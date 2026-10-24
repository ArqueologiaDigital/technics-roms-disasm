#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# kn7asm - a tiny, self-contained assembler/linker for the KN7000 disassembly.
#
# There is no free GNU binutils target for the KN7000's Panasonic MN10300 CPU
# available in this environment, so instead of depending on a cross-assembler
# this project uses a minimal assembler whose whole job is to reconstruct the
# flash images byte-for-byte from a source tree.
#
# The disassembly starts as a "skeleton": every byte of the ROM is pulled in
# verbatim with `.incbin_range` (a not-yet-understood region) or written out as
# `.byte`/`.word`/`.long`/`.space` (an understood region). As reverse
# engineering progresses, `.incbin_range` blocks shrink and are replaced by real
# data/instruction directives -- and `make verify` guarantees the rebuilt image
# stays 100% identical to the original at every step.
#
# Supported syntax (one directive per line; `#` or `;` start a comment):
#
#   label:                         define a symbol = the CPU address of the
#                                  current output offset (.mnbase + offset;
#                                  with no .mnbase that is the offset itself)
#   .equ NAME, EXPR                define a constant symbol
#   .org EXPR                      assert the current output offset equals EXPR
#   .byte  b [, b ...]             emit 8-bit values
#   .word  w [, w ...]             emit 16-bit little-endian values
#   .long  l [, l ...]             emit 32-bit little-endian values
#   .ascii "text" [, "text" ...]   emit the bytes of each string
#   .asciz "text" [, "text" ...]   the same, each followed by a NUL
#                                  (escapes: \\ \" \n \r \t \0 and \xHH,
#                                  exactly two hex digits; `#` and `;` inside
#                                  quotes are text, not a comment)
#   .space N [, FILL]              emit N fill bytes (FILL default 0x00)
#   .align N [, FILL]              emit FILL bytes up to the next multiple of N
#   .incbin "path" [, START [, LEN]]           append bytes from a file
#   .incbin_range "path", START, END           append path[START:END] and
#                                              assert the current offset == START
#
# An instruction operand may be NAME+N or NAME-N (folded to one number).
#
# EXPR supports hex (0x..), decimal, defined symbols, and + - * ( ).
# Numeric byte/word/long args additionally accept the same expressions.
#
# An instruction operand or an EXPR may name a label defined LATER in the source
# (a forward branch to a local label in converted code, or a table of offsets
# that comes before the data it points into). The source is then
# assembled again, with the addresses the previous pass found, until a pass
# uses only addresses that turn out to be right; that pass's output is the
# result, and only its errors (layout assertions included) are reported. A
# label whose name is already an .equ (a function name from symbols.inc) must
# land on that address, so converted code also cross-checks the symbol tables.

import argparse
import os
import re
import sys

# The MN10300 instruction encoder lives beside this file. It lets source lines
# hold real MN10300 mnemonics (unidasm operand syntax) that assemble to bytes,
# not just raw .incbin/.byte data. Optional: without it, only data directives work.
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
try:
    import mn10300_asm
except ImportError:
    mn10300_asm = None


class AsmError(Exception):
    pass


def strip_comment(raw):
    """`raw` up to the first `#` or `;` that is not inside a double-quoted string."""
    in_str = esc = False
    for i, ch in enumerate(raw):
        if esc:
            esc = False
        elif in_str and ch == "\\":
            esc = True
        elif ch == '"':
            in_str = not in_str
        elif ch in "#;" and not in_str:
            return raw[:i]
    return raw


