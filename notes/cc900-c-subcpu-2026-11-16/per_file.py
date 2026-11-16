#!/usr/bin/env python3
"""Per probe file, option set and function: MATCH or the first difference (for the idiom probes).

QUESTION ANSWERED: sub_v423.py check keeps each function's best attempt; an idiom probe needs every file's own verdict
(one C spelling per file).  For every listing of a run whose stem matches PATTERN this prints and writes one row:
file, option set, function, bytes, verdict.

    python3 -B notes/cc900-c-subcpu-2026-11-16/per_file.py RUN_DIR PATTERN [--tsv OUT]     (repository root)
"""
import fnmatch, glob, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import sub_v423 as S                                          # noqa: E402


def main():
    a = sys.argv[1:]
    if len(a) < 2:
        sys.exit(__doc__)
    rows = []
    for lst in sorted(glob.glob(os.path.join(a[0], 'out', 'v423', '*', 'sub', '*.asm'))):
        stem, label = os.path.basename(lst)[:-4], lst.split(os.sep)[-3]
        if not fnmatch.fnmatch(stem, a[1]):
            continue
        c = S.find_c(stem)
        for fn, n, v in S.compare(lst, 'v142/subcpu', [c] if c else []):
            rows.append((stem, label, fn, str(n), v))
    for r in rows:
        print('%-14s %-6s %-36s %5s  %s' % r)
    if '--tsv' in a:
        with open(a[a.index('--tsv') + 1], 'w') as fh:
            fh.write('file\tset\tfunction\tbytes\tverdict\n')
            for r in rows:
                fh.write('\t'.join(r) + '\n')


if __name__ == '__main__':
    main()
