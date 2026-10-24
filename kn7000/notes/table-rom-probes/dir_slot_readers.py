#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Which program-flash code reads which slot of the table-flash offset directory?
#
# The firmware reaches a table segment as  mov (0x48000000 + 4*i), Rn ; add 0x48000000, Rn
# (MN10300 `mov (abs32), Dm` = FC A4+m, `mov (abs32), Am` = FC A0+m, both followed by
# the 32-bit address).  This scans the program image's two code regions for those
# opcodes with an address inside the directory and prints, per slot, every reader and
# the named function it sits in (nearest preceding symbol of kn7000.sym,
# kn7000_manual.sym, kn7000_exports_from_942.sym).
#
#   python3 notes/table-rom-probes/dir_slot_readers.py [baserom/kn7000_program.rom] [baserom/kn7000_table.rom]
#   python3 notes/table-rom-probes/dir_slot_readers.py baserom/kn7000_program_sp7001.rom \
#       baserom/kn7000_table_sp7001.rom 0x80:0x1864F4,0x3B97B4:0x3F8BDB      # program 942
# (the third argument gives the code regions; names are still looked up in the 941 .sym files,
# so for 942 only the reader counts are meaningful)
#
# Run from kn7000/.  This is a byte scan of the code regions, not a decode: a hit is the
# instruction only if it lies on the instruction stream, which the script does not check.
# Every hit quoted in src/table.s was read in the unidasm listing (`make disasm`).
# The nearest preceding symbol can be far away (a large +offset): then the reader sits
# in an unnamed function after it, not inside the named one.
import re
import struct
import sys

PROG = sys.argv[1] if len(sys.argv) > 1 else "baserom/kn7000_program.rom"
TABLE = sys.argv[2] if len(sys.argv) > 2 else "baserom/kn7000_table.rom"
PBASE, TBASE = 0x48400000, 0x48000000
REGIONS = [(0x80, 0x186000), (0x3B8D00, 0x3F6F01)]       # Makefile: disasm region 1 and 2
if len(sys.argv) > 3:
    REGIONS = [tuple(int(x, 0) for x in r.split(":")) for r in sys.argv[3].split(",")]

p = open(PROG, "rb").read()
t = open(TABLE, "rb").read()
first = struct.unpack_from("<I", t, 0)[0]
dirents = [first]
for i in range(1, first // 4):
    v = struct.unpack_from("<I", t, 4 * i)[0]
    if v <= dirents[-1] or v > len(t):
        break
    dirents.append(v)
nslot = len(dirents)

syms = {}
for f in ("kn7000.sym", "kn7000_manual.sym", "kn7000_exports_from_942.sym"):
    for line in open(f):
        m = re.match(r"0x([0-9A-Fa-f]{8})\s+(\S+)", line)
        if m:
            a = int(m.group(1), 16)
            if PBASE <= a < PBASE + len(p):
                syms.setdefault(a, m.group(2))
addrs = sorted(syms)


def owner(cpu):
    import bisect
    k = bisect.bisect_right(addrs, cpu) - 1
    return f"{syms[addrs[k]]}+0x{cpu - addrs[k]:X}" if k >= 0 else "?"


hits = {}
for lo, hi in REGIONS:
    for o in range(lo, hi - 6):
        if p[o] == 0xFC and 0xA0 <= p[o + 1] <= 0xA7:
            v = struct.unpack_from("<I", p, o + 2)[0]
            if TBASE <= v < TBASE + 4 * nslot and v % 4 == 0:
                reg = ("a" if p[o + 1] < 0xA4 else "d") + str(p[o + 1] & 3)
                hits.setdefault((v - TBASE) // 4, []).append((PBASE + o, reg))

for i in range(nslot):
    rd = hits.get(i, [])
    print(f"dir[{i:2d}] -> 0x{TBASE + dirents[i]:08X}  ({len(rd)} readers)")
    for cpu, reg in rd:
        print(f"    0x{cpu:08X} mov (dir[{i}]),{reg}  in {owner(cpu)}")
