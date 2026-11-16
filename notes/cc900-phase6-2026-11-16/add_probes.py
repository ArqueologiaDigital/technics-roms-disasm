#!/usr/bin/env python3
"""Add probe files to an oracle corpus directory (made by staged_v423.py --corpus or empty).

QUESTION ANSWERED / WHY: one VM run per round compiles the staged C of every tree and the helpers' new probe files
together.  This copies each named probe (scripts/analysis/cc900/corpus/firmware/<stem>.c, which must be committed:
lane_nmx matches a run's sources by SHA-256) into DIR/firmware/, appends it to DIR/sources.txt, checks it with
gcc -fsyntax-only -std=c89, and makes sure DIR/options.txt holds the three option sets.

usage: python3 -B notes/cc900-phase6-2026-11-16/add_probes.py DIR STEM|@STEMFILE [STEM ...]
"""
import os, shutil, subprocess, sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
PROBES = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
SETS = ['O3Xr|-O3 -Xr', 'Xr|-Xr', 'O3XSXr|-O3 -XS -Xr']


def main():
    d, stems = sys.argv[1], []
    for s in sys.argv[2:]:                  # @FILE: one stem per line (no shell substitution needed)
        stems += open(s[1:]).read().split() if s.startswith('@') else [s]
    os.makedirs(os.path.join(d, 'firmware'), exist_ok=True)
    src = os.path.join(d, 'sources.txt')
    have = open(src).read().split() if os.path.exists(src) else []
    bad = 0
    with open(src, 'a') as fh:
        for s in stems:
            p = os.path.join(PROBES, s + '.c')
            r = subprocess.run(['gcc', '-fsyntax-only', '-std=c89', '-D__near=', '-D__tiny=', '-D__cdecl=', p],
                               capture_output=True, text=True)
            if 'error' in r.stderr:
                print('%s: gcc reports errors, left out' % s); bad += 1; continue
            git = subprocess.run(['git', 'ls-files', '--error-unmatch', p], capture_output=True, cwd=REPO)
            if git.returncode:
                print('%s: not committed, left out' % s); bad += 1; continue
            shutil.copyfile(p, os.path.join(d, 'firmware', s + '.c'))
            if 'firmware/%s.c' % s not in have:
                fh.write('firmware/%s.c\n' % s)
    opt = os.path.join(d, 'options.txt')
    cur = open(opt).read().split('\n') if os.path.exists(opt) else []
    with open(opt, 'a') as fh:
        for x in SETS:
            if x not in cur:
                fh.write(x + '\n')
    print('%d probes added to %s (%d left out)' % (len(stems) - bad, d, bad))


if __name__ == '__main__':
    main()
