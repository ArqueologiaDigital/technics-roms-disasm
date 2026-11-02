#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""array_counts.py -- where does each struct array's record count come from?

QUESTION IT ANSWERS
  "For a tree's generated data_structs.inc (committed, or a generator run's directory), which record arrays
   have a count a reader proves -- a pointer loop's end compare (array_end: `ends at +N, where ... loop
   stops`), an index the routine bounds just before it uses it (index_bounds: `the index is bounded by`) --
   which are capped by an index bound the readers check, and which are an inference (where the records
   stop being free, a pointer field stops holding an address, another named address begins: `[INFERENCE]
   the count`)?  How many of each, and which are the inferred ones?"  (Open item N-92b0bf4c.)

HOW
  Reads the `# REC_x: N-byte records (Label, K records); ...` macro headers of data_structs.inc and the
  `#   (...)` evidence line after each, as gen_data_s.py writes them (its struct_arrays(): loop_end,
  index_bounds, count_notes).  Arrays without an evidence line are the ones other passes write (a
  callee's argument block, a record a pointer field leads to): their count is the pass's own.

RUN (from the repository root)
  python3 -I kn7000/notes/mn10300-data-probes/array_counts.py kn7000/src/program/data
  python3 -I kn7000/notes/mn10300-data-probes/array_counts.py DIR/941_on --list inferred
"""
import argparse
import collections
import os
import re
import sys


def classify(ddir):
    out = []
    lines = open(os.path.join(ddir, "data_structs.inc"), encoding="latin-1").read().split("\n")
    for i, ln in enumerate(lines):
        m = re.match(r"# (\w+): (\d+)-byte records \((\S+), (\d+) records\)", ln)
        if not m:
            continue
        ev = lines[i + 1] if i + 1 < len(lines) else ""
        if "loop stops" in ev:
            k = "loop end"
        elif "the index is bounded by" in ev:
            k = "index bound"
        elif "capped by an index bound" in ev:
            k = "capped"
        elif "[INFERENCE] the count" in ev:
            k = "inferred"
        else:
            k = "other pass"
        out.append((k, m.group(3), int(m.group(4)), int(m.group(2))))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("dir")
    ap.add_argument("--list", choices=("loop end", "index bound", "capped", "inferred", "other pass"))
    a = ap.parse_args()
    rows = classify(a.dir)
    c = collections.Counter(k for k, *_ in rows)
    print(f"{a.dir}: {len(rows)} record arrays: " + ", ".join(f"{k} {c[k]}" for k in
                                                            ("loop end", "index bound", "capped", "inferred", "other pass")))
    if a.list:
        for k, lab, n, s in rows:
            if k == a.list:
                print(f"  {lab}  {n} x {s} bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
