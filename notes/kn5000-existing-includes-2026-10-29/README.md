# KN5000 existing trees: the generic binary includes (lane kn5000-existing, 2026-10-29)

Part of the data-semantics effort (`notes/data-semantics-2026-10-29/README.md`). Scope: every `.incbin` that
`scripts/analysis/data_incbin_census.py` classed **generic** in the KN5000 maincpu trees (v10, v9, v7, v6, v5),
table data and custom data.

## Outcome

`python3 scripts/analysis/data_incbin_census.py`, built tree (`make gate`), before (b58b8f696 / 2b70c43ba) and after
this lane:

| tree              | generic before (n / B) | generic after | generated after (n / B) | media after (n / B) |
|-------------------|------------------------|---------------|-------------------------|---------------------|
| kn5000-v10        | 8 / 4,928              | 0 / 0         | 10101 / 870,502         | 0 / 0               |
| kn5000-v9         | 8 / 4,928              | 0 / 0         | 10060 / 851,032         | 0 / 0               |
| kn5000-v7         | 8 / 4,928              | 0 / 0         | 10038 / 849,569         | 0 / 0               |
| kn5000-v6         | 13 / 5,130             | 0 / 0         | 9929 / 843,607          | 0 / 0               |
| kn5000-v5         | 12 / 4,949             | 0 / 0         | 9907 / 842,204          | 0 / 0               |
| kn5000-tabledata  | 69 / 772,289           | 0 / 0         | 344 / 985,431           | 6 / 318,468         |
| kn5000-customdata | 11 / 639,296           | 0 / 0         | 10 / 659,456            | 0 / 0               |

Nothing was declared opaque. All seven trees rebuild byte-identical (`make gate`). The custom-data row is after
the follow-up below: ten `.incbin`s, one per bank or erased run, which now also emit the 20,160 directory bytes (7 banks x 2,880)
that had been `.byte` rows.

Other instruments, run read-only:

- `scripts/analysis/data_range_census.py --images v10,v9,v7,tabledata,customdata`: the bucket totals (CODE /
  KNOWN-A / KNOWN-B / UNKNOWN / FILLER) are identical before and after, for all five images. The marker comments
  move no byte between buckets. v6 and v5 are not in that census.
- `scripts/analysis/doc_quality_census.py --compare`: "nothing rose" against `doc-quality-2026-10-24-04.json`.
- `scripts/analysis/kn5000_source_coverage.py`: v6's verbatim debt went from 22,289 to 17,159 B and v5's from
  24,927 to 19,978 B (see the open questions).
- The dispatch census does not cover v6/v5, the only trees whose code changed, so it was not run.

## What each generic entry was, and what it is now

Most of the 129 entries were **already build products** of a committed round-trip generator: the Makefile rebuilt
the file from readable source before assembling, and the generator's `verify` asserted the round trip. They were
generic only because nothing told the census. They now carry `; census: generated -- <generator>, from <source>`,
written by `scripts/tools/mark_census_generated.py` (its RULES table is the list below; `--check` exits 1 if a line
is missing its marker). Three groups needed real work: the v6/v5 romslices, the v6/v5 boot banners and the HELP
databases' source.

