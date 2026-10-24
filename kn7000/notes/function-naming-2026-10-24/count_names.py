#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""How many KN7000 program-941 routines are still func_<ADDR>, and where do the
names this naming pass added come from?

Run from the repository root, after `make -C kn7000 program-src`:

    python3 kn7000/notes/function-naming-2026-10-24/count_names.py [--rev REV]

Prints
  * the distinct func_<ADDR> routine labels the generated program source defines
    (kn7000/src/program/*.s, a line `func_XXXXXXXX:`), for the working tree and, with
    --rev, for that git revision too;
  * the names per evidence class: the sibling / IC18 matches by class
    (../sibling-name-port/accepted.tsv), the string / call-graph names
    (string-evidence.tsv) and the renames and moves of duplicate names (renames.tsv).
"""
import argparse
import collections
import csv
import glob
import os
import re
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
FUNC = re.compile(rb"^func_[0-9A-F]{8}:", re.M)


def count_tree():
    return len({m.group(0) for f in glob.glob("kn7000/src/program/*.s")
                for m in FUNC.finditer(open(f, "rb").read())})


def count_rev(rev):
    names = subprocess.run(["git", "ls-tree", "--name-only", rev, "kn7000/src/program/"],
                           capture_output=True, text=True, check=True).stdout.split()
    seen = set()
    for n in names:
        if n.endswith(".s"):
            data = subprocess.run(["git", "show", f"{rev}:{n}"], capture_output=True, check=True).stdout
            seen |= {m.group(0) for m in FUNC.finditer(data)}
    return len(seen)


def rows(path):
    with open(path, newline="") as f:
        return list(csv.DictReader(f, delimiter="\t"))


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--rev", help="also count func_ labels at this git revision")
    a = ap.parse_args()
    if a.rev:
        print(f"func_<ADDR> routine labels at {a.rev}: {count_rev(a.rev)}")
    print(f"func_<ADDR> routine labels in the working tree: {count_tree()}")
    acc = rows(os.path.join(HERE, "..", "sibling-name-port", "accepted.tsv"))
    by = collections.Counter((r["image"] if r["image"] == "IC18" else "sibling program", r["class"]) for r in acc)
    print(f"names carried by whole-routine match (tools/port_sibling_names.py): {len(acc)}")
    for (src, cls), n in sorted(by.items()):
        print(f"  {src:16s} {cls:9s} {n}")
    se = rows(os.path.join(HERE, "string-evidence.tsv"))
    print(f"names from strings, constants and the call graph (string-evidence.tsv): {len(se)}")
    for cls, n in sorted(collections.Counter(r["evidence_class"] for r in se).items()):
        print(f"  {n:3d}  {cls}")
    rn = rows(os.path.join(HERE, "renames.tsv"))
    print(f"duplicate or misplaced names fixed (renames.tsv): {len(rn)}")
    for cls, n in sorted(collections.Counter(r["evidence_class"] for r in rn).items()):
        print(f"  {n:3d}  {cls}")


if __name__ == "__main__":
    main()
