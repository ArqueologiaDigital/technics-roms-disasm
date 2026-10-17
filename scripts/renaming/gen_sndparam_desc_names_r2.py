#!/usr/bin/env python3
"""gen_sndparam_desc_names_r2.py -- round 2: name the sound-parameter descriptors the firmware itself identifies.

QUESTION IT ANSWERS / WHAT IT DOES
  The 972 pointers of SndParam_RegisterLoop_Data (v10 0xEE01A0) register the 18-byte sound-parameter descriptors
  (sndparam_types.h: u32 key, record = bank_index, byte = bank_offset, bits = mask, clamp range ...).  Round 1
  (gen_sndparam_desc_names.py) named the per-part ones whose field constant k was settled, as
  SndParam_Part<TT>_<Field>.  After it, 557 descriptors per tree still carried the positional aliases
  ExtPartParam_Entry_NNN / SeqMixParam_Entry_NNN / MidiChParam_Entry_NNN / VoiceCtrlR1_Entry_NNN /
  PartParam_Entry_NNN / VoiceParamEx_Entry_NNN, which sndparam_types.h itself calls "NOT evidence of anything"
  (address-range bucketing).  This script names every descriptor whose key the firmware ties to a meaning, and
  writes  <old alias> -> <new name>  rules into scripts/renaming/rename_sndparam_desc_r2_<tree>.sed.

  How a key is identified (README-lsw-param-namespace-map.md, section 8, has the full table and the citations):
  * PART KEYS.  SndParam_KeyToLswPartNumber (v10 0xFCD7C5, audio/sndparam_routines.s; it was SndParam_DecodeMidiAddr) is the firmware's own decode of a
    key into an Lsw (part, number) pair: for 0x8000 <= key <= 0x17FFF, part = ((key - 0x8000) >> 10) & 0x3F and
    number = key & 0x3FF; for 0x18000 <= key <= 0x27FFF the same part and number = (key & 0x3FF) + 0x400.  The Lsw*
    part-parameter ApFunctions (ui/drawbar_panel_ui.s) answer EVT_GET_LSW_DATA_NO with the number they edit:
    LswLocalControl 0x400, LswMidiChannel 0x401, LswSustainLength 0x600, LswSustainPedal 0x601, LswKeyScaling
    0x602, LswGlidePedal 0x603, LswPartExp 0x604, LswAfterTouch 0x606, LswDrawRelease 0x293, LswDrawAttack 0x294,
    LswPercLevel 0x2CB, LswPercDecay 0x2CC.  LswMidiChannel's EVT_GET_LSW_STRING arm prints "OFF" instead of
    "CH%2d" when (part, 0x402) reads 0, so 0x402 is the part's MIDI-channel ON flag.  Each part field is asserted
    to sit on the same (byte, mask) of the part's own record (bank_index = part tag) in every part that has it.
  * The mixer's channel table (AcMixerVol_Channels, README section 6) lists METR with keys 0xE807 / 0xE808 =
    (part 0x1A, 0x07 volume / 0x08 mute), held in record 0x98: the metronome's volume and mute; MIC with 0x4141 /
    0x4142 (record 0x43 +1, 0x7F / 0x80); MSP with 0x28801 / 0x2880B, which LswVolume / LswMute answer for part
    0x17 -- as LswReverb answers 0x28802 -- in record 0x72 (they were NakaInst_Param_Idx01_88 / _Idx0B_88 /
    _Idx02_88, names that only restated the key).
  * Lsw functions that edit one global value answer EVT_GET_LSW_ADDRESS with its key: LswLeftHold 0x28082,
    LswOrchestrator 0x4201, LswScalingMode 0x4280, LswScalingType 0x4281, LswScalingShift(2) 0x4282.  The
    computer-connect screen's function MdCmptCnct answers 0x2C00 (record 0x98 +14, 0..2); its EVT_GET_LSW_STRING arm
    draws Bitmap_MIDIConnections_1/2/3 for values 0/1/2 ("KN as master" for 1, "KN as slave" for 2).
  * MainGetPmemName reads 0x300 (record 0x98 +1, 0..80) as the current panel-memory number: bank = (n - 1) >> 3.
  * GLOBAL KEYS, each from a screen or a dispatcher that already names it:
    - InOutGridCheck (midi/ac_listener_handlers.s), the MIDI IN/OUT grid: RIGHT 1 INPUT 0x2100, AUTO PLAY CHORD
      input 0x2101, VELOCITY INPUT mode 0x5000 (DIRECT/OFFSET/FIX) with OFFSET VALUE 0x5001 and FIXED VALUE 0x5002,
      TECHNI-CHORD / DRUM PATTERN / AUTO PLAY CHORD / TRANSPOSE output 0x2181 / 0x2182 / 0x2183 / 0x2184;
    - the CONTROL menu's OVERALL TOUCH SENSITIVITY grid (TchSensGrid, ui/ui_mode_handlers.s): row 1 VELOCITY SENSE
      0x100, rows 4-6 AFTER TOUCH ON/OFF 0x104, CURVE 0x102, THRESHOLD 0x103 (row captions from the grid's
      fixedrow string in naka_ctrl_menu_body.bin +0x592);
    - the FOOT CONTROLLERS grid (FSWAssGrid): rows FOOT SWITCH 1/2 = 0x2886 / 0x2888, FOOT CONT.SW 1-4 = 0x288A /
      0x288C / 0x288E / 0x2890, EXPRESS. PEDAL = 0x2880 (fixedrow string, naka_ctrl_menu_body.bin +0x3CE);
    - the VOCALIST WORKSTATION grid (VocalistGridCheck): the case table VocalistGridCheck_LswCaseTable (indexed by
      key - 0x2D00) and the grid strings (naka_midi_reverb.bin +0x3982): rows MIDI CHANNEL, PROGRAM, HARMONY, KEY,
      P.CNG OPTION, CONTROL VOL. (value 0x2D00 + 2r, SEND flag 0x2D01 + 2r), VOCODER and CHORDAL (KEY SPLIT
      0x2D0C / 0x2D10 drawn from bit 7 + bits 0-6, which are 0x2D0E/0x2D12 and 0x2D0D/0x2D11; IGNORE 0x2D0F /
      0x2D13);
    - SndParam_ApplySystemParam's switch (audio/note_voice_mapping.s): 0x4002 reverb on/off, 0x4003 digital
      effect on/off, 0x4004 acoustic illusion on/off, 0x4006 equalizer on/off, 0x4280-0x428E scale tune;
    - the format-3 importer (README-lsw-formats-1-and-3.md): 0x4900 = DSP EFFECT algorithm (slot 0, record 0x61),
      0x4B00 = DIGITAL REVERB algorithm (slot 1, record 0x63);
    - record 0x48 +8 is the tempo (SeqTimer_PostTempoUpdate stores it and posts (e=0x48, d=8)); key 0x0004 edits
      that byte, clamped 40..255.
  Descriptors whose key has no such basis keep their names; the script prints them, grouped by record.

  v9 and v7 hold the same aliases.  A rule is taken for them only when the key at the alias's address in that
  tree's own ROM is the key the rule was made for.

RUN (repository root, built tree)
  python3 scripts/renaming/gen_sndparam_desc_names_r2.py            # dry run: counts, the unnamed rest
  python3 scripts/renaming/gen_sndparam_desc_names_r2.py --write    # writes rename_sndparam_desc_r2_<tree>.sed
  python3 scripts/renaming/gen_sndparam_desc_names_r2.py --markdown # the README / technics-docs tables (v10)
  python3 scripts/renaming/gen_sndparam_desc_names_r2.py --markdown-parts   # every named per-part field (v10)
  then per tree: sed -i -f scripts/renaming/rename_sndparam_desc_r2_<tree>.sed <the files that use the names>
"""
import collections
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
NM = os.path.expanduser("~/compartilhado/llvm-project/build/bin/llvm-nm")
ALIAS = re.compile(r'^(ExtPartParam|SeqMixParam|MidiChParam|VoiceCtrlR1|PartParam|VoiceParamEx)_Entry_\d+$')
# earlier positional-in-substance names of three MSP descriptors, replaced by the Lsw functions' answers
WEAK = {"NakaInst_Param_Idx01_88", "NakaInst_Param_Idx02_88", "NakaInst_Param_Idx0B_88"}

