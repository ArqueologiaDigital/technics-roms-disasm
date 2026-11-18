#!/usr/bin/env python3
"""Which of lane_sub's rows of notes/cc900-c-nearmiss/ready.tsv are really new?

QUESTION ANSWERED: ready.tsv (lane_nmx's index, final refresh 2026-11-17) lists MATCHes that main's trees did not
build from C when it was written.  For each lane_sub row this says whether the function is now defined by a C file
of its tree's `subcpu/cc900/` or `subcpu/cc900-staged/` (label through `cc900-name:`), so already built or staged,
or still NEW.  Prints one line per row (state, tree, function, bytes, run, C copy) and the totals; `--new` prints
the NEW rows only.

usage: python3 -B notes/cc900-c-subcpu-2026-11-16/ready_check.py [--new]      (repository root)
"""
import glob, os, re, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
FN_RE = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def defined(tree):
    where = {}
    for sub in ('cc900', 'cc900-staged'):
        for p in sorted(glob.glob(os.path.join(REPO, tree, 'subcpu', sub, '*.c'))):
            t = open(p, encoding='latin-1').read()
            lm = dict(re.findall(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', t))
            for n in FN_RE.findall(t):
                where[lm.get(n, n)] = sub
    return where


def main():
    only_new = '--new' in sys.argv[1:]
    rows = []
    with open(os.path.join(REPO, 'notes', 'cc900-c-nearmiss', 'ready.tsv'), encoding='utf-8') as f:
        head = f.readline().rstrip('\n').split('\t')
        for line in f:
            r = dict(zip(head, line.rstrip('\n').split('\t')))
            if r.get('lane') == 'lane_sub':
                rows.append(r)
    trees = {}
    count = {}
    for r in rows:
        t = r['tree']
        if t not in trees:
            trees[t] = defined(t)
        st = trees[t].get(r['function'], 'NEW')
        count[st] = count.get(st, 0) + 1
        count[st + ' B'] = count.get(st + ' B', 0) + int(r['bytes'])
        if only_new and st != 'NEW':
            continue
        print('\t'.join([st, t, r['function'], r['bytes'], r['run'], r.get('c_copy', '')]))
    print('# rows %d: %s' % (len(rows), ', '.join('%s %d' % (k, v) for k, v in sorted(count.items()))))
    return 0


if __name__ == '__main__':
    sys.exit(main())
