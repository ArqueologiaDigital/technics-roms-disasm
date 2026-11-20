#!/usr/bin/env python3
"""Which v2.06i functions built from C does each older HD-AE5000 tree define (same label) but not build yet, and how
close did V4.23 come there?

QUESTION ANSWERED (2026-11-20): the resume list for porting.  For each older tree (v2.01i, v1.15i, v1.10i) it takes
the labels hdae5000/ builds from C (its hand source `.include`s generated cc900 bodies), keeps those the older tree's
symbol reference file defines and the tree does not build, and prints each with v2.06i's survey size and the best
attempt the near-miss index (notes/cc900-c-nearmiss/index.tsv) has for THAT tree (status, classes, equal %, run).
It also lists the labels v2.06i builds that the older tree lacks (by name), as a count per tree.  It reads only
committed files; it changes nothing.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/older_gap.py [--tsv OUT.tsv]      (from the repository root)
"""
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
INC = re.compile(rb'^([A-Za-z_]\w*):\s*\.include\s+"includes/generated/cc900/')
OLDER = [('hdae5000_v2_01i', 'hdae5000_v2_01i'), ('hdae5000_v1_15i', 'hdae5000_v1_15i'),
         ('hdae5000_v1_10i', 'hdae5000_v1_10i')]
RANK = {'MATCH': 0, 'NEAR': 1, 'DIFF': 2}


def built(tree):
    out = set()
    for f in os.listdir(os.path.join(REPO, tree)):
        if f.endswith('.s'):
            for l in open(os.path.join(REPO, tree, f), 'rb'):
                m = INC.match(l)
                if m and b'(cc900-data' not in l:
                    out.add(m.group(1).decode())
    return out


def defined(tree):
    out = set()
    for l in open(os.path.join(REPO, 'symbols', tree + '_symbols_reference.txt')):
        if l.startswith('#'):
            continue
        f = l.split()
        if len(f) == 2:
            out.add(f[0])
    return out


def survey_sizes():
    out = {}
    lines = open(os.path.join(HERE, 'survey.tsv')).read().split('\n')
    head = lines[0].split('\t')
    for l in lines[1:]:
        f = l.split('\t')
        if len(f) == len(head):
            out[f[head.index('label')]] = int(f[head.index('bytes')])
    return out


def best_rows():
    """{(tree, function): best index row (dict)}: lowest status rank, then highest equal %"""
    path = os.path.join(REPO, 'notes', 'cc900-c-nearmiss', 'index.tsv')
    lines = open(path, encoding='latin-1').read().split('\n')
    head = lines[0].split('\t')
    best = {}
    for l in lines[1:]:
        f = l.split('\t')
        if len(f) < len(head):
            continue
        r = dict(zip(head, f))
        key = (r['tree'], r['function'])
        pct = float(r['eq_pct']) if r['eq_pct'] else -1.0
        score = (RANK.get(r['status'], 3), -pct)
        if key not in best or score < best[key][0]:
            best[key] = (score, r)
    return {k: v[1] for k, v in best.items()}


def main():
    tsv = sys.argv[sys.argv.index('--tsv') + 1] if '--tsv' in sys.argv else None
    base = built('hdae5000')
    sizes = survey_sizes()
    best = best_rows()
    rows = []
    for tree, key in OLDER:
        have, names = built(tree), defined(tree)
        gap = sorted(base & names - have, key=lambda n: -sizes.get(n, 0))
        lacks = sorted(base - names)
        print('%s: builds %d; v2.06i builds %d; %d of them defined here and not built (%d B by v2.06i size); '
              '%d not defined here' % (tree, len(have), len(base), len(gap), sum(sizes.get(n, 0) for n in gap),
                                       len(lacks)))
        for n in gap:
            r = best.get((key, n))
            st = '%s %s %s%% %s' % (r['status'], r['classes'] or '-', r['eq_pct'] or '-', r['run']) if r else \
                'no index row'
            print('  %-48s %6d  %s' % (n, sizes.get(n, 0), st))
            rows.append((tree, n, sizes.get(n, 0), r['status'] if r else '', r['classes'] if r else '',
                         r['eq_pct'] if r else '', r['run'] if r else ''))
        print('  not defined here: %s' % ' '.join(lacks))
        # functions of this tree that the near-miss index compiled but that v2.06i does not build: the tree's own
        # labels (per-tree C) and v2.06i functions still open in v2.06i too
        other = sorted(((f, r) for (t, f), r in best.items() if t == key and f not in have and f not in gap),
                       key=lambda fr: -int(fr[1]['rom_size'] or 0))
        print('  index rows not built here and not in the list above: %d' % len(other))
        for f, r in other:
            print('    %-46s %6s  %s %s %s%% %s%s' % (f, r['rom_size'] or '-', r['status'], r['classes'] or '-',
                                                     r['eq_pct'] or '-', r['run'],
                                                     '' if f in base else ('  (v2.06i open)' if f in sizes else
                                                                           '  (own label)')))
        # the tree's own functions: survey.py rows (survey.py --tree) whose label v2.06i does not define, below the
        # disk driver (from HDAE5000_Check_HD_Present up the image is hand assembly and the C library, README)
        import survey
        survey.TREE, survey.VERSION = os.path.join(REPO, tree), survey.TREES[tree]
        del survey.ROWS[:]
        v206 = defined('hdae5000')
        srows = survey.routines()
        drv = min(r['addr'] for r in srows if r['label'] == 'HDAE5000_Check_HD_Present')
        own = sorted((r for r in srows if r['label'] not in v206 and r['label'] not in have and r['addr'] < drv
                      and r['kind'] not in ('lib', 'data')), key=lambda r: -r['bytes'])
        print('  own functions (survey --tree) not built: %d, %d B' % (len(own), sum(r['bytes'] for r in own)))
        for r in own:
            print('    %-46s %6d  %s' % (r['label'], r['bytes'], r['kind']))
    if tsv:
        with open(tsv, 'w') as o:
            o.write('tree\tlabel\tv206_bytes\tstatus\tclasses\teq_pct\trun\n')
            for row in rows:
                o.write('\t'.join(str(x) for x in row) + '\n')


if __name__ == '__main__':
    main()