# per-part Lsw numbers (decoded key -> number) the firmware's Lsw* ApFunctions answer
PART_FIELDS = {
    0x400: "LocalControl", 0x401: "MidiChannel", 0x402: "MidiChannelOn",
    0x600: "SustainLength", 0x601: "SustainPedal", 0x602: "KeyScaling", 0x603: "GlidePedal", 0x604: "PartExp",
    0x606: "AfterTouch",
    0x293: "DrawRelease", 0x294: "DrawAttack", 0x2CB: "PercLevel", 0x2CC: "PercDecay",
}
DRAWBAR = {0x293, 0x294, 0x2CB, 0x2CC}          # in the +0x200 drawbar sub-namespace of parts 0-2 (records 0x44-0x46)
# whole keys -> name (record, byte, mask asserted so a moved field stops the script)
GLOBAL = {
    0xE807: ("Metronome_Volume", 0x98, 4, 0x7F), 0xE808: ("Metronome_Mute", 0x98, 4, 0x80),
    0x4141: ("Mic_Volume", 0x43, 1, 0x7F), 0x4142: ("Mic_Mute", 0x43, 1, 0x80),
    0x28801: ("Msp_Volume", 0x72, 3, 0x7F), 0x2880B: ("Msp_Mute", 0x72, 3, 0x80), 0x28802: ("Msp_Reverb", 0x72, 7, 0x7F),
    0x28082: ("LeftHold", 0x90, 3, 0x01),
    0x4201: ("Orchestrator", 0x70, 3, 0xFF),
    0x2C00: ("ComputerConnectMode", 0x98, 14, 0x03),
    0x0300: ("PanelMemory_Number", 0x98, 1, 0x7F),
    0x0004: ("Tempo", 0x48, 8, 0xFF),
    0x0100: ("InitialTouch_VelocitySense", 0x93, 0, 0x0F),
    0x0102: ("AfterTouch_Curve", 0x93, 5, 0xFF),
    0x0103: ("AfterTouch_Threshold", 0x93, 6, 0x7F),
    0x0104: ("AfterTouch_OnOff", 0x93, 6, 0x80),
    0x2100: ("MidiIn_Right1Input", 0x80, 3, 0x01),
    0x2101: ("MidiIn_AutoPlayChord", 0x80, 3, 0x04),
    0x5000: ("MidiIn_VelocityMode", 0x80, 10, 0x03),
    0x5001: ("MidiIn_VelocityOffset", 0x80, 11, 0xFF),
    0x5002: ("MidiIn_VelocityFixed", 0x80, 12, 0xFF),
    0x2181: ("MidiOut_TechniChord", 0x80, 3, 0x80),
    0x2182: ("MidiOut_DrumPattern", 0x80, 0, 0x40),
    0x2183: ("MidiOut_AutoPlayChord", 0x80, 3, 0x40),
    0x2184: ("MidiOut_Transpose", 0x80, 0, 0x20),
    0x2880: ("FootCtrl_ExpressionPedal", 0x99, 2, 0xFF),
    0x2886: ("FootCtrl_FootSwitch1", 0x99, 4, 0xFF),
    0x2888: ("FootCtrl_FootSwitch2", 0x99, 5, 0xFF),
    0x288A: ("FootCtrl_FootContSw1", 0x99, 6, 0xFF),
    0x288C: ("FootCtrl_FootContSw2", 0x99, 7, 0xFF),
    0x288E: ("FootCtrl_FootContSw3", 0x99, 8, 0xFF),
    0x2890: ("FootCtrl_FootContSw4", 0x99, 9, 0xFF),
    0x2D00: ("Vocalist_MidiChannel", 0x47, 1, 0x1F), 0x2D01: ("Vocalist_MidiChannelSend", 0x47, 0, 0x01),
    0x2D02: ("Vocalist_Program", 0x47, 2, 0x7F), 0x2D03: ("Vocalist_ProgramSend", 0x47, 0, 0x02),
    0x2D04: ("Vocalist_Harmony", 0x47, 3, 0x07), 0x2D05: ("Vocalist_HarmonySend", 0x47, 0, 0x04),
    0x2D06: ("Vocalist_Key", 0x47, 3, 0xF0), 0x2D07: ("Vocalist_KeySend", 0x47, 0, 0x08),
    0x2D08: ("Vocalist_ProgChangeOption", 0x47, 4, 0xC0), 0x2D09: ("Vocalist_ProgChangeOptionSend", 0x47, 0, 0x10),
    0x2D0A: ("Vocalist_ControlVolume", 0x47, 5, None), 0x2D0B: ("Vocalist_ControlVolumeSend", 0x47, 0, 0x20),
    0x2D0C: ("Vocalist_VocoderKeySplit", 0x47, 6, 0xFF), 0x2D0D: ("Vocalist_VocoderKeySplitNote", 0x47, 6, 0x7F),
    0x2D0E: ("Vocalist_VocoderKeySplitSide", 0x47, 6, 0x80), 0x2D0F: ("Vocalist_VocoderIgnore", 0x47, 0, 0x40),
    0x2D10: ("Vocalist_ChordalKeySplit", 0x47, 7, 0xFF), 0x2D11: ("Vocalist_ChordalKeySplitNote", 0x47, 7, 0x7F),
    0x2D12: ("Vocalist_ChordalKeySplitSide", 0x47, 7, 0x80), 0x2D13: ("Vocalist_ChordalIgnore", 0x47, 0, 0x80),
    0x4002: ("ReverbOnOff", 0x60, 1, 0x80),
    0x4003: ("DigitalEffectOnOff", 0x70, 0, 0x04),
    0x4004: ("AcousticIllusionOnOff", 0x60, 1, 0x40),
    0x4006: ("EqualizerOnOff", 0x60, 1, 0x20),
    0x4280: ("ScaleTune_OnOff", 0x92, 1, 0x80),
    0x4281: ("ScaleTune_Type", 0x92, 0, 0xFF),
    0x4282: ("ScaleTune_Key", 0x92, 1, 0x0F),
    0x4900: ("DspEffect_Algorithm", 0x61, 0, 0xFF),
    0x4B00: ("DigitalReverb_Algorithm", 0x63, 0, 0xFF),
}
for _i in range(12):                              # 0x4283..0x428E: user scale-tune offsets, record 0x92 +2..+13
    GLOBAL[0x4283 + _i] = ("ScaleTune_UserNote%d" % _i, 0x92, 2 + _i, 0xFF)


