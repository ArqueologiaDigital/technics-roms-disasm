; ===========================================================================
; RingBuf_ReadByte - Read single byte from audio ring buffer
; ===========================================================================
; Entry: XWA = pointer to buffer control structure:
;        +0 = write pointer (16-bit)
;        +2 = read pointer (16-bit)
;        +4 = byte count (16-bit)
;        +6 = buffer data (4KB)
; Exit:  HL = byte read (0x0000-0x00FF) or 0xFFFF if buffer empty
; Notes: Uses 12-bit circular index (0xFFF mask = 4KB buffer)
;        Decrements byte count after successful read
; ===========================================================================
; Pops one byte from a ring buffer.  Already named in the reference file.
; Input XWA = ring descriptor base (always 0x2B0D in practice: +0x00 write index, +0x02 read
; index, +0x04 byte count, +0x06 payload).
; Returns HL = the byte (0..0xFF) or 0xFFFF when the count is zero -- callers test the SIGN of
; HL, not equality, so any value >= 0x8000 reads as "empty".
; Side effects: increments the read index (masked to 0x0FFF, so a 4096-byte payload) and
; decrements the count.  32 call sites, all in MIDI_Dispatch and RingBuf_SkipToEnd.
RingBuf_ReadByte:
	cpw (xwa + 4), 0x0
	jr z, RingBuf_ReadByte_Empty
	lda xbc, (xwa + 2)
	ld de, (xbc)
	incw 1, (xbc)
	and de, 0xFFF
	ld bc, de
	extz xbc
	inc 6, xbc
	add xbc, xwa
	ld c, (xbc)
	extz bc
	ld hl, bc
	decm 1, (xwa + 4)
	jr RingBuf_ReadByte_Return

; Count == 0: HL = 0xFFFF.
RingBuf_ReadByte_Empty:
	ldw hl, 0xFFFF

; Shared `ret`.
RingBuf_ReadByte_Return:
	ret

; A two-instruction convenience wrapper: `lda XWA,0x2B0D` then fall into RINGBUF_READBYTE,
; i.e. "read one byte from THE MIDI ring".  It has no caller in the authoritative source.
; The ELF name RingBuf_ReadByte_Data implies data; it is code.
; ★ Renamed 2026-09-25 from RingBuf_ReadByte_Data: header: `lda XWA,0x2B0D` then RINGBUF_READBYTE -- read one byte from the MIDI ring.
RingBuf_ReadByte_MidiRing:
	lda	xwa, (MIDI_RingBuffer:16)
	jr	RingBuf_ReadByte

; Drains a ring buffer completely and then RESETS THE WRITE INDEX to the read index.
; Input XWA = ring descriptor base.  Calls RINGBUF_READBYTE until it returns a negative value,
; then does (XIZ+0x00) = (XIZ+0x02), i.e. write := read.
; ★ This is the MIDI parser's error recovery: every "message truncated" branch of
; MIDI_Dispatch jumps here, so ONE malformed or short event discards the ENTIRE ring content
; (up to 4096 bytes of queued MIDI), not just the bad message.  8 call sites, all in
; MIDI_Dispatch.
RingBuf_SkipToEnd:
	push xiz
	ld xiz, xwa
	ld xwa, xiz
	calr RingBuf_ReadByte
	cp hl, 0:i3
	jr lt, RingBuf_SkipToEnd_Epilogue

; Drain loop; exits when RINGBUF_READBYTE returns negative.
RingBuf_SkipToEnd_Loop:
	ld xwa, xiz
	calr RingBuf_ReadByte
	cp hl, 0:i3
	jr ge, RingBuf_SkipToEnd_Loop

; write index := read index, pop XIZ, ret.
RingBuf_SkipToEnd_Epilogue:
	ld wa, (xiz + 2)
	ld (xiz), wa
	pop xiz
	ret

