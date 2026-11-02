#!/usr/bin/env python3
"""gen_panel_macros.py -- write the full PANEL MEMORY record macros (PMR_*) into the shared
kn7000/src/include/panel_memory.inc, between its BEGIN/END PMR markers.

QUESTION IT ANSWERS: "what macro types each record of a KN6000 / KN7000 panel-memory record?"  The record
(0x750 bytes on the KN7000, 0x700 on the KN6000; the source of the one-touch-setting triples above) is a
list of tag/length records ended by FF FF.  The tags and lengths are the ones the 27 softlist disks hold
(kn_panel.py; 1,808 .PMT memories, 80 .LSW panels).  Parameter names follow this file's convention: the
part record's p<hex> is the offset in the part's payload, as in PM_PART; other records are x<hex>.
Run: python3 -I floppy/tools/kd/gen_panel_macros.py   (idempotent)

FIELD NAMES (kn67-field-names lane, 2026-10-29).  The record is the LIVE panel state: library
func_4C021F33 (KN7000 lib 0x4C021F33) recalls a memory by memcpy(0x84000020, memory, 0x750) and then
func_4C01F98B, and func_4C021EEE stores one the other way.  Every live parameter is reached through the
parameter-id trie (ResourceIdTrie, walked by lib func_4C01BB1A for GetM3Em / PutM3Em): a record names a
block (= this record's tag; pointer table 0x4858D44C, func_4C021040), a byte offset in the block's
payload, a mask and a shift (func_4C015602 / func_4C0156BD / func_4C01F153; writes func_4C01F200).
kn7000/notes/kn67-field-names-probes/m3em_param_map.py dumps all of them (314 byte parameters on the
KN7000, 307 on the KN6000, whose trie is at 0x4C1935DC).  Ids 0xB0nnnn are MIDI control change nn and
0xC00000 program change (region1 func_48440533 builds ids as (status & 0xF0) << 16 | controller), 0xB080nn
RPN nn ([INFERENCE] from the ranges: 0 = bend range 0..12, 1 = fine, 2 = coarse 40..88).  A field is named
by what its parameter is where a caller or a GUI grid says so (m3em_callers.py lists every literal-id
call and its routine); a field whose parameter is known but not its meaning is named m<id>, so it can be
grepped in the probes' output; a byte no parameter record covers keeps its offset name (p<hex> / x<hex>).
"""
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
INC = os.path.join(HERE, '..', '..', '..', 'kn7000', 'src', 'include', 'panel_memory.inc')
# (tag, len) of the records that are not parts (0x00-0x12, 0x1B, 0x1C, 0x1F: 72 bytes) or entries (0x13-0x1A: 4)
OTHER = [(0x41, 8), (0x42, 14), (0x43, 2), (0x44, 14), (0x44, 20), (0x45, 2), (0x46, 4), (0x47, 14), (0x48, 30),
         (0x4A, 4), (0x4B, 8), (0x4C, 30), (0x4D, 14),
         (0x50, 8), (0x51, 14), (0x52, 40), (0x52, 46), (0x60, 20), (0x60, 22), (0x61, 20), (0x61, 22),
         (0x62, 20), (0x62, 22), (0x68, 16)]
