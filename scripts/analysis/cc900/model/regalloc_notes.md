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

## The homes2 rule, ported (`model/homes2.py`, 2026-11-10)

The fitted rule of research-scratch `sessions/2026-11-09_cc900-homes2` (README "The rule": a Chow-style priority
colouring of the values live across a call, score / span, interference by overlapping quad intervals, the IZ / QIZ
halves by a decision list) is `model/homes2.py`, linearizer included, with the fitted parameters embedded.
`codegen.plan_homes` hands a function to it when the policy `codegen.HOMES2` (environment `CC900_HOMES2`) says so,
and applies its answer with the same bookkeeping as `homes.py`'s: the rule may home only plan_homes's own
across-a-call candidates (`vals`); a losing adecl register parameter gets its slot store, a losing cdecl parameter
stays on the stack, a losing local gets a frame slot; the hidden result pointer stays with `fpgen.needs_sret_home`
(the rule's `.sret` part, `SRET_AS_VALUE` off).  Two things were changed from the session's `lin.py`: an operand
that calls is linearised before its siblings are read (`CALL_FIRST`; `a + b + (x > 0.0)` in probes/adfp.c ad_idi
keeps `a` across the helper, as cc900 and codegen do), and the `_VC` cache keyed by `id(fn)` is gone.  Read back
through each declaration's register (the session's `model_rule.py`), the port gives the rule's own homes on homes2a /
homes2b at all four sets (Xr and O3XSXr identical, none / O3XS a few better because `vals` drops some of the rule's
candidates); on the 1997 library's variables 164 of 198 against the rule's 155 and homes.py's 163.

Policies (`homes2.POLICIES`): `off`; `all`; `r4keep` (homes2 except where R4 answers: cdecl -O3 -XS with a 32-bit
candidate); `noO3XS`; `noopt` (none and -Xr only); `fallback` (only where `homes.choose` returns None); `noloop`
(functions without a loop); `noloop-r4keep`; `fallback-noloop`.  Measured with `model/ledger.sh`, `pairs_model.py`
and `semcheck.py` at the commit that adds this section; every ledger row not listed is unchanged, the 1997 library
rows (184 / 182 / 173 of 248) among them, and the firmware pairs are 223 MATCH under every policy:

| oracle, corpus                      | off       | all       | r4keep    | noloop    | noloop-r4keep | fallback | fallback-noloop |
|-------------------------------------|-----------|-----------|-----------|-----------|---------------|----------|-----------------|
| micro, v423/none                    | 674 / 674 | 673 (-1)  | 673 (-1)  | 674       | 674           | 674      | 674             |
| micro, ide2003/none                 | 670 / 674 | 669 (-1)  | 669 (-1)  | 670       | 670           | 670      | 670             |
| micro, v110/none                    | 667 / 674 | 666 (-1)  | 666 (-1)  | 667       | 667           | 667      | 667             |
| micro, v423/O3XS                    | 674 / 674 | 673 (-1)  | 673 (-1)  | 674       | 674           | 673 (-1) | 674             |
| micro, v423/Xr                      | 674 / 674 | 672 (-2)  | 672 (-2)  | 673 (-1)  | 673 (-1)      | 674      | 674             |
| micro, v423/O3XSXr                  | 674 / 674 | 673 (-1)  | 673 (-1)  | 674       | 674           | 674      | 674             |
| micro, ide2003/O3XS (ide2003)       | 672 / 674 | 671 (-1)  | 671 (-1)  | 672       | 672           | 671 (-1) | 672             |
| micro, ide2003/Xr (ide2003)         | 667 / 674 | 665 (-2)  | 665 (-2)  | 666 (-1)  | 666 (-1)      | 667      | 667             |
| micro, ide2003/O3XSXr (ide2003)     | 660 / 674 | 659 (-1)  | 659 (-1)  | 660       | 660           | 660      | 660             |
| micro-ra, v423/none                 | 34 / 42   | 31 (-3)   | 31 (-3)   | 34        | 34            | 34       | 34              |
| micro-ra, v423/Xr                   | 23 / 42   | 27 (+4)   | 27 (+4)   | 23        | 23            | 23       | 23              |
| abi, v423/none                      | 102 / 108 | 101 (-1)  | 101 (-1)  | 102       | 102           | 102      | 102             |
| abi-adecl, v423/Xr                  | 75 / 80   | 76 (+1)   | 76 (+1)   | 75        | 75            | 75       | 75              |
| abi-adecl, v423/O3XSXr              | 77 / 80   | 76 (-1)   | 76 (-1)   | 77        | 77            | 77       | 77              |
| ra_homes, v423/none                 | 13 / 25   | 12 (-1)   | 12 (-1)   | 13        | 13            | 13       | 13              |
| ra_homes, v423/Xr                   | 19 / 25   | 11 (-8)   | 11 (-8)   | 10 (-9)   | 10 (-9)       | 19       | 19              |
| ra_homes, v423/O3XSXr               | 23 / 25   | 13 (-10)  | 13 (-10)  | 16 (-7)   | 16 (-7)       | 23       | 23              |
| ra_chains, v423/Xr                  | 29 / 33   | 31 (+2)   | 31 (+2)   | 31 (+2)   | 31 (+2)       | 29       | 29              |
| ra_chains, v423/O3XSXr              | 29 / 33   | 31 (+2)   | 31 (+2)   | 31 (+2)   | 31 (+2)       | 29       | 29              |
| ra_homes32, v423/O3XSXr             | 13 / 17   | 12 (-1)   | 12 (-1)   | 12 (-1)   | 12 (-1)       | 13       | 13              |
| ra_libshapes, v423/O3XS             | 17 / 21   | 15 (-2)   | 17        | 15 (-2)   | 17            | 17       | 17              |
| regkw, v423/none                    | 0 / 12    | 8 (+8)    | 8 (+8)    | 8 (+8)    | 8 (+8)        | 0        | 0               |
| regkw, v423/O3XS                    | 2 / 12    | 10 (+8)   | 10 (+8)   | 10 (+8)   | 10 (+8)       | 10 (+8)  | 10 (+8)         |
| regkw, v423/Xr                      | 3 / 12    | 7 (+4)    | 7 (+4)    | 7 (+4)    | 7 (+4)        | 3        | 3               |
| regkw, v423/O3XSXr                  | 0 / 12    | 10 (+10)  | 10 (+10)  | 10 (+10)  | 10 (+10)      | 0        | 0               |
| homes2a, v423/none                  | 15 / 204  | 27 (+12)  | 27 (+12)  | 24 (+9)   | 24 (+9)       | 15       | 15              |
| homes2a, v423/O3XS                  | 8 / 204   | 9 (+1)    | 9 (+1)    | 8         | 8             | 9 (+1)   | 8               |
| homes2a, v423/Xr                    | 28 / 204  | 79 (+51)  | 79 (+51)  | 71 (+43)  | 71 (+43)      | 28       | 28              |
| homes2a, v423/O3XSXr                | 27 / 204  | 67 (+40)  | 67 (+40)  | 63 (+36)  | 63 (+36)      | 27       | 27              |
| homes2b, v423/none                  | 7 / 90    | 14 (+7)   | 14 (+7)   | 12 (+5)   | 12 (+5)       | 7        | 7               |
| homes2b, v423/O3XS                  | 7 / 90    | 12 (+5)   | 11 (+4)   | 10 (+3)   | 9 (+2)        | 11 (+4)  | 9 (+2)          |
| homes2b, v423/Xr                    | 11 / 90   | 26 (+15)  | 26 (+15)  | 24 (+13)  | 24 (+13)      | 11       | 11              |
| homes2b, v423/O3XSXr                | 11 / 90   | 23 (+12)  | 23 (+12)  | 21 (+10)  | 21 (+10)      | 11       | 11              |
| sum of all 131 rows                 | 10098     | +144      | +145      | +132      | +133          | +11      | +10             |

(`noO3XS` and `noopt` were measured in a first round before `CALL_FIRST`: `noO3XS` is `r4keep` without the O3XS
gains, `noopt` loses the O3XSXr gains as well; neither beats `r4keep` or `noloop-r4keep` on any row.)

What the rule loses, read from the listings (`research-scratch sessions/2026-11-10_tmp`, `lost_won.sh`):
- the adecl parameter against a local (`k_keep`, `rh_lp_x2`, `rh_lp_a2`, `rh_lp_call`, `rh_pp_b2`): cc900 gives the
  parameter IZ and the local QIZ; the rule colours the local first and, since a parameter never takes the second
  half, leaves the parameter in a slot.  homes.py's pair test (both get a register when their scores add up) has it;
