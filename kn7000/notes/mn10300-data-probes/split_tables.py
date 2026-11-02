#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""split_tables.py -- which tables does a reader index past a label (one table written as two)?

QUESTION IT ANSWERS
  "For a gen_data_s.py profile, which tables does a routine index with an index it bounds just before
   (gen_data_s.Gen.index_bounds(): `and 2^k - 1`, `cmp N` + branch, a clamp, a counted setlb loop), and
   for which of them does that extent run past another label the data sources define (a name the code or a
   symbol file gives, or a generated one) -- a table the sources may still split in two (open item
   N-44fb32d4)?"  Lists per table: its label, entries x stride, the routine and instructions, and the labels
   inside its extent (the code-named ones, which keep it split, marked `fixed`).

HOW
  Builds gen_data_s.Gen for the profile (no generation: the model, the labels and the code only), takes
  index_bounds() and the labels of the previous generation (labels.sym) and of the code (`fixed`).

RUN (from the repository root; a KN7000 profile needs kn7000/build/*.labels)
  python3 kn7000/notes/mn10300-data-probes/split_tables.py --profile kn6000
"""
import argparse
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.normpath(os.path.join(HERE, "..", "..", "tools")))
import gen_data_s as G  # noqa: E402


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--profile", required=True)
    a = ap.parse_args()
    os.chdir(G.KN7_DIR)
    G.configure(a.profile)
    g = G.Gen()
    ix = g.index_bounds()
    by_addr = {}
    for n, adr in g.prev_data_label.items():
        by_addr.setdefault(adr, n)
    name = {adr: n for n, adr in g.prev_data_label.items()}
    cross = 0
    for t, (cnt, st, cite) in sorted(ix.items()):
        inside = sorted(x for x in by_addr if t < x < t + cnt * st)
        if not inside:
            continue
        cross += 1
        fixed = [x for x in inside if x in g.fixed]
        print(f"0x{t:08X} {name.get(t, '?')}: {cnt} x {st} bytes ({cite}); labels inside: "
              + ", ".join(f"{by_addr[x]}{' (fixed)' if x in fixed else ''} +{x - t}" for x in inside[:6])
              + (" ..." if len(inside) > 6 else ""))
    print(f"{a.profile}: {len(ix)} tables indexed with a bounded index, {cross} with a label inside their extent")
    return 0


if __name__ == "__main__":
    sys.exit(main())
