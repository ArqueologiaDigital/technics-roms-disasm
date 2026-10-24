
; ------------------------------------------------------------------
; 0xF2D000-0xF2D3FF -- 256 pointers, indexed by the SCREEN ID at RAM 0x207C
;   prom_a 0xF9940B: `ld L,(0x207C) / xor H,H / sla 0x02,HL /
;   ld XIY,0x00F2D000 / ld XHL,(XIY+HL)`, then `cp (XHL),0xFF` to test
;   the target for empty.  The index is a byte and nothing bounds it,
;   so the table is 256 entries; every one of them points into
;   0xF2D400-0xF2D5A1, which is where the table's own data begins.
; ------------------------------------------------------------------
ScreenFieldListPtrs:
	.long ScreenFieldList_F2D408	; [  0]  empty
	.long ScreenFieldList_SoundMode	; [  1]
	.long ScreenFieldList_C0mbinati0nM0de	; [  2]
	.long ScreenFieldList_F2D408	; [  3]  empty
	.long ScreenFieldList_Sequencer	; [  4]  empty
	.long ScreenFieldList_F2D40C	; [  5]  empty
	.long ScreenFieldList_RealtimeRecordScreen	; [  6]  empty
	.long ScreenFieldList_CombiEditMixer	; [  7]  empty
	.long ScreenFieldList_CycleRecordScreen	; [  8]  empty
	.long ScreenFieldList_F2D414	; [  9]  empty
	.long ScreenFieldList_F2D416	; [ 10]  empty
	.long ScreenFieldList_AfterT0uchSetting	; [ 11]  empty
	.long ScreenFieldList_MetronomeBalanceScreen	; [ 12]  empty
	.long ScreenFieldList_S0ngSelectName	; [ 13]  empty
	.long ScreenFieldList_StepRecord	; [ 14]  empty
	.long ScreenFieldList_StepRecordPartSelect	; [ 15]  empty
	.long ScreenFieldList_TrackAssign	; [ 16]  empty
	.long ScreenFieldList_TrackAssignPresets	; [ 17]  empty
	.long ScreenFieldList_SeqPlayScreen	; [ 18]  empty
	.long ScreenFieldList_SequencerMedley	; [ 19]  empty
	.long ScreenFieldList_CyclePlayScreen	; [ 20]  empty
	.long ScreenFieldList_ScreenCode15_Handler	; [ 21]  empty
	.long ScreenFieldList_F2D42E	; [ 22]  empty
	.long ScreenFieldList_F2D430	; [ 23]  empty
	.long ScreenFieldList_F2D432	; [ 24]  empty
	.long ScreenFieldList_F2D434	; [ 25]  empty
	.long ScreenFieldList_Edit	; [ 26]  empty
	.long ScreenFieldList_SongClear	; [ 27]  empty
	.long ScreenFieldList_TrackClear	; [ 28]  empty
	.long ScreenFieldList_Vel0cityChange	; [ 29]  empty
	.long ScreenFieldList_Quantize	; [ 30]  empty
	.long ScreenFieldList_TrackMerge	; [ 31]  empty
	.long ScreenFieldList_MeasureErase	; [ 32]  empty
	.long ScreenFieldList_MeasureC0py	; [ 33]  empty
	.long ScreenFieldList_MeasureInsert	; [ 34]  empty
	.long ScreenFieldList_MeasureDelete	; [ 35]  empty
	.long ScreenFieldList_ShowScreen_NoteEditPartSelect	; [ 36]  empty
	.long ScreenFieldList_EditScreen_EnterNoteEdit	; [ 37]  empty
	.long ScreenFieldList_F2D44E	; [ 38]  empty
	.long ScreenFieldList_ShowScreen_DrumEditPartSelect	; [ 39]  empty
	.long ScreenFieldList_EditScreen_EnterDrumEdit	; [ 40]  empty
	.long ScreenFieldList_CyclePlayEditScreen29	; [ 41]  empty
	.long ScreenFieldList_S0ngC0py	; [ 42]  empty
	.long ScreenFieldList_Transp0se	; [ 43]  empty
	.long ScreenFieldList_AdvanceDelay	; [ 44]  empty
	.long ScreenFieldList_N0teChange	; [ 45]  empty
	.long ScreenFieldList_PanelWrite	; [ 46]  empty
	.long ScreenFieldList_F2D460	; [ 47]  empty
	.long ScreenFieldList_F2D408	; [ 48]  empty
	.long ScreenFieldList_F2D408	; [ 49]  empty
	.long ScreenFieldList_F2D408	; [ 50]  empty
	.long ScreenFieldList_F2D408	; [ 51]  empty
	.long ScreenFieldList_CombiEditMenu	; [ 52]  empty
	.long ScreenFieldList_F2D464	; [ 53]  empty
	.long ScreenFieldList_CombinationNaming	; [ 54]  empty
	.long ScreenFieldList_F2D468	; [ 55]  empty
	.long ScreenFieldList_F2D46A	; [ 56]  empty
	.long ScreenFieldList_CombiEditDspEffect	; [ 57]  empty
	.long ScreenFieldList_CombiEditMixer2	; [ 58]  empty
	.long ScreenFieldList_F2D470	; [ 59]  empty
	.long ScreenFieldList_Screen_CombinationNaming_Enter	; [ 60]  empty
	.long ScreenFieldList_F2D408	; [ 61]  empty
	.long ScreenFieldList_F2D408	; [ 62]  empty
	.long ScreenFieldList_F2D408	; [ 63]  empty
	.long ScreenFieldList_DiskMenu	; [ 64]  empty
	.long ScreenFieldList_F2D476	; [ 65]  empty
	.long ScreenFieldList_F2D478	; [ 66]  empty
	.long ScreenFieldList_F2D47A	; [ 67]  empty
	.long ScreenFieldList_F2D47C	; [ 68]  empty
	.long ScreenFieldList_MidiFileDirectPlay	; [ 69]  empty
	.long ScreenFieldList_F2D480	; [ 70]  empty
	.long ScreenFieldList_DiskL0adFile	; [ 71]  empty
	.long ScreenFieldList_F2D484	; [ 72]  empty
	.long ScreenFieldList_MidiFileL0ad	; [ 73]  empty
	.long ScreenFieldList_F2D488	; [ 74]  empty
	.long ScreenFieldList_F2D48A	; [ 75]  empty
	.long ScreenFieldList_PageDispatch_DiskSaveFile	; [ 76]  empty
	.long ScreenFieldList_F2D48E	; [ 77]  empty
	.long ScreenFieldList_PageDispatch_MidiFileSave	; [ 78]  empty
	.long ScreenFieldList_F2D408	; [ 79]  empty
	.long ScreenFieldList_FloppyDiskFormatSelectType	; [ 80]  empty
	.long ScreenFieldList_FloppyDiskFormatAreYouSure	; [ 81]  empty
	.long ScreenFieldList_F2D496	; [ 82]  empty
	.long ScreenFieldList_PageDispatch_L0adSingleC0mbination	; [ 83]  empty
	.long ScreenFieldList_PageDispatch_L0adSingleS0und	; [ 84]  empty
	.long ScreenFieldList_F2D49C	; [ 85]  empty
	.long ScreenFieldList_F2D49E	; [ 86]  empty
	.long ScreenFieldList_F2D4A0	; [ 87]  empty
	.long ScreenFieldList_F2D4A2	; [ 88]  empty
	.long ScreenFieldList_F2D4A4	; [ 89]  empty
	.long ScreenFieldList_F2D4A6	; [ 90]  empty
	.long ScreenFieldList_F2D408	; [ 91]  empty
	.long ScreenFieldList_F2D408	; [ 92]  empty
	.long ScreenFieldList_Screen_SoundMute_Enter	; [ 93]
	.long ScreenFieldList_F2D408	; [ 94]  empty
	.long ScreenFieldList_F2D408	; [ 95]  empty
	.long ScreenFieldList_Screen_System_Enter	; [ 96]  empty
	.long ScreenFieldList_Screen_DataLoadFilter_Enter	; [ 97]
	.long ScreenFieldList_Screen_TuneScale_Enter	; [ 98]
	.long ScreenFieldList_F2D408	; [ 99]  empty
	.long ScreenFieldList_Screen_TouchSensitivityOrTest_Enter	; [100]
	.long ScreenFieldList_Screen_ControllerAssign_Enter	; [101]
	.long ScreenFieldList_Screen_DspEffect_Enter	; [102]  empty
	.long ScreenFieldList_Screen_DrumsMapNaming_Enter	; [103]
	.long ScreenFieldList_F2D408	; [104]  empty
	.long ScreenFieldList_F2D408	; [105]  empty
	.long ScreenFieldList_Screen_Initial_Enter	; [106]  empty
	.long ScreenFieldList_Screen_MainOutEqualizer_Enter	; [107]  empty
	.long ScreenFieldList_Screen_ReMapEdit_Enter	; [108]  empty
	.long ScreenFieldList_Screen_SoundCombinationManager_Enter	; [109]  empty
	.long ScreenFieldList_Screen_MemoryProtect_Enter	; [110]  empty
	.long ScreenFieldList_F2D50A	; [111]  empty
	.long ScreenFieldList_MidiMenu	; [112]  empty
	.long ScreenFieldList_F2D50E	; [113]  empty
	.long ScreenFieldList_F2D510	; [114]  empty
	.long ScreenFieldList_F2D512	; [115]  empty
	.long ScreenFieldList_F2D408	; [116]  empty
	.long ScreenFieldList_MidiRealtimeMessages	; [117]  empty
	.long ScreenFieldList_F2D516	; [118]  empty
	.long ScreenFieldList_F2D408	; [119]  empty
	.long ScreenFieldList_F2D518	; [120]  empty
	.long ScreenFieldList_SysexBulkDump	; [121]  empty
	.long ScreenFieldList_GeneralMidiMode	; [122]  empty
	.long ScreenFieldList_F2D51E	; [123]  empty
	.long ScreenFieldList_F2D520	; [124]  empty
	.long ScreenFieldList_MidiTotalMode	; [125]  empty
	.long ScreenFieldList_MidiInputOutputFilter	; [126]  empty
	.long ScreenFieldList_MidiOutProgramChange	; [127]  empty
	.long ScreenFieldList_F2D408	; [128]  empty
	.long ScreenFieldList_F2D408	; [129]  empty
	.long ScreenFieldList_F2D408	; [130]  empty
	.long ScreenFieldList_F2D408	; [131]  empty
	.long ScreenFieldList_F2D408	; [132]  empty
	.long ScreenFieldList_F2D408	; [133]  empty
	.long ScreenFieldList_F2D408	; [134]  empty
	.long ScreenFieldList_F2D408	; [135]  empty
	.long ScreenFieldList_F2D408	; [136]  empty
	.long ScreenFieldList_F2D408	; [137]  empty
	.long ScreenFieldList_F2D408	; [138]  empty
	.long ScreenFieldList_F2D408	; [139]  empty
	.long ScreenFieldList_F2D408	; [140]  empty
	.long ScreenFieldList_F2D408	; [141]  empty
	.long ScreenFieldList_F2D408	; [142]  empty
	.long ScreenFieldList_F2D408	; [143]  empty
	.long ScreenFieldList_F2D408	; [144]  empty
	.long ScreenFieldList_F2D408	; [145]  empty
	.long ScreenFieldList_F2D408	; [146]  empty
	.long ScreenFieldList_F2D408	; [147]  empty
	.long ScreenFieldList_F2D408	; [148]  empty
	.long ScreenFieldList_F2D408	; [149]  empty
	.long ScreenFieldList_F2D408	; [150]  empty
	.long ScreenFieldList_F2D408	; [151]  empty
	.long ScreenFieldList_F2D408	; [152]  empty
	.long ScreenFieldList_F2D408	; [153]  empty
	.long ScreenFieldList_F2D408	; [154]  empty
	.long ScreenFieldList_F2D408	; [155]  empty
	.long ScreenFieldList_F2D408	; [156]  empty
	.long ScreenFieldList_F2D408	; [157]  empty
	.long ScreenFieldList_F2D408	; [158]  empty
	.long ScreenFieldList_F2D408	; [159]  empty
	.long ScreenFieldList_SoundGroupMenu	; [160]
	.long ScreenFieldList_GroupSoundDisplayHold	; [161]
	.long ScreenFieldList_CombinationGroupMenu	; [162]  empty
	.long ScreenFieldList_F2D408	; [163]  empty
	.long ScreenFieldList_F2D408	; [164]  empty
	.long ScreenFieldList_CombinationGroupMenu2	; [165]
	.long ScreenFieldList_GroupCombiDisplayHold	; [166]
	.long ScreenFieldList_F2D582	; [167]  empty
	.long ScreenFieldList_F2D408	; [168]  empty
	.long ScreenFieldList_F2D408	; [169]  empty
	.long ScreenFieldList_F2D408	; [170]  empty
	.long ScreenFieldList_F2D408	; [171]  empty
	.long ScreenFieldList_F2D408	; [172]  empty
	.long ScreenFieldList_F2D408	; [173]  empty
	.long ScreenFieldList_F2D408	; [174]  empty
	.long ScreenFieldList_F2D408	; [175]  empty
	.long ScreenFieldList_F2D584	; [176]
	.long ScreenFieldList_F2D584	; [177]
	.long ScreenFieldList_F2D584	; [178]
	.long ScreenFieldList_F2D584	; [179]
	.long ScreenFieldList_F2D584	; [180]
	.long ScreenFieldList_F2D584	; [181]
	.long ScreenFieldList_Effect2OutputConflict	; [182]  empty
	.long ScreenFieldList_CombiEditMixer3	; [183]  empty
	.long ScreenFieldList_F2D408	; [184]  empty
	.long ScreenFieldList_F2D408	; [185]  empty
	.long ScreenFieldList_F2D408	; [186]  empty
	.long ScreenFieldList_F2D408	; [187]  empty
	.long ScreenFieldList_F2D408	; [188]  empty
	.long ScreenFieldList_F2D408	; [189]  empty
	.long ScreenFieldList_F2D408	; [190]  empty
	.long ScreenFieldList_F2D408	; [191]  empty
	.long ScreenFieldList_F2D408	; [192]  empty
	.long ScreenFieldList_F2D408	; [193]  empty
	.long ScreenFieldList_F2D408	; [194]  empty
	.long ScreenFieldList_F2D408	; [195]  empty
	.long ScreenFieldList_F2D408	; [196]  empty
	.long ScreenFieldList_F2D408	; [197]  empty
	.long ScreenFieldList_F2D408	; [198]  empty
	.long ScreenFieldList_F2D408	; [199]  empty
	.long ScreenFieldList_F2D408	; [200]  empty
	.long ScreenFieldList_F2D408	; [201]  empty
	.long ScreenFieldList_F2D408	; [202]  empty
	.long ScreenFieldList_F2D408	; [203]  empty
	.long ScreenFieldList_F2D408	; [204]  empty
	.long ScreenFieldList_SoundEditControllerPage1	; [205]
	.long ScreenFieldList_F2D408	; [206]  empty
	.long ScreenFieldList_F2D408	; [207]  empty
	.long ScreenFieldList_F2D408	; [208]  empty
	.long ScreenFieldList_F2D408	; [209]  empty
	.long ScreenFieldList_F2D408	; [210]  empty
	.long ScreenFieldList_F2D408	; [211]  empty
	.long ScreenFieldList_F2D408	; [212]  empty
	.long ScreenFieldList_F2D408	; [213]  empty
	.long ScreenFieldList_F2D408	; [214]  empty
	.long ScreenFieldList_F2D408	; [215]  empty
	.long ScreenFieldList_GateArrayCheck	; [216]  empty
	.long ScreenFieldList_PanelCpuCheck	; [217]  empty
	.long ScreenFieldList_SineWaveCheckMode	; [218]
	.long ScreenFieldList_PanelSwLedCheck	; [219]  empty
	.long ScreenFieldList_F2D59C	; [220]  empty
	.long ScreenFieldList_DebugMonitor	; [221]  empty
	.long ScreenFieldList_F2D5A0	; [222]  empty
	.long ScreenFieldList_F2D408	; [223]  empty
	.long ScreenFieldList_F2D408	; [224]  empty
	.long ScreenFieldList_F2D408	; [225]  empty
	.long ScreenFieldList_F2D408	; [226]  empty
	.long ScreenFieldList_F2D408	; [227]  empty
	.long ScreenFieldList_F2D408	; [228]  empty
	.long ScreenFieldList_F2D408	; [229]  empty
	.long ScreenFieldList_F2D408	; [230]  empty
	.long ScreenFieldList_F2D408	; [231]  empty
	.long ScreenFieldList_F2D408	; [232]  empty
	.long ScreenFieldList_F2D408	; [233]  empty
	.long ScreenFieldList_F2D408	; [234]  empty
	.long ScreenFieldList_F2D408	; [235]  empty
	.long ScreenFieldList_F2D408	; [236]  empty
	.long ScreenFieldList_F2D408	; [237]  empty
	.long ScreenFieldList_F2D408	; [238]  empty
	.long ScreenFieldList_F2D408	; [239]  empty
	.long ScreenFieldList_F2D408	; [240]  empty
	.long ScreenFieldList_F2D408	; [241]  empty
	.long ScreenFieldList_F2D408	; [242]  empty
	.long ScreenFieldList_F2D408	; [243]  empty
	.long ScreenFieldList_F2D408	; [244]  empty
	.long ScreenFieldList_F2D408	; [245]  empty
	.long ScreenFieldList_F2D408	; [246]  empty
	.long ScreenFieldList_F2D408	; [247]  empty
	.long ScreenFieldList_F2D408	; [248]  empty
	.long ScreenFieldList_F2D408	; [249]  empty
	.long ScreenFieldList_F2D408	; [250]  empty
	.long ScreenFieldList_F2D408	; [251]  empty
	.long ScreenFieldList_F2D408	; [252]  empty
	.long ScreenFieldList_F2D408	; [253]  empty
	.long ScreenFieldList_F2D408	; [254]  empty
	.long ScreenFieldList_F2D408	; [255]  empty

