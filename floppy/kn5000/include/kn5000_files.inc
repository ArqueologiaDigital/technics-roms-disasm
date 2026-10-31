; kn5000_files.inc -- record macros for the SX-KN5000's own file formats (floppy/kn5000/formats.py).
;
; Each macro spells one record's framing; the payload a record carries follows it at the call
; site.  Formats and evidence: notes/floppy-kn5000-2026-10-29/README.md.

; One 256-byte accompaniment-style cell (CMP and RCM style banks; the IC19 custom-data format,
; docs/accompaniment-style-format.md).  MARK is 0x80 for a cell of a linked chain, 0x00 for an
; unlinked template block.  PREV / NEXT are cell numbers in the bank's own encoding: the low 12
; bits are the cell's block index from the bank's first cell block, the top nibble the section
; tag (section + 1 in IC19; FileIO_LoadRcmToFlash's Pack12BitValueWithBank 0xf1710c stamps it
; on install); 0xffff = none.  Then 249 bytes of events, then style_cell_end.
	.macro	style_cell mark, prev, next
	.byte	\mark
	.short	\prev, \next
	.byte	0x87
	.endm
	.macro	style_cell_end
	.byte	0x87
	.endm

; One 256-byte sequencer event cell (SQT event memory; the .SEQ cell of docs/kn-disk-file-formats.md).
; FLAGS is byte 0 (0x00 marks a block of the free list); PREV / NEXT are ONE-BASED cell numbers
; (value v addresses cell v - 1), PREV 0 = none, NEXT 0xffff = none.  Then 251 bytes of events.
	.macro	seq_cell flags, prev, next
	.byte	\flags
	.short	\prev, \next
	.endm

; One panel record header: tag and payload length.  The firmware's record lists are
; PanelTlv_Block0_Layout / PanelTlv_Block1_Layout (v10/maincpu/ui_widgets/naka_extension_device.c);
; PanelTlv_ValidateBlock0/1 walk them.  Tag 0xff, length 0xff ends a block.
	.macro	panel_tlv tag, len
	.byte	\tag, \len
	.endm

; BITMAPFILEHEADER (14 bytes) and BITMAPINFOHEADER (40 bytes), as stored.
	.macro	bmp_file_header size, res1, res2, offbits
	.ascii	"BM"
	.long	\size
	.short	\res1, \res2
	.long	\offbits
	.endm
	.macro	bmp_info_header width, height, planes, bpp, compression, imgsize, xppm, yppm, clrused, clrimp
	.long	40, \width, \height
	.short	\planes, \bpp
	.long	\compression, \imgsize, \xppm, \yppm, \clrused, \clrimp
	.endm

; ---- IC19 accompaniment events (CMP / RCM style banks), one per line.  Grammar:
; docs/accompaniment-style-format.md; the reader is the firmware's style player (the format the
; IC19 custom-data banks hold, decoded with zero malformed events by scripts/build/style_events.py).
; pos = tick within the beat (96 per beat); a duration is dur_beats * 96 + dur_ticks.
	.macro	st_beat
	.byte	0x81
	.endm
	.macro	st_end
	.byte	0x83
	.endm
	.macro	st_note pos, note, vel, dur_ticks, dur_beats
	.byte	0x90, \pos, \note, \vel, \dur_ticks, \dur_beats
	.endm
; NOTE2: the five note fields and two trailing bytes (range 0..25) whose meaning is not established.
	.macro	st_note2 pos, note, vel, dur_ticks, dur_beats, x1, x2
	.byte	0x91, \pos, \note, \vel, \dur_ticks, \dur_beats, \x1, \x2
	.endm
; Three controller events; what each selects is not established (CTL2 values cluster at 61..64,
; CTL3 is 0 or 127, a switch).
	.macro	st_ctl1 pos, value
	.byte	0xd1, \pos, \value
	.endm
	.macro	st_ctl2 pos, value
	.byte	0xd2, \pos, \value
	.endm
	.macro	st_ctl3 pos, value
	.byte	0xd3, \pos, \value
	.endm
; 0xd4 / 0xd5: two data bytes each, measured on these disks (not in the factory IC19 banks).
	.macro	st_ctl4 pos, value
	.byte	0xd4, \pos, \value
	.endm
	.macro	st_ctl5 pos, value
	.byte	0xd5, \pos, \value
	.endm

