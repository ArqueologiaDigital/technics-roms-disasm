#!/usr/bin/env python3
# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Generates src/ic18/rhythm.s, src/ic18/styles/<rhythm group>/<style>.s and
# src/ic18/old_build.s: IC18 (C3CBND000046) from 0x10000 to the end of the chip,
# the built-in "Technics Rhythms" style resource the firmware reads at
# 0x40010000, typed record by record and event by event. Nothing is .incbin'd.
# notes/ic18-rhythm-rom.md is the format; this is how the source is made.
#
# Every field is written as what the firmware reads it as (big-endian: the
# firmware reads this resource through LoadU16BE / LoadU24BE / SumU16BE, although
# the MN10300 itself is little-endian):
#
#   * rhythm.s: the header, the count block, the 2048-entry style-ID index, the
#     169-entry style table and the 8-entry count-in table, with every offset
#     spelled symbolically (`.be24 Label - TechnicsRhythms`); the macros; the
#     eight count-in patterns; an .include per style; the erased flash and the
#     version string;
#   * styles/<group>/<style>.s, one per style: its name, its two sound-unit keys,
#     its eight part set-ups (one macro per record, every field named), its 20
#     slot offsets, then its 20 variation records in the order they sit in the
#     chip: header, set-up events, the event stream, one event per line;
#   * old_build.s: an older build's leftovers past the last style, typed the same
#     way, the bytes before the first whole event of a fragment as .byte.
#
# Events: one macro per kind (note, named controllers, program change, pitch
# bend, pressure, beat marker, end); a position byte (the tick in the beat) folds
# into the event after it as the @ form of its macro. Drum-part keys are spelled
# by table 84's Standard Kit 1 names (DRUM_KEYS), a note's gate as one number of
# ticks and its rule by its NoteConvRules name (NCR_NAMES, checked against program
# 941), the two sound-unit keys get their DSP preset names in a comment. Each
# stream is checked as it is written: it
# opens with a beat marker, ends with 0xF5, holds bars x beats markers, and every
# event has the length RhyEventLenByStatus gives it (the same checks as
# notes/ic18-rhythm-rom-probes/ic18_rhythm_probe.py).
#
# Inputs: the IC18 reference (baserom/kn7000_ic18.rom); program 941
# (baserom/kn7000_program.rom), for the rhythm group lists that give each style
# its group, its place in it and its style-ID; table 84 (baserom/kn7000_table.rom),
# for the names of the 51 styles that live there, which the index points to.
#
#   python3 tools/gen_ic18_rhythm_s.py --rom baserom/kn7000_ic18.rom \
#       --program baserom/kn7000_program.rom --table baserom/kn7000_table.rom \
#       --out src/ic18/rhythm.s          # the other files go beside it
import argparse
import hashlib
import re
import struct
import sys

IC18_SHA1 = "2dc71f5082063cd6b21e4ed16acd67e9d326a79f"
BASE = 0x10000                  # file offset of the resource (CPU 0x40010000)
CPU = 0x40000000                # CPU address of file offset 0
PROGRAM_BASE = 0x48400000
GENRE_TABLE = 0x48735EE4        # RhythmGenreNameTable, program 941
TABLE_STYLE_SUBTABLE_DIR = 0xEC  # TableRomStyleSubTablePtr: table ROM + *(0x480000EC)

PART_NAMES = ["Drum", "Bass", "Acc1", "Acc2", "Acc3", "Acc4", "Acc5", "Perc"]
# Slots 12-19 (program 941): INTRO k+1 is slot 12 + 4k (func_484437DA), ENDING k+1 slot 14 + 4k
# (func_484439EB); StyleRecordSlotSelect adds 0x5003A46A = func_484361BC(chord type), 1 for
# the minor-family chord types, so the odd slot of each pair is the minor version
# (notes/mn10300-names-probes/rhythm_style_semantics.py, sections 1 and 2).
SLOT_NAMES = ["Var1", "Var1Fill1", "Var1Fill2", "Var2", "Var2Fill1", "Var2Fill2",
              "Var3", "Var3Fill1", "Var3Fill2", "Var4", "Var4Fill1", "Var4Fill2",
              "Intro1Major", "Intro1Minor", "Ending1Major", "Ending1Minor",
              "Intro2Major", "Intro2Minor", "Ending2Major", "Ending2Minor"]
DSP_PRESET_TABLE = 0x48703558   # func_48412187: kind-0 DSP preset key -> record, index lo << 6 | hi & 0x3F


class Img:
    def __init__(self, data):
        self.d = data

    def u16(self, o):
        return (self.d[o] << 8) | self.d[o + 1]

    def u24(self, o):
        return (self.d[o] << 16) | (self.d[o + 1] << 8) | self.d[o + 2]


def ev_len(d, o):
    """RhyEventLenByStatus / RhySysexLen (program 941 0x484403D5 / 0x484403CD)."""
    s = d[o]
    if s == 0xF0:
        return d[o + 1] + 2
    return {0x90: 6, 0xB0: 3, 0xC0: 4, 0xD0: 2, 0xE0: 3}.get(s & 0xF0, 1)


def check_stream(d, s, e, beats_wanted, what):
    """The stream d[s:e] parses as events: opens with 0xF4, ends with 0xF5 at
    e-1, every data byte < 0x80, every position byte 0..95 and rising within a
    beat, and bars*beats 0xF4 markers."""
    if d[s] != 0xF4 or d[e - 1] != 0xF5:
        raise SystemExit(f"{what}: stream does not open with F4 / end with F5")
    p, beats, last = s, 0, -1
    while p < e:
        c = d[p]
        n = ev_len(d, p)
        if c == 0xF4:
            beats, last = beats + 1, -1
        elif c < 0x80:
            if c > 95 or c < last:
                raise SystemExit(f"{what}: position byte {c} at {p:#x}")
            last = c
        elif c != 0xF5 and any(b >= 0x80 for b in d[p + 1:p + n]):
            raise SystemExit(f"{what}: data byte >= 0x80 in event at {p:#x}")
        p += n
    if p != e:
        raise SystemExit(f"{what}: events overrun the stream end ({p:#x} != {e:#x})")
    if beats != beats_wanted:
        raise SystemExit(f"{what}: {beats} beat markers, want {beats_wanted}")


