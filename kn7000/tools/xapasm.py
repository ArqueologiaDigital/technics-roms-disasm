#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# xapasm - a small two-pass MN10300 assembler for NEW code on the KN7000 (homebrew
# apps and SP7001 .XAP add-on modules), built on the same encoder as kn7asm.
#
# kn7asm's job is byte-exact reconstruction of existing images: its labels are
# output offsets, they must be defined before use, and operands are plain numbers.
# Hand-written code needs the opposite, so here:
#   * a `label:` is a CPU address (.mnbase + offset), usable before its definition;
#   * passes repeat until every label settles (instruction sizes depend on distances);
#   * operands and data accept expressions: + - * / % << >> & | ( ), symbols, numbers.
#
# Syntax (one statement per line; `#` or `;` start a comment):
#   label:                       define a label (CPU address)
#   .equ NAME, EXPR              define a constant
#   .mnbase EXPR                 CPU address of output offset 0 (default 0)
#   .byte / .word / .long EXPR [, EXPR ...]
#   .space N [, FILL]            N fill bytes (FILL default 0)
#   .fill COUNT, SIZE, VALUE     COUNT copies of VALUE as SIZE (<=4) little-endian bytes
#   .align N [, FILL]            pad to a multiple of N (FILL default 0)
#   .ascii "text" / .asciz "text"
#   .include "file"              relative to the including file, then the -I dirs
#   .ifdef NAME / .ifndef NAME   assemble what follows, up to the matching .else or .endif, only when NAME is
#   .else / .endif               (is not) defined: by -D, or by an .equ before this line (not by a label);
#                                they nest, and the lines skipped are not looked at (labels, .equ, .include)
#   mnemonic operands            MN10300, MAME unidasm operand syntax (mn10300_asm.py)
#
# Usage:  xapasm.py SRC.s -o OUT.bin [-m OUT.map] [-I DIR ...] [-D NAME[=VALUE] ...]
#   -D NAME[=VALUE] defines NAME (as .equ, VALUE default 1) before the first line of every pass.
import argparse
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mn10300_asm as enc  # noqa: E402

REGS = {"d0", "d1", "d2", "d3", "a0", "a1", "a2", "a3", "sp", "pc", "mdr", "psw", "lir", "lar"}


class AsmError(Exception):
    pass


