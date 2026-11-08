#!/usr/bin/env python3
"""Compare Toshiba's TMP94C241 SFR header (Io900h2.h, kit CD IDE) with our sfr_tmp94c241.s, by address.

usage: python3 -I sfr_compare.py IO900H2.H OUR_SFR.s [--md]
Toshiba lines: `extern unsigned char __io(0xNN) NAME;` or `#pragma io NAME 0xNN`; ours: `.equ NAME, 0xNN`.  Prints counts (same name, other
name, only Toshiba, only ours) and, with --md, a Markdown table of the addresses where they differ.
"""
import re, sys, collections

def main():
    th, ours = sys.argv[1], sys.argv[2]
    t = collections.defaultdict(list)
    for m in re.finditer(r'__io\((0x[0-9a-fA-F]+)\)\s+(\w+)\s*;\s*(?:/\*\s*(.*?)\s*\*/)?', open(th, encoding='latin-1').read()):
        t[int(m.group(1), 16)].append((m.group(2), m.group(3) or ''))
    for m in re.finditer(r'#pragma\s+io\s+(\w+)\s+(0x[0-9a-fA-F]+)\s*(?:/\*\s*(.*?)\s*\*/)?', open(th, encoding='latin-1').read()):
        t[int(m.group(2), 16)].append((m.group(1), m.group(3) or ''))   # older headers: #pragma io NAME 0xNN
    o = collections.defaultdict(list)
    for m in re.finditer(r'^\s*\.equ\s+(\w+)\s*,\s*(0x[0-9a-fA-F]+|\d+)\s*(?:;.*)?$', open(ours, encoding='latin-1').read(), re.M):
        v = int(m.group(2), 0)
        if v < 0x200: o[v].append(m.group(1))   # the SFR area
    same = other = only_t = only_o = 0; diff = []
    for a in sorted(set(t) | set(o)):
        tn = [n for n, _ in t.get(a, [])]; on = o.get(a, [])
        if tn and on:
            if set(tn) & set(on): same += 1
            else: other += 1; diff.append((a, tn, on, t[a][0][1]))
        elif tn: only_t += 1; diff.append((a, tn, [], t[a][0][1]))
        else: only_o += 1; diff.append((a, [], on, ''))
    print('Toshiba %d addresses, ours %d (< 0x200): same name %d, other name %d, only Toshiba %d, only ours %d'
          % (len(t), len(o), same, other, only_t, only_o))
    if '--md' in sys.argv:
        rows = [('address', 'Toshiba header', 'ours', 'Toshiba comment')] + \
               [('0x%02x' % a, ' / '.join(tn) or '-', ' / '.join(on) or '-', c) for a, tn, on, c in diff]
        w = [max(len(r[i]) for r in rows) for i in range(4)]
        for k, r in enumerate(rows):
            print('| ' + ' | '.join(c.ljust(x) for c, x in zip(r, w)) + ' |')
            if k == 0: print('|' + '|'.join('-' * (x + 2) for x in w) + '|')

main()
