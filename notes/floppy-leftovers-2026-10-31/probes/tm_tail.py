# Question: what is the KN6000 .TM tail word (+0xB7F8, LE16 after the edit-index byte)?  Try sums over ranges.
import glob, os, sys, collections
FL = sys.argv[1]
files = sorted(glob.glob(os.path.join(FL, 'build', 'kn6000', '*', '*.tm.p1.ref')))
def le(p, a, b): return sum(p[i] | p[i + 1] << 8 for i in range(a, b - 1, 2))
def be(p, a, b): return sum(p[i] << 8 | p[i + 1] for i in range(a, b - 1, 2))
KB = 0x10 + 40 * 0x2C8
hits = collections.Counter(); n = 0; seen = {}
for f in files:
    p = open(f, 'rb').read()
    if p[:16] != b'KN6000 SOUND RAM': continue
    n += 1
    t = p[-2] | p[-1] << 8; tb = p[-2] << 8 | p[-1]
    cands = {}
    for name, a, b in [('sounds', 0x10, KB), ('sounds+kit', 0x10, len(p) - 3), ('all', 0, len(p) - 3), ('kit', KB, len(p) - 3),
                       ('all+idx', 0, len(p) - 2), ('sounds+kit+idx', 0x10, len(p) - 2), ('kit+idx', KB, len(p) - 2)]:
        for odd in (0, 1):
            aa = a + odd
            for fn, nm in ((le, 'le16'), (be, 'be16')):
                v = fn(p, aa, b)
                for op, vv in (('~', ~v & 0xFFFF), ('', v & 0xFFFF), ('-', -v & 0xFFFF)):
                    cands['%s%s %s +%d' % (op, nm, name, odd)] = vv
            v = sum(p[aa:b])
            cands['~bytes %s +%d' % (name, odd)] = ~v & 0xFFFF; cands['bytes %s +%d' % (name, odd)] = v & 0xFFFF
    for k, v in cands.items():
        if v == t: hits[k + ' (LE word)'] += 1
        if v == tb: hits[k + ' (BE word)'] += 1
    seen[f] = (p[-3], t, len(p))
print(n, 'files')
for k, v in hits.most_common(12): print(v, k)
print(collections.Counter(v[2] for v in seen.values()))
