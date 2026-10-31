; ============================================================================
; TaskSched_TaskDescriptorTable -- the scheduler's static TASK TABLE (0x01FD98, 3 x 12 bytes)
; ============================================================================
; CORRECTED: this was labelled `DSP_ChannelConfigTable` with the comment "DSP channel
; configuration data table (42 bytes)".  Nothing in the DSP code reads it.  Its reader is
; TaskSched_SpawnTask (0x01FFFD):
;     ld l,12 / mul8rr l,a / extz xhl / add xhl, TaskSched_TaskDescriptorTable - 12
; i.e. record = table + 12*(A-1) for task id A = 1..3 (the constant in the instruction is
; the table MINUS one record, 0x01FD8C, which is why a search for 0x01FD98 found nothing).
; Record layout, derived field by field from the loads in TaskSched_SpawnTask:
;   +0  long   entry PC       `ld xwa,(xhl+0)` -> frame+30, the slot TaskSched_ContextRestore
;                             pops with its final RET
;   +4  long   stack top      `ld xiy,(xhl+4)`; the 34-byte (0x22) context frame is built at
;                             stack top - 0x22 and stored as the descriptor's saved XSP (+4)
;   +8  word   initial SR     `ld wa,(xhl+8)` -> frame+28, popped by TaskSched_ContextRestore's
;                             `pop sr`
;   +10 byte   priority       `ld a,(xhl+10)` -> descriptor +8, and selects the ready-queue head
;                             at 0x1068 + 4*priority
;   +11 byte   0              not read by TaskSched_SpawnTask
; Entry count 3: TaskSched_Init initialises exactly three 12-byte run-time descriptors at
; 0x1048/0x1054/0x1060 (= 0x103C + 12*A, `ld b,3`), and the six bytes after record 3 are
; independently claimed by TaskSched_Init's two ldir copies (below), so the table cannot be
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
; Initial values of the two EVENT flag bytes 0x1080/0x1081 (events 1, 2): TaskSched_Init
; copies these 2 bytes there with `ld xhl, TaskSched_EventFlagInit / ld de,0x1080 / ld bc,2 /
; ldir`.  1 = "already signalled"; see TaskEvent_Signal.
TaskSched_EventFlagInit:
	.byte	1, 1
; Initial counts of the four SEMAPHORES 0x1092..0x1095 (ids 1..4): TaskSched_Init copies these 4
; bytes with `ld xhl, TaskSched_SemaphoreInit / ld de,0x1092 / ld bc,4 / ldir`.  See
; TaskSem_GetCount, which reads them back.
TaskSched_SemaphoreInit:
	.byte	1, 1, 1, 1

Task_DequeueDispatch_Prio3:
	ld a, 0x3:opc
	jrl TaskQueue_Dequeue
; A separate one-instruction routine, not dead code after the tail jump: 0x01FDC7 is the
; callback pointer (+4) of TaskSched_Init_ConfigData, which Task_ConfigTimer copies into soft
; timer slot 1 (0x10CA).  TaskSched_SoftTimer_Service pushes its loop-advance address and
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
	jrl TaskSwitch_Countdown

TaskSched_Init:
	ld xsp, TaskSched_StackTop
	xor wa, wa
	ld (4166:16), wa
	inc 1, wa
	ldc_cr16 wa, 0x7C
	ld (4306:16), wa
	ldw hl, 0x106C
	extz xhl
	ld de, 4:i3
	ld b, 0x3:opc

TaskSched_Init_QueueHeaders:
	ld ix, hl
	ld (xhl+), IX
	ld (xhl+), IX
	djnz8 b, TaskSched_Init_QueueHeaders
	ldw ix, 0x1048
	extz xix
	ld b, 0x3:opc
	ld a, 0x0:opc

TaskSched_Init_TaskDescriptors:
	ld (xix + 9), a
	ld (xix + 10), 0x0
	ld (xix + 11), 0x0
	add ix, 0xC
	djnz8 b, TaskSched_Init_TaskDescriptors
	ldw ix, 0x10CA
	extz xix
	ld b, 0x1:opc
	ld xwa, 0xFFFFFFFF

TaskSched_Init_FreeList_A:
	ld (xix + 4), xwa
	add ix, 0x8
	djnz8 b, TaskSched_Init_FreeList_A
	ld xhl, TaskSched_EventFlagInit
	ldw de, 0x1080
	extz xde
	ld bc, 2:i3
	ldir83
	ldw hl, 0x1078
	extz xhl
	ld b, 0x2:opc

TaskSched_Init_QueueGroup_B:
	ld ix, hl
	ld (xhl+), IX
	ld (xhl+), IX
	djnz8 b, TaskSched_Init_QueueGroup_B
	ld xhl, TaskSched_SemaphoreInit
	ldw de, 0x1092
	extz xde
	ld bc, 4:i3
	ldir83
	ldw hl, 0x1082
	extz xhl
	ld b, 0x4:opc

TaskSched_Init_QueueGroup_C:
	ld ix, hl
	ld (xhl+), IX
	ld (xhl+), IX
	djnz8 b, TaskSched_Init_QueueGroup_C
	ldw hl, 0x10A6
	extz xhl
	ld b, 0x4:opc
	ld xwa, 0xFFFFFFFF

TaskSched_Init_FreeList_B:
	ld (xhl + 4), xwa
	add hl, 0x8
	djnz8 b, TaskSched_Init_FreeList_B
	ldw iy, 0x10C6
	extz xiy
	ld (xiy + 0:8), iy
	ld (xiy + 2), iy
	ldw ix, 0x10A6
	ld b, 0x4:opc

