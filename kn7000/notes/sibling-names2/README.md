# Lane open12/sibling-names2 (2026-11-06, wave 12): routine and RAM names in the MN10300 siblings, round 2

Wave 12 continues wave 11's lane (`../sibling-names/README.md`, whose tools and regeneration order
this lane uses unchanged).  Items: routine names N-a810f3f6 (KN6000), N-f22bdce4 (KN6500),
N-b3ba9d8b (KN2400); RAM operands N-8fce01b1 (KN6000), N-cccf0416 (KN6500), N-dc17693c (KN2400).
They are L backlogs and stay OPEN; the aim was measured progress with evidence.  Also handled:
the KN6000 / KN6500 24-typed-byte regression lane mn10300-data3 recorded
(`../mn10300-data3/README.md`, section 3).  The probes are in `../sibling-names2-probes/` (README
there); every figure below comes from one of them or from the tools' own reports
(`<model>/notes/aligned-names-report.md`, `<model>/notes/ram-names-report.md`).

## What changed in `port_names_by_alignment.py`

| rule (header name) | what it does                                                                                                                                                                                                                                                                                                        | evidence that it is safe (audit, where the answer is known)                                                                                                                                                           |
|--------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `is_region_base`   | a RAM window's base (0x50000000, 0x90000000, 0x84000000) is a memory-map constant, not a variable: its 941 name (`WORK_RAM_BASE`) is no longer carried                                                                                                                                                              | the regression it caused, below                                                                                                                                                                                       |
| RUNS               | a relinked module keeps its variables' order and spacing, so the RAM pairs come in runs of one delta (B - A); between two voted pairs that are neighbours in B's order and share the delta (at most `--ram-run-gap` 0x1000 apart), every RAM address both codes spell pairs by that delta; the twin pass reads them | `ram_run_premise.py` on the voted pairs: KN6000 1,125 right / 2 wrong, KN6500 1,152 / 2, KN2400 1,900 / 2 (gap 0x1000); the wrong count stays 2 from gap 0x40 to 0x10000; the exceptions are 1- to 3-byte field moves |
| POINTERS, operand  | an aligned operand that is a routine start on both sides (`mov func, d0`, a callback handed over) pairs the two routines, one support of the anchor's class, through the call-site tests                                                                                                                            | pairs both images name, paired by operands alone: KN6000 11 right / 0 wrong, KN6500 13 / 0, KN2400 19 / 0                                                                                                             |
| POINTERS, table    | an aligned operand that is a data address on both sides pairs two tables; their 32-bit words pair at equal offsets while both or neither are code addresses; a table is used only when 2+ of its words are routines both images name alike and none unlike                                                          | leave one out: KN2400 1,684 right / 5 wrong, KN6000 4 / 0, KN6500 4 / 0.  Unchecked (`--table-agree -1`), the KN2400's named table words are 3,080 alike / 1,786 unlike, the KN6000's 11 / 7: the check is needed     |

Both audits that already existed did not get worse: call sites KN6000 488 / 2 -> 498 / 2, KN6500
491 / 2 -> 504 / 2, KN2400 650 / 3 -> 674 / 3 (right / wrong; the same two and three wrong pairs
wave 11 lists); same-body routines picked by mapped operands KN6000 122 / 0 -> 126 / 0, KN6500
125 / 0 -> 130 / 0, KN2400 190 / 0 -> 201 / 0.

## The WORK_RAM_BASE regression (lane mn10300-data3)

`kn6000_aligned.sym` / `kn6500_aligned.sym` (and `kn2400_aligned.sym`) named 0x50000000
`WORK_RAM_BASE`, carried from 941's `kn7000.sym` memory-map row.  The data generator then read the
first field of KN6000 `func_4C0506C7_entry_L4_Records` (0x50000000, 0x58000000, 0x54000000:
bus-window bases, values) as a pointer, and the inferred count stopped at the first record whose
field is no named address (3 records -> 1).  The cause was the name, so it is fixed on the naming
side: `is_region_base` keeps the base unnamed, and the regeneration types the array as 3 records
again (`kn6000/src/program/data/data_03.s`, `REC_func_4C0506C7_entry_L4_Records f0=0x50000000` /
`0x58000000` / `0x54000000`; KN6500 likewise).  Nothing is left for lane mn10300-data4.  The cost:
the six KN6000 operands (five KN2400) that spelled the base, `or WORK_RAM_BASE, d0` and
`mov WORK_RAM_BASE, d0` (composing an address in the window), are numbers again, which is why the
KN6000 / KN6500 work-RAM operand counts below rise by 3.

