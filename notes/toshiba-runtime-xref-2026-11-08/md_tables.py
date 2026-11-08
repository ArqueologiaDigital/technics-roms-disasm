#!/usr/bin/env python3
"""Markdown tables for the note, from xref_runtime.py's outputs.

usage: python3 -I md_tables.py XREF.resolved.tsv XREF.inferred.tsv [IMAGE ...]
Prints, for each IMAGE (default: maincpu v10, subcpu v142, table data, hdae v2.06i, wsa1 prom_a), a table of exact
hits (address, Toshiba name, length, our label, libraries, check) and one of names inferred from their calls.
Then a count table: hits per image and which library builds they match.
"""
import sys, collections

def table(rows, head):
    w = [max(len(str(r[i])) for r in rows + [head]) for i in range(len(head))]
    out = ['| ' + ' | '.join(str(c).ljust(x) for c, x in zip(head, w)) + ' |',
           '|' + '|'.join('-' * (x + 2) for x in w) + '|']
    out += ['| ' + ' | '.join(str(c).ljust(x) for c, x in zip(r, w)) + ' |' for r in rows]
    return '\n'.join(out)

def tick(s): return '`%s`' % s

def main():
    res = [l.split('\t') for l in open(sys.argv[1]).read().splitlines()[1:]]
    inf = [l.split('\t') for l in open(sys.argv[2]).read().splitlines()[1:]]
    imgs = sys.argv[3:] or ['maincpu v10', 'subcpu v142', 'table data', 'hdae v2.06i', 'wsa1 prom_a']
    for im in imgs:
        rows = [('0x' + r[1], ' / '.join(tick(n.strip()) for n in r[2].split('|')), r[3], tick(r[4]), r[5].replace(',', ', '), r[6])
                for r in res if r[0] == im]
        print('#### %s: exact hits (%d)\n' % (im, len(rows)))
        print(table(rows, ('address', 'Toshiba name', 'bytes', 'our label', 'library builds', 'check')) + '\n')
        rows = [('0x' + r[1], tick(r[2]), tick(r[3]), tick(r[4]) if r[4] != '?' else '(no label)') for r in inf if r[0] == im]
        if rows:
            print('#### %s: names read from those routines\' calls and pointers (%d)\n' % (im, len(rows)))
            print(table(rows, ('address', 'Toshiba name', 'referenced from', 'our label')) + '\n')
    c = collections.OrderedDict()
    for r in res:
        ide, v = 'IDE' in r[5], 'v1.10' in r[5]
        k = c.setdefault(r[0], collections.Counter())
        k['both' if ide and v else 'IDE only' if ide else 'v1.10 only'] += 1
    print(table([(k, sum(v.values()), v['both'], v['IDE only'], v['v1.10 only']) for k, v in c.items()],
                ('image', 'exact hits', 'both builds', 'IDE (2003) only', 'v1.10 (2008) only')))

main()
