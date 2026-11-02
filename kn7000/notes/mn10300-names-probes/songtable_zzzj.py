#!/usr/bin/env python3
"""songtable_zzzj.py -- question: what do table segment 1's 220 'ZZZJ' records and their eight
entries select?  Answer (traced in program 941, see notes/table-semantics-2026-10-29.md):
the SOUND ARRANGER's factory settings, one record per preset rhythm, one entry per
accompaniment part.

Checks, all read-only on baserom/:
  1. GenreStyleTable (941 0x48735EE4, 942 0x48736F08): the style counts (+0x11) of genres 0..13
     (8&16 BEAT .. LATIN & WORLD) sum to 220 = the record count; genres 14/15 (CUSTOM, MEMORY)
     are outside the records (StyleIdToPresetOrdinal 0x4843FACD).
  2. 0x485B73A0 (func_4843FB49's table): M3 part 0x13..0x1A -> record entry;
     0x485B7396 (func_4843FFD0's table): style part 0..7 (Drum, Bass, Acc1-5, Perc) -> entry.
     Together they give the entry order Drum, Perc, Bass, Acc1..Acc5.
  3. The program's fall-back record 0x485B737E and the factory records: bank MSB, and the bit-7
     flags (entry 0 bit 7 = Sound Arranger ON for the rhythm; entries 2..7 bit 7 = the part's
     CC94 := 127 instead of 0).
  4. Each record's rhythm: style id from the genre's id list (+0x14), its name from the style-ID
     index (table 84's segment-83 copy, else IC18's) -> IC18 or the table's segment 59.
Run from kn7000/:  python3 -I notes/mn10300-names-probes/songtable_zzzj.py [--names]
"""
import struct, sys
B = 0x48400000
P = {"941": ("baserom/kn7000_program.rom", 0x48735EE4), "942": ("baserom/kn7000_program_sp7001.rom", 0x48736F08)}
u24 = lambda d, o: int.from_bytes(d[o:o + 3], "big")
u16 = lambda d, o: int.from_bytes(d[o:o + 2], "big")


def segments(t):
    first = struct.unpack_from("<I", t, 0)[0]
    ent = list(struct.unpack_from(f"<{first // 4}I", t, 0))
    return ent


def main():
    p941 = open(P["941"][0], "rb").read()
    tab = {b: open(f, "rb").read() for b, f in (("84", "baserom/kn7000_table.rom"), ("83", "baserom/kn7000_table_sp7001.rom"))}
    ic18 = open("baserom/kn7000_ic18.rom", "rb").read()
    # 1. genres
    genres = {}
    for b, (f, a) in P.items():
        d = open(f, "rb").read(); o = a - B
        genres[b] = [(d[o + 24 * i:o + 24 * i + 16].decode().strip(), d[o + 24 * i + 0x11],
                      struct.unpack_from("<I", d, o + 24 * i + 0x14)[0]) for i in range(16)]
        print(f"program {b}: genres 0..13 hold {sum(g[1] for g in genres[b][:14])} rhythms;"
              f" 14 = {genres[b][14][0]} ({genres[b][14][1]}), 15 = {genres[b][15][0]} ({genres[b][15][1]})")
    # 2. part maps
    pe = [struct.unpack_from("<I", p941, 0x485B73A0 - B + 4 * k)[0] for k in range(8)]
    se = list(p941[0x485B7396 - B:0x485B7396 - B + 8])
    print("M3 part 0x13..0x1A -> entry", pe, "; style part 0..7 -> entry", se)
    order = {}
    for sp, nm in enumerate(["Drum", "Bass", "Acc1", "Acc2", "Acc3", "Acc4", "Acc5", "Perc"]):
        order[se[sp]] = nm
    print("entry order:", [order[k] for k in range(8)])
    dflt = p941[0x485B737E - B:0x485B737E - B + 24]
    print("fall-back record 0x485B737E:", [tuple(dflt[3 * k:3 * k + 3]) for k in range(8)])
    # 3. factory records
    for b, t in tab.items():
        s = segments(t)[1]
        assert t[s:s + 8] == b"ZZZJ\x00K\x00\xdc", b
        n = u16(t, s + 6)
        on = sum(t[s + 16 + 24 * r] >> 7 for r in range(n))
        fl = [sum(t[s + 16 + 24 * r + 3 * k] >> 7 for r in range(n)) for k in range(8)]
        msb = [sorted({t[s + 16 + 24 * r + 3 * k + 2] for r in range(n)}) for k in range(8)]
        print(f"table {b}: seg 1 at 0x{s:X}, u16BE count {n}; records ON (entry 0 bit 7) {on};"
              f" bit 7 per entry {fl}; bank MSBs per entry {msb}")
    if "--names" not in sys.argv:
        return
    # 4. names
    t = tab["84"]; ent = segments(t)
    s59 = ent[59]; ns = u24(t, s59) // 3
    tnames = [t[s59 + u24(t, s59 + 3 * k):s59 + u24(t, s59 + 3 * k) + 13].decode().strip() for k in range(ns)]
    R = 0x10000; o_idx, o_sty = u24(ic18, R + 0x1B), u24(ic18, R + 0x1E); cnt = u16(ic18, R + u24(ic18, R + 0x18) + 2)
    s83 = ent[83]; x_idx = u24(t, s83 + 0x1B)

    def name(sid):
        for _ in range(4):
            i = ((sid & 0x0F00) >> 1) | (sid & 0x7F)
            v = u16(t, s83 + x_idx + 2 * i)
            if v < cnt:
                so = R + u24(ic18, R + o_sty + 3 * v)
                return ic18[so:so + 13].decode().strip()
            if v >> 14 == 1:
                return tnames[v & 0x3FFF] + " (table)"
            k = v & 0x7FF
            sid = ((k & 0x780) << 1) | (k & 0x7F)
        return "?"
    s = ent[1]; r = 0
    for gi, (gn, gc, lst) in enumerate(genres["941"][:14]):
        for k in range(gc):
            sid = struct.unpack_from("<I", p941, lst - B + 4 * k)[0]
            o = s + 16 + 24 * r
            E = [tuple(t[o + 3 * j:o + 3 * j + 3]) for j in range(8)]
            print(f"{r:3d} {gn:15s} {k + 1:2d} id 0x{sid:03x} {name(sid):14s} "
                  + " ".join(f"{e[0] & 0x7F:3d}/{e[1]:02x}/{e[2]:02x}{'*' if e[0] & 0x80 else ' '}" for e in E))
            r += 1


main()
