; =============================================================================
; MIDI Packet Routines
; =============================================================================
;
; MIDI packet extraction, packing, and queue management.
; Handles the low-level MIDI message framing between the
; serial I/O layer and the dispatch handlers.
; =============================================================================

;
; v7 REGENERATED FROM v10's STRUCTURE (midi lane, 2026-09-25,
; scripts/tools/midi_lane_v7_from_v10.py): every line below was derived
; from the v10 line emitting the same bytes at v10 = v7 + 0x7D1, with v7's
; own bytes decoded and re-encoded.  Addresses quoted in carried-over
; headers are v10's.  The old v7 names that other files kept 0x41A away from
; their code (`v7 NAME DISPLACED`) were moved to it on 2026-10-06:
; scripts/tools/fix_v7_displaced_names.py --audit checks every name here.
;
; The first bytes of this file are the TAIL of an instruction whose head
; is the last bytes of the previous file: the v7 file boundary sits 0x41A
; bytes off the v10 one, so it cuts an instruction.
	.byte 0x04, 0x31
	ld (xbc), xhl
	ld (xwa), xiz
	ld xbc, (xbc)
	ld c, (xbc + 16)
	extz bc
	sla bc, 2
	lda	xde, (MidiCtl_Handlers:24)
	exts xbc
	add xbc, xde
	ld xhl, (xbc)
	call (xhl)
	pop xiz
	inc 8, xsp
	ret
MidiPkt_DispatchViaTable_4DA6:
	dec 8, xsp
	push xiz
	ld xiz, xwa
	ld xwa, xiz
	ld	xbc, MidiCtl_MatchList4
	calr	MidiPkt_MatchParamInTable
	lda xwa, (xsp + 4)
	lda xbc, (xwa + 4)
	ld (xbc), xhl
	ld (xwa), xiz
	ld xbc, (xbc)
	ld c, (xbc + 16)
	extz bc
	sla bc, 2
	lda	xde, (MidiCtl_Handlers:24)
	exts xbc
	add xbc, xde
	ld xhl, (xbc)
	call (xhl)
	pop xiz
	inc 8, xsp
	ret
MidiPkt_DispatchViaTable_4DAE:
	dec 8, xsp
	push xiz
	ld xiz, xwa
	ld xwa, xiz
	ld	xbc, MidiCtl_MatchList5
	calr	MidiPkt_MatchParamInTable
	lda xwa, (xsp + 4)
	lda xbc, (xwa + 4)
	ld (xbc), xhl
	ld (xwa), xiz
	ld xbc, (xbc)
	ld c, (xbc + 16)
	extz bc
	sla bc, 2
	lda	xde, (MidiCtl_Handlers:24)
	exts xbc
	add xbc, xde
	ld xhl, (xbc)
	call (xhl)
	cp (xiz + 1), 0xb
	jr	nz, MidiPkt_DispatchViaTable_4DAE_Done
	lda xde, (xiz + 3)
	ld xwa, (xsp + 8)
	ld c, (xwa + 8)
	cpl c
	ld a, (xde)
	and a, c
	ld (xde), a
	cp a, 0:i3
	jr	z, MidiPkt_DispatchViaTable_4DAE_Done
	ld xwa, xiz
	ld	xbc, MidiCtl_MatchList5
	calr	MidiPkt_MatchParamInTable
	lda xwa, (xsp + 4)
	lda xbc, (xwa + 4)
	ld (xbc), xhl
	ld (xwa), xiz
	ld xbc, (xbc)
	ld c, (xbc + 16)
	extz bc
	sla bc, 2
	lda	xde, (MidiCtl_Handlers:24)
	exts xbc
	add xbc, xde
	ld xhl, (xbc)
	call (xhl)
MidiPkt_DispatchViaTable_4DAE_Done:
	pop xiz
	inc 8, xsp
	ret
MidiPkt_DispatchSpecialType:
	dec 8, xsp
	push xiz
	ld xiz, xwa
	ld a, (xiz + 1)
	cp a, 0x11
	jr	nz, MidiPkt_DispatchSpecialType_Type10
	ld	xwa, SysEx_GmSystemOn
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld	xwa, (0xbbc0:16)
	jr	MidiPkt_DispatchSpecialType_SendAndUpdate
MidiPkt_DispatchSpecialType_Type10:
	cp a, 0x10
	jr	nz, MidiPkt_DispatchSpecialType_Default
	ld	xwa, SysEx_GmSystemOff
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld	xwa, (0xbbc0:16)
MidiPkt_DispatchSpecialType_SendAndUpdate:
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
	jr	MidiPkt_DispatchSpecialType_Return
MidiPkt_DispatchSpecialType_Default:
	ld xwa, xiz
	ld	xbc, MidiCtl_MatchList6
	calr	MidiPkt_MatchParamInTable
	lda xwa, (xsp + 4)
	lda xbc, (xwa + 4)
	ld (xbc), xhl
	ld (xwa), xiz
	ld xbc, (xbc)
	ld c, (xbc + 16)
	extz bc
	sla bc, 2
	lda	xde, (MidiCtl_Handlers:24)
	exts xbc
	add xbc, xde
	ld xhl, (xbc)
	call (xhl)
MidiPkt_DispatchSpecialType_Return:
	pop xiz
	inc 8, xsp
	ret
MidiPkt_MatchParamInTable:
	ld xde, xbc
	lda	xix, (MidiCtl_NullRecord:24)
MidiPkt_MatchParamInTable_Loop:
	ld XHL, (xde+)
	cp xix, xhl
	ret z
	ld c, (xhl + 7)
	cp c, (xwa + 1)
	jr	nz, MidiPkt_MatchParamInTable_Loop
	ld c, (xhl + 8)
	and c, (xwa + 3)
	jr	z, MidiPkt_MatchParamInTable_Loop
	ret
MidiPkt_EnqueueControlNop:
	ret
MidiPkt_EnqueueControl_3354:
	dec 4, xsp
	push xiz
	ld xiz, xwa
	ld	xiy, MidiPkt_MsgTemplate_334C
	lda xix, (xsp + 4)
	ldi85
	ldiw
	ld xwa, (xiz + 4)
	calr	MidiPkt_CheckGateCondition
	cp hl, 0xffff
	jr	z, MidiPkt_EnqueueControl_3354_Return
	lda	xbc, (MidiCtl_NullRecord:24)
	ld xwa, (xiz + 4)
	cp xbc, xwa
	jr	z, MidiPkt_EnqueueControl_3354_Return
	ld xbc, (xiz)
	ld a, (xwa + 8)
	and a, (xbc + 3)
	jr	z, MidiPkt_EnqueueControl_3354_Return
	ld	xwa, SysEx_Msg_35DC
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld xwa, (xiz + 4)
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld xbc, (xiz)
	ld xde, (xiz + 4)
	ld a, (xde + 8)
	and a, (xbc + 2)
	ld c, a
	ld a, (xde + 11)
	and a, 0xf
	jr	z, MidiPkt_EnqueueControl_3354_ShiftBits
	srla c
