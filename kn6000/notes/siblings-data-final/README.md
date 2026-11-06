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

| tree   | before generic  | generated     | media      | opaque          | generic n | generic bytes |
|--------|-----------------|---------------|------------|-----------------|-----------|---------------|
| kn6000 | 6,072 / 797,489 | 80 / 137,020  | 3 / 28,660 | 3,336 / 79,522  | 380       | 18,810        |
| kn6500 | 5,427 / 901,823 | 83 / 137,404  | 3 / 28,660 | 3,346 / 83,667  | 386       | 18,930        |
| kn2400 | 5,646 / 590,773 | 127 / 134,756 | 5 / 43,175 | 5,048 / 197,205 | 431       | 18,853        |
| hdsx3  | 414 / 6,623     | 3 / 309,200   | 0 / 0      | 101 / 3,133     | 40        | 266           |

`kn7000/notes/gui-data-region-probes/gap_kinds.py` (the generic pieces only, not the opaque ones; the
third argument is the link base, added by this lane):

| tree   | pieces before | bytes before | other             | pointer-like  | 7-bit         | text-like     | tails      | pieces after | bytes after |
|--------|---------------|--------------|-------------------|---------------|---------------|---------------|------------|--------------|-------------|
| kn6000 | 6,070         | 796,788      | 625,527 -> 16,796 | 80,010 -> 848 | 23,749 -> 402 | 65,164 -> 55  | 2,338 -> 8 | 378          | 18,109      |
| kn6500 | 5,425         | 901,122      | 748,825 -> 16,948 | 75,180 -> 788 | 20,736 -> 362 | 54,096 -> 123 | 2,285 -> 8 | 384          | 18,229      |
| kn2400 | 5,646         | 590,773      | 449,840 -> 17,494 | 57,073 -> 680 | 25,792 -> 520 | 56,369 -> 155 | 1,699 -> 4 | 431          | 18,853      |
| hdsx3  | 414           | 6,623        | 5,477 -> 196      | 399 -> 0      | 363 -> 70     | 250 -> 0      | 134 -> 0   | 40           | 266         |

`kn7000/tools/gui_readability.py`:

| tree          | records typed | records in blobs | raw ids | numeric links | numeric addresses | code -> data nums | unnamed fields |
|---------------|---------------|------------------|---------|---------------|-------------------|-------------------|----------------|
| before kn6000 | 7145          | 0                | 0       | 0             | 4                 | 6                 | 0              |
| before kn6500 | 7203          | 0                | 0       | 0             | 1                 | 2                 | 0              |
| before kn2400 | 7322          | 0                | 3       | 0             | 3                 | 2                 | 0              |
| before hdsx3  | 999           | 0                | 0       | 0             | 3                 | 1                 | 0              |
| after kn6000  | 7145          | 0                | 0       | 0             | 149               | 75                | 0              |
| after kn6500  | 7203          | 0                | 0       | 0             | 152               | 72                | 0              |
| after kn2400  | 7322          | 0                | 3       | 0             | 180               | 9                 | 0              |
| after hdsx3   | 999           | 0                | 0       | 0             | 34                | 1                 | 0              |

The GUI columns are unchanged. The numeric-address rise is in non-GUI lines that are now typed:

- 131 of the KN6000's 149 (150 of the KN2400's 180) are the low words of IEEE doubles in the
  double tables (`.long 0x48551854, 0x3F250783  # -3.59884302e-06`), which the counter's
  `0x48......` / `0x4C......` pattern also matches.
- The rest are u32 fields of reader-typed records holding values that are not addresses of anything
  named: the KN6000's `REC_func_4C02CA6A_Records_p0` f0, and `0x50000000` RAM bases.
- "code -> data nums" counts immediates in the converted code. With the new labels some of them
  fall inside typed items, for example `mov 0x4c32be24, a1` in func_4C03D431, which
  `gen_image_s.py` leaves as a number.

