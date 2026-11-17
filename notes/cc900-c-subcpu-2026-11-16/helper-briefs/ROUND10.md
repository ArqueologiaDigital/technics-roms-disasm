# Round 10 for lane_sub's helpers (read after BRIEF.md, ROUND3-9.md; the owner's rule in ROUND8.md stands)

Round 9 ran as oracle run 2026-11-16-86-sub-r9 at -Xr, -O1 -Xr, -O2 -Xr and -O3 -Xr.  Verdicts:
~/compartilhado/tmp/cc900-tab/lane_sub/r9_<TAG>.tsv.  21 of 77 matched; staged.  -Xr is confirmed: the only -O-only
match was Serial1_DataTransmit_Loop (now staged with `cc900-options: -O3 -Xr`).  If you suspect a whole hand source is
an -O module, say so and add `/* cc900-options: -O3 -Xr */` to a probe file of its own.

FOCUS: the calr-calling routines (pools/pool_<TAG>_remaining.txt rows whose last column lists calr targets; the
coordinator counts 199 such candidates).  The checker places module-local callees at their ROM addresses, so calr /
jr / jrl to them are checked exactly; list every such callee in one-line `/* cc900-module: ... */` comments.  These are
often larger functions: one or two per form is fine.

Round 10: files sub_<TAG>_10a.c / _10b.c (/_10c.c).  Same rules; report as before.
