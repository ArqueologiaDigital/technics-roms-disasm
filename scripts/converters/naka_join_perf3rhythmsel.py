#!/usr/bin/env python3
r"""naka_join_perf3rhythmsel.py -- type the PsWideToggle record that two NAKA C blobs cut in two.

QUESTION ANSWERED
-----------------
"Can NakaWidget_Perf3RhythmSel (element 9 of Viewable slot 0xE3, a 42-byte PsWideToggle at 0xE24034) be
one typed member, and stop reading as `naka_dispatch_t w119` with `.inst_ptr = 0x00F40008`?"  (register
items N-45db7885, the last numeric ROM address in the NAKA C of v10 / v9 / v7, and N-2f640c1d, a
blob-edge record.)  Its first 34 bytes were the last members of naka_direct_play.c (a 24-byte
naka_dispatch_t + 2 pad bytes + two words) and its last 8 bytes the first member of
naka_widget_tables_1.c (`uint8_t NakaWidget_Perf3RhythmSel_Tail[8]`).  So `.inst_ptr = 0x00F40008` was
the flag word 0x0008 and rect x1 = 244; `.link_ptr = 0x013B00D8` rect y1 = 216 and x2 = 315; and
`.proc_addr = NAKA_ADDR(INTETC45)` (INTETC45 = 0xEE, an SFR) the rect y2 = 238 and the low half of the font.

This moves the boundary between the two blobs 8 bytes up (both are emitted back to back, so the image does
not change):

  * naka_direct_play.c: the four members become `naka_cls_PsWideToggle_t NakaWidget_Perf3RhythmSel`
    (12250 -> 12258 bytes), its values read from the two compiled blobs and spelled like the record's
    siblings (elements 7 and 8);
  * naka_widget_tables_1.c: the 8-byte tail member goes, BASE 0xE24056 -> 0xE2405E (12878 -> 12870 bytes);
    every SELF() is BASE + offsetof, so the other members keep their addresses;
  * direct_play_medley_screens.s: the record's `.incbin` grows from 0x22 to 0x2A bytes;
  * naka_widget_tables_1.s: the tail label and its `.incbin` go, every other `.incbin` offset into
    naka_widget_tables_1.bin drops by 8;
  * the v7 C-divergence json's recorded size of naka_widget_tables_1.bin follows.

Run it once per tree (v10, v9, v7: their files are identical here; v6 and v5, whose C is v7's with
their own bases: v6's addresses here are v7's, v5's are 0x18 lower), then
`naka_gui_symbolize.py --tree <t> --apply` (it refreshes the slot enum's comments) and `make gate`.
It refuses to run on a tree it has already converted (v10 / v9 / v7 since 2026-11-06, v6 / v5 since
lane open12/v6v5-port3 ran it).  The addresses it checks and writes are the tree's own: the two blobs'
`#define BASE`s, the record's and its captions' labels (symbols/maincpu_<tree>_symbols_reference.txt)
and RAM_Rhythm_PsWideToggle_OnOff (the tree's naka_ram_cells.h).  The `Base ROM address` header lines
move by the same 8 bytes (v5's keep v7's value, as all of that tree's carried headers do).

RUN (repository root, built tree)
    python3 scripts/converters/naka_join_perf3rhythmsel.py --tree v10
"""
import argparse
import json
import os
import re
import struct
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def rd(p):
    return open(p, 'rb').read().decode('latin-1')


def wr(p, t):
    open(p, 'wb').write(t.encode('latin-1'))


def sub1(pat, rep, text, what):
    new, n = re.subn(pat, rep, text, count=1, flags=re.M | re.S)
    if n != 1:
        sys.exit('naka_join_perf3rhythmsel: pattern not found: ' + what)
    return new


def tree_syms(tree):
    syms = {}
    for ln in open(os.path.join(ROOT, 'symbols', 'maincpu_%s_symbols_reference.txt' % tree)):
        p = ln.split()
        if len(p) == 2 and not ln.startswith('#'):
            syms[p[0]] = int(p[1], 16)
    return syms


