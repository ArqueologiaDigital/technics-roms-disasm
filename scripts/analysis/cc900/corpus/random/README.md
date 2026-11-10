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

## Second pass (2026-11-10, later: the chidx / E3 batch)

The wrong code the first pass found is fixed or refused, and the char-index shapes it exposed are a module of their
own (`model/chidx.py`, probe `probes/chidx.c`, run `2026-11-10-4-micro-chidx`: 50 / 50 at every option set).  Fixed
from this corpus in that batch: `!` of a long helper result or a shifted long tested the wrong register (`r1_00_05`,
`r1_09_14`); `61613L * gl2` loads the variable first; a shift count expression over a register variable is computed
at the variable's width, in a register no live variable holds (`r1_06_19`, `r1_09_14`); an adecl call's computed
byte argument is taken from where it was computed; an unsigned int index on a sized global array is zero-extended
whole (`r1_08_00`, refused under `-O` / `-Xr`); `clobbers` knows that `(XDE+C)` is built from XBC; the pending pops of
a call are released before an expression statement that makes no call and does not assign a register variable
(`r1_02_19`); `gua[a] = gua[a] + gua[6]` evaluates the value first, into DE, and `gua[a] + gua[6]` builds the
element's address, loads the plain operand and adds the element.

| option set   | exact     | semcheck: checked / equal / DIFFERENT | not checked |
|--------------|-----------|---------------------------------------|-------------|
| none         | 8 / 200   | 67 / 64 / 3                           | 133         |
| `-O3 -XS`    | 2 / 200   | 62 / 55 / 7                           | 138         |
| `-Xr`        | 4 / 200   | 58 / 47 / 11                          | 142         |
| `-O3 -XS -Xr`| 2 / 200   | 59 / 48 / 11                          | 141         |

The 32 DIFFERENT functions left were in `r1_s_01` to `r1_s_08` (`r1_s_04` had 14 of them, mostly under `-Xr`).

## Third pass (2026-11-10, later still): no wrong code left in the corpus

Every remaining DIFFERENT function was fixed or refused; semcheck reads 69 / 63 / 58 / 58 checked, all equal, at
none / `-O3 -XS` / `-Xr` / `-O3 -XS -Xr` (the exact counts are unchanged: 8 / 2 / 4 / 2 of 200).  What the second
round taught, each a rule or a guard in `model/codegen.py` (the flag names are in parentheses):
- `!` of a loaded word is `cp WA,0x0`, of a long `or XWA,XWA`; `!gps->c` is `ld XWA,(_gps) / cpb (XWA),0x0`
  (`NOT_MEMBER_CP`, r1_06_01, r1_01_18);
- under `-Xr` too, a call on the right of `+ - & | ^` is made first (`CALL_RIGHT_XR`, r1_01_18: the model had kept
  the left value in BC across `.rul`);
- `3L / 3L` folds (`FOLD_DIV`, r1_02_06); `(unsigned char) a > 255` folds to 0 (`FOLD_UCHAR_CMP`, r1_05_01);
- `gc |= ~'A'` on a global char is `orb (_gc),0xbe` at every option set (`OPB_GLOBAL`, r1_03_19);
- the reload-elision passes know that `sla 0x2,C` ends C's copy of a variable (r1_04_01 under `-O3 -XS`);
- a char live across a call is never homed in IZ: cdecl puts it in `QIZH` (`ld QIZH,A` / `ld A,QIZH`, pushed as
  `QIZ` when nothing else of XIZ is used; r1_05_05, r1_05_19), an `-Xr` register parameter goes to a frame slot
  (`dec 0x2,XSP / ld (XSP),A`, r1_04_01) (`CHAR_HOMES`);
- `gp + b` (a char pointer plus a char) is `ld XBC,(_gp) / ld A,(b) / lda XWA,XBC+A` under `-Xr`, and under `-O` when
  the pointer is a plain global and the result goes to XWA (r1_04_19); otherwise the byte is zero-extended whole
  (r1_04_02, chidx ac1) -- the two forms differ for a char above 127;
- `-Xr`: a char parameter read again after an element read is copied first (`ld E,A / extz DE / lda XHL,_guca`,
  r1_06_01), the element's address is built before a right operand that is an expression of registers
  (`inc 0x8,A / xor A,(XHL+DE)`), and a pointer sum made while A holds a live parameter goes to a free family
  (`ld DE,BC / exts XDE / add XDE,XDE / add XDE,(_gpi)`, `PTRSUM_FREE_X`);