def label_of(name, used):
    base = name.replace("&", "And").replace("'n'", "n").replace("'", "")
    base = re.sub(r"[^A-Za-z0-9]", "", base)
    lab = "Style_" + base
    n = 2
    while lab in used:
        lab = f"Style_{base}_{n}"
        n += 1
    used.add(lab)
    return lab


def sid_of_entry(i):
    """Index entry i <- style-ID: StyleNameSourceSet folds the ID with
    ((id & 0x0F00) >> 1) | (id & 0x7F)."""
    return ((i & 0x780) << 1) | (i & 0x7F)


def hx(v):
    return f"0x{v:02x}"


# Controllers the source spells by name (the part-field table 0x485B77D4 and the
# controllers the streams use); any other is `cc part, number, value`.
CC_NAMES = {1: "mod", 7: "vol", 10: "pan", 11: "expr", 64: "sus", 91: "rev", 93: "cho",
            80: "eq_hi_fc", 81: "eq_hi_gain", 82: "eq_lo_fc", 83: "eq_lo_gain", 92: "multi",
            94: "dsp_sw", 96: "bend_range", 97: "fold_root"}   # the part set-up's fields (style_part)
DRUM_PARTS = (0, 7)
# Drum keys on parts 0 and 7, by the names table 84 gives them in Standard Kit 1 (tone
# 0x260000, program 0 of the kit bank 0x26): a kit is a table tone whose per-note
# {program, LSB, MSB} triple (TgNoteOnTableTone 0x4C03600D) selects a voice record, whose
# name this is ("H.H.On Beat" -> KitHHOnBeat). The other kits keep the layout: 92.5 % of
# the styles' drum notes play a voice of that name in their own kit; the rest are the
# brush, orchestral, bongo/conga, voice and SFX kits' own sounds on the same keys
# (notes/mn10300-names-probes/rhythm_drum_kit_keys.py). Keys 0, 1 and 117-127 are
# "Silent" in Standard Kit 1 and stay numbers.
DRUM_KEYS = {
    2: "KitElectricSD", 3: "KitElectricTomL", 4: "KitElectricTomM", 5: "KitElectricTomH",
    6: "KitOrchTambourin", 7: "KitOrchBassDrum", 8: "KitOrchSnare", 9: "KitOrchCymbal", 10: "KitBrushSwirl",
    11: "KitBrushSlap", 12: "KitVoiceAh", 13: "KitVoiceYeh", 14: "KitVoiceUhs", 15: "KitAmbientHammer",
    16: "KitClick1", 17: "KitClick2", 18: "KitHHOnBeat", 19: "KitHHOffBeat", 20: "KitHiHatAccent",
    21: "KitHHHalfOpen", 22: "KitReverseCymbal", 23: "KitReverseSnare", 24: "KitPiccoloSnare",
    25: "KitSnareRoll", 26: "KitFingerSnap", 27: "KitHighQ", 28: "KitSlap", 29: "KitScratchPush",
    30: "KitScratchPull", 31: "KitSticks", 32: "KitSquareClick", 33: "KitMetronomeTap",
    34: "KitMetronomeBell", 35: "KitBassDrum2", 36: "KitBassDrum1", 37: "KitRimShot", 38: "KitSnareDrum1",
    39: "KitHandClaps", 40: "KitSnareDrum2", 41: "KitBassTomL", 42: "KitHiHatClosed", 43: "KitBassTomH",
    44: "KitHiHatPedal", 45: "KitLowTom", 46: "KitHiHatOpen", 47: "KitMidTomL", 48: "KitMidTomH",
    49: "KitCrashCymbal1", 50: "KitHighTom", 51: "KitRideCymbal1", 52: "KitChinaCymbal", 53: "KitRideBell",
    54: "KitTambourine", 55: "KitSplashCymbal", 56: "KitCowbell", 57: "KitCrashCymbal2", 58: "KitVibraslap",
    59: "KitRideCymbal2", 60: "KitBongoHigh", 61: "KitBongoLow", 62: "KitCongaMuteSlp", 63: "KitCongaHigh",
    64: "KitCongaLow", 65: "KitTimbalesHigh", 66: "KitTimbalesLow", 67: "KitAgogoHigh", 68: "KitAgogoLow",
    69: "KitCabasa", 70: "KitMaracas", 71: "KitShortWhistle", 72: "KitLongWhistle", 73: "KitGuiroShort",
    74: "KitGuiroLong", 75: "KitClaves", 76: "KitWoodBlockH", 77: "KitWoodBlockL", 78: "KitCuicaMute",
    79: "KitCuicaOpen", 80: "KitTriangleMute", 81: "KitTriangleOpen", 82: "KitShaker", 83: "KitSleighBell",
    84: "KitBellTree", 85: "KitCastanets", 86: "KitSurdoMute", 87: "KitSurdoOpen", 88: "KitApplause",
    89: "KitWindchime", 90: "KitSambaDrumOn", 91: "KitSambaDrumOff", 92: "KitSmallCongaH",
    93: "KitSmallCongaL", 94: "KitCongaMuteOn", 95: "KitCongaMuteOff", 96: "KitCongaOpenSlp",
    97: "KitBongoMute1", 98: "KitBongoMute2", 99: "KitBongoMute3", 100: "KitTimbalesOpenH",
    101: "KitTimbalesPaila", 102: "KitSambaWhistleH", 103: "KitSambaWhistleL", 104: "KitShakerOnBeat",
    105: "KitShakerOffBeat", 106: "KitMaracasOn", 107: "KitMaracasOff", 108: "KitTambourineOn",
    109: "KitTambourineOff", 110: "KitSmallWoodBlk", 111: "KitCowbell1", 112: "KitCowbell2",
    113: "KitCowbell3", 114: "KitCowbell4", 115: "KitCowbell5", 116: "KitCowbell6"}
