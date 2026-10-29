; kn_song.inc -- the SX-KN6000 / SX-KN7000 song files (.SQT payloads), as llvm-mc macros.
; Used by the payload sources floppy/tools/kd/kn_sqt.py writes; its docstring gives the layout and says
; which parts are measured rather than traced.  Multi-byte fields are little-endian.

	.ifndef	KN_SONG_INC
	.set	KN_SONG_INC, 1

; A track of the song record's directory (+0xD0, 16 of them): flags (bit 7 = the track holds events)
; and its first cell.
	.macro	sq_track flags, cell
	.byte	\flags
	.short	\cell
	.endm
; A 256-byte event cell's header: flags, the previous and the next cell of its chain (0 / 0xFFFF none).
	.macro	sq_cell flags, prev, next
	.byte	\flags
	.short	\prev, \next
	.endm

; Events.  [INFERENCE] measured (kn_sqt.py): tick = the byte before a channel or system event, ch = the
; status byte's low nibble.
	.macro	sq_beat
	.byte	0x81
	.endm
	.macro	sq_end
	.byte	0x82
	.endm
	.macro	sq_note tick, ch, key, velocity, len_lo, len_hi
	.byte	\tick, 0x90 + \ch, \key, \velocity, \len_lo, \len_hi
	.endm
	.macro	sq_8n tick, n, d0, d1
	.byte	\tick, 0x80 + \n, \d0, \d1
	.endm
	.macro	sq_a tick, ch, d0, d1, d2, d3, d4, d5
	.byte	\tick, 0xa0 + \ch, \d0, \d1, \d2, \d3, \d4, \d5
	.endm
	.macro	sq_cc tick, ch, ctl, value, d2
	.byte	\tick, 0xb0 + \ch, \ctl, \value, \d2
	.endm
	.macro	sq_pc tick, ch, prog, bank_lsb, bank_msb
	.byte	\tick, 0xc0 + \ch, \prog, \bank_lsb, \bank_msb
	.endm
	.macro	sq_press tick, ch, value
	.byte	\tick, 0xd0 + \ch, \value
	.endm
	.macro	sq_bend tick, ch, lsb, msb
	.byte	\tick, 0xe0 + \ch, \lsb, \msb
	.endm
	.macro	sq_sys tick, status, data:vararg
	.ifb	\data
	.byte	\tick, \status
	.else
	.byte	\tick, \status, \data
	.endif
	.endm

	.endif
