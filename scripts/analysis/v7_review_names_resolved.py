#!/usr/bin/env python3
r"""How many of the header-propagation review's missing-name rows does v7 now resolve?

QUESTION ANSWERED
    analysis/header-propagation/review-2026-10-24.tsv lists, for v7, the v10 labels v7 did not define
    (`label-absent`) and the v10 headers that name a symbol v7 did not define (`names-absent-symbol`, the
    names in `detail`).  After a harmonizing rename pass (scripts/renaming/harmonize_by_caller_alignment.py)
    this counts how many of those names the current v7 build defines, from the linked ELF (run `make all`
    first).

    The review list is regenerated whenever propagate_v10_headers.py --apply runs, and a regenerated list
    only holds the names that are still missing, so measuring against the working-tree copy after such a
    run always prints "defined now 0".  The list is therefore read from a git revision, by default
    79e035417 (the review as it stood before lane v7-harmonize of wave 2 renamed anything); pass
    --tsv-rev worktree to read the working-tree file instead.

RUN
    python3 scripts/analysis/v7_review_names_resolved.py [--target v7] [--tsv-rev REV|worktree] [--list]
"""
import argparse
import csv
import io
import os
import subprocess

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
TSV_REL = "analysis/header-propagation/review-2026-10-24.tsv"
PRE_LANE_REV = "79e035417"


def read_tsv(rev):
    if rev == "worktree":
        with open(os.path.join(REPO, TSV_REL), newline="") as fh:
            return fh.read()
    return subprocess.run(["git", "-C", REPO, "show", "%s:%s" % (rev, TSV_REL)], capture_output=True,
                          text=True, check=True).stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--target", default="v7", choices=("v7", "v9"))
    ap.add_argument("--tsv-rev", default=PRE_LANE_REV,
                    help="git revision to read the review list from, or 'worktree' (default %(default)s)")
    ap.add_argument("--list", action="store_true", help="print the names still missing")
    a = ap.parse_args()
    out = subprocess.run([NM, "--defined-only", os.path.join(REPO, "rebuilt_ROMs",
                          "kn5000_%s_program.llvm.elf" % a.target)], capture_output=True, text=True,
                         check=True).stdout
    have = {l.split()[2] for l in out.splitlines() if len(l.split()) == 3}
    absent, named = set(), set()
    rows_named, rows_named_ok = 0, 0
    print("review list: %s at %s" % (TSV_REL, a.tsv_rev))
    for r in csv.DictReader(io.StringIO(read_tsv(a.tsv_rev)), delimiter="\t"):
        if r["target"] != a.target:
            continue
        if r["reason"] == "label-absent":
            absent.add(r["label"])
        elif r["reason"] == "names-absent-symbol":
            ns = r["detail"].split()
            named.update(ns)
            rows_named += 1
            rows_named_ok += all(n in have for n in ns)
    print("%s label-absent labels:            %4d, defined now %4d" % (a.target, len(absent), len(absent & have)))
    print("%s names-absent-symbol names:      %4d, defined now %4d" % (a.target, len(named), len(named & have)))
    print("%s names-absent-symbol rows:       %4d, every name defined now %4d" % (a.target, rows_named, rows_named_ok))
    if a.list:
        for n in sorted((absent | named) - have):
            print("  missing", n)


if __name__ == "__main__":
    main()
