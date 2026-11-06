# open9-a3-probes -- join/split phase A3: one kernel source for three processors (lane open9/kernel-a3, 2026-11-06)

Register item N-8c52a3ed.  The owner decided on 2026-11-06, answering the question the A3 blocker
asked (`../HANDOFF-join-split-kernel.md`): **"Yes: one kernel source for three CPUs, with conditional
blocks through most routines."**  So `wsa1/kernel/kernel.s` is now the multitasking kernel of the
SX-WSA1R's CPU 1 (prom_a), its CPU 2 (prom_c) and the KN5000 sub-CPU payload v1.42 (and v1.41 and
v1.40, which are generated from v1.42).  All six images rebuild byte for byte from it.

| script                                | question it answers                                                                                                 | run (exact command, in `wsa1/`, on a built tree)                                                                             |
|---------------------------------------|---------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| `kernel_a3_pairing.py`                | Which KN5000 sub-CPU routine IS which kernel.s routine, routine against routine on proven boundaries?               | `UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm python3 notes/open9-a3-probes/kernel_a3_pairing.py --selftest` |
| `kernel_a3_merge.py --report`         | How much of the kernel is written once for all three processors, and how much is per CPU?                           | `UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm python3 notes/open9-a3-probes/kernel_a3_merge.py --report`     |
| `kernel_a3_merge.py --verify`         | Did the merge only insert into kernel.s's text, move every KN5000 comment and label, and leave no old name in code? | `UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm python3 notes/open9-a3-probes/kernel_a3_merge.py --verify`     |
| `kernel_a3_merge.py --emit`           | (the job, done once) wrote kernel.s, the KN5000 03 file and `scripts/renaming/rename_kernel_a3.sed` from BASE       | see the script's docstring; not a build step -- kernel.s is the source now                                                   |
| `../open4-e-probes/census_battery.sh` | Did any census silently stop seeing the moved text?  Before and after, diffed                                       | `bash wsa1/notes/open4-e-probes/census_battery.sh OUTDIR` (repo root)                                                        |

The byte gate is the proof of the bytes: `make gate` (sections "subcpu payload v142 / v141 / v140" and
their update images) and `make gate-wsa1` (prom_a, prom_c).

## The pairing (`kernel_a3_pairing.py`, measured 2026-11-06 at base 34bc0c5fe)

Both sides are decoded from the EPROM / payload bytes by MAME unidasm and tokenised the way A2 did
(`../kernel_structural_match.py`: every `0x...` literal folded); the WSA1 extents are kernel.s's own
routine labels, the KN5000 extents its 33 routine entries in `v142/subcpu/core/03_task_scheduler_kernel.s`
at the built ELF's addresses.  A pair is accepted when it is the MUTUAL best, scores >= 0.5
(LCS / longer routine), and the accepted pairs keep the same ROM order on both sides.

* **26 pairs, and the ROM order is the SAME on both products.**  A2's "21-long increasing run of 26"
  (FINDINGS sec 5) came from its approximate match sites (several routines on one site), not from a
  different layout.  So one sequential source body can emit both.
* 25 pairs score 0.65-1.00; the 26th, Kernel_Start = TaskSched_ConfigAndDispatch, is a composite
  (WSA1's `Kernel_InitRam__install` call plus Kernel_Start) that scores exactly 0.500 and is accepted by
  order: it is the only routine left between two accepted pairs on either side.
* The semaphore routines pair with the KN5000's `TaskSem_*` (counting semaphores at 0x1092), not its
  `TaskEvent_*` (one-bit event flags at 0x1080): Kernel_SemaSignal = TaskSem_Release 0.938 against
  0.854 for TaskEvent_Signal, mutual best both ways.  A2's site for Kernel_SemaSignal (0x020308, which
  is TaskEvent_Wait) was one of its approximate ones.
* No partner: the 10 WSA1 stack faces (`*_StackArg`) and 7 KN5000 routines: TaskSched_GetCurrentTaskId,
  TaskSched_Take_Pending_Count, TaskEvent_Signal, TaskEvent_Signal_NoResched, TaskEvent_Wait,
  TaskEvent_Clear, TaskSem_GetCount.

## The merge (`kernel_a3_merge.py --report`)

