#!/usr/bin/env python3
"""What selects MidiNote_OnByPartMode's arms, and what does arm 0xC0 do?  (N-fa489241, N-33cdb04f)

Asserted (exit 0 = PASS):
  * MidiNote_OnByPartMode reads `(part+0x00)->+0x10 & 0xC0` (0xFB3872 / 0xFB3877 / 0xFB387A);
  * Part_LoadToneRecordAndPointers stores Part_ResolveToneRecord's result at part+0x00 (0xFB47EE)
    and switches on the same byte (0xFB47F3 / 0xFB47F6); the only six 32-bit stores into the
    0x1523 part-record array are that one and five into element sub-records (+0x88, +0x8C, +0x90+4k);
  * prom_d's 274 tone heads carry +0x10 in {0x10: 248, 0x00: 6, 0x80: 18, 0x71: 2} -- so mode
    0x00 melodic, 0x40 drawbar (the two Drawbar tones), 0x80 drum kit, and 0xC0 never;
  * the 0xC0 / default arm 0xFB3C0E..0xFB3C27 is the common exit only: no call, one store
    `andw (xbc+5411), 0xfff3` = part word +0x04 &= ~0x000C.
Run: python3 notes/open4-a-probes/part_mode_kind.py
"""
import collections, os, re, struct, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prom_c_callgraph as g

ADDR = re.compile(rb';\s*([0-9A-F]{6})\b')
rows = []
for raw, code in g.lines():
    a = ADDR.search(raw)
    m = g.LABEL.match(code)
    c = (code[m.end():] if m else code).strip().decode('latin1')
    if a and c:
        rows.append((int(a.group(1), 16), c))
at = dict(rows)
fail = 0
for a, t in ((0xFB3872, 'ld\txwa, (xbc+0x1523)'), (0xFB3877, 'ld\tc, (xwa+16)'), (0xFB387A, 'and\tc, 0xC0'),
             (0xFB47DC, 'calr Part_ResolveToneRecord'), (0xFB47EE, 'ld\t(xbc+0x1523), xiy'),
             (0xFB47F3, 'ld\ta, (xiy+16)'), (0xFB47F6, 'and\ta, 0xC0'), (0xFB3898, 'jrl MidiNote_OnByPartMode__FB3C0E')):
    if not at.get(a, '').startswith(t):
        fail += 1
        print('FAIL %06X want %r have %r' % (a, t, at.get(a)))
st = [(a, c) for a, c in rows if re.match(r'ld\t\(x\w\w\+0x1523\), x\w\w$', c)]
print('32-bit stores into the 0x1523 array:', ['%06X' % a for a, _ in st])
if [a for a, _ in st] != [0xFB47B7, 0xFB47EE, 0xFB484E, 0xFB486B, 0xFB48C1, 0xFC2952]:
    fail += 1
    print('FAIL: the 32-bit store census moved')
for a, sub in ((0xFB47B7, 'add\tbc, 0x90'), (0xFB484E, 'add\tbc, 0x88'), (0xFB486B, 'add\tbc, 0x8C'),
               (0xFB48C1, 'add\tbc, 0x88'), (0xFC2952, 'add\twa, 0x8C')):
    i = [r[0] for r in rows].index(a)
    if not any(rows[j][1].startswith(sub) for j in range(i - 3, i)):
        fail += 1
        print('FAIL: %06X is not an element sub-record store' % a)
arm = [c for a, c in rows if 0xFB3C0E <= a <= 0xFB3C27]
if any(c.startswith(('call', 'calr')) for c in arm) or not any(c.startswith('andw\t(xbc+5411), 0xfff3') for c in arm):
    fail += 1
    print('FAIL: arm 0xFB3C0E is not the bare exit:', arm)
print('arm 0xFB3C0E:', ' / '.join(arm))
d = open(os.path.join(g.ROOT, 'original_ROMs/wsa1_prom_d.bin'), 'rb').read()
kinds = collections.Counter(d[struct.unpack_from('<I', d, 0xB80 + 4 * i)[0] + 0x10] for i in range(274))
print('prom_d tone kind (+0x10):', {hex(k): n for k, n in sorted(kinds.items())})
if kinds != {0x10: 248, 0x00: 6, 0x80: 18, 0x71: 2}:
    fail += 1
    print('FAIL: kind census moved')
print('FAILURES:', fail)
sys.exit(1 if fail else 0)
