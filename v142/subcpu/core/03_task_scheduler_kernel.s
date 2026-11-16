; ============================================================================
; TaskSched_TaskDescriptorTable -- the scheduler's static TASK TABLE (0x01FD98, 3 x 12 bytes)
; ============================================================================
; CORRECTED: this was labelled `DSP_ChannelConfigTable` with the comment "DSP channel
; configuration data table (42 bytes)".  Nothing in the DSP code reads it.  Its reader is
; Kernel_StartTask (0x01FFFD):
;     ld l,12 / mul8rr l,a / extz xhl / add xhl, TaskSched_TaskDescriptorTable - 12
; i.e. record = table + 12*(A-1) for task id A = 1..3 (the constant in the instruction is
; the table MINUS one record, 0x01FD8C, which is why a search for 0x01FD98 found nothing).
; Record layout, derived field by field from the loads in Kernel_StartTask:
;   +0  long   entry PC       `ld xwa,(xhl+0)` -> frame+30, the slot Kernel_ResumeTask
;                             pops with its final RET
;   +4  long   stack top      `ld xiy,(xhl+4)`; the 34-byte (0x22) context frame is built at
;                             stack top - 0x22 and stored as the descriptor's saved XSP (+4)
;   +8  word   initial SR     `ld wa,(xhl+8)` -> frame+28, popped by Kernel_ResumeTask's
;                             `pop sr`
;   +10 byte   priority       `ld a,(xhl+10)` -> descriptor +8, and selects the ready-queue head
;                             at 0x1068 + 4*priority
;   +11 byte   0              not read by Kernel_StartTask
; Entry count 3: Kernel_InitRam initialises exactly three 12-byte run-time descriptors at
; 0x1048/0x1054/0x1060 (= 0x103C + 12*A, `ld b,3`), and the six bytes after record 3 are
; independently claimed by Kernel_InitRam's two ldir copies (below), so the table cannot be
; longer.  Entry PCs resolve to: task 1 Task1_StartAudioSystem (inside PostReset_InitAudio),
; task 2 Task2_NeverSpawned (a bare RET; never spawned), task 3 Task3_EnterDspApplyLoop (`jp` to the
; DSP apply-task loop DSP_State_ApplyTask).  The three stack tops partition DRAM
; 0x040000.. as: task 1 below 0x04069A, task 3 0x04069A-0x040A9B, the scheduler's own stack
; (`ld xsp, 0x40B1E`) 0x040A9C-0x040B1D, task 2 0x040B1E-0x040C1F.
; Independent corroboration: wsa1/notes/FINDINGS-kernel-in-the-kn5000.md (section 8) aligns the
; SX-WSA1R prom_c kernel with this one instruction by instruction and pairs its "TCB template"
; operand 0xFFF980DE with this code's 0x0001FD8C (= this table - 12), and its "ROM image of the
; semaphore counts" with 0x0001FDBC (TaskSched_EventFlagInit below).
TaskSched_TaskDescriptorTable:
	.long	Task1_StartAudioSystem, Task1_StackTop	; task 1: entry, stack top
	.short	0x8800					;         initial SR
	.byte	3, 0					;         priority 3
	.long	Task2_NeverSpawned, Task2_StackTop	; task 2: entry, stack top
	.short	0x8800
	.byte	1, 0					;         priority 1
	.long	Task3_EnterDspApplyLoop, Task3_StackTop	; task 3: entry, stack top
	.short	0x8800
	.byte	3, 0					;         priority 3
; Initial values of the two EVENT flag bytes 0x1080/0x1081 (events 1, 2): Kernel_InitRam
; copies these 2 bytes there with `ld xhl, TaskSched_EventFlagInit / ld de,0x1080 / ld bc,2 /
; ldir`.  1 = "already signalled"; see TaskEvent_Signal.
TaskSched_EventFlagInit:
	.byte	1, 1
; Initial counts of the four SEMAPHORES 0x1092..0x1095 (ids 1..4): Kernel_InitRam copies these 4
; bytes with `ld xhl, TaskSched_SemaphoreInit / ld de,0x1092 / ld bc,4 / ldir`.  See
; TaskSem_GetCount, which reads them back.
TaskSched_SemaphoreInit:
	.byte	1, 1, 1, 1

Task_DequeueDispatch_Prio3:
	ld a, 0x3:opc
	jrl Kernel_RotateQueue
