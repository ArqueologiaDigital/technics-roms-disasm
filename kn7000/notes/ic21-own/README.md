# Felipe's own IC21: the whole custom-data flash of his KN7000, typed

Lane `ic21-own`, 2026-10-31, branch `open2/ic21-own`; open items closed by lane `ic21-rest`, branch
`open3/ic21-rest`, the same day. The owner's decision, verbatim: "Yes, lets add
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

| chip offsets         | CPU          | what it holds                                                                                                                   | compared with the factory data                                                                                         |
|----------------------|--------------|---------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| `0x00000`-`0x03FFF`  | `0x96800000` | erased                                                                                                                          |                                                                                                                        |
| `0x04000`-`0x0427F`  | `0x96804000` | the three USER MIDI SETTINGs (the layout of a `.MD` file)                                                                       | all 640 bytes equal `02UMDINI.MD`, and the firmware's own default (893 `0x486162A0`)                                   |
| `0x04280`-`0x04A6F`  | `0x96804280` | the CUSTOM PANEL: a PANEL MEMORY record (43 records) and a second list (7)                                                      | 1,935 of 2,032 bytes equal the firmware's default `Str_empty_1431`: this unit's custom panel                           |
| `0x04A70`-`0x04AA3`  | `0x96804A70` | 26 halfwords of system settings (language, display times, data protect ...)                                                     | 42 of 52 bytes equal the default the boot check writes                                                                 |
| `0x04AA4`-`0x05FFF`  |              | erased                                                                                                                          |                                                                                                                        |
| `0x06000`-`0x07FFF`  | `0x96806000` | `A5 A5 5A 5A` x 2048: the ROM test's flash-test pattern                                                                         | written by the firmware itself (`func_4849FCF2`)                                                                       |
| `0x08000`-`0x0FFFF`  |              | erased                                                                                                                          |                                                                                                                        |
| `0x10000`-`0x10197`  | `0x96810000` | FAVORITES                                                                                                                       | all 408 bytes equal `03FAVINI.FAV`, and the firmware's default (893 `0x48604390`)                                      |
| `0x10198`-`0x10FFF`  |              | erased                                                                                                                          |                                                                                                                        |
| `0x11000`-`0x1118B`  | `0x96811000` | HOME PAGE record                                                                                                                | equal to `04HPGINI.HMP`'s except 53 bytes, all in `+0x08..+0x53` (type and parts: this unit's home page)               |
| `0x1118C`-`0x15441`  | `0x9681118C` | the home-page BMP, 160 x 100                                                                                                    | equal to `04HPGINI.HMP`'s and to program 893's default (`Bmp_48743E5C`)                                                |
| `0x15442`-`0x1FFFF`  |              | erased                                                                                                                          |                                                                                                                        |
| `0x20000`-`0xF8F16`  | `0x96820000` | CUSTOM STYLE bank: 20 styles with their ONE TOUCH SETTINGs (blocks 1-21), KN6000-layout records in free blocks 22, 24-25, 26-27 | 969 of 3,472 256-byte chunks (27.9%) occur in one of the nine factory banks; no used 64 KB sector equals one of theirs |
| `0xF8F17`-`0x1FFFFF` |              | erased                                                                                                                          |                                                                                                                        |

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
  - `Metallic Dance` is the KN5000's `Metalic Dance` respelled (lane ic21-rest, "Where the names come
    from" below).
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
- **Re-read:** `func_4C024030(n)` re-reads one section n, `func_4C024000(n)` programs it back. Both jump
  through a table of 23 cases (`func_4C024030_Table`, `func_4C024000_Table`); `section_map.py` reads the
  RAM and flash address of every case from the image. Corrected 2026-10-31 (lane ic21-rest): this table
  used to give n = 5 for the `.MD` part, 6 / 7 for the CUSTOM PANEL and 8..20 for the fields, which is
  not the order of the cases.

