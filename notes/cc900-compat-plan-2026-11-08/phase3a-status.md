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
`__DOFORM.C`), `__facnv`, `__doform` data, `_vsprintf`, `_sbrk`, `___ctype` naming, `__FloatErrorHandle`.

`_vsprintf` (corrected 2026-11-09): there is no swap. `pairs.py` aligned the near match three bytes into the routine,
which starts at `Sprintf_Unlocked` itself (0xff0ab4 in v10, 0xff02d7 in v7). From there the main CPU's copy is V4.23's
with one extra instruction: `ld XWA,(XSP+0x4)` again after `ld (__str),XWA`, before `s[0] = '\0'`. No compiler we have
produces that reload. The IDE, V4.23 and v1.10 library objects all lack it, and so does the HD-AE5000's copy, which is
byte-identical to all three. Two compiler rules were tried and dropped:
- a store to a global clears what the reload rule knows: it also turns the HD-AE5000's `_sprintf` (4 pairs) wrong;
- no register copies of parameters in a function that stores a global (`plan_leaf`, `_ltoa`'s rule): no effect on its
  own, because the reload rule then drops the load.
The routine sits under a locking wrapper, so it was probably built from Technics' own variant of the source (`s`
reread, for instance through a `volatile` or a macro), not by a different compiler. It stays a known miss.

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

## Floating point (runs `2026-11-09-9-micro-fp` and `-10-micro-fptemps`, 2026-11-09)

`model/fpgen.py` (its docstring lists the rules): every operation is a runtime call on addresses; the result
address is set first when it has to be loaded, copied or computed and last when it is a name or a stack offset;
constants go to `f_const` at the start of the function; relation codes `<=` 0, `<` 1, `>=` 2, `>` 3, `==` 4, `!=` 5,
a branch taking the negated relation's; integer conversions go through a 4-byte temporary; FP locals sit at the top
of the frame and the temporaries below them, in a region twice their size; `-O3 -XS` copies an address that is
already in a register.  fp.c: 99 / 108 (none), 98 / 108 (`-O3 -XS`).  Under `-Xr` thc1 refuses double results
(THC1-Error-373); FP parameters and arguments are allowed there (corpus/probes/adfp.c, 15 / 15 at all four sets
since 2026-11-09).

Run 10 (`corpus/micro/fp_temps.c`, oracle `9ce5a95`), now in the model (`root_mode`, `eval_val`, `cond_into`):
- the hidden result pointer is kept in XIZ when the returned expression's last operation has exactly one computed
  operand and no call is involved (`push XIZ` in the prologue, `ld XIZ,(XSP+..)` right before the return's code,
  the result written through `ld XWA,XIZ`), or for a `?:`;
- the result is built in a temporary and copied when that operation has two computed operands or a call result
  (t_mm, t_call_a, d_call_i); the copy's temporary is reserved first and the right operand built in it;
- an operation writes over its computed left operand's temporary (t_chain4: three products in one); temporaries are
  allocated at their first write (t_ci: the long above the double), except an int conversion's, taken before its
  operand (t_to_i_e);
- for `+` and `*` the computed operand goes to XBC (t_amla: `gd3 + gd*gd2`);
- int `x * 2^k` is `sla k` (t_i_e).
Later the same day: a call's computed argument takes the reserved temporary (d_call_e); the copy's temporary is
reserved up front only when the operand is itself a call (d_call_i); a call statement with a double argument
(d_call_v), whose argument pops merge into the frame release; an index in a register (`lda XDE,XBC+WA`, d_loop);
helper calls are never cross-jumped (d_cond); `-O`'s address reuse also when XDE was computed first or the second
operand is a constant (d_loop, d_inc); the branches' common loads hoisted above an FP test, sorted XBC, XDE, XWA
(`_fabs`, t_cond_e); returns share one exit when there is a frame, without `-O` too (t_cmp_e).  fp.c: 108 / 108 at
none and `-O3 -XS`; fp_temps.c: 33 / 33 at both.  From the library's math routines: two returns of a double that are
not the direct form keep the hidden pointer homed in XIZ from the entry (`_sin`; copies then `ld XWA,XIZ` first); a
returned call's computed argument takes the reserved temporary (`_sin`); a negated FP constant is a constant, and a
constant store to an int global is `ldw (_errno),0x22` (`_exp`); a jump-if-true FP condition also computes the
negated relation and jumps on `eq` (`_exp`'s `break`); the destination equal to the right operand is copied to XDE
(`lda XWA,w` / `ld XDE,XWA`); an element of a global struct array (`g_dbltbl[2].val`) ranks first among `+` / `*`
operands (`_cos`); a node whose operands contain a call takes its temporary before evaluating them (`_cos`:
`_trig`'s result at +0x28, the sum at +0x20, `fabs`'s at +0x18), otherwise at its first write (`_sin`: `-x` at +0x28,
`_trig`'s result at +0x20).  `_tan`: a call's argument pops wait for the next call's (`cal _cos` ... `cal _sin` /
`lda XSP,XSP+0x18`); a pointer assigned once from `&x` folds into its single use (`p[3]` -> `ld WA,(XSP+0x3a)`); a
constant on the left of a compare is swapped (`LMTPOW <= ...` -> `cp WA,0x41e0` / `j ult`); the hidden pointer is
homed in XIZ for two returns when the function makes a real call, even if both returns are direct copies.

## Priorities after 2026-11-09

Done since the list below was first written (2026-11-09, later):
- the `-Xr` leaf loop's temporary family: rule R6 (`-O3 -XS -Xr`) and R1 (`-Xr`), fitted in research-scratch
  `sessions/2026-11-09_cc900-leaf-temps` and implemented in `model/leafalloc.py` (`regalloc_notes.md`, end):
  opt_temps.c 38 / 38 (O3XSXr) and 33 / 38 (Xr), opt_params.c 22 / 24 (O3XSXr);
- floating point (`model/fpgen.py`): fp.c 108 / 108 and fp_temps.c 33 / 33 at none and `-O3 -XS`; the sub CPU's
  `_modf`, `_fabs`, `_sin`, `_cos`, `_tan`, `_exp` byte-identical (18 pairs);
- `-O`'s in-place work on a dying register for shifts, `*`, `/` and indexes: micro O3XSXr 612 -> 632 of 674.

What is left, in order:
1. **The IZ / QIZ / slot choice across calls** (runs `2026-11-09-6-micro-rahomes`, `-7-micro-chains`,
   `-8-micro-homes32`; a refit of research-scratch `sessions/2026-11-09_cc900-homes` with the new data is running).
   It blocks `_memccpy` (9 pairs), ra_homes, ra_homes32 and the three-local cases of ra_chains.
2. **The `-O` counted-loop allocator** (ctrl.c's c_sum, c_find, c_copy: counters in IX, `(XHL+IX)` addressing;
   opt_loops.c 15 / 33 under O3XS): blocks `_itoa`, `_atoi`, `_atol`, `_strrchr`, `_strstr` and the math routines
   with integer loops (`_ldexp`, `_frexp`, `_fint`).
3. **The rest of the library**: `__trig` (operand order of `+` / `*` with a member, `&xn` arguments, `++xn` on a
   double), `__doprnt`, `_vsprintf`, `_strcspn` (`goto`).  `_log` now compiles (integer slot locals sit above the FP
   locals, `&nptr` is `lda XWA,XSP+..` / `push XWA`, a `do ... while` FP test uses the relation and `j ne`) but its
   temporaries are spread over the frame (0x44, 0x3c, 0x34, 0x2c, 0x24 for one statement's and the loop's): a
   function-wide, lifetime-based slot choice.  Fitted from run `2026-11-09-13-micro-fpstmts` in research-scratch
   `sessions/2026-11-09_cc900-fp-frame` (7f6721d) and now `fpgen.FrameAlloc`: op slots pooled per statement,
   call and long slots never reused, the longs in one region taken deepest first, the region D + D' (the depth plus
   the depth with the longs pooled), a statement storing to a global takes its root's slot first.  fp_stmts.c 1 -> 14
   (none) and 0 -> 9 (O3XS) of 16; `_log` still differs in 6 of 10 slots (call slots placed ahead of earlier
   temporaries, research-scratch README E2 / E3).
4. **cdecl `-O3 -XS` switch to lookup table**: done for `f(constant); break;` cases with no hole (a byte table,
   `align 1` / `db` per entry; `lda XIX,S` / `ld A,(XIX+WA)` / `exts WA` / `push WA` / `cal _f`; a long selector
   `add XWA,S` / `ld A,(XWA)`; a default after the call); an arm's pops are released before its `break` (they used
   to add up across arms).  `return g(k)` cases too (sw_ret: then `ret`); a single case on a memory selector is
   `cpw (XSP+0x4),0x7` / `ret ne`.  switch.c O3XS 0 -> 20 of 25; left: fall-through, the event-handler shapes.
5. **Phase 3b**: the LLVM implementation, once the model's rules stop moving as fast.

Done since (2026-11-09, evening):
- **Homes across calls** (item 1): rule R3-set under none, `-Xr` and `-O3 -XS -Xr`, and R4 under cdecl `-O3 -XS`
  when a 32-bit value is a candidate (`model/homes.py`; research-scratch `sessions/2026-11-09_cc900-homes`, a6e6b09
  and 1baf8a7, with run `2026-11-09-14-micro-libshapes`).  With the `-O` call-tail merge, call results stored
  from XHL, and single-use values pushed directly, `_memccpy` is byte-identical (9 pairs).
- **`-Xr` / `-O3 -XS -Xr` calls**: a computed product built before a register variable moves into WA (parked in
  BC without `-O`), register parameters stored at entry into slots in reverse order, global memory / constants /
  frame slots in that order under `-O`.  ra_libshapes Xr 7 -> 12, O3XSXr 5 -> 13 of 21.
- **`_log`'s shapes** (run `2026-11-09-15-micro-fporder`): a table element opposite an int conversion is held in
  XIZ (`elem_hoists`); a discarded double result still gets its hidden-argument temporary; constants second in
  commutative ops; a static union member's address first.  `_log` now assembles: 15 of 338 bytes differ, all slot
  depths (E2 / E3).
