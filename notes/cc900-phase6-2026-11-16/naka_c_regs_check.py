#!/usr/bin/env python3
"""naka_c_regs_check.py TREE -- does nakarest_objtab_map.py read the NAKA registrations from the staged firmware C
exactly as it reads them from the hand source's RegObjTable lines?

QUESTION ANSWERED / WHY: gen_naka_gui_headers.py and naka_gui_model.py build the NAKA headers from the registration
records of the Initialize* routines.  Once a routine is built from C, its records come from Map._from_c() (the C)
instead of the macro lines (2026-11-22).  For every Initialize* routine that TREE's cc900-staged/*.c defines, this
compares the records parsed from the hand source (cls, proc, count, table, slot, count_at; in order) with those
_from_c() reads from the staged C, and prints `same` / `DIFF` per routine.  Exit 1 on any DIFF or missing routine.

usage: python3 -B notes/cc900-phase6-2026-11-16/naka_c_regs_check.py v10      (from the repository root; needs make)
"""
import glob
import os
import re
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'analysis'))
import nakarest_objtab_map as nm                               # noqa: E402

KEYS = ('cls', 'proc', 'count', 'table', 'slot', 'count_at')


def main():
    tree = sys.argv[1]
    m = nm.Map(tree)
    hand = {}
    for r in m.regs:
        hand.setdefault(r['init'], []).append(tuple(r.get(k) for k in KEYS))
    bad = 0
    for p in sorted(glob.glob(os.path.join(REPO, tree, 'maincpu', 'cc900-staged', '*.c'))):
        src = open(p, encoding='latin-1').read()
        alias = {a.group(1): a.group(2) for a in re.finditer(r'cc900-name:\s*(\w+)\s*=\s*(\w+)', src)}
        for f in re.findall(r'^void\s+(Initialize\w+)\s*\(', src, re.M):
            label = alias.get(f, f)
            before = len(m.regs)
            m._from_c(p, label, 'staged', 0)
            got = [tuple(r.get(k) for k in KEYS) for r in m.regs[before:]]
            del m.regs[before:]
            ok = got == hand.get(label, [])
            bad += not ok
            print('%-4s %-22s %s  (%d records from C, %d from the hand source)'
                  % ('same' if ok else 'DIFF', label, os.path.basename(p), len(got), len(hand.get(label, []))))
            if not ok:
                h = hand.get(label, [])
                print('     only in the hand source: %s' % [r for r in h if r not in got][:4])
                print('     only in the C: %s' % [r for r in got if r not in h][:4])
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