| n      | offset             | size         | what                             | written back by                     |
|--------|--------------------|--------------|----------------------------------|-------------------------------------|
| 0      | `+0x000`           | 0x10         | `.MD` header                     |                                     |
| 1      | `+0x010`           | 0xC0         | parameter-id list                |                                     |
| 2..4   | `+0x0D0` ...       | 0x90 each    | USER MIDI SETTING 1..3           | `func_484C4144`                     |
| 5      | `+0xA70`           | 2            | language                         | LangSetFlashFunc, LangSetFlashFunc2 |
| 6      | `+0xA72`           | 0xC          | the six display times            | MainTimeFlashFunc, MainSysControl   |
| 7      | `+0xA7E`           | 4            | jump_insert, file_priority       | SetupFlashFunc                      |
| 8      | `+0xA82`           | 8            | para_load1..4                    | MainFlashFunc                       |
| 9      | `+0xA8A`           | 8            | wall_home1..4                    | MainWallSetFlashFunc                |
| 10     | `+0xA92`           | 2            | contrast                         | FN_TtContrast (`func_4854E5C6`)     |
| 11, 12 | `+0xA94`, `+0xA96` | 2 each       | r_a94, r_a96                     | nothing                             |
| 13, 14 | `+0x280`           | 0x750, 0x7F0 | the CUSTOM PANEL, short or whole | `func_4C021F7F`, `func_4C021FD9`    |
| 15     | `+0xA98`           | 2            | data_protect                     | MainDtPrtFlashFunc                  |
| 16     | `+0x000`           | 0x280        | the `.MD` part whole             | `func_484C44FC`                     |
| 17     | `+0xA9A`           | 2            | cus_mem_mode                     | CustomPanelFlashFunc                |
| 18     | `+0xA9C`           | 2            | acc_reverb_mask                  | nothing                             |
| 19     | `+0xA9E`           | 2            | rsp_select                       | TestVideoOutFunc                    |
| 20, 21 |                    |              | none (the case only returns)     |                                     |
| 22     | `+0xAA0`           | 4            | panel_sw1, panel_sw2             | SdcSetupFlashFunc                   |

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
- **Size:** 0x750 bytes, or 0x7F0 when `cus_mem_mode` (`+0xA9A`) is non-zero. The CUSTOM PANEL MODE
  screen (`custommem`) offers "  PANEL MEMORY" and "  ALL PANEL", in that order, and CusMemModeBoxProc
  frames the box `cus_mem_mode` indexes: 0 = PANEL MEMORY, 1 = ALL PANEL (HelpTextEn35_1's choice
  "whether to load all panel settings or to load panel memory parameters"). This unit has 1.
- **Format:** the PANEL MEMORY record of the floppies' `.PMT` and `.LSW` files. It is a list of 43
  tag/length records ended by FF FF (0x750 bytes), then a second list of 7 records: tags 0x52, 0x50,
  0x51, 0x60, 0x61, 0x62 and 0x68 (0xA0 bytes). Every record is spelled with its `PMR_*` macro.
- **The second list** is the panel state that is not part of a panel memory, which ALL PANEL adds: tag
  0x52 the current PANEL MEMORY number (0x000080), the DSP unit numbers and the MONO 1 / 2 output parts,
  tag 0x50 the tone generator mode (0x000008, AcTGModeSelProc), tag 0x51 the touch sensitivity
  (TchSensGridCheck), and tags 0x60-0x62 and 0x68, whose bytes no parameter record covers (field names:
  `panel_memory.inc`, `notes/data-semantics-2026-10-29/kn67-field-names.md`).

**System settings (`+0xA70`, `USR_SETUP`).** 26 halfwords, RAM `0x500D3584`..`0x500D35B7`. Each field
is named after the routines that read its RAM copy; `user_settings.inc` gives every field with its
reader. Two of them are the language (CheckLanguage, AcLanguageTextProc) and data protect
(DataProtectGridCheck). Named by lane ic21-rest (2026-10-31):

- **The six display times** (`+0xA72`..`+0xA7D`, were `disp_time1..6`): the DISPLAY TIME OUT screen
  (`distim`). DispTimeSetGridCheck maps rows 2..7 of its grid to them, in the order of the grid's row
  captions: SAVE REMINDER, 'COMPLETED' MESSAGE, ARE YOU SURE?, ERROR MESSAGE, SOUND/RHYTHM SELECT, EASY
  SETTING (`to_save_reminder` .. `to_easy_setting`).
- **`contrast`** (`+0xA92`, was `s35a6`): the LCD contrast. FN_TtContrast (`func_4854E5C6`, the
  CONTRAST screen) re-reads section 10 and hands the value to `func_484ABAA9`, which clamps it to 3..100
  and sends the panel CPU command 0x1C with `func_484ABAA9_Table[value]`. This unit has 59, the default 50.
