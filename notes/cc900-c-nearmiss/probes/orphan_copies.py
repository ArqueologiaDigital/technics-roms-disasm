#!/usr/bin/env python3
"""QUESTION ANSWERED: which near-miss C copies under notes/cc900-c-nearmiss/c/ does no row of index.tsv or ready.tsv
name any more (`c_copy` column)?  They are candidates for `git rm` (nothing is deleted here).  2026-11-19: the runs
re-indexed after the HD tree fix wrote their older-HD copies under c/hdae5000_v.../, leaving c/hdae5000/ copies
behind.

usage: python3 -B notes/cc900-c-nearmiss/probes/orphan_copies.py [--list]"""
import glob
import os
import sys

NOTES = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def named(path):
    lines = open(path).read().splitlines()
    ci = lines[0].split('\t').index('c_copy')
    return {l.split('\t')[ci] for l in lines[1:] if l.strip()}


def main():
    used = named(os.path.join(NOTES, 'index.tsv')) | named(os.path.join(NOTES, 'ready.tsv'))
    files = sorted(os.path.relpath(p, NOTES) for p in glob.glob(os.path.join(NOTES, 'c', '*', '*.c')))
    orphans = [f for f in files if f not in used]
    if '--list' in sys.argv:
        for f in orphans:
            print(f)
    per = {}
    for f in orphans:
        per[f.split('/')[1]] = per.get(f.split('/')[1], 0) + 1
    print('%d copies, %d named by no index / ready row %s' % (len(files), len(orphans), per))


if __name__ == '__main__':
    main()
