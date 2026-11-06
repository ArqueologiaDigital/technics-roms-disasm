; Floppy Disk Test Dialog Data
; Factory diagnostics (codename "HAMA"): NAKA widget descriptors for
; FDD test screens including diagnostic lists, console areas, and result display

FDTest_DiagList_Total:
	NAKA_REC_PsNumEditBox super=IDX_FDTest_ScreenView, sub=NAKA_INDEX_NONE, next=IDX_FDTest_DiagList_NG, prev=NAKA_INDEX_NONE, flag=VF_Const, x=8, y=35, w=149, h=32, color=CL_Silver, border=BD_3D_UP2, index=0xffff, caption=FDTest_String_Total, font=idCHARA1, fontcolor=CL_Black, align=AL_LeftJustify, length=4, editsw=ES_None, dial=0x1, selected=0x3dcbe, figures=4
FDTest_String_Total:	aligned_string " TOTAL :"
FDTest_DiagList_NG:
	NAKA_REC_PsNumEditBox super=IDX_FDTest_ScreenView, sub=NAKA_INDEX_NONE, next=IDX_FDTest_DiagList_OK, prev=IDX_FDTest_DiagList_Total, flag=VF_Const, x=8, y=161, w=149, h=32, color=CL_Silver, border=BD_3D_UP2, index=0xffff, caption=FDTest_String_DiagList_NG, font=idCHARA1, fontcolor=CL_Red, align=AL_LeftJustify, length=3, editsw=ES_None, dial=0x1, selected=0x3dcc0, figures=3
FDTest_String_DiagList_NG:	aligned_string "    NG :"
FDTest_DiagList_OK:
	NAKA_REC_PsNumEditBox super=IDX_FDTest_ScreenView, sub=NAKA_INDEX_NONE, next=IDX_FDTest_Separator1, prev=IDX_FDTest_DiagList_NG, flag=VF_Const, x=8, y=119, w=149, h=32, color=CL_Silver, border=BD_3D_UP2, index=0xffff, caption=FDTest_String_DiagList_OK, font=idCHARA1, fontcolor=CL_Green, align=AL_LeftJustify, length=3, editsw=ES_None, dial=0x1, selected=0x3dcc2, figures=3
FDTest_String_DiagList_OK:	aligned_string "    OK :"
FDTest_Separator1:
	NAKA_REC_IvMainEditSw super=IDX_FDTest_ScreenView, sub=NAKA_INDEX_NONE, next=IDX_FDTest_Panel_Param, prev=IDX_FDTest_DiagList_OK, flag=VF_Const | VF_InvisibleBox, x=0, y=0, w=32, h=32, func=NAKA_MAINFUNC_TestTitleFunc
FDTest_Panel_Param:
	NAKA_REC_PsEditSwBox super=IDX_FDTest_ScreenView, sub=IDX_FDTest_Label_Tilde80, next=IDX_FDTest_Panel_SubElements, prev=IDX_FDTest_Separator1, flag=VF_Const, x=84, y=216, w=32, h=23, color=CL_Silver, border=BD_EditSwitch, index=0xffff, font=idCHARA1, fontcolor=CL_Black, align=AL_Center, editsw=ES_Bottom3
FDTest_Label_Tilde80:
	NAKA_REC_Label super=IDX_FDTest_Panel_Param, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Const, x=94, y=221, w=12, h=19, str=FDTest_String_Tilde80, font=idCHARA2, fontcolor=CL_Black
FDTest_String_Tilde80:	.asciz "~80"
FDTest_Panel_SubElements:
	NAKA_REC_PsEditSwBox super=IDX_FDTest_ScreenView, sub=IDX_FDTest_Group_OnOff, next=IDX_FDTest_Label_RunningTest, prev=IDX_FDTest_Panel_Param, flag=VF_Const, x=44, y=216, w=32, h=23, color=CL_Silver, border=BD_EditSwitch, index=0xffff, font=idCHARA1, fontcolor=CL_Black, align=AL_Center, editsw=ES_Bottom2
FDTest_Group_OnOff:
	NAKA_REC_Box super=IDX_FDTest_Panel_SubElements, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Const, x=54, y=222, w=11, h=11, color=CL_Black, border=BD_None
