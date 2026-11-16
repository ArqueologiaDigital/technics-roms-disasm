#!/usr/bin/env python3
"""edge_jr.py OBJ NM_OUTPUT GENERATED_DIR [LO HI]

Which short branches of the compiled (cc900) functions sit at the edge of their 8-bit reach?

QUESTION ANSWERED / WHY: the r18 gate stopped at `.org 0xf97d8d` one byte past it, although the same source
assembled without that `.org` is byte-identical to the ROM.  An `.org` is checked during every relaxation pass,
so a `jr` whose target is a few bytes past +127 / -128 in an intermediate layout can trip it.  This disassembles
each function that has a file GENERATED_DIR/<name>.s (between its label and the next label of NM_OUTPUT, an
`llvm-nm` listing of OBJ) and prints every jr / jr cc whose displacement is within 8 of the d8 limits.
LO / HI (hex section offsets) limit the search.
"""
import os
import re
import subprocess
import sys

OBJDUMP = os.path.expanduser('~/compartilhado/llvm-project/build/bin/llvm-objdump')
JR = re.compile(r'^\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*jr\s')


def main():
    obj, nm, gdir = sys.argv[1:4]
    lo = int(sys.argv[4], 16) if len(sys.argv) > 4 else 0
    hi = int(sys.argv[5], 16) if len(sys.argv) > 5 else 1 << 32
    syms = []
    for line in open(nm):
        p = line.split()
        if len(p) == 3 and p[1] in 'tT':
            syms.append((int(p[0], 16), p[2]))
    syms.sort()
    gen = {f[:-2] for f in os.listdir(gdir) if f.endswith('.s')}
    for i, (a, n) in enumerate(syms):
        if n not in gen or not lo <= a < hi:
            continue
        end = next((b for b, _ in syms[i + 1:] if b > a), a + 1)
        out = subprocess.run([OBJDUMP, '-d', '--start-address=%#x' % a, '--stop-address=%#x' % end, obj],
                             capture_output=True, text=True).stdout
        for line in out.splitlines():
            m = JR.match(line)
            if not m:
                continue
            b = m.group(2).split()
            if len(b) != 2:
                continue
            d = int(b[1], 16)
            d = d - 256 if d > 127 else d
            if d >= 120 or d <= -121:
                print('%s +%#x  %s  disp %d' % (n, int(m.group(1), 16) - a, ' '.join(b), d))


if __name__ == '__main__':
    main()