BASIS = [   # (name prefix, short basis) for the --markdown tables
    ("Metronome_", "mixer channel 26 METR (AcMixerVol_Channels)"),
    ("Mic_", "mixer channel 27 MIC (AcMixerVol_Channels)"),
    ("Msp_", "LswVolume / LswMute / LswReverb answer for part 0x17"),
    ("Tempo", "record 0x48 +8 (SeqTimer_PostTempoUpdate)"),
    ("InitialTouch_", "OVERALL TOUCH SENSITIVITY grid, row VELOCITY SENSE"),
    ("AfterTouch_", "OVERALL TOUCH SENSITIVITY grid, AFTER TOUCH rows"),
    ("MidiIn_", "MIDI IN/OUT grid (InOutGridCheck)"),
    ("MidiOut_", "MIDI IN/OUT grid (InOutGridCheck)"),
    ("FootCtrl_", "FOOT CONTROLLERS grid (FSWAssGrid)"),
    ("Vocalist_", "VOCALIST WORKSTATION grid (VocalistGridCheck)"),
    ("ReverbOnOff", "SndParam_ApplySystemParam case"),
    ("DigitalEffectOnOff", "SndParam_ApplySystemParam case"),
    ("AcousticIllusionOnOff", "SndParam_ApplySystemParam case"),
    ("EqualizerOnOff", "SndParam_ApplySystemParam case"),
    ("ScaleTune_", "SndParam_ApplySystemParam cases; LswScaling* addresses"),
    ("DspEffect_", "format-3 importer, slot 0 (record 0x61)"),
    ("DigitalReverb_", "format-3 importer, slot 1 (record 0x63)"),
    ("LeftHold", "LswLeftHold's EVT_GET_LSW_ADDRESS"),
    ("Orchestrator", "LswOrchestrator's EVT_GET_LSW_ADDRESS"),
    ("ComputerConnectMode", "MdCmptCnct's EVT_GET_LSW_ADDRESS; 0/1/2 pick its 3 connection diagrams"),
    ("PanelMemory_Number", "MainGetPmemName: bank = (n - 1) >> 3"),
]
LSW_FN = {0x400: "LswLocalControl", 0x401: "LswMidiChannel", 0x402: "LswMidiChannel (OFF test)",
          0x600: "LswSustainLength", 0x601: "LswSustainPedal", 0x602: "LswKeyScaling", 0x603: "LswGlidePedal",
          0x604: "LswPartExp", 0x606: "LswAfterTouch", 0x293: "LswDrawRelease", 0x294: "LswDrawAttack",
          0x2CB: "LswPercLevel", 0x2CC: "LswPercDecay"}


