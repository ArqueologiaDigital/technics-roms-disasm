#!/usr/bin/env python3
r"""naka_move_edge_heads_to_asm.py -- give the two NAKA records that a C blob's end cuts in two to the asm.

QUESTION ANSWERED
-----------------
"Can the last two blob-edge records of register item N-2f640c1d be typed?"  Both begin as the last
member of a NAKA C blob and end in the assembler file that follows it:

  * NakaWidget_N1 (element 24 of Viewable slot 0x1, a 36-byte Window): its first 22 bytes were
    `NakaWidget_N1_t NakaWidget_N1` at the end of naka_normal_mode.c, its last 14 the
    `.short 245, 0, 0 / .long 0x3f404, 0x3f408` rows of extensions/extension_data.s, which
    ui_widgets/normal_mode_layout.s (the blob's .incbin file) is included just above;
  * NakaWidget_SdmenuPage (element 1 of Viewable slot 0x2, a 36-byte AcWindowPage): its first 6
    bytes were `str_63 = "%"` (the class id's low word, 0x0025, read as a string), `field_0906 =
    0x0160` and `pad_1` (super = 0) at the end of naka_sound_menu_drawbar.c, its other 30 the
    `.short` rows at the top of ui_widgets/naka_sound_technichord_dispatch.s, the file included
    after the blob's.

Every other record of both Viewable tables beside them is already a NAKA_REC_<Class> macro call in
those two asm files, so the heads move there: the C member goes (the blob gets 22 / 6 bytes shorter at
its end, so no other offset moves), the record's label and its head bytes go in front of its tail as
plain `.long` / `.short` rows, and scripts/converters/naka_asm_records.py --apply then writes the whole
record as one macro call from the ROM bytes.  The image does not change (make gate).

v6 and v5 (lane open12/v6v5-port3) have the same records with the same words; only their blob bases
differ, and no address is written here (the comment patterns accept any address), so the same rewrites
apply.

RUN (repository root, built tree), per tree v10, v9, v7, v6, v5 (their files are the same here):
    python3 scripts/converters/naka_move_edge_heads_to_asm.py --tree v10
    make <tree's program ROM>     (the C blobs and the ELF the next step reads)
    python3 scripts/converters/naka_asm_records.py --tree v10 --apply
It refuses a tree it has already converted.
"""
import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def rd(p):
    return open(p, 'rb').read().decode('latin-1')


def wr(p, t):
    open(p, 'wb').write(t.encode('latin-1'))


