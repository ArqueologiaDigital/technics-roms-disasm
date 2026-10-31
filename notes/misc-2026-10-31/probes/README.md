# Probes of lane open4/misc (2026-10-31)

Run each from the repository root.  None writes into the tree.

| script                      | question it answers                                                                                                                                  | run                                                              |
|-----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------|
| `slide8k_vs_lzss_j.py`      | Does `lzss_j.encode` (Okumura LZSS.C, N = 8192, F = 10) make the factory SLIDE8K decisions?                                                          | `python3 notes/misc-2026-10-31/probes/slide8k_vs_lzss_j.py`      |
| `slide4k_vs_okumura.py`     | Does the same encoder with N = 4096, F = 18 make the factory SLIDE4K decisions?                                                                      | `python3 notes/misc-2026-10-31/probes/slide4k_vs_okumura.py`     |
| `ram_block_delta_review.py` | Which RAM names did only `name_kn5000_ram.py`'s block-delta fallback place, and did any reach the source? (output: `ram_block_delta_review.out.txt`) | `python3 notes/misc-2026-10-31/probes/ram_block_delta_review.py` |

Signals: `slide8k_vs_lzss_j.py` prints one row per help stream; `SAME DECISIONS` with "byte prefix equal" =
the bytes the decoder reads means the stream is `encode()`'s output plus the pad byte (german_stale is compared
up to output 0x55E0, its cut); it exits 0 when every stream matches.  `slide4k_vs_okumura.py` ends with
"22 of 22 streams".
