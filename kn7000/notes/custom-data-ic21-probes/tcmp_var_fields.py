#!/usr/bin/env python3
"""tcmp_var_fields.py -- what values do the TCMP variation record's untraced bytes take, and do the
part set-ups' bytes 15..23 ever differ from the firmware's default template?  (N-b8f49b1e)

Signal: every live slot's TCMP container (slot record section +0x94, as stream_census.py walks it),
its 20 variation records of 0xE0 bytes at +0xF0: bytes +0x00 (kind), +0x01, +0x02, +0x18, +0x19, and
the eight 0x18-byte part set-ups at +0x20.  Firmware 941 reads:
  * +0x18 / +0x19 through StyleRecordBindMem 0x4843374A / StyleRecordBindCustom 0x484337D0, which store
    var + 0x18 in 0x50122DD4 -- the pointer func_48442164 reads as the two style parts the DSP units
    EFF4 / EFF5 apply to (0xFF = default), as the built-in record's +2 / +3 (ic18-rhythm-rom.md);
  * the part set-ups through the pointers 0x50034BAC[] the same binders fill (var + 0x20 + k * 0x18),
    of which StyleTemplateLoadParts 0x4844187A copies 15 bytes; bytes 15..23 are compared here with
    the default template 0x485B7804's fields 15..23 (StylePartTemplateDefault): 0 0 127 0 0 64 64 64 64.
  * the style record's 4 bytes at container +0x70 + 0x70 through StyleNameCommitMem / StyleNameCommitCustom,
    which store record + 0x70 in the units pointer 0x50034C20 (a built-in style's +0x0D), decoded by
    StyleDspUnitsApply 0x484420EF as the DSP preset keys of units EFF4 / EFF5 (two {lo, hi} pairs,
    StyleDspKeyDecode 0x484420C8: (lo & 0x7F) | (hi & 0x7F) << 8, or with hi bit 6 set
    0x10000 | (lo & 0x7F) | (hi & 0x3F) << 8; bit 7 of the first pair's hi byte = TOTAL MODE, key 0xB001); func_4843A47C copies a built-in style's 4 bytes there.
Prints value histograms per byte, the count of set-ups whose bytes 15..23 differ from the default and
the style records' unit bytes.

usage: python3 -I tcmp_var_fields.py IMAGE [IMAGE ...]     (e.g. build/customdata/*.ic21)
"""
import collections
import struct
import sys

DEFAULT_TAIL = bytes([0, 0, 127, 0, 0, 64, 64, 64, 64])
hist = {k: collections.Counter() for k in ("+0x00", "+0x01", "+0x02", "+0x18", "+0x19", "+0x18/19")}
tails = collections.Counter()
units = collections.Counter()
nvar = nsetup = ndiff = 0
for path in sys.argv[1:]:
    d = open(path, "rb").read()
    for s in range(20):
        st = d[2 + 2 * s]
        if st in (0, 0xFF):
            continue
        b = d[st * 0x8000:]
        off, sz = struct.unpack_from("<II", b, 0x94)
        c = b[off:off + sz]
        if c[:4] != b"TCMP":
            continue
        units[c[0xE0:0xE4].hex(" ")] += 1
        for v in range(20):
            r = c[0xF0 + v * 0xE0:0xF0 + (v + 1) * 0xE0]
            nvar += 1
            for k, o in (("+0x00", 0), ("+0x01", 1), ("+0x02", 2), ("+0x18", 0x18), ("+0x19", 0x19)):
                hist[k][r[o]] += 1
            hist["+0x18/19"][r[0x18:0x1A].hex()] += 1
            for p in range(8):
                t = r[0x20 + p * 0x18 + 15:0x20 + (p + 1) * 0x18]
                nsetup += 1
                tails[t.hex(" ")] += 1
                ndiff += t != DEFAULT_TAIL
print(f"{nvar} variation records, {nsetup} part set-ups")
for k, h in hist.items():
    items = sorted(h.items(), key=lambda kv: -kv[1])
    print(f"{k:9} " + ", ".join(f"{(v if isinstance(v, str) else f'0x{v:02X}')} x{n}" for v, n in items[:12]))
print(f"set-ups whose bytes 15..23 differ from the default template: {ndiff}")
for t, n in tails.most_common(6):
    print(f"   {t}  x{n}")
print(f"style records' unit bytes (+0x70..+0x73), {sum(units.values())} records:")


def dspkey(lo, hi):
    hi &= 0x7F
    return (0x10000 | (lo & 0x7F) | (hi & 0x3F) << 8) if hi & 0x40 else (lo & 0x7F) | hi << 8


for t, n in units.most_common(8):
    b = bytes.fromhex(t)
    print(f"   {t}  x{n}   EFF4 key {dspkey(b[0], b[1]):#06x}, EFF5 key {dspkey(b[2], b[3]):#06x},"
          f" TOTAL MODE {b[1] >> 7}")
