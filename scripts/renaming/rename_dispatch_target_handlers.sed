# The 21 dispatch handlers still named <Table>_Target<k> (open item N-bc8cf677), named from their table entry and
# body.  The rules match the label and every local built on it (_Skip, _Return, _Str_Fmt1d ...).
#  Scoop_BoundOpHandlerTable (Scoop bound display list, op = record byte 0):
s/\bScoop_EventLoop_12Entry_Alt_Data_Target4\(_[A-Za-z0-9_]*\)\?\b/Scoop_BoundOp04_DrawBoxByField\1/g
s/\bScoop_EventLoop_12Entry_Alt_Data_Target5\(_[A-Za-z0-9_]*\)\?\b/Scoop_BoundOp05_PrintFieldAtCell\1/g
s/\bScoop_EventLoop_12Entry_Alt_Data_Target7\(_[A-Za-z0-9_]*\)\?\b/Scoop_BoundOp07_DrawStringByField\1/g
s/\bScoop_EventLoop_12Entry_Alt_Data_Target8\(_[A-Za-z0-9_]*\)\?\b/Scoop_BoundOp08_DrawRectByField\1/g
s/\bScoop_EventLoop_12Entry_Alt_Data_Target10\(_[A-Za-z0-9_]*\)\?\b/Scoop_BoundOp0A_PrintByte\1/g
s/\bScoop_EventLoop_12Entry_Alt_Data_Target11\(_[A-Za-z0-9_]*\)\?\b/Scoop_BoundOp0B_PrintSignedField\1/g
#  PanelLed_PendingGroup1..3Handlers ({bit, handler} lists of the LED-row update requests):
s/\bMIDI_ProcessChangedChannels_Data_Target0\(_[A-Za-z0-9_]*\)\?\b/PanelLed_ShowPartVoiceCategory\1/g
s/\bMIDI_ProcessChangedChannels_Data_Target1\(_[A-Za-z0-9_]*\)\?\b/PanelLed_ShowPartSelect\1/g
s/\bMidiChanged_ProcessGroup2_Data_Target0\(_[A-Za-z0-9_]*\)\?\b/PanelLed_ShowVoiceCategory_Via028000\1/g
s/\bMidiChanged_ProcessGroup3_Data_Target7\(_[A-Za-z0-9_]*\)\?\b/SndParam_SetResBit3_Via3390\1/g
s/\bMidiChanged_ProcessGroup3_Data_Target8\(_[A-Za-z0-9_]*\)\?\b/CtrlPanel_SetBit5At8F1E_ViaMode\1/g
s/\bMidiChanged_ProcessGroup3_Data_Target9\(_[A-Za-z0-9_]*\)\?\b/SndParam_SetResBit5_Via40C0\1/g
#  Scoop display event tables (32 entries, index = the display event; W bit 7 = dial direction):
s/\bPerfMode_EventTable_0_Target1\(_[A-Za-z0-9_]*\)\?\b/PerfMode_Evt01_NoteNumberDial\1/g
s/\bPerfMode_EventTable_0_Target2\(_[A-Za-z0-9_]*\)\?\b/PerfMode_Evt02_NoteVelocityDial\1/g
s/\bSubCPU_ToneParamRet_Target1\(_[A-Za-z0-9_]*\)\?\b/SubCPU_ToneParam_Evt01_SelectParamDial\1/g
s/\bUIState_EventTable_Target5\(_[A-Za-z0-9_]*\)\?\b/UIState_Evt05_MemConfig1ThenSeqPlay\1/g
s/\bUIState_EventTable_Target6\(_[A-Za-z0-9_]*\)\?\b/UIState_Evt06_MemConfig0ThenSeqPlay\1/g
s/\bUIState_EventTable_Target11\(_[A-Za-z0-9_]*\)\?\b/UIState_Evt0B_ShowPopup18\1/g
#  SoundEvt_ModeDispatch_Tbl entries 1 and 2, MemoryConfig_Handler_Table entry 2 (siblings MemConfig_Handler_0..5):
s/\bSoundEvt_LongPacketHandler_DispatchTbl_Target1\(_[A-Za-z0-9_]*\)\?\b/SoundEvt_Mode1_StepAndRefresh\1/g
s/\bSoundEvt_LongPacketHandler_DispatchTbl_Target2\(_[A-Za-z0-9_]*\)\?\b/SoundEvt_Mode2_StepAndRefresh\1/g
s/\bMemoryConfig_Handler_Table_Target2\(_[A-Za-z0-9_]*\)\?\b/MemConfig_Handler_2\1/g
