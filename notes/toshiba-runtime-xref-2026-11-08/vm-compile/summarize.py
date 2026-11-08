#!/usr/bin/env python3
"""The per-option-set counts of ../README.md's "Running V4.23" table, from compare_vm.py's output.

usage: python3 -I -B summarize.py ../results/vm_compile.md
Per option set: how many pieces it compiled, how many are byte-identical (relocations masked) to the 1997 / 2003 / 2008
library's piece of the same name ("=" in those columns), and how many have an exact hit in at least one image.  Then,
for -O3 -XS, every piece that is not the 1997 library's.
"""
import sys

ORDER = [('default', '(none)'), ('O1', '`-O1`'), ('O2', '`-O2`'), ('O3', '`-O3`'), ('XS', '`-XS`'),
         ('O2XS', '`-O2 -XS`'), ('O3XS', '`-O3 -XS`')]
rows = [[c.strip() for c in l.strip().strip('|').split('|')] for l in open(sys.argv[1])
        if l.startswith('| ') and not l.startswith('| options')]
rows = [r for r in rows if len(r) == 10]
out = [('options', 'pieces', '= 1997', '= 2003', '= 2008', 'exact hits in our images')]
for lab, name in ORDER:
    rr = [r for r in rows if r[0] == lab]
    out.append((name, str(len(rr)), str(sum(r[7] == '=' for r in rr)), str(sum(r[8] == '=' for r in rr)),
                str(sum(r[9] == '=' for r in rr)), str(sum(r[4] != '0' for r in rr))))
w = [max(len(r[i]) for r in out) for i in range(len(out[0]))]
for k, r in enumerate(out):
    print('| ' + ' | '.join(c.ljust(x) for c, x in zip(r, w)) + ' |')
    if k == 0: print('|' + '|'.join('-' * (x + 2) for x in w) + '|')
print('\n-O3 -XS pieces that are not the 1997 library\'s:')
for r in rows:
    if r[0] == 'O3XS' and r[7] != '=': print('  %s %s B: vs 1997 %s, vs 2003 %s' % (r[2], r[3], r[7], r[8]))
