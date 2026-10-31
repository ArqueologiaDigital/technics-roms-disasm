; ===========================================================================
; InterCPU_Latch_Setup - Setup inter-CPU communication via latches
; ===========================================================================
; Entry: None
; Exit:  DMA channels and interrupt handlers configured
; Notes: Configures interrupt priority for DMA channels 0-3
;        Sets up MicroDMA for inter-CPU latch communication at 0x120000
;        Initializes DMA_XFER_STATE and CMD_PROCESSING_STATE to 0
; ===========================================================================
InterCPU_Latch_Setup:
	and	(INTET23:8), 0xf8
	res	2, (T8RUN:8)
	lda	xbc, (INTETC01:8)
	ld a, (xbc)
	and a, 0xF8
	or a, 0x5
	ld (xbc), a
	lda	xbc, (INTETC23:8)
	ld a, (xbc)
	and a, 0xF8
	or a, 0x5
	ld (xbc), a
	lda	xbc, (INTE0AD:8)
	ld a, (xbc)
	and a, 0xF8
	set 0, a
	ld (xbc), a
	ld (TREG2:8), 0x14:io
	lda xwa, (0x120000:24)
	ldc_cr32 xwa, 0x28
	ld a, 0x8:opc
	ldc_cr8 a, 0x4A
	lda xwa, (0x120000:24)
	ldc_cr32 xwa, 0x00
	ld a, 0x0:opc
	ldc_cr8 a, 0x42
	ld (DMA_XFER_STATE:16), 0
	ld (CMD_PROCESSING_STATE:16), 0
	ret

; ===========================================================================
; InterCPU_DMA_Send - Send data via DMA to main CPU
; ===========================================================================
; Entry: XDE = source data pointer
;        BC = byte count
;        A = command/channel identifier
; Exit:  Data transferred to main CPU via inter-CPU latch
; Notes: Splits large transfers into 32-byte chunks
;        Used by tone generator and audio subsystem for command responses
; ===========================================================================
InterCPU_DMA_Send:
	dec 6, xsp
	pushw iz
	ld (xsp + 2), xde
	ld iz, bc
	ld (xsp + 6), a
	cp iz, 0x20
	jr ule, DMA_Send_Final

DMA_Send_Loop:
	ld a, (xsp + 6)
	extz wa
	ldw bc, 0x20
	ld xde, (xsp + 2)
	calr InterCPU_DMA_SendDataPacket
	ld xwa, 0x20
	add (xsp + 2), xwa
	sub iz, 0x20
	cp iz, 0x20
	jr ugt, DMA_Send_Loop

DMA_Send_Final:
	ld a, (xsp + 6)
	extz wa
	ldto_berp C, 0xF8
	extz bc
	ld xde, (xsp + 2)
	calr InterCPU_DMA_SendDataPacket
	popw iz
	inc 6, xsp
	ret

; ===========================================================================
; InterCPU_DMA_SendDataPacket - Transfer a single chunk of data to main CPU
; ===========================================================================
; Entry: XDE = source data pointer
;        BC = byte count (must be non-zero)
;        A = command/channel identifier (bits 7-5 used for dispatch)
; Exit:  Data transferred via DMA channel 2
; Notes: Helper for InterCPU_DMA_Send - handles one transfer operation.
;        Waits for MSTAT1 handshake, sets up DMA, then waits for completion.
;        Command byte format: (A << 5) | (length - 1)
; ===========================================================================
; InterCPU_DMA_SendDataPacket: Sends one sub->main data packet of 1..32 bytes: after the MSTAT1 (PD bit 4) handshake
;   it writes the header byte (A << 5) | (BC - 1) to the latch 0x120000, then streams the BC bytes at XDE by micro-DMA
;   2 and waits until DMA_XFER_STATE returns to 0; BC = 0 returns at once. Basis: callers + body -- InterCPU_DMA_Send
;   splits every transfer into 32-byte packets (DMA_Send_Loop) plus the remainder (DMA_Send_Final).
InterCPU_DMA_SendDataPacket:
	cp c, 0:i3
	ret z
	ld ix, 0:i3