## Results

`../sibling-names-probes/sibling_name_census.py`, at the base e53dc9b3a
(`../sibling-names2-probes/census-e53dc9b3a.txt`) and after (`census-after.txt`):

| model  | func_ (stats) before | after  | func_ starts before | after | named before | after | work RAM ops / addrs before | after          |
|--------|----------------------|--------|---------------------|-------|--------------|-------|-----------------------------|----------------|
| KN6000 | 9,917                | 9,910  | 5,678               | 5,671 | 2,785        | 2,792 | 17,752 / 2,524              | 17,755 / 2,522 |
| KN6500 | 9,972                | 9,966  | 5,704               | 5,698 | 2,792        | 2,798 | 17,788 / 2,533              | 17,791 / 2,531 |
| KN2400 | 11,340               | 11,315 | 6,538               | 6,517 | 3,420        | 3,441 | 20,931 / 2,940              | 20,908 / 2,933 |
| HD-SX3 | 765                  | 765    | 459                 | 459   | 179          | 179   | 0 / 0                       | 0 / 0          |

Where the names came from (the tools' reports):

| model  | aligned routine names | of them on pointers alone | RAM = (941) | accessor RAM names | owner RAM names | RAM pairs (voted + runs)     |
|--------|-----------------------|---------------------------|-------------|--------------------|-----------------|------------------------------|
| KN6000 | 108 -> 115            | 4                         | 8 -> 7      | 25 -> 25           | 458 -> 461      | 1,613 -> 2,123 (1,620 + 503) |
| KN6500 | 108 -> 114            | 2                         | 9 -> 8      | 25 -> 25           | 458 -> 461      | 1,636 -> 2,124 (1,643 + 481) |
| KN2400 | 228 -> 249            | 6                         | 8 -> 8      | 21 -> 28           | 613 -> 613      | 2,258 -> 3,147 (2,284 + 863) |
| HD-SX3 | 2 -> 2                | 0                         | 0           | -                  | -               | 0                            |

Four of the KN2400's new names are the KN7000's own since wave 11 (`JpegEncSetup`,
`JpegEncImage`, `JpegEncMcu`, N-99771106, and `KeyZoneNoteResolve`, from lane kn7000-research2
merged during this lane): that is the wave-11 next step "re-run with the KN7000 names", and it is
all it gave; the KN6000 / KN6500 had no routine the new KN7000 names reach.  The
KN2400's RAM-linked tone-generator library (941's library at 0x4C000000): 418 -> 424 of 941's 544
names (`missed-kn2400-tglib-after.txt`); the short identical-code routines without a name there
fell from 36 to 30.  The 30 left (`TgGlobalChanBRefresh`, `TgGlobalChan3Refresh` ... in 941) are
told apart only by one byte variable each in a block whose layout the KN2400 changed: 941 reads
0x500C076F and 0x500C0777, the KN2400 0x500937AA, 0x500937AE, 0x500937AF (the run's delta maps
0x500937AA to 0x500C076E, not 0x500C076F), so no RAM pair can be right for them.

Each regeneration ended in a fixed point: after `aligned-names`, `data-and-code-src`, `ram-names`,
`data-and-code-src`, `gui-map`, a second `aligned-names` wrote the same `<model>_aligned.sym`, and
`data-and-code-src` reached its own fixpoint in 2 to 3 rounds.  All four images rebuild
byte-identical (`make -C <model> verify`).

`make doc-quality` (`docs/coverage/doc-quality-2026-11-06-15`, against -14: nothing rose) reads
the same change: (e) placeholder routine names KN6000 5,678 -> 5,671, KN6500 5,704 -> 5,698,
KN2400 6,538 -> 6,517; (b) operands spelled as a number outside the image KN6000 14,501 -> 14,498,
KN6500 14,522 -> 14,519, KN2400 15,810 -> 15,787.

