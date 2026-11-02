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

| offset                  | name                                                                           | evidence                                                                                                                                                                                                                                                                            | status                                     |
|-------------------------|--------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------|
| hdr +0x04               | `reserved_04` (7 B)                                                            | 0 in every bank; no ABS / IMG reader                                                                                                                                                                                                                                                | no reader                                  |
| hdr +0x0b               | `reserved_0b` (3 B)                                                            | 5a 5a 5a in every bank, from `Demo_StyleRhythmData` (`AccDemo_LoadRhythm`); no reader                                                                                                                                                                                               | no reader                                  |
| hdr +0x0e               | `password` (u16)                                                               | `FmmPasswordFunc` (EVT_SET_PASSWORD) writes the entered password through `SetCurrentSlotIndex` (`file_io/medley.s`) and into +0x1c of all ten song slots (`ClearAllSongSlots`); `GetCurrentSlotIndex` reads it. The json said "medley slot"                                         | established; json corrected                |
| hdr +0x10               | `composer_mode`                                                                | `AcCmpMdBoxProc` shows (0x94810) in the COMPOSER MODE screen's boxes " NORMAL MODE:" (.ram 0) and " EXPAND MODE:" (.ram 1) and `CmpSetP1_TtlDispatch` stores the choice; `AccPatch_ConvertLegacyStyleImage` reloads intros / fill-ins / endings when 0                              | established                                |
| hdr +0x11, +0x15, +0x1d | `reserved_11`, `reserved_15`, `reserved_1d`                                    | constant in every bank (01 01 01 01 02 02 02 02 at +0x15), from `Demo_StyleRhythmData`; no reader                                                                                                                                                                                   | no reader                                  |
| hdr +0x1e               | `capacity16`                                                                   | no reader of the word; the firmware hard-codes the same 0x16800 (`MidiPkt_SetXferTotal_StyleImage`)                                                                                                                                                                                 | hard-coded value                           |
| hdr +0x20..+0x2b        | `dir_offset` .. `name_offset`                                                  | no reader of the words; the code hard-codes 0x60 (0x94860, `RhythmTiming_OffsetTable`), 30 (`AccDemo_LoadVariation` `cp a, 0x1e`), 0x100, 340 (`cp wa, 0x154`), 0x40 (`Tempo_DisplayMeasureRange`)                                                                                  | hard-coded values                          |
| hdr +0x2c               | `reserved_2c`                                                                  | 0; no reader                                                                                                                                                                                                                                                                        | no reader                                  |
| hdr +0x30               | `reserved_30` (48 B)                                                           | 0 in every bank; no reader                                                                                                                                                                                                                                                          | no reader                                  |
| rec +0x00..+0x0a        | `drum_cell`, `reserved_02`, `bass_cell`, `acc1_cell`, `acc2_cell`, `acc3_cell` | `MapBitFlagsToChannelOffset`: DRUM 0, BASS 4, ACCOMP1 6, ACCOMP2 8, ACCOMP3 10; it never yields 2                                                                                                                                                                                   | established                                |
| rec +0x0c               | `time_sig`                                                                     | `RhythmPatInit_LoadParams` -> STYLE_SECTION_TIME_SIG; `AccPatch_SetVoiceAndInit` writes it back; the TIME SIGNATURE strings (`RamInit_TimeSigPtrs`, 7 = 4/4)                                                                                                                        | established                                |
| rec +0x0d               | `last_measure`                                                                 | `RhythmPatInit_LoadParams` -> STYLE_SECTION_LAST_MEASURE; `RhythmProc_UpdateVoiceSentinels`, `Tempo_DisplayMeasureRange` write it; the MEASURE row prints it + 1                                                                                                                    | established                                |
| rec +0x0e               | `rec_chord`                                                                    | the RECORD SETTING rows of `CmSetP1Grid` (KEY, CHORD, BASS TYPE, ACCOMP TYPE): bits 0-3 key, 4 minor, 5 accomp 7th, 6 bass 7th (`RhythmPatInit_LoadParams`, `RhythmProc_CheckConfigBits`, `UI_COMPONENT_DISPATCH_CASE2`..`5`)                                                       | established                                |
| rec +0x0f               | `edit_flags`                                                                   | bit 7: MEASURE / TIME SIGNATURE changeable, shown "(ENABLE)"; `DrumVoice_Handler0/1` refuse with error 19 when clear; `Tempo_DisplayMeasureRange`, `AccPatch_InitSlotAndCopyData` clear it                                                                                          | established                                |
| rec +0x10, +0x11        | `style_number`, `style_group`                                                  | a PANEL_STYLE pair: `DrumVoice_Handler7_Helper_Helper` stores PANEL_STYLE there, `RhythmVariation_Select_Entry_Data` puts it back, `AccTone_CheckBit3Flag` sends it on PROGRAM_CHANGE_PART 72; defaults from `AccPatch_VoiceStrideTable`                                            | established; json ("tone_pair") corrected  |
| rec +0x12               | `reserved_12` (6 B)                                                            | 0 in all 2,250 floppy and 150 IC19 records; no reader                                                                                                                                                                                                                               | no reader                                  |
| rec +0x18 + 8 i         | `style_part` DRUM, BASS, ACCOMP1-3                                             | `MainCmpSetFunc` (rec + 16 + 8 * grid row), `AccPedal_DirectionA_Wrap_Helper2` (rec + 24 + 8 * i), `AccPatch_ChannelBitToIndex`; the CmpSetGrid rows "-", BASS, ACCOMP1-3                                                                                                           | established; json part numbering corrected |
| part +0, +1             | `sound`, `bank`                                                                | `AccPatch_SyncVoice_*` write them from PANEL_PART_DRUM / _BASS / _ACC* (+1 & 0x7f; DRUM & 0x0f); `AccVoiceReg_WritePart1`..`5` write them back                                                                                                                                      | established                                |
| part +2                 | `pan`                                                                          | PANPOT column, `MainCmpSetFunc` EVT_PAN_UP / _DN 0..127; `AccPatch_ResetSectionPartByte2Defaults` 64, 12, 116, 64                                                                                                                                                                   | established                                |
| part +3                 | `digital_effect`                                                               | `AccPatch_SyncVoice_*` from bit 6 of the panel part's +4, the SndParam parameter DIGITAL EFFECT (`SndParam_PartTT_DigitalEffect`, Lsw number 0x5e; analysis/disk-format-probes' "reverb on" for that bit is corrected by the descriptor); `AccVoiceReg_WritePart2`..`5` put it back | established                                |
| part +4                 | `pc_byte4`                                                                     | the fifth byte of the part's program-change record (`AccPatch_LoadVoiceParams` -> ACC_EVENT+4, `AccVoice_LoadAllChannelParams`); 80 in the default image                                                                                                                            | [INFERENCE]: its use not traced            |
| part +5                 | `pitch_point`                                                                  | PITCH POINT column, `MainCmpSetFunc` EVT_RLMT_UP / _DN 0..11; the lane copy 0x32c3.. is the wrap point of `Rhythm_TransposeNote`                                                                                                                                                    | established                                |
| part +6                 | `high_key`                                                                     | the lane copy 0x32c7.. -> 0x32cc, the limit `Rhythm_Transp_WrapCheck` folds transposed notes below (when >= 12)                                                                                                                                                                     | established; bit 7 (0xff) [INFERENCE]      |
| part +7                 | `reserved_7`                                                                   | not in the 7-byte lane copy; 0                                                                                                                                                                                                                                                      | no reader                                  |
| rec +0x40               | `name`                                                                         | `Tempo_DisplayMeasureRange` writes it                                                                                                                                                                                                                                               | established                                |
| rec +0x50               | `reserved_50` (16 B)                                                           | `AccDemo_SectionRecordTail`'s zeros; 0 in every record; no reader                                                                                                                                                                                                                   | no reader                                  |
| +0xba0                  | `chord_map[5]`                                                                 | `TimeSig_DisplayStrings_Helper` (base + 0xba0 + 32 * (0x390a)); `CmpNcp_StepSlotInGroup2` copies +0..+3 (four variations, 0..11 or 0xff) to 0x390e; selecting map n sets PANEL_STYLE = 0xf0 + n; the "COMPOSER CHORD MAP" message                                                   | established                                |
| +0xc40                  | `measure_start[12][5][8]`                                                      | `AccVoice_GetMeasureStartBlock` / `_Helper2` (base + 0xc40 + 160 s + 32 i + 4 m), `AccPatch_StoreMeasureCursor`; {cell, offset}                                                                                                                                                     | established                                |

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

