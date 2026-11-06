#!/usr/bin/env python3
"""names_kn2400_titles: which KN2400 title ids (0x000F0000 + i) does the firmware's own
TitleNameTable name that the generated src/program/data/gui_ids.inc does not (L-mn10300-names-
kn2400-titles)?

TitleNameTable (0x48414BD8, 0x140 u32 = 320 pointers, kn2400/src/program/data/labels.sym) holds,
for title i, a pointer to its name string ("_TT_PS", "_TT_CTHOMEPAGE", ... or a placeholder
"_TT_13e"); gui_ids.inc names only the titles a screen registers.  Prints the count of each
kind and every title id whose name gui_ids.inc lacks.  Expected (2026-11-06): 320 entries; the
unnamed ones listed with their string; a NULL / non-string entry counted apart.

usage (from the repo root):
  python3 -I kn7000/notes/kn7000-names-probes/names_kn2400_titles.py
"""
import re
import struct

ROM = open("kn2400/baserom/kn2400_program.rom", "rb").read()
BASE, TAB, N = 0x48400000, 0x48414BD8, 0x140
ids = {int(v, 16): n for n, v in re.findall(r"^\.equ (TT_\w+), (0x[0-9A-Fa-f]+)",
                                            open("kn2400/src/program/data/gui_ids.inc").read(), re.M)}
kinds, missing = {"named in gui_ids.inc": 0, "real name, not in gui_ids.inc": 0,
                  "placeholder _TT_<hex>": 0, "not a string": 0}, []
for i in range(N):
    p = struct.unpack_from("<I", ROM, TAB - BASE + 4 * i)[0]
    o = p - BASE
    s = ROM[o:ROM.index(b"\0", o)].decode("latin-1") if 0 <= o < len(ROM) else None
    tid = 0x000F0000 + i
    if tid in ids:
        kinds["named in gui_ids.inc"] += 1
    elif s is None or not s.startswith("_TT_"):
        kinds["not a string"] += 1
        missing.append((tid, f"0x{p:08X}"))
    elif re.fullmatch(r"_TT_[0-9a-f]+", s):
        kinds["placeholder _TT_<hex>"] += 1
    else:
        kinds["real name, not in gui_ids.inc"] += 1
        missing.append((tid, s))
for k, v in kinds.items():
    print(f"{v:4d}  {k}")
for tid, s in missing:
    print(f"  0x{tid:08X}  {s}")
