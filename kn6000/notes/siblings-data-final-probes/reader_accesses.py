#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""reader_accesses.py -- what the reader walk (kn7000/tools/data_readers.py) sees at one data address.

QUESTION IT ANSWERS
  "Which instructions of <model>'s converted code read, write, pass or index the data at ADDR
   (as a fixed address, a record array based there, or a pointer field of one), at which field
   offset and width?"  This is the evidence behind each field name in
   kn7000/tools/data_struct_names.py MODEL_NAMES (and the reader search behind an opaque marker).

RUN (from the repository root; the model's committed sources are enough):
  python3 kn6000/notes/siblings-data-final-probes/reader_accesses.py kn6000 0x4C3DF8EC
  model: kn6000, kn6500, kn2400, hdsx3 (or a KN7000 profile: 941 ...).
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
TOOLS = os.path.normpath(os.path.join(HERE, "..", "..", "..", "kn7000", "tools"))
sys.path.insert(0, TOOLS)
import gen_data_s as G  # noqa: E402
import data_structs as DS  # noqa: E402


def main():
    model, addr = sys.argv[1], int(sys.argv[2], 0)
    os.chdir(G.KN7)
    G.configure(model)
    g = G.Gen()
    dr = DS.readers(g, g.code_labels, G.code_glob())
    rows = set()
    for a in dr.accesses:
        if str(addr) in repr(a.key):
            rows.add((repr(a.key), a.off, a.width, a.rw, a.func or "", a.cpu or 0, " ".join(a.insn.split())))
    for k, off, w, rw, fn, cpu, insn in sorted(rows, key=lambda r: (r[0], r[1], r[5])):
        print(f"{k}  +{off} w{w} {rw:6s} {fn} 0x{cpu:08X}  `{insn}`")


if __name__ == "__main__":
    main()
