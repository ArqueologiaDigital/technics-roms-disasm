#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""table_semantics_probe.py -- the measurements behind notes/table-semantics-2026-10-29.md.

Run from kn7000/ (reads the git-ignored baserom/ images):
    python3 -I notes/table-semantics-probes/table_semantics_probe.py

Prints, for table builds 84 and 83:
  * the GUI resource tables: item counts and the row pad bytes (all 0);
  * segment 59: the style count and that every style's 20 streams parse
    (tools/gen_table_styles.event_lines: F4 first, F5 last, bars x beats markers);
  * segment 4 ("Technics Pads"): the pad count and that the pads tile the segment;
  * the 'TCMP' and 'TPAD' containers: the stored u16BE checksum at +6 against
    SumU16BE(start = u24BE +8, halfwords = u24BE +0xB);
  * the 'ZZZJ' records: per byte position, how many distinct values the 220 take.
"""
import collections
import os
import struct
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import gen_table_styles as G  # noqa: E402


def segs(d):
    return [struct.unpack_from("<I", d, 4 * i)[0] for i in range(85)]


for rom in ("baserom/kn7000_table.rom", "baserom/kn7000_table_sp7001.rom"):
    d = open(rom, "rb").read()
    dv = segs(d)
    print(f"== {rom}")
    hdr = struct.unpack_from("<5I", d, 0x200)
    for name, t in zip(("bitmap", "frame", "icon"), hdr[:3]):
        o, n, pads = t - 0x48000000, 0, collections.Counter()
        while True:
            w, h, p = struct.unpack_from("<hhI", d, o + 8 * n)
            if p == 0:
                break
            if name != "icon" and w & 1:
                st = w + 1
                pads.update(d[p - 0x48000000 + r * st + w] for r in range(h))
            n += 1
        print(f"  {name} table: {n} rows, odd-width row pad bytes {dict(pads)}")
    s, e = dv[59], dv[60]
    n = G.u24be(d, s) // 3
    pos = s + 3 * n
    for k in range(n):
        _text, pos = G.style_file(d, s + G.u24be(d, s + 3 * k), f"Style{k}", f"style {k}", "")
    print(f"  segment 59: {n} styles, all streams parse; styles end 0x{pos:x}, segment end 0x{e:x}")
    s, e = dv[4], dv[5]
    cnt = G.u16be(d, s + G.u24be(d, s + 0x18) + 2)
    print(f"  segment 4: {cnt} pads")
    for seg in (2, 3):
        c = d[dv[seg]:dv[seg + 1]]
        st, hw = G.u24be(c, 8), G.u24be(c, 0xB)
        calc = sum(struct.unpack_from(f">{hw}H", c, st)) & 0xFFFF
        print(f"  segment {seg} {c[:4].decode()}: stored 0x{G.u16be(c, 6):04x}, SumU16BE(0x{st:x}, {hw}) = 0x{calc:04x}")
    s = dv[1]
    cols = [collections.Counter(d[s + 0x10 + 24 * r + i] for r in range(220)) for i in range(24)]
    print("  ZZZJ distinct values per byte:", [len(c) for c in cols])
    print("  ZZZJ bytes 2/5/8/.../23 most common:", [cols[i].most_common(1)[0] for i in range(2, 24, 3)])
