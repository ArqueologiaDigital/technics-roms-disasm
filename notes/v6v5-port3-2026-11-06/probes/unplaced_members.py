#!/usr/bin/env python3
"""unplaced_members.py TREE BIN PATTERN -- which top-level members of TREE's C blob BIN whose name matches
the regular expression PATTERN reach the image?  For each member: its offset range in the compiled blob
(DWARF of the C compiled with -g) and the .incbin slices of TREE that place any of its bytes ("placed by
[]" = none: the member's bytes never reach the ROM, so what the C compiles there is don't-care).

Used for N-2a3d2074: v6 / v5 have no MPVersion view, and RAM_MPVersion_Window is named only by the
MPVersion records of naka_technichord_part.c, which no slice of v6 / v5 places.

RUN (repository root)
    python3 notes/v6v5-port3-2026-11-06/probes/unplaced_members.py v6 naka_technichord_part.bin MPVersion
"""
import os
import re
import sys

ROOT = os.getcwd()
sys.path.insert(0, os.path.join(ROOT, 'scripts', 'converters'))
import ported_c_rebase as R                                                    # noqa: E402

PROBE = os.path.join(ROOT, 'notes', 'v6v5-port2-2026-11-06', 'probes', 'rawsites.py')


def main():
    tree, name, pat = sys.argv[1], sys.argv[2], re.compile(sys.argv[3])
    ns = {'__name__': 'rawsites_lib'}
    exec(open(PROBE).read().split('\ntree, need')[0], ns)      # rawsites.members(), without its main
    _, mem = ns['members'](tree, name)
    placed = R.placed(tree).get(name, [])
    for i, (o, n) in enumerate(mem):
        if not pat.search(n):
            continue
        end = mem[i + 1][0] if i + 1 < len(mem) else None
        hit = [(a, b) for a, b in placed if (b is None or b > o) and (end is None or a < end)]
        print('%s %s %-32s 0x%04x..0x%s  placed by %s' % (tree, name, n, o, '%04x' % end if end else 'end',
                                                         ['0x%x+0x%x' % (a, (b or 0) - a) for a, b in hit]))


if __name__ == '__main__':
    main()
