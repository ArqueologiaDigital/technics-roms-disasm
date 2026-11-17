; =============================================================================
; DSP_VoiceParamReadWrite -- Read/write a single DSP parameter
; =============================================================================
; Accesses DSP parameter storage at 0x44FCE + 0x1D8 + param_index.
; If voice is allocated (bit 0 set), reads from single slot.
; Otherwise iterates 4 sub-slots via DSP_VoiceParam_MultiSlot.
; Args: wa = voice number (0-15), bc = param index (0-7),
;       xde = pointer to voice parameter data area
; Called from: sub-commands 0x10-0x17 (DSP param set) in Audio_Process_DSP
; Input WA = part, BC = parameter index, XDE = one-byte result buffer.
; If PART+0x00 bit 0 is set (part allocated), the answer is simply the shadow byte at
; UserTone_VelSplit_Base + 0x1D8 + index.  If the part is NOT allocated it instead surveys
; the part's four operator slots (DSP_VoiceParam_MultiSlot) and only reports a value when
; all four agree.  Called from 0x03193B and from eight consecutive sites in
; AUDIO_PROCESS_DSP (0x035C10..0x035C9C), i.e. it is the main query primitive.
DSP_VoiceParamReadWrite:
	lda xsp, (xsp - 14)
	push xiz
	ld (xsp + 10), xde
	ld (xsp + 14), bc
	ld (xsp + 16), wa
	ldw (xsp + 8), 0x0
	ld wa, (xsp + 16)
	extz xwa
	ld xbc, 0x11F
	call Math_Multiply32
	ld xwa, Part_Record_Base
	add xwa, xhl
	ld wa, (xwa)
	bit 0, wa
	jr z, DSP_VoiceParam_MultiSlot
	ld wa, (xsp + 14)
	extz xwa
	add xwa, 0x1D8
	ld xbc, Payload_Bss_Start+0x6158
	add xbc, xwa
	ld xwa, (xsp + 10)
	ld c, (xbc)
	ld (xwa), c
	jrl DSP_VoiceParamReadWrite_Return

; Part not allocated: zero the match counter at (XSP+0x08) and walk the four slots.
DSP_VoiceParam_MultiSlot:
	ldw (xsp + 6), 0x0
	cpw (xsp + 6), 0x4
	jr nc, DSP_VoiceParam_MultiSlot_CheckResult

; Per slot: skip the slot if (slotptr+0x06) & 0xC0 is non-zero or bit 5 of (slotptr+0x06) is
; set; otherwise increment the match counter.
DSP_VoiceParam_MultiSlot_LoopBody:
	ld wa, (xsp + 6)
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	ld xiz, xhl
	add xiz, 0x6E
	ld wa, (xsp + 16)
	extz xwa
	ld xbc, 0x11F
	call Math_Multiply32
	ld xwa, Part_Record_Base
	add xwa, xhl
	add xwa, xiz
	ld xwa, (xwa)
	ld a, (xwa + 6)
	and a, 0xC0
	jr nz, DSP_VoiceParam_MultiSlot_LoopNext
	ld wa, (xsp + 6)
	extz xwa
	ld xbc, 0x25
	call Math_Multiply32
	ld xiz, xhl
	add xiz, 0x6E
	ld wa, (xsp + 16)
	extz xwa
	ld xbc, 0x11F
	call Math_Multiply32
	ld xwa, Part_Record_Base
	add xwa, xhl
	add xwa, xiz
	ld xwa, (xwa)
	bitm 5, (xwa + 6)
	jr nz, DSP_VoiceParam_MultiSlot_LoopNext
	incw 1, (xsp + 8)

; Advance the slot counter and loop while < 4.
DSP_VoiceParam_MultiSlot_LoopNext:
	incw 1, (xsp + 6)
	cpw (xsp + 6), 0x4
	jr c, DSP_VoiceParam_MultiSlot_LoopBody

; Result = 0 unless all four slots matched, in which case the answer comes from
; DSP_VOICEPARAM_DEFAULT_TABLE (0x00F95D) indexed by the parameter index.
DSP_VoiceParam_MultiSlot_CheckResult:
	ld xde, (xsp + 10)
	ld a, 0x0:opc
	cpw (xsp + 8), 0x4
	jr nz, DSP_VoiceParam_MultiSlot_StoreResult
	ld wa, (xsp + 14)
	extz xwa
	ld xbc, DSP_VOICEPARAM_DEFAULT_TABLE
	add xbc, xwa
	ld a, (xbc)

; Store the byte into the caller's buffer.
DSP_VoiceParam_MultiSlot_StoreResult:
	ld (xde), a

; HL = (XSP+0x04), unwind and return.
DSP_VoiceParamReadWrite_Return:
	ld hl, (xsp + 4)
	pop xiz
	lda xsp, (xsp + 14)
	ret

; Input XDE = one-byte result buffer.  Calls ToneDB_Find_ToneRecord (0x03206F) and returns
; byte +0x5D of that buffer -- the algorithm-type byte this whole region dispatches on.
; Returns HL = 1.  Callers: 0x031966 and AUDIO_PROCESS_DSP 0x035CD4.
DSP_ReadVoiceParam5D:	.include "includes/generated/cc900/DSP_ReadVoiceParam5D.s"	; C: cc900/dsp_voice_params.c

; ----------------------------------------------------------------------------
; DSP_VoiceParam_Dispatch - Voice parameter dispatch with routing type check
; Entry: WA = voice parameter, BC = channel/type, XDE = data pointer
; Notes: Checks bit 5 of IX (from BC) for routing mode dispatch
;        If bit 5 set: uses alternate routing path
;        Otherwise: masks WA to 7 bits, extracts HL from BC bits 4:0,
;        uses 4-way dispatch on BC bits 7:6 for coefficient table selection
;        Computes routing index and copies parameters
; ----------------------------------------------------------------------------
; Input WA = 7-bit index, BC = selector, XDE = destination buffer.  If BC bit 5 is set the
; source is ToneDB_Find_ToneRecord's buffer; if BC bits 5 is clear it is a coefficient row
; selected exactly like DSP_RouteCoeffs_TypeA but through the pointer at (0x045314)+0x7C and
; the row block at (0x045314)+0x0080; any other value of (BC & 0x20) leaves XHL untouched
; from the caller.  Either way 0x0D bytes are copied to the caller's buffer and HL = 0x0D is
; returned.  Caller: 0x03198B.
DSP_VoiceParam_Dispatch:
	push	xiz
	ld	xiz, xde
	ld	ix, bc
	and	ix, 32
	cp	ix, 32
	jr	z, DSP_VoiceParam_Dispatch_UseVoiceBuffer
	cp	ix, 0:i3
	jr	nz, DSP_VoiceParam_Dispatch_Copy
	and	wa, 127
	ld	hl, bc
	and	hl, 31
	and	bc, 192
	cp	bc, 192
	jr	z, DSP_VoiceParam_Dispatch_LoadRowBase
	cp	bc, 128
	jr	z, DSP_VoiceParam_Dispatch_LoadRowBase
	cp	bc, 64
	jr	z, DSP_VoiceParam_Dispatch_LoadRowBase
	cp	bc, 0:i3
	jr	nz, DSP_VoiceParam_Dispatch_ComputeRow
; All four values of (BC & 0xC0) load the same pointer, (0x045314)+0x7C -- the four-way
; compare is vestigial.
DSP_VoiceParam_Dispatch_LoadRowBase:
	ld	xbc, (ToneDB_RootPtr:24)
	ld	xde, (xbc+124)
; row = ((BC & 0x1F) << 7 | (WA & 0x7F)) * 2, then a 16-byte-stride row address.
DSP_VoiceParam_Dispatch_ComputeRow:
	ld	bc, hl
	sll	bc, 7
	add	bc, wa
	add	bc, bc
	ld	wa, bc
	extz	xwa
	add	xwa, xde
	add	xwa, (ToneDB_RelBase:24)
	ld	xwa, (xwa)
	ld	bc, wa
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xde, (xwa+128)
	ld	xwa, (ToneDB_RelBase:24)
	add	xwa, xde
	ld	xde, xwa
	ld	wa, bc
	extz	xwa
	sll	xwa, 4
	add	xwa, xde
	ld	xhl, xwa
	jr	DSP_VoiceParam_Dispatch_Copy
; (BC & 0x20) == 0x20: source is ToneDB_Find_ToneRecord's buffer instead.
DSP_VoiceParam_Dispatch_UseVoiceBuffer:
	call	ToneDB_Find_ToneRecord
; Copy 0x0D bytes from XHL to the caller's buffer (post-increment through XIZ).
DSP_VoiceParam_Dispatch_Copy:
	ldw	wa, 13
	ld	ix, 0:i3
	cp	ix, wa
	jr	nc, DSP_VoiceParam_Dispatch_Return
; Loop body of that copy.
DSP_VoiceParam_Dispatch_CopyLoop:
	lda	xde, (xiz+:1)
	ld	bc, ix
	extz	xbc
	add	xbc, xhl
	ld	c, (xbc)
	ld	(xde), c
	inc	1, ix
	cp	ix, wa
	jr	c, DSP_VoiceParam_Dispatch_CopyLoop
; HL = 0x0D, restore XIZ, return.  This is the last instruction pair of the region.
DSP_VoiceParam_Dispatch_Return:
	ld	hl, wa
	pop	xiz
	ret

; DSP_SetVoiceCoefficients -- v1.40 form (the v1.41 one takes a part and an index instead)
; Copy the 10-byte ToneDB record named by ONE sub-tone reference into a caller-supplied
; buffer.  Nothing here touches a DSP; the name is v1.42's (see the note there).
; Entry: WA = reference low byte lo, BC = reference high byte hi -- the {lo, hi} pair at
;        patchrec+0x27+2*i, which in v1.40 DSP_Cmd2B_SetParam reads before the call;
;        XDE = destination buffer.
; Exit:  HL = 10 (the byte count, which DSP_Cmd2B_PostProcess turns into the reply length),
;        XIX = source record.
; Body:  hi & 0x20 set -> ToneDB_Find_ToneRecord(WA = lo, BC = hi) supplies the source
;                         record (v1.41: ToneDB_Find_SubToneRecord(patchrec, i, DE = 0xff));
;        otherwise     -> idx = ((hi & 0x1f) << 7) + (lo & 0x7f)
;                         e   = u16[ ToneDB_RelBase + Root->+0x7c + 2*idx ]
;                         src = ToneDB_RelBase + Root->+0xb0 + 10*e
;        Ten bytes are copied src -> XDE.  No stack frame: the destination walks in XIZ.
DSP_SetVoiceCoefficients:
	push	xiz
	ld	xiz, xde
	ld	de, bc
	and	de, 0x20
	cp	de, 0x20
	jr	z, DSP_SetCoeff_DirectLookup
	cp	de, 0:i3
	jr	nz, DSP_SetCoeff_CopyLoop
	and	wa, 0x7f
	ld	de, bc
	and	de, 0x1f
	and	bc, 0xc0
	cp	bc, 0xc0
	jr	z, DSP_SetCoeff_LoadTableBase
	cp	bc, 0x80
	jr	z, DSP_SetCoeff_LoadTableBase
	cp	bc, 0x40
	jr	z, DSP_SetCoeff_LoadTableBase
	cp	bc, 0:i3
	jr	nz, DSP_SetCoeff_ComputeIndex

; Every value of hi & 0xc0 arrives here, so the four-way compare is vestigial.
; XHL = ToneDB_RootPtr->+0x7c, the sub-tone index table.
DSP_SetCoeff_LoadTableBase:
	ld	xbc, (ToneDB_RootPtr:24)
	ld	xhl, (xbc+124)

; e = u16 table[((hi & 0x1f) << 7) | lo]; XIX = ToneDB_RelBase + Root->+0xb0 + 10*e.
DSP_SetCoeff_ComputeIndex:
	ld	bc, de
	sll	bc, 7
	add	bc, wa
	add	bc, bc
	ld	wa, bc
	extz	xwa
	add	xwa, xhl
	add	xwa, (ToneDB_RelBase:24)
	ld	xwa, (xwa)
	ld	bc, wa
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xhl, (xwa+176:16)
	ld	xix, (ToneDB_RelBase:24)
	add	xix, xhl
	ld	wa, bc
	mul	wa, 10
	add	xix, xwa
	jr	DSP_SetCoeff_CopyLoop

; hi bit 5 set: the reference itself (WA = lo, BC = hi, unmasked) is the selector handed to
; ToneDB_Find_ToneRecord.
DSP_SetCoeff_DirectLookup:
	call	ToneDB_Find_ToneRecord
	ld	xix, xhl

; HL = 10, the byte count and the return value.
DSP_SetCoeff_CopyLoop:
	ldw	hl, 10
	ld	bc, 0:i3
	cp	bc, hl
	jr	nc, DSP_SetCoeff_Return

; Byte copy XIX+ -> XIZ+, 10 iterations.
DSP_SetCoeff_CopyRecordByte:
	ld	a, (xix+)
	ld	(xiz+), a
	inc	1, bc
	cp	bc, hl
	jr	c, DSP_SetCoeff_CopyRecordByte

DSP_SetCoeff_Return:
	pop	xiz
	ret

; ----------------------------------------------------------------------------
; DSP_SetCoeff_CopyDirect - Copy coefficients directly to DSP buffer
; Notes: Reads routing config from (0x45314), adds base from (0x45310)
;        Copies to DSP coefficient buffer at 0x45210
; ----------------------------------------------------------------------------
; Copy a 13-byte row out of the ToneDB table at Root->+0x80 into the inter-CPU
; reply payload.
; Entry: WA = row index.
; Exit:  HL = 13 (bytes written), payload at 0x045216..0x045222.
; src = ToneDB_RelBase + Root->+0x80 + 16*WA; the row stride is 16 but only 13
; bytes are shipped.  Reached only from ToneDB_Query_Dispatch case 15 (0x031993).
DSP_SetCoeff_CopyDirect:	.include "includes/generated/cc900/DSP_SetCoeff_CopyDirect.s"	; C: cc900/dsp_voice_params_d_9a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SetCoeff_CopyDirect_Loop, DSP_SetCoeff_CopyDirect + 27
	.set	DSP_SetCoeff_CopyDirect_Epilogue, DSP_SetCoeff_CopyDirect + 67
; ----------------------------------------------------------------------------
; DSP_SetCoeff_RouteComplex - Complex coefficient routing with table lookup
; Notes: Multiple table lookups via (0x45314) and (0x45310)
;        Extended routing with coefficient transformation
;        Writes to coefficient buffer at 0x45210
; ----------------------------------------------------------------------------
; Answer a query for the 13+3 byte coefficient row selected by one sub-tone
; reference of a part's patch record.
; Entry: WA = part index, C = sub-tone index i.
; Exit:  HL = 16, payload 0x045216..0x045225.
; Body: patchrec = Part_PatchRecord_Ptr[part]; {lo,hi} = patchrec+0x27+2*i.
;       row = u32[ ToneDB_RelBase + Root->+0x7C + 2*(((hi&0x1F)<<7)+(lo&0x7F)) ]
;       If hi & 0x20 == 0: 13 bytes are copied from
;         ToneDB_RelBase + Root->+0x80 + 16*row.
;       If hi & 0x20 == 0x20: 13 bytes are copied from
;         ToneDB_RamBankA + 0x4AA7 + 0x50*i  (the RAM kit/user area).
;       Three extra bytes follow: table[16*row + 0x0D], then row's low and high
;       halves (row & 0xFF, row >> 8).  Hence 16 payload bytes.
; Reached only from ToneDB_Query_Dispatch case 16 (0x0319B2).
DSP_SetCoeff_RouteComplex:
	dec	4, xsp
	push xiz
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xhl, (xde+wa)
	ld	a, c
	extz	wa
	add	wa, wa
	add	wa, 39
	ld	a, (xhl+wa)
	ld	e, a
	extz	de
	and	de, 127
	ld	a, c
	extz	wa
	add	wa, wa
	add	wa, 39
	exts	xwa
	add	xwa, xhl
	ld	a, (xwa+1)
	ldfr_berp	a, 244
	extz	iy
	and	iy, 31
	ld	a, c
	extz	wa
	add	wa, wa
	add	wa, 39
	exts	xwa
	add	xwa, xhl
	ld	a, (xwa+1)
	ldfr_berp	a, 240
	extz	ix
	and	ix, 32
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xhl, (xwa+124)
	ld	wa, iy
	sll	wa, 7
	add	wa, de
	add	wa, wa
	extz	xwa
	add	xwa, xhl
	add	xwa, (ToneDB_RelBase:24)
	ld	xwa, (xwa)
	ld	de, wa
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xhl, (xwa+128)
	ld	xwa, (ToneDB_RelBase:24)
	add	xwa, xhl
	ld	(xsp+4), xwa
	ldw	hl, 13
	ld	wa, ix
	cp	wa, 32
	jr	z, DSP_SetCoeff_RouteComplex_Skip
	cp	wa, 0:i3
	jr	nz, DSP_SetCoeff_RouteComplex_Join
	ld	ix, 0:i3
	cp	ix, hl
	jr	nc, DSP_SetCoeff_RouteComplex_Join
DSP_SetCoeff_RouteComplex_Loop:
	ld	bc, ix
	extz	xbc
	ld	wa, de
	extz	xwa
	sll	xwa, 4
	add	xwa, xbc
	ld	xbc, xwa
	add	xbc, (xsp+4)
	ld	wa, ix
	inc	6, wa
	extz	xwa
	ld	xiy, Payload_Bss_Start+0x639a
	add	xiy, xwa
	ld	a, (xbc)
	ld	(xiy), a
	inc	1, ix
	cp	ix, hl
	jr	c, DSP_SetCoeff_RouteComplex_Loop
	jr	t, DSP_SetCoeff_RouteComplex_Join
DSP_SetCoeff_RouteComplex_Skip:
	ld	ix, 0:i3
	cp	ix, hl
	jr	nc, DSP_SetCoeff_RouteComplex_Join
DSP_SetCoeff_RouteComplex_Loop2:
	ld	a, c
	extz	wa
	muls	wa, 80
	ld	iy, wa
	add	iy, 19111
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xiz, (xwa+iy)
	ld	wa, ix
	inc	6, wa
	extz	xwa
	ld	xiy, Payload_Bss_Start+0x639a
	add	xiy, xwa
	ld	wa, ix
	extz	xwa
	add	xwa, xiz
	ld	a, (xwa)
	ld	(xiy), a
	inc	1, ix
	cp	ix, hl
	jr	c, DSP_SetCoeff_RouteComplex_Loop2
DSP_SetCoeff_RouteComplex_Join:
	ld	wa, hl
	inc	6, wa
	extz	xwa
	ld	xbc, Payload_Bss_Start+0x639a
	add	xbc, xwa
	ld	wa, de
	extz	xwa
	sll	xwa, 4
	add	xwa, (xsp+4)
	ld	a, (xwa+13)
	ld	(xbc), a
	inc	1, hl
	ld	wa, hl
	inc	6, wa
	extz	xwa
	ld	xbc, Payload_Bss_Start+0x639a
	add	xbc, xwa
	ld	wa, de
	ld	w, 0:opc
	ld	(xbc), a
	inc	1, hl
	ld	wa, hl
	inc	6, wa
	extz	xwa
	ld	xbc, Payload_Bss_Start+0x639a
	add	xbc, xwa
	ld	wa, de
	srl	wa, 8
	ld	(xbc), a
	inc	1, hl
	pop xiz
	inc	4, xsp
	ret
; ----------------------------------------------------------------------------
; DSP_SetCoeff_CopyDirect2 - Copy coefficients directly (variant 2)
; Notes: Same pattern as DSP_SetCoeff_CopyDirect with different offsets
; ----------------------------------------------------------------------------
; Same shape as 0x03122F but reads the table at Root->+0x8C.
; Entry: WA = row index.  Exit: HL = 13, payload 0x045216..0x045222.
; Reached only from ToneDB_Query_Dispatch case 17 (0x0319D0).
DSP_SetCoeff_CopyDirect2:	.include "includes/generated/cc900/DSP_SetCoeff_CopyDirect2.s"	; C: cc900/dsp_voice_params_d_9a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SetCoeff_CopyDirect2_Loop, DSP_SetCoeff_CopyDirect2 + 27
	.set	DSP_SetCoeff_CopyDirect2_Epilogue, DSP_SetCoeff_CopyDirect2 + 67
; ----------------------------------------------------------------------------
; DSP_SetCoeff_RouteWithCallback - Coefficient routing with callback function
; Notes: Calls 0x032AE0 for parameter transformation
;        Routes coefficients via (0x45314) tables
;        Uses (0x45310) base for address computation
; ----------------------------------------------------------------------------
; Answer a query for a coefficient row reached through ToneDB_Find_SubToneRecord.
; Entry: A = sub-tone index, C = 0, E = part index in bits 0..3 (E&0x0F is kept
;        in QIZH; the caller passes ToneDB_RamBankA[+0x72A7] in C).
; Exit:  HL = 16, payload 0x045216..0x045225.
; Body: patchrec = Part_PatchRecord_Ptr[E & 0x0F]; ToneDB_Find_SubToneRecord
;       (0x032AE0) resolves a named record; the 0x15-byte partial slot at
;       record+0x10+0x15*QIZH supplies {lo=slot[+1]&0x7F, hi=slot[+2]}.
;       idx = ((slot[+2]&0x0F) << 7) + lo; row = u32[Root->+0x4C + 2*idx];
;       then 13 bytes from Root->+0x8C + 16*row plus the same three trailer
;       bytes as 0x031274.
; Reached only from ToneDB_Query_Dispatch case 18 (0x0319EE).
DSP_SetCoeff_RouteWithCallback:
	dec	4, xsp
	push	xiz
	ldfr_berp	e, 0xfb	; ld QIZH,E
	and_erpb	0xfb, 0x0f	; and QIZH,0x0f
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_PatchRecord_Ptr:24)
	ld	xhl, (xhl+de)
	extz	bc
	ld	e, a
	extz	de
	ld	xwa, xhl
	call	ToneDB_Find_SubToneRecord
	ld_erpb_rr	a, 0xfb	; ld A,QIZH
	extz	wa
	muls	wa, 21
	add	wa, 16
	lda	xhl, (xhl+wa)	; lda XHL,XHL+WA
	ld	a, (xhl+1)
	ld	e, a
	extz	de
	and	de, 127
	ld	a, (xhl+2)
	ld	c, a
	extz	bc
	and	bc, 15
	ld	a, (xhl+2)
	extz	wa
	and	wa, 192
	cp	wa, 192
	jr	z, DSP_SetCoeff_RouteWithCallback_Skip
	cp	wa, 128
	jr	z, DSP_SetCoeff_RouteWithCallback_Skip
	cp	wa, 64
	jr	z, DSP_SetCoeff_RouteWithCallback_Skip
	cp	wa, 0:i3
	jr	nz, DSP_SetCoeff_RouteWithCallback_Skip2
