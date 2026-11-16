#!/usr/bin/env python3
"""Derive v9/v7/v6/v5 firmware C from v10's by mapping the ram_<hex> cells, read from each tree's hand bodies of the
same functions (before splicing).  usage: port_c_trees.py SRC_DIR(v10 C) OUT_ROOT"""
import os, re, sys, glob
src, out = sys.argv[1:]
NUM = re.compile(r'\((0x[0-9a-f]+|\d+):16\)')
def bodies(tree):
    res = {}
    for dp, dn, fn in os.walk(tree):
        dn[:] = [d for d in dn if d != 'generated']
        for f in fn:
            if not f.endswith('.s'): continue
            L = open(os.path.join(dp, f), 'rb').read().decode('latin-1').split('\n')
            for i, l in enumerate(L):
                m = re.match(r'^([A-Za-z_]\w*):', l)
                if not m: continue
                out_ = []; j = i + 1
                rest = l.split(':', 1)[1].split(';')[0].strip()
                if rest: out_.append(rest)
                while j < len(L) and not (out_ and out_[-1] == 'ret') and len(out_) < 8:
                    c = L[j].split(';')[0].strip()
                    if c: out_.append(c)
                    j += 1
                res[m.group(1)] = out_
    return res
B = {t: bodies(t + '/maincpu') for t in ('v10', 'v9', 'v7', 'v6', 'v5')}
# the v10 numbers come from v10's hand bodies, except the M1 functions (already .include): taken from their readers
cfiles = sorted(glob.glob(os.path.join(src, '*.c')))
funcs = []
for c in cfiles:
    funcs += re.findall(r'^[\w\s\*]+?\b(\w+)\s*\([^)]*\)\s*\{', open(c).read(), re.M)
for t in ('v9', 'v7', 'v6', 'v5'):
    amap = {}
    for f in funcs:
        a, b = B['v10'].get(f, []), B[t].get(f, [])
        if not a or a[0].startswith('.include'): continue
        na = [int(x, 0) for x in NUM.findall(' '.join(a))]; nb = [int(x, 0) for x in NUM.findall(' '.join(b))]
        assert len(na) == len(nb), (t, f, a, b)
        for x, y in zip(na, nb):
            assert amap.get(x, y) == y, (t, f, hex(x), hex(y), hex(amap[x]))
            amap[x] = y
    os.makedirs(os.path.join(out, t), exist_ok=True)
    for c in cfiles:
        s = open(c).read()
        def sub(m):
            v = int(m.group(1), 16)
            if v not in amap: raise SystemExit('%s: %s: no %s address for ram_%x' % (t, c, t, v))
            return 'ram_%x' % amap[v]
        open(os.path.join(out, t, os.path.basename(c)), 'w').write(re.sub(r'\bram_([0-9a-f]+)\b', sub, s))
    print(t, 'cells:', ', '.join('%x->%x' % kv for kv in sorted(amap.items()) if kv[0] != kv[1]) or 'unchanged')