; A separate one-instruction routine, not dead code after the tail jump: 0x01FDC7 is the
; callback pointer (+4) of SoftTimer_Request_Boot, which SoftTimer_Register copies into soft
; timer slot 1 (0x10CA).  Kernel_ServiceSoftTimers pushes its loop-advance address and
; jumps here every time that slot's 1-tick period expires, so this RET is a no-op callback.
TaskSched_NullTimerCallback:
	ret


; INTT3 (8-bit timer 3) interrupt, entered through IntTramp_INTT3: bumps the counters at 4306 and 4165,
; runs Task_DequeueDispatch_Prio3, then leaves through TaskSwitch_Countdown.  Was INT16_TaskSwitch_Handler,
; after its trampoline slot (0x16), not an interrupt source -- the TMP94C241F has no INT16.
INTT3_TaskSwitch_Handler:
	incw 1, (4306:16)
	inc 1, (4165:16)
	pushw wa
	pushw bc
	calr Task_DequeueDispatch_Prio3
	popw bc
	popw wa
	jrl IRQ_Epilogue

; ============================================================================
; The multitasking kernel: Kernel_InitRam .. Kernel_KillTask, 0x01FDDA-0x02083A in v1.42
; ============================================================================
; ONE SOURCE FOR THREE PROCESSORS since 2026-11-06 (owner decision, register item N-8c52a3ed):
; this payload builds its kernel from the SX-WSA1R's wsa1/kernel/kernel.s, the file both WSA1
; CPUs build theirs from.  kernel_kn5000_subcpu.inc is this processor's RAM map for it and sets
; KERNEL_KN5000, which selects the per-CPU blocks; the text that stood here moved there, its
; headers under a banner naming this file, and each renamed routine records its old name
; (scripts/renaming/rename_kernel_a3.sed lists them all: TaskSched_Init is Kernel_InitRam, ...).
; The pairing and the merge are
; wsa1/notes/open9-a3-probes/kernel_a3_pairing.py and kernel_a3_merge.py (README beside them).
; The data the kernel reads (the three tables above) and the routines outside its extent
; (Task_DequeueDispatch_Prio3, INTT3_TaskSwitch_Handler above; Timer_Delay_Ticks, Timer3_Start /
; Timer3_Stop and TaskSched_Lock / TaskSched_Unlock below) stay in this file: the WSA1 kernel's
; extent ends at Kernel_KillTask on both of its CPUs, and none of these has a WSA1 partner.
	.include "kernel_kn5000_subcpu.inc"
	.include "kernel.s"

; Busy-wait delay measured in audio ticks. WA is halved, added to the free-running 32-bit
; tick counter at 0x1040, and the routine spins until 0x1040 reaches that value.
; Input: WA = 2 * number of ticks to wait. No timeout, no interrupt masking -- it depends
; entirely on Timer_AudioTick_Handler (0x01FB41) still running.
Timer_Delay_Ticks:
	srl	wa, 1
	add	wa, (4160:16)
Timer_Delay_Ticks_Loop:
	cp	wa, (4160:16)
	jr	gt, Timer_Delay_Ticks_Loop
	ret

; Start / stop the 8-bit timer 3: bit 3 of T8RUN (SFR 0x80) is timer 3's run bit (the
; MICRODMA_CH2_HANDLER header explains T8RUN).  Kernel_InitRam__install stops it, sets
; TREG3 = 0x1D and the timer-3 interrupt level, and starts it again: the scheduler's tick timer.
; ★ Renamed 2026-09-25 from IntMask_SetBit3 / IntMask_ClearBit3 -- no interrupt mask is touched.
Timer3_Start:
	set	3, (T8RUN:8)
	ret

Timer3_Stop:
	res	3, (T8RUN:8)
	ret

; incw 1,(0x10D2) -- take the scheduler lock. While 0x10D2 is non-zero Kernel_Dispatch
; (0x01FF21) returns through ContextRestore without switching tasks and IRQ_Epilogue
; (0x01FFD0) merely counts down. Unlike TASKSCHED_SOFTTIMER_SERVICE this pair does NOT
; mirror the new depth into control register 0x7C.
TaskSched_Lock:
	incw	1, (4306:16)
	ret
