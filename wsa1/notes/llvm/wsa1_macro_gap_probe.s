; wsa1_macro_gap_probe.s -- which spellings the pinned llvm-mc has for the three forms
; wsa1/include/tlcs900_mem_ops.inc still has to emit as bytes (2026-10-24).
;
; RUN:  ~/compartilhado/llvm-project/build/bin/llvm-mc -triple=tlcs900 -show-encoding \
;           wsa1/notes/llvm/wsa1_macro_gap_probe.s
;
; EXPECTED with tlcs900_backend@a3a81863f87d: the first three lines assemble (the
; siblings that DO exist), every line after them is refused.  A line below the marker
; that starts to assemble means the gap has closed: re-run
;   python3 scripts/converters/respell_wsa1_macros.py --family regdirect --apply
; after adding its spelling to rd_candidates() there.
;
; The second group is a warning, not a gap: these "register names" are NOT names to
; this backend.  llvm-mc reads each as an undefined SYMBOL and assembles `ld a, <imm>`
; (c9 03 00) / `ld de, <imm>` -- a silent wrong encoding that only a byte comparison
; catches.  The register-file address therefore stays a number (`ldto_berp a, 0x3c`).

	addb_erp	a, 0x3d		; c7 3d 81   add A,RH3      (byte: exists)
	addw_erp	wa, 0x3e	; d7 3e 80   add WA,QHL3    (word: exists)
	stcfw_erp	0x3e		; d7 3e 2c   stcf A,QHL3    (word: exists)
; ---- gaps: each line below is refused --------------------------------------------
	addl_erp	xhl, 0x38	; e7 38 83   add XHL,XDE3   (m_rd_add_rrx RLX)
	add_lerp	xhl, 0x38
	ldcfb_erp	0x3d		; c7 3d 2b   ldcf A,RH3     (m_rd_ldcf_ax RBX)
	ldcf_berp	0x3d
	stcfb_erp	0x3d		; c7 3d 2c   stcf A,RH3     (m_rd_stcf_ax RBX)
	stcf_berp	0x3d
	ldcf		a, rh3
	stcf		a, rh3
	add		xhl, xde3
; ---- not register names (assemble WRONG, see above) -----------------------------
;	ld	a, iyl
;	ld	a, rl3
;	ld	de, qhl3