FDTest_Label_RunningTest:
	NAKA_REC_Label super=IDX_FDTest_ScreenView, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=IDX_FDTest_Panel_SubElements, flag=VF_Const, x=30, y=197, w=100, h=19, str=FDTest_String_RunningTest, font=idCHARA1, fontcolor=CL_White
FDTest_String_RunningTest:	aligned_string "RUNNING TEST"
FDTest_Container_DebugHDAE1:
				; pointer -- 3F 01 EF 00 only equals Naka_PresentationRootState's address
	; two u16 fields, 320-1 and 240-1 (lane ext: a coordinate pair); not a
	NAKA_REC_TtlScreen super=NAKA_INDEX_NONE, sub=IDX_FDTest_MenuItem_Load1, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3dcc4, title=FDTest_Desc_DebugHDAE1, icon=idICON_i129
FDTest_Desc_DebugHDAE1:	aligned_string "DEBUG SCREEN for HD-AE"
FDTest_MenuItem_Load1:
	NAKA_REC_VwEditSwBox super=IDX_FDTest_Container_DebugHDAE1, sub=NAKA_INDEX_NONE, next=IDX_FDTest_MenuItem_Go1, prev=NAKA_INDEX_NONE, flag=VF_Const, x=8, y=126, w=39, h=18, color=CL_Silver, border=BD_3D_UP2, index=1, font=idCHARA1, fontcolor=CL_Black, align=AL_Center, editsw=ES_Left3, style=SS_Special, str=FDTest_String_Load1
FDTest_String_Load1:	aligned_string "LOAD"
FDTest_MenuItem_Go1:
	NAKA_REC_VwEditSwBox super=IDX_FDTest_Container_DebugHDAE1, sub=NAKA_INDEX_NONE, next=IDX_FDTest_NavWidget1, prev=IDX_FDTest_MenuItem_Load1, flag=VF_Const, x=8, y=168, w=31, h=18, color=CL_Silver, border=BD_3D_UP2, index=2, font=idCHARA1, fontcolor=CL_Black, align=AL_Center, editsw=ES_Left4, style=SS_Special, str=FDTest_String_Go1
FDTest_String_Go1:	aligned_string "GO"
FDTest_NavWidget1:
	NAKA_REC_IvCatchEvent super=IDX_FDTest_Container_DebugHDAE1, sub=IDX_FDTest_Divider1, next=IDX_FDTest_ConsoleArea1, prev=IDX_FDTest_MenuItem_Go1, flag=VF_Const | VF_InvisibleBox, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_hamadeb
FDTest_Divider1:
	NAKA_REC_IvExitScreen super=IDX_FDTest_NavWidget1, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Const | VF_InvisibleBox, x=8, y=8, w=32, h=32, screen=0xfc0000 + IDX_FDTest_ScreenView
FDTest_ConsoleArea1:
	NAKA_REC_AcScreenMenu super=IDX_FDTest_Container_DebugHDAE1, sub=IDX_FDTest_Label_MemoryDump, next=IDX_FDTest_StatusBar1, prev=IDX_FDTest_NavWidget1, flag=VF_Const, x=8, y=35, w=149, h=32, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Left1, selected=0x3dcc8, str=FDTest_String_Console1, screen=0xfc0000 + IDX_FDTest_Container_DebugHDAE2, icon=idICON_None
FDTest_String_Console1:	aligned_string "CONSOLE"
FDTest_Label_MemoryDump:
	NAKA_REC_Label super=IDX_FDTest_ConsoleArea1, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Const, x=134, y=42, w=92, h=19, str=FDTest_String_MemoryDump, font=idCHARA1, fontcolor=CL_White
FDTest_String_MemoryDump:	aligned_string "MEMORY DUMP"
FDTest_StatusBar1:
	NAKA_REC_DbMemoryDump super=IDX_FDTest_Container_DebugHDAE1, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=IDX_FDTest_ConsoleArea1, flag=VF_Const, x=57, y=61, w=263, h=179, adr=0x3dcca
