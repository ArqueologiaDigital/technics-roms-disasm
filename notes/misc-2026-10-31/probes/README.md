# Probes of lane open4/misc (2026-10-31)

Run each from the repository root.  None writes into the tree, except `quote_macro_string_params.py --apply`
(a rewrite) and `v7_converter_rerun_check.py`, which edits one source for the converter run and puts it back
byte for byte.

| script                         | question it answers                                                                                                                                  | run                                                                                            |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| `slide8k_vs_lzss_j.py`         | Does `lzss_j.encode` (Okumura LZSS.C, N = 8192, F = 10) make the factory SLIDE8K decisions?                                                          | `python3 notes/misc-2026-10-31/probes/slide8k_vs_lzss_j.py`                                    |
| `slide4k_vs_okumura.py`        | Does the same encoder with N = 4096, F = 18 make the factory SLIDE4K decisions?                                                                      | `python3 notes/misc-2026-10-31/probes/slide4k_vs_okumura.py`                                   |
| `ram_block_delta_review.py`    | Which RAM names did only `name_kn5000_ram.py`'s block-delta fallback place, and did any reach the source? (output: `ram_block_delta_review.out.txt`) | `python3 notes/misc-2026-10-31/probes/ram_block_delta_review.py`                               |
| `v7_converter_rerun_check.py`  | Does `v7_byte_region_to_insns.py` now write a committed block exactly as the tree has it? (output: `v7_converter_rerun_check.out.txt`)               | `python3 notes/misc-2026-10-31/probes/v7_converter_rerun_check.py v7/maincpu/FILE.s LABEL ...` |
| `kn7asm_macro_quotes.py`       | Does kn7asm pass quoted macro arguments as GNU as and llvm-mc do? (input: `kn7asm_macro_quotes.s`)                                                   | `python3 notes/misc-2026-10-31/probes/kn7asm_macro_quotes.py`                                  |
| `quote_macro_string_params.py` | (a rewrite, not a probe) respell `.ascii \p` as `.ascii "\p"` in the kn7asm trees' macro bodies                                                      | `python3 notes/misc-2026-10-31/probes/quote_macro_string_params.py [--apply]`                  |

Signals: `slide8k_vs_lzss_j.py` prints one row per help stream; `SAME DECISIONS` with "byte prefix equal" =
the bytes the decoder reads means the stream is `encode()`'s output plus the pad byte (german_stale is compared
up to output 0x55E0, its cut); it exits 0 when every stream matches.  `slide4k_vs_okumura.py` ends with
"22 of 22 streams".  `kn7asm_macro_quotes.py` prints OK for kn7asm, GNU as and llvm-mc and exits 0; the
kn7asm of the base (before 2026-10-31) fails on the same file ("macro Q takes 1 arguments, got more").