DMA_Chunk_Start:
	bit	4, (PD:8)	; MSTAT1 - test if Main CPU is requesting handshake
	jr z, DMA_Chunk_Wait_MSTAT1_Clear
	res	0, (PD:8)	; SSTAT0 - clear to acknowledge Main CPU handshake request
	ld (DMA_XFER_STATE:16), 1
	ld l, c
	dec 1, l
	sll a, 5
	or a, l
	ld (0x120000:24), a
	ld ix, 0:i3

DMA_Chunk_Transfer:
	bit	4, (PD:8)	; MSTAT1 - wait for Main CPU to clear (data ready to receive)
	jr nz, DMA_Chunk_Wait_MSTAT1_Set
	set	0, (PD:8)	; SSTAT0 - set to signal ready to receive DMA data
	ldc_cr32 xde, 0x08
	extz bc
	ldc_cr16 bc, 0x48
	ld (258:16), 22
	set	2, (T8RUN:8)
	cp (DMA_XFER_STATE:16), 0
	ret z

DMA_Chunk_Wait:
	cp (DMA_XFER_STATE:16), 0
	jr nz, DMA_Chunk_Wait
	ret

; Retry counter for DMA_Chunk_Start, i.e. the E0/chunk path SPECIFICALLY (the E2 and E3
; paths have their own gates, E2_Wait_MSTAT1_Set and E3_Wait_MSTAT1_Clear/Set).  Spins back
; while MSTAT1 is still low; gives up after 60001 tries (compare 0xEA60).
DMA_Chunk_Wait_MSTAT1_Clear:
	ld hl, ix
	inc 1, ix
	cp hl, 0xEA60
	jr ule, DMA_Chunk_Start
	ret

; Retry counter for DMA_Chunk_Transfer on the same E0/chunk path.  Spins back while MSTAT1
; is still high; on timeout it forces SSTAT0 before returning.
DMA_Chunk_Wait_MSTAT1_Set:
	ld wa, ix
	inc 1, ix
	cp wa, 0xEA60
	jr ule, DMA_Chunk_Transfer
	set	0, (PD:8)	; SSTAT0 - timeout recovery: force ready state before exit
	ret

; Sends the single command byte 0xE3 to the main CPU over the 0x120000 latch, with the same
; two-phase MSTAT1 handshake InterCPU_DMA_SendDataPacket uses but no payload and no micro-DMA.
; Gate 1 (0x020D15): wait for PD bit 4 (MSTAT1, SFR 0x34) to be HIGH; drop SSTAT0 (PD bit 0)
; and write 0xE3 to 0x120000. Gate 2 (0x020D23): wait for MSTAT1 to go LOW, then raise
; SSTAT0 and return. Each gate spins through E3_Wait_MSTAT1_Clear (0x020D2C) /
; E3_Wait_MSTAT1_Set (0x020D37), which give up after 60001 iterations (compare 0xEA60);
; on the gate-1 timeout it returns having sent nothing, on the gate-2 timeout it raises
; SSTAT0 first. BC is used as the retry counter. No caller found by branch-target scan.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from InterCPU_LatchProtocol_Opaque.
InterCPU_Send_E3_Command:
	ld	bc, 0:i3
; Poll MSTAT1 high, then drop SSTAT0 and write 0xE3 to the latch at 0x120000.
InterCPU_E3_Gate1:
	bit	4, (PD:8)
	jr	z, E3_Wait_MSTAT1_Clear
	res	0, (PD:8)
	ld	(1179648:24), 227
; Poll MSTAT1 low, then raise SSTAT0 and return.
InterCPU_E3_Gate2:
	bit	4, (PD:8)
	jr	nz, E3_Wait_MSTAT1_Set
InterCPU_E3_RaiseSSTAT0:
	set	0, (PD:8)
	ret

