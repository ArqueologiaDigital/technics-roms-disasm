# open10-kernel4-probes -- lane open10/kernel4 (wave 10, 2026-11-06)

Five register items: the KN5000 main CPU's kernel joined to `wsa1/kernel/kernel.s` (L-kernel-a3-kn5000-maincpu),
prom_a's SoftTimer_Request_Boot header (L-kernel-a3-softtimer-boot-header), `kernel_join_probe.py --verify`'s stale
failures (L-kernel-a3-join-probe-stale), and two WSA1R screen questions (N-1e4a337c, N-813b5071).

| script                                    | question it answers                                                                                                                                    | run (exact command)                                                                                                                                               |
|-------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `format_screen_requests.py`               | What are screen 0x52 and (0x21E8) bit 2 behind HiddenKey_FloppyDiskFormatSelectType, and what is UI_Request 0x0201?                                    | `python3 wsa1/notes/open10-kernel4-probes/format_screen_requests.py` (repo root)                                                                                  |
| `kernel4_maincpu.py --pairing --selftest` | Which main-CPU kernel instruction and label IS which kernel.s one, in v10, v9 and v7?                                                                  | `UNIDASM=/home/fsanches/compartilhado/mame-sony-video/unidasm python3 notes/open10-kernel4-probes/kernel4_maincpu.py --pairing --selftest` (in wsa1/, built tree) |
| `kernel4_maincpu.py --report`             | How much of the kernel is written once for all four processors?                                                                                        | `... kernel4_maincpu.py --report`                                                                                                                                 |
| `kernel4_maincpu.py --verify`             | Did the join only grow kernel.s, keep the WSA1 and sub-CPU views' code, move every main-CPU comment and label, and leave no old name in main-CPU code? | `... kernel4_maincpu.py --verify`                                                                                                                                 |
| `kernel4_maincpu.py --emit`               | (the job, done once) wrote the kernel.s edits, `kernel_kn5000_maincpu.inc`, the three trees' include and `rename_kernel4.sed` from the current tree    | record only; kernel.s is the source                                                                                                                               |

## N-1e4a337c: the hidden key count on FLOPPY DISK FORMAT (screen 0x50)

`sub_FF657B` (now `HiddenKey_FloppyDiskFormatSelectType`) is the handler of KEY_SoftKeyCol4 and KEY_SoftKeyCol5Alt on
screen 0x50.  While (0x21E8) bit 2 is set it counts presses in DiskScreen_RowOption; the press after the eighth posts
UI_Request 0x8052.  Measured off the EPROM bytes (`format_screen_requests.py`):

* A2: `PanelScreen_VtableTable_ViewB[0x52]` (0xF86F41 + 4 * 0x52) holds 0xF872C1 = `PanelScreen_NullVtable`, four
  `jr` to one `ret`: screen 0x52 is an EMPTY screen in this build (81 of the 256 entries hold that object).
