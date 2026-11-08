# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# voice_record.inc -- the KN7000 / KN6000 sound records: the 0x8E-byte voice record (VOICE_*),
# the 0x54-byte tone head and its 0x7A-byte units (SOUND_NAME_HEAD / SOUND_MOD) and the 0x23-byte
# element (VOICE_ELEM).  Shared by the CUSTOM banks (src/customdata/), the table flash's 'JK'
# internal voice archive (src/table/voices/, tools/gen_table_voices.py) and the KN6000 .TM files
# (floppy/tools/kd/kn_soundram.py).  Field names come from the tone generator's readers in the
# program-941 library (kn7000_manual.sym, the Tg* rows); evidence per field below.  A field no
# traced routine reads keeps its offset name.
#
# THE VOICE RECORD, 0x8E bytes (the unit of the voice-resource banks, the local-edit shadow
# 0x500C1183 + idx*0x8E, a CUSTOM record's custom-sound block):
#   +0x00  16-byte header: the 13-byte name, then three bytes (VOICE_HEAD):
#          voice_flags +0x0D  on a TABLE tone's note-on (a kit: TgNoteOnTableTone 0x4C03600D) bit 0
#                     stages layer 0 and bit 2 layer 1 (TgTableToneStage 0x4C035EA5 with d1 = 0 / 1);
#                     bit 5: the voice answers a key-off -- TgVoiceKillHandler 0x4C030E6E, the
#                     slot-service handler of the class-8 voices TgTableToneStage stages, programs
#                     the sub-record's release (TgTableKeyOffRelease, sub +0x0E) only then, so a
#                     voice without it is a one-shot.  VoiceSubRecFetch 0x4844978B also passes the
#                     byte with the layer number to func_484494E2 for the sub-record index (0xFF =
#                     none).  The archive's 1,618 records hold 0x01 / 0x05 / 0x21 / 0x25, the
#                     CUSTOM user kit's 128 0x01 / 0x05 / 0x21 (notes/custom-data-ic21-probes/
#                     kit_tone_census.py)
#          excl_group  +0x0E  TgExclGroupChoke 0x4C03099F: bit 7 = the voice is in an exclusive
#                     group, bits 0-6 its id (damp rate from 0x48586EA4); a new note chokes the
#                     part's voices of the same group (open / closed hi-hat)
#          ctrl_sense  +0x0F  TgPartCtrlSenseElem 0x4C030896: the voice's signed amount that the
#                     part's control mode (partrec +0x62 bits 11-12) scales by (0x80 + offset) /
#                     0x100 for TgVoiceFadeParamsPlan
#   +0x10  two 0x1C-byte sub-records (VoiceSubRecFetch: record +0x10 + n*0x1C)
#   +0x48  two 0x23-byte element records (TgPartLocalEditElemRecPtr 0x4C00C2F9: +0x48 +
#          elem*0x23; 0x10 + 2*0x1C + 2*0x23 = 0x8E)
# Readers observed in emulation (lane kn7000-ic21, 2026-11-07; notes/kn7000-ic21/README.md): every CPU
# read of the CUSTOM user kit's bytes while it plays, by routine (notes/kn7000-ic21-probes/kit_readers.lua,
# reader_fields.py); each field below names the routine and what it does with the byte.

.macro VOICE_HEAD name, voice_flags, excl_group, ctrl_sense
	.ascii	"\name"
	.byte	\voice_flags, \excl_group, \ctrl_sense
