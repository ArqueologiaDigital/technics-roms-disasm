# Plan: a cc900-compatible mode for our TLCS-900 LLVM backend (2026-11-08)

**Goal.** Teach our clang/LLVM TLCS-900 backend (`~/compartilhado/llvm-project`, branch `tlcs900_backend`) to
generate the same code as **the cc900 that Technics used**.  We do not have that compiler.  None of the three
Toshiba dev-kit compilers we can run is it (1998, 2003, 2009: `notes/toshiba-runtime-xref-2026-11-08/`).  So its
behaviour is inferred: the dev-kit compilers are the oracle for how cc900 works, and the firmware decides where the
Technics compiler differs from them (section 2).  A C function that we reconstruct from the firmware could then be
compiled back into the ROM's exact bytes ("matching decompilation").

**Secondary goal (Felipe, 2026-11-08).**  Imitate the three dev-kit compilers too, each behind its own variant flag,
as a by-product whenever that is cheap along the way.  They are what the Neo Geo Pocket (Color) homebrew scene builds
with, from SNK's SDK, so an open compiler that matches them is useful there.  The Neo Geo Pocket's CPU is a
TLCS-900/H core (MAME's `ngp` driver emulates it as a TMP95C061), not the KN5000's /H2, so these variants must also work
with `-mcpu=tlcs900h` and the SDK's memory model.  This goal never delays the main one.  It mostly reuses the main
work: V4.23 is the calibration base anyway, and the 2003 and 2009 behaviours are the candidate rules of section 2.

**Gate.** All of this is opt-in.  Without the new flags, clang's TLCS-900 output does not change: same ABI, same
optimisations, same bytes.  The C data tables the disasm build already compiles with clang depend on that.

**Not goals.**
- Running or reading Toshiba's programs anywhere but in the throwaway VM.
- Disassembling thc1 / thc2 to copy their algorithms.  The approach is black-box: we infer the behaviour from
  inputs and outputs (decision D2 below).
- Matching cc900's diagnostics, listings or debug records.
- Committing Toshiba's library sources, or the objects compiled from them, to a public repository.

## 1. What we know already

| fact                                                                                                   | evidence                                                                                           |
|--------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| cc900 (thc1, thc2, asm900, tulink) built the firmware, and Toshiba's runtime is linked into it         | `scripts/analysis/compiler_id/README.md`; `notes/toshiba-runtime-xref-2026-11-08/`                 |
| We can run three dev-kit cc900 versions, in a VM: V4.23 (1998), the kit CD's IDE (2003), v1.10 (2009)  | `vm-compile/` (V4.23 done); the other two have `thc1.exe`, `thc2.exe`, `asm900.exe`                |
| V4.23 at `-O3 -XS` rebuilds 147 of the 156 pieces of its own 1997 library                              | `notes/toshiba-runtime-xref-2026-11-08/README.md`, "Running V4.23"                                 |
| The Technics compiler is none of the three: a thc2 later than V0.8n.04.11 and earlier than 2003's      | same section; the `__doprnt` case table is 3 bytes off everywhere                                  |
| The firmware's runtime was compiled with `-O2`/`-O3` and `-XS`                                         | same section (the other option sets are 12 to 224 bytes off)                                       |
| The cc900 ABI: arguments on the stack, pushed right to left, the caller pops them; result in XHL       | V4.23's `-S` output for `_ultoa` / `_ldiv` (vm-compile runs); `compiler_id/zerotest_after_call.py` |
| `int` is 16 bits, pointers 32 bits ("large" / `$MAXIMUM`); struct results via a hidden first argument  | `_ultoa`'s `cpw (XSP+0x3e),0x2` and `exts XWA`; `_ldiv`'s `ld XIX,(XSP+0x18)`                      |
| The frame is `lda XSP,XSP-N` then `push XIZ`; only XIZ is preserved in the library                     | V4.23 `-O2`/`-O3` listings; `compiler_id/prologue_saves.py`                                        |
| `switch` becomes `add wa,wa ... jp t,(xix+wa)` with its table in `f_const`                             | `compiler_id/switchidiom.py`; the census's D detector                                              |
| Our backend today: arguments in XDE/XBC/XIX/XIY, result in XDE, 32-bit `int`, SSA optimiser, global RA | `llvm/lib/Target/TLCS900/README.md`; `clang/lib/Basic/Targets/TLCS900.h`                           |
| Our llvm-mc already assembles every firmware instruction to the ROM's bytes                            | `make gate`                                                                                        |

The last two rows set the size of the job.  The assembler side is done.  The ABI differs completely.  The code
generator's whole model differs too.  thc2 keeps locals in the frame and works statement by statement: it stores a
temporary to `(XSP+4)` and reads it back.  Its versions differ in how long they remember what a register holds.
LLVM's optimiser and register allocator never produce that shape.

## 2. Method: inferring the Technics compiler

There are three kinds of evidence.  Each answers a different question:

| evidence                                                                                              | what it gives                                                                                           | limit                                                                       |
|-------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| **the dev-kit compilers** (V4.23, 2003, 2009), run in the VM                                          | cc900's output for any C we write, at any option set: as much evidence as we want                       | none of them is the Technics compiler                                       |
| **source and binary pairs in the firmware**: Toshiba's runtime C sources and their copies in the ROMs | the Technics compiler's own output, on source we know exactly, at the options it used (`-O2`/`-O3 -XS`) | only as many routines as the runtime has, and only the constructs they use  |
| **the rest of the firmware's compiled code**, without source                                          | how often each idiom occurs in all of the Technics compiler's output that we hold                       | it can rule an idiom in or out, but it cannot show which source produced it |

The inference has three steps:
1. **Calibrate on the nearest neighbour.**  Make our imitation reproduce V4.23 exactly, on everything the oracle
   can be given.  V4.23 is the closest compiler we can run that is older than the Technics one, and the only one
   whose runtime build we have already reproduced.  An exact V4.23 shows that the model has cc900's machinery right.
   It is the base of the main goal, and the first by-product of the secondary one.
2. **List the candidate differences.**  The Technics compiler lies between V4.23 and the 2003 compiler.  So where
   those two differ on the same input, the Technics compiler probably did one or the other.  Each difference becomes
   a separate rule that can be switched on or off: the register-contents rule first (V4.23 reloads a value it has
   just stored; the firmware and 2003 do not).  The 2009 compiler shows which 2003 behaviours lasted, and that helps
   to group them.  Some Technics behaviours may match neither neighbour; the firmware pairs show those as
   differences that no rule explains.
3. **Decide each rule from the firmware.**  The source and binary pairs decide the rules they exercise: compile the
   runtime sources with each combination of rules, and the firmware's bytes pick one.  The idiom census decides
   others without source.  If a V4.23-only idiom (for example, a store followed by a reload of the same slot) never
   occurs in the firmware's compiled code, its rule is off.  A rule that neither decides stays marked undecided.
   Firmware functions that we later reconstruct (phase 6) decide more.

The result is one personality, `kn5000`: V4.23 plus the decided rules.  The other images that the same tools built
(sub CPU, HD-AE5000, SX-WSA1R) are checked against it in the same way.  If they need different rules, they get
personalities of their own.

## 3. Design

### 3.1 Two flags, not one

| flag                           | what it does                                                                                                                                                                                                      | useful without the other?                                                                     |
|--------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `-mabi=cc900`                  | cc900's data layout and calling convention: 16-bit `int`, cc900's alignment, stack arguments, XHL result, hidden struct-return pointer, the callee-saved set, cc900's helper names (`C9H_divls`, `._fadd_d`, ...) | yes: it lets our code link with Toshiba's objects and libraries, with LLVM's normal optimiser |
| `-mcc900-compat=<personality>` | replaces the optimiser and the code generator with a cc900 imitation.  It implies `-mabi=cc900`                                                                                                                   | no                                                                                            |

Personalities:
- `kn5000`: the Technics compiler, inferred as in section 2.  This is the main product.
- `v4.23`: the calibration base of step 1, and the compiler of SNK's Neo Geo Pocket Color SDK.  The oracle can check
  it exactly at any time, so a regression in the shared machinery shows up there first.
- `ide2003` and `v1.10`: by-products of the secondary goal.  Each is `v4.23` plus all the rules where that compiler
  differs, so phase 4's rule catalogue builds most of them.  They are finished, and checked exactly against their
  compiler in the oracle, when that is cheap (phase 7).

The cc900 option set comes with the personality: `-mcc900-opt=0..3` for thc's `-O`, and `-mcc900-size` for `-XS`.
These are separate from clang's own `-O`, so neither meaning leaks into the other.  Inside LLVM, the settings travel
as function attributes (`"tlcs900-cc900"="kn5000"`, `"tlcs900-cc900-opt"="3"`, `"tlcs900-cc900-size"`), plus a module
flag for the ABI.  So `llc`, `opt` and lit tests can use them without clang.

The two flags are kept apart on purpose.  The ABI is a real feature for anyone who has Toshiba objects.  The
imitation is a niche tool for matching.

### 3.2 How the imitation is built inside LLVM (recommendation, confirmed or rejected by the phase 0 spike)

Tuning LLVM's normal pipeline with knobs until it looks like cc900 is rejected.  The SSA passes (mem2reg, GVN,
instcombine, LICM) and the global register allocator rewrite code in ways thc1 / thc2 never did, and the knobs would
spread through the default backend.  Instead, the cc900 mode is its own pipeline, in its own files
(`TLCS900CC900*.cpp`).  `TLCS900TargetMachine` picks it only when the attribute is set:

1. **Front end.**  clang emits IR as at `-O0`: every local is an alloca, each C access is a load or store, in
   statement order, with no `optnone` and no lifetime markers.  In compat mode, clang also attaches what thc1 sees
   and LLVM IR loses: statement boundaries, the shape of each expression tree, declaration order of locals, the
   `register` keyword (`!cc900.*` metadata).
2. **"thc1" passes.**  These are a small set of IR passes, chosen by personality and `-mcc900-opt`.  Each reproduces
   one machine-independent transformation that the oracle shows thc1 does: which locals become register variables
   (XIZ ...), constant folding, the loop shape (`-XS` jumps to the test at the bottom instead of repeating it at the
   top), switch lowering to cc900's table form, and the like.  None of LLVM's standard optimisation passes run.
3. **"thc2" code generator.**  It takes each statement's expression tree and builds MachineInstrs with cc900's
   register roles (XWA/WA/A accumulator, XHL results, XBC second operand, XIX/XIY addresses), cc900's choice of
   memory operands, and its frame and slot layout.  It replaces SelectionDAG for these functions.  Its central
   piece is a **register-contents model**: what each register is known to hold after each instruction.  Most version
   differences are rules in that model.  The one difference we know between V4.23 and the Technics compiler is one
   of them: V4.23 forgets a value it has just stored and reloads it, and the Technics compiler remembers it.
