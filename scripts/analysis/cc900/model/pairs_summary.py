#!/usr/bin/env python3
"""Per-image summary of pairs_model.py's output: how many pairs each image has, and how many are byte-identical,
differ, or are not compiled yet; a pairs.tsv near match that is not identical has a column of its own (a second public at a pair's address, ___ctype, is not counted).  usage: python3 -I -B pairs_summary.py ../results/pairs_model_kn5000.tsv
Prints an aligned Markdown table (phase 7: a line per image)."""
import sys, collections
rows = [l.rstrip('\n').split('\t') for l in open(sys.argv[1])][1:]
t = collections.OrderedDict()
for r in rows:
    if len(r) < 6 or r[0].startswith('#') or r[5].startswith('alias of'): continue   # ___ctype = __ctype's bytes
    d = t.setdefault(r[0], collections.Counter())
    if len(r) > 6 and r[6] == 'near' and r[5] != 'MATCH':  # pairs.tsv's near matches (_sbrk inside the routine before
        d['near'] += 1; continue                           # .sbrk, the main CPU's _vsprintf at Sprintf_Unlocked+3)
    k = 'identical' if r[5] == 'MATCH' else 'differs' if 'diff' in r[5] else 'not compiled'
    d[k] += 1; d['pairs'] += 1
cells = [('image', 'pairs', 'identical', 'differ', 'not compiled yet', 'near match, unverified')]
cells += [(img, str(d['pairs']), str(d['identical']), str(d['differs']), str(d['not compiled']), str(d['near']))
          for img, d in t.items()]
w = [max(len(c[i]) for c in cells) for i in range(6)]
line = lambda c: '| ' + ' | '.join(x.ljust(w[i]) for i, x in enumerate(c)) + ' |'
print(line(cells[0])); print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
for c in cells[1:]: print(line(c))