| entries                                                    | trees                           | n  | was                                          | now                                                                                   |
|------------------------------------------------------------|---------------------------------|----|----------------------------------------------|---------------------------------------------------------------------------------------|
| `Bitmap_1bit_*` boot / flash-update banners                | v10, v9, v7, table data (v10's) | 32 | built from PNG by `mono_images.py`, unmarked | marked generated                                                                      |
| `Bitmap_1bit_*` boot / flash-update banners                | v6, v5                          | 16 | committed `.bin`, no PNG, no build step      | PNGs exported, `mono_images.py` covers v5/v6, PORTED_MAINCPU objects depend on them   |
| 8 bpp UI bitmaps from `v10/maincpu/images/`                | table data                      | 33 | built from PNG by `indexed_images.py`        | marked generated                                                                      |
| `Wallpaper_0/1`                                            | table data                      | 2  | built from PNG by `indexed_images.py`        | marked generated                                                                      |
| `demo_preset_NN_compressed.bin` (19)                       | table data                      | 19 | MIDI + YAML -> `midi_to_preset.py` -> LZSS   | marked generated                                                                      |
| `help_db_<lang>_compressed.bin` (5)                        | table data                      | 5  | SLIDE8K of a committed **binary** database   | source is now a text listing `help_db_<lang>.txt` (`scripts/build/help_db_text.py`)   |
| `stale_style_records_residue`, `stale_help_db_german_head` | table data                      | 2  | derived by `gen_stale_help_duplicate.py`     | marked generated                                                                      |
| `section_*.bin` (11 slices of 4 banks)                     | custom data                     | 11 | built from `custom_data/styles/*.styles`     | marked generated; then listing format 2 (see "Follow-up")                             |
| `v7_*` romslices                                           | v6 (5), v5 (4)                  | 9  | slices of committed `.bin` files             | v7's native spelling: `.asciz "XAPR"`/`"TEST"`, a `.byte` table, `ret`, 181 B of code |

### v6 / v5 romslices

The ports (`scripts/converters/port_maincpu_version.py`) left five `.incbin` slices where no v7 line mapped. The
probe `probes/maincpu_slices_probe.py` shows each one's bytes are EQUAL to v7's at v7's address of the same label,
so v7's lines are used verbatim:

- `LoadExtROM_JumpEntry_Data` / `ResInfo_GetResourceListPtr_Str_TEST` (v6 and v5 0xE1FFC6 / 0xE1FFCC): `"XAPR"` and
  `"TEST"`, each NUL + 0xff pad. v7's comments name the readers (`Xapr_DetectAndCallBootInit`'s String_Compare
  against the extension ROM's 0x280000; `ResInfo_GetResourceListPtr`).
- `RhythmFillIn_PatternTable` (v6 0xF64989, v5 0xF6467C): 8 bytes, read by `RhythmFillIn_LookupAndApply`
  (`ld a, (xwa+hl)`).
- `CmpStepTitle_Method3Nop` (v6 0xF69F18, v5 0xF69C0B): one `ret`, `CmpStepTitleFunc_ProcTable[3]`.
- v6 only: `BitMapOut_CopyExtTable_Check` (0xFB435F, 181 B), the same code as v7's 0xFB4454 (relative branches and RAM
  addresses only). v5's routine differs from v7's and was already native.

The nine slice files are deleted. This also lowers v6/v5's verbatim debt in `kn5000_source_coverage.py`.

### The HELP databases (`help_db_<lang>.txt`)

Before, the committed source of each `HelpDB_<Lang>` block was `help_db_<lang>.bin`, the 0x9000-byte decompressed
database: a binary file, so "generated from committed source" would have been true only in name. It is now a UTF-8
text listing, one entry per non-empty page of each help topic. `help_db_text.py build` makes the `.bin` (now
git-ignored), and `compress_slide8k.py --strict --reference` packs it exactly as before. `help_db_text.py verify`
(also `make verify-help-db-text`) checks each listing against the decompression of the factory stream.

Format of the decompressed database, with the evidence:

| offset | size              | field                                                                                              | evidence                                                                                                                                                                                                                                                                   |
|--------|-------------------|----------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| +0x000 | 200 x u32         | absolute RAM pointer (base 0x69800) to the text of slot `50 * (page - 1) + topic`                  | `HelpLang_LoadSlide` (0xF477BA) / `HelpLang_SetFlashAndLoadSlide` (0xF4779A): `ld xbc, 0x69800`, `call SLIDE_Parse_Header`. `HelpStsCheck` 0xF2E669, `HelpStsP2Check` 0xF2E691, `P3` 0xF2E6BE, `P4` 0xF2E6EB: `0x69800 + 4 * (0x296E) + 0/200/400/600 - 4 * HELP_LANGUAGE` |
| +0x320 | to the pool's end | NUL-terminated Latin-1 strings, each starting on an even address, 0x00 pad after an odd-length one | measured, `probes/help_db_layout_probe.py`                                                                                                                                                                                                                                 |
| ...    | to 0x9000         | 0x00                                                                                               | measured                                                                                                                                                                                                                                                                   |

