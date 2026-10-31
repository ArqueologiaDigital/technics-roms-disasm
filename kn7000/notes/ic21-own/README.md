# Felipe's own IC21: the whole custom-data flash of his KN7000, typed

Lane `ic21-own`, 2026-10-31, branch `open2/ic21-own`. The owner's decision, verbatim: "Yes, lets add
IC21 as well. Document in the source header what you just told me about these contents". Until then
this read was kept out of the trees as personal data (`custom-data-ic21.md`,
`notes/data-semantics-2026-10-29/README.md`).

IC21 is the KN7000's 2 MB custom-data flash, at CPU `0x96800000`-`0x969FFFFF`. The read is pass 1 of
the ROM dumper on Felipe's KN7000 (PROGRAM 893, TABLE 80), taken 2026-10-19. It was read twice, and
`pass1-run2` is byte-identical: SHA-1 `33b988ec7f63e5fe3c8299f1db2e3b5955a71ff2` for both.

    make -C kn7000 verify-ic21-own   # rebuild all 2 MB from src/ic21own/ic21.s; in make gate-kn7000
    make -C kn7000 ic21-own-src      # regenerate the generated parts (the committed files are the result)
    make -C kn7000 ic21-own-probes   # print every figure below (ic21-own-probes/README.md)

The private read is copied by the Makefile to `kn7000/baserom/kn7000_ic21_own.bin`, git-ignored, with
the SHA-1 checked before and after the copy. `IC21_OWN=` overrides the default path,
`$(HOME)/compartilhado/technics_roms/roms/kn7000/real_dump_v1.3_b893/pass1-run1/IC21.BIN`.

Routine addresses are program 941's (`kn7000/src/program/`), as in `custom-data-ic21.md`. Names in
CamelCase are the firmware's own reflection names or `kn7000_manual.sym`'s. `[INFERENCE]` marks a
reading that no traced code fixes.

## The sources

| path                                     | what                                                                             | made by                                           |
|------------------------------------------|----------------------------------------------------------------------------------|---------------------------------------------------|
| `kn7000/src/ic21own/ic21.s`              | the whole chip: header (what it holds), erased areas, flash-test pattern, layout | hand                                              |
| `kn7000/src/ic21own/midi.inc`            | chip `0x4000`: USER MIDI SETTINGs, CUSTOM PANEL, system settings                 | `tools/gen_ic21own_s.py`                          |
| `kn7000/src/ic21own/favorites.inc`       | chip `0x10000`: FAVORITES                                                        | `tools/gen_ic21own_s.py`                          |
| `kn7000/src/ic21own/homepage.inc`        | chip `0x11000`: HOME PAGE record and its BMP                                     | `tools/gen_ic21own_s.py`                          |
| `kn7000/src/ic21own/custom.s`, `custom/` | chip `0x20000`: the CUSTOM STYLE bank, one include per record and residue run    | `tools/gen_customdata_s.py --base 0x20000 --part` |
| `kn7000/src/include/user_settings.inc`   | the macros of the blocks below `0x20000`, each field with its reader             | hand                                              |

The CUSTOM bank uses the factory banks' macros (`src/customdata/customdata.inc`,
`src/include/panel_memory.inc`, `src/include/voice_record.inc`). The CUSTOM PANEL uses the shared
PANEL MEMORY macros `PMR_*`. Labels are CPU addresses (`.mnbase 0x96800000`); `.org` and
`.incbin_range` take chip offsets. Each generator models the bytes of every line it writes and stops
on a mismatch.

Two changes to `gen_customdata_s.py`; `src/customdata/` regenerates with no diff after both:

- `--base`, `--part` and `--opaque-why`: the bank is taken from inside a bigger image. Offsets are
  that image's, the macro includes are left to the including file, and the residue's opaque reason
  names the corpus.
- `CSTREC_PLACE` is now spelled from the record's own `+0xA4`/`+0xA5`. Before, it was spelled from
  the directory: in Felipe's bank two records differ from the directory (see below), which no factory
  bank does.

