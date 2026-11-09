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
