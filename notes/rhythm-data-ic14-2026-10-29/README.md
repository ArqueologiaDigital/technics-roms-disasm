# KN5000 rhythm data ROM IC14: format and source tree (2026-10-29)

Lane `kn5000-rhythm` of the data-semantics plan (`notes/data-semantics-2026-10-29/README.md`). IC14 now has a
source tree, `rhythm_data/`, that rebuilds the descrambled image byte for byte without a single `.incbin`.
Every byte is a typed record, an event macro or FF fill. The A19/A21 swap is a committed transform, and the gate
checks that it turns the rebuilt image into the raw chip read.

Probes and the command for each measurement are in `probes/README.md`. Firmware addresses are v10 (same code in
v9 and v7). Labels are in `symbols/maincpu_v10_symbols_reference.txt`.

## The two images

| file (private romset, `technics_roms/roms/kn5000/`)  | size | CRC32      | SHA-1                                      | what it is                                              |
|------------------------------------------------------|------|------------|--------------------------------------------|---------------------------------------------------------|
| `kn5000_rhythm_data_rom.ic14`                        | 4 MB | `aa4917ce` | `fef7f1927935d8fdada2afbdbfac29aac56e1c3c` | descrambled: the layout the firmware's pointers address |
| `kn5000_rhythm_data_rom.ic14.as-read-a19a21-swapped` | 4 MB | `76d11a5e` | `e4b572d318c9fe7ba00e5b44ea783e89da9c68bd` | the chip as read, address lines A19 and A21 exchanged   |

`make` copies both into `original_ROMs/` (git-ignored, `KN5000_RHYTHM_REF` / `KN5000_RHYTHM_RAW_REF`) after a
SHA-1 check. `scripts/build/rhythm_rom_address_swap.py` maps one onto the other: `raw[a] = img[swap(a)]`, where
`swap` exchanges address bits 19 and 21. The swap is its own inverse and moves whole 512 KB blocks
(0x080000 <-> 0x200000, 0x180000 <-> 0x300000). `make verify-rhythm-data-raw` applies it to the rebuilt image
and compares the result with the raw read.

Why the descrambled image is the right one: all 46,056 track pointers in the style records land on a track
header in it. In the raw read only 17,608 do, partly by chance (`probes/swap_framing_probe.py`). This agrees with
`docs/accompaniment-style-reader.md`, which found 9,696 of 9,696 lane reads framed after the swap. That document
also notes the question this does not settle: is the dump wrong, or does the board route CPU A19/A21 to other
IC14 pins? The answer decides whether MAME should load the descrambled image or swap lines in its memory map.

**Stale CRC in the MAME driver (noted, not fixed here).** `mame_driver/src/mame/matsushita/kn5000.cpp` line 768
declares `ROM_LOAD("kn5000_rhythm_data_rom.ic14", 0x000000, 0x400000, CRC(76d11a5e)
SHA1(e4b572d318c9fe7ba00e5b44ea783e89da9c68bd))`. Those are the raw read's hashes under the descrambled image's
file name. The romset file of that name is the descrambled one (`aa4917ce` / `fef7f19...`). MAME will report a
mismatch, and if it is given the raw read it plays the wrong 64 KB banks for about two thirds of the styles. The
driver needs either the descrambled hashes, or the raw hashes plus an A19/A21 swap at load time. Which one is the
hardware question above.

## Layout

| image offset      | CPU address       | bytes     | content                                                                   | source                             |
|-------------------|-------------------|-----------|---------------------------------------------------------------------------|------------------------------------|
| 0x000000-0x064FFF | 0x400000-0x464FFF | 413,696   | 202 style records of 2 KB (two 1 KB halves each)                          | `rhythm_data/style_records.s`      |
| 0x065000-0x37FFFF | 0x465000-0x77FFFF | 3,256,320 | 28,400 tracks (3,138,415 B) in 64 KB banks 6..0x37; FF to each bank's end | `rhythm_data/patterns/bank_NN.s`   |
| 0x380000-0x3FFFFF | 0x780000-0x7FFFFF | 524,288   | erased (FF), banks 0x38..0x3F                                             | `rhythm_data/kn5000_rhythm_data.s` |

