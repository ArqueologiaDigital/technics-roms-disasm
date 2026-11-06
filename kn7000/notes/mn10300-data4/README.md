# The MN10300 data generator, wave 12: effect-DSP parameter lists, name tables, the plug-in, field names (lane mn10300-data4, 2026-11-06)

Lane `mn10300-data4` of wave 12 of the open-items effort.  Its items (`notes/open-items/REGISTER.md`):
N-2468beef, N-dff57eb2 (KN6000), N-6acf011c (KN6500), N-b3924e48 (KN2400), the O-* rows of the MN10300 data
regions, the `make -C kn7000 plugin-src` failure wave 11 left, and the KN6000 / KN6500 24-typed-byte regression.
It continues `../mn10300-data3/README.md` (wave 11).  Probes: `../mn10300-data4-probes/` (README there).

The machinery is `kn7000/tools/gen_data_s.py`, `data_struct_names.py`, `data_structs.py` and `milk_model.py`; each
new rule is a key of `gen_data_s.FEATURES` (off with `GEN_DATA_S_OFF=rule,...`): `named_base_not_end`,
`fx_param_lists`, `string_ptr_runs`.

## 1. What the generator now does

| rule                       | what it does                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | reader evidence                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `fx_param_lists`           | (KN6000 / KN6500, profile key `fx_param_lists`) the effect DSP's parameter lists: the 208-pointer per-DSP-type table in the initialised-RAM image (KN6000 0x500060DC, KN6500 0x50006088, named `FxParamListTable`) leads to a list per type, group n the 13-byte entries {kind, u32 BE op1, u32 BE op2, u16 BE addr, u16 BE addr2} of parameter n, 0xFF after each group and after the list; written `FXL_ENTRY` / `FXL_END` (`src/include/data_tables.inc`), 66 pointed lists and 5 orphans between them, 7,091 bytes an image | KN6000 func_4C155072 0x4C155072: `mov (d0, a0), d1` from the table, then for d1 groups: `movbu (a0), d1` / `cmp 0xff, d1` / `add 0xd, d0` (13-byte steps) and one more byte; a 0xFF where a group starts answers -1.  func_4C155C08 0x4C155C08 reads the kind (0xFF ends), then two u32 and two u16 big-endian (`asl 24` / `asl 16` / `asl 8` / `add`) and calls func_4C157DE2 0x4C157DE2, a switch on the kind (`cmp 0, d0` .. `cmp 0x20, d0`) |
| `string_ptr_runs`          | (the siblings, which do not run the KN7000's `pointer_runs`) aligned runs of words no item holds, each 0 or the address of a printable NUL-ended string, at least 4 of them not 0: the GUI resource name tables' second halves, the font files, the KN2400's per-language message tables [INFERENCE: typed by value]                                                                                                                                                                                                            | GetBitmapNameTable / GetFrameNameTable / GetIconNameTable (KN6000 0x4C02053x..) answer a 256-slot name table; the 256 slots after it hold "music1.bmp", "Round1.bmp", "i0.bmp" ...: the resources' files.  Nothing in the code reads the second halves directly (the reader search's "no address the code holds points into them")                                                                                                              |
| `named_base_not_end`       | `struct_arrays` no longer ends a record run at a record whose pointer field holds no named address when the first record's value there is a named address outside the image (a RAM or bus-window base)                                                                                                                                                                                                                                                                                                                          | func_4C0506C7_entry_L4_Records (KN6500 func_4C050837_...): +0 = 0x50000000 (`WORK_RAM_BASE` since kn6000_aligned.sym), 0x58000000, 0x54000000                                                                                                                                                                                                                                                                                                   |
| `milk_model` (no switch)   | `parse_calls` follows a plug-in's host Function-table record reached by an address sum: `add dN, aM` with the record offset, then `mov (aM), aN` (before the `mov (NAME), rN` rule, which read `(a2)` as a symbol called a2)                                                                                                                                                                                                                                                                                                    | the SP7001 plug-in's func_483E8071 registers its class table (slot 0x2F4) that way: `mov (KssFrameworkObj), d0` / `mov 0x1c, a2` / `add d0, a2` / `mov (a2), a0` / `mov (0xec, a0), a1` / `calls (a1)`                                                                                                                                                                                                                                          |
| `data_structs` (no switch) | a curated field name is not given to a multi-byte field no reader of the build touches (the bytes that cover the named offset keep their offset name)                                                                                                                                                                                                                                                                                                                                                                           | the KN6000's ToneTypeFeature +5 / +20, which only the KN7000's readers read                                                                                                                                                                                                                                                                                                                                                                     |

Field names added (`data_struct_names.py`, N-2468beef), each with its reader cited there:

- `TgVoiceRegImage` (KN6000 func_4C0948CB_ArgA0, KN6500 func_4C094795_ArgA0): the 160-byte voice register image;
  every field is named by the MAIN TG register class the routine writes it to, `tg_<class>` (48 writes,
  `tg_image_regs.py`), +0x7C `pitch_hi` (the 17th pitch bit, class 0x5800).  What each class does is the TG's
  register map, which is not known beyond the EG [rate|level] pairs and the plane 0x20 send matrix
  (kn7000_mame `notes/kn6000-tonegen-spec.md`): the names say where a field goes, not what it means.
- `RamTestRegion` {base, length} and `RamTestByteRegion` {base, length, fail_bit}: the KN6000 / KN6500 RAM test's
  regions (RamTestFunc calls func_4C0506C7 and func_4C050787: 0x5A5A5A5A / 0xA5A5A5A5 over word pairs, 0x5A /
  0xA5 over bytes, +8 / +9 ORed into the answer on a failure).
- `ToneTypeFeature` (TgPartEditLfoLoadA_Records, every tree): one record per tone type, a 19-byte head with the
  four LFO triples the LFO EDIT loaders project onto the part's LFO block (`t<k>_a/_b/_c`, `lfo_p6`, `lfo_p7`)
  and four 5-byte EG segment entries from +0x13 (`seg<k>_flags`, `seg<k>_param`; TgVoiceEgSegParamGet,
  TgPartToneTypeParamGet).  [INFERENCE: what each LFO value is (speed, depth, delay) is not traced]

## 2. The items

| item                                  | outcome                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|---------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| plug-in (`make -C kn7000 plugin-src`) | CLOSED: b1424ca71 (`milk_model.parse_calls`, section 1) + fd2b1906b: `gen_data_s.py --profile sp7001plugin` runs again, all ten RegisterObjectTable calls of func_483E8071 are seen (`plugin_regs.py`: slot 0x2F4 first, class 0x00040004), object 4 of block 0x2F0 has its class; `make -C kn7000 plugin-src` reaches its fixpoint and `verify-sp7001` is 100% byte-identical.  The plug-in's data now carries `gui_object_names.tsv` (311 objects frozen) like every other tree                                                                                                                                                                                                                                                |
| KN6000 / KN6500 24-byte regression    | CLOSED twice over: lane sibling-names2 (merged 0aa9f82f9) no longer names the RAM window bases, and this lane's `named_base_not_end` (ea56cdf17) stops a named address outside the image from ending a record run, so the array stays whole whatever the symbol files name.  After the final merge and regeneration func_4C0506C7_entry_L4_Records / func_4C050837_entry_L4_Records are 3 records (labels.sym: 36 bytes), typed `RamTestRegion` {base, length}.  No other array of any tree changed with the rule                                                                                                                                                                                                                |
| N-2468beef                            | OPEN (L, progress): offset-named fields with a reader (`field_names_census.py`) 941 / 942 203 -> 185, 935 / 893 225 -> 207, KN6000 222 -> 157, KN6500 220 -> 156, KN2400 160 -> 142, HD-SX3 20 -> 20 (section 1's kinds).  The TG register image is named by register class, not by meaning: the KN6000 TG register map below 0x20 is not known (kn7000_mame `notes/kn6000-tonegen-spec.md` section 2: "INCONCLUSIVE without a per-plane live sweep").  Next step: the next kinds of `field_names_census.py --list`: func_4C00206A_Records / func_4C002055_Records (the C library's ctype / locale records of 935 / 893, 15 fields each), func_484288AC_Table (7 per build), func_4841202C_Table_2_p0 (6)                        |
| N-dff57eb2                            | OPEN (L, progress): KN6000 opaque 764 / 16,206 -> 696 / 7,665 bytes (sections 3, 4): the effect-DSP parameter lists are typed (`fx_param_lists`, 7,091 bytes; the stream format was the reader's, func_4C155072 / func_4C155C08: no KN7000 counterpart was needed), and the name tables' file halves (`string_ptr_runs`).  Next: the table-tails (2,697 bytes: the func_4C03CD2C_entry_L9d_Selected_* records' tails, ResourceIdLeaf tails), the false-strings (994) and the ` \x95 ` text cells between labelled strings (192)                                                                                                                                                                                                  |
| N-6acf011c                            | OPEN (L, progress): KN6500 755 / 18,340 -> 687 / 9,791 bytes, the same rules and the same next step as the KN6000 (its false-string group is 2,949 bytes)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| N-b3924e48                            | OPEN (L, progress): KN2400 790 / 16,682 -> 769 / 13,880 bytes: names_48545C20's 1,080-byte "table-tail" is the icon table's file half (241 pointers to "kari.bmp", "i0.bmp" ..., 256 slots after the 256 of the names) and is typed; the per-language message tables (after-string 2,711 -> 1,497).  func_50186924_Selected_6's 856 bytes are left: 44-byte records of DSP coefficients (24-bit values in 32-bit words) the code selects only 7 of, followed by single-precision floats that the doubles pass misreads as doubles (`doubles_4840DE50`).  Next: type that coefficient run from func_50186924's reads of its selected records, and teach `doubles()` to refuse 8-byte runs whose halves are each a plausible float |
| O-* rows                              | section 4 and the table below: every MN10300 row of the siblings and the HD-SX3 moves or holds; the KN7000 builds' rows do not move in this lane (their opaque bytes 9,760 / 9,633 / 10,300 / 9,833 are the base's).  No row reaches 0 in this lane; O-kn2400-unknown-dump-f491a3 rises 2 / 8 -> 3 / 12 and the KN2400's binary program-flash class 461 / 10,264 -> 462 / 10,282: remainders of pieces `string_ptr_runs` split, whose rest now classifies as binary (the KN2400's total falls by 2,802 bytes)                                                                                                                                                                                                                    |

The names lane kn7000-research2 proposed for this lane (`SoundKindGet` = func_48449207, `TableToneKeyMap` =
func_48449462; `../kn7000-research2/README.md`) are rows of the KN7000 symbol files, which this lane does not own:
they are handed back, applied, the next data regeneration renames `func_48449462_Records` / `_Table` once the
labels are sed-renamed in each build's `labels.sym` (the generator keeps a label it made before, and does not
re-derive it from a renamed reader).

The opaque census classes, base e53dc9b3a -> this branch (`../mn10300-data4-probes/opaque_classes_diff.py`; the
O- id is the register's for that tree and class):

| id                           | tree   | class                                    | where                     | pieces / bytes before | pieces / bytes after |
|------------------------------|--------|------------------------------------------|---------------------------|-----------------------|----------------------|
| O-kn6000-unknown-dump-a08889 | kn6000 | 7-bit values                             | the initialised-RAM image | 51 / 108              | 51 / 108             |
| O-kn6000-unknown-dump-71c25d | kn6000 | 7-bit values                             | the program flash         | 43 / 1,253            | 42 / 1,229           |
| O-kn6000-unknown-dump-f491a3 | kn6000 | binary                                   | the initialised-RAM image | 9 / 32                | 9 / 32               |
| O-kn6000-unknown-dump-274483 | kn6000 | binary                                   | the program flash         | 391 / 11,874          | 325 / 4,789          |
| O-kn6000-unknown-dump-1bf2b6 | kn6000 | printable bytes, not NUL-terminated text | the program flash         | 130 / 947             | 130 / 939            |
| O-kn6000-unknown-dump-bfbe48 | kn6000 | words that look like addresses           | the initialised-RAM image | 1 / 52                | 1 / 4                |
| O-kn6000-unknown-dump-b7393d | kn6000 | words that look like addresses           | the program flash         | 139 / 1,940           | 138 / 564            |
|                              | kn6000 | total                                    |                           | 764 / 16,206          | 696 / 7,665          |
| O-kn6500-unknown-dump-a08889 | kn6500 | 7-bit values                             | the initialised-RAM image | 51 / 108              | 51 / 108             |
| O-kn6500-unknown-dump-71c25d | kn6500 | 7-bit values                             | the program flash         | 40 / 1,571            | 39 / 1,547           |
| O-kn6500-unknown-dump-f491a3 | kn6500 | binary                                   | the initialised-RAM image | 8 / 30                | 8 / 30               |
| O-kn6500-unknown-dump-274483 | kn6500 | binary                                   | the program flash         | 388 / 13,687          | 322 / 6,602          |
| O-kn6500-unknown-dump-1bf2b6 | kn6500 | printable bytes, not NUL-terminated text | the program flash         | 142 / 1,003           | 141 / 987            |
| O-kn6500-unknown-dump-bfbe48 | kn6500 | words that look like addresses           | the initialised-RAM image | 1 / 52                | 1 / 4                |
| O-kn6500-unknown-dump-b7393d | kn6500 | words that look like addresses           | the program flash         | 125 / 1,889           | 125 / 513            |
|                              | kn6500 | total                                    |                           | 755 / 18,340          | 687 / 9,791          |
| O-kn2400-unknown-dump-a08889 | kn2400 | 7-bit values                             | the initialised-RAM image | 1 / 4                 | 1 / 4                |
| O-kn2400-unknown-dump-71c25d | kn2400 | 7-bit values                             | the program flash         | 102 / 1,686           | 102 / 1,686          |
| O-kn2400-unknown-dump-f491a3 | kn2400 | binary                                   | the initialised-RAM image | 2 / 8                 | 3 / 12               |
| O-kn2400-unknown-dump-274483 | kn2400 | binary                                   | the program flash         | 461 / 10,264          | 462 / 10,282         |
| O-kn2400-unknown-dump-337026 | kn2400 | printable bytes, not NUL-terminated text | the initialised-RAM image | 2 / 172               | 1 / 124              |
| O-kn2400-unknown-dump-1bf2b6 | kn2400 | printable bytes, not NUL-terminated text | the program flash         | 150 / 2,470           | 131 / 1,480          |
| O-kn2400-unknown-dump-bfbe48 | kn2400 | words that look like addresses           | the initialised-RAM image | 1 / 52                | 1 / 4                |
| O-kn2400-unknown-dump-b7393d | kn2400 | words that look like addresses           | the program flash         | 71 / 2,026            | 68 / 288             |
|                              | kn2400 | total                                    |                           | 790 / 16,682          | 769 / 13,880         |
| O-hdsx3-unknown-dump-71c25d  | hdsx3  | 7-bit values                             | the program flash         | 1 / 8                 | 1 / 8                |
| O-hdsx3-unknown-dump-f491a3  | hdsx3  | binary                                   | the initialised-RAM image | 2 / 8                 | 2 / 8                |
| O-hdsx3-unknown-dump-274483  | hdsx3  | binary                                   | the program flash         | 19 / 102              | 19 / 102             |
| O-hdsx3-unknown-dump-1bf2b6  | hdsx3  | printable bytes, not NUL-terminated text | the program flash         | 3 / 157               | 2 / 150              |
| O-hdsx3-unknown-dump-bfbe48  | hdsx3  | words that look like addresses           | the initialised-RAM image | 3 / 16                | 3 / 16               |
| O-hdsx3-unknown-dump-b7393d  | hdsx3  | words that look like addresses           | the program flash         | 2 / 55                | 1 / 4                |
|                              | hdsx3  | total                                    |                           | 30 / 346              | 28 / 288             |

## 3. Measurements

Before: the base e53dc9b3a's committed data directories (`git archive`); after: this branch's, regenerated
(`../mn10300-data-probes/data_stats.py --dirs BEFORE AFTER --brief`: typed bytes from labels.sym, reader rows,
opaque pieces n / bytes, offset-named fields with a reader, bytes a BEFORE item held that no AFTER item holds):

| tree                           | typed before | typed after | change | reader rows before | reader rows after | opaque before | opaque after | offset-named fields before | after | typed before only |
|--------------------------------|--------------|-------------|--------|--------------------|-------------------|---------------|--------------|----------------------------|-------|-------------------|
| kn7000/src/program/data        | 2,264,713    | 2,264,713   | +0     | 76 / 836           | 76 / 836          | 629 / 9,760   | 629 / 9,760  | 203                        | 185   | 0                 |
| kn7000/src/sp7001/program/data | 2,269,541    | 2,269,541   | +0     | 79 / 944           | 79 / 944          | 634 / 9,633   | 634 / 9,633  | 203                        | 185   | 0                 |
| kn7000/src/b935/program/data   | 2,265,650    | 2,265,650   | +0     | 82 / 980           | 82 / 980          | 647 / 10,300  | 647 / 10,300 | 225                        | 207   | 0                 |
| kn7000/src/b893/program/data   | 2,265,937    | 2,265,937   | +0     | 77 / 848           | 77 / 848          | 636 / 9,833   | 636 / 9,833  | 225                        | 207   | 0                 |
| kn6000/src/program/data        | 2,560,919    | 2,569,446   | +8,527 | 126 / 8,365        | 126 / 8,365       | 764 / 16,206  | 696 / 7,665  | 221                        | 157   | 0                 |
| kn6500/src/program/data        | 2,074,318    | 2,082,853   | +8,535 | 131 / 8,481        | 131 / 8,481       | 755 / 18,340  | 687 / 9,791  | 220                        | 156   | 0                 |
| kn2400/src/program/data        | 1,920,463    | 1,923,193   | +2,730 | 134 / 1,721        | 134 / 1,721       | 790 / 16,682  | 769 / 13,880 | 160                        | 142   | 0                 |
| hdsx3/src/program/data         | 485,452      | 485,507     | +55    | 34 / 211           | 34 / 211          | 30 / 346      | 28 / 288     | 20                         | 20    | 0                 |

The KN7000 builds gain no typed byte (their change is ToneTypeFeature's field names); the field column above is
data_stats.py's count, `field_names_census.py`'s (section 2) counts the KN6000 one field more.

## 4. The opaque groups

`../mn10300-data-probes/opaque_left.py --tree <t>` by group (bytes).  Before: the base e53dc9b3a, which is wave
11's "after" (`../mn10300-data3/README.md` section 4; the ram-other column, not in that table, is its total less the
other groups); after: this branch.

| tree   | false-string   | table-tail     | after-string   | labelled-held  | align-pad  | record-rest | ram-widget-var | ram-other  | euc-text | other      | total            |
|--------|----------------|----------------|----------------|----------------|------------|-------------|----------------|------------|----------|------------|------------------|
| kn6000 | 2,024 -> 994   | 4,089 -> 2,697 | 946 -> 930     | 8,435 -> 2,380 | 288 -> 288 | 0 -> 0      | 128 -> 128     | 64 -> 16   | 0 -> 0   | 232 -> 232 | 16,206 -> 7,665  |
| kn6500 | 3,979 -> 2,949 | 3,904 -> 2,504 | 902 -> 886     | 8,892 -> 2,837 | 297 -> 297 | 0 -> 0      | 128 -> 128     | 62 -> 14   | 0 -> 0   | 176 -> 176 | 18,340 -> 9,791  |
| kn2400 | 1,795 -> 1,795 | 5,419 -> 3,859 | 2,711 -> 1,497 | 6,013 -> 6,013 | 207 -> 207 | 125 -> 125  | 4 -> 4         | 232 -> 140 | 0 -> 64  | 176 -> 176 | 16,682 -> 13,880 |
| hdsx3  | 133 -> 133     | 4 -> 4         | 93 -> 35       | 76 -> 76       | 10 -> 10   | 6 -> 6      | 8 -> 8         | 16 -> 16   | 0 -> 0   | 0 -> 0     | 346 -> 288       |

KN6000 / KN6500: the parameter lists were labelled-held, false-string (their kind and operand bytes read as
text) and table-tail pieces; the name tables' file halves were table-tail.  KN2400: the icon table's file half
(1,016 bytes), the per-language message tables and their strings (after-string); its euc-text 64 bytes are a
remainder of a piece the strings split, classified anew, not new opaque bytes.  What is left, largest first:
the KN2400's labelled-held 6,013 bytes (func_5016594F's switch blocks and the DSP coefficient records around
func_50186924_Selected_6, 44-byte records of 24-bit coefficients in 32-bit words, and the float tables after
them, which the doubles pass misreads as doubles), the KN6000 / KN6500 table-tails (the
func_4C03CD2C_entry_L9d_Selected_* records' tails, ResourceIdLeaf tails) and the ` \x95 ` fixed-width text cells
between labelled strings (192 / 192 / 264 bytes, `0x95` being a glyph the text rules do not accept).

## 5. Regenerating

After the tool commits, in mn10300-data3's order (in a worktree, with the absolute Makefile overrides, `UNIDASM=`,
`SP7001_UPDATES=`, and `baserom/kn7000_table_b80.rom` for the 893 code generation):

1. `make -C kn7000 verify verify-sp7001 verify-935 verify-893` (the labels the KN7000 generation reads);
2. `make -C kn2400 data-and-code-src`, the same for `kn6000` and `kn6500` (in parallel), then `hdsx3`, then
   `make -C <each> gui-map`;
3. `make -C kn7000 data-and-code-src`, `make -C kn7000 plugin-src` (now runs: section 2), `make -C kn7000 gui-map`;
4. `python3 -I floppy/tools/kd/gen_panel_macros.py` (unchanged by this lane).

All fixpoints came after 2 rounds.  The siblings' program sources change only where the code names the renamed
table (`mov FxParamListTable, a0`, KN6000 / KN6500); the GUI maps do not change.

## Website page draft

(For the KN6000 / KN6500, KN2400 and KN7000 program-data pages of technics-docs; a new paragraph after the
effect-DSP section where the page has one.)

> **The effect DSP's parameter lists (SX-KN6000 / KN6500).**  For each of its 208 DSP effect types the firmware
> keeps a list that says what a parameter does to the effect DSP: for parameter n, a group of 13-byte entries,
> each a converter kind, two 32-bit operands and one or two 16-bit DSP addresses (0xC0xx for most), the group
> ended by 0xFF and the list by one more.  When a parameter changes, the firmware finds its group and runs
> every entry through the converter its kind selects, with the parameter's value.  The 66 lists the types point
> at (and five older copies between them) take 7,091 bytes of each image.  The GUI's resource name tables are
> 512 slots: 256 names, then the 256 file names of the same resources ("music1.bmp", "i0.bmp"); the second half
> is now typed as such.  The KN6000's per-voice tone-generator register image (160 bytes) is written to the TG
> one register class at a time, and its fields are named by those classes; the meaning of most classes is not
> known yet.