## Name sources measured and not adopted

`../sibling-names2-probes/name-source-trials.txt` (`name_source_trial.sh`, the tool with the rules
above):

| B      | source            | names it would carry | audit, call sites (right / wrong) | the names                                                              |
|--------|-------------------|----------------------|-----------------------------------|------------------------------------------------------------------------|
| KN6000 | KN2400            | 2                    | 499 / 3                           | PartEventToParam, TgActiveHighWaterUpdate                              |
| KN6000 | KN6500            | 1                    | 737 / 0                           | StyleNameModuleBoot (+ RAM OpeningFrameTarget)                         |
| KN6000 | KN7000 893 (v1.3) | 1                    | 587 / 2                           | TechniChordOff                                                         |
| KN2400 | KN6000            | 2                    | 498 / 3                           | TgPartEgRampScaleAReset, TgPartEgRampScaleBReset (+ RAM FileLastError) |
| KN2400 | KN7000 893 (v1.3) | 0                    | 854 / 3                           | -                                                                      |

So the siblings' names are already shared wherever their code is: the names one sibling has and
another lacks sit on code the other does not have, and 893 adds nothing 941 does not.  A
multi-source pass for one or two names a model was not worth its fixpoint questions (a name
carried from a sibling that had it from this model); the six names are listed for whoever names
those routines by hand.

`ram_writer_potential.py`: a third RAM rule, "every store lies in one named routine", would reach
87 KN6000 / 88 KN6500 / 99 KN2400 addresses; most numeric addresses have several writers (887 /
896 / 1,041) or no direct store (581 / 582 / 647).  Not adopted: little reach for a weak name.

`kn7000_ram_names_reach.sh`: naming 941's RAM by use (34 accessor, 697 owner names) would give
the RAM map 14 / 15 / 37 names the siblings lack (accessor 2 / 3 / 3, owner 12 / 12 / 34); the
rest are named in the sibling already (owner 280 / 279 / 377).  The 941 side is the KN7000
lanes' to name; once it is, `make aligned-names` carries those names with no change here.

## Why the backlog is still large

