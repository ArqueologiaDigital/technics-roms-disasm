; ============================================================================
; DSP CONTROL ROUTINES
; These routines control the two DSP chips via GPIO pins:
;   PH.1 = DSP1 reset (active low)
;   PH.2 = DSP2 reset (active low)
;   P7.3 = DSP write strobe (active low)
;   P7.4 = DSP read strobe (active low)
;   P7.5 = DSP1 chip select (active low)
;   P7.6 = DSP command/data select (0=command, 1=data)
;   PE.6 = DSP2 chip select (active low)
; ============================================================================

DSP1_Assert_Reset:	.include "includes/generated/cc900/DSP1_Assert_Reset.s"	; C: cc900/dsp_control_routines.c

DSP1_Deassert_Reset:	.include "includes/generated/cc900/DSP1_Deassert_Reset.s"	; C: cc900/dsp_control_routines.c

DSP2_Assert_Reset:	.include "includes/generated/cc900/DSP2_Assert_Reset.s"	; C: cc900/dsp_control_routines.c

DSP2_Deassert_Reset:	.include "includes/generated/cc900/DSP2_Deassert_Reset.s"	; C: cc900/dsp_control_routines.c

DSP_Nop:	.include "includes/generated/cc900/DSP_Nop.s"	; C: cc900/dsp_control_routines.c

DSP_Set_Command_Mode:	.include "includes/generated/cc900/DSP_Set_Command_Mode.s"	; C: cc900/dsp_control_routines.c

DSP_Set_Data_Mode:	.include "includes/generated/cc900/DSP_Set_Data_Mode.s"	; C: cc900/dsp_control_routines.c

DSP_Assert_Write:	.include "includes/generated/cc900/DSP_Assert_Write.s"	; C: cc900/dsp_control_routines.c

DSP_Deassert_Write:	.include "includes/generated/cc900/DSP_Deassert_Write.s"	; C: cc900/dsp_control_routines.c

; DSP_Assert_Read: Asserts the DSP1 read strobe, `res 4,(P7)` (P7.4, active low); the pair of DSP_Deassert_Read. No
;   caller in this build -- firmware never reads the DSP1 data bus (status comes from PH.0). Basis: pin-map header +
;   paired routine + body; the _Data suffix is a leftover of its former `.byte` spelling.
DSP_Assert_Read:	.include "includes/generated/cc900/DSP_Assert_Read.s"	; C: cc900/dsp_control_routines.c

DSP_Deassert_Read:	.include "includes/generated/cc900/DSP_Deassert_Read.s"	; C: cc900/dsp_control_routines.c

; ----------------------------------------------------------------------------
; DSP_Select_Chip - Select DSP chip for communication
; Entry: WA = chip number (0=DSP1, 1=DSP2)
; Exit:  Chip select asserted (active low)
; ----------------------------------------------------------------------------
DSP_Select_Chip:	.include "includes/generated/cc900/DSP_Select_Chip.s"	; C: cc900/dsp_control_routines_e_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_Select_Chip__select_dsp2, DSP_Select_Chip + 23
	.set	DSP_Select_Chip__done, DSP_Select_Chip + 26

; ----------------------------------------------------------------------------
; DSP_Deselect_Chip - Deselect DSP chip after communication
; Entry: WA = chip number (0=DSP1, 1=DSP2)
; Exit:  Chip select deasserted
; ----------------------------------------------------------------------------
DSP_Deselect_Chip:	.include "includes/generated/cc900/DSP_Deselect_Chip.s"	; C: cc900/dsp_control_routines_e_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_Deselect_Chip__deselect_dsp2, DSP_Deselect_Chip + 23
	.set	DSP_Deselect_Chip__done, DSP_Deselect_Chip + 26

; ----------------------------------------------------------------------------
; DSP_Read_Status - Read DSP status from PH.0
; Entry: None
; Exit:  HL = status bit (0 or 1)
; ----------------------------------------------------------------------------
DSP_Read_Status:	; 0383F7h
	calr DSP_Nop
	set	0, (PH:8)
	ldcf	0, (PH:8)
	scc8 c, l
	extz hl
	ret

; Entry: XWA = 16-bit value, BC = chip number. Sends the value to the chip as two DATA
; bytes, LOW byte first then HIGH byte, each through DSP_DispatchData. Used only by
; DSP_WriteParamCmd30, i.e. only on the chip-1 protocol.
DSP_WriteParamWord:	.include "includes/generated/cc900/DSP_WriteParamWord.s"	; C: cc900/dsp_control_routines.c

; The chip-1 (IC310 / "DSP2") parameter protocol, and it is completely different from the
; IC311 one. Entry: WA = chip, BC = register index, XDE = 16-bit value.
; Emits: COMMAND 0x30, DATA 0x00, DATA (index & 0xFF), then DSP_WriteParamWord(value).
; Every DSP_Write*Param routine below funnels into this whenever its chip argument is 1.
DSP_WriteParamCmd30:	.include "includes/generated/cc900/DSP_WriteParamCmd30.s"	; C: cc900/dsp_control_routines_e_6a.c

; Entry: DE = chip, XBC = 24-bit coefficient, WA = index, plus a base index pushed by the
; caller at (xsp+12); `retd 0x2`.
; If chip == 1 it delegates to DSP_WriteParamCmd30. On chip 0 it emits an 11-byte
; sequence: DATA 0x00, 0x00, then the index split as
;   ((base+index) >> 4 & 0x0F) + 0x10   and   ((base+index) << 4 & 0xF0),
; then DATA 0x00, DATA 0x0A, and finally the 24-bit value packed into four bytes:
;   (v >> 17) & 0x7F, (v >> 9) & 0xFF, (v >> 1) & 0xFF, ((v << 7) & 0x80) + 0x15.
; That 7+8+8+1 split with the 0x15 tag in the last byte is the 36-bit-word packing
; described in technics-docs/effects-dsp.md; the tag distinguishes the destination bank.
DSP_WriteFreqParam_AlgoType:	.include "includes/generated/cc900/DSP_WriteFreqParam_AlgoType.s"	; C: cc900/dsp_control_routines_e_7a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_WriteFreqParam_AlgoType_UseCmd30, DSP_WriteFreqParam_AlgoType + 188
	.set	DSP_WriteFreqParam_AlgoType_Return, DSP_WriteFreqParam_AlgoType + 199

; Identical body to DSP_WriteFreqParam_AlgoType (same 0x10 index bias, same 0x0A opener,
; same 0x15 tag), differing only in which stack slot supplies the base index. It is the
; heavily used one: five call sites at 0x0455xx in the parameter interpreter plus the LUT
; writer at 0x038764, and the pointer 0x038539 appears five times in the ROM's dispatch
; data (0x03CC47, 0x03CCBF, 0x03CCF9, 0x03CD16, 0x03CD36).
DSP_WriteFreqParam:	.include "includes/generated/cc900/DSP_WriteFreqParam.s"	; C: cc900/dsp_control_routines_e_7a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_WriteFreqParam_UseCmd30, DSP_WriteFreqParam + 188
	.set	DSP_WriteFreqParam_Return, DSP_WriteFreqParam + 199

; Entry: XWA = 24-bit coefficient, BC = chip. Emits exactly five DATA bytes and nothing
; else: 0x0A, (v >> 17) & 0x7F, (v >> 9) & 0xFF, (v >> 1) & 0xFF, ((v << 7) & 0x80) + 0x15.
; This is the "bare" coefficient write -- the same tail DSP_WriteFreqParam uses, without
; the index header. It is what streams a coefficient bank into the chip.
DSP_WriteCoeffData_5B:	.include "includes/generated/cc900/DSP_WriteCoeffData_5B.s"	; C: cc900/dsp_control_routines.c

; The 24-bit BIG-ENDIAN stream reader. Entry: XWA = address of a 32-bit cursor variable.
; Reads three bytes b0,b1,b2 at *cursor and returns XHL = (b0 << 16) | (b1 << 8) | b2,
; then advances *cursor by 3. Clobbers XIX, XIY, XBC, XDE.
; This is the decoder for the 3-byte Q0.23 coefficient format; every coefficient in the
; DSP program blobs is stored big-endian even though the CPU is little-endian.
DSP_UnpackParam3B:	.include "includes/generated/cc900/DSP_UnpackParam3B.s"	; C: cc900/dsp_control_routines.c

; Uploads one of six fixed lookup-table programs. Entry: XWA = address of a 32-bit stream
; cursor, BC = chip, XDE = variant (0, 1 or 2), plus stacked arguments; frame of 18 bytes;
; `retd 0x4`. Returns HL.
; The table it uploads does NOT come from the caller's stream -- the caller's cursor value
; is saved on entry and written back verbatim at DSP_WriteLUT_MainLoop_Done, so the caller
; sees no advance. Instead a ROM address is chosen from (chip, variant):
;   chip 0 (36 words): variant 0 -> 0x01EAFA, 1 -> 0x01EB67, 2 -> 0x01EBD4
;   chip 1 (32 words): variant 0 -> 0x01EC41, 1 -> 0x01ECA5, 2 -> 0x01ED09
; The first byte of the chosen blob is a base index. The loop then runs size/4 times
; (9 iterations for chip 0, 8 for chip 1) and per iteration emits:
;   (except on the first) COMMAND 0x01, DATA 0x01, DATA 0x60
;   DSP_WriteFreqParam(base + 4*i, next 3-byte coefficient, chip)
;   three x DSP_WriteCoeffData_5B(next 3-byte coefficient, chip)
;   COMMAND 0x03
; So each entry is one indexed word plus three raw coefficients -- a four-coefficient
; lookup-table row. Only one caller, at 0x045692.
; CORRECTION (2026-09-25, from the instructions below): two claims above are wrong.
;  * The table family is NOT chosen by BC.  0x0386AD `ld c,(xwa+)` reads the selector C from the
;    caller's VALUE STREAM (the operand byte of the op74 record `00 06 74 00 <C> 7a`), and
;    `cp c,1` picks the 32-word family on C == 1, the 36-word family otherwise.  So "chip 0" /
;    "chip 1" here and in the branch comments below mean C != 1 / C == 1.  All 26 effects whose
;    value table has an op74 record are IC311 effects, and C is 1 for ten of them (see
;    DSP_Op74_LUT_Rows9_Var0 in subcpu_data_tables.s).  The BC argument's copy at (xsp+14) is
;    overwritten with the base index at DSP_WriteLUT_MainLoop_Init before any use.
;  * The caller's cursor DOES advance, by exactly that one selector byte: 0x0386B0 re-saves the
;    post-incremented XWA to (xsp+6), which DSP_WriteLUT_MainLoop_Done writes back.
DSP_WriteLUTParamSet:
	lda xsp, (xsp - 18)
	pushw iz
	ld (xsp + 14), bc
	ld (xsp + 16), xwa
	ld xwa, (xsp + 16)
	ld xwa, (xwa)
	ld (xsp + 6), xwa
	ld C, (xwa+)
	ld (xsp + 6), xwa
	cp c, 1:i3
	jr z, DSP_WriteLUT_AlgoC1
	ldw (xsp + 2), 0x24
	cp xde, 0x2
	jr z, DSP_WriteLUT_AlgoC0_TypeDE2
	cp xde, 0x1
	jr z, DSP_WriteLUT_AlgoC0_TypeDE1
	lda xwa, (DSP_Op74_LUT_Rows9_Var0:24)
	ld (xsp + 10), xwa
	jr DSP_WriteLUT_MainLoop_Init

; chip 0, variant 1: select the blob at 0x01EB67.
DSP_WriteLUT_AlgoC0_TypeDE1:
	lda xwa, (DSP_Op74_LUT_Rows9_Var1:24)
	ld (xsp + 10), xwa
	jr DSP_WriteLUT_MainLoop_Init

; chip 0, variant 2: select the blob at 0x01EBD4.
DSP_WriteLUT_AlgoC0_TypeDE2:
	lda xwa, (DSP_Op74_LUT_Rows9_Var2:24)
	ld (xsp + 10), xwa
	jr DSP_WriteLUT_MainLoop_Init

; chip 1: table size becomes 0x20 words; select among 0x01EC41 / 0x01ECA5 / 0x01ED09.
DSP_WriteLUT_AlgoC1:
	ldw (xsp + 2), 0x20
	cp xde, 0x2
	jr z, DSP_WriteLUT_AlgoC1_TypeDE2
	cp xde, 0x1
	jr z, DSP_WriteLUT_AlgoC1_TypeDE1
	lda xwa, (DSP_Op74_LUT_Rows8_Var0:24)
	ld (xsp + 10), xwa
	jr DSP_WriteLUT_MainLoop_Init

; chip 1, variant 1: select the blob at 0x01ECA5.
DSP_WriteLUT_AlgoC1_TypeDE1:
	lda xwa, (DSP_Op74_LUT_Rows8_Var1:24)
	ld (xsp + 10), xwa
	jr DSP_WriteLUT_MainLoop_Init

; chip 1, variant 2: select the blob at 0x01ED09.
DSP_WriteLUT_AlgoC1_TypeDE2:
	lda xwa, (DSP_Op74_LUT_Rows8_Var2:24)
	ld (xsp + 10), xwa

; Read the blob's first byte as the base index, advance the local cursor past it, zero the
; iteration counter, and compute the trip count as size/4.
DSP_WriteLUT_MainLoop_Init:
	ld xbc, (xsp + 10)
	ld xwa, 1:i3
	add (xsp + 10), xwa
	ld a, (xbc)
	extz wa
	ld (xsp + 14), wa
	ldw (xsp + 4), 0x0
	ld wa, (xsp + 2)
	srl wa, 2
	cp (xsp + 4), wa
	jrl nc, DSP_WriteLUT_MainLoop_Done

; Non-first iterations only: the COMMAND 0x01 / DATA 0x01 / DATA 0x60 row separator.
DSP_WriteLUT_MainLoop_RowStart:
	cpw (xsp + 4), 0x0
	jr z, DSP_WriteLUT_MainLoop_FirstEntry
	ld bc, (xsp + 26)
	ld wa, 1:i3
	call DSP_DispatchCommand
	ld iz, hl
	ld bc, (xsp + 26)
	ld wa, 1:i3
	call DSP_DispatchData
	ld iz, hl
	ld bc, (xsp + 26)
	ldw wa, 0x60
	call DSP_DispatchData
	ld iz, hl

; The four coefficient writes for one row (one DSP_WriteFreqParam plus three
; DSP_WriteCoeffData_5B), then the COMMAND 0x03 row terminator and the loop step.
DSP_WriteLUT_MainLoop_FirstEntry:
	ld wa, (xsp + 4)
	sll wa, 2
	ld iz, wa
	add iz, (xsp + 14)
	lda xwa, (xsp + 10)
	calr DSP_UnpackParam3B
	pushm (xsp + 24)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 28)
	calr DSP_WriteFreqParam
	ld iz, hl
	lda xwa, (xsp + 10)
	calr DSP_UnpackParam3B
	ld xwa, xhl
	ld bc, (xsp + 26)
	ld de, (xsp + 24)
	calr DSP_WriteCoeffData_5B
	ld iz, hl
	lda xwa, (xsp + 10)
	calr DSP_UnpackParam3B
	ld xwa, xhl
	ld bc, (xsp + 26)
	ld de, (xsp + 24)
	calr DSP_WriteCoeffData_5B
	ld iz, hl
	lda xwa, (xsp + 10)
	calr DSP_UnpackParam3B
	ld xwa, xhl
	ld bc, (xsp + 26)
	ld de, (xsp + 24)
	calr DSP_WriteCoeffData_5B
	ld iz, hl
	ld bc, (xsp + 26)
	ld wa, 3:i3
	call DSP_DispatchCommand
	incw 1, (xsp + 4)
	ld wa, (xsp + 2)
	srl wa, 2
	cp (xsp + 4), wa
	jrl c, DSP_WriteLUT_MainLoop_RowStart

; Restore the caller's stream cursor to its entry value, return HL, unwind the 18-byte
; frame, `retd 0x4`.
DSP_WriteLUT_MainLoop_Done:
	ld xwa, (xsp + 16)
	ld xbc, (xsp + 6)
	ld (xwa), xbc
	ld hl, iz
	popw iz
	lda xsp, (xsp + 18)
	retd 0x4

; The oscillator/LFO variant of DSP_WriteFreqParam and by far the most used routine in the
; region -- its address appears 24 times in the ROM's dispatch data between 0x039C72 and
; 0x03CEF6. Entry: DE = chip, XBC = 24-bit value, WA = index, base index pushed at
; (xsp+12); `retd 0x2`. chip == 1 delegates to DSP_WriteParamCmd30.
; On chip 0 it emits: DATA 0x08, DATA 0x01, then the index as
;   ((base+index) >> 4 & 0x0F)   and   ((base+index) << 4 & 0xF0) + 8,
; then DATA 0x21, DATA 0x0A, then the same four value bytes as DSP_WriteCoeffData_5B but
; with the tag 0x26 instead of 0x15. The 0x08/0x01 opener and the 0x21 selector are what
; distinguish this address space from the 0x00/0x00 + 0x10-biased one above.
DSP_WriteOscParam:
	dec 6, xsp
	pushw iz
	ld iz, de
	ld (xsp + 2), xbc
	ld (xsp + 6), wa
	ld wa, iz
	cp wa, 1:i3
	jrl z, DSP_WriteOscParam_UseCmd30
	ld bc, iz
	ldw wa, 0x8
	call DSP_DispatchData
	ld bc, iz
	ld wa, 1:i3
	call DSP_DispatchData
	ld wa, (xsp + 12)
	add wa, (xsp + 6)
	srl wa, 4
	and wa, 0xF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld wa, (xsp + 12)
	add wa, (xsp + 6)
	sll wa, 4
	and wa, 0xF0
	inc 8, wa
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld bc, iz
	ldw wa, 0x21
	call DSP_DispatchData
	ld bc, iz
	ldw wa, 0xA
	call DSP_DispatchData
	ld xwa, (xsp + 2)
	sra xwa, 1
	sra xwa, 16
	and xwa, 0x7F
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld xwa, (xsp + 2)
	sra xwa, 9
	and xwa, 0xFF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld xwa, (xsp + 2)
	sra xwa, 1
	and xwa, 0xFF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld xwa, (xsp + 2)
	sla xwa, 7
	and xwa, 0x80
	add xwa, 0x26
	extz wa
	ld bc, iz
	call DSP_DispatchData
	jr DSP_WriteOscParam_Return

; chip == 1: delegate to DSP_WriteParamCmd30.
DSP_WriteOscParam_UseCmd30:
	ld wa, iz
	ld bc, (xsp + 6)
	ld xde, (xsp + 2)
	calr DSP_WriteParamCmd30

; Restore IZ, drop the 6-byte frame, `retd 0x2`.
DSP_WriteOscParam_Return:
	popw iz
	inc 6, xsp
	retd 0x2

; Identical to DSP_WriteCoeffData_5B except the trailing tag is 0x26 instead of 0x15, i.e.
; the bare-coefficient writer for the oscillator address space.
DSP_WriteCoeffData_5B_Direct:	.include "includes/generated/cc900/DSP_WriteCoeffData_5B_Direct.s"	; C: cc900/dsp_control_routines.c

; A third variant: same 0x08 / 0x01 / index / (index<<4)+8 opener as DSP_WriteOscParam but
; the selector byte is 0x25 (not 0x21), the 24-bit value has a stacked OFFSET added to it
; before packing, and the trailing tag is 0x4C. `retd 0x6`. Has no chip-1 fallback -- it
; is chip-0 only. One caller, at 0x045560; the pointer 0x038922 also appears once in the
; dispatch data at 0x03CCA2.
DSP_WriteOscParam_Offset:
	dec 6, xsp
	pushw iz
	ld iz, de
	ld (xsp + 2), xbc
	ld (xsp + 6), wa
	ld bc, iz
	ldw wa, 0x8
	call DSP_DispatchData
	ld bc, iz
	ld wa, 1:i3
	call DSP_DispatchData
	ld wa, (xsp + 16)
	add wa, (xsp + 6)
	srl wa, 4
	and wa, 0xF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld wa, (xsp + 16)
	add wa, (xsp + 6)
	sll wa, 4
	and wa, 0xF0
	inc 8, wa
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld bc, iz
	ldw wa, 0x25
	call DSP_DispatchData
	ld xwa, (xsp + 12)
	add (xsp + 2), xwa
	ld bc, iz
	ldw wa, 0xA
	call DSP_DispatchData
	ld xwa, (xsp + 2)
	sra xwa, 1
	sra xwa, 16
	and xwa, 0x7F
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld xwa, (xsp + 2)
	sra xwa, 9
	and xwa, 0xFF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld xwa, (xsp + 2)
	sra xwa, 1
	and xwa, 0xFF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld xwa, (xsp + 2)
	sla xwa, 7
	and xwa, 0x80
	add xwa, 0x4C
	extz wa
	ld bc, iz
	call DSP_DispatchData
	popw iz
	inc 6, xsp
	retd 0x6
; 0x0389E1 -- routine entry.  Named DSP_AlgoDescriptor_Emit rather than DSP_AlgoSelect:
; that bare name already belongs to the unrelated routine at 0x030960, so the whole block
; (0x038A95 / 0x038ACD / 0x038B10 / 0x038B64) carries the _Emit prefix instead.
; Frame of 8 bytes, `retd 0xA`, returns HL.  Entry: DE = chip, BC = a sub-index,
; WA = an index, plus stacked arguments -- a table pointer at (xsp+20) and a type
; at (xsp+18).
; Body: calls DSP_TableWalk_Search(table, type, 0x78) to locate a descriptor, forms
; value = descriptor[0] + 3*subindex, then emits COMMAND 0x01, DATA 0x00, DATA
; value++, then either a five-DATA "type 0x63" sequence (0x00, 0x00, 0x20, 0x00,
; 0x00) or the normal index-carrying one, and finally a five-byte header that is
; either the fixed 0x08, 0x00, 0x80, 0xB4, 0x07 (sub-index 0) or a computed
; ((value >> 7) & 2) + 0x0C, (value >> 7) & 1, value*2, 0x04, 0x07.
; DEAD CODE: neither this address nor any of its labels is reachable -- a search of
; the payload disassembly and of the raw ROM finds no call, no jump and no pointer.
DSP_AlgoDescriptor_Emit:
	dec 8, xsp
	pushw iz
	ld iz, de
	ld (xsp + 6), bc
	ld (xsp + 8), wa
	ld xhl, (xsp + 20)
	ldw bc, 0x78
	lda xwa, (xsp + 4)
	push xwa
	ld xwa, xhl
	ld de, (xsp + 18)
	call DSP_TableWalk_Search
	ld wa, (xsp + 6)
	mul wa, 0x3
	ld bc, wa
	ld a, (xhl)
	and a, 0xFF
	extz wa
	add wa, bc
	ld (xsp + 2), wa
	ld bc, iz
	ld wa, 1:i3
	call DSP_DispatchCommand
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 2)
	incw 1, (xsp + 2)
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	cpw (xsp + 18), 0x63
	jr z, DSP_AlgoDescriptor_Emit_TypeEq63
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 16)
	add wa, (xsp + 8)
	srl wa, 4
	and wa, 0xF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 16)
	add wa, (xsp + 8)
	sll wa, 4
	and wa, 0xF0
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	jr DSP_AlgoDescriptor_Emit_WriteHeader

; The type == 0x63 arm: emit DATA 0x00, 0x00, 0x20, 0x00, 0x00 instead of the index pair.
DSP_AlgoDescriptor_Emit_TypeEq63:
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0x20
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl

; Sub-index 0: emit the fixed header 0x08, 0x00, 0x80, 0xB4, 0x07.
DSP_AlgoDescriptor_Emit_WriteHeader:
	cpw (xsp + 6), 0x0
	jr nz, DSP_AlgoDescriptor_Emit_WriteHeaderNonZero
	ld bc, iz
	ldw wa, 0x8
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0x80
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0xB4
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 7:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	jr DSP_AlgoDescriptor_Emit_HeaderReturn

; Sub-index non-zero: emit the computed header derived from bit 7 of the descriptor value.
DSP_AlgoDescriptor_Emit_WriteHeaderNonZero:
	ld wa, (xsp + 2)
	srl wa, 7
	and wa, 0x2
	add wa, 0xC
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 2)
	srl wa, 7
	and wa, 0x1
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 2)
	add wa, wa
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 4:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 7:i3
	call DSP_DispatchData
	ld (xsp + 4), hl

; Return the accumulated status in HL, unwind the 8-byte frame, `retd 0xA`.
DSP_AlgoDescriptor_Emit_HeaderReturn:
	ld hl, (xsp + 4)
	popw iz
	inc 8, xsp
	retd 0xA
; No symbol at this address in EITHER source -- genuinely new; the existing
; DSP_OscAlgoSelect_* labels at 0x038C60 / 0x038CB5 are its internal branch targets.
; The oscillator-address-space twin of DSP_AlgoSelect: same DSP_TableWalk_Search(.., 0x78)
; descriptor lookup and the same value = descriptor[0] + 3*subindex, but after COMMAND
; 0x01 / DATA 0x00 / DATA value++ it emits the 0x08 / 0x01 / index-pair / 0x21 opener that
; DSP_WriteOscParam uses, and its fixed header ends 0x08 rather than 0x07.
; DEAD CODE: unreferenced anywhere in the payload, same evidence as DSP_AlgoSelect.
DSP_OscAlgoSelect:
	dec 8, xsp
	pushw iz
	ld iz, de
	ld (xsp + 6), bc
	ld (xsp + 8), wa
	ld xhl, (xsp + 20)
	ldw bc, 0x78
	lda xwa, (xsp + 4)
	push xwa
	ld xwa, xhl
	ld de, (xsp + 18)
	call DSP_TableWalk_Search
	ld wa, (xsp + 6)
	mul wa, 0x3
	ld bc, wa
	ld a, (xhl)
	and a, 0xFF
	extz wa
	add wa, bc
	ld (xsp + 2), wa
	ld bc, iz
	ld wa, 1:i3
	call DSP_DispatchCommand
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 2)
	incw 1, (xsp + 2)
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0x8
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 1:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 18)
	add wa, (xsp + 8)
	srl wa, 4
	and wa, 0xF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 16)
	add wa, (xsp + 8)
	sll wa, 4
	and wa, 0xF0
	inc 8, wa
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0x21
	call DSP_DispatchData
	ld (xsp + 4), hl
	cpw (xsp + 6), 0x0
	jr nz, DSP_OscAlgoSelect_WriteHeaderNonZero
	ld bc, iz
	ldw wa, 0x8
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0x80
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0xB4
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0x8
	call DSP_DispatchData
	ld (xsp + 4), hl
	jr DSP_OscAlgoSelect_Return

; Sub-index non-zero: the computed five-byte header, terminating in 0x08.
DSP_OscAlgoSelect_WriteHeaderNonZero:
	ld wa, (xsp + 2)
	srl wa, 7
	and wa, 0x2
	add wa, 0xC
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 2)
	srl wa, 7
	and wa, 0x1
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 2)
	add wa, wa
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 4:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0x8
	call DSP_DispatchData
	ld (xsp + 4), hl

; Return HL, unwind the 8-byte frame, `retd 0xA`.
DSP_OscAlgoSelect_Return:
	ld hl, (xsp + 4)
	popw iz
	inc 8, xsp
	retd 0xA
; No symbol at this address in EITHER source -- genuinely new; DSP_TuneOffset_Increment
; (0x038CF6) and DSP_TuneOffset_WriteSequence (0x038CF9, just past this region's end) are
; its internal branch targets.
; Entry: BC = chip, XDE = a table pointer, plus stacked arguments; frame of 8 bytes.
; Calls DSP_TableWalk_Search(table, arg, 0x79) -- note 0x79, one more than the 0x78 the
; two AlgoSelect routines use -- takes the first byte of the descriptor as a base value,
; and then adjusts it by +1, -1 or not at all depending on two stacked flags before
; emitting the write sequence (COMMAND 0x01, DATA 0x01, DATA 0x60, ...) that continues
; past 0x038CF8. Confidence is medium only because the write sequence itself falls outside
; this region and was not read line by line.
; DEAD CODE: unreferenced anywhere in the payload, same evidence as the two above.
DSP_TuneOffset:
	dec 8, xsp
	pushw iz
	ld iz, bc
	ld (xsp + 6), xwa
	ldw bc, 0x79
	lda xwa, (xsp + 4)
	push xwa
	ld xwa, xde
	ld de, (xsp + 20)
	call DSP_TableWalk_Search
	ld xde, xhl
	ld a, (xde)
	extz wa
	ld (xsp + 2), wa
	cpw (xsp + 14), 0x0
	jr z, DSP_TuneOffset_WriteSequence
	ld wa, (xsp + 16)
	cp wa, 1:i3
	jr z, DSP_TuneOffset_Increment
	cp wa, 0:i3
	jr nz, DSP_TuneOffset_WriteSequence
	decm 1, (xsp + 2)
	jr DSP_TuneOffset_WriteSequence

; The "+1" adjustment arm of DSP_TuneOffset.
DSP_TuneOffset_Increment:
	incw 1, (xsp + 2)

; Tail of the unnamed routine that starts at 0x038CBE (which has NO symbol in either source --
; see [UNCERTAIN]).  Emits a fixed 15-transfer packet to the DSP selected by IZ:
;   cmd 0x01, data 0x01, 0x60, 0x00, 0x00,
;   data ((t>>4)&0x0F)+0x10, data (t<<4)&0xF0,     t = the byte fetched by DSP_TableWalk_Search
;   data 0x00, data 0x0A,
;   data (P>>17)&0x7F, data (P>>9)&0xFF, data (P>>1)&0xFF, data ((P<<7)&0x80)+0x15,
;   cmd 0x03
; where P is the 32-bit parameter the caller passed in XWA.  Note the coefficient wire format:
; a 24-bit value split MSB-first over four bytes as P[23:17] / P[16:9] / P[8:1] / P[0]<<7, with
; 0x15 OR-ed into the last byte as a tag.  The word at (XSP+4) accumulates the status returned
; by each DSP_DispatchCommand / DSP_DispatchData call and is the routine's return value in HL.
; Falls in from DSP_TuneOffset_Increment (0x038CF6) and from the +/-1 adjustment above it.
DSP_TuneOffset_WriteSequence:
	ld bc, iz
	ld wa, 1:i3
	call DSP_DispatchCommand
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 1:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0x60
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 2)
	srl wa, 4
	and wa, 0xF
	add wa, 0x10
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld wa, (xsp + 2)
	sll wa, 4
	and wa, 0xF0
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 0:i3
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ldw wa, 0xA
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld xwa, (xsp + 6)
	sra xwa, 1
	sra xwa, 16
	and xwa, 0x7F
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld xwa, (xsp + 6)
	sra xwa, 9
	and xwa, 0xFF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld xwa, (xsp + 6)
	sra xwa, 1
	and xwa, 0xFF
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld xwa, (xsp + 6)
	sla xwa, 7
	and xwa, 0x80
	add xwa, 0x15
	extz wa
	ld bc, iz
	call DSP_DispatchData
	ld (xsp + 4), hl
	ld bc, iz
	ld wa, 3:i3
	call DSP_DispatchCommand
	ld (xsp + 4), hl
	ld hl, (xsp + 4)
	popw iz
	inc 8, xsp
	retd 0x4