## The floppy fields (the other items of this lane)

### Panel records: named from the firmware's SndParam descriptor table

Every editable panel setting has a SndParam descriptor: {key, bank_index = the record's TLV tag, bank_offset = the
payload byte, mask, clamp range, ...} (974 records, `v10/maincpu/audio/sndparam_records/`; technics-docs
`panel-parameter-keys.md`). `floppy/kn5000/panel_fields.py` now names each payload byte from the descriptors that
hold it; a byte with several parameters becomes one macro argument per parameter, each shifted to its mask. Where
no descriptor covers a byte, the curated name of `analysis/disk-format-probes/` stays; a byte with neither, that
the load rule zeroes and that no instruction names directly in v5..v10 (`probes/panel_field_refs.py`, its result
committed as `notes/floppy-kn5000-2026-10-29/specs/panel_field_refs.json`), is `reserved_<offset>`. The others keep
`f<offset>` with "TODO: not named" and their reference count.

| macro arguments (all 43 record kinds, 818 in all)                                                | count |
|--------------------------------------------------------------------------------------------------|-------|
| named from a descriptor or the curated studies                                                   | 175   |
| named by the firmware's key only (`lsw_<n>`, `key_<k>`: the descriptor's label is a placeholder) | 33    |
| DSP slot parameters `p1`..`p23` (named per record, below)                                        | 23    |
| `reserved_<offset>` (zeroed on load, no descriptor, no reference)                                | 419   |
| `bits<off>_other` (bits of a described byte that no descriptor names)                            | 43    |
| `f<offset>`, still "TODO: not named"                                                             | 125   |