## What the chip holds

| chip offsets         | CPU          | what it holds                                                                                                 | compared with the factory data                                                                                         |
|----------------------|--------------|---------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| `0x00000`-`0x03FFF`  | `0x96800000` | erased                                                                                                        |                                                                                                                        |
| `0x04000`-`0x0427F`  | `0x96804000` | the three USER MIDI SETTINGs (the layout of a `.MD` file)                                                     | all 640 bytes equal `02UMDINI.MD`, and the firmware's own default (893 `0x486162A0`)                                   |
| `0x04280`-`0x04A6F`  | `0x96804280` | the CUSTOM PANEL: a PANEL MEMORY record (43 records) and a second list (7)                                    | 1,935 of 2,032 bytes equal the firmware's default `Str_empty_1431`: this unit's custom panel                           |
| `0x04A70`-`0x04AA3`  | `0x96804A70` | 26 halfwords of system settings (language, display times, data protect ...)                                   | 42 of 52 bytes equal the default the boot check writes                                                                 |
| `0x04AA4`-`0x05FFF`  |              | erased                                                                                                        |                                                                                                                        |
| `0x06000`-`0x07FFF`  | `0x96806000` | `A5 A5 5A 5A` x 2048: the ROM test's flash-test pattern                                                       | written by the firmware itself (`func_4849FCF2`)                                                                       |
| `0x08000`-`0x0FFFF`  |              | erased                                                                                                        |                                                                                                                        |
| `0x10000`-`0x10197`  | `0x96810000` | FAVORITES                                                                                                     | all 408 bytes equal `03FAVINI.FAV`, and the firmware's default (893 `0x48604390`)                                      |
| `0x10198`-`0x10FFF`  |              | erased                                                                                                        |                                                                                                                        |
| `0x11000`-`0x1118B`  | `0x96811000` | HOME PAGE record                                                                                              | equal to `04HPGINI.HMP`'s except 53 bytes, all in `+0x08..+0x53` (type and parts: this unit's home page)               |
| `0x1118C`-`0x15441`  | `0x9681118C` | the home-page BMP, 160 x 100                                                                                  | equal to `04HPGINI.HMP`'s and to program 893's default (`Bmp_48743E5C`)                                                |
| `0x15442`-`0x1FFFF`  |              | erased                                                                                                        |                                                                                                                        |
| `0x20000`-`0xF8F16`  | `0x96820000` | CUSTOM STYLE bank: 20 styles with their ONE TOUCH SETTINGs (blocks 1-21), residue in free blocks 22 and 24-27 | 969 of 3,472 256-byte chunks (27.9%) occur in one of the nine factory banks; no used 64 KB sector equals one of theirs |
| `0xF8F17`-`0x1FFFFF` |              | erased                                                                                                        |                                                                                                                        |

`[INFERENCE]` The boundaries fit the sector map of a bottom-boot 16 Mbit AMD flash: sectors of 16 KB,
8 KB, 8 KB and 32 KB, then 64 KB ones. `src/symbols.inc` names the command window `CUSTOM_FLASH_CMD`,
"AMD 29LV160". With that map, each block starts a sector of its own.

**What changed from the 2026-10-19 analysis** (its README in the private folder):

- `0x04280`-`0x04ABF` was "2 KB more MIDI-setting records". It is two things, and the used part ends at
  `0x04AA3`. The first is the CUSTOM PANEL, a 0x7F0-byte image of the live panel state in PANEL MEMORY
  format. The second is 52 bytes of system settings, which close the 0xAA4-byte image the firmware
  keeps at `0x96804000`.
- "No user-typed names were found" needs a footnote. The text-run probe still prints 39 KN5000 and 17
  KN7000 names. Read from the records' structure, the bank has 340 name fields:
  - 208 are KN5000 program names (116 distinct) and 127 are KN7000 program or table names (18 distinct);
  - 4 are KN5000 names respelled: `Jazz At 3.00am` (KN5000 `Jazz At 3:00am`), `3/4 Played By 4`,
    `Disco - Techni` and `Sentimntal Solo`;
  - `Metallic Dance` matches no image in this repository.
