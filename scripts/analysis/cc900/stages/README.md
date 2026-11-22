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

| file        | question it answers                                                                                                                                                               |
|-------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `thc1ir.py` | reads and writes thc1's intermediate file; `--roundtrip FILE...` checks the reader is exact (1,133 / 1,133, 2026-11-22)                                                           |
| `s0.py`     | S0: the file split into one unit per function with its parameters, locals and temporaries; `--stats` (1,133 files: 4,726 functions, 239,783 operation lines, 143,532 temporaries) |

Run the round trip, from technics-roms-disasm's root:

    find ~/compartilhado/cc900-oracle/runs/2026-11-22-4[6-9]-i2-fw-* -name '*.inter' | xargs \
        python3 -B scripts/analysis/cc900/stages/thc1ir.py --roundtrip