The FF tails of banks 6..0x37 total 117,905 B. Bank 6 has an FF run 0x06FF3C-0x06FFFF before bank 7 starts.
Nothing else is in the chip (`probes/layout_probe.py`).

The main CPU sees IC14 at 0x400000. `AccVoice_OffsetTable` holds 64 bank bases, `0x400000 + n * 0x10000`, so the
firmware does no scrambling of its own. Every address it forms is `0x400000 + (RHYTHM_ROM_BASE) + ...`, and
RHYTHM_ROM_BASE (RAM 0x3277) is 0 once `RhythmROM_ValidateHeader` has matched the 12 bytes `00 01 04 05 83 00 01
04 05 83 00 01` at 0x400000. Those bytes are simply the start of the section map that opens every record half.
`Test_Rhythm_data_ROM_IC14` (the service test) checks the first four of them through `RomTest_RhythmRomSignature`.
Its word-sum loop sums the same first 2 MB twice, because `ld xiy, 0x400000` sits inside the outer loop, so the
sum comparison always passes. No checksum is stored in the ROM.

## Selecting a style record

`RhythmROM_BankProgramLocators` (program ROM 0xE45142, 8 banks x 128 programs x {u16 hi, u16 lo}) gives
`record = (hi & 0xff) << 16 | lo`. `AccVoice_ComputeChannelIndex` and `AccVoice_LookupWithOffset` read it for the
style (ACC_STYLE_GROUP = bank, ACC_STYLE_NUMBER = program), and `Rhythm_LoadCurrentTimeSig` reads it for PANEL_STYLE
(0xFC5A program, 0xFC5B bank). 201 of the 1,024 slots are used, each pointing to a different record. The record at
0x000000 (`8br86d`) is pointed to by no slot, in any of v5, v6, v7, v8, v9, v10 (the table is byte-identical in
all six, `probes/locator_selection_probe.py`).

Record labels name that selection: `Style_B<bank>P<program>_<id>`, e.g. `Style_B3P090_8br27k`, and
`Style_Unlocated_8br86d`. `<id>` is the record's own 8-character id at +0x3DB without its `1n` / `1v` suffix.
The (bank, program) to record map is printed by the locator probe. Programs group related styles: program 90
holds `8br97g`, `8br17r`, `8br27k`, `8br37p` and `8br75d` in banks 1, 2, 3, 4 and 7.

**Not connected: the names the panel shows.** The firmware's 13-character style names are
`AccVoice_RomRecords13` (280 = 14 groups x 20: "8Bt Standard", "Simple 8 Beat", ...), read by
`AccVoice_ComputedCopy` at `group * 20 + number`, with per-group counts in `AccVoice_GetChannelCount_Lookup_Data`.
No table mapping that UI (group, number) to the locators' (bank, program) was found. A brute-force search of the v10
program ROM for a 280-entry pair table found only `VoiceParam_BankProgramWords`, which is dense with valid pairs
anyway. The labels therefore carry the locator selection and the record id, not a display name. This is an open
question below.

## Style record (2 KB = two 1 KB halves)

Half 0 carries the id suffix `1n` and half 1 `1v`. Both halves of a record name the same pattern bank (202 of
202). Half 0 serves section-slot indices 0..19 and half 1 indices 20..39 (`AccStyle_ReadParamOffset_Data`: 0..19,
then 0x400..0x413). With groups of five that is 8 sections, 0..3 and 4..7. The macros are in
`rhythm_data/rhythm_macros.inc`, and each one's comment cites its readers.

