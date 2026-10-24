

; --------------------------------------------------------------------------
; ParamImage_CopyToSongWorkspace
; Called from: T_ParamImage_CopyToSongWorkspace (x1); far site 0xF42660
; Touches:   |  0x603600
; Evidence: thunk slot T_ParamImage_CopyToSongWorkspace holds `jp 0x00F38800`, and 0xF38800 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ParamImage_CopyToSongWorkspace: Copies the parameter image 0x7600-0x7FFF (0x500 words, count in (0x609102)) into the
;   song workspace at 0x603600-0x603FFF. The copy step of BStore_Workspace_StoreParamImage (after
;   SysPartMidi_ResetBlock1Default). Basis: caller + body. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
ParamImage_CopyToSongWorkspace:		; <- T_ParamImage_CopyToSongWorkspace
	link XIZ,0xfffc	; F38800  link XIZ,0xfffc
	push	xix	; F38804  push XIX
	ldw	bc, 30208	; F38805  ld BC,0x7600
	exts	xbc	; F38808  exts XBC
	ld	(xiz-4), xbc	; F3880A  ld (XIZ+0xfc),XBC
	ld	xix, 6305280	; F3880D  ld XIX,0x00603600
	ldw	(6328578:24), 0	; F38812  ld (0x609102),0x0000
Divide32_Unsigned_Remainder_Join:
	ld	bc, (6328578:24)	; F38819  ld BC,(0x609102)
	extz	xbc	; F3881E  extz XBC
	cp	xbc, 1280	; F38820  cp XBC,0x00000500
	jr	nc, Divide32_Unsigned_Remainder_Skip2	; F38826  jr NC,0xf3883f
	ld	xbc, (xiz-4)	; F38828  ld XBC,(XIZ+0xfc)
	ld	wa, (xbc)	; F3882B  ld WA,(XBC)
	ld	(xix), wa	; F3882D  ld (XIX),WA
	sub	xbc, xbc	; F3882F  sub XBC,XBC
	inc	2, xbc	; F38831  inc 2,XBC
	add	(xiz-4), xbc	; F38833  add (XIZ+0xfc),XBC
	add	xix, xbc	; F38836  add XIX,XBC
	incw	1, (6328578:24)	; F38838  incw 1,(0x609102)
	jr	Divide32_Unsigned_Remainder_Join	; F3883D  jr T,0xf38819
Divide32_Unsigned_Remainder_Skip2:
	pop	xix	; F3883F  pop XIX
	unlk XIZ	; F38840  unlk XIZ
	ret	; F38842  ret

; --------------------------------------------------------------------------
; sub_F38843
; Called from: T_F42664 (x1); far site 0xF42664
; Touches: (0x21E7) (0x2250) (0x7EE2) (0x7EE3) (0x7F05) (0x7FC0)  |  0x603422
; Calls:   T_ParamImage_SnapshotCombinationAndParts_Entry sub_F38A79 sub_F38B8E T_ParamImage_QueueDiffCombinationAndParts T_Queue2C00_DrainPassB T_PanelState_CheckRequestAllowed_2 T_F407A4
;          T_F407A0 T_UiEventList_Publish sub_F389A2
; Evidence: thunk slot T_F42664 holds `jp 0x00F38843`, and 0xF38843 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F38843:		; <- T_F42664
	link XIZ,0xfffb	; F38843  link XIZ,0xfffb
	pushw	hl	; F38847  push HL
	pushw	de	; F38848  push DE
	push	xix	; F38849  push XIX
	lda	xix, (sub_F38A09:24)	; F3884A  lda XIX,0xf38a09
	set	4, (Disk_Flags:16)	; F3884F  set 4,(0x21e7)
	push	xde	; F38853  push XDE
	push	xhl	; F38854  push XHL
	push	xix	; F38855  push XIX
	push	xiz	; F38856  push XIZ
	call	T_ParamImage_SnapshotCombinationAndParts_Entry	; F38857  call 0xf4025c
	pop	xiz	; F3885B  pop XIZ
	pop	xix	; F3885C  pop XIX
	pop	xhl	; F3885D  pop XHL
	pop	xde	; F3885E  pop XDE
	ld	c, (32482:16)	; F3885F  ld C,(0x7ee2)
	ld	(xiz-1), c	; F38863  ld (XIZ+0xff),C
	ld	(xiz-2), (0x7ee3)	; F38866  ld (XIZ+0xfe),(0x7ee3)
	ld	a, (UI_PartIndex:16)	; F3886B  ld A,(0x2250)
	ld	(xiz-3), a	; F3886F  ld (XIZ+0xfd),A
	ld	e, (32517:16)	; F38872  ld E,(0x7f05)
	calr	sub_F38A79	; F38876  calr 0xf38a79
	ldw	bc, 30368	; F38879  ld BC,0x76a0
	sub	bc, 30208	; F3887C  sub BC,0x7600
	pushw	bc	; F38880  push BC
	pushw	0	; F38881  push 0x0000
	lda	xiy, (sub_F38843_Resume:24)	; F38884  lda XIY,0xf3888c
	push	xiy	; F38889  push XIY
	jp	(xix)	; F3888A  jp T,XIX
