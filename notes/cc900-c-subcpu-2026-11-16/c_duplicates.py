#!/usr/bin/env python3
"""Is any sub-CPU function defined twice across <tree>/subcpu/cc900/*.c and cc900-staged/*.c?

QUESTION ANSWERED: a label defined by two C files would be built (or promoted) twice.  Prints each label (through
cc900-name) that more than one file of v142's cc900/ and cc900-staged/ defines, with the files.  Exit 1 if any.

usage: python3 -B notes/cc900-c-subcpu-2026-11-16/c_duplicates.py      (repository root)
"""
import glob, os, re, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
FN_RE = re.compile(r'^[\w][\w\s\*]*?\b(\w+)\s*\([^;{)]*\)\s*\{', re.M)


def main():
    where = {}
    for p in sorted(glob.glob(os.path.join(REPO, 'v142', 'subcpu', 'cc900', '*.c')) +
                    glob.glob(os.path.join(REPO, 'v142', 'subcpu', 'cc900-staged', '*.c'))):
        t = open(p, encoding='latin-1').read()
        lm = dict(re.findall(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', t))
        for n in FN_RE.findall(t):
            where.setdefault(lm.get(n, n), []).append(os.path.relpath(p, REPO))
    dup = {n: f for n, f in where.items() if len(f) > 1}
    for n in sorted(dup):
        print(n, ' '.join(dup[n]))
    print('%d labels defined, %d more than once' % (len(where), len(dup)))
    return 1 if dup else 0


if __name__ == '__main__':
    sys.exit(main())