FDTest_Container_DebugHDAE2:
	NAKA_REC_TtlScreen super=NAKA_INDEX_NONE, sub=IDX_FDTest_MenuItem_Load2, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Fixed | VF_Const, x=0, y=0, w=320, h=240, color=CL_White, border=BD_None, exit=TITLE_PS, window=0x3dcce, title=FDTest_String_DebugHDAE2, icon=idICON_i129
FDTest_String_DebugHDAE2:	aligned_string "DEBUG SCREEN for HD-AE"
FDTest_MenuItem_Load2:
	NAKA_REC_VwEditSwBox super=IDX_FDTest_Container_DebugHDAE2, sub=NAKA_INDEX_NONE, next=IDX_FDTest_MenuItem_Go2, prev=NAKA_INDEX_NONE, flag=VF_Const, x=8, y=126, w=39, h=18, color=CL_Silver, border=BD_3D_UP2, index=1, font=idCHARA1, fontcolor=CL_Black, align=AL_Center, editsw=ES_Left3, style=SS_Special, str=FDTest_String_Load2
FDTest_String_Load2:	aligned_string "LOAD"
FDTest_MenuItem_Go2:
	NAKA_REC_VwEditSwBox super=IDX_FDTest_Container_DebugHDAE2, sub=NAKA_INDEX_NONE, next=IDX_FDTest_NavWidget2, prev=IDX_FDTest_MenuItem_Load2, flag=VF_Const, x=8, y=168, w=31, h=18, color=CL_Silver, border=BD_3D_UP2, index=2, font=idCHARA1, fontcolor=CL_Black, align=AL_Center, editsw=ES_Left4, style=SS_Special, str=FDTest_String_Go2
FDTest_String_Go2:
	.byte 0x47, 0x4f, 0x00, 0xff
FDTest_NavWidget2:
	NAKA_REC_IvCatchEvent super=IDX_FDTest_Container_DebugHDAE2, sub=IDX_FDTest_Divider2, next=IDX_FDTest_ConsoleArea2, prev=IDX_FDTest_MenuItem_Go2, flag=VF_Const | VF_InvisibleBox, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_hamadeb
FDTest_Divider2:
	NAKA_REC_IvExitScreen super=IDX_FDTest_NavWidget2, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=NAKA_INDEX_NONE, flag=VF_Const | VF_InvisibleBox, x=8, y=4, w=32, h=32, screen=0xfc0000 + IDX_FDTest_ScreenView
FDTest_ConsoleArea2:
	NAKA_REC_AcScreenMenu super=IDX_FDTest_Container_DebugHDAE2, sub=NAKA_INDEX_NONE, next=IDX_FDTest_StatusBar_Memory, prev=IDX_FDTest_NavWidget2, flag=VF_Const, x=8, y=35, w=149, h=32, color=CL_Transparent, border=BD_None, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, editsw=ES_Left1, selected=0x3dcd2, str=FDTest_String_ConsoleArea2, screen=0xfc0000 + IDX_FDTest_Container_DebugHDAE1, icon=idICON_None
FDTest_String_ConsoleArea2:	aligned_string "MEMORY"
FDTest_StatusBar_Memory:
	NAKA_REC_DbMemo super=IDX_FDTest_Container_DebugHDAE2, sub=NAKA_INDEX_NONE, next=IDX_FDTest_Label_Console2, prev=IDX_FDTest_ConsoleArea2, flag=VF_Const, x=57, y=61, w=263, h=179
FDTest_Label_Console2:
	NAKA_REC_Label super=IDX_FDTest_Container_DebugHDAE2, sub=NAKA_INDEX_NONE, next=NAKA_INDEX_NONE, prev=IDX_FDTest_StatusBar_Memory, flag=VF_Const, x=142, y=42, w=60, h=19, str=String_CONSOLE, font=idCHARA1, fontcolor=CL_White


String_CONSOLE:
	aligned_string "CONSOLE"
	.byte 0x00, 0x00, 0x00, 0x00, 0xd4, 0xdc, 0x03, 0x00

