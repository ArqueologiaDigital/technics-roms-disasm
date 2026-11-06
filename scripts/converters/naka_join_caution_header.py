#!/usr/bin/env python3
r"""naka_join_caution_header.py -- put ErrorDialog_CautionHeader (element 8 of Viewable slot 0xF4) in one file.

QUESTION ANSWERED
-----------------
"Why is the Label record ErrorDialog_CautionHeader untyped?" (register item N-2f640c1d).  Its 32 bytes
began with the last line of ui_widgets/control_menu_screens.s (`ErrorDialog_CautionHeader:` + `.byte
0x2b, 0x00`, the class id's low half) and went on in extensions/extension_data.s right after that
file's `.include` (`.byte 0x60, 0x01` + the `.short` / `.long` rows), so no block of plain data lines
under its label covers the record and naka_asm_records.py --apply skips it.  The label and its two
bytes move to extension_data.s, after the `.include`, in front of the rest; --apply then writes it as
one NAKA_REC_Label call like elements 9-12.  The image does not change (make gate).

RUN (repository root), per tree v10, v9, v7:
    python3 scripts/converters/naka_join_caution_header.py --tree v10
    make <tree's program ROM>
    python3 scripts/converters/naka_asm_records.py --tree v10 --apply
"""
import argparse
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TAIL = ("ErrorDialog_CautionHeader:\n"
        "\t.byte 0x2b, 0x00\t; class id 0x0160002b (Label), low half: index 0x2b")
NOTE = ("; (ErrorDialog_CautionHeader, element 8, follows this file's .include in extensions/extension_data.s:\n"
        ";  until 2026-11-06 its first two bytes ended this file -- scripts/converters/naka_join_caution_header.py)")
OLD_REST = "\t.byte 0x60, 0x01\t; element 8: header bytes 2-3\n"
NEW_REST = "ErrorDialog_CautionHeader:\n\t.byte 0x2b, 0x00, 0x60, 0x01\n"
OLD_COMMENT = ("; links are checked by scripts/analysis/ext_lane_checks.py test1.  Element 8\n"
               "; begins 2 bytes before this file resumes: its type byte 0x2B and the 0x00\n"
               "; after it are the last two bytes of the control_menu_screens.s blob.\n")
NEW_COMMENT = "; links are checked by scripts/analysis/ext_lane_checks.py test1.\n"


def rd(p):
    return open(p, 'rb').read().decode('latin-1')


def wr(p, t):
    open(p, 'wb').write(t.encode('latin-1'))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--tree', required=True, choices=['v10', 'v9', 'v7'])
    a = ap.parse_args()
    cm = os.path.join(ROOT, a.tree, 'maincpu', 'ui_widgets', 'control_menu_screens.s')
    ex = os.path.join(ROOT, a.tree, 'maincpu', 'extensions', 'extension_data.s')
    c, e = rd(cm), rd(ex)
    if not c.rstrip('\n').endswith(TAIL):
        sys.exit('naka_join_caution_header: %s: tail not found (already converted?)' % a.tree)
    c = c.rstrip('\n')[:-len(TAIL)] + NOTE + '\n'
    for old, new in ((OLD_REST, NEW_REST), (OLD_COMMENT, NEW_COMMENT)):
        if e.count(old) != 1:
            sys.exit('naka_join_caution_header: %s: extension_data.s text not found' % a.tree)
        e = e.replace(old, new)
    wr(cm, c)
    wr(ex, e)
    print('naka_join_caution_header %s: ErrorDialog_CautionHeader moved to extension_data.s' % a.tree)


if __name__ == '__main__':
    main()
