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

| # | bug                                                         | option sets      | found                                  | model                      |
|---|-------------------------------------------------------------|------------------|----------------------------------------|----------------------------|
| 1 | a char product widened to long keeps only its low byte      | all four         | 2026-11-13, probe chararith.c          | reproduces it              |
| 2 | two equal switch arms merged; one case loses its call       | -O3 -XS -Xr      | 2026-11-15, rstmt2.c (semcheck review) | does not reproduce it      |
| 3 | -Xr small struct: caller and callee disagree on stack order | -Xr, -O3 -XS -Xr | 2026-11-16, probe sxl.c                | reproduces the caller side |

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
  argument (7 of the 12 lists: a, b, e, h, i, j, k) the two disagree and the struct and the next stack argument
  exchange places: in `x_b` the caller puts the struct where the callee reads the double.  Structs over 4 bytes, or past
  the third position, keep the left-to-right order on both sides.
- **Evidence:** oracle run 2026-11-16-2-micro-sxl, Xr and O3XSXr, functions `.sx_c_*` (callers) and `.sx_d_*`
  (callees); lane_o3 fix 12 (batch 350) and research-scratch tabulation/lanes-2026-11-15/lane_o3/RULES.md.
- **Model:** reproduces the caller side (STRUCT_REG_SLOT_PUSH), so the probe's callers are exact; its callees follow the
  left-to-right layout, as V4.23's do.  Code mixing V4.23-compiled callers and callees of this shape is wrong either way.
