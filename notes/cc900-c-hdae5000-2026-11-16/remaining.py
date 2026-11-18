#!/usr/bin/env python3
"""Which v2.06i functions are still without matching C, largest first?

QUESTION ANSWERED: survey.tsv lists every function of hdae5000/ with its kind (C?, C-calr, other, tail, hand?, lib);
staged_v423.tsv lists the functions V4.23 reproduces.  This prints the survey's functions of the given kinds that have
no MATCH row for the hdae5000 tree, with size, kind and hand source, and whether a probe file already tried them
(probes/*.c defines the label or maps a C name to it).

    python3 -B notes/cc900-c-hdae5000-2026-11-16/remaining.py [--kinds C?,C-calr] [--min-bytes N] [--untried]
    python3 -B notes/cc900-c-hdae5000-2026-11-16/remaining.py --kinds C?,C-calr,other,tail,hand? --group
        (the open survey rows folded into their procedures: a switch's arms are rows of their own in the survey,
        and the default kinds miss every procedure whose head row is `other`, `tail` or `hand?`; 2026-11-18)
Run from the repository root.
"""
import glob, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
NOT_C_FROM = 0x2971a3      # HDAE5000_Check_HD_Present: first routine of the hand-assembly disk driver


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
    # a label the splice kept as `.set NAME, Function + N` is inside a function now built from C, not a function
    for p in glob.glob(os.path.join(HERE, '..', '..', 'hdae5000', '*.s')):
        t = open(p, 'rb').read().decode('latin-1')
        done |= set(re.findall(r'^\s*\.set\s+(HDAE5000_\w+),\s*HDAE5000_\w+ \+ \d+', t, re.M))
    rows, skipped = [], [0, 0]
    for l in open(os.path.join(HERE, 'survey.tsv')).read().split('\n')[1:]:
        f = l.split('\t')
        if len(f) < 16:
            continue
        name, size, kind = f[1], int(f[3] or 0), f[14]
        # Not the application's C, whatever the survey's kind says (README, "Not compiled by us"):
        # 0x2971a3..0x299ae6 is the hard disk driver, a hand-assembly module; 0x299ae7 up is the C library.
        if '--all' not in a and f[2] != '-' and int(f[2], 16) >= NOT_C_FROM:
            skipped[0] += 1
            skipped[1] += size if kind in kinds else 0
            continue
        if kind in kinds and name not in done and size >= minb:
            if '--untried' in a and name in tried:
                continue
            rows.append((size, name, kind, f[0], 'tried' if name in tried else ''))
    if '--group' in a:
        return grouped(rows)
    rows.sort(reverse=True)
    for size, name, kind, src, t in rows:
        print('%6d  %-6s  %-44s  %-24s  %s' % (size, kind, name, src, t))
    print('%d functions, %d B' % (len(rows), sum(r[0] for r in rows)))
    if skipped[0]:
        print('left out: %d survey rows from 0x%06x up (hand-assembly disk driver and C library), %d B of these kinds;'
              ' --all lists them' % (skipped[0], NOT_C_FROM, skipped[1]))


def grouped(rows):
    """--group: fold the survey's pieces into their procedure.  The survey makes a function of every label that a
    table reaches, so a switch's arms (`Proc_Ev01CA0003`, `Proc_Msg001`, `Proc_Default`) are rows of their own; a
    row whose name is an earlier row's name plus `_...` (the nearest such row before it, by address, in the same
    file) is counted in that row's procedure.  Prints one line per procedure: open bytes, pieces, kinds."""
    addr = {}
    for l in open(os.path.join(HERE, 'survey.tsv')).read().split('\n')[1:]:
        f = l.split('\t')
        if len(f) >= 16 and f[2] != '-':
            addr[f[1]] = (f[0], int(f[2], 16))
    order = sorted(rows, key=lambda r: addr.get(r[1], ('', 0)))
    heads, out = [], {}
    for size, name, kind, src, t in order:
        head = next((h for h in reversed(heads) if name.startswith(h + '_') and addr.get(h, ('',))[0] == src), None)
        if head is None:
            heads.append(name)
            head = name
        g = out.setdefault(head, [0, 0, set(), src, ''])
        g[0] += size
        g[1] += 1
        g[2].add(kind)
        g[4] = g[4] or t
    for head, (size, n, kinds, src, t) in sorted(out.items(), key=lambda x: -x[1][0]):
        print('%6d  %3d  %-14s  %-44s  %-24s  %s' % (size, n, ','.join(sorted(kinds)), head, src, t))
    print('%d procedures (%d survey rows), %d B' % (len(out), len(rows), sum(r[0] for r in rows)))


if __name__ == '__main__':
    main()
