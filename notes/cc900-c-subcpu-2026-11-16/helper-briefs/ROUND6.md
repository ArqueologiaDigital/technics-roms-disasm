# Round 6 for lane_sub's helpers (read after BRIEF.md and ROUND3-5.md)

Round 5 ran as oracle run 2026-11-16-65-sub-r5 (listings .../runs/2026-11-16-65-sub-r5/out/v423/Xr/sub/).  Verdicts:
~/compartilhado/tmp/cc900-tab/lane_sub/r5_<TAG>.tsv.  17 of 74 matched, 1,056 B; staged.  244 functions are staged and
verified in all three trees (12,021 B each).

New facts:
- `__XIZ` CRASHES V4.23: every file that used the pseudo-register __XIZ (sub_B_5a/b/c, sub_C_5b/c, and round 4's sub_C_4c)
  died with a wine page fault (read at 0); their listings are cut off, so none of their functions has a verdict.  `__IZ`
  alone is fine (ToneGen_WriteSingleReg / _WriteExprReg matched with it).  Do not use __XIZ.  For a pointer the ROM keeps
  in XIZ, find another spelling in plain C (e.g. a pointer local V4.23 may put in XIZ when XIX / XIY are taken).
  One or two tries, not more.
- The long-divide map is confirmed: `long / long` calls the payload's Long_SignedDiv (was Int_SignedDiv_AltEntry; it
  returns the quotient), `long % long` Long_SignedRem (was Int_SignedDiv_ConstData).  DSP_PanScale_Simple and
  DSP_ParamInterp_2Point matched through it.
- SAME-MODULE CALLS ARE CHECKABLE: put `/* cc900-module: Label1 Label2 ... */` in the file, naming (by tree label) every
  callee the ROM reaches with calr / jr / jrl from the functions in the file; V4.23's `cal` / `j` to those become calr / jr /
  jrl.  A tail call `return f(...)` matched this way (RingBuf_ReadByte_MidiRing: `jr RingBuf_ReadByte`).  List only
  callees that really are calr / jr / jrl targets in the ROM; an absolute `call` target must not be listed.
  Your new pool: notes/cc900-c-subcpu-2026-11-16/pools/pool_<TAG>_rel.txt (calr-calling candidates; the last column
  lists each one's calr targets).  The routines you skipped for calr / jrl tails are in scope now too.
- A switch that V4.23 compiles to a jump table (`lda XIX,S5000x`) still cannot be checked (tool work pending).

Round 6: files sub_<TAG>_6a.c / _6b.c (/_6c.c).  Same rules; report as before.
