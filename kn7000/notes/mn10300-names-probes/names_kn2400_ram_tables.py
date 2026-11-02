#!/usr/bin/env python3
"""names_kn2400_ram_tables.py -- QUESTION: does any MILK reflection table of the KN2400
image name a procedure in its RAM-linked range (file 0x3285BE..0x3965B8, run at
0x50120000)?  (N-e7ed1928: the README said gen_symbols.py "pairs none of them".)

A reflection table is a run of code pointers, a NUL word, then a run of >= 4 pointers to
identifier strings (tools/gen_symbols.py find_tables).  For every such name run this
counts the words before the NUL that point into 0x50120000..0x5018DFFA, and how many
words anywhere in the image do.  Result on update v1.1 (2026-11-02): 0 tables; the 1,901
words that point into the window are not before any name run.

RUN (from kn2400/):  python3 ../kn7000/notes/mn10300-names-probes/names_kn2400_ram_tables.py
"""
import struct, sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "tools"))
import gen_symbols as G

LO, HI, LINK = 0x3285BE, 0x3965B8, 0x50120000
d = open("baserom/kn2400_program.rom", "rb").read()
ids = G._ident_offsets(d)
u32 = lambda o: struct.unpack_from("<I", d, o)[0]
inwin = lambda v: LINK <= v < LINK + (HI - LO)
print("words pointing into the RAM window:", sum(inwin(u32(o)) for o in range(0, len(d) - 3, 4)))
n, i, tables = len(d) // 4, 0, 0
while i < n:
    if (u32(4 * i) - 0x48400000) not in ids:
        i += 1
        continue
    j = i
    while j < n and (u32(4 * j) - 0x48400000) in ids:
        j += 1
    if j - i >= 4 and u32(4 * i - 4) == 0:
        k, c = 4 * i - 8, 0
        while k >= 0 and inwin(u32(k)):
            c, k = c + 1, k - 4
        if c:
            tables += 1
            print(f"table at 0x{4 * i:X}: {j - i} names, {c} RAM-linked code pointers")
    i = j
print("reflection tables with RAM-linked procedures:", tables)