- a right operand read through a pointer variable puts the pointer in XWA and the left operand in BC (`ld XWA,(_gpi) /
  ld BC,(_gi3) / and BC,(XWA)`, `PTR_RIGHT_BC`, r1_06_08, r1_08_07, r1_04_16); with both operands through pointers,
  the left's pointer goes to XBC (`ld XBC,(_gpl) / ld XWA,(_gpl) / ld XWA,(XWA+0x4) / add XWA,(XBC)`, r1_05_19);
- `(guca[a] | 128) % 2` is `set 0x7,A / and A,0x1` (`UCHAR_MOD_AND`, r1_04_05); `a->a[b]` with an unsigned char b and
  a member offset keeps `ld W,0x0` under `-O` (r1_03_19);
- `-Xr` homes the first register parameter that is live across a call, not the first parameter (`XR_FIRST_LIVE`,
  r1_05_01), and an FP assignment or `?:` counts as a call for that liveness (`fpgen.is_fp_copy`);
- refused rather than wrong: `*p op= k` with the pointer and the value in one register (r1_06_08), the `-O` `?:`
  whose preloaded arm is overwritten by its condition (`TERN_PRE_GUARD`, r1_05_05), an assignment used as a value
  whose value overwrites the pointer in XWA (r1_04_07), an unsigned int index under `-O` / `-Xr` (r1_08_00).

## The second corpus (2026-11-10, `corpus/random2/`, run 2026-11-10-5-micro-random2)

Seed 2's 200 functions, compiled after every fix above, found 81 more DIFFERENT verdicts (17 / 19 / 21 / 24 per set):
wrong code the first corpus had not reached.  Two rounds later the second corpus reads 54 / 54 / 47 / 49 checked and
2 / 3 / 3 / 4 DIFFERENT; eleven of those twelve verdicts are reviewed in `model/semcheck_review.tsv` as UB only (an
array indexed out of range, where the model's zero-extended memory index and the oracle's sign-extended register
index land on different bytes), and one is open: `r2_04_19` under `-O3 -XS`, a counted loop whose slot counter is
compared through a stale register copy.  The first corpus stays at 0 DIFFERENT.  Fixed from this corpus:
- `gps->a[1]` as a right operand (the pointer-in-XWA / left-in-BC form, `ptr_access`), `*gpi - gps->i` (both through
  pointers: the left value into BC), `gl2 ^ -gpl[1]` and other right operands whose code overwrites a left value
  already in WA (refused by `RIGHT_CLOBBER_GUARD` when no rule fits);
- an unsigned int index for a compare (`cpw (XBC),k` after the 32-bit extension); `(unsigned long)gia[4] > 89152UL`
  compared at 32 bits because the constant does not fit the int (`CMP_CONST_FITS`); `gu % gu` folded to 0 at int
  size (`FOLD_SELF_DIV`); `39 < 3` and `x || 0` folded (`FOLD_CONST_CMP`); `~guca[3] / 3` in the byte
  (`CHAR_NARROW_NOT`); `*gp * -90` as `muls WA,0xa6`;
- a long `/` or `%` by a constant counts as a helper call when the right operand's call is ordered first
  (`r2_04_15`: `rl()` beside `gs.l % 3L`); the `cse_params` temporary is not kept across a call and counts as a WA
  variable for the left operand's register (`r2_04_05`, `r2_06_07`);
- a char array store with a char index and a computed value: base, value in E, index in A (`r2_05_07`); a register
  op= on a char-indexed element takes `(XHL+C)` (`r2_06_13`); a `?:` whose arms land in different registers is
  unified (`r2_09_13`); a store to a slot after a value whose evaluation pushed arguments recomputes its offset
  (`r2_08_13`); a `switch`'s last arm releases its pops before the end label (`r2_06_14`); no conditional return while
  a register is pushed (`r2_00_13`); `char t = gc2` into QIZH goes through A;
