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

## In the reference model

The reload-after-store rule is the model's first personality switch (`codegen.py`, `setup_struct_temps`,
`--personality v4.23|kn5000` in `score.py`).  On `_ldiv` (1997 source, `-O3 -XS -DFLOAT`, oracle run
`2026-11-08-5`) the model with `v4.23` gives exactly V4.23's listing, and with `kn5000` exactly the 2003 compiler's,
whose object reproduces the firmware's `_ldiv` pair (`scripts/analysis/cc900/results/pairs_libsrc97_ide2003.tsv`);
the crossed comparisons differ.  `_ldiv` is the first routine where the inferred Technics personality reproduces the
firmware and V4.23 does not.

## The reload rule, stated precisely (from `_ldiv` and `_ultoa`)

Both compilers track which register holds the value of which memory location, and skip a load whose value is
already in the register.  They differ in when they record it:

- **V4.23** records "R holds M" after a load `ld R,(M)` only.  After a store `ld (M),R` the register is not known to
  hold M, so the next use of M reloads it (`ld (XSP+8),XWA` / `ld XWA,(XSP+8)`, `_ldiv`, `_ultoa`, `r_buf`).
- **2003** (and the Technics compiler) also records it after a store.  Like all such knowledge it is forgotten at a
  store through a pointer, which might alias M.  `_ldiv`: `ld (XSP+8),XWA` / `ld (XSP+4),XWA`, only direct stores in
  between, so no reload.  `_ultoa`: `ld (XSP+8),XWA` / `ldb (XWA+0x20),0x0` (a store through XWA) /
  `ld XWA,(XSP+8)` / `lda XWA,XWA+0x1f`: the indirect store invalidated the knowledge, so XWA is reloaded before it
  is used again.

This explains every reload difference seen so far with one switch.  In the model it is best implemented as
register-contents tracking with that switch, rather than as the `setup_struct_temps` special case it is now.

Refined by `_ultoa`: V4.23 keeps load-based knowledge across a store through a pointer (it does not reload after
`ldb (XWA+0x20),0x0`), the 2003 compiler drops all of it there.  So the two personalities differ in two ways: what
creates the knowledge (V4.23: loads; 2003: loads and stores) and what a store through a pointer destroys (V4.23:
nothing of it; 2003: everything).  `codegen.knowledge_pass()` implements both: from the naive sequence
`lda XWA,XSP+0x10 / ld (XSP+8),XWA / ld XWA,(XSP+8) / ldb (XWA+0x20),0x0 / ld XWA,(XSP+8) / lda XWA,XWA+0x1f` it gives
V4.23's `_ultoa` prologue for `v4.23` and the 2003 / firmware one for `kn5000`.

`_ultoa` is reproduced the same way (2026-11-09): from one naive load sequence, `knowledge_pass()` gives V4.23's
listing for `v4.23` and the 2003 listing (the firmware's `_ultoa` pair) for `kn5000`.  So two of the three
routines that the firmware shares with the 2003 compiler but not with V4.23 (`_ldiv`, `_ultoa`; `_ldexp` is next)
now come out of the kn5000 personality as the firmware has them.  One refinement the loop body needed: a store
through a pointer erases only what the 2003 compiler knows about its own temporaries, not about user variables
(`*p` reuses XWA after `ld (XWA),L` in both compilers).

## The reload rule, final form (2026-11-09, from `__doprnt`)

`__doprnt` decided between the two formulations above.  The firmware (and the 2003 compiler) keep
`ld (XSP+8),WA / cpw (XSP+8),0x0 / j ge,L / ld WA,(XSP+8)`: a reload two instructions after the store.  So the 2003
compiler does not learn from stores in general.  The rule that fits every case:

- **both compilers** learn "R holds slot M" from a load, and keep it until a label, a call, an unconditional jump,
  a write to R or a write to M (not across nothing else: conditional jumps and stores through pointers keep it);
- **the 2003 / Technics compiler** also drops a load that **immediately** follows a store of the same register to
  the same slot.

`codegen.knowledge_pass()` implements this.  Results: `_ldiv` and `_ultoa` come out of the model exactly as V4.23's
listing (`v4.23`) and as the 2003 / firmware listing (`kn5000`); applied to V4.23's own library listings it leaves
every routine the firmware shares with V4.23 unchanged and maps V4.23 to the 2003 code exactly for 214 of the 248
functions (209 are already identical), among them `_ldexp`, `_ldiv`, `_fmod`, `_strtol` and `__doprnt`
(`scripts/analysis/cc900/results/rule_on_listings.md`).  The firmware's `__doprnt` still differs from the 2003
compiler's (a variable kept in IZ, two `cp (XSP+0x1a),...` / `decw 1,(XSP+0x12)` sequences absent): a later
revision of `__DOFORM.C`, or a rule neither neighbour has.