| what                                                          | count                                |
|---------------------------------------------------------------|--------------------------------------|
| WSA1 instruction/data slots (prom_a and prom_c alike)         | 941                                  |
| KN5000 sub-CPU instruction/data slots                         | 1,137                                |
| written ONCE for all three processors                         | 801                                  |
| ... of which: kernel.s's line gives the KN5000 bytes          | 744                                  |
| ... of which: a branch / label reference to the paired target | 57                                   |
| aligned but spelled per CPU                                   | 30                                   |
| ... 16-bit direct address where the WSA1 map fits in 8 bits   | 11                                   |
| ... different register, count or encoding                     | 15                                   |
| ... a branch to a different place                             | 4                                    |
| KN5000-only instructions                                      | 306                                  |
| WSA1-only instructions                                        | 110                                  |
| `.if KERNEL_KN5000` blocks (81 with an `.else`)               | 109                                  |
| `.if KERNEL_KN5000 == 0` blocks                               | 25                                   |
| paired routines with at least one per-CPU block               | 25 of 26 (all but Kernel_ResumeTask) |
| KN5000 labels renamed to kernel.s's names                     | 62                                   |

`--verify` (12 checks): every line of BASE's kernel.s is still in kernel.s, in order (the merge only
inserted, plus the four `KS_EDITS`: the header's A3 section, two notes, and the last raw-byte spelling,
`extpfx5 0xBF, 0x0E, 0x02, 0xFF, 0xFF`, respelled `ldw (xsp+14), 0xffff` -- same bytes); the WSA1 view's
non-comment lines are exactly BASE's 1,040; all 133 KN5000 comment lines of the kernel region are in the
KN5000 view, in order; the KN5000 view has the 1,137 instruction/data lines BASE had; all 80 KN5000
labels are defined (62 renamed, 18 kept); no renamed name is used in v142/v141/v140 code; the three
payload trees include the shared source and hold no copy; the Makefile makes their objects depend on it.

## The design, and why

* **One sequential body in kernel.s**, not per-routine files with a per-CPU order list: the order was
  measured first and it is the same.  The KN5000-only routines stand at their ROM position under
  `.if KERNEL_KN5000`; the WSA1 stack faces and prom_a's alias labels under `.if KERNEL_KN5000 == 0`.
  One file also keeps the tools that read kernel.s by path working.
* `KERNEL_KN5000` is set by each processor's .inc: 0 in `kernel_maincpu.inc` / `kernel_subcpu.inc`, 1
  in the new `kernel_kn5000_subcpu.inc`, which also holds the KN5000's values for the 21 kernel equates
  (its RAM map, FINDINGS sec 8) and six names only the KN5000 build uses (KERNEL_LOCK_DEPTH,
  KERNEL_EVENT_QUEUES / _FLAGS / _COUNT / _FLAG_IMAGE, KERNEL_PRIORITY_OUT).  The four ROM values are
  labels of the payload, so v1.41 and v1.40 need no .inc of their own.
* The KN5000 text in its blocks is its own listing with the kernel RAM literals spelled with those
  equates (`(4166:16)` -> `(KERNEL_CURRENT_TASK:16)`, `add wa, 4200` -> `KERNEL_READY_HEADS-4`, ...).
* Labels: where a KN5000 routine IS a kernel.s routine, kernel.s's name is the one label in all
  three builds; each paired routine lists its old KN5000 names under its KN5000 banner, and
  `scripts/renaming/rename_kernel_a3.sed` is the whole list (applied to the v142 tree outside the
  kernel; v141 and v140 regenerated).  The KN5000-only routines keep their names.
* Comments: the KN5000 routine headers moved under
  `; >>>>>> moved from v142/subcpu/core/03_task_scheduler_kernel.s -- the KN5000 SUB-CPU >>>>>>`
  after the WSA1 headers; interior comments before the instruction they preceded.  One KN5000
  comment names the MAIN CPU's routine of the same old name ("Main-CPU twin:
  TaskSched_ChangePriority") and keeps it.
* Out of the shared extent, kept in the KN5000 file: the data the kernel reads
  (TaskSched_TaskDescriptorTable, TaskSched_EventFlagInit, TaskSched_SemaphoreInit), the routines in
  front of Kernel_InitRam (Task_DequeueDispatch_Prio3, TaskSched_NullTimerCallback,
  INTT3_TaskSwitch_Handler) and after Kernel_KillTask (Timer_Delay_Ticks, Timer3_Start / Timer3_Stop,
  TaskSched_Lock / TaskSched_Unlock): the WSA1 kernel's extent is Kernel_InitRam .. Kernel_KillTask on
  both its CPUs, and none of these has a WSA1 partner.

