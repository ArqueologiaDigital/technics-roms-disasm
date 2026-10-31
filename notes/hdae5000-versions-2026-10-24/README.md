# HD-AE5000 versions: v2.06i, v2.01i, v1.15i, v1.10i

Lane `wave2/hdae5000-versions`, 2026-10-24, and lane `open/hdae-v1`, 2026-10-30. The HD-AE5000
expansion ROM (IC4, 512 KiB at 0x280000) is dumped in four versions, and each has a byte-exact
source tree that `make gate` rebuilds: `hdae5000/` (v2.06i), `hdae5000_v2_01i/`,
`hdae5000_v1_15i/` and `hdae5000_v1_10i/`. This note sizes the ports, records what differs, and
says how each tree was made.

## Inputs

The dumps are in the private romset (`~/compartilhado/technics_roms/roms/kn5000/`, read-only, never
committed). `hd-ae5000.ic4` there is byte-identical to v1.15i. The Makefile copies the v2.01i, v1.15i
and v1.10i dumps to `original_ROMs/hd-ae5000_<ver>.ic4` (git-ignored) and checks their SHA-1, as it
does for KN5000 v8.

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
Four review tools, committed, did the rest:

- `scripts/analysis/hdae5000_version_label_check.py v2_01i` compares each label's first
  instructions with v2.06i's, call targets included. The latest run reports 0 orphan labels, 2 labels
  in piles (`HDAE5000_UiObjectName_Pool` and its first entry, which is correct) and no rename
  suggestions. Its "moved" rows are code that really changed, renumbered UI objects, and pointer
  tables.
- `scripts/analysis/hdae5000_version_stale_comments.py v2_01i` lists comments that quote a number
  the code no longer has. Its first check (TEXT) only saw lines whose source text changed. It
  reported 0 while byte dumps contradicted their own lines: in `HDAE5000_HDAETitleFunc`,
  `ld (0x23a022:24), xwa ; f2 9a a0 23 60` assembles to `f2 22 a0 23 60`. It now also reads
  the assembled bytes of both trees. BYTES compares each trailing byte-dump comment with its line's bytes. OPER maps the
  addresses that changed between a line and its v2.06i twin. SYM maps the v2.06i value of a symbol
  quoted in a code line's trailing comment. IMAGE maps RAM and ROM addresses quoted in the `.data`
  image through the copy. Its `--fix` run rewrote 195 byte dumps, 50 operand quotes, 49 symbol
  quotes and 51 image addresses (counts are quotes, not lines; rerun it without `--fix` on the
  commit before the fix to see them). It now reports 0 in all five checks.
  Quoted sizes and offsets in the image and the copy routine were fixed by hand
  (`port-edits/19_data_image_sizes.py`).
- `scripts/analysis/hdae5000_obj_constants_check.py` checks each `HDAE5000_OBJ_<NAME>` against the
  name table: its value must be 0x007F0000 + the index whose name is NAME, and no two constants may
  share a value. It found two v2.01i constants the porting tool's `fix` pass had retargeted after
  `uitables`, so that one routine's bytes matched: SW_HD_FORMAT held #222 and CP_FD_HDSWSEL held
  #220, which is CP_FD_HDSWTO's id. That routine had been respelled to fit, which made it look as
  if v2.01i hid different objects there. It hides the same three as v2.06i
  (`port-edits/18_obj_constant_values.py`). `fix` no longer moves OBJ constants once `uitables` has
  run, and `make gate` runs this check and `l2_symbol_reference.py --check`.
- `port_hdae5000_version.py farptrs` respells every `pushw X@hi16 / @lo16` pair from the bytes. The
  high half of any label in the same 64 KiB assembles the same way, so 409 pairs had named the wrong
  string.

Block comments (prose on lines of their own) elsewhere in `hdae5000_v2_01i/` still quote v2.06i
addresses and object numbers; only the `.data` image's are mapped. The banner at the top of
`hd-ae5000_v2_01i.s` says so. The 738 label-address comments are removed.

## Keeping the trees in step

