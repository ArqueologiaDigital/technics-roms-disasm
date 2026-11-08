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