; Retry counter for gate 1 of the 0xE3 send; spins back to 020D15h while MSTAT1 is still low, gives up after 60001 tries.
E3_Wait_MSTAT1_Clear:
	ld	wa, bc
	inc	1, bc
	cp	wa, 60000
	jr	ule, InterCPU_E3_Gate1
	ret

; Retry counter for gate 2 of the 0xE3 send; spins back to 020D23h while MSTAT1 is still high.
E3_Wait_MSTAT1_Set:
	ld	wa, bc
	inc	1, bc
	cp	wa, 60000
	jr	ugt, InterCPU_E3_RaiseSSTAT0
	jr	InterCPU_E3_Gate2

; Sends command byte 0xE2 followed by a fixed 10-byte parameter block staged at 010D4h (XWA/XDE/BC) via micro-DMA ch2. Sibling of InterCPU_E1_DMA_Transfer.
InterCPU_E2_DMA_Transfer:
	; Converted from a 26-byte `.byte` run. Framing: unidasm; every
	; instruction re-encoded and the whole run compared byte for byte.
	; 9 instructions, of which 2 needed a spelling search because
	; llvm-mc --disassemble refuses them (it can still ASSEMBLE them).
	ld	ix, 0:i3
	cp	(DMA_XFER_STATE:16), 0
	jr	z, E2_DMA_Ready

; Spins while the TX-state flag (DMA_XFER_STATE) is non-zero, i.e. a previous micro-DMA burst is still running.
E2_Wait_DMA_Idle:
	ld	hl, ix
	inc	1, ix
	cp	hl, 60000
	ret	ugt
	cp	(DMA_XFER_STATE:16), 0
	jr	nz, E2_Wait_DMA_Idle

; TX engine idle: assert SSTAT0, mark busy, push the 0xE2 header into the latch.
E2_DMA_Ready:
	res	0, (PD:8)
	ld	(DMA_XFER_STATE:16), 1
	ld	(1179648:24), 226
	ld	ix, 0:i3
InterCPU_E2_Gate2:
	bit	4, (PD:8)
	jr	nz, E2_Wait_MSTAT1_Set

; Header acknowledged: stage the 10-byte block at 010D4h, program DMAS2/DMAC2/DMA2V and start timer 2.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
E2_Start_Transfer:
	set	0, (PD:8)
	lda	xhl, (0x10d4:16)
	ld	(xhl), xwa
	ld	(xhl+4), xde
	ld	(xhl+8), bc
	.byte	0xeb, 0x2e, 0x08	; ldc DMAS2,XHL  (unidasm; no llvm-mc spelling)
	ldw	wa, 10
	.byte	0xd8, 0x2e, 0x48	; ldc cr[0x48],WA -- word to control register 0x48 (unidasm prints it as
				; `unknown`); the DMAC2 count per this routine's header.  No llvm-mc spelling.
	ld	(0x102:16), 22
	set	2, (T8RUN:8)
	set	7, (0x4fe:16)
; Tail of InterCPU_E2_DMA_Transfer: spins on DMA_XFER_STATE (0x10E8) until the micro-DMA
; channel-2 completion ISR (0x020F01) zeroes it. NO TIMEOUT -- see the findings.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
InterCPU_E2_Wait_DMA_Done:
	cp	(0x10e8:16), 0
	ret	z
InterCPU_E2_Wait_DMA_Done_Spin:
	cp	(0x10e8:16), 0
	jr	nz, InterCPU_E2_Wait_DMA_Done_Spin
	ret

; Retry counter for the 0xE2 header acknowledge; spins back to 020D6Dh while MSTAT1 is still high.
E2_Wait_MSTAT1_Set:
	ld	hl, ix
	inc	1, ix
	cp	hl, 60000
	jr	ule, InterCPU_E2_Gate2
	set	0, (PD:8)
	ret

