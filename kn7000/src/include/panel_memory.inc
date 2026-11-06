# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# panel_memory.inc -- the KN7000 / KN6000 one-touch-setting panel memory: the compact record
# the library builds from four PANEL MEMORY records (0x750 bytes each on the KN7000, 0x700 on
# the KN6000) when a style is saved to CUSTOM.  Shared by the CUSTOM banks (src/customdata/)
# and, for the same record, the floppy describers.  Source: kn7000/notes/custom-data-ic21.md,
# section "One touch settings".
#
# The writer is KN7000 library func_4C02A0C4 (KN6000 func_4C04B9F8).  It copies fields out of
# panel-memory record i (0x84000834 + bank*0x3A90 + i*0x750 on the KN7000; 0x840007E2 +
# bank*0x3810 + i*0x700 on the KN6000) through tables of {source offset, destination offset,
# mask} triples: KN7000 program 0x4858E19C..0x4858E252, KN6000 0x4C19AB04.. (the same bytes).
# Every field is stored as source & mask; a parameter here is the stored byte.
#
# FIELD NAMES.  A PANEL MEMORY record is the live panel state's image: lib func_4C021F33 recalls
# memory n by memcpy(0x84000020, memory, 0x750) then func_4C01F98B; func_4C021EEE stores it.  The
# live parameters are reached by parameter id through the trie ResourceIdTrie (lib func_4C01BB1A;
# record = {id, type, kind, min, max, block = the record's tag, offset, mask, shift}), so each source
# byte here is named after the parameter that owns it -- the same names as the PMR_* macros below
# (their comments give the id and the routine behind each name).  m<id> = parameter id known, its
# meaning not traced; p<hex> etc. = no parameter record covers that byte.  Probes and evidence:
# kn7000/notes/kn67-field-names-probes/ (m3em_param_map.py, m3em_callers.py).

# One part's settings, 26 bytes (triple table 0x4858E19C).  Source: the part record at panel
# record +0x16 + part*0x4A (parts 0..2 = tags 0x10-0x12, RIGHT1 / RIGHT2 / LEFT) or +0x2E0 (KN7000)
# / +0x296 (KN6000) (part 3: tag 0x03, PART 4, on both: the block tables 0x4858D44C / 0x4C195520
# put block 3 at 0x84000300 / 0x840002B6 = record +0x2E0 / +0x296).  Masks (source offset, mask):
#   voice_prog +0x00 7f, voice_bank_lsb +0x01 7f, voice_bank_msb +0x02 7f: the part's sound as
#   {program, bank LSB, bank MSB} (parameter 0xC00000, program change); func_4C02B2FE classifies the
#   triple and the writer replaces it with the CUSTOM copy's reference when it names a user sound
#   (class 1) or user kit (class 2)
#   volume +0x03 ff (CC7, bit 7 = 0x200000), ctl_bits +0x04 df (bit 5, 0x204084, is not kept),
#   p06 +0x06 03 (no parameter record), dsp_depth +0x0b ff, multi_depth +0x0c ff, chorus_depth
#   +0x0d ff (each depth with its on/off in bit 7), reverb_depth +0x0e 7f, portamento +0x0f ff,
#   cc80 .. cc83 +0x18..+0x1b 7f, pan +0x1c 7f, coarse_tune +0x1d 7f, fine_tune +0x1e ff,
#   drawbar_type +0x22 0f, organ_nib24 +0x24, organ_nib25 +0x25, drawbar1_2 .. drawbar7_8 +0x26..+0x29
#   ff, drawbar9_perc +0x2a 3f.
.macro PM_PART voice_prog, voice_bank_lsb, voice_bank_msb, volume, ctl_bits, p06, dsp_depth, multi_depth, chorus_depth, reverb_depth, portamento, cc80, cc81, cc82, cc83, pan, coarse_tune, fine_tune, drawbar_type, organ_nib24, organ_nib25, drawbar1_2, drawbar3_4, drawbar5_6, drawbar7_8, drawbar9_perc
	.byte	\voice_prog, \voice_bank_lsb, \voice_bank_msb, \volume, \ctl_bits, \p06, \dsp_depth, \multi_depth, \chorus_depth, \reverb_depth, \portamento, \cc80, \cc81
	.byte	\cc82, \cc83, \pan, \coarse_tune, \fine_tune, \drawbar_type, \organ_nib24, \organ_nib25, \drawbar1_2, \drawbar3_4, \drawbar5_6, \drawbar7_8, \drawbar9_perc
.endm

# Eight bytes, one from each of the panel record's 6-byte entries at +0xF4 + i*6 (table
# 0x4858E1EA: entry +0, mask 0xFF): the entries are tags 0x13-0x1A, the accompaniment parts, and
# entry byte 0 is the part's volume (part +0x03: CC7, bit 7 = 0x200000; func_4C01F8F4 mirrors it).
.macro PM_ENTRIES acc1_volume, acc2_volume, acc3_volume, acc4_volume, acc5_volume, bass_volume, drums1_volume, drums2_volume
	.byte	\acc1_volume, \acc2_volume, \acc3_volume, \acc4_volume, \acc5_volume, \bass_volume, \drums1_volume, \drums2_volume
.endm

# +0x70..+0x76 (table 0x4858E1ED, source panel record +0x6B6 KN7000 / +0x66C KN6000 = tag 0x42):
#   slot   rhythm (parameter 0x00C000, 24-bit style id over source +0..+2): the CUSTOM style the
#          setting belongs to; the writer stores func_4843E452(slot) = slot | 0x200000 as three
#          bytes, low first, over the first three fields
#   tchord_on   source +4, mask 0x40: parameter 0x008080 ([INFERENCE] TECHNI-CHORD on/off)
#   variation   bits 4-5 of source +7, parameter 0x00C004 VARIATION 1-4 (STEP RECORD labeller
#          "VARI %d"; replaced by the writer's running 0x00 / 0x10 / 0x20 / 0x30, so setting i
#          selects variation i)
#   tempo_lo   source +8, tempo_hi source +9 mask 0x01: parameter 0x000004 TEMPO 40..300
.macro PM_STYLE slot, tchord_on, variation, tempo_lo, tempo_hi
	.byte	\slot, 0x00, 0x20, \tchord_on, (\variation) * 16, \tempo_lo, \tempo_hi
