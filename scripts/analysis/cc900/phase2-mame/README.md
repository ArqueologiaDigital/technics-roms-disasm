# Phase 2 exit test: `-mabi=cc900` code against Toshiba's library, run in MAME

**Question:** does code that our clang builds with `-mabi=cc900` call Toshiba-compiled runtime code correctly
(argument passing, results, the long-division helpers)?  PLAN.md's phase 2 asks for it to "link and run with
Toshiba's c900ml.lib, checked in emulation".

**Method:** the KN5000 v10 firmware contains Toshiba-compiled library routines at known addresses (the source/binary
pairs, `../results/pairs.tsv`, and the helpers of `notes/toshiba-runtime-xref-2026-11-08/results/xref.*.tsv`).
`test.c` calls them (`strlen`, `strcpy`, `strcat`, `strncmp`, `strchr`, `memset`, `memcpy`, `ultoa`, and long `/` and
`%`, which our backend turns into `C9H_divlu` / `C9H_remlu`); `run.sh` builds it, binds each name to its firmware
address with `ld.lld --defsym`, and runs MAME's kn5000 driver with `harness.lua`: after about ten seconds of boot
the script copies the binary into work DRAM at 0xE0000, sets PC there (`start.s`: `di`, a private stack, call the
test, loop) and reads the result block when `R.magic` becomes 0xc900.

| file          | what it is                                                    |
|---------------|---------------------------------------------------------------|
| `test.c`      | the test program (cdecl, `-mabi=cc900`)                       |
| `start.s`     | entry stub                                                    |
| `harness.lua` | MAME autoboot script: load, run, read results                 |
| `run.sh`      | build, link, run, compare; prints the results and PASS / FAIL |

Run: `sh run.sh` (defaults: `MAME=~/compartilhado/kn5000dsp_build/kn7000`, `ROMS=~/compartilhado/technics_roms/roms`,
the LLVM build in `~/compartilhado/llvm-project/build/bin`).  Result on 2026-11-09 with the UPDATE 22 toolchain: PASS,
all ten values as expected (`len5 5`, `len3 3`, `cmp_lt 1`, `cmp_eq 1`, `chr_off 4`, `quot 142857`, `rem 1`,
`cat abcdef`, `hex 123456`, `fill xxxx`).

Two backend gaps this test found (phase2.md):
- clang cannot emit an object file for a function with a conditional branch out of `jr` range: the TLCS900 backend
  does not relax `jr` to `jrl` ("fixup value out of range for 8-bit relative branch").  `run.sh` compiles to
  assembly and relaxes with `../model/to_llvm.py`'s `relax()`;
- llvm-mc resolves a numeric local label (`1:` / `jr 1b`, `jr 2f`) to the label's offset instead of a PC-relative
  displacement (`jr 1b` from offset 3 to offset 2 assembles as `68 02`).  `start.s` uses a named label.
