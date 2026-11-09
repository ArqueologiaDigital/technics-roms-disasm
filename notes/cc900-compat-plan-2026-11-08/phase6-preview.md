# Phase 6 preview: firmware functions through the proxy route (2026-11-09)

A first test of matching decompilation on Matsushita's own code (not Toshiba's library), using the proxy route of
`phase3a-status.md` (V4.23 in the oracle VM; the reload rule changes nothing in these).  The C is our guess from the
disassembly: `scripts/analysis/cc900/corpus/firmware/tiny.c`; oracle run `2026-11-09-3-proxy-tiny` (V4.23,
`-O3 -XS -Xr`).

| firmware function (v10)      | our C                             | V4.23 listing                                                    | firmware                                                      |
|------------------------------|-----------------------------------|------------------------------------------------------------------|---------------------------------------------------------------|
| `SetLswFilter`               | `LSW_FILTER = a + b;`             | `add XWA,XBC` / `ld (_LSW_FILTER),XWA` / `ret`                   | `add xwa, xbc` / `ld (LSW_FILTER:24), xwa` / `ret`            |
| `SetRootObject`              | `ROOT_OBJECT = p;`                | `ld (_ROOT_OBJECT),XWA` / `ret`                                  | `ld (ROOT_OBJECT:24), xwa` / `ret`                            |
| `BitMapOut_StorePresetValue` | `g8d3e = v;` (unsigned char)      | `ld (_g8d3e),A` / `ret`                                          | `ld (0x8d3e:16), a` / `ret`                                   |
| `SmfMedley_RawData`          | `g35140 = (c != 0);`              | `cp A,0x0` / `scc ne,WA` / `ld (_g35140),A` / `ret`              | `cp a, 0:i3` / `scc nz, wa` / `ld (35140:16), a` / `ret`      |
| `TrimPad_NullTerminate`      | `*p = 0;`                         | `ldb (XWA),0x0` / `ret`                                          | `ld (xwa), 0x0` / `ret`                                       |
| `FmtNum_WriteSpacePad`       | `*p++ = c; *p++ = ' '; *p = ' ';` | `ld (XWA+:1),C` / `ldb (XWA+:1),0x20` / `ldb (XWA),0x20` / `ret` | `ld (xwa+), c` / `ld (xwa+), 0x20` / `ld (xwa), 0x20` / `ret` |

All six have the firmware's instruction sequence.  Two findings:
- **ABI:** a `char` second adecl argument travels in C (`FmtNum_WriteSpacePad`), one of the unprobed guesses of
  `phase2.md`, now confirmed.
- **Address width:** the firmware uses 16-bit absolute addresses (`:16`) for variables below 0x10000 and 24-bit ones
  above; the listing leaves that to the assembler and linker.  A byte-exact build needs the same choice: asm900 /
  tulink pick the short form from where the symbol lands, so our toolchain must do the same for cc900-compat output.

