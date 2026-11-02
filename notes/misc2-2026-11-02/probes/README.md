# Probes of lane open6/misc2 (2026-11-02)

Run each from the repository root.

| script                    | question it answers                                                                                                                       | run                                                             |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|
| `slide4k_encode_exact.py` | does `compress_lzss.py`'s encoder (lzss_j.encode, N 4096, F 18) give every byte of the 22 factory SLIDE4K streams, and what follows each? | `python3 notes/misc2-2026-11-02/probes/slide4k_encode_exact.py` |
| `slide4k_stale_tails.py`  | what are the bytes after demo songs 17 and 18's streams, and can any source regenerate them?                                              | `python3 notes/misc2-2026-11-02/probes/slide4k_stale_tails.py`  |

Signals: `slide4k_encode_exact.py` prints EXACT / PAD 0xNN / TAIL n per stream and exits 1 on any DIFFERENT
(2026-11-02: EXACT 14, PAD 6, TAIL 2).  `slide4k_stale_tails.py` prints the four checks its docstring lists
(2026-11-02: a 398-byte self-copy, then a 15,559-byte old part that parses as SLIDE4K items, matches the
song-18 stream in nine runs, ends with song 18's 75-byte tail, and occurs nowhere else in 58 images).  Its
step 4 reads every file of `original_ROMs/` and `~/compartilhado/technics_roms/roms/kn5000/` and takes a few
minutes.