- a single-use local is not folded into its use across a store that may alias what its initializer read
  (`r2_08_05`, `r2_05_10`, `r2_09_01`; `_ultoa`'s `q = s` still folds); the reload-elision passes see `decw 0x1,(XSP)`
  as a write of the slot (`r2_04_19`'s other half); a lazily homed parameter is loaded before `a--` (`r2_08_15`);
- `-Xr`: a pointer sum or `&g[i]` computed while WA holds a live parameter goes to a free family (`r2_06_01`,
  `r2_06_17`), unary minus into a home too (`r2_01_01`), a member store through a global pointer while BC holds a
  parameter (`r2_06_02`), an adecl call's computed argument moved from where it was computed (`r2_09_00`);
- and the **live-parameter guard** (`LIVE_PARAM_GUARD`, `F.emit`): under `-Xr`, an instruction that writes WA, BC or
  DE while the parameter there is still read by a later statement makes the model refuse the function (`r2_07_15`,
  `r2_09_01`, `r2_01_01`).  It is off under the loop allocators, which keep their registers in their own objects.

## The third corpus (2026-11-10, `corpus/random3/`, run 2026-11-10-6-micro-random3)

Seed 3's 200 functions (`gen_random.py --seed 3`), compiled by the oracle in the VM and checked against the model at
ca61cff10 (the second corpus's fixes), found 52 more DIFFERENT verdicts.  After this batch the third corpus reads
55 / 54 / 48 / 49 checked and 0 / 0 / 1 / 2 DIFFERENT (3 / 2 / 4 / 2 exact), all three reviewed in `model/semcheck_review.tsv` as UB only
(`r3_07_00`: `gca[c]` with a negative int parameter; `r3_01_06`: `guca[t]` with `t = gia[4]` negative), and the first
and second corpora stay where they were (0, and the eleven UB-only rows).  `r2_04_19`, the second corpus's open case,
is fixed here too: the reload-elision pass now sees `decw 0x1,(XSP)` as a write of that slot.  Fixed from this corpus:
- two **wrong folds across a call**: a single-use local whose use sits in a loop, switch or if that also calls was
  folded into that use, so the model re-read `gp` / `gps->l` after `vd()` / `v2()` had run (`r3_05_00`, `r3_00_06`;
  `call_before_use` now treats a compound statement that both calls and reads the local as a call before the use);
  and the initializer's own global reads block a fold over a later write of that global when the initializer also
  reads through a pointer or calls (`r3_04_11`, `r3_07_01`, `r3_01_07`);
- the **return after a switch** was hoisted to the compare chain even when an arm `break`s to it, so that arm returned
  garbage (`r3_05_00`; `switch_breaks`);
- a **loop counter in BC across a long helper**: `gul % gula[7]` calls `C9H_remlu`, which the L2 leaf allocator did not
  count as a call (`r3_02_00` -O3 -XS; `long_helper_node` in `plan_leaf`, `one_early_call` and `counted_loop`);
- **pending pops** released inside one arm of a `?:` or `if` only (`r3_00_13`, `r3_06_08`, `r3_08_13`: a flush at the
  condition when nothing is live, and each arm releases its own call's pops);
- `!7UL` folded (`r3_01_13`); an unsigned int index computed by an expression is zero-extended whole (`r3_04_11`,
  `UIDX32_EXPR`); `&gca[t]` with t in a home takes the lda form only for a signed index into XWA (`r3_07_07`);
  `guca[a] = a = (a - guca[4]) / 100` evaluates the inner assignment first (`r3_05_02`); `char *t = gp + a` under
  `-Xr` is `ld XBC,(_gp) / lda XBC,XBC+A` (`r3_03_11`, chidx); a char local in QIZH reads like memory and a pointer
  local in its slot is a base (`r3_07_16`); unary `-` / `~` keep the family the operand came back in (`r3_09_14`);
- and the **live-local guard** (`LIVE_LOCAL_GUARD`): the live-parameter guard now also covers register locals in WA,
  BC, DE or HL, refusing a function whose code would overwrite one that a later statement reads (`r3_04_08`,
  `r3_01_13`, `r3_06_06`); `(gca[0] * 61) % 2` under -O3 -XS is refused rather than computed in the wrong width
  (`r3_07_12`, `CHAR_PRODUCT_DIV_GUARD`).  The first gate of this batch showed the local guard's false positives, each
  now an exemption: a write inside a `return` statement at any depth (`_strlen`'s `if (ss == NULL) return 0xffff;`),
  a parameter copy not loaded yet (`F.deferred`), a call's clobber of a local's home (the homes planner's `cal .g1 /
  ld QIZ,HL`), a counted-loop planner's own init (`ol_c_acc3`'s `ld H,0x0`), and a local no statement has assigned
  yet (`s_add2_u`'s `int d1;`, `_fscanf`'s `va_list args;`: a declaration without initializer defines nothing).

Shapes the third corpus shows and the model does not write yet (exactness, not correctness): a pointer local read
once after a call lives in XIZ without -O (`r3_05_00`: `push XIZ / ld XIZ,(_gp)`, the model uses a frame slot); under
-O3 -XS a loop-invariant element address is hoisted into a stack slot (`r3_02_00`: `lda XWA,_gula+0x1c / ld (XSP+0x2),XWA`)
and a repeated argument is loaded once and pushed twice (`ld WA,(_gi2) / push WA / push WA`); and `-(int)gul` is
`ld XWA,(_gul) / ld HL,WA / neg HL`.