Measured on all five languages: every empty page points at a single empty string, the pool's first at 0x69B20
(English 112 empty slots, German 111, French 95, Spanish 92, Indonesian 102); no other string is shared; the pool
order is topic-major (topic 0 pages 1-4, topic 1, ...); the only escape is `~0d`, the renderer's newline; there are
no control bytes. Topic `t`'s title is `HelpTtlFunc_LookupSlide_PtrTable[(t - 1) mod 50]` (`HelpTtlFunc_DecrementPage`
0xF2E94D, `HelpTtlFunc_LookupSlide` 0xF2E962), so topic 0 is DEMO and topic 1 AUTO PLAY CHORD. The listing shows the
title after the entry header, as a comment.

`[INFERENCE]` The `- 4 * HELP_LANGUAGE` in the HelpSts* handlers only makes sense if the widget that sends
`EVT_GET_LANGUAGE_PTR` adds `4 * language` back. That caller was not traced.

The stale German block (`help_db_german_stale.bin`) is not in this format: it is a truncated remnant whose decoded
tail is garbage (`table_data/help_databases.s`). It is not a ROM input (only `verify-help-databases` uses it) and
stays a committed `.bin`.

### Encoder replay (LZSS presets and SLIDE8K help)

`compress_lzss.py` and `compress_slide8k.py` reproduce the factory streams by replaying the literal / match decisions
of the committed slices `original_ROMs/*_compressed.original.bin`. A plain re-encode does not match: tried on
presets 00, 05 and 18, the streams differ from byte 10-12 on. The **content** of these payloads comes from the
readable sources (MIDI + YAML, the help listings), and `--strict` refuses any source that the replay cannot encode.
The **bit layout** comes from the reference slice. Each marker says so ("encoder decisions replayed from ..."), so
that the census line is not read as "an encoder exists".

## Open questions

- **Style-bank fields still unnamed** (see "Follow-up" below): header +0x04..+0x1d, each section record's
  0x34-byte parameter block (+0x0c..+0x3f) and 16-byte tail (+0x50..+0x5f), and the meaning of the five parts.
  They are typed by position and shape, not named. (Resolved 2026-10-31, lane kn5000-style: notes/kn5000-style-2026-10-31/README.md; scripts/build/style_bank_layout.py names every field for both describers.)
- The HelpSts* caller (see the inference above).
- `CLAUDE.md`'s ROM components table still quotes v6 22,289 B (98.9%) and v5 24,927 B (98.8%) of verbatim blob
  (2026-10-24), and its symbols table v6 53,581 rows. Measured after this lane with
  `scripts/analysis/kn5000_source_coverage.py`: v6 17,159 B (99.2% source), v5 19,978 B (99.0%). The drop is exactly
  the generic bytes above, 5,130 and 4,949 B (the banners plus the slices). v6's symbol file has 53,583 rows. This
  lane did not edit `CLAUDE.md`; the integrator should update both rows. (Resolved: 8f40cc8fc updates both CLAUDE.md rows; open-items register 2026-10-31.)

## Follow-up: the custom-data style banks typed (integrator request, 2026-10-29)

