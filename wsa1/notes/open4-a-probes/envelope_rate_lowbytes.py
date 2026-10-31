#!/usr/bin/env python3
"""Registers 0x0010C000 + 0x0840 / 0x0880 / 0x08C0: is the LOW byte from Voice_EnvelopeRate_Table,
as register 0x0800's is?  (N-216e88ae)

Anchors are instruction texts at ROM addresses in the converted prom_c sources; every one is
asserted.  The chain, A/B paths (Voice_StageRegs_0800_A, the B variants read the same offsets):

  segment 0  0x0800  low = RateTable[rec[+0x28]]                      0xFAA627 / 0xFAA62E
  segment 1  voice[+0x3B] = (lvl1 << 8) | max(4, RateTable[rec[+0x2A]])   0xFAA816 .. 0xFAA85F
             0x0840  = (voice[+0x3B] & 0xFF00) | clamp(voice[+0x3B]&0x7F +- PART[+0x1F], 4..0x7F)
                       (Voice_StageRegs_0840_0880_AB 0xFAA93C..0xFAA94D; unmodified copy 0xFAA959)
  segment 2  voice[+0x3D] = (lvl2 << 8) | RateTable[rec[+0x2C]]          0xFAA834 .. 0xFAA875
             0x0880  = (voice[+0x3D] & 0xFF00) | clamp(voice[+0x3D]&0x7F +- PART[+0x1F], 0..0x7F)
                       (0xFAA921..0xFAA935; copy 0xFAA961; 0x8000 | value when arg 2 != 0, 0xFAA917)
  0x08C0     NOT an envelope segment: low = DetuneCurve_LookupSigned(rec[+0x3D] + rec[+0x3E])
             (0xFA9614..0xFA9622 into (XIZ-2), packed at 0xFA96B5..0xFA96C3); high = a second
             DetuneCurve value (0xFA9676), or the low byte of staging word 16 = reg 0x0900 when
             voice[+0x01] & 0x0200 (0xFA96D9..0xFA96EC).
  C/D paths  Voice_StageRegs_0800_CD: segment-1/2 indices rec[+0x0B] / rec[+0x0D] (0xFAAB5F, 0xFAABA0).
PART[+0x1F] is read through voice[+0x23] = &part record (0xFAA8BE / 0xFAA8C3); the offset is applied
only when bit 8 of the word at (voice[+0x25])+0x18 is set and voice[+0x3D]'s low byte is non-zero
(0xFAA88F..0xFAA8A2), subtracted when its bit 9 is set (0xFAA8B1).
`rec` is the record voice[+0x17] points at (Voice_StageRegs_0800_A 0xFAA4CF, _0500_08C0_AB 0xFA95E0).
Also asserted: every Voice_EnvelopeRate_Table byte is <= 0x7F, so the `& 0x7F` loses nothing.
Exit 0 = PASS.  Run: python3 notes/open4-a-probes/envelope_rate_lowbytes.py
"""
import os, re, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import prom_c_callgraph as g

ANCHORS = [
    (0xFAA4CF, 'ld\txwa, (xbc+23)'), (0xFAA627, 'ld\ta, (xbc+40)'), (0xFAA62E, 'add\txwa, Voice_EnvelopeRate_Table'),
    (0xFAA816, 'ld\ta, (xbc+42)'), (0xFAA81D, 'add\txwa, Voice_EnvelopeRate_Table'), (0xFAA82A, 'cp\tix, 4:i3'),
    (0xFAA858, 'or\tbc, iy'), (0xFAA85F, 'ld\t(xwa+59), bc'),
    (0xFAA834, 'ld\ta, (xbc+44)'), (0xFAA83B, 'add\txwa, Voice_EnvelopeRate_Table'),
    (0xFAA86E, 'or\tbc, hl'), (0xFAA875, 'ld\t(xwa+61), bc'),
    (0xFAA93C, 'ld\tbc, (xde+59)'), (0xFAA941, 'and\thl, 0xFF00'), (0xFAA947, 'and\tbc, 0xFF'),
    (0xFAA94D, 'ld\t(0xD778:24), bc'), (0xFAA956, 'ld\tbc, (xde+59)'), (0xFAA959, 'ld\t(0xD778:24), bc'),
    (0xFAA923, 'ld\tbc, (xde+61)'), (0xFAA926, 'and\tbc, 0xFF00'), (0xFAA935, 'ld\t(0xD77A:24), bc'),
    (0xFAA917, 'set\t15, wa'), (0xFAA91A, 'ld\t(0xD77A:24), wa'), (0xFAA961, 'ld\t(0xD77A:24), bc'),
    (0xFA95E0, 'ld\txwa, (xbc+23)'), (0xFA9614, 'ld\th, (xbc+61)'), (0xFA9617, 'ld\ta, (xbc+62)'),
    (0xFA961F, 'calr DetuneCurve_LookupSigned'), (0xFA9622, 'ld\t(xiz-2), wa'),
    (0xFA9676, 'calr DetuneCurve_LookupSigned'), (0xFA96B5, 'ld\thl, (xiz-2)'), (0xFA96C3, 'ld\t(0xD77C:24), bc'),
    (0xFA962D, 'and\tiy, 0x200'), (0xFA96D9, 'ld\tbc, (0xD77E:24)'), (0xFA96EC, 'ld\t(0xD77C:24), bc'),
    (0xFAAB5F, 'ld\ta, (xbc+11)'), (0xFAAB66, 'add\txwa, Voice_EnvelopeRate_Table'),
    (0xFAABA0, 'ld\tc, (xwa+13)'), (0xFAABA7, 'add\txbc, Voice_EnvelopeRate_Table'),
]
ADDR = re.compile(rb';\s*([0-9A-F]{6})\b')
at = {}
table, intab = [], False
for raw, code in g.lines():
    a = ADDR.search(raw)
    if a:
        at[int(a.group(1), 16)] = code.strip().decode('latin1')
    m = g.LABEL.match(code)
    if m:
        intab = m.group(1) == b'Voice_EnvelopeRate_Table'
        code = code[m.end():]
    if intab and code.strip().startswith(b'.byte'):
        table += [int(x, 0) for x in code.strip()[5:].decode().split(',') if x.strip()]
fail = 0
for a, t in ANCHORS:
    if not at.get(a, '').startswith(t):
        fail += 1
        print('FAIL %06X: want %r have %r' % (a, t, at.get(a)))
print('anchors: %d checked' % len(ANCHORS))
print('Voice_EnvelopeRate_Table: %d bytes, max 0x%02X' % (len(table), max(table)))
if not table or max(table) > 0x7F:
    fail += 1
    print('FAIL: rate table has a byte above 0x7F')
print('FAILURES:', fail)
sys.exit(1 if fail else 0)
