#!/usr/bin/env python3
"""QUESTION ANSWERED: after an error-only recheck (`--recheck --status ERR-... --update`), is every index row that was
NOT an error in OLD_REV byte-identical in the new index.tsv (same row count, rows compared by position)?  A recheck
must touch only the rows it selected; any MATCH / NEAR / DIFF row reported as changed is damage.

usage: python3 -B notes/cc900-c-nearmiss/probes/nonerr_same.py OLD_REV [NEW_INDEX.tsv]
(default NEW: the working tree's notes/cc900-c-nearmiss/index.tsv.  2026-11-19, HEAD b650a74fc against the rechecked
file: MATCH 22824, NEAR 10300, DIFF 12562 identical, none changed.)"""
import os
import subprocess
import sys
from collections import Counter

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))


def main():
    rev = sys.argv[1]
    new = sys.argv[2] if len(sys.argv) > 2 else os.path.join(REPO, 'notes', 'cc900-c-nearmiss', 'index.tsv')
    old = subprocess.run(['git', '-C', REPO, 'show', '%s:notes/cc900-c-nearmiss/index.tsv' % rev],
                         capture_output=True, text=True).stdout.splitlines()
    nw = open(new).read().splitlines()
    if len(old) != len(nw):
        print('row counts differ: %d vs %d (an --add-new pass in between? compare before it)' % (len(old), len(nw)))
        return 1
    si = old[0].split('\t').index('status')
    same, diff = Counter(), Counter()
    for a, b in zip(old[1:], nw[1:]):
        st = a.split('\t')[si]
        if st.startswith('ERR'):
            continue
        (same if a == b else diff)[st] += 1
    print('non-error rows identical: %s; changed: %s' % (dict(same), dict(diff)))
    return 1 if diff else 0


if __name__ == '__main__':
    sys.exit(main())
