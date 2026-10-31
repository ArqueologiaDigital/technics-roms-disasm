#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
"""zlib_tables.py -- where zlib 1.0.4's data tables are in each MILK program image.

QUESTION ANSWERED: "at which address does each build (KN7000 941 / 942 / 935 / 893,
KN6000, KN6500, KN2400, the HD-SX3 plug-in) hold zlib 1.0.4's static tables, and does
its symbol files name them?"  The tables are found by their contents, which are
zlib's own (deflate.c configuration_table, trees.c extra_lbits / extra_dbits /
extra_blbits / bl_order / static_*_desc, infblock.c border, inftrees.c cplens /
cplext / cpdist / cpdext, infutil.c inflate_mask, zutil.c z_errmsg), and from the
order the compiler laid them out in (cpdext has extra_dbits' contents: it is the
copy right after cpdist).  Each found table is given at its RAM address when it lies
in the initialised-RAM image (crt0's copy, milk_model.find_raminit / the profile's
`raminit`), else at its flash address.  The last column says which symbol name, if
any, the build's symbol files give that address.

RUN (from kn7000/):  python3 notes/mn10300-formats-probes/zlib_tables.py [--sym] [profile ...]
  --sym   print the lines for the profile's manual symbol file instead
"""
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
KN7 = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(KN7, "tools"))

U32 = lambda *v: struct.pack(f"<{len(v)}I", *v)  # noqa: E731
TABLES = [
    # (name, bytes, what) -- zlib 1.0.4's sources
    ("extra_lbits", U32(*([0] * 8 + [1] * 4 + [2] * 4 + [3] * 4 + [4] * 4 + [5] * 4 + [0])),
     "trees.c: extra bits of each length code (29 ints)"),
    ("extra_blbits", U32(*([0] * 16 + [2, 3, 7])), "trees.c: extra bits of each bit-length code (19 ints)"),
    ("bl_order", bytes([16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15]),
     "trees.c: the order the bit-length code lengths are sent in (19 bytes)"),
    ("border", U32(16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15),
     "infblock.c: the order of the bit-length code lengths (19 uInts)"),
    ("cplens", U32(3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115,
                   131, 163, 195, 227, 258, 0, 0), "inftrees.c: copy lengths for literal codes 257..285 (31 uInts)"),
    ("cplext", U32(*([0] * 8 + [1] * 4 + [2] * 4 + [3] * 4 + [4] * 4 + [5] * 4 + [0, 192, 192])),
     "inftrees.c: extra bits for literal codes 257..285; 192 = invalid (31 uInts)"),
    ("cpdist", U32(1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537,
                   2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577),
     "inftrees.c: copy offsets for distance codes 0..29 (30 uInts)"),
    ("inflate_mask", U32(*[(1 << i) - 1 for i in range(17)]), "infutil.c: masks of the low n bits, n = 0..16 (17 uInts)"),
]
DBITS = U32(0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 13, 13)
CONF0 = struct.pack("<4H", 0, 0, 0, 0)
CONF1 = struct.pack("<4H", 4, 4, 8, 4)


def find_all(d, pat):
    i, out = d.find(pat), []
    while i >= 0:
        out.append(i)
        i = d.find(pat, i + 1)
    return out