`hdae5000_v2_01i/` is its own tree, not a generated one. The delta is too large and too scattered
for a "v2.06i + EDITS" generator: 14 routines, the UI object section, the RAM image and a picture.
The trees are kept in step the way `v9/` and `v7/` are kept with `v10/`. A rename in `hdae5000/` is
applied to `hdae5000_v2_01i/` with the same sed script. The two review tools above show where the
trees drift apart.

## v1.15i and v1.10i: byte-exact trees

Lane `open/hdae-v1`, 2026-10-30. `hdae5000_v1_15i/` and `hdae5000_v1_10i/` rebuild their dumps
byte for byte: `make gate` reports `hd-ae5000_v1_15i IDENTICAL` and `hd-ae5000_v1_10i IDENTICAL`,
and `verify-hdae5000-v115i-reference` / `-v110i-reference` check the git-ignored reference copies
(`HDAE5000_V115_REF`, `HDAE5000_V110_REF` in the Makefile). v1.15i was ported from v2.01i, which
`hdae5000_version_delta.py` puts closer than v2.06i (234,727 B of estimated change against
238,707 B), and v1.10i from v1.15i.

| tree               | ported from | objects (RAM) | classes | ApFunctions | messages (0x1EA) | events (0x1CA) | source coverage                         |
|--------------------|-------------|---------------|---------|-------------|------------------|----------------|-----------------------------------------|
| `hdae5000/`        | -           | 789 (20)      | 13      | 69          | 18               | 13             | 100.0%, 0 B verbatim                    |
| `hdae5000_v2_01i/` | v2.06i      | 786 (20)      | 13      | 67          | 18               | 13             | 100.0%, 0 B verbatim                    |
| `hdae5000_v1_15i/` | v2.01i      | 758 (15)      | 10      | 63          | 13               | 3              | 100.0% (138,388 B asm), 0 B verbatim    |
| `hdae5000_v1_10i/` | v1.15i      | 755 (15)      | 10      | 63          | 13               | 3              | as v1.15i (`kn5000_source_coverage.py`) |

The registry counts are the tables `HDAE5000_Handler_Registration` registers, read from each ROM
(`port_hdae5000_version.py`'s `registered_table`); the object counts come from
`scripts/converters/hdae5000_ui_tree.py`, which now models v1.x too (its layout check holds for all
four versions).

### What v1.x lacks, or has, against v2.x

Each item names the evidence; the hand edit that removed it from the port is in brackets
(`port-edits-v1_15i/`, whose scripts carry the details).

**No lyrics.** "TLhd", "TLtr", ".TLX", ".TTX", "XLT.", "LyricBox" and "FDFileSelect" occur 0 times
in either v1 dump (1 to 7 times each in v2.01i). So v1.x has:

- no LyricBox class or HDAE5000_LyricBoxProc, none of the Lyrics_* routines, no song-position post
  to a lyric box in HDAE5000_Frame_Handler (EV_TICKS) [04, 04h];
- no floppy lyric selector (FDFileSelect class, FdLyricList_*) [04];
- no ninth part (TLX). Load, save, copy, delete and the PC link handle eight parts: the part-mask
  bit 8 tests, the part signature "TLhd", the ninth "show the flag" block, the TLX floppy search,
  the PC-link part mask's high byte (v2.x HDAE5000_RAM_PportPartMaskHi) are absent, and
  HDAE5000_TypeSel_TemplateAllNo has eight flags [04b, 04c, 04j, 05b, 05d];
- three setting bytes in sector 1 (QuickLoadMode, LoadByNumberMode, JumpAfterLoad, 0x229da9-ab),
  not four: no LyricJump and none of the five "show the lyrics after load" blocks [04f];
- language messages 1-62 and 200-212: no message 64 ("Jump after Load") [04i];
- no ApFunctions SfxTlxBitCheck, DelTlxEditCheck, LyricJumpEditCheck, BitmapButt01 (and no 42 x 15
  button picture), no EV_* lyric events (the event-name table has EV_SeqStop, EV_AfterLoad,
  EV_TimerBack only) [04, 05, 06].

**No file-selection backdrop.** No TtlScreenR3 class or procedure, no HDAE5000_Alloc_Memory_3, and
no FilePanel picture: v2.06i's and v2.01i's are both absent from the image [00, 04].

**Messages renumbered.** No MT_SelectAll (no select-all soft button in HDAE5000_SelectListProc, no
select-all case in HDAE5000_CopyToHDScreen), so every method after MT_SelectSAVE is one lower:
MT_SetStrAdr is 0x01ea0009 (31 uses in v1.15i, 0 of 0x01ea000a), MT_SelectDEL 0x01ea000b,
MT_SelectDelFile 0x01ea000c. The v1 trees therefore have their own `shared/event_codes.s`
(generated by `07_event_codes.py`); FILE_LOAD_Screen's switch has 13 cases [04g, 04k, 07]. No
MT_Fd* methods either.

**PC link.** Services 0-27 (v2.x 0-30: no XAP flash, no main-CPU hook services 28-30) [04d].
Command 01 neither latches packet bytes 1-2 nor checks the PC program's version (no "Error : Wrong
Dll Ver" record), and its info block is 0xbf bytes (v2.x 0xca: no TLX description, no file-format
version at +200 / +201); command 20 is a bare `jp` to CommandDone [04e]. In both v1 dumps the
service table's entry 12 is not a pointer: it holds its stub's address AND 0xfff (0x000005c0 for
0x2915c0 in v1.15i, 0x000004c4 for 0x2914c4 in v1.10i), so service 12 cannot be dispatched;
[INFERENCE] a fault of the link [11].

