; ============================================================================
; HDAE5000 initialised .data image  (HDAE5000_DataSegmentImage .. HDAE5000_Init_Data_End)
;
; HDAE5000_Clear_Work_Buffer copies this block verbatim to RAM 0x23c914, then
; HDAE5000_Handler_Registration publishes six of the tables below to the main
; CPU through workspace[0x0e0a][0x00e4] ("RegisterObjectTable").  Each
; registration passes {class id, proc, entry count, data pointer}; the counts
; quoted there (0x45, 0x0d, 0x0e) are exactly the entry counts of these tables,
; which is how each table boundary below was established.
;
;   ROM        RAM        entries  registered as        contents
;   0x2e0fb6   0x23c914   69       ID 0x012a            object handler entry points
;   0x2e10b6   0x23ca14   69       ID 0x042a            object names (parallel array)
;   0x2e11b6   0x23cb14   13 lists (via HDAE5000_RECORD_TABLE+0x14)  per-class parameter names
;   0x2e1216   0x23cb74   13       ID 0x01ca            EV_* event names
;   0x2e1228   0x23cb86   18       ID 0x01ea            MT_* message names
;   0x2e1262   0x23cbc0   13       ID 0x010a            UI class procedures
;   0x2e128e   0x23cbec   13       ID 0x040a            UI class names (parallel array)
;   0x2e18b0   0x23d20e   14       ID 0x014a            screen procedures
;   0x2e18ec   0x23d24a   14       ID 0x044a            screen names (parallel array)
;
; The 13 class procedures/names are the same 13 UI classes described by
; HDAE5000_RECORD_TABLE (0x29c0aa, 13 x 24 bytes): record+0x00 repeats the
; procedure pointer, +0x0c points at the class name, +0x10 at a per-parameter
; type-signature string and +0x14 at that class's parameter-name list in this
; image.  Signature length == parameter count for all 13 records (11, 2, 0, 0,
; 1, 0, 0, 0, 0, 0, 0, 6, 3 - 23 names plus 13 terminators = the 36 slots at
; 0x2e11b6).
; ============================================================================

HDAE5000_DataSegmentImage:

; --- names that live in already-carved blocks; anchored to their block label
; --- so no byte of those blocks has to move.  (Promote to real labels when
; --- hdae-strings/hdae-slices re-carve them.)
	; HDAE5000_UI_Config + offset  (0x29bfe0-0x29c0a9)
	.set HDAE5000_ParamStr_DbMemoCl_End,          HDAE5000_UI_Config + 0x4c
	.set HDAE5000_ParamStr_AcHddNamingWindow_End, HDAE5000_UI_Config + 0x60
	.set HDAE5000_ParamStr_IvHddNaming_End,       HDAE5000_UI_Config + 0x62
	.set HDAE5000_ParamStr_HDTitleMenu_End,       HDAE5000_UI_Config + 0x6a
	.set HDAE5000_ParamStr_TtlScreenR2_End,       HDAE5000_UI_Config + 0x6c
	.set HDAE5000_ParamStr_AcWindowPage1_End,     HDAE5000_UI_Config + 0x6e
	.set HDAE5000_ParamStr_IvScreenR2_End,        HDAE5000_UI_Config + 0x70
	.set HDAE5000_ParamStr_AcLanguageText1_End,   HDAE5000_UI_Config + 0x72
	; HDAE5000_RECORD_COUNT + offset  (0x29d97e-0x29dc13; note that the last
	; two bytes of that range, 0x29dc12-0x29dc13, are already the first half
	; of the UI object descriptor pool's record #0 - the block boundary here
	; follows the HDAE5000_UI_Descriptors label, which is itself mid-record)
	; HDAE5000_GFX_INIT_PARAMS + offset  (0x2a849a-0x2ba1a5)
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
HDAE5000_ParamNames_AcWindowPage1:
	.long HDAE5000_ParamStr_AcWindowPage1_End	; terminator
HDAE5000_ParamNames_IvScreenR2:
	.long HDAE5000_ParamStr_IvScreenR2_End	; terminator
HDAE5000_ParamNames_AcLanguageText1:
	.long HDAE5000_ParamStr_AcLanguageText1_End	; terminator

; ----------------------------------------------------------------------------
; EV_* event names (registration ID 0x01ca, class id 0x0160000c, ResEventProc)
;   Registered with a run-time count read from HDAE5000_EventName_Count, which
;   is part of this same image (RAM 0x23cb84) rather than an immediate.
; ----------------------------------------------------------------------------
HDAE5000_EventName_Table:
	.long HDAE5000_Str_EV_SeqStop
	.long HDAE5000_Str_EV_AfterLoad
	.long HDAE5000_Str_EV_TimerBack
	.long 0			; end of table
HDAE5000_EventName_Count:
	.short 3

; ----------------------------------------------------------------------------
; MT_* message names (registration ID 0x01ea, class id 0x0160000d, ResMethodProc)
;   Lyrics/file-select message vocabulary shared with the main CPU; count in
;   HDAE5000_MessageName_Count (RAM 0x23cbbe).
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
	.long HDAE5000_Str_MT_SetStrAdr
	.long HDAE5000_Str_MT_LOOP
	.long HDAE5000_Str_MT_SelectDEL
	.long HDAE5000_Str_MT_SelectDelFile
	.long 0			; end of table
