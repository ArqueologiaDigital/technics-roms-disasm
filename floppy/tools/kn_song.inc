; kn_song.inc -- the SX-KN6000 / SX-KN7000 song files (.SQT payloads), as llvm-mc macros.
; Used by the payload sources floppy/tools/kd/kn_sqt.py writes; its docstring gives the layout and the
; firmware routines behind it.  Multi-byte fields are little-endian except the parameter ids of 0xAn / 0xFn.

	.ifndef	KN_SONG_INC
	.set	KN_SONG_INC, 1

; A track of the song record's directory (+0xD0, 16 of them): flags (bit 7 = the track holds events; the
; low bits are not traced) and its first cell.
	.macro	sq_track flags, cell
	.byte	\flags
	.short	\cell
	.endm
; A 256-byte event cell's header: flags, the previous and the next cell of its chain (0 / 0xFFFF none).
	.macro	sq_cell flags, prev, next
	.byte	\flags
	.short	\prev, \next
	.endm

; Events.  Lengths: the firmware's per-status table 0x485B9328 (func_4845BC5B; the player 0x484595F0 ->
; 0x4845979E -> 0x48459C98, classifier 0x48458705), kn7000/notes/presentation-control-probes/song-records.md
; section 2.  `tick` = a byte below 0x80, the position in the beat (96 PPQN), before the event.
	.macro	sq_beat
	.byte	0x81
	.endm
	.macro	sq_end
	.byte	0x82
	.endm
; 0x9n: note, velocity, u16 duration; n = 8 when recorded from MIDI IN (the classifier posts it as source 5).
; A note's dur_hi and a bend's msb are the only data bytes seen with bit 7 set (5 on the disks).
	.macro	sq_note tick, n, key, velocity, dur_lo, dur_hi
	.byte	\tick, 0x90 + \n, \key, \velocity, \dur_lo, \dur_hi
	.endm
; 0x80: tempo = lo7 + (hi7 << 7) BPM (parameter 0x000004); 0x8A: PIC = lo7 + ((hi7 & 0x3F) << 7), bit 6 of hi7
; = USER (parameter 0x600014).  0x84 (bar), 0x85 / 0x86 (rhythm start / stop) take no data: sq_sys.
	.macro	sq_8n tick, n, lo7, hi7
	.byte	\tick, 0x80 + \n, \lo7, \hi7
	.endm
; 0xAn, n = 1..3 the value's width: a part parameter {part, flags, id (big-endian, 3 bytes), value}; flags
; restores bit 7 of the bytes that follow.
	.macro	sq_a tick, n, part, flags, id_hi, id_mid, id_lo, value:vararg
	.byte	\tick, 0xa0 + \n, \part, \flags, \id_hi, \id_mid, \id_lo, \value
	.endm
; 0xB0: control change {part, cc, value} = parameter 0xB000cc (status 0xB1-0xBF is not an event: n is 0).
	.macro	sq_cc tick, n, part, cc, value
	.byte	\tick, 0xb0 + \n, \part, \cc, \value
	.endm
; 0xC0: program change {prog, bank LSB, bank MSB} = parameter 0xC00000.
	.macro	sq_pc tick, n, prog, bank_lsb, bank_msb
	.byte	\tick, 0xc0 + \n, \prog, \bank_lsb, \bank_msb
	.endm
; 0xD0: channel aftertouch (0xD00000).
	.macro	sq_press tick, n, value
	.byte	\tick, 0xd0 + \n, \value
	.endm
; 0xE0: pitch bend (0xE00000).
	.macro	sq_bend tick, n, lsb, msb
	.byte	\tick, 0xe0 + \n, \lsb, \msb
	.endm
; 0xF1-0xF4: a global parameter {flags, id (3 bytes), value (n bytes)}; 0x84 bar, 0x85 rhythm START, 0x86 STOP.
	.macro	sq_sys tick, status, data:vararg
	.ifb	\data
	.byte	\tick, \status
	.else
	.byte	\tick, \status, \data
	.endif
	.endm

	.endif
