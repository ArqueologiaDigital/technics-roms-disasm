

; --------------------------------------------------------------------------
; Pack3x7BitFields_Bytes9To11
; Called from: in-module: 0xF36FAC 0xF379B5
; Touches: nothing with an absolute address
; Evidence: three bytes are read from the record at (XIZ+0x08): (XIX+0x09),
;           (XIX+0x0A), (XIX+0x0B).  Each has bit 7 cleared by `res 0x07`, and
;           they are shifted left by 14, by 7 and by 0 before being OR-ed
;           together.  Seven-bit fields at those three shifts is the MIDI-
;           style split of one value across three bytes, and the name says
;           only that.
; Unknown: the last two ORs are 16-bit (`or DE,WA` / `or BC,DE`), and `ld
;          IY,(XIZ+0xfc)` takes only the low half of the 14-bit-shifted field,
;          so the value this routine returns is 16 bits wide and the top five
;          bits of the first field do not survive.  That is what the
;          instructions do; whether it is intended is NOT decoded here, and no
;          21-bit claim is made.
; --------------------------------------------------------------------------
Pack3x7BitFields_Bytes9To11:
	link XIZ,0xfff8	; F36800  link XIZ,0xfff8
	pushw	hl	; F36804  push HL
	pushw	de	; F36805  push DE
	push	xix	; F36806  push XIX
	ld	xix, (xiz+8)	; F36807  ld XIX,(XIZ+0x08)
	ld	c, (xix+9)	; F3680A  ld C,(XIX+0x09)
	res	7, c	; F3680D  res 0x07,C
	extz	bc	; F36810  extz BC
	extz	xbc	; F36812  extz XBC
	sll	xbc, 14	; F36814  sll 0x0e,XBC
	ld	(xiz-4), xbc	; F36817  ld (XIZ+0xfc),XBC
	ld	a, (xix+10)	; F3681A  ld A,(XIX+0x0a)
	res	7, a	; F3681D  res 0x07,A
	extz	wa	; F36820  extz WA
	extz	xwa	; F36822  extz XWA
	sll	xwa, 7	; F36824  sll 0x07,XWA
	ld	(xiz-8), xwa	; F36827  ld (XIZ+0xf8),XWA
	ld	c, (xix+11)	; F3682A  ld C,(XIX+0x0b)
	res	7, c	; F3682D  res 0x07,C
	extz	bc	; F36830  extz BC
	extz	xbc	; F36832  extz XBC
	ld	xix, xbc	; F36834  ld XIX,XBC
	ld	hl, wa	; F36836  ld HL,WA
	ld	iy, (xiz-4)	; F36838  ld IY,(XIZ+0xfc)
	ld	de, iy	; F3683B  ld DE,IY
	or	de, wa	; F3683D  or DE,WA
	or	bc, de	; F3683F  or BC,DE
	ld	wa, bc	; F36841  ld WA,BC
	pop	xix	; F36843  pop XIX
	popw	de	; F36844  pop DE
	popw	hl	; F36845  pop HL
	unlk XIZ	; F36846  unlk XIZ
	ret	; F36848  ret

; --------------------------------------------------------------------------
; Pack3x7BitFields_Bytes6To8
; Called from: in-module: 0xF36FB8 0xF379C1
; Touches: nothing with an absolute address
; Evidence: identical to Pack3x7BitFields_Bytes9To11 three bytes earlier in
;           the record: (XIX+0x06), (XIX+0x07), (XIX+0x08), `res 0x07` on
;           each, shifts of 14, 7 and 0.  It differs only in returning through
;           XIY rather than WA.
; Unknown: the same 16-bit truncation as its twin, and the same open question
;          about it.
; --------------------------------------------------------------------------
Pack3x7BitFields_Bytes6To8:
	link XIZ,0xfff8	; F36849  link XIZ,0xfff8
	push	xix	; F3684D  push XIX
	ld	xix, (xiz+8)	; F3684E  ld XIX,(XIZ+0x08)
	ld	c, (xix+6)	; F36851  ld C,(XIX+0x06)
	res	7, c	; F36854  res 0x07,C
	extz	bc	; F36857  extz BC
	extz	xbc	; F36859  extz XBC
	sll	xbc, 14	; F3685B  sll 0x0e,XBC
	ld	(xiz-4), xbc	; F3685E  ld (XIZ+0xfc),XBC
	ld	a, (xix+7)	; F36861  ld A,(XIX+0x07)
	res	7, a	; F36864  res 0x07,A
	extz	wa	; F36867  extz WA
	extz	xwa	; F36869  extz XWA
	sll	xwa, 7	; F3686B  sll 0x07,XWA
	ld	(xiz-8), xwa	; F3686E  ld (XIZ+0xf8),XWA
	ld	c, (xix+8)	; F36871  ld C,(XIX+0x08)
	res	7, c	; F36874  res 0x07,C
	extz	bc	; F36877  extz BC
	extz	xbc	; F36879  extz XBC
	ld	xix, xbc	; F3687B  ld XIX,XBC
	or	xwa, (xiz-4)	; F3687D  or XWA,(XIZ+0xfc)
	or	xwa, xbc	; F36880  or XWA,XBC
	ld	xiy, xwa	; F36882  ld XIY,XWA
	pop	xix	; F36884  pop XIX
	unlk XIZ	; F36885  unlk XIZ
	ret	; F36887  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_LocateElementModellingChunk
; Called from: in-module: 0xF36A6F
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF36888 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_LocateElementModellingChunk: Fills the chunk descriptor (arg, 0x0B83) for an offset inside element
;   k's 43-byte modelling block of the melodic image (offset 541 + 43k): +0 := the block id the caller passes
;   (0x11/0x21/0x31/0x41), +1 := offset - (541 + 43k), +5 := 43, +3 := the remaining count clipped to the block end.
;   SysExThirdRegion_MapMelodicOffset calls it for offsets >= 541. Basis: caller + body + notes/sysex-
;   probes/sysex_third_region.py layout. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
SysExThirdRegion_LocateElementModellingChunk:
	link XIZ,0xfffc	; F36888  link XIZ,0xfffc
	pushw	hl	; F3688C  push HL
	pushw	de	; F3688D  push DE
	push	xix	; F3688E  push XIX
	ld	xix, (xiz+18)	; F3688F  ld XIX,(XIZ+0x12)
	ldw	(xix+5), 0x002b	; F36892  ld (XIX+0x05),0x002b
	ld	c, (xiz+14)	; F36897  ld C,(XIZ+0x0e)
	ld	(xix), c	; F3689A  ld (XIX),C
	sub	xbc, xbc	; F3689C  sub XBC,XBC
	ld	(xiz-4), xbc	; F3689E  ld (XIZ+0xfc),XBC
	ld	a, 43:opc	; F368A1  ld A,0x2b
	mul	wa, (xiz+16)	; F368A3  mul WA,(XIZ+0x10)
	extz	xwa	; F368A6  extz XWA
	add	xwa, 541	; F368A8  add XWA,0x0000021d
	add	xbc, xwa	; F368AE  add XBC,XWA
	extz	xbc	; F368B0  extz XBC
	ld	xwa, (xiz+8)	; F368B2  ld XWA,(XIZ+0x08)
	sub	xwa, xbc	; F368B5  sub XWA,XBC
	ld	de, wa	; F368B7  ld DE,WA
	ld	(xix+1), wa	; F368B9  ld (XIX+0x01),WA
	ld	hl, (xix+5)	; F368BC  ld HL,(XIX+0x05)
	ld	bc, hl	; F368BF  ld BC,HL
	sub	bc, de	; F368C1  sub BC,DE
	cp	bc, (xiz+12)	; F368C3  cp BC,(XIZ+0x0c)
	jr	ule, SysExThirdRegion_LocateElementModellingChunk_Skip	; F368C6  jr ULE,0xf368d0
	ld	bc, (xiz+12)	; F368C8  ld BC,(XIZ+0x0c)
	ld	(xix+3), bc	; F368CB  ld (XIX+0x03),BC
	jr	SysExThirdRegion_LocateElementModellingChunk_Join	; F368CE  jr T,0xf368da
SysExThirdRegion_LocateElementModellingChunk_Skip:
	ld	bc, (xix+1)	; F368D0  ld BC,(XIX+0x01)
	ld	wa, hl	; F368D3  ld WA,HL
	sub	wa, bc	; F368D5  sub WA,BC
	ld	(xix+3), wa	; F368D7  ld (XIX+0x03),WA
SysExThirdRegion_LocateElementModellingChunk_Join:
	pop	xix	; F368DA  pop XIX
	popw	de	; F368DB  pop DE
	popw	hl	; F368DC  pop HL
	unlk XIZ	; F368DD  unlk XIZ
	ret	; F368DF  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_LocateElementChunk
; Called from: in-module: 0xF36AD8
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF368E0 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_LocateElementChunk: Fills the chunk descriptor (arg, 0x0B83) for an offset inside element k's
;   81-byte block of the melodic image (offset 217 + 81k): +0 := the block id the caller passes (1..4), +1 := offset -
;   (217 + 81k), +5 := 81, +3 := the remaining count clipped to the block end. SysExThirdRegion_MapMelodicOffset calls
;   it for offsets 217..540. Basis: caller + body + notes/sysex-probes/sysex_third_region.py layout. (notes/naming-
;   pilot-2026-10-06/proposals_wave5_o.json)
SysExThirdRegion_LocateElementChunk:
	link XIZ,0xfffc	; F368E0  link XIZ,0xfffc
	pushw	hl	; F368E4  push HL
	pushw	de	; F368E5  push DE
	push	xix	; F368E6  push XIX
	ld	xix, (xiz+18)	; F368E7  ld XIX,(XIZ+0x12)
	ldw	(xix+5), 0x0051	; F368EA  ld (XIX+0x05),0x0051
	ld	c, (xiz+14)	; F368EF  ld C,(XIZ+0x0e)
	ld	(xix), c	; F368F2  ld (XIX),C
	sub	xbc, xbc	; F368F4  sub XBC,XBC
	ld	(xiz-4), xbc	; F368F6  ld (XIZ+0xfc),XBC
	ld	a, 81:opc	; F368F9  ld A,0x51
	mul	wa, (xiz+16)	; F368FB  mul WA,(XIZ+0x10)
	extz	xwa	; F368FE  extz XWA
	add	xwa, 217	; F36900  add XWA,0x000000d9
	add	xbc, xwa	; F36906  add XBC,XWA
	extz	xbc	; F36908  extz XBC
	ld	xwa, (xiz+8)	; F3690A  ld XWA,(XIZ+0x08)
	sub	xwa, xbc	; F3690D  sub XWA,XBC
	ld	de, wa	; F3690F  ld DE,WA
	ld	(xix+1), wa	; F36911  ld (XIX+0x01),WA
	ld	hl, (xix+5)	; F36914  ld HL,(XIX+0x05)
	ld	bc, hl	; F36917  ld BC,HL
	sub	bc, de	; F36919  sub BC,DE
	cp	bc, (xiz+12)	; F3691B  cp BC,(XIZ+0x0c)
	jr	ule, SysExThirdRegion_LocateElementChunk_Skip	; F3691E  jr ULE,0xf36928
	ld	bc, (xiz+12)	; F36920  ld BC,(XIZ+0x0c)
	ld	(xix+3), bc	; F36923  ld (XIX+0x03),BC
	jr	SysExThirdRegion_LocateElementChunk_Join	; F36926  jr T,0xf36932
SysExThirdRegion_LocateElementChunk_Skip:
	ld	bc, (xix+1)	; F36928  ld BC,(XIX+0x01)
	ld	wa, hl	; F3692B  ld WA,HL
	sub	wa, bc	; F3692D  sub WA,BC
	ld	(xix+3), wa	; F3692F  ld (XIX+0x03),WA
SysExThirdRegion_LocateElementChunk_Join:
	pop	xix	; F36932  pop XIX
	popw	de	; F36933  pop DE
	popw	hl	; F36934  pop HL
	unlk XIZ	; F36935  unlk XIZ
	ret	; F36937  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_MapMelodicDspParams
; Called from: in-module: 0xF36E68
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF36938 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_MapMelodicDspParams: For a third-region request into the melodic image (offsets 135..207 of region
;   0x040000): fills the descriptor at XIX (0x0B83): +0 := 0, +1 = first DSP parameter (offsets 135..137 -> 70..72,
;   138 -> 69, 139..207 -> 0..68), +5 = that group's size (3, 1, 69), +3 = count clipped to the group end.
;   SysExThirdRegion_FetchNextChunk then reads them with DspParam_ReadByNumber. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_n.json)
SysExThirdRegion_MapMelodicDspParams:
	link XIZ,0xfffe	; F36938  link XIZ,0xfffe
	pushw	hl	; F3693C  push HL
	pushw	de	; F3693D  push DE
	push	xix	; F3693E  push XIX
	ld	xix, (xiz+14)	; F3693F  ld XIX,(XIZ+0x0e)
	ld	de, (xiz+12)	; F36942  ld DE,(XIZ+0x0c)
	ld	(xix), 0	; F36945  ld (XIX),0x00
	ld	xbc, (xiz+8)	; F36948  ld XBC,(XIZ+0x08)
	cp	xbc, 138	; F3694B  cp XBC,0x0000008a
	jr	nc, SysExThirdRegion_MapMelodicDspParams_Skip2	; F36951  jr NC,0xf3698a
	ldw	(xix+5), 0x0003	; F36953  ld (XIX+0x05),0x0003
	ld	xbc, (xiz+8)	; F36958  ld XBC,(XIZ+0x08)
	sub	xbc, 135	; F3695B  sub XBC,0x00000087
	ld	(xiz-2), bc	; F36961  ld (XIZ+0xfe),BC
	ld	(xix+1), bc	; F36964  ld (XIX+0x01),BC
	ld	hl, (xix+5)	; F36967  ld HL,(XIX+0x05)
	ld	bc, hl	; F3696A  ld BC,HL
	sub	bc, (xiz-2)	; F3696C  sub BC,(XIZ+0xfe)
	cp	bc, de	; F3696F  cp BC,DE
	jr	ule, SysExThirdRegion_MapMelodicDspParams_Skip	; F36971  jr ULE,0xf36978
	ld	(xix+3), de	; F36973  ld (XIX+0x03),DE
	jr	SysExThirdRegion_MapMelodicDspParams_Join	; F36976  jr T,0xf36982
SysExThirdRegion_MapMelodicDspParams_Skip:
	ld	bc, (xix+1)	; F36978  ld BC,(XIX+0x01)
	ld	wa, hl	; F3697B  ld WA,HL
	sub	wa, bc	; F3697D  sub WA,BC
	ld	(xix+3), wa	; F3697F  ld (XIX+0x03),WA
SysExThirdRegion_MapMelodicDspParams_Join:
	addw	(xix+1), 0x0046	; F36982  add (XIX+0x01),0x0046
	jrl	SysExThirdRegion_MapMelodicDspParams_Join4	; F36987  jrl T,0xf36a00
SysExThirdRegion_MapMelodicDspParams_Skip2:
	ld	xbc, (xiz+8)	; F3698A  ld XBC,(XIZ+0x08)
	cp	xbc, 138	; F3698D  cp XBC,0x0000008a
	jr	nz, SysExThirdRegion_MapMelodicDspParams_Skip4	; F36993  jr NZ,0xf369cb
	ldw	(xix+5), 0x0001	; F36995  ld (XIX+0x05),0x0001
	ld	xbc, (xiz+8)	; F3699A  ld XBC,(XIZ+0x08)
	sub	xbc, 138	; F3699D  sub XBC,0x0000008a
	ld	(xiz-2), bc	; F369A3  ld (XIZ+0xfe),BC
	ld	(xix+1), bc	; F369A6  ld (XIX+0x01),BC
	ld	hl, (xix+5)	; F369A9  ld HL,(XIX+0x05)
	ld	bc, hl	; F369AC  ld BC,HL
	sub	bc, (xiz-2)	; F369AE  sub BC,(XIZ+0xfe)
	cp	bc, de	; F369B1  cp BC,DE
	jr	ule, SysExThirdRegion_MapMelodicDspParams_Skip3	; F369B3  jr ULE,0xf369ba
	ld	(xix+3), de	; F369B5  ld (XIX+0x03),DE
	jr	SysExThirdRegion_MapMelodicDspParams_Join2	; F369B8  jr T,0xf369c4
SysExThirdRegion_MapMelodicDspParams_Skip3:
	ld	bc, (xix+1)	; F369BA  ld BC,(XIX+0x01)
	ld	wa, hl	; F369BD  ld WA,HL
	sub	wa, bc	; F369BF  sub WA,BC
	ld	(xix+3), wa	; F369C1  ld (XIX+0x03),WA
SysExThirdRegion_MapMelodicDspParams_Join2:
	addw	(xix+1), 0x0045	; F369C4  add (XIX+0x01),0x0045
	jr	SysExThirdRegion_MapMelodicDspParams_Join4	; F369C9  jr T,0xf36a00
SysExThirdRegion_MapMelodicDspParams_Skip4:
	ldw	(xix+5), 0x0045	; F369CB  ld (XIX+0x05),0x0045
	ld	xbc, (xiz+8)	; F369D0  ld XBC,(XIZ+0x08)
	sub	xbc, 139	; F369D3  sub XBC,0x0000008b
	ld	(xiz-2), bc	; F369D9  ld (XIZ+0xfe),BC
	ld	(xix+1), bc	; F369DC  ld (XIX+0x01),BC
	ld	hl, (xix+5)	; F369DF  ld HL,(XIX+0x05)
	ld	bc, hl	; F369E2  ld BC,HL
	sub	bc, (xiz-2)	; F369E4  sub BC,(XIZ+0xfe)
	cp	bc, de	; F369E7  cp BC,DE
	jr	ule, SysExThirdRegion_MapMelodicDspParams_Skip5	; F369E9  jr ULE,0xf369f0
	ld	(xix+3), de	; F369EB  ld (XIX+0x03),DE
	jr	SysExThirdRegion_MapMelodicDspParams_Join3	; F369EE  jr T,0xf369fa
SysExThirdRegion_MapMelodicDspParams_Skip5:
	ld	bc, (xix+1)	; F369F0  ld BC,(XIX+0x01)
	ld	wa, hl	; F369F3  ld WA,HL
	sub	wa, bc	; F369F5  sub WA,BC
	ld	(xix+3), wa	; F369F7  ld (XIX+0x03),WA
SysExThirdRegion_MapMelodicDspParams_Join3:
	ld	bc, (xix+1)	; F369FA  ld BC,(XIX+0x01)
	ld	(xix+1), bc	; F369FD  ld (XIX+0x01),BC
SysExThirdRegion_MapMelodicDspParams_Join4:
	pop	xix	; F36A00  pop XIX
	popw	de	; F36A01  pop DE
	popw	hl	; F36A02  pop HL
	unlk XIZ	; F36A03  unlk XIZ
	ret	; F36A05  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_MapMelodicOffset
; Called from: in-module: 0xF36E78
; Touches: nothing with an absolute address
; Calls:   SysExThirdRegion_LocateElementModellingChunk SysExThirdRegion_LocateElementChunk
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF36A06 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_MapMelodicOffset: Read side of a SysEx third-region request in the melodic image (0x040000 + n, n
;   outside 135..207, which SysExThirdRegion_MapMelodicDspParams maps): fills the chunk descriptor out (0x0B83) -- [0] block id, [1..2] start in
;   the block, [3..4] length, [5..6] block size. n < 217: block 0 (size 217; a run to its end is capped at 120);
;   217..540: blocks 1..4 of 81 bytes (SysExThirdRegion_LocateElementChunk); 541..712: blocks 0x11/0x21/0x31/0x41 of 43 (SysExThirdRegion_LocateElementModellingChunk); the
;   length is the remaining count (arg 2) unless the block ends first. SysExThirdRegion_FetchNextChunk then sends
;   ToneMsg80_SendParam(id, start, length, 0x30). Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
SysExThirdRegion_MapMelodicOffset:
	link XIZ,0x0000	; F36A06  link XIZ,0x0000
	pushw	hl	; F36A0A  push HL
	pushw	de	; F36A0B  push DE
	pushw	ix	; F36A0C  push IX
	ld	ix, (xiz+12)	; F36A0D  ld IX,(XIZ+0x0c)
	ld	xbc, (xiz+8)	; F36A10  ld XBC,(XIZ+0x08)
	cp	xbc, 670	; F36A13  cp XBC,0x0000029e
	jr	c, SysExThirdRegion_MapMelodicOffset_Skip	; F36A19  jr C,0xf36a27
	ld	xwa, (xiz+14)	; F36A1B  ld XWA,(XIZ+0x0e)
	push	xwa	; F36A1E  push XWA
	pushw	3	; F36A1F  push 0x0003
	pushw	65	; F36A22  push 0x0041
	jr	SysExThirdRegion_MapMelodicOffset_Join	; F36A25  jr T,0xf36a6a
SysExThirdRegion_MapMelodicOffset_Skip:
	ld	xbc, (xiz+8)	; F36A27  ld XBC,(XIZ+0x08)
	cp	xbc, 627	; F36A2A  cp XBC,0x00000273
	jr	c, SysExThirdRegion_MapMelodicOffset_Skip2	; F36A30  jr C,0xf36a3e
	ld	xwa, (xiz+14)	; F36A32  ld XWA,(XIZ+0x0e)
	push	xwa	; F36A35  push XWA
	pushw	2	; F36A36  push 0x0002
	pushw	49	; F36A39  push 0x0031
	jr	SysExThirdRegion_MapMelodicOffset_Join	; F36A3C  jr T,0xf36a6a
SysExThirdRegion_MapMelodicOffset_Skip2:
	ld	xbc, (xiz+8)	; F36A3E  ld XBC,(XIZ+0x08)
	cp	xbc, 584	; F36A41  cp XBC,0x00000248
	jr	c, SysExThirdRegion_MapMelodicOffset_Skip3	; F36A47  jr C,0xf36a55
	ld	xwa, (xiz+14)	; F36A49  ld XWA,(XIZ+0x0e)
	push	xwa	; F36A4C  push XWA
	pushw	1	; F36A4D  push 0x0001
	pushw	33	; F36A50  push 0x0021
	jr	SysExThirdRegion_MapMelodicOffset_Join	; F36A53  jr T,0xf36a6a
SysExThirdRegion_MapMelodicOffset_Skip3:
	ld	xbc, (xiz+8)	; F36A55  ld XBC,(XIZ+0x08)
	cp	xbc, 541	; F36A58  cp XBC,0x0000021d
	jr	c, SysExThirdRegion_MapMelodicOffset_Skip4	; F36A5E  jr C,0xf36a79
	ld	xwa, (xiz+14)	; F36A60  ld XWA,(XIZ+0x0e)
	push	xwa	; F36A63  push XWA
	pushw	0	; F36A64  push 0x0000
	pushw	17	; F36A67  push 0x0011