; ------------------------------------------------------------------
; 0xF2D400-0xF2D5A1 -- the lists ScreenFieldListPtrs points at
;   Each is 16-bit values terminated by 0xFFFF; prom_a 0xF99437
;   compares each against a word taken from RAM 0x2C00.  The 127
;   distinct targets' lists TILE this range exactly, with no hole and
;   no byte left over -- which is what fixes the range's end.
; ------------------------------------------------------------------
ScreenFieldList_SoundMode:
; ; the field list of screen id 0x01 only (ScreenFieldListPtrs[0x01]; screen object T_InstallPainter_SoundMode_Entry)
	.short 0x0000
	.short 0xFFFF	; end of list
ScreenFieldList_C0mbinati0nM0de:
; ; the field list of screen id 0x02 only (ScreenFieldListPtrs[0x02]; screen object T_InstallPainter_C0mbinati0nM0de_Entry)
	.short 0x0198
	.short 0xFFFF	; end of list
ScreenFieldList_F2D408:
	.short 0xFFFF	; end of list
ScreenFieldList_Sequencer:
; ; the field list of screen id 0x04 only (ScreenFieldListPtrs[0x04]; screen object T_Paint_Sequencer)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D40C:
	.short 0xFFFF	; end of list
ScreenFieldList_RealtimeRecordScreen:
; ; the field list of screen id 0x06 only (ScreenFieldListPtrs[0x06]; screen object T_ScreenEnter_RealtimeRecordScreen_Fwd)
	.short 0xFFFF	; end of list
