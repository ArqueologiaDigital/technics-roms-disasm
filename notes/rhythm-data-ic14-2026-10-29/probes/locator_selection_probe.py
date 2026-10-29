#!/usr/bin/env python3
"""locator_selection_probe.py -- which (bank, program) selects which style record, in each firmware.

QUESTION: how do the program ROMs' RhythmROM_BankProgramLocators (8 banks x 128 programs x {u16 hi, u16 lo},
record = (hi & 0xff) << 16 | lo) map onto IC14's records, which pairs VoiceParam_BankProgramWords (the remap
VoiceParam_ClampAndStore applies) can reach, what the panel calls each record, and is the table the same in
v5..v10?  The panel name: AccStyle_VelocityTableMain[program][bank] = number << 8 | group (a misnamed table),
AccVoice_RomRecords16[group] = group name, AccVoice_RomRecords13[group * 20 + number] = style name, the indexing
of AccVoice_ComputedCopy.  [Measured 2026-10-29: 201 non-zero locators; the zero locator of (bank 0, program 90),
which the remap targets for (0, 89) and (0, 90), addresses the record at 0x000000, 8br86d = STANDARD ROCK 0
"8Bt Standard"; the remap reaches no pair of 8beats and 6beats, whose panel entries PARTY TIME 7 and
MARCH & WALTZ 11 are shared with dxi97p and wzs87e; same table in v5..v10.]  v5/v6/v8 are read from the
private romset when present.
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
print("records %d, with a non-zero locator %d, without %s" % (len(recs), len(sel),
      ["0x%06X %s" % (r, d[r + 0x3db:r + 0x3e1].decode()) for r in sorted(recs - set(sel))]))
sym = {l.split()[0]: int(l.split()[1], 16) for l in open(os.path.join(REPO, "symbols/maincpu_v10_symbols_reference.txt"))
       if not l.startswith("#") and len(l.split()) == 2}
A = lambda n: sym[n] - 0xE00000
remap = {(u16(v10, A("VoiceParam_BankProgramWords") + 2 * i) >> 8, u16(v10, A("VoiceParam_BankProgramWords") + 2 * i) & 0x7f)
         for i in range(1024)}
locof = lambda b, p: ((u16(tab, (b * 128 + p) * 4) & 0xff) << 16) | u16(tab, (b * 128 + p) * 4 + 2)
print("remap targets with a zero locator (-> record 0x000000):", sorted(k for k in remap if not locof(*k)))
print("records the remap reaches no pair of:", sorted(d[o + 0x3db:o + 0x3e1].decode() for o, v in sel.items()
                                                     if not any(k in remap for k in v)))
for o, v in sorted(list(sel.items()) + [(0, [(0, 90)])]):
    for b, p in v:
        w = u16(v10, A("AccStyle_VelocityTableMain") + (p * 8 + b) * 2)
        g, n = w & 0xff, w >> 8
        print("  0x%06X %s  bank %d program %3d  panel %-16s %2d %s" % (
            o, d[o + 0x3db:o + 0x3e1].decode(), b, p,
            v10[A("AccVoice_RomRecords16") + 16 * g:][:16].decode("latin-1").strip(), n,
            v10[A("AccVoice_RomRecords13") + 13 * (g * 20 + n):][:13].decode("latin-1").strip()))
rs = os.path.expanduser("~/compartilhado/technics_roms/roms/kn5000")
for v, p in [("v9", "original_ROMs/kn5000_v9_program.rom"), ("v7", "original_ROMs/kn5000_v7_program.rom"),
             ("v8", rs + "/kn5000_v8_program.rom"), ("v6", rs + "/kn5000_v6_program.rom"),
             ("v5", rs + "/kn5000_v5_program.rom")]:
    p = os.path.join(REPO, p)
    if os.path.exists(p):
        i = open(p, "rb").read().find(tab)
        print("%s: v10 table %s" % (v, "at 0x%06X" % (0xE00000 + i) if i >= 0 else "NOT FOUND"))
