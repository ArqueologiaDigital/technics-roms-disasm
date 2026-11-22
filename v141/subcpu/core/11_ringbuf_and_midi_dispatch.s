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
RingBuf_ReadByte:	.include "includes/generated/cc900/RingBuf_ReadByte.s"	; C: cc900/ringbuf_and_midi_dispatch_ae_21a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	RingBuf_ReadByte_Empty, RingBuf_ReadByte + 37
	.set	RingBuf_ReadByte_Return, RingBuf_ReadByte + 40

; A two-instruction convenience wrapper: `lda XWA,0x2B0D` then fall into RINGBUF_READBYTE,
; i.e. "read one byte from THE MIDI ring".  It has no caller in the authoritative source.
; The ELF name RingBuf_ReadByte_Data implies data; it is code.
; ★ Renamed 2026-09-25 from RingBuf_ReadByte_Data: header: `lda XWA,0x2B0D` then RINGBUF_READBYTE -- read one byte from the MIDI ring.
RingBuf_ReadByte_MidiRing:	.include "includes/generated/cc900/RingBuf_ReadByte_MidiRing.s"	; C: cc900/ringbuf_and_midi_dispatch_b.c

; Drains a ring buffer completely and then RESETS THE WRITE INDEX to the read index.
; Input XWA = ring descriptor base.  Calls RINGBUF_READBYTE until it returns a negative value,
; then does (XIZ+0x00) = (XIZ+0x02), i.e. write := read.
; ★ This is the MIDI parser's error recovery: every "message truncated" branch of
; MIDI_Dispatch jumps here, so ONE malformed or short event discards the ENTIRE ring content
; (up to 4096 bytes of queued MIDI), not just the bad message.  8 call sites, all in
; MIDI_Dispatch.
RingBuf_SkipToEnd:	.include "includes/generated/cc900/RingBuf_SkipToEnd.s"	; C: cc900/ringbuf_and_midi_dispatch_d_6a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	RingBuf_SkipToEnd_Loop, RingBuf_SkipToEnd + 12
	.set	RingBuf_SkipToEnd_Epilogue, RingBuf_SkipToEnd + 21

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
RingBuf_Write4K:	.include "includes/generated/cc900/RingBuf_Write4K.s"	; C: cc900/ringbuf_and_midi_dispatch_d_7a.c

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
Audio_CmdHandler_00_1F:	.include "includes/generated/cc900/Audio_CmdHandler_00_1F.s"	; C: cc900/ringbuf_and_midi_dispatch.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	Audio_CmdHandler_00_1F_Loop, Audio_CmdHandler_00_1F + 7
	.set	Audio_CmdHandler_00_1F_Done, Audio_CmdHandler_00_1F + 49

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
MIDI_Dispatch:	.include "includes/generated/cc900/MIDI_Dispatch.s"	; C: cc900/ringbuf_and_midi_dispatch_d_8a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	MIDI_Dispatch_ParseStatus, MIDI_Dispatch + 15
	.set	MIDI_Status_NoteOn_Extended, MIDI_Dispatch + 142
	.set	MIDI_Status_Incomplete, MIDI_Dispatch + 202
	.set	MIDI_Status_NoteOn, MIDI_Dispatch + 210
	.set	MIDI_Status_NoteOn_Poly, MIDI_Dispatch + 268
	.set	MIDI_Status_NoteOn_Skip, MIDI_Dispatch + 279
	.set	MIDI_Status_CtrlChange, MIDI_Dispatch + 287
	.set	MIDI_Status_CtrlChange_Skip, MIDI_Dispatch + 336
	.set	MIDI_Status_ProgChange, MIDI_Dispatch + 344
	.set	MIDI_Status_ProgChange_Skip, MIDI_Dispatch + 402
	.set	MIDI_Status_ChanPressure, MIDI_Dispatch + 410
	.set	MIDI_Status_ChanPressure_Skip, MIDI_Dispatch + 459
	.set	MIDI_Status_PitchBend, MIDI_Dispatch + 466
	.set	MIDI_Status_PitchBend_Skip, MIDI_Dispatch + 514
	.set	MIDI_Status_System, MIDI_Dispatch + 521
	.set	MIDI_Status_System_Skip, MIDI_Dispatch + 569
	.set	MIDI_Status_Unknown, MIDI_Dispatch + 576
	.set	MIDI_Dispatch_NextByte, MIDI_Dispatch + 581
	.set	MIDI_Dispatch_Exit, MIDI_Dispatch + 593

