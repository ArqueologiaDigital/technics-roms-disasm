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

| rule                | V4.23                                                 | 2003                              | trigger                                    | kn5000 state | evidence                                                                                                                  |
|---------------------|-------------------------------------------------------|-----------------------------------|--------------------------------------------|--------------|---------------------------------------------------------------------------------------------------------------------------|
| reload-after-store  | `lda XWA,XSP+d` / `ld (XSP+e),XWA` / `ld XWA,(XSP+e)` | the reload is dropped             | `rules.c` `r_buf`                          | **2003**     | pairs `_ldiv`, `_ultoa`, `_ldexp`; census: V4.23 form 0, 2003 form 65 in main CPU v10, 0 / 29 in the HD-AE5000            |
| djnz-loop           | `djnz r,L`                                            | `sub r,0x1` / `j ne,L`            | `rules.c` `r_countdown2`, `ctrl.c` `c_do`  | **V4.23**    | pair `_strrchr`; census: `djnz` 171 against 1 `sub`/`jr ne` in main CPU v10, 14 / 0 sub CPU, 10 / 0 HD-AE5000             |
| lda-offset-fold     | `ld XIZ,XWA` / `add XIZ,XHL` / `dec 0x1,XIZ`          | `lda XIZ,XWA-0x1` / `add XIZ,XHL` | `rules.c` `r_rev`                          | **V4.23**    | pair `_strrev` (`HDAE5000_StrRev`: `add xix,xiz` / `dec 1,xix`); census: 1 / 0 in the HD-AE5000, none in main CPU v10     |
| call-register-alloc | arguments re-read from the frame around calls         | more values kept in XIZ / XBC     | (library `_memccpy`; no micro trigger yet) | **V4.23**    | pair `_memccpy`                                                                                                           |
| m_gps_a index form  | `add WA,0xc` then the 8-bit index register            | `ld BC,WA` first                  | `mem.c` `m_gps_a`                          | undecided    | none yet                                                                                                                  |
| loop-entry-copy     | `j L_test` / body / `L_test:` test                    | not probed                        | `p6_m3.c` `trim_a`                         | **firmware** | firmware `TrimAndPadSmfFilename` (runs `2026-11-16-9` to `-11`); census: 332 one-compare tests copied, 29 jumped to (v10) |

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

## From the firmware's own functions (phase 6, 2026-11-16)

Phase 6 builds Matsushita's functions from guessed C (`notes/cc900-phase6-2026-11-16/README.md`).  Two findings bear
on this list.  Both come from comparing V4.23's output with the ROM, run in the oracle VM.

**The firmware was built with options per source file.**  V4.23 at `-O` loads a 32-bit constant of 8..0xffff with
`lda`, which asm900 assembles to the short absolute form; without `-O` it uses the 5-byte `ld`.
- `GetNamingWindowID` (main CPU v10, `ui/ui_widget_defs.s` in the disassembly) returns 10 with the `ld`.  V4.23
  reproduces it at `-Xr` only.
- `StyleConv_ClearWorkBuffer` (`sequencer/accompaniment_engine.s`) is `-O`-shaped: the end pointer is computed from
  the start register, and the loop has no entry test.  It loads its buffer's address, 0x488c, with the `lda` form,
  the instruction V4.23 writes only at `-O3 -XS -Xr` (run `2026-11-16-14-p6-m4-split`).
- `TrimAndPadSmfFilename` (`file_io/smf_operations.s`) matches V4.23 at `-O3 -XS -Xr` for its first 42 of 55 bytes,
  and at `-Xr` not from its first byte.

So the Technics compiler has the `-O` `lda` rule, and the source files were compiled with different options.  The
phase-6 C files record theirs (`cc900-options:`; `ui_widget_defs.c` is at `-Xr`).  The caveat: the `lda` evidence is
a pointer constant and `GetNamingWindowID`'s an integer, which V4.23 treats alike.  Of 36 small functions built so
far, 35 give the same bytes at either option set, so most files' options are still unknown.

**loop-entry-copy (kn5000 state: firmware).**  The Technics compiler copies a loop's test to the loop's entry when the
test is one compare and its branch: test, fall into the body, test again at the bottom.  V4.23 jumps to the bottom
test for every form tried (`while`, `for`, `if` + `do`-`while`, two hand-made `goto` loops: runs `2026-11-16-9` to
`-11`).  For a longer test, one that loads or has `&&`, the firmware jumps too.
- **The firmware routine.**  `TrimAndPadSmfFilename` shows both shapes in one function.  Its first loop
  (`while (i < n && (c = *p) != 0)`) jumps to the test, exactly as V4.23 does.  Its padding loop (`while (i < n)`)
  is entered by `cp IX,BC / jr nc,exit`, where V4.23 writes `jr T,test`.
- **The census** (`notes/cc900-phase6-2026-11-16/loop_shapes.py --test-blocks`, v10).  Of 3,136 backward branches:
  - 332 are loops whose one-compare bottom test is copied to the entry, and 229 more test something else at the
    entry;
  - 344 jump to their test.  That test is one instruction in only 29 of them, and 7 of the 29 are in
    `audio/sprintf_core.s`, the library code Toshiba's tools built;
  - for the other 315 the test is two instructions or more: 40 of two, 75 of three, 200 of four or more.
  
  Neither a branch to the loop's entry nor the body's length separates the shapes.  The 22 one-compare jump-to-test
  loops outside the library are the rule's exceptions to check; some look hand-written.
- **The 2003 compiler** has not been asked.

In the reference model the rule is `KN_LOOP_INVERT` / `kn_invert_entry` in `codegen.py`, for the `kn5000`
personality only, at `-O`, in the generic `while` and `for` paths (lane_p6 fix p6-01).