- The home page's 53 bytes are not one contiguous run. They lie within `+0x08..+0x53`, and the probe
  merges runs across gaps of up to 8 equal bytes.

All other figures of that analysis reproduce exactly. `regions.py`, `regions2.py`, `custom.py`,
`names_kn5000.py` and `marker.py` were copied here and print them.

## The settings image at `0x96804000` (0xAA4 bytes)

The table's help texts say what this image is. HelpTextEn41_0 (`kn7000/src/table.s`): "User MIDI
Settings, Help language, and Rhythm Custom etc. are not affected by Initial Setting". The image holds
the first two. Rhythm Custom is the CUSTOM bank.

- **RAM copy** at `0x500D2B14`. `func_4C024247` copies the whole image to it.
- **Write back:** `func_4C024000(n)` programs the image back with FlashProgram128Words, 0xAA4 bytes.
- **Re-read:** `func_4C024030(n)` re-reads one section n:

| n     | offset             | size         | what                             |
|-------|--------------------|--------------|----------------------------------|
| 0     | `+0x000`           | 0x10         | `.MD` header                     |
| 1     | `+0x010`           | 0xC0         | parameter-id list                |
| 2..4  | `+0x0D0` ...       | 0x90 each    | USER MIDI SETTING 1..3           |
| 5     | `+0x000`           | 0x280        | the `.MD` part whole             |
| 6, 7  | `+0x280`           | 0x750, 0x7F0 | the CUSTOM PANEL, short or whole |
| 8..20 | `+0xA70`..`+0xAA0` | 2 to 12      | the field groups of `USR_SETUP`  |

At boot, `func_4854AC28` calls `func_4C023EC9`, which compares the image's first 3 bytes with `"JK "`.
When they differ it rebuilds the image from ROM and programs it, 0xAA4 bytes:

- the `.MD` part, by `func_484C41B6`, from `Str_JK_6` and `func_484C41B6_Block`..`_Block_4`;
- the CUSTOM PANEL, by `func_4C01ED5D`, which copies `Str_empty_1431`, 0x7F0 bytes;
- the 26 halfwords, from `func_4C023EC9_Table` and `func_4C023F9B_Table`. Bit 0 of `0x500D35B2` is
  kept.

It then resets the home page (HpFlashWriteDefaults) and the favorites (`func_4849EDEB`).

**USER MIDI SETTINGs (`+0x000`, the `.MD` layout).** The header is `UMD_HEADER`: `"JK "`, NUL, then six
halfwords. The first is 0. The others are the offset and size of the id list (`0x10`, `0xC0`), the offset
and size of a setting (`0xD0`, `0x90`), and the count, 3. The code uses the same numbers as constants.

The id list is 44 parameter ids (`UMD_PARAM`), then `0xFFFFFF` up to 0xC0 bytes. Two routines walk it
until `0xFFFFFF`: `func_484C4229` loads a setting into the live parameters (PutM3Em), and
`func_484C4414` stores one (GetM3EmVal).

`func_4C01BC28` decides how many bytes a parameter takes. An id whose bits 20-23 are 2, 8, 9, B, C, D or
E is a part parameter and takes 32 bytes, value n going to `id | n << 24`. Any other id takes one byte.
That gives 137 values per setting, then 7 bytes of 0xFF (`UMD_PARTS`, `UMD_VALUE`). The loader skips
0x8060 and 0x8061 (split mode, split point) when their value is 0xFF.

