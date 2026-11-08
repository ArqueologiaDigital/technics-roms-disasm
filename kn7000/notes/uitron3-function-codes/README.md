# The MILK kernel's services, named by their uITRON 3.0 function codes (2026-11-07)

Lane open13/uitron-names.  The owner's request: name the MILK kernel's services in the four
KN7000 program builds (941 `src/program`, 942 `src/sp7001`, 935 `src/b935`, 893 `src/b893`) and in
the SX-KN6000, SX-KN6500 and SX-KN2400 from the uITRON 3.0 function-code table, fix the
mislabelled `loc_cpu`, and commit the evidence.  This continues the lead of
`../sibling-names2/README.md` ("A lead: the MILK kernel's services by their uITRON function codes").

## The source: the uITRON 3.0 specification, and why none of it is here

- "uITRON 3.0 Specification", Ver 3.02.00, TRON Association, document I-01-02E, plain text:
  <https://www.ertl.jp/ITRON/SPEC/FILE/mitron3.02.txt.Z>, sha256 of the `.Z`
  `2e0a2201fbd3c92af66a84b8f60b836ac7a7e1643bba0bc4602808e9cf67abdc`.
- Section 6.3 "Function Codes" is a table of 16 columns, rows H'ff00 .. H'fff0: row + column is
  the 16-bit code, and a service's code read as a signed number is what the firmware passes (cre_tsk
  H'ffef = -17).  Section 6.7 lists the error codes (E_NOMEM -10, E_PAR -33, E_ID -35, E_OBJ -63,
  E_CTX -69, E_QOVR -73, E_TMOUT -85 ...).
- **The specification's licence allows it to be reproduced only in its entirety; any partial
  reproduction is prohibited.**  So no excerpt of it is committed: no copy of the table, no quoted
  text.  `fetch_spec.sh` downloads it into `spec/` (git-ignored, `kn7000/.gitignore`), checks the
  sha256 and decompresses it; `function_codes.py` parses sections 6.3 and 6.7 from that local copy
  each time it runs.  The individual codes quoted in these notes and in the symbol files' comments
  are facts about the firmware, cited to the document, version and section.

## Files