ScreenFieldList_CombiEditMixer:
; ; the field list of screen id 0x07 only (ScreenFieldListPtrs[0x07]; screen object T_ScreenEnterBody_CombiEditMixer)
	.short 0xFFFF	; end of list
ScreenFieldList_CycleRecordScreen:
; ; the field list of screen id 0x08 only (ScreenFieldListPtrs[0x08]; screen object T_ScreenEnter_CycleRecordScreen_Fwd)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D414:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D416:
	.short 0xFFFF	; end of list
ScreenFieldList_AfterT0uchSetting:
; ; the field list of screen id 0x0B only (ScreenFieldListPtrs[0x0B]; screen object T_ScreenEnter_AfterT0uchSetting)
	.short 0xFFFF	; end of list
ScreenFieldList_MetronomeBalanceScreen:
; ; the field list of screen id 0x0C only (ScreenFieldListPtrs[0x0C]; screen object T_ScreenEnter_MetronomeBalanceScreen_Fwd)
	.short 0xFFFF	; end of list
ScreenFieldList_S0ngSelectName:
; ; the field list of screen id 0x0D only (ScreenFieldListPtrs[0x0D]; screen object T_ScreenEnter_S0ngSelectName)
	.short 0xFFFF	; end of list
ScreenFieldList_StepRecord:
; ; the field list of screen id 0x0E only (ScreenFieldListPtrs[0x0E]; screen object T_ScreenEnter_StepRecord)
	.short 0xFFFF	; end of list
