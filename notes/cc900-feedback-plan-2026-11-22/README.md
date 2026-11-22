# Plan: turning the C work's results into the Technics-compiler model and the LLVM drop-in (2026-11-22)

**Owner's request (2026-11-22).**  The dashboard's C-coverage curve is flattening.  Part of the reason may be that
V4.23 is not the compiler Technics used.  The near misses the C lanes collected and classified may show where the two
compilers differ.  Use them to resume the original task (PLAN.md: model the Toshiba compilers, then build an LLVM
drop-in replacement), and plan how.

**Short answer.**  The C work's biggest product for the original task is not the near misses but the matches:
**10,818 functions (1.08 MB of ROM) whose source we now have and whose Technics-compiled bytes V4.23 reproduces
exactly.**  PLAN.md section 2 expected the firmware to yield only "as many routines as the runtime has" (about 220
library pairs); the C work multiplied that evidence by about fifty, and it is the right distribution: Matsushita's own
code at the options it was built with.  The near misses (573 NEAR + 272 DIFF functions, 133 KB) are the second
product: the place to look for Technics behaviours that V4.23 lacks.  The plan has four steps:

1. **Separate the residual into spelling and compiler** (section 3): recompile it with the 2003 and 2009 compilers
   the oracle already runs, cluster the remaining differences by signature, and census each candidate in the ROMs.
2. **Retarget the model to the firmware corpus** (section 4): the 10,818 pairs become its calibration and held-out
   sets, replacing the random programs that let it overfit (RESUME, 2026-11-15).  The model reproduces 46,547 B of
   the firmware C today against V4.23's 1,240,291 B: that gap is the work, ranked by bytes.
3. **Build the `kn5000` personality from the decided rules** and let the build use the model for the functions only
   it reproduces (section 5); the dashboard's "reference model" row becomes the measure of the inference.
4. **Port the model to clang** stage by stage (phase3b-design.md design (b)), with the whole firmware C rebuilt by
   `clang -mcc900-compat=kn5000` byte-identically as the definition of "drop-in" (section 6).

## 1. What the C work produced, measured

From `residual.py` (beside this file; output `residual.md`), which joins the near-miss index
(`notes/cc900-c-nearmiss/index.tsv`, 334 oracle runs) with the build's per-function table
(`scripts/analysis/cc900/results/c_build_coverage.md`, main at 8e4810c58):

| state of a function V4.23 compiled from our C        | functions | ROM B     |
|------------------------------------------------------|-----------|-----------|
| built from C on main, byte-identical (V4.23 MATCH)   | 10,818    | 1,081,482 |
| a MATCH attempt exists, not built (staging blockers) | 203       | 16,208    |
| best attempt NEAR (≥ 70 % of bytes equal), not built | 573       | 100,413   |
| best attempt DIFF, not built                         | 272       | 33,034    |
| never compared (translation, data or name errors)    | 289       | 0         |