# A note's last byte: its entry of NoteConvRules 0x48736104 (128 x 8 bytes; func_4843D558 /
# func_4843CEF3 / func_48436229), by the name of the conversion table +4 points at (the
# table's first word). Rule 0 has no table: func_48436229 returns the key unchanged. The
# entries not named here repeat a named one's table (25-79, 84-127 and 2, 15, 81, 99) or
# have none (3-14) and stay numbers. "Merodic" is the firmware's spelling.
NCR_NAMES = {
    0: "NcrNone", 1: "NcrRootShiftOnly", 16: "NcrMelodyBasic", 17: "NcrMelodyIn7thGToBb",
    18: "NcrMelodyIn7thCToBb", 19: "NcrMajInclFForGospelEtc", 20: "NcrMajInclAForWalkingBass",
    21: "NcrMajInclBbForMajIs7th", 22: "NcrNaturalIsMelodicDown", 23: "NcrHarmonicMinor",
    24: "NcrMerodicMinAscend", 80: "NcrBasicChord100", 82: "NcrKeepNearC", 83: "NcrHardRockChord",
    96: "NcrChordCEGB", 97: "NcrChordCDEG", 98: "NcrChordDEGB", 100: "NcrChordCEGA",
    101: "NcrChordADGC", 102: "NcrChordEGAD", 103: "NcrChordCEAD"}
NCR_TABLE = 0x48736104          # NoteConvRules, program 941
NCR_FIRMWARE_NAMES = {          # the names the program carries for them, checked by main()
    1: "Root Shift Only", 16: "Melody Basic", 17: "Melody In 7th G>Bb", 18: "Melody In 7th C>Bb",
    19: "Maj incl. F for Gospel etc", 20: "Maj incl. A for walking Bass", 21: "Maj incl.Bb for MAJ=7th",
    22: "Natural=MelodicDown", 23: "Harmonic Minor", 24: "Merodic Min Ascend", 80: "Basic Chord 100%",
    82: "Keep near C", 83: "HardRock Chord", 96: "Chord CEGB", 97: "Chord CDEG", 98: "Chord DEGB",
    100: "Chord CEGA", 101: "Chord ADGC", 102: "Chord EGAD", 103: "Chord CEAD"}


def check_ncr_names(prog):
    """Refuse a program 941 whose NoteConvRules do not carry the names NCR_NAMES spells."""
    o = NCR_TABLE - PROGRAM_BASE
    if struct.unpack_from("<I", prog, o + 4)[0] != 0:
        raise SystemExit("NoteConvRules: rule 0 has a table")
    for k, want in NCR_FIRMWARE_NAMES.items():
        t = struct.unpack_from("<I", prog, o + 8 * k + 4)[0] - PROGRAM_BASE
        s = struct.unpack_from("<I", prog, t)[0] - PROGRAM_BASE
        got = prog[s:prog.index(b"\0", s)].decode("latin-1").strip()
        if got != want:
            raise SystemExit(f"NoteConvRules rule {k}: {got!r}, want {want!r}")


def dsp_preset(prog, pair):
    """The DSP preset a style's sound-unit pair selects (func_484420C8 + func_48412187): its
    name, or None when the key is not a kind-0 preset of program 941's table."""
    lo, hi = pair[0] & 0x7F, pair[1] & 0x3F
    if lo >= 0x70:
        return None
    a = struct.unpack_from("<I", prog, DSP_PRESET_TABLE - PROGRAM_BASE + 4 * ((lo << 6) | hi))[0]
    o = a - PROGRAM_BASE
    if not 0 <= o < len(prog) - 0x20 or prog[o + 0x1C:o + 0x1E] != bytes((lo, hi)):
        return None
    return prog[o:o + 16].decode("latin-1").strip()


def one_event(d, p, tick):
    """The source line of the channel or meta event at p, `tick` = the position byte
    before it or None. Returns (line, length)."""
    c = d[p]
    n = ev_len(d, p)
    a = list(d[p + 1:p + n])
    if c in (0xF4, 0xF5) or c < 0x80 or c == 0xF0:
        raise SystemExit(f"one_event: {c:#x} at {p:#x}")
    if any(x >= 0x80 for x in a):
        raise SystemExit(f"data byte >= 0x80 in the event at {p:#x}")
    part, kind = c & 15, c & 0xF0
    if kind == 0x90:
        key = DRUM_KEYS.get(a[0], a[0]) if part in DRUM_PARTS else a[0]
        name, args = "n", [part, key, a[1], a[2] | a[3] << 7, NCR_NAMES.get(a[4], a[4])]
    elif kind == 0xB0:
        if a[0] in CC_NAMES:
            name, args = CC_NAMES[a[0]], [part, a[1]]
        else:
            name, args = "cc", [part] + a
    elif kind == 0xC0:
        name, args = "pc", [part] + [hx(x) for x in a]
    elif kind == 0xE0:
        name, args = "bend", [part] + a
    elif kind == 0xD0:
        name, args = "pres", [part] + a
    else:
        raise SystemExit(f"event {c:#x} at {p:#x} not typed")
    if tick is not None:
        name, args = "@" + name, [tick] + args
    return f"\t{name} {','.join(str(x) for x in args)}", n


def event_lines(d, s, e):
    """One line per event of d[s:e]; a position byte folds into the event after it."""
    out = []
    p, tick = s, None
    while p < e:
        c = d[p]
        if c < 0x80:
            if tick is not None:
                out.append(f"\tat {tick}")
            tick = c
            p += 1
            continue
        if c in (0xF4, 0xF5):
            if tick is not None:
                out.append(f"\tat {tick}")
                tick = None
            out.append("\tbeat" if c == 0xF4 else "\tend")
            p += 1
            continue
        line, n = one_event(d, p, tick)
        out.append(line)
        tick = None
        p += n
    if tick is not None:
        out.append(f"\tat {tick}")
    if p != e:
        raise SystemExit(f"events overrun {e:#x}")
    return out


