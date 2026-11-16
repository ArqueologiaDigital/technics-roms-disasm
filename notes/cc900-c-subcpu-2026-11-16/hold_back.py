#!/usr/bin/env python3
"""Move functions out of <tree>/subcpu/cc900/FILE.c (built) into <tree>/subcpu/cc900-staged/FILE_<TAG>.c (not built).

QUESTION ANSWERED / WHY: V4.23 reproduces these functions (staged_v423.tsv), but the build cannot build them yet: a
name its lookup does not resolve (the shared kernel's labels, the C runtime's C9H_* routines, a callee's short
cc900-name).  This takes each named function out of the built file, in all three trees, keeps every declaration in
both files, and writes the held-back functions with a note saying why.  The hand sources must then be spliced again
from their unspliced state (git checkout of v142/subcpu/core, cc900_splice.py, the v141 / v140 generators).

usage: python3 -B notes/cc900-c-subcpu-2026-11-16/hold_back.py FILE.c TAG "WHY" FUNC [FUNC ...]   (repository root)
"""
import os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import port_staged as P                                           # noqa: E402

REPO = P.REPO


def main():
    a = sys.argv[1:]
    if len(a) < 4:
        sys.exit(__doc__)
    fname, tag, why, names = a[0], a[1], a[2], a[3:]
    for t in ('v142', 'v141', 'v140'):
        p = os.path.join(REPO, t, 'subcpu', 'cc900', fname)
        text = open(p).read()
        head, funcs = P.split_functions(text)
        got = [n for n, _, _ in funcs if n in names]
        assert sorted(got) == sorted(names), (t, fname, got)
        keep = head + ''.join(('' if n in names else body) + rest for n, body, rest in funcs)
        moved = head + ''.join((body + rest) if n in names else rest for n, body, rest in funcs)
        moved = moved.replace('*/\n', '   Held back from subcpu/cc900/ (2026-11-16): %s\n*/\n' % why, 1)
        q = os.path.join(REPO, t, 'subcpu', 'cc900-staged', fname[:-2] + '_' + tag + '.c')
        os.makedirs(os.path.dirname(q), exist_ok=True)
        open(p, 'w').write(keep)
        open(q, 'w').write(moved)
        empty = not re.search(r'\w+\s*\([^;{)]*\)\s*\{', keep.split('*/', 1)[1])
        print('%s: %d function(s) -> %s%s' % (os.path.relpath(p, REPO), len(got), os.path.relpath(q, REPO),
                                             '  (built file now empty)' if empty else ''))


if __name__ == '__main__':
    main()