Before this lane the panel macros held 622 neutral names (`f<offset>`, `b<offset>` and the style bank's `gN_*` /
`t*`); 125 remain, each one with its search recorded in its macro comment. They are bytes the load rules check
(range / keep-bits) but that no descriptor and no direct instruction reaches: most are in the companion records
0xC0..0xD7, which `PanelTlv_ResolvePartCompanions` refreshes from each part's sound through
`SndParam_ResolveVoiceEntry`, and in tags 0x49, 0x72, 0x93, 0x99 and 0x9a.

Three readings of `analysis/disk-format-probes/README-lsw-part-record-fields.md` are corrected by the descriptors:
part +3 is VOLUME (bits 6:0) and MUTE (bit 7), not a DSP level; +4 bit 6 is DIGITAL EFFECT (Lsw number 0x5e) and
bit 3 SUSTAIN, not "reverb on" / "chorus on"; +7 is REVERB SEND, not the part volume; +9..+13 are KEY SHIFT, TUNING,
BEND RANGE and two bytes of MIDI / keyboard bit fields. So the part bytes the old TODOs named resolve as: b10 =
`tuning` (0x80 in every save = the centre value), b11 = `bend_range`, bit22 = Lsw number 0x605 (descriptor
`ExtPartParam_Entry_374`, no name), and b16, b18..b21, b23 are `reserved_<off>`.

