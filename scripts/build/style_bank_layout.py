#!/usr/bin/env python3
"""The KN5000 Composer style bank's field layout, shared by both of its describers.

One bank is the RAM image of RHYTHM_PATTERN_BUF_A (0x94800): FileIO_SaveRegion3_ExtMem (v10 0xF87D2C) saves
it as a .CMP file, FileIO_SaveRcmFromFlash / FileIO_LoadRcmToFlash move it between an .RCM file and the
Custom Data Flash sections.  Two generators type it and both import this module, so they cannot name a
field differently:
  scripts/build/style_events.py   the IC19 custom-data banks and the table-data Composer image (listings);
  floppy/kn5000/formats.py        the .CMP files and the .RCM sections of the KN5000 floppies (macros in
                                  floppy/kn5000/include/kn5000_files.inc).
The owner adopted these readings on 2026-10-31 (notes/floppy-kn5000-2026-10-29/specs/style_bank_extra.json,
"adopted"); every field was checked against the v10 code that reads it.  The evidence is below and in
notes/kn5000-style-2026-10-31/README.md; the readers are listed by
notes/kn5000-style-2026-10-31/probes/style_bank_readers.py.  A field marked [INFERENCE] has no reader that
settles it.

HEADER (bank-relative)
  +0x00  "H\\0K\\0"                AccPatch_EnsureStyleImageHeader / AccPatch_ConvertLegacyStyleImage test it
  +0x04  reserved_04, 7 B       0 in every bank.  No reader (ABS and IMG rows of the probe: none)
  +0x0b  reserved_0b, 3 B       5a 5a 5a in every bank, copied from Demo_StyleRhythmData by AccDemo_LoadRhythm;
                                no reader
  +0x0e  password, u16          FmmPasswordFunc's EVT_SET_PASSWORD path writes the entered password here
                                (SetCurrentSlotIndex, file_io/medley.s) and the same word into +0x1c of all ten
                                song slots (ClearAllSongSlots / SetSongSlotValue); GetCurrentSlotIndex reads it
                                back.  0 (no password) in every bank
  +0x10  composer_mode          0 = NORMAL MODE, 1 = EXPAND MODE (own intro, fill-ins and ending): AcCmpMdBoxProc
                                shows (0x94810) on the COMPOSER MODE screen's two boxes (.ram 0 / 1) and stores the
                                selection (CmpSetP1_TtlDispatch); AccPatch_ConvertLegacyStyleImage loads the
                                intros / fill-ins / endings from the rhythm when it is 0
  +0x11  reserved_11, 4 B       0 in every bank; no reader
  +0x15  reserved_15, 8 B       01 01 01 01 02 02 02 02 in every bank (Demo_StyleRhythmData); no reader
  +0x1d  reserved_1d            0; no reader
  +0x1e  capacity16 0x1680      no reader of the word: the firmware hard-codes the same 0x16800
                                (MidiPkt_SetXferTotal_StyleImage, `add xwa, 0x16800`)
  +0x20  dir_offset 0x60, +0x22 record_size 0x60, +0x24 record_count 30, +0x26 cell_size 0x100,
         +0x28 cell_count 340, +0x2a name_offset 0x40: no reader of these words; the firmware hard-codes the
         values (0x94860 = base + 0x60 and RhythmTiming_OffsetTable's 0x60 stride; AccDemo_LoadVariation
         `cp a, 0x1e`; `cp wa, 0x154` in AccPatch_SeqAdvance_CheckLimit and its twins; 256-byte cells from
         +0x1400; the name at record +0x40, Tempo_DisplayMeasureRange `lda xwa, (xiz + 64)`)
  +0x2c  reserved_2c, u16       0; no reader
  +0x2e  used_size16            AccPatch_InitSlotChain writes it; cmp_sv_mae returns it * 16 as the .CMP size,
                                MidiPkt_GetUsedSize_StyleImage reads (0x9482e)
  +0x30  reserved_30, 48 B      0 in every bank; no reader

SECTION RECORD (bank + 0x60 + 0x60 * k, k = STYLE_SECTION 0..29)
  +0x00  drum_cell, +0x04 bass_cell, +0x06 acc1_cell, +0x08 acc2_cell, +0x0a acc3_cell: each part's first
         cell, (section nibble << 12) | cell entry.  MapBitFlagsToChannelOffset maps the one-hot part
         (CMP_RECORD_PART: 16 DRUM, 8 BASS, 1/2/4 ACCOMP1-3) to word offset 0 / 4 / 6 / 8 / 10
  +0x02  reserved_02, u16       the sixth lane's word; MapBitFlagsToChannelOffset never yields 2; 0 everywhere
  +0x0c  time_sig               index of the TIME SIGNATURE strings (RamInit_TimeSigPtrs: 0 = 1/2 .. 7 = 4/4 ..
                                15 = 4/8); RhythmPatInit_LoadParams copies it to STYLE_SECTION_TIME_SIG,
                                AccPatch_SetVoiceAndInit writes it back; DrumVoice_Handler1 steps it 4..11
  +0x0d  last_measure           MEASURE - 1 (0..7): RhythmPatInit_LoadParams -> STYLE_SECTION_LAST_MEASURE,
                                RhythmProc_UpdateVoiceSentinels writes it (& 7); the MEASURE row prints it + 1
  +0x0e  rec_chord              the RECORD SETTING rows (CmSetP1Grid): bits 0-3 KEY (RamInit_NoteNamePtrs,
                                C .. B), bit 4 CHORD MINOR, bit 5 ACCOMP TYPE 7th, bit 6 BASS TYPE 7th;
                                RhythmPatInit_LoadParams copies them to 0x34e9 / 0x34ea, RhythmProc_CheckConfigBits
                                writes them back
  +0x0f  edit_flags             bit 7: MEASURE and TIME SIGNATURE may still be changed (the row's "(ENABLE)" /
                                "(DISABLE)"; DrumVoice_Handler0/1 refuse with error 19 when clear).
                                RhythmPatInit_LoadParams copies it to bit 7 of 0x34ce; Tempo_DisplayMeasureRange and
                                AccPatch_InitSlotAndCopyData clear it once the section holds a recording
  +0x10  style_number, +0x11 style_group: a {number, group} pair in PANEL_STYLE's format.
                                DrumVoice_Handler7_Helper_Helper stores the panel style there, RhythmVariation_
                                Select_Entry_Data puts it back on the panel, AccTone_CheckBit3Flag sends it as a
                                program change of PROGRAM_CHANGE_PART 72 (the rhythm part); AccPatch_SetVoiceAndInit
                                / AccPatch_RefreshSlotOffset default it per time signature from
                                AccPatch_VoiceStrideTable
  +0x12  reserved_12, 6 B       0 in every record; no reader
  +0x18  five part settings of 8 bytes, DRUM BASS ACCOMP1 ACCOMP2 ACCOMP3 (+0x18 + 8 * i; i is
         AccPatch_ChannelBitToIndex's 0 DRUM, 1 BASS, 2-4 ACCOMP1-3; the CmpSetGrid rows "-", BASS, ACCOMP1-3;
         MainCmpSetFunc addresses record + 16 + 8 * row).  AccPedal_DirectionA_Wrap_Helper2 copies 7 of the 8
         bytes into the lane records at 0x3246 + 7 * i, AccPatch_ResolveEntryAddr_Helper all 8 to 0x37d1:
     +0  sound   +1 bank        AccPatch_SyncVoice_* write them from PANEL_PART_DRUM / _BASS / _ACC*: +0 and +1 &
                                0x7f (the DRUM sound masked to 0..15); AccVoiceReg_WritePart1..5 write them back
     +2  pan                    PANPOT column: MainCmpSetFunc on EVT_PAN_UP / _DN steps it 0..127;
                                AccPatch_ResetSectionPartByte2Defaults writes 64, 12, 116, 64 to the BASS..ACCOMP3
                                bytes on a legacy load
     +3  digital_effect         AccPatch_SyncVoice_* set it from bit 6 of the panel part's +4, the SndParam
                                parameter DIGITAL EFFECT (SndParam_PartTT_DigitalEffect, Lsw number 0x5e);
                                AccVoiceReg_WritePart2..5 put it back there
     +4  pc_byte4               the fifth byte of the part's program-change record (AccPatch_LoadVoiceParams ->
                                ACC_EVENT+4, sent by AccVoice_LoadAllChannelParams); 80 in the default image
                                [INFERENCE: what the tone generator does with it was not traced]
     +5  pitch_point            PITCH POINT column: MainCmpSetFunc on EVT_RLMT_UP / _DN steps it 0..11; the lane
                                copy (0x32c3..) is the point Rhythm_TransposeNote wraps transposed notes at
     +6  high_key               the lane copy (0x32c7..) is the upper limit Rhythm_Transp_WrapCheck folds a
                                transposed note below, octave by octave, when it is >= 12; 0x7f / 0xff = none
                                [INFERENCE: the meaning of bit 7 (0xff) is not traced]
     +7  reserved_7             not in the 7-byte lane copy; 0 everywhere
  +0x40  name, 16 B             Tempo_DisplayMeasureRange writes it when a recording ends; the pattern source name
  +0x50  reserved_50, 16 B      AccDemo_SectionRecordTail's zeros; 0 in every record; no reader

AFTER THE DIRECTORY
  +0xba0 chord_map[5], 32 B each: +0..+3 the four variations (0..11, 0xff = none) of COMPOSER CHORD MAP n
         (CmpNcp_StepSlotInGroup2 copies them to 0x390e and steps the selected one 0..11 / 0xff; selecting map n
         sets PANEL_STYLE = 0xf0 + n), +4 reserved 12 B, +16 the name ("chord map n", AccDemo_LoadVariation_
         DataBlock); TimeSig_DisplayStrings_Helper addresses base + 0xba0 + 32 * (0x390a)
  +0xc40 measure_start[12][5][8] of {u16 cell, u16 offset}: where measure m of part i of variation s starts
         (AccVoice_GetMeasureStartBlock / _Helper2 read base + 0xc40 + 160 * s + 32 * i + 4 * m;
         AccPatch_StoreMeasureCursor writes the record cursor there; AccDemo_LoadVariation_DataBlock's loop writes
         {5 * s + i, 6}); ends at +0x13c0, where the fill-in cell starts
"""