.endm
# The same seven bytes in a built-in Music Stylist setup's one-touch setting (KN6000 / KN6500 program,
# StyleRecordTable.panel): the style's own 24-bit rhythm id, low byte first, in place of the CUSTOM
# slot; tempo is the 9-bit TEMPO, stored low byte and bit 8 (source +8 / +9 mask 0x01).
.macro PM_RHYTHM rhythm, tchord_on, variation, tempo
	.byte	(\rhythm) & 0xff, ((\rhythm) >> 8) & 0xff, ((\rhythm) >> 16) & 0xff, \tchord_on, (\variation) * 16
	.byte	(\tempo) & 0xff, (\tempo) >> 8
.endm
# +0x77..+0x79 (table 0x4858E202, source +0x6C6 / +0x67C = tag 0x41): conductor mask 0x07, left_hold
# mask 0x01, r_octave (0x008038, AcRightOctProc).  (Named 2026-11-02, lane mn10300-names, from the
# KN6000 merge tables 0x4C19AB6A {00 00 07, 03 01 01, 04 02 ff}.)
#   conductor  parameter 0x008040, 0..5: the CONDUCTOR (part-select) state.  KN6000 func_4C02EDD9 plays
#              a note above the split on RIGHT2 (part 0x11) for 1 and 5 and on RIGHT1 (0x10) for 0, 2,
#              3, 4; func_4C02F302 gives the left zone a part for 3..5; the KN5000's same record (panel
#              tag 0x90, floppy/kn5000/include/kn5000_panel.inc) names its byte 0 SndParam_Conductor, 0..5
#   left_hold  bit 0 of the source byte, parameter 0x00C084 LEFT HOLD: LeftholdToggleFunc (KN6000
#              0x4C0FE257, KN7000 0x4856D61C) writes 0x00C084 with MainPutM3Em, ApcSelFunc sends it to
#              ApcLefthold; the mask drops bit 1, 0x00C083 ON BASS (OnbassToggleFunc)
.macro PM_SET77 conductor, left_hold, r_octave
	.byte	\conductor, \left_hold, \r_octave
.endm
# +0x7A..+0x87 (table 0x4858E20B, source +0x6D0 / +0x686 = tag 0x4C): eff_bits mask 0x88 (bit 3
# 0x008024, bit 7 0x008020), m008010, then the 14-bit effect ids 0x00A000, 0x00A100, 0x00A200 and
# the DSP group part keys 0x00B014, 0x00B024, 0x00B034 as {lo, hi} byte pairs, mask 0x7F.  The writer
# re-maps each pair through func_48413686 (kinds 0, 9, 1, 2, 3, 4) when it names user data, so it
# stores the CUSTOM copy's id.
.macro PM_FX eff_bits, m008010, effa0_lo, effa0_hi, effa1_lo, effa1_hi, effa2_lo, effa2_hi, dsp1_part_lo, dsp1_part_hi, dsp2_part_lo, dsp2_part_hi, dsp3_part_lo, dsp3_part_hi
	.byte	\eff_bits, \m008010, \effa0_lo, \effa0_hi, \effa1_lo, \effa1_hi, \effa2_lo, \effa2_hi, \dsp1_part_lo, \dsp1_part_hi, \dsp2_part_lo, \dsp2_part_hi, \dsp3_part_lo, \dsp3_part_hi
.endm
# +0x88..+0x8B (table 0x4858E235, source +0x700 / +0x6B6 = tag 0x44): tremolo mask 0x04 (parameter
# 0x008030, AcTremoloProc), tc_orchestrator (+3, 0x008082, TechniChordOrchestratorPart),
# techni_chord mask 0x0F (+4, 0x008081 TECHNI-CHORD type, AcTechniChordProc), apc_volume (+8: 0x008008
# bits 0-6, 0x008009 bit 7): the APC (accompaniment) VOLUME, 0..127.  941 func_48454E3A (KN6000
# func_4C114272) sets 0x008008 and the sequencer's 0x008006 (SEQ VOLUME) from the APC/SEQUENCER VOLUME
# slider, PanelCtrlValueGet of control 0xC2 (KN6000 0xC6): func_48454D21 answers 0 in DEMO and whenever no
# sequencer part plays (GetSeqPlyPart), and then 0x008008 follows the slider and 0x008006 is held at 0x7F;
# while the sequencer plays the two swap (kn7000/notes/presentation-control-probes/song-records.md: the
# firmware's parameter dump labels 0x8006 SEQ VOLUME and 0x8008 APC VOLUME).  The control is the slider: index 26 of
# PanelCtrlValueGet_Table (bank 3, input 2) is the byte PanelCtrlLatch32 latches from wire 0xD2, the
# CPL panel CPU's AD2 input, which the KN7000 service manual wires to VR1102 "APC/SEQUENCER"; on the
# KN6000 (index 30, AD6) the SX-KN6500 service manual's VR1 "APC/SEQUENCER VOLUME".  The KN5000's tag
# 0x70 has no byte +8.  (kn7000/notes/mn10300-data3/README.md, N-4b34dd8b)
.macro PM_SET88 tremolo, tc_orchestrator, techni_chord, apc_volume
	.byte	\tremolo, \tc_orchestrator, \techni_chord, \apc_volume
