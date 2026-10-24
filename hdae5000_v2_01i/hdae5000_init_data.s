; ============================================================================
; HDAE5000 initialised .data image  (ROM 0x2f899e - 0x2f95e5, 0x0c48 bytes)
;
; HDAE5000_Clear_Work_Buffer copies this block verbatim to RAM 0x2394ce, then
; HDAE5000_Handler_Registration publishes six of the tables below to the main
; CPU through workspace[0x0e0a][0x00e4] ("RegisterObjectTable").  Each
; registration passes {class id, proc, entry count, data pointer}; the counts
; quoted there (0x45, 0x0d, 0x0e) are exactly the entry counts of these tables,
; which is how each table boundary below was established.
;
;   ROM        RAM        entries  registered as        contents
;   0x2f899e   0x2394ce   69       ID 0x012a            object handler entry points
;   0x2f8aae   0x2395de   69       ID 0x042a            object names (parallel array)
;   0x2f8bbe   0x2396ee   13 lists (via HDAE5000_RECORD_TABLE+0x14)  per-class parameter names
;   0x2f8c4e   0x23977e   13       ID 0x01ca            EV_* event names
;   0x2f8c88   0x2397b8   18       ID 0x01ea            MT_* message names
;   0x2f8cd6   0x239806   13       ID 0x010a            UI class procedures
;   0x2f8d0e   0x23983e   13       ID 0x040a            UI class names (parallel array)
;   0x2f942a   0x239f5a   14       ID 0x014a            screen procedures
;   0x2f9466   0x239f96   14       ID 0x044a            screen names (parallel array)
;
; The 13 class procedures/names are the same 13 UI classes described by
; HDAE5000_RECORD_TABLE (0x29c0aa, 13 x 24 bytes): record+0x00 repeats the
; procedure pointer, +0x0c points at the class name, +0x10 at a per-parameter
; type-signature string and +0x14 at that class's parameter-name list in this
; image.  Signature length == parameter count for all 13 records (11, 2, 0, 0,
; 1, 0, 0, 0, 0, 0, 0, 6, 3 - 23 names plus 13 terminators = the 36 slots at
; 0x2f8bbe).
; ============================================================================

HDAE5000_DataSegmentImage:

