#!/usr/bin/env python3
"""fpconst.py [LO HI] : the sub-CPU v1.42 payload's floating constants and their values.

QUESTION ANSWERED: for every FPConst_* / FP_Const_* label (and any other label in the DSP constant pool range,
default 0x12c00..0x13300), its size (distance to the next label, 4 = float, 8 = double), its value and a C literal
whose bits are exactly the ROM's (checked by round-tripping through struct).  Run from the csub worktree root.
"""
import struct, sys

ROM = 'original_ROMs/kn5000_subprogram_v142.rom'
SYM = 'symbols/subcpu_symbols_reference.txt'


def lit(v, size):
    for p in range(1, 18):
        s = '%.*g' % (p, v)
        if size == 4:
            if struct.pack('<f', float(s)) == struct.pack('<f', v):
                break
        elif float(s) == v:
            break
    if 'e' not in s and '.' not in s and 'n' not in s:
        s += '.0'
    return s


def main():
    lo = int(sys.argv[1], 16) if len(sys.argv) > 1 else 0x12c00
    hi = int(sys.argv[2], 16) if len(sys.argv) > 2 else 0x13300
    rom = open(ROM, 'rb').read()
    syms = []
    for l in open(SYM):
        f = l.split()
        if len(f) == 2 and not l.startswith('#'):
            try:
                syms.append((int(f[1], 16), f[0]))
            except ValueError:
                pass
    syms.sort()
    for i, (a, n) in enumerate(syms):
        if not (lo <= a < hi):
            continue
        size = syms[i + 1][0] - a if i + 1 < len(syms) else 8
        off = a - 0xf000 + 0x100
        b = rom[off:off + min(size, 8)]
        if size == 4:
            v = struct.unpack('<f', b)[0]
            print('%06x %-55s %d %s  %s' % (a, n, size, b.hex(), lit(v, 4)))
        elif size == 8:
            v = struct.unpack('<d', b)[0]
            print('%06x %-55s %d %s  %s' % (a, n, size, b.hex(), lit(v, 8)))
        else:
            print('%06x %-55s %d %s' % (a, n, size, b.hex()))


if __name__ == '__main__':
    main()