FDTest_DataBlock_Table:
	.long FDTest_DiagList_Total
	.long FDTest_DiagList_NG
	.long FDTest_DiagList_OK
	.long FDTest_Separator1
	.long FDTest_Panel_Param
	.long FDTest_Label_Tilde80
	.long FDTest_Panel_SubElements
	.long FDTest_Group_OnOff
	.long FDTest_Label_RunningTest
	.long FDTest_Container_DebugHDAE1
	.long FDTest_MenuItem_Load1
	.long FDTest_MenuItem_Go1
	.long FDTest_NavWidget1
	.long FDTest_Divider1
	.long FDTest_ConsoleArea1
	.long FDTest_Label_MemoryDump
	.long FDTest_StatusBar1
	.long FDTest_Container_DebugHDAE2
	.long FDTest_MenuItem_Load2
	.long FDTest_MenuItem_Go2
	.long FDTest_NavWidget2
	.long FDTest_Divider2
	.long FDTest_ConsoleArea2
	.long FDTest_StatusBar_Memory
	.long FDTest_Label_Console2
	.byte 0x00, 0x00, 0x00, 0x00
	.long FDTest_DataBlock_Terminator
FDTest_DataBlock_Terminator:	aligned_string ""
FDTest_Config_Table:
	.long FDTest_CfgName_FDDTest
	.long FDTest_CfgName_Total
	.long FDTest_CfgName_NG
	.long FDTest_CfgName_OK
	.long FDTest_CfgName_Slot04
	.long FDTest_CfgName_Start
	.long FDTest_CfgName_Slot06
	.long FDTest_CfgName_Stop
	.long FDTest_CfgName_Slot08
	.long FDTest_CfgName_Slot09
	.long FDTest_CfgName_DebugHDAE
	.long FDTest_CfgName_Slot11
	.long FDTest_CfgName_Slot12
	.long FDTest_CfgName_Slot13
	.long FDTest_CfgName_Slot14
	.long FDTest_CfgName_Slot15
	.long FDTest_CfgName_Slot16
	.long FDTest_CfgName_Slot17
	.long FDTest_CfgName_DebugHDAE2
	.long FDTest_CfgName_Slot19
	.long FDTest_CfgName_Slot20
	.long FDTest_CfgName_Slot21
	.long FDTest_CfgName_Slot22
	.long FDTest_CfgName_Slot23
	.long FDTest_CfgName_Slot24
	.long FDTest_CfgName_Slot25
	.long FDTest_CfgName_Slot26
FDTest_CfgName_Slot26:	aligned_string ""
FDTest_CfgName_Slot25:	aligned_string ""
FDTest_CfgName_Slot24:	aligned_string ""
FDTest_CfgName_Slot23:	aligned_string ""
FDTest_CfgName_Slot22:	aligned_string ""
FDTest_CfgName_Slot21:	aligned_string ""
FDTest_CfgName_Slot20:	aligned_string ""
FDTest_CfgName_Slot19:	aligned_string ""
FDTest_CfgName_DebugHDAE2:	aligned_string "DebugForHDAE2"
FDTest_CfgName_Slot17:	aligned_string ""
FDTest_CfgName_Slot16:	aligned_string ""
FDTest_CfgName_Slot15:	aligned_string ""
FDTest_CfgName_Slot14:	aligned_string ""
FDTest_CfgName_Slot13:	aligned_string ""
FDTest_CfgName_Slot12:	aligned_string ""
FDTest_CfgName_Slot11:	aligned_string ""
FDTest_CfgName_DebugHDAE:	aligned_string "DebugForHDAE"
FDTest_CfgName_Slot09:	aligned_string ""
FDTest_CfgName_Slot08:	aligned_string ""
FDTest_CfgName_Stop:	aligned_string "STOP"
FDTest_CfgName_Slot06:	aligned_string ""
FDTest_CfgName_Start:	aligned_string "START"
FDTest_CfgName_Slot04:	aligned_string ""
FDTest_CfgName_OK:
	.byte 0x4f, 0x4b, 0x00, 0xff
FDTest_CfgName_NG:
	.byte 0x4e, 0x47, 0x00, 0xff
FDTest_CfgName_Total:	aligned_string "TOTAL"
FDTest_CfgName_FDDTest:	aligned_string "FDD_TEST"
	aligned_string "TT_HDDEXT"
	aligned_string "TT_EXTAPR"
	.byte 0x9a, 0xe3, 0xf1, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x3e, 0xfd, 0xe1, 0x00
	.long FDTest_TestTitle_Terminator