| file                     | question it answers                                                                                                                                                                                               | command (from the repository root)                                                   |
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| `fetch_spec.sh`          | where is the specification `function_codes.py` reads, and is it the copy these notes were written against (sha256)                                                                                                | `sh kn7000/notes/uitron3-function-codes/fetch_spec.sh [COPY.txt.Z]`                  |
| `function_codes.py`      | which uITRON 3.0 service is each kernel routine that reports an error, by the d0 it passes to KernelErrorHook*; is it the service's wrapper or its body; which name does every service-call wrapper and body want | `python3 -I kn7000/notes/uitron3-function-codes/function_codes.py [TREE ...]`        |
| (same, `--selftest`)     | do the 942 export names agree with the specification (7 anchors), do 942's exported forwarders reach the bodies the codes say, is every d0 one defined code, does any label disagree                              | `python3 -I kn7000/notes/uitron3-function-codes/function_codes.py --selftest`        |
| (same, `--codes`)        | the specification's names for the codes the firmware uses, and where the table's own marks disagree                                                                                                               | `python3 -I kn7000/notes/uitron3-function-codes/function_codes.py --codes`           |
| (same, `--rows`)         | the symbol-file rows for the names the evidence asks for (how the rows in the `.sym` files were made)                                                                                                             | `python3 -I kn7000/notes/uitron3-function-codes/function_codes.py --rows [TREE ...]` |
| (same, `--sed DIR`)      | the per-tree rename rules (`scripts/renaming/rename_uitron_services_<tree>.sed`)                                                                                                                                  | `python3 -I kn7000/notes/uitron3-function-codes/function_codes.py --sed DIR`         |
| (same, `--placeholders`) | how many `func_<ADDR>` routine labels each tree has                                                                                                                                                               | `python3 -I kn7000/notes/uitron3-function-codes/function_codes.py --placeholders`    |
| `function-codes.txt`     | the probe's output on the tree of this lane's regeneration                                                                                                                                                        | `python3 -I kn7000/notes/uitron3-function-codes/function_codes.py > ...`             |
| `selftest.txt`           | `--selftest` on the same tree                                                                                                                                                                                     |                                                                                      |
| `placeholders-*.txt`     | `--placeholders` before (the lane's base, dfd9dfd90) and after                                                                                                                                                    |                                                                                      |
| `codes.txt`              | `--codes` on the same tree                                                                                                                                                                                        |                                                                                      |
| `sibling-census-*.txt`   | `../sibling-names-probes/sibling_name_census.py` before (dfd9dfd90, the lane's base) and after                                                                                                                    | `python3 -I kn7000/notes/sibling-names-probes/sibling_name_census.py`                |

The signal it reads: in each tree's generated program source, every `call KernelErrorHook` /
`call KernelErrorHook2`, and among the 8 lines before it (no label between) the last
`mov <imm>, d0` (the function code) and `mov <x>, d1` (the error code; a register when the body
passes on its core's result).  A routine is the nearest label that is not local (`loc_<ADDR>`,
`.L*`, `<routine>_entry`, `<routine>_L<hex>`).  A service-call wrapper is a routine that starts
`add -4, sp / mov d1, (0, sp)` and saves the context with `udf15 d3, d3`.  Bodies are compared
across trees with labels and addresses of 5 or more hex digits masked.

## Result

`function-codes.txt` holds both tables, `selftest.txt` the check (PASS).  Every routine that reports
an error decodes to one defined uITRON 3.0 code; with the names below, no label disagrees with its
code in any tree.

**How a service is built.**  A task calls a service through a *wrapper*: `add -4, sp / mov d1,
(0, sp)`, then (unless the call is nested) the register save with `udf15 d3, d3`, a switch to the
kernel stack and `call <body>_entry`; the *body* does the work and reports errors.  The wrappers are
near-identical bytes for every service.  So the wrapper is named after the service (the name the
firmware's own export table gives it: 942's `unl_cpu`, `wai_sem` ... are wrappers) and the body
`<svc>_Impl`, as `DrawBox` / `DrawBox_Impl` already are.  `loc_cpu`, `sus_tsk`, `ena_dsp` (and 942's
`ref_sem`, `ter_tsk`) are called directly and keep the plain name; `ena_dsp`'s one caller is
`unl_cpu_Impl` (unlocking re-enables dispatching).

**Two services report another's code.**  `preq_sem`'s body passes d0 = -53 (wai_sem's code) and
`prcv_msg`'s d0 = -61 (rcv_msg's), each with d1 = the result of the poll core it shares with the
waiting service (E_TMOUT when the poll fails; e.g. 942 `func_4C03CD31` returns -0x55 when the
semaphore count is below 1).  The code alone would name them wai_sem / rcv_msg; the call structure
does not: 942's export table names the -53 register variant's wrapper `preq_sem`, and the exported
forwarder `prcv_msg_X` calls the -61 register variant's wrapper (`rcv_msg_X` the other's).  Where a
code is reported twice and one reporter passes d1 in a register, that one is the polling service.

**Names by tree.**  "code" = the function code its body reports; "942" = program 942's export table
or exported forwarder (`cre_mbx_X`, `cre_sem_X`, `cre_flg_X`, `ref_sem_X`, `snd_msg_X`), carried to
the other trees by an identical body (labels and addresses masked).

| service  | evidence                          | 941 | 942 | 935 | 893 | KN6000 | KN6500 | KN2400 |
|----------|-----------------------------------|-----|-----|-----|-----|--------|--------|--------|
| rel_blk  | code -143 (E_PAR, E_OBJ)          | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| get_blk  | code -141 (E_OBJ, E_TMOUT)        | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| cre_mpl  | code -137 (E_NOMEM)               | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| rcv_msg  | code -61 (E_CTX); 942 rcv_msg_X   | b   | b   | b   | b   | b      | b      | b      |
| prcv_msg | code -61, polling; 942 prcv_msg_X | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| wai_sem  | code -53 (E_CTX)                  | b   | b   | b   | b   | b      | b      | W+B    |
| preq_sem | code -53, polling; 942 export     | b   | b   | b   | b   | b      | b      | -      |
| wai_flg  | code -46 (E_CTX)                  | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| wup_tsk  | code -39 (E_QOVR)                 | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| slp_tsk  | code -38 (E_CTX)                  | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| sus_tsk  | code -33 (E_OBJ, E_QOVR), direct  | D   | D   | D   | D   | -      | -      | D      |
| ena_dsp  | code -29 (E_CTX), direct          | D   | D   | D   | D   | D      | D      | D      |
| rot_rdq  | code -28 (E_CTX)                  | b   | b   | b   | b   | b      | b      | b      |
| chg_pri  | code -27 (E_ID, E_CTX)            | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| ter_tsk  | code -25 (E_OBJ), direct          | -   | ok  | -   | -   | ok     | ok     | -      |
| exd_tsk  | code -22 (E_OBJ)                  | b   | b   | b   | b   | b      | b      | b      |
| ext_tsk  | code -21 (E_OBJ)                  | -   | b   | -   | -   | b      | b      | -      |
| cre_tsk  | code -17                          | b   | b   | b   | b   | b      | b      | b      |
| loc_cpu  | code -8 (E_CTX), direct           | ok  | ok  | ok  | ok  | ok     | ok     | ok     |
| unl_cpu  | code -7 (E_CTX)                   | b   | b   | b   | b   | b      | b      | b      |
| snd_msg  | 942 snd_msg_X                     | w+B | w+B | w+B | w+B | w+B    | w+B    | w+B    |
| cre_mbx  | 942 cre_mbx_X                     | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| cre_sem  | 942 cre_sem_X                     | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| cre_flg  | 942 cre_flg_X                     | W+B | W+B | W+B | W+B | W+B    | W+B    | W+B    |
| set_flg  | 942 export                        | b   | b   | b   | b   | b      | b      | b      |
| sig_sem  | 942 export                        | b   | b   | b   | b   | b      | b      | b      |
| sta_tsk  | 942 export                        | b   | b   | b   | b   | b      | b      | b      |
| del_mbx  | 942 export                        | -   | b   | -   | -   | b      | b      | -      |
| del_sem  | 942 export                        | -   | b   | -   | -   | b      | b      | -      |
| del_flg  | 942 export                        | -   | b   | -   | -   | b      | b      | -      |
| ref_sem  | 942 ref_sem_X, direct             | -   | D   | -   | -   | D      | D      | -      |
| rsm_tsk  | by hand [INFERENCE], below        | W+B | W+B | W+B | W+B | -      | -      | W+B    |

W+B: the wrapper and its body newly named (`<svc>`, `<svc>_Impl`); b: the wrapper already had the
name (export table or reflection names), its body newly `<svc>_Impl`; w+B: the wrapper renamed
(`LibMsgSend` -> `snd_msg`, `LibMsgReceive` -> `rcv_msg`, the 942 forwarders `snd_msg_X` /
`rcv_msg_X` call them), the body newly named; D: a directly called service newly named; ok: already
named; -: the build has no such routine.

| tree   | labels changed | func_ routines before (dfd9dfd90) | after | symbol file                                                                                                                                 |
|--------|----------------|-----------------------------------|-------|---------------------------------------------------------------------------------------------------------------------------------------------|
| 941    | 39             | 6,327                             | 6,290 | `kn7000_manual.sym`                                                                                                                         |
| 942    | 44             | 6,331                             | 6,289 | `kn7000_sp7001_new.sym` (+ 2 ported LibMsg)                                                                                                 |
| 935    | 39             | 6,324                             | 6,287 | `kn7000_b935_manual.sym` (ported from 941)                                                                                                  |
| 893    | 39             | 6,316                             | 6,279 | `kn7000_b893_manual.sym` (ported from 941)                                                                                                  |
| KN6000 | 41             | 5,671                             | 5,632 | `kn6000_manual.sym`, `kn6000_aligned.sym`                                                                                                   |
| KN6500 | 41             | 5,698                             | 5,659 | `kn6500_manual.sym`, `kn6500_aligned.sym`                                                                                                   |
| KN2400 | 39             | 6,517                             | 6,480 | `kn2400_manual.sym`, `kn2400_aligned.sym`                                                                                                   |
| HD-SX3 | 0              | 459                               | 459   | no kernel of its own (0 KernelErrorHook calls, 0 wrappers; it calls the host's `dly_tsk`, `dis_int`, `ena_int` through registry slot 0x107) |

(`placeholders-dfd9dfd90.txt`, `placeholders-after.txt`; the siblings' census,
`sibling-census-dfd9dfd90.txt` / `sibling-census-after.txt`, reads the same starts and also the
`_entry` labels: func_ (stats) KN6000 9,910 -> 9,843, KN6500 9,966 -> 9,899, KN2400 11,315 -> 11,254.)

**rsm_tsk [INFERENCE].**  One wrapper has no function code (its body reports no error) and no name
of the firmware's own: 941 `0x4C03D7E2` (942 `0x4C03DB4A`, 893 `0x4C03D7CF`, KN2400 `0x5018D8C7`;
the KN6000 / KN6500 have neither it nor `sus_tsk`).  Its body (d0 = task id) counts the task's
TCB +0x12 down by one and, at zero, makes the task ready if its wait state is 2 (suspended only) or
clears the suspend bit 2: the inverse of `sus_tsk`, which counts +0x12 up (E_QOVR at 0x7FFF) and
sets that bit.  `sus_tsk`'s three callers call it in mirror order (941 `FdcPrgReadDataCmdTasksHeld`:
`sus_tsk(7)`, `sus_tsk(3)`, work, `rsm_tsk(3)`, `rsm_tsk(7)`).  uITRON's `rsm_tsk` returns E_OBJ
for a task that is not suspended; this body does not check, and nothing else in the image resumes.

