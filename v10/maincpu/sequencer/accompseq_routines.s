; =============================================================================
; Accompaniment Sequencer
; =============================================================================
;
; Accompaniment sequencer periodic processing. Handles real-time
; accompaniment playback, manual MIDI mode, and fade-out timing.
; =============================================================================

AccompSeq_PeriodicEntry:
	jp AccompSeq_PeriodicMain

; Jumps to AccompSeq_ManualMidiMode2.
; Called from VoiceMode_ParamHandler_4.
AccompSeq_ManualMidiEntry2:
	jp AccompSeq_ManualMidiMode2

; Jumps to AccompSeq_ManualMidiMode1.
; Called from MidiStream_RefreshDisplay.
AccompSeq_ManualMidiEntry1:
	jp AccompSeq_ManualMidiMode1

AccompSeq_PeriodicMain:
	calr AccompSeq_CaptureTimerState
	and (0x7e53:16), 223
	calr AccompSeq_CheckChannelActive
	bit 5, (0x7e53:16)
	jr nz, AccompSeq_PeriodicReturn
	calr AccompSeq_FadeOutTick
	call AccPlay_TickVector
	calr AccompSeq_SaveTimerSnapshot

AccompSeq_PeriodicReturn:
	ret

; With interrupts masked to level 6: clears byte 0x46b and copies the word 0x468 to 0x7e1c, byte
; 0x46a to 0x7e1e and byte 0x41f to 0x7e1f.
AccompSeq_CaptureTimerState:
	jr AccompSeq_ReadTimerRegisters

AccompSeq_ReadTimerRegisters:
	xor a, a
	ei 6
	ld (1131:16), a
	ld wa, (1128:16)
	ld (0x7e1c:16), wa
	ld a, (1130:16)
	ld (0x7e1e:16), a
	ld a, (1055:16)
	ld (0x7e1f:16), a
	ei 0
	ret

; Copies the snapshot 0x7e1c (word), 0x7e1e, 0x7e1f to 0x7e20, 0x7e22, 0x7e23.
AccompSeq_SaveTimerSnapshot:
	ld wa, (0x7e1c:16)
	ld (0x7e20:16), wa
	ld a, (0x7e1e:16)
	ld (0x7e22:16), a
	ld a, (0x7e1f:16)
	ld (0x7e23:16), a
	ret

AccompSeq_CheckChannelActive:
	bit 2, (0x7e1f:16)
	jr nz, AccompSeq_SetupChannel1
	jp AccompSeq_ChannelSetupDone

AccompSeq_SetupChannel1:
	bit 0, (0x7e24:16)
	jr z, AccompSeq_SetupChannel2
	ld (0x7e52:16), 0
	ld xwa, 0x7aec
	ld (0x7e4c:16), xwa
	ld xwa, 0x7e40
	ld (0x7e48:16), xwa
	ld xwa, 0x7e72
	ld (0x7e74:16), xwa
	ld wa, (0x7e2c:16)
	ld (ACCSEQ_BLOCK:16), wa
	ld wa, (0x7e2e:16)
	ld (0x7e44:16), wa
	ld wa, (0x7e3c:16)
	ld (ACCSEQ_BEAT_COUNTER:16), wa
	ld a, (0x7e6e:16)
	ld (0x7e6d:16), a
	calr AccompSeq_InitEventDispatch
	ld a, (0x7e6d:16)
	ld (0x7e6e:16), a
	ld wa, (ACCSEQ_BEAT_COUNTER:16)
	ld (0x7e3c:16), wa
	ld wa, (0x7e44:16)
	ld (0x7e2e:16), wa
	ld wa, (ACCSEQ_BLOCK:16)
	ld (0x7e2c:16), wa

AccompSeq_SetupChannel2:
	bit 1, (0x7e24:16)
	jr z, AccompSeq_ChannelSetupDone
	ld (0x7e52:16), 1
	ld xwa, 0x7bec
	ld (0x7e4c:16), xwa
	ld xwa, 0x7e41
	ld (0x7e48:16), xwa
	ld xwa, 0x7e73
	ld (0x7e74:16), xwa
	ld wa, (0x7e30:16)
	ld (ACCSEQ_BLOCK:16), wa
	ld wa, (0x7e32:16)
	ld (0x7e44:16), wa
	ld wa, (0x7e3e:16)
	ld (ACCSEQ_BEAT_COUNTER:16), wa
	ld a, (0x7e6f:16)
	ld (0x7e6d:16), a
	calr AccompSeq_InitEventDispatch
	ld a, (0x7e6d:16)
	ld (0x7e6f:16), a
	ld wa, (ACCSEQ_BEAT_COUNTER:16)
	ld (0x7e3e:16), wa
	ld wa, (0x7e44:16)
	ld (0x7e32:16), wa
	ld wa, (ACCSEQ_BLOCK:16)
	ld (0x7e30:16), wa

AccompSeq_ChannelSetupDone:
	ret

AccompSeq_IncrementTickCounter:
	ld	hl, (1128:16)
	ld	a, (1130:16)
	inc	1, a
	cp	a, 96
	jr	nz, AccompSeq_IncrementTickCounter_Skip
	xor	a, a
	inc	1, hl
AccompSeq_IncrementTickCounter_Skip:
	ld	(1128:16), hl
	ld	(1130:16), a
	inc	1, (1132:16)
	call	SeqEvt_EntryPoint1
	call	SeqEvt_EntryPoint2
	ret

AccompSeq_InitEventDispatch:
	ld a, 0x9:opc
	and (0x7e53:16), 252

AccompSeq_EventDispatchLoop:
	bit 0, (0x7e53:16)
	jr z, AccompSeq_DispatchByOpcode
	jp AccompSeq_EventDispatchDone

AccompSeq_DispatchByOpcode:
	calr ResolveVRAMAddressForVoice
	ld a, (xiy)
	cp a, 0x84
	jr nz, AccompSeq_CheckLoopMarker
	calr AccompSeq_UpdatePosition
	jr AccompSeq_EventDispatchLoop

AccompSeq_CheckLoopMarker:
	cp a, 0x83
	jr nz, AccompSeq_CheckTimedOpcodes
	calr AccompSeq_HandlePartTransition
	jr AccompSeq_EventDispatchLoop

AccompSeq_CheckTimedOpcodes:
	cp a, 0x81
	jr z, AccompSeq_HandleEndMarker
	cp a, 0x90
	jr z, AccompSeq_ProcessTimedEvent
	cp a, 0x91
	jr z, AccompSeq_ProcessTimedEvent
	cp a, 0xd2
	jr z, AccompSeq_ProcessTimedEvent
	cp a, 0xd1
	jr z, AccompSeq_ProcessTimedEvent
	cp a, 0xd3
	jr z, AccompSeq_ProcessTimedEvent
	cp a, 0xd4
	jr z, AccompSeq_ProcessTimedEvent
	cp a, 0xd5
	jr z, AccompSeq_ProcessTimedEvent
	cp a, 0xd7
	jr z, AccompSeq_ProcessTimedEvent
	cp a, 0xc0
	jr z, AccompSeq_ProcessTimedEvent
	calr AccompSeq_AdvancePosition
	jr AccompSeq_EventDispatchLoop

AccompSeq_ProcessTimedEvent:
	calr AccompSeq_CheckPatternEnd
	call AccompSeq_CalcDeltaTime
	cp a, 0x18
	jr ugt, AccompSeq_SetTimePending
	calr AccompSeq_ParseEvents
	jr AccompSeq_EventDispatchLoop

AccompSeq_SetTimePending:
	or (0x7e53:16), 1
	jr AccompSeq_EventDispatchLoop

AccompSeq_HandleEndMarker:
	bit 1, (0x7e53:16)
	jr z, AccompSeq_EndMarkerCalcTime
	or (0x7e53:16), 1
	jr AccompSeq_EventDispatchLoop

AccompSeq_EndMarkerCalcTime:
	ld a, 0x60:opc
	call AccompSeq_CalcDeltaTime
	cp a, 0x18
	jr ule, AccompSeq_EndMarkerAdvance
	or (0x7e53:16), 1
	jp AccompSeq_EventDispatchLoop

AccompSeq_EndMarkerAdvance:
	or (0x7e53:16), 2
	ld wa, (ACCSEQ_BEAT_COUNTER:16)
	inc 1, wa
	ld (ACCSEQ_BEAT_COUNTER:16), wa
	calr AccompSeq_AdvancePosition
	jp AccompSeq_EventDispatchLoop

AccompSeq_EventDispatchDone:
	ret

; Peeks at the byte after the accompaniment-sequence read position (ResolveVRAMAddressForVoice);
; when it is the page end 0x87, returns the first data byte of the next page instead
; (AccompSeq_ReadBeatHeader, AccompSeq_BuildVRAMAddr with offset 6).  Out: A.  Preserves XIY.
AccompSeq_CheckPatternEnd:
	push xiy
	calr ResolveVRAMAddressForVoice
	ld a, (xiy + 1)
	cp a, 0x87
	jr nz, AccompSeq_PatternEndReturn
	calr AccompSeq_ReadBeatHeader
	ldfr_werp WA, 0xe2
	ld wa, 6:i3
	calr AccompSeq_BuildVRAMAddr
	ld a, (xiy)

AccompSeq_PatternEndReturn:
	pop xiy
	ret

; ============================================================================
; AccompSeq_AdvancePosition - Advance the accompaniment sequencer position
; ============================================================================
; Input:  None (reads from sequencer state at 32322-32324)
; Output: None (updates position counters)
; Increments the tick counter (32324). On tick overflow (wrap to 0),
; increments the beat counter (32322). Checks for pattern end marker
; (0x87) and handles looping by resetting position via sub-calls.
; ============================================================================
AccompSeq_AdvancePosition:
	ld wa, (0x7e44:16)
	inc 1, wa
	ld (0x7e44:16), wa
	cp wa, 0:i3
	jr nz, AccompSeq_AdvanceCheckPattern
	pushw wa
	ld wa, (ACCSEQ_BLOCK:16)
	inc 1, wa
	ld (ACCSEQ_BLOCK:16), wa
	popw wa

AccompSeq_AdvanceCheckPattern:
	calr ResolveVRAMAddressForVoice
	ld a, (xiy)
	cp a, 0x87
	jr nz, AccompSeq_AdvanceDone
	calr AccompSeq_ReadBeatHeader
	ld (ACCSEQ_BLOCK:16), wa
	ldfr_werp WA, 0xe2
	ld wa, 6:i3
	ld (0x7e44:16), wa
	calr AccompSeq_BuildVRAMAddr
	ld a, (xiy)