SECTION_ROLE = ['a-variation1', 'a-variation2', 'a-variation3', 'a-variation4',
                'b-variation1', 'b-variation2', 'b-variation3', 'b-variation4',
                'c-variation1', 'c-variation2', 'c-variation3', 'c-variation4',
                'a-intro 1', 'a-intro 2', 'a-fill in 1', 'a-fill in 2', 'a-ending 1', 'a-ending 2',
                'b-intro 1', 'b-intro 2', 'b-fill in 1', 'b-fill in 2', 'b-ending 1', 'b-ending 2',
                'c-intro 1', 'c-intro 2', 'c-fill in 1', 'c-fill in 2', 'c-ending 1', 'c-ending 2']

TIME_SIG = ['1/2', '2/2', '3/2', '4/2', '1/4', '2/4', '3/4', '4/4',
            '5/4', '6/4', '7/4', '8/4', '1/8', '2/8', '3/8', '4/8']          # RamInit_TimeSigPtrs
KEY = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']      # RamInit_NoteNamePtrs

# Header byte ranges that are not size words: (offset, length, name).
HEADER_BYTES = [(0x04, 7, 'reserved_04'), (0x0b, 3, 'reserved_0b'), (0x11, 4, 'reserved_11'),
                (0x15, 8, 'reserved_15'), (0x1d, 1, 'reserved_1d')]