; Seeds the DSP configuration-buffer POOL and starts the task that consumes it.
;   Kernel_StartTask(3)
;   MsgQueue_Send(queue 1, 0x045324)
;   MsgQueue_Send(queue 1, 0x045446)     [tail-jump]
; i.e. exactly TWO 0x122-byte buffers are ever in circulation.  Called once, from DSP_Reset
; (0x0360F9).  Task 3's body is the loop at 0x038E0F, reached through the thunk
; DSP_WaitForTaskSlot_Data (0x036327) = `jp 0x038E0F`.
; (Now labelled Task3_EnterDspApplyLoop -> DSP_State_ApplyTask; the thunk is found through record 3 of
; TaskSched_TaskDescriptorTable.)
; The pool size of two is the reason DSP_State_ApplyBuf can wedge -- see [UNCERTAIN].
DSP_State_DmaLoadPresets:	.include "includes/generated/cc900/DSP_State_DmaLoadPresets.s"	; C: cc900/dsp_control_routines_kernel.c
; TASK BODY (task id 3), not data -- the name is wrong, see [UNCERTAIN].  Never returns:
;   forever {
;     XIZ = MsgQueue_ReceiveBlocking(queue 2);        // BLOCKING, no timeout
;     DSP_State_ApplyAll(XIZ);                // 0x036E3D: pushes the image to the DSPs
;     XIZ->[0x0120] = 0;                      // clear the "request pending" flag
;     MsgQueue_Send(queue 1, XIZ);            // return the buffer to the free pool
;   }
; The only producer for queue 2 is DSP_State_ApplyBuf (0x038E31); the only consumer of queue 1
; is DSP_State_ApplyBuf.  Entered through the thunk at 0x036327.
; (Renamed DSP_State_InlineData -> DSP_State_ApplyTask; the thunk is Task3_EnterDspApplyLoop.)
; DSP_State_ApplyTask: Task 3's body, never returns: forever XIZ = MsgQueue_ReceiveBlocking(queue 2), DSP_State_ApplyAll(XIZ),
;   buf[0x120] = 0, MsgQueue_Send(queue 1, XIZ). Basis: task table + thunk + body -- record 3 of the task descriptor
;   table is Task3_EnterDspApplyLoop = `jp` here; DSP_State_DmaLoadPresets spawns task 3 and seeds queue 1 with the two
;   buffers.
DSP_State_ApplyTask:	.include "includes/generated/cc900/DSP_State_ApplyTask.s"	; C: cc900/dsp_control_routines_kernel.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_State_ApplyTask_Loop, DSP_State_ApplyTask + 1

; Hands the caller's 0x91-word (290-byte) DSP configuration image to the apply task.
; In: XWA = address of the caller's image (callers pass 0x00448E, the live config block).
; Grabs a buffer:  XHL = MsgQueue_Receive_NoBlock(queue 2)   -- non-blocking; if a request is still
; queued it is RE-USED, i.e. the older request is silently overwritten.
;                  if zero, XHL = MsgQueue_ReceiveBlocking(queue 1)  -- BLOCKING, NO TIMEOUT.
; The chosen buffer address is parked in the global at 0x004A3A.  Then ldirw 0x91 words from
; the caller's image into it, set buf[0x0120] = 1 ("request pending"), MsgQueue_Send(queue 2).
; Callers: DSP_ApplyAlgoForVoiceType (0x03608C), DSP_ApplyConfig (0x03616A, three call sites)
; and DSP_ReconfigAndStatus (0x0361C5).
; ** The blocking Receive at 0x038E44 is the one unbounded wait in this region. **
DSP_State_ApplyBuf:	.include "includes/generated/cc900/DSP_State_ApplyBuf.s"	; C: cc900/dsp_control_routines_b_kernel.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_State_ApplyBuf_DoCopy, DSP_State_ApplyBuf + 27

; Synchronous variant used only at reset (called from 0x0360EF).  Copies the caller's image
; (XWA) straight into the fixed buffer 0x045324, parks that address in the global 0x004A3E,
; sets buf[0x0120] = 1, calls DSP_State_ApplyAll (0x036E3D) INLINE on the caller's stack -- no
; task, no message queue -- then clears buf[0x0120] and returns.  This is the path that cannot
; block, which is why reset uses it.
DSP_State_LoadAndApplyAll:	.include "includes/generated/cc900/DSP_State_LoadAndApplyAll.s"	; C: cc900/dsp_control_routines_b.c

; NOT data -- a five-instruction table fetch, twin of DSP_ParamFetch_SingleTable.  The name is
; wrong (see [UNCERTAIN]).
;   XHL = *(uint32*)(0x0129A3 + 4*XBC)
; XBC is the 0..99 parameter value; the table has 100 entries.  This is the decoder for
; byte-code opcode 0x61 (arm 0x03CB8E), whose result goes straight to DSP_WriteOscParam.
; ★ Renamed 2026-09-25 from DSP_State_LoadAndApply_InlineData: header: table fetch XHL = *(0x0129A3 + 4*XBC), the decoder of byte-code opcode 0x61.
DSP_ParamFetch_Op61Table:	.include "includes/generated/cc900/DSP_ParamFetch_Op61Table.s"	; C: cc900/dsp_control_routines.c

; XHL = *(uint32*)(0x012B33 + 4*XBC).  100-entry table; XBC = 0..99 parameter value.
; Decoder for opcode 0x62.  The table is monotonically increasing and roughly exponential
; (0, 74, 83, 93, 105, 118, 132, 148, ... 4194304, 4706086, 5280316, 5924612), i.e. a
; log-spaced Q23 coefficient ladder ending just under 2^23 * 0.706.
DSP_ParamFetch_SingleTable:	.include "includes/generated/cc900/DSP_ParamFetch_SingleTable.s"	; C: cc900/dsp_control_routines.c

; Same idea as above but the table is chosen by an algorithm-type byte read from the stream.
; In:  XWA = address of the caller's stream cursor, XBC = 0..99 parameter value.
; Out: XHL = the 32-bit coefficient; the cursor is advanced by ONE byte (the type byte).
;   type 0 -> 0x012483[XBC]   (100 entries)
;   type 1 -> 0x012613[XBC]   (100 entries)
;   type 2 -> 0x0127A3[XBC]   (128 entries)
;   anything else -> XHL is left UNDEFINED (fall straight through to the epilogue).
; Decoder for opcode 0x63; result goes to DSP_WriteFreqParam_AlgoType (0x03846C).
DSP_ParamFetch_AlgoTypeTable:	.include "includes/generated/cc900/DSP_ParamFetch_AlgoTypeTable.s"	; C: cc900/dsp_control_routines.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_ParamFetch_AlgoType1, DSP_ParamFetch_AlgoTypeTable + 30
	.set	DSP_ParamFetch_AlgoType2, DSP_ParamFetch_AlgoTypeTable + 44
	.set	DSP_ParamFetch_AlgoTypeReturn, DSP_ParamFetch_AlgoTypeTable + 56

; Decoder for opcode 0x79.  Reads a type byte from the stream, fetches 0x0127A3[XBC], and runs
; it through the double-precision helpers before converting back to an integer.
; In: XWA = &cursor, XBC = 0..99 parameter value.  Out: XHL = 32-bit result; cursor += 1.
;   type != 1 : the fetched word is two's-complement NEGATED first, then
;               FP_SP_CallWithBuf8 -> FP_ftod -> FP_dmul(const 0x012CC3)
;               -> FP_DP_DecodeToInt
;   type == 1 : same chain, no negation, constant 0x012CCB
; Both constants decode as the double 0.552.  I have NOT proved the exact arithmetic because
; the FP helper names are suspect (see [UNCERTAIN]); the control flow and the operands are
; certain, the formula is not.
DSP_AlgoParam_Decode:
	lda xsp, (xsp - 28)
	push xiz
	ld (xsp + 28), xwa
	ld xwa, (xsp + 28)
	ld xwa, (xwa)
	ld (xsp + 4), xwa
	ld a, (xwa)
	cp a, 1:i3
	jr z, DSP_AlgoParam_Decode_Type1
	sll xbc, 2
	ld xwa, DSP_FreqParamCurve_Algo2
	add xwa, xbc
	ld xwa, (xwa)
	cpl wa
	cplw_erp 0xE2
	inc 1, xwa
	ld (xsp + 20), xwa
	lda xbc, (xsp + 20)
	lda xwa, (xsp + 8)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 8)
	lda xwa, (xsp + 12)
	call FP_ftod
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_AlgoParam_Decode_0p552:24)
	lda xwa, (xsp + 12)
	call FP_dmul
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 24)
	call FP_DP_DecodeToInt
	jr DSP_AlgoParam_Decode_Return

; type == 1 arm: no negation, constant pool entry 0x012CCB.
DSP_AlgoParam_Decode_Type1:
	sll xbc, 2
	ld xiz, 0x127A3
	add xiz, xbc
	lda xwa, (xsp + 8)
	ld xbc, xiz
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 8)
	lda xwa, (xsp + 12)
	call FP_ftod
	lda xbc, (xsp + 12)
	lda xde, (FP_Const_0p552_Add:24)
	lda xwa, (xsp + 12)
	call FP_dmul
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 24)
	call FP_DP_DecodeToInt

; Advance the caller's cursor by one byte, load the result into XHL, unwind the 0x1C-byte frame.
DSP_AlgoParam_Decode_Return:
	ld xwa, 1:i3
	add (xsp + 4), xwa
	ld xwa, (xsp + 28)
	ld xbc, (xsp + 4)
	ld (xwa), xbc
	ld xhl, (xsp + 24)
	pop xiz
	lda xsp, (xsp + 28)
	ret

; Decoder for opcode 0x64; result goes to DSP_WriteFreqParam (0x038539).
; In: XWA = &cursor, XBC = 0..99 parameter value.
; Consumes ONE 3-byte stream value v (DSP_StreamDecode_3ByteWord); takes only its top byte
; d = (v>>8) & 0xFF, then
;       XHL = ((XBC << 23) / d) - 0x00800000
; i.e. a Q23 signed quantity centred on zero: parameter/d relative to 1.0, minus 1.0.  The
; `sla 5 / sla 0` pair is <<21 and the later `sla 2` completes the <<23 after the divide.
; Writes the advanced cursor back through XWA.
DSP_PitchParam_Scale:
	lda xsp, (xsp - 12)
	push xiz
	ld (xsp + 8), xbc
	ld (xsp + 12), xwa
	ld xwa, (xsp + 12)
	ld xiz, (xwa)
	lda xwa, (xsp + 4)
	ld xbc, xwa
	ld xwa, xiz
	call DSP_StreamDecode_3ByteWord
	ld xiz, xhl
	ld xwa, (xsp + 4)
	sra xwa, 8
	and_erpw 0xE2, 0xFF, 0x00
	ld (xsp + 4), xwa
	ld xwa, (xsp + 8)
	sla xwa, 5
	sla xwa, 16
	ld xbc, (xsp + 4)
	call Long_SignedDiv
	sla xhl, 2
	add xhl, 0xFF800000
	ld xwa, (xsp + 12)
	ld (xwa), xiz
	pop xiz
	lda xsp, (xsp + 12)
	ret

; Decoder for opcode 0x65 (result -> DSP_WriteOscParam).  BYTE-FOR-BYTE IDENTICAL to
; DSP_VolScale_B (0x03A282); see [UNCERTAIN] about the "Volume" in the name.
; In: XWA = &cursor, XBC = 0..99 parameter value.  Out: XHL = Q23 coefficient; cursor += 1.
; Consumes ONE byte (the curve family) and evaluates a continuous 4- or 5-segment piecewise
; rational curve.  With f = 44100 * numerator / denominator (44100 == 0xAC44 == the sample
; rate, and the <<23 is the Q23 scaling):
;   family 0  (divisors 441000 = 44100*10 and 220500 = 44100*5)  -- 0.1 Hz steps then 0.2 Hz:
;       x<=50  f = x/10           x<=75  f = (x-25)/5
;       x<=88  f = (4x-250)/5     else   f = (9x-690)/5          => 0 .. 40.2 Hz
;   family 1  (divisor 44100)     -- direct Hz:
;       x<=10  f = x             x<=19  f = 10x-90    x<=64  f = 20x-280
;       x<=87  f = 400x-24800    else   f = 800x-59600            => 0 .. 19600 Hz
;   family 2  (denominator varies with x, so this is a warped / bilinear mapping):
;       x<=50  f = 44100*x/(4000-2x)          x<=75  f = 44100*(x-25)/(2050-2x)
;       x<=88  f = 44100*(4x-250)/(2500-8x)   else   f = 44100*(9x-690)/(3380-18x)
;                                                                => 0 .. ~5.5 kHz
; Families 0 and 2 are continuous at every knot; family 1 has a 200 Hz step at x=64.
; Any family byte other than 0/1/2 falls through with XHL undefined.
DSP_VolumeParam_Scale:	.include "includes/generated/cc900/DSP_VolumeParam_Scale.s"	; C: cc900/dsp_control_routines_e_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_VolScale_Algo0_Seg2, DSP_VolumeParam_Scale + 57
	.set	DSP_VolScale_Algo0_Seg3, DSP_VolumeParam_Scale + 91
	.set	DSP_VolScale_Algo0_Seg4, DSP_VolumeParam_Scale + 128
	.set	DSP_VolScale_Algo1_Seg1, DSP_VolumeParam_Scale + 159
	.set	DSP_VolScale_Algo1_Seg2, DSP_VolumeParam_Scale + 187
	.set	DSP_VolScale_Algo1_Seg3, DSP_VolumeParam_Scale + 228
	.set	DSP_VolScale_Algo1_Seg4, DSP_VolumeParam_Scale + 270
	.set	DSP_VolScale_Algo1_Seg5, DSP_VolumeParam_Scale + 315
	.set	DSP_VolScale_Algo2_Seg1, DSP_VolumeParam_Scale + 352
	.set	DSP_VolScale_Algo2_Seg2, DSP_VolumeParam_Scale + 388
	.set	DSP_VolScale_Algo2_Seg3, DSP_VolumeParam_Scale + 435
	.set	DSP_VolScale_Algo2_Seg4, DSP_VolumeParam_Scale + 486
	.set	DSP_VolScale_Return, DSP_VolumeParam_Scale + 533

; Decoder for opcodes 0x66 and 0x21 (result -> DSP_WriteOscParam).  Plain linear interpolation
; between two 24-bit endpoints held in the stream.
; In: XWA = &cursor, XBC = 0..99 blend value.  Out: XHL; cursor += 6 (two 3-byte values).
;       A = value[0], B = value[1]
;       XHL = (A>>8) + ((((B - A) >> 8) * XBC) / 99)
; The >>8 undoes the left-justification applied by DSP_StreamDecode_3ByteWord; the /99 (0x63)
; is the 0..99 parameter normalisation.
; BYTE-FOR-BYTE IDENTICAL to DSP_FreqInterp_2Point (0x0394CD) and DSP_ParamInterp_2Point_B
; (0x03A22A) -- three copies of the same 0x58-byte function, verified by memcmp.
DSP_ParamInterp_2Point:	.include "includes/generated/cc900/DSP_ParamInterp_2Point.s"	; C: cc900/dsp_control_routines_c_runtime.c

; Decoder for opcode 0x67; result -> DSP_WriteOscParam_Offset (0x038922).
; In: XWA = &cursor, XBC = 0..99 value.  Out: XHL; cursor += 3.
;       base = (value[0] >> 8) & 0xFF
;       XHL  = (XBC * 44100) / 1000 + base
; 44100/1000 = 44.1 samples per millisecond, so this is "base plus XBC milliseconds expressed
; in samples at the 44.1 kHz DSP rate".
DSP_ParamInterp_FPScale:
	lda xsp, (xsp - 12)
	push xiz
	ld (xsp + 8), xbc
	ld (xsp + 12), xwa
	ld xwa, (xsp + 12)
	ld xiz, (xwa)
	lda xwa, (xsp + 4)
	ld xbc, xwa
	ld xwa, xiz
	call DSP_StreamDecode_3ByteWord
	ld xiz, xhl
	ld xwa, (xsp + 4)
	sra xwa, 8
	and_erpw 0xE2, 0xFF, 0x00
	ld (xsp + 4), xwa
	ld xwa, (xsp + 8)
	ld xbc, 0xAC44
	call Math_Multiply32
	ld xwa, xhl
	ld xbc, 0x3E8
	call Long_SignedDiv
	add xhl, (xsp + 4)
	ld xwa, (xsp + 12)
	ld (xwa), xiz
	pop xiz
	lda xsp, (xsp + 12)
	ret

; Decoder for opcode 0x68; result -> DSP_WriteFreqParam.
; In: XWA = &cursor, XBC = 0..99 value.  Out: XHL; cursor += 3.
;       XHL = (XBC * ((value[0] >> 8) & 0xFF)) / 180
; The /180 (0xB4) rather than /99 is unusual -- 180 reads as degrees, which would make this a
; phase parameter, but I have not confirmed that from the DSP side.
DSP_ParamInterp_Div0xB4:
	lda xsp, (xsp - 12)
	push xiz
	ld (xsp + 8), xbc
	ld (xsp + 12), xwa
	ld xwa, (xsp + 12)
	ld xiz, (xwa)
	lda xwa, (xsp + 4)
	ld xbc, xwa
	ld xwa, xiz
	call DSP_StreamDecode_3ByteWord
	ld xiz, xhl
	ld xwa, (xsp + 4)
	sra xwa, 8
	and_erpw 0xE2, 0xFF, 0x00
	ld (xsp + 4), xwa
	ld xbc, (xsp + 8)
	call Math_Multiply32
	ld xwa, xhl
	ld xbc, 0xB4
	call Long_SignedDiv
	ld xwa, (xsp + 12)
	ld (xwa), xiz
	pop xiz
	lda xsp, (xsp + 12)
	ret

; Decoder for opcode 0x69; result -> DSP_WriteOscParam.  Takes NO stream field -- it works
; purely on XBC (the 0..99 value), which is stashed at (XSP+0x40) and converted to float by
; FP_SP_CallWithBuf8.
; Two branches on the value: x <= 75 (0x4B) uses the constant group at 0x012CD3..0x012CE7
; (30, 44100, 3307500 = 44100*75, 75, 1800, and the double 2.0); x > 75 uses 0x012CEF..0x012D03
; (30, 44100, 65091600, 24, 576, 2.0).  Both branches end in the same five-push call to
; FP_pow with the double 2.0 as one operand -- which is almost certainly
; pow(2.0, y) (see [UNCERTAIN]) -- then FP_dtof, then a shared finalisation.
; Frame is 0x44 bytes; returns XHL = the 32-bit result read back from (XSP+0x38).
; I am naming the SHAPE (two-range exponential curve driven by the sample rate 44100) with
; confidence; I am NOT claiming the routine controls "volume".
DSP_VolumeCurve_FP:
	lda xsp, (xsp - 68)
	ld (xsp + 64), xbc
	ld xwa, (xsp + 64)
	cp xwa, 0x4B
	jrl gt, DSP_VolumeCurve_FP_HighRange
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 36)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_VolumeCurve_FP_30:24)
	lda xwa, (xsp + 36)
	call FP_fmul
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_VolumeCurve_FP_SampleRate:24)
	lda xwa, (xsp + 36)
	call FP_fmul
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_VolumeCurve_FP_3307500:24)
	lda xwa, (xsp + 36)
	call FP_fadd
	lda xbc, (FPConst_DSP_VolumeCurve_FP_75:24)
	lda xde, (xsp + 36)
	lda xwa, (xsp + 36)
	call FP_fsub
	lda xbc, (FPConst_DSP_VolumeCurve_FP_1800:24)
	lda xde, (xsp + 36)
	lda xwa, (xsp + 36)
	call FP_fdiv
	lda xbc, (xsp + 36)
	lda xwa, (xsp + 28)
	call FP_ftod
	lda xiy, (xsp + 28)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_VolumeCurve_FP_2:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 64)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 48)
	lda xwa, (xsp + 60)
	call FP_dtof
	jrl DSP_VolumeCurve_FP_Finalize

; x > 75 arm; constant group 0x012CEF..0x012D03.
DSP_VolumeCurve_FP_HighRange:
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 36)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_VolumeCurve_FP_HighRange_30:24)
	lda xwa, (xsp + 36)
	call FP_fmul
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_VolumeCurve_FP_HighRange_SampleRate:24)
	lda xwa, (xsp + 36)
	call FP_fmul
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_VolumeCurve_FP_HighRange_65091600:24)
	lda xwa, (xsp + 36)
	call FP_fsub
	lda xbc, (FPConst_DSP_VolumeCurve_FP_HighRange_24:24)
	lda xde, (xsp + 36)
	lda xwa, (xsp + 36)
	call FP_fsub
	lda xbc, (FPConst_DSP_VolumeCurve_FP_HighRange_576:24)
	lda xde, (xsp + 36)
	lda xwa, (xsp + 36)
	call FP_fdiv
	lda xbc, (xsp + 36)
	lda xwa, (xsp + 28)
	call FP_ftod
	lda xiy, (xsp + 28)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_VolumeCurve_FP_HighRange_2:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 56)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 40)
	lda xwa, (xsp + 60)
	call FP_dtof

; Shared tail: FP_fmul with the constant at 0x012D0B, then FP_ftoi to
; produce the integer result at (XSP+0x38); unwind the 0x44-byte frame.
DSP_VolumeCurve_FP_Finalize:
	lda xbc, (xsp + 60)
	lda xde, (FPConst_DSP_VolumeCurve_FP_Finalize_Q23One:24)
	lda xwa, (xsp + 36)
	call FP_fmul
	lda xbc, (xsp + 36)
	lda xwa, (xsp + 56)
	call FP_ftoi
	ld xhl, (xsp + 56)
	lda xsp, (xsp + 68)
	ret

; Decoder for opcode 0x6A; result -> DSP_WriteFreqParam.  Despite the _FP suffix this routine
; is pure INTEGER arithmetic -- there is no floating point in it at all.
; In: XBC = 0..99 value (copied to IZ).  Out: XHL.  Consumes nothing from the stream.
;   x <= 20  XHL = (x<<23)          / (4000 - 2x)
;   x <= 50  XHL = ((x-10)<<23)     / (2020 - 2x)
;   else     XHL = ((11x-390)<<15)  / (8780 - 22x), then <<8
; Continuous at both knots (checked: x=20 gives 10/1980 == 20/3960; x=50 gives 40/1920 ==
; 160/7680).  Full range 0 .. 0.1059 in Q23, i.e. 0 .. ~4.67 kHz if read as f/44100.
DSP_FreqCurve_FP:	.include "includes/generated/cc900/DSP_FreqCurve_FP.s"	; C: cc900/dsp_control_routines_c_runtime.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_FreqCurve_FP_Seg2, DSP_FreqCurve_FP + 38
	.set	DSP_FreqCurve_FP_Seg3, DSP_FreqCurve_FP + 83
	.set	DSP_FreqCurve_FP_Return, DSP_FreqCurve_FP + 142

; Decoder for opcode 0x6B; result -> DSP_WriteFreqParam.
; BYTE-FOR-BYTE IDENTICAL to DSP_ParamInterp_2Point (0x039206) -- verified by memcmp over all
; 0x58 bytes.  Same contract: two 3-byte stream values, XHL = A>>8 + ((B-A)>>8)*XBC/99,
; cursor += 6.  A separate copy exists only because the compiler emitted it per call site.
DSP_FreqInterp_2Point:	.include "includes/generated/cc900/DSP_FreqInterp_2Point.s"	; C: cc900/dsp_control_routines_c_runtime.c

; Decoder for opcode 0x6C; result -> DSP_WriteFreqParam.  Interpolates between the TOP BYTES of
; two stream values and then adds a caller-supplied bias.
; In: XWA = &cursor, XBC = 0..99 value, XDE = bias.  Out: XHL; cursor += 6.
;       a = (value[0]>>8)&0xFF ;  b = (value[1]>>8)&0xFF
;       XHL = (XDE + a + ((b - a) * XBC) / 99) << 8
; The final <<8 re-left-justifies the result into the 24-bit-in-32 stream format.
DSP_ParamInterp_3Point_WithOffset:
	lda xsp, (xsp - 20)
	push xiz
	ld (xsp + 12), xde
	ld (xsp + 16), xbc
	ld (xsp + 20), xwa
	ld xwa, (xsp + 20)
	ld xiz, (xwa)
	lda xwa, (xsp + 8)
	ld xbc, xwa
	ld xwa, xiz
	call DSP_StreamDecode_3ByteWord
	ld xiz, xhl
	lda xwa, (xsp + 4)
	ld xbc, xwa
	ld xwa, xiz
	call DSP_StreamDecode_3ByteWord
	ld xiz, xhl
	ld xwa, (xsp + 8)
	sra xwa, 8
	and_erpw 0xE2, 0xFF, 0x00
	ld (xsp + 8), xwa
	ld xwa, (xsp + 4)
	sra xwa, 8
	and_erpw 0xE2, 0xFF, 0x00
	ld (xsp + 4), xwa
	sub xwa, (xsp + 8)
	ld xbc, (xsp + 16)
	call Math_Multiply32
	ld xwa, xhl
	ld xbc, 0x63
	call Long_SignedDiv
	ld xwa, (xsp + 12)
	add xwa, (xsp + 8)
	add xwa, xhl
	sla xwa, 8
	ld xbc, (xsp + 20)
	ld (xbc), xiz
	ld xhl, xwa
	pop xiz
	lda xsp, (xsp + 20)
	ret

; Decoder for opcode 0x6D; result -> DSP_WriteOscParam.  Same shape as DSP_VolumeCurve_FP:
; no stream field, branch at x > 89 (0x59), a chain of single- and double-precision helpers
; over the constant groups 0x012D0F..0x012D2B (low range: 1, 441, 10, 0.427042, 1) and
; 0x012D33..0x012D4F (high range: 44100, 3924900 = 44100*89, 10, 0.427042, 1), both ending in
; the FP_pow / FP_dtof pair and a shared finalisation.
; The 441 / 44100 / 3924900 constants and the 0.427042 exponent-like factor say this is a
; time-constant or decay curve computed against the sample rate; "reverb" is plausible from the
; opcode's neighbours but is NOT proved here.  Frame 0x44 bytes; result in XHL.
DSP_ReverbCurve_FP:
	lda xsp, (xsp - 68)
	ld (xsp + 64), xbc
	ld xwa, (xsp + 64)
	cp xwa, 0x59
	jr gt, DSP_ReverbCurve_FP_HighRange
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 28)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 28)
	lda xde, (FPConst_DSP_ReverbCurve_FP_1:24)
	lda xwa, (xsp + 28)
	call FP_fadd
	lda xbc, (xsp + 28)
	lda xwa, (xsp + 40)
	call FP_ftod
	lda xbc, (xsp + 40)
	lda xde, (FPConst_DSP_ReverbCurve_FP_441:24)
	lda xwa, (xsp + 40)
	call FP_dmul
	lda xbc, (FPConst_DSP_ReverbCurve_FP_10:24)
	lda xde, (xsp + 40)
	lda xwa, (xsp + 40)
	call FP_ddiv
	lda xiy, (xsp + 40)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_ReverbCurve_FP_0p4270422:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 64)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (FPConst_DSP_ReverbCurve_FP_1_2:24)
	lda xde, (xsp + 48)
	lda xwa, (xsp + 40)
	call FP_dsub
	lda xbc, (xsp + 40)
	lda xwa, (xsp + 60)
	call FP_dtof
	jr DSP_ReverbCurve_FP_Finalize

; x > 89 arm; constant group 0x012D33..0x012D4F.
DSP_ReverbCurve_FP_HighRange:
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 28)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 28)
	lda xde, (FPConst_DSP_ReverbCurve_FP_HighRange_SampleRate:24)
	lda xwa, (xsp + 28)
	call FP_fmul
	lda xbc, (xsp + 28)
	lda xde, (FPConst_DSP_ReverbCurve_FP_HighRange_3924900:24)
	lda xwa, (xsp + 28)
	call FP_fsub
	lda xbc, (FPConst_DSP_ReverbCurve_FP_HighRange_10:24)
	lda xde, (xsp + 28)
	lda xwa, (xsp + 28)
	call FP_fdiv
	lda xbc, (xsp + 28)
	lda xwa, (xsp + 40)
	call FP_ftod
	lda xiy, (xsp + 40)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_ReverbCurve_FP_HighRange_0p4270422:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 48)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (FPConst_DSP_ReverbCurve_FP_HighRange_1:24)
	lda xde, (xsp + 32)
	lda xwa, (xsp + 40)
	call FP_dsub
	lda xbc, (xsp + 40)
	lda xwa, (xsp + 60)
	call FP_dtof

; Shared tail: FP_fmul(0x012D4F), FP_ftoi, result from (XSP+0x38).
DSP_ReverbCurve_FP_Finalize:
	lda xbc, (xsp + 60)
	lda xde, (FPConst_DSP_ReverbCurve_FP_Finalize_Q23One:24)
	lda xwa, (xsp + 28)
	call FP_fmul
	lda xbc, (xsp + 28)
	lda xwa, (xsp + 56)
	call FP_ftoi
	ld xhl, (xsp + 56)
	lda xsp, (xsp + 68)
	ret

; Decoder for opcode 0x6E; result -> DSP_WriteOscParam.  The most elaborate decoder here:
; it consumes TWO 3-byte stream values AND the 0..99 value, and mixes them in floating point.
; In: XWA = &cursor, XBC = 0..99 value.  Out: XHL; cursor += 6.
; Sequence (operands certain, arithmetic inferred from the helper names):
;   value[0] -> float, combined with the constants at 0x012D53 (32768) and 0x012D57 (65536)
;   value[1] -> float, top byte kept as an integer at (XSP+0x24)
;   XBC      -> float
;   the three are combined through FP_fsub / FP_fmul / FP_fadd against
;   0x012D5B (99), 0x012D5F (44100), 0x012D63 (99), 0x012D67 (2376)
;   -> promoted to double, FP_pow with the double at 0x012D6B (2.0)
;   -> FP_dtof, then FP_fmul(0x012D73) and FP_ftoi.
; The 32768/65536/99/44100 group is the same normalisation vocabulary as the rest of the file.
; The advanced cursor is written back BEFORE the finalisation (at 0x0397CD).
DSP_ParamInterp_FPComplex:
	lda xsp, (xsp - 52)
	push xiz
	ld (xsp + 48), xbc
	ld (xsp + 52), xwa
	ld xwa, (xsp + 52)
	ld xiz, (xwa)
	lda xwa, (xsp + 40)
	ld xbc, xwa
	ld xwa, xiz
	call DSP_StreamDecode_3ByteWord
	ld xiz, xhl
	lda xbc, (xsp + 40)
	lda xwa, (xsp + 20)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 20)
	lda xde, (FPConst_DSP_ParamInterp_FPComplex_32768:24)
	lda xwa, (xsp + 20)
	call FP_fdiv
	lda xbc, (xsp + 20)
	lda xde, (FPConst_DSP_ParamInterp_FPComplex_65536:24)
	lda xwa, (xsp + 28)
	call FP_fdiv
	lda xwa, (xsp + 36)
	ld xbc, xwa
	ld xwa, xiz
	call DSP_StreamDecode_3ByteWord
	ld xiz, xhl
	ld xwa, (xsp + 36)
	sra xwa, 8
	and_erpw 0xE2, 0xFF, 0x00
	ld (xsp + 36), xwa
	lda xbc, (xsp + 48)
	lda xwa, (xsp + 20)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 36)
	lda xwa, (xsp + 24)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 24)
	lda xde, (xsp + 28)
	lda xwa, (xsp + 24)
	call FP_fsub
	lda xbc, (xsp + 24)
	lda xde, (xsp + 20)
	lda xwa, (xsp + 24)
	call FP_fmul
	lda xbc, (xsp + 28)
	lda xde, (FPConst_DSP_ParamInterp_FPComplex_99:24)
	lda xwa, (xsp + 20)
	call FP_fmul
	lda xbc, (xsp + 20)
	lda xde, (xsp + 24)
	lda xwa, (xsp + 24)
	call FP_fadd
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_ParamInterp_FPComplex_44100:24)
	lda xwa, (xsp + 24)
	call FP_fmul
	lda xbc, (FPConst_DSP_ParamInterp_FPComplex_99_2:24)
	lda xde, (xsp + 24)
	lda xwa, (xsp + 24)
	call FP_fsub
	lda xbc, (FPConst_DSP_ParamInterp_FPComplex_2376:24)
	lda xde, (xsp + 24)
	lda xwa, (xsp + 24)
	call FP_fdiv
	lda xbc, (xsp + 24)
	lda xwa, (xsp + 4)
	call FP_ftod
	lda xiy, (xsp + 4)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_ParamInterp_FPComplex_2:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 28)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 44)
	call FP_dtof
	ld xwa, (xsp + 52)
	ld (xwa), xiz
	lda xbc, (xsp + 44)
	lda xde, (FPConst_DSP_ParamInterp_FPComplex_Q23One:24)
	lda xwa, (xsp + 24)
	call FP_fmul
	lda xbc, (xsp + 24)
	lda xwa, (xsp + 32)
	call FP_ftoi
	ld xhl, (xsp + 32)
	pop xiz
	lda xsp, (xsp + 52)
	ret