DSP_SetCoeff_RouteWithCallback_Skip:
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xwa, (xwa+76)
	ld	(xsp+4), xwa
DSP_SetCoeff_RouteWithCallback_Skip2:
	ld	wa, bc
	sll	wa, 7
	add	wa, de
	add	wa, wa
	extz	xwa
	add32_src_rid8	xsp, 0x04, xwa	; add XWA,(XSP+0x04)
	add	xwa, (ToneDB_RelBase:24)
	ld	xwa, (xwa)
	ld	de, wa
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xwa, (xwa+140)
	ld	(xsp+4), xwa
	ld	xix, (ToneDB_RelBase:24)
	add32_src_rid8	xsp, 0x04, xix	; add XIX,(XSP+0x04)
	ldw	hl, 13
	ld	iy, 0:i3
	cp	iy, hl
	jr	nc, DSP_SetCoeff_RouteWithCallback_Skip3
DSP_SetCoeff_RouteWithCallback_Loop:
	ld	bc, iy
	extz	xbc
	ld	wa, de
	extz	xwa
	sll	xwa, 4
	add	xwa, xbc
	ld	xbc, xwa
	add	xbc, xix
	ld	wa, iy
	inc	6, wa
	extz	xwa
	ld	xiz, Payload_Bss_Start+0x639a
	add	xiz, xwa
	ld	a, (xbc)
	ld	(xiz), a
	inc	1, iy
	cp	iy, hl
	jr	c, DSP_SetCoeff_RouteWithCallback_Loop
DSP_SetCoeff_RouteWithCallback_Skip3:
	ld	wa, hl
	inc	6, wa
	extz	xwa
	ld	xbc, Payload_Bss_Start+0x639a
	add	xbc, xwa
	ld	wa, de
	extz	xwa
	sll	xwa, 4
	add	xwa, xix
	ld	a, (xwa+13)
	ld	(xbc), a
	inc	1, hl
	ld	wa, hl
	inc	6, wa
	extz	xwa
	ld	xbc, Payload_Bss_Start+0x639a
	add	xbc, xwa
	ld	wa, de
	ld	w, 0:opc
	ld	(xbc), a
	inc	1, hl
	ld	wa, hl
	inc	6, wa
	extz	xwa
	ld	xbc, Payload_Bss_Start+0x639a
	add	xbc, xwa
	ld	wa, de
	srl	wa, 8
	ld	(xbc), a
	inc	1, hl
	pop	xiz
	inc	4, xsp
	ret
; ----------------------------------------------------------------------------
; DSP_SetCoeff_FullPipeline - Full coefficient setup pipeline
; Notes: Largest coefficient setup function (384 bytes)
;        Calls 0x032AE0 and 0x032682 for multi-stage processing
;        Full routing table lookup chain via (0x45314)/(0x45310)
;        Writes computed coefficients to DSP buffer at 0x45210
; ----------------------------------------------------------------------------
; Answer a query for the coefficient row of one partial of one part, going
; through the Stage-A1 velocity-split lookup.
; Entry: A = part index, C = zone/partial argument, E = nibble pair
;        (E & 0x0F -> QIZH = partial index, E >> 4 -> secondary index).
; Exit:  HL = 16, payload 0x045216..0x045225.
; Body: patchrec = Part_PatchRecord_Ptr[part]; ToneDB_Find_SubToneRecord and
;       WaveSel_StageA1_FromToneSlot (0x032682) are both invoked, then the
;       {lo,hi} pair at record+0x10+0x15*QIZH+3+2*(E>>4) drives the same
;       u16-index / 16-byte-row lookup, this time through Root->+0x60 and
;       Root->+0x94.  Three trailer bytes as above.
; Reached only from ToneDB_Query_Dispatch case 19 (0x031A19).
DSP_SetCoeff_FullPipeline:
	lda	xsp, (xsp-10)
	push xiz
	ld	(xsp+10), c
	ld	(xsp+12), a
	ldfr_berp	e, 251
	and_erpb	251, 15
	ld	a, e
	and	a, 240
	srl	a, 4
	ld	(xsp+8), a
	ld	a, (xsp+12)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xhl, (xbc+wa)
	ld	a, (xsp+10)
	ld	c, a
	extz	bc
	ld	a, (xsp+12)
	ld	e, a
	extz	de
	ld	xwa, xhl
	call	ToneDB_Find_SubToneRecord
	ldto_berp	a, 251
	extz	wa
	muls	wa, 21
	add	wa, 16
	lda	xhl, (xhl+wa)
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	a, (xsp+10)
	ld	e, a
	extz	de
	ld	a, (xsp+12)
	extz	wa
	pushw wa
	ld	wa, bc
	ld	xbc, xhl
	call	WaveSel_StageA1_FromToneSlot
	ld	a, (xsp+8)
	extz	wa
	add	wa, wa
	inc	3, wa
	ld	a, (xhl+wa)
	ld	c, a
	extz	bc
	and	bc, 127
	ld	a, (xsp+8)
	extz	wa
	add	wa, wa
	inc	3, wa
	exts	xwa
	add	xwa, xhl
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	and	de, 15
	ld	a, (xsp+8)
	extz	wa
	add	wa, wa
	inc	3, wa
	exts	xwa
	add	xwa, xhl
	ld	a, (xwa+1)
	extz	wa
	and	wa, 192
	cp	wa, 192
	jr	z, DSP_SetCoeff_FullPipeline_Skip
	cp	wa, 128
	jr	z, DSP_SetCoeff_FullPipeline_Skip
	cp	wa, 64
	jr	z, DSP_SetCoeff_FullPipeline_Skip
	cp	wa, 0:i3
	jr	nz, DSP_SetCoeff_FullPipeline_Skip2
DSP_SetCoeff_FullPipeline_Skip:
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xwa, (xwa+96)
	ld	(xsp+4), xwa
DSP_SetCoeff_FullPipeline_Skip2:
	ld	wa, de
	sll	wa, 7
	add	wa, bc
	add	wa, wa
	extz	xwa
	add	xwa, (xsp+4)
	add	xwa, (ToneDB_RelBase:24)
	ld	xwa, (xwa)
	ld	de, wa
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xwa, (xwa+148)
	ld	(xsp+4), xwa
	ld	xix, (ToneDB_RelBase:24)
	add	xix, (xsp+4)
	ldw	hl, 13
	ld	iy, 0:i3
	cp	iy, hl
	jr	nc, DSP_SetCoeff_FullPipeline_Skip3
DSP_SetCoeff_FullPipeline_Loop:
	ld	bc, iy
	extz	xbc
	ld	wa, de
	extz	xwa
	sll	xwa, 4
	add	xwa, xbc
	ld	xbc, xwa
	add	xbc, xix
	ld	wa, iy
	inc	6, wa
	extz	xwa
	ld	xiz, Payload_Bss_Start+0x639a
	add	xiz, xwa
	ld	a, (xbc)
	ld	(xiz), a
	inc	1, iy
	cp	iy, hl
	jr	c, DSP_SetCoeff_FullPipeline_Loop
DSP_SetCoeff_FullPipeline_Skip3:
	ld	wa, hl
	inc	6, wa
	extz	xwa
	ld	xbc, Payload_Bss_Start+0x639a
	add	xbc, xwa
	ld	wa, de
	extz	xwa
	sll	xwa, 4
	add	xwa, xix
	ld	a, (xwa+13)
	ld	(xbc), a
	inc	1, hl
	ld	wa, hl
	inc	6, wa
	extz	xwa
	ld	xbc, Payload_Bss_Start+0x639a
	add	xbc, xwa
	ld	wa, de
	ld	w, 0:opc
	ld	(xbc), a
	inc	1, hl
	ld	wa, hl
	inc	6, wa
	extz	xwa
	ld	xbc, Payload_Bss_Start+0x639a
	add	xbc, xwa
	ld	wa, de
	srl	wa, 8
	ld	(xbc), a
	inc	1, hl
	pop xiz
	lda	xsp, (xsp+10)
	ret
; ----------------------------------------------------------------------------
; DSP_SetCoeff_WithDispatch - Coefficient setup with type dispatch
; Notes: Loads from (0x45314), dispatches by routing type
;        Copies coefficients to DSP buffer at 0x45210
; ----------------------------------------------------------------------------
; Copy 13 bytes from Root->+0x8C + 16*row where row = u32[Root->+0x4C +
; 2*(((BC&0x0F)<<7) + (WA&0x7F))].
; Entry: WA = fine byte, BC = set byte.  Exit: HL = 13, payload 0x045216+.
; MEASURED: this routine has NO caller anywhere in the sub-CPU image (checked
; against a full-image call/jump scan).  It is dead code, most likely an
; earlier revision of 0x031411.  Documented for completeness only.
DSP_SetCoeff_WithDispatch:
	push xiz
	and	wa, 127
	ld	de, bc
	and	bc, 15
	and	de, 192
	cp	de, 192
	jr	z, DSP_SetCoeff_FullPipeline_Skip4
	cp	de, 128
	jr	z, DSP_SetCoeff_FullPipeline_Skip4
	cp	de, 64
	jr	z, DSP_SetCoeff_FullPipeline_Skip4
	cp	de, 0:i3
	jr	nz, DSP_SetCoeff_FullPipeline_Skip5
DSP_SetCoeff_FullPipeline_Skip4:
	ld	xde, (ToneDB_RootPtr:24)
	ld	xhl, (xde+76)
DSP_SetCoeff_FullPipeline_Skip5:
	sll	bc, 7
	add	bc, wa
	add	bc, bc
	ld	wa, bc
	extz	xwa
	add	xwa, xhl
	add	xwa, (ToneDB_RelBase:24)
	ld	xwa, (xwa)
	ld	ix, wa
	ld	xwa, (ToneDB_RootPtr:24)
	ld	xhl, (xwa+140)
	ld	xiy, (ToneDB_RelBase:24)
	add	xiy, xhl
	ldw	hl, 13
	ld	de, 0:i3
	cp	de, hl
	jr	nc, DSP_SetCoeff_FullPipeline_Epilogue
DSP_SetCoeff_FullPipeline_Loop2:
	ld	bc, de
	extz	xbc
	ld	wa, ix
	extz	xwa
	sll	xwa, 4
	add	xwa, xbc
	ld	xbc, xwa
	add	xbc, xiy
	ld	wa, de
	inc	6, wa
	extz	xwa
	ld	xiz, Payload_Bss_Start+0x639a
	add	xiz, xwa
	ld	a, (xbc)
	ld	(xiz), a
	inc	1, de
	cp	de, hl
	jr	c, DSP_SetCoeff_FullPipeline_Loop2
DSP_SetCoeff_FullPipeline_Epilogue:
	pop xiz
	ret
; ----------------------------------------------------------------------------
; DSP_SetCoeff_WriteParams - Write individual coefficient parameters
; Notes: Writes directly to DSP coefficient bytes at 0x045216/0x045217
;        Handles special parameter formatting
; ----------------------------------------------------------------------------
; Two-byte query: the part's patch-record format byte and, for one particular
; format, an extra descriptor byte.
; Entry: A = part index.  Exit: HL = 2, payload 0x045216..0x045217.
; 0x045216 = Part_PatchRecord_Ptr[part][+0x10].
; 0x045217 = patchrec[+0x5F] if (patchrec[+0x5D] & 0x0F) == 0x0C, else 0.
; Reached only from ToneDB_Query_Dispatch case 23 (0x031A44).
DSP_SetCoeff_WriteParams:	.include "includes/generated/cc900/DSP_SetCoeff_WriteParams.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SetCoeff_WriteParams_Skip, DSP_SetCoeff_WriteParams + 83
	.set	DSP_SetCoeff_WriteParams_Return, DSP_SetCoeff_WriteParams + 89
; ----------------------------------------------------------------------------
; DSP_SetCoeff_MasterConfig - Master coefficient configuration routine
; Notes: Largest DSP coefficient function (706 bytes)
;        References 0x045216 (coefficient buffer) extensively
;        Calls 0x02B014 for coefficient computation
;        Full DSP state setup with all coefficient types
;        Writes to coefficient output table at 0x45210
; ----------------------------------------------------------------------------
; The 24-opcode query interpreter behind status bytes 0x80..0x87 opcode 0.
; Entry: XWA = pointer to the 6-byte request packet (0x002AE8 or 0x002AEE).
;        request[+1] = part/slot index, request[+2] = opcode (bit 7 ignored),
;        request[+3] = a secondary index, request[+4] = reply tag.
; Exit:  HL = number of payload bytes deposited at 0x045216 (0 = nothing).
; Opcode is range-checked 0..0x17; out-of-range and opcodes 2,3,20,21,22 fall
; straight through to the epilogue with IZ still 0, i.e. an empty payload.
; Case map (callee -> payload length is that callee's HL):
;   0  DSP_EffectStateQuery 0x030618 (1 byte: part flags bit 0)
;   1  CheckStatusBits_40 0x02E213 [+ Voice_Slot_CalcArticParams 0x02B014]
;      then DSP_AlgoSelect 0x030960
;   4  DSP_MixSendConfig 0x0309EA        5  DSP_RouteCoeffs_TypeA 0x030A0A
;   6  DSP_RouteCoeffs_TypeB 0x030AAD    7  DSP_CopyCoeffs_TypeA 0x030B50
;   8  DSP_CopyCoeffs_TypeB 0x030B93     9  DSP_VoiceCoeffRoute 0x030BD6
;   10 DSP_VoiceCoeffRoute2 0x030D43     11 DSP_AlgoCoeffLookup 0x030EF1
;   12 eight calls to DSP_VoiceParamReadWrite 0x030F7D (payload = 8 bytes)
;   13 DSP_ReadVoiceParam5D 0x03106F     14 DSP_VoiceParam_Dispatch 0x03107F
;   15 0x03122F  16 0x031274  17 0x0313CC  18 0x031411  19 0x031534  23 0x03173B
; Cases 18 and 19 first fetch ToneDB_RamBankA[+0x72A7] and pass it as the
; "current part" argument.  Sole caller: 0x031B5D (query family case 0).
; The LLVM source calls this DSP_SetCoeff_MasterConfig.
DSP_SetCoeff_MasterConfig:
	dec	6, xsp
	pushw iz
	ld	(xsp+4), xwa
	ldw	(xsp+2), 0
	ld	iz, 0:i3
	ld	xwa, (xsp+4)
	ld	a, (xwa+2)
	res	7, a
	extz	wa
	cp	wa, 0:i3
	jrl	mi, DSP_SetCoeff_MasterConfig_Epilogue
	cp	wa, 23
	jrl	gt, DSP_SetCoeff_MasterConfig_Epilogue
	add	wa, wa
	lda	xix, (DSP_SETCOEFF_MASTERCONFIG_JUMPTABLE:24)
	ld	wa, (xix+wa)
	lda	xix, (DSP_SetCoeff_MasterConfig_CaseBase:24)
	jp	t, (xix+wa)
DSP_SetCoeff_MasterConfig_CaseBase:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xbc, xwa
	ld	wa, de
	calr	DSP_EffectStateQuery
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_AlgoSelect:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	calr	CheckStatusBits_40
	cp	l, 0:i3
	jr	z, DSP_SetCoeff_MasterConfig_Skip
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	call	Voice_Slot_CalcArticParams
DSP_SetCoeff_MasterConfig_Skip:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	l, a
	extz	hl
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	c, a
	extz	bc
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_AlgoSelect
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_ToneNameAndMode:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	l, a
	extz	hl
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	c, a
	extz	bc
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_MixSendConfig
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_SourceNameA_BySelector:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	e, a
	extz	de
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	c, a
	extz	bc
	ld	wa, de
	calr	DSP_RouteCoeffs_TypeA
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_SourceNameB_BySelector:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	e, a
	extz	de
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	c, a
	extz	bc
	ld	wa, de
	calr	DSP_RouteCoeffs_TypeB
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_SourceNameA_ByRow:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	c, a
	extz	bc
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	sll	wa, 8
	or	wa, bc
	calr	DSP_CopyCoeffs_TypeA
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_SourceNameB_ByRow:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	c, a
	extz	bc
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	sll	wa, 8
	or	wa, bc
	calr	DSP_CopyCoeffs_TypeB
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_SlotSourceNameA:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	c, a
	extz	bc
	ld	wa, de
	calr	DSP_VoiceCoeffRoute
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_SlotPairSourceNameB:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	c, a
	extz	bc
	ld	wa, de
	calr	DSP_VoiceCoeffRoute2
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_CatalogueFooter:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	extz	wa
	calr	DSP_AlgoCoeffLookup
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_ToneOptions:
	ldw	iz, 8
	cp	(xsp+2), iz
	jrl	nc, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_Loop:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	c, a
	extz	bc
	ld	wa, (xsp+2)
	inc	6, wa
	extz	xwa
	ld	xde, Payload_Bss_Start+0x639a
	add	xde, xwa
	ld	wa, bc
	ld	bc, (xsp+2)
	calr	DSP_VoiceParamReadWrite
	incw	1, (xsp+2)
	cp	(xsp+2), iz
	jr	c, DSP_SetCoeff_MasterConfig_Loop
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_AlgorithmType:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	l, a
	extz	hl
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	c, a
	extz	bc
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_ReadVoiceParam5D
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_DrumSourceName_BySelector:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	l, a
	extz	hl
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	c, a
	extz	bc
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_VoiceParam_Dispatch
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_DrumSourceName_ByRow:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	c, a
	extz	bc
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	sll	wa, 8
	or	wa, bc
	calr	DSP_SetCoeff_CopyDirect
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_KitNoteSourceName:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	e, a
	extz	de
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	c, a
	extz	bc
	ld	wa, de
	calr	DSP_SetCoeff_RouteComplex
	ld	iz, hl
	jrl	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_PercSourceName_ByRow:
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	c, a
	extz	bc
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	sll	wa, 8
	or	wa, bc
	calr	DSP_SetCoeff_CopyDirect2
	ld	iz, hl
	jr	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_SubToneLayerSourceName:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	l, a
	extz	hl
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	ld	c, a
	extz	bc
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	e, a
	extz	de
	ld	wa, hl
	calr	DSP_SetCoeff_RouteWithCallback
	ld	iz, hl
	jr	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_SubToneLayerPairSourceName:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	ld	l, a
	extz	hl
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	ld	c, a
	extz	bc
	ld	xwa, (xsp+4)
	ld	a, (xwa+3)
	ld	e, a
	extz	de
	ld	wa, hl
	calr	DSP_SetCoeff_FullPipeline
	ld	iz, hl
	jr	t, DSP_SetCoeff_MasterConfig_Epilogue
DSP_SetCoeff_MasterConfig_PartModeBytes:
	ld	xwa, (xsp+4)
	ld	a, (xwa+1)
	extz	wa
	calr	DSP_SetCoeff_WriteParams
	ld	iz, hl
DSP_SetCoeff_MasterConfig_Epilogue:
	ld	hl, iz
	popw iz
	inc	6, xsp
	ret

; Unbounded byte block copy used by the whole query family.
; Entry: XBC = source, XDE = destination, WA = byte count (0..0xFFFF).
; Exit:  memory copied; no register contract beyond the caller reloading HL.
; NOTE: the count is taken verbatim from the request packet's length byte
; (request[+3], 0..255) and the destination is always the 0x045216 reply
; payload, whose next allocated neighbour is ToneDB_RelBase at 0x045310 --
; only 0xFA bytes away.  See [UNCERTAIN]/findings: a length byte >= 0xFA
; overwrites ToneDB_RelBase / ToneDB_RootPtr.
DSP_ParamWrite_BlockCopy:	.include "includes/generated/cc900/DSP_ParamWrite_BlockCopy.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_ParamWrite_BlockCopy_Loop, DSP_ParamWrite_BlockCopy + 8

; Six consecutive 'ret' bytes; alignment padding, no caller.
DSP_ParamWrite_NopPad:
	.fill 6, 1, 0x0e

; Service one 6-byte tone/parameter command taken from the audio command ring.
; This is the main sub->main reply producer in this region.
; Entry: XWA -> 6-byte packet: [0]=status byte, [1]=part index, [2]=offset,
;        [3]=length, [4]=reply tag, [5]=spare.
; Exit:  HL = payload length actually produced (query family) or the callee's
;        status (action family).
; Dispatch: A = status & 7 selects one of 8 cases; bit 3 of the status selects
;   WHICH table:
;     bit 3 SET   -> table 0x00FB2E, bodies at 0x031AA1.. -- "actions".  Each
;                    case ends with an unconditional jump to 0x031E68 and
;                    therefore emits NO inter-CPU reply.
;     bit 3 CLEAR -> table 0x00FB1E, bodies at 0x031B5B.. -- "queries".  Every
;                    case falls into 0x031E2D, which ALWAYS sends a reply.
; Callers: MIDI_Dispatch_ParseStatus 0x034E1A (statuses 0x80..0x87, packet
; assembled at 0x002AE8) and MIDI_Status_NoteOn_Extended 0x034E56 (statuses
; 0x88..0x8F, packet at 0x002AEE).  Despite the MIDI_* names of the callers,
; the 0x8x status range on this internal ring is NOT MIDI note-off: the low
; nibble is an opcode/table selector consumed here.
; Hardware: reaches the inter-CPU latch window (0x120000) indirectly through
; InterCPU_DMA_Send 0x020C6B.
Voice_ParamFinalize:
	push xiz
	ld xiz, xwa
	ld a, (xiz)
	and a, 0x7
	bitm 3, (xiz)
	jrl z, VoiceParamFinalize_SecondaryDispatch
	extz wa
	cp wa, 0:i3
	jrl mi, VoiceParamFinalize_Return
	cp wa, 7:i3
	jrl gt, VoiceParamFinalize_Return
	add wa, wa
	lda xix, (VOICEPARAM_FINALIZE_ACTION_JUMPTABLE:24)
	ld	wa, (xix+wa)
	lda xix, (VoiceParam_Action_ToneEdit:24)
	jp	t, (xix+wa)

; --- ToneCmd_Dispatcher: Route tone/MIDI commands by type and channel ---
; Entry: XIZ = pointer to command structure
;   byte[0] = command type, byte[1] = note/key, byte[2] = velocity/flags
; Dispatches to velocity handlers, channel assignment (BC=0-3),
; note-on/off routing, and special command handlers.
; Each dispatch path exits via jrl to common return.
; Action case 0: call 0x02ED80 with XWA = packet, then return (no reply).
; VoiceParam_Action_ToneEdit: Action case 0 (status 0x88) of Voice_ParamFinalize, and the base of
;   VOICEPARAM_FINALIZE_ACTION_JUMPTABLE: passes the 6-byte packet to Audio_Cmd_ToneEdit_Dispatch (the tone-edit
;   opcode tree) and returns without a reply. Basis: table + body, named like its siblings
;   VoiceParam_Action_EffectParam (0x89) ... _SubToneLayerByteReply (0x8F).
VoiceParam_Action_ToneEdit:
	ld	xwa, xiz
	calr	Audio_Cmd_ToneEdit_Dispatch
	jrl	VoiceParamFinalize_Return
; Action case 1: VoiceAlloc_CheckAndInit 0x02EC0A on packet[+1], then 0x02F830.
; VoiceParam_Action_EffectParam: Status 0x89.
VoiceParam_Action_EffectParam:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	xwa, xiz
	calr	Audio_Cmd_EffectParam_Dispatch
	jrl	VoiceParamFinalize_Return
; Action case 2: VoiceAlloc_CheckAndInit, then 0x02FF3A with BC = 0 or 1
; depending on bit 7 of packet[+2].
; VoiceParam_Action_Partial0Or1Param: Status 0x8A: bit 7 of the opcode byte selects partial 0 or 1.
VoiceParam_Action_Partial0Or1Param:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+2)
	and	a, 128
	cp	a, 128
	jr	z, Voice_ParamFinalize_Skip
	cp	a, 0:i3
	jrl	nz, VoiceParamFinalize_Return
	ld	xwa, xiz
	ld	bc, 0:i3
	calr	Audio_Cmd_DSPUnit_Param
	jrl	VoiceParamFinalize_Return
