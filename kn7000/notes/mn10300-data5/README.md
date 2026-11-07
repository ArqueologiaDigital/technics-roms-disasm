# The MN10300 data generator, wave 13: dispatch lists, copies, text cells, names by the reader (lane mn10300-data5, 2026-11-07)

Lane `mn10300-data5` of wave 13 of the open-items effort.  Its items (`notes/open-items/REGISTER.md`): N-2468beef,
N-dff57eb2 (KN6000), N-6acf011c (KN6500), N-b3924e48 (KN2400), the KN7000 builds' opaque groups and the O-* rows of
the MN10300 data regions.  It continues `../mn10300-data4/README.md` (wave 12).  Probes: `../mn10300-data5-probes/`
(README there); the wave 6 .. 12 probes it reuses: `../mn10300-data-probes/opaque_left.py`,
`../mn10300-data4-probes/opaque_classes_diff.py`, `../mn10300-formats-probes/field_names_census.py`.

The machinery is `kn7000/tools/gen_data_s.py` and `data_struct_names.py`; each new rule is a key of
`gen_data_s.FEATURES` (off with `GEN_DATA_S_OFF=rule,...`): `sentinel_copy`, `float_pairs`, `dup_spans`,
`copied_reclaim`.  Tools commit 1b0044cb9; the regenerated sources are separate commits.

## 1. What the generator now does

| rule                             | what it does                                                                                                                                                                                                                                                                                                                                | reader evidence                                                                                                                                                                                                                                                                                                                                             |
|----------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `sentinel_copy`                  | `sentinel_lists` also reads a walk whose loaded word is copied to an address register before the compare, and whose pointer is the list's start plus the marker field's offset (`mov K, aR` / `add dZ, aR`).  The M3 hook dispatch lists ({mask, value, handler} records, 12 bytes, ended by a record whose handler is 0) are typed whole   | 941 func_4C021761 / KN6000 func_4C03CD2C: `mov func_..._Selected_k, d2` per case, then `mov 8, a3` / `add d2, a3`; the loop `mov (a3), d0` / `mov d0, a0` / `cmp 0, d0` / `beq` (end), `(d0 & +0) == +4` -> `calls (a0)`, `add 0xc` to all three pointers.  The same in 941 func_4C0216A3 (KN6000 func_4C03CC6E, `M3HookDispatch`), every build and sibling |
| `float_pairs`                    | `doubles()` leaves a run whose 8-byte words read as two plausible singles each (exponent 2^-31 .. 2^32, at least 4 words with a low word not 0, three quarters of them) to the later passes                                                                                                                                                 | by value [INFERENCE]: a double's low word is mantissa bits, a plausible single about one time in four (the KN7000 935 / KN6500 74-word double tables: 15 of 72).  Only the KN2400's `doubles_4840DE50` passes (61 of 62): `float_pairs.py`                                                                                                                  |
| `dup_spans`                      | free bytes (>= 32, >= 8 distinct values) that are a byte-identical copy of typed items elsewhere, from one item's start to an item's end: typed as those items again, each by its own rule, under `<item>_Copy`, with a comment that nothing is seen to read the copy.  Only items whose rendering defines their own label alone are copied | the byte identity (`opaque_copies.py`).  KN2400 0x4840DAF8 .. 0x4840E040 (1,352 bytes) = 0x4840D45C .. 0x4840D9A4: the interpolation tables func_50186924 / func_50186981 read and the float tables of func_50189206 / func_5018884C / func_5018888A, a second time, unreferenced; every tree's EQ band labels ("   20", "   25", " 31.5" ...) twice        |
| `copied_reclaim`                 | `copied_blocks` takes back a block whose bytes are all NUL-ended text cells when a string guess took its first cell, and writes a block of text cells as `.asciz` lines                                                                                                                                                                     | 941 AcAcdnTabProc 0x4849989C `mov AcAcdnTabProc_Table, a1` / `mov (d0, a1), a1` / `mov 0x12, d0` / `call memcpy`: each entry is an 18-byte accordion register diagram, three 6-byte cells of `"  \x95  "` (0x95 a bullet glyph) or blanks.  The siblings' twins (KN6000 / KN6500 / KN2400) the same                                                         |
| `data_struct_names.reader_alias` | an array labelled `func_<ADDR>_<suffix>` (a label the generator keeps from before its reader had a name) is also looked up under `<the routine's name now><suffix>`; the label itself is kept                                                                                                                                               | 935's `func_4C00206A_Records` is read by `localeconv` 0x4C00206A (named since): it takes 941's `LconvMonetary` / `LconvNumeric` names; `func_48489E33_Table` (TtMessage) takes `MessageBoxDef`                                                                                                                                                              |