4. **"asm900" choices.**  These are branch and call relaxation (`j` to `jr`/`jrl`, `cal` to `call`/`calr`) and the
   section layout (`f_code`, `f_const`, `f_data`, `f_area`, switch tables at the start of `f_const`).  They reuse the
   MC layer, which is already byte-exact, with a cc900 relaxation policy where asm900's choices differ from ours.

The spike in phase 0 checks this design on a dozen small library routines before anything large is built.  If a
FastISel-style selector with the register-contents model can reach the oracle's output, that is cheaper than a
separate tree code generator, and we use it.

### 3.3 Keeping the default untouched

- The ABI and the imitation are selected only by the flags and attributes above.  With neither set, the default
  `TargetInfo`, calling convention and pass pipeline run unchanged.
- The existing `llvm/test/CodeGen/TLCS900/*.ll` tests stay as they are and must keep passing.  New tests live in
  `llvm/test/CodeGen/TLCS900/cc900/` and `clang/test/CodeGen/tlcs900-cc900*.c`.
- A guard test compiles the disasm's C data tables with the new toolchain, without flags, and compares them with the
  old output: `make gate` already does this, because those tables are in the ROMs.

## 4. The evidence tools

### 4.1 The dev-kit oracle

`notes/toshiba-runtime-xref-2026-11-08/vm-compile/` is the seed.  It grows into a batch service:

| piece      | what it becomes                                                                                                                                                                                                                                 |
|------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| the VM     | one persistent guest with Wine and the three compiler trees.  It compiles a whole corpus in one boot (thousands of files)                                                                                                                       |
| inputs     | our own C test files (below), Toshiba's library sources (local only), and the C we reconstruct from the firmware                                                                                                                                |
| outputs    | thc2's `.asm` and asm900's `.rel` for each (version, option set, file).  They are Toshiba-generated, so they are kept out of public repos (D1)                                                                                                  |
| comparison | `ieee695.py` and `lib_match.py` already compare objects piece by piece with relocations masked.  Add a normalised asm-text diff (Toshiba syntax to ours) that shows *where* two outputs part                                                    |
| ledger     | for each verifiable personality against its compiler (`v4.23` first), per option set: the fraction of functions byte-identical, and the first differing instruction of each other function. Committed as dated snapshots, like `docs/coverage/` |
| rule list  | every behaviour that differs between V4.23 and the 2003 compiler, each with the smallest test that shows it, and its state for `kn5000`: on, off or undecided                                                                                   |