**Smaller items.**

- The boot splash is v1.x's own: no "Version 2" line, "Startup !" for "Start-up !"
  (`hdae5000_v1_15i/images/HDAE5000_SplashScreen_v1_15i.png`; v1.10i has the same bytes) [02].
- The version string ("V1.15i" / "V1.10i") sits in front of the title logo's palette, not after
  the HDD icon [05f].
- The .data image (copied to RAM 0x23c914 in both v1 dumps, 0x9d4 bytes) has no file-format
  version words and no lyric lines; HDAE5000_Frame_Handler first increments a byte at 0x22b3da
  that nothing reads (HDAE5000_RAM_FrameCount) [08, 13].
- The unreferenced VarInt codec, the SMF header reader and HDAE5000_StrUpr of v2.x are absent [04d].
- Every version's ROM header holds, after "XAPR", a pointer to the end of its .data image
  (v2.06i 0x2fa134, v2.01i 0x2f95e6, v1.15i 0x2e198a, v1.10i 0x2e17fa); every tree spells it
  `.long HDAE5000_Init_Data_End` (the v2.x trees since b3b788b14, 2026-10-31) [13].
- The naming keyboard's two character tables end with a pointer to an empty string right after
  them, `.long HDAE5000_Str_Empty_AtoSPC[_2]` in every tree (the v2.x trees spelled that word as
  bytes and a "." string until b3b788b14) [05e].

**v1.10i against v1.15i** (`routine-diff-v1_10i.txt`: 538 routines each, 533 the same, 5 changed):

