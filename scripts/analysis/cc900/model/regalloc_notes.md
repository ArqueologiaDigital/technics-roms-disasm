# Register allocation in cc900, as the oracle shows it (V4.23, no options)

Source: oracle run `2026-11-08-8-micro-ra` (cc900-oracle commit `403ee45`), files `corpus/micro/ra_leaf.c` and
`ra_call.c`, plus `ctrl.c` and `call.c` of run `2026-11-08-7-micro`.  "vN" are the generated locals.  Status per rule:
**fits** (all examples agree), **guess** (some examples, alternatives open), **open** (not understood).

## Leaf functions (no calls)

| rule                                                                                                                                                                                         | status | evidence                                                                               |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|----------------------------------------------------------------------------------------|
| every 16-bit local used in a loop gets a register; locals are processed in reverse declaration order                                                                                         | fits   | ra_leaf1-5, ra_leafsum1-5 (`int i` is declared first and allocated last)               |
| the register sequence is BC, DE, HL, IX, IY, IZ, QWA; IZ is saved with `push IZ` when used                                                                                                   | fits   | ra_leaf4 (`push IZ`), ra_leaf5 (the loop variable in QWA)                              |
| a register that a temporary inside the variable's range needs is skipped: indexing an int array through `ld WA,i / add WA,WA / lda XBC,_ga / (XBC+WA)` takes WA and BC, so BC is not offered | fits   | ra_leaf1 (i in DE) vs ra_char (`(XWA+BC)`: i in BC), ra_param3 (only WA used: i in BC) |
| a local that is returned as it is gets HL first                                                                                                                                              | fits   | ra_leaf1-5 (v0 in HL), ra_long (s in XHL), ra_char (c in L)                            |
| in ra_leafsum, HL goes to the second local in processing order (the first takes DE)                                                                                                          | fits   | ra_leafsum2-5: consistent with the sequence once BC is excluded                        |
| a parameter that is modified in a loop is copied to a register (`ld DE,(XSP+4)`)                                                                                                             | fits   | ra_while, ra_dowhile, ra_for_down, ra_ptr (k)                                          |
| a read-only parameter stays in memory, except one used in a nested (depth 2) loop                                                                                                            | guess  | ra_param3 (a, b, c in memory) vs ra_nested (k in BC)                                   |
| pointer parameters used with `*p++` stay in memory and are bumped there (`ld XBC,(p) / ld XWA,2 / add (p),XWA`)                                                                              | guess  | ra_ptr, ra_ptr2                                                                        |
| ... but pointers walked with `*s++` in both operands of an assignment go to XBC / XDE with `(XBC+:1)`                                                                                        | guess  | ra_ptrcpy, c_cnt                                                                       |
| locals not in loops: single-use locals fold into their use; others get registers in the same sequence                                                                                        | guess  | ra_noloop (y in BC), ra_noloop3 (x DE, y BC), ra_twice (x in HL)                       |

## Functions with calls

| rule                                                                                                                                                            | status | evidence                                                            |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|---------------------------------------------------------------------|
| only IZ and QIZ hold variables across calls; `push IZ` / `pop IZ` if only IZ, `push XIZ` if QIZ too                                                             | fits   | rc_keep1-4, rc_loop1-4, c_for, c_nested                             |
| the other locals live in stack slots below the saved XIZ (`dec N,XSP`, slots at `(XSP+4)` up)                                                                   | fits   | rc_loop2-4, rc_keep3-4, rc_ptr_loop, rc_two_loops                   |
| which variable gets IZ and which QIZ: looks cost-based.  QIZ cannot be a memory or push operand, so the variable that is pushed or compared with memory gets IZ | open   | rc_loop1 (v0 pushed: IZ; i: QIZ) vs rc_loop2-4 (i: IZ, last v: QIZ) |
| a parameter used across two or more calls is copied to IZ                                                                                                       | fits   | rc_param_twice, rc_param_thrice, rc_keep1                           |
| a parameter used once after a call stays in memory                                                                                                              | fits   | rc_param, rc_ptr                                                    |
| a long local across a call goes to XIZ                                                                                                                          | fits   | rc_long, mul_l_loc (binop_l.c)                                      |
| a parameter decremented in the loop condition (`while (n--)`) goes to IZ; in `do ... while (--n)` it stays in memory (`decw 0x1,(XSP+4)`)                       | open   | rc_while vs rc_dowhile; ra_dowhile (leaf) uses DE                   |

