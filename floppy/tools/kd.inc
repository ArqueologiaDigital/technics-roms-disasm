; kd.inc -- the file containers of the SX-KN6000 / SX-KN7000 diskettes, as llvm-mc macros.
;
; Used by the files/<unit>.s that floppy/tools/kd/kd_describe.py writes.  Layout and evidence:
; floppy/tools/kd/kd.py (docstring) and notes/floppy-others-2026-10-29/README.md, "Containers".
; The magic's first byte names the model ('I' KN6000, 'J' KN7000).  The KN7000 program reads these
; headers through its fmm layer (fmmopen / fmmread, kn7000/kn7000_manual.sym 0x48532395..) and the
; payload through zlib 1.0.4's inflate ('I') or the LZSS decoder ('J').
;
;   kd_one   magic, flags, size
;            a one-part file (.CMP .TM .PMT .MSP .EFC): +8 u32 0, +0xc u32 payload size
;   kd_two   magic, flags, size1, size2, s1, e1, s2, e2, hdr
;            a two-part file (.SQT .LSW): +8/+0xc the payload sizes, +0x10/+0x14 the stored sizes
;   k1_head  model, size
;            the 8 bytes every 'I K\1' / 'J K\1' file (.AST .CST) starts with; model = "I" or "J"
;
; s/e (kd_two) are the labels around each stored stream.  hdr is the stored-size bias: 2 for a deflate part
; (the zlib header the file leaves out still counts), 0 for an LZSS part.  The flags word is
; big-endian, the sizes little-endian, as the files have them.

	.ifndef	KD_INC
	.set	KD_INC, 1

	.macro	kd_magic magic
.Lkd_m\@:
	.ascii	"\magic"
	.if	(. - .Lkd_m\@) - 4
	.error	"kd: the magic is not 4 bytes"
	.endif
	.endm

	.macro	kd_one magic, flags, size
	kd_magic	"\magic"
	.byte	0x00, 0x01				; version 1, big-endian
	.byte	(\flags) >> 8, (\flags) & 0xff		; flags, big-endian
	.long	0					; no first part
	.long	\size					; payload size, inflated
	.endm

	.macro	kd_two magic, flags, size1, size2, s1, e1, s2, e2, hdr
	kd_magic	"\magic"
	.byte	0x00, 0x01
	.byte	(\flags) >> 8, (\flags) & 0xff
	.long	\size1, \size2				; payload sizes, inflated
	.long	(\e1) - (\s1) + (\hdr), (\e2) - (\s2) + (\hdr)	; stored sizes
	.endm

	.macro	k1_head model, size
	.ascii	"\model", " K"
	.byte	0x01
	.long	\size					; payload size, inflated
	.endm

	.endif