| half offset | size | macro                                | content                                                                                                                                                                                                                                           | evidence                                                                                                                                                                    |
|-------------|------|--------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| +0x000      | 280  | `style_section_map`                  | 7 blocks of 40 B. Each block is 4 sections x `sec_picks` (4 slot numbers + 0x83), then 4 more `sec_picks`. Block 0 is for parts 1 and 2, blocks 1..4 for parts 4, 8, 16 and 32. Blocks 5 and 6 are unread. The map is identical in all 404 halves | `AccStyle_ReadParamOffset` (+0/+40/+80/+120/+160), `AccPart_IncrementIndex` (0x83 = back to the group's first pick), `AccStyle_ByteDataBlock` (+20, no caller in v10)       |
| +0x118      | 6x38 | `part_tracks` x 6                    | per part, 19 u16 track slots: offset of the track within the half's pattern bank                                                                                                                                                                  | `AccPart_GetParamAddr` (+0x118, +0x13e, +0x164, +0x18a, +0x1b0, +0x1d6), `AccVoice_TableLookup`                                                                             |
| +0x1fc      | 76   | `style_gap_1fc`                      | FF                                                                                                                                                                                                                                                | constant                                                                                                                                                                    |
| +0x248      | 8x49 | `part_sound` x 5 + `sound_block_end` | 8 sound blocks. Each is 5 x 7-byte part sound records (DRUM, BASS, ACCOMP1, ACCOMP2, ACCOMP3: program, bank, forced byte, bank-msb flag, 3 untraced bytes) and 14 FF                                                                              | `AccVoice_LoadTuningBlock` (copies 0x31 B to RAM 0x3246, forces +9/+0x10/+0x17/+0x1e), `RhythmROM_PatternDisp_Handle90`, `AccTuning_LoadFromROM` (Sound Arranger overrides) |
| +0x3d0      | 1    | `style_tail` time_sig                | time-signature code: 7 = 4/4 (374 halves), 6 = 3/4 (26), 11 = 8/4 (2), 9 = 6/4 (2); spelled `TIMESIG_n_d`                                                                                                                                         | `AccStyle_ReadVoiceParam` -> `AccTone_LookupByProgram_Table` (beats per bar); `Rhythm_LoadCurrentTimeSig` -> RAM 0x34f0, the `TimeSig_DisplayStrings` index                 |
| +0x3d1      | 1    | bank                                 | pattern bank 0x06..0x37 of this half's tracks                                                                                                                                                                                                     | `AccStyle_SetupPartAddresses` -> ACC_STYLE_BANK, `ToneData_LookupEffectParam`                                                                                               |
| +0x3d2      | 8    | v0a..v3b                             | per section of the half, two velocity settings; the same 61,61 / 13,61 / 61,61 / 61,61 in every half                                                                                                                                              | `Rhythm_LookupTuningRange` (0x3d2, 0x3d4, 0x3d6, 0x3d8 and +0x400) -> RAM 0x333f / 0x3340; `AccMidi_SelectVelocitySource`                                                   |
| +0x3da      | 1    | flag                                 | 1 in every half                                                                                                                                                                                                                                   | `AccStyle_ReadVoiceParam` -> RAM 0x32ef, which nothing in v10 reads                                                                                                         |
| +0x3db      | 8    | id                                   | ASCII `<6-char id>1n` / `1v`                                                                                                                                                                                                                      | no reader found                                                                                                                                                             |
| +0x3e3      | 16   | m0, m1, 0, m3, w0..w3, c0..c3        | small counts, four u16, four small counts                                                                                                                                                                                                         | **no reader found** (open question)                                                                                                                                         |
| +0x3f3      | 13   | (in `style_tail`)                    | zeros                                                                                                                                                                                                                                             | constant                                                                                                                                                                    |

### Parts and slots

The parts are the six one-hot ACC_PART_BIT values 1, 2, 4, 8, 16, 32, in that order. Their source names are
`Drum`, `Drum2`, `Bass`, `Acc1`, `Acc2`, `Acc3`. Measured (`probes/part_stats_probe.py`):

- parts 0 and 1 have identical slot lists in all 404 halves. They play General MIDI drum notes (36, 49, 38 most
  common), and the code skips the note check `Rhythm_CheckVelocityThreshold` for parts 1 and 2 only;
- part 2 plays notes 23..84, median 36: a bass line;
- parts 3..5 play notes with medians 62..64, mostly 0x91 notes: chord parts.

The five sound records per block are DRUM, BASS, ACCOMP1, ACCOMP2, ACCOMP3 in the Sound Arranger's order.
Linking parts 2..5 to sound records 1..4 is an **inference** (counts and order agree; no code path joining them
was traced).

Slots (`probes/slot_bars_probe.py`). Every track in slots 0..15 and 17 is exactly one bar of the half's time
signature (2,424 of 2,424 per slot). Slots 16 and 18 hold 1..8 bars.

| slots  | selected by                                                                                                                                                                           | reading                                        |
|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|
| 0..7   | the section map: pick p -> slot p (`AccPart_LookupBoundVoiceParam`)                                                                                                                   | the sections' bars                             |
| 8..11  | no reader traced (in record 0 they equal slots 12..15)                                                                                                                                | open                                           |
| 12..15 | `AccVoice_ComputeParamAddr`: 0x18/0x1a for section slots < 15, 0x1c/0x1e for < 20, the same +0x400 in half 1; the second of a pair when RAM 0x3309 bit 0 is 0 (`AccPedal_DirectionA`) | [INFERENCE] fill-ins                           |
| 16..18 | `AccVoice_SelectPartOffset` (0x20 / 0x22 / 0x420 on RAM 0x32ff bits 0, 1), `AccVoice_Reset_SelectMode` (RAM 0x330a), `AccVoice_ThirdLayer_SelectMode` (0x24 / 0x424, RAM 0x330b)      | [INFERENCE] 16 / 18 intro / ending, 17 one bar |

Track labels are `Trk_<id>_<N|V>_<part>_S<slot>`, named after the first slot that refers to them (in record,
half, part and slot order). Tracks are shared: 46,056 slot references name 28,400 tracks, and every track is
referenced (`probes/track_grammar_probe.py`).

## Tracks and events

A track is `80 FF FF FF FF 87`, events, then `83 87`. The reader (`AccVoice_ProcessEventLoop`) gets
XHL = bank base + 0x8000 (`AccVoice_TableLookup`) and IY = slot word - 0x8000 + 6 (`AccPart_GetParamAddr`), so it
starts just after the header. In the header, +1/+2 and +3/+4 are page links (`AccBuf_Advance` follows the word at
+3 when it meets an 0x87). In the ROM all 28,400 headers are FFFF/FFFF and every 0x87 follows an 0x83, so no link
is ever taken. The same header is used for the 256-byte cells in IC19 and on disk
(`docs/accompaniment-style-format.md`), where the links are used.

| status    | bytes | macro                                                 | fields                                                   | reader                                                                                  | count   |
|-----------|-------|-------------------------------------------------------|----------------------------------------------------------|-----------------------------------------------------------------------------------------|---------|
| 0x81      | 1     | `beat [count]`                                        | one beat passes (96 ticks)                               | `AccVoice_HandleBarEndEvent`, `AccTempo_PositionCompare`                                | 163,146 |
| 0x90      | 6     | `note tick, key, vel, dur_ticks, dur_beats`           | tick in the beat 0..95, note, velocity, duration         | `AccMidi_ParseCommon` -> ACC_EVENT+0..+5                                                | 319,081 |
| 0x91      | 8     | `note2 ... , ext1, ext2`                              | as 0x90, then two bytes whose meaning is not established | `AccMidi_ParseNoteOn` -> RAM 0x3433 / 0x3434                                            | 95,112  |
| 0xD1-0xD5 | 3     | `cc_mod`, `cc_bend`, `cc_damper`, `cc_pan`, `cc_expr` | tick, value; selector = status & 0x0f                    | `AccMidi_ParseDType`; selector meanings from `SeqPerformance_EventDispatch` (IC19 path) | 24,229  |
| 0x83 0x87 | 2     | `trk_end`                                             | end of the pattern, then the page-end byte               | `AccVoice_HandleMarker83`                                                               | 28,400  |

The controller counts are 0xD1 2,540, 0xD2 10,496, 0xD3 9,402, 0xD4 6 and 0xD5 1,785. Unlike the IC19 styles,
IC14 uses all five selectors. Selector meanings are taken from the IC19 analysis of the shared performance
dispatcher. That the IC14 path (`AccCh*_DTypeEntry` ring buffers) ends in the same dispatcher is an **inference**.

## Census

`data_incbin_census.py` row `kn5000-rhythm` (`rhythm_data/`): no `.incbin` / `.incbin_range` at all, so
generic = 0, opaque = 0 and generated = 0. The tree has no binary include to classify.

## Open questions

1. The UI-name connection: which table maps the panel's (rhythm group, number), `AccVoice_RomRecords13`, onto the
   locators' (bank, program)? Leads: `AccVoice_Dispatch` (L = group 0..15, H = number 0..0x4f; groups 14 and 15
   take other paths), `MainGetRhyGrpName`, `RVari_Paint`, `CmpSet_StepRhythmBank` (it clamps 0xFC5B with
   `AccVoice_GetChannelCount`, which suggests 0xFC5A is also used as a UI group index).
