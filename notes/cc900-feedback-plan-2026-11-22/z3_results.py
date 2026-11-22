#!/usr/bin/env python3
"""Step Z3 of the feedback plan: what share of the `djnz` pool does Toshiba V4.23 reproduce?

QUESTION ANSWERED: z3_pool.tsv (z3_pool.py) lists the hand-source routines holding a `djnz`; its 56 rows of class
`compiled-looking` or `no frame` are the pool lane_z3 wrote C for.  z3_results.tsv (filled by the lane, one row per
pool routine) records each one's outcome:
    MATCH   V4.23 reproduces the ROM's bytes from our C (the run named; the probe file in the detail column)
    NEAR    our best C differs from the ROM at a small offset; the detail names the first difference's class
    DIFF    tried, differs early and widely
    hand    not tried: the routine reads as hand assembly (the reason in one line)
A routine of the pool with no row, or a row for a routine outside the pool, is an error.  This prints the per-routine
table and the share (counts per outcome, per image and in all), aligned Markdown, and checks the TSV.

usage, from technics-roms-disasm's root:
    python3 -B notes/cc900-feedback-plan-2026-11-22/z3_results.py [--write notes/cc900-feedback-plan-2026-11-22/z3_results.md]
"""
import collections
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
OUTCOMES = ['MATCH', 'NEAR', 'DIFF', 'hand']


def table(head, rows):
    w = [max(len(str(r[i])) for r in [head] + rows) for i in range(len(head))]
    line = lambda r: '| ' + ' | '.join(str(c).ljust(w[i]) for i, c in enumerate(r)) + ' |'
    return '\n'.join([line(head), '|' + '|'.join('-' * (x + 2) for x in w) + '|'] + [line(r) for r in rows])


def main():
    pool = [l.split('\t') for l in open(os.path.join(HERE, 'z3_pool.tsv')).read().splitlines()[1:]]
    pool = {(r[0], r[1]): r for r in pool if r[9] != 'hand'}
    res = [l.split('\t') for l in open(os.path.join(HERE, 'z3_results.tsv')).read().splitlines()[1:] if l.strip()]
    bad = []
    seen = {}
    for r in res:
        if len(r) != 5 or r[2] not in OUTCOMES:
            bad.append('malformed row: %r' % (r,))
            continue
        k = (r[0], r[1])
        if k not in pool:
            bad.append('not in the pool: %s %s' % k)
        if k in seen:
            bad.append('duplicate: %s %s' % k)
        seen[k] = r
    for k in pool:
        if k not in seen:
            bad.append('no result: %s %s' % k)
    if bad:
        sys.exit('\n'.join(bad))
    order = {'v10': 0, 'v142': 1, 'hdae5000': 2}
    rows = sorted(seen.values(), key=lambda r: (order[r[0]], OUTCOMES.index(r[2]), r[1]))
    out = ['## Z3 results: the `djnz` pool, routine by routine', '',
           'Pool: z3_pool.tsv rows of class `compiled-looking` or `no frame`; outcome as z3_results.py defines it.', '',
           table(['image', 'routine', 'cls', 'insns', 'outcome', 'detail', 'run'],
                 [[r[0], r[1], pool[(r[0], r[1])][9], pool[(r[0], r[1])][8], r[2], r[3], r[4]] for r in rows]),
           '', '## The share', '']
    cnt = collections.Counter((r[0], r[2]) for r in rows)
    srows = []
    for img in sorted({r[0] for r in rows}, key=order.get) + ['all']:
        c = [sum(v for (i, o), v in cnt.items() if o == oc and img in (i, 'all')) for oc in OUTCOMES]
        tried = c[0] + c[1] + c[2]
        srows.append([img, sum(c), tried, c[0], c[1], c[2], c[3],
                      '%d %%' % round(100.0 * c[0] / tried) if tried else '-'])
    out.append(table(['image', 'routines', 'tried', 'MATCH', 'NEAR', 'DIFF', 'hand', 'MATCH of tried'], srows))
    text = '\n'.join(out) + '\n'
    if '--write' in sys.argv:
        open(sys.argv[sys.argv.index('--write') + 1], 'w').write(text)
    print(text, end='')


if __name__ == '__main__':
    main()
