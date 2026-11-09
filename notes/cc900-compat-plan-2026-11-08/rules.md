# The rule list: where the Technics compiler differs from V4.23 (plan section 4.1)

Each rule is a behaviour that differs between V4.23 and the 2003 compiler on the same C.  Its state for the `kn5000`
personality is **2003** (the Technics compiler has the change), **V4.23** (it does not), or **undecided**.  The
evidence is the source/binary pairs (`scripts/analysis/cc900/results/pairs_libsrc97_groups.md`) and the idiom census
(`scripts/analysis/cc900/results/idiom_census.md`, `idiom_census.py`).  The trigger is the smallest of our
micro-tests that shows the difference (`scripts/analysis/cc900/corpus/micro/`, oracle runs in
`~/compartilhado/cc900-oracle/runs/`).

How rare the differences are: at `-O3 -XS`, V4.23 and the 2003 compiler give different code for 3 of the 749
functions of the general micro corpora (`results/compiler_diff_v423_ide2003.md`), and for 3 of the 11 rule-trigger
functions built from the library's shapes (`rules.c`, run `2026-11-09-1-micro-rules`).

| rule                | V4.23                                                 | 2003                              | trigger                                    | kn5000 state | evidence                                                                                                              |
|---------------------|-------------------------------------------------------|-----------------------------------|--------------------------------------------|--------------|-----------------------------------------------------------------------------------------------------------------------|
| reload-after-store  | `lda XWA,XSP+d` / `ld (XSP+e),XWA` / `ld XWA,(XSP+e)` | the reload is dropped             | `rules.c` `r_buf`                          | **2003**     | pairs `_ldiv`, `_ultoa`, `_ldexp`; census: V4.23 form 0, 2003 form 65 in main CPU v10, 0 / 29 in the HD-AE5000        |
| djnz-loop           | `djnz r,L`                                            | `sub r,0x1` / `j ne,L`            | `rules.c` `r_countdown2`, `ctrl.c` `c_do`  | **V4.23**    | pair `_strrchr`; census: `djnz` 171 against 1 `sub`/`jr ne` in main CPU v10, 14 / 0 sub CPU, 10 / 0 HD-AE5000         |
| lda-offset-fold     | `ld XIZ,XWA` / `add XIZ,XHL` / `dec 0x1,XIZ`          | `lda XIZ,XWA-0x1` / `add XIZ,XHL` | `rules.c` `r_rev`                          | **V4.23**    | pair `_strrev` (`HDAE5000_StrRev`: `add xix,xiz` / `dec 1,xix`); census: 1 / 0 in the HD-AE5000, none in main CPU v10 |
| call-register-alloc | arguments re-read from the frame around calls         | more values kept in XIZ / XBC     | (library `_memccpy`; no micro trigger yet) | **V4.23**    | pair `_memccpy`                                                                                                       |
| m_gps_a index form  | `add WA,0xc` then the 8-bit index register            | `ld BC,WA` first                  | `mem.c` `m_gps_a`                          | undecided    | none yet                                                                                                              |

Pairs that no rule setting explains yet (`__doprnt`, `__facnv`, `__doform` data, `_vsprintf` in two images, `_sbrk`,
`__FloatErrorHandle`) are the next source of rules: once the model reproduces V4.23's output for them, the remaining
differences from the firmware are rules that neither neighbour has.
