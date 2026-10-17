# written by scripts/renaming/apply_kn5000_naming_proposals.py
s/\bSubsys_HandlerTable01\b/COMM_InitFuncTable/g
s/\bWidgetDispatch_FDTestPtrTable\b/Xapr_InitFuncTable/g
s/\bSeqFormat_HandlerTable\b/SoundMode_InitFuncTable/g
s/\bSoundProgram_ParamPtrTable\b/Audio_InitFuncTable/g
s/\bSubsys_HandlerTable11\b/SoundData_InitFuncTable/g
s/\bWidgetData_CharsetMappingTable\b/SeqInit_InitFuncTable/g
s/\bSeqByteBlock_DispatchJumpTable\b/SeqDispatch_InitFuncTable/g
s/\bSoundRam_HandlerTable\b/SoundRam_InitFuncTable/g
s/\bCharMap_Preamble_Table\b/CharMap_InitFuncTable/g
s/\bSoundProgram_ResetAfterErrorVector\b/Audio_ResetAfterErrorVector/g
