# Toshiba cc900 V4.23: compiler bugs found by the compatibility work

Miscompiles of the Toshiba TLCS-900 C compiler V4.23 (the oracle of phase 3a), each found while imitating it.  A
"bug" here means V4.23's code computes something other than what the C source means, for inputs where C defines the
result; undefined behaviour (overflow, out-of-range indexes, a value-returning function that falls off its end) is not
counted.  The oracle's listings stay in the private `~/compartilhado/cc900-oracle` repository; this page describes
the code in prose and names the run and function where it can be read.

**Policy (owner, 2026-11-16): case by case.**  The model reproduces a V4.23 bug only when real firmware needs it to
match; otherwise it emits correct C.  The current treatment of each bug is in its "model" line; a bug the model does not
reproduce is a function the model can never match byte for byte.

Add every new one here, in the commit that finds it.

| #  | bug                                                                                           | option sets          | found                                  | model                      |
|----|-----------------------------------------------------------------------------------------------|----------------------|----------------------------------------|----------------------------|
| 1  | a char product widened to long keeps only its low byte                                        | all four             | 2026-11-13, probe chararith.c          | reproduces it              |
| 2  | two equal switch arms merged; one case loses its call                                         | -O3 -XS -Xr          | 2026-11-15, rstmt2.c (semcheck review) | does not reproduce it      |
| 3  | -Xr small struct: caller and callee disagree on stack order                                   | -Xr, -O3 -XS -Xr     | 2026-11-16, probe sxl.c                | reproduces the caller side |
| 4  | char pointer + negative int or char index zero-extended                                       | all four             | 2026-11-16, probes ptrar.c, stptr.c    | reproduces it              |
| 5  | -O: char pointer difference compared with 0 unsigned                                          | -O3 -XS, -O3 -XS -Xr | 2026-11-16, probe ptrar.c              | refuses the shape          |
| 6  | struct pointer + char index, 10-byte element: low word of the product, zero-extended          | all four             | 2026-11-16, probe ptrar.c              | refuses the shape          |
| 7  | a shifted or divided char compared with a char of the other signedness, at the byte, unsigned | all four             | 2026-11-16, probe shcmp.c              | refuses mixed signedness   |
| 8  | -O: op= on a 1-bit bit-field at bit 15 flips bit 7 of the unit's low byte                     | -O3 -XS, -O3 -XS -Xr | 2026-11-16, probe bitf.c               | refuses the shape          |
| 9  | an unsigned char plus a constant computed at the byte, wrapping at 256                        | all four             | 2026-11-16, training pool rstmt11.c    | computes correct C         |
| 10 | -O3 -XS -Xr: an argument register overwritten before it is read (a shift count)               | -O3 -XS -Xr          | 2026-11-16, training pool rstmt10.c    | refuses or computes C      |
| 11 | the code generator crashes on a loop bound of a constant pointer plus an offset               | all four             | 2026-11-16, phase 6 (p6_m4)            | the model compiles it      |

## 1. A char product widened to long keeps only its low byte

- **Source:** `long gl; char gc, hc; void ca_mss_sl(void) { gl = gc * hc; }` (corpus/probes/chararith.c; the `sl`
  context, and likewise `sr sd sm cm ng su` -- see research-scratch tabulation/chararith-FAMILIES.md).
- **C meaning:** `gc * hc` is an int product (both operands promoted), so `gl` receives the full 16-bit product,
  sign-extended: `gc = hc = 16` gives 256.
- **V4.23:** multiplies the two bytes into a 16-bit register pair, then sign-extends the *low byte* of that product to
  16 bits before widening to 32, discarding the product's high byte: `gc = hc = 16` stores 0, `gc = 100, hc = 3` stores
  44.  In other contexts (`ri si pa ar xi ml`) the same product is kept as an int, correctly.
- **Evidence:** oracle run 2026-11-13-8-micro-chararith, function `_ca_mss_sl` at every set.
- **Model:** reproduces it -- the per-context `wide` table of the chararith predictor (the one table-driven rule
  there), so these functions are exact.  No firmware function is known to depend on it.

## 2. Two equal switch arms are merged and one case loses its call

- **Source:** rstmt2.c `rs_2_04_03_3`, a `switch` whose `case 2:` and `case 3:` both call `vs(gps)` (with fall-through
  structure from the generator).
- **C meaning:** for the case-2 value the function calls `vs`.
- **V4.23 at -O3 -XS -Xr:** merges the two identical arms and sends case 2 to the default arm, so no call is made for
  that value (semcheck: "calls: model 1, oracle 0").  The other three option sets compile it correctly.
- **Evidence:** oracle run 2026-11-13-7-micro-rstmt, O3XSXr, `.rs_2_04_03_3`; reviewed in
  `scripts/analysis/cc900/model/semcheck_review.tsv`.
