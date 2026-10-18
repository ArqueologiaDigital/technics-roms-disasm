#!/usr/bin/env python3
"""Align a GFM table: reads '|'-separated rows on stdin (first row = header), prints a padded table."""
import sys
rows = [[c.strip() for c in l.strip().strip('|').split('|')] for l in sys.stdin if l.strip()]
w = [max(len(r[i]) for r in rows) for i in range(len(rows[0]))]
fmt = lambda r: '| ' + ' | '.join(c.ljust(w[i]) for i, c in enumerate(r)) + ' |'
print(fmt(rows[0])); print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
for r in rows[1:]: print(fmt(r))
