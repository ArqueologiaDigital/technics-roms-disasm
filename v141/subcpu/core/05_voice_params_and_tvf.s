; ===========================================================================
; ToneGen_Read_Register - Read one tone-generator register
; ===========================================================================
; (Was DAC_Write_Sample.  Nothing here writes a sample: 0x100000 is the tone
;  generator's register-ADDRESS latch on write and its status word on read --
;  see subcpu_mem in MAME's kn5000.cpp.)
; Entry: WA = TG register number to latch.
; Exit:  HL = the word read back for that register.
; Notes: clearing P6.7 (SFR 0x18 bit 7) drives A23 low, selecting the TG rather
;        than the keybed side of the multiplex.
;        Latch 0..3     -> HL = the 16-bit ACTIVE-VOICE BITMAP for that bank.
;        Latch 0x180+ch -> HL = that channel's envelope level.
;        This is the single point where the TG active-voice bitmap re-enters
;        sub-CPU software (caller: Voice_Manager_PollBank).
;        It is the only read of the REGISTER window in the whole payload: 139 writes to the
;        address latch 0x100000, 137 direct-addressing writes to the data port 0x100002
;        (which is never read at all), and this single `ldw_da`. Qualify the line above
;        accordingly: the same chip's other window (0x110000 / 0x110002, A23 high) is read
;        four times, by Keybed_Read_Event and ToneGen_Poll_Read, and ToneGen_Poll_Read
;        keeps its own per-voice on/off bitmap at 0x01F41C -- so this is the only path for
;        the bitmap the REGISTER FILE returns, not the only voice-state feedback there is.
;        No read anywhere returns a wave-ROM byte: IC304-IC307 hang off IC303 and are in no
;        CPU's address space, which is why the wave directory is [INFERENCE] walked by the
;        chip and not by this firmware. See "WHAT +0x040 SELECTS" near the 0x0451CC staging
;        block.
; ===========================================================================
ToneGen_Read_Register:
	res	7, (P6:8)
	ld (ToneGen_RegAddrLatch:24), wa
	ld hl, (ToneGen_RegAddrLatch:24)
	ret

; MIDI_Backlog_Publish(WA = the MIDI ring's current byte count) -- was
; RingBuf_SetOffsetHi, which is not what it does: it stores the count to the word at
; 0x27E7, the MIDI BACKLOG GAUGE.  Sole caller: MIDI_Dispatch (0x034D93).  The value is
; read back only by RingBuf_CheckOffset_ClearFlags (0x02103B), which compares it against
; 0x20/0x30 (or 0x40/0x50 when the byte at 0x27E6 is zero) and drops layer slots 1..3 --
; i.e. it is a backpressure threshold that thins the polyphony when MIDI falls behind.
MIDI_Backlog_Publish:
	ld (10215:16), wa
	ret

RingBuf_SetOffsetLo:
	ld (10214:16), a
	ret

RingBuf_CheckOffset_ClearFlags:
	cp (10214:16), 0
	jr z, RingBuf_CheckOffset_LoZero
	cpw (10215:16), 48
	jr c, RingBuf_CheckOffset_Level1
	resm 7, (xwa + 3)
	resm 7, (xwa + 4)
	resm 7, (xwa + 5)
	ret

RingBuf_CheckOffset_Level1:
	cpw (10215:16), 32
	ret c
	resm 7, (xwa + 4)
	resm 7, (xwa + 5)
	ret

RingBuf_CheckOffset_LoZero:
	cpw (10215:16), 80
	jr c, RingBuf_CheckOffset_LoZero_Level1
	resm 7, (xwa + 3)
	resm 7, (xwa + 4)
	resm 7, (xwa + 5)
	ret

RingBuf_CheckOffset_LoZero_Level1:
	cpw (10215:16), 64
	ret c
	resm 7, (xwa + 4)
	resm 7, (xwa + 5)
	ret

Quad_Decode_A_To_L:
	cp a, 0x40
	jr nc, Quad_Decode_Quarter2
	ld l, 0x0:opc
	jr Quad_Decode_Return

Quad_Decode_Quarter2:
	cp a, 0x80
	jr nc, Quad_Decode_Quarter3
	ld l, 0x4:opc
	jr Quad_Decode_Return

Quad_Decode_Quarter3:
	cp a, 0xC0
	jr nc, Quad_Decode_Quarter4
	ld l, 0x8:opc
	jr Quad_Decode_Return

Quad_Decode_Quarter4:
	ld l, 0x0:opc

Quad_Decode_Return:
	ret

ExtVoice_Fold_SlotNumber:
	and c, 0x3
	cp c, 3:i3
	jr z, ExtVoice_Fold_SlotNumber_Group3_IndexInBank2
	cp c, 2:i3
	jr z, ExtVoice_Fold_SlotNumber_Group2_IndexFromBank1
	cp c, 1:i3
	jr z, ExtVoice_Fold_SlotNumber_Group0Or1_IndexInBank
	cp c, 0:i3
	ret nz

; ExtVoice_Fold_SlotNumber_Group0Or1_IndexInBank: Groups 0 and 1 (group 0 falls in from the test above): L = slot &
;   0x3F, the slot's index inside its 64-slot bank.
ExtVoice_Fold_SlotNumber_Group0Or1_IndexInBank:
	and a, 0x3F
	ld l, a
	jr SlotPair_Decode_Return

; ExtVoice_Fold_SlotNumber_Group2_IndexFromBank1: Group 2 spans banks 1 and 2: L = (slot - 0x40) & 0x7F.
ExtVoice_Fold_SlotNumber_Group2_IndexFromBank1:
	sub a, 0x40
	ld l, a
	res 7, l
	jr SlotPair_Decode_Return

ExtVoice_Fold_SlotNumber_Group3_IndexInBank2:
	ld l, a
	res 7, l

SlotPair_Decode_Return:
	ret

VoiceState_SwapSlot_DE_BC:
	ld e, c
	extz de
	ld ix, de
	ld e, a
	extz de
	muls de, 0xC
	lda xhl, (9446:16)
	exts xde
	add xde, xhl
	ld hl, ix
	extz xhl
	add xhl, xde
	ld b, (xhl)
	ld e, c
	extz de
	ld ix, de
	inc 4, ix
	ld e, a
	extz de
	muls de, 0xC
	lda xhl, (9446:16)
	exts xde
	add xde, xhl
	ld hl, ix
	extz xhl
	add xhl, xde
	ld w, (xhl)
	ld e, c
	extz de
	ld ix, de
	ld e, w
	extz de
	muls de, 0xC
	lda xhl, (9446:16)
	exts xde
	add xde, xhl
	ld hl, ix
	extz xhl
	add xhl, xde
	ld (xhl), b
	ld e, c
	extz de
	ld ix, de
	inc 4, ix
	ld e, b
	extz de
	muls de, 0xC
	lda xhl, (9446:16)
	exts xde
	add xde, xhl
	ld hl, ix
	extz xhl
	add xhl, xde
	ld (xhl), w
	ld e, c
	extz de
	ld ix, de
	ld e, a
	extz de
	muls de, 0xC
	lda xhl, (9446:16)
	exts xde
	add xde, xhl
	ld hl, ix
	extz xhl
	add xhl, xde
	ld (xhl), a
	extz bc
	ld hl, bc
	inc 4, hl
	ld c, a
	extz bc
	muls bc, 0xC
	lda xde, (9446:16)
	exts xbc
	add xbc, xde
	ld de, hl
	extz xde
	add xde, xbc
	ld (xde), a
	ret

VoiceState_SwapSlot_HL_IY:
	ld l, c
	extz hl
	ld iy, hl
	ld l, a
	extz hl
	muls hl, 0xC
	lda xix, (9446:16)
	exts xhl
	add xhl, xix
	ld ix, iy
	extz xix
	add xix, xhl
	ld b, (xix)
	ld l, c
	extz hl
	ld iy, hl
	inc 4, iy
	ld l, a
	extz hl
	muls hl, 0xC
	lda xix, (9446:16)
	exts xhl
	add xhl, xix
	ld ix, iy
	extz xix
	add xix, xhl
	ld w, (xix)
	ld l, c
	extz hl
	ld iy, hl
	ld l, w
	extz hl
	muls hl, 0xC
	lda xix, (9446:16)
	exts xhl
	add xhl, xix
	ld ix, iy
	extz xix
	add xix, xhl
	ld (xix), b
	ld l, c
	extz hl
	ld iy, hl
	inc 4, iy
	ld l, b
	extz hl
	muls hl, 0xC
	lda xix, (9446:16)
	exts xhl
	add xhl, xix
	ld ix, iy
	extz xix
	add xix, xhl
	ld (xix), w
	ld l, c
	extz hl
	ld iy, hl
	inc 4, iy
	ld l, e
	extz hl
	muls hl, 0xC
	lda xix, (9446:16)
	exts xhl
	add xhl, xix
	ld ix, iy
	extz xix
	add xix, xhl
	ld w, (xix)
	ld l, c
	extz hl
	ld iy, hl
	ld l, w
	extz hl
	muls hl, 0xC
	lda xix, (9446:16)
	exts xhl
	add xhl, xix
	ld ix, iy
	extz xix
	add xix, xhl
	ld (xix), a
	ld l, c
	extz hl
	ld iy, hl
	inc 4, iy
	ld l, a
	extz hl
	muls hl, 0xC
	lda xix, (9446:16)
	exts xhl
	add xhl, xix
	ld ix, iy
	extz xix
	add xix, xhl
	ld (xix), w
	ld l, c
	extz hl
	ld iy, hl
	ld l, a
	extz hl
	muls hl, 0xC
	lda xix, (9446:16)
	exts xhl
	add xhl, xix
	ld ix, iy
	extz xix
	add xix, xhl
	ld (xix), e
	extz bc
	ld hl, bc
	inc 4, hl
	ld c, e
	extz bc
	muls bc, 0xC
	lda xde, (9446:16)
	exts xbc
	add xbc, xde
	ld de, hl
	extz xde
	add xde, xbc
	ld (xde), a
	ret

VoiceState_SwapSlot_Guarded:
	dec 8, xsp
	ld (xsp + 4), e
	ld (xsp + 6), c
	ld c, a
	extz bc
	muls bc, 0xC
	lda xde, (9446:16)
	exts xbc
	add xbc, xde
	ld (xsp), xbc
	ld c, (xsp + 6)
	extz bc
	ld de, bc
	inc 8, de
	ld xbc, (xsp)
	ld	e, (xbc+de)
	ld c, e
	cp c, 0xC0
	jr nc, VoiceState_SwapSlot_Guarded_WriteDst
	ld c, e
	extz bc
	muls bc, 0x5
	lda xde, (8486:16)
	lda	xix, (xde+bc)
	cp (xix + 4), a
	jr nz, VoiceState_SwapSlot_Guarded_WriteDst
	ld c, (xsp + 6)
	ld e, c
	extz de
	ld xbc, (xsp)
	cp	(xbc+de), a
	jr z, VoiceState_SwapSlot_Guarded_MarkInactive
	ld c, (xsp + 6)
	ld e, c
	extz de
	ld xbc, (xsp)
	ld	c, (xbc+de)
	ld (xix + 4), c
	jr VoiceState_SwapSlot_Guarded_WriteDst

VoiceState_SwapSlot_Guarded_MarkInactive:
	ld (xix + 4), 0xFF

VoiceState_SwapSlot_Guarded_WriteDst:
	ld c, (xsp + 4)
	extz bc
	muls bc, 0x5
	lda xde, (8486:16)
	lda	xix, (xde+bc)
	cp (xix + 4), 0x40
	jr ule, VoiceState_SwapSlot_Guarded_UseHL_IY
	ld (xix + 4), a
	ld e, a
	extz de
	ld a, (xsp + 6)
	ld c, a
	extz bc
	ld wa, de
	calr VoiceState_SwapSlot_DE_BC
	jr VoiceState_SwapSlot_Guarded_Return

VoiceState_SwapSlot_Guarded_UseHL_IY:
	ld l, a
	extz hl
	ld a, (xsp + 6)
	ld c, a
	extz bc
	ld a, (xix + 4)
	ld e, a
	extz de
	ld wa, hl
	calr VoiceState_SwapSlot_HL_IY

VoiceState_SwapSlot_Guarded_Return:
	ld a, (xsp + 6)
	extz wa
	ld de, wa
	inc 8, de
	ld xwa, (xsp)
	ld c, (xsp + 4)
	ld	(xwa+de), c
	inc 8, xsp
	ret

VoiceRow_FetchPair_WA_SP:
	ld c, a
	extz bc
	muls bc, 0x5
	lda xde, (8486:16)
	ld	w, (xde+bc)
	ld c, a
	extz bc
	muls bc, 0x5
	lda xde, (8487:16)
	ld	l, (xde+bc)
	ld c, l
	extz bc
	muls bc, 0x5
	lda xde, (8486:16)
	ld	(xde+bc), w
	ld c, w
	extz bc
	muls bc, 0x5
	lda xde, (8487:16)
	ld	(xde+bc), l
	ld c, a
	extz bc
	muls bc, 0x5
	lda xde, (8486:16)
	ld	(xde+bc), a
	ld c, a
	extz bc
	muls bc, 0x5
	lda xde, (8487:16)
	ld	(xde+bc), a
	ret

VoiceRow_FetchPair_DE_WA:
	ld e, a
	extz de
	muls de, 0x5
	lda xhl, (8486:16)
	ld	b, (xhl+de)
	ld e, a
	extz de
	muls de, 0x5
	lda xhl, (8487:16)
	ld	w, (xhl+de)
	ld e, w
	extz de
	muls de, 0x5
	lda xhl, (8486:16)
	ld	(xhl+de), b
	ld e, b
	extz de
	muls de, 0x5
	lda xhl, (8487:16)
	ld	(xhl+de), w
	ld e, c
	extz de
	muls de, 0x5
	lda xhl, (8487:16)
	ld	w, (xhl+de)
	ld e, w
	extz de
	muls de, 0x5
	lda xhl, (8486:16)
	ld	(xhl+de), a
	ld e, a
	extz de
	muls de, 0x5
	lda xhl, (8487:16)
	ld	(xhl+de), w
	ld e, a
	extz de
	muls de, 0x5
	lda xhl, (8486:16)
	ld	(xhl+de), c
	extz bc
	muls bc, 0x5
	lda xde, (8487:16)
	ld	(xde+bc), a
	ret

VoiceSlot_UpdateNoteSource:
	dec 4, xsp
	push xiz
	ld (xsp + 4), e
	ld (xsp + 6), c
	ld c, a
	extz bc
	muls bc, 0x5
	lda xde, (8486:16)
	lda	xiz, (xde+bc)
	ld c, (xiz + 2)
	extz bc
	muls bc, 0x1B
	lda xde, (7757:16)
	lda	xhl, (xde+bc)
	ld e, (xiz + 3)
	ld c, e
	extz bc
	cp	(xhl+bc), a
	jr nz, VoiceSlot_UpdateNoteSource_WriteCurrent
	cp (xiz), a
	jr z, VoiceSlot_UpdateNoteSource_MarkInactive
	extz de
	ld c, (xiz)
	ld	(xhl+de), c
	jr VoiceSlot_UpdateNoteSource_WriteCurrent

VoiceSlot_UpdateNoteSource_MarkInactive:
	ld c, e
	extz bc
	ld	(xhl+bc), 0xff

VoiceSlot_UpdateNoteSource_WriteCurrent:
	ld c, (xsp + 6)
	extz bc
	muls bc, 0x1B
	lda xde, (7757:16)
	lda	xhl, (xde+bc)
	ld c, (xsp + 4)
	extz bc
	cp	(xhl+bc), 0xc0
	jr ule, VoiceSlot_UpdateNoteSource_UseDE_WA
	ld c, (xsp + 4)
	extz bc
	ld	(xhl+bc), a
	extz wa
	calr VoiceRow_FetchPair_WA_SP
	jr VoiceSlot_UpdateNoteSource_Return

VoiceSlot_UpdateNoteSource_UseDE_WA:
	ld e, a
	extz de
	ld a, (xsp + 4)
	extz wa
	ld	a, (xhl+wa)
	ld c, a
	extz bc
	ld wa, de
	calr VoiceRow_FetchPair_DE_WA

VoiceSlot_UpdateNoteSource_Return:
	ld a, (xsp + 6)
	ld (xiz + 2), a
	ld a, (xsp + 4)
	ld (xiz + 3), a
	pop xiz
	inc 4, xsp
	ret

Voice_ScanSlots_ReassignSources:
	dec 6, xsp
	push xiz
	ld (xsp + 8), a
	ld a, (xsp + 8)
	extz wa
	muls wa, 0xC
	lda xbc, (9446:16)
	exts xwa
	add xwa, xbc
	ld (xsp + 4), xwa
	ldib_erp 0xFB, 0
	cpib_erp 0xFB, 4
	jrl nc, Voice_ScanSlots_Return

Voice_ScanSlots_LoopBody:
	ldto_berp A, 0xFB
	extz wa
	ld bc, wa
	inc 8, bc
	ld xwa, (xsp + 4)
	ld	l, (xwa+bc)
	ld a, l
	cp a, 0xC0
	jrl nc, Voice_ScanSlots_LoopNext
	ld a, l
	extz wa
	muls wa, 0x5
	lda xbc, (8486:16)
	lda	xde, (xbc+wa)
	ld a, (xde + 4)
	cp a, (xsp + 8)
	jr nz, Voice_ScanSlots_MarkSlotInactive
	ldto_berp A, 0xFB
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	ld	a, (xwa+bc)
	cp a, (xsp + 8)
	jr z, Voice_ScanSlots_PromoteSource
	ldto_berp A, 0xFB
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	ld	a, (xwa+bc)
	ld (xde + 4), a
	jr Voice_ScanSlots_MarkSlotInactive

Voice_ScanSlots_PromoteSource:
	ld (xde + 4), 0xFF
	ldfr_berp L, 0xF8
	extz iz
	ld a, l
	extz wa
	calr Quad_Decode_A_To_L
	ld c, l
	extz bc
	ld wa, iz
	ld de, bc
	ldw bc, 0x1A
	calr VoiceSlot_UpdateNoteSource

Voice_ScanSlots_MarkSlotInactive:
	ld a, (xsp + 8)
	ld e, a
	extz de
	ldto_berp A, 0xFB
	ld c, a
	extz bc
	ld wa, de
	calr VoiceState_SwapSlot_DE_BC
	ldto_berp A, 0xFB
	extz wa
	ld bc, wa
	inc 8, bc
	ld xwa, (xsp + 4)
	ld	(xwa+bc), 0xff

Voice_ScanSlots_LoopNext:
	inc1b_erp 0xFB
	cpib_erp 0xFB, 4
	jrl c, Voice_ScanSlots_LoopBody

Voice_ScanSlots_Return:
	pop xiz
	inc 6, xsp
	ret

VoiceState_FullReset:
	push xiz
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x40
	jr nc, VoiceState_FullReset_Phase2

VoiceState_FullReset_Phase1_SlotLoop:
	ld c, 0x0:opc
	cp c, 4:i3
	jr nc, VoiceState_FullReset_Phase1_Next

VoiceState_FullReset_Phase1_ColLoop:
	ld a, c
	extz wa
	ld hl, wa
	inc 8, hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0xC
	lda xde, (9446:16)
	exts xwa
	add xwa, xde
	ld de, hl
	extz xde
	add xde, xwa
	ld (xde), 0xFF
	ld a, c
	extz wa
	ld hl, wa
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0xC
	lda xde, (9446:16)
	exts xwa
	add xwa, xde
	ld de, hl
	extz xde
	add xde, xwa
	ldto_berp A, 0xFB
	ld (xde), a
	ld a, c
	extz wa
	ld hl, wa
	inc 4, hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0xC
	lda xde, (9446:16)
	exts xwa
	add xwa, xde
	ld de, hl
	extz xde
	add xde, xwa
	ldto_berp A, 0xFB
	ld (xde), a
	inc 1, c
	cp c, 4:i3
	jr c, VoiceState_FullReset_Phase1_ColLoop

VoiceState_FullReset_Phase1_Next:
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x40
	jr c, VoiceState_FullReset_Phase1_SlotLoop

VoiceState_FullReset_Phase2:
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0xC0
	jr nc, VoiceState_FullReset_Phase3

VoiceState_FullReset_Phase2_Loop:
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x5
	ld bc, wa
	lda xde, (8486:16)
	ldto_berp A, 0xFB
	ld	(xde+bc), a
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x5
	ld bc, wa
	lda xde, (8487:16)
	ldto_berp A, 0xFB
	ld	(xde+bc), a
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x5
	lda xbc, (8488:16)
	ld	(xbc+wa), 0x00
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x5
	lda xbc, (8489:16)
	ld	(xbc+wa), 0x00
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x5
	lda xbc, (8490:16)
	ld	(xbc+wa), 0xff
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0xC0
	jr c, VoiceState_FullReset_Phase2_Loop

VoiceState_FullReset_Phase3:
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x1B
	jr nc, VoiceState_FullReset_Phase3_InitSlots

VoiceState_FullReset_Phase3_ClearLoop:
	ld c, 0x0:opc
	cp c, 0x1B
	jr nc, VoiceState_FullReset_Phase3_ClearNext

VoiceState_FullReset_Phase3_ClearInner:
	ld a, c
	extz wa
	ld hl, wa
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x1B
	lda xde, (7757:16)
	exts xwa
	add xwa, xde
	ld de, hl
	extz xde
	add xde, xwa
	ld (xde), 0xFF
	inc 1, c
	cp c, 0x1B
	jr c, VoiceState_FullReset_Phase3_ClearInner

VoiceState_FullReset_Phase3_ClearNext:
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x1B
	jr c, VoiceState_FullReset_Phase3_ClearLoop

VoiceState_FullReset_Phase3_InitSlots:
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0xC0
	jr nc, VoiceState_FullReset_Phase3_Return

VoiceState_FullReset_Phase3_InitBody:
	ldto_berp A, 0xFB
	ldfr_berp A, 0xF8
	extz iz
	ldto_berp A, 0xFB
	extz wa
	calr Quad_Decode_A_To_L
	ld c, l
	extz bc
	ld wa, iz
	ld de, bc
	ldw bc, 0x1A
	calr VoiceSlot_UpdateNoteSource
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0xC0
	jr c, VoiceState_FullReset_Phase3_InitBody

VoiceState_FullReset_Phase3_Return:
	pop xiz
	ret

ExtVoice_Lookup_SlotFallback:
	lda xbc, (8459:16)
	and wa, 0x3
	cp wa, 3:i3
	jr z, ExtVoice_Lookup_SlotFallback_Group3_Bank2
	cp wa, 2:i3
	jr z, ExtVoice_Lookup_SlotFallback_Group2_Bank2ElseBank1
	cp wa, 1:i3
	jr z, ExtVoice_Lookup_SlotFallback_Group1_Bank1
	cp wa, 0:i3
	ret nz
	ld l, (xbc)
	jr ExtVoice_Lookup_SlotFallback_Return

ExtVoice_Lookup_SlotFallback_Group1_Bank1:
	ld l, (xbc + 4)
	jr ExtVoice_Lookup_SlotFallback_Return

; ExtVoice_Lookup_SlotFallback_Group2_Bank2ElseBank1: Group 2: the bank-2 column, falling back to the bank-1 column
;   when it holds no slot (> 0xC0).
ExtVoice_Lookup_SlotFallback_Group2_Bank2ElseBank1:
	ld l, (xbc + 8)
	cp l, 0xC0
	ret ule
	ld l, (xbc + 4)
	jr ExtVoice_Lookup_SlotFallback_Return

ExtVoice_Lookup_SlotFallback_Group3_Bank2:
	ld l, (xbc + 8)

ExtVoice_Lookup_SlotFallback_Return:
	ret

ExtVoice_Alloc_StreamSlot:
	dec 8, xsp
	pushw_erp 0xFA
	ld (xsp + 4), e
	ld (xsp + 6), c
	ld (xsp + 8), a
	andmi8 (xsp + 4), 0x3F
	cp (xsp + 6), 0x40
	jr nc, ExtVoice_Alloc_StreamSlot_NoMatch
	cp (xsp + 8), 0x1A
	jr c, ExtVoice_Alloc_StreamSlot_Search

ExtVoice_Alloc_StreamSlot_NoMatch:
	ld a, (xsp + 4)
	extz wa
	sll wa, 8
	ld hl, wa
	or hl, 0xFF
	jrl ExtVoice_Alloc_StreamSlot_Return

ExtVoice_Alloc_StreamSlot_Search:
	ld a, (xsp + 4)
	and a, 0x1F
	extz wa
	lda xbc, (Voice_PolyphonyLimits_Table:24)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xFA
	ld a, (xsp + 4)
	extz wa
	lda xbc, (Voice_IndexMapping_Table:24)
	ld	a, (xbc+wa)
	ld (xsp + 2), a
	ld a, (xsp + 6)
	extz wa
	muls wa, 0xC
	lda xbc, (9446:16)
	lda	xbc, (xbc+wa)
	ldto_berp A, 0xFA
	extz wa
	inc 8, wa
	ld	a, (xbc+wa)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0xC0
	jr nc, ExtVoice_Alloc_StreamSlot_FallbackFB
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x5
	lda xbc, (8486:16)
	lda	xbc, (xbc+wa)
	ld a, (xbc + 2)
	cp a, (xsp + 8)
	jr nz, ExtVoice_Alloc_StreamSlot_FallbackFB
	ld a, (xbc + 3)
	cp a, (xsp + 2)
	jr nz, ExtVoice_Alloc_StreamSlot_FallbackFB
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ldto_berp A, 0xFA
	ld c, a
	extz bc
	ld wa, de
	calr ExtVoice_Fold_SlotNumber
	ld c, l
	extz bc
	ld a, (xsp + 4)
	set 7, a
	extz wa
	sll wa, 8
	ld hl, wa
	or hl, bc
	jrl ExtVoice_Alloc_StreamSlot_Return

ExtVoice_Alloc_StreamSlot_FallbackFB:
	bitm 5, (xsp + 4)
	jr z, ExtVoice_Alloc_StreamSlot_TryNoteSourceTable
	ldto_berp A, 0xFA
	extz wa
	calr ExtVoice_Lookup_SlotFallback
	ldfr_berp L, 0xFB
	ldto_berp A, 0xFB
	cp a, 0xC0
	jr nc, ExtVoice_Alloc_StreamSlot_FallbackFB_Inactive
	ldto_berp A, 0xFB
	ld l, a
	extz hl
	ld a, (xsp + 8)
	ld c, a
	extz bc
	ld a, (xsp + 2)
	ld e, a
	extz de
	ld wa, hl
	calr VoiceSlot_UpdateNoteSource
	ld a, (xsp + 6)
	ld l, a
	extz hl
	ldto_berp A, 0xFA
	ld c, a
	extz bc
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ld wa, hl
	calr VoiceState_SwapSlot_Guarded
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ldto_berp A, 0xFA
	ld c, a
	extz bc
	ld wa, de
	calr ExtVoice_Fold_SlotNumber
	jrl ExtVoice_Alloc_StreamSlot_PackResult

ExtVoice_Alloc_StreamSlot_FallbackFB_Inactive:
	ld l, 0xFF:opc
	jrl ExtVoice_Alloc_StreamSlot_PackResult

ExtVoice_Alloc_StreamSlot_TryNoteSourceTable:
	ld a, (xsp + 2)
	extz wa
	ld de, wa
	ld a, (xsp + 8)
	extz wa
	muls wa, 0x1B
	lda xbc, (7757:16)
	exts xwa
	add xwa, xbc
	ld bc, de
	extz xbc
	add xbc, xwa
	ld a, (xbc)
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0xC0
	jr nc, ExtVoice_Alloc_StreamSlot_FallbackFA
	ld a, (xsp + 6)
	ld l, a
	extz hl
	ldto_berp A, 0xFA
	ld c, a
	extz bc
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ld wa, hl
	calr VoiceState_SwapSlot_Guarded
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ldto_berp A, 0xFA
	ld c, a
	extz bc
	ld wa, de
	calr ExtVoice_Fold_SlotNumber
	setm 7, (xsp + 4)
	jr ExtVoice_Alloc_StreamSlot_PackResult

ExtVoice_Alloc_StreamSlot_FallbackFA:
	ldto_berp A, 0xFA
	extz wa
	calr ExtVoice_Lookup_SlotFallback
	ldfr_berp L, 0xFB
	ldto_berp A, 0xFB
	cp a, 0xC0
	jr nc, ExtVoice_Alloc_StreamSlot_FA_Inactive
	ldto_berp A, 0xFB
	ld l, a
	extz hl
	ld a, (xsp + 8)
	ld c, a
	extz bc
	ld a, (xsp + 2)
	ld e, a
	extz de
	ld wa, hl
	calr VoiceSlot_UpdateNoteSource
	ld a, (xsp + 6)
	ld l, a
	extz hl
	ldto_berp A, 0xFA
	ld c, a
	extz bc
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ld wa, hl
	calr VoiceState_SwapSlot_Guarded
	ldto_berp A, 0xFB
	ld e, a
	extz de
	ldto_berp A, 0xFA
	ld c, a
	extz bc
	ld wa, de
	calr ExtVoice_Fold_SlotNumber
	jr ExtVoice_Alloc_StreamSlot_PackResult

ExtVoice_Alloc_StreamSlot_FA_Inactive:
	ld l, 0xFF:opc

ExtVoice_Alloc_StreamSlot_PackResult:
	ld c, l
	extz bc
	ld a, (xsp + 4)
	extz wa
	sll wa, 8
	ld hl, wa
	or hl, bc

ExtVoice_Alloc_StreamSlot_Return:
	popw_erp 0xFA
	inc 8, xsp
	ret

; Builds the packed 16-bit "part handle" the voice allocator passes around, and refreshes
; the slot table first when the part index is a real one.
; Inputs: C = part index (only the low 6 bits are used, saved in a 2-byte stack slot),
;         A = a selector. If A >= 0x40 the refresh is skipped; otherwise
;         Voice_ScanSlots_ReassignSources (0x02150D) is called with WA = A.
; Output: HL = ((C & 0x3F) << 8) | 0x00FF, i.e. part in the high byte and 0xFF ("no slot
;         yet") in the low byte.  Only caller: 0x0219BB.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from VoiceState_OpaqueData1.
Voice_MakePartHandle:
	dec	2, xsp
	ld	(xsp), c
	andmi8	(xsp), 63
	cp	a, 64
	jr	c, Voice_MakePartHandle_NoRefresh
	ld	a, (xsp)
	extz	wa
	sll	wa, 8
	ld	hl, wa
	or	hl, 255
	jr	Voice_MakePartHandle_Epilogue
Voice_MakePartHandle_NoRefresh:
	extz	wa
	calr	Voice_ScanSlots_ReassignSources
	ld	a, (xsp)
	extz	wa
	sll	wa, 8
	ld	hl, wa
	or	hl, 255
Voice_MakePartHandle_Epilogue:
	inc	2, xsp
	ret
; Stack-argument front end that turns a (part, selector, key) triple into an assigned voice
; slot: saves C and A in a local frame, calls VOICE_PART_HANDLE_MAKE (0x02197C) with
; C = E, then calls ExtVoice_Alloc_StreamSlot (0x02177E) with WA = the saved A, C = the saved C and
; E = the caller's argument at (XSP+8). Returns with 'retd 2', i.e. it pops one word of
; caller-pushed argument. No caller found by branch-target scan (candidate for a call
; through one of the dispatch tables).
Voice_Part_Assign:
	dec	4, xsp
	ld	(xsp), c
	ld	(xsp+2), a
	ld	a, (xsp)
	extz	wa
	ld	c, e
	extz	bc
	calr	Voice_MakePartHandle
	ld	a, (xsp+2)
	ld	l, a
	extz	hl
	ld	a, (xsp)
	ld	c, a
	extz	bc
	ld	a, (xsp+8)
	ld	e, a
	extz	de
	ld	wa, hl
	calr	ExtVoice_Alloc_StreamSlot
	inc	4, xsp
	retd	2
; Builds a 0xFFFF-terminated word list at 0x00286B describing the up-to-four sounding
; sub-slots of one tone entry.
; Inputs: A = tone/part row index, C = a group id, E = a group mask (the routine keeps
;         ~E in its frame and matches (table_byte & ~E) against (C & ~E)).
; Walks i = 0..3 over the bytes at (0x0024E6 + 12*A + 8 + i). A byte >= 0xC0 means "slot
; unused" and is skipped. Otherwise the byte indexes a 5-byte-stride table at 0x002129,
; whose first byte indexes VOICE_COMMANDINDEXTABLE (0x00F4EC); that result is the value
; matched against the group and is also the high byte of the emitted word. The low byte is
; whatever ExtVoice_Fold_SlotNumber (0x0210A2) returns for (WA = the raw byte, BC = i).
; Output: XHL = 0x00286B (the list). No caller found by branch-target scan.
; CODE, converted from a 178-byte .byte run on 2026-09-25 (convert_v142_byte_block.py): llvm-mc
; and unidasm agree on all 63 instruction boundaries, every instruction re-assembles to its own
; bytes, and it is instruction-for-instruction the 4-entry twin of Voice_BuildOutputList below
; (same frame, same ERP counter, same `calr ExtVoice_Fold_SlotNumber`).
Voice_Build_PartSlot_List:
	lda	xsp, (xsp-12)
	push	qiz
	cpl	e
	ld	(xsp+8), e
	and	c, (xsp+8)
	ld	(xsp+6), c
	extz	wa
	muls	wa, 12
	lda	xbc, (0x24e6:16)
	exts	xwa
	add	xwa, xbc
	ld	(xsp+2), xwa
	lda	xwa, (0x286b:16)
	ld	(xsp+10), xwa
	ldib_erp	251, 0
	cpib_erp	251, 4
	jr	nc, Voice_Build_PartSlot_List_Done
Voice_Build_PartSlot_List_Loop:
	ldto_berp	a, 251
	extz	wa
	ld	bc, wa
	inc	8, bc
	ld	xwa, (xsp+2)
	ld	e, (xwa+bc)
	ld	a, e
	cp	a, 192
	jr	nc, Voice_Build_PartSlot_List_Next
	ld	a, e
	extz	wa
	muls	wa, 5
	lda	xbc, (0x2129:16)
	ld	a, (xbc+wa)
	extz	wa
	lda	xbc, (Voice_CommandIndexTable:24)
	ld	a, (xbc+wa)
	ldfr_berp	a, 250
	and	a, (xsp+8)
	cp	a, (xsp+6)
	jr	nz, Voice_Build_PartSlot_List_Next
	extz	de
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	wa, de
	calr	ExtVoice_Fold_SlotNumber
	ld	c, l
	extz	bc
	ldto_berp	a, 250
	extz	wa
	sll	wa, 8
	ld	de, wa
	or	de, bc
	ld	xwa, (xsp+10)
	ld	(xwa+), de
	ld	(xsp+10), xwa
Voice_Build_PartSlot_List_Next:
	inc1b_erp	251
	cpib_erp	251, 4
	jr	c, Voice_Build_PartSlot_List_Loop
Voice_Build_PartSlot_List_Done:
	ld	xwa, (xsp+10)
	ldw	(xwa), 0xffff
	lda	xhl, (0x286b:16)
	pop	qiz
	lda	xsp, (xsp+12)
	ret

Voice_BuildOutputList:
	lda xsp, (xsp - 12)
	pushw_erp 0xFA
	cpl e
	ld (xsp + 8), e
	and c, (xsp + 8)
	ld (xsp + 6), c
	extz wa
	muls wa, 0x1B
	lda xbc, (7757:16)
	exts xwa
	add xwa, xbc
	ld (xsp + 2), xwa
	lda xwa, (10217:16)
	ld (xsp + 10), xwa
	ldib_erp 0xFA, 0
	cp_erpb 0xFA, 0x1B
	jr nc, Voice_BuildOutputList_Return

Voice_BuildOutputList_Loop:
	ldto_berp A, 0xFA
	ld c, a
	extz bc
	ld xwa, (xsp + 2)
	ld	e, (xwa+bc)
	ld a, e
	cp a, 0xC0
	jr nc, Voice_BuildOutputList_Next
	ldto_berp A, 0xFA
	extz wa
	lda xbc, (Voice_CommandIndexTable:24)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xFB
	and a, (xsp + 8)
	cp a, (xsp + 6)
	jr nz, Voice_BuildOutputList_Next
	ldto_berp A, 0xFB
	and a, 0x1F
	extz wa
	lda xbc, (Voice_PolyphonyLimits_Table:24)
	ld	c, (xbc+wa)
	ld a, e
	extz wa
	extz bc
	calr ExtVoice_Fold_SlotNumber
	ld c, l
	extz bc
	ldto_berp A, 0xFB
	extz wa
	sll wa, 8
	ld de, wa
	or de, bc
	ld xwa, (xsp + 10)
	ld (xwa+), DE
	ld (xsp + 10), xwa

Voice_BuildOutputList_Next:
	inc1b_erp 0xFA
	cp_erpb 0xFA, 0x1B
	jr c, Voice_BuildOutputList_Loop

Voice_BuildOutputList_Return:
	ld xwa, (xsp + 10)
	ldw (xwa), 0xFFFF
	lda xhl, (10217:16)
	popw_erp 0xFA
	lda xsp, (xsp + 12)
	ret

; Builds a 0xFF-terminated byte list at 0x0028ED of the voice ids currently sounding for a
; part group. Inputs: A = row selector (row base = 0x001E4D + 27*A), C = group id,
; E = group mask (E is complemented and ANDed into C on entry, so the test is on the bits
; NOT in the mask). For each of the 27 part indices B: the row byte is skipped when >= 0xC0;
; VOICE_COMMANDINDEXTABLE[B] (0x00F4EC) must match the group; the row byte then indexes the
; 5-byte-stride table at 0x00212A to give a voice id, which must be < 0x40 to be emitted.
; After emitting, VOICE_POLYPHONYLIMITS_TABLE (0x00F48C) indexed by the command byte & 0x1F
; gives a stride used to chain forward through 0x0024E6 + 12*voice, emitting further ids
; until the chain byte repeats. Output: XHL = 0x0028ED.
; LOW confidence: the chain walk at 0x021BB7..0x021BE2 is understood mechanically but its
; purpose (layer chaining? unison? drum-map expansion?) is not proven. No caller found.
; CODE, converted from a 182-byte .byte run on 2026-09-25 (was `VoiceState_OpaqueData2`):
; llvm-mc and unidasm agree on all 65 instruction boundaries and every instruction
; re-assembles to its own bytes.  Still no caller found (no numeric or symbolic branch targets it).
Voice_Build_SoundingVoiceList:
	pushw	iz
	cpl	e
	and	c, e
	extz	wa
	muls	wa, 27
	lda	xhl, (0x1e4d:16)
	lda	xix, (xhl+wa)
	lda	xhl, (0x28ed:16)
	ld	b, 0:opc
	cp	b, 27
	jrl	nc, Voice_Build_SoundingVoiceList_Done
Voice_Build_SoundingVoiceList_Loop:
	ld	a, b
	extz	wa
	ld	a, (xix+wa)
	ldfr_berp	a, 226
	cp	a, 192
	jr	nc, Voice_Build_SoundingVoiceList_Next
	ld	a, b
	extz	wa
	lda	xiy, (Voice_CommandIndexTable:24)
	ld	d, (xiy+wa)
	ld	a, d
	and	a, e
	cp	a, c
	jr	nz, Voice_Build_SoundingVoiceList_Next
	ldto_berp	a, 226
	extz	wa
	muls	wa, 5
	lda	xiy, (0x212a:16)
	ld	a, (xiy+wa)
	ldfr_berp	a, 230
	cp	a, 64
	jr	nc, Voice_Build_SoundingVoiceList_Next
	ldto_berp	a, 230
	ldfr_berp	a, 226
	ld	a, d
	and	a, 31
	extz	wa
	lda	xiy, (Voice_PolyphonyLimits_Table:24)
	ld	d, (xiy+wa)
Voice_Build_SoundingVoiceList_ChainLoop:
	ldto_berp	a, 230
	ld	(xhl+), a
	ld	a, d
	extz	wa
	ld	iz, wa
	ldto_berp	a, 226
	extz	wa
	muls	wa, 12
	lda	xiy, (0x24e6:16)
	exts	xwa
	add	xwa, xiy
	ld	iy, iz
	extz	xiy
	add	xiy, xwa
	ld	a, (xiy)
	ldfr_berp	a, 226
	cpb_erp	a, 230
	jr	nz, Voice_Build_SoundingVoiceList_ChainLoop
Voice_Build_SoundingVoiceList_Next:
	inc	1, b
	cp	b, 27
	jrl	c, Voice_Build_SoundingVoiceList_Loop
Voice_Build_SoundingVoiceList_Done:
	ld	(xhl), 255
	lda	xhl, (0x28ed:16)
	popw	iz
	ret

Voice_AdvanceSlotIterator:
	dec 2, xsp
	push xiz
	ld c, 0x30:opc
	mul bc, a
	ld iz, bc
	ld (xsp + 4), iz
	addiw_da (xsp + 4), 0x30
	cp iz, (xsp + 4)
	jr nc, Voice_AdvanceSlotIterator_Return

Voice_AdvanceSlotIterator_Loop:
	ld wa, iz
	mul wa, 0x5
	lda xbc, (8490:16)
	extz xwa
	add xwa, xbc
	cp (xwa), 0x40
	jr ule, Voice_AdvanceSlotIterator_Next
	ld wa, iz
	mul wa, 0x5
	lda xbc, (8488:16)
	extz xwa
	add xwa, xbc
	cp (xwa), 0x1A
	jr z, Voice_AdvanceSlotIterator_Next
	ldto_berp A, 0xF8
	extz wa
	ldfr_werp WA, 0xFA
	ldto_berp A, 0xF8
	extz wa
	calr Quad_Decode_A_To_L
	ld c, l
	extz bc
	ldto_werp WA, 0xFA
	ld de, bc
	ldw bc, 0x1A
	calr VoiceSlot_UpdateNoteSource

Voice_AdvanceSlotIterator_Next:
	inc 1, iz
	cp iz, (xsp + 4)
	jr c, Voice_AdvanceSlotIterator_Loop

Voice_AdvanceSlotIterator_Return:
	pop xiz
	inc 2, xsp
	ret

DList_Unlink_SelfLink:
	ld xde, (xwa)
	ld xbc, (xwa + 4)
	ld (xbc), xde
	ld (xde + 4), xbc
	ld (xwa), xwa
	ld (xwa + 4), xwa
	ret

DList_InsertAfter_Offsets0:
	ld xhl, (xwa)
	ld xde, (xwa + 4)
	ld (xde), xhl
	ld (xhl + 4), xde
	ld xde, (xbc + 4)
	ld (xde), xwa
	ld (xbc + 4), xwa
	ld (xwa), xbc
	ld (xwa + 4), xde
	ret

Voice_List_MoveToPool:
	dec 6, xsp
	push xiz
	ld (xsp + 4), e
	ld (xsp + 6), xbc
	ld xiz, xwa
	ld xde, (xiz + 29)
	ld c, (xiz + 33)
	ld a, c
	extz wa
	sla wa, 2
	inc 2, wa
	cp	(xde+wa), xiz
	jr nz, VoiceNode_PriorityList_InsertOrLink
	cp (xiz), xiz
	jr z, VoiceNode_PriorityList_SelfLink
	ld a, c
	extz wa
	sla wa, 2
	ld bc, wa
	inc 2, bc
	ld xwa, (xiz)
	ld	(xde+bc), xwa
	jr VoiceNode_PriorityList_InsertOrLink

VoiceNode_PriorityList_SelfLink:
	ld a, c
	extz wa
	sla wa, 2
	ld bc, wa
	inc 2, bc
	ld xwa, 0:i3
	ld	(xde+bc), xwa

VoiceNode_PriorityList_InsertOrLink:
	ld a, (xsp + 4)
	extz wa
	sla wa, 2
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 6)
	ld	xwa, (xwa+bc)
	or xwa, xwa
	jr nz, VoiceNode_PriorityList_Insert
	ld a, (xsp + 4)
	extz wa
	sla wa, 2
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 6)
	ld	(xwa+bc), xiz
	ld xwa, xiz
	calr DList_Unlink_SelfLink
	jr VoiceNode_PriorityList_Return

VoiceNode_PriorityList_Insert:
	ld a, (xsp + 4)
	extz wa
	sla wa, 2
	ld de, wa
	inc 2, de
	ld xwa, xiz
	ld xbc, (xsp + 6)
	ld	xbc, (xbc+de)
	calr DList_InsertAfter_Offsets0

VoiceNode_PriorityList_Return:
	ld xwa, (xsp + 6)
	ld (xiz + 29), xwa
	ld a, (xsp + 4)
	ld (xiz + 33), a
	pop xiz
	inc 6, xsp
	ret

DList_Unlink_SelfLink_Offsets8:
	ld xde, (xwa + 8)
	ld xbc, (xwa + 12)
	ld (xbc + 8), xde
	ld (xde + 12), xbc
	ld (xwa + 8), xwa
	ld (xwa + 12), xwa
	ret

DList_InsertAfter_Offsets8:
	ld xhl, (xwa + 8)
	ld xde, (xwa + 12)
	ld (xde + 8), xhl
	ld (xhl + 12), xde
	ld xde, (xbc + 12)
	ld (xde + 8), xwa
	ld (xbc + 12), xwa
	ld (xwa + 8), xbc
	ld (xwa + 12), xde
	ret

Voice_List_MoveToPartList:
	dec 6, xsp
	push xiz
	ld (xsp + 4), e
	ld (xsp + 6), xbc
	ld xiz, xwa
	ld xde, (xiz + 24)
	ld c, (xiz + 28)
	ld a, c
	extz wa
	sla wa, 2
	inc 4, wa
	cp	(xde+wa), xiz
	jr nz, VoiceNode_SecondList_InsertOrLink
	cp (xiz + 8), xiz
	jr z, VoiceNode_SecondList_SelfLink
	ld a, c
	extz wa
	sla wa, 2
	ld bc, wa
	inc 4, bc
	ld xwa, (xiz + 8)
	ld	(xde+bc), xwa
	jr VoiceNode_SecondList_InsertOrLink

VoiceNode_SecondList_SelfLink:
	ld a, c
	extz wa
	sla wa, 2
	ld bc, wa
	inc 4, bc
	ld xwa, 0:i3
	ld	(xde+bc), xwa

VoiceNode_SecondList_InsertOrLink:
	ld a, (xsp + 4)
	extz wa
	sla wa, 2
	ld bc, wa
	inc 4, bc
	ld xwa, (xsp + 6)
	ld	xwa, (xwa+bc)
	or xwa, xwa
	jr nz, VoiceNode_SecondList_Insert
	ld a, (xsp + 4)
	extz wa
	sla wa, 2
	ld bc, wa
	inc 4, bc
	ld xwa, (xsp + 6)
	ld	(xwa+bc), xiz
	ld xwa, xiz
	calr DList_Unlink_SelfLink_Offsets8
	jr VoiceNode_SecondList_Return

VoiceNode_SecondList_Insert:
	ld a, (xsp + 4)
	extz wa
	sla wa, 2
	ld de, wa
	inc 4, de
	ld xwa, xiz
	ld xbc, (xsp + 6)
	ld	xbc, (xbc+de)
	calr DList_InsertAfter_Offsets8

VoiceNode_SecondList_Return:
	ld xwa, (xsp + 6)
	ld (xiz + 24), xwa
	ld a, (xsp + 4)
	ld (xiz + 28), a
	pop xiz
	inc 6, xsp
	ret

DList_Unlink_SelfLink_Offsets16:
	ld xde, (xwa + 16)
	ld xbc, (xwa + 20)
	ld (xbc + 16), xde
	ld (xde + 20), xbc
	ld (xwa + 16), xwa
	ld (xwa + 20), xwa
	ret

DList_Relink_Adjacent_Offsets16:
	ld xhl, (xwa + 16)
	ld xde, (xwa + 20)
	ld (xde + 16), xhl
	ld (xhl + 20), xde
	ld xde, (xbc + 20)
	ld (xde + 16), xwa
	ld (xbc + 20), xwa
	ld (xwa + 16), xbc
	ld (xwa + 20), xde
	ret

Voice_Retire_ToFreePool:
	push xiz
	ld xiz, xwa
	bitm 0, (xiz + 34)
	jr nz, Voice_Retire_ToFreePool_Return
	ld xwa, (xiz + 29)
	cp (xwa + 1), 0x0
	jr z, Voice_Retire_ToFreePool_InsertLists
	ld xwa, (xiz + 29)
	decm8 1, (xwa + 1)

Voice_Retire_ToFreePool_InsertLists:
	lda xwa, (4907:16)
	ld xbc, xwa
	ld xwa, xiz
	ld de, 6:i3
	calr Voice_List_MoveToPool
	lda xwa, (5249:16)
	ld xbc, xwa
	ld xwa, xiz
	ld de, 1:i3
	calr Voice_List_MoveToPartList
	ld xwa, xiz
	calr DList_Unlink_SelfLink_Offsets16
	ld (xiz + 34), 0x1
	ld (xiz + 37), 0x0
	ld xwa, (xiz + 29)
	ld xbc, xwa
	ld a, (xwa + 1)
	cp a, (xbc)
	jr nc, Voice_Retire_ToFreePool_Return
	ld xwa, (xiz + 29)
	incm8 1, (xwa + 1)

Voice_Retire_ToFreePool_Return:
	pop xiz
	ret

Voice_Demote_Decayed:
	ld c, (xwa + 34)
	and c, 0x3
	ret nz
	andmi8 (xwa + 34), 0xF3
	setm 1, (xwa + 34)
	ld xbc, xwa
	ld xde, (xwa + 29)
	ld xwa, xbc
	ld xbc, xde
	ld de, 6:i3
	calr Voice_List_MoveToPool
	ret

Voice_Reprioritise:
	bitm 7, (xwa + 34)
	ret nz
	cp (xwa + 37), 0x80
	jr c, Voice_Demote_Decayed
	bitm 3, (xwa + 34)
	ret z
	resm 3, (xwa + 34)
	setm 2, (xwa + 34)
	ld c, (xwa + 38)
	ld e, c
	extz de
	ld xbc, xwa
	ld xhl, (xwa + 29)
	ld xwa, xbc
	ld xbc, xhl
	calr Voice_List_MoveToPool
	ret

Voice_Reset_Engine:
	dec 4, xsp
	push xiz
	ld (xsp + 6), a
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x4
	jr nc, Voice_Reset_Engine_PhaseA

Voice_Reset_Engine_FindStart:
	ld a, (xsp + 4)
	extz wa
	add wa, wa
	lda xbc, (10542:16)
	cpw	(xbc+wa), 0x0000
	jr nz, Voice_Reset_Engine_PhaseA
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x4
	jr c, Voice_Reset_Engine_FindStart

Voice_Reset_Engine_PhaseA:
	cp (xsp + 4), 0x4
	jr nc, Voice_Reset_Engine_PhaseB
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x40
	jr nc, Voice_Reset_Engine_PhaseB

Voice_Reset_Engine_PhaseA_VoiceLoop:
	res	7, (P6:8)
	ld a, (xsp + 4)
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa200
	jr Voice_Reset_Engine_PhaseA_Nop

Voice_Reset_Engine_PhaseA_Nop:
	nop
	nop
	nop
	res	7, (P6:8)
	ld a, (xsp + 4)
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa280
	jr Voice_Reset_Engine_PhaseA_Nop2

Voice_Reset_Engine_PhaseA_Nop2:
	nop
	nop
	nop
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x40
	jr c, Voice_Reset_Engine_PhaseA_VoiceLoop

Voice_Reset_Engine_PhaseB:
	cp (xsp + 4), 0x4
	jr nc, Voice_Reset_Engine_PhaseC
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x40
	jr nc, Voice_Reset_Engine_PhaseC

Voice_Reset_Engine_PhaseB_VoiceLoop:
	res	7, (P6:8)
	ld a, (xsp + 4)
	add a, 0xC0
	extz wa
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x0000
	jr Voice_Reset_Engine_PhaseB_Nop

Voice_Reset_Engine_PhaseB_Nop:
	nop
	nop
	nop
	res	7, (P6:8)
	ld a, (xsp + 4)
	extz wa
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0x7e00
	jr Voice_Reset_Engine_PhaseB_Nop2

Voice_Reset_Engine_PhaseB_Nop2:
	nop
	nop
	nop
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x40
	jr c, Voice_Reset_Engine_PhaseB_VoiceLoop

Voice_Reset_Engine_PhaseC:
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x12
	jrl nc, ChanStruct_Init_Loop

CmdTable_InitEntry_Loop:
	cp (xsp + 6), 0x0
	jr nz, CmdTable_InitEntry_AltPtr
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x1E
	ld de, wa
	lda xhl, (4397:16)
	ld a, (xsp + 4)
	extz wa
	lda xbc, (Voice_Pool_Quota_ModeA:24)
	ld	a, (xbc+wa)
	ld	(xhl+de), a
	jr CmdTable_InitEntry_ZeroFields

CmdTable_InitEntry_AltPtr:
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x1E
	ld de, wa
	lda xhl, (4397:16)
	ld a, (xsp + 4)
	extz wa
	lda xbc, (Voice_Pool_Quota_ModeB:24)
	ld	a, (xbc+wa)
	ld	(xhl+de), a

CmdTable_InitEntry_ZeroFields:
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x1E
	lda xbc, (4398:16)
	ld	(xbc+wa), 0x00
	ld e, 0x0:opc
	cp e, 7:i3
	jr nc, CmdTable_InitEntry_Next

CmdTable_InitEntry_ZeroLoop:
	ld a, e
	extz wa
	sla wa, 2
	ld hl, wa
	inc 2, hl
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x1E
	lda xbc, (4397:16)
	lda	xbc, (xbc+wa)
	ld xwa, 0:i3
	ld	(xbc+hl), xwa
	inc 1, e
	cp e, 7:i3
	jr c, CmdTable_InitEntry_ZeroLoop

CmdTable_InitEntry_Next:
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x12
	jrl c, CmdTable_InitEntry_Loop

ChanStruct_Init_Loop:
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x1B
	jrl nc, VoiceNode_Init_Loop

ChanStruct_Init_BindPartPool:
	cp (xsp + 6), 0x0
	jr nz, ChanStruct_Init_Entry_AltPtr
	ld a, (xsp + 4)
	extz wa
	muls wa, 0xC
	ld de, wa
	lda xhl, (4937:16)
	ld a, (xsp + 4)
	extz wa
	sla wa, 2
	lda xbc, (Voice_Part_PoolPtr_ModeA:24)
	ld	xwa, (xbc+wa)
	ld	(xhl+de), xwa
	jr ChanStruct_Init_ZeroSub

ChanStruct_Init_Entry_AltPtr:
	ld a, (xsp + 4)
	extz wa
	muls wa, 0xC
	ld de, wa
	lda xhl, (4937:16)
	ld a, (xsp + 4)
	extz wa
	sla wa, 2
	lda xbc, (Voice_Part_PoolPtr_ModeB:24)
	ld	xwa, (xbc+wa)
	ld	(xhl+de), xwa

ChanStruct_Init_ZeroSub:
	ld e, 0x0:opc
	cp e, 2:i3
	jr nc, ChanStruct_Init_Next

ChanStruct_Init_ZeroLoop:
	ld a, e
	extz wa
	sla wa, 2
	ld hl, wa
	inc 4, hl
	ld a, (xsp + 4)
	extz wa
	muls wa, 0xC
	lda xbc, (4937:16)
	lda	xbc, (xbc+wa)
	ld xwa, 0:i3
	ld	(xbc+hl), xwa
	inc 1, e
	cp e, 2:i3
	jr c, ChanStruct_Init_ZeroLoop

ChanStruct_Init_Next:
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x1B
	jrl c, ChanStruct_Init_BindPartPool

VoiceNode_Init_Loop:
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x40
	jr nc, Voice_Retire_ToFreePool_All

VoiceNode_Init_NodeLoop:
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x27
	lda xbc, (5261:16)
	lda	xiz, (xbc+wa)
	ld a, (xsp + 4)
	ld (xiz + 36), a
	ld (xiz), xiz
	ld (xiz + 4), xiz
	ld (xiz + 8), xiz
	ld (xiz + 12), xiz
	ld (xiz + 16), xiz
	ld (xiz + 20), xiz
	ld (xiz + 34), 0x0
	lda xwa, (4937:16)
	ld (xiz + 24), xwa
	ld (xiz + 28), 0x1
	lda xwa, (4397:16)
	ld (xiz + 29), xwa
	ld (xiz + 33), 0x6
	ld (xiz + 37), 0x0
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x40
	jr c, VoiceNode_Init_NodeLoop

Voice_Retire_ToFreePool_All:
	lda xiz, (5261:16)
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x40
	jr nc, AudioState_Init_ClearWords_Loop

Voice_Retire_ToFreePool_All_Loop:
	ld xwa, xiz
	calr Voice_Retire_ToFreePool
	lda xiz, (xiz + 39)
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x40
	jr c, Voice_Retire_ToFreePool_All_Loop

AudioState_Init_ClearWords_Loop:
	ld (xsp + 4), 0x0
	cp (xsp + 4), 0x4
	jr nc, AudioState_Init_Return

AudioState_Init_ClearVoiceBitmaps:
	ld a, (xsp + 4)
	extz wa
	add wa, wa
	lda xbc, (10542:16)
	ldw	(xbc+wa), 0x0000
	ld a, (xsp + 4)
	extz wa
	add wa, wa
	lda xbc, (10550:16)
	ldw	(xbc+wa), 0x0000
	incm8 1, (xsp + 4)
	cp (xsp + 4), 0x4
	jr c, AudioState_Init_ClearVoiceBitmaps

AudioState_Init_Return:
	calr VoiceState_FullReset
	pop xiz
	inc 4, xsp
	ret

; PER-TICK TONE-GENERATOR VOICE POLL. Services ONE bank of 16 hardware voices per
; call and is the ONLY place in the firmware where a voice is handed back to the
; software free pool.
; Caller: Audio_Process_Init (0x034CDB) at 0x034CED, on alternate ticks only - that
; routine toggles the byte at 0x041342 with 'xor 0xFF' and only calls us when it is
; non-zero. With the internal bank counter this means each of the 4 banks is polled
; once every 8 ticks.
; State: byte (0x1128) = bank counter, inc'd then masked to 0..3 on entry.
;   word (0x292E + bank*2) = shadow copy of the previous poll's active-voice bitmap.
;   word (0x2936 + bank*2) = software 'held / do not reap' bitmap, set by
;                            Voice_Allocate_Nodes (0x02243D) and cleared by
;                            Voice_Clear_HoldBit (0x0225BB).
; Hardware: calls ToneGen_Read_Register (0x021023), which writes the TG register-address
;   latch at 0x100000 and reads the word back. Latch value
;   0..3 returns the 16-bit active-voice bitmap for that bank; latch 0x180+ch returns
;   that channel's envelope level.
; Edge detection (0x2219F..0x02220A):
;     new  = TG_bitmap | held_bitmap        ; 0x221C5
;     hits = (new ^ prev) & prev            ; 0x221E9 / 0x221F1
;     prev = new                            ; 0x22200
;   so 'hits' are exactly the voices that were marked active last poll and are now
;   reported silent by the TG and are not software-held. Only those get reaped.
; Per-voice loop (see Voice_Manager_PollBank_SlotLoop): voice index = bank*16 + i,
;   voice record = 0x148D + index*0x27 (39-byte records, 64 voices, 0x148D..0x1E4C).
; Exit: calls Voice_AdvanceSlotIterator (0x021BF5) with WA = bank.
; *** BUG-RELEVANT: if the tone generator never clears active bits (e.g. a sine-wave
; diagnostic renderer that has no end-of-sample / no auto-free), 'hits' is
; permanently zero, no voice is ever retired, and the free pool drains to empty. ***
Voice_Manager_PollBank:
	dec 6, xsp
	push xiz
	inc 1, (4392:16)
	and (4392:16), 3
	ld a, (4392:16)
	extz wa
	calr ToneGen_Read_Register
	ld a, (4392:16)
	extz wa
	add wa, wa
	lda xbc, (10550:16)
	ld	de, (xbc+wa)
	or de, hl
	ld a, (4392:16)
	extz wa
	ld hl, wa
	add hl, hl
	lda xix, (10542:16)
	ld a, (4392:16)
	extz wa
	add wa, wa
	lda xbc, (10542:16)
	ld (xsp + 4), de
	ld	wa, (xbc+wa)
	xor (xsp + 4), wa
	ld	wa, (xix+hl)
	and (xsp + 4), wa
	ld a, (4392:16)
	extz wa
	add wa, wa
	lda xbc, (10542:16)
	ld	(xbc+wa), de
	ld a, (4392:16)
	sll a, 4
	ld (xsp + 8), a
	extz wa
	muls wa, 0x27
	lda xbc, (5261:16)
	lda	xiz, (xbc+wa)
	ldw (xsp + 6), 0x1
	cpw (xsp + 6), 0x0
	jr z, Voice_Manager_PollBank_Return

; Loop over the 16 voices of the bank; (XSP+6) is a walking one-hot mask that doubles
; each pass and terminates when it shifts out of the word.
Voice_Manager_PollBank_SlotLoop:
	ld wa, (xsp + 4)
	and wa, (xsp + 6)
	jr z, Voice_Manager_PollBank_DecayCheck
	bitm 0, (xiz + 34)
	jr nz, Voice_Manager_PollBank_DecayCheck
	ld xwa, xiz
	calr Voice_Retire_ToFreePool
	ld a, (xsp + 8)
	extz wa
	call ToneGen_SilenceChannel
	ld a, (xsp + 8)
	extz wa
	calr Voice_ScanSlots_ReassignSources
	jr Voice_Manager_PollBank_Next

; Not a freshly-silent voice: skip entirely if flags (voice+0x22) & 0x81 (bit0 = in the
; free pool, bit7 = held/retrigger). Otherwise read the TG envelope level for this
; channel (latch 0x180+index), keep bits 13..0, >>5, store the low byte in (voice+0x25),
; and if it is < 0x80 and flag bit2 is set call Voice_Demote_Decayed (0x021E83).
Voice_Manager_PollBank_DecayCheck:
	ld a, (xiz + 34)
	and a, 0x81
	jr nz, Voice_Manager_PollBank_Next
	ld a, (xsp + 8)
	extz wa
	add wa, 0x180
	calr ToneGen_Read_Register
	and hl, 0x3FFF
	srl hl, 5
	ld a, l
	ld (xiz + 37), a
	cp (xiz + 37), 0x80
	jr nc, Voice_Manager_PollBank_Next
	bitm 2, (xiz + 34)
	jr z, Voice_Manager_PollBank_Next
	ld xwa, xiz
	calr Voice_Demote_Decayed

; Advance to the next voice: index++, record pointer += 0x27, mask <<= 1.
Voice_Manager_PollBank_Next:
	incm8 1, (xsp + 8)
	lda xiz, (xiz + 39)
	ld wa, (xsp + 6)
	add (xsp + 6), wa
	jr nz, Voice_Manager_PollBank_SlotLoop

; Tail: WA = bank, call Voice_AdvanceSlotIterator (0x021BF5), restore and return.
Voice_Manager_PollBank_Return:
	ld a, (4392:16)
	extz wa
	calr Voice_AdvanceSlotIterator
	pop xiz
	inc 6, xsp
	ret

; FREE-VOICE / CANDIDATE-NODE SEARCH, primary form.
; In:  XWA = pointer to the 12-byte part descriptor (array base 0x1349, stride 0x0C).
;      XBC = pointer to a 0xFF-terminated byte list of pool indices in priority order
;            (the ROM lists live at 0x00F60B / 0x00F61A / 0x00F628).
; Out: XHL = pointer to a voice node, or 0 if every listed pool is empty.
; Fast path: the 32-bit word at 0x1345 is the FREE list, the class-6 head of pool 17
;   (pool record 0x132B = 0x112D + 17*30, filled by Voice_Retire_ToFreePool): a free
;   voice is always taken first.  (This was read as a "forced/override node".)
; Walk: for each byte b of the list - if bit7 is set the pool head is read from the
;   class heads of pool 16 (record 0x130D, heads at 0x130F; the victims that
;   Voice_Allocate_Nodes_StealAtQuota parks there) indexed by (b & 0x7F)*4, otherwise from the array
;   embedded in the part descriptor at (*XWA)+2 indexed by b*4. First non-null wins.
; Called only from Voice_Allocate_Nodes (0x0223CF).
; *** BUG-RELEVANT: this returning 0 is how 'stops allocating voices' manifests; it is
; silent - the caller just writes 0xFF into the slot and no error is reported. ***
Voice_Find_Candidate:
	ld xde, (4933:16)
	or xde, xde
	jr z, Voice_Find_Candidate_Walk
	ld xhl, (4933:16)
	ret

; Set up the walk: XDE = 0x112D+0x1E2 = 0x130F (global pool-head array), XHL = local array at (*XWA)+2, bail out immediately if the list is empty (first byte 0xFF).
Voice_Find_Candidate_Walk:
	lda xde, (4397:16)
	lda xde, (xde+482)
	ld xwa, (xwa)
	lda xhl, (xwa + 2)
	cp (xbc), 0xFF
	jr z, NoteChain_FindNode_NotFound

; List entry with bit7 set: look the pool head up in the GLOBAL array at 0x130F.
Voice_Find_Candidate_Secondary:
	bitm 7, (xbc)
	jr z, Voice_Find_Candidate_Primary
	ld a, (xbc)
	res 7, a
	ldfr_berp A, 0xF0
	extz wa
	sla wa, 2
	ld	xwa, (xde+wa)
	or xwa, xwa
	jr z, Voice_Find_Candidate_Advance
	ldto_berp A, 0xF0
	extz wa
	sla wa, 2
	ld	xhl, (xde+wa)
	ret

; List entry with bit7 clear: look the pool head up in the part-descriptor-local array.
Voice_Find_Candidate_Primary:
	ld a, (xbc)
	extz wa
	sla wa, 2
	ld	xwa, (xhl+wa)
	or xwa, xwa
	jr z, Voice_Find_Candidate_Advance
	ld a, (xbc)
	extz wa
	sla wa, 2
	ld	xhl, (xhl+wa)
	ret

; Pool was empty - advance to the next byte of the priority list, stop on 0xFF.
Voice_Find_Candidate_Advance:
	inc 1, xbc
	cp (xbc), 0xFF
	jr nz, Voice_Find_Candidate_Secondary

; Shared not-found exit: XHL = 0.
NoteChain_FindNode_NotFound:
	ld xhl, 0:i3
	ret

; FREE-VOICE / CANDIDATE-NODE SEARCH, secondary form (voice stealing).
; In:  XWA = a 30-byte pool record (node+0x1D: +0 quota, +1 count, +2 seven class heads).
; Out: XHL = first non-empty class head, or 0.
; Uses the fixed ROM order Voice_StealPoolOrder (classes 6 5 2 4 3 1 0: decayed, released,
; then sounding) and, unlike Voice_Find_Candidate, neither pool 16 nor the free list.
; Called from Voice_Allocate_Nodes_StealAtQuota (0x0224DF) when the part is already at its
; polyphony limit, i.e. this is the steal-a-voice search.
Voice_FindStealCandidate:
	inc 2, xwa
	ld xde, xwa
	lda xwa, (Voice_StealPoolOrder:24)
	ld xbc, xwa
	cp (xbc), 0xFF
	jr z, Voice_FindStealCandidate_NotFound

; Walk the 0x00F603 list, returning the first non-null local pool head.
Voice_FindStealCandidate_Walk:
	ld a, (xbc)
	extz wa
	sla wa, 2
	ld	xwa, (xde+wa)
	or xwa, xwa
	jr z, Voice_FindStealCandidate_Advance
	ld a, (xbc)
	extz wa
	sla wa, 2
	ld	xhl, (xde+wa)
	ret

; Advance to the next list byte, stop on the 0xFF terminator.
Voice_FindStealCandidate_Advance:
	inc 1, xbc
	cp (xbc), 0xFF
	jr nz, Voice_FindStealCandidate_Walk

; Not-found exit: XHL = 0.
Voice_FindStealCandidate_NotFound:
	ld xhl, 0:i3
	ret

; NOTE-ON: ALLOCATE UP TO FOUR VOICE NODES FOR ONE NOTE EVENT.
; In: XWA = note-event record (kept in local (XSP+0x10)):
;       +0x00 word  bits 0..6  = MIDI note number
;                   bits 8..12 = part index, must be < 0x1A
;       +0x02..+0x05  one byte per layer slot: bit7 = slot enabled,
;                     bits 0..3 = index into the 6-byte ROM table at 0x00F633
;       +0x06 bit6  = 'continue chain' - if clear, the global chain head (0x1129) is
;                     reset to 0 first
;       +0x06..+0x09  per-slot bit7 = hold / retrigger flag
;       +0x0A..+0x0D  OUTPUT: allocated hardware voice index per slot, 0xFF = none
; Callers: 0x02BB66, 0x02C033, 0x02C349, 0x02C665, 0x02D034.
; Calls RingBuf_CheckOffset_ClearFlags (0x02103B) first, which clears the enable bit of
; slots 1..3 according to the polyphony/mode values at 0x27E6/0x27E7 - i.e. that is the
; layer limiter.
; Part descriptor = 0x1349 + part*0x0C. Each 0x00F633 entry is {u32 candidate-list ptr,
; u8 priority key, u8 node param}.
; *** BUG-RELEVANT: (voice+0x25) is forced to 0xFF here (0x0223FC) and the flag byte
; (voice+0x22) is set to 0x88 (held) or 0x08 (non-held) - bit2 is NOT set in either
; case. Voice_Manager_PollBank's envelope-based release path requires level < 0x80 AND
; bit2, and its 'and A,0x81' guard also skips anything with bit7 set. So a voice that
; the TG never reports silent has NO second escape route out of the pool. ***
Voice_Allocate_Nodes:
	lda xsp, (xsp - 16)
	push xiz
	ld (xsp + 16), xwa
	ld xwa, (xsp + 16)
	bitm 6, (xwa + 6)
	jr nz, Voice_Allocate_Nodes_SlotLoop
	ld xwa, 0:i3
	ld (4393:16), xwa

; Extract the part index (event word bits 8..12); >= 0x1A jumps to the all-slots-fail exit. Then run the layer limiter and compute the part descriptor pointer.
Voice_Allocate_Nodes_SlotLoop:
	ld xwa, (xsp + 16)
	ld wa, (xwa)
	and wa, 0x1F00
	srl wa, 8
	ldfr_berp A, 0xFB
	cp_erpb 0xFB, 0x1A
	jrl nc, Voice_Allocate_Nodes_AllInactive
	ld xwa, (xsp + 16)
	calr RingBuf_CheckOffset_ClearFlags
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0xC
	lda xbc, (4937:16)
	exts xwa
	add xwa, xbc
	ld (xsp + 4), xwa
	ld (xsp + 12), 0x0
	cp (xsp + 12), 0x4
	jrl nc, Voice_Allocate_Nodes_Return

; Per-slot body (slot = 0..3): if the slot's enable bit7 is clear go mark it 0xFF; else fetch its 6-byte 0x00F633 entry and ask Voice_Find_Candidate for a node.
Voice_Allocate_Nodes_ProcessSlot:
	ld a, (xsp + 12)
	extz wa
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 16)
	bit	7, (xwa+bc)
	jrl z, Voice_Allocate_Nodes_SlotInactive
	ld a, (xsp + 12)
	extz wa
	ld bc, wa
	inc 2, bc
	ld xwa, (xsp + 16)
	ld	a, (xwa+bc)
	and a, 0xF
	extz wa
	muls wa, 0x6
	lda xbc, (Voice_LayerClassTable:24)
	exts xwa
	add xwa, xbc
	ld (xsp + 8), xwa
	ld xbc, (xwa)
	ld xwa, (xsp + 4)
	calr Voice_Find_Candidate
	ld xiz, xhl
	ld xwa, xiz
	or xwa, xwa
	jrl z, Voice_Allocate_Nodes_SlotNoNode
	ld a, (xiz + 36)
	ld (xsp + 14), a
	ld xwa, (xiz + 29)
	cp (xwa + 1), 0x0
	jr z, Voice_Allocate_Nodes_ActivateNode
	ld xwa, (xiz + 29)
	decm8 1, (xwa + 1)

; Node obtained: (node+0x23) = note number, (node+0x25) = 0xFF (envelope max), (node+0x26) = entry byte +5; then branch on the slot's hold flag at event+6+slot.
Voice_Allocate_Nodes_ActivateNode:
	ld xwa, (xsp + 16)
	ld wa, (xwa)
	and wa, 0x7F
	ld (xiz + 35), a
	ld (xiz + 37), 0xFF
	ld xwa, (xsp + 8)
	ld a, (xwa + 5)
	ld (xiz + 38), a
	ld a, (xsp + 12)
	extz wa
	ld bc, wa
	inc 6, bc
	ld xwa, (xsp + 16)
	bit	7, (xwa+bc)
	jr z, Voice_Allocate_Nodes_Retrigger
	ld (xiz + 34), 0x88
	ld a, (xsp + 14)
	and a, 0xF
	ld de, 1:i3
	and a, 0xF
	jr z, Voice_Allocate_Nodes_RetriggerActive
	slla de

; Held/retrigger branch tail: OR this channel's bit into the 'held' bitmap (0x2936 + (chan>>4)*2) so Voice_Manager_PollBank will never reap it.
Voice_Allocate_Nodes_RetriggerActive:
	ld a, (xsp + 14)
	srl a, 4
	extz wa
	add wa, wa
	lda xbc, (10550:16)
	or	(xbc+wa), de
	jr Voice_Allocate_Nodes_UpdateLists

; Non-held branch: flags = 0x08, then clear this channel's bit in the held bitmap 0x2936 ...
Voice_Allocate_Nodes_Retrigger:
	ld (xiz + 34), 0x8
	ld a, (xsp + 14)
	and a, 0xF
	ld bc, 1:i3
	and a, 0xF
	jr z, Voice_Allocate_Nodes_RetriggerMask
	slla bc

; ... using the complement mask, and ...
Voice_Allocate_Nodes_RetriggerMask:
	ld wa, bc
	cpl wa
	ld de, wa
	ld a, (xsp + 14)
	srl a, 4
	extz wa
	add wa, wa
	lda xbc, (10550:16)
	and	(xbc+wa), de
	ld a, (xsp + 14)
	and a, 0xF
	ld de, 1:i3
	and a, 0xF
	jr z, Voice_Allocate_Nodes_RetriggerOrMask
	slla de

; ... SET the bit in the shadow bitmap 0x292E so that the next poll sees a 1->0 transition once the TG finishes the note. This is what arms the reaper.
Voice_Allocate_Nodes_RetriggerOrMask:
	ld a, (xsp + 14)
	srl a, 4
	extz wa
	add wa, wa
	lda xbc, (10542:16)
	or	(xbc+wa), de

; Link the node into the part's priority list (Voice_List_MoveToPool, key = entry byte +4) and its secondary list, then splice it into the global note chain rooted at (0x1129).
Voice_Allocate_Nodes_UpdateLists:
	ld xwa, (xsp + 8)
	ld e, (xwa + 4)
	ld xwa, xiz
	ld xbc, (xsp + 4)
	ld xbc, (xbc)
	calr Voice_List_MoveToPool
	ld xwa, xiz
	ld xbc, (xsp + 4)
	ld de, 0:i3
	calr Voice_List_MoveToPartList
	ld xwa, (4393:16)
	or xwa, xwa
	jr z, Voice_Allocate_Nodes_SetGlobalHead
	ld xwa, xiz
	ld xbc, (4393:16)
	calr DList_Relink_Adjacent_Offsets16
	jr Voice_Allocate_Nodes_CountAgainstQuota

; Global chain was empty: this node becomes the head (0x1129) and self-links.
Voice_Allocate_Nodes_SetGlobalHead:
	ld (4393:16), xiz
	ld xwa, xiz
	calr DList_Unlink_SelfLink_Offsets16

; Polyphony accounting: the pool record (node+0x1D) holds the quota at +0 and the count at +1; below the quota just count the node.
Voice_Allocate_Nodes_CountAgainstQuota:
	ld xwa, (xiz + 29)
	ld xbc, xwa
	ld a, (xwa + 1)
	cp a, (xbc)
	jr nc, Voice_Allocate_Nodes_StealAtQuota
	ld xwa, (xiz + 29)
	incm8 1, (xwa + 1)
	jr Voice_Allocate_Nodes_WriteSlot

; At the quota - steal: Voice_FindStealCandidate picks a victim in the same pool, it moves to pool 16 (record 0x130D) under its own class (node+0x21), the count is bumped and flag bit4 is set on it.
Voice_Allocate_Nodes_StealAtQuota:
	ld xwa, (xiz + 29)
	calr Voice_FindStealCandidate
	ld xiz, xhl
	ld xwa, xiz
	or xwa, xwa
	jr z, Voice_Allocate_Nodes_WriteSlot
	lda xwa, (4877:16)
	ld xbc, xwa
	ld a, (xiz + 33)
	ld e, a
	extz de
	ld xwa, xiz
	calr Voice_List_MoveToPool
	ld xwa, (xiz + 29)
	incm8 1, (xwa + 1)
	setm 4, (xiz + 34)

; Publish the result: Voice_ScanSlots_ReassignSources (0x02150D) for the channel, then event[0x0A+slot] = channel index.
Voice_Allocate_Nodes_WriteSlot:
	ld a, (xsp + 14)
	extz wa
	calr Voice_ScanSlots_ReassignSources
	ld a, (xsp + 12)
	extz wa
	ld de, wa
	add de, 0xA
	ld xwa, (xsp + 16)
	ld c, (xsp + 14)
	ld	(xwa+de), c
	jr Voice_Allocate_Nodes_SlotNext

; No node was available for this slot: event[0x0A+slot] = 0xFF.
Voice_Allocate_Nodes_SlotNoNode:
	ld a, (xsp + 12)
	extz wa
	ld bc, wa
	add bc, 0xA
	ld xwa, (xsp + 16)
	ld	(xwa+bc), 0xff
	jr Voice_Allocate_Nodes_SlotNext

; Slot was disabled: event[0x0A+slot] = 0xFF.
Voice_Allocate_Nodes_SlotInactive:
	ld a, (xsp + 12)
	extz wa
	ld bc, wa
	add bc, 0xA
	ld xwa, (xsp + 16)
	ld	(xwa+bc), 0xff

; Next slot; four slots per event.
Voice_Allocate_Nodes_SlotNext:
	incm8 1, (xsp + 12)
	cp (xsp + 12), 0x4
	jrl c, Voice_Allocate_Nodes_ProcessSlot
	jr Voice_Allocate_Nodes_Return

; Part index out of range (>= 0x1A): reject the whole event.
Voice_Allocate_Nodes_AllInactive:
	ld (xsp + 12), 0x0
	cp (xsp + 12), 0x4
	jr nc, Voice_Allocate_Nodes_Return

; Fill all four output bytes with 0xFF.
Voice_Allocate_Nodes_AllInactive_Loop:
	ld a, (xsp + 12)
	extz wa
	ld bc, wa
	add bc, 0xA
	ld xwa, (xsp + 16)
	ld	(xwa+bc), 0xff
	incm8 1, (xsp + 12)
	cp (xsp + 12), 0x4
	jr c, Voice_Allocate_Nodes_AllInactive_Loop

; Frame teardown and return.
Voice_Allocate_Nodes_Return:
	pop xiz
	lda xsp, (xsp + 16)
	ret

; RELEASE ONE HARDWARE VOICE (clear its 'held' state).
; In: A = hardware voice index 0..63.
; Clears bit7 of the byte at 0x14AF + index*0x27 (i.e. (voice_record+0x22) - the record
; base is 0x148D and 0x14AF = 0x148D+0x22), clears the channel's bit in the held bitmap
; at 0x2936 + (index>>4)*2, then TAIL-JUMPS into Voice_Reprioritise (0x021EA1)
; with XWA = the voice record.
; 12 call sites, all outside the region (0x026E94, 0x026FC6, 0x0270D1, 0x027AA2,
; 0x027B5D, 0x027B7E, 0x027C08, 0x027C29, 0x028EBB, 0x028F1C, 0x02CDCF, 0x02CE29).
; *** BUG-RELEVANT: this is the ONLY writer that clears a bit of the 0x2936 held
; bitmap. If the note-off path that calls it is bypassed, held voices are pinned
; active forever from Voice_Manager_PollBank's point of view. ***
Voice_Clear_HoldBit:
	ld c, a
	ld a, c
	extz wa
	muls wa, 0x27
	lda xde, (5295:16)
	res	7, (xde+wa)
	ld a, c
	and a, 0xF
	ld de, 1:i3
	and a, 0xF
	jr z, Voice_Clear_HoldBit_ApplyMask
	slla de

; Build the complement of the channel's one-hot bit and AND it into the held bitmap word.
Voice_Clear_HoldBit_ApplyMask:
	ld wa, de
	cpl wa
	ld hl, wa
	ld a, c
	srl a, 4
	extz wa
	add wa, wa
	lda xde, (10550:16)
	and	(xde+wa), hl
	ld a, c
	extz wa
	muls wa, 0x27
	lda xbc, (5261:16)
	exts xwa
	add xwa, xbc
	jrl Voice_Reprioritise

; NOTE-OFF FOR ONE VOICE SLOT.
; In: A = hardware voice index; indices >= 0x40 are ignored.
; Voice record = 0x148D + index*0x27. Moves the node onto the list whose head is at
; (node+0x18) via Voice_List_MoveToPartList (DE=1), runs Voice_Reprioritise
; (0x021EA1) to start the release, and unlinks it from the 0x10/0x14 doubly-linked
; chain unless it is already self-linked.
; Single caller: 0x02C8D7.
VoiceSlot_NoteOff:
	push xiz
	cp a, 0x40
	jr nc, VoiceSlot_NoteOff_Return
	extz wa
	muls wa, 0x27
	lda xbc, (5261:16)
	lda	xiz, (xbc+wa)
	ld xwa, xiz
	ld xbc, (xiz + 24)
	ld de, 1:i3
	calr Voice_List_MoveToPartList
	ld xwa, xiz
	calr Voice_Reprioritise
	cp xiz, (xiz + 16)
	jr z, VoiceSlot_NoteOff_Return
	ld xwa, xiz
	calr DList_Unlink_SelfLink_Offsets16

; Common exit.
VoiceSlot_NoteOff_Return:
	pop xiz
	ret

; ENUMERATE A VOICE CHAIN INTO A BYTE BUFFER (non-destructive).
; In: XWA = pointer to the output cursor (a 32-bit pointer variable, auto-advanced),
;     XBC = chain head (0 = nothing to do), E = note number to match,
;     stacked word arg (XSP+0x04) = 'emit unconditionally' flag.
; Walks the chain through link (node+0x08) until it returns to the head, appending
; (node+0x24) - the hardware voice index - for every node whose (node+0x23) equals E
; (or for all nodes when the flag is non-zero). Terminates the buffer with 0xFF.
; 'retd 2' pops the stacked argument. Called only from NoteOn_RoutePacket.
OutputBuf_Flush_A:
	ld xhl, xbc
	or xhl, xhl
	jr z, OutputBuf_Flush_A_Done
	ld xiy, xhl

; Chain walk: emit unconditionally when the flag is set, otherwise only when (node+0x23) == E.
OutputBuf_Flush_A_Loop:
	cp (xsp + 4), 0x0
	jr nz, OutputBuf_Flush_A_Emit
	cp (xiy + 35), e
	jr nz, OutputBuf_Flush_A_Next

; Append (node+0x24) at the cursor and advance the cursor by one.
OutputBuf_Flush_A_Emit:
	ld xix, (xwa)
	ld c, (xiy + 36)
	ld (xix), c
	ld xbc, 1:i3
	add (xwa), xbc

; Follow (node+0x08); stop when the walk wraps to the head.
OutputBuf_Flush_A_Next:
	ld xiy, (xiy + 8)
	cp xiy, xhl
	jr nz, OutputBuf_Flush_A_Loop

; Write the 0xFF terminator at the cursor and return.
OutputBuf_Flush_A_Done:
	ld xwa, (xwa)
	ld (xwa), 0xFF
	retd 0x2

; ENUMERATE A VOICE CHAIN INTO A BYTE BUFFER *AND RELEASE* EACH MATCH (destructive).
; Same interface as OutputBuf_Flush_A but for every match it first calls
; Voice_List_MoveToPartList (0x021D59, DE=1) and Voice_Reprioritise (0x021EA1)
; to put the voice into release, then appends (node+0x24) and unlinks the node from the
; 0x10/0x14 chain, resuming from the saved successor.
; This is the note-off enumerator; OutputBuf_Flush_A is the query-only one.
OutputBuf_Flush_B:
	dec 8, xsp
	push xiz
	ld (xsp + 8), xwa
	or xbc, xbc
	jr z, OutputBuf_Flush_B_Done
	ld xiz, xbc

; Chain walk with the same match rule as OutputBuf_Flush_A_Loop.
OutputBuf_Flush_B_Loop:
	cp (xsp + 16), 0x0
	jr nz, OutputBuf_Flush_B_Emit
	cp (xiz + 35), e
	jr nz, OutputBuf_Flush_B_Next

; Release the matched node, append its voice index, unlink it and continue from (node+0x10).
OutputBuf_Flush_B_Emit:
	ld xwa, xiz
	ld xbc, (xiz + 24)
	ld de, 1:i3
	calr Voice_List_MoveToPartList
	ld xwa, xiz
	calr Voice_Reprioritise
	ld xwa, (xsp + 8)
	ld xbc, (xwa)
	ld a, (xiz + 36)
	ld (xbc), a
	ld xwa, (xsp + 8)
	ld xbc, 1:i3
	add (xwa), xbc
	cp xiz, (xiz + 16)
	jr z, OutputBuf_Flush_B_Done
	ld xwa, (xiz + 16)
	ld (xsp + 4), xwa
	ld xwa, xiz
	calr DList_Unlink_SelfLink_Offsets16
	ld xiz, (xsp + 4)
	jr OutputBuf_Flush_B_Emit

; Follow (node+0x08); stop when the walk wraps to the head.
OutputBuf_Flush_B_Next:
	ld xiz, (xiz + 8)
	cp xiz, xbc
	jr nz, OutputBuf_Flush_B_Loop

; Write the 0xFF terminator at the cursor and return (retd 2).
OutputBuf_Flush_B_Done:
	ld xwa, (xsp + 8)
	ld xwa, (xwa)
	ld (xwa), 0xFF
	pop xiz
	inc 8, xsp
	retd 0x2

; ROUTE A NOTE-OFF / VOICE-QUERY PACKET AND RETURN THE AFFECTED VOICE LIST.
; In: XWA = packet:  +0x00 flag byte (bit7, bit6 select which chains to visit)
;                    +0x01 word: bits0..6 = note A, bits 8..12 = part index
;                    +0x03 word: bits0..6 = note B, bits 8..12 = broadcast selector
;                    +0x05.. = output buffer, filled with hardware voice indices and
;                              terminated by 0xFF
; If (packet+0x03) bits 8..12 are non-zero the request is a BROADCAST: every one of the
; 64 voice records at 0x148D whose flag bit0 is clear (i.e. not in the free pool) is
; listed. Otherwise the part index selects two descriptor arrays - 0x134D + part*0x0C
; and 0x1351 + part*0x0C - and flag bits 7/6 plus bit7 of each note word choose which
; of the two chains are walked and whether the destructive (Flush_B) or query-only
; (Flush_A) enumerator is used. Part indices >= 0x1A return an empty list.
; Six callers, all in 0x02CCCB..0x02CD69.
NoteOn_RoutePacket:
	lda xsp, (xsp - 16)
	push xiz
	ld bc, (xwa + 3)
	and bc, 0x7F
	ld (xsp + 14), c
	ld bc, (xwa + 1)
	and bc, 0x7F
	ld (xsp + 12), c
	lda xbc, (xwa + 5)
	ld (xsp + 16), xbc
	ld bc, (xwa + 3)
	and bc, 0x1F00
	jr z, NoteOn_RoutePacket_Targeted
	lda xiz, (5261:16)
	ld e, 0x0:opc
	cp e, 0x40
	jr nc, NoteOn_RoutePacket_BroadcastDone

; Broadcast body: list every voice record that is not in the free pool (flag bit0 clear).
NoteOn_RoutePacket_BroadcastLoop:
	bitm 0, (xiz + 34)
	jr nz, NoteOn_RoutePacket_BroadcastNext
	ld xbc, (xsp + 16)
	ld xwa, 1:i3
	add (xsp + 16), xwa
	ld a, (xiz + 36)
	ld (xbc), a

; Next of the 64 records (stride 0x27).
NoteOn_RoutePacket_BroadcastNext:
	lda xiz, (xiz + 39)
	inc 1, e
	cp e, 0x40
	jr c, NoteOn_RoutePacket_BroadcastLoop

; Terminate the broadcast list with 0xFF.
NoteOn_RoutePacket_BroadcastDone:
	ld xwa, (xsp + 16)
	ld (xwa), 0xFF
	jrl NoteOn_RoutePacket_Return

; Targeted request: derive the two per-part descriptor pointers (0x134D / 0x1351 + part*0x0C) and validate part < 0x1A.
NoteOn_RoutePacket_Targeted:
	ld bc, (xwa + 1)
	and bc, 0x1F00
	srl bc, 8
	ld l, c
	extz bc
	muls bc, 0xC
	lda xde, (4941:16)
	exts xbc
	add xbc, xde
	ld (xsp + 4), xbc
	ld c, l
	extz bc
	muls bc, 0xC
	lda xde, (4945:16)
	exts xbc
	add xbc, xde
	ld (xsp + 8), xbc
	cp l, 0x1A
	jrl nc, NoteOn_RoutePacket_InvalidChannel
	bitm 7, (xwa)
	jr z, NoteOn_RoutePacket_Targeted_SecondaryOnly
	ld wa, (xwa + 3)
	and wa, 0x7F
	jr z, NoteOn_RoutePacket_Targeted_NoteZero
	ld xwa, (xsp + 4)
	ld xwa, (xwa)
	or xwa, xwa
	jr z, NoteOn_RoutePacket_Targeted_Done
	ld xwa, (xsp + 4)
	ld xiz, (xwa)

; Destructive drain of the primary chain: repeat OutputBuf_Flush_B until the chain head goes null or stops changing.
NoteOn_RoutePacket_Targeted_Loop:
	ld a, (xsp + 12)
	ld e, a
	extz de
	ld a, (xsp + 14)
	extz wa
	pushw wa
	lda xwa, (xsp + 18)
	ld xbc, (xsp + 6)
	ld xbc, (xbc)
	calr OutputBuf_Flush_B
	ld xwa, (xsp + 4)
	ld xwa, (xwa)
	or xwa, xwa
	jr z, NoteOn_RoutePacket_Targeted_Done
	ld xwa, (xsp + 4)
	cp (xwa), xiz
	jr nz, NoteOn_RoutePacket_Targeted_Loop

; Terminate the output list with 0xFF.
NoteOn_RoutePacket_Targeted_Done:
	ld xwa, (xsp + 16)
	ld (xwa), 0xFF
	jrl NoteOn_RoutePacket_Return

; Note B is zero: single destructive pass matching note A instead.
NoteOn_RoutePacket_Targeted_NoteZero:
	ld a, (xsp + 12)
	ld e, a
	extz de
	ld a, (xsp + 14)
	extz wa
	pushw wa
	lda xwa, (xsp + 18)
	ld xbc, (xsp + 6)
	ld xbc, (xbc)
	calr OutputBuf_Flush_B
	jrl NoteOn_RoutePacket_Return

; Flag bit7 clear: query-only paths; bit6 selects the 0x1351 chain alone.
NoteOn_RoutePacket_Targeted_SecondaryOnly:
	bitm 6, (xwa)
	jr z, NoteOn_RoutePacket_Targeted_BothLists_BitB
	ld a, (xsp + 12)
	ld e, a
	extz de
	ld a, (xsp + 14)
	extz wa
	pushw wa
	lda xwa, (xsp + 18)
	ld xbc, (xsp + 10)
	ld xbc, (xbc)
	calr OutputBuf_Flush_A
	jr NoteOn_RoutePacket_Return

; Flags 7 and 6 both clear, note-B word bit7 set: query BOTH chains (0x134D then 0x1351).
NoteOn_RoutePacket_Targeted_BothLists_BitB:
	ld bc, (xwa + 3)
	bit 7, bc
	jr z, NoteOn_RoutePacket_Targeted_PrimaryOnly_BitA
	ld a, (xsp + 12)
	ld e, a
	extz de
	ld a, (xsp + 14)
	extz wa
	pushw wa
	lda xwa, (xsp + 18)
	ld xbc, (xsp + 6)
	ld xbc, (xbc)
	calr OutputBuf_Flush_A
	ld a, (xsp + 12)
	ld e, a
	extz de
	ld a, (xsp + 14)
	extz wa
	pushw wa
	lda xwa, (xsp + 18)
	ld xbc, (xsp + 10)
	ld xbc, (xbc)
	calr OutputBuf_Flush_A
	jr NoteOn_RoutePacket_Return

; Note-B bit7 clear but note-A bit7 set: query the 0x134D chain only.
NoteOn_RoutePacket_Targeted_PrimaryOnly_BitA:
	ld wa, (xwa + 1)
	bit 7, wa
	jr z, NoteOn_RoutePacket_Targeted_SecondaryOnly_B
	ld a, (xsp + 12)
	ld e, a
	extz de
	ld a, (xsp + 14)
	extz wa
	pushw wa
	lda xwa, (xsp + 18)
	ld xbc, (xsp + 6)
	ld xbc, (xbc)
	calr OutputBuf_Flush_A
	jr NoteOn_RoutePacket_Return

; Neither note word has bit7: query the 0x1351 chain only.
NoteOn_RoutePacket_Targeted_SecondaryOnly_B:
	ld a, (xsp + 12)
	ld e, a
	extz de
	ld a, (xsp + 14)
	extz wa
	pushw wa
	lda xwa, (xsp + 18)
	ld xbc, (xsp + 10)
	ld xbc, (xbc)
	calr OutputBuf_Flush_A
	jr NoteOn_RoutePacket_Return

; Part index >= 0x1A: emit an empty (0xFF-only) list.
NoteOn_RoutePacket_InvalidChannel:
	ld xwa, (xsp + 16)
	ld (xwa), 0xFF

; Frame teardown and return.
NoteOn_RoutePacket_Return:
	pop xiz
	lda xsp, (xsp + 16)
	ret

; QUANTISE A 7-BIT VELOCITY INTO ONE OF FOUR BANDS.
; In: A = velocity (bit7 forced clear), XBC = pointer to three ascending threshold
; bytes. Out: L = 0..3, the first band whose threshold is >= the velocity.
; Single caller 0x02B76D. Byte-for-byte identical to Velocity_Select_Split_Zone_Alt.
Velocity_Select_Split_Zone:
	res 7, a
	cp a, (xbc)
	jr ule, Velocity_Select_Split_Zone_Level0
	cp a, (xbc + 1)
	jr ule, Velocity_Select_Split_Zone_Level1
	cp a, (xbc + 2)
	jr ule, Velocity_Select_Split_Zone_Level2
	ld l, 0x3:opc
	jr Velocity_Select_Split_Zone_Return

; Third band: L = 2.
Velocity_Select_Split_Zone_Level2:
	ld l, 0x2:opc
	jr Velocity_Select_Split_Zone_Return

; Second band: L = 1.
Velocity_Select_Split_Zone_Level1:
	ld l, 0x1:opc
	jr Velocity_Select_Split_Zone_Return

; Lowest band: L = 0.
Velocity_Select_Split_Zone_Level0:
	ld l, 0x0:opc

; Return.
Velocity_Select_Split_Zone_Return:
	ret

; Second, identical copy of Velocity_Select_Split_Zone (same code, same semantics).
; Callers 0x02B617, 0x02C1B2, 0x02C520. The duplication is in the original ROM.
Velocity_Select_Split_Zone_Alt:
	res 7, a
	cp a, (xbc)
	jr ule, Velocity_Select_Split_Zone_Alt_Level0
	cp a, (xbc + 1)
	jr ule, Velocity_Select_Split_Zone_Alt_Level1
	cp a, (xbc + 2)
	jr ule, Velocity_Select_Split_Zone_Alt_Level2
	ld l, 0x3:opc
	jr Velocity_Select_Split_Zone_Alt_Return

; Third band: L = 2.
Velocity_Select_Split_Zone_Alt_Level2:
	ld l, 0x2:opc
	jr Velocity_Select_Split_Zone_Alt_Return

; Second band: L = 1.
Velocity_Select_Split_Zone_Alt_Level1:
	ld l, 0x1:opc
	jr Velocity_Select_Split_Zone_Alt_Return

; Lowest band: L = 0.
Velocity_Select_Split_Zone_Alt_Level0:
	ld l, 0x0:opc

; Return.
Velocity_Select_Split_Zone_Alt_Return:
	ret

; DECODE A 2-BIT FIELD OUT OF THE 0x47-BYTE PER-VOICE PARAMETER RECORD.
; In: A = record index. Reads the first word of the record at 0x04308F + index*0x47,
; masks bits 6..7 and maps 0x00/0x40/0x80/0xC0 to L = 0/1/2/3; leaves L untouched for
; any other value (dead case). No caller found by absolute or relative call scan.
; Held as raw .byte in the LLVM source, so its internal branch targets are unlabelled
; (see the four [LABEL] proposals at 0x022892..0x02289C).
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from VoiceDispatch_OpaqueData.
; Note: its internal targets are now labelled, so the [LABEL] proposals above are applied.
VoiceRec_Decode2BitField:
	extz	wa
	muls	wa, 71
	lda	xbc, (Payload_Bss_Start+0x4219:24)
	ld	wa, (xbc+wa)
	and	wa, 192
	cp	wa, 192
	jr	z, VoiceRec_Decode2BitField_Is3
	cp	wa, 128
	jr	z, VoiceDispatch_Field_Is2
	cp	wa, 64
	jr	z, VoiceDispatch_Field_Is1
	cp	wa, 0:i3
	ret	nz
	ld	l, 0:opc
	jr	VoiceRec_Decode2BitField_Return
; Field value 0x40: L = 1. Inside a raw .byte blob in the LLVM source, hence unlabelled.
VoiceDispatch_Field_Is1:
	ld	l, 1:opc
	jr	VoiceRec_Decode2BitField_Return
; Field value 0x80: L = 2.
VoiceDispatch_Field_Is2:
	ld	l, 2:opc
	jr	VoiceRec_Decode2BitField_Return
; Field value 0xC0: L = 3.
VoiceRec_Decode2BitField_Is3:
	ld	l, 3:opc
; Shared return of the 2-bit field decoder at 0x022864.
VoiceRec_Decode2BitField_Return:
	ret

; COPY THE HIGH NIBBLE OF A PATCH'S BYTE +0x2A INTO THE PER-PART PROGRAM BYTE.
; In: A = part index. Record stride is 0x011F bytes throughout this family:
;   0x04136E + part*0x011F holds a 32-bit pointer to the patch parameter block;
;   (block+0x2A) high nibble is used as an index into the byte table at 0x011ACF;
;   the looked-up byte is stored at 0x0413D5 + part*0x011F.
; Called from Voice_Env_VelocityDispatch_Gate (0x0234CC).
Instrument_LookupProgram_HiNibble:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xde+bc)
	ld c, (xbc + 42)
	and c, 0xF0
	srl c, 4
	extz wa
	muls wa, 0x11F
	ld de, wa
	lda xhl, (Payload_Bss_Start+0x255f:24)
	ld a, c
	extz wa
	lda xbc, (Instrument_OctaveShift_Semitones:24)
	ld	a, (xbc+wa)
	ld	(xhl+de), a
	ret

; As Instrument_LookupProgram_HiNibble but takes the LOW nibble of (block+0x2A).
; Called from Voice_Env_Type2_Gate (0x02357E).
Instrument_LookupProgram_LoNibble:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xde+bc)
	ld c, (xbc + 42)
	and c, 0xF
	extz wa
	muls wa, 0x11F
	ld de, wa
	lda xhl, (Payload_Bss_Start+0x255f:24)
	ld a, c
	extz wa
	lda xbc, (Instrument_OctaveShift_Semitones:24)
	ld	a, (xbc+wa)
	ld	(xhl+de), a
	ret

; L = bit0 of A. One of four near-identical predicate helpers used by the velocity dispatchers.
BitTest_Bit0_L:
	bit 0, a
	jr z, BitTest_Bit0_L_Clear
	ld l, 0x1:opc
	ret

; Bit clear: L = 0.
BitTest_Bit0_L_Clear:
	ld l, 0x0:opc
	ret

; L = 1 only if bit1 of A is clear and bit0 is set; otherwise 0.
BitTest_Mode2_L:
	bit 1, a
	jr z, BitTest_Mode2_L_Bit1Clear
	ld l, 0x0:opc
	ret

; bit1 clear - fall through to the bit0 test.
BitTest_Mode2_L_Bit1Clear:
	bit 0, a
	jr z, BitTest_Mode2_L_AllClear
	ld l, 0x1:opc
	ret

; Both bits clear: L = 0.
BitTest_Mode2_L_AllClear:
	ld l, 0x0:opc
	ret

; Duplicate of BitTest_Bit0_L (identical code), used by the Type2 dispatcher.
BitTest_Bit0_L_v2:
	bit 0, a
	jr z, BitTest_Bit0_L_v2_Clear
	ld l, 0x1:opc
	ret

; Bit clear: L = 0.
BitTest_Bit0_L_v2_Clear:
	ld l, 0x0:opc
	ret

; Duplicate of BitTest_Mode2_L, used by the Type2 dispatcher.
BitTest_Mode2_L_v2:
	bit 1, a
	jr z, BitTest_Mode2_L_v2_Bit1Clear
	ld l, 0x0:opc
	ret

; bit1 clear - fall through to the bit0 test.
BitTest_Mode2_L_v2_Bit1Clear:
	bit 0, a
	jr z, BitTest_Mode2_L_v2_AllClear
	ld l, 0x1:opc
	ret

; Both bits clear: L = 0.
BitTest_Mode2_L_v2_AllClear:
	ld l, 0x0:opc
	ret

; PATCH TRANSPOSE / OCTAVE-SHIFT LOOKUP (returns a signed 8.8 semitone offset).
; In: WA = a selector byte, C = a patch byte. Out: XHL = offset, 0 when disabled.
; If bit1 of the global audio-mode word at 0x041343 is set the function returns 0,
; i.e. that bit is a global disable for this contribution.
; Otherwise WA-0x10 in 0..9 indexes the 10-entry u16 offset table at 0x00F693 whose
; values are added to 0x022982 to form the jump target; in v142 nine of the ten
; entries point at the 'return 0' stub and only selector 0x14 reaches the fallback.
; Fallback: (C & 0x0F) indexes the byte table at 0x011ACF, sign-extends and shifts
; left 8 (one semitone = 0x100). Called from Voice_Pitch_Compute (0x0235F1).
Pitch_Get_Patch_Octave_Shift:
	ld de, (Voice_GlobalFlags:24)
	bit 1, de
	jr z, Pitch_Get_Patch_Octave_Shift_Dispatch
	ld hl, 0:i3
	jr Pitch_Get_Patch_Octave_Shift_Return

; Range-check the selector and dispatch through the 0x00F693 offset table.
Pitch_Get_Patch_Octave_Shift_Dispatch:
	extz wa
	sub wa, 0x10
	cp wa, 0:i3
	jr lt, Pitch_Get_Patch_Octave_Shift_Fallback
	cp wa, 0x9
	jr gt, Pitch_Get_Patch_Octave_Shift_Fallback
	add wa, wa
	lda xix, (Pitch_OctaveShift_CaseOffsets:24)
	ld	wa, (xix+wa)
	lda xix, (Pitch_Get_Patch_Octave_Shift_JumpTable:24)
	jp	t, (xix+wa)

; Jump-table base AND the case body for offset 0: XHL = 0.
Pitch_Get_Patch_Octave_Shift_JumpTable:
	ld	hl, 0:i3
	jr	Pitch_Get_Patch_Octave_Shift_Return

; Fallback case: signed semitone from the 0x011ACF table, scaled to 8.8.
Pitch_Get_Patch_Octave_Shift_Fallback:
	and c, 0xF
	ld a, c
	extz wa
	lda xbc, (Instrument_OctaveShift_Semitones:24)
	ld	l, (xbc+wa)
	exts hl
	sla hl, 8

; Return.
Pitch_Get_Patch_Octave_Shift_Return:
	ret

; CLAMP A PITCH ACCUMULATOR INTO A KEY RANGE (saturating, no folding).
; In: WA = signed 16-bit pitch value, C = low key limit, E = high key limit.
; Out: XHL. Negative inputs are first saturated: values <= 0xC000 become 0x7FFF, the
; rest become 0. Then the result is clamped to [C*256+0x80, E*256+0x80], i.e. the key
; limits expressed in the same 8.8 units used everywhere in the pitch chain.
; Called from Voice_Pitch_ApplyFineTune_LegatoB (0x0237FB); also 0x02B431.
Pitch_Clamp_Into_Range:
	ld hl, wa
	bit 15, wa
	jr z, Pitch_Clamp_Into_Range_CompareLo
	cp hl, 0xC000
	jr le, Pitch_Clamp_Into_Range_Clamp7FFF
	ld hl, 0:i3
	jr Pitch_Clamp_Into_Range_CompareLo

; Wrapped-negative case: clamp to 0x7FFF.
Pitch_Clamp_Into_Range_Clamp7FFF:
	ldw hl, 0x7FFF

; Low-limit comparison against C*256+0x80.
Pitch_Clamp_Into_Range_CompareLo:
	ld a, c
	extz wa
	sla wa, 8
	add wa, 0x80
	cp hl, wa
	jr ge, Pitch_Clamp_Into_Range_CompareHi
	ld a, c
	extz wa
	ld hl, wa
	sla hl, 8
	add hl, 0x80
	jr Pitch_Clamp_Into_Range_Return

; High-limit comparison against E*256+0x80.
Pitch_Clamp_Into_Range_CompareHi:
	ld a, e
	extz wa
	sla wa, 8
	add wa, 0x80
	cp hl, wa
	ret le
	ld a, e
	extz wa
	ld hl, wa
	sla hl, 8
	add hl, 0x80

; Return.
Pitch_Clamp_Into_Range_Return:
	ret

; FOLD A PITCH VALUE INTO A KEY RANGE BY WHOLE OCTAVES.
; In: WA = signed 16-bit pitch (8.8 semitones), C = low key limit, E = high key limit.
; Out: XHL. Adds or subtracts 0x0C00 (twelve semitones) until the value lies inside
; [C*256+0x80, E*256+0x80]. This is the transpose-into-range used when a sample zone
; cannot cover the played key. Callers: Voice_Pitch_ApplyFineTune (0x0237DA),
; Voice_Pitch_CopyBase (0x023841), 0x02B481.
Pitch_Fold_Octaves_Into_Range:
	ld hl, wa
	jr PitchBend_AlignLoop_CheckSign

; Value has wrapped negative: step by +/- one octave to recover.
PitchBend_AlignLoop_CheckWrapped:
	cp hl, 0xC000
	jr le, PitchBend_AlignLoop_SubStep
	add hl, 0xC00
	jr PitchBend_AlignLoop_CheckSign

; Subtract one octave.
PitchBend_AlignLoop_SubStep:
	sub hl, 0xC00

; Sign test that drives the recovery loop.
PitchBend_AlignLoop_CheckSign:
	ld wa, hl
	bit 15, wa
	jr nz, PitchBend_AlignLoop_CheckWrapped
	jr PitchBend_AlignLoop_LoCheck

; Add one octave (raising loop).
PitchBend_AlignLoop_AddStep:
	add hl, 0xC00

; Keep adding octaves while below the low limit.
PitchBend_AlignLoop_LoCheck:
	ld a, c
	extz wa
	sla wa, 8
	add wa, 0x80
	cp hl, wa
	jr lt, PitchBend_AlignLoop_AddStep
	jr PitchBend_AlignLoop_HiCheck

; Subtract one octave (lowering loop).
PitchBend_AlignLoop_SubFinal:
	sub hl, 0xC00

; Keep subtracting octaves while above the high limit.
PitchBend_AlignLoop_HiCheck:
	ld a, e
	extz wa
	sla wa, 8
	add wa, 0x80
	cp hl, wa
	jr gt, PitchBend_AlignLoop_SubFinal
	ret

; INDEX A BYTE TABLE BY THE TOP 7 BITS OF A WORD.
; In: XWA = table base, BC = word. Out: L = table[(BC & 0x7F00) >> 8] (arithmetic
; shift). Used by WaveSel_StageB_Build_Reg040 (0x023880) to turn the current pitch into
; a key-zone number.
WaveSel_KeyTable_Lookup:
	and bc, 0x7F00
	sra bc, 8
	ld	l, (xwa+bc)
	ret

; EMIT A KEY-ZONE PARAMETER RECORD OF STRIDE 0x0F.
; In: XWA = voice work record, XBC = record table base, DE = zone index.
; Computes XBC += DE*0x0F, stores that pointer at (XWA+0x0F), ORs the type code 0x7000
; into the word at (XWA+0x01), copies the record's first word to the staging word at
; 0x0451CE and its word at +0x0D to 0x293E.
; One of six stride variants selected by WaveSel_StageB_Build_Reg040 from three flag
; bits of the zone descriptor.
WaveSel_Emit_ZoneRecord_S15:
	extz de
	muls de, 0xF
	lda	xbc, (xbc+de)
	ld (xwa + 15), xbc
	ormi16 (xwa + 1), 0x7000
	ld wa, (xbc)
	ld (Payload_Bss_Start+0x6358:24), wa
	ld wa, (xbc + 13)
	ld (10558:16), wa
	ret

; EMIT A KEY-ZONE PARAMETER RECORD OF STRIDE 0x0C.
; In: XWA = voice work record, XBC = record table base, DE = zone index.
; Computes XBC += DE*0x0C, stores that pointer at (XWA+0x0F), ORs the type code 0x5000
; into the word at (XWA+0x01), copies the record's first word to the staging word at
; 0x0451CE and its word at +0x0A to 0x293E.
; One of six stride variants selected by WaveSel_StageB_Build_Reg040 from three flag
; bits of the zone descriptor.
WaveSel_Emit_ZoneRecord_S12:
	extz de
	muls de, 0xC
	lda	xbc, (xbc+de)
	ld (xwa + 15), xbc
	ormi16 (xwa + 1), 0x5000
	ld wa, (xbc)
	ld (Payload_Bss_Start+0x6358:24), wa
	ld wa, (xbc + 10)
	ld (10558:16), wa
	ret

; EMIT A KEY-ZONE PARAMETER RECORD OF STRIDE 0x0D.
; In: XWA = voice work record, XBC = record table base, DE = zone index.
; Computes XBC += DE*0x0D, stores that pointer at (XWA+0x0F), ORs the type code 0x3000
; into the word at (XWA+0x01), copies the record's first word to the staging word at
; 0x0451CE and its word at none (0 is written) to 0x293E.
; One of six stride variants selected by WaveSel_StageB_Build_Reg040 from three flag
; bits of the zone descriptor.
WaveSel_Emit_ZoneRecord_S13:
	extz de
	muls de, 0xD
	lda	xbc, (xbc+de)
	ld (xwa + 15), xbc
	ormi16 (xwa + 1), 0x3000
	ld wa, (xbc)
	ld (Payload_Bss_Start+0x6358:24), wa
	ldw (10558:16), 0
	ret

; EMIT A KEY-ZONE PARAMETER RECORD OF STRIDE 0x0A.
; In: XWA = voice work record, XBC = record table base, DE = zone index.
; Computes XBC += DE*0x0A, stores that pointer at (XWA+0x0F), ORs the type code 0x1000
; into the word at (XWA+0x01), copies the record's first word to the staging word at
; 0x0451CE and its word at none (0 is written) to 0x293E.
; One of six stride variants selected by WaveSel_StageB_Build_Reg040 from three flag
; bits of the zone descriptor.
WaveSel_Emit_ZoneRecord_S10:
	extz de
	muls de, 0xA
	lda	xbc, (xbc+de)
	ld (xwa + 15), xbc
	ormi16 (xwa + 1), 0x1000
	ld wa, (xbc)
	ld (Payload_Bss_Start+0x6358:24), wa
	ldw (10558:16), 0
	ret

; EMIT A KEY-ZONE PARAMETER RECORD OF STRIDE 0x06.
; In: XWA = voice work record, XBC = record table base, DE = zone index.
; Computes XBC += DE*0x06, stores that pointer at (XWA+0x0F), ORs the type code 0x4000
; into the word at (XWA+0x01), copies the record's first word to the staging word at
; 0x0451CE and its word at +0x04 to 0x293E.
; One of six stride variants selected by WaveSel_StageB_Build_Reg040 from three flag
; bits of the zone descriptor.
WaveSel_Emit_ZoneRecord_S6:
	extz de
	muls de, 0x6
	lda	xbc, (xbc+de)
	ld (xwa + 15), xbc
	ormi16 (xwa + 1), 0x4000
	ld wa, (xbc)
	ld (Payload_Bss_Start+0x6358:24), wa
	ld wa, (xbc + 4)
	ld (10558:16), wa
	ret

; EMIT A KEY-ZONE PARAMETER RECORD OF STRIDE 4 (index shifted left 2 instead of a
; multiply). Unlike the other five variants it writes NO type code into (XWA+0x01) and
; always zeroes 0x293E. This is the base/default zone format.
; ALL SIX VARIANTS ABOVE (S15, S12, S13, S10, S6 and this one) copy the zone record's word 0
; to 0x0451CE unchanged -- `ld wa, (xbc)` then `stw_da 0x0451ce, xwa`, no masking -- and
; that word IS the wave selector, (class << 12) | entry. [INFERENCE] it is resolved by IC303
; itself against the wave ROM's own per-page directory; no CPU here can read that ROM.
; The firmware never range-checks the entry and never dereferences it, but it does modify it
; downstream: WaveSel_StageB_Store_Reg040 doubles the top nibble when bit 2 of 0x041343 is
; set, and Voice_Init_Type1 adds (tick & 7) through Voice_Slot_ApplyPitchJitter. See
; "WHAT +0x040 SELECTS" in the staging-block header for the format and the open questions.
WaveSel_Emit_ZoneRecord_S4:
	extz de
	sla de, 2
	lda	xbc, (xbc+de)
	ld (xwa + 15), xbc
	ld wa, (xbc)
	ld (Payload_Bss_Start+0x6358:24), wa
	ldw (10558:16), 0
	ret

; SATURATE A SIGNED 16-BIT PITCH VALUE TO [0, 0x7FFF].
; In: WA. Out: WA and XHL. Values with bit15 set become 0x7FFF if <= 0xC000 (treated as
; a wrap of a large positive) and 0 otherwise. Used all over the pitch chain
; (0x02373A, 0x023A85, 0x023AC7) and from 0x02B431.
Pitch_Saturate_15bit:
	ld bc, wa
	bit 15, bc
	jr z, Pitch_Saturate_15bit_Return
	cp wa, 0xC000
	jr ule, Pitch_Saturate_15bit_Clamp7FFF
	ld wa, 0:i3
	jr Pitch_Saturate_15bit_Return

; Wrapped-positive case: 0x7FFF.
Pitch_Saturate_15bit_Clamp7FFF:
	ldw wa, 0x7FFF

; Copy the result to XHL and return.
Pitch_Saturate_15bit_Return:
	ld hl, wa
	ret

; CLAMP WA INTO [DE, BC] (signed). Out: WA and XHL. Callers 0x03079E, 0x0307E9 and the
; level packer at 0x023C44 / 0x023C92 / 0x023CA2 / 0x023CB2 / 0x023CC0.
; Int_ClampSignedToRange: Clamps signed 16-bit WA into [DE, BC] (DE = low bound, BC = high bound); result in WA and
;   XHL. Basis: callers + body -- 62 call sites load the bounds first (0..0xFF, 4..0x7F, -50..+50).
Int_ClampSignedToRange:
	cp wa, bc
	jr le, ClampS16_WA_To_DEBC_CheckLo
	ld wa, bc
	jr ClampS16_WA_To_DEBC_Return

; Low-bound test against DE.
ClampS16_WA_To_DEBC_CheckLo:
	cp wa, de
	jr ge, ClampS16_WA_To_DEBC_Return
	ld wa, de

; Copy to XHL and return.
ClampS16_WA_To_DEBC_Return:
	ld hl, wa
	ret

; SCALE A SIGNED DEPTH BY A CURVE-TABLE COEFFICIENT.
; In: A = signed depth, C = curve index (bit7 forced clear), E = shift amount in its
; low nibble. Negative depths are re-mapped through the ROM byte table at 0x00FEE4
; before being negated; the coefficient itself comes from the ROM byte table at
; 0x00FF64 indexed by C. Out: XHL = (coeff * |depth|) >> (E & 0x0F).
; Called from Voice_Level_Triplet_ModByEnv (0x023B3D).
PitchBend_Scale:
	res 7, c
	cp a, 0:i3
	jr ge, PitchBend_Scale_Multiply
	extz bc
	lda xhl, (Voice_DepthMirror_Table:24)
	ld	c, (xhl+bc)
	extz bc
	cpl a
	inc 1, a

; Signed multiply of the coefficient by the depth, then the optional right shift.
PitchBend_Scale_Multiply:
	ldfr_berp A, 0xF0
	exts ix
	ld a, c
	extz wa
	lda xbc, (PitchBend_ScaleCoeff_Table:24)
	ld	l, (xbc+wa)
	exts hl
	ld wa, hl
	muls	xwa, ix
	ld hl, wa
	ld a, e
	and a, 0xF
	ret z
	sraa hl
	ret

; SYMMETRIC DETUNE CURVE LOOKUP.
; In: WA = signed amount. |WA| is clamped to 0x32 (50) and used to index the byte table
; at 0x0119C8; the result is negated again for negative inputs. Out: XHL.
; Called from the level packer (0x023C4D, 0x023CC9, 0x023CD2).
Detune_ScaleSymmetric:
	cp wa, 0:i3
	jr ge, Detune_ScaleSymmetric_PosArm
	cpl wa
	inc 1, wa
	cp wa, 0x32
	jr le, Detune_ScaleSymmetric_NegArm
	ldw wa, 0x32

; Negative arm: table lookup then two's-complement negate.
Detune_ScaleSymmetric_NegArm:
	extz wa
	lda xbc, (Detune_Scale_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	cpl wa
	inc 1, wa
	jr Detune_ScaleSymmetric_Return

; Positive arm: clamp to 0x32.
Detune_ScaleSymmetric_PosArm:
	cp wa, 0x32
	jr le, Detune_ScaleSymmetric_PosClamp
	ldw wa, 0x32

; Positive arm table lookup.
Detune_ScaleSymmetric_PosClamp:
	extz wa
	lda xbc, (Detune_Scale_Curve:24)
	ld	a, (xbc+wa)
	extz wa

; Copy to XHL and return.
Detune_ScaleSymmetric_Return:
	ld hl, wa
	ret

; Unsigned variant: XHL = byte table 0x0119C8 indexed directly by WA, no clamp, no sign handling.
Detune_ScaleUnsigned:
	extz wa
	lda xbc, (Detune_Scale_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld hl, wa
	ret

; INTERPOLATE A PARAMETER BETWEEN TWO LIMITS AND SCALE BY A SIGNED DEPTH.
; In: WA = word whose bits 8..14 hold the control value, BC = baseline, E = low limit,
; two stacked args: (XSP+0x06) = high limit, (XSP+0x04) = signed depth.
; Out: XHL = ((clamp(ctrl, E, hi) - BC) * depth) >> 5. 'retd 4' pops both arguments.
; Called from Voice_Level_ApplyVelocityMod (0x023C36) and 0x023C83.
Pan_ScaleWithVelocity:
	and wa, 0x7F00
	srl wa, 8
	ld l, (xsp + 6)
	extz hl
	cp wa, hl
	jr ule, Pan_ScaleWithVelocity_ClampLo
	ld a, (xsp + 6)
	extz wa
	jr Pan_ScaleWithVelocity_Multiply

; Low-limit clamp against E.
Pan_ScaleWithVelocity_ClampLo:
	ld l, e
	extz hl
	cp wa, hl
	jr nc, Pan_ScaleWithVelocity_Multiply
	ld a, e
	extz wa

; Signed multiply by the stacked depth, then >> 5.
Pan_ScaleWithVelocity_Multiply:
	extz bc
	ld de, wa
	sub de, bc
	ld l, (xsp + 4)
	exts hl
	ld wa, hl
	muls	xwa, de
	ld hl, wa
	sra hl, 5
	retd 0x4

; CLAMP A FILTER-CUTOFF VALUE TO [0, 0x78] (0..120). Out: WA and XHL.
; Called by TVF_Calc_Cutoff/_B and from 0x0306C4, 0x03070D, 0x030753.
TVF_Clamp_Cutoff:
	cp wa, 0x78
	jr le, TVF_Clamp_Cutoff_CheckLo
	ldw wa, 0x78
	jr TVF_Clamp_Cutoff_Return

; Low-bound test.
TVF_Clamp_Cutoff_CheckLo:
	cp wa, 0:i3
	jr ge, TVF_Clamp_Cutoff_Return
	ld wa, 0:i3

; Copy to XHL and return.
TVF_Clamp_Cutoff_Return:
	ld hl, wa
	ret

; COMPUTE A FILTER-CUTOFF CONTRIBUTION WITH KEY FOLLOW AND LEVEL SCALING.
; In: XWA = voice work record, BC = running accumulator, DE = key-follow depth,
;     stacked byte (XSP+0x04) = level-scaling depth. Out: XHL = value in 0..0x78.
; XIX = (XWA+0x17) = the patch parameter block.
; Key follow (when DE != 0): curve = (patch+0x36) >> 5 selects one of eight 128-byte
;   curves in the table at 0x011519; the key number (XWA+0x0C) & 0x7F indexes inside it;
;   the signed byte is multiplied by DE and added as (product >> 5).
; Level scaling (when the stacked depth != 0): the control value (XWA+0x08) bits 8..14
;   is clamped between (patch+0x3A) and (patch+0x3B), (patch+0x39) is subtracted, the
;   difference is multiplied by the depth and added as (product >> 5).
; Finally +0x18 of bias and TVF_Clamp_Cutoff. 'retd 2' pops the stacked argument.
; Called from all five filter builders at 0x023D42, 0x023E04, 0x023E76, 0x023F11,
; 0x023F80, 0x024002.
; See [UNCERTAIN]: this is a TVF (filter) computation, not portamento.
TVF_Calc_Cutoff:
	ld hl, de
	ld xix, (xwa + 23)
	cp hl, 0:i3
	jr z, TVF_Calc_Cutoff_DepthScale
	ld e, (xix + 54)
	and e, 0xE0
	srl e, 5
	extz de
	ld iy, de
	sla iy, 7
	ld e, (xwa + 12)
	extz de
	and de, 0x7F
	extz xde
	lda	xde, (xde+iy)
	ld xiy, TVF_KeyFollow_Curves
	add xiy, xde
	ld e, (xiy)
	ldfr_berp E, 0xF4
	exts iy
	ld de, hl
	muls	xde, iy
	ld hl, de
	sra hl, 5
	add bc, hl

; Level-scaling stage: clamp (XWA+0x08) hi-byte between (patch+0x3A) and (patch+0x3B).
TVF_Calc_Cutoff_DepthScale:
	cp (xsp + 4), 0x0
	jr z, TVF_Calc_Cutoff_AddBaseline
	ld de, (xwa + 8)
	and de, 0x7F00
	srl de, 8
	ld a, (xix + 59)
	extz wa
	cp de, wa
	jr ule, TVF_Calc_Cutoff_ClampHi
	ld a, (xix + 59)
	ld e, a
	extz de
	jr TVF_Calc_Cutoff_Multiply

; Lower clamp arm against (patch+0x3A).
TVF_Calc_Cutoff_ClampHi:
	ld a, (xix + 58)
	extz wa
	cp de, wa
	jr nc, TVF_Calc_Cutoff_Multiply
	ld a, (xix + 58)
	ld e, a
	extz de

; Subtract the (patch+0x39) reference, multiply by the stacked depth, >> 5.
TVF_Calc_Cutoff_Multiply:
	ld a, (xix + 57)
	extz wa
	sub de, wa
	ld a, (xsp + 4)
	exts wa
	muls	xwa, de
	sra wa, 5
	add bc, wa

; Add the +0x18 bias and clamp to 0..0x78.
TVF_Calc_Cutoff_AddBaseline:
	add bc, 0x18
	ld wa, bc
	calr TVF_Clamp_Cutoff
	retd 0x2

; SECOND CUTOFF CONTRIBUTION VARIANT - same shape as TVF_Calc_Cutoff but the
; key-follow depth comes from (patch+0x10) and the curve selector from (patch+0x0F),
; and there is no level-scaling stage and no stacked argument. Ends with the same +0x18
; bias and TVF_Clamp_Cutoff (reached by tail jump). No in-ROM caller was found by a
; call/calr scan, so it may be reachable only through a table this pass did not decode.
TVF_Calc_Cutoff_NoKeyFollow:
	ld xix, (xwa + 23)
	ld e, (xix + 16)
	ld l, e
	exts hl
	cp hl, 0:i3
	jr z, TVF_Calc_Cutoff_NoKeyFollow_AddBaseline
	ld e, (xix + 15)
	and e, 0xE0
	srl e, 5
	extz de
	sla de, 7
	ld a, (xwa + 12)
	extz wa
	and wa, 0x7F
	extz xwa
	lda	xwa, (xwa+de)
	ld xde, TVF_KeyFollow_Curves
	add xde, xwa
	ld a, (xde)
	ld e, a
	exts de
	ld wa, hl
	muls	xwa, de
	ld hl, wa
	sra hl, 5
	ld wa, hl
	add bc, wa

; Add the +0x18 bias and tail-jump into TVF_Clamp_Cutoff.
TVF_Calc_Cutoff_NoKeyFollow_AddBaseline:
	add bc, 0x18
	ld wa, bc
	jrl TVF_Clamp_Cutoff

; Add the +0x18 bias to WA and clamp the result to at most 0x78 (no lower clamp).
; Out: WA and XHL. Used by the filter builders for the second register field.
TVF_Bias_Clamp_Amount:
	add wa, 0x18
	cp wa, 0x78
	jr le, TVF_Bias_Clamp_Amount_Return
	ldw wa, 0x78

; Copy to XHL and return.
TVF_Bias_Clamp_Amount_Return:
	ld hl, wa
	ret

; LOOK UP A THREE-BYTE FILTER COEFFICIENT RECORD.
; In: A - low nibble selects the record, bit7 selects the table:
;     bit7 set   -> records at 0x011A25 (byte0), 0x011A26 (byte1), 0x011A27 (byte2)
;     bit7 clear -> records at 0x0119FB / 0x0119FC / 0x0119FD
;   (three parallel byte arrays with a stride of 3, i.e. one 3-byte record per index).
; Out: XHL = (byte1 << 8) | byte0-in-IX; byte2 is sign-extended into the global word at
; 0x2940. Called from the filter builders at 0x023D7C, 0x023DA2, 0x023E33, 0x023EAF,
; 0x023F3D.
TVF_Lookup_Depth_Amount:
	ld c, a
	and c, 0xF
	ld e, c
	extz de
	bit 7, a
	jr z, TVF_Lookup_Depth_Amount_SetA
	ld wa, de
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	lda xwa, (TVF_DepthRecords_B+1:24)
	add xwa, xbc
	ld a, (xwa)
	ld l, a
	extz hl
	sll hl, 8
	ld wa, de
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	ld xwa, TVF_DepthRecords_B
	add xwa, xbc
	ld a, (xwa)
	ldfr_berp A, 0xF0
	extz ix
	ld wa, de
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	lda xwa, (TVF_DepthRecords_B+2:24)
	add xwa, xbc
	ld a, (xwa)
	exts wa
	ld (10560:16), wa
	jr TVF_Lookup_Depth_Amount_Return

; bit7-clear arm: use the 0x0119FB/FC/FD record set.
TVF_Lookup_Depth_Amount_SetA:
	ld wa, de
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	lda xwa, (TVF_DepthRecords_A+1:24)
	add xwa, xbc
	ld a, (xwa)
	ld l, a
	extz hl
	sll hl, 8
	ld wa, de
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	ld xwa, TVF_DepthRecords_A
	add xwa, xbc
	ld a, (xwa)
	ldfr_berp A, 0xF0
	extz ix
	ld wa, de
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	lda xwa, (TVF_DepthRecords_A+2:24)
	add xwa, xbc
	ld a, (xwa)
	exts wa
	ld (10560:16), wa

; Merge the two halves into XHL and return.
TVF_Lookup_Depth_Amount_Return:
	or hl, ix
	ret

; FILTER BYPASS: write the neutral pair (XWA+0x42) = 0x017F and (XWA+0x44) = 0x7F7F.
; This is entry 0 of the filter-mode dispatch table at 0x02412B, selected when
; (patch+0x36) & 7 == 0. XWA = voice work record.
TVF_Set_Bypass:
	ldw (xwa + 66), 0x17F
	ldw (xwa + 68), 0x7F7F
	ret

; Clamp WA into [DE, BC]; identical code to Int_ClampSignedToRange. Callers 0x03083D, 0x03086D, 0x03089D, 0x0308CD, 0x030901, 0x03093F.
ClampS16_WA_Short:
	cp wa, bc
	jr le, ClampS16_WA_Short_CheckLo
	ld wa, bc
	jr ClampS16_WA_Short_Return

; Low-bound test against DE.
ClampS16_WA_Short_CheckLo:
	cp wa, de
	jr ge, ClampS16_WA_Short_Return
	ld wa, de

; Copy to XHL and return.
ClampS16_WA_Short_Return:
	ld hl, wa
	ret

; ZERO ONE 9-BYTE ENVELOPE SUB-RECORD.
; In: WA = sub-record number (0..2), C = voice/part index. Address is
; 0x04424E + index*0x1B + sub*9; bytes +0..+5 and +7 are cleared (+6 and +8 are left
; alone). Called from 0x034C23. The 0x1B-byte record is exactly three of these.
NoteState_ClearRecord:
	extz wa
	muls wa, 0x9
	ld de, wa
	ld a, c
	extz wa
	muls wa, 0x1B
	lda xbc, (Payload_Bss_Start+0x53d8:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+de)
	ld (xwa + 1), 0x0
	ld (xwa + 2), 0x0
	ld (xwa + 3), 0x0
	ld (xwa + 4), 0x0
	ld (xwa), 0x0
	ld (xwa + 5), 0x0
	ld (xwa + 7), 0x0
	ret

; CAP AN ENVELOPE DEPTH BY A NORMALISED (0x7F - x) FACTOR.
; In: XWA = value, C and E = two 0..0x7F parameters. Uses Math_Multiply32 (0x03D8CA)
; twice: t = (0x7F - C) * E, then result = (value * t) >> 12, finally capped at the
; original value. Out: XHL. Called by every EG/frequency computation in this region
; (0x022E85, 0x022F97, 0x0230A8, 0x023127).
EnvDepth_Cap:
	dec 4, xsp
	push xiz
	ld (xsp + 4), xwa
	ld xwa, 0:i3
	ld a, c
	ld xbc, 0x7F
	sub xbc, xwa
	ld xwa, 0:i3
	ld a, e
	call Math_Multiply32
	ld xiz, xhl
	ld xbc, (xsp + 4)
	ld xwa, xiz
	call Math_Multiply32
	srl xhl, 12
	cp xhl, (xsp + 4)
	jr ule, EnvDepth_Cap_Return
	ld xhl, (xsp + 4)

; Restore and return.
EnvDepth_Cap_Return:
	pop xiz
	inc 4, xsp
	ret

; COMPUTE ENVELOPE VALUE A FOR ONE VOICE (rate/level pair, formatted for the TG).
; In: WA = index. Record = 0x04424E + index*0x1B.
;   (rec+0x01) indexes the u16 table at 0x010A64 -> base value;
;   base is multiplied by (rec+0x02) through Math_Multiply32;
;   if (rec+0x05) != 0 the EnvDepth_Cap of ((rec+0x05),(rec+0x06)) is subtracted;
;   the accumulator is >> 7 and clamped to 0x1FFF;
;   finally (rec+0x00) & 3 indexes the u16 table at 0x011511 and those bits are OR'ed
;   in, producing the 16-bit word the TG expects. Out: XHL.
; Callers 0x0293B9, 0x02F5F0.
EGEnv_Compute_A:
	dec 4, xsp
	push xiz
	extz wa
	muls wa, 0x1B
	lda xbc, (Payload_Bss_Start+0x53d8:24)
	exts xwa
	add xwa, xbc
	ld (xsp + 4), xwa
	ld a, (xwa + 1)
	extz wa
	add wa, wa
	lda xbc, (EGEnv_BaseCurve_A:24)
	ld	wa, (xbc+wa)
	ld iz, wa
	extz xiz
	ld xwa, (xsp + 4)
	ld a, (xwa + 2)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xiz
	call Math_Multiply32
	ld xiz, xhl
	ld xwa, (xsp + 4)
	cp (xwa + 5), 0x0
	jr z, EGEnv_Compute_A_Normalise
	ld xwa, (xsp + 4)
	ld a, (xwa + 6)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 5)
	ld e, a
	extz de
	ld xwa, xiz
	calr EnvDepth_Cap
	sub xiz, xhl

; >> 7 and clamp the accumulator to 0x1FFF.
EGEnv_Compute_A_Normalise:
	srl xiz, 7
	cp xiz, 0x1FFF
	jr ule, EGEnv_Compute_A_FormatBits
	ld xiz, 0x1FFF

; OR in the 2-bit mode field fetched from the 0x011511 table.
EGEnv_Compute_A_FormatBits:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	and a, 0x3
	extz wa
	add wa, wa
	lda xbc, (EGEnv_ModeBits_Table:24)
	ld	wa, (xbc+wa)
	ld bc, iz
	ld hl, bc
	or hl, wa
	pop xiz
	inc 4, xsp
	ret

; SIMPLE ENVELOPE VALUE: (rec+0x03) indexes the u16 table at 0x010964, the value is
; multiplied by (rec+0x04), >> 7 and clamped to 0x3FFF. No depth cap, no mode bits.
; Record base 0x04424E, stride 0x1B. Callers 0x0295C8, 0x02F5FE.
EGEnv_Compute_A_Simple:
	extz wa
	muls wa, 0x1B
	lda xbc, (Payload_Bss_Start+0x53d8:24)
	lda	xde, (xbc+wa)
	ld a, (xde + 3)
	extz wa
	add wa, wa
	lda xbc, (EGEnv_ValueCurve_Simple:24)
	ld	hl, (xbc+wa)
	extz xhl
	ld a, (xde + 4)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xhl
	call Math_Multiply32
	srl xhl, 7
	cp xhl, 0x3FFF
	ret ule
	ld xhl, 0x3FFF
	ret

; BYTE-IDENTICAL DUPLICATE of EGEnv_Compute_A_Simple (0x022EBA) - same table, same
; shift, same clamp. No caller found by a call/calr scan over the whole ROM.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from EGEnv_OpaqueData.
EGEnv_Compute_A_Simple_Dup:
	extz	wa
	muls	wa, 27
	lda	xbc, (Payload_Bss_Start+0x53d8:24)
	lda	xde, (xbc+wa)
	ld	a, (xde+3)
	extz	wa
	add	wa, wa
	lda	xbc, (EGEnv_ValueCurve_Simple:24)
	ld	hl, (xbc+wa)
	extz	xhl
	ld	a, (xde+4)
	ld	xbc, 0:i3
	ld	c, a
	ld	xwa, xhl
	call	Math_Multiply32
	srl	xhl, 7
	cp	xhl, 0x3fff
	ret	ule
	ld	xhl, 0x3fff
	ret

; Envelope value B: identical structure to EGEnv_Compute_A but the record base is
; 0x044257 (= 0x04424E + 9, the second 9-byte sub-record) and the base-value table is
; 0x010B64 instead of 0x010A64. Callers 0x0297CD, 0x02F6F6.
EGEnv_Compute_B:
	dec 4, xsp
	push xiz
	extz wa
	muls wa, 0x1B
	lda xbc, (Payload_Bss_Start+0x53e1:24)
	exts xwa
	add xwa, xbc
	ld (xsp + 4), xwa
	ld a, (xwa + 1)
	extz wa
	add wa, wa
	lda xbc, (EGEnv_BaseCurve_B:24)
	ld	wa, (xbc+wa)
	ld iz, wa
	extz xiz
	ld xwa, (xsp + 4)
	ld a, (xwa + 2)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xiz
	call Math_Multiply32
	ld xiz, xhl
	ld xwa, (xsp + 4)
	cp (xwa + 5), 0x0
	jr z, EGEnv_Compute_B_Normalise
	ld xwa, (xsp + 4)
	ld a, (xwa + 6)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 5)
	ld e, a
	extz de
	ld xwa, xiz
	calr EnvDepth_Cap
	sub xiz, xhl

; >> 7 and clamp the accumulator to 0x1FFF.
EGEnv_Compute_B_Normalise:
	srl xiz, 7
	cp xiz, 0x1FFF
	jr ule, EGEnv_Compute_B_FormatBits
	ld xiz, 0x1FFF

; OR in the 2-bit mode field fetched from the 0x011511 table.
EGEnv_Compute_B_FormatBits:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	and a, 0x3
	extz wa
	add wa, wa
	lda xbc, (EGEnv_ModeBits_Table:24)
	ld	wa, (xbc+wa)
	ld bc, iz
	ld hl, bc
	or hl, wa
	pop xiz
	inc 4, xsp
	ret

; Simple envelope value for sub-record B: base 0x044257, table 0x010964, clamp 0x3FFF.
; Callers 0x0299DF, 0x02F704.
EGEnv_Compute_B_Simple:
	extz wa
	muls wa, 0x1B
	lda xbc, (Payload_Bss_Start+0x53e1:24)
	exts xwa
	add xwa, xbc
	ld xde, xwa
	ld a, (xde + 3)
	extz wa
	add wa, wa
	lda xbc, (EGEnv_ValueCurve_Simple:24)
	ld	hl, (xbc+wa)
	extz xhl
	ld a, (xde + 4)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xhl
	call Math_Multiply32
	srl xhl, 7
	cp xhl, 0x3FFF
	ret ule
	ld xhl, 0x3FFF
	ret

; RAW FREQUENCY/CUTOFF VALUE FROM SUB-RECORD B, without clamping or a register write.
; In: WA = index; record 0x044257 + index*0x1B; (rec+0x03) indexes the u16 table at
; 0x010964, multiplied by (rec+0x04) via Math_Multiply32, >> 7. Out: XHL.
; No caller found by a call/calr scan.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
Voice_Freq_ComputeLeft_Raw:
	extz	wa
	muls	wa, 27
	lda	xbc, (Payload_Bss_Start+0x53e1:24)
	exts	xwa
	add	xwa, xbc
	ld	xde, xwa
	ld	a, (xde+3)
	extz	wa
	add	wa, wa
	lda	xbc, (EGEnv_ValueCurve_Simple:24)
	ld	hl, (xbc+wa)
	extz	xhl
	ld	a, (xde+4)
	ld	xbc, 0:i3
	ld	c, a
	ld	xwa, xhl
	call	Math_Multiply32
	srl	xhl, 7
	ret

; COMPUTE AND STORE THE LEFT-CHANNEL FREQUENCY WORD.
; In: A = index (0..0x7F). Record = 0x044260 + index*0x1B (the third 9-byte
; sub-record). Same pipeline as EGEnv_Compute_A - base from the u16 table at 0x010C64
; indexed by (rec+0x01), multiplied by (rec+0x02), optional EnvDepth_Cap subtraction,
; >> 7, clamp 0x1FFF, OR the 0x011511 mode bits - then stores the result in the staging
; word at 0x045204 for indices < 0x40 and 0x04520E for indices >= 0x40.
; Callers 0x029BEB, 0x02F7FB.
Voice_Freq_WriteLeft:
	dec 4, xsp
	push xiz
	ld c, a
	extz bc
	muls bc, 0x1B
	lda xde, (Payload_Bss_Start+0x53ea:24)
	exts xbc
	add xbc, xde
	ld (xsp + 4), xbc
	cp a, 0x40
	jr nc, Voice_Freq_WriteLeft_HiRange
	ld xwa, (xsp + 4)
	ld a, (xwa + 1)
	extz wa
	add wa, wa
	lda xbc, (Voice_FreqWrite_BaseCurve:24)
	ld	wa, (xbc+wa)
	ld iz, wa
	extz xiz
	ld xwa, (xsp + 4)
	ld a, (xwa + 2)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xiz
	call Math_Multiply32
	ld xiz, xhl
	ld xwa, (xsp + 4)
	cp (xwa + 5), 0x0
	jr z, Voice_Freq_WriteLeft_Clamp
	ld xwa, (xsp + 4)
	ld a, (xwa + 6)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 5)
	ld e, a
	extz de
	ld xwa, xiz
	calr EnvDepth_Cap
	sub xiz, xhl

; Low range: >> 7 and clamp to 0x1FFF.
Voice_Freq_WriteLeft_Clamp:
	srl xiz, 7
	cp xiz, 0x1FFF
	jr ule, Voice_Freq_WriteLeft_Store
	ld xiz, 0x1FFF

; Low range: OR the mode bits and store to 0x045204.
Voice_Freq_WriteLeft_Store:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	and a, 0x3
	extz wa
	add wa, wa
	lda xbc, (EGEnv_ModeBits_Table:24)
	ld	wa, (xbc+wa)
	ld bc, iz
	or bc, wa
	ld (Payload_Bss_Start+0x638e:24), bc
	jr Voice_Freq_WriteLeft_Return

; Index >= 0x40: the identical computation for the upper voice bank.
Voice_Freq_WriteLeft_HiRange:
	ld xwa, (xsp + 4)
	ld a, (xwa + 1)
	extz wa
	add wa, wa
	lda xbc, (Voice_FreqWrite_BaseCurve:24)
	ld	wa, (xbc+wa)
	ld iz, wa
	extz xiz
	ld xwa, (xsp + 4)
	ld a, (xwa + 2)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xiz
	call Math_Multiply32
	ld xiz, xhl
	ld xwa, (xsp + 4)
	cp (xwa + 5), 0x0
	jr z, Voice_Freq_WriteLeft_HiRange_Clamp
	ld xwa, (xsp + 4)
	ld a, (xwa + 6)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 5)
	ld e, a
	extz de
	ld xwa, xiz
	calr EnvDepth_Cap
	sub xiz, xhl

; High range: >> 7 and clamp to 0x1FFF.
Voice_Freq_WriteLeft_HiRange_Clamp:
	srl xiz, 7
	cp xiz, 0x1FFF
	jr ule, Voice_Freq_WriteLeft_HiRange_Store
	ld xiz, 0x1FFF

; High range: OR the mode bits and store to 0x04520E.
Voice_Freq_WriteLeft_HiRange_Store:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	and a, 0x3
	extz wa
	add wa, wa
	lda xbc, (EGEnv_ModeBits_Table:24)
	ld	wa, (xbc+wa)
	ld bc, iz
	or bc, wa
	ld (Payload_Bss_Start+0x6398:24), bc

; Restore and return.
Voice_Freq_WriteLeft_Return:
	pop xiz
	inc 4, xsp
	ret

; COMPUTE AND STORE THE RIGHT-CHANNEL FREQUENCY WORD.
; In: A = index. Record = 0x044260 + index*0x1B; (rec+0x03) indexes the u16 table at
; 0x010964, multiplied by (rec+0x04), >> 7, clamped to 0x3FFF. For indices < 0x40 bit15
; is forced when (rec+0x00) bit5 is set and the value goes to 0x045206; for indices
; >= 0x40 it goes to 0x04520A with no bit15 handling.
; Callers 0x029DFF, 0x02F804.
Voice_Freq_WriteRight:
	dec 2, xsp
	push xiz
	ld (xsp + 4), a
	ld a, (xsp + 4)
	extz wa
	muls wa, 0x1B
	lda xbc, (Payload_Bss_Start+0x53ea:24)
	exts xwa
	add xwa, xbc
	ld xiz, xwa
	ld a, (xiz + 3)
	extz wa
	add wa, wa
	lda xbc, (EGEnv_ValueCurve_Simple:24)
	ld	hl, (xbc+wa)
	extz xhl
	ld a, (xiz + 4)
	ld xbc, 0:i3
	ld c, a
	ld xwa, xhl
	call Math_Multiply32
	srl xhl, 7
	cp (xsp + 4), 0x40
	jr nc, Voice_Freq_WriteRight_HiRange
	cp xhl, 0x3FFF
	jr ule, Voice_Freq_WriteRight_FlagSet
	ld xhl, 0x3FFF

; (rec+0x00) bit5 set: force bit15 of the result before storing.
Voice_Freq_WriteRight_FlagSet:
	bitm 5, (xiz)
	jr z, Voice_Freq_WriteRight_Store
	set 15, hl
	ld (Payload_Bss_Start+0x6390:24), hl
	jr Voice_Freq_WriteRight_Return

; Store to the low-bank staging word 0x045206.
Voice_Freq_WriteRight_Store:
	ld (Payload_Bss_Start+0x6390:24), hl
	jr Voice_Freq_WriteRight_Return

; Index >= 0x40: clamp for the upper bank.
Voice_Freq_WriteRight_HiRange:
	cp xhl, 0x3FFF
	jr ule, Voice_Freq_WriteRight_HiRange_Store
	ld xhl, 0x3FFF

; Store to the high-bank staging word 0x04520A.
Voice_Freq_WriteRight_HiRange_Store:
	ld (Payload_Bss_Start+0x6394:24), hl

; Restore and return.
Voice_Freq_WriteRight_Return:
	pop xiz
	inc 2, xsp
	ret

; Same computation as Voice_Freq_WriteRight but without the (rec+0x00) bit5 handling;
; stores to 0x045206 (index < 0x40) or 0x04520A. No caller found by a call/calr scan.
; Emitted as raw .byte in the LLVM source, so its internal branch targets and the small
; clamp helper that follows it at 0x023242 carry no symbols - see the [LABEL] and
; [ROUTINE] proposals for 0x023226..0x02324B.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Note: its internal branch targets are now labelled by the branch symboliser.
Voice_Freq_ComputeRight_Raw:
	dec	2, xsp
	ld	(xsp), a
	ld	a, (xsp)
	extz	wa
	muls	wa, 27
	lda	xbc, (Payload_Bss_Start+0x53ea:24)
	exts	xwa
	add	xwa, xbc
	ld	xde, xwa
	ld	a, (xde+3)
	extz	wa
	add	wa, wa
	lda	xbc, (EGEnv_ValueCurve_Simple:24)
	ld	hl, (xbc+wa)
	extz	xhl
	ld	a, (xde+4)
	ld	xbc, 0:i3
	ld	c, a
	ld	xwa, xhl
	call	Math_Multiply32
	srl	xhl, 7
	cp	(xsp), 64
	jr	nc, Voice_Freq_ComputeRight_Raw_HiRange
	cp	xhl, 0x3fff
	jr	ule, Voice_Freq_ComputeRight_Raw_StoreLow
	ld	xhl, 0x3fff
; Index < 0x40: store the clamped value to the low-bank staging word 0x045206.
Voice_Freq_ComputeRight_Raw_StoreLow:
	ld	(Payload_Bss_Start+0x6390:24), hl
	jr	Voice_Freq_ComputeRight_Raw_Return
; Index >= 0x40: clamp for the upper voice bank.
Voice_Freq_ComputeRight_Raw_HiRange:
	cp	xhl, 16383
	jr	ule, Voice_Freq_ComputeRight_Raw_StoreHigh
	ld	xhl, 16383
; Store the clamped value to the high-bank staging word 0x04520A.
Voice_Freq_ComputeRight_Raw_StoreHigh:
	ld	(Payload_Bss_Start+0x6394:24), hl
; Frame teardown and return.
Voice_Freq_ComputeRight_Raw_Return:
	inc	2, xsp
	ret
; Clamp WA to at most 0x00FF using an unsigned compare (no lower bound); the result is
; also copied to XHL. 12 bytes, ends with 'ret' at 0x02324D.
; Unreferenced: no call, calr, jp or 24-bit pointer to 0x023242 exists anywhere in the
; 0x30000-byte image. It sits inside the raw .byte blob that the LLVM source emits for
; Voice_Freq_ComputeRight_Raw, which is why it carries no symbol at all today.
; NAMING NOTE: this proposal follows the CamelCase style of its neighbours rather than
; the UPPER_SNAKE house style - see the last [UNCERTAIN] entry.
Voice_Clamp_Byte_Unsigned:
	cp	wa, 255
	jr	ule, Voice_Clamp_Byte_Unsigned_Return
	ldw	wa, 255
; Copy the clamped value to XHL and return.
Voice_Clamp_Byte_Unsigned_Return:
	ld	hl, wa
	ret

; TWO-STAGE LOOKUP OF A TONE-COLOUR / WAVE INDEX.
; In: XWA = a 0..0xFF value, C = a byte whose top 3 bits select the group.
; group = C >> 5; the byte table at 0x0106E4 indexed by XWA gives a row offset, and the
; final byte is read from the ROM table at 0x00FFE4 at (group << 8) + row.
; Out: XHL (zero-extended byte). Four callers at 0x02B316, 0x02B336, 0x02B475, 0x02B492.
Voice_Colour_LookupIndex:
	and c, 0xE0
	srl c, 5
	extz xwa
	ld xde, Voice_Colour_RowOffset_Table
	add xde, xwa
	ld a, (xde)
	ld e, a
	extz de
	ld a, c
	extz wa
	sla wa, 8
	add wa, de
	lda xbc, (Voice_Colour_TransferCurves:24)
	ld	l, (xbc+wa)
	extz hl
	ret

; Clamp the control value (WA bits 8..14) against the stacked high limit at (XSP+0x06).
Voice_Colour_ClampUpper:
	and wa, 0x7F00
	srl wa, 8
	ld l, (xsp + 6)
	extz hl
	cp wa, hl
	jr ule, Voice_Colour_ClampLower
	ld a, (xsp + 6)
	extz wa
	jr Voice_Colour_InterpolateDelta

; Clamp against the low limit in E.
Voice_Colour_ClampLower:
	ld l, e
	extz hl
	cp wa, hl
	jr nc, Voice_Colour_InterpolateDelta
	ld a, e
	extz wa

; (clamped - BC) * stacked depth (XSP+0x04), >> 5; 'retd 4' pops both stacked args. Structurally identical to Pan_ScaleWithVelocity.
Voice_Colour_InterpolateDelta:
	extz bc
	ld de, wa
	sub de, bc
	ld l, (xsp + 4)
	exts hl
	ld wa, hl
	muls	xwa, de
	ld hl, wa
	sra hl, 5
	retd 0x4

; Clamp WA to [0, 0xFF] (signed compare). Out: WA and XHL.
Voice_Clamp_Byte_WA:
	cp wa, 0xFF
	jr le, Voice_Clamp_Byte_WA_LowBound
	ldw wa, 0xFF
	jr Voice_Clamp_Byte_WA_Return

; Low-bound test.
Voice_Clamp_Byte_WA_LowBound:
	cp wa, 0:i3
	jr ge, Voice_Clamp_Byte_WA_Return
	ld wa, 0:i3

; Copy to XHL and return.
Voice_Clamp_Byte_WA_Return:
	ld hl, wa
	ret

; ---------------------------------------------------------------------------------------
; THE TONE GENERATOR STAGING BLOCK AT 0x0451CC
;
; The words from 0x0451CE upwards are staged copies of IC303's per-voice registers. The
; firmware fills them from many places and ToneGen_WriteVoiceParams then bursts the block
; to the chip, so every one of these addresses is a register by another name:
;
;     0x0451CC -> +0x000   CONTROL / gate -- PRESENT IN THE FORMAT, UNUSED HERE. See below.
;     0x0451CE -> +0x040   recording selector, (class << 12) | entry
;     0x0451D0 -> +0x080   output level + the 3-bit descriptor field (built below)
;     0x0451D2 -> +0x0C0   coarse level + expression
;     0x0451D4 -> +0x100   TVF cutoff
;     0x0451D6 -> +0x140   TVF depth / bias
;     0x0451D8 -> +0x180   pan, 0x0040 = centre
;     0x0451DA -> +0x400   absolute log pitch          (Pitch_Emit_Reg400)
;     0x0451DC -> +0x440
;     0x0451DE -> +0x480
;     0x0451E0 -> +0x4C0   oscillator config + slot
;     0x0451E2 -> +0x500   detune / bend pair
;     0x0451E4 -> +0x800   amplitude envelope segment 0
;     0x0451E6 -> +0x840   amplitude envelope segment 1
;     0x0451E8 -> +0x880   amplitude envelope segment 2
;     0x0451EA -> +0x8C0   amplitude envelope segment 3
;     0x0451EC -> +0x900   second envelope, segment 0
;     0x0451EE -> +0x940   second envelope, segment 1
;     0x0451F0 -> +0x980   second envelope, segment 2
;     0x0451F2 -> +0x9C0   third envelope, segment 0
;     0x0451F4 -> +0xA00   third envelope, segment 1
;     0x0451F6 -> +0xA40   third envelope, segment 2
;
; RECORD TAIL, 0x0451F8..0x04520E = words 22..33 of the same 34-word (0x44-byte) record.
; ToneGen_WriteVoiceParams does not transmit them, but at THIS base they are not inert, and
; that is what sizes the record from this file instead of by analogy with the ROM templates:
;     0x045204 (+0x38, word 28)  TG register 0x1C0; EGEnv_Compute_B writes it
;     0x045206 (+0x3A, word 29)  EGEnv_Compute_B_Simple writes it; it reaches the chip
;                                through the ToneGen_WriteExtParam* writers, not this burst
;     0x04520E (+0x42, word 33)  the last word of the record; the secondary-pitch path
;                                writes it and reads it straight back
;                                (`stw_da 0x04520e, xwa` / `ldw_da xiz, 0x04520e`)
;
; Assembled from this file's own scattered annotations (the +0x0C0, +0x100/+0x140,
; +0x180/+0x4C0, +0x400, and the 0x8C0..0xA40 zeroing routine all name their targets) plus
; a capture of every write the chip receives over 1705 note-ons of the built-in demo, which
; agrees register by register.
;
; THE +0x000 CONTROL WORD IS PART OF THE BLOCK FORMAT BUT NOT OF THIS BLOCK'S TRAFFIC.
; ToneGen_Config_Init (0x02DFCF) hands a 68-byte block to ToneGen_WriteVoiceParams and then
; passes that block's WORD 0 to ToneGen_WriteSingleReg with WA = the bare channel, i.e. to
; register (0x0000 + ch) -- so offset +0x00 of a 68-byte block is the CONTROL word. The
; block it is handed is the DRAM copy at (XSP + 2): DSP_Config_Init copies 0x22 words from
; ROM 0x00F8D5 into DRAM 0x2AA4 first. (ROM 0x00F8D5 starts with 0x1200; the dormant probe
; at 0x02E0EE is the only site that hands a ROM pointer directly, `lda xwa, 0x00f919`,
; whose template starts with 0xF000.) The run-time block is different: ToneGen_WriteVoiceParams
; reads from +0x02 upwards and never touches +0x00, and a grep for 0x0451CC in this file
; finds only `lda_24 xbc, 0x0451cc` pointer loads -- no store. At run time the control word
; lives, IN THE VOICE-ENGINE PATHS, in the LIVE SLOT RECORD at 0x0430BB + slot*0x47
; (record +0x2D) instead, built by Voice_Build_GateCommand (0x025589) / _NoPartial
; (0x0255F3) and issued as a separate write after the burst. The auxiliary 8-voice pool is
; the exception: its run-time block at 0x3B1C is refilled by `ldirw` from ROM 0x012115 and
; its OWN word 0 is sent (ToneGen_SetupPolyVoice, 0x0355AD). The command set and the demo capture are documented at 0x025589.
;
; ---------------------------------------------------------------------------------------
; WHAT +0x040 SELECTS: THE WAVE ROM'S OWN DIRECTORY -- WHICH THIS FIRMWARE NEVER READS
;
; NEGATIVE RESULT FIRST, because it is the answer to the obvious question: nothing in this
; ROM, nor in the sub-CPU boot ROM, nor in the main program, walks the waveform ROMs.
; IC304-IC307 hang off IC303 and are in no CPU's address space:
;
;   * THE SCHEMATICS. technics-docs/tone-generator.md:300,321 reads the service manual's Tone
;     Generator Sections A and B as "Waveform ROMs (IC304-307) --> Tone Generator LSI
;     (IC303)". The only CPU-facing windows on IC303 are its register file and its keybed
;     side, and technics-docs/kn7000-expansion-and-wave-dump.md states plainly that NONE of
;     them is a wave-memory read port.
;
;   * THIS PAYLOAD'S OWN TRAFFIC, counted over the whole file. Two windows on IC303,
;     selected by P6.7 driving A23:
;         0x100000  register-ADDRESS latch  139 writes, 1 read (ToneGen_Read_Register,
;                                           documented below)
;         0x100002  register DATA port      137 direct-addressing writes, plus one more
;                                           through a pointer set up in
;                                           ToneGen_ReadPitch_Compute; NEVER read
;         0x110000  keybed / voice DATA     2 reads, no writes
;         0x110002  keybed / voice STATUS   2 reads, no writes
;     The five reads live in three routines -- ToneGen_Read_Register (the active-voice
;     bitmap, or a channel's envelope level), Keybed_Read_Event (one key event) and
;     ToneGen_Poll_Read (one voice's on/off bit, kept in the bitmap at 0x01F41C). Not one
;     of them returns a wave byte, and there is no port through which one could.
;
;   * THE BOOT ROM. subcpu/boot/kn5000_subcpu_boot.s: 29 writes to 0x100000, 28 to
;     0x100002, one read at 0x100004; on the other window one write to 0x110002 and one
;     read each of 0x110002 and 0x110000. Same story, no wave read.
;
;   * THE MAIN PROGRAM. In v7, v9 and v10 the value 0x100000 only ever appears as an
;     IMMEDIATE -- `cp xiz, 0x100000`, `cp xbc, 0x100000`, `add xbc, 0x100000`, i.e. the
;     1 MB DRAM top bound -- never as a direct-addressing access, and 0x110000 is
;     FDC_MAP__BASE_ADDR (maincpu/fdc_constants.s:16). The main CPU has no window on IC303.
;
;   * THE MACHINE'S OWN WAVE ROM CHECK (service test 6, chord E3+E4) is ACOUSTIC: the ROMs
;     are made to sound and a technician listens for distortion. See
;     technics-docs/test-modes.md and technics-docs/kn7000-expansion-and-wave-dump.md. The
;     KN7000 does have a CPU-visible wave read port; the KN5000 has no equivalent.
;
; [INFERENCE] So the directory walk happens inside IC303. That is a conclusion by
; elimination -- nobody has watched IC303 do it -- but the firmware's whole contribution to
; choosing a recording is provably one 16-bit index, and the rest of this block documents
; the format that index is resolved against, because none of the per-voice work in this
; file means anything without it.
;
; THE SELECTOR. 0x0451CE is shadow+0x02 of the voice-engine staging block, the FIRST word
; ToneGen_WriteVoiceParams pushes (register 0x0040 + ch). Its layout, validated in
; kn7000_mame/notes/kn5000-structural-validation.md section 0, is
;
;     class = word >> 12       selects one 1 MB PAGE of one 4 MB wave socket
;     entry = word & 0x0FFF    plain 0-based index into that page's directory, base 0
;
; and the firmware treats it as opaque. Every instruction in this ROM that touches 0x0451CE
; is accounted for: eight stores (the six WaveSel_Emit_ZoneRecord_S* variants and
; WaveSel_StageB_Store_Reg040, each copying word 0 of a zone record verbatim, plus
; Voice_InitVoiceState storing 0), the read half of WaveSel_StageB_Store_Reg040's
; read-modify-write, and the `lda_24 xwa, 0x0451ce` that hands the word to
; Voice_Slot_ApplyPitchJitter. Nothing splits the word, range-checks the entry against a
; count, or dereferences anything with it.
;
; * BUT IT IS NOT ALWAYS EMITTED AS STORED, AND THAT IS AN OPEN PROBLEM. Two sites change
; it after the zone record has been copied in:
;   - WaveSel_StageB_Store_Reg040 DOUBLES the top nibble in place when bit 2 of the global
;     audio-mode word 0x041343 is set -- class *= 2, i.e. a page/bank re-select;
;   - Voice_Init_Type1 calls Voice_Slot_ApplyPitchJitter(0x0451CE) immediately after
;     WaveSel_StageB_Build_Reg040, and that adds (tick & 7) to the WHOLE word.
; Under entry = bits[11:0] the second one picks a DIFFERENT directory entry on every note
; that goes through Voice_Init_Type1. On page 0 the consecutive entries of a shared-wave
; run are different KEY ZONES of one recording (185-190, 191-197), so a +0..7 step there
; would not be a subtle effect. Either the low bits are not a plain entry index on this
; path, or the path is not what it looks like. UNRESOLVED -- do not quote the index model
; as settled without addressing it.
;
; A SECOND TENSION, same register from a different block: ToneGen_SetupPolyVoice fills the
; auxiliary 8-voice block at 0x3B1C, whose +0x02 comes from the octave-indexed table at
; 0x01217D and is annotated in this file as a pitch/rate constant. Under the decode above
; that word is instead a wave selector chosen per octave, which is what a multisample looks
; like. Both readings cannot be right; nobody has checked which.
;
; THE PAGE FORMAT, measured on kn5000_waveform_rom.ic307 (SHA1
; 4b511bff6625f4655cabd96a263bf548d2ef4bf7), the only hardware-rooted wave dump that
; exists -- the files circulating as IC304/IC305/IC306 are mostly-0xFF reads, and
; mame_driver/src/mame/matsushita/kn5000.cpp:771-773 declares all three NO_DUMP. Each 1 MB
; page is independently self-describing:
;
;     u16 param_ptr, u16 wave_off      x N     ; the directory, at page offset 0
;     ... variable-length parameter records ...
;     ... signed 16-bit little-endian PCM ...
;
;     N          = u16[page + 0] / 4           ; entry 0's param_ptr points just past the
;                                              ; directory, so THE DIRECTORY DECLARES ITS
;                                              ; OWN LENGTH -- there is no count field
;     PCM start  = page + wave_off * 16        ; 16-byte (8-sample) granule
;     PCM end    = page + 16 * (next strictly greater wave_off in the directory)
;     param rec  = page + param_ptr .. page + (next strictly greater param_ptr)
;
; wave_off is a u16 scaled by 16, so it reaches 0x0FFFF0 and no further: the field
; addresses exactly 1 MB, which is [INFERENCE] why the page is 1 MB, and why a 4-bit class
; field spans exactly the 16 MB of four 4 MB sockets. IC307's four pages, all four measured
; (columns as published in kn5000-structural-validation.md section 1):
;
;   page  base       N     directory      last param_ptr  first PCM   last wave
;   0     0x000000   198   0x0000-0x0317  0x1A26          0x001A30    0x0FEF60
;   1     0x100000   168   0x0000-0x029F  0x182C          0x001840    0x0FEB60
;   2     0x200000  1072   0x0000-0x10BF  0x2694          0x0026A0    0x0FFEE0
;   3     0x300000    57   0x0000-0x00E3  0x022C          0x000240    0x0FF5C0
;
; 1495 directory slots, 1413 unique wave offsets, in one 4 MB chip. Both columns rise
; monotonically except three entries on page 1 (79, 82, 85) whose wave_off steps backwards
; to re-use an earlier recording. The last parameter record of a page starts 10-20 bytes
; before the first PCM byte, its tail zero-padded up to the granule.
;
; IT IS SELF-VALIDATING. The first word of every parameter record repeats that entry's own
; wave_off: 198/198, 168/168, 1072/1072, 57/57 -- flagcensus.py prints
; "back-reference OK: 1495 / 1495", no exceptions. That redundancy is the cheapest possible
; check that a (class, entry) pair landed on a real slot, and it is also what proves the
; four-page reading is not pattern-matching on noise: mis-framed data cannot satisfy a
; back-reference 1072 times in a row.
;
; WHAT A PARAMETER RECORD CONTAINS. The redundant wave_off word, then zero or more
; { value:8, flag:8 } pairs (little-endian word = value | flag << 8). flagcensus.py counts
; 7203 pairs over the 1495 records -- that total includes the all-zero words padding each
; page's last record -- and waverec.py's size histograms show 964 records with no pairs at
; all (960 of them on page 2, which holds short one-shot material) and the largest record
; at 850 bytes.
;   flag 0x00        KEY-SPLIT BOUNDARY, usually listed high-to-low within a record. The
;                    unit is NOT MIDI: against the firmware's own zone table the relation
;                    is key = 1.5 * (value - 0x28), i.e. one unit = 1/8 octave, and
;                    successive zones of a multisample step by 8 (worked table in
;                    kn5000-structural-validation.md section 4.2 -- MEASURED relation,
;                    INFERRED unit interpretation).
;   flag 0x01-0x2F   PER-ZONE FINE TUNE, values clustered in 0xEA-0xFF, i.e. small negative
;                    trims. Page-0 records 180 and 181 are 53 and 130 such pairs and
;                    nothing else: a per-key detune table across the keyboard, exactly what
;                    a stretched multisample needs. See
;                    kn7000_mame/notes/kn5000-ic307-content-map.md section 3.2.
;   flag bit 7       END OF RECORD. flagcensus.py counts 286 pairs with bit 7 set, and its
;                    per-record last-pair histogram accounts for all 286: bit 7 never
;                    appears on a pair that is not its record's last. Not every record uses
;                    it -- the extent is delimited by the next param_ptr regardless.
;   flag bit 6       A MARKER, 258 occurrences, NOT decoded. content-map section 3.3 groups
;                    0xC0/0xC5/0x80/0x40 as terminators/markers without settling bit 6.
; NO ROOT NOTE AND NO LOOP POINTS ARE STORED HERE [INFERENCE]: every field in every record
; is a single byte, while a loop point into a wave of tens of thousands of samples needs at
; least 16 bits, and loopprobe.py found none. The pitch origin comes from the firmware side
; (the tone database's zone records and this file's pitch chain). Note that
; kn5000-structural-validation.md section 7 leaves open that some of the flag != 0x00 bytes
; are IC303's own per-wave loop/envelope/tune parameters.
;
; MULTISAMPLES SHOW UP AS RUNS OF CONSECUTIVE ENTRIES sharing one wave_off with shifted
; split lists -- page 0 entries 185-190 (wave 0xFCA6) and 191-197 (wave 0xFEF6), each
; successive entry's splits shifted by +8 units. The firmware's own key zones for those
; same entries tile the keyboard contiguously with no overlap (section 4.1): a cross-check
; between two ROMs written by different tools.
;
; PROVENANCE. Format, four-page split and the class decode:
; kn7000_mame/notes/kn5000-structural-validation.md (2026-07-25) and
; kn7000_mame/notes/kn5000-ic307-content-map.md; re-runnable probes in
; kn7000_mame/tools/kn5000-rom-structure/ (waverec.py prints the per-page counts and the
; record-size histograms, flagcensus.py the back-reference check and the flag census,
; loopprobe.py is the loop-point negative). The class -> page assignment was PREDICTED from
; the firmware alone -- max(entry)+1 over the 1444 (class, entry) pairs the table-data ROM's
; zone records produce -- and then checked against IC307's self-declared counts: class 4
; needs 198 and page 0 has 198, class 5 needs 168 and page 1 has 168, class 7 needs 57 and
; page 3 has 57. Three exact hits, zero out-of-range entries; a pitch regression of class 7
; onto page 3 gives slope 1.003 / R^2 0.998, where every wrong page collapses to slope ~0
; (section 4.3). [INFERENCE] hence page = class & 3, bank = (class >> 2) & 3, IC307 = bank 1.
; STILL OPEN: WHICH PHYSICAL SOCKET IS BANK 0. That is a wiring fact, not a decoding one,
; and it cannot be settled until one of IC304/IC305/IC306 is really dumped; section 7 of
; the validation note gives the falsifiable prediction that will identify it.
; ---------------------------------------------------------------------------------------
;
; THE THREE ENVELOPES share one word format, (target << 8) | rate.
; MEASURED (demo capture, 1705 note-ons; harness in kn7000_mame,
; tools/rigs/kn5000_demo_capture.lua): segments 0 and 1 took extra writes during a note,
; segment 2 exactly one write per note-on, and segment 3 of the amplitude envelope was used
; on about 4% of notes, decaying to zero while segment 2 held a sustain level; on the rest
; it was left zero, which means "unused" rather than "fall silent".
; ★ THE ONCE-PER-NOTE-ON FIGURE IS A PROPERTY OF THAT CAPTURE, NOT OF THE CODE: the writer
; census below finds three routines besides the note-on burst that can write segment 2, two
; of which run while a voice is sounding.
;
; [INFERENCE] RATE 0 PROBABLY MEANS "GO TO THE TARGET NOW", not "hold there". The argument is
; entirely firmware-side: Voice_EnvelopeRate_Table (0x011963) has exactly one entry below 4
; (entry 0 = 0x00), and all four envelope-1 builders floor segment 1's rate at 4, so that
; floor exists for no purpose other than keeping 0 off that one segment -- while segments 0
; and 2 are left free to carry it. See Voice_Calc_LevelPair_PatchAtk_ClampDepth.
; NOT MEASURED: no rate-to-time law and no time constant for IC303 has been captured, so
; nothing here fixes what any rate value other than 0 does, or which end of 0x00..0x7F is
; fast. Do not turn the ordering argument above into a number.
;
; WHY THE TEN ENVELOPE REGISTERS ARE REFRESHED AT DIFFERENT RATES. Bank = register number *
; 0x40, so these ten words are IC303 registers 0x20..0x29 (the same conversion is spelled out
; at ToneGen_WriteVoice_6Words, _Pan_Pair, _EnvLevel and _Reg11). Every routine that talks to
; the chip latches 0x100000 with `add wa, <bank>` and then writes 0x100002, so counting that
; one opcode gives the writer list per bank.
; ★ COUNT IT IN THE ROM IMAGE, NOT IN THIS FILE: at the time this was written, a grep for
; `add wa, 0x8..` here missed two real bank writers that were still emitted as `.byte` (see
; the now-resolved MISLABELLED notes at 0x0280FE-0x028838 and 0x028F75-0x029E30, both fully
; converted to instructions as of 2026-09-02). Scanning
; kn5000_subprogram_v142.rom for the opcode bytes D8 C8 <lo> <hi> gives:
;
;   seg 0   +0x800 r0x20 : 24 sites     seg 1   +0x840 r0x21 : 29 sites
;           +0x900 r0x24 :  3 sites             +0x940 r0x25 :  3 sites
;           +0x9C0 r0x27 :  3 sites             +0xA00 r0x28 :  3 sites
;   seg 2   +0x880 r0x22 :  4 sites  -- ToneGen_WriteVoiceParams, ToneGen_WriteEnvSegments,
;                                      ToneGen_WriteSegRegs_SameLevel, and
;                                      ToneGen_WriteVoice_Reg21_Reg22 (0x028170)
;           +0x980 r0x26 :  1 site   -- ToneGen_WriteVoiceParams
;           +0xA40 r0x29 :  1 site   -- ToneGen_WriteVoiceParams
;   +0x8C0  r0x23        :  1 site   -- ToneGen_WriteVoiceParams
;
; So segment 2 of envelopes 2 and 3 (r0x26, r0x29) and r0x23 have exactly ONE writer each:
; whatever ToneGen_WriteVoiceParams leaves in them at note-on is what the chip keeps for the
; whole note, and a model must not expect them to be refreshed.
; ★ SEGMENT 2 OF THE AMPLITUDE ENVELOPE (r0x22) IS NOT IN THAT CLASS. Three routines besides
; the note-on burst write it, and two of them can run while a voice is sounding:
; ToneGen_WriteSegRegs_SameLevel, called from Voice_AllNotes_SustainRetrigger_BranchB/BranchD
; (the sustain-pedal walk over live voices) as well as from Voice_Reload_Levels_BranchA/C,
; and ToneGen_WriteVoice_Reg21_Reg22, called from AudioChannel_AllVoices_Update_PanShift (an
; audio-channel command handler that walks a part's live voices). The third,
; ToneGen_WriteEnvSegments, is reached only from Voice_Reload_Levels_BranchD. The capture
; quoted above saw r0x22 written exactly once per note-on, which says those three branches
; did not fire in it -- not that they cannot fire.
;
; SEGMENTS 0 AND 1 HAVE A SECOND SHADOW. The per-tick path keeps its own copies just above
; the block and ToneGen_WriteLevelBurst (0x02D436) pushes them to the same six registers:
;
;     0x0451F8 -> +0x800   0x0451FA -> +0x840   built by Voice_Calc_LevelPair_EGA 0x026769
;     0x0451FC -> +0x900   0x0451FE -> +0x940   built by Voice_Calc_LevelPair_EGB 0x026975
;     0x045200 -> +0x9C0   0x045202 -> +0xA00   built by Voice_Calc_LevelPair_EGC 0x026AAA
;
; No register outside that set has a second shadow. The three builders do NOT agree on the
; low byte: EGA emits (level << 8) with bit 7 forced on the +0x800 word and clear on +0x840,
; so its rate field is 0; EGB and EGC emit (level << 8) | Detune_ScaleSymmetric(...), a
; signed -0x7F..+0x7F byte that is usually NOT 0 and often has bit 7 set, and each of them
; writes the SAME word to both of its two registers.
;
; TARGET POLARITY: in the amplitude envelope the high byte is an ATTENUATION and 0xFF is
; SILENT. (1) Both parameter curves descend from 0xFF -- Voice_LevelPair_AttackCurve
; (0x011899, 0xFF..0x09) and Voice_EnvelopeLevel_Curve (0x0118FE, 0xFF..0x04). Note neither
; curve can produce 0x00: a target of 0x00 is off the loud end of the curve, not a value the
; builders ever emit. (2) The firmware's mute idiom -- 11 sites writing r0x21 <- 0xFF00 and
; r0x20 <- 0xFF80 -- is called the documented "mute" level word at Voice_SetPitch. (3)
; Voice_Step_ExprRamp counts toward 0xFF00 on r0x21 and releases the slot on arrival, and
; Voice_Calc_LevelPair_Full_CheckMax reserves 0xFF as "fully attenuated / voice finished".
; [INFERENCE] proofs (2) and (3) reach banks +0x800/+0x840 only. Envelopes 2 and 3 share the
; word format and the same 0x0118FE curve, so the same polarity is carried over to
; +0x900..+0xA40 by construction; no firmware site writes a mute word to those banks.
; ★ OPEN CONFLICT: technics-docs/tone-generator.md reads +0x0840/+0x0880 as "Pan Left/Right,
; 0x00 = silent" -- the opposite polarity. That document and this block disagree, and the
; disagreement is not settled here.
;
; THE BUILDERS (all take XWA = voice-slot record; paramA = the u32 at slot+0x17, tonerec =
; the u32 at slot+0x23):
;     amplitude  r0x20..0x22   Voice_Calc_LevelPair_PatchAtk / _FixedAtk / _Full / _Mono
;     second     r0x24..0x26   Voice_Level_ComputeTriplet  0x023AD0
;     third      r0x27..0x29   Voice_StereoLevel_Compute   0x024664
;     r0x23                    Voice_PortaLevel_Compute    0x0248D5 -- NOT part of the
;                              amplitude family: its high byte is Detune_ScaleSymmetric of
;                              paramA+0x08 and its low byte Detune_ScaleSymmetric of
;                              paramA+0x3D + paramA+0x3E, i.e. the same parameter family the
;                              THIRD envelope's rate bytes use, not the +0x27..+0x2C run.
;
; BUILD AND STORE THE VOICE OUTPUT-LEVEL WORD (tone generator register +0x080).
; In: XWA = voice work record, BC = starting level.
;
; LEVEL, bits 11..0: adds (record+0x23)->[0x0C] and (record+0x23)->[0x10] and
; (record+0x33), clamps to 0..0xFF, uses the result*2 to index the u16 table at 0x010764
; and doubles that. The table is a logarithmic law, 256 counts per octave.
;
; BITS 14..12 ARE NOT PAN -- pan is a separate register, +0x180, staged at 0x0451D8.
; This field is three bits of per-recording data, from one of two sources chosen by bit 7
; of the SELECTED ZONE RECORD's byte +0x02:
;
;     bit 7 SET   -> field = (zone_record[+0x02] >> 4) & 7    the descriptor's own bits
;     bit 7 CLEAR -> field = T[folded note mod 12]            u16 table at 0x00FBE4,
;                                                             T[n] = floor(2*(n mod 12)/3)
;
; That zone record is the same one whose first word becomes the +0x040 selector and whose
; word at (stride-2) is the multisample's pitch trim -- so three bits of the multisample
; descriptor travel to the chip verbatim, which is the only per-recording data that does.
;
; MEASURED, 2026-08-20: over a demo capture, the override branch predicts the value the
; chip is given 196 times out of 196 for selectors reachable from exactly one zone record.
; The low nibble of byte +0x02 is zero across all 1444 selectors the firmware's tables
; produce, which is the field structure showing itself in the data.
;
; bit15 is forced here, but it is not data: it is the parameter-latch commit strobe that
; ToneGen_WriteVoiceParams raises on a burst's first word and lowers on its last, so this
; SET is redundant with the writer's own.
;
; No caller found by a call/calr scan over the ROM (reached indirectly).
Voice_Build_OutputLevel:
	push xiz
	ld xiz, xwa
	ld xwa, (xiz + 35)
	add bc, (xwa + 12)
	ld xwa, (xiz + 35)
	add bc, (xwa + 16)
	add bc, (xiz + 51)
	ld wa, bc
	calr Voice_Clamp_Byte_WA
	ld bc, hl
	add bc, bc
	lda xwa, (Voice_OutputLevel_Table:24)
	ld	wa, (xwa+bc)
	add wa, wa
	ld bc, wa
	ld xwa, (xiz + 15)
	bitm 7, (xwa + 2)
	jr z, Voice_Build_OutputLevel_NoPanOverride
	ld xwa, (xiz + 15)
	ld a, (xwa + 2)
	extz wa
	and wa, 0x70
	sll wa, 8
	jr Voice_Build_OutputLevel_Store

; No descriptor override (bit 7 of zone_record[+0x02] clear): take bits 14..12 from the
; 0x00FBE4 table, indexed by the folded note.
Voice_Build_OutputLevel_NoPanOverride:
	ld wa, (xiz + 6)
	srl wa, 8
	extz xwa
	add xwa, xwa
	ld xde, Voice_Reg080_NoteField_Table
	add xde, xwa
	ld wa, (xde)

; OR the level and the bits-14..12 field together, force the commit strobe and store to
; 0x0451D0 (tone generator register +0x080).
Voice_Build_OutputLevel_Store:
	or bc, wa
	set 15, bc
	ld (Payload_Bss_Start+0x635a:24), bc
	pop xiz
	ret

; Clamp WA to [0, 0xFF] using an unsigned upper compare. Out: WA and XHL.
Voice_Clamp_Byte_HL:
	ld bc, wa
	cp bc, 0xFF
	jr ule, Voice_Clamp_Byte_HL_LowBound
	ldw wa, 0xFF
	jr Voice_Clamp_Byte_HL_Return

; Low-bound test.
Voice_Clamp_Byte_HL_LowBound:
	cp wa, 0:i3
	jr ge, Voice_Clamp_Byte_HL_Return
	ld wa, 0:i3

; Copy to XHL and return.
Voice_Clamp_Byte_HL_Return:
	ld hl, wa
	ret

; AGE A PART'S RETRIGGER/VELOCITY-PHASE COUNTER AGAINST THE MASTER TICK.
; In: A = part index. Per-part stride 0x011F:
;   0x041481 + part*0x011F  = 32-bit timestamp of the last update
;   0x041485 + part*0x011F  = phase counter byte
;   0x041486 + part*0x011F  = phase output byte (0x00 / 0x10 / 0x20)
; Master tick is the 32-bit counter at 0x1040. Delta 0 -> only refresh the timestamp;
; delta >= 0x19 (25 ticks) -> reset both counter and phase to 0; otherwise bump the
; counter and map 1 -> 0x10, 0 -> 0x00, anything else -> 0x20.
; Callers 0x02C734, 0x02C838, 0x02C93C, 0x02CAA5.
Voice_Env_UpdateVelocityCounters:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Payload_Bss_Start+0x260b:24)
	ld xhl, (4160:16)
	sub	xhl, (xde+bc)
	jrl z, Voice_Env_UpdateVelocity_Store
	cp xhl, 0x19
	jr nc, Voice_Env_UpdateVelocity_Reset
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Payload_Bss_Start+0x260f:24)
	exts xbc
	add xbc, xde
	incm8 1, (xbc)
	ld c, (xbc)
	cp c, 1:i3
	jr z, Voice_Env_UpdateVelocity_SetPhase1
	cp c, 0:i3
	jr nz, Voice_Env_UpdateVelocity_SetPhase2
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Payload_Bss_Start+0x2610:24)
	ld	(xde+bc), 0x00
	jr Voice_Env_UpdateVelocity_Store

; Counter reached 1: phase byte = 0x10.
Voice_Env_UpdateVelocity_SetPhase1:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Payload_Bss_Start+0x2610:24)
	ld	(xde+bc), 0x10
	jr Voice_Env_UpdateVelocity_Store

; Counter is neither 0 nor 1: phase byte = 0x20.
Voice_Env_UpdateVelocity_SetPhase2:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Payload_Bss_Start+0x2610:24)
	ld	(xde+bc), 0x20
	jr Voice_Env_UpdateVelocity_Store

; Timed out (>= 0x19 ticks): clear both the counter and the phase byte.
Voice_Env_UpdateVelocity_Reset:
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Payload_Bss_Start+0x260f:24)
	ld	(xde+bc), 0x00
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xde, (Payload_Bss_Start+0x2610:24)
	ld	(xde+bc), 0x00

; Refresh the timestamp from the master tick at 0x1040 and return.
Voice_Env_UpdateVelocity_Store:
	extz wa
	muls wa, 0x11F
	ld bc, wa
	lda xde, (Payload_Bss_Start+0x260b:24)
	ld xwa, (4160:16)
	ld	(xde+bc), xwa
	ret

; VELOCITY-SWITCH DISPATCHER, TYPE 0/1 (and entry point for type 2).
; In: A = part index (0, 1 or 2 selects the variant), C = sub-case 0..3.
; First clears the per-part program byte at 0x0413D5 + part*0x011F. A == 2 diverts to
; Voice_Env_ApplyVelocity_Type2. For A == 0 or 1 the sub-case in C picks which flag is
; tested: cases 0 and 1 test the global config byte at 0x04134B (bit3, then bit0/bit1
; via BitTest_*), cases 2 and 3 test bit3 / bit0 / bit1 of the per-part byte at
; 0x04137F + part*0x011F. If the resulting predicate L is non-zero,
; Instrument_LookupProgram_HiNibble installs the program byte.
; Callers 0x02C72B, 0x02C82F, 0x02C933, 0x02CA9C.
Voice_Env_ApplyVelocity_Type0:
	dec 2, xsp
	ld (xsp), a
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x255f:24)
	ld	(xde+wa), 0x00
	ld a, (xsp)
	cp a, 2:i3
	jrl z, Voice_Env_ApplyVelocity_Type2
	cp a, 1:i3
	jr z, Voice_Env_VelocityDispatch_c1
	cp a, 0:i3
	jrl nz, Voice_Env_ApplyVelocity_Return

; Sub-case selector for the type-0/1 variant.
Voice_Env_VelocityDispatch_c1:
	cp c, 3:i3
	jr z, Voice_Env_VelocityDispatch_c3
	cp c, 2:i3
	jr z, Voice_Env_VelocityDispatch_c2
	cp c, 1:i3
	jr z, Voice_Env_VelocityDispatch_c1_Bit1
	cp c, 0:i3
	jrl nz, Voice_Env_VelocityDispatch_ClearFlag
	bit 3, (Payload_Bss_Start+0x24d5:24)
	jr z, Voice_Env_VelocityDispatch_c0_NoBit3
	ld l, 0x0:opc
	jrl Voice_Env_VelocityDispatch_Gate

; Case 0, config bit3 clear: predicate = bit0 of the 0x04134B config byte.
Voice_Env_VelocityDispatch_c0_NoBit3:
	ld a, (Payload_Bss_Start+0x24d5:24)
	extz wa
	calr BitTest_Bit0_L
	jr Voice_Env_VelocityDispatch_Gate

; Case 1: test bit3 of the 0x04134B config byte.
Voice_Env_VelocityDispatch_c1_Bit1:
	bit 3, (Payload_Bss_Start+0x24d5:24)
	jr z, Voice_Env_VelocityDispatch_c1_NoBit3
	ld l, 0x0:opc
	jr Voice_Env_VelocityDispatch_Gate

; Case 1, bit3 clear: predicate = BitTest_Mode2_L of the config byte.
Voice_Env_VelocityDispatch_c1_NoBit3:
	ld a, (Payload_Bss_Start+0x24d5:24)
	extz wa
	calr BitTest_Mode2_L
	jr Voice_Env_VelocityDispatch_Gate

; Case 2: test bit3 of the per-part byte at 0x04137F + part*0x011F.
Voice_Env_VelocityDispatch_c2:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2509:24)
	bit	3, (xbc+wa)
	jr z, Voice_Env_VelocityDispatch_c2_Trigger
	ld l, 0x0:opc
	jr Voice_Env_VelocityDispatch_Gate

; Case 2, bit3 clear: predicate = bit0 of that per-part byte.
Voice_Env_VelocityDispatch_c2_Trigger:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2509:24)
	ld	a, (xbc+wa)
	extz wa
	calr BitTest_Bit0_L_v2
	jr Voice_Env_VelocityDispatch_Gate

; Case 3: test bit3 of the per-part byte.
Voice_Env_VelocityDispatch_c3:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2509:24)
	bit	3, (xbc+wa)
	jr z, Voice_Env_VelocityDispatch_c3_Trigger
	ld l, 0x0:opc
	jr Voice_Env_VelocityDispatch_Gate

; Case 3, bit3 clear: predicate = BitTest_Mode2_L of that per-part byte.
Voice_Env_VelocityDispatch_c3_Trigger:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2509:24)
	ld	a, (xbc+wa)
	extz wa
	calr BitTest_Mode2_L_v2
	jr Voice_Env_VelocityDispatch_Gate

; Unknown sub-case: predicate = 0.
Voice_Env_VelocityDispatch_ClearFlag:
	ld l, 0x0:opc

; Gate: if the predicate is non-zero install the program byte via Instrument_LookupProgram_HiNibble (high nibble variant).
Voice_Env_VelocityDispatch_Gate:
	cp l, 0:i3
	jrl z, Voice_Env_ApplyVelocity_Return
	ld a, (xsp)
	extz wa
	calr Instrument_LookupProgram_HiNibble
	jrl Voice_Env_ApplyVelocity_Return

; VELOCITY-SWITCH DISPATCHER, TYPE 2. Identical structure to the type-0/1 dispatcher
; but every flag test uses bit4 instead of bit3, and the gate calls
; Instrument_LookupProgram_LoNibble (low nibble of the patch byte +0x2A).
; Entered only by the A == 2 branch of Voice_Env_ApplyVelocity_Type0.
Voice_Env_ApplyVelocity_Type2:
	cp c, 3:i3
	jr z, Voice_Env_Type2_c3
	cp c, 2:i3
	jr z, Voice_Env_Type2_c2
	cp c, 1:i3
	jr z, Voice_Env_Type2_c1
	cp c, 0:i3
	jrl nz, Voice_Env_Type2_ClearFlag
	bit 4, (Payload_Bss_Start+0x24d5:24)
	jr z, Voice_Env_Type2_c0_NoBit4
	ld l, 0x0:opc
	jrl Voice_Env_Type2_Gate

; Case 0, bit4 clear: predicate = bit0 of the 0x04134B config byte.
Voice_Env_Type2_c0_NoBit4:
	ld a, (Payload_Bss_Start+0x24d5:24)
	extz wa
	calr BitTest_Bit0_L
	jr Voice_Env_Type2_Gate

; Case 1: test bit4 of the 0x04134B config byte.
Voice_Env_Type2_c1:
	bit 4, (Payload_Bss_Start+0x24d5:24)
	jr z, Voice_Env_Type2_c1_NoBit4
	ld l, 0x0:opc
	jr Voice_Env_Type2_Gate

; Case 1, bit4 clear: predicate = BitTest_Mode2_L of the config byte.
Voice_Env_Type2_c1_NoBit4:
	ld a, (Payload_Bss_Start+0x24d5:24)
	extz wa
	calr BitTest_Mode2_L
	jr Voice_Env_Type2_Gate

; Case 2: test bit4 of the per-part byte at 0x04137F + part*0x011F.
Voice_Env_Type2_c2:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2509:24)
	bit	4, (xbc+wa)
	jr z, Voice_Env_Type2_c2_Trigger
	ld l, 0x0:opc
	jr Voice_Env_Type2_Gate

; Case 2, bit4 clear: predicate = bit0 of that per-part byte.
Voice_Env_Type2_c2_Trigger:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2509:24)
	ld	a, (xbc+wa)
	extz wa
	calr BitTest_Bit0_L_v2
	jr Voice_Env_Type2_Gate

; Case 3: test bit4 of the per-part byte.
Voice_Env_Type2_c3:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2509:24)
	bit	4, (xbc+wa)
	jr z, Voice_Env_Type2_c3_Trigger
	ld l, 0x0:opc
	jr Voice_Env_Type2_Gate

; Case 3, bit4 clear: predicate = BitTest_Mode2_L_v2 of that per-part byte.
Voice_Env_Type2_c3_Trigger:
	ld a, (xsp)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2509:24)
	ld	a, (xbc+wa)
	extz wa
	calr BitTest_Mode2_L_v2
	jr Voice_Env_Type2_Gate

; Unknown sub-case: predicate = 0.
Voice_Env_Type2_ClearFlag:
	ld l, 0x0:opc

; Gate: install the program byte via Instrument_LookupProgram_LoNibble.
Voice_Env_Type2_Gate:
	cp l, 0:i3
	jr z, Voice_Env_ApplyVelocity_Return
	ld a, (xsp)
	extz wa
	calr Instrument_LookupProgram_LoNibble

; Shared return for both dispatchers.
Voice_Env_ApplyVelocity_Return:
	inc 2, xsp
	ret

; COMPUTE THE PITCH OF ONE VOICE (the main pitch accumulator).
; In: XWA = voice work record. Locals: (XSP+0x08) = record, (XSP+0x02) = (record+0x1F)
; = the pitch/portamento descriptor, (XSP+0x06) = (record+0x04) = part index.
; IZ accumulates the pitch in 8.8 semitone units:
;   start  = ((record+0x05) & 0x7F) * 0x100 + 0x80 + (0x041349)   [key + master tune]
;   += (record+0x23)->[0x16] << 8 and (record+0x23)->[0x6D] << 8   [two transposes]
;   += Pitch_Get_Patch_Octave_Shift(WA = (record+0x04), C = (record+0x13)->[0x29])
; Then ScaleTune_Is_Global_Enabled (0x028D42) decides between the active and inactive paths.
; Active path: bit3 of the u16 at 0x04136A + part*0x011F enables a bend-type switch
;   read through ScaleTune_Get_Global_Mode (0x028B96); 0x80 = octave/keyboard-follow via
;   ScaleTune_Get_User_Offset, 0x40 = fixed offset from (0x041366), 0x41/0x42 = the u16
;   ROM tables at 0x00FCE4 / 0x00FDE4 indexed by the key, 0 = nothing.
; Result is written to (record+0x08) and (record+0x06).
; Callers 0x02B91E, 0x02BEB7.
Voice_Pitch_Compute:
	lda xsp, (xsp - 10)
	pushw iz
	ld (xsp + 8), xwa
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 31)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 8)
	ld a, (xwa + 4)
	ld (xsp + 6), a
	ld xwa, (xsp + 8)
	ld a, (xwa + 5)
	ldfr_berp A, 0xF8
	extz iz
	sla iz, 8
	and iz, 0x7F00
	add iz, 0x80
	add iz, (Payload_Bss_Start+0x24d3:24)
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 35)
	ld a, (xwa + 22)
	exts wa
	sla wa, 8
	add iz, wa
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 35)
	ld a, (xwa + 109)
	exts wa
	sla wa, 8
	add iz, wa
	ld xwa, (xsp + 8)
	ld a, (xwa + 4)
	ld e, a
	extz de
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 19)
	ld a, (xwa + 41)
	ld c, a
	extz bc
	ld wa, de
	calr Pitch_Get_Patch_Octave_Shift
	add iz, hl
	call ScaleTune_Is_Global_Enabled
	cp hl, 0:i3
	jrl z, Voice_Pitch_Compute_Inactive
	ld a, (xsp + 6)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PresentWord:24)
	ld	wa, (xbc+wa)
	bit 8, wa
	jrl z, Voice_Pitch_ApplyPortamento
	call ScaleTune_Get_Global_Mode
	ld a, l
	cp a, 0x80
	jr z, Voice_Pitch_BendType_Octave
	cp a, 0x42
	jr z, Voice_Pitch_BendType_TableB
	cp a, 0x41
	jr z, Voice_Pitch_BendType_TableA
	cp a, 0x40
	jr z, Voice_Pitch_BendType_Fixed
	cp a, 0:i3
	jrl z, Voice_Pitch_ApplyPortamento

; Bend type 0x80: key/12 selects a channel assignment via ScaleTune_Get_User_Offset (0x028C28), added as whole semitones.
Voice_Pitch_BendType_Octave:
	ld xwa, (xsp + 8)
	ld a, (xwa + 5)
	res 7, a
	extz wa
	div a, 0xC
	ld a, w
	extz wa
	call ScaleTune_Get_User_Offset
	ld a, l
	exts wa
	add wa, wa
	add iz, wa
	jrl Voice_Pitch_ApplyPortamento

; Bend type 0x40: add the fixed global offset word at 0x041366.
Voice_Pitch_BendType_Fixed:
	add iz, (Payload_Bss_Start+0x24f0:24)
	jrl Voice_Pitch_ApplyPortamento

; Bend type 0x41: add the u16 from the ROM table at 0x00FCE4 indexed by key.
Voice_Pitch_BendType_TableA:
	ld xwa, (xsp + 8)
	ld a, (xwa + 5)
	res 7, a
	extz wa
	add wa, wa
	lda xbc, (Voice_KeyBend_Type41_Table:24)
	ld	wa, (xbc+wa)
	add iz, wa
	jrl Voice_Pitch_ApplyPortamento

; Bend type 0x42: add the u16 from the ROM table at 0x00FDE4 indexed by key.
Voice_Pitch_BendType_TableB:
	ld xwa, (xsp + 8)
	ld a, (xwa + 5)
	res 7, a
	extz wa
	add wa, wa
	lda xbc, (Voice_KeyBend_Type42_Table:24)
	ld	wa, (xbc+wa)
	add iz, wa
	jrl Voice_Pitch_ApplyPortamento

; Inactive/non-mono path: the bend type comes from (patch block)->[0x13] where the block pointer is at 0x04136E + part*0x011F.
Voice_Pitch_Compute_Inactive:
	ld a, (xsp + 6)
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld l, (xwa + 19)
	ld a, l
	cp a, 0x80
	jrl z, Voice_Pitch_ApplyPortamento
	cp a, 0x42
	jr z, Voice_Pitch_Inactive_BendType_TableB
	cp a, 0x41
	jr z, Voice_Pitch_Inactive_BendType_TableA
	cp a, 0x40
	jr z, Voice_Pitch_Inactive_BendType_Fixed
	cp a, 0:i3
	jr nz, Voice_Pitch_Inactive_BendType_Chromatic
	jr Voice_Pitch_ApplyPortamento

; Inactive, type 0x40: add the fixed offset word at 0x041366.
Voice_Pitch_Inactive_BendType_Fixed:
	add iz, (Payload_Bss_Start+0x24f0:24)
	jr Voice_Pitch_ApplyPortamento

; Inactive, type 0x41: 0x00FCE4 table lookup by key.
Voice_Pitch_Inactive_BendType_TableA:
	ld xwa, (xsp + 8)
	ld a, (xwa + 5)
	res 7, a
	extz wa
	add wa, wa
	lda xbc, (Voice_KeyBend_Type41_Table:24)
	ld	wa, (xbc+wa)
	add iz, wa
	jr Voice_Pitch_ApplyPortamento

; Inactive, type 0x42: 0x00FDE4 table lookup by key.
Voice_Pitch_Inactive_BendType_TableB:
	ld xwa, (xsp + 8)
	ld a, (xwa + 5)
	res 7, a
	extz wa
	add wa, wa
	lda xbc, (Voice_KeyBend_Type42_Table:24)
	ld	wa, (xbc+wa)
	add iz, wa
	jr Voice_Pitch_ApplyPortamento

; Inactive, any other non-zero type: chromatic map - key/12 gives the row, key%12 the column, in the 12-byte-per-row table at 0x011B68; the signed byte is added as whole semitones.
Voice_Pitch_Inactive_BendType_Chromatic:
	ld xwa, (xsp + 8)
	ld a, (xwa + 5)
	res 7, a
	extz wa
	div a, 0xC
	ld a, w
	ld e, a
	extz de
	ld a, l
	extz wa
	muls wa, 0xC
	lda xbc, (Voice_ChromaticBend_Table:24)
	exts xwa
	add xwa, xbc
	ld	a, (xwa+de)
	exts wa
	add wa, wa
	add iz, wa

; PORTAMENTO / GLIDE STAGE. Saturates the accumulator into (record+0x08), then reads
; the glide mode from (record+0x17)->[0x06] & 7. Bit1 of the first byte of the
; portamento descriptor selects the 'active glide' arm; mode 7 means 'jump straight to
; the target'; other modes exponentially approach it by right-shifting the difference
; by (mode & 0x0F).
;
; ⚠ THE TWO ARMS DIFFER IN WHERE THE PITCH CENTRE COMES FROM, and anything that reads
; these descriptors offline has to honour it.
;
;   bit1 CLEAR -> the centre is built from the descriptor's own fields: the root byte at
;                 +0x0B gives pivot = (root << 8) + 0x80, which is subtracted, and the
;                 target offset at +0x0C is added back.
;   bit1 SET   -> the centre is the LITERAL 0x4280, subtracted and added back unchanged
;                 (Voice_Pitch_Portamento_Active_SubBias / _AddBias below), or loaded
;                 outright in mode 7. The descriptor's root and basepitch fields are
;                 NEVER READ on this arm, so their contents are unconstrained.
;
; They are, in fact, junk. Of the 487 multisample SET descriptors, 13 have bit1 set; those
; 13 are exactly the 13 whose root byte is not the universal 0x42, and all 13 carry the
; same impossible basepitch 0x417F. An extractor that computes (basepitch - pivot)
; unconditionally therefore fabricates an offset of +49 to +65 semitones for those SETs --
; 112 of the 1444 selectors the firmware's tables produce, about 7.8%.
;
; That bug shipped in a generated pitch table used by an emulator until 2026-08-19. Three
; independent lines of evidence confirmed the rule: this code path; the junk-field
; correlation above; and a live capture, where the affected selectors decode correctly
; only when the term is dropped (19/19, 1/1, 1/1 against 12/19, 0/1, 0/1).
Voice_Pitch_ApplyPortamento:
	ld wa, iz
	calr Pitch_Saturate_15bit
	ld xwa, (xsp + 8)
	ld (xwa + 8), hl
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 23)
	ld l, (xwa + 6)
	and l, 0x7
	ld xwa, (xsp + 2)
	bitm 1, (xwa)
	jr nz, Voice_Pitch_Portamento_Active_SubBias
	cp l, 7:i3
	jr z, Voice_Pitch_Portamento_Mode7_Direct
	ld xwa, (xsp + 2)
	ld a, (xwa + 11)
	extz wa
	sla wa, 8
	add wa, 0x80
	sub iz, wa
	ld a, l
	and a, 0xF
	jr z, Voice_Pitch_Portamento_Off_AddOffset
	sraa iz

; Glide idle: add the target offset word (descriptor+0x0C).
Voice_Pitch_Portamento_Off_AddOffset:
	ld xwa, (xsp + 2)
	ld wa, (xwa + 12)
	add iz, wa
	jr Voice_Pitch_ApplyFineTune

; Glide mode 7: load the target (descriptor+0x0C) directly, no smoothing.
Voice_Pitch_Portamento_Mode7_Direct:
	ld xwa, (xsp + 2)
	ld iz, (xwa + 12)
	jr Voice_Pitch_ApplyFineTune

; Active glide: work relative to the 0x4280 centre, shift, then restore the bias.
Voice_Pitch_Portamento_Active_SubBias:
	cp l, 7:i3
	jr z, Voice_Pitch_Portamento_Active_SetFixed
	sub iz, 0x4280
	ld a, l
	and a, 0xF
	jr z, Voice_Pitch_Portamento_Active_AddBias
	sraa iz

; Restore the 0x4280 bias after the shift.
Voice_Pitch_Portamento_Active_AddBias:
	add iz, 0x4280
	jr Voice_Pitch_ApplyFineTune

; Active glide, mode 7: snap to the 0x4280 centre.
Voice_Pitch_Portamento_Active_SetFixed:
	ldw iz, 0x4280

; FINE-TUNE STAGE: add (record+0x17)->[0x04] and (record+0x27)->[0x20], both signed and
; scaled by 0x100, then map into the zone's key range - by octave folding
; (Pitch_Fold_Octaves_Into_Range) when the glide mode is 0, or by saturation
; (Pitch_Clamp_Into_Range) otherwise - and store the result in (record+0x06).
Voice_Pitch_ApplyFineTune:
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 23)
	ld a, (xwa + 4)
	exts wa
	sla wa, 8
	add iz, wa
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 39)
	ld a, (xwa + 32)
	exts wa
	sla wa, 8
	add iz, wa
	cp l, 0:i3
	jr nz, Voice_Pitch_ApplyFineTune_LegatoB
	ld xwa, (xsp + 2)
	ld a, (xwa + 9)
	ld c, a
	extz bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 10)
	ld e, a
	extz de
	ld wa, iz
	calr Pitch_Fold_Octaves_Into_Range
	ld xwa, (xsp + 8)
	ld (xwa + 6), hl
	jr Voice_Pitch_Compute_Return

; Non-zero glide mode: clamp into the key range with Pitch_Clamp_Into_Range instead of folding.
Voice_Pitch_ApplyFineTune_LegatoB:
	ld xwa, (xsp + 2)
	ld a, (xwa + 9)
	ld c, a
	extz bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 10)
	ld e, a
	extz de
	ld wa, iz
	calr Pitch_Clamp_Into_Range
	ld xwa, (xsp + 8)
	ld (xwa + 6), hl

; Frame teardown and return.
Voice_Pitch_Compute_Return:
	popw iz
	lda xsp, (xsp + 10)
	ret

; RECOMPUTE THE VOICE'S BASE PITCH FROM THE DESCRIPTOR ONLY (no bend, no glide).
; In: XWA = voice work record. (record+0x1F)->[0x0C] is copied to (record+0x08); the
; signed bytes (record+0x17)->[0x03] (semitones) and ->[0x04] (half-steps of 2) are
; added, and the total is octave-folded into the key range given by the descriptor
; bytes +0x09 / +0x0A before being stored in (record+0x06).
; Callers 0x02B6CD, 0x02C278.
Voice_Pitch_CopyBase:
	push xiz
	ld xiz, xwa
	ld xbc, (xiz + 23)
	ld xwa, (xiz + 31)
	ld hl, (xwa + 12)
	ld (xiz + 8), hl
	ld a, (xbc + 3)
	exts wa
	sla wa, 8
	add hl, wa
	ld a, (xbc + 4)
	exts wa
	add wa, wa
	add hl, wa
	ld xwa, (xiz + 31)
	ld a, (xwa + 9)
	ld c, a
	extz bc
	ld xwa, (xiz + 31)
	ld a, (xwa + 10)
	ld e, a
	extz de
	ld wa, hl
	calr Pitch_Fold_Octaves_Into_Range
	ld (xiz + 6), hl
	pop xiz
	ret

; SELECT AND EMIT THE KEY-ZONE RECORD FOR THE CURRENT PITCH.
; In: XWA = voice work record. XIZ = (record+0x1F) = the zone descriptor.
; Two table pointers are formed by adding the 32-bit DRAM base at 0x045310 to
; (desc+0x01) and (desc+0x05). WaveSel_KeyTable_Lookup turns (record+0x06) - the pitch
; just computed - into a zone number through the first table; the byte at
; (table1 + zone + 4) becomes the record index. Descriptor bits 5, 6 and 7 then select
; one of the six SlotParam_Write_Stride* emitters (record strides 0x0F, 0x0C, 0x0D,
; 0x0A, 0x06 or 4).
; Callers 0x02B4FE, 0x02C0D1, 0x02C3E7.
WaveSel_StageB_Build_Reg040:
	lda xsp, (xsp - 12)
	push xiz
	ld (xsp + 12), xwa
	ld xwa, (xsp + 12)
	ld xiz, (xwa + 31)
	ld xwa, (xiz + 1)
	add xwa, (Payload_Bss_Start+0x649a:24)
	ld (xsp + 4), xwa
	ld xwa, (xiz + 5)
	add xwa, (Payload_Bss_Start+0x649a:24)
	ld (xsp + 8), xwa
	ld xwa, (xsp + 4)
	ld xwa, (xwa)
	ld xde, xwa
	add xde, (Payload_Bss_Start+0x649a:24)
	ld xwa, (xsp + 12)
	ld bc, (xwa + 6)
	ld xwa, xde
	calr WaveSel_KeyTable_Lookup
	ld a, l
	extz wa
	ld bc, wa
	inc 4, bc
	ld xwa, (xsp + 4)
	ld	e, (xwa+bc)
	bitm 6, (xiz)
	jr z, Voice_Pitch_Interp_Bit7_NoB6
	bitm 7, (xiz)
	jr z, Voice_Pitch_Interp_Bit7_NoB5
	bitm 5, (xiz)
	jr z, Voice_Pitch_Interp_Bits56
	ld xbc, (xsp + 8)
	extz de
	ld xwa, (xsp + 12)
	calr WaveSel_Emit_ZoneRecord_S15
	jr WaveSel_StageB_Return

; Descriptor bits 7 and 6 set, bit5 clear: stride 0x0C emitter.
Voice_Pitch_Interp_Bits56:
	ld xbc, (xsp + 8)
	extz de
	ld xwa, (xsp + 12)
	calr WaveSel_Emit_ZoneRecord_S12
	jr WaveSel_StageB_Return

; Descriptor bit6 set, bit7 clear: test bit5 to choose stride 0x0D or 0x0A.
Voice_Pitch_Interp_Bit7_NoB5:
	bitm 5, (xiz)
	jr z, Voice_Pitch_Interp_Bits67
	ld xbc, (xsp + 8)
	extz de
	ld xwa, (xsp + 12)
	calr WaveSel_Emit_ZoneRecord_S13
	jr WaveSel_StageB_Return

; Descriptor bits 6 and 7 set, bit5 clear on this arm: stride 0x0A emitter.
Voice_Pitch_Interp_Bits67:
	ld xbc, (xsp + 8)
	extz de
	ld xwa, (xsp + 12)
	calr WaveSel_Emit_ZoneRecord_S10
	jr WaveSel_StageB_Return

; Descriptor bit6 clear: bit7 chooses stride 0x06, otherwise the stride-4 base format.
Voice_Pitch_Interp_Bit7_NoB6:
	bitm 7, (xiz)
	jr z, Voice_Pitch_Interp_Base
	ld xbc, (xsp + 8)
	extz de
	ld xwa, (xsp + 12)
	calr WaveSel_Emit_ZoneRecord_S6
	jr WaveSel_StageB_Return

; No format bits: the stride-4 base emitter.
Voice_Pitch_Interp_Base:
	ld xbc, (xsp + 8)
	extz de
	ld xwa, (xsp + 12)
	calr WaveSel_Emit_ZoneRecord_S4

; Frame teardown and return.
WaveSel_StageB_Return:
	pop xiz
	lda xsp, (xsp + 12)
	ret

; ADVANCE THE MULTI-SAMPLE / FOOTAGE SELECTION AND STORE THE OUTPUT REGISTERS.
; In: XWA = voice work record (kept in XIZ). Base pointer = 0x045310 + (record+0x1F)->
; [0x05]. The state byte (XIZ+0x03) selects the row source:
;   0        -> Voice_Slot_CalcAmpNibble (0x02B154)
;   1 or 2   -> Voice_Slot_FindOctaveOffset (0x02B1E0)
;   >= 3     -> the u16 routing table at (XIZ+0x23) + 0x0102 + state*2
; The result is passed through Voice_KeyIndex_Pack3Nibbles (0x02B2C2) and multiplied by
; 6 to index the record array. Single caller 0x02BCF1.
WaveSel_StageB_Build_Reg040_Footage:
	dec 4, xsp
	push xiz
	ld xiz, xwa
	ld xwa, (xiz + 31)
	ld xwa, (xwa + 5)
	add xwa, (Payload_Bss_Start+0x649a:24)
	ld (xsp + 4), xwa
	cp (xiz + 3), 0x0
	jr nz, WaveSel_StageB_Build_Reg040_Footage_StateB
	ld a, (xiz + 4)
	ld l, a
	extz hl
	ld a, (xiz)
	ld c, a
	extz bc
	ld a, (xiz + 3)
	ld e, a
	extz de
	ld wa, hl
	call Voice_Slot_CalcAmpNibble
	ld wa, hl
	call Voice_KeyIndex_Pack3Nibbles
	ld wa, hl
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	add xbc, xbc
	add (xsp + 4), xbc
	jr WaveSel_StageB_Store_Reg040

; State 1 or 2: use Voice_Slot_FindOctaveOffset instead of the amplitude nibble.
WaveSel_StageB_Build_Reg040_Footage_StateB:
	cp (xiz + 3), 0x3
	jr nc, WaveSel_StageB_Build_Reg040_Footage_RoutingTable
	ld a, (xiz + 4)
	ld l, a
	extz hl
	ld a, (xiz)
	ld c, a
	extz bc
	ld a, (xiz + 3)
	ld e, a
	extz de
	ld wa, hl
	call Voice_Slot_FindOctaveOffset
	ld wa, hl
	call Voice_KeyIndex_Pack3Nibbles
	ld wa, hl
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	add xbc, xbc
	add (xsp + 4), xbc
	jr WaveSel_StageB_Store_Reg040

; State >= 3: take the row directly from the per-patch routing table at (XIZ+0x23)+0x0102.
WaveSel_StageB_Build_Reg040_Footage_RoutingTable:
	ld a, (xiz + 3)
	extz wa
	add wa, wa
	ld bc, wa
	add bc, 0x102
	ld xwa, (xiz + 35)
	ld	hl, (xwa+bc)
	ld wa, hl
	extz xwa
	ld xbc, xwa
	add xbc, xbc
	add xbc, xwa
	add xbc, xbc
	add (xsp + 4), xbc

; Store the selected record: pointer to (XIZ+0x0F), type code 0x4000 OR'ed into
; (XIZ+0x01), record word 0 to the staging word 0x0451CE and record word 4 to 0x293E.
; If bit2 of the global audio-mode word at 0x041343 is set the top nibble of 0x0451CE
; is doubled in place (a mode-dependent re-scale of the wave/bank field).
WaveSel_StageB_Store_Reg040:
	ld xwa, (xsp + 4)
	ld (xiz + 15), xwa
	ormi16 (xiz + 1), 0x4000
	ld xwa, (xsp + 4)
	ld wa, (xwa)
	ld (Payload_Bss_Start+0x6358:24), wa
	ld xwa, (xsp + 4)
	ld wa, (xwa + 4)
	ld (10558:16), wa
	ld wa, (Voice_GlobalFlags:24)
	bit 2, wa
	jr z, WaveSel_StageB_Store_Reg040_Return
	ld wa, (Payload_Bss_Start+0x6358:24)
	and wa, 0xF000
	add wa, wa
	andw (Payload_Bss_Start+0x6358:24), 4095
	or (Payload_Bss_Start+0x6358:24), wa

; Restore and return.
WaveSel_StageB_Store_Reg040_Return:
	pop xiz
	inc 4, xsp
	ret

; SCALE THE MASTER TICK BY A FACTOR AND PUBLISH IT AS THE GLOBAL PITCH OFFSET.
; In: XWA = multiplier. XBC = the 32-bit master tick at 0x1040; Math_Multiply32 multiplies
; them, the product is >> 2, truncated to 8 bits, multiplied by 0x0D and >> 7, and the
; signed result is stored in the global word at 0x041366 that
; Voice_Pitch_BendType_Fixed reads. Single caller 0x02C940.
Voice_Vol_ScaleVelocityWord:
	ld xbc, (4160:16)
	ld xwa, xbc
	call Math_Multiply32
	srl xhl, 2
	and xhl, 0xFF
	ld a, l
	exts wa
	muls wa, 0xD
	sra wa, 7
	ld (Payload_Bss_Start+0x24f0:24), wa
	ret

; COMBINE THE PITCH SOURCES INTO (record+0x0A) AND SET THE 'GLIDE ACTIVE' FLAG.
; In: XWA = voice work record. DE = (record+0x06) + (0x293E) + (record+0x17)->[0x05]*2
;   + (record+0x27)->[0x21] + (record+0x23)->[0x14], stored at (record+0x0A).
; Then bit 0x0400 of (record+0x01) is set only when bit1 of (record+0x23)->[0x0A] AND
; bit5 of (record+0x13)->[0x10] are both set, and cleared otherwise.
; Callers 0x02B504, 0x02BCF7.
Pitch_Apply_Partial_Detune:
	ld de, (xwa + 6)
	add de, (10558:16)
	ld xbc, (xwa + 23)
	ld c, (xbc + 5)
	exts bc
	add bc, bc
	add de, bc
	ld xbc, (xwa + 39)
	ld c, (xbc + 33)
	exts bc
	add de, bc
	ld xbc, (xwa + 35)
	add de, (xbc + 20)
	ld (xwa + 10), de
	ld xbc, (xwa + 35)
	ld bc, (xbc + 10)
	bit 2, bc
	jr z, Pitch_Apply_Partial_Detune_ClearBit
	ld xbc, (xwa + 19)
	bitm 5, (xbc + 16)
	jr z, Pitch_Apply_Partial_Detune_ClearBit
	ormi16 (xwa + 1), 0x400
	ret

; Conditions not met: clear bit 0x0400 of (record+0x01).
Pitch_Apply_Partial_Detune_ClearBit:
	andmi16 (xwa + 1), 0xFBFF
	ret

; EMIT THE FINAL PITCH REGISTER (primary channel).
; In: XWA = voice work record. DE = (record+0x0A) + the global fine-tune word at
; 0x041347; if bit4 of (record+0x27)->[0x18] is set a detune of (record+0x23)->[0x1D] is
; added or subtracted according to bit5 of the same word; if bit 0x0400 of (record+0x01)
; is set the extra offset at 0x04135A is added. The saturated result goes to the staging
; word at 0x0451DA. Callers 0x028D90, 0x02B50A, 0x02BCFD.
Pitch_Emit_Reg400:
	ld de, (xwa + 10)
	add de, (Payload_Bss_Start+0x24d1:24)
	ld xbc, (xwa + 39)
	ld bc, (xbc + 24)
	bit 4, bc
	jr z, Voice_Pitch_Legato_StoreOutput
	ld xbc, (xwa + 39)
	ld bc, (xbc + 24)
	bit 5, bc
	jr z, Voice_Pitch_Legato_DetuneDown
	ld xbc, (xwa + 35)
	sub de, (xbc + 29)
	jr Voice_Pitch_Legato_StoreOutput

; Detune downward variant (bit5 clear): add (record+0x23)->[0x1D].
Voice_Pitch_Legato_DetuneDown:
	ld xbc, (xwa + 35)
	add de, (xbc + 29)

; Optional 0x04135A offset when (record+0x01) bit 0x0400 is set.
Voice_Pitch_Legato_StoreOutput:
	ld wa, (xwa + 1)
	bit 10, wa
	jr z, Voice_Pitch_Legato_StoreOutput_Return
	add de, (Payload_Bss_Start+0x24e4:24)

; Saturate and store to the staging word 0x0451DA.
Voice_Pitch_Legato_StoreOutput_Return:
	ld wa, de
	calr Pitch_Saturate_15bit
	ld (Payload_Bss_Start+0x6364:24), hl
	ret

; Simple pitch combine: (record+0x0A) = (record+0x06) + (0x293E). No detune, no
; register write. Callers 0x02C0D7, 0x02C3F6.
Pitch_Apply_Zone_Trim:
	ld bc, (xwa + 6)
	add bc, (10558:16)
	ld (xwa + 10), bc
	ret

; EMIT THE FINAL PITCH REGISTER (secondary channel). Same as
; Pitch_Emit_Reg400 minus the 0x04135A offset stage; result also goes
; to 0x0451DA. Callers 0x028DA4, 0x02C0DD, 0x02C3FC.
Voice_Pitch_WriteOutputReg_Secondary:
	ld de, (xwa + 10)
	add de, (Payload_Bss_Start+0x24d1:24)
	ld xbc, (xwa + 39)
	ld bc, (xbc + 24)
	bit 4, bc
	jr z, Voice_Pitch_Secondary_StoreOutput
	ld xbc, (xwa + 39)
	ld bc, (xbc + 24)
	bit 5, bc
	jr z, Voice_Pitch_Secondary_DetuneDown
	ld xwa, (xwa + 35)
	sub de, (xwa + 29)
	jr Voice_Pitch_Secondary_StoreOutput

; Detune downward variant: add (record+0x23)->[0x1D].
Voice_Pitch_Secondary_DetuneDown:
	ld xwa, (xwa + 35)
	add de, (xwa + 29)

; Saturate and store to 0x0451DA.
Voice_Pitch_Secondary_StoreOutput:
	ld wa, de
	calr Pitch_Saturate_15bit
	ld (Payload_Bss_Start+0x6364:24), hl
	ret

; ENVELOPE 2 -- IC303 registers r0x24 / r0x25 / r0x26 (banks +0x900 / +0x940 / +0x980).
; In: XWA = voice-slot record; XIZ = paramA = the u32 at slot+0x17 (the patch parameter
; block -- NOT the tone record, which is the pointer at slot+0x23). The prologue's
; `ld xwa, (xwa+23)` is DECIMAL 23 = slot+0x17.
; Out: the three staging words 0x0451EC, 0x0451EE, 0x0451F0. Callers 0x02B510 inside
; Voice_Build_Register_Set (0x02B4E3, the type-4 note-on rebuild) and 0x02BD03 inside
; Voice_Release_Type4 (0x02BCD6, the per-tick refresh of a sounding type-4 voice) --
; type-4 voices ONLY. On the type-1/type-2 path this envelope is never built:
; Voice_Init_Type1 / _Type2 call Voice_Level_ClearAllOutputRegs, which zeroes all three
; words instead.
;
; Same word format as envelope 1, (target << 8) | rate, one (target,rate) couple per
; segment, consecutive in the record:
;   seg 0  target Voice_EnvelopeLevel_Curve[paramA+0x09]   low byte from paramA+0x0A
;   seg 1  target Voice_EnvelopeLevel_Curve[paramA+0x0B]   low byte from paramA+0x0C
;   seg 2  target Voice_EnvelopeLevel_Curve[paramA+0x0D]   low byte from paramA+0x0E
; The three targets share one key-scale term, PitchBend_Scale(paramA+0x11, slot+0x0C,
; shift 4), added only when paramA+0x11 != 0, and each is clamped 0..0xFF. Velocity
; modulation is Pan_ScaleWithVelocity(baseline paramA+0x13, limits 0..0x7F, control word
; slot+0x08) with depth paramA+0x14 on segment 0 and paramA+0x15 shared by segments 1/2.
; 0xFF is the silent end of the level curve; 0x04 is the loudest byte 0x0118FE can produce.
;
; [INFERENCE] CALLING THE LOW BYTE A "RATE" HERE IS AN ANALOGY WITH ENVELOPE 1, NOT A
; RESULT. Nothing in this routine or in the hardware documentation identifies the field, and
; two things cut against the reading. (a) The byte is SIGNED here, which collides with the
; "apply now" meaning bit 7 carries in bank +0x800. (b) Voice_Calc_LevelPair_FixedAtk reads
; paramA+0x0A and +0x0C -- the very bytes this routine pushes through Detune_ScaleSymmetric
; -- as UNSIGNED Voice_EnvelopeRate_Table indexes on the type-1/2 path, where this routine
; never runs. (The two agree on the LEVEL bytes +0x09/+0x0B, which _FixedAtk also sends
; through 0x0118FE; only the low-byte reading differs.) So either those bytes are
; voice-type-polymorphic or one of the two readings is wrong.
;
; THE LOW BYTES ARE SIGNED HERE -- that is what separates envelopes 2 and 3 from envelope 1.
; They do NOT pass through Voice_EnvelopeRate_Table; each is (i8)paramA+0x0A / +0x0C / +0x0E
; pushed through Detune_ScaleSymmetric, which clamps |x| to 0x32, looks up Detune_Scale_Curve
; (0x0119C8, 0x00..0x7F) and NEGATES the result for negative inputs, so the byte spans
; -0x7F..+0x7F and has bit 7 SET whenever the parameter is negative. The whole triple is
; negated up front when (i8)paramA+0x07 < 0. A parameter of 0 still comes out as 0, since
; Detune_Scale_Curve[0] = 0.
; [INFERENCE] bit 7 is documented as the "apply now" strobe in bank +0x800. If it means the
; same in +0x900/+0x9C0, a negative parameter raises that strobe as a side effect; the
; alternative is that bit 7 is simply a SIGN in these banks. Nothing in the firmware settles
; it -- no code here ever tests bit 7 of a value it reads back.
;
; MIRROR: envelope 3 (Voice_StereoLevel_Compute, 0x024664) reads the same parameter block
; moved up by exactly 54 bytes. 0x07/0x09/0x0A/0x0B/0x0C/0x0D/0x0E/0x11/0x13/0x14/0x15 map
; onto 0x3D/0x3F/0x40/0x41/0x42/0x43/0x44/0x47/0x49/0x4A/0x4B, 11 for 11, and the per-tick
; writers mirror too (EGB reads 0x0F/0x10/0x16 where EGC reads 0x45/0x46/0x4C) -- 14 distinct
; mirrored offsets in all. The mirror is NOT operation-preserving: at the first pair
; paramA+0x07 is a SIGN FLAG that negates envelope 2's low bytes, while paramA+0x3D is ADDED
; to each of envelope 3's, before a +-0x32 clamp that envelope 2 does not apply.
Voice_Level_ComputeTriplet:
	lda xsp, (xsp - 16)
	push xiz
	ld (xsp + 16), xwa
	ld xwa, (xsp + 16)
	ld xiz, (xwa + 23)
	cp (xiz + 7), 0x0
	jr ge, Voice_Level_Triplet_Positive
	ld a, (xiz + 10)
	exts wa
	cpl wa
	inc 1, wa
	ld (xsp + 4), wa
	ld a, (xiz + 12)
	exts wa
	cpl wa
	inc 1, wa
	ld (xsp + 6), wa
	ld a, (xiz + 14)
	exts wa
	cpl wa
	inc 1, wa
	ld (xsp + 8), wa
	jr Voice_Level_Triplet_ModByEnv

; (patch+0x07) >= 0: take the three detune bytes with their natural sign.
Voice_Level_Triplet_Positive:
	ld a, (xiz + 10)
	exts wa
	ld (xsp + 4), wa
	ld a, (xiz + 12)
	exts wa
	ld (xsp + 6), wa
	ld a, (xiz + 14)
	exts wa
	ld (xsp + 8), wa

; (patch+0x11) != 0: compute the shared envelope-scaled offset via PitchBend_Scale.
Voice_Level_Triplet_ModByEnv:
	cp (xiz + 17), 0x0
	jrl z, Voice_Level_Triplet_Unmodulated
	ld a, (xiz + 17)
	ld e, a
	exts de
	ld xwa, (xsp + 16)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	cp (xiz + 9), 0x0
	jr z, Voice_Level_Ch1_Unmodulated
	ld de, hl
	ld a, (xiz + 9)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	add wa, de
	ld (xsp + 10), wa
	jr Voice_Level_Ch2_Modulated

; Channel 1 without the envelope offset.
Voice_Level_Ch1_Unmodulated:
	ld a, (xiz + 9)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 10), wa

; Channel 2 with the envelope offset.
Voice_Level_Ch2_Modulated:
	cp (xiz + 11), 0x0
	jr z, Voice_Level_Ch2_Unmodulated
	ld de, hl
	ld a, (xiz + 11)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	add wa, de
	ld (xsp + 12), wa
	jr Voice_Level_Ch3_Modulated

; Channel 2 without the envelope offset.
Voice_Level_Ch2_Unmodulated:
	ld a, (xiz + 11)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 12), wa

; Channel 3 with the envelope offset.
Voice_Level_Ch3_Modulated:
	cp (xiz + 13), 0x0
	jr z, Voice_Level_Ch3_Unmodulated
	ld a, (xiz + 13)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	add wa, hl
	ld (xsp + 14), wa
	jr Voice_Level_ApplyVelocityMod

; Channel 3 without the envelope offset.
Voice_Level_Ch3_Unmodulated:
	ld a, (xiz + 13)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 14), wa
	jr Voice_Level_ApplyVelocityMod

; (patch+0x11) == 0: all three levels come straight from the 0x0118FE table.
Voice_Level_Triplet_Unmodulated:
	ld a, (xiz + 9)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 10), wa
	ld a, (xiz + 11)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 12), wa
	ld a, (xiz + 13)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 14), wa

; Velocity modulation of channel 1 when (patch+0x14) != 0.
Voice_Level_ApplyVelocityMod:
	cp (xiz + 20), 0x0
	jr z, Voice_Level_PackAndStore
	ld a, (xiz + 19)
	ld c, a
	extz bc
	pushw 0x7F
	ld a, (xiz + 20)
	exts wa
	pushw wa
	ld xwa, (xsp + 20)
	ld wa, (xwa + 8)
	ld de, 0:i3
	calr Pan_ScaleWithVelocity
	add (xsp + 10), hl

; Clamp channel 1 to 0..0xFF, map its detune through Detune_ScaleSymmetric, pack level<<8|detune and store to 0x0451EC; then optionally velocity-modulate channels 2 and 3 via (patch+0x15).
Voice_Level_PackAndStore:
	ld wa, (xsp + 10)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	ld wa, (xsp + 4)
	calr Detune_ScaleSymmetric
	ld (xsp + 4), hl
	ld wa, (xsp + 4)
	ld w, 0x0:opc
	ld bc, (xsp + 10)
	sla bc, 8
	or bc, wa
	ld (Payload_Bss_Start+0x6376:24), bc
	cp (xiz + 21), 0x0
	jr z, Voice_Level_PackAndStore_NoVelocityMod
	ld a, (xiz + 19)
	ld c, a
	extz bc
	pushw 0x7F
	ld a, (xiz + 21)
	exts wa
	pushw wa
	ld xwa, (xsp + 20)
	ld wa, (xwa + 8)
	ld de, 0:i3
	calr Pan_ScaleWithVelocity
	ld iz, hl
	ld wa, (xsp + 12)
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl
	ld wa, (xsp + 14)
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 14), hl
	jr Voice_Level_PackSideChannels

; No channel-2/3 velocity modulation: clamp both levels as they are.
Voice_Level_PackAndStore_NoVelocityMod:
	ld wa, (xsp + 12)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 12), hl
	ld wa, (xsp + 14)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 14), hl

; Map the channel-2/3 detunes, pack them with their levels and store to 0x0451EE and 0x0451F0.
Voice_Level_PackSideChannels:
	ld wa, (xsp + 6)
	calr Detune_ScaleSymmetric
	ld (xsp + 6), hl
	ld wa, (xsp + 8)
	calr Detune_ScaleSymmetric
	ld (xsp + 8), hl
	ld wa, (xsp + 6)
	ld w, 0x0:opc
	ld bc, (xsp + 12)
	sla bc, 8
	or bc, wa
	ld (Payload_Bss_Start+0x6378:24), bc
	ld wa, (xsp + 8)
	ld w, 0x0:opc
	ld bc, (xsp + 14)
	sla bc, 8
	or bc, wa
	ld (Payload_Bss_Start+0x637a:24), bc
	pop xiz
	lda xsp, (xsp + 16)
	ret

; FILTER REGISTER BUILDER, MODE 1 (single cutoff + coefficient).
; In: XWA = voice work record; (XSP+0x02) = (record+0x17) = the patch block.
; Cutoff seed = (patch+0x4D) + (record+0x23)->[0x67]; TVF_Calc_Cutoff adds key
; follow ((patch+0x37)) and level scaling ((patch+0x3C)). The slope/mode field
; (patch+0x4E) is shifted left 13 and bit10 is set, then OR'ed with the cutoff to form
; (record+0x42). The second register (record+0x44) is TVF_Bias_Clamp_Amount OR
; TVF_Lookup_Depth_Amount of either the constants 0x48/0x8D (when bit9 of
; (record+0x23)->[0x02] is set) or the patch bytes (patch+0x4F)/(patch+0x50).
; Reached through the mode-1 thunk at 0x02412E of the dispatch table selected by
; (patch+0x36) & 7 - see TVF_Build_Dispatch (0x024102).
TVF_Build_Full:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 103)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 77)
	ldfr_berp A, 0xF8
	extz iz
	add iz, bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 55)
	ld e, a
	exts de
	ld xwa, (xsp + 2)
	ld a, (xwa + 60)
	exts wa
	pushw wa
	ld xwa, (xsp + 8)
	ld bc, iz
	calr TVF_Calc_Cutoff
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 78)
	extz wa
	sll wa, 13
	ld de, wa
	set 10, de
	ld wa, iz
	ld bc, wa
	or bc, de
	ld xwa, (xsp + 6)
	ld (xwa + 66), bc
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld wa, (xwa + 2)
	bit 9, wa
	jr z, TVF_Build_Full_UseVoiceLUT
	ldw wa, 0x48
	calr TVF_Bias_Clamp_Amount
	ld iz, hl
	ldw wa, 0x8D
	calr TVF_Lookup_Depth_Amount
	ld wa, iz
	ld bc, wa
	or bc, hl
	ld xwa, (xsp + 6)
	ld (xwa + 68), bc
	jr TVF_Build_Full_Return

; Bit9 of (record+0x23)->[0x02] clear: take the resonance/depth pair from (patch+0x4F) and (patch+0x50) instead of the 0x48/0x8D constants.
TVF_Build_Full_UseVoiceLUT:
	ld xwa, (xsp + 2)
	ld a, (xwa + 79)
	extz wa
	calr TVF_Bias_Clamp_Amount
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 80)
	extz wa
	calr TVF_Lookup_Depth_Amount
	ld wa, iz
	ld bc, wa
	or bc, hl
	ld xwa, (xsp + 6)
	ld (xwa + 68), bc

; Restore and return.
TVF_Build_Full_Return:
	popw iz
	inc 8, xsp
	ret

; FILTER REGISTER BUILDER, MODE 2. Same ingredients as mode 1 but computes the pair
; twice - once with the 0x48/0x8D constants and once from (patch+0x4F)/(patch+0x50) -
; and packs a different bit layout into (record+0x42) / (record+0x44).
; Reached through the thunk at 0x024131.
Voice_PitchPack_Mode2:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld wa, (xwa + 2)
	bit 9, wa
	jr z, Voice_PitchPack_Mode2_AltPath
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 103)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 77)
	ldfr_berp A, 0xF8
	extz iz
	sub iz, bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 55)
	ld e, a
	exts de
	ld xwa, (xsp + 2)
	ld a, (xwa + 60)
	exts wa
	pushw wa
	ld xwa, (xsp + 8)
	ld bc, iz
	calr TVF_Calc_Cutoff
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 78)
	extz wa
	sll wa, 13
	ld bc, wa
	set 10, bc
	ld wa, iz
	or wa, bc
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 6)
	ld (xwa + 66), bc
	ldw wa, 0x48
	calr TVF_Bias_Clamp_Amount
	ld iz, hl
	ldw wa, 0x8D
	calr TVF_Lookup_Depth_Amount
	ld wa, iz
	ld bc, wa
	or bc, hl
	ld xwa, (xsp + 6)
	ld (xwa + 68), bc
	jr Voice_PitchPack_Mode2_Return

; Alternate arm taken when bit9 of (record+0x23)->[0x02] is clear.
Voice_PitchPack_Mode2_AltPath:
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 103)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 77)
	ldfr_berp A, 0xF8
	extz iz
	add iz, bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 55)
	ld e, a
	exts de
	ld xwa, (xsp + 2)
	ld a, (xwa + 60)
	exts wa
	pushw wa
	ld xwa, (xsp + 8)
	ld bc, iz
	calr TVF_Calc_Cutoff
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 78)
	extz wa
	sll wa, 13
	ld bc, wa
	set 10, bc
	ld wa, iz
	or wa, bc
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 6)
	ld (xwa + 66), bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 79)
	extz wa
	calr TVF_Bias_Clamp_Amount
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 80)
	extz wa
	calr TVF_Lookup_Depth_Amount
	ld wa, iz
	ld bc, wa
	or bc, hl
	ld xwa, (xsp + 6)
	ld (xwa + 68), bc

; Restore and return.
Voice_PitchPack_Mode2_Return:
	popw iz
	inc 8, xsp
	ret

; FILTER REGISTER BUILDER, MODE 3. Structurally the same as mode 2 with a third bit
; packing of the cutoff and slope fields. Reached through the thunk at 0x024134.
Voice_PitchPack_Mode3:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld wa, (xwa + 2)
	bit 9, wa
	jr z, Voice_PitchPack_Mode3_AltPath
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 103)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 77)
	ldfr_berp A, 0xF8
	extz iz
	add iz, bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 55)
	ld e, a
	exts de
	ld xwa, (xsp + 2)
	ld a, (xwa + 60)
	exts wa
	pushw wa
	ld xwa, (xsp + 8)
	ld bc, iz
	calr TVF_Calc_Cutoff
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 78)
	extz wa
	sll wa, 13
	ld de, wa
	set 10, de
	ld wa, iz
	ld bc, wa
	or bc, de
	ld xwa, (xsp + 6)
	ld (xwa + 66), bc
	ldw wa, 0x48
	calr TVF_Bias_Clamp_Amount
	ld iz, hl
	ldw wa, 0x8D
	calr TVF_Lookup_Depth_Amount
	ld wa, iz
	ld bc, wa
	or bc, hl
	ld xwa, (xsp + 6)
	ld (xwa + 68), bc
	jr Voice_PitchPack_Mode3_Return

; Alternate arm taken when bit9 of (record+0x23)->[0x02] is clear.
Voice_PitchPack_Mode3_AltPath:
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 35)
	ld a, (xwa + 103)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 77)
	ldfr_berp A, 0xF8
	extz iz
	add iz, bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 55)
	ld e, a
	exts de
	ld xwa, (xsp + 2)
	ld a, (xwa + 60)
	exts wa
	pushw wa
	ld xwa, (xsp + 8)
	ld bc, iz
	calr TVF_Calc_Cutoff
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 78)
	extz wa
	ld bc, wa
	sll bc, 10
	ld xwa, (xsp + 2)
	ld a, (xwa + 78)
	extz wa
	ld de, wa
	sll de, 13
	or de, bc
	ld wa, iz
	ld bc, wa
	or bc, de
	ld xwa, (xsp + 6)
	ld (xwa + 66), bc
	ld xwa, (xsp + 6)
	ld (xwa + 68), iz
	ldw (10560:16), 0

; Restore and return.
Voice_PitchPack_Mode3_Return:
	popw iz
	inc 8, xsp
	ret

; FILTER REGISTER BUILDER, MODE 4 (single-slope form).
; Cutoff = (patch+0x4D), plus (record+0x23)->[0x67] when bit9 of (record+0x23)->[0x02]
; is clear. TVF_Calc_Cutoff applies key follow (patch+0x37) and level scaling
; (patch+0x3C). (patch+0x4E) is placed at both bit10 and bit13, bit7 is forced in both
; registers, and the coefficient global at 0x2940 is cleared.
; Reached through the thunk at 0x024137.
Voice_PitchPack_Mode4_Single:
	dec 4, xsp
	push xiz
	ld (xsp + 4), xwa
	ld xwa, (xsp + 4)
	ld xiz, (xwa + 23)
	ld xwa, (xsp + 4)
	ld xwa, (xwa + 35)
	ld wa, (xwa + 2)
	bit 9, wa
	jr z, Voice_PitchPack_Mode4_AltPath
	ld l, (xiz + 77)
	extz hl
	jr Voice_PitchPack_Mode4_Finalize

; Bit9 clear: add the tone-record offset (record+0x23)->[0x67] to the cutoff seed.
Voice_PitchPack_Mode4_AltPath:
	ld xwa, (xsp + 4)
	ld xwa, (xwa + 35)
	ld a, (xwa + 103)
	exts wa
	ld l, (xiz + 77)
	extz hl
	add hl, wa

; Shared tail: key follow, bit packing into (record+0x42)/(record+0x44), and (0x2940) = 0.
Voice_PitchPack_Mode4_Finalize:
	ld a, (xiz + 55)
	ld e, a
	exts de
	ld a, (xiz + 60)
	exts wa
	pushw wa
	ld xwa, (xsp + 6)
	ld bc, hl
	calr TVF_Calc_Cutoff
	ld a, (xiz + 78)
	extz wa
	ld bc, wa
	sll bc, 10
	ld a, (xiz + 78)
	extz wa
	ld de, wa
	sll de, 13
	or de, bc
	ld wa, hl
	or wa, de
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 4)
	ld (xwa + 66), bc
	set 7, hl
	ld xwa, (xsp + 4)
	ld (xwa + 68), hl
	ldw (10560:16), 0
	pop xiz
	inc 4, xsp
	ret

; FILTER REGISTER BUILDER, MODE 5 (dual cutoff). Reads BOTH (patch+0x4D) and
; (patch+0x4F) as two independent cutoff seeds. Reached through the thunk at 0x02413A,
; which uses 'calr' rather than 'jrl' so this one returns through the dispatcher.
; *** THIS ROUTINE EXTENDS PAST THE END OF THE REGION: its body continues at
; Voice_PitchPack_Mode5_ApplyDetune (0x024069) and
; Voice_PitchPack_Mode5_Finalize (0x024097), which belong to the next region. ***
Voice_PitchPack_Mode5_Dual:
	dec 8, xsp
	push xiz
	ld (xsp + 8), xwa
	ld xwa, (xsp + 8)
	ld xiz, (xwa + 23)
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 35)
	ld wa, (xwa + 2)
	bit 9, wa
	jr z, Voice_PitchPack_Mode5_ApplyDetune
	ld a, (xiz + 77)
	extz wa
	ld (xsp + 4), wa
	ld a, (xiz + 79)
	extz wa
	ld (xsp + 6), wa
	jr Voice_PitchPack_Mode5_Finalize

; Detune arm of Voice_PitchPack_Mode5_Dual: adds the signed byte (tonerec+103) to each of
; the two zero-extended coarse values (tonerec+77, tonerec+79) into the frames at (xsp+4)/(xsp+6).
Voice_PitchPack_Mode5_ApplyDetune:
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 35)
	ld a, (xwa + 103)
	ld c, a
	exts bc
	ld a, (xiz + 77)
	extz wa
	add wa, bc
	ld (xsp + 4), wa
	ld xwa, (xsp + 8)
	ld xwa, (xwa + 35)
	ld a, (xwa + 103)
	ld c, a
	exts bc
	ld a, (xiz + 79)
	extz wa
	add wa, bc
	ld (xsp + 6), wa

; Common tail of pitch-pack mode 5. Runs TVF_Calc_Cutoff twice (once per coarse
; value) then packs word = (tonerec+78)<<13 | (tonerec+78)<<10 | contrib, sets bit 7, and
; stores the pair to voice+66 / voice+68 (later emitted as TG regs 0x100 / 0x140).
; Clears the 16-bit flag at 0x2940 on exit, as every pitch-pack mode does.
Voice_PitchPack_Mode5_Finalize:
	ld a, (xiz + 55)
	ld e, a
	exts de
	ld a, (xiz + 60)
	exts wa
	pushw wa
	ld xwa, (xsp + 10)
	ld bc, (xsp + 6)
	calr TVF_Calc_Cutoff
	ld (xsp + 4), hl
	ld a, (xiz + 55)
	ld e, a
	exts de
	ld a, (xiz + 60)
	exts wa
	pushw wa
	ld xwa, (xsp + 10)
	ld bc, (xsp + 8)
	calr TVF_Calc_Cutoff
	ld (xsp + 6), hl
	ld a, (xiz + 80)
	extz wa
	ld bc, wa
	sll bc, 10
	ld a, (xiz + 78)
	extz wa
	ld de, wa
	sll de, 13
	or de, bc
	ld wa, (xsp + 4)
	or wa, de
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 8)
	ld (xwa + 66), bc
	ld xwa, (xsp + 8)
	ld bc, (xsp + 6)
	ld (xwa + 68), bc
	ldw (10560:16), 0
	pop xiz
	inc 8, xsp
	ret

TVF_Build_Dispatch:
	ld xbc, (xwa + 23)
	ld c, (xbc + 54)
	and c, 0x7
	extz bc
	cp bc, 0:i3
	jr mi, TVF_Build_Dispatch_Table
	cp bc, 5:i3
	jr gt, TVF_Build_Dispatch_Table
	add bc, bc
	lda xix, (TVF_Build_CaseOffsets:24)
	ld	bc, (xix+bc)
	lda xix, (TVF_Build_Dispatch_Table:24)
	jp	t, (xix+bc)

; Six-entry computed-goto landing pad for TVF_Build_Dispatch. Entry 0 falls through
; to TVF_Set_Bypass (0x022DA1, which sets voice+66=0x017F, voice+68=0x7F7F);
; entries 1..5 reach the mode bodies at 0x023D01, 0x023DB5, 0x023EC2, 0x023FBD, 0x02403D.
; Offsets come from the word table at 0x00F6A7.
TVF_Build_Dispatch_Table:
	jrl TVF_Set_Bypass
TVF_Build_Dispatch_Mode1_SingleCutoff:
	jrl TVF_Build_Full
TVF_Build_Dispatch_Mode2_SingleCutoffBit7:
	jrl Voice_PitchPack_Mode2
; TVF_Build_Dispatch_Mode3_SharedCutoff: With bit 9 of (voice+0x23)->[2] set, Voice_PitchPack_Mode3 packs like mode 1
;   instead (cutoff in the +0x100 word only).
TVF_Build_Dispatch_Mode3_SharedCutoff:
	jrl Voice_PitchPack_Mode3
TVF_Build_Dispatch_Mode4_SharedCutoffBit7:
	jrl Voice_PitchPack_Mode4_Single
TVF_Build_Dispatch_Mode5_DualCutoff:
	calr Voice_PitchPack_Mode5_Dual
	ret

TVF_Build_Short:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld a, (xwa + 17)
	ld c, a
	extz bc
	ld xwa, (xsp + 6)
	calr TVF_Calc_Cutoff_NoKeyFollow
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 18)
	extz wa
	sll wa, 13
	ld de, wa
	set 10, de
	ld wa, iz
	ld bc, wa
	or bc, de
	ld xwa, (xsp + 6)
	ld (xwa + 66), bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 19)
	extz wa
	calr TVF_Bias_Clamp_Amount
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 20)
	extz wa
	calr TVF_Lookup_Depth_Amount
	ld wa, iz
	ld bc, wa
	or bc, hl
	ld xwa, (xsp + 6)
	ld (xwa + 68), bc
	popw iz
	inc 8, xsp
	ret

; Pitch-pack route B. In: XWA = per-voice record. Out: voice+66, voice+68.
; Identical to route A (0x02413E) except that bit 7 is additionally set in the reg-0x100
; word. voice+66 = TVF_Calc_Cutoff_NoKeyFollow(tonerec+0x11) | (tonerec+0x12)<<13 | bit10 | bit7;
; voice+68 = TVF_Bias_Clamp_Amount(tonerec+0x13) | TVF_Lookup_Depth_Amount(tonerec+0x14).
; Touches no hardware. Reached only through TVF_BuildEmit_Short_Dispatch's table.
Voice_PitchPack_RouteB:
	dec 8, xsp
	pushw iz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	ld a, (xwa + 17)
	ld c, a
	extz bc
	ld xwa, (xsp + 6)
	calr TVF_Calc_Cutoff_NoKeyFollow
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 18)
	extz wa
	sll wa, 13
	ld bc, wa
	set 10, bc
	ld wa, iz
	or wa, bc
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 6)
	ld (xwa + 66), bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 19)
	extz wa
	calr TVF_Bias_Clamp_Amount
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 20)
	extz wa
	calr TVF_Lookup_Depth_Amount
	ld wa, iz
	ld bc, wa
	or bc, hl
	ld xwa, (xsp + 6)
	ld (xwa + 68), bc
	popw iz
	inc 8, xsp
	ret

; Pitch-pack route C. In: XWA = per-voice record; XIZ is loaded with the tone record.
; voice+66 = TVF_Calc_Cutoff_NoKeyFollow(tonerec+0x11) | (tonerec+0x12)<<10 | (tonerec+0x12)<<13;
; voice+68 = the same contrib value unmodified. Clears 0x2940. No bit-7 set (that is what
; distinguishes it from route D).
Voice_PitchPack_RouteC:
	dec 4, xsp
	push xiz
	ld (xsp + 4), xwa
	ld xwa, (xsp + 4)
	ld xiz, (xwa + 23)
	ld a, (xiz + 17)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	calr TVF_Calc_Cutoff_NoKeyFollow
	ld a, (xiz + 18)
	extz wa
	ld bc, wa
	sll bc, 10
	ld a, (xiz + 18)
	extz wa
	ld de, wa
	sll de, 13
	or de, bc
	ld wa, hl
	ld bc, wa
	or bc, de
	ld xwa, (xsp + 4)
	ld (xwa + 66), bc
	ld xwa, (xsp + 4)
	ld (xwa + 68), hl
	ldw (10560:16), 0
	pop xiz
	inc 4, xsp
	ret

; Pitch-pack route D. Byte-for-byte route C plus `set 7` on BOTH the reg-0x100 and the
; reg-0x140 words before they are stored to voice+66 / voice+68.
Voice_PitchPack_RouteD:
	dec 4, xsp
	push xiz
	ld (xsp + 4), xwa
	ld xwa, (xsp + 4)
	ld xiz, (xwa + 23)
	ld a, (xiz + 17)
	ld c, a
	extz bc
	ld xwa, (xsp + 4)
	calr TVF_Calc_Cutoff_NoKeyFollow
	ld a, (xiz + 18)
	extz wa
	ld bc, wa
	sll bc, 10
	ld a, (xiz + 18)
	extz wa
	ld de, wa
	sll de, 13
	or de, bc
	ld wa, hl
	or wa, de
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 4)
	ld (xwa + 66), bc
	set 7, hl
	ld xwa, (xsp + 4)
	ld (xwa + 68), hl
	ldw (10560:16), 0
	pop xiz
	inc 4, xsp
	ret

; Pitch-pack route E -- the two-source variant. Calls TVF_Calc_Cutoff_NoKeyFollow twice, once
; with tonerec+0x11 and once with tonerec+0x13, so the two TG pitch registers get
; independent coarse values. voice+66 = contrib(0x11) | (tonerec+0x14)<<10 |
; (tonerec+0x12)<<13 | bit7; voice+68 = contrib(0x13). Clears 0x2940.
Voice_PitchPack_RouteE:
	dec 6, xsp
	push xiz
	ld (xsp + 6), xwa
	ld xwa, (xsp + 6)
	ld xiz, (xwa + 23)
	ld a, (xiz + 17)
	ld c, a
	extz bc
	ld xwa, (xsp + 6)
	calr TVF_Calc_Cutoff_NoKeyFollow
	ld (xsp + 4), hl
	ld a, (xiz + 19)
	ld c, a
	extz bc
	ld xwa, (xsp + 6)
	calr TVF_Calc_Cutoff_NoKeyFollow
	ld a, (xiz + 20)
	extz wa
	ld bc, wa
	sll bc, 10
	ld a, (xiz + 18)
	extz wa
	ld de, wa
	sll de, 13
	or de, bc
	ld wa, (xsp + 4)
	or wa, de
	ld bc, wa
	set 7, bc
	ld xwa, (xsp + 6)
	ld (xwa + 66), bc
	ld xwa, (xsp + 6)
	ld (xwa + 68), hl
	ldw (10560:16), 0
	pop xiz
	inc 6, xsp
	ret

TVF_BuildEmit_Short_Dispatch:
	push xiz
	ld xiz, xwa
	ld xwa, (xiz + 23)
	ld a, (xwa + 15)
	and a, 0x7
	extz wa
	cp wa, 0:i3
	jr mi, TVF_BuildEmit_Short_Dispatch_Table
	cp wa, 5:i3
	jr gt, TVF_BuildEmit_Short_Dispatch_Table
	add wa, wa
	lda xix, (TVF_BuildEmit_Short_CaseOffsets:24)
	ld	wa, (xix+wa)
	lda xix, (TVF_BuildEmit_Short_Dispatch_Table:24)
	jp	t, (xix+wa)

; Landing pad for the dispatcher at 0x024300 (reference name TVF_BuildEmit_Short_Dispatch,
; left alone), which switches on (tonerec+0x0F)&7 using the word table at 0x00F6B3. Case 0
; body is inline here: TVF_Set_Bypass then copy voice+66/voice+68 to
; 0x0451D4/0x0451D6. Cases 1..5 are two-instruction call stubs to TVF_Build_Short..E.
TVF_BuildEmit_Short_Dispatch_Table:
	ld xwa, xiz
	calr TVF_Set_Bypass
	ld wa, (xiz + 66)
	ld (Payload_Bss_Start+0x635e:24), wa
	ld wa, (xiz + 68)
	ld (Payload_Bss_Start+0x6360:24), wa
	jr TVF_BuildEmit_Short_Dispatch_Return
TVF_BuildEmit_Short_Mode1_SingleCutoff:
	ld xwa, xiz
	calr TVF_Build_Short
	jr TVF_BuildEmit_Short_Dispatch_Return
TVF_BuildEmit_Short_Mode2_SingleCutoffBit7:
	ld xwa, xiz
	calr Voice_PitchPack_RouteB
	jr TVF_BuildEmit_Short_Dispatch_Return
TVF_BuildEmit_Short_Mode3_SharedCutoff:
	ld xwa, xiz
	calr Voice_PitchPack_RouteC
	jr TVF_BuildEmit_Short_Dispatch_Return
TVF_BuildEmit_Short_Mode4_SharedCutoffBit7:
	ld xwa, xiz
	calr Voice_PitchPack_RouteD
	jr TVF_BuildEmit_Short_Dispatch_Return
TVF_BuildEmit_Short_Mode5_DualCutoff:
	ld xwa, xiz
	calr Voice_PitchPack_RouteE

; Shared epilogue: pop XIZ, ret.
TVF_BuildEmit_Short_Dispatch_Return:
	pop xiz
	ret

TVF_Emit_Offset_Reg100:
	push xiz
	ld xiz, xwa
	ld xwa, (xiz + 39)
	ld wa, (xwa + 24)
	bit 6, wa
	jr z, Voice_Pan_Write_AsIs
	ld xwa, (xiz + 39)
	ld wa, (xwa + 24)
	bit 7, wa
	jr z, TVF_Emit_Offset_Reg100_Positive
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 66)
	and bc, 0x7F
	sub bc, wa
	ld wa, bc
	jr TVF_Emit_Offset_Reg100_Clamp

; Additive arm (bit 7 of ((voice+39)+0x18) clear): field = (voice+66 & 0x7F) + s8(patch+0x1F).
TVF_Emit_Offset_Reg100_Positive:
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 66)
	and bc, 0x7F
	add bc, wa
	ld wa, bc

; TVF_Clamp_Cutoff the 7-bit field to 0..120, merge under mask 0xFF80 back into voice+66 and
; store to 0x0451D4 (TG reg 0x100).
TVF_Emit_Offset_Reg100_Clamp:
	calr TVF_Clamp_Cutoff
	ld wa, (xiz + 66)
	and wa, 0xFF80
	or wa, hl
	ld (Payload_Bss_Start+0x635e:24), wa
	jr Voice_Pan_WriteSecondary

; Offset disabled (bit 6 of ((voice+39)+0x18) clear): copy voice+66 to 0x0451D4 unchanged.
Voice_Pan_Write_AsIs:
	ld wa, (xiz + 66)
	ld (Payload_Bss_Start+0x635e:24), wa

; Common tail: copy voice+68 to 0x0451D6 (TG reg 0x140) unchanged, pop XIZ, ret.
Voice_Pan_WriteSecondary:
	ld wa, (xiz + 68)
	ld (Payload_Bss_Start+0x6360:24), wa
	pop xiz
	ret

TVF_Emit_Offset_Both:
	push xiz
	ld xiz, xwa
	ld xwa, (xiz + 39)
	ld wa, (xwa + 24)
	bit 6, wa
	jr z, Voice_Pan_WriteBoth_AsIs
	ld xwa, (xiz + 39)
	ld wa, (xwa + 24)
	bit 7, wa
	jr z, Voice_Pan_WriteBoth_Positive
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 66)
	and bc, 0x7F
	sub bc, wa
	ld hl, bc
	jr Voice_Pan_WriteBoth_Clamp

; Additive arm of the "both registers" variant; result kept in HL for the shared clamp.
Voice_Pan_WriteBoth_Positive:
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 66)
	and bc, 0x7F
	add bc, wa
	ld hl, bc

; Clamps the shared 7-bit offset once and merges it into BOTH words: voice+66 under 0xFF80
; -> 0x0451D4, voice+68 under 0xFF80 -> 0x0451D6.
Voice_Pan_WriteBoth_Clamp:
	ld wa, hl
	calr TVF_Clamp_Cutoff
	ld wa, hl
	ld bc, (xiz + 66)
	and bc, 0xFF80
	or bc, wa
	ld (Payload_Bss_Start+0x635e:24), bc
	ld wa, (xiz + 68)
	and wa, 0xFF80
	or wa, hl
	ld (Payload_Bss_Start+0x6360:24), wa
	jr Voice_Pan_WriteBoth_Return

; Offset disabled: copy voice+66/voice+68 verbatim to 0x0451D4/0x0451D6.
Voice_Pan_WriteBoth_AsIs:
	ld wa, (xiz + 66)
	ld (Payload_Bss_Start+0x635e:24), wa
	ld wa, (xiz + 68)
	ld (Payload_Bss_Start+0x6360:24), wa

; pop XIZ, ret.
Voice_Pan_WriteBoth_Return:
	pop xiz
	ret

TVF_Emit_Registers:
	dec 2, xsp
	push xiz
	ld xiz, xwa
	ld xwa, (xiz + 23)
	ld a, (xwa + 54)
	and a, 0x7
	extz wa
	cp wa, 0:i3
	jr mi, TVF_Emit_Registers_Table
	cp wa, 5:i3
	jr gt, TVF_Emit_Registers_Table
	add wa, wa
	lda xix, (TVF_Emit_Registers_CaseOffsets:24)
	ld	wa, (xix+wa)
	lda xix, (TVF_Emit_Registers_Table:24)
	jp	t, (xix+wa)

; Six-case landing pad for the (tonerec+54)&7 dispatcher; offsets from the word table at
; 0x00F6BF (TVF_Emit_Registers_CaseOffsets). Case 0 = verbatim copy of voice+66/+68;
; cases 1 AND 2 = TVF_Emit_Offset_Reg100 (both table entries are +0x13); case 3 = the same
; but gated on bit 9 of (patch+2), else TVF_Emit_Offset_Both; case 4 = TVF_Emit_Offset_Both;
; case 5 = the inline arms below.
; ★ CORRECTED 2026-09-25: this said "case 2 = same but gated on bit 9 of (patch+2); cases
; 3/4 = TVF_Emit_Offset_Both" -- one case off: the table's entries 1..5 are +0x13 +0x13
; +0x1B +0x36 +0x3E, so the gated body is case 3 and only case 4 is the plain Both call.
TVF_Emit_Registers_Table:
	ld wa, (xiz + 66)
	ld (Payload_Bss_Start+0x635e:24), wa
	ld wa, (xiz + 68)
	ld (Payload_Bss_Start+0x6360:24), wa
	jrl TVF_Emit_Registers_Return
; TVF_Emit_Registers_Mode1Or2_OffsetCutoffWord: Modes 1 and 2 (single cutoff): the part offset is applied to the
;   +0x100 word only.
TVF_Emit_Registers_Mode1Or2_OffsetCutoffWord:
	ld xwa, xiz
	calr TVF_Emit_Offset_Reg100
	jrl TVF_Emit_Registers_Return
TVF_Emit_Registers_Mode3_OffsetOneOrBothWords:
	ld xwa, (xiz + 35)
	ld wa, (xwa + 2)
	bit 9, wa
	jr z, TVF_Emit_Registers_Case3_Bit9Clear
	ld xwa, xiz
	calr TVF_Emit_Offset_Reg100
	jrl TVF_Emit_Registers_Return

; Bit-9-clear arm of case 3 (was "case 2", see the ★ CORRECTED note above): use the "both
; registers" offset routine instead.
TVF_Emit_Registers_Case3_Bit9Clear:
	ld xwa, xiz
	calr TVF_Emit_Offset_Both
	jrl TVF_Emit_Registers_Return
TVF_Emit_Registers_Mode4_OffsetBothWords:
	ld xwa, xiz
	calr TVF_Emit_Offset_Both
	jrl TVF_Emit_Registers_Return
TVF_Emit_Registers_Mode5_OffsetEachWord:
	ld xwa, (xiz + 39)
	ld wa, (xwa + 24)
	bit 6, wa
	jrl z, TVF_Emit_Registers_Mode5_AsIs
	ld xwa, (xiz + 39)
	ld wa, (xwa + 24)
	bit 7, wa
	jr z, TVF_Emit_Registers_Mode5_Positive
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 66)
	and bc, 0x7F
	sub bc, wa
	ld de, bc
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 68)
	and bc, 0x7F
	sub bc, wa
	ld (xsp + 4), bc
	jr TVF_Emit_Registers_Mode5_Finalize

; Case-5 additive arm: (voice+66 & 0x7F) + s8(patch+0x1F) into DE, (voice+68 & 0x7F) +
; s8(patch+0x1F) into (xsp+4).
TVF_Emit_Registers_Mode5_Positive:
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 66)
	and bc, 0x7F
	add bc, wa
	ld de, bc
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 68)
	and bc, 0x7F
	add bc, wa
	ld (xsp + 4), bc

; Clamps both offsets to 0..120 independently, merges each under 0xFF80 and stores to
; 0x0451D4 / 0x0451D6.
TVF_Emit_Registers_Mode5_Finalize:
	ld wa, de
	calr TVF_Clamp_Cutoff
	ld wa, (xiz + 66)
	and wa, 0xFF80
	or wa, hl
	ld (Payload_Bss_Start+0x635e:24), wa
	ld wa, (xsp + 4)
	calr TVF_Clamp_Cutoff
	ld wa, (xiz + 68)
	and wa, 0xFF80
	or wa, hl
	ld (Payload_Bss_Start+0x6360:24), wa
	jr TVF_Emit_Registers_Return

; Case-5 with the offset disabled (bit 6 of ((voice+39)+0x18) clear): verbatim copy.
TVF_Emit_Registers_Mode5_AsIs:
	ld wa, (xiz + 66)
	ld (Payload_Bss_Start+0x635e:24), wa
	ld wa, (xiz + 68)
	ld (Payload_Bss_Start+0x6360:24), wa

; pop XIZ, inc 2 xsp, ret.
TVF_Emit_Registers_Return:
	pop xiz
	inc 2, xsp
	ret

; TVF_Emit_Registers_Type2: TVF_Emit_Registers for the type-2 voices (class (voice+1) & 0x3C = 0x10): the same six cases, with
;   the mode from (tonerec+0x0F) & 7 instead of (tonerec+0x36) & 7 and the offsets in
;   TVF_Emit_Registers_Type2_CaseOffsets; it writes the same staging words 0x0451D4 / 0x0451D6, which
;   ToneGen_WriteVoice_TvfPair sends to TG registers 0x100 / 0x140 (the TVF pair).  In: XWA = per-voice record.
;   The A/B pair mirrors the two parameter groups of the tone record (cluster 0x0F..0x16 vs 0x36..0x3C,
;   0x4D..0x50).  Basis: callers + body -- TVF_Refresh_Sounding_Voices calls it for class 0x10 and
;   TVF_Emit_Registers for 4 / 0x20; Voice_Init_Type2 calls it.  (Was Voice_PanReg_WriteDispatchB.)
TVF_Emit_Registers_Type2:
	dec 2, xsp
	push xiz
	ld xiz, xwa
	ld xwa, (xiz + 23)
	ld a, (xwa + 15)
	and a, 0x7
	extz wa
	cp wa, 0:i3
	jr mi, TVF_Emit_Registers_Type2_Table
	cp wa, 5:i3
	jr gt, TVF_Emit_Registers_Type2_Table
	add wa, wa
	lda xix, (TVF_Emit_Registers_Type2_CaseOffsets:24)
	ld	wa, (xix+wa)
	lda xix, (TVF_Emit_Registers_Type2_Table:24)
	jp	t, (xix+wa)

; Landing pad for dispatch B; same six cases as 0x024472.
TVF_Emit_Registers_Type2_Table:
	ld wa, (xiz + 66)
	ld (Payload_Bss_Start+0x635e:24), wa
	ld wa, (xiz + 68)
	ld (Payload_Bss_Start+0x6360:24), wa
	jrl TVF_Emit_Registers_Type2_Return
; TVF_Emit_Registers_Type2_Mode1Or2_OffsetCutoffWord: Modes 1 and 2 (single cutoff): the part offset is applied to
;   the +0x100 word only.
TVF_Emit_Registers_Type2_Mode1Or2_OffsetCutoffWord:
	ld xwa, xiz
	calr TVF_Emit_Offset_Reg100
	jrl TVF_Emit_Registers_Type2_Return
TVF_Emit_Registers_Type2_Mode3_OffsetOneOrBothWords:
	ld xwa, (xiz + 35)
	ld wa, (xwa + 2)
	bit 9, wa
	jr z, TVF_Emit_Registers_Type2_Case3_Bit9Clear
	ld xwa, xiz
	calr TVF_Emit_Offset_Reg100
	jrl TVF_Emit_Registers_Type2_Return

; Bit-9-clear arm of case 3 in dispatch B (was "case 2": entries 1 and 2 of
; TVF_Emit_Registers_Type2_CaseOffsets are both +0x13, entry 3 is this gated body).
TVF_Emit_Registers_Type2_Case3_Bit9Clear:
	ld xwa, xiz
	calr TVF_Emit_Offset_Both
	jrl TVF_Emit_Registers_Type2_Return
TVF_Emit_Registers_Type2_Mode4_OffsetBothWords:
	ld xwa, xiz
	calr TVF_Emit_Offset_Both
	jrl TVF_Emit_Registers_Type2_Return
TVF_Emit_Registers_Type2_Mode5_OffsetEachWord:
	ld xwa, (xiz + 39)
	ld wa, (xwa + 24)
	bit 6, wa
	jrl z, TVF_Emit_Registers_Type2_Mode5_AsIs
	ld xwa, (xiz + 39)
	ld wa, (xwa + 24)
	bit 7, wa
	jr z, TVF_Emit_Registers_Type2_Mode5_Positive
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 66)
	and bc, 0x7F
	sub bc, wa
	ld de, bc
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 68)
	and bc, 0x7F
	sub bc, wa
	ld (xsp + 4), bc
	jr TVF_Emit_Registers_Type2_Mode5_Finalize

; Case-5 additive arm in dispatch B.
TVF_Emit_Registers_Type2_Mode5_Positive:
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 66)
	and bc, 0x7F
	add bc, wa
	ld de, bc
	ld xwa, (xiz + 35)
	ld a, (xwa + 31)
	exts wa
	ld bc, (xiz + 68)
	and bc, 0x7F
	add bc, wa
	ld (xsp + 4), bc

; Case-5 clamp-and-emit in dispatch B.
TVF_Emit_Registers_Type2_Mode5_Finalize:
	ld wa, de
	calr TVF_Clamp_Cutoff
	ld wa, (xiz + 66)
	and wa, 0xFF80
	or wa, hl
	ld (Payload_Bss_Start+0x635e:24), wa
	ld wa, (xsp + 4)
	calr TVF_Clamp_Cutoff
	ld wa, (xiz + 68)
	and wa, 0xFF80
	or wa, hl
	ld (Payload_Bss_Start+0x6360:24), wa
	jr TVF_Emit_Registers_Type2_Return

; Case-5 verbatim copy in dispatch B.
TVF_Emit_Registers_Type2_Mode5_AsIs:
	ld wa, (xiz + 66)
	ld (Payload_Bss_Start+0x635e:24), wa
	ld wa, (xiz + 68)
	ld (Payload_Bss_Start+0x6360:24), wa

; pop XIZ, inc 2 xsp, ret.
TVF_Emit_Registers_Type2_Return:
	pop xiz
	inc 2, xsp
	ret

; ENVELOPE 3 -- staged into the words that reach TG banks +0x9C0 / +0xA00 / +0xA40, i.e.
; IC303 registers r0x27 / r0x28 / r0x29.
; In: XWA = voice-slot record. Out: the staging words 0x0451F2, 0x0451F4, 0x0451F6.
; Callers: Voice_Build_Register_Set (0x02B4E3) and Voice_Release_Type4 (0x02BCD6) -- type-4
; voices only; on the type-1/type-2 path Voice_Level_ClearAllOutputRegs zeroes these three
; words instead and this routine never runs.
;
; BASE-RECORD CORRECTION: the record read here is paramA, the u32 at slot+0x17 -- the
; prologue is `ld xwa, (xwa+23)`, and that 23 is DECIMAL (0x17), not 0x23. It is NOT the tone
; record: that is the pointer at slot+0x23 = decimal 35, as
; Voice_Calc_LevelPair_Full_OscTablePath states. Every "tonerec+NN" written in the comments
; from here to Voice_StereoLevel_PackCh23 means paramA+NN, and those NN are decimal.
;
; Word format (target << 8) | rate, one couple per segment:
;   seg 0  target Voice_EnvelopeLevel_Curve[paramA+0x3F]   low byte from paramA+0x40
;   seg 1  target Voice_EnvelopeLevel_Curve[paramA+0x41]   low byte from paramA+0x42
;   seg 2  target Voice_EnvelopeLevel_Curve[paramA+0x43]   low byte from paramA+0x44
; Each low byte = Detune_ScaleSymmetric(clamp((i8)paramA+0x3D + (i8)offset, -0x32..+0x32)),
; so it is SIGNED, -0x7F..+0x7F, exactly as in envelope 2 and unlike envelope 1's unsigned
; Voice_EnvelopeRate_Table lookup. paramA+0x3D is a bias shared by all three segments (and
; by r0x23, which Voice_PortaLevel_Compute builds from paramA+0x3D + paramA+0x3E).
; [INFERENCE] naming that byte a "rate" is an analogy with envelope 1's documented word
; format, not a result -- see the same caveat at Voice_Level_ComputeTriplet.
; Targets take a shared key scale PitchBend_Scale(paramA+0x47, slot+0x0C, shift 4) when
; paramA+0x47 != 0, plus Pan_ScaleWithVelocity(baseline paramA+0x49, limits 0..0x7F,
; control word slot+0x08) with depth paramA+0x4A on segment 0 and paramA+0x4B shared by
; segments 1/2; each is then clamped 0..0xFF. 0xFF is the silent end of the curve.
;
; This parameter block is envelope 2's block moved up 54 bytes (see
; Voice_Level_ComputeTriplet for the 14-offset correspondence), with one role difference:
; paramA+0x07 is a sign flag that NEGATES envelope 2's low bytes, while paramA+0x3D is ADDED
; to envelope 3's before the +-0x32 clamp.
;
; CONFIDENCE MEDIUM, UNCHANGED: everything above is the SOURCE side -- which bytes the
; firmware puts in these words and when. What IC303 does with registers 0x27..0x29 is still
; not proved here; the register meanings in technics-docs/tone-generator.md (which reads
; +0x09C0/+0x0A00/+0x0A40 as aux/effect send levels, not as an envelope) are that document's
; reading, and it disagrees with the envelope reading recorded in the staging-block header.
Voice_StereoLevel_Compute:
	lda xsp, (xsp - 14)
	pushw iz
	ld (xsp + 12), xwa
	ld xwa, (xsp + 12)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	cp (xwa + 71), 0x0
	jrl z, Voice_StereoLevel_AllUnmodulated
	ld xwa, (xsp + 2)
	ld a, (xwa + 71)
	ld e, a
	exts de
	ld xwa, (xsp + 12)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 4:i3
	calr PitchBend_Scale
	ld xwa, (xsp + 2)
	cp (xwa + 63), 0x0
	jr z, Voice_StereoLevel_Ch1_Unmodulated
	ld de, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 63)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	add wa, de
	ld (xsp + 6), wa
	jr Voice_StereoLevel_Ch2_Modulated

; Channel-1 level with no key-scaling term: table[0x0118FE + tonerec+63] straight to (xsp+6).
Voice_StereoLevel_Ch1_Unmodulated:
	ld xwa, (xsp + 2)
	ld a, (xwa + 63)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 6), wa

; Channel-2 level plus the key-scaled term still held in HL.
Voice_StereoLevel_Ch2_Modulated:
	ld xwa, (xsp + 2)
	cp (xwa + 65), 0x0
	jr z, Voice_StereoLevel_Ch2_Unmodulated
	ld de, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 65)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	add wa, de
	ld (xsp + 8), wa
	jr Voice_StereoLevel_Ch3_Modulated

; Channel-2 level, table value only.
Voice_StereoLevel_Ch2_Unmodulated:
	ld xwa, (xsp + 2)
	ld a, (xwa + 65)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 8), wa

; Channel-3 level plus the key-scaled term.
Voice_StereoLevel_Ch3_Modulated:
	ld xwa, (xsp + 2)
	cp (xwa + 67), 0x0
	jr z, Voice_StereoLevel_Ch3_Unmodulated
	ld xwa, (xsp + 2)
	ld a, (xwa + 67)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	add wa, hl
	ld (xsp + 10), wa
	jr Voice_StereoLevel_ApplyTremolo

; Channel-3 level, table value only.
Voice_StereoLevel_Ch3_Unmodulated:
	ld xwa, (xsp + 2)
	ld a, (xwa + 67)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 10), wa
	jr Voice_StereoLevel_ApplyTremolo

; Fast path taken when tonerec+71 == 0: all three levels are plain table lookups.
Voice_StereoLevel_AllUnmodulated:
	ld xwa, (xsp + 2)
	ld a, (xwa + 63)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 6), wa
	ld xwa, (xsp + 2)
	ld a, (xwa + 65)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 8), wa
	ld xwa, (xsp + 2)
	ld a, (xwa + 67)
	extz wa
	lda xbc, (Voice_EnvelopeLevel_Curve:24)
	ld	a, (xbc+wa)
	extz wa
	ld (xsp + 10), wa

; If tonerec+74 != 0, adds Pan_ScaleWithVelocity(tonerec+73, 0x7F, s8(tonerec+74),
; (voice+8)) to the channel-1 level.
Voice_StereoLevel_ApplyTremolo:
	ld xwa, (xsp + 2)
	cp (xwa + 74), 0x0
	jr z, Voice_StereoLevel_PackCh1
	ld xwa, (xsp + 2)
	ld a, (xwa + 73)
	ld c, a
	extz bc
	pushw 0x7F
	ld xwa, (xsp + 4)
	ld a, (xwa + 74)
	exts wa
	pushw wa
	ld xwa, (xsp + 16)
	ld wa, (xwa + 8)
	ld de, 0:i3
	calr Pan_ScaleWithVelocity
	add (xsp + 6), hl

; Clamps channel 1 to 0..0xFF, computes the signed low-byte coefficient from
; tonerec+61 + tonerec+64 clamped to -0x32..+0x32 through Detune_ScaleSymmetric, and stores
; (level<<8)|coeff to 0x0451F2 (TG reg 0x9C0). Then optionally applies the tonerec+75
; modulation to channels 2 and 3.
Voice_StereoLevel_PackCh1:
	ld wa, (xsp + 6)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 6), hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 61)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 64)
	exts wa
	add wa, bc
	ldw bc, 0x32
	ldw de, 0xFFCE
	calr Int_ClampSignedToRange
	ld wa, hl
	calr Detune_ScaleSymmetric
	ld h, 0x0:opc
	ld wa, (xsp + 6)
	sla wa, 8
	or wa, hl
	ld (Payload_Bss_Start+0x637c:24), wa
	ld xwa, (xsp + 2)
	cp (xwa + 75), 0x0
	jr z, Voice_StereoLevel_ClampCh23_NoMod
	ld xwa, (xsp + 2)
	ld a, (xwa + 73)
	ld c, a
	extz bc
	pushw 0x7F
	ld xwa, (xsp + 4)
	ld a, (xwa + 75)
	exts wa
	pushw wa
	ld xwa, (xsp + 16)
	ld wa, (xwa + 8)
	ld de, 0:i3
	calr Pan_ScaleWithVelocity
	ld iz, hl
	ld wa, (xsp + 8)
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 8), hl
	ld wa, (xsp + 10)
	add wa, iz
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl
	jr Voice_StereoLevel_PackCh23

; tonerec+75 == 0: clamp channels 2 and 3 to 0..0xFF with no added modulation.
Voice_StereoLevel_ClampCh23_NoMod:
	ld wa, (xsp + 8)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 8), hl
	ld wa, (xsp + 10)
	ldw bc, 0xFF
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 10), hl

; Packs and stores channels 2 and 3 to 0x0451F4 (TG reg 0xA00) and 0x0451F6 (TG reg 0xA40),
; each with its own Detune_ScaleSymmetric coefficient from tonerec+61 + tonerec+66 / +68.
Voice_StereoLevel_PackCh23:
	ld xwa, (xsp + 2)
	ld a, (xwa + 61)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 66)
	exts wa
	add wa, bc
	ldw bc, 0x32
	ldw de, 0xFFCE
	calr Int_ClampSignedToRange
	ld iz, hl
	ld wa, iz
	calr Detune_ScaleSymmetric
	ld iz, hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 61)
	ld c, a
	exts bc
	ld xwa, (xsp + 2)
	ld a, (xwa + 68)
	exts wa
	add wa, bc
	ldw bc, 0x32
	ldw de, 0xFFCE
	calr Int_ClampSignedToRange
	ld wa, hl
	calr Detune_ScaleSymmetric
	ld wa, iz
	ld w, 0x0:opc
	ld bc, (xsp + 8)
	sla bc, 8
	or bc, wa
	ld (Payload_Bss_Start+0x637e:24), bc
	ld h, 0x0:opc
	ld wa, (xsp + 10)
	sla wa, 8
	or wa, hl
	ld (Payload_Bss_Start+0x6380:24), wa
	popw iz
	lda xsp, (xsp + 14)
	ret

; Builds the pair emitted as TG registers 0x500 (0x0451E2) and 0x8C0 (0x0451EA).
; In: XWA = per-voice record. Sign-splits tonerec+7 and tonerec+8: if tonerec+7 is negative
; both bytes are negated before scaling (Detune_ScaleUnsigned for +7, Detune_ScaleSymmetric
; for +8), so the routine has a mirrored positive arm at 0x024911. The scaled values are
; then combined with tonerec+18 and the note number (voice+12) in the tail.
Voice_PortaLevel_Compute:
	lda xsp, (xsp - 12)
	pushw iz
	ld (xsp + 10), xwa
	ld xwa, (xsp + 10)
	ld xwa, (xwa + 23)
	ld (xsp + 2), xwa
	cp (xwa + 7), 0x0
	jr ge, Voice_PortaLevel_Compute_Positive
	ld xwa, (xsp + 2)
	ld a, (xwa + 7)
	exts wa
	cpl wa
	inc 1, wa
	calr Detune_ScaleUnsigned
	ld (xsp + 8), hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 8)
	exts wa
	cpl wa
	inc 1, wa
	calr Detune_ScaleSymmetric
	ld (xsp + 6), hl
	jr Voice_PortaLevel_ScaleAndPack

; Positive/zero arm: scale tonerec+7 and tonerec+8 directly, no negation.
Voice_PortaLevel_Compute_Positive:
	ld xwa, (xsp + 2)
	ld a, (xwa + 7)
	exts wa
	calr Detune_ScaleUnsigned
	ld (xsp + 8), hl
	ld xwa, (xsp + 2)
	ld a, (xwa + 8)
	exts wa
	calr Detune_ScaleSymmetric
	ld (xsp + 6), hl

; Shared tail: scales by tonerec+18 against the note number, packs and stores the two words
; to 0x0451E2 (TG reg 0x500) and 0x0451EA (TG reg 0x8C0).
Voice_PortaLevel_ScaleAndPack:
	ld xwa, (xsp + 2)
	ld a, (xwa + 18)
	ld e, a
	exts de
	ld xwa, (xsp + 10)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 6:i3
	calr PitchBend_Scale
	add (xsp + 8), hl
	ld wa, (xsp + 8)
	ldw bc, 0x7F
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld (xsp + 8), hl
	ldw iz, 0x7F
	ld xwa, (xsp + 2)
	ld a, (xwa + 72)
	ld e, a
	exts de
	ld xwa, (xsp + 10)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld wa, de
	ld de, 6:i3
	calr PitchBend_Scale
	add iz, hl
	ld wa, iz
	ldw bc, 0x7F
	ld de, 0:i3
	calr Int_ClampSignedToRange
	ld iz, hl
	ld wa, iz
	ld bc, wa
	ld b, 0x0:opc
	ld wa, (xsp + 8)
	sll wa, 8
	or wa, bc
	ld (Payload_Bss_Start+0x636c:24), wa
	ld xwa, (xsp + 2)
	ld c, (xwa + 61)
	ld xwa, (xsp + 2)
	add c, (xwa + 62)
	ld a, c
	exts wa
	calr Detune_ScaleSymmetric
	ld h, 0x0:opc
	ld wa, (xsp + 6)
	sll wa, 8
	or wa, hl
	ld (Payload_Bss_Start+0x6374:24), wa
	popw iz
	lda xsp, (xsp + 12)
	ret

; Zeroes the whole level half of the staging block: 0x0451EA, 0x0451E2, 0x0451EC,
; 0x0451EE, 0x0451F0, 0x0451F2, 0x0451F4, 0x0451F6, 0x0451DC, 0x0451DE (TG regs 0x8C0,
; 0x500, 0x900, 0x940, 0x980, 0x9C0, 0xA00, 0xA40, 0x440, 0x480).
; In: XWA = per-voice record, XHL = its tone record. Then it selects the reg-0x180 value
; from the part's TG pan mode byte (CC 0x9D) at 0x04138E + channel*0x11F: value 1 -> voice+43 = 0,
; value 2 -> voice+43 = 0x7F, anything else -> voice+43 = tonerec[0]. voice+43 is stored to
; 0x0451D8 (TG reg 0x180) and 0x0451E0 (TG reg 0x4C0) is zeroed.
; NOT teardown-only, and "silence" is not established. The only two callers are
; Voice_Init_Type2 (reached from the Voice_SetVelocity_Type0 / _Type80 note-on paths) and
; Voice_Init_Type1 (reached from Voice_SetPitch and from Voice_NoteOff); there are no
; indirect references. So this runs on every type-1/type-2 parameter rebuild, note-on
; included, and its role there is to leave envelope 1 in sole charge of the level -- those
; voice types never build envelopes 2 and 3 (Voice_Level_ComputeTriplet and
; Voice_StereoLevel_Compute are called only from the type-4 paths).
; [INFERENCE] the value written is 0x0000, which is NOT the firmware's mute word: the mute
; idiom is r0x21 <- 0xFF00 / r0x20 <- 0xFF80, and both level curves put the silent end at
; 0xFF (see the staging-block header). But that evidence covers banks +0x800/+0x840, and
; this routine writes none of them -- it clears +0x8C0, +0x500, +0x900, +0x940, +0x980,
; +0x9C0, +0xA00, +0xA40, +0x440 and +0x480. What 0x0000 means in those banks is unproved:
; under the envelope reading it is a target below the loud end of the curve, while
; technics-docs/tone-generator.md reads several of them as effect sends, where 0 = no send.
Voice_Level_ClearAllOutputRegs:
	ld xhl, (xwa + 23)
	ldw (Payload_Bss_Start+0x6374:24), 0x0000
	ldw (Payload_Bss_Start+0x636c:24), 0x0000
	ldw (Payload_Bss_Start+0x6376:24), 0x0000
	ldw (Payload_Bss_Start+0x6378:24), 0x0000
	ldw (Payload_Bss_Start+0x637a:24), 0x0000
	ldw (Payload_Bss_Start+0x637c:24), 0x0000
	ldw (Payload_Bss_Start+0x637e:24), 0x0000
	ldw (Payload_Bss_Start+0x6380:24), 0x0000
	ldw (Payload_Bss_Start+0x6366:24), 0x0000
	ldw (Payload_Bss_Start+0x6368:24), 0x0000
	ld c, (xwa + 4)
	extz bc
	muls bc, 0x11F
	lda xde, (Payload_Bss_Start+0x2518:24)
	cp	(xde+bc), 0x01
	jr nz, Voice_Level_ClearAllOutputRegs_Check2
	ldw (xwa + 43), 0x0
	jr Voice_Level_ClearAllOutputRegs_Store

; Second routing-byte comparison (== 2 -> voice+43 = 0x7F).
Voice_Level_ClearAllOutputRegs_Check2:
	ld c, (xwa + 4)
	extz bc
	muls bc, 0x11F
	lda xde, (Payload_Bss_Start+0x2518:24)
	cp	(xde+bc), 0x02
	jr nz, Voice_Level_ClearAllOutputRegs_FromTable
	ldw (xwa + 43), 0x7F
	jr Voice_Level_ClearAllOutputRegs_Store

; Default arm: voice+43 = first byte of the tone record.
Voice_Level_ClearAllOutputRegs_FromTable:
	ld c, (xhl)
	extz bc
	ld (xwa + 43), bc

; Store voice+43 to 0x0451D8 (TG reg 0x180), clear 0x0451E0 (TG reg 0x4C0), ret.
Voice_Level_ClearAllOutputRegs_Store:
	ld wa, (xwa + 43)
	ld (Payload_Bss_Start+0x6362:24), wa
	ldw (Payload_Bss_Start+0x636a:24), 0x0000
	ret

; Writes one operator/slot's envelope parameters into the physical slot record.
; In: A = channel, E = operator index, C/(xsp+20) = slot number, (xsp+22) = group index,
; XBC = patch record pointer. Computes three bases: 0x04136E + channel*0x11F (per-voice
; operator parameters), 0x041368 + channel*0x11F, and 0x04424E + slot*0x1B (the physical
; slot record, XIZ). Unless the direct path is taken it offsets each parameter by the signed
; bytes at patch+104/105/106 and clamps (0..0x7F, 0..0x7F, 0..0x1E) before storing to
; slotrec+1, +3 and +7.
; The direct/bypass path is chosen when the group index == 2, or the operator index == 0,
; or the byte at 0x0451A7 == 0xF5 (a global "raw parameters" mode flag).
Voice_OpSlot_WriteParams:
	lda xsp, (xsp - 12)
	push xiz
	ld (xsp + 12), xbc
	ld l, (xsp + 22)
	ld c, e
	extz bc
	ld ix, bc
	sla ix, 2
	ld c, l
	extz bc
	sla bc, 4
	ld iy, bc
	add iy, ix
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xbc, (xix+bc)
	lda	xbc, (xbc+iy)
	ld (xsp + 4), xbc
	ld xbc, 0x2B
	add (xsp + 4), xbc
	ld c, l
	extz bc
	muls bc, 0x9
	ld iy, bc
	ld c, (xsp + 20)
	extz bc
	muls bc, 0x1B
	lda xix, (Payload_Bss_Start+0x53d8:24)
	exts xbc
	add xbc, xix
	lda	xiz, (xbc+iy)
	ld c, e
	extz bc
	ld ix, bc
	sla ix, 2
	ld c, l
	extz bc
	sla bc, 4
	ld iy, bc
	add iy, ix
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_Record_Base:24)
	exts xwa
	add xwa, xbc
	lda	xwa, (xwa+iy)
	ld (xsp + 8), xwa
	ld xwa, 0x27
	add (xsp + 8), xwa
	cp l, 2:i3
	jr z, Voice_OpSlot_WriteParams_Direct
	cp e, 0:i3
	jr nz, Voice_OpSlot_WriteParams_Direct
	cp (Payload_Bss_Start+0x6331:24), 0xf5
	jr z, Voice_OpSlot_WriteParams_Direct
	ld xwa, (xsp + 12)
	ld a, (xwa + 104)
	ld c, a
	exts bc
	ld xwa, (xsp + 4)
	ld a, (xwa)
	extz wa
	add wa, bc
	ldw bc, 0x7F
	ld de, 0:i3
	calr ClampS16_WA_Short
	ld (xiz + 1), l
	ld xwa, (xsp + 12)
	ld a, (xwa + 105)
	ld c, a
	exts bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 1)
	extz wa
	add wa, bc
	ldw bc, 0x7F
	ld de, 0:i3
	calr ClampS16_WA_Short
	ld (xiz + 3), l
	ld xwa, (xsp + 12)
	ld a, (xwa + 106)
	ld c, a
	exts bc
	ld xwa, (xsp + 4)
	ld a, (xwa + 3)
	and a, 0x3F
	extz wa
	add wa, bc
	ldw bc, 0x1E
	ld de, 0:i3
	calr ClampS16_WA_Short
	ld (xiz + 7), l
	jr Voice_OpSlot_ApplySustainPedal

; Bypass path: copy the three parameter bytes into slotrec+1/+3/+7 with no patch offset
; and no clamping.
Voice_OpSlot_WriteParams_Direct:
	ld xwa, (xsp + 4)
	ld a, (xwa)
	ld (xiz + 1), a
	ld xwa, (xsp + 4)
	ld a, (xwa + 1)
	ld (xiz + 3), a
	ld xwa, (xsp + 4)
	ld a, (xwa + 3)
	and a, 0x3F
	ld (xiz + 7), a

; If the sustain bit is set in the per-voice flag word, forces the release segment of this
; slot record to the sustain-pedal value instead of the patch value.
Voice_OpSlot_ApplySustainPedal:
	ld xwa, (xsp + 8)
	bitm 1, (xwa)
	jr z, Voice_OpSlot_SustainRelease_Set
	ld xwa, (xsp + 8)
	ld a, (xwa + 3)
	ld (xiz + 2), a
	ld (xiz + 7), 0x0
	jr Voice_OpSlot_ApplySostenuto

; Two-instruction store of the sustain-pedal release value.
Voice_OpSlot_SustainRelease_Set:
	ld (xiz + 2), 0x80

; Same test/override for the sostenuto pedal.
Voice_OpSlot_ApplySostenuto:
	ld xwa, (xsp + 8)
	bitm 3, (xwa)
	jr z, Voice_OpSlot_SostenutoRelease_Set
	ld xwa, (xsp + 8)
	ld a, (xwa + 2)
	ld (xiz + 4), a
	ld (xiz + 7), 0x0
	jr Voice_OpSlot_CopyWaveformBits

; Two-instruction store of the sostenuto release value.
Voice_OpSlot_SostenutoRelease_Set:
	ld (xiz + 4), 0x80

; Copies the waveform-select bits from the patch record into the slot record.
Voice_OpSlot_CopyWaveformBits:
	ld xwa, (xsp + 4)
	bitm 7, (xwa + 2)
	jr z, Voice_OpSlot_ClearWaveformBit5
	setm 5, (xiz)
	jr Voice_OpSlot_PackEnvelopeBits

; Single `res 5` on the waveform byte.
Voice_OpSlot_ClearWaveformBit5:
	resm 5, (xiz)

; Final packing of the envelope-shape bit-field into the slot record; restores XIZ and returns.
Voice_OpSlot_PackEnvelopeBits:
	ld xwa, (xsp + 4)
	ld a, (xwa + 3)
	and a, 0xC0
	extz wa
	srl wa, 6
	andmi8 (xiz), 0xFC
	or (xiz), a
	ld xwa, (xsp + 4)
	ld a, (xwa + 2)
	res 7, a
	ld (xiz + 5), a
	pop xiz
	lda xsp, (xsp + 12)
	retd 0x4

ExtVoice_Build_SlotRegisters:
	lda xsp, (xsp - 22)
	push xiz
	ld (xsp + 22), xwa
	ldw (Payload_Bss_Start+0x6366:24), 0x0000
	ldw (Payload_Bss_Start+0x6368:24), 0x0000
	ld xwa, (xsp + 22)
	ld xwa, (xwa + 35)
	ld (xsp + 4), xwa
	ld xwa, (xsp + 22)
	ld xwa, (xwa + 39)
	ld (xsp + 8), xwa
	ld xwa, (xsp + 22)
	ld a, (xwa + 4)
	ld (xsp + 16), a
	ld xwa, (xsp + 22)
	ld a, (xwa + 3)
	ld (xsp + 18), a
	ld xwa, (xsp + 8)
	cpw (xwa + 26), 0x0
	jrl z, Voice_Chan_Fallback_NoWaveTable
	ld xwa, (xsp + 8)
	ld wa, (xwa + 26)
	and a, 0x3
	ld (xsp + 20), a
	extz wa
	sla wa, 2
	ld bc, wa
	add bc, 0x2B
	ld xwa, (xsp + 22)
	ld xwa, (xwa + 19)
	lda	xwa, (xwa+bc)
	bitm 7, (xwa + 2)
	jr z, ExtVoice_Build_SlotRegisters_NoAlgoSelect
	ld a, (xsp + 16)
	ld l, a
	extz hl
	ld xwa, (xsp + 22)
	ld a, (xwa)
	ld c, a
	extz bc
	ld a, (xsp + 20)
	extz wa
	set 5, wa
	ld e, a
	extz de
	ld wa, hl
	call ExtVoice_Alloc_StreamSlot
	ld (xsp + 12), hl
	ld wa, (xsp + 12)
	ld w, 0x0:opc
	ld (xsp + 14), wa
	call ToneGen_WriteExtParam_600_Mute
	jr ExtVoice_Store_SlotNumber

; Taken when bit 7 of (partrec+2) is clear: identical ExtVoice_Alloc_StreamSlot call but the group
; index passed in E has bit 5 clear, and ToneGen_WriteExtParam_600_Mute is NOT issued first.
ExtVoice_Build_SlotRegisters_NoAlgoSelect:
	ld a, (xsp + 16)
	ld l, a
	extz hl
	ld xwa, (xsp + 22)
	ld a, (xwa)
	ld c, a
	extz bc
	ld a, (xsp + 20)
	extz wa
	ld e, a
	extz de
	ld wa, hl
	call ExtVoice_Alloc_StreamSlot
	ld (xsp + 12), hl
	ld wa, (xsp + 12)
	ld w, 0x0:opc
	ld (xsp + 14), wa

ExtVoice_Store_SlotNumber:
	ld wa, (xsp + 14)
	extz xwa
	ld xbc, 0x1B
	call Math_Multiply32
	lda xiz, (Payload_Bss_Start+0x53d8:24)
	add xiz, xhl
	ld xwa, (xsp + 22)
	ld a, (xwa + 12)
	res 7, a
	ld (xiz + 6), a
	cpw (xsp + 14), 0x80
	jrl nc, Voice_Chan_SecondaryPitch_Trigger
	ld xwa, (xsp + 8)
	ld wa, (xwa + 26)
	and wa, 0xC0
	or wa, (xsp + 14)
	ld (Payload_Bss_Start+0x6366:24), wa
	ld wa, (xsp + 12)
	bit 15, wa
	jr z, Voice_Chan_WriteOpSlots
	ld xwa, (xsp + 4)
	ld wa, (xwa)
	and wa, 0xC
	jr z, Voice_Chan_CheckPitchEnvGate

; Calls Voice_OpSlot_WriteParams for the resolved slot, computes the envelope level with
; EGEnv_Compute_A_Simple into 0x045208 (TG reg 0x580), then hands the whole block at
; 0x0451CC to ToneGen_WriteExtParams_56_Alt.
Voice_Chan_WriteOpSlots:
	ld a, (xsp + 16)
	ld c, a
	extz bc
	ld a, (xsp + 20)
	ld e, a
	extz de
	pushw 0x0
	ld wa, (xsp + 16)
	extz wa
	pushw wa
	ld wa, bc
	ld xbc, (xsp + 8)
	calr Voice_OpSlot_WriteParams
	ld wa, (xsp + 14)
	extz wa
	calr EGEnv_Compute_A_Simple
	ld (Payload_Bss_Start+0x6392:24), hl
	ld wa, (xsp + 14)
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_56_Alt

; Decides whether the pitch-envelope generator has to be re-triggered: slotstate+7 == 0, or
; bit 13 of (partrec+2) set.
Voice_Chan_CheckPitchEnvGate:
	cp (xiz + 7), 0x0
	jr z, Voice_Chan_PitchEnvGate_CheckBit5
	ld xwa, (xsp + 4)
	ld wa, (xwa + 2)
	bit 13, wa
	jr nz, Voice_Chan_PitchEnvGate_Trigger

; Secondary condition: bit 5 of slotstate[0].
Voice_Chan_PitchEnvGate_CheckBit5:
	bitm 5, (xiz)
	jr z, Voice_Chan_PitchEnvFreeRun_Check

; Re-trigger: slotstate+8 = 0, slotstate[0] &= 0xF3 then bit 4 set, 0x04520C (TG reg 0x600)
; = 0, and ToneGen_WriteExtParam_600 emits it.
Voice_Chan_PitchEnvGate_Trigger:
	ld (xiz + 8), 0x0
	andmi8 (xiz), 0xF3
	setm 4, (xiz)
	ldw (Payload_Bss_Start+0x6396:24), 0x0000
	ld wa, (xsp + 14)
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_600
	jrl Voice_Chan_SecondaryPitch_Trigger

; Free-running arm: slotstate+5 != 0, or bit 15 of the slot word.
Voice_Chan_PitchEnvFreeRun_Check:
	cp (xiz + 5), 0x0
	jr nz, Voice_Chan_PitchEnvFreeRun_Trigger
	ld wa, (xsp + 12)
	bit 15, wa
	jr nz, Voice_Chan_ChokeGroup_Trigger

; Computes the envelope level with EGEnv_Compute_A into 0x04520C (TG reg 0x600) and emits it,
; but only if slotstate[0] & 0x38 == 0.
Voice_Chan_PitchEnvFreeRun_Trigger:
	ld a, (xiz)
	and a, 0x38
	jr nz, Voice_Chan_ChokeGroup_Trigger
	ld wa, (xsp + 14)
	extz wa
	calr EGEnv_Compute_A
	ld (Payload_Bss_Start+0x6396:24), hl
	ld wa, (xsp + 14)
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_600
	jrl Voice_Chan_SecondaryPitch_Trigger

; Third trigger arm, gated on (partrec[0] & 0x0C) != 0 -- the exclusive/choke-group bits.
; Same EGEnv_Compute_A -> 0x04520C -> ToneGen_WriteExtParam_600 sequence.
Voice_Chan_ChokeGroup_Trigger:
	ld xwa, (xsp + 4)
	ld wa, (xwa)
	and wa, 0xC
	jrl z, Voice_Chan_SecondaryPitch_Trigger
	ld wa, (xsp + 14)
	extz wa
	calr EGEnv_Compute_A
	ld (Payload_Bss_Start+0x6396:24), hl
	ld wa, (xsp + 14)
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_600
	jrl Voice_Chan_SecondaryPitch_Trigger

; Entered when (perfrec+26) == 0, i.e. no wave-table assignment for this channel. Bails out
; entirely unless bit 15 of (partrec+10) is set; otherwise writes a precomputed slot word to
; 0x0451DC (TG reg 0x440).
Voice_Chan_Fallback_NoWaveTable:
	ld xwa, (xsp + 4)
	ld wa, (xwa + 10)
	extz xwa
	bit 15, wa
	jrl z, Voice_Chan_SecondaryPitch_Trigger
	ld a, (xsp + 16)
	ld e, a
	extz de
	ld a, (xsp + 18)
	ld c, a
	extz bc
	ld wa, de
	ld de, 1:i3
	call DSP_AlgoType_Dispatch3
	ld (xsp + 20), hl
	cpw (xsp + 20), 0x0
	jr z, Voice_Chan_SecondaryPitch_Trigger
	ld a, (xsp + 16)
	ld e, a
	extz de
	ld xwa, (xsp + 22)
	ld a, (xwa)
	ld c, a
	extz bc
	ld wa, de
	ldw de, 0xD
	call ExtVoice_Alloc_StreamSlot
	ld (xsp + 12), hl
	ld wa, (xsp + 12)
	ld w, 0x0:opc
	ld (xsp + 14), wa
	cpw (xsp + 14), 0x80
	jr nc, Voice_Chan_SecondaryPitch_Trigger
	ld wa, (xsp + 14)
	extz wa
	ld bc, wa
	ld wa, 0:i3
	calr NoteState_ClearRecord
	ld wa, (xsp + 12)
	and wa, 0x7F
	or wa, (xsp + 20)
	ld (Payload_Bss_Start+0x6366:24), wa
	ld wa, (xsp + 12)
	bit 15, wa
	jr z, Voice_Chan_Fallback_WritePrecomputed
	ld xwa, (xsp + 4)
	ld wa, (xwa)
	bit 2, wa
	jr z, Voice_Chan_SecondaryPitch_Trigger

; Stores the precomputed envelope words to 0x04520C (TG reg 0x600) and 0x045208 (TG reg
; 0x580) and emits the block.
Voice_Chan_Fallback_WritePrecomputed:
	ld xwa, (xsp + 4)
	ld wa, (xwa + 91)
	ld (Payload_Bss_Start+0x6396:24), wa
	ld xwa, (xsp + 4)
	ld wa, (xwa + 93)
	ld (Payload_Bss_Start+0x6392:24), wa
	ld wa, (xsp + 14)
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_56

; Common tail of ExtVoice_Build_SlotRegisters and the also the bail-out target when no slot was
; assigned. Writes the secondary slot word to 0x0451DE (TG reg 0x480).
Voice_Chan_SecondaryPitch_Trigger:
	ld xwa, (xsp + 4)
	ld wa, (xwa + 10)
	extz xwa
	bit 15, wa
	jrl z, ExtVoice_Build_SlotRegisters_Return
	ld a, (xsp + 16)
	ld e, a
	extz de
	ld a, (xsp + 18)
	ld c, a
	extz bc
	ld wa, de
	ld de, 0:i3
	call DSP_AlgoType_Dispatch3
	ld (xsp + 20), hl
	cpw (xsp + 20), 0x0
	jrl z, ExtVoice_Build_SlotRegisters_Return
	ld a, (xsp + 16)
	ld e, a
	extz de
	ld xwa, (xsp + 22)
	ld a, (xwa)
	ld c, a
	extz bc
	ld wa, de
	ldw de, 0xC
	call ExtVoice_Alloc_StreamSlot
	ld (xsp + 12), hl
	ld wa, (xsp + 12)
	ld w, 0x0:opc
	ld (xsp + 14), wa
	cpw (xsp + 14), 0x80
	jr nc, ExtVoice_Build_SlotRegisters_Return
	ld wa, (xsp + 14)
	or wa, (xsp + 20)
	ld (Payload_Bss_Start+0x6368:24), wa
	ld a, (xsp + 16)
	extz wa
	call AlgoType_AB_Checker
	cp l, 0:i3
	jr nz, Voice_Chan_SecondaryPitch_ComputeDelta
	ld wa, (xsp + 12)
	bit 15, wa
	jr z, Voice_Chan_SecondaryPitch_ComputeDelta
	ld xwa, (xsp + 4)
	ld wa, (xwa)
	bit 2, wa
	jr z, ExtVoice_Build_SlotRegisters_Return

; Computes the secondary pitch delta into 0x04520E, reloads it, derives 0x04520A (TG reg
; 0x5C0) from it and emits the block again.
Voice_Chan_SecondaryPitch_ComputeDelta:
	ld xwa, (xsp + 4)
	ld wa, (xwa + 87)
	ld (Payload_Bss_Start+0x6398:24), wa
	ld iz, (Payload_Bss_Start+0x6398:24)
	extz xiz
	and xiz, 0x1FFF
	ld xwa, (xsp + 22)
	ld a, (xwa + 12)
	ld c, a
	extz bc
	ld e, l
	extz de
	ld xwa, xiz
	calr EnvDepth_Cap
	sub xiz, xhl
	andw (Payload_Bss_Start+0x6398:24), 57344
	ld wa, iz
	or (Payload_Bss_Start+0x6398:24), wa
	ld xwa, (xsp + 4)
	ld wa, (xwa + 89)
	ld (Payload_Bss_Start+0x6394:24), wa
	ld wa, (xsp + 14)
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_56b

; pop XIZ, unwind 22 bytes of frame, ret.
ExtVoice_Build_SlotRegisters_Return:
	pop xiz
	lda xsp, (xsp + 22)
	ret

; The sub-voice (second layer) twin of ExtVoice_Build_SlotRegisters. Same shape: read the
; patch/perf pointers out of the per-voice record, select the algorithm group, call
; ExtVoice_Alloc_StreamSlot, then fill the staging block and emit.
; The differences are (a) the group index gets `set 2` rather than `set 5`, and (b) the slot
; record base is 0x044257 (= 0x04424E + 9) with the bound check at 0x40 instead of 0x80.
Voice_SubVoice_ComputeAndTrigger:
	lda xsp, (xsp - 24)
	pushw iz
	ld (xsp + 22), xwa
	ld xwa, (xsp + 22)
	ld xwa, (xwa + 35)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 22)
	ld xwa, (xwa + 39)
	ld (xsp + 6), xwa
	ld xwa, (xsp + 22)
	ld a, (xwa + 4)
	ld (xsp + 18), a
	ld xwa, (xsp + 22)
	ld c, (xwa + 3)
	ldw (xsp + 16), 0x0
	ld xwa, (xsp + 6)
	cpw (xwa + 28), 0x0
	jrl z, Voice1_UpdatePitch_AltEntry
	ld xwa, (xsp + 6)
	ld wa, (xwa + 28)
	and a, 0x3
	ld (xsp + 20), a
	extz wa
	sla wa, 2
	ld bc, wa
	add bc, 0x3B
	ld xwa, (xsp + 22)
	ld xwa, (xwa + 19)
	lda	xwa, (xwa+bc)
	bitm 7, (xwa + 2)
	jr z, Voice_SubVoice_Compute_NoAlgoSelect
	ld a, (xsp + 18)
	ld l, a
	extz hl
	ld xwa, (xsp + 22)
	ld a, (xwa)
	ld c, a
	extz bc
	ld a, (xsp + 20)
	extz wa
	or wa, 0x24
	ld e, a
	extz de
	ld wa, hl
	call ExtVoice_Alloc_StreamSlot
	ld (xsp + 14), hl
	ld iz, (xsp + 14)
	ldib_erp 0xF9, 0
	ld wa, iz
	call ToneGen_WriteExtParam_540_Mute
	jr Voice_SubVoice_ResolveSlot

; Sub-voice path with algorithm selection disabled.
Voice_SubVoice_Compute_NoAlgoSelect:
	ld a, (xsp + 18)
	ld l, a
	extz hl
	ld xwa, (xsp + 22)
	ld a, (xwa)
	ld c, a
	extz bc
	ld a, (xsp + 20)
	extz wa
	set 2, wa
	ld e, a
	extz de
	ld wa, hl
	call ExtVoice_Alloc_StreamSlot
	ld (xsp + 14), hl
	ld iz, (xsp + 14)
	ldib_erp 0xF9, 0

; XIZ = slot number (high byte force-zeroed). Slot record = 0x044257 + slot*0x1B via
; Math_Multiply32; stores the note number to slotrec+6 and THEN bounds-checks
; `cp iz,0x40 / jr nc` -- see [UNCERTAIN], the store precedes the check.
Voice_SubVoice_ResolveSlot:
	ld wa, iz
	extz xwa
	ld xbc, 0x1B
	call Math_Multiply32
	lda xwa, (Payload_Bss_Start+0x53e1:24)
	add xwa, xhl
	ld (xsp + 10), xwa
	ld xwa, (xsp + 22)
	ld xbc, (xsp + 10)
	ld a, (xwa + 12)
	ld (xbc + 6), a
	cp iz, 0x40
	jrl nc, Voice1_UpdatePitch_WriteStereoField
	ld xwa, (xsp + 6)
	ld wa, (xwa + 28)
	and wa, 0xC000
	ld (xsp + 16), wa
	ld wa, iz
	sll wa, 8
	or (xsp + 16), wa
	ld wa, (xsp + 14)
	bit 15, wa
	jr z, Voice1_UpdatePitch_WritePBend
	ld xwa, (xsp + 2)
	ld wa, (xwa)
	and wa, 0xC
	jr z, Voice1_UpdatePitch_CheckSustain

; Layer-1 pitch update: calls Voice_OpSlot_WriteParams for group 1, computes the envelope
; with EGEnv_Compute_B_Simple into 0x045206, and emits the block at 0x0451CC.
Voice1_UpdatePitch_WritePBend:
	ld a, (xsp + 18)
	ld c, a
	extz bc
	ld a, (xsp + 20)
	ld e, a
	extz de
	pushw 0x1
	ldto_berp A, 0xF8
	extz wa
	pushw wa
	ld wa, bc
	ld xbc, (xsp + 6)
	calr Voice_OpSlot_WriteParams
	ldto_berp A, 0xF8
	extz wa
	calr EGEnv_Compute_B_Simple
	ld (Payload_Bss_Start+0x6390:24), hl
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_15_Alt

; Tests the per-voice sustain/hold flags before deciding whether the oscillator may be
; deactivated.
Voice1_UpdatePitch_CheckSustain:
	ld xwa, (xsp + 10)
	cp (xwa + 7), 0x0
	jr z, Voice1_UpdatePitch_CheckBit5
	ld xwa, (xsp + 2)
	ld wa, (xwa + 2)
	bit 13, wa
	jr nz, Voice1_UpdatePitch_DeactivateOsc

; Bit-5 test on the slot state byte.
Voice1_UpdatePitch_CheckBit5:
	ld xwa, (xsp + 10)
	bitm 5, (xwa)
	jr z, Voice1_UpdatePitch_CheckPhase

; Clears 0x045204 (TG reg 0x1C0) to zero and emits it via ToneGen_WriteExtParam_1C0_Single
; -- the oscillator-off write.
Voice1_UpdatePitch_DeactivateOsc:
	ld xwa, (xsp + 10)
	ld (xwa + 8), 0x0
	ld xwa, (xsp + 10)
	andmi8 (xwa), 0xF3
	ld xwa, (xsp + 10)
	setm 4, (xwa)
	ldw (Payload_Bss_Start+0x638e:24), 0x0000
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_1C0_Single
	jrl Voice1_UpdatePitch_WriteStereoField

; Phase/segment test that selects between the two frequency-write tails.
Voice1_UpdatePitch_CheckPhase:
	ld xwa, (xsp + 10)
	cp (xwa + 5), 0x0
	jr nz, Voice1_UpdatePitch_CheckStateFlags
	ld wa, (xsp + 14)
	bit 15, wa
	jr nz, Voice1_UpdatePitch_WriteFreq

; State-flag arm: computes the value into 0x045204 (TG reg 0x1C0) and emits.
Voice1_UpdatePitch_CheckStateFlags:
	ld xwa, (xsp + 10)
	ld a, (xwa)
	and a, 0x38
	jr nz, Voice1_UpdatePitch_WriteFreq
	ldto_berp A, 0xF8
	extz wa
	calr EGEnv_Compute_B
	ld (Payload_Bss_Start+0x638e:24), hl
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_1C0_Single
	jrl Voice1_UpdatePitch_WriteStereoField

; Main frequency write: result of Voice_Freq_WriteLeft into 0x045204 (TG reg 0x1C0),
; emitted through ToneGen_WriteExtParam_TypeDispatch_Single.
Voice1_UpdatePitch_WriteFreq:
	ld xwa, (xsp + 2)
	ld wa, (xwa)
	and wa, 0xC
	jrl z, Voice1_UpdatePitch_WriteStereoField
	ldto_berp A, 0xF8
	extz wa
	calr EGEnv_Compute_B
	ld (Payload_Bss_Start+0x638e:24), hl
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_1C0_Single
	jrl Voice1_UpdatePitch_WriteStereoField

; Alternate entry used when the caller already holds the computed frequency.
Voice1_UpdatePitch_AltEntry:
	ld xwa, (xsp + 2)
	ld wa, (xwa + 10)
	extz xwa
	bit 15, wa
	jrl z, Voice1_UpdatePitch_WriteStereoField
	ld a, (xsp + 18)
	extz wa
	extz bc
	call Algo67_LUTOffset_Check
	ld (xsp + 16), hl
	cpw (xsp + 16), 0x0
	jr z, Voice1_UpdatePitch_WriteStereoField
	ld a, (xsp + 18)
	ld e, a
	extz de
	ld xwa, (xsp + 22)
	ld a, (xwa)
	ld c, a
	extz bc
	ld wa, de
	ldw de, 0x10
	call ExtVoice_Alloc_StreamSlot
	ld (xsp + 14), hl
	ld iz, (xsp + 14)
	and iz, 0xFF
	cp iz, 0x40
	jr nc, Voice1_UpdatePitch_WriteStereoField
	ldto_berp A, 0xF8
	extz wa
	ld bc, wa
	ld wa, 1:i3
	calr NoteState_ClearRecord
	ld wa, iz
	sll wa, 8
	or (xsp + 16), wa
	ld wa, (xsp + 14)
	bit 15, wa
	jr z, Voice1_UpdatePitch_WriteAltFreq
	ld xwa, (xsp + 2)
	ld wa, (xwa)
	bit 2, wa
	jr z, Voice1_UpdatePitch_WriteStereoField

; Writes both 0x045204 (TG reg 0x1C0) and 0x045206 before emitting.
Voice1_UpdatePitch_WriteAltFreq:
	ld xwa, (xsp + 2)
	ld wa, (xwa + 95)
	ld (Payload_Bss_Start+0x638e:24), wa
	ld xwa, (xsp + 2)
	ld wa, (xwa + 97)
	ld (Payload_Bss_Start+0x6390:24), wa
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_15

; Shared tail (also the no-slot bail-out target of Voice_SubVoice_ResolveSlot). Reads the
; part's TG pan mode byte (CC 0x9D) at 0x04138E + channel*0x11F to pick the reg-0x180 value.
Voice1_UpdatePitch_WriteStereoField:
	ld xwa, (xsp + 22)
	ld a, (xwa + 4)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2518:24)
	cp	(xbc+wa), 0x01
	jr nz, Voice1_UpdatePitch_StereoPart2
	ld bc, (xsp + 16)
	ld xwa, (xsp + 22)
	ld (xwa + 43), bc
	jr Voice1_UpdatePitch_StoreStereo

; Second routing-byte comparison arm.
Voice1_UpdatePitch_StereoPart2:
	ld xwa, (xsp + 22)
	ld a, (xwa + 4)
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x2518:24)
	cp	(xbc+wa), 0x02
	jr nz, Voice1_UpdatePitch_StereoFallthrough
	ld bc, (xsp + 16)
	or bc, 0x7F
	ld xwa, (xsp + 22)
	ld (xwa + 43), bc
	jr Voice1_UpdatePitch_StoreStereo

; Default arm of the routing selection.
Voice1_UpdatePitch_StereoFallthrough:
	ld xwa, (xsp + 6)
	ld a, (xwa + 35)
	extz wa
	ld bc, wa
	or bc, (xsp + 16)
	ld xwa, (xsp + 22)
	ld (xwa + 43), bc

; Stores the selected value to 0x0451D8 (TG reg 0x180) and returns.
Voice1_UpdatePitch_StoreStereo:
	ld xwa, (xsp + 22)
	ld wa, (xwa + 43)
	ld (Payload_Bss_Start+0x6362:24), wa
	popw iz
	lda xsp, (xsp + 24)
	ret

; Layer-2 twin of the Voice1_UpdatePitch family. Seeds 0x0451E0 (TG reg 0x4C0) with the
; constant 0x4400, then follows the same deactivate / phase / frequency structure.
; In: XWA = per-voice record. Touches only the staging block; emission is via the
; ToneGen_WriteExtParam_* helpers.
Voice2_UpdatePitch:
	lda xsp, (xsp - 22)
	pushw iz
	ld (xsp + 20), xwa
	ldw (Payload_Bss_Start+0x636a:24), 0x4400
	ld xwa, (xsp + 20)
	ld xwa, (xwa + 35)
	ld (xsp + 2), xwa
	ld xwa, (xsp + 20)
	ld xwa, (xwa + 39)
	ld (xsp + 6), xwa
	ld xwa, (xsp + 20)
	ld a, (xwa + 4)
	ld (xsp + 16), a
	ld xwa, (xsp + 6)
	cpw (xwa + 30), 0x0
	jrl z, Voice2_UpdatePitch_Done
	ld xwa, (xsp + 6)
	ld wa, (xwa + 30)
	and a, 0x3
	ld (xsp + 18), a
	extz wa
	sla wa, 2
	ld bc, wa
	add bc, 0x4B
	ld xwa, (xsp + 20)
	ld xwa, (xwa + 19)
	lda	xwa, (xwa+bc)
	bitm 7, (xwa + 2)
	jr z, Voice2_UpdatePitch_NoOsc7Flag
	ld a, (xsp + 16)
	ld l, a
	extz hl
	ld xwa, (xsp + 20)
	ld a, (xwa)
	ld c, a
	extz bc
	ld a, (xsp + 18)
	extz wa
	or wa, 0x28
	ld e, a
	extz de
	ld wa, hl
	call ExtVoice_Alloc_StreamSlot
	ld (xsp + 14), hl
	ld iz, (xsp + 14)
	ldib_erp 0xF9, 0
	ld wa, iz
	call ToneGen_WriteExtParam_Mute_TypeDispatch
	jr Voice2_UpdatePitch_ChanEntry

; Arm taken when the oscillator-7 flag is clear.
Voice2_UpdatePitch_NoOsc7Flag:
	ld a, (xsp + 16)
	ld l, a
	extz hl
	ld xwa, (xsp + 20)
	ld a, (xwa)
	ld c, a
	extz bc
	ld a, (xsp + 18)
	extz wa
	set 3, wa
	ld e, a
	extz de
	ld wa, hl
	call ExtVoice_Alloc_StreamSlot
	ld (xsp + 14), hl
	ld iz, (xsp + 14)
	ldib_erp 0xF9, 0

; Channel-indexed entry; reads the per-channel table at 0x044260 (= 0x04424E + 18).
Voice2_UpdatePitch_ChanEntry:
	ld wa, iz
	extz xwa
	ld xbc, 0x1B
	call Math_Multiply32
	lda xwa, (Payload_Bss_Start+0x53ea:24)
	add xwa, xhl
	ld (xsp + 10), xwa
	ld xwa, (xsp + 20)
	ld xbc, (xsp + 10)
	ld a, (xwa + 12)
	ld (xbc + 6), a
	cp iz, 0x80
	jrl nc, Voice2_UpdatePitch_Done
	ld xwa, (xsp + 6)
	ld wa, (xwa + 30)
	and wa, 0x3300
	or wa, iz
	or (Payload_Bss_Start+0x636a:24), wa
	ld wa, (xsp + 14)
	bit 15, wa
	jr z, Voice2_UpdatePitch_WritePBend
	ld xwa, (xsp + 2)
	ld wa, (xwa)
	and wa, 0xC
	jr z, Voice2_UpdatePitch_CheckSustain

; Layer-2 equivalent of 0x025051: fill and emit the block at 0x0451CC.
Voice2_UpdatePitch_WritePBend:
	ld a, (xsp + 16)
	ld c, a
	extz bc
	ld a, (xsp + 18)
	ld e, a
	extz de
	pushw 0x2
	ldto_berp A, 0xF8
	extz wa
	pushw wa
	ld wa, bc
	ld xbc, (xsp + 6)
	calr Voice_OpSlot_WriteParams
	ldto_berp A, 0xF8
	extz wa
	calr Voice_Freq_WriteRight
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParams_TypeDispatch

; Sustain/hold test before oscillator deactivation.
Voice2_UpdatePitch_CheckSustain:
	ld xwa, (xsp + 10)
	cp (xwa + 7), 0x0
	jr z, Voice2_UpdatePitch_CheckBit5
	ld xwa, (xsp + 2)
	ld wa, (xwa + 2)
	bit 13, wa
	jr nz, Voice2_UpdatePitch_DeactivateOsc

; Bit-5 test on the slot state byte.
Voice2_UpdatePitch_CheckBit5:
	ld xwa, (xsp + 10)
	bitm 5, (xwa)
	jr z, Voice2_UpdatePitch_CheckPhase

; Clears both 0x045204 (TG reg 0x1C0) and 0x04520E, then emits -- layer-2 oscillator off.
Voice2_UpdatePitch_DeactivateOsc:
	ld xwa, (xsp + 10)
	ld (xwa + 8), 0x0
	ld xwa, (xsp + 10)
	andmi8 (xwa), 0xF3
	ld xwa, (xsp + 10)
	setm 4, (xwa)
	ldw (Payload_Bss_Start+0x638e:24), 0x0000
	ldw (Payload_Bss_Start+0x6398:24), 0x0000
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_TypeDispatch_Single
	jr Voice2_UpdatePitch_Done

; Phase/segment test.
Voice2_UpdatePitch_CheckPhase:
	ld xwa, (xsp + 10)
	cp (xwa + 5), 0x0
	jr nz, Voice2_UpdatePitch_CheckStateFlags
	ld wa, (xsp + 14)
	bit 15, wa
	jr nz, Voice2_UpdatePitch_WriteFreq

; State-flag arm; emits the block.
Voice2_UpdatePitch_CheckStateFlags:
	ld xwa, (xsp + 10)
	ld a, (xwa)
	and a, 0x38
	jr nz, Voice2_UpdatePitch_WriteFreq
	ldto_berp A, 0xF8
	extz wa
	calr Voice_Freq_WriteLeft
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_TypeDispatch_Single
	jr Voice2_UpdatePitch_Done

; Layer-2 frequency write and emit.
Voice2_UpdatePitch_WriteFreq:
	ld xwa, (xsp + 2)
	ld wa, (xwa)
	and wa, 0xC
	jr z, Voice2_UpdatePitch_Done
	ldto_berp A, 0xF8
	extz wa
	calr Voice_Freq_WriteLeft
	ld wa, iz
	lda xbc, (ToneGen_StagingBlock:24)
	call ToneGen_WriteExtParam_TypeDispatch_Single

; Frame unwind and ret.
Voice2_UpdatePitch_Done:
	popw iz
	lda xsp, (xsp + 22)
	ret

Level_Build_Reg0C0:
	ld xbc, (xwa + 35)
	cp (xbc + 15), 0x0
	jr z, Level_Build_Reg0C0_ZeroCoarse
	ld xbc, (xwa + 35)
	cp (xbc + 18), 0x0
	jr z, Level_Build_Reg0C0_ZeroCoarse
	ld c, (Payload_Bss_Start+0x24d6:24)
	cp c, 6:i3
	jr nz, Level_Build_Reg0C0_UseCoarse
	ld de, 0:i3
	jr Level_Build_Reg0C0_ApplyDetune

; Global mode byte 0x04134C != 6: DE = zext(patchrec+15).
Level_Build_Reg0C0_UseCoarse:
	ld xbc, (xwa + 35)
	ld c, (xbc + 15)
	extz bc
	ld de, bc
	jr Level_Build_Reg0C0_ApplyDetune

; Entered when patchrec+15 == 0 or patchrec+18 == 0; DE = zext(patchrec+15) regardless of
; the global mode.
Level_Build_Reg0C0_ZeroCoarse:
	ld xbc, (xwa + 35)
	ld c, (xbc + 15)
	extz bc
	ld de, bc

; If DE != 0: DE += (partrec+92) - 0x40, DE += s8(patchrec+102); negative results are floored
; to 0.
Level_Build_Reg0C0_ApplyDetune:
	cp de, 0:i3
	jr z, Level_Build_Reg0C0_CheckExpr
	ld xbc, (xwa + 19)
	ld c, (xbc + 92)
	extz bc
	sub bc, 0x40
	add de, bc
	ld xbc, (xwa + 35)
	ld c, (xbc + 102)
	exts bc
	add de, bc
	jr ge, Level_Build_Reg0C0_ClampHigh
	ld de, 0:i3
	jr Level_Build_Reg0C0_ShiftLeft

; Ceiling at 0x7F.
Level_Build_Reg0C0_ClampHigh:
	cp de, 0x7F
	jr le, Level_Build_Reg0C0_ShiftLeft
	ldw de, 0x7F

; `sla de, 8` -- the high byte of the reg-0x0C0 word is this 7-bit field.
Level_Build_Reg0C0_ShiftLeft:
	sla de, 8

; Selects the low byte: patchrec+18 == 0 -> use patchrec+18 (i.e. 0); global mode 5 or 6 ->
; force 0x7F; otherwise use patchrec+18.
Level_Build_Reg0C0_CheckExpr:
	ld xbc, (xwa + 35)
	cp (xbc + 18), 0x0
	jr z, Level_Build_Reg0C0_NoExpr
	ld c, (Payload_Bss_Start+0x24d6:24)
	cp c, 6:i3
	jr z, Level_Build_Reg0C0_FullExpr
	cp c, 5:i3
	jr nz, Level_Build_Reg0C0_PartialExpr

; `or de, 0x7F` -- low byte forced to maximum.
Level_Build_Reg0C0_FullExpr:
	or de, 0x7F
	jr Level_Build_Reg0C0_Write

; Low byte = patchrec+18.
Level_Build_Reg0C0_PartialExpr:
	ld xwa, (xwa + 35)
	ld a, (xwa + 18)
	extz wa
	or de, wa
	jr Level_Build_Reg0C0_Write

; Low byte = patchrec+18 (reached with the high field left at 0).
Level_Build_Reg0C0_NoExpr:
	ld xwa, (xwa + 35)
	ld a, (xwa + 18)
	extz wa
	or de, wa

; Stores DE to 0x0451D2 (TG reg 0x0C0) and returns.
Level_Build_Reg0C0_Write:
	ld (Payload_Bss_Start+0x635c:24), de
	ret

; Second copy of the routine at 0x0253FE, differing only in that it pre-loads the part
; record pointer (voice+19) into XHL on entry and uses it directly for the +92 term rather
; than re-loading it. Same output: 0x0451D2 (TG reg 0x0C0).
Voice_ComputePitchBend2:
	ld xhl, (xwa + 19)
	ld xbc, (xwa + 35)
	cp (xbc + 15), 0x0
	jr z, Voice_ComputePitchBend2_ZeroCoarse
	ld xbc, (xwa + 35)
	cp (xbc + 18), 0x0
	jr z, Voice_ComputePitchBend2_ZeroCoarse
	ld c, (Payload_Bss_Start+0x24d6:24)
	cp c, 6:i3
	jr nz, Voice_ComputePitchBend2_UseCoarse
	ld de, 0:i3
	jr Voice_ComputePitchBend2_ApplyDetune

; As 0x02541D.
Voice_ComputePitchBend2_UseCoarse:
	ld xbc, (xwa + 35)
	ld c, (xbc + 15)
	extz bc
	ld de, bc
	jr Voice_ComputePitchBend2_ApplyDetune

; As 0x025429.
Voice_ComputePitchBend2_ZeroCoarse:
	ld xbc, (xwa + 35)
	ld c, (xbc + 15)
	extz bc
	ld de, bc

; As 0x025433.
Voice_ComputePitchBend2_ApplyDetune:
	cp de, 0:i3
	jr z, Voice_ComputePitchBend2_CheckExpr
	ld c, (xhl + 15)
	extz bc
	sub bc, 0x40
	add de, bc
	jr ge, Voice_ComputePitchBend2_ClampHigh
	ld de, 0:i3
	jr Voice_ComputePitchBend2_ShiftLeft

; As 0x025455.
Voice_ComputePitchBend2_ClampHigh:
	cp de, 0x7F
	jr le, Voice_ComputePitchBend2_ShiftLeft
	ldw de, 0x7F

; As 0x02545E.
Voice_ComputePitchBend2_ShiftLeft:
	sla de, 8

; As 0x025461.
Voice_ComputePitchBend2_CheckExpr:
	ld xbc, (xwa + 35)
	cp (xbc + 18), 0x0
	jr z, Voice_ComputePitchBend2_NoExpr
	ld c, (Payload_Bss_Start+0x24d6:24)
	cp c, 6:i3
	jr z, Voice_ComputePitchBend2_FullExpr
	cp c, 5:i3
	jr nz, Voice_ComputePitchBend2_PartialExpr

; As 0x025477.
Voice_ComputePitchBend2_FullExpr:
	or de, 0x7F
	jr Voice_ComputePitchBend2_Write

; As 0x02547D.
Voice_ComputePitchBend2_PartialExpr:
	ld xwa, (xwa + 35)
	ld a, (xwa + 18)
	extz wa
	or de, wa
	jr Voice_ComputePitchBend2_Write

; As 0x025489.
Voice_ComputePitchBend2_NoExpr:
	ld xwa, (xwa + 35)
	ld a, (xwa + 18)
	extz wa
	or de, wa

; Stores DE to 0x0451D2 (TG reg 0x0C0) and returns.
Voice_ComputePitchBend2_Write:
	ld (Payload_Bss_Start+0x635c:24), de
	ret

; A = channel (part), BC = a voice's gate/control word.  Returns HL = BC patched by the part's gate routing
; mode byte (CC 0x9B, 0x04138D + part*0x11F): see Voice_CC_SetGateRoutingMode.
Voice_Apply_GateRouting:
	ld e, a
	extz de
	muls de, 0x11F
	lda xhl, (Payload_Bss_Start+0x2517:24)
	ld	e, (xhl+de)
	and e, 0xF
	cp e, 1:i3
	jr z, Voice_Apply_GateRouting_HighNibble
	cp e, 2:i3
	jr z, Voice_Apply_GateRouting_Mode2
	cp e, 0:i3
	jr nz, Voice_Apply_GateRouting_HighNibble
	or bc, 0xE00
	jr Voice_Apply_GateRouting_HighNibble

; Low-nibble routing value 2: `and bc,0xF1FF` then `set 9,bc` -- forces the [11:9] field to 1.
Voice_Apply_GateRouting_Mode2:
	and bc, 0xF1FF
	set 9, bc

; Second half: re-reads (0x04138D + channel*0x11F) & 0xF0. 0x10 -> leave alone; 0x20 -> jump
; to the [14:12] override; 0x00 -> `or bc,0x7000`.
Voice_Apply_GateRouting_HighNibble:
	extz wa
	muls wa, 0x11F
	lda xde, (Payload_Bss_Start+0x2517:24)
	ld	a, (xde+wa)
	and a, 0xF0
	cp a, 0x10
	jr z, Voice_Apply_GateRouting_Done
	cp a, 0x20
	jr z, Voice_Apply_GateRouting_Mode2High
	cp a, 0:i3
	jr nz, Voice_Apply_GateRouting_Done
	or bc, 0x7000
	jr Voice_Apply_GateRouting_Done

; `and bc,0x8FFF` then `set 12,bc` -- forces the [14:12] field to 1.
Voice_Apply_GateRouting_Mode2High:
	and bc, 0x8FFF
	set 12, bc

; `ld hl, bc` / ret -- the patched word is returned in HL.
Voice_Apply_GateRouting_Done:
	ld hl, bc
	ret

; ---------------------------------------------------------------------------------------
; THE TONE GENERATOR CONTROL REGISTER (bank +0x000), AND THE WORD BUILT FOR IT
;
; Register address (0x0000 + slot) on IC303 is the per-voice CONTROL/gate register. This
; routine and its twin Voice_Build_GateCommand_NoPartial (0x0255F3) build the word that is
; handed to it and park it in the LIVE slot record at +0x2D (0x0430BB + slot*0x47). They
; touch no hardware; the writers listed below push it.
;
; FROM THE CODE -- the command set. Every bank-0x0000 access in the ROM was enumerated by
; scanning the binary for the address latch `ld (0x100000),WA` (f2 00 00 10 50) whose
; preceding instruction is NOT `add WA,imm16`, plus the one immediate-form latch
; (f2 00 00 10 02 with a value < 0x40). Thirteen sites, no others; one is the read-back:
;
;   NOTE-ON GATE   literal 0x8100. Always exactly that value, never computed. Three sites,
;                  all mid-burst: ToneGen_WriteVoiceParams (data write at 0x02D2B4),
;                  ToneGen_WriteVoiceParams_Ext (0x02D6CA), _Ext2 (0x02D777).
;   FREE           literal 0x7E00. Four sites: ToneGen_SilenceChannel (0x02B4D4),
;                  ToneGen_Config_Init (0x02E085), Voice_Reset_Engine phase B (0x021F94),
;                  and the dormant probe ToneGen_SelfTest_ProbeVoice0 (0x02E17D).
;   HAND-OFF       the word built here, bit 15 SET. Five sites: ToneGen_WriteSingleReg
;                  (0x02D41B), ToneGen_WriteVoice_Direct (0x027FBB), and the tails of
;                  ToneGen_WriteVoiceParams_Ext (0x02D731) / _Ext2 (0x02D7B9).
;                  The SAME word with bit 15 CLEARED is the update-without-re-gate form,
;                  emitted by ToneGen_ReadPitch_AndScale (`res 15, bc` at 0x02E1E3).
;   READ-BACK      0x021026, inside ToneGen_Read_Register: bank 0x0000 indices 0..3 read as
;                  four 16-bit ACTIVE-VOICE BITMAPS (Voice_Manager_PollBank, 0x02219F).
;
; HOW THIS ROUTINE BUILDS THE WORD (IN: XWA = live slot record; OUT: record+0x2D):
;   bits 7..0   0xFF - 4*(P[0] & 0x3F), where P = the u32 pointer at record+0x17 and P[0]
;               is its first BYTE. Range 0x03..0xFF, and always == 3 (mod 4).
;   bit 8       SET iff that same byte P[0] is non-zero. Meaning not established.
;   bits 15..9  0xFE00 when the global mode byte 0x04134C is 0, 5 or 6, else 0xF000; the
;               selector is skipped and 0xF000 forced when byte +0x12 of the record at
;               record+0x23 is zero.
;   then        Voice_Apply_GateRouting (0x02552A) may overwrite bits [14:12] and [11:9]
;               from the two nibbles of (0x04138D + channel*0x11F). Neither arm can clear
;               bit 15 -- the masks are 0x8FFF and 0xF1FF -- so the hand-off word always
;               leaves here with bit 15 set.
; The twin Voice_Build_GateCommand_NoPartial stores the bare literal 0xFE00 / 0xF000 with no
; level byte at all, so it is the ONLY producer of a 0x00 low byte.
;
; MEASURED (capture of a running machine, 1705 note-ons of the built-in demo): only FOUR
; hand-off values are ever issued -- F0FF, F000, F1D7, F187 -- and the LOW BYTE is an OUTPUT
; LEVEL (0xFF full, 0x00 silent), not a mode flag. All four reconcile with the arithmetic
; above, exactly:
;   F0FF  this routine, P[0] == 0            -> 0xFF - 0    = 0xFF, bit 8 clear
;   F1D7  this routine, P[0] & 0x3F == 0x0A  -> 0xFF - 0x28 = 0xD7, bit 8 set
;   F187  this routine, P[0] & 0x3F == 0x1E  -> 0xFF - 0x78 = 0x87, bit 8 set
;   F000  the NoPartial twin's literal -- unreachable from here, because the computed low
;         byte is always == 3 (mod 4) and can never be 0x00.
; The 0xFExx family is absent from the capture. 0x04134C has exactly one store, at the head
; of Voice_AllVoices_UpdateVelocity (0x028C39), which masks A to 4 bits. That routine has
; TWO entries: Voice_ResetAllControllers calls it with A = 1 (not in {0,5,6}), and a
; parameter-dispatch path tail-jumps into it (`jrl`) with A loaded from a message byte at
; (xwa + 3). So the mode is 1 after an audio-side reset, and only a later parameter write
; can select the 0xFE00 arm -- which the demo never does. [INFERENCE: the dispatch-table
; producers of that message byte were not exhaustively traced.]
;
; A voice handed F000 is meant to be INAUDIBLE, and the firmware relies on it: the capture
; shows one voice left gated and never freed at the end of boot, with its envelope
; programmed to hold. The code makes that state stable -- Voice_Manager_PollBank_SlotLoop
; (0x02222A) frees a slot only on a 1 -> 0 edge of the active-voice bitmap it reads back
; through ToneGen_Read_Register, so a voice whose envelope never decays never produces the
; edge and never reaches ToneGen_SilenceChannel.
;
; INFERENCE: read in the same field layout, the 0x8100 note-on gate is "gate on, both
; routing fields 0, level 0" -- the burst gates the voice silent and the hand-off word that
; follows supplies the routing and the level. Not proven; 0x8100 is a literal in the ROM.
; ---------------------------------------------------------------------------------------
Voice_Build_GateCommand:
	push xiz
	ld xiz, xwa
	ld xwa, (xiz + 23)
	ld a, (xwa)
	extz wa
	and wa, 0x3F
	sll wa, 2
	ldw bc, 0xFF
	sub bc, wa
	ld xwa, (xiz + 23)
	cp (xwa), 0x0
	jr z, Voice_Build_GateCommand_CheckExpr
	set 8, bc

; Selects the high field: patchrec+18 == 0 -> 0xF000; global mode byte 0x04134C in {0,5,6}
; -> 0xFE00; otherwise 0xF000.
Voice_Build_GateCommand_CheckExpr:
	ld xwa, (xiz + 35)
	cp (xwa + 18), 0x0
	jr z, Voice_Build_GateCommand_NoExpr
	ld a, (Payload_Bss_Start+0x24d6:24)
	cp a, 6:i3
	jr z, Voice_Build_GateCommand_FullExpr
	cp a, 5:i3
	jr z, Voice_Build_GateCommand_FullExpr
	cp a, 0:i3
	jr nz, Voice_Build_GateCommand_PartialExpr

; `or wa,0xFE00` and store to voice+45.
Voice_Build_GateCommand_FullExpr:
	ld wa, bc
	or wa, 0xFE00
	ld (xiz + 45), wa
	jr Voice_Build_GateCommand_ApplyMode

; `or wa,0xF000` and store to voice+45.
Voice_Build_GateCommand_PartialExpr:
	ld wa, bc
	or wa, 0xF000
	ld (xiz + 45), wa
	jr Voice_Build_GateCommand_ApplyMode

; `or wa,0xF000` and store to voice+45 (patchrec+18 == 0 arm).
Voice_Build_GateCommand_NoExpr:
	ld wa, bc
	or wa, 0xF000
	ld (xiz + 45), wa

; Runs voice+45 through Voice_Apply_GateRouting with A = voice+4 (the channel) and stores
; the patched word back to voice+45.
Voice_Build_GateCommand_ApplyMode:
	ld a, (xiz + 4)
	extz wa
	ld bc, (xiz + 45)
	calr Voice_Apply_GateRouting
	ld (xiz + 45), hl
	pop xiz
	ret

; The level-less twin of Voice_Build_GateCommand (0x025589 -- the CONTROL register, bank
; +0x000, is documented in full there). IN: XWA = live slot record; OUT: record+0x2D.
;
; It runs the SAME high-field selector (record+0x23 byte +0x12, then the global mode byte
; 0x04134C in {0,5,6}) and the SAME Voice_Apply_GateRouting patch, but stores a bare literal
; -- `ldw (xiz + 45), 0xFE00` / `0xF000` at 0x025613 / 0x02561A / 0x025621 -- with no level
; byte and no bit 8. Its third instruction, `ld xwa, (xiz + 19)`, loads a pointer that the
; next load immediately discards; dead code, kept for byte fidelity.
;
; ★ THIS IS ONE OF THE TWO SOURCES OF 0xF000. The computed sibling cannot produce a 0x00
; low byte (its byte is 0xFF - 4*k, always == 3 mod 4), so no computed path reaches F000.
; The other source is the auxiliary voice template at ROM 0x012115, whose WORD 0 is 0xF000:
; ToneGen_SetupPolyVoice (0x0355AD) copies it verbatim into staging 0x3B1C with `ldirw` and
; hands that word to ToneGen_WriteSingleReg. MEASURED (demo capture, 1705 note-ons; harness in kn7000_mame,
; tools/rigs/kn5000_demo_capture.lua): F000 is one of only four hand-off values
; ever issued, and its low byte 0x00 means output level zero -- the voice is gated but
; inaudible.
; Callers, all of them slot-parameter rebuilds that end in ToneGen_WriteVoiceParams:
; Voice_Init_Type1 (0x02C3CC), Voice_Init_Type2 (0x02C0B6), and the TypeB arm of
; Voice_AllVoices_UpdateVelocity (0x028C39).
Voice_Build_GateCommand_NoPartial:
	push xiz
	ld xiz, xwa
	ld xwa, (xiz + 19)
	ld xwa, (xiz + 35)
	cp (xwa + 18), 0x0
	jr z, Voice_Build_GateCommand_NoPartial_NoExpr
	ld a, (Payload_Bss_Start+0x24d6:24)
	cp a, 6:i3
	jr z, Voice_Build_GateCommand_NoPartial_FullExpr
	cp a, 5:i3
	jr z, Voice_Build_GateCommand_NoPartial_FullExpr
	cp a, 0:i3
	jr nz, Voice_Build_GateCommand_NoPartial_PartialExpr

; Unmuted twin of 0x0255C4.
Voice_Build_GateCommand_NoPartial_FullExpr:
	ldw (xiz + 45), 0xFE00
	jr Voice_Build_GateCommand_NoPartial_ApplyMode

; Unmuted twin of 0x0255CF.
Voice_Build_GateCommand_NoPartial_PartialExpr:
	ldw (xiz + 45), 0xF000
	jr Voice_Build_GateCommand_NoPartial_ApplyMode

; Unmuted twin of 0x0255DA.
Voice_Build_GateCommand_NoPartial_NoExpr:
	ldw (xiz + 45), 0xF000

; Unmuted twin of 0x0255E3.
Voice_Build_GateCommand_NoPartial_ApplyMode:
	ld a, (xiz + 4)
	extz wa
	ld bc, (xiz + 45)
	calr Voice_Apply_GateRouting
	ld (xiz + 45), hl
	pop xiz
	ret

