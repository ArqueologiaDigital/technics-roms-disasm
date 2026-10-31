# Question: how much of the KN6000/KN7000 .SQT stale cell bytes do the two event orders (kn_sqt.stale_tokens) explain?
import glob, os, sys, collections
FL = sys.argv[1]
sys.path.insert(0, os.path.join(FL, 'tools', 'kd')); import kn_sqt
from sqt_tails import chains
tot = collections.Counter()
for p2f in sorted(glob.glob(os.path.join(FL, 'build', 'kn[67]000', '*', '*.sqt.p2.ref'))):
    model = p2f.split(os.sep)[-3]
    p1 = open(p2f.replace('.p2.ref', '.p1.ref'), 'rb').read(); p2 = open(p2f, 'rb').read()
    ch, owner = chains(p1, p2)
    pieces = []
    for s, t, cells in ch:
        stream = b''.join(p2[(c - 1) * 256 + 5:c * 256] for c in cells)
        toks, why = kn_sqt.tokens(stream)
        if why: continue
        end = toks[-1][0] + toks[-1][1]; k = end // 251
        if k >= len(cells): continue
        rest = stream[end:251 * (k + 1)]
        if rest and len(set(rest)) > 1: pieces.append(rest)
    for c in range(1, len(p2) // 256 + 1):
        b = p2[(c - 1) * 256 + 5:c * 256]
        if c not in owner and len(set(b)) > 1: pieces.append(b)
    for r in pieces:
        tk = kn_sqt.stale_tokens(r)
        for o, m, line in tk:
            kind = 'unexplained' if line is None else ('cut' if line.startswith(';') else line.split('\t')[1].split('_')[0])
            tot[(model, kind)] += m
        tot[(model, 'pieces')] += 1
        tot[(model, 'bytes')] += len(r)
        if tk and tk[-1][2] is None: tot[(model, 'pieces with a rest')] += 1
for k, v in sorted(tot.items()): print(k, v)
