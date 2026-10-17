#!/usr/bin/env python3
"""s.py REGEX [tree] [-C N] [-i] -- search every .s/.c/.h file of <tree>/maincpu (default v10) as latin-1 bytes,
so files with bytes > 127 are NOT skipped (the ugrep wrapper skips them). Prints file:line: text."""
import os, glob, re, sys
root = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'snap') + '/'  # git archive of HEAD, see snap/COMMIT
args = [a for a in sys.argv[1:]]
ctx = 0
flags = 0
if '-C' in args:
    i = args.index('-C'); ctx = int(args[i+1]); del args[i:i+2]
if '-i' in args:
    args.remove('-i'); flags = re.I
pat = re.compile(args[0], flags)
tree = args[1] if len(args) > 1 else 'v10'
files = sorted(glob.glob(root + tree + '/maincpu/**/*.[sch]', recursive=True)) if tree != 'all' else sorted(glob.glob(root + '**/*.[sch]', recursive=True))
for p in files:
    L = open(p, 'rb').read().decode('latin-1').split('\n')
    for i, l in enumerate(L):
        if pat.search(l):
            rel = p.replace(root, '')
            if ctx:
                print('--- %s:%d' % (rel, i+1))
                for k in range(max(0, i-ctx), min(len(L), i+ctx+1)):
                    print('%s%6d: %s' % ('>' if k == i else ' ', k+1, L[k]))
            else:
                print('%s:%d: %s' % (rel, i+1, l))
