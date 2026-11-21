#!/usr/bin/env python3
"""Helper AV scratch: from an idiff_full.py output, the map ours-offset -> ROM-offset of XSP slots, over every
paired '-' / '+' line that differs only in its XSP offset (with the push depth as the listing has it).

    python3 -B offmap.py IDIFF.txt
"""
import collections
import re
import sys

lines = [l.rstrip('\n') for l in open(sys.argv[1])]
OFF = re.compile(r'XSP\+0x([0-9a-f]+)')
pairs = collections.Counter()
i = 0
while i < len(lines):
    if lines[i].startswith('  -'):
        minus = []
        while i < len(lines) and lines[i].startswith('  -'):
            minus.append(lines[i][3:]); i += 1
        plus = []
        while i < len(lines) and lines[i].startswith('  +'):
            plus.append(lines[i][3:]); i += 1
        if len(minus) != len(plus):
            continue
        for m, p in zip(minus, plus):
            mm, pm = OFF.search(m), OFF.search(p)
            if mm and pm and OFF.sub('', m) == OFF.sub('', p):
                pairs[(int(mm.group(1), 16), int(pm.group(1), 16))] += 1
    else:
        i += 1
for (a, b), n in sorted(pairs.items()):
    print('%4d -> %4d  (%+d)  x%d' % (a, b, b - a, n))
