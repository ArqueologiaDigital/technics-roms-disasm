#!/usr/bin/env python3
"""side.py DIFF [SHIFT] : rebuild ours / rom instruction sequences from an idiff_full.py unified diff (filtered
to its diff lines) and print them side by side, numbered, XSP offsets in decimal, SHIFT (default 0) added to ours
(the ROM's frame minus ours).  '*' marks a line that still differs after the shift; jump displacements are ignored."""
import re, sys

ours, rom = [], []
for l in open(sys.argv[1]):
    if l.startswith('####') or l.startswith('  ---') or l.startswith('  +++') or l.startswith('  @@'):
        continue
    if l.startswith('  -'):
        ours.append(l[3:].rstrip())
    elif l.startswith('  +'):
        rom.append(l[3:].rstrip())
    elif l.startswith('   '):
        ours.append(l[3:].rstrip()); rom.append(l[3:].rstrip())
shift = int(sys.argv[2]) if len(sys.argv) > 2 else 0


def norm(s, k):
    s = re.sub(r'XSP\+0x([0-9a-f]+)', lambda m: 'XSP+%d' % (int(m.group(1), 16) + k), s)
    return re.sub(r'L\+\d+', 'L', s)


n = max(len(ours), len(rom))
for i in range(n):
    a = norm(ours[i], shift) if i < len(ours) else ''
    b = norm(rom[i], 0) if i < len(rom) else ''
    print('%4d %s %-36s %s' % (i, ' ' if a == b else '*', a, b))
