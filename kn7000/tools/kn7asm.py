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
#   label:                         define a symbol = current output offset
#   .equ NAME, EXPR                define a constant symbol
#   .org EXPR                      assert the current output offset equals EXPR
#   .byte  b [, b ...]             emit 8-bit values
#   .word  w [, w ...]             emit 16-bit little-endian values
#   .long  l [, l ...]             emit 32-bit little-endian values
#   .space N [, FILL]              emit N fill bytes (FILL default 0x00)
#   .incbin "path" [, START [, LEN]]           append bytes from a file
#   .incbin_range "path", START, END           append path[START:END] and
#                                              assert the current offset == START
#
# EXPR supports hex (0x..), decimal, defined symbols, and + - * ( ).
# Numeric byte/word/long args additionally accept the same expressions.

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


class Assembler:
    def __init__(self, base_dir):
        self.base_dir = base_dir
        self.out = bytearray()
        self.symbols = {}
        self.cur_file = "<none>"
        self.cur_line = 0
        self.mn_base = 0   # CPU address that output offset 0 maps to (.mnbase)

    # -- instruction operand symbol resolution --------------------------------

    # Registers must never be treated as symbols even if something .equ's the name.
    _REGS = frozenset(("d0", "d1", "d2", "d3", "a0", "a1", "a2", "a3",
                       "sp", "pc", "mdr", "psw", "lir", "lar"))

    def resolve_operands(self, operands):
        """Substitute known symbol names in an instruction's operand string with
        their numeric value, so `call DispatchEvent` assembles like `call 0x...`.
        This keeps converted disassembly readable while staying byte-exact."""
        def repl(m):
            tok = m.group(0)
            if tok not in self._REGS and tok in self.symbols:
                return hex(self.symbols[tok])
            return tok
        return re.sub(r"[A-Za-z_][A-Za-z0-9_]*", repl, operands)

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
                else:
                    raise AsmError(f"undefined symbol {tok!r}")
        try:
            return int(eval(" ".join(py), {"__builtins__": {}}, {}))
        except AsmError:
            raise
        except Exception as e:
            raise AsmError(f"bad expression {expr!r}: {e}")

    def split_args(self, rest):
        """Split a directive's argument list on commas outside quotes."""
        args, buf, in_str = [], "", False
        for ch in rest:
            if ch == '"':
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
            raise AsmError(f".incbin_range start {start:#x} != current offset "
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

    def do_org(self, args):
        want = self.evaluate(args[0])
        if len(self.out) != want:
            raise AsmError(f".org {want:#x} != current offset {len(self.out):#x}")

    # -- top-level assembly ---------------------------------------------------

    def assemble_file(self, path):
        prev_file, prev_line = self.cur_file, self.cur_line
        self.cur_file = path
        with open(path, "r") as f:
            lines = f.readlines()
        for i, raw in enumerate(lines, 1):
            self.cur_line = i
            line = raw.split("#", 1)[0].split(";", 1)[0].strip()
            if not line:
                continue

            m = re.match(r"([A-Za-z_.][\w.]*):(.*)$", line)
            if m and not line.startswith("."):
                self.symbols[m.group(1)] = len(self.out)
                line = m.group(2).strip()
                if not line:
                    continue

            parts = line.split(None, 1)
            op = parts[0]
            rest = parts[1] if len(parts) > 1 else ""
            args = self.split_args(rest)

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
            elif op == ".space":
                self.do_space(args)
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
                try:
                    self.out += mn10300_asm.encode(op, self.resolve_operands(rest), pc)
                except mn10300_asm.EncError as e:
                    raise AsmError(f"cannot encode '{op} {rest}': {e}")
            else:
                raise AsmError(f"unknown directive {op!r}")
        self.cur_file, self.cur_line = prev_file, prev_line


def main():
    parser = argparse.ArgumentParser(description="KN7000 byte-exact reassembler")
    parser.add_argument("source", help="top-level .s source file")
    parser.add_argument("-o", "--output", required=True, help="output binary")
    parser.add_argument("-I", "--include-dir", default=None,
                        help="base directory for relative paths"
                             " (default: the source file's directory)")
    args = parser.parse_args()

    base = args.include_dir or os.path.dirname(os.path.abspath(args.source)) or "."
    asm = Assembler(base)
    try:
        asm.assemble_file(args.source)
    except AsmError as e:
        sys.stderr.write(f"{asm.cur_file}:{asm.cur_line}: error: {e}\n")
        return 1

    with open(args.output, "wb") as f:
        f.write(asm.out)
    print(f"kn7asm: wrote {args.output} ({len(asm.out):#x} bytes)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