The base column is the main checkout at fd73a97fa, measured with `--root`.

## What makes the passes run on a sibling (tool changes, all in `kn7000/tools/`)

| change                                                                                                                                                   | where                                                                       |
|----------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------|
| `structs=True` (and `string_arrays` on the KN6000 / KN6500) in the four sibling profiles                                                                 | `gen_data_s.py` PROFILES                                                    |
| the code-label map is built from every label file; the siblings' are `.equ` includes                                                                     | `gen_data_s.py` `_load_names`, `data_structs.readers`                       |
| `dsp_pool` reads kn7000's 941 image, `dsp/records.tsv` and listings whichever profile runs                                                               | `gen_data_s.py` `dsp_pool`                                                  |
| the DSP-record include and the drawn bitmaps' `.incbin` paths go through the shared tree                                                                 | `gen_data_s.py` `emit`, `drawn_bitmaps`                                     |
| the `structs` path of `bitmaps()` also takes the plug-in compiler's `cmp / bne / bra` answers                                                            | `gen_data_s.py` `bitmaps` (HD-SX3's three 640 x 240 pictures had been lost) |
| a sibling's `<function>_L<hex>` labels are local labels of the walk, not new functions                                                                   | `data_readers.py` `LOCAL`, `SIB_LOCAL`                                      |
| parameter accesses resolved semi-naively, each kept once (the pairwise version ran out of 29 GB on the KN2400)                                           | `data_readers.py` `resolve_params_distinct`                                 |
| a function whose `ret` leaves the same record address in a0 (or one of a few) gives it to its callers                                                    | `data_readers.py` `rets`, `ret_val`, the `U` value                          |
| the KN2400's code is after its data: `code_cpu` states its ranges (flash and RAM-linked), so its dispatch tables' code pointers are spelled `loc_<ADDR>` | `gen_data_s.py` `in_code`                                                   |
| a gap that is plainly text with no NUL, or words that are each 0 or a named address, is `.ascii` / `.long` rows, with the reader search in a comment     | `gen_data_s.py` `typed_gap`                                                 |
| sibling citations list an array's own loads before accesses carried in through parameters                                                                | `data_structs.py` `PREFER_DIRECT`                                           |
| per-model record names, and pointer fields the walk cannot follow                                                                                        | `data_struct_names.py` `MODEL_NAMES`, `MODEL_POINTED`                       |
| new passes `style_panels`, `hash_tables`, `pads`; `panel_banks` on the KN6500                                                                            | `gen_data_s.py`                                                             |
| `technics_pads(..., inline=True)` writes a program copy's pads inline                                                                                    | `gen_table_styles.py`                                                       |

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
- KN2400: 720 records at 0x48571564, and `StyleRecordTableAlt` (since 2026-10-31 `StyleRecordTableKN2400`), 680 records at 0x48577738

The KN2400's `func_48641CCD` returns `&StyleRecordTableAlt[i]` when `func_487055C4` answers 1, and
`&StyleRecordTable[i]` otherwise. `func_487055C4` reads bits 0 and 1 of 0x98070000. [INFERENCE] The two
lists are the KN2400's and the KN2600's; both point at the same one-touch settings. (Confirmed 2026-10-31,
lane mn10300-formats: `func_487055C4` is `KnprModelGet`, 1 = KN2400; `func_48641CCD` is `MssSetupGet`.)

The field readers (KN6000 v7.1):

| field            | reader                                                                                    |
|------------------|-------------------------------------------------------------------------------------------|
| `+0 panel`       | func_4C16B6B5_entry_L43 loads it and calls func_4C04C476, which hands it to func_4C04C58C |
| `+4 name`        | MssNameFunc_L121 0x4C1637F8, strncpy 16                                                   |
| `+8 genre`       | func_4C1640C8: StyleGenreTable + genre * 8                                                |
| `+10 style`      | func_4C1640C8: the genre's style list + style * 8                                         |
| `+12 setup`      | func_4C1649B6, func_4C164AAC                                                              |
| `+14 era`        | func_4C165A19 `cmp 0xffff, d1`                                                            |
| `+16 era_pos`    | func_4C16619A: LibDiv32 by 9, page and row                                                |
| `+18 letter`     | func_4C164F3F: StyleAlphabetTable + letter * 8                                            |
| `+20 letter_pos` | func_4C164F3F, func_4C1655C7                                                              |

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