ScreenFieldList_StepRecordPartSelect:
; ; the field list of screen id 0x0F only (ScreenFieldListPtrs[0x0F]; screen object T_ScreenEnter_StepRecordPartSelect)
	.short 0xFFFF	; end of list
ScreenFieldList_TrackAssign:
; ; the field list of screen id 0x10 only (ScreenFieldListPtrs[0x10]; screen object T_ScreenEnter_TrackAssign)
	.short 0xFFFF	; end of list
ScreenFieldList_TrackAssignPresets:
; ; the field list of screen id 0x11 only (ScreenFieldListPtrs[0x11]; screen object T_ScreenEnter_TrackAssignPresets)
	.short 0xFFFF	; end of list
ScreenFieldList_SeqPlayScreen:
; ; the field list of screen id 0x12 only (ScreenFieldListPtrs[0x12]; screen object T_ScreenEnter_SeqPlayScreen_Fwd)
	.short 0xFFFF	; end of list
ScreenFieldList_SequencerMedley:
; ; the field list of screen id 0x13 only (ScreenFieldListPtrs[0x13]; screen object T_ScreenEnter_SequencerMedley)
	.short 0xFFFF	; end of list
ScreenFieldList_CyclePlayScreen:
; ; the field list of screen id 0x14 only (ScreenFieldListPtrs[0x14]; screen object T_ScreenEnter_CyclePlayScreen_Fwd)
	.short 0xFFFF	; end of list