; --- names that live in already-carved blocks; anchored to their block label
; --- so no byte of those blocks has to move.  (Promote to real labels when
; --- hdae-strings/hdae-slices re-carve them.)
	; HDAE5000_UI_Config + offset  (0x29bfe0-0x29c0a9)
	.set HDAE5000_ParamStr_ListBox_auto_inc,      HDAE5000_UI_Config + 0x6
	.set HDAE5000_ParamStr_ListBox_dial,          HDAE5000_UI_Config + 0x10
	.set HDAE5000_ParamStr_ListBox_sel_num,       HDAE5000_UI_Config + 0x16
	.set HDAE5000_ParamStr_ListBox_row,           HDAE5000_UI_Config + 0x1e
	.set HDAE5000_ParamStr_ListBox_column,        HDAE5000_UI_Config + 0x22
	.set HDAE5000_ParamStr_ListBox_str_adr,       HDAE5000_UI_Config + 0x2a
	.set HDAE5000_ParamStr_ListBox_main_func,     HDAE5000_UI_Config + 0x32
	.set HDAE5000_ParamStr_ListBox_fontcolor,     HDAE5000_UI_Config + 0x3c
	.set HDAE5000_ParamStr_ListBox_font,          HDAE5000_UI_Config + 0x46
	.set HDAE5000_ParamStr_DbMemoCl_End,          HDAE5000_UI_Config + 0x4c
	.set HDAE5000_ParamStr_DbMemoCl_fontcolor,    HDAE5000_UI_Config + 0x4e
	.set HDAE5000_ParamStr_DbMemoCl_color,        HDAE5000_UI_Config + 0x58
	.set HDAE5000_ParamStr_TtlScreenR_End,        HDAE5000_UI_Config + 0x5e
	.set HDAE5000_ParamStr_AcHddNamingWindow_End, HDAE5000_UI_Config + 0x60
	.set HDAE5000_ParamStr_IvHddNaming_End,       HDAE5000_UI_Config + 0x62
	.set HDAE5000_ParamStr_IvHddNaming_func,      HDAE5000_UI_Config + 0x64
	.set HDAE5000_ParamStr_HDTitleMenu_End,       HDAE5000_UI_Config + 0x6a
	.set HDAE5000_ParamStr_TtlScreenR2_End,       HDAE5000_UI_Config + 0x6c
	.set HDAE5000_ParamStr_TtlScreenR3_End,       HDAE5000_UI_Config + 0x6e
	.set HDAE5000_ParamStr_AcWindowPage1_End,     HDAE5000_UI_Config + 0x70
	.set HDAE5000_ParamStr_IvScreenR2_End,        HDAE5000_UI_Config + 0x72
	.set HDAE5000_ParamStr_AcLanguageText1_End,   HDAE5000_UI_Config + 0x74
	.set HDAE5000_ParamStr_LyricBox_End,          HDAE5000_UI_Config + 0x76
	.set HDAE5000_ParamStr_LyricBox_infocolor,    HDAE5000_UI_Config + 0x78
	.set HDAE5000_ParamStr_LyricBox_infofont,     HDAE5000_UI_Config + 0x82
	.set HDAE5000_ParamStr_LyricBox_reversecolor, HDAE5000_UI_Config + 0x8c
	.set HDAE5000_ParamStr_LyricBox_fontcolor,    HDAE5000_UI_Config + 0x9a
	.set HDAE5000_ParamStr_LyricBox_font,         HDAE5000_UI_Config + 0xa4
	.set HDAE5000_ParamStr_LyricBox_pEnable,      HDAE5000_UI_Config + 0xaa
	.set HDAE5000_ParamStr_FDFileSelect_End,      HDAE5000_UI_Config + 0xb2
	.set HDAE5000_ParamStr_FDFileSelect_sel_pos,  HDAE5000_UI_Config + 0xb4
	.set HDAE5000_ParamStr_FDFileSelect_sel_num,  HDAE5000_UI_Config + 0xbc
	.set HDAE5000_ParamStr_FDFileSelect_dial,     HDAE5000_UI_Config + 0xc4
	; HDAE5000_RECORD_COUNT + offset  (0x29d97e-0x29dc13; note that the last
	; two bytes of that range, 0x29dc12-0x29dc13, are already the first half
	; of the UI object descriptor pool's record #0 - the block boundary here
	; follows the HDAE5000_UI_Descriptors label, which is itself mid-record)
	.set HDAE5000_Str_EV_DrawFDText,         HDAE5000_RECORD_COUNT + 0x2
	.set HDAE5000_Str_EV_InitFDFileSelect,   HDAE5000_RECORD_COUNT + 0x10
	.set HDAE5000_Str_EV_Scrollline,         HDAE5000_RECORD_COUNT + 0x24
	.set HDAE5000_Str_EV_Drawsyllable,       HDAE5000_RECORD_COUNT + 0x32
	.set HDAE5000_Str_EV_Alldraw,            HDAE5000_RECORD_COUNT + 0x42
	.set HDAE5000_Str_EV_Initlyrics,         HDAE5000_RECORD_COUNT + 0x4e
	.set HDAE5000_Str_EV_SETPOSITION,        HDAE5000_RECORD_COUNT + 0x5c
	.set HDAE5000_Str_EV_BEATMESSAGE,        HDAE5000_RECORD_COUNT + 0x6c
	.set HDAE5000_Str_EV_TICKS,              HDAE5000_RECORD_COUNT + 0x7c
	.set HDAE5000_Str_EV_INITLYRICPARAM,     HDAE5000_RECORD_COUNT + 0x86
	.set HDAE5000_Str_EV_TimerBack,          HDAE5000_RECORD_COUNT + 0x98
	.set HDAE5000_Str_EV_AfterLoad,          HDAE5000_RECORD_COUNT + 0xa6
	.set HDAE5000_Str_EV_SeqStop,            HDAE5000_RECORD_COUNT + 0xb4
	.set HDAE5000_Str_MT_FdSaveLyric,        HDAE5000_RECORD_COUNT + 0xc0
	.set HDAE5000_Str_MT_FdLoadLyric,        HDAE5000_RECORD_COUNT + 0xd0
	.set HDAE5000_Str_MT_FdInfo,             HDAE5000_RECORD_COUNT + 0xe0
	.set HDAE5000_Str_MT_FdFreshUp,          HDAE5000_RECORD_COUNT + 0xea
	.set HDAE5000_Str_MT_SelectDelFile,      HDAE5000_RECORD_COUNT + 0xf8
	.set HDAE5000_Str_MT_SelectDEL,          HDAE5000_RECORD_COUNT + 0x10a
	.set HDAE5000_Str_MT_LOOP,               HDAE5000_RECORD_COUNT + 0x118
	.set HDAE5000_Str_MT_SetStrAdr,          HDAE5000_RECORD_COUNT + 0x120
	.set HDAE5000_Str_MT_SelectAll,          HDAE5000_RECORD_COUNT + 0x12e
	.set HDAE5000_Str_MT_SelectSAVE,         HDAE5000_RECORD_COUNT + 0x13c
	.set HDAE5000_Str_MT_SelectOK2,          HDAE5000_RECORD_COUNT + 0x14a
	.set HDAE5000_Str_MT_SelectOK,           HDAE5000_RECORD_COUNT + 0x158
	.set HDAE5000_Str_MT_AckSelNum,          HDAE5000_RECORD_COUNT + 0x164
	.set HDAE5000_Str_MT_ReqSelNum,          HDAE5000_RECORD_COUNT + 0x172
	.set HDAE5000_Str_MT_SetSelNum,          HDAE5000_RECORD_COUNT + 0x180
	.set HDAE5000_Str_MT_ChangeSelNum,       HDAE5000_RECORD_COUNT + 0x18e
	.set HDAE5000_Str_MT_UnderFlow,          HDAE5000_RECORD_COUNT + 0x19e
	.set HDAE5000_Str_MT_OverFlow,           HDAE5000_RECORD_COUNT + 0x1ac
	.set HDAE5000_Str_End_ClassNames,        HDAE5000_RECORD_COUNT + 0x1b8
	.set HDAE5000_Str_FDFileSelectProc,      HDAE5000_RECORD_COUNT + 0x1ba
	.set HDAE5000_Str_LyricBoxProc,          HDAE5000_RECORD_COUNT + 0x1cc
	.set HDAE5000_Str_AcLanguageText1Proc,   HDAE5000_RECORD_COUNT + 0x1da
	.set HDAE5000_Str_IvScreenR2Proc,        HDAE5000_RECORD_COUNT + 0x1ee
	.set HDAE5000_Str_AcWindowPage1Proc,     HDAE5000_RECORD_COUNT + 0x1fe
	.set HDAE5000_Str_TtlScreenR3Proc,       HDAE5000_RECORD_COUNT + 0x210
	.set HDAE5000_Str_TtlScreenR2Proc,       HDAE5000_RECORD_COUNT + 0x220
	.set HDAE5000_Str_HDTitleMenuProc,       HDAE5000_RECORD_COUNT + 0x230
	.set HDAE5000_Str_IvHddNamingProc,       HDAE5000_RECORD_COUNT + 0x240
	.set HDAE5000_Str_AcHddNamingWindowProc, HDAE5000_RECORD_COUNT + 0x250
	.set HDAE5000_Str_TtlScreenRProc,        HDAE5000_RECORD_COUNT + 0x266
	.set HDAE5000_Str_DbMemoClProc,          HDAE5000_RECORD_COUNT + 0x276
	.set HDAE5000_Str_SelectListProc,        HDAE5000_RECORD_COUNT + 0x284
	; HDAE5000_GFX_INIT_PARAMS + offset  (0x2a849a-0x2ba1a5)
	.set HDAE5000_Str_End_ScreenNames,      HDAE5000_GFX_INIT_PARAMS + 0xa
	.set HDAE5000_Str_FileLoadSwCatch,      HDAE5000_GFX_INIT_PARAMS + 0xc
	.set HDAE5000_Str_HDDTitleSwCatch,      HDAE5000_GFX_INIT_PARAMS + 0x1c
	.set HDAE5000_Str_CopyToHDDirSelScreen, HDAE5000_GFX_INIT_PARAMS + 0x2c
	.set HDAE5000_Str_CopyToHDScreen,       HDAE5000_GFX_INIT_PARAMS + 0x42
	.set HDAE5000_Str_FlsFileSelScreen,     HDAE5000_GFX_INIT_PARAMS + 0x52
	.set HDAE5000_Str_FlsDirSelScreen,      HDAE5000_GFX_INIT_PARAMS + 0x64
	.set HDAE5000_Str_FlsEditScreen,        HDAE5000_GFX_INIT_PARAMS + 0x74
	.set HDAE5000_Str_FlsLoadScreen,        HDAE5000_GFX_INIT_PARAMS + 0x82
	.set HDAE5000_Str_SelectFlsScreen,      HDAE5000_GFX_INIT_PARAMS + 0x90
	.set HDAE5000_Str_SetupP2SwCatch,       HDAE5000_GFX_INIT_PARAMS + 0xa0
	.set HDAE5000_Str_FILE_Naming_Screen,   HDAE5000_GFX_INIT_PARAMS + 0xb0
	.set HDAE5000_Str_FILE_LOAD_Screen,     HDAE5000_GFX_INIT_PARAMS + 0xc4
	.set HDAE5000_Str_SEL_DIR_Screen,       HDAE5000_GFX_INIT_PARAMS + 0xd6
	.set HDAE5000_Str_HDAETitleFunc,        HDAE5000_GFX_INIT_PARAMS + 0xe6
	; HDAE5000_Str_Alert_HDFormat and the six HDAE5000_Str_CharSet_* strings this
	; state block cites are labels inside UI object records of the descriptor pool
	; (hdae5000_data_tables.s): the captions of the RAM objects SW_HD_FORMAT and
	; HddNamingABC / abc / Symbol, stored in the records of their ROM neighbours.