FDTest_TestTitle_Terminator:	aligned_string ""
FDTest_String_TestTitleFunc:	aligned_string "TestTitleFunc"
; TestTitleFunc_OnTitleNew_Str_TitleNew: Factory-test diagnostic message "\nTitle new" (leading LF), the text its
;   owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnTitleNew_Str_TitleNew:
	.byte 0x0a
	aligned_string "Title new"
; TestTitleFunc_OnTitleOld_Str_TitleOld: Factory-test diagnostic message "\nTitle old" (leading LF), the text its
;   owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnTitleOld_Str_TitleOld:
	.byte 0x0a
	.asciz "Title old"
	.byte	0xff
; TestTitleFunc_OnTitleActivate_Str_TitleActivate: Factory-test diagnostic message "\nTitle Activate" (leading LF),
;   the text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnTitleActivate_Str_TitleActivate:	.byte	0x0a
	aligned_string "Title Activate"
; TestTitleFunc_OnTitleInactivate_Str_TitleInactivate: Factory-test diagnostic message "\nTitle Inactivate" (leading
;   LF), the text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnTitleInactivate_Str_TitleInactivate:
	.byte 0x0a
	aligned_string "Title Inactivate"
; TestTitleFunc_OnTitleInterrupt_Str_TitleINTERUPT: Factory-test diagnostic message "\nTitle INTERUPT" (leading LF),
;   the text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnTitleInterrupt_Str_TitleINTERUPT:
	.byte 0x0a
	aligned_string "Title INTERUPT"
; TestTitleFunc_OnTitleInterruptReturn_Str_TitleINTERUPT_RETURN: Factory-test diagnostic message "\nTitle INTERUPT
;   RETURN" (leading LF), the text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnTitleInterruptReturn_Str_TitleINTERUPT_RETURN:
	.byte 0x0a
	aligned_string "Title INTERUPT RETURN"
; TestTitleFunc_OnTbiosTest_Str_TBIOS_Test: Factory-test diagnostic message "\nTBIOS Test" (leading LF), the text its
;   owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnTbiosTest_Str_TBIOS_Test:
	.byte 0x0a
	aligned_string "TBIOS Test"
; TestTitleFunc_OnStopFddTest_Str_STOP_FDD_TEST: Factory-test diagnostic message "\nSTOP FDD TEST"
;   (leading LF), the text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnStopFddTest_Str_STOP_FDD_TEST:
	.byte 0x0a
	aligned_string "STOP FDD TEST"
; TestTitleFunc_OnFddTestLoop_Str_START_FDD_TEST_LOOP: Factory-test diagnostic message "\nSTART FDD TEST
;   LOOP" (leading LF), the text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnFddTestLoop_Str_START_FDD_TEST_LOOP:
	.byte 0x0a
	aligned_string "START FDD TEST LOOP"
; TestTitleFunc_OnListDirectory_Str_DIR: Factory-test diagnostic message "\nDIR" (leading LF), the text
;   its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnListDirectory_Str_DIR:
	.byte	0x0a, 0x44, 0x49, 0x52, 0x00, 0xff
; TestTitleFunc_OnFormat2dd_Str_Debug_Test: Factory-test diagnostic message "\nDebug Test" (leading LF),
;   the text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnFormat2dd_Str_Debug_Test:	.byte	0x0a
	aligned_string "Debug Test"
; TestTitleFunc_OnFormat2hd_Str_Debug_Test: Factory-test diagnostic message "\nDebug Test" (leading LF),
;   the text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
TestTitleFunc_OnFormat2hd_Str_Debug_Test:
	.byte 0x0a
	.asciz "Debug Test"
TestTitleFunc_SwitchCaseTable:
	.short	TestTitleFunc_OnTbiosTest - TestTitleFunc_OnTbiosTest
	.short	TestTitleFunc_OnStopFddTest - TestTitleFunc_OnTbiosTest
	.short	TestTitleFunc_OnFddTestLoop - TestTitleFunc_OnTbiosTest
	.short	TestTitleFunc_OnListDirectory - TestTitleFunc_OnTbiosTest
	.short	TestTitleFunc_OnFormat2dd - TestTitleFunc_OnTbiosTest
	.short	TestTitleFunc_OnFormat2hd - TestTitleFunc_OnTbiosTest
	.short	TestTitleFunc_OnListLswFiles - TestTitleFunc_OnTbiosTest
	.short	TitleFunc_Return - TestTitleFunc_OnTbiosTest
