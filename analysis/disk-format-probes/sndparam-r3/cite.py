#!/usr/bin/env python3
"""cite.py FILE REGEX [N] -- print the first N (default 1) lines of snapshot FILE matching REGEX as file:line: text."""
import os, re, sys
SNAP = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'snap') + '/'
f, pat = sys.argv[1], re.compile(sys.argv[2])
n = int(sys.argv[3]) if len(sys.argv) > 3 else 1
L = open(SNAP + f, 'rb').read().decode('latin-1').split('\n')
k = 0
for i, l in enumerate(L):
    if pat.search(l):
        print('%s:%d: %s' % (f, i + 1, l.strip()[:120])); k += 1
        if k >= n: break
