# cc900 rebuilt along its own seam (feedback plan decision E6)

The owner decided on 2026-11-22 (`notes/cc900-feedback-plan-2026-11-22/README.md`, section 13, E6) to rebuild the
reference model of Toshiba's cc900 V4.23 along the compiler's own two passes, each checked against V4.23 alone:

| part      | input                         | output                       | checked against                                         |
|-----------|-------------------------------|------------------------------|---------------------------------------------------------|
| back end  | thc1's intermediate file      | the listing                  | thc2 on the same file: `-zio`, `-zim`, `-g`, the listing |
| front end | C                             | thc1's intermediate file     | thc1's file for the same C                              |

The old model (`../model/`) stays the reference until the new halves beat it on
`notes/cc900-feedback-plan-2026-11-22/i2/m1_model_vs_v423.py` and on `../val_agg.py`.  The back end comes first.

**Clean room.**  Everything here is written from our own descriptions of behaviour (the plan's section 13): no
Toshiba code, table or output is copied in.  The oracle files these scripts read (thc1's files, thc2's dumps and
listings) stay in the private `~/compartilhado/cc900-oracle/`; scripts print counts only.

## The stages of thc2, as observed (V4.23)

Read from thc2's per-function loop and its debug dumps (`notes/cc900-feedback-plan-2026-11-22/i2/README.md`):

| stage | what thc2 does                                                                                                         | observable as                    |
|-------|------------------------------------------------------------------------------------------------------------------------|----------------------------------|
| S0    | reads one function of thc1's file into its own instruction records                                                     | thc1's file (the input)          |
| S1    | machine-independent rewriting and, with `-O`, the optimiser passes                                                     | `-zio` (replaces the code)        |
| S2    | two-address form and addressing modes for the TLCS-900                                                                 | `-zim` (printed before the code) |
| S3    | register allocation: allocate and spill, repeated until stable; then frame layout                                     | `-g` (each variable's storage)   |
| S4    | instruction selection (one handler per operation) and the emitter                                                      | the listing                      |

thc2's instruction record holds an operation (96 kinds: assignment and the C operators in compound and three-address
forms, address-of, conversions, compares as branches, the call and argument kinds, `DJNZ`, block moves, bit-field
insert / extract, switch, labels, line and block markers, inline assembler) and up to three operands (result, first,
second), with flag bits saying which are present.

## thc1's intermediate file

See `thc1ir.py`'s docstring.  Over the 1,133 firmware files kept by runs 2026-11-22-46..49: 534,968 lines, 48 distinct
operations; thc1 already rotates loops (the test at the bottom).

## Files

| file              | question it answers                                                                                                                                                                                                |
|-------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `thc1ir.py`       | reads and writes thc1's intermediate file; `--roundtrip FILE...` checks the reader is exact (1,133 / 1,133, 2026-11-22)                                                                                            |
| `s0.py`           | S0: the file split into one unit per function with its parameters, locals and temporaries; `--stats` (1,133 files: 4,726 functions, 239,783 operation lines, 143,532 temporaries)                                  |
| `s1.py`           | S1 without optimisation: thc1's operations rewritten as thc2 holds them before code selection, printed as its `-zio` dump (rules in the docstring)                                                                 |
| `s1_check.py`     | S1 against thc2's `-zio` for every kept file of job_i2.sh runs: exact functions per option set, first-difference worklist (counts only)                                                                            |
| `dump.py`         | thc2's -zio / -zim dumps read into records and written back; `--roundtrip DUMP...` (all 495,642 lines of runs 2026-11-22-51..54 exact): a stage can start from V4.23's own previous stage                          |
| `s2.py`           | S2 from V4.23's own -zio: DUMMY lines (values live on entry: globals read, address-taken locals, register parameters used), blocks no longer printed; the symbol-table walk order (thc2's name hash) is under test |
| `s2_check.py`     | S2 against thc2's -zim, function by function (exact / up to temporary numbering), first-difference worklist                                                                                                        |
| `flow.py`         | control flow over dump records: successors, and whether a variable is live across a call                                                                                                                           |
| `s3.py`           | S3 from V4.23's own -zim: the register of each parameter and local (memory marks = stack; parameters in their argument register or XIZ across calls; locals by a first rule)                                       |
| `s3_check.py`     | S3 against thc2's -g records, per variable and per function, with a (truth, ours) worklist                                                                                                                         |
| `listing2.py`     | thc2 `zimg` listings split per function into dump and code lines (labels kept, debug records dropped, inline assembler kept)                                                                                       |
| `s4.py`           | S4, instruction selection, from V4.23's own -zim and -g registers: frames, moves, loads / stores, ALU, compares and branches, bit operations, shifts, conversions, register arguments, calls and tail jumps        |
| `s4_check.py`     | S4 against thc2's code lines per function, refusals and first differences as a worklist                                                                                                                            |
| `s4_temps.py`     | probe: searches the temporaries' registers that make S4's code match thc2's longest; S4's default against them, with context (size, defining operation, hints, uses)                                               |
| `stage_scores.py` | the stage scores over time (`results/stage_scores.tsv`) for the dashboard: `backfill` from the stage commits, `record` from the `*_check.py --record` runs                                                         |