**Test corpus.**  The library sources cover few C constructs, so the corpus is mostly ours:
- **Micro-tests.**  One construct per file: each operator at each type (`char`, `int`, `long`, pointers, `float`,
  `double`); each storage class (auto, static, global, `register`, parameter); calls with 0 to 6 arguments; struct
  copies and struct returns; `switch` with dense and sparse cases; loops in each form; varargs.  These are generated
  by a script, so they are ours and can be committed.
- **Random programs.**  Small Csmith-style programs restricted to what cc900 accepts (C89, its integer sizes).
  These find interactions the micro-tests miss.
- **The library sources.**  Their oracle outputs are already measured.
- **Firmware reconstructions**, as they appear (phase 6).

### 4.2 The firmware evidence

- **The pairs list.**  Every runtime routine that the xref found in a ROM and whose C source is in `LIB/SRC`, with
  its address in each image.  For each one, the ledger records whether `kn5000` reproduces it, under which rule
  settings, and the first differing instruction if it does not.  The sources stay local; the list, addresses and
  results are committed.
- **The idiom census.**  For each candidate rule, a detector for the instruction pattern of each of its two
  behaviours, run over the firmware's compiled code.  These are like the existing `compiler_id/` scripts
  (`switchidiom.py`, `prologue_saves.py`).  A rule with one behaviour at zero occurrences and the other at many is
  decided.

## 5. Phases