ScreenFieldList_ScreenCode15_Handler:
; ; the field list of screen id 0x15 only (ScreenFieldListPtrs[0x15]; screen object T_ScreenCode15_Handler)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D42E:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D430:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D432:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D434:
	.short 0xFFFF	; end of list
ScreenFieldList_Edit:
; ; the field list of screen id 0x1A only (ScreenFieldListPtrs[0x1A]; screen object T_ScreenEnter_Edit)
	.short 0xFFFF	; end of list
ScreenFieldList_SongClear:
; ; the field list of screen id 0x1B only (ScreenFieldListPtrs[0x1B]; screen object T_ScreenEnter_SongClear)
	.short 0xFFFF	; end of list
ScreenFieldList_TrackClear:
; ; the field list of screen id 0x1C only (ScreenFieldListPtrs[0x1C]; screen object T_ScreenEnter_TrackClear)
	.short 0xFFFF	; end of list
ScreenFieldList_Vel0cityChange:
; ; the field list of screen id 0x1D only (ScreenFieldListPtrs[0x1D]; screen object T_ScreenEnter_Vel0cityChange)
	.short 0xFFFF	; end of list
ScreenFieldList_Quantize:
; ; the field list of screen id 0x1E only (ScreenFieldListPtrs[0x1E]; screen object T_ScreenEnter_Quantize)
	.short 0xFFFF	; end of list
ScreenFieldList_TrackMerge:
; ; the field list of screen id 0x1F only (ScreenFieldListPtrs[0x1F]; screen object T_ScreenEnter_TrackMerge)
	.short 0xFFFF	; end of list
ScreenFieldList_MeasureErase:
; ; the field list of screen id 0x20 only (ScreenFieldListPtrs[0x20]; screen object T_ScreenEnter_MeasureErase)
	.short 0xFFFF	; end of list
ScreenFieldList_MeasureC0py:
; ; the field list of screen id 0x21 only (ScreenFieldListPtrs[0x21]; screen object T_ScreenEnter_MeasureC0py)
	.short 0xFFFF	; end of list
ScreenFieldList_MeasureInsert:
; ; the field list of screen id 0x22 only (ScreenFieldListPtrs[0x22]; screen object T_ScreenEnter_MeasureInsert)
	.short 0xFFFF	; end of list
ScreenFieldList_MeasureDelete:
; ; the field list of screen id 0x23 only (ScreenFieldListPtrs[0x23]; screen object T_ScreenEnter_MeasureDelete)
	.short 0xFFFF	; end of list
ScreenFieldList_ShowScreen_NoteEditPartSelect:
; ; the field list of screen id 0x24 only (ScreenFieldListPtrs[0x24]; screen object T_ShowScreen_NoteEditPartSelect)
	.short 0xFFFF	; end of list