The parameters are LOCAL, MIDI CHANNEL and MIDI OCTAVE per part, the MIDI CONTROL channel, the MIDI
message filters (0x2000..0x2099) and 0x8090..0x8092. Their names come from the PANEL MEMORY fields
that hold the same ids (`panel_memory.inc`) and from the MIDI grids that read them. Setting 1 of this
unit sets RIGHT1, RIGHT2 and LEFT to channels 1-3, PART4-16 to channels 4-16, and PART1-3 to OFF.
Setting 3 sets PART1-16 to channels 1-16. `[INFERENCE]` Value n belongs to the part whose panel tag
is n.

**The CUSTOM PANEL (`+0x280`, 0x7F0 bytes).** HelpTextEn35_0 describes it: "a special Panel Memory in
which you can store your favorite Panel Memory settings ... Even initializing the KN will not delete
the Custom Panel".

- **Store and recall:** `func_4C021903` either stores the live panel state `0x84000020` here
  (`func_4C021F7F`, `func_4C021FD9`) or recalls it (`func_4C021FB8`, `func_4C022012`).
- **Size:** 0x750 bytes, or 0x7F0 when `cus_mem_mode` (`+0xA9A`, CusMemModeBoxProc) is non-zero.
  `[INFERENCE]` This is HelpTextEn35_1's choice "whether to load all panel settings or to load panel
  memory parameters".
- **Format:** the PANEL MEMORY record of the floppies' `.PMT` and `.LSW` files. It is a list of 43
  tag/length records ended by FF FF (0x750 bytes), then a second list of 7 records: tags 0x52, 0x50,
  0x51, 0x60, 0x61, 0x62 and 0x68 (0xA0 bytes). Every record is spelled with its `PMR_*` macro.

**System settings (`+0xA70`, `USR_SETUP`).** 26 halfwords, RAM `0x500D3584`..`0x500D35B7`. Each field
is named after the routines that read its RAM copy. Two of them:

- language (CheckLanguage, AcLanguageTextProc);
- data protect (DataProtectGridCheck).

The other fields and their readers are in `user_settings.inc`. Three fields have no named reader.

## The flash test at `0x96806000`

`func_4849FCF2` is one step of the ROM test (MainRomTestFunc, and the test runner `func_484A4FBA`):

1. It fills a 0x200-byte stack buffer with `0x5A5AA5A5`.
2. It programs the buffer to `0x96806000` in 0x80-byte chunks: 0x2000 bytes when `func_4849FC1A`
   returns 1, else 0x320.
3. It reads the area back through CUSTOM_FLASH_CMD, as halfwords from index 0x3000, expecting 0xA5A5
   then 0x5A5A. A mismatch sets bit 3 of the result.

Nothing erases the area afterwards. The constant is at 893 `0x4849FB0C` and 941 `0x4849FD19`, the address
at 893 `0x4849FB28` and 941 `0x4849FD35` (`marker.py`). The 0x2000 bytes here say that the long form of
the test ran on this unit. The source spells them as 64 `FLASH_TEST_CHUNK`s, one per programmed chunk.

## FAVORITES at `0x96810000` (0x198 bytes)

**Boot.** `func_4849EDA9` compares the record with the ROM template `func_4849EDEB_Table`: a strcmp of the
signature, then the u32 at `+0x04`. When either differs it rewrites the record from the template
(`func_4849EDEB`, then `func_4849EE0B`, FlashProgram128Words 0x198 bytes). Then `func_4849EE33` loads the
record to RAM `0x5006B888`.

**Layout:**

- `+0x00`, `FAV_HEADER`: `"JK "`, NUL, and the u32 stamp `0xFFFFFFF3`.
- `+0x08`: four banks of 100 bytes (FavBankNamingFunc: `0x5006B890 + bank * 0x64`). Each bank
  (`FAV_BANK`) is a 16-character name, a u32 that is 0, then ten items.
- An item (`FAV_ITEM`) is `{u32 kind, u32 value}`. AcFavoriteProc takes items 0..9 and dispatches on
  the kind through `AcFavoriteProc_Table`:

| kind             | handler         |
|------------------|-----------------|
| 0, 1, and 10..15 | `func_4849D4D4` |
| 2                | `func_4849D575` |
| 3                | `func_4849D6A8` |
| 4                | `func_4849DAAF` |
| 5                | `func_4849DCF9` |
| 6                | `func_4849DE62` |
| 7                | `func_4849E0E0` |
| 8                | `func_4849E193` |
| 9                | `func_4849E303` |

`[INFERENCE]` Kind 3 is a sound, `{program, bank LSB, bank MSB}` low byte first. In every image the tenth
item of each bank is kind 2 with value 0.

This unit's FAVORITES are the factory ones byte for byte: `03FAVINI.FAV`, and the template in program 893.

## HOME PAGE at `0x96811000` (0x4442 bytes = the `.HMP` file)

HmpBlobGet returns this pointer and size. The record comes first, 0x18C bytes, RAM `0x5006B5F8`:

- `HP_HEADER`: `"JK "`, NUL, a u32 stamp `0xFF`, then the home-page type, a u32 at `+0x08`.
  AcHpTypeEditProc keeps the type in 0..5 and indexes TtNormal_Records with it; AcHpPartsListProc
  sets it to 5.
- 64 parts of 6 bytes at `+0x0C` (`HP_PART`; `func_48496956` walks 0x40). A part is a u16 kind, with
  0x31 meaning none (AcHpPartsListProc), then two u16 that `func_48496956` copies to `0x5006B784` /
  `0x5006B786` and compares with the view's `+0x18` / `+0x1A`. `[INFERENCE]` These are the part's x
  and y.

The BMP follows at `0x9681118C`. This unit's record has type 0 and three parts; the factory file has
type 5 and twelve. The picture is the factory one. The source includes the committed
`src/b893/program/data/media/Bmp_48743E5C.bmp`, the default BMP that program 893's HpBmpResetDefault
programs here. The generator checks it byte for byte, and the census counts it as media.

## The CUSTOM bank at `0x96820000`

The bank has the factory format (`custom-data-ic21.md`) and is typed by the same generator. Its 20 slots,
by directory order:

| slot | style            | block(s) | slot | style            | block(s) |
|------|------------------|----------|------|------------------|----------|
| 0    | Soul To Sun      | 1        | 10   | 40's Love Songs  | 10       |
| 1    | New Soul Ballad  | 2        | 11   | Showband         | 11       |
| 2    | N.Y. Rap         | 4        | 12   | Night Club Combo | 12       |
| 3    | House Party      | 3        | 13   | Swing Orchestra  | 19       |
| 4    | Hip Hop          | 20-21    | 14   | 40's Dance Band  | 13       |
| 5    | Straight Dance   | 5        | 15   | Slow Jazz 3/4    | 14       |
| 6    | Dance Floor      | 6        | 16   | Jazz Club        | 15       |
| 7    | Glory Disco      | 7        | 17   | Jazz At 3.00am   | 16       |
| 8    | 80's Disco       | 8        | 18   | Euro Jazz        | 17       |
| 9    | Up Tempo Bigband | 9        | 19   | Gentle Jazz      | 18       |

What differs from the factory banks:

- **Two records were written for other blocks.** The `+0xA4` of slot 13 (Swing Orchestra) says block 22,
  and that of slot 4 (Hip Hop) says blocks 26-27, while the directory has them at 19 and 20-21. Free
  blocks 22 and 26-27 hold residue whose bytes repeat those records: `Block27_Residue.inc` is a copy of
  `Slot04 +0x8040..`. `[INFERENCE]` The slots were first saved at 22 and 26, then moved. The save
  programs the record with the place it was built for, and a later copy or compaction moved the blocks
  without rewriting `+0xA4`.
- **None of the 80 ONE TOUCH SETTINGs holds program 941's part tails at `+0x8F`.** The generator spells
  those 13 bytes as plain bytes. This unit runs program 893. `[INFERENCE]` 893's one-touch writer differs
  there. The factory banks have 82 such settings (`custom-data-ic21.md`).