- **`acc_reverb_mask`** (`+0xA9C`, was `s35b0`): one bit per accompaniment part, bits 0-7 = ACCOMP1-5,
  BASS, DRUMS1, DRUMS2 (part tags 0x13-0x1A). `func_4C027803` is the CC91 (reverb depth) case of the
  part-CC table `func_4C024DD8_Records_4`; it sends a part's CC91 value only when the part's bit is set,
  else 0. The default is 0xFF and nothing writes the field.
- **`r_a94`, `r_a96`** (`+0xA94`, `+0xA96`, were `s35a8`, `s35aa`): no routine of programs 893, 935 or
  941 names their RAM address except the section code itself (copy and compare), and nothing writes
  their sections 11 and 12 back (`section_map.py`). They stay at the boot defaults, 0 and 1.

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

**When the long form runs** (lane ic21-rest). `func_4849FC1A` reads two bytes of the test state buffer
that `func_4849FB5C` returns (RAM `0x5006BA20`, 0x205 bytes):

- `+0x1F9` is the title the test runs under: `func_484A08DE` stores GetTitleNow there. It must be 0xFC,
  `TT_TESTMENU`, the service TEST MENU screen (`TestMenu2`, twelve pages, `pagemin` 1).
- `+0x1F8` is `func_4849FBE4_Table[page]` for the TEST MENU's current page (AcTestMenuPageProc calls
  `func_4849FC08` on MT_Draw). The table starts `0, 1, 3, 4`, so the byte is 1 on page 1, ROM DEVICE TEST
  (`Testmenu1`: "PROGRAM ROM: IC16", "RHYTHM ROM: IC18 (IC20)", "CUSTOM FLASH: IC21").

So the 0x2000-byte form is the ROM DEVICE TEST page of the TEST MENU. Run from elsewhere (the
`stest1`-`stest7` screens, titles 0xF4-0xFA), the test writes the short 0x320 bytes.

## FAVORITES at `0x96810000` (0x198 bytes)

**Boot.** `func_4849EDA9` compares the record with the ROM template `func_4849EDEB_Table`: a strcmp of the
signature, then the u32 at `+0x04`. When either differs it rewrites the record from the template
(`func_4849EDEB`, then `func_4849EE0B`, FlashProgram128Words 0x198 bytes). Then `func_4849EE33` loads the
record to RAM `0x5006B888`.

**Layout:**

- `+0x00`, `FAV_HEADER`: `"JK "`, NUL, and the u32 stamp `0xFFFFFFF3`.
- `+0x08`: four banks of 100 bytes (FavBankNamingFunc: `0x5006B890 + bank * 0x64`). Each bank
  (`FAV_BANK`) is a 16-character name, a u32 that is 0, then ten items.
- The u32 at bank `+0x10` is the NUL that ends the name, padded to a word. FavBankNamingFunc has the
  naming window (at most 0x10 characters) write the name with its NUL to the bank's start, and
  `func_4849E435` and the bank list's MT_GetString case (`0x4849D1B5`, `"1:%s|2:%s|3:%s|4:%s"`) read
  it with strcpy / sprintf. The items start at `+0x14`.
- An item (`FAV_ITEM`) is `{u32 kind, u32 value}`. AcFavoriteProc takes items 0..9 and dispatches on
  the kind through `AcFavoriteProc_Table`. What each handler draws and recalls (lane ic21-rest; the
  source spells the kinds with the `FAVK_*` names of `user_settings.inc`):