AccompSeq_AdvanceDone:
	ret

; Out: in pool mode ((0x7e25) 128 or more) XIY = the current block's base (AccompSeq_GetBlockBase);
; otherwise IY = (ACCSEQ_BLOCK).
AccompSeq_VRAMHelperData:
	cp	(0x7e25:16), 128
	jr	c, AccompSeq_VRAMHelperData_Skip
	calr	AccompSeq_GetBlockBase
	jr	AccompSeq_VRAMHelperData_Return
AccompSeq_VRAMHelperData_Skip:
	ld	wa, (ACCSEQ_BLOCK:16)
	ld	iy, wa
AccompSeq_VRAMHelperData_Return:
	ret
; AccompSeq_GetBlockBase: Returns XIY = 0x1E8B00 + 256 * ((ACCSEQ_BLOCK) & 0xFFF), the start of the accompaniment
;   sequencer's current 256-byte data block in the block pool. Basis: callers + body -- AccompSeq_VRAMHelperData uses
;   it in pool mode ((0x7E25) >= 128); AccompSeq_InlineCodeBlock follows a 0x87 link by storing the next block in
;   0x7E42, calling it, and setting the offset IY = 6.
AccompSeq_GetBlockBase:
	ld	wa, (ACCSEQ_BLOCK:16)
	and	xwa, 4095
	sla	xwa, 8
	add	xwa, 0x1e8b00
	ld	xiy, xwa
	ret

; Returns the address of the accompaniment-sequence read position.
;   With (0x7e25) >= 0x80 and bit 0 of 0x7e6d clear: XIY = 0x1e8b00 + (page 0x7e42 & 0xfff) * 256
;   + (offset 0x7e44 & 0xff), in the MIDI sequence buffer pool.  Otherwise XIY = the offset word
;   and the page is put in QWA (upper word of XWA, code 0xe2).
ResolveVRAMAddressForVoice:
	cp (0x7e25:16), 128
	jr c, AccompSeq_ResolveVRAMFallback
	bit 0, (0x7e6d:16)
	jr nz, AccompSeq_ResolveVRAMFallback
	ld wa, (ACCSEQ_BLOCK:16)
	and xwa, 0xfff
	sla xwa, 8
	ld xiy, xwa
	ld wa, (0x7e44:16)
	and xwa, 0xff
	add xiy, xwa
	add xiy, 0x1e8b00
	jr AccompSeq_ResolveVRAMDone

AccompSeq_ResolveVRAMFallback:
	ld wa, (ACCSEQ_BLOCK:16)
	ldfr_werp WA, 0xe2
	ld wa, (0x7e44:16)
	ld xiy, xwa

AccompSeq_ResolveVRAMDone:
	ret

; Out: XIY = 0x1e8b00 + (page & 0xfff) * 256 + (WA & 0xff), the page taken from QWA (upper word of
; XWA): an address in the MIDI sequence buffer pool.  Preserves XHL.
AccompSeq_BuildVRAMAddr:
	push xhl
	ld xhl, xwa
	ldto_werp WA, 0xe2
	and xwa, 0xfff
	sla xwa, 8
	ld xiy, xwa
	ld wa, hl
	and xwa, 0xff
	add xiy, xwa
	add xiy, 0x1e8b00
	pop xhl
	ret

; Out: WA = the link word at +3 of page (ACCSEQ_BLOCK) of the MIDI sequence buffer pool (the next page of
; the accompaniment sequence).
AccompSeq_ReadBeatHeader:
	ld wa, (ACCSEQ_BLOCK:16)
	and xwa, 0xfff
	sla xwa, 8
	add xwa, 0x3
	add xwa, 0x1e8b00
	ld wa, (xwa)
	ret

AccompSeq_ReadPatternTimeSig:
	ld	wa, (ACCSEQ_BLOCK:16)
	and	xwa, 4095
	sla	xwa, 8
	add	xwa, 1
	add	xwa, 0x1e8b00
	ld	wa, (xwa)
	ret

; End of the current channel's part (0x7e52 = 0 or 1).  With bit 3 of 0x7e27 set it restarts:
; position 0x7e42 / 0x7e44 = 0x7e34 / 0x7e36 (channel 0) or 0x7e38 / 0x7e3a (channel 1).
; Otherwise it clears the channel's bit (0 or 1) of 0x7e24 and sets bit 0 of 0x7e53; when both
; bits are then clear, sets bit 0 of 0x7e24 and AccompSeq_StopSequence.
AccompSeq_HandlePartTransition:
	bit 3, (0x7e27:16)
	jr z, AccompSeq_StopPart
	cp (0x7e52:16), 1
	jr z, AccompSeq_TransitionChannel2
	ld wa, (0x7e34:16)
	ld (ACCSEQ_BLOCK:16), wa
	ld wa, (0x7e36:16)
	ld (0x7e44:16), wa
	jr AccompSeq_PartTransitionDone

AccompSeq_TransitionChannel2:
	ld wa, (0x7e38:16)
	ld (ACCSEQ_BLOCK:16), wa
	ld wa, (0x7e3a:16)
	ld (0x7e44:16), wa

AccompSeq_PartTransitionDone:
	jr AccompSeq_DispatchReturn

AccompSeq_StopPart:
	cp (0x7e52:16), 1
	jr z, AccompSeq_StopPartCh2
	and (0x7e24:16), 254
	jr AccompSeq_CheckRestart

AccompSeq_StopPartCh2:
	and (0x7e24:16), 253

AccompSeq_CheckRestart:
	or (0x7e53:16), 1
	ld a, (0x7e24:16)
	and a, 0x3
	cp a, 0:i3
	jr nz, AccompSeq_DispatchReturn
	or (0x7e24:16), 1
	call AccompSeq_StopSequence

AccompSeq_DispatchReturn:
	ret

; Ticks from the current accompaniment-sequence position (beat 0x7e1c, tick 0x7e1e) to an event
; at tick A of beat (ACCSEQ_BEAT_COUNTER).
;   Out: A = the difference within the same beat (0 if already passed), tick + 96 - current tick
;   for the next beat, 0x60 for a later beat, 0 for an earlier beat.
AccompSeq_CalcDeltaTime:
	ld e, a
	ld wa, (ACCSEQ_BEAT_COUNTER:16)
	cp wa, (0x7e1c:16)
	jr nz, AccompSeq_DeltaCompare
	ld a, (0x7e1e:16)
	cp a, e
	jr ugt, AccompSeq_DeltaZero
	sub e, a
	ld a, e
	jr AccompSeq_DeltaReturn

AccompSeq_DeltaZero:
	xor a, a
	jr AccompSeq_DeltaReturn

AccompSeq_DeltaCompare:
	ld hl, (0x7e1c:16)
	cp hl, wa
	jr ugt, AccompSeq_DeltaFarBehind
	sub wa, hl
	cp wa, 1:i3
	jr z, AccompSeq_DeltaOneAhead
	ld a, 0x60:opc
	jr AccompSeq_DeltaReturn

AccompSeq_DeltaOneAhead:
	ld a, (0x7e1e:16)
	add e, 0x60
	sub e, a
	ld a, e
	jr AccompSeq_DeltaReturn

AccompSeq_DeltaFarBehind:
	xor a, a

AccompSeq_DeltaReturn:
	ret

AccompSeq_ParseEvents:
	cp a, 0:i3
	jr nz, AccompSeq_ParseLoop
	ld a, 0x1:opc

AccompSeq_ParseLoop:
	ld e, a
	calr ResolveVRAMAddressForVoice
	ld a, (xiy)
	cp a, 0x90
	jr z, AccompSeq_Parse_Type90
	cp a, 0x91
	jr z, AccompSeq_Parse_Type91
	cp a, 0xc0
	jr z, AccompSeq_Parse_TypeC0
	jr AccompSeq_Parse_Fallthrough

AccompSeq_Parse_Type91:
	jp AccompSeq_Parse_Type91_Impl

AccompSeq_Parse_TypeC0:
	jp AccompSeq_Parse_TypeC0_Impl

AccompSeq_Parse_Type90:
	calr AccompSeq_ReadParams
	calr AccompSeq_CalcEventSize
	cpw (0x7e50:16), 16
	jr ugt, AccompSeq_Parse_Type90_Large
	calr AccompSeq_ResetCounters
	jr AccompSeq_Parse_Done

AccompSeq_Parse_Type90_Large:
	ld xhl, (0x7e4c:16)
	ld iy, (xhl + 4)
	ld bc, (xhl + 2)
	calr AccompSeq_ProcessNoteOn6

AccompSeq_Parse_Done:
	jp AccompSeq_Ret

AccompSeq_Parse_Type91_Impl:
	calr AccompSeq_ReadParams
	ld (0x7e5a:16), a
	calr AccompSeq_AdvancePosition
	ld (0x7e5b:16), a
	calr AccompSeq_AdvancePosition
	calr AccompSeq_CalcEventSize
	cpw (0x7e50:16), 16
	jr ugt, AccompSeq_Parse_Type91_CalcSize
	calr AccompSeq_ResetCounters
	jr AccompSeq_Parse_Type91_Done

AccompSeq_Parse_Type91_CalcSize:
	ld xhl, (0x7e4c:16)
	ld iy, (xhl + 4)
	ld bc, (xhl + 2)
	calr AccompSeq_ProcessNoteOn8

AccompSeq_Parse_Type91_Done:
	jp AccompSeq_Ret

AccompSeq_Parse_Fallthrough:
	ld d, a
	and a, 0xf0
	ld (0x7e54:16), a
	calr AccompSeq_AdvancePosition
	ld (0x7e55:16), e
	calr AccompSeq_AdvancePosition
	ld a, d
	and a, 0xf
	ld (0x7e56:16), a
	ld a, (xiy)
	ld (0x7e57:16), a
	calr AccompSeq_AdvancePosition
	calr AccompSeq_CalcEventSize
	cpw (0x7e50:16), 16
	jr ugt, AccompSeq_Parse_TypeC0_CalcSize
	calr AccompSeq_ResetCounters
	jr AccompSeq_Parse_TypeC0_Done

AccompSeq_Parse_TypeC0_CalcSize:
	ld xhl, (0x7e4c:16)
	ld iy, (xhl + 4)
	ld bc, (xhl + 2)
	calr AccompSeq_ProcessNotePorta

AccompSeq_Parse_TypeC0_Done:
	jr AccompSeq_Ret

AccompSeq_Parse_TypeC0_Impl:
	calr AccompSeq_ReadParams
	calr AccompSeq_CalcEventSize
	cpw (0x7e50:16), 16
	jr ugt, AccompSeq_Parse_TypeC0_Finalize
	calr AccompSeq_ResetCounters
	jr AccompSeq_Parse_Return

