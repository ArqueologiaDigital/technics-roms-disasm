#!/usr/bin/env python3
"""songtable_m3_set_kinds.py -- question: what does setting M3 id 0x000080 (panel-memory number) do,
for instance when a song replays it?

PutM3Em (lib 0x4C014A51) first offers the id to the class tables of func_4C0216A3 ({mask, value,
handler} triples, printed here: none matches 0x80), then, for a type-0 trie record, func_4C015E50
jumps through func_4C015E50_Table 0x4858C318[record kind].  The cases are 15-byte stubs from
0x4C015E76, each `call <setter>`; this prints the table and the setter each stub calls (decoded from
the stub's `cd` call opcode).  The record of id 0x80 has kind 9 (notes/kn67-field-names-probes/
m3em_param_map.py --table: `000080 52 01 7f 0 0 104 09`), whose setter func_4C016C5C stores the value
(func_4C016050) and then, unless its flag argument has bit 0, calls func_4C021827 = recall panel
memory n (n = 1..104; 0 or > 0x68 does nothing).
Run from kn7000/:  python3 -I notes/mn10300-names-probes/songtable_m3_set_kinds.py
"""
import struct
B, LIB, LIBOFF = 0x48400000, 0x4C000000, 0x3B8FD1
d = open("baserom/kn7000_program.rom", "rb").read()


def off(a):
    return a - LIB + LIBOFF if a >= LIB else a - B


rd = lambda a: struct.unpack_from("<I", d, off(a))[0]


def stub_call(a):
    """the target of the first `call` (opcode 0xCD d16 ... ) in the 15-byte stub at a"""
    for i in range(15):
        if d[off(a) + i] == 0xCD:
            return a + i + struct.unpack_from("<h", d, off(a) + i + 1)[0]
    return None


for i, t in enumerate((0x48731E44, 0x48731E5C, 0x48731E68, 0x48731E74, 0x48731EE0, 0x48731EF8, 0x48731F04, 0x48731F10)):
    rows = []
    while rd(t + 8):
        rows.append(f"(id & {rd(t):08x}) == {rd(t + 4):08x} -> {rd(t + 8):08x}")
        t += 12
    print(f"func_4C0216A3 class table {i}: {rows or 'empty'}")
T = 0x4858C318
for k in range(0x25):
    s = rd(T + 4 * k); c = stub_call(s)
    print(f"kind {k:2d}: stub 0x{s:08X} -> {('0x%08X' % c) if c else '(no call)'}")
