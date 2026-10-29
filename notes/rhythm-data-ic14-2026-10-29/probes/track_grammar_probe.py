#!/usr/bin/env python3
"""track_grammar_probe.py -- does every byte past the records parse as tracks, and is every track used?

QUESTION: with the reader's grammar (AccVoice_ProcessEventLoop: 0x81 1 byte, 0x90 6, 0x91 8
(AccMidi_ParseNoteOn), 0xD1..0xD5 3 (AccMidi_ParseDType), 0x83 end, then the 0x87 page-end byte),
do banks 6..0x37 decode from the first track to FF fill with no unknown byte; are all track headers
80 FF FF FF FF 87; does every one of the 404 x 6 x 19 slot words land on a track start; and is every
track named by some slot?  Exits 1 on any failure.
USAGE: python3 notes/rhythm-data-ic14-2026-10-29/probes/track_grammar_probe.py [IC14]
"""
import collections
import sys
from ic14_common import load, walk, slot_targets, HALVES

d = load()
tracks, ops, bad = {}, collections.Counter(), 0
regions = [(0x65000, 0x70000)] + [(b * 0x10000, (b + 1) * 0x10000) for b in range(7, 0x38)]
for a, b in regions:
    p = a
    while p < b and d[p] != 0xff:
        ev, e = walk(d, p)
        tracks[p] = e
        ops.update(x[0] for x in ev)
        p = e
    if d[p:b] != b"\xff" * (b - p):
        print("bank 0x%02X: non-FF after the last track at 0x%06X" % (a >> 16, p))
        bad += 1
if d[0x380000:] != b"\xff" * (len(d) - 0x380000):
    print("0x380000-: not all FF")
    bad += 1
refs = collections.Counter()
for h in HALVES:
    for lane, s, t in slot_targets(d, h):
        if t not in tracks:
            print("half 0x%06X part %d slot %d -> 0x%06X: not a track start" % (h, lane, s, t))
            bad += 1
        refs[t] += 1
unref = set(tracks) - set(refs)
print("tracks %d, bytes %d, events %d %s" % (len(tracks), sum(e - s for s, e in tracks.items()), sum(ops.values()),
                                            {hex(k): v for k, v in sorted(ops.items())}))
print("slot references %d, distinct %d, unreferenced tracks %d" % (sum(refs.values()), len(refs), len(unref)))
sys.exit(1 if bad or unref else 0)
