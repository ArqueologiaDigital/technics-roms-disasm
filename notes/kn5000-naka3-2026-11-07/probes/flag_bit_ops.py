#!/usr/bin/env python3
"""flag_bit_ops.py -- which routines set, clear and test each bit of a RAM flag byte?

QUESTION ANSWERED
  For one or more RAM byte addresses (spelled as numbers or by any name in shared/ram_variables*.s), lists every
  instruction that touches each bit: `set n, (A)` / `res n, (A)` / `bit n, (A)` / `chg n, (A)`, `or (A), imm` /
  `and (A), imm`, and the read-modify-write form `ld r, (A)` followed (within 8 lines, same block) by
  `set/res/bit n, r` and `ld (A), r`.  Each line names the routine (the nearest label above that is not a
  `.L` local) and the file, so a per-bit name can cite who sets it, who clears it and who tests it.
RUN (repository root)
  python3 notes/kn5000-naka3-2026-11-07/probes/flag_bit_ops.py 0x28b2 0x28b3 [--tree v10] [--summary]
"""
import collections, glob, re, sys

args = [a for a in sys.argv[1:] if not a.startswith('--')]
tree = sys.argv[sys.argv.index('--tree') + 1] if '--tree' in sys.argv else 'v10'
if '--tree' in sys.argv:
    args.remove(tree)
addrs = [int(a, 16) for a in args]
names = collections.defaultdict(set)
for p in glob.glob('%s/maincpu/shared/ram_variables*.s' % tree):
    for m in re.finditer(r'\.equ\s+(\w+),\s*(0x[0-9a-fA-F]+)', open(p, 'rb').read().decode('latin-1')):
        names[int(m.group(2), 16)].add(m.group(1))


def spell(a):
    alts = ['0x0*%x' % a, '%d' % a] + sorted(names.get(a, ()))
    return r'\((?:%s)(?::8|:16|:24)?\)' % '|'.join(alts)


ops = collections.defaultdict(list)    # (addr, bit) -> [(kind, routine, file, line)]
other = collections.defaultdict(list)
for p in sorted(glob.glob('%s/maincpu/**/*.s' % tree, recursive=True)):
    if '/shared/ram_variables' in p:
        continue
    L = open(p, 'rb').read().decode('latin-1').split('\n')
    rout = '?'
    for i, raw in enumerate(L):
        l = raw.split(';')[0]
        mm = re.match(r'^([A-Za-z_]\w*):', l)
        if mm:
            rout = mm.group(1)
            continue
        for a in addrs:
            S = spell(a)
            if not re.search(S, l, re.I):
                continue
            where = (rout, p.split('/maincpu/')[1], i + 1)
            m1 = re.search(r'\b(set|res|bit|chg|tset)\s+(\d),\s*' + S, l, re.I)
            m2 = re.search(r'\b(or|and|xor)\s+' + S + r',\s*(0x[0-9a-f]+|\d+)', l, re.I)
            m3 = re.search(r'\bld\s+(\w+),\s*' + S, l, re.I)
            if m1:
                ops[(a, int(m1.group(2)))].append((m1.group(1).lower(),) + where)
            elif m2:
                v = int(m2.group(2), 0)
                for b in range(8):
                    if m2.group(1).lower() == 'or' and v >> b & 1:
                        ops[(a, b)].append(('set(or)',) + where)
                    if m2.group(1).lower() == 'and' and not v >> b & 1:
                        ops[(a, b)].append(('res(and)',) + where)
                    if m2.group(1).lower() == 'xor' and v >> b & 1:
                        ops[(a, b)].append(('chg(xor)',) + where)
            elif m3:
                r = m3.group(1).lower()
                seen = set()
                for j in range(i + 1, min(i + 9, len(L))):
                    lj = L[j].split(';')[0]
                    if re.match(r'^[A-Za-z_]\w*:', lj):
                        break
                    mb = re.search(r'\b(set|res|bit)\s+(\d),\s*(\w+)\s*$', lj.strip())
                    if mb and mb.group(3).lower() == r:
                        k = (mb.group(1).lower() + '(rmw)', int(mb.group(2)))
                        if k not in seen:
                            ops[(a, k[1])].append((k[0],) + where)
                            seen.add(k)
                    ma = re.search(r'\band\s+(\w+),\s*(0x[0-9a-f]+|\d+)\s*$', lj.strip())
                    if ma and ma.group(1).lower() == r:
                        v = int(ma.group(2), 0)
                        for b in range(8):
                            if v >> b & 1:
                                ops[(a, b)].append(('read(and %s)' % ma.group(2),) + where)
                        seen.add('and')
                    if re.search(r'\bld\s+\w+,\s*' + r'\b' + r + r'\b', lj) and r == 'a':
                        pass
                if not seen:
                    other[a].append(('ld %s' % r,) + where)
            else:
                other[a].append((l.strip(),) + where)
for a in addrs:
    print('== 0x%04x %s' % (a, ' '.join(sorted(names.get(a, ()))) or '(no name)'))
    for b in range(8):
        lst = ops.get((a, b), [])
        if '--summary' in sys.argv:
            c = collections.Counter(k.split('(')[0] for k, *_ in lst)
            print('  bit %d: %s' % (b, ', '.join('%s %d' % kv for kv in sorted(c.items())) or 'untouched'))
            continue
        print('  bit %d' % b)
        for k, r, f, n in lst:
            print('    %-14s %-48s %s:%d' % (k, r, f, n))
    if '--summary' not in sys.argv:
        print('  other uses')
        for k, r, f, n in other.get(a, []):
            print('    %-30s %-40s %s:%d' % (k, r, f, n))