The 10,818 are per image (v10, v9, v8, v7, v6, v5, three sub-CPU payloads, four HD-AE5000 versions); they carry
2,631 distinct function names.  The build compiles them with V4.23 in the VM (`make`), or with our Python model
(`make CC900_COMPILER=model`), which today reproduces 46,547 B of them (the coverage page's "reference model" row).

**The near-miss index overstates the residual.**  Its own class table (README there) puts "call-form" first: 629
functions, 449 of them with nothing else wrong.  Most of those are built: the index compares one listing at a time,
while the build links each C file at its ROM address with module-level call relaxation, which recovers `calr` / `jr`.
Joined with the build, call-form drops to 44 residual NEAR functions.  Any use of the index as compiler evidence must
start from `residual.py`'s set, not from the index's table.

**The residual by class** (each function's best attempt; a function has several classes):

| class      | residual NEAR functions | ROM B  | of them, the only class | residual DIFF functions |
|------------|-------------------------|--------|-------------------------|-------------------------|
| register   | 320                     | 73,457 | 46                      | 226                     |
| other      | 367                     | 70,179 | 87                      | 227                     |
| order      | 185                     | 46,442 | 12                      | 119                     |
| operand    | 99                      | 26,809 | 18                      | 91                      |
| extend     | 108                     | 24,617 | 2                       | 126                     |
| loop-shape | 46                      | 11,609 | 1                       | 96                      |

(`residual.md` has every class.)  **Register choice is the dominant difference**: 320 of 573 NEAR functions, and the
largest single ones are register-only (`HDAE5000_SelectListProc` 2,641 B at 99.3 %, `ProcessLayeredNoteOn_WriteReg4`
965 B).  The lanes report the same from the other side: their last rounds kept failing at the same spots, mostly which
register holds a pointer, a counter or a temporary, and which frame slot a temporary gets.

**Behaviours already found where the firmware and V4.23 part** (rules.md, the lanes' handoffs):

| behaviour                                                 | V4.23                    | firmware                                | state                                                                 |
|-----------------------------------------------------------|--------------------------|-----------------------------------------|-----------------------------------------------------------------------|
| reload after a store                                      | reloads                  | drops it (as the 2003 compiler)         | decided, `kn5000` = 2003                                              |
| a one-compare loop test copied to the loop entry          | jumps to the bottom test | copies the test (Matsushita's C only)   | decided for the firmware's C (`KN_LOOP_INVERT`)                       |
| per-file option sets                                      | n/a                      | `-Xr` / `-O3 -XS -Xr` per file          | recorded per C file (`cc900-options:`)                                |
| a conditional jump to the next instruction, with its test | removed with its test    | kept                                    | reproduced by a C trick (`r ? r : r;`); compiler or source, undecided |
| the `__doprnt` routine                                    | differs                  | 3 bytes off V4.23 and the 2003 compiler | undecided (a later `__DOFORM.C`, or a rule neither neighbour has)     |
| V4.23's 12 recorded bugs (`cc900-v423-bugs.md`)           | miscompiles or crashes   | not checked                             | undecided per bug                                                     |

## 2. Is the plateau the compiler version?

Partly, and the plan must measure how much before betting on it.  Two causes are visible:

- **Candidates ran out.**  The main-CPU lane's family screens (`notes/cc900-phase6-2026-11-16/families.py`,
  `xr_screen.py`) and the sub-CPU and HD-AE5000 screens (`sub_screen.py`, `hd_screen.py`) found that most routines
  not yet tried carry marks of hand assembly or are Toshiba's library.  If that holds, no compiler change will build
  them from C.
- **The residual near misses** (133 KB, about 1.8 % of all ROM code against the 16.6 % now built) are where a
  version difference can show.  Even a complete explanation of them moves the curve by under two points.

So the payoff of this plan is mainly the original goal (an exact, explainable model and its LLVM port), with the C
coverage as a by-product.  Step A2 below measures the hand-assembly ceiling so the dashboard can show it.

## 3. Step A: separating "spelling" from "compiler" in the residual (no new C)

| step | what                                                                                                                                                                                                              | tool / run                                                                  | done when                                                                                                                                                            |
|------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| A1   | the residual set, joined with the build                                                                                                                                                                           | `residual.py` (committed with this plan)                                    | done: 573 NEAR, 272 DIFF                                                                                                                                             |
| A2   | the ceiling: classify every ROM byte not built from C as hand assembly, Toshiba library, data or "compiled-looking, untried", with the lanes' screens as detectors, per image                                     | a `ceiling.py` built from the four screens; a dashboard row                 | each image's code bytes split into those four classes; the untried compiled-looking total known                                                                      |
| A3   | **neighbour compilers on the residual**: recompile each residual function's best C file at its recorded option set with the 2003 IDE compiler and v1.10 (2009), both already in `compilers.conf`                  | two oracle runs (`ide2003`, `v110`); `nearmiss.py --compiler`               | each residual function tagged: matches 2003, matches 2009, same diff as V4.23, other diff                                                                            |
| A4   | **neighbour compilers on the matched set**: the same for a sample of the 10,818 (or all, it is one VM batch per compiler)                                                                                         | the same runs                                                               | where 2003 or 2009 differ from the ROM while V4.23 matches: rules the Technics compiler did not have; brackets the Technics date between V4.23 and 2003 more tightly |
| A5   | **difference signatures**: for each residual function, the first differing ROM / V4.23 instruction pair, normalised (registers and offsets by role, our syntax only, no listing text), clustered across functions | `signatures.py` (reads the private listings, writes only signature classes) | the signature clusters ranked by functions and bytes                                                                                                                 |
| A6   | **census each candidate**: for each cluster or neighbour-compiler finding, a detector for both forms over all of the firmware's compiled code, as `idiom_census.py` does                                          | `idiom_census.py` grows one detector per candidate                          | each candidate decided (on / off / undecided) with counts, in rules.md                                                                                               |

Reading the outcomes: a residual function that **the 2003 or 2009 compiler matches** is a version difference with a
witness, the strongest evidence there is.  A signature that recurs **across unrelated functions and survives the
lanes' rewrites** (they tried three or more spellings on many of them) is a compiler behaviour candidate even without
a neighbour matching it.  A function where all three compilers agree with each other and differ from the ROM is most
likely spelling, or a Technics-only rule; the census decides which.

## 4. Step B: the firmware corpus as the model's ground truth

The model (`scripts/analysis/cc900/model/`, paused at batch 366) was fitted on micro tests and random programs.  On
2026-11-15 a blind hold-out showed that this overfits (22 / 14 / 21 / 14 of 200 exact against about 55 / 34 / 45 / 31
on the training pools).  The firmware pairs fix the distribution problem: they are exactly the code the personality
must reproduce.

| step | what                                                                                                                                                                                                         | done when                                                                                |
|------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------|
| B1   | a `firmware` corpus for the model's ledger: every built C file with its option set; ROM bytes as the target (no oracle text needed); split once, frozen, into fit (about 70 %) and held-out (30 %) by C file | `score.py --corpus firmware` writes per-function verdicts and bytes; the split committed |
| B2   | baseline: the model's exact functions and bytes on both halves, per class of first difference                                                                                                                | a ledger row; today's coverage figure (46,547 B) explained per class                     |
| B3   | work order: the model's failures on the fit half, ranked by bytes and grouped by first-difference class (the same classes as the near-miss index)                                                            | the top ten classes each have a micro trigger or a firmware witness                      |
| B4   | acceptance rule (replaces P11 of 2026-11-15): a model change is kept only if the held-out half does not lose a function and the fit half gains                                                               | written into the model's README; every batch quotes both halves                          |
| B5   | the held items: lane_o3's fixes 29-31 and lane_nm's rules 30-43 (RESUME, 2026-11-16) are re-scored on the firmware corpus before any is merged; wrong code (semcheck) stays the first gate                   | each held item merged or dropped with its firmware score                                 |

Register allocation is where the residual and the model both fail most, so the firmware set's register-choice
failures are the model's main target.  The register-allocator notes (`model/regalloc_notes.md`) already describe the
allocator as fitted priority lists; with about 10,000 exact firmware functions those lists can be fitted on Matsushita's
code instead of on the micro corpus.

## 5. Step C: the `kn5000` personality and the build

| step | what                                                                                                                                                                                            | done when                                                                                           |
|------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| C1   | each rule decided in step A becomes a personality switch in the model (as the reload rule and `KN_LOOP_INVERT` already are), with its micro trigger and its firmware witnesses                  | rules.md lists every rule with state, trigger, witnesses and census                                 |
| C2   | the model with `kn5000` on the residual: functions it reproduces and V4.23 does not are built with `CC900_COMPILER=model` per file (the build already has the flag; it needs a per-file switch) | the first residual function built by the model; the coverage page's "reference model" row counts it |
| C3   | the V4.23 bugs: for each of the 12, a firmware census of the miscompiled shape; a bug whose shape the firmware has in the correct form is a Technics fix                                        | each bug marked "Technics has it", "Technics fixed it" or "no evidence"                             |
| C4   | `__doprnt` and the other library pairs that no setting explains (rules.md) are re-examined with the A3 / A4 results                                                                             | each explained or listed as a Technics-only rule                                                    |

The dashboard gains two curves: firmware bytes reproduced by the model (`v4.23` personality) and by `kn5000`.  The C
coverage stops being the only progress measure.

## 6. Step D: the LLVM drop-in

The port follows phase3b-design.md (design (b): a clang-resident code generator from the AST, emitting through our MC
layer, behind `-mcc900-compat`), with one change: each stage's acceptance corpus adds the firmware functions that
exercise it, taken from B1's per-class tables, beside the micro corpora it already lists.

**Definition of "drop-in", the final gate:** `make CC900_COMPILER=llvm gate` builds every firmware C file now built
by V4.23 with `clang -mcc900-compat=kn5000` and every ROM is byte-identical; with the model as the differential
oracle (`port_check.py`, 100 % line equality per stage).  The Neo Geo Pocket by-products (`v4.23`, `ide2003`, `v1.10`
personalities) come from the same port, checked against their own compilers in the oracle (PLAN phase 7).

## 7. Order, parallelism and what the C lanes do now

| order | steps                               | needs                       | runs in parallel with |
|-------|-------------------------------------|-----------------------------|-----------------------|
| 1     | A2, A3, A4 (two VM batches), B1, B2 | nothing                     | each other            |
| 2     | A5, A6, B3, B4                      | A3 / A4 for A5; B1 for B3   | each other            |
| 3     | C1-C4, B5                           | A6, B3                      | the port's stages 0-2 |
| 4     | D, stage by stage                   | the model stable per module | C, continuing         |

The C lanes stop hunting new functions and become **evidence generators**: targeted C for a rule's witness (as phase
6 found the loop-entry rule), and the near-miss index kept current.  The staged-but-blocked functions (203 with a
MATCH) stay a small side task.

## 8. Risks

- **Spelling and compiler are confounded.**  A residual difference may come from C we have not guessed.  A3 (a
  neighbour compiler matching) and A5 (a signature recurring across unrelated functions) are the two tests that do not
  depend on our guess; a rule with neither stays undecided.
- **The Technics compiler is between two neighbours, not equal to either.**  A3 / A4 show which way each behaviour
  went, not when; a 2003 behaviour may be two changes (PLAN 6).  Rules are decided one by one.
- **Options per file** confound everything: a difference can be an option set.  Every C file records its options, and
  A3 / A4 use them.
- **Toshiba text (D1).**  Signatures and censuses must be our normalised notation; the listings stay in the private
  oracle repository.
- **Overfitting again.**  B4's frozen held-out half is the guard; the firmware corpus is large enough to afford it.
- **The ceiling.**  If A2 shows the untried compiled-looking code is small, the C coverage curve stays flat whatever
  the model does; the plan's value is then the model and the port, not the curve.

## 9. Decisions for the owner

| #   | question                                                                                                                               | recommendation                                                                                |
|-----|----------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| E1  | Resume the paused model work (phase 3a) now, driven by the firmware corpus (section 4)?                                                | yes                                                                                           |
| E2  | Move the C lanes to evidence generation (section 7), ending new-function hunting?                                                      | yes                                                                                           |
| E3  | Approve phase3b-design.md's design (b) and its Q1-Q4 recommendations, if not yet approved, with the firmware acceptance corpora added? | yes                                                                                           |
| E4  | D2 (black-box only) stays?  Disassembling thc2's register allocator would answer the dominant residual class directly                  | keep black-box; revisit if A3-A6 leave register choice undecided                              |
| E5  | Per-function model builds (C2): may a firmware function be built by the model when V4.23 cannot reproduce it?                          | yes, behind `make gate` like everything else; the coverage page keeps the two compilers apart |