def md_table(head, rows):
    """A Markdown table with space-padded, aligned columns."""
    w = [max(len(str(r[i])) for r in [head] + rows) for i in range(len(head))]
    line = lambda r: "| " + " | ".join(str(c).ljust(w[i]) for i, c in enumerate(r)) + " |"
    return "\n".join([line(head), "|" + "|".join("-" * (x + 2) for x in w) + "|"] + [line(r) for r in rows])


def markdown():
    rom = open(os.path.join(REPO, "original_ROMs/kn5000_v10_program.rom"), "rb").read()
    syms = elf_symbols("v10")
    parts, glob_rows, seen = collections.defaultdict(set), [], set()
    for p in registry(rom, syms):
        key, bank, off, mask, lo, hi = descriptor(rom, p)
        d = decode(key)
        if key in GLOBAL and key not in seen:
            seen.add(key)
            nm = GLOBAL[key][0]
            basis = next(b for pre, b in BASIS if nm.startswith(pre))
            glob_rows.append(("0x%05X" % key, "`SndParam_%s`" % nm, "0x%02X" % bank, "+%d" % off, "0x%02X" % mask,
                              "%d..%d" % (lo, hi), basis))
        elif d and d[1] in PART_FIELDS:
            parts[d[1]].add((d[0], off, mask, lo, hi))
    part_rows = []
    for num in sorted(parts):
        tags = sorted(t for t, *_ in parts[num])
        shape = {(o, m, l, h) for _, o, m, l, h in parts[num]}
        o, m, l, h = sorted(shape)[0]
        ks = ("0x%X + 0x400*T" % (0x8000 + num) if num < 0x400 else "0x%X + 0x400*T" % (0x18000 + num - 0x400))
        tr = ("0x%02X-0x%02X" % (tags[0], tags[-1])) + (" (%d)" % len(tags))
        part_rows.append(("0x%03X" % num, ks, "`_%s`" % PART_FIELDS[num], tr, "+%d" % o, "0x%02X" % m,
                          "%d..%d" % (l, h) + ("" if len(shape) == 1 else " *"), LSW_FN[num]))
    print(md_table(("Lsw number", "key", "name suffix", "parts T", "byte", "mask", "range", "firmware basis"), part_rows))
    print()
    glob_rows.sort(key=lambda r: int(r[0], 16))
    print(md_table(("key", "name", "record", "byte", "mask", "range", "basis"), glob_rows))


