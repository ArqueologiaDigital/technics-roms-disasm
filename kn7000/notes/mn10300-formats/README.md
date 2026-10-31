# MN10300 data formats: the last open items (lane mn10300-formats, 2026-10-31)

Lane mn10300-formats of the open-items effort. It takes seven open data-format items of
`../../../notes/data-semantics-2026-10-29/README.md` ("Open items"), `../data-final/README.md`,
`../../../kn6000/notes/siblings-data-final/README.md` and `../callee-walk/README.md`. Probes:
`../mn10300-formats-probes/` (README there). Every name below is in a symbol file or a struct-name
table, so the regenerated sources carry it.

## 1. One KN2400 image, three instruments: the model strap

The SX-KN2400 v1.1 program is also the SX-KN2600's (`make gate-kn2400` checks that the KN2600 package
ships the same image) and, the code shows, the PR54's. `KnprModelGet` (0x487055C4, was `func_487055C4`)
reads the board strap halfword at 0x98070000:

| bit 1 (mask 0x02) | bit 0 (mask 0x01) | answer | instrument |
|-------------------|-------------------|--------|------------|
| 1                 | 1                 | 0      | KN2600     |
| 1                 | 0                 | 1      | KN2400     |
| 0                 | 1                 | 1      | KN2400     |
| 0                 | 0                 | 2      | PR54       |

The numbering is the firmware's own: `IvKNPRWinProc` sends the view held at +0x18, +0x1C or +0x20 of an
`IvKNPRWin` record for answers 0, 1 and 2, and that class's field names (`ClassFields_IvKNPRWin`) are
`KN2600`, `KN2400` and `PR54`, in that order (+0x18 is the first field after a Viewable's 24 bytes).
The records agree: `Test4FDorSD_KNPRWin1` sends `TestmenuSD_id` for the KN2600 (the model with the SD
slot) and `Testmenu4_id` for the other two; the title menus send `TT_SDCCMPLDSNGL` for the KN2600 and
`TT_CMPLDSNGL` for the KN2400 / PR54. 61 calls in 51 routines ask the strap.

Five routines pick a Music Stylist list by the answer, the KN2400's for 1 and the other for 0 and 2
(`kn2400_manual.sym`):

| routine (was)                      | KN2600 / PR54 list (count)         | KN2400 list (count)                                       |
|------------------------------------|------------------------------------|-----------------------------------------------------------|
| `MssSetupGet` (func_48641CCD)      | `StyleRecordTable` (720 x 24 B)    | `StyleRecordTableKN2400` (680; was `StyleRecordTableAlt`) |
| `MssSetupIndexGet` (func_48641D02) | `StyleSetupIndexTable` (720 x u16) | `StyleSetupIndexTableKN2400` (684 x u16)                  |
| `MssGenreGet` (func_48641D2F)      | `StyleGenreTable` (11 x 8 B)       | `StyleGenreTableKN2400` (11)                              |
| `MssLetterGet` (func_48641D5E)     | `StyleAlphabetTable` (34 x 8 B)    | `StyleAlphabetTableKN2400` (34)                           |
| `MssEraGet` (func_48641D8D)        | `StyleEraTable` (10 x 12 B)        | `StyleEraTableKN2400` (10)                                |

Both sets point at the same one-touch settings. The record kinds are the KN6000's (`StyleGenre`,
`StyleLetter`, `StyleEra`, `MusicStylistSetup`), with the KN2400's readers in `data_struct_names.py`.
Other strap-chosen tables, not named here because what they hold was not traced:
`func_487019FB_entry_Lf_Table` (KN2400) / `func_487019FB_entry_L29_Table` (the others),
`func_4865F898_Table` (KN2400) / `func_4865F898_Table_2` (KN2600), `func_5015A8CC_entry_L21_Table`
(KN2600 only). Other bits of the strap the KN2400 reads: bit 4 (`func_487055F5`, unreached code), bit 5
(`func_486ED9FA`, `func_486EDBB7`), bit 6 and bit 13 (`func_486ED65E`, `func_486ED59E`), bit 12
(`func_5015A6A0`); the KN7000's strap readers are `TgStrapProbe`, `PanelSubTypeGet`, `PanelGpioSwScan`
(kn7000_manual.sym).