; decw 1,(0x10D2) -- release the scheduler lock. Nesting-safe, no reschedule on release.
TaskSched_Unlock:
	decw	1, (4306:16)
	ret
; Pop one byte from the 1 KB FIFO whose descriptor base is 0x040C2E.
; Thin wrapper: pushes IX/XDE, XDE = 0x040C2E, calls the 1K engine's GET (0x020B9D).
; Output: HL = byte (zero-extended) or 0xFFFF when the FIFO is empty.
FIFO1K_Get:
	pushw	ix
	push	xde
	lda	xde, (Payload_Bss_Start+0x1db8:24)
	calr	FIFO_Engine1K_Get
	pop	xde
	popw	ix
	ret
; Push one byte onto the 1 KB FIFO. Stack-argument calling convention (link XIZ,0;
; A = (XIZ+8)), then the 1K engine's PUT (0x020BF1).  Output: HL = free space left,
; or 0xFFFF if the FIFO was full and the byte was dropped.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO1K_Put:
	link	xiz, 0
	pushw	ix
	push	xde
	ld	a, (xiz+8)
	lda	xde, (Payload_Bss_Start+0x1db8:24)
	calr	FIFO_Engine1K_Put
	pop	xde
	popw	ix
	unlk	xiz
	ret
; Push BC bytes from (XIY) onto the 1 KB FIFO; both taken from the stack frame
; ((XIZ+8) = count, (XIZ+0x0A) = source pointer). Loops over the engine's PUT; note it does
; not stop when PUT reports "full", so overflow silently drops the tail.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; FIFO1K_PutBytes: Pushes BC bytes from (XIY) onto the 1 KB FIFO (descriptor 0x040c2e) through FIFO_Engine1K_Put, one
;   per byte; BC = (XIZ+8), XIY = (XIZ+10) from the stack frame; does not stop when the FIFO is full. No caller in
;   this build. Basis: API siblings + body -- the multi-byte form of the one-byte put beside it.
FIFO1K_PutBytes:
	link	xiz, 0
	push	xiy
	push	xix
	push	xde
	ld	bc, (xiz+8)
	ld	xiy, (xiz+10)
	lda	xde, (Payload_Bss_Start+0x1db8:24)
FIFO1K_PutBytes_Loop:
	ld	a, (xiy)
	calr	FIFO_Engine1K_Put
	inc	1, xiy
	djnz16	bc, FIFO1K_PutBytes_Loop
	pop	xde
	pop	xix
	pop	xiy
	unlk	xiz
	ret
; HL = 0xFFFF when write index (0x040C2A) == read index (0x040C26), else 0.
FIFO1K_Is_Empty:
	ld	hl, (Payload_Bss_Start+0x1db4:24)
	cp	hl, (Payload_Bss_Start+0x1db0:24)
	ld	hl, 0:i3
	jr	z, FIFO1K_Put_Block_Code_Return
	ldw	hl, 65535
FIFO1K_Put_Block_Code_Return:
	ret
; HL = the free-space counter word at 0x040C2C.
FIFO1K_Free_Space:
	ld	hl, (Payload_Bss_Start+0x1db6:24)
	ret

; Resets the 1 KB FIFO, control block at Payload_Bss_Start+0x1db8 (RingBuf_Reset_1K); keeps IX, XDE.
RingBuf_Init_1K:
	pushw ix
	push xde
	lda xde, (Payload_Bss_Start+0x1db8:24)
	call RingBuf_Reset_1K
	pop xde
	popw ix
	ret

; Copies the read index (0x040C26) into the mark/replay cursor (0x040C24), so the bytes
; consumed from here on can be re-read from the mark by FIFO1K_Get_Marked.
FIFO1K_SetMark:
	pushw	hl
	ld	hl, (Payload_Bss_Start+0x1db0:24)
	ld	(Payload_Bss_Start+0x1dae:24), hl
	popw	hl
	ret
; Pop one byte using the mark cursor, bounded by the commit index (0x040C28).
; Engine entry 0x020BBB. Output: HL = byte, or 0xFFFF when the mark has reached the commit.
FIFO1K_Get_Marked:
	pushw	ix
	push	xde
	lda	xde, (Payload_Bss_Start+0x1db8:24)
	call	FIFO_Engine1K_Get_Marked
	pop	xde
	popw	ix
	ret