2. +0x3E3..+0x3F2: no reader. Tried: a displacement search over v10 sequencer and UI code for 0x3e3..0x3f2 /
   995..1010; and comparing the four u16 with per-part sums of distinct-track bytes, note counts and beats for five
   records (no match). It may be authoring metadata.
3. Slots 8..11: no reader traced.
4. `part_sound` bytes +4..+6: copied to RAM 0x3246.. with the rest; consumer not traced.
5. Does the board cross A19/A21, or is the dump wrong? (See above; it decides the MAME fix.)
6. The record at 0x000000 (`8br86d`) is pointed to by no locator in any firmware. Is it a leftover, or the target
   of some other path?

## Reproduce

    make original_ROMs/kn5000_rhythm_data_rom.ic14 original_ROMs/kn5000_rhythm_data_rom.ic14.as-read-a19a21-swapped
    make rebuilt_ROMs/kn5000_rhythm_data_ic14.llvm.rom verify-rhythm-data-raw      # about 9 s to assemble
    python3 scripts/generators/gen_rhythm_data_s.py --check    # does the tree still equal the first generation?
    python3 notes/rhythm-data-ic14-2026-10-29/probes/track_grammar_probe.py

`gen_rhythm_data_s.py` wrote the first source. It refuses to write if a single byte is unexplained. The `.s` files
are now authoritative, and `--check` only reports whether they still equal its output.

