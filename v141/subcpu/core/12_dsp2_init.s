; ===========================================================================
; DSP2_Init - Initialize second DSP chip
; ===========================================================================
; Entry: None
; Exit:  DSP2 state cleared
; Notes: Clears the shared DSP command-ring control block at 0x3B60-0x3B64
;        (0x3B60 write index, 0x3B62 read index, 0x3B64 count)
;        Called during Audio_System_Init after primary DSP initialization
;        ★ CORRECTED: this used to read "Clears DSP2 control variables".  Despite the
;        routine name the block is not DSP2-specific -- it is the command ring for BOTH
;        DSPs' traffic, as the prose note below already states.
; ===========================================================================
; ALREADY NAMED -- doc header only.
; Clears the DSP command ring control block: (0x3B64) = 0 (count), (0x3B62) = 0 (read index),
; (0x3B60) = 0 (write index). Note it does NOT clear the stream-state words 0x4488/0x448A/
; 0x448C, which is relevant to the wedge described under Audio_Process_DSP. Called once from
; the boot path (kn5000_subprogram_v142.s:148) after the primary DSP is initialised. The name
; is a slight misnomer -- the block is the ring for BOTH DSPs' command traffic, not DSP2 state.
DSP2_Init:	.include "includes/generated/cc900/DSP2_Init.s"	; C: cc900/dsp2_init.c

; --- 0x03582E-0x03582F  Voice_Poly_NoteOn_Data -- two bytes 0x0E 0x0E
; Two `ret` opcodes stranded between Voice_Poly_NoteOn's epilogue and DSP_RingBuf_Read.
; Almost certainly alignment padding produced by the original toolchain (0x0E is `ret`), not
; a table. Not referenced by anything.
; ★ CORRECTED 2026-09-25: the first byte IS referenced -- entries 1, 2 and 3 of
; DSP2_InitTask_PtrTable (subcpu_data_tables.s) are `.long` pointers to it, beside entry 0 =
; DSP2_Init.  So it is a do-nothing task body, a lone `ret`, and is written as one; the
; second 0x0E is the unreferenced one.  Renamed from Voice_Poly_NoteOn_Data.  (The pointer
; table itself has no reader in the payload -- see its header -- so this stub is reached, if at
; all, only through a computed address.)
DSP2_InitTask_NullStub:	.include "includes/generated/cc900/DSP2_InitTask_NullStub.s"	; C: cc900/dsp2_init.c
	ret				; not referenced (padding)

; ALREADY NAMED -- doc header only.
; Pops one byte from a 2 KB ring. Entry XWA = control block. Exit HL = byte (0..0xFF), or
; 0xFFFF when the ring is empty -- callers test with a SIGNED compare (`cps hl,0` / `jr lt`),
; so 0xFFFF is "empty" and any real byte is >= 0. Advances (XWA+2) and decrements (XWA+4);
; index masked with 0x7FF; data area starts at XWA+6.
DSP_RingBuf_Read:
	cpw (xwa + 4), 0x0
	jr z, DSP_RingBuf_Read_Empty
	lda xbc, (xwa + 2)
	ld de, (xbc)
	incw 1, (xbc)
	and de, 0x7FF
	ld bc, de
	extz xbc
	inc 6, xbc
	add xbc, xwa
	ld c, (xbc)
	extz bc
	ld hl, bc
	decm 1, (xwa + 4)
	jr DSP_RingBuf_Read_Return

; HL = 0xFFFF.
DSP_RingBuf_Read_Empty:
	ldw hl, 0xFFFF

; ret.
DSP_RingBuf_Read_Return:
	ret

; --- 0x035859-0x03585E  DSP_RingBuf3B60_Read -- six bytes f1 60 3b 30 68 d1
; Also not a table. `f1 60 3b 30` is `lda XWA,0x3B60` and `68 xx` is a `jr` -- this is the
; tail of a routine the linker placed here, or padding that happens to disassemble. Left
; alone; nothing references it.
; CORRECTED 2026-09-25: not padding.  The two instructions are a complete wrapper: XWA = 0x3B60,
; the control block of a ring whose indices (0x3B60/0x3B62) the routine ending at 0x03582D zeroes,
; then `jr` lands EXACTLY on the entry of DSP_RingBuf_Read (0x035830) -- a tail call.  Renamed
; from DSP_RingBuf_Read_Data.  Still no caller found (no symbolic or 24-bit reference).
DSP_RingBuf3B60_Read:
	lda	xwa, (0x3b60:16)
	jr	DSP_RingBuf_Read

