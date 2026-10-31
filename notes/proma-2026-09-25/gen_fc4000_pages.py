#!/usr/bin/env python3
r"""Frame prom_a 0xFC4000-0xFC52F7 (4,856 B) by its readers -- which are in prom_b.

QUESTION THIS ANSWERS
    prom_a's header for this span said "Read by: STILL NOT ESTABLISHED ...
    no reader is identified in prom_a's own control-flow graph", and framed it as
    one display-list blob, a 13 x 13 name table, 12 unclassified bytes and a
    2,580-byte "172 rows x 15 bytes" bitmap.  The readers are in PROM_B, whose
    source spells its immediates in decimal (`ld xiy, 16531456` = 0x00FC4000),
    which is why a hex search never found them:

      SoundEditDigitalEffect_Paint        prom_b 0xF099F5
      SoundEditDigitalEffect_RepaintField prom_b 0xF09AA5
      sub_F09AF1 + PtrTable_F09B7B        prom_b 0xF09AF1 (the eight widgets)
      SoundEditCopy_Paint                 prom_b 0xF09B9B
      SoundEditCopy_RepaintField          prom_b 0xF09C08
      sub_F09CA9 (DispatchTable_F5B9F8[0]) prom_b 0xF09CA9, and 0xF5BF6D
      sub_F5CADD                          prom_b 0xF5CBAD
    plus, INSIDE this span, interpreter-B records whose +7 long points at the
    name/rectangle tables (op 02 = string table, entry width at +0x0B; op 03 =
    8-byte entries; FINDINGS-ui-display-list-interpreter-b.md's handler table).

    This script lists every object with its reader, asserts that each display
    list's length bytes walk EXACTLY from its start to its end, that every
    pointer in every array lands on an object or record start of this framing,
    that every name table's width is the one its record states, and that the
    objects tile 0xFC4000..0xFC52F8 -- and with --apply writes the typed source.

RUN
    python3 notes/proma-2026-09-25/gen_fc4000_pages.py           # check + summary

--apply IS RETIRED (2026-10-31, lane media-cleanup).  It wrote this span's typed source into
wsa1_prom_a.s in the 2026-09-25 form.  The source has moved on since, and re-running it would
have undone all of it:
    98cabf6d5  the span moved to its own module,
               wsa1/prom_a/modules/fc4000_fc53ff_digital_effect_screen_data.s;
    6e9ea3b49  the display lists became one macro per record kind (include/wsa1_gui.inc);
    6f6138c09  the RAM cells and table pointers they spelled as numbers were named;
    cfb2e8ab1  the eight Widget_* pictograms became `.incbin "images/Widget_*.bin"` of bins
               scripts/build/wsa1_bitmaps.py builds from images/Widget_*.png (the .png is the
               source; the `.byte` rows this script emitted are gone);
    and the inline `; ADDR` comments it wrote are not allowed any more.
That module file is the authoritative source and is edited by hand.  The check above still
reads only the reference ROMs, so it still answers this script's question.
"""
import argparse
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import srcmap  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(HERE))
PROM_B = open(os.path.join(ROOT, "wsa1", "original_ROMs", "wsa1_prom_b.ic13"), "rb").read()
LO, HI = 0xFC4000, 0xFC52F8
B = srcmap.BASE
HTAB_A, HTAB_B = 0xF31D21, 0xF31DB1


def hand(tab, n):
    o = tab - 0xF00000
    return [int.from_bytes(PROM_B[o + 4 * k:o + 4 * k + 4], "little") for k in range(n)]


HA, HB = hand(HTAB_A, 36), hand(HTAB_B, 15)