- **Pairs**: `.sbrk` (table data) right once a `large` extern is taken as 24-bit (asm900 reads the declaration, not
  the address); `pairs.tsv`'s near matches and aliases are counted apart.  kn5000 personality **185** identical,
  v4.23 172; 5 differ (`_log` x3, the main CPU's near-match `_vsprintf` x2).

Done since (2026-11-09, night):
- **L2 in the model** (`model/l2alloc.py`, `codegen.leaf_l2`).  It runs for cdecl `-O` functions with:
  - a ctype table test;
  - one call before the loops, or a final `return f(...)`;
  - a `goto`;
  - any function the old leaf path rejects as Unsupported.
  It needs these code shapes:
  - ctype tests `bit k,(XBC+WA)`, the table base hoisted or per use;
  - held store addresses;
  - in-place `num*10 + (c-'0')`;
  - guarded `djnz` loops;
  - `goto` to a return;
  - `(-XHL:1)`;
  - Q-register locals, `div XWA,DE` with the remainder from QWA, a local array in XIZ;
  - jump threading.
  `_strupr`, `_strlwr`, `_atoi`, `_atol`, `_strrchr`, `_strcspn` and `_itoa` are byte-identical.
- `_strstr` (homes path): a `char` local stored across calls, pops merged with the next call's, branch inversion
  after the tails merge.
- FP: rule R6 (E3, freed op slots reused last-first; research-scratch `sessions/2026-11-09_cc900-fp-prepass`,
  b804104); E2, the order slots are created in, is still open.
- **Pairs: kn5000 221, v4.23 208** byte-identical (from 185 / 172).  Library 158 / 248 pieces (v4.23).

- **Straight-line register shuffles** (research-scratch `sessions/2026-11-09_cc900-binop-loc`, f8143eb, policy T):
  - `-Xr`: the first free pair for `* / %` after the left operand; the shift-count relocation of the WA parameter
    (P for int / long, Q for char); a char local kept out of a live WA; remainders never reused in place.
  - cdecl `-O3 -XS`: byte chains in A / C, never L.
  - Signedness: a narrowed operation keeps its operands' own signedness.
  Several of these also fix wrong code that overwrote a live value.  All binop files are 50 / 50 under every
  option set except the long helpers.  Micro: none 668, O3XS 659, Xr 662, O3XSXr 657 of 674 (from 667 / 634 /
  637 / 635).

Next, in order:
1. The remaining micro misses: the long-helper argument order and homes (`*_l_loc`, `div_l_pk`; README section 6
   of the binop-loc session), `ctrl.c` / `mem.c` loops and addressing (pointer parameters in registers without
   `-O`: c_cnt, c_clear, ra_ptrcpy disagree on when).
2. What still keeps pairs from compiling: `__doprnt` (9), the FP routines `__trig`, `_pow`, `_frexp`, `_ldexp`,
   `__fint` (3 each, waiting on E2 and on union / `fp destination` support), `_strrev` (2: strength-reduced pointer
   copies), `_malloc`.
3. Then phase 3b.

Done since (2026-11-09, late night):
- **Long helpers** (binop-loc section 6): the operand order of `C9H_mulls` / `divls` / `remls` copies, and under
  `-O3 -XS -Xr` the homes of a helper-only function (first operand parameter in XIZ, a helper result in a slot).
  binop_l / binop_ul are 50 / 50 under every option set.
- **mem.c addressing**: `gps->a[k]` (cc900 indexes with the low byte of the scaled offset: `ld C,A /
  (XWA+C)`), `&ga[i]`, `a[i][j]` through `int (*)[4]`, `-Xr` index scaling in the index's own register.
  mem.c is 21 / 21 everywhere.
- **`x & mask` as a condition** (new topic cond_bits.c, run `2026-11-09-22-micro-condbits`).  A one-bit mask is
  `bit n`: in memory for a byte, except bit 7 of a signed char; on WA / QWA for an int or a long.  Any other mask
  is `and`.  Under `-O`, `if (c) return 1; return 0;` becomes `scc`.  109 / 109 / 108 / 108 of 117.
- **Assignment as a value** (new topic assign_expr.c, run `2026-11-09-23-micro-assignexpr`): stored right to left
  from one register, and compared in that register.  30 / 26 / 27 / 27 of 43; what is left is which register a
  local assigned in a condition gets.
- **Calls through pointers**: `(*p->fn)(...)` is `ld XWA,(p) / ld XWA,(XWA+off) / call XWA`.  Char arguments from
  an int in IZ (`ld A,IZL`) and `*s++` (`ld A,(XIZ+:1)`; from a slot `ld XWA,(XSP+d) / ld C,(XWA+:1) /
  ld (XSP+d),XWA / extz BC / push BC`).  `_fputc` and `_fputs` are byte-identical.
- Micro: none 671, O3XS 669, Xr 670, O3XSXr 671 of 674.  Library (v4.23) 161 / 248.  Pairs: kn5000 223.

- **Array elements** (new topic arr_index.c / arr_index_sz.c, runs `2026-11-09-24` / `-25`):
  - an array of known size keeps a computed index in 16 bits; an incomplete one (`extern int a[]`) sign-extends it
    in XWA and adds an immediate base;
  - a char array folds the constant into the symbol (`lda XBC,_gca + 0x1`);
  - through a pointer, `exts` (`extz` for a char element);
  - under -Xr the index is adjusted and scaled in its own register.
  46-51 of 66 per option set.
- **-O copy and constant propagation** of single-assignment locals, and `x + 0` simplification: assign_expr O3XSXr
  28 -> 36, micro-ra O3XSXr 13 -> 18.
- **-O layout**:
  - identical `cal X / ret` tails merge into the last copy;
  - an arm the merge empties goes;
  - an exit block nothing falls into moves to its first jump;
  - cdecl tail calls `j _f`;
  - unreachable code goes.
  switch.c O3XSXr 20 -> 25 of 25.
- **Wrong code fixed** under -Xr: `p[i]` with `p` in XWA no longer builds the index in WA, and the leaf allocator no
  longer gives a local the register a parameter arrives in (c_sum).
- **Micro corpus: 674 / 674 under none, O3XS, Xr and O3XSXr** (run `2026-11-08-7-micro`; reached at 7b7b12f73).
- **Rule U1** (the counted-loop allocator of research-scratch `sessions/2026-11-09_cc900-counted-loops`) is ported as
  `model/u1alloc.py`: opt_counted O3XSXr 32 / 32, Xr 31, O3XS 29; opt_loops O3XS 28, Xr 30, O3XSXr 29 of 33.
- **Without -O**: pointer parameters walked by a pointer-test loop get registers (WA first when no byte temporary);
  BC is kept free for pointer stores.
- **Switches**: -O return-value tables, byte compare chains with an `scc` tail; switch.c O3XSXr 25 / 25, none 22,
  O3XS 22, Xr 22.
- **Homes across calls** under -O3 -XS -Xr:
  - QIZ is never an arithmetic destination;
  - a product of homes, or a char pointer plus a home index, is built in the result register;
  - a homed XIZ local is built in place;
  - a call result goes to its slot from XHL;
  - entry stores and moves come in reverse parameter order.
  ra_homes O3XSXr 14 -> 21, homes32 6 -> 13.
- **Wrong code fixed** under adecl:
  - c_mix pushed a stack argument through XWA while A held an argument;
  - d_ptr loaded a byte into A, the low byte of a pointer in XWA.
- Left in the newer topics:
  - cross-statement CSE of parameter loads (ra_chains `ch_c_*`), and binop-loc's chain register for longer chains;
  - the two-element `g[i-1] += g[i] >> 8` form, and long-element `*=` / `/=` targets (arr_index);
  - a table test with a live register selector (cond_bits `cb_tern`);
  - -Xr shift-count shuffles;
  - FP argument conventions under adecl (abi `c_f` / `c_d`).
  Library (v4.23) 161 / 248; pairs kn5000 223.

Done since (2026-11-09, evening), each from a probe run of its own (`corpus/probes/README.md`):
- **FP parameters and arguments under adecl** (`probes/adfp.c`, run `2026-11-09-29-micro-adfp`: 15 / 15 at all four
  sets): a double is on the stack and uses up its register position; a float travels in its register, through a
  4-byte frame temporary on the caller's side and a slot at entry on the callee's (abi.md).  abi 98 -> 99 (none),
  adecl abi 73 -> 75 (-Xr), 75 -> 77 (-O3 -XS -Xr).
- **A call on the right is built first** (`a + f(x)`, `a + (x > 0.0)`): the model used to load `a` into HL and then
  call, which is wrong code.
- **Int arithmetic on a char is done in the byte** (`probes/chnarrow.c`, run `2026-11-09-30-micro-chnarrow`;
  `codegen.char_narrow`): `c - 48` is `sub A,0x30` and an extension, unsigned when either side is (`c + 200`);
  `c * k` is the byte multiply; a `?:` with char arms is extended once after the join.  19 / 18 / 19 / 18 of 20.
- **Two wrong-code fixes in table tests under adecl** (arr_index.c `ai_xdig_i`, `ai_dig_val`): the narrowing
  `(unsigned char)` cast of a register index was dropped, and a table byte was loaded over the char it is indexed
  by.  The byte is now tested in place (`bit 0x2,(XDE+BC)`), as cc900 does.
- Smaller rules: local union elements as `(XSP+d)` operands that keep a zero displacement (`(XSP+0x0)`); a one-bit
  `or` is `set`; `ret eq` keeps what the reload rule knows; a `?:` arm is exclusive for last uses.
- **`_vsprintf`** was misread as a swap; it is one extra reload, most probably from a Technics source variant (see
  the open-pairs paragraph above).
  Micro 674 / 674 at all four sets throughout; library (v4.23) 169 / 248; pairs kn5000 223.

Array elements (2026-11-09, night), from runs `2026-11-09-24-micro-arrindex` / `-25-micro-arrindexsz`:
- **Wrong code fixed**, all in compound assignments to array elements:
  - a long element with `*` / `/` / `%` kept its address in XDE / XBC across the helper call. cc900 builds it in
    XIZ (`push XIZ`), at every option set; a multiply by a constant with few one bits is inline instead;
  - `g[i-1] += g[i] >> 8` overwrote the target's address (none) or the index (`-O3 -XS -Xr`);
  - a sized long array's `(XDE+WA)` target lost its index to the loaded value; cc900 makes the address one
    register (`lda XBC,_gla` / `lda XDE,XBC+WA`).
  The model now refuses any target operand that the right side could clobber.
- **The two-element forms**: under -O, cc900 shares the array base between `g[i+k]` and `g[i]` (`shared_base_opassign`),
  or uses DE / XIZ for a pointer target (`pointer_pair_opassign`). Without -O it puts the target in XDE (sized:
  `(XHL+DE)`, `sized_pair_noopt`).
- arr_index 50 / 48 / 49 / 49 -> 56 / 58 / 55 / 59 of 66 (none / O3XS / Xr / O3XSXr); arr_index_sz
  51 / 48 / 49 / 48 -> 57 / 58 / 56 / 59.
- Left: the strength-reduced loops (`ai_div10`, `ai_mul10`, `ai_carry`, `ai_shift`: an end pointer and `(XBC+:2)`),
  the char forms (`ai_c_g_sh`, and `ai_c_p_carry`, which cc900 reduces to `inc 0x1,BC`), and the table-test
  preloads (`ai_up`).
- **A missing instrument**: three of these wrong-code bugs were found only by reading the model's output beside
  the oracle's. A function that does not match is not checked for meaning. An interpreter for the model's
  output, run on random inputs against the oracle's code, would catch them; phase 3's random-program tests
  need one anyway.

The behavioural check (2026-11-09, late): `model/semcheck.py` (commit 43da7f613, README `model/semcheck.md`) runs
the model's code and the oracle's in a TLCS-900 interpreter on random inputs and compares what a caller sees. Its
first run found 74 DIFFERENT functions over the micro and probe corpora, 63 of them wrong code in the model, all in
functions that did not match the oracle's text. After the fixes that followed it reports 12, with no ledger row lost
on the way (`results/semcheck.md`):
- 3 differ only where the C overflows (`ai_shift` x2, `oc_down`, none);
- the rest are none-mode loops whose counter the model puts where cc900 does not (`ai_carry`, `ai_div10`,
  `oc_add2`, `oc_clr_l`, `ol_two_arr`), and `rh_ptr_int` under -O3 -XS -Xr, a homes choice;
- the guards added on the way (`held_after`, `IDX_GUARD`) refuse a function instead of writing wrong code
  when a register they would overwrite still holds a variable. They approximate liveness; see
  `held_after`'s docstring.
Run it after every change, beside the ledger and the pairs:
`python3 -I -B model/semcheck.py --ledger --jobs 4 --results results/semcheck.md`. The DIFFERENT count must not
rise.

Leaf registers without options, and what the lnr probes showed (2026-11-09, night):
- **Rule LN1** (`model/leafnone.py`, `regalloc_notes.md`) now chooses the registers of a leaf function with a loop
  under no options.  It came from an agent's fit (research-scratch `sessions/2026-11-09_cc900-leaf-none`): 275 / 275
  fitted functions, 15 / 18 on the held-out `lnr4.c` after six fixes.  Ledger: micro_ra 33 -> 34, opt_counted
  25 -> 27, cond_bits 113 -> 114, assign_expr 30 -> 31, opt_loops 23 -> 27 (none).
- **The probes `lnr.c` .. `lnr4.c` joined the ledger** at all four sets (runs `2026-11-09-31` .. `-34`).  They keep
  three locals live across each loop, and semcheck found **61 more wrong-code functions** in them: templates that
  wrote a register still holding a variable read after the loop.  All 61 are gone, each fixed to V4.23's form or
  refused:
  - `held_after` now also sees a variable whose first reference after the current statement is a read
    (`read_after_top`); a write first (`d1 = g1`) leaves it free;
  - the element and store templates take the first free register where V4.23 does (`p[i] op= x`: XBC, XDE, XHL,
    XIX, XIY; `*gp = i` and `p[i] = i`: XWA; `gr = p[i]` under -Xr: the address register; `1 << i`: the next free);
  - generic guards (`clobbers`, `STORE_ADDR_GUARD`) refuse a store, op= or multiply whose code overwrites its own
    address or a live variable;
  - a local written in between was folded into its single read (`h5`: `gc = c` stored c's initial value); fixed
    in both the fold and `foldable`.
  Probe scores, none: lnr 25 -> 28, lnr2 19 -> 22, lnr3 6 -> 12, lnr4 5 -> 6; the other sets are 0-9 of 18-50:
  the probes' crowded loops need QWA / QDE and loop-invariant hoisting (`*gp`, `n + n` into DE before the loop),
  which the model does not have.
- Also: `i--` then `i >= 0` is `sub R,0x1` + a signed branch (no `dec` / `cp R,0x0` pair in any listing; they differ
  when n = -32768), and an if/else arm does not `ret` before a frame is released (`s_if`).
- semcheck DIFFERENT: 10 -> 5.  Left: `rh_ptr_int` (O3XSXr homes), `_fmod`, `_strtok`, `_tanh`, `__trig` (O3XS
  library).  Library 172 / 248, pairs kn5000 223: unchanged throughout.

The library and the fitted rules of three agents (2026-11-09 night to 2026-11-10):
- **Library 172 -> 184 of 248** (v4.23, -O3 -XS; kn5000 170 -> 182) with pairs kn5000 steady at 223, from rules
  read off single library functions: `store_forward` (a value just stored to a global or static is used from its
  register: `_strtok`), the argument pop before a test (`add XSP,n` when only the test reads the result, else
  `lda`), a pointer difference in place, a pushed chain's register (`___fmemccpy`), `k = f()` straight into k's
  slot and the hidden result pointer homed in XIZ by the homes2 rule (`_floor`, `_ceil`, `acos`), `dfb` tails,
  width-aware struct arrays and double tables as data (`__ctype`, `_normtab`, `s_coshtbl`, `__fint`'s `maru`).
- **Pops**: call statements' pops merge up to 32 bytes (two 12-byte `fd()` calls, six 2-byte calls, `frexp` +
  `ldexp`), and pending pops are released before a loop; both found by semcheck on the fpp7-fpp9 probes, where
  the model popped inside the loop body (wrong code).
- **Three fitted rules reported** (research-scratch `sessions/2026-11-09_cc900-fp-e2b`, `_cc900-homes2`,
  `_cc900-leaf-none`):
  - LN1 (leaf registers without options) is in `model/leafnone.py`;
  - the homes2 rule (IZ / QIZ / XIZ across calls: a Chow-style priority colouring by references per span, later-
    declared of two locals takes IZ, `register` ignored) beats `homes.py` on every probe file (held-out homes2b
    76 / 67 / 73 / 75 % of values against 47 / 42 / 56 / 52 %) but not yet on the library's variables (78 % vs
    82 %); its result-pointer part (20 of 21) is ported, the rest waits until it is also better on the library;
  - the window rule (the order of FP frame temporaries, E2) is `model/fpwindow.py`, hooked into fpgen's two
    passes behind `WINDOW_RULE` and guarded (no early return, break / continue / goto or long slot): fitted
    365 / 373 layouts, held-out fpp9 26 / 48.  Its gate is the next entry.
- semcheck: 61 wrong-code functions found by the lnr probes and 32 by the fpp probes are all fixed or refused;
  11 remain in fpp7 / fpp8 (FP argument stacks), 2 in homes2b, plus `__trig` (reviewed, not observable).

State at 2026-11-10 02:00 (commit 5b8c6bf8b): micro 674 / 674 at all four sets; library 185 / 248 (v4.23),
183 (kn5000), 174 (ide2003); pairs kn5000 223 MATCH; semcheck DIFFERENT 1 (`__trig`, reviewed).  The window rule
plus the pop fixes took the FP probes from 4-36 to 44 / 51 / 86 / 29 / 31 / 21 / 6 of 59 / 59 / 100 / 56 / 79 / 108 /
60 (fpp3-fpp9, none).  Two FP operand rules came from fpp7: the operand with more calls is evaluated first (the
right one on a tie), and for `+` / `*` the operand computed last is passed in XBC.  `_fgetc` matches through a
member-address cache (p in XDE, the twice-used member's address in XBC).  Left in the library, by kind: register
homes (`_fread`, `_fwrite`, `_frexp`, `_ldexp`, `_sgl_set`, `_normlz2`: the homes2 port decides), rule L2 shapes
(`_strspn`, `_stricmp`, `_strnicmp`, `__todigit`'s byte temporaries), FP slot sharing E3 (`_log`, `_sqrt`, `cosh`,
`sinh`, `tanh`, `atan2`), `__doprnt` and the `__afcnv` / `__facvt` families (unsupported constructs: local array
element stores, `_frccal`'s unrolled compare chain).
The homes2 rule ported (2026-11-10, `model/homes2.py`; `regalloc_notes.md`, "The homes2 rule, ported"): the
session's linearizer and colouring, keyed by declaration, applied by `codegen.plan_homes` behind `codegen.HOMES2`
(environment `CC900_HOMES2`) with nine policies.  Read back through each declaration's register it reproduces the
rule's homes on homes2a / homes2b and gives 164 of the library's 198 variables (rule 155, homes.py 163), because only
plan_homes's own candidates may be homed.  Measured with the ledger, the pairs and semcheck at every policy:
- `all` / `r4keep` gain 144 / 145 functions over the 131 ledger rows (homes2a Xr 28 -> 79, O3XSXr 27 -> 67, held-out
  homes2b +7 / +4 / +15 / +12, regkw 0 / 2 / 3 / 0 -> 8 / 10 / 7 / 10, ra_chains +2 / +2, micro-ra Xr +4) but lose
  one micro function per set (`c_nested`, `k_keep`), ra_homes Xr 19 -> 11 and O3XSXr 23 -> 13, micro-ra none -3,
  abi -1: the adecl parameter-against-local contests, two locals computed from register parameters, and loop
  counters, where homes.py's pair test and declaration order are right and the rule is not;
- `fallback-noloop` (cdecl -O3 -XS functions without a loop where `homes.choose` returns None) moves no row down:
  regkw O3XS 2 -> 10, homes2b O3XS 7 -> 9.  **Adopted.**  The library rows (184 / 182 / 173) and the pairs (223
  MATCH) are unchanged under every policy.
- Fixed on the way: a 16-bit or 8-bit memory compare printed its negative immediate at 32 bits (`cpw
  (XSP+0x20),0xfffff801`, which llvm-mc refuses; `_ldexp` when `nn` is in memory); the rule's linearizer now
  walks a calling operand before its siblings are read (`a + b + (x > 0.0)`, adfp ad_idi).

Char indexes (2026-11-10, `model/chidx.py`; probe `corpus/probes/chidx.c`, run `2026-11-10-4-micro-chidx`, found by
the random corpus r1_02_12 / r1_03_19 / r1_04_01): an element address or pointer sum whose index is a char.  V4.23
keeps a signed char in the byte wherever the addressing mode takes an 8-bit index register (`ld A,(c) / add A,(c) /
lda XBC,_gia / ld HL,(XBC+A)`; a char array's index zero-extended whole, `ld XWA,0x0 / ld A,(c) / add XWA,XBC`),
and widens an unsigned char to a word first (`extz WA / add WA,WA / (XBC+WA)`).  An index expression of chars
(`c + 1`, `c + d`, `u * 2`) is computed in the byte, so `gia[u * 2]` reads element `(u * 2) & 0xff`: the
compiler's own wrong code, imitated (semcheck had reported fu2 DIFFERENT against the correct model).  `-O3 -XS`
loads the char straight into the register it is widened in (`ld C,(c) / exts BC / add BC,BC`) or into the other
scratch byte for the byte doubling (`ld C,(c) / ld A,C / add A,C`); `-Xr` takes the parameter's byte in the
addressing mode (`lda XBC,_gca / ld L,(XBC+A)`; `ld L,(XWA+C)`), doubles a register variable into the first free
byte (`ld C,A / add C,A / lda XWA,_gia / (XWA+C)`; `ld E,C / add E,C / (XWA+E)` when XWA holds the struct
pointer) and scales by four in place (`sla 0x2,A`).  The module's docstring has the forms by base kind, element
size and read / store / sum.  chidx.c: none 48 -> 50, O3XS 24 -> 50, Xr 0 -> 50, O3XSXr 0 -> 50 of 50 (the two -Xr
rows had been the old index path's wrong code: `ld BC,A`, `ld WA,A`).

The E3 rules installed and the random corpus's wrong code (2026-11-10, later).  `model/fpe3.py` (the E3 session's
rules, ported by an agent and hooked over `fpgen.py` behind `fpgen.FPE3`) took the FP probes from
44 / 51 / 86 / 29 / 31 / 21 / 6 / 27 / 8 to 46 / 51 / 86 / 33 / 42 / 46 / 8 / 70 / 43 (fpp3-fpp11, none; fp_order 10 -> 12,
fpp1 24 -> 31, fpp2 21 -> 25) and the library to 186 / 248 (v4.23), 184 (kn5000); the pairs stay at 223.  Two pop
rules came out of the semantic check: the pending pops of an earlier call wait under a call's pushed arguments
(fpp11 q15: `ldexp(f * 2.0, n / 2)` after `frexp` released them between `push WA` and `._fmul_d`, dropping the
argument), while a call made inside the argument list releases its own at once (`_cos`: `cal _fabs / lda XSP,XSP+0xc`
before `._fadd_d`); and the pops are released before an expression statement that makes no call, unless it assigns a
register variable (random r1_02_19 against homes2a B09 / homes2b HP07).  The random corpus's first-pass wrong code is
fixed (`corpus/random/README.md`, "Second pass"): random1 none 4 -> 8, Xr 2 -> 4 of 200; semcheck DIFFERENT 48 -> 41,
all but `__trig` in the random corpus (32) and fpp10's four uninitialized-local functions (reviewed).  Gate: no ledger
row down, micro 674 / 674 at all four sets, chidx 50 / 50 at all four.

The random corpus's second round (2026-11-10, later still): the 32 DIFFERENT functions left after the chidx batch
are all fixed or refused (`corpus/random/README.md`, "Third pass": fourteen rules and four guards, among them char
homes in `QIZH`, the `-Xr` first-live-parameter home, the pointer-in-XWA / left-in-BC operand form, the `lda
XWA,XBC+A` char-pointer sum).  semcheck DIFFERENT 41 -> 9: `__trig` (reviewed) and fpp10's four uninitialized-local
functions (reviewed).  No ledger row moved; the pairs stay at 223; micro 674 / 674 and chidx 50 / 50 at all four
sets.  The random corpus's exact counts did not move (8 / 2 / 4 / 2 of 200): what it shows now is unsupported shapes
and listing differences, not wrong code.

The second random corpus (2026-11-10, night; `corpus/random2/`, run `2026-11-10-5-micro-random2`): 200 functions
of seed 2 found 81 DIFFERENT verdicts the first corpus had not reached.  Two rounds of fixes (`corpus/random/README.md`,
"The second corpus"; about twenty rules and guards, among them the live-parameter guard under `-Xr`) leave 12:
eleven reviewed as UB only in `model/semcheck_review.tsv`, one open (`r2_04_19` -O3 -XS).  Gate: no ledger row
down (micro 674 / 674 at all four sets, library 186 / 184 / 174, pairs 223 MATCH); semcheck DIFFERENT 9 -> 21, the
twelve above; the first random corpus 0 DIFFERENT at every set.  The exact counts of the random corpora are still
1-4 %: what is left there is unsupported shapes and the order in which V4.23 evaluates operands (a Sethi-Ullman-like
"heavier operand first", seen in r2_05_13 / r2_06_05 / r2_02_18), the next rule to fit with a probe of its own.
The blog draft `notas/blog/2026-11-10_programas_aleatorios_contra_o_modelo.md` tells the day for outside readers.

The third random corpus (2026-11-10, early morning; `corpus/random3/`, run `2026-11-10-6-micro-random3`): seed 3's 200
functions found 52 DIFFERENT verdicts against the model at ca61cff10.  One batch of fixes (`corpus/random/README.md`,
"The third corpus") leaves 3, all reviewed as UB only, and also closes `r2_04_19`; so no random corpus has an open
wrong-code verdict.  Two of the fixes matter beyond the corpus: a single-use local was folded into a use inside a
loop or switch that also made a call (the model re-read the global after the call), and the return hoisted after a
switch's compare chain was skipped by an arm that `break`s.  Gate: no ledger row down (micro 674 / 674 at all four sets, library 186 / 184 / 174, pairs 223 MATCH), the four
random3 rows added; semcheck DIFFERENT 21 -> 23 (`r2_04_19` gone, the three UB-only random3 rows added).  The exact counts of the random corpora
stay at 1-2 % (random3: 3 / 2 / 4 / 2 of 200); the shapes seen there and not written yet are listed at the end of that README section.

The fourth random corpus (2026-11-10, morning; `corpus/random4/`, run `2026-11-10-7-micro-random4`): 27 DIFFERENT
lines against a4fc98542; one batch (`corpus/random/README.md`, "The fourth corpus") leaves the nine UB-only verdicts
of four functions, reviewed.  Beyond the corpus the batch fixed constant shifts in `fold` (a negative constant's
right shift was arithmetic: `~0x10000UL >> 3`), the compare of a narrowing cast, and two last-use holes (`a--` as a
read, a death in a returning arm).  Gate: no ledger row down, random1 none 8 -> 9, random4 8 / 4 / 7 / 4 of 200;
semcheck DIFFERENT 23 -> 31 (`r2_06_02` gone, the nine random4 rows added); pairs 223.

**The order of evaluation of binary operands** (2026-11-10, morning; `corpus/probes/evorder.c`, 507 functions, run
`2026-11-10-9-micro-evorder`; the probe generator and the order analyser are in research-scratch
`sessions/2026-11-10_cc900-evorder/`).  The three random corpora had shown "the heavier operand first"; the probe
(13 operand kinds x 13, for - ^ *, the left side reading g* globals and the right h*) gives the rule, the same at
all four option sets: one operand is the accumulator (HL; XWA for *), the other the instruction's source.  For -
the left is the accumulator; for + & | ^ * a value that needs computing is the accumulator when the other side is
not one, a constant never is, two addressed operands (*p, p->m, g[i], and a struct member or constant-index
element too) make the right one the accumulator, otherwise the left.  Code order: the addresses in textual order,
then the source's value, then the accumulator's value or load, then the operator; registers: an index claims WA /
XBC first, a value WA (BC when the accumulator's code needs WA), pointers the next free family, a right pointer
XWA; `!x` and `-x` as the accumulator compute in WA and move to HL (under -O `!x` goes to HL directly and `-x`
keeps the operator in WA); `a - -b` is `a + b`; `(K1 - x) - K2` folds.  Implemented as `evorder_bin` (flag
`EVORDER`) in front of the simple-operator and multiply paths for 16-bit operands with the result in HL, no calls,
helpers or register variables; the probe reads 442 / 383 / 198 / 155 of 507 exact at none / -O3 -XS / -Xr /
-O3 -XS -Xr (118 / 115 / 118 / 115 before).  Not written yet: a `?:` beside a member or element (V4.23 materializes
the member's address first, `lda XWA,_gs`), two indexed elements (the index is shared), a shift beside an indexed
element (IX), and the -Xr forms, where the parameter in WA is a register variable the rule leaves to the older
paths.  Gate: no ledger row down (micro 674 / 674 at all four sets, chidx 50 / 50, library 186 / 184 / 174, pairs kn5000 223 MATCH), the four evorder rows added; semcheck DIFFERENT 31 -> 31 (the probe's 34 wrong-code verdicts of the committed model became refusals: 21 / 31 / 72 / 72 functions not checked at none / -O3 -XS / -Xr / -O3 -XS -Xr).

Two more probes the same morning (`corpus/probes/evorder_st.c`: the kinds as a stored value, `es_*`, and as a pushed
argument, `ea_*`; `corpus/probes/evorder_l.c`: the kinds as longs; run `2026-11-10-10-micro-evorder2`) show the same
order matrices with each context's registers: a stored value accumulates in WA and the source takes BC; a WA
accumulator loads from its own pointer or index; a pushed argument lets the source take WA and the accumulator the
first free family (or its own pointer's, or its index register); longs follow the int rule in XHL / XWA / XBC with
`!l` / `-l` through XWA.  `evorder_bin` now takes the context (HL, WA, ANY) and sizes 2 and 4, and a parameter the function never reads holds
no register under -Xr; the probes read evorder.c 442 / 394 / 356 / 315 of 507, evorder_st.c 546 / 465 / 397 / 428
of 676, evorder_l.c 259 / 191 / 206 / 148 of 338 at none / -O3 -XS / -Xr / -O3 -XS -Xr.  Two safety nets came out
of it: `clobbers()` sees `scc` (a `scc eq,BC` over a member store's address in XBC was wrong code, `r2_06_05`), and
`emit` refuses a byte register loaded into a word register (`ld WA,A` for a char index under -Xr, `r2_02_05`, from an
older path the committed model's refusal of the return expression had masked).  Gate: no ledger row down (micro 674 / 674 at all four sets, chidx 50 / 50, library 186 / 184 / 174, pairs kn5000 223 MATCH); random2 none and -Xr 2 -> 3; evorder.c -O3 -XS 383 -> 394, -Xr 198 -> 356, -O3 -XS -Xr 155 -> 315; eight rows added; semcheck DIFFERENT 31 -> 31 (r2_06_05 and r2_02_05 became refusals).

A fourth probe (`corpus/probes/evorder_d.c`, the int kinds for `/` and `%`, run `2026-11-10-11-micro-evorder3`): the
same order with a multiply's registers (the left accumulates in WA, `exts XWA / divs XWA,src / ld HL,WA`, the
remainder from QWA; under -O a plain left divides in HL).  `ev_mul_div` covers them; the probe reads 252 / 202 /
214 / 180 of 338 at none / -O3 -XS / -Xr / -O3 -XS -Xr (86 / 78 / 86 before), no wrong code.  Three findings from
functions the wider rule now compiles: V4.23 types a constant 128..255 as an unsigned char, so `~255` is 0, `~139` is
0x74 and `-8 ^ ~255` folds in the byte to 0xf8, while `~4` stays 0xfffb (imitated in `fold`); an immediate stored by
`ldw` / `ldb` is masked at emit; and the exit label of an early return goes after the last return's call pops
(`r3_03_06` crashed).  Gate: no ledger row down (micro 674 / 674 at all four sets, chidx 50 / 50, library 186 / 184 / 174, pairs kn5000 223 MATCH), the four evorder_d rows added; semcheck DIFFERENT 31 -> 31 (the functions the wider rule exposed are equal or refused).

**Compares** (2026-11-10, midday; `corpus/probes/cmpord.c`, 507 functions, run `2026-11-10-12-micro-cmpord`): the
same operand order, and the compare instruction per kind pair: a computed right goes to WA and a memory left stays
in memory (`cp (_gi),WA` ordered, `cp WA,(_gi)` for `==`), a computed left goes to WA against a memory right, two
computed operands `cp BC,WA` (the right first), a unary-minus left owns WA, a shift's value is in BC, a left `*p` stays
`(XBC)` against a computed right, a right `*p` takes XBC (or XWA before a left value), a constant right keeps the
left in memory (`cpw (XWA),0x7`), `==` of two offset or addressed operands loads the right; and in a condition V4.23
compares `!x` with the truth value of a constant (`if (!gi == 7)` -> `cp WA,0x1`; as a value the 7 stays).
`cmp_order` in `gen_compare`; the probe reads 429 / 378 / 363 / 315 of 507 at none / -O3 -XS / -Xr / -O3 -XS -Xr.
The arguments of the long `*` `/` `%` helpers follow suit (`corpus/probes/evorder_lh.c`, run
`2026-11-10-13-micro-evorder4`): the left in XWA, the right in XBC (`*` puts the operator rule's accumulator in XWA),
pointer addresses first, the source value, the accumulator value, plain loads with a plain variable before a member,
constants last, pointer loads last in place; `long_helper_order` in `gen_long_helper`; the probe reads 246 / 124 / 211 / 109 of 507 at none / -O3 -XS / -Xr / -O3 -XS -Xr
(30 / 31 / 30 before).  Gate: no ledger row down, the eight cmpord and evorder_lh rows added, semcheck DIFFERENT 31 -> 31, pairs 223 MATCH.

**Register temporaries** (2026-11-10, afternoon; `corpus/probes/loc0.c`, 512 functions, run `2026-11-10-14-micro-loc0`;
research-scratch `sessions/2026-11-10_cc900-refusals/`): the random corpora's commonest refusal was a local with an
initialiser (`int *t = gpi;`, `unsigned long t = gula[5];`, `unsigned char t = guc + 212;`: 150 to 190 functions per
set).  The probe (8 types x 4 initialisers x 4 statements in between x 4 uses) shows the rule, the same at the four
option sets: a local whose value never lives across a call is a register temporary -- WA when nothing but its own uses
follows the declaration (`ld WA,(_gi) / ld (_hi2),WA / push WA`), else the lowest of BC, DE, HL that the code in between
does not write (`ld BC,(_gi) / ld WA,(_hj) / ld (_hi),WA / ld (_hi2),BC`; random r1_00_07 XHL behind an element update
that uses BC and DE), a call result in HL / L / XHL where it takes the operator in place (`cal _ri / add HL,(_hi) /
ld (_hi2),HL`); a byte in the low half (`ld C,(_gc)`; a computed byte through A, `ld A,(_gc) / add A,(_hc) / ld C,A`); a
pointer sum through XWA (`ld XWA,(_gp) / inc 0x1,XWA / ld XBC,XWA`); the values that live across a call stay homes2's
(IZ / QIZ / XIZ, loaded or computed directly: `ld XIZ,(_gl)`, `srl 0x3,XIZ`, stored and pushed directly, `ld (_hl2),XIZ`,
`push XIZ`, a QIZH through A).  `plan_regtemps` / `regtemp_candidates` in codegen.py, without -O: the candidates are
tried in order and the live-register guard's `LiveClobber` makes `compile_function` retry with the next one (the WA
trial generates the code in between as if WA were free, `live_regs` / `held_after` hide a WA temporary, so a statement
that computes anything moves the temporary to BC); when all fail the local keeps its slot.  A local read once by the
next statement is still folded there, except a call argument (materialized: `ld WA,(_gi) / push WA`) and a call result.
`regtemp_premark` runs before the home planners so that homes2 and plan_registers leave those locals alone (a long
call result read next by a call stays in XHL).  The probe reads 510 / 132 / 510 / 147 of 512 at none / -O3 -XS / -Xr /
-O3 -XS -Xr (116 / 112 / 130 / 127 before; the two left are a pointer offset from a plan_registers XIZ home; -O is
not modelled yet).  Also in this batch: `gs.a[3]` is a static operand (`(_gs + 0x14)`, `global_offset`), `&gia[5]` /
`&gca[4]` a single `lda` (`ADDR_GLOBAL_CONST`).  Over the four random corpora at none the functions refused whole fell
from 549 to 502 of 800 (`stmt_bisect.py`, which compiles each statement of a refused function alone to name the
statement behind the refusal).  The next probe, `corpus/probes/stord.c` (432 functions, run `2026-11-10-15-micro-stord`),
maps the order and registers of a store's address and value, the next two refusals ("the value overwrites the store
address", "complex long helper operands"); the model read 212 / 202 / 199 / 171 of it before any rule.

**The store rule** (2026-11-10, afternoon; `store_plan` / `sp_address` / `plan_store_xiz` in codegen.py, the same at
the four option sets): the address first and the value second, except after a call (`cal _ri / ld XWA,(_gps) /
ld (XWA+0x2),HL`).  A plain `*p` takes XBC with the value in WA whatever the value; a member with a displacement
takes XBC before a loaded value in WA and XWA before a computed value in BC (`ld XWA,(_gps) / ld BC,(_hi) /
sub BC,(_hj) / ld (XWA+0x2),BC`; `divs XBC,(_hj)`: the multiply and divide paths take the planner's accumulator); a
global element takes BC / XDE with the value in WA, or WA / XBC with the value in DE for a difference or a `!`; a
member array element through a pointer the same with E / XBC and C / XWA; `p[i]` builds its address in XWA and moves
it to XBC, straight in XWA after a call; a shift's value goes to the next free register with the count in WA; a `?:`
value takes its address first in XBC, a displacement added (`inc 0x2,XBC`), a static member too (`lda XBC,_gs + 0x2`);
an element value keeps WA / XBC and the address moves over (`ld XDE,(_gpi)`; `ld DE,(c) / add DE,DE / lda XHL,_gia`;
a member's pointer keeps XBC and the element's base moves to XDE); a long helper's store through a pointer keeps the
address in XIZ across the call (`push XIZ / ld XIZ,(_gps) / ... / cal C9H_divls / ld (XIZ+0x4),XHL / pop XIZ`,
`plan_store_xiz` saves XIZ in the prologue); a char value computes in WA and stores A, a char element at an int index
adds the zero-extended index to the array's address (`lda XWA,_gca / ld BC,(c) / extz XBC / add XBC,XWA`); under -Xr
the index parameter in WA is used in place.  The probe reads 337 / 202 / 286 / 171 of 432 at none / -O3 -XS / -Xr /
-O3 -XS -Xr (212 / 202 / 199 / 171 before; the -O sets wait for the planner to run under -O).  What is left: a value
that divides by an indexed element (the value first, then the address), an indexed left operand of a divide, a long
helper into an element (the index in IZ and the base in a slot), a shift whose count is also the index, and the char
arithmetic that loads a char global as a word (`ld WA,(_hc) / sub WA,(_hd) / ld (_gc),A`, the model's byte ops).
The semantic check of the first gate found six wrong-code shapes the wider rules had reached, fixed in the same
batch: a register temporary clobbered within its own statement (the guard now counts a read later in the statement:
r2_08_14, r3_08_15, r3_03_00), a byte compare with an unmasked immediate (`cp A,0xffc2`: r3_01_02), a pointer plus a
char index into an XIZ home (refused: the oracle zero-extends it through IZL and interleaves the next statement,
r1_04_19), an unsigned register-parameter index extended whole (r3_08_11), the XIZ initialiser's constant left
operand; two out-of-range index verdicts (r3_01_02, r3_01_06) are reviewed as UB in `model/semcheck_review.tsv`.
Gate: no ledger row down (15 rows up, among them random1 at none 9 -> 16 and at -Xr 4 -> 13), the eight loc0 and stord rows added; pairs 223 MATCH; semcheck DIFFERENT 31 -> 59, the 28 new verdicts all out-of-range indexes that the model and the oracle extend differently (UB), reviewed in model/semcheck_review.tsv (the rows for the -O stord ones reach results/semcheck.md at the next run).

**Register temporaries under -O; more store shapes** (2026-11-10, afternoon, second batch): `plan_regtemps` now runs
under -O as well (`REGTEMP_OPT`), with the XIZ homes' direct forms there too (`XIZ_DIRECT_OPT`): loc0 reads 436 / 380
of 512 at -O3 -XS / -O3 -XS -Xr (132 / 147 before).  Two -O refinements came from the probe: under -O3 -XS -Xr a
temporary whose last read is the argument of the function's final call keeps WA and the code in between moves to BC
(`ld WA,(_gi) / ld BC,(_hj) / ld (_hi),BC / ld (_hi2),WA / j .vi`; `regtemp_keep_wa`), and a pointer plus a constant
into a home is one `lda XBC,XWA+0x1`; a byte computed in place is stored from its register (`add C,(_hc) /
ld (_hc2),C`, `STORE_FROM_WORK` for bytes).  A local initialised with a stack address stays folded (`_tan`'s
`p = (unsigned short *)&x`), which kept the 1997 library at 186.  Tried and turned off (`REGTEMP_OPT_SCRATCH`): the
-O source-into-a-scratch-register initialiser (`ld WA,(_hi) / ld BC,(_gi) / add BC,WA`, lo_i_Bgd) costs more loc0 -O3
-XS rows than it wins; what decides between it and `add BC,(_hi)` (lo_i_Bgs) is not understood.  The store rule gained
`p->arr[K]` and `p[K]` as members with a displacement (`ld XWA,(_gps) / ldw (XWA+0x14),0x64`; `cal / ld XWA,(_gpi) /
ld (XWA+0x6),HL`), a member array of a global struct as an element with a static base (`lda XBC,_gs + 0xe`), and a
sum whose operand reads through the stored pointer, computed first (`ld XWA,(_gps) / ld XBC,(_gla + 0x4) /
add XBC,(XWA+0x4) / ld XWA,(_gps) / ld (XWA+0x4),XBC`); `++` / `--` on a stack parameter is `incb 0x1,(XSP+0x16)`;
a char argument that is no plain operand is computed into A (`vc(gps->c)`: `ld XWA,(_gps) / ld A,(XWA) / exts WA /
push WA`).  The bisector (`stmt_bisect.py`, which now takes `-D` / `-I`) over the 1997 library at -O3 -XS names 42
functions refused whole, 6 of them at a `++` on a pointer parameter the oracle homes in XIZ (`strtoul`), 5 at an
element op-assign in a loop (`a[i] <<= y`), the rest one each; its tally is in the research-scratch README.  Over the
four random corpora at none: refused whole 490 -> 478, exact 38 -> 41.  The first gate of this batch found seven more wrong-code shapes, fixed before the second: store forwarding did
not end at `scc` (r1_04_12 -O3 -XS: `scc ne,WA / ld (XWA),A` through a stale copy of `gp`); a conditional return in a
function that returns with `retd` (r1_07_03 -Xr: `ret lt` left the double parameter's 8 bytes); a char index in
memory loaded as a word by the element lvalue (r2_05_07: `ld BC,(XSP+0xa)` of a char parameter; now the oracle's
zero-extended form `ld A,.. / ld XDE,0x0 / ld E,A / add XDE,XBC`); a char loaded through a pointer as a char array's
index sign-extended (`_atof`'s `_ctype[*str]`: `extz WA`); a member array of a global struct at an unsigned index,
which takes the low byte of the scaled offset plus the member offset (r2_03_08: `add A,0xe / lda XBC,_gs /
ld (XBC+A),HL`); the `(XBC+A)` byte store form kept to -Xr (r2_05_07 at none); a pointer plus a char index is no
register temporary (r3_03_11); and the stack-address local is folded under -O only (fpp11 q17 at none keeps it in WA).  Gate: no ledger row down (12 rows up: loc0 at -O3 -XS 132 -> 436 and at -O3 -XS -Xr 147 -> 380, six random rows), pairs 223 MATCH, semcheck DIFFERENT 59 -> 57 with no new verdict.

**The store rule under -O; the unsigned index's IZ home** (2026-11-10, afternoon, third batch): `store_plan` runs
under -O as well, outside a pointer run (`_fassign`'s and `_ungetc`'s cached stream pointer keep their register; a
first try without that exclusion cost them), with three -O variants from the probe: `p[i]`'s address is built in its
own register (`ld BC,(c) / exts XBC / add XBC,XBC / add XBC,(_gpi)`), a char member array's index is computed in the
index register's word (`ld DE,(c) / add DE,0x20 / ld XBC,(_gps)`), and the XIZ save for a long helper's store applies
too; an index already in WA (-Xr) keeps the -O0 forms.  stord reads 337 / 303 / 293 / 273 of 432 (337 / 202 / 293 /
171 before).  The -O refusal of an unsigned element index is lifted when the index's home is IZ / QIZ or memory,
which the oracle copies out first (r1_01_15 -O3 -XS: `ld WA,IZ / extz XWA / add XWA,XWA / ld XBC,_gua`).  Over the
four random corpora at -O3 -XS: refused whole 515 -> 484, exact 14 -> 15 (the bisector's -O tally: compares 53, long
helpers 46, stores 43 before this batch's store change).  Gate: no ledger row down (7 rows up: stord at -O3 -XS 202 -> 303 and at -O3 -XS -Xr 171 -> 273, random4 at three sets and random1 at -O3 -XS -Xr by one each); pairs 223 MATCH; semcheck DIFFERENT 57 -> 43: 22 of the -O stord index verdicts are gone, and the 8 new ones are 4 stord out-of-range indexes at -O3 -XS (UB, extended differently), r4_02_10 at the two -O sets (already reviewed as UB for every set) and r3_00_04 at the two -O sets, where cc900 hoists the call both branches begin with above the if's condition and the model keeps the C order; all in model/semcheck_review.tsv.

**The operands of long and char compares** (`corpus/probes/cmpordl.c`, 680 functions, run 2026-11-10-16; the rule is
`cmp_wide`, developed on a scratch copy while the previous gate ran: research-scratch
`sessions/2026-11-10_cc900-refusals/patch_cmpwide.py`).  The probe crosses 14 long operand kinds (constant, global,
static member, deref, constant element, element at c, !, -, difference, 256L - x, ?:, shift by c, member through a
pointer, call) and 12 char kinds on both sides of < and ==.  The table it gives is the one `cmp_order` gave for ints,
with the long and byte registers, plus three things ints did not show: == loads the right side when both operands are
memories or addressed and reverses the instruction's operands for a computed or call right; a ?: keeps the plain
branch form and takes the other side's address first; and two char-derived operands compare at the byte although C
promotes them (`-gc < hc`: `ld A,(_gc) / neg A / cp A,(_hc)`), except a !, which compares as a word.  The probe reads
674 / 152 / 546 / 152 of 680 at none / -O3 -XS / -Xr / -O3 -XS -Xr (158 / 148 / 158 / 148 before); the -O sets wait for
the rule to run under -O (553 of the oracle's 680 forms are the same there; the next commit), -Xr for the element and
shift kinds whose index is the parameter in WA.  Random corpora at none: refused whole 476 -> 472, exact 41 -> 42.
Gate: no ledger row down (random2 at none 5 -> 6, the four cmpordl rows added); pairs 223 MATCH; semcheck DIFFERENT 43 -> 55, the 12 new verdicts all cmpordl.c char negations at the two -O sets, where the model's -O path still negates the promoted word as C says and cc900 negates the byte (reviewed in model/semcheck_review.tsv; the -O rule of the next commit imitates it).

**The compare rule under -O** (`CMP_WIDE_OPT`, the same patch): 553 of the oracle's 680 forms are the same at -O3 -XS; the variants are the truth value straight into BC / DE, a negation or difference computed in its own register, `lda XWA,0x100` for the long constant, one index shared by two elements, the plain branch form of a ?: as a compare operand, and a char member's address straight into XBC.  cmpordl.c: 674 / 668 / 546 / 544 of 680.  Gate: no ledger row down (random2 at -O3 -XS 1 -> 2, cmpordl at -O3 -XS 152 -> 668 and at -O3 -XS -Xr 152 -> 546); pairs 223 MATCH; semcheck DIFFERENT 55 -> 43: the 12 cmpordl.c char-negation verdicts of the previous gate are gone, the model negating the byte as cc900 does under -O too.

**Binary operations with addressed operands** (`corpus/probes/evorder_ad.c`, 1,116 functions, run 2026-11-10-17; the rule is
`bin_wide`): the random corpora's commonest refusal after the compares, "the right operand overwrites the left".  The
right's address is taken first and the left loads; a left pointer's own load comes before it; a commutative operation of
two addressed sides loads the right and keeps the left as the memory operand; a call comes first and is the accumulator;
a multiply by a member through a pointer puts the pointer in XWA and the accumulator in BC; a divide extends the dividend
(a constant one not).  987 / 946 / 882 / 850 of 1,116 (590 / 580 / 508 / 498 before).  Two calls in a long operation
now keep the right result in XIZ: the call-pair planner had given them the 16-bit IZ, and the semantic check caught it.

**A guard for fitted tables** (`cw_pin` / `cw_guard`): both rules record each address and value register they form with the
line at which it became ready, and refuse an instruction that reads one after a later line wrote a register it is built
from; a register index is checked where it is read.  Its first runs found wrong code in pairs the probes never contained
(a generic operand computed over the other side's register, a member-array index in C overwritten by the other pointer,
a call over -Xr's index in WA).  The probes' semantic check now reads 0 verdicts at the four option sets, except one
out-of-range index (UB).  The random corpora also reached an older clash: a floating-point element hoist (`lda XIZ,...`)
over locals homed in IZ and QIZ (r3_08_05), now refused in `fpgen.hoist_elems`.

**The compare operands of the second wave** (`corpus/probes/cmpordl2.c`, 572 functions, run 2026-11-10-18): a pointer at a
constant index, a call with arguments, the widening casts (through A into BC for the right, XWA for the left; the zero
extension of a byte to a long as `ld XWA,0x0 / ld A,(_guc)`), a narrowing cast of a long to a byte, a member array
through a pointer (the index in a byte register: `ld E,A / cp WA,(XBC+E)`), and a generic computed operand.  Two findings
beyond the kinds: cc900 keeps an explicit widening cast as a conversion where an implicit promotion compares at the
narrower width (the frontend now marks `CStyleCastExpr`), and a local with an initialiser and no use is still computed
into WA (`int t = gi;` -> `ld WA,(_gi)`), which was the random corpora's "local t" refusal.  A local used once as an
element index stays a register temporary (`ld BC,(_gi) / add BC,BC / lda XDE,_hia`), and -Xr's index parameter in WA is
used the same way.  cmpordl2.c: 388 of 572 (17 before); cmpordl.c at -Xr 546 -> 586.  Random corpora at none: refused
whole 472 -> 451, exact 42 -> 43.  Gate: no ledger row down (21 rows up, the eight evorder_ad and cmpordl2 rows added; cmpordl at -Xr 546 -> 586, cmpord at -Xr 363 -> 405, evorder_st at -Xr 397 -> 420); pairs 223 MATCH (three _pow refusal reasons changed); semcheck DIFFERENT 43 -> 51, the 8 new verdicts all out-of-range indexes reviewed as UB in model/semcheck_review.tsv (cmpordl2 cc_l_YF / cc_e_YF, r2_05_11, r2_07_14).  The regression finder shows six functions newly inexact against 8b3c63aad (evorder_ad ea_i_div_DD, ea_i_rem_DD, ea_i_mul_KD; cmpordl -Xr cc_e_XG, cc_l_XE, cc_l_XG, cc_l_XM), fixed in the next commit (research-scratch fac6ec2).

**Chained stores, returned assignments, long helpers with a member operand** (2026-11-12, after the reboot; the rules are
reproducible from research-scratch `sessions/2026-11-10_cc900-refusals/patch_cmpwide.py`).  Two probes: `stchain.c`
(`L1 = (L2 = V)` for int and long, 392 functions, run 2026-11-12-1) and `stret.c` (`return L = V` for char, int and
long, and the char chains, 280 functions, run 2026-11-12-2).  `store_chain`: with a loaded or constant value the outer
address comes first, the inner one next, the value last, the registers handed out in the order WA, BC, DE, HL to an
outer member through a pointer, the inner address, an outer element, the value and an outer plain pointer; a computed
value stores the inner first and builds the outer address after it; a call comes first.  `ret_assign`: the address
first and the value straight into HL.  `sc_char`: chars through A or C, a char element built through XWA.  Also
`lh_member` (a long helper with an operand read through a pointer: the pointer in XIZ, saved at entry), any computed
char argument into A, the address of an element into XWA, and the six functions batch 14 had lost.  stchain 49 -> 321,
stret 28 -> 264, evorder_ad 987 -> 1010 at none.  Random corpora at none: refused whole 451 -> 417, exact 43 -> 51.
Gate: no ledger row down (15 rows up -- random1 at none 17 -> 20, random2 at none 6 -> 9, random3 at none 7 -> 9, evorder_lh at none 246 -> 272, evorder_ad at none 987 -> 1010, cmpordl at -Xr 586 -> 590 -- and the eight stchain and stret rows added); the regression finder shows no function newly inexact against 9aee92699; pairs 223 MATCH; semcheck DIFFERENT 51 -> 60, the 9 new verdicts all out-of-range indexes in stret.c chains at -O and -Xr that the older store path still takes (UB, reviewed in model/semcheck_review.tsv).

**Elements at a local index** (`corpus/probes/idxloc.c`, 108 functions, run 2026-11-12-3): an element indexed by a loop
counter, a local kept across a call (IZ) or a register temporary, in twelve statement shapes.  The compare and binary
rules now accept an operand that reads an IZ-family home, which they never write; a char element at a register index
uses the register as it is (`lda XWA,_gca / ld A,(XWA+IZ)`); an int element is pushed from memory (`pushw (XBC+WA)`)
and a pushed global-minus-element takes DE.  The probe also exposed a wrong-code fold the committed model had: `int t = gi;
gia[t] = ri();` read `gi` after the call; `call_before_use` now keeps such a local.  idxloc.c 57 -> 81 at none.
Gate: no ledger row down (5 rows up -- random3 and random4 at none by one each, cmpordl at -Xr 590 -> 594, evorder_ad at -Xr 905 -> 931, cmpordl2 at none 388 -> 394 -- and the four idxloc rows added); the regression finder shows no function newly inexact against cf6ad58b1; pairs 223 MATCH; semcheck DIFFERENT 60 -> 81: two older verdicts gone (r4_03_00 -Xr, r4_08_17), 23 new ones all idxloc.c char elements at t = gi, an index out of range (UB, reviewed in model/semcheck_review.tsv).

**Values read through an address** (`corpus/probes/stval.c`, 221 functions, run 2026-11-12-4): `return L = V` and
int chains `L1 = (L2 = V)` whose value is a deref, a member through a pointer, an element, a constant element or a
static member.  The store address and the value's address take registers in one fixed order (`sv_regs`: a member
with a displacement as the store first, a plain pointer store last); a chain's value lands in the first register
neither address needs.  `ret_assign` and the char chains are now on under -O (stret.c at -O3 -XS 28 -> 264): the
same code as none, except a pointer element built in its own register, constants stored with `ldb` on both sides
and values computed in the register they are stored from.  stval.c 75 -> 208 at none, 39 -> 206 at -O3 -XS.
Gate: no ledger row down (random1 at -O3 -XS and -O3 -XS -Xr 6 -> 7, random3 at -O3 -XS 3 -> 4, stret at -O3 -XS
28 -> 264, the four stval rows added); no function newly inexact against 29c5f148e; pairs 223 MATCH; semcheck
DIFFERENT 81 -> 78, none new.

**Division stores, -O and -Xr widening** (`corpus/probes/stdiv.c`, 750 functions, run 2026-11-12-5): `store_div`
models int and unsigned `L = A / B` and `L = A % B` (300 of 300 at none and -O3 -XS; a divisor in memory takes the
store address first, a divisor read through an address the division first).  Under -O an unused local's
side-effect-free initialiser is dropped and cmp_wide loads a byte straight into its register (cmpordl2 at -O3 -XS
59 -> 388).  Under -Xr the store rules ignore the register of a parameter the function never reads (stval / stret /
stchain at -Xr 33 / 31 / 49 -> 126 / 163 / 202).  **Wrong code fixed**, older than this series: under -Xr
`gi = gi + a` loaded `gi` into WA over the parameter `a` (gen_bin); the gate's semantic check found it in
random r2_05_16 at -O3 -XS -Xr once that function's unused local was dropped.  Long and char division are not modelled
(the long helper's frame-slot / XIZ form; char mixes 16/8 and 32/16 division).  Gate: no ledger row down (13 up, 4
stdiv rows added); no function newly inexact against 78e8ac600; pairs 223 MATCH; semcheck 78 -> 110, the 32 new
verdicts stdiv char indexes past the arrays (UB, reviewed).

**Long helpers with a call operand or two members** (`lh_call`, evorder_ad.c): what has to survive the other
operand's call -- a call's result, a member's pointer -- goes to XIZ, saved at entry, then to a 4-byte temporary
below the frame (`l_div_FD: dec 0x4,XSP / push XIZ / cal _gfl / ld (XSP+0x4),XHL / ld XIZ,(_hps)`).  One such
statement `G = A op B` per function, at none only.  evorder_ad 1010 -> 1039 at none.  Gate clean (semcheck 110, the
same verdicts).

**Elements as long helper operands** (`lh_elem`): the index is copied into a 2-byte frame temporary and scaled there,
the base goes to XIZ; with the order of plain long helper operands fixed too, evorder_ad reads 1080 of 1116 at none
(1039 before), stdiv 408 of 750, evorder_lh 284 of 507.  Gate clean (semcheck 110, the same verdicts).

**lh_call and lh_elem under -O**: the none forms, except that a call beside a global moves straight to its side and an
element beside a global reads the global last; two elements at one index share it under -O and are not planned.
evorder_ad at -O3 -XS 969 -> 1030, stdiv 340 -> 356.  Gate clean (semcheck 110, the same verdicts).

**Long helpers stored through an address** (`lh_store_post`, stdiv.c): with the right operand read through an address
the value is that of a global store and the store address is built after the call.  stdiv 408 -> 512 at none.  Gate
clean (semcheck 110, the same verdicts).

**Long helpers at a local index** (`corpus/probes/lhidx.c`, 150 functions, run 2026-11-12-6): a local index used once is
a register temporary copied straight into the index temporary, a constant divisor beside an element is read last,
constant-element stores are global stores.  lhidx 36 -> 78 at none.  The loop counter is still homed in IZ by the model
where the oracle keeps it in a frame slot.  Gate clean.

**Long divisions stored to an element** (`lh_store_x`, stdiv.c): two memory operands keep the scaled index in IZ and the
array's address in a 4-byte temporary; a constant beside one keeps the index in the 2-byte temporary and the base in XIZ.
stdiv 516 -> 528 at none.  Gate clean.

**Long stores with a pointer dividend; dereference before a constant**: the whole store address goes to XIZ first
(`lda XIZ,XWA+0x4`, `lda XIZ,XBC+WA`), and long_helper_order dereferences a left pointer before loading a right
constant.  stdiv 528 -> 556 at none.  Gate clean.

**The remaining long division stores** (stdiv.c): a left element beside a plain right saves the store address in a
4-byte temporary; a pointer-element store with a pointer dividend builds its address in XIZ; a constant over a
pointer's target loads the pointer first.  Every long row of stdiv is exact at none (612 of 750).  Gate clean.

**Char division stores** (`store_div_char`, stdiv.c): with explicit `(int)` casts a divisor in memory or a constant
dividend divides 16 / 8, a divisor read through an address or a constant beside a loaded dividend 32 / 16; with an
implicit promotion every divisor divides 16 / 8 (the older paths).  stdiv 750 of 750 at none.  Gate clean (semcheck
110 -> 106).

**Long helpers and the division stores under -O**: a constant is ld for 0..7 and lda above; long_helper_order loads
XWA's operand then XBC's after the pointers; the division store rules are on under -O; an older -O test no longer
crashes on the XIZ planners' marker.  stdiv 372 -> 628 at -O3 -XS, evorder_lh 150 -> 176, stord 312 -> 322, random2
2 -> 3.  Gate clean (semcheck 106 -> 102).

**Char division under -O**: the divisor straight into C / E, a constant dividend divided in BC beside an element
store.  stdiv 628 -> 694 at -O3 -XS.  Gate clean.

**A bare-declared loop counter** (`corpus/probes/loopctr.c`, 30 functions, run 2026-11-12-7): the oracle keeps it in the
lowest of BC, DE, HL the loop body does not write, also when calls come before the loop; the model's leaf allocator
does that only for for / while counters in leaf functions (not modelled further yet).  A constant-left char operation
now loads its memory operand first.  loopctr 8 -> 12 at none, random3 10 -> 11.  Gate clean.

**Bare-declared loop counters in registers** (loopctr.c): the leaf planner takes a do-while's counter, the do-while test
is dec 0x1,R / ld WA,R / cp WA,K, and a counter assigned right before its do-while / while is a register temporary also
when calls precede the loop.  loopctr 12 -> 22 at none.  Wrong code fixed on the way (found by the gate, not
committed): a broader register-temporary rule broke the library's _frexp; an older shift op= path overwrote its
computed count (r1_06_03).  Gate clean.

**For counters and counter registers**: a for's counter is a register temporary also when calls precede the loop, and a
counter takes the lowest of BC, DE, HL that the body's element accesses at [i] leave free.  loopctr 22 -> 29 at none,
random1 22 -> 23.  Gate clean.

**Loop-free locals assigned before use** are register temporaries like initialised locals (a local touched by a loop
stays with the older paths, after _frexp).  homes2a 16 -> 22, homes2b 7 -> 12 at none.  Gate clean.

**Batch 34 (2026-11-12): stores of a computed value read through an address.**  `corpus/probes/stvx.c` (run
2026-11-12-8, 135 functions) asks how cc900 orders a statement store's address and value when the value itself reads
through a pointer or an indexed element.  For int and long: `h - p->m` and a shift by a computed count are computed
first (pointer in XWA, value in BC, or DE before an element address); every other value comes after the address,
whose register depends on what the value needs.  The model now reads 93 / 93 / 41 / 41 of 135 at none / -O3 -XS / -Xr /
-O3 -XS -Xr (35 each before).  The probe also exposed wrong code in older -Xr paths (an element address overwriting
its own index in WA; a signed register index zero-extended on a char pointer; an address overwriting a register the
value reads) and one at none (`vs.p + b` zero-extending a negative b); all four are fixed, and semcheck DIFFERENT falls
from 102 to 74.  The random corpora do not move (57 of 800 at none): their stores index with char parameters and
promote char values implicitly, which `corpus/probes/stvxc.c` (run 2026-11-12-9) covers next.

**Batch 35 (2026-11-12): the same stores in the random corpora's forms.**  `corpus/probes/stvxc.c` (run 2026-11-12-9,
294 functions) repeats stvx.c with implicitly promoted char values and with char / unsigned char parameters as
indices.  Char values are computed in A in 8 bits with the same order rule; an int or long element at a char parameter
indexes through A (`ld A,(c) / add A,(c)` into `(XBC+A)`), at an unsigned char through `extz WA`, and a pointer element
through a 16-bit index register.  The model reads 251 / 250 / 82 / 84 of 294 at none / -O3 -XS / -Xr / -O3 -XS -Xr
(151 / 150 / 82 / 84 before).  The random corpora's three model crashes are gone (a double compare under a cast is now
written; the other shapes refuse), and two older wrong-code paths the probe reached now refuse.  The random corpora
still read 57 of 800 at none: each function there has several statements and locals, and what blocks most of them now
is where locals live (frame slots against XIZ / QIZ, 60-odd first differences in the prologue) and the long-helper
operands (73 refused statements), not the store shapes.

**Batch 36 (2026-11-12): memory operands through a plain pointer.**  Grouping the random corpora's first differences
showed two small rules: a constant compare of a value read through a plain pointer compares the memory
(`cpw (XWA+0x8),0x0`), and an int argument read through one is pushed from memory (`pushw (XWA+0x2)`).  The random
corpora read 62 of 800 at none (57 before) and 20 at -O3 -XS (19).  The same survey (`frames.py`) counts 99 functions
whose frame size or saved register differs; two thirds call FP helpers, and the largest groups are a double compound
assignment's target address hoisted into XIZ and the number of double temporaries.  `corpus/probes/fpopa.c`
(run 2026-11-12-10) asks about the first.

**Batch 37 (2026-11-12): double compound assignments.**  `corpus/probes/fpopa.c` (run 2026-11-12-10, 112 functions):
unless the target is a plain global, cc900 saves XIZ in the prologue, loads the target's address into it at the
statement and passes it as both the left operand and the result (`lda XDE,_hd / ld XBC,XIZ / ld XWA,XIZ`).  The model
reads 100 / 82 / 100 / 82 of 112 at none / -O3 -XS / -Xr / -O3 -XS -Xr (20 / 16 / 20 / 16 before); an older path that
built a computed element's address two or three times over its own index (wrong code under -Xr and -O3 -XS) now
refuses what the rule does not cover.  The random corpora read 63 of 800 at none and 21 at -O3 -XS.

**Batch 38 (2026-11-12): four small rules.**  From the random corpora's first differences and
`corpus/probes/fpargf.c` (run 2026-11-12-11): without -O an inner `if` that ends where the enclosing `if` ends shares
its join label (only `if` joins merge; a switch's table base and first case, a break and a continue label stay two);
`g += k` for k in 1..8 on an int global is `incw k,(_g)`; `return g + k` on a global pointer is `ld XWA,(_g) /
lda XHL,XWA+k`; a double helper's constant-element right operand is addressed before a plain left one.  The random
corpora read 69 / 22 / 47 / 21 of 800 at none / -O3 -XS / -Xr / -O3 -XS -Xr (63 / 21 / 46 / 20 before).  The same probe and
`corpus/probes/fpargg.c` (run 2026-11-12-12) show that a function containing a `switch` anywhere gets a double-temporary
region half the usual size; that rule is next.

**Batch 39 (2026-11-12): the double-temporary region beside a switch; pending pops.**  `corpus/probes/fpargg.c` (run
2026-11-12-12) varies the construct around one double temporary: only a `switch` changes the frame, on either side of
the statement, and (random r4_03_19) only on an int-sized value -- such a function has the region D alone, 8 bytes
with the temporary at XSP, instead of D + D'.  Without -O the pops left by an earlier call statement also stay
pending through the helper calls of a bare call statement.  `fpargf.c` reads 96 / 48 / 24 / 24 of 96 (48 / 32 / 20 / 20
before), `fpargg.c` 36 / 32 / 36 / 32 of 44; fpp1, fpp3, fpp4 and fpp5 rise at none (31 -> 32, 46 -> 48, 51 -> 55, 86 -> 91)
and the random corpora read 70 of 800 at none.  The first gate of this batch showed one row down (fpp8.c at none,
46 -> 44: an assignment from a call must release the pops first); the rule was narrowed and the gate re-run.

**Batch 40 (2026-11-12): double constants folded; the whole long under a narrowing cast.**  A double + - * / of two
constants is one constant (`vd(3.0 + 2.5)` pushes 5.5), and without -O an explicit cast of a long in memory to an int
or char loads the 32 bits (`(int)gul * 8` -> `ld XWA,(_gul) / sla 0x3,WA`).  The random corpora read 72 of 800 at none
(random4 15 -> 17); opt_loops.c 27 -> 28 at none.  A third rule tried with them -- "a statement without a double binary
operation uses the temporary region D alone", from `vd(-gda[0])` in 8 bytes -- was wrong: the first gate showed the
fpp probes at none collapse (fpp4.c 55 -> 0), and the regression finder, whose list covers 103 of the ledger's 247
rows, had shown nothing.  It is switched off (`FP_UNARY_HALF`), and research-scratch `gate/ledger-copy.sh` now runs the
whole ledger on the scratch copy before a batch reaches the tree.

**Batch 41 (2026-11-12): an IZ home initialised through a pointer; a member store of a displaced dividend.**  Without -O
the initialiser of an int local homed in IZ that reads through a plain pointer is computed in IZ
(`ld XWA,(_gps) / ld IZ,(XWA+0xe) / add IZ,(_gi2)`), and `store_div` now takes `gps->i = gps->i / gi3` and
`gps->i = gpi[3] % gi` (the pointer in XWA, the division in XBC).  The random corpora read 73 of 800 at none.  This
batch was checked with the whole ledger on the scratch copy before it reached the tree.

**Batch 42 (2026-11-12): pops that wait for a later call; an unsigned long remainder by 2^n.**  Without -O the stack
arguments of `g = call(..)` and of earlier calls are not released while a later call statement with arguments follows
in the block and nothing in between touches the frame; they merge into that call's cleanup (`cal _rl / ld (_gl2),XHL /
.. / cal _v1 / inc 0x6,XSP`).  With no such call they are released at once, as before.  An unsigned long `%= 2^n` on a
global is `ld XWA,2^n - 1 / and (_g),XWA`.  The random corpora read 77 of 800 at none (73 before).

**Batch 43 (2026-11-12): long helpers in the random corpora.**  A constant element is a plain operand of a long * / %
in a planned store (`*gpl = gla[4] / 7L` keeps the address in XIZ); a long helper stored through `p->m` or `p[k]` that
the planner does not take loads its address after the call; a member dividend takes a constant divisor
(`ld XIZ,(_gps) / ld XWA,(XIZ+0x4) / ld XBC,0x7`).  The random corpora read 78 of 800 at none; evorder_lh.c 286 -> 288
at none and 239 -> 241 at -Xr.  The top refusal there, long helpers with an element at a variable index (about 40
statements), needs cc900's frame-slot form (the scaled index and the store address saved in slots, the base in XIZ).

**Batch 44 (2026-11-12): the loop-counter rows of lhidx.c.**  Without -O a loop counter that indexes an element
operand of a long * / % helper stays in its frame slot (`ldw (XSP+0x4),0x0 / cpw (XSP+0x4),0x4 / j ge / .. /
incw 0x1,(XSP+0x4)`), and the loop body is the parameter-index form the model already wrote.  Such counters are marked
before planning, kept out of the register planners, and given a provisional slot while the long-helper planner (which
runs before the frame is laid out) classifies its operands.  `lhidx.c` at none reads 122 of 150 (78 before); what is
left there is the multiply stored through an address and two local-index shapes.  The random corpora stay at 78: six
of their refusals became differences.

**Batch 45 (2026-11-12): a dead store of a call result.**  Without -O a top-level `t = call(..);` into a local that
nothing reads afterwards is only the call, and a long * / % helper's result is a register temporary in XHL like a
call's.  The random corpora read 79 of 800 at none.  A second rule tried with it -- a loop counter live across a long
helper homed in IZ, as across a call -- is in the tree switched off (`HELPER_IS_CALL`): the oracle keeps the counter in
its slot when the helper's operand needs XIZ, and the model's operand order changes once IZ is saved.

**Batch 46 (2026-11-12): a loop counter across a long helper.**  Without -O a loop counter that is live across a long
* / % helper whose operands are plain (a constant, a global, a static member, a constant element) is homed in IZ, as
across a call; when the helper's operand needs XIZ the counter stays in its slot.  The helper then loads XWA first
unless an operand is a register or a long local is homed in XIZ.  The random corpora read 83 of 800 at none (79
before).  The whole-ledger check on the scratch copy caught this batch's first form before it reached the tree: it
took six micro functions (`mul_l_loc` and its five siblings) out of exactness at none.

**Batch 47 (2026-11-13): the order of a double operation's addresses.**  `corpus/probes/fpord.c` (run
2026-11-12-13-micro-fpord, 288 functions; `-Xr` rejects its double-returning functions, so only two sets have
listings) asks in which order cc900 addresses the operands and the destination of a double `+`, `-`, `*` of two plain
operands.  Without options (`FP_ORD`, `fo_plain` in `fpgen.py`): `+` and `*` swap their operands when the left is a
constant or both are a static member / constant element; members and elements are addressed first, in source order,
then the others, XBC before XDE; a plain destination (a global, a local) comes last, a member / element destination
first, and beside two such operands or such a right operand of `-` or `/` the result goes through a temporary and
`._fld_dd`.  Element 0 of a global array is written without `+ 0x0`.  fpord.c 64 -> 288 of 288 without options and
64 -> 96 at -O3 -XS (the rule is not applied there: -O's order differs and is not modelled).  Random programs at none
83 -> 88 of 800 (the other three sets stay at 22 / 47 / 21).  The same batch makes the second-attempt copies of a
function pickles instead of `copy.deepcopy` trees (identical ledger).  Tooling since batch 46: the rounds share one
compile through `model/cache.py` (`CC900_CACHE`; README "One compile per round"), and the dashboard counts the rounds
and their mean time.

**Batch 48 (2026-11-13): stores of a division, more operand kinds.**  `corpus/probes/stdiv2.c` (run
2026-11-13-1-micro-stdiv2, 1,020 functions) repeats stdiv.c's `L = A / B`, `L = A % B` with the operands the random
corpora use and stdiv.c lacked: the stored-to object itself, a member through a pointer, a static member, a constant
element, a parameter.  Found (`SD_MORE`): a static member or constant element divisor behaves like one read through an
address -- the division first, then the store address; a displaced divisor's pointer takes XWA and the division runs
in XBC; `*p = *p / k` reads through the store address; an element on both sides loads its index once (into WA beside a
plain divisor, held in HL or DE when the division comes first); -O builds the object's address once in XBC (XDE beside
a displaced divisor) and reads and writes through it; implicitly promoted chars divide 16 / 8 whatever the divisor
(`store_div_char2`); a long helper with a member / element divisor stores after the call and keeps no address in XIZ.
stdiv2.c 566 / 404 / 409 / 275 -> 898 / 820 / 409 / 275 of 1,020 at none / -O3 -XS / -Xr / -O3 -XS -Xr; the misses
left without -Xr are the unsigned long rows that keep an address in XIZ or a temporary across the helper.  Random
programs at none 88 -> 90 of 800.  The gate for this batch took 1 min 19 s with the shared compile cache.

**Batch 49 (2026-11-13): what a long division store keeps across its helper call.**  The 122 unsigned long rows of
`stdiv2.c` that batch 48 left out follow one table (`sd4_need`, `plan_sd4`, `sd4_store`; without -O, cdecl).  A plain
divisor (a global, a parameter, a constant) lets the store address be built before the call: kept in XIZ for a pointer
or a member through one; for an element, the scaled index in a 2-byte temporary with the base in XIZ, or the scaled
index in IZ with the base in a 4-byte temporary beside a plain dividend.  A dividend read through a displaced pointer
takes XIZ for that pointer and sends the store address to a 4-byte temporary.  Any other divisor (a static member, a
constant element, one read through an address, the stored-to object) puts the call first and the store address after
it, with XIZ holding a displaced operand's pointer or an element operand's base.  The divisor's memory is loaded
before a dividend that is not a plain variable.  stdiv2.c at none 898 -> 1,020 of 1,020; the other sets and the random
corpora are unchanged (the random functions' long divisions use char, unsigned or local indices, or sit beside a
second helper or a loop, which the plan does not claim).  A first form loaded the divisor first beside a plain
global dividend too and lost stdiv.c 12 and stord.c 10; the scratch copy's ledger caught it.

**Batch 50 (2026-11-13): three probes written by tabulation agents, and the wrong code they exposed.**  From this
batch on a cheaper model (Sonnet sub-agents) does the tabulation and this one the rules: an agent takes one refusal
reason, classifies the random corpora's refused statements and writes a probe generator
(`research-scratch/.../tabulation-BRIEF.md`, the three reports beside it); after the oracle run a second agent
describes the oracle's forms as a standalone `predict.py` that is checked against every listing.  The three probes --
`lhx.c` (long helpers: char / unsigned indices, more destinations, two helpers; 1,184 functions), `elrd.c` (an element
read beside a left value, an assignment to an element used as a value; 1,234) and `cmpx.c` (compare operands; 1,192)
-- start at 416 / 269 / 464 exact at none.  The agents' predictors already reproduce all 1,184 of lhx.c's forms at
none; porting them is the next batch.

The same probes made the semantic check go from 73 to 321 DIFFERENT, all in older paths, now fixed or refused (back to
73, the same verdicts):
- **struct layout**: an array member starts at an even offset, a char array too (`struct { char c; char ca[8];
  unsigned char u; unsigned char ua[8]; int i; }`: `ca` at +2, `u` at +0xa, `i` at +0x14; the front end had 1, 9,
  0x12).  About 190 of the verdicts.  clang's `-mabi=cc900` layout has to do the same: a point for phase 3b;
- a widened value left outside the register being extended (`(hca[x] = 2) == gi`: the extension read A, the value was
  in C) is refused;
- an unsigned int extended to a long for a compare was loaded as a byte; it is `ld WA,(_hu)` / `extz XWA`;
- a char element at an unsigned index held in a register used `(XBC+WA)`, which reads the index signed; a load now
  extends it whole (`extz XWA` / `ld XBC,_hca` / `add XBC,XWA`), the other uses are refused;
- `gps->l = vla[2] * 7` built the product in the register of its operand (16 times instead of 7): refused.

**Batch 51 (2026-11-13): long helpers with address operands, ported from an agent's predictor.**  `lx5_lines` is the
tabulation agent's `lhx2-predict.py` (840 of 840 oracle forms reproduced) rewritten over the model's operand kinds:
a long `/`, `%` or `*` whose operands are `*p`, `p->m`, a static member / constant element or an element at an int
parameter, used as a store (to a global, `*p`, `p->m`, an element), a returned value, a call argument or a condition.
A goes to XWA and B to XBC (`*` exchanges them beside a pointer, member or element B); a displaced operand's pointer
takes XIZ, an element operand keeps its scaled index in a 2-byte temporary and its base in XIZ; a plain divisor lets
the store address be built first and kept in XIZ or a 4-byte temporary, any other rebuilds it after the call.  A long
times 2^n - 1 is a shift and a subtraction.  lhx.c at none 416 -> 790 of 1,184; evorder_lh.c 288 -> 319, evorder_ad.c
+2 at each set, stord.c +1.  Random programs unchanged (90 of 800 at none).  The port took about 40 minutes from the
agent's report to the commit; the agent's own run took 5.

**Batch 52 (2026-11-13): long helpers with a char or unsigned parameter index.**  `lx6_lines`, from the agent's
`lhx1-predict.py`: an element at a char or unsigned char parameter has its scaled index in the 2-byte temporary (a
byte for char, the 16-bit form after `extz WA` for unsigned char) and its array's base in XIZ; at an unsigned int
parameter the index is extended whole and added to the base, with no temporary.  `ga[i] = ga[i] op vv`, and
`ga[i] = vv * wa[i]`, build the store address first and keep it.  lhx.c at none 790 -> 862 of 1,184.  The local and
loop-counter indices of the same rows are not reached: the register planner gives such a local a register before
this plan runs.  By now the agents' predictors reproduce every oracle form at none of lhx.c (1,184), of cmpx.c's cx
and cc families (744) and of elrd.c's er and bc families (1,234); what limits the rate is porting them.

**Batch 53 (2026-11-13): near misses.**  `nearmiss.py` (research-scratch) counts, for the random functions the model
writes but gets wrong, how many lines separate it from the oracle: of 301 at none, 14 were one line off, 45 within
two, 82 within three, 113 within four.  Four one-line causes fixed: an OR with a one-bit constant is `set` (in a
register, `set 0x3,WA` for `gul | 8`, `set 0x0,QWA` from bit 16 up; in a byte of memory, `set 0x0,(_guc)`; no oracle
listing has `or R,<one bit>`); a lone `if` inside the function's last `if` returns early too (`ret lt` / .. /
`ret eq`); a constant under a narrowing cast is loaded at the narrow width (`char f() { return 53; }` ->
`ld L,0x35`); an unsigned char times a power of two in a compound assignment is `sll`.  Random programs
90 / 22 / 47 / 21 -> 95 / 22 / 49 / 22 of 800.  A tabulation agent is classifying the functions within four lines by
cause.

**Batch 54 (2026-11-13): three more near misses.**  Element 0 of a global array as a long helper's right operand is
read through its address (`gul % gula[0]` -> `lda XBC,_gula` / `ld XWA,(_gul)` / `ld XBC,(XBC)`; any other constant
element is a plain memory operand); a char remainder goes through A into a member or element (`gca[2] = 0 % gc2` ->
`ld A,W` / `ld (_gca + 0x2),A`) and straight from W only into a plain variable; a truth value that initialises a
register temporary is made in WA and moved (`int t = !(..)` -> `scc eq,WA` / `ld DE,WA`; 114 `scc cc,WA` / `ld BC,WA`
pairs in the oracle's listings at none).  Random programs at none 95 -> 99 of 800.

**Batch 55 (2026-11-13): four more near misses.**  `x |= 0` with a folded zero is no code; a static member's char
pointer plus a char index, as a call argument, loads the pointer first (`vp(gs.p + a)` -> `ld XBC,(_gs + 0xa)` /
`ld XWA,0x0` / `ld A,(a)` / `add XWA,XBC`); an explicitly sign-cast long register temporary is copied before it is
pushed (`vl((long)t)` -> `ld XWA,XDE` / `push XWA`); a register temporary stored through a pointer takes XWA for the
pointer (`gps->l = t` -> `ld XWA,(_gps)` / `ld (XWA+0x4),XDE`).  Random programs at none 99 -> 103 of 800, at -Xr
49 -> 50.

**Batch 56 (2026-11-13): two more near misses.**  A byte global stored from a register and bumped by the next
statement is bumped in the register first (`gc = gc2; gc++` -> `ld A,(_gc2)` / `inc 0x1,A` / `ld (_gc),A`);
`g = g + e` with a computed `e` adds into memory (`gpi = gpi + t` -> `add (_gpi),XWA`; the oracle's listings at none
have 143 `add (m),XWA` against 3 `add XWA,(m)` / `ld (m),XWA`, which come from a folded local and a chained
assignment).  Random programs at none 103 -> 106 of 800.

**Batch 57 (2026-11-13): three more near misses.**  `!x` of a char value computed in a byte is tested as a byte
(`return !(gc - 5)` -> `ld A,(_gc)` / `dec 0x5,A` / `cp A,0x0`); an unsigned int divided by a power of two in a
compound assignment is a shift (`gu2 /= 16` -> `srl 0x4,WA`); a constant element or static member `op=` a call takes
the result from XHL (`gula[4] += rul(gul)` -> `cal _rul` / `add (_gula + 0x10),XHL`).  Random programs at none
106 -> 110 of 800.

**Batch 58 (2026-11-13): three more near misses.**  A register is compared with `cp`, never `cpb` / `cpw`
(`cp QIZH,0x26`); `p[k]` with `p` a register temporary reads through that register (`t[1]`, t in XDE ->
`ld A,(XDE+0x1)`); an XIZ pointer home initialised with the address of an element or member is built in XWA
(`char *t = &gca[6]` -> `lda XWA,_gca + 0x6` / `ld XIZ,XWA`).  Random programs at none 110 -> 112 of 800.

**Batch 59 (2026-11-13): three patterns among the three-line near misses.**  A byte shifted by a constant in a
compound assignment works in A (`guc >>= 3` -> `ld A,(_guc)` / `srl 0x3,A` / `ld (_guc),A`; the model used C); a
static int element or member multiplied or divided in a compound assignment goes through its address
(`gua[6] %= 3` -> `lda XBC,_gua + 0xc` / `ld WA,(XBC)` / .. / `ld (XBC),WA`; a plain global stays direct);
`g = K op g` on a long global loads the constant and operates in memory (`gl = -1916L ^ gl` ->
`ld XWA,0xfffff884` / `xor (_gl),XWA`).  Random programs at none 112 -> 119 of 800.

**Batch 60 (2026-11-13): two more patterns.**  Two computed byte operands whose leaves need no address register are
evaluated right first: the right one in A, moved to C, then the left one in A (`guc = (7 + guc) ^ (guc & 162)` ->
`ld A,(_guc)` / `and A,0xa2` / `ld C,A` / `ld A,(_guc)` / `inc 0x7,A` / `xor A,C`); an IZ home's value that is loaded
through an address and then worked on is loaded into IZ, not through WA (`int u = gps->a[b] + gi3` ->
`ld IZ,(XWA+C)` / `add IZ,(_gi3)`; `c[3] << 5` -> `ld IZ,(XWA+0x6)` / `sla 0x5,IZ`).  Random programs at none
119 -> 123 of 800.

**Batch 61 (2026-11-13).**  A `?:` that initialises a register temporary is computed in WA / XWA in both arms and
moved after the join (`unsigned long t = c ? gula[c] : ..` -> `ld XWA,(XBC+WA)` twice, then `ld XDE,XWA`); an
unsigned value divided by a power of two in an expression is a shift, as in a compound assignment
(`vu(gu / 16)` -> `srl 0x4,WA`).  Random programs at none 123 -> 125 of 800.

**Batch 62 (2026-11-13): one exit.**  Without -O too, an early `return` in a function that has an epilogue (a saved
register, a frame) jumps to one exit label in front of the epilogue instead of repeating it (`lda XHL,_gia + 0xc` /
`j L50000` .. `L50000:` / `pop XIZ` / `ret`); the model did this only under -O and in functions with double
temporaries.  Random programs at none 125 -> 128 of 800; ra_libshapes.c at none 12 -> 13 of 21.

**Batch 63 (2026-11-13).**  The evaluation-order rule of evorder.c now also covers `& | ^ +` of two addressed byte
operands (`gca[6] ^ *gp` -> `ld XWA,(_gp)` / `ld L,(XWA)` / `xor L,(_gca + 0x6)`: the right one is the
accumulator); a byte element at a loop counter held in IZ, beside a constant, takes XWA for its base
(`guca[i] + 7` -> `lda XWA,_guca` / `ld A,(XWA+IZ)` / `inc 0x7,A`).  Random programs at none 128 -> 130 of 800.

**Batch 64 (2026-11-13): the order of a double operation's addresses, four more cases.**  `gd2 *= gs.d` follows
batch 47's rule (the member first, in XDE, then `lda XBC,_gd2` / `lda XWA,_gd2`); a constant on the left of `==` /
`!=` becomes the right operand (`100.0 == gd` -> `lda XWA,_gd` / `lda XBC,S1`); a member / element destination is
addressed first in a copy and in a negation too (`gda[1] = gda[2]` -> `lda XWA,_gda + 0x8` / `lda XBC,_gda + 0x10`).
Random programs at none 130 -> 134 of 800.

**Batch 65 (2026-11-13).**  A chained store whose inner target is a static element or member needs no address
register, so its value stays in WA (`gc = gca[7] = -gc` -> `ld A,(_gc)` / `neg A` / `ld (_gca + 0x7),A` /
`ld (_gc),A`; the model used C / XBC); a byte or word shifted by one in place is shifted in memory
(`a->c <<= 1` -> `ld XWA,(XSP+0x4)` / `slab (XWA)`); an IZ home's `*p - 7` uses `dec 0x7,IZ`.  Random programs at
none 134 -> 140 of 800; stchain.c at none 321 -> 323 of 392.

**Batch 66 (2026-11-13).**  `!p[k]` and `!*p` compare the memory (`!gpi[1]` -> `ld XWA,(_gpi)` /
`cpw (XWA+0x2),0x0`); `p->m = a op b` with plain operands takes XWA for the pointer and computes the value in BC
(`gps->l = gs.l - gl2` -> `ld XWA,(_gps)` / `ld XBC,(_gs + 0x4)` / `sub XBC,(_gl2)` / `ld (XWA+0x4),XBC`); a compound
shift by a constant works in WA at every size, not only bytes.  Random programs at none 140 -> 143 of 800.

**Batch 67 (2026-11-13): compares against an indexed element.**  `cmpx_elem`, from the agent's `cmpx1-predict.py`:
a plain left operand (a global, a parameter, a static member or constant element) compared with an element at a char,
unsigned char, int or unsigned int index held in a parameter or a global.  The index and the base are built first
(registers by a table over index type and element size), then the left operand is loaded and compared with the
element; `==` / `!=` against a static member or element load the element instead.  cmpx.c at none 464 -> 553 of
1,192.  The random corpora's 28 "complex compare operand" refusals are mostly other shapes (casts, computed operands,
elements on both sides) and stay.

**Batch 68 (2026-11-13): thirteen of the day's cdecl rules also hold under -Xr.**  `nearmiss.py --set Xr` showed
functions one line off at -Xr for rules that had been made cdecl-only; `lift_adecl.py` (research-scratch) then
removed the `not F.adecl` guard of each rule in turn and scored the random corpora at -Xr.  Thirteen gain and are
lifted: narrow constants, a byte bumped before its store, a member / element destination first in a double copy, a
char truth test in a byte, `p[k]` through a register, an XIZ home's address through XWA, a static element multiplied
through its address, constant shifts in WA, the one exit, a chained store's value in WA, `!p[k]`, element 0 through
its address, a char remainder through A.  Random programs at -Xr 50 -> 70 of 800 (none 143, -O3 -XS 22, -O3 -XS -Xr
22 unchanged); stdiv2.c at -Xr 409 -> 426 and at -O3 -XS -Xr 275 -> 288; stchain.c and stval.c at -Xr +4 and +3.
The rules that did not gain at -Xr stay cdecl-only.

**Batch 69 (2026-11-13): the optimised sets.**  `lift_guard.py` repeated batch 68's sweep for the `not F.opt` guards
at -O3 -XS: four rules gain there and are lifted (narrow constants, a member pointer loaded first, a byte bumped
before its store, byte shifts in A).  And one rule for every 32-bit register constant, applied where instructions are
emitted: under -O a constant from 8 to 0xffff is `lda` and any other `ld`; without -O it is always `ld` (the
oracle's listings: 509 `lda` and 1,473 `ld` at -O3 -XS, 1,988 `ld` at none, no exception).  The model had this in a
few places only.  Random programs at -O3 -XS 22 -> 29 and at -O3 -XS -Xr 22 -> 25 of 800; evorder_l.c 191 -> 233 and
148 -> 182, evorder_lh.c 176 -> 224 and 159 -> 204, stdiv.c 694 -> 698 and 142 -> 166 at those two sets: twelve
ledger rows up by 207 functions.

**Batch 70 (2026-11-13): forms the oracle never writes.**  `never_forms.py` (research-scratch) lists the instruction
forms the model emits at a set that no oracle listing of that set contains.  Two were rules, applied where
instructions are emitted: QIZ is never loaded from memory, the value goes through WA (`ld WA,(_x)` / `ld QIZ,WA`,
when WA is free); and `ld R,R` is not written (left alone right after a call, where the later passes drop it and
decide between `cal` / `j` and a tail jump: switch.c sw_local).  homes2a.c 22 / 9 / 36 / 32 -> 23 / 37 / 40 / 34 of
204 and homes2b.c 12 / 9 / 19 / 16 -> 14 / 10 / 22 / 17 of 90 at none / -O3 -XS / -Xr / -O3 -XS -Xr: eight ledger
rows up by 42 functions.  The random programs do not move (143 / 29 / 70 / 25 of 800).

**Batch 71 (2026-11-13): near misses again.**  Three rules from random functions one or two lines off.  (1) `add R,k`
with k from 1 to 8 is `inc k,R` (no oracle listing adds 1..8 to a register except once before a `j ne`; 1,335 `inc`
at none).  (2) The lazy stack clean-up of batch 31 (the pops of a call wait for a later call's clean-up, cdecl without
-O) holds in more shapes: after a static element or member takes the call's value (`gca[1] = rc(gs.i)`), after
`G op= call()` on a global (`gu &= ru(32767)`), across a double copied between statics (it uses no frame temporary),
and when the absorbing call is the `return`'s (`return rul(gula[0] >> 4)` -> one `inc 0x8,XSP`).  (3) An explicit
`(char)` cast of an int in memory, passed as a char argument, reads the word (`vc((char)gu)` -> `ld WA,(_gu)` /
`exts WA`; an implicit conversion reads the byte).  Random programs at none 143 -> 147 of 800 (the other sets
unchanged: 29 / 70 / 25); cmpordl2.c at -O3 -XS -Xr 349 -> 351.

**Batch 72 (2026-11-13): four more near misses.**  A register is not reloaded right after it was stored: `ld Y,X`
directly after `ld X,Y` is not written (no such pair in the cdecl listings; the -Xr listings do have them, so the
rule is cdecl-only: without that limit the micro corpus lost 4 and 19 functions at the two -Xr sets, which the scratch
ledger caught).  An unsigned int `% 2^k` is `and R,2^k-1`.  `*gp op= K` for `&`, `|`, `^` on an int through a global
pointer is `ld XWA,(_gp)` / `xorw (XWA),K`.  A char variable in QIZH / QIZL compares with a constant in place
(`cp QIZH,0x0`; five in the oracle's listings, never through A).  Random programs at none 147 -> 151 of 800
(29 / 70 / 25 at the other sets, unchanged).

**Batch 73 (2026-11-13): probe stdiv3.c, and the wrong code it exposed.**  The largest remaining refusal family in the
random programs is the generator's guarded division by an element at a variable index (`if (gua[t] != 0) gps->u =
gua[4] / gua[t]`, about 13 functions under "the right operand overwrites the left").  `corpus/probes/stdiv3.c`
(`gen_stdiv3.py`, run 2026-11-13-5-micro-stdiv3, 1,200 functions) asks about it: int, unsigned int and promoted char;
the index an int or unsigned parameter, a char local kept across a call (QIZH) or not, or a loop counter.  The model
had 234 / 186 / 76 / 80 at none / -O3 -XS / -Xr / -O3 -XS -Xr, almost all of it the int-parameter rows.  semcheck
found 60 new wrong-code verdicts in what the model already wrote for the probe, all fixed or refused: a char element
read or stored at a char local in QIZH went through the zero-extending sum of a char in memory, where the compiler
indexes with the register, signed (`lda XWA,_hca` / `ld A,(XWA+QIZH)`; `ld (XBC+QIZH),A`: now written so, in
`chidx.py` and `lvalue`); under -O the char division's sums zero-extended an int index that two arrays share, where
-O keeps it in a register (`(XBC+DE)`: refused); and -O's `(XWA+DE)` char form at an unsigned index (refused).
stdiv3.c now 254 / 206 / 88 / 92; semcheck back to 73, the same verdicts.  Two Sonnet sub-agents tabulated the probe at
none: their predictors reproduce 800 of 800 int / unsigned rows and 400 of 400 char rows from the name alone
(research-scratch `tabulation/stdiv3a-*`, `stdiv3c-*`); porting them is the next batch.

**Batch 74 (2026-11-13): the stdiv3 predictors ported (`model/sd3.py`); a constant-folding quirk (probe negk.c).**
`model/sd3.py` is the two sub-agents' predictors turned into a statement rule: `L = A / B` and `L = A % B` with an
element at a variable index, cdecl without -O, taking the real operands and the index variable's actual home.  The
statement is a fixed sequence of steps over temporaries (index copy, offsets, bases, pointers, dividend, quotient);
each takes the lowest register no overlapping, already coloured temporary holds, in a fixed colouring order.  The
temporaries are coloured without regard to the index variable's home, as the compiler colours variables last; a
temporary that lands on a live home raises, and for a register temporary the function's allocator then tries its next
candidate (reserving the home instead moved a loop counter from HL to DE in r4_00_08).  stdiv3.c at none 254 -> 878 of
1,200; the 322 left are almost all rows where the model's allocator gives the char local or the loop counter another
home than the compiler's lowest free one (`ld L,(_jc)` for `ld C,(_jc)`).  The random programs do not gain yet (151 of
800 at none): their divisions by an element mix what the probe kept apart: a char parameter as the index, two
different indices, a member array through a pointer, an explicit cast of a long as the dividend, other variables in
registers.  Three random functions are no longer refused but differ elsewhere.
One of them, r2_08_12, returned 0xfed9 for `return -40 - 255` where the compiler returns 0xffd9.  `corpus/probes/
negk.c` (run 2026-11-13-6-micro-negk, 38 functions) shows the rule: a negated literal in -127..-1 (`-K`, `~K`) folded
against a literal in 128..255 is taken as its unsigned byte, so `-40 - 255` is 216 - 255, `-40 * 255` is 0xd728,
`255 - -40` is 0x27, and the result is unsigned (`gl = -40 - 255` loads 0x0000ffd9); `-40 - 256`, `-128 - 255`,
`-40 + -255`, `40 - 255` and the long forms fold as C does.  It joins the model's rule that V4.23 types a constant in
128..255 as an unsigned char.  negk.c 19 -> 38 of 38 at each of the four sets.

**Batch 75 (2026-11-13): four more near misses.**  An explicit `(char)` of an int read through an address reads the
word, as one in plain memory does (`vc((char)gps->u)` -> `ld XWA,(_gps)` / `ld WA,(XWA+0x8)` / `exts WA`).  The pops
pending from a call come before a loop counter's initial load when the loop follows (`vc(..); i = 0; while (..)` ->
`inc 0x2,XSP` / `ld DE,0x0`; before a later call statement they still wait).  The last `if` of the last `if`'s block
returns early like a lone inner `if` does, and its join label stays (`ret ne` / .. / `ret eq` / .. / `L3:` / `ret`).  A
constant dividend is loaded at the division's width (`gc2 = 8 / gs.c` -> `ld WA,0x8` / `divs WA,(_gs)`, not
`ld A,0x8` / `exts WA`; stdiv3.c's K rows show the same).  Random programs at none 151 -> 154 of 800 (29 / 70 / 25
at the other sets, unchanged).

**Batch 76 (2026-11-13): two rules from functions three lines off.**  A commutative int operation (`+ & | ^`) whose
left is plain memory (a global, a constant element, a static member) and whose right is computed evaluates the
computed side first and takes the memory as the operand (`return gi3 + (gpl[3] % 16)` -> .. / `ld HL,QWA` /
`add HL,(_gi3)`; `gia[0] + gps->a[5]` -> `ld XWA,(_gps)` / `ld HL,(XWA+0x18)` / `add HL,(_gia)`); a remainder then goes
straight into the result register.  A conditional expression with a constant else-arm loads the constant first and
the test skips the other arm's load, with one label (`u == 2 ? gi3 : (16 - 255)` -> `ld HL,0xff11` / `cp IZ,0x2` /
`j ne,L1` / `ld HL,(_gi3)` / `L1:`); the model does this when the test is compares only and the other arm is a plain
load, and keeps the two-label form otherwise.  Random programs at none 154 -> 158 of 800 (29 / 70 / 25 at the other
sets, unchanged); elrd.c at none 270 -> 274.

**Batch 77 (2026-11-13): three rules also under -Xr.**  `lift_guard.py` tried the rules of batches 71 to 76 at -Xr
and at -O3 -XS.  Three gain at -Xr and are lifted there: an unsigned `% 2^k` as `and`, the commutative operation that
computes its complex side first, and the constant else-arm loaded first.  None gains at -O3 -XS.  Random programs at
-Xr 70 -> 74 of 800 (158 / 29 / 25 at none / -O3 -XS / -O3 -XS -Xr, unchanged).

**Batch 78 (2026-11-13): the long helper's operand order under -Xr.**  Near misses at -Xr showed the helper's two
plain operands loaded in the reverse of the compiler's order: the model had treated -Xr as the optimised sets (the
divisor first beside any local in XIZ, the dividend first before a plain divisor).  Without -O, -Xr orders them as
cdecl does: a constant or static dividend after a plain global divisor (`65536L / gl` -> `ld XBC,(_gl)` /
`ld XWA,0x10000`), and the dividend first when only a loop counter sits in IZ (`gl2 % gl` -> `ld XWA,(_gl2)` /
`ld XBC,(_gl)`).  The unsigned divide by a power of two as a shift also holds at -Xr.  Random programs at -Xr
74 -> 79 of 800; lhx.c 184 -> 214, stdiv.c 162 -> 178, stdiv2.c 426 -> 442, evorder_lh.c 241 -> 249, evorder_ad.c
933 -> 938 at -Xr: eight ledger rows up by 80 functions.

**Batch 79 (2026-11-13): two -O rules from the optimised sets' near misses.**  Under -O an int local or parameter
that nothing reads produces no code: its initialiser and the statements that only write it (`++t`, `b--`, `t op= x`,
`t = x` with x free of side effects) disappear when they stand outside any loop (`unsigned t = 3; ++t;` -> nothing;
`b--;` on a parameter -> nothing).  Inside a loop they stay: micro ra_leaf2 accumulates `v1 += ga[i]` into IY though
nothing reads v1, and the first version of the rule, which took those too, lost that function on the scratch ledger.
And a static address that initialises a pointer kept in XIZ is loaded straight into it (`char *t = &gca[5]` ->
`lda XIZ,_gca + 0x5`, not through XHL).  Random programs at -O3 -XS 29 -> 39 and at -O3 -XS -Xr 25 -> 32 of 800
(158 / 79 at none / -Xr, unchanged); fpp10.c at -O3 -XS 68 -> 70.

**Batch 80 (2026-11-13): five rules also under -O; two unreferenced labels.**  `lift_guard.py` ran over every one of
the model's 252 rule flags at -O3 -XS.  Six gained one random function each; five are lifted to -O: an element's
address through WA, the constant else-arm loaded first, the unsigned divide by a power of two as a shift, a pointer
home's initial value, and an element pushed from memory (`pushw (XBC+WA)`).  The sixth, the general char argument
path, also gained one but wrote wrong code under -O (semcheck: idxloc.c il_c_T7 pushed `gca[t]` through the
zero-extending sum where -O indexes `(XWA+IZ)`; random r3_03_05), so it stays as it was.  Two labels nothing
jumps to are no longer written: the skip label of -O's preloaded constant else-arm, and the join label of an `if`
whose test is a constant (`if (255 != 4313) { .. }`).  A first, wider version of the second, dropping any join label
nothing references, cost four random functions at none: the compiler keeps the label of an early-returning inner
`if` (batch 75).  Random programs at -O3 -XS 39 -> 45, at -O3 -XS -Xr 32 -> 36 and at -Xr 79 -> 80 of 800 (none 158);
idxloc.c 31 -> 37 and 36 -> 40 at the two optimised sets, cmpord.c +1 and cmpordl.c +2 at each of the four sets:
eighteen ledger rows up by 33 functions.

**Batch 81 (2026-11-13): six rules from functions two and three lines off.**  The address of a char array element
whose index sits in IZ takes the base first (`return &gca[t]` -> `lda XWA,_gca` / `ld HL,IZ` / `extz XHL` /
`add XHL,XWA`).  A constant chained through a constant element or static member into a global is stored into both
(`guc = guca[6] = 9` -> `ldb (_guca + 0x6),0x9` / `ldb (_guc),0x9`).  A stored operation on a call's result is done in
HL, where the call left it (`gu2 = ru(..) | 1` -> `cal _ru` / `inc 0x2,XSP` / `set 0x0,HL` / `ld (_gu2),HL`).  A
global shifted into a variable kept in IZ is loaded into IZ and shifted there (`unsigned t = gu << 7` ->
`ld IZ,(_gu)` / `sll 0x7,IZ`).  The unsigned divide that is a shift works on a static member directly, not through
its address as a real division does (`gs.u /= 16` -> `ld WA,(_gs + 0x8)` / `srl 0x4,WA` / `ld (_gs + 0x8),WA`).  And
the chained-store rule of batch 30 now also runs when a variable lives in a register the chain does not need
(`gua[0] = gps->u = K` beside a long in XHL).  Random programs at none 158 -> 164 of 800 (45 / 80 / 36 at the other
sets, unchanged).

**Batch 82 (2026-11-13): seven more rules under -Xr.**  `lift_guard.py` over every rule flag (274, fpgen's included)
at -Xr: the evaluation-order rules for a constant left operand and char swaps (one guard for CONST_LEFT_SWAP, EVORDER
and L2_CHAR_SWAP), the store after a long helper, a pointer plus a constant through `lda`, operations on memory
through a pointer, and an unsigned long `% 2^k` as `and` each gain there, and none loses a ledger row.  Random
programs at -Xr 80 -> 87 of 800 (164 / 45 / 36 at none / -O3 -XS / -O3 -XS -Xr, unchanged); at -Xr lhx.c 214 -> 236,
stdiv2.c 442 -> 458, loopctr.c 14 -> 23, stdiv.c 178 -> 186, fpargf.c 24 -> 32: eight ledger rows up by 70 functions.

**Batch 83 (2026-11-13): the statement probes, and 253 wrong-code verdicts they expose (OPEN).**
`corpus/probes/rstmt1.c` .. `rstmt4.c` (`gen_rstmt.py`, run 2026-11-13-7-micro-rstmt) hold every statement line of
the four random corpora alone in its own function, 4,694 functions: the locals a line uses are initialised from
externs, `v0();` comes first when an earlier line of the original calls.  The hand-made probes kept missing the
combinations the random generator makes; here the shapes are the corpus's own.  This gives a statement-level score:
the model reproduces 3,308 / 2,930 / 2,950 / 2,806 of the 4,694 at none / -O3 -XS / -Xr / -O3 -XS -Xr (70.5 / 62.4 /
62.8 / 59.8 %), and `diffpat.py` ranks the differences that remain by pattern.  Four rules from its first list:
an explicit `(char)` of an int in memory stays a cast through `narrow`, so that every context reads the word
(`guca[3] = -((unsigned char)gua[0])` -> `ld WA,(_gua)` / `neg A`); a long local in XIZ passed under an explicit
sign cast is copied through XWA; `x % x` and `x / x` fold for a long too; and a conditional jump to the label of the
final bare `ret` is a `ret cc`, the label staying (a `break` in a function's last loop; an unconditional jump there
stays, r2_07_14).  rstmt at none 3,308 -> 3,341, random at none 164 -> 165.
**The cost of looking closer: semcheck on the new rows reports 253 verdicts (73 -> 326), 116 distinct statements whose
model code behaves differently from the compiler's.**  Most belong to functions the model refuses as a whole, so
they had never been simulated.  `notes/cc900-compat-plan-2026-11-08/rstmt-wrong-code-2026-11-13.txt` lists each
with its sets, the first difference and the statement.  They are of two kinds.  Model bugs: a `char` parameter read
as a word, a signed int index zero-extended (`gp = gp + a`), a helper's result shifted in XWA instead of XHL, an
invalid `j RET` for a constant-false test, register temporaries overwritten, `while (a-- > 0) *gpi++ = K` under -O
and -Xr, the clean-up amount of some -Xr functions.  And compiler quirks the model does not imitate: `gp + b` with a
`char` b is zero-extended, `(gc * gc) >> 7` shifts the byte, `-guca[a] / 10` negates the byte, `(8 ^ 16) << 11` folds
to 0.  The gate's baseline is now these 326; the next batches bring it back down, each fixing or refusing a class.

**Batch 84 (2026-11-13): the first wrong-code fixes from the statement probes; semcheck 326 -> 260.**
Five causes, 68 verdicts.  (1) A constant-false `&&` / `||` test with the function exit as its target wrote `j RET`,
not an instruction; and a test that is a constant now writes only its live arm, as the compiler does
(`if (0x10000UL != 0x10000UL && gu2 != 256) ++gu2;` -> `ret`).  (2) A function that ends with `retd` has no
`ret cc`: an early exit there (a loop's entry test under -Xr with a double parameter) skipped the stack clean-up;
every conditional return in such a function now jumps to the exit label.  (3) A constant shift of a long helper's
result shifted a stale XWA; it now uses the register the helper left it in (`(gul * x) >> 16` -> `cal C9H_mullu` /
`srl 0x0,XHL`).  (4) `while (a-- > 0) *gpi++ = K;` under -O and -Xr loaded the pointer into XBC over the counter in
BC; the live-register guard now catches a 32-bit load over the home of a narrower variable that the enclosing loop
uses (a wider version of this check refused two correct micro functions on the scratch ledger and was narrowed).
(5) The extension of a char pointer's index depends on the context: stored into a pointer the index is
sign-extended after the base is loaded (`gp = gp + a` -> `ld XBC,(_gp)` / `ld WA,(a)` / `exts XWA` / `add XWA,XBC`;
the model zero-extended a signed int there), while as a local's initialiser, a return value or an argument a char is
zero-extended whole, the compiler's own arithmetic (`char *u = gp + b` -> `ld XBC,(_gp)` / `ld XWA,0x0` / `ld A,(b)`
/ `add XWA,XBC`); under -O an int pointer's int index read once is zero-extended too.  rstmt 3,341 / 2,943 / 2,968 /
2,820 -> 3,350 / 2,957 / 2,969 / 2,823.  **Still open: 187 of the 253 verdicts of batch 83** (260 - 73), listed by
`gate/rsem.sh`: char arithmetic the compiler does at byte width, constant folding at char width, element indices
whose extension differs out of range, several -Xr forms.

**Batch 85 (2026-11-13): a register parameter is not written before its last read; semcheck 260 -> 244.**  Most of
the -Xr verdicts had one cause: the statement overwrote the first register parameter (in WA) and read it again later
(`gps->i = gps->a[a] % a` doubled `a` in WA for the index and then divided by it; a compare loaded XWA over `a` before
`guca[a]`).  The older guard only knows whether a parameter is read after the current statement.  STMT_PARAM_GUARD
counts, per expression or return statement under -Xr, how often the code has read a register parameter and refuses
a first write that comes before as many reads as the statement has uses; a copy to another register, a call, a use
in only one arm of `?:` / `&&` / `||`, and an in-place replacement of part of the register (`ld W,0x0` for
`x & 0xff`) count as served.  Each of those exemptions was a correct micro function the first version refused
(call.c k_nest and k_l, chnarrow.c cn_tern, cond_bits.c cb_i_p_ff); with them no ledger row moves.  16 verdicts
gone, none new.  The char-arithmetic probe (`corpus/probes/chararith.c`, 238 functions, run 2026-11-13-8) is
compiled and tabulated (research-scratch `tabulation/chararith-*`: a predictor for all 238 rows at none) but not
yet in the ledger or the model: the compiler keeps char arithmetic char-typed, and the model's C promotion is the
cause of several of the open verdicts.  **Open: 171 of batch 83's 253** (244 - 73).

**Batch 86 (2026-11-13): char arithmetic stays char-typed (probe chararith.c); semcheck 244 -> 233.**
`corpus/probes/chararith.c` (`gen_chararith.py`, run 2026-11-13-8-micro-chararith, 238 functions): seventeen char
expressions in fourteen int contexts.  The compiler does not apply C's integer promotion here.  `-c`, `~c`, `c + d`,
`c - d`, `c << k`, `c / d` and products of chars are char-typed: a shift, division, remainder, comparison, negation
or widening takes the byte (`(gc + hc) >> 3` -> .. / `sra 0x3,A` / `ld L,A` / `exts HL`; `-guc` is an unsigned char:
`neg A` / `extz WA`), and an int consumer widens it with `exts` / `extz`.  Only a signed product is the whole 16-bit
register where an int is wanted (returned, stored to an int, added, xor-ed, multiplied, passed), and a product with
an unsigned char multiplies the bytes unsigned.  The model had this for `+ - & | ^ ~` (`char_narrow`); it promoted
the rest as C does, which behaved differently in 107 of the 238 rows.  `char_narrow` now types `-`, `<<`, `/` of
plain global chars and `*` of any chars the compiler's way; no row of the probe behaves differently any more, and
121 are exact at none (71 before).  Three limits came from rows that were already exact: an array element negated or
shifted is promoted (random r4_09_06 `gi2 = -gca[0]` -> `exts WA` / `neg WA`; r4_06_05), an explicit `(int)` makes it
an int (`(int)guca[5] * 2`), and an index (`gia[u * 2]`) and a division stored to a char keep their own forms.  The
statement guard of batch 85 now also covers register temporaries at every set (a `char u` in A overwritten by a
pointer load), and a multiply whose right operand ended up in the accumulator is refused.  A Sonnet sub-agent's
predictor reproduces all 238 rows at none (research-scratch `tabulation/chararith-*`); the forms it shows are not
all ported.  **Open: 160 of batch 83's 253** (233 - 73).

**Batch 87 (2026-11-13): typed constant folding (probe kfold.c); semcheck 233 -> 227.**  `corpus/probes/kfold.c`
(run 2026-11-13-9-micro-kfold, 47 functions) asked why `return (8 ^ 16) << 11` is 0.  With negk.c's rows it gives
one rule for the compiler's folder: an operation on two byte-sized constants is char-typed, as its char arithmetic
on variables is (batch 86): unsigned when either constant is 128..255, a negative one then counting as its unsigned
byte (`-40 - 255` is 216 - 255); the value is kept whole (`100 + 100` is 0xc8, `127 + 1 + 1` is 0x81), but a left
shift of such a char-typed result is cut to the byte and extended again (`(8 ^ 16) << 11` is 0, `(100 + 100) << 1`
is 0xff90, `(200 ^ 1) << 2` is 0x24).  A bare literal shifts as an int (`8 << 11` is 0x4000), a product is whole,
long constants fold as C does, and `~K` of 128..255 is its low byte (`~255 + 1` is 1).  `fold` now carries that type
(`kctype`); batch 74's special case is part of it.  kfold.c 27 -> 47 of 47 and negk.c 38 of 38 at each of the four
sets.  And `x + 0` writes no instruction (`gi + ((8 ^ 16) << 11)` -> `ld HL,(_gi)`).  rstmt 3,352 / 2,958 / 2,971 /
2,824 -> 3,362 / 2,963 / 2,979 / 2,829; micro ra_*.c and fpp11.c +1 at none.  **Open: 154 of batch 83's 253**
(227 - 73).

**Batch 88 (2026-11-13): three more -Xr causes; semcheck 227 -> 195.**  (1) The test of an `if` loaded WA (or BC)
while an arm still read the parameter kept there (`if (gps->u) v2(gia[a], gi)` tested through XWA with `a` in A;
the compiler takes XBC for such a test): `test_clobber_check` refuses a test that writes the home of a register
parameter an arm reads; a loop's test is checked the same way for pointer and long homes
(`while (gi-- > 0) *a++ = K` tested with `ld WA,(_gi)` over `a` in XWA).  A parameter the arm only assigns does not
count.  (2) A read-modify-write on an element put the array's base into the index's own register
(`guca[b] <<= 1` with `b` in BC -> `lda XBC,_guca` / `lda XBC,XBC+BC`).  (3) An unsigned int index in a 16-bit
register index reads as signed; only the load form zero-extends it, so the other forms decline an unsigned index
(`gla[b] = ..` with an unsigned `b` in BC wrote `(XDE+BC)`).  32 verdicts gone, none new, no ledger row moves.
**Open: 122 of batch 83's 253** (195 - 73).

**Batch 89 (2026-11-13): pointer sums under -Xr; semcheck 195 -> 188.**  The context rule of batch 84 at -Xr, where
the index sits in a register.  Stored into a pointer: the base first and the index sign-extended, also when an
unread parameter occupies BC (`gp = gp + a` -> `ld XBC,(_gp)` / `exts XWA` / `add XWA,XBC`).  Returned: a char in a
byte register or QIZH is zero-extended whole (`return t + b` -> `ld XHL,0x0` / `ld L,C` / `add XHL,XDE`) and an int
index is copied and zero-extended (`return gp + b` -> `ld HL,BC` / `extz XHL` / `add XHL,(_gp)`).  But a local's
initialiser and an argument index with the register, signed (`char *u = gp + b` -> `ld XWA,(_gp)` /
`lda XWA,XWA+C`; `vp(gp + c)` -> `lda XWA,XWA+DE`): two first attempts that zero-extended there too were caught by
the gate (4 new verdicts) and narrowed to the return.  rstmt at -Xr / -O3 -XS -Xr 2,979 / 2,829 -> 2,981 / 2,831.
**Open: 115 of batch 83's 253** (188 - 73).

**Batch 90 (2026-11-13): register indices for IZ homes and unsigned indices; semcheck 188 -> 167.**  A char element
at a signed int local kept in IZ or QIZ is indexed with the register itself (`lda XWA,_guca` / `subb (XWA+IZ),0xff`;
`ld A,(XWA+QIZ)`); the model did this without -O only (idxloc.c) and wrote the zero-extending sum under -O.  It now
holds under -O for locals; a *parameter* the model homes in IZ is not included: the compiler reads it from memory
and zero-extends it there (random r4_03_00, which a first version got wrong; the gate caught it).  An unsigned int
index in a register is zero-extended whole into a sum (`gia[t] <<= 15` with an unsigned `t` in IZ -> `ld WA,IZ` /
`extz XWA` / `add XWA,XWA` / `ld XBC,_gia` / `add XBC,XWA`), where the model used the signed `(base+R16)`.
idxloc.c at the two optimised sets 37 -> 41 and 40 -> 45; 21 verdicts gone, several of them older ones on idxloc.c.
**Open: about 100 of batch 83's 253** (semcheck 167, of which 106 on rstmt).

**Batch 91 (2026-11-13): char typing for every operand kind (probe chararith2.c); semcheck 167 -> 163.**  Batch 86
had limited the char typing of `-x` and `x << k` to plain globals, because two random statements with an array
element showed int arithmetic.  `corpus/probes/chararith2.c` (`gen_chararith2.py`, run 2026-11-13-10, 576
functions: six operand kinds, signed and unsigned, eight expressions, six contexts) shows the typing holds for a
constant element, an element at a parameter, `*p`, `p->m` and a char parameter alike, and for every shift count up
to 7.  The two random statements carry an explicit `(int)` (`gi2 = -(int)gca[0]`, `(int)guca[5] << 5`), which the
model already respects; the limit is removed.  An unsigned char-typed value widened to a long clears the high byte
and then extends (`gl = -guc` -> `neg A` / `ld W,0x0` / `extz XWA`).  chararith2.c: no row behaves differently at
any set; 342 / 357 / 334 / 333 of 576 exact (153 at none before); chararith.c 121 -> 130 at none.  rstmt 3,363 /
2,965 / 2,981 / 2,832 -> 3,366 / 2,967 / 2,984 / 2,834.  **Open: 102 statement findings** (semcheck 163 = 61 older
reviewed ones + 102 on rstmt).

**Batch 92 (2026-11-13): the statement guard for any local in a scratch register; semcheck 163 -> 155.**  The guard
of batches 85 and 86 (no first write to a register before the statement has read the variable kept there as often
as it uses it) covered register parameters under -Xr and register temporaries.  A plain local that the planner keeps
in a scratch register was outside it: `unsigned char u = juc; gu = (gu2 + (unsigned)u) * gu2;` loaded WA over `u`
in A.  It is covered now, at every set, outside loops (a loop's planners move its variables themselves) and not for
the variable's own update (`i++`): both exemptions are from micro opt_loops.c ol_while, which a first version
refused; I had installed that version before reading the scratch ledger's two rows down, and nothing was committed
until they were gone.  8 verdicts gone, none new, no ledger row moves.  **Open: 94 statement findings**
(semcheck 155 = 61 older reviewed ones + 94 on rstmt).

**Batch 93 (2026-11-13): two char-index bugs; semcheck 155 -> 145.**  (1) A char parameter used as the index of an
int array was loaded as a word (`gua[c]` -> `ld WA,(XSP+0xc)`), reading the neighbouring byte of the stack slot;
`gen` now refuses any narrow variable in memory asked for at a wider size.  (2) The zero-extended whole form of a
char index in memory (`ld XWA,0x0` / `ld A,(b)` / `add XWA,XBC`) is the compiler's for a parameter read once; one
read twice it keeps in a register and indexes signed (`ld C,(b)` / .. / `ld A,(XWA+C)`), which the model does not
write yet, so the statement is refused there.  Declining instead (falling into the older paths) made three new
verdicts on the gate; refusing makes none.  10 verdicts gone, none new, no ledger row moves.  **Open: 84 statement
findings** (semcheck 145 = 61 older reviewed ones + 84 on rstmt).

**Batch 94 (2026-11-13): the guards reach declarations and tests over locals; semcheck 145 -> 142.**  The statement
guard now also runs in a declaration with an initialiser (`long u = gla[t] << (b & 15)` overwrote `t` in DE with
the shift count), and an `if`'s test may not write the home of a local in a scratch register that an arm reads, at
every set (`if (gca[t] > gc) return gca[t]` with an unsigned `t` in BC loaded XBC for the address).  `K * c` is
typed as `c * K` (`('0' * gp[0]) >> 5` -> `muls WA,0x30` / `sra 0x5,A`).  Two false positives were met and removed
before the commit: a floating-point initialiser, whose helper addresses the model emits ahead and patches, is not
judged for locals (rs_1_03_04_1 stays exact), but its register parameters still are (without that, a -Xr statement
the guard had been refusing came back wrong: 2 new verdicts on a first gate run).  **Open: 81 statement findings**
(semcheck 142 = 61 older reviewed ones + 81 on rstmt).

**Batch 95 (2026-11-13): every exit of a `retd` function goes through the `retd`; semcheck 142 -> 140.**  Batch 84
turned a `ret cc` in a function that ends with `retd` into a jump to the exit.  A plain `ret` (a `switch` arm that
returned on its own) and a tail jump to another function (`j .v0`) skipped the stack clean-up in the same way; they
are now a jump to the exit label, the tail jump as `cal` then the jump (`.rs_3_05_01_1`, `.rs_4_03_19_1` under -Xr
with a double parameter).  Also prepared, without effect on a verdict yet: `&arr[i]` with an unsigned register
index is extended whole under -Xr too, and the zero-extended sum of batch 90 serves a read-modify-write through
XBC.  **Open: 79 statement findings** (semcheck 140 = 61 older reviewed ones + 79 on rstmt).

**Batch 96 (2026-11-13): a char element's address by a QIZH / IZ register index; semcheck 140 -> 122.**  A char
element changed in place (`guca[t] /= 7`, `gca[t] %= 16`) at a signed local kept in QIZH, or in IZ under -O or -Xr,
takes its address from the register index: `lda XWA,_guca` / `lda XBC,XWA+QIZH` / `ld A,(XBC)` / .. / `ld (XBC),A`.
The model built a zero-extended sum (`ld BC,QIZH` / `extz XBC` / `add XBC,XWA`), which differs for a negative
index.  And `&arr[i]` with an unsigned register index under -Xr is extended whole also when an unread parameter
sits in WA.  18 verdicts gone (several older ones on idxloc.c among them), none new; rstmt +1 / +1 / +2 / +1.
**Open: 70 statement findings** (semcheck 122).

**Batch 97 (2026-11-13): an operation of a register with itself is refused; semcheck 122 -> 118.**  Under -O3 -XS
three statements combined a value with a copy of itself after the copy's source had been overwritten:
`guca[t] - t` came out as `ld A,(_juc)` / `ld C,A` / .. / `ld A,(XBC+WA)` / `sub A,A`, `guca[t] & t` as `and A,A`,
and `guca[a] <= a` as `cp WA,WA`.  No listing of the compiler has `sub`, `and`, `cp`, `xor` or `sbc` of a register
with itself in these places, so the model now refuses to write one.  4 verdicts gone, none new, no ledger row moves.
**Open: 66 statement findings** (semcheck 118).

**Batch 98 (2026-11-13): two more zero-extended char pointer indices; semcheck 118 -> 114.**  The address of a char
element at a char parameter, as a local's initialiser, zero-extends the char whole like a pointer sum does
(`char *u = &gca[a]` -> `lda XBC,_gca` / `ld XWA,0x0` / `ld A,(a)` / `add XWA,XBC`).  And an element read through a
char pointer at an int index that is read once, from memory, zero-extends the index (`t[b]` -> `ld WA,(b)` /
`extz XWA` / `add XWA,XBC`); the model sign-extended.  An index read again elsewhere in the function is another
matter: the compiler keeps it in a register and indexes signed (random r3_03_00, the function this statement comes
from: `ld A,(XWA+IZ)`), which a first version without the "read once" condition got wrong on the gate.  The
recurring rule of these batches, stated once: **an index read from memory is zero-extended into a sum; an index held
in a register is used as a signed register index.**  rstmt at none / -O3 -XS 3,367 / 2,968 -> 3,369 / 2,970.
**Open: 62 statement findings** (semcheck 114).

**Batch 99 (2026-11-13): the statement guard covers cdecl parameters kept in a register; semcheck 114 -> 110.**  The
guard of batch 87 (a register parameter must not be written before the statement's last read of it) ran only at the
-Xr sets.  Under -O3 -XS the planner also keeps a cdecl parameter in a register, and the same clobbers happen there
(rstmt rs_4_06_03_3); it now runs at every set for such parameters, with the parameter's own load from the stack
exempt (opt_params.c op_ret_b, `ld XDE,(XSP+0x8)`, which a first version refused: four ledger rows down on the
scratch copy, read before installing).  The guard's "a part replaced in place is a use" exemption is narrowed to a
constant written into the part (`ld W,0x0`); a narrower register load over the home is a clobber (rs_1_02_05_6,
rs_3_05_08_2 at the -Xr sets).  All four are refused, none is new code; scores unchanged.
**Open: 58 statement findings** (semcheck 110).

**Batch 100 (2026-11-13): no statement finding left at the plain set; semcheck 110 -> 98.**  Three refusals.
(1) A shift by a computed count parked the count in E while the value's code still read DE (rs_4_07_05_1: `t` in DE,
`ld E,A` / `ld WA,DE`); refused when DE is live or read.  (2) A char element's index that another statement reads
again: the compiler keeps it in a register and indexes signed (rs_2_02_17_0: `guca[a]` .. `gua[a]` -> `ld BC,(a)` /
`lda XWA,_guca` / `cpb (XWA+BC),0x80`, later `add BC,BC`; rs_1_01_13_3: `t *= 10; guca[t] &= 109` ->
`andb (XWA+BC),0x6d`), where the model zero-extended from memory.  Refused (IDX_READ_ONCE) for a local read in
another statement and for a parameter that is a char / int element's index in another statement.  Two narrower cases
stay as they were, because the oracle reads memory again there: twice within one expression (evorder_ad.c
ea_c_add_XX, cmpordl.c, stdiv3.c: a first version refused these, seven ledger rows down on the scratch copy) and a
later long element, which takes the index in WA (random r2_07_14).  (3) A chained store into a char element at a
register index (rs_3_01_16_2: `guca[a] = guc = -guc`, value first in C, then the zero-extended sum).  The second
refusal also removes two older reviewed verdicts in the random corpora (r2_05_00 at none, r2_05_11 at -O3 -XS).
Scores unchanged.  **Open: 48 statement findings** (semcheck 98): 0 none / 4 -O3 -XS / 19 -Xr / 25 -O3 -XS -Xr.

**Batch 101 (2026-11-13): two -O refusals; semcheck 98 -> 93.**  (1) Under -O an `if` / `else` whose arms both begin
with the same call without arguments has that call moved before the test (rstmt rs_3_00_04_6, random r3_00_04:
`cal _v0` / `ld XWA,(_gs + 0x4)` / `or XWA,XWA`); the model tested first, which differs when the callee changes what
is tested.  Refused (IF_ARMS_HEAD).  Calls with different arguments stay in their arms (ctrl.c c_ifchain,
`f1(20)` / `f1(30)`; a first version without the "no arguments" condition refused six micro functions on the scratch
copy).  (2) The across-call planner put an `int` in IZ and a pointer in XIZ at once (rs_3_04_07_6: `ld IZ,0x10`
over `t`); refused (IZ_ONE_VAR).  The two statement findings left at -O3 -XS, rs_3_06_19_0 and rs_4_09_17_5, are no
defects: the functions return nothing on the path compared (`if (..) return ..;` alone), so the verdict compares a
stale HL; reviewed in `semcheck_review.tsv`.  Scores unchanged.
**Open: 45 statement findings** (semcheck 93): 0 none / 2 -O3 -XS (both reviewed) / 19 -Xr / 24 -O3 -XS -Xr.

**Batch 102 (2026-11-13): three refinements of the -Xr statement guard; semcheck 93 -> 79.**  (1) A register
parameter read only in the arms of a conditional was not guarded at all (batch 87's exemption for `k ? c - 32 : c`);
the test's code could write it (rs_1_07_15_1: `*c <= t ? gul << (a & 15) : gula[a]` loaded `*c` into XWA over `a`).
It is now guarded until the first jump of the statement, where the arms begin; which arm's code comes when is still
not judged (rs_1_01_12_1 stays exact).  (2) The "a part replaced in place is a use" exemption no longer covers a
constant written over the low byte (rs_3_01_10_1: `ld A,0x0` over a long whose low byte is read next); a constant
into another part stays a use (cond_bits.c cb_i_p_ff `ld W,0x0`, cb_ul_p_ffff0000 `ld WA,0x0`; a first version that
kept only the high byte lost the latter on the scratch copy).  (3) An operand `(Xr+r)` whose index is a part of its
own base register is never right: the base was loaded over the index (rs_2_05_00_1: `lda XBC,_gua` /
`ldw (XBC+BC),0x0`; rs_2_06_13_1: `(XHL+L)`).  Refused in Fn.emit, whoever emits it.  All 14 are refusals; scores
unchanged.  **Open: 31 statement findings** (semcheck 79): 0 none / 2 -O3 -XS (reviewed) / 11 -Xr / 18 -O3 -XS -Xr.

**Batch 103 (2026-11-13): three more -Xr causes; semcheck 79 -> 64.**  (1) An element changed in place at an
unsigned int index held in a register: the oracle extends it whole (rs_1_05_16_4: `gula[a] |= K` -> `extz XWA` /
`sll 0x2,XWA` / `ld XBC,_gula` / `add XBC,XWA` / `or (XBC),XWA`; rs_2_04_15_2 with a local in IZ), the model indexed
`(XDE+BC)`, signed.  Refused in a wrapper around `lvalue` for the in-place kinds (UIDX_RMW).  (2) A `switch` value
loaded into WA over a register parameter that the body reads (rs_2_05_19_4, rs_3_05_00_2; the oracle tests in C / BC:
`ld C,(_gc2)` / `cp C,0x2`).  Refused (SWITCH_WA_PARAM); this also removes rs_3_06_12_3, rs_3_08_00_0 and
rs_4_09_17_3.  (3) Modelled, in chidx.py: a struct member array at an unsigned char register index, once the member
offset is added, is indexed by the byte register (rs_1_03_19_1: `a->a[b]` -> `extz BC` / `add BC,BC` /
`add BC,0xe` / `ld WA,(XWA+C)`; the model used `(XWA+BC)`).  Scores unchanged.
**Open: 16 statement findings** (semcheck 64): 0 none / 2 -O3 -XS (reviewed) / 4 -Xr / 10 -O3 -XS -Xr.

**Batch 104 (2026-11-13): the statement probes' findings are all dealt with; semcheck 64 -> 49.**  (1) The
"index read again" refusal of batch 100 now also runs at the -Xr sets (a local read in another statement,
rs_1_01_13_3; a register parameter the model spilled, which the oracle keeps in IZ and indexes signed, rs_4_00_14_4)
and at gen_load_mem's char element.  It does **not** judge a function that makes a call: random r3_07_00 reads `c`
from memory for `gca[c]` and again, after `cal _v1`, for `guca[c]`, and is exact; refusing it would cost an exact
function.  The price: two older verdicts that batch 100 had removed are back (r2_05_00 at none, r2_05_11 at
-O3 -XS; in both the oracle homes the index in IZ across the calls, which the model's planner does not do).  They
differ only for an index outside the array and are reviewed as such, as before batch 100.  (2) Modelled: at
-O3 -XS -Xr a local's initialiser zero-extends the int register index of an int pointer sum (`int *t = gpi + b` ->
`extz XBC` / `add XBC,XBC` / `add XBC,(_gpi)`; plain -Xr and `gpi = gpi + c` sign-extend): rs_1_04_15_0,
rs_1_06_01_0, rs_2_02_10_0 are exact now.  (3) Refused: `do .. while (--i > 0)` over an element at `i` under -O
(rs_1_00_19_4: the oracle keeps `dec 0x1,IY` / `cp IY,0x0` / `j gt`, the model's `sub` / `j gt` leaves the loop at
i = -32768), and a right operand that reads a register parameter whose home already holds the left value
(rs_3_01_01_2: `(guca[a] ^ 128) + (a - 255)`).  Reviewed as no defects: rs_4_08_02_0 and rs_1_05_07_2 (no return
value on the compared path) and rs_2_04_03_3, where V4.23 itself drops a call (case 2 of a switch whose cases 2 and
3 are the same call goes to the default arm) and the model, right by C, does not imitate it.
rstmt at -O3 -XS -Xr 2,836 -> 2,839.  **Open: 0 statement findings**; semcheck 49 = the reviewed rows.

**Batch 105 (2026-11-13): the exit label of a function that ends in `if (..) return x;`; rstmt +133.**  The most
common near miss of the statement probes at the plain set (42 of 816 differing statements).  A function whose last
statement is an `if` without `else` ending in `return x;` falls off its end after it; the return's jump to the exit
is dropped as a jump to the next instruction, but its label stays in front of the final `ret` (rs_1_00_07_3:
`ret eq` / `ld HL,(_gi)` / `L37:` / `ret`).  The model wrote no label.  Under -O a constant test leaves no label
(rs_3_00_19_3: `if (guc > 1 || 65536L < 86430L) return ..` is the bare return); a first version without that
condition lost four statements at each -O set.  The pass runs last, after -O's removal of unreachable code, which
dropped the label when it ran before.  rstmt at none / -O3 -XS / -Xr / -O3 -XS -Xr 3,369 / 2,970 / 2,986 / 2,839 ->
3,409 / 3,003 / 3,018 / 2,867 of 4,694.  The random corpora do not move (165 / 46 / 87 / 37): a function there
rarely ends this way.

**Batch 106 (2026-11-13): an `int` local's constant goes through WA when nothing optimises; rstmt +42.**  The second
near miss of the statement probes (34 statements).  `int t = 256 + 8; ji = t;` without -O is `ld WA,0x108` /
`ld (_ji),WA`: the local is forwarded into its one use, but as a register value, not as an immediate; the model wrote
`ldw (_ji),0x108`, which is what -O does.  Only the 16-bit case differed: a char local already went through A and a
long through XWA (17 + 5 and 6 + 5 statements of those kinds were exact).  rstmt at none / -Xr 3,409 / 3,018 ->
3,443 / 3,026 of 4,694; the -O sets and the random corpora unchanged.

**Batch 107 (2026-11-13): a local's pointer-operand initialiser; a correction to batch 105; rstmt +9.**  (1) Batch
105's exit label must not be written for a constant test at any set, not only under -O: two statements at none and
two at -Xr had lost their exact match to it, hidden in that batch's net gain of 40 and 32 (found by diffpat's
"model: L:" group; rs_3_00_19_3).  (2) `int t = gpi[0] & gia[3]; ji = t;` is `ld XWA,(_gpi)` / `ld BC,(_gia + 0x6)`
/ `and BC,(XWA)` / `ld (_ji),BC`: the pointer in XWA and the value in BC, the mirror of the direct store
`gi2 = gi & *hpi` (evorder_ad.c: XBC / WA).  Applied to a forwarded local at the plain set, and only to the shape the
evidence covers: a pointer in a global, a plain global value, one operation.  An element operand or a widened char
keeps XBC / WA (rs_1_01_13_0, rs_3_09_13_0; a first, wider version lost those).  Fifteen more statements differ from
the oracle only by this WA / BC swap in other contexts (a narrowing cast, an argument, a store through a pointer);
`swapfit.py` lists them.  rstmt at none / -Xr 3,443 / 3,026 -> 3,450 / 3,028.

**Batch 108 (2026-11-13): a call's or a long helper's result is computed before the store address; rstmt +2.**
From the largest refusal group of the statement probes ("the value overwrites the store address", 47 at the plain
set).  Without -O, `gla[b] = rl(..)` and `gula[a] = gul % gula[4]` compute the value first and store it from HL, the
address built afterwards in the usual registers (rs_2_08_19_1: `cal _rl` / `inc 0x4,XSP` / `ld A,(b)` / `extz WA` /
`sla 0x2,WA` / `lda XBC,_gla` / `ld (XBC+WA),XHL`; rs_1_09_19_2: `cal C9H_remlu` / `ld A,(a)` / `sla 0x2,A` /
`lda XBC,_gula` / `ld (XBC+A),XHL`).  Five statements leave the refusals: two exact (rs_1_09_19_2, rs_4_02_07_4),
three that now differ elsewhere (a local the oracle keeps in QIZH, labels).  Not covered, and still refused: a long
division by a constant, where the oracle takes the address first, into XIZ (rs_1_04_03_3), and the operand shapes
with an element at a variable index ("complex long helper operands", 40 statements: index temporaries in stack
slots, the element base in XIZ).  rstmt at none 3,450 -> 3,452.

**Batch 109 (2026-11-13): two forms from "the right operand overwrites the left"; rstmt +4; probe lhy.c.**  (1) A
computed left beside `*p` / `p->m`: the pointer is loaded first, into XBC, then the left is computed in WA and the
operation reads through XBC (rs_1_08_18_6: `gl = (gl >> 16) | gpl[3]` -> `ld XBC,(_gpl)` / `ld XWA,(_gl)` /
`sra 0x0,XWA` / `or XWA,(XBC+0xc)`; rs_2_08_18_1: `(gu2 / 100) + gps->u`).  The left may be a simple operation, a
shift, or an int division.  (2) An operand read through a pointer local held in XIZ is a plain memory operand,
`(XIZ)` / `(XIZ+d)` (rs_1_08_06_3: `t[2] + t[0]` -> `ld A,(XIZ)` / `add A,(XIZ+0x2)`).  Both without -O, cdecl.  The
refusal group stays large and mixed (64 statements at the plain set: conditionals, calls, char remainders, elements
at a variable index beside a pointer).  rstmt at none 3,452 -> 3,456.
**New probe `lhy.c`** (run 2026-11-13-11-micro-lhy, 360 functions; commit 70fe8a2ec): long `*` `/` `%` with an
element at an `int` or `char` index, the largest refusal group of both corpora.  The model before any rule for it:
96 / 48 / 0 / 0 of 360.  A Sonnet agent tabulated its templates (`tabulation/lhy-predict.py`, 360 of 360 lines;
`tabulation/lhy-FAMILIES.md`); porting them is the next batch.

**Batch 110 (2026-11-13): the guarded long helper statement; the exit label before the epilogue; lhy 96 -> 120.**
First steps on `lhy.c`, whose templates the tabulation gives in full (`tabulation/lhy-FAMILIES.md`).  (1) The planner
of a long helper with an element operand (plan_lh_call0) took its one statement only at the top level; the random
corpora write every division under `if (divisor != 0)`.  The guard's code is the ordinary condition and the body
the plain form, so accepting the statement inside such an `if` is enough for the int-parameter rows
(lyi_*_iPg G E Y J D: 0 -> 4 of 4 each).  (2) Batch 105's exit label goes in front of the epilogue, not of the
`ret`: `L1:` / `pop XIZ` / `inc 0x2,XSP` / `ret` (lyi_l_d_iPgR); only the `inc` that undoes the frame's `dec` is
epilogue, an argument's `inc 0x4,XSP` is not (rs_2_00_05_2), and where the `if`'s own end label already stands
there is one label, not two.  lhy at none 96 -> 120 of 360; rstmt 3,456 / 3,003 / 3,028 / 2,867 ->
3,459 / 3,005 / 3,030 / 2,869.  Left on lhy: a local index (T rows), the held destination address (shapes C, and
E Y D under `*`), `x * 7` open coded (K J S), the char-index rows of the new shapes.

**Batch 111 (2026-11-13): a constant multiple of a long element at a variable index; lhy 120 -> 128.**  Without -O,
`gl = vla[c] * 7` loads the element into XBC as an absolute operand is loaded, and multiplies by shifts
(lyi_l_x_iPnK: `ld WA,(c)` / `sla 0x2,WA` / `lda XBC,_vla` / `ld XBC,(XBC+WA)` / `ld XWA,XBC` / `sla 0x3,XWA` /
`sub XWA,XBC`; a char index: `ld A,(c)` / `sla 0x2,A` / .. `(XBC+A)`).  The model refused ("complex multiplicand").
lhy at none 120 -> 128, lhx 862 -> 864, evorder_ad 1,082 -> 1,084.
**A limit worth stating:** of the 39 statements still refused as "complex long helper operands" at the plain set,
most are compound (a block under an `if` or a loop holding several statements, or two helpers): the long-helper
planner (plan_lh_call0) lays out the frame temporaries and XIZ for exactly one helper statement per function.
Composing several is frame allocation proper, not another template; lhy's remaining families (a local index, held
addresses) raise the probe's score but reach few corpus statements until that exists.

**Batch 112 (2026-11-13): two single-pattern near misses; rstmt +17.**  From diffpat's "alone" groups (statements
whose whole difference is one pattern).  (1) A shift count that reads a forwarded `int` local is computed at 16
bits (rs_1_04_04_2: `unsigned t = ju; gi3 <<= (t & 15)` -> `ld WA,(_ju)` / `and WA,0xf`; the model computed it in A).
The forwarding mark of batch 106 tells the count's code that the value came from a local.  (2) A double compound
assignment into element 0 of a global array takes the array's address through XWA (rs_3_00_17_0:
`gda[0] *= ..` -> `lda XWA,_gda` / `ld XIZ,XWA`), where an element with an offset, or a member, is loaded straight
into XIZ (`lda XIZ,_gda + 0x8`, 26 times in the statement probes; fpopa.c's `lda XIZ,_gs + 0x4`).  Both without -O.
rstmt at none / -Xr 3,459 / 3,030 -> 3,469 / 3,037.

**Batch 113 (2026-11-13): a computed long stored into `p->m`; rstmt +4.**  Without -O the model always put the
member's pointer in XBC and the value in XWA.  The oracle does so for a plain value (`gps->l = *hpl`, stord.c
st_l_DP) and for `gps->l = (long)!hl` (st_l_DN), but mirrors the pair -- pointer in XWA, value in XBC -- for a
compound assignment (`gps->l -= 6L | gl`, `gps->l |= gpl[3] << 8`) and for a value computed through a second
pointer (rs_2_03_01_1: `gps->l = (long)!*gp` -> `ld XWA,(_gps)` / `ld XBC,(_gp)` / `cpb (XBC),0x0` / `scc eq,BC` /
`exts XBC` / `ld (XWA+0x4),XBC`).  Longs only: an int member keeps XBC / WA (`gps->i = !gps->l`, `gps->u = ~gu`).
Two wider versions were stopped before installing: one cost two exact random functions (int members), the other
three probe rows on the scratch ledger (stord, stchain, stvx: plain long values).  rstmt at none 3,469 -> 3,473.

**Batch 114 (2026-11-13): a local whose value is dead across a call; rstmt +20.**  `int i = ji; v0();
for (i = 0; i < 11; i++) ..` keeps `i` in BC: `ld BC,(_ji)` / `cal _v0` / `ld BC,0x0` / `cp BC,0xb` (rs_1_00_03_5;
DE when the body's element reads take BC, rs_2_00_10_5).  The initialiser's value is never read -- the loop assigns
`i` first -- so nothing lives across the call.  The model counted it as live across the call and homed `i` in IZ
(`push IZ` .. `pop IZ`).  Three places had to agree: the across-call planner lets a top-level plain assignment after
the call kill the earlier value (KILL_TOP; batch 87 did this only inside branches); the register-temporary planner
plans such a local from its next assignment, as it does a counter declared without an initialiser
(DEAD_INIT_CTR); and the live-register guard lets the call pass over the register (dead_until_redef).  Functions
with a long or floating-point helper keep the old behaviour: there the loop's counter is in IZ for the helper's
sake (rs_1_05_11_4, rs_3_09_10_3; a first version lost those, and seven plain `int t = ji; t = ..;` statements that
need no change at all).  rstmt at none 3,473 -> 3,493; the other sets unchanged.

**Batch 115 (2026-11-13): a returned two-level expression; rstmt +8.**  Without -O the model computed a returned
expression in HL throughout.  The oracle uses HL only for the outermost operation when its operand is itself
computed: the operand goes to WA, is moved, and the outer shift or negation is done in HL (rs_1_09_06_6:
`return (6L + gl) << 9` -> `ld XWA,(_gl)` / `inc 0x6,XWA` / `ld XHL,XWA` / `sla 0x9,XHL`; rs_3_08_13_5:
`return -(8 | (unsigned)gl)` -> `ld XWA,(_gl)` / `set 0x3,WA` / `ld HL,WA` / `neg HL`); a long `~` is finished in
WA before the move (rs_1_00_03_7: .. `cpl WA` / `cpl QWA` / `ld XHL,XWA`).  A plain operand is still loaded straight
into HL (`return gl << 9`), and a folded constant is a constant (kfold.c: a first version sent `(8 ^ 16) << 11`
down this path and cost 16 of that probe's 47 on the scratch ledger).  Only the three outer forms seen; cdecl.
rstmt at none 3,493 -> 3,501.

**Batch 116 (2026-11-13): an `int` local that indexes char elements lives in BC; rstmt +5, idxloc +3.**  Without
-O the first register of a local with an initialiser is WA; one that is only ever the index of char elements takes
BC instead, and the element's base goes to XWA: `int t = ji; guc = guca[t];` -> `ld BC,(_ji)` / `lda XWA,_guca` /
`ld A,(XWA+BC)` (rs_1_08_08_1); the element's address as a local's initialiser `lda XWA,XWA+BC` (rs_1_00_00_2); a
constant store `ldb (XWA+BC),0x3` (rs_4_01_03_4).  A stored address `gp = &gca[u]` keeps WA and the sign-extended
sum (rs_2_02_19_6).  The compound assignment `guc |= guca[t] ^ 229` wants the same and is not done yet (the model
falls to DE there).  rstmt at none 3,501 -> 3,506; idxloc.c 82 -> 85; semcheck 49 -> 48 (idxloc il_c_RA at none is
right now; its review row still covers the other sets).

**Batch 117 (2026-11-13): a write-only local has no slot; rstmt +4, fpp10 +2.**  Without -O a local that is only
ever assigned -- never read -- gets no frame slot: its initialiser and each `t = e;` are evaluated into WA and
nothing is stored (rs_2_09_17_4: `int t = ji; v0(); t = a;` -> `ld WA,(_ji)` / `cal _v0` / `ld WA,(XSP+0x4)`;
rs_1_01_15_2: `t = gps->u` -> `ld XWA,(_gps)` / `ld WA,(XWA+0x8)`).  The model kept a slot and stored into it.  A
pre-pass (eval_write_only) marks those statements; the declaration then goes the existing unused-local way.  Not for
a variable touched in a loop or a switch, nor when a right side calls (batch 76's dead-call-store rule covers the
plain call).  `return (t = 255);` evaluates twice (`ld WA,0xff` / `ld HL,0xff`) and is left.  rstmt at none
3,506 -> 3,510; fpp10.c 71 -> 73.

**Batch 118 (2026-11-13): a returned `*p op division`; an int pointer plus an unsigned char; rstmt +6.**  (1) A
returned commutative operation whose left reads through a pointer and whose right is an int division loads the
pointer first, into XBC, divides in WA, moves the quotient to HL and reads through XBC (rs_2_08_03_6:
`return *gpi ^ (gi / 10)` -> `ld XBC,(_gpi)` / `ld WA,(_gi)` / `exts XWA` / `divs XWA,0xa` / `ld HL,WA` /
`xor HL,(XBC)`).  Only a right side that needs WA: with a simple one the pointer stays in XWA and the value is
computed in HL (evorder.c eo_x_PB; a wider first version cost eight functions of evorder.c / evorder_l.c on the
scratch ledger).  (2) `gpi = gpi + b` with an unsigned char `b` scales at 16 bits and sign-extends the result of
that: `ld A,(b)` / `extz WA` / `add WA,WA` / `ld XBC,(_gpi)` / `exts XWA` / `add XWA,XBC` / `ld (_gpi),XWA`
(rs_3_09_01_4); as a local's initialiser the index goes to BC and the sum is an `lda`: `ld BC,WA` / `add BC,BC` /
`ld XWA,(_gpi)` / `lda XWA,XWA+BC` (rs_1_07_17_1).  rstmt at none 3,510 -> 3,516.
Tried and dropped in this batch's work: a general "an array's own address goes through XWA" pass (true for a store
into element 0 and for a double argument, false for plain globals and long-helper operands: -8 statements, -4
random functions).

**Batch 119 (2026-11-13): an `and` that clears one bit is `res`; rstmt +1.**  The oracle's listings contain `res 0xf,WA`
three times, each for a mask of 0x7fff (rs_1_04_05_0: `gua[c] & 32767` -> `ld WA,(XBC+A)` / `res 0xf,WA`); the model
emitted `and WA,0x7fff`.  A peephole turns an `and WA,K` whose mask clears exactly one bit into `res n,WA`, cdecl,
no -O.  The evidence is three listings, all the same form; the rule is no wider.  rstmt at none 3,516 -> 3,517; the
other sets and the random corpora unchanged.

**Batch 120 (2026-11-13): a char register local compares in place; rstmt +2.**  `char t = jc; if (t != 0) ..` with `t`
in C: the oracle writes `cp C,0x0` (rs_1_07_18_2; rs_4_04_14_4), the model copied C into A first (`ld A,C` /
`cp A,0x0`).  The same in-place compare already existed for a char in QIZ (CP_QIZ_K, random r3_09_12); this extends it
to the low byte of BC / DE / HL, cdecl, no -O, and only when A is not live.  rstmt at none 3,517 -> 3,519; chararith,
chararith2 and kfold unchanged.

**Batch 121 (2026-11-13): a one-bit doubling inside a constant multiply is `add R,R`; rstmt +2.**  `gul = gula[a] * 6UL`
without -O: the oracle doubles with `add XWA,XWA` (x, 2x, 3x, 6x = add, add, add, add), the model wrote `sll 0x1,XWA`
(rs_1_06_10_1; rs_3_01_05_4).  The one-bit shift is kept everywhere else: the oracle has 88 `sll 0x1`/`sla 0x1` lines,
so the rule is only the doubling step inside gen_mul_const.  rstmt at none 3,519 -> 3,521, at -Xr 3,037 -> 3,038;
chararith, chararith2, kfold, evorder_ad, lhx and lhy unchanged.

**Batch 122 (2026-11-13): a 4-byte XIZ local loads straight from a pointer member; rstmt +3.**  `long u = gps->l;`
with `u` homed in XIZ: the oracle writes `ld XWA,(_gps)` / `ld XIZ,(XWA+0x4)` (rs_1_05_15_1; rs_4_06_10_1 with a char
pointer at +0xa); the model loaded into HL and copied to XIZ.  Only a member or a plain pointer's target through a
global pointer, cdecl, no -O, and WA free.  rstmt at none 3,521 -> 3,524; chararith, chararith2, kfold, evorder_ad,
lhx and lhy unchanged.  (A first version emitted a doubled `ld ld` for the zero-offset form; caught by the probe check
before the gate and fixed.)

**Batch 123 (2026-11-13): a memory left compared with a cast right; random +1, rstmt +1.**  `cp mem,WA` with the cast's
value computed into WA first (the oracle order: right loaded, then the compare with the left in memory, `cp (_gi),WA`
in cmpx.c's `_cc_n_i_GGr`).  The condition code stays the same, since `mem - WA` has the flags of `l op r`.  Cdecl, no
-O, WA free.  Random at none 165 -> 166 of 800 (random3 37 -> 38); rstmt at none 3,524 -> 3,525.  The cmpx probe's
`r` rows stay refused (their path is cmp_wide, not this one); cmpx stays at 553 exact.

**Batch 124 (2026-11-13): a memory left compared with a cast of a memory right; cmpx +12.**  `if (r < (unsigned int)hl)`
(a parameter on the left, a long global cast on the right): the oracle loads the right's memory operand into WA and
compares the left in memory, `ld XWA,(_hl)` / `cp (XSP+0x4),WA`.  Batch 123's branch took only a computed cast; it now
also takes a cast of a plain memory operand.  cmpx.c at none 553 -> 565 exact (`_cc_n_i_GGr` now matches); the other
probes (chararith, chararith2, kfold, evorder_ad, lhx, lhy) unchanged.  `_cc_l_u_RGr` is still refused (its path
differs; not chased).  Random and rstmt unchanged (166 and 3,525 at none).

**Batch 125 (2026-11-13): a cdecl parameter read often is cached in a register; pc.c 9 -> 17 of 48 at none.**  Found by
following the store family's refusals (stv2.c / stv3.c): with the guard turned off the model's code for `gp->arr[c] =
.. / c` was the oracle's except that the oracle first copies the parameter into DE (`ld DE,(XSP+0x4)`) and uses the
register as index and divisor.  The new probe pc.c (48 functions over the number of reads of a parameter, 1 to 4, and
their roles; oracle run 2026-11-13-15) shows the rule, tabulated by a Sonnet agent (`cc900-tab/pc`, 48 of 48 with some
per-form constants): a cdecl parameter of a function with no calls is cached at entry when it is read three or more
times, or, for a signed int, twice when an index read is followed by a non-index read; the register is the first of
BC, DE, HL, IX, IY that the statement's own code leaves alone.  Ported as plan_param_cache, using the regtemp retry for
the register choice (not the agent's per-form table).  First versions cost 15 functions on stord, cmpordl and stdiv3
and one wrong-code verdict (cond_bits.c cb_tern: `(unsigned char)c` extended the cached copy in place); the rule now
skips a shift count (stord.c st_i_QS), a division by an element at a variable index (sd3's, stdiv3.c) and a parameter
read under a narrowing cast.  The corpora do not move (rstmt 3,525 / 3,005 / 3,038 / 2,869; random 166 / 46 / 87 / 37):
a function that caches a parameter also needs its other statements to pass.  pc.c at -O / -Xr: 8 / 12 / 13 of 48,
unchanged (none only).
**Open, newly visible (probe stv.c / pc.c, not caused by this batch):** pc.c `_pc_c_g` at -O3 -XS (a char parameter
index store leaves the element unchanged: wrong code) and `.pc_c_d`, `.pc_c_h` at -Xr and -O3 -XS -Xr (char arithmetic
on a parameter); the stv.c `x / x` verdicts are reviewed as zero-division only.
**Correction, same day:** batch 125's commit also carries `PTRARR_LVALUE` (`_lvalue_raw`), an experiment from the same
side copy that the batch text did not name: a store into a pointer's member array at a plain index builds its address
with the `A` kind of `cw_addr` (cmpx.c's `gps->a[t]`), instead of being refused as "lvalue index".  It changes no score
(stv2.c and stv3.c stay at 0 exact) and moved no gate figure; it only moves their refusals one layer down: stv2.c now
16 "complex long helper operands", 8 "the right operand overwrites the left", 4 "the value overwrites the store
address", 4 "lvalue index"; stv3.c 20 / 16 "lvalue index" / 12.  Next layer for that family: the long-helper operand
combinations with an element at a pointer-member index.

**Batch 126 (2026-11-13): a signed char index in memory is refused under -O; one open wrong-code verdict closed.**
`gca[c] = c` with a char parameter `c`, at -O3 -XS (pc.c `_pc_c_g`): the model zero-extended the index (`ld XDE,0x0` /
`ld E,A` / `add XDE,XBC`), which is wrong for a negative `c`; the oracle indexes with the signed register,
`lda XWA,_gca` / `ld C,(XSP+0x4)` / `ld (XWA+C),C`.  The zero-extending form is the right one without options (random
r2_05_07), so only the -O path now refuses, until the oracle's form is modelled.  No ledger row moved and no function
that was exact was refused.  Scores unchanged.  **Still open from batch 125's finding:** `.pc_c_d` and `.pc_c_h` at -Xr
and -O3 -XS -Xr (char arithmetic on a parameter).

**Batch 127 (2026-11-13): the statement guard's copy exemption does not cover a char parameter; the last open pc.c
verdicts closed.**  At -Xr a char parameter arrives in A.  For `gc = gca[c] + c` the model emitted `ld C,A` / `lda XWA,_gca` /
`ld A,(XWA+C)` / `add A,A`: the element load overwrote A, and the later read of the parameter still named A, so the sum
was element + element.  `c * c + c` ended the same way (`muls BC,A` / `ld A,C` / `add A,A`).  The guard of batch 87 lets a
write pass once the parameter has been "copied to another register: the copy serves the later uses", but the model's
later reads name the parameter's own register, so for a char the exemption is wrong.  The oracle keeps the parameter in A
and loads the element into C (`ld C,(XBC+A)` / `add C,A`).  The two statements are now refused at -Xr and -O3 -XS -Xr
(exact before: none).  No ledger row moved.  **Open wrong-code verdicts from the batch 125 probes: none.**

**Batch 128 (2026-11-13): a static struct's int member array at a variable index is loaded; rstmt +2.**  `gs.a[i]` reads
were refused ("memory load index"; 6 random functions among those with a member-array element).  The oracle loads them
like a global array's element, with the member's address as the base and the index form set by the index type
(read off 27 rstmt statements): signed int `ld WA,(b)` / `add WA,WA` / `lda XBC,_gs + 0xe` / `ld WA,(XBC+WA)`
(rs_2_03_01_0); unsigned int with the member offset folded into the low byte, `extz XWA` / `add XWA,XWA` / `add A,0xe` /
`lda XBC,_gs` / `(XBC+A)` (rs_3_09_11_2); char `ld A,(b)` / `add A,(b)` / `(XBC+A)`; unsigned char `extz WA` / `add WA,WA`
/ `(XBC+WA)`.  Without options, and only with WA and BC free (the oracle moves the base to XDE when BC is busy: not
done).  rstmt at none 3,525 -> 3,527 (rs_2_03_01_0, rs_4_06_04_2); the other statements of the family stop at other
operations of the same statement.  Random unchanged (166 / 46 / 87 / 37).

**Batch 129 (2026-11-13): a static struct's int member array element as a store or op= target; rstmt +2.**  The companion
of batch 128.  `gs.a[b] %= 3` -> `ld WA,(b)` / `add WA,WA` / `lda XBC,_gs + 0xe` / `lda XBC,XBC+WA` / `ld WA,(XBC)` / ..
(rs_1_08_10_6); a plain store keeps `(XBC+WA)` and computes the value after the address (`gs.a[t] = (int)gu2` -> .. /
`ld DE,(_gu2)` / `ld (XBC+WA),DE`).  Signed int and unsigned char indices, without options, WA and BC free.  rstmt at
none 3,527 -> 3,529 (rs_1_08_10_6, rs_4_00_07_4).  Random unchanged.

**Batch 130 (2026-11-13): a dead local index keeps its slot, which the long helper's temporary reuses; rstmt +1.**  From
the single-statement blockers of the random corpora (long-helper operands, 23 functions).  `int t = ji; v0(); gul =
gula[t] % 7UL;`: `t` lives across the call, and the oracle keeps it in its frame slot, then uses that slot as the
helper's index temporary (`ld WA,(_ji)` / `ld (XSP+0x4),WA` / `cal _v0` / `ld WA,(XSP+0x4)` / `ld (XSP+0x4),WA` / `ld WA,(XSP+0x4)`
/ `sla 0x2,WA` / `ld (XSP+0x4),WA` / `lda XIZ,_gula` / ..).  The model refused it.  Three parts, all without options: the
loop-counter marking of batch 7x (LH_CTR_SLOT) also marks a local whose only later read is that one statement's index
(after a call); its declaration is initialised in the slot; plan_lh_call0 uses the variable itself as the temporary
instead of a new one.  rstmt at none 3,529 -> 3,530 (rs_2_09_18_5); random r2_09_18 moves from refused to compiled
(differing elsewhere).  Random exact unchanged.

**Batch 131 (2026-11-13): a long helper by a constant whose left is another helper's result; lhx +16, rstmt +2.**  From the
single-statement blockers (long-helper operands).  `return (*gpl % 100L) / 100L;` -> `ld XWA,(_gpl)` / `ld XWA,(XWA)` /
`ld XBC,0x64` / `cal C9H_remls` / `ld XWA,XHL` / `ld XBC,0x64` / `cal C9H_divls` (rs_4_06_00_2): the inner helper first, its
result moved from XHL to XWA, the constant into XBC.  Unsigned by a power of two the outer is done on XHL: `gul % 3 % 2` ->
`cal C9H_remlu` / `and XHL,0x1` (rs_3_01_10_0), and a shift right for `/`.  Without options.  lhx.c at none 864 -> 880 (its
group 3, two helpers in one expression); rstmt at none 3,530 -> 3,532.  Random exact unchanged.

**Batch 132 (2026-11-13): a member through a pointer times a computed long value; rstmt +1.**  `gl = gps->l * (gpl[3] + gl)`
-> `ld XWA,(_gps)` / `lda XBC,XWA+0x4` / `ld XWA,(_gpl)` / `ld XWA,(XWA+0xc)` / `add XWA,(_gl)` / `ld XBC,(XBC)` / `cal C9H_mulls`
(rs_1_07_12_2): the member's address is held in XBC while the right side is computed in XWA.  Multiply only (for / and % the
left must be XWA), without options.  rstmt at none 3,532 -> 3,533.  Random exact unchanged.

**Batch 133 (2026-11-13): a call's long result by a constant; an unsigned long by a power of two; random +1, rstmt +7.**
(1) Batch 131's nested form also takes a call's result on the left: `return rul(gula[a]) % 10UL` -> .. `cal _rul` /
`inc 0x4,XSP` / `ld XWA,XHL` / `ld XBC,0xa` / `cal C9H_remlu` (rs_3_09_10_5).  (2) An unsigned long `%` or `/` by a power of
two calls no helper: `gula[a] % 2UL` -> `ld XWA,(XBC+A)` / `and XWA,0x1` (rs_3_07_12_2); `/` is a shift right.  The model
refused both ("complex long helper operands").  Without options.  rstmt at none 3,533 -> 3,540; lhx.c 880 -> 886; random
at none 166 -> 167 of 800 (random3 38 -> 39).

**Batch 134 (2026-11-13): a constant minus a pointer member; the value first for a store through a global pointer; random +1,
rstmt +3.**  From the single-statement blockers ("the right operand overwrites the left").  `gpi[3] = 255 - gps->a[4]` ->
`ld XWA,(_gps)` / `ld BC,0xff` / `sub BC,(XWA+0x16)` / `ld XWA,(_gpi)` / `ld (XWA+0x6),BC` (rs_1_02_13_3).  Two rules: the
value (a constant minus a member, or a member array at a constant index, through a global pointer) is built in BC with the
pointer in XWA; and when a value's code would overwrite the address of a store through a global pointer, the value comes
first and the pointer is loaded after it, which is what the guard of batch 34 refused.  A value ending in WA stays refused.
Without options.  rstmt at none 3,540 -> 3,543; stvxc.c 251 -> 255; elrd.c 274 -> 278; random at none 167 -> 168 of 800.
The gate's semcheck shows no new verdict.

**Batch 135 (2026-11-13): a long op= by a helper on a constant element holds its address in XIZ; rstmt +10.**  Found with
single_bad_stmt.py ("long element address across a helper", 6 functions one statement from exact).  `gla[2] /= 3L` ->
`push XIZ` / `lda XIZ,_gla + 0x8` / `ld XWA,(XIZ)` / `ld XBC,0x3` / `cal C9H_divls` / `ld (XIZ),XHL` / `pop XIZ` (rs_1_03_09_2).
The XIZ mechanism (LONG_RMW_XIZ, for an element at a variable index) refused a constant element because its lvalue is
direct memory; its address now goes into XIZ by `lda`.  Without options.  rstmt at none 3,543 -> 3,548 and at -Xr 3,038 ->
3,043.  Random exact unchanged (its six functions differ elsewhere too).

**Batch 136 (2026-11-13): a 4-byte local keeps its slot when a double op= needs XIZ; random refused 389 -> 382.**  From the
43 random functions whose statements are all exact alone (single_bad_stmt.py).  `char *t = gp; gda[1] *= gs.d / 3.0; ..`:
the model homed `t` in XIZ and then refused the double compound assignment, whose target address also needs XIZ ("a
double compound assignment over the XIZ home of t", 5 functions).  The oracle keeps `t` in a frame slot instead
(`ld XWA,(_gp)` / `ld (XSP+0x4),XWA` / `lda XIZ,_gda + 0x8` / ..; random r1_03_12).  Without options, a 4-byte local is not
homed in XIZ in a function with a double op= on a non-local target, and is kept out of folding so it gets its slot.  Seven
random functions move from refused to compiled (r1_03_12, r1_06_02, r2_07_03, r2_09_04, r3_03_04, r3_09_19, r4_06_12); none
is exact yet (r1_03_12's frame is 0x14 bytes where the oracle's is 0xc: the floating-point temporaries' layout).  The
gate's semcheck shows no new verdict, so the newly compiled code is right.  No ledger row moved.

**Batch 137 (2026-11-13): a local across a long helper keeps a frame slot; probe lsl.c; random refused 382 -> 380.**  From
the "local t" refusals (8 random functions).  New probe lsl.c (126 functions over the local's type, its initialiser, the
middle statement -- a long helper, a call, nothing -- and its use; oracle run 2026-11-13-16).  Across a long helper the
oracle keeps the local in a frame slot, XIZ being the helper's (`ld WA,(_gi)` / `ld (XSP+0x4),WA` / .. `cal C9H_remls` / .. /
`ld WA,(XSP+0x4)` / `add (_gi),WA`); across a call it homes it in IZ; with nothing between, a register temporary.  The model
now plans such a local as slot-only (no register temporary, no home, not folded) when a real long helper -- not folded,
not an unsigned power of two -- lies between its declaration and last use and no call does.  A first version counted
`7L * 10L` and `65536L % 4L` as helpers and ignored intervening calls: it cost three exact random functions on the scratch
ledger and was not installed.  lsl.c at none 31 -> 42 of 126 (char locals and the built-through-the-slot initialiser,
`ld (XSP+0x4),WA` / `ld WA,(XSP+0x4)` / `sra 0x3,WA` / `ld (XSP+0x4),WA`, are not modelled).  Random at none: exact 168
unchanged, refused 382 -> 380.

**Batch 138 (2026-11-13): the initialiser of a local in a slot across a long helper; random +1, lsl 42 -> 47.**  Read off
lsl.c (run 2026-11-13-16), without options: an int with a constant operand is computed in WA and stored (`ld WA,(_gi)` /
`inc 0x5,WA` / `ld (XSP+0x4),WA`); a long simple operation is built in the slot (`ld XWA,(_gl2)` / `ld (XSP+0x4),XWA` /
`ld XWA,0x5` / `add (XSP+0x4),XWA`); a shift by a constant is stored, reloaded, shifted and stored again (`exts WA` /
`ld (XSP+0x4),WA` / `ld WA,(XSP+0x4)` / `sra 0x3,WA` / `ld (XSP+0x4),WA`, random r1_07_08's form); a pointer plus a constant
is `lda XWA,XWA+0xa`.  Random at none 168 -> 169 (random1 49 -> 50); lsl.c 42 -> 47.
**Open, newly visible (probe lsl.c, not caused by batches 137 / 138; the model of batch 136 gives the same results):** 30
wrong-code verdicts at -O3 -XS and -O3 -XS -Xr, every `ls_*_h_r` (a local returned after a long helper): e.g. `ls_i_g_h_r`
returns 0x7 where the oracle returns 0xffff.

**Batch 139 (2026-11-13): a local across a long helper keeps its slot at every option set; 30 wrong-code verdicts closed.**
lsl.c showed (batch 138) that at -O3 -XS and -O3 -XS -Xr the model kept such a local in HL, which the helper's result
overwrites: `int t = gi; .. *gpl = gla[7] % gl; return t;` returned the remainder (`ls_i_g_h_r`: 0x7 where the oracle
returns 0xffff).  The oracle keeps the local in its frame slot at those sets too, so batch 137's rule now applies at every
option set.  It does not apply when a loop lies between the declaration and the last use: the 1997 library's `_ultoa` keeps
`q = s` across a loop of `val % radix` in a home (a first version lost it on the scratch ledger).  semcheck: the 30 lsl.c
verdicts are gone, none new.  lsl.c at -Xr 19 -> 30 exact; the other scores unchanged (random 169 / 46 / 87 / 37).

**Batch 140 (2026-11-13): a char local across a long helper is initialised in its slot; lsl +3 / +3.**  A char local with a
slot was stored there only when a call followed; across a long helper it fell to the register path and was refused
(`ld XWA,(_gl)` over it in WA).  It now goes to its one-byte slot the same way (`ld A,(_gc)` / `ld (XSP+0x4),A`; lsl.c
ls_c_g_h_a).  lsl.c at none 47 -> 50 and at -Xr 30 -> 33.  Not done: the char shift form, which the oracle computes in W
(`ld W,(_gca + 0x3)` / `sra 0x3,W` / `ld (XSP+0x4),W`).  Random unchanged.

**Batch 141 (2026-11-13): a call that is an operand pops at once; its shifted result stays in HL; random +1, rstmt +13.**
From single_bad_stmt.py (a DIFF group: `inc 0x4,XSP` against `ld XWA,XHL`).  Without options, when a call's result feeds a
further operation in the same statement the oracle pops the arguments right after the call and works on the result in
place: `gl2 = rl(gl) << 24` -> `cal _rl` / `inc 0x4,XSP` / `sla 0x8,XHL` / `sla 0x0,XHL` (rs_1_05_17_4); `gs.l = gl2 = rl(gl)
* 4L` -> .. `sla 0x2,XHL` (rs_1_01_03_2); `gla[3] -= rl(gla[a])` -> `cal _rl` / `inc 0x4,XSP` / `sub (_gla + 0xc),XHL`
(rs_4_02_17_5).  The model deferred the pops and moved the result to XWA.  Times 2 keeps the doubling by an add (call.c k_l:
`ld XWA,XHL` / `add XWA,XHL`; a first version shifted it and lost that micro function on the scratch ledger), and the pops
still wait when a later call absorbs them (POP_LAZY2).  rstmt at none 3,548 -> 3,561; random at none 169 -> 170 of 800.

**Batch 142 (2026-11-13): no model crash at -Xr.**  The random corpora at -Xr had 10 functions that crashed the model
(`AttributeError: 'Decl' object has no attribute 'off'`), pre-existing (the batch-98 model crashes the same way): under -Xr a
register parameter that a planner moves to a home slot has, until the frame is laid out, neither a register nor a slot nor a
stack offset, and the long-helper operand classifier and two char-index element paths (chidx.py) read its offset.
`mem_operand` now refuses such a parameter explicitly, plan_lh_call gives it a provisional slot while it classifies operands
(as it already did loop counters), and chidx.py declines the two paths.  Model errors at -Xr 10 -> 0; the functions are
compiled or refused with a reason.  No score moved.  Still crashing: three functions at -O3 -XS (`KeyError: 8`) and one
(`'N' object has no attribute 'decl'`).

**Batch 143 (2026-11-13): the wrong code batch 142 let through, fixed.** Batch 142's message said "semcheck
unchanged"; it was not. Its gate showed one new verdict, `rstmt3.c v423/Xr .rs_3_02_07_4` (`call 2 to .vc: model args
(0x14), oracle (0x1a)`), noticed only after the commit. The statement had crashed the model before; batch 142's
decline made it compile through the char-index 'pptr' path, which read the element `a[t]` (t a signed char in QIZH) by
the zero-extending memory-index form. The oracle reads the parameter's home slot and indexes by QIZH:
`ld XWA,(XSP+0x4) / ld A,(XWA+QIZH)`. In `chidx.py` (edit_batch143_chidx.py), `param_mem(F, d)` gives a stack
parameter's memory operand (its home slot when it has one), the 'pptr' and pointer-sum paths use it, and 'pptr' takes
the QIZH register-index form at -Xr. The 'pmem' path (`a->a[b]`) keeps declining a parameter without a stack offset:
there the oracle indexes by a byte register (`ld C,A / ld XWA,(p) / ld WA,(XWA+C)`, rstmt rs_3_08_13_4), which another
path already produces. Ledger down 0; pairs MATCH 223; semcheck 59 -> 58, the 58 reviewed before batch 142; random
170 / 46 / 87 / 37 and rstmt at -Xr 3,043, at -O3 -XS -Xr 2,869, all unchanged.

**Batch 144 (2026-11-13): no model crashes left in the random corpora.** Three crash sites become refusals or code
(edit_batch144.py). (1) `leaf_l2`: a char local across a call makes the -O leaf allocator stand aside; it has no byte
register in IZ, and the oracle writes `push QIZ` / `ld QIZH,A`, which the ordinary planner already produces. Random
r3_06_07 at -O3 -XS crashed with KeyError 8 and is now exact. (2) `gen_compare` refuses an operand wider than 4 bytes
(r4_08_05, a double compare at -O3 -XS). (3) `shared_base_opassign` declines a base that is neither a variable nor a load
(r2_01_02, `gps->a[6] += ...`, at -O3 -XS and -O3 -XS -Xr). Ledger up 1 (random3 at -O3 -XS 8 -> 9), down 0; pairs MATCH
223; semcheck 58, unchanged. Random 170 / 47 / 87 / 37; rstmt 3,561 / 3,005 / 3,043 / 2,869, unchanged.

**Batch 145 (2026-11-13): a long / or % by an element at an unsigned index (LH_REG_UIDX).** The oracle builds the
divisor element's address in XBC as the element load does (`ld WA,i / extz XWA / sll 0x2,XWA / ld XBC,_g /
add XBC,XWA`), whether the unsigned int index is a register variable in IZ or a variable in memory. A global dividend
comes next, then `ld XBC,(XBC)`; a constant dividend comes after the element's load (`ld XBC,(XBC) / ld XWA,0x4`).
`lh_reg_uidx` writes that shape without -O and -Xr; rstmt rs_3_04_14_4 (`gul / gula[u]`) and rs_2_07_08_5
(`4L / gla[b]`) are exact. Also, the value-first store path refuses a family without a long register instead of
crashing (random r2_04_10 at none, KeyError 4; no model errors are left at any set). Ledger up 2, down 0; pairs MATCH
223; semcheck 58. Rstmt at none 3,561 -> 3,564, random at none 170 -> 171 (random3 39 -> 40).

**Batch 146 (2026-11-13): a compare with an element at an unsigned index in IZ (CMPX_IZ), and conditional calls
(COND_CALL).** `cmpx_index` accepts an unsigned int index held in IZ and uses cmpx's unsigned-index form with `WA,IZ`
as its source (rstmt rs_4_07_10_4: `gc > gca[u]` -> `ld WA,IZ / extz XWA / ld XBC,_gca / add XBC,XWA / ld A,(_gc) /
cp A,(XBC)`). A jump around a single call (`j cc,L / cal f / L:`) becomes `cal !cc,f / L:`. The oracle's listings at
all four option sets hold 17 conditional calls and no jump around a lone call; helper calls are left alone. Ledger up
2, down 0; pairs MATCH 223; semcheck 58. Rstmt at none 3,564 -> 3,565, random at none 171 -> 172 (random4 40 -> 41).

**Batch 147 (2026-11-13): a chained store whose inner target's address is in XBC keeps the value in WA
(CHAIN_ADDR_BC_WA).** When the inner target of `x = a[i] = v` has its address in `(XBC)`, or at an 8-bit index
`(XDE+C)` and the like, the oracle builds the value in A/WA/XWA and stores it there and then into the outer target
(rstmt rs_3_06_16_2: `guc = guca[a] = guca[1]` -> `ld WA,(a) / extz XWA / ld XBC,_guca / add XBC,XWA /
ld A,(_guca + 0x1) / ld (XBC),A / ld (_guc),A`). The model refused these ("operator = through BC"). `(XDE+BC)` stays
refused: a char element at an int index, which the oracle zero-extends (`extz XBC`), while the CPU indexes
`(XDE+BC)` signed (rs_3_00_08_4). Ledger up 2, down 0; pairs MATCH 223; semcheck 58. Rstmt at none 3,565 -> 3,567,
random at none 172 -> 173 (random3 40 -> 41).

**Batch 148 (2026-11-13): a chained store into a char element at an int parameter index (CHAIN_CHAR_INT_IDX).**
`x = g[c] = v`, with g a global char array and c an int parameter in memory, gets the oracle's zero-extended address:
`lda XWA,_g / ld BC,(c) / extz XBC / add XBC,XWA`, then the value in A and `ld (XBC),A` (rstmt rs_3_00_08_4). Batch
147 refused it, because the model's own address was `(XDE+BC)`, which the CPU indexes signed. A global int index is
left out: cmpx.c shows it as `(Xb+i)`. Ledger up 3 (elrd.c 278 -> 284, random3 41 -> 42, rstmt), down 0; pairs MATCH
223; semcheck 58. Rstmt at none 3,567 -> 3,568, random at none 173 -> 174.

**Batch 149 (2026-11-13): pending call pops survive two more statement kinds (POP_LAZY_RET_BIN,
IF_CONST_KEEP_POPS).** Found among the 46 random functions at none whose rstmt statements are all exact but which
still differ (several of them differ only in where a call's pops go). `later_call_absorbs` lets a final
`return f(a) op g` (op one of `+ - & | ^`, no call or helper on the right) absorb the pops pending from earlier call
statements, as `return f(a)` does (random r1_06_19: `... pushw (XSP+0x6) / cal _r1 / inc 0x4,XSP / sub HL,(_gi3)`). An
`if` whose test folds to a constant no longer flushes the pending pops before it; they stay pending into the live arm
(r1_09_16: `cal _v1 / pushw 0x0 / cal _vc / inc 0x4,XSP`). Ledger up 2 (random1 at none 51 -> 53, at -O3 -XS 15 -> 16),
down 0; pairs MATCH 223; semcheck 58. Random 176 / 48 / 87 / 37; rstmt unchanged.

**Batch 150 (2026-11-13): a local across a long helper of plain operands lives in IZ / QIZ (LH_SLOT_XIZ_ONLY,
LH_PLAIN_IZ).** Batch 137's frame slot for a local across a long helper came from lsl.c, where the helper's
statement `*gpl = gla[7] % gl` holds gpl in XIZ across the call. When the operands and the target need no address
register (constants, globals, static members, constant elements), XIZ stays free, and the oracle gives the local IZ / QIZ
as across a call (random r4_00_09: `unsigned char t = (unsigned char)gula[0]; .. if (gs.l != 0) gs.l = gl % gs.l;
v1(t)` -> `push QIZ / ld QIZH,A / .. / ld A,QIZH`). The slot is now kept for helper statements that need XIZ, and a
plain helper statement before a local's last use makes it homes2's, not a register temporary's (without -O and -Xr).
Ledger up 1 (random4 41 -> 42), down 0; pairs MATCH 223; semcheck 58. Random 177 / 48 / 87 / 37.

**Batch 151 (2026-11-13): a constant into a char local in QIZH is `ld QIZH,k` (QIZH_CONST).** The oracle's listings at
all four option sets hold 19 `ld QIZH,k` and no `ld A,k / ld QIZH,A`; a reader then loads `ld A,QIZH` (random
r3_04_03: `char u = '0'; gc = u;` -> `ld QIZH,0x30 / ld A,QIZH / ld (_gc),A`). Ledger up 3 (random3 42 -> 43, lsl.c 50
-> 51 at none and 33 -> 34 at -Xr), down 0; pairs MATCH 223; semcheck 58. Random 178 / 48 / 87 / 37.

**Batch 152 (2026-11-13): a long register temporary initialised from a truth value (TRUTH_VIA_WA_LONG).** As
TRUTH_VIA_WA does for an int, a long local in XBC / XDE / XHL whose initialiser is a compare or `!` widened to long is
made in WA, moved at 16 bits and widened in place (random r2_02_14: `unsigned long t = (unsigned long)(1 >= gps->c)` ->
`scc le,WA / ld BC,WA / exts XBC`; the model wrote `scc le,BC / exts XBC`). Without -O and -Xr. Ledger up 1 (random2
40 -> 41), down 0; pairs MATCH 223; semcheck 58. Random 179 / 48 / 87 / 37.

**Batch 153 (2026-11-13): pending call pops wait through three more statement kinds (POP_LAZY_CHAIN, POP_LAZY_PTR,
POP_LAZY_FPCOPY).** `later_call_absorbs` follows chained stores and a call that is the left operand of `+ - & | ^ << >>`
or of `*` by a constant, whose pop takes the pending ones with it (random r1_01_03: `gul += rul(..); gia[6] %= 16;
gs.l = gl2 = rl(gl) * 4L` -> `cal _rul / add (_gul),XHL / .. / cal _rl / inc 0x8,XSP`). `store_plan` keeps them pending
for a store through a global pointer, as for a static target (r1_06_10: `*gp = rc(7)` -> `cal _rc / ld XWA,(_gp) /
ld (XWA),L`). A double copied between a static and a plain local does not release them: `stmt_touches_stack` says so,
and fpgen's `begin_stmt` (edit_batch153_fpgen.py) keeps them when a later call takes them (r1_06_10: `gd = t` ->
`lda XBC,XSP+0x2 / lda XWA,_gd / cal ._fld_dd`, then `inc 0x6,XSP` after `cal _rul`). Without that later call they go
first, as r1_08_03 and r2_01_19 showed when the first try lost them. Ledger up 1 (random1 53 -> 55), down 0; pairs MATCH
223; semcheck 58. Random 181 / 48 / 87 / 37.

**Batch 154 (2026-11-13): a double `?:` with a constant test is its live arm (FP_COND_CONST); a test that starts with
a call keeps the pending pops (IF_CALL_KEEP_POPS).** Found among the random functions at none whose first difference is
the frame size (44 of the 245 DIFF functions; about 95 differ first in the prologue, frame or IZ homes). `fold_fp_consts`
folds `c ? x : y` of doubles when `cond_const(c)` is known (random r4_01_01: `double t = (128 == 128 ? gs.d : gs.d)`,
which the model wrote with both arms and a second temporary, a 16-byte frame for the oracle's 8). An `if` whose first
evaluated operand is a call with arguments no longer flushes the pending pops before it; the call's pop takes them
(r4_01_01: `cal _vd / pushw (_gi2) / pushw (_gi2) / cal _r2 / add XSP,0xc`). Ledger up 4 (rstmt +1 at each set: 3,569 /
3,006 / 3,044 / 2,870), down 0; pairs MATCH 223; semcheck 58. Random unchanged, 181 / 48 / 87 / 37 (r4_01_01 still
differs in its return expression's registers).

**Batch 155 (2026-11-13): a double `?:` with a constant first arm is preloaded (FP_COND_PRELOAD); a call with a double
`?:` argument releases the pending pops (POP_LAZY_FPARG).** In fpgen's `cond_into` (edit_batch155_fpgen.py), a double
`?:` whose first arm is a constant and whose destination is a temporary loads the constant there first, then jumps over
the second arm when the test holds (random r3_05_16: `vd(guca[1] ? 0.25 : gd)` -> `lda XBC,S / lda XWA,XSP+0x4 /
cal ._fld_dd / cpb (_guca + 0x1),0x0 / j ne,L / lda XBC,_gd / lda XWA,XSP+0x4 / cal ._fld_dd / L:`). A later call whose
argument holds a double `?:` does not absorb the pending pops (r3_05_16: `cal _vp / inc 0x4,XSP`). A double sum
argument still does (r1_00_01), which a wider first try lost. r3_05_16 itself still differs in its frame size (16 for the oracle's
8: the second temporary comes from fpgen's frame planning, not yet understood). Ledger up 2 (random4 42 -> 43, rstmt at
none 3,569 -> 3,571), down 0; pairs MATCH 223; semcheck 58. Random 182 / 48 / 87 / 37.

**Batch 156 (2026-11-13): a computed char argument under cdecl -O3 -XS (CHAR_ARG_ANY_OPT), and -O char elements at
an int index refused where the oracle indexes signed (CHAR_ZX_OPT_GUARD).** CHAR_ARG_ANY / CHAR_ARG_GEN (a char
argument built in A, then `exts WA / push WA`) now also apply under cdecl -O3 -XS, where 29 random functions were
refused ("complex char argument"). That exposed three wrong-code verdicts in the zero-extending char-element forms
(`ld BC,i / extz XBC / add XBC,XWA`). The oracle writes those forms only when it reads the index from memory once. It
indexes signed when it keeps the index in a register: a parameter homed in IZ (random r3_07_00 and rstmt rs_4_00_14_4,
`ld A,(XWA+IZ)`), or a parameter read again (r3_03_05: `guca[b] += ..; for (i = b; ..)` -> `ld DE,(b) /
add (XBC+DE),A / ld IZ,DE`). Under -O both cases are now refused. A first, wider guard (every store or op= under -O)
lost arr_index.c ai_c_g_add and three siblings at -O3 -XS, where the index is read once and zero-extended. Ledger up 4
(rstmt at -O3 -XS 3,006 -> 3,028, chararith.c 114 -> 129, idxloc.c 41 -> 43, random4 15 -> 16), down 0; pairs MATCH 223;
semcheck 58 -> 56 (r2_05_00 at -O3 -XS and r4_03_00 at -O3 -XS -Xr no longer compile wrongly). Random 182 / 49 / 87 / 37.
Lead recorded, not acted on: the double temporaries' frame region (D + D', fpgen.temp). Of 156 double-using random
functions at none, the oracle's frame is D + D' for 75 + 37, D alone for 11 (r4_01_09, r3_05_16, r4_01_10: one
temporary for a call argument), and neither for 33 (research-scratch gate/fpframe.py).

**Batch 157 (2026-11-13): cdecl -O3 -XS, a static tested against zero and read again is tested in a register
(TEST_REG_REUSE).** The oracle's -O3 -XS listings hold 187 `ld R,(M) / cp R,0x0 / j` whose register is read in the
straight-line code after the jump (65 `div XWA,BC`, 39 `divs WA,C`, 32 `divs XWA,BC`, ...), against 867 memory tests
`cpw (M),0x0` whose static is not read there. This is the guarded division of the random corpora, `if (g != 0) x = y / g`.
`test_reg_reuse`, a final pass under cdecl -O, rewrites the model's `cpw (M),0x0 / j` that way when (M) is read and
not written before the next label, call, jump or return: BC (C for a byte), else DE (E). The register must appear
nowhere else in the function. A first try checked only the block, took BC while it held a loop counter, and gave
three wrong-code verdicts (rstmt rs_3_01_01_1, random r4_03_11, r4_05_13). Random r1_02_08 and r1_02_12 are exact.
Ledger up 2 (random1 at -O3 -XS 16 -> 18, rstmt 3,028 -> 3,029), down 0; pairs MATCH 223; semcheck 56. Random
182 / 51 / 87 / 37.

**Batch 158 (2026-11-13): `test_reg_reuse` under -O3 -XS -Xr as well (TEST_REG_REUSE_XR).** The oracle's -O3 -XS -Xr
listings show the same shape as -O3 -XS: 187 register zero tests whose register is read in the block after, and 2
memory tests whose static is read there. Without -O it never does this (none and -Xr: 255 memory tests each whose
static is read again). The same pass and rule now run under adecl -O. Ledger up 2 (random1 at -O3 -XS -Xr 13 -> 14,
rstmt 2,870 -> 2,872), down 0; pairs MATCH 223; semcheck 56. Random 182 / 51 / 87 / 38.

**Batch 159 (2026-11-13): under -O a long static tested against zero and then a long helper's right operand is tested
in XBC (TEST_REG_REUSE_LONG).** The long form of batch 157's guarded division: `if (gul != 0) gula[6] = 7UL / gul` ->
`ld XBC,(_gul) / or XBC,XBC / j eq,L / ld XWA,0x7 / cal C9H_divlu` (random r1_06_09, r3_09_08). The model tested
`ld XWA,(_gul) / or XWA,XWA` and loaded `ld XBC,(_gul)` again before the call. `test_reg_reuse_long` rewrites that
only under three conditions: the block writes XWA whole before reading it; it touches neither XBC nor the static
before the load; and XBC is dead at the jump's label. `xbc_dead_at` checks the last: every path, jumps followed, must
reach a full write, a call or a return before reading XBC. Ledger up 10 (lsl.c 19 -> 31 at both -O sets, rstmt at -O3
-XS 3,029 -> 3,032 and at -O3 -XS -Xr 2,872 -> 2,878, random3), down 0; pairs MATCH 223; semcheck 56. Random
182 / 55 / 87 / 42.

**Batch 160 (2026-11-13): `test_reg_reuse` takes a dead register (TEST_REG_LIVE, `reg_dead`).** Batch 157 took a
register only if the function used it nowhere else, which forced E where the oracle uses C (random r1_05_09:
`if (gc2 != 0) gca[2] = gs.c % gc2` -> `ld C,(_gc2) / cp C,0x0 / .. / divs WA,C`). `reg_dead(lines, start, R, lab)`
checks every path from a line or a label, conditional jumps followed both ways. Each path must reach a write of all of
R, a call, a tail jump to a function or a return before naming any part of R. A path off the listing, an indirect jump
or a jump table counts as live. The pass writes only R, so R must be dead after the last read it takes over and at the
jump's label. A first version treated a tail jump (`j _rp`) as unknown and lost r1_02_08. Ledger up 2 (rstmt at -O3 -XS
3,032 -> 3,034, at -O3 -XS -Xr 2,878 -> 2,881), down 0; pairs MATCH 223; semcheck 56. Random 182 / 55 / 87 / 42.

**Batch 161 (2026-11-13): under -O a guarded division takes its divisor from the test's register (GUARD_DIV).**
Statics were handled by batch 157's listing pass; a member through a pointer needs the code generator. For an
`if (D != 0)` without else under -O, whose then-arm starts with an assignment dividing by D (an int static, or a member
through a global pointer), `guard_div_plan` has the test load D into BC (`ld XWA,(_gps) / ld BC,(XWA+0x2) / cp BC,0x0 /
j eq,L`) and leaves (D, BC) for the arm. The division takes BC as its right operand when nothing since the test wrote
BC (`writes_family`), and reads D again if the dividend's code takes BC. store_div, bin_wide and evorder_bin stand
aside for it, and a constant dividend is `lda XWA,K` (random r1_09_05: `if (gps->i != 0) gi3 = 100 / gps->i` ->
`.. / lda XWA,0x64 / divs XWA,BC / ld (_gi3),WA`). Not when BC holds a live variable (checked before the load; random
r1_09_14 was refused by a first version), nor for D / D (r1_02_08, which the first version folded to a constant and
lost). Ledger up 3 (rstmt at -O3 -XS 3,034 -> 3,039 and at -O3 -XS -Xr 2,881 -> 2,883, random3 10 -> 11), down 0;
pairs MATCH 223; semcheck 56. Random 182 / 56 / 87 / 42.

**Batch 162 (2026-11-13): under -O an array read at two or more constant indices in one statement has its base in a
register (BASE_HOIST).** In the oracle's -O3 -XS rstmt listings (research-scratch gate/basehoist.py), 38 expression or
return statements without a call that touch one global int array at two or more constant indices load its base
first (`lda XBC,_gca / ld E,(XBC+0x2) / .. / ld A,(XBC)`), and 2 do not; with a call in the statement the elements stay
direct (5). `base_hoist` runs after each expression, return or declaration statement under -O that has no call,
helper or double. It puts `lda R,_g` at the statement's start and rewrites `(_g + K)` to `(R+K)`. R is the first of
XWA, XBC, XDE that the statement's code does not use and that holds no variable. It does not run while a pointer is
cached across statements (rstmt rs_1_09_07_8: `return (gula[5] = gula[0])` -> `lda XWA,_gula / ld XHL,(XWA) /
ld (XWA+0x14),XHL`; random r2_05_04). Ledger up 3 (rstmt at -O3 -XS 3,039 -> 3,064, at -O3 -XS -Xr 2,883 -> 2,897,
random2 9 -> 11), down 0; pairs MATCH 223; semcheck 56. Random 182 / 58 / 87 / 42.

**Batch 163 (2026-11-13): `test_reg_reuse_long` checks XWA by liveness (TEST_REG_LONG_LIVE); IZ_TAIL_DIRECT under
cdecl -O (IZ_TAIL_DIRECT_OPT).** In random r2_00_10 the reload `ld XBC,(_gul)` comes right after the jump, before
`ld XWA,0x10000`, so batch 159's "XWA written whole first" did not hold. The rewrite now also applies when XWA, which
no longer holds the static, is dead after the test and at the jump's label (`reg_dead`; a 16-bit write ends XWA's old
value). An IZ home loaded from memory and worked on is built in IZ under cdecl -O3 -XS as it is without options
(r1_09_00: `ld IZ,(_gi3) / sra 0xe,IZ`). Ledger up 1 (rstmt at -O3 -XS 3,064 -> 3,065), down 0; pairs MATCH 223;
semcheck 56. Random unchanged, 182 / 58 / 87 / 42 (both functions still differ elsewhere).

**Batch 164 (2026-11-13): under -Xr a register parameter the body never reads is dead from the entry
(UNREAD_PARAM_DEAD, SLOT_INIT_UNREAD).** The random corpora's functions often take parameters they never use. Under
adecl, those arrive in WA, BC or DE, and the model treated those registers as held for the whole function. The oracle
uses them freely (random .r1_02_04: `char a` in A, never read -> `ld XWA,(_gp) / ld (XSP+0x2),XWA`, where the model
avoided WA). `compile_function_once` now puts such a parameter in F.dead before the body (both -Xr sets), and
`slot_init`'s WA guard ignores it. Ledger up 24 with 420 more exact functions (rstmt at -Xr 3,044 -> 3,195 and at -O3
-XS -Xr 2,897 -> 2,980, stvxc.c +29 / +29, idxloc.c +19, fpargf.c +16 / +8, stdiv2.c +18 / +14, the random
corpora), down 0; pairs MATCH 223; semcheck 56 -> 54 (rs_4_08_02_0 at both -Xr sets no longer compiles wrongly).
Random 182 / 58 / 99 / 49.

**Batch 165 (2026-11-13): IZ_TAIL_DIRECT and MEMBER_STORE_BC under -Xr as well.** Two rules evidenced without options
hold under adecl too: an IZ home loaded from memory and worked on is built in IZ (random .r1_09_00), and a displaced
member store of an arithmetic value of plain operands puts the pointer in XWA and the value in BC (rstmt
.rs_1_03_03_1: `gps->l = gs.l - gl2` -> `ld XWA,(_gps) / ld XBC,(_gs + 0x4) / sub XBC,(_gl2) / ld (XWA+0x4),XBC`). Ledger
up 6 (stvxc.c at -Xr 111 -> 115, stvx.c 47 -> 49, rstmt 3,195 -> 3,198 and 2,980 -> 2,982, random1 and random4 at -Xr),
down 0; pairs MATCH 223; semcheck 54. Random 182 / 58 / 101 / 49.

**Batch 166 (2026-11-13): sixteen rules evidenced without options also apply under -Xr.** research-scratch
gate/xrtry.sh relaxes each of the 69 rules restricted to the no-option set (`not F.opt and not F.adecl` -> `not F.opt`)
alone and scores rstmt at -Xr (baseline 3,198; results in gate/xrtry-results-2026-11-13.txt). Sixteen gained two or
more statements; together they give 3,265: REG_MEMBER, LEFT_BIN_RIGHT_PTR, UCHAR_IDX_INTPTR, ULONG_POW2, LH_NESTED_K,
OPASSIGN_CALL_ELEM, XIZ_MEMBER_INIT, LOCAL_BIN_SWAP, RET_TWO_LEVEL, NESTED_IF_RET2, VALUE_FIRST_PK, MEMBER_STORE_SWAP,
ADD_IN_PLACE, HELPER_IS_CALL, DEAD_INIT_CTR, CHAR_IDX_BC. One relaxation lost and stays as it was. NESTED_IF_RET2 and
RET_TWO_LEVEL now skip a function that returns with `retd` (adecl with stack parameters). A first run turned
.rs_3_05_05_2's jump to the exit into `ret eq`, which skipped its `retd 0x8` (wrong code, caught by semcheck). Ledger up
9 with 131 more exact functions (lhx.c at -Xr 236 -> 258, stvxc.c 115 -> 129, lsl.c 34 -> 46, stdiv2.c 476 -> 483,
rstmt 3,198 -> 3,265, ...), down 0; pairs MATCH 223; semcheck 54. Random 182 / 58 / 102 / 49.

**Batch 167 (2026-11-13): ten rules evidenced without options also apply under cdecl -O3 -XS.** The same sweep as
batch 166, at -O3 -XS (research-scratch gate/xrtry2.sh "not F.adecl" O3XS; results in
gate/xrtry-results-o3xs-2026-11-13.txt): the 53 remaining no-option rules, each relaxed alone and scored on rstmt (baseline
3,065). Ten of the eleven that gained are relaxed together (3,077): CALL_SHIFT_HL, EVORDER_BYTE, K_DIVIDEND_WIDE,
LH_D_COMPUTED, CP_QIZ_K, MEMBER_ARR_LOAD, MEMBER_ARR_STORE, OPK_DEREF_GLOBAL, SHIFT1_MEM, AND_BIT_CLR. The eleventh,
LEAF_NONE_LN1, gained 3 rstmt statements but cost the 1997 library five functions (186 -> 181: _strncmp, _strcat, _strchr,
_strnset, _strset) and two wrong-code verdicts. A first combined run showed that in the ledger and the gate, and it was
not committed. The library is the -O3 -XS evidence the rstmt sweep does not see; gate/lib_one.sh scores it for one model.
Ledger up 1 (rstmt at -O3 -XS 3,065 -> 3,077), down 0; pairs MATCH 223; semcheck 54. Random 182 / 58 / 102 / 49.

**Batch 168 (2026-11-13): eighteen rules evidenced without -O also apply under -O.** research-scratch gate/xrtry3.sh
relaxes each of the 99 rules gated by `not F.opt` alone (to `True`) and scores rstmt at -O3 -XS and -O3 -XS -Xr
(baselines 3,077 / 2,982; results in gate/xrtry-results-opt-2026-11-13.txt). Eighteen lost at neither set and gained
four or more statements in all; each was then checked on the 1997 library (gate/lib_one.sh: 186 each, after batch 167's
lesson). Together they give 3,143 / 3,045: NOT_PTR_ELEM_CP, NOT_CHAR8, LEFT_BIN_RIGHT_PTR, COMM_SWAP_PLAIN, PTR_K_LDA,
UCHAR_IDX_INTPTR, SHIFT_COUNT_LOCAL, CHAIN_STATIC_WA, OPASSIGN_ZERO, OPASSIGN_CALL_ELEM, LONG_RMW_CONST_ELEM,
MULDIV_ELEM_ADDR, XIZ_MEMBER_INIT, LOCAL_BIN_SWAP, VALUE_FIRST_PK, MEMBER_STORE_SWAP, ADD_IN_PLACE, CHAR_IDX_BC. The
-O3 -XS -Xr sweep of the remaining no-option rules found no gain (gate/xrtry-results-o3xsxr-2026-11-13.txt). Ledger up
23 with 275 more exact functions (fpargf.c +24 / +16, stdiv2.c +10 / +16, stvxc.c +4 / +14, stdiv.c +12, lsl.c +10 / +10,
rstmt +66 / +63, the random corpora), down 0; pairs MATCH 223; semcheck 54. Random 182 / 60 / 102 / 52.

**Batch 169 (2026-11-13): five cdecl-only rules also apply under -Xr.** The last sweep of the series (research-scratch
gate/xrtry4.sh; results in gate/xrtry-results-adecl-2026-11-13.txt) relaxes each of the 56 rules gated by `not F.adecl`
alone and scores rstmt at -Xr and -O3 -XS -Xr (baselines 3,265 / 3,045). None lost. The five that gained two or more
statements are relaxed together (3,270 / 3,051): CALL_SHIFT_HL, K_DIVIDEND_WIDE, LH_D_COMPUTED, CP_QIZ_K,
OPK_DEREF_GLOBAL. Ledger up 5 (random1 and random4 at -Xr +2 each, stdiv.c 186 -> 190, rstmt), down 0; pairs MATCH 223;
semcheck 54. Random 182 / 60 / 106 / 52. With batches 166 to 168 this completes the four relaxation sweeps for the
current model.

**Batch 170 (2026-11-14): under -Xr a register parameter is dead after its last read (PARAM_DEAD_AFTER).** Batch 164's
rule generalised. Before each top-level statement, a parameter in WA, BC or DE goes into F.dead when neither this
statement nor a later top-level one reads it. A loop is one top-level statement, so a read inside it keeps the
parameter live for the whole loop. Ledger up 2 (random4 at -Xr 27 -> 29, homes2a.c at -O3 -XS -Xr 34 -> 35), down 0;
pairs MATCH 223; semcheck 54. Random 182 / 60 / 108 / 52.

**Batch 171 (2026-11-14): six more no-option rules apply under -Xr.** The -Xr sweep re-run on the batch-170 model
(gate/xrtry2.sh "not F.opt" Xr over the 43 remaining no-option rules; baseline 3,270; results in
gate/xrtry-results-xr2-2026-11-14.txt) found interactions the first run could not see. Six rules gained one or two
statements each and are relaxed together (3,277): CW_IZ_XWA, XIZ_PTR_MEM, K_MINUS_PTR, RET_PTR_LEFT, CHAR_IDX_BC's
lvalue side, KOP_IN_PLACE. Ledger up 4 (random1 at -Xr 35 -> 37, random2 20 -> 21, idxloc.c 80 -> 81, rstmt), down 0;
pairs MATCH 223; semcheck 54. Random 182 / 60 / 111 / 52.

**Batch 172 (2026-11-14): nine more rules gated by `not F.opt` apply under -O.** The -O sweep re-run on the batch-171
model (gate/xrtry3.sh over 87 rules; baselines 3,143 / 3,051; results in gate/xrtry-results-opt2-2026-11-14.txt).
Nine rules lost at neither -O set and gained two or more statements; each kept the 1997 library at 186. Relaxed
together they give 3,154 / 3,063: REG_MEMBER, the -O guard of lh_member_kinds (LH_MEMBER_K), K_MINUS_PTR,
MUL_K_DOUBLE_ADD, LH_NESTED_K, PTR_REG_DIRECT, CHAR_IDX_BC's lvalue side, MULB_SHIFT, RET_TWO_LEVEL. Ledger up 9 with
94 more exact functions (lhx.c +32 at both -O sets, evorder_lh.c +2 / +2, idxloc.c, random2, rstmt), down 0; pairs MATCH
223 (one refusal reason changed: the table data's _malloc, still refused); semcheck 54. Random 182 / 61 / 111 / 52.

**Batch 173 (2026-11-14): under the -Xr sets the homes2 rule decides where it homes parameters alone (HOMES2 policy
xr-fallback-noloop, edit_batch173_homes2.py).** The policy in use handed only cdecl -O3 -XS functions without a loop to
homes2; everywhere else homes.py decided. Each policy was measured as a model copy's default: the listing cache is keyed
by the model's files, so CC900_HOMES2 in the environment does not show through it, and an earlier check that way was
void. With homes2 everywhere the random scores read 180 / 61 / 115 / 53 against 182 / 61 / 111 / 52. The ledger showed
homes2 losing micro and probe functions under -Xr (call.c k_keep, ra_homes.c rh_ll, rh_pp_b2 ...: a local in IZ / QIZ,
the halves of two locals, the first of two int parameters). Its gains (random .r1_04_02, .r2_02_07, .r2_08_11,
.r3_07_00) all home a parameter alone. The new policy lets homes2 decide under -Xr and -O3 -XS -Xr when every value it
puts in a register is a parameter and no int parameter goes to a slot (first tries lost 9, 6 and 1 ledger rows).
Ledger up 7 (homes2a.c, homes2b.c, regkw.c, the random corpora at -Xr), down 0; pairs MATCH 223; semcheck 54. Random
182 / 61 / 115 / 53.

**Batch 174 (2026-11-14): SHIFT1_MEM sees a char's shift through its narrowing cast, and applies under -Xr too.** The
rule shifts a byte or word in memory when it is shifted by one in place. It tested `strip(s.e.r).k == 'bin'`, but
`guc = guc >> 1` reaches it as `(unsigned char)(guc >> 1)`, so it never fired for a char. The example in the rule's own
comment (random r2_02_06) was not exact. `uncast_int()` looks through the cast (rstmt rs_2_02_06_1 -> `srlb (_guc)`;
rs_2_03_03_1: `guca[5] /= 2` -> `srlb (_guca + 0x5)`). The rule's `not F.adecl` goes too, since it gains under -Xr as
well. Ledger up 6 (rstmt +1 at each set, random2 at none and -Xr), down 0; pairs MATCH 223; semcheck 54. Random
183 / 61 / 116 / 53.

**Batch 175 (2026-11-14): a call's result combined with a negated operand computes the operand in WA
(CALL_LEFT_UNARY_WA).** For `f(..) op -x` or `f(..) op !x` (op one of `& | ^ +`, int, result wanted in HL) the oracle
builds the operand in WA, applies the operator there with HL as source, and moves WA to HL (rstmt rs_2_04_05_2:
`return r2(gi2, a[7]) & -gi2` -> `.. cal _r2 / inc 0x4,XSP / ld WA,(_gi2) / neg WA / and WA,HL / ld HL,WA`; the model
negated in BC and wrote `and HL,BC`). Ledger up 1 (rstmt at none 3,572 -> 3,573), down 0; pairs MATCH 223; semcheck
54. Random 183 / 61 / 116 / 53.

**Batch 176 (2026-11-14): a guarded long helper with an element at a local index reaches plan_lh_call
(LH_ELEM_NOT_LEAF, LH_IDX_BCDE).** The random corpora's typical shape is `int i = gi; if (vla[i] != 0) gl = vl /
vla[i];`, lhy.c's iTg rows (0 of 32 exact). Two things kept it from batch 13x's slot-and-XIZ machinery (plan_lh_call,
lh_elem). First, `plan_leaf` took the function as a leaf: it ignores a helper outside a loop, and i is read twice. A
function whose long helper has an element operand at a variable index is no longer a leaf. Second, `lh_call_kinds`
accepted a register-temporary index only in WA / HL, while the oracle keeps i in DE (`ld DE,(_gi)` for the test, then
`ld (XSP+0x4),DE` into the helper's slot). Ledger up 2 (lhy.c at none 128 -> 144: rows G, X, J, D of iTg; lhidx.c
122 -> 128), down 0; pairs MATCH 223; semcheck 54. Random unchanged, 183 / 61 / 116 / 53.

**Batch 177 (2026-11-14): the long-helper operand planner runs under -Xr as well (LH_CALL_XR).** `plan_lh_call0`
returned at once for adecl, so none of the long-helper operand machinery (lh_call, lh_elem, the slot-and-XIZ element
form) ran under -Xr. The rule sweeps could not see this, because its guard is `F.adecl`, not `not F.adecl`. Enabling it
compiled evorder_ad.c's element-beside-a-call rows (`gla[c] / hfl()`, c in WA) wrongly: the index was read after the
call clobbered it, six semcheck verdicts in a first run that was not committed. `lh_call_kinds` therefore leaves that
pair alone under adecl. Ledger up 16 with 490 more exact functions (lhy.c 0 -> 52 at -Xr and 0 -> 48 at -O3 -XS -Xr,
lhx.c 258 -> 322 and 212 -> 262, stdiv2.c, stv.c, elrd.c, ...), down 0; pairs MATCH 223; semcheck 54. Random unchanged,
183 / 61 / 116 / 53.

**A gap for phase 3b**: cc900 writes the byte halves of IX / IY / IZ as `IXL`, `IYL`, `IZL` (`_fputc`:
`ld A,IZL`).  Our llvm-mc does not know those names: it takes `izl` for a symbol and emits a fixup
(`[0xc9,0x03,A]`).  The backend needs those registers (the extended-register `C7 r` form) before the compat
pipeline can emit them.

## How to resume

```sh
cd scripts/analysis/cc900/model
R=~/compartilhado/cc900-oracle/runs/2026-11-08-7-micro/out/v423
python3 -I -B score.py $R/none ../corpus/micro/*.c                       # one line per file and a total
python3 -I -B score.py $R/O3XSXr ../corpus/micro/binop_i.c --adecl --show 8   # mismatches, oracle on the left
```

The oracle VM is idle at `~/compartilhado/cc900-oracle/vm/`; new micro-tests go through
`scripts/analysis/cc900/corpus/gen_micro.py` and `oracle/run_oracle.sh`.