MidiPkt_EnqueueControl_3354_ShiftBits:
	lda xwa, (xsp + 4)
	ld (xwa), c
	and c, 0xf
	ld (xwa + 1), c
	ld c, (xwa)
	srl c, 4
	ld (xwa), c
	ld bc, 3:i3
	call	ArpQueue_Enqueue
	call	ArpQueue_ComputeAndEnqueue
	ld	xwa, (0xbbc0:16)
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
MidiPkt_EnqueueControl_3354_Return:
	pop xiz
	inc 4, xsp
	ret
; MidiPkt_SendCtlWordValueSysEx: 16-bit variant of MidiPkt_SendCtlValueSysEx: given XWA -> {packet, record}, returns
;   on MidiPkt_CheckGateCondition = 0xFFFF, on MidiCtl_NullRecord or when the packet's mask word (+4) is 0; else
;   queues SysEx_Msg_35DC (F0 50 2C 01 28 12) and the record's first 6 bytes, then the low byte of (value word +2 &
;   mask word +4) >> (record+11 & 15) as two nibbles, high first, plus a zero byte, and closes and sends the message.
;   No live caller in this build. Basis: callers + body -- its only caller MidiPkt_ExtractAndPack builds the packet
;   {record+6, record+7, u16 value from two consecutive part-table bytes (record+7, record+7+1), u16 mask record+8 <<
;   (record+11 & 15)}; MidiPkt_ExtractAndPack itself has no referrer (no call/calr/jp to 0xFD9533, no 24-bit pointer
;   to it in any ROM image).
MidiPkt_SendCtlWordValueSysEx:
	dec	4, xsp
	push	xiz
	ld	xiz, xwa
	ld	xiy, MidiPkt_MsgTemplate_3350
	lda	xix, (xsp+4)
	ldi85
	ldiw
	ld	xwa, (xiz+4)
	calr	MidiPkt_CheckGateCondition
	cp	hl, 0xffff
	jr	z, MidiPkt_SendCtlWordValueSysEx_Epilogue
	lda	xwa, (MidiCtl_NullRecord:24)
	cp	xwa, (xiz+4)
	jr	z, MidiPkt_SendCtlWordValueSysEx_Epilogue
	ld	xwa, (xiz)
	cpw	(xwa+4), 0
	jr	z, MidiPkt_SendCtlWordValueSysEx_Epilogue
	ld	xwa, SysEx_Msg_35DC
	ld	bc, 6:i3
	call	ArpQueue_Enqueue
	ld	xwa, (xiz+4)
	ld	bc, 6:i3
	call	ArpQueue_Enqueue
	ld	xwa, (xiz)
	ld	xbc, xwa
	ld	bc, (xbc+4)
	and	bc, (xwa+2)
	ld	xwa, (xiz+4)
	ld	a, (xwa+11)
	and	a, 15
	jr	z, MidiPkt_SendCtlWordValueSysEx_Skip
	.byte 0xd9, 0xff	; srl a,bc -- the backend cannot spell this form
MidiPkt_SendCtlWordValueSysEx_Skip:
	lda	xwa, (xsp+4)
	ld	(xwa), c
	and	c, 15
	ld	(xwa+1), c
	ld	c, (xwa)
	srl	c, 4
	ld	(xwa), c
	ld	bc, 3:i3
	call	ArpQueue_Enqueue
	call	ArpQueue_ComputeAndEnqueue
	ld	xwa, (0xbbc0:16)
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
MidiPkt_SendCtlWordValueSysEx_Epilogue:
	pop	xiz
	inc	4, xsp
	ret
MidiPkt_EnqueueControl_335C:
	dec 4, xsp
	push xiz
	ld xiz, xwa
	ld	xiy, MidiPkt_MsgTemplate_3354
	lda xix, (xsp + 4)
	ldi85
	ldiw
	ld xwa, (xiz + 4)
	calr	MidiPkt_CheckGateCondition
	cp hl, 0xffff
	jr	z, MidiPkt_EnqueueControl_335C_Return
	lda	xbc, (MidiCtl_NullRecord:24)
	ld xwa, (xiz + 4)
	cp xbc, xwa
	jr	z, MidiPkt_EnqueueControl_335C_Return
	ld xbc, (xiz)
	ld a, (xwa + 8)
	and a, (xbc + 3)
	jr	z, MidiPkt_EnqueueControl_335C_Return
	ld	xwa, SysEx_Msg_35DC
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld xwa, (xiz + 4)
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	lda xwa, (xsp + 4)
	ld (xwa), 0x0
	ld xde, (xiz)
	ld xbc, (xiz + 4)
	ld c, (xbc + 8)
	and c, (xde + 2)
	jr	z, MidiPkt_EnqueueControl_335C_ZeroData
	ld (xwa), 0x7f
MidiPkt_EnqueueControl_335C_ZeroData:
	ld c, (xwa)
	and c, 0xf
	ld (xwa + 1), c
	ld c, (xwa)
	srl c, 4
	ld (xwa), c
	ld bc, 3:i3
	call	ArpQueue_Enqueue
	call	ArpQueue_ComputeAndEnqueue
	ld	xwa, (0xbbc0:16)
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
MidiPkt_EnqueueControl_335C_Return:
	pop xiz
	inc 4, xsp
	ret
MidiPkt_EnqueueControl_3358:
	dec 6, xsp
	push xiz
	ld xiz, xwa
	ld	xiy, MidiPkt_MsgTemplate_3358
	lda xix, (xsp + 4)
	ld bc, 2:i3
	ldirw
	ldi85
	ld xwa, (xiz + 4)
	calr	MidiPkt_CheckGateCondition
	cp hl, 0xffff
	jrl	z, MidiPkt_EnqueueControl_3358_Return
	lda	xbc, (MidiCtl_NullRecord:24)
	ld xwa, (xiz + 4)
	cp xbc, xwa
	jrl	z, MidiPkt_EnqueueControl_3358_Return
	ld xbc, (xiz)
	ld a, (xwa + 8)
	and a, (xbc + 3)
	jrl	z, MidiPkt_EnqueueControl_3358_Return
	ld	xwa, SysEx_Msg_35DC
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld xwa, (xiz + 4)
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld	xhl, (PART_RECORD_PTRS:16)
	ld xwa, (xiz)
	ld a, (xwa)
	extz wa
	sla wa, 2
	ld	xwa, (xhl+wa)
	cp xwa, 0xffffffff
	jr	z, MidiPkt_EnqueueControl_3358_Return
	lda xwa, (xsp + 4)
	ld xbc, (xiz)
	ld c, (xbc)
	extz bc
	sla bc, 2
	ld	xbc, (xhl+bc)
	ld c, (xbc)
	ld (xwa), c
	lda xde, (xwa + 2)
	ld xbc, (xiz)
	ld c, (xbc)
	extz bc
	sla bc, 2
	ld	xbc, (xhl+bc)
	ld c, (xbc + 1)
	and c, 0x7
	ld (xde), c
	ld c, (xwa)
	bit 7, c
	jr	z, MidiPkt_EnqueueControl_3358_SplitNibbles
	res 7, c
	ld (xwa), c
	ld c, (xde)
	set 7, c
	ld (xde), c
