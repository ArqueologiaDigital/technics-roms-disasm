# Sub-CPU payload v1.41: the source tree and how it was derived (2026-10-24)

`v141/subcpu/` is a byte-exact source tree for `original_ROMs/kn5000_subprogram_v141.rom`
(196,608 B, SHA-1 `39b0dd7b23abd3cdfedce65dd4fef0e2ab16ab69`). The same build, recompressed
with the factory stream's decisions, reproduces the firmware-update image
`original_ROMs/kn5000_subprogram_v141_compressed.rom` (93,181 B, SHA-1
`ac9791441ceb13748a2196a0a6a400431d6aed5e`). Both are checked by `make gate`, in the
`kn5000_subprogram_v141` and `kn5000_subprogram_v141_compressed` rows. Both files were
already tracked; this work adds no image to git.

## The whole difference

The raw byte diff is 124,033 bytes in 2,875 runs (issue `kn5000-v41`), but almost all of it
is address ripple. The real changes are three, plus one consequence:

| # | v1.42                                                                   | v1.41                  | effect                                        |
|---|-------------------------------------------------------------------------|------------------------|-----------------------------------------------|
| 1 | version word at 0x00F000 = 142                                          | 141                    | none                                          |
| 2 | RESET begins with 5 stores: DMA0V, DMA2V, DMAR, DMAB, INTCLR := 0       | absent                 | every later address 0x17 lower                |
| 3 | 1 byte of 0xFF pad (FP_dcmp_AlignPad) before the FP library at 0x03D2AB | absent (already even)  | from FP_dcmp on, 0x18 lower                   |
| 4 | zero-initialised RAM (BSS) at 0x03EE76, 0x66F2 bytes                    | at 0x03EE5E, same size | every absolute DRAM operand in it, 0x18 lower |

The image end moves by the same amount, so v1.41 carries 0x18 more bytes of 0xFF tail fill.
Nothing else differs. That is not an inference: it is what the byte-exact build proves.

## How the tree is made, and how it stays in sync

* `scripts/generators/create_v141_subcpu_source.py` copies `v142/subcpu/` and applies its
  `EDITS` list, which holds items 1-3 plus a banner. **That list is the semantic diff.**
  After any v142 change, re-run it and commit both trees; `--check` exits 1 when v141 has
  drifted from "v142 + EDITS". `diff -r v142/subcpu v141/subcpu` fits on one screen.
* Item 4 needs no edit. Since commit 29e5caa82 **both** trees spell those operands
  `Payload_Bss_Start+0xOFFSET`. `Payload_Bss_Start` is a label at the image end, so the
  assembler supplies each revision's base. `scripts/converters/subcpu_bss_relative_refs.py`
  did the respelling: 947 literals and the five DRAM `.equ`s. Six in-range numbers were
  excluded because they are Q23 coefficients, not addresses: they are identical in v1.41.
  The converter also found one pointer hidden in a `.byte` run (IRAM_Unreferenced_F340
  +2 = Payload_Bss_Start+0x24).
* Addresses quoted in v141 comments are v1.42 addresses, because the comments are v142's
  (the banner gives the conversion). Labels carry the right address for each revision:
  `symbols/subcpu_v141_symbols_reference.txt` (5,058 names). That is every v142 name
  except `FP_dcmp_AlignPad`, which covers no byte in v1.41.

## How the delta was found

`scripts/analysis/subcpu_v141_v142_alignment.py` lines the two images up at their run-time
addresses. Output on 2026-10-24:

| shift (v1.41 - v1.42) | bytes in equal blocks |
|-----------------------|-----------------------|
| +0x000                | 127,992               |
| -0x017                | 115,068               |
| -0x018                | 6,886                 |
| other (-0x25..-0x3a)  | 52                    |

It found 3,131 gaps. 3,123 have the same length on both sides: these are absolute operands
that differ by the shift. Eight change length:

| v1.42 address | v1.42 bytes | v1.41 bytes | what it is                                             |
|---------------|-------------|-------------|--------------------------------------------------------|
| 0x01F925      | 23          | 0           | item 2 (RESET; the first byte, 0xF1, happens to match) |
| 0x0249C3      | 50          | 36          | aligner artefact: same code, repetitive 7-byte stores  |
| 0x024A08      | 0           | 14          | (the other half of the artefact above)                 |
| 0x0272D8      | 29          | 1           | aligner artefact, as above                             |
| 0x027309      | 8           | 1           | (artefact)                                             |
| 0x02731E      | 1           | 36          | (artefact; the three net to zero)                      |
| 0x03D2AB      | 1           | 0           | item 3                                                 |
| 0x03EF00      | 0           | 24          | the longer tail fill                                   |

The build is what decides "artefact": the v141 tree has no edit at 0x0249C3 or 0x0272D8 and
still matches byte for byte.

## Reproduce

    python3 scripts/analysis/subcpu_v141_v142_alignment.py
    python3 scripts/generators/create_v141_subcpu_source.py --check
    make -j3 gate        # kn5000_subprogram_v141 / _compressed: IDENTICAL

## Next: v1.40

The same aligner, run on v1.41 against v1.40, finds real code changes, not only a shift.
To reproduce it:

    python3 scripts/analysis/subcpu_v141_v142_alignment.py \
        original_ROMs/kn5000_subprogram_v141.rom original_ROMs/kn5000_subprogram_v140.rom

The raw diff is 56,018 B in 2,508 runs. The shifts are -0x34 and -0x86. Length-changing
gaps sit around 0x031103-0x03121B (net about -134 B) and 0x035CC1-0x03602C (net about
+82 B). A v140 tree should be derived from v141 the same way. Its tail is 52 bytes longer.