TaskSched_Init_LinkFreeNodes:
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	add ix, 0x8
	djnz8 b, TaskSched_Init_LinkFreeNodes
	ldw hl, 0x1096
	extz xhl
	ld b, 0x2:opc

TaskSched_Init_QueueGroup_D:
	ld ix, hl
	ld (xhl+), IX
	ld (xhl+), IX
	djnz8 b, TaskSched_Init_QueueGroup_D
	ldw hl, 0x109E
	extz xhl
	ld b, 0x2:opc

TaskSched_Init_QueueGroup_E:
	ld ix, hl
	ld (xhl+), IX
	ld (xhl+), IX
	djnz8 b, TaskSched_Init_QueueGroup_E
	ld xwa, TaskSched_Init_ConfigData
	jr TaskSched_ConfigAndDispatch

; Data, not code: TaskSched_Init loads its ADDRESS ("ld xwa, 0x1FEDF" above) rather than
; jumping to it, immediately before calling Task_ConfigTimer -- this is that call's config
; struct, not an instruction stream. It happens to disassemble as several short instructions
; if fed to a byte-stream decoder (that reading was audited and refused, see notes/README.md),
; which is why it is correctly left as .byte rather than converted.
; Layout, from its only reader Task_ConfigTimer (0x02072A), XIX = this struct:
;   +0 byte  timer slot id (1)   `ld a,(xix+0) / mul a,8 / add wa,0x10C2` -> slot 0x10CA
;   +1 byte  0                   not read
;   +2 word  period in ticks (1) copied to BOTH the slot's down-counter (+0) and reload (+2)
;   +4 long  callback            copied to the slot's +4; TaskSched_SoftTimer_Service calls it
TaskSched_Init_ConfigData:
	.byte	1, 0
	.short	1
	.long	TaskSched_NullTimerCallback

TaskSched_ConfigAndDispatch:
	call Task_ConfigTimer
	calr Timer3_Stop
	ld (TREG3:8), 0x1D:io
	ld	a, (INTET23:8)
	and a, 0xF
	or a, 0x20
	ld	(INTET23:8), a
	calr Timer3_Start
	ld a, 0x1:opc
	calr TaskSched_SpawnTask
	ei 6
	ld (4164:16), 0
	xor wa, wa
	ldc_cr16 wa, 0x7C
	ld (4306:16), wa
	jrl TaskSched_Dispatch

TaskSched_Halt:
	ei 0
	ld (305:16), 255

TaskSched_HaltLoop:
	jr TaskSched_HaltLoop

TaskSched_Dispatch:
	ld (305:16), 0
	ld wa, (4306:16)
	or wa, wa
	jr nz, TaskSched_ContextRestore
	xor wa, wa
	cp (4166:16), wa
	jr z, TaskSched_Dispatch_ScanQueues
	ld iy, (4166:16)
	extz xiy
	ld (xiy + 4), xsp
	ld xsp, TaskSched_StackTop
	xor wa, wa
	ld (4166:16), wa

TaskSched_Dispatch_ScanQueues:
	ld b, 0x3:opc
	ldw ix, 0x106C
	extz xix

TaskSched_Dispatch_ScanLoop:
	ld hl, (xix + 0:8)
	cp hl, ix
	jr nz, TaskSched_Dispatch_SwitchTo
	inc 4, ix
	djnz8 b, TaskSched_Dispatch_ScanLoop
	jr TaskSched_Halt

TaskSched_Dispatch_SwitchTo:
	ld (4166:16), hl
	extz xhl
	ld a, (xhl + 11)
	sll a, 5
	ld (305:16), a
	ld xsp, (xhl + 4)

TaskSched_ContextRestore:
	pop xiz
	pop xiy
	pop xix
	pop xde
	pop xbc
	pop xwa
	pop xhl
	pop	sr
	ret

; Software one-shot/periodic timer service. Walks the 1-entry timer table at 0x10CA
; (8 bytes/entry: +0 = down-counter word, +2 = reload word, +4 = 32-bit callback address,
; 0xFFFFFFFF = slot empty). For each armed slot it decrements +0; when the counter reaches
; zero it reloads it from +2, pushes the loop-advance address 0x01FFA8 as a return address
; and jumps to the callback, so the callback returns straight back into the walk.
; Runs the whole walk inside a scheduler lock: 0x10D2 (the lock-depth word) is incremented
; and mirrored into control register 0x7C on entry and decremented/mirrored on exit, with
; the interrupt mask raised to level 0 (all masked) for the walk and back to 6 afterwards.
; While the lock is non-zero TaskSched_Dispatch refuses to context-switch (see 0x01FF21).
; No caller was found by a whole-ROM branch-target scan; it is most likely reached through
; a dynamically installed vector (see Task_ConfigTimer 0x02072A). Register use: WA, XIX, B.
TaskSched_SoftTimer_Service:
	ld	wa, (4306:16)
	inc	1, wa
	ld	(4306:16), wa
	ldc_cr16	wa, 0x7c
	ei	0
	ldw	ix, 4298
	extz	xix
	ld	b, 1:opc
; Top of the per-slot walk; XIX = current 8-byte timer entry, B = slots remaining.
TaskSched_SoftTimer_SlotLoop:
	ld	xwa, (xix+4)
	cp	xwa, 4294967295
	jr	z, TaskSched_SoftTimer_Next
	ld	wa, (xix+0:8)	; ld wa,(XIX+0x00)
	dec	1, wa
	ld	(xix+0:8), wa	; ld (XIX+0x00),wa
	or	wa, wa
	jr	z, TaskSched_SoftTimer_Fire
; Advance XIX by 8 and djnz; also the synthetic return address pushed for a fired callback.
TaskSched_SoftTimer_Next:
	add	ix, 8
	djnz8	b, -30