.endm
# A sub-record, 0x1C bytes: one layer of a TABLE (kit) voice.  TgTableToneStage stages it as the voice's
# "desc2" (librec +0x3C), and the class-8 programmers read it there:
#   pan           +0x00  TgLevelResolve 0x4C02FBDE: + the part's pan (partrec +0x0A - 0x40, reset to
#                        0x40 by the part init 0x4C0095D6) + the pan modulation, clamped 0..0x7F, into
#                        shadow +0x24 bits 0-6.  The archive's drum voices hold the drum-kit pan
#                        positions: bass drums 64, snares 76, closed hi-hats 88, rides 40, crashes 96
#                        or 48
#   elem_prog, elem_bank_lsb, elem_bank_msb  +0x01..+0x03  the element, which TgTableToneStage passes to
#                        TgPartElemProgramApplyIdxSel as {program, bank LSB, bank MSB}
#   coarse_tune   +0x04  TgPitchZoneFold 0x4C02FB25: signed semitones (<< 8 on the zone pitch, 0xC00 an
#   fine_tune     +0x05  octave), and signed fine steps of 2 pitch units (1/128 semitone)
#   level         +0x06  TgVoiceLevelTermCalc 0x4C02FD94: the voice's level term = level base + value -
#                        100 (0 = silent: -0x200), then the part's per-note offset, into
#                        TgLevelTermFinalize
#   level_key_slope +0x07, level_key_curve +0x08  func_4C02FCBA (the table twin of TgElemLevelBaseCalc,
#                        which reads the unit's +0x1A / +0x1B): +0x08 = 0x70 takes the fixed table
#                        0x486D2805, else its high nibble picks a key curve (0x486D1454 + n * 0x100)
#                        scaled by the signed slope +0x07; the level base lands in librec +0x12
#   aeg_attack_rate +0x09, aeg_attack_key +0x0F  TgTableAmpAttackRateCalc 0x4C02FDFA: the amp EG attack
#                        rate through the attack curve 0x486D25E4 (as TgAmpEgAttackRateCalc), + the
#                        signed key scaling +0x0F * key table 0x486D13D4 >> 4, clamped 0..0xFF
#   aeg_rate1, aeg_level1, aeg_rate2, aeg_level2  +0x0A..+0x0D  TgElemNoteOnStd 0x4C030A98: two decay
#                        segments, rates through the rate curve 0x486D2649 and levels through the level
#                        curve 0x486D26AE (the curve TgElemNoteOnFresh puts a unit's amp EG levels
#                        through), packed into shadow +0x04 / +0x08
#   aeg_release_rate +0x0E  TgTableKeyOffRelease 0x4C02FE59, through the rate curve 0x486D2649 (only for
#                        a voice with voice_flags bit 5; seen in MAME on the table flash's 'JK' archive kits, not
#                        in the user-kit run: kn7000/notes/kn7000-ic21/README.md section 1)
#   filter_flags  +0x10  bits 0-1 the filter mode (func_4C02FFD4 / TgVoiceFilterProgram 0x4C030606: 0 =
#                        off -- shadow +0x4C bit 17 set, +0x24 bits 8-14 = 0x7F; 1..3 the three set-ups);
#                        bits 5-7 the velocity curve of filter_level (TgVeloSenseApply 0x4C02FE77:
#                        table 0x486D2264 + n * 0x80)
#   filter_velo_sense +0x11  TgVeloSenseApply: signed depth of that curve (curve[vel] * depth >> 5)
#   cutoff        +0x12  TgVoiceFilterProgram: the base of TgPartCutoffResolve, whose 0..0x70 cutoff goes
#                        to shadow +0x26 bits 8-14
#   filter_level  +0x13  TgTableFilterLevelCalc 0x4C02FEC7: base + the part term 0x4C0146D3 + the layer's
#                        signed filter_ofs, through TgVeloSenseApply, into librec +0x60, which
#                        TgVoiceFilterProgram sends through TgVoiceZoneVeloResolve to
#                        TgVoiceSendWordALevelSet (shadow +0x4C)
#   cutoff_key_follow +0x14  TgVoiceFilterProgram: TgPartCutoffResolve's key-follow depth
#   filter_q      +0x15  func_4C02FFD4: + 0x18, clamped 0..0x7F, into librec +0x62, which
#                        TgVoiceFilterProgram sends to TgVoiceSendWordBLevelSet (shadow +0x50).
#                        [INFERENCE] the resonance: the second value of the filter set-up
#   filter_shape  +0x16  func_4C02FFD4 / TgVoiceFilterProgram: bits 6-7 pick one of four paths, bit 5
#                        the table (0x486D2794 / 0x486D2746) and bits 0-4 its 3-byte entry: shadow +0x50
#                        bits 18-19, shadow +0x24 bits 8-14, and a level correction that func_4C02FCBA
#                        adds to the level base
#   send_a, send_b +0x18 / +0x19  TgElemNoteOnStd: the effect sends (curves 0x486D1F54 / 0x486D2154;
#                        skipped when both are 0), as a unit's send_a / send_b_glide
#   s17, s1a, s1b  no reader seen (0 in 1,605 / 1,617 / 1,617 of the archive's 1,617 sub-records)
.macro VOICE_SUB pan, elem_prog, elem_bank_lsb, elem_bank_msb, coarse_tune, fine_tune, level, level_key_slope, level_key_curve, aeg_attack_rate, aeg_rate1, aeg_level1, aeg_rate2, aeg_level2, aeg_release_rate, aeg_attack_key, filter_flags, filter_velo_sense, cutoff, filter_level, cutoff_key_follow, filter_q, filter_shape, s17, send_a, send_b, s1a, s1b
	.byte	\pan, \elem_prog, \elem_bank_lsb, \elem_bank_msb, \coarse_tune, \fine_tune, \level, \level_key_slope, \level_key_curve, \aeg_attack_rate, \aeg_rate1, \aeg_level1, \aeg_rate2, \aeg_level2
	.byte	\aeg_release_rate, \aeg_attack_key, \filter_flags, \filter_velo_sense, \cutoff, \filter_level, \cutoff_key_follow, \filter_q, \filter_shape, \s17, \send_a, \send_b, \s1a, \s1b