; ===========================================================================
; InterCPU_E1_DMA_Transfer - E1 command bulk data transfer (Sub→Main CPU)
; ===========================================================================
; Entry: XWA = source address in sub CPU memory (kept at (0x1110): the phase-2 DMA source)
;        XDE = destination address in main CPU memory (stored at (0x10DE) with BC: the
;              6-byte header phase 1 sends, DMA channel 2 source register 0x08 = 0x10DE)
;        BC = byte count
; Exit:  Data transferred to main CPU via two-phase E1 protocol
; Notes: Called from Cmd_Check_E2_Pending to send response data.
;        Phase 1: Send E1 command + 6-byte header (dest addr, byte count)
;        Phase 2: Actual data transfer via DMA channel 2
;        Uses 60000 iteration timeout (0xEA60) for handshake waits.
;        Stores parameters at 0x1110 and 0x10DE for DMA setup.
; ===========================================================================
InterCPU_E1_DMA_Transfer:
	pushw iz
	ld iz, 0:i3
	cp (DMA_XFER_STATE:16), 0
	jr z, E1_DMA_Ready

E1_Wait_DMA_Idle:
	ld hl, iz
	inc 1, iz
	cp hl, 0xEA60
	jrl ugt, E1_Exit
	cp (DMA_XFER_STATE:16), 0
	jr nz, E1_Wait_DMA_Idle

E1_DMA_Ready:
	ld iz, 0:i3

E1_Check_MSTAT1:
	bit	4, (PD:8)	; MSTAT1 - test if Main CPU is initiating E1 transfer
	jrl z, E1_Timeout_Retry
	res	0, (PD:8)	; SSTAT0 - clear to acknowledge E1 command from Main CPU
	ld (DMA_XFER_STATE:16), 2
	ld (0x120000:24), 0xe1
	ld iz, 0:i3

E1_Start_Transfer:
	bit	4, (PD:8)	; MSTAT1 - wait for Main CPU to clear (header data ready)
	jrl nz, E1_Busy_Wait
	set	0, (PD:8)	; SSTAT0 - set to signal ready to receive DMA header
	lda xhl, (4368:16)
	ld (xhl), xwa
	lda xwa, (4318:16)
	ld (xwa), xde
	ld (xhl + 4), bc
	ld (xwa + 4), bc
	ldc_cr32 xwa, 0x08
	ld wa, 6:i3
	ldc_cr16 wa, 0x48
	ld (258:16), 22
	set	2, (T8RUN:8)
	cp (DMA_XFER_STATE:16), 1
	jr z, E1_Delay_Loop1

E1_Wait_State1:
	cp (DMA_XFER_STATE:16), 1
	jr nz, E1_Wait_State1

E1_Delay_Loop1:
	ld iz, 0:i3
	cp iz, 0xC8
	jr nc, E1_Phase2_Setup

E1_Delay1:
	nop
	inc 1, iz
	cp iz, 0xC8
	jr c, E1_Delay1

E1_Phase2_Setup:
	lda xwa, (4368:16)
	ld xbc, (xwa)
	ldc_cr32 xbc, 0x08
	ld wa, (xwa + 4)
	ldc_cr16 wa, 0x48
	ld (258:16), 22
	set	2, (T8RUN:8)
	cp (DMA_XFER_STATE:16), 0
	jr z, E1_Delay_Loop2

E1_Wait_Complete:
	cp (DMA_XFER_STATE:16), 0
	jr nz, E1_Wait_Complete

E1_Delay_Loop2:
	ld iz, 0:i3
	cp iz, 0xC8
	jr nc, E1_Done

E1_Delay2:
	nop
	inc 1, iz
	cp iz, 0xC8
	jr c, E1_Delay2

E1_Done:
	jr E1_Exit

E1_Timeout_Retry:
	ld hl, iz
	inc 1, iz
	cp hl, 0xEA60
	jrl ule, E1_Check_MSTAT1
	jr E1_Exit

E1_Busy_Wait:
	ld hl, iz
	inc 1, iz
	cp hl, 0xEA60
	jrl ule, E1_Start_Transfer
	set	0, (PD:8)	; SSTAT0 - timeout recovery: force ready state before exit

E1_Exit:
	popw iz
	ret


