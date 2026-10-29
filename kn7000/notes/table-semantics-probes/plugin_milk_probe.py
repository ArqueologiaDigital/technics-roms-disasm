#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""plugin_milk_probe.py -- the SP7001 table-flash plug-in's own MILK classes.

QUESTION IT ANSWERS
  "Which MILK GUI classes does the SP7001 XAPR plug-in (table 83, 0x3E8000..0x3FB5A0) define,
   and what are their fields?" -- the preparation for typing its widget data
  (0x3EF6C5..0x3F782C, 0x3F783E..0x3F88F0, 0x3F9194..0x3FB59C) with lane gui-kn7000's macros.

A class record is the KN5000/KN7000 24-byte layout (notes/gui-data-region/README.md on branch
data/gui-kn7000): {u32 proc, u32 parent class id, u16 allsize, u16 selfsize, u32 name,
u32 propdata (one type character per own field), u32 propname (pointers to field names)}.
The probe scans the plug-in's data for 4-aligned records whose proc lies in the plug-in's
code (0x3E803C..0x3EF6C5) and whose name, propdata and propname point into the plug-in.

Run from kn7000/:  python3 -I notes/table-semantics-probes/plugin_milk_probe.py
"""
import re
import struct

d = open("baserom/kn7000_table_sp7001.rom", "rb").read()
B = 0x48000000
CODE = (0x3E803C, 0x3EF6C5)
LO, HI = 0x3EF6C5, 0x3FB5A0


def inside(v):
    return 0x3E8000 <= v - B < 0x3FB5A0


def cstr(v):
    o = v - B
    return d[o:d.index(0, o)]


for o in range(LO & ~3, HI - 24, 4):
    proc, parent, alls, selfs, name, pd, pn = struct.unpack_from("<IIHHIII", d, o)
    if not (CODE[0] <= proc - B < CODE[1] and inside(name) and inside(pd) and inside(pn) and alls >= selfs):
        continue
    nm = cstr(name)
    if not re.fullmatch(rb"[A-Za-z_][A-Za-z0-9_]*", nm):
        continue
    sig = cstr(pd)
    if parent > 0x0FFFFFFF:          # a code address, not a class id: not a class record
        continue
    names = []
    p = pn - B
    while True:
        s = cstr(struct.unpack_from("<I", d, p)[0])
        if not s:
            break
        names.append(s.decode("latin-1"))
        p += 4
    print(f"0x{B + o:08X} {nm.decode():20s} parent 0x{parent:08X} allsize {alls:3d} selfsize {selfs:3d} "
          f"fields {sig.decode('latin-1')!r}: {', '.join(names)}")