; Restore interrupt level 6, decrement lock depth 0x10D2, mirror to cr 0x7C, return.
TaskSched_SoftTimer_Unlock:
	ei	6
	ld	wa, (4306:16)
	dec	1, wa
	ld	(4306:16), wa
	ldc_cr16	wa, 0x7c
	ret
; Reload counter from +2, push 0x01FFA8, jp (XIX+4) -- i.e. tail-call the callback.
TaskSched_SoftTimer_Fire:
	ld16_src_rid8	xix, 0x02, wa	; ld wa,(XIX+0x02)
	ld	(xix+0:8), wa	; ld (XIX+0x00),wa
	lda	xwa, (TaskSched_SoftTimer_Next:24)
	push	xwa
	ld	xwa, (xix+4)
	jp	(xwa)

TaskSwitch_Countdown:
	pushw wa
	ld wa, (4306:16)
	cp wa, 1:i3
	jr z, TaskSwitch_Expired
	dec 1, wa
	ld (4306:16), wa
	ldc_cr16 wa, 0x7C
	popw wa
	reti

TaskSwitch_Expired:
	xor wa, wa
	ld (4306:16), wa
	ldc_cr16 wa, 0x7C
	popw wa
	ei 0
	nop
	ei 6
	push xhl
	push xwa
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	jrl TaskSched_Dispatch

TaskSched_SpawnTask:
	push	sr
	ei 6
	push xhl
	push xwa
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	ld w, a
	ld l, 0xC:opc
	mul hl, a
	extz xhl
	add xhl, TaskSched_TaskDescriptorTable - 12
	ld c, 0xC:opc
	mul bc, a
	add bc, 0x103C
	extz xbc
	ld xix, xbc
	ld a, (xix + 9)
	cp a, 0:i3
	jrl nz, TaskSched_ContextRestore
	ld (xix + 11), w
	ld xiy, (xhl + 4)
	sub xiy, 0x22
	ld wa, (xhl + 8)
	ld (xiy + 28), wa
	ld xwa, (xhl + 0:8)
	ld (xiy + 30), xwa
	ld (xix + 4), xiy
	ld a, (xhl + 10)
	ld (xix + 8), a
	ld (xix + 9), 0x4
	ld (xix + 10), 0x0
	ld a, (xhl + 10)
	sll a, 2
	extz wa
	add wa, 0x1068
	ld iy, wa
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	jrl TaskSched_Dispatch

; Terminate the calling task: back on the scheduler stack (SP = 0x40B1E, the value
; TaskSched_Init uses), the current TCB (pointer at 0x1046) gets state +0x09 = 0 and pending
; count +0x0A = 0, 0x1046 is cleared, the TCB is unlinked from its queue and
; TaskSched_Dispatch picks the next task.  No caller in v1.42.
TaskSched_ExitCurrentTask:
	ei 6
	ld xsp, TaskSched_StackTop
	ld ix, (4166:16)
	extz xix
	ld (xix + 9), 0x0
	ld (xix + 10), 0x0
	xor wa, wa
	ld (4166:16), wa
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	jrl TaskSched_Dispatch

; HL = the running task's id (TCB +0x0B, the byte TaskSched_SpawnTask stores), or 0 when the
; scheduler lock depth at 0x10D2 is non-zero.  No caller in v1.42.
TaskSched_GetCurrentTaskId:
	ld hl, (4306:16)
	or hl, hl
	jr nz, TaskSched_ReturnZero
	push xix
	ld ix, (4166:16)
	extz xix
	ld l, (xix + 11)
	extz hl
	pop xix
	ret

TaskSched_ReturnZero:
	xor hl, hl
	ret

TaskSched_PreemptiveYield:
	push	sr
	ei 6
	push xhl
	push xwa
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	sll a, 2
	extz wa
	add wa, 0x1068
	ld iy, wa
	extz xiy
	ld ix, (xiy + 0:8)
	cp ix, (xiy + 2)
	jrl z, TaskSched_ContextRestore
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	jrl TaskSched_Dispatch

TaskQueue_Dequeue:
	push xwa
	push xix
	push xiy
	push xhl
	sll a, 2
	extz wa
	add wa, 0x1068
	ld iy, wa
	extz xiy
	ld ix, (xiy + 0:8)
	cp ix, (xiy + 2)
	jr z, TaskQueue_Dequeue_Return
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix

TaskQueue_Dequeue_Return:
	pop xhl
	pop xiy
	pop xix
	pop xwa
	ret

; "Wait on my own pending count" - the counting half of a binary rendezvous.
; Reads the current-task descriptor pointer from 0x1046. If the descriptor's pending count
; (+0x0A) is non-zero it just decrements it and returns through TaskSched_ContextRestore
; (0x01FF72). Otherwise it unlinks the descriptor from its ready queue (next at +0, prev at
; +2), sets state (+0x09) = 3 (BLOCKED) and jumps to TaskSched_Dispatch (0x01FF21), which
; picks another task. Entered with a full context already pushed (push SR + 7 long pushes),
; matching the frame TaskSched_ContextRestore pops.
; Inputs: none. Clobbers: everything (it either reschedules or restores the pushed context).
TaskSched_Block_Self:
	push	sr
	ei	6
	push	xhl
	push	xwa
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	ld	ix, (4166:16)
	extz	xix
	ld8_src_rid8	xix, 0x0a, a	; ld a,(XIX+0x0a)
	cp	a, 0:i3
	jr	nz, TaskSched_Block_Self_Consume
	extz	xix
	xor	xwa, xwa
	xor	xhl, xhl
	ld	wa, (xix+0:8)	; ld wa,(XIX+0x00)
	ld16_src_rid8	xix, 0x02, hl	; ld hl,(XIX+0x02)
	ld	(xhl+0:8), wa	; ld (XHL+0x00),wa
	ld_dst16_rid8	xwa, 0x02, hl	; ld (XWA+0x02),hl
	ld	(xix+9), 3
	jrl	TaskSched_Dispatch