AccompSeq_Parse_TypeC0_Finalize:
	ld xhl, (0x7e4c:16)
	ld iy, (xhl + 4)
	ld bc, (xhl + 2)
	calr AccompSeq_ProcessNoteOn5

AccompSeq_Parse_Return:
	jr AccompSeq_Ret

AccompSeq_Ret:
	ret

; Stores A in 0x7e54, then reads five more bytes of the accompaniment sequence into
; 0x7e55..0x7e59 (AccompSeq_AdvancePosition before each; the 0x7e55 store takes E).
AccompSeq_ReadParams:
	ld (0x7e54:16), a
	calr AccompSeq_AdvancePosition
	ld (0x7e55:16), e
	calr AccompSeq_AdvancePosition
	ld (0x7e56:16), a
	calr AccompSeq_AdvancePosition
	ld (0x7e57:16), a
	calr AccompSeq_AdvancePosition
	ld (0x7e58:16), a
	calr AccompSeq_AdvancePosition
	ld (0x7e59:16), a
	calr AccompSeq_AdvancePosition
	ret

; Stores in 0x7e50 the number of bytes waiting in the accompaniment-sequence ring buffer whose
; header is at (0x7e4c) (same rule as AccBuf_ComputeFillLevel).
AccompSeq_CalcEventSize:
	ld xhl, (0x7e4c:16)
	ld wa, (xhl + 6)
	cp wa, (xhl + 4)
	jr c, AccompSeq_CalcSize_Negative
	jr ugt, AccompSeq_CalcSize_Positive
	ld wa, (xhl + 2)
	sub wa, (xhl + 0:8)
	inc 1, wa
	jr AccompSeq_CalcSize_Store

AccompSeq_CalcSize_Negative:
	ld wa, (xhl + 2)
	sub wa, (xhl + 0:8)
	inc 1, wa
	sub wa, (xhl + 4)
	add wa, (xhl + 6)
	jr AccompSeq_CalcSize_Store

AccompSeq_CalcSize_Positive:
	sub wa, (xhl + 4)

AccompSeq_CalcSize_Store:
	ld (0x7e50:16), wa
	ret

; Resets the accompaniment-sequence ring buffer header at (0x7e4c): first 0x0a, last 0xff,
; read and write 0x0a, +8 = 0xf6.
AccompSeq_ResetCounters:
	ld xhl, (0x7e4c:16)
	ldw (xhl + 0:8), 0xa
	ldw (xhl + 2), 0xff
	ldw (xhl + 4), 0xa
	ldw (xhl + 6), 0xa
	ldw (xhl + 8), 0xf6
	ret

AccompSeq_InlineCodeBlock:
	inc	1, xiy
	ld	a, (xiy)
	cp	a, 135
	jr	nz, AccompSeq_InlineCodeBlock_Return
	xor	xhl, xhl
	ld	hl, (xhl+3)
	ld	(ACCSEQ_BLOCK:16), hl
	push	xhl
	calr	AccompSeq_VRAMHelperData
	pop	xhl
	ld	iy, 6:i3
AccompSeq_InlineCodeBlock_Return:
	ret

; Appends a record to the ring buffer XHL at IY (AccompSeq_AdvanceBufferPtr after each byte):
; status (0x7e54), timing byte (AccompSeq_ResolveChannel), (0x7e56) passed through
; AccompSeq_ConvertNote90, (0x7e57), (0x7e58) (0 written as 1), (0x7e59) and the unconverted
; (0x7e56); the write position goes to header +4.
AccompSeq_ProcessNoteOn6:
	ld a, (0x7e54:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	calr AccompSeq_ResolveChannel
	ld a, (0x7e56:16)
	ld e, a
	call AccompSeq_ConvertNote90
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e57:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e58:16)
	cp a, 0:i3
	jr nz, AccompSeq_NoteOn6_VelClamp
	ld a, 0x1:opc

AccompSeq_NoteOn6_VelClamp:
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e59:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld	(xhl+iy), e
	calr AccompSeq_AdvanceBufferPtr
	ld (xhl + 4), iy
	ret

; AccompSeq_ProcessNoteOn6 with AccompSeq_ConvertNote91, and (0x7e5a), (0x7e5b) written
; before the last byte.
AccompSeq_ProcessNoteOn8:
	ld a, (0x7e54:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	calr AccompSeq_ResolveChannel
	ld a, (0x7e56:16)
	ld e, a
	calr AccompSeq_ConvertNote91
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e57:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e58:16)
	cp a, 0:i3
	jr nz, AccompSeq_NoteOn8_VelClamp
	ld a, 0x1:opc

AccompSeq_NoteOn8_VelClamp:
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e59:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e5a:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e5b:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld	(xhl+iy), e
	calr AccompSeq_AdvanceBufferPtr
	ld (xhl + 4), iy
	ret