; ----------------------------------------------------------------------------
; INT0_HANDLER - External Interrupt 0 Handler (Inter-CPU Command Reception)
; Entry: Triggered when main CPU sends command via latch at 0x120000
; Notes: Reads command byte from latch, dispatches based on value:
;        0xE1 = Start E1 command (6 bytes, state 2) - bulk data transfer setup
;        0xE2 = Start E2 command (10 bytes, state 3) - extended data transfer
;        0xE3 = Payload ready signal (sets PAYLOAD_LOADED_FLAG bit 6)
;        Other = Standard command (1-32 bytes based on bits 4-0, state 1)
;
; ASYMMETRY WITH THE MAIN CPU'S INT0_HANDLER (0xEF3525 in the v9/v10 program
; ROM, 0xEF34FB in v7).  Both ISRs sit on the same kind of latch (IC22 here at
; 0x120000, IC23 the other way) and both are entered once per byte written by
; the other side.  The difference is what happens to the PAYLOAD bytes:
;   this side  - INT0_Start_DMA writes DMA0V (SFR 0x0100) = 10 = the INT0
;                vector number (subcpu_vectors.s), so once the header has been
;                parsed the payload bytes are consumed by HARDWARE micro-DMA
;                and never dispatch this ISR;
;   main side  - DMA0V is never armed at all; every payload byte re-enters the
;                main ISR, which pulls it with a SOFTWARE micro-DMA request
;                (DMAR, SFR 0x0109, bit 0).
; The main-side ISR therefore carries a re-entrancy hazard on HEADER bytes,
; documented above its INT0_HANDLER; it has only ever been observed in
; emulation, under a since-removed /INT0 re-assertion in the CPU model.  Armed
; DMA0V keeps the payload bytes on this side out of this ISR entirely, so there
; is no analogue of it here.  The same non-atomic SHAPE is present, though: the
; MSTAT0 gate is tested before the latch read and SSTAT1 is cleared only at
; INT0_Ack, at the end.
; ----------------------------------------------------------------------------
INT0_HANDLER:	; 20E86
	push xwa
	bit	2, (PD:8)	; MSTAT0 - test if Main CPU is currently sending data
	jr nz, INT0_Exit
	ld a, (0x120000:24)
	ld (BYTE_FROM_MAINCPU_LATCH:16), a
	cp a, 0xE1
	jr nz, INT0_Check_E2
	ld (CMD_PROCESSING_STATE:16), 2	; E1 command - state 2
	lda xwa, (4374:16)	; E1 data buffer
	ld (4324:16), xwa	; Save DMA target
	ldc_cr32 xwa, 0x20
	ld wa, 6:i3	; 6 bytes for E1
	ldc_cr16 wa, 0x40
	jr INT0_Start_DMA

INT0_Check_E2:	; 020EB1h
	cp a, 0xE2
	jr nz, INT0_Check_E3
	ld (CMD_PROCESSING_STATE:16), 3	; E2 command - state 3
	lda xwa, (4380:16)	; E2 data buffer
	ld (4324:16), xwa
	ldc_cr32 xwa, 0x20
	ldw wa, 0xA	; 10 bytes for E2
	ldc_cr16 wa, 0x40
	jr INT0_Start_DMA

INT0_Check_E3:	; 020ECEh
	cp a, 0xE3
	jr nz, INT0_Standard_Cmd
	set 6, (PAYLOAD_LOADED_FLAG:16)	; E3 = payload ready
	jr INT0_Ack

INT0_Standard_Cmd:	; 020ED9h - standard variable-length command
	ld (CMD_PROCESSING_STATE:16), 1	; State 1
	lda xwa, (4336:16)	; Standard command buffer
	ld (4324:16), xwa
	ldc_cr32 xwa, 0x20
	ld a, (BYTE_FROM_MAINCPU_LATCH:16)
	and a, 0x1F	; Bits 4-0 = length - 1
	inc 1, a	; Add 1 for actual length
	extz wa
	ldc_cr16 wa, 0x40

INT0_Start_DMA:	; 020EF7h
	ld (256:16), 10	; Start DMA channel 0