SysExThirdRegion_MapMelodicOffset_Join:
	pushw	ix	; F36A6A  push IX
	ld	xbc, (xiz+8)	; F36A6B  ld XBC,(XIZ+0x08)
	push	xbc	; F36A6E  push XBC
	calr	SysExThirdRegion_LocateElementModellingChunk	; F36A6F  calr 0xf36888
SysExThirdRegion_MapMelodicOffset_Join2:
	inc	8, xsp	; F36A72  inc 0,XSP
	inc	6, xsp	; F36A74  inc 6,XSP
	jrl	SysExThirdRegion_MapMelodicOffset_Join4	; F36A76  jrl T,0xf36b29
SysExThirdRegion_MapMelodicOffset_Skip4:
	ld	xbc, (xiz+8)	; F36A79  ld XBC,(XIZ+0x08)
	cp	xbc, 460	; F36A7C  cp XBC,0x000001cc
	jr	c, SysExThirdRegion_MapMelodicOffset_Skip5	; F36A82  jr C,0xf36a90
	ld	xwa, (xiz+14)	; F36A84  ld XWA,(XIZ+0x0e)
	push	xwa	; F36A87  push XWA
	pushw	3	; F36A88  push 0x0003
	pushw	4	; F36A8B  push 0x0004
	jr	SysExThirdRegion_MapMelodicOffset_Join3	; F36A8E  jr T,0xf36ad3
SysExThirdRegion_MapMelodicOffset_Skip5:
	ld	xbc, (xiz+8)	; F36A90  ld XBC,(XIZ+0x08)
	cp	xbc, 379	; F36A93  cp XBC,0x0000017b
	jr	c, SysExThirdRegion_MapMelodicOffset_Skip6	; F36A99  jr C,0xf36aa7
	ld	xwa, (xiz+14)	; F36A9B  ld XWA,(XIZ+0x0e)
	push	xwa	; F36A9E  push XWA
	pushw	2	; F36A9F  push 0x0002
	pushw	3	; F36AA2  push 0x0003
	jr	SysExThirdRegion_MapMelodicOffset_Join3	; F36AA5  jr T,0xf36ad3
SysExThirdRegion_MapMelodicOffset_Skip6:
	ld	xbc, (xiz+8)	; F36AA7  ld XBC,(XIZ+0x08)
	cp	xbc, 298	; F36AAA  cp XBC,0x0000012a
	jr	c, SysExThirdRegion_MapMelodicOffset_Skip7	; F36AB0  jr C,0xf36abe
	ld	xwa, (xiz+14)	; F36AB2  ld XWA,(XIZ+0x0e)
	push	xwa	; F36AB5  push XWA
	pushw	1	; F36AB6  push 0x0001
	pushw	2	; F36AB9  push 0x0002
	jr	SysExThirdRegion_MapMelodicOffset_Join3	; F36ABC  jr T,0xf36ad3
SysExThirdRegion_MapMelodicOffset_Skip7:
	ld	xbc, (xiz+8)	; F36ABE  ld XBC,(XIZ+0x08)
	cp	xbc, 217	; F36AC1  cp XBC,0x000000d9
	jr	c, SysExThirdRegion_MapMelodicOffset_Skip8	; F36AC7  jr C,0xf36add
	ld	xwa, (xiz+14)	; F36AC9  ld XWA,(XIZ+0x0e)
	push	xwa	; F36ACC  push XWA
	pushw	0	; F36ACD  push 0x0000
	pushw	1	; F36AD0  push 0x0001
SysExThirdRegion_MapMelodicOffset_Join3:
	pushw	ix	; F36AD3  push IX
	ld	xbc, (xiz+8)	; F36AD4  ld XBC,(XIZ+0x08)
	push	xbc	; F36AD7  push XBC
	calr	SysExThirdRegion_LocateElementChunk	; F36AD8  calr 0xf368e0
	jr	SysExThirdRegion_MapMelodicOffset_Join2	; F36ADB  jr T,0xf36a72
SysExThirdRegion_MapMelodicOffset_Skip8:
	ld	xbc, (xiz+14)	; F36ADD  ld XBC,(XIZ+0x0e)
	ldw	(xbc+5), 0x00d9	; F36AE0  ld (XBC+0x05),0x00d9
	ld	xbc, (xiz+14)	; F36AE5  ld XBC,(XIZ+0x0e)
	ld	(xbc), 0	; F36AE8  ld (XBC),0x00
	ld	hl, (xiz+8)	; F36AEB  ld HL,(XIZ+0x08)
	ld	xbc, (xiz+14)	; F36AEE  ld XBC,(XIZ+0x0e)
	ld	(xbc+1), hl	; F36AF1  ld (XBC+0x01),HL
	ld	xbc, (xiz+14)	; F36AF4  ld XBC,(XIZ+0x0e)
	ld	de, (xbc+5)	; F36AF7  ld DE,(XBC+0x05)
	ld	wa, de	; F36AFA  ld WA,DE
	sub	wa, hl	; F36AFC  sub WA,HL
	cp	wa, ix	; F36AFE  cp WA,IX
	jr	ule, SysExThirdRegion_MapMelodicOffset_Skip9	; F36B00  jr ULE,0xf36b07
	ld	(xbc+3), ix	; F36B02  ld (XBC+0x03),IX
	jr	SysExThirdRegion_MapMelodicOffset_Join4	; F36B05  jr T,0xf36b29
SysExThirdRegion_MapMelodicOffset_Skip9:
	ld	xbc, (xiz+14)	; F36B07  ld XBC,(XIZ+0x0e)
	ld	hl, (xbc+1)	; F36B0A  ld HL,(XBC+0x01)
	ld	wa, de	; F36B0D  ld WA,DE
	sub	wa, hl	; F36B0F  sub WA,HL
	cp	wa, 120	; F36B11  cp WA,0x0078
	jr	ule, SysExThirdRegion_MapMelodicOffset_Skip10	; F36B15  jr ULE,0xf36b1e
	ldw	(xbc+3), 0x0078	; F36B17  ld (XBC+0x03),0x0078
	jr	SysExThirdRegion_MapMelodicOffset_Join4	; F36B1C  jr T,0xf36b29
SysExThirdRegion_MapMelodicOffset_Skip10:
	ld	xbc, (xiz+14)	; F36B1E  ld XBC,(XIZ+0x0e)
	ld	wa, (xbc+5)	; F36B21  ld WA,(XBC+0x05)
	sub	wa, hl	; F36B24  sub WA,HL
	ld	(xbc+3), wa	; F36B26  ld (XBC+0x03),WA
SysExThirdRegion_MapMelodicOffset_Join4:
	popw	ix	; F36B29  pop IX
	popw	de	; F36B2A  pop DE
	popw	hl	; F36B2B  pop HL
	unlk XIZ	; F36B2C  unlk XIZ
	ret	; F36B2E  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_LocateDrumModellingChunk
; Called from: in-module: 0xF36BF3
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF36B2F is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_LocateDrumModellingChunk: Drum twin of SysExThirdRegion_LocateElementModellingChunk: fills the
;   chunk descriptor for an offset inside drum entry n's 43-byte modelling block k (start 472 + 150n + 43k): +0 := the
;   block id the caller passes (1 / 2), +1 := offset - start, +5 := 43, +3 := the count clipped to the block end.
;   SysExThirdRegion_LocateDrumEntryChunk calls it for offsets >= 408 + 150n + 64. Basis: caller + body + twin.
;   (notes/naming-pilot-2026-10-06/proposals_wave6_s.json)
SysExThirdRegion_LocateDrumModellingChunk:
	link XIZ,0xfff8	; F36B2F  link XIZ,0xfff8
	pushw	hl	; F36B33  push HL
	pushw	de	; F36B34  push DE
	push	xix	; F36B35  push XIX
	ld	xix, (xiz+20)	; F36B36  ld XIX,(XIZ+0x14)
	ldw	(xix+5), 0x002b	; F36B39  ld (XIX+0x05),0x002b
	ld	c, (xiz+16)	; F36B3E  ld C,(XIZ+0x10)
	ld	(xix), c	; F36B41  ld (XIX),C
	sub	xbc, xbc	; F36B43  sub XBC,XBC
	ld	(xiz-4), xbc	; F36B45  ld (XIZ+0xfc),XBC
	ld	a, 43:opc	; F36B48  ld A,0x2b
	mul	wa, (xiz+18)	; F36B4A  mul WA,(XIZ+0x12)
	extz	xwa	; F36B4D  extz XWA
	ld	(xiz-8), xwa	; F36B4F  ld (XIZ+0xf8),XWA
	ld	c, 150:opc	; F36B52  ld C,0x96
	mul	bc, (xiz+14)	; F36B54  mul BC,(XIZ+0x0e)
	extz	xbc	; F36B57  extz XBC
	add	xbc, xwa	; F36B59  add XBC,XWA
	add	xbc, 472	; F36B5B  add XBC,0x000001d8
	add	xbc, (xiz-4)	; F36B61  add XBC,(XIZ+0xfc)
	extz	xbc	; F36B64  extz XBC
	ld	xwa, (xiz+8)	; F36B66  ld XWA,(XIZ+0x08)
	sub	xwa, xbc	; F36B69  sub XWA,XBC
	ld	de, wa	; F36B6B  ld DE,WA
	ld	(xix+1), wa	; F36B6D  ld (XIX+0x01),WA
	ld	hl, (xix+5)	; F36B70  ld HL,(XIX+0x05)
	ld	bc, hl	; F36B73  ld BC,HL
	sub	bc, de	; F36B75  sub BC,DE
	cp	bc, (xiz+12)	; F36B77  cp BC,(XIZ+0x0c)
	jr	ule, SysExThirdRegion_LocateDrumModellingChunk_Skip	; F36B7A  jr ULE,0xf36b84
	ld	bc, (xiz+12)	; F36B7C  ld BC,(XIZ+0x0c)
	ld	(xix+3), bc	; F36B7F  ld (XIX+0x03),BC
	jr	SysExThirdRegion_LocateDrumModellingChunk_Join	; F36B82  jr T,0xf36b8e
SysExThirdRegion_LocateDrumModellingChunk_Skip:
	ld	bc, (xix+1)	; F36B84  ld BC,(XIX+0x01)
	ld	wa, hl	; F36B87  ld WA,HL
	sub	wa, bc	; F36B89  sub WA,BC
	ld	(xix+3), wa	; F36B8B  ld (XIX+0x03),WA
SysExThirdRegion_LocateDrumModellingChunk_Join:
	pop	xix	; F36B8E  pop XIX
	popw	de	; F36B8F  pop DE
	popw	hl	; F36B90  pop HL
	unlk XIZ	; F36B91  unlk XIZ
	ret	; F36B93  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_LocateDrumEntryChunk
; Called from: in-module: 0xF36D27
; Touches: nothing with an absolute address
; Calls:   SysExThirdRegion_LocateDrumModellingChunk
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF36B94 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_LocateDrumEntryChunk: For drum entry n (the 150-byte records from offset 408): offsets from 408 +
;   150n + 107 go to SysExThirdRegion_LocateDrumModellingChunk as modelling block 1, from + 64 as modelling block 0; the entry's 64-byte common block
;   is filled here (+0 := 0, +1 := offset - (408 + 150n), +5 := 64, +3 := count clipped). Called by
;   SysExThirdRegion_LocateDrumChunk for offsets >= 408. Basis: caller + body + notes/sysex-
;   probes/sysex_third_region.py layout. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
SysExThirdRegion_LocateDrumEntryChunk:
	link XIZ,0xfff8	; F36B94  link XIZ,0xfff8
	pushw	hl	; F36B98  push HL
	pushw	de	; F36B99  push DE
	push	xix	; F36B9A  push XIX
	ld	de, (xiz+12)	; F36B9B  ld DE,(XIZ+0x0c)
	ld	xix, 0	; F36B9E  ld XIX,0x00000000
	ld	c, 150:opc	; F36BA3  ld C,0x96
	mul	bc, (xiz+14)	; F36BA5  mul BC,(XIZ+0x0e)
	extz	xbc	; F36BA8  extz XBC
	ld	(xiz-4), xbc	; F36BAA  ld (XIZ+0xfc),XBC
	add	xbc, 515	; F36BAD  add XBC,0x00000203
	add	xbc, xix	; F36BB3  add XBC,XIX
	extz	xbc	; F36BB5  extz XBC
	cp	xbc, (xiz+8)	; F36BB7  cp XBC,(XIZ+0x08)
	jr	ugt, SysExThirdRegion_LocateDrumEntryChunk_Skip	; F36BBA  jr UGT,0xf36bc8
	ld	xbc, (xiz+16)	; F36BBC  ld XBC,(XIZ+0x10)
	push	xbc	; F36BBF  push XBC
	pushw	1	; F36BC0  push 0x0001
	pushw	2	; F36BC3  push 0x0002
	jr	SysExThirdRegion_LocateDrumEntryChunk_Join	; F36BC6  jr T,0xf36be9
SysExThirdRegion_LocateDrumEntryChunk_Skip:
	ld	xix, 0	; F36BC8  ld XIX,0x00000000
	ld	xbc, (xiz-4)	; F36BCD  ld XBC,(XIZ+0xfc)
	add	xbc, 472	; F36BD0  add XBC,0x000001d8
	add	xbc, xix	; F36BD6  add XBC,XIX
	extz	xbc	; F36BD8  extz XBC
	cp	xbc, (xiz+8)	; F36BDA  cp XBC,(XIZ+0x08)
	jr	ugt, SysExThirdRegion_LocateDrumEntryChunk_Skip2	; F36BDD  jr UGT,0xf36bfd
	ld	xbc, (xiz+16)	; F36BDF  ld XBC,(XIZ+0x10)
	push	xbc	; F36BE2  push XBC
	pushw	0	; F36BE3  push 0x0000
	pushw	1	; F36BE6  push 0x0001
SysExThirdRegion_LocateDrumEntryChunk_Join:
	push	0	; F36BE9  push 0x00
	push	(xiz+14)	; F36BEB  push (XIZ+0x0e)
	pushw	de	; F36BEE  push DE
	ld	xbc, (xiz+8)	; F36BEF  ld XBC,(XIZ+0x08)
	push	xbc	; F36BF2  push XBC
	calr	SysExThirdRegion_LocateDrumModellingChunk	; F36BF3  calr 0xf36b2f
	inc	8, xsp	; F36BF6  inc 0,XSP
	inc	8, xsp	; F36BF8  inc 0,XSP
	jrl	SysExThirdRegion_LocateDrumEntryChunk_Join2	; F36BFA  jrl T,0xf36c57
SysExThirdRegion_LocateDrumEntryChunk_Skip2:
	sub	xbc, xbc	; F36BFD  sub XBC,XBC
	ld	(xiz-8), xbc	; F36BFF  ld (XIZ+0xf8),XBC
	ld	xix, (xiz-4)	; F36C02  ld XIX,(XIZ+0xfc)
	add	xix, 408	; F36C05  add XIX,0x00000198
	add	xbc, xix	; F36C0B  add XBC,XIX
	extz	xbc	; F36C0D  extz XBC
	cp	xbc, (xiz+8)	; F36C0F  cp XBC,(XIZ+0x08)
	jr	ugt, SysExThirdRegion_LocateDrumEntryChunk_Join2	; F36C12  jr UGT,0xf36c57
	ld	xbc, (xiz+16)	; F36C14  ld XBC,(XIZ+0x10)
	ldw	(xbc+5), 0x0040	; F36C17  ld (XBC+0x05),0x0040
	ld	xbc, (xiz+16)	; F36C1C  ld XBC,(XIZ+0x10)
	ld	(xbc), 0	; F36C1F  ld (XBC),0x00
	sub	xbc, xbc	; F36C22  sub XBC,XBC
	add	xbc, xix	; F36C24  add XBC,XIX
	extz	xbc	; F36C26  extz XBC
	ld	xwa, (xiz+8)	; F36C28  ld XWA,(XIZ+0x08)
	sub	xwa, xbc	; F36C2B  sub XWA,XBC
	ld	(xiz-6), wa	; F36C2D  ld (XIZ+0xfa),WA
	ld	xbc, (xiz+16)	; F36C30  ld XBC,(XIZ+0x10)
	ld	(xbc+1), wa	; F36C33  ld (XBC+0x01),WA
	ld	xbc, (xiz+16)	; F36C36  ld XBC,(XIZ+0x10)
	ld	hl, (xbc+5)	; F36C39  ld HL,(XBC+0x05)
	ld	wa, hl	; F36C3C  ld WA,HL
	sub	wa, (xiz-6)	; F36C3E  sub WA,(XIZ+0xfa)
	cp	wa, de	; F36C41  cp WA,DE
	jr	ule, SysExThirdRegion_LocateDrumEntryChunk_Skip3	; F36C43  jr ULE,0xf36c4a
	ld	(xbc+3), de	; F36C45  ld (XBC+0x03),DE
	jr	SysExThirdRegion_LocateDrumEntryChunk_Join2	; F36C48  jr T,0xf36c57
SysExThirdRegion_LocateDrumEntryChunk_Skip3:
	ld	xbc, (xiz+16)	; F36C4A  ld XBC,(XIZ+0x10)
	ld	wa, (xbc+1)	; F36C4D  ld WA,(XBC+0x01)
	ld	iy, hl	; F36C50  ld IY,HL
	sub	iy, wa	; F36C52  sub IY,WA
	ld	(xbc+3), iy	; F36C54  ld (XBC+0x03),IY
SysExThirdRegion_LocateDrumEntryChunk_Join2:
	pop	xix	; F36C57  pop XIX
	popw	de	; F36C58  pop DE
	popw	hl	; F36C59  pop HL
	unlk XIZ	; F36C5A  unlk XIZ
	ret	; F36C5C  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_MapOffsetToDspParamRun
; Called from: in-module: 0xF36ECF
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF36C5D is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_MapOffsetToDspParamRun: For a SysEx third-region request in the 0x060000 region at offset 82..151:
;   fills the run descriptor at the pointer arg (0x0B83): +0 := 3, +7 := 0; offset 82 -> first DSP parameter 0x45,
;   limit 1; 83..151 -> parameter offset - 83, limit 0x45; +3 := min(requested count, limit - first).
;   SysExThirdRegion_FetchNextChunk then reads that run with DspParam_ReadByNumber. Basis: caller + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_l.json)
SysExThirdRegion_MapOffsetToDspParamRun:
	link XIZ,0xfffe	; F36C5D  link XIZ,0xfffe
	pushw	hl	; F36C61  push HL
	pushw	de	; F36C62  push DE
	push	xix	; F36C63  push XIX
	ld	xix, (xiz+14)	; F36C64  ld XIX,(XIZ+0x0e)
	ld	de, (xiz+12)	; F36C67  ld DE,(XIZ+0x0c)
	ld	(xix+7), 0	; F36C6A  ld (XIX+0x07),0x00
	ld	(xix), 3	; F36C6E  ld (XIX),0x03
	ld	xbc, (xiz+8)	; F36C71  ld XBC,(XIZ+0x08)
	cp	xbc, 82	; F36C74  cp XBC,0x00000052
	jr	nz, SysExThirdRegion_MapOffsetToDspParamRun_Skip2	; F36C7A  jr NZ,0xf36cb2
	ldw	(xix+5), 0x0001	; F36C7C  ld (XIX+0x05),0x0001
	ld	xbc, (xiz+8)	; F36C81  ld XBC,(XIZ+0x08)
	sub	xbc, 82	; F36C84  sub XBC,0x00000052
	ld	(xiz-2), bc	; F36C8A  ld (XIZ+0xfe),BC
	ld	(xix+1), bc	; F36C8D  ld (XIX+0x01),BC
	ld	hl, (xix+5)	; F36C90  ld HL,(XIX+0x05)
	ld	bc, hl	; F36C93  ld BC,HL
	sub	bc, (xiz-2)	; F36C95  sub BC,(XIZ+0xfe)
	cp	bc, de	; F36C98  cp BC,DE
	jr	ule, SysExThirdRegion_MapOffsetToDspParamRun_Skip	; F36C9A  jr ULE,0xf36ca1
	ld	(xix+3), de	; F36C9C  ld (XIX+0x03),DE
	jr	SysExThirdRegion_MapOffsetToDspParamRun_Join	; F36C9F  jr T,0xf36cab
SysExThirdRegion_MapOffsetToDspParamRun_Skip:
	ld	bc, (xix+1)	; F36CA1  ld BC,(XIX+0x01)
	ld	wa, hl	; F36CA4  ld WA,HL
	sub	wa, bc	; F36CA6  sub WA,BC
	ld	(xix+3), wa	; F36CA8  ld (XIX+0x03),WA
SysExThirdRegion_MapOffsetToDspParamRun_Join:
	addw	(xix+1), 0x0045	; F36CAB  add (XIX+0x01),0x0045
	jr	SysExThirdRegion_MapOffsetToDspParamRun_Join3	; F36CB0  jr T,0xf36ce7
SysExThirdRegion_MapOffsetToDspParamRun_Skip2:
	ldw	(xix+5), 0x0045	; F36CB2  ld (XIX+0x05),0x0045
	ld	xbc, (xiz+8)	; F36CB7  ld XBC,(XIZ+0x08)
	sub	xbc, 83	; F36CBA  sub XBC,0x00000053
	ld	(xiz-2), bc	; F36CC0  ld (XIZ+0xfe),BC
	ld	(xix+1), bc	; F36CC3  ld (XIX+0x01),BC
	ld	hl, (xix+5)	; F36CC6  ld HL,(XIX+0x05)
	ld	bc, hl	; F36CC9  ld BC,HL
	sub	bc, (xiz-2)	; F36CCB  sub BC,(XIZ+0xfe)
	cp	bc, de	; F36CCE  cp BC,DE
	jr	ule, SysExThirdRegion_MapOffsetToDspParamRun_Skip3	; F36CD0  jr ULE,0xf36cd7
	ld	(xix+3), de	; F36CD2  ld (XIX+0x03),DE
	jr	SysExThirdRegion_MapOffsetToDspParamRun_Join2	; F36CD5  jr T,0xf36ce1
SysExThirdRegion_MapOffsetToDspParamRun_Skip3:
	ld	bc, (xix+1)	; F36CD7  ld BC,(XIX+0x01)
	ld	wa, hl	; F36CDA  ld WA,HL
	sub	wa, bc	; F36CDC  sub WA,BC
	ld	(xix+3), wa	; F36CDE  ld (XIX+0x03),WA
SysExThirdRegion_MapOffsetToDspParamRun_Join2:
	ld	bc, (xix+1)	; F36CE1  ld BC,(XIX+0x01)
	ld	(xix+1), bc	; F36CE4  ld (XIX+0x01),BC