sub_F38843_Resume:
	ldw	bc, 30880	; F3888C  ld BC,0x78a0
	sub	bc, 30208	; F3888F  sub BC,0x7600
	ld	hl, bc	; F38893  ld HL,BC
	ldw	wa, 30944	; F38895  ld WA,0x78e0
	sub	wa, 30208	; F38898  sub WA,0x7600
	pushw	wa	; F3889C  push WA
	pushw	bc	; F3889D  push BC
	lda	xiy, (sub_F3888C_Resume:24)	; F3889E  lda XIY,0xf388a6
	push	xiy	; F388A3  push XIY
	jp	(xix)	; F388A4  jp T,XIX
sub_F3888C_Resume:
	pushw	2	; F388A6  push 0x0002
	pushw	2276	; F388A9  push 0x08e4
	lda	xiy, (sub_F388A6_Resume:24)	; F388AC  lda XIY,0xf388b4
	push	xiy	; F388B1  push XIY
	jp	(xix)	; F388B2  jp T,XIX
sub_F388A6_Resume:
	ld	d, 0:opc	; F388B4  ld D,0x00
	inc	8, xsp	; F388B6  inc 0,XSP
	inc	4, xsp	; F388B8  inc 4,XSP
Divide32_Unsigned_Remainder_Loop2:
	ld	c, d	; F388BA  ld C,D
	extz	bc	; F388BC  extz BC
	extz	xbc	; F388BE  extz XBC
	add	xbc, BStore_TrackToPart	; F388C0  add XBC,0x00603422
	ld	h, (xbc)	; F388C6  ld H,(XBC)
	cp	h, 7:i3	; F388C8  cp H,7
	jr	ugt, Divide32_Unsigned_Remainder_Skip3	; F388CA  jr UGT,0xf388e0
	ld	c, 64:opc	; F388CC  ld C,0x40
	mul	bc, h	; F388CE  mul BC,H
	sub	bc, 30208	; F388D0  sub BC,0x7600
	ld	(xiz-5), bc	; F388D4  ld (XIZ+0xfb),BC
	ldw	wa, 30368	; F388D7  ld WA,0x76a0
	add	wa, bc	; F388DA  add WA,BC
	ld	hl, wa	; F388DC  ld HL,WA
	jr	Divide32_Unsigned_Remainder_Join2	; F388DE  jr T,0xf388f7
Divide32_Unsigned_Remainder_Skip3:
	cp	h, 31	; F388E0  cp H,0x1f
	jr	ugt, Divide32_Unsigned_Remainder_Skip4	; F388E3  jr UGT,0xf38904
	ld	c, 64:opc	; F388E5  ld C,0x40
	mul	bc, h	; F388E7  mul BC,H
	sub	bc, 30720	; F388E9  sub BC,0x7800
	ld	(xiz-5), bc	; F388ED  ld (XIZ+0xfb),BC
	ldw	wa, 30944	; F388F0  ld WA,0x78e0
	add	wa, bc	; F388F3  add WA,BC
	ld	hl, wa	; F388F5  ld HL,WA
Divide32_Unsigned_Remainder_Join2:
	pushw	64	; F388F7  push 0x0040
	pushw	hl	; F388FA  push HL
	lda	xiy, (sub_F388B4_Resume:24)	; F388FB  lda XIY,0xf38903
	push	xiy	; F38900  push XIY
	jp	(xix)	; F38901  jp T,XIX
sub_F388B4_Resume:
	pop	xiy	; F38903  pop XIY
