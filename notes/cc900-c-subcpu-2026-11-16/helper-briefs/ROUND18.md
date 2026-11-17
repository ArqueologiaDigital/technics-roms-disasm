# Round 18 for lane_sub's helpers (read BRIEF.md, ROUND14.md, ROUND16.md and ROUND17.md first; all still hold)

State: 447 functions per tree are built from C (v142/subcpu/cc900/*.c).  Round 17 (run
~/compartilhado/cc900-oracle/runs/2026-11-16-126-sub-r17, listings out/v423/Xr/sub/sub_<TAG>_17<form>.asm,
verdicts notes/cc900-c-subcpu-2026-11-16/verdicts/2026-11-16-126-sub-r17.tsv) matched 44 of 102; your prompt names
the functions it left open with their best form.  What no helper reached is in
notes/cc900-c-subcpu-2026-11-16/pools/pool_<P>_remaining.txt (regenerated for this round).

What round 17 taught (README "Round 16", and these):
(r) An `int` argument passed to an `unsigned int` parameter is loaded BEFORE a pushed argument; the ROM loads it
    after: make the caller's variable the parameter's own type (DSP_AlgoDescriptor_Emit).
(s) An expression's operand order decides which is computed first: `(*p & 0xff) + sub * 3` computes `sub * 3`
    first into BC.  When the ROM's order of two operand computations is the reverse of ours, swap the operands.
(t) V4.23 emits a switch's compares in REVERSE source order (cases 0x00, 0xc0, 0x40, 0x80 in the source gave the
    ROM's order in Voice_PitchBend): read the ROM's compare order backwards to get the source order.
(u) A function body that ends `calr f; ret` with no result load is `void` with `f(v); return;` or an int function
    falling off its end (TVF_Build_Dispatch).
(v) Instruction-level diffs beat first_diff.py when the first difference is only a jump displacement: helper P's
    /home/fsanches/compartilhado/tmp/cc900-tab/lane_sub/P/idiff.py and helper S's
    /home/fsanches/compartilhado/tmp/cc900-tab/lane_sub/S/ctx.py show every difference of a function (read them
    before using; they are scratch tools).
(w) From lane_hd (run 2026-11-17-3-hd-r36, -Xr): a constant times a loop register in the ROM's order,
    `ld wa,K; muls xwa,iz` (a table row's address), comes from a COMMA expression: `(0, 30) * i + &text[2]` or
    `&rows[(k = 37, k * i) + 2]` with a local k.  Literals, enum, #define, a plain local and `(k = 37) * i` do NOT
    give it.  (Voice_AdvanceSlotIterator's `ld c,0x30; mul bc,a` matched here through a byte local, a different
    form; try the comma where the constant goes into WA and the register is the multiplier.)
Floating point: skip functions that call FP_* routines this round (the library names are being mapped).

Files sub_<TAG>_18a.c, _18b.c, _18c.c; one spelling of each function per file.  Check each with
    bash notes/cc900-c-subcpu-2026-11-16/syntax_check.sh FILE.c