## 2. The KN6000's sound hash tables: the payloads

`hash_payloads.py` shows which payload bytes carry values; the routines that read the payload
(`kn6000_manual.sym`, new names) say what they are. The unread bytes are 0 in every entry and are the
macros' trailing `.space` (`src/include/data_tables.inc`):

| table (lookup)                    | key                                   | payload, from its readers                                                                                                                                                                                                                                                                                                                                           |
|-----------------------------------|---------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ToneKeyHash` (`ToneKeyLookup`)   | bank MSB << 16 \| LSB << 8 \| program | `TONE_KEY_PAYLOAD`: +0 u16 `tone` (`SoundToneIndexGet`; func_4C07BA76 names the sound from it), +2 `icon` (`SoundIconGet`; `MainGetSoundName` answers it for MT_GetSoundIcon), +3 / +4 `swgroup01` / `swgroup23`, +5..+8 `swno0`..`swno3` (`SoundSwNoGet`: the panel switch {group, number} for the reference's state 0..3; `MainGetSoundName` for MT_GetSoundSwNo) |
| `ShortKeyHash` (`ShortKeyLookup`) | a panel switch, group << 8 \| number  | `SHORT_KEY_PAYLOAD`: the bank `msb`, `lsb` and `program` the switch selects (`SoundSwNoBankGet` copies +0 / +1 / +2 to its three outputs)                                                                                                                                                                                                                           |
| `BankKeyHash` (`BankKeyLookup`)   | bank MSB << 16 \| LSB << 8 \| program | `BANK_KEY_PAYLOAD`: the u16 `index` `SoundBankIndexGet` answers                                                                                                                                                                                                                                                                                                     |

So ToneKeyHash maps a sound to its panel switch and ShortKeyHash maps a switch back to the sound.
`swgroup01` takes 0..15 and `swno0` / `swno1` 0..39 (the panel's sound groups), `swgroup23` 0..31 and
`swno2` / `swno3` 0..127 (bank-and-program style numbers) [INFERENCE on what the two pairs of states are].
The KN7000's 'Tone' hash (`gen_table_voices.py`) has the same 12-byte payload; its readers: lane
mn10300-rest (`../mn10300-rest/README.md` section 2), which also replaced the [INFERENCE] on the two pairs of
states: 0 / 1 are the panel SOUND GROUP switch and 2 / 3 the SOUND EXPLORER category, the even one for a part
with a DSP unit (`panel_group`, `explorer_group`, `panel_no_dsp`, `panel_no`, `explorer_no_dsp`, `explorer_no`).

## 3. The KN2400's DSP-effect descriptors

The "1,089 small pieces between effect names" at 0x48439000.. are one structure: 107 effect
descriptors and their 809 parameter records, tiling 0x48439000..0x48440898 (30,872 bytes) with no gap
(`kn2400_fx_desc.py`). `FxDescGet` (0x4863CDEF) answers `FxDescTable[FxDescIndexGet(effect code)]`
(0x4856C74C, 260 pointers); `FxCategoryGet` maps the effect code to one of 15 categories whose jump tables
decide how the index is found.

- `FX_DESC` (16 bytes): `count` records at `params` (right before the descriptor), `nparams` parameter
  numbers (`FxDescNParamsGet`), `mode` (`FxDescModeGet`; `SndUnitDbGroupQuery` searches the parameters for
  1 and 2), `pnum9` / `pnum10` / `pnum11` (a parameter number or -1, read by `FxDescPnum9Get` /
  `FxDescPnum10Get` / `FxDescPnum11Get`; their roles, lane mn10300-rest: `speed_param`, `tempo_param`,
  `drive_param`, and `mode` is `connection`, FX_PARAM `x29` `depth_link`: `../mn10300-rest/README.md` section 1), `send_param` (`FxDescSendParamGet`: the REVERB SEND parameter's number in 106 of
  106, -1 in the reverbs), 3 zero bytes.
- `FX_PARAM` (36 bytes): the name, NUL-padded to 20 bytes; `number`, `min`, `max` (`FxParamNumberGet`,
  `FxParamMinGet`, `FxParamMaxGet`); `band` and `sub` (`FxParamBandGet`, `FxParamSubGet`: 0..4 / 0..2 in
  the EQ's band parameters, frequency / Q / gain); `variant` (`FxParamVariantGet`: 0 and 1 for two
  alternative records of one number, "DEPTH" / "DEPTH (V)", "SPEED FAST" / "SLOW"; 0xFF for one always
  shown); `x29` (`FxParamX29Get`); 2 zero bytes; `values`, the value texts ("    0 ms" ...;
  `FxParamValuesGet`).

`gen_data_s.py fx_descriptors()` (profile key `fx_descriptors` = 260, the KN2400 only) writes them, one
line a record. The KN7000's `SndUnitDbGroupQuery` / `SndRec*` routines are the same family
(`kn2400_ported.sym`), but the KN7000's records are not this layout. The 20 KB of
`7c aa aa 7d 55 55 ...` streams at 0x4853C5BE..: the effect DSP's programs, parameter scripts and address
maps, read through four pointer tables (lane mn10300-rest, `../mn10300-rest/README.md` section 1, typed by
`gen_data_s.py fx_streams()`).

## 4. KssBgScreen's `image_id` and `icon` (the SP7001 plug-in)

`kss_bgscreen_ids.py`:

- `icon` (1 in every record) is 942's icon index. `KssBgScreenProc` (0x483E9060) answers its +0x30 for
  `MT_GetIcon` (0x000600B8), which 942's `TtlScreenProc` sends and passes to `DrawTitleBar` ->
  `DrawTitleBarOW` -> `DrawIcons`, entry 1 of `IconTablePtr`'s table = the table flash's `ResIconTable[1]`,
  `ResIcon001` (`src/table/gui/icon_001.png`, the icon 942's own `TtSoftver` / `TtDebug` screens show).
  The resource-id trie also holds an id 1, but this field never reaches `func_4C01BB1A`.
- `image_id` (0x8068 in every record) is read by nothing: no access of the plug-in's code at (0x28, aN) is
  16 bits wide, `KssBgScreenProc` reads +0x2C and +0x30 only, and 942's `Screen` class (40 bytes) ends
  before it. 0x8068 is no id of 942's trie. Read as a Slide Show picture code (0x8000 + n), n = 104 would
  be past the 100 presets that `func_48580A70` accepts [INFERENCE: a field the plug-in's authors did not use].

The plug-in's records now say both in their comments (`gen_data_s.py` profile key `field_notes`).

## 5. The "demo-song streams" are the alphabetical sound lists

`func_485831BA_Table`'s three lists are no demo songs. `SoundAlphaIndexBuild` (0x485831DC) reads +0 of
each 4-byte entry, groups the entries by that byte with the C library's ctype table (letters first,
then digits), and `SoundAlphaInitialGet` (0x485834C0) matches +1 / +2 / +3 against a sound's bank MSB, LSB
and program and answers +0. So an entry is {char initial; u8 bank MSB, LSB, program}, a list ends with a
zero entry, and `SoundAlphaListGet` (0x485831BA) picks one of `SoundAlphaListTable`'s 6 pointers by kind
(the sound group: 0x19 / 0x1A drum kits, 0x13..0x1E, the rest) and a variant. The four lists (941):

| label                             | entries | selected for                       |
|-----------------------------------|---------|------------------------------------|
| `SoundAlphaList_Groups00_12`      | 1,236   | groups 0..0x12 and 0x1F, variant 0 |
| `SoundAlphaList_Groups00_12_Var1` | 1,215   | the same groups, variant 1         |
| `SoundAlphaList_Groups13_1E`      | 1,210   | groups 0x13..0x1E but 0x19 / 0x1A  |
| `SoundAlphaList_DrumKits`         | 41      | groups 0x19 and 0x1A               |

`gen_data_s.py sound_alpha_lists()` writes one `SOUND_ALPHA "A", 121, 2, 120` line an entry (the four
KN7000 program builds; the siblings have no such lists). Variant 1 is chosen when `func_484974A4` answers
0 for the group [INFERENCE on what it tests]. The real demo-song streams are the inflated ones at
0x50000C20 / C50 / C80 (`../work-ram-map.md`).

## 6. zlib's tables

`zlib_tables.py` finds 19 of zlib 1.0.4's tables by their contents in every KN7000 build and in the
KN6000, KN6500 and KN2400 (the HD-SX3 plug-in has no zlib): `configuration_table`, `extra_lbits`,
`extra_dbits`, `extra_blbits`, `bl_order`, `static_l_desc` / `static_d_desc` / `static_bl_desc`,
`static_init_done`, `border`, `cplens`, `cplext`, `cpdist`, `cpdext`, `fixed_built`, the two copyright
strings, `inflate_mask` and `z_errmsg`. They are named in `kn7000_manual.sym` (ported by `make symbols-sp7001
symbols-935 symbols-893` to the other three builds' manual files) and in `kn6000_manual.sym`,
`kn6500_manual.sym` and `kn2400_manual.sym`, at their RAM addresses (the initialised-RAM image).

## 7. Field names from their use

`tools/data_field_uses.py` follows the register a field's reading instruction loads through the next
instructions (and into the routine it is handed to, two levels deep), and `data_struct_names.auto_name()`
names the field after what is done with it: `proc`, `text`, `key`, `count`, `index`, `flags`, `kind`, a
parameter name of a known routine (`view`, `title`, `event`, `object`, `icon`, `size`, `param_key` ...),
`<Routine>_<reg>` for another named routine, or a constant's family (`event`, `message`, `title` ...).
The curated names of `data_struct_names.py` still come first; a field whose places of reading disagree,
or whose use the linear walk does not see, keeps its offset name.

Measured with `../mn10300-formats-probes/field_names_census.py` on the lane's base (f4045a81c) and after
the regeneration (count of record-macro fields in each tree's `data_structs.inc`; "with a reader" leaves
out the bytes no reader touches, which have nothing to be named from; the "no reader" column fell because
the passes above typed the effect records, sound lists and zlib tables those kinds held):

| tree       | kinds before | kinds after | fields after | named before | named after | offset-named with a reader, before | after |
|------------|--------------|-------------|--------------|--------------|-------------|------------------------------------|-------|
| kn7000-941 | 571          | 569         | 1,436        | 31           | 601         | 893                                | 628   |
| kn7000-942 | 573          | 571         | 1,446        | 30           | 605         | 898                                | 630   |
| kn7000-935 | 573          | 571         | 1,440        | 26           | 599         | 901                                | 634   |
| kn7000-893 | 573          | 571         | 1,440        | 26           | 600         | 901                                | 633   |
| kn6000     | 513          | 512         | 1,330        | 30           | 525         | 1,156                              | 668   |
| kn6500     | 513          | 512         | 1,331        | 30           | 523         | 1,156                              | 670   |
| kn2400     | 515          | 514         | 1,281        | 36           | 524         | 1,111                              | 622   |
| hdsx3      | 19           | 19          | 58           | 0            | 8           | 46                                 | 43    |

The names given most (941): `proc` 337, `key` 116, `index` 44, `text` 20, `TgVoiceRegWrite_d0` 13,
`TgVoiceRegWriteB_d0` 9, `flags` 7. What is left offset-named: fields whose reading instruction occurs more
than once in its function with different uses (the walk cannot tell which place the access was), values
stored to the frame and used later, and values whose only use is arithmetic. The KN7000 IC21 structures of
lane ic21-own (`../ic21-own/README.md`) were not taken up here.

## Census

`scripts/analysis/data_incbin_census.py` (read-only; opaque n / bytes, base -> this branch; generic is 0 in
every tree before and after): kn7000-program 3,449 / 63,392 -> 3,448 / 63,227, kn7000-sp7001 3,472 / 61,662
-> 3,471 / 61,497, kn7000-b893 3,454 / 63,075 -> 3,453 / 62,910, kn7000-b935 3,460 / 64,185 -> 3,459 / 64,020
(the drum-kit list's 165 bytes), kn2400 5,131 / 196,924 -> 4,448 / 172,071 (the effect records), kn6000,
kn6500 and hdsx3 unchanged.

## Regenerating

(In a worktree, with the absolute Makefile overrides and `UNIDASM=`.)

1. `make -C kn2400 data-and-code-src`, `make -C kn6000 data-and-code-src`, the same for `kn6500` and then
   `hdsx3` (its host is the KN6000);
2. `make -C kn7000 symbols-sp7001 symbols-935 symbols-893 SYMOUT=<scratch>` and copy the three
   `kn7000_*_manual.sym` it writes;
3. `python3 tools/gen_program_s.py --profile <b>` for 941, sp7001, b935 and b893, then `make -C kn7000
   data-and-code-src` to the fixpoint, then `make -C kn7000 plugin-src`.
   The fixpoint reads the previous build's `build/*.labels`; after it, build the four programs
   (`make -C kn7000 verify verify-sp7001 verify-935 verify-893`) and run `make -C kn7000 data-and-code-src`
   once more: it must stop after its first round with nothing changed.

## Shared files touched

`kn7000/tools/gen_data_s.py` (passes `sound_alpha_lists`, `fx_descriptors`, `zlib_tables`, the
`hash_tables` payloads and a late-binding fix there, profile keys `fx_descriptors` / `field_notes`, a comment;
and one line of the core `ref()`: a code address the data names by its `func_<ADDR>` label is kept in
`code_refs.txt`, as a `loc_<ADDR>` one already was -- without it 935 / 893 lost `func_484082C2`, the task
entry a `T_CTSK` record names, once the previous build's labels gave that name), `kn7000/tools/data_structs.py` (layout keeps
the records' offsets; `name_fields` asks `auto_name`), `kn7000/tools/data_struct_names.py`,
`kn7000/tools/data_field_uses.py` (new), `kn7000/src/include/data_tables.inc` (macros `SOUND_ALPHA`,
`TONE_KEY_PAYLOAD`, `SHORT_KEY_PAYLOAD`, `BANK_KEY_PAYLOAD`, `FX_DESC`, `FX_PARAM`), the manual symbol
files of kn7000 (and the three ported ones), kn6000, kn6500 and kn2400.

## Website page draft

(For the KN2400, KN6000 and KN7000 data pages of technics-docs, to be added by the website sync.)

> **One program, three instruments.** The SX-KN2400 and SX-KN2600 run the same program image, and so
> does the PR54. Two straps on the board, bits 0 and 1 of the halfword at 0x98070000, tell it which
> instrument it is: both set for the KN2600, one for the KN2400, none for the PR54. Sixty-one places in
> the program ask: the KN2600's SD-card screens, the menus, and the Music Stylist, which has a list of 720
> setups for the KN2600 and PR54 and one of 680 for the KN2400, each with its own genre, alphabet and era
> indexes.
>
> **The KN6000's sound tables.** Without a voice archive loaded, the KN6000 finds a sound's tone, icon
> and panel button through a hash table keyed by its bank and program numbers, and a panel button's
> sound through a second one keyed by the button; the disassembly names each field from the routine
> that reads it.
>
> **The KN2400's effects.** Each DSP effect is a 16-byte descriptor and a list of 36-byte parameter
> records: name, number, range, EQ band, an alternative for the vocal "(V)" or fast / slow setting, and
> the texts its values are shown with. 107 effects, 809 parameters, one line each in the source.
>
> **The KN7000's alphabetical sound lists.** The sound search lists every sound by its initial with the
> bank and program numbers that select it: about 1,200 sounds in three lists and 41 drum kits.
