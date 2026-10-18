#!/usr/bin/env python3
"""List the non-note events of song 1 of a decoded KN6000 'I KD' .SQT, assuming the KN5000 song layout
(+0xD0: 16 x {flags bit7=present, u16 start cell}; cells of 256 B in part 2, cell c at (c-1)*256,
[3..4] = next cell, payload [5..255]; status byte = bit 7 set; 0x81 = beat).
Usage: kn6000_song_events.py PART1.bin PART2.bin [--all] [--track N]"""
import sys
from collections import Counter
p1 = open(sys.argv[1], 'rb').read(); p2 = open(sys.argv[2], 'rb').read()
show_all = '--all' in sys.argv
only = int(sys.argv[sys.argv.index('--track') + 1]) if '--track' in sys.argv else None
rec = p1[:0x876]
print('header +0x20:', rec[0x20:0x30].hex(' ')); print('header +0x30:', rec[0x30:0x40].hex(' '))
stat = Counter()
for t in range(16):
    e = 0xD0 + 3*t; fl, cell = rec[e], rec[e+1] | rec[e+2] << 8
    if not fl & 0x80: continue
    if only is not None and t != only: continue
    pay = bytearray(); c = cell; seen = set()
    while c not in (0, 0xFFFF) and c not in seen and (c-1)*256+256 <= len(p2):
        seen.add(c); b = (c-1)*256; pay += p2[b+5:b+256]; c = p2[b+3] | p2[b+4] << 8
    i = 0; beat = 0
    print('track %2d flags %02X start cell %04X cells %d payload %d' % (t, fl, cell, len(seen), len(pay)))
    while i < len(pay):
        s = pay[i]
        if s & 0x80:
            j = i+1
            while j < len(pay) and not pay[j] & 0x80: j += 1
            data = pay[i+1:j]
            if s == 0x81: beat += 1
            elif s == 0x82:
                print('   END at beat', beat); break
            else:
                stat[(t, s & 0xF0)] += 1
                if (s & 0xF0) != 0x90 and (show_all or (s & 0xF0) not in (0x90,)):
                    print('   beat %4d st %02X %s' % (beat, s, data.hex(' ')))
            i = j
        else: i += 1
print(sorted(stat.items()))
