#!/usr/bin/env python3
"""Near matches: library pieces that do not occur exactly but nearly (another build of the same routine).

usage: python3 -I near_match.py XREF.resolved.tsv OUT.tsv [--min-len 24] [--min-score 0.80]
(one image per family: FAMILY below; the other versions repeat their exact hits)
For every piece of the four libraries (xref_runtime.LIBS) with at least --min-len known bytes, and every image
(xref_runtime.IMAGES), candidate starts come from each 6-byte unmasked window of the piece found in the image; the
score at a start is the fraction of the piece's known bytes that equal the image.  The best start per (piece, image)
is kept when score >= --min-score, score < 1 (exact hits are xref_runtime's), and no exact hit of any piece is
already at that address.  Writes TSV: image, address, library, public, length, known, score, our label.
"""
import os, sys, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ieee695, lib_match, xref_runtime as X

FAMILY = {'maincpu v10', 'maincpu v7', 'subcpu v142', 'subcpu boot', 'table data', 'hdae v2.06i', 'hdae v1.10i',
          'wsa1 prom_a', 'wsa1 prom_b', 'wsa1 prom_c'}

def main():
    res, out = sys.argv[1], sys.argv[2]
    mn = int(sys.argv[sys.argv.index('--min-len') + 1]) if '--min-len' in sys.argv else 24
    ms = float(sys.argv[sys.argv.index('--min-score') + 1]) if '--min-score' in sys.argv else 0.80
    exact = collections.defaultdict(set)
    for l in open(res).read().splitlines()[1:]:
        f = l.split('\t'); exact[f[0]].add(int(f[1], 16))
    pieces = []
    for ln, lf in X.LIBS:
        for m in ieee695.library(open(lf, 'rb').read()):
            for sname, pub, off, pat, rel in lib_match.pieces_r(m):
                kn = [(i, x) for i, x in enumerate(pat) if x is not None and x >= 0]
                if len(kn) >= mn and len({x for _, x in kn}) >= 8: pieces.append((ln, pub, pat, kn))
    rows = []
    for iname, img, elf in [i for i in X.IMAGES if i[0] in FAMILY]:
        syms = X.symbols(elf); addrs = sorted(syms); segs = X.segments(elf)
        for ln, pub, pat, kn in pieces:
            best = (0, None)
            for va, data in segs:
                cands = set()
                for k in range(0, len(pat) - 6):
                    w = pat[k:k + 6]
                    if any(x is None or x < 0 for x in w): continue
                    a = bytes(w); p = 0; n = 0
                    while n < 64:
                        p = data.find(a, p)
                        if p < 0: break
                        if p - k >= 0: cands.add(p - k)
                        p += 1; n += 1
                for c in cands:
                    if c + len(pat) > len(data): continue
                    sc = sum(1 for i, x in kn if data[c + i] == x) / len(kn)
                    if sc > best[0]: best = (sc, va + c)
            sc, a = best
            if a is not None and ms <= sc < 1 and a not in exact[iname]:
                rows.append((iname, a, ln, pub, len(pat), len(kn), sc, X.label(syms, addrs, a)))
    # one row per (image, address): the best-scoring piece
    by = {}
    for r in rows:
        k = (r[0], r[1])
        if k not in by or (r[6], r[5]) > (by[k][6], by[k][5]): by[k] = r
    with open(out, 'w') as f:
        f.write('image\taddress\tlibrary\tpublic\tlength\tknown\tscore\tour_label\n')
        for r in sorted(by.values()):
            f.write('%s\t%06x\t%s\t%s\t%d\t%d\t%.3f\t%s\n' % r)
    print('%d near matches' % len(by), file=sys.stderr)

main()
