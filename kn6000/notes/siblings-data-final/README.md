# The siblings' data regions, final pass: the reader-typed passes on the MN10300 siblings

Lane siblings-final of the data-semantics effort (`notes/data-semantics-2026-10-29/README.md` at the
repository root), 2026-10-30. It covers the four MILK images that share `kn7000/tools/`:

- SX-KN6000 v7.1 (`kn6000/`)
- SX-KN6500 v1.3 (`kn6500/`)
- SX-KN2400 / KN2600 v1.1 (`kn2400/`)
- the HD-SX3 (HD-SX6) XAPR plug-in (`hdsx3/`)

Before this lane those profiles of `gen_data_s.py` ran the older pass order. The KN7000 profiles'
reader-typed passes (lane kn7000-data-rest, `kn7000/notes/data-rest/README.md`) were off for them:
struct arrays from their readers, pointed records, DSP download records, drawn bitmaps, message
tables, fixed-address variables and the opaque declarations with their reader search. They are now on
for all four, and five new kinds of structure are typed from their firmware readers. The probes are in
`../siblings-data-final-probes/` (README there).

## Census

`scripts/analysis/data_incbin_census.py` (count / bytes). "Before" is the lane's base, fd73a97fa;
"after" is this branch.

CENSUS_TABLE

`kn7000/notes/gui-data-region-probes/gap_kinds.py` (the generic pieces only, not the opaque ones; the
third argument is the link base, added by this lane):

GAPS_TABLE

`kn7000/tools/gui_readability.py`:

READ_TABLE

## What makes the passes run on a sibling (tool changes, all in `kn7000/tools/`)

| change                                                                                          | where                                    |
|-------------------------------------------------------------------------------------------------|------------------------------------------|
| `structs=True` (and `string_arrays` on the KN6000 / KN6500) in the four sibling profiles         | `gen_data_s.py` PROFILES                 |
| the code-label map is built from every label file; the siblings' are `.equ` includes             | `gen_data_s.py` `_load_names`, `data_structs.readers` |
| `dsp_pool` reads kn7000's 941 image, `dsp/records.tsv` and listings whichever profile runs       | `gen_data_s.py` `dsp_pool`               |
| the DSP-record include and the drawn bitmaps' `.incbin` paths go through the shared tree         | `gen_data_s.py` `emit`, `drawn_bitmaps`  |
| the `structs` path of `bitmaps()` also takes the plug-in compiler's `cmp / bne / bra` answers    | `gen_data_s.py` `bitmaps` (HD-SX3's three 640 x 240 pictures had been lost) |
| a sibling's `<function>_L<hex>` labels are local labels of the walk, not new functions           | `data_readers.py` `LOCAL`, `SIB_LOCAL`   |
| parameter accesses resolved semi-naively, each kept once (the pairwise version ran out of 29 GB on the KN2400) | `data_readers.py` `resolve_params_distinct` |
| a function whose `ret` leaves the same record address in a0 (or one of a few) gives it to its callers | `data_readers.py` `rets`, `ret_val`, the `U` value |
| sibling citations list an array's own loads before accesses carried in through parameters        | `data_structs.py` `PREFER_DIRECT`        |
| per-model record names, and pointer fields the walk cannot follow                               | `data_struct_names.py` `MODEL_NAMES`, `MODEL_POINTED` |
| new passes `style_panels`, `hash_tables`, `pads`; `panel_banks` on the KN6500                    | `gen_data_s.py`                          |
| `technics_pads(..., inline=True)` writes a program copy's pads inline                            | `gen_table_styles.py`                    |

Every one is gated on the sibling profiles (a profile with a `root`, or a profile key): KN7000 programs
941 / 935 / 893 / SP7001 regenerate to the same data source (checked), and `make -C kn7000 verify
verify-sp7001 verify-935 verify-893 verify-gui-map symbols-check` passes.

Shared includes: `kn7000/src/include/panel_memory.inc` gains `PM_RHYTHM`;
`kn7000/src/include/data_tables.inc` gains `hash_desc`, `hash_ent32`, `hash_ent16`. Nothing existing
changed.

## What is newly typed, and the evidence

### The Music Stylist setups and their one-touch settings (KN6000, KN6500, KN2400)

`StyleRecordTable` is the KN7000's 24-byte `MusicStylistSetup` record, field for field, on all three:

