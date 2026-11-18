# Round 21 for lane_sub's helpers (2026-11-18; read ROUND20.md first: its reading list and rules all hold)

Round 20's runs: ~/compartilhado/cc900-oracle/runs/2026-11-18-6-sub-r20a (helpers AD, AE; verdicts
notes/cc900-c-subcpu-2026-11-16/verdicts/2026-11-18-6-sub-r20a.tsv) and 2026-11-18-*-sub-r20b-staged (helper AF).
Listings: out/v423/Xr/sub/<stem>.asm.  Your prompt names your functions and their best form.

What round 20 taught (README "Floating point matched (round 20)" has the FP part):
(z)  A byte of a record read at a fixed offset keeps the offset as a displacement, `(xwa+3)`, when the read goes
     through a struct cast on the record's address: `((struct b4 *)&R[slot * 4 + K])->b3` (the six
     AudioChannel_Handler_Cmd*; sub_AD_20a.c).  Indexing `R[slot * 4 + K + 3]` folds the 3 into the index.
(aa) A byte loaded into A and then moved to L and extended (`ld a,..; ld l,a; extz hl`): `h = (unsigned char)p[12];`
     (Voice_InterpolateNoteCurve, sub_AD_20b.c).
(ab) A frame slot that the code never touches: `(void *)&a;` on a local (Voice_PortaLevel_Compute, sub_AE_20a.c).
(ac) Floating point: the frame rule (address-taken locals top-down in declaration order, temporaries below, spilled
     register candidates lowest), constant folding stopped by a unary plus, `y = (float)(1.0 - pow(...))` for the
     ROM's temporary order.  FP library calls are plain operators and casts; `pow` is `extern double __cdecl
     pow(double, double);`.
(ad) Helper AE's observation, not yet a fix: where the ROM adds a 16-bit offset to a base address it computes the
     offset first, loads the base, then widens the offset, and the sum lands in the offset's register; ours makes
     the base the destination.  Spellings with the offset on the left of the `+` were tried in sub_AE_20a/b/c.c.
(ae) Helper AD's observation for switches: V4.23 seems to drop a first case whose body is only `break` /
     `continue` (AudioChannel_AllVoices_Update_Variant3 lost its 0x20 compare in every attempt).

Files sub_<TAG>_21a.c, _21b.c, _21c.c; one spelling of each function per file.  Check each with
    bash notes/cc900-c-subcpu-2026-11-16/syntax_check.sh FILE.c
