# The MN10300 data generator, wave 11: indexed lists, frozen object names, the APC/SEQ slider, field names (lane mn10300-data3, 2026-11-06)

Lane `mn10300-data3` of wave 11 of the open-items effort.  Its items (`notes/open-items/REGISTER.md`):
N-61c32961, N-fb88572c, N-2468beef, N-4b34dd8b, and the data regions' opaque bytes (N-dff57eb2 KN6000,
N-6acf011c KN6500, N-b3924e48 KN2400, the O-* rows).  It continues `../mn10300-data2/README.md` (wave 10).

The machinery is `kn7000/tools/gen_data_s.py` and `data_struct_names.py`; each new rule is a key of
`gen_data_s.FEATURES` (off with `GEN_DATA_S_OFF=rule,...`): `sentinel_indexed`, `frozen_obj_names`,
`host_widget_vars`.  Probes: `../mn10300-data3-probes/` (README there).

## 1. What the generator now does

| rule (`FEATURES`)  | what it does                                                                                                                                                                                                                                                                                                                                                                                                 | reader evidence                                                                                                                                                                                                                                                     |
|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `sentinel_indexed` | `sentinel_lists()` also reads the indexed walk: `mov (dI, aT), dX` with dI a counter stepped by one and scaled to the entry width right before the load, the marker compare, and an `lne` (after `setlb`) or a branch back.  The menu parameter-id lists of KN6000 func_4C11B347, KN6500 func_4C11B237, KN2400 func_4861CCC5 and 941 / 942 / 935 / 893 func_4845BC68 are -1-ended u32 lists (five per image) | KN6000 func_4C11B347: `inc d3` / `mov d3, d1` / `mov d1, d0` / `asl2 d0` / `mov (d0, a0), d0` / `cmp d2, d0` / `lne`, d2 = -1 (`mov -1, d2` before the `setlb`), a0 one of the five lists (`mov func_4C11B347_entry_L4a_Selected_N, a0` on the paths into the loop) |
| `frozen_obj_names` | the GUI objects with an empty ResName take the names `<src>/data/gui_object_names.tsv` gives them (object id = slot << 16 plus the index, class, name), reserved before any other name of the run; a name is invented only for an object the map lacks or whose class changed, and every run writes the map back                                                                                             | the design of `../gui-data-region/README.md` (N-fb88572c); `../mn10300-data3-probes/frozen_names_check.py`                                                                                                                                                          |
| `host_widget_vars` | (a plug-in: the HD-SX3) `widget_vars()` also reads the host firmware's class procedures, which the plug-in's widgets are instances of                                                                                                                                                                                                                                                                        | the KN6000's class procedures in `kn6000/src/program.s` (`field_deref` over the host's code)                                                                                                                                                                        |
| (no switch)        | `style_panels()` writes PM_SET88 / PM_SET8C's levels and numbers in decimal (TECHNI-CHORD type, sequencer volume, pad volume, pad bank) and the masks and the 0xFF "none" in hex                                                                                                                                                                                                                             | `src/include/panel_memory.inc`                                                                                                                                                                                                                                      |

Field names added by hand (`data_struct_names.py`, N-2468beef), each with its reader cited there:

- `LconvMonetary` / `LconvNumeric` (`localeconv_Records` / `_Records_2`, every tree that has them): the C
  library's locale categories.  localeconv 0x4C00206A copies the numeric category's +4 / +8 / +0xC to the
  static `struct lconv`'s decimal_point / thousands_sep / grouping (0x50008270 / 74 / 78) and the monetary
  category's +4 .. +0x1C and +0x20 .. +0x27 to int_curr_symbol .. negative_sign (0x5000827C .. 94) and
  int_frac_digits .. n_sign_posn (0x50008298 .. 9F), the C89 member order; +0 is the category's locale name.
