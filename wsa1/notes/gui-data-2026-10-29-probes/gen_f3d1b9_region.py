#!/usr/bin/env python3
"""gen_f3d1b9_region.py -- respell prom_b 0xF3D1B9-0xF3D9A6 from its REAL entry points, as display-list macros.

QUESTION IT ANSWERS
  "What is in the 1,998 bytes between StepSelectAddrTable_F3D089's end and NoteNameTable_F3D9A7?"  An earlier
  emitter walked it as ONE interpreter-A list of 88 records from 0xF3D1B9 to 0xF3D5E4, and two more as a
  '2 unlabelled bytes + 64-entry fixed-stride array'.  Read instead from the code that names addresses in it --
  every 24-bit value in [0xF3D1B9, 0xF3D9A7) in either image, found by a byte scan (--refs) -- it is:

    0xF3D1B9  4 x 35 bytes, interpreter A   sub_F81EF3 (prom_a 0xF81F08): XIY = here, XIX = here + 35 * min(4, n)
    0xF3D245  3 x 90 bytes, interpreter A   sub_F81F1A (0xF81F1A): base + 0 / 0x5A / 0xB4 by BC, XIX = base + 10
                                            + 20 * count
    0xF3D353 / 35D / 367   B op 06          sub_F81C90 via T_DLB_Handler_Decimal_2, one record each
    0xF3D371 / 376 / 37B   A op 06 text     sub_F81C90 via T_DLHandler_IX_Text, one record each ('-' when >= 1000)
    0xF3D380               B op 00          0xF81B65 / 0xF81BF6 via T_DLB_Handler_Decimal
    0xF3D38A               B op 02          sub_F81C15 via T_DLB_Handler_StringTable
    0xF3D399               5 x 4 characters the string table the 15-byte records below name (+0x07 = 0xF3D399)
    0xF3D3AD .. 0xF3D9A6   102 x 15 bytes   interpreter-B op-02 records, a FIXED-STRIDE run: sub_F81C33 runs
                                            [0xF3D3AD or 0xF3D3CB, 0xF3D3E9 or 0xF3D407) through
                                            T_DisplayListB_Run; nothing in either image names an address from
                                            0xF3D408 on.  Two of the records' +1 bytes are not their 15
                                            (0x0D at 0xF3D5D9, 0x14 at 0xF3D7E6), which is why the old walk
                                            broke at 0xF3D5E5 -- the "2 unlabelled bytes" there are the +0x0D
                                            position of the record at 0xF3D5D8.

  Each piece is emitted with the macros of include/wsa1_gui.inc; a record whose +1 byte is not its natural
  length is written with `length=`.  The gate is the proof: make gate-wsa1.

RUN (inside wsa1/, after make all)
  python3 notes/gui-data-2026-10-29-probes/gen_f3d1b9_region.py --refs     # the byte scan
  python3 notes/gui-data-2026-10-29-probes/gen_f3d1b9_region.py            # print the emission
  python3 notes/gui-data-2026-10-29-probes/gen_f3d1b9_region.py --apply    # splice it into the module
"""
import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, os.path.join(ROOT, "scripts", "tools"))
import gui_display_list_macros as G  # noqa: E402

ROMB = open(os.path.join(ROOT, "original_ROMs", "wsa1_prom_b.ic13"), "rb").read()
ROMA = open(os.path.join(ROOT, "original_ROMs", "wsa1_prom_a.ic12"), "rb").read()
BASE = 0xF00000
WARN = "\u26a0".encode("utf-8").decode("latin-1")   # the tree's UTF-8 warning sign, in a latin-1 round trip
LO, HI = 0xF3D1B9, 0xF3D9A7
MODULE = os.path.join(ROOT, "prom_b", "modules", "f39000_f3f3ff_sequencer_job_display_lists.s")
LABELS = {          # entry points: the immediates prom_a loads (see --refs); names from what each draws
    0xF3D1B9: "DL_F3D1B9", 0xF3D245: "DL_F3D245",
    0xF3D353: "StepRecord_PrevRowNumber_DL", 0xF3D35D: "StepRecord_CurrentRowNumber_DL",
    0xF3D367: "StepRecord_NextRowNumber_DL", 0xF3D371: "StepRecord_PrevRowNoNumber_DL",
    0xF3D376: "StepRecord_CurrentRowNoNumber_DL", 0xF3D37B: "StepRecord_NextRowNoNumber_DL",
    0xF3D380: "DL_F3D380", 0xF3D38A: "StepRecord_MsgLine_DL", 0xF3D399: "DLTable_BlankEndRep",
    0xF3D3AD: "StepRecord_PrevRow_DL", 0xF3D3CB: "StepRecord_CurrentRow_DL", 0xF3D3E9: "StepRecord_NextRow_DL",
    0xF3D407: "StepRecord_MarkGrid_DL", 0xF3D56F: "StepRecord_ChordSymbolGrid_DL",
}


