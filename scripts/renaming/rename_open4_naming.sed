# kn5000-nl6 naming leads, lane open4/kn5000-b-naming (2026-10-31).
# Applied to v10/v9/v7/v6/v5 maincpu (v8 = v9's source).  Evidence per rule: notes/open4-kn5000-b/naming/README.md.
# MainPmanControl case 0 (EVT_LSW_PUT); v10 had it already.
s/\bMainPmanCtrl_Case0\b/MainPmanCtrl_OnLswPut/g
# AppEvent toggle tail: the join both toggles fall into, not a switch case.
s/\bSeqState_Case4\b/AppEvent_DispatchToVoiceHandler/g
# One-panel-memory single load (SingleLoadDst_PanelMemListProc, not ALL mode).
s/\bFileIO_ByteBlock_DemoProc1/SingleLoad_LoadPanelMemory/g
# file_io/wallpaper.s: the single-load name getters and area scan, not wallpaper code.
s/\bWP_ScanAvailability\b/SingleLoad_ScanAreas/g
s/\bWPScan_SlotFlagBits\b/SingleLoad_AreaFlagBits/g
s/\bWPScan_/SingleLoad_ScanAreas_/g
s/\bWP_FindNextSlot\b/SingleLoad_FindNextArea/g
s/\bWPFind_/SingleLoad_FindNextArea_/g
s/\bWP_GetConfigName\b/SingleLoad_GetFileBankName/g
s/\bWP_GetNameByOffset\b/SingleLoad_GetFileMemoryName/g
s/\bWP_GetPresetName1\b/SingleLoad_GetComposerBankName/g
s/\bWP_GetPresetPtr\b/SingleLoad_GetVariationName/g
s/\bWP_GetBankMemName/SingleLoad_GetComposerSectionName/g
s/\bWP_GetPresetName3_PtrTable\b/SingleLoad_SoundMemBankNames/g
s/\bWP_GetPresetName3\b/SingleLoad_GetSoundMemBankName/g
s/\bWP_GetUserName1\b/SingleLoad_GetSoundRamName/g
s/\bWP_GetUserName2\b/SingleLoad_GetUserKitName/g
s/\bWP_GetUserName3\b/SingleLoad_GetUserKitEntryName/g
s/\bWP_SectionNameTable\b/SingleLoad_StyleSectionNames/g
s/\bWP_VariationName8_Empty\b/Str_Variation9_Empty/g
s/\bStr_BankMem0_Empty\b/Str_StyleSection0_Empty/g
s/\bWP_BankMemName1_Empty\b/Str_StyleSection1_Empty/g
s/\bWP_SectionName_Vari3Blank\b/Str_StyleSection2_Empty/g
# Value-map lookups (SndParam_OffsetHandler with selector 1 / 2), not scoop curve code.
s/\bParam_SignExtendReturn\b/SndParam_ValueMapLookup/g
s/\bScoop_CurveUpdate_NextSegment\b/SndParam_ValueMapLookupSel2/g
s/\bScoopDisp_BytecodeBlock1_Helper\b/SndParam_ValueMapLookupSel1/g
# GLOBAL_ERROR_CODE = table[SEQ_ERROR_CODE]: error-code maps, not voice tables.
s/\bPart_LoadAndApplyVoiceTable\b/SeqError_MapToGlobal/g
s/\bPart_ApplyVoiceTableA\b/SeqError_MapViaTableA/g
s/\bPart_ApplyVoiceTableB\b/SeqError_MapViaTableB/g
s/\bPart_ApplyVoiceTableC\b/SeqError_MapViaTableC/g
s/\bPart_ApplyVoiceTableA_Table\b/SeqError_MapTableA/g
s/\bPart_ApplyVoiceTableB_Table\b/SeqError_MapTableB/g
s/\bPart_ApplyVoiceTableC_Table\b/SeqError_MapTableC/g
s/\bSeqVoice_ApplyTableEntry_Table\b/SeqError_MapTableD/g
s/\bSeqVoice_ApplyTableEntry\b/SeqError_MapViaTableD/g
s/\bAppEvent_ExtendedHandler_Table_2\b/SeqError_MapTableF/g
s/\bAppEvent_ExtendedHandler_Table\b/SeqError_MapTableE/g
s/\bAppEvent_ExtendedHandler\b/SeqError_MapViaTableE/g
s/\bSeqPart_ByteBlockA95A_Helper\b/SeqError_MapViaTableF/g
# ArrowProc's EVT_PAINT: the arrow painters, not progress bars.
s/\bDrawProgressRectH\b/Arrow_DrawHorizontal/g
s/\bDrawProgressRectV\b/Arrow_DrawVertical/g
s/\bDrawProgH_/Arrow_DrawHorizontal_/g
s/\bDrawProgV_/Arrow_DrawVertical_/g
s/\bDrawDouble_/ArrowProc_/g
# FDD test title: switch 4/5 format a 2DD/2HD disk and label it; the dispatch names were swapped.
s/\bRegHamaTitle1_Entry/FDTest_Format2ddAndLabel/g
s/\bRegHamaTitle2_Entry/FDTest_Format2hdAndLabel/g
s/\bTitleFunc_LifecycleDispatch_CaseTable\b/TestTitleFunc_SwitchCaseTable/g
s/\bTitleFunc_LifecycleDispatch_On/TestTitleFunc_On/g
s/\bTitleFunc_LifecycleDispatch\b/TestTitleFunc_SwitchDispatch/g
s/\bTitleFunc_LifecycleTable/TestTitleFunc_OnTbiosTest/g
s/\bTitleFunc_ActionDispatch/TestTitleFunc_OnTitleNew/g
s/\bTestTitleFunc_CaseTable\b/TestTitleFunc_StateCaseTable/g
# Welcome-screen glyphs (the letters I, L/N/O, R, U), not digits.
s/\bBitmap_Digit1\b/WelcomeGlyph_I/g
s/\bBitmap_DigitL\b/WelcomeGlyph_L/g
s/\bBitmap_DigitR\b/WelcomeGlyph_R/g
s/\bBitmap_DigitD\b/WelcomeGlyph_U/g
# SqplyFunc: punch-in / punch-out / count-in strings; EqOnOffFuncToggleProc's own tail.
s/\bSqplyFunc_FormatIntro/SqplyFunc_FormatPunchIn/g
s/\bSqplyFunc_FormatEnding/SqplyFunc_FormatPunchOut/g
s/\bSqplyFunc_FormatFillIn/SqplyFunc_FormatCountIn/g
s/\bSqplyFunc_FormatDispatch\b/EqOnOff_ReturnZero/g
s/\bSqplyFunc_FormatEntry\b/EqOnOff_Epilogue/g
# The "ON" caption string of ButtonState_DispatchDSP.
s/\bNakaInst_OK\b/ButtonState_DispatchDSP_InlineData_Str_ON/g
# Seq-to-composer page: 0x398e is TRANSPOSE (25 = 0), 0x398f the composer memory number.
s/\bTempo_AdjustQuantize_WideArg\b/SeqToComposer_StepTranspose_WideArg/g
s/\bTempo_AdjustQuantize\b/SeqToComposer_StepTranspose/g
s/\bTempo_Quantize\(Dec\|SetDirty\|Return\)\b/SeqToComposer_StepTranspose_\1/g
s/\bTempo_IncrementTimeSigNum\b/SeqToComposer_IncMemoryNo/g
s/\bTempo_DecrementTimeSigNum/SeqToComposer_DecMemoryNo/g
# Sound-memory image conversion (older models' SOUND RAM images: KN2000, MKA, MKB, KN3000, KN1500), not the HD-AE5000.
s/\bSendPartDataBlock_InitVal4\b/SoundRam_IdentifyImage/g
s/\bSendPartDataBlock_SetWord7\b/SoundRam_WriteChecksum/g
s/\bSendPartDataBlock_Block11\b/SoundRam_WriteChecksum_Loop/g
s/\bHdaeRom_DispatchOffsetTable\b/SoundRam_ConvertSounds_CaseTable/g
s/\bHdaeRomData_SwitchOffsets\b/SoundRam_ConvertSounds_CaseTable/g
s/\bHdaeRom_AltDispatchOffsetTable\b/SoundRam_ConvertUserKit_CaseTable/g
s/\bHdaeRomAlt_SwitchOffsets\b/SoundRam_ConvertUserKit_CaseTable/g
s/\bHdaeRom_DataHandler_ConvertKn2000MkaMkb\b/SoundRam_ConvertSounds_Kn2000MkaMkb/g
s/\bHdaeRom_DataHandler/SoundRam_ConvertSounds/g
s/\bHdaeRom_DataDispatch_Block3/SoundRam_ConvertKn3000UserKit/g
s/\bHdaeRom_DataDispatch_SetWord_Loop\b/SoundRam_WriteIdAndChecksum_CopyId/g
s/\bHdaeRom_DataDispatch_SetWord\b/SoundRam_ConvertSounds_Unsupported/g
s/\bHdaeRom_DataDispatch/SoundRam_ConvertSounds_Kn1500/g
s/\bHdaeRom_AltHandler_Kn5000Image\b/SoundRam_ConvertUserKit_Kn5000/g
s/\bHdaeRom_AltHandler/SoundRam_ConvertUserKit/g
s/\bHdaeRom_AltDispatch_SetWord_Loop\b/SoundRam_ConvertUserKit_CopyId/g
s/\bHdaeRom_AltDispatch_SetWord\b/SoundRam_ConvertUserKit_Unsupported/g
s/\bHdaeRom_AltDispatch\b/SoundRam_ConvertUserKit_Kn3000/g
# The record-address helpers after TmFlash_BulkTransferToSubCPU (labels placed by the comment patch).
s/\bTmFlashBulkA_SwitchOffsets\b/SoundRam_GetRecordAddress_CaseTable/g
s/\bTmFlashBulkB_SwitchOffsets\b/SoundRam_GetRecordOffsetAndSize_CaseTable/g
s/\bVoiceParam_DispatchTable1_Code\b/SoundRam_GetRecordOffsetAndSize_Kn5000Kn3000/g
s/\bVoiceParam_DispatchTable1\b/SoundRam_GetRecordAddress_Kn5000Kn3000/g
s/\bTmFlash_BulkTransferToSubCPU_Switch2_Case5\b/SoundRam_GetRecordOffsetAndSize_Kn1500/g
s/\bTmFlash_BulkTransferToSubCPU_Switch2_Case1\b/SoundRam_GetRecordOffsetAndSize_Kn2000MkaMkb/g
s/\bTmFlash_BulkTransferToSubCPU_Join2\b/SoundRam_GetRecordOffsetAndSize_Join/g
s/\bTmFlash_BulkTransferToSubCPU_Skip5\b/SoundRam_GetRecordOffsetAndSize_Unknown/g
s/\bTmFlash_BulkTransferToSubCPU_Epilogue3\b/SoundRam_GetRecordOffsetAndSize_Epilogue/g
s/\bTmFlash_BulkTransferToSubCPU_Case5\b/SoundRam_GetRecordAddress_Kn1500/g
s/\bTmFlash_BulkTransferToSubCPU_Case1\b/SoundRam_GetRecordAddress_Kn2000MkaMkb/g
s/\bTmFlash_BulkTransferToSubCPU_Join\b/SoundRam_GetRecordAddress_Join/g
s/\bTmFlash_BulkTransferToSubCPU_Skip3\b/SoundRam_GetRecordAddress_Unknown/g
s/\bTmFlash_BulkTransferToSubCPU_Epilogue\b/SoundRam_GetRecordAddress_Epilogue/g
s/\bTmFlash_BulkTransferToSubCPU_Skip4\b/SoundRam_GetSoundSlot_OutOfRange/g
s/\bTmFlash_BulkTransferToSubCPU_Epilogue2\b/SoundRam_GetSoundSlot_Epilogue/g
s/\bTmFlash_BulkTransferToSubCPU_Skip2\b/SoundRam_CheckKnownImage_Fail/g
s/\bTmFlash_BulkTransferToSubCPU_Skip\b/SoundRam_CheckKn5000Image_Store/g
# Alias merges (g6 merge_into; AcChordBoxProc_Entry / DirmdEmulator_Entry sit on their routine's own address).
s/\bSndParam_RegisterLoop_Data\b/SndParam_Registry/g
s/\bSndParam_RO_Dispatch_Data\b/SndParam_ReadHandlers/g
s/\bSndParam_DispatchCallback_Data\b/SndParam_RegisterHandlers/g
s/\bSndParam_Lkp2_Dispatch_Data\b/SndParam_Register2Handlers/g
s/\bSndParam_RW_ProcessResult_Data\b/SndParam_EncodeHandlers/g
s/\bSndParam_DispatchTypeDE5_Data\b/SndParam_WriteHandlers/g
s/\bAcChordBoxProc_Entry\b/AcChordBoxProc/g
s/\bDirmdEmulator_Entry\b/DirmdEmulator/g
# Entries 2 and 5 of SndParam_EncodeHandlers return the style tempo clamped to 40..300.
s/\bSndParam_ClampReverbTime/SndParam_GetStyleTempoClamped/g
s/\bSndParam_ClampDelayTime/SndParam_GetStyleTempoClamped2/g
# Returns the index of the lowest bit of WA set (0..15, 16 if none); sends nothing.
s/\bDkMdlyPly_SendAudioCmd\b/DkMdlyPly_FindLowestSetBit/g
# MainSysControl's EVT_SYS_INI cases follow the INITIAL SETTING list (0 PERFORMANCE .. 8 SOUND MEMORY).
s/\bMainSysCtrl_Entry4_CopyBitmaps\b/MainSysCtrl_OnInitPanelMemory/g
s/\bMainSysCtrl_Entry1_AccDemo\b/MainSysCtrl_OnInitComposer/g
s/\bMainSysCtrl_Entry2_PartInit\b/MainSysCtrl_OnInitSequencer/g
s/\bMainSysCtrl_Entry5_VoiceInit\b/MainSysCtrl_OnInitMspUser/g
s/\bMainSysCtrl_Entry3_Misc\b/MainSysCtrl_OnInitSoundMemory/g
# Parameter 0x4005 = FADE IN/OUT level, COMM packet 6 (sub-CPU DSP_Set_FadeLevel).
s/\bSendEpilogue_Data_Case5\b/SndParam_ApplySystemParam_SendFadeLevel/g
s/\bSendPartDataBlock_Block3\b/COMM_SendFadeLevel/g
# NoteEventBuffer switch case tables, not MSP defaults.
s/\bMSP_Default_GroupOffsetB\b/NoteEventBuffer_CopyToSlot_CaseTable/g
s/\bMSP_Default_VarSize\b/NoteEventBuffer_Store_CaseTable/g
# The black-key x-offset table of the sound editor's mini keyboard (data, was spelled as dead code).
s/\bSeMenu_ShowConfirmDialog_Code\b/SeMenu_KeyboardOctave_BlackKeyX/g
s/\bSeMenu_ShowConfirmDialog_Data_Code_Loop2\b/SeMenu_DrawKeyboardOctave_BlackKeyLoop/g