Divide32_Unsigned_Remainder_Skip4:
	inc	1, d	; F38904  inc 1,D
	cp	d, 16	; F38906  cp D,0x10
	jr	c, Divide32_Unsigned_Remainder_Loop2	; F38909  jr C,0xf388ba
	ld	h, (32704:16)	; F3890B  ld H,(0x7fc0)
	res	1, (0x7fc0:16)	; F3890F  res 1,(0x7fc0)
	calr	sub_F38B8E	; F38913  calr 0xf38b8e
	ld	(32704:16), h	; F38916  ld (0x7fc0),H
	ld	c, (xiz-1)	; F3891A  ld C,(XIZ+0xff)
	ld	(32482:16), c	; F3891D  ld (0x7ee2),C
	ld	c, (xiz-2)	; F38921  ld C,(XIZ+0xfe)
	ld	(32483:16), c	; F38924  ld (0x7ee3),C
	ld	a, (xiz-3)	; F38928  ld A,(XIZ+0xfd)
	ld	(UI_PartIndex:16), a	; F3892B  ld (0x2250),A
	ld	(32517:16), e	; F3892F  ld (0x7f05),E
	push	xde	; F38933  push XDE
	push	xhl	; F38934  push XHL
	push	xix	; F38935  push XIX
	push	xiz	; F38936  push XIZ
	call	T_ParamImage_QueueDiffCombinationAndParts	; F38937  call 0xf40258
	pop	xiz	; F3893B  pop XIZ
	pop	xix	; F3893C  pop XIX
	pop	xhl	; F3893D  pop XHL
	pop	xde	; F3893E  pop XDE
	push	xde	; F3893F  push XDE
	push	xhl	; F38940  push XHL
	push	xix	; F38941  push XIX
	push	xiz	; F38942  push XIZ
	call	T_Queue2C00_DrainPassB	; F38943  call 0xf40038
	pop	xiz	; F38947  pop XIZ
	pop	xix	; F38948  pop XIX
	pop	xhl	; F38949  pop XHL
	pop	xde	; F3894A  pop XDE
	push	xde	; F3894B  push XDE
	push	xhl	; F3894C  push XHL
	push	xix	; F3894D  push XIX
	push	xiz	; F3894E  push XIZ
	call	T_PanelState_CheckRequestAllowed_2	; F3894F  call 0xf40f4c
	pop	xiz	; F38953  pop XIZ
	pop	xix	; F38954  pop XIX
	pop	xhl	; F38955  pop XHL
	pop	xde	; F38956  pop XDE
	push	xde	; F38957  push XDE
	push	xhl	; F38958  push XHL
	push	xix	; F38959  push XIX
	push	xiz	; F3895A  push XIZ
	call	T_F407A4	; F3895B  call 0xf407a4
	pop	xiz	; F3895F  pop XIZ
	pop	xix	; F38960  pop XIX
	pop	xhl	; F38961  pop XHL
	pop	xde	; F38962  pop XDE
	push	xde	; F38963  push XDE
	push	xhl	; F38964  push XHL
	push	xix	; F38965  push XIX
	push	xiz	; F38966  push XIZ
	call	T_F407A0	; F38967  call 0xf407a0
	pop	xiz	; F3896B  pop XIZ
	pop	xix	; F3896C  pop XIX
	pop	xhl	; F3896D  pop XHL
	pop	xde	; F3896E  pop XDE
	push	xde	; F3896F  push XDE
	push	xhl	; F38970  push XHL
	push	xix	; F38971  push XIX
	push	xiz	; F38972  push XIZ
	call	T_UiEventList_Publish	; F38973  call 0xf40f50
	pop	xiz	; F38977  pop XIZ
	pop	xix	; F38978  pop XIX
	pop	xhl	; F38979  pop XHL
	pop	xde	; F3897A  pop XDE
	push	xde	; F3897B  push XDE
	push	xhl	; F3897C  push XHL
	push	xix	; F3897D  push XIX
	push	xiz	; F3897E  push XIZ
	call	T_Queue2C00_DrainPassB	; F3897F  call 0xf40038
	pop	xiz	; F38983  pop XIZ
	pop	xix	; F38984  pop XIX
	pop	xhl	; F38985  pop XHL
	pop	xde	; F38986  pop XDE
	pushw	0	; F38987  push 0x0000
	pushw	4	; F3898A  push 0x0004
	pushw	3	; F3898D  push 0x0003
	pushw	145	; F38990  push 0x0091
	calr	sub_F389A2	; F38993  calr 0xf389a2
	res	4, (Disk_Flags:16)	; F38996  res 4,(0x21e7)
	inc	8, xsp	; F3899A  inc 0,XSP
	pop	xix	; F3899C  pop XIX
	popw	de	; F3899D  pop DE
	popw	hl	; F3899E  pop HL
	unlk XIZ	; F3899F  unlk XIZ
	ret	; F389A1  ret

