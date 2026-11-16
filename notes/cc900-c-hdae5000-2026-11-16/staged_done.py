#!/usr/bin/env python3
"""Which staged C files are promoted completely, and how many functions does each tree build from C?

QUESTION ANSWERED: after promote_hd.py, a file of <tree>/cc900-staged/ whose every function is built (its label's
line in the tree's hand source is an `.include "includes/generated/cc900/<label>.s"`) can be removed from staging.
This prints, per tree, the staged files that are complete (one path per line, for an explicit `git rm --`), the
ones that are not with the functions still held, and the number of functions the tree builds from C.  It deletes
nothing.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/staged_done.py        (from the repository root)
"""
import os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import stage_from_probe as sp                                # noqa: E402

TREES = ['hdae5000', 'hdae5000_v2_01i', 'hdae5000_v1_15i', 'hdae5000_v1_10i']
INC = re.compile(rb'^([A-Za-z_]\w*):\s*\.include\s+"includes/generated/cc900/')
NAME_RE = re.compile(r'cc900-name:\s*(\w+)\s*=\s*(\w+)')


def main():
    for tree in TREES:
        built = set()
        for f in sorted(os.listdir(os.path.join(REPO, tree))):
            if f.endswith('.s'):
                for l in open(os.path.join(REPO, tree, f), 'rb'):
                    m = INC.match(l)
                    if m:
                        built.add(m.group(1).decode())
        print('%s: %d functions built from C' % (tree, len(built)))
        sdir = os.path.join(REPO, tree, 'cc900-staged')
        for f in sorted(os.listdir(sdir)):
            if not f.endswith('.c'):
                continue
            text = open(os.path.join(sdir, f), encoding='latin-1').read()
            label = dict(NAME_RE.findall(text))
            fns = [label.get(n, n) for k, n, _ in sp.split(text) if k == 'fn']
            held = [n for n in fns if n not in built]
            if not held:
                print('  complete  %s/cc900-staged/%s' % (tree, f))
            else:
                print('  held      %s/cc900-staged/%s: %s' % (tree, f, ' '.join(held)))


if __name__ == '__main__':
    main()