### The note-conversion rules and their tables (KN6000, KN6500, KN2400)

`NoteConvRules` (KN6000 0x4C3850BC, KN6500 0x4C3108F8) is 128 x 8 bytes:
`{is_melody, alt_chord, no_third_adj, no_transpose, table}`. Its reader, func_4C05805C, is the KN7000's
func_48436229 instruction for instruction:

- func_4C05800B, func_4C058026 and func_4C058041 answer +1, +2 and +3;
- func_4C05805C_entry_L13 0x4C058074 loads +4 into d2;
- at L12e / L179 it adds 4 + (type - 1) * 12, or 4 + (type - 1) * 0x90 + (root - 1) * 12, then
  note % 12, and does `movbu (d0, a0)` followed by `extb`.

The walk loses d2 across the labels, so `data_struct_names.MODEL_POINTED` states that read. The KN2400's
copy (0x4854B24C) is read by func_50173F49 in its RAM-linked code, which the walk follows: +4 is loaded at
L13 0x50173F61 and read at L170 / L1b5. The answers for +1 / +2 / +3 come from func_50173EF8,
func_50173F13 and func_50173F2E. The tables
are then the KN7000's `NoteConvTable` {name; s8 deltas}, with 492-byte melody and 4,900-byte chord
tables: KN6000 21 tables, about 50 KB (the "chord tables" of the sib-kn6000 notes).

### The built-in sound hash tables (KN6000)

The KN6000 v7.1 holds three multiplicative hash tables of the 'JK' voice archive's shape
(`kn7000/notes/table-semantics-2026-10-29.md`), with absolute pointers. Each is a `{u16 mult, u16
nbuckets}` descriptor, then the buckets, then chains of entries `{u32 next, key, payload}`. The readers
are used when no archive is loaded, that is when `func_4C07B982` answers neither 1 nor 2. Each takes
`key * mult % nbuckets` (func_4C09B1EC: `mulu`, `divu`, mdr), walks the chain comparing +4 and answers
the payload:

| table          | descriptor | buckets | entries x size | key              | reader               |                         |               |
|----------------|------------|---------|----------------|------------------|----------------------|-------------------------|---------------|
| `ToneKeyHash`  | 0x4C3E8680 | 1,139   | 1,896 x 20     | MSB << 16 \      | LSB << 8 \           | program (func_4C09ACF3) | func_4C09B08C |
| `ShortKeyHash` | 0x4C3E9850 | 1,907   | 2,898 x 12     | u16, byte << 8 \ | byte (func_4C09B200) | func_4C09B2AE           |               |
| `BankKeyHash`  | 0x4C3EC6A0 | 1,139   | 1,375 x 12     | MSB << 16 \      | LSB << 8 \           | program (func_4C09BCFA) | func_4C09BDB2 |

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

(Superseded for the generic pieces by "generic-zero" below, 2026-10-30: none is generic any more; the
opaque table stays as it was measured.)

The census leaves 18,810 / 18,930 / 18,853 / 266 bytes generic. Each such piece is **read** by
some instruction (the reader search finds a load, store, base or argument in it) but no pass turned it
into a type. The largest runs (`untyped_regions.py <model> --kind generic`):