ScreenFieldList_EditScreen_EnterNoteEdit:
; ; the field list of screen id 0x25 only (ScreenFieldListPtrs[0x25]; screen object T_EditScreen_EnterNoteEdit)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D44E:
	.short 0xFFFF	; end of list
ScreenFieldList_ShowScreen_DrumEditPartSelect:
; ; the field list of screen id 0x27 only (ScreenFieldListPtrs[0x27]; screen object T_ShowScreen_DrumEditPartSelect)
	.short 0xFFFF	; end of list
ScreenFieldList_EditScreen_EnterDrumEdit:
; ; the field list of screen id 0x28 only (ScreenFieldListPtrs[0x28]; screen object T_EditScreen_EnterDrumEdit)
	.short 0xFFFF	; end of list
ScreenFieldList_CyclePlayEditScreen29:
; ; the field list of screen id 0x29 only (ScreenFieldListPtrs[0x29]; screen object T_ScreenEnter_CyclePlayEditScreen29_Fwd)
	.short 0xFFFF	; end of list
ScreenFieldList_S0ngC0py:
; ; the field list of screen id 0x2A only (ScreenFieldListPtrs[0x2A]; screen object T_ScreenEnter_S0ngC0py)
	.short 0xFFFF	; end of list
ScreenFieldList_Transp0se:
; ; the field list of screen id 0x2B only (ScreenFieldListPtrs[0x2B]; screen object T_ScreenEnter_Transp0se)
	.short 0xFFFF	; end of list
ScreenFieldList_AdvanceDelay:
; ; the field list of screen id 0x2C only (ScreenFieldListPtrs[0x2C]; screen object T_ScreenEnter_AdvanceDelay)
	.short 0xFFFF	; end of list
ScreenFieldList_N0teChange:
; ; the field list of screen id 0x2D only (ScreenFieldListPtrs[0x2D]; screen object T_ScreenEnter_N0teChange)
	.short 0xFFFF	; end of list
ScreenFieldList_PanelWrite:
; ; the field list of screen id 0x2E only (ScreenFieldListPtrs[0x2E]; screen object T_ScreenEnter_PanelWrite)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D460:
	.short 0xFFFF	; end of list
ScreenFieldList_CombiEditMenu:
; ; the field list of screen id 0x34 only (ScreenFieldListPtrs[0x34]; screen object T_ScreenEnter_CombiEditMenu)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D464:
	.short 0xFFFF	; end of list
ScreenFieldList_CombinationNaming:
; ; the field list of screen id 0x36 only (ScreenFieldListPtrs[0x36]; screen object T_ScreenEnter_CombinationNaming)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D468:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D46A:
	.short 0xFFFF	; end of list
ScreenFieldList_CombiEditDspEffect:
; ; the field list of screen id 0x39 only (ScreenFieldListPtrs[0x39]; screen object T_ScreenEnter_CombiEditDspEffect)
	.short 0xFFFF	; end of list
ScreenFieldList_CombiEditMixer2:
; ; the field list of screen id 0x3A only (ScreenFieldListPtrs[0x3A]; screen object T_ScreenEnter_CombiEditMixer)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D470:
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_CombinationNaming_Enter:
; ; the field list of screen id 0x3C only (ScreenFieldListPtrs[0x3C]; screen object T_Screen_CombinationNaming_Enter)
	.short 0xFFFF	; end of list
ScreenFieldList_DiskMenu:
; ; the field list of screen id 0x40 only (ScreenFieldListPtrs[0x40]; screen object T_Paint_DiskMenu)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D476:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D478:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D47A:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D47C:
	.short 0xFFFF	; end of list
ScreenFieldList_MidiFileDirectPlay:
; ; the field list of screen id 0x45 only (ScreenFieldListPtrs[0x45]; screen object T_Paint_MidiFileDirectPlay)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D480:
	.short 0xFFFF	; end of list
ScreenFieldList_DiskL0adFile:
; ; the field list of screen id 0x47 only (ScreenFieldListPtrs[0x47]; screen object T_Paint_DiskL0adFile)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D484:
	.short 0xFFFF	; end of list
ScreenFieldList_MidiFileL0ad:
; ; the field list of screen id 0x49 only (ScreenFieldListPtrs[0x49]; screen object T_Paint_MidiFileL0ad)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D488:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D48A:
	.short 0xFFFF	; end of list
ScreenFieldList_PageDispatch_DiskSaveFile:
; ; the field list of screen id 0x4C only (ScreenFieldListPtrs[0x4C]; screen object T_PageDispatch_DiskSaveFile)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D48E:
	.short 0xFFFF	; end of list
ScreenFieldList_PageDispatch_MidiFileSave:
; ; the field list of screen id 0x4E only (ScreenFieldListPtrs[0x4E]; screen object T_PageDispatch_MidiFileSave)
	.short 0xFFFF	; end of list
ScreenFieldList_FloppyDiskFormatSelectType:
; ; the field list of screen id 0x50 only (ScreenFieldListPtrs[0x50]; screen object T_Paint_FloppyDiskFormatSelectType)
	.short 0xFFFF	; end of list
