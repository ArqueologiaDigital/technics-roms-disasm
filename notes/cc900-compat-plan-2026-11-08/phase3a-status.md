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
3. **Local arrays** (`_ultoa`, `_itoa`, `_ltoa`): the second rule-bearing pair.  Done since: struct temporaries
   (`_ldiv` reproduced in both personalities), shared exits for identical returns under `-XS`, `s[k] = ...` through
   a pointer parameter.  What `_ultoa` still needs, read from the V4.23 and 2003 listings (run `2026-11-08-5`):
   - a local array's address goes to a compiler temporary at its first use (`lda XWA,XSP+0x10` / `ld (XSP+8),XWA`);
     V4.23 reloads it at once; the 2003 compiler (and so the firmware) keeps XWA for a store through it
     (`ldb (XWA+0x20),0x0`) and reloads it before computing a new address from it (`lda XWA,XWA+0x1f`).  So the
     reload rule's 2003 side is "reload before an address computation, not before a store through the register";
   - frame order: scalar locals first (declaration order), then compiler temporaries (creation order), then arrays
     and structs; dead locals (`u`) and copies (`q = s`) take no slot;
   - `(unsigned long)radix`, used by both helper calls of an iteration, is computed once per iteration into a
     temporary slot (`ld WA,(radix)` / `exts XWA` / `ld (XSP+0xc),XWA`), and XBC is loaded from it;
   - a parameter kept in XIZ is loaded before the loop that first uses it (`ld XIZ,(val)` before `L4`), but inside
     an `if` that first uses it (`_ldiv`);
   - `p--` on a slot pointer is `ld XWA,0x1` / `sub (slot),XWA`; `*p` operations reuse the XWA that still holds p
     after a store through it (`ld (XWA),L` / `cpb (XWA),0x39` / `addb (XWA),0x27`).
4. **char loops with byte registers** (`ol_c_acc2`, `ol_c_acc3`: L, W, H as accumulators, the element in A) and
   loops over two arrays (`ol_i_copy`, `ol_two_arr`).
5. The remaining unsupported constructs in the library (goto, indirect calls, `operator =` inside expressions).

## A proxy route for matching work (2026-11-09)

Until the model or the LLVM implementation is complete, the Technics compiler can be approximated as **V4.23 in the
oracle VM plus the reload rule**: compile with V4.23 (`-O3 -XS`), apply `rule_transform.py`, assemble with asm900 in
the VM.  On the firmware pairs this reproduces 242 of 291, against 235 for V4.23 alone; with the model's `_ultoa` the
rule accounts for 251.  It is usable now for phase 6 experiments (compile a candidate C function, compare with the
ROM), within the VM rule.

