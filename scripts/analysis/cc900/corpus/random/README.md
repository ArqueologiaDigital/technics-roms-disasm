# Random programs for the cc900 model

Phase 3 of the cc900 compatibility plan (`notes/cc900-compat-plan-2026-11-08/PLAN.md`, section 4.1) asks for
"random programs at >= 95 %" beside the micro corpus.  `../gen_random.py` writes them: seeded, ours, C89.  The
files in this directory are its output and are committed; the oracle listings live only in the private
`~/compartilhado/cc900-oracle` runs.

## What a program contains

Each file is a translation unit of 20 distinct functions composed from the constructs the micro corpus
(`../gen_micro.py`, `../micro/*.c`) and the probes (`../probes/*.c`) exercise one at a time, so that a listing
shows how V4.23 handles their interactions: parameters, locals and extern globals of every integer type, `double`
and pointers to `char` / `int` / `long` / `struct`; global arrays indexed by a loop counter, a variable or a
constant; struct members through a global, a global pointer or a pointer parameter; every integer operator,
double `+ - *` and `/` by a constant, casts, `?:`, comparisons as values and conditions, `&&` / `||`, `x & mask`
conditions; assignments of every kind including chains and assignment as a value; `if` / `else`, counted `for` /
`while` / `do` loops, pointer walks, `break` / `continue`, `switch` (dense, sparse, fallthrough, `default`),
early returns; calls to extern functions as statements, operands and conditions.

What it avoids, so that the oracle and the model can only differ in code shape (the docstring is the authority):
every local is initialised at its declaration; no division or remainder by a value that may be zero; shift counts
are constants below the width or masked; no double-to-integer conversion; no function returns `double` (the
model's front end rejects one under `-Xr`, and a file with one fails as a whole); loop bounds are constants or an
int parameter.  Array indexes outside a loop are a small constant or an int variable whose range is the caller's
contract: the semantic check's random inputs exceed it, and both compilers then address the same out-of-range
element, except where the model mis-extends the index (see below).

## The first corpus

| what      | value                                                                                              |
|-----------|----------------------------------------------------------------------------------------------------|
| command   | `python3 -I -B corpus/gen_random.py --seed 1 --count 10 --funcs 20 --size small` (the defaults)     |
| files     | `corpus/random/r1_s_00.c` .. `r1_s_09.c`, listed in `corpus/random-sources.txt`; 200 functions     |
| oracle    | run `2026-11-10-1-micro-random1` (V4.23, the four option sets of `corpus/options-micro.txt`)        |
| commit    | technics-roms-disasm a42fc51a5 (generator + corpus); cc900-oracle 8f8116c (the run)                  |

Commands, from `scripts/analysis/cc900` (`R=~/compartilhado/cc900-oracle/runs/2026-11-10-1-micro-random1/out/v423`):

    flock ~/compartilhado/cc900-oracle/vm/.runlock bash oracle/run_oracle.sh micro-random1 corpus \
        corpus/random-sources.txt corpus/options-micro.txt v423          # the oracle run (the VM is shared)
    python3 -I -B model/score.py    $R/none/random   corpus/random/*.c --opt none
    python3 -I -B model/score.py    $R/O3XS/random   corpus/random/*.c --opt O3XS
    python3 -I -B model/score.py    $R/Xr/random     corpus/random/*.c --opt none --adecl
    python3 -I -B model/score.py    $R/O3XSXr/random corpus/random/*.c --opt O3XS --adecl
    python3 -I -B miss_shapes.py    $R/none/random   corpus/random/*.c --opt none      # misses by shape
    python3 -I -B model/semcheck.py $R/none/random   corpus/random/*.c --opt none      # behaviour

## First results (2026-11-10, model at technics-roms-disasm 569686328 plus that session's uncommitted codegen.py)

| option set   | exact     | compiled by the model | misses by first-difference shape (compiled functions)            | semcheck: checked / equal / DIFFERENT |
|--------------|-----------|-----------------------|------------------------------------------------------------------|---------------------------------------|
| none         | 4 / 200   | 62                    | frame 27, instruction choice 13, operand form 10, registers 7    | 59 / 41 / 18                          |
| `-O3 -XS`    | 2 / 200   | 60                    | frame 28, instruction choice 14, registers 7, operand form 6     | 57 / 41 / 16                          |
| `-Xr`        | 2 / 200   | 62                    | frame 24, operand form 14, instruction choice 13, registers 8    | 54 / 35 / 19                          |
| `-O3 -XS -Xr`| 2 / 200   | 63                    | frame 24, instruction choice 14, operand form 11, registers 9    | 55 / 37 / 18                          |

The other 137-140 functions per set raise `Unsupported` in the model; the most frequent reasons, in every set, are
`the value overwrites the store address`, `memory load index`, `complex compare operand`, `complex shift count`
(a masked variable count), `addr` (`&gca[t]`), `complex long helper operands`, `element read over the left
value`, `local` (a long or pointer local read twice in a non-leaf function) and `store address over a live
register`.  `miss_shapes.py` prints the full table.

What the "frame" misses are, read from the first differing lines: the frame size (a long local live across a
call gets a slot in V4.23 where the model homes it in XIZ; FP temporaries take fewer slots than the model
allocates); a local that dies after `t++` or `++t` is computed in WA and never stored (the model gives it a slot);
the `inc 0x4,XSP` after a call is deferred and merged with later pops.  The "instruction choice" misses include a
`char` function returning a constant through `ld L,k` (the model writes `ld HL,k`), and an `op=` on a global array
element whose address is held in XBC.  A chain `gul = gula[2] = 4UL` loads the constant into XWA once per store.

Semcheck's DIFFERENT functions are wrong code, not shape: a `switch` with two fallthrough labels makes the model
emit a jump to a label it never defines (`r1_02_18`); the pointer walk `while (gi-- > 0) *gpi++ = k` through a
global pointer stores through an unset register (`r1_07_13`, `r1_04_17`); a long chain across a call
(`r1_01_15`, `r1_01_18`); under `-Xr` an argument that is a constant long expression (`vl(3L / 3L)`, `r1_02_06`), a
`?:` with an always-false compare on a register parameter (`r1_05_01`) and a compare of a char-indexed element
(`r1_06_08`, an extra call); an unsigned char index of 0xff addressed differently (`r1_04_19`).