## Loop shapes (no options)

- `for (init; c; inc) body`: init; inverted c jumping to the exit; body label; body; inc; c jumping back to the body; exit
  label.  The exit label is numbered before the body label.  With no stack work after the loop, the exit jump is
  `ret <inverse>` (ra_leaf1), otherwise `j` (ra_leafsum2, which adds after the loop).
- `while (c) body`: the same without init/inc.  `do body while (c)`: body label; body; c jumping back.
- `x--` as a condition: `ld WA,x / dec 0x1,x / cp WA,0x0` (rc_while, ra_while).
- a down-counting `for (i = n; i > 0; i--)` tests with `sub DE,0x1 / j gt` (ra_for_down, c_fordown).

## Loops at -O3 -XS (cdecl)

Source: oracle run `2026-11-08-9-micro-optloops` (cc900-oracle commit `5bfb1b2`), `corpus/micro/opt_loops.c`.

| rule                                                                                                                                                                                                                                        | status | evidence                                    |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|---------------------------------------------|
| `for (i = 0; i < k; i++)`: accumulators and i initialised, the bound loaded into a register, then `cp bound,0x0` / `ret le` (`j le,exit` when code follows)                                                                                 | fits   | ol_i_acc1, ol_l_acc1, ol_i_clear, ol_i_glob |
| a global array's base is hoisted (`lda XBC,_ga`) and a byte offset becomes a second induction variable (`ld WA,0x0` before, `inc 0x2,WA` / `inc 0x4` in the latch); the access is `(XBC+WA)`                                                | fits   | ol_i_acc1, ol_l_acc1, ol_i_clear            |
| char arrays use the counter itself as the offset (`(XWA+DE)`, no second variable)                                                                                                                                                           | fits   | ol_c_acc1, ol_c_clear, ol_c_glob            |
| two accesses to the same element share one address (`lda XWA,XDE+BC`, then `(XWA)` twice)                                                                                                                                                   | fits   | ol_i_acc2, ol_l_acc2                        |
| latch: `inc 0x1,i`, `inc esz,offset`, `cp i,bound`, `j lt,body`                                                                                                                                                                             | fits   | every counted loop                          |
| a constant bound with an index used nowhere else: the counter disappears; the loop walks a pointer to an end pointer (`ld XWA,XBC / lda XBC,XBC+0x14 / add HL,(XWA+:2) / cp XWA,XBC / j ult`)                                               | fits   | ol_i_const, ol_l_const, ol_c_const          |
| a loop-invariant expression is computed once before the loop (`ld WA,(a) / muls XWA,(b)`)                                                                                                                                                   | fits   | ol_inv                                      |
| a pointer parameter indexed by i is not strength-reduced: `ld WA,i / exts XWA / add XWA,XWA / add XWA,p` each iteration                                                                                                                     | fits   | ol_ptr, ol_gptr                             |
| `while (k--)` and `while (*s++)` are rotated: `j test` into the bottom test                                                                                                                                                                 | fits   | ol_ptr_walk, ol_strlen                      |
| register choice: s in HL when returned directly; counter, bound, base, offset over IX/IY/IZ and WA/BC/DE, differing between examples (acc1: i IX, k DE, base XBC, offset WA; glob: k from a global in WA, base XDE, offset BC; clear: i HL) | open   | ol_*                                        |

## Hypothesis for the IZ / QIZ choice (not yet implemented)