Voice_ParamFinalize_Skip:
	ld	xwa, xiz
	ld	bc, 1:i3
	calr	Audio_Cmd_DSPUnit_Param
	jrl	VoiceParamFinalize_Return
; Action case 3: same as case 2 but with BC = 2 or 3.
; VoiceParam_Action_Partial2Or3Param: Status 0x8B: bit 7 of the opcode byte selects partial 2 or 3.
VoiceParam_Action_Partial2Or3Param:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	a, (xiz+2)
	and	a, 128
	cp	a, 128
	jr	z, Voice_ParamFinalize_Skip2
	cp	a, 0:i3
	jrl	nz, VoiceParamFinalize_Return
	ld	xwa, xiz
	ld	bc, 2:i3
	calr	Audio_Cmd_DSPUnit_Param
	jrl	VoiceParamFinalize_Return
Voice_ParamFinalize_Skip2:
	ld	xwa, xiz
	ld	bc, 3:i3
	calr	Audio_Cmd_DSPUnit_Param
	jrl	VoiceParamFinalize_Return
; Action case 4: VoiceAlloc_CheckAndInit then 0x0301E3.
; VoiceParam_Action_VelSplitParam: Status 0x8C.
VoiceParam_Action_VelSplitParam:
	ld	a, (xiz+1)
	extz	wa
	calr	VoiceAlloc_CheckAndInit
	ld	xwa, xiz
	calr	Audio_Cmd_DSPGlobal_Param_Store
	jrl	VoiceParamFinalize_Return
; Action case 5: 0x03021F with XWA = packet.
; VoiceParam_Action_PatchByteEcho: Status 0x8D.
VoiceParam_Action_PatchByteEcho:
	ld	xwa, xiz
	calr	Audio_Cmd_PatchByte_Write_And_Echo
	jrl	VoiceParamFinalize_Return
; Action case 6: 0x030428 with XWA = packet.
; VoiceParam_Action_SubToneByteReply: Status 0x8E.
VoiceParam_Action_SubToneByteReply:
	ld	xwa, xiz
	calr	Audio_Cmd_ToneEdit_Write_And_Reply
	jrl	VoiceParamFinalize_Return
; Action case 7: 0x030535 with XWA = packet.
; VoiceParam_Action_SubToneLayerByteReply: Status 0x8F.
VoiceParam_Action_SubToneLayerByteReply:
	ld	xwa, xiz
	calr	Audio_Cmd_ToneEdit_Field_Write_And_Reply
	jrl	VoiceParamFinalize_Return

; Range-check status&7 against 0..7 and jump through table 0x00FB1E.
VoiceParamFinalize_SecondaryDispatch:
	extz wa
	cp wa, 0:i3
	jrl mi, VoiceParamFinalize_CopyToWorkArea
	cp wa, 7:i3
	jrl gt, VoiceParamFinalize_CopyToWorkArea
	add wa, wa
	lda xix, (VOICEPARAM_FINALIZE_QUERY_JUMPTABLE:24)
	ld	wa, (xix+wa)
	lda xix, (VoiceParamFinalize_SecondaryBody:24)
	jp	t, (xix+wa)

; Query case 0: hand the whole packet to ToneDB_Query_Dispatch 0x031795.
VoiceParamFinalize_SecondaryBody:
	ld	xwa, xiz
	calr	DSP_SetCoeff_MasterConfig
	jrl	VoiceParamFinalize_CopyToWorkArea
; Query case 1: copy packet[+3] bytes from Part_PatchRecord_Ptr[part]+packet[+2]
; into the payload.  Special case for offset 0x5D: bit 7 of the returned byte is
; cleared and then re-set from bit 14 of Part_Flags0A[part].
; 2026-09-25: the first 53 bytes were a .byte/.ascii run; now instructions (convert_v142_byte_block.py:
; llvm-mc + unidasm agree on every boundary, each instruction re-assembles to its own bytes).
VoiceParam_Query_Case1_PatchRec:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 0x11f
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xbc+wa)
	ld	a, (xiz+2)
	extz	wa
	extz	xwa
	add	xbc, xwa
	ld	a, (xiz+3)
	ld	l, a
	extz	hl
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_ParamWrite_BlockCopy
	cp	(xiz+2), 93
	jr	nz, VoiceParam_Query_Case1_PatchRec_Done
	res	7, (Payload_Bss_Start+0x63a0:24)
	lda	xhl, (Payload_Bss_Start+0x63a0:24)
	ld	e, 0:opc
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x24fc:24)
	ld	wa, (xbc+wa)
	bit	14, wa
	jr	z, VoiceParam_Query_Case1_PatchRec_Code_Skip
	ld	e, 128:opc
VoiceParam_Query_Case1_PatchRec_Code_Skip:
	or	(xhl), e
VoiceParam_Query_Case1_PatchRec_Done:
	ld	l, (xiz+3)
	extz	hl
	jrl	t, VoiceParamFinalize_CopyToWorkArea
; Query case 2: source is Part_Slot_Sub_Base[part][0] (0x0413D6) when bit 7 of
; packet[+2] is clear, or [1] (0x0413FB) when set; offset = packet[+2] & 0x7F.
VoiceParam_Query_Case2_Partial01:
	ld	a, (xiz+2)
	and	a, 128
	cp	a, 128
	jr	z, VoiceParam_Query_Case1_PatchRec_Code_Skip2
	cp	a, 0:i3
	jr	nz, VoiceParam_Query_Case1_PatchRec_Code_Join
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x2560:24)
	ld	xbc, (xbc+wa)
	jr	t, VoiceParam_Query_Case1_PatchRec_Code_Join
VoiceParam_Query_Case1_PatchRec_Code_Skip2:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x2585:24)
	ld	xbc, (xbc+wa)
VoiceParam_Query_Case1_PatchRec_Code_Join:
	ld	a, (xiz+2)
	res	7, a
	extz	wa
	extz	xwa
	add	xbc, xwa
	ld	a, (xiz+3)
	ld	l, a
	extz	hl
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_ParamWrite_BlockCopy
	ld	l, (xiz+3)
	extz	hl
	jrl	t, VoiceParamFinalize_CopyToWorkArea
; Query case 3: same, but slot pointers at 0x041420 (partial 2) / 0x041445
; (partial 3).
VoiceParam_Query_Case3_Partial23:
	ld	a, (xiz+2)
	and	a, 128
	cp	a, 128
	jr	z, VoiceParam_Query_Case1_PatchRec_Code_Skip3
	cp	a, 0:i3
	jr	nz, VoiceParam_Query_Case1_PatchRec_Code_Join2
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x25aa:24)
	ld	xbc, (xbc+wa)
	jr	t, VoiceParam_Query_Case1_PatchRec_Code_Join2
VoiceParam_Query_Case1_PatchRec_Code_Skip3:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x25cf:24)
	ld	xbc, (xbc+wa)
VoiceParam_Query_Case1_PatchRec_Code_Join2:
	ld	a, (xiz+2)
	res	7, a
	extz	wa
	extz	xwa
	add	xbc, xwa
	ld	a, (xiz+3)
	ld	l, a
	extz	hl
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_ParamWrite_BlockCopy
	ld	l, (xiz+3)
	extz	hl
	jrl	t, VoiceParamFinalize_CopyToWorkArea
; Query case 4: bits 6-7 of packet[+2] pick the partial (0x0413D6 / 0x0413FF /
; 0x041424 / 0x041449); offset = packet[+2] & 0x3F.
VoiceParam_Query_Case4_PartialAny:
	ld	a, (xiz+2)
	and	a, 192
	cp	a, 192
	jr	z, VoiceParam_Query_Case1_PatchRec_Code_Skip6
	cp	a, 128
	jr	z, VoiceParam_Query_Case1_PatchRec_Code_Skip5
	cp	a, 64
	jr	z, VoiceParam_Query_Case1_PatchRec_Code_Skip4
	cp	a, 0:i3
	jr	nz, VoiceParam_Query_Case1_PatchRec_Code_Join3
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x2564:24)
	ld	xbc, (xbc+wa)
	jr	t, VoiceParam_Query_Case1_PatchRec_Code_Join3
VoiceParam_Query_Case1_PatchRec_Code_Skip4:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x2589:24)
	ld	xbc, (xbc+wa)
	jr	t, VoiceParam_Query_Case1_PatchRec_Code_Join3
VoiceParam_Query_Case1_PatchRec_Code_Skip5:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x25ae:24)
	ld	xbc, (xbc+wa)
	jr	t, VoiceParam_Query_Case1_PatchRec_Code_Join3
VoiceParam_Query_Case1_PatchRec_Code_Skip6:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x25d3:24)
	ld	xbc, (xbc+wa)
VoiceParam_Query_Case1_PatchRec_Code_Join3:
	ld	a, (xiz+2)
	and	a, 63
	extz	wa
	extz	xwa
	add	xbc, xwa
	ld	a, (xiz+3)
	ld	l, a
	extz	hl
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_ParamWrite_BlockCopy
	ld	l, (xiz+3)
	extz	hl
	jrl	t, VoiceParamFinalize_CopyToWorkArea
; Query case 5: like case 1 but with no 0x5D fixup.
VoiceParam_Query_Case5_PatchRec2:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xbc+wa)
	ld	a, (xiz+2)
	extz	wa
	extz	xwa
	add	xbc, xwa
	ld	a, (xiz+3)
	ld	l, a
	extz	hl
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_ParamWrite_BlockCopy
	ld	l, (xiz+3)
	extz	hl
	jrl	t, VoiceParamFinalize_CopyToWorkArea
; Query case 6: ToneDB_Find_SubToneRecord (0x032AE0) resolves the record, then
; packet[+3] bytes from record+packet[+2] are shipped.
VoiceParam_Query_Case6_SubTone:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xhl, (xbc+wa)
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	ld	c, a
	extz	bc
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	xwa, xhl
	call	ToneDB_Find_SubToneRecord
	ld	xbc, xhl
	ld	a, (xiz+2)
	extz	wa
	extz	xwa
	add	xbc, xwa
	ld	a, (xiz+3)
	ld	l, a
	extz	hl
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_ParamWrite_BlockCopy
	ld	l, (xiz+3)
	extz	hl
	jrl	t, VoiceParamFinalize_CopyToWorkArea
; Query case 7: ToneDB_Find_SubToneRecord then WaveSel_StageA1_FromToneSlot on
; the 0x15-byte partial slot selected by bits 6-7 of packet[+2]; ships
; packet[+3] bytes from slot+(packet[+2] & 0x3F).
VoiceParam_Query_Case7_PartialSlot:
	ld	a, (xiz+1)
	extz	wa
	muls	wa, 287
	lda	xbc, (Part_PatchRecord_Ptr:24)
	ld	xhl, (xbc+wa)
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	ld	c, a
	extz	bc
	ld	a, (xiz+1)
	ld	e, a
	extz	de
	ld	xwa, xhl
	call	ToneDB_Find_SubToneRecord
	ld	a, (xiz+2)
	and	a, 192
	srl	a, 6
	ld	c, a
	extz	wa
	muls	wa, 21
	add	wa, 16
	lda	xhl, (xhl+wa)
	extz	bc
	ld	xwa, (Payload_Bss_Start+0x64a6:24)
	ld	a, (xwa+29351)
	ld	e, a
	extz	de
	ld	a, (xiz+1)
	extz	wa
	pushw wa
	ld	wa, bc
	ld	xbc, xhl
	call	WaveSel_StageA1_FromToneSlot
	ld	xbc, xhl
	ld	a, (xiz+2)
	and	a, 63
	extz	wa
	extz	xwa
	add	xbc, xwa
	ld	a, (xiz+3)
	ld	l, a
	extz	hl
	lda	xwa, (Payload_Bss_Start+0x63a0:24)
	ld	xde, xwa
	ld	wa, hl
	calr	DSP_ParamWrite_BlockCopy
	ld	l, (xiz+3)
	extz	hl

; Common tail of the query family: copy the 6 request bytes to 0x045210.
VoiceParamFinalize_CopyToWorkArea:
	ld ix, 0:i3
	cp ix, 6:i3
	jr nc, VoiceParamFinalize_CallDispatch

; The 6-iteration header copy packet[i] -> 0x045210+i.
VoiceParamFinalize_CopyLoop:
	ld wa, ix
	extz xwa
	ld xbc, xiz
	add xbc, xwa
	ld wa, ix
	extz xwa
	ld xde, Payload_Bss_Start+0x639a
	add xde, xwa
	ld a, (xbc)
	ld (xde), a
	inc 1, ix
	cp ix, 6:i3
	jr c, VoiceParamFinalize_CopyLoop

; Emit the reply: InterCPU_DMA_Send(A = packet[+4] reply tag, BC = HL+6,
; XDE = 0x045210).  HL is the payload length returned by the case body, so a
; case that produced nothing still sends a bare 6-byte echo.  This is the ONLY
; sub->main transmission in region 10 -- address 0x031E64 is the call site to
; breakpoint when sub->main traffic disappears.
VoiceParamFinalize_CallDispatch:
	ld a, (xiz + 4)
	ld c, a
	extz bc
	inc 6, hl
	lda xwa, (Payload_Bss_Start+0x639a:24)
	ld xde, xwa
	ld wa, bc
	ld bc, hl
	call InterCPU_DMA_Send

; Shared exit; also the direct (reply-less) exit of every action case.
VoiceParamFinalize_Return:
	pop xiz
	ret

