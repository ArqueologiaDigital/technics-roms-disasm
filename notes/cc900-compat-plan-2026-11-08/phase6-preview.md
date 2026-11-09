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
address-width rule is read from the firmware's own encodings; whether tulink decides it from the final address
(as assumed) or from a section attribute is not yet tested.