; Decoder for opcode 0x6F; result -> DSP_WriteOscParam.  Consumes NOTHING from the stream.
; In: XBC = 0..99 value.  Out: XHL = a sample count.
; Five continuous linear segments, all of the form XHL = 44100 * g(x) / 1000, i.e. 44.1 samples
; per millisecond -- so g(x) is a time in MILLISECONDS:
;   x <=  20   g =   2x +   10        (  10 ..   50 ms)
;   x <=  30   g =   5x -   50        (  50 ..  100 ms)
;   x <=  70   g =  10x -  200        ( 100 ..  500 ms)
;   x <=  80   g =  50x - 3000        ( 500 .. 1000 ms)
;   else       g = 100x - 7000        (1000 .. 2900 ms)
; Every knot joins exactly (checked at x = 20, 30, 70, 80).  The constants are
; 0x0006BAA8 = 441000, 0x0021A548 = 2205000, 0x00869520 = 8820000, 0x07E2BCE0 = 132300000,
; 0x12666360 = 308700000, all exact multiples of 44100.
; This is a DELAY-TIME curve, 10 ms .. 2.9 s.  See [UNCERTAIN] about the name "Pan".
DSP_PanCurve_PiecewiseLin:	.include "includes/generated/cc900/DSP_PanCurve_PiecewiseLin.s"	; C: cc900/dsp_control_routines_e_7a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_PanCurve_Seg2, DSP_PanCurve_PiecewiseLin + 41
	.set	DSP_PanCurve_Seg3, DSP_PanCurve_PiecewiseLin + 85
	.set	DSP_PanCurve_Seg4, DSP_PanCurve_PiecewiseLin + 130
	.set	DSP_PanCurve_Seg5, DSP_PanCurve_PiecewiseLin + 179
	.set	DSP_PanCurve_Return, DSP_PanCurve_PiecewiseLin + 218

; Decoder for opcode 0x71; result -> DSP_WriteOscParam.  Consumes nothing from the stream.
; In: XBC = a SIGNED value (copied to IZ).  Out: XHL.
; Works on |x| and re-applies the sign at the end -- the only decoder in the region that is
; explicitly bipolar, which is what makes "detune" a believable reading.
;   |x| <= 10   -> float(|x|), + const 0x012D77 (2)
;   |x| <= 19   -> float(|x|), + 0x012D7B (20),  - 0x012D7F (180)
;   |x| <= 31   -> float(|x|), + 0x012D83 (100), - 0x012D87 (1700)
;   else        -> float(|x|), + 0x012D8B (200), - 0x012D8F (4800)
; then, if x < 0, FP_SP_CopyOrNegate4 flips the sign (DSP_DetuneCurve_ApplySign), and the shared
; finalisation runs the value through FP_fdiv(0x012D93), a promotion to double,
; FP_pow against the double at 0x012D97 (2.0), FP_dsub(0x012D9F, 1.0),
; FP_ddiv(0x012DA7, 2400.0), FP_dtof, FP_fmul(0x012DAF) and
; FP_ftoi.  The 2400 is cents-per-octave x 2, and the 2.0 base again points at a
; pow(2, cents/2400) pitch-ratio computation.  Frame 0x48 bytes.
DSP_DetuneCurve_SignedFP:
	lda xsp, (xsp - 72)
	push xiz
	ld xiz, xbc
	cp xiz, 0x0
	jr lt, DSP_DetuneCurve_NegateInput
	ld xwa, xiz
	jr DSP_DetuneCurve_CheckMagnitude

; x < 0: XWA = -IZ, to get the magnitude for the range test.
DSP_DetuneCurve_NegateInput:
	ld xwa, xiz
	cpl wa
	cplw_erp 0xE2
	inc 1, xwa

; Join point with |x| in XWA; first range test, |x| <= 10.
DSP_DetuneCurve_CheckMagnitude:
	cp xwa, 0xA
	jr gt, DSP_DetuneCurve_CheckRange2
	cp xiz, 0x0
	jr lt, DSP_DetuneCurve_Range1_NegArm
	ld (xsp + 60), xiz
	jr DSP_DetuneCurve_Range1_Compute

; Range 1, negative input: store the magnitude at (XSP+0x3C).
DSP_DetuneCurve_Range1_NegArm:
	ld xwa, xiz
	cpl wa
	cplw_erp 0xE2
	inc 1, xwa
	ld (xsp + 60), xwa

; Range 1 body: int->float, + the constant at 0x012D77.
DSP_DetuneCurve_Range1_Compute:
	lda xbc, (xsp + 60)
	lda xwa, (xsp + 36)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_DetuneCurve_Range1_Compute_2:24)
	lda xwa, (xsp + 68)
	call FP_fmul
	jrl DSP_DetuneCurve_ApplySign

; Recompute |x| for the second range test.
DSP_DetuneCurve_CheckRange2:
	cp xiz, 0x0
	jr lt, DSP_DetuneCurve_Range2_NegArm
	ld xwa, xiz
	jr DSP_DetuneCurve_CheckRange2Limit

; Negate to get the magnitude before the |x| <= 19 test.
DSP_DetuneCurve_Range2_NegArm:
	ld xwa, xiz
	cpl wa
	cplw_erp 0xE2
	inc 1, xwa

; The |x| <= 19 (0x13) comparison itself.
DSP_DetuneCurve_CheckRange2Limit:
	cp xwa, 0x13
	jr gt, DSP_DetuneCurve_CheckRange3
	cp xiz, 0x0
	jr lt, DSP_DetuneCurve_Range2_NegStore
	ld (xsp + 56), xiz
	jr DSP_DetuneCurve_Range2_Compute

; Range 2, negative input: store the magnitude at (XSP+0x38).
DSP_DetuneCurve_Range2_NegStore:
	ld xwa, xiz
	cpl wa
	cplw_erp 0xE2
	inc 1, xwa
	ld (xsp + 56), xwa

; Range 2 body: + 0x012D7B (20), - 0x012D7F (180).
DSP_DetuneCurve_Range2_Compute:
	lda xbc, (xsp + 56)
	lda xwa, (xsp + 36)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_DetuneCurve_Range2_Compute_20:24)
	lda xwa, (xsp + 36)
	call FP_fmul
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_DetuneCurve_Range2_Compute_180:24)
	lda xwa, (xsp + 68)
	call FP_fsub
	jrl DSP_DetuneCurve_ApplySign

; Recompute |x| for the third range test.
DSP_DetuneCurve_CheckRange3:
	cp xiz, 0x0
	jr lt, DSP_DetuneCurve_Range3_NegArm
	ld xwa, xiz
	jr DSP_DetuneCurve_CheckRange3Limit

; Negate to get the magnitude before the |x| <= 31 test.
DSP_DetuneCurve_Range3_NegArm:
	ld xwa, xiz
	cpl wa
	cplw_erp 0xE2
	inc 1, xwa

; The |x| <= 31 (0x1F) comparison itself.
DSP_DetuneCurve_CheckRange3Limit:
	cp xwa, 0x1F
	jr gt, DSP_DetuneCurve_Range4_CheckSign
	cp xiz, 0x0
	jr lt, DSP_DetuneCurve_Range3_NegStore
	ld (xsp + 52), xiz
	jr DSP_DetuneCurve_Range3_Compute

; Range 3, negative input: store the magnitude at (XSP+0x34).
DSP_DetuneCurve_Range3_NegStore:
	ld xwa, xiz
	cpl wa
	cplw_erp 0xE2
	inc 1, xwa
	ld (xsp + 52), xwa

; Range 3 body: + 0x012D83 (100), - 0x012D87 (1700).
DSP_DetuneCurve_Range3_Compute:
	lda xbc, (xsp + 52)
	lda xwa, (xsp + 36)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_DetuneCurve_Range3_Compute_100:24)
	lda xwa, (xsp + 36)
	call FP_fmul
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_DetuneCurve_Range3_Compute_1700:24)
	lda xwa, (xsp + 68)
	call FP_fsub
	jr DSP_DetuneCurve_ApplySign

; Fall-through range (|x| > 31): sign test only.
DSP_DetuneCurve_Range4_CheckSign:
	cp xiz, 0x0
	jr lt, DSP_DetuneCurve_Range4_NegStore
	ld (xsp + 48), xiz
	jr DSP_DetuneCurve_Range4_Compute

; Range 4, negative input: store the magnitude at (XSP+0x30).
DSP_DetuneCurve_Range4_NegStore:
	ld xwa, xiz
	cpl wa
	cplw_erp 0xE2
	inc 1, xwa
	ld (xsp + 48), xwa

; Range 4 body: + 0x012D8B (200), - 0x012D8F (4800).
DSP_DetuneCurve_Range4_Compute:
	lda xbc, (xsp + 48)
	lda xwa, (xsp + 36)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_DetuneCurve_Range4_Compute_200:24)
	lda xwa, (xsp + 36)
	call FP_fmul
	lda xbc, (xsp + 36)
	lda xde, (FPConst_DSP_DetuneCurve_Range4_Compute_4800:24)
	lda xwa, (xsp + 68)
	call FP_fsub

; If the ORIGINAL input was negative, negate the accumulated float via FP_SP_CopyOrNegate4.
DSP_DetuneCurve_ApplySign:
	cp xiz, 0x0
	jr ge, DSP_DetuneCurve_Finalize
	lda xbc, (xsp + 68)
	lda xwa, (xsp + 68)
	call FP_SP_CopyOrNegate4

; Shared tail described in the routine header; note the 2400.0 (cents per octave x 2) at
; 0x012DA7 and the 2.0 base at 0x012D97.
DSP_DetuneCurve_Finalize:
	lda xbc, (xsp + 68)
	lda xde, (FPConst_DSP_DetuneCurve_Finalize_2400:24)
	lda xwa, (xsp + 36)
	call FP_fdiv
	lda xbc, (xsp + 36)
	lda xwa, (xsp + 28)
	call FP_ftod
	lda xiy, (xsp + 28)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_DetuneCurve_Finalize_2:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 56)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (FPConst_DSP_DetuneCurve_Finalize_1:24)
	lda xde, (xsp + 40)
	lda xwa, (xsp + 28)
	call FP_dsub
	lda xbc, (xsp + 28)
	lda xde, (FPConst_DSP_DetuneCurve_Finalize_2400_2:24)
	lda xwa, (xsp + 28)
	call FP_ddiv
	lda xbc, (xsp + 28)
	lda xwa, (xsp + 72)
	call FP_dtof
	lda xbc, (xsp + 72)
	lda xde, (FPConst_DSP_DetuneCurve_Finalize_Q23One:24)
	lda xwa, (xsp + 36)
	call FP_fmul
	lda xbc, (xsp + 36)
	lda xwa, (xsp + 64)
	call FP_ftoi
	ld xhl, (xsp + 64)
	pop xiz
	lda xsp, (xsp + 72)
	ret

; Decoder for opcode 0x72 (arm 0x03CDD6).  Unlike every other routine in the region this one
; EMITS TO THE DSP ITSELF instead of returning a value for the interpreter to send.
; Stack args (retd 0x0008, so two longs are popped): (XSP+0x5E) and (XSP+0x62)/(XSP+0x64) carry
; the DSP channel / chip selectors that are handed to DSP_WriteOscParam and
; DSP_WriteCoeffData_5B_Direct.  XWA = &cursor, XBC = base of a word array, DE = an index.
; Step 1 -- pick two table entries.  It reads ONE byte from the stream (post-increment, cursor
;   written back at the very end) and tests its HIGH nibble:
;     high nibble == 0 : HL = word[DE],   IZ = word[DE+1]
;     otherwise        : HL = word[DE-1], IZ = word[DE]
;   (same "which field of the group does the index point at" convention as
;   DSP_FilterLUT_Fetch and DSP_ParamInterp_MultiStep).
; Step 2 -- clamp: HL to <= 0x59 (89), IZ to <= 0x58 (88).
; Step 3 -- for each of the two, compute (99 - v) as a signed int, promote to double, add the
;   constant at 0x012DB3 / 0x012DCB (-0.0697), call FP_pow against the
;   double 10.0 at 0x012DBB / 0x012DD3 -- i.e. pow(10, -0.0697*(99-v)), a dB-to-linear
;   conversion with a 0.697 dB step -- then FP_dmul with 0.9999 (0x012DC3 / 0x012DDB)
;   and normalise to a float.  Results land at (XSP+0x52) and (XSP+0x4A).
; Step 4 -- with the literal 3.0 (0x40400000) at (XSP+0x4E) it computes five coefficient floats
;   through FP_fsub / FP_fmul / FP_fadd / FP_fdiv against the constants
;   0x012DE3..0x012E03 (2, 2, 1, 3, 2097152, 8388608, 4194304, 2097152, 2097152 -- note
;   2^21/2^23/2^22, the Q23 scalings).
; Step 5 -- emits: one DSP_WriteOscParam then FOUR DSP_WriteCoeffData_5B_Direct calls, i.e. a
;   complete 5-coefficient biquad section.
; Returns XHL = the accumulated write status; writes the advanced cursor back through XWA.
; The dB step, the 10.0 base and the five-coefficient emission are solid; the exact algebra of
; step 4 depends on the FP helper semantics I could not confirm (see [UNCERTAIN]).
DSP_BiquadWarp_FP:
	lda xsp, (xsp - 88)
	pushw iz
	ld (xsp + 86), xwa
	ld de, (xsp + 100)
	ld xwa, (xsp + 86)
	ld xwa, (xwa)
	ld (xsp + 2), xwa
	ld L, (xwa+)
	ld (xsp + 2), xwa
	and l, 0xF0
	jr nz, DSP_BiquadWarp_ReadPrevEntry
	ld wa, de
	extz xwa
	add xwa, xwa
	add xwa, xbc
	ld hl, (xwa)
	inc 1, de
	ld wa, de
	extz xwa
	add xwa, xwa
	add xwa, xbc
	ld iz, (xwa)
	jr DSP_BiquadWarp_ClampHL

; High nibble non-zero: use word[DE-1] and word[DE] instead of word[DE] and word[DE+1].
DSP_BiquadWarp_ReadPrevEntry:
	ld wa, de
	dec 1, wa
	extz xwa
	add xwa, xwa
	add xwa, xbc
	ld hl, (xwa)
	ld wa, de
	extz xwa
	add xwa, xwa
	add xwa, xbc
	ld iz, (xwa)

; Clamp the first table value to 0x59 (89).
DSP_BiquadWarp_ClampHL:
	cp hl, 0x59
	jr le, DSP_BiquadWarp_ClampIZ
	ldw hl, 0x59

; Clamp the second table value to 0x58 (88).
DSP_BiquadWarp_ClampIZ:
	cp iz, 0x58
	jr le, DSP_BiquadWarp_ComputeCoeffs
	ldw iz, 0x58

; Steps 3-5 of the header: the two pow(10, -0.0697*(99-v)) gains, the five coefficient floats,
; and the five DSP writes.
DSP_BiquadWarp_ComputeCoeffs:
	ldw wa, 0x63
	sub wa, hl
	exts xwa
	ld (xsp + 14), xwa
	lda xbc, (xsp + 14)
	lda xwa, (xsp + 58)
	call FP_ScalarToDP
	lda xbc, (xsp + 58)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_Neg0p0697:24)
	lda xwa, (xsp + 58)
	call FP_dmul
	lda xiy, (xsp + 58)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_BiquadWarp_ComputeCoeffs_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 66)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 50)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_0p9999:24)
	lda xwa, (xsp + 58)
	call FP_dmul
	lda xbc, (xsp + 58)
	lda xwa, (xsp + 82)
	call FP_dtof
	ldw wa, 0x63
	sub wa, iz
	exts xwa
	ld (xsp + 18), xwa
	lda xbc, (xsp + 18)
	lda xwa, (xsp + 58)
	call FP_ScalarToDP
	lda xbc, (xsp + 58)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_Neg0p0697_2:24)
	lda xwa, (xsp + 58)
	call FP_dmul
	lda xiy, (xsp + 58)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_BiquadWarp_ComputeCoeffs_10_2:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 58)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 42)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_0p9999_2:24)
	lda xwa, (xsp + 58)
	call FP_dmul
	lda xbc, (xsp + 58)
	lda xwa, (xsp + 74)
	call FP_dtof
	ld xwa, 0x40400000
	ld (xsp + 78), xwa
	lda xbc, (xsp + 82)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_2:24)
	lda xwa, (xsp + 10)
	call FP_fsub
	lda xbc, (xsp + 82)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_2_2:24)
	lda xwa, (xsp + 6)
	call FP_fsub
	lda xbc, (xsp + 6)
	lda xde, (xsp + 10)
	lda xwa, (xsp + 6)
	call FP_fmul
	lda xbc, (xsp + 6)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_1:24)
	lda xwa, (xsp + 6)
	call FP_fsub
	lda xbc, (xsp + 78)
	lda xde, (xsp + 74)
	lda xwa, (xsp + 10)
	call FP_fsub
	lda xbc, (xsp + 10)
	lda xde, (xsp + 6)
	lda xwa, (xsp + 70)
	call FP_fdiv
	lda xbc, (xsp + 70)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_3:24)
	lda xwa, (xsp + 6)
	call FP_fmul
	lda xbc, (xsp + 6)
	lda xde, (xsp + 74)
	lda xwa, (xsp + 66)
	call FP_fadd
	lda xbc, (xsp + 78)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_Q21One:24)
	lda xwa, (xsp + 6)
	call FP_fmul
	lda xbc, (xsp + 6)
	lda xwa, (xsp + 38)
	call FP_ftoi
	pushm (xsp + 94)
	ld wa, (xsp + 100)
	ld xbc, (xsp + 40)
	ld de, (xsp + 98)
	call DSP_WriteOscParam
	lda xbc, (xsp + 82)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_Q23One:24)
	lda xwa, (xsp + 6)
	call FP_fmul
	lda xbc, (xsp + 6)
	lda xwa, (xsp + 34)
	call FP_ftoi
	ld xwa, (xsp + 34)
	ld bc, (xsp + 96)
	ld de, (xsp + 94)
	call DSP_WriteCoeffData_5B_Direct
	lda xbc, (xsp + 70)
	lda xwa, (xsp + 6)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 6)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_Q22One:24)
	lda xwa, (xsp + 6)
	call FP_fmul
	lda xbc, (xsp + 6)
	lda xwa, (xsp + 30)
	call FP_ftoi
	ld xwa, (xsp + 30)
	ld bc, (xsp + 96)
	ld de, (xsp + 94)
	call DSP_WriteCoeffData_5B_Direct
	lda xbc, (xsp + 70)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_Q21One_2:24)
	lda xwa, (xsp + 6)
	call FP_fmul
	lda xbc, (xsp + 6)
	lda xwa, (xsp + 26)
	call FP_ftoi
	ld xwa, (xsp + 26)
	ld bc, (xsp + 96)
	ld de, (xsp + 94)
	call DSP_WriteCoeffData_5B_Direct
	lda xbc, (xsp + 66)
	lda xde, (FPConst_DSP_BiquadWarp_ComputeCoeffs_Q21One_3:24)
	lda xwa, (xsp + 6)
	call FP_fmul
	lda xbc, (xsp + 6)
	lda xwa, (xsp + 22)
	call FP_ftoi
	ld xwa, (xsp + 22)
	ld bc, (xsp + 96)
	ld de, (xsp + 94)
	call DSP_WriteCoeffData_5B_Direct
	ld xwa, (xsp + 86)
	ld xbc, (xsp + 2)
	ld (xwa), xbc
	popw iz
	lda xsp, (xsp + 88)
	retd 0x8

; Decoder for opcode 0x73; result -> DSP_WriteOscParam.  A BIPOLAR two-point interpolation:
; the blend value is offset by +99 and divided by 198, so XBC = -99..+99 maps to 0..1.
; In: XWA = &cursor, XBC = signed blend.  Out: XHL; cursor += 6.
;       A = value[0], B = value[1]
;       t   = ((B - A) >> 8) / 198                       (198 == 0xC6 == 2*99)
;       XHL = (A >> 8) + t * (XBC + 99)
; Note the divide happens BEFORE the multiply here (unlike DSP_ParamInterp_2Point), so the
; result is coarser -- that is in the ROM, not a transcription slip.
DSP_ParamInterp_Div0xC6:
	lda xsp, (xsp - 24)
	push xiz
	ld (xsp + 20), xbc
	ld (xsp + 24), xwa
	ld xwa, (xsp + 24)
	ld xwa, (xwa)
	ld (xsp + 4), xwa
	lda xwa, (xsp + 16)
	ld xbc, xwa
	ld xwa, (xsp + 4)
	call DSP_StreamDecode_3ByteWord
	ld (xsp + 4), xhl
	lda xwa, (xsp + 12)
	ld xbc, xwa
	ld xwa, (xsp + 4)
	call DSP_StreamDecode_3ByteWord
	ld (xsp + 4), xhl
	ld xwa, (xsp + 20)
	ld (xsp + 8), xwa
	ld xwa, 0x63
	add (xsp + 8), xwa
	ld xwa, (xsp + 12)
	sub xwa, (xsp + 16)
	sra xwa, 8
	ld xbc, 0xC6
	call Long_SignedDiv
	ld xiz, xhl
	ld xbc, (xsp + 8)
	ld xwa, xiz
	call Math_Multiply32
	ld xwa, xhl
	ld xhl, (xsp + 16)
	sra xhl, 8
	add xhl, xwa
	ld xwa, (xsp + 24)
	ld xbc, (xsp + 4)
	ld (xwa), xbc
	pop xiz
	lda xsp, (xsp + 24)
	ret

; Decoder for opcode 0x75; result -> DSP_WriteOscParam.  A five-range floating-point curve.
; In: XWA = &cursor, XBC = 0..99 value.  Out: XHL; cursor += 3.
; Consumes ONE 3-byte stream value, converts it to float and pre-scales it against the
; constants at 0x012E07 (32768) and 0x012E0B (65536) -- the second copy is kept at (XSP+0x50)
; and reused by every range.  Then it branches on XBC:
;       XBC <= 15 (0x0F)  range 1, constants 0x012E0F..0x012E3F
;       XBC <= 23 (0x17)  range 2, constants 0x012E63..0x012E87  (bias 16)
;       XBC <= 55 (0x37)  range 3, constants 0x012E8F..0x012EB3  (bias 24)
;       XBC <= 75 (0x4B)  range 4, constants 0x012EBB..0x012EDF  (bias 56)
;       else              range 5, constants 0x012EE7..0x012EFB  (bias 67)
; The biases 16/24/56/67 are subtracted from XBC by the FP_fsub at the head of each range, so
; each range restarts its curve from zero.  Range 1 additionally calls FP_dcmp
; (0x03D2AC -- an FP COMPARISON helper, not a voice routine; see [UNCERTAIN]) against the
; constant at 0x012E2F and takes a separate arm when the coefficient is non-zero.
; Every range converges on DSP_ParamEQ_Finalize.  Frame 0x64 bytes.
DSP_ParamEQ_Curve_FP:
	lda xsp, (xsp - 100)
	push xiz
	ld (xsp + 96), xbc
	ld (xsp + 100), xwa
	ld xwa, (xsp + 100)
	ld xiz, (xwa)
	lda xwa, (xsp + 88)
	ld xbc, xwa
	ld xwa, xiz
	call DSP_StreamDecode_3ByteWord
	ld xiz, xhl
	lda xbc, (xsp + 88)
	lda xwa, (xsp + 12)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_ParamEQ_Curve_FP_32768:24)
	lda xwa, (xsp + 12)
	call FP_fdiv
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_ParamEQ_Curve_FP_65536:24)
	lda xwa, (xsp + 80)
	call FP_fdiv
	ld xwa, (xsp + 96)
	cp xwa, 0xF
	jrl gt, DSP_ParamEQ_Range2
	lda xbc, (xsp + 96)
	lda xwa, (xsp + 12)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 40)
	call FP_ftod
	lda xbc, (xsp + 40)
	lda xde, (FPConst_DSP_ParamEQ_Curve_FP_0p02:24)
	lda xwa, (xsp + 40)
	call FP_dmul
	lda xbc, (xsp + 40)
	lda xde, (FPConst_DSP_ParamEQ_Curve_FP_0p1:24)
	lda xwa, (xsp + 40)
	call FP_dadd
	lda xbc, (FPConst_DSP_ParamEQ_Curve_FP_1:24)
	lda xde, (xsp + 40)
	lda xwa, (xsp + 40)
	call FP_ddiv
	lda xbc, (xsp + 40)
	lda xwa, (xsp + 76)
	call FP_dtof
	lda xbc, (xsp + 76)
	lda xwa, (xsp + 40)
	call FP_ftod
	lda xbc, (xsp + 80)
	lda xwa, (xsp + 64)
	call FP_ftod
	lda xbc, (xsp + 64)
	lda xde, (xsp + 40)
	lda xwa, (xsp + 64)
	call FP_dmul
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Curve_FP_Neg4p816:24)
	lda xwa, (xsp + 64)
	call FP_dmul
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 72)
	call FP_dtof
	lda xbc, (xsp + 72)
	lda xwa, (xsp + 64)
	call FP_ftod
	lda xwa, (xsp + 64)
	lda xbc, (FPConst_DSP_ParamEQ_Curve_FP_Neg7:24)
	ld de, 1:i3
	call FP_dcmp
	cp hl, 0:i3
	jr nz, DSP_ParamEQ_Range1_NonzeroCoeff
	lda xbc, (xsp + 72)
	lda xwa, (xsp + 64)
	call FP_ftod
	lda xiy, (xsp + 64)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_ParamEQ_Curve_FP_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 72)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 56)
	lda xwa, (xsp + 64)
	call FP_DP_CopyOrNegate8
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Curve_FP_2:24)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 92)
	call FP_dtof
	jrl DSP_ParamEQ_Finalize

; Range 1, taken when the FP comparison at 0x039E81 reports non-zero: multiplies by the
; constant at 0x012E47 (7.0) and runs the pow-style helper against 0x012E4B instead.
DSP_ParamEQ_Range1_NonzeroCoeff:
	lda xbc, (xsp + 72)
	lda xde, (FPConst_DSP_ParamEQ_Range1_NonzeroCoeff_7:24)
	lda xwa, (xsp + 12)
	call FP_fadd
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 64)
	call FP_ftod
	lda xiy, (xsp + 64)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_ParamEQ_Range1_NonzeroCoeff_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 64)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 48)
	lda xwa, (xsp + 64)
	call FP_DP_CopyOrNegate8
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range1_NonzeroCoeff_1em7:24)
	lda xwa, (xsp + 64)
	call FP_dmul
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range1_NonzeroCoeff_2:24)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 92)
	call FP_dtof
	jrl DSP_ParamEQ_Finalize

; 15 < XBC <= 23; bias 16 (0x012E63).
DSP_ParamEQ_Range2:
	ld xwa, (xsp + 96)
	cp xwa, 0x17
	jrl gt, DSP_ParamEQ_Range3
	lda xbc, (xsp + 96)
	lda xwa, (xsp + 12)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_ParamEQ_Range2_16:24)
	lda xwa, (xsp + 12)
	call FP_fsub
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 64)
	call FP_ftod
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range2_0p05:24)
	lda xwa, (xsp + 64)
	call FP_dmul
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range2_0p45:24)
	lda xwa, (xsp + 64)
	call FP_dadd
	lda xbc, (xsp + 80)
	lda xwa, (xsp + 40)
	call FP_ftod
	lda xbc, (xsp + 40)
	lda xde, (FPConst_DSP_ParamEQ_Range2_Neg4p816:24)
	lda xwa, (xsp + 40)
	call FP_dmul
	lda xbc, (xsp + 40)
	lda xde, (xsp + 64)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xiy, (xsp + 64)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_ParamEQ_Range2_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 48)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 32)
	lda xwa, (xsp + 64)
	call FP_DP_CopyOrNegate8
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range2_2:24)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 92)
	call FP_dtof
	jrl DSP_ParamEQ_Finalize

; 23 < XBC <= 55; bias 24 (0x012E8F).
DSP_ParamEQ_Range3:
	ld xwa, (xsp + 96)
	cp xwa, 0x37
	jrl gt, DSP_ParamEQ_Range4
	lda xbc, (xsp + 96)
	lda xwa, (xsp + 12)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_ParamEQ_Range3_24:24)
	lda xwa, (xsp + 12)
	call FP_fsub
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 64)
	call FP_ftod
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range3_0p1:24)
	lda xwa, (xsp + 64)
	call FP_dmul
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range3_0p9:24)
	lda xwa, (xsp + 64)
	call FP_dadd
	lda xbc, (xsp + 80)
	lda xwa, (xsp + 40)
	call FP_ftod
	lda xbc, (xsp + 40)
	lda xde, (FPConst_DSP_ParamEQ_Range3_Neg4p816:24)
	lda xwa, (xsp + 40)
	call FP_dmul
	lda xbc, (xsp + 40)
	lda xde, (xsp + 64)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xiy, (xsp + 64)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_ParamEQ_Range3_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 40)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 24)
	lda xwa, (xsp + 64)
	call FP_DP_CopyOrNegate8
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range3_2:24)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 92)
	call FP_dtof
	jrl DSP_ParamEQ_Finalize

; 55 < XBC <= 75; bias 56 (0x012EBB).
DSP_ParamEQ_Range4:
	ld xwa, (xsp + 96)
	cp xwa, 0x4B
	jrl gt, DSP_ParamEQ_Range5
	lda xbc, (xsp + 96)
	lda xwa, (xsp + 12)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_ParamEQ_Range4_56:24)
	lda xwa, (xsp + 12)
	call FP_fsub
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 64)
	call FP_ftod
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range4_0p2:24)
	lda xwa, (xsp + 64)
	call FP_dmul
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range4_4p2:24)
	lda xwa, (xsp + 64)
	call FP_dadd
	lda xbc, (xsp + 80)
	lda xwa, (xsp + 40)
	call FP_ftod
	lda xbc, (xsp + 40)
	lda xde, (FPConst_DSP_ParamEQ_Range4_Neg4p816:24)
	lda xwa, (xsp + 40)
	call FP_dmul
	lda xbc, (xsp + 40)
	lda xde, (xsp + 64)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xiy, (xsp + 64)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_ParamEQ_Range4_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 32)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 16)
	lda xwa, (xsp + 64)
	call FP_DP_CopyOrNegate8
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range4_2:24)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 92)
	call FP_dtof
	jrl DSP_ParamEQ_Finalize