# ------------------------------------------------------------------ the objects
# ("list", start, end, interp, name, reader-text, extra-entry-points)
# ("pairs"|"ptrs", start, count, name, reader-text)
# ("names", start, count, width, name, reader-text)
# ("rects", start, count, name, reader-text)
# ("widgets", start, count)
DE = "SoundEditDigitalEffect_Paint (prom_b 0xF099F5)"
DER = "SoundEditDigitalEffect_RepaintField (prom_b 0xF09AA5)"
CP = "SoundEditCopy_Paint (prom_b 0xF09B9B)"
CPR = "SoundEditCopy_RepaintField (prom_b 0xF09C08)"
PG0 = "sub_F09CA9 (prom_b 0xF09CA9, DispatchTable_F5B9F8[0])"
OBJ = [
    ("list", 0xFC4000, 0xFC40B4, "A", "DigitalEffect_Frame",
     DE + " at 0xF09A33: XIY = this, XIX = DigitalEffect_FrameEnds[type]; so a PREFIX "
     "of this list is drawn, ending at one of the four inner labels", [0xFC405A, 0xFC4078, 0xFC4096]),
    ("list", 0xFC40B4, 0xFC40F0, "A", "DigitalEffect_ValueFrames",
     DE + " at 0xF09A5F (type != 10) / 0xF09A58 (type 10: from the inner label), to 0xFC40F0",
     [0xFC40D2]),
    ("list", 0xFC40F0, 0xFC420F, "A", "DigitalEffect_Header",
     DE + " at 0xF09A0C (type != 10) / 0xF09A05 (type 10: from the inner label), to 0xFC420F; "
     "text INTENSITY, DIGITAL EFFECT, SOUND EDIT, TYPE, REVERB DEPTH", [0xFC410F]),
]
for s, e in [(0xFC420F, 0xFC4292), (0xFC4292, 0xFC4332), (0xFC4332, 0xFC4398), (0xFC4398, 0xFC4404),
             (0xFC4404, 0xFC4470), (0xFC4470, 0xFC44DC), (0xFC44DC, 0xFC4532)]:
    OBJ.append(("list", s, e, "A", "DigitalEffect_ParamLabels_%06X" % s,
                DE + " at 0xF09A2F, through DigitalEffect_ParamLabelLists[type]", []))
OBJ += [
    ("pairs", 0xFC4532, 12, "DigitalEffect_ParamLabelLists",
     DE + " at 0xF09A23: `ld A,(0x27B6) / sla 3,WA / ld XIZ,0x00FC4532 / add XIZ,XWA / "
     "ld XIY,(XIZ) / ld XIX,(XIZ+4) / call T_DisplayList_Run`"),
    ("list", 0xFC4592, 0xFC45D5, "B", "DigitalEffect_Values",
     DE + " at 0xF09A6D, to 0xFC45D5 (type != 10) or 0xFC45CA (type 10); " + DER +
     " runs the inner record 0xFC45A1..0xFC45BF alone (field 0)", [0xFC45A1, 0xFC45B0, 0xFC45BF, 0xFC45CA]),
    ("pairs", 0xFC45D5, 12, "DigitalEffect_ParamValueLists",
     DE + " at 0xF09A94: the same shape as DigitalEffect_ParamLabelLists, run by interpreter B"),
]
for s, e, p, n in [(0xFC4635, 0xFC4668, 0xFC4668, 6), (0xFC4680, 0xFC46BD, 0xFC46BD, 9),
                   (0xFC46E1, 0xFC470E, 0xFC470E, 5), (0xFC4722, 0xFC474A, 0xFC474A, 5),
                   (0xFC475E, 0xFC4788, 0xFC4788, 5), (0xFC479C, 0xFC47BF, 0xFC47BF, 4)]:
    OBJ.append(("list", s, e, "B", "DigitalEffect_ParamValues_%06X" % s,
                DE + " at 0xF09AA0, through DigitalEffect_ParamValueLists[type]", []))
    OBJ.append(("ptrs", p, n, "DigitalEffect_FieldRecords_%06X" % p,
                DER + " at 0xF09ABB (fields 1-6: `ld XIZ,0x00FC47CF / ld XIY,(XIZ+4*type)`) or 0xF09AD2 "
                "(field >= 7: 0xFC46BD), then RunDisplayListBFromPointerArray (prom_b 0xF09AE1): "
                "record [field] drawn alone"))