The call tests fit a cost-based choice better than any fixed order.  QIZ cannot be pushed or compared with memory
directly (`ld WA,QIZ` first), so each such use of a QIZ variable costs an extra instruction per execution; a variable
in a stack slot costs a memory operand per use.  rc_loop1: putting i in IZ (QIZ for v0, pushed every iteration) and
putting v0 in IZ (QIZ for i, compared every iteration) each cost one extra instruction per iteration, and the oracle
picks v0 in IZ (a tie, broken by an order still unknown).  rc_loop2-4: i in IZ costs nothing extra, the last
local in QIZ is used as a register operand (`add WA,QIZ`, free), and the others stay in slots.  A model would
enumerate the few assignments of the candidates to {IZ, QIZ, slot}, weight each use by its loop depth, and take the
cheapest; the weights (instructions, bytes or cycles) are to be fitted to the oracle.

**Superseded (2026-11-09)** by a fitted priority rule: a cost model of this kind fitted worse than a greedy priority
list (research-scratch `sessions/2026-11-09_cc900-homes`, `fit_homes.py`, 200 hand-read values over 79 functions).
The rule now in the model is R3-set (`model/homes.py`):
- the score is reads + writes, less the costs fitted per option set;
- the order is by score under cdecl, and by score / live-range length (in quads) under adecl;
- IZ goes to the first candidate (XIZ if it is 32-bit), QIZ to the next 16-bit one by a pair test.

`codegen.plan_homes` uses it under no options, `-Xr` and `-O3 -XS -Xr` (ledger: micro_ra none 29 -> 32 of 42,
ra_homes none 9 -> 10, ra_chains Xr 25 -> 26 and O3XSXr 27 -> 28; no row fell).  Under cdecl `-O3 -XS` the first
fit's rule stays: R3-set with two refinements gets 142 of 158 values right there, against 132 for R3-set and 94 for
the first fit. The refinements, both in `homes.py` (fit by `fit_o3xs_counter.py`):
- a parameter read only as a loop bound is no candidate when a local that is more than a counter competes;
- an accumulator `s += g1(i)` takes no QIZ.

It still loses 4 listings of the 1997 library: `_strlen`, `_calloc`, `_strcmp`, `_modf`.

**R4 (2026-11-09, research-scratch `1baf8a7`, `fit_o3xs_uses.py`)** replaces it under cdecl `-O3 -XS` whenever a
32-bit value is a candidate.  Fitted on run `2026-11-09-14-micro-libshapes` and the library, it gets 203 of 213 O3XS
values right, with all five library routines.  It orders by how each value is used (`homes.uses`):
- **Demoted:** a 32-bit local passed to a call or read inside an `if` arm; a 32-bit parameter read as an operand
  inside an arm; a 16-bit parameter not passed directly before its first call.
- **Class 0:** a parameter passed as an argument after its first call (outside any arm when it is 16-bit).
- **Then:** score, span, locals before parameters.

Without a 32-bit candidate `homes.choose` returns None and the first fit's rule decides (`rh_lp`, `sv_keep_across`).
Ledger: ra_libshapes O3XS 11 -> 14, homes32 O3XS 4 -> 6 and O3XSXr 5 -> 6, library 149 -> 150 (v4.23) and
147 -> 148 (kn5000).  Pairs: `_memccpy` x9, 176 -> 185.  `homes.py`'s features agree
with the hand counts for 318 of 324 values (`check_model_features.py`).  The 6 that differ:
- the -O copy merge (`rc_keep1-4`);
- the -O tail merge (`h_mc`, `h_mc_int`);
- `n-- > 0` (`rc_while2`);
- `rc_two_loops`' counter.

## Leaf loops under `-O3 -XS -Xr`: parameters that arrive in registers (run 2026-11-09-5-micro-optparams)

Data for the next allocator step (the model scores 0 of 24 here).  Each parameter arrives in WA / BC / DE; the loop
needs a temporary family T for the `n--` copy (`ld T16,n / dec n / cp T16,0x0`) and, when a byte is copied, for the
byte (T8).  The allocator picks T and moves out whichever parameter held it:

| function       | arrival                      | after allocation   | T          |
|----------------|------------------------------|--------------------|------------|
| `op_cpy_ab`    | a XWA, b XBC, n DE           | a XDE, b XBC, n HL | WA / A     |
| `op_cpy_nab`   | n WA, a XBC, b XDE           | n WA, a XBC, b XHL | DE / E     |
| `op_cpy_anb`   | a XWA, n BC, b XDE           | a XWA, n BC, b XHL | DE / E     |
| `op_cmp_ab`    | a XWA, b XBC, n DE           | a XWA, b XHL, n DE | C          |
| `op_two`       | a XWA, b XBC                 | a XDE, b XBC       | A          |
| `op_two_loops` | a XWA, b XBC                 | unchanged          | C (at end) |
| `op_fill`      | a XWA, n BC, c E             | unchanged          | HL         |
| `op_fill2`     | c A, n BC, a XDE             | unchanged          | HL         |
| `op_sum2`      | p XWA, q XBC, n DE           | unchanged, s HL    | IX         |
| `op_three`     | d XWA, s XBC, t XDE, n stack | n IX               | HL / L     |
| `op_heavy_a`   | a XWA, b XBC, n DE           | b XIX, s HL        | BC / C     |
| `op_ret_a`     | a XWA, b XBC, n DE           | b XIX, r XHL       | BC / C     |

So a free register is used when there is one (HL, IX); otherwise one parameter's register is taken, and which one
is not yet clear: WA in `op_cpy_ab` (two moves, a to XDE and n to HL, where taking DE would have needed one) but DE
in `op_cpy_anb`.  A preference order for T (WA, DE, BC ...) combined with "the counter keeps its register" fits most
rows; `op_cpy_ab` against `op_cpy_anb` is the case to explain first.

## The rule, fitted (2026-11-09): R6

research-scratch `sessions/2026-11-09_cc900-leaf-temps` (commit `1105e3d`; `fit.py`, `leaf-temps.csv` derived from
runs `2026-11-09-5-micro-optparams` and `2026-11-09-11-micro-opttemps`) found a rule that reproduces all 62 O3XSXr
rows and, with different candidate lists, all 38 plain-Xr rows.  It is in `leafalloc.py` (docstring) and used by
`codegen.leaf_r6`: the loop body's kind (move, heavy, cmp, cmp2, arith, move3, count, word, none) gives T's
candidates; a candidate's occupant moves to reloc(candidate) (WA -> DE, HL; BC -> HL, IX; DE -> HL); the counter is
never T's victim (it moves and its family is barred); a returned local reserves HL; the entry moves are
sequentialised in parameter order.  The code generator then uses T for the `n--` copy, the moved or compared byte,
and after the loop the first of WA, BC, DE, HL whose variable is not needed again.  opt_temps.c 38 / 38,
opt_params.c 22 / 24 under O3XSXr: loops with no temporary are skipped when choosing the kind (op_cat), a
counter in `n-- && ...` counts, `*a == *b && *a` is cmp2, a stack counter goes to the first free of DE, HL, IX, IY
(op_three: `ld IX,(XSP+0x4)`, `retd 0x2`), the 16-bit temporary of a word body is T (op_sum2: IX).  Left: the two
`heavy` bodies, where `a[1]`'s address goes to T and `a++` moves up before the load.

Plain `-Xr` (rule R1 of the same fit, in `leafalloc.choose(opt=False)`): WA for move / heavy / arith / cmp2, BC for
cmp, no counter clause, relocation WA -> DE, HL, IX, BC -> DE, HL, IX, DE -> HL, IX, and the returned local keeps HL.
A `while` whose condition compares two bytes is rotated without `-O` too (ot_cmp_*, ot_len2); `n--` and `*s++` tests
are repeated in front (ctrl.c c_cnt, c_clear).  A jump to an exit that is only `ret` is `ret cc`; in
`gc = *a + *b` the operand whose dying pointer holds the target family is loaded first (`ld C,(XBC)` /
`add C,(XWA)`).  opt_temps.c under `-Xr`: 33 / 38.

