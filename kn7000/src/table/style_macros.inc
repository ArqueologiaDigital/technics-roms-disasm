# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# Record and event macros of the "Technics Rhythms" style format, for the table flash's
# styles (src/table/styles/*.s, BuiltinStyleSubTable) and its copy of IC18's index
# (TechnicsRhythmsTable). The format and the evidence for every field are in
# notes/ic18-rhythm-rom.md; the names follow src/ic18/rhythm.s (lane kn7000-ic18).
# Every multi-byte field is big-endian: the firmware reads this data with LoadU16BE /
# LoadU24BE although the MN10300 is little-endian.

# A part set-up (15 bytes): byte k is the value of field k of the firmware's part-field
# table 0x485B77D4 (CC -> field map 0x485B781C); func_4844187A copies the eight of a style
# into the part table 0x5003A37C.
#   mode CC97 (0x00 on the drum parts, 0x08 on the others) [INFERENCE: role]; volume CC7;
#   prog, bank_lsb, bank_msb: the program change's data bytes [INFERENCE: the bank names];
#   cc94 CC94; reverb CC91; chorus CC93; pan CC10; cc96, cc82, cc83, cc80, cc81, cc92.
.macro style_part mode, volume, prog, bank_lsb, bank_msb, cc94, reverb, chorus, pan, cc96, cc82, cc83, cc80, cc81, cc92
	.byte	\mode, \volume, \prog, \bank_lsb, \bank_msb, \cc94, \reverb, \chorus, \pan
	.byte	\cc96, \cc82, \cc83, \cc80, \cc81, \cc92
.endm
# The two sound-unit keys (record +0x0D; func_484420EF stores them to parameter keys
# 0xB044 and 0xB054): each pair a 14-bit value, 7 bits a byte, low byte first.
.macro style_units unit5_lo, unit5_hi, unit6_lo, unit6_hi
	.byte	\unit5_lo, \unit5_hi, \unit6_lo, \unit6_hi
.endm
# The 20 slot offsets (record +0x8A, u24BE from the record; StyleNameCommit -> 0x50034BCC[]).
.macro style_slots s
	.be24	\s_Var1 - \s, \s_Var1Fill1 - \s, \s_Var1Fill2 - \s
	.be24	\s_Var2 - \s, \s_Var2Fill1 - \s, \s_Var2Fill2 - \s
	.be24	\s_Var3 - \s, \s_Var3Fill1 - \s, \s_Var3Fill2 - \s
	.be24	\s_Var4 - \s, \s_Var4Fill1 - \s, \s_Var4Fill2 - \s
	.be24	\s_Intro1A - \s, \s_Intro1B - \s, \s_Intro2A - \s, \s_Intro2B - \s
	.be24	\s_Ending1A - \s, \s_Ending1B - \s, \s_Ending2A - \s, \s_Ending2B - \s
.endm
# A variation record (StyleRecordBindBuiltin 0x484336DB): bars - 1 (-> 0x50122DCE), beats a
# bar - 1 (-> 0x50122DCF), two part numbers for the sound units (0xFF = none; func_48442164,
# key 0xB048 [INFERENCE: role]), the set-up events' length and events, then the event
# stream's length and the stream.
.macro var_head v, bars, beats, unit_part_a, unit_part_b
	.byte	\bars - 1, \beats - 1, \unit_part_a, \unit_part_b
	.be16	\v_SetupEnd - \v_Setup
\v_Setup:
.endm
.macro var_events v
\v_SetupEnd:
	.be24	\v_EventsEnd - \v_Events
.endm
.macro var_end v
\v_EventsEnd:
.endm
# Events (RhyEventLenByStatus 0x484403D5): the low nibble of a status byte is the part.
.macro ev_cc part, ctl, value
	.byte	0xb0 + \part, \ctl, \value
.endm
.macro ev_pc part, prog, bank_lsb, bank_msb
	.byte	0xc0 + \part, \prog, \bank_lsb, \bank_msb
.endm
# A note: key, velocity, then three bytes. [INFERENCE] gate_lo/gate_hi a length and `rule`
# the chord-adaptation class (0 on every note of the two drum parts).
.macro ev_note part, key, velocity, gate_lo, gate_hi, rule
	.byte	0x90 + \part, \key, \velocity, \gate_lo, \gate_hi, \rule
.endm
.macro ev_press part, value
	.byte	0xd0 + \part, \value
.endm
.macro ev_bend part, lsb, msb
	.byte	0xe0 + \part, \lsb, \msb
