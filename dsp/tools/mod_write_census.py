#!/usr/bin/env python3
"""mod_write_census.py DSMDIR -- every delay-DRAM word (dly.r / dly.w in the generated .dsm) in each program, and whether a
lo12 == 0x44C word (apply modulation offset) comes within the 3 words before it: does any WRITE take a modulated
address? Prints per program: reads, modulated reads, writes, modulated writes; then the modulated writes."""
import glob
import os
import re
import sys

rows, mw = [], []
for path in sorted(glob.glob(os.path.join(sys.argv[1], 'prog*.dsm'))):
    words = []
    for line in open(path):
        m = re.match(r'\s+w(\d+)\s+([0-9A-F]{10})\s+(\S+)', line)
        if m:
            words.append((int(m.group(1)), int(m.group(2), 16), m.group(3), line.strip()))
    r = rm = w = wm = 0
    for i, (n, raw, mnem, line) in enumerate(words):
        if mnem not in ('dly.r', 'dly.w'):
            continue
        mod = any((x[1] & 0xFFF) == 0x44C for x in words[max(0, i - 3):i])
        if mnem == 'dly.r':
            r += 1; rm += mod
        else:
            w += 1; wm += mod
            if mod:
                mw.append((os.path.basename(path), n, line[:90]))
    rows.append((os.path.basename(path), r, rm, w, wm))
print('%-34s %5s %5s %5s %5s' % ('program', 'reads', 'mod', 'writes', 'mod'))
for row in rows:
    if row[1] or row[3]:
        print('%-34s %5d %5d %5d %5d' % row)
print('\nmodulated writes:')
for x in mw:
    print('  %s w%d  %s' % x)