; XBC > 75; bias 67 (0x012EE7).  The only range with no FP_dadd step.
DSP_ParamEQ_Range5:
	lda xbc, (xsp + 96)
	lda xwa, (xsp + 12)
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_ParamEQ_Range5_67:24)
	lda xwa, (xsp + 12)
	call FP_fsub
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 64)
	call FP_ftod
	lda xbc, (xsp + 80)
	lda xwa, (xsp + 40)
	call FP_ftod
	lda xbc, (xsp + 40)
	lda xde, (FPConst_DSP_ParamEQ_Range5_Neg4p816:24)
	lda xwa, (xsp + 40)
	call FP_dmul
	lda xbc, (xsp + 40)
	lda xde, (xsp + 64)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xiy, (xsp + 64)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_ParamEQ_Range5_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 20)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 4)
	lda xwa, (xsp + 64)
	call FP_DP_CopyOrNegate8
	lda xbc, (xsp + 64)
	lda xde, (FPConst_DSP_ParamEQ_Range5_2:24)
	lda xwa, (xsp + 64)
	call FP_ddiv
	lda xbc, (xsp + 64)
	lda xwa, (xsp + 92)
	call FP_dtof

; Shared tail: write the advanced cursor back through the caller's pointer, then
; FP_fmul(0x012F03 = 8388608.0 = 2^23) and FP_ftoi to land the result as
; a Q23 integer in XHL.  The 2^23 here is the same Q23 convention used by the integer decoders.
DSP_ParamEQ_Finalize:
	ld xwa, (xsp + 100)
	ld (xwa), xiz
	lda xbc, (xsp + 92)
	lda xde, (FPConst_DSP_ParamEQ_Finalize_Q23One:24)
	lda xwa, (xsp + 12)
	call FP_fmul
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 84)
	call FP_ftoi
	ld xhl, (xsp + 84)
	pop xiz
	lda xsp, (xsp + 100)
	ret

; Decoder for opcode 0x77; result -> DSP_WriteOscParam.
; BYTE-FOR-BYTE IDENTICAL to DSP_ParamInterp_2Point (0x039206) and DSP_FreqInterp_2Point
; (0x0394CD) -- all three 0x58-byte bodies verified equal by memcmp.  Same contract.
DSP_ParamInterp_2Point_B:	.include "includes/generated/cc900/DSP_ParamInterp_2Point_B.s"	; C: cc900/dsp_control_routines_c_runtime.c

; Decoder for opcode 0x78; result -> DSP_WriteOscParam.
; BYTE-FOR-BYTE IDENTICAL to DSP_VolumeParam_Scale (0x038FE8) over all 0x21E bytes, verified by
; memcmp.  See that routine's header for the three curve families and their formulas.
DSP_VolScale_B:	.include "includes/generated/cc900/DSP_VolScale_B.s"	; C: cc900/dsp_control_routines_e_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_VolScale_B_Algo0_Seg2, DSP_VolScale_B + 57
	.set	DSP_VolScale_B_Algo0_Seg3, DSP_VolScale_B + 91
	.set	DSP_VolScale_B_Algo0_Seg4, DSP_VolScale_B + 128
	.set	DSP_VolScale_B_Algo1_Seg1, DSP_VolScale_B + 159
	.set	DSP_VolScale_B_Algo1_Seg2, DSP_VolScale_B + 187
	.set	DSP_VolScale_B_Algo1_Seg3, DSP_VolScale_B + 228
	.set	DSP_VolScale_B_Algo1_Seg4, DSP_VolScale_B + 270
	.set	DSP_VolScale_B_Algo1_Seg5, DSP_VolScale_B + 315
	.set	DSP_VolScale_B_Algo2_Seg1, DSP_VolScale_B + 352
	.set	DSP_VolScale_B_Algo2_Seg2, DSP_VolScale_B + 388
	.set	DSP_VolScale_B_Algo2_Seg3, DSP_VolScale_B + 435
	.set	DSP_VolScale_B_Algo2_Seg4, DSP_VolScale_B + 486
	.set	DSP_VolScale_B_Return, DSP_VolScale_B + 533

; Decoder for opcode 0x40 (arm 0x03CE9F); result -> DSP_WriteOscParam.  Six instructions:
;       XHL = (XBC * 44100) / 1000
; That is 44.1 samples per millisecond -- a plain MILLISECONDS-TO-SAMPLES converter covering
; 0..99 ms.  It is the degenerate case of DSP_PanCurve_PiecewiseLin's first segment.
; See [UNCERTAIN] about the name "PanScale".
DSP_PanScale_Simple:	.include "includes/generated/cc900/DSP_PanScale_Simple.s"	; C: cc900/dsp_control_routines_c_runtime.c

; Decoder for opcode 0x24 (arm 0x03CEBC); result -> DSP_WriteOscParam.  Two-point interpolation
; where WHICH pair of endpoints is used comes out of a side table.
; In: XWA = &cursor, XBC = 0..99 blend, XDE = base of a word array; (XSP+0x1C) = a word index
;     pushed by the caller.  Out: XHL; cursor += 18 (SIX 3-byte values are always consumed).
; It reads ONE byte from the stream (post-increment) and looks at its HIGH nibble:
;       0x20 -> order = word[index - 2]
;       0x10 -> order = word[index - 1]
;       else -> order = XBC (the caller's value)
; then selects an arm by order:
;       order == 0 : the 1st and 2nd of the six stream values are the endpoints
;       order == 1 : the 3rd and 4th
;       order == 2 : the 5th and 6th
; In every arm all six values are decoded (the unused ones are decoded into the same scratch
; slot at XSP+0x0C and thrown away), so the cursor always advances by the same 18 bytes.
; The arithmetic is then identical to DSP_ParamInterp_2Point:
;       XHL = (A>>8) + (((B - A) >> 8) * XBC) / 99
; The high-nibble convention (0x00/0x10/0x20 = "the index points at field 0 / 1 / 2 of a
; three-word group") is the same one used by DSP_FilterLUT_Fetch and DSP_BiquadWarp_FP.
DSP_ParamInterp_MultiStep:	.include "includes/generated/cc900/DSP_ParamInterp_MultiStep.s"	; C: cc900/dsp_control_routines_e_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_ParamInterp_MultiStep_Mode0x10, DSP_ParamInterp_MultiStep + 36
	.set	DSP_ParamInterp_MultiStep_Mode0x20, DSP_ParamInterp_MultiStep + 51
	.set	DSP_ParamInterp_MultiStep_Dispatch, DSP_ParamInterp_MultiStep + 64
	.set	DSP_ParamInterp_MultiStep_Order1, DSP_ParamInterp_MultiStep + 154
	.set	DSP_ParamInterp_MultiStep_Order2, DSP_ParamInterp_MultiStep + 234
	.set	DSP_ParamInterp_MultiStep_Compute, DSP_ParamInterp_MultiStep + 312

; Decodes ONE parametric-EQ band descriptor.  NOT a byte-code arm -- it is reached only by the
; `calr` at 0x03A962 inside DSP_BiquadCoeff_Compute (0x03A933, opcode 0x70), which is the first
; routine of region 15.
; In:  WA (-> IZ) = word index into the caller's array
;      XBC = float* out: centre frequency
;      XDE = float* out: Q / bandwidth
;      stack args (retd 0x0010, four longs):
;        (XSP+0x38) = the parameter-stream cursor -- read, advanced by one byte, RETURNED in XHL
;        (XSP+0x3C) = base of a word array (the band's three fields live in it consecutively)
;        (XSP+0x40) = uint16* out: the filter TYPE (low nibble of the stream byte)
;        (XSP+0x44) = float* out: the gain-derived scalar
; The stream byte splits into two nibbles:
;   LOW nibble = filter type
;     0 : full band -- freq from the 27-entry Hz LUT at 0x012397, Q from the 32-entry LUT at
;         0x012403, gain from the third word
;     1 : Q is FORCED to the literal 0.1 (0x3DCCCCCD); only the frequency word is read
;     2 : Q is FORCED to the literal 2.0 (0x40000000); frequency and gain are read
;     other : nothing is computed, the three output pointers get whatever was on the stack
;   HIGH nibble = which field of the three-word group the index currently points at
;     0x00 : freq = arr[i],   Q = arr[i+1], gain = arr[i+2]
;     0x10 : freq = arr[i-1], Q = arr[i],   gain = arr[i+1]
;     0x20 : freq = arr[i-2], Q = arr[i-1], gain = arr[i]
;     (for type 2 the high nibble only distinguishes "gain at i+1" from "gain at i")
; The gain word is sign-extended, promoted to double, combined with 0.5 (0x012F07 etc.) and
; -12.0 (0x012F0F etc.) -- the same pair repeated for all five arms -- and normalised to a
; float.  The 27-entry LUT is the ISO 1/3-octave series 40 Hz..16 kHz and the 32-entry LUT runs
; 0.1..20.0, which is what makes "parametric EQ band" certain rather than inferred.
DSP_FilterLUT_Fetch:
	lda xsp, (xsp - 50)
	pushw iz
	ld (xsp + 44), xde
	ld (xsp + 48), xbc
	ld iz, wa
	ld xwa, (xsp + 56)
	ld a, (xwa)
	and a, 0xF
	extz wa
	ld (xsp + 2), wa
	ld xwa, (xsp + 56)
	ld C, (xwa+)
	ld (xsp + 56), xwa
	and c, 0xF0
	extz bc
	ld wa, (xsp + 2)
	cp wa, 2:i3
	jrl z, DSP_FilterLUT_ModeType2
	cp wa, 1:i3
	jrl z, DSP_FilterLUT_ModeType1
	cp wa, 0:i3
	jrl nz, DSP_FilterLUT_StoreResults
	ld wa, bc
	cp wa, 0x20
	jrl z, DSP_FilterLUT_Mode0x20
	cp wa, 0x10
	jrl z, DSP_FilterLUT_Mode0x10
	cp wa, 0:i3
	jrl nz, DSP_FilterLUT_Mode0x20
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_FreqHz_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 40)
	call FP_SP_Raw4Copy
	ld wa, iz
	inc 1, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_Q_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 36)
	call FP_SP_Raw4Copy
	ld wa, iz
	inc 2, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	exts xwa
	ld (xsp + 4), xwa
	lda xbc, (xsp + 4)
	lda xwa, (xsp + 24)
	call FP_ScalarToDP
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_Fetch_0p5:24)
	lda xwa, (xsp + 24)
	call FP_dmul
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_Fetch_Neg12:24)
	lda xwa, (xsp + 24)
	call FP_dadd
	lda xbc, (xsp + 24)
	lda xwa, (xsp + 32)
	call FP_dtof
	jrl DSP_FilterLUT_StoreResults

; Type 0, high nibble 0x10: freq = arr[i-1], Q = arr[i], gain = arr[i+1].
DSP_FilterLUT_Mode0x10:
	ld wa, iz
	dec 1, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_FreqHz_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 40)
	call FP_SP_Raw4Copy
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_Q_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 36)
	call FP_SP_Raw4Copy
	ld wa, iz
	inc 1, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	exts xwa
	ld (xsp + 8), xwa
	lda xbc, (xsp + 8)
	lda xwa, (xsp + 24)
	call FP_ScalarToDP
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_Mode0x10_0p5:24)
	lda xwa, (xsp + 24)
	call FP_dmul
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_Mode0x10_Neg12:24)
	lda xwa, (xsp + 24)
	call FP_dadd
	lda xbc, (xsp + 24)
	lda xwa, (xsp + 32)
	call FP_dtof
	jrl DSP_FilterLUT_StoreResults

; Type 0, high nibble 0x20: freq = arr[i-2], Q = arr[i-1], gain = arr[i].
DSP_FilterLUT_Mode0x20:
	ld wa, iz
	dec 2, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_FreqHz_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 40)
	call FP_SP_Raw4Copy
	ld wa, iz
	dec 1, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_Q_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 36)
	call FP_SP_Raw4Copy
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	exts xwa
	ld (xsp + 12), xwa
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 24)
	call FP_ScalarToDP
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_Mode0x20_0p5:24)
	lda xwa, (xsp + 24)
	call FP_dmul
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_Mode0x20_Neg12:24)
	lda xwa, (xsp + 24)
	call FP_dadd
	lda xbc, (xsp + 24)
	lda xwa, (xsp + 32)
	call FP_dtof
	jrl DSP_FilterLUT_StoreResults

; Type 1: Q := 0.1 (0x3DCCCCCD), freq = arr[i], no gain term.  Jumps straight to the store.
DSP_FilterLUT_ModeType1:
	ld xwa, 0x3DCCCCCD
	ld (xsp + 36), xwa
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_FreqHz_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 40)
	call FP_SP_Raw4Copy
	jrl DSP_FilterLUT_StoreResults

; Type 2: Q := 2.0 (0x40000000); high nibble 0x00 uses freq = arr[i], gain = arr[i+1].
DSP_FilterLUT_ModeType2:
	ld xwa, 0x40000000
	ld (xsp + 36), xwa
	ld wa, bc
	cp wa, 0x20
	jr z, DSP_FilterLUT_ModeType2_SubMode
	cp wa, 0:i3
	jr nz, DSP_FilterLUT_ModeType2_SubMode
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_FreqHz_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 40)
	call FP_SP_Raw4Copy
	ld wa, iz
	inc 1, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	exts xwa
	ld (xsp + 16), xwa
	lda xbc, (xsp + 16)
	lda xwa, (xsp + 24)
	call FP_ScalarToDP
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_ModeType2_0p5:24)
	lda xwa, (xsp + 24)
	call FP_dmul
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_ModeType2_Neg12:24)
	lda xwa, (xsp + 24)
	call FP_dadd
	lda xbc, (xsp + 24)
	lda xwa, (xsp + 32)
	call FP_dtof
	jr DSP_FilterLUT_StoreResults

; Type 2, high nibble 0x10 or 0x20: freq = arr[i-1], gain = arr[i].
DSP_FilterLUT_ModeType2_SubMode:
	ld wa, iz
	dec 1, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_FreqHz_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 40)
	call FP_SP_Raw4Copy
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 60)
	ld wa, (xwa)
	exts xwa
	ld (xsp + 20), xwa
	lda xbc, (xsp + 20)
	lda xwa, (xsp + 24)
	call FP_ScalarToDP
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_ModeType2_SubMode_0p5:24)
	lda xwa, (xsp + 24)
	call FP_dmul
	lda xbc, (xsp + 24)
	lda xde, (FPConst_DSP_FilterLUT_ModeType2_SubMode_Neg12:24)
	lda xwa, (xsp + 24)
	call FP_dadd
	lda xbc, (xsp + 24)
	lda xwa, (xsp + 32)
	call FP_dtof

; Common tail: store type, frequency, Q and the gain scalar through the four caller pointers,
; return the advanced stream cursor in XHL, `retd 0x0010`.  Note that on an unrecognised type
; the three float outputs are written from UNINITIALISED stack slots.
DSP_FilterLUT_StoreResults:
	ld xbc, (xsp + 64)
	ld wa, (xsp + 2)
	ld (xbc), wa
	ld xbc, (xsp + 48)
	ld xwa, (xsp + 40)
	ld (xbc), xwa
	ld xbc, (xsp + 44)
	ld xwa, (xsp + 36)
	ld (xbc), xwa
	ld xbc, (xsp + 68)
	ld xwa, (xsp + 32)
	ld (xbc), xwa
	ld xhl, (xsp + 56)
	popw iz
	lda xsp, (xsp + 50)
	retd 0x10

; Designs one bilinear-transform biquad from the DSP parameter stream and writes its five
; coefficients to the DSP.  Reached only from the opcode-0x70 dispatch arm (0x03CD96).
; Frame: 236 bytes of locals + `push IZ`.  Register args WA / BC / DE are forwarded to
; DSP_FilterLUT_Fetch.  Five stack args, popped with `retd 0x10` (16 bytes), pushed by the arm
; in this order: (1) long = the parameter-stream pointer, (2) word = the caller's running
; status accumulator (IZ), (3) long, (4) word, (5) long = pointer to the caller's status word.
; Returns XHL = the ADVANCED stream pointer; also stores the accumulated write status (IZ)
; through arg 5.
; Flow:
;   1. calls DSP_FilterLUT_Fetch (0x03A620) which consumes the stream header, writes the
;      ALGORITHM SELECTOR (the low nibble of the header byte) into a local, hands back the band
;      frequency and gain as floats, and returns the advanced stream pointer (kept at frame
;      +0x00FE and returned verbatim by the epilogue).
;   2. three-way switch on that selector: 2 -> DSP_BiquadCoeff_Algo2, 1 -> ..._Algo1,
;      0 -> falls through to the Algo0 body.  ★ ANY OTHER VALUE JUMPS STRAIGHT TO
;      DSP_BiquadCoeff_Epilogue AND WRITES NOTHING TO THE DSP -- silently.
;   3. Algo0 body: widen the cutoff to double; w = f * (pi/44100) [FP_dmul = multiply];
;      K = tan(w) [FP_tan]; narrow to float; build the {1,-2,1}-shaped
;      numerator from the float literals at 0x012F5F..0x012F6B; A = 10^(gain_dB/20) via
;      FP_fdiv (divide by 20.0) then FP_pow (pow, base 10.0 at
;      0x012F73); combine into b0,b1,b2,a1,a2.
; Hardware: no direct MMIO -- everything goes through DSP_WriteOscParam (0x0387E6) and
; DSP_WriteCoeffData_5B_Direct (0x0388B3) in the Fixup block.
DSP_BiquadCoeff_Compute:
	lda xsp, (xsp-236)
	pushw iz
	ld	(xsp+236), wa
	lda xwa, (xsp+222:16)
	push xwa
	lda xwa, (xsp+238:16)
	push xwa
	ld	xwa, (xsp+256)
	push xwa
	ld XWA, (xsp + 0x010a)
	push xwa
	ld wa, de
	lda xbc, (xsp+246:16)
	lda xde, (xsp+242:16)
	calr DSP_FilterLUT_Fetch
	ld	(xsp+254), xhl
	ld	wa, (xsp+234)
	cp wa, 2:i3
	jrl z, DSP_BiquadCoeff_Algo2
	cp wa, 1:i3
	jrl z, DSP_BiquadCoeff_Algo1
	cp wa, 0:i3
	jrl nz, DSP_BiquadCoeff_Epilogue
	lda xbc, (xsp+230:16)
	lda xwa, (xsp + 78)
	call FP_ftod
	lda xbc, (xsp + 78)
	lda xde, (FPConst_DSP_BiquadCoeff_Compute_7p1237929em5:24)
	lda xwa, (xsp + 78)
	call FP_dmul
	lda xiy, (xsp + 78)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp+158:16)
	push xwa
	call FP_tan
	lda xsp, (xsp + 12)
	lda xbc, (xsp+150:16)
	lda xwa, (xsp+218:16)
	call FP_dtof
	lda xbc, (xsp+218:16)
	lda xde, (xsp+226:16)
	lda xwa, (xsp+170:16)
	call FP_fdiv
	lda xbc, (xsp+218:16)
	lda xde, (xsp+218:16)
	lda xwa, (xsp+166:16)
	call FP_fmul
	lda xbc, (xsp+170:16)
	lda xde, (xsp+166:16)
	lda xwa, (xsp + 86)
	call FP_fadd
	lda xbc, (xsp + 86)
	lda xde, (FPConst_DSP_BiquadCoeff_Compute_1:24)
	lda xwa, (xsp+214:16)
	call FP_fadd
	lda xbc, (FPConst_DSP_BiquadCoeff_Compute_1_2:24)
	lda xde, (xsp+166:16)
	lda xwa, (xsp + 86)
	call FP_fsub
	lda xbc, (xsp + 86)
	lda xde, (FPConst_DSP_BiquadCoeff_Compute_Neg2:24)
	lda xwa, (xsp+210:16)
	call FP_fmul
	lda xbc, (xsp+166:16)
	lda xde, (xsp+170:16)
	lda xwa, (xsp + 86)
	call FP_fsub
	lda xbc, (xsp + 86)
	lda xde, (FPConst_DSP_BiquadCoeff_Compute_1_3:24)
	lda xwa, (xsp+206:16)
	call FP_fadd
	lda xwa, (xsp+222:16)
	ld bc, 1:i3
	call FP_SP_CmpZero32
	cp hl, 0:i3
	jr nz, DSP_BiquadCoeff_Algo0_SignZero
	ld	xwa, (xsp+222)
	ld	(xsp+138), xwa
	jr DSP_BiquadCoeff_Algo0_AfterSign

; Algo0: gain term compared zero, so take the |x| copy path (FP_SP_CopyOrNegate4).
DSP_BiquadCoeff_Algo0_SignZero:
	lda xbc, (xsp+222:16)
	lda xwa, (xsp+138:16)
	call FP_SP_CopyOrNegate4

; Algo0: join point; divides the dB gain by 20.0 and calls pow(10, dB/20).
DSP_BiquadCoeff_Algo0_AfterSign:
	lda xbc, (xsp+138:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_AfterSign_20:24)
	lda xwa, (xsp + 86)
	call FP_fdiv
	lda xbc, (xsp + 86)
	lda xwa, (xsp + 78)
	call FP_ftod
	lda xiy, (xsp + 78)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_BiquadCoeff_Algo0_AfterSign_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp+158:16)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp+170:16)
	lda xwa, (xsp + 78)
	call FP_ftod
	lda xbc, (xsp + 78)
	lda xde, (xsp+142:16)
	lda xwa, (xsp + 78)
	call FP_dmul
	lda xbc, (xsp + 78)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_AfterSign_1:24)
	lda xwa, (xsp + 78)
	call FP_dadd
	lda xbc, (xsp+166:16)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xbc, (xsp + 118)
	lda xde, (xsp + 78)
	lda xwa, (xsp + 118)
	call FP_dadd
	lda xbc, (xsp + 118)
	lda xwa, (xsp+202:16)
	call FP_dtof
	ld	xwa, (xsp+210)
	ld	(xsp+198), xwa
	lda xwa, (xsp+222:16)
	ld bc, 1:i3
	call FP_SP_CmpZero32
	cp hl, 0:i3
	jr nz, DSP_BiquadCoeff_Algo0_Sign2Zero
	ld	xwa, (xsp+222)
	ld (xsp + 126), xwa
	jr DSP_BiquadCoeff_Algo0_AfterSign2

; Algo0: second sign test (on the intermediate a-term) took the negate path.
DSP_BiquadCoeff_Algo0_Sign2Zero:
	lda xbc, (xsp+222:16)
	lda xwa, (xsp + 126)
	call FP_SP_CopyOrNegate4

; Algo0: join point after the second sign test; continues assembling the denominator.
DSP_BiquadCoeff_Algo0_AfterSign2:
	lda xbc, (xsp + 126)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_AfterSign2_20:24)
	lda xwa, (xsp + 86)
	call FP_fdiv
	lda xbc, (xsp + 86)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xiy, (xsp + 118)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_BiquadCoeff_Algo0_AfterSign2_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp+146:16)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp+170:16)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xbc, (xsp + 118)
	lda xde, (xsp+130:16)
	lda xwa, (xsp + 118)
	call FP_dmul
	lda xbc, (FPConst_DSP_BiquadCoeff_Algo0_AfterSign2_1:24)
	lda xde, (xsp + 118)
	lda xwa, (xsp + 118)
	call FP_dsub
	lda xbc, (xsp+166:16)
	lda xwa, (xsp + 78)
	call FP_ftod
	lda xbc, (xsp + 78)
	lda xde, (xsp + 118)
	lda xwa, (xsp + 118)
	call FP_dadd
	lda xbc, (xsp + 118)
	lda xwa, (xsp+194:16)
	call FP_dtof
	lda xwa, (xsp+222:16)
	ld bc, 1:i3
	call FP_SP_CmpZero32
	cp hl, 0:i3
	jr nz, DSP_BiquadCoeff_Algo0_NegBranch
	lda xbc, (xsp+202:16)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+190:16)
	call FP_fdiv
	lda xbc, (xsp+198:16)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+186:16)
	call FP_fdiv
	lda xbc, (xsp+194:16)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	lda xbc, (xsp+210:16)
	lda xwa, (xsp + 86)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 86)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+178:16)
	call FP_fdiv
	lda xbc, (xsp+206:16)
	lda xwa, (xsp + 86)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 86)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+174:16)
	call FP_fdiv
	jr DSP_BiquadCoeff_Algo0_Assembly

; Algo0: negative-argument arm of the denominator chain (sign-corrected duplicate of the
; positive arm; it carries its own copy of the same literals).
DSP_BiquadCoeff_Algo0_NegBranch:
	lda xbc, (xsp+214:16)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+190:16)
	call FP_fdiv
	lda xbc, (xsp+210:16)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+186:16)
	call FP_fdiv
	lda xbc, (xsp+206:16)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	lda xbc, (xsp+198:16)
	lda xwa, (xsp + 86)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 86)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+178:16)
	call FP_fdiv
	lda xbc, (xsp+194:16)
	lda xwa, (xsp + 86)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 86)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+174:16)
	call FP_fdiv

; Algo0: assembles the five raw taps from K and A before normalisation.  Ends with a guard at
; 0x03AD0C: it compares the computed a0 against the float 1.0 at 0x012F9B (via
; FP_fcmp with kind DE=0, "equal") and, on a match, forces the normalisation
; factor to the literal 0x3F800000 -- IEEE-754 single 1.0 -- before falling into the Fixup
; block.  That literal is independent confirmation that this code is plain IEEE-754.
DSP_BiquadCoeff_Algo0_Assembly:
	lda xbc, (xsp+190:16)
	lda xde, (xsp+186:16)
	lda xwa, (xsp + 86)
	call FP_fadd
	lda xbc, (xsp + 86)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 86)
	call FP_fadd
	lda xbc, (FPConst_DSP_BiquadCoeff_Algo0_Assembly_1:24)
	lda xde, (xsp+178:16)
	lda xwa, (xsp + 2)
	call FP_fsub
	lda xbc, (xsp + 2)
	lda xde, (xsp+174:16)
	lda xwa, (xsp + 2)
	call FP_fsub
	lda xbc, (xsp + 2)
	lda xde, (xsp + 86)
	lda xwa, (xsp+158:16)
	call FP_fdiv
	lda xwa, (xsp+158:16)
	lda xbc, (FPConst_DSP_BiquadCoeff_Algo0_Assembly_1_2:24)
	ld de, 0:i3
	call FP_fcmp
	cp hl, 0:i3
	jr nz, DSP_BiquadCoeff_Algo0_Fixup
	ld xwa, 0x3F800000
	ld	(xsp+158), xwa

; ★ The store block, and the clearest evidence for what the whole routine is.  For each of the
; five taps it does: tap = tap * something [FP_fmul = multiply], tap = tap / a0
; [FP_fdiv = divide], tap = tap * 2^22 (0x012FAB/AF/B3/B7) -- the FIFTH tap by 2^23
; (0x012FBB) -- then FP_ftoi to convert float->int, then writes it:
;   tap 1 via DSP_WriteOscParam (0x0387E6), taps 2..5 via DSP_WriteCoeffData_5B_Direct
;   (0x0388B3).  Each write's HL status is accumulated in IZ.
; So the DSP's biquad registers are Q22 (Q23 for the last), five per section.
DSP_BiquadCoeff_Algo0_Fixup:
	lda xbc, (xsp+158:16)
	lda xde, (xsp+190:16)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_Fixup_2:24)
	lda xwa, (xsp+190:16)
	call FP_fdiv
	lda xbc, (xsp+158:16)
	lda xde, (xsp+186:16)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_Fixup_2_2:24)
	lda xwa, (xsp+186:16)
	call FP_fdiv
	lda xbc, (xsp+158:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_Fixup_2_3:24)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	lda xbc, (xsp+186:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q22One:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 114)
	call FP_ftoi
	pushw	(xsp+246)
	ld	wa, (xsp+254)
	ld xbc, (xsp + 116)
	ld	de, (xsp+238)
	call DSP_WriteOscParam
	ld iz, hl
	lda xbc, (xsp+190:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q22One_2:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 110)
	call FP_ftoi
	ld xwa, (xsp + 110)
	ld	bc, (xsp+236)
	ld	de, (xsp+246)
	call DSP_WriteCoeffData_5B_Direct
	ld iz, hl
	lda xbc, (xsp+182:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q22One_3:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 106)
	call FP_ftoi
	ld xwa, (xsp + 106)
	ld	bc, (xsp+236)
	ld	de, (xsp+246)
	call DSP_WriteCoeffData_5B_Direct
	ld iz, hl
	lda xbc, (xsp+178:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q22One_4:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 102)
	call FP_ftoi
	ld xwa, (xsp + 102)
	ld	bc, (xsp+236)
	ld	de, (xsp+246)
	call DSP_WriteCoeffData_5B_Direct
	ld iz, hl
	lda xbc, (xsp+174:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo0_Fixup_Q23One:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 98)
	call FP_ftoi
	ld xwa, (xsp + 98)
	ld	bc, (xsp+236)
	ld	de, (xsp+246)
	call DSP_WriteCoeffData_5B_Direct
	ld iz, hl
	jrl DSP_BiquadCoeff_Epilogue

; Algorithm 1 of DSP_BiquadCoeff_Compute (selector nibble == 1).  Same shape as Algo0 --
; prewarp with pi/44100 (its own copy at 0x012FBF), {1,-2,1} numerator literals at
; 0x012FC7..0x012FCF, Q22/Q23 scaling at 0x012FD7..0x012FE7 -- but a different tap topology;
; it has no separate _Assembly stage and falls straight into its own store chain.
; Not a routine in the ABI sense: entered by `jrl`, exits via DSP_BiquadCoeff_Epilogue.
DSP_BiquadCoeff_Algo1:
	lda xbc, (xsp+230:16)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xbc, (xsp + 118)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo1_7p1237929em5:24)
	lda xwa, (xsp + 118)
	call FP_dmul
	lda xiy, (xsp + 118)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 98)
	push xwa
	call FP_tan
	lda xsp, (xsp + 12)
	lda xbc, (xsp + 90)
	lda xwa, (xsp+218:16)
	call FP_dtof
	lda xbc, (xsp+218:16)
	lda xde, (xsp+226:16)
	lda xwa, (xsp+170:16)
	call FP_fdiv
	lda xbc, (xsp+218:16)
	lda xde, (xsp+218:16)
	lda xwa, (xsp+166:16)
	call FP_fmul
	lda xbc, (xsp+170:16)
	lda xde, (xsp+166:16)
	lda xwa, (xsp + 2)
	call FP_fadd
	lda xbc, (xsp + 2)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo1_1:24)
	lda xwa, (xsp+214:16)
	call FP_fadd
	lda xbc, (FPConst_DSP_BiquadCoeff_Algo1_1_2:24)
	lda xde, (xsp+166:16)
	lda xwa, (xsp + 2)
	call FP_fsub
	lda xbc, (xsp + 2)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo1_Neg2:24)
	lda xwa, (xsp+210:16)
	call FP_fmul
	lda xbc, (xsp+166:16)
	lda xde, (xsp+170:16)
	lda xwa, (xsp + 2)
	call FP_fsub
	lda xbc, (xsp + 2)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo1_1_3:24)
	lda xwa, (xsp+206:16)
	call FP_fadd
	lda xbc, (xsp+170:16)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+190:16)
	call FP_fdiv
	ld xwa, 0:i3
	ld	(xsp+186), xwa
	lda xbc, (xsp+190:16)
	lda xwa, (xsp+182:16)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp+210:16)
	lda xwa, (xsp + 2)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 2)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+178:16)
	call FP_fdiv
	lda xbc, (xsp+206:16)
	lda xwa, (xsp + 2)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 2)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+174:16)
	call FP_fdiv
	lda xbc, (xsp+186:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo1_Q22One:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 74)
	call FP_ftoi
	pushw	(xsp+246)
	ld	wa, (xsp+254)
	ld xbc, (xsp + 76)
	ld	de, (xsp+238)
	call DSP_WriteOscParam
	ld iz, hl
	lda xbc, (xsp+190:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo1_Q22One_2:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 70)
	call FP_ftoi
	ld xwa, (xsp + 70)
	ld	bc, (xsp+236)
	ld	de, (xsp+246)
	call DSP_WriteCoeffData_5B_Direct
	ld iz, hl
	lda xbc, (xsp+182:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo1_Q22One_3:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 66)
	call FP_ftoi
	ld xwa, (xsp + 66)
	ld	bc, (xsp+236)
	ld	de, (xsp+246)
	call DSP_WriteCoeffData_5B_Direct
	ld iz, hl
	lda xbc, (xsp+178:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo1_Q22One_4:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 62)
	call FP_ftoi
	ld xwa, (xsp + 62)
	ld	bc, (xsp+236)
	ld	de, (xsp+246)
	call DSP_WriteCoeffData_5B_Direct
	ld iz, hl
	lda xbc, (xsp+174:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo1_Q23One:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 58)
	call FP_ftoi
	ld xwa, (xsp + 58)
	ld	bc, (xsp+236)
	ld	de, (xsp+246)
	call DSP_WriteCoeffData_5B_Direct
	ld iz, hl
	jrl DSP_BiquadCoeff_Epilogue