SysExThirdRegion_MapOffsetToDspParamRun_Join3:
	pop	xix	; F36CE7  pop XIX
	popw	de	; F36CE8  pop DE
	popw	hl	; F36CE9  pop HL
	unlk XIZ	; F36CEA  unlk XIZ
	ret	; F36CEC  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_LocateDrumChunk
; Called from: in-module: 0xF36F1F 0xF36F47
; Touches: nothing with an absolute address
; Calls:   Divide32_Unsigned_Quotient SysExThirdRegion_LocateDrumEntryChunk
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF36CED is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_LocateDrumChunk: Fills the chunk descriptor (arg 3, 0x0B83 from the caller: +0 kind 3, +1 start, +3
;   count clipped to the block and to 120, +5 block size, +7 index) for an offset in the drum image (region 0x060000):
;   the 135-byte common block below 152, the 128 two-byte entries at 152..407 (index (off-152)/2) or the 128 150-byte
;   records from 408 (index (off-408)/150, SysExThirdRegion_LocateDrumEntryChunk). Called by SysExThirdRegion_FetchNextChunk for drum offsets
;   outside 82..151. Basis: caller + body + AcceptRequest header. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_m.json)
SysExThirdRegion_LocateDrumChunk:
	link XIZ,0xfffc	; F36CED  link XIZ,0xfffc
	pushw	hl	; F36CF1  push HL
	pushw	de	; F36CF2  push DE
	push	xix	; F36CF3  push XIX
	ld	xix, (xiz+8)	; F36CF4  ld XIX,(XIZ+0x08)
	cp	xix, 408	; F36CF7  cp XIX,0x00000198
	jr	c, SysExThirdRegion_LocateDrumChunk_Skip	; F36CFD  jr C,0xf36d31
	ld	xbc, xix	; F36CFF  ld XBC,XIX
	sub	xbc, 408	; F36D01  sub XBC,0x00000198
	pushw	0	; F36D07  push 0x0000
	pushw	150	; F36D0A  push 0x0096
	push	xbc	; F36D0D  push XBC
	call	Divide32_Unsigned_Quotient	; F36D0E  call 0xf37f3a
	ldto_berp	h, 0xf4	; F36D12  ld H,IYL
	ld	xbc, (xiz+14)	; F36D15  ld XBC,(XIZ+0x0e)
	ld	(xbc+7), h	; F36D18  ld (XBC+0x07),H
	ld	xbc, (xiz+14)	; F36D1B  ld XBC,(XIZ+0x0e)
	push	xbc	; F36D1E  push XBC
	push	0	; F36D1F  push 0x00
	push	h	; F36D21  push H
	pushw	(xiz+12)	; F36D23  pushw (XIZ+0x0c)
	push	xix	; F36D26  push XIX
	calr	SysExThirdRegion_LocateDrumEntryChunk	; F36D27  calr 0xf36b94
	inc	8, xsp	; F36D2A  inc 0,XSP
	inc	4, xsp	; F36D2C  inc 4,XSP
	jrl	SysExThirdRegion_LocateDrumChunk_Join2	; F36D2E  jrl T,0xf36e1b
SysExThirdRegion_LocateDrumChunk_Skip:
	cp	xix, 152	; F36D31  cp XIX,0x00000098
	jrl	c, SysExThirdRegion_LocateDrumChunk_Skip4	; F36D37  jrl C,0xf36dc4
	ld	xbc, (xiz+14)	; F36D3A  ld XBC,(XIZ+0x0e)
	ldw	(xbc+5), 0x0002	; F36D3D  ld (XBC+0x05),0x0002
	ld	xbc, xix	; F36D42  ld XBC,XIX
	sub	xbc, 152	; F36D44  sub XBC,0x00000098
	ld	(xiz-4), xbc	; F36D4A  ld (XIZ+0xfc),XBC
	ldw	wa, 2	; F36D4D  ld WA,0x0002
	extz	xwa	; F36D50  extz XWA
	push	xwa	; F36D52  push XWA
	push	xbc	; F36D53  push XBC
	call	Divide32_Unsigned_Quotient	; F36D54  call 0xf37f3a
	ldto_berp	c, 0xf4	; F36D58  ld C,IYL
	ld	d, c	; F36D5B  ld D,C
	ld	xbc, (xiz+14)	; F36D5D  ld XBC,(XIZ+0x0e)
	ld	(xbc+7), d	; F36D60  ld (XBC+0x07),D
	ld	xbc, (xiz+14)	; F36D63  ld XBC,(XIZ+0x0e)
	ld	(xbc), 3	; F36D66  ld (XBC),0x03
	ld	xbc, (xiz+14)	; F36D69  ld XBC,(XIZ+0x0e)
	ld	a, (xbc+7)	; F36D6C  ld A,(XBC+0x07)
	mul	a, 2	; F36D6F  mul A,0x02
	extz	xwa	; F36D72  extz XWA
	ld	xiy, (xiz-4)	; F36D74  ld XIY,(XIZ+0xfc)
	sub	xiy, xwa	; F36D77  sub XIY,XWA
	ld	de, iy	; F36D79  ld DE,IY
	ld	(xbc+1), iy	; F36D7B  ld (XBC+0x01),IY
	ld	xbc, (xiz+14)	; F36D7E  ld XBC,(XIZ+0x0e)
	ld	hl, (xbc+5)	; F36D81  ld HL,(XBC+0x05)
	ld	wa, hl	; F36D84  ld WA,HL
	sub	wa, de	; F36D86  sub WA,DE
	cp	wa, (xiz+12)	; F36D88  cp WA,(XIZ+0x0c)
	jr	ule, SysExThirdRegion_LocateDrumChunk_Skip2	; F36D8B  jr ULE,0xf36d95
	ld	wa, (xiz+12)	; F36D8D  ld WA,(XIZ+0x0c)
	ld	(xbc+3), wa	; F36D90  ld (XBC+0x03),WA
	jr	SysExThirdRegion_LocateDrumChunk_Join	; F36D93  jr T,0xf36da2
SysExThirdRegion_LocateDrumChunk_Skip2:
	ld	xbc, (xiz+14)	; F36D95  ld XBC,(XIZ+0x0e)
	ld	wa, (xbc+1)	; F36D98  ld WA,(XBC+0x01)
	ld	iy, hl	; F36D9B  ld IY,HL
	sub	iy, wa	; F36D9D  sub IY,WA
	ld	(xbc+3), iy	; F36D9F  ld (XBC+0x03),IY
SysExThirdRegion_LocateDrumChunk_Join:
	ld	xbc, (xiz+14)	; F36DA2  ld XBC,(XIZ+0x0e)
	ld	wa, (xbc+3)	; F36DA5  ld WA,(XBC+0x03)
	cp	wa, 1:i3	; F36DA8  cp WA,1
	jrl	nz, SysExThirdRegion_LocateDrumChunk_Join2	; F36DAA  jrl NZ,0xf36e1b
	ld	wa, (xbc+1)	; F36DAD  ld WA,(XBC+0x01)
	cp	wa, 0:i3	; F36DB0  cp WA,0
	jr	nz, SysExThirdRegion_LocateDrumChunk_Skip3	; F36DB2  jr NZ,0xf36dbc
	set	0, (0x000a01:24)	; F36DB4  set 0,(0x000a01)
	jrl	SysExThirdRegion_LocateDrumChunk_Join2	; F36DB9  jrl T,0xf36e1b
SysExThirdRegion_LocateDrumChunk_Skip3:
	set	1, (0x000a01:24)	; F36DBC  set 1,(0x000a01)
	jrl	SysExThirdRegion_LocateDrumChunk_Join2	; F36DC1  jrl T,0xf36e1b
SysExThirdRegion_LocateDrumChunk_Skip4:
	ld	xbc, (xiz+14)	; F36DC4  ld XBC,(XIZ+0x0e)
	ldw	(xbc+5), 0x0087	; F36DC7  ld (XBC+0x05),0x0087
	ld	xbc, (xiz+14)	; F36DCC  ld XBC,(XIZ+0x0e)
	ld	(xbc+7), 0	; F36DCF  ld (XBC+0x07),0x00
	ld	xbc, (xiz+14)	; F36DD3  ld XBC,(XIZ+0x0e)
	ld	(xbc), 3	; F36DD6  ld (XBC),0x03
	ld	hl, (xiz+8)	; F36DD9  ld HL,(XIZ+0x08)
	ld	xbc, (xiz+14)	; F36DDC  ld XBC,(XIZ+0x0e)
	ld	(xbc+1), hl	; F36DDF  ld (XBC+0x01),HL
	ld	xbc, (xiz+14)	; F36DE2  ld XBC,(XIZ+0x0e)
	ld	de, (xbc+5)	; F36DE5  ld DE,(XBC+0x05)
	ld	wa, de	; F36DE8  ld WA,DE
	sub	wa, hl	; F36DEA  sub WA,HL
	cp	wa, (xiz+12)	; F36DEC  cp WA,(XIZ+0x0c)
	jr	ule, SysExThirdRegion_LocateDrumChunk_Skip5	; F36DEF  jr ULE,0xf36df9
	ld	wa, (xiz+12)	; F36DF1  ld WA,(XIZ+0x0c)
	ld	(xbc+3), wa	; F36DF4  ld (XBC+0x03),WA
	jr	SysExThirdRegion_LocateDrumChunk_Join2	; F36DF7  jr T,0xf36e1b
SysExThirdRegion_LocateDrumChunk_Skip5:
	ld	xbc, (xiz+14)	; F36DF9  ld XBC,(XIZ+0x0e)
	ld	hl, (xbc+1)	; F36DFC  ld HL,(XBC+0x01)
	ld	wa, de	; F36DFF  ld WA,DE
	sub	wa, hl	; F36E01  sub WA,HL
	cp	wa, 120	; F36E03  cp WA,0x0078
	jr	ule, SysExThirdRegion_LocateDrumChunk_Skip6	; F36E07  jr ULE,0xf36e10
	ldw	(xbc+3), 0x0078	; F36E09  ld (XBC+0x03),0x0078
	jr	SysExThirdRegion_LocateDrumChunk_Join2	; F36E0E  jr T,0xf36e1b
SysExThirdRegion_LocateDrumChunk_Skip6:
	ld	xbc, (xiz+14)	; F36E10  ld XBC,(XIZ+0x0e)
	ld	wa, (xbc+5)	; F36E13  ld WA,(XBC+0x05)
	sub	wa, hl	; F36E16  sub WA,HL
	ld	(xbc+3), wa	; F36E18  ld (XBC+0x03),WA
SysExThirdRegion_LocateDrumChunk_Join2:
	pop	xix	; F36E1B  pop XIX
	popw	de	; F36E1C  pop DE
	popw	hl	; F36E1D  pop HL
	unlk XIZ	; F36E1E  unlk XIZ
	ret	; F36E20  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_FetchNextChunk
