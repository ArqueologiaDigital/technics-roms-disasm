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