HDAE5000_MessageName_Count:
	.short 13

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
	.long HDAE5000_AcWindowPage1Proc
	.long HDAE5000_IvScreenR2Proc
	.long HDAE5000_AcLanguageText1Proc
	.long 0			; end of table

HDAE5000_ClassName_Table:
	.long HDAE5000_Str_SelectListProc
	.long HDAE5000_Str_DbMemoClProc
	.long HDAE5000_Str_TtlScreenRProc
	.long HDAE5000_Str_AcHddNamingWindowProc
	.long HDAE5000_Str_IvHddNamingProc
	.long HDAE5000_Str_HDTitleMenuProc
	.long HDAE5000_Str_TtlScreenR2Proc
	.long HDAE5000_Str_AcWindowPage1Proc
	.long HDAE5000_Str_IvScreenR2Proc
	.long HDAE5000_Str_AcLanguageText1Proc
	.long HDAE5000_Str_End_ClassNames	; empty name terminates the list

; ----------------------------------------------------------------------------
; UI run-time state  (ROM 0x2e12ba-0x2e1659, RAM 0x23cc18)
;
; The initial values of the RAM variables the UI records point at: every field of type
; m / n / r / s (a RAM address) of every object, ROM pool and .data-image records alike,
; points into this block, and no two fields share a variable.  Each variable is labelled
; HdaeUiVar_<object>_<field> after the field that points at it; its size is the distance
; to the next one.  [INFERENCE] what a variable holds is known only from that field's
; firmware name (Screen.window, AcScreenMenu.selected, SelectList.str_adr / sel_num ...);
; no code of this ROM spells one of these RAM addresses (so, [INFERENCE], the main CPU's class procedures
; reach them through the record).  Generated by
; scripts/converters/hdae5000_ui_tree.py.
; SelectList.str_adr variables: 29 of the 31 start at 0x006Fxxxx / 0x0070xxxx.  They are never
; drawn: HDAE5000_SelectListProc draws only when the list's en_paradraw variable is 1, and all
; 31 start at 0; a screen enables its list and gives it its row strings with
; EVT_HDAE_SET_STR_ADR, which overwrites str_adr.  [INFERENCE] the initial values are link-time
; addresses of another build (they move by 680-684 bytes between v2.01i and v2.06i for 16 lists
; and map onto nothing in this image): notes/data-gui-hdae5000-2026-10-29/probes/
; str_adr_initial_values.py.
; ----------------------------------------------------------------------------
HDAE5000_WindowState_Init:
HdaeUiVar_HDDMENU_window:	.long	0xffffffff
HdaeUiVar_HDDMENU_SETUP_TOOLS_selected:	.short	0x0000
HdaeUiVar_HDDMENU_Go_LOAD_BY_NUM_selected:	.short	0x0000
HdaeUiVar_HDDMENU_Go_FLS_SELECT_selected:	.short	0x0000
HdaeUiVar_HDDMENU_COPY_FD_TO_HARD_DISK_selected:	.short	0x0000
HdaeUiVar_HDDMENU_Go_OUTPUT_SETTING_selected:	.short	0x0000
HdaeUiVar_HARD_DISK_OPT_str_adr:	.long	0x00704c71	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_HARD_DISK_OPT_sel_num:	.short	0xffff
HdaeUiVar_HARD_DISK_OPT_en_paradraw:	.short	0x0000
HdaeUiVar_HDDMENU_Go_SELECT_DIR_selected:	.short	0x0000
HdaeUiVar_SETUPS_TOOLS_window:	.long	0xffffffff
HdaeUiVar_SETUPS_TOOLS_AcWindowPage1_page:	.short	0x0001
HdaeUiVar_SELECT_FILE_window:	.long	0xffffffff
HdaeUiVar_SELECT_FILE_AcWindowPage1_page:	.short	0x0001
HdaeUiVar_SELECT_DIR_window:	.long	0xffffffff
HdaeUiVar_SEL_DIR_str_adr:	.long	0x00703f25	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_SEL_DIR_sel_num:	.short	0x0000
HdaeUiVar_SEL_DIR_en_paradraw:	.short	0x0000
HdaeUiVar_SELECT_DIR2_window:	.long	0xffffffff
HdaeUiVar_SELECT_DIR2_Go_SELECT_FILE_selected:	.short	0x0000
HdaeUiVar_SELECT_DIR2_Go_SELECT_FILE_2_selected:	.short	0x0000
HdaeUiVar_FD_FILE_SELECT_window:	.long	0xffffffff
HdaeUiVar_FD_FILE_SELECT_Go_SELECT_FILE_selected:	.short	0x0000
HdaeUiVar_FD_FILE_SELECT_Go_SELECT_FILE_2_selected:	.short	0x0000
HdaeUiVar_FD_FILE_SELECT_SelectList_str_adr:	.long	0x00000000
HdaeUiVar_FD_FILE_SELECT_SelectList_sel_num:	.short	0x0000
HdaeUiVar_FD_FILE_SELECT_SelectList_en_paradraw:	.short	0x0000
HdaeUiVar_HARD_TEST_window:	.long	0xffffffff
HdaeUiVar_RUN_STOP_onoff:	.short	0x0000
HdaeUiVar_PPORT_SW_onoff:	.short	0x0000
HdaeUiVar_FD_SW_onoff:	.short	0x0000
HdaeUiVar_HDD_SW_onoff:	.short	0x0000
HdaeUiVar_HDD_FILE_NAMING_window:	.long	0xffffffff
HdaeUiVar_HD_FILE_NAME_parent:	.long	0xffffffff
HdaeUiVar_HD_FILE_NAME_child:	.long	0xffffffff
HdaeUiVar_HDD_DIR_NAMING_window:	.long	0xffffffff
HdaeUiVar_HD_PLEASE_WIN_parent:	.long	0xffffffff
HdaeUiVar_HD_PLEASE_WIN_child:	.long	0xffffffff
HdaeUiVar_HD_UTIL_window:	.long	0xffffffff
HdaeUiVar_HD_UTIL_FORMAT_selected:	.short	0x0000
HdaeUiVar_HD_UTIL_READ_ID_selected:	.short	0x0000
HdaeUiVar_PC_DATA_LINK_window:	.long	0xffffffff
HdaeUiVar_PP_STATUS_str_adr:	.long	0x00704a13	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_PP_STATUS_sel_num:	.short	0xffff
HdaeUiVar_PP_STATUS_en_paradraw:	.short	0x0000
HdaeUiVar_SETUP_TOOLS_P1_parent:	.long	0xffffffff
HdaeUiVar_SETUP_TOOLS_P1_child:	.long	0xffffffff
HdaeUiVar_SETUP_TOOLS_P1_PC_DATA_LINK_selected:	.short	0x0000
HdaeUiVar_SETUP_TOOLS_P1_WRITE_PROTECT_selected:	.short	0x0000
HdaeUiVar_SETUP_TOOLS_P1_WRITE_PROTECT_data:	.long	0x00000000
HdaeUiVar_SETUP_TOOLS_P1_QUICK_LD_MODE_selected:	.short	0x0000
HdaeUiVar_SETUP_TOOLS_P1_QUICK_LD_MODE_data:	.long	0x00000000
HdaeUiVar_SETUP_TOOLS_P1_JUMP_AFTER_LD_selected:	.short	0x0000
HdaeUiVar_SETUP_TOOLS_P1_JUMP_AFTER_LD_data:	.long	0x00000000
HdaeUiVar_SETUP_TOOLS_P1_WRITE_CONFIRM_selected:	.short	0x0000
HdaeUiVar_SETUP_TOOLS_P1_WRITE_CONFIRM_data:	.long	0x00000000
HdaeUiVar_SETUP_TOOLS_P1_LD_BY_NUM_M_selected:	.short	0x0001
HdaeUiVar_SETUP_TOOLS_P1_LD_BY_NUM_M_data:	.long	0x00000000
HdaeUiVar_SETUP_TOOLS_P2_parent:	.long	0xffffffff
HdaeUiVar_SETUP_TOOLS_P2_child:	.long	0xffffffff
HdaeUiVar_SETUP_TOOLS_P2_SAVE_SETUP_selected:	.short	0x0000
HdaeUiVar_SETUP_TOOLS_P2_HD_AE_INFOS_selected:	.short	0x0000
HdaeUiVar_SW_HD_FORMAT_selected:	.short	0x0000
HdaeUiVar_SETUP_TOOLS_P2_Go_ABOUT_HELP_selected:	.short	0x0000
HdaeUiVar_OUTPUT_SETTING_window:	.long	0xffffffff
HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_selected:	.short	0x0001
HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_data:	.long	0x00000000
HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_2_selected:	.short	0x0000
HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_2_data:	.long	0x00000010
HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_3_selected:	.short	0x0000
HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_3_data:	.long	0x00000000
HdaeUiVar_LOAD_BY_NUM_window:	.long	0xffffffff
HdaeUiVar_LOAD_BY_NUM_AcWindowPage1_page:	.short	0x0001
HdaeUiVar_LBN_P1_parent:	.long	0xffffffff
HdaeUiVar_LBN_P1_child:	.long	0xffffffff
HdaeUiVar_LBN_P1_PsMenuBox_selected:	.short	0x0000
HdaeUiVar_LBN_OPTION_str_adr:	.long	0x0070513c	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_LBN_OPTION_sel_num:	.short	0xffff
HdaeUiVar_LBN_OPTION_en_paradraw:	.short	0x0000
HdaeUiVar_LBN_DIRNO_BOX_str_adr:	.long	0x007048b4	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_LBN_DIRNO_BOX_sel_num:	.short	0xffff
HdaeUiVar_LBN_DIRNO_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_LBN_DIRNAME_BOX_str_adr:	.long	0x007048b9	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_LBN_DIRNAME_BOX_sel_num:	.short	0xffff
HdaeUiVar_LBN_DIRNAME_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_LBN_FILENO_BOX_str_adr:	.long	0x007048cb	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_LBN_FILENO_BOX_sel_num:	.short	0xffff
HdaeUiVar_LBN_FILENO_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_LBN_FILENAME_BOX_str_adr:	.long	0x007048d0	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_LBN_FILENAME_BOX_sel_num:	.short	0xffff
HdaeUiVar_LBN_FILENAME_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_LBN_P2_parent:	.long	0xffffffff
HdaeUiVar_LBN_P2_child:	.long	0xffffffff
HdaeUiVar_LBN_P2_AcRamEditBox_selected:	.short	0x0000
HdaeUiVar_LBN_P2_AcRamEditBox_data:	.long	0x00000000
HdaeUiVar_LBN_P2_CURRENT_PANEL_selected:	.short	0x0001
HdaeUiVar_LBN_P2_CURRENT_PANEL_data:	.long	0x00000002
HdaeUiVar_LBN_P2_PANEL_MEMORY_selected:	.short	0x0001
HdaeUiVar_LBN_P2_PANEL_MEMORY_data:	.long	0x00000002
HdaeUiVar_LBN_P2_SEQUENCER_selected:	.short	0x0001
HdaeUiVar_LBN_P2_SEQUENCER_data:	.long	0x00000002
HdaeUiVar_LBN_P2_COMPOSER_selected:	.short	0x0001
HdaeUiVar_LBN_P2_COMPOSER_data:	.long	0x00000002
HdaeUiVar_LBN_P2_SOUND_MEMORY_selected:	.short	0x0001
HdaeUiVar_LBN_P2_SOUND_MEMORY_data:	.long	0x00000002
HdaeUiVar_LBN_P2_MSP_selected:	.short	0x0001
HdaeUiVar_LBN_P2_MSP_data:	.long	0x00000002
HdaeUiVar_LBN_P2_RHYTHM_CUSTOM_selected:	.short	0x0001
HdaeUiVar_LBN_P2_RHYTHM_CUSTOM_data:	.long	0x00000002
HdaeUiVar_LBN_P2_USER_MIDI_SETTINGS_selected:	.short	0x0001
HdaeUiVar_LBN_P2_USER_MIDI_SETTINGS_data:	.long	0x00000002
HdaeUiVar_CP_FD_window:	.long	0xffffffff
HdaeUiVar_CP_FD_LIST_str_adr:	.long	0x006fdafa	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_CP_FD_LIST_sel_num:	.short	0x0000
HdaeUiVar_CP_FD_LIST_en_paradraw:	.short	0x0000
HdaeUiVar_CP_FD_VOLLABEL_str_adr:	.long	0x006fdaec	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_CP_FD_VOLLABEL_sel_num:	.short	0xffff
HdaeUiVar_CP_FD_VOLLABEL_en_paradraw:	.short	0x0000
HdaeUiVar_CP_FD_DIRSEL_window:	.long	0xffffffff
HdaeUiVar_CP_FD_DIRBOX_str_adr:	.long	0x006fb0f5	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_CP_FD_DIRBOX_sel_num:	.short	0x0000
HdaeUiVar_CP_FD_DIRBOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_SELECT_window:	.long	0xffffffff
HdaeUiVar_SEL_FLS_str_adr:	.long	0x0070411e	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_SEL_FLS_sel_num:	.short	0x0000
HdaeUiVar_SEL_FLS_en_paradraw:	.short	0x0000
HdaeUiVar_HD_FILE_LOAD_P1_parent:	.long	0xffffffff
HdaeUiVar_HD_FILE_LOAD_P1_child:	.long	0xffffffff
HdaeUiVar_HD_FILE_OPTION_str_adr:	.long	0x0070513c	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_HD_FILE_OPTION_sel_num:	.short	0xffff
HdaeUiVar_HD_FILE_OPTION_en_paradraw:	.short	0x0000
HdaeUiVar_HD_FILE_LIST_str_adr:	.long	0x00704d08	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_HD_FILE_LIST_sel_num:	.short	0x0004
HdaeUiVar_HD_FILE_LIST_en_paradraw:	.short	0x0000
HdaeUiVar_FILE_LOAD_DIRBOX_str_adr:	.long	0x00703ed0	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FILE_LOAD_DIRBOX_sel_num:	.short	0xffff
HdaeUiVar_FILE_LOAD_DIRBOX_en_paradraw:	.short	0x0000
HdaeUiVar_HD_FILE_LOAD_P2_parent:	.long	0xffffffff
HdaeUiVar_HD_FILE_LOAD_P2_child:	.long	0xffffffff
HdaeUiVar_HD_FILE_LOAD_P2_CURRENT_PANEL_selected:	.short	0x0001
HdaeUiVar_HD_FILE_LOAD_P2_CURRENT_PANEL_data:	.long	0x00000000
HdaeUiVar_HD_FILE_LOAD_P2_SEQUENCER_selected:	.short	0x0001
HdaeUiVar_HD_FILE_LOAD_P2_SEQUENCER_data:	.long	0x00000000
HdaeUiVar_HD_FILE_LOAD_P2_COMPOSER_selected:	.short	0x0001
HdaeUiVar_HD_FILE_LOAD_P2_COMPOSER_data:	.long	0x00000000
HdaeUiVar_HD_FILE_LOAD_P2_SOUND_MEMORY_selected:	.short	0x0001
HdaeUiVar_HD_FILE_LOAD_P2_SOUND_MEMORY_data:	.long	0x00000000
HdaeUiVar_HD_FILE_LOAD_P2_MSP_2_selected:	.short	0x0001
HdaeUiVar_HD_FILE_LOAD_P2_MSP_2_data:	.long	0x00000000
HdaeUiVar_HD_FILE_LOAD_P2_RHYTHM_CUSTOM_selected:	.short	0x0001
HdaeUiVar_HD_FILE_LOAD_P2_RHYTHM_CUSTOM_data:	.long	0x00000000
HdaeUiVar_HD_FILE_LOAD_P2_USER_MIDI_SETTINGS_selected:	.short	0x0001
HdaeUiVar_HD_FILE_LOAD_P2_USER_MIDI_SETTINGS_data:	.long	0x00000000
HdaeUiVar_HD_FILE_LOAD_P2_AcRamEditBox_selected:	.short	0x0000
HdaeUiVar_HD_FILE_LOAD_P2_AcRamEditBox_data:	.long	0x00000000
HdaeUiVar_HD_FILE_LOAD_P2_PANEL_MEMORY_selected:	.short	0x0001
HdaeUiVar_HD_FILE_LOAD_P2_PANEL_MEMORY_data:	.long	0x00000000
HdaeUiVar_HDD_FLS_NAMING_window:	.long	0xffffffff
HdaeUiVar_FLS_FILE_LOAD_window:	.long	0xffffffff
HdaeUiVar_FLS_OPT_BOX_str_adr:	.long	0x0070513c	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_OPT_BOX_sel_num:	.short	0xffff
HdaeUiVar_FLS_OPT_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_LOC_BOX_str_adr:	.long	0x00703f10	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_LOC_BOX_sel_num:	.short	0xffff
HdaeUiVar_FLS_LOC_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_NAME_BOX_str_adr:	.long	0x00703ef0	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_NAME_BOX_sel_num:	.short	0xffff
HdaeUiVar_FLS_NAME_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_FILE_BOX_str_adr:	.long	0x00704ee9	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_FILE_BOX_sel_num:	.short	0x0000
HdaeUiVar_FLS_FILE_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_DIR_SEL_window:	.long	0xffffffff
HdaeUiVar_FLS_DIR_BOX_str_adr:	.long	0x006fb76d	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_DIR_BOX_sel_num:	.short	0x0000
HdaeUiVar_FLS_DIR_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_FILE_SEL_window:	.long	0xffffffff
HdaeUiVar_FLS_FILE_SEL_DIRBOX_str_adr:	.long	0x006fb718	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_FILE_SEL_DIRBOX_sel_num:	.short	0xffff
HdaeUiVar_FLS_FILE_SEL_DIRBOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_FILE_SEL_LISTBOX_str_adr:	.long	0x006fc564	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_FILE_SEL_LISTBOX_sel_num:	.short	0x0000
HdaeUiVar_FLS_FILE_SEL_LISTBOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_FILE_SEL_OPTBOX_str_adr:	.long	0x006fc998	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_FILE_SEL_OPTBOX_sel_num:	.short	0xffff
HdaeUiVar_FLS_FILE_SEL_OPTBOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_EDIT_window:	.long	0xffffffff
HdaeUiVar_FLS_EDIT_NAME_BOX_str_adr:	.long	0x006fb6dc	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_EDIT_NAME_BOX_sel_num:	.short	0xffff
HdaeUiVar_FLS_EDIT_NAME_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_EDIT_LIST_BOX_str_adr:	.long	0x006fc6e9	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_EDIT_LIST_BOX_sel_num:	.short	0x0000
HdaeUiVar_FLS_EDIT_LIST_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_EDIT_LOC_BOX_str_adr:	.long	0x006fb6fc	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_EDIT_LOC_BOX_sel_num:	.short	0xffff
HdaeUiVar_FLS_EDIT_LOC_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_FLS_EDIT_OPT_BOX_str_adr:	.long	0x006fc93c	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FLS_EDIT_OPT_BOX_sel_num:	.short	0xffff
HdaeUiVar_FLS_EDIT_OPT_BOX_en_paradraw:	.short	0x0000
HdaeUiVar_CP_FD_DIR_NAMING_window:	.long	0xffffffff
HdaeUiVar_Root_AcNamingWindow_parent:	.long	0xffffffff
HdaeUiVar_Root_AcNamingWindow_child:	.long	0xffffffff
HdaeUiVar_SAVE_OPT_SCREEN_window:	.long	0xffffffff
HdaeUiVar_RAM_EDIT_CMP_selected:	.short	0x0001
HdaeUiVar_RAM_EDIT_CMP_data:	.long	0x00000002
HdaeUiVar_SAVE_OPT_SCREEN_AcRamEditBox_selected:	.short	0x0000
HdaeUiVar_SAVE_OPT_SCREEN_AcRamEditBox_data:	.long	0x00000000
HdaeUiVar_RAM_EDIT_LSW_selected:	.short	0x0001
HdaeUiVar_RAM_EDIT_LSW_data:	.long	0x00000002
HdaeUiVar_RAM_EDIT_PMT_selected:	.short	0x0001
HdaeUiVar_RAM_EDIT_PMT_data:	.long	0x00000002
HdaeUiVar_RAM_EDIT_SQT_selected:	.short	0x0001
HdaeUiVar_RAM_EDIT_SQT_data:	.long	0x00000002
HdaeUiVar_RAM_EDIT_TM_selected:	.short	0x0001
HdaeUiVar_RAM_EDIT_TM_data:	.long	0x00000002
HdaeUiVar_RAM_EDIT_MSP_selected:	.short	0x0001
HdaeUiVar_RAM_EDIT_MSP_data:	.long	0x00000002
HdaeUiVar_RAM_EDIT_RCM_selected:	.short	0x0001
HdaeUiVar_RAM_EDIT_RCM_data:	.long	0x00000001
HdaeUiVar_RAM_EDIT_MD_selected:	.short	0x0001
HdaeUiVar_RAM_EDIT_MD_data:	.long	0x00000001
HdaeUiVar_HddNamingWindow_parent:	.long	0xffffffff
HdaeUiVar_HddNamingWindow_child:	.long	0xffffffff
HdaeUiVar_HddNamingCursorBox_cursor:	.short	0x0000
HdaeUiVar_HddNamingABC_onoff:	.short	0x0001
HdaeUiVar_HddNamingabc_onoff:	.short	0x0000
HdaeUiVar_HddNamingSymbol_onoff:	.short	0x0000
HdaeUiVar_FILE_DEL_SCREEN_window:	.long	0xffffffff
HdaeUiVar_DEL_EDIT_LSW_selected:	.short	0x0001
HdaeUiVar_DEL_EDIT_LSW_data:	.long	0x00000002
HdaeUiVar_DEL_EDIT_PMT_selected:	.short	0x0001
HdaeUiVar_DEL_EDIT_PMT_data:	.long	0x00000002
HdaeUiVar_DEL_EDIT_SQT_selected:	.short	0x0001
HdaeUiVar_DEL_EDIT_SQT_data:	.long	0x00000002
HdaeUiVar_DEL_EDIT_CMP_selected:	.short	0x0001
HdaeUiVar_DEL_EDIT_CMP_data:	.long	0x00000002
HdaeUiVar_DEL_EDIT_TM_selected:	.short	0x0001
HdaeUiVar_DEL_EDIT_TM_data:	.long	0x00000002
HdaeUiVar_DEL_EDIT_MSP_selected:	.short	0x0001
HdaeUiVar_DEL_EDIT_MSP_data:	.long	0x00000002
HdaeUiVar_DEL_EDIT_RCM_selected:	.short	0x0001
HdaeUiVar_DEL_EDIT_RCM_data:	.long	0x00000002
HdaeUiVar_DEL_EDIT_MD_selected:	.short	0x0001
HdaeUiVar_DEL_EDIT_MD_data:	.long	0x00000002
HdaeUiVar_FILE_DEL_SCREEN_AcRamEditBox_selected:	.short	0x0000
HdaeUiVar_FILE_DEL_SCREEN_AcRamEditBox_data:	.long	0x00000000
HdaeUiVar_HDD_ICON_DISPLAY_window:	.long	0xffffffff
HdaeUiVar_IV_HDDMENU_window:	.long	0xffffffff
HdaeUiVar_ATTEN_DEL_DIR_window:	.long	0xffffffff
HdaeUiVar_WAIT_DEL_DIR_parent:	.long	0xffffffff
HdaeUiVar_WAIT_DEL_DIR_child:	.long	0xffffffff
HdaeUiVar_ATTEN_DEL_FILE_window:	.long	0xffffffff
HdaeUiVar_ATTEN_OVER_FLS_window:	.long	0xffffffff
HdaeUiVar_ATTEN_DEL_FLS2_window:	.long	0xffffffff
HdaeUiVar_WAIT_DEL_FILE_parent:	.long	0xffffffff
HdaeUiVar_WAIT_DEL_FILE_child:	.long	0xffffffff
HdaeUiVar_ATTEN_HD_FORMAT_window:	.long	0xffffffff
HdaeUiVar_WAIT_HD_FORMAT_parent:	.long	0xffffffff
HdaeUiVar_WAIT_HD_FORMAT_child:	.long	0xffffffff
HdaeUiVar_SETUP_HDINFO_window:	.long	0xffffffff
HdaeUiVar_HD_INFO_LIST_str_adr:	.long	0x00703b39	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_HD_INFO_LIST_sel_num:	.short	0xffff
HdaeUiVar_HD_INFO_LIST_en_paradraw:	.short	0x0000
HdaeUiVar_DBG_MEMO_SCREEN_window:	.long	0xffffffff
HdaeUiVar_ATTEN_DEL_FLS1_window:	.long	0xffffffff
HdaeUiVar_ATTEN_OVER_FILE_window:	.long	0xffffffff
HdaeUiVar_HDD_FLS_NAMING2_window:	.long	0xffffffff
HdaeUiVar_ATTEN_CPHD_WR_window:	.long	0xffffffff
HdaeUiVar_ERR_HD_NOT_FMT_window:	.long	0xffffffff
HdaeUiVar_ERR_HD_SRAM_window:	.long	0xffffffff
HdaeUiVar_ERR_HD_RESET_window:	.long	0xffffffff
HdaeUiVar_ERR_HD_READ_window:	.long	0xffffffff
HdaeUiVar_ERR_HD_ID_READ_window:	.long	0xffffffff
HdaeUiVar_ERR_HD_TRACK_0_window:	.long	0xffffffff
HdaeUiVar_ERR_HD_FAT_window:	.long	0xffffffff
HdaeUiVar_ERR_HD_FSB_window:	.long	0xffffffff
HdaeUiVar_ATTEN_CPFD_MARK_window:	.long	0xffffffff
HdaeUiVar_ABOUT_HELP_window:	.long	0xffffffff
HdaeUiVar_WAIT_TR0_RECOVER_parent:	.long	0xffffffff
HdaeUiVar_WAIT_TR0_RECOVER_child:	.long	0xffffffff
HdaeUiVar_ERR_SAVE_window:	.long	0xffffffff
HdaeUiVar_ERR_LOAD_window:	.long	0xffffffff
HdaeUiVar_ERR_NO_HK_DATA_window:	.long	0xffffffff
HdaeUiVar_ATTEN_FULL_DIR_window:	.long	0xffffffff
HdaeUiVar_ATTEN_CP_UNNAMED_window:	.long	0xffffffff
HdaeUiVar_DIR_OUT_RANGE_window:	.long	0xffffffff
HdaeUiVar_FILE_OUT_RANGE_window:	.long	0xffffffff
HdaeUiVar_HD_PLEASE_window:	.long	0xffffffff
HdaeUiVar_ERR_HD_FORMAT_window:	.long	0xffffffff
HdaeUiVar_AGAIN_HD_FORMAT_window:	.long	0xffffffff
HdaeUiVar_SELECT_FILE_A_Z_window:	.long	0xffffffff
HdaeUiVar_SELECT_FILE_A_Z_AcWindowPage1_page:	.short	0x0001
HdaeUiVar_FILE_LOAD_A_Z_parent:	.long	0xffffffff
HdaeUiVar_FILE_LOAD_A_Z_child:	.long	0xffffffff
HdaeUiVar_FILE_LOAD_A_Z_SelectList_str_adr:	.long	0x00000000
HdaeUiVar_FILE_LOAD_A_Z_SelectList_sel_num:	.short	0x0000
HdaeUiVar_FILE_LOAD_A_Z_SelectList_en_paradraw:	.short	0x0000
HdaeUiVar_FILE_LOAD_A_Z_SelectList_2_str_adr:	.long	0x00702bd8	; inert: not drawn while en_paradraw is 0 (its initial value); screens set it with EVT_HDAE_SET_STR_ADR
HdaeUiVar_FILE_LOAD_A_Z_SelectList_2_sel_num:	.short	0xffff
HdaeUiVar_FILE_LOAD_A_Z_SelectList_2_en_paradraw:	.short	0x0000
HdaeUiVar_Tech_lyrics_window:	.long	0xffffffff

