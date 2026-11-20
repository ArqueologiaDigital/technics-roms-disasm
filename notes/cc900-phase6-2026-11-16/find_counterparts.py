#!/usr/bin/env python3
"""Where are a source tree's labelled routines in another tree's ROM?  For each NAME the bytes at its source-tree
address (up to the next symbol, at most 48) are searched in the target ROM; the longest unique prefix (>= 8 B) wins.
Prints the target address and the nearest preceding target symbol + offset.

usage: python3 -B find_counterparts.py SRC_TREE DST_TREE NAME ...   (from the repository root)"""
import bisect
import os
import sys

ROMS = os.path.expanduser('~/compartilhado/technics_roms/roms/kn5000')


def syms(t):
    out = {}
    for l in open('symbols/maincpu_%s_symbols_reference.txt' % t):
        p = l.split()
        if len(p) == 2 and not l.startswith('#'):
            out[p[0]] = int(p[1], 16)
    return out


def main():
    src, dst, names = sys.argv[1], sys.argv[2], sys.argv[3:]
    s, d = syms(src), syms(dst)
    srom = open(os.path.join(ROMS, 'kn5000_%s_program.rom' % src), 'rb').read()
    drom = open(os.path.join(ROMS, 'kn5000_%s_program.rom' % dst), 'rb').read()
    saddrs = sorted(set(s.values()))
    dlist = sorted((a, n) for n, a in d.items())
    dkeys = [a for a, n in dlist]
    for n in names:
        a = s[n]
        nxt = saddrs[bisect.bisect_right(saddrs, a)]
        ln = min(nxt - a, 48)
        off = a - 0xe00000
        hit = None
        for k in range(ln, 7, -1):
            pat = srom[off:off + k]
            i = drom.find(pat)
            if i >= 0 and drom.find(pat, i + 1) < 0:
                hit = (i + 0xe00000, k)
                break
        if not hit:
            print('%s: no unique hit (%d B available)' % (n, ln))
            continue
        ta = hit[0]
        j = bisect.bisect_right(dkeys, ta) - 1
        pa, pn = dlist[j]
        print('%s %s %06x -> %s %06x (%d B unique)  = %s + %d' % (n, src, a, dst, ta, hit[1], pn, ta - pa))


if __name__ == '__main__':
    main()