; Pending count was non-zero: decrement it and fall out through ContextRestore.
TaskSched_Block_Self_Consume:
	dec	1, a
	ld	(xix+10), a
	jrl	TaskSched_ContextRestore
; Wake task A (task-context version; ends by rescheduling).
; Descriptor = 0x103C + 12*A. If state (+0x09) == 3 (BLOCKED) it is set to 4 (READY) and the
; descriptor is linked at the tail of the ready queue whose head is 0x1068 + 4*(+0x08), then
; control goes to TaskSched_Dispatch (0x01FF21) so a higher-priority wakee runs at once.
; If the task was not blocked the wake is remembered by incrementing its pending count
; (+0x0A), which TASKSCHED_BLOCK_SELF will consume later.
; Input: A = task id (1..3). Called with a full context frame already pushed.
TaskSched_Wake_Task:
	push	sr
	ei	6
	push	xhl
	push	xwa
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	mul	a, 12
	add	wa, 4156
	ld	ix, wa
	extz	xix
	cp8_imm_rid8	xix, 0x09, 0x03	; cp (XIX+0x09),0x03
	jr	nz, TaskSched_Wake_Task_Count
	ld	(xix+9), 4
	ld8_src_rid8	xix, 0x08, a	; ld a,(XIX+0x08)
	sll	a, 2
	extz	wa
	add	wa, 4200
	ld	iy, wa
	extz	xix
	extz	xiy
	xor	xwa, xwa
	ld	(xix+0:8), iy	; ld (XIX+0x00),iy
	ld16_src_rid8	xiy, 0x02, wa	; ld wa,(XIY+0x02)
	ld_dst16_rid8	xix, 0x02, wa	; ld (XIX+0x02),wa
	ld	(xwa), ix
	ld_dst16_rid8	xiy, 0x02, ix	; ld (XIY+0x02),ix
	jrl	TaskSched_Dispatch
; Task was not blocked: bump pending count (+0x0A) and go to Dispatch.
TaskSched_Wake_Task_Count:
	incm8	1, (xix+10)
	jrl	TaskSched_Dispatch
; Same wake as 0x020185 but safe from interrupt context: it saves only XWA/XIX/XIY/SR,
; never touches the scheduler stack and returns with a plain RET instead of dispatching.
; Input: A = task id. Output: none. Use this one from ISRs; the caller is expected to reach
; a scheduling point later (TaskSwitch_Countdown at 0x01FFD0 does that on interrupt exit).
TaskSched_Wake_Task_NoResched:
	push	xwa
	push	xix
	push	xiy
	push	sr
	ei	6
	mul	a, 12
	add	wa, 4156
	ld	ix, wa
	extz	xix
	cp8_imm_rid8	xix, 0x09, 0x03	; cp (XIX+0x09),0x03
	jr	nz, TaskSched_Wake_Task_NoResched_Count
	ld	(xix+9), 4
	ld8_src_rid8	xix, 0x08, a	; ld a,(XIX+0x08)
	sll	a, 2
	extz	wa
	add	wa, 4200
	ld	iy, wa
	extz	xix
	extz	xiy
	xor	xwa, xwa
	ld	(xix+0:8), iy	; ld (XIX+0x00),iy
	ld16_src_rid8	xiy, 0x02, wa	; ld wa,(XIY+0x02)
	ld_dst16_rid8	xix, 0x02, wa	; ld (XIX+0x02),wa
	ld	(xwa), ix
	ld_dst16_rid8	xiy, 0x02, ix	; ld (XIY+0x02),ix
; Common epilogue: pop SR, XIY, XIX, XWA, ret.
TaskSched_Wake_Task_NoResched_Ret:
	pop	sr
	pop	xiy
	pop	xix
	pop	xwa
	ret
; Not blocked: bump pending count and take the common epilogue.
TaskSched_Wake_Task_NoResched_Count:
	incm8	1, (xix+10)
	jr	TaskSched_Wake_Task_NoResched_Ret
; Reads and clears task A's pending count: L = descriptor(0x103C + 12*A) + 0x0A, then that
; field is zeroed. Returns through TaskSched_ContextRestore (0x01FF72).
; Input: A = task id. Output: L = the count that was pending.
TaskSched_Take_Pending_Count:
	push	sr
	ei	6
	push	xhl
	push	xwa
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	mul	a, 12
	add	wa, 4156
	ld	ix, wa
	extz	xix
	ld	l, (xix+10)
	ld	(xix+10), 0
	jrl	TaskSched_ContextRestore
; Signal event flag A (task-context version; ends by rescheduling).
; Event A has a self-linked wait-queue head at 0x1074 + 4*A and a one-bit "already signalled"
; flag in bit 0 of the byte at 0x107F + A. If the wait queue is empty the flag byte's bit 0
; is set (the signal is latched for a future waiter); otherwise the first waiter is unlinked,
; its state set to 4 (READY), it is appended to its priority's ready queue and Dispatch runs.
; Only event ids 1 and 2 exist: TaskSched_Init builds two heads at 0x1078/0x107C and seeds
; both flag bytes 0x1080/0x1081 to 1 (pre-signalled) by copying the two 0x01 bytes at
; 0x01FDBC.  Input: A = event id.
TaskEvent_Signal:
	push	sr
	ei	6
	push	xhl
	push	xwa
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	ld	l, a
	sll	a, 2
	extz	wa
	add	wa, 4212
	ld	iy, wa
	extz	xiy
	ld	ix, (xiy+0:8)	; ld ix,(XIY+0x00)
	cp	ix, iy
	jr	nz, TaskEvent_Signal_Wake
	extz	hl
	add	hl, 4223
	extz	xhl
	setm	0, (xhl)
	jrl	TaskSched_ContextRestore
