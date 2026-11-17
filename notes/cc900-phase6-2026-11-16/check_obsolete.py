#!/usr/bin/env python3
"""check_obsolete.py FILE.c [FILE.c ...]

Is a staging file restage_modules.py calls "obsolete" really redundant?  For each named file of
v10/maincpu/cc900-staged/, every function it defines must also be defined by another .c file of that directory
(the module file restage_modules.py wrote).  Prints `ok FILE` or `MISSING FILE: function ...`, and exits 1 when
anything is missing, so the file is removed (by hand, one standalone `rm` with its literal path) only after `ok`.
Deletes nothing itself.

usage: python3 -B notes/cc900-phase6-2026-11-16/check_obsolete.py audio_control_engine.c ...   (from the repo root)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
SDIR = os.path.join(REPO, 'v10', 'maincpu', 'cc900-staged')
sys.path.insert(0, HERE)
import stage_probe as sp                                     # noqa: E402


def fns(path):
    return {sp.fn_name(d) for k, d in sp.items(open(path, encoding='latin-1').read()) if k == 'fn'}


def main():
    names = [os.path.basename(a) for a in sys.argv[1:]]
    others = {}
    for f in os.listdir(SDIR):
        if f.endswith('.c') and f not in names:
            others[f] = fns(os.path.join(SDIR, f))
    have = set().union(*others.values()) if others else set()
    bad = 0
    for n in names:
        miss = sorted(fns(os.path.join(SDIR, n)) - have)
        if miss:
            bad = 1
            print('MISSING %s: %s' % (n, ' '.join(miss)))
        else:
            print('ok %s' % n)
    sys.exit(bad)


if __name__ == '__main__':
    main()
