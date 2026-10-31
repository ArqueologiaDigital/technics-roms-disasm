#!/usr/bin/env python3
"""gen_sound_patch_catalogue.py -- the KN5000's panel sound list, category by category, from the ROMs.

QUESTION ANSWERED (kn5000-cox)
    Which tone does each panel sound slot select?  The panel offers a category (PIANO .. DRUM KITS, MEMORY A/B)
    and a slot 0..39 inside it.  This walks the same path the firmware does and prints, per category, every
    offered slot with its program/bank and the name of the tone record the sub CPU will load.

THE PATH (every step is a firmware reader; sound-categories.md and tone-database.md have the details)
    main CPU v10 (original_ROMs/kn5000_v10_program.rom; addresses from symbols/maincpu_v10_symbols_reference.txt)
      SoundData_CategoryDescPtr -> descriptor D (Param_SignExtendRetu_Block copies it to RAM 0xE14E)
      D+0x00 -> 18 x 16-char category names                          (StoreDRAMInit_LoadDRAM)
      D+0x14 grid (D+0x24 in mode 1): u16 [category*40 + slot], low byte = program, high byte = bank
                                                                      (FetchOscTableEntry_Prologue)
      D+0x3C / D+0x40 / D+0x44: last offered slot per category for ordinary parts / part 15 (drums) / part 20,
      D+0x48 / D+0x4C the same in mode 1; 0xFF = category not offered  (CharMap_ActivePreamb_Prologue)
    the {program, bank} pair is rewritten by SndParam_ApplyMaskClamp (mode 0 only, and not for bank 0x78):
      program < 0x80: bank &= 7;  program >= 0x80 with bank 7: program & 0x7F in bank 0x70 (drawbar presets);
      0x80..0xEF: bank 0 -> program & 0x7F in bank 0x10, bank 5 -> bank 0x15 (RAM user banks; the panel's
      MEMORY A and B are programs 0x80-0xA7 of bank 0, i.e. user bank 0x10 entries 0-39),
      else program 0 bank 0;  0xF0..0xFF: bank 0/1 -> program & 0x0F in bank 0x40 / 0x41 (the drum kits),
      bank 6 -> program 0 bank 0x50, bank 5 -> program & 3 bank 0x55, else program 0 bank 0
    and then travels in the C0 record {5, 0xC0, part, program, bank, effect} (SndPart_SendProgramChange) to the
    sub CPU, whose ToneDB_Find_PatchRecord resolves it in the table-data
    tone database (original_ROMs/kn5000_table_data.rom, 0x830000 = sub-CPU 0x050000):
      bank selector <= 7, 0x40, 0x41, 0x70 only (others are RAM user banks or fall back to record 0)
      b    = ToneDB_BankMap_Main[bank]                     (0x830100)
      tone = u16 ToneDB_ToneNumBanks_Main[(b << 7) + program] (0x830180)
      rec  = 0x830000 + u32 ToneDB_ToneOffsetTable[tone]   (0x831B00); name = rec[0:16]

RUN
    python3 scripts/generators/gen_sound_patch_catalogue.py            # Markdown to stdout
    python3 scripts/generators/gen_sound_patch_catalogue.py --check FILE   # exit 1 if FILE differs
    The committed output is notes/open4-kn5000-b/midi/sound-patch-catalogue.md.
"""
import os, struct, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
B = 0xE00000
prog = open(os.path.join(ROOT, "original_ROMs/kn5000_v10_program.rom"), "rb").read()
tab = open(os.path.join(ROOT, "original_ROMs/kn5000_table_data.rom"), "rb").read()
sym = {}
for line in open(os.path.join(ROOT, "symbols/maincpu_v10_symbols_reference.txt")):
    p = line.split()
    if len(p) == 2 and not line.startswith("#"):
        sym[p[0]] = int(p[1], 16)