- `TextCentre` (DrawStringCentered's a1: the point the text is centred on, `x = centre.x - width / 2`),
  `BitmapOrigin` / `BmpFileOrigin` (DrawBitmapSP2 / Draw2BpFile's a0 = &point), {x, y}.
- `VoiceDir*Node` {next, key}: the voice directory's hash chains (VoiceDir*Find: bucket from the table, `(4,
  a2)` compared by the KeyEqual routine, `(a2)` the next node; VoiceDirPartRefFind answers node + 8, `value`).
- `GenreStyleEntry` {name, style_count, styles} (GetGenreName memcpy 16, GetGenreStyleCount +0x11,
  func_48435AFF +0x14's list); `EditSwPoint` under the labels the second bank has since the table split.
- by label pattern (`NAMES_RE`, because the readers are address-named and differ by build):
  `PanelMemFieldMap` {param_off, rec_off, mask}, the one-touch / panel-memory field maps of every build and
  sibling (941 func_4C02A0C4 `movbu (a1)` / `movbu (1, a1)` / `movbu (2, a1)` / `and` / `movbu d1, (d2,
  a0)`: record[+1] = live[+0] & mask; the mergers, KN2400 func_50157736, live[+0] = live[+0] & ~mask |
  record[+1] & mask), and `EqEditLabel` {label}, the EQ edit boxes' value texts (strcpy).
- `ChordRecogEntry2` with its 2,048-record count, and `ChordRecogEntry`, under the labels of 942 / 935 / 893 and
  the siblings (the reader is func_4844D297's code instruction for instruction; KN6000 func_4C09DC6F, the twin
  of func_4844D680, builds the same 11-bit interval mask): 1,500 bytes per image were table-tail.

## 2. The items

| item       | outcome                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
|------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| N-61c32961 | CLOSED: `sentinel_indexed` (section 1).  The bytes were the five menu parameter-id lists func_4C11B347 (KN6000; KN6500 func_4C11B237, KN2400 func_4861CCC5, 941 func_4845BC68) picks from by a menu kind (`cmp 0x40` / `0x41` / `0x42`, the byte table `func_4C11B347_Table` for kinds 0..0x12) and walks by index to -1; they were 52-byte records with opaque gaps (KN6000 400 bytes) or a 4-byte record plus an indexed tail (941).  The byte table is typed too (20 bytes, read `movbu (d0, a0)`)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    |
| N-fb88572c | CLOSED: `frozen_obj_names`, as designed in `../gui-data-region/README.md`: `<src>/data/gui_object_names.tsv` in every tree (941 6,309 rows), read before any name is made and written back by each run.  Checked: a second run reproduces every file; editing one row renames that object and nothing else (its `next` / `prev` / `OBJ` references follow); `../mn10300-data3-probes/frozen_names_check.py` finds every row's name in labels.sym and none twice                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| N-4b34dd8b | CLOSED: PM_SET88's `m008008` is `apc_volume`, the APC (accompaniment) VOLUME.  941 func_48454E3A (KN6000 func_4C114272) sets 0x008008 / 0x008006 from PanelCtrlValueGet(0xC2) (KN6000 0xC6): index 26 (30) of PanelCtrlValueGet_Table, 0x5006BEAD (0x50022787), the byte PanelCtrlLatch32 (func_4C047993) latches from wire 0xD2 (0xD6), the CPL panel CPU's AD2 (AD6); the KN7000 service manual wires AD2 to VR1102 "APC/SEQUENCER", the SX-KN6500 one AD6 to VR1 "APC/SEQUENCER VOLUME", and kn7000_mame's `notes/slider-cp-protocol.md` found wire 0xD2 to be that slider at run time.  func_48454D21 answers 0 in DEMO and whenever no sequencer part plays (GetSeqPlyPart): then 0x008008 follows the slider and 0x008006 is held at 0x7F; while the sequencer plays the two swap, so 0x008008 is APC VOLUME and 0x008006 SEQ VOLUME (the firmware's own parameter dump says the same: lane kn7000-research, `../presentation-control-probes/song-records.md`; wave 10's note and this lane's first commit 1843c2cb0 had the two the wrong way round, corrected in the final commit).  With it the other `m<id>` names lane kn7000-research handed over (`../kn7000-research/README.md`): master_tune, msa_on, apc_type, apc_type_alt, rhythm_sync, drawbar_type, tabs_1, tabs_2 (`floppy/tools/kd/gen_panel_macros.py`, `scripts/renaming/rename_panel_memory_fields.sed`).  `panel_ctrl_slider.py`; PM_SET88 / PM_SET8C are written in decimal where they are levels and numbers |
| N-2468beef | OPEN (L, progress): the names of section 1; offset-named fields with a reader (section 3) 941 244 -> 203, 942 246 -> 203, 935 / 893 251 -> 225, KN6000 255 -> 221, KN6500 254 -> 220, KN2400 194 -> 160, HD-SX3 37 -> 20.  Next step: the same, kind by kind from `../mn10300-formats-probes/field_names_census.py --list`; the largest left are TgPartEditLfoLoadA_Records (16 to 18 per tree) and the KN6000 / KN6500 160-byte tone-generator register image func_4C0948CB_ArgA0 (48 fields, each written to MAIN TG register (field << 16) through 0x98050000, which needs the TG register map)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| N-dff57eb2 | OPEN (L, progress): KN6000 opaque 774 / 18,082 -> 764 / 16,206 bytes (section 3).  Next: the KN6000's effect-DSP records (labelled-held, 8,435 bytes: data_4C398C64.. and the pointer table at data_06.s that holds them) need the KN6000 effect DSP's stream format, as `fx_streams` has the KN2400's; the 852 / 296 / 192-byte `names_*` second halves (file-name slots) and the GUI-name tables are the next table-tails                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| N-6acf011c | OPEN (L, progress): KN6500 765 / 20,216 -> 755 / 18,340 bytes; the same groups as the KN6000's                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| N-b3924e48 | OPEN (L, progress): KN2400 801 / 18,746 -> 790 / 16,682 bytes; next the table-tail of `names_48545C20` (1,080) and func_50186924_Selected_6 (856), the after-string group (2,711)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| O-* rows   | section 4: every group's before / after.  O-hdsx3-unknown-dump-a08889 reaches 0 and f491a3 28 -> 8 bytes (`host_widget_vars`: the HD-SX3's ram-widget-var group 12 / 48 -> 2 / 8); the other O-hdsx3 rows do not move (a 9-rect table only the host's DrawFrame reads, text tails, words no class procedure dereferences); no MN10300 O- row rose                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |

## 3. Measurements

Before: the base 2bde950fa's committed data directories (`git archive`); after: this branch's, regenerated
(`../mn10300-data-probes/data_stats.py --dirs BEFORE AFTER --brief`: typed bytes from labels.sym, reader rows
and opaque pieces n / bytes, offset-named fields with a reader, bytes a BEFORE item held that no AFTER item
holds):

| tree                           | typed before | typed after | change | reader rows before | reader rows after | opaque before | opaque after | offset-named fields before | after | typed before only |
|--------------------------------|--------------|-------------|--------|--------------------|-------------------|---------------|--------------|----------------------------|-------|-------------------|
| kn7000/src/program/data        | 2,264,713    | 2,264,713   | +0     | 76 / 836           | 76 / 836          | 629 / 9,760   | 629 / 9,760  | 244                        | 203   | 0                 |
| kn7000/src/sp7001/program/data | 2,265,957    | 2,269,541   | +3,584 | 79 / 944           | 79 / 944          | 641 / 11,133  | 634 / 9,633  | 246                        | 203   | 0                 |
| kn7000/src/b935/program/data   | 2,262,066    | 2,265,650   | +3,584 | 82 / 980           | 82 / 980          | 654 / 11,800  | 647 / 10,300 | 251                        | 225   | 0                 |
| kn7000/src/b893/program/data   | 2,262,353    | 2,265,937   | +3,584 | 77 / 848           | 77 / 848          | 643 / 11,333  | 636 / 9,833  | 251                        | 225   | 0                 |
| kn6000/src/program/data        | 2,556,875    | 2,560,919   | +4,044 | 129 / 8,449        | 126 / 8,365       | 774 / 18,082  | 764 / 16,206 | 255                        | 221   | 24                |
| kn6500/src/program/data        | 2,070,274    | 2,074,318   | +4,044 | 134 / 8,565        | 131 / 8,481       | 765 / 20,216  | 755 / 18,340 | 254                        | 220   | 24                |
| kn2400/src/program/data        | 1,916,287    | 1,920,463   | +4,176 | 135 / 1,749        | 134 / 1,721       | 801 / 18,746  | 790 / 16,682 | 194                        | 160   | 0                 |
| hdsx3/src/program/data         | 484,906      | 485,452     | +546   | 34 / 211           | 34 / 211          | 40 / 386      | 30 / 346     | 37                         | 20    | 0                 |

941 gains no typed byte: its func_4845BC68 lists were already typed (a 4-byte record and an indexed tail),
now they are lists; 942 / 935 / 893 and the siblings gain the chord table's 1,500 + the lists.  The KN6000 /
KN6500 "typed before only" 24 bytes are not this lane's rules: they came with the merge of lane
sibling-names, whose `kn6000_aligned.sym` names 0x50000000 `WORK_RAM_BASE`; func_4C0506C7_entry_L4_Records'
field +0 (0x50000000, 0x58000000, 0x54000000: bus-window bases, values) then reads as a pointer, and the
inferred count stops at the first record whose +0 is no named address (3 records -> 1).  Next step: a
count for that array from its reader, or not taking a window base for a data pointer.

Offset-named fields with a reader (`../mn10300-formats-probes/field_names_census.py`): the column above;
the KN7000 builds lose 26 to 43 each, the siblings 34, the HD-SX3 17.

## 4. The opaque groups

`../mn10300-data-probes/opaque_left.py` by group, base 2bde950fa -> this branch (bytes):

| tree   | false-string   | table-tail     | after-string   | labelled-held  | align-pad  | record-rest | ram-widget-var | other      | total            |
|--------|----------------|----------------|----------------|----------------|------------|-------------|----------------|------------|------------------|
| 941    | 2,426 -> 2,426 | 3,556 -> 3,556 | 1,389 -> 1,389 | 1,398 -> 1,398 | 217 -> 217 | 219 -> 219  | 128 -> 128     | 348 -> 348 | 9,760 -> 9,760   |
| 942    | 2,285 -> 2,285 | 5,060 -> 3,560 | 1,389 -> 1,389 | 1,405 -> 1,405 | 220 -> 220 | 219 -> 219  | 128 -> 128     | 348 -> 348 | 11,133 -> 9,633  |
| 935    | 2,426 -> 2,426 | 5,056 -> 3,556 | 1,925 -> 1,925 | 1,406 -> 1,406 | 217 -> 217 | 219 -> 219  | 128 -> 128     | 332 -> 332 | 11,800 -> 10,300 |
| 893    | 2,320 -> 2,320 | 5,055 -> 3,555 | 1,573 -> 1,573 | 1,398 -> 1,398 | 217 -> 217 | 219 -> 219  | 128 -> 128     | 332 -> 332 | 11,333 -> 9,833  |
| kn6000 | 2,024 -> 2,024 | 5,965 -> 4,089 | 946 -> 946     | 8,435 -> 8,435 | 288 -> 288 | 0 -> 0      | 128 -> 128     | 232 -> 232 | 18,082 -> 16,206 |
| kn6500 | 3,979 -> 3,979 | 5,780 -> 3,904 | 902 -> 902     | 8,892 -> 8,892 | 297 -> 297 | 0 -> 0      | 128 -> 128     | 176 -> 176 | 20,216 -> 18,340 |
| kn2400 | 1,795 -> 1,795 | 7,483 -> 5,419 | 2,711 -> 2,711 | 6,013 -> 6,013 | 207 -> 207 | 125 -> 125  | 4 -> 4         | 176 -> 176 | 18,746 -> 16,682 |
| hdsx3  | 133 -> 133     | 4 -> 4         | 93 -> 93       | 76 -> 76       | 10 -> 10   | 6 -> 6      | 48 -> 8        | 0 -> 0     | 386 -> 346       |

The table-tail drops are the chord table (1,500 bytes per image) and, in the siblings, the menu
parameter-id lists (KN6000 / KN6500 400 bytes, the lists' opaque gaps, less the 24 bytes section 3 explains; KN2400 564).  What is left is as
`../mn10300-data2/README.md` section 4 describes; the next records with readers are listed with the items
above.

The register's O- rows of the HD-SX3 (`../mn10300-data2-probes/opaque_rows.py`: BEFORE the register as committed,
AFTER the census on this branch; no MN10300 O- row rose; all rows together 143,101 -> 91,100 bytes, of which
101,456 -> 91,100 are this lane's, wave 10's table ending at 101,456):

| id                          | class                               | pieces / bytes before | pieces / bytes after | bytes |
|-----------------------------|-------------------------------------|-----------------------|----------------------|-------|
| O-hdsx3-unknown-dump-274483 | binary, program flash               | 19 / 102              | 19 / 102             | +0    |
| O-hdsx3-unknown-dump-71c25d | 7-bit values, program flash         | 1 / 8                 | 1 / 8                | +0    |
| O-hdsx3-unknown-dump-a08889 | 7-bit values, initialised-RAM image | 5 / 20                | 0 / 0                | -20   |
| O-hdsx3-unknown-dump-b7393d | address-like words, program flash   | 2 / 55                | 2 / 55               | +0    |
| O-hdsx3-unknown-dump-bfbe48 | address-like words, RAM image       | 3 / 16                | 3 / 16               | +0    |
| O-hdsx3-unknown-dump-f491a3 | binary, initialised-RAM image       | 7 / 28                | 2 / 8                | -20   |

O-hdsx3-unknown-dump-a08889 reaches 0 (the five 4-byte widget variables, now read through the KN6000's class
procedures); f491a3 keeps 2 / 8 (two widget words no class procedure dereferences).

## 5. Regenerating, and what this lane could not run

After the tool commits, in this order (in a worktree, with the absolute Makefile overrides, `UNIDASM=` and
`SP7001_UPDATES=`; `baserom/kn7000_table_b80.rom` must exist for the 893 code generation, `make -C kn7000
baserom/kn7000_table_b80.rom`):

1. `make -C kn7000 verify verify-sp7001 verify-935 verify-893` (the labels the KN7000 generation reads);
2. `make -C kn2400 data-and-code-src`, the same for `kn6000` and `kn6500` (in parallel), then `hdsx3` (its host
   is the KN6000: `host_widget_vars` reads the KN6000's code), then `make -C <each> gui-map`;
3. `make -C kn7000 data-and-code-src` (fixpoint after 2 rounds), `make -C kn7000 gui-map`;
4. `python3 -I floppy/tools/kd/gen_panel_macros.py` (panel_memory.inc's PMR section).

Each tree's `gui_object_names.tsv` is written by the generation and read by the next one; deleting it makes
the next run invent the names afresh (as before this lane) and freeze them again.

Not run: `make -C kn7000 plugin-src`.  `gen_data_s.py --profile sp7001plugin` fails on the base 2bde950fa as on
this branch (`AttributeError` in obj_names: object 4 of block 0x2F0, Main_KssTextBox1, has no class):
milk_model finds no class-table registration of the plug-in (slot 0x2F4, `calls (a1)` reached through `mov
(KssFrameworkObj), d0` / `mov 0x1c, a2` / `add d0, a2` / `mov (a2), a0` / `mov (0x174, a0), a1`, a shape
parse_calls does not track since the plug-in's code names KssFrameworkObj).  The plug-in's data stays as
committed (2026-11-02).  Next step: parse_calls follows `add dN, aM` from a tracked host-table base.

Lane kn7000-research's hand-overs: the `m<id>` panel-memory names are applied (section 2, N-4b34dd8b);
0x484101FD (a routine a data word references, N-99771106) is named by the KN7000 regeneration of step 3
once its symbol file names it (merged from main before the regeneration).

## Website page draft

(For the KN7000, KN6000 / KN6500, KN2400 and HD-SX3 program-data pages of technics-docs.)

> **Stable names, menu lists and the APC / SEQUENCER slider.**  The firmware's screens hold thousands of
> widgets with no resource name of their own; the disassembly invents a name for each (its screen, its
> class and the text it shows) and now keeps those names in a table beside the source, so that they no
> longer change when the source is regenerated.  The lists of parameters a menu screen offers (the
> MASTER TUNE, MSA, APC and drawbar settings and the rest, as 24-bit parameter ids ended by -1) are typed
> as lists.  In the one-touch settings and panel memories, the byte that was called `m008008` is the APC
> VOLUME: the APC / SEQUENCER VOLUME slider (on the KN7000 the panel CPU's input AD2, VR1102; on the
> KN6000 / KN6500 AD6, VR1) sets the APC VOLUME while no song plays and the SEQ VOLUME while the sequencer
> plays, holding the other at full level.  The C library's locale tables, the voice directory's hash
> chains and the chord-recognition table's 2,048 entries are typed in every build.