def markdown_parts_all():
    """Every named per-part field (rounds 1 and 2), from the v10 ELF's SndParam_Part<TT>_<Field> names."""
    rom = open(os.path.join(REPO, "original_ROMs/kn5000_v10_program.rom"), "rb").read()
    syms = elf_symbols("v10")
    fields = collections.defaultdict(set)
    for name, addr in syms.items():
        m = re.match(r'^SndParam_Part([0-9A-F]{2})_(\w+)$', name)
        if not m:
            continue
        key, bank, off, mask, lo, hi = descriptor(rom, addr)
        part, num = decode(key)
        assert part == int(m.group(1), 16), name
        fields[(num, m.group(2))].add((part, bank, off, mask, lo, hi))
    rows = []
    for (num, fld), v in sorted(fields.items()):
        tags = sorted(x[0] for x in v)
        recs = sorted({x[1] for x in v})
        shape = sorted({x[2:] for x in v})
        off, mask, lo, hi = shape[0]
        rec = "part" if recs == tags else "/".join("0x%02X" % r for r in recs)
        rows.append(("0x%03X" % num, "`_%s`" % fld, "%d" % len(tags), rec, "+%d" % off, "0x%02X" % mask,
                     "%d..%d" % (lo, hi) + ("" if len(shape) == 1 else " (varies)")))
    print(md_table(("Lsw number", "field", "parts", "record", "byte", "mask", "range"), rows))


def decode(key):
    """SndParam_KeyToLswPartNumber: the firmware's key -> (part, Lsw number) decode, or None."""
    if 0x8000 <= key <= 0x17FFF:
        return ((key - 0x8000) >> 10) & 0x3F, key & 0x3FF
    if 0x18000 <= key <= 0x27FFF:
        return ((key - 0x8000) >> 10) & 0x3F, (key & 0x3FF) + 0x400
    return None


