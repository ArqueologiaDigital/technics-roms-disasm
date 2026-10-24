; ram_variables_by_use.s -- main-CPU RAM variables named from the code that uses them (audit WP17).
; The names and reasons are v10's (v10/maincpu/shared/ram_variables_by_use.s); the values here are
; v7's own, derived by scripts/tools/name_kn5000_ram.py from the same instructions in the same routines
; (a corrected line says so).  Names it could not derive for v7 are left out.
	.equ ACC_CLOCK,				0x0415	; accompaniment clock within the beat, 0..95 (INTTR4_CheckSeqEnable counts it, ClkTick_Src2FineBeatCheck by 4 per MIDI clock)
	.equ ACC_BEAT,				0x0416	; beat within the measure; INTTR4_SeqAutoStart compares it with ACC_BEATS_PER_BAR - 1, the BeatLed_*Masks show it on the START/STOP BEAT LEDs
	.equ ACC_BEATS_PER_BAR,			0x0433	; beats per measure of the style; 3 or 6 select the three-beat LED pattern (BeatLed_ThreeBeatMasks)
	.equ SEMENU_PART_MASK,			0x065e	; the sound editor's enabled parts, one bit per part (SeMenu_SetPartEnabled)
	.equ SEMENU_PART_MODE,			0x06ae	; the sound editor's part layout: 1 = 2 parts, else 4 (SeMenu_DrawPartSelector, SeMenu_DrawPartRadioButtons)
	.equ STYLE_WORK_IMAGE_PTR,		0x0c72	; the style work image (0x69800, set by Flash_InitExtMemAddrs); the legacy-image converters build there
	.equ TRACK_ASSIGN_CURSOR,		0x0cdf	; the track (0..15) the TRACK ASSIGN page's cursor is on; 8 = the second page (SqTrAs_Cursor*)
	.equ SQSTEP_CLOCK,			0x0d57	; clock within the beat at the song-data cursor, 0..95 (SqStep_AdvanceClockByStep, SqStep_SeekForwardByDistance store it)
	.equ SQSTEP_WRAP_COUNT,			0x0d58	; word: clock-wrap markers (0x81) passed since the start of the cursor track (SqStep_WriteClockWrapMarker increments it)
	.equ SQSTEP_UNITS,			0x0d5a	; word: whole 96-clock units from the start of the cursor track to the cursor; the seeks count it
	.equ SQSTEP_BEAT,			0x0d5c	; beat within the measure at the cursor, from 0
	.equ SQSTEP_MEASURE_BEATS,		0x0d5d	; beats in the cursor's measure: UIDisp_StepMeasureForward seeks (this) - SQSTEP_BEAT beats to the next measure
	.equ SEQ_SELECTED_TRACK,		0x0d60	; the selected track, 1..16; the status bar redraws when it changes (Display_UpdateRegion0_Check)
	.equ SQSTEP_DISPLAY_MODE,		0x0d65	; display mode of the cursor track, from its TRACK ASSIGN value: 1 = note track, 3 = RHYTHM track; (this) & 3 indexes DisplayMode_Dispatch_Tbl / SoundEvt_ModeDispatch_Tbl
	.equ SQSTEP_SEEK_UNITS,			0x0dcd	; distance in 96-clock units SqStep_SeekForwardByDistance moves the cursor; callers preset it
	.equ SQSTEP_SEEK_CLOCK,			0x0dce	; the clock (0..95) SqStep_SeekForwardByDistance stops on
	.equ STATUS_POPUP_ID,			0x0def	; the pop-up the status bar's region 0 shows: 1 accompaniment parameter, 2 incoming control line, 4 program change, 10 part parameter, 12 RHYTHM track (ParamPopup_*, Display_ModePopupDispatch, SqStep_SetPopupIdForDisplayMode)
	.equ SEQ_CURSOR_TRACK,			0x0eee	; the cursor track, 1..16, of the step-record and scoop screens (SqStep_SetDisplayModeFromTrack copies SEQ_SELECTED_TRACK into it)
	.equ SEQ_EVT_STATUS,			0x0fab	; status byte of the MIDI event the song player is executing (MidiEvent_*, MidiNoteOn_*); only the low nibble, the channel, is used
	.equ SEQ_EVT_DATA1,			0x0fac	; its first data byte (clamped to 0x7F with SEQ_EVT_DATA2 by MidiEvent_ClampVelocityA_High)
	.equ SEQ_EVT_DATA2,			0x0fad	; its second data byte
	.equ SEQ_EVENT_ABORT,			0x10e3	; 0 = carry on; 255 = the block chain ran out (ToneGen_AdvancePosition with no free block) or SeqTrack_ValidateAndAssignVoices found no dispatch slot.  The event handlers skip their register write when it is set and clear it after each event
	.equ SEQ_BLOCK_PTR,			0x10fd	; the 256-byte block being read or written: SMF_CalcPageAddress and its twins store SEQ_BLOCK_POOL + (n - 1) * 0x100 here; nested walks save and restore it
	.equ SEQ_BLOCK_POOL_COPY,		0x110a	; a copy of SEQ_BLOCK_POOL (DispatchHandler_* store it through `ld xhl, ...`), the base SeqNode_ResolveSlotPtr and SetWall_ResolveStreamPtr add to
	.equ SEQ_BLOCK_POOL,			0x1d5a	; base of the sequencer's pool of 256-byte data blocks: SeqInit_SetBaseAddress sets 0xB0000; block n (1-based) is at this + (n - 1) * 0x100
	.equ SEQ_DATA_OFFSET,			0x2666	; word: byte offset of the song-data cursor in SEQ_DATA_BLOCK, 5..255 (5 = first byte after the block header); at 255 ToneGen_AdvancePosition moves on to a new linked block
	.equ SEQ_START_MEASURE,			0x2668	; word: the measure playback starts from, sign-magnitude (0x8002 = 2 measures before measure 1): punch-in minus SEQ_COUNT_IN (SeqPlay_UpdateStartFromPunchIn)
	.equ SEQ_BLOCK_TOTAL,			0x286d	; word: blocks in the pool, 1240 (SeqInit_SetBaseAddress); DispatchHandler_InitAllSlots starts SEQ_FREE_BLOCKS from it, the song-usage percentages divide by it
	.equ TRACK_ASSIGN_EDIT_VALUE,		0x2873	; the TRACK ASSIGN value being edited, reloaded from SEQ_TRACK_ASSIGN when the cursor moves (SetWall_UpdateSlotIndex)
	.equ SEQ_TRACK,				0x2877	; the track (1..16) a sequencer operation or loop works on; 127 = all tracks (the edit titles' track 0x11, MainExeCall_OnTitleSq*); MainExe_SongMem* and SeqStep_MultiTrackProcess loop it over 1..16
	.equ SEQ_SONG,				0x2878	; the song (0..9) the song-memory routines (SeqVoice_InitEntry ...) address; SeqVoice_InitEntryForCurrentBank and SeqStep_TrackChange set it to SEQ_CURRENT_SONG or another song for one call and restore it
	.equ SEQ_WRITE_BLOCK_PTR,		0x2881	; the block SMF_Config* write output bytes into, at (this + IY); set from SEQ_BLOCK_PTR when a new block is started (IY = 5, past the block header)
	.equ SEQ_RTMCFG,			0x28a7	; rtmcfg, the firmware's own name (GetAdr_rtmcfg returns its address): sequencer / accompaniment playback flags; bit 2 = ignore incoming MIDI Start / Continue (Transport_EnableMidiStartContinue clears it)
	.equ SEQ_DATA_BLOCK,			0x28af	; word: block number of the song-data cursor the sequencer reads and writes through (with SEQ_DATA_OFFSET; SeqNode_ResolveSlotPtr turns it into SEQ_BLOCK_PTR)
	.equ SEQ_CYCLE_FLAGS,			0x28b1	; bit 0 = cycle play on (TT_SQCYCPLY), bit 1 = cycle recording on (TT_SQCYCREC; the record paths SeqMIDI_* test it) -- SeqAccomp_ParamDelivery_IncCycleEnable / SeqAccomp_SubChain_DecCycleEnable
	.equ SEQ_SCREEN_OBJECT,			0x2972	; the object EVT_PAINT gave the sequencer screen handlers (ApEditSyori, NoteEditSyori, ApPlaySyori, EffEditMain store its parameter); EVT_PARA_DRAW redraw requests are sent to it
	.equ ACC_PART_BIT,			0x3338	; the accompaniment part being set up or played, one-hot: 1, 2, 4, 8, 16, 32 (AccVoice_SetupKbd1, _SetupKbd2, _SetupAcc1 .. _SetupAcc4); AccStyle_ReadParamOffset picks that part's field of a style record by it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x33d4
	.equ ACC_EVENT,				0x3391	; [6 bytes] an event being built for an accompaniment ring buffer: +0 status, +1 the channel that picks the buffer, +2..+5 the data AccBuf_WriteNoteEvent / AccBuf_Write3ByteEvent copy (a velocity of 0 is written as 1); SqStep_ComputeStepAndGateTime keeps the step and gate lengths in +0..+3	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x342d
	.equ ACC_READ_OFFSET,			0x33ad	; word: offset in ACC_READ_BLOCK	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3449
	.equ ACC_READ_BLOCK,			0x33cf	; word: block of the pattern read position (AccPlayback_SaveReadPosition saves it with ACC_READ_OFFSET)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x346b
	.equ STYLE_FREE_BLOCKS,			0x3438	; word: free pattern blocks of the style image (190 when AccDemo_Init starts it; AccPatch_LinkNewPatternBlock takes one)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d4
	.equ STYLE_SECTION,			0x343a	; the style section being played or edited, 0..29 (variations 0-11, intros / fill-ins / endings 12-29); its 0x60-byte record is RHYTHM_PATTERN_BUF_A + 0x60 + 0x60 * n (AccPatch_GetCurrentSlotAddr)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d6
	.equ STYLE_SECTION_LAST_MEASURE,	0x343b	; last measure index of STYLE_SECTION (its record's +13, RhythmPatInit_LoadParams)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d7
	.equ STYLE_SECTION_TIME_SIG,		0x343c	; time-signature code of STYLE_SECTION (its record's +12)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d8
	.equ STYLE_SECTION_BEATS,		0x343d	; beats per measure of STYLE_SECTION: RhythmPatInit_KitIndexTable[time-signature code] (2/4/6/8 for x/2, 1..8 for x/4 and x/8)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d9
	.equ RHYTHM_LOAD_PROGRAM,		0x3451	; the rhythm RhythmROM_PatternDispatcher loads: below 0x80 a preset of RHYTHM_LOAD_BANK, 0x80 + n composer memory n	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34ed
	.equ RHYTHM_LOAD_BANK,			0x3452	; bank of RHYTHM_LOAD_PROGRAM	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34ee
	.equ RHYTHM_LOAD_PART,			0x3453	; part of that rhythm to load (4/5 intro, 10/11 fill-in, 6/7 ending; (this) & 15 indexes RhythmROM_LoadPattern_Data)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34ef
	.equ ACC_PATCH_CURSOR_BLOCK,		0x3576	; word: block of the pattern-data write cursor (AccPatch_CopyEventToCursor, AccPatch_StoreMeasureCursor)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3612
	.equ ACC_PATCH_CURSOR_OFFSET,		0x3578	; word: byte offset in that block; 6 is the first data byte after the block header	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3614
	.equ SQSTEP_MEASURE,			0x367e	; word: measure number at the cursor (DisplayStr_ShowMeasureNumber shows it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x371a
	.equ CMP_RECORD_PART,			0x36ff	; the Composer's record part, one-hot: 1, 2, 4 = ACP1-3, 8 = BASS, 16 = DRUM (MidiStream_PartEventMapTable, AccPatch_ChannelBitToIndex index by it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x379b
	.equ STYLE_COPY_SRC_SECTION,		0x3910	; AccPatch_CopySection copies this section of STYLE_SRC_IMAGE_PTR ...	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39ac
	.equ STYLE_COPY_DST_SECTION,		0x3911	; ... into this section of STYLE_DST_IMAGE_PTR	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39ad
	.equ STYLE_SRC_IMAGE_PTR,		0x3912	; the style image read from (usually RHYTHM_PATTERN_BUF_A; AccPatch_CountAvailableSlotsInAltImage points it at 0x69800 for a while)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39ae
	.equ STYLE_DST_IMAGE_PTR,		0x3916	; the style image AccPatch_CopySection writes to	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39b2
	.equ DISK_MEDIA_TYPE,			0x8464	; word: disk type code from GetDiskSizeInfo: 2 / 4 2DD, 3 2HD, 5 PD, 6-7 DOC, 0xFFFF none (DiskInfo_MediaTypeNames)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8500
	.equ SINGLE_LOAD_AREA,			0x895c	; the memory area of the single-load screens: 0 PANEL MEMORY, 1 SEQUENCER, 2 COMPOSER, 3 SOUND MEMORY, 4 none (SingleLoadSrc_ListProcByMode is indexed by it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x89f8
	.equ DISPLAY_CHORD_ROOT,		0x8ca4	; the chord MainChordPre shows: its root (copied from CHORD_ROOT by Chord_ApplyCurrentChord)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8d40
	.equ DISPLAY_CHORD_TYPE,		0x8ca6	; the chord MainChordPre shows: its type	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8d42
	.equ DISPLAY_CHORD_BASS,		0x8ca8	; the chord MainChordPre shows: its bass root, 0 unless it is an on-bass chord	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8d44
	.equ PROGRAM_CHANGE_PART,		0x905b	; the part a program change or sound selection is for: 0..31, 16-20 from the accompaniment chains (AccPatch_UpdateChain_*), 72 = the rhythm part	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x90f7
	.equ EXTDATA_TLV_OFFSET,		0x9093	; byte offset in the panel record (tag MIDI_MSG_STATUS) the ExtData_* handlers change	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x912f
	.equ EXTDATA_VALUE,			0x9094	; the received value; with EXTDATA_MASK a two-byte value for ExtData_SetTempoIfChanged	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9130
	.equ EXTDATA_MASK,			0x9095	; the bits of the record byte EXTDATA_VALUE may change (ExtData_SetTlvField)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9131
	.equ EXTDATA_NEW_VALUE,			0x9096	; the record byte after the change, also sent as MIDI_MSG_DATA2	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9132
	.equ MIDIRX_STATUS,			0x9598	; status byte of the MIDI message being received (MidiSerial_PumpLoop; MidiRx_ChannelMsgDispatch maps its channel to parts)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9634
	.equ MIDIRX_DATA1,			0x9599	; its first data byte (the controller number of a CC, the program of a program change)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9635
	.equ MIDIRX_DATA2,			0x959a	; its second data byte (the controller value the MidiCC_Handler_* read)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9636
	.equ MIDIRX_PART_EVENT,			0x95a8	; [4 bytes] the part-parameter event a MIDI receive handler builds: +0 target, +1 part, +2 value, +3 mask; MidiCC_QueuePartParam queues it on the SwbtWr queue	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9644
	.equ MIDIRX_PART,			0x95ce	; the part a received channel message is being applied to: MidiRx_ChannelMsgDispatch walks the parts the channel maps to and calls the handler for each	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x966a
	.equ MIDIRX_PARTS_LEFT,			0x95cf	; parts of that list still to do (MidiRx_ChannelMsgDispatch counts it down)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x966b
	.equ HARMONY_REF_NOTE,			0xce0e	; harmony reference note: the lowest note of the list Harmony_FindReferenceNote scans, if in 25..102, else 0xFF	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xceaa
	.equ HARMONY_REF_BYTE,			0xce0f	; the other byte of that note's list entry	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xceab
	.equ HARMONY_PREV_REF_NOTE,		0xce10	; the previous HARMONY_REF_NOTE	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xceac
	.equ HARMONY_PREV_REF_BYTE,		0xce11	; the previous HARMONY_REF_BYTE	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcead
	.equ CHORD_RECOGNIZE_DELAY,		0xce17	; ticks left before a delayed chord recognition (5 when started)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xceb3
	.equ CHORD_DECAY_TIMER,			0xce18	; ticks before a dropped key count is recognized (6 or 22: DecayTimer_SetShort / _SetLong)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xceb4
	.equ CHORD_FLAGS,			0xce42	; chord recognition flags: bit 7 = no chord (Chord_ClearRecognizedChord sets it), bit 1 = on-bass chord, bit 4 = recognize after a delay, bit 6 = recognize at once (Chord_RecognizeNowOrDelay)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcede
	.equ CHORD_TYPE,			0xce43	; type of the recognized chord (Chord_ApplyCurrentChord)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcedf
	.equ CHORD_ROOT,			0xce44	; root of the recognized chord	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcee0
	.equ CHORD_BASS_ROOT,			0xce45	; bass root of an on-bass chord	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcee1
	.equ CHORD_LAST_TYPE,			0xce46	; type of the last chord applied; recognition falls back to it when it finds none	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcee2
	.equ CHORD_LAST_ROOT,			0xce47	; root of the last chord applied	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcee3
	.equ CHORD_NOTE_COUNT,			0xce49	; notes in the chord note list that follows it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcee5
	.equ CHORD_NOTES,			0xce4a	; the chord's notes, in list order (CHORD_NOTE_COUNT of them)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcee6
	.equ CHORD_HELD_KEY_COUNT,		0xce63	; word: chord keys held	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xceff
	.equ CHORD_CHANGED,			0xce65	; word: Chord_ApplyCurrentChord sets the high byte to 0xFF; Voice_UpdatePlayModeState reports and clears it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcf01
	.equ CHORD_PREV_KEY_COUNT,		0xce7b	; word: chord keys held before the change being recognized (Chord_RecognizeNowOrDelay)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcf17
	.equ SEQ_SONG_RECORD,			0xf180	; [0x800 bytes] the current song's record: VoicePreset_LoadAndInitPan copies song SEQ_CURRENT_SONG's slot (SEQ_SONG_SLOTS + n * 0x800) in, SeqData_CopyBlockToBuffer copies it back
	.equ SEQ_TRACK_ASSIGN,			0xf1a0	; [16 bytes] TRACK ASSIGN value of each of the 16 tracks (13 CHORD, 14 APC, 15 CONTROL, 16 RHYTHM ...), part of SEQ_SONG_RECORD
	.equ SEQ_FREE_BLOCKS,			0xf231	; word: blocks still free; DispatchResolve_MarkCurrent takes one (sets bit 7 of its first byte, decrements); 0 makes ToneGen_AdvancePosition fail with SEQ_EVENT_ABORT = 255
	.equ SEQ_PUNCH_IN_MEASURE,		0xf238	; word: the punch-in ("P" in) measure of the play screen (MT_GetPInMeasString)
	.equ SEQ_PUNCH_OUT_MEASURE,		0xf23a	; word: the punch-out measure (SeqPlay_IncPunchOutMeasure keeps the punch-in below it)
	.equ SEQ_COUNT_IN,			0xf23f	; count-in measures before the punch-in (play-screen parameter 10)
	.equ SEQ_TRACK_TABLE,			0xf250	; [48 bytes] 16 three-byte track entries of the current song; bit 7 of the first byte = the track holds data (SqStep_CheckCursorTrackUsed); part of SEQ_SONG_RECORD
	.equ SEQ_CURRENT_SONG,			0xffe3	; the selected song, 0..9: its record is SEQ_SONG_SLOTS + n * 0x800 (Display_CopyToneTableToRAM, SetSongSlotValue); set when a song is loaded (SMF_FinalizeAndStartPlayback)
	.equ FILE_ERROR,			0x1e53c	; word: the file system's last error: FileOpen_CheckPermission stores 2, SeqStep_MemAllocFail 3, FileOpen_SlotExhausted 4, FileOpen_ErrorNoFile 7; FDC status codes are mapped into it (FDC_SetSectorLength)
	.equ NAMING_CHAR,			0x274de	; word: the character at the naming window's cursor, as an index into the character page (0x1A underscore, 0x25 space); the dial steps it
	.equ DRAW_ENABLED,			0x3044e	; word: 0 = nothing is drawn (ColorBlit, DrawBitmap and the other drawing primitives return); DrawWall sets 1
	.equ WALLPAPER_BITMAP,			0x30452	; the wallpaper bitmap, 320 bytes per row (ChangeWall_Impl stores it); colour 0xF5 draws by copying the pixel from it
	.equ PANEL_RECALL_BACKUP,		0x3c8e4	; [960 bytes] backup of the live panel records PANEL_RECORDS..+959, which a panel-memory recall restores the current style and MSP fields from
	.equ SDPART_ROW,			0x3e99e	; word: the selected row of the part list (IvSdpart_*, AcLswPartEdit*, PsMixer_*): row * 2 indexes the row's part
	.equ GFX_BG_COLOR,			0x3efa2	; word: background colour (Display_SetBackgroundColor stores it)
	.equ GFX_FG_COLOR,			0x3efa4	; word: foreground colour of the drawing primitives (GraphicsRender_ByteData stores it; the SeGfx ops and DrawText_* push it)