OBJ += [
    ("ptrs", 0xFC47CF, 12, "DigitalEffect_FieldRecordArrays",
     DER + " at 0xF09AAF: `ld XIZ,0x00FC47CF / ld C,(0x27B6) / sla 2,BC / ld XIY,(XIZ+BC)`"),
    ("ptrs", 0xFC47FF, 12, "DigitalEffect_FrameEnds",
     DE + " at 0xF09A3A: `ld XIZ,0x00FC47FF / ld C,(0x27B6) / sla 2,BC / ld XIX,(XIZ+BC)`, the END "
     "of the DigitalEffect_Frame prefix"),
    ("names", 0xFC482F, 12, 13, "DigitalEffect_TypeNames",
     "the interpreter-B op-02 record DigitalEffect_Values (0xFC4592): variable 0x27A6, mask 0x0F, "
     "+7 = this table, +0x0B entry width 13"),
    ("names", 0xFC48CB, 2, 6, "DigitalEffect_OutputNames",
     "the op-02 record at 0xFC45B0: variable 0x27A6, mask 0x40, shift 6, +7 = this table, width 6"),
    ("widgets", 0xFC48D7, 8),
    ("list", 0xFC4BA7, 0xFC4D77, "A", "SoundEditCopy_Frame", CP + " at 0xF09BA0; text COPY, SOUND EDIT, FROM, TO, TONE:, OPTION", []),
    ("list", 0xFC4D77, 0xFC4DEB, "A", "SoundEditCopy_ToneLabels", CP + " at 0xF09BBA when (0x27F5) != 1; text BANK:, 1st..4th TONE, SOUND:", []),
    ("list", 0xFC4DEB, 0xFC4E54, "A", "SoundEditCopy_DrumLabels", CP + " at 0xF09BE2 when (0x27F5) == 1; text DRUM KIT:, 1st/2nd TONE, DRUM SOUND:", []),
    ("list", 0xFC4E54, 0xFC4E8C, "B", "SoundEditCopy_ToneValues", CP + " at 0xF09BCD", []),
    ("list", 0xFC4E8C, 0xFC4EC4, "B", "SoundEditCopy_DrumValues", CP + " at 0xF09BF5", []),
    ("list", 0xFC4EC4, 0xFC4EE2, "B", "SoundEditCopy_Field5Values", CPR + " at 0xF09C36 (field 5)", []),
    ("list", 0xFC4EE2, 0xFC4EEC, "A", "SoundEditCopy_Field2Box", CPR + " at 0xF09C19 (field 2, layer 1)", []),
    ("rects", 0xFC4EEC, 5, "SoundEditCopy_ToneOptionRects",
     "the interpreter-B op-03 record at 0xFC4E81 (SoundEditCopy_ToneValues): variable 0x27A8, mask 0x0F, "
     "+7 = this table of 8-byte entries"),
    ("rects", 0xFC4F14, 3, "SoundEditCopy_DrumOptionRects",
     "the op-03 record at 0xFC4EB9 (SoundEditCopy_DrumValues): variable 0x27A8, +7 = this table"),
    ("names", 0xFC4F2C, 7, 10, "SoundEditCopy_OptionNames",
     "the op-02 records at 0xFC4E54 and 0xFC4E8C: variable 0x27A6, mask 0x0F, width 10"),
    ("names", 0xFC4F72, 4, 4, "SoundEditCopy_ToneBankNames",
     "the op-02 record at 0xFC4E72: variable 0x27A9, mask 0x0F, width 4"),
    ("names", 0xFC4F82, 3, 4, "SoundEditCopy_DrumBankNames",
     "the op-02 record at 0xFC4EAA: variable 0x27A9, mask 0x03, width 4"),
    ("names", 0xFC4F8E, 5, 3, "SoundEditCopy_ToneOrdinals",
     "the op-02 record at 0xFC4E63: variable 0x27A7, mask 0x0F, width 3"),
    ("names", 0xFC4F9D, 3, 3, "SoundEditCopy_DrumOrdinals",
     "the op-02 record at 0xFC4E9B: variable 0x27A7, mask 0x0F, width 3"),
    ("ptrs", 0xFC4FA6, 4, "SoundEditCopy_ToneFieldRecords",
     CPR + " at 0xF09C4D when (0x27F5) != 1, then RunDisplayListBFromPointerArray (prom_b 0xF09AE1)"),
    ("ptrs", 0xFC4FB6, 4, "SoundEditCopy_DrumFieldRecords",
     CPR + " at 0xF09C54 when (0x27F5) == 1, then RunDisplayListBFromPointerArray"),
]
_SEG = [0xFC4FC6 + 30 * k for k in range(12)]
for k, s in enumerate(_SEG):
    OBJ.append(("list", s, s + 30, "A", "DisplayList_%06X" % s,
                "sub_F5CADD (prom_b) at 0xF5CBAD: `ld XIX,0x00FC512E / ld XIZ,(XIX+4*(A-20)) / "
                "ld XIY,(XIZ) / ld XIX,(XIZ+4*B) / call T_DisplayList_Run`, B from (0x27D6+A-20); "
                "so a run of 1-3 consecutive 30-byte segments is drawn", []))
