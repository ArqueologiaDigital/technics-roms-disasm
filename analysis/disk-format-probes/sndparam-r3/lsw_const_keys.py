#!/usr/bin/env python3
"""Find constant keys loaded shortly before calls to the Lsw accessors (read-only): prints key, accessor,
enclosing routine, file:line."""
import glob, os, re, sys, collections
root = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))) + '/'
tree = sys.argv[1] if len(sys.argv) > 1 else 'v10'
ACC = re.compile(r'\s+(call|calr)\s+(MainLsw\w+|SndParam_\w*(Get|Put|Set|Add|Read|Write)\w*|Lsw\w*(Get|Put|Set)\w*)\b')
LD = re.compile(r'\s+ld\s+(xwa|xbc|xde|wa|bc|de)\s*,\s*(0x[0-9a-f]+|\d+)(:i3)?\s*$')
hits = []
for p in sorted(glob.glob(root + tree + '/maincpu/**/*.s', recursive=True)):
    L = open(p, 'rb').read().decode('latin-1').split('\n')
    for i, l in enumerate(L):
        m = ACC.match(l)
        if not m: continue
        fn = None
        for k in range(i, -1, -1):
            mm = re.match(r'^([A-Za-z_]\w*):', L[k])
            if mm: fn = mm.group(1); break
        for k in range(i-1, max(i-8, -1), -1):
            if re.match(r'^\w+:', L[k]) or re.match(r'\s+(call|calr|jr|jrl|jp|ret)\b', L[k]): break
            mm = LD.match(L[k])
            if mm and mm.group(1) in ('xwa', 'wa'):
                v = int(mm.group(2), 0)
                hits.append((v, m.group(2), fn, p.split('/maincpu/')[1] + ':' + str(i+1)))
                break
by = collections.defaultdict(list)
for v, acc, fn, loc in hits: by[v].append((acc, fn, loc))
for v in sorted(by):
    print('0x%05X' % v, len(by[v]), '; '.join('%s in %s (%s)' % x for x in by[v][:3]))
