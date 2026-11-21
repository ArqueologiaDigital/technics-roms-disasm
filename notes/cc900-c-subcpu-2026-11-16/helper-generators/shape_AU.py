#!/usr/bin/env python3
"""shape.py FULLDIFF : do ours and the ROM differ only in frame offsets?  Rebuilds both sides of an IDIFF=--full
idiff_full.py diff, replaces every XSP offset by S and every branch displacement by L, and prints the remaining
differences (unified, 1 line of context), then the offset pairs (ours -> rom) seen at the same instruction index
when the shapes agree, with their counts."""
import collections, difflib, re, sys

ours, rom = [], []
for l in open(sys.argv[1]):
    if l.startswith('####') or l.startswith('  ---') or l.startswith('  +++') or l.startswith('  @@'):
        continue
    if l.startswith('  -'):
        ours.append(l[3:].strip())
    elif l.startswith('  +'):
        rom.append(l[3:].strip())
    elif l.startswith('   '):
        ours.append(l[3:].strip()); rom.append(l[3:].strip())


def norm(s):
    s = re.sub(r'XSP\+0x[0-9a-f]+', 'S', s)
    return re.sub(r'L\+\d+', 'L', s)


a = [norm(x) for x in ours]
b = [norm(x) for x in rom]
n = 0
for l in difflib.unified_diff(a, b, 'ours', 'rom', n=1, lineterm=''):
    print(l); n += 1
print('shape diff lines:', n)
pairs = collections.Counter()
if a == b:
    for x, y in zip(ours, rom):
        for p, q in zip(re.findall(r'XSP\+0x([0-9a-f]+)', x), re.findall(r'XSP\+0x([0-9a-f]+)', y)):
            if p != q or len(sys.argv) > 2:
                pairs[(int(p, 16), int(q, 16))] += 1
    for (p, q), c in sorted(pairs.items()):
        print('%4d -> %4d  x%d' % (p, q, c))