ScreenFieldList_FloppyDiskFormatAreYouSure:
; ; the field list of screen id 0x51 only (ScreenFieldListPtrs[0x51]; screen object T_Paint_FloppyDiskFormatAreYouSure)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D496:
	.short 0xFFFF	; end of list
ScreenFieldList_PageDispatch_L0adSingleC0mbination:
; ; the field list of screen id 0x53 only (ScreenFieldListPtrs[0x53]; screen object T_PageDispatch_L0adSingleC0mbination)
	.short 0xFFFF	; end of list
ScreenFieldList_PageDispatch_L0adSingleS0und:
; ; the field list of screen id 0x54 only (ScreenFieldListPtrs[0x54]; screen object T_PageDispatch_L0adSingleS0und)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D49C:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D49E:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D4A0:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D4A2:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D4A4:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D4A6:
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_SoundMute_Enter:
; ; the field list of screen id 0x5D only (ScreenFieldListPtrs[0x5D]; screen object T_Screen_SoundMute_Enter)
	.short 0x0998
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_System_Enter:
; ; the field list of screen id 0x60 only (ScreenFieldListPtrs[0x60]; screen object T_Screen_System_Enter)
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_DataLoadFilter_Enter:
; ; the field list of screen id 0x61 only (ScreenFieldListPtrs[0x61]; screen object T_Screen_DataLoadFilter_Enter)
	.short 0x027A
	.short 0x027A
	.short 0x0598
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_TuneScale_Enter:
; ; the field list of screen id 0x62 only (ScreenFieldListPtrs[0x62]; screen object T_Screen_TuneScale_Enter)
	.short 0x0091
	.short 0x0079
	.short 0x0092
	.short 0x0192
	.short 0x0192
	.short 0x0292
	.short 0x0392
	.short 0x0492
	.short 0x0592
	.short 0x0692
	.short 0x0792
	.short 0x0892
	.short 0x0992
	.short 0x0A92
	.short 0x0B92
	.short 0x0C92
	.short 0x0D92
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_TouchSensitivityOrTest_Enter:
; ; the field list of screen id 0x64 only (ScreenFieldListPtrs[0x64]; screen object T_Screen_TouchSensitivityOrTest_Enter)
	.short 0x0093
	.short 0x0293
	.short 0x0593
	.short 0x0693
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_ControllerAssign_Enter:
; ; the field list of screen id 0x65 only (ScreenFieldListPtrs[0x65]; screen object T_Screen_ControllerAssign_Enter)
	.short 0x0099
	.short 0x0299
	.short 0x0499
	.short 0x0599
	.short 0x1199
	.short 0x1299
	.short 0x1599
	.short 0x1699
	.short 0x1799
	.short 0x1899
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_DspEffect_Enter:
; ; the field list of screen id 0x66 only (ScreenFieldListPtrs[0x66]; screen object T_Screen_DspEffect_Enter)
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_DrumsMapNaming_Enter:
; ; the field list of screen id 0x67 only (ScreenFieldListPtrs[0x67]; screen object T_Screen_DrumsMapNaming_Enter)
	.short 0x0491
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_Initial_Enter:
; ; the field list of screen id 0x6A only (ScreenFieldListPtrs[0x6A]; screen object T_Screen_Initial_Enter)
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_MainOutEqualizer_Enter:
; ; the field list of screen id 0x6B only (ScreenFieldListPtrs[0x6B]; screen object T_Screen_MainOutEqualizer_Enter)
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_ReMapEdit_Enter:
; ; the field list of screen id 0x6C only (ScreenFieldListPtrs[0x6C]; screen object T_Screen_ReMapEdit_Enter)
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_SoundCombinationManager_Enter:
; ; the field list of screen id 0x6D only (ScreenFieldListPtrs[0x6D]; screen object T_Screen_SoundCombinationManager_Enter)
	.short 0xFFFF	; end of list
ScreenFieldList_Screen_MemoryProtect_Enter:
; ; the field list of screen id 0x6E only (ScreenFieldListPtrs[0x6E]; screen object T_Screen_MemoryProtect_Enter)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D50A:
	.short 0xFFFF	; end of list
ScreenFieldList_MidiMenu:
; ; the field list of screen id 0x70 only (ScreenFieldListPtrs[0x70]; screen object T_Paint_MidiMenu)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D50E:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D510:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D512:
	.short 0xFFFF	; end of list
ScreenFieldList_MidiRealtimeMessages:
; ; the field list of screen id 0x75 only (ScreenFieldListPtrs[0x75]; screen object T_Paint_MidiRealtimeMessages)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D516:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D518:
	.short 0xFFFF	; end of list
ScreenFieldList_SysexBulkDump:
; ; the field list of screen id 0x79 only (ScreenFieldListPtrs[0x79]; screen object T_Paint_SysexBulkDump_Entry)
	.short 0xFFFF	; end of list
ScreenFieldList_GeneralMidiMode:
; ; the field list of screen id 0x7A only (ScreenFieldListPtrs[0x7A]; screen object T_Paint_GeneralMidiMode_Entry)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D51E:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D520:
	.short 0xFFFF	; end of list
ScreenFieldList_MidiTotalMode:
; ; the field list of screen id 0x7D only (ScreenFieldListPtrs[0x7D]; screen object T_Paint_MidiTotalMode)
	.short 0xFFFF	; end of list