; ALREADY NAMED -- doc header only.
; Drains the ring until DSP_RingBuf_Read returns 0xFFFF, then FORCES the read index to equal
; the write index ((XIZ) = (XIZ+2)) -- i.e. it is a hard resynchronise, not a byte skip: the
; write index is copied over the ring's index-0 word. Entry XWA = control block, no output.
; This is the recovery action for every malformed or unhandled message in Audio_Process_DSP.
; Note the consequence: one bad length byte discards everything currently queued.
DSP_RingBuf_Skip:
	push xiz
	ld xiz, xwa
	ld xwa, xiz
	calr DSP_RingBuf_Read
	cp hl, 0:i3
	jr lt, DSP_RingBuf_Skip_Epilogue

; Read-until-empty loop body.
DSP_RingBuf_Skip_Loop:
	ld xwa, xiz
	calr DSP_RingBuf_Read
	cp hl, 0:i3
	jr ge, DSP_RingBuf_Skip_Loop

; (XIZ) = (XIZ+2); pop; ret.
DSP_RingBuf_Skip_Epilogue:
	ld wa, (xiz + 2)
	ld (xiz), wa
	pop xiz
	ret

; --- RingBuffer_Write2K: Write a byte to a 2KB circular buffer ---
; Entry: XWA = pointer to buffer control block
;        C = byte to write
; Same as RingBuffer_Write4K but wraps at 2047 (AND 0x07FF).
; Pushes one byte into a 2 KB ring. Entry XWA = control block, C = byte. Advances (XWA) and
; increments (XWA+4); index masked with 0x7FF. No caller reaches it by name in this build --
; Audio_CmdHandler_60_7F has the same code inlined at DSP_RingBuf_Enqueue -- so it is either
; dead or reached through a pointer table outside this region.
DSP_RingBuf_Write2K:
	ld	xde, xwa
	ld	hl, (xde)
	incw	1, (xde)
	and	hl, 2047
	ld	de, hl
	extz	xde
	inc	6, xde
	add	xde, xwa
	ld	(xde), c
	incw	1, (xwa+4)
	ret

; ALREADY NAMED -- doc header only.
; Entry 3 of CMD_DISPATCH_TABLE, i.e. every inter-CPU command byte in 0x60..0x7F.
; Entry (stack, set up by the dispatcher): (XSP+4) = byte count, (XSP+6) = pointer to the
; bytes received from the main CPU. Exit HL = 0 always.
; It does two things: it maintains the bulk-stream accounting in 0x4488/0x448A/0x448C, and
; then unconditionally copies all `count` bytes into the DSP ring at 0x3B60.
;   (0x448C) == 0  -> CmdHandler60_StreamSizeC : this chunk should be a 32-byte stream header
;   (0x448C) == 1  -> CmdHandler60_StreamSizeA : accumulate
;   (0x448C) >= 2  -> IX = 0, then falls into StreamSizeA anyway
; ★ This routine contains the ONLY two instructions in the whole firmware that can clear
;   0x448C: `ld (0x448C),0x0000` at 0x0358C7 and at 0x035904. See the wedge note under
;   Audio_Process_DSP.
Audio_CmdHandler_60_7F:	.include "includes/generated/cc900/Audio_CmdHandler_60_7F.s"	; C: cc900/dsp2_init.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	CmdHandler60_StreamSizeA, Audio_CmdHandler_60_7F + 24
	.set	CmdHandler60_StreamSizeB, Audio_CmdHandler_60_7F + 46
	.set	CmdHandler60_StreamSizeC, Audio_CmdHandler_60_7F + 60
	.set	DSP_CmdHandler_StateReset, Audio_CmdHandler_60_7F + 107
	.set	DSP_EnqueueOrReturn, Audio_CmdHandler_60_7F + 119
	.set	DSP_RingBuf_Enqueue, Audio_CmdHandler_60_7F + 125
	.set	DSP_Enqueue_ReturnOK, Audio_CmdHandler_60_7F + 160

; ALREADY NAMED -- doc header only.
; HL = ((XWA[5] & 0x7F) << 7) | (XWA[6] & 0x7F). Applied to the 8-byte header copy at 0x4368,
; so it reads header bytes 0x436D and 0x436E. MIDI-style 7-bits-per-byte packing.
Extract_14Bit_PayloadSize:	.include "includes/generated/cc900/Extract_14Bit_PayloadSize.s"	; C: cc900/dsp2_init.c