.endm
# An element, 0x23 bytes.  +0x00..+0x02: velocity split points -- the staging (0x4C035EAA..,
# 0x4C035F2B) compares the note's velocity with them and picks layer 0..3; +0x05 + layer*5: the
# layer, whose first three bytes go to VoiceParamRecFetchBanked (0x48449925: param = +0 & 0x7F, then
# +1, +2) and VoiceParamBankClassify to fetch the 0x10-byte parameter record (the zones; jk_param);
# TgVoiceZoneVeloResolve 0x4C02C153 reads them again.  The layer's +3 is its signed level offset
# (l<k>_level: func_4C02FCBA adds it to the level base) and +4 its signed filter offset (l<k>_filter_ofs:
# TgTableFilterLevelCalc adds it to the sub-record's filter_level).  The element's +3, +4: no reader seen.
# [INFERENCE] l<k>_bank / l<k>_class from the callee names.  TgPartElemMapScratchBuild 0x4C03866F builds
# one with six layers.
.macro VOICE_ELEM vel_split0, vel_split1, vel_split2, e03, e04, l0_param, l0_bank, l0_class, l0_level, l0_filter_ofs, l1_param, l1_bank, l1_class, l1_level, l1_filter_ofs, l2_param, l2_bank, l2_class, l2_level, l2_filter_ofs, l3_param, l3_bank, l3_class, l3_level, l3_filter_ofs, l4_param, l4_bank, l4_class, l4_level, l4_filter_ofs, l5_param, l5_bank, l5_class, l5_level, l5_filter_ofs
	.byte	\vel_split0, \vel_split1, \vel_split2, \e03, \e04, \l0_param, \l0_bank, \l0_class, \l0_level, \l0_filter_ofs, \l1_param, \l1_bank, \l1_class, \l1_level, \l1_filter_ofs, \l2_param, \l2_bank, \l2_class
	.byte	\l2_level, \l2_filter_ofs, \l3_param, \l3_bank, \l3_class, \l3_level, \l3_filter_ofs, \l4_param, \l4_bank, \l4_class, \l4_level, \l4_filter_ofs, \l5_param, \l5_bank, \l5_class, \l5_level, \l5_filter_ofs
.endm

