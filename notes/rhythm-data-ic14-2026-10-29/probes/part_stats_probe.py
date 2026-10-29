#!/usr/bin/env python3
"""part_stats_probe.py -- what each of the six parts plays (the basis of the part names).

QUESTION: which part slots hold drums, bass and chords?  Per part (record +0x118 + 0x26 * part): distinct
tracks, note-number range / median / most common notes, event mix; and whether parts 0 and 1 name the same
tracks.  [Measured 2026-10-29: parts 0 and 1 name the same 5,716 tracks in every half, GM drum notes
36/49/38; part 2 notes 23..84, median 36; parts 3..5 median 62..64.]
USAGE: python3 notes/rhythm-data-ic14-2026-10-29/probes/part_stats_probe.py [IC14]
"""
import collections
import statistics
from ic14_common import load, walk, slot_targets, HALVES

d = load()
part = collections.defaultdict(set)
same01 = 0
for h in HALVES:
    st = slot_targets(d, h)
    part0 = [t for l, s, t in st if l == 0]
    part1 = [t for l, s, t in st if l == 1]
    same01 += part0 == part1
    for l, s, t in st:
        part[l].add(t)
for l in range(6):
    notes, ops = [], collections.Counter()
    for t in part[l]:
        ev, _ = walk(d, t)
        ops.update(x[0] for x in ev)
        notes += [x[2] for x in ev if x[0] in (0x90, 0x91)]
    print("part %d: %d tracks, notes %d..%d median %s top %s, events %s" % (
        l, len(part[l]), min(notes), max(notes), statistics.median(notes),
        collections.Counter(notes).most_common(4), {hex(k): v for k, v in sorted(ops.items())}))
print("halves whose parts 0 and 1 have identical slot lists: %d of %d" % (same01, len(HALVES)))