def sub1(pat, rep, text, what):
    new, n = re.subn(pat, rep, text, count=1, flags=re.M | re.S)
    if n != 1:
        sys.exit('naka_move_edge_heads_to_asm: pattern not found: ' + what)
    return new


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True, choices=['v10', 'v9', 'v7', 'v6', 'v5'])
    a = ap.parse_args()
    mc = os.path.join(ROOT, a.tree, 'maincpu')
    p = lambda *x: os.path.join(mc, *x)
    nm_c, db_c = p('ui_widgets', 'naka_normal_mode.c'), p('ui_widgets', 'naka_sound_menu_drawbar.c')
    nm_s, db_s = p('ui_widgets', 'normal_mode_layout.s'), p('ui_widgets', 'sound_menu_drawbar_screens.s')
    ext_s, tc_s = p('extensions', 'extension_data.s'), p('ui_widgets', 'naka_sound_technichord_dispatch.s')
    nm = rd(nm_c)
    if 'NakaWidget_N1_t NakaWidget_N1;' not in nm:
        sys.exit('naka_move_edge_heads_to_asm: %s already converted' % a.tree)

    # --- NakaWidget_N1 -------------------------------------------------------------------------
    nm = sub1(r"^/\* NakaWidget_N1's element \(scripts/converters/nakarest_reviewed_slices\.py\)\. \*/\n"
              r"typedef struct __attribute__\(\(packed\)\) \{\n.*?\} NakaWidget_N1_t;\n\n", '', nm, 'N1 typedef')
    nm = sub1(r'^    /\* zero padding \*/\n    /\* Window view record "N1", first 22 bytes .*?\*/\n'
              r'    NakaWidget_N1_t NakaWidget_N1;\n', '', nm, 'N1 member')
    nm = sub1(r'^    \.NakaWidget_N1 = \{ NAKA_CLASS\(Window\), 0xFFFF, 0x0019, 0xFFFF, 0xFFFF, 0x0008, '
              r'\{ 0, 127, 319, 236 \} \},\n\n', '', nm, 'N1 initializer')
    nm = sub1(r'^ \* Total size: 1168 bytes$', ' * Total size: 1146 bytes', nm, 'normal_mode header size')
    nm = sub1(r'sizeof\(naka_normal_mode_t\) == 1168,\n    "naka_normal_mode must be exactly 1168 bytes"',
              'sizeof(naka_normal_mode_t) == 1146,\n    "naka_normal_mode must be exactly 1146 bytes"',
              nm, 'normal_mode size assert')
    wr(nm_c, nm)
    s = rd(nm_s)
    s = sub1(r'^; Normal Mode screen layout \(14 widgets, 1168 bytes\)$',
             '; Normal Mode screen layout (13 widgets, 1146 bytes)', s, 'normal_mode_layout header')
    s = sub1(r'^; NakaWidget_N1 -- 1 x struct .*?\nNakaWidget_N1:\t\.incbin "includes/generated/naka_normal_mode\.bin", '
             r'0x47A, 0x16\n',
             '; Element 24 of the slot, the "N1" Window, follows the blob: it is the first record of\n'
             '; extensions/extension_data.s after the include of this file (NakaWidget_N1).\n', s, 'N1 incbin')
    wr(nm_s, s)
    s = rd(ext_s)
    s = sub1(r'in order; element 24 begins in\n; ui_widgets/normal_mode_layout\.s and only its last 14 bytes are here\.',
             'in order, and element 24 is the first\n; record below (NakaWidget_N1).', s, 'extension_data intro')
    s = sub1(r'^\t; element 24 \(0x35\), \+0x16\.\.\+0x23 -- begun in normal_mode_layout\.s\n\t\.short 245, 0, 0\n',
             'NakaWidget_N1:\n'
             '\t; element 24 (0x35), the "N1" Window; its first 22 bytes were the end of naka_normal_mode.c until\n'
             '\t; 2026-11-06 (scripts/converters/naka_move_edge_heads_to_asm.py)\n'
             '\t.long 0x01600035\n'
             '\t.short 0xffff, 25, 0xffff, 0xffff, 8\n'
             '\t.short 0, 127, 319, 236\n'
             '\t.short 245, 0, 0\n', s, 'N1 tail')
    wr(ext_s, s)

    # --- NakaWidget_SdmenuPage -----------------------------------------------------------------
    db = rd(db_c)
    db = sub1(r'^    char str_63\[2\];\n    uint16_t field_0906;\n    uint8_t pad_1\[2\];  /\* zero padding \*/\n',
              '', db, 'SdmenuPage members')
    db = sub1(r'^    \.str_63 = "%",\n\n    \.field_0906 = 0x0160,\n\n    \.pad_1 = \{ 0 \},\n\n', '', db,
              'SdmenuPage initializers')
    db = sub1(r'^ \* Total size: 2314 bytes$', ' * Total size: 2308 bytes', db, 'drawbar header size')
    db = sub1(r'sizeof\(naka_sound_menu_drawbar_t\) == 2314,\n    "naka_sound_menu_drawbar must be exactly 2314 bytes"',
              'sizeof(naka_sound_menu_drawbar_t) == 2308,\n    "naka_sound_menu_drawbar must be exactly 2308 bytes"',
              db, 'drawbar size assert')
    wr(db_c, db)
    s = rd(db_s)
    s = sub1(r'^; \[nakarest\] NakaWidget_SdmenuPage  \+0x904\.\.\+0x90a \(0x[0-9a-f]+, 6 B\)\n'
             r'; \[nakarest\] widget record, element 1 of Viewable slot 0x2 .*?\n.*?AcWindowPage \(36 B\)\.\n'
             r'NakaWidget_SdmenuPage:\t\.incbin "includes/generated/naka_sound_menu_drawbar\.bin", 0x904, 0x6\n',
             '; Element 1 of the slot, NakaWidget_SdmenuPage (AcWindowPage), follows the blob: it is the first\n'
             '; record of ui_widgets/naka_sound_technichord_dispatch.s.\n', s, 'SdmenuPage incbin')
    wr(db_s, s)
    s = rd(tc_s)
    # (the field comments of the old rows give way to one line; v10 / v9 / v7 were tidied so by hand in
    # f3220ffc9, v6 / v5 get the same text from here)
    s = sub1(r'^; Tail of the NAKA record whose header \(naka_header type 0x25\) is at 0x[0-9A-Fa-f]+,\n'
             r'; in the previous file; a 32-bit pointer to that record is at 0x[0-9A-Fa-f]+\.\n'
             r'(\t\.short 0xffff, 0x2\n\t\.short 0xffff, 0x8\n)\t\.short 0xf5\t; X-left coord of the button\n'
             r'\t\.short 0x6\t; y-top coord of the button\n\t\.short 0x13b, 0x17\t; x-right coord of the button\n'
             r'\t\.short 0xf3, 0xc1\t; y-botton coord\n\t\.short 0xffff\n'
             r'\t\.long 0x3e664\t; <-- the LSByte here affects the page number\n\t\.short 0x1\n'
             r'\t\.short 0x2\t; total number of pages\n',
             '; element 1 of Viewable slot 0x2 (Sdmenu), an AcWindowPage; its first 6 bytes were the end of\n'
             '; naka_sound_menu_drawbar.c until 2026-11-06 (scripts/converters/naka_move_edge_heads_to_asm.py)\n'
             '; (the rect is the box of the page indicator; pagemax = 2, the number of pages)\n'
             'NakaWidget_SdmenuPage:\n'
             '\t.long 0x01600025\n'
             '\t.short 0\n'
             '\\1\t.short 0xf5\n\t.short 0x6\n\t.short 0x13b, 0x17\n\t.short 0xf3, 0xc1\n\t.short 0xffff\n'
             '\t.long 0x3e664\n\t.short 0x1\n\t.short 0x2\n', s, 'SdmenuPage tail')
    wr(tc_s, s)
    print('naka_move_edge_heads_to_asm %s: NakaWidget_N1 and NakaWidget_SdmenuPage moved to the asm' % a.tree)


if __name__ == '__main__':
    main()
