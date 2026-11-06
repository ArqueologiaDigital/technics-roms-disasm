; ============================================================================
; kernel/kernel_kn5000_maincpu.inc -- what the SHARED kernel source means on the
; Technics KN5000's MAIN CPU (TMP94C241F, program v10 / v9 / v8 / v7).
; ============================================================================
;
; kernel/kernel.s is ONE source assembled into FOUR processors: the SX-WSA1R's two
; TMP95C061s (kernel_maincpu.inc, kernel_subcpu.inc), the KN5000 sub-CPU
; (kernel_kn5000_subcpu.inc) and this one.  The two KN5000 builds are the same text
; but for two copy lengths (`ld bc, N:i3` on the sub-CPU, whose counts fit in 3 bits;
; `ldw bc, N` here): 1,030 of the main CPU's 1,135 kernel slots are byte-identical to the
; sub-CPU's and the rest differ only in the values below (lane open10/kernel4,
; wsa1/notes/open10-kernel4-probes/kernel4_maincpu.py --pairing).
;
; ⚠ EVERY VALUE BELOW IS A MEASUREMENT: the operand of the main-CPU instruction paired
;   with each kernel.s use of the name, and if one is wrong the program stops rebuilding
;   (`make gate`, sections maincpu v10 / v9 / v8 / v7).  The RAM map is the same in all
;   four versions (their kernels assemble from this one file); the ROM values are labels of
;   each program, so they follow each version's addresses.
;   FINDINGS-kernel-in-the-kn5000.md sec 8's main-CPU table paired the WSA1's semaphores
;   with this CPU's EVENT flags (0x04CD/0x04D1 queues, 0x04F8/0x04F9 flags) -- the same
;   mix-up A3 corrected on the sub-CPU; the semaphores are 0x0503 / 0x0533 below.
;
; ★ Read together, these equates ARE the KN5000 main CPU's kernel RAM map, 0x0485-0x05C4.

.equ KERNEL_KN5000,              2	; selects the main CPU's blocks: 0 = SX-WSA1R, 1 = KN5000 sub-CPU, 2 = KN5000 main CPU
.equ KERNEL_MEM_OPS_PROVIDED,    1	; as on the sub-CPU: the TLCS-900 byte-emitter macros stay out of this build
.equ KERNEL_STACK_TOP,           0x0001E53A	; the kernel's own stack, above task 3's (0x0001E4B8, TaskSched_TaskDescriptorTable)
.equ KERNEL_CURRENT_TASK,        0x0487	; word cell: the running task's control block, 0 = none (the main tree's TASK_CURRENT)
.equ KERNEL_PENDING_TICKS,       0x0485	; byte cell: kernel ticks not yet serviced; Kernel_Start clears it
.equ KERNEL_TCB_BASE,            0x0489	; task control blocks, stride 12 (+8 level, +9 state, +10 pending wakes, +11 task id)
.equ KERNEL_TASK_COUNT,          5	; how many control blocks Kernel_InitRam clears (TaskSched_TaskDescriptorTable has 5 records)
.equ KERNEL_READY_HEADS,         0x04C5	; ready-queue heads, stride 4, one per priority level
.equ KERNEL_READY_LEVELS,        3	; how many priority levels Kernel_Dispatch scans
.equ KERNEL_SEMA_QUEUES,         0x0503	; one wait-queue head per counting semaphore, stride 4
.equ KERNEL_SEMA_COUNTS,         0x0533	; the semaphore counts, one byte each
.equ KERNEL_SEMA_COUNT,          12	; how many counting semaphores this CPU has
.equ KERNEL_SEMA_COUNT_IMAGE,    TaskSched_SemaphoreInit	; ROM: the power-on image of KERNEL_SEMA_COUNTS (12 x 1)
.equ KERNEL_MSGQ_WAITQ,          0x053F	; one receiver wait-queue head per message queue, stride 4
.equ KERNEL_MSGQ_HEADS,          0x0553	; one message-list head per message queue, stride 4
.equ KERNEL_MSGQ_COUNT,          5	; how many message queues this CPU has
.equ KERNEL_NODE_POOL,           0x0567	; the message nodes, stride 8
.equ KERNEL_NODE_COUNT,          10	; how many message nodes are in the pool
.equ KERNEL_FREE_LIST,           0x05B7	; head of the free-node list; the whole pool is appended to it at boot
.equ KERNEL_TIMERS,              0x05BB	; software-timer slots, stride 8
.equ KERNEL_TIMER_COUNT,         1	; ONE slot, as on the sub-CPU
.equ KERNEL_BOOT_TIMER_CALLBACK, TaskSched_NullTimerCallback	; ROM: the callback in SoftTimer_Request_Boot (a bare RET)
.equ KERNEL_TCB_TEMPLATE,        TaskSched_TaskDescriptorTable - 12	; the task entry-point record array minus one 12-byte stride
.equ KERNEL_LOCK_DEPTH,          0x05C3	; word cell: the dispatch-inhibit depth, mirrored into control register 0x7C
.equ KERNEL_EVENT_QUEUES,        0x04D1	; one wait-queue head per EVENT flag (TaskEvent_*), stride 4
.equ KERNEL_EVENT_FLAGS,         0x04F9	; the event flags, one byte each, bit 0 = signal latched
.equ KERNEL_EVENT_COUNT,         10	; how many event flags this CPU has
.equ KERNEL_EVENT_FLAG_IMAGE,    TaskSched_EventFlagInit	; ROM: the power-on image of KERNEL_EVENT_FLAGS (10 x 1)
.equ KERNEL_PRIORITY_OUT,        0x0131	; byte: the running task's id << 5, written by Kernel_Dispatch (0xFF while idle)
.equ KERNEL_TICK_TREG3,          0x07	; 8-bit timer 3's compare value, the kernel tick's period (the sub-CPU's is 0x1D)