.endm
# SysEx (RhySysexLen 0x484403CD): 0xF0, a length byte, then that many data bytes (.byte).
.macro ev_sysex len
	.byte	0xf0, \len
.endm
# A position byte: the tick in the beat (0-95, 96 a beat) of the events after it.
.macro ev_at tick
	.byte	\tick
.endm
.macro ev_beat
	.byte	0xf4
.endm
.macro ev_end
	.byte	0xf5
.endm
# Style-ID index entries (StyleBuiltinNameResolve 0x48433ABF).
.macro sidx_style no
	.be16	\no
.endm
.macro sidx_alias entry
	.be16	0x8000 + \entry
.endm
.macro sidx_table no
	.be16	0x4000 + \no
.endm
# A "Technics Pads" pad record after its 16-byte name (TechnicsPadsResource): bars - 1 and
# beats a bar - 1 as in a variation record (the stream holds bars x beats beat markers),
# then `kind`, the pad's flags (func_48434096 -> 0x50122E06; the TPAD twin +0x1A): bit 0 LOOP,
# bit 1 SYNCHRO (MainPAD_SetUserPadLoop / MainPAD_SetUserPadSync), bit 2 / bit 3 set on the
# "Maj" / "Min" pads [INFERENCE: a fixed-chord pad / minor]; then b13-b15, which no routine
# reads (0, 0, 0xFF in all 120 pads) [INFERENCE: b15 an unused part number, as var_head's].
# Two part set-ups (style_part) and the event stream follow.
.macro pad_head bars, beats, kind, b13, b14, b15
	.byte	\bars - 1, \beats - 1, \kind, \b13, \b14, \b15
.endm
.macro pad_events p
	.be24	\p_EventsEnd - \p_Events
.endm
# One of the eight 3-byte entries of a 'ZZZJ' record (SramRecordDefaultsZZZJ, table segment
# 1; SramRecordsLoadFactory copies the 220 records to battery SRAM 0x84030FF8): the SOUND
# ARRANGER's factory sound {prog, bank_lsb, bank_msb} for one accompaniment part of one preset
# rhythm. Record n = preset rhythm n (StyleIdToPresetOrdinal 0x4843FACD); entries in the order
# Drum, Perc, Bass, Acc1-Acc5 (0x485B73A0, 0x485B7396). Bit 7 of prog: in entry 0 the arranger
# is ON for the rhythm (SndArgOnSet 0x4843FCE6, SndArgIsOn 0x4843FCA2); in entries 2..7 the
# part's CC94 is 127 instead of 0 (SndArgTemplateApply 0x4843FFD0); in entry 1 always 0.
# notes/table-semantics-2026-10-29.md, notes/mn10300-names-probes/songtable_zzzj.py.
.macro zzzj_voice prog, bank_lsb, bank_msb
	.byte	\prog, \bank_lsb, \bank_msb
.endm
# The 9 bytes a MEMORY ('TCMP') variation record keeps after a part's 15 style_part fields
# (a 0x18-byte part block). No firmware routine reads or writes them: func_4844187A copies 15
# bytes of each block into the part template and func_48441EB4 writes 15; they are 0 in every
# TCMP container (notes/mn10300-names-probes/songtable_part_more.py). [INFERENCE] The size
# matches fields 15-23 of the part-field table 0x485B77D4, hence the names, in the table's
# order: CC64, CC1, CC11, channel pressure, pitch bend (two bytes), CC16, CC17, CC13.
.macro part_more cc64, cc1, cc11, pressure, bend_a, bend_b, cc16, cc17, cc13
	.byte	\cc64, \cc1, \cc11, \pressure, \bend_a, \bend_b, \cc16, \cc17, \cc13
.endm
# A pad reference of a 'TPAD' bank record (FactoryMemPadContainer). [INFERENCE] from the
# data: a COMPILE bank names a pad by the two bytes a pad record keeps at +0x10 (flags 0);
# a USER bank by (bank, slot) with flags 0x10.
.macro tpad_ref a, b, flags
	.byte	\a, \b, \flags
.endm
# ---- the 'JK' internal voice archive (src/table/voices/; tools/gen_table_voices.py) ----
# A parameter record (0x10 bytes; VoiceParamRecFetchBanked 0x48449925 indexes them):
#   ms, zones   offsets of its multisample header and zone list (TgVoiceRoutePtrCalc 0x4C02BE45)
#   flags       bit 7: the zones are 8 bytes and carry a fine tune (TgVoiceRoutePtrCalc steps 8
#               or 6; TgPitchNoteResolve 0x4C02FB79 adds zone +6); the low bits: no reader traced
#   key_lo, key_hi  the sample's mapped key window, notes (TgPitchZoneFold 0x4C02FB25 folds the
#               pitch by octaves into [key_lo << 8, (key_hi << 8) + 0xFF])
#   b11         no reader traced (66 in nearly all records)
#   center      the zone centre pitch, 16-bit (TgPitchZoneFold -> librec +0x0C)
#   b14, b15    no reader traced
.macro jk_param ms, zones, flags, key_lo, key_hi, b11, center, b14, b15
	.long	\ms, \zones
	.byte	\flags, \key_lo, \key_hi, \b11
	.word	\center
	.byte	\b14, \b15