TestTitleFunc_StateCaseTable:
	.short	TestTitleFunc_OnTitleNew - TestTitleFunc_OnTitleNew
	.short	TestTitleFunc_OnTitleOld - TestTitleFunc_OnTitleNew
	.short	TestTitleFunc_OnTitleInactivate - TestTitleFunc_OnTitleNew
	.short	TestTitleFunc_OnTitleActivate - TestTitleFunc_OnTitleNew
	.short	TestTitleFunc_OnTitleInterrupt - TestTitleFunc_OnTitleNew
	.short	TestTitleFunc_OnTitleInterruptReturn - TestTitleFunc_OnTitleNew
ListDir2_Entry_Str_A_HAMA_LSW:
	aligned_string "A:\\HAMA\\*.LSW"
; RunTestCounters_Display_Str_TEST_Finishd: Factory-test diagnostic message "\nTEST Finishd!!" (leading LF), the text
;   its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
RunTestCounters_Display_Str_TEST_Finishd:
	.byte 0x0a
	.asciz "TEST Finishd!!"
CreateRunFDOp_Entry_Str_init:
	aligned_string "init"
CreateRunFDOp_Entry_Str_OK:
	.byte 0x4f, 0x4b
	.byte	0x00, 0xff
CreateRunFDOp_Fail_Str_NG:	.byte	0x4e, 0x47, 0x00, 0xff
FDLoadSaveTest_Str_A_IMMUNITY_TST:
	aligned_string "A:IMMUNITY.TST"
; FDLoadSaveTest_Str_File_remove: Factory-test diagnostic message "\nFile remove =>" (leading LF), the text its owner
;   prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
FDLoadSaveTest_Str_File_remove:
	.byte	0x0a
	.ascii	"File remove =>"
	.byte	0x00
FDLoadSaveTest_Str_error:	.byte	0x20, 0x65
	aligned_string "rror"
FDTest_OpenFailed_Str_OK:
	.byte 0x20, 0x4f
	.byte	0x4b, 0x00
; FDTest_AllocBuffer_Str_Not_Enough_memory: Factory-test diagnostic message "\nNot Enough memory!" (leading LF), the
;   text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
FDTest_AllocBuffer_Str_Not_Enough_memory:	.byte	0x0a
	.asciz "Not Enough memory!"
FDTest_OpenForWrite_Str_wb:
	.byte 0x77, 0x62
	.byte	0x00, 0xff
; FDTest_OpenForWrite_Str_cannot_open_write_file: Factory-test diagnostic message "\ncannot open write file" (leading
;   LF), the text its owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
FDTest_OpenForWrite_Str_cannot_open_write_file:	.byte	0x0a
	.asciz "cannot open write file"
; FDTest_WriteBuffer_Str_File_Write: Factory-test diagnostic message "\nFile Write =>" (leading LF), the text its
;   owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
FDTest_WriteBuffer_Str_File_Write:
	.byte 0x0a
	aligned_string "File Write =>"
FDTest_WriteBuffer_Str_Error:
	aligned_string " Error"
FDTest_CloseAndReopen_Str_OK:
	.byte	0x20, 0x4f, 0x4b, 0x00
; FDTest_CloseAndReopen_Str_File_Read: Factory-test diagnostic message "\nFile Read =>" (leading LF), the text its
;   owner prints (FDTest_PrintDiag or the console printer). Basis: readers + bytes.
FDTest_CloseAndReopen_Str_File_Read:	.byte	0x0a
	aligned_string "File Read =>"
FDTest_CloseAndReopen_Str_rb:
	.byte	0x72, 0x62, 0x00, 0xff
; FDTest_String_CannotOpenReadFile: FD self-test diagnostic line "\ncannot open read file" (0x0A + text, NUL, 0xFF
;   pad), printed when reopening A:IMMUNITY.TST for reading fails. Basis: readers + bytes.
FDTest_String_CannotOpenReadFile:	.byte	0x0a
	.ascii	"cannot open read file"
	.byte	0x00, 0xff
