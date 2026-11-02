# Probes of lane open6/misc2 (2026-11-02)

Run each from the repository root.

| script                    | question it answers                                                                                                                       | run                                                             |
|---------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|
| `slide4k_encode_exact.py` | does `compress_lzss.py`'s encoder (lzss_j.encode, N 4096, F 18) give every byte of the 22 factory SLIDE4K streams, and what follows each? | `python3 notes/misc2-2026-11-02/probes/slide4k_encode_exact.py` |
| `slide4k_stale_tails.py`  | what are the bytes after demo songs 17 and 18's streams, and can any source regenerate them?                                              | `python3 notes/misc2-2026-11-02/probes/slide4k_stale_tails.py`  |
| `chord_types_29_30.py`    | what tells chord types 29 / 30 from 12 / 28, whose voicing records are the same? (the held sets: a 9th, a flat 9th)                       | `python3 notes/misc2-2026-11-02/probes/chord_types_29_30.py`    |
| `wsa1_f7df_runs.py`       | where are the WSA1R disks' 0xFF / 0xF7 / 0xDF runs, and what pattern do they follow? (3 runs, qsdisk 01WORKS_.SEQ)                        | `python3 notes/misc2-2026-11-02/probes/wsa1_f7df_runs.py`       |
| `tm_stale_carryover.py`   | where do the 38 stale KN6000 .TM checksum words come from? (carried over from an earlier recompute)                                       | `python3 notes/misc2-2026-11-02/probes/tm_stale_carryover.py`   |
| `sqt_residue_bits.py`     | are the .SQT bytes no event order explains song data or RAM nothing wrote? (KN7000 large runs: RAM)                                       | `python3 notes/misc2-2026-11-02/probes/sqt_residue_bits.py`     |
| `macro_name_escapes.py`   | does a quoted name through a macro's `.ascii "\name"` give the bytes of a plain `.ascii`, in llvm-mc and kn7asm? (yes)                    | `python3 notes/misc2-2026-11-02/probes/macro_name_escapes.py`   |

The floppy probes need the floppy references built (`make -C floppy refs-wsa1 refs-kn6000 refs-kn7000`).

Signals: `slide4k_encode_exact.py` prints EXACT / PAD 0xNN / TAIL n per stream and exits 1 on any DIFFERENT
(2026-11-02: EXACT 14, PAD 6, TAIL 2).  `slide4k_stale_tails.py` prints the four checks its docstring lists
(2026-11-02: a 398-byte self-copy, then a 15,559-byte old part that parses as SLIDE4K items, matches the
song-18 stream in nine runs, ends with song 18's 75-byte tail, and occurs nowhere else in 58 images).  Its
step 4 reads every file of `original_ROMs/` and `~/compartilhado/technics_roms/roms/kn5000/` and takes a few
minutes.

The other probes print the figures their docstrings record under "Measured 2026-11-02";
`macro_name_escapes.py` exits 1 on a mismatch.