; --- RingBuffer_Write4K: Write a byte to a 4KB circular buffer ---
; Entry: XWA = pointer to buffer control block
;        C = byte to write
; Buffer layout: [0]=write_ptr(16), [4]=count(16), [6+]=data area
; Write pointer wraps at 4095 (AND 0x0FFF).
; ★ CODE, not const data.  The mirror image of RINGBUF_READBYTE: input XWA = ring descriptor
; base, C = the byte.  Stores C at payload[write index], increments the write index (masked
; 0x0FFF) and increments the count at +0x04.
; It performs NO capacity check -- nothing stops the count exceeding 0x1000.
; No caller anywhere in the authoritative source; Audio_CmdHandler_00_1F open-codes the same
; sequence against the fixed 0x2B0D ring instead.  Proposed rename because the existing name
; asserts "const data"; see [UNCERTAIN] if you would rather keep it.
; ★ Renamed 2026-09-25 from Audio_CmdHandler_ConstData: header: stores C at payload[write index & 0x0FFF] of a 4 KB ring (its own banner's name).
RingBuf_Write4K:
	ld	xde, xwa
	ld	hl, (xde)
	incw	1, (xde)
	and	hl, 4095
	ld	de, hl
	extz	xde
	inc	6, xde
	add	xde, xwa
	ld	(xde), c
	incw	1, (xwa+4)
	ret

; ===========================================================================
; Audio_CmdHandler_00_1F - Audio command handler for DSP/audio control
; ===========================================================================
; Entry: Stack contains:
;        XSP+004h = count of bytes to process (DE)
;        XSP+006h = pointer to command data (XWA)
; Exit:  HL = 0 (success)
; Notes: Writes incoming audio data to circular ring buffer
;        Buffer control at 0x2B0D (write ptr), 0x2B11 (count), 0x2B13 (base)
;        Uses 12-bit index (0xFFF mask = 4KB buffer capacity)
;        Called from CMD_DISPATCH_TABLE for commands 0x00-0x1F
; ===========================================================================
; Inter-CPU command handler for command classes 0x00..0x1F: copies N bytes from the main CPU's
; message body into the MIDI event ring.  Already named in the reference file.
; Inputs: stack (XSP+0x04) = DE = byte count, (XSP+0x06) = long pointer to the source bytes.
; Per byte it open-codes the ring push against the fixed globals: write index at 0x2B0D
; (post-incremented, masked 0x0FFF), payload base 0x2B13, count at 0x2B11 (incremented).
; Returns HL = 0.  6 call sites, all in the inter-CPU command dispatch table.
; ★ There is NO check that the count at 0x2B11 stays below 0x1000, and no check that the write
; index has not lapped the read index.  See the note under MIDI_Dispatch.
Audio_CmdHandler_00_1F:
	ld de, (xsp + 4)
	cp de, 0:i3
	jr z, Audio_CmdHandler_00_1F_Done

; Per-byte body: ring push plus source-pointer advance.
Audio_CmdHandler_00_1F_Loop:
	lda xwa, (MIDI_RingBuffer:16)
	ld bc, (xwa)
	incw 1, (xwa)
	and bc, 0xFFF
	lda xwa, (11027:16)
	extz xbc
	add xbc, xwa
	ld xwa, (xsp + 6)
	ld a, (xwa)
	ld (xbc), a
	incw 1, (11025:16)
	dec 1, de
	ld xwa, 1:i3
	add (xsp + 6), xwa
	cp de, 0:i3
	jr nz, Audio_CmdHandler_00_1F_Loop

; HL = 0, ret.
Audio_CmdHandler_00_1F_Done:
	ld hl, 0:i3
	ret

; ===========================================================================
; MIDI_Dispatch - MIDI message dispatcher
; ===========================================================================
; Entry: Ring buffer at 0x2B0D contains MIDI data from main CPU
; Exit:  Messages dispatched to appropriate voice parameter handlers
; Notes: Parses MIDI status byte (0x80-0xF0) and routes to handlers:
;        0x80/0x90 = Note Off/On -> Voice_NoteOn (velocity 0 = off)
;        0xB0 = Control Change -> Voice_CtrlChange
;        0xC0 = Program Change -> Voice_ProgChange
;        0xD0 = Channel Pressure -> Voice_ChanPressure
;        0xE0 = Pitch Bend -> Voice_PitchBend
;        0xF0 = System Message -> Voice_SystemMsg
;        Loops until buffer is empty (RingBuf_ReadByte returns 0xFFFF)
; ===========================================================================
; The MIDI event dispatcher.  Already named in the reference file.  Called once per pass of
; Audio_Main_Loop (0x01FAE6) via the unconditional call at 0x01FB2F.
; It first publishes the ring's current byte count to 0x27E7 via MIDI_Backlog_Publish
; (0x021031) -- that global is the MIDI BACKLOG GAUGE, see the findings note below -- then
; loops: read one byte; if it is negative the ring is empty and the routine returns; otherwise
; treat it as a status byte and switch on its top nibble.
; Each arm first checks that the ring still holds enough bytes for a complete event (5 for
; note-off, 3 for note-on/CC/channel-pressure/pitch-bend/system, 4 for program change); if not
; it calls RINGBUF_SKIPTOEND, which throws away the whole ring.  Otherwise it copies the fixed
; number of following bytes into that class's 6-byte staging buffer and calls the handler:
;   0x80 note-off        -> 0x2AE8 / 0x2AEE (extended)  -> Voice_ParamFinalize (0x031A72)
;   0x90 note-on         -> 0x2AF4  -> Voice_NoteOn (0x02CF97) or Voice_Poly_NoteOn (0x0356C9)
;                           when staging byte +0x01 >= 0xF0
;   0xB0 control change  -> 0x2AF8  -> Voice_CtrlChange (0x02A282)
;   0xC0 program change  -> 0x2AFC  -> Voice_ProgChange (0x034A4A)
;   0xD0 channel press.  -> 0x2B01  -> Voice_ChanPressure (0x02A4EA)
;   0xE0 pitch bend      -> 0x2B05  -> Voice_PitchBend (0x02A5E6)
;   0xF0 system          -> 0x2B09  -> Voice_SystemMsg (0x02A7AF)
;   anything else        -> RINGBUF_SKIPTOEND
; Note the events in the ring are FIXED-WIDTH internal records (status + 3..5 bytes), not raw
; MIDI wire bytes; running status is never handled.
; ★ THE DRAIN LOOP IS UNBOUNDED.  There is no iteration cap and no "stop after N events" check;
; MIDI_Dispatch returns only when the count at 0x2B11 reaches zero.  See findings.
MIDI_Dispatch:
	push xiz
	lda xiz, (MIDI_RingBuffer:16)
	ld wa, (xiz + 4)
	call MIDI_Backlog_Publish
	jrl MIDI_Dispatch_NextByte

; Status-byte switch (top nibble), tried from 0xF0 downwards.
MIDI_Dispatch_ParseStatus:
	ld wa, hl
	and wa, 0xF0
	cp wa, 0xF0
	jrl z, MIDI_Status_System
	cp wa, 0xE0
	jrl z, MIDI_Status_PitchBend
	cp wa, 0xD0
	jrl z, MIDI_Status_ChanPressure
	cp wa, 0xC0
	jrl z, MIDI_Status_ProgChange
	cp wa, 0xB0
	jrl z, MIDI_Status_CtrlChange
	cp wa, 0x90
	jrl z, MIDI_Status_NoteOn
	cp wa, 0x80
	jrl nz, MIDI_Status_Unknown
	cpw (xiz + 4), 0x5
	jr c, MIDI_Status_Incomplete
	bit 3, hl
	jr nz, MIDI_Status_NoteOn_Extended
	ld (10984:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10985:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10986:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10987:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10988:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10989:16), l
	lda xwa, (10984:16)
	call Voice_ParamFinalize
	jrl MIDI_Dispatch_Exit

; Note-off variant taken when bit 3 of the status byte is set: 6-byte record staged at 0x2AEE.
MIDI_Status_NoteOn_Extended:
	ld (10990:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10991:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10992:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10993:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10994:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10995:16), l
	lda xwa, (10990:16)
	call Voice_ParamFinalize
	jrl MIDI_Dispatch_Exit

; Fewer than 5 bytes left for a note-off: discard the whole ring via RINGBUF_SKIPTOEND.
MIDI_Status_Incomplete:
	ld xwa, xiz
	calr RingBuf_SkipToEnd
	jrl MIDI_Dispatch_NextByte

; 0x90: stage 4 bytes at 0x2AF4; staging byte +0x01 >= 0xF0 selects the poly handler.
MIDI_Status_NoteOn:
	cpw (xiz + 4), 0x3
	jr c, MIDI_Status_NoteOn_Skip
	ld (10996:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10997:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10998:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (10999:16), l
	ld a, (10997:16)
	cp a, 0xF0
	jr nc, MIDI_Status_NoteOn_Poly
	lda xwa, (10996:16)
	call Voice_NoteOn
	jrl MIDI_Dispatch_Exit

; Voice_Poly_NoteOn (0x0356C9) path.
MIDI_Status_NoteOn_Poly:
	lda xwa, (10996:16)
	call Voice_Poly_NoteOn
	jrl MIDI_Dispatch_Exit

; Truncated note-on: discard the ring.
MIDI_Status_NoteOn_Skip:
	ld xwa, xiz
	calr RingBuf_SkipToEnd
	jrl MIDI_Dispatch_NextByte

; 0xB0: stage 4 bytes at 0x2AF8, call Voice_CtrlChange.
MIDI_Status_CtrlChange:
	cpw (xiz + 4), 0x3
	jr c, MIDI_Status_CtrlChange_Skip
	ld (11000:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11001:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11002:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11003:16), l
	lda xwa, (11000:16)
	call Voice_CtrlChange
	jrl MIDI_Dispatch_Exit

; Truncated control change: discard the ring.
MIDI_Status_CtrlChange_Skip:
	ld xwa, xiz
	calr RingBuf_SkipToEnd
	jrl MIDI_Dispatch_NextByte

; 0xC0: stage 5 bytes at 0x2AFC, call Voice_ProgChange.
MIDI_Status_ProgChange:
	cpw (xiz + 4), 0x4
	jr c, MIDI_Status_ProgChange_Skip
	ld (11004:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11005:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11006:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11007:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11008:16), l
	lda xwa, (11004:16)
	call Voice_ProgChange
	jrl MIDI_Dispatch_Exit

; Truncated program change: discard the ring.
MIDI_Status_ProgChange_Skip:
	ld xwa, xiz
	calr RingBuf_SkipToEnd
	jrl MIDI_Dispatch_NextByte

; 0xD0: stage 4 bytes at 0x2B01, call Voice_ChanPressure.
MIDI_Status_ChanPressure:
	cpw (xiz + 4), 0x3
	jr c, MIDI_Status_ChanPressure_Skip
	ld (11009:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11010:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11011:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11012:16), l
	lda xwa, (11009:16)
	call Voice_ChanPressure
	jrl MIDI_Dispatch_Exit

; Truncated channel pressure: discard the ring.
MIDI_Status_ChanPressure_Skip:
	ld xwa, xiz
	calr RingBuf_SkipToEnd
	jr MIDI_Dispatch_NextByte

; 0xE0: stage 4 bytes at 0x2B05, call Voice_PitchBend.
MIDI_Status_PitchBend:
	cpw (xiz + 4), 0x3
	jr c, MIDI_Status_PitchBend_Skip
	ld (11013:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11014:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11015:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11016:16), l
	lda xwa, (11013:16)
	call Voice_PitchBend
	jr MIDI_Dispatch_Exit

; Truncated pitch bend: discard the ring.
MIDI_Status_PitchBend_Skip:
	ld xwa, xiz
	calr RingBuf_SkipToEnd
	jr MIDI_Dispatch_NextByte

; 0xF0: stage 4 bytes at 0x2B09, call Voice_SystemMsg.
MIDI_Status_System:
	cpw (xiz + 4), 0x3
	jr c, MIDI_Status_System_Skip
	ld (11017:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11018:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11019:16), l
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld (11020:16), l
	lda xwa, (11017:16)
	call Voice_SystemMsg
	jr MIDI_Dispatch_Exit

; Truncated system message: discard the ring.
MIDI_Status_System_Skip:
	ld xwa, xiz
	calr RingBuf_SkipToEnd
	jr MIDI_Dispatch_NextByte

; Status byte with an unrecognised top nibble (< 0x80): discard the ring.
MIDI_Status_Unknown:
	ld xwa, xiz
	calr RingBuf_SkipToEnd

; ★ The unbounded drain back-edge: read one byte, and if it is non-negative go round again.
MIDI_Dispatch_NextByte:
	ld xwa, xiz
	calr RingBuf_ReadByte
	ld wa, hl
	cp wa, 0:i3
	jrl ge, MIDI_Dispatch_ParseStatus

; pop XIZ, ret.
MIDI_Dispatch_Exit:
	pop xiz
	ret

; Computes the checksum word that trails the DSP1 image before it is DMAed out.
; No arguments.  Sums 0x24B8 words (0x4970 / 2) starting at (0x04531C) + 0x10 and returns
; HL = the one's complement (`cpl`) of the 16-bit total.
; Every caller immediately stores it at (0x04531C) + 0x72A8, i.e. the last word of the image.
; 4 call sites: DSP_WriteAlgoBuffer_Epilogue and three inside DSP_Reinit_VoiceSlots.
DSP_WriteCount_Compute:
	ldw bc, 0x4970
	srl bc, 1
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	lda xwa, (xwa + 16)
	ld de, 0:i3
	cp bc, 0:i3
	jr z, DSP_WriteCount_Next

; The `add DE,(XWA+)` / `djnz` accumulation loop.
DSP_WriteCount_Loop:
	add DE, (xwa+)
	djnz16 bc, DSP_WriteCount_Loop

; HL = ~sum.
DSP_WriteCount_Next:
	ld wa, de
	cpl wa
	ld hl, wa
	ret

; Builds one 0x50-byte DSP channel record inside the DSP1 image.
; Inputs: XWA = source parameter block, BC = channel index (0..0x7F).
; Destination = (0x04531C) + 0x4AA7 + 0x50*channel  (the 0x50 comes from ((ch*4)+ch)*16).
; Steps: ToneDB_Find_SubToneRecord (0x032AE0) with mask 0x00FF produces a source pointer;
; 0x1D words are block-copied into the record; then WaveSel_StageA1_FromToneSlot (0x032682) is
; run twice (selectors 0 and 1) and its result block-copied to record+0x3A and record+0x45
; (5 words + 1 byte each); finally the flag byte at record+0x12 and record+0x27 gets
; `and 0xCF` / `set 4` -- i.e. its 2-bit mode field is forced to 1.
; Callers: DSP_FlushAllSlots_Loop2 and two sites in DSP_Reinit_VoiceSlots.
DSP_InitChannelSlot:
	dec 6, xsp
	push xiz
	ld (xsp + 8), bc
	ld xde, xwa
	ld wa, (xsp + 8)
	ld c, a
	extz bc
	ld xwa, xde
	ldw de, 0xFF
	call ToneDB_Find_SubToneRecord
	ld (xsp + 4), xhl
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 2
	add xbc, xwa
	sll xbc, 4
	add xbc, 0x4AA7
	ld xde, xbc
	add xde, (Payload_Bss_Start+0x64a6:24)
	ld xwa, (xsp + 4)
	ld xiy, xwa
	ld xix, xde
	ldw bc, 0x1D
	ldirw
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 2
	add xbc, xwa
	sll xbc, 4
	add xbc, 0x4AA7
	add xbc, (Payload_Bss_Start+0x64a6:24)
	ld (xsp + 4), xbc
	ld xwa, xbc
	lda xwa, (xwa + 16)
	ld xiz, xwa
	ld xbc, xiz
	ld wa, (xsp + 8)
	extz wa
	pushw 0xFF
	ld de, wa
	ld wa, 0:i3
	call WaveSel_StageA1_FromToneSlot
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 2
	add xbc, xwa
	sll xbc, 4
	add xbc, 0x4AA7
	ld xwa, xbc
	add xwa, (Payload_Bss_Start+0x64a6:24)
	ld xiy, xhl
	lda xix, (xwa + 58)
	ld bc, 5:i3
	ldirw
	ldi85
	andmi8 (xiz + 2), 0xCF
	setm 4, (xiz + 2)
	ld xwa, (xsp + 4)
	lda xwa, (xwa + 37)
	ld xiz, xwa
	ld xbc, xiz
	ld wa, (xsp + 8)
	extz wa
	pushw 0xFF
	ld de, wa
	ld wa, 1:i3
	call WaveSel_StageA1_FromToneSlot
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, xwa
	sll xbc, 2
	add xbc, xwa
	sll xbc, 4
	add xbc, 0x4AA7
	ld xwa, xbc
	add xwa, (Payload_Bss_Start+0x64a6:24)
	ld xiy, xhl
	lda xix, (xwa + 69)
	ld bc, 5:i3
	ldirw
	ldi85
	andmi8 (xiz + 2), 0xCF
	setm 4, (xiz + 2)
	pop xiz
	inc 6, xsp
	ret

; Rebuilds the entire DSP1 image and ships it to the main CPU.
; Inputs: WA and BC identify the voice buffer (passed to ToneDB_Find_ToneRecord, 0x03206F).
; Steps: 0x93 words + 1 byte are copied from the located buffer to (0x04531C)+0x4980; then for
; all 128 voices, bit 5 of the word at (0x04531C)+0x49A7+2*v is cleared and immediately set
; again (a deliberate toggle, presumably an edge the DSP latches); then DSP_InitChannelSlot is
; run for all 128 channels; then 16 bytes are copied from the constant table at 0x0120F4 to
; (0x04531C)+0x4980..+0x498F; finally InterCPU_E1_DMA_Transfer(0x007800, 0x72AA, 0x001E0000).
; Sole direct caller: DSP_Reinit_VoiceSlots_OuterNext (0x03546B).
DSP_FlushAllSlots:
	dec 4, xsp
	pushw iz
	extz wa
	extz bc
	call ToneDB_Find_ToneRecord
	ld (xsp + 2), xhl
	ld xde, (Payload_Bss_Start+0x64a6:24)
	ld xwa, (xsp + 2)
	ld xiy, xwa
	lda xix, (xde+18816)
	ldw bc, 0x93
	ldirw
	ldi85
	ld iz, 0:i3
	cp iz, 0x80
	jr nc, DSP_FlushAllSlots_Loop1Next

; The 128-voice clear-then-set of bit 5 at (0x04531C)+0x49A7+2*v.
DSP_FlushAllSlots_Loop1:
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, 0x49A7
	add xwa, (Payload_Bss_Start+0x64a6:24)
	resm 5, (xwa + 1)
	ld wa, iz
	extz xwa
	add xwa, xwa
	add xwa, 0x49A7
	add xwa, (Payload_Bss_Start+0x64a6:24)
	setm 5, (xwa + 1)
	inc 1, iz
	cp iz, 0x80
	jr c, DSP_FlushAllSlots_Loop1

; Head of the 128-channel DSP_InitChannelSlot loop.
DSP_FlushAllSlots_Loop1Next:
	ld iz, 0:i3
	cp iz, 0x80
	jr nc, DSP_FlushAllSlots_Loop2Next

; Body: DSP_InitChannelSlot(buffer, channel).
DSP_FlushAllSlots_Loop2:
	ld xwa, (xsp + 2)
	ld bc, iz
	calr DSP_InitChannelSlot
	inc 1, iz
	cp iz, 0x80
	jr c, DSP_FlushAllSlots_Loop2

; Head of the 16-byte constant copy from 0x0120F4.
DSP_FlushAllSlots_Loop2Next:
	ld iz, 0:i3
	cp iz, 0x10
	jr nc, DSP_FlushAllSlots_Loop3Next

; Body of the 16-byte constant copy.
DSP_FlushAllSlots_Loop3:
	ld wa, iz
	extz xwa
	add xwa, 0x4980
	ld xde, xwa
	add xde, (Payload_Bss_Start+0x64a6:24)
	ld wa, iz
	extz xwa
	ld xbc, DSP1_ImageHeader_UserKit
	add xbc, xwa
	ld a, (xbc)
	ld (xde), a
	inc 1, iz
	cp iz, 0x10
	jr c, DSP_FlushAllSlots_Loop3

; ★ InterCPU_E1_DMA_Transfer(src 0x007800, len 0x72AA, dst 0x001E0000) -- the sub->main push.
DSP_FlushAllSlots_Loop3Next:
	lda xwa, (0x007800:24)
	ldw bc, 0x72AA
	ld xde, 0x1E0000
	call InterCPU_E1_DMA_Transfer
	popw iz
	inc 4, xsp
	ret

; ★ CODE, not data (the ELF calls it DSP_FlushAllSlots_Data).
; Input A = part index.  Loads WA = part+0x19 (0x041381) and BC = part+0x1A (0x041382) -- the
; two program-change bytes stored by Voice_ProgChange -- and tail-jumps into DSP_FlushAllSlots.
; So this is "flush the DSP using the program currently assigned to this part".
; It has no caller in the authoritative source; either dead or reached from the boot ROM.
; ★ Renamed 2026-09-25 from DSP_FlushAllSlots_Data: header: flush the DSP with the program-change bytes of part A.
DSP_FlushAllSlots_ForPart:
	ld	c, a
	extz	bc
	muls	bc, 287
	lda	xde, (Payload_Bss_Start+0x250b:24)
	ld	c, (xde+bc)
	ld	e, c
	extz	de
	extz	wa
	muls	wa, 287
	lda	xbc, (Payload_Bss_Start+0x250c:24)
	ld	a, (xbc+wa)
	ld	c, a
	extz	bc
	ld	wa, de
	jrl	DSP_FlushAllSlots

; Resolves one DSP1 microprogram/parameter stream out of the blob whose base is the constant
; 0x00050000 (also installed at 0x045310/0x045314 by DSP_System_Init).
; Input WA = stream index.  Reads a bias word from base+0x88, adds it to WA, then indexes the
; 32-bit table at base + (word at base+0x08) by 4*index and returns XHL = base + entry,
; XBC = base.  3 call sites, all in DSP_Reinit_VoiceSlots.
DSP1_ResolveStreamPtr:
	ld xhl, 0x50000
	ld	xbc, (xhl+136)
	add wa, bc
	ld xbc, (xhl + 8)
	ld xde, xhl
	add xde, xbc
	extz xwa
	sll xwa, 2
	add xde, xwa
	ld xwa, (xde)
	ld xbc, xhl
	add xhl, xwa
	ret

; Copies the 16 default bytes at 0x0120E3 to the first 16 bytes of the DSP1 image at
; (0x04531C).  No arguments.  Sole caller: DSP_Reinit_VoiceSlots_Loop3A (0x035427).
DSP_ResetAlgoDefaults:
	ld hl, 0:i3
	cp hl, 0x10
	ret nc

; The 16-byte copy loop.
DSP_ResetAlgoDefaults_Loop:
	ld wa, hl
	extz xwa
	ld xde, xwa
	add xde, (Payload_Bss_Start+0x64a6:24)
	ld wa, hl
	extz xwa
	ld xbc, DSP1_ImageHeader_SoundRAM
	add xbc, xwa
	ld a, (xbc)
	ld (xde), a
	inc 1, hl
	cp hl, 0x10
	jr c, DSP_ResetAlgoDefaults_Loop
	ret

; Loads one part's effect algorithm into one DSP1 slot and ships the image.
; Inputs: A = part index, C = DSP slot index.  Returns L = 0 on success, 2 on rejection.
; Rejects (L = 2) if A >= 0x1A or C >= 0x28 -- 26 parts, 40 DSP slots.
; Otherwise it block-copies 0xD5 words from the part's descriptor (part+0x06 dereferenced) to
; (0x04531C) + 0x10 + 0x01D6*slot, then for each of the four output slots copies 5 words + 1
; byte from the pointer at output-slot+0x04 to slotbase + 0x0B*i + 0x01BA, and forces the
; 2-bit mode field of the byte at slotbase + 0x51*i + 0x79 to 1 unless it is already 3.
; Finally: DSP_WriteCount_Compute, store the checksum at (0x04531C)+0x72A8, and
; InterCPU_E1_DMA_Transfer(0x007800, 0x72AA, 0x001E0000).
DSP_WriteAlgoBuffer:
	push xiz
	ld e, c
	cp a, 0x1A
	jr nc, DSP_WriteAlgoBuffer_PathA
	cp e, 0x28
	jr c, DSP_WriteAlgoBuffer_PathB

; Rejection path: L = 2, straight to the exit (no DMA, no image change).
DSP_WriteAlgoBuffer_PathA:
	ld l, 0x2:opc
	jrl DSP_WriteAlgoBuffer_Return

; Accepted: the 0xD5-word descriptor copy into the slot's algorithm block.
DSP_WriteAlgoBuffer_PathB:
	ld c, e
	extz bc
	muls bc, 0x1D6
	ld iz, bc
	add iz, 0x10
	ld xhl, (Payload_Bss_Start+0x64a6:24)
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_PatchRecord_Ptr:24)
	ld	xiy, (xix+bc)
	lda	xix, (xhl+iz)
	ldw bc, 0xD5
	ldirw
	ld l, 0x0:opc
	cp l, 4:i3
	jrl nc, DSP_WriteAlgoBuffer_Epilogue

; Per-output-slot body: the 5-word+1-byte copy and the mode-field fixup.
DSP_WriteAlgoBuffer_Loop:
	ld c, l
	extz bc
	muls bc, 0xB
	ld ix, bc
	ld c, e
	extz bc
	muls bc, 0x1D6
	ld iy, bc
	add iy, ix
	ld xbc, (Payload_Bss_Start+0x64a6:24)
	lda	xiz, (xbc+iy)
	ld c, l
	extz bc
	muls bc, 0x25
	ld iy, bc
	add iy, 0x6E
	ld c, a
	extz bc
	muls bc, 0x11F
	lda xix, (Part_Record_Base:24)
	exts xbc
	add xbc, xix
	lda	xbc, (xbc+iy)
	ld xiy, (xbc + 4)
	lda xix, (xiz+442)
	ld bc, 5:i3
	ldirw
	ldi85
	ld c, l
	extz bc
	muls bc, 0x51
	ld ix, bc
	ld c, e
	extz bc
	muls bc, 0x1D6
	ld iy, bc
	add iy, ix
	ld xbc, (Payload_Bss_Start+0x64a6:24)
	lda	xix, (xbc+iy)
	lda xix, (xix + 121)
	ld c, (xix)
	and c, 0xC0
	cp c, 0xC0
	jr z, DSP_WriteAlgoBuffer_LoopNext
	andmi8 (xix), 0xCF
	setm 4, (xix)

; Output-slot loop increment and back-edge (i < 4).
DSP_WriteAlgoBuffer_LoopNext:
	inc 1, l
	cp l, 4:i3
	jrl c, DSP_WriteAlgoBuffer_Loop

; ★ Checksum, store at image+0x72A8, then InterCPU_E1_DMA_Transfer -- the sub->main push.
DSP_WriteAlgoBuffer_Epilogue:
	calr DSP_WriteCount_Compute
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	ld	(xwa+29352), hl
	lda xwa, (0x007800:24)
	ldw bc, 0x72AA
	ld xde, 0x1E0000
	call InterCPU_E1_DMA_Transfer
	ld l, 0x0:opc

; Not data: the shared `pop XIZ / ret` exit, reached from the rejection path by `jrl`.
; ★ Renamed 2026-09-25 from DSP_WriteAlgoBuffer_Data: header: the shared `pop XIZ / ret` exit of DSP_WriteAlgoBuffer.
DSP_WriteAlgoBuffer_Return:
	pop xiz
	ret

; The general "re-stage part of the DSP1 image and push it" entry.  Inputs A and C are a
; two-level selector; every path ends at the same DMA push.
;   A < 0x40 and C != 0xFF : re-stage the single stream (A*0x14 + C)
;   A < 0x40 and C == 0xFF : re-stage the 0x14 streams A*0x14 .. A*0x14+0x13
;   A == 0xFF              : DSP_ResetAlgoDefaults, re-stage streams 0..0x27, then
;                            DSP_FlushAllSlots(0, 0x40) -- the full rebuild
;   otherwise, C != 0xFF   : DSP_InitChannelSlot for channel C only
;   otherwise, C == 0xFF   : DSP_InitChannelSlot for all 128 channels
; Re-staging one stream = DSP1_ResolveStreamPtr(index) then a 0xD5-word copy to
; (0x04531C) + 0x10 + 0x01D6*index.
; All paths converge on DSP_WriteCount_Compute + the checksum store + the DMA push.
DSP_Reinit_VoiceSlots:
	dec 4, xsp
	push xiz
	cp a, 0x40
	jrl nc, DSP_Reinit_VoiceSlots_Loop2A
	cp c, 0xFF
	jr z, DSP_Reinit_VoiceSlots_Loop1
	extz bc
	extz wa
	mul wa, 0x14
	ldfr_werp WA, 0xFA
	add wa, bc
	ldfr_werp WA, 0xFA
	calr DSP1_ResolveStreamPtr
	ld (xsp + 4), xhl
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x1D6
	call Math_Multiply32
	add xhl, 0x10
	add xhl, (Payload_Bss_Start+0x64a6:24)
	ld xwa, (xsp + 4)
	ld xiy, xwa
	ld xix, xhl
	ldw bc, 0xD5
	ldirw
	jr DSP_Reinit_VoiceSlots_Loop2

; C == 0xFF: set up the 0x14-stream range for part A.
DSP_Reinit_VoiceSlots_Loop1:
	ldfr_berp A, 0xF8
	extz iz
	ld wa, iz
	mul wa, 0x14
	ld iz, wa
	ldfr_werp IZ, 0xFA
	ld bc, iz
	add bc, 0x14
	ldto_werp WA, 0xFA
	cp wa, bc
	jr nc, DSP_Reinit_VoiceSlots_Loop2

; Body: resolve one stream and copy 0xD5 words into its slot.
DSP_Reinit_VoiceSlots_Loop1Next:
	ldto_werp WA, 0xFA
	calr DSP1_ResolveStreamPtr
	ld (xsp + 4), xhl
	ldto_werp WA, 0xFA
	extz xwa
	ld xbc, 0x1D6
	call Math_Multiply32
	add xhl, 0x10
	add xhl, (Payload_Bss_Start+0x64a6:24)
	ld xwa, (xsp + 4)
	ld xiy, xwa
	ld xix, xhl
	ldw bc, 0xD5
	ldirw
	inc1w_erp 0xFA
	ld bc, iz
	add bc, 0x14
	ldto_werp WA, 0xFA
	cp wa, bc
	jr c, DSP_Reinit_VoiceSlots_Loop1Next

; Checksum + store, then jump to the DMA flush.
DSP_Reinit_VoiceSlots_Loop2:
	calr DSP_WriteCount_Compute
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	ld	(xwa+29352), hl
	jrl DSP_Reinit_VoiceSlots_DMAFlush

; A >= 0x40 entry: distinguishes the A == 0xFF full rebuild from the channel-slot paths.
DSP_Reinit_VoiceSlots_Loop2A:
	cp a, 0xFF
	jr z, DSP_Reinit_VoiceSlots_Loop3A
	cp c, 0xFF
	jr z, DSP_Reinit_VoiceSlots_Loop2B
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	lda xwa, (xwa+18816)
	extz bc
	calr DSP_InitChannelSlot
	jr DSP_Reinit_VoiceSlots_Loop3

; C == 0xFF: head of the 128-channel DSP_InitChannelSlot loop.
DSP_Reinit_VoiceSlots_Loop2B:
	ldfr_werp IZ, 0xFA
	cp_erpw 0xFA, 0x80, 0x00
	jr nc, DSP_Reinit_VoiceSlots_Loop3

; Body of the 128-channel loop.
DSP_Reinit_VoiceSlots_Loop2Next:
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	lda xwa, (xwa+18816)
	ldto_werp BC, 0xFA
	calr DSP_InitChannelSlot
	inc1w_erp 0xFA
	cp_erpw 0xFA, 0x80, 0x00
	jr c, DSP_Reinit_VoiceSlots_Loop2Next

; Checksum + store for the channel-slot paths.
DSP_Reinit_VoiceSlots_Loop3:
	calr DSP_WriteCount_Compute
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	ld	(xwa+29352), hl
	jr DSP_Reinit_VoiceSlots_DMAFlush

; A == 0xFF full rebuild: DSP_ResetAlgoDefaults then the 0x28-stream re-stage loop.
DSP_Reinit_VoiceSlots_Loop3A:
	calr DSP_ResetAlgoDefaults
	ld iz, 0:i3
	cp iz, 0x28
	jr nc, DSP_Reinit_VoiceSlots_OuterNext

; Body of the 0x28-stream re-stage loop.
DSP_Reinit_VoiceSlots_Loop3Next:
	ld wa, iz
	calr DSP1_ResolveStreamPtr
	ld (xsp + 4), xhl
	ld wa, iz
	extz xwa
	ld xbc, 0x1D6
	call Math_Multiply32
	add xhl, 0x10
	add xhl, (Payload_Bss_Start+0x64a6:24)
	ld xwa, (xsp + 4)
	ld xiy, xwa
	ld xix, xhl
	ldw bc, 0xD5
	ldirw
	inc 1, iz
	cp iz, 0x28
	jr c, DSP_Reinit_VoiceSlots_Loop3Next

; Full-rebuild tail: DSP_FlushAllSlots(0, 0x40), then checksum + store.
DSP_Reinit_VoiceSlots_OuterNext:
	ld wa, 0:i3
	ldw bc, 0x40
	calr DSP_FlushAllSlots
	calr DSP_WriteCount_Compute
	ld xwa, (Payload_Bss_Start+0x64a6:24)
	ld	(xwa+29352), hl

; ★ The common exit: InterCPU_E1_DMA_Transfer(0x007800, 0x72AA, 0x001E0000).
DSP_Reinit_VoiceSlots_DMAFlush:
	lda xwa, (0x007800:24)
	ldw bc, 0x72AA
	ld xde, 0x1E0000
	call InterCPU_E1_DMA_Transfer
	pop xiz
	inc 4, xsp
	ret

; Scans all 26 parts and acts on the program byte at part+0x1A (0x041382).
; Only the head of the scan is inside this region: it compares part+0x1A against 0x10 and 0x50
; and branches to the per-part body at 0x0354CA (just past the region boundary) when either
; matches, otherwise to the loop-increment at 0x035551.  3 call sites outside the region.
; The 0x10 / 0x50 constants are program-byte class markers, matching the two "voice active"
; encodings used by Voice_ProgChange.
DSP_VoiceState_Dispatch:
	pushw_erp 0xFA
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x1A
	jrl nc, DSP_VoiceState_Dispatch_Epilogue

; Per-part test of part+0x1A against 0x10 then 0x50.  The rest of the routine (the
; DSP_VoiceState_Dispatch_ActiveVoice body at 0x0354CA and the loop tail at 0x035551) lies
; beyond 0x0354C9 and belongs to the next region.
DSP_VoiceState_Dispatch_Scan:
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x250c:24)
	cp	(xbc+wa), 0x10
	jr z, DSP_VoiceState_Dispatch_ActiveVoice
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x250c:24)
	cp	(xbc+wa), 0x50
	jrl nz, DSP_VoiceState_Dispatch_LoopNext

