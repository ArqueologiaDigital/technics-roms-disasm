#!/usr/bin/env python3
"""phase6_counts.py -- how many main-CPU functions are built from C, staged, or probed?

QUESTION ANSWERED: the final state for the handoff (HANDOFF-2026-11-17.md), from the files themselves:
  built    functions defined in <tree>/maincpu/cc900/*.c (compiled by V4.23 in the build)
  staged   functions defined in <tree>/maincpu/cc900-staged/*.c (checked or waiting for a check)
  probed   v10 routines some p6_*.c probe defines (scripts/analysis/cc900/corpus/firmware/)
  matched  distinct functions probe_matches.tsv records as matched by an oracle run
Prints one line per tree and the probe totals.

usage: python3 -B notes/cc900-phase6-2026-11-16/phase6_counts.py      (from the repository root)
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, '..', '..'))
sys.path.insert(0, HERE)
import new_pool                                              # noqa: E402


def main():
    for t in ('v10', 'v9', 'v7', 'v6', 'v5'):
        built = new_pool.defined_in(os.path.join(REPO, t, 'maincpu', 'cc900'))
        staged = new_pool.defined_in(os.path.join(REPO, t, 'maincpu', 'cc900-staged'))
        print('%-4s built %4d   staged %3d' % (t, len(built), len(staged - built)))
    probes = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'corpus', 'firmware')
    probed = new_pool.defined_in(probes, 'p6_')
    nfiles = sum(1 for f in os.listdir(probes) if f.startswith('p6_') and f.endswith('.c'))
    matched = set()
    for line in open(os.path.join(HERE, 'probe_matches.tsv')):
        c = line.split('\t')
        if len(c) >= 3 and c[0] != 'function':
            matched.add(c[0])
    built10 = new_pool.defined_in(os.path.join(REPO, 'v10', 'maincpu', 'cc900'))
    print('probe files %d, routines probed %d, matched by a run %d, of the probed not built in v10 %d'
          % (nfiles, len(probed), len(matched), len(probed - built10)))


if __name__ == '__main__':
    main()