; Pop one byte using the mark cursor, bounded by the write index (0x040C2A).
; Engine entry 0x020BD6. Output: HL = byte or 0xFFFF.
FIFO1K_Get_From_Mark:
	pushw	ix
	push	xde
	lda	xde, (Payload_Bss_Start+0x1db8:24)
	call	FIFO_Engine1K_Get_From_Mark
	pop	xde
	popw	ix
	ret
; Advances the read index (0x040C26) to the commit index (0x040C28).
FIFO1K_Commit:
	pushw	hl
	ld	hl, (Payload_Bss_Start+0x1db2:24)
	ld	(Payload_Bss_Start+0x1db0:24), hl
	popw	hl
	ret
; Advances the commit index (0x040C28) to the current write index (0x040C2A).
FIFO1K_Set_Commit:
	pushw	hl
	ld	hl, (Payload_Bss_Start+0x1db4:24)
	ld	(Payload_Bss_Start+0x1db2:24), hl
	popw	hl
	ret
; Same as FIFO1K_Get for the 256-byte FIFO at descriptor base 0x041038 (engine 0x020A7F).
FIFO256_Get:
	pushw	ix
	push	xde
	lda	xde, (Payload_Bss_Start+0x21c2:24)
	calr	FIFO_Engine256_Get
	pop	xde
	popw	ix
	ret
; Stack-arg push of one byte onto the 256-byte FIFO (engine 0x020AD3).
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO256_Put:
	link	xiz, 0
	pushw	ix
	push	xde
	ld	a, (xiz+8)
	lda	xde, (Payload_Bss_Start+0x21c2:24)
	calr	FIFO_Engine256_Put
	pop	xde
	popw	ix
	unlk	xiz
	ret
; Stack-arg push of a count/pointer block onto the 256-byte FIFO.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; FIFO256_PutBytes: Pushes BC bytes from (XIY) onto the 256-byte FIFO (descriptor 0x041038) through
;   FIFO_Engine256_Put, one per byte; BC = (XIZ+8), XIY = (XIZ+10) from the stack frame; does not stop when the FIFO
;   is full. No caller in this build. Basis: API siblings + body -- the multi-byte form of the one-byte put beside it.
FIFO256_PutBytes:
	link	xiz, 0
	push	xiy
	push	xix
	push	xde
	ld	bc, (xiz+8)
	ld	xiy, (xiz+10)
	lda	xde, (Payload_Bss_Start+0x21c2:24)
FIFO256_PutBytes_Loop:
	ld	a, (xiy)
	calr	FIFO_Engine256_Put
	inc	1, xiy
	djnz16	bc, FIFO256_PutBytes_Loop
	pop	xde
	pop	xix
	pop	xiy
	unlk	xiz
	ret
; HL = 0xFFFF when write index (0x041034) == read index (0x041030).
FIFO256_Is_Empty:
	ld	hl, (Payload_Bss_Start+0x21be:24)
	cp	hl, (Payload_Bss_Start+0x21ba:24)
	ld	hl, 0:i3
	jr	z, FIFO256_Put_Block_Code_Return
	ldw	hl, 65535
FIFO256_Put_Block_Code_Return:
	ret
; HL = free-space counter at 0x041036.
FIFO256_Free_Space:
	ld	hl, (Payload_Bss_Start+0x21c0:24)
	ret

; Resets the 256-byte FIFO, control block at Payload_Bss_Start+0x21c2 (RingBuf_Reset_256); keeps IX, XDE.
RingBuf_Init_256:
	pushw ix
	push xde
	lda xde, (Payload_Bss_Start+0x21c2:24)
	call RingBuf_Reset_256
	pop xde
	popw ix
	ret

; Read index (0x041030) -> mark cursor (0x04102E).
FIFO256_SetMark:
	pushw	hl
	ld	hl, (Payload_Bss_Start+0x21ba:24)
	ld	(Payload_Bss_Start+0x21b8:24), hl
	popw	hl
	ret
; Mark-cursor pop bounded by the commit index (engine 0x020A9D).
FIFO256_Get_Marked:
	pushw	ix
	push	xde
	lda	xde, (Payload_Bss_Start+0x21c2:24)
	call	FIFO_Engine256_Get_Marked
	pop	xde
	popw	ix
	ret