## Website page draft

*(For `technics-docs`: a new page `rhythm-rom.md`, linked from `memory-map.md` 0x400000 and from
`accompaniment-engine.md` "Style Data Format"; add it to `_data/navigation.yml`. The disassembly repository's
source is `rhythm_data/`.)*

---

**Rhythm ROM (IC14)**

The 4 MB mask ROM at IC14 holds the KN5000's factory accompaniment styles: 202 style records, and the 28,400
one-part patterns ("tracks") they play. The main CPU maps it at 0x400000-0x7FFFFF and reads it in 64 KB banks
(`AccVoice_OffsetTable`). The dump in circulation has address lines A19 and A21 exchanged. Undoing that swap
gives the layout the firmware's pointers address, and all 46,056 of them land on a track.

*Layout.* 0x400000-0x464FFF holds the style records, 2 KB each. 0x465000-0x77FFFF holds the tracks, in banks
6..0x37, each bank filled with FF after its last track. 0x780000-0x7FFFFF is erased.

*Selecting a style.* `RhythmROM_BankProgramLocators` in the program ROM (8 banks x 128 programs) points to 201
of the records. A style is chosen by (bank, program); the panel stores them at 0xFC5B / 0xFC5A. The 12 bytes the
firmware checks at boot (`00 01 04 05 83 00 01 04 05 83 00 01`) are the start of the first record.

*Style record.* Two 1 KB halves, sections 0-3 and 4-7. Each half holds:

- a section map: which one-bar slots each section plays, in turn;
- for each of six parts (two drum parts that always play the same tracks, bass, and three accompaniment
  parts), 19 track slots. Slots 0-15 and 17 are one bar; slots 16 and 18 are longer, probably intro and ending;
- eight sound blocks: program and bank for DRUM, BASS and ACCOMP1-3, which the Sound Arranger can override;
- the time signature (4/4, 3/4, 6/4 or 8/4), the pattern bank, two velocity settings per section, and an
  8-character id such as `8br27k1n`.

*Tracks.* A track is the six-byte header `80 FF FF FF FF 87`, then events, then `83 87`. Its events are:

- `81`: one beat;
- `90 tick note velocity dur_ticks dur_beats`: a note, at 96 ticks per beat;
- `91`: the same, with two more bytes;
- `D1`..`D5 tick value`: modulation, pitch bend, damper, pan and expression.

It is the same event language as the user styles in the custom-data flash (IC19), without IC19's 256-byte cell
chaining.

*For emulation.* MAME must present the descrambled layout at 0x400000. Its ROM entry currently declares the raw
read's hashes (CRC 76d11a5e) under the descrambled file name.
