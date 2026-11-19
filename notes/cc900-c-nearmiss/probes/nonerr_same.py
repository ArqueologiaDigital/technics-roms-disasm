#!/usr/bin/env python3
"""QUESTION ANSWERED: after an error-only recheck (`--recheck --status ERR-... --update`), is every index row that was
NOT an error in OLD_REV byte-identical in the new index.tsv (same row count: rows compared by position; after an
--add-new pass: paired by (listing, function, occurrence))?  A recheck must touch only the rows it selected, and
--add-new only add rows; any MATCH / NEAR / DIFF row reported as changed, or an old row missing, is damage.

--reindexed-hd: the runs that drop_runs.py --misattributed took out of OLD_REV's index (rows whose C lies in an
older HD-AE5000 tree, indexed as 'hdae5000') were indexed again on purpose.  Their rows are not counted as damage;
their status moves are listed apart (old status -> new status, the tree column included), the rows of their
v2.06i sources separately from the re-attributed ones.

usage: python3 -B notes/cc900-c-nearmiss/probes/nonerr_same.py OLD_REV [NEW_INDEX.tsv] [--reindexed-hd]
(default NEW: the working tree's notes/cc900-c-nearmiss/index.tsv.  2026-11-19, HEAD b650a74fc against the rechecked
file: MATCH 22824, NEAR 10300, DIFF 12562 identical, none changed.)"""
import os
import subprocess
import sys
from collections import Counter

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..'))
OLD_HD = ('hdae5000_v2_01i', 'hdae5000_v1_15i', 'hdae5000_v1_10i')


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    reidx = '--reindexed-hd' in sys.argv
    rev = args[0]
    new = args[1] if len(args) > 1 else os.path.join(REPO, 'notes', 'cc900-c-nearmiss', 'index.tsv')
    old = subprocess.run(['git', '-C', REPO, 'show', '%s:notes/cc900-c-nearmiss/index.tsv' % rev],
                         capture_output=True, text=True).stdout.splitlines()
    nw = open(new).read().splitlines()
    cols = old[0].split('\t')
    si, ti, sri, ri = cols.index('status'), cols.index('tree'), cols.index('source'), cols.index('run')
    li, fi = cols.index('listing'), cols.index('function')
    reruns = set()
    if reidx:
        for l in old[1:]:
            p = l.split('\t')
            first = p[sri].split('/')[0]
            if first in OLD_HD and p[ti] != first:
                reruns.add(p[ri])
    if len(old) == len(nw) and not reidx:
        pairs = list(zip(old[1:], nw[1:]))
        missing = 0
    else:
        # rows added (an --add-new pass): pair by (listing, function, occurrence within the file), as status_moves.py
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
        missing = Counter(ko[k].split('\t')[ri] in reruns for k in ko if k not in kn)
        print('rows: %d old, %d new, %d old rows missing from new (%d of them in re-indexed runs)' % (
            len(old) - 1, len(nw) - 1, sum(missing.values()), missing[True]))
        missing = missing[False]
    same, diff = Counter(), Counter()
    moves = {'v2.06i source': Counter(), 'older-HD source': Counter()}
    for a, b in pairs:
        pa, pb = a.split('\t'), b.split('\t')
        if pa[ri] in reruns:
            kind = 'older-HD source' if pa[sri].split('/')[0] in OLD_HD else 'v2.06i source'
            if (pa[ti], pa[si]) != (pb[ti], pb[si]):
                moves[kind]['%s %s -> %s %s' % (pa[ti], pa[si], pb[ti], pb[si])] += 1
            else:
                moves[kind]['unchanged ' + pa[si]] += 1
            continue
        st = pa[si]
        if st.startswith('ERR'):
            continue
        (same if a == b else diff)[st] += 1
    print('non-error rows identical: %s; changed: %s' % (dict(same), dict(diff)))
    if reidx:
        print('re-indexed runs: %d' % len(reruns))
        for kind, c in moves.items():
            print('  %s rows:' % kind)
            for m, n in sorted(c.items()):
                print('    %-60s %d' % (m, n))
    return 1 if diff or missing else 0


if __name__ == '__main__':
    sys.exit(main())
