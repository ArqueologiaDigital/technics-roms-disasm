#!/usr/bin/env python3
r"""subcpu_v141_v142_alignment.py -- how do sub-CPU payloads v1.41 and v1.42 line up?

QUESTION THIS ANSWERS
    The raw byte diff of the two 196,608-byte payload images is 124,033 bytes in 2,875 runs.
    How much of that is genuine change, and where are the insertions / deletions that make
    the rest of it ripple?

METHOD
    Both images are placed at their run-time addresses (file 0..255 -> 0x000400, file 256..
    -> 0x00F000).  A patience-style aligner anchors on k-grams that are unique in both
    images (k = 32, 16, 8, 6), keeps the longest increasing chain of anchors, grows each
    anchor into a maximal equal block, and recurses into the gaps.  It reports
      * the raw position-for-position diff (the issue's figure),
      * the bytes covered by equal blocks, grouped by shift (v1.41 address - v1.42 address),
      * the gaps whose two sides differ in LENGTH (insertions / deletions -- the only places
        where the shift can change), and the count of equal-length gaps (which are where
        an absolute address operand differs by the shift).
    An equal-length gap is not proof of "only an address": that is what the byte-exact
    v141 build proves (scripts/generators/create_v141_subcpu_source.py + make gate).

RUN
    python3 scripts/analysis/subcpu_v141_v142_alignment.py
    python3 scripts/analysis/subcpu_v141_v142_alignment.py OLD.rom NEW.rom   # any two payloads,
        e.g. original_ROMs/kn5000_subprogram_v141.rom original_ROMs/kn5000_subprogram_v140.rom
    (the first image is the reference, "v1.42" in the output; the second is "v1.41")
"""
import bisect
import os
import sys
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
V142 = os.path.join(ROOT, "original_ROMs/kn5000_subprogram_v142.rom")
V141 = os.path.join(ROOT, "original_ROMs/kn5000_subprogram_v141.rom")
BASE, HI_START, END = 0x400, 0xF000, 0x3EF00


def to_mem(rom):
    img = bytearray(b"\xff" * (END - BASE))
    img[0:256] = rom[0:256]
    t = rom[256:]
    img[HI_START - BASE:HI_START - BASE + len(t)] = t
    return bytes(img[:END - BASE])


def lis(pairs):
    tails, tail_idx, prev = [], [], [None] * len(pairs)
    for i, (_, y) in enumerate(pairs):
        j = bisect.bisect_left(tails, y)
        if j == len(tails):
            tails.append(y)
            tail_idx.append(i)
        else:
            tails[j] = y
            tail_idx[j] = i
        prev[i] = tail_idx[j - 1] if j else None
    out, i = [], (tail_idx[-1] if tail_idx else None)
    while i is not None:
        out.append(pairs[i])
        i = prev[i]
    return out[::-1]


def align(a, b, a0, a1, b0, b1, ks, out):
    if a0 >= a1 or b0 >= b1:
        return
    for k in ks:
        if a1 - a0 < k or b1 - b0 < k:
            continue
        ca, cb = {}, {}
        for i in range(a0, a1 - k + 1):
            g = a[i:i + k]
            ca[g] = -1 if g in ca else i
        for i in range(b0, b1 - k + 1):
            g = b[i:i + k]
            cb[g] = -1 if g in cb else i
        pairs = sorted((ia, cb[g]) for g, ia in ca.items() if ia >= 0 and cb.get(g, -1) >= 0)
        if not pairs:
            continue
        blocks, pa, pb = [], a0, b0
        for x, y in lis(pairs):
            if x < pa or y < pb:
                continue
            while x > pa and y > pb and a[x - 1] == b[y - 1]:
                x, y = x - 1, y - 1
            ex, ey = x, y
            while ex < a1 and ey < b1 and a[ex] == b[ey]:
                ex, ey = ex + 1, ey + 1
            blocks.append((x, y, ex - x))
            pa, pb = ex, ey
        smaller = [kk for kk in ks if kk < k]
        pa, pb = a0, b0
        for x, y, n in blocks:
            align(a, b, pa, x, pb, y, smaller, out)
            out.append((x, y, n))
            pa, pb = x + n, y + n
        align(a, b, pa, a1, pb, b1, smaller, out)
        return


def main():
    ref, new = (sys.argv[1], sys.argv[2]) if len(sys.argv) == 3 else (V142, V141)
    print("reference %s\nother     %s" % (os.path.relpath(ref, ROOT), os.path.relpath(new, ROOT)))
    r142, r141 = open(ref, "rb").read(), open(new, "rb").read()
    raw = [i for i in range(len(r142)) if r142[i] != r141[i]]
    runs = sum(1 for j, i in enumerate(raw) if j == 0 or raw[j - 1] != i - 1)
    print("raw position-for-position diff: %d bytes in %d runs (of %d)" % (len(raw), runs, len(r142)))

    a, b = to_mem(r142), to_mem(r141)
    sys.setrecursionlimit(100000)
    blocks = []
    align(a, b, 0, len(a), 0, len(b), [32, 16, 8, 6], blocks)
    blocks.sort()
    shift = Counter()
    for x, y, n in blocks:
        shift[y - x] += n
    print("aligned: %d equal blocks covering %d of %d bytes" % (len(blocks), sum(shift.values()), len(a)))
    for d, n in shift.most_common():
        print("  shift %+#06x : %7d bytes" % (d, n))
    gaps, pa, pb = [], 0, 0
    for x, y, n in blocks + [(len(a), len(b), 0)]:
        if x > pa or y > pb:
            gaps.append((pa, x - pa, pb, y - pb))
        pa, pb = x + n, y + n
    uneq = [g for g in gaps if g[1] != g[3]]
    print("gaps: %d, of which equal-length %d, length-changing %d:" % (len(gaps), len(gaps) - len(uneq), len(uneq)))
    for ga, la, gb, lb in uneq:
        print("  v1.42 0x%06x +%-3d  <->  v1.41 0x%06x +%-3d  (net %+d)" % (ga + BASE, la, gb + BASE, lb, lb - la))


if __name__ == "__main__":
    main()