| model  | run                                                    | bytes  | what is known                                                                                                                |
|--------|--------------------------------------------------------|--------|------------------------------------------------------------------------------------------------------------------------------|
| kn6000 | 0x4C1A04AC..0x4C1A1903                                 | 5,207  | binary after a word table; read through `data_4C1A04AC` (not traced)                                                         |
| kn6000 | 0x4C1A1909..0x4C1A22F0                                 | 2,535  | `10 95 48 76 61 00 10 32 97 36 ...`: 4-byte groups, read (not traced)                                                        |
| kn6000 | 0x4C194EF2.., 0x4C196957.., 0x4C197436..               | ~4,000 | records with `7f 00 .. f0 ..` and pointers into themselves, between strings: [INFERENCE] effect parameter tables; not traced |
| kn6500 | the same three at 0x4C1A0E5C, 0x4C1A22B9, 0x4C19590E.. | ~9,000 | as on the KN6000                                                                                                             |
| kn2400 | 0x4840B3D4.., 0x48409F34.., 0x4840D9C4..               | ~8,500 | [INFERENCE] parameter / colour tables of the data's first 64 KB (`cc cc 4c 00` colour runs)                                  |
| hdsx3  | 0x978A2C1E.. (82), 0x978A2BFC.. (24)                   | 106    | [INFERENCE] u16 coordinate rows (x, y, w, h) beside the file-browser strings                                                 |

Declared opaque: 79,522 / 83,667 / 197,205 / 3,133 bytes. Every one has the generator's marker:
`census: opaque -- unknown-dump: <n> bytes of <what> in <where>; no instruction reads them
(tools/data_readers.py: no load, store, base or call argument in them)`, followed by whether a typed
pointer still holds their address. That is the reader search the rulings ask for. The walk has limits:
a pointer computed in a way it does not follow is not seen. The biggest:

| model          | run                                                                                      | bytes   | what it is, as far as known                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
|----------------|------------------------------------------------------------------------------------------|---------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| kn2400         | 0x4853C5BE..0x48541488                                                                   | 20,065  | `7c aa aa 7d 55 55 7e aa aa 7f ...` command streams, with names (`Str_yUUz_UU_*`) and more at 0x48537CDC.. (5,101), 0x48539DD5.. (4,373): [INFERENCE] effect-DSP programs. Data tables point into them (0x48464AD4 -> 0x48540059), but nothing is read through those pointers. The format is not the KN7000's SHARC download record. Resolved (lane mn10300-rest): the effect DSP's programs, scripts and maps, 0x48533EAC..0x48541618, read through FxTypeProgramTable / FxTypeScriptTable / FxTypeMapTable (0x48464AD4 is text, not a pointer) |
| kn2400         | 0x48430000..0x4843FFFF                                                                   | 44,299  | 1,089 small pieces between effect names (`Str_DELAY_1`, `Str_SPEED_FAST`, `Str_FEEDBACK_R_12`): effect parameter records nothing reads directly                                                                                                                                                                                                                                                                                                                                                                                                  |
| kn2400         | 0x4853AF63..0x4853C5AA                                                                   | 5,703   | high-entropy bytes after `Str_My_Ml_M`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| kn6000, kn6500 | 0x4C398C2B.. / 0x4C3244AF..                                                              | 3,927   | records `03 00 00 00 00 00 00 00 f0 c0 05 ff ff ff 04 ...`                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| kn6000, kn6500 | `data_4C3855C0_p0_p36_0` / `data_4C310DFC_p0_p36_0`                                      | 3,888   | the tail of a pointed record kind: small 0..13 values (chord step lists?)                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| kn6000, kn6500 | `func_4C02CA6A_Records_p0_69` / `func_4C02CBDA_Records_p0_69` ..                         | 3,676 + | `{0, pointer}` word pairs whose pointers lead into gaps (no symbol), so typed_gap could not spell them                                                                                                                                                                                                                                                                                                                                                                                                                                           |
| all four       | 1,525 bytes (KN6000 0x4C327307, KN6500 0x4C2B2B1F, KN2400 0x48528C8B, HD-SX3 0x978B014B) | 1,525   | high entropy (7.8 bits a byte), followed by the JPEG zig-zag order `00 01 08 10 09 02 03 0a 11 18 ...`: [INFERENCE] the JPEG decoder library's constant tables; no zlib stream starts in it. Corrected (lane mn10300-rest): the tail of the C library's powers of ten, 309 doubles 1e0..1e308 that PfDoubleToDecimal reads (`Pow10Table`)                                                                                                                                                                                                        |
| kn6500, kn2400 | 0x4C236048.. / 0x484FE008..                                                              | 5,147   | `03 37 3c 40 ff ff ff ff 03 38 3d 41 ...`: 8-byte rows of a count and up to 4 notes [INFERENCE: chord voicings]                                                                                                                                                                                                                                                                                                                                                                                                                                  |