* A3: of the 19 instructions in prom_a and prom_b whose (#16) operand covers 0x21E8, none can set bit 2 (reads; `res
  3/5`, `set 3`; `xor 0x08`; `or 0x80`; `and 0x7F`).  No (#24) form names it.  Eleven instructions load a pointer to
  0x21E7 or 0x21E8; read by hand, every 0x21E7 one is used only as `(XIX)` until XIX is reloaded, and the 0x21E8 one
  (Playback_SilenceAll, 0xFE2E97) sets and clears bit 6 only.
* So the count can never run in this firmware, and if it ran, it would open an empty screen: a test feature whose
  screen was removed (an inference; a block move or a computed address that nobody has found could still set the bit).

## N-813b5071: UI_Request 0x0201 after a format

YES on the confirmation (LcdKeyRow3_FloppyDiskFormatAreYouSure) posts 0x0201 after DiskFormat_Execute_Entry.

* B1: (0x2071) = 0x02 is bit 1, which PanelState_RunRequests hands to PanelScreen_ApplyModeChange (0xF86318, `bit
  1,A`): a MODE request, not a screen request.  PanelMode_Normalise (0xF86344) turns a requested mode 1 into 1, or
  into 2 when (0x7F02) & 0xF0 == 0x10, the cell Mode_SwitchToCombination sets.
* B2: `PanelMode_ToScreenIdMap[1]` / `[2]` are screens 0x01 / 0x02, whose ViewB objects are
  T_InstallPainter_SoundMode_Entry and T_InstallPainter_CombinationMode_Entry.
* B3: six places post 0x0201: the format YES, EXIT on the DISK menu (ExitKey_DiskMenu), DiskSaveFile_SaveNow,
  MidiFilePlay_OnSongSelect, EditScreen_EnterNoteEdit and 0xFF7590.  So 0x0201 means "back to the play screen of the
  current mode (SOUND or COMBINATION)".

Both answers are now in the routine headers (`wsa1/prom_a/modules/ff3800_ff7fff_disk_menu_screens.s`); the label is
renamed by `scripts/renaming/rename_kernel4_wsa1_screens.sed`.

## L-kernel-a3-kn5000-maincpu: the KN5000 main CPU's kernel is kernel.s's fourth processor

The owner's decision of 2026-11-06 ("one kernel source ... with conditional blocks through most routines") covers it.
Measured first (`kernel4_maincpu.py --pairing`, BASE a385de42f): the main CPU's kernel extent (TaskSched_Init ..
the end of TaskSched_TCBTemplate, 0xEF1977-0xEF23D9 in v10) against kernel.s's KN5000 view (the sub-CPU build's
text) at v1.42 payload addresses, both decoded off the dumps by MAME unidasm, one LCS over the whole extent:

| measure                                               | v10   | v9    | v7    |
|-------------------------------------------------------|-------|-------|-------|
| slots, main CPU (the 8-byte argument block = 1)       | 1,135 | 1,135 | 1,135 |
| slots, kernel.s KN5000 view                           | 1,135 | 1,135 | 1,135 |
| aligned                                               | 1,133 | 1,133 | 1,133 |
| aligned and byte-identical to the sub-CPU             | 1,030 | 1,030 | 1,030 |
| kernel.s KN5000 routines paired (scores 0.98-1.00)    | 33    | 33    | 33    |
| main labels landing on a kernel.s label               | 73/73 | 73/73 | 73/73 |
| muITRON stubs (`rot_rdq_X` ...) on the paired routine | 11/11 | 11/11 | 11/11 |

So the two KN5000 kernels are ONE build over two RAM maps: every aligned pair that is not byte-identical differs
only in an operand that `kernel_kn5000_maincpu.inc` names.  The text differs in two places (the event-flag and
semaphore copy lengths: `ld bc, N:i3` on the sub-CPU, N = 2 and 4; `ldw bc, N` here, N = 10 and 12, which do not fit
in 3 bits).

### The design, and why

* **Selector: one symbol, a processor number.**  `KERNEL_KN5000` = 0 (SX-WSA1R, both CPUs), 1 (KN5000 sub-CPU),
  2 (KN5000 main CPU).  `.if KERNEL_KN5000` stays "both KN5000 processors", which is exactly right: the measurement
  says their text is the same.  `.if KERNEL_KN5000 == 2` / `.else` holds the two main-CPU lines.  A second symbol
  would have doubled every existing `.if` for no gain.
* `wsa1/kernel/kernel_kn5000_maincpu.inc`: the main CPU's RAM map (0x0485-0x05C4) and counts (5 tasks, 3 levels,
  10 event flags, 12 semaphores, 5 message queues, 10 nodes, 1 soft timer), three ROM labels, `KERNEL_TICK_TREG3`.
* Three sub-CPU lines spelled a per-CPU value as a literal or a label (`ld b, 0x2:opc`, `ld xhl,
  TaskSched_EventFlagInit`, `ld (TREG3:8), 0x1D:io`) and now name it (`KERNEL_EVENT_COUNT`,
  `KERNEL_EVENT_FLAG_IMAGE`, the new `KERNEL_TICK_TREG3`, 0x1D in kernel_kn5000_subcpu.inc).  Same sub-CPU bytes.
* v10, v9 (and v8, its build) and v7 replace the region with `.include "kernel_kn5000_maincpu.inc"` / `.include
  "kernel.s"` (`-I wsa1/kernel`; Makefile `MAINCPU_KERNEL_SRC`).  The kernel's data (task table, flag and semaphore
  images), INTT3_HANDLER / INTT3_PriorityAdjust, the null callback and TaskSched_DelayTicks stay in each tree.
* Comments: every main-CPU comment line of the region (v10's 54; v9's and v7's 39 are a subset but for one
  respelled line, `VARIANTS`) moved into kernel.s, renamed, under
  `; >>>>>> moved from v10/maincpu/boot/system_handlers.s -- the KN5000 MAIN CPU >>>>>>` with a record of the
  routine's old main-CPU names.
* **v6 and v5** are not joined: their kernel stays their own text (another lane owns their TODO(port) rows), and only
  its labels were renamed by the same sed.  `check_ported_labels.py --src v7 --dst v6` / `--src v6 --dst v5`: none of
  the renamed kernel labels is misplaced.

`--report` on the result:

| code lines from Kernel_InitRam on                      | count               |
|--------------------------------------------------------|---------------------|
| WSA1 view / KN5000 sub-CPU view / KN5000 main-CPU view | 941 / 1,137 / 1,137 |
| written once for all four processors                   | 801                 |
| written once for the two KN5000 processors             | 334                 |
| main CPU only (`.if KERNEL_KN5000 == 2`)               | 2                   |
| sub-CPU only (their `.else`)                           | 2                   |

### Names

73 main-CPU kernel labels took kernel.s's names, and six labels outside the extent took the sub-CPU's
(TaskSched_TaskTable -> TaskSched_TaskDescriptorTable, _ExtQueueByteInit -> TaskSched_EventFlagInit,
_ExtQueue2ByteInit -> TaskSched_SemaphoreInit, TaskTimer_NullCallback -> TaskSched_NullTimerCallback,
Start_8bit_Timer_3 / Stop_and_Clear_8bit_Timer_3 -> Timer3_Start / Timer3_Stop):
`scripts/renaming/rename_kernel4.sed`, applied to v10, v9, v7, v6, v5 (63 files).  So the six names the sub-CPU
gave up in A3 are gone from the main CPU too: TaskSched_Init = Kernel_InitRam, TaskSched_HaltLoop =
Kernel_Idle__loop, TaskSched_Dispatch = Kernel_Dispatch, TaskSched_SpawnTask = Kernel_StartTask,
TaskSched_ExitCurrentTask = Kernel_ExitTask, TaskSched_ChangePriority = Kernel_SetTaskLevel -- the two KN5000
processors now call each routine by one name.  Audio_Lock_Acquire / Audio_Lock_Release are Kernel_SemaWait /
Kernel_SemaSignal (they always were the kernel's generic semaphores).  "TaskSched_TCBTemplate" was code:
Kernel_KillTask.

Prose fixed in this tree: CLAUDE.md (prefix table, symbol counts), docs/IS-IT-DONE.md,
tools/spelling-probes/README-inc_reg.md, notes/DRIVER-INSIGHT-kn5000-2026-09-02.md,
wsa1/notes/FINDINGS-kernel-in-the-kn5000.md (sec 7: the approximate sites, sec 8: the main-CPU map's
event/semaphore mix-up), wsa1/notes/open9-a3-probes/README.md.  Left as history: dated lane reports and JSON
(notes/lanes/, analysis/), earlier scripts/renaming/*, v7/maincpu/transplant_manifest.txt (a record of 2026-10
bins), scripts/analysis/v7_shift_map.json.  ⚠ Outside this lane's files, for the integrator:
`hdae5000*/hdae5000_ui_display.s` line ~590 quotes `AudioLock_GetCount` (now TaskSem_GetCount) in a comment.

### Checkers

| checker                                              | result                                     |
|------------------------------------------------------|--------------------------------------------|
| `make gate`                                          | see the commit                             |
| `kernel4_maincpu.py --verify`                        | 20 checks, 0 failures                      |
| `kernel4_maincpu.py --pairing --selftest`            | ok                                         |
| `../open9-a3-probes/kernel_a3_merge.py --verify`     | 12 checks, 0 failures                      |
| `../open9-a3-probes/kernel_a3_pairing.py --selftest` | ok                                         |
| `../kernel_join_probe.py --verify`                   | 16 of 16 (takes this join's origin lines)  |
| `l2_symbol_reference.py --check`                     | all OK after `--regen` of the 7 main files |

Tools taught the fourth processor: `asm_source.cpu_view(kn5000=0|1|2)` (`.if KERNEL_KN5000 == N` / `!= N`),
`doc_quality_census.py` (`KERNEL_CPU`: v10/v9/v8/v7 read kernel.s as 2, `-I wsa1/kernel`), `data_range_census.py`
(`xmirrors=["wsa1/kernel"]` for v10/v9/v8/v7), `kn5000_source_coverage.py` (`EXTRA_SRC` / `EXTRA_CPU`),
`assert_images_assemble.py`.  NOT taught (one-shot lane tools that assemble a main tree with their own `-I`, and
would now need `-I wsa1/kernel`): scripts/analysis/lane_line_map.py, seqeng_line_map.py, v7_blocking_forms_census.py,
scripts/lanes/sys/port_islands.py.

`diffs/` (policy 10): the committed v9-vs-v10 diff is stale since 2026-03-25 (44 lines against 10,582 today, all
lanes' work); this join removes the kernel region from both trees, so their kernel diff is empty by construction.
Not regenerated here (another lane edits v10 / v9 this wave): regenerate after the wave's merges with
`diff -r --exclude=*.bin --exclude=*.o --exclude=generated v9/maincpu v10/maincpu`.

## Website page drafts (for the integrator's docs pass; technics-docs is not edited here)

Every page below quotes old main-CPU names; the mechanical part is `sed -f scripts/renaming/rename_kernel4.sed` on
the page.  Where that would make a sentence wrong, the text is given.

### `firmware-flowchart.md`, lines 40 and 123

Old: `TASK_INIT["TaskSched_Init<br/>0xEF1977"]` / `SCHED["TaskSched_Dispatch<br/>0xEF1AC0 — run next ready task"]`.
New: `TASK_INIT["Kernel_InitRam<br/>0xEF1977"]` / `SCHED["Kernel_Dispatch<br/>0xEF1AC0 — run next ready task"]`.

### `floppy-security-analysis.md`, line 195

Old: "... and `TaskSched_Init` later moves it to `0x01E53A` in work DRAM."
New: "... and `Kernel_InitRam` (the shared kernel's start-up, `wsa1/kernel/kernel.s`; `KERNEL_STACK_TOP` in
`kernel_kn5000_maincpu.inc`) later moves it to `0x01E53A` in work DRAM."

### `cpu-subsystem.md`, the two-processor run table and the paragraphs after it (lines 255-295)

Replace the sentence "The main-CPU source still carries these names:" and the table by:

    That is how the subcpu lane (September 2026) found several main-CPU kernel names to be wrong.  Since
    2026-11-06 the question is closed: both KN5000 processors build their kernel from the SX-WSA1R's
    `wsa1/kernel/kernel.s` (`KERNEL_KN5000` = 1 the sub CPU, 2 the main CPU), and one LCS over the main CPU's
    whole kernel against the sub CPU's text aligns 1,133 of 1,135 instructions, 1,030 of them byte-identical
    (`wsa1/notes/open10-kernel4-probes/kernel4_maincpu.py --pairing`): one build over two RAM maps.  The
    main-CPU names that table listed are now the shared ones:

    | Main CPU, until 2026-11-06                 | Both KN5000 CPUs now                         |
    |--------------------------------------------|----------------------------------------------|
    | `TaskSched_YieldToQueue`                   | `Kernel_YieldRotate`                         |
    | `TaskSched_Resume` (0xEF1CEC)              | `Kernel_BlockSelf`                           |
    | `TaskSched_SignalEvent` / `_WaitForEvent`  | `TaskEvent_Signal` / `TaskEvent_Wait`        |
    | `Audio_Lock_Release` (0xEF1F0F)            | `Kernel_SemaSignal`                          |
    | `Audio_Lock_Acquire` (0xEF1FEE)            | `Kernel_SemaWait`                            |
    | `AudioLock_TryAcquire` / `_GetCount`       | `Kernel_SemaTryWait` / `TaskSem_GetCount`    |
    | `TaskMsg_Send` / `TaskMsg_Receive`         | `MsgQueue_Send` / `MsgQueue_ReceiveBlocking` |
    | `TaskSched_SpawnTask` / `_ExitCurrentTask` | `Kernel_StartTask` / `Kernel_ExitTask`       |
    | `TaskSched_Init` / `TaskSched_Dispatch`    | `Kernel_InitRam` / `Kernel_Dispatch`         |

Then: "The table used to have two more rows ... until its own
kernel is joined." -> "The main CPU routines at 0xEF1B9C (formerly `Show_ScreenGroup`) and 0xEF1C16 carried the
sub-CPU names `TaskSched_SpawnTask` / `TaskSched_ExitCurrentTask` from 2026-10-17 and are `Kernel_StartTask` /
`Kernel_ExitTask` since 2026-11-06; the first fills a task's TCB from `TaskSched_TaskDescriptorTable` and queues it,
the second ends the calling task."  "So **`Audio_Lock_Acquire` / `Audio_Lock_Release` are the kernel's generic
semaphore P/V routines**" -> "So **`Kernel_SemaWait` / `Kernel_SemaSignal` (`Audio_Lock_Acquire` /
`Audio_Lock_Release` until 2026-11-06) are the kernel's generic semaphore P/V routines** -- the main program
exports them to its plug-ins as the muITRON calls `wai_sem_X` / `sig_sem_X`".  "`TaskSched_SpawnTask` (formerly
`Show_ScreenGroup`) spawns a task on the main CPU, as `Kernel_StartTask` does on the sub CPU.  `TaskSched_Resume`
puts the calling task to sleep" -> "`Kernel_StartTask` (formerly `Show_ScreenGroup`, then `TaskSched_SpawnTask`)
spawns a task on both CPUs.  `Kernel_BlockSelf` (the main CPU's `TaskSched_Resume`) puts the calling task to
sleep".  The pairs "(`Kernel_InitRam__tcbs` / `TaskSched_InitTCBFields`, `Kernel_Dispatch__pick_task` /
`TaskSched_ScanPriorityQueues`) and the timer tick (`Kernel_ServiceSoftTimers` / `TaskSched_TimerTick`)" -> one
name each: "(`Kernel_InitRam__tcbs`, `Kernel_Dispatch__pick_task`) and the timer tick (`Kernel_ServiceSoftTimers`)".

### `inter-cpu-protocol.md`, lines 66-84, 353-354, 723-728

sed (Audio_Lock_Acquire -> Kernel_SemaWait, Audio_Lock_Release -> Kernel_SemaSignal); at line 66 add "(the main
CPU's `Audio_Lock_*` until 2026-11-06)".  Line 84: "head at `0x04FF + 4 × lock_index`" is
`KERNEL_SEMA_QUEUES - 4` = 0x0503 - 4, correct as written.

### `audio-subsystem.md`, lines 17, 1410-1411; `display-subsystem.md`, line 372; `event-codes.md`, line 330

sed.  Line 1411: "byte twin of the sub CPU's `Kernel_SemaSignal`" -> "the same source line as the sub CPU's (one
kernel, `wsa1/kernel/kernel.s`)"; add "(`Audio_Lock_Acquire` / `_Release` until 2026-11-06)" to the two rows.

### `wsa1-disassembly.md`, line 279; `kn7000-task-scheduler.md`, line 179; `mame-pull-requests.md`, line 129

`wsa1-disassembly.md`: after "... `scripts/renaming/rename_kernel_a3.sed`, and `wsa1/notes/open9-a3-probes/`)." add
"**The same day the KN5000's main CPU became a fourth processor** (`kernel_kn5000_maincpu.inc`, `KERNEL_KN5000 =
2`): its text is the sub CPU's but for two copy lengths, 801 kernel lines are written once for all four
processors (`wsa1/notes/open10-kernel4-probes/`)."  `kn7000-task-scheduler.md`: "(renamed `TaskSched_SpawnTask` on
2026-10-17); its kernel is a separate build and is not joined yet." -> "(renamed `TaskSched_SpawnTask` on
2026-10-17, `Kernel_StartTask` on 2026-11-06, when the main CPU's kernel was joined to `wsa1/kernel/kernel.s` as a
fourth processor)."  `mame-pull-requests.md`: "`INTT3_EnterScheduler` in the main-CPU program and
`IRQ_Epilogue__enter_kernel` in the sub-CPU payload (`TaskSwitch_Expired` until 2026-11-06; ...)" -> "
`IRQ_Epilogue__enter_kernel` in both KN5000 programs (the main CPU's `INTT3_EnterScheduler` and the sub CPU's
`TaskSwitch_Expired` until 2026-11-06; the label of the shared kernel source `wsa1/kernel/kernel.s`)".

### `technics-shared-codebase.md`, "One kernel, four processors, two products"

Add: "Since 2026-11-06 all four processors build it from one file: `wsa1/kernel/kernel.s` assembles into prom_a,
prom_c, the KN5000 sub-CPU payloads and the KN5000 main program (v10, v9, v8, v7), all byte-identical; 801
instructions are written once for all four, 334 more once for both KN5000 CPUs, 2 per KN5000 CPU."