; Mark-cursor pop bounded by the write index (engine 0x020AB8).
FIFO256_Get_From_Mark:
	pushw	ix
	push	xde
	lda	xde, (Payload_Bss_Start+0x21c2:24)
	call	FIFO_Engine256_Get_From_Mark
	pop	xde
	popw	ix
	ret
; Commit index (0x041032) -> read index (0x041030).
FIFO256_Commit:
	pushw	hl
	ld	hl, (Payload_Bss_Start+0x21bc:24)
	ld	(Payload_Bss_Start+0x21ba:24), hl
	popw	hl
	ret
; Write index (0x041034) -> commit index (0x041032).
FIFO256_Set_Commit:
	pushw	hl
	ld	hl, (Payload_Bss_Start+0x21be:24)
	ld	(Payload_Bss_Start+0x21bc:24), hl
	popw	hl
	ret
; Same as FIFO1K_Get for the 512-byte FIFO at descriptor base 0x041142 (engine 0x020B0E).
FIFO512_Get:
	pushw	ix
	push	xde
	lda	xde, (Payload_Bss_Start+0x22cc:24)
	calr	FIFO_Engine512_Get
	pop	xde
	popw	ix
	ret
; Stack-arg push of one byte onto the 512-byte FIFO (engine 0x020B62).
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO512_Put:
	link	xiz, 0
	pushw	ix
	push	xde
	ld	a, (xiz+8)
	lda	xde, (Payload_Bss_Start+0x22cc:24)
	calr	FIFO_Engine512_Put
	pop	xde
	popw	ix
	unlk	xiz
	ret
; Stack-arg push of a count/pointer block onto the 512-byte FIFO.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; FIFO512_PutBytes: Pushes BC bytes from (XIY) onto the 512-byte FIFO (descriptor 0x041142) through
;   FIFO_Engine512_Put, one per byte; BC = (XIZ+8), XIY = (XIZ+10) from the stack frame; does not stop when the FIFO
;   is full. No caller in this build. Basis: API siblings + body -- the multi-byte form of the one-byte put beside it.
FIFO512_PutBytes:
	link	xiz, 0
	push	xiy
	push	xix
	push	xde
	ld	bc, (xiz+8)
	ld	xiy, (xiz+10)
	lda	xde, (Payload_Bss_Start+0x22cc:24)
FIFO512_PutBytes_Loop:
	ld	a, (xiy)
	calr	FIFO_Engine512_Put
	inc	1, xiy
	djnz16	bc, FIFO512_PutBytes_Loop
	pop	xde
	pop	xix
	pop	xiy
	unlk	xiz
	ret
; HL = 0xFFFF when write index (0x04113E) == read index (0x04113A).
FIFO512_Is_Empty:
	ld	hl, (Payload_Bss_Start+0x22c8:24)
	cp	hl, (Payload_Bss_Start+0x22c4:24)
	ld	hl, 0:i3
	jr	z, FIFO512_Put_Block_Code_Return
	ldw	hl, 65535
FIFO512_Put_Block_Code_Return:
	ret
; HL = free-space counter at 0x041140.
FIFO512_Free_Space:
	ld	hl, (Payload_Bss_Start+0x22ca:24)
	ret

; Resets the 512-byte FIFO, control block at Payload_Bss_Start+0x22cc (RingBuf_Reset_512); keeps IX, XDE.
; Audio_InitRingBuffers tail-jumps here after the 1 KB and 256-byte ones.
RingBuf_Init_512:
	pushw ix
	push xde
	lda xde, (Payload_Bss_Start+0x22cc:24)
	call RingBuf_Reset_512
	pop xde
	popw ix
	ret

; --- Audio buffer pointer load/store utilities ---
; Five small routines that load/store 16-bit pointer values
; from the audio buffer control block at 0x041138-0x041142.
; Each routine saves/restores caller registers.
; Read index (0x04113A) -> mark cursor (0x041138).
FIFO512_SetMark:
	pushw	hl
	ld	hl, (Payload_Bss_Start+0x22c4:24)
	ld	(Payload_Bss_Start+0x22c2:24), hl
	popw	hl
	ret
; Mark-cursor pop bounded by the commit index (engine 0x020B2C).
FIFO512_Get_Marked:
	pushw	ix
	push	xde
	lda	xde, (Payload_Bss_Start+0x22cc:24)
	call	FIFO_Engine512_Get_Marked
	pop	xde
	popw	ix
	ret