; Algorithm 2 (selector nibble == 2).  The most branchy of the three: five separate copies of
; pi/44100 (0x012FEB, 0x012FF3, 0x012FFB, 0x013003, 0x01300B), one per basic block, plus two
; sign tests.  Entered by `jrl` from DSP_BiquadCoeff_Compute, exits via the shared epilogue.
DSP_BiquadCoeff_Algo2:
	lda xbc, (xsp+230:16)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xbc, (xsp + 118)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5:24)
	lda xwa, (xsp + 118)
	call FP_dmul
	lda xiy, (xsp + 118)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 58)
	push xwa
	call FP_tan
	lda xsp, (xsp + 12)
	lda xbc, (xsp + 50)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5_2:24)
	lda xwa, (xsp + 118)
	call FP_ddiv
	lda xbc, (xsp + 118)
	lda xwa, (xsp+218:16)
	call FP_dtof
	lda xbc, (xsp+218:16)
	lda xde, (xsp+226:16)
	lda xwa, (xsp + 2)
	call FP_fdiv
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xbc, (xsp + 118)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5_3:24)
	lda xwa, (xsp + 118)
	call FP_dmul
	lda xbc, (xsp + 118)
	lda xwa, (xsp+170:16)
	call FP_dtof
	lda xbc, (xsp+218:16)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xbc, (xsp + 118)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5_4:24)
	lda xwa, (xsp + 118)
	call FP_dmul
	lda xbc, (xsp+218:16)
	lda xwa, (xsp + 78)
	call FP_ftod
	lda xbc, (xsp + 78)
	lda xde, (xsp + 118)
	lda xwa, (xsp + 118)
	call FP_dmul
	lda xbc, (xsp + 118)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_7p1237929em5_5:24)
	lda xwa, (xsp + 118)
	call FP_dmul
	lda xbc, (xsp + 118)
	lda xwa, (xsp+162:16)
	call FP_dtof
	lda xbc, (xsp+170:16)
	lda xde, (xsp+162:16)
	lda xwa, (xsp + 2)
	call FP_fadd
	lda xbc, (xsp + 2)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_1:24)
	lda xwa, (xsp+214:16)
	call FP_fadd
	lda xbc, (FPConst_DSP_BiquadCoeff_Algo2_1_2:24)
	lda xde, (xsp+162:16)
	lda xwa, (xsp + 2)
	call FP_fsub
	lda xbc, (xsp + 2)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_Neg2:24)
	lda xwa, (xsp+210:16)
	call FP_fmul
	lda xbc, (xsp+162:16)
	lda xde, (xsp+170:16)
	lda xwa, (xsp + 2)
	call FP_fsub
	lda xbc, (xsp + 2)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_1_3:24)
	lda xwa, (xsp+206:16)
	call FP_fadd
	lda xwa, (xsp+222:16)
	ld bc, 1:i3
	call FP_SP_CmpZero32
	cp hl, 0:i3
	jr nz, DSP_BiquadCoeff_Algo2_Sign1Zero
	ld	xwa, (xsp+222)
	ld (xsp + 38), xwa
	jr DSP_BiquadCoeff_Algo2_AfterSign1

; Algo2: first sign test took the negate path.
DSP_BiquadCoeff_Algo2_Sign1Zero:
	lda xbc, (xsp+222:16)
	lda xwa, (xsp + 38)
	call FP_SP_CopyOrNegate4

; Algo2: join point after the first sign test; divides the dB gain by 20.0.
DSP_BiquadCoeff_Algo2_AfterSign1:
	lda xbc, (xsp + 38)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_AfterSign1_20:24)
	lda xwa, (xsp + 2)
	call FP_fdiv
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xiy, (xsp + 118)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_BiquadCoeff_Algo2_AfterSign1_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 58)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp+170:16)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xbc, (xsp + 118)
	lda xde, (xsp + 42)
	lda xwa, (xsp + 118)
	call FP_dmul
	lda xbc, (xsp + 118)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_AfterSign1_1:24)
	lda xwa, (xsp + 118)
	call FP_dadd
	lda xbc, (xsp+162:16)
	lda xwa, (xsp + 78)
	call FP_ftod
	lda xbc, (xsp + 78)
	lda xde, (xsp + 118)
	lda xwa, (xsp + 118)
	call FP_dadd
	lda xbc, (xsp + 118)
	lda xwa, (xsp+202:16)
	call FP_dtof
	ld	xwa, (xsp+210)
	ld	(xsp+198), xwa
	lda xwa, (xsp+222:16)
	ld bc, 1:i3
	call FP_SP_CmpZero32
	cp hl, 0:i3
	jr nz, DSP_BiquadCoeff_Algo2_Sign2Zero
	ld	xwa, (xsp+222)
	ld (xsp + 26), xwa
	jr DSP_BiquadCoeff_Algo2_AfterSign2

; Algo2: second sign test took the negate path.
DSP_BiquadCoeff_Algo2_Sign2Zero:
	lda xbc, (xsp+222:16)
	lda xwa, (xsp + 26)
	call FP_SP_CopyOrNegate4

; Algo2: join point after the second sign test.
DSP_BiquadCoeff_Algo2_AfterSign2:
	lda xbc, (xsp + 26)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_AfterSign2_20:24)
	lda xwa, (xsp + 2)
	call FP_fdiv
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xiy, (xsp + 118)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_BiquadCoeff_Algo2_AfterSign2_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 46)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp+170:16)
	lda xwa, (xsp + 118)
	call FP_ftod
	lda xbc, (xsp + 118)
	lda xde, (xsp + 30)
	lda xwa, (xsp + 118)
	call FP_dmul
	lda xbc, (FPConst_DSP_BiquadCoeff_Algo2_AfterSign2_1:24)
	lda xde, (xsp + 118)
	lda xwa, (xsp + 118)
	call FP_dsub
	lda xbc, (xsp+162:16)
	lda xwa, (xsp + 78)
	call FP_ftod
	lda xbc, (xsp + 78)
	lda xde, (xsp + 118)
	lda xwa, (xsp + 118)
	call FP_dadd
	lda xbc, (xsp + 118)
	lda xwa, (xsp+194:16)
	call FP_dtof
	lda xwa, (xsp+222:16)
	ld bc, 1:i3
	call FP_SP_CmpZero32
	cp hl, 0:i3
	jr nz, DSP_BiquadCoeff_Algo2_NegBranch
	lda xbc, (xsp+210:16)
	lda xwa, (xsp + 2)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 2)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+178:16)
	call FP_fdiv
	lda xbc, (xsp+206:16)
	lda xwa, (xsp + 2)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 2)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+174:16)
	call FP_fdiv
	lda xbc, (xsp+202:16)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+190:16)
	call FP_fdiv
	lda xbc, (xsp+198:16)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+186:16)
	call FP_fdiv
	lda xbc, (xsp+194:16)
	lda xde, (xsp+214:16)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	jr DSP_BiquadCoeff_Algo2_WriteParams

; Algo2: negative-argument arm of the final chain.
DSP_BiquadCoeff_Algo2_NegBranch:
	lda xbc, (xsp+198:16)
	lda xwa, (xsp + 2)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 2)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+178:16)
	call FP_fdiv
	lda xbc, (xsp+194:16)
	lda xwa, (xsp + 2)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp + 2)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+174:16)
	call FP_fdiv
	lda xbc, (xsp+214:16)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+190:16)
	call FP_fdiv
	lda xbc, (xsp+210:16)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+186:16)
	call FP_fdiv
	lda xbc, (xsp+206:16)
	lda xde, (xsp+202:16)
	lda xwa, (xsp+182:16)
	call FP_fdiv

; Algo2's store block: scales by 2^22 (0x01304B, 0x01304F, 0x013057, 0x01305B) and 2^23
; (0x013053), converts to integer and emits five coefficients exactly like
; DSP_BiquadCoeff_Algo0_Fixup.
DSP_BiquadCoeff_Algo2_WriteParams:
	lda xbc, (xsp+186:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q22One:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 22)
	call FP_ftoi
	pushw	(xsp+246)
	ld	wa, (xsp+254)
	ld xbc, (xsp + 24)
	ld	de, (xsp+238)
	call DSP_WriteOscParam
	ld iz, hl
	lda xbc, (xsp+182:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q22One_2:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 18)
	call FP_ftoi
	ld xwa, (xsp + 18)
	ld	bc, (xsp+236)
	call DSP_WriteParamWord
	ld iz, hl
	lda xbc, (xsp+174:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q23One:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 14)
	call FP_ftoi
	ld xwa, (xsp + 14)
	ld	bc, (xsp+236)
	call DSP_WriteParamWord
	ld iz, hl
	lda xbc, (xsp+190:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q22One_3:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 10)
	call FP_ftoi
	ld xwa, (xsp + 10)
	ld	bc, (xsp+236)
	call DSP_WriteParamWord
	ld iz, hl
	lda xbc, (xsp+178:16)
	lda xde, (FPConst_DSP_BiquadCoeff_Algo2_WriteParams_Q22One_4:24)
	lda xwa, (xsp + 2)
	call FP_fmul
	lda xbc, (xsp + 2)
	lda xwa, (xsp + 6)
	call FP_ftoi
	ld xwa, (xsp + 6)
	ld	bc, (xsp+236)
	call DSP_WriteParamWord
	ld iz, hl

; Common exit for all three algorithms AND for the "unknown selector" fall-through.
;   *(arg5 pointer at frame+0x00F2) = IZ  (accumulated DSP write status)
;   XHL = the stream pointer saved at frame+0x00FE by the DSP_FilterLUT_Fetch call
;   pop IZ, lda XSP,XSP+0xEC, retd 0x10.
DSP_BiquadCoeff_Epilogue:
	ld	xwa, (xsp+242)
	ld (xwa), iz
	ld	xhl, (xsp+254)
	popw iz
	lda xsp, (xsp+236:16)
	retd 0x10

; Parses one second-order-section header out of the DSP parameter stream and returns the band
; frequency and the band gain as floats.  Called only by DSP_SOS_Coeff_Compute (`calr`).
; In:  WA = parameter index (kept in IZ), XBC and XDE = out-pointers for the two floats,
;      3 stack args (retd 0x0C): the stream pointer, the caller's per-parameter word array,
;      and the out-pointer for the TYPE nibble.
; Out: XHL = advanced stream pointer; *(type ptr) = header_byte & 0x0F -- this is the value
;      DSP_SOS_Coeff_Compute switches on to pick algorithm 0/1/2.
; Body: reads the header byte, keeps its low nibble as the type and its high nibble as the
;   indexing mode.  Mode 0x10 (DSP_SOS_LUT_Mode0x10) uses word[IZ-1] for the frequency and
;   word[IZ] for the gain; every other mode uses word[IZ] and word[IZ+1].  The frequency word
;   indexes the ISO 1/3-octave float table at 0x012397 (copied out with FP_SP_Raw4Copy).  The
;   gain word is widened with FP_ScalarToDP then mapped to dB as raw*0.5 - 12.0
;   (FP_dmul with 0.5 at 0x01305F = multiply, then FP_dadd with -12.0 at 0x013067 =
;   add) and narrowed back to a float.
; If the type nibble is 2 it consumes ONE MORE stream byte, masks it with 0x1F and re-fetches
; the frequency float from 0x012397 with that index -- i.e. indices 27..31 select the
; 0.1/0.2/0.3/0.4/0.5 constants that follow the frequency table.
DSP_SOS_LUT_Fetch:
	lda xsp, (xsp - 34)
	pushw iz
	ld (xsp + 28), xde
	ld (xsp + 32), xbc
	ld iz, wa
	ld xwa, (xsp + 40)
	ld a, (xwa)
	and a, 0xF
	extz wa
	ld (xsp + 2), wa
	ld xwa, (xsp + 40)
	ld C, (xwa+)
	ld (xsp + 40), xwa
	and c, 0xF0
	ld a, c
	cp a, 0x10
	jr z, DSP_SOS_LUT_Mode0x10
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 44)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_FreqHz_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 24)
	call FP_SP_Raw4Copy
	ld wa, iz
	inc 1, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 44)
	ld wa, (xwa)
	exts xwa
	ld (xsp + 4), xwa
	lda xbc, (xsp + 4)
	lda xwa, (xsp + 12)
	call FP_ScalarToDP
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_SOS_LUT_Fetch_0p5:24)
	lda xwa, (xsp + 12)
	call FP_dmul
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_SOS_LUT_Fetch_Neg12:24)
	lda xwa, (xsp + 12)
	call FP_dadd
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 20)
	call FP_dtof
	jr DSP_SOS_LUT_CheckType2

; Alternate indexing when the header's high nibble is 0x10: frequency from word[IZ-1], gain
; from word[IZ]; own copies of the 0.5 / -12.0 dB literals at 0x01306F / 0x013077.
DSP_SOS_LUT_Mode0x10:
	ld wa, iz
	dec 1, wa
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 44)
	ld wa, (xwa)
	sla wa, 2
	lda xbc, (DSP_EQ_FreqHz_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 24)
	call FP_SP_Raw4Copy
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 44)
	ld wa, (xwa)
	exts xwa
	ld (xsp + 8), xwa
	lda xbc, (xsp + 8)
	lda xwa, (xsp + 12)
	call FP_ScalarToDP
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_SOS_LUT_Mode0x10_0p5:24)
	lda xwa, (xsp + 12)
	call FP_dmul
	lda xbc, (xsp + 12)
	lda xde, (FPConst_DSP_SOS_LUT_Mode0x10_Neg12:24)
	lda xwa, (xsp + 12)
	call FP_dadd
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 20)
	call FP_dtof

; Join point; if the type nibble is 2, consume one extra stream byte and re-fetch the float
; from 0x012397 masked with 0x1F.
DSP_SOS_LUT_CheckType2:
	ld wa, (xsp + 2)
	cp wa, 2:i3
	jr nz, DSP_SOS_LUT_StoreResults
	ld xwa, (xsp + 40)
	ld C, (xwa+)
	ld (xsp + 40), xwa
	and c, 0x1F
	ld a, c
	extz wa
	sla wa, 2
	lda xbc, (DSP_EQ_FreqHz_Table:24)
	lda	xbc, (xbc+wa)
	lda xwa, (xsp + 24)
	call FP_SP_Raw4Copy

; Writes the type nibble, the frequency float and the gain float through the three
; out-pointers, returns XHL = stream pointer, `retd 0x0C`.
DSP_SOS_LUT_StoreResults:
	ld xbc, (xsp + 48)
	ld wa, (xsp + 2)
	ld (xbc), wa
	ld xbc, (xsp + 32)
	ld xwa, (xsp + 24)
	ld (xbc), xwa
	ld xbc, (xsp + 28)
	ld xwa, (xsp + 20)
	ld (xbc), xwa
	ld xhl, (xsp + 40)
	popw iz
	lda xsp, (xsp + 34)
	retd 0xC

; Designs one RBJ-cookbook second-order section and writes its coefficients to the DSP.
; Reached only from the opcode-0x76 dispatch arm (0x03CE42).  Same five-stack-arg convention
; as DSP_BiquadCoeff_Compute (`retd 0x10`), same "return the advanced stream pointer in XHL
; and the accumulated write status through the last pointer arg" contract.
; Differs from the biquad family in the prewarp: it uses the FULL angle
;   w0 = f * 2*pi/44100  (literal 1.424758573e-04 at 0x01308B and its per-block copies)
; rather than the half angle, which is the signature of the sin(w0)/cos(w0) cookbook form.
; Selector: the type nibble returned by DSP_SOS_LUT_Fetch; 2 -> DSP_SOS_Algo2,
; 1 -> DSP_SOS_Algo1, 0 -> falls through, anything else -> DSP_SOS_Coeff_Epilogue with NO
; writes at all.
DSP_SOS_Coeff_Compute:
	lda xsp, (xsp-210)
	push xiz
	ld iz, wa
	lda xwa, (xsp+176:16)
	push xwa
	ld	xwa, (xsp+228)
	push xwa
	ld	xwa, (xsp+238)
	push xwa
	ld wa, de
	lda xbc, (xsp+222:16)
	lda xde, (xsp+218:16)
	calr DSP_SOS_LUT_Fetch
	ld	(xsp+230), xhl
	ld	wa, (xsp+176)
	cp wa, 2:i3
	jrl z, DSP_SOS_Algo2
	cp wa, 1:i3
	jrl z, DSP_SOS_Algo1
	cp wa, 0:i3
	jrl nz, DSP_SOS_Coeff_Epilogue
	lda xbc, (xsp+206:16)
	lda xde, (FPConst_DSP_SOS_Coeff_Compute_20:24)
	lda xwa, (xsp + 56)
	call FP_fdiv
	lda xbc, (xsp + 56)
	lda xwa, (xsp + 72)
	call FP_ftod
	lda xiy, (xsp + 72)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_SOS_Coeff_Compute_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp+184:16)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp+168:16)
	lda xwa, (xsp+178:16)
	call FP_dtof
	lda xwa, (xsp+206:16)
	ld bc, 1:i3
	call FP_SP_CmpZero32
	cp hl, 0:i3
	jrl nz, DSP_SOS_Algo0_NonzeroCoeff
	lda xbc, (xsp+210:16)
	lda xwa, (xsp + 72)
	call FP_ftod
	lda xbc, (xsp + 72)
	lda xde, (FPConst_DSP_SOS_Coeff_Compute_0p00014247586:24)
	lda xwa, (xsp + 72)
	call FP_dmul
	lda xiy, (xsp + 72)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp+168:16)
	push xwa
	call FP_cos
	lda xbc, (xsp+222:16)
	lda xwa, (xsp + 84)
	call FP_ftod
	lda xbc, (xsp + 84)
	lda xde, (FPConst_DSP_SOS_Coeff_Compute_0p00014247586_2:24)
	lda xwa, (xsp + 84)
	call FP_dmul
	lda xiy, (xsp + 84)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp+172:16)
	push xwa
	call FP_sin
	lda xsp, (xsp + 24)
	lda xbc, (xsp+152:16)
	lda xde, (FPConst_DSP_SOS_Coeff_Compute_1:24)
	lda xwa, (xsp + 72)
	call FP_dsub
	lda xbc, (xsp + 72)
	lda xde, (xsp+160:16)
	lda xwa, (xsp + 72)
	call FP_ddiv
	lda xbc, (xsp + 72)
	lda xwa, (xsp+202:16)
	call FP_dtof
	lda xbc, (FPConst_DSP_SOS_Coeff_Compute_1_2:24)
	lda xde, (xsp+202:16)
	lda xwa, (xsp + 56)
	call FP_fsub
	lda xbc, (xsp+202:16)
	lda xde, (FPConst_DSP_SOS_Coeff_Compute_1_3:24)
	lda xwa, (xsp + 120)
	call FP_fadd
	lda xbc, (xsp + 120)
	lda xde, (xsp + 56)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 120)
	call FP_fdiv
	lda xbc, (FPConst_DSP_SOS_Coeff_Compute_1_4:24)
	lda xde, (xsp + 120)
	lda xwa, (xsp + 120)
	call FP_fsub
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 56)
	call FP_fdiv
	lda xbc, (xsp + 56)
	lda xde, (FPConst_DSP_SOS_Coeff_Compute_1_5:24)
	lda xwa, (xsp + 56)
	call FP_fadd
	lda xbc, (xsp + 120)
	lda xde, (xsp + 56)
	lda xwa, (xsp+198:16)
	call FP_fdiv
	jrl DSP_SOS_Algo0_FinalChain

; Algo0: arm taken when the tested coefficient is non-zero (the zero arm skips a whole
; multiply chain).
DSP_SOS_Algo0_NonzeroCoeff:
	lda xbc, (xsp+210:16)
	lda xwa, (xsp + 72)
	call FP_ftod
	lda xbc, (xsp + 72)
	lda xde, (FPConst_DSP_SOS_Algo0_NonzeroCoeff_0p00014247586:24)
	lda xwa, (xsp + 72)
	call FP_dmul
	lda xiy, (xsp + 72)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp+152:16)
	push xwa
	call FP_cos
	lda xbc, (xsp+222:16)
	lda xwa, (xsp + 84)
	call FP_ftod
	lda xbc, (xsp + 84)
	lda xde, (FPConst_DSP_SOS_Algo0_NonzeroCoeff_0p00014247586_2:24)
	lda xwa, (xsp + 84)
	call FP_dmul
	lda xiy, (xsp + 84)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp+156:16)
	push xwa
	call FP_sin
	lda xsp, (xsp + 24)
	lda xbc, (xsp+136:16)
	lda xde, (FPConst_DSP_SOS_Algo0_NonzeroCoeff_1:24)
	lda xwa, (xsp + 72)
	call FP_dsub
	lda xbc, (xsp + 72)
	lda xde, (xsp+144:16)
	lda xwa, (xsp + 72)
	call FP_ddiv
	lda xbc, (xsp + 72)
	lda xwa, (xsp+198:16)
	call FP_dtof
	lda xbc, (xsp+198:16)
	lda xde, (FPConst_DSP_SOS_Algo0_NonzeroCoeff_1_2:24)
	lda xwa, (xsp + 120)
	call FP_fadd
	lda xbc, (FPConst_DSP_SOS_Algo0_NonzeroCoeff_1_3:24)
	lda xde, (xsp+198:16)
	lda xwa, (xsp + 56)
	call FP_fsub
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 120)
	call FP_fdiv
	lda xbc, (xsp + 120)
	lda xde, (FPConst_DSP_SOS_Algo0_NonzeroCoeff_1_4:24)
	lda xwa, (xsp + 120)
	call FP_fadd
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 56)
	call FP_fdiv
	lda xbc, (xsp + 56)
	lda xde, (FPConst_DSP_SOS_Algo0_NonzeroCoeff_1_5:24)
	lda xwa, (xsp + 56)
	call FP_fsub
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+202:16)
	call FP_fdiv

; Algo0's store block: normalises by a0 (FP_fdiv = divide), scales by 2^22
; (0x0130E3, 0x0130E7), converts float->int and emits the taps through DSP_WriteOscParam /
; DSP_WriteCoeffData_5B_Direct, accumulating status in IZ.
DSP_SOS_Algo0_FinalChain:
	lda xbc, (FPConst_DSP_SOS_Algo0_FinalChain_1:24)
	lda xde, (xsp+202:16)
	lda xwa, (xsp + 120)
	call FP_fsub
	lda xbc, (FPConst_DSP_SOS_Algo0_FinalChain_1_2:24)
	lda xde, (xsp+198:16)
	lda xwa, (xsp + 56)
	call FP_fsub
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+194:16)
	call FP_fdiv
	lda xbc, (xsp+202:16)
	lda xde, (xsp+194:16)
	lda xwa, (xsp+190:16)
	call FP_fmul
	lda xbc, (xsp+198:16)
	lda xwa, (xsp+186:16)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp+190:16)
	lda xde, (FPConst_DSP_SOS_Algo0_FinalChain_Q22One:24)
	lda xwa, (xsp + 120)
	call FP_fmul
	lda xbc, (xsp + 120)
	lda xwa, (xsp+132:16)
	call FP_ftoi
	pushw	(xsp+218)
	ld	wa, (xsp+230)
	ld	xbc, (xsp+134)
	ld de, iz
	call DSP_WriteOscParam
	ldfr_werp HL, 0xFA
	lda xbc, (xsp+186:16)
	lda xde, (FPConst_DSP_SOS_Algo0_FinalChain_Q22One_2:24)
	lda xwa, (xsp + 120)
	call FP_fmul
	lda xbc, (xsp + 120)
	lda xwa, (xsp+128:16)
	call FP_ftoi
	ld	xwa, (xsp+128)
	ld bc, iz
	call DSP_WriteParamWord
	ldfr_werp HL, 0xFA
	lda xbc, (xsp+194:16)
	lda xde, (FPConst_DSP_SOS_Algo0_FinalChain_Q22One_3:24)
	lda xwa, (xsp + 120)
	call FP_fmul
	lda xbc, (xsp + 120)
	lda xwa, (xsp + 124)
	call FP_ftoi
	ld xwa, (xsp + 124)
	ld bc, iz
	call DSP_WriteParamWord
	ldfr_werp HL, 0xFA
	jrl DSP_SOS_Coeff_Epilogue

; Second-order-section algorithm 1 (type nibble == 1).  Own literal block at
; 0x0130EF..0x01315B; note the 2^21 scale (2097152.0 at 0x013153 / 0x01315B) instead of 2^22,
; i.e. this topology's coefficients need one more headroom bit.
; Entered by `jrl`, exits via DSP_SOS_Coeff_Epilogue.
DSP_SOS_Algo1:
	lda xbc, (xsp+206:16)
	lda xde, (FPConst_DSP_SOS_Algo1_20:24)
	lda xwa, (xsp + 120)
	call FP_fdiv
	lda xbc, (xsp + 120)
	lda xwa, (xsp + 72)
	call FP_ftod
	lda xiy, (xsp + 72)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_SOS_Algo1_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp+128:16)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 112)
	lda xwa, (xsp+178:16)
	call FP_dtof
	lda xwa, (xsp+206:16)
	ld bc, 1:i3
	call FP_SP_CmpZero32
	cp hl, 0:i3
	jrl nz, DSP_SOS_Algo1_NonzeroCoeff
	lda xbc, (xsp+210:16)
	lda xwa, (xsp + 72)
	call FP_ftod
	lda xbc, (xsp + 72)
	lda xde, (FPConst_DSP_SOS_Algo1_0p00014247586:24)
	lda xwa, (xsp + 72)
	call FP_dmul
	lda xiy, (xsp + 72)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 112)
	push xwa
	call FP_cos
	lda xbc, (xsp+222:16)
	lda xwa, (xsp + 84)
	call FP_ftod
	lda xbc, (xsp + 84)
	lda xde, (FPConst_DSP_SOS_Algo1_0p00014247586_2:24)
	lda xwa, (xsp + 84)
	call FP_dmul
	lda xiy, (xsp + 84)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 116)
	push xwa
	call FP_sin
	lda xsp, (xsp + 24)
	lda xbc, (xsp + 96)
	lda xde, (FPConst_DSP_SOS_Algo1_1:24)
	lda xwa, (xsp + 72)
	call FP_dsub
	lda xbc, (xsp + 72)
	lda xde, (xsp + 104)
	lda xwa, (xsp + 72)
	call FP_ddiv
	lda xbc, (xsp + 72)
	lda xwa, (xsp+202:16)
	call FP_dtof
	lda xbc, (xsp+202:16)
	lda xde, (FPConst_DSP_SOS_Algo1_1_2:24)
	lda xwa, (xsp + 120)
	call FP_fadd
	lda xbc, (FPConst_DSP_SOS_Algo1_1_3:24)
	lda xde, (xsp+202:16)
	lda xwa, (xsp + 56)
	call FP_fsub
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 120)
	call FP_fdiv
	lda xbc, (xsp + 120)
	lda xde, (FPConst_DSP_SOS_Algo1_1_4:24)
	lda xwa, (xsp + 120)
	call FP_fadd
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 56)
	call FP_fdiv
	lda xbc, (xsp + 56)
	lda xde, (FPConst_DSP_SOS_Algo1_1_5:24)
	lda xwa, (xsp + 56)
	call FP_fsub
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+198:16)
	call FP_fdiv
	jrl DSP_SOS_Algo1_FinalChain

; Algo1: non-zero-coefficient arm.
DSP_SOS_Algo1_NonzeroCoeff:
	lda xbc, (xsp+210:16)
	lda xwa, (xsp + 72)
	call FP_ftod
	lda xbc, (xsp + 72)
	lda xde, (FPConst_DSP_SOS_Algo1_NonzeroCoeff_0p00014247586:24)
	lda xwa, (xsp + 72)
	call FP_dmul
	lda xiy, (xsp + 72)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 96)
	push xwa
	call FP_cos
	lda xbc, (xsp+222:16)
	lda xwa, (xsp + 84)
	call FP_ftod
	lda xbc, (xsp + 84)
	lda xde, (FPConst_DSP_SOS_Algo1_NonzeroCoeff_0p00014247586_2:24)
	lda xwa, (xsp + 84)
	call FP_dmul
	lda xiy, (xsp + 84)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 100)
	push xwa
	call FP_sin
	lda xsp, (xsp + 24)
	lda xbc, (xsp + 80)
	lda xde, (FPConst_DSP_SOS_Algo1_NonzeroCoeff_1:24)
	lda xwa, (xsp + 72)
	call FP_dsub
	lda xbc, (xsp + 72)
	lda xde, (xsp + 88)
	lda xwa, (xsp + 72)
	call FP_ddiv
	lda xbc, (xsp + 72)
	lda xwa, (xsp+198:16)
	call FP_dtof
	lda xbc, (FPConst_DSP_SOS_Algo1_NonzeroCoeff_1_2:24)
	lda xde, (xsp+198:16)
	lda xwa, (xsp + 120)
	call FP_fsub
	lda xbc, (xsp+198:16)
	lda xde, (FPConst_DSP_SOS_Algo1_NonzeroCoeff_1_3:24)
	lda xwa, (xsp + 56)
	call FP_fadd
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 120)
	call FP_fdiv
	lda xbc, (FPConst_DSP_SOS_Algo1_NonzeroCoeff_1_4:24)
	lda xde, (xsp + 120)
	lda xwa, (xsp + 120)
	call FP_fsub
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 56)
	call FP_fdiv
	lda xbc, (xsp + 56)
	lda xde, (FPConst_DSP_SOS_Algo1_NonzeroCoeff_1_5:24)
	lda xwa, (xsp + 56)
	call FP_fadd
	lda xbc, (xsp + 120)
	lda xde, (xsp + 56)
	lda xwa, (xsp+202:16)
	call FP_fdiv

