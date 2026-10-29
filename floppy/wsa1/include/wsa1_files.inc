; wsa1_files.inc -- the SX-WSA1R disk files, as llvm-mc macros (floppy/wsa1/formats.py).

	.ifndef	WSA1_FILES_INC
	.set	WSA1_FILES_INC, 1

; One block of the song store's heap (prom_b BLOCK STORE, wsa1/notes/FINDINGS-prom_b-block-store.md):
; +0 flags (bit 7 = allocated: `bit 7,(XHL)` at 0xF62CDB), +1 the previous block (0xF63A4B), +3 the
; next block (0xF635D5; 0xFFFF ends the chain, 0xF63A46), then 251 payload bytes (0xF639B8).
	.macro	seq_block flags, prev, next
	.byte	\flags
	.short	\prev, \next
	.endm

; Song events.  [INFERENCE] the grammar is the KN5000 demo-song grammar (floppy/kn5000/events.py,
; tokenize_seq): a byte with bit 7 set is a status, the bytes after it with bit 7 clear its data; it
; parses 443 of the 444 chains on the 9 disks to an 0x82 end.  No WSA1R routine has been tied to it.
	.macro	sq_beat
	.byte	0x81
	.endm
	.macro	sq_note status, pos, note, vel, dur_ticks, dur_beats
	.byte	\status, \pos, \note, \vel, \dur_ticks, \dur_beats
	.endm
	.macro	sq_run pos, note, vel, dur_ticks, dur_beats
	.byte	\pos, \note, \vel, \dur_ticks, \dur_beats
	.endm
	.macro	sq_ev status, data:vararg
	.byte	\status
	.ifnb	\data
	.byte	\data
	.endif
	.endm
	.macro	sq_data data:vararg
	.byte	\data
	.endm

	.endif