; DSP_WriteVoiceParam -- Write DSP voice parameter by mode
; Dispatches on voice+16 bits 7:6 for 4 modes (0x00/0x40/0x80/0xC0).
; Copy a run of bytes out of a part's patch record, gated on the record format.
; Entry: WA = part index, BC = byte offset inside the record, DE = length,
;        stacked long at (XSP+0x0A) = destination pointer.
; Exit:  HL = bytes copied, or 0 when the record is rejected.  'retd 4'.
; Gate: A = patchrec[+0x10] & 0xC0.  0x00 and 0x80 copy; 0x40 and 0xC0 return 0.
; Sole caller: DSP_Cmd2B_VoiceParamWrite 0x035D46, whose caller
; DSP_Cmd2B_PostProcess (0x035D4A) DROPS the reply entirely when HL == 0 --
; see findings.  Uses Math_Multiply32 0x03D8CA as a plain 32-bit multiply for
; part*0x11F.
DSP_WriteVoiceParam:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), de
	ld (xsp + 4), bc
	ld iz, wa
	ld wa, iz
	extz xwa
	ld xbc, 0x11F
	call Math_Multiply32
	lda xwa, (Part_PatchRecord_Ptr:24)
	add xwa, xhl
	ld xwa, (xwa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0xC0
	jr z, DSP_WriteVoiceParam_ModeC0
	cp a, 0x80
	jr z, DSP_WriteVoiceParam_Mode80
	cp a, 0x40
	jr z, DSP_WriteVoiceParam_Mode40
	cp a, 0:i3
	jr nz, DSP_WriteVoiceParam_Return
	ld wa, iz
	extz xwa
	ld xbc, 0x11F
	call Math_Multiply32
	lda xwa, (Part_PatchRecord_Ptr:24)
	add xwa, xhl
	ld xbc, (xwa)
	ld wa, (xsp + 4)
	extz xwa
	add xbc, xwa
	ld wa, (xsp + 2)
	ld xde, (xsp + 10)
	calr DSP_ParamWrite_BlockCopy
	ld hl, (xsp + 2)
	jr DSP_WriteVoiceParam_Return

; Format byte 0x40: HL = 0, nothing copied.
DSP_WriteVoiceParam_Mode40:
	ld hl, 0:i3
	jr DSP_WriteVoiceParam_Return

; Format byte 0x80: identical copy path to the 0x00 case.
DSP_WriteVoiceParam_Mode80:
	ld wa, iz
	extz xwa
	ld xbc, 0x11F
	call Math_Multiply32
	lda xwa, (Part_PatchRecord_Ptr:24)
	add xwa, xhl
	ld xbc, (xwa)
	ld wa, (xsp + 4)
	extz xwa
	add xbc, xwa
	ld wa, (xsp + 2)
	ld xde, (xsp + 10)
	calr DSP_ParamWrite_BlockCopy
	ld hl, (xsp + 2)
	jr DSP_WriteVoiceParam_Return

; Format byte 0xC0: HL = 0, nothing copied.
DSP_WriteVoiceParam_ModeC0:
	ld hl, 0:i3

; Frame teardown and 'retd 0x0004'.
DSP_WriteVoiceParam_Return:
	popw iz
	inc 4, xsp
	retd 0x4

; Return the partial-present byte of a tone record.
; Entry: WA/BC = the {lo,hi} tone selector, XDE = 1-byte destination.
; Exit:  *XDE = tonerec[+0x11]; HL = 1.
; Calls ToneDB_Find_ToneRecord 0x03206F.  Sole caller: DSP_Cmd2B_ReadParam11
; 0x035D0A.  tonerec+0x11 is the bit-per-partial presence byte (bits 0/2/4/6).
DSP_ReadVoiceParam11:	.include "includes/generated/cc900/DSP_ReadVoiceParam11.s"	; C: cc900/dsp_voice_params.c

; The alternate preset resolver selected by ToneGen_GlobalFlags (0x041343) bit 0.
; Entry: WA = selector low byte, BC = selector high byte.
; Exit:  XHL = patch-record pointer.
; Identical arithmetic to ToneDB_Find_PatchRecord_Preset (0x031F87) except that
; the bank table comes from ToneDB_RootPtr->+0x6C instead of ->+0x04:
;   C   = byte[RelBase + Root->+0x6C + hi]
;   idx = (C << 7) + lo
;   k   = u16[RelBase + Root->+0x6C + 0x80 + 2*idx]
;   rec = RelBase + u32[RelBase + Root->+0x08 + 4*k]
; There is NO bank validity filter on this path (unlike 0x031F71), and no
; fallback to record #0.  Root->+0x6C is referenced nowhere else in the image.
ToneDB_Find_ToneRecord_CoeffPath:
	ld de, bc
	extz xde
	ld xbc, (ToneDB_RootPtr:24)
	ld xbc, (xbc + 108)
	add xbc, xde
	add xbc, (ToneDB_RelBase:24)
	ld c, (xbc)
	extz bc
	ld xde, (ToneDB_RootPtr:24)
	ld xhl, (xde + 108)
	add xhl, 0x80
	sll bc, 7
	add bc, wa
	add bc, bc
	ld wa, bc
	extz xwa
	add xwa, xhl
	add xwa, (ToneDB_RelBase:24)
	ld bc, (xwa)
	ld xwa, (ToneDB_RootPtr:24)
	ld xhl, (xwa + 8)
	ld wa, bc
	sll wa, 2
	extz xwa
	add xwa, xhl
	add xwa, (ToneDB_RelBase:24)
	ld xhl, (xwa)
	ld xwa, (ToneDB_RelBase:24)
	add xwa, xhl
	ld xhl, xwa
	ret

ToneDB_Find_PatchRecord:
	cp bc, 7:i3
	jr ule, ToneDB_Find_PatchRecord_Preset
	cp bc, 0x40
	jr z, ToneDB_Find_PatchRecord_Preset
	cp bc, 0x41
	jr z, ToneDB_Find_PatchRecord_Preset
	cp bc, 0x70
	jr nz, ToneDB_Find_PatchRecord_UserA

ToneDB_Find_PatchRecord_Preset:
	ld de, bc
	extz xde
	ld xbc, (ToneDB_RootPtr:24)
	ld xbc, (xbc + 4)
	add xbc, xde
	add xbc, (ToneDB_RelBase:24)
	ld c, (xbc)
	extz bc
	ld xde, (ToneDB_RootPtr:24)
	ld xhl, (xde + 4)
	add xhl, 0x80
	sll bc, 7
	add bc, wa
	add bc, bc
	ld wa, bc
	extz xwa
	add xwa, xhl
	add xwa, (ToneDB_RelBase:24)
	ld bc, (xwa)
	ld xwa, (ToneDB_RootPtr:24)
	ld xhl, (xwa + 8)
	ld wa, bc
	sll wa, 2
	extz xwa
	add xwa, xhl
	add xwa, (ToneDB_RelBase:24)
	ld xhl, (xwa)
	ld xwa, (ToneDB_RelBase:24)
	add xwa, xhl
	ld xhl, xwa
	jrl ToneDB_Find_PatchRecord_Return

ToneDB_Find_PatchRecord_UserA:
	cp bc, 0x10
	jr nz, ToneDB_Find_PatchRecord_UserB
	extz xwa
	ld xbc, 0x1D6
	call Math_Multiply32
	add xhl, 0x10
	add xhl, (Payload_Bss_Start+0x64a6:24)
	jr ToneDB_Find_PatchRecord_Return

ToneDB_Find_PatchRecord_UserB:
	cp bc, 0x15
	jr nz, ToneDB_Find_PatchRecord_KitA
	extz xwa
	ld xbc, 0x1D6
	call Math_Multiply32
	add xhl, 0x10
	add xhl, (Payload_Bss_Start+0x64a2:24)
	jr ToneDB_Find_PatchRecord_Return

ToneDB_Find_PatchRecord_KitA:
	cp bc, 0x50
	jr nz, ToneDB_Find_PatchRecord_KitB
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	lda xhl, (xwa+18816)
	jr ToneDB_Find_PatchRecord_Return

ToneDB_Find_PatchRecord_KitB:
	cp bc, 0x55
	jr nz, ToneDB_Find_PatchRecord_Default
	and wa, 0x3
	extz xwa
	ld xbc, 0x2927
	call Math_Multiply32
	add xhl, 0x4980
	add xhl, (Payload_Bss_Start+0x64a2:24)
	jr ToneDB_Find_PatchRecord_Return

ToneDB_Find_PatchRecord_Default:
	ld xwa, (ToneDB_RootPtr:24)
	ld xhl, (xwa + 8)
	ld xwa, (ToneDB_RelBase:24)
	add xwa, xhl
	ld xhl, (xwa)
	ld xwa, (ToneDB_RelBase:24)
	add xwa, xhl
	ld xhl, xwa

ToneDB_Find_PatchRecord_Return:
	ret

; ToneDB_Find_ToneRecord -- Resolve voice buffer pointer
; Checks flag at 0x041343 and dispatches to one of two lookup functions.
; Referenced 10 times throughout the DSP processing code.
ToneDB_Find_ToneRecord:	.include "includes/generated/cc900/ToneDB_Find_ToneRecord.s"	; C: cc900/dsp_voice_params_c_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceBuf_TypeSelector_EFFMatch, ToneDB_Find_ToneRecord + 15
	.set	VoiceBuf_TypeSelector_NoMatch, ToneDB_Find_ToneRecord + 18

; Map a logical partial index to its packed position inside a tone record, or
; report that the partial is absent.
; Entry: WA = part index, BC = partial index p (0..3).
; Exit:  L = packed rank, or 0xFF when partial p is not present.
; Body: if the part's selector-high byte (0x041382+part*0x11F) >= 0x10 and
;       p != 0, L = p is returned unchanged (RAM user tones / kits are not
;       packed).  Otherwise mask = table[0x00FB4E + 2*p]; if
;       (Part_PatchRecord_Ptr[part][+0x11] & mask) == 0 the partial is absent
;       (L = 0xFF); else L = the number of present partials among indices
;       1..p.  Callers pass the result straight into the 0x51-byte partial
;       block address patchrec + 0x66 + 0x51*L.
; Callers: 0x032253 and 0x032345 (both inside VoiceParam_Update).
VoiceBuf_TypeSelector_MatchEpilogue:
	ld e, a
	extz de
	muls de, 0x11F
	lda xhl, (Payload_Bss_Start+0x250c:24)
	cp	(xhl+de), 0x10
	jr c, VoiceChanScan_LoopBody
	cp c, 0:i3
	jr nz, VoiceChanScan_ReturnPUnchanged

; Test mask[p] against tonerec+0x11; jump to the absent path if clear.
VoiceChanScan_LoopBody:
	ld e, c
	extz de
	ld ix, de
	add ix, ix
	lda xiy, (VoiceChanScan_SlotEnableMask:24)
	ld e, a
	extz de
	muls de, 0x11F
	lda xhl, (Part_PatchRecord_Ptr:24)
	ld	xde, (xhl+de)
	ld e, (xde + 17)
	extz de
	and	de, (xiy+ix)
	jr z, VoiceChanScan_Epilogue
	ld w, 0x0:opc
	ld b, 0x1:opc
	ld e, c
	inc 1, e
	cp b, e
	jr nc, VoiceChanScan_LoopNext

; Count loop body: B = 1..p, W += 1 for each present partial.
VoiceChanScan_MatchFound:
	ld e, b
	extz de
	ld ix, de
	add ix, ix
	lda xiy, (VoiceChanScan_SlotEnableMask:24)
	ld e, a
	extz de
	muls de, 0x11F
	lda xhl, (Part_PatchRecord_Ptr:24)
	ld	xde, (xhl+de)
	ld e, (xde + 17)
	extz de
	and	de, (xiy+ix)
	jr z, VoiceChanScan_NoMatch
	inc 1, w

; Count loop increment and termination test.
VoiceChanScan_NoMatch:
	inc 1, b
	ld e, c
	inc 1, e
	cp b, e
	jr c, VoiceChanScan_MatchFound

; C = W (the accumulated rank).
VoiceChanScan_LoopNext:
	ld c, w
	jr VoiceChanScan_ReturnPUnchanged

; C = 0xFF -- partial not present in this tone record.
VoiceChanScan_Epilogue:
	ld c, 0xFF:opc

; L = C; ret.
; ★ Renamed 2026-09-25 from VoiceChanScan_Data: the `L = C; ret` arm: partial index p returned unpacked (RAM tones / kits).
VoiceChanScan_ReturnPUnchanged:
	ld l, c
	ret

; (Re)bind a part's cached tone-record pointer and its four partial-block
; pointers.  This is the routine that makes a part playable: every downstream
; consumer dereferences Part_PatchRecord_Ptr[part] and
; Part_Slot_Sub_Base[part][p] without re-checking them.
; Entry: A = part index (0..25), BC = selector low byte, DE = selector high byte.
; Exit:  nothing; writes Part_PatchRecord_Ptr (0x04136E+part*0x11F) and
;        Part_Slot_Sub_Base + 0x25*p (0x0413D6/0x0413FB/0x041420/0x041445).
; Body:
;   Part flags word (0x041368+part*0x11F) bit 0 SET = RAM user tone:
;     hi in {0x40,0x41,0x50} -> record pointer = ToneDB_RamBankA + 0x4980,
;                               partial pointers left alone;
;     otherwise              -> record pointer = UserTone_VelSplit_Base
;                               (0x044FCE) and each partial p is bound to
;                               record + 0x66 + 0x51*p.
;   bit 0 CLEAR = ROM tone: part <= 0x0F uses ToneDB_Find_ToneRecord (which
;     honours ToneGen_GlobalFlags bit 0), part > 0x0F uses
;     ToneDB_Find_PatchRecord directly.  Each partial p is then bound to
;     patchrec + 0x66 + 0x51*PARTIAL_FIND_RANK(part,p), or, when the partial is
;     absent (rank 0xFF), to the shared default block
;     ToneDB_RelBase + Root->+0xAC.
;   Bit 1 of the same flags word selects between two byte-identical copies of
;   the ROM path (0x0321FE.. and 0x0322F0..).
; Caller: WaveSel_Rebuild_PartCaches 0x032949.
VoiceParam_Update:
	dec 2, xsp
	pushw_erp 0xFA
	ld (xsp + 2), a
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xhl, (Part_Record_Base:24)
	ld	wa, (xhl+wa)
	bit 0, wa
	jrl z, VoiceParam_Update_InactivePath
	cp de, 0x40
	jr z, VoiceParam_Update_ActivePath
	cp de, 0x41
	jr z, VoiceParam_Update_ActivePath
	cp de, 0x50
	jr nz, VoiceParam_Update_ActiveEFF

; RAM path, banks 0x40/0x41/0x50: record pointer = ToneDB_RamBankA + 0x4980.
VoiceParam_Update_ActivePath:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	ld bc, wa
	lda xde, (Part_PatchRecord_Ptr:24)
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	lda xwa, (xwa+18816)
	ld	(xde+bc), xwa
	jrl EFFSlotScan_Epilogue

; RAM path, other banks: record pointer = 0x044FCE, then bind 4 partials.
VoiceParam_Update_ActiveEFF:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	ld bc, wa
	lda xde, (Part_PatchRecord_Ptr:24)
	lda xwa, (Payload_Bss_Start+0x6158:24)
	ld	(xde+bc), xwa
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jrl nc, EFFSlotScan_Epilogue

; p = 0..3: Part_Slot_Sub_Base[part][p] = record + 0x66 + 0x51*p.
VoiceParam_Update_ActiveMain:
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	lda	xhl, (xbc+wa)
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	ld bc, wa
	lda xix, (Part_PatchRecord_Ptr:24)
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x51
	ld iy, wa
	add iy, 0x66
	ld	xwa, (xix+bc)
	lda	xwa, (xwa+iy)
	ld	(xhl+de), xwa
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jr c, VoiceParam_Update_ActiveMain
	jrl EFFSlotScan_Epilogue

; ROM path taken when flags bit 1 is set; resolves and stores the record ptr.
VoiceParam_Update_InactivePath:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xhl, (Part_Record_Base:24)
	ld	wa, (xhl+wa)
	bit 1, wa
	jrl z, EFFSlotScan_AltLoopBody
	cp (xsp + 2), 0xF
	jr ugt, VoiceParam_Update_InactiveSub
	ld wa, bc
	ld bc, de
	calr ToneDB_Find_ToneRecord
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	(xbc+wa), xhl
	jr VoiceParam_Update_InactiveEpilogue

; part > 0x0F: bypass ToneDB_Find_ToneRecord and call ToneDB_Find_PatchRecord.
VoiceParam_Update_InactiveSub:
	ld wa, bc
	ld bc, de
	calr ToneDB_Find_PatchRecord
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	(xbc+wa), xhl

; Initialise the p = 0..3 partial-binding loop counter (QIZH).
VoiceParam_Update_InactiveEpilogue:
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jrl nc, EFFSlotScan_Epilogue

; Absent partial: bind to the shared default block RelBase + Root->+0xAC.
EFFSlotScan_LoopBody:
	ld a, (xsp + 2)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	ld c, a
	extz bc
	ld wa, de
	calr VoiceBuf_TypeSelector_MatchEpilogue
	cp l, 0xFF
	jr nz, EFFSlotScan_AssignPath
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	lda	xhl, (xbc+wa)
	ld xbc, (ToneDB_RelBase:24)
	ld xwa, (ToneDB_RootPtr:24)
	ld	xwa, (xwa+172)
	add xwa, xbc
	ld	(xhl+de), xwa
	jr EFFSlotScan_LoopNext

; Present partial: bind to patchrec + 0x66 + 0x51*rank.
EFFSlotScan_AssignPath:
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	lda	xix, (xbc+wa)
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	ld bc, wa
	lda xiy, (Part_PatchRecord_Ptr:24)
	ld a, l
	extz wa
	muls wa, 0x51
	ld hl, wa
	add hl, 0x66
	ld	xwa, (xiy+bc)
	lda	xwa, (xwa+hl)
	ld	(xix+de), xwa

; p++ and loop while p < 4.
EFFSlotScan_LoopNext:
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jrl c, EFFSlotScan_LoopBody
	jrl EFFSlotScan_Epilogue

; Duplicate ROM path taken when flags bit 1 is clear.
EFFSlotScan_AltLoopBody:
	cp (xsp + 2), 0xF
	jr ugt, EFFSlotScan_AltMatchPath
	ld wa, bc
	ld bc, de
	calr ToneDB_Find_ToneRecord
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	(xbc+wa), xhl
	jr EFFSlotScan_AltAssign

; part > 0x0F variant of the duplicate path.
EFFSlotScan_AltMatchPath:
	ld wa, bc
	ld bc, de
	calr ToneDB_Find_PatchRecord
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	(xbc+wa), xhl

; Duplicate partial-binding loop init.
EFFSlotScan_AltAssign:
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jrl nc, EFFSlotScan_Epilogue

; Duplicate loop head (absent-partial branch follows).
EFFSlotScan_AltLoopNext:
	ld a, (xsp + 2)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	ld c, a
	extz bc
	ld wa, de
	calr VoiceBuf_TypeSelector_MatchEpilogue
	cp l, 0xFF
	jr nz, EFFSlotScan_AltEpilogue
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	lda	xhl, (xbc+wa)
	ld xbc, (ToneDB_RelBase:24)
	ld xwa, (ToneDB_RootPtr:24)
	ld	xwa, (xwa+172)
	add xwa, xbc
	ld	(xhl+de), xwa
	jr EFFSlotScan_OuterNext

; Duplicate present-partial binding.
EFFSlotScan_AltEpilogue:
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	lda	xix, (xbc+wa)
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	ld bc, wa
	lda xiy, (Part_PatchRecord_Ptr:24)
	ld a, l
	extz wa
	muls wa, 0x51
	ld hl, wa
	add hl, 0x66
	ld	xwa, (xiy+bc)
	lda	xwa, (xwa+hl)
	ld	(xix+de), xwa

; Duplicate loop increment.
EFFSlotScan_OuterNext:
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jrl c, EFFSlotScan_AltLoopNext

; Shared exit for every path above.
EFFSlotScan_Epilogue:
	popw_erp 0xFA
	inc 2, xsp
	ret

WaveSel_StageA1_SelectTables:
	cp de, 0xC0
	jr z, VoiceBufIdx_TableC
	cp de, 0x80
	jr z, VoiceBufIdx_TableB
	cp de, 0x40
	jr z, VoiceBufIdx_TableA
	cp de, 0:i3
	jr nz, WaveSel_StageA1_IndexLookup
	ld xde, (ToneDB_RootPtr:24)
	ld xhl, (xde + 12)
	ld xde, (ToneDB_RootPtr:24)
	ld xix, (xde + 24)
	ld xde, (ToneDB_RootPtr:24)
	ld	iy, (xde+234)
	jr WaveSel_StageA1_IndexLookup

; SET family 0x40: index table Root->+0x14, VSEL array Root->+0x20,
; stride Root->+0xF0.
VoiceBufIdx_TableA:
	ld xde, (ToneDB_RootPtr:24)
	ld xhl, (xde + 20)
	ld xde, (ToneDB_RootPtr:24)
	ld xix, (xde + 32)
	ld xde, (ToneDB_RootPtr:24)
	ld	iy, (xde+240)
	jr WaveSel_StageA1_IndexLookup

; SET family 0x80: Root->+0x10 / Root->+0x1C / stride Root->+0xEA.
VoiceBufIdx_TableB:
	ld xde, (ToneDB_RootPtr:24)
	ld xhl, (xde + 16)
	ld xde, (ToneDB_RootPtr:24)
	ld xix, (xde + 28)
	ld xde, (ToneDB_RootPtr:24)
	ld	iy, (xde+234)
	jr WaveSel_StageA1_IndexLookup

; SET family 0xC0: same triple as family 0x00 (Root->+0x0C / +0x18 / +0xEA).
VoiceBufIdx_TableC:
	ld xde, (ToneDB_RootPtr:24)
	ld xhl, (xde + 12)
	ld xde, (ToneDB_RootPtr:24)
	ld xix, (xde + 24)
	ld xde, (ToneDB_RootPtr:24)
	ld	iy, (xde+234)

WaveSel_StageA1_IndexLookup:
	sll bc, 7
	add bc, wa
	add bc, bc
	ld wa, bc
	extz xwa
	add xwa, xhl
	add xwa, (ToneDB_RelBase:24)
	ld xwa, (xwa)
	ld bc, iy
	mul xbc, wa
	add xbc, xix
	ld xhl, xbc
	add xhl, (ToneDB_RelBase:24)
	ret

WaveSel_StageA1_FindVelSplit:
	dec 2, xsp
	pushw iz
	ld (xsp + 2), a
	ld a, (xsp + 8)
	ld w, (xsp + 10)
	ldfr_berp C, 0xF8
	extz iz
	and iz, 0x7F
	ldfr_berp E, 0xF4
	extz iy
	and iy, 0xF
	ldfr_berp E, 0xF0
	extz ix
	and ix, 0xC0
	ld c, e
	extz bc
	and bc, 0x30
	cp bc, 0x10
	jr z, WaveSel_StageA1_UserTonePath
	cp bc, 0x30
	jr z, WaveSel_StageA1_PresetPath
	cp bc, 0x20
	jr z, WaveSel_StageA1_PresetPath
	cp bc, 0:i3
	jrl nz, WaveSel_StageA1_Return

WaveSel_StageA1_PresetPath:
	ld wa, iz
	ld bc, iy
	ld de, ix
	calr WaveSel_StageA1_SelectTables
	jrl WaveSel_StageA1_Return

WaveSel_StageA1_UserTonePath:
	ld bc, ix
	cp bc, 0x40
	jrl z, SlotParam_WriteType5
	cp bc, 0xC0
	jr z, SlotParam_WriteType2
	cp bc, 0x80
	jr z, SlotParam_WriteType2
	cp bc, 0:i3
	jrl nz, WaveSel_StageA1_Return

; User-tone path, SET family 0x00/0x80/0xC0: choose RAM bank by comparing
; Part_PatchRecord_Ptr[part] against ToneDB_RamBankB (0x045318).
SlotParam_WriteType2:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+bc)
	lda xbc, (Payload_Bss_Start+0x64a2:24)
	cp xde, xbc
	jr c, SlotParam_WriteType3
	cp a, 0xFF
	jr nz, SlotParam_WriteType4

; XHL = ToneDB_RamBankA + 0x1D6*utidx + 0x1BA + 0x0B*p.
SlotParam_WriteType3:
	ld a, (xsp + 2)
	ld c, a
	extz bc
	muls bc, 0xB
	ld a, w
	extz wa
	muls wa, 0x1D6
	ld de, wa
	add de, bc
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xhl, (xwa+de)
	lda xhl, (xhl+442)
	jrl WaveSel_StageA1_Return

; XHL = ToneDB_RamBankB + 0x1D6*utidx + 0x1BA + 0x0B*p.
SlotParam_WriteType4:
	ld a, (xsp + 2)
	ld c, a
	extz bc
	muls bc, 0xB
	ld a, w
	extz wa
	muls wa, 0x1D6
	ld de, wa
	add de, bc
	ld xwa, (Payload_Bss_Start+0x64a2:24)
	lda	xhl, (xwa+de)
	lda xhl, (xhl+442)
	jrl WaveSel_StageA1_Return

; User-tone path, SET family 0x40 (drum kit): same bank comparison.
SlotParam_WriteType5:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Part_PatchRecord_Ptr:24)
	ld	xde, (xde+bc)
	lda xbc, (Payload_Bss_Start+0x64a2:24)
	cp xde, xbc
	jr c, SlotParam_WriteType6
	cp a, 0xFF
	jr nz, SlotParam_WriteType7

; XHL = ToneDB_RamBankA + 0x50*utidx + 0x4AE1 + 0x0B*p.
SlotParam_WriteType6:
	ld a, (xsp + 2)
	ld c, a
	extz bc
	muls bc, 0xB
	ld a, w
	extz wa
	muls wa, 0x50
	ld de, wa
	add de, bc
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xhl, (xwa+de)
	lda xhl, (xhl+19169)
	jr WaveSel_StageA1_Return

; XHL = ToneDB_RamBankB + 0x2927*Part_UserToneIndex[part] + 0x50*utidx
; + 0x4AE1 + 0x0B*p.  Uses Math_Multiply32 for the 0x2927 multiply.
SlotParam_WriteType7:
	ld c, w
	extz bc
	muls bc, 0x50
	ld iz, bc
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x250b:24)
	ld	a, (xbc+wa)
	extz wa
	extz xwa
	ld xbc, 0x2927
	call Math_Multiply32
	lda	xwa, (xhl+iz)
	ld xbc, xwa
	add xbc, (Payload_Bss_Start+0x64a2:24)
	ld a, (xsp + 2)
	extz wa
	muls wa, 0xB
	add wa, 0x4AE1
	lda	xhl, (xbc+wa)

WaveSel_StageA1_Return:
	popw iz
	inc 2, xsp
	retd 0x4

WaveSel_StageA1_FromPatchBlock:	.include "includes/generated/cc900/WaveSel_StageA1_FromPatchBlock.s"	; C: cc900/dsp_voice_params_r_17a.c

WaveSel_StageA1_FromToneSlot:	.include "includes/generated/cc900/WaveSel_StageA1_FromToneSlot.s"	; C: cc900/dsp_voice_params_d_9a.c

WaveSel_Cache_VelSplitPtr:
	dec 4, xsp
	ld (xsp), c
	ld (xsp + 2), a
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	ld	wa, (xbc+wa)
	bit 0, wa
	jr z, WaveSel_Cache_VelSplitPtr_Path0
	ld a, (xsp)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	exts xde
	add xde, xwa
	ld a, (xsp)
	extz wa
	muls wa, 0xB
	add wa, 0x1AA
	lda xbc, (Payload_Bss_Start+0x6158:24)
	exts xwa
	add xwa, xbc
	ld (xde + 4), xwa
	jr WaveSel_Cache_VelSplitPtr_Path1

; Part flags bit 0 clear: the VSEL pointer comes from
; WaveSel_StageA1_FromPatchBlock 0x0325FC instead of the fixed RAM formula.
WaveSel_Cache_VelSplitPtr_Path0:
	ld a, (xsp + 2)
	ld e, a
	extz de
	ld a, (xsp)
	ld c, a
	extz bc
	ld wa, de
	calr WaveSel_StageA1_FromPatchBlock
	ld a, (xsp)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+de)
	ld (xwa + 4), xhl

; Frame teardown.
WaveSel_Cache_VelSplitPtr_Path1:
	inc 4, xsp
	ret

WaveSel_StageA2_FindSetDesc:
	pushw iz
	ld l, a
	extz hl
	and hl, 0x7F
	ld e, c
	extz de
	and de, 0xF
	ld a, c
	extz wa
	and wa, 0xC0
	cp wa, 0x80
	jr z, VoiceTablePtr_Epilogue
	cp wa, 0x40
	jr z, VoiceTablePtr_SelectC
	cp wa, 0xC0
	jr z, VoiceTablePtr_Select
	cp wa, 0:i3
	jrl nz, WaveSel_StageA2_IndexLookup

; SET families 0x00 and 0xC0; ToneGen_GlobalFlags bit 2 chooses Root->+0x9C
; over Root->+0x24.
VoiceTablePtr_Select:
	ld wa, (Voice_GlobalFlags:24)
	bit 2, wa
	jr z, VoiceTablePtr_SelectA
	ld xwa, (ToneDB_RootPtr:24)
	ld	xix, (xwa+156)
	jr VoiceTablePtr_SelectB

; Standard index table Root->+0x24.
VoiceTablePtr_SelectA:
	ld xwa, (ToneDB_RootPtr:24)
	ld xix, (xwa + 36)