; Computes the checksum word that trails the DSP1 image before it is DMAed out.
; No arguments.  Sums 0x24B8 words (0x4970 / 2) starting at (0x04531C) + 0x10 and returns
; HL = the one's complement (`cpl`) of the 16-bit total.
; Every caller immediately stores it at (0x04531C) + 0x72A8, i.e. the last word of the image.
; 4 call sites: DSP_WriteAlgoBuffer_Epilogue and three inside DSP_Reinit_VoiceSlots.
DSP_WriteCount_Compute:	.include "includes/generated/cc900/DSP_WriteCount_Compute.s"	; C: cc900/ringbuf_and_midi_dispatch_z3_2c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_WriteCount_Loop, DSP_WriteCount_Compute + 20
	.set	DSP_WriteCount_Next, DSP_WriteCount_Compute + 26

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
DSP_FlushAllSlots_ForPart:	.include "includes/generated/cc900/DSP_FlushAllSlots_ForPart.s"	; C: cc900/ringbuf_and_midi_dispatch_d_6a.c

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
DSP_ResetAlgoDefaults:	.include "includes/generated/cc900/DSP_ResetAlgoDefaults.s"	; C: cc900/ringbuf_and_midi_dispatch.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_ResetAlgoDefaults_Loop, DSP_ResetAlgoDefaults + 8

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
DSP_Reinit_VoiceSlots:	.include "includes/generated/cc900/DSP_Reinit_VoiceSlots.s"	; C: cc900/ringbuf_and_midi_dispatch_ap_34a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_Reinit_VoiceSlots_Loop1, DSP_Reinit_VoiceSlots + 75
	.set	DSP_Reinit_VoiceSlots_Loop1Next, DSP_Reinit_VoiceSlots + 104
	.set	DSP_Reinit_VoiceSlots_Loop2, DSP_Reinit_VoiceSlots + 166
	.set	DSP_Reinit_VoiceSlots_Loop2A, DSP_Reinit_VoiceSlots + 182
	.set	DSP_Reinit_VoiceSlots_Loop2B, DSP_Reinit_VoiceSlots + 209
	.set	DSP_Reinit_VoiceSlots_Loop2Next, DSP_Reinit_VoiceSlots + 219
	.set	DSP_Reinit_VoiceSlots_Loop3, DSP_Reinit_VoiceSlots + 245
	.set	DSP_Reinit_VoiceSlots_Loop3A, DSP_Reinit_VoiceSlots + 260
	.set	DSP_Reinit_VoiceSlots_Loop3Next, DSP_Reinit_VoiceSlots + 271
	.set	DSP_Reinit_VoiceSlots_OuterNext, DSP_Reinit_VoiceSlots + 323
	.set	DSP_Reinit_VoiceSlots_DMAFlush, DSP_Reinit_VoiceSlots + 344

; Scans all 26 parts and acts on the program byte at part+0x1A (0x041382).
; Only the head of the scan is inside this region: it compares part+0x1A against 0x10 and 0x50
; and branches to the per-part body at 0x0354CA (just past the region boundary) when either
; matches, otherwise to the loop-increment at 0x035551.  3 call sites outside the region.
; The 0x10 / 0x50 constants are program-byte class markers, matching the two "voice active"
; encodings used by Voice_ProgChange.
DSP_VoiceState_Dispatch:	.include "includes/generated/cc900/DSP_VoiceState_Dispatch.s"	; C: cc900/ringbuf_and_midi_dispatch_lane_23c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_VoiceState_Dispatch_Scan, DSP_VoiceState_Dispatch + 13
	.set	DSP_VoiceState_Dispatch_ActiveVoice, DSP_VoiceState_Dispatch + 58
	.set	DSP_VoiceState_Dispatch_SubPathA, DSP_VoiceState_Dispatch + 164
	.set	DSP_VoiceState_Dispatch_SubPathB, DSP_VoiceState_Dispatch + 175
	.set	DSP_VoiceState_Dispatch_LoopNext, DSP_VoiceState_Dispatch + 193
	.set	DSP_VoiceState_Dispatch_Epilogue, DSP_VoiceState_Dispatch + 203