# ---- SOUND RECORDS (floppy-others lane, 2026-10-29; named by kn67-field-names) ----
# THE TONE RECORD (a JK archive tone, the part tone block's descriptor 0x500CE404 + part*0x130 +0):
# the 16-byte name, the 0x54-byte head, then n 0x7A-byte units (VoiceModRecFetch 0x4844982A).
# THE SOUND EDIT RECORD, 0x2C8 bytes: the KN6000 .TM files hold 40 (floppy/tools/kd/kn_soundram.py), a
# CUSTOM record its count of them (CustomSoundEditRecFetch 0x484845E1), RAM 0x500C0784 + (part-0x10)*0x2C8 one
# per aux part, the JK archive 40 (descriptor +0x3C).  TgPartAuxRecBuild 0x4C00C6E9 builds it as 0x23C bytes of
# the tone record (head + four units) over which it copies the part's own four units, so it is a tone record
# plus four elements:
#   +0x00  0x54-byte head, the 16-character name first (SOUND_NAME_HEAD)
#   +0x54  four 0x7A-byte units, SOUND_MOD (TgPartAuxModRecPtr 0x4C00C25B)
#   +0x23C four 0x23-byte elements, VOICE_ELEM (TgPartAuxElemRecPtr 0x4C00C28D; 0x54 + 4*0x7A + 4*0x23 = 0x2C8)
# The 16-character name is a quoted string argument: llvm-mc and kn7asm both strip its quotes (since
# 2026-10-31), so `.ascii "\name"` serves both.  SOUND_NAME_HEAD is the head with its name; the table flash's
# archive (tools/gen_table_voices.py), the KN6000 .TM files (floppy/tools/kd/kn_soundram.py) and the program
# builds' data (tools/gen_data_s.py tones()) write it, and VOICE_HEAD.  (The nameless SOUND_HEAD and
# VOICE_HEAD_TAIL, written after an `.ascii "<name>"`, were removed on 2026-11-06 with their last caller,
# register row N-f67b155c.)
# The head after the name, +0x10..+0x53:
#   tone_class +0x10  & 0xC0 picks the note-on path (TgNoteOn 0x4C036832): 0x00 / 0xC0 melodic, 0x40 TABLE
#                     (then the head is 0x27 bytes and a 3-byte entry per note follows: tone_head_table,
#                     src/table/style_macros.inc), 0x80 kit; & 0xCF = 0x81..0x83 kit layers
#   mod_src    +0x12  2-bit modulation-source fields (TgPartToneModSetupMelodic 0x4C03A3CD)
#   tone_type  +0x44  low nibble the tone TYPE / LFO group (TgPartEditLfoGroupLoad 0x4C00CF8B,
#                     TgVoiceEgSegParamGet 0x4C03A20F)
#   eg_flag    +0x45  the flag TgVoiceEgSegParamGet tests for types 0xA / 0xB; SOUND EDIT reads and writes
#                     it with TgPartAuxHdr45Get/Set 0x4C00C318 / 0x4C00C475
#   h46, h47          SOUND EDIT fields (TgPartAuxHdr46/47Get/Set); meaning not traced
.macro SOUND_NAME_HEAD name, tone_class, h11, mod_src, h13, h14, h15, h16, h17, h18, h19, h1a, h1b, h1c, h1d, h1e, h1f, h20, h21, h22, h23, h24, h25, h26, h27, h28, h29, h2a, h2b, h2c, h2d, h2e, h2f, h30, h31, h32, h33, h34, h35, h36, h37, h38, h39, h3a, h3b, h3c, h3d, h3e, h3f, h40, h41, h42, h43, tone_type, eg_flag, h46, h47, h48, h49, h4a, h4b, h4c, h4d, h4e, h4f, h50, h51, h52, h53
	.ascii	"\name"
	.byte	\tone_class, \h11, \mod_src, \h13, \h14, \h15, \h16, \h17, \h18, \h19, \h1a, \h1b, \h1c, \h1d, \h1e, \h1f, \h20, \h21
	.byte	\h22, \h23, \h24, \h25, \h26, \h27, \h28, \h29, \h2a, \h2b, \h2c, \h2d, \h2e, \h2f, \h30, \h31, \h32, \h33
	.byte	\h34, \h35, \h36, \h37, \h38, \h39, \h3a, \h3b, \h3c, \h3d, \h3e, \h3f, \h40, \h41, \h42, \h43, \tone_type, \eg_flag
	.byte	\h46, \h47, \h48, \h49, \h4a, \h4b, \h4c, \h4d, \h4e, \h4f, \h50, \h51, \h52, \h53