.endm
# +0x8C..+0x8D (table 0x4858E241, source +0x716 / +0x6C6 = tag 0x46): pad_volume (0x00E001 bits 0-6,
# 0x00E002 bit 7), pad_bank (0x00E005, AcPadBankProc); pad_bank is then passed through func_484417B9
# (KN6000 func_4C063396), which re-maps a user pad bank to the CUSTOM copy.  pad_volume (named
# 2026-11-02, lane mn10300-names): the parameter-change dispatcher (KN6000 func_4C0484C7, its case at
# 0x4C048AAC; KN7000 lib func_4C024DD8) sends 0x00E001 as controller 7 (volume) and 0x00E002 as code 0x90 to parts
# 0x1D and 0x1E, which ApcToSMFConvGrid (KN6000 0x4C0CB01B) names "PAD PART1" / "PAD PART2".
.macro PM_SET8C pad_volume, pad_bank
	.byte	\pad_volume, \pad_bank
.endm
# KN7000 only, +0x8F..+0x9A: three more bytes of each of the four parts (table 0x4858E24A):
# tremulant (part +0x23 mask 0x07, parameter 0x2000A2), tabs_1 (+0x38: 0x2000B0-B7), tabs_2
# (+0x39: 0x2000B8-BF).
.macro PM_PART_TAIL tremulant, tabs_1, tabs_2
	.byte	\tremulant, \tabs_1, \tabs_2
.endm
# A KN7000 setting converted from a KN6000 file.  When AstLoadHandler or LoadCst load a file with the
# KN6000 signature (func_4852B746 = 3), func_48485B52 (KN7000 program 941; func_48485E55 for all 20
# slots, func_48485E79 for one) rebuilds each slot in the KN7000 layout: per setting it copies the
# 0xA0-byte default func_48485B52_Block, then the KN6000 setting's 0x90 bytes over it.  So +0x00..+0x8D
# are the KN6000 setting's fields (same offsets), +0x8E..+0x8F its last two bytes, FF FF, and
# +0x90..+0x9F the default's: part 0's tabs_1 / tabs_2 (its tremulant byte +0x8F is the KN6000 FF),
# the tails of parts 1-3 and the five FF.
.macro PM_KN6000_END
	.byte	0xff, 0xff
.endm
.macro PM_CONVERT_TAIL
	.byte	0x17, 0x00
	PM_PART_TAIL 0x00, 0x17, 0x00
	PM_PART_TAIL 0x00, 0x06, 0x00
	PM_PART_TAIL 0x00, 0x17, 0x00
	.space	5, 0xff
.endm

# ---- BEGIN PMR (generated by floppy/tools/kd/gen_panel_macros.py; do not edit by hand) ----
# The full PANEL MEMORY record: the floppies' .PMT memories and .LSW panels hold it as is, and its
# byte offsets are the "source" offsets of the triple tables above: the 72-byte part records start at
# record +0x16 + part*0x4A (tag 0x10 at +0x14), the eight 4-byte entries at +0xF4 + i*6 (tags 0x13-0x1A).
# Order and tags: floppy/tools/kd/kn_panel.py.  It is the live panel state (recall: lib func_4C021F33 copies
# a memory to 0x84000020, then func_4C01F98B); the field names come from the parameter-id trie, see the
# generator's docstring and kn7000/notes/kn67-field-names-probes/.  m<id> = parameter id known, meaning not;
# p<hex> / x<hex> = no parameter record covers the byte.
.macro PMR_END
	.byte	0xff, 0xff
.endm
# 0x40, 18 bytes: the memory's 16-character name, then n10, n11.  The name is a quoted string argument
# (llvm-mc and kn7asm both strip its quotes, so `.ascii "\name"` serves both, as VOICE_HEAD does).
.macro PMR_NAME name, n10, n11
	.byte	0x40, 18
	.ascii	"\name"
	.byte	\n10, \n11
