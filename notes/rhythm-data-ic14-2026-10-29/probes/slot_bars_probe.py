#!/usr/bin/env python3
"""slot_bars_probe.py -- how long, in bars of the half's time signature, the track in each slot is.

QUESTION: what do the 19 slots hold, and is +0x3D0 the time signature?  Beats are counted as 0x81 events,
bars = beats / AccTone_LookupByProgram_Table[byte +0x3D0].  [Measured 2026-10-29: slots 0..15 and 17 are
exactly 1 bar in all 2,424 part slots each; slots 16 and 18 are 1..8 bars.]  Also prints the
time-signature codes in use.
USAGE: python3 notes/rhythm-data-ic14-2026-10-29/probes/slot_bars_probe.py [IC14]
"""
import collections
from ic14_common import load, walk, slot_targets, HALVES, BPB

d = load()
c = collections.Counter()
for h in HALVES:
    bpb = BPB[d[h + 0x3d0]]
    for l, s, t in slot_targets(d, h):
        ev, _ = walk(d, t)
        c[(s, sum(x[0] == 0x81 for x in ev) / bpb)] += 1
for s in range(19):
    print("slot %2d: %s" % (s, ", ".join("%g bar(s) x%d" % (b, n) for (ss, b), n in sorted(c.items()) if ss == s)))
print("time-signature codes:", dict(collections.Counter(d[h + 0x3d0] for h in HALVES)))