ScreenFieldList_MidiInputOutputFilter:
; ; the field list of screen id 0x7E only (ScreenFieldListPtrs[0x7E]; screen object T_Paint_MidiInputOutputFilter)
	.short 0xFFFF	; end of list
ScreenFieldList_MidiOutProgramChange:
; ; the field list of screen id 0x7F only (ScreenFieldListPtrs[0x7F]; screen object T_Paint_MidiOutProgramChange)
	.short 0xFFFF	; end of list
ScreenFieldList_SoundGroupMenu:
; ; the field list of screen id 0xA0 only (ScreenFieldListPtrs[0xA0]; screen object T_InstallPainter_SoundGroupMenu_Entry)
	.short 0x08A8
	.short 0xFFFF	; end of list
ScreenFieldList_GroupSoundDisplayHold:
; ; the field list of screen id 0xA1 only (ScreenFieldListPtrs[0xA1]; screen object T_InstallPainter_GroupSoundDisplayHold_Entry)
	.short 0x08A8
	.short 0x0000
	.short 0x0001
	.short 0x0002
	.short 0x0003
	.short 0x0004
	.short 0x0005
	.short 0x0006
	.short 0x0007
	.short 0x0008
	.short 0x0009
	.short 0x000A
	.short 0x000B
	.short 0x000C
	.short 0x000D
	.short 0x000E
	.short 0x000F
	.short 0x0010
	.short 0x0011
	.short 0x0012
	.short 0x0013
	.short 0x0014
	.short 0x0015
	.short 0x0016
	.short 0x0017
	.short 0x0018
	.short 0x0019
	.short 0x001A
	.short 0x001B
	.short 0x001C
	.short 0x001D
	.short 0x001E
	.short 0x001F
	.short 0xFFFF	; end of list
ScreenFieldList_SoundEditControllerPage1:
; ; the field list of screen id 0xCD only (ScreenFieldListPtrs[0xCD]; screen object T_ScreenEnter_SoundEditControllerPage1)
	.short 0x1920
	.short 0x1A20
	.short 0xFFFF	; end of list
ScreenFieldList_CombinationGroupMenu:
; ; the field list of screen id 0xA2 only (ScreenFieldListPtrs[0xA2]; screen object T_InstallPainter_CombinationGroupMenu_Entry)
	.short 0xFFFF	; end of list
ScreenFieldList_CombinationGroupMenu2:
; ; the field list of screen id 0xA5 only (ScreenFieldListPtrs[0xA5]; screen object T_InstallPainter_CombinationGroupMenu_Entry_5)
	.short 0x08A8
	.short 0xFFFF	; end of list
ScreenFieldList_GroupCombiDisplayHold:
; ; the field list of screen id 0xA6 only (ScreenFieldListPtrs[0xA6]; screen object T_InstallPainter_GroupCombiDisplayHold_Entry)
	.short 0x08A8
	.short 0x0198
	.short 0xFFFF	; end of list
ScreenFieldList_F2D582:
	.short 0xFFFF	; end of list
ScreenFieldList_F2D584:
	.short 0x1090
	.short 0xFFFF	; end of list
ScreenFieldList_Effect2OutputConflict:
; ; the field list of screen id 0xB6 only (ScreenFieldListPtrs[0xB6]; screen object T_ScreenEnter_Effect2OutputConflict)
	.short 0xFFFF	; end of list
ScreenFieldList_CombiEditMixer3:
; ; the field list of screen id 0xB7 only (ScreenFieldListPtrs[0xB7]; screen object T_ScreenEnterBody_CombiEditMixer)
	.short 0xFFFF	; end of list
ScreenFieldList_GateArrayCheck:
; ; the field list of screen id 0xD8 only (ScreenFieldListPtrs[0xD8]; screen object T_Paint_GateArrayCheck)
	.short 0xFFFF	; end of list
ScreenFieldList_PanelCpuCheck:
; ; the field list of screen id 0xD9 only (ScreenFieldListPtrs[0xD9]; screen object T_Paint_PanelCpuCheck)
	.short 0xFFFF	; end of list
ScreenFieldList_SineWaveCheckMode:
; ; the field list of screen id 0xDA only (ScreenFieldListPtrs[0xDA]; screen object T_Paint_SineWaveCheckMode)
	.short 0x08A8
	.short 0x0500
	.short 0x0600
	.short 0x0700
	.short 0xFFFF	; end of list
ScreenFieldList_PanelSwLedCheck:
; ; the field list of screen id 0xDB only (ScreenFieldListPtrs[0xDB]; screen object T_Paint_PanelSwLedCheck)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D59C:
	.short 0xFFFF	; end of list
ScreenFieldList_DebugMonitor:
; ; the field list of screen id 0xDD only (ScreenFieldListPtrs[0xDD]; screen object T_ScreenEnter_DebugMonitor)
	.short 0xFFFF	; end of list
ScreenFieldList_F2D5A0:
	.short 0xFFFF	; end of list

; 0xF2D5A2-0xF2D7FF -- 606 bytes of 0x0E `ret` padding
	.fill 606, 1, 0x0E