; ----------------------------------------------------------------------------
; The 15 UI objects whose record lives here, i.e. in RAM once the image is copied
; (their tree position is the `ui_ram_object` line in hdae5000_ui_tree.s; the object
; table points at the RAM copy).  Same class macros as the ROM pool.
; ----------------------------------------------------------------------------
	ui_ram_records
	AcIndexEditSw	SELECT_DIR_SW_EDIT, x=265, y=201, w=47, h=18, flag=VF_None, color=CL_Selected, border=BD_3D_UP1, index=4, editsw=ES_Right5, style=SS_Special
	AcScreenMenu	SW_HD_FORMAT, x=163, y=72, w=149, h=26, flag=VF_None, editsw=ES_Right2, selected=HdaeUiVar_SW_HD_FORMAT_selected, screen=NAKA_NO_OBJECT, icon=idICON_Default, str_at=HDAE5000_Str_Alert_HDFormat
	AcIndexEditSw	COPY_HD_SW_TO, x=265, y=30, w=47, h=26, flag=VF_None, border=BD_3D_UP1, index=3, editsw=ES_Right1, style=SS_Special
	AcIndexEditSw	COPY_HD_SW_SELECT, x=265, y=202, w=47, h=18, flag=VF_None, color=CL_Selected, border=BD_3D_DOWN2, index=4, font=idCHARA4, editsw=ES_Right5, style=SS_Special
	AcIndexEditSw	FLS_SELECT_SW_EDIT, x=265, y=201, w=47, h=18, flag=VF_None, color=CL_Selected, border=BD_3D_UP1, index=4, editsw=ES_Right5, style=SS_Special
	AcIndexEditSw	HD_FILE_LOAD_SW_SAVE, x=265, y=203, w=47, h=18, flag=VF_None, color=CL_Selected, border=BD_3D_UP1, index=4, editsw=ES_Right5, style=SS_Special
	AcIndexEditSw	HD_FILE_LOAD_SW_DEL, x=8, y=30, w=34, h=26, flag=VF_None, color=CL_Selected, border=BD_3D_DOWN1, index=7, editsw=ES_Left1, style=SS_Special
	AcIndexEditSw	HD_FILE_LOAD_SW_DELFILE, x=8, y=114, w=34, h=26, flag=VF_None, color=CL_Selected, border=BD_3D_DOWN1, index=5, editsw=ES_Left3, style=SS_Special
	AcIndexEditSw	HD_FILE_LOAD_P2_AcIndexEditSw_9, x=9, y=160, w=31, h=18, flag=VF_None, border=BD_3D_UP1, index=4, editsw=ES_Left4, style=SS_Special
	AcIndexEditSw	FLS_FILE_LOAD_SW_EDIT, x=265, y=201, w=47, h=18, flag=VF_None, color=CL_Selected, border=BD_3D_UP1, index=4, editsw=ES_Right5, style=SS_Special
	AcIndexToggle	HddNamingABC, x=84, y=216, w=32, h=23, onoff=HdaeUiVar_HddNamingABC_onoff, editsw=ES_Bottom3, tag=0, stron_at=HDAE5000_Str_CharSet_Upper_2, stroff_at=HDAE5000_Str_CharSet_Upper_1
	AcIndexToggle	HddNamingabc, x=124, y=216, w=32, h=23, onoff=HdaeUiVar_HddNamingabc_onoff, editsw=ES_Bottom4, tag=1, stron_at=HDAE5000_Str_CharSet_Lower_2, stroff_at=HDAE5000_Str_CharSet_Lower_1
	AcIndexToggle	HddNamingSymbol, x=164, y=216, w=32, h=23, onoff=HdaeUiVar_HddNamingSymbol_onoff, editsw=ES_Bottom5, tag=2, stron_at=HDAE5000_Str_CharSet_Symbol_2, stroff_at=HDAE5000_Str_CharSet_Symbol_1
	IvExitScreen	ERR_SAVE_EXIT, x=0, y=0, w=32, h=32, flag=VF_InvisibleBox, screen=NAKA_NO_OBJECT
	IvExitScreen	ERR_LOAD_EXIT, x=0, y=0, w=32, h=32, flag=VF_InvisibleBox, screen=NAKA_NO_OBJECT
	ui_ram_records_end

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
; File/name editing buffers (v1.x has no file-format version words in front of them)
; ----------------------------------------------------------------------------
HDAE5000_Name_ColumnRuler:
	.asciz "123456789012345678901234567890"
	.byte 0x00		; 16-bit alignment pad