| kind             | handler         | name              | the item                                                                                                                    |
|------------------|-----------------|-------------------|-----------------------------------------------------------------------------------------------------------------------------|
| 0, 1, and 10..15 | `func_4849D4D4` | `FAVK_NONE`       | nothing: an empty box                                                                                                       |
| 2                | `func_4849D575` | `FAVK_SETTING`    | "FAVORITES SETTING": opens the FAVORITES SETTING page (ChangeMode 0xD, ChangeTitle 0x10); value 0                           |
| 3                | `func_4849D6A8` | `FAVK_SOUND`      | a sound `{program, bank LSB, bank MSB}`, put to parameter 0xC00000 of the selected part (0x8041)                            |
| 4                | `func_4849DAAF` | `FAVK_RHYTHM`     | a rhythm: its id, put to parameter 0xC000; `func_48433C1E` names it                                                         |
| 5                | `func_4849DCF9` | `FAVK_STYLIST`    | a MUSIC STYLIST setup: below 0x438 one of StyleRecordTable's 1,080, above the user's; MainFuncCall(0x830000, 0x860003)      |
| 6                | `func_4849DE62` | `FAVK_MENU`       | a menu page: an index into `func_4849DE62_Table` (114 records: "SOUND MENU", "SOUND PART SETTING", "MIXER" ...)             |
| 7                | `func_4849E0E0` | `FAVK_PANIC`      | "PANIC": parameter 0x600004 := 0; value 0                                                                                   |
| 8                | `func_4849E193` | `FAVK_MUTE_KEYS`  | "MUTE KEYS : ON / OFF": toggles parameter 0x600005; value 0                                                                 |
| 9                | `func_4849E303` | `FAVK_SOUND_MODE` | the sound mode: parameter 8 := value; 0 "NX SOUND ON", 2 "GM LEVEL2 ON" (`func_4849E303_Table`)                             |

A kind-6 item opens its page with ChangeMode, ChangeTitle or InterruptTitle, as its record says;
indices 0x2C..0x6E go through MainFuncCall(0x830000, 0x860002). The generator writes each kind-6 item's
page name as a comment, read from `func_4849DE62_Table` in the 941 data source. Every bank ends with
the FAVORITES SETTING item.

This unit's FAVORITES are the factory ones byte for byte: `03FAVINI.FAV`, and the template in program 893.

## HOME PAGE at `0x96811000` (0x4442 bytes = the `.HMP` file)

HmpBlobGet returns this pointer and size. The record comes first, 0x18C bytes, RAM `0x5006B5F8`:

- `HP_HEADER`: `"JK "`, NUL, a u32 stamp `0xFF`, then the home-page type, a u32 at `+0x08`.
  AcHpTypeEditProc keeps the type in 0..5 and indexes TtNormal_Records with it: 0 DEFAULT, 1 DEFAULT
  WITH PICTURE, 2-4 PRESET 1-3, 5 USER, the record's own parts (`HPT_*`). AcHpPartsListProc sets 5.
- 64 parts of 6 bytes at `+0x0C` (`HP_PART`; `func_48496956` walks 0x40): `{u16 kind, s16 x, s16 y}`.
  The kind indexes TtNormal_Table, 49 HomePagePart records (view id, part number, name) named by the 49
  strings of Text_TITLE_BAR_NORM: TITLE BAR NORM / P.MEM / RHYTHM / PAD / SPLIT / SEQ, BALANCE ...,
  RIGHT and LEFT COMBI, R1 / R2 / LEFT SOUND, RHYTHM, TEMPO, CHORD, SPLIT POINT, R1/R2 OCT, TRANSPOSE,
  PAD, MONITOR, P.MEMORY BANK / 1-8 / CURRENT, PADS BANK, PAD 1-6, PICTURE, SEQ SONG, FAVORITES BANK,
  GLOBAL EFFECTS, SOUND DSP, SOUND LOAD OPT, FOOT SWITCH, FOOT CONTROLLER (`HPK_*`). Kind 0x31
  (`HPK_NONE`) is the table's end record (view -1), an unused part.
- x and y are the part's cell: `func_48496956` copies them to `0x5006B784` / `0x5006B786` and compares
  them with the view's `+0x18` / `+0x1A`. y = -1 (0xFFFF) is the row above the grid: every preset layout
  (TtNormal_Records_p0_0..3) and the factory record put their TITLE BAR part there (`hp_parts.py`).

The BMP follows at `0x9681118C`. This unit's record has type 0 (DEFAULT) and three parts:
TITLE BAR NORM at (0, -1), RIGHT COMBI 1 at (8, 0) and BALANCE NORM 1 at (0, 4). The factory file has
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

What differs from the factory banks (rewritten by lane ic21-rest, 2026-10-31; the 2026-10-31 ic21-own
inferences about moved blocks and a different 893 writer are replaced by what follows):