`../sibling-names2-probes/func_pairing.py` (`func-pairing.txt`): of the KN6000's 5,671 func_
starts, 1,358 pair by call sites with a 941 routine that 941 leaves unnamed too
(`notes/routine-map-kn7000.tsv`, "A unnamed"; KN6500 1,421 of 5,698, KN2400 2,320 of 6,518, measured before KeyZoneNoteResolve).
Every KN7000 name given to such a routine reaches the sibling by `make aligned-names`.  The rest
have no call-site partner (some have a same-body one that `port_names_by_code.py` saw, unnamed on
both sides): the KN6000's are thickest in 0x4C11xxxx / 0x4C12xxxx (485 + 450; the sequencer and
SMF code, where `GetSeqPlyPart`, `sqpstp_op` and `SaveSmf` sit), the KN2400's in its RAM-linked
library (0x5014xxxx / 0x5015xxxx, 247 + 390) and at 0x4861xxxx / 0x4862xxxx (257 + 350).
For RAM, 1,936 KN6000 addresses (KN2400 2,141) have several users, and 745 (816) one user that
is still func_ (the reports' "not named" lines): the owner and accessor rules grow only with the
routine names.

## A lead: the MILK kernel's services by their uITRON function codes

`kernel_errorhook_codes.py`: each MILK kernel service calls KernelErrorHook / KernelErrorHook2
before it returns an error, with d0 = a function code and d1 = a uITRON 3.0 error code (E_ID
-0x23, E_OBJ -0x3F, E_CTX -0x45, E_QOVR -0x49, E_TMOUT -0x55, E_NOMEM -0x0A, E_PAR -0x21).  19
KN6000 / KN6500 routines and 17 KN2400 ones do so (with `loc_cpu` among them: see below), and,
before lane open13/uitron-names, 17 / 17 / 16 of them were still func_.

**Followed on 2026-11-07 (lane open13/uitron-names, `../uitron3-function-codes/README.md`).**  The
table is section 6.3 of the TRON Association's "uITRON 3.0 Specification" Ver 3.02.00 (I-01-02E);
its licence forbids partial reproduction, so `../uitron3-function-codes/fetch_spec.sh` downloads it
(git-ignored) and `function_codes.py` reads it at run time.  It names every code the firmware
passes, and agrees with the seven program-942 export names that report one (`ter_tsk` = -0x19,
`cre_tsk` -17, `wai_sem` -53, `rot_rdq` -28, `exd_tsk` -22, `ext_tsk` -21, `unl_cpu` -7).  Almost
every reporting routine is the body of a service-call wrapper (the context-saving trap stub a task
calls): the wrapper is named after the service, the body `<svc>_Impl`; `loc_cpu`, `sus_tsk` and
`ena_dsp` are called directly.  The two polling services report their waiting twin's code
(`preq_sem` wai_sem's -53, `prcv_msg` rcv_msg's -61, with d1 = the poll's result).

**Corrected:** this section said "-0x08 is `clr_flg` in the KN6000 / KN6500 but `ena_int` in the
KN2400, so the reflection rows are not a reliable key on their own".  That was the probe's error,
not the labels': it skipped every label starting `loc_` (meant for `loc_<ADDR>`), so the service
`loc_cpu`, which reports -8 and is labelled correctly in all seven trees, lent its code to the
routine before it (`clr_flg` in the KN6000 / KN6500 and 942, `ena_int` in the KN2400, 941, 935 and
893, whose kernels have no `clr_flg`).  The bodies check out: `loc_cpu` sets the dispatch-disabled
state and clears PSW.IE (`and 0xf7ff, psw`), `clr_flg` ANDs an event flag's pattern, `ena_int`
sets an interrupt's enable bit (or PSW.IE for 0).  The probe is fixed and
`kernel-errorhook-codes.txt` re-measured.

## Items

| item       | outcome | in one line                                                                                                                                                       |
|------------|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| N-a810f3f6 | OPEN    | KN6000 func_ 9,917 -> 9,910 (aligned names 108 -> 115, by RAM runs and pointer pairs); the rest wants KN7000 names (1,358 call-site pairs) or hand naming         |
| N-f22bdce4 | OPEN    | KN6500 func_ 9,972 -> 9,966 (108 -> 114); next as N-a810f3f6                                                                                                      |
| N-b3ba9d8b | OPEN    | KN2400 func_ 11,340 -> 11,315 (228 -> 249; TG library 418 -> 424 of 544, short twins 36 -> 30, those 30 blocked by a changed variable layout); next as N-a810f3f6 |
| N-8fce01b1 | OPEN    | KN6000 work-RAM 17,752 / 2,524 -> 17,755 / 2,522 (+3 operands: WORK_RAM_BASE unnamed on purpose; RAM pairs 1,613 -> 2,123); next: more routine names              |
| N-cccf0416 | OPEN    | KN6500 17,788 / 2,533 -> 17,791 / 2,531 (as N-8fce01b1; RAM pairs 1,636 -> 2,124)                                                                                 |
| N-dc17693c | OPEN    | KN2400 20,931 / 2,940 -> 20,908 / 2,933 (accessor names 21 -> 28; RAM pairs 2,258 -> 3,147)                                                                       |

## Website page draft

*For the technics-docs pages on the MN10300 siblings (`kn6000-disassembly.md`,
`kn2400-disassembly.md`), section "Names", after the paragraph wave 11 drafted
(`../sibling-names/README.md`).  Text only; the integrator publishes it.*

**More ways a KN7000 name reaches a sibling.**  Since the second round of November 2026 a
routine also takes a KN7000 name when the routines both models name hand it over the same way:
as a callback (`mov func, d0` at the same place of the same routine), or as an entry of a table
the two routines read at the same place, when the table's other entries that both models name
already agree.  Variables are paired the same way and, between two paired variables of one
module, by their spacing, since a relinked module keeps its variables' order.  Every rule is
checked where the answer is known, on the routines both models name already; the table rule is
used only with its check, because without it a third of the table entries pair wrongly in the
KN2400.
