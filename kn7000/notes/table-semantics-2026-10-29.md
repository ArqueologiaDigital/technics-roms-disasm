# The table flash's data, described (lane kn7000-table, 2026-10-29)

Part of the data-semantics effort (`notes/data-semantics-2026-10-29/README.md` at the repo root). The
goal: no table segment left as an anonymous `.incbin_range` of the reference image when a better form
exists. This covers table 84 (`src/table.s`, the image of the update disks), table 83 (the SP7001,
`src/sp7001/table.s`, with its XAPR plug-in and `BASEEXT.XAP`) and table 80 (`src/b80/table.s`).

Wave 1 (`notes/table-rom-probes/`) had already typed the directory, the 159 JPEG/BMP segments and
items, the HELP texts and the GUI resource tables' rows. This lane did the rest.

All routine addresses are program 941's (`kn7000.sym`, `kn7000_manual.sym`).
`[INFERENCE]` marks a reading that no traced code fixes.

## Where each segment stands

| segment                        | slot | form now                                                                          | tool                     |
|--------------------------------|------|-----------------------------------------------------------------------------------|--------------------------|
| GUI bitmaps, frames, icons     | 0    | 366 indexed PNGs, `src/table/gui/`                                                | `tools/table_png.py`     |
| GUI fonts                      | 0    | 12 PNG glyph sheets, `src/table/gui/font_NN.png`; font 5's kern table typed       | `tools/table_png.py`     |
| `SramRecordDefaultsZZZJ`       | 1    | typed: signature, 220 records of eight `zzzj_voice` entries                       | `tools/gen_table_styles` |
| `FactoryMemStyleContainer`     | 2    | typed 'TCMP': header, 3 style records, 60 variation records, heap streams         | `tools/gen_table_styles` |
| `FactoryMemPadContainer`       | 3    | typed 'TPAD': header, 5 bank records, 18 pad records, heap streams                | `tools/gen_table_styles` |
| `TechnicsPadsResource`         | 4    | typed: header, pad-ID index, pad table, 120 pads in `src/table/pads/`             | `tools/gen_table_styles` |
| `InternalVoiceArchive`         | 6    | **still generic** (below)                                                         |                          |
| `UserHpMenuData`               | 57   | 47 2-bpp PNGs, `src/table/user_hp_menu/`                                          | `tools/table_png.py`     |
| `TcdImages`                    | 58   | 14 1-bpp PNGs, `src/table/tcd/`                                                   | `tools/table_png.py`     |
| `BuiltinStyleSubTable`         | 59   | typed: offsets + 52 styles (51 in table 83), one file each in `src/table/styles/` | `tools/gen_table_styles` |
| `TechnicsRhythmsTable`         | 83   | typed: the copy of IC18's header, index (`sidx_*`) and offset tables              | `tools/gen_table_styles` |
| table 83's plug-in data gaps   |      | typed where understood (`typed_gap`); 3 gaps still generic (below)                | `tools/gen_table_s.py`   |
| `BASEEXT.XAP` data             |      | typed (`--typed-gaps`); one 42-byte gap still generic                             | `tools/gen_xap_s.py`     |
| table 80                       |      | its two passthroughs of table 83's image marked `census: generated`               |                          |

`tools/gen_table_s.py` still writes `src/table.s` and `src/sp7001/table.s` whole (`make table-src`,
`make table-src-sp7001`), and `tools/gen_xap_s.py` writes `src/sp7001/baseext.s` (`make
xap-src-sp7001`); all three regenerate to the committed text. They now also write the PNGs and the
per-item include files. A file already there must decode to, or hold, the same bytes. The style
files are shared by tables 84 and 83: every one of 83's 51 styles is the same text as 84's. A style
that differed would go to `src/table/styles/b<build>/`.

## The raw pictures: `tools/table_png.py`

Each item is an indexed PNG whose pixel indices are the firmware's pixel values. Its tEXt chunk
`kn7000-format` says how it is packed. `make` turns the PNGs back into `build/table_png/**.bin`, and
the sources `.incbin` those, marked `census: generated -- tools/table_png.py`. The palettes are only
for viewing. The 8 bpp items use the firmware's CLUT seed (`display_palette` in
`src/program/region1_0C.s`, `ClutPaletteSeedTable` 0x4872573C, 0x00BBGGRR), with 0xF7 transparent.

