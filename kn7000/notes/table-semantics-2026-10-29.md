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

| segment                      | slot | form now                                                                                           | tool                        |
|------------------------------|------|----------------------------------------------------------------------------------------------------|-----------------------------|
| GUI bitmaps, frames, icons   | 0    | 366 indexed PNGs, `src/table/gui/`                                                                 | `tools/table_png.py`        |
| GUI fonts                    | 0    | 12 PNG glyph sheets, `src/table/gui/font_NN.png`; font 5's kern table typed                        | `tools/table_png.py`        |
| `SramRecordDefaultsZZZJ`     | 1    | typed: signature, 220 records of eight `zzzj_voice` entries                                        | `tools/gen_table_styles`    |
| `FactoryMemStyleContainer`   | 2    | typed 'TCMP': header, 3 style records, 60 variation records, heap streams                          | `tools/gen_table_styles`    |
| `FactoryMemPadContainer`     | 3    | typed 'TPAD': header, 5 bank records, 18 pad records, heap streams                                 | `tools/gen_table_styles`    |
| `TechnicsPadsResource`       | 4    | typed: header, pad-ID index, pad table, 120 pads in `src/table/pads/`                              | `tools/gen_table_styles`    |
| `InternalVoiceArchive`       | 6    | typed: hash tables, directories, tones, voices, zones (wave recordings named); many fields as rows | `tools/gen_table_voices.py` |
| `UserHpMenuData`             | 57   | 47 2-bpp PNGs, `src/table/user_hp_menu/`                                                           | `tools/table_png.py`        |
| `TcdImages`                  | 58   | 14 1-bpp PNGs, `src/table/tcd/`                                                                    | `tools/table_png.py`        |
| `BuiltinStyleSubTable`       | 59   | typed: offsets + 52 styles (51 in table 83), one file each in `src/table/styles/`                  | `tools/gen_table_styles`    |
| `TechnicsRhythmsTable`       | 83   | typed: the copy of IC18's header, index (`sidx_*`) and offset tables                               | `tools/gen_table_styles`    |
| table 83's plug-in data gaps |      | typed where understood (`typed_gap`); 3 gaps still generic (below)                                 | `tools/gen_table_s.py`      |
| `BASEEXT.XAP` data           |      | typed (`--typed-gaps`); one 42-byte gap still generic                                              | `tools/gen_xap_s.py`        |
| table 80                     |      | its two passthroughs of table 83's image marked `census: generated`                                |                             |

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

| format       | items                     | packing (evidence: `annotations/gfx_draw.ann`)                                                                          |
|--------------|---------------------------|-------------------------------------------------------------------------------------------------------------------------|
| `p8 W H`     | 53 bitmaps, 73 frames     | `DrawBitmap_Impl` 0x48423BBA, `DrawFrameSP_Impl` 0x48423F6E: 1 byte a pixel, rows padded to even (pad byte 0 always)    |
| `p4 24 24`   | 240 icons                 | `DrawIcons_Impl` 0x48423E31: 24x24, 4 bpp, high nibble left; nibble n -> index n or 0xF0 + n                            |
| `font C H N` | 12 fonts, 224 glyphs each | `DrawString_Impl` 0x48425467: 1 bpp column-major, C 8-pixel columns of H bytes, from 0x20; font 5 proportional          |
| `b1 240 80`  | 14 TCD pictures           | `AcTcdImageProc` 0x4848CBC4 -> `DrawBitmapSP2` (width 0xF0, height 0x50): MSB-first rows; they are chord-voicing staves |
| `p2 W H`     | 47 USER HP pictures       | `AcUserHpMenuProc` 0x4849681E (`func_48496B28`) -> `DrawBitmapSPFast4`: four 2-bit pixels a byte, rows of (W + 3) / 4   |

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

| tree          | entry                                          | bytes  | why                                                                                                 |
|---------------|------------------------------------------------|--------|-----------------------------------------------------------------------------------------------------|
| kn7000-sp7001 | plug-in data 0x3EF6C5..0x3F782C                | 33,127 | widget/descriptor tables: names (`ap_func`, `style_id`, `font` ...) and binary records, not decoded |
| kn7000-sp7001 | plug-in data 0x3F783E..0x3F88F0                | 4,274  | the same kind                                                                                       |
| kn7000-sp7001 | plug-in data 0x3F9194..0x3FB59C                | 9,224  | the same kind                                                                                       |
| kn7000-sp7001 | `program/region1_0C.s` x 2, `library_00.s` x 1 | 2.6 MB | program 942's data region and library head: the program image, not the table (no program lane here) |

## The 'JK' internal voice archive (segment 6)

`tools/gen_table_voices.py` writes it to `src/table/voices/internal_archive.s` (table 83:
`src/sp7001/internal_voice_archive.s`, the same text but for the reference image). Since the third
pass it holds no passthrough. All pointers are u32 offsets from the archive's first byte,
little-endian. The macros (`jk_param`, `jk_zone6`, `jk_zone8`, `tone_head`, `tone_type`,
`tone_head_table`, `tone_note`) are in `src/table/style_macros.inc`.