OBJ += [
    ("ptrs", 0xFC512E, 4, "SegmentArrays_FC512E",
     "sub_F5CADD (prom_b) at 0xF5CBAD, indexed by A-20 (see DisplayList_FC4FC6)"),
    ("ptrs", 0xFC513E, 4, "SegmentBounds_FC513E", "SegmentArrays_FC512E[0]: (XIZ) is the start, (XIZ+4*B) the end"),
    ("ptrs", 0xFC514E, 4, "SegmentBounds_FC514E", "SegmentArrays_FC512E[1]"),
    ("ptrs", 0xFC515E, 4, "SegmentBounds_FC515E", "SegmentArrays_FC512E[2]"),
    ("ptrs", 0xFC516E, 4, "SegmentBounds_FC516E", "SegmentArrays_FC512E[3]"),
    ("list", 0xFC517E, 0xFC527A, "B", "DisplayList_FC517E",
     PG0 + " at 0xF09D07 and 0xF09D69, and prom_b 0xF5BF6D, whole; its inner sub-lists "
     "0xFC51B1-0xFC51D3 (0xF09D28), 0xFC51F9-0xFC521B (0xF09D3D), 0xFC524D-0xFC526F (0xF09CD1)",
     [0xFC51B1, 0xFC51D3, 0xFC51F9, 0xFC521B, 0xFC524D, 0xFC526F]),
    ("list", 0xFC527A, 0xFC5292, "B", "DisplayRecords_FC527A",
     "DisplayRecordPtrs_FC52B4[12..14] only (two op-09 records, each drawn alone)", [0xFC5286]),
    ("rects", 0xFC5292, 3, "Rects_FC5292",
     "the interpreter-B op-03 record at 0xFC526F: variable 0x27A6, mask 0x03, +7 = this table"),
    ("list", 0xFC52AA, 0xFC52B4, "A", "DisplayList_FC52AA", PG0 + " at 0xF09CEB and 0xF09D52 (layer 1)", []),
    ("ptrs", 0xFC52B4, 17, "DisplayRecordPtrs_FC52B4",
     PG0 + " at 0xF09CFB and 0xF09D82, prom_b 0xF09E11 and 0xF09E76: XIY = this, then "
     "RunDisplayListBFromPointerArray / 0xF09AB0 with A = the field"),
]


def rd(a, n=1):
    return srcmap.load.__self__ if False else ROM[a - B:a - B + n]


ROM = open(srcmap.ROM, "rb").read()