MidiPkt_EnqueueControl_3358_SplitNibbles:
	ld c, (xwa)
	and c, 0xf
	ld (xwa + 1), c
	ld c, (xwa)
	srl c, 4
	ld (xwa), c
	ld c, (xde)
	and c, 0xf
	ld (xwa + 3), c
	ld c, (xde)
	srl c, 4
	ld (xde), c
	ld bc, 5:i3
	call	ArpQueue_Enqueue
	call	ArpQueue_ComputeAndEnqueue
	ld	xwa, (0xbbc0:16)
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
MidiPkt_EnqueueControl_3358_Return:
	pop xiz
	inc 6, xsp
	ret
MidiPkt_EnqueueControl_335E:
	lda xsp, (xsp - 14)
	push xiz
	ld xiz, xwa
	ld	xiy, MidiPkt_MsgTemplate_335E
	lda xix, (xsp + 4)
	ld bc, 2:i3
	ldirw
	ldi85
	lda xbc, (xsp + 10)
	ld (xbc), xiz
	lda	xwa, (MidiCtl_Rec_09:24)
	ld (xbc + 4), xwa
	calr	MidiPkt_CheckGateCondition
	cp hl, 0xffff
	jr	z, MidiPkt_EnqueueControl_335E_Return
	ld	xwa, SysEx_Msg_35DC
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld xwa, (xsp + 14)
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	lda xwa, (xsp + 4)
	ld c, (xiz)
	ld (xwa), c
	lda xde, (xwa + 2)
	ld c, (xiz + 1)
	ld (xde), c
	ld c, (xwa)
	bit 7, c
	jr	z, MidiPkt_EnqueueControl_335E_SplitNibbles
	res 7, c
	ld (xwa), c
	ld c, (xde)
	set 7, c
	ld (xde), c
MidiPkt_EnqueueControl_335E_SplitNibbles:
	ld c, (xwa)
	and c, 0xf
	ld (xwa + 1), c
	ld c, (xwa)
	srl c, 4
	ld (xwa), c
	ld c, (xde)
	and c, 0xf
	ld (xwa + 3), c
	ld c, (xde)
	srl c, 4
	ld (xde), c
	ld bc, 5:i3
	call	ArpQueue_Enqueue
	call	ArpQueue_ComputeAndEnqueue
	ld	xwa, (0xbbc0:16)
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
MidiPkt_EnqueueControl_335E_Return:
	pop xiz
	lda xsp, (xsp + 14)
	ret
MidiPkt_EnqueueControl_3364:
	dec 4, xsp
	push xiz
	ld xiz, xwa
	ld	xiy, MidiPkt_MsgTemplate_3364
	lda xix, (xsp + 4)
	ldi85
	ldiw
	ld xwa, (xiz + 4)
	calr	MidiPkt_CheckGateCondition
	cp hl, 0xffff
	jr	z, MidiPkt_EnqueueControl_3364_Return
	ld xbc, (xiz)
	ld xwa, (xiz + 4)
	ld a, (xwa + 8)
	and a, (xbc + 3)
	jr	z, MidiPkt_EnqueueControl_3364_Return
	ld	xwa, SysEx_Msg_35DC
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld xwa, (xiz + 4)
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld xbc, (xiz)
	ld xde, (xiz + 4)
	ld a, (xde + 8)
	and a, (xbc + 2)
	cp a, 1:i3
	jr	nz, MidiPkt_EnqueueControl_3364_FormatData
	ld c, (PANEL_STYLE+7:16)
	and c, 0x30
	ld a, (xde + 11)
	and a, 0xf
	jr	z, MidiPkt_EnqueueControl_3364_NoShift
	srla c
MidiPkt_EnqueueControl_3364_NoShift:
	inc 1, c
	ld (xsp + 4), c
MidiPkt_EnqueueControl_3364_FormatData:
	lda xwa, (xsp + 4)
	ld c, (xwa)
	and c, 0xf
	ld (xwa + 1), c
	ld c, (xwa)
	srl c, 4
	ld (xwa), c
	ld bc, 3:i3
	call	ArpQueue_Enqueue
	call	ArpQueue_ComputeAndEnqueue
	ld	xwa, (0xbbc0:16)
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
MidiPkt_EnqueueControl_3364_Return:
	pop xiz
	inc 4, xsp
	ret
MidiPkt_EnqueueControl_3368:
	dec 4, xsp
	push xiz
	ld xiz, xwa
	ld	xiy, MidiPkt_MsgTemplate_3368
	lda xix, (xsp + 4)
	ldi85
	ldiw
	ld xwa, (xiz + 4)
	calr	MidiPkt_CheckGateCondition
	cp hl, 0xffff
	jrl	z, MidiPkt_EnqueueControl_3368_Return
	ld xbc, (xiz)
	ld xwa, (xiz + 4)
	ld a, (xwa + 8)
	and a, (xbc + 3)
	jrl	z, MidiPkt_EnqueueControl_3368_Return
	ld	xwa, SysEx_Msg_35DC
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld a, (PANEL_PMEM_SETTINGS+3:16)
	and a, 0x1
	cp a, 1:i3
	jr	nz, MidiPkt_EnqueueControl_3368_NoPedal
	ld	xwa, MidiCtl_Rec_07
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld xbc, (xiz)
	ld xde, (xiz + 4)
	ld a, (xde + 8)
	and a, (xbc + 2)
	ld c, a
	ld a, (xde + 11)
	and a, 0xf
	jr	z, MidiPkt_EnqueueControl_3368_PedalNoShift
	srla c
MidiPkt_EnqueueControl_3368_PedalNoShift:
	inc 1, c
	jr	MidiPkt_EnqueueControl_3368_FormatData
MidiPkt_EnqueueControl_3368_NoPedal:
	ld xwa, (xiz + 4)
	ld bc, 6:i3
	call	ArpQueue_Enqueue
	ld xbc, (xiz)
	ld xde, (xiz + 4)
	ld a, (xde + 8)
	and a, (xbc + 2)
	ld c, a
	ld a, (xde + 11)
	and a, 0xf
	jr	z, MidiPkt_EnqueueControl_3368_FormatData
	srla c
MidiPkt_EnqueueControl_3368_FormatData:
	ld (xsp + 4), c
	lda xwa, (xsp + 4)
	ld c, (xwa)
	and c, 0xf
	ld (xwa + 1), c
	ld c, (xwa)
	srl c, 4
	ld (xwa), c
	ld bc, 3:i3
	call	ArpQueue_Enqueue
	call	ArpQueue_ComputeAndEnqueue
	ld	xwa, (0xbbc0:16)
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
MidiPkt_EnqueueControl_3368_Return:
	pop xiz
	inc 4, xsp
	ret
MidiPkt_EnqueueExtended2_Data:
	ret
