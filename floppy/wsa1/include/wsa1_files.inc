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

; ---- COMBINATION (.CMB): the user combination bank, CPU 2 flash 0xEC0000 (DiskLoad_Combination prom_a
; 0xFE2092 streams 0x16300 bytes there).  Its layout is the factory bank's (prom_c PresetBank,
; prom_c/data_tables/preset_bank.s): a 0x200-byte header, 16 bank names at +0x200, 128 combinations of 0x2C0
; at +0x300 (CombiBank_RemoteCombiAddr prom_a 0xF9F984: 0xEC0300 + 0x1600*bank + 0x2C0*memory).  A combination
; is 23 {tag, length, payload} records and FF FF.  Field names: the Technics Reference Guide's, located by
; wsa1/notes/sysex-probes/sysex_combination_layout.py --fields (the 00-area parameter descriptors and their
; setters; a packed byte is named for the fields it holds).  Unnamed offsets keep a letter and the offset.
	.ifndef	WSA1_CMB_INC
	.set	WSA1_CMB_INC, 1
; record 0x78: the 16-character COMBINATION NAME follows cmb_name.
	.macro	cmb_name
	.byte	0x78, 16
	.endm
; record 0x60 EFFECT COMMON: +0 bit 0 the ALGORITHM
	.macro	cmb_effect_common algorithm, m01, m02, m03, m04, m05, m06, m07, m08, m09, m0a, m0b
	.byte	0x60, 12
	.byte	\algorithm, \m01, \m02, \m03, \m04, \m05, \m06, \m07, \m08, \m09, \m0a, \m0b
	.endm
; records 0x61 EFFECT 1, 0x62 EFFECT 2, 0x63 REVERB: +0 TYPE, +1..+0x16 its VALUE slots (written by the
; 11/any parameter family), +0x17..+0x1D zero in every combination
	.macro	cmb_effect tag, effect_type, v01, v02, v03, v04, v05, v06, v07, v08, v09, v0a, v0b, v0c, v0d, v0e, v0f, v10, v11, v12, v13, v14, v15, v16, z17, z18, z19, z1a, z1b, z1c, z1d
	.byte	\tag, 30
	.byte	\effect_type, \v01, \v02, \v03, \v04, \v05, \v06, \v07, \v08, \v09, \v0a, \v0b, \v0c, \v0d, \v0e, \v0f
	.byte	\v10, \v11, \v12, \v13, \v14, \v15, \v16, \z17, \z18, \z19, \z1a, \z1b, \z1c, \z1d
	.endm
; records 0x00+k: PART k block A.  prog_bank0..2 PROGRAM CHANGE & BANK; channel_flags = BASIC CHANNEL
; (bits 0-4), LOCAL CONTROL (5), MIDI OUT SETTING (6), MIDI IN SETTING (7); mmo_* the MIDI MULTIPLE
; MESSAGES OUTPUT settings; key_scaling bit 3
	.macro	cmb_part_a tag, prog_bank0, prog_bank1, prog_bank2, volume, a04, effect1_send, effect2_on, reverb_send, panpot, key_shift, fine_tune, pitch_bend_range, key_scaling, channel_flags, mmo_program, mmo_bank, a10, mmo_volume, mmo_panpot, mmo_chorus, mmo_reverb, a15, a16, a17, a18, a19, a1a, a1b, a1c, a1d
	.byte	\tag, 30
	.byte	\prog_bank0, \prog_bank1, \prog_bank2, \volume, \a04, \effect1_send, \effect2_on, \reverb_send, \panpot, \key_shift, \fine_tune, \pitch_bend_range, \key_scaling, \channel_flags, \mmo_program, \mmo_bank
	.byte	\a10, \mmo_volume, \mmo_panpot, \mmo_chorus, \mmo_reverb, \a15, \a16, \a17, \a18, \a19, \a1a, \a1b, \a1c, \a1d
	.endm
; records 0x20+k: PART k block B.  ctl_filter_* the CONTROLLER INTERNAL FILTER bits, midi_in/out_filter_*
; the MIDI INPUT / OUTPUT FILTER bits (the --fields table lists each bit)
	.macro	cmb_part_b tag, b00, b01, b02, main_out, sub_out, velocity_offset, assign_mode, key_layer_low, key_layer_high, vel_layer_low, vel_layer_high, ctl_filter_0b, ctl_filter_0c, b0d, ctl_filter_0e, midi_in_filter_0f, midi_in_filter_10, b11, b12, midi_out_filter_13, midi_out_filter_14, b15, midi_out_filter_16, midi_out_key_transpose, b18, b19, b1a, b1b, b1c, b1d
	.byte	\tag, 30
	.byte	\b00, \b01, \b02, \main_out, \sub_out, \velocity_offset, \assign_mode, \key_layer_low, \key_layer_high, \vel_layer_low, \vel_layer_high, \ctl_filter_0b, \ctl_filter_0c, \b0d, \ctl_filter_0e, \midi_in_filter_0f
	.byte	\midi_in_filter_10, \b11, \b12, \midi_out_filter_13, \midi_out_filter_14, \b15, \midi_out_filter_16, \midi_out_key_transpose, \b18, \b19, \b1a, \b1b, \b1c, \b1d
	.endm
; record 0x92 KEY SCALING / SCALE TUNING: key_scaling_shift_mode = SHIFT (bits 0-3) and MODE (bit 7);
; the twelve per-key DETUNE SETTINGs
	.macro	cmb_key_scaling total_key_scaling, key_scaling_shift_mode, detune_c, detune_db, detune_d, detune_eb, detune_e, detune_f, detune_gb, detune_g, detune_ab, detune_a, detune_bb, detune_b
	.byte	0x92, 14
	.byte	\total_key_scaling, \key_scaling_shift_mode, \detune_c, \detune_db, \detune_d, \detune_eb, \detune_e, \detune_f, \detune_gb, \detune_g, \detune_ab, \detune_a, \detune_bb, \detune_b
	.endm
; record 0x79 PART COMMON REAL TIME: main_out_eq_low/high = the EQUALIZER FREQ (bits 0-4) and GAIN
; (bits 0-5) as the descriptors read them; effect_output_select = EFFECT1 (bits 0-3) / EFFECT2 (4-7) OUTPUT SELECT
	.macro	cmb_common key_transpose, main_out_eq_low, c02, main_out_eq_high, c04, effect_output_select, c06, c07, c08, c09, c0a, c0b, c0c, c0d, c0e, c0f, c10, c11, c12, c13, c14, c15, c16, c17, c18, c19, c1a, c1b, c1c, c1d, c1e, c1f, c20, c21, c22, c23, c24, c25, c26, c27, c28, c29, c2a, c2b
	.byte	0x79, 44
	.byte	\key_transpose, \main_out_eq_low, \c02, \main_out_eq_high, \c04, \effect_output_select, \c06, \c07, \c08, \c09, \c0a, \c0b, \c0c, \c0d, \c0e, \c0f
	.byte	\c10, \c11, \c12, \c13, \c14, \c15, \c16, \c17, \c18, \c19, \c1a, \c1b, \c1c, \c1d, \c1e, \c1f
	.byte	\c20, \c21, \c22, \c23, \c24, \c25, \c26, \c27, \c28, \c29, \c2a, \c2b
	.endm
	.endif
