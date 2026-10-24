# HD-AE5000 versions: v2.06i, v2.01i, v1.15i, v1.10i

Lane `wave2/hdae5000-versions`, 2026-10-24. The HD-AE5000 expansion ROM (IC4, 512 KiB at
0x280000) is dumped in four versions. v2.06i has the byte-exact source tree `hdae5000/`. This
note sizes the other three, records what differs, and says how v2.01i got its own tree,
`hdae5000_v2_01i/`, which `make gate` now rebuilds byte-identical.

## Inputs

The dumps are in the private romset (`~/compartilhado/technics_roms/roms/kn5000/`, read-only, never
committed). `hd-ae5000.ic4` there is byte-identical to v1.15i. The Makefile copies v2.01i's dump to
`original_ROMs/hd-ae5000_v2_01i.ic4` (git-ignored) and checks its SHA-1, as it does for KN5000 v8.

| version | file                   | SHA-1                                      | version string (offset) |
|---------|------------------------|--------------------------------------------|-------------------------|
| v2.06i  | `hd-ae5000_v2_06i.ic4` | `c4da28f0ad16b1288774af761b3729142e8050b3` | `V2.06i` (0x2e1c82)     |
| v2.01i  | `hd-ae5000_v2_01i.ic4` | `0160c17baa7b026771872126d8146038a19ef53b` | `V2.01i` (0x2e1490)     |
| v1.15i  | `hd-ae5000_v1_15i.ic4` | `581fa58e2cd6fe381cfc312c73771d25ff2e662c` | `V1.15i` (0x2a3d08)     |
| v1.10i  | `hd-ae5000_v1_10i.ic4` | `6019f3c28b6277730418974dde4dc6893fced00e` | `V1.10i` (0x2a3bb8)     |

All four carry the same credits block ("Technics Software section M. Kitajima 2.33J 2.21 TECHNICS
KN5000 Juli-Oktober 1996"), so that block is not a version stamp.

## Sizing the ports

    python3 scripts/analysis/hdae5000_version_delta.py --top 20 > delta-k32.txt

`delta-k32.txt` in this folder is that output, unedited. The script's docstring describes the
method: an offset map of identical blocks, as in `kn5000_version_delta.py`, with every differing
byte of a same-size gap then classified by the value it sits in (moved ROM pointer, RAM address,
UI object id `0x007fNNNN`, or other).

| pair             | positional diff | aligned B (blocks) | rom-moved | ram   | ui-object | other + rom-other | size-changing gaps (churn) | estimated change |
|------------------|-----------------|--------------------|-----------|-------|-----------|-------------------|----------------------------|------------------|
| v2.06i -> v2.01i | 426,370 B       | 335,668 (813)      | 2,189     | 2,813 | 362       | 39,546            | 47,344 B (5,303 B)         | 86,890 B         |
| v2.01i -> v1.15i | 462,181 B       | 240,674 (557)      | 1,615     | 2,304 | 290       | 4,185             | 230,542 B (99,132 B)       | 234,727 B        |
| v1.15i -> v1.10i | 280,466 B       | 474,629 (874)      | 2,415     | 45    | 43        | 3,822             | 14,371 B (1,535 B)         | 18,193 B         |
| v2.06i -> v1.15i | 453,447 B       | 236,923 (544)      | 1,515     | 2,161 | 260       | 4,367             | 234,340 B (101,245 B)      | 238,707 B        |

- **v2.06i -> v2.01i is mostly one picture.** 33,415 of the 44,910 differing same-size-gap bytes,
  and the largest size-changing gap (20,362 B), are inside `HDAE5000_Bitmap_FilePanel` and its
  palette. Outside that picture the differing bytes are mostly RAM addresses and moved pointers.
- **v1.15i is a different layout.** It has about 99 KB of churn and 103 distinct shifts, and a 97 KB
  gap where v2.x has its padding. v1.x has no FilePanel picture at v2.x's position (a 77,824-byte gap
  that maps to nothing), and its boot splash differs too.
- **v1.10i is close to v1.15i** (18 KB estimated change, 21 shifts). It should be ported from a
  v1.15i tree once one exists, not from v2.x.

## What v2.01i lacks, or has, against v2.06i

