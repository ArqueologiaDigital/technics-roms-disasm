# Plan: turning the C work's results into the Technics-compiler model and the LLVM drop-in (2026-11-22, revised)

**Owner's request (2026-11-22).**  The dashboard's C-coverage curve is flattening.  Part of the reason may be that
V4.23 is not the compiler Technics used.  The near misses the C lanes collected and classified may show where the two
compilers differ.  Use them to resume the original task (PLAN.md: model the Toshiba compilers, then build an LLVM
drop-in replacement), and plan how.

**Revision.**  The first version (5b202c125) was reviewed by an independent Fable 5.2 subagent at the owner's request.
The review found errors in `residual.py`'s join (v8 and names cut to 31 were lost), a unit mix in the plateau
estimate, a tool cited that does not exist, a circular "hand assembly" ceiling, and, most important, that the matched
functions cannot support a Technics rule, only veto one.  Section 11 lists every change.  The numbers in section 1 are from
the corrected `residual.py` (output `residual.md`, main at bd5685575).  A few others come from the review's own ad hoc
counts over committed files (index.tsv attempts and combinations, the option-grid figures of B2, the model's 475 of
1,735 in v10, the 18 built functions with a non-call-form best attempt); the step that cites each one re-measures it
with a committed script before it is relied on.

**Short answer.**  The C work gives the original task three things:

1. **A veto set**: 12,773 functions (1,240,291 B; 2,631 distinct names, the rest are the same function in the six
   main-CPU versions, the three sub-CPU payloads and the four HD-AE5000 versions) whose Technics-compiled bytes V4.23
   reproduces from our C.  Any Technics rule that changes their code is wrong.  It is also ground truth for the model's
   `v4.23` personality, on exactly the code the firmware has: about twelve times the 220 library pairs PLAN.md
   expected, counted by distinct function.