; Algo1's normalise / scale / float->int / write chain.
DSP_SOS_Algo1_FinalChain:
	lda xbc, (xsp+202:16)
	lda xde, (FPConst_DSP_SOS_Algo1_FinalChain_1:24)
	lda xwa, (xsp + 120)
	call FP_fadd
	lda xbc, (xsp+198:16)
	lda xde, (FPConst_DSP_SOS_Algo1_FinalChain_1_2:24)
	lda xwa, (xsp + 56)
	call FP_fadd
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+194:16)
	call FP_fdiv
	lda xbc, (xsp+202:16)
	lda xde, (xsp+194:16)
	lda xwa, (xsp+190:16)
	call FP_fmul
	lda xbc, (xsp+198:16)
	lda xwa, (xsp+186:16)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp+190:16)
	lda xde, (FPConst_DSP_SOS_Algo1_FinalChain_Q21One:24)
	lda xwa, (xsp + 120)
	call FP_fmul
	lda xbc, (xsp + 120)
	lda xwa, (xsp + 68)
	call FP_ftoi
	pushw	(xsp+218)
	ld	wa, (xsp+230)
	ld xbc, (xsp + 70)
	ld de, iz
	call DSP_WriteOscParam
	ldfr_werp HL, 0xFA
	lda xbc, (xsp+186:16)
	lda xde, (FPConst_DSP_SOS_Algo1_FinalChain_Q22One:24)
	lda xwa, (xsp + 120)
	call FP_fmul
	lda xbc, (xsp + 120)
	lda xwa, (xsp + 64)
	call FP_ftoi
	ld xwa, (xsp + 64)
	ld bc, iz
	call DSP_WriteParamWord
	ldfr_werp HL, 0xFA
	lda xbc, (xsp+194:16)
	lda xde, (FPConst_DSP_SOS_Algo1_FinalChain_Q21One_2:24)
	lda xwa, (xsp + 120)
	call FP_fmul
	lda xbc, (xsp + 120)
	lda xwa, (xsp + 60)
	call FP_ftoi
	ld xwa, (xsp + 60)
	ld bc, iz
	call DSP_WriteParamWord
	ldfr_werp HL, 0xFA
	jrl DSP_SOS_Coeff_Epilogue

; Second-order-section algorithm 2 (type nibble == 2) -- the variant that also consumed the
; extra stream byte in DSP_SOS_LUT_Fetch.  Literal block 0x01315F..0x0131CB, 2^22 scaling.
; Entered by `jrl`, exits via DSP_SOS_Coeff_Epilogue.
DSP_SOS_Algo2:
	lda xbc, (xsp+206:16)
	lda xde, (FPConst_DSP_SOS_Algo2_20:24)
	lda xwa, (xsp + 120)
	call FP_fdiv
	lda xbc, (xsp + 120)
	lda xwa, (xsp + 72)
	call FP_ftod
	lda xiy, (xsp + 72)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (FPConst_DSP_SOS_Algo2_10:24)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 64)
	push xwa
	call FP_pow
	lda xsp, (xsp + 20)
	lda xbc, (xsp + 48)
	lda xwa, (xsp+178:16)
	call FP_dtof
	lda xwa, (xsp+206:16)
	ld bc, 1:i3
	call FP_SP_CmpZero32
	cp hl, 0:i3
	jrl nz, DSP_SOS_Algo2_NonzeroCoeff
	lda xbc, (xsp+210:16)
	lda xwa, (xsp + 72)
	call FP_ftod
	lda xbc, (xsp + 72)
	lda xde, (FPConst_DSP_SOS_Algo2_0p00014247586:24)
	lda xwa, (xsp + 72)
	call FP_dmul
	lda xiy, (xsp + 72)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 48)
	push xwa
	call FP_cos
	lda xbc, (xsp+222:16)
	lda xwa, (xsp + 84)
	call FP_ftod
	lda xbc, (xsp + 84)
	lda xde, (FPConst_DSP_SOS_Algo2_0p00014247586_2:24)
	lda xwa, (xsp + 84)
	call FP_dmul
	lda xiy, (xsp + 84)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 52)
	push xwa
	call FP_sin
	lda xsp, (xsp + 24)
	lda xbc, (xsp + 32)
	lda xde, (FPConst_DSP_SOS_Algo2_1:24)
	lda xwa, (xsp + 72)
	call FP_dsub
	lda xbc, (xsp + 72)
	lda xde, (xsp + 40)
	lda xwa, (xsp + 72)
	call FP_ddiv
	lda xbc, (xsp + 72)
	lda xwa, (xsp+202:16)
	call FP_dtof
	lda xbc, (xsp+202:16)
	lda xde, (FPConst_DSP_SOS_Algo2_1_2:24)
	lda xwa, (xsp + 120)
	call FP_fadd
	lda xbc, (FPConst_DSP_SOS_Algo2_1_3:24)
	lda xde, (xsp+202:16)
	lda xwa, (xsp + 56)
	call FP_fsub
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 120)
	call FP_fdiv
	lda xbc, (xsp + 120)
	lda xde, (FPConst_DSP_SOS_Algo2_1_4:24)
	lda xwa, (xsp + 120)
	call FP_fadd
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 56)
	call FP_fdiv
	lda xbc, (xsp + 56)
	lda xde, (FPConst_DSP_SOS_Algo2_1_5:24)
	lda xwa, (xsp + 56)
	call FP_fsub
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+198:16)
	call FP_fdiv
	jrl DSP_SOS_Algo2_FinalChain

; Algo2: non-zero-coefficient arm.
DSP_SOS_Algo2_NonzeroCoeff:
	lda xbc, (xsp+210:16)
	lda xwa, (xsp + 72)
	call FP_ftod
	lda xbc, (xsp + 72)
	lda xde, (FPConst_DSP_SOS_Algo2_NonzeroCoeff_0p00014247586:24)
	lda xwa, (xsp + 72)
	call FP_dmul
	lda xiy, (xsp + 72)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 32)
	push xwa
	call FP_cos
	lda xbc, (xsp+222:16)
	lda xwa, (xsp + 84)
	call FP_ftod
	lda xbc, (xsp + 84)
	lda xde, (FPConst_DSP_SOS_Algo2_NonzeroCoeff_0p00014247586_2:24)
	lda xwa, (xsp + 84)
	call FP_dmul
	lda xiy, (xsp + 84)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 36)
	push xwa
	call FP_sin
	lda xsp, (xsp + 24)
	lda xbc, (xsp + 16)
	lda xde, (FPConst_DSP_SOS_Algo2_NonzeroCoeff_1:24)
	lda xwa, (xsp + 72)
	call FP_dsub
	lda xbc, (xsp + 72)
	lda xde, (xsp + 24)
	lda xwa, (xsp + 72)
	call FP_ddiv
	lda xbc, (xsp + 72)
	lda xwa, (xsp+198:16)
	call FP_dtof
	lda xbc, (FPConst_DSP_SOS_Algo2_NonzeroCoeff_1_2:24)
	lda xde, (xsp+198:16)
	lda xwa, (xsp + 120)
	call FP_fsub
	lda xbc, (xsp+198:16)
	lda xde, (FPConst_DSP_SOS_Algo2_NonzeroCoeff_1_3:24)
	lda xwa, (xsp + 56)
	call FP_fadd
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+182:16)
	call FP_fdiv
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 120)
	call FP_fdiv
	lda xbc, (FPConst_DSP_SOS_Algo2_NonzeroCoeff_1_4:24)
	lda xde, (xsp + 120)
	lda xwa, (xsp + 120)
	call FP_fsub
	lda xbc, (xsp+178:16)
	lda xde, (xsp+182:16)
	lda xwa, (xsp + 56)
	call FP_fdiv
	lda xbc, (xsp + 56)
	lda xde, (FPConst_DSP_SOS_Algo2_NonzeroCoeff_1_5:24)
	lda xwa, (xsp + 56)
	call FP_fadd
	lda xbc, (xsp + 120)
	lda xde, (xsp + 56)
	lda xwa, (xsp+202:16)
	call FP_fdiv

; Algo2's normalise / scale / float->int / write chain.
DSP_SOS_Algo2_FinalChain:
	lda xbc, (xsp+202:16)
	lda xde, (FPConst_DSP_SOS_Algo2_FinalChain_1:24)
	lda xwa, (xsp + 120)
	call FP_fadd
	lda xbc, (xsp+198:16)
	lda xde, (FPConst_DSP_SOS_Algo2_FinalChain_1_2:24)
	lda xwa, (xsp + 56)
	call FP_fadd
	lda xbc, (xsp + 56)
	lda xde, (xsp + 120)
	lda xwa, (xsp+194:16)
	call FP_fdiv
	ld	xwa, (xsp+202)
	ld	(xsp+190), xwa
	lda xbc, (xsp+198:16)
	lda xwa, (xsp+186:16)
	call FP_SP_CopyOrNegate4
	lda xbc, (xsp+186:16)
	lda xde, (FPConst_DSP_SOS_Algo2_FinalChain_Q22One:24)
	lda xwa, (xsp + 120)
	call FP_fmul
	lda xbc, (xsp + 120)
	lda xwa, (xsp + 12)
	call FP_ftoi
	pushw	(xsp+218)
	ld	wa, (xsp+230)
	ld xbc, (xsp + 14)
	ld de, iz
	call DSP_WriteOscParam
	ldfr_werp HL, 0xFA
	lda xbc, (xsp+194:16)
	lda xde, (FPConst_DSP_SOS_Algo2_FinalChain_Q22One_2:24)
	lda xwa, (xsp + 120)
	call FP_fmul
	lda xbc, (xsp + 120)
	lda xwa, (xsp + 8)
	call FP_ftoi
	ld xwa, (xsp + 8)
	ld bc, iz
	ld	de, (xsp+218)
	call DSP_WriteCoeffData_5B_Direct
	ldfr_werp HL, 0xFA
	lda xbc, (xsp+190:16)
	lda xde, (FPConst_DSP_SOS_Algo2_FinalChain_Q22One_3:24)
	lda xwa, (xsp + 120)
	call FP_fmul
	lda xbc, (xsp + 120)
	lda xwa, (xsp + 4)
	call FP_ftoi
	ld xwa, (xsp + 4)
	ld bc, iz
	ld	de, (xsp+218)
	call DSP_WriteCoeffData_5B_Direct
	ldfr_werp HL, 0xFA

; Common exit: *(status-out pointer at frame+0x00DC) = IZ; XHL = advanced stream pointer from
; frame+0x00E6; pop XIZ; lda XSP,XSP+0xD2; retd 0x10.
DSP_SOS_Coeff_Epilogue:
	ld	xbc, (xsp+220)
	ldto_werp WA, 0xFA
	ld (xbc), wa
	ld	xhl, (xsp+230)
	pop xiz
	lda xsp, (xsp+210:16)
	retd 0x10

; Computes a two-stage integer mixer gain and writes it to DSP registers 0xD0 and 0xD3.
; Called twice from region 11 (0x034360-area, the output-routing layer).
; In:  WA = index A, BC = curve index, DE = index B.  32 bytes of locals + `push XIZ`, `ret`
;      (no stack args).
; Body: g = long[0x000131CF + 4*BC] >> 15;  g = MulAccum64(g, long[0x00F140 + 4*WA] >> 16);
;       g = MulAccum64(g, long[0x00F140 + 4*DE] >> 15)  -- Math_Multiply32 at 0x03D8CA is a
;       32x32 -> 64 fixed-point multiply-accumulate, so this is Q15/Q16 arithmetic.
;       ⚠ CORRECTED 2026-08-21: 0x00F140 is NOT a "live per-slot volume array". The payload
;       image supplies a 128-entry u32 GAIN CURVE there (0x00F140-0x00F33F, strictly increasing,
;       ending at exactly 0x7FFFFF00 -- same length and same terminator as DSP_MixerGain_Curve at
;       0x0131CF, which this routine multiplies it against).
;       [INFERENCE] WA and DE are curve INDICES, not slot numbers: this routine applies no bounds
;       check to either (all three sites are a bare `lda_d16 xbc, 61760 / extz xwa / add xwa, xbc
;       / ld xwa, (xwa)`), and they are two of the three mixer parameters the main CPU sets
;       through CmdHandler2C global sub-commands 0x01 and 0x06 (DRAM 0x45B2 and 0x45B6). An index
;       above 127 reads past the curve into the double-precision constant pool at 0x00F34E.
;       The same WA index is then run through FP_SP_CallWithBuf8 / FP_ftoi to get a
;       second, float-derived integer.
; Writes, for each of the two results, the sequence
;       DSP_DispatchCommand(0x30) ; DispatchData(0x00) ; DispatchData(0xD0 or 0xD3) ;
;       DispatchData(hi byte) ; DispatchData(lo byte) ; DSP2_SPI_BusIdle ;
;       DSP_Bytecode_NotifyStateChange
; on chip 1 (DSP2 / MN19413).  ★ Note the two NotifyStateChange calls: each is a preemptive
; task yield in the MIDDLE of the register-write sequence (see [UNCERTAIN]).
DSP_MixerCoeff_Compute:
	lda xsp, (xsp - 20)
	push xiz
	ld (xsp + 20), de
	ld (xsp + 22), wa
	ld wa, bc
	extz xwa
	sll xwa, 2
	ld xbc, DSP_MixerGain_Curve
	add xbc, xwa
	ld xde, (xbc)
	srl xde, 15
	ld wa, (xsp + 22)
	sll wa, 2
	lda xbc, (DSP2_MixerGain_Curve:16)
	extz xwa
	add xwa, xbc
	ld xwa, (xwa)
	sra xwa, 16
	ld xbc, xde
	call Math_Multiply32
	srl xhl, 16
	ld wa, (xsp + 20)
	sll wa, 2
	lda xbc, (DSP2_MixerGain_Curve:16)
	extz xwa
	add xwa, xbc
	ld xwa, (xwa)
	sra xwa, 15
	ld xbc, xhl
	call Math_Multiply32
	ld (xsp + 8), xhl
	ld wa, (xsp + 22)
	sll wa, 2
	lda xbc, (DSP2_MixerGain_Curve:16)
	ld iz, wa
	extz xiz
	add xiz, xbc
	lda xwa, (xsp + 12)
	ld xbc, xiz
	call FP_SP_CallWithBuf8
	lda xbc, (xsp + 12)
	lda xwa, (xsp + 16)
	call FP_ftoi
	ldw wa, 0x30
	ld bc, 1:i3
	call DSP_DispatchCommand
	ld wa, 0:i3
	ld bc, 1:i3
	call DSP_DispatchData
	ldw wa, 0xD0
	ld bc, 1:i3
	call DSP_DispatchData
	ld xwa, (xsp + 8)
	srl xwa, 8
	srl xwa, 16
	ld bc, 1:i3
	call DSP_DispatchData
	ld xwa, (xsp + 8)
	srl xwa, 16
	ld bc, 1:i3
	call DSP_DispatchData
	call DSP2_SPI_BusIdle
	call DSP_Bytecode_NotifyStateChange
	ldw wa, 0x30
	ld bc, 1:i3
	call DSP_DispatchCommand
	ld wa, 0:i3
	ld bc, 1:i3
	call DSP_DispatchData
	ldw wa, 0xD3
	ld bc, 1:i3
	call DSP_DispatchData
	ld xwa, (xsp + 16)
	srl xwa, 9
	srl xwa, 16
	ld bc, 1:i3
	call DSP_DispatchData
	ld xwa, (xsp + 16)
	srl xwa, 1
	srl xwa, 16
	ld bc, 1:i3
	call DSP_DispatchData
	call DSP2_SPI_BusIdle
	call DSP_Bytecode_NotifyStateChange
	pop xiz
	lda xsp, (xsp + 20)
	ret

; Already named in both the ELF and the reference file; documented here for completeness.
; In:  WA = effect-slot index, XBC = pointer to the bytecode stream for this slot.
; Looks the slot's CHIP ID up in the byte table at 0x01ED6D, then runs
; DSP_BytecodeInterpreter_Init(WA = chip, BC = slot = program index, XDE = 0x014777 program
; table, pushed XBC = bytecode stream).  Ten callers in region 11's effect layer.
DSP_WriteEFFConfig:	.include "includes/generated/cc900/DSP_WriteEFFConfig.s"	; C: cc900/dsp_control_routines.c

; Already named.  Runs program 0 of the descriptor table at 0x0147B3 on the chip in WA, with
; the caller's XBC as the bytecode stream.  Thirteen callers.
DSP_WriteGlobalConfig:	.include "includes/generated/cc900/DSP_WriteGlobalConfig.s"	; C: cc900/dsp_control_routines.c

; Already named.  Front door for "write parameter set N of effect M".
; In:  WA = chip/kind selector, BC = effect id, DE = word passed through, XIX = a stack arg
;      that is the base of a 56-BYTE-PER-ENTRY parameter-block array (the address computed is
;      XIX + 56*WA + 12).
; If WA==1 and BC is 9 or 0x0A it uses the fixed descriptor pairs 0x01E17F/0x01E19E (9) or
; 0x01E40A/0x01E42D (0x0A); otherwise it looks the pair up in the long tables at 0x0001F22C
; (indexed by BC) and 0x0001F09C.  Either way it ends in
; DSP_ParameterWriteEngine(XDE = descriptor table, XBC = 0x014777, + 3 pushed args).
DSP_WriteParameter:	.include "includes/generated/cc900/DSP_WriteParameter.s"	; C: cc900/dsp_control_routines_e_10a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_WriteParam_EFFCase, DSP_WriteParameter + 19
	.set	DSP_WriteParam_EFFCase0xA, DSP_WriteParameter + 79
	.set	DSP_WriteParam_Generic, DSP_WriteParameter + 126
	.set	DSP_WriteParam_Return, DSP_WriteParameter + 191
	ret

; Already named.  Two instructions: `lds wa,1` then `jp Kernel_SemaSignal`
; (0x020370).  It is a TAIL JUMP, so it re-enters the scheduler with priority 1 and only comes
; back when this task is next dispatched.  Called after every DSP2_SPI_BusIdle in the bytecode
; interpreter, the translator and DSP_MixerCoeff_Compute -- i.e. the DSP write path
; deliberately yields between register groups.
; ★ CORRECTED 2026-09-25 (the jump target was then called TaskSched_PreemptiveYield_INT): WA = 1
; is not a priority but the SEMAPHORE id -- this releases semaphore 1 (count 0x1092, wait queue
; 0x1082), waking the task blocked on it if there is one, and only then switches tasks.
DSP_Bytecode_NotifyStateChange:	.include "includes/generated/cc900/DSP_Bytecode_NotifyStateChange.s"	; C: cc900/dsp_control_routines_kernel.c

; Already named.  Sets up and runs a canned DSP register-write program.
; In:  WA = chip id (0 = DSP1/uPD6383, 1 = DSP2/MN19413), BC = program index,
;      XDE = 12-byte-descriptor table base (0x014777 or 0x0147B3), one pushed long = the
;      BYTECODE STREAM pointer.  `retd 0x4`.  Out: HL = last dispatch status.
; Copies descriptor fields +0/+2/+4/+6 (words) and +8 (long) into the frame, then enters
; DSP_BytecodeInterpreter_CheckEnd.  Frame layout used by every handler:
;   (XSP+0x04) loop counter    (XSP+0x06) group length    (XSP+0x14) CHIP ID
;   (XSP+0x1A) bytecode stream pointer (auto-incremented)  IZ = error accumulator.
DSP_BytecodeInterpreter_Init:
	lda xsp, (xsp - 18)
	push xiz
	ld (xsp + 20), wa
	ld wa, bc
	extz xwa
	ld xhl, xwa
	add xhl, xhl
	add xhl, xwa
	sll xhl, 2
	add xhl, xde
	ld wa, (xhl)
	ld (xsp + 8), wa
	ld wa, bc
	extz xwa
	ld xhl, xwa
	add xhl, xhl
	add xhl, xwa
	sll xhl, 2
	add xhl, xde
	ld wa, (xhl + 2)
	ld (xsp + 10), wa
	ld wa, bc
	extz xwa
	ld xhl, xwa
	add xhl, xhl
	add xhl, xwa
	sll xhl, 2
	add xhl, xde
	ld wa, (xhl + 4)
	ld (xsp + 12), wa
	ld wa, bc
	extz xwa
	ld xhl, xwa
	add xhl, xhl
	add xhl, xwa
	sll xhl, 2
	add xhl, xde
	ld wa, (xhl + 6)
	ld (xsp + 14), wa
	ld wa, bc
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	sll xbc, 2
	add xbc, xde
	ld xwa, (xbc + 8)
	ld (xsp + 16), xwa
	jrl DSP_BytecodeInterpreter_CheckEnd

; Already named.  Fetches one 2-byte bytecode instruction:
;   opcode  = byte0 >> 4
;   length  = ((byte0 & 0x0F) << 8) + byte1 - 2
; then advances the stream by 2 and dispatches: 0xE -> DSP_Bytecode_Op0E_SendCommand,
; 0xD -> DSP_Bytecode_Op0D_StateChange, > 5 -> ignored (straight to CheckEnd), 0..5 ->
; computed `jp` through the offset table at 0x014739 with base 0x03C32E.
DSP_BytecodeInterpreter_Loop:
	ld xwa, (xsp + 26)
	ld a, (xwa)
	and a, 0xF0
	ld e, a
	extz de
	ld xwa, (xsp + 26)
	ld a, (xwa + 1)
	and a, 0xFF
	ld c, a
	extz bc
	ld xwa, (xsp + 26)
	ld a, (xwa)
	and a, 0xF
	extz wa
	sla wa, 8
	add wa, bc
	dec 2, wa
	ld (xsp + 6), wa
	ld xwa, (xsp + 26)
	inc 2, xwa
	ld (xsp + 26), xwa
	ld wa, de
	srl wa, 4
	cp wa, 0xE
	jrl z, DSP_Bytecode_Op0E_SendCommand
	cp wa, 0xD
	jrl z, DSP_Bytecode_Op0D_StateChange
	cp wa, 5:i3
	jrl ugt, DSP_BytecodeInterpreter_CheckEnd
	add wa, wa
	lda xix, (DSP_BytecodeInterpreter_CaseOffsets:24)
	ld	wa, (xix+wa)
	lda xix, (DSP_Bytecode_Op00_Groups5_ParamMix:24)
	jp	t, (xix+wa)


;  DSP_Bytecode_Programs: 1613 bytes of native TLCS-900 code implementing
;  6 opcode handlers (0-5) for the DSP bytecode interpreter.
;  Dispatch table at DSP_BytecodeInterpreter_CaseOffsets contains 16-bit offsets from this address.
;
;  Uses prevbank registers (D7), auto-increment addressing ld C,(XWA+),
;  and compact register forms. Cannot be converted to LLVM native instructions
;  due to unsupported addressing modes.
; ★ CORRECTED 2026-09-25: "Cannot be converted to LLVM native instructions" no longer holds -- all
; six handlers below are instructions now (converted and byte-gated by an earlier pass of this lane).
;
; Handler 0 (offset 0x000, 570 bytes): Command + 2 preamble + groups-of-5
;   3-way branch per group: 0x00=static addr, 0x0A=raw, else=param-modified
;   Mixes 32-bit runtime parameter into template coefficients (Branch C)
;
; Handler 1 (offset 0x23A, 249 bytes): Command + 2 preamble + groups-of-5
;   12-bit address computation (4-bit shift), accumulator at stack[0x08]
;
; Handler 2 (offset 0x333, 167 bytes): Command + 2 preamble + groups-of-3
;   Pure raw data writes, no address computation
;
; Handler 3 (offset 0x3DA, 153 bytes): Command + 16-bit address + raw tail
;   16-bit address (8-bit shift), accumulator at stack[0x0E]
;
; Handler 4 (offset 0x473, 26 bytes): Single command byte only
;   Simplest handler - no data, no loop
;
; Handler 5 (offset 0x48D, 448 bytes): Command + 2 preamble + groups-of-5
;   2-way branch: 0x08=addr (with IZH mask), else=param-modified
;   Variant of Handler 0 with different branching and accumulator at stack[0x0C]
; Already named; the name covers the whole 1613-byte `.byte` run 0x03C32E..0x03C97A, which is
; CODE, not data -- six opcode handlers.  This address is also handler 0's entry.
; Handler 0 (570 B): command byte + 2 preamble bytes + groups of 5; three-way branch per group
; (0x00 = static address, 0x0A = raw, else = parameter-modified, mixing a 32-bit runtime
; parameter into the template coefficient).  The source file's own comment block above this
; label documents all six handlers and was cross-checked against the offset table here.
; ★ Renamed 2026-09-25 from DSP_Bytecode_Programs: that name covered the whole 1613-byte run of six
; handlers; this label is handler 0's entry (DSP_BytecodeInterpreter_CaseOffsets index 0), named like its siblings
; DSP_Bytecode_Op01_Groups5_Addr12 .. _Op05_Groups5_Masked.
DSP_Bytecode_Op00_Groups5_ParamMix:
	; Converted from a 570-byte `.byte` run. Framing: unidasm; every
	; instruction re-encoded and the whole run compared byte for byte.
	; 200 instructions, of which 2 needed a spelling search because
	; llvm-mc --disassemble refuses them (it can still ASSEMBLE them).
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchCommand
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ldw	(xsp+4), 1
	jrl	DSP_BytecodeInterpreter_Init_Join2
DSP_BytecodeInterpreter_Init_Loop:
	ld	xwa, (xsp+26)
	cp	(xwa), 0
	jrl	nz, DSP_BytecodeInterpreter_Init_Skip
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	a, (xwa+1)
	srl	a, 4
	and	a, 15
	ld	c, a
	extz	bc
	ld	xwa, (xsp+26)
	ld	a, (xwa)
	extz	wa
	ld	iz, wa
	sll	iz, 4
	add	iz, bc
	ld	wa, (xsp+10)
	add	iz, wa
	ld	wa, iz
	srl	wa, 4
	ld	w, 0:opc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	wa, iz
	sll	wa, 4
	ld	w, 0:opc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	inc	2, xwa
	ld	(xsp+26), xwa
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	jrl	DSP_BytecodeInterpreter_Init_Join
DSP_BytecodeInterpreter_Init_Skip:
	ld	xwa, (xsp+26)
	cp	(xwa), 10
	jr	nz, DSP_BytecodeInterpreter_Init_Skip2
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	jrl	DSP_BytecodeInterpreter_Init_Join
DSP_BytecodeInterpreter_Init_Skip2:
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+16)
	sra	xwa, 1
	sra	xwa, 16
	ld	xbc, xwa
	and	xbc, 127
	ld	xwa, (xsp+26)
	ld	a, (xwa)
	extz	wa
	extz	xwa
	add	xwa, xbc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+16)
	sra	xwa, 9
	ld	xbc, xwa
	and	xbc, 255
	ld	xwa, (xsp+26)
	ld	a, (xwa+1)
	extz	wa
	extz	xwa
	add	xwa, xbc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+16)
	sra	xwa, 1
	ld	xbc, xwa
	and	xbc, 255
	ld	xwa, (xsp+26)
	ld	a, (xwa+2)
	extz	wa
	extz	xwa
	add	xwa, xbc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+16)
	sla	xwa, 7
	ld	xbc, xwa
	and	xbc, 128
	ld	xwa, (xsp+26)
	ld	a, (xwa+3)
	extz	wa
	extz	xwa
	add	xwa, xbc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	inc	4, xwa
	ld	(xsp+26), xwa
DSP_BytecodeInterpreter_Init_Join:
	incw	1, (xsp+4)
DSP_BytecodeInterpreter_Init_Join2:
	ld	wa, (xsp+6)
	dec	3, wa
	extz	xwa
	div	wa, 5
	cp	(xsp+4), wa
	jrl	ule, DSP_BytecodeInterpreter_Init_Loop
	jrl	DSP_BytecodeInterpreter_CheckEnd
; Bytecode handler 1 (offset 0x23A, 249 bytes).  Entered ONLY by the computed jump in
; DSP_BytecodeInterpreter_Loop when the opcode nibble is 1; no symbol existed for it.
; Verified head: fetch one byte from the stream at (XSP+0x1A) with post-increment, extend it
; and send it as a COMMAND -- DSP_DispatchCommand(WA = byte, BC = (XSP+0x14) = chip id) -- and
; accumulate the returned status into IZ.  Then two preamble bytes and groups of five, with a
; 12-bit address computation (4-bit shift) and its accumulator at frame+0x08.
; Exits by `jrl` to DSP_BytecodeInterpreter_CheckEnd (0x03C9CE).
DSP_Bytecode_Op01_Groups5_Addr12:
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchCommand
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ldw	(xsp+4), 1
	jrl	DSP_BytecodeInterpreter_Init_Join3
DSP_BytecodeInterpreter_Init_Loop2:
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	a, (xwa+1)
	srl	a, 4
	and	a, 15
	ld	c, a
	extz	bc
	ld	xwa, (xsp+26)
	ld	a, (xwa)
	extz	wa
	ld	iz, wa
	sll	iz, 4
	add	iz, bc
	ld	wa, (xsp+8)
	add	iz, wa
	ld	wa, iz
	srl	wa, 4
	ld	w, 0:opc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	wa, iz
	sll	wa, 4
	ld	w, 0:opc
	inc	8, wa
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	inc	2, xwa
	ld	(xsp+26), xwa
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	incw	1, (xsp+4)
DSP_BytecodeInterpreter_Init_Join3:
	ld	wa, (xsp+6)
	dec	3, wa
	extz	xwa
	div	wa, 5
	cp	(xsp+4), wa
	jrl	ule, DSP_BytecodeInterpreter_Init_Loop2
	jrl	DSP_BytecodeInterpreter_CheckEnd
; Bytecode handler 2 (offset 0x333, 167 bytes).  Same command-byte prologue as handler 1, then
; two preamble bytes and groups of THREE raw data bytes with no address computation -- a plain
; block copy into consecutive DSP registers.  Exits to DSP_BytecodeInterpreter_CheckEnd.
DSP_Bytecode_Op02_Groups3_Raw:
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchCommand
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ldw	(xsp+4), 1
	jr	DSP_BytecodeInterpreter_Init_Join4
DSP_BytecodeInterpreter_Init_Loop3:
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	incw	1, (xsp+4)
DSP_BytecodeInterpreter_Init_Join4:
	ld	wa, (xsp+6)
	dec	3, wa
	extz	xwa
	div	wa, 3
	cp	(xsp+4), wa
	jr	ule, DSP_BytecodeInterpreter_Init_Loop3
	jrl	DSP_BytecodeInterpreter_CheckEnd
; Bytecode handler 3 (offset 0x3DA, 153 bytes).  Command byte, then a 16-bit address built
; from two stream bytes (8-bit shift; the `ld A,(XWA+0x01)` at 0x03C722 is the second address
; byte), then a raw tail.  Accumulator at frame+0x0E.  Exits to CheckEnd.
DSP_Bytecode_Op03_Addr16_RawTail:
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchCommand
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	a, (xwa+1)
	and	a, 255
	ld	c, a
	extz	bc
	ld	xwa, (xsp+26)
	ld	a, (xwa)
	extz	wa
	ld	iz, wa
	sll	iz, 8
	add	iz, bc
	ld	wa, (xsp+14)
	add	iz, wa
	ld	wa, iz
	srl	wa, 8
	ld	w, 0:opc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	wa, iz
	ld	w, 0:opc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	inc	2, xwa
	ld	(xsp+26), xwa
	ldw	(xsp+4), 1
	ld	wa, (xsp+6)
	dec	3, wa
	cp	(xsp+4), wa
	jrl	ugt, DSP_BytecodeInterpreter_CheckEnd
