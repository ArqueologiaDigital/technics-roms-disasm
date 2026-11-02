# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# The style-record and event macros of src/ic18/rhythm.s (tools/gen_ic18_rhythm_s.py), copied
# verbatim by tools/gen_data_s.py for the program's own Technics Rhythms resource; do not edit.

# ---- record macros ----------------------------------------------------------------
# A part set-up (15 bytes): each byte is the value of one controller, in the order of
# the firmware's field table 0x485B77D4 (CC -> field map 0x485B781C). The firmware
# copies the eight of a style into the part table 0x5003A37C (func_4844187A); the
# set-up events of a variation then overwrite single fields (func_48441EB4).
# The meanings are program 941's (notes/ic18-rhythm-rom.md, "A part set-up"): the CC is turned
# into the part parameter 0xB000cc (func_48440533), named by the SP7001 parameter dump
# func_48500C71 ("EQ LOW FC", "DIGITAL EFFECT" ...).
#   fold_root  CC97, never sent (func_48440662 skips a controller above 127; the field table
#              gives it 255): a note follows the chord root up by root - 1 semitones, an
#              octave lower when root - 1 > fold_root (func_484419BB -> func_48436229).
#              0x00 on the drum parts, 0x08 (G#) on the others
#   volume     CC7, sent folded into CC11 (func_48440662: expression + volume - 127)
#   prog, bank_lsb, bank_msb   the part's sound {program, bank LSB, bank MSB}; MSB 0x26 = kits
#   dsp_sw     CC94, DIGITAL EFFECT: 0 off, 127 on, any other value (64 in every style) the
#              sound's own setting, which func_48448D93 looks up (func_48440662 sends 0 or 127)
#   reverb     CC91          chorus   CC93 (CHORUS DEPTH)          pan   CC10
#   bend_range CC96 -> parameter 0xB08000, RPN 0: BEND SENS, in semitones
#   eq_lo_fc, eq_lo_gain, eq_hi_fc, eq_hi_gain   CC82, CC83, CC80, CC81: the part EQ; FC >> 2
#              indexes 20 Hz .. 20 kHz in third octaves (0x485EC344, func_4848BC9A), gain (v - 64) / 2 dB
#   multi      CC92, MULTI EFFECT DEPTH
.macro style_part fold_root, volume, prog, bank_lsb, bank_msb, dsp_sw, reverb, chorus, pan, bend_range, eq_lo_fc, eq_lo_gain, eq_hi_fc, eq_hi_gain, multi
	.byte	\fold_root, \volume, \prog, \bank_lsb, \bank_msb, \dsp_sw, \reverb, \chorus, \pan
	.byte	\bend_range, \eq_lo_fc, \eq_lo_gain, \eq_hi_fc, \eq_hi_gain, \multi
.endm
# The two sound-unit keys of a style (record +0x0D, 4 bytes; func_484420EF): each pair is
# a 14-bit value, 7 bits a byte, low byte first (bit 6 of the second byte adds 0x10000),
# stored to parameter keys 0xB044 and 0xB054: the DSP preset of effect units EFF4 and EFF5
# (groups 0xB040 / 0xB050, SndUnitRefreshGroups56). The key is a preset of program 941's
# table 0x48703558, index lo << 6 | hi (func_48412187), whose name the comment gives.
# Bit 7 of the first pair's second byte goes to key 0xB001, the EFFECT DEBUG screen's
# TOTAL MODE / SOUND MODE switch (EffApcSw).
.macro style_units eff4_lo, eff4_hi, eff5_lo, eff5_hi
	.byte	\eff4_lo, \eff4_hi, \eff5_lo, \eff5_hi
.endm
# The 20 slot offsets of a style (record +0x8A, from the record): StyleNameCommit loads
# them into 0x50034BCC[]. Slots 0-11 are four variations, each a main pattern and two
# fill-ins (only slot % 3 == 0 has a name in a MEMORY style: MemStyleVarCopy). 12-19 are
# INTRO 1, ENDING 1, INTRO 2, ENDING 2 (slot 12 + 4k, 14 + 4k: func_484437DA, func_484439EB),
# each a major and a minor version: StyleRecordSlotSelect adds 0x5003A46A, 1 for a minor-
# family chord (func_484361BC). [INFERENCE] the fill-in role
.macro style_slots s
	.be24	\s_Var1 - \s, \s_Var1Fill1 - \s, \s_Var1Fill2 - \s
	.be24	\s_Var2 - \s, \s_Var2Fill1 - \s, \s_Var2Fill2 - \s
	.be24	\s_Var3 - \s, \s_Var3Fill1 - \s, \s_Var3Fill2 - \s
	.be24	\s_Var4 - \s, \s_Var4Fill1 - \s, \s_Var4Fill2 - \s
	.be24	\s_Intro1Major - \s, \s_Intro1Minor - \s, \s_Ending1Major - \s, \s_Ending1Minor - \s
	.be24	\s_Intro2Major - \s, \s_Intro2Minor - \s, \s_Ending2Major - \s, \s_Ending2Minor - \s