; --- Pack3x7bit: Extract and pack three 7-bit fields ---
; Entry: XWA = pointer to a 4-byte structure
;   byte[1] bits 6:0 -> XHL bits 20:14
;   byte[2] bits 6:0 -> XHL bits 13:7
;   byte[3] bits 6:0 -> XHL bits 6:0
; Exit: XHL = packed 21-bit value
; ALREADY NAMED -- doc header only.
; XHL = (XWA[1] & 0x7F) << 14 | (XWA[2] & 0x7F) << 7 | (XWA[3] & 0x7F), a 21-bit value. Used
; where a DSP parameter needs more than 14 bits. No caller inside this region.
DSP_Pack3x7bitFields:	.include "includes/generated/cc900/DSP_Pack3x7bitFields.s"	; C: cc900/dsp2_init.c

; ALREADY NAMED -- doc header only.
; HL = ((XWA[2] & 0x7F) << 7) | (XWA[3] & 0x7F). On the header copy that is bytes 0x436A and
; 0x436B. Used by DSP_Cmd2B_VoiceParamWrite for the parameter index.
Extract_14Bit_VoiceParam:	.include "includes/generated/cc900/Extract_14Bit_VoiceParam.s"	; C: cc900/dsp2_init.c

; ALREADY NAMED -- doc header only.
; Pops exactly seven bytes from the ring (XWA = control block) into 0x4369..0x436F. It does
; NOT check for underflow: DSP_RingBuf_Read's 0xFFFF sentinel is stored as its low byte 0xFF,
; so a starved ring yields a header of all-0xFF rather than an error. The caller has already
; range-checked the message length, which is why this is safe in the normal case -- and why
; it is not safe if the length byte itself is garbage.
DSP_Cmd_DequeueHeader:
	push xiz
	ld xiz, xwa
	ld xwa, xiz
	calr DSP_RingBuf_Read
	ld (17257:16), l
	ld xwa, xiz
	calr DSP_RingBuf_Read
	ld (17258:16), l
	ld xwa, xiz
	calr DSP_RingBuf_Read
	ld (17259:16), l
	ld xwa, xiz
	calr DSP_RingBuf_Read
	ld (17260:16), l
	ld xwa, xiz
	calr DSP_RingBuf_Read
	ld (17261:16), l
	ld xwa, xiz
	calr DSP_RingBuf_Read
	ld (17262:16), l
	ld xwa, xiz
	calr DSP_RingBuf_Read
	ld (17263:16), l
	pop xiz
	ret

; ALREADY NAMED -- doc header only.
; Loads a complete 290-byte effect configuration out of the ring into the live config buffer.
; Entry XWA = ring control block. Exit HL = 0 on success, 0xFFFF on rejection.
; Guard: ((0x436D) << 7) + (0x436E) must equal 0x122 (290) exactly; otherwise the whole
; message is discarded with DSP_RingBuf_Skip and 0xFFFF returned.
; On success it reads, in order: 8 bytes into DSP_GetConfigBuffer() (0x448E), then for each
; of the five slots 0x38 bytes into EFF_GetSlotBuffer(slot), then two trailing bytes that are
; read and thrown away. 8 + 5*56 + 2 = 290, which is where the size guard comes from.
; Called only from DSP_CmdHandler_2D when header byte 0x4369 == 0 and 0x436A == 0x09.
DSP_Cmd_LoadEffectPreset:
	lda xsp, (xsp - 10)
	push xiz
	ld (xsp + 10), xwa
	ld a, (17261:16)
	extz wa
	ld bc, wa
	sll bc, 7
	ld a, (17262:16)
	extz wa
	add wa, bc
	cp wa, 0x122
	jr nz, DSP_LoadEffPreset_Loop3Next
	call DSP_GetConfigBuffer
	ld (xsp + 6), xhl
	ldw (xsp + 4), 0x8
	ld iz, 0:i3
	cp iz, (xsp + 4)
	jr nc, DSP_LoadEffPreset_Loop1Next

; The 8 header bytes.
DSP_LoadEffPreset_Loop1:
	ld xwa, (xsp + 10)
	calr DSP_RingBuf_Read
	ld xwa, (xsp + 6)
	ld (xwa+), l
	ld (xsp + 6), xwa
	inc 1, iz
	cp iz, (xsp + 4)
	jr c, DSP_LoadEffPreset_Loop1

; Sets the per-slot byte count to 0x38 and starts the slot loop (slot < 5).
DSP_LoadEffPreset_Loop1Next:
	ldw (xsp + 4), 0x38
	ldiw_erp 0xFA, 0
	cpi3_erpw 5, 0xFA
	jr nc, DSP_LoadEffPreset_Loop3A