MidiPkt_SendCtlValueSysEx:
	lda	xsp, (xsp-10)
	push	xiz
	ld	xiz, xwa
	ld	xiy, MidiPkt_MsgTemplate_336C
	lda	xix, (xsp+4)
	ldi85
	ldiw
	ld	xwa, (xiz+4)
	calr	MidiPkt_CheckGateCondition
	cp	hl, 0xffff
	jrl	z, MidiPkt_SendCtlValueSysEx_Epilogue
	lda	xbc, (MidiCtl_NullRecord:24)
	ld	xwa, (xiz+4)
	cp	xbc, xwa
	jr	z, MidiPkt_SendCtlValueSysEx_Epilogue
	ld	xbc, (xiz)
	ld	a, (xwa+8)
	and	a, (xbc+3)
	jr	z, MidiPkt_SendCtlValueSysEx_Epilogue
	ld	xwa, SysEx_Msg_35DC
	ld	bc, 6:i3
	call	ArpQueue_Enqueue
	pushw	6
	lda	xwa, (xsp+10)
	push	xwa
	ld	xwa, (xiz+4)
	push	xwa
	call	Mem_Copy
	lda	xsp, (xsp+10)
	lda	xwa, (xsp+8)
	ld	xbc, (xiz)
	ld	c, (xbc)
	set	5, c
	ld	(xwa+1), c
	ld	bc, 6:i3
	call	ArpQueue_Enqueue
	ld	xbc, (xiz)
	ld	xde, (xiz+4)
	ld	a, (xde+8)
	and	a, (xbc+2)
	ld	c, a
	ld	a, (xde+11)
	and	a, 15
	jr	z, MidiPkt_SendCtlValueSysEx_Skip
	.byte 0xcb, 0xff	; srl a,c -- the backend cannot spell this form
MidiPkt_SendCtlValueSysEx_Skip:
	lda	xwa, (xsp+4)
	ld	(xwa), c
	and	c, 15
	ld	(xwa+1), c
	ld	c, (xwa)
	srl	c, 4
	ld	(xwa), c
	ld	bc, 3:i3
	call	ArpQueue_Enqueue
	call	ArpQueue_ComputeAndEnqueue
	ld	xwa, (0xbbc0:16)
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
MidiPkt_SendCtlValueSysEx_Epilogue:
	pop	xiz
	lda	xsp, (xsp+10)
	ret
MidiPkt_CheckGateCondition:	.include "includes/generated/cc900/MidiPkt_CheckGateCondition.s"	; C: cc900/midipkt_routines.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	MidiPkt_CheckGateCondition_Second, MidiPkt_CheckGateCondition + 35
	.set	MidiPkt_CheckGateCondition_Blocked, MidiPkt_CheckGateCondition + 70
	.set	MidiPkt_CheckGateCondition_Pass, MidiPkt_CheckGateCondition + 74
MidiPkt_DispatchViaTable_4DCE:
	dec 8, xsp
	push xiz
	ld xiz, (xsp + 16)
	ld xwa, xiz
	ld	xbc, MidiCtl_MatchList7
	calr	MidiPkt_MatchParamInTable
	lda xwa, (xsp + 4)
	lda xbc, (xwa + 4)
	ld (xbc), xhl
	ld (xwa), xiz
	ld xbc, (xbc)
	ld c, (xbc + 16)
	extz bc
	sla bc, 2
	lda	xde, (MidiCtl_Handlers:24)
	exts xbc
	add xbc, xde
	ld xhl, (xbc)
	call (xhl)
	pop xiz
	inc 8, xsp
	ret
MidiPkt_DispatchData_Chan4:
	ld	(0xbc60:16), 4
	jr	MidiPkt_DispatchData_Chan6_Join2
MidiPkt_DispatchData_Chan3:
	ld	(0xbc60:16), 3
	jr	MidiPkt_DispatchData_Chan6_Join2
MidiPkt_DispatchData_Chan1:
	ld	(0xbc60:16), 1
	jr	MidiPkt_DispatchData_Chan6_Join2
MidiPkt_DispatchData_Chan2:
	ld	(0xbc60:16), 2
	jr	MidiPkt_DispatchData_Chan6_Join2
MidiPkt_DispatchData_Chan5:
	ld	(0xbc60:16), 5
	jr	MidiPkt_DispatchData_Chan6_Join2
MidiPkt_DispatchData_Chan6:
	ld	(0xbc60:16), 6
	jr	MidiPkt_DispatchData_Chan6_Join2
MidiPkt_DispatchData_Chan6_Join:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	AccWrap_PlayModeDispatch
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	a, (0xbc60:16)
	extz	wa
	jp	SysEx_InitiateSend
MidiPkt_DispatchData_Chan6_Join2:
	ld	a, (CURRENT_TITLE:16)
	cp	a, 87
	jr	z, MidiPkt_DispatchData_Chan6_Skip
	cp	(CURRENT_MODE:16), 1
	jr	nz, MidiPkt_DispatchData_Chan6_Skip2
	cp	a, 1:i3
	jr	nz, MidiPkt_DispatchData_Chan6_Skip2
MidiPkt_DispatchData_Chan6_Skip:
	jr	MidiPkt_DispatchData_Chan6_Join
MidiPkt_DispatchData_Chan6_Skip2:
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ld	bc, 4:i3
	ldw	de, 17
	jp	MIDI_ReadChannelParam
MidiPkt_SendBankSelect:
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ld bc, 4:i3
	call	SeqData_ReadFieldByIndex
	cp l, 0:i3
	ret z
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ld bc, 5:i3
	call	SeqData_ReadFieldByIndex
	cp l, 0x2b
	jr	z, MidiPkt_SendBankSelect_Send
	cp l, 0x2c
	ret nz
MidiPkt_SendBankSelect_Send:
	ld	xwa, SysEx_Msg_35AC
	ld bc, 5:i3
	call	ArpQueue_Enqueue
	ld	xwa, (0xbbc0:16)
	call	SeqOut_FlushTimedBuffer
	call	ArpQueue_SwapBuffers
	ret
; SysEx_OnGmSystemOn: Handler of message id 36, the Universal SysEx F0 7E 7F 09 01 (General MIDI System On): outside
;   the guarded titles sets bit 2 of the byte at 0xFDAD, writes it with AssswbWr (0x91, 3) and re-sends both output
;   banks. Basis: table + body.
SysEx_OnGmSystemOn:
	ld	a, (CURRENT_TITLE:16)
	cp	a, 108
	jr	c, SysEx_OnGmSystemOn_Skip
	cp	a, 118
	jr	ule, SysEx_OnGmSystemOn_Skip2
SysEx_OnGmSystemOn_Skip:
	bit	4, (PANEL_MIDI:16)
	ret	nz
SysEx_OnGmSystemOn_Skip2:
	cp	a, 153
	jr	ugt, SysEx_OnGmSystemOn_Skip3
	cp	a, 148
	ret	nc
SysEx_OnGmSystemOn_Skip3:
	set	7, (0x905d:16)
	lda	xbc, (PANEL_GM+3:16)
	ld	e, (xbc)
	set	2, e
	ld	(xbc), e
	extz	de
	pushw	4
	ldw	wa, 145
	ld	bc, 3:i3
	call	AssswbWr
	push	xiz
	call	SwbtWr_ReinitBothBanks
	pop	xiz
	ret