; Unlink the head waiter, mark it READY, requeue by priority, jump to Dispatch.
TaskEvent_Signal_Wake:
	extz	xix
	xor	xwa, xwa
	xor	xhl, xhl
	ld	wa, (xix+0:8)	; ld wa,(XIX+0x00)
	ld16_src_rid8	xix, 0x02, hl	; ld hl,(XIX+0x02)
	ld	(xhl+0:8), wa	; ld (XHL+0x00),wa
	ld_dst16_rid8	xwa, 0x02, hl	; ld (XWA+0x02),hl
	ld	(xix+9), 4
	ld8_src_rid8	xix, 0x08, a	; ld a,(XIX+0x08)
	sll	a, 2
	extz	wa
	add	wa, 4200
	ld	iy, wa
	extz	xix
	extz	xiy
	xor	xwa, xwa
	ld	(xix+0:8), iy	; ld (XIX+0x00),iy
	ld16_src_rid8	xiy, 0x02, wa	; ld wa,(XIY+0x02)
	ld_dst16_rid8	xix, 0x02, wa	; ld (XIX+0x02),wa
	ld	(xwa), ix
	ld_dst16_rid8	xiy, 0x02, ix	; ld (XIY+0x02),ix
	jrl	TaskSched_Dispatch
; Interrupt-safe TaskEvent_Signal: identical logic, but saves only XWA/XIX/XIY/XHL/SR and
; returns with RET rather than entering the dispatcher.  Input: A = event id.
TaskEvent_Signal_NoResched:
	push	xwa
	push	xix
	push	xiy
	push	xhl
	ld	l, a
	sll	a, 2
	extz	wa
	add	wa, 4212
	ld	iy, wa
	extz	xiy
	push	sr
	ei	6
	ld	ix, (xiy+0:8)	; ld ix,(XIY+0x00)
	cp	ix, iy
	jr	nz, TaskEvent_Signal_NoResched_Wake
	extz	hl
	add	hl, 4223
	extz	xhl
	setm	0, (xhl)
; Common epilogue: pop SR, XHL, XIY, XIX, XWA, ret.
TaskEvent_Signal_NoResched_Ret:
	pop	sr
	pop	xhl
	pop	xiy
	pop	xix
	pop	xwa
	ret
; Queue non-empty: unlink waiter, state = 4, requeue on 0x1068 + 4*prio, take the epilogue.
TaskEvent_Signal_NoResched_Wake:
	extz	xix
	xor	xwa, xwa
	xor	xhl, xhl
	ld	wa, (xix+0:8)	; ld wa,(XIX+0x00)
	ld16_src_rid8	xix, 0x02, hl	; ld hl,(XIX+0x02)
	ld	(xhl+0:8), wa	; ld (XHL+0x00),wa
	ld_dst16_rid8	xwa, 0x02, hl	; ld (XWA+0x02),hl
	ld	(xix+9), 4
	ld8_src_rid8	xix, 0x08, a	; ld a,(XIX+0x08)
	sll	a, 2
	extz	wa
	add	wa, 4200
	ld	iy, wa
	extz	xix
	extz	xiy
	xor	xwa, xwa
	ld	(xix+0:8), iy	; ld (XIX+0x00),iy
	ld16_src_rid8	xiy, 0x02, wa	; ld wa,(XIY+0x02)
	ld_dst16_rid8	xix, 0x02, wa	; ld (XIX+0x02),wa
	ld	(xwa), ix
	ld_dst16_rid8	xiy, 0x02, ix	; ld (XIY+0x02),ix
	pop	sr
	pop	xhl
	pop	xiy
	pop	xix
	pop	xwa
	ret
; Wait on event flag A. If bit 0 of (0x107F + A) is set the latched signal is consumed
; (bit cleared) and the caller resumes immediately through TaskSched_ContextRestore.
; Otherwise the current task (descriptor pointer at 0x1046) is unlinked from its ready
; queue, state set to 3 (BLOCKED), appended to the event wait queue at 0x1074 + 4*A, and
; TaskSched_Dispatch is entered.  Input: A = event id. Entered with a full context pushed.
TaskEvent_Wait:
	push	sr
	ei	6
	push	xhl
	push	xwa
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	ld	e, a
	extz	wa
	add	wa, 4223
	extz	xwa
	bitm	0, (xwa)
	jr	z, TaskEvent_Wait_SuspendTask
	resm	0, (xwa)
	jrl	TaskSched_ContextRestore
; No latched signal: block the caller on the event queue and dispatch.
TaskEvent_Wait_SuspendTask:
	ld	ix, (4166:16)
	extz	xix
	xor	xwa, xwa
	xor	xhl, xhl
	ld	wa, (xix+0:8)	; ld wa,(XIX+0x00)
	ld16_src_rid8	xix, 0x02, hl	; ld hl,(XIX+0x02)
	ld	(xhl+0:8), wa	; ld (XHL+0x00),wa
	ld_dst16_rid8	xwa, 0x02, hl	; ld (XWA+0x02),hl
	ld	(xix+9), 3
	sll	e, 2
	extz	de
	add	de, 4212
	ld	iy, de
	extz	xix
	extz	xiy
	xor	xwa, xwa
	ld	(xix+0:8), iy	; ld (XIX+0x00),iy
	ld16_src_rid8	xiy, 0x02, wa	; ld wa,(XIY+0x02)
	ld_dst16_rid8	xix, 0x02, wa	; ld (XIX+0x02),wa
	ld	(xwa), ix
	ld_dst16_rid8	xiy, 0x02, ix	; ld (XIY+0x02),ix
	jrl	TaskSched_Dispatch