class XapAsm:
    def __init__(self, incdirs=(), defines=None):
        self.incdirs = list(incdirs)
        self.defines = dict(defines or {})  # -D NAME=VALUE
        self.known = {}          # labels settled by the previous pass

    # -- expressions ----------------------------------------------------------
    def eval(self, expr):
        expr = expr.strip()
        if not expr:
            raise AsmError("empty expression")
        toks = re.findall(r"0x[0-9A-Fa-f]+|\d+|[A-Za-z_.][\w.]*|<<|>>|[-+*/%&|()~]", expr)
        if "".join(toks) != re.sub(r"\s+", "", expr):
            raise AsmError(f"bad expression {expr!r}")
        py = []
        for t in toks:
            if re.fullmatch(r"0x[0-9A-Fa-f]+|\d+", t):
                py.append(str(int(t, 0)))
            elif t == "/":
                py.append("//")
            elif re.fullmatch(r"<<|>>|[-+*%&|()~]", t):
                py.append(t)
            elif t == ".":
                py.append(str(self.pc))
            elif t in self.syms:
                py.append(str(self.syms[t]))
            elif t in self.known:
                py.append(str(self.known[t]))
            elif not self.final:
                self.unresolved = True
                py.append(str(self.pc))   # placeholder; settles in a later pass
            else:
                raise AsmError(f"undefined symbol {t!r}")
        return int(eval(" ".join(py), {"__builtins__": {}}, {}))

    @staticmethod
    def num(v):
        # plain "0" for zero: it is also the empty register list of call/ret
        return "0" if v == 0 else (f"-0x{-v:x}" if v < 0 else f"0x{v:x}")

    def operand(self, op):
        s = op.strip()
        if s.startswith("[") or s.lower() in REGS:
            return s
        if s.startswith("(") and s.endswith(")"):
            parts = []
            for p in enc.split_ops(s[1:-1]):
                p = p.strip()
                parts.append(p if p.lower() in REGS else self.num(self.eval(p)))
            return "(" + ", ".join(parts) + ")"
        return self.num(self.eval(s))

    # -- one pass ---------------------------------------------------------------
    def find(self, name, cur_dir):
        for d in [cur_dir] + self.incdirs:
            p = os.path.join(d, name)
            if os.path.exists(p):
                return p
        raise AsmError(f"cannot find include {name!r}")

    def run_pass(self, path, final):
        self.final, self.out, self.syms, self.base = final, bytearray(), dict(self.defines), 0
        self.labels = {}
        self.equs = set(self.defines)   # what .ifdef sees: -D names and .equ names so far
        self.cond = []           # .ifdef/.ifndef nesting: per level, whether its lines are assembled
        self._file(path)
        if self.cond:
            raise AsmError(f"{path}: {len(self.cond)} .ifdef/.ifndef without .endif")
        return self.out, self.labels

    @property
    def pc(self):
        return self.base + len(self.out)

    def _file(self, path):
        cur_dir = os.path.dirname(os.path.abspath(path))
        for n, raw in enumerate(open(path), 1):
            try:
                self._line(raw, cur_dir)
            except (AsmError, enc.EncError) as e:
                raise AsmError(f"{path}:{n}: {e}") from None

    def _line(self, raw, cur_dir):
        line, quoted = "", False
        for ch in raw:                      # `#` and `;` start a comment outside "strings"
            if ch == '"':
                quoted = not quoted
            elif ch in "#;" and not quoted:
                break
            line += ch
        line = line.strip()
        op, _, rest = line.partition(" ")
        if op in (".ifdef", ".ifndef"):
            name = rest.strip()
            if not re.fullmatch(r"[A-Za-z_][\w.]*", name):
                raise AsmError(f"{op} needs a symbol name")
            self.cond.append(all(self.cond) and ((name in self.equs) == (op == ".ifdef")))
            return
        if op in (".else", ".endif"):
            if not self.cond or rest.strip():
                raise AsmError(f"{op} without .ifdef/.ifndef" if not self.cond else f"{op} takes no operand")
            if op == ".endif":
                self.cond.pop()
            else:
                self.cond[-1] = all(self.cond[:-1]) and not self.cond[-1]
            return
        if not all(self.cond):
            return
        m = re.match(r"([A-Za-z_][\w.]*):(.*)$", line)
        if m:
            if m.group(1) in self.labels:
                raise AsmError(f"label {m.group(1)!r} defined twice")
            self.labels[m.group(1)] = self.syms[m.group(1)] = self.pc
            line = m.group(2).strip()
        if not line:
            return
        op, _, rest = line.partition(" ")
        rest = rest.strip()
        if op == ".equ":
            name, expr = rest.split(",", 1)
            self.syms[name.strip()] = self.eval(expr)
            self.equs.add(name.strip())
        elif op == ".mnbase":
            if self.out:
                raise AsmError(".mnbase must come before any output")
            self.base = self.eval(rest)
        elif op in (".byte", ".word", ".long"):
            w = {".byte": 1, ".word": 2, ".long": 4}[op]
            for a in enc.split_ops(rest):
                self.out += (self.eval(a) & ((1 << (8 * w)) - 1)).to_bytes(w, "little")
        elif op == ".fill":
            a = enc.split_ops(rest)                 # .fill COUNT, SIZE, VALUE (SIZE<=4)
            count, size = self.eval(a[0]), (self.eval(a[1]) if len(a) > 1 else 1)
            val = self.eval(a[2]) if len(a) > 2 else 0
            self.out += (val & ((1 << (8 * size)) - 1)).to_bytes(size, "little") * count
        elif op == ".space":
            a = enc.split_ops(rest)
            self.out += bytes([self.eval(a[1]) & 0xFF if len(a) > 1 else 0]) * self.eval(a[0])
        elif op == ".align":
            a = enc.split_ops(rest)
            n, fill = self.eval(a[0]), (self.eval(a[1]) & 0xFF if len(a) > 1 else 0)
            while len(self.out) % n:
                self.out.append(fill)
        elif op in (".ascii", ".asciz"):
            m = re.fullmatch(r'"(.*)"', rest)
            if not m:
                raise AsmError(f"{op} needs a quoted string")
            self.out += m.group(1).encode("latin1") + (b"\0" if op == ".asciz" else b"")
        elif op == ".include":
            self._file(self.find(rest.strip('"'), cur_dir))
        elif op.startswith("."):
            raise AsmError(f"unknown directive {op!r}")
        else:
            ops = ", ".join(self.operand(o) for o in enc.split_ops(rest)) if rest else ""
            try:
                self.out += enc.encode(op, ops, self.pc)
            except enc.EncError:
                if self.final:
                    raise
                self.out += b"\0\0"        # e.g. a short branch whose target has not settled yet

    def assemble(self, path):
        prev = None
        for _ in range(40):
            _, labels = self.run_pass(path, final=False)
            if labels == prev:
                break
            prev, self.known = labels, labels
        else:
            raise AsmError("labels did not settle after 40 passes")
        out, labels = self.run_pass(path, final=True)
        if labels != self.known:
            raise AsmError("final pass moved a label")
        return bytes(out), labels


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("src")
    ap.add_argument("-o", "--out", required=True)
    ap.add_argument("-m", "--map")
    ap.add_argument("-I", dest="incdirs", action="append", default=[])
    ap.add_argument("-D", dest="defines", action="append", default=[], metavar="NAME[=VALUE]")
    a = ap.parse_args()
    defines = {}
    for d in a.defines:
        name, _, val = d.partition("=")
        if not re.fullmatch(r"[A-Za-z_][\w.]*", name):
            sys.exit(f"xapasm: -D {d!r}: not a symbol name")
        defines[name] = int(val, 0) if val else 1
    try:
        out, labels = XapAsm(a.incdirs, defines).assemble(a.src)
    except AsmError as e:
        sys.exit(f"xapasm: {e}")
    open(a.out, "wb").write(out)
    if a.map:
        with open(a.map, "w") as f:
            for name, addr in sorted(labels.items(), key=lambda kv: kv[1]):
                f.write(f"0x{addr:08X}  {name}\n")
    print(f"xapasm: wrote {a.out} ({len(out)} bytes, {len(labels)} labels)")


if __name__ == "__main__":
    main()