; --------------------------------------------------------------------------
; sub_F389A2
; Called from: in-module: 0xF38993
; Touches:   |  0x603600
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF389A2 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F389A2:
	link XIZ,0x0000	; F389A2  link XIZ,0x0000
	pushw	hl	; F389A6  push HL
	pushw	de	; F389A7  push DE
	push	xix	; F389A8  push XIX
	lda	xix, (11776:16)	; F389A9  lda XIX,0x2e00
	ld	hl, (6352900:24)	; F389AD  ld HL,(0x60f004)
	cpw	(0x60f004:24), 0x00fb	; F389B2  cp (0x60f004),0x00fb
	jr	nc, sub_F389A2_Skip	; F389B9  jr NC,0xf38a03
	ld	de, hl	; F389BB  ld DE,HL
	ld	bc, ix	; F389BD  ld BC,IX
	extz	xbc	; F389BF  extz XBC
	add	bc, de	; F389C1  add BC,DE
	ld	a, (xiz+8)	; F389C3  ld A,(XIZ+0x08)
	ld	(xbc), a	; F389C6  ld (XBC),A
	ld	bc, de	; F389C8  ld BC,DE
	inc	1, bc	; F389CA  inc 1,BC
	extz	xbc	; F389CC  extz XBC
	add	bc, ix	; F389CE  add BC,IX
	ld	a, (xiz+10)	; F389D0  ld A,(XIZ+0x0a)
	ld	(xbc), a	; F389D3  ld (XBC),A
	ld	bc, de	; F389D5  ld BC,DE
	inc	2, bc	; F389D7  inc 2,BC
	extz	xbc	; F389D9  extz XBC
	add	bc, ix	; F389DB  add BC,IX
	ld	a, (xiz+12)	; F389DD  ld A,(XIZ+0x0c)
	ld	(xbc), a	; F389E0  ld (XBC),A
	ld	bc, de	; F389E2  ld BC,DE
	inc	3, bc	; F389E4  inc 3,BC
	extz	xbc	; F389E6  extz XBC
	add	bc, ix	; F389E8  add BC,IX
	ld	a, (xiz+14)	; F389EA  ld A,(XIZ+0x0e)
	ld	(xbc), a	; F389ED  ld (XBC),A
	ld	bc, de	; F389EF  ld BC,DE
	inc	4, bc	; F389F1  inc 4,BC
	extz	xbc	; F389F3  extz XBC
	add	bc, ix	; F389F5  add BC,IX
	ld	(xbc), 255	; F389F7  ld (XBC),0xff
	ld	bc, hl	; F389FA  ld BC,HL
	inc	4, bc	; F389FC  inc 4,BC
	ld	(6352900:24), bc	; F389FE  ld (0x60f004),BC
sub_F389A2_Skip:
	pop	xix	; F38A03  pop XIX
	popw	de	; F38A04  pop DE
	popw	hl	; F38A05  pop HL
	unlk XIZ	; F38A06  unlk XIZ
	ret	; F38A08  ret
sub_F38A09:
	link XIZ,0xfffc	; F38A09  link XIZ,0xfffc
	pushw	hl	; F38A0D  push HL
	push	xix	; F38A0E  push XIX
	ld	hl, (xiz+10)	; F38A0F  ld HL,(XIZ+0x0a)
	ld	bc, (xiz+8)	; F38A12  ld BC,(XIZ+0x08)
	extz	xbc	; F38A15  extz XBC
	add	xbc, 6305280	; F38A17  add XBC,0x00603600
	ld	(xiz-4), xbc	; F38A1D  ld (XIZ+0xfc),XBC
	ld	wa, (xiz+8)	; F38A20  ld WA,(XIZ+0x08)
	add	wa, 30208	; F38A23  add WA,0x7600
	extz	xwa	; F38A27  extz XWA
	ld	xix, xwa	; F38A29  ld XIX,XWA
	ld	iy, hl	; F38A2B  ld IY,HL
	srl	iy, 1	; F38A2D  srl 0x01,IY
	ld	hl, iy	; F38A30  ld HL,IY
	ldw	(6328578:24), 0	; F38A32  ld (0x609102),0x0000
	jr	sub_F389A2_Join	; F38A39  jr T,0xf38a50
sub_F389A2_Loop:
	ld	xbc, (xiz-4)	; F38A3B  ld XBC,(XIZ+0xfc)
	ld	wa, (xbc)	; F38A3E  ld WA,(XBC)
	ld	(xix), wa	; F38A40  ld (XIX),WA
	sub	xbc, xbc	; F38A42  sub XBC,XBC
	inc	2, xbc	; F38A44  inc 2,XBC
	add	(xiz-4), xbc	; F38A46  add (XIZ+0xfc),XBC
	add	xix, xbc	; F38A49  add XIX,XBC
	incw	1, (6328578:24)	; F38A4B  incw 1,(0x609102)