- **The bank was loaded from a KN6000 file.** AstLoadHandler / LoadCst run `func_48485B52` on each slot of
  a file with the KN6000 signature (`custom-data-ic21.md`, "Loading a KN6000 file"). It copies each
  0x90-byte KN6000 setting over the 0xA0-byte default `func_48485B52_Block`, keeps the header's
  `+0xA4`/`+0xA5`, and installs the bigger record in newly allocated blocks. All 80 settings have that
  shape: FF FF at `+0x8E`, the default's tail at `+0x90` (`ots_origin.py`), so none holds 941's part
  tails. Programs 893 and 941 have the same one-touch writer and tables; the writer was never used here.
  The source spells them `PM_KN6000_END` + `PM_CONVERT_TAIL`.
- **The KN6000 records survive.** Free blocks 22 (Swing Orchestra), 24-25 (Modern Samba) and 26-27 (Hip
  Hop) hold three complete records in the KN6000 layout (this bank's; the KN6000's own factory bank
  `01ctmini.ic18` has none, `custom-data-ic21.md`), typed as `Stale22`, `Stale24`, `Stale26`. Two are
  the originals of slots 13 and 4, whose converted records still say block 22 and blocks 26-27 at
  `+0xA4` while the directory has them at 19 and 20-21. Modern Samba is in no slot. Block 23 is erased.
- **Residue**, typed as in the factory banks: 46,927 bytes are copies of typed records, 1,625 the
  donors' lines with other values, 40 a pad record's head, 23,989 streams and 14,313 event bytes. None
  stays opaque.
- **Names:** every style is a KN5000 one (KN5000 program v5-v10). The owner's manual (p.120) says CUSTOM
  holds 20 styles copied from COMPOSER MEMORY; the Initial Data Disk resets it to the factory set
  (p.137).

## Where the names come from

Each slot's four ONE TOUCH SETTING names are the titles of the KN5000's four MUSIC DATABASE records of
that style, in the KN5000 table's order. The KN5000 table-data ROM holds its 1,000 records as text
(category, style, title, tempo), e.g. "Dance Pop / Straight Dance / Metalic Dance / 121" at `0x15DA09`.
75 of the 80 names are those titles as they are; five are spelled differently (`name_origin.py`):

| slot | style           | here              | KN5000 title       |
|------|-----------------|-------------------|--------------------|
| 5    | Straight Dance  | `Metallic Dance`  | `Metalic Dance`    |
| 7    | Glory Disco     | `Disco - Techni`  | `Disco-Techni`     |
| 14   | 40's Dance Band | `Sentimntal Solo` | `Sentimental Solo` |
| 14   | 40's Dance Band | `Harry J.& Co`    | `Harry J.& Co.`    |
| 15   | Slow Jazz 3/4   | `3/4 Played By 4` | `3/4 Played by 4`  |

The style name `Jazz At 3.00am` is the KN5000's `Jazz At 3:00am`. All names are centred in their
16-character fields, as in the factory custom1 / custom2 banks. `name_search.py` searched every dump,
softlist floppy, Club Arena installer, CD-ROM and leaflet we hold, with their containers opened: the
respelled forms occur only in Felipe's own reads. So the bank's author typed the KN5000 names into a
KN6000 CUSTOM file by hand. `[INFERENCE]` Who, and with what, no image here says.

## Census

`python3 scripts/analysis/data_incbin_census.py`, 2026-10-31, on branch open3/ic21-rest:

| tree             | generated | media      | opaque | generic n | generic bytes |
|------------------|-----------|------------|--------|-----------|---------------|
| `kn7000-ic21own` | 0 / 0     | 1 / 17,078 | 0 / 0  | 0         | 0             |

The media entry is the home-page BMP. The 191 opaque residue splinters (2,256 bytes) of lane ic21-own
are all typed now (`custom-data-ic21.md`, "How the residue is typed"). The census kind `personal` was
removed: no source used it.

## Open questions

All the open questions of lane ic21-own are closed (lane ic21-rest, 2026-10-31):