## Counted loops under `-O3 -XS -Xr`: rule U1 (2026-11-09)

research-scratch `sessions/2026-11-09_cc900-counted-loops` (commit `6357bd2`; data from runs
`2026-11-09-12-micro-optcounted`, `2026-11-08-9-micro-optloops`, ctrl.c / mem.c) fitted one allocator for counted
`for` loops: 61 / 64 rows under O3XSXr, 63 / 65 under Xr, 58 / 64 under O3XS (its README states it in full: object
classes visited in a fixed order, each object the first free of WA, BC, DE, HL, IX, IY, IZ).  `codegen.leaf_u1`
implements the part for one loop over pointer parameters under O3XSXr: parameters keep their registers, a returned
variable (an accumulator, or the counter itself in `oc_find`) takes HL, then the byte temporary (C, evicting BC's
parameter to the first free of DE, HL: `ld XHL,XBC`) or the index chain (`ld DE,IX` / `exts XDE` / `add XDE,XDE` /
`add XDE,XWA` / `(XDE)`), then the other locals in reverse declaration order, then the counter; a char array is
indexed `(Xp+i)`.  opt_counted.c O3XSXr 2 -> 24 of 32; micro O3XSXr 632 -> 635.  (Then not yet, all
added later the same day, see below: a long constant store's temporary class, two arrays (the held address copy),
down-counting loops, nested loops, the `ldirw` block copy, and the Xr variant.)  Under cdecl `-O3 -XS` (`leaf_u1_cdecl`): the bound gets a register loaded just before
the first test, a pointer read once per iteration is reloaded at each use (a chain operand: `ld XDE,(XSP+0x4)` /
`add XWA,XDE`; a direct base: `ld XDE,(XSP+0x4)` / `ld XWA,(XSP+0x8)` / `ld A,(XWA+HL)`), the first temporary takes WA;
opt_counted.c O3XS 2 -> 16 of 32.

Since 2026-11-09 (later the same day) the allocation itself is `model/u1alloc.py`, a port of the session's engine
(`fit.py`): objects in classes visited in U1's order, the first free register at each object's width, Q halves, bytes
A W C B E D L H, the returned-sum HL / L preference, the byte temporary C with BC's parameter evicted to DE / HL.
codegen.py builds the objects from the C and calls it from four places:
- `u1_global` (via `plan_leaf` and `counted_loop`): -O counted loops over global arrays, both ABIs.  The first
  temporary is the shared element address (ra_leaf2 `lda XBC,XIX+DE`), a long constant (ol_l_clear `ld XBC,0x0`) or
  a loaded value (ol_i_copy, ol_idx_use `ld BC,(XIX+DE)` / `muls XBC,IY`); one offset IV per element size and the
  bases in first-use order (an assignment's source first: ol_l_copy `lda XIY,_gb` / `lda XIX,_gla` / `ld DE,0x0` /
  `ld HL,0x0`, the increments in reverse); the while / do forms (ol_while, ol_do, which has no guard and no exit
  label); nested loops with the base hoisted out of the inner one only (ol_nested); `for (i = k; i > 0; i--)`
  (ol_down: `ld DE,WA` / `cp DE,0x0` / `ret le` / `lda XBC,_ga` / `ld WA,DE` / `add WA,WA` / ... / `dec 0x2,WA`).
  Under cdecl the bound is a kept parameter (`ld IX,(XSP+0x4)` before the guard), a do loop's bound stays on the stack
  (`cp DE,(XSP+0x4)`), the byte temporary is A.