- **Model:** compiles correct C; the function stays DIFFERENT in semcheck (one of the 9 reviewed verdicts) and cannot be
  exact.

## 3. -Xr: a small struct in a register position, caller and callee disagree

- **Source:** corpus/probes/sxl.c, e.g. `void x_b(struct s4 s, double d)` called as `x_b(g4, gd)`; 12 parameter lists,
  each as a definition and as a call.
- **C meaning:** the callee receives `s` and `d` as passed.
- **V4.23 with -Xr (adecl):** a struct of 4 bytes or less in one of the first three (register) argument positions is
  passed on the stack.  The *callee* reads every stack argument at its left-to-right place; the *caller* pushes such a
  struct last, after every other stack argument, among the register loads.  Whenever the struct precedes another stack
  argument (7 of the 12 lists: a, b, e, h, i, j, k; first seen in probe stc, `.st_pc_1..4`) the two disagree and the struct and the next stack argument
  exchange places: in `x_b` the caller puts the struct where the callee reads the double.  Structs over 4 bytes, or past
  the third position, keep the left-to-right order on both sides.
- **Evidence:** oracle run 2026-11-16-2-micro-sxl, Xr and O3XSXr, functions `.sx_c_*` (callers) and `.sx_d_*`
  (callees); lane_o3 fix 12 (batch 350) and research-scratch tabulation/lanes-2026-11-15/lane_o3/RULES.md.
- **Model:** reproduces the caller side (STRUCT_REG_SLOT_PUSH), so the probe's callers are exact; its callees follow the
  left-to-right layout, as V4.23's do.  Code mixing V4.23-compiled callers and callees of this shape is wrong either way.

## 4. A char pointer plus a negative index is zero-extended

- **Source:** `char *gcp; char *pa_cgpa(int b) { return gcp + b; }` and the like (corpus/probes/ptrar.c: pa_cgpa,
  pa_cqpa, pa_cgga, and pa_cgca with a signed char index; corpus/probes/stptr.c: sp_cQpa `q[b] = 5`, sp_cQpb;
  corpus/micro/arr_index.c: ai_c_p_p1 `return p[i + 1]`, ai_c_p_st_m1 `p[i - 1] = x`, at none and -O3 -XS).
- **C meaning:** `p + i` with a negative `i` points before `p`, which is defined whenever `p` points into the middle of
  an array.
- **V4.23:** widens the index to 32 bits with a zero extension in some homes and contexts and with a sign extension in
  others.  For `p + i` with `p` a char pointer and `i` a signed int (probe psum.c, 140 functions, all four sets):
  - **returned** (`return p + i`): zero-extended, whatever the operands' homes;
  - **stored into a pointer** (`gp2 = p + i`): sign-extended, correctly;
  - **in an argument, a local's initialiser, or a store through the sum** (`vp(p + i)`, `char *w = p + i`,
    `*(p + i) = 5`): zero-extended when the pointer or the index is a cdecl stack parameter (under -O, a local copied
    from a stack parameter counts as one); sign-extended, correctly, when both are locals, globals or -Xr register
    parameters (`ld XWA,(u) / ld BC,(i) / lda XWA,XWA+BC`, or the (XR+R16) indexed form for a store).
  A signed char index is zero-extended as a byte (`+ 256` for a negative one) except when the sum is stored into a
  pointer.  An unsigned index is zero-extended (correct), and `p - i` is sign-extended (correct).  So `p + i` for `i < 0`
  yields `p + (i + 65536)` exactly in the zero-extending cases.  This is not a uniform "indexes are unsigned"
  convention; it may still be a documented limitation of V4.23 (to check against the compiler manual).
- **Evidence:** oracle runs 2026-11-16-16-micro-psum (the home and context split, all four sets: `_ps_qba` / `_ps_gba`
  zero-extend and `_ps_gga` / `_ps_lla` sign-extend at none, `_ps_*r` zero-extend and `_ps_*s` sign-extend everywhere,
  `.ps_gba` sign-extends at -Xr), 2026-11-16-3-micro-ptrar (all four sets), 2026-11-15-8-micro-stptr (all four sets),
  2026-11-09-24-micro-arrindex (none, O3XS); and in random code, run 2026-11-16-4-micro-pool9-12: rstmt10.c
  `rs_10_02_13_2` (`char *u = gs.p + a;` with `a` a stack parameter, none and O3XS), rstmt11.c `rs_11_05_01_5`
  (`return gp + t;` with a char t, Xr and O3XSXr), and rstmt9.c `rs_9_08_04_3` (`vp(u + i)` with locals u and i:
  sign-extended, no bug).  Reported by lane_nm.
