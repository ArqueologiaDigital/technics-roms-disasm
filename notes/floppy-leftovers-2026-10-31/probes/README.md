# Probes: leftover bytes on the WSA1R, KN6000 and KN7000 floppies (2026-10-31)

Lane `floppies` of wave 4 (`../README.md`). Every script reads only build products of `make -C floppy gate`
(the files `fat12_extract.py` and `kd.py unpack-dir` write under `floppy/build/<model>/<disk>/`, all
git-ignored) and prints to stdout. Run them from this directory, passing the `floppy/` directory:

    cd notes/floppy-leftovers-2026-10-31/probes && python3 <script> ../../../floppy

| script                 | question it answers                                                                                                                                         | what to read in its output                                                                                                            |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------|
| `wsa1_leftovers.py`    | are the WSA1R .CMB tails (+0x16300..) a copy of +0x13700..+0x137FF, and the .MID tails a copy of the bytes 1024 earlier?                                    | last line: `CMB: 13 of 13 ...; MID: 13 of 13 ...` (pass = both N of N)                                                                |
| `seq_layout.py`        | why does a WSA1R .SEQ hold blocks in no chain? (file length vs chained blocks, the .SQF's +0xB8 free head / +0xBA count, and the first byte of free blocks) | per file: `%4 = 0`, `used+free 1292`, `orphans = chained-max+1..n`; then the first payload byte of each free-chain block (0x82 = 130) |
| `seq_orphans.py`       | is each orphan block's body the same 251 bytes as a chained block (or another orphan, or a block of another file)?                                          | `---- class` table: `chained copy`, `orphan copy`, `other file`, `unique` per file                                                    |
| `seq_statuses.py`      | which statuses and data counts do the WSA1R chains hold in the KN5000 demo-song grammar? (the strict set of `wsa1/formats.py` SEQ_STRICT)                   | `(status, data bytes) count`                                                                                                          |
| `sqt_tails.py`         | the KN6000 / KN7000 .SQT bytes after a track's 0x82: copies of another cell? parse in the file's own (tick-first) grammar?                                  | `same=[...]` cells with the same bytes; `skip k events a/b` how far the tick-first grammar parses                                     |
| `sqt_tails2.py`        | do those bytes, read in the KN5000's status-first order, hold notes equal to the same track's live notes?                                                   | last line: `exact` = tails whose KN5000-order notes occur, in order, among the track's notes (76 at 6b98dda19's tree)                 |
| `sqt_stale_cover.py`   | how many stale .SQT bytes `kn_sqt.stale_tokens` types per order, how many are erased 0xFF or a song-record image, and how many stay opaque?                 | `(model, 'sq' / 'k5' / 'cut' / 'erased' / 'image' / 'unexplained')` byte counts                                                       |
| `sqt_residue.py`       | are the stale bytes no order explains found, at the same offset, in another song file of the disk?                                                          | `same bytes at the same offset in another file` vs `unique` byte counts                                                               |
| `sqt_record_images.py` | which stale runs no order explains are, at one alignment, mostly a song record's bytes (own part 1 and the disk's other .SQT files)?                        | per run: equal bytes, record offset, `rule image` / `no`; for images the other files' counts (slow, ~10 min)                          |
| `sqt_ram_phase.py`     | are the KN7000's unexplained stale bytes power-up RAM rather than events? (set bits by RAM address mod 8, typed stale events as control)                    | one line per (model, kind): bytes and the 8 mean set-bit counts                                                                       |
| `sqt_random_types.py`  | how many bytes of seeded uniform random data the stale tokenizer types (its false-positive rate), and whether the erased / image rules fire on noise        | `typed as events N, as cut events M (x %)`; `runs erased 0, images 0`                                                                 |
| `tm_tail.py`           | which sum over which range gives the KN6000 .TM tail word? (brute force: LE / BE words, bytes, ~ / - / plain, seven ranges)                                 | the top line is `~le16 sounds +0 (LE word)`, 12 of 50                                                                                 |
| `tm_tail2.py`          | which window start for the firmware's 0x37A0-halfword sum (`func_4C07D7C1`) matches most files, and which files match?                                      | `window starts by matches`: 16 (= +0x10) with 12; the list of the 12 files                                                            |

The other two probes this lane relied on are committed beside the open-items register:
`notes/open-items/probes/wsa1_boot_sectors.py` (the nine WSA1R boot sectors are one, SHA-1
`631c4b94c3526e28a7382af72f54f3907065fa22` over bytes 0x3E..0x1FD) and `stale_tails.py`.

## Figures at this lane's commits

- `wsa1_leftovers.py`: CMB 13 of 13, MID 13 of 13.
- `seq_layout.py`: 7 of the 10 .SEQ files hold exactly the chained blocks plus the first blocks of the free
  chain, the .SQF's free head first, up to a multiple of 4 blocks (1 KB); used + free = 1292 in 8 files.
  `01E_TEC1` (1288: blocks 7-10 on neither list) and `01220497` (1169: 123 blocks on neither list) are the
  exceptions. Every free-chain block that held a song starts with 0x82 (`02SD_CMB`, a never-used store, does
  not).
- `seq_orphans.py`: 118 of `01220497`'s orphans repeat a chained block of the same file (block k = block
  k - 139).
- `sqt_tails2.py`: 327 tails: 76 `exact`, 144 `no match`, 107 `no notes`.
- `sqt_stale_cover.py` (bytes): KN6000 32,861 = 17,923 tick-first + 12,046 KN5000-order + 1,124 cut events
  + 1,768 unexplained; KN7000 11,122 = 5,541 + 222 + 89 + 5,270 unexplained. The tokenizer types < 1 % of
  uniform random bytes (checked in the session with 300 random 200-byte runs: 413 of 60,000 bytes).
- `sqt_residue.py`: of the unexplained bytes, 16 (KN6000) and 0 (KN7000) recur at the same offset elsewhere.
- 2026-11-06 (lane kn7000-names, the layer cuts; `../README.md` section "layer cuts"): `sqt_stale_cover.py`
  KN6000 32,861 = 18,528 tick-first + 11,650 KN5000-order + 1,377 cut + 818 erased + 452 image + 36 unexplained;
  KN7000 11,122 = 5,847 + 0 + 230 + 0 + 0 + 5,045.  `sqt_record_images.py`: 2 images (KN6000 03SMBMIX 186 / 215,
  08ENKADC 220 / 237), KN7000 runs at most 28 %.  `sqt_ram_phase.py`: KN7000 unexplained 5,045 B, 3.22 3.26
  3.56 3.61 4.75 4.78 4.48 4.59; controls 2.39..2.54.  `sqt_random_types.py`: 161 + 327 of 60,000 (0.81 %), 0, 0.
  `sqt_residue.py` (it counts every run stale_tokens leaves without a line, erased and images included): KN6000
  1,306 unique, KN7000 5,045 unique, none recurs at the same offset elsewhere now (16 KN6000 bytes did before).
- `tm_tail2.py`: window +0x10 (the 40 sound records), 12 files.