; Body of DSP_VoiceState_Dispatch, whose entry (0x035497) is just below this region. For MIDI
; part `n` (0..0x19, stride 0x11F from the 0x041368 part table) whose byte at +0x1A is 0x10 or
; 0x50, calls WaveSel_Rebuild_PartCaches(WA=n, BC=part[+0x19], DE=part[+0x1A]), then switches on
; bits 7:6 of tonerec[+0x10] (tonerec = the long at part+0x06): 0x80 or 0 -> next part,
; 0x40 -> SubPathB, 0xC0 -> SubPathA.
DSP_VoiceState_Dispatch_ActiveVoice:
	ldto_berp A, 0xFB
	ld l, a
	extz hl
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x250b:24)
	ld	a, (xbc+wa)
	ldfr_berp A, 0xF0
	extz ix
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x11F
	lda xbc, (Payload_Bss_Start+0x250c:24)
	ld	a, (xbc+wa)
	ld e, a
	extz de
	ld wa, hl
	ld bc, ix
	call WaveSel_Rebuild_PartCaches
	ldto_berp A, 0xFB
	extz wa
	muls wa, 0x11F
	lda xbc, (Part_PatchRecord_Ptr:24)
	ld	xwa, (xbc+wa)
	ld a, (xwa + 16)
	and a, 0xC0
	cp a, 0x80
	jr z, DSP_VoiceState_Dispatch_LoopNext
	cp a, 0x40
	jr z, DSP_VoiceState_Dispatch_SubPathB
	cp a, 0xC0
	jr z, DSP_VoiceState_Dispatch_SubPathA
	cp a, 0:i3
	jr nz, DSP_VoiceState_Dispatch_LoopNext

