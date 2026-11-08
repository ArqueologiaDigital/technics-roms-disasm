# Plan: a cc900-compatible mode for our TLCS-900 LLVM backend (2026-11-08)

**Goal.** Teach our clang/LLVM TLCS-900 backend (`~/compartilhado/llvm-project`, branch `tlcs900_backend`) to
generate the same code as Toshiba's cc900.  It should be exact for the compiler versions we have, and inferred for
the one that built the KN5000 firmware.  The compiler versions we have serve as the oracle.  A C function that we
reconstruct from the firmware could then be compiled back into the ROM's exact bytes ("matching decompilation").

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
| We can run three cc900 versions, in a VM: V4.23 (1998), the kit CD's IDE (2003), v1.10 (2009)          | `vm-compile/` (V4.23 done); the other two have `thc1.exe`, `thc2.exe`, `asm900.exe`                |
| V4.23 at `-O3 -XS` rebuilds 147 of the 156 pieces of its own 1997 library                              | `notes/toshiba-runtime-xref-2026-11-08/README.md`, "Running V4.23"                                 |
| The firmware's compiler is none of the three: a thc2 later than V0.8n.04.11 and earlier than 2003's    | same section; the `__doprnt` case table is 3 bytes off everywhere                                  |
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

## 2. Design

### 2.1 Two flags, not one

| flag                           | what it does                                                                                                                                                                                                      | useful without the other?                                                                     |
|--------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| `-mabi=cc900`                  | cc900's data layout and calling convention: 16-bit `int`, cc900's alignment, stack arguments, XHL result, hidden struct-return pointer, the callee-saved set, cc900's helper names (`C9H_divls`, `._fadd_d`, ...) | yes: it lets our code link with Toshiba's objects and libraries, with LLVM's normal optimiser |
| `-mcc900-compat=<personality>` | replaces the optimiser and the code generator with a cc900 imitation.  It implies `-mabi=cc900`                                                                                                                   | no                                                                                            |

Personalities:
- `v4.23`: the 1998 compiler.  The oracle can verify it exactly.
- `ide2003` and `v1.10`: the later compilers.  The oracle can verify them exactly.
- `kn5000`: the firmware's compiler, inferred (phase 4).

The cc900 option set comes with the personality: `-mcc900-opt=0..3` for thc's `-O`, and `-mcc900-size` for `-XS`.
These are separate from clang's own `-O`, so neither meaning leaks into the other.  Inside LLVM, the settings travel
as function attributes (`"tlcs900-cc900"="v4.23"`, `"tlcs900-cc900-opt"="3"`, `"tlcs900-cc900-size"`), plus a module
flag for the ABI.  So `llc`, `opt` and lit tests can use them without clang.

The two flags are kept apart on purpose.  The ABI is a real feature for anyone who has Toshiba objects.  The
imitation is a niche tool for matching.

### 2.2 How the imitation is built inside LLVM (recommendation, confirmed or rejected by the phase 0 spike)

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
   differences are rules in that model.  The V4.23-to-firmware difference is one of them: V4.23 forgets a value it
   has just stored and reloads it, and the firmware's compiler remembers it.
4. **"asm900" choices.**  These are branch and call relaxation (`j` to `jr`/`jrl`, `cal` to `call`/`calr`) and the
   section layout (`f_code`, `f_const`, `f_data`, `f_area`, switch tables at the start of `f_const`).  They reuse the
   MC layer, which is already byte-exact, with a cc900 relaxation policy where asm900's choices differ from ours.

The spike in phase 0 checks this design on a dozen small library routines before anything large is built.  If a
FastISel-style selector with the register-contents model can reach the oracle's output, that is cheaper than a
separate tree code generator, and we use it.

### 2.3 Keeping the default untouched

- The ABI and the imitation are selected only by the flags and attributes above.  With neither set, the default
  `TargetInfo`, calling convention and pass pipeline run unchanged.
- The existing `llvm/test/CodeGen/TLCS900/*.ll` tests stay as they are and must keep passing.  New tests live in
  `llvm/test/CodeGen/TLCS900/cc900/` and `clang/test/CodeGen/tlcs900-cc900*.c`.
