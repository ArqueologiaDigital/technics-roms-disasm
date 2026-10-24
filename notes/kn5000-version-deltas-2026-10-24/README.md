# KN5000 main-program deltas: how big are the v5 and v6 ports?

Measured 2026-10-24 (lane `wave1/kn5000-v8`) so that a later lane can size porting the v5 and v6
main-program ROMs, which have dumps (private romset) but no source. v7, v8, v9 and v10 are
byte-exact targets. v8 is v9 with a different version byte, so it is left out here.

## How to reproduce

    python3 scripts/analysis/kn5000_version_delta.py            > delta-k32.txt
    python3 scripts/analysis/kn5000_version_delta.py --k 16     > delta-k16.txt
    python3 scripts/analysis/kn5000_version_delta.py v6:v7 --map v6_to_v7_offset_map.tsv

The two `.txt` files in this folder are those outputs, unedited. v5 and v6 are read from
`$KN5000_ROMS_DIR` (default `~/compartilhado/technics_roms/roms/kn5000`). Each output starts
with the SHA-1 of every input:

| image | SHA-1                                      |
|-------|--------------------------------------------|
| v5    | `7b69a8aaa84ee3d337acc0c29c34154c5da2df32` |
| v6    | `51108e2d75b180a034395e90bd40ca2bd2a0adfb` |
| v7    | `4c682cb248034a2de04c688b0a45654b8726bffb` |
| v9    | `d9a3b462b1f9302402e8d37aacd15f069f56abd9` |
| v10   | `1f2abc5b1b7b9e16fdf796f26d939edaceded354` |

The offset map is regenerable from the script, so it is not committed.

## What the script measures

The script's docstring has the full method. In short:

- **positional diff**: bytes that differ at the same offset. Useless once anything has moved.
- **offset map**: blocks of identical bytes at a constant shift. They are anchored on K-byte
  sequences that occur exactly once in each image, chained monotonically, and extended byte by byte.
  Whatever lies between two blocks is a **gap**.
- **moved-pointer bytes**: differing bytes inside same-size gaps that belong to a 24-bit ROM
  pointer which the offset map explains, because its target moved. With symbolic source they
  cost nothing to port.
- **estimated change** = differing same-size-gap bytes, minus moved-pointer bytes, plus all
  bytes of size-changing gaps. This is an upper bound on real change. Moved 16-bit relative
  displacements (`jr`/`calr`/`jrl`) and moved RAM variables are not recognised, and a
  size-changing gap is counted in full even where most of its bytes agree.

## Results

| pair      | positional diff | estimated change, K=32 | estimated change, K=16 | blocks (K=32) | distinct shifts (K=32) | layout churn (K=32) |
|-----------|-----------------|------------------------|------------------------|---------------|------------------------|---------------------|
| v5 -> v6  | 1,514,774 B     | 53,062 B               | 60,054 B               | 8,359         | 50                     | 2,907 B             |
| v6 -> v7  | 1,461,567 B     | 108,588 B              | 100,403 B              | 6,963         | 73                     | 5,293 B             |
| v5 -> v7  | 1,556,228 B     | 124,483 B              | 99,516 B               | 7,293         | 98                     | 6,478 B             |
| v7 -> v9  | 1,039,383 B     | 63,171 B               | 62,238 B               | 5,987         | 16                     | 2,046 B             |
| v9 -> v10 | 13,517 B        | 1,403 B                | 1,570 B                | 1,261         | 3                      | 14 B                |

"Layout churn" counts the bytes by which size-changing gaps grow. The same number of bytes
shrink elsewhere, because every image is 2 MiB, so code growth is paid for by fill.

## Reading it

- **The yardstick is v7 -> v9, about 62-63 KB of estimated change.** v7 was ported from the
  v9/v10 source. That is a known amount of work, so the other rows can be read as multiples of it.
- **v6 -> v7 is about 100-109 KB, roughly 1.6-1.7 times the v7 job**, and its layout moves more:
  73 distinct shifts against 16, and 5,293 B of churn against 2,046 B. Porting v6 from the v7
  source is the larger of the two ports.
- **v5 -> v6 is about 53-60 KB, slightly less than the v7 job.** v5 is much closer to v6 than to
  v7. So the cheaper route is v7 -> v6 -> v5, with v5 ported from the v6 source once v6 exists.
  v5 -> v7 measures 100-124 KB.
- **The estimate moves by up to about 20% with the anchor length** (v5 -> v7: 124 KB at K=32,
  100 KB at K=16). Treat the figures as sizes, not counts. The ratios between rows are steadier
  than the absolute numbers.
- **Positional diffs say nothing here.** About 70% of v5/v6 differs from v7 at the same offset,
  because most code moved by a small constant. Of the v6 -> v7 aligned bytes, only 273,051 sit
  at shift 0. The next largest shifts are +0xfc (261,102 B), -0x6 (216,028 B) and +0xf5
  (128,943 B).
- In v7, the five largest v6 -> v7 gaps start at or inside `StyleSong_MasterTable` (0xeba494),
  `AccTone_LookupByProgram` (0xf5d23c + 9; it is the one large size-changing gap,
  5,918 B of v6 -> 5,110 B of v7), `InitializeScoop`, `SysExRx_Trie_000` and
  `IvExitTrSel_CopyString`. Names are from `symbols/maincpu_v7_symbols_reference.txt`.

## Not measured yet

- No attribution of the change to v7 source files or subsystems. The offset map (`--map`) plus
  the v7 ELF symbols is the input for that.
- No recognition of moved 16-bit relative displacements or moved RAM addresses. Either would
  lower the estimates.
