# kn5000-j8z, lane open6/kn5000-d naming (2026-11-02).
# Applied to the .s/.c/.h/.ld files of v10/v9/v7/v6/v5 maincpu (v8 = v9's source).  Evidence per rule:
# notes/open6-kn5000-d/naming/README.md, section kn5000-j8z.  The headers, the data respelling of
# StyleSection_GroupBaseTable and the comment fixes are scripts/renaming/open6_naming_patches.py --j8z.
#
# Section index (STYLE_SECTION 0..29) -> its group's first variation (0 A, 4 B, 8 C); no reader in v5..v10.
s/\bRhythmProc_ChannelMapTable\b/StyleSection_GroupBaseTable/g
#
# MainSysControl INITIAL SETTING, case 4 PANEL MEMORY: header "HK" + 0xa0 bytes of names from table data
# 0x99ec00, then the 80 panel memories (0x1ed400, 960 B each) from table data 0x99eca0 + 0x2a2 * n and
# SndParamRam_DefaultImage, then the PanelMem_FixupRecords fix-ups.
s/\bDisplay_CopyAndRenderBitmaps_Str_HK\b/PanelMem_HeaderTemplate/g
s/\bDisplay_CopyAndRenderBitmaps\b/PanelMem_InitAllFromFactory/g
s/\bDisplayRender_Loop\b/PanelMem_InitAllFromFactory_Loop/g
s/\bVoiceData_InitAndCopyParams\b/PanelMem_InitFromFactory/g
s/\bVoiceData_InitDone\b/PanelMem_InitFromFactory_Done/g
s/\bDisplay_ProcessBitmapTable\b/PanelMem_ApplyFixups/g
s/\bBitmapTable_ProcessEntry\b/PanelMem_ApplyFixups_Record/g
s/\bBitmapTable_RenderLine\b/PanelMem_ApplyFixups_AllLoop/g
s/\bBitmapTable_CheckOffset\b/PanelMem_ApplyFixups_One/g
s/\bBitmapTable_NextEntry\b/PanelMem_ApplyFixups_Next/g
#
# Case 5 COMPOSER: AccDemo_Init (the empty built-in style image) + AccPatch_CountAvailableSlots.
s/\bAccDemo_InitDone\b/Composer_ResetStyleImage/g
#
# Case 6 SEQUENCER: re-initialises song slots 0..10 (DataBuf_InitSlotFromPreset, Part_WriteByte/Word defaults).
s/\bPart_InitFromPreset/SeqSong_ResetAll/g
#
# Case 7 MSP USER: the accompaniment block area 0x1e8800 from Voice_FactoryPresetData / MSP_FACTORY_DEFAULTS.
s/\bVoice_InitBankDataSafe\b/MspUser_ResetToFactory/g
s/\bVoice_InitBankData\b/MspUser_InitFromFactory/g
#
# Case 8 SOUND MEMORY and the sound-RAM subsystem's init-phase table SoundRam_InitFuncTable.
s/\bSendPartDataBlock_ClearByte4\b/SoundRam_InitPhase0_SendImage/g
s/\bSendPartDataBlock_LoadReg\b/SoundRam_InitPhase0_SendImage_IdLoop/g
s/\bSendPartDataBlock_Compare\b/SoundRam_InitPhase0_SendImage_IdDone/g
s/\bSendPartDataBlock_SetWord6\b/SoundRam_InitPhase0_SendImage_NoImage/g
s/\bSendPartDataBlock_Return4\b/SoundRam_InitPhase1_Nop/g
s/\bSendPartDataBlock_DoGetError\b/SoundRam_InitPhase2_ResetIfRamLost/g
s/\bSendPartDataBlock_Return5\b/SoundRam_InitPhase3_Nop/g
s/\bSendPartDataBlock_SetWord5\b/SoundRam_ComputeChecksum/g
s/\bSendPartDataBlock_Block10\b/SoundRam_ComputeChecksum_Loop/g
#
# The HdaeRom_* labels are SwbtWr bank-2 listeners (SwbtB2_CodeNN_Listeners lists, code = panel TLV tag),
# not HD-AE5000 code (probes/swbt_listener_owners.py lists the owner of each per tree).
# DSP slot records 0x61 / 0x63 / 0x65 / 0x66 / 0x64 (slots 0..4): any change of payload bytes 0..24
# is applied as a change of byte 0 (SndParam_ApplyEventField).
s/\bHdaeRom_ProcessBlock/PanelTag61_ApplyDspSlot/g
s/\bSwbtB2_Code63_Listener\b/PanelTag63_ApplyDspSlot/g
s/\bHdaeRom_ReadParam_Epilogue\b/PanelTag63_ApplyDspSlot_Epilogue/g
s/\bHdaeRom_WriteParam/PanelTag64_ApplyDspSlot/g
s/\bHdaeRom_CheckResult/PanelTag65_ApplyDspSlot/g
s/\bHdaeRom_FinishBlock/PanelTag66_ApplyDspSlot/g
# Empty listeners (a lone `ret`), named like SwbtB2_Code69_NopListener.
s/\bHdaeRom_ReadParam\b/SwbtB2_Code62_NopListener/g
s/\bHdaeRom_TableEntry0\b/SwbtB2_Code68_NopListener/g
s/\bHdaeRom_TableEntry1\b/SwbtB2_Code6A_NopListener/g
s/\bHdaeRom_AltEntry\b/SwbtB2_Code80_NopListener/g
s/\bHdaeRom_AltTableEntry7\b/SwbtB2_CodeB6_NopListener/g
s/\bHdaeRom_AltTableEntry8\b/SwbtB2_CodeB7_NopListener/g
# v7 / v6 / v5 still carry v10's PanelTag60 / PanelTag72 listeners under HdaeRom_ names.
s/\bHdaeRom_Entry/PanelTag60_ApplyEffectOnOff/g
s/\bHdaeRom_TableEntry2\b/PanelTag72_ApplyPartMix/g
s/\bHdaeRomEntry2_SwitchOffsets\b/PanelTag72_ApplyPartMix_SwitchOffsets/g
# Field-by-field listeners: each masked field of payload byte 3 goes to SndParam_ApplyEventField.
s/\bHdaeRom_AltReadParam/PanelTag70_ApplyFields/g
s/\bHdaeRom_AltProcessBlock/PanelTag92_ApplyFields/g
s/\bHdaeRom_AltCheckResult/PanelTag98_ApplyFieldsAndVolume/g
s/\bHdaeRom_AltTableEntry0\b/PanelTagAE_ApplyFields/g
s/\bHdaeRom_AltTableEntry1/PanelTagB0_ApplyFields/g
s/\bHdaeRom_AltTableEntry2\b/PanelTagB1_ApplyFields/g
s/\bHdaeRom_AltTableEntry3\b/PanelTagB2_ApplyFields/g
s/\bHdaeRom_AltTableEntry4/PanelTagB3_ApplyFields/g
s/\bHdaeRom_AltTableEntry5\b/PanelTagB4_ApplyFields/g
s/\bHdaeRom_AltTableEntry6\b/PanelTagB5_ApplyFields/g
s/\bHdaeRom_AltTableEntry9/PanelTag43_ApplyFields/g
# 16-entry nibble -> code map of SoundRam_ConvertSounds_Helper (older-model sound records).
s/\bHdaeRom_DataByteMap\b/SoundRam_ConvertNibbleMap/g
