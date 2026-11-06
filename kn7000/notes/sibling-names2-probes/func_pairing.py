#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Question: "of a sibling's routine starts that are still func_<ADDR>, how many pair with a
# KN7000 941 routine (notes/routine-map-kn7000.tsv, where 941 leaves the routine unnamed too),
# and where in the image are the ones with no partner?"  Reads <model>/src/labels.inc (the
# func_<ADDR> .equ rows) and <model>/notes/routine-map-kn7000.tsv.  Run from the repo root:
#     python3 -I kn7000/notes/sibling-names2-probes/func_pairing.py kn6000 kn6500 kn2400
import collections
import re
import sys

for m in sys.argv[1:]:
    starts = {int(v, 16) for _n, v in re.findall(r"^\.equ\s+(func_[0-9A-F]{8}),\s*0x([0-9a-fA-F]+)",
                                                 open(f"{m}/src/labels.inc").read(), re.M)}
    rmap = {int(ln.split("\t")[0], 16) for ln in open(f"{m}/notes/routine-map-kn7000.tsv") if ln.startswith("0x")}
    paired = sum(1 for s in starts if s in rmap)
    h = collections.Counter(s >> 16 for s in starts if s not in rmap)
    top = ", ".join(f"0x{k:04X}xxxx {n}" for k, n in h.most_common(8))
    print(f"{m}: {len(starts)} func_ starts, {paired} paired with an unnamed 941 routine, "
          f"{len(starts) - paired} without; most of those in {top}")