Found in the port. The code side is from
`python3 scripts/analysis/hdae5000_version_routine_diff.py v2_01i` (output: `routine-diff-v2_01i.txt`
here). That run compares 584 v2.06i routines with 582 v2.01i ones: 568 are the same once moves are
factored out, 14 changed, and 2 exist only in v2.06i. The data side is from the port's own hunks.

**Lyric colour settings: new in v2.06i.**

- `HDAE5000_LyricForeColorCheck` and `HDAE5000_LyricBackColorCheck` (127 B each) are missing from
  v2.01i, together with their registry entries. The ApFunction tables register 67 objects in v2.01i
  and 69 in v2.06i.
- So are their strings ("RED", "GREEN", "BLUE", "BLACK", "YELLOW") and their two setting bytes.
  v2.01i's settings stop at `HDAE5000_RAM_LyricJump` (0x229dac), and the variables after it, up to
  0x229e5c, sit 2 bytes lower.
- `HDAE5000_Lyrics_ResetState` does not set the lyric palette from those settings, and does not
  blank the lyric lines.
- `HDAE5000_HD_Init`, `HD_Format`, `HD_BuildSettingsSector`, `HD_LoadSettings` and
  `HD_SaveSettings` lack the loads and stores of those two bytes (0x229dad / 0x229dae in v2.06i).
- The lyric settings page (`LyrSettings`) has one option row in v2.01i and three in v2.06i
  (v2.06i objects 784-787 are gone).
- v2.06i's language messages 65 and 66 ("COLOR ACTIV" / "COLOR PASSIV") and 67 (an "overwrite an
  existing entry?" query) do not exist in v2.01i. The message switch has 77 entries in v2.01i and 80
  in v2.06i.
- Message 64 is "Jump after Load" in v2.01i and "LYRICS LOAD MODE" in v2.06i. Its French text is
  "Gumpéé après ski", as the ROM has it.
- Right after `LyricJumpEditCheck`, at 0x285F8B, v2.06i has an unlabelled handler that nothing in
  the ROM points to. No 24-bit value in the image equals its address. On `EVT_GET_RAM_STRING` it
  prints a value with "%1d". v2.01i does not have it.