.endm
# A variation record (StyleRecordBindBuiltin): bars - 1 (-> 0x50122DCE), beats a bar - 1
# (-> 0x50122DCF; StyleBoundRecByteCfLow3), two part numbers for the sound units (0xFF =
# none; func_48442164, key 0xB048 [INFERENCE: the role]), the length of the set-up
# events, the events; then the length of the event stream and the stream.
.macro var_head v, bars, beats, unit_part_a, unit_part_b
	.byte	\bars - 1, \beats - 1, \unit_part_a, \unit_part_b
	.be16	\v_SetupEnd - \v_Setup
\v_Setup:
.endm
.macro var_events v
\v_SetupEnd:
	.be24	\v_EventsEnd - \v_Events
\v_Events:
.endm
.macro var_end v
\v_EventsEnd:
.endm
# Events (RhyEventLenByStatus): `part` is the low nibble of the status byte, 0-7. The
# @ form of each takes the position byte that precedes the event: the tick in the beat,
# 0-95 (96 a beat); without it the event is at the tick of the one before (tick 0 after a
# beat marker).
# n: note. gate = its length in ticks, 7 bits a byte, low first (func_484425FE:
#    `movbu (4, a1), d0` `movbu (3, a1), d1` `asl 7, d0` `add d1, d0`); rule = its
#    NoteConvRules entry, how the key follows the chord (func_4843D558 -> func_4843CEF3 ->
#    func_48436229; NcrNone on every drum-part note)
.macro n part, key, vel, gate, rule
	.byte 0x90 + \part, \key, \vel, (\gate) & 0x7f, (\gate) >> 7, \rule
.endm
.macro @n tick, part, key, vel, gate, rule
	.byte \tick, 0x90 + \part, \key, \vel, (\gate) & 0x7f, (\gate) >> 7, \rule
.endm
# cc: control change, controller by number
.macro cc part, ctl, value
	.byte 0xb0 + \part, \ctl, \value
.endm
.macro @cc tick, part, ctl, value
	.byte \tick, 0xb0 + \part, \ctl, \value
.endm
# pc: program change: the three bytes of a part set-up's prog/bank_lsb/bank_msb
.macro pc part, prog, bank_lsb, bank_msb
	.byte 0xc0 + \part, \prog, \bank_lsb, \bank_msb
.endm
.macro @pc tick, part, prog, bank_lsb, bank_msb
	.byte \tick, 0xc0 + \part, \prog, \bank_lsb, \bank_msb
.endm
# bend: pitch bend
.macro bend part, lsb, msb
	.byte 0xe0 + \part, \lsb, \msb
.endm
.macro @bend tick, part, lsb, msb
	.byte \tick, 0xe0 + \part, \lsb, \msb
.endm
# pres: channel pressure
.macro pres part, value
	.byte 0xd0 + \part, \value
.endm
.macro @pres tick, part, value
	.byte \tick, 0xd0 + \part, \value
.endm
# bend_range: CC96
.macro bend_range part, value
	.byte 0xb0 + \part, 96, \value
.endm
.macro @bend_range tick, part, value
	.byte \tick, 0xb0 + \part, 96, \value
.endm
# cho: CC93
.macro cho part, value
	.byte 0xb0 + \part, 93, \value
.endm
.macro @cho tick, part, value
	.byte \tick, 0xb0 + \part, 93, \value
.endm
# dsp_sw: CC94
.macro dsp_sw part, value
	.byte 0xb0 + \part, 94, \value
.endm
.macro @dsp_sw tick, part, value
	.byte \tick, 0xb0 + \part, 94, \value
.endm
# eq_hi_fc: CC80
.macro eq_hi_fc part, value
	.byte 0xb0 + \part, 80, \value