# Part record (tags 0x00-0x0F PART1-16, 0x10 RIGHT1, 0x11 RIGHT2, 0x12 LEFT, 0x1B CHORD: the MIDI part grid's row
# table 0x48626C14, read by MidiPartGrid 0x484D0..; 0x13-0x1A ACCOMP1-5, BASS, DRUMS1, DRUMS2 live in work RAM
# 0x500D28C2 + i*0x4A and keep only the 4-byte entries below).  {offset: (name, evidence)}.
PART_FIELDS = {
    0x00: ('voice_prog', '0xC00000 program change; kind 6 reads the {prog, bank LSB, bank MSB} triple (func_4C01F1A5)'),
    0x01: ('voice_bank_lsb', 'the triple, byte 1'),
    0x02: ('voice_bank_msb', 'the triple, byte 2'),
    0x03: ('volume', '0xB00007 CC7 volume, mask 0x7F; bit 7 = 0x200000'),
    0x04: ('ctl_bits', 'bits 0-2 0x204080 (0..7, sent as TG code 0x85, lib 0x4C02581A), bit 3 0xB00040 CC64 sustain, bit 4 '
                       '0x204081, bit 5 0x204084, bit 6 0xB0005E CC94, bit 7 0xB0007E CC126 mono'),
    0x05: ('tg_bits', 'bit 0 0x204085, bit 2 0x200011, bit 3 0x204082 (TG code 0x93), bit 4 0x204086, bit 5 0x204083 (TG code '
                      '0x84); KN6000 also bit 6 0x204087, bit 7 0x204088'),
    0x0B: ('dsp_depth', '0xB0005F CC95, mask 0x7F; bit 7 = 0x20005F, the part\'s DSP on/off (DSPSELTitleFunc)'),
    0x0C: ('multi_depth', '0xB0005C CC92; bit 7 = 0x20005C, MULTI effect on/off (MULSELTitleFunc)'),
    0x0D: ('chorus_depth', '0xB0005D CC93; bit 7 = 0x20005D, chorus on/off (CHOSELTitleFunc)'),
    0x0E: ('reverb_depth', '0xB0005B CC91'),
    0x0F: ('portamento', 'bits 0-6 0xB00005 CC5 portamento time, bit 7 0xB00041 CC65 portamento switch'),
    0x10: ('resonance', '0xB00047 CC71'), 0x11: ('release_time', '0xB00048 CC72'),
    0x12: ('attack_time', '0xB00049 CC73'), 0x13: ('cutoff', '0xB0004A CC74'), 0x14: ('decay_time', '0xB0004B CC75'),
    0x15: ('vibrato_rate', '0xB0004C CC76'), 0x16: ('vibrato_depth', '0xB0004D CC77'),
    0x17: ('vibrato_delay', '0xB0004E CC78'),
    0x18: ('cc80', '0xB00050 CC80, 0..120'), 0x19: ('cc81', '0xB00051 CC81, 40..88'),
    0x1A: ('cc82', '0xB00052 CC82, 0..120'), 0x1B: ('cc83', '0xB00053 CC83, 40..88'),
    0x1C: ('pan', '0xB0000A CC10'),
    0x1D: ('coarse_tune', '0xB08002 RPN 2, 40..88'), 0x1E: ('fine_tune', '0xB08001 RPN 1'),
    0x1F: ('bend_range', '0xB08000 RPN 0, 0..12'),
    0x20: ('mod_range', '0xB08005 RPN 5, 0..0xC7F, read with +0x21 (kind 0x14, func_4C01578C)'),
    0x22: ('m200080', 'bits 0-3 0x200080 (0..1)'),
    0x23: ('tremulant', '0x2000A2, mask 0x07, KN7000 only (AcTabTremulantProc)'),
    0x24: ('organ_nib24', 'RIGHT1 only: nibbles 0x200088 / 0x200089 (0..15)'),
    0x25: ('organ_nib25', 'RIGHT1 only: nibbles 0x20008A / 0x20008B (0..15)'),
    0x26: ('drawbar1_2', 'nibbles 0x200090 / 0x200091 (0..8): the nine drawbars are 0x200090-0x200098'),
    0x27: ('drawbar3_4', 'nibbles 0x200092 / 0x200093'), 0x28: ('drawbar5_6', 'nibbles 0x200094 / 0x200095'),
    0x29: ('drawbar7_8', 'nibbles 0x200096 / 0x200097'),
    0x2A: ('drawbar9_perc', 'bits 0-3 0x200098 (drawbar 9), bit 4 0x200099, bit 5 0x20009A'),
    **{0x2C + k: ('scale_' + n, ('0x%06X, 28..228 (128 = 0)' % (0x2000C0 + k)) + (
                  ': 0x2000C0-0x2000CB, [INFERENCE] SCALE TUNING by degree, C first (TgPartPitchWordCalc indexes '
                  'its scale table by note % 12)' if k == 0 else ''))
       for k, n in enumerate(['c', 'cs', 'd', 'ds', 'e', 'f', 'fs', 'g', 'gs', 'a', 'as', 'b'])},
    0x38: ('m2000b0', 'bits 0-7 0x2000B0-0x2000B7 (KN7000 only)'),
    0x39: ('m2000b8', 'bits 0-7 0x2000B8-0x2000BF (KN7000 only)'),
    0x3A: ('midi_octave_local', 'bits 0-2 0x204004 MIDI OCTAVE (-3..+3 stored 0..6), bit 5 0x204000 LOCAL (MidiPartGrid, '
                                'grid "PART|CHANNEL|OCTAVE|LOCAL")'),
    0x3B: ('midi_channel', '0x204001 MIDI CHANNEL, 0..15, 0xFF = OFF (MidiPartGrid)'),
    0x3C: ('m204020_prog', '0x204020: a second {prog, bank LSB, bank MSB} triple (kind 6) at +0x3C..+0x3E; bit 7 = 0x204021'),
    0x3D: ('m204020_lsb', 'the triple, byte 1'), 0x3E: ('m204020_msb', 'the triple, byte 2'),
    0x3F: ('m204024', 'bits 0-6 0x204024, bit 7 0x204025'), 0x40: ('m204028', 'bits 0-6 0x204028, bit 7 0x204029'),
    0x41: ('m20402c', 'bits 0-6 0x20402C, bit 7 0x20402D'), 0x42: ('m204030', 'bits 0-6 0x204030, bit 7 0x204031'),
    0x43: ('m204022', 'bits 0-4 0x204022 / 0x204026 / 0x20402A / 0x20402E / 0x204032'),
}
PART_NAMED = {k: v[0] for k, v in PART_FIELDS.items()}
# The 4-byte entries, tags 0x13-0x1A: bytes +0x03, +0x05, +0x3A, +0x3B of the RAM part (func_4C01F8F4 mirrors a
# write to one of those four offsets into the entry; func_4C01F98B copies them back after a recall).
ENTRY_FIELDS = [('volume', PART_FIELDS[3][1]), ('tg_bits', 'part +0x05'), ('midi_octave_local', 'part +0x3A'),
                ('midi_channel', 'part +0x3B')]