def b(a, n=1):
    return ROMB[a - BASE:a - BASE + n]


def refs():
    out = []
    for img, base, data in (("prom_a", 0xF80000, ROMA), ("prom_b", BASE, ROMB)):
        for i in range(len(data) - 3):
            if data[i + 3] == 0 and data[i + 2] == 0xF3:
                v = data[i] | data[i + 1] << 8 | 0xF30000
                if LO <= v < HI:
                    out.append((img, base + i, v))
    return out


def record(ctx, a, interp, natural=None):
    op, ln = b(a)[0], b(a + 1)[0]
    size = natural or ln
    rec = G.Rec(op, size if interp == 'A' else G.B_LEN[op], interp, [('b', x) for x in b(a, size)], [])
    mac, args = G.emit(rec, ctx)
    if interp == 'B' and ln != G.B_LEN[op]:
        args.append("length=%d" % ln)
    return size, "\t%s\t%s" % (mac, ", ".join(args))


def emission():
    ctx = G.Ctx("prom_b")
    o = []
    H = o.append
    H("; ------------------------------------------------------------------")
    H("; 0xF3D1B9-0xF3D9A6 -- the step-record screen's lists, read from the code that enters them")
    H(";")
    H("; Re-framed 2026-10-29 (lane gui-wsa1).  An earlier walk read 0xF3D1B9-0xF3D5E4 as ONE")
    H("; interpreter-A list of 88 records, and 0xF3D5E5 as '2 unlabelled bytes' before a 64-entry")
    H("; array.  The addresses prom_a names in this span -- a byte scan of both images finds 15")
    H("; prom_a immediates, plus the 24 +0x07 pointers of the records below to DLTable_BlankEndRep;")
    H("; --refs lists them -- give this layout instead:")
    H(";   DL_F3D1B9   4 x 35 bytes, A: sub_F81EF3 runs [here, here + 35 * min(4, n))")
    H(";   DL_F3D245   3 x 90 bytes, A: sub_F81F1A runs [base, base + 10 + 20 * count),")
    H(";               base = here + 0 / 0x5A / 0xB4")
    H(";   StepRecord_*RowNumber_DL / _NoNumber_DL, DL_F3D380, StepRecord_MsgLine_DL (MsgLine_Text, the bottom line): single records that sub_F81C90,")
    H(";               0xF81B65 and sub_F81C15 hand to one")
    H(";               interpreter handler each (T_DLB_Handler_Decimal_2, T_DLHandler_IX_Text,")
    H(";               T_DLB_Handler_Decimal, T_DLB_Handler_StringTable)")
    H(";   DLTable_BlankEndRep   the 5 x 4-character table the 15-byte records name")
    H(";   StepRecord_PrevRow_DL .. 102 interpreter-B op-02 records at a FIXED 15-byte stride to 0xF3D9A6:")
    H(";     records 0-5   the three measure rows: each row's 30-character text (StepRecord_PrevRowText,")
    H(";                   _CurrentRowText, _NextRowText) and its marker byte.  sub_F81C33 runs")
    H(";                   [StepRecord_PrevRow_DL or _CurrentRow_DL, StepRecord_NextRow_DL or _MarkGrid_DL)")
    H(";                   through T_DisplayListB_Run: the previous row only when (0x0F5E) != 0, the")
    H(";                   next only when (0x0F62) != 0 -- the same words sub_F81C90 draws as the rows'")
    H(";                   numbers (StepRecord_*RowNumber_DL, or '-' from 1000 on)")
    H(";     records 6-29  StepRecord_MarkGrid_DL: 24 cells, 3 rows x 8 at the rows' own y (52, 97,")
    H(";                   142), cell n = UI_DrawScratch+n through DLTable_BlankEndRep (blank, END,")
    H(";                   REP, two glyphs)")
    H(";     records 30-101 StepRecord_ChordSymbolGrid_DL: 24 chord symbols on the same grid, three")
    H(";                   records each -- root (NoteNameTable_F3D9A7), quality (ChordQualityTable_F3D9C7),")
    H(";                   tail (ChordTailTable_F3DA67)")
    H(";   " + WARN + " RECORDS 6-101 HAVE NO READER IN EITHER IMAGE, and that is a measurement, not a gap in")
    H(";   reading: (1) no 24-bit value in either image names an address from 0xF3D408 to 0xF3D9A6")
    H(";   (--refs); (2) the image's only stride-15 index computations, `muls HL,0x000f` at prom_b")
    H(";   0xF7E31D (TrackAssign_DrawSelectedPart_DL) and `mul C,0x0f` at prom_a 0xFCABE5 (the part")
    H(";   note lists), index other arrays; (3) every list end any call site passes in this span is")
    H(";   StepRecord_NextRow_DL or StepRecord_MarkGrid_DL; (4) no other record in prom_b draws")
    H(";   through DLTable_BlankEndRep or the three chord tables.  They read as an older build's step-")
    H(";   record grid left in the image (cf. the OldBuild_* data); that reading is an inference.")
    H(";   Two records' +1 bytes are not 15 -- 0x0D at 0xF3D5D9, 0x14 at 0xF3D7E6 -- and are written")
    H(";   with length=; the old walk stopped at the first of them, and the '2 unlabelled bytes' it")
    H(";   left at 0xF3D5E5 are that record's own +0x0D position.  The label the old walk put at")
    H(";   0xF3D5E7 (StepRecordChordFieldArray_F3D5E7) fell inside a chord symbol and is gone.")
    H("; Generated by notes/gui-data-2026-10-29-probes/gen_f3d1b9_region.py (--refs: the scan).")
    H("; ------------------------------------------------------------------")
    a = LO
    while a < HI:
        if a in LABELS:
            o.append("%s:" % LABELS[a])
        if a == 0xF3D399:
            for k in range(5):
                o.append("\t.ascii\t%s" % G.qstring(b(a + 4 * k, 4)))
            a += 20
            continue
        interp = 'B' if a in (0xF3D353, 0xF3D35D, 0xF3D367, 0xF3D380, 0xF3D38A) or a >= 0xF3D3AD else 'A'
        natural = 15 if a >= 0xF3D3AD else None
        n, text = record(ctx, a, interp, natural)
        o.append(text)
        a += n
    assert a == HI
    return o


def splice(new):
    lines = open(MODULE, "rb").read().decode("latin-1").split("\n")
    i = lines.index("DL_F3D1B9:")
    while lines[i - 1].startswith(";"):
        i -= 1
    j = lines.index("NoteNameTable_F3D9A7:")
    while lines[j - 1].startswith(";"):
        j -= 1
    while not lines[j - 1].strip():
        j -= 1
    return "\n".join(lines[:i] + new + lines[j:])


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--refs", action="store_true")
    ap.add_argument("--apply", action="store_true")
    a = ap.parse_args()
    if a.refs:
        for img, at, v in refs():
            print("%s 0x%06X names 0x%06X" % (img, at, v))
        return
    new = emission()
    if a.apply:
        data = splice(new).encode("latin-1")    # read and ENCODE before opening for writing
        open(MODULE, "wb").write(data)
        print("spliced %d lines into %s" % (len(new), os.path.relpath(MODULE, ROOT)))
    else:
        print("\n".join(new))


if __name__ == "__main__":
    main()
