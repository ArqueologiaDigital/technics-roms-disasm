#!/usr/bin/env python3
"""scoop_unknown_readers.py -- do the Scoop lane's "honest unknowns" have a reader anywhere in the v10 ROM?

QUESTION IT ANSWERS (open item N-1fe9a5df; notes/scoop-lane-2026-09-25/README.md, "What remains")
  For the 64 bytes after Str_TuningEq's "TUNING=", Str_ExtTabEffectEnDis, Unref_EF6BD3_Tbl, Unref_EFA7C5_Tbl
  and ClockConfig_Select_Table it lists
    A. every instruction of MAME's linear listing (original_ROMs/kn5000_v10_program.rom.unidasm) with an
       immediate or memory operand inside the object;
    B. every 3-byte little-endian occurrence of an address inside the object anywhere in the ROM (a pointer in
       data, or a coincidence inside other bytes), with its context, for reading by hand.
SIGNAL (2026-10-31): A is empty for all five.  B: Str_TuningEq+8 / +26 at 0xF83BD5 / 0xF3627D sit inside
  `call` operands (1d db c3 fa ..., 1d 59 d5 fa ...: targets 0xFAC3DB / 0xFAD559); Str_ExtTabEffectEnDis+2/+18
  hits are the operand bytes of `ld (0xf0029f / 0xf002af...)`-shaped words inside other instructions (27 20, 97 20,
  e8 12 ...), none decoded as an operand by A; Unref_EF6BD3_Tbl+10 at 0xF8B6A1 is inside `69 cb dd 6b ef`, a
  relative jump and an operand of another instruction; the other two have no occurrence.  So none of the five is
  read, by name, by a pointer or by an instruction operand.  (Indexed reads from a neighbouring label cannot be
  excluded by a scan; none of the neighbours' readers indexes past its own object: ParamPopup_PartTuning copies
  exactly 7 bytes of Str_TuningEq.)
RUN (repository root, after make all)
  python3 notes/kn5000-a-2026-10-31/probes/scoop_unknown_readers.py
"""
import re

syms = {}
for l in open("symbols/maincpu_v10_symbols_reference.txt"):
    p = l.split()
    if len(p) == 2 and not l.startswith("#"):
        syms[p[0]] = int(p[1], 16)
ITEMS = {"Str_TuningEq": (7, 71), "Str_ExtTabEffectEnDis": (0, 23), "Unref_EF6BD3_Tbl": (0, 20),
         "Unref_EFA7C5_Tbl": (0, 4), "ClockConfig_Select_Table": (0, 16)}
rng = {n: (syms[n] + a, syms[n] + b) for n, (a, b) in ITEMS.items()}
A = {n: [] for n in ITEMS}
for l in open("original_ROMs/kn5000_v10_program.rom.unidasm", errors="replace"):
    if ":" not in l:
        continue
    for m in re.finditer(r"0x([0-9a-fA-F]+)", l.split(":", 1)[1][20:]):
        v = int(m.group(1), 16)
        for n, (a, b) in rng.items():
            if a <= v < b:
                A[n].append(l.strip())
rom = open("original_ROMs/kn5000_v10_program.rom", "rb").read()
for n, (a, b) in rng.items():
    print("%s 0x%x..0x%x" % (n, a, b))
    print("  A. instruction operands: %d %s" % (len(A[n]), A[n][:4]))
    hits = []
    for t in range(a, b):
        pat = bytes([t & 255, (t >> 8) & 255, (t >> 16) & 255])
        i = rom.find(pat)
        while i >= 0:
            hits.append("0x%x at 0x%x (%s)" % (t, 0xE00000 + i, rom[max(0, i - 2):i + 4].hex()))
            i = rom.find(pat, i + 1)
    print("  B. 3-byte occurrences: %d %s" % (len(hits), hits[:6]))
