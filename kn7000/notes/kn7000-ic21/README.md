# Lane kn7000-ic21 (2026-11-07, wave 13): the IC21 kit's fields from their readers, seen in MAME

Wave 13 of the open-items work (`../../../notes/open-items/REGISTER.md`), continuing lane kn7000-research2
(`../kn7000-research2/README.md`).  Two items: the IC21 fields still to trace (N-b8f49b1e) and the factory
banks' field-level questions (N-f3c6a3ea, the pointer row to `../custom-data-ic21.md` "Open questions").
Probes, commands and run logs: [`../kn7000-ic21-probes/README.md`](../kn7000-ic21-probes/README.md).  Every
MAME result is **observed in emulation, not on hardware** (program 941 on the kn7000_mame overlay build of
2026-11-06).

## Items

| item       | outcome | where                                                                                  | in one line                                                                                                                                                                                               |
|------------|---------|----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| N-b8f49b1e | OPEN    | `../../src/include/voice_record.inc`, `../../src/customdata/customdata.inc`, this file | the user kit played in MAME: every byte of it that the firmware reads has its reader; the voice sub-record, element and TABLE head fields are named from those readers; the `m<id>` panel fields are left |
| N-f3c6a3ea | OPEN    | `../custom-data-ic21.md` "Open questions" (rewritten), this file                       | the part set-up's bytes 15..23 and nine of the pad record's thirteen setting bytes are unread in emulation too; four questions stay BLOCKED (no image / no older program), the `m<id>` fields stay open   |

## 1. How the kit was played

The kn7000_mame build loads IC21's CUSTOM bank from `kn7000_custom_data.rom`.  Given as it is, the bank
reaches the CPU halfword-swapped (the directory's `"IK"` reads `"KI"` and the firmware writes an empty
directory over it), so `make_rompath.py` swaps each byte pair first; the CPU then reads `03custm3`'s own
bytes (checked by a peek of the directory).  This is a driver observation for the kn7000_mame owner: the
comment above `ROM_LOAD_OPTIONAL("kn7000_custom_data.rom", ...)` says the plain load is unaffected, and in
this build it is not.  Nothing was changed in kn7000_mame.  **Fixed since:** kn7000_mame b5581e5 (2026-11-07, published
kn7000-emulator md5 4e4c2390) loads the file `ROM_GROUPWORD | ROM_REVERSE` like the other Initial Data files
(its probe: kn7000_mame `notes/ic21-byte-order-2026-11-07/`).  With that build a bank is given as it is, and
`make_rompath.py` swaps only when passed `--swap` (for older builds); an nvram saved by an older build still
holds the swapped or emptied bank, so use a fresh `-nvram_directory`.

`03custm3` slot 7 ("Bossa Nova") holds the only factory custom-sound block, a user drum kit.  Its style
does not use the kit; its pads 1 ("PERCUSSION", part 1) and 4 ("RIDE BELL", part 0) do, with the sound
`{0, 0, 0x19}` (bank kind 0x19 = the CUSTOM kit, `SoundNameGet` / `func_484495E8` -> `func_4844A413`).
Selecting the style and pressing the pads did not bind the style's own pads: `PadSelectById` was called with
built-in bank ids (`0x371`, `0x178`).  It takes a CUSTOM style's "TPAD" only for an id with `0x200000` set,
so the probe replaces the first id of the pad phase by `0x200000` (a breakpoint, as lane kn7000-research's
picload probe redirected a title).  The firmware's own code does the rest: `PadBindCustom` binds pad 1, its
stream plays, `TgNoteOnTableTone` runs 64 times on the pad parts (40 on part 0x1E, the kit), and
`CustomVoiceRecFetch` 84 times.  How the instrument selects a CUSTOM style's pads by itself (a button, or
the ONE TOUCH SETTING's pad bank) was not traced.