MidiPkt_SysExProcessor_Data:
	ld	a, (CURRENT_TITLE:16)
	cp	a, 108
	jr	c, MidiPkt_SysExProcessor_Data_Skip
	cp	a, 118
	jr	ule, MidiPkt_SysExProcessor_Data_Skip2
MidiPkt_SysExProcessor_Data_Skip:
	bit	4, (PANEL_MIDI:16)
	ret	nz
MidiPkt_SysExProcessor_Data_Skip2:
	cp	a, 153
	jr	ugt, MidiPkt_SysExProcessor_Data_Skip3
	cp	a, 148
	ret	nc
MidiPkt_SysExProcessor_Data_Skip3:
	lda	xbc, (PANEL_GM+3:16)
	ld	a, (xbc)
	bit	2, a
	ret	z
	set	7, (0x905d:16)
	ld	e, (xbc)
	res	2, e
	ld	(xbc), e
	extz	de
	pushw	4
	ldw	wa, 145
	ld	bc, 3:i3
	call	AssswbWr
	push	xiz
	call	SwbtWr_ReinitBothBanks
	pop	xiz
	ret
MidiPkt_SysExBulkTransfer_Data:
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ld	bc, 1:i3
	call	SeqData_ReadFieldByIndex
	extz	hl
	dec	1, hl
	cp	hl, 0:i3
	ret	lt
	cp	hl, 5:i3
	ret	gt
	add	hl, hl
	lda	xix, (SysExBulk_SwitchOffsets:24)
	ld	hl, (xix+hl)
	lda	xix, (SysEx_OnRolandGs_UseForRhythmPart:24)
	jp	t, (xix+hl)
SysEx_OnRolandGs_UseForRhythmPart:
	jr	MidiPkt_SysExBulkTransfer_Data_Helper2_Join
MidiPkt_SysExBulkTransfer_Data_Case2:
	jrl	MidiPkt_SysExBulkTransfer_Data_Helper2_Join3
MidiPkt_SysExBulkTransfer_Data_Case3:
	jrl	MidiPkt_SysExBulkTransfer_Data_Helper2_Join4
MidiPkt_SysExBulkTransfer_Data_Case4:
	jrl	SysEx_ApplyGsReverbLevel
MidiPkt_SysExBulkTransfer_Data_Case5:
	jrl	SysEx_ApplyGsChorusMacro
MidiPkt_SysExBulkTransfer_Data_Case6:
	calr	SysEx_ApplyGsChorusLevel
	ret
MidiPkt_SysExBulkTransfer_Data_Helper:
	lda	xde, (MIDIRX_PART_EVENT:16)
	ld	c, (xwa)
	ld	(xde), c
	ld	c, (xwa+1)
	ld	(xde+1), c
	ld	c, (xwa+2)
	ld	(xde+2), c
	ld	a, (xwa+3)
	ld	(xde+3), a
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	MidiCC_ApplyBankSelect
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ret
MidiPkt_SysExBulkTransfer_Data_Helper2:
	lda	xde, (MIDIRX_PART_EVENT:16)
	ld	c, (xwa)
	ld	(xde), c
	ld	c, (xwa+1)
	ld	(xde+1), c
	ld	c, (xwa+2)
	ld	(xde+2), c
	ld	a, (xwa+3)
	ld	(xde+3), a
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	MidiRx_ApplyProgramChange
	call	SwbtWr_ReinitOutputBank
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ret
MidiPkt_SysExBulkTransfer_Data_Helper2_Join:
	lda	xsp, (xsp-12)
	push	qiz
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ldw	bc, 9
	call	SeqData_ReadFieldByIndex
	ldfr_berp	l, 251
	sub_erpb	251, 16
	cp_erpb	251, 16
	jrl	nc, MidiPkt_SysExBulkTransfer_Data_Helper2_Epilogue
	ldto_berp	a, 251
	extz	wa
	lda	xbc, (SysExBulk_SlotMap:24)
	ld	a, (xbc+wa)
	ldfr_berp	a, 251
	; v7 bytes do not decode as v10's `sub	(xbc-31), ix`
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ldw	bc, 11
	call	SeqData_ReadFieldByIndex
	; v7 bytes; v10 has: .byte 0xb6
	; v7 bytes do not decode as v10's `pop	xiz`
	cp	l, 2:i3
	jrl	ugt, MidiPkt_SysExBulkTransfer_Data_Helper2_Epilogue
	cp_erpb	251, 15
	jrl	z, MidiPkt_SysExBulkTransfer_Data_Helper2_Epilogue
	ldto_berp	a, 251
	extz	wa
	cp	l, 0:i3
	jr	z, MidiPkt_SysExBulkTransfer_Data_Helper2_Skip
	pushw	0
	ld	bc, 0:i3
	ld	de, 0:i3
	call	SndParam_NotifyAndReturn
	ldto_berp	a, 251
	extz	wa
	pushw	0
	ldw	bc, 32
	ldw	de, 120
	call	SndParam_NotifyAndReturn
	ld	xiy, SysExBulk_FrameTemplate0
	lda	xix, (xsp+10)
	ldiw
	ldiw
	lda	xwa, (xsp+10)
	ldto_berp	c, 251
	ld	(xwa), c
	calr	MidiPkt_SysExBulkTransfer_Data_Helper
	ld	xiy, SysExBulk_FrameTemplate1
	lda	xix, (xsp+6)
	ldiw
	ldiw
	lda	xwa, (xsp+6)
	ldto_berp	c, 251
	ld	(xwa), c
	calr	MidiPkt_SysExBulkTransfer_Data_Helper
	ld	xiy, SysExBulk_FrameTemplate2
	lda	xix, (xsp+2)
	ldiw
	ldiw
	lda	xwa, (xsp+2)
	ldto_berp	c, 251
	ld	(xwa), c
	jr	MidiPkt_SysExBulkTransfer_Data_Helper2_Join2
MidiPkt_SysExBulkTransfer_Data_Helper2_Skip:
	pushw	0
	ld	bc, 0:i3
	ld	de, 0:i3
	call	SndParam_NotifyAndReturn
	ldto_berp	a, 251
	extz	wa
	pushw	0
	ldw	bc, 32
	ld	de, 0:i3
	call	SndParam_NotifyAndReturn
	ld	xiy, SysExBulk_FrameTemplate3
	lda	xix, (xsp+10)
	ldiw
	ldiw
	lda	xwa, (xsp+10)
	ldto_berp	c, 251
	ld	(xwa), c
	calr	MidiPkt_SysExBulkTransfer_Data_Helper
	ld	xiy, SysExBulk_FrameTemplate4
	lda	xix, (xsp+6)
	ldiw
	ldiw
	lda	xwa, (xsp+6)
	ldto_berp	c, 251
	ld	(xwa), c
	calr	MidiPkt_SysExBulkTransfer_Data_Helper
	ld	xiy, SysExBulk_FrameTemplate5
	lda	xix, (xsp+2)
	ldiw
	ldiw
	lda	xwa, (xsp+2)
	ldto_berp	c, 251
	ld	(xwa), c
