; ram_variables_by_use.s -- main-CPU RAM variables named from the code that uses them (audit WP17).
; The names and reasons are v10's (v10/maincpu/shared/ram_variables_by_use.s); the values here are
; v7's own, derived by scripts/tools/name_kn5000_ram.py from the same instructions in the same routines
; (a corrected line says so).  Names it could not derive for v7 are left out.
	.equ BOOT_STAGE,			0x0400	; boot progress: Boot_PostSelfTest stores 2 before TaskSched_Init and 3 after it, Boot_DisplayScreen 6 after the first screen group and 0x80 after the last; NMI_ClearGuardAndHalt stores 0.  Only NMI_StorePayloadChecksums reads it: it stores the power-fail checksums only at 0x80 (boot complete, power-fail save armed)
	.equ BOOT_CONFIG_FLAGS,			0x0406	; bit 7 = boot finished normally (Boot_SetConfigFlag7 sets it in Boot_DisplayScreen, Boot_ClearConfigFlag7 clears it at the start of Boot_InitPeripherals)
	.equ ACC_CLOCK,				0x0415	; accompaniment clock within the beat, 0..95 (INTTR4_CheckSeqEnable counts it, ClkTick_Src2FineBeatCheck by 4 per MIDI clock)
	.equ ACC_BEAT,				0x0416	; beat within the measure; INTTR4_SeqAutoStart compares it with ACC_BEATS_PER_BAR - 1, the BeatLed_*Masks show it on the START/STOP BEAT LEDs
	.equ PLAY_CLOCK,			0x0417	; tick within the beat, 0..95, counted by INTTR4_HANDLER while PLAY_TRANSPORT_STATE runs (INTTR4_MetroBeat_Check stops on 0 / 24 / 48 / 72)
	.equ PLAY_BEAT_COUNT,			0x0418	; word: beats counted since the play transport started
	.equ ACC_TRANSPORT_STATE,		0x041e	; transport of the accompaniment clock ACC_CLOCK / ACC_BEAT (bit 2 = running gates them in INTTR4_CheckSeqEnable; AccAutoPlay_* test it), coded like SEQ_TRANSPORT_STATE (1, 6, 8, 12, 16; AccPlayMode_StartAccPlay stores 1); 128 / 134 = waiting for synchro start: INTTR4_SeqAutoStart starts PLAY_TRANSPORT_STATE and SEQ_TRANSPORT_STATE at the end of a bar
	.equ PLAY_TRANSPORT_STATE,		0x0420	; the play transport, coded like SEQ_TRANSPORT_STATE: 1 start pending, 6 running (bit 2 gates PLAY_CLOCK / PLAY_BEAT_COUNT in INTTR4_HANDLER; Audio_WaitForReady and the demo song player wait on it), bit 3 = stop at the next 24-tick boundary (INTTR4_MetroBeat_Check), 16 stopped; AccPlayMode_* start and stop it (ssf-presentation.md calls it the sequencer transport lane)
	.equ ACC_BEATS_PER_BAR,			0x0433	; beats per measure of the style; 3 or 6 select the three-beat LED pattern (BeatLed_ThreeBeatMasks)
	.equ ACC_BAR_COUNT,			0x0434	; bars the accompaniment clock has completed (INTTR4_SeqTick_CheckBeat counts them; synchro start waits for 1)
	.equ ACC_SECTION_BAR,			0x0435	; bar within the style section, back to 0 after STYLE_SECTION_LAST_MEASURE (INTTR4_SeqTick_CheckBeat)
	.equ MIDI_RX_CONTEXT,			0x0438	; [28 bytes] XWA, XBC, XDE, XHL, XIX, XIY, XIZ saved by MIDI_RX_CONTEXT_SAVE and put back by MIDI_RX_CONTEXT_RESTORE
	.equ TASK_CURRENT,			0x0487	; word: the TCB of the running task, 0 while the scheduler runs (TaskSched_FoundReadyTask sets it, TaskSched_Dispatch saves XSP at its +4)
	.equ INTERCPU_XFER_PTR,			0x05da	; the source address of the inter-CPU transfer in progress (InterCPU_Send_WaitAck, E1Bulk_WaitAck; inter-cpu-protocol.md)
	.equ INTERCPU_XFER_COUNT,		0x05de	; word: its byte count
	.equ INTERCPU_XFER_STATE,		0x05e0	; 0 = idle, 1 while a packet or E2 header is sent, 2 for an E1 bulk transfer's first phase (INTTC2_HANDLER clears it)
	.equ INTERCPU_RX_STATE,			0x05e2	; receive state of the inter-CPU link: 0 idle, 1 data command, 2 latch read, 3 E2 command, 4 E1 DMA transfer (INT0_* set it, INTTC0_HANDLER clears it)
	.equ INTERCPU_RX_HEADER,		0x05e4	; the header byte INT0_ReadLatch took from the latch
	.equ SEMENU_PART_MASK,			0x065e	; the sound editor's enabled parts, one bit per part (SeMenu_SetPartEnabled)
	.equ SEMENU_PART_MODE,			0x06ae	; the sound editor's part layout: 1 = 2 parts, else 4 (SeMenu_DrawPartSelector, SeMenu_DrawPartRadioButtons)
	.equ SEMENU_GFX_X,			0x06c6	; word: x origin of the sound editor's graphic (mini keyboard, envelope curve: SeMenu_DrawKeyboardGraphic)
	.equ SEMENU_GFX_Y,			0x06c8	; word: its y origin
	.equ SEGFX_RECORD,			0x06ca	; [10 bytes] the record the sound editor's SeGfx_StaticOpNN_FromBuf drawers read: +2 x1, +4 y1, +6 x2, +8 y2 (SeGfx_DrawLine fills it from its four pushed words; SeMenu_DrawKeyboardGraphic and others likewise)
	.equ FLASH_SLOT_ASSIGN_LIST,		0x07a0	; the slot assignment list Flash_AssignSlotsToBlocks builds: {block, 0x500 | slot} records, bit 7 set for small slots (Flash_CopyBlocksToSlots, Flash_WriteSlotOwnerMap consume it)
	.equ STYLE_WORK_IMAGE_PTR,		0x0c72	; the style work image (0x69800, set by Flash_InitExtMemAddrs); the legacy-image converters build there
	.equ FLASH_SECTOR_IMAGE_PTR,		0x0c96	; RAM image of the custom-data flash's section-7 sector (0x69800, Flash_InitExtMemAddrs); Flash_CopyBlocksToSlots / Flash_WriteBackSlot* build it before the sector is rewritten
	.equ TRACK_ASSIGN_CURSOR,		0x0cdf	; the track (0..15) the TRACK ASSIGN page's cursor is on; 8 = the second page (SqTrAs_Cursor*)
	.equ DEMO_DEBOUNCE,			0x0d33	; debounce counter of the demo selection buttons (Demo_SelectEntry_Debounce)
	.equ PLAYBACK_START_ARMED,		0x0d34	; 1 once the start countdown is armed (PlayMode_ArmStartCountdown), 0 when disarmed
	.equ SQSTEP_CLOCK,			0x0d57	; clock within the beat at the song-data cursor, 0..95 (SqStep_AdvanceClockByStep, SqStep_SeekForwardByDistance store it)
	.equ SQSTEP_WRAP_COUNT,			0x0d58	; word: clock-wrap markers (0x81) passed since the start of the cursor track (SqStep_WriteClockWrapMarker increments it)
	.equ SQSTEP_UNITS,			0x0d5a	; word: whole 96-clock units from the start of the cursor track to the cursor; the seeks count it
	.equ SQSTEP_BEAT,			0x0d5c	; beat within the measure at the cursor, from 0
	.equ SQSTEP_MEASURE_BEATS,		0x0d5d	; beats in the cursor's measure: UIDisp_StepMeasureForward seeks (this) - SQSTEP_BEAT beats to the next measure
	.equ SEQ_SELECTED_TRACK,		0x0d60	; the selected track, 1..16; the status bar redraws when it changes (Display_UpdateRegion0_Check)
	.equ SQSTEP_DISPLAY_MODE,		0x0d65	; display mode of the cursor track, from its TRACK ASSIGN value: 1 = note track, 3 = RHYTHM track; (this) & 3 indexes DisplayMode_Dispatch_Tbl / SoundEvt_ModeDispatch_Tbl
	.equ SQSTEP_SEEK_UNITS,			0x0dcd	; distance in 96-clock units SqStep_SeekForwardByDistance moves the cursor; callers preset it
	.equ SQSTEP_SEEK_CLOCK,			0x0dce	; the clock (0..95) SqStep_SeekForwardByDistance stops on
	.equ SQSTEP_RECORD_LENGTH,		0x0dd2	; length of the event record being step-recorded: 3 modulation, 4 pitch bend or tempo
	.equ SQSTEP_HELD_COUNT,			0x0dd4	; keys held while step-recording, up to 8 (TempoRingBuf_ReadNoteIntoHeldList)
	.equ SQSTEP_COLLECTED_NOTES,		0x0dd5	; notes collected for the chord being step-recorded; TempoRingBuf_OnNoteEvent writes one record per note
	.equ STATUS_POPUP_ID,			0x0def	; the pop-up the status bar's region 0 shows: 1 accompaniment parameter, 2 incoming control line, 4 program change, 10 part parameter, 12 RHYTHM track (ParamPopup_*, Display_ModePopupDispatch, SqStep_SetPopupIdForDisplayMode)
	.equ PERF_STEP_AMOUNT,			0x0df2	; +1 or 0xff (-1): what PerfMode_StepCursorEventByte adds
	.equ PERF_STEP_FIELD,			0x0df3	; which byte of the event at the cursor it steps (2, 3 velocity, 4)
	.equ SQSTEP_ROW1_MEASURE,		0x0e4c	; word: measure number of the step grid's row above the cursor row (SqStep_SetupPrevGridRow; capped at 1000)
	.equ SQSTEP_ROW2_MEASURE,		0x0e4e	; word: measure number of the cursor row
	.equ SQSTEP_ROW3_MEASURE,		0x0e50	; word: measure number of the row below (SqStep_SetupNextGridRow); 0 = no row
	.equ SQSTEP_ROW1_BEATS,			0x0e52	; beats shown in row 1 (its segment count; Scoop_TitleBar_GetPartConfig draws one block per beat)
	.equ SQSTEP_ROW2_BEATS,			0x0e53	; beats shown in row 2
	.equ SQSTEP_ROW3_BEATS,			0x0e54	; beats shown in row 3
	.equ SEQ_CURSOR_TRACK,			0x0eee	; the cursor track, 1..16, of the step-record and scoop screens (SqStep_SetDisplayModeFromTrack copies SEQ_SELECTED_TRACK into it)
	.equ SEQ_EVT_STATUS,			0x0fab	; status byte of the MIDI event the song player is executing (MidiEvent_*, MidiNoteOn_*); only the low nibble, the channel, is used
	.equ SEQ_EVT_DATA1,			0x0fac	; its first data byte (clamped to 0x7f with SEQ_EVT_DATA2 by MidiEvent_ClampVelocityA_High)
	.equ SEQ_EVT_DATA2,			0x0fad	; its second data byte
	.equ SEQ_EVENT_ABORT,			0x10e3	; 0 = carry on; 255 = the block chain ran out (ToneGen_AdvancePosition with no free block) or SeqTrack_ValidateAndAssignVoices found no dispatch slot.  The event handlers skip their register write when it is set and clear it after each event
	.equ POPUP_PART,			0x10f1	; part shown by the parameter pop-up, an index into StringData_PartNames (ParamPopup_Part*)
	.equ POPUP_VALUE,			0x10f3	; value the parameter pop-up shows (decimal, a signed amount or an on/off bit, by pop-up)
	.equ SEQ_BLOCK_PTR,			0x10fd	; the 256-byte block being read or written: SMF_CalcPageAddress and its twins store SEQ_BLOCK_POOL + (n - 1) * 0x100 here; nested walks save and restore it
	.equ GOTO_MEASURE_TARGET,		0x1105	; word: the measure the go-to-measure loop steps SQSTEP_MEASURE towards
	.equ SEQ_BLOCK_POOL_COPY,		0x110a	; a copy of SEQ_BLOCK_POOL (DispatchHandler_* store it through `ld xhl, ...`), the base SeqNode_ResolveSlotPtr and SetWall_ResolveStreamPtr add to
	.equ SMF_FILE_PTR,			0x1118	; the byte pointer into the SMF file data being read or written: FloppyIO_ReadNextByte reads through it, SMF_WriteByte writes through it
	.equ PART_PARAM_SELECT,			0x111c	; the part parameter shown: 0 PAN, 1 KEY SHIFT, 2 TUNING, 3 BEND SENS (PartParam_LoadSelectedValue)
	.equ PART_PARAM_VALUE,			0x111d	; its value, shown under that label by DisplayStr_ShowPartParamLine
	.equ PLAYBACK_COUNTDOWN,		0x1144	; ticks before an armed playback starts: 10 when armed (PlayMode_LoadStartCountdown), CDlikeSwitch_PlaybackTimer counts it down
	.equ SEQ_BLOCK_POOL,			0x1d5a	; base of the sequencer's pool of 256-byte data blocks: SeqInit_SetBaseAddress sets 0xb0000; block n (1-based) is at this + (n - 1) * 0x100
	.equ SEQ_OP_MEASURES,			0x25de	; word: measures the edit operation covers, last - first + 1 (the EXECUTE handlers MainExeCall_OnTitleSq* store it; SeqPart_* and the Seq_Validate* checks read it)
	.equ SEQ_PART_LOOP,			0x25e0	; the part (0..15) the sequencer's per-part loops are on (SeqAcc_ProcessTempo_*, Portamento_Scan*, SeqScan_*)
	.equ SQEDT_TRKCLR_MASK,			0x25e8	; word: TT_SQTRKCLR's track mask; EXECUTE clears every track whose bit is set and zeroes it
	.equ SQEDT_VELOCNG_LAST,		0x25fa	; TT_SQVELOCNG: last measure (word)
	.equ SQEDT_QTZ_LAST,			0x25fc	; TT_SQQTZ: last measure (word)
	.equ SEQ_OP_QUANTIZE,			0x25fe	; the quantize value, SQEDT_QTZ_VALUE doubled (SeqPart_VelocityCurveCalc reads it)
	.equ SQEDT_QTZ_STRENGTH,		0x2600	; TT_SQQTZ: quantize strength, 0..100 (SeqParams_InitDefaults stores 100; AppEvent_ChainDispatch1_IncQtzStrength / AppEvent_InlineHandler_DecQtzStrength step it within 0..100 and redraw item 8; SeqPart_VelocityCurveCalc's caller returns early at 100)
	.equ SQEDT_QTZ_WINDOW,			0x2602	; TT_SQQTZ: quantize window, signed -100..+100 (SeqParams_InitDefaults stores 100; AppEvent_ChainDispatch1_IncQtzWindow / AppEvent_InlineHandler_DecQtzWindow step it between 0x9c = -100 and 100 and redraw item 9)
	.equ SQEDT_ADVDLY_TRACK,		0x2604	; TT_SQADVDLY: track
	.equ SQEDT_ADVDLY_FROM,			0x2606	; TT_SQADVDLY: first measure (word; also the default the FM string shows)
	.equ SQEDT_ADVDLY_LAST,			0x2608	; TT_SQADVDLY: last measure (word)
	.equ SQEDT_NOTECNG_TRACK,		0x260e	; TT_SQNOTECNG (note change): track
	.equ SQEDT_NOTECNG_FROM,		0x2610	; TT_SQNOTECNG: first measure (word)
	.equ SQEDT_NOTECNG_LAST,		0x2612	; TT_SQNOTECNG: last measure (word)
	.equ SQEDT_TRNS_TRACK,			0x261c	; TT_SQTRNS (transpose): track
	.equ SQEDT_TRNS_FROM,			0x261e	; TT_SQTRNS: first measure (word)
	.equ SQEDT_TRNS_LAST,			0x2620	; TT_SQTRNS: last measure (word)
	.equ SQEDT_MERS_LAST,			0x2626	; TT_SQMERS: last measure (word)
	.equ SQEDT_MCP_LAST,			0x2628	; TT_SQMCP: last source measure (word)
	.equ SQEDT_MCP_REPEAT,			0x262a	; TT_SQMCP: repeat count
	.equ SQEDT_MDEL_LAST,			0x262c	; TT_SQMDEL: last measure (word)
	.equ SQEDT_MINS_LAST,			0x262e	; TT_SQMINS: last measure of A (word)
	.equ SQEDT_MINS_REPEAT,			0x2630	; TT_SQMINS: repeat count
	.equ SEQ_OP_FROM,			0x2632	; word: first measure of the edit operation (MainExeCall_OnTitleSq*)
	.equ SEQ_QTZ_TICK,			0x2638	; the tick within the beat of the event being quantized: the byte SeqData_ReadNextByte returns (SeqPart_VelExprClamp), which SeqPart_VelocityCurveCalc splits into grid zones (QtzGrid48: at 24 / 72)
	.equ SEQ_QTZ_ZONE_EDGE_A,		0x2640	; first of the edge pair of the grid zone SEQ_QTZ_TICK falls in (SeqPart_VelocityCurveCalc: 48 for quantize value 0, else from SeqPart_VelCurveData_Table / SeqPart_VelZoneLookup_Table by zone)
	.equ SEQ_QTZ_ZONE_EDGE_B,		0x2642	; second of that edge pair (SeqPart_VelZoneLookup_Table_2 by zone; 48 for quantize value 0)
	.equ SEQ_OP_ERASE_CHOICE,		0x2650	; what a measure erase removes (SQEDT_MERS_CHOICE; SeqPart_FullLoad picks its mode by it)
	.equ SEQ_OP_VELOCITY,			0x2654	; the velocity amount of a velocity change (SQEDT_VELOCNG_AMOUNT)
	.equ SEQ_DATA_OFFSET,			0x2666	; word: byte offset of the song-data cursor in SEQ_DATA_BLOCK, 5..255 (5 = first byte after the block header); at 255 ToneGen_AdvancePosition moves on to a new linked block
	.equ SEQ_START_MEASURE,			0x2668	; word: the measure playback starts from, sign-magnitude (0x8002 = 2 measures before measure 1): punch-in minus SEQ_COUNT_IN (SeqPlay_UpdateStartFromPunchIn)
	.equ SCOOP_DST_BLOCK_PTR,		0x267a	; address of the destination block of the scoop display's chained copy (SeqData_ChainNextDstBlock follows the +3 link and stores the next block here)
	.equ SCOOP_SRC_BLOCK_PTR,		0x267e	; address of its source block (SeqData_ChainPrevSrcBlock follows the +1 link)
	.equ SEQ_OP_DEST_TRACK,			0x2682	; destination track of a copy / insert operation (SQEDT_MCP_TRACK_B, SQEDT_MINS_TRACK_B)
	.equ SEQ_OP_DEST_MEASURE,		0x2686	; word: destination measure of a copy / insert operation (SQEDT_MCP_AT, SQEDT_MINS_AT)
	.equ NOTEEDIT_BASE_KEY,			0x2798	; the lowest key the note-edit display shows; MT_GetKb1Str / MT_GetKb2Str name it and the next (BmDrEdit_ChordScroll* step it)
	.equ SEQ_BLOCK_TOTAL,			0x286d	; word: blocks in the pool, 1240 (SeqInit_SetBaseAddress); DispatchHandler_InitAllSlots starts SEQ_FREE_BLOCKS from it, the song-usage percentages divide by it
	.equ TRACK_ASSIGN_EDIT_VALUE,		0x2873	; the TRACK ASSIGN value being edited, reloaded from SEQ_TRACK_ASSIGN when the cursor moves (SetWall_UpdateSlotIndex)
	.equ SEQ_TRACK,				0x2877	; the track (1..16) a sequencer operation or loop works on; 127 = all tracks (the edit titles' track 0x11, MainExeCall_OnTitleSq*); MainExe_SongMem* and SeqStep_MultiTrackProcess loop it over 1..16
	.equ SEQ_SONG,				0x2878	; the song (0..9) the song-memory routines (SeqVoice_InitEntry ...) address; SeqVoice_InitEntryForCurrentBank and SeqStep_TrackChange set it to SEQ_CURRENT_SONG or another song for one call and restore it
	.equ SEQ_EDIT_FLAGS,			0x287b	; flags of the song-data edit and scan routines: bit 2 = take the measure lengths from the RHYTHM track (Seq_FindRhythmTrack sets it), bit 5 = a scan met the end marker (SeqTrack_ScanSetEndFlag, SetWall_ForwardSkip); bits 0, 3, 4, 6 and 7 are working flags of the SeqPart_* copy / exchange / load operations
	.equ SEQ_WRITE_BLOCK_PTR,		0x2881	; the block SMF_Config* write output bytes into, at (this + IY); set from SEQ_BLOCK_PTR when a new block is started (IY = 5, past the block header)
	.equ SEQOP_PRIMARY_OFFSET,		0x2885	; word: offset of the primary song-data cursor of the SeqPart_* / SMF_Config* walks (SeqPart_ReadByte_Primary, SeqPart_WriteByte_Primary); 5 = first byte of a block, 255 = its last
	.equ SEQOP_PRIMARY_BLOCK,		0x2887	; word: block of the primary cursor (SMF_AdvanceInPageChain follows the +3 link when the offset passes 255)
	.equ SEQOP_SECONDARY_OFFSET,		0x2889	; word: offset of the secondary song-data cursor (SeqPart_WriteByte_Secondary, PartCtrl_AdvanceReadPos)
	.equ SEQOP_SECONDARY_BLOCK,		0x288b	; word: block of the secondary cursor (SMF_AdvanceReadPtr, SeqCopy_ComparePositionLoop)
	.equ SEQ_RTMCFG,			0x28a7	; rtmcfg, the firmware's own name (GetAdr_rtmcfg returns its address): sequencer / accompaniment playback flags; bit 2 = ignore incoming MIDI Start / Continue (Transport_EnableMidiStartContinue clears it)
	.equ SEQ_REC_TRACKS,			0x28a8	; word: one bit per track armed for recording (SqRealRecTitleFunc sets them through SeqVoice_SetOrClearBitMask); Audio_CheckInitStatus reports them as audio group B
	.equ SEQ_RECORDING_TRACKS,		0x28aa	; word: the tracks being recorded now: SEQ_REC_TRACKS & SEQ_ACTIVE_PARTS when recording starts (SeqPlay_ActivatePartsAndSendOff), 0 when it stops; while it is non-zero INTTR4 writes a beat marker into TempoRingBuf every beat
	.equ SEQ_DATA_BLOCK,			0x28af	; word: block number of the song-data cursor the sequencer reads and writes through (with SEQ_DATA_OFFSET; SeqNode_ResolveSlotPtr turns it into SEQ_BLOCK_PTR)
	.equ SEQ_CYCLE_FLAGS,			0x28b1	; bit 0 = cycle play on (TT_SQCYCPLY), bit 1 = cycle recording on (TT_SQCYCREC; the record paths SeqMIDI_* test it) -- SeqAccomp_ParamDelivery_IncCycleEnable / SeqAccomp_SubChain_DecCycleEnable
	.equ SQSTEP_SCAN_BLOCK,			0x28bf	; word: block of the song-data scan position (SeqStep_Walk*, SqStep_UpdateMsaStateFromEvent)
	.equ SQSTEP_SCAN_OFFSET,		0x28c1	; word: offset in that block
	.equ SEQ_PLAY_FLAGS,			0x28c5	; bit 0 = playback started (SeqPlay_InitTempoAndActivateParts; the start, stop and repeat paths test it), bit 6 = the recorded tracks are active (SeqPlay_ActivatePartsAndSendOff / _ReactivatePartsAndResume set it, SeqPlay_DeactivateAndSendOff clears it and sets bit 5)
	.equ SEQ_RECORDED_TRACKS,		0x28c6	; word: the tracks recording took out of SEQ_TRACK_MASK; SeqPlay_DeactivateParts_LoopNext and SeqPlay_SyncPosition_StopAndReset put them back
	.equ BMDREDIT_CHANNEL,			0x2965	; the MIDI channel (track) the beat / drum editor works on; SEQ_TRACK_ASSIGN[this] picks its part type (BmDrEdit_TestPartTableEntry)
	.equ SEQ_SCREEN_OBJECT,			0x2972	; the object EVT_PAINT gave the sequencer screen handlers (ApEditSyori, NoteEditSyori, ApPlaySyori, EffEditMain store its parameter); EVT_PARA_DRAW redraw requests are sent to it
	.equ DSP_EFFECT_NUMBER,			0x2976	; word: the DSP effect being edited (DspItem0_DisplayEffectName indexes DspEffectName_PtrTable by it)
	.equ ACC_STYLE_BANK,			0x31e9	; the style's 64 KB rhythm-ROM bank, its record's byte +0x3d1 (AccStyle_SetupPartAddresses); pattern reads are 0x400000 + bank * 0x10000 + offset	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3285
	.equ ACC_LANE_READ_POS,			0x31eb	; [12 bytes] per-lane read position, a word per lane (lanes in ACC_PART_BIT order): the signed 16-bit offset into the style's bank, starting at the lane pointer - 0x8000 + 6 (AccStyle_SetupPartAddresses); AccBuf_Advance steps it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3287
	.equ ACC_LANE_BLOCK,			0x31fb	; [12 bytes] per-lane current pattern block (patch entry, 256-byte block) number, a word per lane; AccBuf_Advance replaces it with the block's link word at a 0x87 cell link (AccPatch_LoadTablePointers returns these words)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3297
	.equ ACC_LANE_SECTION,			0x3207	; [6 bytes] per-lane section byte (sections are 5 apart; AccStyle_SelectSection writes all six)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32a3
	.equ ACC_LANE_BEAT_POS,			0x320f	; [6 bytes] per-lane position: low nibble = beat in the measure, high nibble = measure (AccVoice_BarEnd_* step it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32ab
	.equ ACC_LANE_BAR,			0x3219	; [6 bytes] per part (bit 1..32): its bar counter; AccVoice_SavePartStateN copies it to ACC_CUR_BAR and back, AccVoice_HandleBarEndEvent increments the working copy when the beat position wraps	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32b5
	.equ ACC_CH_TURNOVER,			0x3227	; [4 bytes] per rhythm channel D7 / D4 / D5 / D6: the part sound's turnover byte (IC14 part_sound +5), RhythmPartN_LoadAndStore; Rhythm_SetupChannel_Dn copies it to ACC_CUR_TURNOVER	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32c3
	.equ ACC_CH_CEILING,			0x322b	; [4 bytes] per rhythm channel D7 / D4 / D5 / D6: the part sound's note ceiling (IC14 part_sound +6); Rhythm_SetupChannel_Dn copies it to ACC_CUR_CEILING	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32c7
	.equ ACC_CUR_TURNOVER,			0x322f	; the working channel's turnover: Rhythm_TransposeNote moves a transposition above it an octave down; Rhythm_CrossVoiceCorrect bases 0x332e on it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32cb
	.equ ACC_CUR_CEILING,			0x3230	; the working channel's note ceiling: Rhythm_TransposeNote folds notes at or above it down by octaves (when it is 12 or more)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32cc
	.equ ACC_STYLE_RECORD,			0x3232	; the current style record in the rhythm ROM (AccStyle_ApplyExtendedStyle stores it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32ce
	.equ ACC_STYLE_NUMBER,			0x3249	; the style playing, 0..127 within ACC_STYLE_GROUP (below 0x80 a rhythm-ROM style; committed from ACC_PENDING_STYLE by AccStyle_ApplyChanges)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32e5
	.equ ACC_STYLE_GROUP,			0x324a	; its group, 0..6 (the directory has 8 groups x 128 styles)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32e6
	.equ ACC_BAD_EVENT_COUNT,		0x3251	; unknown pattern bytes the lane reader skipped; at 32 AccVoice_AdvanceAndCheckEnd stops the accompaniment	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32ed
	.equ ACC_SCAN_BAD_EVENT_COUNT,		0x3252	; the same count for AccSeq_FourChannelScan's pattern scanner (AccSeq_Scanner_Unknown)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32ee
	.equ ACC_PENDING_STYLE,			0x3259	; style number sampled from PANEL_STYLE, applied by AccStyle_ApplyChanges; 0xff forces a reload (the bad-event watchdogs store it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32f5
	.equ ACC_PENDING_GROUP,			0x325b	; group sampled from PANEL_STYLE+1 (low 3 bits used)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32f7
	.equ ACC_REQ_FILLIN,			0x325f	; FILL IN requests, bit 0 = FILL IN 1, bit 1 = FILL IN 2: PANEL_STYLE+5 bits 6 / 7, copied every tick (SeqTick_ReadControlState); AccSection_LatchFillInRequests latches a newly set bit	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32fb
	.equ ACC_REQ_FILLIN_PREV,		0x3260	; ACC_REQ_FILLIN of the previous tick (Rhythm_SaveState); Rhythm_SaveState also moves bit 0 / 1 when one fill hands over to the other	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32fc
	.equ ACC_REQ_ENDING,			0x3261	; ENDING requests, bit 0 = ENDING 1, bit 1 = ENDING 2: PANEL_STYLE+5 bits 4 / 5 (SeqTick_ReadControlState); AccSection_LatchEndingRequests latches a newly set bit	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32fd
	.equ ACC_REQ_ENDING_PREV,		0x3262	; ACC_REQ_ENDING of the previous tick (Rhythm_SaveState)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32fe
	.equ ACC_REQ_INTRO,			0x3263	; intro requests, bit 0 = INTRO 1, bit 1 = COUNT IN, bit 2 = INTRO 2: PANEL_STYLE+5 bits 2 / 3 and PANEL_STYLE+6 bit 2 (SeqTick_ReadControlState); AccSection_LatchIntroRequests latches a newly set bit	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x32ff
	.equ ACC_REQ_INTRO_PREV,		0x3264	; ACC_REQ_INTRO of the previous tick (Rhythm_SaveState)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3300
	.equ ACC_STYLE_ARRANGER_ON,		0x3265	; bit 0 = MUSIC STYLE ARRANGER on (PANEL_PMEM_SETTINGS+3 bit 0, SeqTick_ReadControlState): then FILL IN 1 / 2 step the variation down / up (AccSection_SwitchNow, AccVoice_SetChordChangeFlags)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3301
	.equ ACC_VARIATION_REQUEST,		0x3269	; the VARIATION 1-4 request, 0..3 = (PANEL_STYLE+7 & 0x30) >> 4, copied every tick (SeqTick_ReadControlState); AccentVoice_DetectAndMarkChange flags a change for the bar line	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3305
	.equ ACC_PENDING_FILLIN,		0x326d	; latched fill-in waiting to start, bit 0 = FILL IN 1, bit 1 = FILL IN 2 (AccSection_LatchFillInRequests sets it, AccSection_StartFillIn clears it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3309
	.equ ACC_PENDING_INTRO,			0x326e	; latched intro waiting to start, bit 0 = INTRO 1, bit 2 = COUNT IN, bit 3 = INTRO 2 (AccSection_LatchIntroRequests sets it, AccSection_StartIntro clears it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x330a
	.equ ACC_PENDING_ENDING,		0x326f	; latched ending waiting to start, bit 0 = ENDING 1, bit 1 = ENDING 2 (AccSection_LatchEndingRequests sets it, AccSection_StartEnding clears it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x330b
	.equ ACC_VARIATION_CHANGE_PENDING,	0x3271	; bit 0: ACC_VARIATION_REQUEST moved to a variation not playing (AccentVoice_DetectAndMarkChange); the lanes raise the switch at their bar end and AccSection_SwitchAtBarLine loads it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x330d
	.equ ACC_LANES_FILLIN1,			0x3276	; the lanes (bits 0-5) still playing FILL IN 1: AccSection_StartFillIn sets 0x3f, a lane clears its bit at the section's end marker, Rhythm_SaveState retires the section when the byte reaches 0	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3312
	.equ ACC_LANES_FILLIN2,			0x3277	; the lanes still playing FILL IN 2 (as ACC_LANES_FILLIN1)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3313
	.equ ACC_LANES_ENDING1,			0x3278	; the lanes still playing ENDING 1 (AccSection_StartEnding sets 0x3f)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3314
	.equ ACC_LANES_ENDING2,			0x3279	; the lanes still playing ENDING 2	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3315
	.equ ACC_LANES_INTRO1,			0x327a	; the lanes still playing INTRO 1 (AccSection_StartIntro sets 0x3f)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3316
	.equ ACC_LANES_COUNTIN,			0x327b	; the lanes still playing the COUNT IN	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3317
	.equ ACC_LANES_INTRO2,			0x327c	; the lanes still playing INTRO 2	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3318
	.equ ACC_DEFER_ENDING_LANES,		0x328a	; lanes whose pending ending (or style change) waits for their bar line: AccSection_DeferToBarUnlessFirstBeat sets bits 0-5 unless the engine beat is 0; AccSection_SwitchAtBarLine clears it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3326
	.equ ACC_DEFER_SECTION_LANES,		0x328b	; lanes whose pending intro / fill-in waits for their bar line: AccSection_DeferToBarIfLastBeat sets bits 0-5 when the press comes on the last beat; AccSection_SwitchAtBarLine clears it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3327
	.equ ACC_CH_CC3,			0x3293	; [4 bytes] per rhythm channel D7 / D4 / D5 / D6: the last controller-3 value sent (0xdn 0x03 v, AccVoice_SendProgChange from ACC_CUR_CC3); Rhythm_SendVolume_Dn re-sends it, Rhythm_AllNotesOff_Dn sends 0 when it is set
	.equ ACC_CUR_CC3,			0x3297	; the last 0xd3 (controller selector 3) value AccVoice_ScanInstruments / AccSeq_Scanner_D3Voice found in the working part's pattern, 0 when none
	.equ ACC_VARIATION_NEXT,		0x329e	; the variation index 0..3 to load: ACC_VARIATION_REQUEST & 3 (AccentVoice_DetectAndMarkChange), stepped -1 / +1 (clamped) by FILL IN 1 / 2 under the arranger (AccSection_SwitchNow)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x333a
	.equ SNDARG_PART_SELECT,		0x32f2	; the Sound Arranger part being edited, one-hot: 1 DRUM, 2 BASS, 4 / 8 / 16 ACCOMP1-3 (AcSndArgGridBoxProc sets it; cleared entering and leaving MD_SND_ARG); AccStyle_Process copies changed sounds while it is set	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x338e
	.equ SNDARG_LAST_SOUNDS,		0x32f9	; [10 bytes] the sound (part record bytes +0, +1 & 0x7f) of DRUM, BASS, ACCOMP1-3 the Sound Arranger last saw (AccVoiceState_Snapshot); SndArg_Store*Sound compare with it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3395
	.equ ACC_PART_BIT,			0x3338	; the accompaniment part being set up or played, one-hot: 1, 2, 4, 8, 16, 32 (AccVoice_SetupKbd1, _SetupKbd2, _SetupAcc1 .. _SetupAcc4); AccStyle_ReadParamOffset picks that part's field of a style record by it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x33d4
	.equ ACC_CUR_SECTION,			0x3339	; the lane being processed: its ACC_LANE_SECTION (AccVoice_SavePartState1 and its twins copy the lane in, *_RestoreState back)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x33d5
	.equ ACC_CUR_BLOCK,			0x333a	; word: the lane being processed: its ACC_LANE_BLOCK	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x33d6
	.equ ACC_CUR_READ_POS,			0x333c	; word: the lane being processed: its ACC_LANE_READ_POS	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x33d8
	.equ ACC_CUR_BAR,			0x333e	; the working part's bar counter (copy of ACC_LANE_BAR[part]); AccTempo_PositionCompare's bar	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x33da
	.equ ACC_CUR_BEAT_POS,			0x333f	; the lane being processed: its ACC_LANE_BEAT_POS	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x33db
	.equ ACC_CUR_MEASURE,			0x334e	; the working part's measure counter (copy of ACC_LANE_MEASURE[part]); AccVoice_IncrementBarCounter wraps it past byte +13 of the record at (0x3426)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x33ea
	.equ ACC_LANE_MEASURE,			0x334f	; [6 bytes] per part: its measure counter; AccVoice_ClearChannelStates clears all six	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x33eb
	.equ ACC_EVENT,				0x3391	; [6 bytes] the pattern event being decoded or built (docs/accompaniment-style-reader.md): +0 status, +1 position in the beat, +2 note, +3 velocity, +4/+5 duration; AccBuf_WriteNoteEvent copies all but +1 into a ring buffer, a zero duration as 1.  SqStep_ComputeStepAndGateTime keeps the step and gate lengths in +0..+3	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x342d
	.equ ACC_READ_OFFSET,			0x33ad	; word: offset in ACC_READ_BLOCK	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3449
	.equ ACC_READ_BLOCK,			0x33cf	; word: block of the pattern read position (AccPlayback_SaveReadPosition saves it with ACC_READ_OFFSET)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x346b
	.equ ACC_SECTION_BUTTONS_HELD,		0x33d4	; section buttons held: bit 0 INTRO 2, 2 INTRO 1, 3 COUNT IN, 4 ENDING 1, 5 ENDING 2, 6 FILL IN 1, 7 FILL IN 2 (AccSection_Request* set them, AccSection_Release* clear them); a held FILL IN restarts the fill at an arranger step	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3470
	.equ ACC_CTL_EVENT_VALUE,		0x33e2	; new value of the style-record (0x48) field-5 / 6 switch event being handled (AccStyleCtl_OnSwitchEvent)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x347e
	.equ ACC_CTL_EVENT_MASK,		0x33e3	; its mask of changed bits (0xff read as 0); a button is pressed when its bit is set in both, released when set only here	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x347f
	.equ ACC_CTL_EVENT_FIELD,		0x33ee	; its field of record 0x48: 5 or 6 (AccStyleCtl_OnSwitchEvent; AccPedal_RawHandler stores 3)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x348a
	.equ STYLE_FREE_BLOCKS,			0x3438	; word: free pattern blocks of the style image (190 when AccDemo_Init starts it; AccPatch_LinkNewPatternBlock takes one)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d4
	.equ STYLE_SECTION,			0x343a	; the style section being played or edited, 0..29 (variations 0-11, intros / fill-ins / endings 12-29); its 0x60-byte record is RHYTHM_PATTERN_BUF_A + 0x60 + 0x60 * n (AccPatch_GetCurrentSlotAddr)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d6
	.equ STYLE_SECTION_LAST_MEASURE,	0x343b	; last measure index of STYLE_SECTION (its record's +13, RhythmPatInit_LoadParams)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d7
	.equ STYLE_SECTION_TIME_SIG,		0x343c	; time-signature code of STYLE_SECTION (its record's +12)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d8
	.equ STYLE_SECTION_BEATS,		0x343d	; beats per measure of STYLE_SECTION: RhythmPatInit_KitIndexTable[time-signature code] (2/4/6/8 for x/2, 1..8 for x/4 and x/8)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34d9
	.equ CMP_QUANTIZE,			0x343f	; the Composer's QUANTIZE setting: 0 off, 1..7 = 8, 12, 16, 24, 32, 48, 96-tick grids (PsCmpQtzBoxProc prints it, AccPatch_LookupStepByDrumParam uses it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34db
	.equ RHYTHM_LOAD_PROGRAM,		0x3451	; the rhythm RhythmROM_PatternDispatcher loads: below 0x80 a preset of RHYTHM_LOAD_BANK, 0x80 + n composer memory n	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34ed
	.equ RHYTHM_LOAD_BANK,			0x3452	; bank of RHYTHM_LOAD_PROGRAM	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34ee
	.equ RHYTHM_LOAD_PART,			0x3453	; part of that rhythm to load (4/5 intro, 10/11 fill-in, 6/7 ending; (this) & 15 indexes RhythmROM_LoadPattern_Data)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34ef
	.equ CMP_SOLO,				0x3455	; 0x80 = the Composer's SOLO is on (RhythmSolo_Toggle), 0 = off; AcCmpRecBoxProc prints MUTE in a part box by it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x34f1
	.equ PATTERN_CURSOR_OFFSET,		0x3476	; word: offset of the pattern-edit cursor in its block (ToneGen_SaveCursorEventBytes, ToneGen_DeleteEventAtCursor)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3512
	.equ PATTERN_CURSOR_BLOCK,		0x3478	; word: block of the pattern-edit cursor	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3514
	.equ RHYTHM_SECTION_PTR,		0x34c4	; pointer into RHYTHM_PATTERN_BUF_A for STYLE_SECTION, through RhythmTiming_OffsetTable (sequencer.md)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3560
	.equ RHYTHM_PATTERN_ALLOC,		0x34c8	; the 2 KB buffer AccPat_Dispatch_AllocAndProcess allocates (Malloc(0x800)) for a rhythm-ROM pattern; RhythmROM_LoadPattern copies into it, RhythmROM_PatternDisp_* read it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3564
	.equ ACC_PATCH_CURSOR_BLOCK,		0x3576	; word: block of the pattern-data write cursor (AccPatch_CopyEventToCursor, AccPatch_StoreMeasureCursor)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3612
	.equ ACC_PATCH_CURSOR_OFFSET,		0x3578	; word: byte offset in that block; 6 is the first data byte after the block header	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3614
	.equ SQSTEP_CURSOR_STEP,		0x3673	; the step cursor's position in the grid, 1..32, 0 = off (SqStep_RestoreOnLeave clears it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x370f
	.equ CMP_STEP_MODE,			0x3676	; Composer step mode: 4 = step entry (CmpStep_SetStepModeAndBlockSustain); AccDraw_StepNoteValue and its twins act only then	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3712
	.equ STEP_NOTE_VALUE,			0x3678	; step-record note value, 1..13 (AccDraw_StepNoteValue; SqStep_ComputeStepAndGateTime reads ScoopParam_ValueTable by it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3714
	.equ STEP_PLUS_NOTE_VALUE,		0x3679	; the "+" note value added to it, 0..13	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3715
	.equ STEP_ARTICULATION,			0x367a	; 0 TENU, 1 NORM, 2 STAC, 3 CUTT: the gate as 19/20, 4/5, 1/2 or 1/4 of the step	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3716
	.equ STEP_VELOCITY,			0x367b	; the velocity Disp_ShowNoteNameAndVelocity prints after 'V' (255 = none)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3717
	.equ STEP_NOTE,				0x367c	; the note number Disp_ShowNoteNameAndVelocity prints (PerfMode_StepNoteNumber steps it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3718
	.equ SQSTEP_MEASURE,			0x367e	; word: measure number at the cursor (DisplayStr_ShowMeasureNumber shows it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x371a
	.equ CONTROL_LINE_KIND,			0x3684	; what the status bar's CONTROL line shows: 1 P.BEND, 2 MOD., 3 EXP., 4 P.MEM, 5 AFT. (Str_PBendModExpEq cell)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3720
	.equ CONTROL_LINE_VALUE,		0x3685	; the value it shows	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3721
	.equ SQSTEP_STYLE_SECTION,		0x368c	; style-section index the step-record display shows: 1 START, 2 STOP, ... (DisplayStr_StyleSectionNames)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3728
	.equ ACC_VIEW_FIRST_MEASURE,		0x36aa	; first measure of the composer's pattern view: x = (measure - this) * width (AccTiming_ComputeOffset)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3746
	.equ CMP_RECORD_PART,			0x36ff	; the Composer's record part, one-hot: 1, 2, 4 = ACP1-3, 8 = BASS, 16 = DRUM (MidiStream_PartEventMapTable, AccPatch_ChannelBitToIndex index by it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x379b
	.equ CMPNCP_FROM_ITEM,			0x390b	; the Composer copy page's FROM item selector, 0..2 (CmpNcp_StepItemA; CmpNcp_ItemA_HandlerIndex maps it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39a7
	.equ CMPNCP_TO_ITEM,			0x390c	; the TO item selector, 0..1 (CmpNcp_StepItemB)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39a8
	.equ STYLE_COPY_SRC_SECTION,		0x3910	; AccPatch_CopySection copies this section of STYLE_SRC_IMAGE_PTR ...	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39ac
	.equ STYLE_COPY_DST_SECTION,		0x3911	; ... into this section of STYLE_DST_IMAGE_PTR	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39ad
	.equ STYLE_SRC_IMAGE_PTR,		0x3912	; the style image read from (usually RHYTHM_PATTERN_BUF_A; AccPatch_CountAvailableSlotsInAltImage points it at 0x69800 for a while)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39ae
	.equ STYLE_DST_IMAGE_PTR,		0x3916	; the style image AccPatch_CopySection writes to	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39b2
	.equ CSTMCP_FROM_SLOT,			0x391a	; custom-style copy: the FROM rhythm slot (MEMORY 0..2, CUSTOM 10..29; CstmCpTtl_RecMode2_On*)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39b6
	.equ CSTMCP_TO_SLOT,			0x391b	; custom-style copy: the TO rhythm slot	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x39b7
	.equ CSTMCP_WINDOW,			0x39e2	; the custom-style copy title's open window: 0 none, 1 memory full, 2 function select	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3a7e
	.equ STYLCNV_LIST_POS,			0x3c68	; word: scroll position (first line shown) of the style-convert title lists (StylCnvSel / StylCnvModl / StylCnvCnvt *_OK_Scroll*)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x3d04
	.equ ACCSEQ_BLOCK,			0x7da6	; word: the accompaniment sequencer's current data block; its 256 bytes are at 0x1e8b00 + 256 * (this & 0xfff) (AccompSeq_GetBlockBase)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x7e42
	.equ ACCSEQ_BEAT_COUNTER,		0x7daa	; word: beats the accompaniment sequencer has read (each 0x81 marker counts one)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x7e46
	.equ DISK_MEDIA_TYPE,			0x8464	; word: disk type code from GetDiskSizeInfo: 2 / 4 2DD, 3 2HD, 5 PD, 6-7 DOC, 0xffff none (DiskInfo_MediaTypeNames)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8500
	.equ SINGLE_LOAD_SRC_ROWS,		0x88b2	; [84 bytes] the four 21-byte text rows of the single-load source list (cells 0..3)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x894e
	.equ SINGLE_LOAD_DST_ROWS,		0x8906	; [84 bytes] the four 21-byte text rows of the destination list	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x89a2
	.equ SINGLE_LOAD_AREA,			0x895c	; the memory area of the single-load screens: 0 PANEL MEMORY, 1 SEQUENCER, 2 COMPOSER, 3 SOUND MEMORY, 4 none (SingleLoadSrc_ListProcByMode is indexed by it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x89f8
	.equ SINGLE_LOAD_ALL,			0x895e	; ALL mode of the single-load list: cell 3 shows "ALL" and the item number is left out	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x89fa
	.equ SLOAD_SRC_PMEM_POS,		0x8960	; single-load source cursor in PANEL MEMORY, 0..79 (8 per bank)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x89fc
	.equ SLOAD_SRC_CMP_POS,			0x8962	; single-load source cursor in COMPOSER (10 per bank)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x89fe
	.equ SLOAD_SRC_SOUND_POS,		0x8964	; single-load source cursor in SOUND MEMORY (20 per bank, USER KITs from 40)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a00
	.equ SLOAD_DST_PMEM_POS,		0x8966	; single-load destination cursor in PANEL MEMORY	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a02
	.equ SLOAD_DST_SONG,			0x8968	; single-load destination song (SEQUENCER)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a04
	.equ SLOAD_DST_CMP_POS,			0x896a	; single-load destination cursor in COMPOSER	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a06
	.equ SLOAD_DST_SOUND_POS,		0x896c	; single-load destination cursor in SOUND MEMORY	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a08
	.equ PASSWORD_STATE,			0x8970	; [2 bytes] the password check: +0 protected-operation mode 0-3 (SelectMode_*), +1 flags (FmmPassword_StateInit's initial {0, 0})	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a0c
	.equ FDC_PROBE_FLAG,			0x8974	; word: 0xffff while a caller probes the disk format (a one-sector read of track 0, head 0 gets a single try: FDC_DETECT_CHECK, FDC_DRIVE_DETECT)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a10
	.equ FDC_BUSY_LATCH,			0x897a	; 0xa5 while a request runs, 0x5a when it ends; a request that finds 0xa5 fails with 0xfb (FDC_CommandEntry)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a16
	.equ FDC_SECTOR_SIZE,			0x8982	; word: sector size, 0x200 or 0x400	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a1e
	.equ FDC_INIT_FLAG,			0x8984	; 0xff once the controller is initialised (FDC_CONFIG_VERIFY)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a20
	.equ FDC_CMD_OPCODE,			0x898c	; the uPD765 command byte being issued (0xd1 / 0xd9 / 0xdd are the scan commands FDC_SendParams_ReadWrite sends STP for)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a28
	.equ FDC_HEAD,				0x898d	; head 0 or 1 for the command's unit/head byte (FDC_CheckHead copies the request's head; other values fail with 0xfe)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a29
	.equ FDC_DRIVE,				0x898e	; drive 0 or 1 for the command's unit/head byte (FDC_CheckDriveCount copies the request's drive)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a2a
	.equ FDC_PARAM_C,			0x898f	; uPD765 parameter C, the cylinder (FDC_SendParams_ReadWrite)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a2b
	.equ FDC_PARAM_H,			0x8990	; parameter H, the head (bit 0 sent)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a2c
	.equ FDC_PARAM_R,			0x8991	; parameter R, the sector number	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a2d
	.equ FDC_PARAM_N,			0x8992	; parameter N, the sector size code (bits 0-2 sent; also FORMAT TRACK's N)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a2e
	.equ FDC_PARAM_EOT,			0x8993	; parameter EOT, the last sector of the track	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a2f
	.equ FDC_PARAM_GPL,			0x8994	; parameter GPL, the gap length	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a30
	.equ FDC_PARAM_DTL,			0x8995	; parameter DTL, the data length (0xff from FDC_InitStateVars)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a31
	.equ FDC_FORMAT_SC,			0x8996	; FORMAT TRACK's SC, sectors per track (FDC_SendParams_Format)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a32
	.equ FDC_FORMAT_GPL,			0x8997	; FORMAT TRACK's gap length (80 / 108 / 116, FDC_MODE_CONFIG)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a33
	.equ FDC_FORMAT_FILL,			0x8998	; FORMAT TRACK's filler byte (0xe5)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a34
	.equ FDC_PARAM_STP,			0x8999	; the scan commands' STP (bits 0-1 sent instead of DTL)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a35
	.equ FDC_SPECIFY_SRT,			0x899b	; SPECIFY's step rate time (the high nibble of its first byte)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a37
	.equ FDC_SPECIFY_HUT,			0x899c	; SPECIFY's head unload time (the low nibble, 15 from FDC_InitStateVars)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a38
	.equ FDC_SPECIFY_HLT,			0x899d	; SPECIFY's head load time (bits 1-7 of its second byte, 1 from FDC_InitStateVars)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a39
	.equ FDC_SPECIFY_ND,			0x899e	; SPECIFY's non-DMA bit (bit 0 of its second byte, 0 = DMA)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a3a
	.equ FDC_REQ_DRIVE,			0x89a6	; word: request +0x02, the drive (FDC_CommandEntry_CopyParams copies the caller's 16-byte request to FDC_COMMAND_INDEX..)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a42
	.equ FDC_REQ_HEAD,			0x89a8	; word: request +0x04, the head (command 9 reads it as the new disk-changed flag)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a44
	.equ FDC_REQ_TRACK,			0x89aa	; word: request +0x06, the track (command 0: the media-type code)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a46
	.equ FDC_REQ_SECTOR,			0x89ac	; word: request +0x08, the starting sector (1-based)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a48
	.equ FDC_REQ_COUNT,			0x89ae	; word: request +0x0a, the sector count	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a4a
	.equ FDC_REQ_BUFFER,			0x89b0	; request +0x0c, the buffer address (the DMA memory address, advanced after each burst; a format points it at FDC_FORMAT_IDS)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a4c
	.equ FDC_REQUEST_COPY,			0x89b4	; [16 bytes] the second copy of the caller's request FDC_CommandEntry_CopyParams makes	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a50
	.equ FDC_RESULT,			0x89c4	; [7 bytes] the result-phase bytes FDC_ResultPhase_Read collects (ST0 first)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a60
	.equ FDC_RETRY_COUNT,			0x89cc	; retries left: 8 for a read or write, 1 for a probe read; at 0 the command fails with error 16 (read) or 32 (write)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a68
	.equ FDC_DISK_CHANGED,			0x89ce	; disk-changed flag: command 9 sets 0xff or 0; cleared at initialisation	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a6a
	.equ FDC_DRIVE_MODE,			0x89d0	; drive mode 0-5 (FDC_CONFIG_VERIFY's media cases)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a6c
	.equ FDC_FORMAT_IDS,			0x89d4	; the sector ID bytes a FORMAT TRACK sends by DMA (FDC_FormatOneTrack builds them)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8a70
	.equ FDC_CURRENT_CYLINDER,		0x8a68	; the cylinder last sought to, 0xff = unknown (FDC_CmdSeek compares it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8b04
	.equ FDC_SECTOR_LIMIT,			0x8a70	; word: one more than the sectors per track (10, 9 or 19 by media type); bounds the sector number in the read and write loops	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8b0c
	.equ FDC_PROBE_REQUEST,			0x8a88	; [16 bytes] the request FDC_Reset_BuildParams builds for the disk-format probe: {command, drive, head, track, sector, count, buffer}	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8b24
	.equ DISPLAY_CHORD_ROOT,		0x8ca4	; the chord MainChordPre shows: its root (copied from CHORD_ROOT by Chord_ApplyCurrentChord)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8d40
	.equ DISPLAY_CHORD_TYPE,		0x8ca6	; the chord MainChordPre shows: its type	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8d42
	.equ DISPLAY_CHORD_BASS,		0x8ca8	; the chord MainChordPre shows: its bass root, 0 unless it is an on-bass chord	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8d44
	.equ DIAG_ANIM_STEP,			0x8cde	; step of the diagnostic title sequence, 1..5 then wrapping to 1 every 30 calls (EffectMode_DiagSeq_AnimFrame)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8d7a
	.equ LED_REQUEST_1,			0x8e9e	; word: panel-LED update requests of group 1; MIDI_ProcessChangedChannels runs PanelLed_PendingGroup1Handlers for the bits set here and not in LED_REQUEST_HOLD_1, then clears it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f3a
	.equ LED_REQUEST_HOLD_1,		0x8ea0	; word: group-1 bits held back	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f3c
	.equ LED_REQUEST_2,			0x8ea2	; word: panel-LED update requests of group 2 (PanelLed_PendingGroup2Handlers)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f3e
	.equ LED_REQUEST_HOLD_2,		0x8ea4	; word: group-2 bits held back	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f40
	.equ LED_REQUEST_3,			0x8ea6	; word: panel-LED update requests of group 3 (PanelLed_PendingGroup3Handlers)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f42
	.equ LED_REQUEST_HOLD_3,		0x8ea8	; word: group-3 bits held back	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f44
	.equ DEMO_PLAY_STATE,			0x8eb2	; 4 = idle (the Demo_SelectEntry_* paths), 6 = a song started by Demo_SelectEntry_PlaySong	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x8f4e
	.equ SWBTWR_WRITE_INDEX,		0x9042	; word: write index of the parameter-event output buffer that MIDI_WriteCommandToBuffer, AssswbWr and the SwbtWr_* appenders fill (Audio_InitAllDefaults zeroes it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x90de
	.equ PART_RECORD_PTRS,			0x9056	; address of the part-record pointer table: entry p = part p's RAM record, 0xffffffff = none (Audio_InitAllDefaults stores it; MIDI_WriteVoiceParam* index it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x90f2
	.equ PROGRAM_CHANGE_PART,		0x905b	; the part a program change or sound selection is for: 0..31, 16-20 from the accompaniment chains (AccPatch_UpdateChain_*), 72 = the rhythm part	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x90f7
	.equ PANEL_EVENT_SOURCE,		0x905c	; source of the switch event being applied: 127 = the front panel (Audio_InitAllDefaults and the queue drain store it), 0xff = the switch-write path, else the event's own byte (VoiceMode_ParamDispatch); the INTRO & ENDING buttons choose intro or ending by the transport only for 127	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x90f8
	.equ EXTDATA_TLV_OFFSET,		0x9093	; byte offset in the panel record (tag MIDI_MSG_STATUS) the ExtData_* handlers change	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x912f
	.equ EXTDATA_VALUE,			0x9094	; the received value; with EXTDATA_MASK a two-byte value for ExtData_SetTempoIfChanged	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9130
	.equ EXTDATA_MASK,			0x9095	; the bits of the record byte EXTDATA_VALUE may change (ExtData_SetTlvField)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9131
	.equ EXTDATA_NEW_VALUE,			0x9096	; the record byte after the change, also sent as MIDI_MSG_DATA2	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9132
	.equ EXT_RECORD_OFFSET,			0x9097	; word: read offset into PANEL_EVENT_QUEUE, the buffer of received 4-byte records (SndParam_FetchSequencerParams; a type byte 0xff ends the scan)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9133
	.equ MIDI_CUR_PART,			0x912c	; the part the MIDI controller and pending-parameter handlers work on (Pending*_ScanEntry, MidiCtrl_Mode*_Handler, the Part_ReinitAllActive loop)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x91c8
	.equ MIDIRX_STATUS,			0x9598	; status byte of the MIDI message being received (MidiSerial_PumpLoop; MidiRx_ChannelMsgDispatch maps its channel to parts)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9634
	.equ MIDIRX_DATA1,			0x9599	; its first data byte (the controller number of a CC, the program of a program change)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9635
	.equ MIDIRX_DATA2,			0x959a	; its second data byte (the controller value the MidiCC_Handler_* read)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9636
	.equ MIDIRX_PART_EVENT,			0x95a8	; [4 bytes] the part-parameter event a MIDI receive handler builds: +0 target, +1 part, +2 value, +3 mask; MidiCC_QueuePartParam queues it on the SwbtWr queue	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x9644
	.equ MIDIRX_PART,			0x95ce	; the part a received channel message is being applied to: MidiRx_ChannelMsgDispatch walks the parts the channel maps to and calls the handler for each	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x966a
	.equ MIDIRX_PARTS_LEFT,			0x95cf	; parts of that list still to do (MidiRx_ChannelMsgDispatch counts it down)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0x966b
	.equ MIDIPKT_RX_GROUPS,			0xbc7e	; bulk-receive groups completed, bits 7 panel, 6 sound RAM, 5 / 4 / 2 the others: MidiSysEx_Finish*Xfer act on their bit and clear it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xbd1a
	.equ PANEL_EVENT_QUEUE,			0xbf9d	; the PanelEvent_Post queue of 4-byte records {type, ...}; 0xff ends it (Encoder_MarkInvalid empties it; SwbtWr walks it, EXT_RECORD_OFFSET indexes it)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xc039
	.equ SWBTWR_DISPATCH_INDEX,		0xbfdf	; word: read offset in the SwbtWr dispatch buffer (SwbtWr_DispatchLoop)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xc07b
	.equ SWBTWR_BUFFER_PTR,			0xbfed	; the SwbtWr dispatch buffer (SwbtWr_InitBank1-3 point it at their bank)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xc089
	.equ HARMONY_NOTE_LIST,			0xcd86	; the note list Harmony_FindReferenceNote scans: word count, then 2-byte entries from +4 (VoiceMap_AllocateSlot, NoteMap_FindBestMatch)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xce22
	.equ HARMONY_REF_NOTE,			0xce0e	; harmony reference note: the lowest note of the list Harmony_FindReferenceNote scans, if in 25..102, else 0xff	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xceaa
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
	.equ CHORD_CHANGED,			0xce65	; word: Chord_ApplyCurrentChord sets the high byte to 0xff; Voice_UpdatePlayModeState reports and clears it	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcf01
	.equ CHORD_PREV_KEY_COUNT,		0xce7b	; word: chord keys held before the change being recognized (Chord_RecognizeNowOrDelay)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xcf17
	.equ SOUND_TABLE_BASE,			0xe0b2	; the sound-table base every sound-data lookup goes through (SoundData_CategoryDescPtr is stored here; 14 loads)	; v7 address, derived from v10's uses (name_kn5000_ram.py); was a copy of v10's 0xe14e
	.equ SEQ_SONG_RECORD,			0xf180	; [0x800 bytes] the current song's record: VoicePreset_LoadAndInitPan copies song SEQ_CURRENT_SONG's slot (SEQ_SONG_SLOTS + n * 0x800) in, SeqData_CopyBlockToBuffer copies it back
	.equ SEQ_TRACK_MASK,			0xf19e	; word: one bit per track (bit t - 1): Chan_SetActiveBit sets or clears a track's bit; recording takes the recorded tracks out while it runs (SeqPlay_ActivatePartsAndSendOff) and puts them back; Seq_FindRhythmTrack and Demo_ScanPartLoop consider only tracks whose bit is set; a field of SEQ_SONG_RECORD
	.equ SEQ_TRACK_ASSIGN,			0xf1a0	; [16 bytes] TRACK ASSIGN value of each of the 16 tracks (13 CHORD, 14 APC, 15 CONTROL, 16 RHYTHM ...), part of SEQ_SONG_RECORD
	.equ SQEDT_TRKMRG_TRACK_A,		0xf1d3	; TT_SQTRKMRG: first source track (MrgTrA), a field of SEQ_SONG_RECORD
	.equ SQEDT_TRKMRG_TRACK_B,		0xf1d4	; TT_SQTRKMRG: second source track (MrgTrB)
	.equ SQEDT_TRKMRG_TRACK_C,		0xf1d5	; TT_SQTRKMRG: destination track (MrgTrC)
	.equ SQEDT_MDEL_TRACK,			0xf1d6	; TT_SQMDEL (measure delete): track
	.equ SQEDT_MDEL_FROM,			0xf1d7	; TT_SQMDEL: first measure (word)
	.equ SQEDT_MERS_TRACK,			0xf1db	; TT_SQMERS (measure erase): track
	.equ SQEDT_MERS_FROM,			0xf1dc	; TT_SQMERS: first measure (word)
	.equ SQEDT_MERS_CHOICE,			0xf1e0	; TT_SQMERS: what to erase (EXECUTE copies it to SEQ_OP_ERASE_CHOICE)
	.equ SQEDT_MINS_TRACK_A,		0xf1e1	; TT_SQMINS (measure insert): track A
	.equ SQEDT_MINS_FROM,			0xf1e2	; TT_SQMINS: first measure of A (word)
	.equ SQEDT_MINS_TRACK_B,		0xf1e6	; TT_SQMINS: track B
	.equ SQEDT_MINS_AT,			0xf1e7	; TT_SQMINS: measure of B to insert at (word)
	.equ SQEDT_MCP_TRACK_A,			0xf1e9	; TT_SQMCP (measure copy): source track
	.equ SQEDT_MCP_FROM,			0xf1ea	; TT_SQMCP: first source measure (word)
	.equ SQEDT_MCP_TRACK_B,			0xf1ee	; TT_SQMCP: destination track
	.equ SQEDT_MCP_AT,			0xf1ef	; TT_SQMCP: destination measure (word)
	.equ SQEDT_QTZ_TRACK,			0xf1f1	; TT_SQQTZ (quantize): track (0x11 = all)
	.equ SQEDT_QTZ_FROM,			0xf1f2	; TT_SQQTZ: first measure (word)
	.equ SQEDT_QTZ_VALUE,			0xf1f6	; TT_SQQTZ: the quantize value (EXECUTE doubles it into SEQ_OP_QUANTIZE)
	.equ SQEDT_VELOCNG_TRACK,		0xf228	; TT_SQVELOCNG (velocity change): track
	.equ SQEDT_VELOCNG_FROM,		0xf229	; TT_SQVELOCNG: first measure (word)
	.equ SQEDT_VELOCNG_AMOUNT,		0xf22e	; TT_SQVELOCNG: the velocity amount (EXECUTE copies it to SEQ_OP_VELOCITY)
	.equ SEQ_FREE_LIST_HEAD,		0xf22f	; word: first block of the free-block list, 0xffff = none; DispatchHandler_ResolveSlot takes it, moves the head to its +3 link, marks the block used (bit 7) and counts SEQ_FREE_BLOCKS down; a field of SEQ_SONG_RECORD
	.equ SEQ_FREE_BLOCKS,			0xf231	; word: blocks still free; DispatchResolve_MarkCurrent takes one (sets bit 7 of its first byte, decrements); 0 makes ToneGen_AdvancePosition fail with SEQ_EVENT_ABORT = 255
	.equ SEQ_PUNCH_IN_MEASURE,		0xf238	; word: the punch-in ("P" in) measure of the play screen (MT_GetPInMeasString)
	.equ SEQ_PUNCH_OUT_MEASURE,		0xf23a	; word: the punch-out measure (SeqPlay_IncPunchOutMeasure keeps the punch-in below it)
	.equ SEQ_COUNT_IN,			0xf23f	; count-in measures before the punch-in (play-screen parameter 10)
	.equ SEQ_TRACK_TABLE,			0xf250	; [48 bytes] 16 three-byte track entries of the current song; bit 7 of the first byte = the track holds data (SqStep_CheckCursorTrackUsed); part of SEQ_SONG_RECORD
	.equ LIVE_PANEL_BLOCK,			0xf980	; the live panel block, 0x280 bytes (it holds PANEL_RECORDS): MidiPkt_SetXferBlock_LivePanel transfers it, FileData_ImportNNLivePanel loads into it, the power-fail NMI checksums it
	.equ NMI_CHECKSUM_REGION2,		0xffd2	; word: checksum of LIVE_PANEL_BLOCK, stored and checked the same way
	.equ NMI_CHECKSUM_REGION1,		0xffd4	; word: checksum of the 0x800 words from SEQ_SONG_RECORD on, which NMI_StorePayloadChecksums stores at power-fail; SubCPU_Payload_Verify checks it at boot
	.equ SEQ_CURRENT_SONG,			0xffe3	; the selected song, 0..9: its record is SEQ_SONG_SLOTS + n * 0x800 (Display_CopyToneTableToRAM, SetSongSlotValue); set when a song is loaded (SMF_FinalizeAndStartPlayback)
	.equ SEQ_TRACK_MASK_COPY,		0xffec	; word: the copy of SEQ_TRACK_MASK kept outside the song record: SqSngSel_CalcSongUsageOnEnter and AccompMode_ApplyAndNotify copy it in, SingleLoad_PrepareSongSlot / _FinishSongLoad save and restore it around a load
	.equ FILE_ERROR,			0x1e53c	; word: the file system's last error: FileOpen_CheckPermission stores 2, SeqStep_MemAllocFail 3, FileOpen_SlotExhausted 4, FileOpen_ErrorNoFile 7; FDC status codes are mapped into it (FDC_SetSectorLength)
	.equ SEQMAIN_READ_POS,			0x1f373	; word: read index of the main sequencer ring buffer SEQMAIN_RING (Seq_CheckSongEnd compares it with SEQMAIN_WRITE_POS)
	.equ SEQMAIN_WRITE_POS,			0x1f377	; word: write index of SEQMAIN_RING
	.equ SEQMAIN_RING,			0x1f37b	; the main sequencer ring buffer of MIDI events (SeqMain_WriteByte / SeqMain_ReadData; sequencer.md "Ring Buffer Pipeline")
	.equ SEQBUF_MIDIOUT,			0x1f785	; the MIDI-out ring buffer (SeqBuf_MidiOut_*)
	.equ SEQBUF_DSPSYSEX,			0x1fca3	; the DSP SysEx ring buffer (SeqBuf_DspSysEx_*)
	.equ LYRIC_LINES,			0x20cbe	; the lyric box's line buffers (LyricsBox_ClearBuffers blanks them, LyricsBox_DrawCurrentLine draws from them)
	.equ PRESENTATION_LOADED,		0x251d8	; word: 1 while a presentation started from disk is loaded (Seq_InitializeAndStart sets it, MainPreControl clears it; MT_ExistPresentation returns it)
	.equ FILE_LIST_LAST,			0x271f0	; word: index of the last entry of the file list (59 for a full list, 9 for the wallpapers; GetFileCount_StoreAndClamp)
	.equ NAMING_LENGTH,			0x274d6	; word: length of the name being edited (32 from AcNaming_InitScrollState)
	.equ NAMING_CURSOR,			0x274d8	; word: cursor position in the name being edited (kept below NAMING_LENGTH)
	.equ NAMING_PAGE,			0x274da	; word: the character page shown: 0 A-Z _ 0-9 SPC, 1 a-z _ 0-9 SPC, 2 symbols
	.equ NAMING_CHAR,			0x274de	; word: the character at the naming window's cursor, as an index into the character page (0x1a underscore, 0x25 space); the dial steps it
	.equ NAMING_MODE,			0x274e2	; word: the naming mode EVT_GET_NAMING_MODE reported (it bounds the character pages)
	.equ NAMING_CHARSET,			0x274e4	; the naming mode's character set (AcNaming_QueryCharSet stores it); its first byte fills and erases the name
	.equ OBJECT_REGISTRY,			0x27ed2	; the object table RegisterObjectTable fills: 14-byte entries {class, proc, count, table}, entry n at +14n (ClassProc, FunctionProc, TitleProc ... look objects up here)
	.equ TITLE_FLAGS,			0x2bc30	; word: the current title's flags: 0x1 hold, 0x4 do not draw, 0x8 vari, 0x10 keep, 0x20 easy set (MT_SetHold, MT_SetNotDrawFlag, MT_SetTitleFlag; CheckNotDrawFlag)
	.equ EVENT_QUEUE,			0x2bc34	; the event queue PostEvent / ApPostEvent fill: 1,024 entries of 12 bytes {target, event, param} (GetEvent, DeleteEvent scan it)
	.equ DRAW_ENABLED,			0x3044e	; word: 0 = nothing is drawn (ColorBlit, DrawBitmap and the other drawing primitives return); DrawWall sets 1
	.equ WALLPAPER_BITMAP,			0x30452	; the wallpaper bitmap, 320 bytes per row (ChangeWall_Impl stores it); colour 0xf5 draws by copying the pixel from it
	.equ DRAW_QUEUE,			0x30466	; the 8 KB circular queue of draw commands (DrawQueue_Alloc, DrawRing_Init): each entry a DrawXxx_Impl address and its parameters
	.equ DRAW_QUEUE_WRITE_PTR,		0x3246a	; where DrawQueue_Alloc puts the next command
	.equ MUSIC_STYLIST_GENRE,		0x340c4	; word: the genre selected on the Music Stylist pages (MstStyle_*)
	.equ MUSIC_STYLIST_GROUP_TABLE,		0x340d2	; the group table of that genre (MstStyle1Page_EventDispatch loads it)
	.equ HELP_LANGUAGE,			0x340e4	; the help / feature-demo text language: 0 English, 1 German, 2 French, 3 Spanish, 4 Italian, 5 Indonesian (MT_SetLang, CheckLanguage; the FtLangText* tables are indexed by it)
	.equ SURE_CONFIRM,			0x340ea	; non-zero = ask "are you sure?" before a delete, overwrite or clear (SureJudgeFunc, FileName_OpDelete, CmpBkslSTtl_DirectMode_OnClearPattern); 0 = act at once
	.equ PANEL_RECALL_BACKUP,		0x3c8e4	; [960 bytes] backup of the live panel records PANEL_RECORDS..+959, which a panel-memory recall restores the current style and MSP fields from
	.equ SQEDT_FROM_CURSOR,			0x3e2dc	; the FROM side's field cursor
	.equ SQEDT_TO_CURSOR,			0x3e2de	; the TO side's field cursor
	.equ SQEDT_CURSOR_SIDE,			0x3e2e0	; the sequencer edit title's cursor side: 0 = the FROM fields, 1 = the TO fields (SqedtFunc_OnChkCur2_*)
	.equ SDPART_ROW,			0x3e99e	; word: the selected row of the part list (IvSdpart_*, AcLswPartEdit*, PsMixer_*): row * 2 indexes the row's part
	.equ GFX_BG_COLOR,			0x3efa2	; word: background colour (Display_SetBackgroundColor stores it)
	.equ GFX_FG_COLOR,			0x3efa4	; word: foreground colour of the drawing primitives (GraphicsRender_ByteData stores it; the SeGfx ops and DrawText_* push it)
	.equ FONTID_NAME_TABLE,			0x3efac	; the font-name pointer list FontIDProc reads (RAM copy of FontIDProc_FontNameTable, made by Boot_InitWorkRAM; no code writes it after boot: notes/kn5000-a-2026-10-31/probes/fontid_table_writers.py)
