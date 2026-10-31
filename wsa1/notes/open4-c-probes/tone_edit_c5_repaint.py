#!/usr/bin/env python3
"""Is ToneEditPage_ToggleRowFocus's literal 0xC5 repaint wrong on pages 0xA6 / 0xA7?  (open-items
N-2814717a)

ToneEditPage_ToggleRowFocus (prom_a 0xFD4FE0) is shared by the three MODELING pages PAGE1/3..3/3
(screens 0xA5, 0xA6, 0xA7) and always calls T_Dispatch_Code80(0xC5, field 0) -- page 0xA5's field-0
repaint, even when 0xA6 or 0xA7 is on screen.  This probe compares what the three field-0 repaints
draw.

CHECKS (exit 1 on any failure)
  R1  the routine pushes 0x00 / 0xC5 and calls T_Dispatch_Code80 (bytes at 0xFD500E).
  R2  Dispatch_Code80 maps a selector >= 0xC0 to Dispatch_Code80_RepaintFieldTable[sel - 0xC0 + 0x20],
      and entries [0xA5] [0xA6] [0xA7] are ToneEditPage_A5/A6/A7_RepaintField (0xF5CD46 / 0xF5CDA8 /
      0xF5CDD4).
  R3  the field-0 arm of all three (layer 1: DL_F03581..0xF03595, then
      ToneEditPage_PaintMainAndSubFocus, A := 0) is the same 25 bytes.
  R4  the record each then runs on layer 0 for field 0 -- DLRecordPtrs_F0355D[0], Data_F03617[0],
      DLRecordPtrs_F036C2[0] -- is a separate copy per page with the same 11 bytes:
      op 03, var 0x27A6 (ModelingPage_Fields[0]), mask 0x01, service 5, table DLTable_F035AA.
  => repainting with 0xC5 on 0xA6 / 0xA7 draws exactly what 0xC6 / 0xC7 would: harmless, not a defect.

RUN
  python3 notes/open4-c-probes/tone_edit_c5_repaint.py
"""
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
A = open(os.path.join(ROOT, "original_ROMs", "wsa1_prom_a.ic12"), "rb").read()
B = open(os.path.join(ROOT, "original_ROMs", "wsa1_prom_b.ic13"), "rb").read()
fails = []


def a(x, n):
    return A[x - 0xF80000:x - 0xF80000 + n]


def b(x, n):
    return B[x - 0xF00000:x - 0xF00000 + n]


def le32(x):
    return int.from_bytes(b(x, 4), "little")


def ck(name, cond, detail=""):
    print("%-3s %s %s" % (name, "ok  " if cond else "FAIL", detail))
    if not cond:
        fails.append(name)


ck("R1", a(0xFD500E, 10) == bytes.fromhex("0b00000bc5001dd41ef4"),
   "pushw 0x00 / pushw 0xc5 / call 0xf41ed4 at FD500E")
TABLE = 0xF5B9F8
ents = {k: le32(TABLE + 4 * (k - 0x80)) for k in (0xA5, 0xA6, 0xA7)}
ck("R2", b(0xF5B9C7, 4) == bytes.fromhex("dbcfc000") and b(0xF5B9D1, 1) == b"\x45"
     and ents == {0xA5: 0xF5CD46, 0xA6: 0xF5CDA8, 0xA7: 0xF5CDD4}
     and le32(0xF5B9D1 + 1) == TABLE + 0x80,
   "selector 0xC5 -> table+0x80+5*4; entries %s" % {hex(k): hex(v) for k, v in ents.items()})
arms = [b(0xF5CD54, 25), b(0xF5CDAC, 25), b(0xF5CDD8, 25)]
ck("R3", arms[0] == arms[1] == arms[2], "field-0 layer-1 arm: %s" % arms[0].hex(" "))
recs = [le32(0xF0355D), le32(0xF03617), le32(0xF036C2)]
bodies = [b(r, 11) for r in recs]
ck("R4", len(set(recs)) == 3 and bodies[0] == bodies[1] == bodies[2]
     and bodies[0] == bytes.fromhex("030ba6270100" "05aa35f000"),
   "records %s, bytes %s" % (" ".join("%06X" % r for r in recs), bodies[0].hex(" ")))
print("\nFAILURES:", len(fails))
sys.exit(1 if fails else 0)
