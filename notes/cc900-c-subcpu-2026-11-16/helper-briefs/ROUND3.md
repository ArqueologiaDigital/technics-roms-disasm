# Round 3 for lane_sub's helpers (read after BRIEF.md)

Round 2 ran as oracle run 2026-11-16-47-sub-r2 (listings: ~/compartilhado/cc900-oracle/runs/2026-11-16-47-sub-r2/out/v423/
{Xr,O3Xr}/sub/sub_<TAG>_2{a,b,c}.asm).  Your verdicts: ~/compartilhado/tmp/cc900-tab/lane_sub/r2_<TAG>.tsv (function, bytes,
matches = file@set that MATCH, best_diff = furthest first-difference offset and where).  Overall 132 of 280 functions
matched, 4,301 B.  Every function that matched at Xr is now staged (v142/subcpu/cc900-staged/): do not repeat it.
Only Xr counts: the payload is -Xr.

New facts:
- `__ASM("\tnop")`: V4.23 copies the backslash-t into the listing literally and asm900 then stops with a syntax error, so
  every function of the inline-assembly files (sub_B_2c, sub_C_2c) failed.  Write the string without an escape: try a
  leading space (`__ASM(" nop")`) in one form and a real TAB character inside the quotes in another.  The `jr` to the
  next instruction may be `__ASM(" jr $+2")` (the checker maps `$` to llvm-mc's `.`) or a C idiom; keep both.
- float / double as a RETURN type is refused at -Xr (THC1-Error-373 "Illegal function return type"), so a file with
  such a function loses everything.  The DSP_*_FP routines must return through memory or an int.
- The checker now handles shifts by 16 (V4.23 writes the count 0).
- Calls are checked as absolute calls; a callee defined in the same probe file is fine for the check.
- A function V4.23 matched only at O3Xr is not counted (DSP_Set_MixParam_45B2: find the -Xr spelling).
- `__WA = 0;` (helper D) works: Debug_Print_Byte / Debug_Print_String matched with it.

Round 3: files sub_<TAG>_3a.c / _3b.c (and _3c.c).  First refine the misses that came closest (read V4.23's Xr listing of
your round-2 form beside the ROM's hand assembly; change types, signedness, test order, locals, operand order), then new
functions from your pool (the larger ones you skipped are welcome now).  Same rules as before; report as before.
