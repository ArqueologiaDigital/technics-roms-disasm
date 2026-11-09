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
(`--opt O3XS --adecl`, against the run's listing) scores 6 of 6.  What is still missing for a byte-exact build from
our own tools is the step from the model's Toshiba-syntax listing to bytes: a translation to our LLVM syntax (or an
LLVM-syntax emitter) and the 16/24-bit address choice.