; tonerec type 0xC0: call VoiceSlot_FullInit(WA = part index), then continue the scan.
DSP_VoiceState_Dispatch_SubPathA:
	ldto_berp A, 0xFB
	extz wa
	call VoiceSlot_FullInit
	jr DSP_VoiceState_Dispatch_LoopNext

; tonerec type 0x40: Voice_PortamentoTargets_SetAll(part) then VoiceSlot_AltInit(part).
DSP_VoiceState_Dispatch_SubPathB:
	ldto_berp A, 0xFB
	extz wa
	call Voice_PortamentoTargets_SetAll
	ldto_berp A, 0xFB
	extz wa
	call VoiceSlot_AltInit

; ++part; loop back to the scan while part < 0x1A.
DSP_VoiceState_Dispatch_LoopNext:
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x1A
	jrl c, DSP_VoiceState_Dispatch_Scan

; pop frame, ret. Callers: DSP_Cmd2B_AlgoSelect's neighbourhood (0x026279), CmdHandler2C
; sub-commands 4 and 6 (0x035EF0, 0x035F0B).
DSP_VoiceState_Dispatch_Epilogue:
	popw_erp 0xFA
	ret

; Resets the two DSP working-buffer write pointers to 0x007800:
;   (0x045320) = 0x00007800 ; (0x04531C) = 0x00007800
; Both are 32-bit. Companions set at boot by DSP_System_Init_Continue: (0x045310) and
; (0x045314) = 0x00050000, (0x045318) = 0x000A0000. So 0x045310..0x045323 is a block of five
; longword pointers into the DSP's own address space, of which these two are the ones that
; get rewound. Called from the audio init path (0x032186), right after DSP_Reset. No
; hardware touched. No inputs, no outputs.
DSP_ResetWriteBufferPtr:
	lda xwa, (0x007800:24)
	ld (Payload_Bss_Start+0x64aa:24), xwa
	lda xwa, (0x007800:24)
	ld (Payload_Bss_Start+0x64a6:24), xwa
	ret

