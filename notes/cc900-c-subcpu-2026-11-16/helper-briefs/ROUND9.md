# Round 9 for lane_sub's helpers (read after BRIEF.md, ROUND3-8.md; the owner's rule in ROUND8.md stands)

Round 8 ran as oracle run 2026-11-16-82-sub-r8 (listings .../runs/2026-11-16-82-sub-r8/out/v423/Xr/sub/).  Verdicts:
~/compartilhado/tmp/cc900-tab/lane_sub/r8_<TAG>.tsv.  22 of 84 matched, 2,455 B; staged.  Before you start, re-read your
pool: notes/cc900-c-subcpu-2026-11-16/pools/pool_<TAG>_remaining.txt; skip anything now defined in
v142/subcpu/cc900/*.c or v142/subcpu/cc900-staged/*.c (`command grep -l '^.*\bNAME\s*(' ...`).

Checker changes since round 8: V4.23's `and QWA,n`, `ld r,IZL`, `push / pop QIZ` and the QIZH byte-register lines are
now translated; a conditional jr to a module-local label is no longer widened to jrl.  The cc900-module: comment is read
one line at a time: keep each list on one line (several one-line comments are fine).

Round 9: files sub_<TAG>_9a.c / _9b.c (/_9c.c).  Refine the closest round-8 misses, then new routines.  Same rules.
