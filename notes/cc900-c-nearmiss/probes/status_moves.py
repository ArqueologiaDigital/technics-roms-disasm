#!/usr/bin/env python3
"""QUESTION ANSWERED: which index rows changed status between two committed versions of
notes/cc900-c-nearmiss/index.tsv, and how many of each move (MATCH -> NEAR, ERR-asm -> MATCH, ...)?
Rows are matched by (listing, function, occurrence number within the file), so the variants of one label line up.

usage: python3 -B notes/cc900-c-nearmiss/probes/status_moves.py OLD_REV NEW_REV
(2026-11-18: 117dd396c d84256090 showed the --update recheck rewriting rows it had not selected: MATCH -> NEAR 99.)"""
import os
import subprocess
import sys
from collections import Counter

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))


def rows(rev):
    t = subprocess.run(['git', '-C', REPO, 'show', '%s:notes/cc900-c-nearmiss/index.tsv' % rev],
                       capture_output=True, text=True).stdout.splitlines()
    cols = t[0].split('\t')
    seen = Counter()
    out = {}
    for l in t[1:]:
        r = dict(zip(cols, l.split('\t')))
        k = (r['listing'], r['function'])
        seen[k] += 1
        out[k + (seen[k],)] = r
    return out


def main():
    a, b = rows(sys.argv[1]), rows(sys.argv[2])
    moves = Counter((a[k]['status'], b[k]['status']) for k in a if k in b and a[k]['status'] != b[k]['status'])
    for (x, y), n in sorted(moves.items()):
        print('%-14s -> %-14s %d' % (x, y, n))
    print('rows only in old: %d, only in new: %d' % (len(set(a) - set(b)), len(set(b) - set(a))))


if __name__ == '__main__':
    main()
