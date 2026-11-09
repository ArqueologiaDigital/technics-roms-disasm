# Phase 3a status: the Python reference model (2026-11-08)

Where the model (`scripts/analysis/cc900/model/`) stands and what comes next.  Scores are in
`scripts/analysis/cc900/results/model_ledger.md`; register-allocation findings in `model/regalloc_notes.md`.

## Where it stands (V4.23 listings, micro corpus of 674 functions)

| configuration                              | exact         | what is missing                                           |
|--------------------------------------------|---------------|-----------------------------------------------------------|
| cdecl, no options                          | 96.4%         | values kept in IZ / QIZ across calls; a few address forms |
| the same against the 2003 / 2009 compilers | 96.0% / 95.8% | the same; the three compilers agree on nearly all of it   |
| cdecl, `-O3 -XS`                           | 87.5%         | the `-O` behaviours below                                 |
| adecl (`-Xr`), no options                  | 81.8%         | register parameters under pressure (liveness)             |
| adecl, `-O3 -XS` (the firmware's)          | 81.2%         | liveness, then the `-O` behaviours                        |

Every binary and unary operator, comparison and compound assignment at every integer type is reproduced exactly at
no options, as are the loop shapes and the leaf-function register allocator.

## Next, in order

1. **Liveness-aware register choice** (adecl and `-O3`).  A register parameter that dies in an operation is
   computed in place and moved (`add WA,BC` / `ld HL,WA`, `binop_i.c` `add_i_pp` under `O3XSXr`); one that stays
   live is copied to a free register first (`ld DE,WA` / `muls XDE,BC`, `mul_i_loc`).  `muls`, `divs` work on any
   register pair.  Needs last-use information per variable.
2. **Allocation across calls** (`ra_call.c`, `call.c`, `ctrl.c`): which values go to IZ / QIZ and which to stack
   slots.  It looks cost-based (`regalloc_notes.md`, "open" rows); more targeted micro-tests may be needed.
3. **The `-O3 -XS` loop optimizations** (`ra_leaf.c` scores 0 at `-O3 -XS`; run `2026-11-08-8-micro-ra`).  Compared
   with no options, a loop at `-O3` gets:
   - the array base hoisted out of the loop (`lda XDE,_ga` before it: loop-invariant motion);
   - the index strength-reduced to a byte offset in its own register, stepped by the element size (`inc 0x2,BC`,
     `inc 0x4,WA` for long), beside the counter (`inc 0x1,IZ`): an induction variable;
   - one address computed for loads that share it (`lda XWA,XDE+BC` then `add HL,(XWA)` and `add IY,(XWA)`):
     common subexpressions;
   - the bound loaded into a register (`ld IX,(XSP+6)`, compared `cp IZ,IX`), and the loop entered with its test
     first (`cp IX,0x0 / j le` on the bound);
   - `while` loops rotated (`j L27` to the test at the bottom, `-XS`) and `*p++` folded into `(XDE+:2)`;
   - more variables in registers (IZ pushed in a leaf function), in a different order.
   `codegen.py` reads `opt` (`F.opt`) for the rules it has; these are next.  (`score.py` takes the level from the
   oracle directory name.)  The targeted run `2026-11-08-9-micro-optloops` (`opt_loops.c`) pins down the loop
   shapes; `regalloc_notes.md`, "Loops at -O3 -XS", lists them.  What it does not pin down is the register choice
   for counters, bounds, bases and offsets: that needs a model of the allocator (priority order and per-role
   register preferences, fitted to the oracle) rather than more hand-written rules, so as not to overfit the
   examples.
4. **Then the library**: score the model on the 123 `LIB/SRC` files against run `2026-11-08-5` (V4.23 at
   `-O3 -XS -DFLOAT`), which also brings the pairs check (`pairs_check.py`) into reach for the model's output once
   it can be assembled.

## Progress since (2026-11-09)

- Library at `-O3 -XS` (run `2026-11-08-5`, the 71 functions that parse with Toshiba's headers): **10 exact**,
  among them `_strcat`, `_strchr` and `_strncpy`, three of the firmware pairs that every compiler reproduces.
- `-O3` counted loops over one global array (`opt_loops.c`): 15 of 33, with the allocation rule in
  `regalloc_notes.md` (Loops at -O3 -XS); constant bounds walk a pointer to an end pointer.
- Stack-slot frames for non-leaf functions are in place; the IZ / QIZ choice is not (hypothesis in
  `regalloc_notes.md`).

## The next steps, concretely

1. **Struct locals and compiler temporaries** (`_ldiv`, `_div`, and `r_divmod` in `rules.c`).  V4.23 turns
   `dv.quot = ...; dv.rem = ...` on a struct local into stores through address temporaries kept in stack slots
   (`lda XWA,XSP+0xc` / `ld (XSP+8),XWA` / [reload] / `ld (XSP+4),XWA`), and returns the struct through the hidden
   pointer with `ldirw`.  Once the model writes `_ldiv`, switching the reload-after-store rule (rules.md) should
   give the firmware's bytes: the first pair that the kn5000 personality reproduces and V4.23 does not.
2. **The IZ / QIZ choice** across calls (`ra_call.c`, `rc_keep3` vs `rc_keep4` are the hard pair).
3. **Indexed stores into local arrays** (`_ultoa`, `_itoa`, `_ltoa`): the second rule-bearing pair.
4. **char loops with byte registers** (`ol_c_acc2`, `ol_c_acc3`: L, W, H as accumulators, the element in A) and
   loops over two arrays (`ol_i_copy`, `ol_two_arr`).
5. The remaining unsupported constructs in the library (goto, indirect calls, `operator =` inside expressions).

## How to resume

```sh
cd scripts/analysis/cc900/model
R=~/compartilhado/cc900-oracle/runs/2026-11-08-7-micro/out/v423
python3 -I -B score.py $R/none ../corpus/micro/*.c                       # one line per file and a total
python3 -I -B score.py $R/O3XSXr ../corpus/micro/binop_i.c --adecl --show 8   # mismatches, oracle on the left
```

The oracle VM is idle at `~/compartilhado/cc900-oracle/vm/`; new micro-tests go through
`scripts/analysis/cc900/corpus/gen_micro.py` and `oracle/run_oracle.sh`.