; Per-slot: buffer = EFF_GetSlotBuffer(slot).
DSP_LoadEffPreset_Loop2:
	ldto_werp WA, 0xFA
	call EFF_GetSlotBuffer
	ld (xsp + 6), xhl
	ld iz, 0:i3
	cp iz, (xsp + 4)
	jr nc, DSP_LoadEffPreset_Loop3

; Inner byte loop for one slot.
DSP_LoadEffPreset_Loop2Next:
	ld xwa, (xsp + 10)
	calr DSP_RingBuf_Read
	ld xwa, (xsp + 6)
	ld (xwa+), l
	ld (xsp + 6), xwa
	inc 1, iz
	cp iz, (xsp + 4)
	jr c, DSP_LoadEffPreset_Loop2Next

; ++slot; repeat while slot < 5.
DSP_LoadEffPreset_Loop3:
	inc1w_erp 0xFA
	cpi3_erpw 5, 0xFA
	jr c, DSP_LoadEffPreset_Loop2

; Two trailing bytes consumed and discarded; HL = 0.
DSP_LoadEffPreset_Loop3A:
	ld xwa, (xsp + 10)
	calr DSP_RingBuf_Read
	ld xwa, (xsp + 10)
	calr DSP_RingBuf_Read
	ld hl, 0:i3
	jr DSP_LoadEffPreset_Epilogue

; Size-guard failure: DSP_RingBuf_Skip, HL = 0xFFFF.
DSP_LoadEffPreset_Loop3Next:
	ld xwa, (xsp + 10)
	calr DSP_RingBuf_Skip
	ldw hl, 0xFFFF

; Restore frame, ret.
DSP_LoadEffPreset_Epilogue:
	pop xiz
	lda xsp, (xsp + 10)
	ret

; ALREADY NAMED -- doc header only.
; Reads (0x436E) payload bytes from the ring into the buffer at XBC, byte by byte, and counts
; how many DIFFER from what is already there -- note it counts differences but does NOT write
; the new value; the destination is left untouched. Entry XWA = ring control block,
; XBC = destination (0x4370 for 0x2B/0x2C, the slot buffer for 0x2D).
; Exit: HL = (0x436F) if (0x436F) != 0xFF or if two or more bytes differed, else HL = 0.
; So 0xFF in the header's status byte means "reply only if this is actually a change", with a
; deliberate one-byte tolerance. The result is discarded by the 0x2B and 0x2C paths and is
; used only by CmdHandler2D_PathA, which feeds it to DSP_ApplyConfig as E.
DSP_RingBuf_ReadAndCompare:
	dec 8, xsp
	push xiz
	ld (xsp + 4), xbc
	ld (xsp + 8), xwa
	ld iz, 0:i3
	jr DSP_RingBuf_Compare_MismatchPath

; Read one byte, compare with (XWA), bump the mismatch counter on inequality.
DSP_RingBuf_Compare_Loop:
	ld xwa, (xsp + 8)
	calr DSP_RingBuf_Read
	ld xwa, (xsp + 4)
	cp (xwa), l
	jr z, DSP_RingBuf_Compare_MatchPath
	inc1w_erp 0xFA

; Advance the destination pointer and the index (taken on both match and mismatch).
DSP_RingBuf_Compare_MatchPath:
	ld xwa, (xsp + 4)
	ld (xwa+), l
	ld (xsp + 4), xwa
	inc 1, iz

; Loop condition against (0x436E), then the two result tests. The two "Match"/"Mismatch"
; names are the wrong way round; see [UNCERTAIN].
DSP_RingBuf_Compare_MismatchPath:
	ld a, (17262:16)
	extz wa
	cp iz, wa
	jr c, DSP_RingBuf_Compare_Loop
	cp (17263:16), 255
	jr z, DSP_RingBuf_Compare_LoopNext
	cpi3_erpw 2, 0xFA
	jr c, DSP_RingBuf_Compare_FoundPath

; HL = (0x436F) -- the "report the header's status byte" exit.
DSP_RingBuf_Compare_LoopNext:
	ld l, (17263:16)
	jr DSP_RingBuf_Compare_Epilogue

; HL = 0 -- the "identical, suppress" exit.
DSP_RingBuf_Compare_FoundPath:
	ld l, 0x0:opc

; pop; ret.
DSP_RingBuf_Compare_Epilogue:
	pop xiz
	inc 8, xsp
	ret