## Tools that read kernel.s, taught the conditional (2026-11-06)

* `wsa1/notes/asm_source.py` `cpu_view()`: the lines one build assembles, the other processor's
  `.if KERNEL_KN5000` branches (and the directives) BLANKED, so line numbers stay true.
  `image_lines()` / `image_path()` apply it to every WSA1 image; `kernel_structural_match.py`'s
  `kernel_lines()` too.  In the KN5000 view it also drops `.ifndef KERNEL_MEM_OPS_PROVIDED` (the KN5000
  .inc defines that symbol, so wsa1/include/tlcs900_mem_ops.inc stays out of that build).
* `scripts/analysis/doc_quality_census.py`: the sub-CPU images take `-I wsa1/kernel`, and kernel.s is
  read per processor.
* `scripts/analysis/data_range_census.py`: the sub-CPU images mirror `wsa1/kernel`
  (`xmirrors`), as the build passes it.  The dispatch census uses this instrument.
* `scripts/analysis/kn5000_source_coverage.py`: `EXTRA_SRC` scans kernel.s (KN5000 view) for v142.
* `scripts/analysis/l2_symbol_reference.py`: drops `KERNEL_*` equates, five of which the KN5000 .inc
  defines as label expressions and the ELF would otherwise carry as aliases of named labels.
* `wsa1/notes/kernel_join_probe.py --verify` accepts the comment lines whose origin is the KN5000
  file (`kernel_a3_merge.kn_origin_lines()`); its stray count is back to its pre-A3 figure.

## Re-baselined checkers (what moved and why)

| checker                                                     | before (34bc0c5fe)                                  | after                        | why                                                                                                                                                                 |
|-------------------------------------------------------------|-----------------------------------------------------|------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `open4-e-probes/kernel_a3_shareability.py --selftest`       | ok                                                  | ok                           | unchanged: it now reads kernel.s through cpu_view (the WSA1 build), as before                                                                                       |
| `kernel_join_probe.py --verify`                             | 4 FAIL (2 missing, 244 stray, 14 + 14 literal)      | the same 4 FAIL, same counts | the KN5000-origin comments are accepted; the four failures pre-date A3 (fixed by lane open10/kernel4: "New items" 1)                                                |
| `kernel_structural_match.py --selftest`                     | 1 FAIL (S7)                                         | the same 1 FAIL              | unchanged; S7 looks for two spellings both trees have since respelled (`m_ld_rm MWD+r4, 0x00, r3`, `ld hl, (xix + 256)`), so it fails at base too                   |
| `scripts/tools/split_v142_subcpu_core.py --check 130735749` | FAIL at base (v142 / v141 / v140 expansions differ) | FAIL                         | it compares the core's expansion with the pre-split monolith; later legitimate edits to core/ already broke it before A3, and A3 moves the kernel text out of core/ |

## New items found on the way

1. RESOLVED 2026-11-06 (lane open10/kernel4, L-kernel-a3-join-probe-stale): `kernel_join_probe.py
   --verify` passes, 16 of 16.  The four failures were post-merge edits, now dated beside CORRECTIONS:
   POST_MERGE_EDITS (8180b9b1d, 2026-10-03: sub_F85EC2 named SoftTimer_RotateLevel3, the 2 "missing"
   lines; b9e3a0657, 2026-08-30: the header paragraph rewritten when the macro block moved to
   include/tlcs900_mem_ops.inc) and RESPELLINGS for the 14 + 14 literal mismatches (c56231510
   `ldw_d16`, f305c6c95 `ldio`, 166c9dc3e `stw_dpi`).  231 of the 244 "stray" lines were that include
   file's own comments: the reverse check read kernel.s's expansion, and now reads kernel.s.  An
   unlisted edit still fails (checked by mutating two comment lines).
   Was: `kernel_join_probe.py --verify` fails 4 checks at base 34bc0c5fe already: prom_a's
   SoftTimer_Request_Boot header gained "-- SoftTimer_RotateLevel3" after the A1 merge (2 lines
   "missing"), the macro-block comment of kernel.s was rewritten on 2026-08-30 (244 "stray"), and 14
   operands were respelled (`(KERNEL_PENDING_TICKS:8)` ...), which its literal comparison does not
   parse.