; Mark-cursor pop bounded by the write index (engine 0x020B47).
FIFO512_Get_From_Mark:
	pushw	ix
	push	xde
	lda	xde, (Payload_Bss_Start+0x22cc:24)
	call	FIFO_Engine512_Get_From_Mark
	pop	xde
	popw	ix
	ret
; Commit index (0x04113C) -> read index (0x04113A).
FIFO512_Commit:
	pushw	hl
	ld	hl, (Payload_Bss_Start+0x22c6:24)
	ld	(Payload_Bss_Start+0x22c4:24), hl
	popw	hl
	ret
; Write index (0x04113E) -> commit index (0x04113C).
FIFO512_Set_Commit:
	pushw	hl
	ld	hl, (Payload_Bss_Start+0x22c8:24)
	ld	(Payload_Bss_Start+0x22c6:24), hl
	popw	hl
	ret

RingBuf_Reset_256:	.include "includes/generated/cc900/RingBuf_Reset_256.s"	; C: cc900/task_scheduler_kernel.c

; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from RingBuf_WrappedRead_Opaque_A.
; Note: the engine GET: pop at the read index (XDE-8) until it meets the write index (XDE-4), then increment the free count (XDE-2).
FIFO_Engine256_Get:
	ld	ix, (xde-8)
	cp	ix, (xde-4)
	jr	nz, FIFO_Engine256_Get_NotEmpty
	ldw	hl, 0xffff
	ret
FIFO_Engine256_Get_NotEmpty:
	xor	hl, hl
	ld	l, (xde+ix)
	.byte	0xdc, 0x38, 0xff, 0x00	; minc1 0x00ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-8), ix
	incm	1, (xde-2)
	ret
; Engine: pop at the mark cursor (XDE-10), stop when it equals the commit index (XDE-6).
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO_Engine256_Get_Marked:
	ld	ix, (xde-10)
	cp	ix, (xde-6)
	jr	nz, FIFO_Engine256_Get_Marked_NotEmpty
	ldw	hl, 0xffff
	ret
FIFO_Engine256_Get_Marked_NotEmpty:
	xor	hl, hl
	ld	l, (xde+ix)
	.byte	0xdc, 0x38, 0xff, 0x00	; minc1 0x00ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-10), ix
	ret
; Engine: pop at the mark cursor (XDE-10), stop when it equals the write index (XDE-4).
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO_Engine256_Get_From_Mark:
	ld	ix, (xde-10)
	cp	ix, (xde-4)
	jr	nz, FIFO_Engine256_Get_From_Mark_NotEmpty
	ldw	hl, 0xffff
	ret
FIFO_Engine256_Get_From_Mark_NotEmpty:
	xor	hl, hl
	ld	l, (xde+ix)
	.byte	0xdc, 0x38, 0xff, 0x00	; minc1 0x00ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-10), ix
	ret
; Engine: if free count (XDE-2) is zero return HL=0xFFFF; else store A at (XDE + writeidx),
; advance the write index modulo 0x0FF, decrement the free count, return it in HL.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO_Engine256_Put:
	cpw	(xde-2), 0
	jr	nz, FIFO_Engine256_Put_HasRoom
	ldw	hl, 0xffff
	ret
FIFO_Engine256_Put_HasRoom:
	ld	ix, (xde-4)
	ld	(xde+ix), a
	.byte	0xdc, 0x38, 0xff, 0x00	; minc1 0x00ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-4), ix
	decm	1, (xde-2)
	ld	hl, (xde-2)
	ret

RingBuf_Reset_512:	.include "includes/generated/cc900/RingBuf_Reset_512.s"	; C: cc900/task_scheduler_kernel.c

; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from RingBuf_WrappedRead_Opaque_B.
; Note: the 512-byte twin of FIFO_Engine256_Get.
FIFO_Engine512_Get:
	ld	ix, (xde-8)
	cp	ix, (xde-4)
	jr	nz, FIFO_Engine512_Get_NotEmpty
	ldw	hl, 0xffff
	ret
FIFO_Engine512_Get_NotEmpty:
	xor	hl, hl
	ld	l, (xde+ix)
	.byte	0xdc, 0x38, 0xff, 0x01	; minc1 0x01ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-8), ix
	incm	1, (xde-2)
	ret