MidiPkt_SysExBulkTransfer_Data_Helper2_Join2:
	calr	MidiPkt_SysExBulkTransfer_Data_Helper2
MidiPkt_SysExBulkTransfer_Data_Helper2_Epilogue:
	pop	qiz
	lda	xsp, (xsp+12)
	ret
MidiPkt_SysExBulkTransfer_Data_Helper2_Join3:
	jrl	SysEx_OnGmSystemOn
MidiPkt_SysExBulkTransfer_Data_Helper2_Join4:
	dec	2, xsp
	push	xiz
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ldw	bc, 11
	call	SeqData_ReadFieldByIndex
	ld	(xsp+4), l
	ld	a, (xsp+4)
	extz	wa
	calr	SysEx_ClampVoiceIndex8
	extz	hl
	ld	xwa, 0x4b00
	ld	bc, hl
	call	DSPCfg_WriteParamFull
	cp	hl, 0:i3
	jr	lt, MidiPkt_SysExBulkTransfer_Data_Helper2_Epilogue2
	ld	xwa, 0x4b04
	call	DSPCfg_ReadParam_Map0
	ld	qiz, hl
	cp	qiz, 0
	jr	lt, MidiPkt_SysExBulkTransfer_Data_Helper2_Epilogue2
	ld	iz, 0:i3
	cp	qiz, 0
	jr	le, MidiPkt_SysExBulkTransfer_Data_Helper2_Skip3
MidiPkt_SysExBulkTransfer_Data_Helper2_Loop:
	ld	a, (xsp+4)
	extz	wa
	ldto_berp	c, 248
	extz	bc
	calr	SysEx_DispatchByChannel_49
	ld	bc, hl
	cp	bc, 0xd8f0
	jr	z, MidiPkt_SysExBulkTransfer_Data_Helper2_Skip2
	ld	wa, iz
	exts	xwa
	add	xwa, 0x4b10
	call	DSPCfg_WriteParamFull
MidiPkt_SysExBulkTransfer_Data_Helper2_Skip2:
	inc	1, iz
	cp	iz, qiz
	jr	lt, MidiPkt_SysExBulkTransfer_Data_Helper2_Loop
MidiPkt_SysExBulkTransfer_Data_Helper2_Skip3:
	push	xiz
	call	SwbtWr_ReinitOutputBank
	pop	xiz
MidiPkt_SysExBulkTransfer_Data_Helper2_Epilogue2:
	pop	xiz
	inc	2, xsp
	ret
; =============================================================================
; DSP Configuration & SysEx Processing
; =============================================================================
;
; DSP effect parameter handlers (reverb, chorus, EQ, compressor)
; and System Exclusive (SysEx) command processing. Manages effect
; presets and real-time parameter editing.
; =============================================================================

SysEx_ClampVoiceIndex8:
	cp	a, 8
	jr	c, SysEx_ClampVoiceIndex8_DoLookup
	ld	a, 0:opc
SysEx_ClampVoiceIndex8_DoLookup:
	extz	wa
	lda	xbc, (SysEx4B_VoiceIndexMap8:24)
	ld	l, (xbc+wa)
	ret
SysEx_ApplyGsReverbLevel:
	dec	2, xsp
	push	xiz
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ldw	bc, 11
	call	SeqData_ReadFieldByIndex
	ld	(xsp+4), l
	ld	a, (xsp+4)
	extz	wa
	calr	SysEx_ClampVoiceIndex128
	ld	(xsp+4), l
	ld	xwa, 0x4b04
	call	DSPCfg_ReadParam_Map0
	ld	qiz, hl
	cp	qiz, 0
	jr	lt, SysEx_ClampVoiceIndex8_Epilogue
	ld	iz, 0:i3
	cp	qiz, 0
	jr	le, SysEx_ClampVoiceIndex8_Join
SysEx_ClampVoiceIndex8_Loop:
	ld	wa, iz
	exts	xwa
	add	xwa, 0x4b10
	call	DSPCfg_ResolveAndExtract
	cp	hl, 1:i3
	jr	z, SysEx_ClampVoiceIndex8_Skip
	cp	hl, 2:i3
	jr	nz, SysEx_ClampVoiceIndex8_Skip2
SysEx_ClampVoiceIndex8_Skip:
	ld	wa, iz
	exts	xwa
	add	xwa, 0x4b10
	ld	c, (xsp+4)
	extz	bc
	call	DSPCfg_WriteParamFull
	jr	SysEx_ClampVoiceIndex8_Join
SysEx_ClampVoiceIndex8_Skip2:
	inc	1, iz
	cp	iz, qiz
	jr	lt, SysEx_ClampVoiceIndex8_Loop
SysEx_ClampVoiceIndex8_Join:
	push	xiz
	call	SwbtWr_ReinitOutputBank
	pop	xiz
SysEx_ClampVoiceIndex8_Epilogue:
	pop	xiz
	inc	2, xsp
	ret
SysEx_ClampVoiceIndex128:
	cp	a, 128
	jr	c, SysEx_ClampVoiceIndex128_DoLookup
	ld	a, 0:opc
SysEx_ClampVoiceIndex128_DoLookup:
	extz	wa
	lda	xbc, (SysEx4B_LevelCurve128:24)
	ld	l, (xbc+wa)
	ret
SysEx_ApplyGsChorusMacro:
	dec	2, xsp
	push	xiz
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ldw	bc, 11
	call	SeqData_ReadFieldByIndex
	ld	(xsp+4), l
	ld	a, (xsp+4)
	extz	wa
	calr	SysEx_ClampVoiceIndex8_49
	extz	hl
	ld	xwa, 0x4900
	ld	bc, hl
	call	DSPCfg_WriteParamFull
	cp	hl, 0:i3
	jr	lt, SysEx_ClampVoiceIndex128_Epilogue
	ld	xwa, 0x4904
	call	DSPCfg_ReadParam_Map0
	ld	qiz, hl
	cp	qiz, 0
	jr	lt, SysEx_ClampVoiceIndex128_Epilogue
	ld	iz, 0:i3
	cp	qiz, 0
	jr	le, SysEx_ClampVoiceIndex128_Skip2
SysEx_ClampVoiceIndex128_Loop:
	ld	a, (xsp+4)
	extz	wa
	ldto_berp	c, 248
	extz	bc
	calr	SysEx_DispatchByChannel
	ld	bc, hl
	cp	bc, 0xd8f0
	jr	z, SysEx_ClampVoiceIndex128_Skip
	ld	wa, iz
	exts	xwa
	add	xwa, 0x4910
	call	DSPCfg_WriteParamFull
SysEx_ClampVoiceIndex128_Skip:
	inc	1, iz
	cp	iz, qiz
	jr	lt, SysEx_ClampVoiceIndex128_Loop
SysEx_ClampVoiceIndex128_Skip2:
	push	xiz
	call	SwbtWr_ReinitOutputBank
	pop	xiz