- two locals computed from register parameters (`rh_ll*`, `rh_lll_z2`, `rh_llll`): the earlier-declared takes IZ
  (`ld IZ,WA / add IZ,BC`), where the rule's `decl` key, fitted on homes2a's global-operand families, gives IZ to
  the later one;
- loop counters and accumulators (`c_nested`: the outer counter takes IZ, the rule gives it to the inner;
  `rc_loop2-4`, `rh_loop*`, `sv_register`);
- a long call result against an unsigned parameter at -O3 -XS -Xr (`h_p_un`), and the 32-bit contests R4 decides
  (`ls_cl1_always`, `ls_mc_test`; `r4keep` keeps those).

**Adopted: `fallback-noloop`**, the one policy that moves no row down: homes2 decides cdecl -O3 -XS functions without
a loop where `homes.choose` returns None, which used to be the first fit's rule.  regkw O3XS 2 -> 10, homes2b O3XS
7 -> 9; library, pairs and every other row unchanged.  `r4keep` is the most the rule can give as it stands (+145,
homes2a Xr 28 -> 79, O3XSXr 27 -> 67, held-out homes2b +7 / +4 / +15 / +12) at the price of the first three
groups above, ra_homes O3XSXr 23 -> 13 among them; it is selectable, not adopted.  A refit that takes the
ra_homes / call.c shapes into the fit (the parameter-displaces-the-local rule, the halves order with register-parameter
operands, loop counters) is what would let the rule replace homes.py everywhere.

Not modelled by the port: the `.sret` value (left to `needs_sret_home`); QIZ as an arithmetic destination (the rule
only names the half, codegen's QIZ forms apply); compiler temporaries in XIZ (sqrt, `_fint`, `_trig`); the -O
transformations beyond the copy merge and the counted loop (the model's own COPY_PROP / U1 run before plan_homes, so a
value they fold is no candidate here either).  A second half-holder with a disjoint interval is allowed (the rule
shares a half between values dead around each other); codegen then loads the half at each definition.

semcheck (`--ledger --library`, 48 trials per function) at the same commit: `off`, `all` and `fallback-noloop` all
report DIFFERENT 2 / 3 / 0 / 0 (none / O3XS / Xr / O3XSXr), the same five functions as the committed
`results/semcheck.md` (`__trig`, reviewed; fpp7's `_w5` and `_w7` at none and O3XS): the rule wrote no new wrong
code at any policy.  `results/semcheck.md` is the `fallback-noloop` run.

## Leaf loops without options: rule LN1 (`model/leafnone.py`, 2026-11-09)

Fitted in research-scratch `sessions/2026-11-09_cc900-leaf-none` (`rule.py`, commit 3d847d0) on 275 leaf functions
with a register variable (the micro corpora and the probes `lnr.c`, `lnr2.c`, `lnr3.c`, runs 2026-11-09-31 to -33).
It reproduces all 275 there (624 of 624 variables); the model's own rule got 165.  On `lnr4.c`, written afterwards
and run as a held-out check (run 2026-11-09-34), it predicted 9 of 18 functions before six fixes and 15 of 18
after, so expect misses on new code.  The parts that are descriptions rather than mechanisms: the soft
temporaries, the early / late split of pointer parameters, and the order of variables born inside a loop.

`plan_leaf` (no options, cdecl, a loop, no call) still decides which variables get a register; LN1 then chooses
their registers (`LEAF_NONE_LN1`).  When LN1 wants a Q register or none, the model's choice stays.  Two templates
had to follow it:
- a copy between two global-array elements puts the store address in DE / XHL (`COPY_ELEM_DE`; `ol_i_copy`:
  `ld DE,IX / add DE,DE / lda XHL,_gb / ... lda XBC,_ga / ld (XHL+DE),WA`);
- a member through a pointer in a register is addressed directly (`REG_MEMBER`; `ae_fl_chain`:
  `cpw (XBC+0x4),0x4 / ld XBC,(XBC)`).

`STORE_ADDR_GUARD` refuses a store whose value overwrites the store address's registers (it turned the 1997
library's `__doudigit` at -O3 -XS from wrong code into "unsupported").  Ledger (none): micro_ra 33 -> 34, opt_counted
25 -> 27, cond_bits 113 -> 114, assign_expr 30 -> 31, opt_loops 23 -> 27; no row fell.

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
