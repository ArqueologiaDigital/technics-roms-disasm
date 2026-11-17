# Round 17 for lane_sub's helpers (read BRIEF.md, ROUND14.md and ROUND16.md first; all still hold)

State: 403 functions per tree are built from C (v142/subcpu/cc900/*.c: read them as examples, they all match).
What is left is in notes/cc900-c-subcpu-2026-11-16/pools/pool_<P>_remaining.txt (bytes, instructions, label, hand
source, kind, erp / nop counts, runtime routines, calr callees; largest first).  Nothing in those lists is built.

More spellings since ROUND16.md (README "Round 16"):
(k) Doubling by add (`add wa,wa`): `b = w + w;` on a local; `* 2` and `<< 1` give a shift.
(l) A product copied before a sum (`ld xwa,xhl`, then the other term built in XHL): the product through a
    conversion or its own local, `r = (v0 >> 8) + (long)(unsigned long)(q * t);`.
(m) A two-way switch that compares the byte in place is an `if (c != 1) { } else { }`.
(n) A record pointer in XBC with a store through (XBC+8): a byte-pointer local, `*(unsigned long *)(s + 8) = v;`.
(o) Switch bodies must be in the ROM's order (the ROM may have case 13 between 11 and 12).
(p) Switches with a jump table: one comment line per function, `/* cc900-data: FUNCTION 1 = TableLabel */`
    (the table's label in the tree; see v142/subcpu/cc900/voice_params_and_tvf_k_16a.c).  They are checkable and
    six are built.
(q) calr callees: `/* cc900-module: Label */`, one line per callee, and a prototype.  Runtime calls (Math_Multiply32,
    Long_SignedDiv, Long_SignedRem, Int_UnsignedRemainder) are just `*`, `/`, `%` on long operands.

Earlier attempts: notes/cc900-c-subcpu-2026-11-16/idiom_scan.tsv names the best attempt of 159 functions (run and
stem; its file is scripts/analysis/cc900/corpus/firmware/<stem>.c, its listing
~/compartilhado/cc900-oracle/runs/<run>/out/v423/Xr/sub/<stem>.asm).  Where a function of your pool has one, start
from it and use first_diff.py; otherwise write it from the hand source (bin/show.py LABEL).

Work order: near misses with an earlier attempt first, then new functions of 20..400 bytes, largest value first;
skip functions with ei / di / ldc / swi / reti, memory-to-memory block moves you cannot express, and bank-register
(erp) counts above ~10 unless the earlier notes show how.  Aim at 15-30 functions.  Files sub_<TAG>_17a.c, _17b.c,
_17c.c (one spelling of each function per file, alternatives in b / c).  Check each with
    gcc -fsyntax-only -std=c89 -D__near= -D__tiny= -D'__asm(x)=' -D'__ASM(x)=' FILE.c