def fragment_lines(d, s, e):
    """A stream fragment that may begin inside an event: the shortest prefix after
    which the rest parses to e as the styles' streams do is written as bytes, the
    rest as events. As in every style stream, a position byte must be followed by
    a channel event and positions must not fall within a beat."""
    for k in range(6):
        p, last, prev_pos = s + k, -1, False
        try:
            while p < e:
                c = d[p]
                n = 1 if c < 0x80 or c in (0xF4, 0xF5) else ev_len(d, p)
                if c >= 0x80 and c not in (0xF4, 0xF5) and (c == 0xF0 or any(x >= 0x80 for x in d[p + 1:p + n])):
                    raise ValueError
                if c < 0x80:
                    if prev_pos or c < last or c > 95:
                        raise ValueError
                    last = c
                elif c in (0xF4, 0xF5):
                    if prev_pos:
                        raise ValueError
                    last = -1
                prev_pos = c < 0x80
                p += n
        except (ValueError, IndexError):
            continue
        if p == e:
            pre = [f"\t.byte {', '.join(hx(x) for x in d[s:s + k])}\t# the end of an event cut off at its start"] if k else []
            return pre + event_lines(d, s + k, e)
    raise SystemExit(f"fragment {s:#x}..{e:#x} does not parse")


def macro_defs():
    m = []
    w = m.append
    w("# Events (RhyEventLenByStatus): `part` is the low nibble of the status byte, 0-7. The")
    w("# @ form of each takes the position byte that precedes the event: the tick in the beat,")
    w("# 0-95 (96 a beat); without it the event is at the tick of the one before (tick 0 after a")
    w("# beat marker).")
    defs = [
        ("n", "part, key, vel, gate, rule", "0x90 + \\part, \\key, \\vel, (\\gate) & 0x7f, (\\gate) >> 7, \\rule",
         "note. gate = its length in ticks, 7 bits a byte, low first (func_484425FE:\n"
         "#    `movbu (4, a1), d0` `movbu (3, a1), d1` `asl 7, d0` `add d1, d0`); rule = its\n"
         "#    NoteConvRules entry, how the key follows the chord (func_4843D558 -> func_4843CEF3 ->\n"
         "#    func_48436229; NcrNone on every drum-part note)"),
        ("cc", "part, ctl, value", "0xb0 + \\part, \\ctl, \\value", "control change, controller by number"),
        ("pc", "part, prog, bank_lsb, bank_msb", "0xc0 + \\part, \\prog, \\bank_lsb, \\bank_msb",
         "program change: the three bytes of a part set-up's prog/bank_lsb/bank_msb"),
        ("bend", "part, lsb, msb", "0xe0 + \\part, \\lsb, \\msb", "pitch bend"),
        ("pres", "part, value", "0xd0 + \\part, \\value", "channel pressure"),
    ]
    for cc, nm in sorted(CC_NAMES.items(), key=lambda x: x[1]):
        defs.append((nm, "part, value", f"0xb0 + \\part, {cc}, \\value", f"CC{cc}"))
    for name, params, body, doc in defs:
        w(f"# {name}: {doc}")
        w(f".macro {name} {params}")
        w(f"\t.byte {body}")
        w(".endm")
        w(f".macro @{name} tick, {params}")
        w(f"\t.byte \\tick, {body}")
        w(".endm")
    w("# A position byte with no event after it (the data of this ROM needs none).")
    w(".macro at tick")
    w("\t.byte \\tick")
    w(".endm")
    w("# The beat marker (a stream holds bars x beats of them) and the end of the stream.")
    w(".macro beat")
    w("\t.byte 0xf4")
    w(".endm")
    w(".macro end")
    w("\t.byte 0xf5")
    w(".endm")
    w("# Drum keys, used on parts 0 and 7: the names of table 84's Standard Kit 1 (tone 0x260000;")
    w("# its per-note voice records, TgNoteOnTableTone). The other kits keep the layout: 92.5 % of the")
    w("# styles' drum notes play a voice of that name in their own kit (notes/ic18-rhythm-rom.md).")
    for k, nm in sorted(DRUM_KEYS.items()):
        w(f".equ {nm}, {k}")
    w("# Note conversion rules (a note's last byte): NoteConvRules 0x48736104, by the name of the")
    w("# rule's table in program 941. NcrNone has no table: the key does not follow the chord.")
    for k, nm in sorted(NCR_NAMES.items()):
        w(f".equ {nm}, {k}")
    return m


