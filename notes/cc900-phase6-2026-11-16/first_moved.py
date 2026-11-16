#!/usr/bin/env python3
"""first_moved.py SYMBOLS_REF NM_OUTPUT [BASE]

Which label moved first?  NM_OUTPUT is `llvm-nm --defined-only` of a rebuilt object or
ELF; with BASE (hex, e.g. e00000) the nm values are section offsets and BASE is added.
Lists the first labels, in reference-address order, whose address differs from the
symbols reference file, with the shift, and the labels just before the first one.
Used to find which spliced cc900 function grew when a `.org` check fails.
"""
import sys


def main():
    ref = {}
    for line in open(sys.argv[1]):
        p = line.split()
        if len(p) == 2 and not line.startswith('#'):
            ref[p[0]] = int(p[1], 16)
    base = int(sys.argv[3], 16) if len(sys.argv) > 3 else 0
    got = {}
    for line in open(sys.argv[2]):
        p = line.split()
        if len(p) == 3 and p[1] in 'tT':
            got[p[2]] = int(p[0], 16) + base
    bad = sorted((ref[n], n, got[n]) for n in ref if n in got and got[n] != ref[n])
    print('moved labels:', len(bad))
    if not bad:
        return
    rows = sorted((a, n) for n, a in ref.items() if n in got)
    for a, n in [r for r in rows if r[0] < bad[0][0]][-4:]:
        print('  ok    %06x %s' % (a, n))
    for a, n, g in bad[:6]:
        print('  moved %06x %s -> %06x (%+d)' % (a, n, g, g - a))


if __name__ == '__main__':
    main()
