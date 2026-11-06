# KN5000 naming items of lane open6/kn5000-d (sub-lane `naming`, 2026-11-02)

Items: tracker issues `kn5000-j8z`, `kn5000-rld`, `kn5000-zc1` and notes item `N-edb08959`.  They continue
`notes/open4-kn5000-b/naming/README.md` ("What is left", items 2-4) and
`notes/kn5000-style-2026-10-31/README.md` ("Names in the firmware that this changes").

Nothing here changes a ROM byte.  Every rename is a sed rule applied to the `.s` / `.c` / `.h` / `.ld` files of
v10 / v9 / v7 / v6 / v5 maincpu (v8 is v9's source) or of v142 subcpu (v141 / v140 regenerated from it); the edits
a sed line cannot make (headers, one data respelling) are `scripts/renaming/open6_naming_patches.py`.

| item       | sed script(s)                                                                        | patch phase           |
|------------|--------------------------------------------------------------------------------------|-----------------------|
| kn5000-j8z | `scripts/renaming/rename_open6_j8z.sed`, `rename_open6_j8z_v142.sed`                 | `--j8z`, `--j8z-v142` |
| N-edb08959 | `scripts/renaming/rename_open6_style.sed`                                            | `--style`             |
| kn5000-rld | `scripts/renaming/rename_open6_rld.sed`                                              | -                     |
| kn5000-zc1 | `scripts/renaming/rename_open6_zc1_<tree>.sed` (written by `open6_zc1_voiceslot.py`) | `--zc1`               |

Probes (`probes/README.md` says what each answers and how to run it):
`table_reader_scan.py`, `swbt_listener_owners.py`, `voiceslot_family.py`, `rld_record_status.py`.

(The sections below are filled in as each item lands.)

## kn5000-j8z

### RhythmProc_ChannelMapTable -> StyleSection_GroupBaseTable (data, was spelled as code)

`sequencer/accompaniment_engine.s`, after `RhythmProc_CopySlotData`: 30 bytes `00 00 00 00 04 04 04 04 08 08 08 08`
`00 x6 04 x6 08 x6`, decoded as `nop` / `max` / `ld (P2:8), 8:io` / `.fill`.  30 = the style sections
(STYLE_SECTION 0..29; `AccPatch_GetCurrentSlotAddr` caps at 0x1E) in the record order of
`scripts/build/style_bank_layout.py` SECTION_ROLE (A/B/C VARIATION 1-4, then A/B/C INTRO 1-2, FILL IN 1-2,
ENDING 1-2), and each byte is the index of its group's first VARIATION (0 = A, 4 = B, 8 = C).  Now six typed
`.byte` rows with a header.

**No reader exists.**  `probes/table_reader_scan.py` scans the v10 / v9 / v7 / v6 / v5 images for any 24/32-bit
little-endian value in [table - 32, table + 30) and any LDAR (f3 13 d16) landing there: the only hit in every tree is
the `call RhythmProc_CopySlotData` 0x1B bytes before the table.  The source has no symbolic reference either.  So
the reader the issue asked for is not in the program: the table is a leftover (the same bytes in every version).
The name says what the bytes mean; the header says nobody reads them.

### MainSysControl's INITIAL SETTING callees

`MainSysControl` (display/graphics_text_vga.s) dispatches EVT_SYS_INI through `MainSysControl_CaseTable`.  Each
callee was read; all five are the per-item resetters the earlier lane suspected:

| case (item)    | old name                       | new name                             | what the body does                                                                                                                                                           |
|----------------|--------------------------------|--------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 4 PANEL MEMORY | `Display_CopyAndRenderBitmaps` | `PanelMem_InitAllFromFactory`        | "HK" header template (record size 960, 80 records) to 0x1ED350, 0xA0 bytes of table data 0x99EC00 to 0x1ED360, the 80 memories, then the fix-ups                             |
|                | `VoiceData_InitAndCopyParams`  | `PanelMem_InitFromFactory`           | memory WA (< 80): clear 960 B at 0x1ED400 + 960 * WA, fill from table data 0x99ECA0 + 0x2A2 * WA and SndParamRam_DefaultImage + 0x7C                                         |
|                | `Display_ProcessBitmapTable`   | `PanelMem_ApplyFixups`               | PanelMem_FixupRecords: payload[off] = (payload[off] AND NOT mask) OR value in tag 0x43 of every memory                                                                       |
| 5 COMPOSER     | `AccDemo_InitDone`             | `Composer_ResetStyleImage`           | AccDemo_Init (empty built-in style into RHYTHM_PATTERN_BUF_A, 0x94800) + AccPatch_CountAvailableSlots                                                                        |
| 6 SEQUENCER    | `Part_InitFromPreset`          | `SeqSong_ResetAll`                   | song slots 0..10: DataBuf_InitSlotFromPreset, defaults at +0x1C .. +0x112, voice sub-blocks, pan                                                                             |
| 7 MSP USER     | `Voice_InitBankDataSafe`       | `MspUser_ResetToFactory`             | XIZ-preserving call of the next one                                                                                                                                          |
|                | `Voice_InitBankData`           | `MspUser_InitFromFactory`            | accompaniment block area 0x1E8800: Voice_InitBankTables, Voice_FactoryPresetData, 0x60 zero words, MSP_FACTORY_DEFAULTS to 0x1E8B00, CountAvailableVoiceSlots                |
| 8 SOUND MEMORY | `SendPartDataBlock_DoGetError` | `SoundRam_InitPhase2_ResetIfRamLost` | slot 2 of SoundRam_InitFuncTable: COMM(0xFF, 0xFF) when the RAM status byte 0x1E53E is 0xFF -- which MainSysControl itself sets (SubCPU_PayloadErrorStore) before every case |

The rest of `SoundRam_InitFuncTable` was named with it: slot 0 `SendPartDataBlock_ClearByte4` ->
`SoundRam_InitPhase0_SendImage` (id "KN5000 SOUND RAM" + checksum good: E1 bulk transfer of 0x72AA bytes to sub-CPU
0x7800, else COMM(0xFF, 0xFF)), slots 1 / 3 `SendPartDataBlock_Return4` / `_Return5` -> `SoundRam_InitPhase1_Nop` /
`SoundRam_InitPhase3_Nop`, and its helper `SendPartDataBlock_SetWord5` -> `SoundRam_ComputeChecksum` (the read twin of
`SoundRam_WriteChecksum`).  [INFERENCE] COMM(0xFF, 0xFF) tells the sub CPU there is no user sound image; nobody has
read the sub-CPU side of that packet.  The `SendPartDataBlock_Return5_*` branch labels inside the SoundRam_Convert*
routines keep their names (they belong to those routines; see "What is left").

### The remaining HdaeRom_* labels are panel-record listeners

The earlier lane took the remaining `HdaeRom_*` labels for sound-RAM conversion code.  They are not: every one
is reached only from a `SwbtB2_Code<NN>_Listeners` list of `ui_widgets/widget_dispatch.s`, the SwbtWr bank-2
callbacks for panel TLV record NN (`probes/swbt_listener_owners.py` prints the owner of each label, per tree;
the five trees agree).  Named as the earlier lane named their neighbours (`PanelTag60_ApplyEffectOnOff`,
`SwbtB2_Code69_NopListener`):

| old                                                                                                                  | new                                                                                               | record                                |
|----------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------|---------------------------------------|
| `HdaeRom_ProcessBlock`, `SwbtB2_Code63_Listener`, `HdaeRom_WriteParam`, `HdaeRom_CheckResult`, `HdaeRom_FinishBlock` | `PanelTag61/63/64/65/66_ApplyDspSlot`                                                             | DSP slots 0, 1, 4, 2, 3               |
| `HdaeRom_ReadParam_Epilogue`                                                                                         | `PanelTag63_ApplyDspSlot_Epilogue` (it is the 0x63 one's)                                         | 0x63                                  |
| `HdaeRom_ReadParam`, `_TableEntry0`, `_TableEntry1`, `_AltEntry`, `_AltTableEntry7`, `_AltTableEntry8`               | `SwbtB2_Code62/68/6A/80/B6/B7_NopListener`                                                        | lone `ret`s                           |
| `HdaeRom_AltReadParam`, `_AltProcessBlock`, `_AltCheckResult`                                                        | `PanelTag70_ApplyFields`, `PanelTag92_ApplyFields`, `PanelTag98_ApplyFieldsAndVolume`             | 0x70, 0x92, 0x98                      |
| `HdaeRom_AltTableEntry0..6`, `_AltTableEntry9`                                                                       | `PanelTagAE/B0/B1/B2/B3/B4/B5_ApplyFields`, `PanelTag43_ApplyFields`                              | 0xAE, 0xB0..0xB5, 0x43                |
| `HdaeRom_Entry`, `HdaeRom_TableEntry2`, `HdaeRomEntry2_SwitchOffsets` (v7 / v6 / v5 only)                            | `PanelTag60_ApplyEffectOnOff`, `PanelTag72_ApplyPartMix`, `PanelTag72_ApplyPartMix_SwitchOffsets` | v10's names, with v10's headers       |
| `HdaeRom_DataByteMap`                                                                                                | `SoundRam_ConvertNibbleMap`                                                                       | read by SoundRam_ConvertSounds_Helper |

DSP slot tags from `floppy/kn5000/panel_fields.py` (0x61 / 0x63 / 0x65 / 0x66 / 0x64 = slots 0..4).  The DSP-slot
listeners apply any change of payload bytes 0..24 as a change of byte 0 [INFERENCE: re-send the whole slot].

### v142 Voice_PanReg_WriteDispatchB -> TVF_Emit_Registers_Type2

Not "the second TVF word": it is `TVF_Emit_Registers`' twin for the type-2 voices (class (voice+1) & 0x3C = 0x10 in
`TVF_Refresh_Sounding_Voices`; `Voice_Init_Type2` calls it), with the mode from (tonerec+0x0F) & 7 instead of +0x36,
writing the same two staging words that `ToneGen_WriteVoice_TvfPair` sends to TG 0x100 / 0x140.  Its case arms
follow (`TVF_Emit_Registers_Type2_*`), and TVF_Emit_Registers' own inline case-5 arms `Voice_PanReg_Dispatch_Mode5_*`
became `TVF_Emit_Registers_Mode5_*`.  v141 / v140 regenerated (`create_v141/v140_subcpu_source.py`, `--check` in
the gate).


## N-edb08959: the style-bank renames

Each rename of the kn5000-style table was re-checked against the v10 body (and the v7 / v5 bodies, which carry the
same code under the same labels):

| old                                                                                           | new                                                                                                                            | evidence                                                                                                                                                         |
|-----------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `SetCurrentSlotIndex`, `GetCurrentSlotIndex` (file_io/medley.s)                               | `Composer_SetPassword`, `Composer_GetPassword`                                                                                 | word 0x9480E = style image +0x0E; `Password_ClearAndSetSlot` (EVT_SET_PASSWORD) stores the entered value with it after ClearAllSongSlots                         |
| `CheckIsCurrentSlot`, `CheckSlotIndexValid`                                                   | `Composer_IsPassword`, `Composer_HasPassword`                                                                                  | HL = (WA == password) / (password != 0); the password delete / save / set handlers are their only callers (not in the kn5000-style list; same word)              |
| `AccPatch_VoiceStrideTable`                                                                   | `AccPatch_DefaultStyleByTimeSig`                                                                                               | `AccPatch_SetVoiceAndInit` reads the word at 2 * STYLE_SECTION_TIME_SIG into record +0x10 / +0x11 (PANEL_STYLE pair); respelled as 20 `.byte number, group` rows |
| `AccPatch_SyncVoice_Rhythm`, `AccPatch_SyncVoice_Bass` (swapped)                              | `AccPatch_SyncVoice_Bass`, `AccPatch_SyncVoice_Drum`                                                                           | the first reads PANEL_PART_BASS into record +0x20, the second PANEL_PART_DRUM into +0x18 (locals `AccPatch_SyncRhythm_*` / `_SyncBass_*` follow)                 |
| `TimeSig_DisplayStrings_Helper` (v6 / v5: `DrumVoice_NotifyEE_Helper5`)                       | `ComposerChordMap_GetRecord`                                                                                                   | XIY = RHYTHM_PATTERN_BUF_A + 0xBA0 + 32 * (0x390A; v6/v5 0x3852), the COMPOSER CHORD MAP record; the v6/v5 port had a neighbour's name on it                     |
| `DrumVoice_Handler0` .. `7`                                                                   | `CmpRecSet_OnMeasure`, `_OnTimeSig`, `_OnKey`, `_OnChord`, `_OnBassType`, `_OnAccompType`, `_OnRhythmProgram`, `_OnRhythmBank` | fields: STYLE_SECTION_LAST_MEASURE 0..7, STYLE_SECTION_TIME_SIG 4..11, 0x34E9 key 0..11, 0x34EA bit 4 / bit 6 / bit 5, Rhythm_StepProgram, CmpSet_StepRhythmBank |
| `DrumVoice_DispatchTable`, `_Dispatch`, `_Select`, `_ClampMin`, `_InlineStub`, `_NullHandler` | `CmpRecSet_RowHandlers`, `_DispatchRow`, `_DispatchCursorRow`, `_DispatchCursorRow_Clamp`, `_DispatchRow_Wrap`, `_NopRow`      | the table and its dispatchers (index = cursor row (0x3540) - 1)                                                                                                  |

The `CmpRecSet_OnBassType_Code_*` labels sit in an unlabelled routine after `CmpRecSet_OnBassType` (it cycles bits 5 / 6
of 0x34EA together, 0 -> 64 -> 32 -> 96); it kept the prefix it had (`DrumVoice_Handler4_Code_*`).  Also unchanged:
`DrumVoice_NotifyEE` and `CmpSetTtl_DrumVoice0/1` (not read here).

## kn5000-rld: the 100 not-reviewed generic records

`probes/rld_record_status.py` looks each record's label up at its 2026-10-06 address: 90 of the 100 already carry
descriptive names given by later lanes (2026-10-07 .. 10-31).  The other ten were read and named here
(`scripts/renaming/rename_open6_rld.sed`): the four sound-editor filter-page static record lists (named from
their contents in `sound_editor_screens/se_setup_*.c`), `AccReplay_HandlePendingStop`, `AccSection_ApplyPendingChange`,
and three v7 / v6 / v5 labels that still had the generic name v10 / v9 had already replaced (same reader, same
bytes).  One (`NakaToggle_OnOff_Data`, the empty text of `FDTest_Group_OnOff`) is in the NAKA files of lane
kn5000-c and goes to the lead (`rename_naming.sed`), with three stale names quoted in NAKA C comments.  The verdict
for every record is in `rld-verdicts.md` (table) and `rld-verdicts.json`.

## kn5000-zc1: the VoiceSlot_* song-memory family

The 212 `VoiceSlot_*` labels defined in v10 `display/scoop_display.s` (212 v9, 214 v7, 204 v6 / v5; 1,108
references in v10) are the step sequencer's song-memory code, not voice-slot code.  The model, read from
`SeqTrack_AdvanceCursor` / `SeqTrack_ReadByteAndAdvance` (named earlier) and the bodies below:

- the **cursor** of track T = (SEQ_CURSOR_TRACK) is a block number (u16 at 0x0C9E + 2 * (T - 1)) and an offset 5..255
  (u8 at 0x0CBE + T - 1);
- **song blocks** are 256 bytes at (SEQ_BLOCK_POOL) + 256 * (block - 1) (`SeqBlock_Select` sets SEQ_BLOCK_PTR), with a
  5-byte header: flags, previous link (+1), next link (+3, 0xFFFF = none);
- **events** start with a status byte (`SeqEvent_CheckStatusByte`: 0x80..0x86 but 0x83, 0x90..0xD3 but 0xAn); 0x81 is
  the wrap / beat marker counted in SQSTEP_WRAP_COUNT, 0x82 the end, 0x84 a section end;
- eight **cursor snapshots** of 8 bytes at 0x0DFF (`SeqCursor_Save` / `_Restore`).

`probes/voiceslot_family.py` sorts the labels into routines (reached by call / calr / a pointer / another file) and
branch targets.  The routines were read one by one and named by hand (`ROUTINES` in
`scripts/renaming/open6_zc1_voiceslot.py`, the comment beside each the one-line reason); the cursor primitives' arms
too (`LOCALS`).  Every other label is a branch target and is renamed after the routine it sits in, keeping its
suffix (`VoiceSlot_StatusRet_Skip39` -> `SqStep_ShowCursorEventPopup_Skip39`), so a label is never named after a
routine it does not belong to (v7 `VoiceSlot_CheckCursorAtTrackStart_Loop2` sits in what is now
`SeqTrack_CheckEventFollows` and becomes `SeqTrack_CheckEventFollows_Loop2`).  The script writes one sed file per tree
(the trees differ: v6 / v5 call `SeqTrack_SkipWrapMarkers` `VoiceSlot_TableSetup_Helper`, v7 / v6 / v5 lack the two
`FinalRetZ` helpers, v6 / v5 have `SqStep_ShowTempoPopup` and one more empty pop-up stub); routine names are the same
in every tree.  Headers for 24 main routines: `open6_naming_patches.py --zc1` (they replace the "voice
selection" wording of the old headers).  `VoiceSlot_*` labels outside scoop_display.s (note_voice_mapping.s,
accompaniment_engine.s, demo_seq_bridge.s) are other families and were not touched.

| old (v10 unless noted)                        | new                                       | from the body                                                                                                         |
|-----------------------------------------------|-------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| `VoiceSlot_UpdateCurrentPointer`              | `SeqBlock_Select`                         | SEQ_BLOCK_PTR = pool + (IY - 1) * 256                                                                                 |
| `VoiceSlot_ComputeWordIndex`                  | `SeqTrack_WordIndex`                      | IZ = 2 * (SEQ_CURSOR_TRACK - 1)                                                                                       |
| `VoiceSlot_ComputeIndex`                      | `SeqTrack_TripleIndex`                    | IZ = 3 * (SEQ_CURSOR_TRACK - 1)                                                                                       |
| `VoiceSlot_ReadCurrentParams`                 | `SeqTrack_ReadCursorByte`                 | A = byte at the cursor                                                                                                |
| `VoiceSlot_WriteCurrentParam`                 | `SeqTrack_WriteCursorByte`                | byte at the cursor = W                                                                                                |
| `VoiceSlot_FlagCheck`                         | `SeqTrack_PeekNextByte`                   | SeqTrack_PeekAhead with 0x0DF5 = 1                                                                                    |
| `VoiceSlot_FlagCheckBody`                     | `SeqTrack_PeekSecondByte`                 | ... with 0x0DF5 = 2                                                                                                   |
| `VoiceSlot_FlagCheckDone`                     | `SeqTrack_PeekAhead`                      | byte (0x0DF5) past the cursor, next block                                                                             |
| `VoiceSlot_FinalRetZ_0x11`                    | `SeqTrack_PeekNextByte_SaveRegs`          | A = E; PeekNextByte, XIY XIZ XHL kept                                                                                 |
| `VoiceSlot_FinalRetZ_0x1E`                    | `SeqTrack_ReadCursorByteOfTrack`          | cursor byte of track E (1-based)                                                                                      |
| `VoiceSlot_StatusCheck`                       | `SeqEvent_CheckStatusByte`                | W = 0 when A starts an event                                                                                          |
| `VoiceSlot_CompareRet`                        | `SeqTrack_StepEvent`                      | W = 0 one event on, W = 1 one event back                                                                              |
| `VoiceSlot_LoadAndDispatch`                   | `SeqTrack_NextEvent`                      |                                                                                                                       |
| `VoiceSlot_DispatchRet`                       | `SeqTrack_NextEventKeepWrapCount`         |                                                                                                                       |
| `VoiceSlot_CompareAndBranch`                  | `SeqTrack_PrevEvent`                      |                                                                                                                       |
| `VoiceSlot_StepCursorBack`                    | `SeqTrack_PrevEventKeepWrapCount`         |                                                                                                                       |
| `VoiceSlot_SubrRetZ`                          | `SeqTrack_DecWrapCount`                   | SQSTEP_WRAP_COUNT - 1, not below 0                                                                                    |
| `VoiceSlot_SkipByteAndRead`                   | `SeqTrack_SkipByteAndRead`                |                                                                                                                       |
| `VoiceSlot_SkipWrapMarkers`                   | `SeqTrack_SkipWrapMarkers`                |                                                                                                                       |
| `VoiceSlot_TableSetup_Helper`                 | `SeqTrack_SkipWrapMarkers`                | v6 / v5 spelling of the same routine                                                                                  |
| `VoiceSlot_CheckCursorAtTrackStart`           | `SeqTrack_CheckCursorAtStart`             |                                                                                                                       |
| `VoiceSlot_ReadParamsWithSaveRestore_Helper3` | `SeqTrack_CheckEventFollows`              |                                                                                                                       |
| `VoiceSlot_InitAndProcess`                    | `SeqTrack_WriteBytesAtCursor`             | BC bytes from (0x1101), cursor advanced                                                                               |
| `VoiceSlot_RetZ`                              | `SeqTrack_DeleteBytesAtCursor`            | W bytes (SqStep_DeleteEventAtCursor)                                                                                  |
| `VoiceSlot_SaveState`                         | `SeqCursor_Save`                          |                                                                                                                       |
| `VoiceSlot_RestoreState`                      | `SeqCursor_Restore`                       |                                                                                                                       |
| `VoiceSlot_CompareSavedMarkerCount`           | `SeqCursor_CompareSavedWrapCount`         | step-edit screens built on them                                                                                       |
| `VoiceSlot_TableSetup`                        | `SqStep_RebuildGridRows`                  | bit 0 of 0x0DD3: rows around the cursor                                                                               |
| `VoiceSlot_StatusRet`                         | `SqStep_ShowCursorEventPopup`             | the pop-up for the event at the cursor                                                                                |
| `VoiceSlot_IndexDone`                         | `SqStep_ShowCursorMarkerPopup`            | 0x81 / 0x82 / 0x84 at the cursor                                                                                      |
| `VoiceSlot_ReadParamsWithSaveRestore`         | `SqStep_WritePopupValueToEvent`           |                                                                                                                       |
| `VoiceSlot_StatusRet_Helper`                  | `SqStep_AuditionCursorNotes`              | 0x90 at the cursor: notes to SeqBuf                                                                                   |
| `VoiceSlot_StatusRet_Helper4`                 | `ParamPopup_EmptyStub4`                   | lone `ret`s among the ParamPopup_*                                                                                    |
| `VoiceSlot_StatusRet_Helper5`                 | `ParamPopup_EmptyStub5`                   |                                                                                                                       |
| `VoiceSlot_StatusRet_Helper6`                 | `ParamPopup_EmptyStub6`                   |                                                                                                                       |
| `VoiceSlot_StatusRet_Helper7`                 | `ParamPopup_EmptyStub7`                   |                                                                                                                       |
| `VoiceSlot_StatusRet_Helper8`                 | `ParamPopup_EmptyStub8`                   |                                                                                                                       |
| `VoiceSlot_StatusRet_Helper10`                | `ParamPopup_EmptyStub10`                  | v6 / v5                                                                                                               |
| `VoiceSlot_StatusRet_Helper11`                | `SqStep_ShowTempoPopup`                   | v6 / v5: "TEMPO=" line; since 2026-11-06 v7's `DisplayStr_RedrawStatusAndTempoLine` (scripts/tools/port_todo_hand.py) |
| `VoiceSlot_StatusRet_Tbl2`                    | `SqStep_ShowCursorEventPopup_NoteCodeMap` | 12 x u8 -> 0x0D61, note-event case                                                                                    |

## What is left

1. `SendPartDataBlock_*` (about 120 labels in audio/note_voice_mapping.s): most are sound-RAM record helpers, and
   the `SendPartDataBlock_Return5_*` ones are branch targets inside the `SoundRam_Convert*` routines; rename them after
   their owners with the zc1 method (`open6_zc1_voiceslot.py` generalises: owner = nearest routine label above).
2. The unlabelled routine after `CmpRecSet_OnBassType` (cycles bits 5 / 6 of 0x34EA) and its
   `CmpRecSet_OnBassType_Code_*` labels; `DrumVoice_NotifyEE` and `CmpSetTtl_DrumVoice0/1`.
3. The flag bits behind `AccReplay_HandlePendingStop` (0x347A.1) and `AccSection_ApplyPendingChange` (0x341F.0):
   read their setters and name the RAM bytes.
4. The sub-CPU side of COMM(0xFF, 0xFF) (`SoundRam_InitPhase0_SendImage` / `_InitPhase2_ResetIfRamLost`).
5. `MemConfig_Handler_1_Helper5` frees a block chain (it is `SeqTrack_DeleteBytesAtCursor`'s last step) and the
   `SeqBlockChain_*` labels inside `SeqTrack_AdvanceCursor`: name them with the song-memory model above.
6. The lead's `rename_naming.sed` (files outside this sub-lane: table data, HD-AE5000 event codes, floppy
   formats, a generator, NAKA files).

## Website page draft

The technics-docs pages that quote renamed labels (found by searching the pages for every old name of the
`rename_open6_*.sed` scripts; the docs lane applies them):

| page                         | old                                                                                                                                | new                                                                                                                                           |
|------------------------------|------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| audio-subsystem.md           | Part_InitFromPreset                                                                                                                | SeqSong_ResetAll                                                                                                                              |
| boot-sequence.md             | AccDemo_InitDone, SendPartDataBlock_ClearByte4, SendPartDataBlock_Return4, SendPartDataBlock_DoGetError, SendPartDataBlock_Return5 | Composer_ResetStyleImage, SoundRam_InitPhase0_SendImage, SoundRam_InitPhase1_Nop, SoundRam_InitPhase2_ResetIfRamLost, SoundRam_InitPhase3_Nop |
| firmware-v9-vs-v10.md        | SendPartDataBlock_DoGetError                                                                                                       | SoundRam_InitPhase2_ResetIfRamLost                                                                                                            |
| floppy-disk-formats.md       | SetCurrentSlotIndex, GetCurrentSlotIndex, DrumVoice_Handler0 / 1                                                                   | Composer_SetPassword, Composer_GetPassword, CmpRecSet_OnMeasure / CmpRecSet_OnTimeSig                                                         |
| panel-memory-factory-data.md | Display_CopyAndRenderBitmaps, VoiceData_InitAndCopyParams                                                                          | PanelMem_InitAllFromFactory, PanelMem_InitFromFactory                                                                                         |
| questions.md                 | SendPartDataBlock_DoGetError                                                                                                       | SoundRam_InitPhase2_ResetIfRamLost                                                                                                            |
| sequencer.md                 | Part_InitFromPreset                                                                                                                | SeqSong_ResetAll                                                                                                                              |
| sns-nmi-emulation.md         | Voice_InitBankData                                                                                                                 | MspUser_InitFromFactory                                                                                                                       |
| sound-parameter-protocol.md  | HdaeRom_ProcessBlock, SwbtB2_Code63_Listener                                                                                       | PanelTag61_ApplyDspSlot, PanelTag63_ApplyDspSlot (SwbtWr listeners of DSP slot records 0x61 / 0x63)                                           |

No page quotes a `VoiceSlot_*` name of the zc1 family or a kn5000-rld record.  Suggested text for
**sequencer.md** (a new short section, "Song memory: blocks and cursors"):

> Song data lives in 256-byte blocks at (SEQ_BLOCK_POOL) + 256 * (n - 1), chained through a 5-byte header (flags,
> previous block +1, next block +3, 0xFFFF = none).  Each track has a cursor -- a block number (word table 0x0C9E)
> and an offset 5..255 (byte table 0x0CBE) -- that `SeqTrack_ReadCursorByte`, `SeqTrack_StepEvent`,
> `SeqTrack_WriteBytesAtCursor` and `SeqTrack_DeleteBytesAtCursor` move and edit; events start with a status byte
> (0x80..0x86 except 0x83, 0x90..0xD3 except 0xAn), 0x81 marks a beat, 0x82 the end.  The step-edit screens save the
> cursor in eight 8-byte snapshots at 0x0DFF (`SeqCursor_Save` / `SeqCursor_Restore`).

## Checks run

- `make gate` (under the lane's build lock) after each item: exit 0 -- "PASS: every KN5000 image assembles with the
  pinned toolchain", "PASS: every rebuilt ROM is byte-identical", "PASS: every reference file matches its build".
- `python3 scripts/analysis/l2_symbol_reference.py --regen`, then `--check` (part of the gate): PASS.
- `python3 scripts/analysis/check_ported_labels.py` after the last item: v7 -> v6 same 34711, changed 11925,
  misplaced 112, only in v7 1326, only in v6 1163; v6 -> v5 same 44196, changed 3521, misplaced 16, only in v6 48,
  only in v5 11 (no earlier run is recorded to compare with; the renames give the same name to the same thing in
  every tree, so they can only turn "only in" pairs into "same").