def group_dir(name):
    g = name.lower().replace("&", " and ")
    return re.sub(r"[^a-z0-9]+", "_", g).strip("_")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rom", required=True)
    ap.add_argument("--program", required=True)
    ap.add_argument("--table", required=True)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    data = open(args.rom, "rb").read()
    if hashlib.sha1(data).hexdigest() != IC18_SHA1:
        raise SystemExit(f"{args.rom}: not the IC18 reference (SHA-1 {IC18_SHA1})")
    im = Img(data)
    d = data
    prog = open(args.program, "rb").read()
    table = open(args.table, "rb").read()
    check_ncr_names(prog)

    # ---- header -----------------------------------------------------------
    if d[BASE:BASE + 16] != b"Technics Rhythms":
        raise SystemExit("no signature at 0x10000")
    ck = im.u16(BASE + 0x10)
    ck_start, ck_len = im.u24(BASE + 0x12), im.u24(BASE + 0x15)
    o_count, o_index, o_styles, o_countin, o_fallback = (im.u24(BASE + x) for x in (0x18, 0x1B, 0x1E, 0x21, 0x24))
    calc = sum(struct.unpack_from(f">{ck_len}H", d, BASE + ck_start)) & 0xFFFF
    if calc != ck:
        raise SystemExit("checksum does not match")
    if (o_count, o_index) != (0x27, 0x33) or o_styles != o_index + 0x1000:
        raise SystemExit("unexpected header layout")
    count = im.u16(BASE + o_count + 2)
    nstyles = (o_countin - o_styles) // 3
    styles = [im.u24(BASE + o_styles + 3 * i) for i in range(nstyles)]
    countins = [im.u24(BASE + o_countin + 3 * k) for k in range(8)]
    if countins[0] != o_countin + 24 or styles[0] != o_fallback:
        raise SystemExit("unexpected table layout")
    index = [im.u16(BASE + o_index + 2 * i) for i in range(0x800)]

    # ---- program 941: the rhythm groups -------------------------------------
    genre_of = {}
    go = GENRE_TABLE - PROGRAM_BASE
    for g in range(16):
        rec = prog[go + g * 0x18:go + g * 0x18 + 0x18]
        gname = rec[:16].decode("ascii").strip()
        n = rec[0x11]
        ptr = struct.unpack_from("<I", rec, 0x14)[0] - PROGRAM_BASE
        for k in range(n):
            sid = struct.unpack_from("<I", prog, ptr + 4 * k)[0]
            if sid & 0x00700000:   # a MEMORY or CUSTOM style (StyleNameSourceSet)
                continue
            i = ((sid & 0xF00) >> 1) | (sid & 0x7F)
            e = index[i]
            if e >> 14 == 2:
                e = index[e & 0x7FF]
            if e < nstyles and e not in genre_of:
                genre_of[e] = (gname, k + 1, n, sid)
    # ---- table 84: the styles the index sends to the table ROM ---------------
    sub = struct.unpack_from("<I", table, TABLE_STYLE_SUBTABLE_DIR)[0]
    tnames = []
    for k in range(64):
        off = (table[sub + 3 * k] << 16) | (table[sub + 3 * k + 1] << 8) | table[sub + 3 * k + 2]
        nm = table[sub + off:sub + off + 13]
        if off == 0 or sub + off + 13 > len(table) or not all(0x20 <= b < 0x7F for b in nm):
            break
        tnames.append(nm.decode("ascii"))

    # ---- styles ---------------------------------------------------------------
    used = set()
    out = []
    w = out.append
    labels = []
    for i, r in enumerate(styles):
        nm = d[BASE + r:BASE + r + 13]
        if not all(0x20 <= b < 0x7F and b != 0x22 and b != 0x5C for b in nm):
            raise SystemExit(f"style {i}: name {nm!r} is not plain ASCII")
        labels.append(label_of(nm.decode("ascii").strip(), used))
    ends = styles[1:] + [None]

    def var_record(lab, o, slotname, what):
        """o = file offset of a variation record -> its source lines and its end."""
        bars, beats = d[o] + 1, d[o + 1] + 1
        if d[o + 1] > 7:
            raise SystemExit(f"{what}: meter byte {d[o + 1]:#x}")
        L = im.u16(o + 4)
        S = im.u24(o + 6 + L)
        s = o + 9 + L
        e = s + S
        check_stream(d, s, e, bars * beats, what)
        v = f"{lab}_{slotname}" if slotname else lab
        lines = [f"{v}:\t# {bars} bars of {beats} beats",
                 f"\tvar_head\t{v}, {bars}, {beats}, {hx(d[o + 2])}, {hx(d[o + 3])}"]
        setup = event_lines(d, o + 6, o + 6 + L)
        if any(x.startswith(("\t@", "\tat", "\tbeat", "\tend")) for x in setup):
            raise SystemExit(f"{what}: a set-up event with a position, or a meta event")
        lines += setup
        lines.append(f"\tvar_events\t{v}")
        lines += event_lines(d, s, e)
        lines.append(f"\tvar_end\t{v}")
        return v, s, e, lines, bars, beats

    import os
    src_dir = os.path.dirname(args.out)
    style_src = []
    style_files = {}
    for i, r in enumerate(styles):
        o = BASE + r
        lab = labels[i]
        nm = d[o:o + 13].decode("ascii")
        g = genre_of.get(i)
        offs = [im.u24(o + 0x8A + 3 * j) for j in range(20)]
        if d[o + 0x89] != 1 or min(offs) != 0xC6 or len(set(offs)) != 20:
            raise SystemExit(f"style {i}: unexpected record layout")
        body = []
        S = body.append
        S("")
        S("# " + "-" * 92)
        if g:
            S(f'# Style {i}: "{nm.strip()}", {g[0]} {g[1]} of {g[2]}, style-ID 0x{g[3]:03x}')
        else:
            S(f'# Style {i}: "{nm.strip()}"')
        S(f"{lab}:")
        S(f'\t.ascii\t"{nm}"')
        p4, p5 = dsp_preset(prog, d[o + 13:o + 15]), dsp_preset(prog, d[o + 15:o + 17])
        if p4 is None or p5 is None:
            raise SystemExit(f"style {i}: a sound-unit key that is no DSP preset of program 941")
        tm = ", TOTAL MODE" if d[o + 14] & 0x80 else ""
        S(f"\tstyle_units\t{hx(d[o + 13])}, {hx(d[o + 14])}, {hx(d[o + 15])}, {hx(d[o + 16])}"
          f'\t# EFF4 "{p4}", EFF5 "{p5}"{tm}')
        for p in range(8):
            f = d[o + 0x11 + 15 * p:o + 0x11 + 15 * p + 15]
            vals = [hx(f[0]), str(f[1]), hx(f[2]), hx(f[3]), hx(f[4])] + [str(x) for x in f[5:]]
            S(f"\tstyle_part\t{', '.join(vals)}\t# {PART_NAMES[p]}")
        S("\t.byte\t1\t\t\t# +0x89: unread (1 in every style; no reader in 941, notes/ic18-rhythm-rom.md)")
        S(f"\tstyle_slots\t{lab}")
        pos = o + 0xC6
        for off in sorted(offs):
            j = offs.index(off)
            if o + off != pos:
                raise SystemExit(f"style {i}: gap before slot {j}")
            v, s, e, lines, bars, beats = var_record(lab, o + off, SLOT_NAMES[j], f"style {i} slot {j}")
            body += lines
            pos = e
        rel = f"styles/{group_dir(g[0])}/{lab[6:]}.s"
        head = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
                "# Licensed under the terms of the GNU General Public License v3 or later",
                "#",
                f'# IC18 style {i}, "{nm.strip()}" ({g[0]} {g[1]} of {g[2]}): its record and its 20',
                "# variations, every event typed. GENERATED by tools/gen_ic18_rhythm_s.py; included by",
                "# src/ic18/rhythm.s, which defines the macros. notes/ic18-rhythm-rom.md is the format."]
        style_files[rel] = head + body
        style_src.append(f'.include "src/ic18/{rel}"\t# style {i}: {nm.strip()}')
        nxt = BASE + ends[i] if ends[i] is not None else None
        if nxt is not None and pos != nxt:
            raise SystemExit(f"style {i}: ends at {pos:#x}, next starts at {nxt:#x}")
    last_end = pos

    # ---- the leftovers past the last style ------------------------------------
    old_slots = ["Var3", "Var3Fill1", "Var3Fill2", "Var4", "Var4Fill1", "Var4Fill2",
                 "Ending1Major", "Ending1Minor", "Ending2Major", "Ending2Minor"]
    tail_src = []
    T = tail_src.append
    f0_end = d.index(b"\xf5", last_end) + 1
    T("")
    T("# " + "=" * 92)
    T("# Past the last style: an older build's data, which nothing in the directory reaches.")
    T("# First the end of an event stream whose start the current data overwrote, then ten whole")
    T("# variation records of a style that is not in this build. [INFERENCE] By their bar counts")
    T("# (4,1,1, 4,1,1, then two equal pairs) and the order every style here stores its slots in,")
    T("# they are slots Var3..Var4Fill2 and the four endings of that style, and the fragment")
    T("# before them the end of its Var2Fill2. Then two shorter fragments of event streams, the")
    T("# second a copy of the first one's last 135 bytes.")
    T("OldBuildStyle_Var2Fill2_Tail:")
    tail_src += fragment_lines(d, last_end, f0_end)
    pos = f0_end
    for k, sl in enumerate(old_slots):
        v, s, e, lines, bars, beats = var_record("OldBuildStyle", pos, sl, f"leftover {k}")
        tail_src += lines
        pos = e
    used_end = len(d[:0x3FFFE8].rstrip(b"\xff"))
    f1_end = d.index(b"\xf5", pos) + 1
    if d[f1_end:used_end] != d[f1_end - (used_end - f1_end):f1_end]:
        raise SystemExit("the last fragment is not a copy of the end of the one before")
    T("# A fragment of older events, which starts inside a note event.")
    T("OldBuildFragment1:")
    tail_src += fragment_lines(d, pos, f1_end)
    T(f"# The last {used_end - f1_end} bytes of OldBuildFragment1 again.")
    T("OldBuildFragment2:")
    tail_src += fragment_lines(d, f1_end, used_end)
    if d[used_end:0x3FFFE8] != b"\xff" * (0x3FFFE8 - used_end):
        raise SystemExit("not erased before the version string")
    ver = d[0x3FFFE8:0x3FFFF2]
    if ver != b"jkr_33.ssf" or d[0x3FFFF2:0x3FFFF8] != bytes(6) or d[0x3FFFF8:] != b"\xff" * 8:
        raise SystemExit("unexpected top of chip")
    old_src = tail_src
    tail_src = []
    T = tail_src.append
    T("")
    T('.include "src/ic18/old_build.s"\t# an older build\'s leftovers past the last style')
    T("")
    T(f"\t.space\t0x{0x3FFFE8 - used_end:x}, 0xff\t\t# erased")
    T("# The version of this data: AcRhythmVerBoxProc (program 941) reads the two digits at")
    T("# 0x3FFFEC and shows them as RHYTHM 33 on the SP7001 DEBUG TOOLS screen.")
    T("RhythmRomVersion:")
    T('\t.ascii\t"jkr_33.ssf"')
    T("\t.space\t6\t\t\t# NUL padding to 16 bytes")
    T("\t.space\t8, 0xff\t\t\t# erased")
    T(".org 0x400000")

    # ---- the directory ----------------------------------------------------------
    w("# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>")
    w("# Licensed under the terms of the GNU General Public License v3 or later")
    w("#")
    w("# IC18 (C3CBND000046) from 0x10000 to the end: the built-in \"Technics Rhythms\" style")
    w("# resource, which the firmware finds at 0x40010000 (StyleResourceWindowProbe, its third")
    w("# window) and opens with StyleBuiltinNameTableInit. GENERATED by tools/gen_ic18_rhythm_s.py")
    w("# (`make ic18-rhythm-src`); notes/ic18-rhythm-rom.md is the format and its evidence.")
    w(f"#   {nstyles} styles x 20 variations, 8 count-in patterns; {count} rhythms in all with the")
    w(f"#   {count - nstyles} that live in the table ROM.")
    w("#")
    w("# Every multi-byte field is BIG-endian (.be16/.be24): the firmware reads this resource")
    w("# through LoadU16BE / LoadU24BE / SumU16BE, although the MN10300 is little-endian.")
    w("# Offsets are from the resource start, TechnicsRhythms.")
    w("#")
    w("# Each style, its record and its 20 variations with every event typed, is in its own")
    w("# file, src/ic18/styles/<rhythm group>/<style>.s; the older build's leftovers are in")
    w("# src/ic18/old_build.s. The macros below are theirs too.")
    w("")
    w(".mnbase 0x40000000")
    w("")
    w("# ---- record macros ----------------------------------------------------------------")
    w("# A part set-up (15 bytes): each byte is the value of one controller, in the order of")
    w("# the firmware's field table 0x485B77D4 (CC -> field map 0x485B781C). The firmware")
    w("# copies the eight of a style into the part table 0x5003A37C (func_4844187A); the")
    w("# set-up events of a variation then overwrite single fields (func_48441EB4).")
    w("# The meanings are program 941's (notes/ic18-rhythm-rom.md, \"A part set-up\"): the CC is turned")
    w("# into the part parameter 0xB000cc (func_48440533), named by the SP7001 parameter dump")
    w("# func_48500C71 (\"EQ LOW FC\", \"DIGITAL EFFECT\" ...).")
    w("#   fold_root  CC97, never sent (func_48440662 skips a controller above 127; the field table")
    w("#              gives it 255): a note follows the chord root up by root - 1 semitones, an")
    w("#              octave lower when root - 1 > fold_root (func_484419BB -> func_48436229).")
    w("#              0x00 on the drum parts, 0x08 (G#) on the others")
    w("#   volume     CC7, sent folded into CC11 (func_48440662: expression + volume - 127)")
    w("#   prog, bank_lsb, bank_msb   the part's sound {program, bank LSB, bank MSB}; MSB 0x26 = kits")
    w("#   dsp_sw     CC94, DIGITAL EFFECT: 0 off, 127 on, any other value (64 in every style) the")
    w("#              sound's own setting, which func_48448D93 looks up (func_48440662 sends 0 or 127)")
    w("#   reverb     CC91          chorus   CC93 (CHORUS DEPTH)          pan   CC10")
    w("#   bend_range CC96 -> parameter 0xB08000, RPN 0: BEND SENS, in semitones")
    w("#   eq_lo_fc, eq_lo_gain, eq_hi_fc, eq_hi_gain   CC82, CC83, CC80, CC81: the part EQ; FC >> 2")
    w("#              indexes 20 Hz .. 20 kHz in third octaves (0x485EC344, func_4848BC9A), gain (v - 64) / 2 dB")
    w("#   multi      CC92, MULTI EFFECT DEPTH")
    w(".macro style_part fold_root, volume, prog, bank_lsb, bank_msb, dsp_sw, reverb, chorus, pan, bend_range, eq_lo_fc, eq_lo_gain, eq_hi_fc, eq_hi_gain, multi")
    w("\t.byte\t\\fold_root, \\volume, \\prog, \\bank_lsb, \\bank_msb, \\dsp_sw, \\reverb, \\chorus, \\pan")
    w("\t.byte\t\\bend_range, \\eq_lo_fc, \\eq_lo_gain, \\eq_hi_fc, \\eq_hi_gain, \\multi")
    w(".endm")
    w("# The two sound-unit keys of a style (record +0x0D, 4 bytes; func_484420EF): each pair is")
    w("# a 14-bit value, 7 bits a byte, low byte first (bit 6 of the second byte adds 0x10000),")
    w("# stored to parameter keys 0xB044 and 0xB054: the DSP preset of effect units EFF4 and EFF5")
    w("# (groups 0xB040 / 0xB050, SndUnitRefreshGroups56). The key is a preset of program 941's")
    w("# table 0x48703558, index lo << 6 | hi (func_48412187), whose name the comment gives.")
    w("# Bit 7 of the first pair's second byte goes to key 0xB001, the EFFECT DEBUG screen's")
    w("# TOTAL MODE / SOUND MODE switch (EffApcSw).")
    w(".macro style_units eff4_lo, eff4_hi, eff5_lo, eff5_hi")
    w("\t.byte\t\\eff4_lo, \\eff4_hi, \\eff5_lo, \\eff5_hi")
    w(".endm")
    w("# The 20 slot offsets of a style (record +0x8A, from the record): StyleNameCommit loads")
    w("# them into 0x50034BCC[]. Slots 0-11 are four variations, each a main pattern and two")
    w("# fill-ins (only slot % 3 == 0 has a name in a MEMORY style: MemStyleVarCopy). 12-19 are")
    w("# INTRO 1, ENDING 1, INTRO 2, ENDING 2 (slot 12 + 4k, 14 + 4k: func_484437DA, func_484439EB),")
    w("# each a major and a minor version: StyleRecordSlotSelect adds 0x5003A46A, 1 for a minor-")
    w("# family chord (func_484361BC). [INFERENCE] the fill-in role")
    w(".macro style_slots s")
    w("\t.be24\t\\s_Var1 - \\s, \\s_Var1Fill1 - \\s, \\s_Var1Fill2 - \\s")
    w("\t.be24\t\\s_Var2 - \\s, \\s_Var2Fill1 - \\s, \\s_Var2Fill2 - \\s")
    w("\t.be24\t\\s_Var3 - \\s, \\s_Var3Fill1 - \\s, \\s_Var3Fill2 - \\s")
    w("\t.be24\t\\s_Var4 - \\s, \\s_Var4Fill1 - \\s, \\s_Var4Fill2 - \\s")
    w("\t.be24\t\\s_Intro1Major - \\s, \\s_Intro1Minor - \\s, \\s_Ending1Major - \\s, \\s_Ending1Minor - \\s")
    w("\t.be24\t\\s_Intro2Major - \\s, \\s_Intro2Minor - \\s, \\s_Ending2Major - \\s, \\s_Ending2Minor - \\s")
    w(".endm")
    w("# A variation record (StyleRecordBindBuiltin): bars - 1 (-> 0x50122DCE), beats a bar - 1")
    w("# (-> 0x50122DCF; StyleBoundRecByteCfLow3), two part numbers for the sound units (0xFF =")
    w("# none; func_48442164, key 0xB048 [INFERENCE: the role]), the length of the set-up")
    w("# events, the events; then the length of the event stream and the stream.")
    w(".macro var_head v, bars, beats, unit_part_a, unit_part_b")
    w("\t.byte\t\\bars - 1, \\beats - 1, \\unit_part_a, \\unit_part_b")
    w("\t.be16\t\\v_SetupEnd - \\v_Setup")
    w("\\v_Setup:")
    w(".endm")
    w(".macro var_events v")
    w("\\v_SetupEnd:")
    w("\t.be24\t\\v_EventsEnd - \\v_Events")
    w("\\v_Events:")
    w(".endm")
    w(".macro var_end v")
    w("\\v_EventsEnd:")
    w(".endm")
    out += macro_defs()
    w(".macro sidx_style no")
    w("\t.be16\t\\no")
    w(".endm")
    w(".macro sidx_alias entry")
    w("\t.be16\t0x8000 + \\entry")
    w(".endm")
    w(".macro sidx_table no")
    w("\t.be16\t0x4000 + \\no")
    w(".endm")
    w("")
    w("# ---- the header (StyleBuiltinNameTableInit, StyleResourceVerify) -----------------")
    w(".org 0x10000")
    w("TechnicsRhythms:")
    w('\t.ascii\t"Technics Rhythms"\t\t# strncmp with the firmware\'s 0x4872980C')
    w(f"\t.be16\t0x{ck:04x}\t\t\t# SumU16BE of the halfwords below, StyleResourceVerify")
    w(f"\t.be24\t0x{ck_start:06x}\t\t\t# checksum start, from TechnicsRhythms: file 0x{BASE + ck_start:x}, inside a stream")
    w(f"\t.be24\t0x{ck_len:06x}\t\t\t# checksum length in halfwords (2 MB)")
    w("\t.be24\tRhythmCountBlock - TechnicsRhythms")
    w("\t.be24\tRhythmStyleIndex - TechnicsRhythms\t# -> 0x50034B7C")
    w("\t.be24\tRhythmStyleTable - TechnicsRhythms\t# -> 0x50034B80")
    w("\t.be24\tRhythmCountInTable - TechnicsRhythms\t# -> 0x50034B84")
    w(f"\t.be24\t{labels[0]} - TechnicsRhythms\t# -> 0x50034B88, the fallback style")
    w("RhythmCountBlock:")
    blk = d[BASE + o_count:BASE + o_index]
    if im.u16(BASE + o_count) != 0 or im.u16(BASE + o_count + 4) != 96:
        raise SystemExit("unexpected count block")
    w("# Only the u16 at +2 is read (StyleBuiltinNameTableInit: `add 2, a0` / LoadU16BE); no routine")
    w("# reads the other ten bytes (notes/mn10300-names-probes/rhythm_count_block_readers.py).")
    w("\t.be16\t0\t\t\t# unread")
    w(f"\t.be16\t{count}\t\t\t# the rhythm count -> 0x50034B74; the index's limit")
    w("\t.be16\t96\t\t\t# unread; [INFERENCE] ticks a beat: every position byte of every stream is 0..95")
    w(f"\t.byte\t{', '.join(str(x) for x in blk[6:])}\t# unread; [INFERENCE] name length 13, 8 parts, 4 variations, 2 fill-ins,")
    w("\t\t\t\t\t# 2 intros, 2 endings (4 + 4x2 + 2x2 + 2x2 = 20 slots)")
    w("")
    w("# ---- the style-ID index (StyleBuiltinNameResolve) --------------------------------")
    w("# 2048 entries; entry ((id & 0x0F00) >> 1) | (id & 0x7F) serves style-ID id. An entry")
    w(f"# below {count} is a style of this table, 0x8000 + n sends the ID to entry n, 0x4000 + n to")
    w("# style n of the table ROM's secondary sub-table (TableRomStyleSubTablePtr). Every ID")
    w("# resolves to some style.")
    for i, r in enumerate(styles):
        w(f".equ SNo_{labels[i][6:]}, {i}")
    w("RhythmStyleIndex:")
    for i, e in enumerate(index):
        if i % 128 == 0:
            w(f"# style-IDs 0x{sid_of_entry(i):03x}-0x{sid_of_entry(i + 127):03x}")
        sid = sid_of_entry(i)
        if e < nstyles:
            w(f"\tsidx_style\tSNo_{labels[e][6:]}\t# id 0x{sid:03x}")
        elif e >> 14 == 2:
            t = e & 0x7FF
            w(f"\tsidx_alias\t0x{t:03x}\t\t# id 0x{sid:03x} -> id 0x{sid_of_entry(t):03x}")
        elif e >> 14 == 1:
            t = e & 0x3FFF
            nm = f' "{tnames[t].strip()}"' if t < len(tnames) else ""
            w(f"\tsidx_table\t{t}\t\t# id 0x{sid:03x}: table ROM style {t}{nm}")
        else:
            raise SystemExit(f"index entry {i}: {e:#x}")
    w("")
    w("# ---- the style table: 3-byte offsets (StyleBuiltinNameResolve) -------------------")
    w("RhythmStyleTable:")
    for i in range(nstyles):
        w(f"\t.be24\t{labels[i]} - TechnicsRhythms")
    w("")
    w("# ---- the count-in patterns, one per meter (StyleCountInRecordGet) ---------------")
    w("# Slot 20 of StyleRecordSlotSelect: the low 3 bits of the main variation's meter byte pick")
    w("# one. With COUNT INTRO on (parameter 0xD00A == 1) a 1-4 beat meter takes the program's")
    w("# own pattern instead (table 0x48736078: Voice Kit keys 74-77, \"Count 1\"..\"Count 4\").")
    w("RhythmCountInTable:")
    for k in range(8):
        w(f"\t.be24\tCountIn_{k + 1}Beats - TechnicsRhythms")
    pos = BASE + o_countin + 24
    for k in range(8):
        o = BASE + countins[k]
        if o != pos:
            raise SystemExit(f"count-in {k} does not follow the one before")
        v, s, e, lines, bars, beats = var_record(f"CountIn_{k + 1}Beats", o, None, f"count-in {k}")
        if (bars, beats) != (1, k + 1):
            raise SystemExit(f"count-in {k}: {bars} bars of {beats}")
        out += lines
        pos = e
    if pos != BASE + styles[0]:
        raise SystemExit("count-in patterns do not end at the first style")
    out += style_src
    out += tail_src
    open(args.out, "w").write("\n".join(out) + "\n")
    for rel, lines in style_files.items():
        os.makedirs(os.path.join(src_dir, os.path.dirname(rel)), exist_ok=True)
        open(os.path.join(src_dir, rel), "w").write("\n".join(lines) + "\n")
    old_head = ["# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>",
                "# Licensed under the terms of the GNU General Public License v3 or later",
                "#",
                "# IC18 0x3FBAD3-0x3FFC6D: an older build's leftovers, every event typed as far as it",
                "# parses. GENERATED by tools/gen_ic18_rhythm_s.py; included by src/ic18/rhythm.s."]
    open(os.path.join(src_dir, "old_build.s"), "w").write("\n".join(old_head + old_src) + "\n")
    have = set()
    for root, _, files in os.walk(os.path.join(src_dir, "styles")):
        have |= {os.path.relpath(os.path.join(root, f), src_dir) for f in files}
    stale = sorted(have - set(style_files))
    if stale:
        print("stale style files (not written by this run; remove them):", *stale)
    print(f"{args.out}: {len(out)} lines, {nstyles} styles, {len(genre_of)} in a rhythm group,"
          f" {len(tnames)} table-ROM names")


if __name__ == "__main__":
    sys.exit(main())
