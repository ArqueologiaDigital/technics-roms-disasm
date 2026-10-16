#!/usr/bin/env python3
# Question: how many bytes of code region 1 does a generated program source emit as
# MN10300 assembly (i.e. NOT as .incbin_range)? Used to check that naming more functions
# (INHERIT_SYMS) never shrinks the converted source.
# Run from the repo root:  python3 -I notes/sp7001-probes/asm_coverage.py
import re
def asm_bytes(path, lo, hi):
    raw = 0
    for line in open(path):
        m = re.match(r'\.incbin_range "[^"]+", (0x[0-9a-fA-F]+), (0x[0-9a-fA-F]+)', line)
        if m:
            a, b = int(m.group(1), 16), int(m.group(2), 16)
            raw += max(0, min(b, hi) - max(a, lo))
    return (hi - lo) - raw
a = asm_bytes("src/program.s", 0x80, 0x186000)          # build 941 region 1
b = asm_bytes("src/sp7001/program.s", 0x80, 0x1864F4)   # build 942 region 1 (941's bound, mapped)
print(f"region-1 bytes emitted as assembly: build 941 {a}, build 942 {b}, difference {b - a} "
      f"(942's new code block is 1285 B, the last byte a 0xFF pad)")