- no language message 62 (v1.15i's evaluation date, "Evaluation 07-07-98"): messages 1-61 and
  200-212 (`port-edits-v1_10i/04_no_message_62.py`);
- the overwrite query ATTEN_OVER_FILE is fixed German text ("!ACHTUNG!", "Sie überschreiben einen
  bestehenden Titel. Sind Sie sicher?", "JA" / "NEIN") where v1.15i uses language messages 210,
  211 and 28; v1.10i's message 28 reads "You are going to overwrite a FLS entry. Are you sure?"
  (v1.15i: "... an existing entry ...");
- HDAE5000_LoadSong_Pmt, HDAE5000_SaveSong_Rcm, HDAE5000_HD_WriteStream and
  HDAE5000_PPORT_Svc27 differ in code.

### How the trees were made

The 2026-10-24 trial failed on two things, both fixed in `scripts/tools/port_hdae5000_version.py`:

- **`fix` oscillated** because one constant had uses that wanted different values. `fix` and the
  new `afix` now decide each constant from all its uses (`resolve_votes`): the value of the uses
  that already emit the target's bytes stays, a use spelled `name+N` that wants another address
  moves its offset (v1.x's save options have one part fewer, so v2.x's SaveOptions+11 is +10), and
  any other use gets a symbol of its own.
- **`uitables` refused v1.x** because the old record model assumed v2.x's body lengths. The GUI
  converter (`hdae5000_ui_tree.py`) reads each class's fields from the firmware, so it only needed
  the v1.x layout: the HD-AE5000's own class ids are per version (v1.x has 10 classes, so
  AcLanguageText1 is 0x016a0009), the .data image's RAM base is read from the boot copy loop, and a
  tree being ported is given its labels' target addresses (`--syms`).

The block aligner then still put routine i of a family of look-alikes (LBN*BitCheck, the per-part
blocks) against routine i+1, and every transplant made there was wrong. The new **anchored passes**
pin the alignment to the firmware: seeds are the procedures both images register under the same
name, the pointer tables those reach, and long identical blocks; from each seed both instruction
streams are walked in lockstep, and every operand pair becomes an anchor (`anchors`), a constant
vote (`afix`) or the end of a span to realign (`code --anchored`).

`port-edits-v1_15i/replay.sh` (and `port-edits-v1_10i/replay.sh`) rebuild each tree from its source
tree in about 12 minutes: the removals first (so that no pass ever aligns code the target lacks),
then the anchored passes, then the clean-ups. Unlike `port-edits/`, these scripts stay replayable;
each folder's README gives the order.

Review tools, each run against the tree the port came from (`--base`):

| tool                                               | v1.15i (base v2.01i)                                | v1.10i (base v1.15i)                               |
|----------------------------------------------------|-----------------------------------------------------|----------------------------------------------------|
| `hdae5000_version_label_check.py`                  | 0 piles, 0 orphans, 107 moved, 0 rename suggestions | 0 piles, 0 orphans, 55 moved, 0 rename suggestions |
| `hdae5000_version_stale_comments.py`               | 0 in every check, 0 left                            | 0 in every check, 0 left                           |
| `hdae5000_obj_constants_check.py` (in `make gate`) | 758 constants, 0 errors                             | 755 constants, 0 errors                            |
| `port_hdae5000_version.py farptrs`                 | 0 pairs to respell                                  | 0 pairs to respell                                 |

The label check now leaves out the GUI's macro-made labels (the converter checks the GUI against
the ROM), and its marker build skips `.macro` bodies (since the GUI became a macro tree the
v2.06i tree had not assembled in it). Its "moved" rows are code that really changed, as for
v2.01i. Its 7 rename suggestions of 2026-10-30 (6 in v1.15i, 1 in v1.10i) were reviewed on
2026-10-31; see "v1.x label review" below.

### v1.x label review (2026-10-31)

Lane `open2/hdae-ledgers`. `hdae5000_version_label_check.py` listed 6 rename suggestions on v1.15i
(base v2.01i) and 1 on v1.10i (base v1.15i). `scripts/renaming/rename_hdae5000_v1_label_review.sed`
makes the renames, run once per tree by `port-edits-v1_15i/98b_label_review.py` (which also fixes
the comments around them; its docstring says why it runs once):

| suggestion (2026-10-30)                                         | what it was                                                                                                       | done                                                                            |
|-----------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| `HDAE5000_PPORT_Cmd09_SendFilesToPc_Skip` / `_Skip2` / `_Skip3` | v1.x has 8 part blocks; the port left v2.x's `.Lsfsb_bit<k>` one block off                                        | block k (mask 1 << k) is `.Lsfsb_bit<k>`; two unreferenced in-block labels gone |
| `HDAE5000_SaveOptSwEventCatch_Skip7`                            | v2.x's `_Skip3` (case 0x0a, every part; mask 0x00ff in v1.x, 0x01ff in v2.x)                                      | renamed `_Skip3`                                                                |
| `HDAE5000_CopyFdSongToHd_Pmt_Skip3`                             | v1.x reads 64 KiB per pass and writes the first chunk before a read-and-append loop                               | `.Lts925_1` / `_loop` / `_4` / `_5` / `_close`, by meaning                      |
| `HDAE5000_CopyFdSongToHd_Pmt_Skip` -> `.Lec_process`            | not a rename: `.Lec_process` belongs to HDAE5000_Smf_ReadHeader, which v1.x lacks (three generic workspace loads) | the check now requires the same routine on both sides                           |
| v1.10i `.Lrfsb_exit` -> `.Lrfsb_flag2_bit0`                     | v1.10i was right; v1.15i's `.Lrfsb_flag2_bit0` is the exit (v1.x has no flag-byte-2 block)                        | v1.15i's renamed `.Lrfsb_exit`                                                  |

