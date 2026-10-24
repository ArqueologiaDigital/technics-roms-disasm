#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# What in src/ic18/boot.s is still spelled as a bare number or as bytes nobody
# typed? Prints
#   * the instructions whose memory operand is a numeric address, by address
#     (a `(0x........)` operand: a register or variable with no .equ);
#   * the 32-bit immediates in code that are still numbers, by value, for the
#     ones at or above 0x20000000 (where this board's devices and memories are;
#     below that they are masks and constants);
#   * the `.byte` lines with no comment of their own, summed per label above them
#     (the label's own comment may still say what they are);
#   * how many distinct LCD controller registers (LCDC_*) LcdControllerInit names.
#
#   python3 -I leftovers.py ../../src/ic18/boot.s
import collections
import re
import sys


def main(path):
    lines = open(path, "rb").read().decode("ascii").split("\n")
    mem = collections.Counter()
    imm = collections.Counter()
    untyped = collections.Counter()
    label = None
    routine = None
    lcdc = set()
    for ln in lines:
        m = re.match(r"# ---- (\w+) ", ln)
        if m:
            routine = m.group(1)
        if routine == "LcdControllerInit":
            lcdc |= set(re.findall(r"\bLCDC_(?!VRAM\b)\w+", ln.split("#")[0]))
        m = re.match(r"([A-Za-z_]\w*):", ln)
        if m:
            label = m.group(1)
            continue
        if ln.startswith("# ----"):
            label = None
        if not ln.startswith("    ") or ln.startswith("    ."):
            m = re.match(r"    \.byte   (.*?)(\s+#.*)?$", ln)
            if m and not m.group(2):
                untyped[label] += len(m.group(1).split(","))
            continue
        code = ln.split("#")[0]
        for a in re.findall(r"\((0x[0-9a-fA-F]{8})\)", code):
            mem[a.lower()] += 1
        for v in re.findall(r"(?<![(\w])(0x[0-9a-fA-F]{8})\b(?!\))", code):
            if int(v, 16) >= 0x20000000:
                imm[v.lower()] += 1
    print(f"numeric memory operands: {sum(mem.values())} uses of {len(mem)} addresses")
    for a, n in sorted(mem.items()):
        print(f"  {a}  x{n}")
    print(f"numeric immediates >= 0x20000000 in code: {sum(imm.values())} uses of {len(imm)} values")
    for a, n in sorted(imm.items()):
        print(f"  {a}  x{n}")
    print(f"uncommented .byte: {sum(untyped.values())} bytes under {len(untyped)} labels")
    for lab, n in untyped.most_common():
        print(f"  {n:4d}  {lab}")
    print(f"LcdControllerInit names {len(lcdc)} distinct LCD controller registers")


if __name__ == "__main__":
    main(sys.argv[1])
