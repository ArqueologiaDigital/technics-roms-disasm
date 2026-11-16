#!/usr/bin/env python3
"""Which v2.06i functions are still without matching C, largest first?

QUESTION ANSWERED: survey.tsv lists every function of hdae5000/ with its kind (C?, C-calr, other, tail, hand?, lib);
staged_v423.tsv lists the functions V4.23 reproduces.  This prints the survey's functions of the given kinds that have
no MATCH row for the hdae5000 tree, with size, kind and hand source, and whether a probe file already tried them
(probes/*.c defines the label or maps a C name to it).

    python3 -B notes/cc900-c-hdae5000-2026-11-16/remaining.py [--kinds C?,C-calr] [--min-bytes N] [--untried]
Run from the repository root.
"""
import glob, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))


def opt(a, n, d):
    return a[a.index(n) + 1] if n in a else d


def main():
    a = sys.argv[1:]
    kinds = set(opt(a, '--kinds', 'C?,C-calr').split(','))
    minb = int(opt(a, '--min-bytes', '0'))
    done = set()
    for l in open(os.path.join(HERE, 'staged_v423.tsv')):
        f = l.rstrip('\n').split('\t')
        if len(f) == 8 and f[0] == 'hdae5000' and f[7] == 'MATCH':
            done.add(f[5])
    tried = set()
    for p in glob.glob(os.path.join(HERE, 'probes', '*.c')):
        t = open(p, encoding='latin-1').read()
        tried |= set(re.findall(r'\b(HDAE5000_\w+)\s*\(', t))
        tried |= {lab for _, lab in re.findall(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', t)}
    rows = []
    for l in open(os.path.join(HERE, 'survey.tsv')).read().split('\n')[1:]:
        f = l.split('\t')
        if len(f) < 16:
            continue
        name, size, kind = f[1], int(f[3] or 0), f[14]
        if kind in kinds and name not in done and size >= minb:
            if '--untried' in a and name in tried:
                continue
            rows.append((size, name, kind, f[0], 'tried' if name in tried else ''))
    rows.sort(reverse=True)
    for size, name, kind, src, t in rows:
        print('%6d  %-6s  %-44s  %-24s  %s' % (size, kind, name, src, t))
    print('%d functions, %d B' % (len(rows), sum(r[0] for r in rows)))


if __name__ == '__main__':
    main()
