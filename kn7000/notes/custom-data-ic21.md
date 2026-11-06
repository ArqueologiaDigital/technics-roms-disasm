# The custom-data flash: the CUSTOM STYLE memory (KN7000 IC21, KN6000 / KN6500 IC18)

Written 2026-10-29, lane `customdata` of the data-semantics effort
(`notes/data-semantics-2026-10-29/README.md`).

The KN7000's IC21 is a 2 MB flash at `0x96800000`. Its upper 1,966,080 bytes (`0x1E0000`,
60 blocks of 32 KB), the bank at `0x96820000`, hold the **CUSTOM** style source: 20 slots, each
a custom style together with its four ONE TOUCH SETTING panel memories, its performance pads and
the user sounds it needs. The owner's manual (p.120) describes CUSTOM as 20 styles copied in from
COMPOSER MEMORY. The Initial Data Disk resets it to the factory set (p.137). The KN6000 and KN6500
have the same bank at the same address on their IC18, written by the same firmware module.

This lane gives byte-exact, typed sources for the ten factory banks that exist:

| image (reference)               | floppy (MAME softlist)  | file           | SHA-1 of the bank                          |
|---------------------------------|-------------------------|----------------|--------------------------------------------|
| KN7000 `01ctmini.ic21`          | `kn7000_flop` `idd7000` | `01CTMINI.AST` | `67b2a0fe8154c4d15557399a86bf0d0b49813ced` |
| KN7000 `01custm1.ic21`          | `kn7000_flop` `custom1` | `01CUSTM1.AST` | `4cd5fe37871984a4b470b1a12b835c9bc41f37f5` |
| KN7000 `02custm2.ic21`          | `kn7000_flop` `custom1` | `02CUSTM2.AST` | `6c85b616a9acc3a7ecc1b49a70f138c0d9442086` |
| KN7000 `03custm3.ic21`          | `kn7000_flop` `custom1` | `03CUSTM3.AST` | `d5722a1129134383bf643d20b4e0866c3089fc36` |
| KN7000 `04custm4.ic21`          | `kn7000_flop` `custom1` | `04CUSTM4.AST` | `25822a3ad726df49882cdd0066424600fb70ea14` |
| KN7000 `01custm5.ic21`          | `kn7000_flop` `custom2` | `01CUSTM5.AST` | `11d32c3d293a23a511a76297647758046cd8ccc9` |
| KN7000 `02custm6.ic21`          | `kn7000_flop` `custom2` | `02CUSTM6.AST` | `54f2bac0551a8d43dc1a87fe24a13c545169a326` |
| KN7000 `03custm7.ic21`          | `kn7000_flop` `custom2` | `03CUSTM7.AST` | `e1bdfbbbe78353003af5ed01866be87d799523bb` |
| KN7000 `04custm8.ic21`          | `kn7000_flop` `custom2` | `04CUSTM8.AST` | `f4722d93ff3f31c6d8c25f757968d796e4eb57ca` |
| KN6000 / KN6500 `01ctmini.ic18` | `kn6000_flop` `idd6000` | `01CTMINI.AST` | `8c6d62a8afab717a2b59e9242bbf897b01369416` |

The SHA-1s are those of the images in the private romsets (`technics_romsets/kn7000/*.ic21`,
`technics_roms/roms/kn6000/01ctmini.ic18`, which equals `kn6500/01ctmini.ic18`). The Makefiles
make the references from the floppies, not from the romsets: `unzip` the disk, extract the
`.AST` with `tools/fat12_extract.py`, inflate it with `tools/ast_file.py`, check the SHA-1. The
floppy images are those of the 2026-10-18 rebuild (`SOFTLIST_DIR`).

    make -C kn7000 verify-customdata       # 9 banks, in make gate-kn7000
    make -C kn6000 verify-customdata       # 1 bank, in make gate-kn6000
    make -C kn7000 verify-customdata-ast   # the 9 .AST files rebuilt from the banks (not in the gate)
    make -C kn6000 verify-customdata-ast
    make -C kn7000 customdata-src          # regenerate src/customdata/ (tools/gen_customdata_s.py)
    make -C kn6000 customdata-src