; Called from: T_SysExThirdRegion_FetchNextChunk (x1); far site 0xF41250
; Touches: nothing with an absolute address
; Calls:   SysExThirdRegion_MapMelodicDspParams SysExThirdRegion_MapMelodicOffset T_ToneMsg80_SendParam SysExThirdRegion_MapOffsetToDspParamRun T_DspParam_ReadByNumber SysExThirdRegion_SendReplyChunk
;          SysExThirdRegion_LocateDrumChunk T_ToneMsg80_Id16 T_ToneMsg88_Id13 T_ToneMsg85_SendParam
; Evidence: thunk slot T_SysExThirdRegion_FetchNextChunk holds `jp 0x00F36E21`, and 0xF36E21 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_FetchNextChunk: Main-loop step of a SysEx third-region request: while (0x0A00) bit 2 is set
;   (SysExThirdRegion_AcceptRequest's |= 5; re-armed by the reply sender SysExThirdRegion_SendReplyChunk while bytes remain), fetches the chunk at (0x0A03) --
;   region 0x040000 or 0x060000 -- through ToneMsg80/85 requests to CPU 2 or DspParam_ReadByNumber + SysExThirdRegion_SendReplyChunk --
;   then clears bit 2 and sets bit 1. Basis: caller + body + module siblings. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
SysExThirdRegion_FetchNextChunk:		; <- T_SysExThirdRegion_FetchNextChunk
	link XIZ,0xfffc	; F36E21  link XIZ,0xfffc
	pushw	hl	; F36E25  push HL
	push	xix	; F36E26  push XIX
	ld	hl, (2567:24)	; F36E27  ld HL,(0x000a07)
	ld	bc, (2560:24)	; F36E2C  ld BC,(0x000a00)
	and	bc, 4	; F36E31  and BC,0x0004
	jrl	z, SysExThirdRegion_FetchNextChunk_Join5	; F36E35  jrl Z,0xf36f87
	ld	xbc, (2563:24)	; F36E38  ld XBC,(0x000a03)
	cp	xbc, 393216	; F36E3D  cp XBC,0x00060000
	jr	ge, SysExThirdRegion_FetchNextChunk_Skip8	; F36E43  jr GE,0xf36ea7
	sub	xbc, 262144	; F36E45  sub XBC,0x00040000
	ld	(xiz-4), xbc	; F36E4B  ld (XIZ+0xfc),XBC
	ld	xix, xbc	; F36E4E  ld XIX,XBC
	cp	xbc, 135	; F36E50  cp XBC,0x00000087
	jr	c, SysExThirdRegion_FetchNextChunk_Skip7	; F36E56  jr C,0xf36e6d
	cp	xbc, 207	; F36E58  cp XBC,0x000000cf
	jr	ugt, SysExThirdRegion_FetchNextChunk_Skip7	; F36E5E  jr UGT,0xf36e6d
	lda	xwa, (2947:24)	; F36E60  lda XWA,0x000b83
	push	xwa	; F36E65  push XWA
	pushw	hl	; F36E66  push HL
	push	xbc	; F36E67  push XBC
	calr	SysExThirdRegion_MapMelodicDspParams	; F36E68  calr 0xf36938
	jr	SysExThirdRegion_FetchNextChunk_Join3	; F36E6B  jr T,0xf36ed2
SysExThirdRegion_FetchNextChunk_Skip7:
	lda	xbc, (2947:24)	; F36E6D  lda XBC,0x000b83
	push	xbc	; F36E72  push XBC
	pushw	hl	; F36E73  push HL
	ld	xwa, (xiz-4)	; F36E74  ld XWA,(XIZ+0xfc)
	push	xwa	; F36E77  push XWA
	calr	SysExThirdRegion_MapMelodicOffset	; F36E78  calr 0xf36a06
	ld	bc, (2950:24)	; F36E7B  ld BC,(0x000b86)
	ld	(2569:24), bc	; F36E80  ld (0x000a09),BC
	pushw	48	; F36E85  push 0x0030
	ld	wa, (2950:24)	; F36E88  ld WA,(0x000b86)
	pushw	wa	; F36E8D  push WA
	ld	wa, (2948:24)	; F36E8E  ld WA,(0x000b84)
	pushw	wa	; F36E93  push WA
	ld	a, (2947:24)	; F36E94  ld A,(0x000b83)
	pushw	wa	; F36E99  push WA
	call	T_ToneMsg80_SendParam	; F36E9A  call 0xf43474
	add	xsp, 18	; F36E9E  add XSP,0x00000012
	jrl	SysExThirdRegion_FetchNextChunk_Join4	; F36EA4  jrl T,0xf36f7d
SysExThirdRegion_FetchNextChunk_Skip8:
	ld	xbc, (2563:24)	; F36EA7  ld XBC,(0x000a03)
	sub	xbc, 393216	; F36EAC  sub XBC,0x00060000
	ld	(xiz-4), xbc	; F36EB2  ld (XIZ+0xfc),XBC
	ld	xix, xbc	; F36EB5  ld XIX,XBC
	cp	xbc, 82	; F36EB7  cp XBC,0x00000052
	jr	c, SysExThirdRegion_FetchNextChunk_Skip9	; F36EBD  jr C,0xf36f01
	cp	xbc, 151	; F36EBF  cp XBC,0x00000097
	jr	ugt, SysExThirdRegion_FetchNextChunk_Skip9	; F36EC5  jr UGT,0xf36f01
	lda	xwa, (2947:24)	; F36EC7  lda XWA,0x000b83
	push	xwa	; F36ECC  push XWA
	pushw	hl	; F36ECD  push HL
	push	xbc	; F36ECE  push XBC
	calr	SysExThirdRegion_MapOffsetToDspParamRun	; F36ECF  calr 0xf36c5d
SysExThirdRegion_FetchNextChunk_Join3:
	inc	8, xsp	; F36ED2  inc 0,XSP
	inc	2, xsp	; F36ED4  inc 2,XSP
	ld	bc, (2950:24)	; F36ED6  ld BC,(0x000b86)
	ld	(2569:24), bc	; F36EDB  ld (0x000a09),BC
	lda	xwa, (2827:24)	; F36EE0  lda XWA,0x000b0b
	push	xwa	; F36EE5  push XWA
	ld	iy, (2950:24)	; F36EE6  ld IY,(0x000b86)
	ldto_berp	c, 0xf4	; F36EEB  ld C,IYL
	pushw	bc	; F36EEE  push BC
	ld	bc, (2948:24)	; F36EEF  ld BC,(0x000b84)
	pushw	bc	; F36EF4  push BC
	call	T_DspParam_ReadByNumber	; F36EF5  call 0xf434a4
	calr	SysExThirdRegion_SendReplyChunk	; F36EF9  calr 0xf37e1c
	inc	8, xsp	; F36EFC  inc 0,XSP
	jrl	SysExThirdRegion_FetchNextChunk_Join5	; F36EFE  jrl T,0xf36f87
SysExThirdRegion_FetchNextChunk_Skip9:
	ld	xix, (xiz-4)	; F36F01  ld XIX,(XIZ+0xfc)
	cp	xix, 152	; F36F04  cp XIX,0x00000098
	jr	c, SysExThirdRegion_FetchNextChunk_Skip10	; F36F0A  jr C,0xf36f3c
	cp	xix, 407	; F36F0C  cp XIX,0x00000197
	jr	ugt, SysExThirdRegion_FetchNextChunk_Skip10	; F36F12  jr UGT,0xf36f3c
	lda	xbc, (2947:24)	; F36F14  lda XBC,0x000b83
	push	xbc	; F36F19  push XBC
	pushw	hl	; F36F1A  push HL
	ld	xwa, (xiz-4)	; F36F1B  ld XWA,(XIZ+0xfc)
	push	xwa	; F36F1E  push XWA
	calr	SysExThirdRegion_LocateDrumChunk	; F36F1F  calr 0xf36ced
	ld	bc, (2950:24)	; F36F22  ld BC,(0x000b86)
	ld	(2569:24), bc	; F36F27  ld (0x000a09),BC
	ld	a, (2954:24)	; F36F2C  ld A,(0x000b8a)
	pushw	wa	; F36F31  push WA
	call	T_ToneMsg80_Id16	; F36F32  call 0xf4348c
	inc	8, xsp	; F36F36  inc 0,XSP
	inc	4, xsp	; F36F38  inc 4,XSP
	jr	SysExThirdRegion_FetchNextChunk_Join4	; F36F3A  jr T,0xf36f7d
SysExThirdRegion_FetchNextChunk_Skip10:
	lda	xbc, (2947:24)	; F36F3C  lda XBC,0x000b83
	push	xbc	; F36F41  push XBC
	pushw	hl	; F36F42  push HL
	ld	xwa, (xiz-4)	; F36F43  ld XWA,(XIZ+0xfc)
	push	xwa	; F36F46  push XWA
	calr	SysExThirdRegion_LocateDrumChunk	; F36F47  calr 0xf36ced
	ld	bc, (2950:24)	; F36F4A  ld BC,(0x000b86)
	ld	(2569:24), bc	; F36F4F  ld (0x000a09),BC
	ld	a, (2954:24)	; F36F54  ld A,(0x000b8a)
	pushw	wa	; F36F59  push WA
	call	T_ToneMsg88_Id13	; F36F5A  call 0xf43488
	pushw	48	; F36F5E  push 0x0030
	ld	bc, (2950:24)	; F36F61  ld BC,(0x000b86)
	pushw	bc	; F36F66  push BC
	ld	bc, (2948:24)	; F36F67  ld BC,(0x000b84)
	pushw	bc	; F36F6C  push BC
	ld	c, (2947:24)	; F36F6D  ld C,(0x000b83)
	pushw	bc	; F36F72  push BC
	call	T_ToneMsg85_SendParam	; F36F73  call 0xf4347c
	add	xsp, 20	; F36F77  add XSP,0x00000014
SysExThirdRegion_FetchNextChunk_Join4:
	res	2, (0x000a00:24)	; F36F7D  res 2,(0x000a00)
	set	1, (0x000a00:24)	; F36F82  set 1,(0x000a00)
SysExThirdRegion_FetchNextChunk_Join5:
	pop	xix	; F36F87  pop XIX
	popw	hl	; F36F88  pop HL
	unlk XIZ	; F36F89  unlk XIZ
	ret	; F36F8B  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_AcceptRequest
; Called from: T_SysExThirdRegion_AcceptRequest (x1); far site 0xF41254
; Touches: nothing with an absolute address
; Calls:   Pack3x7BitFields_Bytes9To11 Pack3x7BitFields_Bytes6To8
; Evidence: thunk slot T_SysExThirdRegion_AcceptRequest holds `jp 0x00F36F8C`, and 0xF36F8C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_AcceptRequest: 2B request into the tone-edit image: busy ((0x0A00) bit 0) -> 1; else unpacks
;   address (msg bytes 6-8 -> (0x0A03)) and count (9-11 -> (0x0A07)) and accepts a non-empty run inside 0x040000+713
;   (melodic) or 0x060000+19608 (drum): (0x0A00) |= 5, returns 0; otherwise (0x0A00) := 0, returns 1 and the caller
;   sends the refusal. Basis: caller + body + sysex probe. (notes/naming-pilot-2026-10-06/proposals_wave3_h.json)
SysExThirdRegion_AcceptRequest:		; <- T_SysExThirdRegion_AcceptRequest
	link XIZ,0xfffc	; F36F8C  link XIZ,0xfffc
	pushw	hl	; F36F90  push HL
	push	xix	; F36F91  push XIX
	lda	xix, (2563:24)	; F36F92  lda XIX,0x000a03
	ld	bc, (2560:24)	; F36F97  ld BC,(0x000a00)
	and	bc, 1	; F36F9C  and BC,0x0001
	jr	z, SysExThirdRegion_AcceptRequest_Skip11	; F36FA0  jr Z,0xf36fa8
	ldw	wa, 1	; F36FA2  ld WA,0x0001
	jrl	SysExThirdRegion_AcceptRequest_Join8	; F36FA5  jrl T,0xf3702a
SysExThirdRegion_AcceptRequest_Skip11:
	ld	xbc, (xiz+8)	; F36FA8  ld XBC,(XIZ+0x08)
	push	xbc	; F36FAB  push XBC
	calr	Pack3x7BitFields_Bytes9To11	; F36FAC  calr 0xf36800
	ld	(2567:24), wa	; F36FAF  ld (0x000a07),WA
	ld	xbc, (xiz+8)	; F36FB4  ld XBC,(XIZ+0x08)
	push	xbc	; F36FB7  push XBC
	calr	Pack3x7BitFields_Bytes6To8	; F36FB8  calr 0xf36849
	ld	(xix), xiy	; F36FBB  ld (XIX),XIY
	inc	8, xsp	; F36FBD  inc 0,XSP
	cpw	(0x000a07:24), 0x0000	; F36FBF  cp (0x000a07),0x0000
	jr	z, SysExThirdRegion_AcceptRequest_Skip13	; F36FC6  jr Z,0xf3701e
	ld	xbc, (xix)	; F36FC8  ld XBC,(XIX)
	or	xbc, xbc	; F36FCA  or XBC,XBC
	jr	z, SysExThirdRegion_AcceptRequest_Skip13	; F36FCC  jr Z,0xf3701e
	ld	xbc, (xix)	; F36FCE  ld XBC,(XIX)
	cp	xbc, 393216	; F36FD0  cp XBC,0x00060000
	jr	ge, SysExThirdRegion_AcceptRequest_Skip12	; F36FD6  jr GE,0xf36ff6
	ld	bc, (2567:24)	; F36FD8  ld BC,(0x000a07)
	exts	xbc	; F36FDD  exts XBC
	ld	(xiz-4), xbc	; F36FDF  ld (XIZ+0xfc),XBC
	ld	xwa, (xix)	; F36FE2  ld XWA,(XIX)
	sub	xwa, 262144	; F36FE4  sub XWA,0x00040000
	add	xwa, xbc	; F36FEA  add XWA,XBC
	cp	xwa, 713	; F36FEC  cp XWA,0x000002c9
	jr	ugt, SysExThirdRegion_AcceptRequest_Skip13	; F36FF2  jr UGT,0xf3701e
	jr	SysExThirdRegion_AcceptRequest_Join6	; F36FF4  jr T,0xf37012
SysExThirdRegion_AcceptRequest_Skip12:
	ld	bc, (2567:24)	; F36FF6  ld BC,(0x000a07)
	exts	xbc	; F36FFB  exts XBC
	ld	(xiz-4), xbc	; F36FFD  ld (XIZ+0xfc),XBC
	ld	xwa, (xix)	; F37000  ld XWA,(XIX)
	sub	xwa, 393216	; F37002  sub XWA,0x00060000
	add	xwa, xbc	; F37008  add XWA,XBC
	cp	xwa, 19608	; F3700A  cp XWA,0x00004c98
	jr	ugt, SysExThirdRegion_AcceptRequest_Skip13	; F37010  jr UGT,0xf3701e
SysExThirdRegion_AcceptRequest_Join6:
	ldw	hl, 0	; F37012  ld HL,0x0000
	orw	(0x000a00:24), 0x0005	; F37015  or (0x000a00),0x0005
	jr	SysExThirdRegion_AcceptRequest_Join7	; F3701C  jr T,0xf37028
SysExThirdRegion_AcceptRequest_Skip13:
	ldw	hl, 1	; F3701E  ld HL,0x0001
	ldw	(2560:24), 0	; F37021  ld (0x000a00),0x0000
SysExThirdRegion_AcceptRequest_Join7:
	ld	wa, hl	; F37028  ld WA,HL
SysExThirdRegion_AcceptRequest_Join8:
	pop	xix	; F3702A  pop XIX
	popw	hl	; F3702B  pop HL
	unlk XIZ	; F3702C  unlk XIZ
	ret	; F3702E  ret

; --------------------------------------------------------------------------
; ClampFieldToRange
; Called from: in-module: 0xF37584 0xF3799A
; Touches: nothing with an absolute address
; Calls:   Asr16ByCount
; Evidence: five 16-bit words are read off the caller's stack -- (XIZ+0x08)
;           value, (XIZ+0x0A) mask, (XIZ+0x0C) shift, (XIZ+0x0E) maximum,
;           (XIZ+0x10) minimum.  The body is `ld DE,(XIZ+0x0a) / and
;           DE,(XIZ+0x08)` then a shift by (XIZ+0x0C) through Asr16ByCount, then
;           `cp WA,(XIZ+0x0e) / jr LE` and `cp HL,(XIZ+0x10) / jr GE` -- a
;           SIGNED clamp, which is what one arm's 0xFFC4/0x003C pair
;           (-60..+60) requires -- then `cpl BC / and BC,(XIZ+0x08) / or
;           BC,HL`, which puts the clamped field back under the same mask and
;           leaves every other bit of the value alone.
; Unknown: what the value IS.  The routine is a generic field clamp; the
;          meaning of the mask, the shift and the range comes from whichever
;          arm called it, and no arm carries a name.
; --------------------------------------------------------------------------
ClampFieldToRange:
	link XIZ,0x0000	; F3702F  link XIZ,0x0000
	pushw	hl	; F37033  push HL
	pushw	de	; F37034  push DE
	ld	de, (xiz+10)	; F37035  ld DE,(XIZ+0x0a)
	and	de, (xiz+8)	; F37038  and DE,(XIZ+0x08)
	ld	c, (xiz+12)	; F3703B  ld C,(XIZ+0x0c)
	pushw	bc	; F3703E  push BC
	pushw	de	; F3703F  push DE
	call	Asr16ByCount	; F37040  call 0xf37f70
	ld	hl, wa	; F37044  ld HL,WA
	cp	wa, (xiz+14)	; F37046  cp WA,(XIZ+0x0e)
	jr	le, ClampFieldToRange_Skip	; F37049  jr LE,0xf37050
	ld	hl, (xiz+14)	; F3704B  ld HL,(XIZ+0x0e)
	jr	ClampFieldToRange_Join	; F3704E  jr T,0xf37058
ClampFieldToRange_Skip:
	cp	hl, (xiz+16)	; F37050  cp HL,(XIZ+0x10)
	jr	ge, ClampFieldToRange_Join	; F37053  jr GE,0xf37058
	ld	hl, (xiz+16)	; F37055  ld HL,(XIZ+0x10)
ClampFieldToRange_Join:
	ld	bc, (xiz+10)	; F37058  ld BC,(XIZ+0x0a)
	cpl	bc	; F3705B  cpl BC
	and	bc, (xiz+8)	; F3705D  and BC,(XIZ+0x08)
	or	bc, hl	; F37060  or BC,HL
	ld	a, c	; F37062  ld A,C
	popw	de	; F37064  pop DE
	popw	hl	; F37065  pop HL
	unlk XIZ	; F37066  unlk XIZ
	ret	; F37068  ret

; --------------------------------------------------------------------------
; ClampParamValueById_From541
; Called from: in-module: 0xF37A0F
; Touches: nothing with an absolute address
; Calls:   Divide32_Unsigned_Remainder
; Evidence: `ld XIX,(XIZ+0x08) / cp XIX,0x0000021d`: an id of 541 or more is
;           reduced by `sub XBC,0x21d` and Divide32_Unsigned_Remainder with a
;           divisor of 0x2B, bounded `cp IY,0x0029`, and indexes
;           ParamRangeArms_F370A7; below that, `cp XIX,0x000000d9` splits
;           217-and-up (mod 0x51, bound 0x4C, ParamRangeArms_F3719C) from the
;           rest (the id itself, bound 0x89, ParamRangeArms_F37312).  The name
;           says the FIRST of the three bases; the other two are in the table
;           headers below and in --selftest.
; Unknown: what the parameter ids ENUMERATE.  They arrive from outside the
;          span through T_F41250-T_F41264 and nothing decoded here says what
;          any of them is.
; --------------------------------------------------------------------------
ClampParamValueById_From541:
	link XIZ,0x0000	; F37069  link XIZ,0x0000
	pushw	hl	; F3706D  push HL
	push	xix	; F3706E  push XIX
	ld	h, (xiz+12)	; F3706F  ld H,(XIZ+0x0c)
	ld	xix, (xiz+8)	; F37072  ld XIX,(XIZ+0x08)
	cp	xix, 541	; F37075  cp XIX,0x0000021d
	jrl	c, ClampArm541_M60To60_MaskFFFF_Skip	; F3707B  jrl C,0xf3716a
	ld	xbc, xix	; F3707E  ld XBC,XIX
	sub	xbc, 541	; F37080  sub XBC,0x0000021d
	pushw	0	; F37086  push 0x0000
	pushw	43	; F37089  push 0x002b
	push	xbc	; F3708C  push XBC
	call	Divide32_Unsigned_Remainder	; F3708D  call 0xf37f91
	extz	xiy	; F37091  extz XIY
	cp	iy, 41	; F37093  cp IY,0x0029
	jrl	ugt, ClampParamValueById_Unchanged	; F37097  jrl UGT,0xf3758d
	sll	iy, 2	; F3709A  sll 0x02,IY
	add	xiy, ParamRangeArms_F370A7	; F3709D  add XIY,0x00f370a7
	ld	xiy, (xiy)	; F370A3  ld XIY,(XIY)
	jp	(xiy)	; F370A5  jp T,XIY

; --------------------------------------------------------------------------
; ParamRangeArms_F370A7 -- 42 32-bit entries, all inside this block
;                          (0xF3714F-0xF3758D), naming 8 distinct arms.  Each
;                          arm is one or two `push imm16` instructions -- that
;                          parameter's MINIMUM and MAXIMUM -- and a jump to a
;                          shared tail that pushes the mask and the shift and
;                          calls ClampFieldToRange.
; Read by: 0xF3709D, `sll 0x02,IY / add XIY,0x00F370A7 / ld XIY,(XIY) / jp
;          (XIY)`, with the index bounded by the `cp IY,0x0029 / jrl
;          UGT,0xF3758D` at 0xF37093 immediately above it.
; Evidence: the ENTRY COUNT IS PROVED BY THE INDEXER'S OWN BOUND, not by the
;           extent: `cp IY,0x0029 / jrl UGT,0xF3758D` at 0xF37093 admits
;           indices 0..41, and 42 x 4 = 168 bytes, which is exactly this
;           segment.  Every word is re-read on each emit and asserted to land
;           inside 0xF353AB-0xF3934C.
; Unknown: WHICH parameter each index is.  Nothing in this span names one, so
;          the table keeps a FRAMED name and not one arm is given a
;          parameter's name.  ★ The ROWS are the evidence a later lane will
;          match names to: entry [i]'s arm carries that parameter's legal
;          range as two immediates.
; --------------------------------------------------------------------------
ParamRangeArms_F370A7:
	.long	ClampArm541_0To127_MaskFFFF	; F370A7  [0] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F370AB  [1] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F370AF  [2] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F370B3  [3] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F370B7  [4] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To127_MaskFFFF	; F370BB  [5] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F370BF  [6] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To127_MaskFFFF	; F370C3  [7] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F370C7  [8] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To127_MaskFFFF	; F370CB  [9] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F370CF  [10] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To63_Mask3F	; F370D3  [11] -> ClampArm541_0To63_Mask3F
	.long	ClampArm541_0To63_MaskFFFF	; F370D7  [12] -> ClampArm541_0To63_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F370DB  [13] -> ClampParamValueById_Unchanged
	.long	ClampParamValueById_Unchanged	; F370DF  [14] -> ClampParamValueById_Unchanged
	.long	ClampParamValueById_Unchanged	; F370E3  [15] -> ClampParamValueById_Unchanged
	.long	ClampArm541_M50To50_MaskFFFF	; F370E7  [16] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To50_MaskFFFF	; F370EB  [17] -> ClampArm541_0To50_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F370EF  [18] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F370F3  [19] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F370F7  [20] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F370FB  [21] -> ClampParamValueById_Unchanged
	.long	ClampArm541_M50To50_MaskFFFF	; F370FF  [22] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37103  [23] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37107  [24] -> ClampParamValueById_Unchanged
	.long	ClampParamValueById_Unchanged	; F3710B  [25] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To127_MaskFFFF	; F3710F  [26] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37113  [27] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37117  [28] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M60To60_MaskFFFF	; F3711B  [29] -> ClampArm541_M60To60_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3711F  [30] -> ClampParamValueById_Unchanged
	.long	ClampParamValueById_Unchanged	; F37123  [31] -> ClampParamValueById_Unchanged
	.long	ClampArm541_M50To50_MaskFFFF	; F37127  [32] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3712B  [33] -> ClampParamValueById_Unchanged
	.long	ClampArm541_M50To50_MaskFFFF	; F3712F  [34] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37133  [35] -> ClampParamValueById_Unchanged
	.long	ClampArm541_M50To50_MaskFFFF	; F37137  [36] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3713B  [37] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To127_MaskFFFF	; F3713F  [38] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37143  [39] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37147  [40] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M60To60_MaskFFFF	; F3714B  [41] -> ClampArm541_M60To60_MaskFFFF


; --------------------------------------------------------------------------
; ClampArm541_0To63_Mask3F
; Called from: arm table 0xF370A7[11]
; Touches: nothing with an absolute address
; Evidence: entry [11] of the arm table at 0xF370A7 reads 0x00F3714F, that
;           table's indexer ends `jp (Xrr)`, and 0xF3714F is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To63_Mask3F: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0x3F, shift 0, max 63, min 0), a signed
;   clamp of the masked field to 0..63 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To63_Mask3F:
	pushw	0	; F3714F  push 0x0000
	pushw	63	; F37152  push 0x003f
	jrl	ClampArm541_0To30_Mask3F_Join	; F37155  jrl T,0xf37579

; --------------------------------------------------------------------------
; ClampArm541_0To63_MaskFFFF
; Called from: arm table 0xF370A7[12]
; Touches: nothing with an absolute address
; Evidence: entry [12] of the arm table at 0xF370A7 reads 0x00F37158, that
;           table's indexer ends `jp (Xrr)`, and 0xF37158 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To63_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 63, min 0), a signed
;   clamp of the masked field to 0..63 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To63_MaskFFFF:
	pushw	0	; F37158  push 0x0000
	pushw	63	; F3715B  push 0x003f
	jrl	ClampArm541_6To10_MaskFFFF_Join	; F3715E  jrl T,0xf3755d

; --------------------------------------------------------------------------
; ClampArm541_M60To60_MaskFFFF
; Called from: arm table 0xF370A7[29], 0xF370A7[41]
; Touches: nothing with an absolute address
; Calls:   Divide32_Unsigned_Remainder
; Evidence: entry [29] of the arm table at 0xF370A7 reads 0x00F37161, that
;           table's indexer ends `jp (Xrr)`, and 0xF37161 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_M60To60_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 60, min -60), a signed
;   clamp of the masked field to -60..60 (notes/prom_b_param_range_arm_names.py).
ClampArm541_M60To60_MaskFFFF:
	pushw	65476	; F37161  push 0xffc4
	pushw	60	; F37164  push 0x003c
	jrl	ClampArm541_6To10_MaskFFFF_Join	; F37167  jrl T,0xf3755d
ClampArm541_M60To60_MaskFFFF_Skip:
	cp	xix, 217	; F3716A  cp XIX,0x000000d9
	jrl	c, ClampArm541_0To100_MaskFFFF_Skip	; F37170  jrl C,0xf372f9
	ld	xbc, xix	; F37173  ld XBC,XIX
	sub	xbc, 217	; F37175  sub XBC,0x000000d9
	pushw	0	; F3717B  push 0x0000
	pushw	81	; F3717E  push 0x0051
	push	xbc	; F37181  push XBC
	call	Divide32_Unsigned_Remainder	; F37182  call 0xf37f91
	extz	xiy	; F37186  extz XIY
	cp	iy, 76	; F37188  cp IY,0x004c
	jrl	ugt, ClampParamValueById_Unchanged	; F3718C  jrl UGT,0xf3758d
	sll	iy, 2	; F3718F  sll 0x02,IY
	add	xiy, ParamRangeArms_F3719C	; F37192  add XIY,0x00f3719c
	ld	xiy, (xiy)	; F37198  ld XIY,(XIY)
	jp	(xiy)	; F3719A  jp T,XIY

; --------------------------------------------------------------------------
; ParamRangeArms_F3719C -- 77 32-bit entries, all inside this block
;                          (0xF372D0-0xF3758D), naming 7 distinct arms.  Each
;                          arm is one or two `push imm16` instructions -- that
;                          parameter's MINIMUM and MAXIMUM -- and a jump to a
;                          shared tail that pushes the mask and the shift and
;                          calls ClampFieldToRange.
; Read by: 0xF37192, `sll 0x02,IY / add XIY,0x00F3719C / ld XIY,(XIY) / jp
;          (XIY)`, with the index bounded by the `cp IY,0x004C / jrl
;          UGT,0xF3758D` at 0xF37188 immediately above it.
; Evidence: the ENTRY COUNT IS PROVED BY THE INDEXER'S OWN BOUND, not by the
;           extent: `cp IY,0x004C / jrl UGT,0xF3758D` at 0xF37188 admits
;           indices 0..76, and 77 x 4 = 308 bytes, which is exactly this
;           segment.  Every word is re-read on each emit and asserted to land
;           inside 0xF353AB-0xF3934C.
; Unknown: WHICH parameter each index is.  Nothing in this span names one, so
;          the table keeps a FRAMED name and not one arm is given a
;          parameter's name.  ★ The ROWS are the evidence a later lane will
;          match names to: entry [i]'s arm carries that parameter's legal
;          range as two immediates.
; --------------------------------------------------------------------------
ParamRangeArms_F3719C:
	.long	ClampArm541_0To50_MaskFFFF	; F3719C  [0] -> ClampArm541_0To50_MaskFFFF
	.long	ClampArm541_0To128_MaskFFFF	; F371A0  [1] -> ClampArm541_0To128_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F371A4  [2] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F371A8  [3] -> ClampParamValueById_Unchanged
	.long	ClampArm541_M24To24_MaskFFFF	; F371AC  [4] -> ClampArm541_M24To24_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F371B0  [5] -> ClampParamValueById_Unchanged
	.long	ClampParamValueById_Unchanged	; F371B4  [6] -> ClampParamValueById_Unchanged
	.long	ClampArm541_M50To50_MaskFFFF	; F371B8  [7] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371BC  [8] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F371C0  [9] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371C4  [10] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F371C8  [11] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371CC  [12] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F371D0  [13] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371D4  [14] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F371D8  [15] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371DC  [16] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371E0  [17] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371E4  [18] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F371E8  [19] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371EC  [20] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371F0  [21] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371F4  [22] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F371F8  [23] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F371FC  [24] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37200  [25] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To127_MaskFFFF	; F37204  [26] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37208  [27] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F3720C  [28] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37210  [29] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37214  [30] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37218  [31] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F3721C  [32] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37220  [33] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37224  [34] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37228  [35] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F3722C  [36] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37230  [37] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37234  [38] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To100_MaskFFFF	; F37238  [39] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F3723C  [40] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F37240  [41] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F37244  [42] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F37248  [43] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F3724C  [44] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F37250  [45] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37254  [46] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37258  [47] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F3725C  [48] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37260  [49] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37264  [50] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37268  [51] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F3726C  [52] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37270  [53] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37274  [54] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To50_MaskFFFF	; F37278  [55] -> ClampArm541_0To50_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3727C  [56] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To127_MaskFFFF	; F37280  [57] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37284  [58] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37288  [59] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F3728C  [60] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37290  [61] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F37294  [62] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F37298  [63] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F3729C  [64] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F372A0  [65] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F372A4  [66] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F372A8  [67] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F372AC  [68] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To100_MaskFFFF	; F372B0  [69] -> ClampArm541_0To100_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F372B4  [70] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F372B8  [71] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F372BC  [72] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F372C0  [73] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F372C4  [74] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F372C8  [75] -> ClampArm541_M50To50_MaskFFFF
	.long	ClampArm541_M50To50_MaskFFFF	; F372CC  [76] -> ClampArm541_M50To50_MaskFFFF


; --------------------------------------------------------------------------
; ClampArm541_0To50_MaskFFFF
; Called from: arm table 0xF370A7[17], 0xF3719C[0], 0xF3719C[55]
; Touches: nothing with an absolute address
; Evidence: entry [17] of the arm table at 0xF370A7 reads 0x00F372D0, that
;           table's indexer ends `jp (Xrr)`, and 0xF372D0 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To50_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 50, min 0), a signed
;   clamp of the masked field to 0..50 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To50_MaskFFFF:
	pushw	0	; F372D0  push 0x0000
	jr	ClampArm541_M50To50_MaskFFFF_Skip	; F372D3  jr T,0xf372ea

; --------------------------------------------------------------------------
; ClampArm541_0To128_MaskFFFF
; Called from: arm table 0xF3719C[1]
; Touches: nothing with an absolute address
; Evidence: entry [1] of the arm table at 0xF3719C reads 0x00F372D5, that
;           table's indexer ends `jp (Xrr)`, and 0xF372D5 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To128_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 128, min 0), a signed
;   clamp of the masked field to 0..128 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To128_MaskFFFF:
	pushw	0	; F372D5  push 0x0000
	pushw	128	; F372D8  push 0x0080
	jrl	ClampArm541_6To10_MaskFFFF_Join	; F372DB  jrl T,0xf3755d

; --------------------------------------------------------------------------
; ClampArm541_M24To24_MaskFFFF
; Called from: arm table 0xF3719C[4]
; Touches: nothing with an absolute address
; Evidence: entry [4] of the arm table at 0xF3719C reads 0x00F372DE, that
;           table's indexer ends `jp (Xrr)`, and 0xF372DE is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_M24To24_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 24, min -24), a signed
;   clamp of the masked field to -24..24 (notes/prom_b_param_range_arm_names.py).
ClampArm541_M24To24_MaskFFFF:
	pushw	65512	; F372DE  push 0xffe8
	pushw	24	; F372E1  push 0x0018
	jrl	ClampArm541_6To10_MaskFFFF_Join	; F372E4  jrl T,0xf3755d

; --------------------------------------------------------------------------
; ClampArm541_M50To50_MaskFFFF
; Called from: arm table 0xF370A7[16], 0xF370A7[22], 0xF370A7[23],
;              0xF370A7[28], 0xF370A7[32], 0xF370A7[34] +32 more
; Touches: nothing with an absolute address
; Evidence: entry [16] of the arm table at 0xF370A7 reads 0x00F372E7, that
;           table's indexer ends `jp (Xrr)`, and 0xF372E7 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_M50To50_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 50, min -50), a signed
;   clamp of the masked field to -50..50 (notes/prom_b_param_range_arm_names.py).
ClampArm541_M50To50_MaskFFFF:
	pushw	65486	; F372E7  push 0xffce
ClampArm541_M50To50_MaskFFFF_Skip:
	pushw	50	; F372EA  push 0x0032
	jrl	ClampArm541_6To10_MaskFFFF_Join	; F372ED  jrl T,0xf3755d

; --------------------------------------------------------------------------
; ClampArm541_0To100_MaskFFFF
; Called from: arm table 0xF3719C[9], 0xF3719C[11], 0xF3719C[13],
;              0xF3719C[15], 0xF3719C[39], 0xF3719C[40] +9 more
; Touches: nothing with an absolute address
; Evidence: entry [9] of the arm table at 0xF3719C reads 0x00F372F0, that
;           table's indexer ends `jp (Xrr)`, and 0xF372F0 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To100_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 100, min 0), a signed
;   clamp of the masked field to 0..100 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To100_MaskFFFF:
	pushw	0	; F372F0  push 0x0000
	pushw	100	; F372F3  push 0x0064
	jrl	ClampArm541_6To10_MaskFFFF_Join	; F372F6  jrl T,0xf3755d
ClampArm541_0To100_MaskFFFF_Skip:
	ld	bc, (xiz+8)	; F372F9  ld BC,(XIZ+0x08)
	extz	xbc	; F372FC  extz XBC
	cp	bc, 137	; F372FE  cp BC,0x0089
	jrl	ugt, ClampParamValueById_Unchanged	; F37302  jrl UGT,0xf3758d
	sll	bc, 2	; F37305  sll 0x02,BC
	add	xbc, ParamRangeArms_F37312	; F37308  add XBC,0x00f37312
	ld	xbc, (xbc)	; F3730E  ld XBC,(XBC)
	jp	(xbc)	; F37310  jp T,XBC

; --------------------------------------------------------------------------
; ParamRangeArms_F37312 -- 138 32-bit entries, all inside this block
;                          (0xF3753A-0xF3758D), naming 8 distinct arms.  Each
;                          arm is one or two `push imm16` instructions -- that
;                          parameter's MINIMUM and MAXIMUM -- and a jump to a
;                          shared tail that pushes the mask and the shift and
;                          calls ClampFieldToRange.
; Read by: 0xF37308, `sll 0x02,BC / add XBC,0x00F37312 / ld XBC,(XBC) / jp
;          (XBC)`, with the index bounded by the `cp BC,0x0089 / jrl
;          UGT,0xF3758D` at 0xF372FE immediately above it.
; Evidence: the ENTRY COUNT IS PROVED BY THE INDEXER'S OWN BOUND, not by the
;           extent: `cp BC,0x0089 / jrl UGT,0xF3758D` at 0xF372FE admits
;           indices 0..137, and 138 x 4 = 552 bytes, which is exactly this
;           segment.  Every word is re-read on each emit and asserted to land
;           inside 0xF353AB-0xF3934C.
; Unknown: WHICH parameter each index is.  Nothing in this span names one, so
;          the table keeps a FRAMED name and not one arm is given a
;          parameter's name.  ★ The ROWS are the evidence a later lane will
;          match names to: entry [i]'s arm carries that parameter's legal
;          range as two immediates.
; --------------------------------------------------------------------------
ParamRangeArms_F37312:
	.long	ClampArm541_32To127_MaskFFFF	; F37312  [0] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F37316  [1] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F3731A  [2] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F3731E  [3] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F37322  [4] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F37326  [5] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F3732A  [6] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F3732E  [7] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F37332  [8] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F37336  [9] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F3733A  [10] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F3733E  [11] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F37342  [12] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F37346  [13] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F3734A  [14] -> ClampArm541_32To127_MaskFFFF
	.long	ClampArm541_32To127_MaskFFFF	; F3734E  [15] -> ClampArm541_32To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37352  [16] -> ClampParamValueById_Unchanged
	.long	ClampParamValueById_Unchanged	; F37356  [17] -> ClampParamValueById_Unchanged
	.long	ClampParamValueById_Unchanged	; F3735A  [18] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To66_MaskFFFF	; F3735E  [19] -> ClampArm541_0To66_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37362  [20] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F37366  [21] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F3736A  [22] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3736E  [23] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F37372  [24] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F37376  [25] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3737A  [26] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F3737E  [27] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F37382  [28] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37386  [29] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F3738A  [30] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F3738E  [31] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37392  [32] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F37396  [33] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F3739A  [34] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3739E  [35] -> ClampParamValueById_Unchanged
	.long	ClampParamValueById_Unchanged	; F373A2  [36] -> ClampParamValueById_Unchanged
	.long	ClampParamValueById_Unchanged	; F373A6  [37] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F373AA  [38] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F373AE  [39] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F373B2  [40] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F373B6  [41] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F373BA  [42] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F373BE  [43] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F373C2  [44] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F373C6  [45] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F373CA  [46] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F373CE  [47] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F373D2  [48] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F373D6  [49] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F373DA  [50] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F373DE  [51] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F373E2  [52] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F373E6  [53] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F373EA  [54] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F373EE  [55] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F373F2  [56] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F373F6  [57] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F373FA  [58] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F373FE  [59] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F37402  [60] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37406  [61] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F3740A  [62] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F3740E  [63] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37412  [64] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F37416  [65] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F3741A  [66] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3741E  [67] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F37422  [68] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F37426  [69] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3742A  [70] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F3742E  [71] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F37432  [72] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37436  [73] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F3743A  [74] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F3743E  [75] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F37442  [76] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F37446  [77] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F3744A  [78] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3744E  [79] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F37452  [80] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F37456  [81] -> ClampArm541_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3745A  [82] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To49_Mask7F	; F3745E  [83] -> ClampArm541_0To49_Mask7F
	.long	ClampArm541_0To127_MaskFFFF	; F37462  [84] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_6To10_MaskFFFF	; F37466  [85] -> ClampArm541_6To10_MaskFFFF
	.long	ClampParamValueById_Unchanged	; F3746A  [86] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To127_MaskFFFF	; F3746E  [87] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37472  [88] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F37476  [89] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F3747A  [90] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F3747E  [91] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37482  [92] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F37486  [93] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F3748A  [94] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F3748E  [95] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37492  [96] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F37496  [97] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F3749A  [98] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F3749E  [99] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F374A2  [100] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F374A6  [101] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F374AA  [102] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F374AE  [103] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F374B2  [104] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F374B6  [105] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F374BA  [106] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F374BE  [107] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F374C2  [108] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F374C6  [109] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F374CA  [110] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F374CE  [111] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F374D2  [112] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F374D6  [113] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F374DA  [114] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F374DE  [115] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F374E2  [116] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F374E6  [117] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F374EA  [118] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F374EE  [119] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F374F2  [120] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F374F6  [121] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F374FA  [122] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F374FE  [123] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37502  [124] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F37506  [125] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F3750A  [126] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F3750E  [127] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37512  [128] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F37516  [129] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F3751A  [130] -> ClampArm541_0To30_Mask3F
	.long	ClampArm541_0To127_MaskFFFF	; F3751E  [131] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37522  [132] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To50_Mask7F	; F37526  [133] -> ClampArm541_0To50_Mask7F
	.long	ClampArm541_0To30_Mask3F	; F3752A  [134] -> ClampArm541_0To30_Mask3F
	.long	ClampParamValueById_Unchanged	; F3752E  [135] -> ClampParamValueById_Unchanged
	.long	ClampArm541_0To127_MaskFFFF	; F37532  [136] -> ClampArm541_0To127_MaskFFFF
	.long	ClampArm541_0To127_MaskFFFF	; F37536  [137] -> ClampArm541_0To127_MaskFFFF


; --------------------------------------------------------------------------
; ClampArm541_32To127_MaskFFFF
; Called from: arm table 0xF37312[0], 0xF37312[1], 0xF37312[2], 0xF37312[3],
;              0xF37312[4], 0xF37312[5] +10 more
; Touches: nothing with an absolute address
; Evidence: entry [0] of the arm table at 0xF37312 reads 0x00F3753A, that
;           table's indexer ends `jp (Xrr)`, and 0xF3753A is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_32To127_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 127, min 32), a signed
;   clamp of the masked field to 32..127 (notes/prom_b_param_range_arm_names.py).
ClampArm541_32To127_MaskFFFF:
	pushw	32	; F3753A  push 0x0020
	jr	ClampArm541_0To127_MaskFFFF_Skip	; F3753D  jr T,0xf37552

; --------------------------------------------------------------------------
; ClampArm541_0To66_MaskFFFF
; Called from: arm table 0xF37312[19]
; Touches: nothing with an absolute address
; Evidence: entry [19] of the arm table at 0xF37312 reads 0x00F3753F, that
;           table's indexer ends `jp (Xrr)`, and 0xF3753F is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To66_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 66, min 0), a signed
;   clamp of the masked field to 0..66 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To66_MaskFFFF:
	pushw	0	; F3753F  push 0x0000
	pushw	66	; F37542  push 0x0042
	jr	ClampArm541_6To10_MaskFFFF_Join	; F37545  jr T,0xf3755d

; --------------------------------------------------------------------------
; ClampArm541_0To49_Mask7F
; Called from: arm table 0xF37312[21], 0xF37312[24], 0xF37312[27],
;              0xF37312[30], 0xF37312[33], 0xF37312[38] +15 more
; Touches: nothing with an absolute address
; Evidence: entry [21] of the arm table at 0xF37312 reads 0x00F37547, that
;           table's indexer ends `jp (Xrr)`, and 0xF37547 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To49_Mask7F: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0x7F, shift 0, max 49, min 0), a signed
;   clamp of the masked field to 0..49 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To49_Mask7F:
	pushw	0	; F37547  push 0x0000
	pushw	49	; F3754A  push 0x0031
	jr	ClampArm541_0To50_Mask7F_Join	; F3754D  jr T,0xf3756b

; --------------------------------------------------------------------------
; ClampArm541_0To127_MaskFFFF
; Called from: arm table 0xF370A7[0], 0xF370A7[1], 0xF370A7[2], 0xF370A7[3],
;              0xF370A7[5], 0xF370A7[7] +75 more
; Touches: nothing with an absolute address
; Evidence: entry [0] of the arm table at 0xF370A7 reads 0x00F3754F, that
;           table's indexer ends `jp (Xrr)`, and 0xF3754F is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To127_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 127, min 0), a signed
;   clamp of the masked field to 0..127 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To127_MaskFFFF:
	pushw	0	; F3754F  push 0x0000
ClampArm541_0To127_MaskFFFF_Skip:
	pushw	127	; F37552  push 0x007f
	jr	ClampArm541_6To10_MaskFFFF_Join	; F37555  jr T,0xf3755d

; --------------------------------------------------------------------------
; ClampArm541_6To10_MaskFFFF
; Called from: arm table 0xF37312[85]
; Touches: nothing with an absolute address
; Evidence: entry [85] of the arm table at 0xF37312 reads 0x00F37557, that
;           table's indexer ends `jp (Xrr)`, and 0xF37557 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_6To10_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 10, min 6), a signed
;   clamp of the masked field to 6..10 (notes/prom_b_param_range_arm_names.py).
ClampArm541_6To10_MaskFFFF:
	pushw	6	; F37557  push 0x0006
	pushw	10	; F3755A  push 0x000a
ClampArm541_6To10_MaskFFFF_Join:
	pushw	0	; F3755D  push 0x0000
	pushw	65535	; F37560  push 0xffff
	jr	ClampArm541_0To30_Mask3F_Join2	; F37563  jr T,0xf3757f

; --------------------------------------------------------------------------
; ClampArm541_0To50_Mask7F
; Called from: arm table 0xF370A7[18], 0xF37312[89], 0xF37312[93],
;              0xF37312[97], 0xF37312[101], 0xF37312[105] +7 more
; Touches: nothing with an absolute address
; Evidence: entry [18] of the arm table at 0xF370A7 reads 0x00F37565, that
;           table's indexer ends `jp (Xrr)`, and 0xF37565 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To50_Mask7F: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0x7F, shift 0, max 50, min 0), a signed
;   clamp of the masked field to 0..50 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To50_Mask7F:
	pushw	0	; F37565  push 0x0000
	pushw	50	; F37568  push 0x0032
ClampArm541_0To50_Mask7F_Join:
	pushw	0	; F3756B  push 0x0000
	pushw	127	; F3756E  push 0x007f
	jr	ClampArm541_0To30_Mask3F_Join2	; F37571  jr T,0xf3757f

; --------------------------------------------------------------------------
; ClampArm541_0To30_Mask3F
; Called from: arm table 0xF37312[90], 0xF37312[94], 0xF37312[98],
;              0xF37312[102], 0xF37312[106], 0xF37312[110] +6 more
; Touches: nothing with an absolute address
; Calls:   ClampFieldToRange
; Evidence: entry [90] of the arm table at 0xF37312 reads 0x00F37573, that
;           table's indexer ends `jp (Xrr)`, and 0xF37573 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm541_0To30_Mask3F: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0x3F, shift 0, max 30, min 0), a signed
;   clamp of the masked field to 0..30 (notes/prom_b_param_range_arm_names.py).
ClampArm541_0To30_Mask3F:
	pushw	0	; F37573  push 0x0000
	pushw	30	; F37576  push 0x001e
ClampArm541_0To30_Mask3F_Join:
	pushw	0	; F37579  push 0x0000
	pushw	63	; F3757C  push 0x003f
ClampArm541_0To30_Mask3F_Join2:
	ld	c, h	; F3757F  ld C,H
	exts	bc	; F37581  exts BC
	pushw	bc	; F37583  push BC
	calr	ClampFieldToRange	; F37584  calr 0xf3702f
	ld	h, a	; F37587  ld H,A
	inc	8, xsp	; F37589  inc 0,XSP
	inc	2, xsp	; F3758B  inc 2,XSP

; --------------------------------------------------------------------------
; ClampParamValueById_Unchanged
; Called from: arm table 0xF370A7[4], 0xF370A7[6], 0xF370A7[8], 0xF370A7[10],
;              0xF370A7[13], 0xF370A7[14] +44 more
; Touches: nothing with an absolute address
; Evidence: entry [4] of the arm table at 0xF370A7 reads 0x00F3758D, that
;           table's indexer ends `jp (Xrr)`, and 0xF3758D is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampParamValueById_Unchanged: the out-of-range exit of a ParamRangeArms table -- returns the value unclamped
;   (notes/prom_b_param_range_arm_names.py).
ClampParamValueById_Unchanged:
	ld	a, h	; F3758D  ld A,H
	pop	xix	; F3758F  pop XIX
	popw	hl	; F37590  pop HL
	unlk XIZ	; F37591  unlk XIZ
	ret	; F37593  ret

; --------------------------------------------------------------------------
; ClampParamValueById_From408
; Called from: in-module: 0xF37BD5
; Touches: nothing with an absolute address
; Calls:   Divide32_Unsigned_Quotient Divide32_Unsigned_Remainder
; Evidence: the same shape with a different id space: `cp XBC,0x00000198`
;           (408), then Divide32_Unsigned_Quotient by 0x96 (150), `ld A,0x96 /
;           mul WA,E / add XWA,0x000001d8` to rebuild the row base, and a
;           residue taken mod 0x2B (bound 0x29, ParamRangeArms_F3760E) or mod
;           0x3B+1 (bound 0x3B, ParamRangeArms_F37705); an id below 408
;           indexes ParamRangeArms_F3782E directly, bound 0x51.  It returns
;           through 0xF379A3, the OTHER default arm, where 0xF37069 returns
;           through 0xF3758D.
; Unknown: the same gap, and additionally why there are TWO id spaces with two
;          default arms.
; --------------------------------------------------------------------------
ClampParamValueById_From408:
	link XIZ,0xfff8	; F37594  link XIZ,0xfff8
	pushw	hl	; F37598  push HL
	pushw	de	; F37599  push DE
	push	xix	; F3759A  push XIX
	ld	d, (xiz+12)	; F3759B  ld D,(XIZ+0x0c)
	ld	xbc, (xiz+8)	; F3759E  ld XBC,(XIZ+0x08)
	ld	(xiz-4), xbc	; F375A1  ld (XIZ+0xfc),XBC
	cp	xbc, 408	; F375A4  cp XBC,0x00000198
	jrl	c, ClampArm408_0To100_MaskFFFF_Skip	; F375AA  jrl C,0xf37815
	sub	xbc, 408	; F375AD  sub XBC,0x00000198
	pushw	0	; F375B3  push 0x0000
	pushw	150	; F375B6  push 0x0096
	push	xbc	; F375B9  push XBC
	call	Divide32_Unsigned_Quotient	; F375BA  call 0xf37f3a
	ldto_berp	e, 0xf4	; F375BE  ld E,IYL
	sub	xbc, xbc	; F375C1  sub XBC,XBC
	ld	(xiz-8), xbc	; F375C3  ld (XIZ+0xf8),XBC
	ld	a, 150:opc	; F375C6  ld A,0x96
	mul	wa, e	; F375C8  mul WA,E
	ld	hl, wa	; F375CA  ld HL,WA
	extz	xwa	; F375CC  extz XWA
	ld	xix, xwa	; F375CE  ld XIX,XWA
	add	xwa, 472	; F375D0  add XWA,0x000001d8
	ld	xix, xwa	; F375D6  ld XIX,XWA
	add	xbc, xwa	; F375D8  add XBC,XWA
	extz	xbc	; F375DA  extz XBC
	cp	xbc, (xiz-4)	; F375DC  cp XBC,(XIZ+0xfc)
	jrl	ugt, ClampArm408_M60To60_MaskFFFF_Skip	; F375DF  jrl UGT,0xf376e0
	sub	xbc, xbc	; F375E2  sub XBC,XBC
	add	xbc, xwa	; F375E4  add XBC,XWA
	extz	xbc	; F375E6  extz XBC
	ld	xwa, (xiz-4)	; F375E8  ld XWA,(XIZ+0xfc)
	sub	xwa, xbc	; F375EB  sub XWA,XBC
	pushw	0	; F375ED  push 0x0000
	pushw	43	; F375F0  push 0x002b
	push	xwa	; F375F3  push XWA
	call	Divide32_Unsigned_Remainder	; F375F4  call 0xf37f91
	extz	xiy	; F375F8  extz XIY
	cp	iy, 41	; F375FA  cp IY,0x0029
	jrl	ugt, ClampParamValueById_Unchanged2	; F375FE  jrl UGT,0xf379a3
	sll	iy, 2	; F37601  sll 0x02,IY
	add	xiy, ParamRangeArms_F3760E	; F37604  add XIY,0x00f3760e
	ld	xiy, (xiy)	; F3760A  ld XIY,(XIY)
	jp	(xiy)	; F3760C  jp T,XIY

; --------------------------------------------------------------------------
; ParamRangeArms_F3760E -- 42 32-bit entries, all inside this block
;                          (0xF376B6-0xF379A3), naming 8 distinct arms.  Each
;                          arm is one or two `push imm16` instructions -- that
;                          parameter's MINIMUM and MAXIMUM -- and a jump to a
;                          shared tail that pushes the mask and the shift and
;                          calls ClampFieldToRange.
; Read by: 0xF37604, `sll 0x02,IY / add XIY,0x00F3760E / ld XIY,(XIY) / jp
;          (XIY)`, with the index bounded by the `cp IY,0x0029 / jrl
;          UGT,0xF379A3` at 0xF375FA immediately above it.
; Evidence: the ENTRY COUNT IS PROVED BY THE INDEXER'S OWN BOUND, not by the
;           extent: `cp IY,0x0029 / jrl UGT,0xF379A3` at 0xF375FA admits
;           indices 0..41, and 42 x 4 = 168 bytes, which is exactly this
;           segment.  Every word is re-read on each emit and asserted to land
;           inside 0xF353AB-0xF3934C.
; Unknown: WHICH parameter each index is.  Nothing in this span names one, so
;          the table keeps a FRAMED name and not one arm is given a
;          parameter's name.  ★ The ROWS are the evidence a later lane will
;          match names to: entry [i]'s arm carries that parameter's legal
;          range as two immediates.
; --------------------------------------------------------------------------
ParamRangeArms_F3760E:
	.long	ClampArm408_0To127_MaskFFFF	; F3760E  [0] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_0To127_MaskFFFF	; F37612  [1] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_0To127_MaskFFFF	; F37616  [2] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_0To127_MaskFFFF	; F3761A  [3] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3761E  [4] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To127_MaskFFFF	; F37622  [5] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37626  [6] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To127_MaskFFFF	; F3762A  [7] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3762E  [8] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To127_MaskFFFF	; F37632  [9] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37636  [10] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To63_Mask3F	; F3763A  [11] -> ClampArm408_0To63_Mask3F
	.long	ClampArm408_0To63_MaskFFFF	; F3763E  [12] -> ClampArm408_0To63_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37642  [13] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F37646  [14] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F3764A  [15] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_M50To50_MaskFFFF	; F3764E  [16] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampArm408_0To50_MaskFFFF	; F37652  [17] -> ClampArm408_0To50_MaskFFFF
	.long	ClampArm408_0To50_Mask7F	; F37656  [18] -> ClampArm408_0To50_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F3765A  [19] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_0To127_MaskFFFF	; F3765E  [20] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37662  [21] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_M50To50_MaskFFFF	; F37666  [22] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampArm408_M50To50_MaskFFFF	; F3766A  [23] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3766E  [24] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F37672  [25] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To127_MaskFFFF	; F37676  [26] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_0To127_MaskFFFF	; F3767A  [27] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_M50To50_MaskFFFF	; F3767E  [28] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampArm408_M60To60_MaskFFFF	; F37682  [29] -> ClampArm408_M60To60_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37686  [30] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F3768A  [31] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_M50To50_MaskFFFF	; F3768E  [32] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37692  [33] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_M50To50_MaskFFFF	; F37696  [34] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3769A  [35] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_M50To50_MaskFFFF	; F3769E  [36] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F376A2  [37] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To127_MaskFFFF	; F376A6  [38] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_0To127_MaskFFFF	; F376AA  [39] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_M50To50_MaskFFFF	; F376AE  [40] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampArm408_M60To60_MaskFFFF	; F376B2  [41] -> ClampArm408_M60To60_MaskFFFF


; --------------------------------------------------------------------------
; ClampArm408_0To63_Mask3F
; Called from: arm table 0xF3760E[11]
; Touches: nothing with an absolute address
; Evidence: entry [11] of the arm table at 0xF3760E reads 0x00F376B6, that
;           table's indexer ends `jp (Xrr)`, and 0xF376B6 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_0To63_Mask3F: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0x3F, shift 0, max 63, min 0), a signed
;   clamp of the masked field to 0..63 (notes/prom_b_param_range_arm_names.py).
ClampArm408_0To63_Mask3F:
	pushw	0	; F376B6  push 0x0000
	pushw	63	; F376B9  push 0x003f
	pushw	0	; F376BC  push 0x0000
	pushw	63	; F376BF  push 0x003f
	jrl	ClampArm408_0To127_MaskFFFF_Join2	; F376C2  jrl T,0xf37995

; --------------------------------------------------------------------------
; ClampArm408_0To63_MaskFFFF
; Called from: arm table 0xF3760E[12]
; Touches: nothing with an absolute address
; Evidence: entry [12] of the arm table at 0xF3760E reads 0x00F376C5, that
;           table's indexer ends `jp (Xrr)`, and 0xF376C5 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_0To63_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 63, min 0), a signed
;   clamp of the masked field to 0..63 (notes/prom_b_param_range_arm_names.py).
ClampArm408_0To63_MaskFFFF:
	pushw	0	; F376C5  push 0x0000
	pushw	63	; F376C8  push 0x003f
	jrl	ClampArm408_0To127_MaskFFFF_Join	; F376CB  jrl T,0xf3798f

; --------------------------------------------------------------------------
; ClampArm408_0To50_Mask7F
; Called from: arm table 0xF3760E[18]
; Touches: nothing with an absolute address
; Evidence: entry [18] of the arm table at 0xF3760E reads 0x00F376CE, that
;           table's indexer ends `jp (Xrr)`, and 0xF376CE is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_0To50_Mask7F: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0x7F, shift 0, max 50, min 0), a signed
;   clamp of the masked field to 0..50 (notes/prom_b_param_range_arm_names.py).
ClampArm408_0To50_Mask7F:
	pushw	0	; F376CE  push 0x0000
	pushw	50	; F376D1  push 0x0032
	jrl	ClampArm408_0To49_Mask7F_Join	; F376D4  jrl T,0xf37981

; --------------------------------------------------------------------------
; ClampArm408_M60To60_MaskFFFF
; Called from: arm table 0xF3760E[29], 0xF3760E[41]
; Touches: nothing with an absolute address
; Evidence: entry [29] of the arm table at 0xF3760E reads 0x00F376D7, that
;           table's indexer ends `jp (Xrr)`, and 0xF376D7 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_M60To60_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 60, min -60), a signed
;   clamp of the masked field to -60..60 (notes/prom_b_param_range_arm_names.py).
ClampArm408_M60To60_MaskFFFF:
	pushw	65476	; F376D7  push 0xffc4
	pushw	60	; F376DA  push 0x003c
	jrl	ClampArm408_0To127_MaskFFFF_Join	; F376DD  jrl T,0xf3798f
ClampArm408_M60To60_MaskFFFF_Skip:
	ld	bc, hl	; F376E0  ld BC,HL
	extz	xbc	; F376E2  extz XBC
	add	xbc, 408	; F376E4  add XBC,0x00000198
	ld	xwa, (xiz-4)	; F376EA  ld XWA,(XIZ+0xfc)
	sub	xwa, xbc	; F376ED  sub XWA,XBC
	extz	xwa	; F376EF  extz XWA
	cp	wa, 59	; F376F1  cp WA,0x003b
	jrl	ugt, ClampParamValueById_Unchanged2	; F376F5  jrl UGT,0xf379a3
	sll	wa, 2	; F376F8  sll 0x02,WA
	add	xwa, ParamRangeArms_F37705	; F376FB  add XWA,0x00f37705
	ld	xwa, (xwa)	; F37701  ld XWA,(XWA)
	jp	(xwa)	; F37703  jp T,XWA

; --------------------------------------------------------------------------
; ParamRangeArms_F37705 -- 60 32-bit entries, all inside this block
;                          (0xF377F5-0xF379A3), naming 7 distinct arms.  Each
;                          arm is one or two `push imm16` instructions -- that
;                          parameter's MINIMUM and MAXIMUM -- and a jump to a
;                          shared tail that pushes the mask and the shift and
;                          calls ClampFieldToRange.
; Read by: 0xF376FB, `sll 0x02,WA / add XWA,0x00F37705 / ld XWA,(XWA) / jp
;          (XWA)`, with the index bounded by the `cp WA,0x003B / jrl
;          UGT,0xF379A3` at 0xF376F1 immediately above it.
; Evidence: the ENTRY COUNT IS PROVED BY THE INDEXER'S OWN BOUND, not by the
;           extent: `cp WA,0x003B / jrl UGT,0xF379A3` at 0xF376F1 admits
;           indices 0..59, and 60 x 4 = 240 bytes, which is exactly this
;           segment.  Every word is re-read on each emit and asserted to land
;           inside 0xF353AB-0xF3934C.
; Unknown: WHICH parameter each index is.  Nothing in this span names one, so
;          the table keeps a FRAMED name and not one arm is given a
;          parameter's name.  ★ The ROWS are the evidence a later lane will
;          match names to: entry [i]'s arm carries that parameter's legal
;          range as two immediates.
; --------------------------------------------------------------------------
ParamRangeArms_F37705:
	.long	ClampArm408_32To127_MaskFFFF	; F37705  [0] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37709  [1] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3770D  [2] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37711  [3] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37715  [4] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37719  [5] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3771D  [6] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37721  [7] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37725  [8] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37729  [9] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3772D  [10] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37731  [11] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37735  [12] -> ClampArm408_32To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37739  [13] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F3773D  [14] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F37741  [15] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To127_MaskFFFF	; F37745  [16] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_0To127_MaskFFFF	; F37749  [17] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_0To50_MaskFFFF	; F3774D  [18] -> ClampArm408_0To50_MaskFFFF
	.long	ClampArm408_0To128_MaskFFFF	; F37751  [19] -> ClampArm408_0To128_MaskFFFF
	.long	ClampArm408_0To127_MaskFFFF	; F37755  [20] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37759  [21] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_M50To50_MaskFFFF	; F3775D  [22] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37761  [23] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To127_MaskFFFF	; F37765  [24] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_M50To50_MaskFFFF	; F37769  [25] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3776D  [26] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To100_MaskFFFF	; F37771  [27] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F37775  [28] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F37779  [29] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F3777D  [30] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F37781  [31] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F37785  [32] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_M50To50_MaskFFFF	; F37789  [33] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampArm408_M50To50_MaskFFFF	; F3778D  [34] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37791  [35] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To50_MaskFFFF	; F37795  [36] -> ClampArm408_0To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37799  [37] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F3779D  [38] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F377A1  [39] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F377A5  [40] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To50_MaskFFFF	; F377A9  [41] -> ClampArm408_0To50_MaskFFFF
	.long	ClampArm408_0To128_MaskFFFF	; F377AD  [42] -> ClampArm408_0To128_MaskFFFF
	.long	ClampArm408_0To127_MaskFFFF	; F377B1  [43] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F377B5  [44] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_M50To50_MaskFFFF	; F377B9  [45] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F377BD  [46] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To127_MaskFFFF	; F377C1  [47] -> ClampArm408_0To127_MaskFFFF
	.long	ClampArm408_M50To50_MaskFFFF	; F377C5  [48] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F377C9  [49] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To100_MaskFFFF	; F377CD  [50] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F377D1  [51] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F377D5  [52] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F377D9  [53] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F377DD  [54] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_0To100_MaskFFFF	; F377E1  [55] -> ClampArm408_0To100_MaskFFFF
	.long	ClampArm408_M50To50_MaskFFFF	; F377E5  [56] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampArm408_M50To50_MaskFFFF	; F377E9  [57] -> ClampArm408_M50To50_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F377ED  [58] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To50_MaskFFFF	; F377F1  [59] -> ClampArm408_0To50_MaskFFFF


; --------------------------------------------------------------------------
; ClampArm408_0To50_MaskFFFF
; Called from: arm table 0xF3760E[17], 0xF37705[18], 0xF37705[36],
;              0xF37705[41], 0xF37705[59]
; Touches: nothing with an absolute address
; Evidence: entry [17] of the arm table at 0xF3760E reads 0x00F377F5, that
;           table's indexer ends `jp (Xrr)`, and 0xF377F5 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_0To50_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 50, min 0), a signed
;   clamp of the masked field to 0..50 (notes/prom_b_param_range_arm_names.py).
ClampArm408_0To50_MaskFFFF:
	pushw	0	; F377F5  push 0x0000
	jr	ClampArm408_M50To50_MaskFFFF_Skip	; F377F8  jr T,0xf37806

; --------------------------------------------------------------------------
; ClampArm408_0To128_MaskFFFF
; Called from: arm table 0xF37705[19], 0xF37705[42]
; Touches: nothing with an absolute address
; Evidence: entry [19] of the arm table at 0xF37705 reads 0x00F377FA, that
;           table's indexer ends `jp (Xrr)`, and 0xF377FA is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_0To128_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 128, min 0), a signed
;   clamp of the masked field to 0..128 (notes/prom_b_param_range_arm_names.py).
ClampArm408_0To128_MaskFFFF:
	pushw	0	; F377FA  push 0x0000
	pushw	128	; F377FD  push 0x0080
	jrl	ClampArm408_0To127_MaskFFFF_Join	; F37800  jrl T,0xf3798f

; --------------------------------------------------------------------------
; ClampArm408_M50To50_MaskFFFF
; Called from: arm table 0xF3760E[16], 0xF3760E[22], 0xF3760E[23],
;              0xF3760E[28], 0xF3760E[32], 0xF3760E[34] +10 more
; Touches: nothing with an absolute address
; Evidence: entry [16] of the arm table at 0xF3760E reads 0x00F37803, that
;           table's indexer ends `jp (Xrr)`, and 0xF37803 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_M50To50_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 50, min -50), a signed
;   clamp of the masked field to -50..50 (notes/prom_b_param_range_arm_names.py).
ClampArm408_M50To50_MaskFFFF:
	pushw	65486	; F37803  push 0xffce
ClampArm408_M50To50_MaskFFFF_Skip:
	pushw	50	; F37806  push 0x0032
	jrl	ClampArm408_0To127_MaskFFFF_Join	; F37809  jrl T,0xf3798f

; --------------------------------------------------------------------------
; ClampArm408_0To100_MaskFFFF
; Called from: arm table 0xF37705[27], 0xF37705[28], 0xF37705[29],
;              0xF37705[30], 0xF37705[31], 0xF37705[32] +6 more
; Touches: nothing with an absolute address
; Evidence: entry [27] of the arm table at 0xF37705 reads 0x00F3780C, that
;           table's indexer ends `jp (Xrr)`, and 0xF3780C is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_0To100_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 100, min 0), a signed
;   clamp of the masked field to 0..100 (notes/prom_b_param_range_arm_names.py).
ClampArm408_0To100_MaskFFFF:
	pushw	0	; F3780C  push 0x0000
	pushw	100	; F3780F  push 0x0064
	jrl	ClampArm408_0To127_MaskFFFF_Join	; F37812  jrl T,0xf3798f
ClampArm408_0To100_MaskFFFF_Skip:
	ld	bc, (xiz+8)	; F37815  ld BC,(XIZ+0x08)
	extz	xbc	; F37818  extz XBC
	cp	bc, 81	; F3781A  cp BC,0x0051
	jrl	ugt, ClampParamValueById_Unchanged2	; F3781E  jrl UGT,0xf379a3
	sll	bc, 2	; F37821  sll 0x02,BC
	add	xbc, ParamRangeArms_F3782E	; F37824  add XBC,0x00f3782e
	ld	xbc, (xbc)	; F3782A  ld XBC,(XBC)
	jp	(xbc)	; F3782C  jp T,XBC

; --------------------------------------------------------------------------
; ParamRangeArms_F3782E -- 82 32-bit entries, all inside this block
;                          (0xF37976-0xF379A3), naming 4 distinct arms.  Each
;                          arm is one or two `push imm16` instructions -- that
;                          parameter's MINIMUM and MAXIMUM -- and a jump to a
;                          shared tail that pushes the mask and the shift and
;                          calls ClampFieldToRange.
; Read by: 0xF37824, `sll 0x02,BC / add XBC,0x00F3782E / ld XBC,(XBC) / jp
;          (XBC)`, with the index bounded by the `cp BC,0x0051 / jrl
;          UGT,0xF379A3` at 0xF3781A immediately above it.
; Evidence: the ENTRY COUNT IS PROVED BY THE INDEXER'S OWN BOUND, not by the
;           extent: `cp BC,0x0051 / jrl UGT,0xF379A3` at 0xF3781A admits
;           indices 0..81, and 82 x 4 = 328 bytes, which is exactly this
;           segment.  Every word is re-read on each emit and asserted to land
;           inside 0xF353AB-0xF3934C.
; Unknown: WHICH parameter each index is.  Nothing in this span names one, so
;          the table keeps a FRAMED name and not one arm is given a
;          parameter's name.  ★ The ROWS are the evidence a later lane will
;          match names to: entry [i]'s arm carries that parameter's legal
;          range as two immediates.
; --------------------------------------------------------------------------
ParamRangeArms_F3782E:
	.long	ClampArm408_32To127_MaskFFFF	; F3782E  [0] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37832  [1] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37836  [2] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3783A  [3] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3783E  [4] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37842  [5] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37846  [6] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3784A  [7] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3784E  [8] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37852  [9] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37856  [10] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3785A  [11] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3785E  [12] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37862  [13] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F37866  [14] -> ClampArm408_32To127_MaskFFFF
	.long	ClampArm408_32To127_MaskFFFF	; F3786A  [15] -> ClampArm408_32To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3786E  [16] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F37872  [17] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F37876  [18] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F3787A  [19] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3787E  [20] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F37882  [21] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F37886  [22] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3788A  [23] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F3788E  [24] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F37892  [25] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37896  [26] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F3789A  [27] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F3789E  [28] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F378A2  [29] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F378A6  [30] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F378AA  [31] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F378AE  [32] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F378B2  [33] -> ClampParamValueById_Unchanged2
	.long	ClampParamValueById_Unchanged2	; F378B6  [34] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F378BA  [35] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F378BE  [36] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F378C2  [37] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F378C6  [38] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F378CA  [39] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F378CE  [40] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F378D2  [41] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F378D6  [42] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F378DA  [43] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F378DE  [44] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F378E2  [45] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F378E6  [46] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F378EA  [47] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F378EE  [48] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F378F2  [49] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F378F6  [50] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F378FA  [51] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F378FE  [52] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F37902  [53] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F37906  [54] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3790A  [55] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F3790E  [56] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F37912  [57] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37916  [58] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F3791A  [59] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F3791E  [60] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37922  [61] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F37926  [62] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F3792A  [63] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3792E  [64] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F37932  [65] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F37936  [66] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3793A  [67] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F3793E  [68] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F37942  [69] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37946  [70] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F3794A  [71] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F3794E  [72] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F37952  [73] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F37956  [74] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F3795A  [75] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3795E  [76] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F37962  [77] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F37966  [78] -> ClampArm408_0To127_MaskFFFF
	.long	ClampParamValueById_Unchanged2	; F3796A  [79] -> ClampParamValueById_Unchanged2
	.long	ClampArm408_0To49_Mask7F	; F3796E  [80] -> ClampArm408_0To49_Mask7F
	.long	ClampArm408_0To127_MaskFFFF	; F37972  [81] -> ClampArm408_0To127_MaskFFFF


; --------------------------------------------------------------------------
; ClampArm408_32To127_MaskFFFF
; Called from: arm table 0xF37705[0], 0xF37705[1], 0xF37705[2], 0xF37705[3],
;              0xF37705[4], 0xF37705[5] +23 more
; Touches: nothing with an absolute address
; Evidence: entry [0] of the arm table at 0xF37705 reads 0x00F37976, that
;           table's indexer ends `jp (Xrr)`, and 0xF37976 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_32To127_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 127, min 32), a signed
;   clamp of the masked field to 32..127 (notes/prom_b_param_range_arm_names.py).
ClampArm408_32To127_MaskFFFF:
	pushw	32	; F37976  push 0x0020
	jr	ClampArm408_0To127_MaskFFFF_Skip	; F37979  jr T,0xf3798c

; --------------------------------------------------------------------------
; ClampArm408_0To49_Mask7F
; Called from: arm table 0xF3782E[18], 0xF3782E[21], 0xF3782E[24],
;              0xF3782E[27], 0xF3782E[30], 0xF3782E[35] +15 more
; Touches: nothing with an absolute address
; Evidence: entry [18] of the arm table at 0xF3782E reads 0x00F3797B, that
;           table's indexer ends `jp (Xrr)`, and 0xF3797B is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_0To49_Mask7F: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0x7F, shift 0, max 49, min 0), a signed
;   clamp of the masked field to 0..49 (notes/prom_b_param_range_arm_names.py).
ClampArm408_0To49_Mask7F:
	pushw	0	; F3797B  push 0x0000
	pushw	49	; F3797E  push 0x0031
ClampArm408_0To49_Mask7F_Join:
	pushw	0	; F37981  push 0x0000
	pushw	127	; F37984  push 0x007f
	jr	ClampArm408_0To127_MaskFFFF_Join2	; F37987  jr T,0xf37995

; --------------------------------------------------------------------------
; ClampArm408_0To127_MaskFFFF
; Called from: arm table 0xF3760E[0], 0xF3760E[1], 0xF3760E[2], 0xF3760E[3],
;              0xF3760E[5], 0xF3760E[7] +34 more
; Touches: nothing with an absolute address
; Calls:   ClampFieldToRange
; Evidence: entry [0] of the arm table at 0xF3760E reads 0x00F37989, that
;           table's indexer ends `jp (Xrr)`, and 0xF37989 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampArm408_0To127_MaskFFFF: a ParamRangeArms arm -- ClampFieldToRange(value, mask 0xFFFF, shift 0, max 127, min 0), a signed
;   clamp of the masked field to 0..127 (notes/prom_b_param_range_arm_names.py).
ClampArm408_0To127_MaskFFFF:
	pushw	0	; F37989  push 0x0000
ClampArm408_0To127_MaskFFFF_Skip:
	pushw	127	; F3798C  push 0x007f
ClampArm408_0To127_MaskFFFF_Join:
	pushw	0	; F3798F  push 0x0000
	pushw	65535	; F37992  push 0xffff
ClampArm408_0To127_MaskFFFF_Join2:
	ld	c, d	; F37995  ld C,D
	exts	bc	; F37997  exts BC
	pushw	bc	; F37999  push BC
	calr	ClampFieldToRange	; F3799A  calr 0xf3702f
	ld	d, a	; F3799D  ld D,A
	inc	8, xsp	; F3799F  inc 0,XSP
	inc	2, xsp	; F379A1  inc 2,XSP

; --------------------------------------------------------------------------
; ClampParamValueById_Unchanged2
; Called from: arm table 0xF3760E[4], 0xF3760E[6], 0xF3760E[8], 0xF3760E[10],
;              0xF3760E[13], 0xF3760E[14] +48 more
; Touches: nothing with an absolute address
; Evidence: entry [4] of the arm table at 0xF3760E reads 0x00F379A3, that
;           table's indexer ends `jp (Xrr)`, and 0xF379A3 is an instruction
;           boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ClampParamValueById_Unchanged2: the out-of-range exit of a ParamRangeArms table -- returns the value unclamped
;   (notes/prom_b_param_range_arm_names.py).
ClampParamValueById_Unchanged2:
	ld	a, d	; F379A3  ld A,D
	pop	xix	; F379A5  pop XIX
	popw	de	; F379A6  pop DE
	popw	hl	; F379A7  pop HL
	unlk XIZ	; F379A8  unlk XIZ
	ret	; F379AA  ret

; --------------------------------------------------------------------------
; SysExToneImage_WriteByte
; Called from: T_SysExToneImage_WriteByte (x1); far site 0xF41258
; Touches: nothing with an absolute address
; Calls:   Pack3x7BitFields_Bytes9To11 Pack3x7BitFields_Bytes6To8
;          ClampParamValueById_From541 T_ToneMsg_SendParam ClampParamValueById_From408
;          Divide32_Unsigned_Quotient T_ToneMsg88_Id13 T_DspParam_WriteByNumber T_ToneMsg8D_SendParam
; Evidence: thunk slot T_SysExToneImage_WriteByte holds `jp 0x00F379AB`, and 0xF379AB is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExToneImage_WriteByte: SysEx command 0x17 (2C write) into the live tone-edit image: address 0x040000 + n (melodic
;   sound, n < 713) or 0x060000 + n (drum kit, n <= 19608), count must be 1, value (msg[12] << 4) | (msg[13] & 0x0F)
;   clamped per parameter; a ladder of offsets turns n into (block, index) and commits through ToneMsg_SendParam /
;   ToneMsg8D_SendParam / DspParam_WriteByNumber, as the panel's tone editor does. Basis: caller + body + notes/sysex-
;   probes/sysex_third_region.py. (notes/naming-pilot-2026-10-06/proposals_wave3_i.json)
SysExToneImage_WriteByte:		; <- T_SysExToneImage_WriteByte
	link XIZ,0xffe8	; F379AB  link XIZ,0xffe8
	pushw	hl	; F379AF  push HL
	push	xix	; F379B0  push XIX
	ld	xbc, (xiz+8)	; F379B1  ld XBC,(XIZ+0x08)
	push	xbc	; F379B4  push XBC
	calr	Pack3x7BitFields_Bytes9To11	; F379B5  calr 0xf36800
	ld	(2567:24), wa	; F379B8  ld (0x000a07),WA
	ld	xbc, (xiz+8)	; F379BD  ld XBC,(XIZ+0x08)
	push	xbc	; F379C0  push XBC
	calr	Pack3x7BitFields_Bytes6To8	; F379C1  calr 0xf36849
	ld	(2563:24), xiy	; F379C4  ld (0x000a03),XIY
	inc	8, xsp	; F379C9  inc 0,XSP
	cpw	(0x000a07:24), 0x0001	; F379CB  cp (0x000a07),0x0001
	jrl	nz, SysExToneImage_WriteByte_Skip18	; F379D2  jrl NZ,0xf37d0f
	or	xiy, xiy	; F379D5  or XIY,XIY
	jrl	z, SysExToneImage_WriteByte_Skip18	; F379D7  jrl Z,0xf37d0f
	cp	xiy, 393216	; F379DA  cp XIY,0x00060000
	jrl	ge, SysExToneImage_WriteByte_Skip12	; F379E0  jrl GE,0xf37ba4
	sub	xiy, 262144	; F379E3  sub XIY,0x00040000
	ld	(xiz-20), xiy	; F379E9  ld (XIZ+0xec),XIY
	ld	xix, xiy	; F379EC  ld XIX,XIY
	cp	xiy, 713	; F379EE  cp XIY,0x000002c9
	jrl	ugt, SysExToneImage_WriteByte_Skip18	; F379F4  jrl UGT,0xf37d0f
	ld	xbc, (xiz+8)	; F379F7  ld XBC,(XIZ+0x08)
	ld	a, (xbc+13)	; F379FA  ld A,(XBC+0x0d)
	ld	h, a	; F379FD  ld H,A
	and	h, 15	; F379FF  and H,0x0f
	ld	a, (xbc+12)	; F37A02  ld A,(XBC+0x0c)
	sll	a, 4	; F37A05  sll 0x04,A
	or	a, h	; F37A08  or A,H
	pushw	wa	; F37A0A  push WA
	ld	xwa, (xiz-20)	; F37A0B  ld XWA,(XIZ+0xec)
	push	xwa	; F37A0E  push XWA
	calr	ClampParamValueById_From541	; F37A0F  calr 0xf37069
	ld	(2562:24), a	; F37A12  ld (0x000a02),A
	inc	6, xsp	; F37A17  inc 6,XSP
	cp	xix, 670	; F37A19  cp XIX,0x0000029e
	jr	c, SysExToneImage_WriteByte_Skip	; F37A1F  jr C,0xf37a3a
	pushw	255	; F37A21  push 0x00ff
	lda	xbc, (2562:24)	; F37A24  lda XBC,0x000a02
	push	xbc	; F37A29  push XBC
	ld	xwa, (xiz-20)	; F37A2A  ld XWA,(XIZ+0xec)
	sub	xwa, 670	; F37A2D  sub XWA,0x0000029e
	pushw	wa	; F37A33  push WA
	pushw	65	; F37A34  push 0x0041
	jrl	SysExToneImage_WriteByte_Join	; F37A37  jrl T,0xf37b9d
SysExToneImage_WriteByte_Skip:
	ld	xix, (xiz-20)	; F37A3A  ld XIX,(XIZ+0xec)
	cp	xix, 627	; F37A3D  cp XIX,0x00000273
	jr	c, SysExToneImage_WriteByte_Skip2	; F37A43  jr C,0xf37a5d
	pushw	255	; F37A45  push 0x00ff
	lda	xbc, (2562:24)	; F37A48  lda XBC,0x000a02
	push	xbc	; F37A4D  push XBC
	ld	xwa, xix	; F37A4E  ld XWA,XIX
	sub	xwa, 627	; F37A50  sub XWA,0x00000273
	pushw	wa	; F37A56  push WA
	pushw	49	; F37A57  push 0x0031
	jrl	SysExToneImage_WriteByte_Join	; F37A5A  jrl T,0xf37b9d
SysExToneImage_WriteByte_Skip2:
	cp	xix, 584	; F37A5D  cp XIX,0x00000248
	jr	c, SysExToneImage_WriteByte_Skip3	; F37A63  jr C,0xf37a7d
	pushw	255	; F37A65  push 0x00ff
	lda	xbc, (2562:24)	; F37A68  lda XBC,0x000a02
	push	xbc	; F37A6D  push XBC
	ld	xwa, xix	; F37A6E  ld XWA,XIX
	sub	xwa, 584	; F37A70  sub XWA,0x00000248
	pushw	wa	; F37A76  push WA
	pushw	33	; F37A77  push 0x0021
	jrl	SysExToneImage_WriteByte_Join	; F37A7A  jrl T,0xf37b9d
SysExToneImage_WriteByte_Skip3:
	cp	xix, 541	; F37A7D  cp XIX,0x0000021d
	jr	c, SysExToneImage_WriteByte_Skip4	; F37A83  jr C,0xf37a9d
	pushw	255	; F37A85  push 0x00ff
	lda	xbc, (2562:24)	; F37A88  lda XBC,0x000a02
	push	xbc	; F37A8D  push XBC
	ld	xwa, xix	; F37A8E  ld XWA,XIX
	sub	xwa, 541	; F37A90  sub XWA,0x0000021d
	pushw	wa	; F37A96  push WA
	pushw	17	; F37A97  push 0x0011
	jrl	SysExToneImage_WriteByte_Join	; F37A9A  jrl T,0xf37b9d
SysExToneImage_WriteByte_Skip4:
	cp	xix, 460	; F37A9D  cp XIX,0x000001cc
	jr	c, SysExToneImage_WriteByte_Skip5	; F37AA3  jr C,0xf37abd
	pushw	255	; F37AA5  push 0x00ff
	lda	xbc, (2562:24)	; F37AA8  lda XBC,0x000a02
	push	xbc	; F37AAD  push XBC
	ld	xwa, xix	; F37AAE  ld XWA,XIX
	sub	xwa, 460	; F37AB0  sub XWA,0x000001cc
	pushw	wa	; F37AB6  push WA
	pushw	4	; F37AB7  push 0x0004
	jrl	SysExToneImage_WriteByte_Join	; F37ABA  jrl T,0xf37b9d
SysExToneImage_WriteByte_Skip5:
	cp	xix, 379	; F37ABD  cp XIX,0x0000017b
	jr	c, SysExToneImage_WriteByte_Skip6	; F37AC3  jr C,0xf37add
	pushw	255	; F37AC5  push 0x00ff
	lda	xbc, (2562:24)	; F37AC8  lda XBC,0x000a02
	push	xbc	; F37ACD  push XBC
	ld	xwa, xix	; F37ACE  ld XWA,XIX
	sub	xwa, 379	; F37AD0  sub XWA,0x0000017b
	pushw	wa	; F37AD6  push WA
	pushw	3	; F37AD7  push 0x0003
	jrl	SysExToneImage_WriteByte_Join	; F37ADA  jrl T,0xf37b9d
SysExToneImage_WriteByte_Skip6:
	cp	xix, 298	; F37ADD  cp XIX,0x0000012a
	jr	c, SysExToneImage_WriteByte_Skip7	; F37AE3  jr C,0xf37afd
	pushw	255	; F37AE5  push 0x00ff
	lda	xbc, (2562:24)	; F37AE8  lda XBC,0x000a02
	push	xbc	; F37AED  push XBC
	ld	xwa, xix	; F37AEE  ld XWA,XIX
	sub	xwa, 298	; F37AF0  sub XWA,0x0000012a
	pushw	wa	; F37AF6  push WA
	pushw	2	; F37AF7  push 0x0002
	jrl	SysExToneImage_WriteByte_Join	; F37AFA  jrl T,0xf37b9d
SysExToneImage_WriteByte_Skip7:
	cp	xix, 217	; F37AFD  cp XIX,0x000000d9
	jr	c, SysExToneImage_WriteByte_Skip8	; F37B03  jr C,0xf37b1d
	pushw	255	; F37B05  push 0x00ff
	lda	xbc, (2562:24)	; F37B08  lda XBC,0x000a02
	push	xbc	; F37B0D  push XBC
	ld	xwa, xix	; F37B0E  ld XWA,XIX
	sub	xwa, 217	; F37B10  sub XWA,0x000000d9
	pushw	wa	; F37B16  push WA
	pushw	1	; F37B17  push 0x0001
	jrl	SysExToneImage_WriteByte_Join	; F37B1A  jrl T,0xf37b9d
SysExToneImage_WriteByte_Skip8:
	cp	xix, 135	; F37B1D  cp XIX,0x00000087
	jr	c, SysExToneImage_WriteByte_Skip9	; F37B23  jr C,0xf37b46
	cp	xix, 138	; F37B25  cp XIX,0x0000008a
	jr	nc, SysExToneImage_WriteByte_Skip9	; F37B2B  jr NC,0xf37b46
	push	0	; F37B2D  push 0x00
	push	(0x000a02:24)	; F37B2F  push (0x000a02)
	ld	xbc, xix	; F37B34  ld XBC,XIX
	sub	xbc, 135	; F37B36  sub XBC,0x00000087
	add	xbc, 70	; F37B3C  add XBC,0x00000046
	pushw	bc	; F37B42  push BC
	jrl	SysExToneImage_WriteByte_Join2	; F37B43  jrl T,0xf37cec
SysExToneImage_WriteByte_Skip9:
	ld	xix, (xiz-20)	; F37B46  ld XIX,(XIZ+0xec)
	cp	xix, 138	; F37B49  cp XIX,0x0000008a
	jr	nz, SysExToneImage_WriteByte_Skip10	; F37B4F  jr NZ,0xf37b6a
	push	0	; F37B51  push 0x00
	push	(0x000a02:24)	; F37B53  push (0x000a02)
	ld	xbc, xix	; F37B58  ld XBC,XIX
	sub	xbc, 138	; F37B5A  sub XBC,0x0000008a
	add	xbc, 69	; F37B60  add XBC,0x00000045
	pushw	bc	; F37B66  push BC
	jrl	SysExToneImage_WriteByte_Join2	; F37B67  jrl T,0xf37cec
SysExToneImage_WriteByte_Skip10:
	cp	xix, 139	; F37B6A  cp XIX,0x0000008b
	jr	c, SysExToneImage_WriteByte_Skip11	; F37B70  jr C,0xf37b8d
	cp	xix, 207	; F37B72  cp XIX,0x000000cf
	jr	ugt, SysExToneImage_WriteByte_Skip11	; F37B78  jr UGT,0xf37b8d
	push	0	; F37B7A  push 0x00
	push	(0x000a02:24)	; F37B7C  push (0x000a02)
	ld	xbc, xix	; F37B81  ld XBC,XIX
	sub	xbc, 139	; F37B83  sub XBC,0x0000008b
	pushw	bc	; F37B89  push BC
	jrl	SysExToneImage_WriteByte_Join2	; F37B8A  jrl T,0xf37cec
SysExToneImage_WriteByte_Skip11:
	pushw	255	; F37B8D  push 0x00ff
	lda	xbc, (2562:24)	; F37B90  lda XBC,0x000a02
	push	xbc	; F37B95  push XBC
	ld	a, (xiz-20)	; F37B96  ld A,(XIZ+0xec)
	pushw	wa	; F37B99  push WA
	pushw	0	; F37B9A  push 0x0000
SysExToneImage_WriteByte_Join:
	call	T_ToneMsg_SendParam	; F37B9D  call 0xf43470
	jrl	SysExToneImage_WriteByte_Join4	; F37BA1  jrl T,0xf37d07
SysExToneImage_WriteByte_Skip12:
	ld	xbc, (2563:24)	; F37BA4  ld XBC,(0x000a03)
	sub	xbc, 393216	; F37BA9  sub XBC,0x00060000
	ld	(xiz-20), xbc	; F37BAF  ld (XIZ+0xec),XBC
	ld	xix, xbc	; F37BB2  ld XIX,XBC
	cp	xbc, 19608	; F37BB4  cp XBC,0x00004c98
	jrl	ugt, SysExToneImage_WriteByte_Skip18	; F37BBA  jrl UGT,0xf37d0f
	ld	xwa, (xiz+8)	; F37BBD  ld XWA,(XIZ+0x08)
	ld	c, (xwa+13)	; F37BC0  ld C,(XWA+0x0d)
	ld	h, c	; F37BC3  ld H,C
	and	h, 15	; F37BC5  and H,0x0f
	ld	c, (xwa+12)	; F37BC8  ld C,(XWA+0x0c)
	sll	c, 4	; F37BCB  sll 0x04,C
	or	c, h	; F37BCE  or C,H
	pushw	bc	; F37BD0  push BC
	ld	xbc, (xiz-20)	; F37BD1  ld XBC,(XIZ+0xec)
	push	xbc	; F37BD4  push XBC
	calr	ClampParamValueById_From408	; F37BD5  calr 0xf37594
	ld	(2562:24), a	; F37BD8  ld (0x000a02),A
	inc	6, xsp	; F37BDD  inc 6,XSP
	cp	xix, 408	; F37BDF  cp XIX,0x00000198
	jrl	c, SysExToneImage_WriteByte_Skip15	; F37BE5  jrl C,0xf37ca9
	ld	xix, (xiz-20)	; F37BE8  ld XIX,(XIZ+0xec)
	ld	xbc, xix	; F37BEB  ld XBC,XIX
	sub	xbc, 408	; F37BED  sub XBC,0x00000198
	pushw	0	; F37BF3  push 0x0000
	pushw	150	; F37BF6  push 0x0096
	push	xbc	; F37BF9  push XBC
	call	Divide32_Unsigned_Quotient	; F37BFA  call 0xf37f3a
	ldto_berp	h, 0xf4	; F37BFE  ld H,IYL
	push	0	; F37C01  push 0x00
	push	h	; F37C03  push H
	call	T_ToneMsg88_Id13	; F37C05  call 0xf43488
	sub	xbc, xbc	; F37C09  sub XBC,XBC
	ld	(xiz-24), xbc	; F37C0B  ld (XIZ+0xe8),XBC
	ld	a, 150:opc	; F37C0E  ld A,0x96
	mul	wa, h	; F37C10  mul WA,H
	extz	xwa	; F37C12  extz XWA
	ld	(xiz-16), xwa	; F37C14  ld (XIZ+0xf0),XWA
	add	xwa, 515	; F37C17  add XWA,0x00000203
	ld	(xiz-12), xwa	; F37C1D  ld (XIZ+0xf4),XWA
	add	xbc, xwa	; F37C20  add XBC,XWA
	extz	xbc	; F37C22  extz XBC
	popw	iy	; F37C24  pop IY
	cp	xbc, xix	; F37C25  cp XBC,XIX
	jr	ugt, SysExToneImage_WriteByte_Skip13	; F37C27  jr UGT,0xf37c43
	pushw	255	; F37C29  push 0x00ff
	lda	xbc, (2562:24)	; F37C2C  lda XBC,0x000a02
	push	xbc	; F37C31  push XBC
	sub	xiy, xiy	; F37C32  sub XIY,XIY
	add	xiy, xwa	; F37C34  add XIY,XWA
	extz	xiy	; F37C36  extz XIY
	ld	xbc, xix	; F37C38  ld XBC,XIX
	sub	xbc, xiy	; F37C3A  sub XBC,XIY
	pushw	bc	; F37C3C  push BC
	pushw	2	; F37C3D  push 0x0002
	jrl	SysExToneImage_WriteByte_Join3	; F37C40  jrl T,0xf37d03
SysExToneImage_WriteByte_Skip13:
	sub	xbc, xbc	; F37C43  sub XBC,XBC
	ld	(xiz-24), xbc	; F37C45  ld (XIZ+0xe8),XBC
	ld	xwa, (xiz-16)	; F37C48  ld XWA,(XIZ+0xf0)
	add	xwa, 472	; F37C4B  add XWA,0x000001d8
	ld	(xiz-4), xwa	; F37C51  ld (XIZ+0xfc),XWA
	add	xbc, xwa	; F37C54  add XBC,XWA
	extz	xbc	; F37C56  extz XBC
	cp	xbc, xix	; F37C58  cp XBC,XIX
	jr	ugt, SysExToneImage_WriteByte_Skip14	; F37C5A  jr UGT,0xf37c76
	pushw	255	; F37C5C  push 0x00ff
	lda	xbc, (2562:24)	; F37C5F  lda XBC,0x000a02
	push	xbc	; F37C64  push XBC
	sub	xiy, xiy	; F37C65  sub XIY,XIY
	add	xiy, xwa	; F37C67  add XIY,XWA
	extz	xiy	; F37C69  extz XIY
	ld	xbc, xix	; F37C6B  ld XBC,XIX
	sub	xbc, xiy	; F37C6D  sub XBC,XIY
	pushw	bc	; F37C6F  push BC
	pushw	1	; F37C70  push 0x0001
	jrl	SysExToneImage_WriteByte_Join3	; F37C73  jrl T,0xf37d03
SysExToneImage_WriteByte_Skip14:
	sub	xbc, xbc	; F37C76  sub XBC,XBC
	ld	(xiz-24), xbc	; F37C78  ld (XIZ+0xe8),XBC
	ld	xwa, (xiz-16)	; F37C7B  ld XWA,(XIZ+0xf0)
	add	xwa, 408	; F37C7E  add XWA,0x00000198
	ld	(xiz-8), xwa	; F37C84  ld (XIZ+0xf8),XWA
	add	xbc, xwa	; F37C87  add XBC,XWA
	extz	xbc	; F37C89  extz XBC
	cp	xbc, xix	; F37C8B  cp XBC,XIX
	jrl	ugt, SysExToneImage_WriteByte_Join5	; F37C8D  jrl UGT,0xf37d0b
	pushw	255	; F37C90  push 0x00ff
	lda	xbc, (2562:24)	; F37C93  lda XBC,0x000a02
	push	xbc	; F37C98  push XBC
	sub	xiy, xiy	; F37C99  sub XIY,XIY
	add	xiy, xwa	; F37C9B  add XIY,XWA
	extz	xiy	; F37C9D  extz XIY
	ld	xbc, xix	; F37C9F  ld XBC,XIX
	sub	xbc, xiy	; F37CA1  sub XBC,XIY
	pushw	bc	; F37CA3  push BC
	pushw	0	; F37CA4  push 0x0000
	jr	SysExToneImage_WriteByte_Join3	; F37CA7  jr T,0xf37d03
SysExToneImage_WriteByte_Skip15:
	ld	xix, (xiz-20)	; F37CA9  ld XIX,(XIZ+0xec)
	cp	xix, 82	; F37CAC  cp XIX,0x00000052
	jr	nz, SysExToneImage_WriteByte_Skip16	; F37CB2  jr NZ,0xf37ccc
	push	0	; F37CB4  push 0x00
	push	(0x000a02:24)	; F37CB6  push (0x000a02)
	ld	xbc, xix	; F37CBB  ld XBC,XIX
	sub	xbc, 82	; F37CBD  sub XBC,0x00000052
	add	xbc, 69	; F37CC3  add XBC,0x00000045
	pushw	bc	; F37CC9  push BC
	jr	SysExToneImage_WriteByte_Join2	; F37CCA  jr T,0xf37cec
SysExToneImage_WriteByte_Skip16:
	cp	xix, 83	; F37CCC  cp XIX,0x00000053
	jr	c, SysExToneImage_WriteByte_Skip17	; F37CD2  jr C,0xf37cf3
	cp	xix, 151	; F37CD4  cp XIX,0x00000097
	jr	ugt, SysExToneImage_WriteByte_Skip17	; F37CDA  jr UGT,0xf37cf3
	push	0	; F37CDC  push 0x00
	push	(0x000a02:24)	; F37CDE  push (0x000a02)
	ld	xbc, xix	; F37CE3  ld XBC,XIX
	sub	xbc, 83	; F37CE5  sub XBC,0x00000053
	pushw	bc	; F37CEB  push BC
SysExToneImage_WriteByte_Join2:
	call	T_DspParam_WriteByNumber	; F37CEC  call 0xf434a0
	pop	xiy	; F37CF0  pop XIY
	jr	SysExToneImage_WriteByte_Join5	; F37CF1  jr T,0xf37d0b
SysExToneImage_WriteByte_Skip17:
	pushw	255	; F37CF3  push 0x00ff
	lda	xbc, (2562:24)	; F37CF6  lda XBC,0x000a02
	push	xbc	; F37CFB  push XBC
	ld	wa, (xiz-20)	; F37CFC  ld WA,(XIZ+0xec)
	pushw	wa	; F37CFF  push WA
	pushw	3	; F37D00  push 0x0003
SysExToneImage_WriteByte_Join3:
	call	T_ToneMsg8D_SendParam	; F37D03  call 0xf43478
SysExToneImage_WriteByte_Join4:
	inc	8, xsp	; F37D07  inc 0,XSP
	inc	2, xsp	; F37D09  inc 2,XSP
SysExToneImage_WriteByte_Join5:
	sub	wa, wa	; F37D0B  sub WA,WA
	jr	SysExToneImage_WriteByte_Join6	; F37D0D  jr T,0xf37d12
SysExToneImage_WriteByte_Skip18:
	ldw	wa, 1	; F37D0F  ld WA,0x0001
SysExToneImage_WriteByte_Join6:
	pop	xix	; F37D12  pop XIX
	popw	hl	; F37D13  pop HL
	unlk XIZ	; F37D14  unlk XIZ
	ret	; F37D16  ret

; --------------------------------------------------------------------------
; SysExParam_ExecSoundWriteRequest
; Called from: T_SysExParam_ExecSoundWriteRequest (x1); far site 0xF4125C
; Touches: nothing with an absolute address
; Calls:   T_ToneMsg80_Id01
; Evidence: thunk slot T_SysExParam_ExecSoundWriteRequest holds `jp 0x00F37D17`, and 0xF37D17 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExParam_ExecSoundWriteRequest: Carries out a received SOUND WRITE REQUEST: number = nibbles +12/+13, bank =
;   nibbles +15/+16 of the payload; bank 8/9 -> slot (bank-8)*128 + number, bank 0x28/0x29 with number < 2 ->
;   (bank-0x28)*2 + number; T_ToneMsg80_Id01(slot, 0x30), WA = 0. Any other bank or number returns WA = 1, and the
;   setter then sends an error frame. ToneMsg80_Id01 is the call SOUND EDIT MEMORY WRITE makes. Basis: caller + body +
;   the memory-write twin. (notes/naming-pilot-2026-10-06/proposals_wave3_j.json)
SysExParam_ExecSoundWriteRequest:		; <- T_SysExParam_ExecSoundWriteRequest
	link XIZ,0xfffc	; F37D17  link XIZ,0xfffc
	pushw	hl	; F37D1B  push HL
	pushw	de	; F37D1C  push DE
	push	xix	; F37D1D  push XIX
	ld	xix, (xiz+8)	; F37D1E  ld XIX,(XIZ+0x08)
	ld	xbc, xix	; F37D21  ld XBC,XIX
	add	xbc, 12	; F37D23  add XBC,0x0000000c
	ld	(xiz-4), xbc	; F37D29  ld (XIZ+0xfc),XBC
	ld	a, (xix+13)	; F37D2C  ld A,(XIX+0x0d)
	ld	d, a	; F37D2F  ld D,A
	and	d, 15	; F37D31  and D,0x0f
	ld	l, (xbc)	; F37D34  ld L,(XBC)
	ld	c, l	; F37D36  ld C,L
	sll	c, 4	; F37D38  sll 0x04,C
	ld	l, c	; F37D3B  ld L,C
	or	c, d	; F37D3D  or C,D
	ld	l, c	; F37D3F  ld L,C
	ld	a, (xix+16)	; F37D41  ld A,(XIX+0x10)
	ld	d, a	; F37D44  ld D,A
	and	d, 15	; F37D46  and D,0x0f
	ld	h, (xix+15)	; F37D49  ld H,(XIX+0x0f)
	ld	b, h	; F37D4C  ld B,H
	sll	b, 4	; F37D4E  sll 0x04,B
	ld	h, b	; F37D51  ld H,B
	or	b, d	; F37D53  or B,D
	ld	h, b	; F37D55  ld H,B
	cp	b, 8	; F37D57  cp B,0x08
	jr	z, SysExParam_ExecSoundWriteRequest_Skip	; F37D5A  jr Z,0xf37d61
	cp	b, 9	; F37D5C  cp B,0x09
	jr	nz, SysExParam_ExecSoundWriteRequest_Skip2	; F37D5F  jr NZ,0xf37d78
SysExParam_ExecSoundWriteRequest_Skip:
	pushw	48	; F37D61  push 0x0030
	ld	c, h	; F37D64  ld C,H
	extz	bc	; F37D66  extz BC
	dec	8, bc	; F37D68  dec 0,BC
	ld	de, bc	; F37D6A  ld DE,BC
	sll	de, 7	; F37D6C  sll 0x07,DE
	ld	c, l	; F37D6F  ld C,L
	extz	bc	; F37D71  extz BC
	add	bc, de	; F37D73  add BC,DE
	pushw	bc	; F37D75  push BC
	jr	SysExParam_ExecSoundWriteRequest_Join	; F37D76  jr T,0xf37d9c
SysExParam_ExecSoundWriteRequest_Skip2:
	cp	h, 40	; F37D78  cp H,0x28
	jr	z, SysExParam_ExecSoundWriteRequest_Skip3	; F37D7B  jr Z,0xf37d82
	cp	h, 41	; F37D7D  cp H,0x29
	jr	nz, SysExParam_ExecSoundWriteRequest_Skip4	; F37D80  jr NZ,0xf37da5
SysExParam_ExecSoundWriteRequest_Skip3:
	cp	l, 2:i3	; F37D82  cp L,2
	jr	nc, SysExParam_ExecSoundWriteRequest_Skip4	; F37D84  jr NC,0xf37da5
	pushw	48	; F37D86  push 0x0030
	ld	c, h	; F37D89  ld C,H
	extz	bc	; F37D8B  extz BC
	sub	bc, 40	; F37D8D  sub BC,0x0028
	ld	de, bc	; F37D91  ld DE,BC
	add	de, de	; F37D93  add DE,DE
	ld	c, l	; F37D95  ld C,L
	extz	bc	; F37D97  extz BC
	add	bc, de	; F37D99  add BC,DE
	pushw	bc	; F37D9B  push BC
SysExParam_ExecSoundWriteRequest_Join:
	call	T_ToneMsg80_Id01	; F37D9C  call 0xf43480
	pop	xiy	; F37DA0  pop XIY
	sub	wa, wa	; F37DA1  sub WA,WA
	jr	SysExParam_ExecSoundWriteRequest_Join2	; F37DA3  jr T,0xf37da8
SysExParam_ExecSoundWriteRequest_Skip4:
	ldw	wa, 1	; F37DA5  ld WA,0x0001
SysExParam_ExecSoundWriteRequest_Join2:
	pop	xix	; F37DA8  pop XIX
	popw	de	; F37DA9  pop DE
	popw	hl	; F37DAA  pop HL
	unlk XIZ	; F37DAB  unlk XIZ
	ret	; F37DAD  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_GetReplyDataBuffer
; Called from: T_SysExThirdRegion_GetReplyDataBuffer (x3); far site 0xF41260
; Touches: nothing with an absolute address
; Evidence: thunk slot T_SysExThirdRegion_GetReplyDataBuffer holds `jp 0x00F37DAE`, and 0xF37DAE is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_GetReplyDataBuffer: XIY := 0x0B0B, the buffer whose bytes SysExThirdRegion_SendReplyChunk sends as
;   nibble pairs (SysExThirdRegion_FetchNextChunk has T_DspParam_ReadByNumber fill it). Cpu2Reply_HandleNext (slot
;   T_SysExThirdRegion_GetReplyDataBuffer) stores CPU 2's reply bytes through it: the Var2812 continuation, the opcode-0x16 two-byte reply and the
;   tag-0x30 block. Basis: callers + body + reader. (notes/naming-pilot-2026-10-06/proposals_wave10_b10.json)
SysExThirdRegion_GetReplyDataBuffer:		; <- T_SysExThirdRegion_GetReplyDataBuffer
	lda	xiy, (2827:24)	; F37DAE  lda XIY,0x000b0b
	ret	; F37DB3  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_BuildReplyHeader
; Called from: in-module: 0xF37E2E
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF37DB4 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_BuildReplyHeader: Writes the 12-byte head of a 2C reply at the buffer (arg 1): F0 50 2C 04 00 11,
;   the 21-bit address (0x0A03) as three 7-bit bytes, 00 00 and the count (arg 2); returns XIY = buffer + 12, where
;   SysExThirdRegion_SendReplyChunk puts the nibble data. Its only caller is SysExThirdRegion_SendReplyChunk. Basis:
;   caller + body + notes/sysex-probes/sysex_third_region.py. (notes/naming-pilot-2026-10-06/proposals_wave5_o.json)
SysExThirdRegion_BuildReplyHeader:
	link XIZ,0x0000	; F37DB4  link XIZ,0x0000
	push	xix	; F37DB8  push XIX
	ld	xix, (xiz+8)	; F37DB9  ld XIX,(XIZ+0x08)
	ld	(xix), 240	; F37DBC  ld (XIX),0xf0
	ld	(xix+1), 80	; F37DBF  ld (XIX+0x01),0x50
	ld	(xix+2), 44	; F37DC3  ld (XIX+0x02),0x2c
	ld	(xix+3), 4	; F37DC7  ld (XIX+0x03),0x04
	ld	(xix+4), 0	; F37DCB  ld (XIX+0x04),0x00
	ld	(xix+5), 17	; F37DCF  ld (XIX+0x05),0x11
	ld	xbc, (2563:24)	; F37DD3  ld XBC,(0x000a03)
	and	xbc, 2080768	; F37DD8  and XBC,0x001fc000
	sra	xbc, 14	; F37DDE  sra 0x0e,XBC
	ld	(xix+6), c	; F37DE1  ld (XIX+0x06),C
	ld	xbc, (2563:24)	; F37DE4  ld XBC,(0x000a03)
	and	xbc, 16256	; F37DE9  and XBC,0x00003f80
	sra	xbc, 7	; F37DEF  sra 0x07,XBC
	ld	(xix+7), c	; F37DF2  ld (XIX+0x07),C
	ld	c, (2563:24)	; F37DF5  ld C,(0x000a03)
	res	7, c	; F37DFA  res 0x07,C
	ld	(xix+8), c	; F37DFD  ld (XIX+0x08),C
	ld	(xix+9), 0	; F37E00  ld (XIX+0x09),0x00
	ld	(xix+10), 0	; F37E04  ld (XIX+0x0a),0x00
	ld	c, (xiz+12)	; F37E08  ld C,(XIZ+0x0c)
	ld	(xix+11), c	; F37E0B  ld (XIX+0x0b),C
	ld	xbc, xix	; F37E0E  ld XBC,XIX
	add	xbc, 12	; F37E10  add XBC,0x0000000c
	ld	xiy, xbc	; F37E16  ld XIY,XBC
	pop	xix	; F37E18  pop XIX
	unlk XIZ	; F37E19  unlk XIZ
	ret	; F37E1B  ret

; --------------------------------------------------------------------------
; SysExThirdRegion_SendReplyChunk
; Called from: T_SysExThirdRegion_SendReplyChunk (x1); far site 0xF41264; in-module: 0xF36EF9
; Touches: nothing with an absolute address
; Calls:   SysExThirdRegion_BuildReplyHeader T_SysEx_Checksum T_SysExTx_SendBytes
; Evidence: thunk slot T_SysExThirdRegion_SendReplyChunk holds `jp 0x00F37E1C`, and 0xF37E1C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SysExThirdRegion_SendReplyChunk: Sends one 2C reply of a third-region request: SysExThirdRegion_BuildReplyHeader builds F0 50 2C 04 00 11 +
;   the address septets of (0x0A03) + count (0x0A09) at 0x0A0B, then the bytes at 0x0B0B as nibble pairs (one byte
;   from 0x0B0B/0x0B0C when (0x0A00) bit 8/9), 00, SysEx_Checksum, F7, SysExTx_SendBytes; (0x0A07) -= n, (0x0A03) +=
;   n; re-arms (0x0A00) bit 2 while bytes remain, else (0x0A00) := 0. Basis: callers + body + sysex_third_region.py.
;   (notes/naming-pilot-2026-10-06/proposals_wave4_n.json)
SysExThirdRegion_SendReplyChunk:		; <- T_SysExThirdRegion_SendReplyChunk
	link XIZ,0xfff8	; F37E1C  link XIZ,0xfff8
	pushw	hl	; F37E20  push HL
	pushw	de	; F37E21  push DE
	push	xix	; F37E22  push XIX
	pushw	(0x000a09:24)	; F37E23  pushw (0x000a09)
	lda	xbc, (2571:24)	; F37E28  lda XBC,0x000a0b
	push	xbc	; F37E2D  push XBC
	calr	SysExThirdRegion_BuildReplyHeader	; F37E2E  calr 0xf37db4
	ld	xix, xiy	; F37E31  ld XIX,XIY
	ld	bc, (2560:24)	; F37E33  ld BC,(0x000a00)
	and	bc, 256	; F37E38  and BC,0x0100
	inc	6, xsp	; F37E3C  inc 6,XSP
	jr	z, SysExThirdRegion_SendReplyChunk_Skip	; F37E3E  jr Z,0xf37e58
	ld	c, (2827:24)	; F37E40  ld C,(0x000b0b)
	srl	c, 4	; F37E45  srl 0x04,C
	ld	(xiy), c	; F37E48  ld (XIY),C
	inc	1, xix	; F37E4A  inc 1,XIX
	ld	c, (2827:24)	; F37E4C  ld C,(0x000b0b)
	and	c, 15	; F37E51  and C,0x0f
	ld	(xix), c	; F37E54  ld (XIX),C
	jr	SysExThirdRegion_SendReplyChunk_Join	; F37E56  jr T,0xf37e79
SysExThirdRegion_SendReplyChunk_Skip:
	ld	bc, (2560:24)	; F37E58  ld BC,(0x000a00)
	and	bc, 512	; F37E5D  and BC,0x0200
	jr	z, SysExThirdRegion_SendReplyChunk_Skip2	; F37E61  jr Z,0xf37e7d
	ld	c, (2828:24)	; F37E63  ld C,(0x000b0c)
	srl	c, 4	; F37E68  srl 0x04,C
	ld	(xix), c	; F37E6B  ld (XIX),C
	inc	1, xix	; F37E6D  inc 1,XIX
	ld	c, (2828:24)	; F37E6F  ld C,(0x000b0c)
	and	c, 15	; F37E74  and C,0x0f
	ld	(xix), c	; F37E77  ld (XIX),C
SysExThirdRegion_SendReplyChunk_Join:
	inc	1, xix	; F37E79  inc 1,XIX
	jr	SysExThirdRegion_SendReplyChunk_Join3	; F37E7B  jr T,0xf37ebf
SysExThirdRegion_SendReplyChunk_Skip2:
	ldw	hl, 0	; F37E7D  ld HL,0x0000
SysExThirdRegion_SendReplyChunk_Join2:
	cp	hl, (0x000a09:24)	; F37E80  cp HL,(0x000a09)
	jr	nc, SysExThirdRegion_SendReplyChunk_Join3	; F37E85  jr NC,0xf37ebf
	ld	bc, hl	; F37E87  ld BC,HL
	extz	xbc	; F37E89  extz XBC
	ld	(xiz-4), xbc	; F37E8B  ld (XIZ+0xfc),XBC
	add	xbc, 2827	; F37E8E  add XBC,0x00000b0b
	ld	a, (xbc)	; F37E94  ld A,(XBC)
	srl	a, 4	; F37E96  srl 0x04,A
	ld	(xix), a	; F37E99  ld (XIX),A
	ld	xbc, xix	; F37E9B  ld XBC,XIX
	inc	1, xbc	; F37E9D  inc 1,XBC
	ld	(xiz-8), xbc	; F37E9F  ld (XIZ+0xf8),XBC
	lda	xwa, (2827:24)	; F37EA2  lda XWA,0x000b0b
	add	xwa, (xiz-4)	; F37EA7  add XWA,(XIZ+0xfc)
	ld	c, (xwa)	; F37EAA  ld C,(XWA)
	and	c, 15	; F37EAC  and C,0x0f
	ld	d, c	; F37EAF  ld D,C
	ld	xbc, (xiz-8)	; F37EB1  ld XBC,(XIZ+0xf8)
	ld	(xbc), d	; F37EB4  ld (XBC),D
	ld	xix, (xiz-8)	; F37EB6  ld XIX,(XIZ+0xf8)
	inc	1, xix	; F37EB9  inc 1,XIX
	inc	1, hl	; F37EBB  inc 1,HL
	jr	SysExThirdRegion_SendReplyChunk_Join2	; F37EBD  jr T,0xf37e80
SysExThirdRegion_SendReplyChunk_Join3:
	ld	(xix), 0	; F37EBF  ld (XIX),0x00
	ld	xbc, xix	; F37EC2  ld XBC,XIX
	inc	1, xbc	; F37EC4  inc 1,XBC
	ld	(xiz-4), xbc	; F37EC6  ld (XIZ+0xfc),XBC
	ld	iy, (2569:24)	; F37EC9  ld IY,(0x000a09)
	add	iy, iy	; F37ECE  add IY,IY
	add	iy, 13	; F37ED0  add IY,0x000d
	pushw	iy	; F37ED4  push IY
	lda	xwa, (2571:24)	; F37ED5  lda XWA,0x000a0b
	push	xwa	; F37EDA  push XWA
	call	T_SysEx_Checksum	; F37EDB  call 0xf4090c
	ld	xbc, (xiz-4)	; F37EDF  ld XBC,(XIZ+0xfc)
	ld	(xbc), a	; F37EE2  ld (XBC),A
	ld	xbc, (xiz-4)	; F37EE4  ld XBC,(XIZ+0xfc)
	ld	(xbc+1), 247	; F37EE7  ld (XBC+0x01),0xf7
	ld	bc, (2569:24)	; F37EEB  ld BC,(0x000a09)
	add	bc, bc	; F37EF0  add BC,BC
	add	bc, 15	; F37EF2  add BC,0x000f
	pushw	bc	; F37EF6  push BC
	lda	xbc, (2571:24)	; F37EF7  lda XBC,0x000a0b
	push	xbc	; F37EFC  push XBC
	call	T_SysExTx_SendBytes	; F37EFD  call 0xf40910
	ld	bc, (2569:24)	; F37F01  ld BC,(0x000a09)
	sub	(2567:24), bc	; F37F06  sub (0x000a07),BC
	exts	xbc	; F37F0B  exts XBC
	add	(2563:24), xbc	; F37F0D  add (0x000a03),XBC
	inc	8, xsp	; F37F12  inc 0,XSP
	inc	4, xsp	; F37F14  inc 4,XSP
	cpw	(0x000a07:24), 0x0000	; F37F16  cp (0x000a07),0x0000
	jr	le, SysExThirdRegion_SendReplyChunk_Skip3	; F37F1D  jr LE,0xf37f2d
	andw	(0x000a00:24), 0xfcfd	; F37F1F  and (0x000a00),0xfcfd
	set	2, (0x000a00:24)	; F37F26  set 2,(0x000a00)
	jr	SysExThirdRegion_SendReplyChunk_Join4	; F37F2B  jr T,0xf37f34
SysExThirdRegion_SendReplyChunk_Skip3:
	ldw	(2560:24), 0	; F37F2D  ld (0x000a00),0x0000
SysExThirdRegion_SendReplyChunk_Join4:
	pop	xix	; F37F34  pop XIX
	popw	de	; F37F35  pop DE
	popw	hl	; F37F36  pop HL
	unlk XIZ	; F37F37  unlk XIZ
	ret	; F37F39  ret

; --------------------------------------------------------------------------
; Divide32_Unsigned_Quotient
; Called from: in-module: 0xF36D0E 0xF36D54 0xF375BA 0xF37BFA
; Touches: nothing with an absolute address
; Evidence: a 32-iteration restoring division.  `ld B,0x20` is the loop count;
;           `sllw (XIZ+0x08)` / `sllw (XIZ+0x0a)` shift the 32-bit dividend
;           left one bit per iteration through the carry, `cp XIX,(XIZ+0x0c) /
;           sub XIX,(XIZ+0x0c)` compares and conditionally subtracts the
;           32-bit divisor, and `inc 1,XIY` sets the quotient bit.  XIX -- the
;           running remainder -- is `pop`ped back at the end, so what survives
;           is XIY, the QUOTIENT.  `retd 0x0008` removes the two 32-bit
;           arguments.  ★ CONFIRMED FROM THE OTHER SIDE: 0xF375BA divides (id
;           - 408) by 150 with this routine and then multiplies the answer by
;           150 again to rebuild a row base, which only works if the answer is
;           a quotient.
; --------------------------------------------------------------------------
Divide32_Unsigned_Quotient:
	link XIZ,0x0000	; F37F3A  link XIZ,0x0000
	push	xix	; F37F3E  push XIX
	ld	b, 32:opc	; F37F3F  ld B,0x20
	sub	wa, wa	; F37F41  sub WA,WA
	sub	xiy, xiy	; F37F43  sub XIY,XIY
	sub	xix, xix	; F37F45  sub XIX,XIX
Divide32_Unsigned_Quotient_Loop:
	sll	xix, 1	; F37F47  sll 0x01,XIX
	sllw	(xiz+8)	; F37F4A  sllw (XIZ+0x08)
	.byte 0xD8, 0x24, 0x00	; F37F4D  stcf 0x00,WA   [llvm-mc cannot encode this]
	sllw	(xiz+10)	; F37F50  sllw (XIZ+0x0a)
	.byte 0xDC, 0x24, 0x00	; F37F53  stcf 0x00,IX   [llvm-mc cannot encode this]
	add	(xiz+10), wa	; F37F56  add (XIZ+0x0a),WA
	sll	xiy, 1	; F37F59  sll 0x01,XIY
	cp	xix, (xiz+12)	; F37F5C  cp XIX,(XIZ+0x0c)
	jr	c, Divide32_Unsigned_Quotient_Skip	; F37F5F  jr C,0xf37f66
	sub	xix, (xiz+12)	; F37F61  sub XIX,(XIZ+0x0c)
	inc	1, xiy	; F37F64  inc 1,XIY
Divide32_Unsigned_Quotient_Skip:
	dec	1, b	; F37F66  dec 1,B
	jr	nz, Divide32_Unsigned_Quotient_Loop	; F37F68  jr NZ,0xf37f47
	pop	xix	; F37F6A  pop XIX
	unlk XIZ	; F37F6B  unlk XIZ
	retd	8	; F37F6D  retd 0x0008

; --------------------------------------------------------------------------
; Asr16ByCount
; Called from: in-module: 0xF37040
; Touches: nothing with an absolute address
; Evidence: reached by a branch decoded in this transcription (the sites are
;           listed above), so 0xF37F70 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Asr16ByCount: Asr16ByCount(value, count): value >> count, ARITHMETIC (`sra A,IY`), count up to 31 (a high nibble
;   shifts 16 first), callee pops 4 -- the signed twin of prom_a Lsr16ByCount. ClampFieldToRange shifts its masked
;   field with it before the SIGNED clamp. Basis: caller + body + twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_g.json)
Asr16ByCount:
	ld	iy, (xsp+4)	; F37F70  ld IY,(XSP+0x04)
	ld	b, (xsp+6)	; F37F73  ld B,(XSP+0x06)
	ld	w, b	; F37F76  ld W,B
	srl	w, 4	; F37F78  srl 0x04,W
	sub	a, a	; F37F7B  sub A,A
	cp	w, 0:i3	; F37F7D  cp W,0
	jr	z, Asr16ByCount_Skip	; F37F7F  jr Z,0xf37f83
	.byte 0xDD, 0xFD	; F37F81  sra A,IY   [llvm-mc cannot encode this]
