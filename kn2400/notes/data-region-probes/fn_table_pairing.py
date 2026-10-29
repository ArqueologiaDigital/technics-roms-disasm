#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""fn_table_pairing.py -- do the symbol files name each MILK function the way its table does?

QUESTION IT ANSWERS
  "For every Function / ApFunction / MainFunction table the start-up code registers
   (RegisterObjectTable, read by kn7000/tools/milk_model.py), is the procedure at index i named,
   in the image's symbol files, by entry i of the parallel name table?"  The registration gives
   both tables and one count; the MILK function id is (slot << 16) | i for both.  A name that
   disagrees is a reflection-table pairing gen_symbols.py got wrong.
  2026-10-29, kn2400: with kn2400.sym as generated before the start-alignment fix of
  gen_symbols.py, 2,193 agree and 90 do not (all in SDFM MainFunctions, slot 0x213: names
  0x485CFC18, 111 entries, an identifier run of 90, paired 21 entries late); after it, 2,283 / 0.

RUN (from kn7000/; the profile's reference image built):
  python3 ../kn2400/notes/data-region-probes/fn_table_pairing.py kn2400 [--sym OLD.sym ...]
"""
import argparse
import os
import sys

TOOLS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "kn7000", "tools")
sys.path.insert(0, TOOLS)
import gen_data_s as G  # noqa: E402
import milk_model as MM  # noqa: E402

ap = argparse.ArgumentParser()
ap.add_argument("profile")
ap.add_argument("--sym", nargs="+", help="symbol files to check instead of the profile's")
a = ap.parse_args()
G.configure(a.profile)
m = G.Gen().m
by_addr = MM.read_syms(a.sym)[0] if a.sym else m.sym_by_addr
ok = bad = unnamed = 0
for slot, r in sorted(m.by_slot.items()):
    nr = m.by_slot.get(MM.names_slot(slot))
    if r.get("kind") not in ("Function", "ApFunction", "MainFunction") or not nr:
        continue
    for i in range(r["count"]):
        code, nm = m.u32(r["table"] + 4 * i), m.cstr(m.u32(nr["table"] + 4 * i))
        s = by_addr.get(code)
        if s is None:
            unnamed += 1
        elif s in (nm, nm + "_entry"):
            ok += 1
        else:
            bad += 1
            print(f"slot {slot:#05x} [{i:3d}] {code:#010x}: symbol {s}, table name {nm}")
print(f"agree {ok}, disagree {bad}, no symbol {unnamed}")