FDTest_ReadBack_Str_error:
	aligned_string " error"
FDTest_VerifyData_Str_OK:
	.byte	0x20, 0x4f, 0x4b, 0x00
; FDTest_String_DataCompare: FD self-test diagnostic line "\nData Compare =>" (0x0A + text, NUL, 0xFF pad), printed
;   before the read-back compare verdict. Basis: readers + bytes.
FDTest_String_DataCompare:	.byte	0x0a
	.ascii	"Data Compare =>"
	.byte	0x00, 0xff
FDTest_CompareResult_Str_Error:
	aligned_string " Error!!!!!!!!"
FDTest_Pass_Str_OK:
	.byte	0x20, 0x4f, 0x4b, 0x00
FDListDirectory_Str_Star_Dot_Star:	.byte	0x2a, 0x2e, 0x2a, 0x00
FDTestDlg_FormatDisplay_Str_File_Name_20_charact:
	aligned_string "File Name 20 charact"
FDTestDialogProc_CaseTable:
	.short	FDTestDlg_DefaultCase - FDTestDlg_DefaultCase
	.short	FDTestDlg_DefaultCase - FDTestDlg_DefaultCase
	.short	FDTestDlg_DefaultCase - FDTestDlg_DefaultCase
	.short	FDTestDlg_DefaultCase - FDTestDlg_DefaultCase
	.short	FDTestDlg_Unhandled - FDTestDlg_DefaultCase
	.short	FDTestDlg_DefaultCase - FDTestDlg_DefaultCase
	.short	FDTestDlg_DefaultCase - FDTestDlg_DefaultCase
FDTest_Format2ddAndLabel_Str_TEST_HAMA:
	aligned_string "TEST_HAMA"
FDTest_Format2hdAndLabel_Str_TESTHAMA2HD:
	aligned_string "TESTHAMA2HD"
HamaEvtDisp_LifecycleCheck_Str_LOAD:
	.ascii	"LOAD"
	.byte	0x00, 0xff
HamaEvtDisp_LifecycleCheck_Str_LOAD_END:
	.ascii	"LOAD END"
	.byte	0x00, 0xff
HamaEvtDisp_ExtBootstrap_Str_GO:	.byte	0x47, 0x4f, 0x00, 0xff
HamaEvtDisp_ExtBootstrap_Str_Finishd:
	aligned_string "Finishd"
CheckFDStatusLoad_Entry_Str_Media_Error:
	aligned_string "Media Error"
CheckFDStatusLoad_DoLoad_Str_rb:
	.byte	0x72, 0x62, 0x00, 0xff
CheckFDStatusLoad_DoLoad_Str_A_HKEXT_XAP:	aligned_string "A:HKEXT.XAP"
CheckFDStatusLoad_DoLoad_Str_Cannot_open:
	aligned_string "Cannot open"
LoadExtROM_Entry_Str_XAPR:	.ascii	"XAPR"
	.byte	0x00, 0xff
LoadExtROM_Entry_Str_Different_ID:
	aligned_string "Different ID"
LoadXaprInit_Entry_Str_XAPR:	aligned_string "XAPR"
; Xapr_InitFuncTable: Init-phase handler table of this subsystem (4 x u32, slots = init phases 0-3). Basis: readers +
;   bytes -- entry 2 of Subsys_HandlerTableList, which ScreenGroup_Dispatch walks calling slot WA (init phase 0-3) of
;   every table; slot 0 is Xapr_DetectOnInit.
Xapr_InitFuncTable:
	.long	Xapr_DetectOnInit
	.long	Xapr_InitPhase1_NullRet
	.long	Xapr_InitPhase2_NullRet
	.long	Xapr_InitPhase3_NullRet
LoadExtROM_JumpEntry_Data:	.byte	0x58, 0x41
	.byte 0x50, 0x52, 0x00, 0xff
ResInfo_GetResourceListPtr_Str_TEST:
	.byte 0x54, 0x45, 0x53, 0x54
	.byte 0x00, 0xff
