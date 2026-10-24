; ram_variables_by_use.s -- main-CPU RAM variables named from the code that uses them (audit WP17), one
; line per variable, sorted by address.  Each comment says what the uses show: who writes it, with what,
; and how it is read (scripts/analysis/kn5000_ram_evidence.py prints that evidence for an address).
; Added by scripts/tools/add_kn5000_ram_names.py, which also rewrites the numeric operands.
	.equ NMI_GUARD,				0x0400	; 0x80 arms the power-fail NMI: NMI_StorePayloadChecksums stores the checksums only when it is set (Boot_DisplayScreen arms it)
	.equ BOOT_CONFIG_FLAGS,			0x0406	; bit 7 = boot finished normally (Boot_SetConfigFlag7 sets it in Boot_DisplayScreen, Boot_ClearConfigFlag7 clears it at the start of Boot_InitPeripherals)
	.equ ACC_CLOCK,				0x0415	; accompaniment clock within the beat, 0..95 (INTTR4_CheckSeqEnable counts it, ClkTick_Src2FineBeatCheck by 4 per MIDI clock)
	.equ ACC_BEAT,				0x0416	; beat within the measure; INTTR4_SeqAutoStart compares it with ACC_BEATS_PER_BAR - 1, the BeatLed_*Masks show it on the START/STOP BEAT LEDs
	.equ ACC_BEATS_PER_BAR,			0x0433	; beats per measure of the style; 3 or 6 select the three-beat LED pattern (BeatLed_ThreeBeatMasks)
	.equ MIDI_RX_CONTEXT,			0x0438	; [28 bytes] XWA, XBC, XDE, XHL, XIX, XIY, XIZ saved by MIDI_RX_CONTEXT_SAVE and put back by MIDI_RX_CONTEXT_RESTORE
	.equ TASK_CURRENT,			0x0487	; word: the TCB of the running task, 0 while the scheduler runs (TaskSched_FoundReadyTask sets it, TaskSched_Dispatch saves XSP at its +4)
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
	.equ ACC_STYLE_BANK,			0x3285	; the style's 64 KB rhythm-ROM bank, its record's byte +0x3D1 (AccStyle_SetupPartAddresses); pattern reads are 0x400000 + bank * 0x10000 + offset
	.equ ACC_LANE_READ_POS,			0x3287	; [12 bytes] per-lane read position, a word per lane (lanes in ACC_PART_BIT order): the signed 16-bit offset into the style's bank, starting at the lane pointer - 0x8000 + 6 (AccStyle_SetupPartAddresses); AccBuf_Advance steps it
	.equ ACC_LANE_SECTION,			0x32a3	; [6 bytes] per-lane section byte (sections are 5 apart; AccStyle_SelectSection writes all six)
	.equ ACC_LANE_BEAT_POS,			0x32ab	; [6 bytes] per-lane position: low nibble = beat in the measure, high nibble = measure (AccVoice_BarEnd_* step it)
	.equ ACC_STYLE_RECORD,			0x32ce	; the current style record in the rhythm ROM (AccStyle_ApplyExtendedStyle stores it)
	.equ ACC_STYLE_NUMBER,			0x32e5	; the style playing, 0..127 within ACC_STYLE_GROUP (below 0x80 a rhythm-ROM style; committed from ACC_PENDING_STYLE by AccStyle_ApplyChanges)
	.equ ACC_STYLE_GROUP,			0x32e6	; its group, 0..6 (the directory has 8 groups x 128 styles)
	.equ ACC_BAD_EVENT_COUNT,		0x32ed	; unknown pattern bytes the lane reader skipped; at 32 AccVoice_AdvanceAndCheckEnd stops the accompaniment
	.equ ACC_SCAN_BAD_EVENT_COUNT,		0x32ee	; the same count for AccSeq_FourChannelScan's pattern scanner (AccSeq_Scanner_Unknown)
	.equ ACC_PENDING_STYLE,			0x32f5	; style number sampled from PANEL_STYLE, applied by AccStyle_ApplyChanges; 0xFF forces a reload (the bad-event watchdogs store it)
	.equ ACC_PENDING_GROUP,			0x32f7	; group sampled from PANEL_STYLE+1 (low 3 bits used)
	.equ ACC_SECTION_REQUEST,		0x3305	; the 2-bit section request, (PANEL_STYLE+7 & 0x30) >> 4 (SeqCtl_StorePedalFlags)
	.equ ACC_PART_BIT,			0x33d4	; the accompaniment part being set up or played, one-hot: 1, 2, 4, 8, 16, 32 (AccVoice_SetupKbd1, _SetupKbd2, _SetupAcc1 .. _SetupAcc4); AccStyle_ReadParamOffset picks that part's field of a style record by it
	.equ ACC_CUR_SECTION,			0x33d5	; the lane being processed: its ACC_LANE_SECTION (AccVoice_SavePartState1 and its twins copy the lane in, *_RestoreState back)
	.equ ACC_CUR_READ_POS,			0x33d8	; word: the lane being processed: its ACC_LANE_READ_POS
	.equ ACC_CUR_BEAT_POS,			0x33db	; the lane being processed: its ACC_LANE_BEAT_POS
	.equ ACC_EVENT,				0x342d	; [6 bytes] the pattern event being decoded or built (docs/accompaniment-style-reader.md): +0 status, +1 position in the beat, +2 note, +3 velocity, +4/+5 duration; AccBuf_WriteNoteEvent copies all but +1 into a ring buffer, a zero duration as 1.  SqStep_ComputeStepAndGateTime keeps the step and gate lengths in +0..+3
	.equ ACC_READ_OFFSET,			0x3449	; word: offset in ACC_READ_BLOCK
	.equ ACC_READ_BLOCK,			0x346b	; word: block of the pattern read position (AccPlayback_SaveReadPosition saves it with ACC_READ_OFFSET)
	.equ STYLE_FREE_BLOCKS,			0x34d4	; word: free pattern blocks of the style image (190 when AccDemo_Init starts it; AccPatch_LinkNewPatternBlock takes one)
	.equ STYLE_SECTION,			0x34d6	; the style section being played or edited, 0..29 (variations 0-11, intros / fill-ins / endings 12-29); its 0x60-byte record is RHYTHM_PATTERN_BUF_A + 0x60 + 0x60 * n (AccPatch_GetCurrentSlotAddr)
	.equ STYLE_SECTION_LAST_MEASURE,	0x34d7	; last measure index of STYLE_SECTION (its record's +13, RhythmPatInit_LoadParams)
	.equ STYLE_SECTION_TIME_SIG,		0x34d8	; time-signature code of STYLE_SECTION (its record's +12)
	.equ STYLE_SECTION_BEATS,		0x34d9	; beats per measure of STYLE_SECTION: RhythmPatInit_KitIndexTable[time-signature code] (2/4/6/8 for x/2, 1..8 for x/4 and x/8)
	.equ RHYTHM_LOAD_PROGRAM,		0x34ed	; the rhythm RhythmROM_PatternDispatcher loads: below 0x80 a preset of RHYTHM_LOAD_BANK, 0x80 + n composer memory n
	.equ RHYTHM_LOAD_BANK,			0x34ee	; bank of RHYTHM_LOAD_PROGRAM
	.equ RHYTHM_LOAD_PART,			0x34ef	; part of that rhythm to load (4/5 intro, 10/11 fill-in, 6/7 ending; (this) & 15 indexes RhythmROM_LoadPattern_Data)
	.equ ACC_PATCH_CURSOR_BLOCK,		0x3612	; word: block of the pattern-data write cursor (AccPatch_CopyEventToCursor, AccPatch_StoreMeasureCursor)
	.equ ACC_PATCH_CURSOR_OFFSET,		0x3614	; word: byte offset in that block; 6 is the first data byte after the block header
	.equ SQSTEP_MEASURE,			0x371a	; word: measure number at the cursor (DisplayStr_ShowMeasureNumber shows it)
	.equ CMP_RECORD_PART,			0x379b	; the Composer's record part, one-hot: 1, 2, 4 = ACP1-3, 8 = BASS, 16 = DRUM (MidiStream_PartEventMapTable, AccPatch_ChannelBitToIndex index by it)
	.equ STYLE_COPY_SRC_SECTION,		0x39ac	; AccPatch_CopySection copies this section of STYLE_SRC_IMAGE_PTR ...
	.equ STYLE_COPY_DST_SECTION,		0x39ad	; ... into this section of STYLE_DST_IMAGE_PTR
	.equ STYLE_SRC_IMAGE_PTR,		0x39ae	; the style image read from (usually RHYTHM_PATTERN_BUF_A; AccPatch_CountAvailableSlotsInAltImage points it at 0x69800 for a while)
	.equ STYLE_DST_IMAGE_PTR,		0x39b2	; the style image AccPatch_CopySection writes to
	.equ DISK_MEDIA_TYPE,			0x8500	; word: disk type code from GetDiskSizeInfo: 2 / 4 2DD, 3 2HD, 5 PD, 6-7 DOC, 0xFFFF none (DiskInfo_MediaTypeNames)
	.equ SINGLE_LOAD_AREA,			0x89f8	; the memory area of the single-load screens: 0 PANEL MEMORY, 1 SEQUENCER, 2 COMPOSER, 3 SOUND MEMORY, 4 none (SingleLoadSrc_ListProcByMode is indexed by it)
	.equ FDC_PROBE_FLAG,			0x8a10	; word: 0xFFFF while a caller probes the disk format (a one-sector read of track 0, head 0 gets a single try: FDC_DETECT_CHECK, FDC_DRIVE_DETECT)
	.equ FDC_BUSY_LATCH,			0x8a16	; 0xA5 while a request runs, 0x5A when it ends; a request that finds 0xA5 fails with 0xFB (FDC_CommandEntry)
	.equ FDC_SECTOR_SIZE,			0x8a1e	; word: sector size, 0x200 or 0x400
	.equ FDC_INIT_FLAG,			0x8a20	; 0xFF once the controller is initialised (FDC_CONFIG_VERIFY)
	.equ FDC_CMD_OPCODE,			0x8a28	; the uPD765 command byte being issued (0xD1 / 0xD9 / 0xDD are the scan commands FDC_SendParams_ReadWrite sends STP for)
	.equ FDC_HEAD,				0x8a29	; head 0 or 1 for the command's unit/head byte (FDC_CheckHead copies the request's head; other values fail with 0xFE)
	.equ FDC_DRIVE,				0x8a2a	; drive 0 or 1 for the command's unit/head byte (FDC_CheckDriveCount copies the request's drive)
	.equ FDC_PARAM_C,			0x8a2b	; uPD765 parameter C, the cylinder (FDC_SendParams_ReadWrite)
	.equ FDC_PARAM_H,			0x8a2c	; parameter H, the head (bit 0 sent)
	.equ FDC_PARAM_R,			0x8a2d	; parameter R, the sector number
	.equ FDC_PARAM_N,			0x8a2e	; parameter N, the sector size code (bits 0-2 sent; also FORMAT TRACK's N)
	.equ FDC_PARAM_EOT,			0x8a2f	; parameter EOT, the last sector of the track
	.equ FDC_PARAM_GPL,			0x8a30	; parameter GPL, the gap length
	.equ FDC_PARAM_DTL,			0x8a31	; parameter DTL, the data length (0xFF from FDC_InitStateVars)
	.equ FDC_FORMAT_SC,			0x8a32	; FORMAT TRACK's SC, sectors per track (FDC_SendParams_Format)
	.equ FDC_FORMAT_GPL,			0x8a33	; FORMAT TRACK's gap length (80 / 108 / 116, FDC_MODE_CONFIG)
	.equ FDC_FORMAT_FILL,			0x8a34	; FORMAT TRACK's filler byte (0xE5)
	.equ FDC_PARAM_STP,			0x8a35	; the scan commands' STP (bits 0-1 sent instead of DTL)
	.equ FDC_SPECIFY_SRT,			0x8a37	; SPECIFY's step rate time (the high nibble of its first byte)
	.equ FDC_SPECIFY_HUT,			0x8a38	; SPECIFY's head unload time (the low nibble, 15 from FDC_InitStateVars)
	.equ FDC_SPECIFY_HLT,			0x8a39	; SPECIFY's head load time (bits 1-7 of its second byte, 1 from FDC_InitStateVars)
	.equ FDC_SPECIFY_ND,			0x8a3a	; SPECIFY's non-DMA bit (bit 0 of its second byte, 0 = DMA)
	.equ FDC_REQ_DRIVE,			0x8a42	; word: request +0x02, the drive (FDC_CommandEntry_CopyParams copies the caller's 16-byte request to FDC_COMMAND_INDEX..)
	.equ FDC_REQ_HEAD,			0x8a44	; word: request +0x04, the head (command 9 reads it as the new disk-changed flag)
	.equ FDC_REQ_TRACK,			0x8a46	; word: request +0x06, the track (command 0: the media-type code)
	.equ FDC_REQ_SECTOR,			0x8a48	; word: request +0x08, the starting sector (1-based)
	.equ FDC_REQ_COUNT,			0x8a4a	; word: request +0x0A, the sector count
	.equ FDC_REQ_BUFFER,			0x8a4c	; request +0x0C, the buffer address (the DMA memory address, advanced after each burst; a format points it at FDC_FORMAT_IDS)
	.equ FDC_REQUEST_COPY,			0x8a50	; [16 bytes] the second copy of the caller's request FDC_CommandEntry_CopyParams makes
	.equ FDC_RESULT,			0x8a60	; [7 bytes] the result-phase bytes FDC_ResultPhase_Read collects (ST0 first)
	.equ FDC_RETRY_COUNT,			0x8a68	; retries left: 8 for a read or write, 1 for a probe read; at 0 the command fails with error 16 (read) or 32 (write)
	.equ FDC_DISK_CHANGED,			0x8a6a	; disk-changed flag: command 9 sets 0xFF or 0; cleared at initialisation
	.equ FDC_DRIVE_MODE,			0x8a6c	; drive mode 0-5 (FDC_CONFIG_VERIFY's media cases)
	.equ FDC_FORMAT_IDS,			0x8a70	; the sector ID bytes a FORMAT TRACK sends by DMA (FDC_MODE_CONFIG_Helper2 builds them)
	.equ FDC_CURRENT_CYLINDER,		0x8b04	; the cylinder last sought to, 0xFF = unknown (FDC_CmdSeek compares it)
	.equ FDC_SECTOR_LIMIT,			0x8b0c	; word: one more than the sectors per track (10, 9 or 19 by media type); bounds the sector number in the read and write loops
	.equ DISPLAY_CHORD_ROOT,		0x8d40	; the chord MainChordPre shows: its root (copied from CHORD_ROOT by Chord_ApplyCurrentChord)
	.equ DISPLAY_CHORD_TYPE,		0x8d42	; the chord MainChordPre shows: its type
	.equ DISPLAY_CHORD_BASS,		0x8d44	; the chord MainChordPre shows: its bass root, 0 unless it is an on-bass chord
	.equ PROGRAM_CHANGE_PART,		0x90f7	; the part a program change or sound selection is for: 0..31, 16-20 from the accompaniment chains (AccPatch_UpdateChain_*), 72 = the rhythm part
	.equ EXTDATA_TLV_OFFSET,		0x912f	; byte offset in the panel record (tag MIDI_MSG_STATUS) the ExtData_* handlers change
	.equ EXTDATA_VALUE,			0x9130	; the received value; with EXTDATA_MASK a two-byte value for ExtData_SetTempoIfChanged
	.equ EXTDATA_MASK,			0x9131	; the bits of the record byte EXTDATA_VALUE may change (ExtData_SetTlvField)
	.equ EXTDATA_NEW_VALUE,			0x9132	; the record byte after the change, also sent as MIDI_MSG_DATA2
	.equ MIDIRX_STATUS,			0x9634	; status byte of the MIDI message being received (MidiSerial_PumpLoop; MidiRx_ChannelMsgDispatch maps its channel to parts)
	.equ MIDIRX_DATA1,			0x9635	; its first data byte (the controller number of a CC, the program of a program change)
	.equ MIDIRX_DATA2,			0x9636	; its second data byte (the controller value the MidiCC_Handler_* read)
	.equ MIDIRX_PART_EVENT,			0x9644	; [4 bytes] the part-parameter event a MIDI receive handler builds: +0 target, +1 part, +2 value, +3 mask; MidiCC_QueuePartParam queues it on the SwbtWr queue
	.equ MIDIRX_PART,			0x966a	; the part a received channel message is being applied to: MidiRx_ChannelMsgDispatch walks the parts the channel maps to and calls the handler for each
	.equ MIDIRX_PARTS_LEFT,			0x966b	; parts of that list still to do (MidiRx_ChannelMsgDispatch counts it down)
	.equ HARMONY_REF_NOTE,			0xceaa	; harmony reference note: the lowest note of the list Harmony_FindReferenceNote scans, if in 25..102, else 0xFF
	.equ HARMONY_REF_BYTE,			0xceab	; the other byte of that note's list entry
	.equ HARMONY_PREV_REF_NOTE,		0xceac	; the previous HARMONY_REF_NOTE
	.equ HARMONY_PREV_REF_BYTE,		0xcead	; the previous HARMONY_REF_BYTE
	.equ CHORD_RECOGNIZE_DELAY,		0xceb3	; ticks left before a delayed chord recognition (5 when started)
	.equ CHORD_DECAY_TIMER,			0xceb4	; ticks before a dropped key count is recognized (6 or 22: DecayTimer_SetShort / _SetLong)
	.equ CHORD_FLAGS,			0xcede	; chord recognition flags: bit 7 = no chord (Chord_ClearRecognizedChord sets it), bit 1 = on-bass chord, bit 4 = recognize after a delay, bit 6 = recognize at once (Chord_RecognizeNowOrDelay)
	.equ CHORD_TYPE,			0xcedf	; type of the recognized chord (Chord_ApplyCurrentChord)
	.equ CHORD_ROOT,			0xcee0	; root of the recognized chord
	.equ CHORD_BASS_ROOT,			0xcee1	; bass root of an on-bass chord
	.equ CHORD_LAST_TYPE,			0xcee2	; type of the last chord applied; recognition falls back to it when it finds none
	.equ CHORD_LAST_ROOT,			0xcee3	; root of the last chord applied
	.equ CHORD_NOTE_COUNT,			0xcee5	; notes in the chord note list that follows it
	.equ CHORD_NOTES,			0xcee6	; the chord's notes, in list order (CHORD_NOTE_COUNT of them)
	.equ CHORD_HELD_KEY_COUNT,		0xceff	; word: chord keys held
	.equ CHORD_CHANGED,			0xcf01	; word: Chord_ApplyCurrentChord sets the high byte to 0xFF; Voice_UpdatePlayModeState reports and clears it
	.equ CHORD_PREV_KEY_COUNT,		0xcf17	; word: chord keys held before the change being recognized (Chord_RecognizeNowOrDelay)
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