; Resets the two DSP working-buffer write pointers to 0x007800:
;   (0x045320) = 0x00007800 ; (0x04531C) = 0x00007800
; Both are 32-bit. Companions set at boot by DSP_System_Init_Continue: (0x045310) and
; (0x045314) = 0x00050000, (0x045318) = 0x000A0000. So 0x045310..0x045323 is a block of five
; longword pointers into the DSP's own address space, of which these two are the ones that
; get rewound. Called from the audio init path (0x032186), right after DSP_Reset. No
; hardware touched. No inputs, no outputs.
DSP_ResetWriteBufferPtr:	.include "includes/generated/cc900/DSP_ResetWriteBufferPtr.s"	; C: cc900/ringbuf_and_midi_dispatch.c

; Bare `ret`. One of three consecutive 1-byte stubs; all three are still referenced by
; pointer tables elsewhere, so they are placeholders for removed features, not padding.
DSP_Stub_RetA:
	ret

; Bare `ret`.
DSP_Stub_RetB:	.include "includes/generated/cc900/DSP_Stub_RetB.s"	; C: cc900/ringbuf_and_midi_dispatch.c

; Bare `ret`.
DSP_Stub_RetC:	.include "includes/generated/cc900/DSP_Stub_RetC.s"	; C: cc900/ringbuf_and_midi_dispatch.c

; Square-law velocity -> 12-bit volume curve, computed not tabulated.
;   HL = ((WA * WA) >> 2) + 0x3F        (mul XBC,WA is a full 16x16->32; only BC is shifted)
; For the 0..0x7F range the tone generator actually feeds it, that maps 0 -> 0x003F and
; 0x7F -> 0x0FFF, i.e. exactly the 12-bit full-scale that ToneGen_SetupPercussionVoice
; hard-codes with `or (0x3B20), 4095`. Entry WA = velocity, exit HL = level. Sole caller
; ToneGen_SetupPolyVoice, which ORs the result into the staging word at 0x3B20.
DSP_VelocityToVolume:	.include "includes/generated/cc900/DSP_VelocityToVolume.s"	; C: cc900/ringbuf_and_midi_dispatch.c

; Builds the per-note effect-send word that both ToneGen setup routines OR into the staging
; word at 0x3B22. No inputs; reads two global bytes and returns HL.
;   HL = 0
;   if (0x041377) != 0 :  HL |= (0x041377) << 8
;   if (0x04137A) == 0 :  return HL
;   HL |= (0x041377)                      <-- reads 0x041377 again, NOT 0x04137A
; The second load really is from 0x041377 -- verified at byte level, 0x0355A3 is
; `c2 77 13 04 21`, and both toolchains reproduce it. See [UNCERTAIN].
DSP_GetEffectRouting:	.include "includes/generated/cc900/DSP_GetEffectRouting.s"	; C: cc900/ringbuf_and_midi_dispatch.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	DSP_GetEffectRouting_Path, DSP_GetEffectRouting + 22

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
ToneGen_SetupPolyVoice:	.include "includes/generated/cc900/ToneGen_SetupPolyVoice.s"	; C: cc900/ringbuf_and_midi_dispatch_n_17a.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	ToneGen_SetupPolyVoice_Path, ToneGen_SetupPolyVoice + 92

; The percussion variant, dispatch-table entry 1. Entry A = tone-generator voice, E = note,
; one pushed word (`retd 0x2`). Same template refill into 0x3B1C. Differences from the
; melodic path: the note is split into octave (note/12, kept in C) and pitch class
; (note - octave, bit 7 cleared); the pitch class goes into staging 0x3B2A << 8, the octave
; indexes the word table at 0x012195 which is ORed into staging 0x3B1C; the volume is the
; fixed full-scale 0xFFF rather than a velocity curve; and staging 0x3B1E takes the single
; word at 0x01217D instead of an octave-indexed one. Then the same two ToneGen writers.
ToneGen_SetupPercussionVoice:	.include "includes/generated/cc900/ToneGen_SetupPercussionVoice.s"	; C: cc900/ringbuf_and_midi_dispatch_d_9a.c

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

