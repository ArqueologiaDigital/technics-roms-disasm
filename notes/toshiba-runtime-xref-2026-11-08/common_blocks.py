#!/usr/bin/env python3
"""Exact byte blocks (>= --min, default 24) shared by a tool binary and our images, fill excluded.

usage: python3 -I common_blocks.py [--min N] FILE...
Every 16-byte window of each FILE with >= 8 distinct byte values is indexed (counting sequences such as
00 00 00 01 00 02 ... are dropped: their byte or 16-bit-word steps are constant); each image segment
(xref_runtime.IMAGES) is scanned, and each seed is extended both ways while the bytes agree.  Prints
file, file offset, image, address, length and our label for each maximal block of at least --min bytes.
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import xref_runtime as X

def counting(w):
    for step in (1, 2):
        v = [int.from_bytes(w[i:i + step], 'big') for i in range(0, len(w) - step + 1, step)]
        d = {(v[i + 1] - v[i]) % (1 << (8 * step)) for i in range(len(v) - 1)}
        if len(d) == 1: return True
        v = [int.from_bytes(w[i:i + step], 'little') for i in range(0, len(w) - step + 1, step)]
        d = {(v[i + 1] - v[i]) % (1 << (8 * step)) for i in range(len(v) - 1)}
        if len(d) == 1: return True
    return any(counting(w[k:]) for k in (1,)) if len(w) == 16 else False

def main():
    a = sys.argv[1:]; mn = 24
    if a and a[0] == '--min': mn = int(a[1]); a = a[2:]
    for fn in a:
        f = open(fn, 'rb').read(); idx = {}
        for i in range(len(f) - 16):
            w = f[i:i + 16]
            if len(set(w)) >= 8 and not counting(w): idx.setdefault(w, i)
        for iname, img, elf in X.IMAGES:
            syms = X.symbols(elf); addrs = sorted(syms)
            for va, d in X.segments(elf):
                p = 0; seen = set()
                while p < len(d) - 16:
                    i = idx.get(d[p:p + 16])
                    if i is None: p += 1; continue
                    s, t = p, i
                    while s > 0 and t > 0 and d[s - 1] == f[t - 1]: s -= 1; t -= 1
                    e, u = p + 16, i + 16
                    while e < len(d) and u < len(f) and d[e] == f[u]: e += 1; u += 1
                    if e - s >= mn and (s, t) not in seen:
                        seen.add((s, t))
                        print('%s\t%06x\t%s\t%06x\t%d\t%s' % (os.path.basename(fn), t, iname, va + s, e - s, X.label(syms, addrs, va + s)))
                    p = e
    return 0

main()