## `loc_cpu` was never mislabelled: the probe was

The wave-12 notes read -8 as "`clr_flg` in the KN6000 / KN6500 but `ena_int` in the KN2400" and the
lane brief carried it as "the -8 routine is loc_cpu but is labelled ena_int / clr_flg".  In all
seven trees the routine that reports -8 is labelled `loc_cpu`, and its body is uITRON's loc_cpu
(E_CTX when called from a task-independent part; else the dispatch-disabled state 3 and
`and 0xf7ff, psw`).  `../sibling-names2-probes/kernel_errorhook_codes.py` (and the research-scratch
variant `itron-2026-11-06/kn7000_errorhook_codes.py`) skipped every label starting `loc_`, meant
for the local `loc_<ADDR>`, so `loc_cpu` was skipped and its code went to the routine before it:
`clr_flg` where the kernel has one (942, KN6000, KN6500), `ena_int` where it does not (941, 935,
893, KN2400).  Those two labels are right too: `clr_flg` ANDs a pattern into an event flag record
(0x50380088 + 20 x id, +0xC), `ena_int` sets an interrupt's enable bit, or PSW.IE for id 0.  The
probe is fixed (it skips only `loc_<ADDR>`), its output re-measured, the wave-12 text corrected
(`../sibling-names2/README.md`).  No other label was affected: the same skip rule decided only
which routine a hook call belongs to, and every routine `function_codes.py` sees agrees with its code.

