#!/usr/bin/env python3
"""The stage scores of the thc1 / thc2 rebuild (S1-S4) over time, for the cc900 dashboard.

QUESTION ANSWERED: how did each stage's exact count move, measurement by measurement?

    python3 -B scripts/analysis/cc900/stages/stage_scores.py backfill      # rewrite results/stage_scores.tsv from git
    python3 -B scripts/analysis/cc900/stages/stage_scores.py record STAGE EXACT TOTAL UNIT [NOTE]

Signal read.  `record` appends one row (now, HEAD, stage, exact, total, unit, note); the *_check.py scripts call it
under --record.  `backfill` takes the points the stage commits stated in their subjects before --record existed: S1 / S2
"-Xr N exact" (of 2,672 / 2,671 functions; S2's total was 2,671 from its start), S3 "N / M variables" or "N / 3,394",
S4 "N / 2,001 -Xr functions ... exact"; the measured totals are the ones the check scripts printed then.  A point is
the measurement quoted in a commit, so its time is that commit's author date.
"""
import os
import re
import subprocess
import sys
import time

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..'))
OUT = os.path.join(REPO, 'scripts', 'analysis', 'cc900', 'results', 'stage_scores.tsv')
HEAD = 'time\tcommit\tstage\texact\ttotal\tunit\tnote\n'
N = lambda s: int(s.replace(',', ''))


def backfill():
    log = subprocess.run(['git', '-C', REPO, 'log', '--reverse', '--format=%h%x09%aI%x09%s', '--',
                          'scripts/analysis/cc900/stages'], capture_output=True, text=True).stdout
    rows = []
    for l in log.splitlines():
        h, d, s = l.split('\t', 2)
        d = d[:19]
        m = re.search(r'S1\b.*?-Xr ([\d,]+) exact', s)
        if m:
            rows.append((d, h, 'S1', N(m.group(1)), 2672, 'functions', ''))
        m = re.search(r'S1\b.*?-Xr ([\d,]+) / 2,672', s)
        if m:
            rows.append((d, h, 'S1', N(m.group(1)), 2672, 'functions', ''))
        m = re.search(r'S2\b.*?-Xr ([\d,]+) (?:exact|/ 2,671)', s)
        if m:
            rows.append((d, h, 'S2', N(m.group(1)), 2671, 'functions', ''))
        m = re.search(r'S3\b.*?([\d,]+) / ([\d,]+) (?:named )?variables', s) or re.search(r'S3\b.*?([\d,]+) / (3,394)', s)
        if m:
            rows.append((d, h, 'S3', N(m.group(1)), N(m.group(2)), 'variables', ''))
        m = re.search(r'([\d,]+) / 2,001 -Xr functions(?:\' code)? exact', s)
        if m:
            rows.append((d, h, 'S4', N(m.group(1)), 2001, 'functions', ''))
    with open(OUT, 'w') as o:
        o.write(HEAD)
        for r in rows:
            o.write('\t'.join(str(x) for x in r) + '\n')
    print('%d points' % len(rows))


def record(stage, exact, total, unit, note=''):
    h = subprocess.run(['git', '-C', REPO, 'rev-parse', '--short', 'HEAD'], capture_output=True, text=True).stdout.strip()
    new = not os.path.exists(OUT)
    with open(OUT, 'a') as o:
        if new:
            o.write(HEAD)
        o.write('\t'.join([time.strftime('%Y-%m-%dT%H:%M:%S', time.gmtime()), h, stage, str(exact), str(total), unit,
                           note]) + '\n')


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[:1] == ['backfill']:
        backfill()
    elif a[:1] == ['record'] and len(a) >= 5:
        record(a[1], int(a[2]), int(a[3]), a[4], ' '.join(a[5:]))
    else:
        sys.exit(__doc__)