A read tap on the kit block logged every CPU read with its PC; `reader_fields.py` gives each read its field
(from the macros) and routine (from the label file).  A second run tapped the table flash's 'JK' archive
while the built-in kits of the rhythm played: the same routines read the same fields there, and it also
saw the release rate and the layers 1-5 of melodic elements.

## 2. The fields and their readers

Offsets in the voice record's sub-record (0x1C bytes; record `+0x10` / `+0x2C`), which `TgTableToneStage`
stages as the voice's "desc2" (librec `+0x3C`).  "MAME" = read while the kit played
(`runs/kit_tcmp_tpad_941.fields.txt`); "archive" = read in the archive run (`runs/kit_archive_941.fields.txt`);
"static" = from the routine's body only.

| field (VOICE_SUB)      | off    | reader                                                      | what the reader does with it                                                                                        | seen         |
|------------------------|--------|-------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------|--------------|
| `pan`                  | `0x00` | `TgLevelResolve` 0x4C02FBDE                                 | + part pan (partrec `+0x0A` - 0x40) + pan modulation, clamped 0..0x7F, into shadow `+0x24` bits 0-6                 | MAME archive |
| `elem_prog` .. `_msb`  | `0x01` | `TgTableToneStage` 0x4C035EA5                               | the element's {program, bank LSB, bank MSB} for `TgPartElemProgramApplyIdxSel`                                      | MAME archive |
| `coarse_tune`          | `0x04` | `TgPitchZoneFold` 0x4C02FB25                                | signed semitones, `<< 8` on the zone pitch (0xC00 = an octave)                                                      | MAME archive |
| `fine_tune`            | `0x05` | `TgPitchZoneFold`                                           | signed, 2 pitch units each (1/128 semitone)                                                                         | MAME archive |
| `level`                | `0x06` | `TgVoiceLevelTermCalc` 0x4C02FD94                           | level base + value - 100 (0 = silent, -0x200) + the part's per-note offset -> `TgLevelTermFinalize`                 | MAME archive |
| `level_key_slope`      | `0x07` | `func_4C02FCBA`                                             | signed slope of the key curve                                                                                       | MAME archive |
| `level_key_curve`      | `0x08` | `func_4C02FCBA`                                             | 0x70 = the fixed table 0x486D2805, else the high nibble picks curve 0x486D1454 + n*0x100                            | MAME archive |
| `aeg_attack_rate`      | `0x09` | `TgTableAmpAttackRateCalc` 0x4C02FDFA                       | through the attack curve 0x486D25E4 (as `TgAmpEgAttackRateCalc` for a unit's `+0x28`)                               | MAME archive |
| `aeg_rate1`, `_level1` | `0x0A` | `TgElemNoteOnStd` 0x4C030A98                                | rate through curve 0x486D2649, level through curve 0x486D26AE (the curve of a unit's amp EG levels), shadow `+0x04` | MAME archive |
| `aeg_rate2`, `_level2` | `0x0C` | `TgElemNoteOnStd`                                           | the same, shadow `+0x08`                                                                                            | MAME archive |
| `aeg_release_rate`     | `0x0E` | `TgTableKeyOffRelease` 0x4C02FE59                           | through curve 0x486D2649, only when the head's `voice_flags` has bit 5 (`TgVoiceKillHandler`)                       | archive      |
| `aeg_attack_key`       | `0x0F` | `TgTableAmpAttackRateCalc`                                  | signed key scaling of the attack rate (key table 0x486D13D4 / 0x486D1354, `>> 4`)                                   | MAME archive |
| `filter_flags`         | `0x10` | `func_4C02FFD4`, `TgVoiceFilterProgram`, `TgVeloSenseApply` | bits 0-1 filter mode (0 = off: shadow `+0x4C` bit 17); bits 5-7 the velocity curve 0x486D2264 + n*0x80              | MAME archive |
| `filter_velo_sense`    | `0x11` | `TgVeloSenseApply` 0x4C02FE77                               | signed depth: base + curve[velocity] * depth `>> 5`                                                                 | MAME archive |
| `cutoff`               | `0x12` | `TgVoiceFilterProgram` 0x4C030606                           | base of `TgPartCutoffResolve`, whose 0..0x70 cutoff goes to shadow `+0x26` bits 8-14                                | MAME archive |
| `filter_level`         | `0x13` | `TgTableFilterLevelCalc` 0x4C02FEC7                         | + part term 0x4C0146D3 + the layer's filter offset, through `TgVeloSenseApply`, into librec `+0x60` (send word A)   | MAME archive |
| `cutoff_key_follow`    | `0x14` | `TgVoiceFilterProgram`                                      | `TgPartCutoffResolve`'s key-follow depth                                                                            | MAME archive |
| `filter_q`             | `0x15` | `func_4C02FFD4`                                             | + 0x18, clamped, into librec `+0x62` (send word B); `[INFERENCE]` the resonance                                     | MAME archive |
| `filter_shape`         | `0x16` | `func_4C02FFD4`, `TgVoiceFilterProgram`                     | bits 6-7 the variant, bit 5 / bits 0-4 a 3-byte entry of 0x486D2794 / 0x486D2746 (two register fields, a level fix) | MAME archive |
| `send_a`, `send_b`     | `0x18` | `TgElemNoteOnStd`                                           | the effect sends (curves 0x486D1F54 / 0x486D2154), as a unit's `+0x18` / `+0x19`                                    | MAME archive |
| `s17`, `s1a`, `s1b`    |        |                                                             | not read (0 in nearly all of the archive's 1,617 sub-records)                                                       |              |

The rest of the voice record:

| field                        | reader                                                             | what it is                                                                                                     | seen         |
|------------------------------|--------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|--------------|
| head `+0x0D` `voice_flags`   | `TgNoteOnTableTone`, `TgVoiceKillHandler`, `VoiceSubRecFetch`      | bit 0 layer 0, bit 2 layer 1; bit 5: the voice takes a key-off (`TgTableKeyOffRelease`), else it is a one-shot | MAME archive |
| head `+0x0E` `excl_group`    | `TgExclGroupChoke` 0x4C03099F                                      | bit 7 = in an exclusive group, bits 0-6 its id (open / closed hi-hat)                                          | MAME archive |
| head `+0x0F` `ctrl_sense`    | `TgPartCtrlSenseElem` 0x4C030896                                   | a signed amount the part's control mode scales, for `TgVoiceFadeParamsPlan`                                    | MAME archive |
| element `+0x00..+0x02`       | `TgTableToneStage`                                                 | the velocity split points (`vel_split0` read by the kit's one-zone elements)                                   | MAME archive |
| layer `+0..+2`               | `TgTableToneStage`, `TgVoiceZoneVeloResolve`, `TgPartProgramApply` | the parameter record reference                                                                                 | MAME archive |
| layer `+3` `l<k>_level`      | `func_4C02FCBA`; `TgElemLevelBaseCalc` (melodic)                   | signed level offset of the layer                                                                               | MAME archive |
| layer `+4` `l<k>_filter_ofs` | `TgTableFilterLevelCalc`; `func_4C01243A` (melodic)                | signed offset on the sub-record's `filter_level`                                                               | MAME archive |
| element `+0x03`, `+0x04`     |                                                                    | not read                                                                                                       |              |

The TABLE head (`CSOUND_HEAD`, `tone_head_table`), after the name, class `+0x10` and key map `+0x11`:

| field                         | reader                               | what it is                                                                                                                     | seen |
|-------------------------------|--------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|------|
| `mod<k>_dest`, `mod<k>_depth` | `TgPartToneModRoutesLoad` 0x4C009C88 | six routings at `+0x12 + k*3`: dest (1..0x2E, the entry of `TgPartModConfigStore`'s jump table 0x48586658) and depth, per part | MAME |
| `mod<k>_src`                  |                                      | not read on the TABLE path; `[INFERENCE]` the source, by the melodic head's `mod_src` fields at `+0x12`                        |      |
| `h24`, `h25`, `h26`           | `func_48448EA3`                      | bytes 6..8 of its nine-byte tone summary (a melodic head gives `+0x51..+0x53` there)                                           | MAME |

So of the "21 unread head bytes" of wave 12, fifteen have readers; the six `mod<k>_src` bytes are not read
on this path.  The 128 note references and the voice records were already traced (wave 12).

Also seen in the archive run, on the archive's own parameter records (`jk_param`, `src/table/style_macros.inc`):
`b11` is read by `TgPitchInitCalc` and `b14` by `TgVoiceZoneVeloResolve` (`center`, `key_lo`, `key_hi` by
`TgPitchZoneFold`, `flags` by five pitch / route / attack routines).  Their names are left to the table lane.

## 3. The style and the pads (N-f3c6a3ea)

The same run tapped slot 7's "TCMP" and "TPAD" containers (`runs/kit_tcmp_tpad_941.fields.txt`):

- **Part set-ups.**  `StyleTemplateLoadParts` copies 15 bytes of each TCMP part set-up (`memcpy`, the
  fields `mode` .. `cc92`), and `StylePartFieldEmit` reads the same 15 fields of each TPAD pad's set-ups;
  bytes 15..23 (`sustain` .. `cc13`) are never read.  This confirms in emulation the static reading of lane
  kn7000-research.
- **Variation records.**  Read while the style played: `bars` / `meter` (`StyleRecordBindCustom`), `eff4` /
  `eff5` (`StyleVarDspPartsApply`), the stream offset (`LoadU24BE`).  The source key `+0x00..+0x02`, the pair
  flag and the eight per-part bytes were not read on this route (the source key is read by `func_4843511C`
  when a MEMORY style is rebuilt, statically).
- **Style record.**  The names (`strncpy` / `memcpy`), the 20 indexes (`StyleNameCommitCustom`) and the
  DSP-unit keys `+0x70..+0x73` (`StyleDspKeyDecode`, `StyleDspUnitsApply`).
- **Pad records.**  `PadBindCustom` reads the name, `bars` `+0x18`, `meter` `+0x19` and `flags` `+0x1A`, and
  the stream offset; none of `s0..s2`, `rec_chord`, `s4..s7`, `s11`, `s12` was read while the pad played.
  `rec_chord` has its reader in the user-pad edit module (lane kn7000-research).  The other nine have no
  reader in either.

## 4. Names added (for lane kn7000-subsystems)

In `kn7000_manual.sym` (ported to 942 / 935 / 893 by `make symbols-sp7001 exports-941 symbols-935
symbols-893`):

| name                       | 941          | what it is                                                      |
|----------------------------|--------------|-----------------------------------------------------------------|
| `TgVoiceLevelTermCalc`     | `0x4C02FD94` | the level term from desc2 `+0x06`                               |
| `TgTableAmpAttackRateCalc` | `0x4C02FDFA` | a TABLE layer's attack rate (`+0x09`, `+0x0F`)                  |
| `TgTableKeyOffRelease`     | `0x4C02FE59` | a TABLE voice's key-off release (`+0x0E`)                       |
| `TgVeloSenseApply`         | `0x4C02FE77` | velocity curve and depth on a base (`+0x10` bits 5-7, `+0x11`)  |
| `TgTableFilterLevelCalc`   | `0x4C02FEC7` | a TABLE layer's filter level (`+0x13`, layer `+4`)              |
| `TgVoiceFilterProgram`     | `0x4C030606` | a voice's filter: cutoff, key follow, the two send-word levels  |
| `TgPartToneModRoutesLoad`  | `0x4C009C88` | the tone head's modulation routings into `TgPartModConfigStore` |
| `PadBindCustom`            | `0x484341A9` | binds a pad of the selected CUSTOM style's TPAD                 |

Not renamed, because data labels are derived from their names (`func_4C02FCBA_Table`,
`func_4C02FFD4_...`, `func_48448EA3_Records`: the data generator's labels) and other lanes regenerate that
data: `func_4C02FCBA` (proposed `TgTableLevelBaseCalc`, the twin of `TgElemLevelBaseCalc`),
`func_4C02FFD4` (proposed `TgTableFilterSetup`) and `func_48448EA3` (proposed `ToneSummaryGet`).

**`TgLevelResolve` resolves the pan.**  Its body adds desc2 `+0x00` (on the TABLE path the sub-record's
first byte, whose archive values are drum-kit pan positions: bass drum 64, snare 76, closed hi-hat 88, ride
40, crash 96 or 48) to the part's byte `+0x0A` - 0x40 (the part init `0x4C0095D6` resets that byte to 0x40,
next to the 0x7F volume / expression bytes), clamps to 0..0x7F and forces 0 or 0x7F for a part whose state
`+0x1D` is 1..3 with flag bit 0 / 1: hard left or right.  None of that is a note level.  The name is kept
(its doc is corrected): it is in the generated sources of four builds, in kn2400's ported names and in the
committed probes and run logs of lane kn7000-research.  Its per-element twin `TgVoiceNoteLevelCalc`
0x4C03129D, which has a random mode, is most probably the pan too; that routine is not an IC21 reader.

## 5. Still open

- **N-b8f49b1e:** the `m<id>` panel fields of the one-touch settings (`PM_FX`'s `m008010`, `PM_PART`'s `p06`,
  the `organ_nib24` / `25` nibbles; `../../../notes/data-semantics-2026-10-29/kn67-field-names.md`).  Next step:
  in MAME, recall a one-touch setting of a CUSTOM style (ONE TOUCH PLAY + VARIATION 1 on slot 7) with a
  write tap on the live panel record `0x84000020 + tag block` and breakpoints on the trie's type-0 reader,
  and follow the parameter ids 0x008010 and the part byte `+0x06` to the routine that uses them; then the
  six `mod<k>_src` bytes (follow a melodic head's `+0x12` through `TgPartToneModSetupMelodic` to see whether
  the TABLE path has a twin), and the TG meaning of shadow `+0x4C` / `+0x50` (`filter_level`, `filter_q`).
- **N-f3c6a3ea:** what stays open is in `../custom-data-ic21.md` "Open questions": four BLOCKED (no image /
  no older program / no tool), the `m<id>` fields above, the nine unread pad bytes (no reader in the pad
  player or the user-pad module; next: the PAD edit screens' procs), and the 157 opaque residue bytes
  (splinters of records cut at both ends; nothing more to type without a donor).

## Website page drafts

*For the technics-docs KN7000 pages; text only, another process publishes them.*

**Drum kits and user kits** (the KN7000 sounds page, extending wave 12's section).  Each drum voice of a kit
is a short record: a 13-character name, three flag bytes and one or two layers of 28 bytes.  The flags say
which layers sound, whether the voice stops at key release (otherwise it rings out, like a real drum) and
which exclusive group it belongs to, so that a closed hi-hat cuts an open one.  A layer gives the voice's
pan (the built-in kits place the bass drum in the centre, the snare a little right, the hi-hat right and
the ride left), its tuning in semitones and fine steps, its level and how that changes across the keyboard,
an amplitude envelope (an attack rate with key scaling, two decay segments, a release rate), a filter
(type, cutoff with key follow, velocity sensitivity, resonance) and two effect sends.  It points to an
element, which splits the velocity range into up to four zones, each naming a sample and adding its own
level and filter offsets.  A kit's head also carries six modulation routings for the part that plays it.
A user kit saved with a CUSTOM style has exactly this layout.  The disassembly names every byte of it from
the firmware routine that reads it, checked by playing the factory user kit in the MAME emulator.