.endm
# A part record, 72 bytes: tags 0x00-0x0F (PART1-16), 0x10-0x12 (RIGHT1, RIGHT2, LEFT), 0x1B (CHORD), 0x1C and
# (KN7000) 0x1F.  Fields (offset, name: parameter id, evidence):
#   +0x00 voice_prog        0xC00000 program change; kind 6 reads the {prog, bank LSB, bank MSB} triple
#                           (func_4C01F1A5)
#   +0x01 voice_bank_lsb    the triple, byte 1
#   +0x02 voice_bank_msb    the triple, byte 2
#   +0x03 volume            0xB00007 CC7 volume, mask 0x7F; bit 7 = 0x200000
#   +0x04 ctl_bits          bits 0-2 0x204080 (0..7, sent as TG code 0x85, lib 0x4C02581A), bit 3 0xB00040 CC64
#                           sustain, bit 4 0x204081, bit 5 0x204084, bit 6 0xB0005E CC94, bit 7 0xB0007E CC126
#                           mono
#   +0x05 tg_bits           bit 0 0x204085, bit 2 0x200011, bit 3 0x204082 (TG code 0x93), bit 4 0x204086, bit
#                           5 0x204083 (TG code 0x84); KN6000 also bit 6 0x204087, bit 7 0x204088
#   +0x0B dsp_depth         0xB0005F CC95, mask 0x7F; bit 7 = 0x20005F, the part's DSP on/off (DSPSELTitleFunc)
#   +0x0C multi_depth       0xB0005C CC92; bit 7 = 0x20005C, MULTI effect on/off (MULSELTitleFunc)
#   +0x0D chorus_depth      0xB0005D CC93; bit 7 = 0x20005D, chorus on/off (CHOSELTitleFunc)
#   +0x0E reverb_depth      0xB0005B CC91
#   +0x0F portamento        bits 0-6 0xB00005 CC5 portamento time, bit 7 0xB00041 CC65 portamento switch
#   +0x10 resonance         0xB00047 CC71
#   +0x11 release_time      0xB00048 CC72
#   +0x12 attack_time       0xB00049 CC73
#   +0x13 cutoff            0xB0004A CC74
#   +0x14 decay_time        0xB0004B CC75
#   +0x15 vibrato_rate      0xB0004C CC76
#   +0x16 vibrato_depth     0xB0004D CC77
#   +0x17 vibrato_delay     0xB0004E CC78
#   +0x18 cc80              0xB00050 CC80, 0..120
#   +0x19 cc81              0xB00051 CC81, 40..88
#   +0x1A cc82              0xB00052 CC82, 0..120
#   +0x1B cc83              0xB00053 CC83, 40..88
#   +0x1C pan               0xB0000A CC10
#   +0x1D coarse_tune       0xB08002 RPN 2, 40..88
#   +0x1E fine_tune         0xB08001 RPN 1
#   +0x1F bend_range        0xB08000 RPN 0, 0..12
#   +0x20 mod_range         0xB08005 RPN 5, 0..0xC7F, read with +0x21 (kind 0x14, func_4C01578C)
#   +0x22 drawbar_type      bits 0-3 0x200080 (0..1)
#   +0x23 tremulant         0x2000A2, mask 0x07, KN7000 only (AcTabTremulantProc)
#   +0x24 organ_nib24       RIGHT1 only: nibbles 0x200088 / 0x200089 (0..15)
#   +0x25 organ_nib25       RIGHT1 only: nibbles 0x20008A / 0x20008B (0..15)
#   +0x26 drawbar1_2        nibbles 0x200090 / 0x200091 (0..8): the nine drawbars are 0x200090-0x200098
#   +0x27 drawbar3_4        nibbles 0x200092 / 0x200093
#   +0x28 drawbar5_6        nibbles 0x200094 / 0x200095
#   +0x29 drawbar7_8        nibbles 0x200096 / 0x200097
#   +0x2A drawbar9_perc     bits 0-3 0x200098 (drawbar 9), bit 4 0x200099, bit 5 0x20009A
#   +0x2C scale_c           0x2000C0, 28..228 (128 = 0): 0x2000C0-0x2000CB, [INFERENCE] SCALE TUNING by degree,
#                           C first (TgPartPitchWordCalc indexes its scale table by note % 12)
#   +0x2D scale_cs          0x2000C1, 28..228 (128 = 0)
#   +0x2E scale_d           0x2000C2, 28..228 (128 = 0)
#   +0x2F scale_ds          0x2000C3, 28..228 (128 = 0)
#   +0x30 scale_e           0x2000C4, 28..228 (128 = 0)
#   +0x31 scale_f           0x2000C5, 28..228 (128 = 0)
#   +0x32 scale_fs          0x2000C6, 28..228 (128 = 0)
#   +0x33 scale_g           0x2000C7, 28..228 (128 = 0)
#   +0x34 scale_gs          0x2000C8, 28..228 (128 = 0)
#   +0x35 scale_a           0x2000C9, 28..228 (128 = 0)
#   +0x36 scale_as          0x2000CA, 28..228 (128 = 0)
#   +0x37 scale_b           0x2000CB, 28..228 (128 = 0)
#   +0x38 tabs_1            bits 0-7 0x2000B0-0x2000B7 (KN7000 only)
#   +0x39 tabs_2            bits 0-7 0x2000B8-0x2000BF (KN7000 only)
#   +0x3A midi_octave_local bits 0-2 0x204004 MIDI OCTAVE (-3..+3 stored 0..6), bit 5 0x204000 LOCAL
#                           (MidiPartGrid, grid "PART|CHANNEL|OCTAVE|LOCAL")
#   +0x3B midi_channel      0x204001 MIDI CHANNEL, 0..15, 0xFF = OFF (MidiPartGrid)
#   +0x3C m204020_prog      0x204020: a second {prog, bank LSB, bank MSB} triple (kind 6) at +0x3C..+0x3E; bit
#                           7 = 0x204021
#   +0x3D m204020_lsb       the triple, byte 1
#   +0x3E m204020_msb       the triple, byte 2
#   +0x3F m204024           bits 0-6 0x204024, bit 7 0x204025
#   +0x40 m204028           bits 0-6 0x204028, bit 7 0x204029
#   +0x41 m20402c           bits 0-6 0x20402C, bit 7 0x20402D
#   +0x42 m204030           bits 0-6 0x204030, bit 7 0x204031
#   +0x43 m204022           bits 0-4 0x204022 / 0x204026 / 0x20402A / 0x20402E / 0x204032
.macro PMR_PART tag, voice_prog, voice_bank_lsb, voice_bank_msb, volume, ctl_bits, tg_bits, p06, p07, p08, p09, p0a, dsp_depth, multi_depth, chorus_depth, reverb_depth, portamento, resonance, release_time, attack_time, cutoff, decay_time, vibrato_rate, vibrato_depth, vibrato_delay, cc80, cc81, cc82, cc83, pan, coarse_tune, fine_tune, bend_range, mod_range, p21, drawbar_type, tremulant, organ_nib24, organ_nib25, drawbar1_2, drawbar3_4, drawbar5_6, drawbar7_8, drawbar9_perc, p2b, scale_c, scale_cs, scale_d, scale_ds, scale_e, scale_f, scale_fs, scale_g, scale_gs, scale_a, scale_as, scale_b, tabs_1, tabs_2, midi_octave_local, midi_channel, m204020_prog, m204020_lsb, m204020_msb, m204024, m204028, m20402c, m204030, m204022, p44, p45, p46, p47
	.byte	\tag, 72
	.byte	\voice_prog, \voice_bank_lsb, \voice_bank_msb, \volume, \ctl_bits, \tg_bits, \p06, \p07, \p08, \p09, \p0a, \dsp_depth, \multi_depth, \chorus_depth, \reverb_depth, \portamento, \resonance, \release_time
	.byte	\attack_time, \cutoff, \decay_time, \vibrato_rate, \vibrato_depth, \vibrato_delay, \cc80, \cc81, \cc82, \cc83, \pan, \coarse_tune, \fine_tune, \bend_range, \mod_range, \p21, \drawbar_type, \tremulant
	.byte	\organ_nib24, \organ_nib25, \drawbar1_2, \drawbar3_4, \drawbar5_6, \drawbar7_8, \drawbar9_perc, \p2b, \scale_c, \scale_cs, \scale_d, \scale_ds, \scale_e, \scale_f, \scale_fs, \scale_g, \scale_gs, \scale_a
	.byte	\scale_as, \scale_b, \tabs_1, \tabs_2, \midi_octave_local, \midi_channel, \m204020_prog, \m204020_lsb, \m204020_msb, \m204024, \m204028, \m20402c, \m204030, \m204022, \p44, \p45, \p46, \p47
