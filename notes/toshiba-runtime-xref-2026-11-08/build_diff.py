#!/usr/bin/env python3
"""Where do the three runtime builds differ, on the routines the firmware matches in some builds but not in all?

usage: python3 -I -B build_diff.py XREF.resolved.tsv > results/build_diff.md
For each exact hit of xref_runtime.py (one image per family: FAMILY below) whose library builds are not all three
of 1997 (V4.23), 2003 (kit-CD IDE) and 2008 (v1.10), and for each build it does NOT match, this takes that build's
piece of the same public name (the `ml` library; the `pic` one only when `ml` has none) and compares it with the
image's bytes at the hit:
- same length: the offsets of the known (not relocated) bytes that differ, and those bytes, library vs image;
- other length: the length difference, and the first differing offset;
- no such piece in that build: "absent".
A same-length difference in a C routine whose source did not change is the code generator's (instruction choice or
order), which is evidence about the compiler that built the firmware's runtime.
"""
import os, sys, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ieee695, lib_match, xref_runtime as X

FAMILY = ['maincpu v10', 'subcpu v142', 'table data', 'hdae v2.06i', 'hdae v1.10i', 'wsa1 prom_a']
BUILDS = [('1997', 'V4.23 ml', None), ('2003', 'IDE ml', 'IDE pic'), ('2008', 'v1.10 ml', 'v1.10 pic')]

def pieces_by_name():
    by = collections.defaultdict(dict)   # library tag -> public -> pattern
    for ln, lf in X.LIBS:
        for m in ieee695.library(open(lf, 'rb').read()):
            for sname, pub, off, pat, rel in lib_match.pieces_r(m):
                if pub == sname: pub = '%s data' % m.name
                by[ln].setdefault(pub, pat)
    return by

def image_bytes(segs, a, n):
    for va, data in segs:
        if va <= a < va + len(data): return data[a - va:a - va + n]
    return b''

def compare(pat, img):
    if len(img) < len(pat): return None
    return [i for i, x in enumerate(pat) if x is not None and x >= 0 and img[i] != x]

def main():
    by = pieces_by_name()
    res = [l.split('\t') for l in open(sys.argv[1]).read().splitlines()[1:]]
    rows = []
    for im in FAMILY:
        elf = [i for i in X.IMAGES if i[0] == im][0][2]
        segs = X.segments(elf)
        for r in res:
            if r[0] != im or '|' in r[2]: continue
            libs = set(r[5].split(','))
            matched = [y for y, ml, pic in BUILDS if ml in libs or (pic and pic in libs)]
            if len(matched) == 3: continue
            a, name, n = int(r[1], 16), r[2], int(r[3])
            for y, ml, pic in BUILDS:
                if y in matched: continue
                pat = by[ml].get(name) or (by[pic].get(name) if pic else None)
                if pat is None:
                    rows.append((im, '0x%06x' % a, '`%s`' % name, n, ', '.join(matched), y, 'absent', '')); continue
                img = image_bytes(segs, a, max(len(pat), n) + 16)
                if len(pat) == n:
                    d = compare(pat, img)
                    show = ' '.join('+%d %02x/%02x' % (i, pat[i], img[i]) for i in d[:6]) + (' ...' if len(d) > 6 else '')
                    rows.append((im, '0x%06x' % a, '`%s`' % name, n, ', '.join(matched), y,
                                 'same length, %d bytes differ' % len(d), show))
                else:
                    first = next((i for i in range(min(len(pat), n)) if pat[i] is not None and pat[i] >= 0
                                  and pat[i] != img[i]), None)
                    rows.append((im, '0x%06x' % a, '`%s`' % name, n, ', '.join(matched), y,
                                 '%+d bytes' % (len(pat) - n), '' if first is None else 'first difference at +%d' % first))
    head = ('image', 'address', 'Toshiba name', 'bytes', 'matches', 'build', 'difference', 'library/image bytes')
    w = [max(len(str(x[i])) for x in rows + [head]) for i in range(len(head))]
    print('| ' + ' | '.join(h.ljust(x) for h, x in zip(head, w)) + ' |')
    print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
    for x in rows: print('| ' + ' | '.join(str(c).ljust(v) for c, v in zip(x, w)) + ' |')

main()
