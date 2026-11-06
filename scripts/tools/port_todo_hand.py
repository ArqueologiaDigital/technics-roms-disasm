#!/usr/bin/env python3
r"""The `; TODO(port)` rows of the ported KN5000 trees (v6, v5) that were read by hand.

QUESTION THIS ANSWERS
    After port_todo_typed.py, port_todo_naka.py and disassemble_port_todo.py, a few TODO(port) rows are
    left whose meaning no generic rule reaches: what are they, and does each tree stay byte-identical
    when they are written as that?  This script is the list (each edit with its evidence) and redoes
    it.  Run it last in the sequence of v6/maincpu/README.md and v5/maincpu/README.md.

THE EDITS (lane open10/v6v5-port, 2026-11-06)
  1. scoop TEMPO templates (v6, v5; display/scoop_display.s).  The port left the two 25-character
     " TEMPO <glyph>=" templates that DisplayStr_ShowTempoLine copies to 0x0ECF as rows under the
     v6-only label DisplayStr_ShowTempoLine_Data, which the routine loads, with the 0x93 variant
     loaded as a number (`ld xiy, 0xefedbf`, v5 0xefeda7).  It put v7's names Str_TempoEq /
     DisplayStr_BytecodeBlock_C_Tbl on the second pair -- the templates that the following routine,
     v7's DisplayStr_RedrawStatusAndTempoLine (here SqStep_ShowTempoPopup, its caller at
     SqStep_ShowCursorEventPopup as in v7), loads -- and held most of that pair as faux instructions
     (`ld xiy, 0x204f504d` = "EMPO ", `ld w, 32:opc` = two spaces); its local label is v7's
     DisplayStr_RedrawStatusAndTempoLine_Helper3_Skip (v6 had DisplayStr_BytecodeBlock_C_Skip, a name
     v7 does not have).  Evidence: the two `ld xiy`
     operands of each routine, and v7's text (v7/maincpu/display/scoop_display.s).  Each name goes
     back on v7's thing; the four templates are `.ascii` / `.byte` as in v7; v6's
     port_dropped_labels.txt loses DisplayStr_TempoString and DisplayStr_BytecodeBlock_C_Tbl2.
  2. AccPatch_ChannelToParamTable / AccPatch_ChannelToRecordPtr (v6, v5; sequencer/
     accompaniment_engine.s): v7's 16-byte table and its six 32-bit RAM record pointers (`.long 0, 0,
     0x2bf8, ...`); v6 / v5 have the same table and pointers 0x1c lower (0x2bdc, ...), which the port
     wrote as rows and two `.asciz ""`.
  3. v5 NakaWidget_MSCTSEL_13_AcMstStyle2GridBox (ui_widgets/control_menu_screens.s): the record's
     rect and color, which the port split between a row and a `.long SeqByteBlock_PathNormalize_Skip16`
     line that only equals the bytes (y2 = 212, color = 0xf5 CL_WallPattern; v6's record, typed
     whole by port_todo_naka.py, has the same values).
  4. v5 SeMenu_DrawPartRadioButtons_Records2_Data (audio/sound_editor_ui.s): two GraphicsRender
     record lists v6 does not have -- `sd_blit SeBitmap_RadioOn` + `sd_ptext ... "1ST"` / "2ND" -- that
     the bounds table right after them (SeMenu_DrawPartRadioButtons_Records2_Data2) delimits; the
     sd_blit / sd_ptext macros of the same file give their layout.
  Left as rows, on purpose: the halves of pointers that a C slice boundary cuts (widget_names_charmap.s
  2 B in v6 / v5 and 3 B in v5, extension_data.s 2 B in v5): the assembler takes `@lo16` / `@hi16`
  only in instruction immediates (`.short Sym@lo16` is an error), so those bytes cannot be spelled by
  name.

RUN
    python3 scripts/tools/port_todo_hand.py --tree v6     (or v5)
    Each edit is skipped when the tree has it already; the tree is rebuilt and the files are restored
    if the image changed.
"""
import argparse
import os
import re
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def rd(p):
    return open(p, "rb").read().decode("latin-1")


def wr(p, s):
    open(p, "wb").write(s.encode("latin-1"))


TEMPO = ('\t.ascii\t"  TEMPO  "\n\t.byte\t0x15\n\t.ascii\t"=              "\n',
         '\t.ascii\t"  TEMPO  "\n\t.byte\t0x93\n\t.ascii\t"=              "\n')