**DSP slot records** (tags 0x61 0x63 0x64 0x65 0x66): +0 is the DSP effect number; the record's other bytes are
that effect's parameters in order, from the v10 tables `DspFxParamCountTable` (count), `DSPCfg_LookupAndExtract_
PtrTable` ({min, max, param id}, big-endian) and `DspParamName_Table` (`probes/dsp_slot_params.py`, committed as
`specs/dsp_effect_params.json`). A parameter whose range passes 255 takes two bytes, big-endian; one with a
negative minimum is a signed byte. Measured over the 23,487 DSP slot records of the floppies, that layout decodes
every saved record of 28 of the 44 effects used; it fails in some records of CHORUS (1,640 of 1,680 fit),
CONCERT REVERB 1 (1,613 of 1,719), WAVE REVERB 2, EXCITER and NO OPERATION, and in every record of the reverbs 18,
19, 21-26, GEQ (79), ROOM (88) and PEQ+S.DELAY (72), whose EQ-like parameters are packed two to a word (GEQ:
frequency << 6 | gain, by the values). Each DSP slot record line now carries its effect's parameter names; where
not every record fits, the comment says the packing is not established.

### The .LSW's 2 KB at RAM 0x1e7800: the Sound Arranger memory

`AccStyle_InitVRAM` fills RAM 0x1e7800..0x1e7fdf from `AccStyle_RamImage_1E7800`: a 16-byte header ("ZZZ",
"H\0K", 200, zeros) and 200 ten-byte records at 0x1e7810 + 10 * n, n = the panel style's index
(`AccHelper_ComputeVoiceOffset`). A record is the Sound Arranger's choice of sounds for that style: DRUM kit and
bank, then sound and bank of BASS, ACCOMP1, ACCOMP2, ACCOMP3, bit 7 of each bank byte = the part's DIGITAL EFFECT,
bit 7 of the DRUM bank byte = arranged. `AccVoiceState_Snapshot` writes them from PANEL_PART_DRUM .. _ACP3;
`AccTuning_LoadFromROM` reads them into the lane records when the arranged bit is set, which
`AccStyle_InlinedBlock_Skip2` sets. `describe_lsw` types the area with the `sndarg` macro; the census
`unknown-dump` opaque group of 63 files is gone.

### SQT slot header (`specs/sqt_slot_header.json`, generator `probes/write_sqt_spec.py`)

`probes/sqt_field_refs.py` searches every field of the song record in v5..v10 in four spellings (absolute address
or `SEQ_SONG_RECORD+n` or any `.equ` name in the record; displacements after a song-record base; the slot accessors
with a constant BC). Results:

| field (record offset)                           | new name                 | what the search shows                                                                                                                                                     |
|-------------------------------------------------|--------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| +0x07                                           | `written_only_07`        | Part_InitVoiceDefaults writes 0; no reader                                                                                                                                |
| +0x12, +0x40, +0xb7, +0xc1, +0xca, +0xcc        | `stale_<off>`            | nothing writes or reads them: RAM residue. +0xc1 is not the KN7000 .SQF's slot name; no KN5000 build has that field                                                       |
| +0x14 / +0x16 and +0x18 / +0x1a                 | (kept)                   | written only (Part_InitVoiceDefaults); no reader of +0x14..+0x1b, so the {offset/16, length} reading stays an inference resting on the values                             |
| +0x1c                                           | `password`               | the song password: FmmPasswordFunc (EVT_SET_PASSWORD) writes it into all ten slots; GetSongSlotValue, SMF_InitPlaybackState read it                                       |
| +0x42..+0x4d, +0x52, +0x77, +0xad, +0xb3..+0xb6 | `written_only_<off>`     | written by the song init; no reader                                                                                                                                       |
| +0x74, +0xab                                    | `written_only_74/_ab`    | set to 1 like the MDEL/MERS/MINS/MCP counts, but TT_SQQTZ / TT_SQVELOCNG keep their range in SQEDT_QTZ_LAST / SQEDT_VELOCNG_LAST (outside the record) and never read them |
| +0x113..+0x2df                                  | `reserved_113`           | zeroed by SeqInit_ClearPartDataLoop; nothing else touches it                                                                                                              |
| +0x6c0..+0x707                                  | `song_panel_block1_copy` | the first three block-1 records (0x17, 0x18, 0x98), typed with the panel macros; the copy stops six bytes into 0x98, whose last six bytes are older slot RAM              |
| +0x708..+0x7ff                                  | `stale_708`              | moved with the panel copy, written by no copy                                                                                                                             |

The old "count" names came from an analogy; the "password" name also corrects the json's "no writer of a non-zero
value found".

### TM sound record (`specs/tm_sound_record.json`, generator `probes/gen_tm_spec.py`)

`probes/tm_subcpu_refs.py` lists sub-CPU v1.42 reads through a tone-record pointer (Part_PatchRecord_Ptr, voice
slot +0x13) or a partial-block pointer (voice slot +0x17). Results: +0x12 = `partial_flag_codes`, four 2-bit codes
(one per partial): code 1 sets bit 15 of the partial's slot flag word (Partial_Build_Present_Word); +0x5b has no
sub-CPU reader (`unread_5b`); +0x62/+0x63 are read by the type-4/5 arms of the algorithm tables
(`algo45_params`); partial +0x06 is read by Voice_Pitch_ApplyPortamento (`porta_sel`, bits 2:0); partial +0x12 by
TVF_Build_Short and Voice_PitchPack_RouteB..D (`filter_b12`, shifted into bits 15:13 of the filter word); partial
+0x01, +0x1d..+0x26, +0x38, +0x48 and the kit entry's +0x0e, +0x0f and layer +0x00 have no reader
(`unread_<off>`). The probe is a lower bound (a pointer kept on the stack is lost), so "no reader" means none in
`table_data/tone_database_records.s`'s reader analysis and none found by the probe.

### The non-mutual links and the two undecodable style chains

`probes/style_links.py` places each one: all 13 non-mutual style links and both chains that stop at 0x10 / 0x87
are in the stale cell-shaped blocks 12..19 (below the cell area +0x1400) of ca5010 `04LATIN.CMP`, `14}DEMO.CMP`
and mix5000 `06STMMIX.CMP`, unreachable from any directory record: the residue of an older layout, which the
firmware never follows (cells start at +0x1400, AccPatch_InitSlotChain). The 0x87 is the end-of-header byte of a
misaligned stale cell; the 0x10 sits inside a note event of the residue. The 7 non-mutual SQT links all leave
cells that are on no track chain and not on the free list (five `(DEMO)` files, cell 3; ca5008's cells 51 and 78):
orphans, not a second link convention.

## Probes

`probes/README.md` says what each script answers and how to run it.

## Website page draft (technics-docs, "Accompaniment style format", section "The section record")

> A Composer style is one 0x16800-byte image: a 0x60-byte header, 30 section records of 0x60 bytes (variations
> A/B/C 1-4, then intro, fill-in and ending 1-2 of A, B and C), the five COMPOSER CHORD MAPs at +0xba0, a
> measure-start table at +0xc40, a 64-byte fill-in cell at +0x13c0 and 340 cells of 256 bytes from +0x1400.
> The header holds the Composer password (+0x0e) and the NORMAL / EXPAND mode (+0x10). Each section record holds
> the first cells of its DRUM, BASS and ACCOMP1-3 parts, the time signature, the number of measures, the RECORD
> SETTING (key, major / minor, bass and accompaniment type), a flag that keeps the meter changeable until something
> is recorded, the preset style the section uses, and per part the sound, panpot, digital effect on/off, pitch point and upper
> note limit. The same layout is in the IC19 custom-data banks, the .CMP files and each section of an .RCM file.

## Website page draft (technics-docs, "KN5000 disk files", additions)

> **The last 2 KB of a .LSW file** are the Sound Arranger memory, RAM 0x1e7800: a 16-byte header and 200 ten-byte
> records, one per preset style, holding the DRUM kit and the BASS and ACCOMP1-3 sounds the player chose for that
> style (each with its DIGITAL EFFECT switch), and a flag that tells the accompaniment to use them instead of the
> style's own sounds.
>
> **Panel records, byte by byte.** Every editable panel setting has a parameter descriptor in the firmware that
> names the record (its tag), the byte and the bits that hold it, so the floppy sources name each byte after its
> setting: a part's sound, bank, volume and mute, sustain bits, DIGITAL EFFECT, DSP effect send, reverb send, pan,
> key shift, tuning, bend range and its MIDI bits; the style number, bank, APC mode and variation; the panel-memory
> filter switches; the metronome; and so on. A DSP effect slot holds the effect number and then that effect's
> parameters in order (DEPTH, LFO SPEED, ... from the effect's own parameter table).

## Left open (with the next step)

- **N-b64487fc** (sound record: envelope pair order, LFO captions, controller groups): envelopes and LFOs settled
  2026-11-02 (sub-lane open6-kn5000-d/panel, notes/open6-kn5000-d/panel/README.md section 3): the SOUND EDIT page
  handlers send each caption's value with the byte's offset as the element, so PITCH / AMPLITUDE / FILTER ENV are named
  byte by byte (time first, then level: ATK, PEAK, DECAY1, SUST1 ...), the twelve LFO entries are DEPTH, SPEED,
  TOUCH + KEYSYNC, WAVE + DELAY, and block +0x06 / +0x26 / +0x38 are the tones' LFO switches. The sub-CPU disagreement
  is two record kinds (tone block vs drum-kit instrument). Still open: the controller groups +0x14..+0x28 (next step:
  the SeCtr2 / SeCtr3 handlers, there).
- **125 panel bytes** keep `f<offset>`: 62 named 2026-11-02 (notes/open6-kn5000-d/panel/README.md section 1): the
  companion records 0xC0..0xD7 and 0x49 are the per-group "last sound / style" memory (`ptlv_part_vari`,
  `ptlv_style_vari`), the descriptor pattern no longer drops 11 descriptors, MSP bank and Composer bend range are
  named from their readers. 63 remain, each listed there with what is known.
- **DSP slot packing**: established 2026-11-02 for every effect (notes/open6-kn5000-d/panel/README.md section 2):
  `DSPCfg_ReadMultiField` / `DSPCfg_ReadField` give each parameter a width by its op letter (big-endian words, packed
  5/6-bit fields, bytes); every typed DSP slot record of the floppies decodes in range, and each is spelled with a
  per-effect macro.
- Renames this lane found but did not make (v10 / v9 / v7 / v6 / v5, a sed script each): the table under "Names
  in the firmware that this changes".