# The u16 words from +0x1e (style_events.py prints record_count and cell_count in decimal).
HEADER_U16 = [(0x1e, 'capacity16'), (0x20, 'dir_offset'), (0x22, 'record_size'), (0x24, 'record_count'),
              (0x26, 'cell_size'), (0x28, 'cell_count'), (0x2a, 'name_offset'), (0x2c, 'reserved_2c'),
              (0x2e, 'used_size16')]
PASSWORD, COMPOSER_MODE = 0x0e, 0x10
RESERVED_30 = (0x30, 0x30)

# Section record: the part cells in record order (+0, +2 unused, +4, +6, +8, +0xa).
CELL_WORDS = ['drum_cell', 'reserved_02', 'bass_cell', 'acc1_cell', 'acc2_cell', 'acc3_cell']
PARTS = ['drum', 'bass', 'acc1', 'acc2', 'acc3']                              # +0x18 + 8 * i
PART_FIELDS = ['sound', 'bank', 'pan', 'digital_effect', 'pc_byte4', 'pitch_point', 'high_key', 'reserved_7']
PART_BASE, PART_SIZE = 0x18, 8
NAME_OFF, TAIL_OFF = 0x40, 0x50

CHORD_MAP_OFF, CHORD_MAPS, CHORD_MAP_SIZE = 0xBA0, 5, 32
MEASURE_OFF, MEASURE_VARS, MEASURE_PARTS, MEASURES = 0xC40, 12, 5, 8
FILLIN_OFF = 0x13C0
assert CHORD_MAP_OFF + CHORD_MAPS * CHORD_MAP_SIZE == MEASURE_OFF
assert MEASURE_OFF + MEASURE_VARS * MEASURE_PARTS * MEASURES * 4 == FILLIN_OFF


def rec_chord_fields(b):
    """+0x0e -> (key, minor, accomp_7th, bass_7th, bit7)."""
    return b & 0x0F, (b >> 4) & 1, (b >> 5) & 1, (b >> 6) & 1, b >> 7


def rec_chord_byte(key, minor, accomp_7th, bass_7th, bit7):
    assert 0 <= key < 16 and all(v in (0, 1) for v in (minor, accomp_7th, bass_7th, bit7))
    return key | minor << 4 | accomp_7th << 5 | bass_7th << 6 | bit7 << 7


def key_name(k):
    return KEY[k] if k < 12 else '?'


def time_sig_name(t):
    return TIME_SIG[t] if t < 16 else '?'
