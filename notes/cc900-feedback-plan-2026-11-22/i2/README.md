# Step I2: thc2's register allocator

Feedback plan section 13, step I2.  Our own descriptions only; Toshiba's code, tables and outputs stay in the private
`~/compartilhado/cc900-oracle/` (clean-room rule).  Binary cited: V4.23 `THC2.EXE`, SHA-256 `eb1a5b07a0d5...`
(i0.md), virtual addresses as Ghidra 12.2 shows them (image base 0x400000).

## Files

| file                                               | question it answers                                                                                                      |
|----------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| `job_i2.sh`                                        | guest job (`JOB=` of run_oracle.sh): keeps thc1's intermediate file, re-runs THC2.EXE on it plain and with extra options |
| `debug.txt`                                        | the extra thc2 option sets job_i2.sh tries, "label\|options" (passed through run_oracle.sh's `ASMFLAGS=` channel)        |
| `options.txt`                                      | the cc900 option sets of the probe runs                                                                                  |
| `sources.txt`                                      | the probe corpus's files                                                                                                 |
| `i2_dataset.py`, `i2_run_shards.sh`, `dataset.txt` | the firmware C as job_i2.sh shards (`-zim -g`), one VM slot each                                                         |
| `i2_registers.py`                                  | thc2's `-g` storage records of those runs as one table (private)                                                         |
| `m1_model_vs_v423.py`                              | the model's listing against V4.23's, per function (`m1_v10.md`, `m1_v10.tsv`)                                            |
| `corpus/`                                          | probe C (ours)                                                                                                           |

Run, from technics-roms-disasm's root:

    JOB=notes/cc900-feedback-plan-2026-11-22/i2/job_i2.sh ASMFLAGS=notes/cc900-feedback-plan-2026-11-22/i2/debug.txt \
      bash scripts/analysis/cc900/oracle/run_oracle.sh i2-debugopts notes/cc900-feedback-plan-2026-11-22/i2/corpus \
      notes/cc900-feedback-plan-2026-11-22/i2/sources.txt notes/cc900-feedback-plan-2026-11-22/i2/options.txt v423

The check that the method is sound: each source's `<base>_plain.asm` (THC2.EXE re-run by hand) must equal the
driver's `<base>.asm`.  Run 2026-11-22-45-i2-debugopts (cc900-oracle e055cf7): equal at none and at `-O3 -XS`.

## Findings so far (2026-11-22)

**How the driver runs the passes** (run 2026-11-22-42: job.sh, at commit 962b5476a, ran a compile under Wine's
process trace for labels starting with `wdbg`; that switch was removed again because job.sh's bytes are part of the
build's V4.23 cache key, and job_i2.sh does the same work):
- thc1 is started as `thc1 -z@` and takes its options from the environment (it reads every environment string as an
  option: under Wine it warns about each `WINE...` variable, harmlessly).
- thc2 is started as `thc2 <options> <thc1's temporary file> <out>.asm`.  The driver gives it `-XO -XM` always, and
  turns `-O3 -XS` into `-O -XS4` (so `-O3` reaches the code generator as plain `-O`).
- The driver forwards only fixed strings to thc2; it cannot pass thc2's other options on.

**thc2's options** (its option table, read in the private decompilation): besides the documented ones it accepts
`-zim`, `-zio`, `-zl`, `-zh`, `-zperf`, `-g` with sub-letters (`l t d f b`), `-Nb0..3`, `-ZC-`, `-ZT-`, `-e-`, `-GF`.
What the probe showed (run 45):

| option   | effect on the output                                                                                                                                               |
|----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-zim`   | prints, before each function's code, thc2's intermediate code as it enters code selection: one line per operation, with parameters, locals and temporaries numbered by class, their C types and flags |
| `-zio`   | prints the intermediate code after the optimiser instead of emitting code (the function's instructions are replaced by the dump)                                  |
| `-g`     | debug records: per function, every local and parameter with its storage; for a register variable the register's internal number; plus live-range events           |
| `-gt`    | the same records without the type records                                                                                                                          |
| `-zl`    | source line records plus the storage records                                                                                                                       |
| `-zh`    | drops the banner comment                                                                                                                                           |
| `-zperf` | pads after each `ret` with `nop`s ("for RTE")                                                                                                                      |
| `-gb`    | no change for this probe                                                                                                                                           |

**thc2's register numbering** (its register-name table, indexed from W): byte registers 0-31 (W = 0, A = 1, QW, QA,
B = 4, C, QB, QC, ... up to QSPL = 31), word registers 32-47 (WA = 32, QWA = 33, BC = 34, QBC = 35, DE = 36, QDE,
HL = 38, QHL, IX = 40, QIX, IY = 42, QIY, IZ = 44, QIZ = 45, SP = 46, QSP = 47), 32-bit registers 48-55 (XWA ...
XSP), F = 56.  So in the probe `leaf` the debug records put `i` in 40 (IX), `s` in 38 (HL), `t` in 36 (DE), and in
`calls` `i` in 44 (IZ) and `v` in 45 (QIZ), matching the listing.

**A free-register search** (0x405ed0): given an occupancy mask with 4 bits per 32-bit register (its two low bytes and
its two Q bytes), XWA to XIZ, it returns the first free byte register (low bytes only), word register (the low word,
never the Q word) or 32-bit register, in the order XWA, XBC, XDE, XHL, XIX, XIY, XIZ.  Under one value of a global
set by the options it first marks the Q words of XWA..XHL as taken.  Nothing calls it directly (a function pointer,
presumably); it looks like the temporaries' allocator, not the variables' (whose order starts at BC).

**The pipeline** (thc2's per-function loop at 0x42be40): read a function, a large selection / optimisation pass
(0x41fca0), then frame layout (0x42bff0: stack offsets for autos and temporaries), 0x42c310, 0x401210, 0x42c710,
and the emitter (0x42e080, whose operand printer reads the register-name table).  Which of these allocates registers
is the next question.

**Why this matters.**  `-zim` gives the allocator's input and `-g` its output, per variable, for any C we can compile.
That turns register choice from a byte-level black box into a per-variable labelled data set, and the code that
decides it can be read in the decompilation.  Next: run `-zim -g` over the built firmware C (V4.23 MATCH functions)
to get that data set at scale, then locate the allocator among the passes above.

## The firmware data set (runs 2026-11-22-46..49, cc900-oracle 9341b06f)

`i2_dataset.py prepare $TMPDIR/cc900-tab/i2-fw 4`, `i2_run_shards.sh $TMPDIR/cc900-tab/i2-fw`: 1,339 distinct C
texts (2,736 files).  1,133 kept thc1's output, and every plain re-run equals the driver's listing; the watcher missed
206 (to be re-run).  `i2_registers.py` over the four runs: 1,130 files, 6,599 variables in registers, 3,702 on the
stack.

## The model against V4.23 on v10 (`m1_v10.md`)

Register choice is **not** where the reference model loses the firmware.  Of the 1,745 functions of v10's C that
V4.23 compiles, the model writes the same listing for 560 (32 %), differs only in registers for 21 (1.2 %), and
writes nothing for 657 (37.7 %): it refuses a construct (`unsupported: var` alone is 199) or its front end fails on
the whole file (22).  The other 483 (27.7 %) differ otherwise.  So the first gain for the model is coverage of C
constructs, and register choice matters for the ROM residual (V4.23 against the ROM), not for the model.

