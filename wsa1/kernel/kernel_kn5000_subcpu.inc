; ============================================================================
; kernel/kernel_kn5000_subcpu.inc -- what the SHARED kernel source means on the
; Technics KN5000's SUB-CPU (TMP94C241F, sub-CPU payload v1.42 / v1.41 / v1.40).
; ============================================================================
;
; kernel/kernel.s is ONE source assembled into THREE processors: the SX-WSA1R's two
; TMP95C061s (kernel_maincpu.inc, kernel_subcpu.inc) and this one.  The two WSA1 CPUs
; differ only in the values below; the KN5000 build differs in TEXT as well -- seven
; routines and 306 instructions the WSA1 kernels do not have, a lock-depth word in
; RAM beside control register 0x7C, 16-bit direct addresses where the WSA1 RAM map
; fits in 8 bits -- so it also sets KERNEL_KN5000, which selects kernel.s's per-CPU
; `.if KERNEL_KN5000` blocks (owner decision 2026-11-06, register item N-8c52a3ed;
; the counts are wsa1/notes/open9-a3-probes/kernel_a3_merge.py --report's).
;
; ⚠ EVERY VALUE BELOW IS A MEASUREMENT, not a decision: the operand of the KN5000
;   instruction paired with each kernel.s use of the name
;   (wsa1/notes/open9-a3-probes/kernel_a3_merge.py), and if one is wrong the payload
;   stops rebuilding (`make gate`, sections "subcpu payload v142/v141/v140").
;   The RAM map is FINDINGS-kernel-in-the-kn5000.md sec 8's KN5000 column; it is the
;   same in v1.40, v1.41 and v1.42 (the kernel's text is identical in the three trees).
;   The four ROM values are labels of the payload itself, so they follow each version's
;   addresses; KERNEL_STACK_TOP is TaskSched_StackTop, Payload_Bss_Start-relative.
;
; ★ Read together, these equates ARE the KN5000 sub-CPU's kernel RAM map, 0x1044-0x10D3.

; KERNEL_KN5000 is a processor number since 2026-11-06 (lane open10/kernel4): 0 the SX-WSA1R, 1 this
; sub-CPU, 2 the KN5000 main CPU (kernel_kn5000_maincpu.inc).  `.if KERNEL_KN5000` = both KN5000 CPUs.
.equ KERNEL_KN5000, 1

; the KN5000 tree defines no TLCS-900 byte-emitter macros and kernel.s uses none, so
; wsa1/include/tlcs900_mem_ops.inc (which kernel.s pulls in for prom_c) stays out of this build
.equ KERNEL_MEM_OPS_PROVIDED, 1

.equ KERNEL_STACK_TOP,           TaskSched_StackTop	; the kernel's own stack, between task 3's and task 2's (TaskSched_TaskDescriptorTable's header)
.equ KERNEL_CURRENT_TASK,        0x1046	; word cell: pointer to the running task's control block, 0 = none
.equ KERNEL_PENDING_TICKS,       0x1044	; byte cell: kernel ticks not yet serviced; Kernel_Start clears it
.equ KERNEL_TCB_BASE,            0x1048	; task control blocks, stride 12 (+8 level, +9 state, +10 pending wakes, +11 task id)
.equ KERNEL_TASK_COUNT,          3	; how many control blocks Kernel_InitRam clears
.equ KERNEL_READY_HEADS,         0x106C	; ready-queue heads, stride 4, one per priority level
.equ KERNEL_READY_LEVELS,        3	; how many priority levels Kernel_Dispatch scans
.equ KERNEL_SEMA_QUEUES,         0x1082	; one wait-queue head per counting semaphore, stride 4
.equ KERNEL_SEMA_COUNTS,         0x1092	; the semaphore counts themselves, one byte each
.equ KERNEL_SEMA_COUNT,          4	; how many counting semaphores this CPU has
.equ KERNEL_SEMA_COUNT_IMAGE,    TaskSched_SemaphoreInit	; ROM: the power-on image of KERNEL_SEMA_COUNTS
.equ KERNEL_MSGQ_WAITQ,          0x1096	; one receiver wait-queue head per message queue, stride 4
.equ KERNEL_MSGQ_HEADS,          0x109E	; one message-list head per message queue, stride 4
.equ KERNEL_MSGQ_COUNT,          2	; how many message queues this CPU has
.equ KERNEL_NODE_POOL,           0x10A6	; the message nodes themselves, stride 8
.equ KERNEL_NODE_COUNT,          4	; how many message nodes are in the pool
.equ KERNEL_FREE_LIST,           0x10C6	; head of the free-node list; the whole pool is appended to it at boot
.equ KERNEL_TIMERS,              0x10CA	; software-timer slots, stride 8
.equ KERNEL_TIMER_COUNT,         1	; ONE slot here, two on both WSA1 CPUs
.equ KERNEL_BOOT_TIMER_CALLBACK, TaskSched_NullTimerCallback	; ROM: the callback in SoftTimer_Request_Boot's inline argument block (a bare RET)
.equ KERNEL_TCB_TEMPLATE,        TaskSched_TaskDescriptorTable - 12	; the task entry-point record array minus one 12-byte stride

; ---- names only the KN5000 build uses (no WSA1 instruction carries them) ----
.equ KERNEL_LOCK_DEPTH,          0x10D2	; word cell: the dispatch-inhibit depth; the WSA1 keeps it in control register 0x3C only, this build in RAM and mirrored into cr 0x7C
.equ KERNEL_EVENT_QUEUES,        0x1078	; one wait-queue head per EVENT flag (TaskEvent_*), stride 4
.equ KERNEL_EVENT_FLAGS,         0x1080	; the event flags, one byte each, bit 0 = signal latched
.equ KERNEL_EVENT_COUNT,         2	; how many event flags this CPU has
.equ KERNEL_EVENT_FLAG_IMAGE,    TaskSched_EventFlagInit	; ROM: the power-on image of KERNEL_EVENT_FLAGS
.equ KERNEL_PRIORITY_OUT,        0x0131	; byte: the running task's id << 5, written by Kernel_Dispatch (0xFF while idle)
.equ KERNEL_TICK_TREG3,          0x1D	; 8-bit timer 3's compare value, the kernel tick's period (the main CPU's is 0x07; 2026-11-06, lane open10/kernel4)
