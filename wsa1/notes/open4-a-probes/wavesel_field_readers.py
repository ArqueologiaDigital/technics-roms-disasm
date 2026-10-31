#!/usr/bin/env python3
"""Who reads wave-select bytes p0, p1, p2 and p12?  (N-bfa65687, N-aa8525ae)

A WAVE-SELECT record (43 bytes, `Q`) reaches prom_c's code through three pointer sources:
  (a) part element +0x8C (0x1523 + 300*part + 41*e + 0x8C), the pointer Part_LoadToneRecordAndPointers
      stores at 0xFB486B;
  (b) P[+0x03] (Pack104_LoadElementWaveSelRec 0xFC6834), loaded back as `ld xRR,(xSS+3)`;
  (c) a routine's own (XIZ+0x08)/(XIZ+0x0A) argument when its callers pass (a) or (b) --
      named in ARG_ROUTINES below with the slot.
This probe tracks, per routine, a register loaded from (a)/(b)/(c) until it is overwritten, and
records every `(xRR+d)` operand on it.  It is a forward, intra-routine, register-only tracker:
a pointer spilled to the frame and reloaded is followed only for the (XIZ+d) frame slots it is
stored to and reloaded from in the same routine.  Its LIMITS are stated in the README.
Asserted (exit 0 = PASS):
  * VelSplit_LayerFromVelocity and _b read p0, p1, p2 (+0, +1, +2) as three velocity thresholds;
  * Pack104_UnpackWaveSelRec_ToSubRecord never reads +0, +1, +2 or +0x0C;
  * no tracked access reads +0x0C at all;
  * sub_FC578C reads +0x14 (p20), through P[+0x03] (0xFC588B);
  * in prom_d's three wave-select tables p0 <= p1 <= p2 always, and (127,127,127) in 579 of 594.
Run: python3 notes/open4-a-probes/wavesel_field_readers.py [--all]
"""
import os, re, sys
from collections import defaultdict
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prom_c_callgraph as g

ARG_ROUTINES = {          # routine -> frame slot holding a wave-select pointer on entry
    'VelSplit_LayerFromVelocity': 10, 'VelSplit_LayerFromVelocity_b': 10,
    'Pack104_UnpackWaveSelRec_ToSubRecord': 8, 'WaveSelRec_ResolveEnvDescriptor': 8,
}
ADDR = re.compile(rb';\s*([0-9A-F]{6})\b')
body = defaultdict(list)
cur = None
for raw, code in g.lines():
    m = g.LABEL.match(code)
    if m:
        if not g.is_local(m.group(1)):
            cur = m.group(1).decode()
        code = code[m.end():]
    a = ADDR.search(raw)
    c = code.strip().decode('latin1').lower()
    if c and not c.startswith('.') and cur:
        body[cur].append((int(a.group(1), 16) if a else 0, c))

reads = defaultdict(list)          # offset -> [(routine, addr, text)]
for r, ins in body.items():
    q = set()                     # registers holding Q
    slots = set()                 # frame slots holding Q
    if r in ARG_ROUTINES:
        slots.add(ARG_ROUTINES[r])
    pend8c = 0
    for i, (a, c) in enumerate(ins):
        mm = re.match(r'(\w+)\s+(.*)$', c)
        if not mm:
            continue
        mn, ops = mm.group(1), mm.group(2)
        dst = ops.split(',')[0].strip()
        # uses first
        for reg in list(q):
            for u in re.finditer(r'\(' + reg + r'(?:\+(-?\w+))?\)', ops):
                if u.group(1) and not re.fullmatch(r'-?(0x[0-9a-f]+|\d+)', u.group(1)):
                    continue                 # a register index, not a field offset
                off = int(u.group(1), 0) if u.group(1) else 0
                if not (mn.startswith('ld') and ops.startswith('(')):    # a load or a test, not a store
                    reads[off].append((r, a, c))
        # new Q registers
        if re.search(r'add\s+\w+,\s*0x8c$', c):
            pend8c = 4
        loaded = None
        m2 = re.match(r'ld\s+(x\w\w),\s*\((x\w\w)\+(0x1523|3|(\d+))\)$', c)
        if m2 and ((m2.group(3) == '0x1523' and pend8c) or (m2.group(3) == '3' and 'e084' in ' '.join(x for _, x in ins[max(0, i - 6):i]))):
            loaded = m2.group(1)
        m3 = re.match(r'ld\s+(x\w\w),\s*\(xiz\+(\d+)\)$', c)
        if m3 and int(m3.group(2)) in slots:
            loaded = m3.group(1)
        m4 = re.match(r'ld\s+\(xiz(-?\+?-?\d+)\),\s*(x\w\w)$', c)
        if m4 and m4.group(2) in q:
            slots.add(int(m4.group(1).replace('+', '')))
        if re.match(r'(ld|lda|add|sub|pop|ex|inc|dec)\b', mn) and dst in q and dst != loaded:
            q.discard(dst)
        if loaded:
            q.add(loaded)
        pend8c = max(0, pend8c - 1)

fail = 0
show = '--all' in sys.argv
for off in sorted(reads):
    rs = sorted({x[0] for x in reads[off]})
    if show or off in (0, 1, 2, 12, 20):
        print('+0x%02X  %3d reads  %s' % (off, len(reads[off]), ', '.join(rs)))
def readers(off):
    return {x[0] for x in reads.get(off, [])}
for v in ('VelSplit_LayerFromVelocity', 'VelSplit_LayerFromVelocity_b'):
    if not all(v in readers(o) for o in (0, 1, 2)):
        fail += 1
        print('FAIL:', v, 'does not read +0/+1/+2')
if any('Pack104_UnpackWaveSelRec_ToSubRecord' in readers(o) for o in (0, 1, 2, 12)):
    fail += 1
    print('FAIL: the unpacker reads p0/p1/p2/p12')
if reads.get(12):
    fail += 1
    print('FAIL: a tracked access reads +0x0C:', reads[12])
if not any(x[0] == 'sub_FC578C' and x[1] == 0xFC588B for x in reads.get(20, [])):
    fail += 1
    print('FAIL: sub_FC578C does not read +0x14 at 0xFC588B')
# the thresholds in prom_d's three wave-select tables (directory +0x18, +0x20, +0x3C)
dd = open(os.path.join(g.ROOT, 'original_ROMs/wsa1_prom_d.bin'), 'rb').read()
tri = [tuple(dd[base + 43 * i:base + 43 * i + 3]) for base, n in ((0x1D965, 322), (0x416AC, 208), (0x20F7B, 64)) for i in range(n)]
ones = sum(t == (127, 127, 127) for t in tri)
mono = all(t[0] <= t[1] <= t[2] for t in tri)
print('p0..p2 over %d wave-select records: (127,127,127) in %d; all non-decreasing: %s' % (len(tri), ones, mono))
if (len(tri), ones, mono) != (594, 579, True):
    fail += 1
    print('FAIL: threshold census moved')
print('FAILURES:', fail)
sys.exit(1 if fail else 0)
