#!/usr/bin/env python3
"""Search ROM images for the code of Toshiba library members, relocated fields masked.

usage: lib_match.py --lib NAME=FILE.lib [...] --img NAME=FILE[@BASE] [...] [--min N]
Each member section is split at its public symbols into pieces; a piece of at least --min (default 12) known bytes
is searched for in every image: the longest unmasked run is the anchor, every other known byte must agree, and
relocated bytes (IEEE-695 BC/BA items) are wildcards.  Prints TSV: lib, member, section, public, offset in section,
length, known bytes, image, address of every hit (at most 8).
"""
import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ieee695

def pieces(m):
    for si, sec in sorted(m.sections.items()):
        code = m.code(si)
        if not code: continue
        starts = sorted({v[1]: n for k, n in m.publics.items()
                         for v in [m.pubval.get(k)] if isinstance(v, tuple) and v[0] == si}.items())
        if not starts or starts[0][0] != 0: starts = [(0, sec['name'])] + starts
        for j, (o, n) in enumerate(starts):
            e = starts[j + 1][0] if j + 1 < len(starts) else len(code)
            yield sec['name'], n, o, code[o:e]

def pieces_r(m):
    """as pieces(), plus each piece's relocated fields: [(offset in piece, size, expression, member externals)]"""
    for si, sec in sorted(m.sections.items()):
        code = m.code(si)
        if not code: continue
        starts = sorted({v[1]: n for k, n in m.publics.items()
                         for v in [m.pubval.get(k)] if isinstance(v, tuple) and v[0] == si}.items())
        if not starts or starts[0][0] != 0: starts = [(0, sec['name'])] + starts
        for j, (o, n) in enumerate(starts):
            e = starts[j + 1][0] if j + 1 < len(starts) else len(code)
            rel = [(pc - o, size, x) for pc, size, x in sec.get('relocs', []) if o <= pc < e]
            yield sec['name'], n, o, code[o:e], rel

def search(pat, img):
    known = [(i, x) for i, x in enumerate(pat) if x is not None and x >= 0]
    best = (0, 0); i = 0
    while i < len(pat):
        if pat[i] is None or pat[i] < 0: i += 1; continue
        j = i
        while j < len(pat) and pat[j] is not None and pat[j] >= 0: j += 1
        if j - i > best[1] - best[0]: best = (i, j)
        i = j
    a, e = best
    anchor = bytes(pat[a:e]); hits = []; p = 0
    while True:
        p = img.find(anchor, p)
        if p < 0: break
        s = p - a
        if s >= 0 and s + len(pat) <= len(img) and all(img[s + k] == x for k, x in known):
            hits.append(s)
        p += 1
    return hits, len(known)

def main():
    a = sys.argv[1:]; libs = []; imgs = []; mn = 12
    while a:
        k = a.pop(0)
        if k == '--lib': n, f = a.pop(0).split('=', 1); libs.append((n, f))
        elif k == '--img':
            n, f = a.pop(0).split('=', 1); base = 0
            if '@' in f: f, bs = f.rsplit('@', 1); base = int(bs, 16)
            imgs.append((n, open(f, 'rb').read(), base))
        elif k == '--min': mn = int(a.pop(0))
    for ln, lf in libs:
        for m in ieee695.library(open(lf, 'rb').read()):
            for sname, pub, off, pat in pieces(m):
                nk = sum(1 for x in pat if x is not None and x >= 0)
                if nk < mn: continue
                for iname, img, base in imgs:
                    hits, _ = search(pat, img)
                    if hits:
                        print('\t'.join([ln, m.name, sname, pub, str(off), str(len(pat)), str(nk), iname,
                                         ' '.join('%06x' % (base + h) for h in hits[:8]) + (' ...%d' % len(hits) if len(hits) > 8 else '')]))
                        sys.stdout.flush()

main()