sub_F389A2_Join:
	ld	bc, (6328578:24)	; F38A50  ld BC,(0x609102)
	cp	bc, hl	; F38A55  cp BC,HL
	jr	c, sub_F389A2_Loop	; F38A57  jr C,0xf38a3b
	pop	xix	; F38A59  pop XIX
	popw	hl	; F38A5A  pop HL
	unlk XIZ	; F38A5B  unlk XIZ
	ret	; F38A5D  ret
	link XIZ,0x0000	; F38A5E  link XIZ,0x0000
	push	xix	; F38A62  push XIX
	ld	xix, (IndexedTable_Base:24)	; F38A63  ld XIX,(0x60f018)
	ld	c, 4:opc	; F38A68  ld C,0x04
	mul	bc, (xiz+8)	; F38A6A  mul BC,(XIZ+0x08)
	extz	xbc	; F38A6D  extz XBC
	add	xbc, xix	; F38A6F  add XBC,XIX
	ld	xwa, (xbc)	; F38A71  ld XWA,(XBC)
	ld	xiy, xwa	; F38A73  ld XIY,XWA
	pop	xix	; F38A75  pop XIX
	unlk XIZ	; F38A76  unlk XIZ
	ret	; F38A78  ret

; --------------------------------------------------------------------------
; sub_F38A79
; Called from: in-module: 0xF38876
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF38A79 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F38A79:
	link XIZ,0xfffb	; F38A79  link XIZ,0xfffb
	pushw	hl	; F38A7D  push HL
	pushw	de	; F38A7E  push DE
	push	xix	; F38A7F  push XIX
	lda	xix, (sub_F38B3A:24)	; F38A80  lda XIX,0xf38b3a
	ldw	(6328580:24), 0	; F38A85  ld (0x609104),0x0000
	ldw	hl, 30383	; F38A8C  ld HL,0x76af
	ldw	de, 30417	; F38A8F  ld DE,0x76d1
	ld	(xiz-1), 8	; F38A92  ld (XIZ+0xff),0x08
sub_F38A79_Loop:
	pushw	9	; F38A96  push 0x0009
	ld	(xiz-3), hl	; F38A99  ld (XIZ+0xfd),HL
	pushw	(xiz-3)	; F38A9C  pushw (XIZ+0xfd)
	lda	xiy, (sub_F38A79_Resume:24)	; F38A9F  lda XIY,0xf38aa7
	push	xiy	; F38AA4  push XIY
	jp	(xix)	; F38AA5  jp T,XIX
sub_F38A79_Resume:
	pushw	9	; F38AA7  push 0x0009
	ld	(xiz-5), de	; F38AAA  ld (XIZ+0xfb),DE
	pushw	(xiz-5)	; F38AAD  pushw (XIZ+0xfb)
	lda	xiy, (sub_F38AA7_Resume:24)	; F38AB0  lda XIY,0xf38ab8
	push	xiy	; F38AB5  push XIY
	jp	(xix)	; F38AB6  jp T,XIX
sub_F38AA7_Resume:
	ld	hl, (xiz-3)	; F38AB8  ld HL,(XIZ+0xfd)
	add	hl, 64	; F38ABB  add HL,0x0040
	ld	de, (xiz-5)	; F38ABF  ld DE,(XIZ+0xfb)
	add	de, 64	; F38AC2  add DE,0x0040
	decm8	1, (xiz-1)	; F38AC6  dec 1,(XIZ+0xff)
	inc	8, xsp	; F38AC9  inc 0,XSP
	cp	(xiz-1), 0x00	; F38ACB  cp (XIZ+0xff),0x00
	jr	nz, sub_F38A79_Loop	; F38ACF  jr NZ,0xf38a96
	ldw	hl, 30959	; F38AD1  ld HL,0x78ef
	ldw	de, 30993	; F38AD4  ld DE,0x7911
	ld	(xiz-1), 24	; F38AD7  ld (XIZ+0xff),0x18
sub_F38A79_Loop2:
	pushw	9	; F38ADB  push 0x0009
	ld	(xiz-3), hl	; F38ADE  ld (XIZ+0xfd),HL
	pushw	(xiz-3)	; F38AE1  pushw (XIZ+0xfd)
	lda	xiy, (sub_F38AB8_Resume:24)	; F38AE4  lda XIY,0xf38aec
	push	xiy	; F38AE9  push XIY
	jp	(xix)	; F38AEA  jp T,XIX
sub_F38AB8_Resume:
	pushw	9	; F38AEC  push 0x0009
	ld	(xiz-5), de	; F38AEF  ld (XIZ+0xfb),DE
	pushw	(xiz-5)	; F38AF2  pushw (XIZ+0xfb)
	lda	xiy, (sub_F38AEC_Resume:24)	; F38AF5  lda XIY,0xf38afd
	push	xiy	; F38AFA  push XIY
	jp	(xix)	; F38AFB  jp T,XIX
