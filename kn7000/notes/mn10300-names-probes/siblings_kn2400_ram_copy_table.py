#!/usr/bin/env python3
"""siblings_kn2400_ram_copy_table.py -- what does the KN2400's start-up copy from RamCodeTrailer, and where to?

Question it answers: crt0_start ends with `call func_4870587E_entry` and `jmp KernelStart`.  func_4870587E
walks 12-byte records from RamCodeTrailer+3 (0x487965BB), assembling each field byte by byte (movbu, asl 8 /
16 / 24):
    +0  u16 flags     bit 15 = the last record
    +2  u16 length    used only by the last record
    +4  u32 source    (flash)
    +8  u32 dest      (link address); below 0x80000000 the copy writes dest + 0x40000000 (the uncached view)
For every record but the last the length is next.source - source.  The routine then copies `length` bytes
(setlb / movbu / lcs).  This script replays that walk on the reference image and prints each record and the
range it copies, then checks that no word of the image and no PC-relative call / jmp / calls targets the
second record's destination 0x5018FFF0..0x5018FFF2.

Run (from the repo root):
    python3 kn7000/notes/mn10300-names-probes/siblings_kn2400_ram_copy_table.py [kn2400/baserom/kn2400_program.rom]
Read-only, deterministic.  Expected output: two records,
    0x487285BE -> 0x50120000, 0x6DFFA bytes (file 0x3285BE..0x3965B8: the RAM-linked code, 0x50120000..0x5018DFFA)
    0x487965B8 -> 0x5018FFF0, 3 bytes (de 00 00 = `retf [], 0`)
and 0 references to 0x5018FFF0..2.
"""
import os
import struct
import sys

BASE = 0x48400000
RAM_LO, RAM_HI, RAM_DELTA = 0x3285BE, 0x3965B8, 0x4FDF7A42   # file range linked for 0x50120000 (kn2400/README.md)
TABLE = 0x487965BB                                            # RamCodeTrailer + 3


def main():
    here = os.path.dirname(os.path.abspath(__file__))
    rom = sys.argv[1] if len(sys.argv) > 1 else os.path.join(here, "..", "..", "..", "kn2400", "baserom",
                                                               "kn2400_program.rom")
    d = open(rom, "rb").read()
    u16 = lambda a: struct.unpack_from("<H", d, a - BASE)[0]
    u32 = lambda a: struct.unpack_from("<I", d, a - BASE)[0]
    recs, a = [], TABLE
    while True:
        flags, ln, src, dst = u16(a), u16(a + 2), u32(a + 4), u32(a + 8)
        recs.append((a, flags, ln, src, dst))
        if flags & 0x8000:
            break
        a += 12
    print(f"{'record':10} {'flags':6} {'len16':6} {'source':10} {'dest':10} {'written at':10} {'length':8} file range")
    for i, (a, flags, ln, src, dst) in enumerate(recs):
        n = ln if flags & 0x8000 else recs[i + 1][3] - src
        w = dst + 0x40000000 if dst < 0x80000000 else dst
        print(f"0x{a:08X} 0x{flags:04X} 0x{ln:04X} 0x{src:08X} 0x{dst:08X} 0x{w:08X} 0x{n:06X}   "
              f"0x{src - BASE:06X}..0x{src - BASE + n:06X} -> link 0x{dst:08X}..0x{dst + n:08X}")
    last = recs[-1]
    print("last record's bytes:", d[last[3] - BASE:last[3] - BASE + last[2]].hex(" "),
          "(MN10300 0xDE = retf: `retf [], 0`)")
    # references to the last destination
    lo, hi = last[4], last[4] + last[2]
    words = [o for o in range(len(d) - 3) if lo <= struct.unpack_from("<I", d, o)[0] < hi
             and o != last[0] - BASE + 8]
    branches = []
    for o in range(len(d) - 6):
        pc = o + (RAM_DELTA if RAM_LO <= o < RAM_HI else BASE)
        b = d[o]
        for t, kind in (((pc + struct.unpack_from("<i", d, o + 1)[0]) if b in (0xDC, 0xDD) else None, "d32"),
                        ((pc + struct.unpack_from("<h", d, o + 1)[0]) if b in (0xCC, 0xCD) else None, "d16"),
                        ((pc + struct.unpack_from("<i", d, o + 2)[0]) if b == 0xFC and d[o + 1] == 0xFF else None, "calls32"),
                        ((pc + struct.unpack_from("<h", d, o + 2)[0]) if b == 0xFA and d[o + 1] == 0xFF else None, "calls16")):
            if t is not None and lo <= (t & 0xFFFFFFFF) < hi:
                branches.append((o, kind))
    print(f"words equal to 0x{lo:08X}..0x{hi - 1:08X} outside the table: {len(words)}; "
          f"PC-relative branches there: {len(branches)}")


if __name__ == "__main__":
    sys.exit(main())