| question                                           | answer                                                                                         |
|----------------------------------------------------|------------------------------------------------------------------------------------------------|
| where `Metallic Dance` comes from                  | the KN5000's MUSIC DATABASE title `Metalic Dance`, retyped ("Where the names come from")       |
| FAVORITES kinds 2 and 4-9; the u32 at bank `+0x10` | the handlers' table above; the name's NUL terminator                                           |
| home-page part kinds; x/y = 0xFFFF                 | the 49 TtNormal_Table parts; y = -1 is the title-bar row above the grid                        |
| `s35a6`, `s35a8`, `s35aa`, `s35b0`; the six rows   | contrast, two unread fields, the accompaniment reverb mask; the DISPLAY TIME OUT messages      |
| the CUSTOM PANEL's second list                     | the panel state outside a panel memory, stored in ALL PANEL mode                               |
| when the flash test's long form runs               | TEST MENU page 1, ROM DEVICE TEST                                                              |
| 893's one-touch writer at `+0x8F`                  | the same as 941's; the settings come from the KN6000-file conversion                           |

What stays open:

- **BLOCKED** (no image): who typed the respelled names into the KN6000 file, and with what.
- The field-level questions of the factory banks: `custom-data-ic21.md`, "Open questions".

## Website page draft

For technics-docs `kn7000-panel-memory.md` and `kn7000-custom-style-memory.md`; not written there by this
lane.

> ### IC21: what a KN7000 keeps in its custom-data flash
>
> The KN7000 keeps the data its owner can change but Initial Setting must not touch in a 2 MB flash,
> IC21, at `0x96800000`:
>
> | address      | contents                                                                                       |
> |--------------|------------------------------------------------------------------------------------------------|
> | `0x96804000` | the three USER MIDI SETTINGs (the layout of a `.MD` file), the CUSTOM PANEL, system settings   |
> | `0x96806000` | a test pattern the service TEST MENU's ROM DEVICE TEST writes and reads back                   |
> | `0x96810000` | FAVORITES: four banks of ten items (a `.FAV` file)                                             |
> | `0x96811000` | the HOME PAGE: its layout record and a 160 x 100 BMP (a `.HMP` file)                           |
> | `0x96820000` | the CUSTOM STYLE memory: 20 styles with their One Touch Settings (an `.AST` file is all of it) |
>
> The CUSTOM PANEL is a panel memory stored with SET + CUSTOM PANEL. In CUSTOM PANEL MODE "PANEL
> MEMORY" it is 0x750 bytes; "ALL PANEL" adds 0xA0 bytes of the panel state no panel memory holds:
> the current panel-memory number, DSP unit and MONO output assignments, the tone-generator mode and
> the touch sensitivity. The system settings hold the language, the DISPLAY TIME OUT of six kinds of
> message, the parameter-load options, wallpaper and home-page choices, the LCD contrast, data protect,
> the custom-panel mode, a mask of the accompaniment parts that get reverb, and two fields no program
> reads.
>
> A FAVORITES item is a kind and a value: a sound, a rhythm, a Music Stylist setup, a menu page, PANIC,
> MUTE KEYS, the sound mode (NX or GM Level 2), or the FAVORITES SETTING button that ends every bank. A
> HOME PAGE is one of six types (Default, Default with picture, Preset 1-3, User); the User type places up
> to 64 of 49 kinds of part (title bars, balance, sounds, rhythm, tempo, chord, pads, panel memory,
> picture ...) on a grid, a title bar on the row above it.
>
> At boot the firmware checks the `JK` signature of the settings, FAVORITES and HOME PAGE records, and
> rewrites a missing one from defaults in its ROM. The Initial Data Disk's USER MIDI SETTINGs, FAVORITES
> and home-page picture are exactly those defaults; its home-page record differs from the ROM's in one
> byte.
>
> ### A KN6000 CUSTOM file in a KN7000
>
> The KN7000 loads the KN6000's CUSTOM files (`.AST`, `.CST`) and converts them: each One Touch Setting
> grows from 0x90 to 0xA0 bytes, its new bytes taken from a default in ROM, and the record moves to new
> blocks. The old KN6000 records stay in the freed blocks until something overwrites them.
>
> The disassembly rebuilds one real chip byte for byte: the IC21 of the project owner's KN7000, read
> with the instrument's own ROM dumper. Its MIDI settings, favorites and home-page picture are the
> factory ones; its custom panel and home-page layout are his own. Its 20 custom styles are KN5000
> styles that came through a KN6000 CUSTOM file: their One Touch Setting names are the KN5000's Music
> Database titles for each style, retyped (five with other spellings, such as "Metallic Dance" for the
> KN5000's "Metalic Dance"), and three of the KN6000 records are still in the chip's free blocks.