- **Model:** reproduces it where V4.23 does it (PTR_CTX, chidx; lane_nm rules 15 and 28, CHAR_IDX_SIGN and
  CHAR_SUM_HOME, batch 366: the home and context conditions above), except under -O for a local copied from a stack
  parameter, where the model computes correct C.  Firmware code indexing a char pointer backwards would need this to
  match.

## 5. Under -O, a char pointer difference compared with 0 is compared unsigned

- **Source:** `int pd_cg(char *q, char *r) { return (q - r) > 0; }` (corpus/probes/ptrar.c).
- **C meaning:** 1 when `q` is above `r`, else 0.
- **V4.23 at -O3 -XS and -O3 -XS -Xr:** computes the 32-bit difference and sets the result with an unsigned
  greater-than, so it returns 1 whenever `q != r`, including `q < r`.  none and -Xr use a signed compare (right); for
  int pointers the difference is divided first and the signed compare is right at every set (pd_ig).
- **Evidence:** oracle run 2026-11-16-3-micro-ptrar, O3XS / O3XSXr, `pd_cg`.  Reported by lane_nm.
- **Model:** refuses the shape at -O (lane_nm rule 23 PTRDIFF_CMP_OPT); does not reproduce it.

## 6. A struct pointer plus a char index with a 10-byte element keeps only the low word of the product

- **Source:** `struct s10 { int a[5]; } *gsp; struct s10 *pa_sgca(char cb) { return gsp + cb; }` (corpus/probes/ptrar.c:
  pa_sgca, pa_sqca).
- **C meaning:** `gsp + cb` is `gsp` plus `10 * cb` bytes, negative for a negative `cb`.
- **V4.23:** sign-extends the char, multiplies by 10 with a 16-bit signed multiply, then keeps only the low word of the
  product and zero-extends it: for `cb < 0` the result is `p + (10 * cb + 65536)`.  `p - cb` sign-extends the product and
  is right.
- **Evidence:** oracle run 2026-11-16-3-micro-ptrar, all four sets.  Reported by lane_nm.
- **Model:** refuses the shape (lane_nm rule 21 declines a char index over a non-power-of-two element); does not
  reproduce it.

## 7. A shifted or divided char compared with a char of the other signedness is compared at the byte, unsigned

- **Source:** corpus/probes/shcmp.c (gen_shcmp.py), e.g. `int sc_p_s1_ge_S_v(unsigned char a, signed char sc) { return
  (a >> 1) >= sc; }` and `int sc_p_D2_ge_c_v(signed char sa, unsigned char c) { return (sa / 2) >= c; }`; the same with
  `<` and `==`, `/ 2`, globals instead of parameters, and as a branch.
- **C meaning:** both sides are promoted to int and compared signed: `(a >> 1) >= sc` with `sc = -1` is true;
  `(sa / 2) >= c` with `sa = -2, c = 0` is false (-1 >= 0); `(sa / 2) == c` with `sa = -2, c = 255` is false.
- **V4.23, all four option sets:** keeps the shifted / divided char in A and compares it with the other char at the
  byte, with an unsigned condition whenever either side is unsigned: the three examples give false, true and true.
  Signed against signed (a signed condition) and unsigned against unsigned are right, and so is equality of `a >> 1`
  with a signed char (a byte of at most 127 never equals a negative one).
- **Evidence:** oracle run 2026-11-16-7-micro-shcmp, functions `sc_p_s1_ge_S_v`, `sc_p_s1_lt_S_v`, `sc_p_d2_ge_S_v`,
  `sc_p_D2_ge_c_v`, `sc_p_D2_eq_c_v`, `sc_p_D2_lt_c_v` and their `_b` / `sc_g_` forms.  Found by lane_o3 while checking
  phase 6's `VariScreen_IsHalfRangeAbove` shape (p6_m2a), whose operands are both unsigned, a case V4.23 gets right.
- **Model:** the byte compare is modelled where it is correct (both operands of one signedness); a mixed-signedness
  compare of this shape is refused, under the owner's case-by-case rule (no firmware function is known to need it).

## 8. At -O, op= on a 1-bit bit-field at bit 15 flips the wrong bit

- **Source:** corpus/probes/bitf.c (gen_bitf.py): `struct b1 { unsigned a:1; unsigned b:3; unsigned c:4; unsigned d:8; }
  gb1; void bf_b1_a_a(void) { gb1.a += 1; }`; likewise `gb4.x += 1` (the 1-bit field of a second unit, at +2), and
  `if (gb7.m < 0) gb7.m += 1;` / `if (gb7.m > -1) gb7.m -= 1;` on a signed 1-bit field.
