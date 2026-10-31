# open4/kn5000-b-hdae (2026-10-31): the main CPU's sound-RAM image converters were prefixed
# HdaeRom_ although they have nothing to do with the HD-AE5000 (kn5000-nl6 lead).  After a .TM
# file (or one SOUND MEMORY entry) is read into the image at 0x1E0000, SoundRam_IdentifyImage
# (was SendPartDataBlock_InitVal4) tells the model from the 16-byte id (1 KN2000, 2 MKA, 3 MKB,
# 4 KN3000, 5 KN1500, 6 KN5000, 0 unknown) and the two converters rewrite the 40 user sounds (470 B each)
# and the user drum kit (128 x 80 B) into the KN5000 layout.  Evidence: notes/open4-kn5000-b/hdae/README.md.
# Applied to v10, v9 (= v8), v7, v6, v5.  Exact-token rules (\b); _-suffixed locals listed one by one.
s/\bHdaeRom_DataHandler\b/SoundRam_ConvertUserSounds/g
s/\bHdaeRom_DataHandler_ConvertKn2000MkaMkb\b/SoundRam_ConvertUserSounds_Kn2000MkaMkb/g
s/\bHdaeRom_DataHandler_Loop3\b/SoundRam_ConvertUserSounds_Kn2000Loop/g
s/\bHdaeRom_DataHandler_Skip2\b/SoundRam_ConvertUserSounds_Kn2000One/g
s/\bHdaeRom_DataHandler_Loop\b/SoundRam_ConvertUserSounds_Kn2000OneLoop/g
s/\bHdaeRom_DataHandler_Join\b/SoundRam_ConvertUserSounds_Kn2000OneNext/g
s/\bHdaeRom_DataHandler_Skip\b/SoundRam_ConvertUserSounds_Done/g
s/\bHdaeRom_DataHandler_Epilogue\b/SoundRam_ConvertUserSounds_Epilogue/g
s/\bHdaeRom_DataDispatch\b/SoundRam_ConvertUserSounds_Kn1500/g
s/\bHdaeRom_DataDispatch_Loop2\b/SoundRam_ConvertUserSounds_Kn1500Loop/g
s/\bHdaeRom_DataDispatch_SetWord\b/SoundRam_ConvertUserSounds_BadImage/g
s/\bHdaeRom_DataDispatch_SetWord_Loop\b/SoundRam_WriteIdAndChecksum_CopyId/g
s/\bHdaeRom_DataDispatch_Block3\b/SoundRam_ConvertKn3000DrumKit/g
s/\bHdaeRom_DataDispatch_Block3_Loop2\b/SoundRam_ConvertKn3000DrumKit_ShiftLoop/g
s/\bHdaeRom_DataDispatch_Block3_Skip\b/SoundRam_ConvertKn3000DrumKit_SetFlags/g
s/\bHdaeRom_DataDispatch_Block3_Loop\b/SoundRam_ConvertKn3000DrumKit_FlagLoop/g
s/\bHdaeRom_DataHandler_Helper\b/SoundRam_RemapKn2000RecordFields/g
s/\bHdaeRom_DataHandler_Helper_Skip\b/SoundRam_RemapKn2000RecordFields_Skip/g
s/\bHdaeRom_DataHandler_Helper_Skip2\b/SoundRam_RemapKn2000RecordFields_Skip2/g
s/\bHdaeRom_DataHandler_Helper2_Entry\b/SoundRam_ConvertKn2000Record_Skip6/g
s/\bHdaeRom_DataHandler_Helper2_Entry_Join3\b/SoundRam_ConvertKn2000Record_Join3/g
s/\bHdaeRom_DataHandler_Helper2_Entry_Skip6\b/SoundRam_ConvertKn2000Record_Skip7/g
s/\bHdaeRom_AltHandler\b/SoundRam_ConvertUserDrumKit/g
s/\bHdaeRom_AltDispatch\b/SoundRam_ConvertUserDrumKit_Kn3000/g
s/\bHdaeRom_AltHandler_Kn5000Image\b/SoundRam_ConvertUserDrumKit_Kn5000Image/g
s/\bHdaeRom_AltDispatch_SetWord\b/SoundRam_ConvertUserDrumKit_BadImage/g
s/\bHdaeRom_AltHandler_Join\b/SoundRam_ConvertUserDrumKit_WriteId/g
s/\bHdaeRom_AltDispatch_SetWord_Loop\b/SoundRam_ConvertUserDrumKit_CopyId/g
s/\bHdaeRom_DataByteMap\b/SoundRam_Kn2000NibbleMap/g
s/\bHdaeRomData_SwitchOffsets\b/SoundRam_ConvertUserSounds_Cases/g
s/\bHdaeRomAlt_SwitchOffsets\b/SoundRam_ConvertUserDrumKit_Cases/g
s/\bSendPartDataBlock_InitVal4\b/SoundRam_IdentifyImage/g
s/\bSendPartDataBlock_LoadReg2\b/SoundRam_IdentifyImage_Kn5000Loop/g
s/\bSendPartDataBlock_Compare2\b/SoundRam_IdentifyImage_Kn5000Done/g
s/\bSendPartDataBlock_InitVal5\b/SoundRam_IdentifyImage_TryKn1500/g
s/\bSendPartDataBlock_LoadReg3\b/SoundRam_IdentifyImage_Kn1500Loop/g
s/\bSendPartDataBlock_Compare3\b/SoundRam_IdentifyImage_Kn1500Done/g
s/\bSendPartDataBlock_InitVal6\b/SoundRam_IdentifyImage_TryKn3000/g
s/\bSendPartDataBlock_LoadReg4\b/SoundRam_IdentifyImage_Kn3000Loop/g
s/\bSendPartDataBlock_Compare4\b/SoundRam_IdentifyImage_Kn3000Done/g
s/\bSendPartDataBlock_InitVal7\b/SoundRam_IdentifyImage_TryKn2000/g
s/\bSendPartDataBlock_LoadReg5\b/SoundRam_IdentifyImage_Kn2000Loop/g
s/\bSendPartDataBlock_Compare5\b/SoundRam_IdentifyImage_Kn2000Done/g
s/\bSendPartDataBlock_InitVal8\b/SoundRam_IdentifyImage_TryMka/g
s/\bSendPartDataBlock_LoadReg6\b/SoundRam_IdentifyImage_MkaLoop/g
s/\bSendPartDataBlock_Compare6\b/SoundRam_IdentifyImage_MkaDone/g
s/\bSendPartDataBlock_InitVal9\b/SoundRam_IdentifyImage_TryMkb/g
s/\bSendPartDataBlock_LoadReg7\b/SoundRam_IdentifyImage_MkbLoop/g
s/\bSendPartDataBlock_Compare7\b/SoundRam_IdentifyImage_MkbDone/g
s/\bSendPartDataBlock_ClearByte5\b/SoundRam_IdentifyImage_Unknown/g
s/\bSendPartDataBlock_SetWord7\b/SoundRam_StoreChecksum/g
s/\bSendPartDataBlock_Block11\b/SoundRam_StoreChecksum_Loop/g
# HD-AE5000 trees (hdae5000, hdae5000_v2_01i, hdae5000_v1_15i, hdae5000_v1_10i): PC-link services 18 / 27
# (no trace banner) named from what they call.
s/\bHDAE5000_PPORT_Svc18\b/HDAE5000_PPORT_Svc18_RequestNormalMode/g
s/\bHDAE5000_PPORT_Svc27\b/HDAE5000_PPORT_Svc27_DeleteSongParts/g
# v10/v9 also spelled the two switch tables through .set aliases COMM_InitFuncTable + 540 / + 552 (same addresses,
# checked with llvm-nm); the aliases were removed and the code names SoundRam_ConvertUser*_Cases directly.