; SET array Root->+0x30, stride Root->+0xEC.
VoiceTablePtr_SelectB:
	ld xwa, (ToneDB_RootPtr:24)
	ld xiy, (xwa + 48)
	ld xwa, (ToneDB_RootPtr:24)
	ld	iz, (xwa+236)
	jr WaveSel_StageA2_IndexLookup

; SET family 0x40; bit 2 chooses Root->+0xA4 over Root->+0x2C.
VoiceTablePtr_SelectC:
	ld wa, (Voice_GlobalFlags:24)
	bit 2, wa
	jr z, VoiceTablePtr_SelectD
	ld xwa, (ToneDB_RootPtr:24)
	ld	xix, (xwa+164)
	jr VoiceTablePtr_Common

; Standard index table Root->+0x2C.
VoiceTablePtr_SelectD:
	ld xwa, (ToneDB_RootPtr:24)
	ld xix, (xwa + 44)

; SET array Root->+0x38, stride Root->+0xF2.
VoiceTablePtr_Common:
	ld xwa, (ToneDB_RootPtr:24)
	ld xiy, (xwa + 56)
	ld xwa, (ToneDB_RootPtr:24)
	ld	iz, (xwa+242)
	jr WaveSel_StageA2_IndexLookup

; SET family 0x80; bit 2 chooses Root->+0xA0 over Root->+0x28.
VoiceTablePtr_Epilogue:
	ld wa, (Voice_GlobalFlags:24)
	bit 2, wa
	jr z, VoiceTablePtr_StdIndex28
	ld xwa, (ToneDB_RootPtr:24)
	ld	xix, (xwa+160)
	jr VoiceTablePtr_Select2

; Standard index table Root->+0x28.
; ★ Renamed 2026-09-25 from VoiceTablePtr_Data: arm selecting the standard index table Root->+0x28.
VoiceTablePtr_StdIndex28:
	ld xwa, (ToneDB_RootPtr:24)
	ld xix, (xwa + 40)

; SET array Root->+0x34, stride Root->+0xEC.
VoiceTablePtr_Select2:
	ld xwa, (ToneDB_RootPtr:24)
	ld xiy, (xwa + 52)
	ld xwa, (ToneDB_RootPtr:24)
	ld	iz, (xwa+236)

WaveSel_StageA2_IndexLookup:
	sll de, 7
	add de, hl
	add de, de
	ld wa, de
	extz xwa
	add xwa, xix
	add xwa, (ToneDB_RelBase:24)
	ld xwa, (xwa)
	ld hl, wa
	ld wa, iz
	mul xwa, hl
	add xwa, xiy
	ld xhl, xwa
	add xhl, (ToneDB_RelBase:24)
	popw iz
	ret

WaveSel_StageA2_FromToneRec:	.include "includes/generated/cc900/WaveSel_StageA2_FromToneRec.s"	; C: cc900/dsp_voice_params_r_17a.c

WaveSel_StageA2_FromVelZone:	.include "includes/generated/cc900/WaveSel_StageA2_FromVelZone.s"	; C: cc900/dsp_voice_params_d_10a.c

WaveSel_Cache_SetDescPtr:	.include "includes/generated/cc900/WaveSel_Cache_SetDescPtr.s"	; C: cc900/dsp_voice_params_c_7a.c

WaveSel_Rebuild_PartCaches:	.include "includes/generated/cc900/WaveSel_Rebuild_PartCaches.s"	; C: cc900/dsp_voice_params_d_10a_qizinc2.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceInit_EFFScanLoop, WaveSel_Rebuild_PartCaches + 75
	.set	VoiceInit_EFFScanMatch, WaveSel_Rebuild_PartCaches + 102
	.set	VoiceInit_EFFScanNext, WaveSel_Rebuild_PartCaches + 136
	.set	VoiceInit_AltPath, WaveSel_Rebuild_PartCaches + 146
	.set	VoiceInit_AltPath2, WaveSel_Rebuild_PartCaches + 154
	.set	VoiceInit_Epilogue, WaveSel_Rebuild_PartCaches + 202

ToneDB_Resolve_NamedToneRecord:
	pushw iz
	ld l, (xsp + 6)
	ld iy, wa
	and iy, 0x7F
	ld iz, bc
	and iz, 0x1F
	and bc, 0x20
	ld wa, bc
	cp wa, 0x20
	jr z, ToneDB_Resolve_NamedToneRecord_User
	cp wa, 0:i3
	jrl nz, ToneDB_Resolve_NamedToneRecord_Return
	ld xwa, (ToneDB_RootPtr:24)
	ld xde, (xwa + 116)
	ld xwa, (ToneDB_RootPtr:24)
	ld xbc, (xwa + 120)
	ld xwa, (ToneDB_RootPtr:24)
	ld	hl, (xwa+238)
	ld wa, iz
	sll wa, 7
	add wa, iy
	add wa, wa
	extz xwa
	add xwa, xde
	add xwa, (ToneDB_RelBase:24)
	ld xwa, (xwa)
	ld iy, wa
	ld wa, hl
	mul xwa, iy
	add xwa, xbc
	add xwa, (ToneDB_RelBase:24)
	ld xix, xwa
	jr ToneDB_Resolve_NamedToneRecord_Return

ToneDB_Resolve_NamedToneRecord_User:
	ld a, l
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xbc+wa)
	lda xwa, (Payload_Bss_Start+0x64a2:24)
	cp xbc, xwa
	jr c, VoiceBuf_Lookup_FlagClear
	cp l, 0xFF
	jr nz, VoiceBuf_Lookup_Common

; XIX = ToneDB_RamBankA + 0x4AA7 + 0x50*E.
VoiceBuf_Lookup_FlagClear:
	ld a, e
	extz wa
	muls wa, 0x50
	ld bc, wa
	add bc, 0x4AA7
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	lda	xix, (xwa+bc)
	jr ToneDB_Resolve_NamedToneRecord_Return

; XIX = ToneDB_RamBankB + 0x2927*Part_UserToneIndex[part] + 0x4AA7 + 0x50*E.
VoiceBuf_Lookup_Common:
	ld a, e
	extz wa
	muls wa, 0x50
	ld iz, wa
	ld a, l
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x250b:24)
	ld	a, (xbc+wa)
	extz wa
	extz xwa
	ld xbc, 0x2927
	call Math_Multiply32
	lda	xix, (xhl+iz)
	add xix, (Payload_Bss_Start+0x64a2:24)
	lda xix, (xix+19111)

ToneDB_Resolve_NamedToneRecord_Return:
	ld xhl, xix
	popw iz
	retd 0x2

ToneDB_Find_SubToneRecord:	.include "includes/generated/cc900/ToneDB_Find_SubToneRecord.s"	; C: cc900/dsp_voice_params_d_10a.c

Partial_Build_Present_Word:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Part_PresentWord:24)
	ld	bc, (xde+bc)
	extz xbc
	and xbc, 0xFFFF3FF0
	ld de, bc
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xhl, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xhl+bc)
	ld l, (xbc + 18)
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xix+bc)
	bitm 0, (xbc + 17)
	jr z, Partial_Try_Unison_Slot0
	set 0, de
	jr VoiceFlags_Bit0Set

Partial_Try_Unison_Slot0:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Payload_Bss_Start+0x24fc:24)
	ld	bc, (xix+bc)
	extz xbc
	bit 15, bc
	jr z, VoiceFlags_Bit0Set
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xix+bc)
	bitm 2, (xbc + 17)
	jr z, VoiceFlags_Bit0Set
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xix+bc)
	ld c, (xbc + 93)
	and c, 0xF
	cp c, 0x8
	jr ugt, VoiceFlags_Bit0Set
	cp c, 0:i3
	jr c, VoiceFlags_Bit0Set
	or de, 0x4001

; (tonerec[+0x12] & 0x03) == 1 -> Part_Slot_Flags[0] (0x0413EE) |= 0x8000.
VoiceFlags_Bit0Set:
	ld c, l
	and c, 0x3
	cp c, 1:i3
	jr nz, VoiceFlags_Bit1Check
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Payload_Bss_Start+0x2578:24)
	orw	(xix+bc), 0x8000
	jr VoiceFlags_Bit1Set

; Otherwise Part_Slot_Flags[0] &= 0x7FFF.
VoiceFlags_Bit1Check:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Payload_Bss_Start+0x2578:24)
	andw	(xix+bc), 0x7fff

; tonerec[+0x11] bit 2 -> set bit 1 of the present word.
VoiceFlags_Bit1Set:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xix+bc)
	bitm 2, (xbc + 17)
	jr z, Partial_Try_Unison_Slot1
	set 1, de
	jr VoiceFlags_Bit2Set

Partial_Try_Unison_Slot1:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Payload_Bss_Start+0x24fc:24)
	ld	bc, (xix+bc)
	extz xbc
	bit 15, bc
	jr z, VoiceFlags_Bit2Set
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xix+bc)
	bitm 0, (xbc + 17)
	jr z, VoiceFlags_Bit2Set
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xix+bc)
	ld c, (xbc + 93)
	and c, 0xF
	cp c, 0x8
	jr ugt, VoiceFlags_Bit2Set
	cp c, 0:i3
	jr c, VoiceFlags_Bit2Set
	or de, 0x8002

; (tonerec[+0x12] & 0x0C) == 4 -> Part_Slot_Flags[1] (0x041413) |= 0x8000.
VoiceFlags_Bit2Set:
	ld c, l
	and c, 0xC
	cp c, 4:i3
	jr nz, VoiceFlags_Bit3Check
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Payload_Bss_Start+0x259d:24)
	orw	(xix+bc), 0x8000
	jr VoiceFlags_Bit3Set

; Otherwise Part_Slot_Flags[1] &= 0x7FFF.
VoiceFlags_Bit3Check:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Payload_Bss_Start+0x259d:24)
	andw	(xix+bc), 0x7fff

; tonerec[+0x11] bit 4 -> set bit 2 of the present word.
VoiceFlags_Bit3Set:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xix+bc)
	bitm 4, (xbc + 17)
	jr z, VoiceFlags_Bit4Check
	set 2, de

; (tonerec[+0x12] & 0x30) == 0x10 -> Part_Slot_Flags[2] (0x041438) |= 0x8000.
VoiceFlags_Bit4Check:
	ld c, l
	and c, 0x30
	cp c, 0x10
	jr nz, VoiceFlags_Bit4Set
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Payload_Bss_Start+0x25c2:24)
	orw	(xix+bc), 0x8000
	jr VoiceFlags_Bit5Check

; Otherwise Part_Slot_Flags[2] &= 0x7FFF.
VoiceFlags_Bit4Set:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Payload_Bss_Start+0x25c2:24)
	andw	(xix+bc), 0x7fff

; tonerec[+0x11] bit 6 -> set bit 3 of the present word.
VoiceFlags_Bit5Check:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xix+bc)
	bitm 6, (xbc + 17)
	jr z, VoiceFlags_Bit5Set
	set 3, de

; (tonerec[+0x12] & 0xC0) == 0x40 -> Part_Slot_Flags[3] (0x04145D) |= 0x8000.
VoiceFlags_Bit5Set:
	ld c, l
	and c, 0xC0
	cp c, 0x40
	jr nz, VoiceFlags_Bit6Check
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xhl, (Payload_Bss_Start+0x25e7:24)
	orw	(xhl+bc), 0x8000
	jr VoiceFlags_Bit6Set

; Otherwise Part_Slot_Flags[3] &= 0x7FFF.
VoiceFlags_Bit6Check:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xhl, (Payload_Bss_Start+0x25e7:24)
	andw	(xhl+bc), 0x7fff

; Write the assembled word back to Part_PresentWord (0x04136A+part*0x11F).
; Bits 0..3 = "partial p present"; bit 14 = partial 0 is unison-substituted by
; partial 1; bit 15 = partial 1 is unison-substituted by partial 0.  The
; substitution is only taken when Part_Flags0A bit 15 is set, the OTHER
; partial is present, and (tonerec[+0x5D] & 0x0F) is in 0..8.
VoiceFlags_Bit6Set:
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	ld	(xbc+wa), de
	ret

; Clamp a signed 16-bit value to 0..0x7F.
; Entry: WA = value.  Exit: HL = clamped value.
; Used only by Part_Apply_KeyTranspose (5 call sites).
SignedClamp_Zero:	.include "includes/generated/cc900/SignedClamp_Zero.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SignedClamp_Max, SignedClamp_Zero + 11
	.set	SignedClamp_InRange, SignedClamp_Zero + 17

; Fetch the base key number of one partial from its cached partial-block
; pointer, honouring the unison substitution recorded in Part_PresentWord.
; Entry: WA = part index, C = partial index p (0..3).
; Exit:  HL = block[+1] (a 0..0x7F key number, 0x80 = "no key" sentinel).
; p == 0: Part_PresentWord bit 14 set -> read partial 1's block (0x0413FB),
;         else partial 0's (0x0413D6).
; p == 1: Part_PresentWord bit 15 set -> read partial 0's block, else 1's.
; p == 2 / 3: read 0x041420 / 0x041445 directly.
; Sole caller: Part_Apply_KeyTranspose 0x032E6E.
; ★ Renamed 2026-09-25 from AlgoType_TableLookup: header: fetch the base key number of one partial (HL = block[+1]).
Partial_GetBaseKey:	.include "includes/generated/cc900/Partial_GetBaseKey.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Partial_GetBaseKey_P0Own, Partial_GetBaseKey + 63
	.set	Partial_GetBaseKey_P1, Partial_GetBaseKey + 85
	.set	Partial_GetBaseKey_P1Own, Partial_GetBaseKey + 132
	.set	Partial_GetBaseKey_P2, Partial_GetBaseKey + 154
	.set	Partial_GetBaseKey_P3, Partial_GetBaseKey + 176

; Recompute the cached key-range of every partial of one part after a
; transpose change, then apply the two-partial key spread.
; Entry: A = part index.  Exit: nothing.
; Writes Part_Struct_Base + part*0x11F + 0x6E + 0x25*p + 0x23 and + 0x24 for
; p = 0..3 (the partial's key-range low/high bytes).
; Step 1: t = byte[0x041376 + part*0x11F] - 0x40 (signed transpose).  For each
;   partial, k = Partial_Get_BaseKey; if k != 0x80 then k = clamp(k + t); both
;   +0x23 and +0x24 receive k.
; Step 2 (0x032F09): if Part_Struct[+0x0A] bit 15 is set, patchrec[+0x5D] bit 6
;   is set, the two saved keys of partials 0 and 1 are EQUAL and not 0x80, the
;   pair is spread apart: k < 0x40 -> lo = clamp(k-0x10), hi = clamp(lo+0x28);
;   k >= 0x40 -> lo = clamp(k+0x10), hi = clamp(lo-0x28).
;   (patchrec[+0x5D] & 0x0F) == 9  -> both partials get {+0x23 = lo,
;                                     +0x24 = hi};
;   (patchrec[+0x5D] & 0x0F) <  0x0A -> partial 0 gets +0x23 = lo and
;                                     partial 1 gets +0x23 = hi;
;   otherwise nothing is written.
; Callers: Voice_Portamento_OnHandler_C0Mode 0x02A15A, Voice_CC_Pan 0x02A358,
; VoiceAlloc_Apply_Algo_Group0 (x4), VoiceSlot_FullInit 0x0348DD,
; VoiceSlot_AltInit 0x0349B8.
; The LLVM source calls this EnvTranspose_UpdateLoop; nothing here touches an
; envelope generator (see [UNCERTAIN]).
EnvTranspose_UpdateLoop:
	lda xsp, (xsp - 16)
	push xiz
	ld (xsp + 18), a
	ld a, (xsp + 18)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	ld (xsp + 4), xwa
	ld a, (xsp + 18)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2500:24)
	ld	a, (xbc+wa)
	sub a, 0x40
	exts wa
	ld (xsp + 8), wa
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jrl nc, EnvTranspose_SubPath1

; p = 0..3: fetch base key, add the transpose, clamp, stash in the frame.
EnvTranspose_ApplyPath:
	ld a, (xsp + 18)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	ld c, a
	extz bc
	ld wa, de
	calr Partial_GetBaseKey
	ldto_berp A, 0xFB
	extz wa
	add wa, wa
	lda xbc, (xsp + 10)
	ld	(xbc+wa), hl
	cp hl, 0x80
	jr z, EnvTranspose_LoopNext
	ldto_berp A, 0xFB
	extz wa
	add wa, wa
	lda xbc, (xsp + 10)
	ld	wa, (xbc+wa)
	add wa, (xsp + 8)
	calr SignedClamp_Zero
	ldto_berp A, 0xFB
	extz wa
	add wa, wa
	lda xbc, (xsp + 10)
	ld	(xbc+wa), hl

; Store the result to the partial block's +0x23 and +0x24.
EnvTranspose_LoopNext:
	ldto_berp A, 0xFB
	extz wa
	add wa, wa
	lda xbc, (xsp + 10)
	ld	wa, (xbc+wa)
	ld e, a
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld bc, wa
	add bc, 0x6E
	ld xwa, (xsp + 4)
	lda	xwa, (xwa+bc)
	ld (xwa + 35), e
	ldto_berp A, 0xFB
	extz wa
	add wa, wa
	lda xbc, (xsp + 10)
	ld	wa, (xbc+wa)
	ld e, a
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x25
	ld bc, wa
	add bc, 0x6E
	ld xwa, (xsp + 4)
	lda	xwa, (xwa+bc)
	ld (xwa + 36), e
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jrl c, EnvTranspose_ApplyPath

; Gate and entry of the partial-0/partial-1 key spread.
EnvTranspose_SubPath1:
	ld a, (xsp + 18)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld a, (xwa + 93)
	ldfr_berp A, 0xFB
	ld xwa, (xsp + 4)
	ld wa, (xwa + 10)
	extz xwa
	bit 15, wa
	jrl z, EnvTranspose_Epilogue
	bit_erpb 0xFB, 0x06
	jrl z, EnvTranspose_Epilogue
	ld wa, (xsp + 12)
	cp wa, (xsp + 10)
	jrl nz, EnvTranspose_Epilogue
	cpw (xsp + 10), 0x80
	jrl z, EnvTranspose_Epilogue
	ld iz, (xsp + 10)
	ld wa, iz
	cp wa, 0x40
	jr ge, EnvTranspose_SubPath2
	ld wa, iz
	sub wa, 0x10
	calr SignedClamp_Zero
	ld iz, hl
	ld wa, iz
	add wa, 0x28
	calr SignedClamp_Zero
	jr EnvTranspose_SubPath3

; k >= 0x40: lo = clamp(k+0x10), hi = clamp(lo-0x28).
EnvTranspose_SubPath2:
	ld wa, iz
	add wa, 0x10
	calr SignedClamp_Zero
	ld iz, hl
	ld wa, iz
	sub wa, 0x28
	calr SignedClamp_Zero

; (patchrec[+0x5D] & 0x0F) == 9: write both +0x23 and +0x24 of both partials.
EnvTranspose_SubPath3:
	ldto_berp A, 0xFB
	and a, 0xF
	cp a, 0x9
	jr nz, EnvTranspose_SubPath4
	ldto_berp C, 0xF8
	ld xwa, (xsp + 4)
	ld	(xwa+145), c
	ldto_berp C, 0xF8
	ld xwa, (xsp + 4)
	ld	(xwa+182), c
	ld c, l
	ld xwa, (xsp + 4)
	ld	(xwa+146), c
	ld xwa, (xsp + 4)
	ld	(xwa+183), l
	jr EnvTranspose_Epilogue

; (patchrec[+0x5D] & 0x0F) < 0x0A: write only +0x23 of both partials.
EnvTranspose_SubPath4:
	ldto_berp A, 0xFB
	and a, 0xF
	cp a, 0xA
	jr nc, EnvTranspose_Epilogue
	ldto_berp C, 0xF8
	ld xwa, (xsp + 4)
	ld	(xwa+145), c
	ld xwa, (xsp + 4)
	ld	(xwa+182), l

; Frame teardown.
EnvTranspose_Epilogue:
	pop xiz
	lda xsp, (xsp + 16)
	ret

; Recompute bits 0 and 1 of one entry of a part's 4-byte routing-flag record by
; polling all four partial blocks.
; Entry: A = part index, C = group selector (0/1/2), E = value to match (0..3).
; Exit:  nothing; updates one byte in the part structure.
; Target byte = Part_Struct_Base + part*0x11F + 0x27 + 0x10*C + 4*E.
; The byte's low two bits are cleared first.  If (target+3) != 0 and
; (target+1) & 0x55 != 0, bit 1 is set and the routine returns.  Otherwise all
; four partials are scanned: b = block_p[+0x06] for C == 0, block_p[+0x26] for
; C == 1, block_p[+0x38] for C == 2, where block_p = Part_Slot_Sub_Base[part][p].
; If b bit 5 is set and (b >> 6) == E, bit 0 of the target is set.
; MEASURED but not interpreted: what the three group offsets select is not
; established; b bits 6-7 are clearly a 2-bit destination code and bit 5 an
; enable.  The XHL load of Part_PatchRecord_Ptr at 0x033007..0x033014 is dead.
; Callers: TVF_Refresh_Sounding_Voices (6 sites), VoiceAlloc_Apply_Algo_Group0
; (6 sites), Voice_Part_ResetSlotRouting (2), VoiceSlot_FullInit/AltInit (2).
AlgoFlag_Write:	.include "includes/generated/cc900/AlgoFlag_Write.s"	; C: cc900/dsp_voice_params_w_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AlgoFlag_Write_OuterStart, AlgoFlag_Write + 86
	.set	AlgoFlag_Write_InnerLoop, AlgoFlag_Write + 93
	.set	AlgoFlag_Write_InnerMatch, AlgoFlag_Write + 148
	.set	AlgoFlag_Write_InnerNext, AlgoFlag_Write + 189
	.set	AlgoFlag_Write_OuterMatch, AlgoFlag_Write + 228
	.set	AlgoFlag_Write_OuterNext, AlgoFlag_Write + 247
	.set	AlgoFlag_Write_Epilogue, AlgoFlag_Write + 254

