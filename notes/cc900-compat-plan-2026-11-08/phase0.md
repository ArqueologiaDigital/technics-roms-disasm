# Phase 0 report: survey and spike (2026-11-08)

Phase 0 of `PLAN.md` asked for an ABI note, the pairs list, and a spike of design 3.2.  All three are done; the spike
**revised** the design (section 4 below).  Tools are in `scripts/analysis/cc900/` (its README); oracle outputs are in
the private `~/compartilhado/cc900-oracle` (runs `2026-11-08-1` to `-6`).

## 1. The ABI (`abi.md`)

The three dev-kit compilers share one ABI, so `-mabi=cc900` is a single target:
- 16-bit `int`, signed `char`, 4-byte pointers, 8-byte IEEE `double`, 10-byte `long double`, nothing aligned past 2;
- two function types.  **cdecl** (the default, and the library's): every argument on the stack, right to left, the
  caller pops.  **adecl** (`__adecl`, `#pragma adecl`, `-Xr`): the first three arguments in XWA / XBC / XDE, the rest
  on the stack left to right, the callee pops with `retd`; no float or struct results, no varargs; symbols prefixed
  `.` instead of `_`;
- results in L / HL / XHL; larger structs and `double` through a hidden first argument;
- XIZ is the only callee-saved register; IZ and QIZ hold register variables.

**The firmware's own C is adecl** (register arguments, `retd`, homed register arguments), calling the cdecl library
through `__CDECL` prototypes.  The plan assumed cdecl throughout; both conventions are needed.

## 2. The pairs and the baseline

`pairs.py` lists 291 source/binary pairs over 14 images: Toshiba runtime routines compiled from C whose copy in a ROM
is known (`results/pairs.tsv`).  `pairs_check.py` compares any objects with them.

| objects                                                     | pairs reproduced | file                                 |
|-------------------------------------------------------------|------------------|--------------------------------------|
| V4.23, its own 1997 sources, `-O3 -XS -DFLOAT` (run 3)      | 226 of 291       | `results/pairs_v423_O3XS.tsv`        |
| V4.23, the same, its headers, run 5 (`_ctype` now compiles) | 235 of 291       | `results/pairs_libsrc97_v423.tsv`    |
| the 2003 compiler on the same 1997 sources (run 5)          | 208 of 291       | `results/pairs_libsrc97_ide2003.tsv` |
| v1.10 on the same 1997 sources (run 5)                      | 191 of 291       | `results/pairs_libsrc97_v110.tsv`    |

## 3. The method works: the firmware splits the V4.23-to-2003 changes

With the same sources, the same headers and the same options, the firmware sides with different compilers for
different routines (`pairs_compare.py`, `results/pairs_libsrc97_groups.md`):

| reproduced by       | pairs | what it means                                                                                                                                                             |
|---------------------|-------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| all three           | 172   | code where the compilers agree                                                                                                                                            |
| V4.23 only          | 40    | `_memccpy`, `_strrchr`, `_strrev`, `_cos`, `_sin`, `_tan`, `_exp`, `_log`, `_modf`, `__trig`: changes the Technics compiler does **not** have                             |
| 2003 and v1.10 only | 16    | `_ldiv`, `_ultoa`, `_ldexp`: a change it **does** have                                                                                                                    |
| V4.23 and 2003      | 20    | `_atoi`, `_atol`, `_strncmp`: changed only by 2009                                                                                                                        |
| none                | 40    | `__doprnt`, `__facnv`, `__doform`'s data, `_vsprintf` (2), `_sbrk`, `___ctype` naming, `__FloatErrorHandle`: need a combination of rules, or a rule neither neighbour has |

So the Technics compiler is V4.23 plus some of the changes that 2003 shows, as section 2 of the plan assumed.  The
first three rules, from diffs of V4.23 and 2003 on those routines:

| rule                | V4.23                            | 2003                                  | Technics | decided by                                                                                |
|---------------------|----------------------------------|---------------------------------------|----------|-------------------------------------------------------------------------------------------|
| reload-after-store  | stores a value, then reloads it  | keeps it (or reloads later, `_ultoa`) | as 2003  | pairs `_ldiv`, `_ultoa`, `_ldexp`                                                         |
| djnz-loop           | `djnz BC,L`                      | `sub BC,1` / `j ne,L`                 | as V4.23 | pair `_strrchr`; census: 171 `djnz` against 1 in main CPU v10 (`results/idiom_census.md`) |
| call-register-alloc | arguments re-read from the frame | more values kept in XIZ / XBC         | as V4.23 | pair `_memccpy`                                                                           |

## 4. The spike: design 3.2 is revised

Design 3.2 assumed a statement-at-a-time code generator with a register-contents model.  The listings and the
v1.10 manual (C compiler reference, chapter 6 "Optimizations") show a **global optimizing compiler**:
- every auto variable is assigned a register when possible, with registers shared between variables whose lifetimes
  do not overlap (manual 6.1.1).  In leaf functions, parameters live in XHL / XDE / XIX / BC and `int` locals in
  IX / IY (`_strncpy`, `_atoi`); across calls, in IZ / QIZ;
- copy and constant propagation, common subexpressions, loop-invariant motion and induction variables (6.1.6-6.1.8):
  `_atoi` hoists `lda XBC,__ctype` out of its loops;
- branch optimizations (6.1.4): jump tables from six dense cases, return duplication (off under `-XS`), tail merging
  (`_atoi`'s `-` and `+` branches share one `inc XHL`), conditional returns (`ret ge`);
- one stack release for consecutive cdecl calls (6.1.2), post-increment operands, loop rotation under `-XS`.

That is far more than a per-statement generator.  The revised design keeps the pipeline's outline (clang front end;
a separate cc900 path in its own files, behind the attribute; the shared MC layer) and changes its middle:

1. **A reference model first, in Python** (`scripts/analysis/cc900/model/`, phase 3a).  It reads clang's AST
   (`-ast-dump=json`, which keeps the syntax thc1 sees) and writes Toshiba-syntax assembly, so it can be compared
   with the oracle's `.asm` line by line.  Learning cc900's rules (which variable gets which register, which
   expressions are hoisted, how branches are laid out) is the uncertain part, and a model that is cheap to change is
   the fastest way through it.  It is also the executable specification the LLVM implementation is tested against.
2. **The LLVM implementation follows the model** (phase 3b): the clang-side input it needs (AST-level or IR with
   `!cc900.*` metadata, whichever the model shows is necessary), cc900-specific passes for the optimizations of
   chapter 6, a cc900 register allocator, and cc900 instruction selection.  LLVM's own passes are reused only where
   the oracle shows identical decisions.
3. **The rules of section 3 become switches of both**, so `kn5000`, `v4.23`, `ide2003` and `v1.10` stay selectable.

The size of phase 3 grows accordingly: it is a re-implementation of a 1990s optimizing compiler, matched to its
output.  The phases after it are unchanged.

## 5. What phase 0 did not settle

- `__doprnt` and `__facnv`: whether a combination of the known rules reproduces them, or new rules are needed.
- How many of the firmware's 124 + 100 store-then-reload pairs are homed adecl arguments; whether the firmware was
  compiled with `-Xr` or with per-function qualifiers.
- Which of the two `switch` forms and register choices thc2 picks in each situation: phase 1's micro-tests.