; ----------------------------------------------------------------------------
; HDAE5000_ObjHandler_Table / HDAE5000_ObjName_Table
;   69 named objects published to the main-CPU UI framework (registration IDs
;   0x012a and 0x042a, both class id 0x01600002, ApFunctionProc).  Index i of one table
;   matches index i of the other; the name is what the framework looks up.
;   Names ending in "Check" are validation callbacks, "Catch" are event sinks,
;   "Page"/"PAGE" are page constructors and "Bitmap*" are image providers.
; ----------------------------------------------------------------------------
HDAE5000_ObjHandler_Table:
	.long HDAE5000_HardTestPage
	.long HDAE5000_HDDNamingCheck
	.long HDAE5000_HDD_DIRNAMECheck
	.long HDAE5000_HDD_UTIL_PAGE
	.long HDAE5000_PC_DATA_LINK_PAGE
	.long HDAE5000_SeparateOutputModeCheck
	.long HDAE5000_SaveOptNameCheck
	.long HDAE5000_FileOptNameCheck
	.long HDAE5000_SfxLswBitCheck
	.long HDAE5000_SfxPmtBitCheck
	.long HDAE5000_SfxSqtBitCheck
	.long HDAE5000_SfxCmpBitCheck
	.long HDAE5000_SfxTmBitCheck
	.long HDAE5000_SfxMspBitCheck
	.long HDAE5000_SfxRcmBitCheck
	.long HDAE5000_SfxMdBitCheck
	.long HDAE5000_SfxTlxBitCheck
	.long HDAE5000_WriteProtectEditCheck
	.long HDAE5000_WriteConfirmEditCheck
	.long HDAE5000_QuickLoadModeEditCheck
	.long HDAE5000_LoadByNumberModeEditCheck
	.long HDAE5000_JumpAfterLoadModeEditCheck
	.long HDAE5000_HdTitleEventCatch
	.long HDAE5000_FlsNamingCheck
	.long HDAE5000_FlsNamingCheck2
	.long HDAE5000_CP_FD_DIRNAMECheck
	.long HDAE5000_WrConfirmEventCatch
	.long HDAE5000_SaveOptSwEventCatch
	.long HDAE5000_DelOptSwEventCatch
	.long HDAE5000_DelOptNameCheck
	.long HDAE5000_DelLswEditCheck
	.long HDAE5000_DelPmtEditCheck
	.long HDAE5000_DelSqtEditCheck
	.long HDAE5000_DelCmpEditCheck
	.long HDAE5000_DelTmEditCheck
	.long HDAE5000_DelMspEditCheck
	.long HDAE5000_DelRcmEditCheck
	.long HDAE5000_DelMdEditCheck
	.long HDAE5000_DelTlxEditCheck
	.long HDAE5000_BitmapHdd_icon            	; registry entry 39
	.long HDAE5000_LBNPage1SwCatch
	.long HDAE5000_LBNLoadSwCatch
	.long HDAE5000_FileLBNNameCheck
	.long HDAE5000_LBNLswBitCheck
	.long HDAE5000_LBNPmtBitCheck
	.long HDAE5000_LBNSqtBitCheck
	.long HDAE5000_LBNCmpBitCheck
	.long HDAE5000_LBNTmBitCheck
	.long HDAE5000_LBNMspBitCheck
	.long HDAE5000_LBNRcmBitCheck
	.long HDAE5000_LBNMdBitCheck
	.long HDAE5000_FlsFileLoadSwCatch
	.long HDAE5000_AttenDelDirSwCatch
	.long HDAE5000_AttenDelFileSwCatch
	.long HDAE5000_AttenHDFormatSwCatch
	.long HDAE5000_AttenCpToHDSwCatch
	.long HDAE5000_AttenCpToMarkSwCatch
	.long HDAE5000_FlsDel1SwCatch
	.long HDAE5000_FlsDel2SwCatch
	.long HDAE5000_FlsOverWrSwCatch
	.long HDAE5000_SeparateDrumPartCheck
	.long HDAE5000_SeparateBassPartCheck
	.long HDAE5000_ErrMsgTimerCatch
	.long HDAE5000_ErrMsgTimerCatchLBN
	.long HDAE5000_LanguageTextReturn        	; registry entry 64
	.long HDAE5000_BitmapButt01
	.long HDAE5000_LyricJumpEditCheck
	.long 0			; end of table