## A real mislabelling this lane found and avoided: the port to 942

`make symbols-sp7001` ports `kn7000_manual.sym` (941) to 942 through the byte offset map.  The
wrappers being near-identical, the map put 941's `get_blk` on 942's `del_mbx` wrapper, `wai_flg` on
`del_sem` and `sus_tsk` on `ref_sem`'s body: the services 942 inserted just before them.  The wrong
rows then made 942's own export names `del_mbx` / `del_sem` "aliases".  Builds 935 and 893 port
right (the probe checked every row).  The fix: `tools/port_symbols.py --authority FILE` leaves
unported every name FILE places itself, and `symbols-sp7001` passes `kn7000_sp7001_new.sym`, which
holds 942's kernel names as `function_codes.py --rows 942` makes them from 942's own code.
`tools/itron_stubs.py` fixes the same kind of misalignment for the export names (942 -> 941).

## The specification's table disagrees with itself once

In the H'ffc0 row the line that marks ITRON2-only codes with `-` puts the mark of the semaphore half
one column right of the row's `V2` annotation (on H'ffcb instead of H'ffca).  Program 942's export
`wai_sem` reports -53 = H'ffcb, so the `V2` annotation is the one that is aligned; the parser takes
the `V2` line wherever a block has one and prints the disagreement (`--codes`, `codes.txt`).

## What is not named

- Every error-reporting routine, every wrapper and every body a wrapper calls is named in all seven
  trees.  This lane left as func_ the kernel's inner routines no wrapper calls directly and that
  report no code (the poll cores such as 942 `func_4C03CD31`, the ready-queue and wait-queue
  helpers, the interrupt lock pair ...): the function codes say nothing about them.  Lane
  open14/kn7000-subsystems named many of them from their bodies (`KernelTaskReadyRemove`,
  `KernelQueueRemove`, `KernelTaskReadyInsert`, `KernelPswGet` / `KernelPswSet` ...;
  `../kn7000-subsystems/README.md`).
- The callee records the kernel's `cre_*` services read (`REC_cre_flg_ArgA0`, 12 bytes:
  uITRON's `T_CFLG` {exinf, flgatr, iflgptn} by size) are not typed as uITRON packets yet; `T_CTSK`
  is (`tools/data_struct_names.py`).  Next step: name their fields from `cre_flg_Impl`'s reads.

## Website page draft

*For technics-docs' KN7000 firmware page (and the KN6000 / KN2400 disassembly pages), a section
"The MILK kernel" after the memory map; text only, the integrator publishes it.*

> **The MILK kernel is a uITRON 3.0 kernel.**  Its services report errors to an empty hook with the
> service's uITRON 3.0 function code (the TRON Association's "uITRON 3.0 Specification" Ver 3.02.00,
> section 6.3) and a uITRON error code, so the codes name them, in the KN7000's program v1.3, v1.5,
> v1.6 and SP7001 builds and in the SX-KN6000, KN6500 and KN2400 alike.  A
> task calls most services through a small wrapper that saves its context and switches to the kernel
> stack; the disassembly names the wrapper after the service (`wai_sem`) and the routine that does
> the work `wai_sem_Impl`.  `loc_cpu`, `sus_tsk` and `ena_dsp` are called directly.  The SP7001
> build exports 20 kernel services by name to its plug-in, and 10 more through small forwarders
> (`cre_tsk_X` ...); wherever a name and a code meet, they agree.