def walk(s, e):
    recs, p = [], s
    while p < e:
        op, ln = ROM[p - B], ROM[p - B + 1]
        assert ln >= 2 and p + ln <= e, "list 0x%06X-0x%06X: record at 0x%06X overruns" % (s, e, p)
        recs.append((p, op, ln))
        p += ln
    assert p == e, "list 0x%06X-0x%06X does not walk exactly" % (s, e)
    return recs


def size(o):
    k = o[0]
    if k == "list":
        return o[2] - o[1]
    if k == "pairs":
        return 8 * o[2]
    if k == "ptrs":
        return 4 * o[2]
    if k == "names":
        return o[2] * o[3]
    if k == "rects":
        return 8 * o[2]
    if k == "widgets":
        return 90 * o[2]


def u32(a):
    return int.from_bytes(ROM[a - B:a - B + 4], "little")


def check():
    cur = LO
    starts = {}          # address -> label
    recstarts = set()
    for o in OBJ:
        assert o[1] == cur, "gap/overlap at 0x%06X (object starts 0x%06X)" % (cur, o[1])
        cur += size(o)
        if o[0] == "list":
            recs = walk(o[1], o[2])
            for p, op, ln in recs:
                recstarts.add(p)
            starts[o[1]] = o[4]
            for x in o[6]:
                assert x in {r[0] for r in recs} or x == o[2], "inner 0x%06X is not a record start" % x
        elif o[0] == "widgets":
            for k in range(o[2]):
                starts[o[1] + 90 * k] = "Widget_%06X" % (o[1] + 90 * k)
        else:
            starts[o[1]] = o[-2] if o[0] in ("names",) else o[3] if o[0] in ("pairs", "ptrs", "rects") else None
    assert cur == HI, "tiling ends at 0x%06X" % cur
    # names objects: label is index 4
    for o in OBJ:
        if o[0] == "names":
            starts[o[1]] = o[4]
    # every array target is an object start, a record start, or a list end
    ends = {o[2] for o in OBJ if o[0] == "list"}
    for o in OBJ:
        if o[0] in ("pairs", "ptrs"):
            n = o[2] * (2 if o[0] == "pairs" else 1)
            for k in range(n):
                v = u32(o[1] + 4 * k)
                assert v in starts or v in recstarts or v in ends, \
                    "%s[%d] = 0x%06X is not a boundary of this framing" % (o[3], k, v)
    # every B op-02/03 record that points into the span points at an object start, and
    # op-02's width field equals the names table's width
    widths = {o[1]: o[3] for o in OBJ if o[0] == "names"}
    for o in OBJ:
        if o[0] == "list" and o[3] == "B":
            for p, op, ln in walk(o[1], o[2]):
                if op in (2, 3) and ln >= 11:
                    v = u32(p + 7)
                    if LO <= v < HI:
                        assert v in starts, "record 0x%06X points at 0x%06X, not an object" % (p, v)
                        if op == 2:
                            w = ROM[p - B + 0x0B] | ROM[p - B + 0x0C] << 8
                            assert widths.get(v) == w, "record 0x%06X width %d != table's %s" % (
                                p, w, widths.get(v))
    return starts, recstarts


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true", help="retired; see the module docstring")
    a = ap.parse_args()
    if a.apply:
        sys.exit("gen_fc4000_pages.py --apply is retired: the authoritative source is "
                 "wsa1/prom_a/modules/fc4000_fc53ff_digital_effect_screen_data.s, edited by hand "
                 "(see this script's docstring for what replaced each part of its output)")
    starts, recstarts = check()
    print("tiling 0x%06X-0x%06X: OK, %d objects; every list walks exactly; every array entry "
          "and every op-02/03 table pointer lands on a boundary; op-02 widths match" % (LO, HI, len(OBJ)))
    for o in OBJ:
        print("  0x%06X %-7s %5d B  %s" % (o[1], o[0], size(o),
                                          o[4] if o[0] in ("list", "names") else
                                          ("Widget_*" if o[0] == "widgets" else o[3])))


if __name__ == "__main__":
    main()