SysEx_ClampVoiceIndex128_Epilogue:
	pop	xiz
	inc	2, xsp
	ret
SysEx_ClampVoiceIndex8_49:	.include "includes/generated/cc900/SysEx_ClampVoiceIndex8_49.s"	; C: cc900/midipkt_routines_m290_xs.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SysEx_ClampVoiceIndex8_49_DoLookup, SysEx_ClampVoiceIndex8_49 + 7
SysEx_ApplyGsChorusLevel:
	dec	2, xsp
	push	xiz
	ld	xwa, (MIDISEQ_ACTIVE_BUF_PTR:16)
	ldw	bc, 11
	call	SeqData_ReadFieldByIndex
	ld	(xsp+4), l
	ld	a, (xsp+4)
	extz	wa
	calr	SysEx_ClampVoiceIndex128_49
	ld	(xsp+4), l
	ld	xwa, 0x4904
	call	DSPCfg_ReadParam_Map0
	ld	qiz, hl
	cp	qiz, 0
	jr	lt, SysEx_ApplyGsChorusLevel_Epilogue
	ld	iz, 0:i3
	cp	qiz, 0
	jr	le, SysEx_ApplyGsChorusLevel_Join
SysEx_ApplyGsChorusLevel_Loop:
	ld	wa, iz
	exts	xwa
	add	xwa, 0x4910
	call	DSPCfg_ResolveAndExtract
	cp	hl, 1:i3
	jr	z, SysEx_ApplyGsChorusLevel_Skip
	cp	hl, 2:i3
	jr	nz, SysEx_ApplyGsChorusLevel_Skip2
SysEx_ApplyGsChorusLevel_Skip:
	ld	wa, iz
	exts	xwa
	add	xwa, 0x4910
	ld	c, (xsp+4)
	extz	bc
	call	DSPCfg_WriteParamFull
	jr	SysEx_ApplyGsChorusLevel_Join
SysEx_ApplyGsChorusLevel_Skip2:
	inc	1, iz
	cp	iz, qiz
	jr	lt, SysEx_ApplyGsChorusLevel_Loop
SysEx_ApplyGsChorusLevel_Join:
	push	xiz
	call	SwbtWr_ReinitOutputBank
	pop	xiz
SysEx_ApplyGsChorusLevel_Epilogue:
	pop	xiz
	inc	2, xsp
	ret
SysEx_ClampVoiceIndex128_49:	.include "includes/generated/cc900/SysEx_ClampVoiceIndex128_49.s"	; C: cc900/midipkt_routines_m290_xs.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SysEx_ClampVoiceIndex128_49_DoLookup, SysEx_ClampVoiceIndex128_49 + 7
SysEx_DispatchByChannel:
	ldw	hl, 0xd8f0
	ld	e, c
	extz	de
	add	de, de
	extz	wa
	cp	wa, 0:i3
	ret	mi
	cp	wa, 7:i3
	ret	gt
	add	wa, wa
	lda	xix, (SysEx4B_ChannelSwitch:24)
	ld	wa, (xix+wa)
	lda	xix, (SysEx_DispatchByChannel_ChorusMacroChorus1:24)
	jp	t, (xix+wa)
; SysEx_DispatchByChannel_ChorusMacroChorus1: GS chorus macro 0 (Chorus 1; also the switch base): value C of
;   SysEx4B_ChannelWords0, written by the callers to DSP param 0x4910+C (DSP EFFECT slot). Basis: switch value (GS
;   CHORUS MACRO) + body.
SysEx_DispatchByChannel_ChorusMacroChorus1:
	cp	c, 5:i3
	ret	nc
	ld	xwa, SysEx4B_ChannelWords0
	jr	SysEx_DispatchByChannel_ChorusMacroChorus1_Join
SysEx_DispatchByChannel_Case1:
	cp	c, 7:i3
	ret	nc
	ld	xwa, SysEx4B_ChannelWords1
	jr	SysEx_DispatchByChannel_ChorusMacroChorus1_Join
SysEx_DispatchByChannel_Case2:
	cp	c, 5:i3
	ret	nc
	ld	xwa, SysEx4B_ChannelWords2
	jr	SysEx_DispatchByChannel_ChorusMacroChorus1_Join
SysEx_DispatchByChannel_Case3:
	cp	c, 7:i3
	ret	nc
	ld	xwa, SysEx4B_ChannelWords3
	jr	SysEx_DispatchByChannel_ChorusMacroChorus1_Join
SysEx_DispatchByChannel_Case4:
	cp	c, 8
	ret	nc
	ld	xwa, SysEx4B_ChannelWords4
	jr	SysEx_DispatchByChannel_ChorusMacroChorus1_Join
SysEx_DispatchByChannel_Case5:
	cp	c, 8
	ret	nc
	ld	xwa, SysEx4B_ChannelWords5
	jr	SysEx_DispatchByChannel_ChorusMacroChorus1_Join
SysEx_DispatchByChannel_Case6:
	cp	c, 7:i3
	ret	nc
	ld	xwa, SysEx4B_ChannelWords6
	jr	SysEx_DispatchByChannel_ChorusMacroChorus1_Join
SysEx_DispatchByChannel_Case7:
	cp	c, 7:i3
	ret	nc
	ld	xwa, SysEx4B_ChannelWords7
SysEx_DispatchByChannel_ChorusMacroChorus1_Join:
	ld	hl, (xwa+de)
	ret
SysEx_DispatchByChannel_49:
	ldw	hl, 0xd8f0
	ld	e, c
	extz	de
	add	de, de
	extz	wa
	cp	wa, 0:i3
	ret	mi
	cp	wa, 7:i3
	ret	gt
	add	wa, wa
	lda	xix, (SysEx49_ChannelSwitch:24)
	ld	wa, (xix+wa)
	lda	xix, (SysEx_DispatchByChannel_49_ReverbMacroRoom1:24)
	jp	t, (xix+wa)
; SysEx_DispatchByChannel_49_ReverbMacroRoom1: GS reverb macro 0 (Room 1; also the switch base): value C of
;   SysEx49_ChannelWords0, written by the callers to DSP param 0x4B10+C. Basis: switch value (GS REVERB MACRO) + body.
SysEx_DispatchByChannel_49_ReverbMacroRoom1:
	cp	c, 5:i3
	ret	nc
	ld	xwa, SysEx49_ChannelWords0
	jr	SysEx_DispatchByChannel_49_Entry
; SysEx_DispatchByChannel_49_ReverbMacroRoom2: GS reverb macro 1 (Room 2): value i of SysEx49_ChannelWords1, written
;   by the callers to DSP param 0x4B10+i
SysEx_DispatchByChannel_49_ReverbMacroRoom2:
	cp	c, 5:i3
	ret	nc
	ld	xwa, SysEx49_ChannelWords1
	jr	SysEx_DispatchByChannel_49_Entry