| phase | what                                                                                                                                                                                                                                                                                                                                                                         | done when                                                                                                                                                                                                                                                                                                                                      |
|-------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0     | **Survey and spike.**  Write down cc900's ABI and frame rules from oracle listings: argument offsets, which registers a call clobbers, struct and float passing, alignment, CPU and memory-model options (`-ml`, `-ms`, H2 selection).  Count the firmware pairs.  Spike the 3.2 design on ~12 small library routines.                                                       | an ABI note with an oracle listing behind each rule; the pairs list (4.2) committed; the spike reproduces V4.23's output for most of those routines, or shows why not, and the design in 3.2 is confirmed or revised                                                                                                                           |
| 1     | **Evidence tools.**  The batch VM for all three dev-kit compilers, the corpus generator, the normalised diff, the ledger; the idiom-census framework.                                                                                                                                                                                                                        | one command compiles the corpus with all three versions and writes a ledger snapshot; the micro-test corpus covers every construct in section 4.1                                                                                                                                                                                              |
| 2     | **`-mabi=cc900`.**  clang `TargetInfo` (16-bit `int`, sizes, alignment), the calling convention, the libcall names, varargs, struct return.                                                                                                                                                                                                                                  | Code built with our normal optimiser links and runs with Toshiba's `c900ml.lib` (through an IEEE-695-to-ELF converter built on `ieee695.py`, or `tulink` in the VM).  This is checked in MAME's TLCS-900 core or in an emulated KN5000 test harness: call each library routine from our code and compare results. Default-mode tests unchanged |
| 3     | **Calibration: `v4.23`.**  The compat pipeline, level by level: `-mcc900-opt=0`, then 1, 2, 3, then each with `-mcc900-size`.  The levels the firmware used (`-O2`/`-O3 -XS`) come first.                                                                                                                                                                                    | 100% of micro-tests and of the library sources byte-identical to V4.23's own output at each of the seven option sets; random programs at an agreed rate (≥ 95%), every mismatch triaged                                                                                                                                                        |
| 4     | **Candidate rules.**  Run the corpus through V4.23, 2003 and 2009 at the firmware's options.  Turn each behaviour where V4.23 and 2003 differ into a switchable rule of the compat pipeline, with its smallest test.                                                                                                                                                         | every V4.23-to-2003 difference in the corpus is either a rule (on, its tests give 2003's output; off, V4.23's) or listed as unexplained                                                                                                                                                                                                        |
| 5     | **Personality `kn5000`.**  Decide each rule from the firmware (section 2, step 3): the pairs first, then the idiom census.  Look at the pairs that no rule setting reproduces: they are Technics behaviours that neither neighbour has, and they become new rules.                                                                                                           | every firmware pair is byte-identical under `kn5000` (`_ldiv`, `_ultoa`, `_ldexp` and `__doprnt` among them), checked locally; every rule is on, off or explicitly undecided, with its evidence in the rule list                                                                                                                               |
| 6     | **Matching decompilation in the disasm.**  A build rule that compiles a `.c` of *code* with `-mcc900-compat=kn5000` into the ROM, under `make gate`.  A diff tool for one function against the ROM.  Later, a permuter.  First targets: small, leaf, Matsushita-written functions.                                                                                           | the first firmware function built from our C is byte-identical in `make gate`; the ROM status diagram gets a "compiled C code" class                                                                                                                                                                                                           |
| 7     | **Other images, by-products and upkeep.**  Check the sub CPU, HD-AE5000 and SX-WSA1R pairs against `kn5000`.  Finish `ide2003` and `v1.10` from the rule catalogue, and check `v4.23` with `-mcpu=tlcs900h` on Neo Geo Pocket code (the SDK's samples and library).  The documentation; the website's backend pages.  Undecided rules are revisited as phase 6 decides them. | each image's pairs have a ledger line; each by-product personality has its ledger line against its own compiler; the backend's README describes the flags, the personalities and the rule list                                                                                                                                                 |

Phases 1 and 2 can run in parallel.  Phase 3 needs both.  Phase 4 needs phase 3.  Phase 5 needs phase 4.  Phase 6 can
start once phase 5 has decided the rules that its first functions exercise.

## 6. Risks

- **Information lost between C and LLVM IR.**  thc1 sees the syntax tree.  Some of its choices may depend on things
  clang's IR does not keep (an expression's shape, `for` versus `while`, a temporary's scope).  The `!cc900.*`
  metadata is the mitigation.  If that is not enough, a clang-side lowering for compat mode (from the AST) is the
  fallback.  The spike in phase 0 should find this early.
- **Behaviours the corpus never exercises.**  A rule that the oracle never shows cannot be learnt.  The
  micro-test generator and the random programs are there to keep that set small.  The ledger's "first differing
  instruction" lists show what remains.
- **The Technics compiler can only be inferred.**  The pairs are few, and they use few constructs.  Some rules will
  stay undecided until reconstructed firmware functions exercise them.  The rules learnt from V4.23-to-2003 may also
  not split the way the Technics version did: one 2003 behaviour may be two changes made at different times.  So
  phase 5 decides each rule separately, and the pairs that no setting reproduces are treated as new rules.
- **Two compilers to keep correct.**  The default backend and the compat pipeline share the MC layer and little else.
  The compat pipeline needs its own regression tests, and ABI bugs in it show up only at run time (phase 2's
  emulator check).
- **Effort.**  Phase 3 is the large one: a second code generator, whose size is not known until the phase 0 spike.
  Phases 4 and 5 are bounded by how many rules the neighbours' differences turn out to need.

## 7. Decisions (Felipe, 2026-11-08: plan approved)

| #  | question                                                                            | decision                                                                                                                                                                                                               |
|----|-------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| D1 | Where do the oracle's outputs (Toshiba-generated `.asm` / `.rel`) live?             | in the private git repository `~/compartilhado/cc900-oracle/`, which has no remote and a `pre-push` hook that refuses; public notes cite those files by SHA-256.  Set up the same day, with V4.23 runs 1-3             |
| D2 | Black-box only, or may thc1 / thc2 themselves be disassembled to learn their rules? | black-box only, for now; Felipe may reconsider it later                                                                                                                                                                |
| D3 | Flag names                                                                          | as proposed: `-mabi=cc900`, `-mcc900-compat=<personality>`, `-mcc900-opt=N`, `-mcc900-size`                                                                                                                            |
| D4 | Is the backend meant for LLVM upstream?                                             | yes.  So the compat pipeline stays in its own files behind the attribute check, and `-mabi=cc900` is written to upstream standards; whether the compat mode itself is proposed upstream is decided when the backend is |
| D5 | May the oracle VM stay on the share permanently?                                    | yes.  It moved from `~/compartilhado/tmp/cc900-vm/` to `~/compartilhado/cc900-oracle/vm/` (git-ignored there), about 2.8 GB                                                                                            |
| D6 | (raised by Felipe) Should the dev-kit compilers be imitated too?                    | yes, as a secondary goal: one variant flag per compiler (`v4.23`, `ide2003`, `v1.10`), produced as a by-product whenever that is viable, for the Neo Geo Pocket homebrew scene                                         |

## 8. Working rules that apply

- Toshiba executables run only in the VM.  Their outputs and the library sources stay out of this repository and out
  of the LLVM fork.
- Each LLVM commit that produces verified ROM artefacts is immutable.  The disasm's `TOOLCHAIN_VERSION` and the
  `LLVM:` trailer follow the toolchain as usual.
- Every number in a ledger or note comes with the script that produced it, committed beside it.