| format         | items                     | packing (evidence: `annotations/gfx_draw.ann`)                                                                         |
|----------------|---------------------------|------------------------------------------------------------------------------------------------------------------------|
| `p8 W H`       | 53 bitmaps, 73 frames     | `DrawBitmap_Impl` 0x48423BBA, `DrawFrameSP_Impl` 0x48423F6E: 1 byte a pixel, rows padded to even (pad byte 0 always)    |
| `p4 24 24`     | 240 icons                 | `DrawIcons_Impl` 0x48423E31: 24x24, 4 bpp, high nibble left; nibble n -> index n or 0xF0 + n                           |
| `font C H N`   | 12 fonts, 224 glyphs each | `DrawString_Impl` 0x48425467: 1 bpp column-major, C 8-pixel columns of H bytes, from 0x20; font 5 proportional         |
| `b1 240 80`    | 14 TCD pictures           | `AcTcdImageProc` 0x4848CBC4 -> `DrawBitmapSP2` (width 0xF0, height 0x50): MSB-first rows; they are chord-voicing staves |
| `p2 W H`       | 47 USER HP pictures       | `AcUserHpMenuProc` 0x4849681E (`func_48496B28`) -> `DrawBitmapSPFast4`: four 2-bit pixels a byte, rows of (W + 3) / 4  |

Font 5 is proportional: its kern table, typed in the source, holds {u8 advance width, u8 0, u16
offset of the glyph} per character from 0x20. The offsets are contiguous, and each glyph's column
count is its offset step over the height. The PNG lists those column counts in its format string.

The USER HP pictures are drawn in a box that `GetBox` takes from the item's view (the 12-byte rows of
0x485F921C: view ID, item). The box sizes are in the view resources, which were not traced.
`[INFERENCE]` The row lengths in `table_segments.PNG_GROUPS` were chosen as heights that are a
multiple of the 13-pixel text line, with the row length whose rows repeat most. They were checked by
eye: all 47 show coherent panels (bank lists, mixer strips, "PICTURE", tempo and chord boxes). Slot
47 was set by hand to 40 bytes, because at 80 it shows two half-panels side by side. Any row length
gives the same bytes back, so this only affects how the PNG looks.

## The style data: `tools/gen_table_styles.py`

The format is IC18's "Technics Rhythms" (`notes/ic18-rhythm-rom.md`, lane kn7000-ic18), and the
macros keep its names (`src/table/style_macros.inc`). The integrator's ruling of 2026-10-29: music
that can be parsed is typed, one event per line, in per-item include files.

**Segment 59** opens with u24BE offsets, one per style. Index entry 0x4000 + n sends a style-ID to
style n (`StyleBuiltinNameResolve` 0x48433ABF; `TableRomStyleSubTablePtr` 0x4843D797). Each style is
a 0xC6-byte record and 20 variations, exactly as in IC18. Table 84 has 52 styles. Table 83 has the
first 51 of them, identical, so table 84 adds one style ("70s Orchestra") and its 52nd index entry.
After the last style come 3 zero bytes (1 in table 83).

**Segment 83** (table 84 only; table 83 has `"DMY"`) is IC18's first 0x1248 bytes, minus the
styles: the header with its checksum fields zeroed, the count block with 221, the 2048-entry index,
IC18's 169-entry style table and its 8-entry count-in table. Its offsets after the index point into
IC18, so they stay numbers, each with a comment.

**Segment 4, "Technics Pads"** is the same resource shape. `TechnicsPadsResourceParse` 0x48433F4A
checks the 16-byte name and reads the u24BE offsets at +0x18 (the count block, whose u16 at +2,
120, goes to 0x50034C24), +0x1B (the pad-ID index -> 0x50034C2C) and +0x1E (the pad table ->
0x50034C30). `func_4843443E` looks a pad up: an index entry below the count is pad n, and
0x8000 + n sends the lookup to entry n. The index has 1024 entries, folded by `func_48434591` as
`((id & 0x0700) >> 1) | (id & 0x7F)`. A pad is a 16-byte name, then 6 bytes `pad_head` (bars - 1,
beats - 1, then four bytes with no reader traced), two 15-byte part set-ups (`style_part`), a u24BE
stream length and the stream. The 120 pads tile the segment. Five bytes follow the last one,
`00 6C 00 00 00`, which nothing reads; they are a commented `.byte` row.

**'TCMP', segment 2** (`notes/tcmp-container-synthesis.md`, the TCMP section of
`kn7000_manual.sym`) has the following parts:

- a 0x70-byte header: signature, checksum, checksum range, the 0x25800 area length, the allocator
  top (a label difference), N = 3;
- three style records of 0x80 bytes: the style name, four variation names, the 20 slots' variation
  indices and the two sound-unit keys (`style_units`, at +0x70 as in the Technics Rhythms record's
  +0x0D);