**HDD utility page: v2.01i can format the drive from it.** `HDAE5000_HDD_UTIL_PAGE` has a switch 9
in v2.01i that formats the drive ("FORMAT TRY !!!", `HDAE5000_HD_FormatDrive`, "FORMAT FINISHED
!!!" / "FORMAT ERROR !!!" with the error number). v2.06i has no such switch. Switch 11, the drive
information, lists the LSW, SDA, PMT and SQF blocks in v2.01i. v2.06i lists those plus SEQ, CMP,
TM, MSP, RCM and MD.

**Floppy lyric file selector.**

- In `HDAE5000_FDFileSelectProc`, keys 1 / 0x81 have their own case in v2.01i: it sends 0x01EA000E,
  0x01CA000C and EVT_PARA_DRAW to the object. Keys 7 / 0x87 return 0. v2.06i folds both through a
  byte map: 1 / 0x81 return 0 and 7 / 0x87 take the enter case.
- The bottom bar of the `LoadLyricFD` screen has four buttons in v2.01i and two in v2.06i
  (objects 773-776).
- The file-selection backdrop picture shows the same thing. v2.01i's has a magenta marble background
  and five buttons in the bottom bar; v2.06i's has a plain dark background and three.

**Lyric window.** It is narrower in v2.01i: x 19-302 against 0-319 (objects 753-756 and 770).
Its six text lines are 35 bytes each against 40 in v2.06i.

**Saved file format version.** `HDAE5000_FileFormat_VersionMinor` is 1 in v2.01i and 6 in v2.06i.
The major version is 2 in both.

**Smaller items.**

- The French texts of messages 57-59 are empty strings in v2.01i. v2.06i repeats the English text
  there.
- The UI object table has 786 objects (766 in the ROM pool, 20 in RAM) against 789 in v2.06i. Every
  insert, delete and replace is listed in the header of the UI object section of
  `hdae5000_v2_01i/hdae5000_data_tables.s`.
- The frame handler's init posts to object 0x7F013E in both versions. In v2.01i that object is
  unnamed, and FLS_FILE_LOAD_SW_EDIT is object 320. The note at the code marks this [INFERENCE] as a
  stale id.
- The `.data` image is laid out differently. The RAM addresses of the copied image are 0x5c to
  0x96 bytes lower in v2.01i (the RAM table in the main source's header lists every
  `HDAE5000_RAM_*` constant).

## How the v2.01i tree was made

`scripts/tools/port_hdae5000_version.py` (its docstring describes each pass):

1. `init` copied `hdae5000/` to `hdae5000_v2_01i/`.
2. `fix`, `strings` and `code` ran in rounds. Each round assembles the tree with a marker label per
   source line, aligns the image with the v2.01i dump, and works on the hunks left.
3. `uitables` regenerated the UI object section from the v2.01i ROM. The same generator, run on a
   copy of `hdae5000/`, reproduces v2.06i byte for byte.
4. The rest was done by hand. Every hand edit is a script in `port-edits/`, and `port-edits/README.md`
   gives the order.

The result is byte-identical. `make gate` reports `hd-ae5000_v2_01i IDENTICAL`, and
`verify-hdae5000-v201-reference` checks the reference copy's SHA-1.

Byte-exactness pins every label that something references, but not the others, and not the names.
Three review tools, committed, did the rest:

- `scripts/analysis/hdae5000_version_label_check.py v2_01i` compares each label's first
  instructions with v2.06i's, call targets included. The latest run reports 0 orphan labels, 2 labels
  in piles (`HDAE5000_UiObjectName_Pool` and its first entry, which is correct) and no rename
  suggestions. Its "moved" rows are code that really changed, renumbered UI objects, and pointer
  tables.
- `scripts/analysis/hdae5000_version_stale_comments.py v2_01i` lists comments that quote a number
  the code no longer has. It reports 0.
- `port_hdae5000_version.py farptrs` respells every `pushw X@hi16 / @lo16` pair from the bytes. The
  high half of any label in the same 64 KiB assembles the same way, so 409 pairs had named the wrong
  string.

Comments elsewhere in `hdae5000_v2_01i/` still quote v2.06i addresses and object numbers. The banner
at the top of `hd-ae5000_v2_01i.s` says so. The 738 label-address comments are removed.

## Keeping the trees in step

`hdae5000_v2_01i/` is its own tree, not a generated one. The delta is too large and too scattered
for a "v2.06i + EDITS" generator: 14 routines, the UI object section, the RAM image and a picture.
The trees are kept in step the way `v9/` and `v7/` are kept with `v10/`. A rename in `hdae5000/` is
applied to `hdae5000_v2_01i/` with the same sed script. The two review tools above show where the
trees drift apart.

## v1.15i and v1.10i: not ported

Only the sizing above was done for them, plus one trial run of the porting tool on v1.15i. That run
was thrown away and nothing of it is committed.

- After `init`, `fix` and three `code / strings / fix` rounds, `status v1_15i` still showed 2,099
  hunks, with 121,119 of 524,288 bytes equal in place. The `fix` pass oscillated: the same 4
  constants flipped between two values on every round, because two uses of each wanted different
  values. v2.01i got there from 1,682 hunks.
- `uitables` refused v1.15i: "#3 caption arena not NUL-terminated". Its UI records do not follow
  v2.x's per-class body lengths (`UI_F` in the tool), so v1.x needs its own record model first.
  The table locations themselves are found generically, by
  `python3 scripts/tools/port_hdae5000_version.py tables v2_06i v2_01i v1_15i v1_10i`:

  | version | object table | name table | objects | class-name table |
  |---------|--------------|------------|---------|------------------|
  | v2.06i  | 0x2a5d2c     | 0x2a6984   | 789     | 0x2f9832         |
  | v2.01i  | 0x2a5558     | 0x2a61a4   | 786     | 0x2f8d0e         |
  | v1.15i  | 0x2a16a4     | 0x2a2280   | 758     | 0x2e128e         |
  | v1.10i  | 0x2a1572     | 0x2a2142   | 755     | 0x2e10fe         |

- v1.x also has no FilePanel picture, and its boot splash differs (a `VERSION_ASSETS` entry in
  `scripts/build/hdae5000_images.py` each).

A v1.15i tree is therefore a lane of its own:

1. a v1.x record model for `uitables`;
2. the pictures;
3. then the same port loop, starting from `port_hdae5000_version.py init v1_15i` (it reads the dump
   from the private romset when `original_ROMs/hd-ae5000_v1_15i.ic4` is absent);
4. then v1.10i, from the v1.15i tree.