Asr16ByCount_Skip:
	ld	a, b	; F37F83  ld A,B
	and	a, 15	; F37F85  and A,0x0f
	jr	z, Asr16ByCount_Skip2	; F37F88  jr Z,0xf37f8c
	.byte 0xDD, 0xFD	; F37F8A  sra A,IY   [llvm-mc cannot encode this]
Asr16ByCount_Skip2:
	ld	wa, iy	; F37F8C  ld WA,IY
	retd	4	; F37F8E  retd 0x0004

; --------------------------------------------------------------------------
; Divide32_Unsigned_Remainder
; Called from: in-module: 0xF3708D 0xF37182 0xF375F4
; Touches: nothing with an absolute address
; Evidence: the same 32-iteration restoring division with the two accumulators
;           exchanged: here XIY holds the running remainder and XIX the
;           quotient bits, and XIX is the one `pop`ped back, so what survives
;           is the REMAINDER.  ★ CONFIRMED FROM THE OTHER SIDE: 0xF3708D calls
;           it with a divisor of 0x2B and immediately bounds the answer `cp
;           IY,0x0029` -- 41 -- which is exactly the largest residue mod 43,
;           and would be wrong for a quotient.
; --------------------------------------------------------------------------
Divide32_Unsigned_Remainder:
	link XIZ,0x0000	; F37F91  link XIZ,0x0000
	push	xix	; F37F95  push XIX
	ld	b, 32:opc	; F37F96  ld B,0x20
	sub	wa, wa	; F37F98  sub WA,WA
	sub	xix, xix	; F37F9A  sub XIX,XIX
	sub	xiy, xiy	; F37F9C  sub XIY,XIY