DSP_BytecodeInterpreter_Init_Loop4:
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	incw	1, (xsp+4)
	ld	wa, (xsp+6)
	dec	3, wa
	cp	(xsp+4), wa
	jr	ule, DSP_BytecodeInterpreter_Init_Loop4
	jrl	DSP_BytecodeInterpreter_CheckEnd
; Bytecode handler 4 (offset 0x473, 26 bytes) -- the whole handler, fully decoded:
;   XWA = (XSP+0x1A); C = (XWA+) ; (XSP+0x1A) = XWA        ; fetch one stream byte
;   WA = zero-extend(C) ; BC = (XSP+0x14)                  ; chip id
;   call DSP_DispatchCommand (0x036A2E) ; IZ = HL          ; accumulate status
;   jrl DSP_BytecodeInterpreter_CheckEnd (0x03C9CE)
; i.e. "emit one command byte, no data".  This is the block that proves the frame layout used
; by all six handlers.
DSP_Bytecode_Op04_CommandOnly:
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchCommand
	ld	qiz, hl
	jrl	DSP_BytecodeInterpreter_CheckEnd
; Bytecode handler 5 (offset 0x48D, 448 bytes).  A variant of handler 0: command byte, two
; preamble bytes, groups of five, but a TWO-way branch (0x08 = address, masked with IZH; else
; parameter-modified) and its accumulator at frame+0x0C.  Exits to CheckEnd.
DSP_Bytecode_Op05_Groups5_Masked:
	; Converted from a 448-byte `.byte` run. Framing: unidasm; every
	; instruction re-encoded and the whole run compared byte for byte.
	; 158 instructions, of which 1 needed a spelling search because
	; llvm-mc --disassemble refuses them (it can still ASSEMBLE them).
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchCommand
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ldw	(xsp+4), 1
	jrl	DSP_BytecodeInterpreter_Init_Join6
DSP_BytecodeInterpreter_Init_Loop5:
	ld	xwa, (xsp+26)
	cp	(xwa), 8
	jrl	nz, DSP_BytecodeInterpreter_Init_Skip3
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	ld	a, (xwa+1)
	srl	a, 4
	and	a, 15
	ld	c, a
	extz	bc
	ld	xwa, (xsp+26)
	ld	a, (xwa)
	extz	wa
	ld	iz, wa
	sll	iz, 4
	add	iz, bc
	ld	wa, (xsp+12)
	add	iz, wa
	ldib_erp	249, 0
	ld	wa, iz
	srl	wa, 4
	ld	w, 0:opc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	wa, iz
	sll	wa, 4
	ld	w, 0:opc
	inc	8, wa
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	inc	2, xwa
	ld	(xsp+26), xwa
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	jrl	DSP_BytecodeInterpreter_Init_Join5
DSP_BytecodeInterpreter_Init_Skip3:
	ld	xwa, (xsp+26)
	ld	c, (xwa+)
	ld	(xsp+26), xwa
	ld	a, c
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+16)
	sra	xwa, 1
	sra	xwa, 16
	ld	xbc, xwa
	and	xbc, 127
	ld	xwa, (xsp+26)
	ld	a, (xwa)
	extz	wa
	extz	xwa
	add	xwa, xbc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+16)
	sra	xwa, 9
	ld	xbc, xwa
	and	xbc, 255
	ld	xwa, (xsp+26)
	ld	a, (xwa+1)
	extz	wa
	extz	xwa
	add	xwa, xbc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+16)
	sra	xwa, 1
	ld	xbc, xwa
	and	xbc, 255
	ld	xwa, (xsp+26)
	ld	a, (xwa+2)
	extz	wa
	extz	xwa
	add	xwa, xbc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+16)
	sla	xwa, 7
	ld	xbc, xwa
	and	xbc, 128
	ld	xwa, (xsp+26)
	ld	a, (xwa+3)
	extz	wa
	extz	xwa
	add	xwa, xbc
	extz	wa
	ld	bc, (xsp+20)
	call	DSP_DispatchData
	ld	qiz, hl
	ld	xwa, (xsp+26)
	inc	4, xwa
	ld	(xsp+26), xwa
DSP_BytecodeInterpreter_Init_Join5:
	incw	1, (xsp+4)
DSP_BytecodeInterpreter_Init_Join6:
	ld	wa, (xsp+6)
	dec	3, wa
	extz	xwa
	div	wa, 5
	cp	(xsp+4), wa
	jrl	ule, DSP_BytecodeInterpreter_Init_Loop5
	jr	DSP_BytecodeInterpreter_CheckEnd

; Already named.  Opcode nibble 0xD: `DSP2_SPI_BusIdle` then `DSP_Bytecode_NotifyStateChange`
; (a task yield) then CheckEnd.  Emits no data at all -- it exists purely to release the SPI
; bus and let other tasks run between register groups.
DSP_Bytecode_Op0D_StateChange:
	call DSP2_SPI_BusIdle
	calr DSP_Bytecode_NotifyStateChange
	jr DSP_BytecodeInterpreter_CheckEnd

; Already named.  Opcode nibble 0xE: sends one stream byte as a COMMAND, then, if the decoded
; group length > 1, falls into DSP_Bytecode_Op0E_DataLoop for the remaining bytes.
DSP_Bytecode_Op0E_SendCommand:
	ld xwa, (xsp + 26)
	ld C, (xwa+)
	ld (xsp + 26), xwa
	ld a, c
	extz wa
	ld bc, (xsp + 20)
	call DSP_DispatchCommand
	ldfr_werp HL, 0xFA
	ldw (xsp + 4), 0x1
	ld wa, (xsp + 6)
	dec 1, wa
	cp (xsp + 4), wa
	jr ugt, DSP_BytecodeInterpreter_CheckEnd

; Already named.  Sends stream bytes as DATA via DSP_DispatchData until the frame counter
; at (XSP+0x04) reaches the group length at (XSP+0x06).
DSP_Bytecode_Op0E_DataLoop:
	ld xwa, (xsp + 26)
	ld C, (xwa+)
	ld (xsp + 26), xwa
	ld a, c
	extz wa
	ld bc, (xsp + 20)
	call DSP_DispatchData
	ldfr_werp HL, 0xFA
	incw 1, (xsp + 4)
	ld wa, (xsp + 6)
	dec 1, wa
	cp (xsp + 4), wa
	jr ule, DSP_Bytecode_Op0E_DataLoop

; Already named.  Peeks the next stream byte WITHOUT consuming it; if (byte & 0xF0) != 0xF0
; loops back to DSP_BytecodeInterpreter_Loop, else returns HL = IZ (accumulated status),
; pop XIZ, `retd 0x4`.  ★ 0xFx is the only terminator -- a stream that lacks one runs off the
; end of the program image (see [UNCERTAIN]).
DSP_BytecodeInterpreter_CheckEnd:
	ld xwa, (xsp + 26)
	ld a, (xwa)
	and a, 0xF0
	cp a, 0xF0
	jrl nz, DSP_BytecodeInterpreter_Loop
	ldto_werp HL, 0xFA
	pop xiz
	lda xsp, (xsp + 18)
	retd 0x4

; Already named.  Walks a tagged table of parameter records and hands each one to
; DSP_PerParameterTranslator, framing the whole run with DSP1 bracket commands.
; In:  WA = effect-slot index, BC/DE forwarded, plus 5 stack args (`retd 0x0A`): the record
;      table pointer, an end pointer, the opcode-descriptor table and two pass-throughs.
; The CHIP ID is byte[0x0001ED6D + WA] and lives at frame+0x04 for the whole run.
; Uses DSP_TableWalk_SearchWithState to position XIZ at the first record; if that reports a
; non-zero status it calls DSP_NopReturn (a stub! the error is swallowed) and returns.
; Per record, ONLY when the chip id is 0 (DSP1 / uPD6383), it brackets the record with
;   DispatchCommand(1) ; DispatchData(1) ; DispatchData(0x60)   ... record ...
;   DispatchCommand(3)
; The loop terminates when XIZ reaches the end pointer at frame+0x06.
DSP_ParameterWriteEngine:	.include "includes/generated/cc900/DSP_ParameterWriteEngine.s"	; C: cc900/dsp_control_routines_e_7a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_ParamLoop_CheckBound, DSP_ParameterWriteEngine + 74
	.set	DSP_ParamLoop_Iterate, DSP_ParameterWriteEngine + 79
	.set	DSP_ParamLoop_CallTranslator, DSP_ParameterWriteEngine + 123
	.set	DSP_ParamLoop_PostCall, DSP_ParameterWriteEngine + 169
	.set	DSP_ParamLoop_SendEndCmd, DSP_ParameterWriteEngine + 188
	.set	DSP_ParamLoop_Return, DSP_ParameterWriteEngine + 193

; Already named.  ★ The heart of the region: interprets ONE parameter record as a little
; opcode stream, and for each opcode calls a curve/interpolation function and then a DSP
; register writer.
; In:  WA / BC / DE plus 6 stack args (`retd 0x14`, 20 bytes).  BC indexes a 12-BYTE-PER-ENTRY
;      descriptor array whose base is the stack arg at +0x1E: fields +0, +2, +4 (words) and +8
;      (long) are cached into the frame at +0x04, +0x06, +0x08 and +0x0A.
; Out: XHL = advanced stream pointer; the status word is stored through the pointer at +0x1A.
; Loop: DSP_Translator_CheckEnd reads one byte; while it is not 0x7A, DSP_Translator_ReadOpcode
; runs one opcode; 0x7A ends the record.
DSP_PerParameterTranslator:
	lda xsp, (xsp - 18)
	push xiz
	ld (xsp + 16), de
	ld (xsp + 18), bc
	ld (xsp + 20), wa
	ld xde, (xsp + 30)
	ld wa, (xsp + 18)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	sll xbc, 2
	add xbc, xde
	ld wa, (xbc)
	ld (xsp + 4), wa
	ld wa, (xsp + 18)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	sll xbc, 2
	add xbc, xde
	ld wa, (xbc + 2)
	ld (xsp + 6), wa
	ld wa, (xsp + 18)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	sll xbc, 2
	add xbc, xde
	ld wa, (xbc + 4)
	ld (xsp + 8), wa
	ld wa, (xsp + 18)
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	sll xbc, 2
	add xbc, xde
	ld xwa, (xbc + 8)
	ld (xsp + 10), xwa
	jrl DSP_Translator_CheckEnd

; Reads the opcode byte, then calls DSP_TableWalk_Search to locate the matching record field;
; a non-zero walk status aborts to DSP_Translator_Return.  It then reads a signed word from
; the caller-supplied word table (stack arg at +0x22, indexed by the loop counter) into DE and
; dispatches:  0x21 -> DSP_Op_0x21_Interp2Point, 0x24 -> DSP_Op_0x24_MultiStepInterp,
; 0x40 -> DSP_Op_0x40_PanScale, 0x61..0x79 -> computed `jp (XIX+DE)` with the offset table at
; 0x014745 and base 0x03CB8E, anything else -> DSP_Op_Unknown_Error.
DSP_Translator_ReadOpcode:
	ld xbc, (xsp + 42)
	ld xwa, 1:i3
	add (xsp + 42), xwa
	ld a, (xbc)
	ld e, a
	extz de
	lda xwa, (xsp + 14)
	push xwa
	ld xwa, (xsp + 42)
	ldto_werp BC, 0xFA
	calr DSP_TableWalk_Search
	cpw (xsp + 14), 0x0
	jrl nz, DSP_Translator_Return
	ld a, (xhl)
	ldfr_berp A, 0xF8
	extz iz
	ld wa, (xsp + 16)
	extz xwa
	add xwa, xwa
	add xwa, (xsp + 34)
	ld de, (xwa)
	exts xde
	ldto_werp WA, 0xFA
	cp wa, 0x21
	jrl z, DSP_Op_0x21_Interp2Point
	cp wa, 0x24
	jrl z, DSP_Op_0x24_MultiStepInterp
	cp wa, 0x40
	jrl z, DSP_Op_0x40_PanScale
	sub wa, 0x61
	cp wa, 0:i3
	jrl c, DSP_Op_Unknown_Error
	cp wa, 0x18
	jrl ugt, DSP_Op_Unknown_Error
	add wa, wa
	lda xix, (DSP_Translator_CaseOffsets:24)
	ld	wa, (xix+wa)
	lda xix, (DSP_Op_0x61_LinearEval:24)
	jp	t, (xix+wa)
; ⚠ THE ELF NAME IS MISLEADING -- see [UNCERTAIN].  These 26 bytes are the OPCODE 0x61 ARM,
; not a jump table: DSP_ParamFetch_Op61Table (0x038E9F) then DSP_WriteOscParam
; (0x0387E6), then `jrl DSP_Translator_PostDispatch`.  The real table is at 0x014745.
; Proposing the existing name unchanged so integration stays mechanical.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from DSP_Translator_JumpTable.
; Note: the misleading name noted above is replaced.
DSP_Op_0x61_LinearEval:
	lda	xwa, (xsp+42)
	ld	xbc, xde
	call	DSP_ParamFetch_Op61Table
	pushm	(xsp+4)
	ld	wa, iz
	ld	xbc, xhl
	ld	de, (xsp+22)
	call	DSP_WriteOscParam
	ld	(xsp+14), hl

; Common return point for all 27 opcode arms.  If the frame word at +0x14 is 1 it runs
; DSP2_SPI_BusIdle and DSP_Bytecode_NotifyStateChange (a task yield) before falling into
; DSP_Translator_CheckEnd.
DSP_Translator_PostDispatch:
	cpw (xsp + 20), 0x1
	jr nz, DSP_Translator_CheckEnd
	call DSP2_SPI_BusIdle
	calr DSP_Bytecode_NotifyStateChange

; Consumes one stream byte; loops back to DSP_Translator_ReadOpcode unless it is 0x7A.
; ★ 0x7A is the ONLY terminator -- see [UNCERTAIN].
DSP_Translator_CheckEnd:
	ld xbc, (xsp + 42)
	ld xwa, 1:i3
	add (xsp + 42), xwa
	ld a, (xbc)
	extz wa
	ldfr_werp WA, 0xFA
	cp wa, 0x7A
	jrl nz, DSP_Translator_ReadOpcode

; Stores the status word through the pointer arg, returns XHL = stream pointer, `retd 0x14`.
DSP_Translator_Return:
	ld xbc, (xsp + 26)
	ld wa, (xsp + 14)
	ld (xbc), wa
	ld xhl, (xsp + 42)
	pop xiz
	lda xsp, (xsp + 18)
	retd 0x14
; Opcode 0x62 arm (offset 0x0050 in the table at 0x014745).  NEW NAME -- this code lives inside
; a converter `.byte` run and has no symbol at all.
; DSP_ParamFetch_SingleTable (0x038EAC) -> DSP_WriteOscParam (0x0387E6) -> PostDispatch.
; The shape of every arm in this block is identical: load the parameter pointer from
; (XSP+0x2A), pass the record pointer in XBC, call the CURVE function, then push the curve's
; result and call the WRITER with WA = IZ (the DSP channel) and DE = (XSP+0x16), storing the
; writer's HL into the status word at (XSP+0x0E).
DSP_Op_0x62_ParamFetchSingle:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamFetch_SingleTable
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jr DSP_Translator_PostDispatch
; Opcode 0x63 arm.  NEW NAME.
; DSP_ParamFetch_AlgoTypeTable (0x038EB9) -> DSP_WriteFreqParam_AlgoType (0x03846C).
DSP_Op_0x63_ParamFetchAlgoType:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamFetch_AlgoTypeTable
	pushm (xsp + 6)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteFreqParam_AlgoType
	ld (xsp + 14), hl
	jr DSP_Translator_PostDispatch
; Opcode 0x79 arm (offset 0x0088 -- note it sits physically BEFORE the 0x64 arm).  NEW NAME.
; DSP_AlgoParam_Decode (0x038EF6) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x79_AlgoParamDecode:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_AlgoParam_Decode
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x64 arm.  NEW NAME.
; DSP_PitchParam_Scale (0x038F9B) -> DSP_WriteFreqParam (0x038539).
DSP_Op_0x64_PitchParamScale:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_PitchParam_Scale
	pushm (xsp + 6)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteFreqParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x65 arm.  NEW NAME.
; DSP_VolumeParam_Scale (0x038FE8) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x65_VolumeParamScale:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_VolumeParam_Scale
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x66 arm.  NEW NAME.
; DSP_ParamInterp_2Point (0x039206) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x66_Interp2Point:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamInterp_2Point
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x67 arm.  NEW NAME.  The only arm that uses the offset writer.
; DSP_ParamInterp_FPScale (0x03925E) -> DSP_WriteOscParam_Offset (0x038922).
DSP_Op_0x67_InterpFPScale:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamInterp_FPScale
	pushm (xsp + 8)
	ld xwa, (xsp + 12)
	push xwa
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 26)
	call DSP_WriteOscParam_Offset
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x68 arm.  NEW NAME.
; DSP_ParamInterp_Div0xB4 (0x0392AC) -> DSP_WriteFreqParam (0x038539).
DSP_Op_0x68_InterpDiv0xB4:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamInterp_Div0xB4
	pushm (xsp + 6)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteFreqParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x69 arm.  NEW NAME.
; DSP_VolumeCurve_FP (0x0392F2) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x69_VolumeCurve:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_VolumeCurve_FP
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x6A arm.  NEW NAME.
; DSP_FreqCurve_FP (0x03943B) -> DSP_WriteFreqParam (0x038539).
DSP_Op_0x6A_FreqCurve:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_FreqCurve_FP
	pushm (xsp + 6)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteFreqParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x6B arm.  NEW NAME.
; DSP_FreqInterp_2Point (0x0394CD) -> DSP_WriteFreqParam (0x038539).
DSP_Op_0x6B_FreqInterp2Point:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_FreqInterp_2Point
	pushm (xsp + 6)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteFreqParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x6C arm.  NEW NAME.  Takes one extra stack argument before the call.
; DSP_ParamInterp_3Point_WithOffset (0x039525) -> DSP_WriteFreqParam (0x038539).
DSP_Op_0x6C_Interp3Point:
	lda xwa, (xsp + 42)
	ld xbc, xde
	ld xde, (xsp + 10)
	call DSP_ParamInterp_3Point_WithOffset
	pushm (xsp + 6)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteFreqParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x6D arm.  NEW NAME.
; DSP_ReverbCurve_FP (0x039599) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x6D_ReverbCurve:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ReverbCurve_FP
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x6E arm.  NEW NAME.
; DSP_ParamInterp_FPComplex (0x0396C2) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x6E_InterpFPComplex:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamInterp_FPComplex
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x6F arm.  NEW NAME.
; DSP_PanCurve_PiecewiseLin (0x0397F3) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x6F_PanCurve:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_PanCurve_PiecewiseLin
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x70 arm.  NEW NAME.  ★ The ONLY caller of DSP_BiquadCoeff_Compute (0x03A933).
; Unlike the curve arms it has no separate writer: it pushes five arguments -- the parameter
; stream pointer from (XSP+0x2A), IZ, the long at (XSP+0x28), the word at (XSP+0x0E) and a
; pointer to the local at XSP+0x1A -- passes WA/BC/DE from (XSP+0x24)/(XSP+0x22)/(XSP+0x20),
; and stores the returned XHL back into (XSP+0x2A) as the new stream pointer.
; The coefficient routine does its own DSP writes.
DSP_Op_0x70_BiquadCoeff:
	ld xwa, (xsp + 42)
	push xwa
	pushw iz
	ld xwa, (xsp + 40)
	push xwa
	pushm (xsp + 14)
	lda xwa, (xsp + 26)
	push xwa
	ld wa, (xsp + 36)
	ld bc, (xsp + 34)
	ld de, (xsp + 32)
	call DSP_BiquadCoeff_Compute
	ld (xsp + 42), xhl
	jrl DSP_Translator_PostDispatch
; Opcode 0x71 arm.  NEW NAME.
; DSP_DetuneCurve_SignedFP (0x0398CE) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x71_DetuneCurve:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_DetuneCurve_SignedFP
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x72 arm.  NEW NAME.  Four pushed arguments, no separate writer.
; DSP_BiquadWarp_FP (0x039ABD) does its own writing.
DSP_Op_0x72_BiquadWarp:
	pushm (xsp + 16)
	pushw iz
	pushm (xsp + 24)
	pushm (xsp + 10)
	lda xwa, (xsp + 50)
	ld xbc, (xsp + 42)
	ld de, (xsp + 26)
	call DSP_BiquadWarp_FP
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x73 arm.  NEW NAME.
; DSP_ParamInterp_Div0xC6 (0x039D26) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x73_InterpDiv0xC6:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamInterp_Div0xC6
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x74 arm.  NEW NAME.  Two pushed argument groups, no separate writer.
; DSP_WriteLUTParamSet (0x03869B) writes a whole LUT-driven parameter set itself.
DSP_Op_0x74_LUTParamSet:
	pushm (xsp + 20)
	pushm (xsp + 8)
	lda xwa, (xsp + 46)
	ld bc, iz
	call DSP_WriteLUTParamSet
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x75 arm.  NEW NAME.
; DSP_ParamEQ_Curve_FP (0x039D98) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x75_ParamEQCurve:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamEQ_Curve_FP
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x76 arm.  NEW NAME.  ★ The ONLY caller of DSP_SOS_Coeff_Compute (0x03B646).
; Same five-argument shape as the 0x70 arm; stores the returned stream pointer back into
; (XSP+0x2A).
DSP_Op_0x76_SOSCoeff:
	ld xwa, (xsp + 42)
	push xwa
	pushw iz
	ld xwa, (xsp + 40)
	push xwa
	lda xwa, (xsp + 24)
	push xwa
	pushm (xsp + 18)
	ld wa, (xsp + 36)
	ld bc, (xsp + 34)
	ld de, (xsp + 32)
	call DSP_SOS_Coeff_Compute
	ld (xsp + 42), xhl
	jrl DSP_Translator_PostDispatch
; Opcode 0x77 arm.  NEW NAME.
; DSP_ParamInterp_2Point_B (0x03A22A) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x77_Interp2PointB:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamInterp_2Point_B
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch
; Opcode 0x78 arm.  NEW NAME.
; DSP_VolScale_B (0x03A282) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x78_VolScaleB:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_VolScale_B
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch

; Opcode 0x40 arm (special-cased before the jump table).
; DSP_PanScale_Simple (0x03A4A0) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x40_PanScale:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_PanScale_Simple
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch

; Opcode 0x24 arm (special-cased).  Pushes two extra argument groups.
; DSP_ParamInterp_MultiStep (0x03A4B7) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x24_MultiStepInterp:
	pushm (xsp + 18)
	pushm (xsp + 18)
	lda xwa, (xsp + 46)
	ld xbc, xde
	ld xde, (xsp + 38)
	call DSP_ParamInterp_MultiStep
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch

; Opcode 0x21 arm (special-cased).
; DSP_ParamInterp_2Point (0x039206) -> DSP_WriteOscParam (0x0387E6).
DSP_Op_0x21_Interp2Point:
	lda xwa, (xsp + 42)
	ld xbc, xde
	call DSP_ParamInterp_2Point
	pushm (xsp + 4)
	ld wa, iz
	ld xbc, xhl
	ld de, (xsp + 22)
	call DSP_WriteOscParam
	ld (xsp + 14), hl
	jrl DSP_Translator_PostDispatch

; Unrecognised opcode: sets the status word at (XSP+0x0E) to 5 and `jrl`s to
; DSP_Translator_Return -- ★ it ABORTS THE WHOLE PARAMETER RECORD, so one bad opcode silently
; drops every remaining parameter of that effect.
DSP_Op_Unknown_Error:
	ldw (xsp + 14), 0x5
	jrl DSP_Translator_Return

; Decodes a 24-bit BIG-ENDIAN signed coefficient out of a byte stream, left-justified into a
; 32-bit word.  34 call sites across regions 12-14 -- the standard way DSP coefficients are
; unpacked from the effect ROM images.
; In:  XWA = stream pointer, XBC = destination.   Out: (XBC) = (b0<<24)|(b1<<16)|(b2<<8),
;      each byte sign-extended before shifting (only b0's sign survives); XHL = XWA + 3.
; No hardware access.  Fully decoded at 0x03CF07..0x03CF52.
DSP_StreamDecode_3ByteWord:	.include "includes/generated/cc900/DSP_StreamDecode_3ByteWord.s"	; C: cc900/dsp_control_routines.c

; Linear search through a table of TAGGED VARIABLE-LENGTH records, returning a pointer to a
; field inside the matching record.
; Record layout, read off the code:
;     +0  byte  length high  }  entry length in bytes = (b0<<8)|b1
;     +1  byte  length low   }
;     +2  byte  record ID
;     +3.. payload
;   A record whose FIRST BYTE is 0xF0 terminates the table.
; In:  XWA = table base, BC = wanted record ID, DE = field offset within the record,
;      one pushed long = pointer to a status word.  `retd 0x4`.
; Out: XHL = &record[3 + DE] (see below); status = 0 found, 3 hit the 0xF0 sentinel,
;      4 the requested field lies past the record's own length.
; Four callers: three in region 12 and DSP_Translator_ReadOpcode here.
DSP_TableWalk_Search:	.include "includes/generated/cc900/DSP_TableWalk_Search.s"	; C: cc900/dsp_control_routines.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_TableWalk_CheckEntry, DSP_TableWalk_Search + 4
	.set	DSP_TableWalk_FoundInRange, DSP_TableWalk_Search + 36
	.set	DSP_TableWalk_SkipEntry, DSP_TableWalk_Search + 40
	.set	DSP_TableWalk_ReadHeader, DSP_TableWalk_Search + 42
	.set	DSP_TableWalk_Return, DSP_TableWalk_Search + 74

; Positional variant of the same walk: instead of matching an ID it SKIPS BC records and
; returns the address of the next one.
; In:  XWA = table base, BC = records to skip, XDE = pointer to a status word,
;      one pushed long = pointer that receives (record address + record length).  `retd 0x4`.
; Out: XHL = XWA advanced past the skipped records; status = 0 normally, 2 if the 0xF0
;      sentinel was reached first.
; Sole caller: DSP_ParameterWriteEngine, which uses the pushed out-pointer as the loop's END
; POINTER.
DSP_TableWalk_SearchWithState:
	ld xhl, xde
	jr DSP_TableWalk_State_ReadHeader

; If the skip count has reached zero, publish (base + length) through the out-pointer, advance
; XWA by 2 and return.
DSP_TableWalk_State_CheckEntry:
	cp bc, 0:i3
	jr nz, DSP_TableWalk_State_Advance
	ld ix, 0:i3
	ld xde, (xsp + 4)
	ld bc, iy
	extz xbc
	add xbc, xwa
	ld (xde), xbc
	inc 2, xwa
	jr DSP_TableWalk_State_Return

; Otherwise XWA += record length and BC -= 1.
DSP_TableWalk_State_Advance:
	ld de, iy
	extz xde
	add xwa, xde
	dec 1, bc

; Reads the 2-byte length header and tests the 0xF0 sentinel.
DSP_TableWalk_State_ReadHeader:
	ld e, (xwa + 1)
	ldfr_berp E, 0xF0
	extz ix
	ld e, (xwa)
	extz de
	ld iy, de
	sll iy, 8
	add iy, ix
	ld de, iy
	srl de, 8
	cp de, 0xF0
	jr nz, DSP_TableWalk_State_CheckEntry
	ld ix, 2:i3

; Stores the status through XDE(saved in XHL), returns XHL = XWA, `retd 0x4`.
DSP_TableWalk_State_Return:
	ld (xhl), ix
	ld xhl, xwa
	retd 0x4

; A single `ret`.  ★ It is the project's ERROR HOOK: DSP_ParameterWriteEngine calls it with
; WA = the failing status code at two places (after the table walk and after the translator)
; and DSP_ParamLoop_Return then bails out.  The status is therefore never reported anywhere --
; DSP parameter-write failures are silent by design in v142.
DSP_NopReturn:	.include "includes/generated/cc900/DSP_NopReturn.s"	; C: cc900/dsp_control_routines.c


; Already named (the reference file spells it AUDIO_CMDHANDLER_A0_BF).  Entry 5 of
; CMD_DISPATCH_TABLE, i.e. main->sub inter-CPU commands 0xA0..0xBF.
; In:  one pushed long = pointer to the 2-byte command payload.  Out: HL = 0 always.
;   payload[0] == 1 and payload[1] <= 9  ->  (0x004A48) = payload[1]
;   payload[0] == 0 and payload[1] == 1  ->  (0x004A4A) = 1
;   anything else -> no effect.
; ★ 0x004A48 is the keybed TOUCH-CURVE index used by Keybed_Decode_Event; 0x004A4A is the
; KEYBED->MAIN FORWARDING ENABLE flag tested by ToneGen_Process_Notes.  These two bytes are
; the sub-CPU's entire "local control" state and they are only ever written from here.
Audio_CmdHandler_A0_BF:	.include "includes/generated/cc900/Audio_CmdHandler_A0_BF.s"	; C: cc900/dsp_control_routines.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	CmdA0BF_CheckSubByte, Audio_CmdHandler_A0_BF + 26
	.set	CmdA0BF_Return, Audio_CmdHandler_A0_BF + 37

; ----------------------------------------------------------------------------
; ToneGen_Init - Initialize tone generator subsystem
; Entry: None
; Exit:  Via JRL to ToneGen_Process
; Notes: Sets up tone generator state at 0x4A48 (mode = 6)
;        Tone generator is memory-mapped at 0x00110000
;        State buffer at 0x4A42-0x4A5C
; ----------------------------------------------------------------------------
; Already named (reference: TONEGEN_INIT).  ⚠ MISNOMER: this is the KEYBED, not the tone
; generator -- see [UNCERTAIN].  Two instructions: (0x004A48) = 6 (default touch curve) then
; `jrl ToneGen_Poll_Init`.  Called once from the sub-CPU boot path.
ToneGen_Init:	.include "includes/generated/cc900/ToneGen_Init.s"	; C: cc900/dsp_control_routines_e_6a.c