- A guard test compiles the disasm's C data tables with the new toolchain, without flags, and compares them with the
  old output: `make gate` already does this, because those tables are in the ROMs.

## 3. The oracle: differential testing against Toshiba's compilers

`notes/toshiba-runtime-xref-2026-11-08/vm-compile/` is the seed.  It grows into a batch service:

| piece      | what it becomes                                                                                                                                                                              |
|------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| the VM     | one persistent guest with Wine and the three compiler trees.  It compiles a whole corpus in one boot (thousands of files)                                                                    |
| inputs     | our own C test files (below), Toshiba's library sources (local only), and the C we reconstruct from the firmware                                                                             |
| outputs    | thc2's `.asm` and asm900's `.rel` for each (version, option set, file).  They are Toshiba-generated, so they are kept out of public repos (D1)                                               |
| comparison | `ieee695.py` and `lib_match.py` already compare objects piece by piece with relocations masked.  Add a normalised asm-text diff (Toshiba syntax to ours) that shows *where* two outputs part |
| ledger     | per personality and option set: the fraction of functions byte-identical, and the first differing instruction of each other function. Committed as dated snapshots, like `docs/coverage/`    |

**Test corpus.**  The library sources cover few C constructs, so the corpus is mostly ours:
- **Micro-tests.**  One construct per file: each operator at each type (`char`, `int`, `long`, pointers, `float`,
  `double`); each storage class (auto, static, global, `register`, parameter); calls with 0 to 6 arguments; struct
  copies and struct returns; `switch` with dense and sparse cases; loops in each form; varargs.  These are generated
  by a script, so they are ours and can be committed.
- **Random programs.**  Small Csmith-style programs restricted to what cc900 accepts (C89, its integer sizes).
  These find interactions the micro-tests miss.
- **The library sources.**  Their oracle outputs are already measured.
- **Firmware reconstructions**, as they appear (phase 5).

## 4. Phases

| phase | what                                                                                                                                                                                                                                                                                        | done when                                                                                                                                                                                                                                                                                                                                      |
|-------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0     | **Survey and spike.**  Write down cc900's ABI and frame rules from oracle listings: argument offsets, which registers a call clobbers, struct and float passing, alignment, CPU and memory-model options (`-ml`, `-ms`, H2 selection).  Spike the 2.2 design on ~12 small library routines. | an ABI note with an oracle listing behind each rule; the spike reproduces V4.23's output for most of those routines, or shows why not, and the design in 2.2 is confirmed or revised                                                                                                                                                           |
| 1     | **Oracle service.**  Batch VM for all three versions, the corpus generator, the normalised diff, the ledger.                                                                                                                                                                                | one command compiles the corpus with all three versions and writes a ledger snapshot; the micro-test corpus covers every construct in section 3                                                                                                                                                                                                |
| 2     | **`-mabi=cc900`.**  clang `TargetInfo` (16-bit `int`, sizes, alignment), the calling convention, the libcall names, varargs, struct return.                                                                                                                                                 | Code built with our normal optimiser links and runs with Toshiba's `c900ml.lib` (through an IEEE-695-to-ELF converter built on `ieee695.py`, or `tulink` in the VM).  This is checked in MAME's TLCS-900 core or in an emulated KN5000 test harness: call each library routine from our code and compare results. Default-mode tests unchanged |
| 3     | **Personality `v4.23`.**  The compat pipeline, level by level: `-mcc900-opt=0`, then 1, 2, 3, then each with `-mcc900-size`.                                                                                                                                                                | 100% of micro-tests and of the library sources byte-identical to V4.23's own output at each of the seven option sets; random programs at an agreed rate (≥ 95%), every mismatch triaged                                                                                                                                                        |
| 4     | **Personality `kn5000`.**  Diff V4.23 and the 2003 compiler on the corpus.  Each behaviour that differs becomes a separate rule (the register-contents rule first).  Turn the rules on one at a time until the firmware's runtime routines come out.                                        | Compiling Toshiba's sources with `kn5000 -mcc900-opt=3 -mcc900-size` gives the firmware's bytes for `_ldiv`, `_ultoa`, `_ldexp`, `__doprnt`, and for every runtime routine the xref found in the firmware. Checked locally: Toshiba's sources are not committed                                                                                |
| 5     | **Matching decompilation in the disasm.**  A build rule that compiles a `.c` of *code* with `-mcc900-compat=kn5000` into the ROM, under `make gate`.  A diff tool for one function against the ROM.  Later, a permuter.  First targets: small, leaf, Matsushita-written functions.          | the first firmware function built from our C is byte-identical in `make gate`; the ROM status diagram gets a "compiled C code" class                                                                                                                                                                                                           |
| 6     | **Ports and upkeep.**  `ide2003` and `v1.10` personalities, if wanted (they cost little once phase 4 has the rules); the documentation; the website's backend pages.                                                                                                                        | each personality has its ledger line; README of the backend describes both flags                                                                                                                                                                                                                                                               |