.endm
# A 4-byte entry, tags 0x13-0x1A (ACCOMP1-5, BASS, DRUMS1, DRUMS2, whose part records live in work RAM):
# bytes +0x03, +0x05, +0x3A, +0x3B of the part (func_4C01F8F4 / func_4C01F98B).  PM_ENTRIES stores the volume.
.macro PMR_ENTRY tag, volume, tg_bits, midi_octave_local, midi_channel
	.byte	\tag, 4, \volume, \tg_bits, \midi_octave_local, \midi_channel
.endm
# tag 0x41 fields:
#   +0x00 conductor         bits 0-2 0x008040 CONDUCTOR, 0..5 (the KN5000 tag 0x90 SndParam_Conductor; KN6000
#                           func_4C02EDD9 / func_4C02F302 pick the RIGHT1 / RIGHT2 / left-zone parts from it)
#   +0x03 left_hold_on_bass bit 0 0x00C084 LEFT HOLD (LeftholdToggleFunc), bit 1 0x00C083 ON BASS
#                           (OnbassToggleFunc); ApcSelFunc
#   +0x04 r_octave          0x008038, 40..88 (AcRightOctProc; the PANEL MEMORY filter row "R1/R2 OCTAVE")
.macro PMR_41_8 conductor, x01, x02, left_hold_on_bass, r_octave, x05, x06, x07
	.byte	0x41, 8
	.byte	\conductor, \x01, \x02, \left_hold_on_bass, \r_octave, \x05, \x06, \x07
.endm
# tag 0x42 fields:
#   +0x00 rhythm_lo         0x00C000 the rhythm: kind 6, a 24-bit style id over +0..+2 (MainGetRhythmName,
#                           CustomStyleIndexFromParam; the one-touch writer stores slot | 0x200000 there)
#   +0x01 rhythm_mid        byte 1
#   +0x02 rhythm_hi         byte 2
#   +0x03 apc_type          bits 0-3 0x00C080 (0..3; MainCOMP_RtcControl, TtChordFinder), bit 4 0x00C082
#                           (ApcSelFunc)
#   +0x04 apc_type_alt      bits 0-3 0x00C081 (0..3), bit 6 0x008080 ([INFERENCE] TECHNI-CHORD on: TtSdtecd,
#                           TechniChordCompute)
#   +0x05 rhythm_sync       bit 1 0x00D000
#   +0x06 m00d001           bits 0-3 0x00D001 (0..3; TempoSync* setters)
#   +0x07 variation         bits 4-5 0x00C004 (0..3; AcTimeSigBoxProc); the one-touch writer stores setting i
#                           there
#   +0x08 tempo_lo          0x000004 TEMPO 40..300, kind 0xA over +0x08 (low) / +0x09 (bit 0 = bit 8);
#                           TempoSyncParamDispatch
#   +0x09 tempo_hi          tempo bit 8
.macro PMR_42_14 rhythm_lo, rhythm_mid, rhythm_hi, apc_type, apc_type_alt, rhythm_sync, m00d001, variation, tempo_lo, tempo_hi, x0a, x0b, x0c, x0d
	.byte	0x42, 14
	.byte	\rhythm_lo, \rhythm_mid, \rhythm_hi, \apc_type, \apc_type_alt, \rhythm_sync, \m00d001, \variation, \tempo_lo, \tempo_hi, \x0a, \x0b, \x0c, \x0d
.endm
# tag 0x43 fields:
#   +0x00 control_channel   0x00F101 the MIDI CONTROL channel, 0xFF = OFF (MidiPartGrid row CONTROL)
.macro PMR_43_2 control_channel, x01
	.byte	0x43, 2
	.byte	\control_channel, \x01
.endm
# tag 0x44 fields:
#   +0x00 split_mode        bits 0-1 0x008060 (0..3; AcSplitBoxProc), bit 2 0x008030 tremolo (AcTremoloProc)
#   +0x01 split_point       0x008061 SPLIT POINT, key 21..108 (AcSplitBoxProc)
#   +0x02 transpose         0x000003 TRANSPOSE, 52..76 = 64 +- 12 (AcTransposeBoxProc)
#   +0x03 tc_orchestrator   0x008082 (TechniChordOrchestratorPart)
#   +0x04 techni_chord      bits 0-3 0x008081 TECHNI-CHORD type 0..13 (AcTechniChordProc)
#   +0x05 m006000           0x006000, 1..16
#   +0x06 m006001           0x006001, 1..16
#   +0x07 m006004           bits 0-2 0x006004 / 0x006005 / 0x006006
#   +0x08 apc_volume        bits 0-6 0x008008 APC VOLUME (the APC/SEQUENCER VOLUME slider while no sequencer
#                           part plays: 941 func_48454E3A / func_48454D21), bit 7 0x008009
#   +0x0C apc_rev1          KN7000 only: 0x00E030 APC reverb DEPTH of row 1, bit 7 0x00E038 (ApcRevFunc, grid
#                           "PART | DEPTH" ACCOMP1..)
#   +0x0D apc_rev2          KN7000 only: 0x00E031 APC reverb DEPTH of row 2, bit 7 0x00E039 (ApcRevFunc, grid
#                           "PART | DEPTH" ACCOMP1..)
.macro PMR_44_14 split_mode, split_point, transpose, tc_orchestrator, techni_chord, m006000, m006001, m006004, apc_volume, x09, x0a, x0b, apc_rev1, apc_rev2
	.byte	0x44, 14
	.byte	\split_mode, \split_point, \transpose, \tc_orchestrator, \techni_chord, \m006000, \m006001, \m006004, \apc_volume, \x09, \x0a, \x0b, \apc_rev1, \apc_rev2