# Other records: {tag: {offset: (name, evidence)}}.
OTHER_FIELDS = {
    0x41: {0x00: ('conductor', 'bits 0-2 0x008040 CONDUCTOR, 0..5 (the KN5000 tag 0x90 SndParam_Conductor; KN6000 '
                                 'func_4C02EDD9 / func_4C02F302 pick the RIGHT1 / RIGHT2 / left-zone parts from it)'),
           0x03: ('left_hold_on_bass', 'bit 0 0x00C084 LEFT HOLD (LeftholdToggleFunc), bit 1 0x00C083 ON BASS '
                                         '(OnbassToggleFunc); ApcSelFunc'),
           0x04: ('r_octave', '0x008038, 40..88 (AcRightOctProc; the PANEL MEMORY filter row "R1/R2 OCTAVE")')},
    0x42: {0x00: ('rhythm_lo', '0x00C000 the rhythm: kind 6, a 24-bit style id over +0..+2 (MainGetRhythmName, '
                               'CustomStyleIndexFromParam; the one-touch writer stores slot | 0x200000 there)'),
           0x01: ('rhythm_mid', 'byte 1'), 0x02: ('rhythm_hi', 'byte 2'),
           0x03: ('m00c080', 'bits 0-3 0x00C080 (0..3; MainCOMP_RtcControl, TtChordFinder), bit 4 0x00C082 (ApcSelFunc)'),
           0x04: ('m00c081', 'bits 0-3 0x00C081 (0..3), bit 6 0x008080 ([INFERENCE] TECHNI-CHORD on: TtSdtecd, '
                             'TechniChordCompute)'),
           0x05: ('m00d000', 'bit 1 0x00D000'),
           0x06: ('m00d001', 'bits 0-3 0x00D001 (0..3; TempoSync* setters)'),
           0x07: ('variation', 'bits 4-5 0x00C004 (0..3; AcTimeSigBoxProc); the one-touch writer stores setting i there'),
           0x08: ('tempo_lo', '0x000004 TEMPO 40..300, kind 0xA over +0x08 (low) / +0x09 (bit 0 = bit 8); '
                              'TempoSyncParamDispatch'),
           0x09: ('tempo_hi', 'tempo bit 8')},
    0x43: {0x00: ('control_channel', '0x00F101 the MIDI CONTROL channel, 0xFF = OFF (MidiPartGrid row CONTROL)')},
    0x44: {0x00: ('split_mode', 'bits 0-1 0x008060 (0..3; AcSplitBoxProc), bit 2 0x008030 tremolo (AcTremoloProc)'),
           0x01: ('split_point', '0x008061 SPLIT POINT, key 21..108 (AcSplitBoxProc)'),
           0x02: ('transpose', '0x000003 TRANSPOSE, 52..76 = 64 +- 12 (AcTransposeBoxProc)'),
           0x03: ('tc_orchestrator', '0x008082 (TechniChordOrchestratorPart)'),
           0x04: ('techni_chord', 'bits 0-3 0x008081 TECHNI-CHORD type 0..13 (AcTechniChordProc)'),
           0x05: ('m006000', '0x006000, 1..16'), 0x06: ('m006001', '0x006001, 1..16'),
           0x07: ('m006004', 'bits 0-2 0x006004 / 0x006005 / 0x006006'),
           0x08: ('m008008', 'bits 0-6 0x008008, bit 7 0x008009'),
           **{0x0C + k: ('apc_rev%d' % (k + 1), 'KN7000 only: 0x%06X APC reverb DEPTH of row %d, bit 7 0x%06X (ApcRevFunc, '
                         'grid "PART | DEPTH" ACCOMP1..)' % (0x00E030 + k, k + 1, 0x00E038 + k)) for k in range(8)}},
    0x45: {0x00: ('m005040', 'bit 0 0x005040, bit 1 0x005041')},
    0x46: {0x00: ('pad_volume', 'bits 0-6 0x00E001, bit 7 0x00E002: sent as controller 7 / code 0x90 to parts 0x1D / '
                                  '0x1E, "PAD PART1" / "PAD PART2" (KN6000 func_4C0484C7, ApcToSMFConvGrid)'),
           0x01: ('pad_bank', '0x00E005 the PAD BANK (AcPadBankProc, MainPAD_GetPadName)')},
    0x47: {0x00: ('midi_bits0', 'MIDI message flags, bits 0x002021 (0-1), 0x002020, 0x002022, 0x002023, 0x002013, 0x002011, '
                                '0x002014 (MidiInputGrid, MidiControlGrid)'),
           0x01: ('midi_bits1', 'bit 2 0x00208F, bit 3 0x002040'),
           0x02: ('midi_bits2', 'bit 0 0x002043, bit 2 0x002041, bits 3-4 0x002025'),
           0x03: ('midi_bits3', 'bit 0 0x002000, bit 2 0x002001, bit 6 0x002012, bit 7 0x002010 (MidiInputGrid)'),
           0x06: ('midi_bits6', 'bit 3 0x002042'),
           0x07: ('midi_bits7', 'bits 0x00208D, 0x00208C, 0x002090, 0x002092, 0x002080-0x002082, 0x002094'),
           0x08: ('midi_bits8', 'bits 0x002087, 0x00208B, 0x002084-0x002086, 0x00208A, 0x002093, 0x002083'),
           0x09: ('midi_bits9', 'bits 0x00208E, 0x002091, 0x002098, 0x002099'),
           0x0B: ('m008090', 'bits 0-1 0x008090, 0..2 (AcMidiInputGridBoxProc)'),
           0x0C: ('m008091', '0x008091 (MidiInputGrid)'), 0x0D: ('m008092', '0x008092, 1..127 (MidiInputGrid)')},
    0x48: {0x02: ('expr_pedal_func', '0x004000, 0..200: read last of seven by FSWAssGridCheck, grid row EXPRESS. PEDAL'),
           0x04: ('fsw1_func', '0x004002 FOOT SWITCH 1 function (FSWAssGridCheck reads 0x004002..7 then 0x004000 in '
                               'the grid\'s row order)'),
           0x05: ('fsw2_func', '0x004003 FOOT SWITCH 2'), 0x06: ('fc_sw1_func', '0x004004 FOOT CONT. SW 1'),
           0x07: ('fc_sw2_func', '0x004005'), 0x08: ('fc_sw3_func', '0x004006'), 0x09: ('fc_sw4_func', '0x004007')},
    0x4A: {0x00: ('mic_bits', 'bit 0 0x00802A, bit 6 0x008029, bit 7 0x008028 (MicSelFuncPage1/2, MicPresetStore)'),
           0x01: ('m00a401', '0x00A401, 0..99 (MicPresetStore)'),
           0x02: ('m00802c', 'bits 0-6 0x00802C 0..27 (HarmPartMuteCheck, MicEffMuteToggleFunc), bit 7 0x00802D'),
           0x03: ('m00a402', '0x00A402 (MicPresetStore)')},
    0x4B: {0x00: ('vocalist_bits', 'bits 0x007020-0x007027'), 0x01: ('m007000', 'bits 0-4 0x007000, 0..17'),
           0x02: ('m007001', '0x007001, 0..99 (VocalistGrid)'),
           0x03: ('m007002', 'bits 0-2 0x007002, bits 4-7 0x007003 (VocalistGrid)'),
           0x04: ('m007004', 'bits 6-7 0x007004 (VocalistGrid)'), 0x05: ('m007005', '0x007005, 0..121 (VocalistGrid)'),
           0x06: ('m007006', '0x007006 whole byte = 0x007007 bits 0-6 + 0x007008 bit 7'),
           0x07: ('m007009', '0x007009 whole byte = 0x00700A bits 0-6 + 0x00700B bit 7 (VocalistGrid)')},
    0x4C: {0x00: ('eff_bits', 'bit 2 0x008025, bit 3 0x008024, bit 5 0x008022 (EQFunc), bit 7 0x008020 (REVSELTitleFunc)'),
           0x01: ('m008010', '0x008010'),
           **{0x02 + 2 * k + j: ('eff%X_%s' % (0xA0 + k, 'lo' if j == 0 else 'hi'),
                                 '0x00%02X00 (kind 0xF, two 7-bit bytes)' % (0xA0 + k)) for k in range(6) for j in range(2)},
           **{0x0E + 2 * k + j: ('dsp%d_part_%s' % (k + 1, 'lo' if j == 0 else 'hi'),
                                 '0x00B0%d4 the DSP group\'s part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)' % (k + 1))
              for k in range(5) for j in range(2)}},
    0x4D: {0x00: ('eq_low_freq', '0x00A310, 0..26'), 0x01: ('eq_low_gain', '0x00A311, 0..48 (AcGainBoxProc)'),
           0x02: ('eq_mid1_freq', '0x00A312'), 0x03: ('eq_mid1_q', '0x00A313, 0..31'),
           0x04: ('eq_mid1_gain', '0x00A314 (AcGainBoxProc)'), 0x05: ('eq_mid2_freq', '0x00A315'),
           0x06: ('eq_mid2_q', '0x00A316'), 0x07: ('eq_mid2_gain', '0x00A317 (AcGainBoxProc)'),
           0x08: ('eq_mid3_freq', '0x00A318'), 0x09: ('eq_mid3_q', '0x00A319'),
           0x0A: ('eq_mid3_gain', '0x00A31A (AcGainBoxProc)'), 0x0B: ('eq_high_freq', '0x00A31B'),
           0x0C: ('eq_high_gain', '0x00A31C (AcGainBoxProc)')},
    0x50: {0x00: ('m000000', '0x000000'), 0x03: ('m000008', '0x000008, 0..6 (AcTGModeSelProc, AcHpScreenProc)')},
    0x51: {0x00: ('m000020', 'bits 0-3 0x000020, 0..9 (TchSensGridCheck)'), 0x02: ('m000030', '0x000030'),
           0x05: ('m000024', '0x000024, 1..10 (TchSensGridCheck)'),
           0x06: ('m000028', 'bits 0-6 0x000028 1..127, bit 7 0x00002C (TchSensGridCheck)')},
    0x52: {0x00: ('m000082', 'bit 6 0x000082'),
           0x01: ('pmem_number', '0x000080 the PANEL MEMORY number 0..104 (MainGetPmemName, PmemBankViewCatch)'),
           0x03: ('m0000a0', 'bit 0 0x0000A0, bits 4-6 0x0000A1'), 0x04: ('m00800c', 'bits 0-6 0x00800C, bit 7 0x00800D'),
           0x07: ('bits5000', 'bits 0x005000-0x005007'), 0x08: ('bits5008', 'bits 0x005008-0x00500F'),
           0x09: ('bits5010', 'bits 0x005010-0x005015'), 0x0A: ('bits5020', 'bits 0x005020-0x005023'),
           0x0D: ('m00e004', 'bit 0 0x00E004, bit 1 0x00D00A, bits 6-7 0x008033 (AcFadeBoxProc)'),
           0x0E: ('m006020', '0x006020 (MidiIoCatch)'), 0x0F: ('m00b000', 'bits 0-1 0x00B000, bit 2 0x00B001'),
           **{0x10 + k: ('dsp%d_unit' % (k + 1), '0x00B0%d0 (DspUnitNumSel, SndCmdEmitUnitCc)' % (k + 1)) for k in range(5)},
           0x1A: ('m007040', 'KN7000 only: bits 0-1 0x007040, bit 2 0x007044, bit 3 0x007045 (SeparateOutProc)'),
           0x1B: ('m007041', '0x007041, 0..9'), 0x1C: ('mono1_part', '0x007042 (SpPartMono, grid "OUTPUT | PART ASSIGN" MONO 1)'),
           0x1D: ('mono2_part', '0x007043 (SpPartMono, MONO 2)')},
}


