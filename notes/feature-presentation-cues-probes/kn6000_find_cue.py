#!/usr/bin/env python3
"""Question: which event in a KN6000 'I KD' song carries the <ACT NO=n> cue?  For every status byte S
(bit 7 set) followed by data bytes a, b, c (bit 7 clear), group the events by (track, S, a, b) and print
the groups whose third byte c runs through 1, 2, 3 ... (the ACT numbers).  Walks song 1's tracks with the
KN5000 cell layout (see kn6000_song_events.py).  Usage: kn6000_find_cue.py PART1.bin PART2.bin"""
import sys
from collections import defaultdict
p1 = open(sys.argv[1], 'rb').read(); p2 = open(sys.argv[2], 'rb').read(); rec = p1[:0x876]
groups = defaultdict(list)
for t in range(16):
    e = 0xD0 + 3*t; fl, cell = rec[e], rec[e+1] | rec[e+2] << 8
    if not fl & 0x80: continue
    pay = bytearray(); c = cell; seen = set()
    while c not in (0, 0xFFFF) and c not in seen and (c-1)*256+256 <= len(p2):
        seen.add(c); b = (c-1)*256; pay += p2[b+5:b+256]; c = p2[b+3] | p2[b+4] << 8
    beat = 0
    for i in range(len(pay) - 3):
        s = pay[i]
        if s == 0x81: beat += 1
        if s == 0x82: break
        if s & 0x80 and not (pay[i+1] | pay[i+2] | pay[i+3]) & 0x80 and (s & 0xF0) != 0x90:
            groups[(t, s, pay[i+1], pay[i+2])].append((beat, pay[i+3]))
for k, v in sorted(groups.items()):
    vals = [x[1] for x in v]
    if len(vals) >= 3 and vals[:3] == [1, 2, 3] or (len(vals) >= 3 and sorted(set(vals)) == list(range(1, max(vals)+1)) and len(set(vals)) >= 4):
        print('track %d status %02X a %02X b %02X: %d events, values %s' % (k[0], k[1], k[2], k[3], len(v), [(bt, x) for bt, x in v]))