; ---- Sequencer (SQT) events, one per line: the demo-song grammar of the factory demo songs
; (scripts/build/demo_preset_to_midi.py).  A status byte has bit 7 set; its data bytes do not.
	.macro	sq_beat
	.byte	0x81
	.endm
; A note: status 0x9n, tick within the beat, note, velocity, dur_ticks, dur_beats.
	.macro	sq_note status, pos, note, vel, dur_ticks, dur_beats
	.byte	\status, \pos, \note, \vel, \dur_ticks, \dur_beats
	.endm
; A further note under the same status byte (running status).
	.macro	sq_run pos, note, vel, dur_ticks, dur_beats
	.byte	\pos, \note, \vel, \dur_ticks, \dur_beats
	.endm
; Any other status with its data bytes (0x82 = end of track); meanings beyond beat, note and end
; are not established.
	.macro	sq_ev status, data:vararg
	.byte	\status
	.ifnb	\data
	.byte	\data
	.endif
	.endm
; Data bytes under no status (the stream's first bytes, or a note group shorter than 5).
	.macro	sq_data data:vararg
	.byte	\data
	.endm

; ---- Style bank header and section records (CMP, RCM sections 0..6, and the IC19 custom-data
; banks).  The layout, the field names and the evidence for each field are in
; scripts/build/style_bank_layout.py, which formats.py and scripts/build/style_events.py both import.
;   password       +0x0e: written by FmmPasswordFunc (EVT_SET_PASSWORD) with the song slots' +0x1c; 0 = none
;   composer_mode  +0x10: 0 NORMAL MODE, 1 EXPAND MODE (AcCmpMdBoxProc, the COMPOSER MODE screen)
	.macro	style_bank_mode password, composer_mode
	.short	\password
	.byte	\composer_mode
	.endm
; The size words at +0x1e..+0x2f; capacity16 and used_size16 count 16-byte units.  used_size16 is
; written by AccPatch_InitSlotChain; cmp_sv_mae returns it * 16 as the .CMP size and
; FileIO_SaveRcmFromFlash reads it for the .RCM chunk lengths.  No reader of the other words was
; found: the firmware hard-codes the same values (0x16800, 0x60, 30, 0x100, 340, 0x40).
	.macro	style_bank_sizes capacity16, dir_offset, record_size, record_count, cell_size, cell_count, name_offset, reserved_2c, used_size16
	.short	\capacity16, \dir_offset, \record_size, \record_count, \cell_size, \cell_count, \name_offset, \reserved_2c, \used_size16
	.endm

; Head of one of the 30 STYLE_SECTION records (a/b/c variation 1-4, then intro, fill-in, ending 1-2):
;   drum_cell .. acc3_cell  the five parts' first cells, (section nibble << 12) | cell entry
;                           (MapBitFlagsToChannelOffset: DRUM +0, BASS +4, ACCOMP1-3 +6/+8/+0xa)
;   reserved_02             the sixth lane's word, never used (0)
;   time_sig                +0x0c, TIME SIGNATURE index (0 = 1/2 .. 7 = 4/4 .. 15 = 4/8)
;   last_measure            +0x0d, MEASURE - 1 (0..7)
;   key, minor, accomp_7th, bass_7th, bit7
;                           +0x0e, the RECORD SETTING rows: KEY (C .. B), CHORD MINOR, ACCOMP TYPE 7th,
;                           BASS TYPE 7th (RhythmPatInit_LoadParams / RhythmProc_CheckConfigBits)
;   edit_flags              +0x0f, bit 7 = MEASURE / TIME SIGNATURE still changeable ("(ENABLE)")
;   style_number, style_group
;                           +0x10, the section's style in PANEL_STYLE's {number, group} format
	.macro	style_section_head drum_cell, reserved_02, bass_cell, acc1_cell, acc2_cell, acc3_cell, time_sig, last_measure, key, minor, accomp_7th, bass_7th, bit7, edit_flags, style_number, style_group
	.short	\drum_cell, \reserved_02, \bass_cell, \acc1_cell, \acc2_cell, \acc3_cell
	.byte	\time_sig, \last_measure
	.byte	\key | (\minor << 4) | (\accomp_7th << 5) | (\bass_7th << 6) | (\bit7 << 7)
	.byte	\edit_flags, \style_number, \style_group
	.endm
; One part's settings, record +0x18 + 8 * part (DRUM, BASS, ACCOMP1, ACCOMP2, ACCOMP3):
;   sound, bank   the part's sound (AccPatch_SyncVoice_* from PANEL_PART_*; DRUM: the kit, 0..15)
;   pan           PANPOT 0..127 (MainCmpSetFunc, EVT_PAN_UP / _DN)
;   digital_effect 0/1, bit 6 of the panel part's +4, SndParam DIGITAL EFFECT (AccPatch_SyncVoice_*)
;   pc_byte4      the fifth byte of the part's program-change record (AccVoice_LoadAllChannelParams)
;                 [INFERENCE: its use in the tone generator was not traced]
;   pitch_point   PITCH POINT 0..11 (MainCmpSetFunc, EVT_RLMT_UP / _DN; Rhythm_TransposeNote)
;   high_key      the note limit Rhythm_Transp_WrapCheck folds transposed notes below (0x7f / 0xff none)
;   reserved_7    0; not in the lane copy
	.macro	style_part sound, bank, pan, digital_effect, pc_byte4, pitch_point, high_key, reserved_7
	.byte	\sound, \bank, \pan, \digital_effect, \pc_byte4, \pitch_point, \high_key, \reserved_7
	.endm
; The section's 16-byte name (+0x40; the pattern source the section came from).
	.macro	style_section_name name
.Lssn\@:
	.ascii	"\name"
.Lsse\@:
	.if	(.Lsse\@ - .Lssn\@) - 16
	.error	"style_section_name: name is not 16 bytes"
	.endif
	.endm
; One of the five COMPOSER CHORD MAPs at +0xba0: the four variations it plays (0..11, 0xff none;
; CmpNcp_StepSlotInGroup2), twelve zero bytes and the 16-byte name.
	.macro	style_chord_map v0, v1, v2, v3, name
	.byte	\v0, \v1, \v2, \v3
	.fill	12, 1, 0
.Lscn\@:
	.ascii	"\name"
.Lsce\@:
	.if	(.Lsce\@ - .Lscn\@) - 16
	.error	"style_chord_map: name is not 16 bytes"
	.endif
	.endm
; One row of the measure-start table at +0xc40 (variation 0..11, part DRUM BASS ACCOMP1-3): for
; measures 1..8 the {cell, offset} where the part's measure starts (AccVoice_GetMeasureStartBlock,
; AccPatch_StoreMeasureCursor).
	.macro	style_measure_starts c1, o1, c2, o2, c3, o3, c4, o4, c5, o5, c6, o6, c7, o7, c8, o8
	.short	\c1, \o1, \c2, \o2, \c3, \o3, \c4, \o4, \c5, \o5, \c6, \o6, \c7, \o7, \c8, \o8
	.endm