def wrap(vals, w=18):
    return ['\t.byte\t' + ', '.join(vals[k:k + w]) for k in range(0, len(vals), w)]


def comments(fields):
    """'#   +0xNN name  evidence' lines, wrapped at 110 columns."""
    out = []
    for k in sorted(fields):
        name, ev = fields[k]
        head = '#   +0x%02X %-17s ' % (k, name)
        words, line = ev.split(), head
        for w in words:
            if len(line) + len(w) + 1 > 112 and line != head:
                out.append(line.rstrip())
                line = '#' + ' ' * (len(head) - 1)
            line += w + ' '
        out.append(line.rstrip())
    return out


def section():
    L = ['# ---- BEGIN PMR (generated by floppy/tools/kd/gen_panel_macros.py; do not edit by hand) ----',
         '# The full PANEL MEMORY record: the floppies\' .PMT memories and .LSW panels hold it as is, and its',
         '# byte offsets are the "source" offsets of the triple tables above: the 72-byte part records start at',
         '# record +0x16 + part*0x4A (tag 0x10 at +0x14), the eight 4-byte entries at +0xF4 + i*6 (tags 0x13-0x1A).',
         '# Order and tags: floppy/tools/kd/kn_panel.py.  It is the live panel state (recall: lib func_4C021F33 copies',
         '# a memory to 0x84000020, then func_4C01F98B); the field names come from the parameter-id trie, see the',
         '# generator\'s docstring and kn7000/notes/kn67-field-names-probes/.  m<id> = parameter id known, meaning not;',
         '# p<hex> / x<hex> = no parameter record covers the byte.',
         '.macro PMR_END', '\t.byte\t0xff, 0xff', '.endm',
         '# 0x40, 18 bytes: the memory\'s 16-character name, then n10, n11.  The name is a quoted string argument',
         '# (llvm-mc and kn7asm both strip its quotes, so `.ascii "\\name"` serves both, as VOICE_HEAD does).',
         '.macro PMR_NAME name, n10, n11', '\t.byte\t0x40, 18', '\t.ascii\t"\\name"', '\t.byte\t\\n10, \\n11', '.endm',
         '# The same record in three lines, PMR_NAME_HEAD, `.ascii "<name>"`, PMR_NAME_TAIL: what the program builds\'',
         '# data sources still write (kn7000/tools/gen_data_s.py; moving them is register row N-f67b155c\'s rest).',
         '.macro PMR_NAME_HEAD', '\t.byte\t0x40, 18', '.endm',
         '.macro PMR_NAME_TAIL n10, n11', '\t.byte\t\\n10, \\n11', '.endm']
    names = [PART_NAMED.get(k, 'p%02x' % k) for k in range(72)]
    L += ['# A part record, 72 bytes: tags 0x00-0x0F (PART1-16), 0x10-0x12 (RIGHT1, RIGHT2, LEFT), 0x1B (CHORD), 0x1C and',
          '# (KN7000) 0x1F.  Fields (offset, name: parameter id, evidence):'] + \
         comments(PART_FIELDS) + \
         ['.macro PMR_PART tag, ' + ', '.join(names), '\t.byte\t\\tag, 72'] + wrap(['\\' + n for n in names]) + ['.endm']
    en = [e[0] for e in ENTRY_FIELDS]
    L += ['# A 4-byte entry, tags 0x13-0x1A (ACCOMP1-5, BASS, DRUMS1, DRUMS2, whose part records live in work RAM):',
          '# bytes +0x03, +0x05, +0x3A, +0x3B of the part (func_4C01F8F4 / func_4C01F98B).  PM_ENTRIES stores the volume.',
          '.macro PMR_ENTRY tag, ' + ', '.join(en), '\t.byte\t\\tag, 4, ' + ', '.join('\\' + x for x in en), '.endm']
    for t, n in OTHER:
        f = {k: v for k, v in OTHER_FIELDS.get(t, {}).items() if k < n}
        ps = [f[k][0] if k in f else 'x%02x' % k for k in range(n)]
        if f and (t, n) == min(x for x in OTHER if x[0] == t):
            L += ['# tag 0x%02X fields:' % t] + comments(f)
        L += ['.macro PMR_%02X_%d %s' % (t, n, ', '.join(ps)), '\t.byte\t0x%02x, %d' % (t, n)] + \
             wrap(['\\' + x for x in ps]) + ['.endm']
    L.append('# ---- END PMR ----')
    return '\n'.join(L) + '\n'


def main():
    s = open(INC).read()
    s = re.sub(r'\n# ---- BEGIN PMR.*?# ---- END PMR ----\n', '\n', s, flags=re.S)
    open(INC, 'w').write(s.rstrip('\n') + '\n\n' + section())


if __name__ == '__main__':
    main()