.endm
.macro @eq_hi_fc tick, part, value
	.byte \tick, 0xb0 + \part, 80, \value
.endm
# eq_hi_gain: CC81
.macro eq_hi_gain part, value
	.byte 0xb0 + \part, 81, \value
.endm
.macro @eq_hi_gain tick, part, value
	.byte \tick, 0xb0 + \part, 81, \value
.endm
# eq_lo_fc: CC82
.macro eq_lo_fc part, value
	.byte 0xb0 + \part, 82, \value
.endm
.macro @eq_lo_fc tick, part, value
	.byte \tick, 0xb0 + \part, 82, \value
.endm
# eq_lo_gain: CC83
.macro eq_lo_gain part, value
	.byte 0xb0 + \part, 83, \value
.endm
.macro @eq_lo_gain tick, part, value
	.byte \tick, 0xb0 + \part, 83, \value
.endm
# expr: CC11
.macro expr part, value
	.byte 0xb0 + \part, 11, \value
.endm
.macro @expr tick, part, value
	.byte \tick, 0xb0 + \part, 11, \value
.endm
# fold_root: CC97
.macro fold_root part, value
	.byte 0xb0 + \part, 97, \value
.endm
.macro @fold_root tick, part, value
	.byte \tick, 0xb0 + \part, 97, \value
.endm
# mod: CC1
.macro mod part, value
	.byte 0xb0 + \part, 1, \value
.endm
.macro @mod tick, part, value
	.byte \tick, 0xb0 + \part, 1, \value
.endm
# multi: CC92
.macro multi part, value
	.byte 0xb0 + \part, 92, \value
.endm
.macro @multi tick, part, value
	.byte \tick, 0xb0 + \part, 92, \value
.endm
# pan: CC10
.macro pan part, value
	.byte 0xb0 + \part, 10, \value
.endm
.macro @pan tick, part, value
	.byte \tick, 0xb0 + \part, 10, \value
.endm
# rev: CC91
.macro rev part, value
	.byte 0xb0 + \part, 91, \value
.endm
.macro @rev tick, part, value
	.byte \tick, 0xb0 + \part, 91, \value
.endm
# sus: CC64
.macro sus part, value
	.byte 0xb0 + \part, 64, \value
.endm
.macro @sus tick, part, value
	.byte \tick, 0xb0 + \part, 64, \value
.endm
# vol: CC7
.macro vol part, value
	.byte 0xb0 + \part, 7, \value
.endm
.macro @vol tick, part, value
	.byte \tick, 0xb0 + \part, 7, \value
.endm
# A position byte with no event after it (the data of this ROM needs none).
.macro at tick
	.byte \tick
.endm
# The beat marker (a stream holds bars x beats of them) and the end of the stream.
.macro beat
	.byte 0xf4
.endm
.macro end
	.byte 0xf5