HDAE5000_ObjName_Table:
	.long HDAE5000_Str_HardTestPage
	.long HDAE5000_Str_HDDNamingCheck
	.long HDAE5000_Str_HDD_DIRNAMECheck
	.long HDAE5000_Str_HDD_UTIL_PAGE
	.long HDAE5000_Str_PC_DATA_LINK_PAGE
	.long HDAE5000_Str_SeparateOutputModeCheck
	.long HDAE5000_Str_SaveOptNameCheck
	.long HDAE5000_Str_FileOptNameCheck
	.long HDAE5000_Str_SfxLswBitCheck
	.long HDAE5000_Str_SfxPmtBitCheck
	.long HDAE5000_Str_SfxSqtBitCheck
	.long HDAE5000_Str_SfxCmpBitCheck
	.long HDAE5000_Str_SfxTmBitCheck
	.long HDAE5000_Str_SfxMspBitCheck
	.long HDAE5000_Str_SfxRcmBitCheck
	.long HDAE5000_Str_SfxMdBitCheck
	.long HDAE5000_Str_SfxTlxBitCheck
	.long HDAE5000_Str_WriteProtectEditCheck
	.long HDAE5000_Str_WriteConfirmEditCheck
	.long HDAE5000_Str_QuickLoadModeEditCheck
	.long HDAE5000_Str_LoadByNumberModeEditCheck
	.long HDAE5000_Str_JumpAfterLoadModeEditCheck
	.long HDAE5000_Str_HdTitleEventCatch
	.long HDAE5000_Str_FlsNamingCheck
	.long HDAE5000_Str_FlsNamingCheck2
	.long HDAE5000_Str_CP_FD_DIRNAMECheck
	.long HDAE5000_Str_WrConfirmEventCatch
	.long HDAE5000_Str_SaveOptSwEventCatch
	.long HDAE5000_Str_DelOptSwEventCatch
	.long HDAE5000_Str_DelOptNameCheck
	.long HDAE5000_Str_DelLswEditCheck
	.long HDAE5000_Str_DelPmtEditCheck
	.long HDAE5000_Str_DelSqtEditCheck
	.long HDAE5000_Str_DelCmpEditCheck
	.long HDAE5000_Str_DelTmEditCheck
	.long HDAE5000_Str_DelMspEditCheck
	.long HDAE5000_Str_DelRcmEditCheck
	.long HDAE5000_Str_DelMdEditCheck
	.long HDAE5000_Str_DelTlxEditCheck
	.long HDAE5000_Str_BitmapHdd_icon
	.long HDAE5000_Str_LBNPage1SwCatch
	.long HDAE5000_Str_LBNLoadSwCatch
	.long HDAE5000_Str_FileLBNNameCheck
	.long HDAE5000_Str_LBNLswBitCheck
	.long HDAE5000_Str_LBNPmtBitCheck
	.long HDAE5000_Str_LBNSqtBitCheck
	.long HDAE5000_Str_LBNCmpBitCheck
	.long HDAE5000_Str_LBNTmBitCheck
	.long HDAE5000_Str_LBNMspBitCheck
	.long HDAE5000_Str_LBNRcmBitCheck
	.long HDAE5000_Str_LBNMdBitCheck
	.long HDAE5000_Str_FlsFileLoadSwCatch
	.long HDAE5000_Str_AttenDelDirSwCatch
	.long HDAE5000_Str_AttenDelFileSwCatch
	.long HDAE5000_Str_AttenHDFormatSwCatch
	.long HDAE5000_Str_AttenCpToHDSwCatch
	.long HDAE5000_Str_AttenCpToMarkSwCatch
	.long HDAE5000_Str_FlsDel1SwCatch
	.long HDAE5000_Str_FlsDel2SwCatch
	.long HDAE5000_Str_FlsOverWrSwCatch
	.long HDAE5000_Str_SeparateDrumPartCheck
	.long HDAE5000_Str_SeparateBassPartCheck
	.long HDAE5000_Str_ErrMsgTimerCatch
	.long HDAE5000_Str_ErrMsgTimerCatchLBN
	.long HDAE5000_Str_LanguageTextReturn
	.long HDAE5000_Str_BitmapButt01
	.long HDAE5000_Str_LyricJumpEditCheck
	.long HDAE5000_Str_End_ObjNames	; empty name terminates the list

; ----------------------------------------------------------------------------
; Per-class parameter-name lists
;   One list per HDAE5000_RECORD_TABLE record, reached through record+0x14.
;   Each list ends with a pointer to an empty string.  Six classes take no
;   parameters, so their "list" is just the terminator.
; ----------------------------------------------------------------------------
HDAE5000_ParamNames_ListBox:
	.long HDAE5000_ParamStr_ListBox_font
	.long HDAE5000_ParamStr_ListBox_fontcolor
	.long HDAE5000_ParamStr_ListBox_main_func
	.long HDAE5000_ParamStr_ListBox_str_adr
	.long HDAE5000_ParamStr_ListBox_column
	.long HDAE5000_ParamStr_ListBox_row
	.long HDAE5000_ParamStr_ListBox_sel_num
	.long HDAE5000_ParamStr_ListBox_dial
	.long HDAE5000_ParamStr_ListBox_auto_inc
	.long HDAE5000_ParamStr_ListBox_en_paradraw
	.long HDAE5000_ParamStr_ListBox_sel_type
	.long HDAE5000_ParamStr_ListBox_End	; terminator
HDAE5000_ParamNames_DbMemoCl:
	.long HDAE5000_ParamStr_DbMemoCl_color
	.long HDAE5000_ParamStr_DbMemoCl_fontcolor
	.long HDAE5000_ParamStr_DbMemoCl_End	; terminator
HDAE5000_ParamNames_TtlScreenR:
	.long HDAE5000_ParamStr_TtlScreenR_End	; terminator
HDAE5000_ParamNames_AcHddNamingWindow:
	.long HDAE5000_ParamStr_AcHddNamingWindow_End	; terminator
HDAE5000_ParamNames_IvHddNaming:
	.long HDAE5000_ParamStr_IvHddNaming_func
	.long HDAE5000_ParamStr_IvHddNaming_End	; terminator
HDAE5000_ParamNames_HDTitleMenu:
	.long HDAE5000_ParamStr_HDTitleMenu_End	; terminator
HDAE5000_ParamNames_TtlScreenR2:
	.long HDAE5000_ParamStr_TtlScreenR2_End	; terminator
HDAE5000_ParamNames_TtlScreenR3:
	.long HDAE5000_ParamStr_TtlScreenR3_End	; terminator
HDAE5000_ParamNames_AcWindowPage1:
	.long HDAE5000_ParamStr_AcWindowPage1_End	; terminator
HDAE5000_ParamNames_IvScreenR2:
	.long HDAE5000_ParamStr_IvScreenR2_End	; terminator
HDAE5000_ParamNames_AcLanguageText1:
	.long HDAE5000_ParamStr_AcLanguageText1_End	; terminator
HDAE5000_ParamNames_LyricBox:
	.long HDAE5000_ParamStr_LyricBox_pEnable
	.long HDAE5000_ParamStr_LyricBox_font
	.long HDAE5000_ParamStr_LyricBox_fontcolor
	.long HDAE5000_ParamStr_LyricBox_reversecolor
	.long HDAE5000_ParamStr_LyricBox_infofont
	.long HDAE5000_ParamStr_LyricBox_infocolor
	.long HDAE5000_ParamStr_LyricBox_End	; terminator
HDAE5000_ParamNames_FDFileSelect:
	.long HDAE5000_ParamStr_FDFileSelect_dial
	.long HDAE5000_ParamStr_FDFileSelect_sel_num
	.long HDAE5000_ParamStr_FDFileSelect_sel_pos
	.long HDAE5000_ParamStr_FDFileSelect_End	; terminator