; Clears the latched-signal bit for event A: res 0,(0x107F + A), under interrupt level 6.
; Input: A = event id. Clobbers WA/XWA.
TaskEvent_Clear:
	extz	wa
	add	wa, 4223
	extz	xwa
	push	sr
	ei	6
	resm	0, (xwa)
	pop	sr
	ret

; Semaphore release -- V() -- for semaphore A (1..4), task-context version that reschedules.
; Saves the full context frame TaskSched_ContextRestore pops, masks to level 6, and looks at the
; semaphore's wait queue, head at 0x107E + 4*A (a circular list: empty when the head points at
; itself).  Empty: the count byte at 0x1091 + A is incremented (not stored if it would wrap to
; 0) and the context is restored.  Otherwise the first waiter is unlinked, its state (+0x09) set
; to 4 = READY, linked at the tail of ready queue 0x1068 + 4*(+0x08), and TaskSched_Dispatch
; runs.  Same count and queue addresses as TaskSem_GetCount / TaskSched_Wait / TaskSem_TryDec.
; ★ Renamed 2026-09-25 from TaskSched_PreemptiveYield_INT: nothing here yields
; unconditionally -- it only dispatches when it has woken a waiter.  The main-CPU v10 ROM holds
; the same code: a 44-byte run at +39 here is byte-identical to Audio_Lock_Release+39 there
; (scripts/analysis/v142_maincpu_shared_code_scan.py; ALIGNED = same offset in both routines).
TaskSem_Release:
	push	sr
	ei 6
	push xhl
	push xwa
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	ld l, a
	sll a, 2
	extz wa
	add wa, 0x107E
	ld iy, wa
	extz xiy
	ld ix, (xiy + 0:8)
	cp ix, iy
	jr nz, TaskSem_Release_WakeWaiter
	extz hl
	add hl, 0x1091
	extz xhl
	ld a, (xhl)
	inc 1, a
	jr z, TaskSem_Release_NoWaiter
	ld (xhl), a

TaskSem_Release_NoWaiter:
	jrl TaskSched_ContextRestore

TaskSem_Release_WakeWaiter:
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 9), 0x4
	ld a, (xix + 8)
	sll a, 2
	extz wa
	add wa, 0x1068
	ld iy, wa
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	jrl TaskSched_Dispatch

; The same V() without rescheduling: saves only XWA/XIX/XIY/XHL, masks to level 6 under
; `push sr`, and on the wake path makes the waiter READY and links it but RETURNS to the caller
; instead of dispatching (for a caller that must not be switched out here).  No caller found in
; v1.42: the entry address as a 3-byte LE value occurs nowhere in the image, and no calr
; displacement lands on it; it had no label until 2026-09-25.  Its wake path also occurs in the
; main-CPU v10 ROM (runs of 16, 16 and 46 bytes inside AudioLock_Release_WakeWaiter, same
; scan).
TaskSem_Release_NoResched:
	push xwa
	push xix
	push xiy
	push xhl
	ld l, a
	sll a, 2
	extz wa
	add wa, 0x107E
	ld iy, wa
	extz xiy
	push	sr
	ei 6
	ld ix, (xiy + 0:8)
	cp ix, iy
	jr nz, TaskSem_Release_NoResched_WakeWaiter
	extz hl
	add hl, 0x1091
	extz xhl
	ld a, (xhl)
	inc 1, a
	jr z, TaskSem_Release_NoResched_NoWaiter
	ld (xhl), a

TaskSem_Release_NoResched_NoWaiter:
	pop	sr
	pop xhl
	pop xiy
	pop xix
	pop xwa
	ret

TaskSem_Release_NoResched_WakeWaiter:
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 9), 0x4
	ld a, (xix + 8)
	sll a, 2
	extz wa
	add wa, 0x1068
	ld iy, wa
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	pop	sr
	pop xhl
	pop xiy
	pop xix
	pop xwa
	ret

TaskSched_Wait:
	push	sr
	ei 6
	push xhl
	push xwa
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	ld e, a
	extz wa
	add wa, 0x1091
	extz xwa
	cp (xwa), 0x0
	jr z, TaskSched_Wait_SuspendTask
	decm8 1, (xwa)
	jrl TaskSched_ContextRestore

TaskSched_Wait_SuspendTask:
	ld ix, (4166:16)
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 9), 0x3
	sll e, 2
	extz de
	add de, 0x107E
	ld iy, de
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	jrl TaskSched_Dispatch

; Non-blocking P() on semaphore A: under interrupt level 6, if the count at 0x1091 + A is 0
; return HL = 0xFFFF, else decrement it and return HL = 0.  Named in TaskSem_GetCount's header;
; no caller in v1.42.
TaskSem_TryDec:
	extz wa
	add wa, 0x1091
	extz xwa
	push	sr
	ei 6
	cp (xwa), 0x0
	jr z, TaskSem_TryDec_WouldBlock
	decm8 1, (xwa)
	xor hl, hl
	jr TaskSem_TryDec_Return

TaskSem_TryDec_WouldBlock:
	ldw hl, 0xFFFF

TaskSem_TryDec_Return:
	pop	sr
	ret

