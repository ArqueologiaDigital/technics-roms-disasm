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