; Bare `ret`. One of three consecutive 1-byte stubs; all three are still referenced by
; pointer tables elsewhere, so they are placeholders for removed features, not padding.
DSP_Stub_RetA:
	ret

; Bare `ret`.
DSP_Stub_RetB:
	ret

; Bare `ret`.
DSP_Stub_RetC:
	ret

; Square-law velocity -> 12-bit volume curve, computed not tabulated.
;   HL = ((WA * WA) >> 2) + 0x3F        (mul XBC,WA is a full 16x16->32; only BC is shifted)
; For the 0..0x7F range the tone generator actually feeds it, that maps 0 -> 0x003F and
; 0x7F -> 0x0FFF, i.e. exactly the 12-bit full-scale that ToneGen_SetupPercussionVoice
; hard-codes with `or (0x3B20), 4095`. Entry WA = velocity, exit HL = level. Sole caller
; ToneGen_SetupPolyVoice, which ORs the result into the staging word at 0x3B20.
DSP_VelocityToVolume:
	ld bc, wa
	mul xbc, wa
	srl bc, 2
	ld hl, bc
	add hl, 0x3F
	ret

; Builds the per-note effect-send word that both ToneGen setup routines OR into the staging
; word at 0x3B22. No inputs; reads two global bytes and returns HL.
;   HL = 0
;   if (0x041377) != 0 :  HL |= (0x041377) << 8
;   if (0x04137A) == 0 :  return HL
;   HL |= (0x041377)                      <-- reads 0x041377 again, NOT 0x04137A
; The second load really is from 0x041377 -- verified at byte level, 0x0355A3 is
; `c2 77 13 04 21`, and both toolchains reproduce it. See [UNCERTAIN].
DSP_GetEffectRouting:
	ld hl, 0:i3
	cp (Payload_Bss_Start+0x2501:24), 0x00
	jr z, DSP_GetEffectRouting_Path
	ld a, (Payload_Bss_Start+0x2501:24)
	extz wa
	sll wa, 8
	or hl, wa

