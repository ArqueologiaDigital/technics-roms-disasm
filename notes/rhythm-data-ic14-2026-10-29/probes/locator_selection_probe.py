#!/usr/bin/env python3
"""locator_selection_probe.py -- which (bank, program) selects which style record, in each firmware.

QUESTION: how do the program ROMs' RhythmROM_BankProgramLocators (8 banks x 128 programs x {u16 hi, u16 lo},
record = (hi & 0xff) << 16 | lo) map onto IC14's records, and is the table the same in v5..v10?  Prints
the map with each record's id (+0x3DB), the record no locator reaches, and per version where the v10 table
occurs.  v5/v6/v8 are read from the private romset when present.
USAGE: python3 notes/rhythm-data-ic14-2026-10-29/probes/locator_selection_probe.py [IC14]
"""
import collections
import os
from ic14_common import load, u16, REPO, LOCATORS, HALVES

d = load()
v10 = open(os.path.join(REPO, "original_ROMs/kn5000_v10_program.rom"), "rb").read()
tab = v10[LOCATORS - 0xE00000:][:0x1000]
sel = collections.defaultdict(list)
for i in range(1024):
    hi, lo = u16(tab, 4 * i), u16(tab, 4 * i + 2)
    if hi or lo:
        sel[((hi & 0xff) << 16) | lo].append((i >> 7, i & 127))
for b in range(8):
    row = ["%d:%s" % (p, d[o + 0x3db:o + 0x3e1].decode()) for o, v in sorted(sel.items()) for bb, p in v if bb == b]
    print("bank %d (%d): %s" % (b, len(row), " ".join(sorted(row, key=lambda x: int(x.split(':')[0])))))
recs = set(range(0, 0x65000, 0x800))
print("records %d, located %d, unlocated %s" % (len(recs), len(sel),
      ["0x%06X %s" % (r, d[r + 0x3db:r + 0x3e1].decode()) for r in sorted(recs - set(sel))]))
rs = os.path.expanduser("~/compartilhado/technics_roms/roms/kn5000")
for v, p in [("v9", "original_ROMs/kn5000_v9_program.rom"), ("v7", "original_ROMs/kn5000_v7_program.rom"),
             ("v8", rs + "/kn5000_v8_program.rom"), ("v6", rs + "/kn5000_v6_program.rom"),
             ("v5", rs + "/kn5000_v5_program.rom")]:
    p = os.path.join(REPO, p)
    if os.path.exists(p):
        i = open(p, "rb").read().find(tab)
        print("%s: v10 table %s" % (v, "at 0x%06X" % (0xE00000 + i) if i >= 0 else "NOT FOUND"))
