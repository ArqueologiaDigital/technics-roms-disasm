#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""frozen_names_check.py -- are the frozen GUI object names the ones the data sources use?

QUESTION ANSWERED (N-fb88572c): "for each tree's gui_object_names.tsv (gen_data_s.py frozen_object_names /
object_names_tsv: object id, class, name of every GUI object with an empty ResName), is every name unique,
does labels.sym define it (the data source labels the object with it), and how many rows are there?"
A regeneration reads the map before it names anything, so a row's name is the object's label for as long
as the object keeps its id and class; this checks the committed map and sources agree.  Exit 1 on a
duplicate or a name labels.sym lacks.

RUN (from the repository root):  python3 kn7000/notes/mn10300-data3-probes/frozen_names_check.py
"""
import collections
import os
import sys

REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
TREES = [("941", "kn7000/src/program/data"), ("942", "kn7000/src/sp7001/program/data"),
         ("935", "kn7000/src/b935/program/data"), ("893", "kn7000/src/b893/program/data"),
         ("kn6000", "kn6000/src/program/data"), ("kn6500", "kn6500/src/program/data"),
         ("kn2400", "kn2400/src/program/data"), ("hdsx3", "hdsx3/src/program/data")]


def main():
    bad = 0
    print("| tree   | rows  | classes | names labels.sym lacks | duplicate names |")
    print("|--------|-------|---------|------------------------|-----------------|")
    for t, d in TREES:
        tsv = os.path.join(REPO, d, "gui_object_names.tsv")
        if not os.path.exists(tsv):
            print(f"| {t:<6} | none  |         |                        |                 |")
            continue
        labels = set()
        for ln in open(os.path.join(REPO, d, "labels.sym"), encoding="latin-1"):
            if not ln.startswith(";"):
                labels.add(ln.split()[1])
        rows = [ln.rstrip("\n").split("\t") for ln in open(tsv, encoding="latin-1") if ln.strip() and not ln.startswith("#")]
        names = collections.Counter(r[2] for r in rows)
        missing = sum(1 for r in rows if r[2] not in labels)
        dup = sum(1 for n, c in names.items() if c > 1)
        bad += missing + dup
        print(f"| {t:<6} | {len(rows):<5} | {len({r[1] for r in rows}):<7} | {missing:<22} | {dup:<15} |")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
