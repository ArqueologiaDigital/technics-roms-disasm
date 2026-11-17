#!/usr/bin/env python3
"""drop_link_routines.py POOLFILE [POOLFILE ...]

Which routines use a `link` / `unlk` frame, and so cannot be V4.23 output?  Take them out of the helpers' pools.

QUESTION ANSWERED / WHY: the WSA1R lane found code compiled by a compiler other than the cc900 we hold: frames built
with `link xiz,-N` / `unlk xiz`, arguments at (xiz+8).  No oracle listing of V4.23 has ever contained link / unlk,
so no C can reproduce such a routine.  This scans the hand sources of all five main-CPU trees (v10 v9 v7 v6 v5,
every .s under <tree>/maincpu, read as bytes) and collects each label whose block -- the lines up to the next
column-0 label -- holds a `link` or `unlk` instruction.  Each POOLFILE row naming such a label is dropped; the
original is kept beside it as POOLFILE.withlink (written once, never overwritten), and the counts are printed.
Deletes nothing.

usage: python3 -B notes/cc900-phase6-2026-11-16/drop_link_routines.py ~/compartilhado/tmp/cc900-tab/lane_p6/scan/pool*.txt
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
LABEL = re.compile(rb'^([A-Za-z_]\w*):')
LINK = re.compile(rb'^\s+(link|unlk)\b', re.I)
NAME = re.compile(r'\b[A-Za-z_]\w*\b')


def link_routines():
    found = {}
    for tree in ('v10', 'v9', 'v7', 'v6', 'v5'):
        root = os.path.join(REPO, tree, 'maincpu')
        for dp, dn, fn in os.walk(root):
            dn[:] = [d for d in dn if d != 'generated']
            for f in fn:
                if not f.endswith('.s'):
                    continue
                cur = None
                for line in open(os.path.join(dp, f), 'rb').read().split(b'\n'):
                    m = LABEL.match(line)
                    if m:
                        cur = m.group(1).decode()
                        rest = line[m.end():]
                        if LINK.match(b'\t' + rest.strip()):
                            found.setdefault(cur, set()).add(tree)
                    elif cur and LINK.match(line):
                        found.setdefault(cur, set()).add(tree)
    return found


def main():
    found = link_routines()
    print('routines with link / unlk in the five trees: %d (v10: %d)'
          % (len(found), sum(1 for t in found.values() if 'v10' in t)))
    sys.path.insert(0, HERE)
    import new_pool                                          # noqa: E402
    built = set()
    for t in ('v10', 'v9', 'v7', 'v6', 'v5'):
        built |= new_pool.defined_in(os.path.join(REPO, t, 'maincpu', 'cc900'))
        built |= new_pool.defined_in(os.path.join(REPO, t, 'maincpu', 'cc900-staged'))
    clash = sorted(set(found) & built)
    print('of them already built or staged as C: %d %s' % (len(clash), ' '.join(clash)))
    total = 0
    for path in sys.argv[1:]:
        text = open(path).read()
        keep, drop = [], []
        for row in text.split('\n'):
            hit = [n for n in NAME.findall(row) if n in found]
            (drop if hit else keep).append(row)
        if not drop:
            print('%-40s dropped 0' % os.path.basename(path))
            continue
        backup = path + '.withlink'
        if not os.path.exists(backup):
            open(backup, 'w').write(text)
        open(path, 'w').write('\n'.join(keep))
        total += len(drop)
        print('%-40s dropped %d: %s' % (os.path.basename(path), len(drop),
                                        ' '.join(sorted({n for r in drop for n in NAME.findall(r) if n in found}))))
    print('total rows dropped: %d' % total)


if __name__ == '__main__':
    main()
