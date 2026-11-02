#!/usr/bin/env python3
"""songtable_pad_fields.py -- question: what are the pad / TPAD / TCMP-variation head bytes that had no
reader (table-semantics note), and what is the byte after the last built-in pad?

For tables 84 and 83 (baserom/):
  * segment 4 ("Technics Pads"): the last pad's end vs the segment end, the tail bytes, and whether every
    directory offset is a multiple of 4 (then the tail is alignment fill);
  * per built-in pad: +0x12 (flags: bit 0 LOOP, bit 1 SYNCHRO from MainPAD_SetUserPadLoop/Sync via the
    TPAD twin +0x1A; bits 2/3 set only on the "... Maj"/"... Min" pads), and +0x13..+0x15;
  * TPAD records: +0x10/+0x11 (the built-in pad ID it was copied from, func_48431D21), +0x13 (RECORD
    KEY/CHORD, func_484325B4), +0x14/+0x15, +0x1A;
  * TCMP variation records: value census of the head bytes +0x00..+0x1F.
Run from kn7000/:  python3 -I notes/mn10300-names-probes/songtable_pad_fields.py
"""
import struct
from collections import Counter, defaultdict
u24 = lambda t, o: int.from_bytes(t[o:o + 3], "big")
for f in ("baserom/kn7000_table.rom", "baserom/kn7000_table_sp7001.rom"):
    t = open(f, "rb").read()
    ent = list(struct.unpack_from("<%dI" % (struct.unpack_from("<I", t, 0)[0] // 4), t, 0))
    print("==", f, "| directory offsets not a multiple of 4:", [i for i, x in enumerate(ent) if x % 4])
    s, e = ent[4], ent[5]
    o_tab = u24(t, s + 0x1E); cnt = int.from_bytes(t[s + u24(t, s + 0x18) + 2:s + u24(t, s + 0x18) + 4], "big")
    pads = [s + u24(t, s + o_tab + 3 * k) for k in range(cnt)]
    last = max(p + 0x37 + u24(t, p + 0x34) for p in pads)
    print(f"  seg 4 0x{s:X}..0x{e:X}: {cnt} pads, last ends 0x{last:X}, tail {t[last:e].hex()} "
          f"(fill to 4: {(-last) % 4})")
    g = defaultdict(list)
    for p in pads:
        g[t[p + 0x12]].append(t[p:p + 16].decode().strip())
    for k in sorted(g):
        bits = [n for b, n in ((1, "LOOP"), (2, "SYNCHRO"), (4, "bit2"), (8, "bit3")) if k & b]
        mm = Counter(("Maj" if x.endswith("Maj") else "Min" if x.endswith("Min") else "-") for x in g[k])
        print(f"  pad flags {k:2d} {'+'.join(bits) or '-':22s} {len(g[k]):3d} pads, name ends {dict(mm)}")
    print("  pad +0x13..+0x15 values:", Counter(tuple(t[p + 0x13:p + 0x16]) for p in pads))
    s3 = ent[3]; r = s3 + 0x70 + 5 * 0x30; n = 0; C = defaultdict(Counter)
    while all(0x20 <= x < 0x7F for x in t[r:r + 16]):
        for k in (0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x1A):
            C[k][t[r + k]] += 1
        r += 0x60; n += 1
    print(f"  TPAD: {n} records;", "; ".join(f"+0x{k:02X} {dict(C[k])}" for k in sorted(C)))
    s2 = ent[2]; C = defaultdict(Counter)
    for v in range(60):
        r = s2 + 0x1F0 + 0xE0 * v
        for k in range(0x20):
            C[k][t[r + k]] += 1
    print("  TCMP var head:", "; ".join(f"+0x{k:02X} {dict(C[k])}" for k in (0, 1, 2, 3, 0xC, 0xD, 0xE, 0xF, 0x12, 0x13, 0x14, 0x18, 0x19) + tuple(range(0x1A, 0x20))))