- **No complete stale record.** Free blocks 22 and 24-27 hold parts of older records, and block 23 is
  erased.
- **Residue**, typed as in the factory banks: 117,903 bytes are copies of typed records, 35,260 whole
  event streams and 32,210 event runs. 2,256 bytes stay opaque, in 191 entries.
- **Names:** see "What changed" above. Every style is a KN5000 one (KN5000 program v5-v10). The owner's
  manual (p.120) says CUSTOM holds 20 styles copied from COMPOSER MEMORY; the Initial Data Disk resets it
  to the factory set (p.137).

## Census

`python3 scripts/analysis/data_incbin_census.py`, 2026-10-31, on this branch:

| tree             | generated | media      | opaque      | generic n | generic bytes |
|------------------|-----------|------------|-------------|-----------|---------------|
| `kn7000-ic21own` | 0 / 0     | 1 / 17,078 | 191 / 2,256 | 0         | 0             |

The media entry is the home-page BMP, and the opaque entries are the residue splinters of the CUSTOM
bank (`unknown-dump`, the same rule as the factory banks). The census kind `personal` was removed: no
source used it.

## Open questions

- `Metallic Dance`: a one touch setting name in no image here. The other four non-exact names are KN5000
  names respelled. Were these typed on this unit, or written by a converter? The Style Convert Disk and
  the KN5000 `.SST` / `.SEQ` style files were not searched with the fields' structure.
- The FAVORITES kinds 2 and 4-9, and the u32 at bank `+0x10`.
- The home-page part kinds, and the meaning of x/y = 0xFFFF on a used part.
- The system settings `s35a6`, `s35a8`, `s35aa` and `s35b0`, which have no named reader, and the
  `disp_time` grid's six rows.
- The meaning of the second list of the CUSTOM PANEL (tags 0x50-0x68, the 0xA0 bytes that
  `cus_mem_mode` adds).
- When the long form (0x2000 bytes) of the flash test runs. `func_4849FC1A` returns 1 only when
  `func_4849FBD5` returns 0xFC and byte `+0x1F8` of the buffer `func_4849FB5C` returns is 1.
- Program 893's one-touch writer: where it differs from 941's at `+0x8F`.

## Website page draft

For technics-docs `kn7000-panel-memory.md` and the custom-data page; not written there by this lane.

> ### IC21: what a KN7000 keeps in its custom-data flash
>
> The KN7000 keeps the data its owner can change but Initial Setting must not touch in a 2 MB flash,
> IC21, at `0x96800000`:
>
> | address      | contents                                                                                       |
> |--------------|------------------------------------------------------------------------------------------------|
> | `0x96804000` | the three USER MIDI SETTINGs (the layout of a `.MD` file), the CUSTOM PANEL, system settings   |
> | `0x96806000` | a test pattern the service ROM test writes and reads back                                      |
> | `0x96810000` | FAVORITES: four banks of ten items (a `.FAV` file)                                             |
> | `0x96811000` | the HOME PAGE: its layout record and a 160 x 100 BMP (a `.HMP` file)                           |
> | `0x96820000` | the CUSTOM STYLE memory: 20 styles with their One Touch Settings (an `.AST` file is all of it) |
>
> The CUSTOM PANEL is a whole panel memory, the panel state stored with SET + CUSTOM PANEL. At boot the
> firmware checks the `JK` signature of the settings, FAVORITES and HOME PAGE records, and rewrites a
> missing one from defaults in its ROM. The Initial Data Disk's USER MIDI SETTINGs, FAVORITES and
> home-page picture are exactly those defaults; its home-page record differs from the ROM's in one byte.
>
> The disassembly rebuilds one real chip byte for byte: the IC21 of the project owner's KN7000, read
> with the instrument's own ROM dumper. Its MIDI settings, favorites and home-page picture are the
> factory ones. Its custom panel and home-page layout are his own. Its 20 custom styles are styles of
> the KN5000, loaded into the KN7000.