2. RESOLVED 2026-11-06 (lane open10/kernel4, L-kernel-a3-softtimer-boot-header): prom_a's header now reads
   +2 off the shared callee (`ld WA,(XIX+0x02)` stored to slot+0 and slot+2, the period), and
   `data_range_census.py --images v142,prom_a,prom_c` grades the 8 bytes KNOWN-A ("documented + evidence")
   in all three again (v141 / v140 assemble the same source).  The edit is dated in kernel_a3_merge.py's
   LATER_EDITS and kernel_join_probe.py's POST_MERGE_EDITS, so both --verify still pass.
   Was: prom_a's SoftTimer_Request_Boot header says field +2 is "NOT established"; prom_c's and the KN5000's
   headers (now beside it) both read it off the callee: it is copied into the slot's countdown AND
   reload, i.e. the period.  `data_range_census.py` caps a header that admits ignorance at grade B, so
   in the three payloads those 8 bytes moved KNOWN-A -> KNOWN-B.  Next step: reconcile prom_a's header
   with the other two (a WSA1 documentation edit).

## Follow-up: the KN5000 MAIN CPU's kernel (out of scope here)

FINDINGS sec 7: the main program ROM carries a separate build of the same kernel (v10 at about
0xEF1977-0xEF23AA, `TaskSched_Init` ... `TaskSched_TCBTemplate`; v9 and v7 likewise), with its own
RAM map (five tasks, current task 0x0487, ready heads 0x04C5, stack top 0x0001E53A).  Joining it would
make kernel.s a source for a FOURTH processor:
* a `kernel_kn5000_maincpu.inc` (its RAM map, FINDINGS sec 8's second table) and either a second
  selector value or a KERNEL_KN5000 = 1 build with its own few extra blocks (FINDINGS: "an extra store
  and an extra TCB field initialiser the other three copies do not");
* `kernel_a3_pairing.py` / `kernel_a3_merge.py` re-pointed at the main ROM and its ELF (the order
  test there gives the same 21-of-26 run, so expect the same order once proven boundaries are used);
* its labels renamed to kernel.s's, with the same care for prose that quotes both CPUs:
  six old sub-CPU names are ALSO main-CPU names today (TaskSched_Init, TaskSched_HaltLoop,
  TaskSched_Dispatch, TaskSched_SpawnTask, TaskSched_ExitCurrentTask, TaskSched_ChangePriority), so
  after A3 the two KN5000 CPUs name the same routine differently until that lane runs;
* three trees (v10, v9, v7; v8 rides on v9) instead of one, and the v6 / v5 ports after them.

## Prose outside this tree that quotes the old names (not edited here)

* `../kn7000_mame` (not this lane's repository): `notes/tlcs900-timer-prescaler/README.md:80` and
  `notas/blog/2026-09-25_o_estado_valia_dois_clocks.md:105` quote the sub-CPU's
  `TaskSched_ConfigAndDispatch` (now `Kernel_InitRam__install`, with `Kernel_Start` at its timer-3
  set-up).  (`notes/wsa1-probes/README.md:883`'s `TaskSched_Init` / `TaskSched_TimerTick` are the main
  CPU's and stay.)
* Historical records in this repository keep the names they were written with: the dated lane
  reports and JSON under `notes/lanes/`, `analysis/kn5000-naming/`, `symbols/proposals/`, earlier
  `scripts/renaming/*.sed` / `*.py`, and one-shot converters (`scripts/converters/convert_taskevent_fifo_family.py`,
  `scripts/analysis/trace_blocked_byte_runs.py`).

## Website page drafts (for the integrator's docs pass; technics-docs is not edited here)

### `cpu-subsystem.md`, section on the KN5000's two processors (the run table and the paragraph after it)

Old (table header and rows, sub-CPU column):

    | Sub CPU (v1.42, named from the code)                 | Main CPU (v10 label) | aligned run |
    | `TaskSched_PreemptiveYield`                          | `TaskSched_YieldToQueue` | 63 B at +21 |
    | `TaskSched_Block_Self` — blocks the **calling** task | `TaskSched_Resume` (0xEF1CEC) | 56 B at +15 |
    | `TaskSem_Release` (semaphore V)                      | `Audio_Lock_Release` (0xEF1F0F) | 44 B at +39 |
    | `TaskSem_Release_WakeWaiter`                         | `AudioLock_Release_WakeWaiter` | 16 B at +56 |
    | `TaskSem_TryDec` / `TaskSem_GetCount`                | `AudioLock_TryAcquire` / `AudioLock_GetCount` | 22 B / 26 B |
    | `TaskMsgQ_Send` / `TaskMsgQ_Receive`                 | `TaskMsg_Send` / `TaskMsg_Receive` | 41 B at +37 and 54 B at +102 / 39 B at +23 |

New (same rows; sub-CPU names are now the shared kernel's, `wsa1/kernel/kernel.s`):

    | Sub CPU (v1.42; since 2026-11-06 built from wsa1/kernel/kernel.s) | Main CPU (v10 label) | aligned run |
    | `Kernel_YieldRotate`                                 | `TaskSched_YieldToQueue` | 63 B at +21 |
    | `Kernel_BlockSelf` — blocks the **calling** task     | `TaskSched_Resume` (0xEF1CEC) | 56 B at +15 |
    | `TaskEvent_Signal` / `TaskEvent_Wait_SuspendTask`    | `TaskSched_SignalEvent` / `TaskSched_WaitForEvent_Block` | 38 B / 30 B |
    | `Kernel_SemaSignal` (semaphore V)                    | `Audio_Lock_Release` (0xEF1F0F) | 44 B at +39 |
    | `Kernel_SemaSignal__wake`                            | `AudioLock_Release_WakeWaiter` | 16 B at +56 |
    | `Kernel_SemaTryWait` / `TaskSem_GetCount`            | `AudioLock_TryAcquire` / `AudioLock_GetCount` | 22 B / 26 B |
    | `MsgQueue_Send` / `MsgQueue_ReceiveBlocking`         | `TaskMsg_Send` / `TaskMsg_Receive` | 41 B at +37 and 54 B at +102 / 39 B at +23 |

Old paragraph text: "...with the sub CPU's `TaskSched_SpawnTask`) and 0xEF1C16 (...; 20 B at +29 with
`TaskSched_ExitCurrentTask`) have carried the sub-CPU names since 2026-10-17 ..." and "`TaskSched_SpawnTask`
(formerly `Show_ScreenGroup`) spawns a task. ... (`TaskSched_Init_TaskDescriptors` / `TaskSched_InitTCBFields`,
`TaskSched_Dispatch_ScanQueues` / `TaskSched_ScanPriorityQueues`) and the timer tick (`TaskSched_SoftTimer_Service`
/ `TaskSched_TimerTick`). ... (`TaskSem_Release`'s says it was `TaskSched_PreemptiveYield_INT` until September 2026)."

New paragraph text: "...with the sub CPU's `Kernel_StartTask`) and 0xEF1C16 (...; 20 B at +29 with
`Kernel_ExitTask`) carried the sub-CPU names `TaskSched_SpawnTask` / `TaskSched_ExitCurrentTask` from
2026-10-17; on 2026-11-06 the sub CPU's kernel became the SX-WSA1R's shared source and took its names, so
the main CPU now keeps the old ones until its own kernel is joined. ... `TaskSched_SpawnTask` (formerly
`Show_ScreenGroup`) spawns a task on the main CPU, as `Kernel_StartTask` does on the sub CPU. ...
(`Kernel_InitRam__tcbs` / `TaskSched_InitTCBFields`, `Kernel_Dispatch__pick_task` /
`TaskSched_ScanPriorityQueues`) and the timer tick (`Kernel_ServiceSoftTimers` / `TaskSched_TimerTick`). ...
(`Kernel_SemaSignal`'s KN5000 header says it was `TaskSched_PreemptiveYield_INT` until September 2026, and
`TaskSem_Release` until November)."

### `audio-subsystem.md`, line 616 (state-change bytecode row) and line 1411 (main-CPU lock table)

Old: "releases kernel semaphore 1 (`TaskSem_Release`, WA = 1 ...)" / "byte twin of the sub CPU's `TaskSem_Release`".
New: "releases kernel semaphore 1 (`Kernel_SemaSignal`, WA = 1 ...)" / "byte twin of the sub CPU's
`Kernel_SemaSignal` (`TaskSem_Release` until 2026-11-06)".

### `inter-cpu-protocol.md`, line 67 and the naming table at line 751

Old: "twin of the sub CPU's `TaskSem_Release`" and the row "`Audio_Lock_*`, `AudioLock_*` | `TaskSem_*`, `TaskSched_Wait` | Kernel semaphores ...".
New: "twin of the sub CPU's `Kernel_SemaSignal`" and "`Audio_Lock_*`, `AudioLock_*` | `Kernel_Sema*` (`Kernel_SemaSignal`,
`Kernel_SemaWait`, `Kernel_SemaTryWait`) and `TaskSem_GetCount` | Kernel semaphores ...".

### `mame-pull-requests.md`, line 129

Old: "`INTT3_EnterScheduler` in the main-CPU program and `TaskSwitch_Expired` in the sub-CPU payload".
New: "`INTT3_EnterScheduler` in the main-CPU program and `IRQ_Epilogue__enter_kernel` in the sub-CPU payload
(`TaskSwitch_Expired` until 2026-11-06; the label of the shared kernel source `wsa1/kernel/kernel.s`)".

### `kn7000-task-scheduler.md`, the "Do not trust the KN5000's kernel labels" paragraph (lines 166-173)

Old: "⚠ **Do not trust the KN5000's kernel labels.** The measured alignment does not match them: the site that
actually corresponds to `MsgQueue_Send` is labelled `TaskSched_Wait`, the one matching `Kernel_SemaSignal` is
labelled `TaskEvent_Wait`, and on the main CPU ... Several KN5000 kernel labels are simply wrong — a renaming
pass waiting to happen, ..."

New: "The KN5000 SUB-CPU's kernel labels are settled: since 2026-11-06 that payload builds its kernel from the
SX-WSA1R's `wsa1/kernel/kernel.s` (one source, three processors, `.if KERNEL_KN5000` blocks where the
text differs), and its routines carry the shared names.  The pairing behind the renames was redone routine
against routine on proven boundaries (`wsa1/notes/open9-a3-probes/kernel_a3_pairing.py`): 26 pairs in the
same ROM order on both products.  It also corrected A2's approximate sites: `MsgQueue_Send` is
`TaskMsgQ_Send` (not `TaskSched_Wait`, which is `Kernel_SemaWait`), and `Kernel_SemaSignal` is
`TaskSem_Release` (not `TaskEvent_Wait`; the `TaskEvent_*` event flags have no WSA1 partner).  On the MAIN
CPU the site matching `Kernel_StartTask` at 0.978 was called `Show_ScreenGroup` (renamed
`TaskSched_SpawnTask` on 2026-10-17); its kernel is a separate build and is not joined yet."

### `technics-shared-codebase.md`, "One kernel, four processors, two products" (bullets at lines 198-206)

Add after the first bullet: "* **...and since 2026-11-06 the KN5000's sub-CPU builds it from the same file.**
`wsa1/kernel/kernel.s` assembles into prom_a, prom_c and the KN5000 sub-CPU payload v1.42 (v1.41, v1.40),
all byte-identical.  801 of the KN5000's 1,137 kernel instructions are written once for all three; 30
are spelled per CPU and 306 exist only on the KN5000 (an event-flag family, a lock-depth word in RAM, a
pending-wake count per task) inside `.if KERNEL_KN5000` blocks (`wsa1/notes/open9-a3-probes/`)."
In the summary table row "kernel / RTOS", append "; one source file for three of the four
(`wsa1/kernel/kernel.s`)".

### `wsa1-disassembly.md`, "The two WSA1R processors share ONE SOURCE FILE" (line 260 on)

Add a paragraph after it: "**Since 2026-11-06 the file has a third processor:** the KN5000 sub-CPU payload
includes it through `kernel_kn5000_subcpu.inc`, which sets `KERNEL_KN5000 = 1` (the WSA1 .inc files set
0).  Between the two WSA1 CPUs the difference is still only equates; between the WSA1 and the KN5000 the
text differs in 25 of 26 paired routines, so those runs sit in `.if KERNEL_KN5000` / `.else` blocks
(109 of them), and the WSA1's stack faces in `.if KERNEL_KN5000 == 0`.  The KN5000 routines took the
shared names (`TaskSched_Dispatch` is `Kernel_Dispatch`, ...; `scripts/renaming/rename_kernel_a3.sed`)."