; Byte-for-byte twin of 0x032FD5 operating on bits 2 and 3 of the same target
; byte: the mask is 0xF3 instead of 0xFC, the "already forced" probe reads
; (target+2) instead of (target+3), and the bits set are 3 (forced) and 2
; (matched) instead of 1 and 0.  Same entry contract, same callers (a different
; set of 16 call sites), same dead XHL load at 0x033107..0x033114.
AlgoFlag_Write_Bit3:	.include "includes/generated/cc900/AlgoFlag_Write_Bit3.s"	; C: cc900/dsp_voice_params_w_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AlgoFlag_Write_Bit3_OuterStart, AlgoFlag_Write_Bit3 + 86
	.set	AlgoFlag_Write_Bit3_InnerLoop, AlgoFlag_Write_Bit3 + 93
	.set	AlgoFlag_Write_Bit3_InnerMatch, AlgoFlag_Write_Bit3 + 148
	.set	AlgoFlag_Write_Bit3_InnerNext, AlgoFlag_Write_Bit3 + 189
	.set	AlgoFlag_Write_Bit3_OuterMatch, AlgoFlag_Write_Bit3 + 228
	.set	AlgoFlag_Write_Bit3_OuterNext, AlgoFlag_Write_Bit3 + 247
	.set	AlgoFlag_Write_Bit3_Epilogue, AlgoFlag_Write_Bit3 + 254

; Writes ONE 16-bit routing word into an output-slot record.
; Inputs: XWA = base address of the output-slot record (part+0x6E+0x25*slot),
;         E   = the DSP channel/slot selector used for the mask tests,
;         XBC = pointer to the slot's gate record; only (XBC+1) -- an 8-bit enable byte -- is
;               read,
;         stack arg at (XSP+0x0C) = the 8-bit payload value,
;         stack arg at (XSP+0x0E) = L = which of the three routing words to write (0/1/2).
; Output: (XWA + 0x1A + 2*L) = payload | one of six constants.  Nothing else is touched.
; Mechanism: (XBC+1) is ANDed with SlotEnableMaskA[E] (0x00FB56 = {1,4,0x10,0x40}).  If that
; is zero the routine returns without writing anything -- that is the "slot not routed" case.
; It is then ANDed with SlotEnableMaskB[E] (0x00FB5E = {2,8,0x20,0x80}); non-zero selects the
; constants {0x00C0, 0xC000, 0x3300} for L = {0,1,2}, zero selects {0x0040, 0x4000, 0x1100}.
; So the enable byte carries TWO bits per slot: bit(2s) = routed at all, bit(2s+1) = which of
; the two level/pan encodings to stamp into the word.
; Caller: EFF_RoutingInit only (0x033463).  Callee-cleans 4 bytes of arguments (retd 0x0004).
RoutingFlag_Encode:
	dec 4, xsp
	push xiz
	ld (xsp + 4), xwa
	ld a, (xsp + 12)
	ld l, (xsp + 14)
	ldfr_berp E, 0xF0
	extz ix
	ld iy, ix
	add iy, iy
	lda xiz, (SlotEnableMaskA:24)
	ld w, (xbc + 1)
	ldfr_berp W, 0xF0
	extz ix
	and	ix, (xiz+iy)
	jrl z, RoutingFlag_Epilogue
	extz de
	add de, de
	lda xix, (SlotEnableMaskB:24)
	ld c, (xbc + 1)
	extz bc
	and	bc, (xix+de)
	jr z, RoutingFlag_Chan2
	ld c, l
	cp c, 2:i3
	jr z, RoutingFlag_Chan1
	cp c, 1:i3
	jr z, RoutingFlag_Chan0
	cp c, 0:i3
	jrl nz, RoutingFlag_Epilogue
	ld c, l
	extz bc
	add bc, bc
	add bc, 0x1A
	extz wa
	ld de, wa
	or de, 0xC0
	ld xwa, (xsp + 4)
	ld	(xwa+bc), de
	jrl RoutingFlag_Epilogue

; MaskB set, L==1: writes payload | 0xC000.
RoutingFlag_Chan0:
	ld c, l
	extz bc
	add bc, bc
	add bc, 0x1A
	extz wa
	ld de, wa
	or de, 0xC000
	ld xwa, (xsp + 4)
	ld	(xwa+bc), de
	jr RoutingFlag_Epilogue

; MaskB set, L==2: writes payload | 0x3300.
RoutingFlag_Chan1:
	ld c, l
	extz bc
	add bc, bc
	add bc, 0x1A
	extz wa
	ld de, wa
	or de, 0x3300
	ld xwa, (xsp + 4)
	ld	(xwa+bc), de
	jr RoutingFlag_Epilogue

; MaskB clear: re-tests L and takes the second constant set; L==0 writes payload with bit 6 set.
RoutingFlag_Chan2:
	ld c, l
	cp c, 2:i3
	jr z, RoutingFlag_Chan1B
	cp c, 1:i3
	jr z, RoutingFlag_Chan0B
	cp c, 0:i3
	jr nz, RoutingFlag_Epilogue
	ld c, l
	extz bc
	add bc, bc
	add bc, 0x1A
	extz wa
	ld de, wa
	set 6, de
	ld xwa, (xsp + 4)
	ld	(xwa+bc), de
	jr RoutingFlag_Epilogue

; MaskB clear, L==1: writes payload with bit 14 set (0x4000).
RoutingFlag_Chan0B:
	ld c, l
	extz bc
	add bc, bc
	add bc, 0x1A
	extz wa
	ld de, wa
	set 14, de
	ld xwa, (xsp + 4)
	ld	(xwa+bc), de
	jr RoutingFlag_Epilogue

; MaskB clear, L==2: writes payload | 0x1100.
RoutingFlag_Chan1B:
	ld c, l
	extz bc
	add bc, bc
	add bc, 0x1A
	extz wa
	ld de, wa
	or de, 0x1100
	ld xwa, (xsp + 4)
	ld	(xwa+bc), de

; Common exit; also the "nothing to route" early-out.  pop XIZ / inc 4,XSP / retd 4.
RoutingFlag_Epilogue:
	pop xiz
	inc 4, xsp
	retd 0x4

; Routing-word writer #0 of three near-identical siblings (see also 0x033327 and 0x033372).
; Inputs: XWA = output-slot record base, BC = the payload index, E = the expected 2-bit
;         "section" value, stack arg (XSP+4) = B = the slot's descriptor flag byte.
; Writes (XWA + 0x1A + 2*BC) = E | 0x00C0 (if B bit4 set) or E with bit 6 set (if clear),
; but ONLY when B bit5 is set AND (B>>6) == E.  Otherwise it writes nothing.
; That guard -- bit5 = "slot enabled", bits 7:6 = "which effect section owns the slot" -- is
; repeated verbatim in all three siblings; only the constants and the target word differ.
; Caller: EFF_RoutingInit_SlotPath (0x0334BF).  retd 0x0002.
SlotRouting_WriteSingle:	.include "includes/generated/cc900/SlotRouting_WriteSingle.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SlotRouting_Chan0, SlotRouting_WriteSingle + 50
	.set	SlotRouting_Chan1PreWrite, SlotRouting_WriteSingle + 72

; Routing-word writer #1.  Same guard and same argument layout as SlotRouting_WriteSingle;
; the payload constants are 0xC000 (B bit4 set) and bit 14 (clear).
; Caller: EFF_RoutingInit_LoopNext (0x033502), which supplies slot-record byte +0x26.
SlotRouting_Chan1:	.include "includes/generated/cc900/SlotRouting_Chan1.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SlotRouting_Chan2, SlotRouting_Chan1 + 50
	.set	SlotRouting_Chan3PreWrite, SlotRouting_Chan1 + 72

; Routing-word writer #2.  Constants 0x3300 (B bit4 set) and 0x1100 (clear).
; Caller: EFF_RoutingInit_SubLoop (0x033544), which supplies slot-record byte +0x38.
SlotRouting_Chan3:	.include "includes/generated/cc900/SlotRouting_Chan3.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SlotRouting_Chan4, SlotRouting_Chan3 + 50
	.set	SlotRouting_Epilogue, SlotRouting_Chan3 + 73

; Rebuilds the routing words of ONE output slot of ONE part for all four DSP sub-slots.
; Inputs: A = part index (0..0x19), C = output-slot index (0..3), E = routing word selector
;         (0/1/2), i.e. which of the slot's three routing words this pass owns.
; Effects: zeroes (part + 0x6E + 0x25*C + 0x1A + 2*E) first, then loops i = 0..3 and, per i,
;   reads the gate byte at (part + 0x11F-scaled base + (E<<4) + (i<<2)) + 0x27:
;     - if (gate & 0x0A) != 0  -> RoutingFlag_Encode(payload=i, word=E)
;     - else if (gate & 0x05) != 0 -> one of the SlotRouting_* writers chosen by E:
;         E==0 -> SlotRouting_WriteSingle with slot-record byte +0x06
;         E==1 -> SlotRouting_Chan1        with slot-record byte +0x26
;         E==2 -> SlotRouting_Chan3        with slot-record byte +0x38
;     - else nothing.
; Callers: Voice_Part_ResetSlotRouting (0x0345F9), VoiceSlot_FullInit_Loop2Next (0x034949)
; and VoiceSlot_AltInit_Loop2Next (0x034A28) -- always inside a 4x3 (slot x word) double loop,
; so a full rebuild of a part costs 12 calls.
EFF_RoutingInit:
	lda xsp, (xsp - 10)
	pushw_erp 0xFA
	ld (xsp + 6), e
	ld (xsp + 8), c
	ld (xsp + 10), a
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x25
	ld de, wa
	add de, 0x6E
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+de)
	ld (xsp + 2), xwa
	ld a, (xsp + 6)
	extz wa
	add wa, wa
	ld bc, wa
	add bc, 0x1A
	ld xwa, (xsp + 2)
	ldw	(xwa+bc), 0x0000
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jrl nc, EFF_RoutingInit_Epilogue

; i-loop body: computes the gate-record address and branches on (gate & 0x0A).
EFF_RoutingInit_LoopBody:
	ldto_berp A, 0xFB
	extz wa
	ld bc, wa
	sla bc, 2
	ld a, (xsp + 6)
	extz wa
	sla wa, 4
	ld de, wa
	add de, bc
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xbc, (xwa+de)
	lda xbc, (xbc + 39)
	ld a, (xbc)
	and a, 0xA
	jr z, EFF_RoutingInit_SlotPath
	ld a, (xsp + 8)
	ld e, a
	extz de
	ld a, (xsp + 6)
	extz wa
	pushw wa
	ldto_berp A, 0xFB
	extz wa
	pushw wa
	ld xwa, (xsp + 6)
	calr RoutingFlag_Encode
	jrl EFF_RoutingInit_SubLoopNext

; (gate & 0x0A)==0 path: tests (gate & 0x05) then dispatches on E to the SlotRouting_* writers.
EFF_RoutingInit_SlotPath:
	ld a, (xbc)
	and a, 0x5
	jrl z, EFF_RoutingInit_SubLoopNext
	ld a, (xsp + 6)
	cp a, 2:i3
	jrl z, EFF_RoutingInit_SubLoop
	cp a, 1:i3
	jr z, EFF_RoutingInit_LoopNext
	cp a, 0:i3
	jrl nz, EFF_RoutingInit_SubLoopNext
	ld a, (xsp + 6)
	ld c, a
	extz bc
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x25
	ld ix, wa
	add ix, 0x6E
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xhl, (Part_Record_Base:24)
	exts xwa
	add xwa, xhl
	ld	xwa, (xwa+ix)
	ld a, (xwa + 6)
	extz wa
	pushw wa
	ld xwa, (xsp + 4)
	calr SlotRouting_WriteSingle
	jrl EFF_RoutingInit_SubLoopNext

; E==1 arm: pushes slot-record byte +0x26 and calls SlotRouting_Chan1.
EFF_RoutingInit_LoopNext:
	ld a, (xsp + 6)
	ld c, a
	extz bc
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x25
	ld ix, wa
	add ix, 0x6E
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xhl, (Part_Record_Base:24)
	exts xwa
	add xwa, xhl
	ld	xwa, (xwa+ix)
	ld a, (xwa + 38)
	extz wa
	pushw wa
	ld xwa, (xsp + 4)
	calr SlotRouting_Chan1
	jr EFF_RoutingInit_SubLoopNext

; E==2 arm: pushes slot-record byte +0x38 and calls SlotRouting_Chan3.
EFF_RoutingInit_SubLoop:
	ld a, (xsp + 6)
	ld c, a
	extz bc
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x25
	ld ix, wa
	add ix, 0x6E
	ld a, (xsp + 10)
	extz wa
	muls wa, 0x11F
	lda xhl, (Part_Record_Base:24)
	exts xwa
	add xwa, xhl
	ld	xwa, (xwa+ix)
	ld a, (xwa + 56)
	extz wa
	pushw wa
	ld xwa, (xsp + 4)
	calr SlotRouting_Chan3

; i-loop increment and back-edge (i < 4).
EFF_RoutingInit_SubLoopNext:
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jrl c, EFF_RoutingInit_LoopBody

; pop QIZ / lda XSP,XSP+0x0A / ret.
EFF_RoutingInit_Epilogue:
	popw_erp 0xFA
	lda xsp, (xsp + 10)
	ret

; The master "an algorithm changed, recompute everything" entry for one part.
; Input: A = part index; C = a flag (0 = full recompute, non-zero = refresh only).
; Reads the algorithm type = descriptor[0x5D] & 0x0F and splits three ways:
;   type == 7 and C == 0 : sets part+0x0A bit 15, then writes the coefficient triple
;       part+0x63/0x64/0x65 = {0x0F,0x4F,0x96} if part+0x0A bit 14 is set, else {1,1,1}, then
;       runs the full six-call recompute (Dispatch1/2 for channels 0 and 1, then
;       DSP_ChanFreq_WritePacket1 and 2).
;   type == 7 and C != 0 : refresh only -- masks part+0x63 with 0x05 and optionally sets bit 1.
;   type != 7            : sets part+0x0A bit 15 only if bit 14 is set, runs the same six-call
;       recompute, then sets part+0x02 bit 9 when the type is 0x0A and clears it otherwise;
;       if bit 14 was clear it instead CLEARS part+0x0A bit 15, clears part+0x02 bit 9 and
;       zeroes the coefficient triple.
; So part+0x0A bit 14 ("a real algorithm is loaded") is the master enable and bit 15 is the
; derived "engaged" flag that every other routine in this region tests.
; Callers: VoiceSlot_FullInit (0x03489D), VoiceSlot_AltInit (0x034977) and one site outside
; the region.
AlgoType_StateWrite:
	dec 4, xsp
	ld (xsp + 2), a
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xde, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xde+wa)
	ld a, (xwa + 93)
	and a, 0xF
	ld (xsp), a
	cp (xsp), 0x7
	jrl nz, AlgoType_StateWrite_RefreshD
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x24fc:24)
	orw	(xde+wa), 0x8000
	cp c, 0:i3
	jrl nz, AlgoType_StateWrite_RefreshA
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	ld	wa, (xbc+wa)
	bit 14, wa
	jr z, AlgoType_StateWrite_Type7
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2555:24)
	ld	(xbc+wa), 0x0f
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2556:24)
	ld	(xbc+wa), 0x4f
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2557:24)
	ld	(xbc+wa), 0x96
	jr AlgoType_StateWrite_NonType7

; type 7, part+0x0A bit 14 clear: coefficient triple := {1,1,1}.
AlgoType_StateWrite_Type7:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2555:24)
	ld	(xbc+wa), 0x01
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2556:24)
	ld	(xbc+wa), 0x01
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2557:24)
	ld	(xbc+wa), 0x01

; The six-call recompute: Dispatch1(ch0), Dispatch2(ch0), Dispatch1(ch1), Dispatch2(ch1),
; ChanFreq_WritePacket1, ChanFreq_WritePacket2.
AlgoType_StateWrite_NonType7:
	ld a, (xsp + 2)
	extz wa
	ld bc, 0:i3
	calr DSP_AlgoType_Dispatch1
	ld a, (xsp + 2)
	extz wa
	ld bc, 0:i3
	calr DSP_AlgoType_Dispatch2
	ld a, (xsp + 2)
	extz wa
	ld bc, 1:i3
	calr DSP_AlgoType_Dispatch1
	ld a, (xsp + 2)
	extz wa
	ld bc, 1:i3
	calr DSP_AlgoType_Dispatch2
	ld a, (xsp + 2)
	extz wa
	calr DSP_ChanFreq_WritePacket1
	ld a, (xsp + 2)
	extz wa
	calr DSP_ChanFreq_WritePacket2
	jr AlgoType_StateWrite_RefreshC

; C != 0 refresh path for type 7: part+0x63 &= 0x05, then bit 1 set if part+0x0A bit 14 set.
AlgoType_StateWrite_RefreshA:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	ld	wa, (xbc+wa)
	bit 14, wa
	jr z, AlgoType_StateWrite_RefreshB
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2555:24)
	and	(xbc+wa), 0x05
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2555:24)
	set	1, (xbc+wa)
	jr AlgoType_StateWrite_RefreshC

; Same but bit 14 clear: part+0x63 &= 0x05 only.
AlgoType_StateWrite_RefreshB:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2555:24)
	and	(xbc+wa), 0x05

; Clears part+0x02 bit 9 and falls into the epilogue.
AlgoType_StateWrite_RefreshC:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	andw	(xbc+wa), 0xfdff
	jrl AlgoType_StateWrite_Epilogue

; Entry for algorithm type != 7: tests part+0x0A bit 14 and runs the recompute if set.
AlgoType_StateWrite_RefreshD:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	ld	wa, (xbc+wa)
	bit 14, wa
	jrl z, AlgoType_StateWrite_RefreshF
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	orw	(xbc+wa), 0x8000
	ld a, (xsp + 2)
	extz wa
	ld bc, 0:i3
	calr DSP_AlgoType_Dispatch1
	ld a, (xsp + 2)
	extz wa
	ld bc, 0:i3
	calr DSP_AlgoType_Dispatch2
	ld a, (xsp + 2)
	extz wa
	ld bc, 1:i3
	calr DSP_AlgoType_Dispatch1
	ld a, (xsp + 2)
	extz wa
	ld bc, 1:i3
	calr DSP_AlgoType_Dispatch2
	ld a, (xsp + 2)
	extz wa
	calr DSP_ChanFreq_WritePacket1
	ld a, (xsp + 2)
	extz wa
	calr DSP_ChanFreq_WritePacket2
	cp (xsp), 0xA
	jr nz, AlgoType_StateWrite_RefreshE
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	orw	(xbc+wa), 0x0200
	jr AlgoType_StateWrite_RefreshG

; type != 0x0A: clears part+0x02 bit 9.
AlgoType_StateWrite_RefreshE:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	andw	(xbc+wa), 0xfdff
	jr AlgoType_StateWrite_RefreshG

; bit 14 clear: clears part+0x0A bit 15 and part+0x02 bit 9, then zeroes the coefficient triple.
AlgoType_StateWrite_RefreshF:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x24fc:24)
	andw	(xbc+wa), 0x7fff
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	andw	(xbc+wa), 0xfdff

; Writes part+0x63/0x64/0x65 = 0,0,0.
AlgoType_StateWrite_RefreshG:
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2555:24)
	ld	(xbc+wa), 0x00
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2556:24)
	ld	(xbc+wa), 0x00
	ld a, (xsp + 2)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2557:24)
	ld	(xbc+wa), 0x00

; inc 4,XSP / ret.
AlgoType_StateWrite_Epilogue:
	inc 4, xsp
	ret

; Computes DSP coefficient word #1 for (part, channel) and stores it at part+0x57+4*channel.
; Inputs: A = part index, C = channel (0 or 1).  Output: HL, and the store.
; Reads algorithm type = descriptor[0x5D] & 0x0F into B.  Types outside 0..0x0B fall straight
; through to the store with HL = 0 (i.e. "no coefficient").  Otherwise it takes a computed
; jump: `jp T, 0x033812 + DSP_AlgoType_Dispatch1_CaseOffsets[type]` with DSP_AlgoType_Dispatch1_CaseOffsets at 0x00FB66.
; Each arm reads a per-algorithm selector byte from 0x010FCE + 6*type + 2*channel, then uses
; it as a 0x66-byte stride into the word table at 0x011346, sub-indexed by 2*descriptor[0x5E]
; (or [0x60] for the second channel), and optionally ORs in a word from 0x011511.
; Callers: AlgoType_StateWrite (four call sites, channels 0 and 1 on both paths).
DSP_AlgoType_Dispatch1:
	ld hl, 0:i3
	ld e, a
	extz de
	muls de, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xde, (xix+de)
	ld e, (xde + 93)
	and e, 0xF
	ld b, e
	extz de
	cp de, 0:i3
	jrl mi, DSP_AlgoType_Dispatch1_Store
	cp de, 0xB
	jrl gt, DSP_AlgoType_Dispatch1_Store
	add de, de
	lda xix, (DSP_AlgoType_Dispatch1_CaseOffsets:24)
	ld	de, (xix+de)
	lda xix, (DSP_AlgoType_Dispatch1_Arms:24)
	jp	t, (xix+de)

; NOT DATA -- this is the arm block of the computed jump above, entered at +0x00, +0x52,
; +0xE1 or +0x16C.  Arm at +0x00 serves algorithm types 0..3.
; ★ Renamed 2026-09-25 from DSP_AlgoType_Dispatch1_TableData: header: NOT DATA -- the arm block of the computed jump above.
DSP_AlgoType_Dispatch1_Arms:
	; Converted from a 364-byte `.byte` run. Framing: unidasm; every
	; instruction re-encoded and the whole run compared byte for byte.
	; 124 instructions, of which 1 needed a spelling search because
	; llvm-mc --disassemble refuses them (it can still ASSEMBLE them).
	ld	e, c
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, b
	extz	de
	muls	de, 6
	lda	xhl, (DSP_AlgoChannel_SelectorRecords:24)
	exts	xde
	add	xde, xhl
	ld	w, (xde+ix)
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_PatchRecord_Ptr:24)
	ld	xde, (xhl+de)
	ld	e, (xde+94)
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, w
	extz	de
	muls	de, 102
	lda	xhl, (DSP_ChanFreq_Dispatch1_Curves:24)
	exts	xde
	add	xde, xhl
	ld	hl, (xde+ix)
	jrl	DSP_AlgoType_Dispatch1_Store
