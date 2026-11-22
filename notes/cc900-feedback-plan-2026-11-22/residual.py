#!/usr/bin/env python3
"""Residual near misses: functions that V4.23 has compiled from our C but that are still NOT built from C on main.

QUESTION ANSWERED: the near-miss index (notes/cc900-c-nearmiss/index.tsv) takes each function's best attempt over
every oracle run, but many of its non-matching rows belong to functions that the build reproduces anyway (the build
links each C file at its ROM address with module-level call relaxation; the index compares one listing at a time).
Which functions are really left, how big are they, and which difference classes keep them from matching?  This is
the evidence set for the compiler-modelling feedback plan (README.md beside this script).

Inputs (both committed): notes/cc900-c-nearmiss/index.tsv and scripts/analysis/cc900/results/c_build_coverage.md
(its per-function table: built = yes and V4.23 = MATCH means built from C on main).

Usage, from the repository root:
    python3 -B notes/cc900-feedback-plan-2026-11-22/residual.py [--list N]
Prints Markdown: totals, classes of the residual NEAR / DIFF functions, and the N largest residual NEAR functions.
"""
import sys

INDEX = 'notes/cc900-c-nearmiss/index.tsv'
COVERAGE = 'scripts/analysis/cc900/results/c_build_coverage.md'
TREE_TO_IMAGE = {'hdae5000_v2_01i': 'hdae_v201', 'hdae5000_v1_15i': 'hdae_v115', 'hdae5000_v1_10i': 'hdae_v110'}
RANK = {'MATCH': 3, 'NEAR': 2, 'DIFF': 1}


def built_set():
    built = set()
    in_table = False
    with open(COVERAGE, encoding='utf-8') as f:
        for line in f:
            if line.startswith('| image ') and '| function ' in line and '| built ' in line:
                in_table = True
                continue
            if in_table:
                if not line.startswith('|'):
                    break
                cells = [c.strip() for c in line.strip().strip('|').split('|')]
                if len(cells) < 8 or cells[0].startswith('-'):
                    continue
                if cells[5] == 'yes' and cells[7] == 'MATCH':
                    built.add((cells[0], cells[1]))
    return built


def best_attempts():
    best = {}
    with open(INDEX, encoding='utf-8') as f:
        head = f.readline().rstrip('\n').split('\t')
        col = {name: i for i, name in enumerate(head)}
        for line in f:
            r = line.rstrip('\n').split('\t')
            tree, fn, status = r[col['tree']], r[col['function']], r[col['status']]
            try:
                pct = float(r[col['eq_pct']]) if r[col['eq_pct']] else 0.0
            except ValueError:
                pct = 0.0
            try:
                size = int(r[col['rom_size']]) if r[col['rom_size']] else 0
            except ValueError:
                size = 0
            key = (TREE_TO_IMAGE.get(tree, tree), fn)
            score = (RANK.get(status, 0), pct)
            if key not in best or score > best[key][0]:
                best[key] = (score, status, r[col['classes']], size, pct, r[col['first_diff']], r[col['run']])
    return best


def main():
    nlist = 25
    if '--list' in sys.argv:
        nlist = int(sys.argv[sys.argv.index('--list') + 1])
    built = built_set()
    best = best_attempts()
    totals = {}
    residual = []
    for key, (score, status, classes, size, pct, first, run) in best.items():
        is_built = key in built
        kind = 'built' if is_built else status if status in RANK else 'error'
        totals.setdefault(kind, [0, 0])
        totals[kind][0] += 1
        totals[kind][1] += size
        if not is_built and status in ('NEAR', 'DIFF'):
            residual.append((key, status, classes, size, pct, first, run))

    def table(rows, head):
        widths = [max(len(str(x)) for x in col) for col in zip(head, *rows)] if rows else [len(h) for h in head]
        out = ['| ' + ' | '.join(str(h).ljust(w) for h, w in zip(head, widths)) + ' |',
               '|' + '|'.join('-' * (w + 2) for w in widths) + '|']
        for r in rows:
            out.append('| ' + ' | '.join(str(x).ljust(w) for x, w in zip(r, widths)) + ' |')
        return '\n'.join(out)

    print('## Functions V4.23 compiled from our C, by state on main\n')
    order = ['built', 'MATCH', 'NEAR', 'DIFF', 'error']
    rows = [(k, totals.get(k, [0, 0])[0], totals.get(k, [0, 0])[1]) for k in order]
    print(table(rows, ('state (best attempt)', 'functions', 'ROM B')))
    print('\n`built`: built from C on main, V4.23 MATCH (any attempt state).  `MATCH`: a MATCH attempt exists but the'
          ' function is not built (ready.tsv).  NEAR / DIFF / error: never matched, not built.\n')

    for status in ('NEAR', 'DIFF'):
        cls = {}
        sole = {}
        for key, st, classes, size, pct, first, run in residual:
            if st != status:
                continue
            names = [c for c in classes.split(',') if c]
            for c in names:
                cls.setdefault(c, [0, 0])
                cls[c][0] += 1
                cls[c][1] += size
            if len(names) == 1:
                sole.setdefault(names[0], [0, 0])
                sole[names[0]][0] += 1
                sole[names[0]][1] += size
        rows = sorted(((c, n, b, sole.get(c, [0, 0])[0], sole.get(c, [0, 0])[1]) for c, (n, b) in cls.items()),
                      key=lambda x: -x[2])
        n_fn = sum(1 for r in residual if r[1] == status)
        n_b = sum(r[3] for r in residual if r[1] == status)
        print('## Residual %s: %d functions, %d ROM B, by class\n' % (status, n_fn, n_b))
        print(table(rows, ('class', 'functions', 'ROM B', 'sole', 'sole ROM B')))
        print()

    near = sorted((r for r in residual if r[1] == 'NEAR'), key=lambda r: -r[3])[:nlist]
    rows = [('%s %s' % r[0], r[3], '%.1f' % r[4], r[2], r[5], r[6]) for r in near]
    print('## The %d largest residual NEAR functions\n' % len(rows))
    print(table(rows, ('function', 'ROM B', 'eq %', 'classes', 'first diff', 'best run')))


if __name__ == '__main__':
    main()