; SysEx_DispatchByChannel_49_ReverbMacroRoom3: GS reverb macro 2 (Room 3): value i of SysEx49_ChannelWords2, written
;   by the callers to DSP param 0x4B10+i
SysEx_DispatchByChannel_49_ReverbMacroRoom3:
	cp	c, 5:i3
	ret	nc
	ld	xwa, SysEx49_ChannelWords2
	jr	SysEx_DispatchByChannel_49_Entry
; SysEx_DispatchByChannel_49_ReverbMacroHall1: GS reverb macro 3 (Hall 1): value i of SysEx49_ChannelWords3, written
;   by the callers to DSP param 0x4B10+i
SysEx_DispatchByChannel_49_ReverbMacroHall1:
	cp	c, 5:i3
	ret	nc
	ld	xwa, SysEx49_ChannelWords3
	jr	SysEx_DispatchByChannel_49_Entry
; SysEx_DispatchByChannel_49_ReverbMacroHall2: GS reverb macro 4 (Hall 2): value i of SysEx49_ChannelWords4, written
;   by the callers to DSP param 0x4B10+i
SysEx_DispatchByChannel_49_ReverbMacroHall2:
	cp	c, 5:i3
	ret	nc
	ld	xwa, SysEx49_ChannelWords4
	jr	SysEx_DispatchByChannel_49_Entry
; SysEx_DispatchByChannel_49_ReverbMacroPlate: GS reverb macro 5 (Plate): value i of SysEx49_ChannelWords5, written by
;   the callers to DSP param 0x4B10+i
SysEx_DispatchByChannel_49_ReverbMacroPlate:
	cp	c, 5:i3
	ret	nc
	ld	xwa, SysEx49_ChannelWords5
	jr	SysEx_DispatchByChannel_49_Entry
; SysEx_DispatchByChannel_49_ReverbMacroDelay: GS reverb macro 6 (Delay): value i of SysEx49_ChannelWords6, written by
;   the callers to DSP param 0x4B10+i
SysEx_DispatchByChannel_49_ReverbMacroDelay:
	cp	c, 6:i3
	ret	nc
	ld	xwa, SysEx49_ChannelWords6
	jr	SysEx_DispatchByChannel_49_Entry
; SysEx_DispatchByChannel_49_ReverbMacroPanningDelay: GS reverb macro 7 (Panning Delay): value i of
;   SysEx49_ChannelWords7, written by the callers to DSP param 0x4B10+i
SysEx_DispatchByChannel_49_ReverbMacroPanningDelay:
	cp	c, 6:i3
	ret	nc
	ld	xwa, SysEx49_ChannelWords7
SysEx_DispatchByChannel_49_Entry:
	ld	hl, (xwa+de)
	ret
SysEx_ValidateRolandHeader:	.include "includes/generated/cc900/SysEx_ValidateRolandHeader.s"	; C: cc900/dsp_config_sysex_m290.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SysEx_ValidateRolandHeader_NonZeroChan, SysEx_ValidateRolandHeader + 62
	.set	SysEx_ValidateRolandHeader_Dispatch, SysEx_ValidateRolandHeader + 86
	.set	SysEx_ValidateRolandHeader_Cmd33, SysEx_ValidateRolandHeader + 115
	.set	SysEx_ValidateRolandHeader_Cmd38, SysEx_ValidateRolandHeader + 122
	.set	SysEx_ValidateRolandHeader_Cmd3A, SysEx_ValidateRolandHeader + 129
SysEx_ApplyVoiceParam_4B:
	dec 8, xsp
	push xiz
	ld (xsp + 6), xbc
	ld (xsp + 10), a
	lda xwa, (PANEL_DIGITAL_REVERB:16)
	sub xwa, 0xf980
	add (xsp + 6), xwa
	ld a, (xsp + 10)
	extz wa
	calr	SysEx_ClampVoiceIndex8
	extz hl
	ld xwa, 0x4b00
	ld bc, hl
	ld xde, (xsp + 6)
	call	DSPCfg_WriteParamSimple
	cp hl, 0:i3
	jr	lt, SysEx_ApplyVoiceParam_4B_Return
	lda xwa, (PANEL_DIGITAL_REVERB:16)
	cp xwa, (xsp + 6)
	jr	z, SysEx_ApplyVoiceParam_4B_ReadSubParams
	ld a, (xwa)
	ld (xsp + 4), a
	ld a, (xsp + 10)
	extz wa
	calr	SysEx_ClampVoiceIndex8
	ld (PANEL_DIGITAL_REVERB:16), l
SysEx_ApplyVoiceParam_4B_ReadSubParams:
	ld xwa, 0x4b04
	call	DSPCfg_ReadParam_Map0
	ldfr_werp HL, 0xfa
	cpiw_erp 0xfa, 0
	jr	ge, SysEx_ApplyVoiceParam_4B_IterateSlots
	lda xbc, (PANEL_DIGITAL_REVERB:16)
	cp xbc, (xsp + 6)
	jr	z, SysEx_ApplyVoiceParam_4B_SkipRestore
	ld a, (xsp + 4)
	ld (xbc), a
SysEx_ApplyVoiceParam_4B_SkipRestore:
	jr	SysEx_ApplyVoiceParam_4B_Return
SysEx_ApplyVoiceParam_4B_IterateSlots:
	ld iz, 0:i3
	cpiw_erp 0xfa, 0
	jr	le, SysEx_ApplyVoiceParam_4B_RestoreSlotId
SysEx_ApplyVoiceParam_4B_SlotLoop:
	ld a, (xsp + 10)
	extz wa
	ldto_berp C, 0xf8
	extz bc
	calr	SysEx_DispatchByChannel_49
	ld bc, hl
	cp bc, 0xd8f0
	jr	z, SysEx_ApplyVoiceParam_4B_SlotNext
	ld wa, iz
	exts xwa
	add xwa, 0x4b10
	ld xde, (xsp + 6)
	call	DSPCfg_WriteParamSimple
SysEx_ApplyVoiceParam_4B_SlotNext:
	inc 1, iz
	cpw_erp IZ, 0xfa
	jr	lt, SysEx_ApplyVoiceParam_4B_SlotLoop
SysEx_ApplyVoiceParam_4B_RestoreSlotId:
	lda xbc, (PANEL_DIGITAL_REVERB:16)
	cp xbc, (xsp + 6)
	jr	z, SysEx_ApplyVoiceParam_4B_Return
	ld a, (xsp + 4)
	ld (xbc), a
SysEx_ApplyVoiceParam_4B_Return:
	pop xiz
	inc 8, xsp
	ret
SysEx_ApplyVoiceParam_4B_128:
	dec 8, xsp
	push xiz
	ld (xsp + 6), xbc
	ld (xsp + 10), a
	lda xwa, (PANEL_DIGITAL_REVERB:16)
	sub xwa, 0xf980
	add (xsp + 6), xwa
	ld a, (xsp + 10)
	extz wa
	calr	SysEx_ClampVoiceIndex128
	ld (xsp + 10), l
	lda xbc, (PANEL_DIGITAL_REVERB:16)
	cp xbc, (xsp + 6)
	jr	z, SysEx_ApplyVoiceParam_4B_128_ReadSub
	ld a, (xbc)
