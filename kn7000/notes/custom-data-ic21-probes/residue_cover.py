#!/usr/bin/env python3
"""residue_cover.py -- how much of the residue in the KN7000 custom banks can be typed?

Question: the bytes past a record's end and in free blocks are left over from earlier writes.
How many of them repeat a typed record (any record of the nine sets, at the same record-relative
offset or at any offset, 32-byte matches or longer), how many more are whole event streams,
variation or pad records, or runs of events, and how many match nothing and do not parse?
It runs the generator (kn7000/tools/gen_customdata_s.py) on each image into a scratch directory
and prints the generator's per-image tally.

Usage (from kn7000/): python3 -I notes/custom-data-ic21-probes/residue_cover.py baserom/customdata/*.ic21
"""
import os
import subprocess
import sys
import tempfile

here = os.path.dirname(os.path.abspath(__file__))
tool = os.path.join(here, "..", "..", "tools", "gen_customdata_s.py")
imgs = sys.argv[1:]
corpus = [f"{os.path.basename(p)[:-5]}={p}" for p in imgs]
with tempfile.TemporaryDirectory() as tmp:
    for p in imgs:
        n = os.path.basename(p)[:-5]
        out = subprocess.run([sys.executable, "-I", tool, "--rom", p, "--ref", p, "--out", os.path.join(tmp, n + ".s"),
                              "--model", "kn7000", "--include", "x.inc", "--corpus", *corpus],
                             capture_output=True, text=True, check=True).stdout
        print(n, out.split("residue bytes ", 1)[1].strip())