sub_F38AEC_Resume:
	ld	hl, (xiz-3)	; F38AFD  ld HL,(XIZ+0xfd)
	add	hl, 64	; F38B00  add HL,0x0040
	ld	de, (xiz-5)	; F38B04  ld DE,(XIZ+0xfb)
	add	de, 64	; F38B07  add DE,0x0040
	decm8	1, (xiz-1)	; F38B0B  dec 1,(XIZ+0xff)
	inc	8, xsp	; F38B0E  inc 0,XSP
	cp	(xiz-1), 0x00	; F38B10  cp (XIZ+0xff),0x00
	jr	nz, sub_F38A79_Loop2	; F38B14  jr NZ,0xf38adb
	pushw	11	; F38B16  push 0x000b
	pushw	MidiCfg_ModeBits	; F38B19  push 0x7f32
	lda	xiy, (sub_F38AFD_Resume:24)	; F38B1C  lda XIY,0xf38b24
	push	xiy	; F38B21  push XIY
	jp	(xix)	; F38B22  jp T,XIX
sub_F38AFD_Resume:
	pushw	1	; F38B24  push 0x0001
	pushw	32589	; F38B27  push 0x7f4d
	lda	xiy, (sub_F38B24_Resume:24)	; F38B2A  lda XIY,0xf38b32
	push	xiy	; F38B2F  push XIY
	jp	(xix)	; F38B30  jp T,XIX
sub_F38B24_Resume:
	inc	8, xsp	; F38B32  inc 0,XSP
	pop	xix	; F38B34  pop XIX
	popw	de	; F38B35  pop DE
	popw	hl	; F38B36  pop HL
	unlk XIZ	; F38B37  unlk XIZ
	ret	; F38B39  ret
sub_F38B3A:
	link XIZ,0xfff4	; F38B3A  link XIZ,0xfff4
	pushw	hl	; F38B3E  push HL
	push	xix	; F38B3F  push XIX
	ld	bc, (xiz+8)	; F38B40  ld BC,(XIZ+0x08)
	extz	xbc	; F38B43  extz XBC
	ld	(xiz-8), xbc	; F38B45  ld (XIZ+0xf8),XBC
	lda	xwa, (6328582:24)	; F38B48  lda XWA,0x609106
	ld	(xiz-12), xwa	; F38B4D  ld (XIZ+0xf4),XWA
	ld	iy, (6328580:24)	; F38B50  ld IY,(0x609104)
	extz	xiy	; F38B55  extz XIY
	add	xwa, xiy	; F38B57  add XWA,XIY
	ld	(xiz-4), xwa	; F38B59  ld (XIZ+0xfc),XWA
	ld	xix, 0	; F38B5C  ld XIX,0x00000000
sub_F38A79_Join:
	ld	bc, (xiz+10)	; F38B61  ld BC,(XIZ+0x0a)
	extz	xbc	; F38B64  extz XBC
	cp	xbc, xix	; F38B66  cp XBC,XIX
	jr	ule, sub_F38A79_Skip	; F38B68  jr ULE,0xf38b89
	ld	xbc, (xiz-8)	; F38B6A  ld XBC,(XIZ+0xf8)
	ld	a, (xbc)	; F38B6D  ld A,(XBC)
	ld	h, a	; F38B6F  ld H,A
	ld	xwa, (xiz-4)	; F38B71  ld XWA,(XIZ+0xfc)
	ld	(xwa), h	; F38B74  ld (XWA),H
	sub	xbc, xbc	; F38B76  sub XBC,XBC
	inc	1, xbc	; F38B78  inc 1,XBC
	add	(xiz-8), xbc	; F38B7A  add (XIZ+0xf8),XBC
	add	(xiz-4), xbc	; F38B7D  add (XIZ+0xfc),XBC
	add	(6328580:24), bc	; F38B80  add (0x609104),BC
	add	xix, xbc	; F38B85  add XIX,XBC
	jr	sub_F38A79_Join	; F38B87  jr T,0xf38b61
sub_F38A79_Skip:
	pop	xix	; F38B89  pop XIX
	popw	hl	; F38B8A  pop HL
	unlk XIZ	; F38B8B  unlk XIZ
	ret	; F38B8D  ret

; --------------------------------------------------------------------------
; sub_F38B8E
; Called from: in-module: 0xF38913
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF38B8E is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F38B8E:
	link XIZ,0xfffb	; F38B8E  link XIZ,0xfffb
	pushw	hl	; F38B92  push HL
	pushw	de	; F38B93  push DE
	push	xix	; F38B94  push XIX
	lda	xix, (Unclaimed_F38C4F:24)	; F38B95  lda XIX,0xf38c4f
	ldw	(6328580:24), 0	; F38B9A  ld (0x609104),0x0000
	ldw	hl, 30383	; F38BA1  ld HL,0x76af
	ldw	de, 30417	; F38BA4  ld DE,0x76d1
	ld	(xiz-1), 8	; F38BA7  ld (XIZ+0xff),0x08
