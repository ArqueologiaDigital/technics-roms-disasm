#!/usr/bin/env python3
"""Which sub-CPU candidates has no probe compiled yet?

QUESTION ANSWERED: pools/pool_<TAG>_remaining.txt (`pools.py --remaining`) lists every routine not yet built or
staged; open_list.py's source (verdicts/*-sub-*.tsv through idiom_scan.best_attempts) names those some probe
compiled.  This prints the rest -- never compiled -- largest first, with the pool, and the totals per pool.

    python3 -B notes/cc900-c-subcpu-2026-11-16/never_tried.py [--min BYTES] [--max BYTES]      (repository root)
"""
import glob, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import idiom_scan as I                                        # noqa: E402


def main():
    lo, hi = 0, 1 << 30
    a = sys.argv[1:]
    if '--min' in a:
        lo = int(a[a.index('--min') + 1])
    if '--max' in a:
        hi = int(a[a.index('--max') + 1])
    tried = set(I.best_attempts(I.matched()))
    rows, tot = [], {}
    for p in sorted(glob.glob(os.path.join(HERE, 'pools', 'pool_*_remaining.txt'))):
        tag = os.path.basename(p).split('_')[1]
        for line in open(p, encoding='utf-8'):
            f = line.split()
            if len(f) < 5 or not f[0].isdigit():
                continue
            b, label, src, kind = int(f[0]), f[2], f[3], f[4]
            if label in tried or not lo <= b <= hi:
                continue
            rows.append((b, label, tag, kind, src))
            n, s = tot.get(tag, (0, 0))
            tot[tag] = (n + 1, s + b)
    rows.sort(key=lambda r: (-r[0], r[1]))
    for r in rows:
        print('%5d  %-44s %s  %-4s %s' % r)
    print('# never compiled: %d functions, %d B; %s' % (
        len(rows), sum(r[0] for r in rows), ', '.join('%s %d / %d B' % (k, v[0], v[1]) for k, v in sorted(tot.items()))))


if __name__ == '__main__':
    main()
