# Probes of lane mn10300-data5 (wave 13, 2026-11-07)

Each script answers one question about the MN10300 data regions; run them from the repository root.  The
lane's notes are `../mn10300-data5/README.md`.  They read the committed data directories (or the directories
given) and the git-ignored reference images in each tree's `baserom/`; they write nothing.

| script             | question it answers                                                                                                                                                                                                 | command                                                                              |
|--------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
| `opaque_diff.py`   | between two copies of a tree's data directory (BEFORE: committed or a `git archive` of the base; AFTER: a generator run), which bytes became census-opaque (a rise to explain) and which stopped being opaque       | `python3 -I kn7000/notes/mn10300-data5-probes/opaque_diff.py BEFORE AFTER [--all]`   |
| `opaque_copies.py` | which census-opaque pieces are, whole or from their start, a byte-identical copy of bytes elsewhere in the same image (what `gen_data_s.dup_spans` types as the copy of a typed item)                               | `python3 -I kn7000/notes/mn10300-data5-probes/opaque_copies.py [--min N] [TREE ...]` |
| `float_pairs.py`   | which of a tree's "double tables" pass `gen_data_s.float_pairs` (at least 4 words with a low word not 0, three quarters of them two singles of plausible exponent): single-precision floats the 8-byte grid misread | `python3 -I kn7000/notes/mn10300-data5-probes/float_pairs.py [TREE ...]`             |

Signals:

- `opaque_diff.py` prints `newly opaque 0 in 0 spans` for every tree after this lane's regeneration (no rise).
- `opaque_copies.py` on the base (92b5cc4a7) lists the KN2400's `0x00DAF8 856 B: whole = 0x00D45C`: the second copy
  of the interpolation tables; after the regeneration that piece is gone.  Its "where" column names a label
  only for the KN6000 / KN6500 (the CPU base it assumes is the first label's top byte), else the ROM offset.
- `float_pairs.py` on the base: `kn2400 doubles_4840DE50 62 words, 62 lo!=0, 61 float pairs: SINGLES`, every other
  table `doubles` (the KN7000 935 / KN6500 74-word tables 15 of 72, the rate random low words give, about 1 in 4).