sub_F38B8E_Loop:
	pushw	9	; F38BAB  push 0x0009
	ld	(xiz-3), hl	; F38BAE  ld (XIZ+0xfd),HL
	pushw	(xiz-3)	; F38BB1  pushw (XIZ+0xfd)
	lda	xiy, (sub_F38B8E_Resume:24)	; F38BB4  lda XIY,0xf38bbc
	push	xiy	; F38BB9  push XIY
	jp	(xix)	; F38BBA  jp T,XIX
sub_F38B8E_Resume:
	pushw	9	; F38BBC  push 0x0009
	ld	(xiz-5), de	; F38BBF  ld (XIZ+0xfb),DE
	pushw	(xiz-5)	; F38BC2  pushw (XIZ+0xfb)
	lda	xiy, (sub_F38BBC_Resume:24)	; F38BC5  lda XIY,0xf38bcd
	push	xiy	; F38BCA  push XIY
	jp	(xix)	; F38BCB  jp T,XIX
sub_F38BBC_Resume:
	ld	hl, (xiz-3)	; F38BCD  ld HL,(XIZ+0xfd)
	add	hl, 64	; F38BD0  add HL,0x0040
	ld	de, (xiz-5)	; F38BD4  ld DE,(XIZ+0xfb)
	add	de, 64	; F38BD7  add DE,0x0040
	decm8	1, (xiz-1)	; F38BDB  dec 1,(XIZ+0xff)
	inc	8, xsp	; F38BDE  inc 0,XSP
	cp	(xiz-1), 0x00	; F38BE0  cp (XIZ+0xff),0x00
	jr	nz, sub_F38B8E_Loop	; F38BE4  jr NZ,0xf38bab
	ldw	hl, 30959	; F38BE6  ld HL,0x78ef
	ldw	de, 30993	; F38BE9  ld DE,0x7911
	ld	(xiz-1), 24	; F38BEC  ld (XIZ+0xff),0x18
sub_F38B8E_Loop2:
	pushw	9	; F38BF0  push 0x0009
	ld	(xiz-3), hl	; F38BF3  ld (XIZ+0xfd),HL
	pushw	(xiz-3)	; F38BF6  pushw (XIZ+0xfd)
	lda	xiy, (sub_F38BCD_Resume:24)	; F38BF9  lda XIY,0xf38c01
	push	xiy	; F38BFE  push XIY
	jp	(xix)	; F38BFF  jp T,XIX
sub_F38BCD_Resume:
	pushw	9	; F38C01  push 0x0009
	ld	(xiz-5), de	; F38C04  ld (XIZ+0xfb),DE
	pushw	(xiz-5)	; F38C07  pushw (XIZ+0xfb)
	lda	xiy, (sub_F38C01_Resume:24)	; F38C0A  lda XIY,0xf38c12
	push	xiy	; F38C0F  push XIY
	jp	(xix)	; F38C10  jp T,XIX
sub_F38C01_Resume:
	ld	hl, (xiz-3)	; F38C12  ld HL,(XIZ+0xfd)
	add	hl, 64	; F38C15  add HL,0x0040
	ld	de, (xiz-5)	; F38C19  ld DE,(XIZ+0xfb)
	add	de, 64	; F38C1C  add DE,0x0040
	decm8	1, (xiz-1)	; F38C20  dec 1,(XIZ+0xff)
	inc	8, xsp	; F38C23  inc 0,XSP
	cp	(xiz-1), 0x00	; F38C25  cp (XIZ+0xff),0x00
	jr	nz, sub_F38B8E_Loop2	; F38C29  jr NZ,0xf38bf0
	pushw	11	; F38C2B  push 0x000b
	pushw	MidiCfg_ModeBits	; F38C2E  push 0x7f32
	lda	xiy, (sub_F38C12_Resume:24)	; F38C31  lda XIY,0xf38c39
	push	xiy	; F38C36  push XIY
	jp	(xix)	; F38C37  jp T,XIX
sub_F38C12_Resume:
	pushw	1	; F38C39  push 0x0001
	pushw	32589	; F38C3C  push 0x7f4d
	lda	xiy, (sub_F38C39_Resume:24)	; F38C3F  lda XIY,0xf38c47
	push	xiy	; F38C44  push XIY
	jp	(xix)	; F38C45  jp T,XIX
sub_F38C39_Resume:
	inc	8, xsp	; F38C47  inc 0,XSP
	pop	xix	; F38C49  pop XIX
	popw	de	; F38C4A  pop DE
	popw	hl	; F38C4B  pop HL
	unlk XIZ	; F38C4C  unlk XIZ
	ret	; F38C4E  ret

