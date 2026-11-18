#!/usr/bin/env python3
"""QUESTION ANSWERED: does a change to nearmiss.py leave the first row of each (listing, function) of a run as it
was in a committed index (status, equal %, classes)?  Used to check that comparing a label's later variants (rows
that used to be ERR-dup) does not move the first variant's result.

usage: python3 -B notes/cc900-c-nearmiss/probes/first_occ.py REV INDEX.tsv RUN
(2026-11-18: 117dd396c, a scratch index of run 2026-11-17-10-hd-r39 made with
`nearmiss.py --runs 2026-11-17-10-hd-r39 --out DIR --jobs 2`: 40 first rows in both, 0 differ.)"""
import os
import subprocess
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))


def first(lines, run):
    cols = lines[0].split('\t')
    out = {}
    for l in lines[1:]:
        r = dict(zip(cols, l.split('\t')))
        if r['run'] == run:
            out.setdefault((r['listing'], r['function']), r)
    return out


def main():
    rev, idx, run = sys.argv[1:4]
    a = first(subprocess.run(['git', '-C', REPO, 'show', '%s:notes/cc900-c-nearmiss/index.tsv' % rev],
                             capture_output=True, text=True).stdout.splitlines(), run)
    b = first(open(idx).read().splitlines(), run)
    diff = [(k, a[k]['status'], a[k]['eq_pct'], b[k]['status'], b[k]['eq_pct']) for k in a if k in b and
            (a[k]['status'], a[k]['eq_pct'], a[k]['classes']) != (b[k]['status'], b[k]['eq_pct'], b[k]['classes'])]
    print('%d first rows in both, %d differ, %d only old, %d only new' % (
        len(set(a) & set(b)), len(diff), len(set(a) - set(b)), len(set(b) - set(a))))
    for d in diff[:20]:
        print(d)


if __name__ == '__main__':
    main()