.endm
.macro PMR_44_20 split_mode, split_point, transpose, tc_orchestrator, techni_chord, m006000, m006001, m006004, apc_volume, x09, x0a, x0b, apc_rev1, apc_rev2, apc_rev3, apc_rev4, apc_rev5, apc_rev6, apc_rev7, apc_rev8
	.byte	0x44, 20
	.byte	\split_mode, \split_point, \transpose, \tc_orchestrator, \techni_chord, \m006000, \m006001, \m006004, \apc_volume, \x09, \x0a, \x0b, \apc_rev1, \apc_rev2, \apc_rev3, \apc_rev4, \apc_rev5, \apc_rev6
	.byte	\apc_rev7, \apc_rev8
.endm
# tag 0x45 fields:
#   +0x00 m005040           bit 0 0x005040, bit 1 0x005041
.macro PMR_45_2 m005040, x01
	.byte	0x45, 2
	.byte	\m005040, \x01
.endm
# tag 0x46 fields:
#   +0x00 pad_volume        bits 0-6 0x00E001, bit 7 0x00E002: sent as controller 7 / code 0x90 to parts 0x1D /
#                           0x1E, "PAD PART1" / "PAD PART2" (KN6000 func_4C0484C7, ApcToSMFConvGrid)
#   +0x01 pad_bank          0x00E005 the PAD BANK (AcPadBankProc, MainPAD_GetPadName)
.macro PMR_46_4 pad_volume, pad_bank, x02, x03
	.byte	0x46, 4
	.byte	\pad_volume, \pad_bank, \x02, \x03
.endm
# tag 0x47 fields:
#   +0x00 midi_bits0        MIDI message flags, bits 0x002021 (0-1), 0x002020, 0x002022, 0x002023, 0x002013,
#                           0x002011, 0x002014 (MidiInputGrid, MidiControlGrid)
#   +0x01 midi_bits1        bit 2 0x00208F, bit 3 0x002040
#   +0x02 midi_bits2        bit 0 0x002043, bit 2 0x002041, bits 3-4 0x002025
#   +0x03 midi_bits3        bit 0 0x002000, bit 2 0x002001, bit 6 0x002012, bit 7 0x002010 (MidiInputGrid)
#   +0x06 midi_bits6        bit 3 0x002042
#   +0x07 midi_bits7        bits 0x00208D, 0x00208C, 0x002090, 0x002092, 0x002080-0x002082, 0x002094
#   +0x08 midi_bits8        bits 0x002087, 0x00208B, 0x002084-0x002086, 0x00208A, 0x002093, 0x002083
#   +0x09 midi_bits9        bits 0x00208E, 0x002091, 0x002098, 0x002099
#   +0x0B m008090           bits 0-1 0x008090, 0..2 (AcMidiInputGridBoxProc)
#   +0x0C m008091           0x008091 (MidiInputGrid)
#   +0x0D m008092           0x008092, 1..127 (MidiInputGrid)
.macro PMR_47_14 midi_bits0, midi_bits1, midi_bits2, midi_bits3, x04, x05, midi_bits6, midi_bits7, midi_bits8, midi_bits9, x0a, m008090, m008091, m008092
	.byte	0x47, 14
	.byte	\midi_bits0, \midi_bits1, \midi_bits2, \midi_bits3, \x04, \x05, \midi_bits6, \midi_bits7, \midi_bits8, \midi_bits9, \x0a, \m008090, \m008091, \m008092
.endm
# tag 0x48 fields:
#   +0x02 expr_pedal_func   0x004000, 0..200: read last of seven by FSWAssGridCheck, grid row EXPRESS. PEDAL
#   +0x04 fsw1_func         0x004002 FOOT SWITCH 1 function (FSWAssGridCheck reads 0x004002..7 then 0x004000 in
#                           the grid's row order)
#   +0x05 fsw2_func         0x004003 FOOT SWITCH 2
#   +0x06 fc_sw1_func       0x004004 FOOT CONT. SW 1
#   +0x07 fc_sw2_func       0x004005
#   +0x08 fc_sw3_func       0x004006
#   +0x09 fc_sw4_func       0x004007
.macro PMR_48_30 x00, x01, expr_pedal_func, x03, fsw1_func, fsw2_func, fc_sw1_func, fc_sw2_func, fc_sw3_func, fc_sw4_func, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15, x16, x17, x18, x19, x1a, x1b, x1c, x1d
	.byte	0x48, 30
	.byte	\x00, \x01, \expr_pedal_func, \x03, \fsw1_func, \fsw2_func, \fc_sw1_func, \fc_sw2_func, \fc_sw3_func, \fc_sw4_func, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15, \x16, \x17, \x18, \x19, \x1a, \x1b, \x1c, \x1d
.endm
# tag 0x4A fields:
#   +0x00 mic_bits          bit 0 0x00802A, bit 6 0x008029, bit 7 0x008028 (MicSelFuncPage1/2, MicPresetStore)
#   +0x01 m00a401           0x00A401, 0..99 (MicPresetStore)
#   +0x02 m00802c           bits 0-6 0x00802C 0..27 (HarmPartMuteCheck, MicEffMuteToggleFunc), bit 7 0x00802D
#   +0x03 m00a402           0x00A402 (MicPresetStore)
.macro PMR_4A_4 mic_bits, m00a401, m00802c, m00a402
	.byte	0x4a, 4
	.byte	\mic_bits, \m00a401, \m00802c, \m00a402
.endm
# tag 0x4B fields:
#   +0x00 vocalist_bits     bits 0x007020-0x007027
#   +0x01 m007000           bits 0-4 0x007000, 0..17
#   +0x02 m007001           0x007001, 0..99 (VocalistGrid)
#   +0x03 m007002           bits 0-2 0x007002, bits 4-7 0x007003 (VocalistGrid)
#   +0x04 m007004           bits 6-7 0x007004 (VocalistGrid)
#   +0x05 m007005           0x007005, 0..121 (VocalistGrid)
#   +0x06 m007006           0x007006 whole byte = 0x007007 bits 0-6 + 0x007008 bit 7
#   +0x07 m007009           0x007009 whole byte = 0x00700A bits 0-6 + 0x00700B bit 7 (VocalistGrid)
.macro PMR_4B_8 vocalist_bits, m007000, m007001, m007002, m007004, m007005, m007006, m007009
	.byte	0x4b, 8
	.byte	\vocalist_bits, \m007000, \m007001, \m007002, \m007004, \m007005, \m007006, \m007009
