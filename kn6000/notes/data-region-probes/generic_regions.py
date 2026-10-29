#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""generic_regions.py -- where are the data region's remaining .incbin_range bytes?

QUESTION ANSWERED
  "Which stretches of the typed data region are still blobs, and how big is each?"  It reads
  the committed source only (src/program/data/data_*.s of a sibling tree), takes every
  .incbin_range piece, merges pieces less than 64 bytes apart into a region, and prints the
  regions by size with the two source lines before each (what precedes it).  This is the
  table "What is still generic" in ../data-region.md.

RUN (from the repository root)
    python3 kn6000/notes/data-region-probes/generic_regions.py kn6000 [N]
"""
import glob
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))


def main():
    model = sys.argv[1] if len(sys.argv) > 1 else "kn6000"
    top = int(sys.argv[2]) if len(sys.argv) > 2 else 40
    pieces = []
    for f in sorted(glob.glob(os.path.join(ROOT, model, "src", "program", "data", "data_*.s"))):
        prev = []
        for line in open(f, "rb"):
            m = re.match(rb'\.incbin_range "[^"]+", 0x([0-9A-Fa-f]+), 0x([0-9A-Fa-f]+)', line)
            if m:
                pieces.append((int(m.group(1), 16), int(m.group(2), 16),
                               b" | ".join(prev[-2:]).decode("latin-1")[:100]))
            if line.strip():
                prev.append(line.strip()[:50])
    regs = []
    for a, b, c in sorted(pieces):
        if regs and a - regs[-1][1] < 64:
            regs[-1][1] = b
            regs[-1][2] += b - a
        else:
            regs.append([a, b, b - a, c])
    regs.sort(key=lambda r: -r[2])
    print(f"{model}: {len(pieces)} pieces, {sum(b - a for a, b, _ in pieces)} bytes, {len(regs)} regions")
    for a, b, n, c in regs[:top]:
        print(f"0x{a:06X}-0x{b:06X} {n:8d} blob bytes  {c}")


if __name__ == "__main__":
    main()
