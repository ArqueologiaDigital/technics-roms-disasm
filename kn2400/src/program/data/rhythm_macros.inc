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
#   mode     CC97; 0x00 on the two drum parts, 0x08 on the others   [INFERENCE: role]
#   volume   CC7
#   prog, bank_lsb, bank_msb   the three data bytes of the part's program change
#            (StyleRecordToTemplate); bank_msb is 0x26 on the drum parts, 0x20 on the
#            others. [INFERENCE] the names of the two bank bytes
#   cc94     CC94          reverb   CC91          chorus   CC93          pan   CC10
#   cc96, cc82, cc83, cc80, cc81, cc92   those controllers
.macro style_part mode, volume, prog, bank_lsb, bank_msb, cc94, reverb, chorus, pan, cc96, cc82, cc83, cc80, cc81, cc92
	.byte	\mode, \volume, \prog, \bank_lsb, \bank_msb, \cc94, \reverb, \chorus, \pan
	.byte	\cc96, \cc82, \cc83, \cc80, \cc81, \cc92
.endm
# The two sound-unit keys of a style (record +0x0D, 4 bytes; func_484420EF): each pair is
# a 14-bit value, 7 bits a byte, low byte first (bit 6 of the second byte adds 0x10000);
# they are stored to parameter keys 0xB044 and 0xB054, the sound-unit groups 0xB040 and
# 0xB050 (SndUnitRefreshGroups56). Bit 7 of the second byte goes to key 0xB001.
.macro style_units unit5_lo, unit5_hi, unit6_lo, unit6_hi
	.byte	\unit5_lo, \unit5_hi, \unit6_lo, \unit6_hi
.endm
# The 20 slot offsets of a style (record +0x8A, from the record): StyleNameCommit loads
# them into 0x50034BCC[]. Slots 0-11 are four variations, each a main pattern and two
# fill-ins (only slot % 3 == 0 has a name in a MEMORY style: MemStyleVarCopy); 12-19 are
# four A/B pairs, 12-15 intros, 16-19 endings (func_4844232B tells (slot - 12) % 4 < 2,
# number 1, from number 2). [INFERENCE] the intro/ending and fill-in roles
.macro style_slots s
	.be24	\s_Var1 - \s, \s_Var1Fill1 - \s, \s_Var1Fill2 - \s
	.be24	\s_Var2 - \s, \s_Var2Fill1 - \s, \s_Var2Fill2 - \s
	.be24	\s_Var3 - \s, \s_Var3Fill1 - \s, \s_Var3Fill2 - \s
	.be24	\s_Var4 - \s, \s_Var4Fill1 - \s, \s_Var4Fill2 - \s
	.be24	\s_Intro1A - \s, \s_Intro1B - \s, \s_Intro2A - \s, \s_Intro2B - \s
	.be24	\s_Ending1A - \s, \s_Ending1B - \s, \s_Ending2A - \s, \s_Ending2B - \s
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
# n: note. [INFERENCE] len_lo/len_hi its length, cls its chord-adaptation class (0 on every drum-part note)
.macro n part, key, vel, len_lo, len_hi, cls
	.byte 0x90 + \part, \key, \vel, \len_lo, \len_hi, \cls
.endm
.macro @n tick, part, key, vel, len_lo, len_hi, cls
	.byte \tick, 0x90 + \part, \key, \vel, \len_lo, \len_hi, \cls
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
# cho: CC93
.macro cho part, value
	.byte 0xb0 + \part, 93, \value
.endm
.macro @cho tick, part, value
	.byte \tick, 0xb0 + \part, 93, \value
.endm
# expr: CC11
.macro expr part, value
	.byte 0xb0 + \part, 11, \value
.endm
.macro @expr tick, part, value
	.byte \tick, 0xb0 + \part, 11, \value
.endm
# mod: CC1
.macro mod part, value
	.byte 0xb0 + \part, 1, \value
.endm
.macro @mod tick, part, value
	.byte \tick, 0xb0 + \part, 1, \value
.endm
# mode: CC97
.macro mode part, value
	.byte 0xb0 + \part, 97, \value
.endm
.macro @mode tick, part, value
	.byte \tick, 0xb0 + \part, 97, \value
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
# Drum keys, used on parts 0 and 7: the GS/GM percussion map. [INFERENCE] that the
# KN7000's kits follow it (table 84's drum-voice records near 0x1088D0 list Bass Drum 2,
# Bass Drum 1, Side Stick, Snare Drum 1 in the GM order of keys 35-38).
.equ HIGHQ, 27
.equ SLAP, 28
.equ SCRPUSH, 29
.equ SCRPULL, 30
.equ STICKS, 31
.equ SQCLICK, 32
.equ MCLICK, 33
.equ MBELL, 34
.equ BD2, 35
.equ BD1, 36
.equ SSTICK, 37
.equ SD1, 38
.equ CLAP, 39
.equ SD2, 40
.equ LTOM2, 41
.equ HHC, 42
.equ LTOM1, 43
.equ HHP, 44
.equ MTOM2, 45
.equ HHO, 46
.equ MTOM1, 47
.equ HTOM2, 48
.equ CRASH1, 49
.equ HTOM1, 50
.equ RIDE1, 51
.equ CHINA, 52
.equ RBELL, 53
.equ TAMB, 54
.equ SPLASH, 55
.equ COWBELL, 56
.equ CRASH2, 57
.equ VSLAP, 58
.equ RIDE2, 59
.equ HBONGO, 60
.equ LBONGO, 61
.equ MHCONGA, 62
.equ OHCONGA, 63
.equ LCONGA, 64
.equ HTIMB, 65
.equ LTIMB, 66
.equ HAGOGO, 67
.equ LAGOGO, 68
.equ CABASA, 69
.equ MARACAS, 70
.equ SWHISTL, 71
.equ LWHISTL, 72
.equ SGUIRO, 73
.equ LGUIRO, 74
.equ CLAVES, 75
.equ HWOOD, 76
.equ LWOOD, 77
.equ MCUICA, 78
.equ OCUICA, 79
.equ MTRI, 80
.equ OTRI, 81
.equ SHAKER, 82
.equ JBELL, 83
.equ BELLTREE, 84
.equ CASTAN, 85
.equ MSURDO, 86
.equ OSURDO, 87
.macro sidx_style no
	.be16	\no
.endm
.macro sidx_alias entry
	.be16	0x8000 + \entry
.endm
.macro sidx_table no
	.be16	0x4000 + \no
.endm
