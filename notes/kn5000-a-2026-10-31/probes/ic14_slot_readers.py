#!/usr/bin/env python3
"""ic14_slot_readers.py -- which IC14 style-record bytes does the v10 firmware read?

QUESTIONS IT ANSWERS (open items N-a7314f90, N-ae3d1690, N-628bbeaf, N-8f4e2d69)
  1. Slots 8..11 of part_tracks (half offsets +0x118 + 0x26 * part + 2 * slot, slot 8..11 = word offset
     0x10..0x16): AccPart_GetParamAddr is the only routine that indexes part_tracks (`add hl, 0x118 /
     0x13e / ...; ld wa, (xiy+hl)`).  This lists every offset its callers pass: the section map's picks
     (style_section_map in rhythm_data/rhythm_macros.inc) and every `ldw hl|bc|iz, N` within 14 lines
     before a call of AccPart_GetParamAddr's loaders.  None is 0x10..0x16 (or +0x400).
  2. +0x3e3..+0x3f2 of a half: no `(xRR + d)` displacement 0x3e3..0x3f2 / 0x7e3..0x7f2 in any v10 .s.
  3. part_sound +4..+6 (RAM 0x3246 + 7 * record + 4..6): lists every instruction whose memory operand
     falls there, by field.  +4 goes to ACC_EVENT+4 (the voice record), +5 to 0x32c3 + n, +6 to 0x32c7 + n.
  4. RhythmROM_BankProgramLocators: lists every `ld xiy, RhythmROM_BankProgramLocators` with its routine.
SIGNAL (2026-10-31): 1. offsets {0..0xe, 0x18, 0x1a, 0x1c, 0x1e, 0x20, 0x22, 0x24, 0x400.., 0x418.., 0x420,
  0x424}; 2. one hit, `lda xwa, (xde+1006)` in midi_dispatch_handlers.s (a MIDI buffer, not a style record);
  3. +4: 8, +5: 8, +6: 8 reads, all in RhythmPartN_LoadAndStore / AccStyle_InlinedBlock; 4. four readers:
  RhythmROM_PatternDispatcher, VoiceAssign_Process_Return (both remap through VoiceParam_ClampAndValidate),
  Rhythm_LoadCurrentTimeSig (PANEL_STYLE, no remap) and the AccVoice locator reader fed by ACC_PENDING_*
  (remapped by VoiceParam_ClampAndStore).
RUN (repository root)
  python3 notes/kn5000-a-2026-10-31/probes/ic14_slot_readers.py
"""
import collections
import glob
import re

SRC = sorted(glob.glob("v10/maincpu/**/*.s", recursive=True))
TEXT = {f: open(f, "rb").read().decode("latin-1").split("\n") for f in SRC}

print("1. offsets passed to the part_tracks loaders")
macros = open("rhythm_data/rhythm_macros.inc", "rb").read().decode("latin-1")
picks = sorted({int(x) for m in re.finditer(r"sec_picks\t([\d, ]+)", macros) for x in m.group(1).split(",")})
print("   section-map picks:", picks)
offs = collections.Counter()
for f, L in TEXT.items():
    for i, l in enumerate(L):
        if re.search(r"\b(call|calr)\s+(AccStyle_SetupPartAddressesByHL|AccVoice_LoadAllParts)(_Wrap)?\b", l):
            for x in L[max(0, i - 14):i]:
                m = re.match(r"\s*ldw?\s+(hl|bc|iz),\s*(0x[0-9a-fA-F]+|\d+)\s*(;|$)", x)
                if m:
                    offs[int(m.group(2), 0)] += 1
print("   immediate offsets before loader calls:", sorted(hex(v) for v in offs))
# AccVoice_ComputeParamAddr's results, and the C caller's IZ (ldw iz, N) before AccStyle_SetupPartAddressesByHL_Wrap
for f, L in TEXT.items():
    inside = None
    for l in L:
        if re.match(r"^[A-Za-z_]\w*:", l):
            inside = l.split(":")[0]
        m = re.match(r"\s*ldw\s+(hl|iz),\s*(0x[0-9a-fA-F]+|\d+)\s*(;|$)", l)
        if m and inside and (inside.startswith("AccVoice_ParamAddr") or inside == "AccVoice_ComputeParamAddr"
                             or inside.startswith("AccTone_InlineBytecodeData_Code_Helper3")):
            offs[int(m.group(2), 0)] += 1
print("   with AccVoice_ComputeParamAddr's and the C caller's:", sorted(hex(v) for v in offs))
bad = [v for v in offs if 0x10 <= (v & 0x3ff) <= 0x16]
print("   offsets in slots 8..11 (0x10..0x16):", bad or "none")

print("2. displacements 0x3e3..0x3f2 (+0x400)")
for f, L in TEXT.items():
    for i, l in enumerate(L):
        for m in re.finditer(r"\(x(?:i[xyz]|wa|bc|de|hl)\s*\+\s*(0x[0-9a-fA-F]+|\d+)\)", l.split(";")[0]):
            v = int(m.group(1), 0)
            if 0x3e3 <= v <= 0x3f2 or 0x7e3 <= v <= 0x7f2:
                print("   %s:%d  %s" % (f, i + 1, l.strip()))

print("3. part_sound fields in RAM 0x3246..0x3276")
per = collections.defaultdict(list)
for f, L in TEXT.items():
    for i, l in enumerate(L):
        for m in re.finditer(r"\((0x32[4-7][0-9a-fA-F])(?::16)?\)", l.split(";")[0]):
            v = int(m.group(1), 16)
            if 0x3246 <= v < 0x3277:
                per[(v - 0x3246) % 7].append("%s:%d %s" % (f, i + 1, l.strip()))
for k in sorted(per):
    print("   +%d: %d operands, e.g. %s" % (k, len(per[k]), per[k][0]))

print("4. readers of RhythmROM_BankProgramLocators")
for f, L in TEXT.items():
    lab = None
    for i, l in enumerate(L):
        if re.match(r"^[A-Za-z_]\w*:", l):
            lab = l.split(":")[0]
        if re.search(r"ld\s+xiy,\s*RhythmROM_BankProgramLocators", l):
            print("   %s:%d in %s" % (f, i + 1, lab))