Run the round trip, from technics-roms-disasm's root:

    find ~/compartilhado/cc900-oracle/runs/2026-11-22-4[6-9]-i2-fw-* -name '*.inter' | xargs \
        python3 -B scripts/analysis/cc900/stages/thc1ir.py --roundtrip

## Progress

| date       | stage | measured                                                                                                                                                                                                        |
|------------|-------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2026-11-22 | S1    | the probe (run 2026-11-22-50, `i2a.c`), no options: 2 / 2 functions equal thc2's `-zio`                                                                                                                         |
| 2026-11-22 | S1    | firmware C, `-Xr` (runs 2026-11-22-51..54): 496 / 2,672 functions equal thc2's `-zio` (from 38 at the first version)                                                                                            |
| 2026-11-22 | S1    | `-Xr` 676 / 2,672; `-O3 -Xr` 340 / 2,879 and `-O3 -XS -Xr` 1 / 21 (no optimiser modelled yet)                                                                                                                   |
| 2026-11-22 | S1    | `-Xr` 773 / 2,672 (28.9 %); the largest remaining class of first differences is temporary numbering (818 functions before this row), then (Def) (135)                                                           |
| 2026-11-22 | S1    | `-Xr` 872 exact, 1,238 up to temporary numbering (46 %), of 2,672: switch jump tables, jump threading                                                                                                           |
| 2026-11-22 | S2    | from thc2's own -zio, `-Xr`: 383 / 2,671 equal its -zim (DUMMY lines only so far)                                                                                                                               |
| 2026-11-22 | S2    | `-Xr` 416 exact, 439 up to numbering, of 2,671 (from V4.23's own -zio): DUMMY order, addressing modes, two-address form; {MO} on parameters still open                                                          |
| 2026-11-22 | S2    | `-Xr` 466 exact, 629 up to numbering, of 2,671: register routing (memory-memory, 4-byte constants, 16-bit multiply / divide), XIZ spill marks, live-on-entry DUMMY lines                                        |
| 2026-11-22 | S3    | from thc2's own -zim against -g: 1,957 / 3,394 named variables (57.7 %), 1,289 / 2,001 `-Xr` functions all right (returned locals in the HL family)                                                             |
| 2026-11-22 | S3    | 2,659 / 3,394 named variables (78.3 %), 1,606 / 2,001 `-Xr` functions all right: interference colouring, XWA-first order, temporaries' families avoided, call results and returns in HL, bytes on high halves   |
| 2026-11-22 | S4    | from V4.23's own -zim and -g: 138 / 2,001 `-Xr` functions' code exact (S3 now 5,958 / 6,768 variables)                                                                                                          |
| 2026-11-22 | S4    | 397 / 2,001 `-Xr` functions' code exact, 341 refused (switches, struct fields, stack arguments, shared epilogue, liveness-based temporaries); S3 6,172 / 6,982 variables                                        |
| 2026-11-23 | S4    | 516 / 2,001 `-Xr` functions' code exact, 241 refused: temporaries' registers studied with `s4_temps.py` (indirect-call targets, returned values, reservations, XIZ across calls), block copies, switch defaults |
| 2026-11-23 | S4    | 702 / 2,001 `-Xr` functions' code exact, 136 refused (calls and tail jumps, or r,r / scc / res / set, sizes, stack arrays, deferred pops); handoff: `HANDOFF-2026-11-23.md`                                     |

## S3, first measurement (2026-11-22)

`-zim` is printed after thc2's allocate / spill loop, so its memory marks already carry the register-or-stack
decision: in 1,956 of 2,001 firmware `-Xr` functions (whose `-g` records pair with their dumps), the number of named
variables `-g` places on the stack equals the number of parameters and locals `-zim` marks `{MO}`, `{MM}` or `PIN`.
S3 is therefore mainly the choice of register for the others (7,939 register variables in the `-g` records of runs
2026-11-22-51..54, private table `cc900-oracle/internals/i2/fw-registers-2.tsv`), and for temporaries, which only
the listing shows (S4).

## thc2's allocator, as read (V4.23, our description; addresses in THC2.EXE, image base 0x400000)

The allocate / spill loop of the big per-function pass runs 0x437740, which:
  - pins the function's return value to the HL family (L, HL or XHL by size);
  - gives each candidate (temporaries, locals, parameters) an allocation record: its size, an *avoid* mask (registers
    something in its live range clobbers) and a *pinned* mask (all but one register excluded: an operand an
    instruction needs in a fixed register, e.g. the runtime helpers' XWA / XBC / XHL, a block move's pointers); masks
    have one bit per byte register (W, A, QW, QA, B, C, ...), so a word register covers two bits and a 32-bit one four;
  - walks every block's instructions with the live set, adding clobbers to the avoid masks of the values live there
    and recording interference (0x439d40: each live value's interference set gains the live set);
  - counts the live bytes per register class at each point against the class's capacity; where a class overflows it
    records the excess and the live set (0x439760, one record per distinct live set, keeping the largest excess);
  - resolves those records in increasing order of excess (0x439840), choosing what to spill (0x439950) -- the
    variables -zim then marks {MO} / {MK}; this repeats with the spill code inserted until nothing overflows.
The register each surviving value gets is decided after this loop (0x43ac40 works on register numbers with the
pinned / avoid masks); that is S3's remaining part.

