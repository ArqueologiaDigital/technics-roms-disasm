#!/usr/bin/env python3
"""Does a set of compiled objects reproduce the firmware at the source/binary pairs?

usage: python3 -I -B pairs_check.py PAIRS.tsv OBJDIR [--tag TAG] [--md]
OBJDIR holds IEEE-695 objects (`*.rel`, any case) compiled from Toshiba's LIB/SRC files, named after the source
(`_LDIV.rel` for `_LDIV.C`): an oracle run's `out/<compiler>/<label>/` directory, or our compiler's output in the
same form.  For each pair of PAIRS.tsv (pairs.py), the object of its source file is read, the piece of its public
is taken (split at publics like xref_runtime.py, relocated fields masked) and compared with the image at the pair's
address over the piece's length:
- `=`        every known byte agrees;
- `N diff`   N known bytes differ; the first at +OFF (`first +OFF`);
- `no obj`   the source was not compiled (or failed); `no piece`: the object has no such public.
Prints TSV (or an aligned Markdown table with --md): image, address, public, source, how, length, result, first,
then a summary line per result.  --tag labels the summary (e.g. the compiler and options).
"""
import os, sys, glob, collections
R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
sys.path.insert(0, os.path.join(R, 'notes/toshiba-runtime-xref-2026-11-08'))
import ieee695, lib_match, xref_runtime as X

def pieces_of(objdir):
    objs = {}
    for f in glob.glob(os.path.join(objdir, '*')):
        if f.lower().endswith('.rel'): objs[os.path.basename(f)[:-4].upper()] = f
    cache = {}
    def get(src):
        b = src[:-2].upper()
        if b not in objs: return None
        if b not in cache:
            m = ieee695.Module(open(objs[b], 'rb').read())
            d = {}
            for sname, pub, off, pat, rel in lib_match.pieces_r(m):
                d.setdefault(pub if pub != sname else '%s data' % m.name.lower(), pat)
            cache[b] = d
        return cache[b]
    return get

def main():
    pairs_f, objdir = sys.argv[1], sys.argv[2]
    tag = sys.argv[sys.argv.index('--tag') + 1] if '--tag' in sys.argv else objdir
    md = '--md' in sys.argv
    get = pieces_of(objdir)
    segs = {n: X.segments(e) for n, ref, e in X.IMAGES if os.path.exists(e)}
    rows, summ = [], collections.Counter()
    for l in open(pairs_f).read().splitlines()[1:]:
        im, a, pub, mem, src, how = l.split('\t')[:6]
        a = int(a, 16)
        d = get(src)
        if d is None: res, first, n = 'no obj', '', 0
        elif pub not in d: res, first, n = 'no piece', '', 0
        else:
            pat = d[pub]; n = len(pat)
            img = next((data[a - va:a - va + n] for va, data in segs.get(im, []) if va <= a < va + len(data)), b'')
            diff = [i for i, x in enumerate(pat) if x is not None and x >= 0 and (i >= len(img) or img[i] != x)]
            res = '=' if not diff else '%d diff' % len(diff)
            first = '' if not diff else '+%d' % diff[0]
        summ['=' if res == '=' else res.split()[-1] if res.endswith('diff') else res] += 1
        rows.append((im, '0x%06x' % a, pub, src, how, str(n), res, first))
    head = ('image', 'address', 'public', 'source', 'how', 'bytes', 'result', 'first')
    if md:
        w = [max(len(r[i]) for r in rows + [head]) for i in range(len(head))]
        print('| ' + ' | '.join(h.ljust(x) for h, x in zip(head, w)) + ' |')
        print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
        for r in rows: print('| ' + ' | '.join(c.ljust(x) for c, x in zip(r, w)) + ' |')
        print()
    else:
        print('\t'.join(head))
        for r in rows: print('\t'.join(r))
    print('%s: %d pairs: %s' % (tag, len(rows), ', '.join('%s %d' % kv for kv in sorted(summ.items()))))

main()
