# The WSA1 byte-emitter macros, respelled (2026-10-24)

`wsa1/include/tlcs900_mem_ops.inc` defines about 80 macros that emit TLCS-900 instructions as `.byte`
runs. They were written in 2026-08, when llvm-mc had no spelling for most memory-operand forms. The
backend has since learned nearly all of them (`wsa1/TOOLCHAIN_VERSION` UPDATE 7-10, and the KN5000
tree's UPDATE 16-21 in the shared backend). So on 2026-10-24 every call site that now has a native
spelling was rewritten as an instruction.

The tool is `scripts/converters/respell_wsa1_macros.py`. Its docstring gives the method. In short:

1. It builds candidate spellings from the macro's own arguments, never from unidasm text.
2. It assembles the macro call and every candidate with the pinned llvm-mc. Each line's exact byte run
   is read between two labels. Symbols take the values in the image's linked ELF. A kernel line is
   checked under both prom_a and prom_c, and a `maincpu/shared` line under prom_a and prom_b.
3. It keeps the first candidate whose bytes match under every image that assembles the line.
4. It requires MAME unidasm's reading of those bytes to agree with the spelling's mnemonic and
   registers. For `ld (mem),(mem)`, it also requires the two addresses in the same order.
5. It rewrites the lines and runs `make all`, then reverts any line that fails in context.
   `make gate-wsa1` proved every family before its commit.

## What moved

Macro call sites, counted by `python3 scripts/converters/respell_wsa1_macros.py --count`. The before
column was measured at 908218944, the after column at the end of the lane.

| family    | macros                                                           | before | after |
|-----------|------------------------------------------------------------------|--------|-------|
| imm       | `m_{cp,and,or,xor,add,sub}_mi8/mi16`, `m_ld_mi8/mi16`            | 5,635  | 0     |
| regmem    | `m_*_rm`, `m_*_mr`, `m_st_mr*`, `m_lda32`, `m_mul/muls/div/divs` | 1,799  | 0     |
| mx        | every `mx_*` / `mx8_*` (register-indexed operand)                | 1,772  | 0     |
| bit       | `m_bit`, `m_set`, `m_res`, `m_stcf`                              | 1,664  | 0     |
| stack     | `m_push`, `m_pop`, `m_popw`                                      | 853    | 0     |
| regdirect | `m_rd_*`, `m_ldc_*` (register-direct operand)                    | 633    | 9     |
| memmem    | `m_ld_mm16`, `m_ldw_mm16`, `m_ld_m16m`                           | 52     | 0     |
| unary     | `m_inc/dec`, the memory shifts, `m_*cf_a`                        | 38     | 0     |
| **total** |                                                                  | 12,446 | 9     |

By tree: prom_a 5,710 -> 0, prom_b 6,646 -> 9, kernel 89 -> 0, maincpu/shared 1 -> 0.

## The spellings, one per form

| form                                    | macro (before)                     | instruction (after)          |
|-----------------------------------------|------------------------------------|------------------------------|
| direct address, width as the ROM has it | `m_cp_mi8 MB16, Sym, 0x01`         | `cp (Sym:16), 0x01`          |
| word immediate to memory                | `m_ld_mi16 MDD+r7, 0x14, 0x0000`   | `ldw (xsp+20), 0x0000`       |
| (Rn+d8): raw byte -> signed             | `m_push MWD+r6, 0xfc`              | `pushw (xiz-4)`              |
| (Rn+d8) with d = 0                      | `m_... MBD+rN, 0x00, ...`          | `(xrr+0:8)`                  |
| mul / div pair                          | `m_mul MBD+r6, 0x08, 3`            | `mul bc, (xiz+8)`            |
| memory to memory                        | `m_ld_mm16 MD24, 0x60f189, 0x276e` | `ld (0x60f189:24), (0x276e)` |
| register-indexed, 16-bit index          | `mx_ld_rm MXL, ra_IY, ra_WA, r5`   | `ld xiy, (xiy+wa)`           |
| register-indexed, 8-bit index           | `mx8_ld_rm MXB, ra_IY, rb_C, r1`   | `ld a, (xiy+c)`              |
| jump table                              | `mx_jp_cc MXD, ra_IX, ra_WA, 8`    | `jp t, (xix+wa)`             |
| bank register (C7/D7/E7 + address)      | `m_rd_ld_rrx RLX, 0x38, r6`        | `ldto_lerp xiz, 0x38`        |
| carry flag from a register              | `m_rd_stcf_a RW+r6`                | `stcf_a_16 iz`               |
| control register                        | `m_ldc_cr_reg RL+r1, CR_DMAD2`     | `ldc_cr32 xbc, CR_DMAD2`     |

The last three use the names the backend gives to forms it has no real-mnemonic syntax for:
`ldto_*`/`ldfr_*` erp, `push_lerp`, `ldc_cr16`, `stcf_a_16` and the like. The KN5000 tree is already
written in these names: `ldto_berp` appears 2,001 times in v10, v142, hdae5000, subcpu and table_data
(`command grep -rhoE '^\s+ldto_berp\b' --include='*.s' v10 v142 hdae5000 subcpu table_data | wc -l`).
Their encoding comes from the assembler, so the bytes are proven, not hand-emitted.

## What is left: three backend gaps, nine call sites, all in prom_b

| macro          | sites | form                 | bytes      | example        | what exists                      |
|----------------|-------|----------------------|------------|----------------|----------------------------------|
| `m_rd_add_rrx` | 5     | `add R32,<bank reg>` | `e7 38 83` | `add XHL,XDE3` | byte `addb_erp`, word `addw_erp` |
| `m_rd_ldcf_ax` | 2     | `ldcf A,<bank byte>` | `c7 3d 2b` | `ldcf A,RH3`   | nothing                          |
| `m_rd_stcf_ax` | 2     | `stcf A,<bank byte>` | `c7 3d 2c` | `stcf A,RH3`   | word only, `stcfw_erp`           |

`wsa1/notes/llvm/wsa1_macro_gap_probe.s` is the probe behind the last column. `--left` lists the
reasons again on any later tree. Closing a gap is a backend commit: add a def, then add its spelling to
`rd_candidates()` and re-run `--apply`.

## Traps the tool had to avoid

- **Bank-register names are not register names to this backend.** llvm-mc accepts `ld a, rl3`,
  `ld a, iyl` and `ld de, qhl3` without an error. It reads each name as an undefined symbol and emits
  `ld a, <imm>` (`c9 03` plus a fixup). Only the link, or a byte comparison, refuses them. So the
  register-file address stays a number, as it does in the KN5000 tree.
- **A shorter encoding can hide in zero padding.** The older `llvm_native_equivalence.py` compared
  16-byte slots, so a 4-byte candidate followed by padding matched a 5-byte macro ending in `00`. This
  tool reads each line's bytes between two labels instead.
- **`(xrr+256)` no longer means "d8 with zero".** Since UPDATE 17 it means +256. The zero-displacement
  d8 form is spelled `(xrr+0:8)`. `llvm_native_equivalence.py` and `README.md` here have been corrected.
- **Hex copied from macro arguments** (`0x3C`, `0xF4`) is lowercased, per CLAUDE.md. A digit inside a
  symbol name keeps its case.

## Census note for whoever runs `make dispatch-census` next

The 10 `mx_jp_cc` sites are now spelled `jp t, (xix+wa)`. The census D detector finds dispatch sites by
matching that text, so it can now see these 10 sites in prom_a/prom_b, where before it saw a macro.
Expect D-found tables or D-unres to change for those two images. The new sites are what changed, not
the code.
