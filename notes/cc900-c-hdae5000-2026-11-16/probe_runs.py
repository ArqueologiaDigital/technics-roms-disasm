#!/usr/bin/env python3
"""Which probe files of lane_hd were never compiled by an oracle run?

QUESTION ANSWERED: every probes/*.c should have gone through V4.23 at least once.  A run keeps each compiled file as
out/<compiler>/<options>/<dir>/<stem>.asm (or <stem>.cc.log when V4.23 refused it).  This lists the probe stems that
no `*hd-r*` run under the oracle's runs directory holds, so a handoff can say which probes are unrun.

    python3 -B notes/cc900-c-hdae5000-2026-11-16/probe_runs.py [--runs DIR]
Run from the repository root.  Default DIR: ~/compartilhado/cc900-oracle/runs.  Prints only file names.
"""
import glob, os, sys

HERE = os.path.dirname(os.path.abspath(__file__))


def main():
    a = sys.argv[1:]
    runs = a[a.index('--runs') + 1] if '--runs' in a else os.path.expanduser('~/compartilhado/cc900-oracle/runs')
    seen = set()
    for run in glob.glob(os.path.join(runs, '*hd-r*')):
        for root, _, files in os.walk(os.path.join(run, 'out')):
            for f in files:
                if f.endswith('.asm'):
                    seen.add(f[:-4])
                elif f.endswith('.cc.log'):
                    seen.add(f[:-7])
    probes = sorted(os.path.basename(p)[:-2] for p in glob.glob(os.path.join(HERE, 'probes', '*.c')))
    unrun = [p for p in probes if p not in seen]
    for p in unrun:
        print('not run: probes/%s.c' % p)
    print('%d probe files, %d compiled by some hd-r run, %d not' % (len(probes), len(probes) - len(unrun), len(unrun)))


if __name__ == '__main__':
    main()