def scoop_tempo(tree, s):
    m = re.search(r"\tld\txiy, DisplayStr_ShowTempoLine_Data\n((?:.*\n){1,4}?)\tld\txiy, 0x([0-9a-f]{6})\n", s)
    if not m:
        return None
    s = s[:m.start()] + "\tld\txiy, Str_TempoEq\n" + m.group(1) + "\tld\txiy, DisplayStr_BytecodeBlock_C_Tbl\n" + s[m.end():]
    a = s.index("DisplayStr_ShowTempoLine_Data:\n")
    # the porter's note (v5 carries v6's, which names v7 and v6)
    me = re.compile(r"^; port: \w+'s label DisplayStr_BytecodeBlock_C_Tbl2 is not in \w+ -- no \w+ bytes correspond "
                    r"to what it named\n", re.M).search(s, a)
    b = me.end()
    old = s[a:b]
    m2 = re.search(r"^SqStep_ShowTempoPopup:\n((?:.*\n)+?\tret\n)", old, re.M)
    body = m2.group(1).replace("\tld\txiy, Str_TempoEq\n", "\tld\txiy, DisplayStr_TempoString\n") \
        .replace("\tld\txiy, DisplayStr_BytecodeBlock_C_Tbl\n", "\tld\txiy, DisplayStr_BytecodeBlock_C_Tbl2\n") \
        .replace("DisplayStr_BytecodeBlock_C_Skip", "DisplayStr_RedrawStatusAndTempoLine_Helper3_Skip")
    new = ("; Str_TempoEq / DisplayStr_BytecodeBlock_C_Tbl: the 25-character TEMPO templates DisplayStr_ShowTempoLine copies\n"
           ";   to 0x0ECF: glyph 0x15, or 0x93 when (PANEL_STYLE) = 7 and (PANEL_STYLE+1) = 2.\n"
           "Str_TempoEq:\n" + TEMPO[0] + "DisplayStr_BytecodeBlock_C_Tbl:\n" + TEMPO[1] +
           "; DisplayStr_RedrawStatusAndTempoLine: TEMPO line for a tempo event stored at the song-data cursor: marks the status\n"
           ";   bar (region 0) for redraw, blanks the text line, copies the 25-character ' TEMPO <glyph>=' template to 0x0ECF\n"
           ";   (DisplayStr_TempoString, or DisplayStr_BytecodeBlock_C_Tbl2 with glyph 0x93 when (0xFC5A) = 7 and (0xFC5B) = 2),\n"
           ";   marks region 5, writes the tempo (DisplayStr_WriteTempoValue) and marks region 3: DisplayStr_ShowTempoLine with\n"
           ";   the region-0 redraw in front.  Basis: callers + body (SqStep_ShowCursorEventPopup calls it, as in v7).\n"
           "DisplayStr_RedrawStatusAndTempoLine:\n" + body +
           "; DisplayStr_TempoString / DisplayStr_BytecodeBlock_C_Tbl2: the same two templates, read by\n"
           ";   DisplayStr_RedrawStatusAndTempoLine.\n"
           "DisplayStr_TempoString:\n" + TEMPO[0] + "DisplayStr_BytecodeBlock_C_Tbl2:\n" + TEMPO[1])
    s = s[:a] + new + s[b:]
    s = re.sub(r"^(\tcall\t)SqStep_ShowTempoPopup$", r"\1DisplayStr_RedrawStatusAndTempoLine", s, flags=re.M)
    return s


ACC_OLD = ("AccPatch_ChannelToParamTable:\n"
           "\t.asciz\t\"\"\n"
           "; TODO(port): v6 bytes with no v7 line -- disassemble\n"
           "\t.byte\t0x00, 0x00, 0x00, 0xd7, 0x00, 0xd4, 0x00, 0xd5\n"
           "\t.byte\t0x00, 0xd6, 0x00, 0x00, 0x00, 0x00, 0x00\n"
           "\t.asciz\t\"\"\n"
           "; TODO(port): v6 bytes with no v7 line -- disassemble\n"
           "\t.byte\t0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xdc\n"
           "\t.byte\t0x2b, 0x00, 0x00, 0xdc, 0x2c, 0x00, 0x00, 0xdc\n"
           "\t.byte\t0x2d, 0x00, 0x00, 0xdc, 0x2e, 0x00, 0x00\n")
ACC_NEW = ("AccPatch_ChannelToParamTable:\t.byte\t0, 0, 0, 0, 0xd7, 0, 0xd4, 0, 0xd5, 0, 0xd6, 0, 0, 0, 0, 0\n"
           "AccPatch_ChannelToRecordPtr:\t.long\t0, 0, 0x2bdc, 0x2cdc, 0x2ddc, 0x2edc\t; v7: 0x2bf8 ...\n")

MSCTSEL_OLD = ("\t.short\tVF_Const\t; AcMstStyle2GridBox flag\n"
               "; TODO(port): v6 bytes with no v7 line -- disassemble\n"
               "\t.byte\t0x28, 0x00, 0x40, 0x00, 0x35, 0x01\n"
               "\t.long\tSeqByteBlock_PathNormalize_Skip16\n")
MSCTSEL_NEW = ("\t.short\tVF_Const\t; AcMstStyle2GridBox flag\n"
               "\t.short\t40, 64, 309, 212\t; AcMstStyle2GridBox rect (x1, y1, x2, y2)\n"
               "\t.short\tCL_WallPattern\t; AcMstStyle2GridBox color\n")

