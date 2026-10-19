#!/usr/bin/env python3
"""Which wave ROM does each step of the service-mode WAVE ROM test (8.9) read?

Reads only the PROGRAM 941 image. Prints, per test index 0..3:
  * the tone-generator port and the +8 latch bit 0 the checksum core uses
    (tables 0x485CFD28 / 0x485CFD04, consumed by 0x48483B63 -> 0x484839A1),
  * the expected checksum (table 0x485CFD18),
  * the screen object MainWaveRomTestFunc (0x484A2E3A) writes that index's
    OK/NG into, and the label printed left of that object on the WAVE ROM TEST
    screen (resource records at 0x4860AA80..0x4860AD40).

Object ids are not stored in the records: they are the record's ordinal,
counted from the page record (0xED, the parent of every control on the page).
The script checks that numbering against every parent/child/next/prev link
before it trusts it.

usage: python3 -I wave_rom_test_map.py ../../baserom/kn7000_program.rom
"""
import struct
import sys

BASE = 0x48400000
d = open(sys.argv[1], "rb").read()


def u8(a):
    return d[a - BASE]


def u16(a):
    return struct.unpack_from("<H", d, a - BASE)[0]


def u32(a):
    return struct.unpack_from("<I", d, a - BASE)[0]


def cstr(a):
    o = a - BASE
    return d[o:d.index(b"\0", o)].decode("latin-1")


def expect(a, hexbytes):
    want = hexbytes.replace(" ", "")
    got = d[a - BASE:a - BASE + len(want) // 2].hex()
    assert got == want, f"{a:#x}: {got} != {want}"


# 1. the checksum core: d0 == 0 drives 0x9805xxxx, anything else 0x9804xxxx
expect(0x484839AC, "a0 00 c8 05")                   # cmp 0,d0 ; beq 0x484839B3
expect(0x484839BC, "fc 83 06 00 05 98")             # movhu d0,(0x98050006)
expect(0x48483A68, "fc 83 06 00 04 98")             # movhu d0,(0x98040006)
expect(0x484839FD, "fc 87 08 00 05 98")             # movhu d1,(0x98050008)
expect(0x48483A03, "fc ac 0a 00 05 98")             # movhu (0x9805000A),d0
PORT = {0: 0x98050000, 1: 0x98040000}

# 2. MainWaveRomTestFunc: error bit n <- index n; OK/NG object per bit
for a, n in ((0x484A2ECC, 1), (0x484A2F03, 2), (0x484A2F3C, 4), (0x484A2F75, 8)):
    expect(a, f"f8 ee {n:02x}")                     # btst n,d2
OBJ_SITE = {0: 0x484A2ED5, 1: 0x484A2F0C, 2: 0x484A2F45, 3: 0x484A2F7E, "all": 0x484A2FB7}
obj = {}
for k, a in OBJ_SITE.items():
    expect(a, "fc cc")                              # mov imm32,d0
    obj[k] = u32(a + 2)

# 3. the WAVE ROM TEST page: record header = type, ?, parent, child, next, prev, ?, x0, y0, x1, y1
RECS = [0x4860AA80, 0x4860AABC, 0x4860AAE0, 0x4860AB20, 0x4860AB64, 0x4860ABA8,
        0x4860ABD8, 0x4860AC08, 0x4860AC2C, 0x4860AC6C, 0x4860AC90, 0x4860ACBC,
        0x4860ACE8, 0x4860AD14, 0x4860AD40]
FIRST_ID = 0xED
rec = {}
for i, r in enumerate(RECS):
    rid = FIRST_ID + i
    rec[rid] = dict(addr=r, type=u16(r), parent=u16(r + 4), child=u16(r + 6),
                    next=u16(r + 8), prev=u16(r + 10),
                    box=(u16(r + 14), u16(r + 16), u16(r + 18), u16(r + 20)),
                    text=cstr(u32(r + 0x18)) if u16(r) == 0x16 else None)
# check the ordinal numbering against every link
kids = {}
for rid, x in rec.items():
    kids.setdefault(x["parent"], []).append(rid)
for p, ks in kids.items():
    if p in rec:
        assert rec[p]["child"] == ks[0], (hex(p), rec[p]["child"])
    for j, k in enumerate(ks):
        assert rec[k]["prev"] == (ks[j - 1] if j else 0xFFFF), hex(k)
        assert rec[k]["next"] == (ks[j + 1] if j + 1 < len(ks) else 0xFFFF), hex(k)
print(f"{len(rec)} records, ids {FIRST_ID:#x}..{FIRST_ID + len(rec) - 1:#x}: "
      "every parent/child/next/prev link agrees with ordinal numbering")


def label_left_of(rid):
    x0, y0, x1, y1 = rec[rid]["box"]
    best = None
    for k, x in rec.items():
        if x["text"] is None:
            continue
        lx0, ly0, lx1, ly1 = x["box"]
        if ly0 < y1 and ly1 > y0 and lx1 <= x0:
            if best is None or lx1 > rec[best]["box"][2]:
                best = k
    return rec[best]["text"].strip() if best else "?"


print()
print("| index | port       | +8 bit 0 | expected sum | OK/NG object | label left of it                |")
print("|-------|------------|----------|--------------|--------------|---------------------------------|")
for i in range(4):
    tg, par, gold = u8(0x485CFD28 + i), u8(0x485CFD04 + i), u32(0x485CFD18 + 4 * i)
    o = obj[i] & 0xFFFF
    print(f"| {i}     | {PORT[0 if tg == 0 else 1]:#010x} | {par}        | {gold:#010x}   "
          f"| {obj[i]:#010x}   | {label_left_of(o):<31} |")
print(f"\noverall result object {obj['all']:#010x}: record type {rec[obj['all'] & 0xFFFF]['type']:#x}, "
      f"box {rec[obj['all'] & 0xFFFF]['box']}")