- `leaf_u1_adecl` / `leaf_u1_cdecl` (via `leaf_u1`): loops over pointer parameters, -O and plain -Xr.  A long
  constant is the first temporary (oc_clr_l `ld XDE,0x0` under -Xr, `ld XWA,0x0` under cdecl), two int arrays get the
  held copy (oc_add2 `ld XIY,XHL` / `add XIY,XWA` / `add XHL,XBC` / `ld HL,(XHL)` / `add (XIY),HL`; plain -Xr
  recomputes the scaled index), nested loops take the counters in reverse declaration order (oc_nested j IY, i IZ),
  `for (i = n - 1; i >= 0; i--)` frees n's register (oc_down: -O3 -XS -Xr `ld DE,BC` at entry and `dec 0x1,DE` / `j
  L1` that the tail merge must not fold; plain -Xr `sub DE,0x1` / `ret lt`), `if (p[i] > m) m = p[i]` loads the
  element once into the chain register (-O only), a global pointer is a chain operand (`add XBC,(_gp)`).  Under
  cdecl a parameter used twice is kept and loaded at its first use (oc_max), one read once per iteration stays on the
  stack (oc_find `cp WA,(XSP+0xa)`), a chain operand's reload takes the first free of WA BC DE HL, else is read as a
  memory operand (oc_nested `add XWA,(XSP+0x4)`).
- `u1_plain_global`: plain -Xr loops over global arrays.  Each access rebuilds its address (`ld BC,IX` / `add BC,BC`
  / `lda XDE,_ga` / `(XDE+BC)`); the access computed last gets the first temporaries (ol_i_copy: gb's HL / XIX come
  first in the code, ga's BC / XDE first in the allocation; ol_two_arr likewise).
- `leaf_u1_noarr`, `u1_down2`, `u1_block_copy`: `s += b * c` with b, c parameters is hoisted under -O (ra_param3
  `muls XBC,DE` after the guard; cdecl ol_inv `ld WA,(XSP+0x6)` / `muls XWA,(XSP+0x8)`, class inv) and a value
  temporary otherwise (`ld IX,BC` / `muls XIX,DE`); `for (; n > 0; n--) s += p[n - 1]` (oc_down2, -Xr only: the
  derived IV n - 1 under -O); a char copy of an even constant count from a global array to a pointer parameter is
  `ldirw` of words under -O (oc_cpy_g).
- -O, one char element read by several statements (`U1_BYTE_CSE`): loaded once into the byte temporary (C, cdecl A)
  and the accumulators packed in byte halves, high ones included (ol_c_acc3: s0 H, s1 L, s2 B; cdecl s2 W; FAM has
  entries W, B, D, H for them); the returned sum is added in place, `add H,L` / `add H,B` / `ld L,H`.
Switches `U1_CDECL_GLOBAL`, `U1_PLAIN_XR` and `U1_BYTE_CSE` turn those parts off.  Not implemented: the README's
exceptions (three reads of one wide global with the base copies and Q halves, ra_leaf3..5 and ol_*_acc3; ol_two_arr
under -O; cdecl oc_sum2 / oc_add2 and ol_l_copy; plain -Xr oc_clr_l), cdecl oc_down2 (its reload takes IX, against
the WA..HL rule above), nested loops without arrays under cdecl (ra_nested).  Results (`sh model/ledger.sh`):
opt_counted.c O3XSXr 24 -> 32 / 32, O3XS 16 -> 29, Xr 11 -> 31; opt_loops.c O3XS 16 -> 27 / 33, O3XSXr 14 -> 29, Xr 10 ->
30; ra_*.c O3XSXr 13 -> 18 / 42; micro O3XS 671 -> 672, Xr 673 -> 674 (ctrl.c c_find, c_copy).

## cdecl -O leaf (old path): register order, a hypothesis that failed (2026-11-09)

The old -O leaf path (`plan_leaf`) gives registers to locals before parameters, each in reverse declaration order
(`_strcat`: s, s2, s1).  `_strspn` does not fit: the oracle has s1 in XBC and the local s in XDE.  Ordering every
candidate by its first reference in the source instead fits `_strspn` and `_strcat`, but sh model/ledger.sh fell
sharply: opt_params O3XS 21 -> 5 of 24, library 169 -> 165.  So the order is not first use.  The change was
reverted and `_strspn` is still open.
