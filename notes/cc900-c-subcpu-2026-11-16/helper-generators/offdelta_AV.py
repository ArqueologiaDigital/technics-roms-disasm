#!/usr/bin/env python3
"""Helper AV scratch: in an idiff_full.py output, pair each run of '-' lines with the following run of '+' lines
and report pairs that differ by something other than an XSP offset shifted by DELTA (default 2), plus unpaired lines.

    python3 -B offdelta.py IDIFF.txt [DELTA]
"""
import re
import sys

path = sys.argv[1]
delta = int(sys.argv[2]) if len(sys.argv) > 2 else 2
lines = [l.rstrip('\n') for l in open(path)]
OFF = re.compile(r'XSP\+0x([0-9a-f]+)')


def norm(s, d):
    return OFF.sub(lambda m: 'XSP+%x' % (int(m.group(1), 16) + d), s)


i = 0
bad = 0
while i < len(lines):
    if lines[i].startswith('  -'):
        minus = []
        while i < len(lines) and lines[i].startswith('  -'):
            minus.append(lines[i][3:]); i += 1
        plus = []
        while i < len(lines) and lines[i].startswith('  +'):
            plus.append(lines[i][3:]); i += 1
        if len(minus) != len(plus):
            bad += 1
            print('UNPAIRED', len(minus), len(plus))
            for m in minus: print('   -', m)
            for p in plus: print('   +', p)
            continue
        for m, p in zip(minus, plus):
            if norm(m, delta) != p:
                bad += 1
                print('   -', m, '   |   +', p)
    else:
        i += 1
print('differences other than a +%d offset:' % delta, bad)