.endm
# A zone: the halfword +0 is the wave page (low byte; TgVoiceRouteFieldSet 0x4C037C16 puts
# it in bits 19:12 of the voice's select) with the TG side in bits 10/11 (TgVoiceSideSelect
# 0x4C02BECB; 0x400 = the MAIN TG 0x98050000, IC203 / IC204, 0x800 = the SUB TG 0x98040000,
# IC207 / IC208: TgVoiceRegWrite 0x4C036F98 sends slots below 0x40 to 0x98050000; lane
# mn10300-rest) and bits 12-15 not traced (bits 8-9 are 0 in every zone); +2 the wave directory entry
# (TgElemNoteOnStd 0x4C030A98: & 0xFFF into bits 11:0); +4, +5 not traced (+5 is 0 in
# every zone); the 8-byte kind adds a signed fine tune (+6; TgPitchNoteResolve).
# A 'Tone' hash entry's payload (ToneKeyFind 0x4856FC51; lane mn10300-rest): the tone record's index
# (SoundToneIndexGet 0x48570051, `movhu (a0), d0`), the icon (SoundIconGet 0x48570027, +2), and the
# sound's switch {group, number} for each switch state (SoundSwNoGet 0x4856FF75): 0 {panel_group,
# panel_no_dsp}, 1 {panel_group, panel_no}, 2 {explorer_group, explorer_no_dsp}, 3 {explorer_group,
# explorer_no}; the even state is for a part with a DSP unit (PartHasDspUnit 0x484161BE), the panel
# states are MT_GetSoundSwNo's, the SOUND EXPLORER ones GetSoundDev's.  3 bytes no routine reads.
.macro jk_tone_key tone, icon, panel_group, explorer_group, panel_no_dsp, panel_no, explorer_no_dsp, explorer_no
	.word	\tone
	.byte	\icon, \panel_group, \explorer_group, \panel_no_dsp, \panel_no, \explorer_no_dsp, \explorer_no
	.space	3, 0x00
.endm
# A switch-key hash entry's payload (ShortKeyLookup 0x485703A5, key at +4 a u16 key group << 8 |
# number): the bank MSB, LSB and program the switch selects (SoundSwNoBankGet 0x485702CC copies
# +0 / +1 / +2), 3 bytes no routine reads.
.macro jk_sw_key msb, lsb, program
	.byte	\msb, \lsb, \program
	.space	3, 0x00
.endm
.macro jk_zone6 page, flags, entry, b4, b5
	.byte	\page, \flags
	.word	\entry
	.byte	\b4, \b5
.endm
.macro jk_zone8 page, flags, entry, b4, b5, tune
	.byte	\page, \flags
	.word	\entry
	.byte	\b4, \b5
	.word	\tune
.endm
# A tone record's head (0x54 bytes) and its 0x7A-byte units are SOUND_HEAD / SOUND_MOD of
# src/include/voice_record.inc (the same record as a SOUND EDIT record's first 0x23C bytes;
# TgPartAuxRecBuild 0x4C00C6E9), its voice records VOICE_HEAD_TAIL / VOICE_SUB and its elements
# VOICE_ELEM: the archive includes that file.
# A TABLE tone (class 0x40): the head is 0x27 bytes, then one 3-byte entry per note that
# TgNoteOnTableTone (0x4C03600D) reads at +0x27 + note x 3: it enables up to two synth
# layers (0x4C035EAA builds them).
.macro tone_head_table class, b11, b12, b13, b14, b15, b16, b17, b18, b19, b1a, b1b, b1c, b1d, b1e, b1f, b20, b21, b22, b23, b24, b25, b26
	.byte	\class, \b11, \b12, \b13, \b14, \b15, \b16, \b17, \b18, \b19, \b1a, \b1b, \b1c, \b1d, \b1e, \b1f
	.byte	\b20, \b21, \b22, \b23, \b24, \b25, \b26
.endm
.macro tone_note a, b, c
	.byte	\a, \b, \c
.endm