def probe(profile):
    import gen_data_s as G
    G.configure(profile)
    P = G.P
    root = G.KN7
    rom = open(os.path.join(root, P["rom"]), "rb").read()
    base = G.BASE
    rr, ram, ln = G.RAMINIT_ROM, G.RAMINIT_RAM, G.RAMINIT_LEN

    def where(off):
        a = base + off
        if rr <= a < rr + ln:
            return ram + (a - rr)
        return a
    found = []
    for name, pat, what in TABLES:
        hits = find_all(rom, pat)
        if name == "inflate_mask":
            hits = [h for h in hits if h % 4 == 0]
        if name == "extra_lbits":
            # cplext starts with extra_lbits' 29 values: keep the hit that is not followed by 192, 192
            hits = [h for h in hits if rom[h + 116:h + 124] != U32(192, 192)]
        if len(hits) == 1:
            found.append((where(hits[0]), name, what))
    byname = {n: a for a, n, _w in found}
    # extra_dbits and cpdext have the same contents: cpdext follows cpdist, extra_dbits follows extra_lbits
    for h in find_all(rom, DBITS):
        a = where(h)
        if byname.get("cpdist") == a - 120:
            found.append((a, "cpdext", "inftrees.c: extra bits for distance codes (30 uInts)"))
            found.append((a + 120, "fixed_built", "inftrees.c: non-zero once inflate_trees_fixed has built the fixed tables"))
        elif byname.get("extra_lbits") == a - 116:
            found.append((a, "extra_dbits", "trees.c: extra bits of each distance code (30 ints)"))
    # configuration_table: 10 x {u16 good_length, max_lazy, nice_length, max_chain; compress_func func}
    for h in find_all(rom, CONF0):
        if h % 4 == 0 and rom[h + 12:h + 20] == CONF1 and struct.unpack_from("<4H", rom, h + 108) == (32, 258, 258, 4096):
            found.append((where(h), "configuration_table", "deflate.c: per-level {good_length, max_lazy, "
                          "nice_length, max_chain, func} (10 x 12 bytes)"))
    # static_l_desc / static_d_desc / static_bl_desc: {tree, extra_bits, extra_base, elems, max_length}
    byname = {n: a for a, n, _w in found}
    rom_ram = lambda a: (a - ram + rr) - base if ram <= a < ram + ln else a - base  # noqa: E731
    for n, eb, base_, elems, ml in (("static_l_desc", "extra_lbits", 257, 286, 15),
                                    ("static_d_desc", "extra_dbits", 0, 30, 15),
                                    ("static_bl_desc", "extra_blbits", 0, 19, 7)):
        if eb not in byname:
            continue
        pat = struct.pack("<IIII", byname[eb], base_, elems, ml)
        for h in find_all(rom, pat):
            if h % 4 == 0 and h >= 4:
                found.append((where(h - 4), n, f"trees.c: {{tree, {eb}, {base_}, {elems}, {ml}}}"))
        if n == "static_bl_desc" and n in {x[1] for x in found}:
            a = next(x[0] for x in found if x[1] == n)
            found.append((a + 20, "static_init_done", "trees.c: non-zero once tr_static_init has run"))
    # z_errmsg: 10 pointers, the first to "need dictionary"
    for h in find_all(rom, b"need dictionary\x00"):
        for p in {base + h, where(h)}:
            for q in find_all(rom, struct.pack("<I", p)):
                # (a data word of the initialised-RAM image, not a `mov imm32` in the code)
                if q % 4 == 0 and rr <= base + q < rr + ln:
                    found.append((where(q), "z_errmsg", "zutil.c: the error texts, indexed 2 - err (10 pointers)"))
    for pat, n in ((b" deflate 1.0.4 ", "deflate_copyright"), (b" inflate 1.0.4 ", "inflate_copyright")):
        for h in find_all(rom, pat):
            found.append((where(h), n, "the copyright string the zlib sources keep in the binary"))
    names = {}
    for s in P["syms"]:
        f = os.path.join(root, s)
        if os.path.exists(f):
            for line in open(f, encoding="latin-1"):
                m = re.match(r"0x([0-9A-Fa-f]+)\s+(\S+)", line)
                if m:
                    names.setdefault(int(m.group(1), 16), m.group(2))
    lab = os.path.join(root, P["src"], "data", "labels.sym")
    if os.path.exists(lab):
        for line in open(lab, encoding="latin-1"):
            m = re.match(r"0x([0-9A-Fa-f]+)\s+(\S+)", line)
            if m:
                names.setdefault(int(m.group(1), 16), "(generated) " + m.group(2))
    return sorted(set(found)), names


def main():
    args = sys.argv[1:]
    sym = "--sym" in args
    profs = [a for a in args if not a.startswith("--")] or ["941", "sp7001", "b935", "b893", "kn6000", "kn6500",
                                                             "kn2400", "hdsx3"]
    for p in profs:
        found, names = probe(p)
        if sym:
            for a, n, what in found:
                print(f"0x{a:08X}  {n:<24s}; zlib 1.0.4 {what} (found by contents: "
                      "kn7000/notes/mn10300-formats-probes/zlib_tables.py)")
            continue
        print(f"== {p}: {len(found)} zlib tables")
        for a, n, what in found:
            print(f"  0x{a:08X}  {n:<20s} {names.get(a, '-')}")


if __name__ == "__main__":
    main()
