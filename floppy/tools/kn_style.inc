; kn_style.inc -- the SX-KN6000 / SX-KN7000 style container "TCMP" (.CMP payloads) and its event
; streams, as llvm-mc macros.  Used by the payload sources floppy/tools/kd/kn_tcmp.py writes.
;
; Evidence (KN7000 program 941, kn7000/kn7000_manual.sym, the two "TCMP" STYLE CONTAINER sections):
;   header      MemStyleAreaSignatureVerify 0x48435749, MemStyleAreaChecksumVerify 0x484356BD,
;               MemStyleAllocOffsetGet 0x48435564 (+0x13), MemStyleAreaHeaderRestamp 0x48435336
;   style rec   MemStyleRecPtr 0x484355E2 (+0x70 + style*0x80), MemStyleRecInit 0x484353AF (+0x50)
;   var rec     MemStyleVarRecPtr 0x484355F8 (+0x70 + N*0x80 + var*0xE0), MemStyleVarBarCount
;               0x4843C445 (+0x10/+0x11), MemStyleRecData 0x48435611 (+0x15), MemStyleVarRecInit
;               0x484353FE (+0x03 bit 4, +0x04..+0x0B)
;   stream      MemStyleAreaStreamsVerify 0x4843579E (+0 = the variation index, +1 u24BE length,
;               events from +4, F4 first, F5 last), RhyEventLenByStatus 0x484403D5 / RhySysexLen
;               0x484403CD (event lengths)
; All multi-byte fields are big-endian.  The KN6000 writes the same container (its .CMP payloads
; parse identically, notes/floppy-others-2026-10-29/README.md "Styles").

	.ifndef	KN_STYLE_INC
	.set	KN_STYLE_INC, 1

	.macro	be16 v
	.byte	((\v) >> 8) & 0xff, (\v) & 0xff
	.endm
	.macro	be24 v
	.byte	((\v) >> 16) & 0xff, ((\v) >> 8) & 0xff, (\v) & 0xff
	.endm

; The 0x18-byte header proper.  base = the container's first label; top = the label after the last
; stream (the bump-allocator top, MemStyleAllocOffsetGet); length = the u24 at +0x10 (the capacity
; 0x25800 in RAM; a saved file has the used size, MemStyleExportToCustom).
	.macro	tcmp_head base, checksum, csum_start, csum_halfwords, f0e, length, top, nstyles
	.ascii	"TCMP"
	.byte	0, 0
	be16	\checksum			; SumU16BE of the record block (MemStyleAreaChecksumVerify)
	be24	\csum_start
	be24	\csum_halfwords
	be16	\f0e				; copied between containers, not validated
	be24	\length
	be24	(\top) - (\base)		; bump-allocator top
	be16	\nstyles
	.endm

; A style record, 0x80 bytes: the name and the four variation names are 13 characters, each field
; 16 bytes; +0x50 the 20 absolute variation indices the style owns; +0x70 two little-endian u16
; (template 0x0010, 0x0023).  The bytes the firmware is not known to read are spelled as they are (tail_*).
	.macro	tcmp_name text, pad=0
.Ltn\@:
	.ascii	"\text"
	.if	(. - .Ltn\@) - 13
	.error	"tcmp_name: not 13 characters"
	.endif
	.byte	\pad, 0, 0
	.endm

