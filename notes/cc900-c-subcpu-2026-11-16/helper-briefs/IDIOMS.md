# Idiom probes (round 13) for lane_sub's helpers (read after BRIEF.md; the owner's rule in ROUND8.md stands)

Goal: for one blocking idiom class each, find WHICH C spelling makes V4.23 produce the ROM's form, by trying ~10-20
spellings of the SAME statement in one VM run.  The answer helps all three lanes (main CPU, sub-CPU, HD-AE5000).

How: pick 1-3 small ROM functions (from your earlier misses) that show the pattern and differ from V4.23 only there.
Write ONE probe file per spelling, each defining the function(s) under their ROM labels, so the checker compares every
spelling with the ROM:  sub_<TAG>_i<cls><NN>.c  (NN = 01, 02, ...; e.g. sub_A_ia01.c ... sub_A_ia15.c).  Put a
one-line comment at the top of each file naming the spelling ("spelling 07: assignment chain a = b = x").  Keep the
rest of each function identical across the files.  lane_sub compiles all of them at -Xr, -O1 -Xr and -O2 -Xr.

Classes:
- A, class (a) reload-after-store: the ROM stores a value to a stack local and keeps using the register (`ld (xsp+n),xwa`
  then uses XWA); V4.23 reloads it.  Spellings: volatile vs not; a temporary local; `register` locals; assignment
  chains (`a = b = x`); comma expressions; the store and the reuse in one expression vs two statements; the variable
  declared in an inner block; the value as a parameter reassigned; a pointer vs an integer local.
- E, class (b) constant-argument load order: the ROM loads a constant register argument in argument order (e.g.
  `ldw bc,0x20` before `ld xde,(buf)`); V4.23 loads constants last.  Spellings: argument order in the call; casts on
  the constant ((int), (unsigned char), (long)); the constant through a local (initialised, assigned, const);
  prototype vs no prototype for the callee; K&R vs ANSI callee declaration; an enum or #define'd constant.
- B, class (c) char-argument extension: the ROM passes a char argument unextended (`ld c,(xbc+wa)` then call) where
  V4.23 extends it (`extz bc`).  Spellings: prototype parameter type char / unsigned char / signed char / int / unsigned
  int; no prototype; a K&R definition of the callee (lane_p6 found the firmware needs K&R in places: `void f(a) char
  a; { ... }` -- the CALLER sees no prototype); casts at the call; the argument from a char local vs an array element
  vs a struct member.
Report: per spelling, the verdict (lane_sub sends you the TSV), and in two lines the rule you infer.
