# Question: the stale .SQT bytes that neither event order explains (kn_sqt.stale_tokens line None): are they the
# same bytes, at the same cell and offset, in another song file of the same disk (RAM never written by a song)?
import glob, os, sys, collections
FL = sys.argv[1]
sys.path.insert(0, os.path.join(FL, 'tools', 'kd')); import kn_sqt
from sqt_tails import chains
tot = collections.Counter()
for disk in sorted(glob.glob(os.path.join(FL, 'build', 'kn[67]000', '*'))):
    fs = {f: open(f, 'rb').read() for f in sorted(glob.glob(os.path.join(disk, '*.sqt.p2.ref')))}
    for f, p2 in fs.items():
        p1 = open(f.replace('.p2.ref', '.p1.ref'), 'rb').read()
        ch, owner = chains(p1, p2)
        pieces = []
        for s, t, cells in ch:
            stream = b''.join(p2[(c - 1) * 256 + 5:c * 256] for c in cells)
            toks, why = kn_sqt.tokens(stream)
            if why: continue
            end = toks[-1][0] + toks[-1][1]; k = end // 251
            if k >= len(cells): continue
            at = (cells[k] - 1) * 256 + 5 + end - 251 * k
            pieces.append((at, stream[end:251 * (k + 1)]))
        for c in range(1, len(p2) // 256 + 1):
            if c not in owner: pieces.append(((c - 1) * 256 + 5, p2[(c - 1) * 256 + 5:c * 256]))
        for at, r in pieces:
            if not r or len(set(r)) == 1: continue
            for o, m, line in kn_sqt.stale_tokens(r):
                if line is not None: continue
                a = at + o
                same = [g for g, q in fs.items() if g != f and q[a:a + m] == p2[a:a + m]]
                key = (disk.split(os.sep)[-2], 'same bytes at the same offset in another file' if same else 'unique')
                tot[key] += m
for k, v in sorted(tot.items()): print(k, v)