.endm
# A unit, 0x7A bytes: one element's tone parameters.  The note-on staging TgElemStageFresh (lib 0x4C034927)
# stores *(tone block +0x60 + unit*0x34) -- the same unit pointer TgPartAuxRecBuild copies -- as the voice's
# "desc2" (librec +0x3C), so the Tg* routines' desc2 offsets are offsets in this record (this answers the
# open question of table-semantics-2026-10-29.md: desc2 is not the 0x1C sub-record on this path; the table-tone
# staging does store a sub-record there).  Readers (kn7000_manual.sym):
#   +0x04..+0x06       SOUND EDIT fields (TgPartAuxMod04/05/06Get/Set); meaning not traced
#   level_ofs +0x09    TgZoneLevelScaleCalc 0x4C00FD68 (through curve 0x486D2713)
#   velo_sense +0x0A   TgZoneVeloSenseCalc 0x4C00FE03
#   +0x0B..+0x12       the pitch EG: attack rate +0x0B (TgPitchEgAttackCalc 0x4C031C4B), decay rates +0x0D /
#                      +0x0F (TgPitchEgDecayCalc), release rate +0x11 and scale +0x12 (TgKeyOffPitchRelease);
#                      +0x0E / +0x10 are also read by TgZoneSendLevelsCalc 0x4C00FE4D as curve indexes; +0x0C:
#                      no reader traced ([INFERENCE] the attack level)
#   level_key_slope +0x14  TgZoneLevelScaleCalc's key-scale slope
#   peg_key_scale0..2 +0x15..+0x17  the pitch EG's key scaling (TgPitchEgAttackCalc / DecayCalc)
#   send_a, send_b_glide +0x18 / +0x19  effect sends (TgElemNoteOnStd 0x4C030A98, curves 0x486D1F54 /
#                      0x486D2154); +0x19 bit 7 = glide (TgElemLevelBaseCalc 0x4C03132B); SOUND EDIT
#                      TgPartAuxMod19Get/Set keep the low 7 bits
#   key_follow_slope, key_follow_mode +0x1A / +0x1B  level key follow; mode 0x70 = the fixed table
#                      0x486D2805 (TgElemLevelBaseCalc)
#   velo_fade0..3 +0x20..+0x23, key_fade0..3 +0x24..+0x27  the VELOCITY FADE and KEY FADE zones
#                      (TgElemLevelBaseCalc)
#   aeg_attack_rate +0x28, aeg_decay1_rate +0x2A, aeg_decay2_rate +0x2C, aeg_release_rate +0x2E  the amp EG
#                      (TgAmpEgAttackRateCalc 0x4C031627, TgAmpEgDecayRatePairCalc 0x4C031787,
#                      TgKeyOffAmpRelease 0x4C031944; SOUND EDIT TgPartAuxMod28/2A/2C/2EGet/Set)
#   aeg_attack_key +0x2F, aeg_decay_key +0x30  key follow of those rates; aeg_break1..3 +0x31..+0x33 the
#                      velocity / key breakpoints; aeg_attack_velo +0x34, aeg_decay_velo +0x35 velocity
#                      sense; aeg_release_key +0x36 the release key-scale slope (TgDrumAmpReleaseCalc)
#   cutoff_adjust +0x3E  the folded CUTOFF ADJUST (TgKeyOffFilterRelease 0x4C03248B)
#   +0x3F..+0x4C       the filter EG: segment levels +0x3F / +0x41 / +0x43 / +0x45 (offsets on cutoff_adjust,
#                      TgZoneFilterEgLevel1/2Calc, TgZoneFilterEgLevelCalc), rates +0x40 (attack), +0x42 /
#                      +0x44 (decay), +0x46 (release), release level +0x47, key scale +0x4A (attack) / +0x4C
#                      (decay) (TgFilterEgAttackCalc 0x4C0321BA, TgFilterEgDecayCalc 0x4C03231A)
#   the rest           no reader traced
.macro SOUND_MOD m00, m01, m02, m03, m04, m05, m06, m07, m08, level_ofs, velo_sense, peg_attack_rate, peg_0c, peg_decay1_rate, peg_level_0e, peg_decay2_rate, peg_level_10, peg_release_rate, peg_release_scale, m13, level_key_slope, peg_key_scale0, peg_key_scale1, peg_key_scale2, send_a, send_b_glide, key_follow_slope, key_follow_mode, m1c, m1d, m1e, m1f, velo_fade0, velo_fade1, velo_fade2, velo_fade3, key_fade0, key_fade1, key_fade2, key_fade3, aeg_attack_rate, m29, aeg_decay1_rate, m2b, aeg_decay2_rate, m2d, aeg_release_rate, aeg_attack_key, aeg_decay_key, aeg_break1, aeg_break2, aeg_break3, aeg_attack_velo, aeg_decay_velo, aeg_release_key, m37, m38, m39, m3a, m3b, m3c, m3d, cutoff_adjust, feg_level1, feg_attack_rate, feg_level2, feg_decay1_rate, feg_level3, feg_decay2_rate, feg_level4, feg_release_rate, feg_release_level, m48, m49, feg_attack_key, m4b, feg_decay_key, m4d, m4e, m4f, m50, m51, m52, m53, m54, m55, m56, m57, m58, m59, m5a, m5b, m5c, m5d, m5e, m5f, m60, m61, m62, m63, m64, m65, m66, m67, m68, m69, m6a, m6b, m6c, m6d, m6e, m6f, m70, m71, m72, m73, m74, m75, m76, m77, m78, m79
	.byte	\m00, \m01, \m02, \m03, \m04, \m05, \m06, \m07, \m08, \level_ofs, \velo_sense, \peg_attack_rate, \peg_0c, \peg_decay1_rate, \peg_level_0e, \peg_decay2_rate, \peg_level_10, \peg_release_rate, \peg_release_scale, \m13
	.byte	\level_key_slope, \peg_key_scale0, \peg_key_scale1, \peg_key_scale2, \send_a, \send_b_glide, \key_follow_slope, \key_follow_mode, \m1c, \m1d, \m1e, \m1f, \velo_fade0, \velo_fade1, \velo_fade2, \velo_fade3, \key_fade0, \key_fade1, \key_fade2, \key_fade3
	.byte	\aeg_attack_rate, \m29, \aeg_decay1_rate, \m2b, \aeg_decay2_rate, \m2d, \aeg_release_rate, \aeg_attack_key, \aeg_decay_key, \aeg_break1, \aeg_break2, \aeg_break3, \aeg_attack_velo, \aeg_decay_velo, \aeg_release_key, \m37, \m38, \m39, \m3a, \m3b
	.byte	\m3c, \m3d, \cutoff_adjust, \feg_level1, \feg_attack_rate, \feg_level2, \feg_decay1_rate, \feg_level3, \feg_decay2_rate, \feg_level4, \feg_release_rate, \feg_release_level, \m48, \m49, \feg_attack_key, \m4b, \feg_decay_key, \m4d, \m4e, \m4f
	.byte	\m50, \m51, \m52, \m53, \m54, \m55, \m56, \m57, \m58, \m59, \m5a, \m5b, \m5c, \m5d, \m5e, \m5f, \m60, \m61, \m62, \m63
	.byte	\m64, \m65, \m66, \m67, \m68, \m69, \m6a, \m6b, \m6c, \m6d, \m6e, \m6f, \m70, \m71, \m72, \m73, \m74, \m75, \m76, \m77
	.byte	\m78, \m79
.endm
# ---- END SOUND RECORDS ----
