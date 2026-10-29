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
# then four bytes with no reader traced: `kind` takes 0-14, b13 and b14 are 0 and b15 is
# 0xFF in all 120 pads [INFERENCE: b15 an unused part number, as var_head's]. Two part
# set-ups (style_part) and the event stream follow.
.macro pad_head bars, beats, kind, b13, b14, b15
	.byte	\bars - 1, \beats - 1, \kind, \b13, \b14, \b15
.endm
.macro pad_events p
	.be24	\p_EventsEnd - \p_Events
.endm
# One of the eight 3-byte entries of a 'ZZZJ' record (SramRecordDefaultsZZZJ, table segment
# 1; SramRecordsLoadFactory copies the 220 records to battery SRAM 0x84030FF8). Bit 7 of a
# record's first byte is a flag that func_4843FCE6 sets or clears and func_4843FCA2 tests,
# for the record func_4843FACD picks from GetM3EmVal(0xC000). [INFERENCE] Each entry is a
# program change's data bytes {prog, bank_lsb, bank_msb}, as in style_part: bank_msb is 0x26
# in entries 0 and 1 of every record (the drum bank of the style format) and 0x20 elsewhere
# in 217 of 220; the role of the eight entries and of the 220 records (220 = the rhythm
# count) is not traced.
.macro zzzj_voice prog, bank_lsb, bank_msb
	.byte	\prog, \bank_lsb, \bank_msb
.endm
# Fields 15-23 of the part-field table 0x485B77D4 that a MEMORY ('TCMP') variation record
# keeps after a part's 15 style_part fields (a 0x18-byte part block). [INFERENCE] In the
# table's order: CC64, CC1, CC11, channel pressure, pitch bend (two bytes), CC16, CC17, CC13.
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
# it in bits 19:12 of the voice's select) with the TG side in bits 10/11 (0x400 / 0x800;
# TgVoiceSideSelect 0x4C02BECB) and bits 12-15 not traced; +2 the wave directory entry
# (TgElemNoteOnStd 0x4C030A98: & 0xFFF into bits 11:0); +4, +5 not traced (+5 is 0 in
# every zone); the 8-byte kind adds a signed fine tune (+6; TgPitchNoteResolve).
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
# A tone record's head (0x54 bytes; the part tone block's descriptor, 0x500CE404 + part *
# 0x130 +0; TgPartProgramApply 0x4C03893D stores it). After the 16-byte name:
#   class   +0x10: & 0xC0 picks the note-on path (TgNoteOn 0x4C036832): 0x00/0xC0 melodic,
#           0x40 table (TgPartToneIsTableClass), 0x80 kit; & 0xCF = 0x81..0x83 kit layers
#   b11     +0x11: no reader traced
#   mod_src +0x12: 2-bit mod source fields (TgPartToneModSetupMelodic 0x4C03A3CD)
#   type    +0x44: low nibble the tone TYPE / LFO group (TgPartEditLfoGroupLoad 0x4C00CF8B,
#           TgVoiceEgSegParamGet 0x4C03A20F)
#   b45     +0x45: the flag TgVoiceEgSegParamGet tests for types 0xA/0xB
# tone_head covers +0x10..+0x12 and tone_type +0x44..+0x45; the bytes between and after,
# whose readers are not traced, follow as .byte rows with their offsets.
.macro tone_head class, b11, mod_src
	.byte	\class, \b11, \mod_src
.endm
.macro tone_type type, b45
	.byte	\type, \b45
.endm
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