INT0_Ack:	; 020EFCh
	res	1, (PD:8)	; SSTAT1 - clear to acknowledge command received from Main CPU

INT0_Exit:	; 020EFFh
	pop xwa
	reti


;=============================================================================
; MICRODMA_CH2_HANDLER - MicroDMA Channel 2 Completion Interrupt
;=============================================================================
; Called when DMA channel 2 transfer completes (payload data transfers).
; Manages the DMA state machine for multi-phase transfers:
;   - State 2 (two-phase) -> State 1 (waiting for phase 2)
;   - State 1 (single xfer) -> State 0 (idle)
; Stops the 8-bit TIMER 2 that paces the DMA transfers.  (Not "Timer 8": T8RUN
; is SFR 0x80 (shared/sfr_tmp94c241.s), the RUN register FOR the four 8-bit
; timers T0..T3, and bit 2 is timer 2's run bit; the old name reads like a
; misparse of the register name.  A 16-bit Timer 8 does exist on this part, but
; it runs from T16RUN and is not what is stopped here.  Corroborated by
; InterCPU_DMA_SendDataPacket, which arms DMA2V = 22 = the INTT2 vector number
; before setting T8RUN bit 2.)
;=============================================================================
MICRODMA_CH2_HANDLER:	; Channel #2 completion		; 20F01
	res	2, (T8RUN:8)
	cp (DMA_XFER_STATE:16), 1
	jr nz, MICRODMA_CH2_State2
	ld (DMA_XFER_STATE:16), 0
	jr MICRODMA_CH2_Done

MICRODMA_CH2_State2:	; 020F12h - two-phase transfer, go to state 1
	cp (DMA_XFER_STATE:16), 2
	jr nz, MICRODMA_CH2_Done
	ld (DMA_XFER_STATE:16), 1

MICRODMA_CH2_Done:	; 020F1Eh
	reti


;=============================================================================
; MICRODMA_CH0_HANDLER - MicroDMA Channel 0 Completion Interrupt
;=============================================================================
; Called when DMA channel 0 transfer completes (inter-CPU latch reads).
; This is the main command dispatcher - receives commands from main CPU
; and processes them based on CMD_PROCESSING_STATE:
;   State 1: Decode command byte (bits 7-5 = handler, bits 4-0 = length)
;   State 2: Process E1 command (two-phase transfer setup)
;   State 3: Process E2 command (transfer parameters)
;   State 4: Process E3 command (payload ready signal)
;=============================================================================
MICRODMA_CH0_HANDLER:	; 20F1Fh - Channel #0 completion (command dispatch)
	push xiz
	push xiy
	push xix
	push xhl
	push xde
	push xbc
	push xwa
	ld a, (CMD_PROCESSING_STATE:16)
	cp a, 4:i3
	jr z, CH0_State4_E1_Done
	cp a, 3:i3
	jr z, CH0_State3_E2
	cp a, 2:i3
	jr z, CH0_State2_E1
	cp a, 1:i3
	jr nz, CH0_Timer_Reset
	; State 1: Standard command processing
	pushw 0x0
	pushw 0x10F0	; Command buffer address
	ld c, (BYTE_FROM_MAINCPU_LATCH:16)
	ld a, c
	and a, 0x1F
	inc 1, a	; Length = (byte & 0x1F) + 1
	extz wa
	pushw wa
	srl c, 5	; The 3 highest bits from the byte received via maincpu latch
	             ; are used to select one of the 8 call-table entries
	ld a, c
	extz wa
	sla wa, 2	; Multiply by 4 (table entry size)
	lda xbc, (CMD_DISPATCH_TABLE:24)
	ld	xwa, (xbc+wa)
	call (xwa)	; Dispatch to handler
	inc 6, xsp
	ld (CMD_PROCESSING_STATE:16), 0
	jr CH0_Ack

