; kn_panel.inc -- the SX-KN6000 / SX-KN7000 panel memories (.PMT, .LSW payloads), as llvm-mc macros.
; Used by the payload sources floppy/tools/kd/kn_panel.py writes; its docstring gives the layout.
; A panel memory is a list of tag/length records ended by FF FF, the shape of the KN5000's
; PanelTlv blocks (floppy/kn5000/include/kn5000_files.inc, panel_tlv); on these two models the
; list is 42 records (KN6000) or 43 (KN7000).
; [INFERENCE] measured on the disks; no KN6000/KN7000 panel-memory routine is traced yet.

	.ifndef	KN_PANEL_INC
	.set	KN_PANEL_INC, 1

	.macro	kp_tlv tag, len
	.byte	\tag, \len
	.endm
	.macro	kp_end
	.byte	0xff, 0xff
	.endm
; Record 0x40, 18 bytes: the memory's 16-character name and two bytes.
	.macro	kp_name text, b16, b17
	.byte	0x40, 18
.Lkpn\@:
	.ascii	"\text"
	.if	(. - .Lkpn\@) - 16
	.error	"kp_name: not 16 characters"
	.endif
	.byte	\b16, \b17
	.endm

	.endif

; .LSW part 2: per rhythm, eight {program, bank LSB, bank MSB} sound references ([INFERENCE]: the count,
; 200 on the KN6000 and 220 on the KN7000, is each model's rhythm count, kn7000/notes/ic18-rhythm-rom.md;
; eight parts as a style's eight part set-ups).  ls_refs writes one rhythm's 24 bytes.
	.ifndef	KN_PANEL_LSW2
	.set	KN_PANEL_LSW2, 1
	.macro	ls_refs p0, b0, m0, p1, b1, m1, p2, b2, m2, p3, b3, m3, p4, b4, m4, p5, b5, m5, p6, b6, m6, p7, b7, m7
	.byte	\p0, \b0, \m0, \p1, \b1, \m1, \p2, \b2, \m2, \p3, \b3, \m3
	.byte	\p4, \b4, \m4, \p5, \b5, \m5, \p6, \b6, \m6, \p7, \b7, \m7
	.endm
	.endif