def elf_symbols(tree):
    out = subprocess.run([NM, "--defined-only", os.path.join(REPO, "rebuilt_ROMs/kn5000_%s_program.llvm.elf" % tree)],
                         capture_output=True, text=True, check=True).stdout
    return {f[2]: int(f[0], 16) for f in (l.split() for l in out.splitlines()) if len(f) == 3}


def registry(rom, syms):
    """The 972 descriptor pointers SndParam_RegisterLoop walks (`ld xwa, SndParam_Registry` ... `cp xiz, 0x3cc`)."""
    start = syms.get("SndParam_RegisterLoop_Data", syms.get("SndParam_Registry")) - 0xE00000
    ptrs = [int.from_bytes(rom[start + 4 * i:start + 4 * i + 4], "little") for i in range(972)]
    assert all(0xEDB000 <= p < 0xEE0200 for p in ptrs), "registry entry outside the descriptor runs"
    return ptrs


def descriptor(rom, addr):
    b = rom[addr - 0xE00000:addr - 0xE00000 + 18]
    return int.from_bytes(b[0:4], "little"), b[4], b[5], b[6], b[7], b[8]


def plan(tree):
    rom = open(os.path.join(REPO, "original_ROMs/kn5000_%s_program.rom" % tree), "rb").read()
    syms = elf_symbols(tree)
    targets = set(registry(rom, syms))
    rules, rest, field_shape = {}, collections.defaultdict(list), collections.defaultdict(set)
    taken = set(syms)
    for name, addr in sorted(syms.items(), key=lambda x: x[1]):
        if not (ALIAS.match(name) or name in WEAK) or addr not in targets:
            continue
        key, bank, off, mask, lo, hi = descriptor(rom, addr)
        new = None
        d = decode(key)
        if key in GLOBAL:
            nm, b_, o_, m_ = GLOBAL[key]
            assert (bank, off) == (b_, o_) and (m_ is None or mask == m_), (tree, name, hex(key), bank, off, mask)
            new = "SndParam_" + nm
        elif d and d[1] in PART_FIELDS:
            part, num = d
            if num in DRAWBAR:
                assert part in (0, 1, 2) and bank == 0x44 + part, (tree, name, hex(key), part, bank)
            else:
                assert bank == part, (tree, name, hex(key), part, bank)
            field_shape[num].add((off, mask))
            new = "SndParam_Part%02X_%s" % (part, PART_FIELDS[num])
        if new is None:
            rest[bank].append((key, name, off, mask, lo, hi))
            continue
        assert new not in taken, (tree, new)
        taken.add(new)
        rules[name] = (new, key)
    for num, shapes in field_shape.items():          # a part field must have one (byte, mask) in every part
        assert len(shapes) == 1, (tree, hex(num), shapes)
    return rules, rest


def main():
    if "--markdown-parts" in sys.argv:
        return markdown_parts_all()
    if "--markdown" in sys.argv:
        return markdown()
    write = "--write" in sys.argv
    v10_rules = None
    for tree in ("v10", "v9", "v7"):
        rules, rest = plan(tree)
        if v10_rules is None:
            v10_rules = rules
        else:
            # the same alias must get the same name, for the same key, as in v10
            for a, (n, k) in rules.items():
                assert v10_rules.get(a, (n, k)) == (n, k), (tree, a, n, hex(k), v10_rules.get(a))
        nrest = sum(len(v) for v in rest.values())
        print("%s: %d descriptors named, %d keep their alias" % (tree, len(rules), nrest))
        if tree == "v10":
            for bank in sorted(rest):
                v = rest[bank]
                print("   record 0x%02X: %d left: %s" % (bank, len(v), " ".join("%X" % x[0] for x in v[:16])
                                                         + (" ..." if len(v) > 16 else "")))
        if write:
            out = os.path.join(REPO, "scripts/renaming/rename_sndparam_desc_r2_%s.sed" % tree)
            with open(out, "w") as f:
                f.write("# %s: sound-parameter descriptors named from the firmware's own screens and Lsw functions\n"
                        "# (gen_sndparam_desc_names_r2.py; basis: analysis/disk-format-probes/"
                        "README-lsw-param-namespace-map.md section 8).\n" % tree)
                for a, (n, k) in sorted(rules.items(), key=lambda x: -len(x[0])):
                    f.write("s/\\b%s\\b/%s/g\n" % (a, n))
            print("   -> %s" % os.path.relpath(out, REPO))


if __name__ == "__main__":
    main()