; ----------------------------------------------------------------------------
; ToneGen_Process_Notes - Process incoming note events from tone generator
; Entry: Called from main tone gen handler
; Exit:  Note events dispatched to appropriate voice slots
; Notes: Reads events via Keybed_Read_Event; there is no voice allocation here.
;        0x004A4C is a PER-MIDI-NOTE held-key map indexed by the decoded note, not 16 slots:
;        the code computes 0x004A4C + note and note = (key & 0x7F) + 0x24, so the map starts
;        at 0x004A70.  [INFERENCE] with a 61-key bed (MIDI 36..96) it occupies
;        0x004A70..0x004AAC.  Its only job is to suppress a note-off with no matching
;        note-on.  0x004A42..0x004A44 is the 3-byte MIDI staging area.
;        ★ Where a key event goes from here: NOT into the tone generator.  This routine
;        writes no TG register at all -- it formats 0x90 / note / velocity and, only when
;        (0x004A4A) == 1, hands those 3 bytes to InterCPU_DMA_Send for the MAIN CPU.
;        [INFERENCE] the voice registers that actually sound the note are written by other
;        paths (the staging block at 0x0451CC, bursted by ToneGen_WriteVoiceParams); which
;        of them this MIDI message ends up driving has not been traced.
; ----------------------------------------------------------------------------
; Already named (reference: TONEGEN_PROCESS_NOTES).  ★ THIS IS THE KEYBED SERVICE that
; Audio_Main_Loop calls unconditionally every pass (the brief's "keybed (0x03D01E)").
; Drains the keybed FIFO and forwards every key event to the MAIN CPU as MIDI.
; Per event (Keybed_Read_Event gives note in byte 0, velocity in byte 1):
;   velocity != 0 -> mark (0x004A4C + note) = 0xFF, build 0x90 / note / velocity at
;                    0x004A42..0x004A44
;   velocity == 0 -> only if (0x004A4C + note) was 0xFF: clear it and build the same 3 bytes
;   then, ONLY IF (0x004A4A) == 1, call InterCPU_DMA_Send(XDE = 0x004A42, WA = 2, BC = 3).
; Loops until Keybed_Read_Event returns HL == 0xFFFF ("no more data").
; ★ Two properties matter for the open sub->main bug -- see the [UNCERTAIN] notes.
ToneGen_Process_Notes:	; 03D01Eh
	dec 2, xsp	; Allocate 2 bytes for result
	ld wa, 0:i3
	lda xwa, (xsp)
	calr Keybed_Read_Event
	cp hl, 0xFFFF
	jrl z, ToneGen_Note_Done

; Already named.  Body of the drain loop; back-edge at ToneGen_Note_Continue.
ToneGen_Note_Loop:	; 03D02Eh
	cp (xsp + 1), 0x0	; Check velocity
	jr z, ToneGen_Note_Off_Slot
	ld a, (xsp + 0:8)	; Get note number
	extz wa
	lda xbc, (19020:16)	; Voice slot table
	extz xwa
	add xwa, xbc
	ld (xwa), 0xFF	; Mark slot as note-on
	ld (19010:16), 144	; DMA command: note on
	ld a, (xsp + 0:8)
	ld (19011:16), a	; Store note number
	ld a, (xsp + 1)
	ld (19012:16), a	; Store velocity
	cp (19018:16), 1	; Check if DMA enabled
	jr nz, ToneGen_Note_Continue
	ld xde, 0x4A42
	ld wa, 2:i3
	ld bc, 3:i3
	call InterCPU_DMA_Send	; Send via DMA
	jr ToneGen_Note_Continue

; Already named.  Note-off arm; suppresses the message unless the per-note byte at
; 0x004A4C + note was 0xFF, so a key-up without a matching key-down sends nothing.
ToneGen_Note_Off_Slot:	; 03D06Dh
	ld a, (xsp + 0:8)
	extz wa
	lda xbc, (19020:16)
	extz xwa
	add xwa, xbc
	cp (xwa), 0xFF	; Check if slot was active
	jr nz, ToneGen_Note_Continue
	ld a, (xsp + 0:8)
	extz wa
	lda xbc, (19020:16)
	extz xwa
	add xwa, xbc
	ld (xwa), 0x0	; Clear slot
	ld (19010:16), 144	; DMA command: note off
	ld a, (xsp + 0:8)
	ld (19011:16), a
	ld a, (xsp + 1)
	ld (19012:16), a
	cp (19018:16), 1
	jr nz, ToneGen_Note_Continue
	ld xde, 0x4A42
	ld wa, 2:i3
	ld bc, 3:i3
	call InterCPU_DMA_Send

; Already named.  Fetches the next event and loops while HL != 0xFFFF.
ToneGen_Note_Continue:	; 03D0B6h
	lda xwa, (xsp)
	calr Keybed_Read_Event
	cp hl, 0xFFFF
	jrl nz, ToneGen_Note_Loop

; Already named.  `inc 2,xsp ; ret`.
ToneGen_Note_Done:	; 03D0C2h
	inc 2, xsp
	ret

; ----------------------------------------------------------------------------
; Keybed_Read_Event - Read one key event from the KEYBED port
; Entry: XWA = pointer to 2-byte result buffer
; Exit:  HL = 0 (success) or 0xFFFF (FIFO empty)
; Notes: 0x110000 / 0x110002 are the keybed data and status ports (kbd_data_r /
;        kbd_status_r in MAME's kn5000.cpp), NOT tone-generator voice state --
;        the routine was called ToneGen_Read_Voice_Data, which is wrong.
;        P6.7 is toggled around the two accesses; see the A23 note below.
;
; ★ PORT CONTRACT, as the two ROMs exercise it -- the only description of this interface
; that exists, so an implementation has to satisfy it:
;   (0x110002) STATUS, read first on every call
;     bit 0  an event is queued.  Clear -> HL = 0xFFFF and the drain loop stops for this
;            pass, with the data port left untouched.
;     bit 1  release / second-contact qualifier: when SET the event takes the same arm as a
;            0xFF touch byte.  Bits 2..15 are never tested.
;   (0x110000) DATA, read here only when status bit 0 was set.
;     low  byte  bits 0..6 = key index; bit 7 = key state, SET = DOWN, CLEAR = UP.  Both
;                ROMs mask the index ((idx >> 3) & 7, idx & 7) when addressing their 8-byte
;                bitmaps, so an index >= 64 aliases rather than being rejected -- the
;                bitmaps bound nothing at the port itself.
;     high byte  raw touch reading; 0xFF = "no touch value for this event".
; ⚠ Two things an implementer must not read into the above:
;   * [INFERENCE] that the DATA read is what advances the scanner.  Nothing in either ROM
;     writes anything back to clear bit 0, but no code observes a FIFO advance either.
;   * bit 0 does not gate every consumer: ToneGen_Poll_Read (0x03D230) reads 0x110002 and
;     then 0x110000 without testing bit 0 at all, 16 times during init.
; A second HL = 0xFFFF path exists at Keybed_Read_Event_NoteOff: a DATA word that has
; already been popped is DISCARDED when bit 7 is set, and the drain loop still stops.
; The boot ROM (subcpu/boot/kn5000_subcpu_boot.s, INTER_CPU_LATCH_READ_DISPATCH at
; 0xFF8B89) drives the same two ports with the same decode and WITHOUT any P6 access at
; all -- it never writes P6, P6CR or P6FC.  [INFERENCE] address bit 1 alone separates
; STATUS from DATA and the P6.7 toggle here is an extra select.  That bears directly on the
; open item in symbols/proposals/subcpu-region-01.txt.
; ----------------------------------------------------------------------------
; Reads ONE key event from the keybed port and decodes it.  ★ The A23 multiplex is the interesting hardware detail:
;   set bit 7 of SFR 0x18  -> A23 high -> read (0x110002) = STATUS word
;   res bit 7 of SFR 0x18  -> A23 low  -> read (0x110000) = DATA word
; (each toggle followed by a NOP for setup time).  Status bit 0 = data ready, bit 1 = note-on
; qualifier.  Data low byte = key index in bits 0..6; bit 7 is the key STATE and its sense is
; ★ SET = key DOWN, CLEAR = key UP -- NOT a "release flag".  Independent corroboration:
; ToneGen_Poll_Read (0x03D230) SETS the key's bitmap bit when bit 7 is 1 and clears it when
; bit 7 is 0, and Keybed_Decode_Event stores velocity 0 exactly on the bit-7-clear path.
; High byte = the RAW TOUCH reading, not a velocity: it is a table index, and 0xFF means "no
; touch value", which routes the event to the note-off arm.
; In:  XWA = pointer to a 2-byte result buffer.  Out: HL = 0 on an event, 0xFFFF when the FIFO
; is empty; the buffer holds the transposed note and the curve-mapped velocity.
Keybed_Read_Event:	; 03D0C5h
	push xiz
	ld xiz, xwa
	set	7, (P6:8)	; Assert A23 for status read
	nop
	ld bc, (0x110002:24)                 ; Read status register
	bit 0, bc	; Check data ready bit
	jr z, Keybed_Read_Event_NotReady
	res	7, (P6:8)	; Deassert A23 for data read
	nop
	ld wa, (0x110000:24)                 ; Read voice data (16-bit)
	ld l, a	; L = note byte (low)
	and l, 0xFF
	srl wa, 8
	ld e, a	; E = velocity byte (high)
	and e, 0xFF
	cp e, 0xFF	; Check for note-off
	jr z, Keybed_Read_Event_NoteOff
	bit 1, bc	; Check status bit 1
	jr z, Keybed_Read_Event_NoteOn

; Already named.  Note-off path; a set bit 7 in the note byte means "release, ignore".
Keybed_Read_Event_NoteOff:	; 03D0F6h
	bit 7, l	; Check note high bit (release flag)
	jr z, Keybed_Read_Event_Release
	ldw hl, 0xFFFF	; Return not ready
	jr Keybed_Read_Event_Done

; Already named.  Runs the pitch/velocity mapping then forces velocity to 0.
Keybed_Read_Event_Release:	; 03D100h
	ld c, l
	ld xwa, xiz
	calr Keybed_Decode_Event
	ld (xiz + 1), 0x0	; Clear velocity for note-off
	ld hl, 0:i3
	jr Keybed_Read_Event_Done

; Already named.  Runs the pitch/velocity mapping and keeps the velocity.
Keybed_Read_Event_NoteOn:	; 03D10Fh
	ld c, l
	ld xwa, xiz
	calr Keybed_Decode_Event
	ld hl, 0:i3
	jr Keybed_Read_Event_Done

; Already named.  Status bit 0 clear -> HL = 0xFFFF, which is what ends the drain loop.
Keybed_Read_Event_NotReady:	; 03D11Ah
	ldw hl, 0xFFFF

; Already named.  `pop xiz ; ret`.
Keybed_Read_Event_Done:	; 03D11Dh
	pop xiz
	ret

; ----------------------------------------------------------------------------
; Keybed_Decode_Event - Calculate pitch value for voice
; Entry: C = note number, XWA = result pointer
; Exit:  Pitch value stored at (XWA), velocity at (XWA+1)
; Notes: Uses lookup tables at 0x01F43E (note map), 0x01F420 (mode params)
;        Mode stored at 0x4A48, calculation uses MULS/DIVS
; ----------------------------------------------------------------------------
; Already named in the ELF; the reference file calls this address KEYBED_DECODE_EVENT -- see
; [UNCERTAIN], the reference name is the accurate one and BOTH are already real names, so
; nothing is proposed here beyond documentation.
; Maps a raw keybed event to a MIDI note number and a curved velocity.
; In:  C = raw key byte (bit 7 SET = key DOWN, CLEAR = key UP), E = raw TOUCH reading (an
;      index into 0x01F43E, not a velocity), XWA = 2-byte output buffer.
; The same computation, over byte-identical tables, as NOTE_VELOCITY_LOOKUP_CALCULATE
; (0xFF8BD2) in the sub-CPU boot ROM, which hard-codes curve 6 where this copy reads
; 0x004A48; the code bytes are not identical (prologue, table pointer, displacements).
; Shape of the two tables, read straight off the .byte listings in subcpu_data_tables.s:
;   * 0x01F43E is 255 for raw 0..8, monotonically decreasing after that, reaching 1 at raw
;     222 and 0 at raw 254/255.  A small raw number is a LOUD strike.
;   * 0x01F53E is 1 at 0, a flat 2 across 1..95, a ramp 3..16 across 96..143, and exactly
;     (index - 128) from 144 up.  The soft half of the range collapses into velocities 1..16.
;   * curve 0 (gain 0) always yields intermediate 208, i.e. MIDI velocity 80 -- touch OFF.
;   * where the intermediate stays >= 144 (the linear part of the output curve) the
;     black-key trim appears as a flat -(trim) on the delivered velocity: -16 for curve 6.
;   ⚠ UNCERTAIN: the rounding rule of `divs` (truncate toward zero vs floor) is not
;     established here and can move borderline results by one velocity; curve 0, having
;     gain 0, is unaffected either way.
; Note number: (C & 0x7F) + 0x24, i.e. the keybed's key 0 is MIDI note 36 (C2).
; Velocity: raw -> table 0x01F43E[E]; subtract the word at 0x01F418; multiply by
;   byte[0x01F420 + 3*curve]; divide by the word at 0x01F41A; add byte[0x01F421 + 3*curve];
;   for note classes 1, 3, 6, 8 and 10 of the octave (the BLACK KEYS -- note%12) subtract
;   byte[0x01F422 + 3*curve]; clamp to 0..255; final value = byte table 0x01F53E[result].
;   `curve` is the byte at 0x004A48 set by Audio_CmdHandler_A0_BF, default 6.
; This is the KN5000's touch-sensitivity curve, and the black-key correction is a real
; mechanical compensation for the different key leverage.
Keybed_Decode_Event:	; 03D11Fh
	ld l, c
	res 7, l	; Clear release flag
	add l, 0x24	; Add pitch offset (36)
	ld (xwa), l	; Store base pitch
	bit 7, c	; Check if release (note-off)
	jrl z, Keybed_Decode_NoteOff
	ld c, e
	extz bc
	lda xde, (ToneGen_Velocity_Input_Curve:24)
	ld	c, (xde+bc)
	extz bc
	extz xbc
	ld xde, xbc
	ld bc, (ToneGen_VelCurve_Pivot:24)
	ld hl, de
	sub hl, bc
	ld c, (19016:16)
	extz bc
	muls bc, 0x3
	lda xde, (ToneGen_VelCurve_ModeParams:24)
	ld	c, (xde+bc)
	extz bc
	muls xbc, hl
	ld de, (ToneGen_VelCurve_Divisor:24)
	exts xbc
	divs xbc, de
	ld hl, bc
	ld c, (19016:16)
	extz bc
	muls bc, 0x3
	lda xde, (ToneGen_VelCurve_ModeParams+1:24)
	ld	c, (xde+bc)
	extz bc
	add bc, hl
	ld de, bc
	exts xde
	ld c, (xwa)
	extz bc
	div c, 0xC
	ld c, b
	cp c, 0xA
	jr z, Keybed_Vel_BlackKey_Trim
	cp c, 0x8
	jr z, Keybed_Vel_BlackKey_Trim
	cp c, 6:i3
	jr z, Keybed_Vel_BlackKey_Trim
	cp c, 3:i3
	jr z, Keybed_Vel_BlackKey_Trim
	cp c, 1:i3
	jr nz, Keybed_Vel_Clamp

; Already named.  The black-key correction arm (note%12 in {1,3,6,8,10}).
Keybed_Vel_BlackKey_Trim:	; 03D1AAh - apply mode-specific pitch offset
	ld c, (19016:16)	; Get tone gen mode
	extz bc
	muls bc, 0x3	; mode * 3 for table index
	lda xhl, (ToneGen_VelCurve_ModeParams+2:24)                  ; Pitch offset table
	ld	c, (xhl+bc)
	extz bc
	extz xbc
	sub xde, xbc	; Apply offset

; Already named.  Upper clamp to 255.
Keybed_Vel_Clamp:	; 03D1C4h - clamp pitch to 0-255 range
	ld xbc, 0xFF
	cp xde, 0xFF
	jr gt, Keybed_Vel_ClampHi
	ld xbc, xde

; Already named.
Keybed_Vel_ClampHi:	; 03D1D3h
	ld xde, xbc
	ld xbc, 0:i3
	cp xde, 0x0
	jr lt, Keybed_Vel_ClampLo
	ld xbc, xde

; Already named.  Lower clamp to 0, then the final 0x01F53E lookup.
Keybed_Vel_ClampLo:	; 03D1E1h
	ld xde, xbc
	ld c, e
	extz bc
	lda xde, (ToneGen_Velocity_Output_Curve:24)                  ; Velocity lookup table
	ld	c, (xde+bc)
	ld (xwa + 1), c	; Store velocity
	ret

; Already named.  Release event: store velocity 0 and return.
Keybed_Decode_NoteOff:	; 03D1F5h - note-off, no velocity
	ld (xwa + 1), 0x0
	ret

; --- 0x03D1FA-0x03D1FA  ToneGen_Poll_Padding -- one alignment byte 0x0E
; Already named.  Not executed.
ToneGen_Poll_Padding:	; 03D1FAh
	.byte 0x0e

; ----------------------------------------------------------------------------
; ToneGen_Poll_Init - Initialize and poll all tone generator voices
; Entry: Called from ToneGen_Init
; Exit:  Voice status updated in buffer at (0x01F41C)
; Notes: Clears 8 voice buffers, then polls 16 iterations
; ----------------------------------------------------------------------------
; Already named (reference: TONEGEN_POLL_INIT).  The keybed's power-on scan, entered by `jrl`
; from ToneGen_Init and never called again.  Clears 8 bytes of voice-status at 0x01F41C
; (address 128028 = 0x01F41C) then falls into ToneGen_Poll_All.
ToneGen_Poll_Init:	; 03D1FBh
	ld hl, 0:i3
	cp hl, 0x8
	jr nc, ToneGen_Poll_All

; Already named.  Zeroes the 8 status bytes.
ToneGen_Clear_Voice_Loop:	; 03D203h
	ld wa, hl
	extz xwa
	add xwa, (ToneGen_Voice_Bitmap_Ptr:24)	; Voice status buffer base
	ld (xwa), 0x0	; Clear voice status
	inc 1, hl
	cp hl, 0x8
	jr c, ToneGen_Clear_Voice_Loop

; ----------------------------------------------------------------------------
; ToneGen_Poll_All - Poll tone generator for all 16 channels
; Entry: None
; Exit:  Voice status bits updated
; Notes: Reads from 0x110000/0x110002, uses P6.7 for control
; ----------------------------------------------------------------------------
; Already named.  16 polling iterations, one per keybed scan group.
ToneGen_Poll_All:	; 03D217h
	ld hl, 0:i3
	cp hl, 0x10	; 16 iterations (one per MIDI channel)
	ret nc

; Already named.  Per-iteration entry; sets up the 10000-step settling delay.
ToneGen_Poll_Channel:	; 03D21Fh
	ld wa, 0:i3
	cp wa, 0x2710	; 10000 delay cycles
	jr nc, ToneGen_Poll_Read

; Already named.  ★ A 10000-iteration NOP busy-wait, run 16 times = 160,000 NOPs of dead time
; during boot with interrupts still enabled.  Bounded, so it cannot wedge, but it is a real
; multi-millisecond stall on the audio CPU's startup path.
ToneGen_Poll_Delay:	; 03D227h
	nop
	inc 1, wa
	cp wa, 0x2710
	jr c, ToneGen_Poll_Delay

; Already named.  Same A23 multiplex as Keybed_Read_Event (SFR 0x18 bit 7): dummy-read
; (0x110002), then read (0x110000).  Splits the low byte into a group index (bits 3-5) and a
; bit position (bits 0-2), and sets or clears that bit in the status bitmap at 0x01F41C
; according to bit 7 of the byte.  The source's own comment records that A23 is tied to the
; tone generator's D5VNAD / NAD / EXADL0 pins.
ToneGen_Poll_Read:	; 03D230h
	set	7, (P6:8)	; A23 pin tied to D5VNAD (both pins "NAD" and "EXADL0" of of tone generator)
	nop
	ld wa, (0x110002:24)
	res	7, (P6:8)
	nop
	ld wa, (0x110000:24)
	ld c, a
	and c, 0xFF
	srl wa, 8
	and a, 0xFF
	ld a, c
	srl a, 3	; Extract voice index (bits 3-5)
	and a, 0x7
	ld e, a
	ld a, c
	and a, 0x7	; Extract bit position (bits 0-2)
	ld w, a
	bit 7, c	; Check note-on flag
	jr z, ToneGen_Poll_NoteOff
	ld a, e	; Note ON - set voice bit
	ldfr_berp A, 0xF0
	extz ix
	ld xbc, (ToneGen_Voice_Bitmap_Ptr:24)                 ; Voice status buffer
	ld de, 1:i3
	ld a, w
	and a, 0xF
	jr z, ToneGen_Poll_SetBit
	slaa de	; Create bit mask

; Already named.  Key-down: OR the mask into the bitmap byte.
ToneGen_Poll_SetBit:	; 03D27Ah
	or	(xbc+ix), e	; Set voice active bit
	jr ToneGen_Poll_Next

; Already named.  Key-up arm.
ToneGen_Poll_NoteOff:	; 03D281h - Note OFF - clear voice bit
	ld a, e
	ldfr_berp A, 0xF0
	extz ix
	ld xbc, (ToneGen_Voice_Bitmap_Ptr:24)
	ld de, 1:i3
	ld a, w
	and a, 0xF
	jr z, ToneGen_Poll_ClearBit
	slaa de

; Already named.  AND the complemented mask into the bitmap byte.
ToneGen_Poll_ClearBit:	; 03D298h
	ld wa, de
	cpl wa	; Invert mask
	and	(xbc+ix), a	; Clear voice bit

; Already named.  Loop back for 16 iterations, then `ret`.
ToneGen_Poll_Next:	; 03D2A1h
	inc 1, hl
	cp hl, 0x10
	jrl c, ToneGen_Poll_Channel
	ret

; The FP library (FP_dcmp onward) starts on an even address.  In v1.42 the code above ends on
; an odd one and a 0xff pad byte (FP_dcmp_AlignPad there) fills the gap; in v1.41, 0x17 bytes
; shorter, it already ends on an even address and no pad byte exists.
	.balign	2, 0xff

; ----------------------------------------------------------------------------
; FP_dcmp - Compare two voice parameter blocks
; Entry: XWA = voice 1 pointer, XBC = voice 2 pointer, DE = comparison type
; Exit:  HL = comparison result (0 = different, 1 = same, or lookup value)
; Notes: Compares 8-byte voice blocks at XWA and XBC
;        Uses lookup table at 0x03D978 for result mapping
; ----------------------------------------------------------------------------
; Already named (reference: TONEGEN_COMPARE_VOICE).  ⚠ Nothing to do with voices: this is the
; FLOAT-COMPARE PREDICATE of the FP library -- 11 of its 12 call sites are in
; subcpu_fp_math.s (the 12th is in region 13's curve code).
; In:  XWA / XBC = the two 8-byte operands, DE = the comparison-kind code.
; Out: HL = the boolean result.
;   Equal operands -> HL = byte table 0x03D978[kind].
;   kind 4 -> 0, kind 5 -> 1 (the "unordered/NaN" answers).
;   Otherwise it compares the high longs, then the low longs, taking sign into account, and
;   returns byte table 0x03D97E[kind] for "less" or 0x03D984[kind] for "greater" (each XORed
;   into L, which is how a single table serves <, <=, >, >=, ==, !=).
; ★ Renamed 2026-09-25 from ToneGen_Compare_Voice (FP library compare; see the headers).
; Toshiba C runtime ._fcmp_d (c900ml.lib, CMP_D.MAC, 1996): 34 of 34 instructions (scripts/analysis/compiler_id/).
FP_dcmp:	; 03D2ACh
	ld xix, (xwa + 4)	; Compare high 4 bytes
	cp xix, (xbc + 4)
	jr nz, FP_dcmp_HighDiffer
	ld xiy, (xwa)	; Compare low 4 bytes
	cp xiy, (xbc)
	jr nz, FP_dcmp_NotEqual
	lda xix, (FP_CmpResult_Equal:24)                  ; Exact match - lookup result
	ld	l, (xix+de)
	ld h, 0x0:opc
	ret

; Already named.  High halves differ; reload the low half and fall through.
; ★ Renamed 2026-09-25 from ToneGen_Compare_Diff (FP library compare; see the headers).
FP_dcmp_HighDiffer:	; 03D2C7h
	ld xiy, (xwa)

; Already named.  The kind-4 / kind-5 early answers.
; ★ Renamed 2026-09-25 from ToneGen_Compare_Result (FP library compare; see the headers).
FP_dcmp_NotEqual:	; 03D2C9h
	ld hl, 0:i3
	cp de, 4:i3
	ret z
	ld hl, 1:i3
	cp de, 5:i3
	ret z
	ld xwa, (xbc + 4)
	ld hl, 0:i3
	ldcf_erpw 0xF2, 0x0F
	jr nc, FP_dcmp_Sign
	xorcf_erpw 0xE2, 0x0F
	scc16 nc, hl

; Already named.  Signed magnitude comparison of the two operands.
; ★ Renamed 2026-09-25 from ToneGen_Compare_Sign (FP library compare; see the headers).
FP_dcmp_Sign:	; 03D2E6h
	cp xix, xwa
	jr gt, FP_dcmp_Greater
	jr lt, FP_dcmp_Less
	cp xiy, (xbc)
	jr ugt, FP_dcmp_Greater

; Already named.  Result from the 0x03D97E table.
; ★ Renamed 2026-09-25 from ToneGen_Cmp_Less (FP library compare; see the headers).
FP_dcmp_Less:	; 03D2F0h - voice 1 < voice 2
	lda xix, (FP_CmpResult_Less:24)                  ; Less-than lookup table
	xor	l, (xix+de)
	ret

; Already named.  Result from the 0x03D984 table.
; ★ Renamed 2026-09-25 from ToneGen_Cmp_Greater (FP library compare; see the headers).
FP_dcmp_Greater:	; 03D2FBh - voice 1 > voice 2
	lda xix, (FP_CmpResult_Greater:24)                  ; Greater-than lookup table
	xor	l, (xix+de)
	ret

; ----------------------------------------------------------------------------
; FP_fcmp - Compare two 32-bit voice parameters
; Entry: XWA = voice 1 pointer, XBC = voice 2 pointer, DE = comparison type
; Exit:  HL = comparison result
; Notes: Simplified version comparing only first 4 bytes
; ----------------------------------------------------------------------------
; Already named (reference: TONEGEN_COMPARE_VOICE_32).  The 32-bit (single-precision) form of
; the same predicate; same three result tables at 0x03D978 / 0x03D97E / 0x03D984.
; Exactly one call site, at 0x03AD0C inside DSP_BiquadCoeff_Algo0_Assembly, testing a0 == 1.0.
; ★ Renamed 2026-09-25 from ToneGen_Compare_Voice_32 (FP library compare; see the headers).
; Toshiba C runtime ._fcmp_f (c900ml.lib, CMP_F.MAC, 1996): 26 of 26 instructions (scripts/analysis/compiler_id/).
FP_fcmp:	; 03D306h
	ld hl, 0:i3
	ld xwa, (xwa)	; Load 32-bit value from voice 1
	ld xbc, (xbc)	; Load 32-bit value from voice 2
	cp xwa, xbc
	jr nz, FP_fcmp_NotEqual
	lda xix, (FP_CmpResult_Equal:24)                  ; Equal - lookup result
	ld	l, (xix+de)
	ret

; Already named.  kind-4 / kind-5 early answers for the 32-bit form.
; ★ Renamed 2026-09-25 from ToneGen_Cmp32_NotEqual (FP library compare; see the headers).
FP_fcmp_NotEqual:	; 03D31Bh
	cp de, 4:i3
	ret z
	ld hl, 1:i3
	cp de, 5:i3
	ret z
	ld hl, 0:i3
	ldcf_erpw 0xE2, 0x0F	; Load carry from sign bit
	jr nc, FP_fcmp_Sign
	xorcf_erpw 0xE6, 0x0F
	scc16 nc, hl

; Already named.
; ★ Renamed 2026-09-25 from ToneGen_Cmp32_Sign (FP library compare; see the headers).
FP_fcmp_Sign:	; 03D333h
	cp xwa, xbc
	jr gt, FP_fcmp_Greater
	lda xix, (FP_CmpResult_Less:24)
	xor	l, (xix+de)
	ret

; Already named.
; ★ Renamed 2026-09-25 from ToneGen_Cmp32_Greater (FP library compare; see the headers).
FP_fcmp_Greater:	; 03D342h
	lda xix, (FP_CmpResult_Greater:24)
	xor	l, (xix+de)
	ret

; A double-precision transcendental wrapper, almost certainly cos(x) implemented as
; sin(pi/2 - x) -- called once from the FP library (subcpu_fp_math.s:127).
; In:  one 8-byte double pushed by the caller plus a destination pointer; 48 bytes of frame.
; Body: FP_fabs to fetch/normalise the argument; then
;       FP_dadd(dest, 0x00F3CA = 1.5707963267948966 = pi/2, arg)  -- FP_dadd is ADD/SUB,
;       so this is the pi/2 - x fold; then FP_SinCos_Kernel (0x03D98A), which is the
;       polynomial/series evaluator; then FP_DP_Raw8Copy to publish the result.
; Medium confidence because the series constants inside FP_SinCos_Kernel were not
; decoded in this pass; the pi/2 fold and the call graph are certain.
; RENAMED 2026-09-25: was VoiceFloat_DispatchMulAdd (scripts/renaming/rename_v142_fp_libm.sed); the name now says
; what the header above established.
FP_cos:
	lda xsp, (xsp - 48)
	pushw 0x0
	lda xiy, (xsp + 58)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 34)
	push xwa
	call FP_fabs
	lda xsp, (xsp + 12)
	lda xbc, (FPConst_HalfPi:24)
	lda xde, (xsp + 26)
	lda xwa, (xsp + 34)
	call FP_dadd
	lda xiy, (xsp + 34)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xiy, (xsp + 66)
	ld xix, (xiy + 4)
	push xix
	ld xix, (xiy)
	push xix
	lda xwa, (xsp + 58)
	push xwa
	call FP_SinCos_Kernel
	lda xsp, (xsp + 22)
	ld xwa, (xsp + 52)
	lda xbc, (xsp + 40)
	call FP_DP_Raw8Copy
	lda xsp, (xsp + 48)
	ret

; ⚠ NOT a subtraction: this is DOUBLE-PRECISION DIVIDE.  27 call sites (7 in the FP library,
; 20 in the DSP curve/coefficient code).
; In:  XWA = destination (8-byte double), XBC = dividend pointer, XDE = divisor pointer.
; Body: FP_DP_Decode both operands into 12-byte scratch buffers on the stack, call
;       FP_DP_DivCore (0x03E3F6) -- which SUBTRACTS the exponents and XORs the signs, i.e.
;       divides -- then FP_DP_Encode the result to *(XWA).
; No hardware access.  See [UNCERTAIN] for the naming.
; RENAMED 2026-09-25: was VoiceFloat_SubDP (scripts/renaming/rename_v142_fp_libm.sed); the name now says
; what the header above established.
FP_ddiv:
	push xiz
	lda xsp, (xsp - 28)
	ld xiz, xde
	ld (xsp + 24), xwa
	ld xwa, xsp
	call FP_DP_Decode
	ld xbc, xiz
	lda xiz, (xsp + 12)
	lda xwa, (xiz)
	call FP_DP_Decode
	ld xwa, xsp
	lda xbc, (xiz)
	call FP_DP_DivCore
	ld xwa, (xsp + 24)
	ld xbc, xsp
	call FP_DP_Encode
	lda xsp, (xsp + 28)
	pop xiz
	ret

; ⚠ NOT a subtraction: SINGLE-PRECISION DIVIDE.  74 call sites -- it is how every coefficient
; in this region gets normalised by a0 and how every dB value gets divided by 20.0.
; In:  XWA = destination (4-byte float), XBC = dividend pointer, XDE = divisor pointer.
; Body: FP_SP_Decode both operands, FP_SP_DivCore (0x03E4B4) = divide, FP_SP_Encode.
; Region 15 ends at 0x03D403, the last byte of this routine.
; RENAMED 2026-09-25: was VoiceFloat_SubSP (scripts/renaming/rename_v142_fp_libm.sed); the name now says
; what the header above established.
FP_fdiv:
	push xiz
	lda xsp, (xsp - 20)
	ld xiz, xde
	ld (xsp + 16), xwa
	ld xwa, xsp
	call FP_SP_Decode
	ld xbc, xiz
	lda xiz, (xsp + 8)
	lda xwa, (xiz)
	call FP_SP_Decode
	ld xwa, xsp
	lda xbc, (xiz)
	call FP_SP_DivCore
	ld xwa, (xsp + 16)
	ld xbc, xsp
	call FP_SP_Encode
	lda xsp, (xsp + 20)
	pop xiz
	ret


