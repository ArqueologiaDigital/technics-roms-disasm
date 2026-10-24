# HD-AE5000 versions: v2.06i, v2.01i, v1.15i, v1.10i

Lane `wave2/hdae5000-versions`, 2026-10-24. The HD-AE5000 expansion ROM (IC4, 512 KiB at
0x280000) is dumped in four versions. v2.06i has the byte-exact source tree `hdae5000/`. This
note sizes the other three, and records what changed between them.

## Inputs

The dumps are in the private romset (`~/compartilhado/technics_roms/roms/kn5000/`, read-only, never
committed). `hd-ae5000.ic4` there is byte-identical to v1.15i.

| version | file                   | SHA-1                                      | version string (offset)  |
|---------|------------------------|--------------------------------------------|--------------------------|
| v2.06i  | `hd-ae5000_v2_06i.ic4` | `c4da28f0ad16b1288774af761b3729142e8050b3` | `V2.06i` (0x2e1c82)      |
| v2.01i  | `hd-ae5000_v2_01i.ic4` | `0160c17baa7b026771872126d8146038a19ef53b` | `V2.01i` (0x2e1490)      |
| v1.15i  | `hd-ae5000_v1_15i.ic4` | `581fa58e2cd6fe381cfc312c73771d25ff2e662c` | `V1.15i` (0x2a3d08)      |
| v1.10i  | `hd-ae5000_v1_10i.ic4` | `6019f3c28b6277730418974dde4dc6893fced00e` | `V1.10i` (0x2a3bb8)      |

All four carry the same credits block ("Technics Software section M. Kitajima 2.33J 2.21 TECHNICS
KN5000 Juli-Oktober 1996"), so that block is not a version stamp.

## How to reproduce

    python3 scripts/analysis/hdae5000_version_delta.py --top 20 > delta-k32.txt

`delta-k32.txt` in this folder is that output, unedited. The script's docstring describes the
method: an offset map of identical blocks, as in `kn5000_version_delta.py`, with every differing
byte of a same-size gap then classified by the value it sits in (moved ROM pointer, RAM address,
UI object id `0x007fNNNN`, or other).

## Results

| pair             | positional diff | aligned B (blocks) | rom-moved | ram   | ui-object | other + rom-other | size-changing gaps (churn) | estimated change |
|------------------|-----------------|--------------------|-----------|-------|-----------|-------------------|----------------------------|------------------|
| v2.06i -> v2.01i | 426,370 B       | 335,668 (813)      | 2,189     | 2,813 | 362       | 39,546            | 47,344 B (5,303 B)         | 86,890 B         |
| v2.01i -> v1.15i | 462,181 B       | 240,674 (557)      | 1,615     | 2,304 | 290       | 4,185             | 230,542 B (99,132 B)       | 234,727 B        |
| v1.15i -> v1.10i | 280,466 B       | 474,629 (874)      | 2,415     | 45    | 43        | 3,822             | 14,371 B (1,535 B)         | 18,193 B         |
| v2.06i -> v1.15i | 453,447 B       | 236,923 (544)      | 1,515     | 2,161 | 260       | 4,367             | 234,340 B (101,245 B)      | 238,707 B        |

## Reading it

- **v2.06i -> v2.01i is mostly one picture.** 33,415 of the 44,910 differing same-size-gap bytes,
  and the largest size-changing gap (20,362 B), are inside `HDAE5000_Bitmap_FilePanel` and its
  palette. v2.01i's file-selection backdrop has a magenta marble background where v2.06i's is
  plain dark blue, and five buttons in its bottom bar where v2.06i has three. Outside that picture
  the differing bytes are mostly RAM addresses (the data segment and the BSS are laid out
  differently) and moved pointers. The real code change is spread thinly over many routines.
- **v1.15i is a different layout.** About 99 KB of churn, 103 distinct shifts, and a 97 KB gap
  where v2.x has its padding. v1.x has no `HDAE5000_Palette_FilePanel` / `_Bitmap_FilePanel`
  block at v2.x's position (a 77,824-byte gap that maps to nothing). Porting v1.15i from v2.x is a
  separate tree's worth of work, not a list of edits.
- **v1.10i is close to v1.15i** (18 KB estimated change, 21 shifts), so it should be ported from
  a v1.15i tree once one exists, not from v2.x.