class Assembler:
    def __init__(self, base_dir):
        self.base_dir = base_dir
        self.known = {}    # symbol -> value, as found by the previous pass
        self.parsed = {}   # path -> its lines, parsed once for every pass
        self.enc_cache = {}  # (mnemonic, resolved operands, pc) -> bytes, this pass
        self.start_pass()

    def start_pass(self):
        # encodings of the previous pass, looked up by this one (most lines
        # encode the same operands at the same pc again)
        self.enc_prev, self.enc_cache = getattr(self, "enc_cache", {}), {}
        self.out = bytearray()
        self.symbols = {}
        self.labels = {}
        self.cur_file = "<none>"
        self.cur_line = 0
        self.mn_base = 0   # CPU address that output offset 0 maps to (.mnbase)
        self.guessed = {}      # forward name with no address yet -> (file, line) of 1st use
        self.assumed = {}      # forward names resolved from the previous pass
        # output offset at each source line, this pass and the previous one: a
        # forward label is estimated at its previous address plus the drift this
        # line has had since, so displacements are those of ONE layout
        self.prev_off = getattr(self, "line_off", {})
        self.line_off = {}
        self.problem = None    # first error of this pass; raised only if it is exact

    def fail(self, msg):
        """An error that may be an artefact of a placeholder address: keep the
        first one, and raise it once the pass proves to be exact."""
        if self.problem is None:
            self.problem = AsmError(msg), self.cur_file, self.cur_line

    # -- instruction operand symbol resolution --------------------------------

    # Registers must never be treated as symbols even if something .equ's the name.
    _REGS = frozenset(("d0", "d1", "d2", "d3", "a0", "a1", "a2", "a3",
                       "sp", "pc", "mdr", "psw", "lir", "lar",
                       "other", "other0", "other2", "other3"))   # register-list members

    def resolve_operands(self, operands):
        """Substitute known symbol names in an instruction's operand string with
        their numeric value, so `call DispatchEvent` assembles like `call 0x...`.
        This keeps converted disassembly readable while staying byte-exact.
        A name not defined yet is a forward label: it takes the previous pass's
        address if there was one, else this instruction's own address as a
        placeholder (which makes the pass inexact)."""
        def repl(m):
            tok = m.group(1)
            if tok is None or tok in self._REGS:
                return m.group(0)               # a number, or a register
            if tok in self.symbols:
                return hex(self.symbols[tok])
            if tok in self.known:
                return hex(self.forward(tok))
            self.guessed.setdefault(tok, (self.cur_file, self.cur_line))
            return hex(self.mn_base + len(self.out))
        out = re.sub(r"0x[0-9A-Fa-f]+|\d+|([A-Za-z_]\w*)", repl, operands)
        # fold `NAME+N` / `NAME-N` (an address inside a labelled data item) into
        # one number for the encoder
        fold = re.compile(r"(0x[0-9A-Fa-f]+|\b\d+)\s*([+-])\s*(0x[0-9A-Fa-f]+|\d+)\b")
        while True:
            m = fold.search(out)
            if not m:
                return out
            a, b = int(m.group(1), 0), int(m.group(3), 0)
            out = out[:m.start()] + hex(a + b if m.group(2) == "+" else a - b) + out[m.end():]

    def forward(self, tok):
        """The estimated address of forward label `tok`: where the previous pass
        put it, moved by the drift this line has had since. Without the drift a
        pass mixes two layouts (backward labels from this one, forward ones from
        the last), and the branches that span the difference relax and grow."""
        here = len(self.out)
        v = self.known[tok] + here - self.prev_off.get((self.cur_file, self.cur_line), here)
        self.assumed[tok] = v
        return v

    # -- expression evaluation ------------------------------------------------

    def evaluate(self, expr):
        expr = expr.strip()
        # tokenise into numbers, symbols and operators
        tokens = re.findall(r"0x[0-9A-Fa-f]+|\d+|[A-Za-z_.][\w.]*|[()+\-*]", expr)
        py = []
        for tok in tokens:
            if re.fullmatch(r"0x[0-9A-Fa-f]+|\d+", tok):
                py.append(str(int(tok, 0)))
            elif tok in "()+-*":
                py.append(tok)
            else:
                if tok == ".":
                    py.append(str(len(self.out)))  # current offset
                elif tok in self.symbols:
                    py.append(str(self.symbols[tok]))
                elif tok in self.known:        # a forward label: the previous pass's address
                    py.append(str(self.forward(tok)))
                else:                          # not defined yet: a placeholder, so this pass is inexact
                    self.guessed.setdefault(tok, (self.cur_file, self.cur_line))
                    py.append(str(self.mn_base + len(self.out)))
        try:
            return int(eval(" ".join(py), {"__builtins__": {}}, {}))
        except AsmError:
            raise
        except Exception as e:
            raise AsmError(f"bad expression {expr!r}: {e}")

    def split_args(self, rest):
        """Split a directive's argument list on commas outside quotes."""
        args, buf, in_str, esc = [], "", False, False
        for ch in rest:
            if esc:
                esc = False
                buf += ch
            elif ch == "\\" and in_str:
                esc = True
                buf += ch
            elif ch == '"':
                in_str = not in_str
                buf += ch
            elif ch == "," and not in_str:
                args.append(buf.strip())
                buf = ""
            else:
                buf += ch
        if buf.strip():
            args.append(buf.strip())
        return args

    def unquote(self, arg):
        if not (arg.startswith('"') and arg.endswith('"')):
            raise AsmError(f"expected quoted string, got {arg!r}")
        return arg[1:-1]

    _ESC = {"\\": 0x5C, '"': 0x22, "n": 0x0A, "r": 0x0D, "t": 0x09, "0": 0x00}

    def string_bytes(self, arg):
        """The bytes of a quoted .ascii/.asciz string, escapes decoded."""
        body = self.unquote(arg)
        out, i = bytearray(), 0
        while i < len(body):
            ch = body[i]
            if ch != "\\":
                if ord(ch) > 0x7E:
                    raise AsmError(f"non-ASCII character in string (write \\x{ord(ch):02X})")
                out.append(ord(ch))
                i += 1
            elif body[i + 1:i + 2] == "x" and re.fullmatch(r"[0-9A-Fa-f]{2}", body[i + 2:i + 4]):
                out.append(int(body[i + 2:i + 4], 16))
                i += 4
            elif body[i + 1:i + 2] in self._ESC:
                out.append(self._ESC[body[i + 1]])
                i += 2
            else:
                raise AsmError(f"bad escape in string: {body[i:i + 4]!r}")
        return bytes(out)

    def do_ascii(self, args, nul):
        for a in args:
            self.out += self.string_bytes(a) + (b"\0" if nul else b"")

    def resolve_path(self, path):
        return path if os.path.isabs(path) else os.path.join(self.base_dir, path)

    # -- directive handlers ---------------------------------------------------

    def do_incbin_range(self, args):
        if len(args) != 3:
            raise AsmError(".incbin_range needs: \"path\", START, END")
        path = self.resolve_path(self.unquote(args[0]))
        start = self.evaluate(args[1])
        end = self.evaluate(args[2])
        if len(self.out) != start:
            self.fail(f".incbin_range start {start:#x} != current offset "
                      f"{len(self.out):#x} (gap or overlap in the layout)")
        if end < start:
            raise AsmError(f".incbin_range end {end:#x} < start {start:#x}")
        with open(path, "rb") as f:
            f.seek(start)
            chunk = f.read(end - start)
        if len(chunk) != end - start:
            raise AsmError(f"{path}: only {len(chunk):#x} bytes available for "
                           f"range [{start:#x}, {end:#x})")
        self.out += chunk

    def do_incbin(self, args):
        path = self.resolve_path(self.unquote(args[0]))
        start = self.evaluate(args[1]) if len(args) >= 2 else 0
        with open(path, "rb") as f:
            f.seek(start)
            chunk = f.read(self.evaluate(args[2]) if len(args) >= 3 else -1)
        self.out += chunk

    def do_byte(self, args, width):
        for a in args:
            value = self.evaluate(a) & ((1 << (8 * width)) - 1)
            self.out += value.to_bytes(width, "little")

    def do_space(self, args):
        n = self.evaluate(args[0])
        fill = self.evaluate(args[1]) & 0xFF if len(args) >= 2 else 0x00
        self.out += bytes([fill]) * n

    def do_align(self, args):
        n = self.evaluate(args[0])
        fill = self.evaluate(args[1]) & 0xFF if len(args) >= 2 else 0x00
        self.out += bytes([fill]) * (-len(self.out) % n)

    def do_org(self, args):
        want = self.evaluate(args[0])
        if len(self.out) != want:
            self.fail(f".org {want:#x} != current offset {len(self.out):#x}")

    # -- top-level assembly ---------------------------------------------------

    def parse_file(self, path):
        """(line number, label or None, op or None, rest, args) per source line
        that holds anything; the same in every pass, so done once."""
        if path not in self.parsed:
            out = []
            with open(path, "r") as f:
                for i, raw in enumerate(f, 1):
                    line = strip_comment(raw).strip()
                    if not line:
                        continue
                    label = None
                    m = re.match(r"([A-Za-z_.][\w.]*):(.*)$", line)
                    if m and not line.startswith("."):
                        label, line = m.group(1), m.group(2).strip()
                    if not line:
                        out.append((i, label, None, "", []))
                        continue
                    parts = line.split(None, 1)
                    rest = parts[1] if len(parts) > 1 else ""
                    out.append((i, label, parts[0], rest,
                                self.split_args(rest) if parts[0].startswith(".") else None))
            self.parsed[path] = out
        return self.parsed[path]

    def assemble_file(self, path):
        prev_file, prev_line = self.cur_file, self.cur_line
        self.cur_file = path
        for i, label, op, rest, args in self.parse_file(path):
            self.cur_line = i
            self.line_off[(path, i)] = len(self.out)
            if label is not None:
                self.define_label(label)
            if op is None:
                continue

            if op == ".equ":
                name, expr = args[0], ",".join(args[1:])
                self.symbols[name] = self.evaluate(expr)
            elif op == ".org":
                self.do_org(args)
            elif op == ".byte":
                self.do_byte(args, 1)
            elif op == ".word":
                self.do_byte(args, 2)
            elif op == ".long":
                self.do_byte(args, 4)
            elif op == ".ascii":
                self.do_ascii(args, False)
            elif op == ".asciz":
                self.do_ascii(args, True)
            elif op == ".space":
                self.do_space(args)
            elif op == ".align":
                self.do_align(args)
            elif op == ".incbin":
                self.do_incbin(args)
            elif op == ".incbin_range":
                self.do_incbin_range(args)
            elif op == ".include":
                self.assemble_file(self.resolve_path(self.unquote(args[0])))
            elif op == ".mnbase":
                self.mn_base = self.evaluate(args[0])
            elif not op.startswith("."):
                # A bare mnemonic => an MN10300 instruction. PC-relative targets
                # (branches/calls/jumps) are absolute CPU addresses, so encode()
                # needs this instruction's CPU address = mn_base + output offset.
                if mn10300_asm is None:
                    raise AsmError("MN10300 encoder (mn10300_asm.py) not available")
                pc = self.mn_base + len(self.out)
                key = (op, self.resolve_operands(rest), pc)
                enc = self.enc_prev.get(key)
                if enc is None:
                    try:
                        enc = mn10300_asm.encode(*key)
                    except mn10300_asm.EncError as e:
                        enc = e
                self.enc_cache[key] = enc
                if isinstance(enc, Exception):
                    self.fail(f"cannot encode '{op} {rest}': {enc}")
                    self.out += b"\0\0"   # e.g. a branch whose target has not settled
                else:
                    self.out += enc
            else:
                raise AsmError(f"unknown directive {op!r}")
        self.cur_file, self.cur_line = prev_file, prev_line

    def define_label(self, name):
        """A label is the CPU address of the current output offset. If the name
        is already an .equ (a function name from symbols.inc), the two must agree."""
        addr = self.mn_base + len(self.out)
        if name in self.labels:
            raise AsmError(f"label {name!r} defined twice")
        if name in self.symbols and self.symbols[name] != addr:
            self.fail(f"label {name!r} is at {addr:#x} but was "
                      f".equ'd to {self.symbols[name]:#x}")
        self.labels[name] = self.symbols[name] = addr

    def seed(self, path):
        """Take a previous build's label addresses (write_labels) as the first
        pass's estimates of forward labels. Only a guess, and only trusted when
        it is right: if the seeded first pass is not exact, assemble() starts
        over from no estimates (see there), so a stale file costs one pass,
        never correctness."""
        try:
            for line in open(path):
                name, value = line.split()
                self.known[name] = int(value, 16)
        except (OSError, ValueError):
            self.known = {}
        self.seeded = bool(self.known)

    def write_labels(self, path):
        with open(path, "w") as f:
            for name, value in sorted(self.labels.items()):
                f.write(f"{name} {value:x}\n")

    def assemble(self, path):
        """Assemble `path`, repeating the pass until it is exact: no placeholder
        was needed and every forward address it took from the previous pass is
        where that label really landed. Usually one pass, or two with forward
        labels.

        A seeded run (seed()) whose first pass is not exact starts over without
        the seed. Branch relaxation only ever grows an instruction, so the
        passes settle on the shortest layout only when they start from short
        branches, as placeholders give. A stale seed can start a conditional
        branch at the edge of its 8-bit reach in its long `bCC !cc; jmp` form,
        and that layout is consistent too: the 3 extra bytes keep the target
        out of reach. Seen 2026-10-24 after a relabelling: `beq` +0x7F at
        0x48507A39 settled long, 3 bytes off from there on."""
        for n in range(20):
            if n == 1 and getattr(self, "seeded", False):
                self.seeded, self.known, self.line_off, self.enc_cache = False, {}, {}, {}
            self.start_pass()
            self.assemble_file(path)
            undefined = [n for n in self.guessed if n not in self.symbols]
            if undefined:
                self.cur_file, self.cur_line = self.guessed[undefined[0]]
                raise AsmError(f"undefined symbol {undefined[0]!r}")
            if not self.guessed and all(self.symbols.get(n) == a
                                        for n, a in self.assumed.items()):
                if self.problem:
                    err, self.cur_file, self.cur_line = self.problem
                    raise err
                return
            self.known = dict(self.symbols)
        raise AsmError("labels did not settle after 20 passes")


def main():
    parser = argparse.ArgumentParser(description="KN7000 byte-exact reassembler")
    parser.add_argument("source", help="top-level .s source file")
    parser.add_argument("-o", "--output", required=True, help="output binary")
    parser.add_argument("--labels", metavar="FILE",
                        help="label addresses of the previous build: read as the first pass's"
                             " estimates (saves passes), rewritten after a good build")
    parser.add_argument("-I", "--include-dir", default=None,
                        help="base directory for relative paths"
                             " (default: the source file's directory)")
    args = parser.parse_args()

    base = args.include_dir or os.path.dirname(os.path.abspath(args.source)) or "."
    asm = Assembler(base)
    if args.labels:
        asm.seed(args.labels)
    try:
        asm.assemble(args.source)
    except AsmError as e:
        sys.stderr.write(f"{asm.cur_file}:{asm.cur_line}: error: {e}\n")
        return 1

    with open(args.output, "wb") as f:
        f.write(asm.out)
    if args.labels:
        asm.write_labels(args.labels)
    print(f"kn7asm: wrote {args.output} ({len(asm.out):#x} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