.endm
# Drum keys, used on parts 0 and 7: the names of table 84's Standard Kit 1 (tone 0x260000;
# its per-note voice records, TgNoteOnTableTone). The other kits keep the layout: 92.5 % of the
# styles' drum notes play a voice of that name in their own kit (notes/ic18-rhythm-rom.md).
.equ KitElectricSD, 2
.equ KitElectricTomL, 3
.equ KitElectricTomM, 4
.equ KitElectricTomH, 5
.equ KitOrchTambourin, 6
.equ KitOrchBassDrum, 7
.equ KitOrchSnare, 8
.equ KitOrchCymbal, 9
.equ KitBrushSwirl, 10
.equ KitBrushSlap, 11
.equ KitVoiceAh, 12
.equ KitVoiceYeh, 13
.equ KitVoiceUhs, 14
.equ KitAmbientHammer, 15
.equ KitClick1, 16
.equ KitClick2, 17
.equ KitHHOnBeat, 18
.equ KitHHOffBeat, 19
.equ KitHiHatAccent, 20
.equ KitHHHalfOpen, 21
.equ KitReverseCymbal, 22
.equ KitReverseSnare, 23
.equ KitPiccoloSnare, 24
.equ KitSnareRoll, 25
.equ KitFingerSnap, 26
.equ KitHighQ, 27
.equ KitSlap, 28
.equ KitScratchPush, 29
.equ KitScratchPull, 30
.equ KitSticks, 31
.equ KitSquareClick, 32
.equ KitMetronomeTap, 33
.equ KitMetronomeBell, 34
.equ KitBassDrum2, 35
.equ KitBassDrum1, 36
.equ KitRimShot, 37
.equ KitSnareDrum1, 38
.equ KitHandClaps, 39
.equ KitSnareDrum2, 40
.equ KitBassTomL, 41
.equ KitHiHatClosed, 42
.equ KitBassTomH, 43
.equ KitHiHatPedal, 44
.equ KitLowTom, 45
.equ KitHiHatOpen, 46
.equ KitMidTomL, 47
.equ KitMidTomH, 48
.equ KitCrashCymbal1, 49
.equ KitHighTom, 50
.equ KitRideCymbal1, 51
.equ KitChinaCymbal, 52
.equ KitRideBell, 53
.equ KitTambourine, 54
.equ KitSplashCymbal, 55
.equ KitCowbell, 56
.equ KitCrashCymbal2, 57
.equ KitVibraslap, 58
.equ KitRideCymbal2, 59
.equ KitBongoHigh, 60
.equ KitBongoLow, 61
.equ KitCongaMuteSlp, 62
.equ KitCongaHigh, 63
.equ KitCongaLow, 64
.equ KitTimbalesHigh, 65
.equ KitTimbalesLow, 66
.equ KitAgogoHigh, 67
.equ KitAgogoLow, 68
.equ KitCabasa, 69
.equ KitMaracas, 70
.equ KitShortWhistle, 71
.equ KitLongWhistle, 72
.equ KitGuiroShort, 73
.equ KitGuiroLong, 74
.equ KitClaves, 75
.equ KitWoodBlockH, 76
.equ KitWoodBlockL, 77
.equ KitCuicaMute, 78
.equ KitCuicaOpen, 79
.equ KitTriangleMute, 80
.equ KitTriangleOpen, 81
.equ KitShaker, 82
.equ KitSleighBell, 83
.equ KitBellTree, 84
.equ KitCastanets, 85
.equ KitSurdoMute, 86
.equ KitSurdoOpen, 87
.equ KitApplause, 88
.equ KitWindchime, 89
.equ KitSambaDrumOn, 90
.equ KitSambaDrumOff, 91
.equ KitSmallCongaH, 92
.equ KitSmallCongaL, 93
.equ KitCongaMuteOn, 94
.equ KitCongaMuteOff, 95
.equ KitCongaOpenSlp, 96
.equ KitBongoMute1, 97
.equ KitBongoMute2, 98
.equ KitBongoMute3, 99
.equ KitTimbalesOpenH, 100
.equ KitTimbalesPaila, 101
.equ KitSambaWhistleH, 102
.equ KitSambaWhistleL, 103
.equ KitShakerOnBeat, 104
.equ KitShakerOffBeat, 105
.equ KitMaracasOn, 106
.equ KitMaracasOff, 107
.equ KitTambourineOn, 108
.equ KitTambourineOff, 109
.equ KitSmallWoodBlk, 110
.equ KitCowbell1, 111
.equ KitCowbell2, 112
.equ KitCowbell3, 113
.equ KitCowbell4, 114
.equ KitCowbell5, 115
.equ KitCowbell6, 116
# Note conversion rules (a note's last byte): NoteConvRules 0x48736104, by the name of the
# rule's table in program 941. NcrNone has no table: the key does not follow the chord.
.equ NcrNone, 0
.equ NcrRootShiftOnly, 1
.equ NcrMelodyBasic, 16
.equ NcrMelodyIn7thGToBb, 17
.equ NcrMelodyIn7thCToBb, 18
.equ NcrMajInclFForGospelEtc, 19
.equ NcrMajInclAForWalkingBass, 20
.equ NcrMajInclBbForMajIs7th, 21
.equ NcrNaturalIsMelodicDown, 22
.equ NcrHarmonicMinor, 23
.equ NcrMerodicMinAscend, 24
.equ NcrBasicChord100, 80
.equ NcrKeepNearC, 82
.equ NcrHardRockChord, 83
.equ NcrChordCEGB, 96
.equ NcrChordCDEG, 97
.equ NcrChordDEGB, 98
.equ NcrChordCEGA, 100
.equ NcrChordADGC, 101
.equ NcrChordEGAD, 102
.equ NcrChordCEAD, 103
.macro sidx_style no
	.be16	\no
.endm
.macro sidx_alias entry
	.be16	0x8000 + \entry
.endm
.macro sidx_table no
	.be16	0x4000 + \no
.endm


# (from src/table/style_macros.inc: the built-in pads' macros)
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