CH0_State2_E1:	; 020F6Dh - E1 command phase 1 complete, start phase 2
	lda xwa, (4374:16)	; E1 data buffer
	ld xbc, (xwa)	; Get DMA destination address
	ldc_cr32 xbc, 0x20
	ld wa, (xwa + 4)	; Get DMA byte count
	ldc_cr16 wa, 0x40
	ld (256:16), 10	; Start DMA
	ld (CMD_PROCESSING_STATE:16), 4	; Move to state 4
	jr CH0_Timer_Reset

CH0_State3_E2:	; 020F88h - E2 command complete
	ld (4334:16), 255
	ld (CMD_PROCESSING_STATE:16), 0
	set	1, (PD:8)	; SSTAT1 - set to signal ready for next command from Main CPU
	set 7, (4390:16)	; Set E2 pending flag
	jr CH0_Timer_Reset

CH0_State4_E1_Done:	; 020F9Bh - E1 two-phase transfer complete
	ld (CMD_PROCESSING_STATE:16), 0
	res 7, (PAYLOAD_LOADED_FLAG:16)

CH0_Ack:	; 020FA4h
	set	1, (PD:8)	; SSTAT1 - set to signal E1 transfer complete, ready for next

CH0_Timer_Reset:	; 020FA7h - reset Timer 8 if running
	bit	2, (T8RUN:8)
	jr z, CH0_Exit
	res	2, (T8RUN:8)	; Stop timer
	nop
	nop
	set	2, (T8RUN:8)	; Restart timer

CH0_Exit:	; 020FB4h
	pop xwa
	pop xbc
	pop xde
	pop xhl
	pop xix
	pop xiy
	pop xiz
	reti

; ----------------------------------------------------------------------------
; Cmd_Check_E2_Pending - Check and process pending E2 command
; Entry: None
; Exit:  E2 data processed if pending flag set
; Notes: Called from main loop to handle deferred E2 processing
; ----------------------------------------------------------------------------
Cmd_Check_E2_Pending:	; 020FBCh
	ei 6
	lda xwa, (4390:16)
	bitm 7, (xwa)	; Check E2 pending flag
	jr z, Cmd_Check_DMA_Timeout
	resm 7, (xwa)	; Clear pending flag
	ei 0
	lda xde, (4380:16)	; E2 data buffer
	ld xwa, (xde)
	ld bc, (xde + 8)
	ld xde, (xde + 4)
	calr InterCPU_E1_DMA_Transfer	; Process E2 data

; Check for DMA timeout (stuck transfer detection)
Cmd_Check_DMA_Timeout:	; 020FD9h
	ei 0
	bit	1, (PD:8)	; SSTAT1 - test own status: if set, no DMA transfer in progress
	jr nz, Cmd_DMA_Idle
	ldc_16_cr wa, 0x40	; Get current DMA byte count
	cp (InterCPU_DmaLast_Count:16), wa	; Compare with previous
	jr nz, Cmd_DMA_Reset_Counter
	incw 1, (InterCPU_DmaStuck_Count:16)	; Increment stuck counter
	jr Cmd_DMA_Save_Count

Cmd_DMA_Reset_Counter:	; 020FEFh
	ldw (InterCPU_DmaStuck_Count:16), 0	; Reset stuck counter

Cmd_DMA_Save_Count:	; 020FF5h
	ld (InterCPU_DmaLast_Count:16), wa	; Save current count
	jr Cmd_DMA_Check_Stuck

Cmd_DMA_Idle:	; 020FFBh
	ldw (InterCPU_DmaStuck_Count:16), 0

Cmd_DMA_Check_Stuck:	; 021001h
	ld wa, (InterCPU_DmaStuck_Count:16)
	cp wa, 0xA	; Stuck for 10 iterations?
	ret ule
	; Timeout recovery - abort stuck DMA
	ldw (InterCPU_DmaStuck_Count:16), 0
	ld (256:16), 0	; Stop DMA
	ld (CMD_PROCESSING_STATE:16), 0
	set	1, (PD:8)	; SSTAT1 - timeout recovery: force ready state after DMA abort
	inc 1, (InterCPU_DmaAbort_Count:16)	; Increment error counter
	ret

