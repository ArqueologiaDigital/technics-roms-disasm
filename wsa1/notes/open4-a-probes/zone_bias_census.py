#!/usr/bin/env python3
"""The (0x00E08C) key-zone bias b, over every factory key zone in prom_d, and what
Table_Muting_CutoffFloor_ByKeyZone_256's 27 values are.  (N-03a03c49, N-4d6ac76a)

The chain (all prom_c instructions, asserted by the source anchors in the sibling probes and
quoted in FINDINGS-l7a1429-curve-tables.md section 7a):
  Voice_SelectKeyZone_Reg0040 (0xFA819A): desc = voice[+0x1F], a 14-byte ToneDB_EnvDescTable
    descriptor; partA = desc[+1] + base, partB = desc[+5] + base, curve = *(partA) + base;
    zone = curve[note]; sub = partA[4 + zone]; element = partB + stride * sub, stride by tag
    bits 6/7 (8 / 6 / 6 / 4 bytes).
  KeyZone_Stage_Reg0040_Stride8 / _Stride6A (tag bit 6 SET) push element[+5] as the BYTE
    argument of Pack104_SetInputs_Rec0C_E08C, which stores it to (0x00E08C) (0xFC4D99);
    _Stride6B / _Stride4 (bit 6 clear) push 0.
  Dev104_PackStagingStruct reads it SIGNED as the bias of register 0x0140/0x0180's index
    (`ld IX,(0x00E08C) / exts IX`, 0xFC4FB7) and UNSIGNED as the index of the floor table
    (`ld C,(0x00E08C) / extz`, 0xFC52A6 and 0xFC541C).
This probe walks every descriptor of directory slots +0x30, +0x38 and +0x70, every note 0..127,
and tabulates b; and reads the floor table out of prom_c's ROM.  Asserted (exit 0 = PASS):
  * b is never positive and never 0x30: b in {0} U [-32, -2];
  * the floor table is 0x3C at indices 0..127 (b >= 0), 0x22 at 128..224 (b <= -32), and
    non-decreasing 0x22 -> 0x3B over 224..255 (b = -32..-1): 27 distinct values;
  so the "27 values" are one ramp of b, not per-zone data.
Run: python3 notes/open4-a-probes/zone_bias_census.py
"""
import collections, os, struct, sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..'))
d = open(os.path.join(ROOT, 'original_ROMs/wsa1_prom_d.bin'), 'rb').read()
c = open(os.path.join(ROOT, 'original_ROMs/wsa1_prom_c.ic28'), 'rb').read()
FLOOR = 0xFDFF96 - 0xF80000
floor = c[FLOOR:FLOOR + 256]
u32 = lambda o: struct.unpack_from('<I', d, o)[0]
fail = 0
allb = collections.Counter()
for slot in (0x30, 0x38, 0x70):
    base = u32(slot)
    descs, o, lo = [], base, 1 << 30
    while o < lo:                       # the array ends at its smallest pool offset
        tag, a, b = d[o], u32(o + 1), u32(o + 5)
        lo = min([lo] + [x for x in (a, b) if x])
        descs.append((tag, a, b))
        o += 14
    bs = collections.Counter()
    zones = set()
    for tag, a, b in descs:
        if not (a and b and tag & 0x40):
            continue                    # bit 6 clear: the walker pushes b = 0
        stride = 8 if tag & 0x80 else 6
        curve = u32(a)
        for note in range(128):
            el = b + stride * d[a + 4 + d[curve + note]]
            v = d[el + 5]
            v = v - 256 if v > 127 else v
            bs[v] += 1
            zones.add((el, v))
    allb.update(bs)
    print('slot +0x%02X: %d descriptors; b over (descriptor, note): %s'
          % (slot, len(descs), dict(sorted(bs.items()))))
    print('            %d distinct zone elements, %d with b != 0'
          % (len(zones), sum(1 for _, v in zones if v)))
vals = set(allb)
if any(v > 0 for v in vals) or 0x30 in vals or not vals <= {0} | set(range(-32, -1)):
    fail += 1
    print('FAIL: b outside {0} U [-32,-2]:', sorted(vals))
ok = (set(floor[0:128]) == {0x3C} and set(floor[128:225]) == {0x22}
      and all(floor[i] <= floor[i + 1] for i in range(224, 255)) and floor[255] == 0x3B
      and len(set(floor)) == 27)
print('floor[0..127] = %s, floor[128..224] = %s, floor[224..255] = %s'
      % (sorted(set(floor[0:128])), sorted(set(floor[128:225])), floor[224:256].hex()))
print('floor by b = -32..0:', [(b, floor[b & 0xFF]) for b in range(-32, 1)])
if not ok:
    fail += 1
    print('FAIL: the floor table is not the b-ramp described')
print('FAILURES:', fail)
sys.exit(1 if fail else 0)