; Non-destructive read of semaphore A's count: HL = zero-extended byte at 0x1091 + A.
; The four semaphores (ids 1..4) have their counts at 0x1092..0x1095, all seeded to 1 by
; TaskSched_Init (from the four 0x01 bytes at 0x01FDBE), and their wait-queue heads at
; 0x107E + 4*A i.e. 0x1082/0x1086/0x108A/0x108E. Siblings: TaskSched_Wait (0x02044F) is the
; blocking P(), TaskSem_TryDec (0x0204A9) is the non-blocking one.
; Input: A = semaphore id. Output: HL = current count.
TaskSem_GetCount:
	extz	wa
	add	wa, 4241
	extz	xwa
	ld	l, (xwa)
	extz	hl
	ret

TaskMsgQ_Send:
	push	sr
	ei 6
	push xhl
	push xwa
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	ld xiz, xbc
	sll a, 2
	ld c, a
	extz wa
	add wa, 0x1092
	ld iy, wa
	extz xiy
	ld ix, (xiy + 0:8)
	cp ix, iy
	jr nz, TaskMsgQ_Send_DirectDeliver
	ld ix, (4294:16)
	extz xix
	ld iy, (xix + 0:8)
	cp iy, ix
	jrl z, TaskMsgQ_Send_PoolEmpty
	ldw (xsp + 24), 0x0
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 4), xiz
	extz bc
	add bc, 0x109A
	ld iy, bc
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	jrl TaskSched_ContextRestore

TaskMsgQ_Send_PoolEmpty:
	ldw (xsp + 24), 0xFFFF
	jrl TaskSched_ContextRestore

TaskMsgQ_Send_DirectDeliver:
	ldw (xsp + 24), 0x0
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 9), 0x4
	ld xwa, (xix + 4)
	ld (xwa + 24), xiz
	ld a, (xix + 8)
	sll a, 2
	extz wa
	add wa, 0x1068
	ld iy, wa
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	jrl TaskSched_Dispatch

; TaskMsgQ_Send without rescheduling: saves six registers instead of the full context frame,
; then the same queue logic (waiter list 0x1092 + 4*A, message list 0x109A + 4*A, free nodes
; at 0x10C6); a waiting receiver is made READY and linked, and the routine RETURNS to its
; caller.  Main-CPU twin: the code under TaskMsg_Send_NB_Return / _NB_WakeReceiver.  No
; caller in v1.42.
TaskMsgQ_Send_NoResched:
	push xwa
	push xix
	push xiy
	push xiz
	push xhl
	push xbc
	ld xiz, xbc
	sll a, 2
	ld c, a
	extz wa
	add wa, 0x1092
	ld iy, wa
	extz xiy
	push	sr
	ei 6
	ld ix, (xiy + 0:8)
	cp ix, iy
	jr nz, TaskMsgQ_Send_Guard_DirectDeliver
	ld ix, (4294:16)
	extz xix
	ld iy, (xix + 0:8)
	cp iy, ix
	jrl z, TaskMsgQ_Send_Guard_PoolEmpty
	ldw (xsp + 4), 0x0
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 4), xiz
	extz bc
	add bc, 0x109A
	ld iy, bc
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix

TaskMsgQ_Send_Guard_Return:
	pop	sr
	pop xbc
	pop xhl
	pop xiz
	pop xiy
	pop xix
	pop xwa
	ret

TaskMsgQ_Send_Guard_PoolEmpty:
	ldw (xsp + 4), 0xFFFF
	jr TaskMsgQ_Send_Guard_Return

TaskMsgQ_Send_Guard_DirectDeliver:
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 9), 0x4
	ld xwa, (xix + 4)
	ld (xwa + 24), xiz
	ld a, (xix + 8)
	sll a, 2
	extz wa
	add wa, 0x1068
	ld iy, wa
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	pop	sr
	pop xbc
	pop xhl
	pop xiz
	pop xiy
	pop xix
	pop xwa
	ret

TaskMsgQ_Receive:
	push	sr
	ei 6
	push xhl
	push xwa
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	sll a, 2
	extz wa
	ld de, wa
	add wa, 0x109A
	ld iy, wa
	extz xiy
	ld ix, (xiy + 0:8)
	cp ix, iy
	jr z, TaskMsgQ_Receive_Empty
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld xiz, (xix + 4)
	ld xbc, 0xFFFFFFFF
	ld (xix + 4), xbc
	ldw iy, 0x10C6
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	ld (xsp + 24), xiz
	jrl TaskSched_ContextRestore

TaskMsgQ_Receive_Empty:
	ld ix, (4166:16)
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 9), 0x3
	add de, 0x1092
	ld iy, de
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	jrl TaskSched_Dispatch

TaskMsgQ_TryReceive:
	push xix
	push xiz
	sll a, 2
	extz wa
	add wa, 0x109A
	ld iy, wa
	push	sr
	ei 6
	extz xiy
	ld ix, (xiy + 0:8)
	cp ix, iy
	jr z, TaskMsgQ_TryReceive_Empty
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld xiz, (xix + 4)
	ld xwa, 0xFFFFFFFF
	ld (xix + 4), xwa
	ldw iy, 0x10C6
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	ld xhl, xiz
	jr TaskMsgQ_TryReceive_Return

TaskMsgQ_TryReceive_Empty:
	xor xhl, xhl

TaskMsgQ_TryReceive_Return:
	pop	sr
	pop xiz
	pop xix
	ret

Task_ConfigTimer:
	push	sr
	ei 6
	push xhl
	push xwa
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	ld xix, xwa
	ld a, (xix + 0:8)
	mul a, 0x8
	add wa, 0x10C2
	ld iy, wa
	extz xiy
	ld wa, (xix + 2)
	ld (xiy + 0:8), wa
	ld (xiy + 2), wa
	ld xwa, (xix + 4)
	ld (xiy + 4), xwa
	jrl TaskSched_Dispatch