.endm
# tag 0x4C fields:
#   +0x00 eff_bits          bit 2 0x008025, bit 3 0x008024, bit 5 0x008022 (EQFunc), bit 7 0x008020
#                           (REVSELTitleFunc)
#   +0x01 m008010           0x008010
#   +0x02 effA0_lo          0x00A000 (kind 0xF, two 7-bit bytes)
#   +0x03 effA0_hi          0x00A000 (kind 0xF, two 7-bit bytes)
#   +0x04 effA1_lo          0x00A100 (kind 0xF, two 7-bit bytes)
#   +0x05 effA1_hi          0x00A100 (kind 0xF, two 7-bit bytes)
#   +0x06 effA2_lo          0x00A200 (kind 0xF, two 7-bit bytes)
#   +0x07 effA2_hi          0x00A200 (kind 0xF, two 7-bit bytes)
#   +0x08 effA3_lo          0x00A300 (kind 0xF, two 7-bit bytes)
#   +0x09 effA3_hi          0x00A300 (kind 0xF, two 7-bit bytes)
#   +0x0A effA4_lo          0x00A400 (kind 0xF, two 7-bit bytes)
#   +0x0B effA4_hi          0x00A400 (kind 0xF, two 7-bit bytes)
#   +0x0C effA5_lo          0x00A500 (kind 0xF, two 7-bit bytes)
#   +0x0D effA5_hi          0x00A500 (kind 0xF, two 7-bit bytes)
#   +0x0E dsp1_part_lo      0x00B014 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
#   +0x0F dsp1_part_hi      0x00B014 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
#   +0x10 dsp2_part_lo      0x00B024 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
#   +0x11 dsp2_part_hi      0x00B024 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
#   +0x12 dsp3_part_lo      0x00B034 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
#   +0x13 dsp3_part_hi      0x00B034 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
#   +0x14 dsp4_part_lo      0x00B044 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
#   +0x15 dsp4_part_hi      0x00B044 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
#   +0x16 dsp5_part_lo      0x00B054 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
#   +0x17 dsp5_part_hi      0x00B054 the DSP group's part key (kind 0x10; SndUnitRecApply needs 0x13..0x1A)
.macro PMR_4C_30 eff_bits, m008010, effA0_lo, effA0_hi, effA1_lo, effA1_hi, effA2_lo, effA2_hi, effA3_lo, effA3_hi, effA4_lo, effA4_hi, effA5_lo, effA5_hi, dsp1_part_lo, dsp1_part_hi, dsp2_part_lo, dsp2_part_hi, dsp3_part_lo, dsp3_part_hi, dsp4_part_lo, dsp4_part_hi, dsp5_part_lo, dsp5_part_hi, x18, x19, x1a, x1b, x1c, x1d
	.byte	0x4c, 30
	.byte	\eff_bits, \m008010, \effA0_lo, \effA0_hi, \effA1_lo, \effA1_hi, \effA2_lo, \effA2_hi, \effA3_lo, \effA3_hi, \effA4_lo, \effA4_hi, \effA5_lo, \effA5_hi, \dsp1_part_lo, \dsp1_part_hi, \dsp2_part_lo, \dsp2_part_hi
	.byte	\dsp3_part_lo, \dsp3_part_hi, \dsp4_part_lo, \dsp4_part_hi, \dsp5_part_lo, \dsp5_part_hi, \x18, \x19, \x1a, \x1b, \x1c, \x1d
.endm
# tag 0x4D fields:
#   +0x00 eq_low_freq       0x00A310, 0..26
#   +0x01 eq_low_gain       0x00A311, 0..48 (AcGainBoxProc)
#   +0x02 eq_mid1_freq      0x00A312
#   +0x03 eq_mid1_q         0x00A313, 0..31
#   +0x04 eq_mid1_gain      0x00A314 (AcGainBoxProc)
#   +0x05 eq_mid2_freq      0x00A315
#   +0x06 eq_mid2_q         0x00A316
#   +0x07 eq_mid2_gain      0x00A317 (AcGainBoxProc)
#   +0x08 eq_mid3_freq      0x00A318
#   +0x09 eq_mid3_q         0x00A319
#   +0x0A eq_mid3_gain      0x00A31A (AcGainBoxProc)
#   +0x0B eq_high_freq      0x00A31B
#   +0x0C eq_high_gain      0x00A31C (AcGainBoxProc)
.macro PMR_4D_14 eq_low_freq, eq_low_gain, eq_mid1_freq, eq_mid1_q, eq_mid1_gain, eq_mid2_freq, eq_mid2_q, eq_mid2_gain, eq_mid3_freq, eq_mid3_q, eq_mid3_gain, eq_high_freq, eq_high_gain, x0d
	.byte	0x4d, 14
	.byte	\eq_low_freq, \eq_low_gain, \eq_mid1_freq, \eq_mid1_q, \eq_mid1_gain, \eq_mid2_freq, \eq_mid2_q, \eq_mid2_gain, \eq_mid3_freq, \eq_mid3_q, \eq_mid3_gain, \eq_high_freq, \eq_high_gain, \x0d
.endm
# tag 0x50 fields:
#   +0x00 master_tune       0x000000
#   +0x03 m000008           0x000008, 0..6 (AcTGModeSelProc, AcHpScreenProc)
.macro PMR_50_8 master_tune, x01, x02, m000008, x04, x05, x06, x07
	.byte	0x50, 8
	.byte	\master_tune, \x01, \x02, \m000008, \x04, \x05, \x06, \x07