; Second half of the above: the low-byte send, gated on 0x04137A.
DSP_GetEffectRouting_Path:
	cp (Payload_Bss_Start+0x2504:24), 0x00
	ret z
	ld a, (Payload_Bss_Start+0x2501:24)
	extz wa
	or hl, wa
	ret

; Note-on for the melodic entries of the auxiliary 8-voice pool. Entry: A = tone-generator
; voice number (== the pool slot 0..7), C = pool channel 0..5, E = MIDI note, one word of
; velocity pushed by the caller (this routine ends in `retd 0x2`).
; Steps:
;   1. refill the 68-byte staging block 0x3B1C..0x3B5F from the ROM template at 0x012115
;      (0x22 words, `ldirw` with XIX = destination, XIY = source);
;   2. note += (byte at 0x012171 + channel); clear bit 7; staging word 0x3B2A = note << 8
;      with bit 7 set;
;   3. if (0x012177 + channel) != 0 that byte replaces the caller's velocity;
;   4. OR DSP_VelocityToVolume(velocity) into staging 0x3B20, and DSP_GetEffectRouting()
;      into staging 0x3B22;
;   5. staging 0x3B1E = word from the table at 0x01217D indexed by (note / 12) * 2 -- an
;      octave-indexed pitch/rate constant;
;   6. ToneGen_WriteVoiceParams(WA = voice, XBC = 0x3B1C) then
;      ToneGen_WriteSingleReg(WA = voice, XBC = word at 0x3B1C).
; Hardware: indirectly the tone generator at 0x100000/0x100002 through the two writers.
; Reached only through the 6-entry dispatch table at ROM 0x012159 (see [DATA]).
ToneGen_SetupPolyVoice:
	dec 4, xsp
	ld (xsp), e
	ld e, c
	ld (xsp + 2), a
	ld xiy, ToneGen_Voice_Param_Template
	ld xix, 0x3B1C
	ldw bc, 0x22
	ldirw
	ld a, e
	extz wa
	lda xbc, (Audio_DSP_StateTable_Packed:24)
	ld	a, (xbc+wa)
	add a, (xsp)
	ld (xsp), a
	resm 7, (xsp)
	ld a, (xsp)
	extz wa
	sll wa, 8
	set 7, wa
	ld (15146:16), wa
	ld a, e
	extz wa
	lda xbc, (ToneGen_VoiceType_Default_Level:24)
	cp	(xbc+wa), 0x00
	jr z, ToneGen_SetupPolyVoice_Path
	ld a, e
	extz wa
	lda xbc, (ToneGen_VoiceType_Default_Level:24)
	ld	a, (xbc+wa)
	ld (xsp + 8), a