; ----------------------------------------------------------------------------
; EV_* event names (registration ID 0x01ca, class id 0x0160000c, ResEventProc)
;   Registered with a run-time count read from HDAE5000_EventName_Count, which
;   is part of this same image (RAM 0x2397b6) rather than an immediate.
; ----------------------------------------------------------------------------
HDAE5000_EventName_Table:
	.long HDAE5000_Str_EV_SeqStop
	.long HDAE5000_Str_EV_AfterLoad
	.long HDAE5000_Str_EV_TimerBack
	.long HDAE5000_Str_EV_INITLYRICPARAM
	.long HDAE5000_Str_EV_TICKS
	.long HDAE5000_Str_EV_BEATMESSAGE
	.long HDAE5000_Str_EV_SETPOSITION
	.long HDAE5000_Str_EV_Initlyrics
	.long HDAE5000_Str_EV_Alldraw
	.long HDAE5000_Str_EV_Drawsyllable
	.long HDAE5000_Str_EV_Scrollline
	.long HDAE5000_Str_EV_InitFDFileSelect
	.long HDAE5000_Str_EV_DrawFDText
	.long 0			; end of table
HDAE5000_EventName_Count:
	.short 13

; ----------------------------------------------------------------------------
; MT_* message names (registration ID 0x01ea, class id 0x0160000d, ResMethodProc)
;   Lyrics/file-select message vocabulary shared with the main CPU; count in
;   HDAE5000_MessageName_Count (RAM 0x239804).
; ----------------------------------------------------------------------------
HDAE5000_MessageName_Table:
	.long HDAE5000_Str_MT_OverFlow
	.long HDAE5000_Str_MT_UnderFlow
	.long HDAE5000_Str_MT_ChangeSelNum
	.long HDAE5000_Str_MT_SetSelNum
	.long HDAE5000_Str_MT_ReqSelNum
	.long HDAE5000_Str_MT_AckSelNum
	.long HDAE5000_Str_MT_SelectOK
	.long HDAE5000_Str_MT_SelectOK2
	.long HDAE5000_Str_MT_SelectSAVE
	.long HDAE5000_Str_MT_SelectAll
	.long HDAE5000_Str_MT_SetStrAdr
	.long HDAE5000_Str_MT_LOOP
	.long HDAE5000_Str_MT_SelectDEL
	.long HDAE5000_Str_MT_SelectDelFile
	.long HDAE5000_Str_MT_FdFreshUp
	.long HDAE5000_Str_MT_FdInfo
	.long HDAE5000_Str_MT_FdLoadLyric
	.long HDAE5000_Str_MT_FdSaveLyric
	.long 0			; end of table
HDAE5000_MessageName_Count:
	.short 18

; ----------------------------------------------------------------------------
; UI class procedures and names (registration IDs 0x010a / 0x040a)
;   The same 13 classes that HDAE5000_RECORD_TABLE describes, in the same
;   order; record+0x00 of each record repeats the pointer listed here.
; ----------------------------------------------------------------------------
HDAE5000_ClassProc_Table:
	.long HDAE5000_SelectListProc
	.long HDAE5000_DbMemoClProc
	.long HDAE5000_TtlScreenRProc
	.long HDAE5000_AcHddNamingWindowProc
	.long HDAE5000_IvHddNamingProc
	.long HDAE5000_HDTitleMenuProc
	.long HDAE5000_TtlScreenR2Proc
	.long HDAE5000_TtlScreenR3Proc
	.long HDAE5000_AcWindowPage1Proc
	.long HDAE5000_IvScreenR2Proc
	.long HDAE5000_AcLanguageText1Proc
	.long HDAE5000_LyricBoxProc
	.long HDAE5000_FDFileSelectProc
	.long 0			; end of table

HDAE5000_ClassName_Table:
	.long HDAE5000_Str_SelectListProc
	.long HDAE5000_Str_DbMemoClProc
	.long HDAE5000_Str_TtlScreenRProc
	.long HDAE5000_Str_AcHddNamingWindowProc
	.long HDAE5000_Str_IvHddNamingProc
	.long HDAE5000_Str_HDTitleMenuProc
	.long HDAE5000_Str_TtlScreenR2Proc
	.long HDAE5000_Str_TtlScreenR3Proc
	.long HDAE5000_Str_AcWindowPage1Proc
	.long HDAE5000_Str_IvScreenR2Proc
	.long HDAE5000_Str_AcLanguageText1Proc
	.long HDAE5000_Str_LyricBoxProc
	.long HDAE5000_Str_FDFileSelectProc
	.long HDAE5000_Str_End_ClassNames	; empty name terminates the list

