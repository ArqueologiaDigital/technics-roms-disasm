#!/usr/bin/env python3
"""QUESTION ANSWERED: per tree, how many functions have MATCH / NEAR / DIFF / an error as their best attempt in the
near-miss index (best = MATCH over NEAR over DIFF over any error, as the README's "functions (best attempt)" row)?

usage: python3 -B notes/cc900-c-nearmiss/probes/per_tree.py [INDEX.tsv]
       (default: notes/cc900-c-nearmiss/index.tsv; prints an aligned Markdown table)"""
import os
import sys
from collections import Counter

NOTES = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RANK = {'MATCH': 0, 'NEAR': 1, 'DIFF': 2}


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else os.path.join(NOTES, 'index.tsv')
    lines = open(path).read().splitlines()
    cols = lines[0].split('\t')
    ti, fi, si = cols.index('tree'), cols.index('function'), cols.index('status')
    best = {}
    for l in lines[1:]:
        p = l.split('\t')
        k = (p[ti], p[fi])
        r = RANK.get(p[si], 3)
        if k not in best or r < best[k]:
            best[k] = r
    per = {}
    for (t, _f), r in best.items():
        per.setdefault(t, Counter())[r] += 1
    rows = [[t, c[0], c[1], c[2], c[3]] for t, c in sorted(per.items())]
    tot = Counter()
    for c in per.values():
        tot.update(c)
    rows.append(['all', tot[0], tot[1], tot[2], tot[3]])
    head = ['tree', 'MATCH', 'NEAR', 'DIFF', 'errors']
    w = [max(len(str(x)) for x in col) for col in zip(head, *rows)]
    print('| ' + ' | '.join(h.ljust(n) for h, n in zip(head, w)) + ' |')
    print('|' + '|'.join('-' * (n + 2) for n in w) + '|')
    for r in rows:
        print('| ' + ' | '.join(str(x).ljust(n) for x, n in zip(r, w)) + ' |')


if __name__ == '__main__':
    main()