**How a note reaches a recording.** This is traced through program 941's library.

1. The part's tone block (0x500CE404 + part x 0x130) holds the tone record's address at +0.
   `TgPartProgramApply` 0x4C03893D stores what `func_48449525` returns. That routine looks the
   MIDI triple up in the tone-key hash table (`func_4856FC51` / `func_48570078`, sound directory
   +0x00/+0x18) and indexes the descriptor's +0x04 tone directory with the result.
2. The note-on staging (0x4C035EAA..) fetches four more records into the voice record
   (librec):
   - +0x3C, the voice sub-record (`TgPartVoiceRecFetchIdxSel`);
   - +0x40, the element (`TgPartElemProgramApplyIdxSel`), whose 5-byte velocity splits pick a
     5-byte layer entry;
   - +0x44, the parameter record (`VoiceParamRecFetchBanked`), from the layer's {program, bank};
   - then `TgPitchZoneFold` and `TgVoiceRoutePtrCalc`.
3. `TgVoiceRoutePtrCalc` 0x4C02BE45 finds the zone:
   - the key map is base + *(base + param+0), and gives group = keymap[note];
   - the zone index is (param+0 + 4)[group];
   - the zone is (base + param+4) + index x (8 when param+8 bit 7 is set, else 6).

   **That bit is the 6- vs 8-byte selector.** `TgPitchNoteResolve` adds the 8-byte zone's s16 at
   +6 only when it is set.
4. `TgVoiceRouteFieldSet` / `TgElemNoteOnStd` put the zone's page (byte +0) and entry (+2 & 0xFFF)
   into the select word. `TgVoiceSideSelect` takes the TG side from bits 10/11 of the halfword
   +0. Which TG, MAIN or SUB, each side bit means was not traced, so a zone's comment names both
   `Main_Ppp_Eeee` / `Sub_Ppp_Eeee`, keeping those that exist in `src/wave/`.

**Static cross-check** (the open item of `wave-roms-2026-10-29.md`): all 3,753 zones of the 864
zone lists and all 1,462 zones of the trailing zone array name an existing wave directory entry.
The generator lists any that does not ("no such wave entry"), and none does.

| item                     | count / size                   | typed as                                                   | reader / evidence                               |
|--------------------------|--------------------------------|------------------------------------------------------------|-------------------------------------------------|
| header                   | 0x20                           | `.ascii`, `.long`                                          | `VoiceArchiveScanBoot` (+0x14), lookups (+0x18) |
| bank block T, descriptor | 0x54                           | `.long` label differences                                  | `VoiceArchiveScanBoot`, the fetchers            |
| sound directory D        | 0x48: 8 hash tables + 2 tables | `.long`                                                    | the `Voice*Lookup*` routines, `func_48570078`   |
| hash tables              | 8 tables, 11,357 chain entries | descriptors, buckets, entries with links and MIDI keys     | the bucket walks                                |
| tone directory, records  | 1,293 (+ 'Initial')            | name, `tone_head`/`tone_type`, rows, 0x7A units as rows    | `func_48449525`, `TgNoteOn`, `VoiceModRecFetch` |
| table tones              | 52 x 0x1A7                     | `tone_head_table`, 128 `tone_note`                         | `TgNoteOnTableTone` 0x4C03600D                  |
| voice directory, records | 1,617 (+ default)              | name, selector byte, 0x1C sub-records as rows              | `VoiceRecFetchBanked`, `VoiceSubRecFetch`       |
| parameter records        | 864 x 0x10                     | `jk_param` (offsets symbolic)                              | `TgVoiceRoutePtrCalc`, `TgPitchZoneFold`        |
| key maps                 | 7 x 128 (one unreferenced)     | `.byte` rows                                               | `TgVoiceRoutePtrCalc`                           |
| multisample headers      | 864                            | `.long` key map, group -> zone bytes                       | `TgVoiceRoutePtrCalc`                           |
| zone lists, zone array   | 3,753 + 1,462 zones            | `jk_zone6` / `jk_zone8` with the recording named           | as above                                        |
| element table            | 87 x 0x23                      | rows                                                       | `VoiceElemRecFetch`, `TgVoiceZoneVeloResolve`   |
| other descriptor tables  | +0x30 .. +0x44, T+8, D+0x10/14 | rows; names as `.ascii` (128 group names, tunings, curves) | `func_484499E9` (+0x30); the rest not traced    |
| 0x2C8-byte named records | 40 (descriptor +0x3C)          | name, rows                                                 | size = a SOUND EDIT record; reader not traced   |

**What "typed as rows" means here.** About two thirds of the archive's bytes are rows of `.byte`
with their offsets in a comment, inside records whose boundaries, names and roles are known but
whose fields are not traced: the tone heads beyond +0x10/+0x12/+0x44/+0x45, the 0x7A units, the
voice sub-records, the element rows, the 0x2C8 records and the smaller tables. The census reads 0
generic for this tree, but **those fields still need naming**.

