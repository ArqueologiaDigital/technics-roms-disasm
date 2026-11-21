#!/usr/bin/env python3
"""slots.py FULLDIFF [ours|rom] : frame-slot map of one side of an IDIFF=--full idiff_full.py diff (filtered).

QUESTION: in which order did V4.23 (ours) and the ROM's compiler lay out the frame temporaries?  For every XSP
offset, normalised to the frame (bytes pushed since the last stack adjustment subtracted), print the slot, the
index of the instruction that first and last touches it, and that instruction.  push XIX / XWA = 4, pushw = 2;
a call followed by `lda XSP,XSP+N` is popped by the caller, any other call by the callee (retd)."""
import re, sys

side = sys.argv[2] if len(sys.argv) > 2 else 'ours'
seq = []
for l in open(sys.argv[1]):
    if l.startswith('####') or l.startswith('  ---') or l.startswith('  +++') or l.startswith('  @@'):
        continue
    if l.startswith('  -'):
        if side == 'ours':
            seq.append(l[3:].strip())
    elif l.startswith('  +'):
        if side == 'rom':
            seq.append(l[3:].strip())
    elif l.startswith('   '):
        seq.append(l[3:].strip())

depth = 0
first, last = {}, {}
for i, ins in enumerate(seq):
    if re.match(r'lda XSP,XSP\+0x', ins):
        continue
    for m in re.finditer(r'XSP\+0x([0-9a-f]+)', ins):
        off = int(m.group(1), 16) - depth
        first.setdefault(off, (i, ins))
        last[off] = (i, ins)
    if ins.startswith('push XIX') or ins.startswith('push XWA'):
        depth += 4
    elif ins.startswith('pushw'):
        depth += 2
    elif ins.startswith('call') or ins.startswith('calr'):
        depth = 0
for off in sorted(first, reverse=True):
    print('%4d  first %4d %-28s last %4d %s' % (off, first[off][0], first[off][1], last[off][0], last[off][1]))