Found on the way: `HDAE5000_RAM_PportPartMaskHi` was a second name of the part mask (both
0x23c4e4; v1.x has no second mask byte); its `.equ` is gone and its uses name the part mask. The
`(0x23c4e4:24)` reads of the Cmd09 chain are spelled by that name too.

The "moved" rows (107 in v1.15i, 55 in v1.10i; 117 and 55 before): 87 and 47 of them are data whose
first 8 bytes are pointers or object ids that moved. Of the 20 code rows of v1.15i, five were v2.x
ninth-part labels on v1.x code with no ninth part, renamed by the same sed (`.LHD_Data_Copy__bit8`,
`.Ltco_slot8`, `.Lcv_bit8`, `.Lir_flag2_bit0` to `__done`, `_none`, `_validate`, `_done`;
`.Ltl_chk8`, unreferenced, removed), with the "nine parts" prose of HDAE5000_Song_IsUsed and
HDAE5000_DeleteDirectory (v1.x: 8 slots, 8 DeleteSongPart_* calls). The rest are real
differences: code that changed (`.Lhbi_skip6` returns where v2.x branches; HDAE5000_CopyToHDScreen,
`.Lfbs_evt_*` and HDAE5000_PPORT_Svc13_SendInfosAboutSong save one register fewer;
HDAE5000_Frame_Handler counts frames first; `.LHD_AppendFile_Worker_Skip2`; `.Lts925_4` is `jr`
where v2.x has `jrl`), epilogues whose 3-instruction window runs into a routine that differs, the
message handler HDAE5000_FILE_LOAD_Screen_Ev01EA000C (0x01ea000c is MT_SelectDelFile in v1.x), and
tables and strings decoded as code (the ROM header, the PC-link tables, a status string).

    python3 scripts/analysis/hdae5000_version_label_check.py v1_15i --base v2_01i
    python3 scripts/analysis/hdae5000_version_label_check.py v1_10i --base v1_15i

### Website page draft (technics-docs `hdae5000.md`, section "Versions")

> Four versions of the HD-AE5000 ROM are dumped, and all four are now rebuilt byte for byte from
> source: v2.06i (`hdae5000/`), v2.01i, v1.15i and v1.10i (`hdae5000_v2_01i/`, `_v1_15i/`,
> `_v1_10i/`). The v1 firmware is the HD-AE5000 without lyrics: no lyric display, no lyric files
> (.TLX) on the hard disk or the floppy, and so eight song parts where v2 has nine. It also lacks
> the file-selection backdrop picture, the "select all" soft button, the PC link's XAP flash
> service and the PC program version check, and its boot screen has no "Version 2" line. Because
> it has no MT_SelectAll method, the HD-AE5000's own message numbers after MT_SelectSAVE are one
> lower than in v2. In both v1 dumps, entry 12 of the PC-link service table is not a valid
> pointer, so that service cannot run. v1.10i differs from v1.15i in five routines, one language
> message (the evaluation date) and its overwrite query, which is German-only.

## Ledger: the seven images the censuses gained (2026-10-31)

Lane `open2/hdae-ledgers` made KN5000 maincpu v8, v6 and v5, sub-CPU payload v1.40 and the
HD-AE5000 v2.01i, v1.15i and v1.10i images of the data census (`data_range_census.py`, 13 -> 20
images), the dispatch census (`scripts/analysis/dispatch_table_census/`, 12 -> 19), the
doc-quality census and the semantic score (rules 5), in a commit of its own (cf8b62847). Keys:
`v8`, `v6`, `v5`, `v140`, `hdae_v201`, `hdae_v115`, `hdae_v110`. v8 is v9's tree assembled with
`--defsym FW_VERSION_BYTE=0x08` (one byte differs), so every figure of it repeats v9's. The
HD-AE5000 version trees are mapped with the directories they take through `-I` (`xmirrors`).