.endm
# tag 0x51 fields:
#   +0x00 m000020           bits 0-3 0x000020, 0..9 (TchSensGridCheck)
#   +0x02 m000030           0x000030
#   +0x05 m000024           0x000024, 1..10 (TchSensGridCheck)
#   +0x06 m000028           bits 0-6 0x000028 1..127, bit 7 0x00002C (TchSensGridCheck)
.macro PMR_51_14 m000020, x01, m000030, x03, x04, m000024, m000028, x07, x08, x09, x0a, x0b, x0c, x0d
	.byte	0x51, 14
	.byte	\m000020, \x01, \m000030, \x03, \x04, \m000024, \m000028, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d
.endm
# tag 0x52 fields:
#   +0x00 m000082           bit 6 0x000082
#   +0x01 pmem_number       0x000080 the PANEL MEMORY number 0..104 (MainGetPmemName, PmemBankViewCatch)
#   +0x03 msa_on            bit 0 0x0000A0, bits 4-6 0x0000A1
#   +0x04 m00800c           bits 0-6 0x00800C, bit 7 0x00800D
#   +0x07 bits5000          bits 0x005000-0x005007
#   +0x08 bits5008          bits 0x005008-0x00500F
#   +0x09 bits5010          bits 0x005010-0x005015
#   +0x0A bits5020          bits 0x005020-0x005023
#   +0x0D m00e004           bit 0 0x00E004, bit 1 0x00D00A, bits 6-7 0x008033 (AcFadeBoxProc)
#   +0x0E m006020           0x006020 (MidiIoCatch)
#   +0x0F m00b000           bits 0-1 0x00B000, bit 2 0x00B001
#   +0x10 dsp1_unit         0x00B010 (DspUnitNumSel, SndCmdEmitUnitCc)
#   +0x11 dsp2_unit         0x00B020 (DspUnitNumSel, SndCmdEmitUnitCc)
#   +0x12 dsp3_unit         0x00B030 (DspUnitNumSel, SndCmdEmitUnitCc)
#   +0x13 dsp4_unit         0x00B040 (DspUnitNumSel, SndCmdEmitUnitCc)
#   +0x14 dsp5_unit         0x00B050 (DspUnitNumSel, SndCmdEmitUnitCc)
#   +0x1A m007040           KN7000 only: bits 0-1 0x007040, bit 2 0x007044, bit 3 0x007045 (SeparateOutProc)
#   +0x1B m007041           0x007041, 0..9
#   +0x1C mono1_part        0x007042 (SpPartMono, grid "OUTPUT | PART ASSIGN" MONO 1)
#   +0x1D mono2_part        0x007043 (SpPartMono, MONO 2)
.macro PMR_52_40 m000082, pmem_number, x02, msa_on, m00800c, x05, x06, bits5000, bits5008, bits5010, bits5020, x0b, x0c, m00e004, m006020, m00b000, dsp1_unit, dsp2_unit, dsp3_unit, dsp4_unit, dsp5_unit, x15, x16, x17, x18, x19, m007040, m007041, mono1_part, mono2_part, x1e, x1f, x20, x21, x22, x23, x24, x25, x26, x27
	.byte	0x52, 40
	.byte	\m000082, \pmem_number, \x02, \msa_on, \m00800c, \x05, \x06, \bits5000, \bits5008, \bits5010, \bits5020, \x0b, \x0c, \m00e004, \m006020, \m00b000, \dsp1_unit, \dsp2_unit
	.byte	\dsp3_unit, \dsp4_unit, \dsp5_unit, \x15, \x16, \x17, \x18, \x19, \m007040, \m007041, \mono1_part, \mono2_part, \x1e, \x1f, \x20, \x21, \x22, \x23
	.byte	\x24, \x25, \x26, \x27
.endm
.macro PMR_52_46 m000082, pmem_number, x02, msa_on, m00800c, x05, x06, bits5000, bits5008, bits5010, bits5020, x0b, x0c, m00e004, m006020, m00b000, dsp1_unit, dsp2_unit, dsp3_unit, dsp4_unit, dsp5_unit, x15, x16, x17, x18, x19, m007040, m007041, mono1_part, mono2_part, x1e, x1f, x20, x21, x22, x23, x24, x25, x26, x27, x28, x29, x2a, x2b, x2c, x2d
	.byte	0x52, 46
	.byte	\m000082, \pmem_number, \x02, \msa_on, \m00800c, \x05, \x06, \bits5000, \bits5008, \bits5010, \bits5020, \x0b, \x0c, \m00e004, \m006020, \m00b000, \dsp1_unit, \dsp2_unit
	.byte	\dsp3_unit, \dsp4_unit, \dsp5_unit, \x15, \x16, \x17, \x18, \x19, \m007040, \m007041, \mono1_part, \mono2_part, \x1e, \x1f, \x20, \x21, \x22, \x23
	.byte	\x24, \x25, \x26, \x27, \x28, \x29, \x2a, \x2b, \x2c, \x2d
.endm
.macro PMR_60_20 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13
	.byte	0x60, 20
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13
.endm
.macro PMR_60_22 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15
	.byte	0x60, 22
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15
.endm
.macro PMR_61_20 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13
	.byte	0x61, 20
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13
.endm
.macro PMR_61_22 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15
	.byte	0x61, 22
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15
.endm
.macro PMR_62_20 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13
	.byte	0x62, 20
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13
.endm
.macro PMR_62_22 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f, x10, x11, x12, x13, x14, x15
	.byte	0x62, 22
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f, \x10, \x11
	.byte	\x12, \x13, \x14, \x15
.endm
.macro PMR_68_16 x00, x01, x02, x03, x04, x05, x06, x07, x08, x09, x0a, x0b, x0c, x0d, x0e, x0f
	.byte	0x68, 16
	.byte	\x00, \x01, \x02, \x03, \x04, \x05, \x06, \x07, \x08, \x09, \x0a, \x0b, \x0c, \x0d, \x0e, \x0f
.endm
# ---- END PMR ----