RADIO_OLD = ("SeMenu_DrawPartRadioButtons_Records2_Data:\n"
             "; TODO(port): v5 bytes with no v6 line -- disassemble\n"
             "\t.byte\t0x03, 0x0c\n"
             "\t.long\tSeBitmap_RadioOn\n"
             "; TODO(port): v5 bytes with no v6 line -- disassemble\n"
             "\t.byte\t0x9a, 0x12, 0x02, 0x00, 0x0c, 0x00, 0x17, 0x09\n"
             "\t.byte\t0x21, 0x00, 0x7a, 0x00, 0x31, 0x53, 0x54\n"
             "SeMenu_DrawPartRadioButtons_Records2_Data2_Item2:\n"
             "; TODO(port): v5 bytes with no v6 line -- disassemble\n"
             "\t.byte\t0x03, 0x0c\n"
             "\t.long\tSeBitmap_RadioOn\n"
             "; TODO(port): v5 bytes with no v6 line -- disassemble\n"
             "\t.byte\t0x4a, 0x17, 0x02, 0x00, 0x0c, 0x00, 0x17, 0x09\n"
             "\t.byte\t0x21, 0x00, 0x98, 0x00, 0x32, 0x4e, 0x44\n")
RADIO_NEW = ("; v5's two-part ON radio buttons (v6 has no such lists): SeBitmap_RadioOn and \"1ST\" on row y 119, then\n"
             ";   SeBitmap_RadioOn and \"2ND\" on row y 149; the bounds table SeMenu_DrawPartRadioButtons_Records2_Data2\n"
             ";   right after them delimits the two lists for GraphicsRender_ProcessEntries.\n"
             "SeMenu_DrawPartRadioButtons_Records2_Data:\n"
             "\tsd_blit\tSeBitmap_RadioOn, 119*40+2, 2, 12\n"
             "\tsd_ptext\t0x17, 9, 33, 122, \"1ST\"\n"
             "SeMenu_DrawPartRadioButtons_Records2_Data2_Item2:\n"
             "\tsd_blit\tSeBitmap_RadioOn, 149*40+2, 2, 12\n"
             "\tsd_ptext\t0x17, 9, 33, 152, \"2ND\"\n")

SRC = {"v6": "v7", "v5": "v6"}


def text_edit(old, new):
    def f(tree, s):
        if old not in s:
            return None
        assert s.count(old) == 1
        return s.replace(old, new)
    return f


EDITS = [
    ("scoop TEMPO templates", ("v6", "v5"), "display/scoop_display.s", scoop_tempo),
    ("AccPatch_ChannelToRecordPtr", ("v6", "v5"), "sequencer/accompaniment_engine.s", text_edit(ACC_OLD, ACC_NEW)),
    ("MSCTSEL_13 rect / color", ("v5",), "ui_widgets/control_menu_screens.s", text_edit(MSCTSEL_OLD, MSCTSEL_NEW)),
    ("two-part ON radio lists", ("v5",), "audio/sound_editor_ui.s", text_edit(RADIO_OLD, RADIO_NEW)),
]

# names an edit gives the tree that its port_dropped_labels.txt listed as missing
UNDROPPED = {"v6": ["DisplayStr_TempoString", "DisplayStr_BytecodeBlock_C_Tbl2"]}


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--tree", required=True, choices=("v6", "v5"))
    a = ap.parse_args()
    files = {}
    for name, trees, rel, fn in EDITS:
        if a.tree not in trees:
            continue
        p = os.path.join(ROOT, a.tree, "maincpu", rel)
        s = files.get(p, rd(p))
        r = fn(a.tree, s)
        if r is None:
            print("%-32s %s: not there (done already?)" % (name, a.tree))
            continue
        files[p] = r
        print("%-32s %s: applied" % (name, a.tree))
    dl = os.path.join(ROOT, a.tree, "maincpu", "port_dropped_labels.txt")
    if UNDROPPED.get(a.tree) and os.path.exists(dl):
        s = files.get(dl, rd(dl))
        keep = [ln for ln in s.split("\n") if ln.split("\t")[0] not in UNDROPPED[a.tree]]
        if "\n".join(keep) != s:
            files[dl] = "\n".join(keep)
    if not files:
        return
    backup = {p: rd(p) for p in files}
    for p, s in files.items():
        wr(p, s)
    r = subprocess.run(["make", "-s", "rebuilt_ROMs/kn5000_%s_program.llvm.rom" % a.tree], cwd=ROOT,
                       capture_output=True, text=True)
    built = os.path.join(ROOT, "rebuilt_ROMs", "kn5000_%s_program.llvm.rom" % a.tree)
    ref = os.path.join(ROOT, "original_ROMs", "kn5000_%s_program.rom" % a.tree)
    if r.returncode != 0 or open(built, "rb").read() != open(ref, "rb").read():
        for p, s in backup.items():
            wr(p, s)
        sys.exit("not byte-identical; files restored\n" + r.stderr[-3000:])
    print("%s: byte-identical" % a.tree)


if __name__ == "__main__":
    main()