Curated kinds added (`data_struct_names.py`, N-2468beef; each entry's comment there cites its reader):

| kind                                                           | array (941; the other builds' labels in the entry)                                                                 | fields                                                                                                               | evidence                                                                                                                                                                                                                    |
|----------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `T_CFLG` / `T_CFLG_s8`                                         | `cre_flg_ArgA0`, every build and sibling                                                                           | exinf, flgatr, iflgptn                                                                                               | cre_flg_Impl copies +0 / +4 (16 bits) / +8 to the flag block +0x10 / +8 / +0xC; set_flg_Impl ORs into +0xC (the pattern).  +0 / +4 by the uITRON 3.0 order [INFERENCE]                                                      |
| `T_DefTimeHandler`                                             | `func_4C03C8D0_ArgA0` (941, 935)                                                                                   | exinf, handler, mode, time_hi, time_lo                                                                               | func_4C03C8D0 fills the handler block 0x50380824 + n * 32 (a0 = -1 deletes), then func_4C03BA20 starts it; def_cyc or def_alm [INFERENCE: not settled, the routine reports no error code]                                   |
| `InOutTestTextPos` / `StatePos`                                | `InOutTestWindowProc_Var_2` / `_Records`                                                                           | x, y                                                                                                                 | InOutTestWindowProc: the corner of the DrawString rectangle (+0x104 / +0x78 / +0x50 wide)                                                                                                                                   |
| `SdCommandFrame`                                               | `SdCommandSend_ArgA0` (KN7000 builds, KN2400)                                                                      | clock_mode, resp_type, cmd, crc7                                                                                     | SdCommandSend (kn7000_manual.sym): SdSpiClockSet(+0), SdResponseScan(+2), 6 bytes from +4 sent, SdCmdCrc7's byte stored at +9                                                                                               |
| `StylePartTemplate`                                            | `StylePartTemplateDefault_Result`, every build and sibling                                                         | pc_d1, pc_d2, pc_d3, bend_d1, bend_d2                                                                                | StylePartFieldEmit: kind C0 sends +2 .. +4, kind E0 sends +0x13 / +0x14 [INFERENCE: which is program / bank not traced: named by place in the message]                                                                      |
| `AppTaskState`                                                 | `func_484288AC_Table` (941 / 942), `func_4842886A_Table` (935 / 893)                                               | q_rd, q_wr, q_size, msg_flag, lock_flag, cur_class, main_obj, msg_obj / event / param, call_obj / msg / param, q_buf | func_484285DF (post: +0 vs +2 + 1, +4 the size, lock +8, buffer +0x2C), InitDrawTask (waits on +6), func_48428C3E (the message into +0x14 .. +0x1C), ProcCall (+0x20 .. +0x28, +0xC around the call), func_48428550 (+0x10) |
| `JpegMode{H,V}Sampling`, `JpegModeQuantSel`, `JpegModeHuffSel` | `func_4840EBC3_Table(_2)`, `func_4840D29C_Records(_2)` (941 / 942; 935 / 893 `func_48406633_*`, `func_48404D10_*`) | comp0 .. comp3                                                                                                       | JpegEncSetup copies the mode's record of each into the parameter block; the values are grey / 4:4:4 / 4:2:2 / 4:2:0 / 4:1:1 [INFERENCE: which table is which from the values]                                               |
| `BlockPatch`                                                   | `func_4C02B569_Records`, `func_4C02B542_Records` (941, 935)                                                        | off, ops, val0, val1                                                                                                 | func_4C02B569 runs the op list +4 (func_4C02B591, ops 0 .. 6, 0xFF ends) on block + +0 + 2; func_4C02B6F8 stores +8 / +9 at block[+0] / [+0 + 1]                                                                            |

## 2. The items

| item                  | outcome                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
|-----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| N-2468beef            | OPEN (L, progress): offset-named fields with a reader (`field_names_census.py`, section 3) 941 185 -> 136, 942 185 -> 148, 935 207 -> 140, 893 207 -> 152, KN6000 157 -> 150, KN6500 156 -> 149, KN2400 142 -> 131, HD-SX3 20 -> 20.  The wave-12 next steps are done (func_4C00206A / _4C002055_Records by `reader_alias`, func_484288AC_Table = AppTaskState) except func_4841202C_Table_2_p0.  Next: func_4841202C_Table_2_p0 / func_48411FEA_Table_2_p0 (the DSP effect types' descriptors: +8 .. +12 are five s8 getters, func_484120D9 .. func_4841214D, whose callers in the effect edit code say what each selects), SndRecTriFieldGet2_Table_2_p0, StartFeatureDemo_Table_p0, MusicStylistPanelData, then `field_names_census.py --list` kind by kind |
| N-dff57eb2            | OPEN (L, progress): KN6000 opaque 696 / 7,665 -> 662 / 6,507 bytes: the dispatch-list tails (660 bytes, `sentinel_copy`), the accordion diagrams' cells (312, `copied_reclaim`), the EQ band labels' copy (186, `dup_spans`).  Left, largest first: labelled-held 2,380, table-tail 2,037 (func_4C05E846_Block_2 198, ResourceIdLeaf tails, VocalistGrid_L16b_Table 88), false-string 886, after-string 540.  Next: the copied blocks' tails (func_4C05E846_Block_2: a 198-byte remainder after a memcpy'd block, all builds), the ResourceIdLeaf tails (resource_trie's leaf variants), the false-string pieces one by one                                                                                                                                    |
| N-6acf011c            | OPEN (L, progress): KN6500 653 / 8,633 (from 687 / 9,791), the same rules; its false-string group is 2,841 bytes (one piece of 1,998 bytes at 0x37654E: its first 1,838 bytes are a copy of func_4C16F9FF_Table + 322, `opaque_copies.py`, not taken because the source span does not start at an item); next as the KN6000, and that piece                                                                                                                                                                                                                                                                                                                                                                                                                    |
| N-b3924e48            | OPEN (L, progress): KN2400 729 / 12,004 (from 769 / 13,880): func_50186924_Selected_6's 856-byte tail is gone -- it and the 496 "doubles" after it are the second copy of the interpolation and float tables (`dup_spans`, `float_pairs`), plus the dispatch lists and accordion cells.  The 11-point interpolation tables themselves are still split by the generator into a 4-byte `REC_func_50186924_ArgA0` and a 10 x u32 table (func_50186924 interpolates `(d1, a0)` / `(4, a0)` with d1 = x / 10 * 4: 11 points, 0 .. 100) and one is mistyped as a string (`Str_empty_1216`); typed, not opaque, so outside the census.  Next: labelled-held 6,013 (func_5016594F's switch blocks), table-tail 2,351, after-string 1,233                               |
| KN7000 builds' groups | OPEN (progress): 941 629 / 9,760 -> 8,038, 942 9,633 -> 7,911, 935 10,300 -> 8,578, 893 9,833 -> 8,111 (section 4): dispatch lists, accordion diagrams, EQ band labels' copies and the 255-byte copy (941 0x34C495).  Largest left in 941: table-tail (TgPartEgRampBuild_Table_3 304, func_4843CAF9_Block_2 198, func_484061F9_Table_p0_* 40 .. 98), false-string (Str_empty_276 641: the bytes after a NUL a string guess took, Str_N 336, Str_empty_307 255 = i * 0x12 mod 256), labelled-held 1,398                                                                                                                                                                                                                                                         |
| O-* rows              | section 4: every MN10300 row of the KN7000 builds and the siblings holds or falls; none rises; HD-SX3 does not move.  No row reaches 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

## 3. Measurements

Before: the base 92b5cc4a7's data directories (`git archive 92b5cc4a7 <tree>/src/.../program/data | tar -x -C BASE`);
after: this branch, regenerated.

Opaque bytes (`python3 -I kn7000/notes/mn10300-data5-probes/opaque_diff.py BASE/<dir> <dir>`; "newly opaque" is 0 for
every tree) and offset-named fields with a reader (`cd kn7000; python3 notes/mn10300-formats-probes/field_names_census.py --md`):

| tree   | opaque before | opaque after | no longer opaque | newly opaque | offset-named before | offset-named after |
|--------|---------------|--------------|------------------|--------------|---------------------|--------------------|
| 941    | 9,760         | 8,038        | 1,722            | 0            | 185                 | 136                |
| 942    | 9,633         | 7,911        | 1,722            | 0            | 185                 | 148                |
| 935    | 10,300        | 8,578        | 1,722            | 0            | 207                 | 140                |
| 893    | 9,833         | 8,111        | 1,722            | 0            | 207                 | 152                |
| kn6000 | 7,665         | 6,507        | 1,158            | 0            | 157                 | 150                |
| kn6500 | 9,791         | 8,633        | 1,158            | 0            | 156                 | 149                |
| kn2400 | 13,880        | 12,004       | 1,876            | 0            | 142                 | 131                |
| hdsx3  | 288           | 288          | 0                | 0            | 20                  | 20                 |

## 4. The opaque groups and classes

`python3 -I kn7000/notes/mn10300-data-probes/opaque_left.py --tree <t>` (bytes), base -> this branch:

| tree   | false-string   | table-tail     | after-string   | labelled-held  | other groups | total            |
|--------|----------------|----------------|----------------|----------------|--------------|------------------|
| 941    | 2,426 -> 2,282 | 3,556 -> 2,800 | 1,389 -> 567   | 1,398 -> 1,398 | 991 -> 991   | 9,760 -> 8,038   |
| kn6000 | 994 -> 886     | 2,697 -> 2,037 | 930 -> 540     | 2,380 -> 2,380 | 664 -> 664   | 7,665 -> 6,507   |
| kn6500 | 2,949 -> 2,841 | 2,504 -> 1,844 | 886 -> 496     | 2,837 -> 2,837 | 615 -> 615   | 9,791 -> 8,633   |
| kn2400 | 1,795 -> 1,691 | 3,859 -> 2,351 | 1,497 -> 1,233 | 6,013 -> 6,013 | 716 -> 716   | 13,880 -> 12,004 |
| hdsx3  | 133 -> 133     | 4 -> 4         | 35 -> 35       | 76 -> 76       | 40 -> 40     | 288 -> 288       |

The register's O- rows by class (`python3 -I kn7000/notes/mn10300-data4-probes/opaque_classes_diff.py BASE`), pieces /
bytes; rows that do not move are left out (they hold; HD-SX3 holds whole).  The fields' KN7000 figures are after the
code rounds of `data-and-code-src` (the regenerated code names more readers' uses than a lone data run: 160 / 164 /
164 / 168 in the scratch runs before them):

| id                                   | tree   | class                                    | where             | pieces / bytes before | pieces / bytes after |
|--------------------------------------|--------|------------------------------------------|-------------------|-----------------------|----------------------|
| O-kn7000-program-unknown-dump-274483 | 941    | binary                                   | the program flash | 240 / 6,804           | 228 / 5,988          |
| O-kn7000-program-unknown-dump-1bf2b6 | 941    | printable bytes, not NUL-terminated text | the program flash | 128 / 1,364           | 96 / 458             |
|                                      | 941    | total                                    |                   | 629 / 9,760           | 585 / 8,038          |
| O-kn7000-sp7001-unknown-dump-274483  | 942    | binary                                   | the program flash | 243 / 6,661           | 231 / 5,845          |
| O-kn7000-sp7001-unknown-dump-1bf2b6  | 942    | printable bytes, not NUL-terminated text | the program flash | 126 / 1,352           | 94 / 446             |
|                                      | 942    | total                                    |                   | 634 / 9,633           | 590 / 7,911          |
| O-kn7000-b935-unknown-dump-274483    | 935    | binary                                   | the program flash | 238 / 6,618           | 226 / 5,802          |
| O-kn7000-b935-unknown-dump-1bf2b6    | 935    | printable bytes, not NUL-terminated text | the program flash | 123 / 1,393           | 91 / 487             |
|                                      | 935    | total                                    |                   | 647 / 10,300          | 603 / 8,578          |
| O-kn7000-b893-unknown-dump-274483    | 893    | binary                                   | the program flash | 237 / 6,605           | 225 / 5,789          |
| O-kn7000-b893-unknown-dump-1bf2b6    | 893    | printable bytes, not NUL-terminated text | the program flash | 133 / 1,402           | 101 / 496            |
|                                      | 893    | total                                    |                   | 636 / 9,833           | 592 / 8,111          |
| O-kn6000-unknown-dump-274483         | kn6000 | binary                                   | the program flash | 325 / 4,789           | 315 / 4,093          |
| O-kn6000-unknown-dump-1bf2b6         | kn6000 | printable bytes, not NUL-terminated text | the program flash | 130 / 939             | 106 / 477            |
|                                      | kn6000 | total                                    |                   | 696 / 7,665           | 662 / 6,507          |
| O-kn6500-unknown-dump-274483         | kn6500 | binary                                   | the program flash | 322 / 6,602           | 312 / 5,906          |
| O-kn6500-unknown-dump-1bf2b6         | kn6500 | printable bytes, not NUL-terminated text | the program flash | 141 / 987             | 117 / 525            |
|                                      | kn6500 | total                                    |                   | 687 / 9,791           | 653 / 8,633          |
| O-kn2400-unknown-dump-274483         | kn2400 | binary                                   | the program flash | 462 / 10,282          | 451 / 8,754          |
| O-kn2400-unknown-dump-1bf2b6         | kn2400 | printable bytes, not NUL-terminated text | the program flash | 131 / 1,480           | 102 / 1,132          |
|                                      | kn2400 | total                                    |                   | 769 / 13,880          | 729 / 12,004         |

## 5. Regenerating

After the tools commit, in mn10300-data4's order (in a worktree, with the absolute Makefile overrides, `UNIDASM=`,
`SP7001_UPDATES=`, `CA_MIRROR=`):

1. `make -C kn7000 verify verify-sp7001 verify-935 verify-893` (the labels the KN7000 generation reads);
2. `make -C kn2400 data-and-code-src`, the same for `kn6000` and `kn6500` (in parallel), then `hdsx3`; `make -C <each>
   gui-map` (each a fixpoint after 2 rounds);
3. `make -C kn7000 data-and-code-src`, `make -C kn7000 plugin-src`, `make -C kn7000 gui-map`;
4. `python3 -I floppy/tools/kd/gen_panel_macros.py` (unchanged by this lane).

The program sources change only where the code names a renamed data label (the accordion blocks were
`Str_empty_*`, now `AcAcdnTabProc_Block*`; the data names them, the code does not).

## Website page draft

(For the KN7000 / KN6000 / KN2400 program-data pages of technics-docs, after the GUI section.)

> **Hook dispatch lists.**  Parameter changes are fanned out through lists of {mask, value, handler} records:
> for a parameter id d0 the firmware calls every handler whose `(d0 & mask) == value`, until a record whose handler
> is 0.  Nine lists, chosen by the parameter's group, sit in each image (941 around func_4C021761), and are now
> typed whole.  **Accordion register diagrams.**  The accordion tab's register symbols are 18-byte pictures: three
> 5-character cells of blanks and bullets (0x95 in the firmware's font), copied whole for drawing.  **Copies.**
> Some tables stand twice in an image with nothing pointing at the second copy: the SX-KN2400 keeps its whole set of
> interpolation tables (11-point curves read between points at steps of 10, a 16-point one at steps of 8, and
> single-precision curves) twice; every image keeps the 31 EQ band labels twice.  The copies are now written as
> copies of the typed originals.
