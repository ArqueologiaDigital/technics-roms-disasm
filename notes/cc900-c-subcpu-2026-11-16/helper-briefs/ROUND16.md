# Round 16 for lane_sub's helpers (read BRIEF.md and ROUND14.md first; both still hold, with the owner's rm rule)

More spellings found since ROUND14.md (worktree notes/cc900-c-subcpu-2026-11-16/README.md, sections "Idioms found
by systematic probes", "Applying them", "Round 15"):
(e) RESULT KEPT IN A PARAMETER'S REGISTER.  `ld xde,xhl; ld a,(xde)` after a call, where XDE held a pointer
    parameter: the parameter is reused, `tbl = f(tbl, k, mode, &st); v = *tbl;` (sub_F_ra11.c).  A new pointer
    local stays in XHL instead.
(f) COPY THROUGH WA BEFORE A STORE (`ld wa,iz; ld (port),wa`): a temporary, `r = i; port = r;` (sub_J_15b.c).
(g) VALUE COMPUTED BEFORE THE ADDRESS IT IS STORED TO: the value through a byte temporary first (sub_G_15a.c).
(h) STACK ARGUMENTS ARE PUSHED LEFT TO RIGHT in non-__cdecl functions: the LAST parameter has the lowest (xsp+N)
    offset.  Read the parameter order from the ROM's offsets; our C has had the wrong parameter passed on before.
(i) 8-bit unsigned compare of a byte: `(unsigned char)k`, never through `(int)k`.  An index `extz wa; add wa,12`:
    `unsigned int i = n;` (initializer) indexed with `(int)i + 12`.
(j) A constant POINTER argument loaded first: a register local set before the call (sub_J_14b.c).
V4.23 seems to copy a value into another register when the C converts its type; where the ROM shows such a copy
and ours has none, try a cast or a temporary of another type.

Latest runs: ~/compartilhado/cc900-oracle/runs/2026-11-16-106-sub-r15 (round 15), 2026-11-16-101-sub-r14,
2026-11-16-99-sub-r13-idioms (round 13, switches sub_C_13*, sub_D_13*).  Listings: out/v423/Xr/sub/<stem>.asm.
Start each function from its best file (named in your prompt), use first_diff.py to see the difference, and write
2-4 spellings per function in sub_<TAG>_16a.c, _16b.c, _16c.c (one spelling of each function per file).