; 512-byte twin of 0x020A9D (wrap mask 0x1FF).
FIFO_Engine512_Get_Marked:
	ld	ix, (xde-10)
	cp16_src_rid8	xde, 0xfa, ix	; cp IX,(XDE+0xfa)
	jr	nz, FIFO_Engine512_Get_Marked_Skip
	ldw	hl, 65535
	ret
FIFO_Engine512_Get_Marked_Skip:
	xor	hl, hl
	ld	l, (xde+ix)
	minc1_16	ix, 0x01ff	; minc1 0x01ff,IX
	ld	(xde-10), ix
	ret
; 512-byte twin of 0x020AB8 (wrap mask 0x1FF).
FIFO_Engine512_Get_From_Mark:
	ld	ix, (xde-10)
	cp16_src_rid8	xde, 0xfc, ix	; cp IX,(XDE+0xfc)
	jr	nz, FIFO_Engine512_Get_From_Mark_Skip
	ldw	hl, 65535
	ret
FIFO_Engine512_Get_From_Mark_Skip:
	xor	hl, hl
	ld	l, (xde+ix)
	minc1_16	ix, 0x01ff	; minc1 0x01ff,IX
	ld	(xde-10), ix
	ret
; 512-byte twin of 0x020AD3 (wrap mask 0x1FF).
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO_Engine512_Put:
	cpw	(xde-2), 0
	jr	nz, FIFO_Engine512_Put_HasRoom
	ldw	hl, 0xffff
	ret
FIFO_Engine512_Put_HasRoom:
	ld	ix, (xde-4)
	ld	(xde+ix), a
	.byte	0xdc, 0x38, 0xff, 0x01	; minc1 0x01ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-4), ix
	decm	1, (xde-2)
	ld	hl, (xde-2)
	ret

RingBuf_Reset_1K:	.include "includes/generated/cc900/RingBuf_Reset_1K.s"	; C: cc900/task_scheduler_kernel.c

; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from RingBuf_WrappedRead_Opaque_C.
; Note: the 1K twin of FIFO_Engine256_Get.
FIFO_Engine1K_Get:
	ld	ix, (xde-8)
	cp	ix, (xde-4)
	jr	nz, FIFO_Engine1K_Get_NotEmpty
	ldw	hl, 0xffff
	ret
FIFO_Engine1K_Get_NotEmpty:
	xor	hl, hl
	ld	l, (xde+ix)
	.byte	0xdc, 0x38, 0xff, 0x03	; minc1 0x03ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-8), ix
	incm	1, (xde-2)
	ret
; 1 KB twin of 0x020A9D (wrap mask 0x3FF).
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO_Engine1K_Get_Marked:
	ld	ix, (xde-10)
	cp	ix, (xde-6)
	jr	nz, FIFO_Engine1K_Get_Marked_NotEmpty
	ldw	hl, 0xffff
	ret
FIFO_Engine1K_Get_Marked_NotEmpty:
	xor	hl, hl
	ld	l, (xde+ix)
	.byte	0xdc, 0x38, 0xff, 0x03	; minc1 0x03ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-10), ix
	ret
; 1 KB twin of 0x020AB8 (wrap mask 0x3FF).
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO_Engine1K_Get_From_Mark:
	ld	ix, (xde-10)
	cp	ix, (xde-4)
	jr	nz, FIFO_Engine1K_Get_From_Mark_NotEmpty
	ldw	hl, 0xffff
	ret
FIFO_Engine1K_Get_From_Mark_NotEmpty:
	xor	hl, hl
	ld	l, (xde+ix)
	.byte	0xdc, 0x38, 0xff, 0x03	; minc1 0x03ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-10), ix
	ret
; 1 KB twin of 0x020AD3 (wrap mask 0x3FF).
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
FIFO_Engine1K_Put:
	cpw	(xde-2), 0
	jr	nz, FIFO_Engine1K_Put_HasRoom
	ldw	hl, 0xffff
	ret
FIFO_Engine1K_Put_HasRoom:
	ld	ix, (xde-4)
	ld	(xde+ix), a
	.byte	0xdc, 0x38, 0xff, 0x03	; minc1 0x03ff,IX  (unidasm; no llvm-mc spelling)
	ld	(xde-4), ix
	decm	1, (xde-2)
	ld	hl, (xde-2)
	ret

Audio_CmdHandler_C0_FF:
	ld hl, 0:i3
	ret

