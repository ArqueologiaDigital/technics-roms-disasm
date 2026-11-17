# Round 19 for lane_sub's helpers (read BRIEF.md, ROUND14.md, ROUND16.md, ROUND17.md and ROUND18.md first)

State: 477 functions per tree are built from C (v142/subcpu/cc900/*.c).  Round 18 (run
~/compartilhado/cc900-oracle/runs/2026-11-17-7-sub-r18, listings out/v423/Xr/sub/sub_<TAG>_18<form>.asm, verdicts
notes/cc900-c-subcpu-2026-11-16/verdicts/2026-11-17-7-sub-r18.tsv) matched 30 of 76; your prompt names the
functions it left open with their best form.  Pools: notes/cc900-c-subcpu-2026-11-16/pools/pool_<P>_remaining.txt
(regenerated; routines with `link` / `unlk` frames are out: another compiler's convention).

Tools, now committed in notes/cc900-c-subcpu-2026-11-16/helper-generators/: idiff.py (helper P's instruction-level
diff) and ctx.py (helper S's, with context).  Read them before use; copy into your scratch dir to change them.

What round 18 taught:
(x) DSP_BytecodeInterpreter_Init (1,933 B): the byte local declared BEFORE the scratch pointer local moved the
    pair to the ROM's registers (C and XWA).  Declaration order does matter for some pairs of temporaries.
(y) A switch whose case bodies sit under labels of their own is ONE C function from its first label to the end
    of its last case body; the checker compares that whole length, and the build keeps the inner labels as
    `.set` offsets.  First run notes/cc900-c-subcpu-2026-11-16/span_refs.py FILE.s START END TABLE: an inner label
    that anything outside the function (other than its own case table) names is a real separate function, and the
    split stays there.  Checked: Voice_CtrlChange (.. Voice_ChanPressure, table Voice_CC_Mode_CaseOffsets) and
    Voice_SystemMsg (.. Voice_ResetAllControllers, table Voice_SystemMsg_CaseOffsets): no outside reference, so
    each is one function.  Its case table gets a `/* cc900-data: FUNCTION 1 = TableLabel */` line.

Floating point at -Xr:
- A function with the register convention may NOT return float or double (THC1-Error-373 "Illegal function
  return type", prototypes included).  A `__cdecl` one may.  The library: `extern double __cdecl pow(double,
  double);` (sin, cos, tan, fabs, exp, log, frexp, ldexp, modf likewise).
- Arithmetic, compares and conversions are plain C operators on float / double: V4.23 calls its library with
  addresses (XWA destination, XBC / XDE operands), as the ROM's callers do.
- The checker maps V4.23's names to the tree's FP_* labels as CANDIDATES (._fmul_d -> FP_dmul, ._fld_df ->
  FP_ftod, _pow -> FP_pow, ...; list in notes/cc900-c-subcpu-2026-11-16/sub_v423.py).  A match confirms them.
- Floating constants (the ROM's FPConst_* / FP_Const_* labels) are V4.23 constant data: each needs a
  `/* cc900-data: FUNCTION N = Label */` line (N counts the function's constant objects in order).

Files sub_<TAG>_19a.c, _19b.c, _19c.c; one spelling of each function per file.  Check each with
    bash notes/cc900-c-subcpu-2026-11-16/syntax_check.sh FILE.c