**The reference model does the same without Toshiba's compiler:** `model/score.py` on `corpus/firmware/tiny.c`
(`--opt O3XS --adecl`, against the run's listing) scores 6 of 6.  

## From C to ROM bytes with our own tools only

`model/to_llvm.py` rewrites the model's listing in our llvm-mc syntax and makes asm900's choices:
- the 3-bit immediate for `cp`/`ld` of 0..7 to a register (`cp a, 0:i3`, `c9 d8`);
- a post-increment operand with the data size as its step (`(xwa+)`);
- the absolute-address width from where the variable lies: `(ADDR:8)` below 0x100, `(ADDR:16)` below 0x10000,
  `(ADDR:24)` above.  The addresses come from a symbol file (`corpus/firmware/tiny.syms`).

`model/check_bytes.py` assembles the result with llvm-mc (UPDATE 22 toolchain) and compares each function with
`original_ROMs/kn5000_v10_program.rom` at the address `symbols/maincpu_v10_symbols_reference.txt` gives it.  The
commands are in `scripts/analysis/cc900/model/README.md`; the output, 2026-11-09:

| function                     | bytes | result |
|------------------------------|-------|--------|
| `SetLswFilter`               | 8     | MATCH  |
| `SetRootObject`              | 6     | MATCH  |
| `BitMapOut_StorePresetValue` | 5     | MATCH  |
| `SmfMedley_RawData`          | 9     | MATCH  |
| `TrimPad_NullTerminate`      | 4     | MATCH  |
| `FmtNum_WriteSpacePad`       | 11    | MATCH  |

So for these six the whole chain -- guessed C, clang's front end, the reference model, our assembler -- gives the
firmware's bytes with no Toshiba program involved.  The translator covers only the instructions these six need;
an unknown line is emitted as `; untranslated:` so that a wider corpus fails loudly instead of silently.  The
address-width rule is read from the firmware's own encodings.  **Tested later the same day:** the final address does
not decide it.  The table data's `.sbrk` reads `_SBRK_size`, at 0x999c, with a 24-bit operand
(`ld XHL,(0x00999c)`, `e2 9c 99 00 23`), and its listing declares the variable `extern large`.  Every extern of the
1997 library is declared that way (828 of 828), and so are tiny.c's (`extern large _g8d3e`), yet the firmware encodes
`(0x8d3e:16)`.  So the width follows the declaration: a `large` extern takes 24 bits whatever its address, and the
firmware's own variables below 0x10000 must have been declared another way (a near or tiny area).  How exactly is
still open.  `to_llvm.LARGE_DATA` makes named operands 24-bit; `pairs_model.py` sets it.

## The firmware's library pairs from Toshiba's C with our tools only (2026-11-09)

`model/pairs_model.py` takes every source/binary pair of `results/pairs.tsv`, compiles the library source with the
reference model (cdecl, `-O3 -XS -DFLOAT`, as the library was built), translates the function with
`model/to_llvm.py` (asm900's encodings; `jr` / `jrl` by reach; `cal` as a 24-bit `call`; absolute operands through the
image's own addresses: the pairs' publics, the image's labels, the helpers named in the runtime cross-reference),
assembles and links it with llvm-mc / ld.lld at the pair's address, and compares the bytes with the image.

| personality | byte-identical pairs | which                                                                                                                                                                                                                                                                                                                                                                   |
|-------------|----------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `v4.23`     | 172 (18 differ)      | `_ltoa`, `_strcat`, `_strncpy`, `_strncat`, `_strcpy`, `_strlen`, `_memset`, `_memcmp`, `_memchr`, `_memcpy`, `_memccpy`, `__ctype` x9 each, `_strncmp` x10, `_strchr` x5, `_strnset` x5, `.sbrk` x6, `__FloatErrorHandle` x3, sub CPU float tables x9; `_modf`, `_fabs`, `_sin`, `_cos`, `_tan`, `_exp` (sub CPU x3 each); `_sprintf`, `_vsprintf` (HD-AE5000 x4 each) |
| `kn5000`    | 185 (5 differ)       | the same 172, plus `_ultoa` (main CPU v10, v9, v7, v6, v5, HD-AE5000 x4) and `_ldiv` (HD-AE5000 x4)                                                                                                                                                                                                                                                                     |

`_ltoa` came later the same day (`-O` keeps the parameters of a function with calls in scratch registers when no
value is read after a call; and asm900 writes a 32-bit `cp XDE,0x0` with the long immediate, `ea cf 00 00 00 00`, not
the 3-bit form `ea d8` that MAME also decodes); the V4.23 personality then matches it too, so it is not one of the
personality's additions.  `_modf` (sub CPU v142, v141, v140) is the first floating-point routine rebuilt this way
(`model/fpgen.py`, run `2026-11-09-9-micro-fp`); its constant `0.0` sits in `f_const`, placed by the linker, so
`pairs_model.py` takes its address from the image's own `lda XBC,...` operand and checks that the image holds that
double there.  The 13 the kn5000 personality adds are the two routines in which the firmware's code differs from V4.23's output:
the reload rule (`rules.md`) accounts for them, and with it they come out byte-identical with no Toshiba program in
the chain.  The 5 that differ are `_log` x3 (20 of 338 bytes) and the main CPU's `_vsprintf` x2, a near match only (below).
`_memccpy` x9 came right with the -O3 -XS home rule R4 (`model/homes.py`).  Three more -O behaviours were needed:
- the arms' identical call tails are merged (`cross_jump`, counted once for the homes);
- a call result is stored straight from XHL after its pops;
- a value written once and pushed once by the next call is not stored.
The table data's `.sbrk` came right once a `large` extern was taken as 24-bit (below).
`.sbrk` is declared `__adecl` in a cdecl file; the front end now reads the attribute per function.  A static
(`__str`, a static function's address `__strOut`) has no public symbol in the image either: `pairs_model.py` gives it
a placeholder, takes its address from the image's own operands (a 24-bit address, or a `pushw` hi / lo pair) and
requires every use to agree on one address.  The main CPU's `_vsprintf` (v10, v7) is not V4.23's nor the
HD-AE5000's: it reloads `s` after `_str = s` (`ld (0x03c21c),XWA` / `ld XWA,(XSP+0x04)` / `ld (XWA),0x0`), where
V4.23 and the HD-AE5000 keep XWA; and `pairs.tsv` puts its public 3 bytes past its first instruction (ff0ab7 for
ff0ab4).  A different build of the library, or a rule for the main CPU; not decided.  `pairs.tsv` itself found it only as a near match
(`near`, V4.23 ml 0.875, at `Sprintf_Unlocked+3`), so it may not be the library routine at all.  `_fabs` came with `-O`'s hoisting of the two branches' common first instructions above the test
(`fpgen.hoist_common`).  `_exp` showed one more asm900 choice: `lda` of a symbol always takes the 24-bit address
(`lda XBC,_g_mathtbl` at 0xf420 is `f2 20 f4 00 31`), where an `ld` of a variable below 0x10000 takes 16 bits.  The other 110 (`model cannot` in the TSV) are routines the model does not compile yet (`goto` in `_strcspn`, the
floating-point formatter `__doprnt`, the math routines), or that are data the model does not emit.

Inline assembly (`__ASM("...")`, `_memset`, `_memcmp`, `_memchr`) is passed through as thc1 does: the front end turns
it into a marker call that keeps the string, the model writes the text, and `return (void *)__XHL` becomes a plain
`ret`.  One instruction needs a workaround in `to_llvm.py`: llvm-mc knows only the operand-less `cpir` (XWA), so
`cpir A,(XHL+)` is written as its two bytes (`.byte 0x83, 0x15`); the backend's assembler should learn the operand
forms of `cpi` / `cpir` / `cpd` / `cpdr`.  The block transfers with explicit operands are written as bytes too: llvm-mc's
bare `ldi` is the `(XWA+)` form (`80 10`) where `ldib (XIX+),(XIY+)` is `85 10` (`_memcpy`).

Output: `scripts/analysis/cc900/results/pairs_model_kn5000.tsv`; command in `scripts/analysis/cc900/model/README.md`.
(Earlier runs the same day: 36, 51, 63, 90, 108, 117, 126, 135, 144, 147, 150, 156, 159, 162, 167, 171; the rules added in between are in those commits.  The library sources end in
a DOS end-of-file byte, which the front end now cuts.)

### Per image (phase 7: a line per image)

`python3 -I -B model/pairs_summary.py ../results/pairs_model_kn5000.tsv` (from `scripts/analysis/cc900`):

| image       | pairs | identical | differ | not compiled yet | near match, unverified |
|-------------|-------|-----------|--------|------------------|------------------------|
| maincpu v10 | 24    | 17        | 0      | 7                | 3                      |
| maincpu v9  | 24    | 17        | 0      | 7                | 0                      |
| maincpu v7  | 24    | 17        | 0      | 7                | 3                      |
| maincpu v6  | 24    | 17        | 0      | 7                | 0                      |
| maincpu v5  | 24    | 17        | 0      | 7                | 0                      |
| subcpu v142 | 16    | 10        | 1      | 5                | 0                      |
| subcpu v141 | 16    | 10        | 1      | 5                | 0                      |
| subcpu v140 | 16    | 10        | 1      | 5                | 0                      |
| table data  | 3     | 2         | 0      | 1                | 1                      |
| hdae v2.06i | 21    | 17        | 0      | 4                | 1                      |
| hdae v2.01i | 21    | 17        | 0      | 4                | 0                      |
| hdae v1.15i | 19    | 17        | 0      | 2                | 0                      |
| hdae v1.10i | 19    | 17        | 0      | 2                | 1                      |

The sub CPU's pairs are mostly the floating-point routines, which the model does not compile yet; the one that
differed on the main CPU and the HD-AE5000, `_memccpy`, is now byte-identical too.  `pairs.tsv` also lists `___ctype` at `__ctype`'s address in
every image that has it; `pairs_model.py` reports it as `alias of __ctype` and the table does not count it.  The
`near match, unverified` column counts `pairs.tsv`'s `near` rows that are not byte-identical, outside `pairs`:
- `_sbrk` (main CPU v10 and v7, table data) is the last bytes of the routine before `.sbrk` (`pop XIZ` / `ret`);
- the main CPU's `_vsprintf`;
- `__facnv` (main CPU v10 and v7, HD-AE5000 v2.06i and v1.10i), which the model cannot compile yet.  The SX-WSA1R images have no pairs in `pairs.tsv`.