; Appends status (0x7e54), timing byte, (0x7e56) and (0x7e57) passed through AccompSeq_PortaFadeOut
; to the ring buffer XHL at IY (write position to header +4).  For status 0xd0 with (0x7e55) = 5,
; also stores (0x7e57) at the byte that (0x7e74) points to.
AccompSeq_ProcessNotePorta:
	ld a, (0x7e54:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	calr AccompSeq_ResolveChannel
	ld a, (0x7e56:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e57:16)
	calr AccompSeq_PortaFadeOut
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld (xhl + 4), iy
	ld a, (0x7e54:16)
	cp a, 0xd0
	jr nz, AccompSeq_NotePorta_Done
	ld a, (0x7e55:16)
	cp a, 5:i3
	jr nz, AccompSeq_NotePorta_Done
	ld a, (0x7e57:16)
	push xiy
	ld xiy, (0x7e74:16)
	ld (xiy), a
	pop xiy

AccompSeq_NotePorta_Done:
	ret

; Appends status (0x7e54), timing byte and (0x7e56) .. (0x7e59) to the ring buffer XHL at IY (write
; position to header +4).  For status 0xc0, also stores (0x7e56) & 0x7f, with bit 7 = bit 0 of
; (0x7e57), at the byte that (0x7e48) points to.
AccompSeq_ProcessNoteOn5:
	ld a, (0x7e54:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	calr AccompSeq_ResolveChannel
	ld a, (0x7e56:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e57:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e58:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld a, (0x7e59:16)
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld (xhl + 4), iy
	ld a, (0x7e54:16)
	cp a, 0xc0
	jr nz, AccompSeq_NoteOn5_Return
	ld a, (0x7e56:16)
	and a, 0x7f
	bit 0, (0x7e57:16)
	jr z, AccompSeq_NoteOn5_StoreProgram
	or a, 0x80

AccompSeq_NoteOn5_StoreProgram:
	push xiy
	ld xiy, (0x7e48:16)
	ld (xiy), a
	pop xiy

AccompSeq_NoteOn5_Return:
	ret

; Timing byte for an accompaniment-sequence record (as RhythmAccent_UpdateRingBufPosition, with
; 0x7e55 / 0x46b / 0x46d / 0x7dfc): (0x7e55) - (0x46b) + (0x46d) when positive, else 0x7e55 = 1
; and the byte is (0x46d) (1 when 0).  Written at IY, IY advanced, minimum kept in 0x7dfc.
AccompSeq_ResolveChannel:
	ld a, (0x7e55:16)
	ei 6
	sub a, (1131:16)
	jr ugt, AccompSeq_ResolveCh_Store
	ld a, 0x1:opc
	ld (0x7e55:16), a
	cp (1133:16), 0
	jr z, AccompSeq_ResolveCh_AddOffset
	xor a, a
	jr AccompSeq_ResolveCh_AddOffset

AccompSeq_ResolveCh_Store:
	ld (0x7e55:16), a

AccompSeq_ResolveCh_AddOffset:
	ld w, (1133:16)
	add a, w
	ld	(xhl+iy), a
	calr AccompSeq_AdvanceBufferPtr
	ld w, (0x7dfc:16)
	cp a, w
	jr nc, AccompSeq_ResolveCh_Done
	ld (0x7dfc:16), a

AccompSeq_ResolveCh_Done:
	ei 0
	ret

; Clears bits 1 and 2 of ACCSEQ_CONVERT_FLAGS, sets bit 2 (fixed note) when the note A is 0x78 or more
; or the channel's program byte at (0x7e48) is 0xf0 or more, then Rhythm_PhraseConvertNote_Tramp (XDE, XHL, XIY preserved).
AccompSeq_ConvertNote90:
	and (ACCSEQ_CONVERT_FLAGS:16), 253
	and (ACCSEQ_CONVERT_FLAGS:16), 251
	cp a, 0x78
	jr c, AccompSeq_ConvNote90_CheckProgram
	or (ACCSEQ_CONVERT_FLAGS:16), 4

AccompSeq_ConvNote90_CheckProgram:
	push xiy
	ld xiy, (0x7e48:16)
	ld w, (xiy)
	cp w, 0xf0
	jr c, AccompSeq_ConvNote90_CallDispatch
	or (ACCSEQ_CONVERT_FLAGS:16), 4

AccompSeq_ConvNote90_CallDispatch:
	pop xiy
	push xde
	push xhl
	push xiy
	call Rhythm_PhraseConvertNote_Tramp
	pop xiy
	pop xhl
	pop xde
	ret

; Sets bit 1 of ACCSEQ_CONVERT_FLAGS and copies the 0x91 note's rule bytes 0x7e5a / 0x7e5b to
; ACCSEQ_NOTE_EXT1 / _EXT2; bit 2 as in
; AccompSeq_ConvertNote90; then Rhythm_PhraseConvertNote_Tramp (XDE, XHL, XIY preserved).
AccompSeq_ConvertNote91:
	or (ACCSEQ_CONVERT_FLAGS:16), 2
	pushw wa
	ld a, (0x7e5a:16)
	ld (ACCSEQ_NOTE_EXT1:16), a
	ld a, (0x7e5b:16)
	ld (ACCSEQ_NOTE_EXT2:16), a
	popw wa
	and (ACCSEQ_CONVERT_FLAGS:16), 251
	cp a, 0x78
	jr c, AccompSeq_ConvNote91_CheckProg
	or (ACCSEQ_CONVERT_FLAGS:16), 4

AccompSeq_ConvNote91_CheckProg:
	push xiy
	ld xiy, (0x7e48:16)
	ld w, (xiy)
	cp w, 0xf0
	jr c, AccompSeq_ConvNote91_Dispatch
	or (ACCSEQ_CONVERT_FLAGS:16), 4

AccompSeq_ConvNote91_Dispatch:
	pop xiy
	push xde
	push xhl
	push xiy
	call Rhythm_PhraseConvertNote_Tramp
	pop xiy
	pop xhl
	pop xde
	ret

; Steps a circular-buffer index.
;   In:  IY = index, BC = last valid index, XHL = buffer header.
;   Out: IY + 1, or the restart index (the word at XHL+0) when that passes BC.
AccompSeq_AdvanceBufferPtr:
	inc 1, iy
	cp iy, bc
	jr ule, AccompSeq_AdvanceBuf_Return
	ld iy, (xhl + 0:8)

AccompSeq_AdvanceBuf_Return:
	ret

; While fading (bit 2 of 0x7e1f and bit 7 of 0x7e24): counts 0x7e70 down; past 0 it clears bit 7 of
; 0x7e24 and stops the sequence (AccompSeq_StopSequence), otherwise every 8th count
; AccompSeq_FadeOutApplyVol.
AccompSeq_FadeOutTick:
	bit 2, (0x7e1f:16)
	jr nz, AccompSeq_FadeOut_Active
	jr AccompSeq_FadeOut_Return

AccompSeq_FadeOut_Active:
	bit 7, (0x7e24:16)
	jr z, AccompSeq_FadeOut_Return
	ld wa, (0x7e70:16)
	dec 1, wa
	ld (0x7e70:16), wa
	cp wa, 0xffff
	jr nz, AccompSeq_FadeOut_Periodic
	and (0x7e24:16), 127
	call AccompSeq_StopSequence
	jr AccompSeq_FadeOut_Return

AccompSeq_FadeOut_Periodic:
	and wa, 0x7
	cp wa, 0:i3
	jr nz, AccompSeq_FadeOut_Return
	call AccompSeq_FadeOutApplyVol

AccompSeq_FadeOut_Return:
	ret

; For each active channel (bit 0 / bit 1 of 0x7e24) sends A = 0xd1 / 0xd2, W = 5, E = (0x7e72) /
; (0x7e73) * (0x7e70) / 0x800 (AccompSeq_SendMidiEvent).
AccompSeq_FadeOutApplyVol:
	bit 0, (0x7e24:16)
	jr z, AccompSeq_FadeOut_Ch2Volume
	ld l, (0x7e72:16)
	xor h, h
	ld wa, (0x7e70:16)
	mul xwa, hl
	ldto_werp DE, 0xe2
	ldw hl, 0x800
	ldfr_werp DE, 0xe2
	div xwa, hl
	ldto_werp DE, 0xe2
	ld e, a
	ld w, 0x5:opc
	ld a, 0xd1:opc
	call AccompSeq_SendMidiEvent

AccompSeq_FadeOut_Ch2Volume:
	bit 1, (0x7e24:16)
	jr z, AccompSeq_FadeOut_ChReturn
	ld l, (0x7e73:16)
	xor h, h
	ld wa, (0x7e70:16)
	mul xwa, hl
	ldto_werp DE, 0xe2
	ldw hl, 0x800
	ldfr_werp DE, 0xe2
	div xwa, hl
	ldto_werp DE, 0xe2
	ld e, a
	ld w, 0x5:opc
	ld a, 0xd2:opc
	call AccompSeq_SendMidiEvent

AccompSeq_FadeOut_ChReturn:
	ret

AccompSeq_PortaFadeOut:
	bit 7, (0x7e24:16)
	jr z, AccompSeq_PortaFade_Return
	ld w, (0x7e54:16)
	cp w, 0xd0
	jr nz, AccompSeq_PortaFade_Return
	ld w, (0x7e55:16)
	cp w, 5:i3
	jr nz, AccompSeq_PortaFade_Return
	push xhl
	push xde
	ld l, (0x7e57:16)
	xor h, h
	ld wa, (0x7e70:16)
	mul xwa, hl
	ldto_werp DE, 0xe2
	ldw hl, 0x800
	ldfr_werp DE, 0xe2
	div xwa, hl
	ldto_werp DE, 0xe2
	pop xde
	pop xhl

AccompSeq_PortaFade_Return:
	ret

AccompSeq_ManualMidiMode1:
	or (0x7f15:16), 2
	jr AccompSeq_ManualMidi_CheckAllNotes

AccompSeq_ManualMidiMode2:
	or (0x7f15:16), 8

AccompSeq_ManualMidi_CheckAllNotes:
	cp l, 0x7f
	jr nz, AccompSeq_ManualMidi_SaveAndCall
	cp h, 3:i3
	jr nz, AccompSeq_ManualMidi_SaveAndCall
	call AccompSeq_AllNotesOff
	jr AccompSeq_ManualMidi_ClearFlags

AccompSeq_ManualMidi_SaveAndCall:
	ld a, (SWBTWR_PAYLOAD_2:16)
	push xwa
	push xhl
	call Voice_DecodeNoteParam
	call Voice_DecodeNoteChannel
	ld (SWBTWR_PAYLOAD_2:16), 1
	cp h, 0:i3
	jr z, AccompSeq_ManualMidi_SetChannel
	ld (SWBTWR_PAYLOAD_2:16), 2
	cp h, 1:i3
	jr z, AccompSeq_ManualMidi_SetChannel
	ld (SWBTWR_PAYLOAD_2:16), 4

AccompSeq_ManualMidi_SetChannel:
	pop xhl
	call AccompSeq_ProcessAfterNote
	pop xwa
	ld (SWBTWR_PAYLOAD_2:16), a

AccompSeq_ManualMidi_ClearFlags:
	and (0x7f15:16), 253
	and (0x7f15:16), 247
	ret

AccompSeq_LargeCodeBlock1:
	ld	(xhl), e
	ld	(xhl+1), d
	ld	a, (0x7e56:16)
	ld	(xhl+2), a
	ld	a, (0x7e57:16)
	ld	(xhl+3), a
	ld	a, (0x7e58:16)
	ld	(xhl+4), a
	calr	AccompSeq_PortaFadeOut_Helper
	ret
; When bit 7 of E is set: sets bit 4 of D and clears bit 7 of E.  Unreferenced code follows (two
; AccompSeq_PortaFadeOut_Helper_Helper calls with A = 0x9f and 0xdf).
AccompSeq_PortaFadeOut_Helper:
	bit	7, e
	jr	z, AccompSeq_PortaFadeOut_Return
	or	d, 16
	and	e, 127
AccompSeq_PortaFadeOut_Return:
	ret
	ld	a, 159:opc
	ld	w, 127:opc
	ld	e, 127:opc
	calr	AccompSeq_PortaFadeOut_Helper_Helper
	ret
	ld	a, 223:opc
	ld	w, 127:opc
	ld	e, 127:opc
	calr	AccompSeq_PortaFadeOut_Helper_Helper
	ret
AccompSeq_PortaFadeOut_Helper_Helper:
	pushw	iy
	ld	xhl, 0x7aec
	ei	6
	ld	iy, (xhl+4)
	ld	bc, (xhl+2)
	ld	(xiy+hl), e
	calr	AccompSeq_AdvanceBufferPtr
	ld	(xiy+hl), d
	calr	AccompSeq_AdvanceBufferPtr
	ld	(xiy+hl), a
	calr	AccompSeq_AdvanceBufferPtr
	ld	(xhl+4), iy
	ei	0
	popw	iy
	ret
	ld	wa, 0:i3
	ld	(1128:16), wa
	ld	(1130:16), a
	ld	(0x7e1c:16), wa
	ld	(0x7e1e:16), a
	ret
	ld	a, (0x7e62:16)
	ld	w, (ACC_BAR_COUNT:16)
	ld	(0x7e62:16), w
	cp	a, w
	jr	z, AccompSeq_PortaFadeOut_Return2
	bit	0, (0x7e5f:16)
	jr	z, AccompSeq_PortaFadeOut_Return2
	and	(0x7e5f:16), 254
	ld	l, (0x7e60:16)
	ld	h, (0x7e61:16)
	ld	a, (0x7e24:16)
	and	a, (P0FC:8)
	cp	a, 0:i3
	jr	nz, AccompSeq_PortaFadeOut_Helper_Skip
	call	AccompSeq_InitPartFull
	jr	AccompSeq_PortaFadeOut_Join
AccompSeq_PortaFadeOut_Helper_Skip:
	call	AccompSeq_ReinitPart
AccompSeq_PortaFadeOut_Join:
	ei	6
	ld	c, (ACC_CLOCK:16)
	ld	(1130:16), c
	ld	(1138:16), c
	ld	wa, 0:i3
	ld	a, (ACC_BEAT:16)
	ld	(1128:16), wa
	ei	0
AccompSeq_PortaFadeOut_Return2:
	ret

; Loads the channel's start position (0x7e52 = 0: the long at 0x7e65, else at 0x7e69): 0x7e44 =
; low word, 0x7e42 = high word; clears bit 0 of 0x7e6d.
AccompSeq_UpdatePosition:
	cp (0x7e52:16), 0
	jr nz, AccompSeq_UpdatePos_Part2
	ld xwa, (0x7e65:16)
	and (0x7e6d:16), 254
	jr AccompSeq_UpdatePos_Store

AccompSeq_UpdatePos_Part2:
	ld xwa, (0x7e69:16)
	and (0x7e6d:16), 254

AccompSeq_UpdatePos_Store:
	ld (0x7e44:16), wa
	ldto_werp WA, 0xe2
	ld (ACCSEQ_BLOCK:16), wa
	ret

AccompSeq_JumpTable:
	jp	AccompSeq_LargeCodeBlock2_Join
	jp	AccompSeq_ProcessAfterNote_Helper
SwbtB3_CodeA9_Listener1:
	jp	AccompSeq_GuardedNoteOff

; Stops the accompaniment sequence: AccompSeq_CleanupSequence with XIZ preserved.  Called on
; play halt, mode switches, demo start and sequencer stop.
AccompSeq_StopSequence:
	push xiz
	call AccompSeq_CleanupSequence
	pop xiz
	ret

; Alias entry: jumps to AccompSeq_WriteMidiToBuffer (A = status, W and E = data bytes).
AccompSeq_SendMidiEvent:
	jp AccompSeq_WriteMidiToBuffer

; Jumps to AccompSeq_AllNotesOffImpl.
; Called from AccompSeq_ManualMidi_CheckAllNotes.
AccompSeq_AllNotesOff:
	jp AccompSeq_AllNotesOffImpl

; Jumps to AccompSeq_PostNoteProcess.
; Called from AccompSeq_ManualMidi_SetChannel.
AccompSeq_ProcessAfterNote:
	jp AccompSeq_PostNoteProcess
AccompSeq_LargeCodeBlock2:
	jp	AccompSeq_ClearPendingFlag
AccompSeq_LargeCodeBlock2_Join:
	ld	a, (SWBTWR_PAYLOAD_1:16)
	cp	a, 9
	jrl	nz, AccompSeq_LargeCodeBlock2_Return
	ld	a, (SWBTWR_PAYLOAD_3:16)
	bit	7, a
	jr	z, AccompSeq_LargeCodeBlock2_Skip2
	calr	AccompSeq_ProcessAfterNote_Helper
	ld	l, 127:opc
	ld	h, 3:opc
	ld	a, (SWBTWR_PAYLOAD_2:16)
	bit	7, a
	jr	z, AccompSeq_LargeCodeBlock2_Skip
	calr	AccompSeq_OutputEvent
AccompSeq_LargeCodeBlock2_Skip:
	jrl	AccompSeq_LargeCodeBlock2_Return
AccompSeq_LargeCodeBlock2_Skip2:
	and	a, 63
	cp	a, 0:i3
	jr	z, AccompSeq_LargeCodeBlock2_Return
	ld	a, (SWBTWR_PAYLOAD_2:16)
	and	a, (SWBTWR_PAYLOAD_3:16)
	and	a, 63
	cp	a, 0:i3
	jr	z, AccompSeq_LargeCodeBlock2_Return
	xor	w, w
	ld	hl, wa
	ld	xix, AccompSeq_LowestBitIndex
	ld	h, (xix+hl)
	ld l, (PANEL_MSP+6:16)
	cp l, 17
	jr	z, AccompSeq_LargeCodeBlock2_Return
	cp	l, 18
	jr	z, AccompSeq_LargeCodeBlock2_Return
	cp	l, 15
	jr	z, AccompSeq_LargeCodeBlock2_Skip3
	cp	l, 16
	jr	nz, AccompSeq_LargeCodeBlock2_Skip5
AccompSeq_LargeCodeBlock2_Skip3:
	ld	xix, 0x1e8a00
	cp	l, 16
	jr	nz, AccompSeq_LargeCodeBlock2_Skip4
	add	xix, 16
AccompSeq_LargeCodeBlock2_Skip4:
	sll	h, 1
	ld	l, (xix+h)
	inc 1, h
	ld	h, (xix+h)
	cp l, 14
	jr	ugt, AccompSeq_LargeCodeBlock2_Return
AccompSeq_LargeCodeBlock2_Skip5:
	call	Voice_NoteChannelGrid_Lookup
	cp	h, 0:i3
	jr	z, AccompSeq_LargeCodeBlock2_Return
	cp	(0x7f0b:16), 0
	jr	nz, AccompSeq_LargeCodeBlock2_Return
	bit	0, (0x7e7a:16)
	jr	z, AccompSeq_LargeCodeBlock2_Skip6
	calr	AccompSeq_HandleSpecialMode
	jr	AccompSeq_LargeCodeBlock2_Return
AccompSeq_LargeCodeBlock2_Skip6:
	calr	AccompSeq_OutputEvent
	call	AccompSeq_ProcessChordChange
AccompSeq_LargeCodeBlock2_Return:
	ret

AccompSeq_PostNoteProcess:
	cp h, 0:i3
	jr z, AccompSeq_PostNote_Return
	cp (0x7f0b:16), 0
	jr nz, AccompSeq_PostNote_Return
	calr AccompSeq_OutputEvent
	call AccompSeq_ProcessChordChange

AccompSeq_PostNote_Return:
	ret

; Starts an accompaniment-sequence voice: AccompSeq_ResetMidiState, stores the voice (L, H) in
; 0x7e25 / 0x7e26, looks up its style data (AccompSeq_LookupStyleData) and runs
; AccompSeq_LoadParams, AccompSeq_InitMidiEvents and AccompSeq_InitPlayState.
AccompSeq_InitPartFull:
	calr AccompSeq_ResetMidiState
	ld (0x7e25:16), l
	ld (0x7e26:16), h
	calr AccompSeq_LookupStyleData
	calr AccompSeq_LoadParams
	calr AccompSeq_InitMidiEvents
	calr AccompSeq_InitPlayState
	ret

; Calls Voice_DecodeNoteParam.
; Called from AccompSeq_InitPartFull, AccompSeq_ReinitPart, AccompSeq_HandleSpecialMode_Skip2 and
; AccompSeq_CompareChord.
AccompSeq_ResetMidiState:
	call Voice_DecodeNoteParam
	ret

; Resolves the address of a voice's style data into 0x7e2a (low word) / 0x7e28 (high word,
; from QWA (upper word of XWA, code 0xe2)): voices 0x80 and up from Voice_DecodeBankIndex(L & 15)
; + MSP_SETTINGS__BASE_ADDR, the others from AccompSeq_StyleDataTable + 32 *
; Voice_DecodeNoteChannel2().
AccompSeq_LookupStyleData:
	cp l, 0x80
	jr c, AccompSeq_LookupStyle_Internal
	and l, 0xf
	call Voice_DecodeBankIndex
	and xhl, 0xffff
	ld xwa, xhl
	add xwa, 0x1e8800
	ld (0x7e2a:16), wa
	ldto_werp WA, 0xe2
	ld (0x7e28:16), wa
	jr AccompSeq_LookupStyle_Return

AccompSeq_LookupStyle_Internal:
	call Voice_DecodeNoteChannel2
	xor xwa, xwa
	ldw wa, 0x20
	mul xwa, hl
	add xwa, AccompSeq_StyleDataTable
	ld (0x7e2a:16), wa
	ldto_werp WA, 0xe2
	ld (0x7e28:16), wa

AccompSeq_LookupStyle_Return:
	ret

AccompSeq_LoadParams:
	ld wa, (0x7e28:16)
	ldfr_werp WA, 0xe2
	ld wa, (0x7e2a:16)
	ld xiy, xwa
	cp (0x7e25:16), 128
	jr nc, AccompSeq_LoadParams_Alt
	ld a, (xiy + 0:8)
	and a, 0x1d
	ld (0x7e27:16), a
	ld xwa, (xiy + 1)
	add xwa, 0x6
	ld (0x7e2e:16), wa
	ldto_werp WA, 0xe2
	ld (0x7e2c:16), wa
	ld xwa, (xiy + 5)
	ld (0x7e36:16), wa
	ldto_werp WA, 0xe2
	ld (0x7e34:16), wa
	ld a, (xiy + 16)
	bit 0, a
	jr z, AccompSeq_LoadParams_Bit0Set
	or (0x7e27:16), 2

AccompSeq_LoadParams_Bit0Set:
	ld xwa, (xiy + 17)
	add xwa, 0x6
	ld (0x7e32:16), wa
	ldto_werp WA, 0xe2
	ld (0x7e30:16), wa
	ld xwa, (xiy + 21)
	ld (0x7e3a:16), wa
	ldto_werp WA, 0xe2
	ld (0x7e38:16), wa
	jr AccompSeq_LoadParams_OverrideCheck

AccompSeq_LoadParams_Alt:
	ld a, (xiy + 0:8)
	and a, 0x1d
	ld (0x7e27:16), a
	ld wa, (xiy + 3)
	ld (0x7e2c:16), wa
	ld wa, 6:i3
	ld (0x7e2e:16), wa

AccompSeq_LoadParams_OverrideCheck:
	bit 0, (0x7e5f:16)
	jr z, AccompSeq_LoadParams_Return
	ld wa, (0x7e2c:16)
	ldfr_werp WA, 0xe2
	ld wa, (0x7e2e:16)
	ld (0x7e65:16), xwa
	ld wa, (0x7e30:16)
	ldfr_werp WA, 0xe2
	ld wa, (0x7e32:16)
	ld (0x7e69:16), xwa
	ld wa, 0:i3
	ld a, (ACC_BEATS_PER_BAR:16)
	dec 1, a
	and a, 0x7
	sll wa, 2
	ld xiy, AccompSeq_TempoScaleTable
	ld	xwa, (xiy+wa)
	add xwa, 0x6
	ld (0x7e2e:16), wa
	ld (0x7e32:16), wa
	ldto_werp WA, 0xe2
	ld (0x7e2c:16), wa
	ld (0x7e30:16), wa

AccompSeq_LoadParams_Return:
	ret

AccompSeq_InitMidiEvents:
	ld a, 0xd0:opc
	ld w, 0x3:opc
	ld e, 0x0:opc
	calr AccompSeq_WriteMidiToBuffer
	ld (0x7e72:16), 127
	ld (0x7e73:16), 127
	ld wa, (0x7e28:16)
	ldfr_werp WA, 0xe2
	ld wa, (0x7e2a:16)
	ld xiy, xwa
	bit 0, (0x7e27:16)
	jr z, AccompSeq_InitMidi_Ch2
	ld wa, (xiy + 9)
	ld e, w
	ld w, a
	ld a, 0xc1:opc
	ld (0x7e40:16), w
	and e, 0xf
	bit 7, w
	jr z, AccompSeq_InitMidi_Ch1Flags
	or e, 0x10
	and w, 0x7f

AccompSeq_InitMidi_Ch1Flags:
	calr AccompSeq_WriteMidiToBuffer
	ld a, (xiy + 12)
	ld e, a
	ld w, 0x4:opc
	ld a, 0xd1:opc
	calr AccompSeq_WriteMidiToBuffer
	ld a, (xiy + 13)
	ld e, 0x0:opc
	bit 0, a
	jr z, AccompSeq_InitMidi_Ch1Reverb
	ld e, 0x7f:opc

AccompSeq_InitMidi_Ch1Reverb:
	ld w, 0x7:opc
	ld a, 0xd1:opc
	calr AccompSeq_WriteMidiToBuffer
	ld a, (xiy + 14)
	ld e, 0x0:opc
	bit 0, a
	jr z, AccompSeq_InitMidi_Ch1Chorus
	ld e, 0x7f:opc

AccompSeq_InitMidi_Ch1Chorus:
	ld w, 0x3:opc
	ld a, 0xd1:opc
	calr AccompSeq_WriteMidiToBuffer

AccompSeq_InitMidi_Ch2:
	bit 1, (0x7e27:16)
	jr z, AccompSeq_InitMidi_Return
	ld wa, (xiy + 25)
	ld e, w
	ld w, a
	ld a, 0xc2:opc
	ld (0x7e41:16), w
	and e, 0xf
	bit 7, w
	jr z, AccompSeq_InitMidi_Ch2Flags
	or e, 0x10
	and w, 0x7f

AccompSeq_InitMidi_Ch2Flags:
	calr AccompSeq_WriteMidiToBuffer
	ld a, (xiy + 28)
	ld e, a
	ld w, 0x4:opc
	ld a, 0xd2:opc
	calr AccompSeq_WriteMidiToBuffer
	ld a, (xiy + 29)
	ld e, 0x0:opc
	bit 0, a
	jr z, AccompSeq_InitMidi_Ch2Reverb
	ld e, 0x7f:opc

AccompSeq_InitMidi_Ch2Reverb:
	ld w, 0x7:opc
	ld a, 0xd2:opc
	calr AccompSeq_WriteMidiToBuffer
	ld a, (xiy + 30)
	ld e, 0x0:opc
	bit 0, a
	jr z, AccompSeq_InitMidi_Ch2Chorus
	ld e, 0x7f:opc

AccompSeq_InitMidi_Ch2Chorus:
	ld w, 0x3:opc
	ld a, 0xd2:opc
	calr AccompSeq_WriteMidiToBuffer

AccompSeq_InitMidi_Return:
	ret

; Resets the accompaniment-sequence counters (0x468, 0x46a, 0x472, 0x7e3c, 0x7e3e), sets bit 0 of
; 0x41f unless bit 2 is set, copies bits 0..1 of 0x7e27 into 0x7e24 (bit 7 cleared), and returns A
; = 1, 2 or 4 for the first of bits 0, 1 set in SWBTWR_PAYLOAD_2 (4 when neither).
AccompSeq_InitPlayState:
	and (0x7e24:16), 127
	xor wa, wa
	ei 6
	ld (1128:16), wa
	ld (1130:16), a
	ld (1138:16), a
	bit 2, (1055:16)
	jr nz, AccompSeq_InitPlay_SetCounters
	or (1055:16), 1

AccompSeq_InitPlay_SetCounters:
	ei 0
	ld (0x7e3c:16), wa
	ld (0x7e3e:16), wa
	ld a, (0x7e24:16)
	ld w, (0x7e27:16)
	bit 0, w
	jr z, AccompSeq_InitPlay_Ch2Flag
	or a, 0x1

AccompSeq_InitPlay_Ch2Flag:
	bit 1, w
	jr z, AccompSeq_InitPlay_Store
	or a, 0x2

AccompSeq_InitPlay_Store:
	ld (0x7e24:16), a
	ld w, (SWBTWR_PAYLOAD_2:16)
	ld a, 0x1:opc
	bit 0, w
	jr nz, AccompSeq_InitPlay_Return
	ld a, 0x2:opc
	bit 1, w
	jr nz, AccompSeq_InitPlay_Return
	ld a, 0x4:opc

AccompSeq_InitPlay_Return:
	ret

; Restarts an accompaniment-sequence voice: clears bits 0..1 of 0x7e24, silences it
; (AccompSeq_SendAllOff) and then does what AccompSeq_InitPartFull does for the voice in HL.
AccompSeq_ReinitPart:
	pushw hl
	ld a, (0x7e24:16)
	and a, 0xfc
	ld (0x7e24:16), a
	calr AccompSeq_SendAllOff
	popw hl
	calr AccompSeq_ResetMidiState
	ld (0x7e25:16), l
	ld (0x7e26:16), h
	calr AccompSeq_LookupStyleData
	calr AccompSeq_LoadParams
	calr AccompSeq_InitMidiEvents
	calr AccompSeq_InitPlayState
	ret

; With channel bits 0-1 of 0x7e24 set, clears them and silences the sequence (AccompSeq_SendAllOff,
; HL preserved).  When 0xfd12 is 13 or 14: 0x7f0b = 1, 0x7f14 = low nibble of
; AccompSeq_ResetMidiState's L, and A = 1, 2 or 4 for bit 0, bit 1 or neither of
; SWBTWR_PAYLOAD_2.  Otherwise GLOBAL_ERROR_CODE = 57, DrumVoice_NotifyEE and MIDI_SendSysExCmd with
; A = 8.
AccompSeq_HandleSpecialMode:
	ld	a, (0x7e24:16)
	and	a, 3
	jr	z, AccompSeq_HandleSpecialMode_Skip
	pushw	hl
	ld	a, (0x7e24:16)
	and	a, 252
	ld	(0x7e24:16), a
	calr	AccompSeq_SendAllOff
	popw	hl
AccompSeq_HandleSpecialMode_Skip:
	ld	a, (PANEL_MSP+6:16)
	cp	a, 13
	jr	z, AccompSeq_HandleSpecialMode_Skip2
	cp	a, 14
	jr	nz, AccompSeq_HandleSpecialMode_Skip4
AccompSeq_HandleSpecialMode_Skip2:
	ld	(0x7f0b:16), 1
	calr	AccompSeq_ResetMidiState
	and	l, 15
	ld	(0x7f14:16), l
	ld	w, (SWBTWR_PAYLOAD_2:16)
	ld	a, 1:opc
	bit	0, w
	jr	nz, AccompSeq_HandleSpecialMode_Skip3
	ld	a, 2:opc
	bit	1, w
	jr	nz, AccompSeq_HandleSpecialMode_Skip3
	ld	a, 4:opc
AccompSeq_HandleSpecialMode_Skip3:
	jr	AccompSeq_HandleSpecialMode_Return
AccompSeq_HandleSpecialMode_Skip4:
	ld	(GLOBAL_ERROR_CODE:16), 57
	call	DrumVoice_NotifyEE
	ld	a, 8:opc
	call	MIDI_SendSysExCmd
AccompSeq_HandleSpecialMode_Return:
	ret

; Sends a controller pair for the voice in HL (Voice_DecodeNoteChannel).  When the sequencer is
; running (SEQ_RECORDING_TRACKS) or title 138 is showing with 0xd65 = 2, and bit 3 of 0x7f15 is clear,
; Tempo_ProcessExpressionChange sees it first; MidiPkt_SendControlPair sends it unless bit 1 of
; 0x7f15 is set.  Preserves HL.
AccompSeq_OutputEvent:
	pushw hl
	pushw hl
	call Voice_DecodeNoteChannel
	ld bc, hl
	popw hl
	ld wa, hl
	ld hl, bc
	cpw (SEQ_RECORDING_TRACKS:16), 0
	jr nz, AccompSeq_Output_CheckFilter
	cp (CURRENT_TITLE:16), 138
	jr nz, AccompSeq_Output_CheckManual
	cp (SQSTEP_DISPLAY_MODE:16), 2
	jr nz, AccompSeq_Output_CheckManual

AccompSeq_Output_CheckFilter:
	bit 3, (0x7f15:16)
	jr nz, AccompSeq_Output_CheckManual
	pushw wa
	pushw hl
	call Tempo_ProcessExpressionChange
	popw hl
	popw wa

AccompSeq_Output_CheckManual:
	bit 1, (0x7f15:16)
	jr nz, AccompSeq_Output_Return
	call MidiPkt_SendControlPair

AccompSeq_Output_Return:
	popw hl
	ret

; Writes a three-byte MIDI message to the sequencer event buffer, byte by byte
; (SeqEvtBuf_WriteByte, a compiled-C routine taking its argument on the stack).
;   In:  A = status, W = first data byte, E = second data byte.  Preserves WA and XIY.
AccompSeq_WriteMidiToBuffer:
	pushw wa
	push xiy
	pushw wa
	pushw wa
	call SeqEvtBuf_WriteByte
	inc 2, xsp
	popw wa
	ld a, w
	pushw wa
	call SeqEvtBuf_WriteByte
	inc 2, xsp
	ld a, e
	pushw wa
	call SeqEvtBuf_WriteByte
	inc 2, xsp
	pop xiy
	popw wa
	ret

AccompSeq_WriteMidi_CodeBlock:
	inc	1, iy
	cp	iy, bc
	jr	ule, AccompSeq_WriteMidi_CodeBlock_Return
	ld iy, (xhl+0:8)
AccompSeq_WriteMidi_CodeBlock_Return:
	ret
AccompSeq_ProcessAfterNote_Helper:
	ld	a, (SWBTWR_PAYLOAD_2:16)
	bit	7, a
	jr	nz, AccompSeq_ProcessAfterNote_Helper_Skip2
	and	(0x7e7a:16), 254
	jr	AccompSeq_ProcessAfterNote_Helper_Return
AccompSeq_ProcessAfterNote_Helper_Skip2:
	or	(0x7e7a:16), 1
	ld	a, (0x7f0b:16)
	cp	a, 0:i3
	jr	z, AccompSeq_ProcessAfterNote_Helper_Skip3
	ld	a, 0:opc
	ld	(0x7f0b:16), a
	jr	AccompSeq_ProcessAfterNote_Helper_Return
AccompSeq_ProcessAfterNote_Helper_Skip3:
	ld	a, (0x7e24:16)
	and	a, 3
	cp	a, 0:i3
	jr	z, AccompSeq_ProcessAfterNote_Helper_Return
	bit	2, (0x7e27:16)
	jr	z, AccompSeq_ProcessAfterNote_Helper_Skip
	bit	7, (0x7e24:16)
	jr	nz, AccompSeq_ProcessAfterNote_Helper_Skip
	ldw	(0x7e70:16), 2048
	or	(0x7e24:16), 128
	jr	AccompSeq_ProcessAfterNote_Helper_Return
AccompSeq_ProcessAfterNote_Helper_Skip:
	calr	AccompSeq_CleanupSequence
AccompSeq_ProcessAfterNote_Helper_Return:
	ret

AccompSeq_AllNotesOffImpl:
	ld a, (0x7e24:16)
	and a, 0x3
	cp a, 0:i3
	jr z, AccompSeq_AllNotesOff_Send
	bit 2, (0x7e27:16)
	jr z, AccompSeq_AllNotesOff_Stop
	bit 7, (0x7e24:16)
	jr nz, AccompSeq_AllNotesOff_Stop
	ldw (0x7e70:16), 2048
	or (0x7e24:16), 128
	jr AccompSeq_AllNotesOff_Send

AccompSeq_AllNotesOff_Stop:
	calr AccompSeq_CleanupSequence

AccompSeq_AllNotesOff_Send:
	ld l, 0x7f:opc
	ld h, 0x3:opc
	calr AccompSeq_OutputEvent
	ret

AccompSeq_ClearPendingFlag:
	; --- Routine 1: clear flag at (0x7f0b) if nonzero (15 bytes) ---
	ld	a, (0x7f0b:16)
	cp	a, 0:i3
	jr z, AccompSeq_ClearPending_Return
	ld a, 0x00:opc
	ld	(0x7f0b:16), a
AccompSeq_ClearPending_Return:
	ret
AccompSeq_GuardedNoteOff:
	; --- Routine 2: multi-guard, all-register push, call F99490 (61 bytes) ---
	ld	a, (SWBTWR_PAYLOAD_1:16)
	cp a, 0x1c
	jr nz, AccompSeq_GuardedNote_Return
	ld	a, (SWBTWR_PAYLOAD_2:16)
	and	a, (SWBTWR_PAYLOAD_3:16)
	and a, 0x03
	cp	a, 0:i3
	jr z, AccompSeq_GuardedNote_Return
	cp	(CURRENT_MODE:16), 19
	jr z, AccompSeq_GuardedNote_Return
	cp	(ACTIVE_TITLE:16), 200
	jr z, AccompSeq_GuardedNote_Return
	push xwa
	push xhl
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	xor wa, wa
	ld a, TT_MSPBKSL:opc
	call UI_ChangeTitleByIndex
	pop xiz
	pop xiy
	pop xix
	pop xde
	pop xbc
	pop xhl
	pop xwa
AccompSeq_GuardedNote_Return:
	ret


; Stops a running accompaniment sequence: when bits 0..1 of 0x7e24 are set, clears them and bit
; 7, sets bit 3 of 0x41f and sends all-notes-off (AccompSeq_SendAllOff).  Always clears bit 0 of
; 0x7e6e and 0x7e6f.
AccompSeq_CleanupSequence:
	ld a, (0x7e24:16)
	and a, 0x3
	cp a, 0:i3
	jr z, AccompSeq_Cleanup_ClearFlags
	and (0x7e24:16), 127
	or (1055:16), 8
	ld a, (0x7e24:16)
	and a, 0xfc
	ld (0x7e24:16), a
	calr AccompSeq_SendAllOff

AccompSeq_Cleanup_ClearFlags:
	and (0x7e6e:16), 254
	and (0x7e6f:16), 254
	ret

; Silences the accompaniment sequence: sends 0x90 0x7f 0x7f and 0xd0 0x03 0x00
; (AccompSeq_WriteMidiToBuffer), sets 0x7e72 / 0x7e73 = 127, empties the ring buffers at 0x7aec
; and 0x7bec (read index = write index, +8 = 0xf6) and clears byte 0 of the eight 9-byte slots
; at 0x7d6c and at 0x7db4.
AccompSeq_SendAllOff:
	ld a, 0x90:opc
	ld w, 0x7f:opc
	ld e, 0x7f:opc
	calr AccompSeq_WriteMidiToBuffer
	ld a, 0xd0:opc
	ld w, 0x3:opc
	ld e, 0x0:opc
	calr AccompSeq_WriteMidiToBuffer
	ld (0x7e72:16), 127
	ld (0x7e73:16), 127
	ld xhl, 0x7aec
	ld wa, (xhl + 4)
	ld (xhl + 6), wa
	ldw wa, 0xf6
	ld (xhl + 8), wa
	ld xhl, 0x7bec
	ld wa, (xhl + 4)
	ld (xhl + 6), wa
	ldw wa, 0xf6
	ld (xhl + 8), wa
	ld a, 0x8:opc
	xor w, w
	ld xhl, 0x7d6c

AccompSeq_SendAllOff_Loop1:
	ld (xhl), w
	add hl, 0x9
	dec 1, a
	cp a, 0:i3
	jr nz, AccompSeq_SendAllOff_Loop1
	ld a, 0x8:opc
	xor w, w
	ld xhl, 0x7db4

AccompSeq_SendAllOff_Loop2:
	ld (xhl), w
	add hl, 0x9
	dec 1, a
	cp a, 0:i3
	jr nz, AccompSeq_SendAllOff_Loop2
	ret

AccompSeq_MidiFilterCodeBlock:
	or	(0xe3e2:16), 8
	ret
	ret
	; No reference found.  Unless (0x7F0B) is set, steps (0xFD12) within 0..12 (bit 7 of W = down).
AccompSeq_MidiFilterCodeBlock_Step:
	cp	(0x7f0b:16), 0
	jr	z, AccompSeq_MidiFilterCodeBlock_Step_Skip
	jp	AccompSeq_MidiFilterCodeBlock_Step2_Store_Return
AccompSeq_MidiFilterCodeBlock_Step_Skip:
	ld	e, 12:opc
	ld	a, (PANEL_MSP+6:16)
	bit	7, w
	jr	z, AccompSeq_MidiFilterCodeBlock_Step_Skip3
	inc	1, a
	cp	a, e
	jr	ule, AccompSeq_MidiFilterCodeBlock_Step_Skip2
	ld	a, e
AccompSeq_MidiFilterCodeBlock_Step_Skip2:
	jr	AccompSeq_MidiFilterCodeBlock_Step_Join
AccompSeq_MidiFilterCodeBlock_Step_Skip3:
	dec	1, a
	cp	a, 255
	jr	nz, AccompSeq_MidiFilterCodeBlock_Step_Join
	ld	a, 0:opc
AccompSeq_MidiFilterCodeBlock_Step_Join:
	ld	(PANEL_MSP+6:16), a
	ld	(0x7e78:16), 0
	or	(0xe3e0:16), 16
	jr	AccompSeq_MidiFilterCodeBlock_Step2_Store_Return
	; No reference found.  Was `.byte 0xc1 / jrl 16254 / nop`: `cp (0x7e78:16), 0`.
AccompSeq_MidiFilterCodeBlock_Step2:
	cp	(0x7e78:16), 0
	jr	nz, AccompSeq_MidiFilterCodeBlock_Step2_Skip
	ld	(0x7e79:16), a
	ld	(0x7e78:16), 1
	or	(0xe3de:16), 16
	jr	AccompSeq_MidiFilterCodeBlock_Step2_Store_Return
AccompSeq_MidiFilterCodeBlock_Step2_Skip:
	ld	a, (0x7e79:16)
	ld	w, 10:opc
	add	a, w
	cp	a, 0:i3
	jr	z, AccompSeq_MidiFilterCodeBlock_Step2_Compare
	dec	1, a
AccompSeq_MidiFilterCodeBlock_Step2_Compare:
	cp	a, e
	jr	ule, AccompSeq_MidiFilterCodeBlock_Step2_Store
	ld	a, e
AccompSeq_MidiFilterCodeBlock_Step2_Store:
	ld	(PANEL_MSP+6:16), a
	ld	(0x7e78:16), 0
	or	(0xe3de:16), 16
AccompSeq_MidiFilterCodeBlock_Step2_Store_Return:
	ret
AccompSeq_LowestBitIndex:
	; Byte a (0..63) = the index of the lowest set bit of a, 0 for a = 0.  AccompSeq_ProcessAfterNote
	; reads it with `ld h, (xix+hl)` after `and a, 63`.  Was decoded as `nop / .byte 0x01 / push sr` ...
	.byte	0, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0
	.byte	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0
	.byte	5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0
	.byte	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0

AccompSeq_ProcessChordChange:
	and (0x7e6e:16), 254
	and (0x7e6f:16), 254
	and (0x7e5f:16), 252
	pushw hl
	calr AccompSeq_CompareChord
	popw hl
	ld a, (0x7e24:16)
	and a, 0x3
	cp a, 0:i3
	jr nz, AccompSeq_ChordChange_Reinit
	push xwa
	push xhl
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	call Fade_StartArmedFadeIn
	pop xiz
	pop xiy
	pop xix
	pop xde
	pop xbc
	pop xhl
	pop xwa
	calr AccompSeq_InitPartFull
	jr AccompSeq_ChordChange_CheckOverride

AccompSeq_ChordChange_Reinit:
	push xwa
	push xhl
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	call Fade_StartArmedFadeIn
	pop xiz
	pop xiy
	pop xix
	pop xde
	pop xbc
	pop xhl
	pop xwa
	calr AccompSeq_ReinitPart

AccompSeq_ChordChange_CheckOverride:
	bit 1, (0x7e5f:16)
	jr nz, AccompSeq_ChordChange_ApplyOverride
	bit 0, (0x7e5f:16)
	jr z, AccompSeq_ChordChange_Return
	or (0x7e6e:16), 1
	or (0x7e6f:16), 1

AccompSeq_ChordChange_ApplyOverride:
	and (0x7e5f:16), 253
	call AccompSeq_SetupChannels

AccompSeq_ChordChange_Return:
	ret

; Only when bit 0 of 0x3283 is set and bit 2 of SEQ_METRO_FLAGS clear: 0x7e60 / 0x7e61 = L / H; looks up the
; voice's style data (AccompSeq_ResetMidiState, AccompSeq_LookupStyleData) and, when bit 4 of its
; first byte is set, sets bit 0 of 0x7e5f if byte 0x433 equals (ACC_BEAT) + 1, else bit 1.  0x7e28 /
; 0x7e2a are saved and restored.
AccompSeq_CompareChord:
	bit 0, (ACC_RUN_FLAGS:16)
	jr z, AccompSeq_CompareChord_Return
	bit 2, (SEQ_METRO_FLAGS:16)
	jr nz, AccompSeq_CompareChord_Return
	ld (0x7e60:16), l
	ld (0x7e61:16), h
	ld wa, (0x7e2a:16)
	pushw wa
	ld wa, (0x7e28:16)
	pushw wa
	calr AccompSeq_ResetMidiState
	calr AccompSeq_LookupStyleData
	ld wa, (0x7e28:16)
	ldfr_werp WA, 0xe2
	ld wa, (0x7e2a:16)
	ld xiy, xwa
	ld a, (xiy + 0:8)
	bit 4, a
	jr z, AccompSeq_CompareChord_RestorePos
	ld a, (ACC_BEATS_PER_BAR:16)
	ld w, (ACC_BEAT:16)
	inc 1, w
	cp a, w
	jr z, AccompSeq_CompareChord_Match
	or (0x7e5f:16), 2
	jr AccompSeq_CompareChord_RestorePos

AccompSeq_CompareChord_Match:
	or (0x7e5f:16), 1

AccompSeq_CompareChord_RestorePos:
	popw wa
	ld (0x7e28:16), wa
	popw wa
	ld (0x7e2a:16), wa

AccompSeq_CompareChord_Return:
	ret

AccompSeq_SetupChannels:
	ei 6
	ld c, (ACC_CLOCK:16)
	ld (0x7e63:16), c
	ld wa, 0:i3
	ld a, (ACC_BEAT:16)
	ld (0x7e64:16), a
	ld (1130:16), c
	ld (1138:16), c
	ld (1128:16), wa
	ei 0
	bit 0, (0x7e24:16)
	jr z, AccompSeq_SetupCh2
	ld (0x7e52:16), 0
	ld xwa, 0x7e40
	ld (0x7e48:16), xwa
	ld xwa, 0x7e72
	ld (0x7e74:16), xwa
	ld wa, (0x7e2c:16)
	ld (ACCSEQ_BLOCK:16), wa
	ld wa, (0x7e2e:16)
	ld (0x7e44:16), wa
	ld wa, (0x7e3c:16)
	ld (ACCSEQ_BEAT_COUNTER:16), wa
	ld a, (0x7e6e:16)
	ld (0x7e6d:16), a
	calr AccompSeq_ParseSequenceData
	ld a, (0x7e6d:16)
	ld (0x7e6e:16), a
	ld wa, (ACCSEQ_BEAT_COUNTER:16)
	ld (0x7e3c:16), wa
	ld wa, (0x7e44:16)
	ld (0x7e2e:16), wa
	ld wa, (ACCSEQ_BLOCK:16)
	ld (0x7e2c:16), wa

AccompSeq_SetupCh2:
	bit 1, (0x7e24:16)
	jr z, AccompSeq_SetupCh_Return
	ld (0x7e52:16), 1
	ld xwa, 0x7e41
	ld (0x7e48:16), xwa
	ld xwa, 0x7e73
	ld (0x7e74:16), xwa
	ld wa, (0x7e30:16)
	ld (ACCSEQ_BLOCK:16), wa
	ld wa, (0x7e32:16)
	ld (0x7e44:16), wa
	ld wa, (0x7e3e:16)
	ld (ACCSEQ_BEAT_COUNTER:16), wa
	ld a, (0x7e6f:16)
	ld (0x7e6d:16), a
	calr AccompSeq_ParseSequenceData
	ld a, (0x7e6d:16)
	ld (0x7e6f:16), a
	ld wa, (ACCSEQ_BEAT_COUNTER:16)
	ld (0x7e3e:16), wa
	ld wa, (0x7e44:16)
	ld (0x7e32:16), wa
	ld wa, (ACCSEQ_BLOCK:16)
	ld (0x7e30:16), wa

AccompSeq_SetupCh_Return:
	ret

AccompSeq_ParseSequenceData:
	ld bc, 0:i3
	ld d, (0x7e64:16)
	ld e, (0x7e63:16)
	and (0x7e53:16), 254

AccompSeq_SeqParse_Loop:
	bit 0, (0x7e53:16)
	jr z, AccompSeq_SeqParse_Dispatch
	jp AccompSeq_SeqParse_Return

AccompSeq_SeqParse_Dispatch:
	calr ResolveVRAMAddressForVoice
	ld a, (xiy)
	cp a, 0x83
	jr z, AccompSeq_SeqParse_EndMark
	cp a, 0x81
	jr z, AccompSeq_SeqParse_TimeAdvance
	cp a, 0x90
	jr z, AccompSeq_SeqParse_MidiEvent
	cp a, 0x91
	jr z, AccompSeq_SeqParse_MidiEvent
	cp a, 0xd2
	jr z, AccompSeq_SeqParse_MidiEvent
	cp a, 0xd1
	jr z, AccompSeq_SeqParse_MidiEvent
	cp a, 0xd3
	jr z, AccompSeq_SeqParse_MidiEvent
	cp a, 0xd4
	jr z, AccompSeq_SeqParse_MidiEvent
	cp a, 0xd5
	jr z, AccompSeq_SeqParse_MidiEvent
	cp a, 0xd7
	jr z, AccompSeq_SeqParse_MidiEvent
	cp a, 0xc0
	jr z, AccompSeq_SeqParse_MidiEvent
	cp a, 0x84
	jp z, (AccompSeq_SeqParse_TempoReset:24)
	calr AccompSeq_AdvancePosition
	jr AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_EndMark:
	calr AccompSeq_CleanupSequence
	or (0x7e53:16), 1
	jr AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_TimeAdvance:
	ld bc, (ACCSEQ_BEAT_COUNTER:16)
	inc 1, bc
	ld b, c
	xor c, c
	cp de, bc
	jr nc, AccompSeq_SeqParse_TimeStore
	or (0x7e53:16), 1
	jr AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_TimeStore:
	incw 1, (ACCSEQ_BEAT_COUNTER:16)
	calr AccompSeq_AdvancePosition
	jr AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_MidiEvent:
	calr AccompSeq_CheckPatternEnd
	ld bc, (ACCSEQ_BEAT_COUNTER:16)
	ld c, a
	ld b, (ACCSEQ_BEAT_COUNTER:16)
	cp de, bc
	jr nc, AccompSeq_SeqParse_CheckNoteOn
	or (0x7e53:16), 1
	jp AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_CheckNoteOn:
	ld a, (xiy)
	cp a, 0x90
	jr nz, AccompSeq_SeqParse_CheckNoteOn8
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	jp AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_CheckNoteOn8:
	cp a, 0x91
	jr nz, AccompSeq_SeqParse_CheckProgChg
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	jp AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_CheckProgChg:
	cp a, 0xc0
	jr nz, AccompSeq_SeqParse_CtrlChg
	ld a, 0x1:opc
	cp (0x7e52:16), 0
	jr z, AccompSeq_SeqParse_ProgChg_SetCh
	ld a, 0x2:opc

AccompSeq_SeqParse_ProgChg_SetCh:
	or a, 0xc0
	ld (0x7e54:16), a
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	ld a, (xiy)
	ld (0x7e55:16), a
	calr AccompSeq_AdvancePosition
	ld a, (xiy)
	ld (0x7e56:16), a
	calr AccompSeq_AdvancePosition
	ld e, (xiy)
	and e, 0xf
	ld (0x7e57:16), e
	bit 0, (0x7e56:16)
	jr z, AccompSeq_SeqParse_ProgChg_Flags
	or e, 0x10

AccompSeq_SeqParse_ProgChg_Flags:
	ld a, (0x7e54:16)
	ld w, (0x7e55:16)
	calr AccompSeq_WriteMidiToBuffer
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	push xiy
	ld xiy, (0x7e48:16)
	ld a, (0x7e55:16)
	and a, 0x7f
	bit 0, (0x7e56:16)
	jr z, AccompSeq_SeqParse_ProgChg_Store
	or a, 0x80

AccompSeq_SeqParse_ProgChg_Store:
	ld (xiy), a
	pop xiy
	jp AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_CtrlChg:
	and a, 0xf
	ld (0x7e55:16), a
	ld a, 0x1:opc
	cp (0x7e52:16), 0
	jr z, AccompSeq_SeqParse_CtrlChg_SetCh
	ld a, 0x2:opc

AccompSeq_SeqParse_CtrlChg_SetCh:
	or a, 0xd0
	ld (0x7e54:16), a
	calr AccompSeq_AdvancePosition
	calr AccompSeq_AdvancePosition
	ld e, (xiy)
	ld (0x7e56:16), e
	ld w, (0x7e55:16)
	ld a, (0x7e54:16)
	calr AccompSeq_WriteMidiToBuffer
	calr AccompSeq_AdvancePosition
	ld w, (0x7e55:16)
	ld a, (0x7e54:16)
	and a, 0xf0
	cp a, 0xd0
	jr nz, AccompSeq_SeqParse_CtrlChg_Loop
	cp w, 5:i3
	jr nz, AccompSeq_SeqParse_CtrlChg_Loop
	ld a, (0x7e56:16)
	push xiy
	ld xiy, (0x7e74:16)
	ld (xiy), a
	pop xiy

AccompSeq_SeqParse_CtrlChg_Loop:
	jp AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_TempoReset:
	ld xwa, (0x7e65:16)
	cp (0x7e52:16), 0
	jr z, AccompSeq_SeqParse_TempoStore
	ld xwa, (0x7e69:16)

AccompSeq_SeqParse_TempoStore:
	ld (0x7e44:16), wa
	ldto_werp WA, 0xe2
	ld (ACCSEQ_BLOCK:16), wa
	jp AccompSeq_SeqParse_Loop

AccompSeq_SeqParse_Return:
	ret

AccompSeq_TempoScaleTable:
	.long TempoScale_1Beat
	.long TempoScale_2Beats
	.long TempoScale_3Beats
	.long TempoScale_4Beats
	.long TempoScale_5Beats
	.long TempoScale_6Beats
	.long TempoScale_7Beats
	.long TempoScale_8Beats
TempoScale_8Beats:
	; data, not code: TempoScale_8Beats is reached only as data (1 data), and its instruction decode held swi (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x84
TempoScale_7Beats:
	; data, not code: TempoScale_7Beats is reached only as data (1 data), and its instruction decode held swi (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x84
TempoScale_6Beats:
	; data, not code: TempoScale_6Beats is reached only as data (1 data), and its instruction decode held swi (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x84
TempoScale_5Beats:
	; data, not code: TempoScale_5Beats is reached only as data (1 data), and its instruction decode held swi (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x81, 0x81, 0x81, 0x81, 0x81, 0x84
TempoScale_4Beats:
	; data, not code: TempoScale_4Beats is reached only as data (1 data), and its instruction decode held swi (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x81, 0x81, 0x81, 0x81, 0x84
TempoScale_3Beats:
	; data, not code: TempoScale_3Beats is reached only as data (1 data), and its instruction decode held swi (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x81, 0x81, 0x81, 0x84
TempoScale_2Beats:
	; data, not code: TempoScale_2Beats is reached only as data (1 data), and its instruction decode held swi (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x81, 0x81, 0x84
TempoScale_1Beat:
	; data, not code: TempoScale_1Beat is reached only as data (2 data), and its instruction decode held swi (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x81, 0x84
AccompSeq_InitFuncTable:
	.long	AccompSeq_ResetToFactoryBanks
	.long	AccompSeq_VoiceResetStub
	.long	AccompSeq_InitBankIfNoError
	.long	AccompSeq_VoiceResetStub

AccompSeq_VoiceResetStub:
	ret

AccompSeq_ResetToFactoryBanks:
	call Voice_ResetToFactoryBanks
	ret

AccompSeq_InitBankIfNoError:
	call SubCPU_Payload_GetErrorFlag
	cp hl, 0xffff
	jr nz, AccompSeq_InitBankDone
	call MspUser_InitFromFactory

AccompSeq_InitBankDone:
	ret

AccompSeq_BankTablePtr:
	jp	Voice_ResetToFactoryBanks

; Jumps to Voice_InitBankTables.
; Called from MspLoad_InitVoice.
AccompSeq_InitBankTables:
	jp Voice_InitBankTables