- **C meaning:** the 1-bit field toggles; the other fields are untouched.
- **V4.23 at -O3 -XS and -O3 -XS -Xr:** turns the op= into a bit flip (valid in itself) but addresses the wrong byte.
  Bit-fields fill a 16-bit unit from the high end, so these fields are bit 15 of the unit, which on the little-endian
  TLCS-900 is bit 7 of the byte at unit + 1.  V4.23 flips bit 7 of the byte at unit + 0, i.e. word bit 7: the field never
  changes and a neighbouring field is corrupted (the top bit of `d` in b1, the low bit of `o` in b7).  The test of the
  signed variant reads bit 15 correctly.  Without -O (none, -Xr) V4.23 does a full read-modify-write of the unit, which
  is right.
- **Evidence:** oracle run 2026-11-16-6-micro-bitf, O3XS / O3XSXr, `bf_b1_a_a`, `bf_b4_x_a`, `bf_b7_m_a`, `bf_b7_m_o`.
  Found by lane_o3.
- **Model:** refuses a 1-bit bit-field op= at -O (case by case: no firmware need known).

## 9. An unsigned char plus a constant is computed at the byte and wraps

- **Source:** the training pool, corpus/probes/rstmt11.c `rs_11_00_05_2`: `guc = (255 + guc) / 7;` with `unsigned char guc`.
- **C meaning:** `255 + guc` is an int addition: `guc = 1` gives 256 / 7 = 36.
- **V4.23, all four option sets:** adds 0xff to `guc` in the byte register (A), so the sum wraps at 256, then
  zero-extends it and divides unsigned: `guc = 1` gives 0 / 7 = 0.
- **Evidence:** oracle run 2026-11-16-4-micro-pool9-12, `_rs_11_00_05_2` (and its `-Xr` forms).  Found by lane_nm in the
  pool's semcheck triage.
- **Model:** adds in a word (correct C); semcheck reports the function DIFFERENT, a known V4.23 bug.

## 10. At -O3 -XS -Xr an argument register is overwritten before it is read

- **Source:** the training pool, corpus/probes/rstmt10.c `rs_10_04_19_4`: `guca[6] = a = (3 >> (b & 7)) ^ guc;` with
  `unsigned char a` (in A) and `unsigned int b` (in BC) as -Xr register parameters.
- **C meaning:** the shift count is `b & 7`.
- **V4.23 at -O3 -XS -Xr only:** first copies `a` into C, over the low byte of `b`, then takes the shift count from BC,
  so the count is `a & 7` instead of `b & 7`.
- **Evidence:** oracle run 2026-11-16-4-micro-pool9-12, O3XSXr, `.rs_10_04_19_4`.  Reported by lane_nm from the pool's
  semcheck triage.
- **Model:** reads `b`, as C requires; semcheck reports the function DIFFERENT, a known V4.23 bug.

## 11. The code generator crashes on a loop bound of a constant pointer plus an offset

- **Source:** phase 6's reconstruction of StyleConv_ClearWorkBuffer's neighbours, corpus/firmware/p6_m4_sc_b.c:
  `void sc_b(void) { unsigned char *p; for (p = (unsigned char *)0x488c; p < (unsigned char *)0x488c + 32; p++) *p = 0; }`,
  and the same with `0x29f8 + 155` (p6_m4_va_b.c).
- **C meaning:** clears 32 bytes from address 0x488c.
- **V4.23, all four option sets:** thc2 (code generator 0.8n.04.11) takes a page fault reading the host address
  constant + 4 (0x4890): it dereferences the C constant pointer as a host pointer.  No code is emitted for the file;
  asm900 then rejects the output.  va_b at -O3 -XS exits 1 instead.  The same loop with an end-pointer variable
  compiles (sc_a, sc_c, va_a), so the firmware's own source must have been written that other way.
- **Evidence:** oracle runs 2026-11-16-12-p6-m4 (the crash, whole file) and 2026-11-16-14-p6-m4-split (one function per
  file).  Found by lane_p6.
- **Model:** compiles it (no crash to imitate).

## 12. The pseudo-register `__XIZ` crashes the compiler (candidate, not yet isolated)

- **Source:** the sub-CPU lane's probes that name V4.23's 32-bit pseudo-register `__XIZ`, to keep XIZ live around an
  inline-asm block (corpus/firmware/sub_B_5a.c, sub_B_5b.c, sub_B_5c.c, sub_C_4c.c, sub_C_5b.c, sub_C_5c.c).
- **C meaning:** `__XIZ` names the register as a variable; the 16-bit `__IZ` works and gives the ROM's save of XIZ
  (ToneGen_WriteVoice_Direct matches with it).
- **V4.23:** every file using `__XIZ` stops with a page fault reading address 0 under Wine and leaves a truncated
  listing.  Not yet reduced to a minimal case, so whether the compiler or its use of Wine is at fault is open.
- **Evidence:** oracle runs 2026-11-16-62-sub-r4 and 2026-11-16-65-sub-r5.  Found by lane_sub.
- **Model:** not applicable (paused); the C lanes use `__IZ` instead.