2. **The residual**: 553 NEAR (98,563 B) and 271 DIFF (32,958 B) functions, 772 distinct names, almost all in v10
   (104,361 B there, 10.5 % of v10's code against 12.7 % built).  This is where a Technics behaviour V4.23 lacks can
   show, and register choice dominates it.
3. **The tricks**: every C spelling the lanes needed to make V4.23 match (`r ? r : r;`, `volatile float`, lower-case
   `__asm`, `__near` declarations, declaration order, block-scoped locals).  Each is either ordinary C or a compiler
   difference in disguise, and none has been checked.

The plan: first measure what the plateau is made of (section 3), then separate spelling from compiler in the
residual and the tricks (section 4), then retarget the model to the firmware with a leak-free split and a stop rule
(section 5), then decide Technics rules from evidence that can support them (section 6), and only then port (section 7).

## 1. What the C work produced, measured

| state of a function, main at bd5685575                        | functions | ROM B     |
|---------------------------------------------------------------|-----------|-----------|
| built from C, V4.23 byte-identical (every image, v8 included) | 12,773    | 1,240,291 |
| a matching attempt exists, not built (staging blockers)       | 41        | 4,641     |
| best attempt NEAR (≥ 70 % of bytes equal), not built          | 553       | 98,563    |
| best attempt DIFF, not built                                  | 271       | 32,958    |
| never compared (translation, data or name errors)             | 289       | 0         |

| image    | residual NEAR | ROM B  | residual DIFF | ROM B  |
|----------|---------------|--------|---------------|--------|
| v10      | 422           | 72,798 | 236           | 31,563 |
| v142     | 52            | 15,327 | 12            | 1,048  |
| v5       | 32            | 3,530  | 5             | 76     |
| v6       | 22            | 2,364  | 5             | 76     |
| v7       | 22            | 1,396  | 10            | 136    |
| hdae5000 | 3             | 3,148  | 3             | 59     |

The residual was attempted almost only in v10; built v10 functions are usually built in v9 / v8 / v7 / v6 / v5 too,
so a residual v10 function that becomes buildable is worth several times its bytes on the dashboard.

**The near-miss index overstates the residual.**  Its class table puts "call-form" first (449 functions with no
other class); 439 of them are built.  The index compares one listing at a time; the build links each C file at its
ROM address with module-level call relaxation.  After the join, call-form is the only class of 1 residual NEAR
function.  The review also found 18 built functions whose best attempt has a non-call-form class, so other
listing-level classes (length-only, operand) may hide link artefacts too: step A0 recompares the residual through
the build's link.

**The residual by class** (`residual.md` has every class):

| class      | residual NEAR functions | ROM B  | only class | residual DIFF functions |
|------------|-------------------------|--------|------------|-------------------------|
| register   | 316                     | 72,835 | 46         | 225                     |
| other      | 360                     | 69,309 | 87         | 226                     |
| order      | 184                     | 46,399 | 12         | 119                     |
| operand    | 99                      | 26,809 | 18         | 91                      |
| extend     | 106                     | 24,480 | 2          | 126                     |
| loop-shape | 46                      | 11,609 | 1          | 96                      |

**Behaviours already found where the firmware and V4.23 part, or seemed to** (rules.md, the lanes' handoffs, RESUME):

| behaviour                                               | V4.23                    | firmware                                    | state                                                             |
|---------------------------------------------------------|--------------------------|---------------------------------------------|-------------------------------------------------------------------|
| reload after a store                                    | reloads                  | drops it (as the 2003 compiler)             | decided, `kn5000` = 2003                                          |
| one-compare loop test copied to the loop entry          | jumps to the bottom test | copies it (Matsushita's C, not the library) | decided for the firmware's C (`KN_LOOP_INVERT`); 2003 never asked |
| memory-to-memory moves                                  | seemed absent            | present                                     | spelling: V4.23 emits them for `__near` cells (lane_o3, RESUME)   |
| conditional jump to the next instruction, with its test | removed with its test    | kept                                        | reproduced by `r ? r : r;`; spelling or compiler, undecided       |
| per-file option sets                                    | n/a                      | `-Xr` or `-O3 -XS -Xr` per file             | recorded per file; may be a compiler difference in disguise (A4)  |
| `__doprnt`                                              | differs                  | 3 bytes off V4.23 and the 2003 compiler     | undecided                                                         |
| V4.23's 12 recorded bugs (`cc900-v423-bugs.md`)         | miscompiles or crashes   | not checked                                 | undecided per bug                                                 |

The `__near` precedent matters: a difference that looked like a compiler rule was a declaration.  Every candidate
below gets the same suspicion.

## 2. Two properties of the evidence that bound what it can show

- **The matched set can veto a rule, not support one.**  On the 12,773, V4.23 already equals the ROM; a `kn5000`
  rule that changes any of them is wrong there.  The C was also searched until V4.23 matched, so it is co-adapted to
  V4.23.  Positive evidence for a Technics rule can only come from the residual, the library pairs, the tricks
  (section 4), and the firmware-wide census of both forms of a behaviour.
- **The screens are not hand-assembly detectors.**  `families.py` and `new_pool.py` say themselves that nothing marks
  a routine as compiled C; the hand marks of `xr_screen.py`, `sub_screen.py` and `hd_screen.py` are "features V4.23
  never writes", which would also label another compiler's idioms as hand written (one of them, `djnz`, is a decided
  V4.23 behaviour: 171 occurrences in v10, rules.md).  So "most untried code is hand assembly" is not established.

## 3. Step A: what the plateau is made of (first, no VM)

| step | what                                                                                                                                                                                                                                                                                                                                                                                                                                                            | done when                                                                                                                    |
|------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| A0   | recompare every residual function through the build's link (each C file at its ROM address, module call relaxation), as the build does, instead of the index's one-listing comparison                                                                                                                                                                                                                                                                           | the residual re-counted; listing artefacts removed                                                                           |
| A1   | the residual set joined with the build                                                                                                                                                                                                                                                                                                                                                                                                                          | done (`residual.py`, corrected)                                                                                              |
| A2   | **the ceiling, with compiler-positive marks**: classify every ROM byte not built from C by marks that say "a compiler wrote this" (cc900 frame `lda XSP` / `push XIZ`, the caller pops its arguments, the switch idiom, membership of a `calr` module) and those that say "hand written" independent of V4.23 (shared tails, entry points mid-routine, register conventions no cc900 uses); report "compiler frame plus a V4.23-negative mark" as its own class | each image's code split into compiled-looking, hand-looking, conflict and library; the conflict class sized; a dashboard row |
| A3   | collect the lanes' reasons for rejecting candidates from their scratch (`~/compartilhado/tmp/cc900-tab/lane_p6/scan/` and the helpers' lists) into a committed table                                                                                                                                                                                                                                                                                            | every untried routine has a recorded reason                                                                                  |

A2's conflict class is where a different compiler would show; its size decides how much the rest of this plan can
move the curve.  If it is large, the screens were hiding compiled code and the C lanes resume on it.

## 4. Step B: spelling or compiler?

Ordered from cheapest and most decisive.

| step | what                                                                                                                                                                                                                                                                                                                                                 | tool / run                                                          | done when                                                                                 |
|------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| B0   | **stability of the first difference across rewrites** (no VM): `index.tsv` holds 76,854 compared attempts; for each residual function with attempts from several different C files, does the first difference stay at the same place with the same signature?  Stable across independent spellings points to the compiler; moving points to spelling | `stability.py` over `index.tsv`                                     | each residual function tagged stable / moving / single attempt                            |
| B1   | **the trick catalogue**: every C spelling the lanes needed, from their READMEs and handoffs, with the functions that needed it; for each, a micro probe asking all three compilers whether the trick is needed there too                                                                                                                             | `tricks.md`; one oracle run per compiler                            | each trick marked "ordinary C" (all compilers need it) or "candidate rule"                |
| B2   | **the option grid**: in v10, 111 functions (13,251 B) match only without `-O`, in 28 address runs, 20 of them single functions among `-O`-only neighbours, and 22 of 76 inferred modules mix both; test whether one Technics behaviour explains the "without `-O`" shape inside `-O` files                                                           | `options_cluster.py`; probes of the 20 singletons at the full grid  | the per-file option model confirmed, or replaced by a rule                                |
| B3   | **neighbour compilers on the residual**: recompile each residual function's attempts with the 2003 IDE compiler and v1.10 (2009), at the full option grid (not only the recorded set); first check `to_llvm.py` on their listings (the 2003 / 2009 runs so far were micro corpora)                                                                   | write `nearmiss.py --compiler` (it does not exist); two oracle runs | each residual function tagged: matches 2003, matches 2009, same diff as V4.23, other diff |
| B4   | **neighbour compilers on the matched set**: the same for the 12,773 (one batch per compiler); where 2003 or 2009 differ from the ROM, the Technics compiler did not have that behaviour                                                                                                                                                              | the same runs                                                       | a tighter bracket on the Technics compiler's date; rules ruled out                        |
| B5   | **a permuter** (PLAN phase 6) on the 46 register-only NEAR functions: mechanical C rewrites (declaration order, temporaries, scopes, casts) compiled in bulk; a function no permutation fixes is a stronger compiler candidate                                                                                                                       | `permute.py`; batched oracle runs                                   | each of the 46 matched or "no permutation found" with the count tried                     |
| B6   | **census of both forms** of each surviving candidate over all compiled-looking code (A2), as `idiom_census.py` does                                                                                                                                                                                                                                  | one detector per candidate                                          | each candidate decided on / off / undecided in rules.md, with counts                      |

Expectations, stated so they can be checked: V4.23 and the 2003 compiler differ on 3 of 749 micro functions
(rules.md), and the one earlier firmware trial (run `2026-11-16-50-hd-x1-compilers`) gave V4.23's bytes from the
other compilers.  So B3 is likely to find few witnesses; it is run because it is cheap and decisive.  B0, B1 and B5
carry most of the weight.

## 5. Step C: the model on the firmware

The model (`scripts/analysis/cc900/model/`, paused at batch 366) overfit its training pools (2026-11-15: 22 / 14 /
21 / 14 of 200 on a blind hold-out against about 55 / 34 / 45 / 31 on training).  In v10 it matches 475 of the
1,735 built functions today, none over 128 B; on validation it was at 96 / 47 / 77 / 41 of 600 per option set.
PLAN.md's phase-3 exit (100 % of micro tests, ≥ 95 % of random programs) was never met.

| step | what                                                                                                                                                                                                                                                                                                    | done when                                                   |
|------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------|
| C1   | **the `v4.23` training set is every compared attempt**, not only the matches: 40,590 distinct (function, C file, option set) combinations in 4,721 C files are valid V4.23 pairs, matched or not (the oracle listing is the target)                                                                     | `score.py --corpus firmware-attempts`; per-attempt verdicts |
| C2   | **a leak-free split**: by function name across all images (a v10 function and its v9 / v8 / v7 / v6 / v5 twins together) and by look-alike family (`families.py` shapes); three tiers: fit, validation (acceptance), and a blind test kept as `random5` was, plus the random hold-out as a second guard | the split committed and frozen                              |
| C3   | baseline on all tiers, per first-difference class; wrong code (semcheck) first, as before the pause                                                                                                                                                                                                     | a ledger row                                                |
| C4   | the held items (lane_o3's fixes 29-31, lane_nm's rules 30-43) re-scored on the firmware tiers before any merge                                                                                                                                                                                          | each merged or dropped with its score                       |
| C5   | **an effort estimate and a stop rule**: after C3, estimate the batches to V4.23 parity on the firmware validation tier from the rate of the last 30 batches; stop or re-plan if the blind tier stops gaining for 20 batches                                                                             | the estimate and the rule in the model's README             |

PLAN.md's phase-3 exit stays the end goal for the `v4.23` personality; the firmware tiers are added beside the micro
and random corpora, not in their place.

## 6. Step D: the `kn5000` personality

| step | what                                                                                                                                                                                                                                    | done when                                                                                        |
|------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------|
| D1   | each candidate decided in step B becomes a personality switch, with its trigger, its positive witnesses (residual, library, tricks, census) and the veto check: no function of the 12,773 changes                                       | rules.md lists every rule so                                                                     |
| D2   | the V4.23 bugs: for each of the 12, the census of the miscompiled shape and of its correct form in the firmware                                                                                                                         | each marked "Technics has it", "Technics fixed it" or "no evidence"                              |
| D3   | `__doprnt` and the other unexplained library pairs re-examined with B3 / B4                                                                                                                                                             | each explained or listed as a Technics-only rule                                                 |
| D4   | building a firmware function with the model where V4.23 cannot (owner decision E5): only for functions in the blind or validation tier, with no function-specific rule, semcheck clean, chosen per file explicitly, never as a fallback | if approved: the first such function in `make gate`; the coverage page keeps the compilers apart |

D4 reverses the recorded decision that the model is never an automatic fallback (Makefile, `CC900_COMPILER`), and a
model fitted on a function's own bytes that then builds that function proves nothing.  The tier restriction is what
keeps it honest.

## 7. Step E: the LLVM drop-in

phase3b-design.md's design (b) (a clang-resident code generator from the AST, emitting through our MC layer) stays
the intended route, but its inventory dates from 2026-11-10, before the overfitting finding, and the model has grown
since (`codegen.py` from 7,978 to 21,429 lines).  Its own condition for porting a module (stable for a week) is not
met.  So:

- **E-0**: re-inventory the model against the 3b design once step C's tiers exist; mark modules stable by the C5
  rule; the owner approves the design then.
- **Stages** as in 3b, each adding to its acceptance corpus the firmware functions of the validation tier that
  exercise it.
- **Definition of "drop-in"**: `make CC900_COMPILER=llvm gate` builds every firmware C file now built by V4.23 with
  `clang -mcc900-compat=kn5000`, all ROMs byte-identical, with the model as the differential oracle
  (`port_check.py`).  The Neo Geo Pocket personalities follow from the same port (PLAN phase 7).

## 8. Order, parallelism and the C lanes

| order | steps                                  | needs                             |
|-------|----------------------------------------|-----------------------------------|
| 1     | A0, A2, A3, B0, B1 (catalogue), C1, C2 | nothing (A0, B1's probes: the VM) |
| 2     | B1 (probes), B2, B3, B4, B5, C3, C4    | A0 for the residual; C2 for C3    |
| 3     | B6, C5, D1-D3                          | step B's candidates; C3           |
| 4     | E-0, then the port; D4 if approved     | C5's stable modules               |

**The C lanes**: one lane keeps porting v10's residual and matches to the sibling images, the cheapest dashboard
gain left (the residual is almost all v10); the others become evidence generators (the trick catalogue's probes, the
option-grid probes, the permuter's batches, targeted C for a candidate's witness).  If A2 finds a large conflict
class, a lane resumes new-function work there.

## 9. Risks

- **Spelling and compiler are confounded.**  B0, B3 and B5 are the tests that do not depend on our guess; a candidate
  with none of them stays undecided.
- **The Technics compiler lies between two neighbours.**  B3 / B4 show which way a behaviour went, not when; rules are
  decided one by one.
- **Options per file** may hide a behaviour (B2).
- **Toshiba text (D1).**  Signatures, censuses and the trick catalogue use our notation; listings stay in the private
  oracle repository.
- **Overfitting again.**  C2's leak-free blind tier and C5's stop rule are the guards.
- **The ceiling.**  If A2 finds little compiled-looking code left, the C curve stays flat whatever the model does; the
  plan's value is then the model and the port.

## 10. Decisions for the owner

| #   | question                                                        | recommendation                                                                                                    |
|-----|-----------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| E1  | Resume the model work (phase 3a), driven by the firmware tiers? | yes, narrowed: C1-C3 and wrong code first; no rule fitting until C2's split exists and A2 / B0 / B3 have reported |
| E2  | Move the C lanes to evidence work?                              | partly: one lane keeps porting the v10 residual and matches to the sibling images; the rest to evidence work      |
| E3  | Approve phase3b-design.md's design (b)?                         | not yet: re-inventory first (E-0), then approve                                                                   |
| E4  | Keep D2 (black-box only)?                                       | yes; revisit if the register-only residual is still unexplained after B3 and the permuter (B5)                    |
| E5  | Build a firmware function with the model where V4.23 cannot?    | not yet; later only under D4's restrictions                                                                       |

## 11. What the review changed (Fable 5.2 subagent, 2026-11-22)

| first version                                                              | now                                                                              |
|----------------------------------------------------------------------------|----------------------------------------------------------------------------------|
| 10,818 built, 203 matched-not-built, 573 NEAR (join lost v8 and cut names) | 12,773 built, 41 matched-not-built, 553 NEAR, 271 DIFF (`residual.py` fixed)     |
| "about fifty times" the library pairs                                      | about twelve, by distinct function name                                          |
| "under two points" of dashboard gain from the residual                     | per image: 10.5 % of v10's code; worth more once ported to the siblings          |
| matched functions as support for Technics rules                            | a veto set only; positive evidence from the residual, library, tricks and census |
| screens treated as hand-assembly detectors                                 | not established; A2 measures with compiler-positive marks                        |
| `nearmiss.py --compiler` cited                                             | to be written (B3); `to_llvm.py` checked on 2003 / 2009 listings first           |
| neighbour compilers first                                                  | B0 (no VM), the trick catalogue and the option grid first; the permuter added    |
| split by C file, held-out used for acceptance                              | split by function name and family, three tiers, random hold-out kept             |
| no effort estimate or stop rule; PLAN's phase-3 exit silently replaced     | C5's estimate and stop rule; the phase-3 exit kept as the end goal               |
| E3 yes, E5 yes                                                             | E3 after a re-inventory, E5 not yet                                              |