- KN6000: 1,000 records at 0x4C3DF8EC
- KN6500: 1,080 records at 0x4C36F724
- KN2400: 720 records at 0x48571564, and `StyleRecordTableAlt`, 680 records at 0x48577738

The KN2400's `func_48641CCD` returns `&StyleRecordTableAlt[i]` when `func_487055C4` answers 1, and
`&StyleRecordTable[i]` otherwise. `func_487055C4` reads bits 0 and 1 of 0x98070000. [INFERENCE] The two
lists are the KN2400's and the KN2600's; both point at the same one-touch settings.

The field readers (KN6000 v7.1):

| field        | reader                                                                       |
|--------------|------------------------------------------------------------------------------|
| `+0 panel`   | func_4C16B6B5_entry_L43 loads it and calls func_4C04C476, which hands it to func_4C04C58C |
| `+4 name`    | MssNameFunc_L121 0x4C1637F8, strncpy 16                                      |
| `+8 genre`   | func_4C1640C8: StyleGenreTable + genre * 8                                   |
| `+10 style`  | func_4C1640C8: the genre's style list + style * 8                            |
| `+12 setup`  | func_4C1649B6, func_4C164AAC                                                 |
| `+14 era`    | func_4C165A19 `cmp 0xffff, d1`                                               |
| `+16 era_pos`| func_4C16619A: LibDiv32 by 9, page and row                                   |
| `+18 letter` | func_4C164F3F: StyleAlphabetTable + letter * 8                               |
| `+20 letter_pos` | func_4C164F3F, func_4C1655C7                                             |

The KN2400's readers for the same offsets are listed in `data_struct_names.py`. `StyleGenreTable`,
`StyleEraTable` and `StyleAlphabetTable` are named on the KN6000 and KN6500 too.

The `panel` record is the one-touch-setting record that the CUSTOM banks also hold
(`kn7000/src/include/panel_memory.inc`, `kn6000/src/customdata/01ctmini/Slot*.inc`):

- KN6000 and KN6500: 0x90 bytes. `func_4C04C552` (KN6500 `func_4C04C6C2`) answers 0x90. func_4C04C58C
  merges the record into 0x84000036.. through the same triple tables (`func_4C04B9F8_entry_L4f_Table`)
  that the CUSTOM writer func_4C04B9F8 uses.
- KN2400: 0xA0 bytes, the KN7000 layout with `PM_PART_TAIL` x 4.

`gen_data_s.py style_panels()` types each record as `PM_PART` x 3, `PM_ENTRIES`, `PM_PART`, `PM_RHYTHM`,
`PM_SET77`, `PM_FX`, `PM_SET88`, `PM_SET8C`. The label is `StylePanel_<setup name>_<n>`. `PM_RHYTHM` is
the new macro. Where a CUSTOM setting has its slot, a built-in has the 24-bit rhythm id, low byte first:
+0x72 is 0 in all 2,800 records. The tempo is stored as 9 bits.

The counts: KN6000 999 records (143,856 bytes, the "part-like" 144 KB the sib-kn6000 lane left), KN6500
1,080, KN2400 719 of 720. The one KN2400 record left out does not fit the masks.

### The note-conversion rules and their tables (KN6000, KN6500)

`NoteConvRules` (KN6000 0x4C3850BC, KN6500 0x4C3108F8) is 128 x 8 bytes:
`{is_melody, alt_chord, no_third_adj, no_transpose, table}`. Its reader, func_4C05805C, is the KN7000's
func_48436229 instruction for instruction:

- func_4C05800B, func_4C058026 and func_4C058041 answer +1, +2 and +3;
- func_4C05805C_entry_L13 0x4C058074 loads +4 into d2;
- at L12e / L179 it adds 4 + (type - 1) * 12, or 4 + (type - 1) * 0x90 + (root - 1) * 12, then
  note % 12, and does `movbu (d0, a0)` followed by `extb`.

The walk loses d2 across the labels, so `data_struct_names.MODEL_POINTED` states that read. The tables
are then the KN7000's `NoteConvTable` {name; s8 deltas}, with 492-byte melody and 4,900-byte chord
tables: KN6000 21 tables, about 50 KB (the "chord tables" of the sib-kn6000 notes).