def c_base(text, what):
    m = re.search(r'^#define BASE  0x([0-9A-F]{8})u$', text, re.M)
    if not m:
        sys.exit('naka_join_perf3rhythmsel: no single #define BASE in ' + what)
    return int(m.group(1), 16)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True, choices=['v10', 'v9', 'v7', 'v6', 'v5'])
    a = ap.parse_args()
    uw = os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets')
    gen = os.path.join(ROOT, a.tree, 'maincpu', 'includes', 'generated')
    dp_c, t1_c = os.path.join(uw, 'naka_direct_play.c'), os.path.join(uw, 'naka_widget_tables_1.c')
    dp_s, t1_s = os.path.join(uw, 'direct_play_medley_screens.s'), os.path.join(uw, 'naka_widget_tables_1.s')
    dp_ld = os.path.join(uw, 'naka_direct_play_link.ld')
    dp, t1 = rd(dp_c), rd(t1_c)
    if 'naka_dispatch_t w119;' not in dp:
        sys.exit('naka_join_perf3rhythmsel: %s already converted' % a.tree)

    # The tree's own addresses: the blobs' bases, the record's labels, its onoff cell.
    syms = tree_syms(a.tree)
    dp_base, t1_base = c_base(dp, dp_c), c_base(t1, t1_c)
    assert syms['NakaWidget_Perf3RhythmSel'] == dp_base + 0x2FB8, hex(syms['NakaWidget_Perf3RhythmSel'])
    assert syms['NakaWidget_Perf3RhythmSel_Tail'] == t1_base, hex(syms['NakaWidget_Perf3RhythmSel_Tail'])
    cells = open(os.path.join(uw, 'naka_ram_cells.h'), encoding='latin-1').read()
    onoff_cell = int(re.search(r'^#define RAM_Rhythm_PsWideToggle_OnOff\s+0x([0-9A-F]+)u', cells, re.M).group(1), 16)

    # The record's 42 bytes, from the two compiled blobs (each tree reads its own).
    b1 = open(os.path.join(gen, 'naka_direct_play.bin'), 'rb').read()
    b2 = open(os.path.join(gen, 'naka_widget_tables_1.bin'), 'rb').read()
    assert len(b1) == 12250 and len(b2) == 12878, (len(b1), len(b2))
    rec = b1[0x2FB8:] + b2[:8]
    assert len(rec) == 42
    (cls, sup, sub, nxt, prv, flag, x1, y1, x2, y2, font, stron, stroff, onoff, es1, es2) = \
        struct.unpack('<IHHHHHhhhhIIIIHH', rec)
    assert cls == 0x01600045 and (sup, sub, nxt, prv) == (0, 0xFFFF, 10, 8) and flag == 0x0008
    assert (x1, y1, x2, y2) == (244, 216, 315, 238) and font == 0
    assert (stron, stroff) == (syms['NakaWidget_Perf3RhythmSel_StrOn'], syms['NakaWidget_Perf3RhythmSel_StrOff']) \
        == (t1_base + 16, t1_base + 8), (hex(stron), hex(stroff))
    assert onoff == onoff_cell and (es1, es2) == (6, 7)

    # naka_direct_play.c: the struct members ...
    dp = sub1(r'^    naka_dispatch_t w119;  /\* 0x45 \*/\n    uint8_t pad_482\[2\];  /\* zero padding \*/\n'
              r'    uint32_t ptr_2fd2;\n    uint32_t NakaWidget_Perf3RhythmSel_StrOn_ptr;\n',
              '    /* element 9 of Viewable slot 0xE3: PsWideToggle (class id 0x01600045) */\n'
              '    naka_cls_PsWideToggle_t NakaWidget_Perf3RhythmSel;\n', dp, 'w119 members')
    dp = sub1(r'sizeof\(naka_direct_play_t\) == 12250,\n    "naka_direct_play must be exactly 12250 bytes"',
              'sizeof(naka_direct_play_t) == 12258,\n    "naka_direct_play must be exactly 12258 bytes"',
              dp, 'size assert')
    dp = sub1(r'^ \* Total size: 12250 bytes$', ' * Total size: 12258 bytes', dp, 'header size')
    # ... and the initializer (spelled like elements 7 and 8; naka_gui_symbolize keeps it).
    dp = sub1(r'^    \.w119 = \{\n.*?^    \.NakaWidget_Perf3RhythmSel_StrOn_ptr = NAKA_ADDR\('
              r'NakaWidget_Perf3RhythmSel_StrO(?:n|ff)\),\n',
              '    .NakaWidget_Perf3RhythmSel = {\n'
              '        .class_ = NAKA_CLASS(PsWideToggle),\n'
              '        .super = OBJ_DemoRhy,\n'
              '        .sub = NAKA_NONE,\n'
              '        .next = OBJ_NakaHdr_Perf2MeasureBoxData,\n'
              '        .prev = OBJ_DemoRhy_PsWideToggle_2,\n'
              '        .flag = VF_Const,\n'
              '        .rect = NAKA_XYWH(244, 216, 72, 23),\n'
              '        .font = idCHARA1,\n'
              '        .stron = NAKA_ADDR(NakaWidget_Perf3RhythmSel_StrOn),\n'
              '        .stroff = NAKA_ADDR(NakaWidget_Perf3RhythmSel_StrOff),\n'
              '        .onoff = RAM_Rhythm_PsWideToggle_OnOff,\n'
              '        .editsw = ES_Bottom7,\n'
              '        .editsw2 = ES_Bottom8,\n'
              '    },\n', dp, 'w119 initializer')
    dp = sub1(r'^extern const char INTETC45;\n', '', dp, 'INTETC45 extern')
    wr(dp_c, dp)
    ld = rd(dp_ld)
    ld = sub1(r'^INTETC45 = 0x000000EE;\n', '', ld, 'INTETC45 link symbol')
    wr(dp_ld, ld)

    # naka_widget_tables_1.c: the tail goes, BASE moves 8 bytes up.
    t1 = sub1(r'^#define BASE  0x%08Xu$' % t1_base, '#define BASE  0x%08Xu' % (t1_base + 8), t1, 'BASE')
    hb = re.search(r'^ \* Base ROM address: 0x([0-9A-F]{6})$', t1, re.M)
    t1 = sub1(r'^ \* Base ROM address: 0x%s$' % hb.group(1), ' * Base ROM address: 0x%06X' % (int(hb.group(1), 16) + 8),
              t1, 'header base')
    t1 = sub1(r'^ \* Total size: 12878 bytes$', ' * Total size: 12870 bytes', t1, 'header size')
    t1 = sub1(r'sizeof\(naka_widget_tables_1_t\) == 12878,\n    "naka_widget_tables_1 must be exactly 12878 bytes"',
              'sizeof(naka_widget_tables_1_t) == 12870,\n    "naka_widget_tables_1 must be exactly 12870 bytes"',
              t1, 'size assert')
    t1 = sub1(r'^    /\* -+\n     \* NakaWidget_Perf3RhythmSel_Tail -- .*?\* -+ \*/\n'
              r'    uint8_t NakaWidget_Perf3RhythmSel_Tail\[8\];\n',
              '    /* ---------------------------------------------------------------------\n'
              '     * The two captions of NakaWidget_Perf3RhythmSel (element 9 of Viewable\n'
              '     * slot 0xE3, the PsWideToggle at the end of naka_direct_play.c): its\n'
              '     * stroff (+30) points at the first "RHYTHM", its stron (+26) at the\n'
              '     * second, as elements 7 and 8 do (texts stroff, then stron).\n'
              '     * --------------------------------------------------------------------- */\n',
              t1, 'tail member')
    t1 = sub1(r'^    \.NakaWidget_Perf3RhythmSel_Tail = \{\n        0xA0, 0xDE, 0x03, 0x00, 0x06, 0x00, 0x07, 0x00,\n    \},\n',
              '', t1, 'tail initializer')
    wr(t1_c, t1)

    # The assembler: the record's .incbin grows, tables_1's offsets drop by 8.
    s = rd(dp_s)
    s = sub1(r'^; \[nakarest\] NakaWidget_Perf3RhythmSel  \+0x2fb8\.\.\+0x2fda \(0xe24034, 34 B\)\n'
             r'(; \[nakarest\] widget record, element 9 .*?\n; \[nakarest\] InitializeYoko\) \("DemoRhy"\): '
             r'PsWideToggle \(42 B\)\.)  Only 34 bytes are here: the\n; last 8, and the two "RHYTHM" captions, '
             r'are NakaWidget_Perf3RhythmSel_Tail and the labels after\n; it, at the start of '
             r'ui_widgets/naka_widget_tables_1\.s\.\n'
             r'NakaWidget_Perf3RhythmSel:\t\.incbin "includes/generated/naka_direct_play\.bin", 0x2FB8, 0x22\n',
             '; [nakarest] NakaWidget_Perf3RhythmSel  +0x2fb8..+0x2fe2 (0xe24034, 42 B)\n\\1  Its two\n'
             '; "RHYTHM" captions are the first labels of ui_widgets/naka_widget_tables_1.s.\n'
             'NakaWidget_Perf3RhythmSel:\t.incbin "includes/generated/naka_direct_play.bin", 0x2FB8, 0x2A\n',
             s, 'direct_play incbin')
    wr(dp_s, s)
    s = rd(t1_s)
    s = sub1(r'^; -+\n; NakaWidget_Perf3RhythmSel_Tail -- .*?; -+\n'
             r'NakaWidget_Perf3RhythmSel_Tail:\t\.incbin "includes/generated/naka_widget_tables_1\.bin", 0x0, 0x8\n',
             '; -----------------------------------------------------------------------------\n'
             '; The two captions of NakaWidget_Perf3RhythmSel (element 9 of Viewable slot\n'
             '; 0xe3, the PsWideToggle at the end of direct_play_medley_screens.s): its\n'
             '; stroff (+30) points at NakaWidget_Perf3RhythmSel_StrOff, its stron (+26) at\n'
             '; NakaWidget_Perf3RhythmSel_StrOn.\n'
             '; -----------------------------------------------------------------------------\n',
             s, 'tail label')
    n = [0]

    def shift(mm):
        off = int(mm.group(1), 16)
        assert off >= 8
        n[0] += 1
        return '"includes/generated/naka_widget_tables_1.bin", 0x%X,' % (off - 8)
    s = re.sub(r'"includes/generated/naka_widget_tables_1\.bin", 0x([0-9A-Fa-f]+),', shift, s)
    wr(t1_s, s)

    jp = os.path.join(ROOT, a.tree, 'maincpu', 'includes', '%s_c_divergence.json' % a.tree)
    if os.path.exists(jp) and re.search(r'"naka_widget_tables_1\.bin":', rd(jp)):
        jt = rd(jp)
        jt = sub1(r'("naka_widget_tables_1\.bin":\s*\{\s*"raw":\s*\{\},\s*"reloc":\s*\[\],\s*"size":\s*)12878',
                  '\\g<1>12870', jt, 'json size')
        wr(jp, jt)
    print('naka_join_perf3rhythmsel %s: record typed, %d tables_1 .incbin offsets moved' % (a.tree, n[0]))


if __name__ == '__main__':
    main()
