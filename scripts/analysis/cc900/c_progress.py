#!/usr/bin/env python3
"""Record one point of the firmware-C progress: how many ROM bytes our C reproduces through Toshiba V4.23, both
built into the images and confirmed but still staged on the C lane's branch.

QUESTION ANSWERED: after the latest V4.23 run, how much firmware C does V4.23 confirm, in the build and waiting to be
built?  The owner asked (2026-11-16) for the dashboard to get a new point every time new scores exist, even when
they do not change; staged C is otherwise invisible until it is merged.

usage: python3 scripts/analysis/cc900/c_progress.py record RUN [--branch BRANCH]
    RUN     the V4.23 run that produced the new scores (a name under ~/compartilhado/cc900-oracle/runs/), or "-"
    BRANCH  the lane branch holding the staged C (default phase6/first-functions)

It appends one row to results/c_progress.tsv (beside this script, in results/):
    time       when the row was recorded (local time, ISO 8601)
    run        RUN
    built_fn   firmware C functions built into the images that V4.23 reproduces, over all six main-CPU images
               (results/c_build_coverage.md, rows "firmware C", V4.23 MATCH; v8 counts on its own, with v9's C)
    built_b    their bytes
    staged_fn  functions in BRANCH's notes/cc900-phase6-2026-11-16/staged_v423.tsv whose latest check is MATCH and
               which are not built yet, counted per image the same way (v9's staged C counts for v8 too); also
               the sub-CPU and HD-AE5000 lanes' tables (OTHER_LANES)
    staged_b   their bytes
    v10_fn / v10_b   the same two totals (built + staged) for v10 alone
The dashboard (dashboard.py) charts this file.  Nothing here reads a Toshiba listing; the figures come from the two
tables the build and the C lane already record.
"""
import datetime
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
COVERAGE = os.path.join(HERE, "results", "c_build_coverage.md")
OUT = os.path.join(HERE, "results", "c_progress.tsv")
STAGED = "notes/cc900-phase6-2026-11-16/staged_v423.tsv"
HEADER = "time\trun\tbuilt_fn\tbuilt_b\tstaged_fn\tstaged_b\tv10_fn\tv10_b\n"
IMAGES_OF_TREE = {"v10": ["v10"], "v9": ["v9", "v8"], "v7": ["v7"], "v6": ["v6"], "v5": ["v5"]}
# staged-results tables of the other C lanes, same columns as staged_v423.tsv; a missing branch or file counts nothing
OTHER_LANES = [("cc900/c-subcpu-hdae", "notes/cc900-c-subcpu-2026-11-16/staged_v423.tsv"),
               ("cc900/c-hdae5000", "notes/cc900-c-hdae5000-2026-11-16/staged_v423.tsv")]


def built():
    """{(image, function): bytes} for the firmware C functions V4.23 reproduces in the build"""
    out = {}
    for line in open(COVERAGE, encoding="utf-8"):
        f = [c.strip() for c in line.strip().strip("|").split("|")]
        # the per-function table: image | function | C file | options | bytes | built | model | V4.23 | V4.23 run
        if len(f) == 9 and re.fullmatch(r"v\d+", f[0]) and f[5] == "yes" and f[7].startswith("MATCH"):
            out[(f[0], f[1])] = int(f[4])
    return out


def staged(branch, path=STAGED):
    """{(image, function): bytes} for staged functions whose latest V4.23 check is MATCH"""
    try:
        text = subprocess.run(["git", "-C", REPO, "show", "%s:%s" % (branch, path)], check=True,
                              capture_output=True, text=True).stdout
    except subprocess.CalledProcessError:
        return {}
    latest = {}
    for line in text.splitlines():
        if line.startswith("#") or line.startswith("tree\t"):
            continue
        f = line.split("\t")
        if len(f) < 8:
            continue
        tree, fn, size, result = f[0], f[5], f[6], f[7]
        latest[(tree, fn)] = (int(size), result)     # later rows are later checks
    out = {}
    for (tree, fn), (size, result) in latest.items():
        if result == "MATCH":
            for img in IMAGES_OF_TREE.get(tree, [tree]):
                out[(img, fn)] = size
    return out


def record(run, branch):
    b = built()
    st = staged(branch)
    for br, path in OTHER_LANES:          # the other images' C lanes (2026-11-16): their staged C counts too
        st.update(staged(br, path))
    s = {k: v for k, v in st.items() if k not in b}
    v10 = [v for (img, _), v in list(b.items()) + list(s.items()) if img == "v10"]
    row = [datetime.datetime.now().strftime("%Y-%m-%dT%H:%M:%S"), run, len(b), sum(b.values()), len(s),
           sum(s.values()), len(v10), sum(v10)]
    new = not os.path.exists(OUT)
    with open(OUT, "a", encoding="utf-8") as fh:
        if new:
            fh.write(HEADER)
        fh.write("\t".join(str(x) for x in row) + "\n")
    print("c_progress: built %d functions / %d B, staged %d / %d B; v10 %d / %d B" % tuple(row[2:]))


def main():
    a = sys.argv[1:]
    if len(a) < 2 or a[0] != "record":
        sys.exit(__doc__)
    branch = "phase6/first-functions"
    if "--branch" in a:
        branch = a[a.index("--branch") + 1]
    record(a[1], branch)


if __name__ == "__main__":
    main()
