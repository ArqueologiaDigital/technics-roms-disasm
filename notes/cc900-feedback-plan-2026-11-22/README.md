# Plan: turning the C work's results into the Technics-compiler model and the LLVM drop-in (2026-11-22, third version)

**Owner's request (2026-11-22).**  The dashboard's C-coverage curve is flattening.  Part of the reason may be that
V4.23 is not the compiler Technics used.  The near misses the C lanes collected and classified may show where the two
compilers differ.  Use them to resume the original task (PLAN.md: model the Toshiba compilers, then build an LLVM
drop-in replacement), and plan how.

**History.**  First version 5b202c125; second ff7e7c036, after an independent Fable 5.2 review; this third version
after a second, fresh Fable 5.2 review of the second.  Section 12 lists what each review changed.  Section 1's
figures come from `residual.py` (beside this file; `residual.md` is its output with `--list 20`).  Figures marked
"(review)" come from the reviewers' own counts over committed files (their scripts are in research-scratch
`sessions/2026-11-22_e8b15bf9/`: `census_split.py`, `check.py`); the step that relies on each one re-measures it
with a committed script first.

**Short answer.**  The C work gives the original task three things, and one warning:

1. **A veto set**: 12,773 functions (1,240,291 B; 2,631 distinct names across the six main-CPU versions, three
   sub-CPU payloads and four HD-AE5000 versions) whose Technics-compiled bytes V4.23 reproduces from our C.  A
   Technics rule that changes their code is suspect.  For the model's `v4.23` personality they are ground truth on
   exactly the firmware's code: about twelve times the library pairs, counted by distinct function.
2. **The residual**: 553 NEAR (98,563 B) and 271 DIFF (32,958 B) functions, 772 distinct names, almost all in v10.
   This is where a Technics behaviour V4.23 lacks can show; register choice dominates it.
3. **The tricks**: the C spellings the lanes needed to make V4.23 match (`r ? r : r;`, `volatile float`, lower-case
   `__asm`, `__near` declarations, declaration order, block-scoped locals).  Each is ordinary C or a compiler
   difference in disguise; none has been checked.
4. **The warning**: the two rules the old plan treated as decided do not survive the C work.  The loop-entry copy is
   V4.23 at `-O3` without `-XS` (retracted by phase 6; rules.md corrected with this version), and the reload rule's
   "Technics" form stands in many bodies V4.23 reproduces (section 2).  So the inferred Technics compiler is today
   closer to V4.23 than PLAN.md assumed, and every rule must pass the veto check before anything is built on it.

The order: first three checks that need no VM and could change the premises (section 3), then what the plateau is
made of (section 4), then spelling or compiler for the residual and the tricks (section 5), then the model on the
firmware with a leak-free split and an effort estimate (section 6), then Technics rules from evidence that can
support them (section 7), and only then the port (section 8).

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

- v10's residual is 104,361 B, 10.5 % of v10's code against 12.7 % built.  That is an upper bound: the ROM sizes come
  from the index's size heuristic, which its README says can overshoot.
- Built v10 functions are usually built in v9 / v8 / v7 / v6 / v5 too, so a residual v10 function that becomes
  buildable is worth several times its bytes on the dashboard.
- 96 residual v5 / v6 / v7 functions have a same-named twin built in another image (review): that is version work
  (porting a function whose code differs between firmware versions), not compiler evidence; it is set apart.
- **The near-miss index overstates the residual.**  Of the 449 functions whose best attempt has only the
  "call-form" class, 448 are built (review): the index compares one listing at a time, the build links each C file at
  its ROM address with module-level call relaxation.  More generally, 593 built functions have a best attempt of NEAR
  or DIFF, 145 of them with a class other than call-form (review), so listing-level classes may hide link artefacts:
  step A1 recompares the residual through the build's link.

**The residual by class** (`residual.md` has every class):

| class      | residual NEAR functions | ROM B  | only class | residual DIFF functions |
|------------|-------------------------|--------|------------|-------------------------|
| register   | 316                     | 72,835 | 46         | 225                     |
| other      | 360                     | 69,309 | 87         | 226                     |
| order      | 184                     | 46,399 | 12         | 119                     |
| operand    | 99                      | 26,809 | 18         | 91                      |
| extend     | 106                     | 24,480 | 2          | 126                     |
| loop-shape | 46                      | 11,609 | 1          | 96                      |

