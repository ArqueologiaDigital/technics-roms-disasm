#!/usr/bin/env python3
"""slice_bases.py TREE -- for each compiled-C bin, where does each labelled slice
(`Label: .incbin "includes/generated/X.bin", off, len`) sit in TREE's image, and what blob base
(address - off) does that imply?  A bin whose slices all imply one base is placed contiguously, so a
C `#define BASE` set to that base makes every SELF() pointer exact."""
import collections, glob, os, re, sys
ROOT = os.environ.get('REPO') or os.getcwd()
tree = sys.argv[1]
syms = {}
for ln in open(os.path.join(ROOT, 'symbols', 'maincpu_%s_symbols_reference.txt' % tree)):
    p = ln.split()
    if len(p) == 2 and not ln.startswith('#'):
        syms[p[0]] = int(p[1], 16)
RX = re.compile(rb'^([A-Za-z_][\w.]*):\s*\.incbin\s+"includes/generated/([\w.]+\.bin)"(?:\s*,\s*(0x[0-9a-fA-F]+|\d+))?')
bases = collections.defaultdict(collections.Counter)
for f in glob.glob(os.path.join(ROOT, tree, 'maincpu', '**', '*.s'), recursive=True):
    for ln in open(f, 'rb'):
        m = RX.match(ln)
        if not m:
            continue
        lab = m.group(1).decode(); b = m.group(2).decode(); off = int(m.group(3) or b'0', 0)
        if lab in syms:
            bases[b][syms[lab] - off] += 1
for b in sorted(bases):
    c = bases[b]
    print('%-40s %s' % (b, ', '.join('0x%06x x%d' % kv for kv in c.most_common(6)) + (' ...' if len(c) > 6 else '')))
