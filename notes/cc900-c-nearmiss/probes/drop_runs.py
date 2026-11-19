#!/usr/bin/env python3
"""Take runs out of the near-miss index so that the next `nearmiss.py --add-new` indexes them again with the current
code (index.tsv rows and runs.tsv lines of those runs removed; nothing else is touched, no file is deleted).

QUESTION ANSWERED (with --list): which runs have index rows whose C source lies in an older HD-AE5000 tree
(`hdae5000_v2_01i/`, `hdae5000_v1_15i/`, `hdae5000_v1_10i/`) but whose `tree` column is not that tree?  Before
2026-11-19 nearmiss.py's tree_of() mapped every `hdae5000*` source to 'hdae5000' (v2.06i), so the ported C of the
older versions was compared with the v2.06i image.

usage: python3 -B notes/cc900-c-nearmiss/probes/drop_runs.py --list-misattributed
       python3 -B notes/cc900-c-nearmiss/probes/drop_runs.py --misattributed     (drop those runs)
       python3 -B notes/cc900-c-nearmiss/probes/drop_runs.py RUN [RUN ...]"""
import os
import sys
from collections import Counter

NOTES = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OLD_HD = ('hdae5000_v2_01i', 'hdae5000_v1_15i', 'hdae5000_v1_10i')


def read(path):
    return open(path).read().splitlines()


def misattributed(index):
    cols = index[0].split('\t')
    ti, si, ri = cols.index('tree'), cols.index('source'), cols.index('run')
    runs = Counter()
    for l in index[1:]:
        p = l.split('\t')
        first = p[si].split('/')[0]
        if first in OLD_HD and p[ti] != first:
            runs[p[ri]] += 1
    return runs


def main():
    ipath, rpath = os.path.join(NOTES, 'index.tsv'), os.path.join(NOTES, 'runs.tsv')
    for p in (ipath, rpath):
        assert os.path.dirname(p) == NOTES and os.path.isfile(p), p
    index = read(ipath)
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return 2
    if args[0] == '--list-misattributed':
        m = misattributed(index)
        for r, n in sorted(m.items()):
            print('%-40s %d rows' % (r, n))
        print('%d runs, %d rows' % (len(m), sum(m.values())))
        return 0
    drop = set(misattributed(index)) if args[0] == '--misattributed' else set(args)
    ri = index[0].split('\t').index('run')
    keep = [index[0]] + [l for l in index[1:] if l.split('\t')[ri] not in drop]
    runs = read(rpath)
    rkeep = [l for l in runs if l.split('\t')[0] not in drop]
    with open(ipath, 'w') as f:
        f.write('\n'.join(keep) + '\n')
    with open(rpath, 'w') as f:
        f.write('\n'.join(rkeep) + '\n')
    print('dropped %d runs: %d index rows, %d runs.tsv lines' % (len(drop), len(index) - len(keep), len(runs) - len(rkeep)))
    return 0


if __name__ == '__main__':
    sys.exit(main())