Felipe's own IC21 read (`real_dump_v1.3_b893`, PROGRAM 893) was at first kept out of the trees as
personal data. On 2026-10-31 the owner decided to add it. `kn7000/src/ic21own/ic21.s` now types the
whole 2 MB chip, this bank included, with this lane's generator (`gen_customdata_s.py --base 0x20000
--part`) and macros (`make verify-ic21-own`; [`ic21-own/README.md`](ic21-own/README.md)). Its CUSTOM
bank holds KN5000 styles loaded from a KN6000 file: the firmware's KN6000-to-KN7000 conversion
(`func_48485B52`, see "Loading a KN6000 file" below) shaped all 80 of its settings, left three
KN6000-layout records in free blocks and, in two slots, a `+0xA4` that differs from the directory.

Addresses of routines are KN7000 program 941's (`kn7000/src/program/region1_04.s`, names from
`kn7000_manual.sym`). `[INFERENCE]` marks a reading that no traced code fixes.

## The sources

| path                                            | what                                                                 |
|-------------------------------------------------|----------------------------------------------------------------------|
| `kn7000/src/customdata/customdata.inc`          | the record macros, one per record kind, every known field named      |
| `kn7000/src/customdata/<image>.s`               | the bank: the directory, then per block an include, residue or fill  |
| `kn7000/src/customdata/<image>/SlotNN.inc`      | slot NN's record, fully typed, events one per line                   |
| `kn7000/src/customdata/<image>/StaleNN.inc`     | a complete older record in free block NN, typed the same way         |
| `kn6000/src/customdata/01ctmini.s`, `01ctmini/` | the KN6000 bank, same macros (`--model kn6000`)                      |
| `kn7000/tools/gen_customdata_s.py`              | the generator; it models every macro's bytes and stops on a mismatch |
| `kn7000/tools/ast_file.py`                      | `.AST` inflate (references) and deflate (rebuild)                    |
| `kn7000/tools/zlib10_deflate.py`                | the programs' zlib 1.0.4 deflate, ported to Python                   |

## The directory (block 0)

Module status `*(0x50001298)`: `func_48484499` runs at boot. When `FlashReadAutoselect` fails it
sets -1 (no custom flash: every fetcher returns NULL). When the bank does not start with `"IK"`
it builds an empty directory in the RAM shadow `0x5037A000` (0x6000 bytes of 0xFF, the
signature, all slots `{0, 0}`, all blocks free, block 0 used) and programs it with
`FlashProgram128Words`.

| offset  | size   | field                                | read / written by                                                            |
|---------|--------|--------------------------------------|------------------------------------------------------------------------------|
| `+0x00` | 2      | `"IK"`                               | `func_48484499` (check), `func_48483F35` (write)                             |
| `+0x02` | 20 x 2 | slot: first block (0 = empty), count | `func_48483F53` / `func_48483F82`; setters `func_48483F6D` / `func_48483F9C` |
| `+0x2A` | 60     | block map, 1 = allocated             | `func_48483FB4`, set `func_48483FC6`, clear `func_48483FDA`                  |
| `+0x66` |        | 0xFF to `0x6000`, erased to `0x8000` |                                                                              |

A block `b` is at `0x96820000 + (b << 15)` (`func_48483FED`); a slot's record is at its first
block (`func_48483FFC`). The allocator `func_484843A4` looks for free runs in the map; the
saver `func_484857AF` writes the slot descriptor and marks the blocks. In all ten images every
slot is used, its block count is `ceil(size / 0x8000)`, and the map is exactly block 0 plus the
slots' blocks (`custom-data-ic21-probes/layout_check.py`).

## The slot record

Built by the MEMORY -> CUSTOM save `func_484854E3` in RAM (`0x5031C000` or `INSTALL_SCRATCH`
`0x502B8000`), then programmed to its blocks. All little-endian.

| offset           | field                                                      | evidence                                                                                             |
|------------------|------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| `+0x00`          | u32 record size = `0x100` + the sections                   | `func_4848403C`; `func_4848512E` sums the sections                                                   |
| `+0x04`          | 16-byte style name                                         | `func_48484049`; written by `func_4C021AF8`                                                          |
| `+0x14..+0x44`   | four 16-byte ONE TOUCH SETTING names                       | `func_4848407B` / `B1` / `E7` / `1D`; written by `func_4C021B53`                                     |
| `+0x54..+0x7C`   | five `{u32 offset, u32 count}`: 0x42-byte records          | `func_48484153`..`func_48484257`; counts from item bitmasks 0-9, 10-14, 15-34, 35-44, 45-54          |
| `+0x7C`          | `{offset, count}` of 0x2C8-byte SOUND EDIT records         | `func_48484266` / `func_4848428E`; `CustomSoundEditRecFetch` 0x484845E1                              |
| `+0x84`          | `{offset, count}` of the 0x48A7-byte custom-sound block    | `func_4848429E` / `func_484842C8`; `CustomVoiceRecFetch` 0x4844A42F                                  |
| `+0x8C`          | `{offset, size}` of the 4 one-touch-setting panel memories | `func_484842D8`; record size from `func_4C02AD02` (0xA0)                                             |
| `+0x94`          | `{offset, size}` of the "TCMP" style container             | `func_48484305`, `CustomStyleBlockFetch` 0x48484578                                                  |
| `+0x9C`          | `{offset, size}` of the "TPAD" pad container               | `func_48484332`, `func_4848435C`                                                                     |
| `+0xA4`, `+0xA5` | first block, block count (as in the directory)             | equal to the slot descriptor in all 200 live records; not in 2 of Felipe's 20 (`func_48485B52`)      |
| `+0xA6..+0xFF`   | RAM residue of the build buffer                            | `[INFERENCE]`: debug strings ("TITLE : TT_RVARI", "MODE  : MD_NORMAL"); no accessor reads past +0xA4 |

The sections follow the header in that order with no gap. In the factory sets only one record
has a dependency section: a custom-sound block (`count 1` at `+0x88`). The custom-sound block is
a 0x27-byte header, 128 `{program, bank LSB, bank MSB}` references at `+0x27` and 128 voice
records of 0x8E bytes at `+0x1A7` (`CustomVoiceRecFetch`; 0x27 + 384 + 128 x 0x8E = 0x48A7).
It sits in `03custm3` slot 7 and is a user drum kit (header name "User Kit"; voice names such as
"Electric SD", "Snare Drum 2", "Silent" for unused keys).

**The block is a TABLE tone** (lane kn7000-research2, 2026-11-06; `CSOUND_HEAD` in
`src/customdata/customdata.inc`).  For a part whose sound is the custom kit (bank kind 0x19,
941 `0x48448D4D`) `func_4844A413` returns the block, and the tone library stores it as the part's tone
record (tone block `0x500CE404 + part * 0x130`, library `0x4C0390E8`), the pointer `TgPartToneDescPtr`
returns.  So the 0x27-byte header is a tone record's head: the 16-character name, the class `+0x10`
= 0x40 (TABLE, the class `TgNoteOn` 0x4C036832 sends to `TgNoteOnTableTone`), then 22 bytes.  It is
byte for byte the head of 20 of the table flash's 52 TABLE tones (its kits), Standard Kit1 among them
(`custom-data-ic21-probes/kit_tone_census.py`).  `TgNoteOnTableTone` 0x4C03600D reads the 3-byte
entry at `+0x27 + note * 3`, so the 128 references are **one per MIDI note**.  It also tests the voice
record's `+0x0D`: bit 0 stages layer 0 and bit 2 layer 1.  The user kit's 128 records hold 0x01 (121),
0x05 (3) and 0x21 (4), and the archive's 1,618 records hold the same values plus 0x25.  The head's `+0x11`
is the **key map**: `func_48449462` reads tone record `+0x11` (through `func_484495E8`), and when it is
below 7 it maps a played key through one of the seven tables `func_48449462_Records`.  This happens
only when M3 0x2025 is 1, for `KeyZoneNoteResolve` 0x484516EC.  The factory kits use 0..6, and the User
Kit uses 1, like Standard Kit1.  The other 21 head bytes have no traced reader.

**Voice records** (`kn7000/src/include/voice_record.inc`). The 0x8E-byte record of the tone
generator's voice-resource banks, the same unit `VoiceRecFetchBanked` 0x484496C9 returns and
`TgPartLocalEditRecPtr` 0x4C00C2C8 shadows: a 16-byte header (13-byte name; `+0x0D` is the layer
mask: `VoiceSubRecFetch` 0x4844978B passes it with the layer number to func_484494E2, which returns that
layer's sub-record index or 0xFF = none -- bit 0 enables layer 0, bit 2 layer 1, see the user kit above;
this sentence said until 2026-11-06 that the byte itself picks the sub-record), two 0x1C-byte sub-records at `+0x10`
(`VoiceSubRecFetch`: `+0x10 + n*0x1C`) and two 0x23-byte element records at `+0x48`
(`TgPartLocalEditElemRecPtr` 0x4C00C2F9). `VOICE_HEAD`, `VOICE_SUB` and `VOICE_ELEM` type each
part; the sub-record and element fields keep neutral names (offset in the sub-record), since no
reader of single fields was traced. No floppy lane has typed a KN6000/KN7000 sound file yet; the
include is meant for those too.

**One touch settings** (`kn7000/src/include/panel_memory.inc`, shared with the floppy
describers). Four records of 0xA0 bytes (KN6000: 0x90), one per ONE TOUCH SETTING. The save builds
them with library `func_4C02A0C4` (KN6000 `func_4C04B9F8`) from four consecutive PANEL MEMORY
records, the 0x750-byte records of the backup-SRAM store at `0x84000824 + bank*0x3A90 + 0x10 +
i*0x750` (KN6000: 0x700-byte records at `0x840007D2 + bank*0x3810 + 0x10 + i*0x700`). Each field
is copied as `source & mask` through a table of `{source offset, destination offset, mask}`
triples (KN7000 program 0x4858E19C..; the KN6000's 0x4C19AB04.. holds the same bytes, minus the
last table). `panel_memory_map.py` prints the tables. The record, KN7000 offsets:

| offset                  | macro          | source (panel-memory record)                                      | traced fields                                                                                                                                                              |
|-------------------------|----------------|-------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `+0x00` `+0x1A` `+0x34` | `PM_PART`      | part 0..2 at `+0x16 + part*0x4A`, 26 fields                       | `+0..+2` the part's sound {program, bank LSB, bank MSB}: `func_4C02B2FE` classifies it and the writer substitutes the CUSTOM copy's reference for a user sound or kit      |
| `+0x4E`                 | `PM_ENTRIES`   | byte 0 of the eight 6-byte entries at `+0xF4`                     |                                                                                                                                                                            |
| `+0x56`                 | `PM_PART`      | part 3 at `+0x2E0` (KN6000 `+0x296`)                              | as above                                                                                                                                                                   |
| `+0x70`                 | `PM_STYLE`     | 7 fields from `+0x6B6` (`+0x66C`)                                 | `+0x70..+0x72` the style, `func_4843E452(slot)` = slot OR 0x200000, low byte first (also restamped by `func_484859D8` on load); `+0x74` bits 4-5 the setting's number 0..3 |
| `+0x77`                 | `PM_SET77`     | 3 fields from `+0x6C6` (`+0x67C`)                                 |                                                                                                                                                                            |
| `+0x7A`                 | `PM_FX`        | 14 fields from `+0x6D0` (`+0x686`)                                | six 14-bit ids re-mapped by `func_48413686` (kinds 0, 9, 1, 2, 3, 4) when they name user data; `[INFERENCE]` effects                                                       |
| `+0x88`                 | `PM_SET88`     | 4 fields from `+0x700` (`+0x6B6`)                                 |                                                                                                                                                                            |
| `+0x8C`                 | `PM_SET8C`     | 2 fields from `+0x716` (`+0x6C6`); the second via `func_484417B9` |                                                                                                                                                                            |
| `+0x8E`                 |                | not written                                                       |                                                                                                                                                                            |
| `+0x8F..+0x9A`          | `PM_PART_TAIL` | KN7000 only: part `+0x23` (mask 0x07), `+0x38`, `+0x39`, x4       |                                                                                                                                                                            |
| `+0x9B..+0x9F`          |                | 0xFF (KN6000: `+0x8E..+0x8F`)                                     |                                                                                                                                                                            |

Parameter names (since lane kn67-field-names, 2026-10-29) are the panel-memory parameters the
source bytes belong to, the same names as the `PMR_*` macros: a panel-memory record is the image of
the live panel state (library `func_4C021F33` recalls one with `memcpy(0x84000020, memory, 0x750)`
and `func_4C01F98B`), and each live parameter is reached by id through `ResourceIdTrie` (block = the
record's tag, offset, mask). So `PM_PART` holds the part's sound, volume, effect depths, portamento,
CC80-83, pan, tuning and drawbars; `PM_ENTRIES` the eight accompaniment volumes; `PM_STYLE` the
rhythm, TECHNI-CHORD on (`[INFERENCE]`), the variation (parameter 0x00C004, VARIATION 1-4: setting i
selects variation i) and the tempo; `PM_SET88` tremolo, TECHNI-CHORD part and type; `PM_SET8C` the
pad bank. The fourth part (`+0x56`) is tag 0x03, PART 4, on both models. Evidence and the unnamed
remainder: `notes/data-semantics-2026-10-29/kn67-field-names.md`. Two observations fix what wrote the factory files:

- No stored byte breaks a mask, except that **all 80 KN6000 settings have part 3 all 0xFF**
  (880 bytes outside their masks): the v7.1 writer copies part 3, so these were written by an
  earlier one.
- **Program 941's part tails at `+0x8F`** are missing from 76 live settings of `01ctmini` (their `p23`
  exceeds the mask 0x07) and from none of the other eight factory banks' live settings; with the stale
  records, the generator counts 135 such settings over the nine banks. Programs 893 and 941 have the
  same writer and the same field-map tables (`ic21-own-probes/ots_origin.py`), so those bytes come from
  a writer older than program 893. Those 13 bytes are spelled as plain bytes with that comment; the
  rest use `PM_PART_TAIL`.

**Loading a KN6000 file** (lane ic21-rest, 2026-10-31). AstLoadHandler (`.AST`, all 20 slots) and LoadCst
(`.CST`, one slot) check the file's signature with `func_4852B746`, which returns 1 for a KN7000 file and
3 for a KN6000 one. For 3 they call `func_48485E55` (every slot) or `func_48485E79` (one), which run
`func_48485B52` on the slot:

1. it copies the record's 0x100-byte header to `INSTALL_SCRATCH`, then the dependency sections;
2. for each of the four settings it copies the 0xA0-byte default `func_48485B52_Block`, then the KN6000
   setting's 0x90 bytes over it, so `+0x8E..+0x8F` keep the KN6000 record's FF FF and `+0x90..+0x9F` are
   the default's (`PM_KN6000_END`, `PM_CONVERT_TAIL` in `panel_memory.inc`);
3. it grows the record size by 0x40 and the settings section to 0x280, copies the TCMP and TPAD
   containers, allocates blocks for the bigger record (`func_484843A4`) and installs it (AstHeaderIngest).

The header keeps the KN6000 record's `+0xA4`/`+0xA5`, and the old record stays in its freed blocks. Felipe's
bank shows all of it: its 80 settings have exactly that shape, two slots keep the old block number, and
free blocks 22, 24-25 and 26-27 hold three complete records in the KN6000 layout, two of them the
originals of those two slots (`Stale22`, `Stale24`, `Stale26` of `src/ic21own/custom/`).

## The "TCMP" style container (N = 1)

The CUSTOM container is the MEMORY style area's layout with one style (`MemStyleExportToCustom`
0x4843DEC7). It is described in `kn7000_manual.sym` (section `"TCMP" STYLE CONTAINER`) and
`notes/tcmp-container-synthesis.md`; this lane confirms it on 200 records. Big-endian.

| offset    | field                                                                                                      |
|-----------|------------------------------------------------------------------------------------------------------------|
| `+0x00`   | `"TCMP"`, `00 00`; the checksum descriptor `[0x06,0x10)` zero (the export clears it)                       |
| `+0x10`   | u24BE container length; `+0x13` u24BE allocator top: both equal the size here                              |
| `+0x16`   | u16BE style count 1; `+0x18` the ROM template's tail `00 60 0D 08 04 02 02 01 02 0F`; 64 spaces at `+0x30` |
| `+0x70`   | style record, 0x80 bytes: name, four variation-name fields, indices 0..19, the DSP-unit keys at `+0x70`    |
| `+0xF0`   | 20 variation records of 0xE0 bytes                                                                         |
| `+0x1270` | the 20 event streams, contiguous, the last ending at the container's end                                   |

A variation record: the source built-in style `+0x00..+0x02`, pair flag `+0x03` (bit 4), eight
per-part bytes `+0x04`, bars `+0x10` and meter `+0x11` (`MemStyleVarBarCount` 0x4843C445), the
stream offset `+0x15`, the DSP units' parts `+0x18` / `+0x19`, then eight part set-ups of 0x18
bytes at `+0x20`.  Traced 2026-11-06 (lane kn7000-research; counts by
`custom-data-ic21-probes/tcmp_var_fields.py` over the nine factory banks, 180 styles, 3,600
variations):

- **`+0x00..+0x02`: the built-in style the variation was copied from.** `func_4843B386`, which
  copies a built-in variation into a MEMORY style (`StyleBuiltinNameResolve`, `func_48433D88`),
  writes `key & 0x7F`, `key >> 7` and 0, and also copies the built-in bars, meter and `+2` / `+3`;
  `func_4843511C` reads variation 0's three bytes back as `((b1 << 8 | b0) & 0xF00) >> 1 | b0 & 0x7F`
  and passes that key to `func_4843B386` for each of the 20 variations.  0 0 0 in 2,553 variations
  (written from scratch); otherwise e.g. `58 02 00` (465 times).  `+0x02` is 0 in all 3,600.
- **`+0x18` / `+0x19`: the style parts that the DSP units EFF4 / EFF5 apply to**, 0xFF = the
  default (Acc1 / Acc2).  `StyleRecordBindMem` 0x4843374A and `StyleRecordBindCustom` 0x484337D0
  store `var + 0x18` in 0x50122DD4, the pointer `func_48442164` reads (a built-in variation's
  `+2` / `+3`, `ic18-rhythm-rom.md` "A variation record"); `FF FF` in 3,380, otherwise parts 1..7.
- **The style record's `+0x70..+0x73`: the two DSP-unit preset keys**, a built-in style's
  `style_units` (`+0x0D` there).  `StyleNameCommitMem` / `StyleNameCommitCustom` store
  `record + 0x70` as the units pointer 0x50034C20, which `StyleDspUnitsApply` 0x484420EF decodes
  (`StyleDspKeyDecode` 0x484420C8) into the keys of EFF4 (0xB044) and EFF5 (0xB054), bit 7 of
  `+0x71` = TOTAL MODE (0xB001); `func_4843A47C` copies a built-in style's four bytes there.  132 of
  the 180 live styles have `10 00 23 00` (keys 0x0010 / 0x0023), 18 have 0x0044 ("Limiter1") twice.

**Part set-up (`PART_SETUP`).** The 0x18-byte block is laid out like the 24 fields of the
part-field table 0x485B77D4, in its order: `B0 FF`, CC7, the program change's three bytes, CC94,
CC91, CC93, CC10, CC96, CC82, CC83, CC80, CC81, CC92, CC64, CC1, CC11, channel pressure, pitch
bend (two bytes), CC16, CC17, CC13. The table has exactly 24 entries. The first 15 fields are the
built-in styles' 15-byte part set-up, whose reading the kn7000-ic18 lane traced
(`notes/ic18-rhythm-rom.md`): mode, volume, program/bank, CC94 = 64 and CC96 = 12 hold here too.
The reader (2026-11-06): `StyleRecordBindMem` / `StyleRecordBindCustom` put `var + 0x20 +
k * 0x18` in 0x50034BAC[k] (`StylePartSetupPtrGet` 0x48433F13), and `StyleTemplateLoadParts`
0x4844187A copies **15** bytes of each into the part template 0x5003A37C, whose fields
`StylePartFieldEmit` 0x4844085D sends as the table says.  So the first 15 fields are read in the
table's order; bytes 15..23 are never read, and they are 0 in all 28,800 factory set-ups (the
firmware's default template 0x485B7804 has 0 0 127 0 0 64 64 64 64 there), so their names stay an
inference from the stride.

**Event streams.** `[index][u24BE count][events]`: the index is the variation number
(`MemStyleAreaStreamsVerify` 0x4843579E rejects any other), the count excludes the 4-byte
header, the events run from a 0xF4 beat marker to 0xF5. Event lengths are `RhyEventLenByStatus`
0x484403D5 / `RhySysexLen` 0x484403CD. All 5,200 streams of the live records (TCMP and TPAD, ten
images) parse to their exact ends: 806,516 events, 2,979,536 bytes; no data byte >= 0x80, every
position byte 0-95 (`custom-data-ic21-probes/stream_census.py`).

| event           | macro       | count   |
|-----------------|-------------|---------|
| `9n` 5 bytes    | `ev_note`   | 398,918 |
| `00-5F`         | `ev_at`     | 261,177 |
| `F4`            | `ev_beat`   | 57,034  |
| `En` 2 bytes    | `ev_bend`   | 49,467  |
| `Bn` 2 bytes    | `ev_cc`     | 31,240  |
| `F5`            | `ev_end`    | 5,200   |
| `F0 04` 4 bytes | `ev_sysex4` | 3,290   |
| `Cn` 3 bytes    | `ev_pc`     | 188     |
| `Dn` 1 byte     | `ev_press`  | 2       |

The macro names and parameters are those of `src/ic18/rhythm.s` (lane kn7000-ic18), whose reading
of the note's last three bytes (gate, rule) is `[INFERENCE]` there too. Every SysEx in these sets
is `F0 04 02 08 02 08` or another 4-byte one.

## The "TPAD" performance-pad container (N = 1)

The PERFORMANCE PAD user memory's layout (`MemPadAreaLoadFactory` 0x48432175; the MEMORY area at
`0x501F91A0`, accessors `func_4843873A` / `func_48438752` / `func_48438791`) with one bank:

| offset   | field                                                                                                                                         |
|----------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| `+0x00`  | `"TPAD"`, `00 00` (`func_48438871`), descriptor zero, length / top u24BE, count 1, template tail `00 60 10 06 10 02 00 00 00 0F` (0x48729858) |
| `+0x70`  | bank record 0x30: 16-byte name ("User Bank 1"), six `{bank, pad, 0x20}`                                                                       |
| `+0xA0`  | six pad records of 0x60: name, 13 setting bytes, u24BE stream offset `+0x1D` (`func_484387A9`), two part set-ups at `+0x28`                   |
| `+0x2E0` | six event streams, same format, index = pad                                                                                                   |

`func_484388C6` checks each MEMORY pad stream (opens with 0xF4, ends with 0xF5, `stream[0]` the
index) and `func_484385DD` sets bits 2/3 of `+0x1A` for pads 4 and 5.  Of a pad record's thirteen setting bytes
(`+0x10..+0x1C`) the user-pad module reads four (2026-11-06, lane kn7000-research): `+0x13` RECORD
KEY / CHORD (`UserPadRecChordGet`), `+0x18` measures - 1 and `+0x19` beats - 1 (the firmware's
`MainPAD_SetUserPadMsrTmSigAftClr` stores them through `func_4843264C`; `func_484326B7` multiplies them
into the beat count, as `MemStyleVarBarCount` does for a style) and `+0x1A` the flags (bit 0 LOOP, bit 1
SYNCHRO).  The other nine have no reader in that module; the `TPAD_PAD` macro names the four.

## Stale records and residue

A record's blocks are programmed whole, from a RAM buffer that still held what was built there
before. So:

- **Past a record's end** its blocks hold the tail of an earlier, longer write. 166 records have
  such residue (`slack_origin.py`); no accessor reads past `+0x00`'s size.
- **Free blocks** (map 0) are not erased in the nine KN7000 sets: they hold 41 complete older
  records (Felipe's bank holds three more, in the KN6000 layout) (no slot points at them; their `+0xA4` gives the block they were written for) and one
  fragment (01ctmini block 21). The complete ones are typed like live records (`StaleNN.inc`),
  e.g. "Revival Rock" (in 7 sets) and "Soloist Sounds" (4).
- The 80 "Blank" slots of the eight custom1/custom2 sets are each 0x237F bytes.

The KN6000 / KN6500 factory bank (`01ctmini.ic18`) has no stale records and no residue.  (Clarified
2026-11-02: the three KN6000-layout records above are in Felipe's KN7000 bank, not in this one.)

**How the residue is typed** (third round, extended by lane ic21-rest on 2026-10-31; `gen_customdata_s.py`,
class `Cover`; each run is an include file `<image>/SlotNN_Residue.inc`, `StaleNN_Residue.inc` or
`BlockNN_Residue.inc`):

1. **Copies of typed records.** At the start of a run, and after each matched piece, the
   generator first looks for a record of the nine sets with the same bytes at the **same
   record-relative offset** (32 bytes or more), then for the longest match at **any offset** in
   any record. A match is spelled with that record's own lines (its macros, every label folded
   to a number). The first line carries
   `stale tail of an earlier write; same bytes as <image> <Record> +0x..+0x..`.
2. **The donor's structure, other values.** Where a match ends (or starts) inside one of the donor's
   lines, or on a line boundary, the generator goes on along the donor's lines in place and spells each
   from the residue's own bytes when they keep the macro's shape: `PART_SETUP`, `PM_PART`, `PM_STYLE`,
   `PM_SET77`, `PM_FX`, `PM_SET88`, `PM_SET8C`, `PM_PART_TAIL`, `PM_ENTRIES`, `STREAM_HEADER`,
   `TCMP_VAR`, `TCMP_STYLE`, `TPAD_PAD`, `.ascii`, and an events run where the donor has an event line.
   A byte must lie in the range the corpus's items of that macro have, and the macro's fixed fields
   (zeros, `00 20`) must hold. These lines say "other values than the donor's line at the same place".
3. **Structures that no record holds.** In what is left: whole event streams (`{index, u24
   count, F4 .. F5}` that parse with the firmware's event lengths), the cut start of a stream (its
   header and events up to the next piece) and a stream header whose stream is the next piece, both
   only right after a stream's F5 (streams are contiguous) and with a count of at most 0x8000 (the live
   maximum is 0x23B9), TCMP variation records, TCMP / TPAD container headers, TPAD pad records and
   their first 0x28 bytes, each spelled with its macros.
4. **Runs of events.** A run of 16 bytes or more with at least two status events, or one that ends
   with F5, that parses under the stream rules the firmware's own streams keep (a position byte 0-95 is
   followed by an event; positions do not fall within a beat: the live streams repeat a position
   43,611 times and lower one once, `ic21-own-probes/stream_rules.py`). Also: a short piece between two
   typed pieces that parses exactly as events; events whose last one runs into the next piece on a
   donor line boundary; right after an F5, the 1-5 data bytes of an event whose status byte the newer
   stream overwrote (`[INFERENCE]` in the comment); the first bytes of an event cut by the end of the
   record's last block.
5. **Opaque**: what is left.

Tally, all nine sets (bytes; `residue_cover.py` prints it per image; "shaped" includes the pad and
variation records):

| image      | record copies | streams | events | shaped | opaque |
|------------|---------------|---------|--------|--------|--------|
| `01ctmini` | 60,805        | 68,789  | 21,908 | 8,677  | 4      |
| `01custm1` | 210,540       | 48,138  | 19,229 | 1,318  | 1      |
| `02custm2` | 282,330       | 5,563   | 5,759  | 2,243  | 5      |
| `03custm3` | 285,830       | 5,563   | 5,748  | 1,459  | 5      |
| `04custm4` | 204,806       | 26,300  | 8,384  | 1,311  | 0      |
| `01custm5` | 225,148       | 28,792  | 8,313  | 26,027 | 76     |
| `02custm6` | 261,576       | 73,359  | 13,535 | 13,872 | 43     |
| `03custm7` | 318,805       | 6,341   | 7,500  | 8,614  | 13     |
| `04custm8` | 308,169       | 6,333   | 6,760  | 4,307  | 10     |

157 bytes remain opaque, in 28 entries (the census figure; 4,179 B in 679 entries before). They are
pieces of one-touch settings and TCMP style records cut at both ends by other pieces (the largest, 42
bytes of `01custm5`, is the tail `+0x77..+0x9F` of a setting just past a record's end), event bytes
between two pieces where a position falls, and single bytes after a stream's end.

**PMR and SOUND records.** floppy-others' `PMR_*` (the full 0x750 / 0x700-byte PANEL MEMORY
record) and `SOUND_NAME_HEAD` / `SOUND_MOD` (the 0x2C8-byte SOUND EDIT record) are in the shared
includes, but IC21 holds neither: panel memories live in the backup SRAM (`0x84000824..`),
IC21 holds only the 0xA0-byte one-touch settings built from them (`PM_*`), and no factory record
has a SOUND EDIT dependency section. They would apply to a user's own IC21 with such sections.

## The .AST file

`func_4852D0E5` (by its size, 0x1E0000, the whole-bank save) builds a 16-byte header on its stack: three bytes copied from
0x48664308 (`"J K"`; the KN6000's files carry `"I K"`), `+0x03` = 1, `+0x04` u32 LE `0x1E0000`.
It never writes `+0x08..+0x0F`, so those 8 bytes are whatever the stack held: `48582CD3 5006F220`
(LE words) in custom1/custom2's eight files, `485A9C1D 5006ED88` in idd7000's, `0 50052930` in
idd6000's. The payload follows: the bank deflated by the programs' zlib 1.0.4 (the banner at
program file 0x3B8604; `func_48532C77` calls `deflateInit_` with level -1 = 6, and the library
defaults windowBits 15 and memLevel 8), written without the 2-byte zlib header but with the
Adler-32 trailer (big-endian). On load `AstHeaderIngest` 0x4848594D takes kind 0x17 as the
whole-bank file, at most 0x1E0000 bytes, programmed from `0x96820000`.

**Rebuilding them.** Python's zlib (1.3.1) does not reproduce the payload: it differs at byte 1.
zlib 1.0.4 does: its C sources (zlib.net/fossils, compiled with
`custom-data-ic21-probes/zlib104_drv.c`) give `01CUSTM1.AST`'s payload exactly. The difference
is in `_tr_tally`: 1.0.4 may end a block every 4096 symbols when its estimate says the block
compresses well; later versions compile that only with `TRUNCATE_BLOCK`. `tools/zlib10_deflate.py`
is a Python port of 1.0.4's deflate (deflate_slow, the sliding window and the trees), and
`ast_file.py deflate` rebuilds **all ten** `.AST` files byte for byte from the banks plus the
tag and the 8 stack bytes (`make verify-customdata-ast` in both trees). The floppy lanes can use
it to regenerate these files.

## Census

`scripts/analysis/data_incbin_census.py`, 2026-10-31 on branch open3/ic21-rest (count / bytes):

| tree                | opaque      | generic n | generic bytes |
|---------------------|-------------|-----------|---------------|
| `kn7000-customdata` | 28 / 157    | 0         | 0             |
| `kn6000-customdata` | 0 / 0       | 0         | 0             |

Generic is 0 in both trees: the panel memories and the voice records are typed since the second
round (`panel_memory.inc`, `voice_record.inc`). The opaque entries are the residue splinters
above (it was 183 / 2,592,308 before the third round, 679 / 4,179 before lane ic21-rest).

## Open questions

State after lane ic21-rest (2026-10-31):

- **BLOCKED** (no image holds one): the 0x42-byte dependency records (five kinds) and the 0x2C8 SOUND
  EDIT records. None of the ten factory banks, nor Felipe's bank and its three KN6000-layout records,
  has a dependency section other than `03custm3` slot 7's custom-sound block, so only the strides are
  known. Needs a bank saved with user effects or SOUND EDIT sounds.
- **BLOCKED** (needs a program build older than 893, v1.0-v1.2, not dumped): the writer of the 76
  `01ctmini` settings without 941's part tails. Programs 893 and 941 write them alike.
- **BLOCKED** (needs a KN6000 program older than v7.1): the writer of the KN6000 bank's settings with
  part 3 all 0xFF.
- **BLOCKED** (no copy of the tool): where the factory sets were made; the residue shows one tool built
  them in sequence, reusing its buffer.
- Not closed by this lane (firmware tracing still to do; no blocker): the panel-memory fields named only
  by their parameter id (`m<id>`), see `notes/data-semantics-2026-10-29/kn67-field-names.md`; the voice
  record's single fields beyond those `voice_record.inc` names, and the custom-sound block's 0x27-byte
  header; nine of the pad record's thirteen setting bytes.  (Status 2026-11-06, lane kn7000-research2:
  the header is a TABLE tone head, class `+0x10` and key map `+0x11` traced, 21 bytes unread; the
  references are per note; the voice record's `+0x0D` bits 0 / 2 enable the two layers; section "The
  slot record".  The voice record's sub-record and element bytes that `voice_record.inc` leaves by
  offset are still to trace.  Next step: the TABLE voice's staged record keeps the sub-record at
  `+0x3C`, the element at `+0x40` and the parameter record at `+0x44` (`TgTableToneStage`).  Follow
  `TgPitchZoneFold`, `TgVoiceRoutePtrCalc` and `TgTableKeyOffProgram` for the class-0x40 path.  Check in
  MAME by loading `03custm3` (CUSTOM slot 7), playing its kit, and breaking on `TgTableToneStage`.)  (Status 2026-11-06, lane kn7000-research: the
pad record's `+0x13`, `+0x18`, `+0x19` and `+0x1A` are traced, section "TPAD"; the TCMP variation
  bytes `+0x00..+0x02` and `+0x18` / `+0x19`, the style record's `+0x70` and the reader of the part
  set-up are traced, section "The TCMP style container"; the macros in `src/customdata/customdata.inc`
  carry the names.  The part set-up's bytes 15..23 have no reader: 0 everywhere.)  The `m<id>` fields
  whose ids are song-record parameters are named in `presentation-control-probes/song-records.md`
  section 3 (the firmware's parameter dump, 2026-11-06).
- The 157 opaque residue bytes above.

## Website page draft

> ### Custom style memory (IC21)
>
> The KN7000 keeps its 20 CUSTOM styles in the upper 1,920 KB of IC21, the flash at
> `0x96800000`, in a bank at `0x96820000` divided into 60 blocks of 32 KB. Block 0 is a
> directory: the signature "IK", where each of the 20 slots starts and how many blocks it takes,
> and a map of the used blocks. Each slot is one record holding a style and everything it needs:
> its name and the names of its four One Touch Settings, the four panel memories, the style
> itself (a "TCMP" container: 20 variations, each with eight part set-ups and an event stream),
> its six performance pads (a "TPAD" container), and any user sounds or effect settings it uses.
> The KN6000 and KN6500 use the same layout on their IC18.
>
> The factory contents come on floppies: the Initial Data Disk's `01CTMINI.AST` and the eight
> sets of the Custom Style disks 1 and 2. An `.AST` file is the whole bank compressed with zlib
> 1.0.4, the version in the firmware; a 16-byte header names the model ("J K" KN7000, "I K"
> KN6000). The disassembly rebuilds all ten banks byte for byte from typed sources, every style
> event on its own line, and rebuilds the `.AST` files from them with a port of zlib 1.0.4.
>
> The banks also show how they were made: flash blocks hold what the writer's buffer held
> before, so past many styles lie the tails of earlier ones, and unused blocks of the KN7000 sets
> still contain 41 complete styles that no slot lists ("Revival Rock" in seven of the sets).