Until this follow-up, the four `custom_data/styles/*.styles` listings (and the Composer image's) kept each bank's
first 20 blocks as `RAW` hex: the header, the directory and the area up to the first cell, 7-14 KB per listing.
`scripts/build/style_events.py` now writes **listing format 2** (format 3 since 2026-10-31, which names every
field: notes/kn5000-style-2026-10-31/README.md), which types those blocks (its docstring, BANK
LAYOUT, defines every line kind and gives the evidence for each field). No `RAW` block is left in any of the
five listings. `kn5000_custom_data.s` no longer keeps its own copy of the directories as `.byte` rows: each bank
is one `.incbin` of the listing's output, `CustomData_Section_0` .. `_6`, so the listing is the only source.
`style_events.py verify`: ROUND TRIP EXACT for all five banks. `make gate` is green. `data_range_census.py`
custom data totals are unchanged (KNOWN-A 660,657, FILLER 387,919).

The field names are the floppy lane's (`floppy/kn5000/formats.py`, branch `data/floppy-kn5000`) where it names
the field: "bank magic", the directory's chain pointers at +0, +4..+0xa (+2 = 0), the name at +0x40, the cell
link base at block 20, and the `st_*` event mnemonics, with `st_ctl4` / `st_ctl5` accepted although no factory
bank uses them. Where the firmware says more, the listing says more:

| bank offset  | listing line                                                                                                                                                                        | evidence                                                                                                                                                                                                                                        |
|--------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| +0x00        | (`BANK b`)                                                                                                                                                                          | `"H\0K\0"`, as the floppy lane                                                                                                                                                                                                                  |
| +0x04        | `reserved_04`, `reserved_0b`, `password`, `composer_mode`, `reserved_11`, `reserved_15`, `reserved_1d`                                                                              | +0x0e password (FmmPasswordFunc, EVT_SET_PASSWORD), +0x10 NORMAL / EXPAND MODE (AcCmpMdBoxProc); the rest constant, no reader (probes/style_bank_readers.py in notes/kn5000-style-2026-10-31)                                                   |
| +0x1e        | `capacity16` 0x1680                                                                                                                                                                 | no reader of the word; the firmware hard-codes the same 0x16800 (MidiPkt_SetXferTotal_StyleImage)                                                                                                                                               |
| +0x20..+0x2b | `dir_offset`, `record_size`, `record_count`, `cell_size`, `cell_count`, `name_offset`                                                                                               | constants in every bank and in `Demo_StyleRhythmData`; no reader of the words: the code hard-codes the same values (30 = `cp a, 0x1e` in `AccDemo_LoadVariation`, 0x154 = the `cp wa, 0x154` limit checks, 0x60 via `RhythmTiming_OffsetTable`) |
| +0x2e        | `used_size16`                                                                                                                                                                       | written by `AccPatch_InitSlotChain`; read by `cmp_sv_mae` (.CMP size) and `FileIO_SaveRcmFromFlash` (.RCM chunk lengths). The RCM probe confirms it: `+0x2e * 16` = chunk length in all 7 sections                                              |
| +0x60        | `SECTION k cells=... reserved_02=... name="..."`                                                                                                                                    | 30 records = `STYLE_SECTION` 0..29 (a/b/c variation 1-4, intro / fill-in / ending 1-2), order of `AccDemo_LoadVariation_EntryLoop_Data`                                                                                                         |
| rec +0x0c    | `time_sig`, `last_measure`, `rec_chord`, `edit_flags`, `style`, `reserved_12`, five `part` lines (DRUM, BASS, ACCOMP1-3: sound, bank, pan, reverb, pc_byte4, pitch_point, high_key) | RhythmPatInit_LoadParams, the CmSetP1Grid / CmpSetGrid rows, MainCmpSetFunc, AccPatch_SyncVoice_*; scripts/build/style_bank_layout.py                                                                                                           |
| rec +0x50    | `reserved_50`                                                                                                                                                                       | AccDemo_SectionRecordTail's zeros; no reader; 0 in every record                                                                                                                                                                                 |
| +0xba0       | `chord_maps`, `measure_starts`                                                                                                                                                      | the five COMPOSER CHORD MAPs (CmpNcp_StepSlotInGroup2) and the measure-start table at +0xc40 (AccVoice_GetMeasureStartBlock); zero in every factory bank                                                                                        |
| +0x13c0      | `FILLIN mark= prev= next=` + events                                                                                                                                                 | `AccDemo_LoadFillIn` copies 0x40 B here; a 64-byte cell: 80 ffff ffff 87, eight `st_beat`, `st_end`                                                                                                                                             |
| +0x1400      | `CELL b mark= prev= next=`, then `CHAIN` events                                                                                                                                     | `AccPatch_InitSlotChain` (base + 0x1400; 0x96 = 150 head entries = 30 sections x 5 parts, continuation cells from +0xaa00)                                                                                                                      |

**Do the formats differ?** No. `probes/rcm_vs_ic19_probe.py` compares the idd5000 floppy's `01CTMINI.RCM`
sections 0..6 with IC19's banks. In all seven, the header +0x00..+0x2d is byte-identical, `+0x2e * 16` is the
chunk length, the directory pointers agree in their low 12 bits, and every block from +0x1400 has the cell shape.
The pointer nibble is 0 in the file and section + 1 in flash, which the floppy lane traces to the loader's stamping.
The music is different: 36-48 KB of each section differ, because the dumped IC19 holds other styles than the
factory initial-data disk. Two points of interpretation differ from the floppy lane:

1. **The 30 records are the 30 sections of one style, not 30 styles.** `formats.py` comments them "style k".
   The firmware indexes them by `STYLE_SECTION` (0..29: variations 0-11, intros / fill-ins / endings 12-29;
   `AccPatch_GetCurrentSlotAddr`, `RHYTHM_PATTERN_BUF_A + 0x60 + 0x60 * n`). The default image names them
   "a-variation1" .. " c-ending 2". The names a bank holds, such as "Bolero puro" four times, are the names of the
   patterns each section was taken from. (Resolved: e266dd9f8, floppy/kn5000/formats.py emits 30 STYLE_SECTION records; open-items register 2026-10-31.)
2. **The area between the directory and block 20 is not unknown.** It is zero up to +0x13c0, then a 64-byte
   fill-in cell, which the floppy lane types as one opaque run ("between the directory and the first cell"). (Resolved: e266dd9f8, formats.py types data_ba0 and the fill-in cell at +0x13c0; open-items register 2026-10-31.)

The three chains the listing leaves `UNDECODED` (0x0EA in section_0, 0x0E5 in section_1_2, 0x0FE in the Composer
image) are single cells with prev = 0xffff whose payload starts inside an event, as format 1 already showed.

## Probes

`probes/README.md` says what each script answers and how to run it.

## Website page draft

For `rom-reconstruction.md` / `lzss-compression.md`, section "HELP databases":

> The on-screen HELP texts are rebuilt from five plain-text listings,
> `table_data/includes/help_databases/help_db_<lang>.txt`. Each entry is one page (1-4) of one of the 50 help
> topics, the topics whose titles the HELP screen shows (DEMO, AUTO PLAY CHORD, ...). The build turns the listings
> into the 36,864-byte databases the firmware decompresses to RAM 0x69800, laid out as follows. First come 200 pointers,
> one per topic and page, with an empty page pointing at a shared empty string. Then comes the text pool, in topic
> order, each string NUL-terminated and starting on an even address, zero-filled to the end. The build then packs
> them in the SLIDE8K format, replaying the factory encoder's choices so that the ROM is byte-identical. `~0d` in a
> text is the renderer's line break. English has 88 non-empty pages, German 89, French 105, Spanish 108 and Indonesian 98.

For `rom-reconstruction.md`, a line under the data census:

> As of 2026-10-29 no KN5000 maincpu, table-data or custom-data `.incbin` is an anonymous blob. Each one is the
> build output of a round-trip generator from a committed readable source: PNG images, MIDI + YAML demo songs,
> HELP text listings, style event listings, or the derived stale-help duplicate.