; A variation record, 0xE0 bytes, first 0x20 (the eight part set-ups follow, tcmp_part).
;   kind     +0x00 (0x5A / 0x60 / 0x22 in the factory data; meaning not traced)
;   x01 x02  +0x01, +0x02
;   flags    +0x03: bit 4 = the B half of a paired slot (MemStyleVarRecInit, table 0x485B6D74)
;   p0..p7   +0x04..+0x0B: one byte per part (clamped to 1 for slots >= 12 by MemStyleVarRecInit)
;   x0c..x0f +0x0C..+0x0F
;   bars     +0x10 = bars - 1;  beats: +0x11 low 3 bits = beats a bar - 1 (MemStyleVarBarCount)
;   x12..x14 +0x12..+0x14
;   stream   +0x15 u24BE: the stream's offset in the container (MemStyleRecData)
;   ua ub    +0x18, +0x19 (FF = none, as the built-in records' two sound-unit part numbers; inferred)
;   x1a..x1f +0x1A..+0x1F
	.macro	tcmp_var base, kind, x01, x02, flags, p0, p1, p2, p3, p4, p5, p6, p7, x0c, x0d, x0e, x0f, bars, meter, x12, x13, x14, stream, ua, ub, x1a, x1b, x1c, x1d, x1e, x1f
	.byte	\kind, \x01, \x02, \flags
	.byte	\p0, \p1, \p2, \p3, \p4, \p5, \p6, \p7
	.byte	\x0c, \x0d, \x0e, \x0f
	.byte	(\bars) - 1, \meter
	.byte	\x12, \x13, \x14
	be24	(\stream) - (\base)
	.byte	\ua, \ub, \x1a, \x1b, \x1c, \x1d, \x1e, \x1f
	.endm

; One part set-up, 0x18 bytes: the 24 fields of the firmware's part-field table 0x485B77D4, in its
; order (the built-in styles' 15-byte set-up is fields 0-14, kn7000/notes/ic18-rhythm-rom.md; fields
; 15-23 are CC64, CC1, CC11, channel pressure, pitch bend (two bytes), CC16, CC17, CC13 -- [INFERENCE]
; that a saved variation stores all 24 in that order: the first 15 match the built-in set-ups' value
; pattern, cc94 = 64 and cc96 = 12 in every part).
	.macro	tcmp_part mode, volume, prog, bank_lsb, bank_msb, cc94, reverb, chorus, pan, cc96, cc82, cc83, cc80, cc81, cc92, f15, f16, f17, f18, f19, f20, f21, f22, f23
	.byte	\mode, \volume, \prog, \bank_lsb, \bank_msb, \cc94, \reverb, \chorus, \pan, \cc96
	.byte	\cc82, \cc83, \cc80, \cc81, \cc92
	.byte	\f15, \f16, \f17, \f18, \f19, \f20, \f21, \f22, \f23
	.endm

; A heap object: the owning variation's index, the u24BE event-byte count, then the events.
	.macro	tcmp_stream var, s, e
	.byte	\var
	be24	(\e) - (\s)
	.endm

; Events (RhyEventLenByStatus 0x484403D5): a status byte's low nibble is the part (0-7).
; ev_at: a byte below 0x80, the tick in the beat (0-95, 96 a beat) of the events after it
; ([INFERENCE] kn7000/notes/ic18-rhythm-rom.md: every such byte is 0-95 and they never fall within a
; beat; MemStyleAreaStreamsVerify only steps over it, as one byte).
	.macro	ev_at tick
	.byte	\tick
	.endm
; ev_note: key, velocity, then three bytes ([INFERENCE] a 14-bit length and the chord-adaptation
; class, as kn7000/notes/ic18-rhythm-rom.md reads them).
	.macro	ev_note part, key, velocity, gate_lo, gate_hi, rule
	.byte	0x90 + \part, \key, \velocity, \gate_lo, \gate_hi, \rule
	.endm
	.macro	ev_cc part, ctl, value
	.byte	0xb0 + \part, \ctl, \value
	.endm
	.macro	ev_pc part, prog, bank_lsb, bank_msb
	.byte	0xc0 + \part, \prog, \bank_lsb, \bank_msb
	.endm
	.macro	ev_press part, value
	.byte	0xd0 + \part, \value
	.endm
	.macro	ev_bend part, lsb, msb
	.byte	0xe0 + \part, \lsb, \msb
	.endm
; SysEx: F0, the length of the rest (RhySysexLen), the rest.
	.macro	ev_sysex n, data:vararg
	.byte	0xf0, \n, \data
	.endm
	.macro	ev_beat
	.byte	0xf4
	.endm
	.macro	ev_end
	.byte	0xf5
	.endm
; A status byte RhyEventLenByStatus gives no data bytes (0x8n, 0xAn, 0xF1-F3, F6-FF): one byte.
	.macro	ev_byte b
	.byte	\b
	.endm

	.endif