Phases 1 and 2 can run in parallel.  Phase 3 needs both.  Phase 4 needs phase 3 and the 2003 oracle.

## 5. Risks

- **Information lost between C and LLVM IR.**  thc1 sees the syntax tree.  Some of its choices may depend on things
  clang's IR does not keep (an expression's shape, `for` versus `while`, a temporary's scope).  The `!cc900.*`
  metadata is the mitigation.  If that is not enough, a clang-side lowering for compat mode (from the AST) is the
  fallback.  The spike in phase 0 should find this early.
- **Behaviours the corpus never exercises.**  A rule that the oracle never shows cannot be learnt.  The
  micro-test generator and the random programs are there to keep that set small.  The ledger's "first differing
  instruction" lists show what remains.
- **The firmware personality is inferred.**  No oracle exists for it; the firmware's bytes are the only check, and
  only for code whose C we can reconstruct.  The rules learnt from V4.23-to-2003 may not split the way the firmware's
  version did.  Phase 4 tests each rule separately against the runtime routines for that reason.
- **Two compilers to keep correct.**  The default backend and the compat pipeline share the MC layer and little else.
  The compat pipeline needs its own regression tests, and ABI bugs in it show up only at run time (phase 2's
  emulator check).
- **Effort.**  Phase 3 is the large one: a second code generator.  Its size is not known until the phase 0 spike.

## 6. Decisions for Felipe

| #  | decision                                                                                                                                                     | recommendation                                                                                                                       |
|----|--------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| D1 | Where do the oracle's outputs (Toshiba-generated `.asm` / `.rel`) live?                                                                                      | a private git repository on the share, never pushed (for example `~/compartilhado/cc900-oracle/`), with their hashes in public notes |
| D2 | Black-box only, or may thc1 / thc2 themselves be disassembled to learn their rules?                                                                          | black-box only.  It keeps the implementation clearly ours, and the oracle answers most questions                                     |
| D3 | Flag names: `-mabi=cc900` and `-mcc900-compat=<personality>` / `-mcc900-opt=N` / `-mcc900-size`?                                                             | as proposed.  They name the toolchain being imitated, and they are clearly not clang's own `-O`                                      |
| D4 | Is the backend meant for LLVM upstream one day?                                                                                                              | if so, keep the compat pipeline in its own files behind the attribute check (as planned), so it can stay out of tree                 |
| D5 | May the oracle VM, its Debian image and Wine stay on the share permanently (about 3 GB in `~/compartilhado/tmp/cc900-vm/`, to move somewhere less volatile)? | yes; the README rebuilds it, but phase 1 runs it often                                                                               |

## 7. Working rules that apply

- Toshiba executables run only in the VM.  Their outputs and the library sources stay out of this repository and out
  of the LLVM fork.
- Each LLVM commit that produces verified ROM artefacts is immutable.  The disasm's `TOOLCHAIN_VERSION` and the
  `LLVM:` trailer follow the toolchain as usual.
- Every number in a ledger or note comes with the script that produced it, committed beside it.
