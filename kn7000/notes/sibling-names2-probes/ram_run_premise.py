#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "is the premise of port_names_by_alignment.py's RAM runs true: when a voted RAM
# pair's two neighbours (in B's order) have one delta B - A, does it have that delta too,
# and does the answer change with how far apart the neighbours are?"
# Reads <model>/notes/ram-map-kn7000.tsv; only the voted rows (aligned operands > 0) count,
# not the rows the runs added (0).  Run from the repo root:
#     python3 -I kn7000/notes/sibling-names2-probes/ram_run_premise.py kn6000 kn6500 kn2400
import sys

for m in sys.argv[1:]:
    seq = []
    for ln in open(f"{m}/notes/ram-map-kn7000.tsv"):
        if ln.startswith("0x"):
            f = ln.split("\t")
            if int(f[2]) > 0:
                seq.append((int(f[0], 16), int(f[1], 16)))
    seq.sort()
    out = []
    for gap in (0x40, 0x100, 0x400, 0x1000, 0x4000, 0x10000):
        ok = bad = 0
        for (b0, a0), (b1, a1), (b2, a2) in zip(seq, seq[1:], seq[2:]):
            if b0 - a0 == b2 - a2 and b2 - b0 <= gap:
                if b1 - a1 == b0 - a0:
                    ok += 1
                else:
                    bad += 1
        out.append(f"gap {gap:#x}: {ok} right / {bad} wrong")
    print(f"{m} ({len(seq)} voted pairs): " + "; ".join(out))
    for (b0, a0), (b1, a1), (b2, a2) in zip(seq, seq[1:], seq[2:]):
        if b0 - a0 == b2 - a2 and b2 - b0 <= 0x10000 and b1 - a1 != b0 - a0:
            print(f"  exception: B 0x{b1:08X} / A 0x{a1:08X} delta {b1 - a1:+#x}, neighbours {b0 - a0:+#x}")