u32 = lambda a: struct.unpack_from("<I", prog, a - B)[0]
D = u32(sym["SoundData_CategoryDescPtr"])
NCAT, NSLOT = u32(D + 4), u32(D + 8)
names_at = u32(D + 0)
CAT = [prog[names_at - B + 16 * i:][:16].decode("latin-1").strip() for i in range(NCAT)]
TB = 0x800000
t16 = lambda a: struct.unpack_from("<H", tab, a - TB)[0]
t32 = lambda a: struct.unpack_from("<I", tab, a - TB)[0]
PRESET_BANKS = set(range(8)) | {0x40, 0x41, 0x70}


def clamp(pg, bk, mode):
    """SndParam_ApplyMaskClamp (v10 audio/note_voice_mapping.s): the {program, bank} actually sent."""
    if mode == 1 or bk == 0x78:
        return pg, bk
    if pg <= 0x7F:
        return pg, bk & 7
    if bk == 7:
        return pg & 0x7F, 0x70
    if pg <= 0xEF:
        return {0: (pg & 0x7F, 0x10), 5: (pg & 0x7F, 0x15)}.get(bk, (0, 0))
    if bk <= 1:
        return pg & 0x0F, (bk & 1) | 0x40
    return {6: (0, 0x50), 5: (pg & 3, 0x55)}.get(bk, (0, 0))


RAM_BANKS = {0x10: "RAM user bank 0x10", 0x15: "RAM user bank 0x15", 0x50: "RAM user drum kit 0x50",
             0x55: "RAM user drum kit 0x55"}


def tone_of(program, bank):
    if bank not in PRESET_BANKS:
        return None, None, "(%s)" % RAM_BANKS.get(bank, "bank 0x%02X: no ROM tone" % bank)
    b = tab[0x830100 - TB + bank]
    tone = t16(0x830180 + 2 * ((b << 7) + program))
    rec = 0x830000 + t32(0x831B00 + 4 * tone)
    return tone, rec, tab[rec - TB:][:16].decode("latin-1").strip()


def table(rows, hdr):
    w = [max(len(str(r[c])) for r in rows + [hdr]) for c in range(len(hdr))]
    out = ["| " + " | ".join(str(h).ljust(w[c]) for c, h in enumerate(hdr)) + " |",
           "|" + "|".join("-" * (x + 2) for x in w) + "|"]
    out += ["| " + " | ".join(str(r[c]).ljust(w[c]) for c in range(len(hdr))) + " |" for r in rows]
    return out


def section(title, grid_off, last_off, cats, mode):
    grid, last = u32(D + grid_off), u32(D + last_off)
    out = ["## " + title, ""]
    total = 0
    for c in cats:
        n = prog[last - B + c]
        if n == 0xFF:
            continue
        rows = []
        for s in range(n + 1):
            e = struct.unpack_from("<H", prog, grid - B + 2 * (c * NSLOT + s))[0]
            pg, bk = e & 0xFF, e >> 8
            sp, sb = clamp(pg, bk, mode)
            tone, rec, name = tone_of(sp, sb)
            rows.append([s + 1, "%d (0x%02X)" % (pg, pg), "0x%02X" % bk, "%d / 0x%02X" % (sp, sb),
                         "-" if tone is None else tone,
                         "-" if rec is None else "0x%06X" % rec, name])
        total += len(rows)
        out += ["### %s (category %d, %d sounds)" % (CAT[c], c, len(rows)), ""]
        out += table(rows, ["slot", "program", "bank", "sent (program / bank)", "tone #", "tone record", "tone name"]) + [""]
    out.insert(2, "%d sounds.  Grid D+0x%02X, last-slot table D+0x%02X." % (total, grid_off, last_off))
    out.insert(3, "")
    return out


