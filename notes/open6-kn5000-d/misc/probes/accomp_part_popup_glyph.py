#!/usr/bin/env python3
"""accomp_part_popup_glyph.py -- what does the step-record screen draw for the 0x09 bytes of
Tbl_AccompPartNames, and what text does ParamPopup_AccompPart put on the screen?

Question (open item N-1fe9a5df, the last Scoop unknown): ParamPopup_AccompPart copies 16 bytes of
Tbl_AccompPartNames (0x09 0x09 "ACCOMP PART1 ON ACCOMP PART2 ON " 0x09 0x09 "ACCOMP PART3 ON ") into the
pop-up line buffer; which glyph does the font draw for code 0x09?

Signal, read from the ROM images (nothing is emulated):
  1. SqStep_PopupLineField (the record Display_RedrawMainContent draws the pop-up line with): byte +6 is the
     text style, bytes +7..+10 the buffer address (0x0ECA), +11 the length (30), +13 the cell position.
  2. Scoop_CurveUpdate_SegmentEnd maps every buffer byte through Scoop_CharGlyphMap before DrawString,
     and takes the font from TextStyle_FontTable[style & 0x3f] (32-bit entries).
  3. The font's descriptor (table data 0x945C00 + 16 * font) and its glyph bank (characters 0x20-0xFF,
     column-major 1bpp); the glyph of code c is bank[(map[c] - 0x20) * size].
  4. ParamPopup_AccompPart is replayed in Python for every value of A (bits 7-5 of the event's flag byte,
     1..7) and of W (the part on/off bits): 16 bytes from Tbl + 16 * (A >> 5) to 0x0ECF, "OFF" to 0x0EDC
     when (A & W) == 0, over a line DisplayStr_ClearRegion filled with spaces (0x0ECD, 27 bytes).

Run:  python3 accomp_part_popup_glyph.py [REPO_ROOT]
      (REPO_ROOT defaults to four directories up; reads original_ROMs/kn5000_v{5..10}_program.rom, the
       git-ignored v5/v6/v8 copies included when present, original_ROMs/kn5000_table_data.rom and
       symbols/maincpu_v*_symbols_reference.txt)
"""
import os
import struct
import sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else os.path.abspath(
    os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
BASE = 0xE00000
TBASE = 0x800000
SYMS = {"v10": "v10", "v9": "v9", "v8": "v8", "v7": "v7", "v6": "v6", "v5": "v5"}


def syms(v):
    d = {}
    with open(os.path.join(ROOT, "symbols", "maincpu_%s_symbols_reference.txt" % SYMS[v]), "rb") as f:
        for line in f:
            p = line.split()
            if len(p) == 2 and not line.startswith(b"#"):
                d[p[0].decode("latin-1")] = int(p[1], 16)
    return d


def main():
    tdata = open(os.path.join(ROOT, "original_ROMs", "kn5000_table_data.rom"), "rb").read()
    for v in ("v10", "v9", "v8", "v7", "v6", "v5"):
        path = os.path.join(ROOT, "original_ROMs", "kn5000_%s_program.rom" % v)
        if not os.path.exists(path):
            print("== %s: %s not present, skipped" % (v, path))
            continue
        rom = open(path, "rb").read()
        s = syms(v)

        def at(name, n):
            o = s[name] - BASE
            return rom[o:o + n]
        rec = at("SqStep_PopupLineField", 15)
        style = rec[6]
        buf = struct.unpack_from("<I", rec, 7)[0]
        length = struct.unpack_from("<H", rec, 11)[0]
        cell = struct.unpack_from("<H", rec, 13)[0]
        gmap = at("Scoop_CharGlyphMap", 256)
        font = struct.unpack_from("<I", at("TextStyle_FontTable", 256), 4 * (style & 0x3F))[0]
        desc = tdata[0x945C00 - TBASE + 16 * font:][:16]
        w, h, dsc, asc, bank, kern = struct.unpack("<4H2I", desc)
        gsize = ((w + 7) // 8) * h
        tbl = at("Tbl_AccompPartNames", 16 * 8 + 16)
        print("== %s" % v)
        print("   pop-up record SqStep_PopupLineField: style %d, buffer 0x%04X, %d chars, cell x=%d y=%d"
              % (style, buf, length, (cell % 40) * 8, cell // 40))
        print("   TextStyle_FontTable[%d] = font %d: %dx%d, glyph bank 0x%06X, kern 0x%X"
              % (style, font, w, h, bank, kern))
        print("   Scoop_CharGlyphMap[0x00..0x1F] = " + " ".join("%02X" % b for b in gmap[:32]))
        g = gmap[0x09]
        print("   code 0x09 -> glyph code 0x%02X" % g)
        if g >= 0x20 and kern == 0:
            o = bank - TBASE + (g - 0x20) * gsize
            bits = tdata[o:o + gsize]
            lit = sum(bin(b).count("1") for b in bits)
            print("   glyph 0x%02X in font %d: %d bytes at 0x%06X, %d pixels set%s"
                  % (g, font, gsize, bank + (g - 0x20) * gsize, lit, " (blank: a space)" if lit == 0 else ""))
            sp = tdata[bank - TBASE:bank - TBASE + gsize]
            print("   identical to the glyph of ' ' (0x20): %s" % (bits == sp))
        print("   table bytes: " + tbl[:52].hex(" "))
        print("   what ParamPopup_AccompPart leaves in the 16 visible cells from 0x0ECF (glyph-mapped; '.'"
              " marks a byte past the 52-byte table):")
        for a in range(1, 8):
            for wbit in (a, 0):
                line = bytearray(b" " * 16)
                chunk = tbl[16 * a:16 * a + 16]
                line[:] = chunk
                if (a & wbit) == 0:
                    line[13:16] = b"OFF"
                shown = ""
                for i, c in enumerate(line):
                    src = 16 * a + i
                    if (a & wbit) == 0 and i >= 13:
                        shown += chr(c)
                    elif src >= 52:
                        shown += "."
                    else:
                        m = gmap[c]
                        shown += chr(m) if 0x20 <= m < 0x7F else "<%02X>" % m
                print("     A=%d (flag bits %s) %-3s |%s|" % (
                    a, format(a << 5, "08b"), "ON" if wbit else "OFF", shown))


if __name__ == "__main__":
    main()
