#!/usr/bin/env python3
"""The source/binary pairs: Toshiba runtime routines compiled from C whose copy in a ROM we know.

usage: python3 -I -B pairs.py > pairs.tsv
The Technics compiler's own output on source we know exactly is the main evidence for the cc900-compat `kn5000`
personality (notes/cc900-compat-plan-2026-11-08/PLAN.md, section 2).  A pair is a public symbol of a library member
built from C (member name ending in `_c`; its source is LIB/SRC/<NAME>.C) together with an address in one of our
images, found in one of four ways:
- `exact`: an exact hit of xref_runtime.py (results/xref.resolved.tsv), with the libraries it matched;
- `call`:  an address that a matched routine calls or points to under that name (results/xref.inferred.tsv);
- `near`:  a near match (results/near.tsv), with its score;
- `known`: listed in KNOWN below, by our label (the routine matches nowhere and nothing matched calls it).
Writes TSV: image, address, public, member, source file, how, detail, our label.  An address can appear under
more than one public when a matched piece holds several; the first way found wins per (image, address, public).
A `near` or `call` row is dropped when the same image has an `exact` row for that public (an offset artefact).
"""
import os, sys, collections, subprocess
R = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
XN = os.path.join(R, 'notes/toshiba-runtime-xref-2026-11-08')
sys.path.insert(0, XN)
import ieee695, lib_match, xref_runtime as X

KNOWN = [('maincpu v10', 'Sprintf_Core', '__doprnt'), ('maincpu v9', 'Sprintf_Core', '__doprnt'),
         ('maincpu v7', 'Sprintf_Core', '__doprnt'), ('maincpu v6', 'Sprintf_Core', '__doprnt'),
         ('maincpu v5', 'Sprintf_Core', '__doprnt')]

def c_publics():
    """public -> (member, source file), from every library's C members; data pieces as '<member> data'"""
    out = {}
    for ln, lf in X.LIBS:
        for m in ieee695.library(open(lf, 'rb').read()):
            if not m.name.endswith('_c'): continue
            src = m.name[:-2].upper() + '.C'
            for sname, pub, off, pat, rel in lib_match.pieces_r(m):
                out.setdefault(pub if pub != sname else '%s data' % m.name, (m.name, src))
            for n in m.publics.values(): out.setdefault(n, (m.name, src))
    return out

def tsv(path):
    L = open(path).read().splitlines()
    return [l.split('\t') for l in L[1:]]

def main():
    cp = c_publics()
    rows = collections.OrderedDict()
    def add(im, a, pub, how, detail, lab):
        names = [p.strip() for p in pub.split('|')]
        for p in names:
            if p in cp and (im, a, p) not in rows:
                rows[(im, a, p)] = (how, detail, lab, cp[p])
    for r in tsv(os.path.join(XN, 'results/xref.resolved.tsv')):
        add(r[0], int(r[1], 16), r[2], 'exact', r[5], r[4])
    for r in tsv(os.path.join(XN, 'results/xref.inferred.tsv')):
        add(r[0], int(r[1], 16), r[2], 'call', 'called from %s' % r[3], r[4])
    for r in tsv(os.path.join(XN, 'results/near.tsv')):
        add(r[0], int(r[1], 16), r[3], 'near', '%s %s' % (r[2], r[6]), r[7])
    elfs = {n: e for n, ref, e in X.IMAGES}
    for im, lab, pub in KNOWN:
        out = subprocess.run([X.NM, '--defined-only', elfs[im]], capture_output=True, text=True, check=True).stdout
        a = [int(l.split()[0], 16) for l in out.splitlines() if l.split()[-1] == lab]
        if a: add(im, a[0], pub, 'known', 'by label', lab)
    exact = {(im, p) for (im, a, p), v in rows.items() if v[0] == 'exact'}
    for k in [k for k, v in rows.items() if v[0] in ('near', 'call') and (k[0], k[2]) in exact]: del rows[k]
    print('\t'.join(['image', 'address', 'public', 'member', 'source', 'how', 'detail', 'our_label']))
    for (im, a, p), (how, detail, lab, (mem, src)) in sorted(rows.items(), key=lambda kv: ([n for n, _, _ in X.IMAGES].index(kv[0][0]), kv[0][1])):
        print('\t'.join([im, '%06x' % a, p, mem, src, how, detail, lab]))

main()
