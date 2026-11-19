#!/usr/bin/env python3
"""QUESTION ANSWERED: after an error-only recheck (`--recheck --status ERR-... --update`), is every index row that was
NOT an error in OLD_REV byte-identical in the new index.tsv (same row count: rows compared by position; after an
--add-new pass: paired by (listing, function, occurrence))?  A recheck must touch only the rows it selected, and
--add-new only add rows; any MATCH / NEAR / DIFF row reported as changed, or an old row missing, is damage.

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
    cols = old[0].split('\t')
    si = cols.index('status')
    if len(old) == len(nw):
        pairs = zip(old[1:], nw[1:])
        missing = 0
    else:
        # rows added (an --add-new pass): pair by (listing, function, occurrence within the file), as status_moves.py
        li, fi = cols.index('listing'), cols.index('function')

        def keyed(lines):
            seen, out = Counter(), {}
            for l in lines[1:]:
                p = l.split('\t')
                k = (p[li], p[fi])
                seen[k] += 1
                out[k + (seen[k],)] = l
            return out
        ko, kn = keyed(old), keyed(nw)
        pairs = [(ko[k], kn[k]) for k in ko if k in kn]
        missing = sum(1 for k in ko if k not in kn)
        print('rows: %d old, %d new, %d old rows missing from new' % (len(old) - 1, len(nw) - 1, missing))
    same, diff = Counter(), Counter()
    for a, b in pairs:
        st = a.split('\t')[si]
        if st.startswith('ERR'):
            continue
        (same if a == b else diff)[st] += 1
    print('non-error rows identical: %s; changed: %s' % (dict(same), dict(diff)))
    return 1 if diff or missing else 0


if __name__ == '__main__':
    sys.exit(main())