The rest is thousands of pieces under 256 bytes, mostly in the initialised-RAM images (variables that
no instruction names) and between the effect and parameter names.

## generic-zero (lane generic-zero, 2026-10-30)

Every generic piece the table above lists had a reader, so by the owner's rule none may stay a generic
`.incbin_range` (and none may be declared opaque).  `kn7000/tools/gen_data_s.py`'s new last fallback,
`reader_rows()` (profile key `reader_rows`, on for the four siblings and the KN7000 builds; described in
`kn7000/notes/data-final/README.md`, "generic-zero"), writes each such piece as rows at the width and
signedness of the reads that land in it, its address words as `.long Label` / `Label+N`, with a header naming
the readers.  `record_start()` stops typed_refs() from taking a record that the walk reads past its first bytes
for a short string: on the KN6000 / KN6500 the `func_4C02CA6A_Records_p0` / `func_4C02CBDA_Records_p0` records (`Str_empty_918`,
`Str_P_19`, ... before), on the KN2400 the `func_5014A95C_Records_p0` ones (`Str_empty_1261`, `Str_4_33` ...).

What the pieces became (`kn7000/notes/data-final-probes/reader_rows_stats.py`):

| tree   | read at a width (n / bytes) | address only taken (n / bytes) | strings (n) | total n | total bytes |
|--------|-----------------------------|--------------------------------|-------------|---------|-------------|
| kn6000 | 5 / 129                     | 339 / 17,838                   | 34          | 378     | 18,109      |
| kn6500 | 5 / 129                     | 345 / 17,958                   | 34          | 384     | 18,229      |
| kn2400 | 3 / 109                     | 380 / 18,475                   | 48          | 431     | 18,853      |
| hdsx3  | 0 / 0                       | 30 / 228                       | 10          | 40      | 266         |

Most are "address only taken": the code loads the piece's address into a register or passes it to a
routine, and the walk does not follow the reads the callee makes.  Examples:

- KN2400 0x48409720.. (`data_48409720`, `data_48409740`, ... 32 bytes each): the KN7000's 260-way switch
  descriptors, `{u32, u16, u16, pointer, u16 ...}` followed by the SysEx the pointer names (`F0 7F 7F 04 ..
  F7`, `F0 50 2C 20 32 1F ..`): u8 rows with `.long data_48409720+20` ([INFERENCE] by the KN7000's
  `REC_func_484C01F1_Result`; the KN2400's code reaches them as `mov data_X, d0`, which the walk does not
  carry into the reader);
- the 16-colour table of VwUserBitmapProc (`data_4C176EA8`, u32 0x00BBGGRR rows), the empty strings handed to
  strcpy (`.asciz ""`), the "\r" handed to strcspn;
- HD-SX3's coordinate words (0x500014 = x 0x14, y 0x50) passed to the host's drawing routines through `calls (a2)`.

The KN6000 / KN6500 code file had two `.incbin_range`s outside every range (115 + 586 bytes).  They are
typed by the Makefile's `TYPED` (`gen_image_s.py --fill / --rows / --text / --long-table`, `--rows` new) and
named in `<model>_manual.sym`, each with the code that reads it:

| name                                           | KN6000                 | KN6500                 | what it is, and its reader                                                                                                 |
|------------------------------------------------|------------------------|------------------------|----------------------------------------------------------------------------------------------------------------------------|
| `FirmwareVersionByte`                          | 0x4C00000F             | 0x4C00000F             | the boot header's last byte, 0x71 / 0x13 (v7.1 / v1.3; the KN2400 v1.1's is 0x11): func_4C07B3D7 / func_4C07B56B answer it |
| `Str_MILK_MN10300_Ver1_0R1`                    | 0x4C3F77E8             | 0x4C381448             | the kernel's version string                                                                                                |
| `KernelServiceHash`                            | 0x4C3F7800             | 0x4C381460             | 16 x {u32 key, handler}: func_4C3F7632 / func_4C381292 probe it by (key & 0xF) * 8 and `jmp` through +4                    |
| `KernelRamLayout`                              | 0x4C3F7880             | 0x4C3814E0             | 6 RAM addresses: func_4C3F61BB, func_4C3F61F7, func_4C3F62A4, func_4C3F7793 (KN6000 names) read +4 .. +0x14                |
| `KernelParams`                                 | 0x4C3F7898             | 0x4C3814F8             | 14 u16: get_tid (+0), func_4C3F47EC (+0x10, +0x12), func_4C3F4A69 (+0x16)                                                  |
| `KernelStartStub`                              | 0x4C3F78B4             | 0x4C381514             | code: `jmp func_4C3F7793`, the routine crt0_start's func_4C000350 ends by jumping to                                       |
| `KernelGroup0IntDispatch`, `KernelIntDispatch` | 0x4C3F78BC, 0x4C3F7942 | 0x4C38151C, 0x4C3815A2 | code: the kernel's interrupt dispatchers; func_4C000350 writes a `jmp KernelIntDispatch` at 0x90000000                     |

Those two dispatchers were outside the code ranges because nothing but that written `jmp` reaches them: they
are a code range now (`--code 0x3f78b4:0x3f7a31` / `0x381514:0x381691`), decoded; the five `movm` with the
`other3` register group (save and restore) stay `.byte` escapes with the disassembly beside them (the
encoder does not spell that group), and the twelve `udf` instructions (the MN103002A's extension unit) are
instructions.  [INFERENCE] on what the hash keys, the RAM words and the u16 parameters mean.

Readability counters (`scripts/analysis/doc_quality_census.py --compare docs/coverage/doc-quality-2026-10-30-01.json`)
rise on the KN6000 and KN6500 for one reason, the kernel tail made code and the hash table typed:

- routines without a header +12 / +12 and placeholder names +13 / +13: `--long-table` makes each code
  pointer of `KernelServiceHash` an entry, so the twelve service handlers func_4C3F7632 jumps to (KN6000
  func_4C3F7693 .. func_4C3F7756; they were `func_4C3F7632_entry_L11f` ... before) are routines now, and
  the return path the tasks `jmp` to is func_4C3F7A07;
- `.byte` runs +3 / +1 (8 bytes): the `movm` with the `other3` group in the two dispatchers;
- numeric operands elsewhere +15: the dispatchers' RAM and interrupt-controller addresses (0x50180CCC,
  0x34000100, ...).

Against them: numeric branch targets 28 -> 0 (`jmp 0x4c3f7a07`), numeric operands in the image 19 -> 1.

The same naming of typed ranges shows the KN2400's `RamCodeTrailer` is read after all: func_4870587E reads it
byte by byte from +3, 12 bytes a record (`kn2400/notes/data-region/README.md`, corrected).