def section_gm_drums():
    grid, last = u32(D + 0x24), u32(D + 0x4C)
    t30 = u32(D + 0x30)
    n = prog[last - B + 15]
    rows = []
    for s in range(n + 1):
        e = struct.unpack_from("<H", prog, grid - B + 2 * (15 * NSLOT + s))[0]
        pg, bk = e & 0xFF, e >> 8
        kp, kb = prog[t30 - B + 2 * pg], prog[t30 - B + 2 * pg + 1]
        sp, sb = clamp(kp, kb, 0)
        tone, rec, name = tone_of(sp, sb)
        rows.append([s + 1, "%d (0x%02X)" % (pg, pg), "0x%02X" % bk, "0x%02X / 0x%02X" % (kp, kb),
                     "%d / 0x%02X" % (sp, sb), tone, "0x%06X" % rec, name])
    return ["### DRUM KITS, mode 1 (%d kits)" % len(rows), ""] + table(
        rows, ["slot", "program", "bank", "+0x30 kit", "sent (program / bank)", "tone #", "tone record",
               "tone name"]) + [""]


def section_gm_voices():
    """Descriptor +0x1C: voice index v (the GM program number - 1) -> the first {program, bank} record, and the
    +0x34 note shift the SMF import adds for that voice (MidiNoteOn_NonDrumLookupA/B)."""
    t1c, t34 = u32(D + 0x1C), u32(D + 0x34)
    rows = []
    for v in range(128):
        r = u32(t1c + 4 * v)
        pg, bk = prog[r - B], prog[r - B + 1]
        sp, sb = clamp(pg, bk, 0)
        tone, rec, name = tone_of(sp, sb)
        sh = prog[t34 - B + v]
        sh = sh - 256 if sh > 127 else sh
        rows.append([v, v + 1, "%d / 0x%02X" % (pg, bk), tone, name, "%+d" % sh if sh else "0"])
    return ["## GM voice map (descriptor +0x1C and +0x34)", "",
            "Voice index v is GM program v+1: +0x1C gives the KN5000 sound used for it, +0x34 the note shift "
            "added to its note-ons when an SMF is imported.", ""] + table(
        rows, ["voice", "GM program", "program / bank", "tone #", "tone name", "+0x34 shift"]) + [""]


def main():
    lines = ["# KN5000 panel sound catalogue (generated)", "",
             "Generated by `scripts/generators/gen_sound_patch_catalogue.py` from the v10 program ROM and the "
             "table-data ROM; do not edit by hand.  Slot numbers are 1-based as on the panel (the firmware's "
             "slot is one less).  \"Mode 1\" is SndParam_LookupReadOnly(0xC0) == 1, probably the GM mode "
             "(inference from the counts and the GS drum-set map in descriptor slot +0x30).", ""]
    lines += section("Mode 0, ordinary parts", 0x14, 0x3C, range(NCAT), 0)
    lines += section("Mode 0, the drum part (part 15)", 0x14, 0x40, range(NCAT), 0)
    lines += section("Mode 0, part 20", 0x14, 0x44, range(NCAT), 0)
    lines += section("Mode 1, ordinary parts", 0x24, 0x48, range(NCAT), 1)
    lines += ["Mode 1, the drum part (part 15): descriptor +0x4C lists 8 kits as program/bank pairs in bank 0x78 "
              "(the GM2 rhythm bank).  SndParam_LookupAndDispatch maps such a pair through the GS drum-set map at "
              "descriptor +0x30 to a KN5000 kit program 0xF0+k, bank 0; the table below applies the mode-0 rewrite "
              "to that pair, which is an INFERENCE (the mode-1 send path of a bank-0x78 pair is not traced).", ""]
    lines += section_gm_drums()
    lines += section_gm_voices()
    text = "\n".join(lines).rstrip() + "\n"
    if len(sys.argv) > 2 and sys.argv[1] == "--check":
        ok = open(sys.argv[2]).read() == text
        print("OK" if ok else "STALE: " + sys.argv[2])
        sys.exit(0 if ok else 1)
    sys.stdout.write(text)


main()
