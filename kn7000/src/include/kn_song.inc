# (c) 2026 Felipe Correa da Silva Sanches <juca@members.fsf.org>
# Licensed under the terms of the GNU General Public License v3 or later
#
# kn_song.inc -- the SX-KN6000 / SX-KN7000 song (sequencer) data as kn7asm macros: the kn7asm
# twin of floppy/tools/kn_song.inc (llvm-mc), same names and parameters, so the lines
# floppy/tools/kd/kn_sqt.py writes assemble with either.  The layout and the firmware routines
# behind it are kn_sqt.py's docstring: a song record (0x8E0 bytes on the KN7000, "ZZZZ" first,
# its +0xD0 a directory of 16 tracks), and the event memory, 256-byte cells {flags, u16 previous
# cell, u16 next cell, 251 bytes of events}.  Used by the program's built-in demo songs
# (src/program/data/, tools/gen_data_s.py).

# A track of the song record's directory: flags (bit 7 = the track holds events) and its first cell.
.macro sq_track flags, cell
	.byte	\flags
	.word	\cell
.endm
# A 256-byte event cell's header: flags, the previous and the next cell of its chain (0 / 0xFFFF none).
.macro sq_cell flags, prev, next
	.byte	\flags
	.word	\prev, \next
.endm

# Events.  Lengths: the firmware's per-status table 0x485B9328 (func_4845BC5B; the player 0x484595F0 ->
# 0x4845979E -> 0x48459C98).  `tick` = a byte below 0x80, the position in the beat (96 PPQN).
.macro sq_beat
	.byte	0x81
.endm
.macro sq_end
	.byte	0x82
.endm
# 0x9n: note, velocity, duration in ticks (0..0x5F) and in beats (0..255, unsigned: the note handler
# func_48459B49 sets the note-off at beat + dur_beats); n = 8 when recorded from MIDI IN.
.macro sq_note tick, n, key, velocity, dur_ticks, dur_beats
	.byte	\tick, 0x90 + \n, \key, \velocity, \dur_ticks, \dur_beats
.endm
# 0x80: tempo = lo7 + (hi7 << 7) BPM; 0x8A: PIC.
.macro sq_8n tick, n, lo7, hi7
	.byte	\tick, 0x80 + \n, \lo7, \hi7
.endm
# 0xAn, n = 1..3 the value's width: a part parameter {part, flags, id (big-endian, 3 bytes), value}.
.macro sq_a tick, n, part, flags, id_hi, id_mid, id_lo, value:vararg
	.byte	\tick, 0xa0 + \n, \part, \flags, \id_hi, \id_mid, \id_lo, \value
.endm
# 0xB0: control change {part, cc, value}.
.macro sq_cc tick, n, part, cc, value
	.byte	\tick, 0xb0 + \n, \part, \cc, \value
.endm
# 0xC0: program change {prog, bank LSB, bank MSB}.
.macro sq_pc tick, n, prog, bank_lsb, bank_msb
	.byte	\tick, 0xc0 + \n, \prog, \bank_lsb, \bank_msb
.endm
# 0xD0: channel aftertouch.
.macro sq_press tick, n, value
	.byte	\tick, 0xd0 + \n, \value
.endm
# 0xE0: pitch bend.
.macro sq_bend tick, n, lsb, msb
	.byte	\tick, 0xe0 + \n, \lsb, \msb
.endm
# 0xF1-0xF4: a global parameter {flags, id (3 bytes), value (n bytes)}; 0x84 bar, 0x85 rhythm START,
# 0x86 STOP (no data).
.macro sq_sys tick, status, data:vararg
	.byte	\tick, \status, \data
.endm
# Stale events in the KN5000's order, status first (floppy/kn5000/events.py), as cells still hold them past the
# end of a track and in free cells (kn_sqt.py stale_tokens; floppy/tools/kn_song.inc, the llvm-mc twin, has the
# notes): 0x9n {status, tick, key, velocity, duration ticks and beats}; a further note under the same status;
# any other KN5000 status with its data bytes.
.macro k5_note status, tick, key, velocity, dur_ticks, dur_beats
	.byte	\status, \tick, \key, \velocity, \dur_ticks, \dur_beats
.endm
.macro k5_run tick, key, velocity, dur_ticks, dur_beats
	.byte	\tick, \key, \velocity, \dur_ticks, \dur_beats
.endm
.macro k5_ev status, data:vararg
	.byte	\status, \data
.endm
