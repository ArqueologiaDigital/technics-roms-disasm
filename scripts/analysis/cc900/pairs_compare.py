#!/usr/bin/env python3
"""Which compilers reproduce which firmware pairs?  Groups pairs_check.py results from several compilers.

usage: python3 -I -B pairs_compare.py NAME=CHECK.tsv [NAME=CHECK.tsv ...] [--md]
Each CHECK.tsv is pairs_check.py's output for one compiler on the same sources and options.  Pairs are grouped by
the set of compilers that reproduce them ("=" result); each group lists its routines with their pair counts.  With
the same sources compiled by V4.23 and by the 2003 / 2009 compilers, a routine that only the later compilers
reproduce shows a V4.23-to-2003 code-generator change that the Technics compiler has; one that only V4.23 reproduces
shows a change it does not have (notes/cc900-compat-plan-2026-11-08/PLAN.md, section 2, step 3).
"""
import sys, collections

def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    names = [a.split('=', 1)[0] for a in args]
    res = collections.defaultdict(dict)
    for a in args:
        n, f = a.split('=', 1)
        for l in open(f).read().splitlines()[1:]:
            c = l.split('\t')
            if len(c) < 7: continue
            res[(c[0], c[1], c[2])][n] = c[6]
    groups = collections.defaultdict(collections.Counter)
    for (im, addr, pub), d in res.items():
        groups[tuple(n for n in names if d.get(n) == '=')][pub] += 1
    rows = []
    for key, cnt in sorted(groups.items(), key=lambda kv: (-sum(kv[1].values()), kv[0])):
        rows.append((', '.join(key) if key else '(none)', str(sum(cnt.values())),
                     ', '.join('`%s` (%d)' % kv for kv in sorted(cnt.items()))))
    head = ('reproduced by', 'pairs', 'routines (pairs)')
    if '--md' in sys.argv:
        w = [max(len(r[i]) for r in rows + [head]) for i in range(3)]
        print('| ' + ' | '.join(h.ljust(x) for h, x in zip(head, w)) + ' |')
        print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
        for r in rows: print('| ' + ' | '.join(c.ljust(x) for c, x in zip(r, w)) + ' |')
    else:
        for r in rows: print('\t'.join(r))

main()