; ---- The Sound Arranger memory (RAM 0x1e7800, the last 0x800 bytes of a .LSW): one record per style index
; (AccHelper_ComputeVoiceOffset), the sounds of DRUM, BASS, ACCOMP1, ACCOMP2, ACCOMP3.  Readers and writers:
; AccVoiceState_Snapshot (from PANEL_PART_DRUM .. _ACP3), AccTuning_LoadFromROM (into the lane records 0x3246..),
; AccStyle_InlinedBlock_Skip2 (sets arranged); initial image AccStyle_RamImage_1E7800 (AccStyle_InitVRAM).
;   drum_kit, drum_bank   the DRUM kit (low nibble) and bank (bits 6:0)
;   *_sound, *_bank       the part's sound and bank (bits 6:0)
;   flags                 the five bit-7s: bit 0 = arranged (DRUM bank byte: use these sounds), bits 1..4 = the
;                         DIGITAL EFFECT of BASS, ACCOMP1, ACCOMP2, ACCOMP3 (PANEL_PART_x+4 bit 6)
	.macro	sndarg drum_kit, drum_bank, bass_sound, bass_bank, acc1_sound, acc1_bank, acc2_sound, acc2_bank, acc3_sound, acc3_bank, flags
	.byte	\drum_kit, \drum_bank | ((\flags & 1) << 7)
	.byte	\bass_sound, \bass_bank | (((\flags >> 1) & 1) << 7)
	.byte	\acc1_sound, \acc1_bank | (((\flags >> 2) & 1) << 7)
	.byte	\acc2_sound, \acc2_bank | (((\flags >> 3) & 1) << 7)
	.byte	\acc3_sound, \acc3_bank | (((\flags >> 4) & 1) << 7)
	.endm
