#!/usr/bin/env python3
"""What does the tree's source say a routine is?  Prints the statements of the named routines, comments stripped.

usage (repository root): python3 -B notes/cc900-c-wsa1-2026-11-17/show.py TREE NAME [NAME ...] [--max N]
    TREE is wsa1/prom_a, wsa1/prom_b or wsa1/prom_c.  Each routine is printed from its label to the first
    `ret` / `retd` that is followed by a label starting another routine (`link`) or by data, at most N
    statements (default 120).
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import wsa_common as W


def main():
    a = sys.argv[1:]
    mx = int(a[a.index('--max') + 1]) if '--max' in a else 120
    tree, names = a[0], [x for x in a[1:] if not x.startswith('--') and not x.isdigit()]
    want = set(names)
    for path in W.source_files(tree):
        it = W.items(path)
        for k, (n, labs, ins) in enumerate(it):
            hit = want & set(labs)
            if not hit:
                continue
            print('== %s  (%s:%d)' % (' '.join(labs), os.path.relpath(path, W.REPO), n))
            for j in range(k, min(k + mx, len(it))):
                n2, l2, i2 = it[j]
                if j > k:
                    for l in l2:
                        print('%s:' % l)
                print('\t' + i2)
                if re.match(r'(?i)^(ret|retd\b.*|reti)$', i2):
                    nxt = it[j + 1] if j + 1 < len(it) else None
                    if nxt is None or nxt[1] and (nxt[2].lower().startswith(('link', '.')) or
                                                  not nxt[1][0].startswith(('sub_', '.L')) or '__' not in nxt[1][0]):
                        break
            want -= hit
    for n in sorted(want):
        print('not found: %s' % n)


if __name__ == '__main__':
    sys.exit(main())
