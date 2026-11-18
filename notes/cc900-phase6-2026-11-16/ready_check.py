#!/usr/bin/env python3
"""ready_check.py -- which lane_p6 rows of the near-miss index's ready.tsv are really not built from C yet?

QUESTION ANSWERED: notes/cc900-c-nearmiss/ready.tsv lists functions some VM run matched but which main did not build
from C when the index was made.  The index was made on another branch, so some rows are built by now, or are
staged.  For every lane_p6 row this prints one verdict:
  built     the tree's hand source has the label on an `.include "includes/generated/cc900/` line
  staged    a <tree>/maincpu/cc900-staged/*.c defines it (not built)
  NEW       neither: a candidate for staging
  nolabel   the tree has no column-0 label of that name
v8 rows are read in v9's tree (v8 is v9's source).  Prints the rows, then per verdict the count and bytes.

usage: python3 -B notes/cc900-phase6-2026-11-16/ready_check.py [--lane LANE] [--new]     (from the repository root)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import new_pool                                              # noqa: E402


def labels(tree):
    """label -> True when its line includes a generated cc900 body."""
    out = {}
    root = os.path.join(REPO, tree, 'maincpu')
    for dp, dn, fn in os.walk(root):
        for f in fn:
            if not f.endswith('.s'):
                continue
            for line in open(os.path.join(dp, f), 'rb'):
                m = re.match(rb'([A-Za-z_][\w.]*):(.*)', line)
                if m:
                    name = m.group(1).decode('latin-1')
                    gen = b'includes/generated/cc900/' in m.group(2)
                    out[name] = out.get(name, False) or gen
    return out


def main():
    a = sys.argv[1:]
    lane = a[a.index('--lane') + 1] if '--lane' in a else 'lane_p6'
    only_new = '--new' in a
    rows = []
    for line in open(os.path.join(REPO, 'notes', 'cc900-c-nearmiss', 'ready.tsv'), encoding='latin-1'):
        c = line.rstrip('\n').split('\t')
        if c[0] == lane:
            rows.append(c)
    cache, staged = {}, {}
    tally = {}
    for c in rows:
        tree = 'v9' if c[1] == 'v8' else c[1]
        if tree not in cache:
            cache[tree] = labels(tree)
            staged[tree] = new_pool.defined_in(os.path.join(REPO, tree, 'maincpu', 'cc900-staged'))
        lab = cache[tree]
        fn = c[2]
        if fn not in lab:
            v = 'nolabel'
        elif lab[fn]:
            v = 'built'
        elif fn in staged[tree]:
            v = 'staged'
        else:
            v = 'NEW'
        n, b = tally.get(v, (0, 0))
        tally[v] = (n + 1, b + int(c[3]))
        if not only_new or v == 'NEW':
            print('\t'.join([v] + c[1:8]))
    for v, (n, b) in sorted(tally.items()):
        print('# %-8s %4d rows %7d B' % (v, n, b))


if __name__ == '__main__':
    main()
