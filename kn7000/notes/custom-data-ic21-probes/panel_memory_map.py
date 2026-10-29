#!/usr/bin/env python3
"""panel_memory_map.py -- does the stored one-touch-setting record follow program 941's writer?

Question: func_4C02A0C4 (KN7000 library) builds each 0xA0-byte setting from panel-memory records
through tables of {source offset, destination offset, mask} triples.  This prints those tables
(from the program image) and, per bank, how many stored bytes break a mask, how many settings
lack the 941 part tails at +0x8F (p23 > 7), and how many KN6000 settings have part 3 all 0xFF.

Usage: python3 -I panel_memory_map.py PROGRAM_941.rom IMAGE [IMAGE ...]
       (a 0x1E0000-byte image whose OTS records are 0x90 bytes is read as a KN6000 bank)
"""
import struct
import sys

TABLES = [("part (x4)", 0x4858E19C, 26), ("entries", 0x4858E1EA, 1), ("+0x70", 0x4858E1ED, 7),
          ("+0x77", 0x4858E202, 3), ("+0x7A", 0x4858E20B, 14), ("+0x88", 0x4858E235, 4),
          ("+0x8C", 0x4858E241, 2), ("part tail (x4, 941)", 0x4858E24A, 3)]
prog = open(sys.argv[1], "rb").read()
for name, addr, n in TABLES:
    o = addr - 0x48400000
    print(f"{name:20s} {addr:#x}: " + " ".join(f"{prog[o + 3*i]:#x}->{prog[o + 3*i + 1]}&{prog[o + 3*i + 2]:#04x}"
                                              for i in range(n)))
part_masks = [prog[0x18E19C + 3 * i + 2] for i in range(26)]
for path in sys.argv[2:]:
    d = open(path, "rb").read()
    ots = 0x90 if struct.unpack_from("<I", d, d[2] * 0x8000 + 0x90)[0] == 0x240 else 0xA0
    bad = tails = ff3 = 0
    for s in range(20):
        b = d[d[2 + 2 * s] * 0x8000:]
        off = struct.unpack_from("<I", b, 0x8C)[0]
        for i in range(4):
            r = b[off + i * ots:off + (i + 1) * ots]
            for k in (0, 0x1A, 0x34, 0x56):
                bad += sum(1 for j in range(3, 26) if r[k + j] & ~part_masks[j])
            ff3 += r[0x56:0x70] == b"\xff" * 0x1A
            if ots == 0xA0:
                tails += any(r[0x8F + 3 * k] > 7 for k in range(4))
    print(f"{path}: {ots:#x}-byte settings; part bytes outside their mask {bad}; "
          f"settings without 941 tails {tails}; part 3 all 0xFF {ff3}")
