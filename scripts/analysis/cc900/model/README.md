# cc900 reference model (phase 3a)

An executable specification of cc900's code generation, in Python, checked line by line against the oracle's
listings (`notes/cc900-compat-plan-2026-11-08/phase0.md`, section 4).  The LLVM implementation (phase 3b) is
written from it and tested against it.

| module           | what it does                                                                                                                                                                                |
|------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `frontend.py`    | clang's AST (`-ast-dump=json`) to a small tree with cc900's types (16-bit `int`, alignment 2, even struct sizes)                                                                            |
| `listing.py`     | splits a Toshiba `.asm` listing into normalised per-function lines; compares two                                                                                                            |
| `codegen.py`     | the code generator; each rule cites the oracle listing it comes from                                                                                                                        |
| `homes.py`       | which values live across a call get IZ / QIZ / XIZ: rules R3-set and R4 (`codegen.plan_homes`)                                                                                              |
| `homes2.py`      | the same question by the fitted homes2 rule (a Chow-style priority colouring), behind `codegen.HOMES2` / `CC900_HOMES2`                                                                     |
| `leafnone.py`    | rule LN1: the registers of a cdecl leaf function with a loop, without options                                                                                                               |
| `leafalloc.py`   | rule R6: the `-O3 -XS -Xr` leaf loop's temporary family and parameter moves                                                                                                                 |
| `l2alloc.py`     | rule L2: the register allocator of cdecl `-O3 -XS` leaf functions                                                                                                                           |
| `u1alloc.py`     | rule U1: the register allocator of counted loops                                                                                                                                            |
| `chidx.py`       | char indexes: an element address or pointer sum whose index is a char, at every option set (`probes/chidx.c`)                                                                               |
| `fpgen.py`       | floating point: helper calls, frame temporaries, FP arguments and results (`micro/fp.c`, `fp_temps.c`, `fp_stmts.c`)                                                                        |
| `fpwindow.py`    | rule E2 (the window rule): the order of a function's FP frame temporaries                                                                                                                   |
| `fpe3.py`        | rules E3: how many FP temporaries a function uses and which slot each operation writes; installed over `fpgen.py`                                                                           |
| `interp.py`      | an interpreter for TLCS-900/H2 assembly in the listing syntax (`test_interp.py` checks it)                                                                                                  |
| `semcheck.py`    | does the model's code compute what the oracle's computes?  Random trials through `interp.py` (`semcheck.md`)                                                                                |
| `score.py`       | model against oracle, per function: `python3 -I -B score.py ORACLE_DIR FILE.c ... [--opt O3XS] [--adecl] [--show N]`                                                                        |
| `to_llvm.py`     | the model's listing rewritten in our llvm-mc syntax, with asm900's encodings and the 8/16/24-bit address choice; with `SPELL` set (the phase 6 build) a named operand keeps the tree's name |
| `check_bytes.py` | assembles `to_llvm.py` output with llvm-mc and compares each function's bytes with a ROM image; `assemble()` / `load_reference()` as a module                                               |
| `fn_diff.py`     | one firmware function, our C through the model against the ROM: instructions, bytes, first difference (phase 6)                                                                             |
| `pairs_model.py` | the firmware's library pairs rebuilt by the model + `to_llvm.py` + llvm-mc / ld.lld, compared with each image; `--listings DIR` uses a Toshiba listing in place of the model's              |

**From C to ROM bytes without Toshiba's tools** (phase 6 preview; prints `6 of 6 functions byte-identical`):

    python3 -I -B to_llvm.py ../corpus/firmware/tiny.c ../corpus/firmware/tiny.syms --adecl > "$TMPDIR/tiny.s"
    python3 -I -B check_bytes.py "$TMPDIR/tiny.s" ../../../../original_ROMs/kn5000_v10_program.rom \
        ../../../../symbols/maincpu_v10_symbols_reference.txt 0xe00000 --alias SmfMedley_RawData=Smf_SetMidiOut

(`tiny.c` keeps the C names its oracle run compiled, and that run is a ledger row; the firmware label
`SmfMedley_RawData` is `Smf_SetMidiOut` since 2026-11-16, hence `--alias`.)

**Firmware functions in the build (phase 6):** `scripts/build/cc900_firmware_c.py` compiles `v10/maincpu/cc900/*.c`
for `make` (`notes/cc900-phase6-2026-11-16/README.md`); one function against the ROM, or every function of a file:

    python3 -I -B fn_diff.py ../../../../v10/maincpu/cc900/medley.c SmfMedley_RawData
    python3 -I -B fn_diff.py ../../../../v10/maincpu/cc900/ui_widget_defs.c

**The firmware's library pairs without Toshiba's tools** (`../results/pairs_model_kn5000.tsv`):

    python3 -I -B pairs_model.py ../results/pairs.tsv ~/compartilhado/tmp/cc900-corpus-libsrc97 > ../results/pairs_model_kn5000.tsv

The same pairs from V4.23's own listings of the 1997 library (oracle run `2026-11-08-5`), through the same `to_llvm.py`
and llvm-mc (`../results/pairs_v423_llvm_kn5000.tsv`; `make cc900-c-coverage` runs both):

    python3 -I -B pairs_model.py ../results/pairs.tsv ~/compartilhado/tmp/cc900-corpus-libsrc97 \
        --listings ~/compartilhado/cc900-oracle/runs/2026-11-08-5-libsrc97-O3XS/out/v423/O3XS/libsrc > ../results/pairs_v423_llvm_kn5000.tsv

`../results/model_ledger.md` records the scores; `sh model/ledger.sh` (from `scripts/analysis/cc900`) regenerates them.  The oracle
directories are `~/compartilhado/cc900-oracle/runs/2026-11-08-7-micro/out/<compiler>/<options>`.

## Effort estimate before resuming (feedback plan step C0, 2026-11-22)

`notes/cc900-feedback-plan-2026-11-22/c0_rate.py` scores nine snapshots of this directory, taken from git between
batch 72 and batch 366, on the validation corpus (never tuned on) and on the 1,738 v10 functions the build makes from C
with V4.23 (output `c0.md` beside the script).  Each snapshot uses its own `to_llvm.py`.

| measure                                       | batch 72 | batch 366 | gain per batch | left    | batches at that rate |
|-----------------------------------------------|----------|-----------|----------------|---------|----------------------|
| v10 built functions reproduced                | 456      | 475       | 0.065          | 1,263   | 19,543               |
| their ROM bytes                               | 6,525    | 7,424     | 3.06           | 119,639 | 39,126               |
| validation exact, four sets summed (of 2,400) | 120      | 261       | 0.480          | 2,139   | 4,460                |

Over the last 25 batches (341-366, the first ones driven partly by the firmware lanes' rules) the firmware gained 0.32
functions per batch and validation 0.16.  Even at 0.32, parity on the built v10 functions is about 3,900 batches, some
65 days at phase 3a's pace of about 60 batches a day.  So batches judged on micro corpora are no route to the
firmware; the plan's C1-C3 (firmware attempts as training data, scored per function) are its test, and C5's stop rule
applies.  This meets the condition the plan set for revisiting decision E4 (black-box only).