Dispatch census, `census.py --report` on scratch maps (`build_maps.py`), compared with
`docs/coverage/dispatch-census-2026-10-30-03.json` (`--compare`: the seven are `new`, nothing rose).
No snapshot is written here; the integrator writes it after merging.

| image       | framed / used | NOT | newT | newT(x) | spellT | stale | U  | U-NOT | U-newT | null | D-unres |
|-------------|---------------|-----|------|---------|--------|-------|----|-------|--------|------|---------|
| `v8`        | 684 / 684     | 0   | 0    | 0       | 0      | 0     | 27 | 0     | 0      | 3    | 0       |
| `v6`        | 685 / 685     | 0   | 0    | 0       | 0      | 0     | 28 | 0     | 0      | 2    | 0       |
| `v5`        | 685 / 685     | 0   | 0    | 0       | 0      | 0     | 28 | 0     | 0      | 2    | 0       |
| `v140`      | 44 / 44       | 0   | 0    | 0       | 0      | 0     | 0  | 0     | 0      | 0    | 0       |
| `hdae_v201` | 66 / 66       | 0   | 0    | 0       | 0      | 0     | 0  | 0     | 0      | 0    | 0       |
| `hdae_v115` | 57 / 57       | 0   | 0    | 0       | 0      | 0     | 0  | 0     | 0      | 0    | 0       |
| `hdae_v110` | 57 / 57       | 0   | 0    | 0       | 0      | 0     | 0  | 0     | 0      | 0    | 0       |

So all seven meet the census half of the full-coverage criterion (NOT = newT = newT(x) = spellT =
U-NOT = U-newT = D-unres = 0), with no stale tables. When they were added, v6 and v5 showed
682 / 682 framed, U 31, U-NOT 5 (v5 also U-newT 1): five code-pointer tables spelled as numbers.
d44487651 and 3783cef9c fixed them (`scripts/tools/port_symbolize_pointers.py`; v5's Yoko
language checks also carried their names one procedure late, `scripts/renaming/rename_v5_langcheck_shift.sed`).
The three tables that were `.byte` rows are framed `.long` tables now, hence 682 -> 685 and U 31 -> 28.

Data census (bytes; `data_range_census.py --images ...`, every mirror inert, reconciled) and the
semantic score's names component (`semantic_score.py`'s `names()`, ELF `.text` symbols):

| image       | CODE    | KNOWN-A | KNOWN-B | UNKNOWN | FILLER  | bytes understood | semantic names         |
|-------------|---------|---------|---------|---------|---------|------------------|------------------------|
| `v8`        | 996,474 | 963,640 | 75,067  | 3,524   | 58,447  | 96.25%           | 43,350 / 45,007 96.32% |
| `v6`        | 992,858 | 945,775 | 94,122  | 3,750   | 60,647  | 95.33%           | 42,750 / 44,894 95.22% |
| `v5`        | 991,846 | 944,153 | 95,648  | 3,750   | 61,755  | 95.26%           | 42,710 / 44,852 95.22% |
| `v140`      | 128,832 | 66,348  | 1,136   | 30      | 262     | 99.41%           | 4,042 / 4,066 99.41%   |
| `hdae_v201` | 110,476 | 335,325 | 45,285  | 0       | 33,202  | 91.36%           | 6,071 / 6,071 100.00%  |
| `hdae_v115` | 95,884  | 255,022 | 42,946  | 0       | 130,436 | 91.81%           | 5,734 / 5,734 100.00%  |
| `hdae_v110` | 95,632  | 254,947 | 42,873  | 0       | 130,836 | 91.82%           | 5,720 / 5,720 100.00%  |

Doc-quality census (`doc_quality_census.py --compare` vs `doc-quality-2026-10-30-03`: the seven are
`new`, nothing rose): routines without a header / call targets without one, numeric operands
(in-image memory, in-image immediates, numeric branch targets), `.Lc_<hex>` locals, `.byte` runs
after a fall-through:

| image       | routines | no header | call, no header | mem / imm / branch numeric | `.Lc_` locals | byte runs |
|-------------|----------|-----------|-----------------|----------------------------|---------------|-----------|
| `v8`        | 8,732    | 7,275     | 4,485           | 0 / 0 / 4                  | 0             | 64        |
| `v6`        | 8,906    | 7,827     | 4,777           | 1 / 1 / 11                 | 634           | 186       |
| `v5`        | 8,907    | 7,829     | 4,775           | 1 / 1 / 10                 | 632           | 186       |
| `v140`      | 957      | 155       | 90              | 632 / - / 0                | 0             | 12        |
| `hdae_v201` | 598      | 187       | 0               | 0 / 0 / 0                  | 0             | 0         |
| `hdae_v115` | 539      | 167       | 0               | 0 / 0 / 0                  | 0             | 0         |
| `hdae_v110` | 539      | 167       | 0               | 0 / 0 / 0                  | 0             | 0         |

(v140's in-image immediates are not counted: its range starts at 0x400, as for v141 and v142.)

Reproduce (scratch only; the maps are about 0.5 GB):

    DISPATCH_CENSUS_DIR=~/compartilhado/tmp/<scratch> python3 scripts/analysis/dispatch_table_census/build_maps.py
    DISPATCH_CENSUS_DIR=~/compartilhado/tmp/<scratch> python3 scripts/analysis/dispatch_table_census/census.py \
        --compare $(git ls-files 'docs/coverage/dispatch-census-*.json' | sort | tail -1)
    python3 scripts/analysis/data_range_census.py --images v8,v6,v5,v140,hdae_v201,hdae_v115,hdae_v110
    python3 scripts/analysis/doc_quality_census.py --compare

## Follow-ups

- **Dispatch census, semantic score, doc-quality.** Done (2026-10-31, lane `open2/hdae-ledgers`):
  the three older HD-AE5000 versions, and KN5000 v8, v6, v5 and v1.40, are images of all three and
  of the data census; see "Ledger" above. The first snapshots with them are the integrator's
  (`make dispatch-census`, `make doc-quality`, `make semantic-score`).
- **Documentation website.** Done: technics-docs 944d566 (2026-10-30) gives `hdae5000.md` the section
  "Four byte-exact source trees" (v2.06i, v2.01i, v1.15i, v1.10i and what differs between them).
- **v1.x review.** Done (2026-10-31): 0 rename suggestions in either v1 tree; see "v1.x label review".
- **v2.x header and terminator.** Done (b3b788b14): both v2.x trees spell the header's image-end
  pointer and the naming tables' empty-string pointers by symbol, as the v1 trees do.
- **Open.** v5 has a second unlabelled `cp xbc, 0x1e0009f` procedure, after AttAreYouSureCheck_Skip,
  that may carry the same one-off label shift as the Yoko checks had; the census does not flag it.
  `style_ui/ctlonly_link.ld` names four Scoop_* addresses that no tree (v7, v6, v5) has at those
  names; the C data holds the values, so they may not be pointers at all. The HD-AE5000 v1 prose
  blocks still quote v2.x facts in places (for example the header of
  HDAE5000_PPORT_Svc13_SendInfosAboutSong describes the lyrics part, HDAE5000_TlxPart_Describe,
  which v1.x lacks), as the banner of each v1 tree warns.
- **Replays (2026-10-31).** At 203396a2c, `port-edits-v1_15i/replay.sh` (after `make all`) rebuilds
  `hdae5000_v1_15i/` equal to the committed tree, byte for byte and line for line.
  `port-edits-v1_10i/replay.sh` then rebuilds a byte-identical v1.10i that differs from the
  committed `hdae5000_v1_10i/` in 5 files (108 lines added, 122 removed): quoted addresses and
  counts in comments, where the replay's are v1.10i's and the committed tree's are v2.01i's or
  v1.15i's (`entry count = 67` for 0x3f), and the replay drops the committed tree's labels
  HDAE5000_Palette_FilePanel / HDAE5000_Bitmap_FilePanel (v1.x has no FilePanel picture). So the
  committed v1.10i is older than its recipe; regenerating it is left to a lane of its own (it moves
  symbols and the label check's baseline).
