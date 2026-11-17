# cc900 C for the SX-WSA1R (lane_ws, 2026-11-17)

Goal (coordinator, 2026-11-17): write C for the SX-WSA1R program images (`wsa1/prom_a`, `prom_b`, `prom_c`) that
Toshiba cc900 V4.23 compiles to the ROM's bytes, as lane_p6 / lane_sub / lane_hd do for the KN5000.  The first
question was whether the WSA1R was compiled by cc900 V4.23 at all, and with which options.

## Answer: none of the cc900 versions we hold compiled the WSA1R (run `2026-11-17-8-ws-r1`)

24 small leaf functions (10 of prom_a, 6 of prom_b, 8 of prom_c; `scripts/analysis/cc900/corpus/firmware/ws_a_1.c`,
`ws_b_1.c`, `ws_c_1.c`) were compiled by the three compilers of the oracle (`v423`, `ide2003`, `v110`) at eight
option sets each: no option, `-g`, `-O0`, `-O3`, `-O3 -XS`, `-Xr`, `-O3 -Xr`, `-O3 -XS -Xr`.  All 72 listings
compiled.  **0 of 24 functions match in any of the 24 compiler / option combinations, and every one differs at its
first byte** (`verdicts/2026-11-17-8-ws-r1.tsv`, written by `wsa_v423.py check`).  No listing of the run, and no
listing of any earlier run in the oracle repository, contains `link` or `unlk`.

The difference is systematic, not a matter of C spelling.  The WSA1R's compiled code follows another code
generator's conventions (read from the trees' sources with `show.py`; the counts are `survey.py`'s):

| trait                     | SX-WSA1R ROM                                                                                               | cc900 V4.23 / 2003 / v1.10 (abi.md, and this run)                             |
|---------------------------|------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| frame                     | `link xiz, -N` .. `unlk xiz` in every function with arguments or locals; arguments at `(xiz+8)` and up     | no frame pointer; arguments at `(xsp+4)` and up, locals by `lda xsp, (xsp-N)` |
| trivial setter            | 14 B (`link`, load the argument into a register, store, `unlk`, `ret`)                                     | 6 B (one memory-to-memory move and `ret`)                                     |
| 8 / 16-bit result         | A / WA                                                                                                     | L / HL                                                                        |
| 32-bit and pointer result | XIY (`ld xiy, xwa` before the exit)                                                                        | XHL                                                                           |
| scratch registers         | XWA, XBC, XIY                                                                                              | XWA, XBC, XDE, XHL, XIX, XIY                                                  |
| callee-saved              | HL, DE (pushed as words), XIX (pushed whole), in that order after `link`; XIZ is the frame pointer         | XIZ only                                                                      |
| argument cleanup          | the caller, by `pop` into a scratch register (`popw bc`, `pop xbc`, `pop xiy`)                             | the caller (plain) or the callee with `retd N` (`-Xr`)                        |
| arguments                 | always on the stack (no register arguments anywhere)                                                       | stack (plain) or XWA / XBC / XDE with `retd` (`-Xr`)                          |
| runtime library           | 38 helpers ending in `retd`, wide results through XIY (`wsa1/notes/FINDINGS-prom_c-eeprom-and-runtime.md`) | Toshiba's `C9H_*` helpers; `results/pairs.tsv` has no WSA1R pair              |
| byte-to-pointer index     | `extz bc` then `extz xbc` (two steps)                                                                      | one extension                                                                 |

So the WSA1R (1995) was built with a different compiler from the KN5000 (1997-98): an older generation of
Toshiba's TLCS-900 C compiler or another vendor's.  Which one is not established; nothing here identifies it.
The KN5000's own images carry a few routines in this older convention (`v10/maincpu/boot/system_handlers.s` has 33
`link` frames, the sub-CPU payload 7), the twins of WSA1R code that `wsa1/notes/FINDINGS-kn5000-twin-routines.md`
describes.

Per image (`survey.md`): link-frame routines are 1,331 in prom_a, 274 in prom_b and 737 in prom_c.  prom_c is mostly
compiled code; prom_b is mostly display-list data and frameless register-passing code that reads as hand
assembly (`cp a, (mem)`, arguments in A / registers, `calr` chains), with its 274 framed routines in the same
convention as the other two images.  The three images do not differ in convention.

**Consequence: nothing can be staged for V4.23.**  The lane stops here for the owner's decision; no
`cc900-staged/` directory and no `staged_v423.tsv` exist.  What could still be done without the original compiler:
find it (the `link` / `unlk` + A / WA / XIY-result convention is a searchable fingerprint), or reconstruct the C
anyway as documentation with no byte check.

## Scripts

| script          | question it answers                                                                                           | command (repository root, after `make wsa1`)                                                                                                                                                                    |
|-----------------|---------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `wsa_common.py` | (module) the three images' ROMs, base addresses, labels and `.equ` values, read from the linked ELFs          | not a command                                                                                                                                                                                                   |
| `survey.py`     | which routines have a `link` frame, their size, calls, hand marks; the smallest framed leaves                 | `python3 -B notes/cc900-c-wsa1-2026-11-17/survey.py --tsv notes/cc900-c-wsa1-2026-11-17/survey.tsv --md notes/cc900-c-wsa1-2026-11-17/survey.md --top 60`                                                       |
| `show.py`       | what the tree's source says a routine is (its statements, comments stripped)                                  | `python3 -B notes/cc900-c-wsa1-2026-11-17/show.py wsa1/prom_c Queue_FreeSlots Rec0E3E_GroupOfIndex`                                                                                                             |
| `wsa_v423.py`   | which functions a cc900 reproduces from which C, compiler and option set (`corpus`, `check`, `record`, `one`) | see its docstring; run 1: `python3 -B notes/cc900-c-wsa1-2026-11-17/wsa_v423.py check ~/compartilhado/cc900-oracle/runs/2026-11-17-8-ws-r1 --tsv notes/cc900-c-wsa1-2026-11-17/verdicts/2026-11-17-8-ws-r1.tsv` |

`wsa_v423.py` is `notes/cc900-c-subcpu-2026-11-16/sub_v423.py` with the WSA1R's address maps (prom_b at 0xF00000,
prom_a and prom_c at 0xF80000, offset = address - base), names taken from `wsa1/rebuilt_ROMs/*.elf` with llvm-nm
(the WSA1R has no symbols reference file), several compilers per run, and `link` / `unlk` passed through to
llvm-mc.  A probe file's name gives its image: `ws_a_*.c`, `ws_b_*.c`, `ws_c_*.c`.

The run was made with
`python3 -B notes/cc900-c-wsa1-2026-11-17/wsa_v423.py corpus $TMPDIR/cc900-wsa1/r1 scripts/analysis/cc900/corpus/firmware/ws_a_1.c .../ws_b_1.c .../ws_c_1.c --sets none,g,O0,O3,O3XS,Xr,O3Xr,O3XSXr`
and, from `scripts/analysis/cc900`,
`bash oracle/run_oracle.sh ws-r1 DIR DIR/sources.txt DIR/options.txt v423 ide2003 v110`.

`survey.py`'s routine rule is coarse for prom_a / prom_b: a label after a `ret` or a data directive starts a
"routine", so display-list records and tables count among the frameless ones.  The link-frame counts do not depend
on it.