; --------------------------------------------------------------------------
; Unclaimed_F38C4F -- 176 bytes that decode as code and are deliberately NOT
;                     claimed as code.  Nothing in either image references any
;                     address inside them, so the layout has no entry point to
;                     start a walk from, and this tree does not promote a run
;                     to code on the strength of a decode alone.
; Decodes as: ONE `link XIZ,0xfff4` prologue, at 0xF38C4F, and THREE `unlk
;             XIZ` opcode pairs, at 0xF38CA0 0xF38CED 0xF38CFD -- so two of
;             the three bodies have no prologue of their own inside this run.
;             And the longest repeated byte run inside it is 77 bytes long, at
;             0xF38C56 and 0xF38CA3: the same code twice, which is what a
;             compiler emits for two copies of one function.
; Evidence: the `link`/`unlk` opcode pairs are re-scanned over
;           0xF38C4F-0xF38CFE on every emit and the repeated run is re-
;           measured by an O(n^2) search; neither is typed in.  ⚠ AND THE
;           FIRST DRAFT OF THIS HEADER WAS WRONG ABOUT BOTH: it said three
;           `link` prologues (there is one) and a 76-byte repeat at 0xF38C53
;           (it is 77 bytes at 0xF38C56).  --selftest now pins the measured
;           values.  What this region needs is a REFERENCE, not a better
;           decoder.
; Unknown: who calls any of it.  Kept as `.byte` and a FRAMED name.
; --------------------------------------------------------------------------
Unclaimed_F38C4F:
	.byte	0xEE, 0x0C, 0xF4, 0xFF, 0x2B, 0x3C, 0xF2, 0x06, 0x91, 0x60, 0x31, 0xBE, 0xF4, 0x61, 0xD2, 0x04	; F38C4F  |....+<...`1..a..|
	.byte	0x91, 0x60, 0x20, 0xE8, 0x12, 0xE8, 0x81, 0xBE, 0xF8, 0x61, 0x9E, 0x08, 0x20, 0xE8, 0x12, 0xBE	; F38C5F  |.` ......a.. ...|
	.byte	0xFC, 0x60, 0x44, 0x00, 0x00, 0x00, 0x00, 0x9E, 0x0A, 0x21, 0xE9, 0x12, 0xEC, 0xF1, 0x63, 0x1F	; F38C6F  |.`D......!....c.|
	.byte	0xAE, 0xF8, 0x21, 0x81, 0x21, 0xC9, 0x8E, 0xAE, 0xFC, 0x20, 0xB0, 0x46, 0xE9, 0xA1, 0xE9, 0x61	; F38C7F  |..!.!.... .F...a|
	.byte	0xAE, 0xF8, 0x89, 0xAE, 0xFC, 0x89, 0xD2, 0x04, 0x91, 0x60, 0x89, 0xE9, 0x84, 0x68, 0xD8, 0x5C	; F38C8F  |.........`...h.\|
	.byte	0x4B, 0xEE, 0x0D, 0x0E, 0x06, 0x91, 0x60, 0x31, 0xBE, 0xF4, 0x61, 0xD2, 0x04, 0x91, 0x60, 0x20	; F38C9F  |K.....`1..a...` |
	.byte	0xE8, 0x12, 0xE8, 0x81, 0xBE, 0xF8, 0x61, 0x9E, 0x08, 0x20, 0xE8, 0x12, 0xBE, 0xFC, 0x60, 0x44	; F38CAF  |......a.. ....`D|
	.byte	0x00, 0x00, 0x00, 0x00, 0x9E, 0x0A, 0x21, 0xE9, 0x12, 0xEC, 0xF1, 0x63, 0x1F, 0xAE, 0xF8, 0x21	; F38CBF  |......!....c...!|
	.byte	0x81, 0x21, 0xC9, 0x8E, 0xAE, 0xFC, 0x20, 0xB0, 0x46, 0xE9, 0xA1, 0xE9, 0x61, 0xAE, 0xF8, 0x89	; F38CCF  |.!.... .F...a...|
	.byte	0xAE, 0xFC, 0x89, 0xD2, 0x04, 0x91, 0x60, 0x89, 0xE9, 0x84, 0x68, 0xD8, 0x5C, 0x4B, 0xEE, 0x0D	; F38CDF  |......`...h.\K..|
	.byte	0x0E, 0xFC, 0x89, 0xD2, 0x04, 0x91, 0x60, 0x89, 0xE9, 0x84, 0x68, 0xD8, 0x5C, 0x4B, 0xEE, 0x0D	; F38CEF  |......`...h.\K..|

	.fill	769, 1, 0x0E	; F38CFF-F38FFF  `ret` padding (asserted pure 0x0E)
