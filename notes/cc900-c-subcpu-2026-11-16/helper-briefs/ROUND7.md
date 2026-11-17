# Round 7 for lane_sub's helpers (read after BRIEF.md and ROUND3-6.md)

Round 6 ran as oracle run 2026-11-16-73-sub-r6 (listings .../runs/2026-11-16-73-sub-r6/out/v423/Xr/sub/).  Verdicts:
~/compartilhado/tmp/cc900-tab/lane_sub/r6_<TAG>.tsv.  29 of 52 matched, 3,198 B.  The 268 earlier matches are being
PROMOTED: they move from <tree>/subcpu/cc900-staged/ into <tree>/subcpu/cc900/ and `make` builds the payload from them.
Do not repeat any function that is in v142/subcpu/cc900/*.c or that matched in round 6.

New facts:
- A SECOND V4.23 CRASH (wine page fault, read at 0x630): sub_B_6a / 6b and sub_C_6b / 6c, which hold the register
  number in __IZ and keep the record pointer in memory (one-element local array `q[0] = p`, `(void)&p`, or a `register`
  pointer local).  Those files lost every function again.  Helpers B and C: bisect it in this round.  Put each
  suspect spelling in its OWN small file (sub_<TAG>_7x.c, a few functions each), so that a crash costs only that file.
- sub_A_6a/b/c did not compile: two names agree in their first 31 characters (THC1-Error-262, "Redeclaration of
  'Voice_Artic_SetWord2Word1_Nibbl'").  Give one of them a short C name with `/* cc900-name: SHORT=FullLabel */`.
- From the HD-AE5000 lane: when a returned or passed pointer is CONVERTED (to `void *` or to an integer), V4.23 loads
  the array base as an immediate (`ld xhl,sym; add xhl,xwa`) instead of `lda`.  Example:
  `return (void *)(ARR + (unsigned long)i * 16);`.  Its idiom table: notes/cc900-c-hdae5000-2026-11-16/README.md on
  branch cc900/c-hdae5000 (`git -C /home/fsanches/compartilhado/technics-roms-disasm show cc900/c-hdae5000:notes/cc900-c-hdae5000-2026-11-16/README.md`).
- A cc900-module: comment stays with the functions it was checked with: lane_sub now stages each probe's matches in a
  file of their own.  Keep each probe file's module list exact (only the ROM's calr / jr / jrl targets).

Round 7: files sub_<TAG>_7a.c / _7b.c (/_7c.c, and small bisection files for B / C).  Same rules; report as before.