; ----------------------------------------------------------------------------
; Screen/window run-time state block  (ROM 0x2f8d46-0x2f9429, RAM 0x239876)
;
; Initial values for the window records the HD-AE5000 keeps in RAM.  Three
; motifs repeat and are what the byte grouping below follows:
;   * 0xffff          - the "unset" sentinel used everywhere in this ROM
;   * 0x0001 0x0002 0x0000 triplets - per-window state enumerations
;   * 8-byte records {u16 0x0000; u32 handle; u16 0xffff} whose 32-bit field
;     always lands in 0x006fb0f5-0x00709078.  Those values are NOT referenced
;     by any code in this ROM and the window they fall in belongs to the main
;     CPU rhythm ROM, so reading them as pointers is not supported by
;     evidence; they look like opaque handles patched at run time.
;   * from 0x2f911c on the block is not state at all: it is 20 UI object
;     descriptor records in the same format as the pool at 0x29dc12 (see the
;     header at HDAE5000_UI_Descriptors in hdae5000_data_tables.s), one for
;     each of the 20 objects whose descriptor lives in RAM.  0x0160 is NOT a
;     display width: it is the high half of the .long class id, and the words
;     after it are {parent, first child, next, prev} object indices then
;     x1,y1,x2,y2.
; No code in this ROM reads the block through a named address, so it is kept
; as annotated bytes rather than being split into invented variables.
; ----------------------------------------------------------------------------
HDAE5000_WindowState_Init:
	; slot defaults: 0xffff/0x0000 sentinels, the 8-byte {0x0000, handle, 0xffff}
	; records, and runs of the {0x0001, 0x0002, 0x0000} per-slot state triplet
	.short 0xffff, 0xffff, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x8901
	.short 0x0070, 0xffff, 0x0000, 0x0000, 0x0000, 0xffff, 0xffff, 0x0001
	.short 0xffff, 0xffff, 0x0001, 0xffff, 0xffff, 0x7bb2, 0x0070, 0x0000
	.short 0x0000, 0xffff, 0xffff, 0x0000, 0x0000, 0xffff, 0xffff, 0x0000
	.short 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0xffff, 0xffff, 0x0000
	.short 0x0000, 0x0000, 0x0000, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0x0000, 0x0000, 0xffff, 0xffff, 0x86a1, 0x0070, 0xffff
	.short 0x0000, 0xffff, 0xffff, 0xffff, 0xffff, 0x0000, 0x0001, 0x0000
	.short 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000
	.short 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0x0000, 0x0000, 0x0000, 0x0000, 0xffff, 0xffff
	.short 0x0001, 0x0000, 0x0000, 0x0000, 0x0010, 0x0000, 0x0000, 0x0000
	.short 0x0000, 0xffff, 0xffff, 0x0001, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0x0000, 0x8dcc, 0x0070, 0xffff, 0x0000, 0x8542, 0x0070, 0xffff
	.short 0x0000, 0x8547, 0x0070, 0xffff, 0x0000, 0x8559, 0x0070, 0xffff
	.short 0x0000, 0x855e, 0x0070, 0xffff, 0x0000, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0x0000, 0x0000, 0x0000, 0x0001, 0x0002, 0x0000, 0x0001
	.short 0x0002, 0x0000, 0x0001, 0x0002, 0x0000, 0x0001, 0x0002, 0x0000
	.short 0x0001, 0x0002, 0x0000, 0x0001, 0x0002, 0x0000, 0x0001, 0x0002
	.short 0x0000, 0x0001, 0x0002, 0x0000, 0xffff, 0xffff, 0x765b, 0x0070
	.short 0x0000, 0x0000, 0x764d, 0x0070, 0xffff, 0x0000, 0xffff, 0xffff
	.short 0xb0f5, 0x006f, 0x0000, 0x0000, 0xffff, 0xffff, 0x7dab, 0x0070
	.short 0x0000, 0x0000, 0xffff, 0xffff, 0xffff, 0xffff, 0x8dcc, 0x0070
	.short 0xffff, 0x0000, 0x8998, 0x0070, 0x0001, 0x0000, 0x7b0c, 0x0070
	.short 0xffff, 0x0000, 0xffff, 0xffff, 0xffff, 0xffff, 0x0001, 0x0002
	.short 0x0000, 0x0001, 0x0002, 0x0000, 0x0001, 0x0002, 0x0000, 0x0001
	.short 0x0002, 0x0000, 0x0001, 0x0002, 0x0000, 0x0001, 0x0002, 0x0000
	.short 0x0001, 0x0002, 0x0000, 0x0000, 0x0000, 0x0000, 0x0001, 0x0002
	.short 0x0000, 0x0001, 0x0002, 0x0000, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0x8dcc, 0x0070, 0xffff, 0x0000, 0x7b4c, 0x0070, 0xffff, 0x0000
	.short 0x7b2c, 0x0070, 0xffff, 0x0000, 0x8b79, 0x0070, 0x0000, 0x0000
	.short 0xffff, 0xffff, 0x7be6, 0x0070, 0x0000, 0x0000, 0xffff, 0xffff
	.short 0x7b40, 0x0070, 0xffff, 0x0000, 0x89cc, 0x0070, 0x0000, 0x0000
	.short 0x8e00, 0x0070, 0xffff, 0x0000, 0xffff, 0xffff, 0x7b60, 0x0070
	.short 0xffff, 0x0000, 0x8bad, 0x0070, 0x0000, 0x0000, 0x7b80, 0x0070
	.short 0xffff, 0x0000, 0x8e00, 0x0070, 0xffff, 0x0000, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0x0001, 0x0002
	.short 0x0000, 0x0000, 0x0000, 0x0000, 0x0001, 0x0002, 0x0000, 0x0001
	.short 0x0002, 0x0000, 0x0001, 0x0002, 0x0000, 0x0001, 0x0002, 0x0000
	.short 0x0001, 0x0002, 0x0000, 0x0001, 0x0002, 0x0000, 0x0001, 0x0002
	.short 0x0000, 0x0001, 0x0002, 0x0000, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0x0000, 0x0000, 0x0001, 0x0000, 0xffff, 0xffff, 0x0001, 0x0001
	.short 0x0000, 0x0001, 0x0001, 0x0000, 0x0001, 0x0001, 0x0000, 0x0001
	.short 0x0001, 0x0000, 0x0001, 0x0001, 0x0000, 0x0001, 0x0001, 0x0000
	.short 0x0001, 0x0001, 0x0000, 0x0001, 0x0001, 0x0000, 0x0000, 0x0000
	.short 0x0000, 0x0001, 0x0001, 0x0000, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0x3b39, 0x0070, 0xffff, 0x0000, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0x0001, 0xffff, 0xffff, 0xffff
	.short 0xffff, 0x0000, 0x0000, 0x0000, 0x0000, 0x2bd8, 0x0070, 0xffff
	.short 0x0000, 0xffff, 0xffff, 0x0000, 0xffff, 0xffff, 0x0000, 0x0000
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0x0001, 0x0000, 0x0000
HDAE5000_WindowGeometry_Init:
	; ROM init image for the 20 UI objects whose descriptor lives in sub-CPU
	; work RAM (0x239C4C-0x239F59) instead of in the ROM pool.  After four
	; 0xffff words (eight 0xff bytes) the record array starts at 0x2f911c and
	; runs to 0x2f9429, in exactly the format documented at
	; HDAE5000_UI_Descriptors in hdae5000_data_tables.s.  The start address is
	; pinned independently of that parse: HDAE5000_Clear_Work_Buffer copies
	; this image to 0x2394ce, and 0x2f911c - 0x2f899e = 0x77e =
	; 0x239c4c - 0x2394ce, the first RAM descriptor address in
	; HDAE5000_UiObject_PtrTable.
	;
	; RETRACTED: "40-byte-stride" and "0x0160 (=352, the panel display width)".
	; There is no single stride - the 20 records are 40,54,40,40,40,40,40,40,
	; 40,40,40,44,44,44,26,26,36,36,36,36 bytes.  The first 19 of those lengths
	; are the address deltas between the 20 RAM descriptors listed in
	; HDAE5000_UiObject_PtrTable; the 20th comes from the class instead.  Each
	; length is also the class-determined body length of the record (classes
	; 0160:001F, 0041, 004E, 0049, 0012), except for 0160:004E, which has no
	; instance in the ROM pool and so is pinned only by the delta.  0x0160 is
	; the high half of the .long class id, the same value 546 of the 769 ROM
	; pool records carry.
	;
	; The records are, in order: #44 SELECT_DIR_SW_EDIT, #128 SW_HD_FORMAT,
	; #218 CP_FD_HDSWTO, #220 CP_FD_HDSWSEL, #224 CP_FD_HDALLSEL,
	; #249 FLS_SELECT_SW_EDIT, #256 HD_FILE_LOAD_SW_SAVE, #266
	; HD_FILE_LOAD_SW_DEL, #269 HD_FILE_LOAD_SW_DELFILE, #302 (unnamed),
	; #318 FLS_FILE_LOAD_SW_EDIT, #443 HddNamingABC, #444 HddNamingabc,
	; #445 HddNamingSymbol, #664 ERR_SAVE_EXIT, #670 ERR_LOAD_EXIT,
	; #767 ChordinLyric, #768 TempoinLyric, #769 MeasureinLyric,
	; #770 TimeSigInLyric.  VERIFIED: every parent / first-child / next / prev
	; index they carry agrees with the ROM pool's own tree - 33/33 checkable
	; links, no exception (analysis/wave7-probes/verify_hdae5000_ui_pool.py).
	;
	; The three 44-byte records (#443/444/445, class 0160:004E) are the
	; naming-screen character-set selectors; like the pool's 0160:0026 toggle
	; soft keys they carry TWO caption pointers, at +0x1e and +0x1a, and here
	; both copies are identical ("ABC"/"ABC", "abc"/"abc", "!#$"/"!#$").  Those
	; six literals are stored inside object #442 "HddNamingCursorBox" in the
	; ROM pool.  Each record also holds a pointer back into the RAM copy of
	; this image, which is why the block has to be copied, not read in place.
	.short 0xffff, 0xffff, 0xffff, 0xffff, 0x001f, 0x0160, 0x0023, 0x002e
	.short 0x002f, 0x002c, 0x0000, 0x0109, 0x00c9, 0x0137, 0x00da, 0x00f2
	.short 0x00c0, 0x0004, 0x0000, 0x0000, 0x0000, 0x0000, 0x000c, 0x0000
	.short 0x0041, 0x0160, 0x007c, 0x0083, 0x0084, 0x0081, 0x0000, 0x00a3
	.short 0x0048, 0x0137, 0x0061, 0x00f7, 0x0000, 0xffff, 0x0000, 0x0000
	.short 0x00ff, 0x0000, 0x0009
	.long 0x0023992e	; RAM copy of this image + 0x470
	.long HDAE5000_Str_Alert_HDFormat
	.short 0xffff, 0xffff, 0x0001, 0x0000, 0x001f, 0x0160, 0x00d4, 0x00dd
	.short 0x00de, 0x00db, 0x0000, 0x010f, 0x0022, 0x0137, 0x0033, 0x0007
	.short 0x00c1, 0x0003, 0x0000, 0x0000, 0x0000, 0x0000, 0x0008, 0x0000
	.short 0x001f, 0x0160, 0x00d4, 0x00df, 0x00e0, 0x00dc, 0x0000, 0x0106
	.short 0x00ca, 0x0137, 0x00db, 0x00f2, 0x00c1, 0x0004, 0x0003, 0x0000
	.short 0x0000, 0x0000, 0x000c, 0x0000, 0x001f, 0x0160, 0x00d4, 0x00e3
	.short 0xffff, 0x00e1, 0x0000, 0x0106, 0x00a0, 0x0137, 0x00b1, 0x00f2
	.short 0x00c1, 0x0008, 0x0003, 0x0000, 0x0000, 0x0000, 0x000b, 0x0000
	.short 0x001f, 0x0160, 0x00f2, 0x00fc, 0x00fd, 0x00fa, 0x0000, 0x0109
	.short 0x00c9, 0x0137, 0x00da, 0x00f2, 0x00c0, 0x0004, 0x0000, 0x0000
	.short 0x0000, 0x0000, 0x000c, 0x0000, 0x001f, 0x0160, 0x0101, 0x0103
	.short 0x0104, 0xffff, 0x0000, 0x0109, 0x00cb, 0x0137, 0x00dc, 0x00f2
	.short 0x00c0, 0x0004, 0x0000, 0x0000, 0x0000, 0x0000, 0x000c, 0x0000
	.short 0x001f, 0x0160, 0x0101, 0x010d, 0x010f, 0x010b, 0x0000, 0x0008
	.short 0x001e, 0x0029, 0x0037, 0x00f2, 0x00c2, 0x0007, 0x0000, 0x0000
	.short 0x0000, 0x0000, 0x0088, 0x0000, 0x001f, 0x0160, 0x0101, 0x0110
	.short 0xffff, 0x010c, 0x0000, 0x0008, 0x0072, 0x0029, 0x008b, 0x00f2
	.short 0x00c2, 0x0005, 0x0000, 0x0000, 0x0000, 0x0000, 0x008a, 0x0000
	.short 0x001f, 0x0160, 0x0112, 0xffff, 0x0131, 0x012f, 0x0000, 0x0009
	.short 0x00a0, 0x0028, 0x00b6, 0x0007, 0x00c9, 0x0009, 0x0000, 0x0000
	.short 0x0000, 0x0000, 0x008b, 0x0003, 0x001f, 0x0160, 0x013c, 0x0141
	.short 0x0142, 0x013e, 0x0000, 0x0109, 0x00c9, 0x0137, 0x00da, 0x00f2
	.short 0x00c0, 0x0004, 0x0000, 0x0000, 0x0000, 0x0000, 0x000c, 0x0000
	.short 0x004e, 0x0160, 0x01b0, 0xffff, 0x01be, 0x01bc, 0x0000, 0x0054
	.short 0x00d8, 0x0073, 0x00ee, 0x0000, 0x0000
	.long HDAE5000_Str_CharSet_Upper_2
	.long HDAE5000_Str_CharSet_Upper_1
	.long 0x00239b18	; RAM copy of this image + 0x65a
	.short 0x0002, 0x0000, 0x0000, 0x004e, 0x0160, 0x01b0, 0xffff, 0x01bf
	.short 0x01bd, 0x0000, 0x007c, 0x00d8, 0x009b, 0x00ee, 0x0000, 0x0000
	.long HDAE5000_Str_CharSet_Lower_2
	.long HDAE5000_Str_CharSet_Lower_1
	.long 0x00239b1a	; RAM copy of this image + 0x65c
	.short 0x0003, 0x0000, 0x0001, 0x004e, 0x0160, 0x01b0, 0xffff, 0x01c0
	.short 0x01be, 0x0000, 0x00a4, 0x00d8, 0x00c3, 0x00ee, 0x0000, 0x0000
	.long HDAE5000_Str_CharSet_Symbol_2
	.long HDAE5000_Str_CharSet_Symbol_1
	.long 0x00239b1c	; RAM copy of this image + 0x65e
	.short 0x0004, 0x0000, 0x0002, 0x0049, 0x0160, 0x0296, 0xffff, 0x0298
	.short 0xffff, 0x0010, 0x0000, 0x0000, 0x001f, 0x001f, 0xffff, 0xffff
	.short 0x0049, 0x0160, 0x029c, 0xffff, 0x029e, 0xffff, 0x0010, 0x0000
	.short 0x0000, 0x001f, 0x001f, 0xffff, 0xffff, 0x0012, 0x0160, 0x02fd
	.short 0xffff, 0x02ff, 0xffff, 0x0000, 0x0000, 0x00d1, 0x004f, 0x00e0
	.short 0x00f7, 0x0000, 0xffff, 0x0003, 0x0000, 0x00ff, 0x0000, 0x0012
	.short 0x0160, 0x02fd, 0xffff, 0x0300, 0x02fe, 0x0000, 0x004e, 0x00d1
	.short 0x009d, 0x00e0, 0x00f7, 0x0000, 0xffff, 0x0003, 0x0000, 0x00ff
	.short 0x0000, 0x0012, 0x0160, 0x02fd, 0xffff, 0x0301, 0x02ff, 0x0000
	.short 0x00f0, 0x00d1, 0x013f, 0x00e0, 0x00f7, 0x0000, 0xffff, 0x0003
	.short 0x0000, 0x00ff, 0x0000, 0x0012, 0x0160, 0x02fd, 0xffff, 0xffff
	.short 0x0300, 0x0000, 0x00aa, 0x00d1, 0x00f9, 0x00e0, 0x00f7, 0x0000
	.short 0xffff, 0x0003, 0x0000, 0x00ff, 0x0000

; ----------------------------------------------------------------------------
; Screen procedures and names (registration IDs 0x014a / 0x044a)
;   The 14 top-level HD-AE5000 screens.  Unlike the class table there is no
;   ROM-side descriptor array for these; the name is the only handle.
; ----------------------------------------------------------------------------
HDAE5000_ScreenProc_Table:
	.long HDAE5000_HDAETitleFunc
	.long HDAE5000_SEL_DIR_Screen      	; registry entry 1
	.long HDAE5000_FILE_LOAD_Screen
	.long HDAE5000_FILE_Naming_Screen
	.long HDAE5000_SetupP2SwCatch
	.long HDAE5000_SelectFlsScreen
	.long HDAE5000_FlsLoadScreen
	.long HDAE5000_FlsEditScreen
	.long HDAE5000_FlsDirSelScreen
	.long HDAE5000_FlsFileSelScreen
	.long HDAE5000_CopyToHDScreen
	.long HDAE5000_CopyToHDDirSelScreen
	.long HDAE5000_HDDTitleSwCatch
	.long HDAE5000_FileLoadSwCatch
	.long 0			; end of table

HDAE5000_ScreenName_Table:
	.long HDAE5000_Str_HDAETitleFunc
	.long HDAE5000_Str_SEL_DIR_Screen
	.long HDAE5000_Str_FILE_LOAD_Screen
	.long HDAE5000_Str_FILE_Naming_Screen
	.long HDAE5000_Str_SetupP2SwCatch
	.long HDAE5000_Str_SelectFlsScreen
	.long HDAE5000_Str_FlsLoadScreen
	.long HDAE5000_Str_FlsEditScreen
	.long HDAE5000_Str_FlsDirSelScreen
	.long HDAE5000_Str_FlsFileSelScreen
	.long HDAE5000_Str_CopyToHDScreen
	.long HDAE5000_Str_CopyToHDDirSelScreen
	.long HDAE5000_Str_HDDTitleSwCatch
	.long HDAE5000_Str_FileLoadSwCatch
	.long HDAE5000_Str_End_ScreenNames	; empty name terminates the list

; ----------------------------------------------------------------------------
; File/name editing scalars and buffers  (RAM 0x239fd2 onwards)
; ----------------------------------------------------------------------------
HDAE5000_FileFormat_VersionMajor:
	.short 2			; low byte -> saved-file header 0x238ff6
HDAE5000_FileFormat_VersionMinor:
	.short 1			; low byte -> 0x238ff7; load compares the major against 0x2390f4
HDAE5000_Name_ColumnRuler:
	.asciz "123456789012345678901234567890"
	.byte 0x00		; 16-bit alignment pad
HDAE5000_Name_EditBuffer:
	.asciz "                              "	; 30 columns, blank-filled
	.byte 0x00		; 16-bit alignment pad
HDAE5000_Browser_State:
	; RAM 0x23a016 is the row-base offset added to every browser row address;
	; the next words are the browser cursors (0x23a01e is the display row base).
	.short 0, 0, 0, 0, 0, 0, 0
	.short 127			; RAM 0x23a024, not read anywhere in this ROM
	.short 0			; RAM 0x23a026, byte-tested flag
				; ^ = HDAE5000_RAM_SeparateBassPart (0 = NONE): the value of
				;   SeparateBassPartCheck, used by HDAE5000_SeparateOutput_Apply
HDAE5000_Browser_PageRows:
	; ^ name not supported by the code: 0x23a028 is HDAE5000_RAM_SeparateDrumPart
	;   (SeparateDrumPartCheck's value, initially 16) and 0x23a02a the drum part
	;   last sent (HDAE5000_RAM_SeparateDrumPartSent); see HDAE5000_SeparateOutput_Apply.
	.short 16, 16		; RAM 0x23a028/0x23a02a
	.short 0			; RAM 0x23a02c, byte-tested flag
				; ^ = HDAE5000_RAM_SeparateBassPartSent
	.short 2			; RAM 0x23a02e
	.short 0			; RAM 0x23a030
HDAE5000_LyricLines_Init:
	; HDAE5000_RAM_LyricLines: the six text lines of the lyric window, 35 bytes
	; each in v2.01i (40 in v2.06i); HDAE5000_Lyrics_FillLines
	; (hdae5000_ui_display.s) scrolls them up one line before refilling the last
	.zero 210
	.zero 4			; RAM 0x23a104 (set to 1 by HDAE5000_Lyrics_ResetState) and
				; 0x23a106 (HDAE5000_RAM_LyricLoaded)
HDAE5000_LyricBoxObj_Init:
	.long 0xffffffff	; RAM 0x23a108 = HDAE5000_RAM_LyricBoxObj: no lyric box open
	.zero 10		; RAM 0x23a10c (main workspace pointer) + 6 bytes; last byte of
				; the copied image is 0x23a115 = 0x2394ce + 0x0c48 - 1

; ----------------------------------------------------------------------------
; Tail of the ROM (0x2f95e6-0x2fffff)
;   The .data image ends at 0x2f95e5 - HDAE5000_Clear_Work_Buffer copies
;   exactly 0x0c48 bytes.  The 0x000e word at 0x2f95e6 is the first thing
;   past the copied window and is never transferred to RAM; everything after
;   it is 0x00 fill up to the 0x300000 ROM end.
; ----------------------------------------------------------------------------
HDAE5000_Init_Data_End:
	.short 14
	.zero 27160