; Join point after the optional velocity override; steps 4-6 above.
ToneGen_SetupPolyVoice_Path:
	ld a, (xsp + 8)
	extz wa
	calr DSP_VelocityToVolume
	or (15136:16), hl
	calr DSP_GetEffectRouting
	or (15138:16), hl
	ld a, (xsp)
	extz wa
	div a, 0xC
	ld a, w
	extz wa
	add wa, wa
	lda xbc, (ToneGen_Semitone_Pitch_Table:24)
	ld	wa, (xbc+wa)
	ld (15134:16), wa
	ld a, (xsp + 2)
	extz wa
	lda xbc, (15132:16)
	call ToneGen_WriteVoiceParams
	ld a, (xsp + 2)
	extz wa
	ld bc, (15132:16)
	call ToneGen_WriteSingleReg
	inc 4, xsp
	retd 0x2

; The percussion variant, dispatch-table entry 1. Entry A = tone-generator voice, E = note,
; one pushed word (`retd 0x2`). Same template refill into 0x3B1C. Differences from the
; melodic path: the note is split into octave (note/12, kept in C) and pitch class
; (note - octave, bit 7 cleared); the pitch class goes into staging 0x3B2A << 8, the octave
; indexes the word table at 0x012195 which is ORed into staging 0x3B1C; the volume is the
; fixed full-scale 0xFFF rather than a velocity curve; and staging 0x3B1E takes the single
; word at 0x01217D instead of an octave-indexed one. Then the same two ToneGen writers.
ToneGen_SetupPercussionVoice:
	dec 2, xsp
	ld (xsp), a
	ld xiy, ToneGen_Voice_Param_Template
	ld xix, 0x3B1C
	ldw bc, 0x22
	ldirw
	ld a, e
	extz wa
	div a, 0xC
	ld c, w
	sub e, c
	res 7, e
	ld a, e
	extz wa
	sll wa, 8
	or (15146:16), wa
	ld a, c
	extz wa
	add wa, wa
	lda xbc, (ToneGen_Octave_Pitch_Table:24)
	ld	wa, (xbc+wa)
	or (15132:16), wa
	calr DSP_GetEffectRouting
	or (15138:16), hl
	orw (15136:16), 4095
	ld wa, (ToneGen_Semitone_Pitch_Table:24)
	ld (15134:16), wa
	ld a, (xsp)
	extz wa
	lda xbc, (15132:16)
	call ToneGen_WriteVoiceParams
	ld a, (xsp)
	extz wa
	ld bc, (15132:16)
	call ToneGen_WriteSingleReg
	inc 2, xsp
	retd 0x2