Field readings for the 0x7A units are left as candidates, not applied. The `Tg*` routines read a
"desc2" at librec+0x3C with offsets up to +0x47 (EG rates and levels, key scaling, filter). That
does not fit the 0x1C-byte voice sub-record the staging stores there. Which record those offsets
really address needs the staging traced once more.

## The SP7001 plug-in's GUI data: preparation (not typed yet)

These are the three generic plug-in gaps of table 83: 0x3EF6C5..0x3F782C (33,127 B),
0x3F783E..0x3F88F0 (4,274 B) and 0x3F9194..0x3FB59C (9,224 B). They hold the plug-in's MILK GUI:
its own class records, their field-name arrays, the widget records and their caption strings
("SELECT SONG", "SD-AUDIO PLAY" ...).

`table-semantics-probes/plugin_milk_probe.py` finds the plug-in's 10 classes, at 0x483F8DB8..
0x483F8EA8. The record is the 24-byte KN5000/KN7000 class layout that lane gui-kn7000 documents.

| class               | parent       | allsize | selfsize | own fields                                                                       |
|---------------------|--------------|---------|----------|----------------------------------------------------------------------------------|
| `AcKssList`         | `0x00040012` | 112     | 80       | ap_func, style_id, is_big, ... num_items, enum_type, is_ringlist, dial, ... (28) |
| `PsKssTextBox`      | `0x0004001D` | 64      | 24       | is_3d, ver_align, padding, auto_wrap, init_str, str_adr                          |
| `KssBgScreen`       | `0x00040041` | 52      | 12       | image_id, title, icon                                                            |
| `DbKssMemo`         | `0x00040012` | 44      | 12       | ap_func, popup, extension                                                        |
| `AcKssScreenMenu`   | `0x02F40001` | 72      | 8        | ap_func, editsw                                                                  |
| `AcKssEditBox`      | `0x0004001D` | 84      | 44       | ap_func, editsw, is_selected, selection, caption, cap_font, ... (13)             |
| `AcKssNamingWindow` | `0x00040043` | 44      | 0        | (none)                                                                           |
| `IvKssNaming`       | `0x00040015` | 28      | 4        | func                                                                             |
| `AcKssNamingEditSw` | `0x00040020` | 52      | 8        | sign, page                                                                       |
| `KssXLyricsBox`     | `0x00040012` | 36      | 4        | pEnable                                                                          |

The parents are the firmware's block-0 classes (`0x0004xxxx`), plus one class of the plug-in's own
registry slot 0x2F4 (`0x02F40001`; `AcKssScreenMenu` derives from it). After the field-name strings,
the widget records start at about 0x3F0668. Each is a Viewable header: class id, super / sub / next /
prev indices, flag, rect. It is followed by the class's own fields and, inline, the caption
strings the records point at.

Plan, once `data/gui-kn7000` is on main:

1. Reuse `milk_model.py`, which computes the field sizes from propdata and checks the links, and
   reuse the per-class macros of `gui_classes.inc` for the firmware's base classes.
2. Generate macros for the 10 KSS classes from the records above.
3. Spell every record by name, with the class by name, rect as X/Y/W/H and links by object name,
   from `gen_table_s.py`'s plug-in pass.
4. Add the plug-in's screens to the menu map.

## BASEEXT.XAP 0x167E4..0x16810

It is now typed: 0xFFFFFFFF, the pointer 0x502AFF88, eight u32 values `0x02F001nn` (nn = 3, 4, 5,
0x0A, 9, 8, 7, 6), then the pointer 0x502B006C. Neither a code immediate nor a data word
anywhere in the file points into 0x502B1700..0x502B1840, so nothing reads this by its address.
It sits among the plug-in's static records and is presumably reached through a structure
pointer.

## Measurements

`notes/table-semantics-probes/table_semantics_probe.py` (README beside it) printed, for both
builds: odd-width row pads 393 (bitmaps) and 364 (frames), all 0. Segment 59 has 52 / 51 styles
whose streams all parse. Segment 4 has 120 pads. TCMP stores 0xCC00 and SumU16BE(0x70, 6912)
gives 0xCC00. TPAD stores 0xE13D and SumU16BE(0xD0, 936) gives 0xE13D.

`python3 scripts/analysis/data_incbin_census.py` at this lane's last commit (third pass):

| tree          | generated     | media           | opaque | generic n | generic bytes |
|---------------|---------------|-----------------|--------|-----------|---------------|
| kn7000-table  | 439 / 299,512 | 159 / 1,316,309 | 0 / 0  | 0         | 0             |
| kn7000-sp7001 | 439 / 299,512 | 159 / 1,316,309 | 0 / 0  | 6         | 2,646,270     |
| kn7000-b80    | 2 / 4,064,860 | 0 / 0           | 0 / 0  | 0         | 0             |

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
