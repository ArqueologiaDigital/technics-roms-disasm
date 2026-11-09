# Phase 2 report: `-mabi=cc900` in the LLVM fork (2026-11-09)

`-mabi=cc900` (and `-mcc900-adecl`) is implemented on `tlcs900_backend` in eight commits, `80fb7c8b63d8` ..
`edc018e026cb`.  Without the new flags the output is unchanged.  The fork's
`llvm/lib/Target/TLCS900/README.md` documents the ABI.

| #  | commit         | what it does                                                                                                         |
|----|----------------|----------------------------------------------------------------------------------------------------------------------|
| 1  | `80fb7c8b63d8` | `retd` is 3 bytes but was sized as 2, which miscounted branch distances (nothing emitted `retd` before)             |
| 2  | `f9b58e842847` | LLVM calling conventions `tlcs900_cdeclcc` (124), `tlcs900_adeclcc` (125), one for the C9H helpers (126), IR keywords |
| 3  | `4cb68a4bb249` | backend `-target-abi=cc900`: data layout, cdecl, adecl with `retd N`, XHL results, hidden result pointer, XIZ the only callee-saved register, `C9H_divls/divlu/remls/remlu` with XWA/XBC (`TLCS900ISelLoweringCC900.cpp`, 8 tests in `llvm/test/CodeGen/TLCS900/cc900/`) |
| 4  | `bf843df4bd75` | memcpy/memmove with a 16-bit length (cc900's `size_t`), which crashed the backend                                    |
| 5  | `c94ae968b1ae` | clang attributes `tlcs900_cdecl` / `tlcs900_adecl`, `-fdefault-calling-conv=tlcs900_adecl`, cc900's adecl restrictions as errors |
| 6  | `f40366e5265c` | clang `-mabi=cc900`: sizes, alignments, `size_t` = unsigned int, `ptrdiff_t` = long, `wchar_t` = int (Toshiba's STDDEF.H); `-mcc900-adecl`; the module flag |
| 7  | `b338ef3daac0` | clang's cc900 argument and result classification (`clang/lib/CodeGen/Targets/TLCS900.cpp`)                          |
| 8  | `edc018e026cb` | the README section                                                                                                    |

One small generic clang hook was added for "a struct of one char has sizeof 2": `TargetInfo::getMinRecordAlign()`,
set only by tlcs900 under cc900; packed structs are exempt.

## Verification

- TLCS900 CodeGen and MC lit tests: 105 of 105 pass (re-run 2026-11-09 after the agent's report).
- The 104 `v10/maincpu` C files compiled with the Makefile's commands before and after: byte-identical once the
  `.comment` section (clang's version string) is removed.  Harness and baseline SHA-256s: research-scratch
  `9c5a528`, `sessions/2026-11-09_cc900-ab/`.  `llc` output at -O2 and -O0 for every existing TLCS900 `.ll` test:
  identical.
- `make gate` and `make gate-wsa1` with the new toolchain: see the commit that records this toolchain
  (`TOOLCHAIN_VERSION`, UPDATE 22).
- The ABI probes: all eleven compile under `-mabi=cc900`; with `-mcc900-adecl` clang refuses exactly the lines cc900
  refuses (returns.c 10-15, fptr.c 13/14/17, args_callee.c 8/9, varargs.c 3/6/7).  A smoke test shows cc900's
  argument offsets (+4, +6, +8, +12 for char, int, long, pointer) and adecl's `retd 2`.
- Smoke-tested sizes under `-mabi=cc900`: int 2, long double 10, a one-char struct 2, size_t 2.

## Gaps and guesses (from the implementation report)

- Callers move XSP (`sub xsp,N`, stores, call, `add xsp,N`) instead of pushing: the stack layout is cc900's, the
  code is not.  That is phase 3b's concern.
- No extension attributes: a callee extends a narrow argument itself if needed; the caller does not.
- Unprobed: a struct or double among the first three adecl arguments (put on the stack, using up its register
  position); a char as the 2nd/3rd adecl argument (assumed C / E); long double's encoding (x87 80-bit placeholder);
  union alignment; whether char arrays get the even-address rule.
- C9H helpers are assumed to preserve XIZ; long multiply stays inline, so `C9H_mulls` is registered but unused.
- memset's length is passed as 4 bytes (harmless: it is the last argument and cc900 reads the low half).
- Out of scope: float/double helpers (still LLVM's `__addsf3` ...), the `_` / `.` symbol prefixes, bit fields,
  enum size; adecl checks cover C function declarations only.

## Found, not fixed: a bug in the default ABI

The default (non-cc900) convention reads a 5th argument from `(xsp)`, the return address, instead of `(xsp+4)`.
Fixing it changes default output, so it was left for a separate, deliberate change.

## The exit criterion: met through the firmware's copies of the library (2026-11-09)

PLAN.md asks that code built with `-mabi=cc900` link and run against Toshiba's `c900ml.lib`, checked in emulation.
`scripts/analysis/cc900/phase2-mame/` does this without converting the IEEE-695 library: the KN5000 v10 firmware
already contains Toshiba-compiled library routines (the source/binary pairs) and the `C9H_*` helpers, so the test
program, built by our clang with `-mabi=cc900`, is linked against those addresses and run in MAME's kn5000 driver.
`strlen`, `strcpy`, `strcat`, `strncmp`, `strchr`, `memset`, `memcpy`, `ultoa` and the long division helpers
`C9H_divlu` / `C9H_remlu` all return the expected values: **PASS** (the README there has the command and the values).

Two backend bugs the test found, both outside the default code paths that the ROM build uses:
- **no `jr` to `jrl` relaxation:** clang fails with "fixup value out of range for 8-bit relative branch" on a
  function whose conditional branch spans more than 127 bytes; the test relaxes the assembly itself;
- **numeric local labels:** llvm-mc encodes `jr 1b` / `jr 2f` with the label's section offset as the displacement
  (`68 02` for a jump from offset 3 back to offset 2).  This made the first runs fail mysteriously: the test's end
  loop jumped into the middle of the test function and overwrote its results.  Named labels are correct.
The label bug is fixed in the fork (`91a65b6ddfd1`, TOOLCHAIN_VERSION UPDATE 23: `make gate` and `make gate-wsa1`
still byte-identical, a new lit test).  The missing relaxation is still open: it belongs in the code generator
(branch relaxation choosing `jrl`), not in the assembler, since the ROM sources' explicit `jr` must stay an error when
out of range.
