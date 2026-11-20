#!/usr/bin/env python3
"""Where are a source tree's labelled routines in another tree's ROM?  For each NAME the bytes at its source-tree
address (up to the next symbol, at most 48) are searched in the target ROM; the longest unique prefix (>= 8 B) wins.
Prints the target address and the nearest preceding target symbol + offset.  When no prefix is unique (address
operands differ between the builds), unique runs of >= 8 B inside the routine vote for a start; two agreeing runs
decide.

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
            # fallback (address operands differ between builds): unique runs of >= 8 B INSIDE the routine, each
            # projected back to a start address; accepted when at least two non-overlapping runs agree
            votes = {}
            o = 0
            while o + 8 <= ln:
                for k in range(ln - o, 7, -1):
                    pat = srom[off + o:off + o + k]
                    i = drom.find(pat)
                    if i >= 0 and drom.find(pat, i + 1) < 0:
                        votes.setdefault(i - o + 0xe00000, []).append((o, k))
                        o += k
                        break
                else:
                    o += 1
            good = [(a2, v) for a2, v in votes.items() if len(v) >= 2]
            if len(good) == 1:
                ta = good[0][0]
                j = bisect.bisect_right(dkeys, ta) - 1
                pa, pn = dlist[j]
                print('%s %s %06x -> %s %06x (runs %s agree)  = %s + %d' % (
                    n, src, a, dst, ta, ' '.join('+%d:%d' % x for x in good[0][1]), pn, ta - pa))
            else:
                print('%s: no unique hit (%d B available; %d candidate starts)' % (n, ln, len(good)))
            continue
        ta = hit[0]
        j = bisect.bisect_right(dkeys, ta) - 1
        pa, pn = dlist[j]
        print('%s %s %06x -> %s %06x (%d B unique)  = %s + %d' % (n, src, a, dst, ta, hit[1], pn, ta - pa))


if __name__ == '__main__':
    main()
