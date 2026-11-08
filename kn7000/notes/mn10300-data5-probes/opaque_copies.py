#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""opaque_copies.py -- which census-opaque pieces are byte-identical copies of bytes elsewhere in the image?

QUESTION IT ANSWERS
  "Of a tree's `census: opaque -- unknown-dump` pieces (the `.incbin_range` after each census line), which
   are, whole or from their start, an exact copy of bytes at another place of the same reference image, and
   where is that place (its label in the tree's labels.sym)?"  A copy of a typed table is typed by what the
   original is (gen_data_s.py `dup_spans`, lane mn10300-data5); a piece found nowhere else is not.

  Only pieces of >= MIN bytes (default 32) with >= 8 distinct byte values are looked at (fill is not a copy).
  The longest common prefix with any other place is reported; `whole` = the full piece.

RUN (from the repository root)
  python3 -I kn7000/notes/mn10300-data5-probes/opaque_copies.py [--min N] [TREE ...]
  TREE is one of 941 942 935 893 kn6000 kn6500 kn2400 hdsx3 (default all), or DIR=ROM for another directory.
"""
import bisect
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
TREES = {"941": ("kn7000/src/program/data", "kn7000"), "942": ("kn7000/src/sp7001/program/data", "kn7000"),
         "935": ("kn7000/src/b935/program/data", "kn7000"), "893": ("kn7000/src/b893/program/data", "kn7000"),
         "kn6000": ("kn6000/src/program/data", "kn6000"), "kn6500": ("kn6500/src/program/data", "kn6500"),
         "kn2400": ("kn2400/src/program/data", "kn2400"), "hdsx3": ("hdsx3/src/program/data", "hdsx3")}


def pieces(ddir):
    for f in sorted(os.listdir(ddir)):
        if not re.fullmatch(r"data_\d+\.s", f):
            continue
        L = open(os.path.join(ddir, f), "rb").read().split(b"\n")
        for i, ln in enumerate(L[:-1]):
            if ln.startswith(b"# census: opaque -- unknown-dump"):
                m = re.match(rb'\.incbin_range "([^"]+)", (0x[0-9A-Fa-f]+), (0x[0-9A-Fa-f]+)', L[i + 1])
                if m:
                    yield m.group(1).decode(), int(m.group(2), 16), int(m.group(3), 16)


def labels(ddir):
    out = []
    p = os.path.join(ddir, "labels.sym")
    for ln in open(p, encoding="latin-1"):
        m = re.match(r"0x([0-9A-F]+)\s+(\S+)", ln)
        if m:
            out.append((int(m.group(1), 16), m.group(2)))
    out.sort()
    return out


def main(argv):
    mn = 32
    if "--min" in argv:
        i = argv.index("--min")
        mn = int(argv[i + 1])
        del argv[i:i + 2]
    trees = argv or list(TREES)
    for t in trees:
        ddir, root = TREES[t]
        ddir = os.path.join(REPO, ddir)
        labs = labels(ddir)
        addrs = [a for a, _n in labs]
        rows = []
        tot = 0
        for ref, s, e in pieces(ddir):
            rom = open(os.path.join(REPO, root, ref), "rb").read()
            bs = rom[s:e]
            if len(bs) < mn or len(set(bs)) < 8:
                continue
            best, at = 0, None
            j = rom.find(bs[:16])
            while j != -1:
                if j != s:
                    n = 0
                    while n < len(bs) and j + n < len(rom) and rom[j + n] == bs[n] and not (s <= j + n < e):
                        n += 1
                    if n > best:
                        best, at = n, j
                j = rom.find(bs[:16], j + 1)
            if best >= mn:
                base = labs[0][0] - 0 if labs else 0
                # labels.sym holds CPU addresses: the image's base is the first label's high bits
                hi = labs[0][0] & 0xFF000000 if labs else 0
                k = bisect.bisect_right(addrs, hi + at) - 1
                where = f"{labs[k][1]}+{hi + at - labs[k][0]}" if k >= 0 else hex(at)
                rows.append((s, e - s, best, at, where))
                tot += best
        print(f"== {t}: {len(rows)} opaque pieces are copies of other bytes ({tot:,} bytes)")
        for s, n, b, at, where in rows:
            print(f"  0x{s:06X} {n:5d} B: {'whole' if b == n else f'first {b} B'} = 0x{at:06X} ({where})")


if __name__ == "__main__":
    main(sys.argv[1:])
