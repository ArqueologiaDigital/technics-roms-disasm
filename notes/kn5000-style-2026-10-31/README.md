# KN5000 style banks and floppy fields named (lane kn5000-style, wave 4, 2026-10-31)

The owner decided on 2026-10-31 to adopt the field readings of
`notes/floppy-kn5000-2026-10-29/specs/style_bank_extra.json` (the floppy-kn5000 lane's spec), each one
verified against the v10 accompaniment code that reads it, in both places at once:

- the KN5000 floppy style sources (`floppy/kn5000/formats.py`, macros in `floppy/kn5000/include/kn5000_files.inc`);
- the custom-data style banks (`scripts/build/style_events.py`, listings `custom_data/styles/*.styles`).

Both now import one module, `scripts/build/style_bank_layout.py`. Its docstring names every field of the bank
and gives the evidence for each, so the two describers cannot drift apart again. The listing format is 3.

```
python3 scripts/build/style_events.py verify          # the five IC19 / table-data banks round-trip
make -C floppy src-kn5000 && make -C floppy gate-kn5000 # 14 KN5000 disks rebuilt from the regenerated sources
python3 notes/kn5000-style-2026-10-31/probes/style_bank_readers.py > readers.txt   # the reader search
```

## The style bank, field by field

Offsets are bank-relative for the header and record-relative (record = bank + 0x60 + 0x60 * k) otherwise.
"Readers" are v10 routines; the source lines come from `probes/style_bank_readers.py` and were read by eye.

| offset                  | name                                                                           | evidence                                                                                                                                                                                                                                               | status                                     |
|-------------------------|--------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------|
| hdr +0x04               | `reserved_04` (7 B)                                                            | 0 in every bank; no ABS / IMG reader                                                                                                                                                                                                                   | no reader                                  |
| hdr +0x0b               | `reserved_0b` (3 B)                                                            | 5a 5a 5a in every bank, from `Demo_StyleRhythmData` (`AccDemo_LoadRhythm`); no reader                                                                                                                                                                  | no reader                                  |
| hdr +0x0e               | `password` (u16)                                                               | `FmmPasswordFunc` (EVT_SET_PASSWORD) writes the entered password through `SetCurrentSlotIndex` (`file_io/medley.s`) and into +0x1c of all ten song slots (`ClearAllSongSlots`); `GetCurrentSlotIndex` reads it. The json said "medley slot"            | established; json corrected                |
| hdr +0x10               | `composer_mode`                                                                | `AcCmpMdBoxProc` shows (0x94810) in the COMPOSER MODE screen's boxes " NORMAL MODE:" (.ram 0) and " EXPAND MODE:" (.ram 1) and `CmpSetP1_TtlDispatch` stores the choice; `AccPatch_ConvertLegacyStyleImage` reloads intros / fill-ins / endings when 0 | established                                |
| hdr +0x11, +0x15, +0x1d | `reserved_11`, `reserved_15`, `reserved_1d`                                    | constant in every bank (01 01 01 01 02 02 02 02 at +0x15), from `Demo_StyleRhythmData`; no reader                                                                                                                                                      | no reader                                  |
| hdr +0x1e               | `capacity16`                                                                   | no reader of the word; the firmware hard-codes the same 0x16800 (`MidiPkt_SetXferTotal_StyleImage`)                                                                                                                                                    | hard-coded value                           |
| hdr +0x20..+0x2b        | `dir_offset` .. `name_offset`                                                  | no reader of the words; the code hard-codes 0x60 (0x94860, `RhythmTiming_OffsetTable`), 30 (`AccDemo_LoadVariation` `cp a, 0x1e`), 0x100, 340 (`cp wa, 0x154`), 0x40 (`Tempo_DisplayMeasureRange`)                                                     | hard-coded values                          |
| hdr +0x2c               | `reserved_2c`                                                                  | 0; no reader                                                                                                                                                                                                                                           | no reader                                  |
| hdr +0x30               | `reserved_30` (48 B)                                                           | 0 in every bank; no reader                                                                                                                                                                                                                             | no reader                                  |
| rec +0x00..+0x0a        | `drum_cell`, `reserved_02`, `bass_cell`, `acc1_cell`, `acc2_cell`, `acc3_cell` | `MapBitFlagsToChannelOffset`: DRUM 0, BASS 4, ACCOMP1 6, ACCOMP2 8, ACCOMP3 10; it never yields 2                                                                                                                                                      | established                                |
| rec +0x0c               | `time_sig`                                                                     | `RhythmPatInit_LoadParams` -> STYLE_SECTION_TIME_SIG; `AccPatch_SetVoiceAndInit` writes it back; the TIME SIGNATURE strings (`RamInit_TimeSigPtrs`, 7 = 4/4)                                                                                           | established                                |
| rec +0x0d               | `last_measure`                                                                 | `RhythmPatInit_LoadParams` -> STYLE_SECTION_LAST_MEASURE; `RhythmProc_UpdateVoiceSentinels`, `Tempo_DisplayMeasureRange` write it; the MEASURE row prints it + 1                                                                                       | established                                |
| rec +0x0e               | `rec_chord`                                                                    | the RECORD SETTING rows of `CmSetP1Grid` (KEY, CHORD, BASS TYPE, ACCOMP TYPE): bits 0-3 key, 4 minor, 5 accomp 7th, 6 bass 7th (`RhythmPatInit_LoadParams`, `RhythmProc_CheckConfigBits`, `UI_COMPONENT_DISPATCH_CASE2`..`5`)                          | established                                |
| rec +0x0f               | `edit_flags`                                                                   | bit 7: MEASURE / TIME SIGNATURE changeable, shown "(ENABLE)"; `DrumVoice_Handler0/1` refuse with error 19 when clear; `Tempo_DisplayMeasureRange`, `AccPatch_InitSlotAndCopyData` clear it                                                             | established                                |
| rec +0x10, +0x11        | `style_number`, `style_group`                                                  | a PANEL_STYLE pair: `DrumVoice_Handler7_Helper_Helper` stores PANEL_STYLE there, `RhythmVariation_Select_Entry_Data` puts it back, `AccTone_CheckBit3Flag` sends it on PROGRAM_CHANGE_PART 72; defaults from `AccPatch_VoiceStrideTable`               | established; json ("tone_pair") corrected  |
| rec +0x12               | `reserved_12` (6 B)                                                            | 0 in all 2,250 floppy and 150 IC19 records; no reader                                                                                                                                                                                                  | no reader                                  |
| rec +0x18 + 8 i         | `style_part` DRUM, BASS, ACCOMP1-3                                             | `MainCmpSetFunc` (rec + 16 + 8 * grid row), `AccPedal_DirectionA_Wrap_Helper2` (rec + 24 + 8 * i), `AccPatch_ChannelBitToIndex`; the CmpSetGrid rows "-", BASS, ACCOMP1-3                                                                              | established; json part numbering corrected |
| part +0, +1             | `sound`, `bank`                                                                | `AccPatch_SyncVoice_*` write them from PANEL_PART_DRUM / _BASS / _ACC* (+1 & 0x7f; DRUM & 0x0f); `AccVoiceReg_WritePart1`..`5` write them back                                                                                                         | established                                |
| part +2                 | `pan`                                                                          | PANPOT column, `MainCmpSetFunc` EVT_PAN_UP / _DN 0..127; `AccPatch_ResetSectionPartByte2Defaults` 64, 12, 116, 64                                                                                                                                      | established                                |
| part +3                 | `reverb`                                                                       | `AccPatch_SyncVoice_*` from bit 6 of the panel part's +4 (reverb on); `AccVoiceReg_WritePart2`..`5` put it back                                                                                                                                        | established                                |
| part +4                 | `pc_byte4`                                                                     | the fifth byte of the part's program-change record (`AccPatch_LoadVoiceParams` -> ACC_EVENT+4, `AccVoice_LoadAllChannelParams`); 80 in the default image                                                                                               | [INFERENCE]: its use not traced            |
| part +5                 | `pitch_point`                                                                  | PITCH POINT column, `MainCmpSetFunc` EVT_RLMT_UP / _DN 0..11; the lane copy 0x32c3.. is the wrap point of `Rhythm_TransposeNote`                                                                                                                       | established                                |
| part +6                 | `high_key`                                                                     | the lane copy 0x32c7.. -> 0x32cc, the limit `Rhythm_Transp_WrapCheck` folds transposed notes below (when >= 12)                                                                                                                                        | established; bit 7 (0xff) [INFERENCE]      |
| part +7                 | `reserved_7`                                                                   | not in the 7-byte lane copy; 0                                                                                                                                                                                                                         | no reader                                  |
| rec +0x40               | `name`                                                                         | `Tempo_DisplayMeasureRange` writes it                                                                                                                                                                                                                  | established                                |
| rec +0x50               | `reserved_50` (16 B)                                                           | `AccDemo_SectionRecordTail`'s zeros; 0 in every record; no reader                                                                                                                                                                                      | no reader                                  |
| +0xba0                  | `chord_map[5]`                                                                 | `TimeSig_DisplayStrings_Helper` (base + 0xba0 + 32 * (0x390a)); `CmpNcp_StepSlotInGroup2` copies +0..+3 (four variations, 0..11 or 0xff) to 0x390e; selecting map n sets PANEL_STYLE = 0xf0 + n; the "COMPOSER CHORD MAP" message                      | established                                |
| +0xc40                  | `measure_start[12][5][8]`                                                      | `AccVoice_GetMeasureStartBlock` / `_Helper2` (base + 0xc40 + 160 s + 32 i + 4 m), `AccPatch_StoreMeasureCursor`; {cell, offset}                                                                                                                        | established                                |

Measured over the 75 floppy CMPs (`notes/floppy-kn5000-2026-10-29/probes/cmp_var.py`): the header bytes +0x04..+0x1d
are the same in all 75 files except +0x10 (1 in 72, 0 in 3); the chord maps are in the shape above in 69 files and
zero in 3; in 3 (ca5010 `04LATIN`, `14}DEMO`, mix5000 `06STMMIX`) the whole +0xba0..+0x13bf area holds stale
cell-shaped bytes, which the describer keeps as bytes and says so. The IC19 banks have both tables zero.

**"No reader"** means the probe's two searches found nothing and the hits it did list were read and are other
data: ABS (an absolute operand 0x94800 + off in any v10 `.s` / `.c`) and IMG (a displacement after an instruction
that loads a style-image base: RHYTHM_PATTERN_BUF_A / _PTR, STYLE_SRC/DST/WORK_IMAGE_PTR, the work image 0x69800,
a Custom Data Flash section base). The probe's REC search (displacements after a section-record pointer) found the
record readers above.

### Names in the firmware that this changes

Several v10 routine names now read wrong. They were left as they are (renaming them across v10 / v9 / v7 / v6 / v5
is a separate change), and are listed so that the next naming pass can fix them:

| routine                                                  | what it does                                                          |
|----------------------------------------------------------|-----------------------------------------------------------------------|
| `SetCurrentSlotIndex` / `GetCurrentSlotIndex` (medley.s) | set / get the Composer password, style image +0x0e                    |
| `AccPatch_VoiceStrideTable`                              | the default style pair per time signature                             |
| `AccPatch_SyncVoice_Rhythm` / `AccPatch_SyncVoice_Bass`  | swapped: the first syncs BASS (+0x20), the second DRUM (+0x18)        |
| `TimeSig_DisplayStrings_Helper`                          | the address of COMPOSER CHORD MAP (0x390a)                            |
| `DrumVoice_Handler0` .. `7`                              | the RECORD SETTING page's row handlers (MEASURE, TIME SIGNATURE, ...) |

## Probes

`probes/README.md` says what each script answers and how to run it.

## Website page draft (technics-docs, "Accompaniment style format", section "The section record")

> A Composer style is one 0x16800-byte image: a 0x60-byte header, 30 section records of 0x60 bytes (variations
> A/B/C 1-4, then intro, fill-in and ending 1-2 of A, B and C), the five COMPOSER CHORD MAPs at +0xba0, a
> measure-start table at +0xc40, a 64-byte fill-in cell at +0x13c0 and 340 cells of 256 bytes from +0x1400.
> The header holds the Composer password (+0x0e) and the NORMAL / EXPAND mode (+0x10). Each section record holds
> the first cells of its DRUM, BASS and ACCOMP1-3 parts, the time signature, the number of measures, the RECORD
> SETTING (key, major / minor, bass and accompaniment type), a flag that keeps the meter changeable until something
> is recorded, the preset style the section uses, and per part the sound, panpot, reverb, pitch point and upper
> note limit. The same layout is in the IC19 custom-data banks, the .CMP files and each section of an .RCM file.
