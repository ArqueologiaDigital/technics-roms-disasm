#!/usr/bin/env python3
"""promoted_bytes.py RUN [RUN ...] -- how many functions and ROM bytes did a promotion move into the build, per tree?

QUESTION ANSWERED: for the per-tree checks of the given oracle runs (staged_v423.tsv rows with result MATCH), which
functions are now built from C (the tree's hand source has the label on an `.include "includes/generated/cc900/`
line, ready_check.labels) and how many bytes they are.  One line per tree; v8 is v9's source and is not repeated.

usage: python3 -B notes/cc900-phase6-2026-11-16/promoted_bytes.py 2026-11-18-12-p6-r35      (from the repository root)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import ready_check                                           # noqa: E402


def main():
    runs = set(sys.argv[1:])
    if not runs:
        sys.exit(__doc__)
    rows = {}
    for line in open(os.path.join(HERE, 'staged_v423.tsv')):
        c = line.rstrip('\n').split('\t')
        if len(c) >= 8 and c[4] in runs and c[7] == 'MATCH':
            rows.setdefault(c[0], {})[c[5]] = int(c[6])
    total = 0
    for t in ('v10', 'v9', 'v7', 'v6', 'v5'):
        lab = ready_check.labels(t)
        got = {f: b for f, b in rows.get(t, {}).items() if lab.get(f)}
        total += sum(got.values())
        print('%-4s %3d functions %6d B built from C (of %d checked MATCH)' % (t, len(got), sum(got.values()),
                                                                             len(rows.get(t, {}))))
    print('all five trees: %d B' % total)


if __name__ == '__main__':
    main()