; Give task A priority C: TCB = 0x103C + 12*A.  If the task is READY (state +0x09 == 4) it is
; unlinked, its priority byte +0x08 set and it is relinked at the tail of ready queue
; 0x1068 + 4*C, then TaskSched_Dispatch runs; otherwise only +0x08 is written
; (Task_Reassign_NotRunning).  Main-CPU twin: TaskSched_ChangePriority.  No caller in v1.42.
TaskSched_ChangePriority:
	push	sr
	ei 6
	push xhl
	push xwa
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	ld e, c
	mul a, 0xC
	add wa, 0x103C
	ld ix, wa
	extz xix
	cp (xix + 9), 0x4
	jr nz, Task_Reassign_NotRunning
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 8), e
	sll e, 2
	extz de
	add de, 0x1068
	ld iy, de
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	jrl TaskSched_Dispatch

Task_Reassign_NotRunning:
	ld (xix + 8), e
	jrl TaskSched_ContextRestore

; TaskSched_ChangePriority without the context frame and without rescheduling: the same
; relink under `push sr / ei 6`, then return to the caller.  No caller in v1.42.
TaskSched_ChangePriority_NoResched:
	push xwa
	push xix
	push xiy
	push xhl
	pushw de
	ld e, c
	mul a, 0xC
	add wa, 0x103C
	ld ix, wa
	extz xix
	push	sr
	ei 6
	cp (xix + 9), 0x4
	jr nz, Task_Reassign_Guard_NotRunning
	extz xix
	xor xwa, xwa
	xor xhl, xhl
	ld wa, (xix + 0:8)
	ld hl, (xix + 2)
	ld (xhl + 0:8), wa
	ld (xwa + 2), hl
	ld (xix + 8), e
	sll e, 2
	extz de
	add de, 0x1068
	ld iy, de
	extz xix
	extz xiy
	xor xwa, xwa
	ld (xix + 0:8), iy
	ld wa, (xiy + 2)
	ld (xix + 2), wa
	ld (xwa), ix
	ld (xiy + 2), ix
	jr Task_Reassign_Guard_Return

Task_Reassign_Guard_NotRunning:
	ld (xix + 8), e

Task_Reassign_Guard_Return:
	pop	sr
	popw de
	pop xhl
	pop xiy
	pop xix
	pop xwa
	ret

; Terminate task A. Descriptor = 0x103C + 12*A; the descriptor is unlinked from whatever
; doubly-linked list it is on (next +0 / prev +2) and both its state byte (+0x09) and its
; pending count (+0x0A) are zeroed, i.e. the slot returns to the "never spawned" condition
; that TaskSched_SpawnTask (0x01FFFD) tests for. Runs at interrupt level 6, saves
; WA/XIX/XIY/XHL, plain RET (it never kills the *running* task's stack, so the caller must
; not be task A itself).  Input: A = task id.
; 2026-09-25: CODE, converted from a .byte run (scripts/converters/convert_v142_byte_block.py:
; llvm-mc and unidasm agree on every instruction boundary; each instruction re-assembles to its
; own bytes, the few llvm-mc cannot spell stay .byte with unidasm's reading as a comment).
; Renamed from RingBuf_Access_Opaque_A.
; Note: its first four bytes were `.ascii "(<=;"` -- they are `push wa / push xix / push xiy / push xhl`, matching the pops at the end.
TaskSched_TerminateTask:
	pushw	wa
	push	xix
	push	xiy
	push	xhl
	ei	6
	mul	a, 12
	add	wa, 4156
	ld	ix, wa
	extz	xix
	xor	xwa, xwa
	xor	xhl, xhl
	ld	wa, (xix+0:8)	; ld wa,(XIX+0x00)
	ld16_src_rid8	xix, 0x02, hl	; ld hl,(XIX+0x02)
	ld	(xhl+0:8), wa	; ld (XHL+0x00),wa
	ld_dst16_rid8	xwa, 0x02, hl	; ld (XWA+0x02),hl
	ld	(xix+9), 0
	ld	(xix+10), 0
	ei	0
	pop	xhl
	pop	xiy
	pop	xix
	popw	wa
	ret
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
; MICRODMA_CH2_HANDLER header explains T8RUN).  TaskSched_ConfigAndDispatch stops it, sets
; TREG3 = 0x1D and the timer-3 interrupt level, and starts it again: the scheduler's tick timer.
; ★ Renamed 2026-09-25 from IntMask_SetBit3 / IntMask_ClearBit3 -- no interrupt mask is touched.
Timer3_Start:
	set	3, (T8RUN:8)
	ret

Timer3_Stop:
	res	3, (T8RUN:8)
	ret

; incw 1,(0x10D2) -- take the scheduler lock. While 0x10D2 is non-zero TaskSched_Dispatch
; (0x01FF21) returns through ContextRestore without switching tasks and TaskSwitch_Countdown
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

RingBuf_Reset_256:
	ldw (xde - 10), 0x0
	ldw (xde - 8), 0x0
	ldw (xde - 4), 0x0
	ldw (xde - 6), 0x0
	ldw (xde - 2), 0xFF
	ret

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

RingBuf_Reset_512:
	ldw (xde - 10), 0x0
	ldw (xde - 8), 0x0
	ldw (xde - 4), 0x0
	ldw (xde - 6), 0x0
	ldw (xde - 2), 0x1FF
	ret

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

RingBuf_Reset_1K:
	ldw (xde - 10), 0x0
	ldw (xde - 8), 0x0
	ldw (xde - 4), 0x0
	ldw (xde - 6), 0x0
	ldw (xde - 2), 0x3FF
	ret

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