; ALREADY NAMED in the reference file -- doc header only, no rename.
; Handler for internal pseudo-MIDI packets whose status byte is >= 0xF0. Reached from
; MIDI_Dispatch (0x0323F0 area) with XWA pointing at the 4-byte packet in the MIDI scratch
; at 0x2AF4: +1 = status (0xF0 | channel), +2 = note, +3 = velocity.
; The KN5000's own firmware injects such packets: DSP_WriteAlgoInitPreset and
; DSP_SlotState_DisplayRestore push one of the canned 4-byte messages at ROM 0x0121EB /
; 0x0121EF / 0x0121F3 (`F0 50 B0 01`, `F0 50 B0 05`, `F0 50 B0 06`) into the MIDI ring via
; Audio_CmdHandler_00_1F and then call MIDI_Dispatch immediately. So this is the path the
; DSP subsystem uses to make the tone generator produce its own reference tone.
; Behaviour:
;   channel = status & 0xF; if status < 0xF0 return; if channel > 5 force channel = 0
;   slot = (0x3B13) = ((0x3B13) + 1) & 7        -- pure round robin, the tone generator's
;                                                  active-voice bitmap is NEVER consulted
;   velocity = packet[+3] & 0x7F ; note = packet[+2] & 0x7F
;   if velocity == 0 -> Voice_Poly_NoteOn_ReleasePath (note-off)
;   else: TG reg 0x21 voice slot <= 0xFF00, TG reg 0x20 voice slot <= 0xFF80, then call
;         through the 6-entry table at ROM 0x012159 indexed by channel, then mark
;         (0x3B14 + slot) = note | 0x80.
; Hardware: writes 0x100000 (address latch) and 0x100002 (data) directly, with the
; res 7,(P6) / set 7,(P6) address-vs-data strobe and the mandatory settling nops.
Voice_Poly_NoteOn:
	push xiz
	ld e, (xwa + 1)
	ld c, e
	and c, 0xF
	ldfr_berp C, 0xFB
	cp e, 0xF0
	jrl c, Voice_Poly_NoteOn_Epilogue
	cpib_erp 0xFB, 5
	jr ule, Voice_Poly_NoteOn_RoundRobin
	ldib_erp 0xFB, 0

; Advances the round-robin index at 0x3B13 and extracts note and velocity from the packet.
Voice_Poly_NoteOn_RoundRobin:
	ld c, (15123:16)
	inc 1, c
	and c, 0x7
	ld (15123:16), c
	ld c, (xwa + 3)
	res 7, c
	ldfr_berp C, 0xF9
	ld a, (xwa + 2)
	res 7, a
	ldfr_berp A, 0xFA
	cpib_erp 0xF9, 0
	jrl z, Voice_Poly_NoteOn_ReleasePath
	res	7, (P6:8)
	ld a, (15123:16)
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff00
	jr Voice_Poly_NoteOn_SlotSearch

; Second half of the note-on register pair: settling nops, then TG reg 0x20 voice slot
; <= 0xFF80. Despite the existing name it does not search anything.
Voice_Poly_NoteOn_SlotSearch:
	nop
	nop
	nop
	res	7, (P6:8)
	ld a, (15123:16)
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xff80
	jr Voice_Poly_NoteOn_SlotFound

; Calls the per-channel setup routine through the table at ROM 0x012159 (index = channel * 4)
; with WA = slot, BC = channel, DE = note and velocity pushed, then records the owner byte
; (0x3B14 + slot) = note | 0x80.
Voice_Poly_NoteOn_SlotFound:
	nop
	nop
	nop
	ld a, (15123:16)
	ld l, a
	extz hl
	ldto_berp A, 0xFB
	ld c, a
	extz bc
	ldto_berp A, 0xFA
	ld e, a
	extz de
	ldto_berp A, 0xF9
	extz wa
	pushw wa
	ld wa, hl
	ldto_berp L, 0xFB
	extz hl
	sla hl, 2
	lda xix, (Voice_PolyNoteOn_Setup_PtrTable:24)
	exts xhl
	add xhl, xix
	ld xhl, (xhl)
	call (xhl)
	ld a, (15123:16)
	extz wa
	lda xbc, (15124:16)
	ld de, wa
	extz xde
	add xde, xbc
	ldto_berp A, 0xFA
	set 7, a
	ld (xde), a
	jr Voice_Poly_NoteOn_Epilogue

; velocity == 0: set bit 7 of the note byte to form the owner key, then scan slots 0..7.
Voice_Poly_NoteOn_ReleasePath:
	set_erpb 0xFA, 0x07
	ldib_erp 0xFB, 0
	cp_erpb 0xFB, 0x08
	jr nc, Voice_Poly_NoteOn_Epilogue

; Compares (0x3B14 + slot) against the owner key; on a miss go to AssignSlot (which is really
; just "next slot"); on a hit write TG reg 0x21 voice slot <= 0xA200.
Voice_Poly_NoteOn_ReleaseCheck:
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (15124:16)
	extz xwa
	add xwa, xbc
	ld a, (xwa)
	cpb_erp A, 0xFA
	jr nz, Voice_Poly_NoteOn_AssignSlot
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x840
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa200
	jr Voice_Poly_NoteOn_ReleaseNext

; Second half of the release register pair: TG reg 0x20 voice slot <= 0xA280.
Voice_Poly_NoteOn_ReleaseNext:
	nop
	nop
	nop
	res	7, (P6:8)
	ldto_berp A, 0xFB
	extz wa
	add wa, 0x800
	ld (ToneGen_RegAddrLatch:24), wa
	nop
	set	7, (P6:8)
	ldw (ToneGen_RegDataPort:24), 0xa280
	jr Voice_Poly_NoteOn_ReleaseDone

; Clears bit 7 of the owner byte (slot now free) and returns. Only ONE slot is ever released
; per note-off -- the loop exits here, it does not continue scanning for duplicates.
Voice_Poly_NoteOn_ReleaseDone:
	nop
	nop
	nop
	ldto_berp A, 0xFB
	extz wa
	lda xbc, (15124:16)
	extz xwa
	add xwa, xbc
	resm 7, (xwa)
	jr Voice_Poly_NoteOn_Epilogue

; ++slot; repeat the release scan while slot < 8. The name is misleading; nothing is assigned.
Voice_Poly_NoteOn_AssignSlot:
	inc1b_erp 0xFB
	cp_erpb 0xFB, 0x08
	jr c, Voice_Poly_NoteOn_ReleaseCheck

; pop xiz; ret.
Voice_Poly_NoteOn_Epilogue:
	pop xiz
	ret

; (0x4366) = WA. Two instructions. Called only from the top of Audio_Process_DSP to publish
; the ring byte count sampled at the start of the pass; nothing in this region reads 0x4366
; back, so it exists for the debugger / for code outside the region.
DSP_StoreBufferCount:
	ld (17254:16), wa
	ret