### The built-in sound hash tables (KN6000)

The KN6000 v7.1 holds three multiplicative hash tables of the 'JK' voice archive's shape
(`kn7000/notes/table-semantics-2026-10-29.md`), with absolute pointers. Each is a `{u16 mult, u16
nbuckets}` descriptor, then the buckets, then chains of entries `{u32 next, key, payload}`. The readers
are used when no archive is loaded, that is when `func_4C07B982` answers neither 1 nor 2. Each takes
`key * mult % nbuckets` (func_4C09B1EC: `mulu`, `divu`, mdr), walks the chain comparing +4 and answers
the payload:

| table          | descriptor   | buckets | entries x size | key                                   | reader        |
|----------------|--------------|---------|----------------|---------------------------------------|---------------|
| `ToneKeyHash`  | 0x4C3E8680   | 1,139   | 1,896 x 20     | MSB << 16 \| LSB << 8 \| program (func_4C09ACF3) | func_4C09B08C |
| `ShortKeyHash` | 0x4C3E9850   | 1,907   | 2,898 x 12     | u16, byte << 8 \| byte (func_4C09B200) | func_4C09B2AE |
| `BankKeyHash`  | 0x4C3EC6A0   | 1,139   | 1,375 x 12     | MSB << 16 \| LSB << 8 \| program (func_4C09BCFA) | func_4C09BDB2 |

`hash_chains.py` checks every key against its bucket (0 misplaced). These 89,196 bytes were the sib-kn6000
lane's "past the tone directory" 0x311244..0x326EEC. The payloads are byte rows. [INFERENCE] ToneKeyHash's
first u16 is a tone-record index, as in the KN7000's 'Tone' hash; the code was not traced past the
lookup.

### The factory panel memories (KN6500)

The sib-kn6000 notes said the KN6500's program flash has no panel banks. It has them: `func_4C03D5A1`
copies `func_4C03D5A1_Table` (the .PMT header) and then 0x2D8D0 bytes from 0x4C2B7668 to the backup RAM
0x840007C2 / 0x840007D2. This is the KN6000's func_4C03D431 with the same size. `FactoryPanelMemory`
(kn6500_manual.sym) now has `panel_banks()` type its 13 banks x 8 memories, 186,576 bytes: the
"Soloist Sounds", "PAd", "PZA" ... runs.

### The built-in "Technics Pads" bank (KN6000, KN6500, KN2400)

`TechnicsPadsResourceInit` stores the program's own copy and calls `TechnicsPadsResourceParse` when the
table flash's copy does not check. That copy is `TechnicsPadsResource`, at:

- KN6000 0x4C35FF84
- KN6500 0x4C2EB7C8
- KN2400 0x48532260

It is the table flash's segment 4 format. `gen_table_styles.technics_pads(inline=True)` types it: the
header, the pad-ID index, the pad table, and six pads with their events one per line. KN6000 pad 3 has 15
beat markers for 4 x 4 beats, so the beat count is not checked for these copies; the event grammar is.

## What is still generic or opaque

GENERIC_LIST

## Open questions

- [INFERENCE] The KN2400's two setup lists by model (the 0x98070000 bits).
- The hash tables' payloads past their first field, and ShortKeyHash's key.
- The KN2400's effect-program blocks: 0x4853C5BE.., 20 KB, and 0x48537CDC.. (`7c aa aa 7d 55 55 ...`).
  Opaque, with no reader seen; their format is not the KN7000's SHARC download records.
- The one-touch bytes the macros keep as hex (PM_PART fields are named in panel_memory.inc).

## Website page draft

(For the `kn6000-program-data.md` and `kn2400-kn2600` pages in technics-docs, to be added by the website
sync.)

> **What the SX-KN6000 / KN6500 / KN2400 program data is, from the code that reads it.** Besides the GUI,
> the program flash carries the built-in Music Stylist (1,000 / 1,080 / 720 setups, each pointing at a
> one-touch setting written with the same macros as a CUSTOM bank's), the note-conversion tables of the
> accompaniment, the factory panel memories (KN6000 and KN6500), a fallback "Technics Pads" bank, and on
> the KN6000 the built-in sound tables: tone and voice records plus three hash tables keyed by the MIDI
> bank and program. The disassembly writes each as typed records whose comments name the routine that
> reads every field.