Census (`scripts/analysis/data_incbin_census.py`; "before" is bf0581312, the lane's base):

| tree   | generic before n / bytes | opaque before   | generic after | opaque after    |
|--------|--------------------------|-----------------|---------------|-----------------|
| kn6000 | 380 / 18,810             | 3,336 / 79,522  | 0 / 0         | 3,197 / 70,137  |
| kn6500 | 386 / 18,930             | 3,346 / 83,667  | 0 / 0         | 3,213 / 74,371  |
| kn2400 | 431 / 18,853             | 5,048 / 197,205 | 0 / 0         | 5,051 / 196,479 |
| hdsx3  | 40 / 266                 | 101 / 3,133     | 0 / 0         | 101 / 3,133     |

The opaque bytes fall (the record starts are records now); the KN2400's opaque piece count rises by 3 while
its opaque bytes fall by 726 (pieces split at labels the new records and reader rows name; not traced one by one).

## Open questions

- The siblings' reader rows of address-only pieces: the walk does not carry a register argument into the
  routine that reads it (the KN7000 profiles' extended walk, `readers_ext`, made the KN2400 worse: 78.1% typed
  instead of 82.6%, bitmaps lost, tried 2026-10-30 and not applied).
- [INFERENCE] The KN2400's two setup lists by model (the 0x98070000 bits). Resolved 2026-10-31 (lane
  mn10300-formats, `../../kn7000/notes/mn10300-formats/README.md`): `KnprModelGet` 0x487055C4, 0 KN2600,
  1 KN2400, 2 PR54; `StyleRecordTableAlt` is now `StyleRecordTableKN2400`.
- The hash tables' payloads past their first field, and ShortKeyHash's key. Resolved 2026-10-31 (same
  lane): ShortKeyHash's key is a panel switch (group << 8 | number) and its payload the bank MSB / LSB /
  program it selects; ToneKeyHash's payload {tone, icon, switch groups and numbers}.
- The KN2400's effect-program blocks: 0x4853C5BE.., 20 KB, and 0x48537CDC.. (`7c aa aa 7d 55 55 ...`).
  Resolved 2026-10-31 (lane mn10300-rest, `../../../kn7000/notes/mn10300-rest/README.md` section 1): the
  effect DSP's program streams, parameter scripts and address maps of the 208 DSP types, 55,111 bytes,
  typed by `gen_data_s.py fx_streams()`.
- The one-touch bytes the macros keep as hex (PM_PART fields are named in panel_memory.inc).
  (Mostly resolved 2026-11-02, lane mn10300-names, from the KN6000 merge tables 0x4C19AB04..: PM_SET77's
  m008040 is `conductor` (0x008040, 0..5, the KN5000's SndParam_Conductor; func_4C02EDD9 / func_4C02F302 pick
  the RIGHT1 / RIGHT2 / left-zone parts from it) and m00c084 is `left_hold` (0x00C084, LeftholdToggleFunc;
  the mask 0x01 drops ON BASS); PM_SET8C's m00e001 is `pad_volume` (0x00E001 goes out as controller 7 to parts
  0x1D / 0x1E, "PAD PART1" / "PAD PART2" in ApcToSMFConvGrid).  PM_ENTRIES' eight bytes were already named
  (the accompaniment parts' volumes).  Left: PM_SET88's m008008 (0x008008 / 0x008009), which KN6000
  func_4C114253 sets from latched panel control 0xC6.  `kn7000/src/include/panel_memory.inc`; the values are
  still written in hex by `gen_data_s.py style_panels()`.)  (Resolved 2026-11-06, lane mn10300-data3,
  N-4b34dd8b: m008008 is `apc_volume`, the APC VOLUME (0x008006 is the SEQ VOLUME; while the sequencer plays the
  slider drives 0x008006 instead): control 0xC6 is the APC/SEQUENCER VOLUME
  slider (index 30 of PanelCtrlValueGet_Table, latched by func_4C047993 from wire 0xD6, the CPL panel CPU's
  AD6, which the SX-KN6500 service manual wires to VR1 "APC/SEQUENCER VOLUME"; the KN7000's control 0xC2 /
  AD2 / VR1102 likewise); style_panels() now writes PM_SET88 / PM_SET8C's levels and numbers in decimal.
  `../../../kn7000/notes/mn10300-data3/README.md` section 2.)

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