Divide32_Unsigned_Remainder_Loop:
	sll	xiy, 1	; F37F9E  sll 0x01,XIY
	sllw	(xiz+8)	; F37FA1  sllw (XIZ+0x08)
	.byte 0xD8, 0x24, 0x00	; F37FA4  stcf 0x00,WA   [llvm-mc cannot encode this]
	sllw	(xiz+10)	; F37FA7  sllw (XIZ+0x0a)
	.byte 0xDD, 0x24, 0x00	; F37FAA  stcf 0x00,IY   [llvm-mc cannot encode this]
	add	(xiz+10), wa	; F37FAD  add (XIZ+0x0a),WA
	sll	xix, 1	; F37FB0  sll 0x01,XIX
	cp	xiy, (xiz+12)	; F37FB3  cp XIY,(XIZ+0x0c)
	jr	c, Divide32_Unsigned_Remainder_Skip	; F37FB6  jr C,0xf37fbd
	sub	xiy, (xiz+12)	; F37FB8  sub XIY,(XIZ+0x0c)
	inc	1, xix	; F37FBB  inc 1,XIX
Divide32_Unsigned_Remainder_Skip:
	dec	1, b	; F37FBD  dec 1,B
	jr	nz, Divide32_Unsigned_Remainder_Loop	; F37FBF  jr NZ,0xf37f9e
	pop	xix	; F37FC1  pop XIX
	unlk XIZ	; F37FC2  unlk XIZ
	retd	8	; F37FC4  retd 0x0008
	.fill	2105, 1, 0x0E	; F37FC7-F387FF  `ret` padding (asserted pure 0x0E)