Open pairs: `__doprnt` (beyond both neighbours: a variable in IZ and two missing `decw` sequences, probably a later
`__DOFORM.C`), `__facnv`, `__doform` data, `_vsprintf` (the firmware stores XWA to the buffer pointer before loading
it from `(XSP+4)`: the first two instructions swapped relative to V4.23's, which no rule seen so far produces), `_sbrk`,
`___ctype` naming, `__FloatErrorHandle`.

## Progress on the firmware's convention (2026-11-09, later)

The firmware is compiled `-O3 -XS -Xr` (adecl).  Work since the table at the top concentrated there; scores from
`model/ledger.sh` (the full table is `results/model_ledger.md`):

| oracle (v423)                  | corpus              | morning   | evening       |
|--------------------------------|---------------------|-----------|---------------|
| micro, no options              | micro/*.c (674)     | 650       | 667 (99.0%)   |
| micro, `-O3 -XS`               | micro/*.c (674)     | 590       | 632 (93.8%)   |
| micro, `-Xr`                   | micro/*.c (674)     | 552 (82%) | 637 (94.5%)   |
| micro, `-O3 -XS -Xr`           | micro/*.c (674)     | 549 (81%) | 612 (90.8%)   |
| ABI probes, `-Xr`              | abi/*.c (80)        | 7         | 58            |
| switch, `-Xr`                  | micro/switch.c (25) | (new run) | 22            |
| switch, `-O3 -XS -Xr`          | micro/switch.c (25) | (new run) | 20            |
| register corpus, `-O3 -XS -Xr` | micro/ra_*.c (42)   | 0         | 11            |
| parameters, `-O3 -XS`          | micro/opt_params.c  | (new run) | 19 / 24       |
| 1997 library, `-O3 -XS`        | LIB/SRC pieces      | 13 / 71   | 111 / 147     |
| firmware, `-O3 -XS -Xr`        | firmware/tiny.c     | 6 / 6     | 6 / 6         |
| firmware library pairs         | `pairs_model.py`    | (none)    | 126 identical |

What the model now does (codegen.py; each rule cites its oracle function):
- adecl callers: arguments in WA / BC / DE by size, the rest pushed left to right, in the order register moves,
  computed arguments, stack arguments, memory operands, constants; a `__cdecl` callee is recognised (the front end
  parses with `-mabi=cc900`, plus `-mcc900-adecl` for an `-Xr` file);
- homes: a register value live across a call goes to IZ / XIZ / QIZ or a stack slot stored at entry, by reference
  count, branch-aware (if / switch arms, calls inside a return ignored);
- liveness-dependent forms: in-place unary and compound operators on dying registers, narrowing casts by width,
  the `-O` / no-`-O` differences for each;
- data definitions (db / dw / dl / fdatad / strings / dsb);
- switch: jump tables of `dw Lcase-Lbase` with the firmware's own dispatch sequence (`sub XBC,0x2000 / cp XBC,0x0 /
  j lt / cp XBC,0x5 / j gt / add XBC,XBC / add XBC,S / ld BC,(XBC) / lda XIX,L / j XIX+BC`), compare chains with
  ranges, and `-O` cross-jumping (identical tails merged), tail calls.

Library and firmware pairs (later the same day): the library at `-O3 -XS` is 110 of 147 listing pieces (inline
assembly is now passed through, so its labels split pieces as in the listings), and `model/pairs_model.py` rebuilds
117 firmware library pairs byte-identical with our own tools (`phase6-preview.md`).

The order of -O's parameter loads, settled by run `2026-11-09-5-micro-optparams` (`corpus/micro/opt_params.c`,
cc900-oracle `560f24e`): parameters loaded at the start of the function come in reverse declaration order whatever
their uses (all 24 functions); those loaded later, before a second loop, in declaration order (`op_cat`, `op_cat2`,
`op_cat_b`, as `_strncat`); a parameter copied into a local is loaded at that copy (`op_ret_b`, `_memicmp`).  The same
run showed that `*p++ + *q++` loads the right operand first (as `*s1 == *s2` does), that a returned char-valued int
is computed at char width (`op_two`: `ld L,(XDE) / sub L,(XBC) / exts HL`), and that only a cast parameter is stored
through an address temporary (`op_fill` stores a char directly).  Under `-Xr` the same functions show the register
allocator moving parameters out of the scratch registers a loop needs (`op_cpy_nab`: n stays in WA, the temporaries
are DE / E, the pointer leaves XDE for XHL): the model has no allocator for that yet (0 of 24).

Switch under cdecl -O3 -XS (0 of 25): V4.23 turns a switch whose cases all call one function with different
constants into a lookup table of the arguments (`sw_jt6`: `db 10 ... db 15`, `ld A,(XIX+WA) / exts WA / push WA /
cal _f1`).  Under `-O3 -XS -Xr` (the firmware's options) it does not, so this is left for later.

The IZ / QIZ / slot choice for values live across a call: run `2026-11-09-6-micro-rahomes` (`corpus/micro/ra_homes.c`,
cc900-oracle `df41bd5`, all four option sets) gives the data; the rule is not settled yet.  What it shows under `-Xr`:
- two locals: IZ for the first declared, QIZ for the second, whatever their use counts (`rh_ll`, `rh_ll_y2`,
  `rh_ll_x2`; `rh_ll_rev` swaps with the declarations);
- three or four locals: the first declared goes to a stack slot (`rh_lll`, `rh_lll_z2`), with four the last as well
  (`rh_llll`); which of the others gets IZ differs between `rh_lll` (z) and `rh_lll_z2` (y);
- a local and a parameter with two references each: the local gets IZ and the parameter a slot (`rh_lp`); with three
  references for either, both get registers, the parameter IZ and the local QIZ (`rh_lp_x2`, `rh_lp_a2`, `rh_lp_call`);
- two or three parameters: the first gets IZ, the others slots (`rh_pp*`, `rh_ppp`); a long or pointer gets XIZ;
- QIZ is never the destination of arithmetic: `ld QIZ,BC / add BC,DE / ld QIZ,BC` (`rh_lll`).
Without -O (cdecl) parameters already on the stack are mostly left there (`rh_pp`, `rh_p1`).  This looks like a
cost model (QIZ costs moves, a slot costs a store and a frame); fitting it is the next allocator step.

Still open on this convention: the `-O` register allocator for loops (`ra_leaf2..5`: which values go to IX / IY /
IZ / QDE ...), `sw_local` (a local kept in HL across a call), placement of the code after a switch next to the
first case (`sw_evtab`), loops in the switch's continue label (`sw_loop`), long helper homes at `-O` (`mul_l_loc`).

## Operand chains and the code around homes (run `2026-11-09-7-micro-chains`, 2026-11-09)

`corpus/micro/ra_chains.c` (33 functions; cc900-oracle `bc43c90`, V4.23, all four option sets) asks where a chain of
`+ - & | ^` operands is built.  The answer, the same with and without `-Xr`:
- a chain of two or three operands led by memory (a global, a stack parameter, a slot) is built in its target:
  `ld HL,(_gi) / add HL,(_gj) / add HL,(_gk)` (`ch_g3`, `ch_c_xyz`);
- a chain of four or more, or one led by an IZ / QIZ home, is built in WA, moved, and the last operand added in the
  target: `ld WA,(_gi) / add WA,(_gj) / add WA,(_gk) / ld HL,WA / add HL,(_gm)` (`ch_g4`); `ld WA,IZ / add WA,(_gi) /
  ld HL,WA / add HL,(_gj)` (`ch_c_pg2`);
- at `-O` the whole chain stays in its working register (WA, or a dying parameter's register) and moves at the end:
  `add WA,BC / add WA,DE / ld HL,WA` (`ch_p3`), as `ra_noloop3` already showed after a multiply;
- a constant moves to the end of a `+` chain at every level (`gi + 100 + gj`: `add HL,(_gj) / add HL,0x64`);
- `x + x` of a variable in memory is `sla 0x1,HL` (`ch_g3_rep`); of one in a register, `add WA,WA` (`rh_lp_x2`);
- a store or an argument is built in WA (`ch_st3`, `ch_arg3`); a local homed in IZ is built in IZ
  (`ch_loc3`: `ld IZ,(_gj) / add IZ,(_gk) / add IZ,(_gm)`);
- a local that is read once but after a call is not folded into its use: it gets a slot, built in place
  (`ld (XSP+0x4),WA / add (XSP+0x4),BC` under `-Xr`; cdecl `ld WA,(a) / ld (XSP+0x4),WA / ld WA,(b) / add (XSP+0x4),WA`).
- a 16-bit local homed in IZ is computed in IZ (`ld IZ,WA / add IZ,BC`); one in QIZ is loaded, computed in its first
  operand's register and stored again (`ld QIZ,WA / sub WA,BC / ld QIZ,WA`), or, when that operand stays live,
  through a free register (`ch_c_xyg`: `ld QIZ,WA / ld HL,QIZ / add HL,BC / ld QIZ,HL`; not modelled yet).
These rules are in `model/codegen.py` (`chain_wa`, `same_leaf`, `slot_init`, `call_before_use`).  Ledger: ra_chains
28 / 21 / 25 / 27 of 33 (none / O3XS / Xr / O3XSXr), ra_homes 9 / 6 / 16 / 13 of 25 (from 6 / 2 / 4 / 4).

**Still open: which of three locals live across a call gets the slot, and which IZ.**  With the same declarations
(`x = a + b, y = b + c, z = a + c`) the slot goes to x when the return is `x + y + z`, `z + y + x` or `y + x + z`,
to y for `x + z + y` and to z for `x + y + gi + z`.  The fitted home rule (nearest the middle of the declarations)
gives x every time.  The IZ / QIZ split differs between `-Xr` and cdecl for `x + y + z` (z gets IZ under `-Xr`, y
without), and the two-local rule (earlier declaration gets IZ) does not hold for `x + y + gi + z` (y gets IZ).  Five
data points do not decide it; a probe permuting three and four locals over the use order is the next step here.
Other misses left in the run: `-O`'s reuse of a global read twice (`ch_g3_rep2`: `ld WA,(_gj) / ld HL,(_gi) /
add HL,WA / add HL,WA`; `ch_p4` the same for a parameter).  (cdecl `-O` homing a parameter read once after a call,
`ch_c_gp2`, was fixed the same day: under cdecl `-O` a stack-born parameter loses 1, not 0, in the home score;
ra_chains O3XS 21 -> 26, ra_homes O3XS 6 -> 7.)

## Priorities after 2026-11-09

1. **The cost-based allocator.**  The IZ / QIZ / slot choice across calls (run `2026-11-09-6-micro-rahomes`) and the
   `-Xr` leaf loops' temporary family (run `2026-11-09-5-micro-optparams`, `regalloc_notes.md`) block the register
   corpus, `saves.c`, `_itoa` / `_ltoa` / `_atoi` / `_atol` and most of `opt_params` under `-Xr`.  The data is in
   those two runs; the next step is a hypothesis-testing harness over them rather than more single rules.
2. **Floating point.**  The library was built `-DFLOAT`; doubles travel through adecl helpers that take pointers to
   the operands (`_fabs`: `lda XWA,XSP+0x8 / ld BC,0x1 / cal ._fcmp_zd`, `._fld_dd` to copy into the hidden result,
   `._fneg_d`).  About 50 firmware pairs wait on it, most of the sub CPU's (`model/pairs_summary.py`).
3. **cdecl `-O3 -XS` switch to lookup table** (0 of 25 there; not used under `-Xr`, so after 1 and 2).
4. **Phase 3b**: the LLVM implementation, once the model's rules stop moving as fast.

## How to resume

```sh
cd scripts/analysis/cc900/model
R=~/compartilhado/cc900-oracle/runs/2026-11-08-7-micro/out/v423
python3 -I -B score.py $R/none ../corpus/micro/*.c                       # one line per file and a total
python3 -I -B score.py $R/O3XSXr ../corpus/micro/binop_i.c --adecl --show 8   # mismatches, oracle on the left
```

The oracle VM is idle at `~/compartilhado/cc900-oracle/vm/`; new micro-tests go through
`scripts/analysis/cc900/corpus/gen_micro.py` and `oracle/run_oracle.sh`.