- 60 variation records of 0xE0 bytes: a 0x20-byte head (bars - 1 and beats - 1 at +0x10, and the
  stream's offset at +0x15 as a label difference), then eight 0x18-byte part blocks. A part block is
  `style_part` plus `part_more`, the nine further fields of the part-field table 0x485B77D4.
  `[INFERENCE]` The order of `part_more`'s names;
- the heap: per variation its index, a u24BE length and the events.

**'TPAD', segment 3** is read by its likeness to TCMP. The header has the same shape. Five bank
records of 0x30 bytes follow, each a name and six 3-byte references (`tpad_ref`). Then come 18 pad
records of 0x60 bytes: a name, two bytes `[INFERENCE: the pad's ID]`, two flag bytes, bars - 1,
beats - 1, a kind byte, the heap offset, two part blocks and 8 bytes. The heap has the TCMP item
shape. The header's checksum covers the three user banks and the pad records, 0xD0..0x820. That is
measured, not inferred: SumU16BE gives 0xE13D, the stored value.

Every stream in segments 2, 3, 4 and 59 parses under `event_lines`. It opens with 0xF4, ends with
0xF5, holds bars x beats beat markers, and every event has the length `RhyEventLenByStatus`
0x484403D5 gives. The generator refuses any image where one does not. Events are `ev_at`, `ev_beat`,
`ev_end`, `ev_note`, `ev_cc`, `ev_pc`, `ev_press`, `ev_bend` and `ev_sysex`. The SysEx events, in the
TPAD streams, are followed by their data as `.byte`.

## 'ZZZJ', segment 1

`SramRecordsLoadFactory` 0x4843FB65 compares the first 8 bytes with the program's 0x485B7370
(`'ZZZJ', 0, 'K', 0, 0xDC`). It then copies records lo..hi (0x18 bytes each, from +0x10) over the
battery-SRAM table 0x84030FF8. Bit 7 of a record's first byte is a flag: `func_4843FCE6` sets or
clears it and `func_4843FCA2` tests it, for the record `func_4843FACD` picks from GetM3EmVal(0xC000).
`[INFERENCE]` A record is eight {prog, bank_lsb, bank_msb} entries (`zzzj_voice`). The probe shows
bank_msb 0x26 in entries 0 and 1 of all 220 records, and 0x20 elsewhere in 217-220 of them, the
drum/melodic pattern of `style_part`'s program bytes. 220 is the rhythm count. Matching a record
against a style's eight part programs found no exact match for any of the 52 table styles, so what
the records configure (per rhythm or not) is open.

## Table 83's plug-in and BASEEXT.XAP

`typed_gap` (in `tools/gen_table_s.py`, also used by `gen_xap_s.py --typed-gaps`) spells a data gap
as fill (`.space`), text (`.asciz`), UTF-16 character tables (`.word`), pointers (`.long`), IEEE
doubles (`.long lo, hi` with the value) and the C runtime's ctype table. When more than a tenth of a
gap (and over 16 bytes) is not understood, it gives up, and the gap stays a passthrough that the
census still counts, rather than becoming a wall of anonymous `.byte`.

## What is still generic, and why

| tree          | entry                                          | bytes   | why                                                                                                  |
|---------------|------------------------------------------------|---------|------------------------------------------------------------------------------------------------------|
| kn7000-table  | `InternalVoiceArchive`, `src/table.s`          | 832,592 | the 'JK' voice archive; structure partly known (below), records not decoded                          |
| kn7000-sp7001 | the same, `src/sp7001/table.s`                 | 832,592 | the same segment                                                                                     |
| kn7000-sp7001 | plug-in data 0x3EF6C5..0x3F782C                | 33,127  | widget/descriptor tables: names (`ap_func`, `style_id`, `font` ...) and binary records, not decoded  |
| kn7000-sp7001 | plug-in data 0x3F783E..0x3F88F0                | 4,274   | the same kind                                                                                        |
| kn7000-sp7001 | plug-in data 0x3F9194..0x3FB59C                | 9,224   | the same kind                                                                                        |
| kn7000-sp7001 | `BASEEXT.XAP` 0x0167E4..0x01680E               | 42      | a small table of {u8, u8, u16} rows after a pointer, not identified                                  |
| kn7000-sp7001 | `program/region1_0C.s` x 2, `library_00.s` x 1 | 2.6 MB  | program 942's data region and library head: the program image, not the table (no program lane here) |

**The 'JK' archive** (`VoiceArchiveScanBoot`, the `Voice*LookupInternal` routines;
`kn7000_manual.sym`, "THE VOICE-LIST INDEX LAYER"). It is little-endian. The header is `"JK"`, 14
zeros, then u32 1, and u32 0xB2234 at +0x14, which points at a table of offsets. The u32 0xB2288 at
+0x18 is the sound directory: (bucket table, descriptor) offset pairs for the six hash directories.
Before them is about 0.7 MB of voice records. Decoding them needs the tone-parameter layout the `Tg*`
routines read, which is a task of its own.

## Measurements

`notes/table-semantics-probes/table_semantics_probe.py` (README beside it) printed, for both
builds: odd-width row pads 393 (bitmaps) and 364 (frames), all 0. Segment 59 has 52 / 51 styles
whose streams all parse. Segment 4 has 120 pads. TCMP stores 0xCC00 and SumU16BE(0x70, 6912)
gives 0xCC00. TPAD stores 0xE13D and SumU16BE(0xD0, 936) gives 0xE13D.

`python3 scripts/analysis/data_incbin_census.py` at this lane's last commit:

| tree          | generated        | media           | opaque | generic n | generic bytes |
|---------------|------------------|-----------------|--------|-----------|---------------|
| kn7000-table  | 439 / 299,512    | 159 / 1,316,309 | 0 / 0  | 1         | 832,592       |
| kn7000-sp7001 | 439 / 299,512    | 159 / 1,316,309 | 0 / 0  | 8         | 3,478,904     |
| kn7000-b80    | 2 / 4,064,860    | 0 / 0           | 0 / 0  | 0         | 0             |

Before: kn7000-table 447 entries / 2,560,580 B, kn7000-sp7001 704 / 5,176,151 B, kn7000-b80 2 /
4,064,860 B (`notes/data-semantics-2026-10-29/README.md`). Table 80's two entries are generated
from table 83's assembled image, so they carry table 83's remaining generic bytes with them.

## Open questions

- The 'JK' voice archive's records (the largest item left).
- The plug-in's widget/descriptor tables (table 83, about 46 KB).
- 'ZZZJ': what the 220 records and their eight entries select.
- The USER HP pictures' true box sizes (the view resources behind `GetBox`).
- Pad bytes +0x12..+0x15 (`pad_head`'s `kind`, b13-b15), the TPAD record bytes +0x10..+0x15, and the
  TCMP variation head's undocumented bytes: no reader traced.
- The order of `part_more`'s nine fields within the part-field table.

## Website page draft

> **KN7000 table flash: what the data is**
>
> The KN7000's 4 MB table flash (CPU 0x48000000) is an 84-segment archive. With this pass, almost all
> of it is described in the disassembly:
>
> - **GUI resources**: 53 bitmaps and 73 frame pieces (8 bpp palette indices; 0xF7 transparent,
>   0xF6 the template colour, 0xF4 copies the picture plane), 240 icons (24x24, 4 bpp), 12 bitmap
>   fonts (1 bpp, column-major, one proportional). Each is a PNG in the source tree, which the build
>   packs back into the firmware's format.
> - **Pictures**: the Feature Demo's JPEGs, the RHYTHM, SOUND and organ-tab pictures (wave 1), the
>   14 chord-voicing staves of the TCD screen (240x80, 1 bpp) and the 47 USER HP menu panels (2 bpp).
> - **Styles**: 52 built-in styles (51 in the SP7001's table) in the "Technics Rhythms" format of
>   the rhythm ROM: a 13-character name, eight part set-ups, 20 variations (four main patterns with
>   two fill-ins each, two intros and two endings as A/B pairs), and per variation the event stream:
>   position bytes (96 ticks a beat), notes, controllers, pitch bends, beat markers. The table also
>   carries a copy of the rhythm ROM's style-ID index, which adds one style (70s Orchestra).
> - **Pads**: the built-in "Technics Pads" bank (120 pads, the same event format), and the factory
>   PERFORMANCE PAD user memory ('TPAD': banks, 18 pads).
> - **MEMORY styles**: the factory 'TCMP' container with three styles (Easy 8 Beat, Easy 16 Beat,
>   Easy Swing).
> - **'ZZZJ'**: 220 battery-SRAM default records of eight program selections each.
> - **Still opaque**: the 'JK' internal voice archive (0.8 MB), the voices' parameter records.
>
> `make -C kn7000 verify verify-sp7001 verify-table80` rebuilds tables 84, 83 and 80 byte for
> byte. Notes: `kn7000/notes/table-semantics-2026-10-29.md`.
