#!/usr/bin/env python3
"""names_reflection_table_dump.py -- QUESTION: how does gen_symbols.py pair the MILK
reflection table that holds a given name, and do the two arrays have the same length?

For the table whose name array contains NAME, print: the code array's and the name
array's file offsets, the length of the identifier run (n_names), the length of the run
of code pointers that ends at the NUL before the names (n_code), and every pair
(index, code pointer, name) as gen_symbols.py pairs it (start-aligned).

RUN (from kn7000/):
    python3 notes/mn10300-names-probes/names_reflection_table_dump.py ROM BASE NAME [--lo X --hi Y]
e.g.
    python3 notes/mn10300-names-probes/names_reflection_table_dump.py baserom/kn7000_program.rom 0x48400000 SdcSoundTtlJgFunc
    python3 notes/mn10300-names-probes/names_reflection_table_dump.py ../kn2400/baserom/kn2400_program.rom 0x48400000 SdcSoundTtlJgFunc
"""
import argparse, os, sys
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import gen_symbols as G

ap = argparse.ArgumentParser()
ap.add_argument("rom"); ap.add_argument("base", type=lambda s: int(s, 0)); ap.add_argument("name")
a = ap.parse_args()
data = open(a.rom, "rb").read()
G.PROGRAM_BASE = a.base
G.CODE_LO, G.CODE_HI = 0, len(data)
G._is_code = lambda v: 0 <= v - a.base < len(data)
ids = G._ident_offsets(data)
for code_off, name_off, n in G.find_tables(data, ids):
    names = [G.read_name(data, G.read_u32(data, name_off + 4 * k)) for k in range(n)]
    if a.name not in names:
        continue
    # the run of code pointers that ends at the NUL word before the names
    k = name_off - 8
    while k >= 0 and G._is_code(G.read_u32(data, k)) and not G._is_strptr(data, ids, G.read_u32(data, k)):
        k -= 4
    n_code = (name_off - 8 - k) // 4
    print(f"table: code array 0x{code_off:X}  name array 0x{name_off:X}  n_names {n}  "
          f"code run before NUL {n_code} (starts 0x{k + 4:X})")
    for i in range(n):
        c = G.read_u32(data, code_off + 4 * i)
        print(f"{i:4d}  0x{c:08X}  {names[i]}")