HDAE5000_Name_EditBuffer:
	.asciz "                              "	; 30 columns, blank-filled
	.byte 0x00		; 16-bit alignment pad
HDAE5000_Browser_State:
	; RAM 0x23d2c6 is the row-base offset added to every browser row address;
	; the next words are the browser cursors (0x23d2ce is the display row base).
	.short 0, 0, 0, 0, 0, 0, 0
	.short 127			; RAM 0x23d2d4, not read anywhere in this ROM
	.short 0			; RAM 0x23d2d6, byte-tested flag
				; ^ = HDAE5000_RAM_SeparateBassPart (0 = NONE): the value of
				;   SeparateBassPartCheck, used by HDAE5000_SeparateOutput_Apply
HDAE5000_Browser_PageRows:
	; ^ name not supported by the code: 0x23d2d8 is HDAE5000_RAM_SeparateDrumPart
	;   (SeparateDrumPartCheck's value, initially 16) and 0x23d2da the drum part
	;   last sent (HDAE5000_RAM_SeparateDrumPartSent); see HDAE5000_SeparateOutput_Apply.
	.short 16, 16		; RAM 0x23d2d8/0x23d2da
	.short 0			; RAM 0x23d2dc, byte-tested flag
				; ^ = HDAE5000_RAM_SeparateBassPartSent
	.zero 10		; HDAE5000_RAM_MainWorkspacePtr's slot + 6 bytes; the copied image ends here

; ----------------------------------------------------------------------------
; Tail of the ROM
;   The .data image ends here: the boot copy loop copies it from HDAE5000_DataSegmentImage
;   up to HDAE5000_Init_Data_End, which the ROM header's second long also names.  The
;   0x000e word after it is the first thing past the copied window and is never
;   transferred to RAM; everything after it is 0x00 fill up to the 0x300000 ROM end.
; ----------------------------------------------------------------------------
HDAE5000_Init_Data_End:
	.short 14
	.zero 124532

; ----------------------------------------------------------------------------
; RAM addresses of the image labels the code reaches: the image is copied to
; HDAE5000_DATA_COPY_DEST, so HDAE5000_RAM_<name> follows HDAE5000_<name>.  The
; code spells its RAM operands with these (scripts/converters/hdae5000_ram_image_refs.py).
; ----------------------------------------------------------------------------