**A base rate from known source**: on the runtime library, where the C source is exact, V4.23 reproduces 235 of 291
pairs, 16 need the 2003 compiler's behaviour, and 40 match no compiler (`scripts/analysis/cc900/results/
pairs_libsrc97_groups.md`).  If Matsushita's residual behaved like that, a few percent of it would be explained by a
neighbour compiler and more by nothing we have; but the library was built by Toshiba's tools (rules.md), so this is a
prior, not a prediction.

**Where the firmware and V4.23 seemed to part** (rules.md, the lanes' handoffs, RESUME):

| behaviour                                               | V4.23                    | firmware                                | state now                                                                                   |
|---------------------------------------------------------|--------------------------|-----------------------------------------|---------------------------------------------------------------------------------------------|
| reload after a store                                    | reloads                  | drops it (as the 2003 compiler)         | decided from library pairs; contradicted in Matsushita's code (section 2); re-checked in Z2 |
| one-compare loop test copied to the loop entry          | jumps to the bottom test | copies it                               | not a rule: V4.23 at `-O3` without `-XS` (phase-6 README; rules.md corrected)               |
| memory-to-memory moves                                  | seemed absent            | present                                 | not a rule: V4.23 emits them for `__near` cells (lane_o3, RESUME)                           |
| conditional jump to the next instruction, with its test | removed with its test    | kept                                    | reproduced by `r ? r : r;`; spelling or compiler undecided (B1)                             |
| per-file option sets                                    | n/a                      | `-Xr` or `-O3 -Xr` per file             | recorded per file; may hide a behaviour (B2)                                                |
| `__doprnt`                                              | differs                  | 3 bytes off V4.23 and the 2003 compiler | undecided                                                                                   |
| V4.23's 12 recorded bugs (`cc900-v423-bugs.md`)         | miscompiles or crashes   | not checked                             | undecided per bug (D2)                                                                      |

Two of the five behaviours turned out to be V4.23 under the right spelling or options.  Every candidate below starts
as "spelling until shown otherwise".

## 2. What the evidence can and cannot show

- **The matched set vetoes, it does not support.**  On the 12,773, V4.23 already equals the ROM; a rule that changes
  their code is suspect.  But the C was searched until V4.23 matched, so it is co-adapted to V4.23: a true Technics
  rule may change a matched function whose C carries a V4.23-only trick.  So the veto is applied **per rule, after
  removing that rule's trick** (B1 before D1).
- **The library is weak evidence for Matsushita's compile.**  The library was built by Toshiba's tools, and its loops
  already differ from Matsushita's C (rules.md).  Rules found on library pairs stay candidates until a residual
  function or the census witnesses them.
- **The reload rule fails the veto as stated** (review, `census_split.py`): the store-then-reload pattern the rule says
  the Technics compiler drops stands 19 times in V4.23-built v10 bodies, 84 in v142, 5 in the HD-AE5000; and 27 of
  the HD-AE5000's 29 "2003-form" census sites are in bodies V4.23 reproduces, so that census count does not
  discriminate.  Either the rule is narrower (only under some option set), or it describes Toshiba's library build.
  Z2 settles it.
- **The screens are not hand-assembly detectors.**  `families.py` and `new_pool.py` say nothing marks a routine as
  compiled C; the hand marks of `xr_screen.py`, `sub_screen.py` and `hd_screen.py` are "features V4.23 never writes".
  One of them is `djnz`, decided V4.23 behaviour in rules.md; and none of the 171 (v10), 14 (sub CPU) and 10
  (HD-AE5000) `djnz` sites lies in a built body (review).  So the screens may have hidden compiled code (Z3).

## 3. Step Z: three checks first (no VM)

| step | what                                                                                                                                                                                                                                                                                                                                                    | done when                                                                                                   |
|------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------|
| Z1   | **preserve the attempts' C.**  Oracle runs keep only a tar hash of their inputs.  Of the compared attempts, 19,041 have a committed copy, 50,019 are exact but in scratch only, 3,956 "likely", 3,838 have no source (review).  Commit the scratch-only C (our own C, small) beside the near-miss index's `c/`, or archive it in its own git repository | every compared attempt's C retrievable from git by its hash; the counts re-measured by a committed script   |
| Z2   | **the rule veto check.**  Run `scripts/analysis/cc900/rule_transform.py` (the reload rule applied to listings; it exists) over the cached V4.23 listings of the matched set and of the residual, and re-compare with the ROM through the build's link                                                                                                   | for each rule: functions it breaks in the matched set, functions it fixes in the residual; rules.md updated |
| Z3   | **a `djnz` pool**: the routines holding the 195 `djnz` sites, screened with every other mark but `djnz`; one lane writes C for the compiled-looking ones                                                                                                                                                                                                | the share of them that V4.23 matches; if high, the screens hid compiled code and A2 is urgent               |

## 4. Step A: what the plateau is made of

| step | what                                                                                                                                                                                                                                                                                                                                                                                                                                                    | done when                                                                                          |
|------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| A1   | recompare every residual function through the build's link (each C file at its ROM address, module call relaxation), from the cached listings (no VM)                                                                                                                                                                                                                                                                                                   | the residual re-counted, listing artefacts removed                                                 |
| A2   | **the ceiling, with compiler-positive marks**: classify every ROM byte not built from C by marks that say "a compiler wrote this" (cc900 frame `lda XSP` / `push XIZ`, the caller pops its arguments, the switch idiom, membership of a `calr` module) and marks of hand writing independent of V4.23 (shared tails, mid-routine entry points, register conventions no cc900 uses); report "compiler frame plus a V4.23-negative mark" as its own class | each image's code split into compiled-looking, hand-looking, conflict and library; a dashboard row |
| A3   | collect the lanes' reasons for rejecting candidates from their scratch (`~/compartilhado/tmp/cc900-tab/lane_p6/scan/` and the helpers' lists) into a committed table                                                                                                                                                                                                                                                                                    | every untried routine has a recorded reason                                                        |

## 5. Step B: spelling or compiler?

| step | what                                                                                                                                                                                                                                                                                                                                                                             | tool / run                                                          | done when                                                                           |
|------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------|-------------------------------------------------------------------------------------|
| B0   | **signature clustering** (no VM): the first difference of each residual function, normalised (registers and offsets by role, our syntax), clustered **across functions**; a compiler rule recurs across unrelated functions.  Within a function, stability across rewrites counts only between attempts whose function text differs (hash the function's own text, not the file) | `signatures.py` over `index.tsv` and the cached listings            | clusters ranked by functions and bytes; per function: stable / moving / single text |
| B1   | **the trick catalogue**: every C spelling the lanes needed, with the functions that needed it; for each, a micro probe asking all three compilers whether the trick is needed there too                                                                                                                                                                                          | `tricks.md`; one oracle run per compiler                            | each trick "ordinary C" (all compilers need it) or "candidate rule"                 |
| B2   | **the option grid**: in v10 111 functions match only without `-O` (all were also tried with `-O`), in address runs, many as single functions among `-O`-only neighbours (review; the run and module counts to be re-measured); test whether one behaviour explains the "without `-O`" shape inside `-O` files                                                                    | `options_cluster.py`; probes of the singletons at the full grid     | the per-file option model confirmed, or replaced by a rule                          |
| B3   | **neighbour compilers on the residual**: each residual function's attempts with the 2003 IDE compiler and v1.10 (2009) at the full option grid; first check `to_llvm.py` on their listings                                                                                                                                                                                       | write `nearmiss.py --compiler` (it does not exist); two oracle runs | each residual function: matches 2003, matches 2009, same diff as V4.23, other diff  |
| B4   | **neighbour compilers on the matched set**: the same for the 12,773; where 2003 or 2009 differ from the ROM, the Technics compiler did not have that behaviour                                                                                                                                                                                                                   | the same runs                                                       | a tighter bracket on the Technics compiler's date; rules ruled out                  |
| B5   | **a permuter** (PLAN phase 6) on the 46 register-only NEAR functions: mechanical C rewrites (declaration order, temporaries, scopes, casts) compiled in bulk                                                                                                                                                                                                                     | `permute.py`; batched oracle runs                                   | each matched, or "no permutation found" with the count tried                        |
| B6   | **census of both forms** of each surviving candidate over the compiled-looking code (A2), split between hand source and V4.23-built bodies as `census_split.py` does                                                                                                                                                                                                             | one detector per candidate, committed                               | each candidate on / off / undecided in rules.md, with counts                        |

Expectations: V4.23 and the 2003 compiler differ on 3 of 749 micro functions (rules.md), and the one earlier firmware
trial (run `2026-11-16-50-hd-x1-compilers`) gave V4.23's bytes from the other compilers.  B3 will likely find few
witnesses; it runs because it is cheap.  B0, B1 and B5 carry most of the weight.

## 6. Step C: the model on the firmware

The model (`scripts/analysis/cc900/model/`, paused at batch 366) overfit its training pools (2026-11-15: 22 / 14 /
21 / 14 of 200 on a blind hold-out against about 55 / 34 / 45 / 31 on training).  On validation it reached 96 / 47 /
77 / 41 of 600 per option set.  On the firmware it matches 475 of the 1,735 built v10 functions, the largest 108 B,
7,424 of 126,490 B (review).  PLAN.md's phase-3 exit (100 % of micro tests, ≥ 95 % of random programs) was never met.

| step | what                                                                                                                                                                                                                                                                                                   | done when                                                    |
|------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------|
| C0   | **a rough effort estimate now**, before any batch: from the model's batch history, the rate at which validation and firmware functions were gained; the batches to `v4.23` parity on the firmware at that rate                                                                                         | the estimate in the model's README; it informs E1 and E4     |
| C1   | **the `v4.23` training data is every compared attempt** (matched or not, the oracle listing is the target): about 40,590 distinct (function, C file, option set) combinations over about 4,650 C file hashes (review), **scored per distinct function**, not per attempt, since attempts are redundant | `score.py --corpus firmware-attempts`; per-function verdicts |
| C2   | **a leak-free split**: by function name across all images (a v10 function and its twins together) and by look-alike family (`families.py` shapes); three tiers: fit, validation (acceptance), blind test, plus the random hold-out as a second guard                                                   | the split committed and frozen                               |
| C3   | baseline on all tiers, per first-difference class; wrong code (semcheck) first                                                                                                                                                                                                                         | a ledger row                                                 |
| C4   | the held items (lane_o3's fixes 29-31, lane_nm's rules 30-43) re-scored on the tiers before any merge                                                                                                                                                                                                  | each merged or dropped with its score                        |
| C5   | **the stop rule**: stop or re-plan if the blind tier stops gaining for 20 batches, or if the rate falls far below C0's estimate                                                                                                                                                                        | written in the model's README                                |

PLAN.md's phase-3 exit stays the end goal for the `v4.23` personality; the firmware tiers are added beside the micro
and random corpora.

## 7. Step D: the `kn5000` personality

| step | what                                                                                                                                                                                                                                                                                     | done when                                                    |
|------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------|
| D0   | **a frozen confirmation half of the residual**: split the 772 residual names (by name and family, as C2) before any rule is fitted; rules are found on one half and confirmed on the other                                                                                               | the split committed                                          |
| D1   | each candidate that survives step B becomes a personality switch, with its trigger, its positive witnesses (residual, tricks, census; library only as support), the per-rule veto (no matched function changes once the rule's trick is removed) and its score on D0's confirmation half | rules.md lists every rule so                                 |
| D2   | the V4.23 bugs: for each of the 12, the census of the miscompiled shape and of its correct form in the firmware                                                                                                                                                                          | each "Technics has it", "Technics fixed it" or "no evidence" |
| D3   | `__doprnt` and the other unexplained library pairs re-examined with B3 / B4                                                                                                                                                                                                              | each explained or listed as a Technics-only rule             |
| D4   | building a firmware function with the model where V4.23 cannot (owner decision E5): only for functions of D0's confirmation half, no function-specific rule, semcheck clean, chosen per file explicitly, never as a fallback                                                             | if approved: the first such function in `make gate`          |

D4 reverses the recorded decision that the model is never an automatic fallback (Makefile, `CC900_COMPILER`), and a
model fitted on a function's own bytes that then builds that function proves nothing; the confirmation half is what
keeps it honest.

## 8. Step E: the LLVM drop-in

phase3b-design.md's design (b) (a clang-resident code generator from the AST, emitting through our MC layer) stays the
intended route.  Its inventory dates from 2026-11-10; `codegen.py` was 10,698 lines then and is 21,429 now, and the
design's own condition for porting a module (stable for a week) is not met.  So:

- **E-0**: re-inventory the model against the 3b design once step C's tiers exist; mark modules stable by C5; the
  owner approves the design then.
- **Stages** as in 3b, each adding to its acceptance corpus the firmware functions of the validation tier that
  exercise it.
- **Definition of "drop-in"**: `make CC900_COMPILER=llvm gate` builds every firmware C file now built by V4.23 with
  `clang -mcc900-compat=kn5000`, all ROMs byte-identical, with the model as the differential oracle
  (`port_check.py`).  The Neo Geo Pocket personalities follow from the same port (PLAN phase 7).

## 9. Order, parallelism and the C lanes

| order | steps                                      | needs                               |
|-------|--------------------------------------------|-------------------------------------|
| 1     | Z1, Z2, Z3, C0                             | nothing; no VM except Z3's compiles |
| 2     | A1, A2, A3, B0, B1 (catalogue), C1, C2, D0 | Z1 for C1 / B0; Z2 for rules.md     |
| 3     | B1 (probes), B2, B3, B4, B5, C3, C4        | A1 for the residual; C2 for C3      |
| 4     | B6, C5, D1-D3                              | step B's candidates; C3             |
| 5     | E-0, then the port; D4 if approved         | C5's stable modules                 |

**The C lanes**: one lane runs the `djnz` pool (Z3) and then keeps porting v10's residual and matches to the sibling
images (the 96 twins of section 1 are its version work); the others become evidence generators (the trick
catalogue's probes, the option-grid probes, the permuter's batches, targeted C for a candidate's witness).  If A2 or
Z3 find hidden compiled code, a lane resumes new-function work there.

## 10. Risks

- **Spelling and compiler are confounded.**  B0's cross-function clusters, B3 and B5 do not depend on our guess; a
  candidate with none of them stays undecided.
- **The Technics compiler may be very close to V4.23.**  If Z2 and B3 find no robust difference, the `kn5000`
  personality is V4.23 plus a few narrow rules, and most of the value is in the `v4.23` model and the port.
- **The Technics compiler lies between two neighbours.**  B3 / B4 show which way a behaviour went, not when.
- **Options per file** may hide a behaviour (B2).
- **Toshiba text (D1 of PLAN).**  Signatures, censuses and the trick catalogue use our notation; listings stay in the
  private oracle repository.  Z1 preserves our C only.
- **Overfitting again.**  C2's blind tier, D0's confirmation half and C5's stop rule are the guards.
- **Disk.**  The share is near full; Z1 commits small text, and the oracle batches of B3 / B4 / B5 must be sized
  against free space.
- **The ceiling.**  If A2 and Z3 find little compiled-looking code left, the C curve stays flat whatever the model
  does; the plan's value is then the model and the port.

## 11. Decisions for the owner

| #   | question                                                        | recommendation                                                                                                                        |
|-----|-----------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| E1  | Resume the model work (phase 3a), driven by the firmware tiers? | yes, narrowed: Z1, Z2 and C0 first; then C1-C3 with wrong code first; no rule fitting until C2 and D0's splits exist                  |
| E2  | Move the C lanes to evidence work?                              | partly: one lane on the `djnz` pool and the v10-to-siblings porting; the rest to evidence work                                        |
| E3  | Approve phase3b-design.md's design (b)?                         | not yet: re-inventory first (E-0)                                                                                                     |
| E4  | Keep D2 (black-box only)?                                       | yes; revisit if the register-only residual is unexplained after B3 and B5, or if C0 estimates hundreds of batches for register choice |
| E5  | Build a firmware function with the model where V4.23 cannot?    | not yet; later only under D4's restrictions                                                                                           |

**Answered 2026-11-22: the owner accepted every recommendation** ("I accept all recommendations").  So the model work
resumes narrowed (E1), one C lane takes the `djnz` pool and the v10-to-siblings porting (E2), design (b) waits for
E-0 (E3), the model stays black-box (E4) and builds no firmware function (E5).  Work starts with Z1, Z2, Z3 and C0,
one step at a time (the owner's token budget, 2026-11-20).  Progress is logged in `PROGRESS.md` beside this file.

**E4 revised 2026-11-22, after C0** (C0 estimated about 3,900 batches to firmware parity, which meets E4's revisit
condition).  Asked whether the model should stay black-box, the owner answered: "look at compiler internals".  So
PLAN.md's D2 is lifted: thc1 / thc2 may be disassembled to learn their rules.  Section 13 says how, and what stays
private because of D4.

## 12. What the reviews changed

**First review (Fable 5.2, on 5b202c125):**

| first version                                                              | second version                                                               |
|----------------------------------------------------------------------------|------------------------------------------------------------------------------|
| 10,818 built, 203 matched-not-built, 573 NEAR (join lost v8 and cut names) | 12,773 built, 41 matched-not-built, 553 NEAR, 271 DIFF (`residual.py` fixed) |
| "about fifty times" the library pairs                                      | about twelve, by distinct function name                                      |
| "under two points" of dashboard gain                                       | per image: 10.5 % of v10's code (an upper bound), worth more once ported     |
| matched functions as support for Technics rules                            | a veto set only                                                              |
| screens treated as hand-assembly detectors                                 | not established; A2 measures with compiler-positive marks                    |
| `nearmiss.py --compiler` cited                                             | to be written (B3)                                                           |
| neighbour compilers first                                                  | the trick catalogue, the option grid and a permuter added                    |
| split by C file, held-out used for acceptance                              | split by name and family, three tiers                                        |
| no effort estimate or stop rule                                            | an estimate and a stop rule; PLAN's phase-3 exit kept                        |

**Second review (a fresh Fable 5.2, on ff7e7c036):**

| second version                                                | third version                                                                             |
|---------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| loop-entry copy "decided for the firmware's C"                | not a rule: V4.23 at `-O3` without `-XS` (phase 6 had retracted it); rules.md corrected   |
| reload rule "decided"                                         | fails the veto as stated; Z2 re-checks it                                                 |
| the veto stated absolutely                                    | applied per rule after removing the rule's trick                                          |
| library pairs as positive evidence                            | candidates only until a residual witness or the census confirms                           |
| djnz selection effect noted, unused                           | Z3, a `djnz` pool                                                                         |
| B0: stability across rewrites by file hash                    | cross-function signature clusters; function-text hashes                                   |
| no `kn5000` hold-out                                          | D0, a frozen confirmation half of the residual                                            |
| attempts' C assumed available                                 | Z1: most of it is in scratch only; preserve it first                                      |
| effort estimate after C3                                      | C0, before any batch                                                                      |
| "439 built", "18 built with other classes", A0 "needs the VM" | 448; 593 built with a NEAR / DIFF best attempt, 145 of them not call-form; A1 needs no VM |
| `codegen.py` "from 7,978"                                     | 10,698 lines at 2026-11-10                                                                |
| no base rate                                                  | the library's 235 / 16 / 40 of 291 as a prior                                             |
| v5 / v6 / v7 residual counted as compiler evidence            | 96 with a built twin set apart as version work                                            |

## 13. Step I: the compiler's internals (E4 revised, 2026-11-22)

**Why.**  C0 showed that fitting rules from outputs, batch by batch, does not reach the firmware: the residual is
mostly register choice, and register choice is what black-box fitting learned slowest.  The compiler's own code holds
the answer directly: the allocator's order and costs, the peephole patterns, the switch and loop heuristics.

**What we have.**  Static analysis only; the programs still run only in the oracle VM.  All are 32-bit Windows console
programs (PE32, i386); the 1998 ones say "Copyright(C) TOSHIBA CORPORATION 1989-1997" and link the Microsoft
Visual C++ runtime.

| build              | where (`~/compartilhado/upstream_repos/file_archive/`)                              | thc1 / thc2 bytes |
|--------------------|-------------------------------------------------------------------------------------|-------------------|
| V4.23 (1998-06-04) | `devrs.com/ngpcbins/unpacked/zip/T900/BIN/`                                         | 276,992 / 301,568 |
| IDE 2003           | `github.com/colinoflynn/Toshiba-TLCS-900-L-Resources/unpacked/toshiba-ide/.../bin/` | 311,296 / 352,256 |
| v1.10 (2009)       | `archive.org/ToshibaTLCS900CompilerV1.10/unpacked/msi/.../bin/`                     | 409,600 / 479,232 |

**The clean-room boundary (because of D4).**  The backend is meant for LLVM upstream, so no Toshiba code may reach it,
even rewritten line by line.
- Anything that reproduces Toshiba's code or tables (disassembly, decompiled C, a table dumped verbatim) lives only
  in the private `~/compartilhado/cc900-oracle/internals/`, never pushed, like the oracle's outputs (D1).
- Public notes (rules.md, this directory) carry our own description of a behaviour: what the compiler decides and
  when, in our words, citing a binary by SHA-256 and a virtual address.  No listing lines.
- The model and the LLVM code are written from those descriptions, and every rule taken from the internals is
  still checked the usual way: it must survive the veto set (Z2) and fix near misses before it is kept.

**Steps.**

| step | what                                                                                                                                                                       | done when                                                                         |
|------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| I0   | inventory, no new tools: every thc1 / thc2 build's SHA-256, size, PE sections, imports, symbols if any, version and diagnostic strings, option names; which pass does what | `i0_inventory.py` and its table; a tool choice for I1                             |
| I1   | tooling: a disassembler / decompiler for i386 PE run headless (Ghidra or an equivalent), its project private in `internals/`                                               | the V4.23 thc2 analysed, function count and call graph                            |
| I2   | thc2's register allocator: the register order, the costs, what decides a choice; described in our words                                                                    | a rule from it fixes register-only near misses (A1's set) and passes the veto set |
| I3   | thc2's peephole and pattern tables: the list, each pattern described, marked "in the model" or not                                                                         | the list in rules.md's style; the missing ones queued for the model               |
| I4   | V4.23 against 2003 and 2009: which thc2 functions changed, to bound the Technics compiler (between 1998 and 2003)                                                          | a changed-function list with what each change does to the output                  |

**Found in I2 (2026-11-22): the compiler can be observed stage by stage.**  thc2 has hidden options that print its
intermediate code as it enters code selection (`-zim`), after its optimiser (`-zio`), and every variable's storage
(`-g`); and thc1's output, the file thc2 reads, can be kept (i2/job_i2.sh).  So each stage of a reimplementation can
be checked against V4.23 on its own, instead of only on the final bytes.  That adds a step:

| step | what                                                                                                                                                         | done when                                                                            |
|------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| I5   | stage oracles for every firmware C file and the validation corpus: thc1's file, `-zim`, `-zio`, `-g`; the model (and later the LLVM port) checked per stage | a per-stage score of the model; the first stage where each failing function diverges |

I0 runs first.  I2 and I3 replace C1-C3's rule fitting as the model's source of rules; B and D keep their role as the
test of each rule.  Order 2's analysis steps (A1, B0, C2, D0) still give I2 and I3 their test sets.

**Found later in I2 (2026-11-22): the seam between the passes is a small text language.**  thc1 hands thc2 a text
file: a type table, the symbols, then three-address code, one operation per line.  Over the 1,133 firmware files whose
thc1 output was kept (runs 2026-11-22-46..49) it is 534,968 lines using only 48 distinct operations (assignment and
the C operators, labels, conditional and plain jumps, call arguments and calls, line and block markers, inline `asm`).
And m1 (i2/m1_v10.md) showed that the current model, 21,429 lines of rules fitted to outputs, writes V4.23's exact
listing for 32 % of v10's functions and refuses 33 %; the first refusal fixed (DECAY_AS_ADDR) let 75 more functions
compile and none of them match yet.

**Proposal (decision E6 for the owner): rebuild the model along the compiler's own seam.**

| part        | what it is                                                                                     | checked against V4.23 by                                     |
|-------------|------------------------------------------------------------------------------------------------|--------------------------------------------------------------|
| front end   | C (clang's AST) to thc1's intermediate code                                                    | thc1's own file for the same C, line by line                 |
| back end    | thc1's intermediate code to the listing, written from our descriptions of thc2's passes        | thc2 run on thc1's file: `-zim`, `-zio`, `-g`, then the listing |
| LLVM        | the back end's decisions as the `-mcc900-compat` pipeline (design (b)), or a driver around both | the same oracles, through clang                              |

Each half is then tested alone on the same input V4.23 had, so a front-end error can no longer hide a back-end one
and the reverse; the stage dumps localise every difference to a pass.  The current model stays the reference until the
new halves beat it on m1 and on validation.  Recommended; it changes E1's "model work resumes narrowed" into "the model
is rebuilt per stage", so it is the owner's call.

