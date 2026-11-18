#!/usr/bin/env python3
"""Does scripts/analysis/cc900/c_build_coverage.py credit every built HD-AE5000 function?

QUESTION ANSWERED: runs c_build_coverage.firmware() for the v2.06i tree only (no census, a few minutes) and prints,
per C function, the verdict and bytes it would write into results/c_build_coverage.md, then the functions the tree
builds (`built`) that it does NOT credit as V4.23 MATCH.  Written 2026-11-18 to check the cc900-data / cc900-name fix
(HDAE5000_SeparateOutputModeCheck was credited 0 B).

    python3 -B notes/cc900-c-hdae5000-2026-11-16/coverage_hd_rows.py [TREE_KEY]   (default hdae5000)
Run from the repository root after a build (it reads the build's V4.23 cache, build/cc900-v423).
"""
import os
import sys

REPO = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
sys.path.insert(0, os.path.join(REPO, 'scripts', 'analysis', 'cc900'))
import c_build_coverage as C                                  # noqa: E402

key = sys.argv[1] if len(sys.argv) > 1 else 'hdae5000'
img = next(i for i in C.IMAGES if i[0] == key)
rows = C.firmware(key, img[2], img[3], img[4])
bad = [r for r in rows if r['built'] and r['V4.23'] is not True]
for r in rows:
    if 'SeparateOutput' in r['function']:
        print('%-40s %-8s %5d B  %s' % (r['function'], r['V4.23'], r['bytes'], r['file']))
print('%s: %d functions, %d built, %d built and V4.23 MATCH, %d B' % (
    key, len(rows), sum(r['built'] for r in rows), sum(r['built'] and r['V4.23'] is True for r in rows),
    sum(r['bytes'] for r in rows if r['built'] and r['V4.23'] is True)))
for r in bad:
    print('NOT CREDITED  %s  %s  (%s)' % (r['function'], r['file'], r['V4.23']))
