#!/usr/bin/env python3
"""Append a probe run's matches to probe_matches.tsv, the ledger restage_modules.py reads.

QUESTION ANSWERED / WHY: which probe (and option set) gave each function's ROM bytes, per oracle run, so the staging
can take that probe's declarations.  Reads probe_v423.py --tsv output; skips rows already in the ledger.

usage: python3 -B notes/cc900-phase6-2026-11-16/append_matches.py RESULT.tsv RUN_NAME
"""
import os, sys

LEDGER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'probe_matches.tsv')


def main():
    res, run = sys.argv[1], sys.argv[2]
    have = set(l.rstrip('\n') for l in open(LEDGER))
    new = []
    for l in open(res):
        c = l.rstrip('\n').split('\t')
        if len(c) >= 3 and c[0] != 'function' and c[2] != '-':
            row = '\t'.join([c[0], c[1], run, c[2]])
            if row not in have:
                new.append(row)
    with open(LEDGER, 'a') as fh:
        for r in new:
            fh.write(r + '\n')
    print('%d rows added to %s' % (len(new), os.path.basename(LEDGER)))


if __name__ == '__main__':
    main()