; Arm for algorithm types 4, 5 and 7 (DSP_AlgoType_Dispatch1_CaseOffsets offset 0x52).  Splits on the channel:
; channel 0 uses descriptor[0x5E], channel 1 uses descriptor[0x60]; any other channel returns
; HL = 0.  No symbol exists here because the block was emitted as .byte.
DSP_AlgoType_D1_Arm_Type457:
	ld	e, c
	extz	de
	ld	iy, de
	add	iy, iy
	ld	e, b
	extz	de
	muls	de, 6
	lda	xix, (DSP_AlgoChannel_SelectorRecords:24)
	exts	xde
	add	xde, xix
	ld	w, (xde+iy)
	cp	c, 0:i3
	jr	nz, DSP_AlgoType_D1_Arm_Type457_Ch1
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_PatchRecord_Ptr:24)
	ld	xde, (xhl+de)
	ld	e, (xde+94)
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, w
	extz	de
	muls	de, 102
	lda	xhl, (DSP_ChanFreq_Dispatch1_Curves:24)
	exts	xde
	add	xde, xhl
	ld	hl, (xde+ix)
	jrl	DSP_AlgoType_Dispatch1_Store
; Channel-1 half of the type-4/5/7 arm.
DSP_AlgoType_D1_Arm_Type457_Ch1:
	cp	c, 1:i3
	jrl	nz, DSP_AlgoType_Dispatch1_Store
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_PatchRecord_Ptr:24)
	ld	xde, (xhl+de)
	ld	e, (xde+96)
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, w
	extz	de
	muls	de, 102
	lda	xhl, (DSP_ChanFreq_Dispatch1_Curves:24)
	exts	xde
	add	xde, xhl
	ld	hl, (xde+ix)
	jrl	DSP_AlgoType_Dispatch1_Store
; Arm for algorithm types 0x0A and 0x0B (DSP_AlgoType_Dispatch1_CaseOffsets offset 0xE1).  If the selector byte is
; 0xFF the coefficient lookup is skipped; either way it then ORs in a word from 0x011511
; indexed by the top two bits of the algorithm-descriptor byte at 0x011E16 + 0x27*type +
; 3*channel + 0x02.
DSP_AlgoType_D1_Arm_TypeAB:
	ld	e, c
	extz	de
	ld	iy, de
	add	iy, iy
	ld	e, b
	extz	de
	muls	de, 6
	lda	xix, (DSP_AlgoChannel_SelectorRecords:24)
	exts	xde
	add	xde, xix
	ld	w, (xde+iy)
	cp	w, 255
	jr	z, DSP_AlgoType_D1_Arm_TypeAB_Or
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_PatchRecord_Ptr:24)
	ld	xde, (xhl+de)
	ld	e, (xde+96)
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, w
	extz	de
	muls	de, 102
	lda	xhl, (DSP_ChanFreq_Dispatch1_Curves:24)
	exts	xde
	add	xde, xhl
	ld	hl, (xde+ix)
; The OR-in-from-0x011511 tail of the type-0x0A/0x0B arm (also the 0xFF-selector target).
DSP_AlgoType_D1_Arm_TypeAB_Or:
	ld	e, c
	extz	de
	muls	de, 3
	ld	iy, de
	ld	e, b
	extz	de
	muls	de, 39
	lda	xix, (DSP_AlgoDescriptor_Records:24)
	exts	xde
	add	xde, xix
	lda	xde, (xde+iy)
	ld	e, (xde+2)
	and	e, 192
	srl	e, 6
	extz	de
	add	de, de
	lda	xix, (EGEnv_ModeBits_Table:24)
	or	hl, (xix+de)

; Common store: (part + 0x57 + 4*channel) = HL.  Also the no-op arm for types 6, 8 and 9
; (DSP_AlgoType_Dispatch1_CaseOffsets offset 0x16C lands exactly here, leaving HL = 0).
DSP_AlgoType_Dispatch1_Store:
	extz bc
	sla bc, 2
	ld de, bc
	add de, 0x57
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	ld	(xwa+de), hl
	ret

; Coefficient word #2 for (part, channel); stored at part+0x59+4*channel.  Structurally
; identical to DSP_AlgoType_Dispatch1 but reads the SECOND selector byte of the 6-byte record
; at 0x010FCE (offset +1), looks up in the 0x66-stride table at 0x011016, and sub-indexes with
; descriptor[0x5F] (channel 0) / descriptor[0x61] (channel 1).
; Jump-offset table: 0x00FB7E, arm base 0x0339DE.
DSP_AlgoType_Dispatch2:
	ld hl, 0:i3
	ld e, a
	extz de
	muls de, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xde, (xix+de)
	ld e, (xde + 93)
	and e, 0xF
	ld b, e
	extz de
	cp de, 0:i3
	jrl mi, DSP_AlgoType_Dispatch2_Store
	cp de, 0xB
	jrl gt, DSP_AlgoType_Dispatch2_Store
	add de, de
	lda xix, (DSP_AlgoType_Dispatch2_CaseOffsets:24)
	ld	de, (xix+de)
	lda xix, (DSP_AlgoType_Dispatch2_Arms:24)
	jp	t, (xix+de)

; NOT DATA -- arm block of the computed jump; +0x00 serves algorithm types 0..3.
; ★ Renamed 2026-09-25 from DSP_AlgoType_Dispatch2_TableData: header: NOT DATA -- the arm block of the computed jump above.
DSP_AlgoType_Dispatch2_Arms:
	; Converted from a 331-byte `.byte` run, round-trip exact: these exact
	; mnemonics re-assemble to the original bytes. Entered by the computed
	; jump above; every interior arm label below falls on an instruction
	; boundary of this decode, which is what makes the linear framing right.
	ld	e, c
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, b
	extz	de
	muls	de, 6
	lda	xhl, (DSP_AlgoChannel_SelectorRecords:24)
	exts	xde
	add	xde, xhl
	lda	xde, (xde+ix)
	ld	w, (xde+1)
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_PatchRecord_Ptr:24)
	ld	xde, (xhl+de)
	ld	e, (xde+95)
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, w
	extz	de
	muls	de, 102
	lda	xhl, (DSP_ChanFreq_CurvePool:24)
	exts	xde
	add	xde, xhl
	ld	hl, (xde+ix)
	jrl	DSP_AlgoType_Dispatch2_Store
; Arm for algorithm types 4, 5 and 7 (offset 0x55).  Channel 0 -> descriptor[0x5F],
; channel 1 -> descriptor[0x61].
DSP_AlgoType_D2_Arm_Type457:
	ld	e, c
	extz	de
	ld	iy, de
	add	iy, iy
	ld	e, b
	extz	de
	muls	de, 6
	lda	xix, (DSP_AlgoChannel_SelectorRecords:24)
	exts	xde
	add	xde, xix
	lda	xde, (xde+iy)
	ld	w, (xde+1)
	cp	c, 0:i3
	jr	nz, DSP_AlgoType_D2_Arm_Type457_Ch1
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_PatchRecord_Ptr:24)
	ld	xde, (xhl+de)
	ld	e, (xde+95)
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, w
	extz	de
	muls	de, 102
	lda	xhl, (DSP_ChanFreq_CurvePool:24)
	exts	xde
	add	xde, xhl
	ld	hl, (xde+ix)
	jrl	DSP_AlgoType_Dispatch2_Store
; Channel-1 half of the type-4/5/7 arm of Dispatch2.
DSP_AlgoType_D2_Arm_Type457_Ch1:
	cp	c, 1:i3
	jrl	nz, DSP_AlgoType_Dispatch2_Store
	ld	e, a
	extz	de
	muls	de, 287
	lda	xhl, (Part_PatchRecord_Ptr:24)
	ld	xde, (xhl+de)
	ld	e, (xde+97)
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, w
	extz	de
	muls	de, 102
	lda	xhl, (DSP_ChanFreq_CurvePool:24)
	exts	xde
	add	xde, xhl
	ld	hl, (xde+ix)
	jr	DSP_AlgoType_Dispatch2_Store
; Arm for algorithm types 0x0A and 0x0B (offset 0xE6).  Selector byte 0xFF aborts to the
; store; otherwise it sub-indexes with the algorithm-descriptor byte at
; 0x011E16 + 0x27*type + 3*channel + 0x01.
DSP_AlgoType_D2_Arm_TypeAB:
	ld	e, c
	extz	de
	ld	iy, de
	add	iy, iy
	ld	e, b
	extz	de
	muls	de, 6
	lda	xix, (DSP_AlgoChannel_SelectorRecords:24)
	exts	xde
	add	xde, xix
	lda	xde, (xde+iy)
	ld	w, (xde+1)
	cp	w, 255
	jr	z, DSP_AlgoType_Dispatch2_Store
	ld	e, c
	extz	de
	muls	de, 3
	ld	ix, de
	ld	e, b
	extz	de
	muls	de, 39
	lda	xhl, (DSP_AlgoDescriptor_Records:24)
	exts	xde
	add	xde, xhl
	lda	xde, (xde+ix)
	ld	e, (xde+1)
	extz	de
	ld	ix, de
	add	ix, ix
	ld	e, w
	extz	de
	muls	de, 102
	lda	xhl, (DSP_ChanFreq_CurvePool:24)
	exts	xde
	add	xde, xhl
	ld	hl, (xde+ix)

; Common store: (part + 0x57 + 4*channel + 0x02) = HL.  Also the no-op arm for types 6, 8, 9.
DSP_AlgoType_Dispatch2_Store:
	extz bc
	sla bc, 2
	ld de, bc
	add de, 0x57
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+de)
	ld (xwa + 2), hl
	ret

; Input A = part index.  Returns HL = descriptor[0x5F] & 0x3F when the part's algorithm type is
; 0x0A or 0x0B, and returns with HL = 0 (and the flags from the compare) for every other type.
; Used by callers outside the region to ask "is this part running one of the two multi-tap
; algorithms, and if so which variant".
AlgoType_AB_Checker:	.include "includes/generated/cc900/AlgoType_AB_Checker.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	AlgoType_AB_LoadIndex, AlgoType_AB_Checker + 36

; Input A = part index.  Stores a 16-bit word at part+0x5F (0x0413C7).
; Only algorithm types 6 and 7 produce a value; every other type stores 0.
;   type 6: selector = byte at 0x010FD2 + 6*type; word = table[0x011478 + 0x66*selector +
;           2*descriptor[0x5E]] OR'd with the word at 0x011511 + 2*descriptor[0x60].
;   type 7: same but the sub-index comes from the algorithm-descriptor byte at
;           0x011E1C + 0x27*type, and no OR is applied.
; Called from both recompute paths of AlgoType_StateWrite.
DSP_ChanFreq_WritePacket1:	.include "includes/generated/cc900/DSP_ChanFreq_WritePacket1.s"	; C: cc900/dsp_voice_params_w_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_ChanFreq_WritePacket1_Algo7, DSP_ChanFreq_WritePacket1 + 139
	.set	DSP_ChanFreq_WritePacket1_Zero, DSP_ChanFreq_WritePacket1 + 205
	.set	DSP_ChanFreq_WritePacket1_Epilogue, DSP_ChanFreq_WritePacket1 + 207

; Input A = part index.  Stores a 16-bit word at part+0x61 (0x0413C9).
; Types 6 and 7 share one path here: selector = byte at 0x010FD3 + 6*type, word =
; table[0x011016 + 0x66*selector + 2*descriptor[0x5F]].  All other types store 0.
DSP_ChanFreq_WritePacket2:	.include "includes/generated/cc900/DSP_ChanFreq_WritePacket2.s"	; C: cc900/dsp_voice_params_w_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_ChanFreq_WritePacket2_PathA, DSP_ChanFreq_WritePacket2 + 34
	.set	DSP_ChanFreq_WritePacket2_PathB, DSP_ChanFreq_WritePacket2 + 103
	.set	DSP_ChanFreq_WritePacket2_Epilogue, DSP_ChanFreq_WritePacket2 + 105

; Input A = part index.  Returns L.
; Returns 0xFF unless part+0x0A bit 15 is set AND the algorithm type is exactly 9; in that case
; it returns the byte at 0x012038 + descriptor[0x5E].  The 0xFF is a sentinel meaning "this
; part has no secondary parameter", not a value.
Voice_SecondaryParam_Fetch:	.include "includes/generated/cc900/Voice_SecondaryParam_Fetch.s"	; C: cc900/dsp_voice_params_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_SecondaryParam_FallbackA, Voice_SecondaryParam_Fetch + 87
	.set	Voice_SecondaryParam_FallbackB, Voice_SecondaryParam_Fetch + 91
	.set	Voice_SecondaryParam_FallbackC, Voice_SecondaryParam_Fetch + 93

; Input A = part index.  Returns L = 0 when part+0x0A bit 15 is clear.
; For algorithm types 0x0A/0x0B it returns the algorithm-descriptor byte at 0x011E24+0x27*type
; if bit 7 of the byte at 0x011E23+0x27*type is set, otherwise descriptor[0x64];
; for every other type it returns descriptor[0x64].
; Caller: Voice_ActiveFlag_CheckAndLoad (0x0344E4), which ADDS the result to its own accumulator
; -- i.e. this is an additive offset applied to a per-part DSP parameter.
Voice_SecondaryParam_Fetch2:	.include "includes/generated/cc900/Voice_SecondaryParam_Fetch2.s"	; C: cc900/dsp_voice_params_w_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_SecondaryParam_AlgoAB, Voice_SecondaryParam_Fetch2 + 63
	.set	Voice_SecondaryParam_Path2, Voice_SecondaryParam_Fetch2 + 103
	.set	Voice_SecondaryParam_Path3, Voice_SecondaryParam_Fetch2 + 124
	.set	Voice_SecondaryParam_Path4, Voice_SecondaryParam_Fetch2 + 143

; NOT an epilogue -- this is a separate one-line accessor with its own entry point.
; Input A = part index; returns L = descriptor[0x65] when part+0x0A bit 15 is set, else 0.
; See [UNCERTAIN]: the name is misleading but I am leaving it alone per the rules.
Voice_SecondaryParam_Epilogue:	.include "includes/generated/cc900/Voice_SecondaryParam_Epilogue.s"	; C: cc900/dsp_voice_params.c

; Input A = part index, C = channel, E = a sub-selector.  Returns HL = 0x0000, 0x0040 or
; 0x00C0 -- a two-bit routing/level field for the effect's send.
; Computed jump `jp T, 0x033E44 + DSP_AlgoType_Dispatch3_CaseOffsets[type]`, table at 0x00FB96; types 6, 8 and 9
; land on the bare `ret` at 0x033F73 (HL = 0).
; Every arm reads a flag byte out of the algorithm-descriptor sub-record at
; 0x011E16 + 0x27*type + 0x13 + 5*channel and combines it with descriptor[0x5D] bit 6.
DSP_AlgoType_Dispatch3:
	ld hl, 0:i3
	ldfr_berp A, 0xF0
	extz ix
	muls ix, 0x11F
	lda xiy, (Part_PatchRecord_Ptr:24)
	ld	xix, (xiy+ix)
	ld w, (xix + 93)
	and w, 0xF
	ld b, w
	ldfr_berp W, 0xF4
	extz iy
	cp iy, 0:i3
	ret mi
	cp iy, 0xB
	ret gt
	add iy, iy
	lda xix, (DSP_AlgoType_Dispatch3_CaseOffsets:24)
	ld	iy, (xix+iy)
	lda xix, (DSP_AlgoType_D3_Arm_Types0to5_7:24)
	jp	t, (xix+iy)

; NOT DATA -- arm block for algorithm types 0..5 and 7.  Splits immediately on E == 0.
DSP_AlgoType_D3_Arm_Types0to5_7:
	cp	e, 0:i3
	jr	nz, DSP_AlgoType_D3_Arm_Type05_SubNZ
	ld	e, c
	extz	de
	muls	de, 5
	ld	iy, de
	add	iy, 19
	ld	e, b
	extz	de
	muls	de, 39
	lda	xix, (DSP_AlgoDescriptor_Records:24)
	exts	xde
	add	xde, xix
	bit	7, (xde+iy)	; (unidasm; no llvm-mc spelling)
	ret	z
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xde+wa)
	bitm	6, (xwa+93)
	jr	z, DSP_AlgoType_D3_E0_DescBit6Clear
	ld	a, c
	extz	wa
	muls	wa, 5
	ld	de, wa
	add	de, 19
	ld	a, b
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	bit	3, (xwa+de)	; (unidasm; no llvm-mc spelling)
	jr	z, DSP_AlgoType_D3_E0_Bit3Clear
	ldw	hl, 192
	jrl	t, DSP_AlgoType_D3_Return
DSP_AlgoType_D3_E0_Bit3Clear:
	ldw	hl, 64
	jrl	t, DSP_AlgoType_D3_Return
DSP_AlgoType_D3_E0_DescBit6Clear:
	ldw	hl, 64
	jrl	t, DSP_AlgoType_D3_Return
; The E != 0 half of the types-0..5/7 arm: uses sub-record bit 6 (instead of bit 7) and
; sub-record bit 2 (instead of bit 3).
DSP_AlgoType_D3_Arm_Type05_SubNZ:
	ld	e, c
	extz	de
	muls	de, 5
	ld	iy, de
	add	iy, 19
	ld	e, b
	extz	de
	muls	de, 39
	lda	xix, (DSP_AlgoDescriptor_Records:24)
	exts	xde
	add	xde, xix
	bit	6, (xde+iy)	; (unidasm; no llvm-mc spelling)
	ret	z
	extz	wa
	muls	wa, 287
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xde+wa)
	bitm	6, (xwa+93)
	jr	z, DSP_AlgoType_D3_ENZ_DescBit6Clear
	ld	a, c
	extz	wa
	muls	wa, 5
	ld	de, wa
	add	de, 19
	ld	a, b
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	bit	2, (xwa+de)	; (unidasm; no llvm-mc spelling)
	jr	z, DSP_AlgoType_D3_ENZ_Bit2Clear
	ldw	hl, 0x00c0
; CORRECTED FRAMING: the next 12 bytes were `.asciz "hR3@"`, `.asciz "hM3@"`, `.byte 0x68,0x48`
; -- 0x68 is `jr t` and 33 40 00 is `ld hl,0x0040`; unidasm frames them as the three exits
; below, the same shape as the E == 0 half above (which uses 3-byte `jrl t`).
	jr	t, DSP_AlgoType_D3_Return
DSP_AlgoType_D3_ENZ_Bit2Clear:
	ldw	hl, 0x0040
	jr	t, DSP_AlgoType_D3_Return
DSP_AlgoType_D3_ENZ_DescBit6Clear:
	ldw	hl, 0x0040
	jr	t, DSP_AlgoType_D3_Return
; Arm for algorithm types 0x0A and 0x0B (DSP_AlgoType_Dispatch3_CaseOffsets offset 0xE7).  Returns immediately for
; E != 0 or descriptor[0x5E] == 0; otherwise 0x00C0 / 0x0040 on sub-record bit 3.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
DSP_AlgoType_D3_Arm_TypeAB:
	cp	e, 0:i3
	ret	nz
	extz	wa
	muls	wa, 0x11f
	lda	xde, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xde+wa)
	cp	(xwa+94), 0
	ret	z
	ld	a, c
	extz	wa
	muls	wa, 5
	ld	de, wa
	add	de, 19
	ld	a, b
	extz	wa
	muls	wa, 39
	lda	xbc, (DSP_AlgoDescriptor_Records:24)
	exts	xwa
	add	xwa, xbc
	bit	3, (xwa+de)	; (unidasm; no llvm-mc spelling)
	jr	z, DSP_AlgoType_D3_Arm_TypeAB_Bit3Clear
	ldw	hl, 192
	jr	DSP_AlgoType_D3_Return
DSP_AlgoType_D3_Arm_TypeAB_Bit3Clear:
	ldw	hl, 64
; The shared `ret`; also the no-op arm for algorithm types 6, 8 and 9.
DSP_AlgoType_D3_Return:
	ret

; Input A = part index, C = channel.  Returns HL = 0x0000, 0x4000 or 0xC000 -- the same kind of
; two-bit field as Dispatch3 but placed in the HIGH byte.
; Only algorithm types 6 and 7 do anything; everything else returns HL = 0.
; Gate: bit 5 of the sub-record byte at 0x011E16 + 0x27*type + 0x13 + 5*channel.  Then
; descriptor[0x5D] bit 6 selects between "always 0x4000" and "0xC000 / 0x4000 on sub-record
; bit 1".
Algo67_LUTOffset_Check:	.include "includes/generated/cc900/Algo67_LUTOffset_Check.s"	; C: cc900/dsp_voice_params_r_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Algo67_LUTOffset_Read, Algo67_LUTOffset_Check + 36
	.set	Algo67_LUTOffset_Flag4000, Algo67_LUTOffset_Check + 138
	.set	Algo_SubTable_Flag8000, Algo67_LUTOffset_Check + 143
	.set	Algo_SubTable_FlagC000, Algo67_LUTOffset_Check + 146

; Input A = part index, C = sub-slot (0..3).  Returns L = the FIRST parameter byte of the
; algorithm sub-record: 0x011E16 + 0x27*type + 0x13 + 5*C + 0x01.
; Special case: for algorithm type 8 with C == 1 it returns descriptor[0x60] instead.
; Caller: VoiceNoteParam_LoopBody (0x03434B); the result lands in output-slot byte +0x20.
Algo_SubTable_DispatchA:	.include "includes/generated/cc900/Algo_SubTable_DispatchA.s"	; C: cc900/dsp_voice_params_r_17a.c

; Same shape as DispatchA but reads sub-record byte +0x02, then post-processes it through a
; computed jump `jp T, 0x0340CC + Algo_SubTable_DispatchB_CaseOffsets[type]` (table 0x00FBAE, 9 entries).
; The arms replace L with 2*descriptor[0x60] (types 0..3), 2*descriptor[0x62] (types 4/5),
; 2*descriptor[0x5F] (type 8), or leave the sub-record byte untouched (types 6/7).
; All arms require C == 1; for any other sub-slot the sub-record byte is returned as-is.
; Caller: VoiceNoteParam_LoopBody (0x034387); result lands in output-slot byte +0x21.
Algo_SubTable_DispatchB:	.include "includes/generated/cc900/Algo_SubTable_DispatchB.s"	; C: cc900/dsp_voice_params_w_18a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Algo_SubTable_JumpTable1, Algo_SubTable_DispatchB + 101
	.set	Algo_SubTable_DispatchB_Arm_Type45, Algo_SubTable_DispatchB + 130
	.set	Algo_SubTable_DispatchB_Arm_Type8, Algo_SubTable_DispatchB + 159
	.set	Algo_SubTable_DispatchB_Return, Algo_SubTable_DispatchB + 186
; A small leaf helper with no symbol of its own -- it sits between the DispatchB arm block and
; Algo_SubTable_DispatchC and is reached only by `calr 0x034122` from two arms of
; Algo_SubTable_JumpTable2 (0x0341E1 and 0x0341F2).
; Input A = part index, C = sub-slot.  Returns L = 0xFC (C==0), 0xF0 (C==1) or 0x00, but only
; when part+0x02 (the flags word, zero-extended to 32 bits) has any of bits 0x00C000 set;
; otherwise L = 0.  Signed offsets, so this reads as a small negative trim applied to the
; DispatchC parameter when a particular part flag pair is engaged.
Algo_SubTable_PanTrim_From_PartFlags:	.include "includes/generated/cc900/Algo_SubTable_PanTrim_From_PartFlags.s"	; C: cc900/dsp_voice_params_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Algo_SubTable_PanTrim_From_PartFlags_Skip, Algo_SubTable_PanTrim_From_PartFlags + 38
	.set	Algo_SubTable_PanTrim_From_PartFlags_Skip2, Algo_SubTable_PanTrim_From_PartFlags + 42
	.set	Algo_SubTable_PanTrim_From_PartFlags_Skip3, Algo_SubTable_PanTrim_From_PartFlags + 46
	.set	Algo_SubTable_PanTrim_From_PartFlags_Return, Algo_SubTable_PanTrim_From_PartFlags + 48

; Input A = part index, C = sub-slot.  Returns L.
; Base value = sub-record byte +0x03 (0x011E16 + 0x27*type + 0x13 + 5*C + 0x03), then a
; computed jump `jp T, 0x0341BE + Algo_SubTable_DispatchC_CaseOffsets[type]` (table 0x00FBC0, 9 entries) adjusts it:
;   types 0..3 : if C == 1 the base is replaced by descriptor[0x62] - 0x64, then
;                Algo_SubTable_PanTrim_From_PartFlags is ADDED
;   types 4/5  : the base is REPLACED by Algo_SubTable_PanTrim_From_PartFlags
;   types 6/8  : if C == 1 the base is replaced by descriptor[0x61] - 0x64
;   type 7     : no adjustment
; Caller: VoiceNoteParam_LoopBody (0x0343C3); result lands in output-slot byte +0x22.
Algo_SubTable_DispatchC:	.include "includes/generated/cc900/Algo_SubTable_DispatchC.s"	; C: cc900/dsp_voice_params_r_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Algo_SubTable_JumpTable2, Algo_SubTable_DispatchC + 107
	.set	Algo_SubTable_DispatchC_Arm03_AddTrim, Algo_SubTable_DispatchC + 138
	.set	Algo_SubTable_DispatchC_Arm_Type45, Algo_SubTable_DispatchC + 155
	.set	Algo_SubTable_DispatchC_Arm_Type68, Algo_SubTable_DispatchC + 167
	.set	Algo_SubTable_Epilogue, Algo_SubTable_DispatchC + 196

; Input A = part index, C = sub-slot.  Returns L = 0 immediately unless part+0x0A bit 15 is set.
; Otherwise: base = sub-record byte +0x04, then a computed jump
; `jp T, 0x03429D + Algo_SubTable_Bit15Dispatch_CaseOffsets[type]` (table 0x00FBD2, 9 entries) may replace it with a
; byte from the 0x0114DE lookup table indexed by descriptor[0x61] (types 0..3),
; descriptor[0x63] (types 4/5) or descriptor[0x5E] (type 8); types 6 and 7 return the base.
; Every replacement arm requires C == 1.
Algo_SubTable_Bit15Dispatch:	.include "includes/generated/cc900/Algo_SubTable_Bit15Dispatch.s"	; C: cc900/dsp_voice_params_r_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Algo_SubTable_JumpTable3, Algo_SubTable_Bit15Dispatch + 127
	.set	Algo_SubTable_Bit15_Arm_Type45, Algo_SubTable_Bit15Dispatch + 164
	.set	Algo_SubTable_Bit15_Arm_Type8, Algo_SubTable_Bit15Dispatch + 201
	.set	Algo_SubTable_ZeroReturn, Algo_SubTable_Bit15Dispatch + 238
	.set	Algo_SubTable_Bit15Dispatch_Return, Algo_SubTable_Bit15Dispatch + 240

; Input A = part index.  Recomputes output-slot bytes +0x20, +0x21 and +0x22 for all four
; output slots of the part by calling Algo_SubTable_DispatchA / DispatchB / DispatchC once each
; per slot (12 calls).  If part+0x0A bit 15 is clear it instead ZEROES all twelve bytes.
; Callers: VoiceSlot_FullInit_Epilogue (0x034961) and VoiceSlot_AltInit_Epilogue (0x034A41),
; i.e. it is always the last step of a part re-init.
VoiceNoteParam_UpdateLoop:	.include "includes/generated/cc900/VoiceNoteParam_UpdateLoop.s"	; C: cc900/dsp_voice_params_r_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceNoteParam_LoopBody, VoiceNoteParam_UpdateLoop + 44
	.set	VoiceNoteParam_FallbackPath, VoiceNoteParam_UpdateLoop + 236
	.set	VoiceNoteParam_LoopNext, VoiceNoteParam_UpdateLoop + 245
	.set	VoiceNoteParam_Epilogue, VoiceNoteParam_UpdateLoop + 380

; Input A = part index.  Writes one byte to part+0x67 (0x0413CF).
; The value is built as: if part+0x00 bit 0 is set AND the global at 0x0451A4 equals this part
; index, start from (byte at 0x0451A6) << 2, else 0; then, if part+0x0A bit 15 is set, ADD
; Voice_SecondaryParam_Fetch2(part).
; 0x0451A4 is the "part currently selected in the effect edit UI" and 0x0451A6 one of its live
; edit values, so part+0x67 is "the DSP parameter with the front-panel override folded in".
; Callers: VoiceSlot_FullInit (0x0348A5), VoiceSlot_AltInit (0x03497F).
Voice_ActiveFlag_CheckAndLoad:	.include "includes/generated/cc900/Voice_ActiveFlag_CheckAndLoad.s"	; C: cc900/dsp_voice_params_c_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ActiveFlag_ActivePath, Voice_ActiveFlag_CheckAndLoad + 52
	.set	Voice_ActiveFlag_InactivePath, Voice_ActiveFlag_CheckAndLoad + 88

; ★ THIS IS CODE, not a table.  The ELF calls it Voice_ProgChange_TableData; that name is a
; converter artifact (the whole body was emitted as `.byte`).  I propose the new name because
; the existing one asserts something false; see [UNCERTAIN] if you would rather keep it.
; Input A = part index.  Two variants selected by the global byte at 0x0451A7:
;   0x0451A7 == 0xF5 : for each of the four output slots, dereference slot+0x04 and mask the
;                      pointed-to byte +0x06 with 0x07 (keep only the low three flag bits).
;   otherwise        : same masking PLUS `set 5` on the same byte.
; Both variants then call AlgoFlag_Write_Bit3 (0x0330D5) and AlgoFlag_Write (0x032FD5) with
; channel 0 / word 0, and finally run EFF_RoutingInit for all four output slots with word
; selector 0.
; NO CALLER references it -- neither a direct call nor a table entry (grep across the whole
; authoritative source).  It is either dead code from an earlier firmware revision or reached
; from the boot ROM; I could not resolve which.  Confidence is therefore medium on the ROLE,
; high on the BEHAVIOUR.
; ★ Renamed 2026-09-25 from Voice_ProgChange_TableData: header: masks the four output slots' flag bytes, AlgoFlag writes, EFF_RoutingInit x4.
Voice_Part_ResetSlotRouting:	.include "includes/generated/cc900/Voice_Part_ResetSlotRouting.s"	; C: cc900/dsp_voice_params_r_17b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_Part_ResetSlotRouting_Loop, Voice_Part_ResetSlotRouting + 20
	.set	Voice_Part_ResetSlotRouting_Skip, Voice_Part_ResetSlotRouting + 115
	.set	Voice_Part_ResetSlotRouting_Skip2, Voice_Part_ResetSlotRouting + 141
	.set	Voice_Part_ResetSlotRouting_Loop2, Voice_Part_ResetSlotRouting + 147
	.set	Voice_Part_ResetSlotRouting_Skip3, Voice_Part_ResetSlotRouting + 198
	.set	Voice_Part_ResetSlotRouting_Join, Voice_Part_ResetSlotRouting + 222
	.set	Voice_Part_ResetSlotRouting_Loop3, Voice_Part_ResetSlotRouting + 228
	.set	Voice_Part_ResetSlotRouting_Epilogue, Voice_Part_ResetSlotRouting + 255

; Input A = part index.  Writes part+0x68 (0x0413D0).
; If part+0x00 bit 0 is set AND 0x0451A4 == this part, the value is (0x0451A7) << 1;
; otherwise 0.  Identical in shape to the four siblings below -- the same panel-override gate,
; a different destination byte, a different source global and a different shift.
;   slot 0 -> part+0x68 from 0x0451A7 << 1     slot 1 -> part+0x69 from 0x0451A8 << 1
;   slot 2 -> part+0x6A from 0x0451A9 << 1     slot 3 -> part+0x6B from 0x0451AB << 2
;   slot 4 -> part+0x6C from 0x0451AC << 2
; Note there are FIVE of these but only FOUR output-slot records; the fifth is a separate
; global send.  Callers: VoiceSlot_FullInit and VoiceSlot_AltInit, all five in sequence.
DSP_SlotParam_Write_Slot0:	.include "includes/generated/cc900/DSP_SlotParam_Write_Slot0.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SlotParam_Write_Slot0_Path, DSP_SlotParam_Write_Slot0 + 57

; As slot 0 but destination part+0x69 (0x0413D1) and source global 0x0451A8, shifted left 1.
DSP_SlotParam_Write_Slot1:	.include "includes/generated/cc900/DSP_SlotParam_Write_Slot1.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SlotParam_Write_Slot1_Path, DSP_SlotParam_Write_Slot1 + 57

; As slot 0 but destination part+0x6A (0x0413D2) and source global 0x0451A9, shifted left 1.
DSP_SlotParam_Write_Slot2:	.include "includes/generated/cc900/DSP_SlotParam_Write_Slot2.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SlotParam_Write_Slot2_Path, DSP_SlotParam_Write_Slot2 + 57

; As slot 0 but destination part+0x6B (0x0413D3) and source global 0x0451AB, shifted left 2.
DSP_SlotParam_Write_Slot3:	.include "includes/generated/cc900/DSP_SlotParam_Write_Slot3.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SlotParam_Write_Slot3_Path, DSP_SlotParam_Write_Slot3 + 57

; As slot 0 but destination part+0x6C (0x0413D4) and source global 0x0451AC, shifted left 2.
DSP_SlotParam_Write_Slot4:	.include "includes/generated/cc900/DSP_SlotParam_Write_Slot4.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_SlotParam_Write_Slot4_Path, DSP_SlotParam_Write_Slot4 + 57

; Input A = part index.  part+0x00 &= 0xFFFC then |= 0x0004, and part+0x04 = 0.
; I.e. it clears the two low status bits (including the bit-0 panel-target gate that
; Voice_ActiveFlag_CheckAndLoad and the five DSP_SlotParam_Write_SlotN routines test) and sets
; bit 2 instead.  Caller: Voice_ProgChange_Path2 (0x034AD2).
Voice_ActiveFlag_Set:	.include "includes/generated/cc900/Voice_ActiveFlag_Set.s"	; C: cc900/dsp_voice_params.c

; Input A = part index.  Early-outs if bit 0 of the global word at 0x041343 is set (a global
; "audio engine suspended" latch also written by DSP_System_Init).
; Otherwise zeroes part+0x1D (word), part+0x1F, part+0x20, sets part+0x1B and part+0x1C to
; 0x40 (mid-scale), and then clears bytes +0x29 and +0x2A of all twelve 4-byte note-state
; records (i = 0..3 x j = 0..2 at part + 0x10*j + 4*i).
; Callers: 6 sites including Voice_ProgChange_Path2 and VoiceSlot_ClearAll_MidNext.
Voice_NoteState_Clear:	.include "includes/generated/cc900/Voice_NoteState_Clear.s"	; C: cc900/dsp_voice_params.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_NoteState_InnerLoopA, Voice_NoteState_Clear + 112
	.set	Voice_NoteState_InnerLoopB, Voice_NoteState_Clear + 118
	.set	Voice_NoteState_Epilogue, Voice_NoteState_Clear + 210

; Full re-initialisation of one part's effect/routing state.  Input A = part index.
; Sequence: AlgoType_StateWrite(part, C=0) -> Voice_ActiveFlag_CheckAndLoad ->
; DSP_SlotParam_Write_Slot0..Slot4 -> Partial_Build_Present_Word (0x032B1E) ->
; EnvTranspose_UpdateLoop (0x032E1E) -> a 3 x 4 double loop calling AlgoFlag_Write_Bit3
; (0x0330D5) and AlgoFlag_Write (0x032FD5) -> a second 3 x 4 loop calling EFF_RoutingInit ->
; VoiceNoteParam_UpdateLoop.
; Entered from Voice_ProgChange_InnerDispatch1 when descriptor[0x10] & 0xC0 == 0xC0.
VoiceSlot_FullInit:	.include "includes/generated/cc900/VoiceSlot_FullInit.s"	; C: cc900/dsp_voice_params_d_10a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceSlot_FullInit_Loop1, VoiceSlot_FullInit + 92
	.set	VoiceSlot_FullInit_Loop1Next, VoiceSlot_FullInit + 98
	.set	VoiceSlot_FullInit_Loop2, VoiceSlot_FullInit + 156
	.set	VoiceSlot_FullInit_Loop2Next, VoiceSlot_FullInit + 162
	.set	VoiceSlot_FullInit_Loop3, VoiceSlot_FullInit + 194
	.set	VoiceSlot_FullInit_Epilogue, VoiceSlot_FullInit + 204

; The second re-init variant, entered from Voice_ProgChange_InnerDispatch2 when
; descriptor[0x10] & 0xC0 == 0x40.  Identical to VoiceSlot_FullInit except that
; Partial_Build_Present_Word is replaced by Voice_InitFromSlot (0x02ADC1) -- i.e. the tone-generator
; voice records are rebuilt from the slot instead of being merely re-aggregated -- and the loop
; counters live in QIZH rather than IZ.
VoiceSlot_AltInit:	.include "includes/generated/cc900/VoiceSlot_AltInit.s"	; C: cc900/dsp_voice_params_d_10a_qizinc.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceSlot_AltInit_Loop1, VoiceSlot_AltInit + 93
	.set	VoiceSlot_AltInit_Loop1Next, VoiceSlot_AltInit + 101
	.set	VoiceSlot_AltInit_Loop2, VoiceSlot_AltInit + 161
	.set	VoiceSlot_AltInit_Loop2Next, VoiceSlot_AltInit + 169
	.set	VoiceSlot_AltInit_Loop3, VoiceSlot_AltInit + 203
	.set	VoiceSlot_AltInit_Epilogue, VoiceSlot_AltInit + 212

; MIDI program-change handler.  Input XWA = pointer to the 6-byte staging buffer at 0x2AFC
; filled by MIDI_Status_ProgChange:  +0x01 = part index, +0x02 and +0x03 = the two program
; bytes, +0x04 = a flag.
; Returns immediately if part index >= 0x1A (26 parts).
; Stores +0x02 into part+0x19 (0x041381) and +0x03 into part+0x1A (0x041382); sets or clears
; part+0x0A bit 14 from +0x04 (this is the "algorithm loaded" master enable that
; AlgoType_StateWrite keys on); then Voice_ActiveFlag_Set, Voice_NoteState_Clear,
; Voice_SetLFO_ActiveFlag (0x027CBE) and WaveSel_Rebuild_PartCaches (0x032938).
; Finally it dereferences part+0x06 and switches on descriptor[0x10] & 0xC0:
;   0xC0 -> VoiceSlot_FullInit
;   0x40 -> Voice_PortamentoTargets_SetAll (0x02AA38) then VoiceSlot_AltInit
;   0x80 or 0x00 -> nothing
; Sole caller: MIDI_Status_ProgChange (0x034F1E).
; ★ This is where a bad or unmapped program number silently leaves the part with NO algorithm
;   engaged (bit 14 clear) -- AlgoType_StateWrite will then clear bit 15 and zero every
;   coefficient, and every routine in this region becomes a no-op for that part.
Voice_ProgChange:	.include "includes/generated/cc900/Voice_ProgChange.s"	; C: cc900/dsp_voice_params_d_10a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Voice_ProgChange_Path1, Voice_ProgChange + 110
	.set	Voice_ProgChange_Path2, Voice_ProgChange + 131
	.set	Voice_ProgChange_InnerDispatch1, Voice_ProgChange + 224
	.set	Voice_ProgChange_InnerDispatch2, Voice_ProgChange + 234
	.set	Voice_ProgChange_InnerDispatch3, Voice_ProgChange + 251

; Global reset of all per-part effect state.  No arguments.
; Pass 1: for every part 0..0x19, for every i 0..3 and j 0..2, zero the note-state byte at
;   part + 0x10*j + 4*i + 0x27 and the ROUTING WORD at part + 0x6E + 0x25*i + 0x1A + 2*j
;   (the code writes offset 0x88 + 0x25*i + 2*j, and 0x88 = 0x6E + 0x1A); then call
;   Voice_NoteState_Clear for the part.
; Pass 2: for every hardware voice 0..0x3F and every j 0..2, call NoteState_ClearRecord
;   (0x022DBD).
; Finally sets the panel-target global 0x0451A4 to 0xFF ("no part selected").
; Callers: DSP_System_Init (0x034CCC) and one site outside the region.
VoiceSlot_ClearAll:	.include "includes/generated/cc900/VoiceSlot_ClearAll.s"	; C: cc900/dsp_voice_params_c_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	VoiceSlot_ClearAll_OuterLoop, VoiceSlot_ClearAll + 14
	.set	VoiceSlot_ClearAll_MidLoop, VoiceSlot_ClearAll + 27
	.set	VoiceSlot_ClearAll_InnerLoop, VoiceSlot_ClearAll + 39
	.set	VoiceSlot_ClearAll_InnerNext, VoiceSlot_ClearAll + 147
	.set	VoiceSlot_ClearAll_MidNext, VoiceSlot_ClearAll + 158
	.set	VoiceSlot_ClearAll_OuterNext, VoiceSlot_ClearAll + 176
	.set	VoiceSlot_ClearAll_SubLoop1, VoiceSlot_ClearAll + 188
	.set	VoiceSlot_ClearAll_SubLoop1Next, VoiceSlot_ClearAll + 200
	.set	VoiceSlot_ClearAll_SubLoop2, VoiceSlot_ClearAll + 230
	.set	VoiceSlot_ClearAll_Epilogue, VoiceSlot_ClearAll + 240

; ----------------------------------------------------------------------------
; DSP_System_Init - Initialize DSP subsystem state and buffers
; Entry: None
; Exit:  None (jumps to DSP_Audio_Init via JP)
; Notes: Clears DSP state buffers at 0x041342 (38 bytes) and 0x041368 (7462 bytes)
;        Initializes control variables at 0x2B0D, 0x2B0F, 0x2B11
;        Checks PH.3 hardware pin for configuration variant
;        Then calls DSP reset and audio initialization routines
; ----------------------------------------------------------------------------
; Cold-start of the whole audio-side state.  Already named in the reference file.
; Zeroes 0x26 bytes at 0x041342 (the global audio flags), then 0x1D26 bytes at 0x041368 --
; note that is only 26 x 0x11F = 0x1D26 exactly, i.e. the ENTIRE 26-entry part table.
; Resets the MIDI ring: (0x2B11) count = 0, (0x2B0F) read = 0, (0x2B0D) write = 0.
; Reads SFR 0x44 bit 3 (a hardware strap) and sets or clears bit 3 of the global word
; 0x041343 accordingly.
; Installs three long pointers: (0x045310) and (0x045314) = 0x00050000, (0x045318) = 0x0A0000.
; Then: DSP_Config_Init (0x02DFA8), DSP_Reset (0x0360A7), Voice_Reset_Engine (0x021ECB),
; DSP_ResetWriteBufferPtr (0x03555F), VoiceSlot_ClearAll, (0x041342) = 0, and tail-jumps to
; Voice_ResetAllControllers (0x02A8F3).
DSP_System_Init:	.include "includes/generated/cc900/DSP_System_Init.s"	; C: cc900/dsp_voice_params_d_9a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_System_Init_Clear1, DSP_System_Init + 13
	.set	DSP_System_Init_Clear2, DSP_System_Init + 25
	.set	DSP_System_Init_Clear2_Loop, DSP_System_Init + 38
	.set	DSP_System_Init_Vars, DSP_System_Init + 50
	.set	DSP_System_Init_SetBit, DSP_System_Init + 80
	.set	DSP_System_Init_Continue, DSP_System_Init + 87
; DSP_InitHandler_NullStub: A lone `ret`: the do-nothing handler that entries 1-3 of
;   DSP_InitHandler_Pointers point to beside entry 0 = DSP_System_Init -- same shape as DSP2_InitTask_NullStub /
;   DSP_ResetTask_NullStub. Basis: table + body; the old header's 'no caller and no table reference' is wrong.
DSP_InitHandler_NullStub:	.include "includes/generated/cc900/DSP_InitHandler_NullStub.s"	; C: cc900/dsp_voice_params_d_8a.c

; The per-tick audio housekeeping alternator.  Already named in the reference file.
; Reads the global byte 0x041342 and runs ONE of two halves per call, then flips every bit of
; 0x041342 with `xor (0x041342),0xFF` so the next call takes the other half:
;   0x041342 == 0 : Audio_Tick_ServiceVoices_A (0x027A46) + DSP_SlotState_DisplayRestore
;                   (0x03611E)
;   otherwise     : Voice_Manager_PollBank (0x02219F) + Audio_Tick_ServiceVoices_B (0x027AC4)
; Note the toggle is an XOR with 0xFF, not an increment, so the alternation only holds while
; nothing else writes 0x041342.  DSP_System_Init sets it back to 0.
Audio_Process_Init:
	cp (Payload_Bss_Start+0x24cc:24), 0x00
	jr nz, Audio_Process_Init_BranchA
	call Audio_Tick_ServiceVoices_A
	call DSP_SlotState_DisplayRestore
	jr Audio_Process_Init_BranchB

; The "0x041342 != 0" half: Voice_Manager_PollBank + Audio_Tick_ServiceVoices_B.
Audio_Process_Init_BranchA:
	call Voice_Manager_PollBank
	call Audio_Tick_ServiceVoices_B

; The shared tail: xor (0x041342),0xFF.
Audio_Process_Init_BranchB:
	xor (Payload_Bss_Start+0x24cc:24), 255
	ret

