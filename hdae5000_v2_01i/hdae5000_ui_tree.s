; =============================================================================
; HD-AE5000 v2.01i GUI: the UI objects of Viewable table 0x7F, as a tree
; =============================================================================
; GENERATED from the v2.01i image by scripts/converters/hdae5000_ui_tree.py, then
; source: edit it here.  The macros are hdae5000/shared/naka_ui_macros.s (how to
; read a line: its header).  786 objects in 78 top-level trees; 20 of them keep
; their record in the .data image (`ui_ram_object` lines here, the records in
; hdae5000_init_data.s).  The ROM pool runs 0x29D4B2-0x2A5557; then the object table,
; the name table and the name pool, all generated from this tree.  Index of every
; screen, its children and where each leads: notes/data-gui-hdae5000-2026-10-29/
; menu-map-v2_01i.md (scripts/analysis/hdae5000_menu_map.py).
;
; What the record layout rests on (evidence, all from the ROM):
;  * every record starts with its class id 0x016S_KKKK: Class table 0x16S, entry KKKK
;    (ClassProc); 0x160 = the main CPU's root classes, 0x16A = this ROM's own 13
;    (HDAE5000_RECORD_TABLE).  A record's fields are its class chain's propname fields;
;    the class's allsize is exactly where the inline captions start, for every record;
;  * Viewable +4 super, +6 sub, +8 next, +10 prev are object indices; the table is the
;    preorder walk of the forest they describe, with no exception in either version
;    (analysis/wave7-probes/verify_hdae5000_ui_pool.py; probes in the notes);
;  * +14 rect is x1, y1, x2, y2: the 769 v2.06i pool records all satisfy x1 <= x2 <= 321,
;    y1 <= y2 <= 239 at +14 and at no other offset (same probe); record 0 is 0,0-319,239.
; =============================================================================

	.include	"shared/naka_ui_macros.s"

; HD-AE5000 function ids the records name and shared/event_codes.s does not: entry k of
; its ApFunction table 0x12A (HDAE5000_ObjHandler_Table, names HDAE5000_ObjName_Table)
; is 0x012A0000 + k, of its MainFunction table 0x14A (HDAE5000_ScreenProc_Table, names
; HDAE5000_ScreenName_Table) 0x014A0000 + k.  The procedure is HDAE5000_<name>.
	.equ	NAKA_APFUNC_HardTestPage, 0x012a0000
	.equ	NAKA_APFUNC_HDD_UTIL_PAGE, 0x012a0003
	.equ	NAKA_APFUNC_PC_DATA_LINK_PAGE, 0x012a0004
	.equ	NAKA_APFUNC_SeparateOutputModeCheck, 0x012a0005
	.equ	NAKA_APFUNC_SaveOptNameCheck, 0x012a0006
	.equ	NAKA_APFUNC_FileOptNameCheck, 0x012a0007
	.equ	NAKA_APFUNC_SfxLswBitCheck, 0x012a0008
	.equ	NAKA_APFUNC_SfxPmtBitCheck, 0x012a0009
	.equ	NAKA_APFUNC_SfxSqtBitCheck, 0x012a000a
	.equ	NAKA_APFUNC_SfxCmpBitCheck, 0x012a000b
	.equ	NAKA_APFUNC_SfxTmBitCheck, 0x012a000c
	.equ	NAKA_APFUNC_SfxMspBitCheck, 0x012a000d
	.equ	NAKA_APFUNC_SfxRcmBitCheck, 0x012a000e
	.equ	NAKA_APFUNC_SfxMdBitCheck, 0x012a000f
	.equ	NAKA_APFUNC_SfxTlxBitCheck, 0x012a0010
	.equ	NAKA_APFUNC_WriteProtectEditCheck, 0x012a0011
	.equ	NAKA_APFUNC_WriteConfirmEditCheck, 0x012a0012
	.equ	NAKA_APFUNC_QuickLoadModeEditCheck, 0x012a0013
	.equ	NAKA_APFUNC_LoadByNumberModeEditCheck, 0x012a0014
	.equ	NAKA_APFUNC_JumpAfterLoadModeEditCheck, 0x012a0015
	.equ	NAKA_APFUNC_HdTitleEventCatch, 0x012a0016
	.equ	NAKA_APFUNC_FlsNamingCheck2, 0x012a0018
	.equ	NAKA_APFUNC_WrConfirmEventCatch, 0x012a001a
	.equ	NAKA_APFUNC_SaveOptSwEventCatch, 0x012a001b
	.equ	NAKA_APFUNC_DelOptSwEventCatch, 0x012a001c
	.equ	NAKA_APFUNC_DelOptNameCheck, 0x012a001d
	.equ	NAKA_APFUNC_DelLswEditCheck, 0x012a001e
	.equ	NAKA_APFUNC_DelPmtEditCheck, 0x012a001f
	.equ	NAKA_APFUNC_DelSqtEditCheck, 0x012a0020
	.equ	NAKA_APFUNC_DelCmpEditCheck, 0x012a0021
	.equ	NAKA_APFUNC_DelTmEditCheck, 0x012a0022
	.equ	NAKA_APFUNC_DelMspEditCheck, 0x012a0023
	.equ	NAKA_APFUNC_DelRcmEditCheck, 0x012a0024
	.equ	NAKA_APFUNC_DelMdEditCheck, 0x012a0025
	.equ	NAKA_APFUNC_DelTlxEditCheck, 0x012a0026
	.equ	NAKA_APFUNC_BitmapHdd_icon, 0x012a0027
	.equ	NAKA_APFUNC_LBNPage1SwCatch, 0x012a0028
	.equ	NAKA_APFUNC_LBNLoadSwCatch, 0x012a0029
	.equ	NAKA_APFUNC_FileLBNNameCheck, 0x012a002a
	.equ	NAKA_APFUNC_LBNLswBitCheck, 0x012a002b
	.equ	NAKA_APFUNC_LBNPmtBitCheck, 0x012a002c
	.equ	NAKA_APFUNC_LBNSqtBitCheck, 0x012a002d
	.equ	NAKA_APFUNC_LBNCmpBitCheck, 0x012a002e
	.equ	NAKA_APFUNC_LBNTmBitCheck, 0x012a002f
	.equ	NAKA_APFUNC_LBNMspBitCheck, 0x012a0030
	.equ	NAKA_APFUNC_LBNRcmBitCheck, 0x012a0031
	.equ	NAKA_APFUNC_LBNMdBitCheck, 0x012a0032
	.equ	NAKA_APFUNC_FlsFileLoadSwCatch, 0x012a0033
	.equ	NAKA_APFUNC_AttenDelDirSwCatch, 0x012a0034
	.equ	NAKA_APFUNC_AttenDelFileSwCatch, 0x012a0035
	.equ	NAKA_APFUNC_AttenHDFormatSwCatch, 0x012a0036
	.equ	NAKA_APFUNC_AttenCpToHDSwCatch, 0x012a0037
	.equ	NAKA_APFUNC_AttenCpToMarkSwCatch, 0x012a0038
	.equ	NAKA_APFUNC_FlsDel1SwCatch, 0x012a0039
	.equ	NAKA_APFUNC_FlsDel2SwCatch, 0x012a003a
	.equ	NAKA_APFUNC_FlsOverWrSwCatch, 0x012a003b
	.equ	NAKA_APFUNC_SeparateDrumPartCheck, 0x012a003c
	.equ	NAKA_APFUNC_SeparateBassPartCheck, 0x012a003d
	.equ	NAKA_APFUNC_ErrMsgTimerCatch, 0x012a003e
	.equ	NAKA_APFUNC_ErrMsgTimerCatchLBN, 0x012a003f
	.equ	NAKA_APFUNC_LanguageTextReturn, 0x012a0040
	.equ	NAKA_APFUNC_LyricJumpEditCheck, 0x012a0042
	.equ	NAKA_MAINFUNC_SEL_DIR_Screen, 0x014a0001
	.equ	NAKA_MAINFUNC_FILE_LOAD_Screen, 0x014a0002
	.equ	NAKA_MAINFUNC_FILE_Naming_Screen, 0x014a0003
	.equ	NAKA_MAINFUNC_SetupP2SwCatch, 0x014a0004
	.equ	NAKA_MAINFUNC_SelectFlsScreen, 0x014a0005
	.equ	NAKA_MAINFUNC_FlsLoadScreen, 0x014a0006
	.equ	NAKA_MAINFUNC_FlsEditScreen, 0x014a0007
	.equ	NAKA_MAINFUNC_FlsDirSelScreen, 0x014a0008
	.equ	NAKA_MAINFUNC_FlsFileSelScreen, 0x014a0009
	.equ	NAKA_MAINFUNC_CopyToHDScreen, 0x014a000a
	.equ	NAKA_MAINFUNC_CopyToHDDirSelScreen, 0x014a000b
	.equ	NAKA_MAINFUNC_HDDTitleSwCatch, 0x014a000c
	.equ	NAKA_MAINFUNC_FileLoadSwCatch, 0x014a000d

; -----------------------------------------------------------------------------
; HDDMENU -- TtlScreenR "HD-AE5000"
; opened by: SETUPS_TOOLS_Exit_HDDMENU.screen, SELECT_DIR_Exit_HDDMENU.screen,
;            HARD_TEST_Exit_HDDMENU.screen, HARD_TEST_Exit_HDDMENU_2.screen,
;            OUTPUT_SETTING_Exit_HDDMENU.screen, LOAD_BY_NUM_Exit_HDDMENU.screen,
;            CP_FD_Exit_HDDMENU.screen, FLS_SELECT_Exit_HDDMENU.screen,
;            DBG_MEMO_SCREEN_Exit_HDDMENU.screen, Tech_lyrics_Exit_HDDMENU.screen,
;            HDAE5000_AttenCpToHDSwCatch, HDAE5000_HDAETitleFunc
; -----------------------------------------------------------------------------
	TtlScreenR	HDDMENU, x=0, y=0, w=320, h=240, exit=TITLE_DKMENU, window=HdaeUiVar_HDDMENU_window, icon=idICON_i129, title="HD-AE5000"
	ui_sub
		AcScreenMenu	HDDMENU_SETUP_TOOLS, x=8, y=72, w=149, h=26, editsw=ES_Left2, selected=HdaeUiVar_HDDMENU_SETUP_TOOLS_selected, screen=HDAE5000_OBJ_SETUPS_TOOLS, icon=idICON_i6, str="SETUP & TOOLS  "
		AcScreenMenu	HDDMENU_Go_LOAD_BY_NUM, x=163, y=114, w=149, h=26, editsw=ES_Right3, selected=HdaeUiVar_HDDMENU_Go_LOAD_BY_NUM_selected, screen=HDAE5000_OBJ_LOAD_BY_NUM, icon=idICON_i172, str=""
		ui_sub
			AcLanguageText1	HDDMENU_Go_LOAD_BY_NUM_Text, x=170, y=114, w=112, h=32, index=6, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=2	; EN "LOAD BY     NUMBER"
		ui_endsub
		AcScreenMenu	HDDMENU_Go_FLS_SELECT, x=163, y=156, w=149, h=26, align=AL_RightJustify, editsw=ES_Right4, selected=HdaeUiVar_HDDMENU_Go_FLS_SELECT_selected, screen=HDAE5000_OBJ_FLS_SELECT, icon=idICON_i173, str=""
		ui_sub
			AcLanguageText1	HDDMENU_Go_FLS_SELECT_Text, x=170, y=156, w=112, h=32, index=7, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=2	; EN "SELECT FILE LOAD SCRIPT"
		ui_endsub
		AcScreenMenu	HDDMENU_COPY_FD_TO_HARD_DISK, x=8, y=114, w=149, h=26, editsw=ES_Left3, selected=HdaeUiVar_HDDMENU_COPY_FD_TO_HARD_DISK_selected, screen=NAKA_NO_OBJECT, icon=idICON_i113, str=""
		ui_sub
			AcLanguageText1	HDDMENU_COPY_FD_TO_HARD_DISK_Text, x=36, y=114, w=125, h=32, index=3, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=2	; EN "COPY FD TO HARD DISK"
		ui_endsub
		AcScreenMenu	HDDMENU_Go_OUTPUT_SETTING, x=8, y=156, w=149, h=26, editsw=ES_Left4, selected=HdaeUiVar_HDDMENU_Go_OUTPUT_SETTING_selected, screen=HDAE5000_OBJ_OUTPUT_SETTING, icon=idICON_i31, str=""
		ui_sub
			AcLanguageText1	HDDMENU_Go_OUTPUT_SETTING_Text, x=36, y=156, w=125, h=32, index=4, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1	; EN "OUTPUT SETTING"
		ui_endsub
		SelectList	HARD_DISK_OPT, x=8, y=188, w=302, h=50, color=CL_WallPattern, index=100, str_adr=HdaeUiVar_HARD_DISK_OPT_str_adr, row=3, sel_num=HdaeUiVar_HARD_DISK_OPT_sel_num, en_paradraw=HdaeUiVar_HARD_DISK_OPT_en_paradraw
		IvCatchEvent	HDDMENU_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_HdTitleEventCatch
		IvMainEditSw	HDDMENU_IvMainEditSw, x=32, y=0, w=32, h=32, func=NAKA_MAINFUNC_HDDTitleSwCatch
		VwUserBitmap	HDDMENU_VwUserBitmap, x=93, y=1, w=27, h=27
		AcScreenMenu	HDDMENU_Go_SELECT_DIR, x=163, y=72, w=149, h=26, align=AL_LeftJustify, editsw=ES_Right2, selected=HdaeUiVar_HDDMENU_Go_SELECT_DIR_selected, screen=HDAE5000_OBJ_SELECT_DIR, icon=idICON_i171, str=""
		ui_sub
			AcLanguageText1	HDDMENU_Go_SELECT_DIR_Text, x=170, y=72, w=112, h=32, index=5, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=2	; EN "SELECT BY   NAME    "
		ui_endsub
		AcLanguageText1	HDDMENU_Evaluation_01_01_99, x=40, y=40, w=240, h=18, index=62, font=idCHARA1W, fontcolor=CL_Text, lines=1	; EN "Evaluation 01-01-99"
		AcScreenMenu	HDDMENU_Go_Tech_lyrics, x=310, y=30, w=5, h=26, align=AL_LeftJustify, editsw=ES_Right1, selected=HdaeUiVar_HDDMENU_Go_Tech_lyrics_selected, screen=HDAE5000_OBJ_Tech_lyrics, icon=idICON_None, str=""
		ui_sub
			AcLanguageText1	HDDMENU_Go_Tech_lyrics_Text, x=170, y=72, w=112, h=32, index=5, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=2	; EN "SELECT BY   NAME    "
		ui_endsub
		TextBox	HDDMENU_LYRIC_WINDOW, x=273, y=34, w=46, h=20, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_LightGreen, alignment=AL_LeftJustify, lines=2, text="LYRIC WINDOW"
	ui_endsub

; -----------------------------------------------------------------------------
; SETUPS_TOOLS -- TtlScreenR " SETUP & TOOLS "
; opened by: HDDMENU_SETUP_TOOLS.screen, HD_UTIL_Exit_SETUPS_TOOLS.screen,
;            SETUP_HDINFO_Exit_SETUPS_TOOLS.screen, ABOUT_HELP_Exit_SETUPS_TOOLS.screen,
;            LyrSettings_Exit_SETUPS_TOOLS.screen, HDAE5000_PC_DATA_LINK_PAGE,
;            HDAE5000_SetupP2SwCatch, HDAE5000_AttenHDFormatSwCatch_OnCancel
; -----------------------------------------------------------------------------
	TtlScreenR	SETUPS_TOOLS, x=0, y=0, w=320, h=240, exit=TITLE_HDDEXT, window=HdaeUiVar_SETUPS_TOOLS_window, icon=idICON_i6, title=" SETUP & TOOLS "
	ui_sub
		IvExitScreen	SETUPS_TOOLS_Exit_HDDMENU, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		IvPageControl	SETUPS_TOOLS_Page_SETUP_TOOLS_P2, x=31, y=30, w=32, h=32, page=2, window=HDAE5000_OBJ_SETUP_TOOLS_P2
		IvPageControl	SETUPS_TOOLS_Page_SETUP_TOOLS_P1, x=0, y=31, w=32, h=32, page=1, window=HDAE5000_OBJ_SETUP_TOOLS_P1
		AcWindowPage1	SETUPS_TOOLS_AcWindowPage1, x=245, y=6, w=71, h=18, page=HdaeUiVar_SETUPS_TOOLS_AcWindowPage1_page
	ui_endsub

; -----------------------------------------------------------------------------
; SELECT_FILE -- TtlScreenR2
; opened by: SELECT_DIR2_Go_SELECT_FILE.screen, SELECT_DIR2_Go_SELECT_FILE_2.screen,
;            FD_FILE_SELECT_Go_SELECT_FILE.screen, FD_FILE_SELECT_Go_SELECT_FILE_2.screen,
;            HDD_FILE_NAMING_Exit_SELECT_FILE.screen, FILE_DEL_SCREEN_Exit_SELECT_FILE.screen,
;            HDAE5000_HDAETitleFunc, HDAE5000_SEL_DIR_Screen, HDAE5000_AttenDelDirSwCatch_Join,
;            HDAE5000_AttenDelDirSwCatch_Skip, HDAE5000_AttenDelFileSwCatch_Join,
;            HDAE5000_FileLoadSwCatch_Join, HDAE5000_HDDNamingCheck_Join,
;            HDAE5000_SaveOptSwEventCatch_Skip, HDAE5000_WrConfirmEventCatch
; -----------------------------------------------------------------------------
	TtlScreenR2	SELECT_FILE, x=0, y=0, w=320, h=240, exit=TITLE_HDDEXT, window=HdaeUiVar_SELECT_FILE_window, icon=idICON_None, title=""
	ui_sub
		IvExitScreen	SELECT_FILE_Exit_SELECT_DIR, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_SELECT_DIR
		IvPageControl	HD_FILE_LOAD, x=0, y=32, w=32, h=32, page=1, window=HDAE5000_OBJ_HD_FILE_LOAD_P1
		IvPageControl	HD_LOAD_OPTION, x=0, y=64, w=32, h=32, page=2, window=HDAE5000_OBJ_HD_FILE_LOAD_P2
		AcIndexEditSw	SELECT_FILE_AcIndexEditSw, x=265, y=36, w=47, h=26, border=BD_3D_UP1, index=0xffff, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	SELECT_FILE_AcIndexEditSw_LOAD, x=270, y=40, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="LOAD"
		ui_endsub
		Line	SELECT_FILE_Line, x=313, y=40, w=1, h=40, color=CL_EditSw
		EditSw	SELECT_FILE_80, x=310, y=77, w=10, h=17, index=0xffff, str="~80"
		IvMainEditSw	SELECT_FILE_IvMainEditSw, x=0, y=96, w=32, h=32, func=NAKA_MAINFUNC_FileLoadSwCatch
		AcWindowPage1	SELECT_FILE_AcWindowPage1, x=245, y=6, w=71, h=18, page=HdaeUiVar_SELECT_FILE_AcWindowPage1_page
	ui_endsub

; -----------------------------------------------------------------------------
; SELECT_DIR -- TtlScreenR2 "HD DIR SELECT"
; opened by: HDDMENU_Go_SELECT_DIR.screen, SELECT_FILE_Exit_SELECT_DIR.screen,
;            HDD_DIR_NAMING_Exit_SELECT_DIR.screen, SELECT_FILE_A_Z_Exit_SELECT_DIR.screen,
;            HDAE5000_HDD_DIRNAMECheck_Skip
; -----------------------------------------------------------------------------
	TtlScreenR2	SELECT_DIR, x=0, y=0, w=320, h=240, window=HdaeUiVar_SELECT_DIR_window, icon=idICON_i171, title="HD DIR SELECT"
	ui_sub
		AcIndexWideES	SELECT_DIR_AcIndexWideES, x=84, y=222, w=112, h=18, index=0
		IvMainEditSw	SELECT_DIR_IvMainEditSw, x=0, y=0, w=32, h=32, func=NAKA_MAINFUNC_SEL_DIR_Screen
		SelectList	SEL_DIR, x=8, y=35, w=256, h=176, color=CL_DarkGray, index=0, main_func=NAKA_MAINFUNC_SEL_DIR_Screen, str_adr=HdaeUiVar_SEL_DIR_str_adr, column=2, row=12, sel_num=HdaeUiVar_SEL_DIR_sel_num, dial=1, auto_inc=1, en_paradraw=HdaeUiVar_SEL_DIR_en_paradraw
		VwEditSwBox	SELECT_DIR_97_120, x=281, y=222, w=38, h=18, color=CL_WallPattern, str="97-120"
		VwEditSwBox	SELECT_DIR_01_24, x=1, y=222, w=38, h=18, color=CL_WallPattern, editsw=ES_Bottom1, str="01-24"
		VwEditSwBox	SELECT_DIR_25_48, x=43, y=222, w=38, h=18, color=CL_WallPattern, str="25-48"
		VwEditSwBox	SELECT_DIR_49_72, x=199, y=222, w=38, h=18, color=CL_WallPattern, str="49-72"
		VwEditSwBox	SELECT_DIR_73_96, x=240, y=222, w=38, h=18, color=CL_WallPattern, str="73-96"
		AcIndexEditSw	SELECT_DIR_AcIndexEditSw, x=265, y=36, w=47, h=26, border=BD_3D_UP1, index=3, editsw=ES_Right1, style=SS_OK
		ui_ram_object	SELECT_DIR_SW_EDIT, AcIndexEditSw
		ui_sub
			Label	SELECT_DIR_SW_EDIT_EDIT, x=271, y=202, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="EDIT"
		ui_endsub
		IvExitScreen	SELECT_DIR_Exit_HDDMENU, x=32, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		EditSw	SELECT_DIR_80, x=310, y=77, w=10, h=19, index=6, str="~80"
		Line	SELECT_DIR_Line, x=313, y=40, w=1, h=40, color=CL_EditSw
	ui_endsub

; -----------------------------------------------------------------------------
; SELECT_DIR2 -- TtlScreenR2 " DIRECTORY SELECT   "
; -----------------------------------------------------------------------------
	TtlScreenR2	SELECT_DIR2, x=0, y=0, w=320, h=240, window=HdaeUiVar_SELECT_DIR2_window, icon=idICON_i129, title=" DIRECTORY SELECT   "
	ui_sub
		AcScreenMenu	SELECT_DIR2_Go_SELECT_FILE, x=266, y=38, w=46, h=24, color=CL_Silver, border=BD_3D_UP1, editsw=ES_Right1, selected=HdaeUiVar_SELECT_DIR2_Go_SELECT_FILE_selected, screen=HDAE5000_OBJ_SELECT_FILE, icon=idICON_None, str=""
		ui_sub
			Label	SELECT_DIR2_Go_SELECT_FILE_OK, x=278, y=42, w=20, h=19, font=idCHARA1, fontcolor=CL_Black, str="OK"
		ui_endsub
		AcIndexWideES	SELECT_DIR2_AcIndexWideES, x=84, y=220, w=112, h=18, index=1
		AcIndexEditSw	SELECT_DIR2_AcIndexEditSw, x=44, y=220, w=32, h=18, index=3, editsw=ES_Bottom2, style=SS_Left2
		AcScreenMenu	SELECT_DIR2_Go_SELECT_FILE_2, x=266, y=77, w=40, h=32, color=CL_WallPattern, editsw=ES_Right2, selected=HdaeUiVar_SELECT_DIR2_Go_SELECT_FILE_2_selected, screen=HDAE5000_OBJ_SELECT_FILE, icon=idICON_None, str=""
		ui_sub
			Label	SELECT_DIR2_Go_SELECT_FILE_2_OK, x=278, y=42, w=20, h=19, font=idCHARA1, fontcolor=CL_Black, str="OK"
		ui_endsub
		Line	SELECT_DIR2_Line, x=313, y=44, w=1, h=40
		AcIndexEditSw	SELECT_DIR2_AcIndexEditSw_2, x=204, y=220, w=32, h=18, index=2, editsw=ES_Bottom6, style=SS_Right2
	ui_endsub

; -----------------------------------------------------------------------------
; FD_FILE_SELECT -- TtlScreenR2 " FD FILE SELECT   "
; -----------------------------------------------------------------------------
	TtlScreenR2	FD_FILE_SELECT, x=0, y=0, w=320, h=240, exit=TITLE_HDDEXT, window=HdaeUiVar_FD_FILE_SELECT_window, icon=idICON_i129, title=" FD FILE SELECT   "
	ui_sub
		AcScreenMenu	FD_FILE_SELECT_Go_SELECT_FILE, x=266, y=38, w=46, h=24, color=CL_Silver, border=BD_3D_UP1, editsw=ES_Right1, selected=HdaeUiVar_FD_FILE_SELECT_Go_SELECT_FILE_selected, screen=HDAE5000_OBJ_SELECT_FILE, icon=idICON_None, str=""
		ui_sub
			Label	FD_FILE_SELECT_Go_SELECT_FILE_COPY, x=270, y=41, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="COPY"
		ui_endsub
		AcIndexWideES	FD_FILE_SELECT_AcIndexWideES, x=84, y=220, w=112, h=18, index=1
		AcIndexEditSw	FD_FILE_SELECT_AcIndexEditSw, x=44, y=220, w=32, h=18, index=3, editsw=ES_Bottom2, style=SS_Left2
		AcScreenMenu	FD_FILE_SELECT_Go_SELECT_FILE_2, x=266, y=77, w=40, h=32, color=CL_WallPattern, editsw=ES_Right2, selected=HdaeUiVar_FD_FILE_SELECT_Go_SELECT_FILE_2_selected, screen=HDAE5000_OBJ_SELECT_FILE, icon=idICON_None, str=""
		Line	FD_FILE_SELECT_Line, x=313, y=44, w=1, h=40
		AcIndexEditSw	FD_FILE_SELECT_AcIndexEditSw_2, x=204, y=220, w=32, h=18, index=2, editsw=ES_Bottom6, style=SS_Right2
		AcIndexWideES	FD_FILE_SELECT_AcIndexWideES_2, x=244, y=220, w=72, h=18, index=4, editsw=ES_Bottom7, editsw2=ES_Bottom8, style=SS_Special
		ui_sub
			Label	FD_FILE_SELECT_AcIndexWideES_2_SELECT, x=254, y=221, w=52, h=19, font=idCHARA1, fontcolor=CL_Black, str="SELECT"
		ui_endsub
		SelectList	FD_FILE_SELECT_SelectList, x=40, y=52, w=200, h=156, color=CL_Green, border=BD_3D_UP2, index=1, font=idCHARA1, str_adr=HdaeUiVar_FD_FILE_SELECT_SelectList_str_adr, column=2, row=10, sel_num=HdaeUiVar_FD_FILE_SELECT_SelectList_sel_num, en_paradraw=HdaeUiVar_FD_FILE_SELECT_SelectList_en_paradraw
	ui_endsub

; -----------------------------------------------------------------------------
; HARD_TEST -- TtlScreenR2 "HARDWARE TEST"
; -----------------------------------------------------------------------------
	TtlScreenR2	HARD_TEST, x=0, y=0, w=320, h=240, window=HdaeUiVar_HARD_TEST_window, icon=idICON_i129, title="HARDWARE TEST"
	ui_sub
		IvExitScreen	HARD_TEST_Exit_HDDMENU, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		ui_sub
			IvCatchEvent	HARD_TEST_Exit_HDDMENU_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_HardTestPage
		ui_endsub
		IvExitScreen	HARD_TEST_Exit_HDDMENU_2, x=32, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		PsToggleBox	RUN_STOP, x=265, y=202, w=47, h=18, onoff=HdaeUiVar_RUN_STOP_onoff, editsw=ES_Right5, stron="STOP", stroff="RUN"
		DbMemoCl	HARD_TEST_DbMemoCl, x=0, y=32, w=231, h=208, flag=VF_Const, color=CL_Black, fontcolor=CL_White
		PsToggleBox	PPORT_SW, x=265, y=76, w=47, h=18, onoff=HdaeUiVar_PPORT_SW_onoff, editsw=ES_Right2, stron="PPORT", stroff="PPORT"
		PsToggleBox	FD_SW, x=281, y=160, w=31, h=18, onoff=HdaeUiVar_FD_SW_onoff, editsw=ES_Right4, stron="FD", stroff="FD"
		PsToggleBox	HDD_SW, x=281, y=118, w=31, h=18, onoff=HdaeUiVar_HDD_SW_onoff, editsw=ES_Right3, stron="HDD", stroff="HDD"
	ui_endsub

; -----------------------------------------------------------------------------
; HDD_FILE_NAMING -- TtlScreenR "EDIT FILE NAME"
; opened by: SAVE_OPT_SCREEN_Exit_HDD_FILE_NAMING.screen, HDAE5000_FILE_LOAD_Screen_Ev01EA0008,
;            HDAE5000_WrConfirmEventCatch
; -----------------------------------------------------------------------------
	TtlScreenR	HDD_FILE_NAMING, x=0, y=0, w=320, h=240, exit=TITLE_HDDEXT, window=HdaeUiVar_HDD_FILE_NAMING_window, icon=idICON_i171, title="EDIT FILE NAME"
	ui_sub
		IvMainEditSw	HDD_FILE_NAMING_IvMainEditSw, x=32, y=0, w=32, h=32, func=NAKA_MAINFUNC_FILE_Naming_Screen
		AcFuncEditSw	HDD_FILE_NAMING_AcFuncEditSw, x=281, y=160, w=31, h=18, color=CL_Selected, editsw=ES_Right4, style=SS_OK, func=NAKA_APFUNC_HDDNamingCheck
		IvExitScreen	HDD_FILE_NAMING_Exit_SELECT_FILE, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_SELECT_FILE
		AcFuncEditSw	HDD_FILE_NAMING_AcFuncEditSw_2, x=281, y=118, w=31, h=18, color=CL_Selected, editsw=ES_Right3, style=SS_Special, func=NAKA_APFUNC_HDDNamingCheck
		ui_sub
			Label	HDD_FILE_NAMING_AcFuncEditSw_2_OPT, x=282, y=119, w=28, h=19, font=idCHARA1, fontcolor=CL_Black, str="OPT"
		ui_endsub
		IvHddNaming	HDD_FILE_NAMING_IvHddNaming, x=0, y=0, w=32, h=32, flag=VF_Const|VF_InvisibleBox, func=NAKA_APFUNC_HDDNamingCheck
		AcFuncEditSw	HDD_FILE_NAMING_AcFuncEditSw_3, x=8, y=118, w=31, h=18, color=CL_Silver, editsw=ES_Left3, style=SS_Special, func=NAKA_APFUNC_HDDNamingCheck
		ui_sub
			Label	HDD_FILE_NAMING_AcFuncEditSw_3_LST, x=9, y=119, w=28, h=19, font=idCHARA1, fontcolor=CL_Red, str="LST"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; HD_FILE_NAME -- AcNamingWindow
; -----------------------------------------------------------------------------
	AcNamingWindow	HD_FILE_NAME, x=40, y=96, w=228, h=104, parent=HdaeUiVar_HD_FILE_NAME_parent, child=HdaeUiVar_HD_FILE_NAME_child

; -----------------------------------------------------------------------------
; HDD_DIR_NAMING -- TtlScreenR "EDIT DIRECTORY NAME"
; opened by: HDAE5000_SEL_DIR_Screen
; -----------------------------------------------------------------------------
	TtlScreenR	HDD_DIR_NAMING, x=0, y=0, w=320, h=240, exit=TITLE_HDDEXT, window=HdaeUiVar_HDD_DIR_NAMING_window, icon=idICON_i171, title="EDIT DIRECTORY NAME"
	ui_sub
		IvNaming	HDD_DIR_NAMING_IvNaming, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_HDD_DIRNAMECheck
		AcFuncEditSw	HDD_DIR_NAMING_AcFuncEditSw, x=281, y=160, w=31, h=18, color=CL_Selected, editsw=ES_Right4, style=SS_OK, func=NAKA_APFUNC_HDD_DIRNAMECheck
		IvExitScreen	HDD_DIR_NAMING_Exit_SELECT_DIR, x=0, y=32, w=32, h=32, screen=HDAE5000_OBJ_SELECT_DIR
		AcFuncEditSw	HDD_DIR_NAMING_AcFuncEditSw_2, x=8, y=118, w=31, h=18, color=CL_Silver, editsw=ES_Left3, style=SS_Special, func=NAKA_APFUNC_HDD_DIRNAMECheck
		ui_sub
			Label	HDD_DIR_NAMING_AcFuncEditSw_2_LST, x=9, y=119, w=28, h=19, font=idCHARA1, fontcolor=CL_Red, str="LST"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; HD_PLEASE_WIN -- Window
; -----------------------------------------------------------------------------
	Window	HD_PLEASE_WIN, x=60, y=84, w=200, h=48, border=BD_3D_UP2, parent=HdaeUiVar_HD_PLEASE_WIN_parent, child=HdaeUiVar_HD_PLEASE_WIN_child
	ui_sub
		Label	HD_PLEASE_WIN_PLEASE_WAIT, x=110, y=98, w=100, h=19, font=idCHARA1, fontcolor=CL_Black, str="PLEASE WAIT!"
	ui_endsub

; -----------------------------------------------------------------------------
; HD_UTIL -- TtlScreenR2 "HD UTILITY"
; -----------------------------------------------------------------------------
	TtlScreenR2	HD_UTIL, x=0, y=0, w=320, h=240, window=HdaeUiVar_HD_UTIL_window, icon=idICON_i129, title="HD UTILITY"
	ui_sub
		IvExitScreen	HD_UTIL_Exit_SETUPS_TOOLS, x=32, y=0, w=32, h=32, screen=HDAE5000_OBJ_SETUPS_TOOLS
		IvCatchEvent	HD_UTIL_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_HDD_UTIL_PAGE
		DbMemo	HD_UTIL_DbMemo, x=0, y=32, w=171, h=208
		VwMenuBox	HD_UTIL_FORMAT, x=163, y=72, w=149, h=26, editsw=ES_Right2, selected=HdaeUiVar_HD_UTIL_FORMAT_selected, str="FORMAT"
		VwMenuBox	HD_UTIL_READ_ID, x=163, y=156, w=149, h=26, editsw=ES_Right4, selected=HdaeUiVar_HD_UTIL_READ_ID_selected, str="READ ID"
	ui_endsub

; -----------------------------------------------------------------------------
; PC_DATA_LINK -- TtlScreenR2 "   PC DATA LINK"
; opened by: SETUP_TOOLS_P1_PC_DATA_LINK.screen
; -----------------------------------------------------------------------------
	TtlScreenR2	PC_DATA_LINK, x=0, y=0, w=320, h=240, window=HdaeUiVar_PC_DATA_LINK_window, icon=idICON_None, title="   PC DATA LINK"
	ui_sub
		IvCatchEvent	PC_DATA_LINK_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_PC_DATA_LINK_PAGE
		SelectList	PP_STATUS, x=20, y=84, w=280, h=48, color=CL_WallPattern, index=0xffff, font=idCHARA1, str_adr=HdaeUiVar_PP_STATUS_str_adr, row=1, sel_num=HdaeUiVar_PP_STATUS_sel_num, en_paradraw=HdaeUiVar_PP_STATUS_en_paradraw
		AcIndexWideES	PC_DATA_LINK_AcIndexWideES, x=244, y=216, w=72, h=23, border=BD_3D_UP1, index=0xffff, editsw=ES_Bottom7, editsw2=ES_Bottom8, style=SS_Special
		ui_sub
			Label	PC_DATA_LINK_AcIndexWideES_CANCEL, x=254, y=219, w=52, h=19, font=idCHARA1, fontcolor=CL_Black, str="CANCEL"
		ui_endsub
		AcIndexWideES	PC_DATA_LINK_AcIndexWideES_2, x=4, y=216, w=72, h=23, border=BD_3D_UP1, index=0xffff, editsw=ES_Bottom1, editsw2=ES_Bottom2, style=SS_Special
		ui_sub
			Label	PC_DATA_LINK_AcIndexWideES_2_START, x=18, y=219, w=44, h=19, font=idCHARA1, fontcolor=CL_Black, str="START"
		ui_endsub
		VwUserBitmap	PC_DATA_LINK_VwUserBitmap, x=76, y=1, w=27, h=27
	ui_endsub

; -----------------------------------------------------------------------------
; SETUP_TOOLS_P1 -- Window
; opened by: SETUPS_TOOLS_Page_SETUP_TOOLS_P1.window
; -----------------------------------------------------------------------------
	Window	SETUP_TOOLS_P1, x=64, y=90, w=219, h=100, color=CL_Transparent, border=BD_None, parent=HdaeUiVar_SETUP_TOOLS_P1_parent, child=HdaeUiVar_SETUP_TOOLS_P1_child
	ui_sub
		AcScreenMenu	SETUP_TOOLS_P1_PC_DATA_LINK, x=163, y=156, w=149, h=26, editsw=ES_Right4, selected=HdaeUiVar_SETUP_TOOLS_P1_PC_DATA_LINK_selected, screen=HDAE5000_OBJ_PC_DATA_LINK, icon=idICON_i129, str="PC DATA LINK"
		ui_sub
			VwUserBitmap	SETUP_TOOLS_P1_PC_DATA_LINK_VwUserBitmap, x=283, y=155, w=27, h=27
		ui_endsub
		AcIndexWideES	SETUP_TOOLS_P1_AcIndexWideES, x=244, y=216, w=72, h=23, index=0, editsw=ES_Bottom7, editsw2=ES_Bottom8
		AcRamEditBox	SETUP_TOOLS_P1_WRITE_PROTECT, x=8, y=72, w=156, h=26, index=0, align=AL_RightJustify, length=4, editsw=ES_Left2, dial=1, selected=HdaeUiVar_SETUP_TOOLS_P1_WRITE_PROTECT_selected, func=NAKA_APFUNC_WriteProtectEditCheck, data=HdaeUiVar_SETUP_TOOLS_P1_WRITE_PROTECT_data, caption=""
		ui_sub
			AcLanguageText1	SETUP_TOOLS_P1_WRITE_PROTECT_Text, x=8, y=72, w=121, h=32, index=8, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1	; EN "WRITE PROTECT: "
		ui_endsub
		AcRamEditBox	SETUP_TOOLS_P1_QUICK_LD_MODE, x=8, y=156, w=149, h=26, index=0, length=2, editsw=ES_Left4, dial=1, selected=HdaeUiVar_SETUP_TOOLS_P1_QUICK_LD_MODE_selected, func=NAKA_APFUNC_QuickLoadModeEditCheck, data=HdaeUiVar_SETUP_TOOLS_P1_QUICK_LD_MODE_data, caption="QUICK LD MODE:"
		AcRamEditBox	SETUP_TOOLS_P1_JUMP_AFTER_LD, x=163, y=72, w=149, h=26, index=0, length=2, editsw=ES_Right2, dial=1, selected=HdaeUiVar_SETUP_TOOLS_P1_JUMP_AFTER_LD_selected, func=NAKA_APFUNC_JumpAfterLoadModeEditCheck, data=HdaeUiVar_SETUP_TOOLS_P1_JUMP_AFTER_LD_data, caption="JUMP AFTER LD.:"
		AcRamEditBox	SETUP_TOOLS_P1_WRITE_CONFIRM, x=8, y=114, w=156, h=26, index=0, align=AL_RightJustify, length=4, editsw=ES_Left3, dial=1, selected=HdaeUiVar_SETUP_TOOLS_P1_WRITE_CONFIRM_selected, func=NAKA_APFUNC_WriteConfirmEditCheck, data=HdaeUiVar_SETUP_TOOLS_P1_WRITE_CONFIRM_data, caption=""
		ui_sub
			AcLanguageText1	SETUP_TOOLS_P1_WRITE_CONFIRM_Text, x=8, y=114, w=121, h=32, index=9, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1	; EN "WRITE CONFIRM: "
		ui_endsub
		AcRamEditBox	SETUP_TOOLS_P1_LD_BY_NUM_M, x=8, y=198, w=149, h=26, index=0, length=2, editsw=ES_Left5, dial=1, selected=HdaeUiVar_SETUP_TOOLS_P1_LD_BY_NUM_M_selected, func=NAKA_APFUNC_LoadByNumberModeEditCheck, data=HdaeUiVar_SETUP_TOOLS_P1_LD_BY_NUM_M_data, caption="LD BY NUM. M.:"
		AcScreenMenu	SETUP_TOOLS_P1_LYRIC_SETTINGS, x=163, y=114, w=149, h=26, editsw=ES_Right3, selected=HdaeUiVar_SETUP_TOOLS_P1_LYRIC_SETTINGS_selected, screen=HDAE5000_OBJ_LyrSettings, icon=idICON_i129, str="LYRIC SETTINGS"
		ui_sub
			VwUserBitmap	SETUP_TOOLS_P1_LYRIC_SETTINGS_VwUserBitmap, x=283, y=113, w=27, h=27
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; SETUP_TOOLS_P2 -- Window
; opened by: SETUPS_TOOLS_Page_SETUP_TOOLS_P2.window
; -----------------------------------------------------------------------------
	Window	SETUP_TOOLS_P2, x=60, y=84, w=200, h=48, color=CL_Transparent, border=BD_None, parent=HdaeUiVar_SETUP_TOOLS_P2_parent, child=HdaeUiVar_SETUP_TOOLS_P2_child
	ui_sub
		AcScreenMenu	SETUP_TOOLS_P2_SAVE_SETUP, x=8, y=198, w=120, h=26, color=CL_Silver, border=BD_3D_UP1, fontcolor=CL_Black, editsw=ES_Left5, selected=HdaeUiVar_SETUP_TOOLS_P2_SAVE_SETUP_selected, screen=NAKA_NO_OBJECT, icon=idICON_None, str=""
		ui_sub
			AcLanguageText1	SETUP_TOOLS_P2_SAVE_SETUP_Text, x=6, y=198, w=124, h=32, index=11, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "SAVE SETUP"
		ui_endsub
		AcScreenMenu	SETUP_TOOLS_P2_HD_AE_INFOS, x=163, y=198, w=149, h=26, editsw=ES_Right5, selected=HdaeUiVar_SETUP_TOOLS_P2_HD_AE_INFOS_selected, screen=NAKA_NO_OBJECT, icon=idICON_Default, str="HD-AE INFOS  "
		ui_sub
			VwUserBitmap	SETUP_TOOLS_P2_HD_AE_INFOS_VwUserBitmap, x=283, y=197, w=27, h=27
		ui_endsub
		IvMainEditSw	SETUP_TOOLS_P2_IvMainEditSw, x=0, y=64, w=32, h=32, func=NAKA_MAINFUNC_SetupP2SwCatch
		HDAE5000_Str_Alert_HDFormat:	.asciz	"! HD FORMAT !"
		ui_ram_object	SW_HD_FORMAT, AcScreenMenu
		ui_sub
			VwUserBitmap	SW_HD_FORMAT_VwUserBitmap, x=283, y=71, w=27, h=27
		ui_endsub
		AcScreenMenu	SETUP_TOOLS_P2_Go_ABOUT_HELP, x=163, y=156, w=149, h=26, editsw=ES_Right4, selected=HdaeUiVar_SETUP_TOOLS_P2_Go_ABOUT_HELP_selected, screen=HDAE5000_OBJ_ABOUT_HELP, icon=idICON_Default, str=""
		ui_sub
			VwUserBitmap	SETUP_TOOLS_P2_Go_ABOUT_HELP_VwUserBitmap, x=283, y=155, w=27, h=27
			AcLanguageText1	SETUP_TOOLS_P2_Go_ABOUT_HELP_Text, x=169, y=156, w=125, h=32, index=10, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1	; EN "ABOUT & HELP "
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; OUTPUT_SETTING -- TtlScreenR "OUTPUT SETTING"
; opened by: HDDMENU_Go_OUTPUT_SETTING.screen
; -----------------------------------------------------------------------------
	TtlScreenR	OUTPUT_SETTING, x=0, y=0, w=320, h=240, window=HdaeUiVar_OUTPUT_SETTING_window, icon=idICON_i31, title="OUTPUT SETTING"
	ui_sub
		IvExitScreen	OUTPUT_SETTING_Exit_HDDMENU, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		AcIndexWideES	OUTPUT_SETTING_AcIndexWideES, x=244, y=216, w=72, h=23, index=0, editsw=ES_Bottom7, editsw2=ES_Bottom8
		AcRamEditBox	OUTPUT_SETTING_AcRamEditBox, x=12, y=72, w=300, h=26, index=0, align=AL_RightJustify, length=16, editsw=ES_Left2, dial=1, selected=HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_selected, func=NAKA_APFUNC_SeparateOutputModeCheck, data=HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_data, caption=""
		AcRamEditBox	OUTPUT_SETTING_AcRamEditBox_2, x=12, y=114, w=300, h=26, index=0, align=AL_RightJustify, length=6, editsw=ES_Left3, dial=1, selected=HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_2_selected, func=NAKA_APFUNC_SeparateDrumPartCheck, data=HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_2_data, caption=""
		AcRamEditBox	OUTPUT_SETTING_AcRamEditBox_3, x=12, y=156, w=300, h=26, index=0, align=AL_RightJustify, length=6, editsw=ES_Left4, dial=1, selected=HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_3_selected, func=NAKA_APFUNC_SeparateBassPartCheck, data=HdaeUiVar_OUTPUT_SETTING_AcRamEditBox_3_data, caption=""
		AcLanguageText1	OUTPUT_SETTING_SEPARATE_OUTPUT_MODE, x=12, y=72, w=190, h=32, index=13, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1	; EN "SEPARATE OUTPUT MODE:"
		AcLanguageText1	OUTPUT_SETTING_PART_SELECT_FOR_SEQ_DRUM, x=12, y=114, w=252, h=32, index=14, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1	; EN "PART SELECT FOR SEQ.DRUMS OUT:"
		AcLanguageText1	OUTPUT_SETTING_PART_SELECT_FOR_SEQ_BASS, x=12, y=156, w=252, h=32, index=15, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1	; EN "PART SELECT FOR SEQ.BASS  OUT:"
		AcLanguageText1	OUTPUT_SETTING_The_separate_outputs_can, x=6, y=184, w=225, h=54, index=16, font=idCHARA1W, fontcolor=CL_Text, alignment=AL_LeftJustify, lines=3	; EN "! The separate outputs cannot be controlled by the internal volume control."
	ui_endsub

; -----------------------------------------------------------------------------
; LOAD_BY_NUM -- TtlScreenR2 "LOAD BY NUMBER"
; opened by: HDDMENU_Go_LOAD_BY_NUM.screen, HDAE5000_HDAETitleFunc, HDAE5000_LBNLoadSwCatch,
;            HDAE5000_Lbn_TypeDigit
; -----------------------------------------------------------------------------
	TtlScreenR2	LOAD_BY_NUM, x=0, y=0, w=320, h=240, window=HdaeUiVar_LOAD_BY_NUM_window, icon=idICON_i172, title="LOAD BY NUMBER"
	ui_sub
		IvExitScreen	LOAD_BY_NUM_Exit_HDDMENU, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		IvPageControl	LOAD_BY_NUM_Page_LBN_P1, x=0, y=32, w=32, h=32, page=1, window=HDAE5000_OBJ_LBN_P1
		IvPageControl	LOAD_BY_NUM_Page_LBN_P2, x=32, y=32, w=32, h=32, page=2, window=HDAE5000_OBJ_LBN_P2
		AcWindowPage1	LOAD_BY_NUM_AcWindowPage1, x=245, y=6, w=71, h=18, page=HdaeUiVar_LOAD_BY_NUM_AcWindowPage1_page
		IvCatchEvent	LOAD_BY_NUM_IvCatchEvent, x=64, y=32, w=32, h=32, func=NAKA_APFUNC_LBNLoadSwCatch
	ui_endsub

; -----------------------------------------------------------------------------
; LBN_P1 -- Window
; opened by: LOAD_BY_NUM_Page_LBN_P1.window
; -----------------------------------------------------------------------------
	Window	LBN_P1, x=60, y=84, w=200, h=48, color=CL_Transparent, border=BD_None, parent=HdaeUiVar_LBN_P1_parent, child=HdaeUiVar_LBN_P1_child
	ui_sub
		PsMenuBox	LBN_P1_PsMenuBox, x=263, y=203, w=49, h=18, flag=VF_Const, color=CL_Silver, border=BD_3D_UP1, index=0xffff, font=idCHARA1, fontcolor=CL_Black, align=AL_Center, editsw=ES_Right5, selected=HdaeUiVar_LBN_P1_PsMenuBox_selected
		ui_sub
			Label	LBN_P1_PsMenuBox_CLEAR, x=265, y=204, w=44, h=19, font=idCHARA1, fontcolor=CL_Black, str="CLEAR"
		ui_endsub
		SelectList	LBN_OPTION, x=236, y=91, w=84, h=111, color=CL_WallPattern, index=100, str_adr=HdaeUiVar_LBN_OPTION_str_adr, row=9, sel_num=HdaeUiVar_LBN_OPTION_sel_num, en_paradraw=HdaeUiVar_LBN_OPTION_en_paradraw
		AcIndexEditSw	LBN_P1_AcIndexEditSw, x=265, y=36, w=47, h=26, border=BD_3D_UP1, index=0xffff, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	LBN_P1_AcIndexEditSw_LOAD, x=270, y=41, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="LOAD"
		ui_endsub
		EditSw	LBN_P1_80, x=310, y=77, w=10, h=17, index=0xffff, str="~80"
		Line	LBN_P1_Line, x=313, y=40, w=1, h=40, color=CL_EditSw
		TextBox	LBN_P1_TextBox, x=4, y=174, w=196, h=65, color=CL_WallPattern, border=BD_3D_UP1, font=idCHARA1, alignment=AL_LeftJustify, lines=3, text=""
		ui_sub
			StringBox	LBN_P1_TextBox_0, x=8, y=210, w=27, h=26, str="0"
			StringBox	LBN_P1_TextBox_1, x=8, y=179, w=27, h=26, str="1"
		ui_endsub
		StringBox	LBN_P1_2, x=48, y=210, w=27, h=26, str="2"
		StringBox	LBN_P1_3, x=48, y=179, w=27, h=26, str="3"
		StringBox	LBN_P1_4, x=88, y=210, w=27, h=26, str="4"
		StringBox	LBN_P1_5, x=88, y=179, w=27, h=26, str="5"
		StringBox	LBN_P1_6, x=128, y=210, w=27, h=26, str="6"
		StringBox	LBN_P1_7, x=128, y=179, w=27, h=26, str="7"
		StringBox	LBN_P1_8, x=168, y=210, w=27, h=26, str="8"
		StringBox	LBN_P1_9, x=168, y=179, w=27, h=26, str="9"
		SelectList	LBN_DIRNO_BOX, x=6, y=45, w=30, h=22, color=CL_WallPattern, index=100, font=idCHARA1, str_adr=HdaeUiVar_LBN_DIRNO_BOX_str_adr, row=1, sel_num=HdaeUiVar_LBN_DIRNO_BOX_sel_num, en_paradraw=HdaeUiVar_LBN_DIRNO_BOX_en_paradraw
		SelectList	LBN_DIRNAME_BOX, x=34, y=45, w=216, h=22, color=CL_WallPattern, index=100, font=idCHARA1, str_adr=HdaeUiVar_LBN_DIRNAME_BOX_str_adr, row=1, sel_num=HdaeUiVar_LBN_DIRNAME_BOX_sel_num, en_paradraw=HdaeUiVar_LBN_DIRNAME_BOX_en_paradraw
		SelectList	LBN_FILENO_BOX, x=6, y=68, w=30, h=22, color=CL_WallPattern, index=100, font=idCHARA1, str_adr=HdaeUiVar_LBN_FILENO_BOX_str_adr, row=1, sel_num=HdaeUiVar_LBN_FILENO_BOX_sel_num, en_paradraw=HdaeUiVar_LBN_FILENO_BOX_en_paradraw
		SelectList	LBN_FILENAME_BOX, x=34, y=68, w=216, h=22, color=CL_WallPattern, index=100, font=idCHARA1, fontcolor=CL_Selected, str_adr=HdaeUiVar_LBN_FILENAME_BOX_str_adr, row=1, sel_num=HdaeUiVar_LBN_FILENAME_BOX_sel_num, en_paradraw=HdaeUiVar_LBN_FILENAME_BOX_en_paradraw
		IvCatchEvent	LBN_P1_IvCatchEvent, x=0, y=96, w=32, h=32, func=NAKA_APFUNC_LBNPage1SwCatch
		AcIndexWideES	LBN_P1_AcIndexWideES, x=204, y=221, w=112, h=19, index=0xffff, editsw=ES_Bottom6, editsw2=ES_Bottom8
		AcLanguageText1	LBN_P1_Press_3_digits_for_direc, x=2, y=116, w=210, h=54, index=21, font=idCHARA1W, fontcolor=CL_Text, alignment=AL_LeftJustify, lines=3	; EN "Press 3 digits for directory and 2 digits for the file."
	ui_endsub

; -----------------------------------------------------------------------------
; LBN_P2 -- Window
; opened by: LOAD_BY_NUM_Page_LBN_P2.window
; -----------------------------------------------------------------------------
	Window	LBN_P2, x=8, y=104, w=24, h=52, color=CL_Transparent, border=BD_None, parent=HdaeUiVar_LBN_P2_parent, child=HdaeUiVar_LBN_P2_child
	ui_sub
		AcRamEditBox	LBN_P2_AcRamEditBox, x=40, y=47, w=224, h=26, border=BD_3D_UP2, index=0xffff, font=idCHARA1P, length=4, selected=HdaeUiVar_LBN_P2_AcRamEditBox_selected, func=NAKA_APFUNC_FileLBNNameCheck, data=HdaeUiVar_LBN_P2_AcRamEditBox_data, caption=""
		AcRamEditBox	LBN_P2_CURRENT_PANEL, x=48, y=76, w=212, h=16, index=1, selected=HdaeUiVar_LBN_P2_CURRENT_PANEL_selected, func=NAKA_APFUNC_LBNLswBitCheck, data=HdaeUiVar_LBN_P2_CURRENT_PANEL_data, caption="CURRENT PANEL          "
		AcRamEditBox	LBN_P2_PANEL_MEMORY, x=48, y=91, w=212, h=16, index=2, selected=HdaeUiVar_LBN_P2_PANEL_MEMORY_selected, func=NAKA_APFUNC_LBNPmtBitCheck, data=HdaeUiVar_LBN_P2_PANEL_MEMORY_data, caption="PANEL MEMORY           "
		ui_sub
			Line	LBN_P2_PANEL_MEMORY_Line, x=40, y=74, w=1, h=125
		ui_endsub
		AcRamEditBox	LBN_P2_SEQUENCER, x=48, y=106, w=212, h=16, index=3, selected=HdaeUiVar_LBN_P2_SEQUENCER_selected, func=NAKA_APFUNC_LBNSqtBitCheck, data=HdaeUiVar_LBN_P2_SEQUENCER_data, caption="SEQUENCER              "
		AcRamEditBox	LBN_P2_COMPOSER, x=48, y=121, w=212, h=16, index=4, selected=HdaeUiVar_LBN_P2_COMPOSER_selected, func=NAKA_APFUNC_LBNCmpBitCheck, data=HdaeUiVar_LBN_P2_COMPOSER_data, caption="COMPOSER               "
		AcRamEditBox	LBN_P2_SOUND_MEMORY, x=48, y=136, w=212, h=16, index=5, selected=HdaeUiVar_LBN_P2_SOUND_MEMORY_selected, func=NAKA_APFUNC_LBNTmBitCheck, data=HdaeUiVar_LBN_P2_SOUND_MEMORY_data, caption="SOUND MEMORY           "
		AcRamEditBox	LBN_P2_MSP, x=48, y=151, w=212, h=16, index=6, selected=HdaeUiVar_LBN_P2_MSP_selected, func=NAKA_APFUNC_LBNMspBitCheck, data=HdaeUiVar_LBN_P2_MSP_data, caption="MSP                    "
		AcRamEditBox	LBN_P2_RHYTHM_CUSTOM, x=48, y=166, w=212, h=16, index=7, selected=HdaeUiVar_LBN_P2_RHYTHM_CUSTOM_selected, func=NAKA_APFUNC_LBNRcmBitCheck, data=HdaeUiVar_LBN_P2_RHYTHM_CUSTOM_data, caption="RHYTHM CUSTOM          "
		AcRamEditBox	LBN_P2_USER_MIDI_SETTINGS, x=48, y=181, w=212, h=16, index=8, selected=HdaeUiVar_LBN_P2_USER_MIDI_SETTINGS_selected, func=NAKA_APFUNC_LBNMdBitCheck, data=HdaeUiVar_LBN_P2_USER_MIDI_SETTINGS_data, caption="USER MIDI SETTINGS     "
		Line	LBN_P2_Line, x=40, y=74, w=224, h=1
		Line	LBN_P2_Line_2, x=263, y=74, w=1, h=125
		Line	LBN_P2_Line_3, x=40, y=198, w=224, h=1
		AcIndexEditSw	LBN_P2_AcIndexEditSw, x=4, y=216, w=32, h=23, index=1, editsw=ES_Bottom1, style=SS_UpDown
		AcIndexEditSw	LBN_P2_AcIndexEditSw_2, x=44, y=216, w=32, h=23, index=2, editsw=ES_Bottom2, style=SS_UpDown
		AcIndexEditSw	LBN_P2_AcIndexEditSw_3, x=84, y=216, w=32, h=23, index=3, editsw=ES_Bottom3, style=SS_UpDown
		AcIndexEditSw	LBN_P2_AcIndexEditSw_4, x=124, y=216, w=32, h=23, index=4, editsw=ES_Bottom4, style=SS_UpDown
		AcIndexEditSw	LBN_P2_AcIndexEditSw_5, x=164, y=216, w=32, h=23, index=5, editsw=ES_Bottom5, style=SS_UpDown
		AcIndexEditSw	LBN_P2_AcIndexEditSw_6, x=244, y=216, w=32, h=23, index=7, editsw=ES_Bottom7, style=SS_UpDown
		AcIndexEditSw	LBN_P2_AcIndexEditSw_7, x=284, y=216, w=32, h=23, index=8, editsw=ES_Bottom8, style=SS_UpDown
		AcIndexEditSw	LBN_P2_AcIndexEditSw_8, x=204, y=216, w=32, h=23, index=6, editsw=ES_Bottom6, style=SS_UpDown
		Label	LBN_P2_PNL, x=9, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="PNL"
		Label	LBN_P2_P_MEM, x=42, y=202, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="P.MEM"
		Label	LBN_P2_SEQ, x=88, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="SEQ"
		Label	LBN_P2_COMP, x=126, y=202, w=28, h=11, font=idCHARA4, fontcolor=CL_White, str="COMP"
		Label	LBN_P2_SOUND, x=162, y=202, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="SOUND"
		Label	LBN_P2_MSP_2, x=209, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="MSP"
		Label	LBN_P2_CUSTOM, x=239, y=202, w=40, h=11, font=idCHARA4, fontcolor=CL_White, str="CUSTOM"
		Label	LBN_P2_MIDI, x=286, y=202, w=28, h=11, font=idCHARA4, fontcolor=CL_White, str="MIDI"
		Line	LBN_P2_Line_4, x=215, y=74, w=1, h=124
		AcIndexEditSw	LBN_P2_AcIndexEditSw_9, x=265, y=36, w=47, h=26, border=BD_3D_UP1, index=0xffff, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	LBN_P2_AcIndexEditSw_9_LOAD, x=270, y=41, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="LOAD"
		ui_endsub
		Line	LBN_P2_Line_5, x=313, y=40, w=1, h=40, color=CL_EditSw
		EditSw	LBN_P2_80, x=310, y=77, w=10, h=17, index=0xffff, str="~80"
	ui_endsub

; -----------------------------------------------------------------------------
; CP_FD -- TtlScreenR2 "COPY TECH TO HD"
; opened by: CP_FD_DIRSEL_Exit_CP_FD.screen, ERR_NO_HK_DATA_Exit_CP_FD.screen,
;            HDAE5000_FdList_Scan, HDAE5000_AttenCpToMarkSwCatch, HDAE5000_CopyToHd_Execute,
;            HDAE5000_CopyToHDDirSelScreen
; -----------------------------------------------------------------------------
	TtlScreenR2	CP_FD, x=0, y=0, w=320, h=240, window=HdaeUiVar_CP_FD_window, icon=idICON_i113, title="COPY TECH TO HD"
	ui_sub
		IvExitScreen	CP_FD_Exit_HDDMENU, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		AcIndexEditSw	CP_FD_AcIndexEditSw, x=204, y=216, w=32, h=23, index=1, editsw=ES_Bottom6, style=SS_Right2
		AcIndexEditSw	CP_FD_AcIndexEditSw_2, x=44, y=216, w=32, h=23, index=2, editsw=ES_Bottom2, style=SS_Left2
		AcIndexWideES	CP_FD_AcIndexWideES, x=84, y=216, w=112, h=23, index=0
		SelectList	CP_FD_LIST, x=40, y=58, w=200, h=157, color=CL_Silver, index=0, font=idCHARA1, fontcolor=CL_Black, main_func=NAKA_MAINFUNC_CopyToHDScreen, str_adr=HdaeUiVar_CP_FD_LIST_str_adr, column=2, row=10, sel_num=HdaeUiVar_CP_FD_LIST_sel_num, dial=1, auto_inc=1, en_paradraw=HdaeUiVar_CP_FD_LIST_en_paradraw, sel_type=1
		Line	CP_FD_LINE2, x=215, y=60, w=1, h=152
		Line	CP_FD_LINE1, x=118, y=60, w=1, h=153
		ui_ram_object	CP_FD_HDSWTO, AcIndexEditSw
		ui_sub
			Label	CP_FD_HDSWTO_TO, x=272, y=35, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="* TO"
		ui_endsub
		ui_ram_object	CP_FD_HDSWSEL, AcIndexEditSw
		ui_sub
			Label	CP_FD_HDSWSEL_SELECT, x=267, y=207, w=40, h=11, font=idCHARA4, fontcolor=CL_White, str="SELECT"
		ui_endsub
		SelectList	CP_FD_VOLLABEL, x=142, y=38, w=94, h=16, color=CL_Silver, border=BD_None, index=100, font=idCHARA1, fontcolor=CL_Selected, str_adr=HdaeUiVar_CP_FD_VOLLABEL_str_adr, row=1, sel_num=HdaeUiVar_CP_FD_VOLLABEL_sel_num, en_paradraw=HdaeUiVar_CP_FD_VOLLABEL_en_paradraw
		StringBox	CP_FD_StringBox, x=40, y=36, w=200, h=20, alignment=AL_LeftJustify, str="StringBox"
		ui_ram_object	CP_FD_HDALLSEL, AcIndexEditSw
		ui_sub
			Label	CP_FD_HDALLSEL_SEL_ALL, x=264, y=165, w=46, h=11, font=idCHARA4, fontcolor=CL_White, str="SEL ALL"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; CP_FD_DIRSEL -- TtlScreenR2 "HD DIR SELECT"
; opened by: CP_FD_DIR_NAMING_Exit_CP_FD_DIRSEL.screen, ATTEN_FULL_DIR_Exit_CP_FD_DIRSEL.screen,
;            ATTEN_CP_UNNAMED_Exit_CP_FD_DIRSEL.screen, HDAE5000_CopyToHDScreen,
;            HDAE5000_CopyToHDDirSelScreen, HDAE5000_CP_FD_DIRNAMECheck
; -----------------------------------------------------------------------------
	TtlScreenR2	CP_FD_DIRSEL, x=0, y=0, w=320, h=240, window=HdaeUiVar_CP_FD_DIRSEL_window, icon=idICON_i113, title="HD DIR SELECT"
	ui_sub
		IvExitScreen	CP_FD_DIRSEL_Exit_CP_FD, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_CP_FD
		AcIndexEditSw	CP_FD_DIRSEL_AcIndexEditSw, x=269, y=30, w=43, h=26, border=BD_3D_UP1, index=3, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	CP_FD_DIRSEL_AcIndexEditSw_COPY, x=272, y=35, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="COPY"
		ui_endsub
		SelectList	CP_FD_DIRBOX, x=8, y=35, w=256, h=176, color=CL_WallPattern, border=BD_3D_UP2, index=0, main_func=NAKA_MAINFUNC_CopyToHDDirSelScreen, str_adr=HdaeUiVar_CP_FD_DIRBOX_str_adr, column=2, row=12, sel_num=HdaeUiVar_CP_FD_DIRBOX_sel_num, dial=1, auto_inc=1, en_paradraw=HdaeUiVar_CP_FD_DIRBOX_en_paradraw
		VwEditSwBox	CP_FD_DIRSEL_01_24, x=1, y=222, w=38, h=18, color=CL_WallPattern, editsw=ES_Bottom1, str="01-24"
		VwEditSwBox	CP_FD_DIRSEL_25_48, x=43, y=222, w=38, h=18, color=CL_WallPattern, str="25-48"
		AcIndexWideES	CP_FD_DIRSEL_AcIndexWideES, x=84, y=222, w=112, h=18, index=0
		VwEditSwBox	CP_FD_DIRSEL_49_72, x=199, y=222, w=38, h=18, color=CL_WallPattern, str="49-72"
		VwEditSwBox	CP_FD_DIRSEL_73_96, x=240, y=222, w=38, h=18, color=CL_WallPattern, str="73-96"
		VwEditSwBox	CP_FD_DIRSEL_97_120, x=281, y=222, w=38, h=18, color=CL_WallPattern, str="97-120"
		AcIndexEditSw	CP_FD_DIRSEL_AcIndexEditSw_2, x=269, y=194, w=43, h=26, color=CL_Selected, border=BD_3D_UP1, index=4, editsw=ES_Right5, style=SS_Special
		ui_sub
			Label	CP_FD_DIRSEL_AcIndexEditSw_2_EDIT, x=273, y=199, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="EDIT"
		ui_endsub
		IvMainEditSw	CP_FD_DIRSEL_IvMainEditSw, x=32, y=0, w=32, h=32, func=NAKA_MAINFUNC_CopyToHDDirSelScreen
	ui_endsub

; -----------------------------------------------------------------------------
; FLS_SELECT -- TtlScreenR2 " F.L.S. SELECT"
; opened by: HDDMENU_Go_FLS_SELECT.screen, HDD_FLS_NAMING_Exit_FLS_SELECT.screen,
;            FLS_FILE_LOAD_Exit_FLS_SELECT.screen, HDAE5000_FlsNamingCheck
; -----------------------------------------------------------------------------
	TtlScreenR2	FLS_SELECT, x=0, y=0, w=320, h=240, window=HdaeUiVar_FLS_SELECT_window, icon=idICON_i173, title=" F.L.S. SELECT"
	ui_sub
		IvExitScreen	FLS_SELECT_Exit_HDDMENU, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		VwEditSwBox	FLS_SELECT_01_24, x=1, y=222, w=38, h=18, editsw=ES_Bottom1, str="01-24"
		VwEditSwBox	FLS_SELECT_25_48, x=43, y=222, w=38, h=18, str="25-48"
		AcIndexWideES	FLS_SELECT_AcIndexWideES, x=84, y=222, w=112, h=18, index=0
		VwEditSwBox	FLS_SELECT_49_72, x=199, y=222, w=38, h=18, str="49-72"
		VwEditSwBox	FLS_SELECT_73_96, x=240, y=222, w=38, h=18, str="73-96"
		VwEditSwBox	FLS_SELECT_97_120, x=281, y=222, w=38, h=18, str="97-120"
		AcIndexEditSw	FLS_SEL, x=265, y=35, w=47, h=26, border=BD_3D_UP1, index=3, editsw=ES_Right1, style=SS_OK
		ui_ram_object	FLS_SELECT_SW_EDIT, AcIndexEditSw
		ui_sub
			Label	FLS_SELECT_SW_EDIT_EDIT, x=270, y=202, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="EDIT"
		ui_endsub
		SelectList	SEL_FLS, x=2, y=34, w=254, h=184, color=CL_DarkGray, index=0, main_func=NAKA_MAINFUNC_SelectFlsScreen, str_adr=HdaeUiVar_SEL_FLS_str_adr, column=2, row=12, sel_num=HdaeUiVar_SEL_FLS_sel_num, dial=1, auto_inc=1, en_paradraw=HdaeUiVar_SEL_FLS_en_paradraw
		IvMainEditSw	FLS_SELECT_IvMainEditSw, x=32, y=0, w=32, h=32, func=NAKA_MAINFUNC_SelectFlsScreen
		EditSw	FLS_SELECT_80, x=310, y=77, w=12, h=19, index=6, str="~80"
		Line	FLS_SELECT_Line, x=313, y=40, w=1, h=40, color=CL_EditSw
	ui_endsub

; -----------------------------------------------------------------------------
; HD_FILE_LOAD_P1 -- Window
; opened by: HD_FILE_LOAD.window
; -----------------------------------------------------------------------------
	Window	HD_FILE_LOAD_P1, x=60, y=80, w=176, h=44, border=BD_3D_UP2, parent=HdaeUiVar_HD_FILE_LOAD_P1_parent, child=HdaeUiVar_HD_FILE_LOAD_P1_child
	ui_sub
		ui_ram_object	HD_FILE_LOAD_SW_SAVE, AcIndexEditSw
		ui_sub
			Label	HD_FILE_LOAD_SW_SAVE_SAVE, x=270, y=204, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="SAVE"
		ui_endsub
		SelectList	HD_FILE_OPTION, x=236, y=95, w=85, h=103, color=CL_DarkGray, index=100, str_adr=HdaeUiVar_HD_FILE_OPTION_str_adr, row=9, sel_num=HdaeUiVar_HD_FILE_OPTION_sel_num, en_paradraw=HdaeUiVar_HD_FILE_OPTION_en_paradraw
		SelectList	HD_FILE_LIST, x=44, y=52, w=192, h=164, color=CL_DarkGray, index=0, main_func=NAKA_MAINFUNC_FILE_LOAD_Screen, str_adr=HdaeUiVar_HD_FILE_LIST_str_adr, row=16, sel_num=HdaeUiVar_HD_FILE_LIST_sel_num, dial=1, auto_inc=1, en_paradraw=HdaeUiVar_HD_FILE_LIST_en_paradraw
		SelectList	FILE_LOAD_DIRBOX, x=44, y=35, w=192, h=16, color=CL_DarkGray, index=100, str_adr=HdaeUiVar_FILE_LOAD_DIRBOX_str_adr, row=1, sel_num=HdaeUiVar_FILE_LOAD_DIRBOX_sel_num, en_paradraw=HdaeUiVar_FILE_LOAD_DIRBOX_en_paradraw
		AcIndexEditSw	HD_FILE_LOAD_P1_AcIndexEditSw, x=44, y=220, w=32, h=18, index=2, editsw=ES_Bottom2, style=SS_Left2
		AcIndexWideES	HD_FILE_LOAD_P1_AcIndexWideES, x=84, y=220, w=112, h=18, index=0
		AcIndexEditSw	HD_FILE_LOAD_P1_AcIndexEditSw_2, x=204, y=220, w=32, h=18, index=1, editsw=ES_Bottom6, style=SS_Right2
		Icon	HD_FILE_LOAD_P1_Icon, x=44, y=0, w=28, h=28
		Label	HD_FILE_LOAD_P1_HD_FILE_SELECT, x=78, y=6, w=158, h=19, font=idCHARA5, fontcolor=CL_White, str="HD FILE SELECT"
		ui_ram_object	HD_FILE_LOAD_SW_DEL, AcIndexEditSw
		ui_sub
			Label	HD_FILE_LOAD_SW_DEL_DEL, x=11, y=33, w=22, h=11, font=idCHARA4, fontcolor=CL_Black, str="DEL"
			Label	HD_FILE_LOAD_SW_DEL_DIR, x=11, y=43, w=22, h=11, font=idCHARA4, fontcolor=CL_Black, str="DIR"
		ui_endsub
		ui_ram_object	HD_FILE_LOAD_SW_DELFILE, AcIndexEditSw
		ui_sub
			Label	HD_FILE_LOAD_SW_DELFILE_DEL, x=10, y=117, w=22, h=11, font=idCHARA4, fontcolor=CL_Black, str="DEL"
			Label	HD_FILE_LOAD_SW_DELFILE_FILE, x=10, y=127, w=28, h=11, font=idCHARA4, fontcolor=CL_Black, str="FILE"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; HD_FILE_LOAD_P2 -- Window
; opened by: HD_LOAD_OPTION.window, SELECT_FILE_A_Z_Page_HD_FILE_LOAD_P2.window
; -----------------------------------------------------------------------------
	Window	HD_FILE_LOAD_P2, x=70, y=80, w=180, h=48, border=BD_3D_UP2, parent=HdaeUiVar_HD_FILE_LOAD_P2_parent, child=HdaeUiVar_HD_FILE_LOAD_P2_child
	ui_sub
		Label	HD_FILE_LOAD_P2_HD_LOAD_OPTION, x=78, y=6, w=158, h=19, font=idCHARA5, fontcolor=CL_White, str="HD LOAD OPTION"
		Icon	HD_FILE_LOAD_P2_Icon, x=44, y=0, w=28, h=28
		AcRamEditBox	HD_FILE_LOAD_P2_CURRENT_PANEL, x=48, y=52, w=212, h=16, index=1, selected=HdaeUiVar_HD_FILE_LOAD_P2_CURRENT_PANEL_selected, func=NAKA_APFUNC_SfxLswBitCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_CURRENT_PANEL_data, caption="CURRENT PANEL          "
		AcIndexEditSw	HD_FILE_LOAD_P2_AcIndexEditSw, x=4, y=216, w=32, h=23, index=1, editsw=ES_Bottom1, style=SS_UpDown
		Label	HD_FILE_LOAD_P2_PNL, x=9, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="PNL"
		AcIndexEditSw	HD_FILE_LOAD_P2_AcIndexEditSw_2, x=44, y=216, w=32, h=23, index=2, editsw=ES_Bottom2, style=SS_UpDown
		AcIndexEditSw	HD_FILE_LOAD_P2_AcIndexEditSw_3, x=84, y=216, w=32, h=23, index=3, editsw=ES_Bottom3, style=SS_UpDown
		AcIndexEditSw	HD_FILE_LOAD_P2_AcIndexEditSw_4, x=124, y=216, w=32, h=23, index=4, editsw=ES_Bottom4, style=SS_UpDown
		AcIndexEditSw	HD_FILE_LOAD_P2_AcIndexEditSw_5, x=164, y=216, w=32, h=23, index=5, editsw=ES_Bottom5, style=SS_UpDown
		AcIndexEditSw	HD_FILE_LOAD_P2_AcIndexEditSw_6, x=204, y=216, w=32, h=23, index=6, editsw=ES_Bottom6, style=SS_UpDown
		AcIndexEditSw	HD_FILE_LOAD_P2_AcIndexEditSw_7, x=244, y=216, w=32, h=23, index=7, editsw=ES_Bottom7, style=SS_UpDown
		AcIndexEditSw	HD_FILE_LOAD_P2_AcIndexEditSw_8, x=284, y=216, w=32, h=23, index=8, editsw=ES_Bottom8, style=SS_UpDown
		Label	HD_FILE_LOAD_P2_P_MEM, x=42, y=202, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="P.MEM"
		Label	HD_FILE_LOAD_P2_SEQ, x=88, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="SEQ"
		Label	HD_FILE_LOAD_P2_COMP, x=126, y=202, w=28, h=11, font=idCHARA4, fontcolor=CL_White, str="COMP"
		Label	HD_FILE_LOAD_P2_SOUND, x=162, y=202, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="SOUND"
		Label	HD_FILE_LOAD_P2_MSP, x=209, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="MSP"
		Label	HD_FILE_LOAD_P2_CUSTOM, x=239, y=202, w=40, h=11, font=idCHARA4, fontcolor=CL_White, str="CUSTOM"
		Label	HD_FILE_LOAD_P2_MIDI, x=286, y=202, w=28, h=11, font=idCHARA4, fontcolor=CL_White, str="MIDI"
		AcRamEditBox	HD_FILE_LOAD_P2_SEQUENCER, x=48, y=84, w=212, h=16, index=3, selected=HdaeUiVar_HD_FILE_LOAD_P2_SEQUENCER_selected, func=NAKA_APFUNC_SfxSqtBitCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_SEQUENCER_data, caption="SEQUENCER              "
		AcRamEditBox	HD_FILE_LOAD_P2_COMPOSER, x=48, y=100, w=212, h=16, index=4, selected=HdaeUiVar_HD_FILE_LOAD_P2_COMPOSER_selected, func=NAKA_APFUNC_SfxCmpBitCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_COMPOSER_data, caption="COMPOSER               "
		AcRamEditBox	HD_FILE_LOAD_P2_SOUND_MEMORY, x=48, y=116, w=212, h=16, index=5, selected=HdaeUiVar_HD_FILE_LOAD_P2_SOUND_MEMORY_selected, func=NAKA_APFUNC_SfxTmBitCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_SOUND_MEMORY_data, caption="SOUND MEMORY           "
		AcRamEditBox	HD_FILE_LOAD_P2_MSP_2, x=48, y=132, w=212, h=16, index=6, selected=HdaeUiVar_HD_FILE_LOAD_P2_MSP_2_selected, func=NAKA_APFUNC_SfxMspBitCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_MSP_2_data, caption="MSP                    "
		AcRamEditBox	HD_FILE_LOAD_P2_RHYTHM_CUSTOM, x=48, y=148, w=212, h=16, index=7, selected=HdaeUiVar_HD_FILE_LOAD_P2_RHYTHM_CUSTOM_selected, func=NAKA_APFUNC_SfxRcmBitCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_RHYTHM_CUSTOM_data, caption="RHYTHM CUSTOM          "
		AcRamEditBox	HD_FILE_LOAD_P2_TECHNICS_LYRICS, x=48, y=180, w=212, h=16, index=9, selected=HdaeUiVar_HD_FILE_LOAD_P2_TECHNICS_LYRICS_selected, func=NAKA_APFUNC_SfxTlxBitCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_TECHNICS_LYRICS_data, caption="TECHNICS LYRICS        "
		Line	HD_FILE_LOAD_P2_Line, x=42, y=198, w=222, h=1
		AcRamEditBox	HD_FILE_LOAD_P2_AcRamEditBox, x=42, y=24, w=222, h=26, border=BD_3D_UP1, index=0xffff, font=idCHARA1P, length=4, selected=HdaeUiVar_HD_FILE_LOAD_P2_AcRamEditBox_selected, func=NAKA_APFUNC_FileOptNameCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_AcRamEditBox_data, caption=""
		AcRamEditBox	HD_FILE_LOAD_P2_PANEL_MEMORY, x=48, y=68, w=212, h=16, index=2, selected=HdaeUiVar_HD_FILE_LOAD_P2_PANEL_MEMORY_selected, func=NAKA_APFUNC_SfxPmtBitCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_PANEL_MEMORY_data, caption="PANEL MEMORY           "
		Line	HD_FILE_LOAD_P2_Line_2, x=263, y=50, w=1, h=148
		ui_ram_object	HD_FILE_LOAD_P2_AcIndexEditSw_9, AcIndexEditSw
		Label	HD_FILE_LOAD_P2_LYRIC, x=6, y=148, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="LYRIC"
		AcRamEditBox	HD_FILE_LOAD_P2_USER_MIDI_SETTINGS, x=48, y=164, w=212, h=16, index=8, selected=HdaeUiVar_HD_FILE_LOAD_P2_USER_MIDI_SETTINGS_selected, func=NAKA_APFUNC_SfxMdBitCheck, data=HdaeUiVar_HD_FILE_LOAD_P2_USER_MIDI_SETTINGS_data, caption="USER MIDI SETTINGS     "
		Line	HD_FILE_LOAD_P2_Line_3, x=213, y=50, w=1, h=148
		Line	HD_FILE_LOAD_P2_Line_4, x=42, y=50, w=1, h=148
		Line	HD_FILE_LOAD_P2_Line_5, x=42, y=50, w=222, h=1
	ui_endsub

; -----------------------------------------------------------------------------
; HDD_FLS_NAMING -- TtlScreenR "EDIT FLS NAME"
; opened by: HDAE5000_SelectFlsScreen_OnHdaeSelectSave
; -----------------------------------------------------------------------------
	TtlScreenR	HDD_FLS_NAMING, x=0, y=0, w=320, h=240, window=HdaeUiVar_HDD_FLS_NAMING_window, icon=idICON_i173, title="EDIT FLS NAME"
	ui_sub
		IvNaming	HDD_FLS_NAMING_IvNaming, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_FlsNamingCheck
		IvExitScreen	HDD_FLS_NAMING_Exit_FLS_SELECT, x=32, y=0, w=32, h=32, screen=HDAE5000_OBJ_FLS_SELECT
		AcFuncEditSw	HDD_FLS_NAMING_AcFuncEditSw, x=281, y=160, w=31, h=18, color=CL_Selected, editsw=ES_Right4, style=SS_OK, func=NAKA_APFUNC_FlsNamingCheck
		AcFuncEditSw	HDD_FLS_NAMING_AcFuncEditSw_2, x=8, y=118, w=31, h=18, color=CL_Silver, editsw=ES_Left3, style=SS_Special, func=NAKA_APFUNC_FlsNamingCheck
		ui_sub
			Label	HDD_FLS_NAMING_AcFuncEditSw_2_LST, x=9, y=119, w=28, h=19, font=idCHARA1, fontcolor=CL_Red, str="LST"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; FLS_FILE_LOAD -- TtlScreenR2 "F.L.S. FILE LOAD"
; opened by: FLS_DIR_SEL_Exit_FLS_FILE_LOAD.screen, FLS_EDIT_Exit_FLS_FILE_LOAD.screen,
;            HDAE5000_HDAETitleFunc, HDAE5000_SelectFlsScreen_Skip, HDAE5000_FlsLoadScreen_Join3,
;            HDAE5000_FlsLoadScreen_Join5
; -----------------------------------------------------------------------------
	TtlScreenR2	FLS_FILE_LOAD, x=0, y=0, w=320, h=240, window=HdaeUiVar_FLS_FILE_LOAD_window, icon=idICON_i173, title="F.L.S. FILE LOAD"
	ui_sub
		IvExitScreen	FLS_FILE_LOAD_Exit_FLS_SELECT, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_FLS_SELECT
		AcIndexEditSw	FLS_FILE_LOAD_AcIndexEditSw, x=266, y=32, w=46, h=24, border=BD_3D_UP1, index=3, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	FLS_FILE_LOAD_AcIndexEditSw_LOAD, x=270, y=36, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="LOAD"
		ui_endsub
		ui_ram_object	FLS_FILE_LOAD_SW_EDIT, AcIndexEditSw
		ui_sub
			Label	FLS_FILE_LOAD_SW_EDIT_EDIT, x=270, y=202, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="EDIT"
		ui_endsub
		AcIndexWideES	FLS_FILE_LOAD_AcIndexWideES, x=84, y=220, w=112, h=18, index=0
		AcIndexEditSw	FLS_FILE_LOAD_AcIndexEditSw_2, x=44, y=220, w=32, h=18, index=2, editsw=ES_Bottom2, style=SS_Left2
		AcIndexEditSw	FLS_FILE_LOAD_AcIndexEditSw_3, x=204, y=220, w=32, h=18, index=1, editsw=ES_Bottom6, style=SS_Right2
		SelectList	FLS_OPT_BOX, x=236, y=80, w=84, h=112, color=CL_DarkGray, index=100, str_adr=HdaeUiVar_FLS_OPT_BOX_str_adr, row=9, sel_num=HdaeUiVar_FLS_OPT_BOX_sel_num, en_paradraw=HdaeUiVar_FLS_OPT_BOX_en_paradraw
		SelectList	FLS_LOC_BOX, x=236, y=58, w=84, h=18, color=CL_DarkGray, index=100, fontcolor=CL_FireRed, str_adr=HdaeUiVar_FLS_LOC_BOX_str_adr, row=1, sel_num=HdaeUiVar_FLS_LOC_BOX_sel_num, en_paradraw=HdaeUiVar_FLS_LOC_BOX_en_paradraw
		SelectList	FLS_NAME_BOX, x=8, y=32, w=190, h=18, color=CL_DarkGray, index=100, str_adr=HdaeUiVar_FLS_NAME_BOX_str_adr, row=1, sel_num=HdaeUiVar_FLS_NAME_BOX_sel_num, en_paradraw=HdaeUiVar_FLS_NAME_BOX_en_paradraw
		ui_sub
			StringBox	FLS_NAME_BOX_AS, x=197, y=32, w=18, h=18, color=CL_DarkGray, font=idCHARA4, fontcolor=CL_White, str="AS"
			StringBox	FLS_NAME_BOX_AL, x=214, y=32, w=19, h=18, color=CL_DarkGray, font=idCHARA4, fontcolor=CL_White, str="AL"
		ui_endsub
		SelectList	FLS_FILE_BOX, x=8, y=52, w=225, h=165, color=CL_DarkGray, index=0, main_func=NAKA_MAINFUNC_FlsLoadScreen, str_adr=HdaeUiVar_FLS_FILE_BOX_str_adr, row=16, sel_num=HdaeUiVar_FLS_FILE_BOX_sel_num, dial=1, auto_inc=1, en_paradraw=HdaeUiVar_FLS_FILE_BOX_en_paradraw
		ui_sub
			Line	FLS_LOAD_LINE1, x=197, y=52, w=1, h=165
			Line	FLS_LOAD_LINE2, x=214, y=52, w=1, h=165
		ui_endsub
		IvCatchEvent	FLS_FILE_LOAD_IvCatchEvent, x=288, y=0, w=32, h=32, func=NAKA_APFUNC_FlsFileLoadSwCatch
		AcIndexWideES	FLS_FILE_LOAD_AcIndexWideES_2, x=244, y=220, w=72, h=18, border=BD_Round5, index=0xffff, editsw=ES_Bottom7, editsw2=ES_Bottom8, style=SS_Special
		ui_sub
			Label	FLS_FILE_LOAD_AcIndexWideES_2_PANIC, x=258, y=221, w=44, h=19, font=idCHARA1, fontcolor=CL_Red, str="PANIC"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; FLS_DIR_SEL -- TtlScreenR2 "F.L.S. DIR SELECT"
; opened by: FLS_FILE_SEL_Exit_FLS_DIR_SEL.screen, HDAE5000_FlsEditScreen_OnHdaeSelectOk
; -----------------------------------------------------------------------------
	TtlScreenR2	FLS_DIR_SEL, x=0, y=0, w=320, h=240, window=HdaeUiVar_FLS_DIR_SEL_window, icon=idICON_i173, title="F.L.S. DIR SELECT"
	ui_sub
		IvExitScreen	FLS_DIR_SEL_Exit_FLS_FILE_LOAD, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_FLS_FILE_LOAD
		AcIndexEditSw	FLS_DIR_SEL_AcIndexEditSw, x=269, y=30, w=43, h=26, border=BD_3D_UP1, index=3, editsw=ES_Right1, style=SS_OK
		SelectList	FLS_DIR_BOX, x=8, y=35, w=256, h=176, color=CL_DarkGray, border=BD_3D_UP2, index=0, main_func=NAKA_MAINFUNC_FlsDirSelScreen, str_adr=HdaeUiVar_FLS_DIR_BOX_str_adr, column=2, row=12, sel_num=HdaeUiVar_FLS_DIR_BOX_sel_num, dial=1, auto_inc=1, en_paradraw=HdaeUiVar_FLS_DIR_BOX_en_paradraw
		VwEditSwBox	FLS_DIR_SEL_01_24, x=1, y=222, w=38, h=18, editsw=ES_Bottom1, str="01-24"
		VwEditSwBox	FLS_DIR_SEL_25_48, x=43, y=222, w=38, h=18, str="25-48"
		AcIndexWideES	FLS_DIR_SEL_AcIndexWideES, x=84, y=222, w=112, h=18, index=0
		VwEditSwBox	FLS_DIR_SEL_49_72, x=199, y=222, w=38, h=18, str="49-72"
		VwEditSwBox	FLS_DIR_SEL_73_96, x=240, y=222, w=38, h=18, str="73-96"
		VwEditSwBox	FLS_DIR_SEL_97_120, x=281, y=222, w=38, h=18, str="97-120"
		IvMainEditSw	FLS_DIR_SEL_IvMainEditSw, x=28, y=0, w=32, h=32, func=NAKA_MAINFUNC_FlsDirSelScreen
	ui_endsub

; -----------------------------------------------------------------------------
; FLS_FILE_SEL -- TtlScreenR2 "F.L.S. FILE SELECT"
; opened by: HDAE5000_FlsDirSelScreen_OnHdaeSelectOk
; -----------------------------------------------------------------------------
	TtlScreenR2	FLS_FILE_SEL, x=0, y=0, w=320, h=240, window=HdaeUiVar_FLS_FILE_SEL_window, icon=idICON_i173, title="F.L.S. FILE SELECT"
	ui_sub
		IvExitScreen	FLS_FILE_SEL_Exit_FLS_DIR_SEL, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_FLS_DIR_SEL
		SelectList	FLS_FILE_SEL_DIRBOX, x=44, y=32, w=192, h=16, color=CL_DarkGray, index=100, str_adr=HdaeUiVar_FLS_FILE_SEL_DIRBOX_str_adr, row=1, sel_num=HdaeUiVar_FLS_FILE_SEL_DIRBOX_sel_num, en_paradraw=HdaeUiVar_FLS_FILE_SEL_DIRBOX_en_paradraw
		SelectList	FLS_FILE_SEL_LISTBOX, x=44, y=48, w=192, h=168, color=CL_DarkGray, index=0, main_func=NAKA_MAINFUNC_FlsFileSelScreen, str_adr=HdaeUiVar_FLS_FILE_SEL_LISTBOX_str_adr, row=16, sel_num=HdaeUiVar_FLS_FILE_SEL_LISTBOX_sel_num, dial=1, auto_inc=1, en_paradraw=HdaeUiVar_FLS_FILE_SEL_LISTBOX_en_paradraw
		AcIndexWideES	FLS_FILE_SEL_AcIndexWideES, x=84, y=220, w=112, h=18, index=0
		AcIndexEditSw	FLS_FILE_SEL_AcIndexEditSw, x=44, y=220, w=32, h=18, index=2, editsw=ES_Bottom2, style=SS_Left2
		AcIndexEditSw	FLS_FILE_SEL_AcIndexEditSw_2, x=204, y=220, w=32, h=18, index=1, editsw=ES_Bottom6, style=SS_Right2
		SelectList	FLS_FILE_SEL_OPTBOX, x=236, y=68, w=84, h=120, color=CL_WallPattern, index=100, str_adr=HdaeUiVar_FLS_FILE_SEL_OPTBOX_str_adr, row=9, sel_num=HdaeUiVar_FLS_FILE_SEL_OPTBOX_sel_num, en_paradraw=HdaeUiVar_FLS_FILE_SEL_OPTBOX_en_paradraw
		AcIndexEditSw	FLS_FILE_SEL_AcIndexEditSw_3, x=258, y=30, w=54, h=26, border=BD_3D_UP1, index=3, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	FLS_FILE_SEL_AcIndexEditSw_3_SELECT, x=259, y=35, w=52, h=19, font=idCHARA1, fontcolor=CL_Black, str="SELECT"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; FLS_EDIT -- TtlScreenR2 "F.L.S. EDIT"
; opened by: HDD_FLS_NAMING2_Exit_FLS_EDIT.screen, HDAE5000_FlsNamingCheck2,
;            HDAE5000_FlsLoadScreen_OnHdaeSelectSave, HDAE5000_FlsEditScreen_OnHdaeSelectSave,
;            HDAE5000_FlsDel1SwCatch_Join, HDAE5000_FlsDel1SwCatch_Skip,
;            HDAE5000_FlsDel2SwCatch_Join, HDAE5000_FlsDel2SwCatch_Skip,
;            HDAE5000_FlsFileSelScreen_OnHdaeSelectOk, HDAE5000_FlsOverWrSwCatch_Join,
;            HDAE5000_FlsOverWrSwCatch_Skip
; -----------------------------------------------------------------------------
	TtlScreenR2	FLS_EDIT, x=0, y=0, w=320, h=240, window=HdaeUiVar_FLS_EDIT_window, icon=idICON_i173, title="F.L.S. EDIT"
	ui_sub
		IvExitScreen	FLS_EDIT_Exit_FLS_FILE_LOAD, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_FLS_FILE_LOAD
		AcIndexWideES	FLS_EDIT_AcIndexWideES, x=84, y=222, w=112, h=18, index=0
		SelectList	FLS_EDIT_NAME_BOX, x=8, y=32, w=190, h=18, color=CL_Silver, index=100, fontcolor=CL_Black, str_adr=HdaeUiVar_FLS_EDIT_NAME_BOX_str_adr, row=1, sel_num=HdaeUiVar_FLS_EDIT_NAME_BOX_sel_num, en_paradraw=HdaeUiVar_FLS_EDIT_NAME_BOX_en_paradraw
		ui_sub
			StringBox	FLS_EDIT_NAME_BOX_AS, x=198, y=32, w=17, h=18, font=idCHARA4, str="AS"
			StringBox	FLS_EDIT_NAME_BOX_AL, x=215, y=32, w=18, h=18, font=idCHARA4, str="AL"
		ui_endsub
		SelectList	FLS_EDIT_LIST_BOX, x=8, y=52, w=225, h=165, color=CL_Silver, index=0, fontcolor=CL_Black, main_func=NAKA_MAINFUNC_FlsEditScreen, str_adr=HdaeUiVar_FLS_EDIT_LIST_BOX_str_adr, row=16, sel_num=HdaeUiVar_FLS_EDIT_LIST_BOX_sel_num, dial=1, auto_inc=1, en_paradraw=HdaeUiVar_FLS_EDIT_LIST_BOX_en_paradraw
		ui_sub
			Line	FLS_EDIT_LINE2, x=214, y=52, w=1, h=164, color=CL_Black
			Line	FLS_EDIT_LINE1, x=197, y=52, w=1, h=164, color=CL_Black
		ui_endsub
		AcIndexEditSw	FLS_EDIT_AcIndexEditSw, x=255, y=30, w=57, h=26, border=BD_3D_UP1, index=3, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	FLS_EDIT_AcIndexEditSw_SEARCH, x=257, y=35, w=52, h=19, font=idCHARA1, fontcolor=CL_Black, str="SEARCH"
		ui_endsub
		AcIndexEditSw	FLS_EDIT_AcIndexEditSw_2, x=256, y=192, w=55, h=26, color=CL_Selected, border=BD_3D_UP1, index=4, editsw=ES_Right5, style=SS_Special
		ui_sub
			Label	FLS_EDIT_AcIndexEditSw_2_SAVE, x=268, y=195, w=28, h=11, font=idCHARA4, fontcolor=CL_White, str="SAVE"
			Label	FLS_EDIT_AcIndexEditSw_2_F_L_S, x=266, y=206, w=40, h=11, font=idCHARA4, fontcolor=CL_White, str="F.L.S."
		ui_endsub
		VwEditSwBox	FLS_EDIT_DEL1, x=4, y=222, w=32, h=18, editsw=ES_Bottom1, str="DEL1"
		VwEditSwBox	FLS_EDIT_DEL2, x=44, y=222, w=33, h=18, editsw=ES_Bottom2, str="DEL2"
		VwEditSwBox	FLS_EDIT_INS, x=204, y=222, w=33, h=18, editsw=ES_Bottom6, str="INS"
		VwEditSwBox	FLS_EDIT_A_S, x=244, y=222, w=32, h=18, editsw=ES_Bottom7, str="A.S."
		VwEditSwBox	FLS_EDIT_A_L, x=284, y=222, w=32, h=18, str="A.L."
		SelectList	FLS_EDIT_LOC_BOX, x=236, y=58, w=84, h=18, color=CL_WallPattern, index=100, fontcolor=CL_Selected, str_adr=HdaeUiVar_FLS_EDIT_LOC_BOX_str_adr, row=1, sel_num=HdaeUiVar_FLS_EDIT_LOC_BOX_sel_num, en_paradraw=HdaeUiVar_FLS_EDIT_LOC_BOX_en_paradraw
		SelectList	FLS_EDIT_OPT_BOX, x=236, y=78, w=84, h=111, color=CL_WallPattern, index=100, str_adr=HdaeUiVar_FLS_EDIT_OPT_BOX_str_adr, row=9, sel_num=HdaeUiVar_FLS_EDIT_OPT_BOX_sel_num, en_paradraw=HdaeUiVar_FLS_EDIT_OPT_BOX_en_paradraw
		IvMainEditSw	FLS_EDIT_IvMainEditSw, x=32, y=0, w=32, h=32, func=NAKA_MAINFUNC_FlsEditScreen
		Line	FLS_EDIT_Line, x=214, y=32, w=1, h=17, color=CL_Black
		Line	FLS_EDIT_Line_2, x=197, y=32, w=1, h=17, color=CL_Black
	ui_endsub

; -----------------------------------------------------------------------------
; CP_FD_DIR_NAMING -- TtlScreenR "EDIT DIRECTORY NAME"
; opened by: HDAE5000_CopyToHDDirSelScreen
; -----------------------------------------------------------------------------
	TtlScreenR	CP_FD_DIR_NAMING, x=0, y=0, w=320, h=240, window=HdaeUiVar_CP_FD_DIR_NAMING_window, icon=idICON_i113, title="EDIT DIRECTORY NAME"
	ui_sub
		IvExitScreen	CP_FD_DIR_NAMING_Exit_CP_FD_DIRSEL, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_CP_FD_DIRSEL
		IvNaming	CP_FD_DIR_NAMING_IvNaming, x=0, y=32, w=32, h=32, func=NAKA_APFUNC_CP_FD_DIRNAMECheck
		AcFuncEditSw	CP_FD_DIR_NAMING_AcFuncEditSw, x=281, y=160, w=31, h=18, color=CL_Selected, editsw=ES_Right4, style=SS_OK, func=NAKA_APFUNC_CP_FD_DIRNAMECheck
		AcFuncEditSw	CP_FD_DIR_NAMING_AcFuncEditSw_2, x=8, y=118, w=31, h=18, color=CL_Silver, editsw=ES_Left3, style=SS_Special, func=NAKA_APFUNC_CP_FD_DIRNAMECheck
		Label	CP_FD_DIR_NAMING_LST, x=9, y=119, w=28, h=19, font=idCHARA1, fontcolor=CL_Red, str="LST"
	ui_endsub

; -----------------------------------------------------------------------------
; Root_AcNamingWindow -- AcNamingWindow
; -----------------------------------------------------------------------------
	AcNamingWindow	Root_AcNamingWindow, x=60, y=84, w=200, h=48, parent=HdaeUiVar_Root_AcNamingWindow_parent, child=HdaeUiVar_Root_AcNamingWindow_child

; -----------------------------------------------------------------------------
; SAVE_OPT_SCREEN -- TtlScreenR2 "SAVE OPTION"
; opened by: HDAE5000_HDDNamingCheck_Join
; -----------------------------------------------------------------------------
	TtlScreenR2	SAVE_OPT_SCREEN, x=0, y=0, w=320, h=240, window=HdaeUiVar_SAVE_OPT_SCREEN_window, icon=idICON_i171, title="SAVE OPTION"
	ui_sub
		IvExitScreen	SAVE_OPT_SCREEN_Exit_HDD_FILE_NAMING, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDD_FILE_NAMING
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw, x=4, y=216, w=32, h=23, index=1, editsw=ES_Bottom1, style=SS_UpDown
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_2, x=44, y=216, w=32, h=23, index=2, editsw=ES_Bottom2, style=SS_UpDown
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_3, x=84, y=216, w=32, h=23, index=3, editsw=ES_Bottom3, style=SS_UpDown
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_4, x=124, y=216, w=32, h=23, index=4, editsw=ES_Bottom4, style=SS_UpDown
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_5, x=164, y=216, w=32, h=23, index=5, editsw=ES_Bottom5, style=SS_UpDown
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_6, x=204, y=216, w=32, h=23, index=6, editsw=ES_Bottom6, style=SS_UpDown
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_7, x=244, y=216, w=32, h=23, index=7, editsw=ES_Bottom7, style=SS_UpDown
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_8, x=284, y=216, w=32, h=23, index=8, editsw=ES_Bottom8, style=SS_UpDown
		Label	SAVE_OPT_SCREEN_PNL, x=9, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="PNL"
		Label	SAVE_OPT_SCREEN_P_MEM, x=42, y=202, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="P.MEM"
		Label	SAVE_OPT_SCREEN_SEQ, x=88, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="SEQ"
		Label	SAVE_OPT_SCREEN_COMP, x=126, y=202, w=28, h=11, font=idCHARA4, fontcolor=CL_White, str="COMP"
		Label	SAVE_OPT_SCREEN_SOUND, x=162, y=202, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="SOUND"
		Label	SAVE_OPT_SCREEN_MSP, x=209, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="MSP"
		Label	SAVE_OPT_SCREEN_CUSTOM, x=239, y=202, w=40, h=11, font=idCHARA4, fontcolor=CL_White, str="CUSTOM"
		Label	SAVE_OPT_SCREEN_MIDI, x=286, y=202, w=28, h=11, font=idCHARA4, fontcolor=CL_White, str="MIDI"
		AcRamEditBox	RAM_EDIT_CMP, x=44, y=106, w=212, h=16, index=4, selected=HdaeUiVar_RAM_EDIT_CMP_selected, func=NAKA_APFUNC_SfxCmpBitCheck, data=HdaeUiVar_RAM_EDIT_CMP_data, caption="COMPOSER               "
		AcRamEditBox	SAVE_OPT_SCREEN_AcRamEditBox, x=40, y=31, w=220, h=26, border=BD_3D_UP1, index=0xffff, font=idCHARA1P, length=4, selected=HdaeUiVar_SAVE_OPT_SCREEN_AcRamEditBox_selected, func=NAKA_APFUNC_SaveOptNameCheck, data=HdaeUiVar_SAVE_OPT_SCREEN_AcRamEditBox_data, caption=""
		AcRamEditBox	RAM_EDIT_LSW, x=44, y=61, w=212, h=16, index=1, selected=HdaeUiVar_RAM_EDIT_LSW_selected, func=NAKA_APFUNC_SfxLswBitCheck, data=HdaeUiVar_RAM_EDIT_LSW_data, caption="CURRENT PANEL          "
		AcRamEditBox	RAM_EDIT_PMT, x=44, y=76, w=212, h=16, index=2, selected=HdaeUiVar_RAM_EDIT_PMT_selected, func=NAKA_APFUNC_SfxPmtBitCheck, data=HdaeUiVar_RAM_EDIT_PMT_data, caption="PANEL MEMORY           "
		AcRamEditBox	RAM_EDIT_SQT, x=44, y=91, w=212, h=16, index=3, selected=HdaeUiVar_RAM_EDIT_SQT_selected, func=NAKA_APFUNC_SfxSqtBitCheck, data=HdaeUiVar_RAM_EDIT_SQT_data, caption="SEQUENCER              "
		AcRamEditBox	RAM_EDIT_TM, x=44, y=121, w=212, h=16, index=5, selected=HdaeUiVar_RAM_EDIT_TM_selected, func=NAKA_APFUNC_SfxTmBitCheck, data=HdaeUiVar_RAM_EDIT_TM_data, caption="SOUND MEMORY           "
		AcRamEditBox	RAM_EDIT_MSP, x=44, y=136, w=212, h=16, index=6, selected=HdaeUiVar_RAM_EDIT_MSP_selected, func=NAKA_APFUNC_SfxMspBitCheck, data=HdaeUiVar_RAM_EDIT_MSP_data, caption="MSP                    "
		AcRamEditBox	RAM_EDIT_RCM, x=44, y=151, w=212, h=16, index=7, selected=HdaeUiVar_RAM_EDIT_RCM_selected, func=NAKA_APFUNC_SfxRcmBitCheck, data=HdaeUiVar_RAM_EDIT_RCM_data, caption="RHYTHM CUSTOM          "
		AcRamEditBox	RAM_EDIT_MD, x=44, y=166, w=212, h=16, index=8, selected=HdaeUiVar_RAM_EDIT_MD_selected, func=NAKA_APFUNC_SfxMdBitCheck, data=HdaeUiVar_RAM_EDIT_MD_data, caption="USER MIDI SETTINGS     "
		Line	SAVE_OPT_SCREEN_Line, x=40, y=198, w=220, h=1
		Line	SAVE_OPT_SCREEN_Line_2, x=40, y=58, w=220, h=1
		Line	SAVE_OPT_SCREEN_Line_3, x=259, y=58, w=1, h=141
		Line	SAVE_OPT_SCREEN_Line_4, x=40, y=58, w=1, h=141
		IvCatchEvent	SAVE_OPT_SCREEN_IvCatchEvent, x=32, y=0, w=32, h=32, func=NAKA_APFUNC_SaveOptSwEventCatch
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_9, x=269, y=30, w=43, h=26, color=CL_Selected, border=BD_3D_UP1, index=0xffff, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	SAVE_OPT_SCREEN_AcIndexEditSw_9_SAVE, x=272, y=35, w=36, h=19, font=idCHARA1, fontcolor=CL_Black, str="SAVE"
		ui_endsub
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_10, x=263, y=76, w=49, h=18, border=BD_3D_UP1, index=0xffff, editsw=ES_Right2, style=SS_Special
		ui_sub
			Label	SAVE_OPT_SCREEN_AcIndexEditSw_10_PERFORM, x=265, y=80, w=46, h=11, font=idCHARA4, fontcolor=CL_Black, str="PERFORM"
		ui_endsub
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_11, x=263, y=160, w=49, h=18, border=BD_3D_UP1, index=0xffff, editsw=ES_Right4, style=SS_Special
		ui_sub
			Label	SAVE_OPT_SCREEN_AcIndexEditSw_11_ALL_OFF, x=265, y=164, w=46, h=11, font=idCHARA4, fontcolor=CL_Black, str="ALL OFF"
		ui_endsub
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_12, x=263, y=118, w=49, h=18, border=BD_3D_UP1, index=0xffff, editsw=ES_Right3, style=SS_Special
		ui_sub
			Label	SAVE_OPT_SCREEN_AcIndexEditSw_12_BACKUP, x=265, y=122, w=40, h=11, font=idCHARA4, fontcolor=CL_Black, str="BACKUP"
		ui_endsub
		AcRamEditBox	RAM_EDIT_TLX, x=44, y=181, w=212, h=16, index=9, selected=HdaeUiVar_RAM_EDIT_TLX_selected, func=NAKA_APFUNC_SfxTlxBitCheck, data=HdaeUiVar_RAM_EDIT_TLX_data, caption="TECHNICS LYRICS        "
		AcIndexEditSw	SAVE_OPT_SCREEN_AcIndexEditSw_13, x=8, y=158, w=32, h=22, index=9, editsw=ES_Left4, style=SS_UpDown
		Label	SAVE_OPT_SCREEN_LYRIC, x=6, y=147, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="LYRIC"
		Line	SAVE_OPT_SCREEN_Line_5, x=209, y=58, w=1, h=141
	ui_endsub

; -----------------------------------------------------------------------------
; HddNamingWindow -- AcHddNamingWindow
; opened by: HDAE5000_IvHddNamingProc_OnShow, HDAE5000_IvHddNamingProc_OnHide,
;            HDAE5000_HDDNamingCheck_OnSwIn, HDAE5000_HDDNamingCheck_Join,
;            HDAE5000_SaveOptSwEventCatch_OnSwIn, HDAE5000_WrConfirmEventCatch
; -----------------------------------------------------------------------------
	AcHddNamingWindow	HddNamingWindow, x=44, y=108, w=232, h=88, flag=VF_Const, color=CL_WallPattern, border=BD_3D_UP1, modal=0, parent=HdaeUiVar_HddNamingWindow_parent, child=HdaeUiVar_HddNamingWindow_child
	ui_sub
		AcIndexEditSw	HddNamingWindow_AcIndexEditSw, x=8, y=76, w=31, h=18, border=BD_3D_UP2, index=7, editsw=ES_Left2, style=SS_Special
		ui_sub
			Label	HddNamingWindow_AcIndexEditSw_DEL, x=9, y=77, w=28, h=19, font=idCHARA1, fontcolor=CL_Black, str="DEL"
		ui_endsub
		AcIndexEditSw	HddNamingWindow_AcIndexEditSw_2, x=8, y=34, w=31, h=18, border=BD_3D_UP2, index=6, editsw=ES_Left1, style=SS_Special
		ui_sub
			Label	HddNamingWindow_AcIndexEditSw_2_INS, x=9, y=35, w=28, h=19, font=idCHARA1, fontcolor=CL_Black, str="INS"
		ui_endsub
		AcIndexEditSw	HddNamingWindow_AcIndexEditSw_3, x=281, y=34, w=31, h=18, border=BD_3D_UP2, index=9, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	HddNamingWindow_AcIndexEditSw_3_CLR, x=282, y=35, w=28, h=19, font=idCHARA1, fontcolor=CL_Black, str="CLR"
		ui_endsub
		AcIndexEditSw	HddNamingWindow_AcIndexEditSw_4, x=281, y=76, w=31, h=18, border=BD_3D_UP2, index=8, editsw=ES_Right2, style=SS_Special
		ui_sub
			Label	HddNamingWindow_AcIndexEditSw_4_8d_8b, x=282, y=77, w=28, h=19, font=idCHARA1, fontcolor=CL_Black, str="~8d ~8b"
		ui_endsub
		AcIndexEditSw	HddNamingWindow_AcIndexEditSw_5, x=4, y=216, w=32, h=23, index=1, editsw=ES_Bottom1, style=SS_Left2
		AcIndexEditSw	HddNamingWindow_AcIndexEditSw_6, x=44, y=216, w=32, h=23, index=2, editsw=ES_Bottom2, style=SS_Right2
		Label	HddNamingWindow_POSITION, x=6, y=201, w=68, h=19, font=idCHARA1, fontcolor=CL_White, str="POSITION"
		PsCursorBox	HddNamingCursorBox, x=44, y=72, w=232, h=32, flag=VF_Const, color=CL_WallPattern, border=BD_3D_UP1, index=0xffff, font=idCHARA1, fontcolor=CL_White, align=AL_Center, cursor=HdaeUiVar_HddNamingCursorBox_cursor
		HDAE5000_Str_CharSet_Upper_1:	.asciz	"ABC"
		HDAE5000_Str_CharSet_Upper_2:	.asciz	"ABC"
		HDAE5000_Str_CharSet_Lower_1:	.asciz	"abc"
		HDAE5000_Str_CharSet_Lower_2:	.asciz	"abc"
		HDAE5000_Str_CharSet_Symbol_1:	.asciz	"!#$"
		HDAE5000_Str_CharSet_Symbol_2:	.asciz	"!#$"
		ui_ram_object	HddNamingABC, AcIndexToggle
		ui_ram_object	HddNamingabc, AcIndexToggle
		ui_ram_object	HddNamingSymbol, AcIndexToggle
		AcIndexEditSw	HddNamingWindow_AcIndexEditSw_7, x=204, y=216, w=32, h=23, index=3, editsw=ES_Bottom6, style=SS_Left2
		AcIndexEditSw	HddNamingWindow_AcIndexEditSw_8, x=244, y=216, w=32, h=23, index=4, editsw=ES_Bottom7, style=SS_UpDown2
		AcIndexEditSw	HddNamingWindow_AcIndexEditSw_9, x=284, y=216, w=32, h=23, index=5, editsw=ES_Bottom8, style=SS_Right2
		PsParaBox	HddNamingLabel, x=204, y=201, w=112, h=15, color=CL_WallPattern, font=idCHARA1
	ui_endsub

; -----------------------------------------------------------------------------
; FILE_DEL_SCREEN -- TtlScreenR2 "HD FILE DELETE"
; opened by: HDAE5000_FILE_LOAD_Screen_Ev01EA000D, HDAE5000_AttenDelFileSwCatch_Skip
; -----------------------------------------------------------------------------
	TtlScreenR2	FILE_DEL_SCREEN, x=0, y=0, w=320, h=240, window=HdaeUiVar_FILE_DEL_SCREEN_window, icon=idICON_i171, title="HD FILE DELETE"
	ui_sub
		IvExitScreen	FILE_DEL_SCREEN_Exit_SELECT_FILE, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_SELECT_FILE
		Label	FILE_DEL_SCREEN_PNL, x=9, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="PNL"
		Label	FILE_DEL_SCREEN_P_MEM, x=42, y=202, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="P.MEM"
		Label	FILE_DEL_SCREEN_SEQ, x=88, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="SEQ"
		Label	FILE_DEL_SCREEN_COMP, x=126, y=202, w=28, h=11, font=idCHARA4, fontcolor=CL_White, str="COMP"
		Label	FILE_DEL_SCREEN_SOUND, x=162, y=202, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="SOUND"
		Label	FILE_DEL_SCREEN_MSP, x=209, y=202, w=22, h=11, font=idCHARA4, fontcolor=CL_White, str="MSP"
		Label	FILE_DEL_SCREEN_CUSTOM, x=239, y=202, w=40, h=11, font=idCHARA4, fontcolor=CL_White, str="CUSTOM"
		Label	FILE_DEL_SCREEN_MIDI, x=286, y=202, w=28, h=11, font=idCHARA4, fontcolor=CL_White, str="MIDI"
		Line	FILE_DEL_SCREEN_Line, x=43, y=59, w=1, h=140
		Line	FILE_DEL_SCREEN_Line_2, x=43, y=58, w=208, h=1
		Line	FILE_DEL_SCREEN_Line_3, x=43, y=198, w=208, h=1
		AcRamEditBox	DEL_EDIT_LSW, x=48, y=59, w=210, h=16, index=1, selected=HdaeUiVar_DEL_EDIT_LSW_selected, func=NAKA_APFUNC_DelLswEditCheck, data=HdaeUiVar_DEL_EDIT_LSW_data, caption="CURRENT PANEL     "
		AcRamEditBox	DEL_EDIT_PMT, x=48, y=76, w=210, h=16, index=2, selected=HdaeUiVar_DEL_EDIT_PMT_selected, func=NAKA_APFUNC_DelPmtEditCheck, data=HdaeUiVar_DEL_EDIT_PMT_data, caption="PANEL MEMORY      "
		AcRamEditBox	DEL_EDIT_SQT, x=48, y=91, w=210, h=16, index=3, selected=HdaeUiVar_DEL_EDIT_SQT_selected, func=NAKA_APFUNC_DelSqtEditCheck, data=HdaeUiVar_DEL_EDIT_SQT_data, caption="SEQUENCER         "
		AcRamEditBox	DEL_EDIT_CMP, x=48, y=106, w=210, h=16, index=4, selected=HdaeUiVar_DEL_EDIT_CMP_selected, func=NAKA_APFUNC_DelCmpEditCheck, data=HdaeUiVar_DEL_EDIT_CMP_data, caption="COMPOSER          "
		AcRamEditBox	DEL_EDIT_TM, x=48, y=121, w=210, h=16, index=5, selected=HdaeUiVar_DEL_EDIT_TM_selected, func=NAKA_APFUNC_DelTmEditCheck, data=HdaeUiVar_DEL_EDIT_TM_data, caption="SOUND MEMORY      "
		AcRamEditBox	DEL_EDIT_MSP, x=48, y=136, w=210, h=16, index=6, selected=HdaeUiVar_DEL_EDIT_MSP_selected, func=NAKA_APFUNC_DelMspEditCheck, data=HdaeUiVar_DEL_EDIT_MSP_data, caption="MSP               "
		AcRamEditBox	DEL_EDIT_RCM, x=48, y=151, w=210, h=16, index=7, selected=HdaeUiVar_DEL_EDIT_RCM_selected, func=NAKA_APFUNC_DelRcmEditCheck, data=HdaeUiVar_DEL_EDIT_RCM_data, caption="RHYTHM CUSTOM     "
		AcRamEditBox	DEL_EDIT_MD, x=48, y=166, w=210, h=16, index=8, selected=HdaeUiVar_DEL_EDIT_MD_selected, func=NAKA_APFUNC_DelMdEditCheck, data=HdaeUiVar_DEL_EDIT_MD_data, caption="USER MIDI SETTINGS"
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw, x=4, y=216, w=32, h=23, index=1, editsw=ES_Bottom1, style=SS_UpDown
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_2, x=44, y=216, w=32, h=23, index=2, editsw=ES_Bottom2, style=SS_UpDown
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_3, x=84, y=216, w=32, h=23, index=3, editsw=ES_Bottom3, style=SS_UpDown
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_4, x=124, y=216, w=32, h=23, index=4, editsw=ES_Bottom4, style=SS_UpDown
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_5, x=164, y=216, w=32, h=23, index=5, editsw=ES_Bottom5, style=SS_UpDown
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_6, x=204, y=216, w=32, h=23, index=6, editsw=ES_Bottom6, style=SS_UpDown
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_7, x=244, y=216, w=32, h=23, index=7, editsw=ES_Bottom7, style=SS_UpDown
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_8, x=284, y=216, w=32, h=23, index=8, editsw=ES_Bottom8, style=SS_UpDown
		IvCatchEvent	FILE_DEL_SCREEN_IvCatchEvent, x=32, y=0, w=32, h=32, func=NAKA_APFUNC_DelOptSwEventCatch
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_9, x=269, y=30, w=43, h=26, color=CL_Selected, border=BD_3D_UP1, index=0xffff, editsw=ES_Right1, style=SS_Special
		ui_sub
			Label	FILE_DEL_SCREEN_AcIndexEditSw_9_DEL, x=276, y=35, w=28, h=19, font=idCHARA1, fontcolor=CL_Black, str="DEL"
		ui_endsub
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_10, x=253, y=118, w=59, h=18, border=BD_3D_UP1, index=0xffff, editsw=ES_Right3, style=SS_Special
		ui_sub
			Label	FILE_DEL_SCREEN_AcIndexEditSw_10_ALL_DEL, x=253, y=119, w=60, h=19, font=idCHARA1, fontcolor=CL_Black, str="ALL DEL"
		ui_endsub
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_11, x=253, y=160, w=59, h=18, border=BD_3D_UP1, index=0xffff, editsw=ES_Right4, style=SS_Special
		ui_sub
			Label	FILE_DEL_SCREEN_AcIndexEditSw_11_ALL_OFF, x=253, y=161, w=60, h=19, font=idCHARA1, fontcolor=CL_Black, str="ALL OFF"
		ui_endsub
		AcRamEditBox	FILE_DEL_SCREEN_AcRamEditBox, x=42, y=32, w=211, h=26, border=BD_3D_UP2, index=0xffff, font=idCHARA1P, length=4, dial=1, selected=HdaeUiVar_FILE_DEL_SCREEN_AcRamEditBox_selected, func=NAKA_APFUNC_DelOptNameCheck, data=HdaeUiVar_FILE_DEL_SCREEN_AcRamEditBox_data, caption=""
		AcIndexEditSw	FILE_DEL_SCREEN_AcIndexEditSw_12, x=8, y=158, w=32, h=22, index=9, editsw=ES_Left4, style=SS_UpDown
		Label	FILE_DEL_SCREEN_LYRIC, x=6, y=147, w=34, h=11, font=idCHARA4, fontcolor=CL_White, str="LYRIC"
		AcRamEditBox	DEL_EDIT_TLX, x=48, y=181, w=210, h=16, index=9, selected=HdaeUiVar_DEL_EDIT_TLX_selected, func=NAKA_APFUNC_DelTlxEditCheck, data=HdaeUiVar_DEL_EDIT_TLX_data, caption="TECHNICS LYRICS   "
		Line	FILE_DEL_SCREEN_Line_4, x=205, y=59, w=1, h=140
		Line	FILE_DEL_SCREEN_Line_5, x=250, y=59, w=1, h=140
	ui_endsub

; -----------------------------------------------------------------------------
; HDD_ICON_DISPLAY -- Screen
; -----------------------------------------------------------------------------
	Screen	HDD_ICON_DISPLAY, x=0, y=0, w=320, h=240, flag=VF_Fixed|VF_Const, color=CL_White, border=BD_None, exit=TITLE_PS, window=HdaeUiVar_HDD_ICON_DISPLAY_window
	ui_sub
		VwUserBitmap	HD_MENU_BMP, x=282, y=197, w=27, h=27
	ui_endsub

; -----------------------------------------------------------------------------
; IV_HDDMENU -- IvScreenR2
; opened by: HDAE5000_Handler_Registration
; -----------------------------------------------------------------------------
	IvScreenR2	IV_HDDMENU, x=0, y=0, w=320, h=240, window=HdaeUiVar_IV_HDDMENU_window

; -----------------------------------------------------------------------------
; ATTEN_DEL_DIR -- TtlScreenR2
; opened by: HDAE5000_FILE_LOAD_Screen_Ev01EA000C
; -----------------------------------------------------------------------------
	TtlScreenR2	ATTEN_DEL_DIR, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_DEL_DIR_window, icon=idICON_None, title=""
	ui_sub
		VwWideESBox	ATTEN_DEL_DIR_YES, x=4, y=216, w=72, h=23, editsw=ES_Bottom1, editsw2=ES_Bottom2, str=""
		ui_sub
			AcLanguageText1	ATTEN_DEL_DIR_YES_Text, x=4, y=220, w=72, h=20, index=200, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "YES"
		ui_endsub
		VwWideESBox	ATTEN_DEL_DIR_NO, x=244, y=216, w=72, h=23, editsw=ES_Bottom7, editsw2=ES_Bottom8, str=""
		ui_sub
			AcLanguageText1	ATTEN_DEL_DIR_NO_Text, x=248, y=220, w=68, h=20, index=201, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "NO"
		ui_endsub
		IvCatchEvent	ATTEN_DEL_DIR_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_AttenDelDirSwCatch
		AcLanguageText1	ATTEN_DEL_DIR_ATTENTION, x=40, y=76, w=240, h=130, color=CL_Silver, border=BD_EditSwitch, index=210, font=idCHARA3, fontcolor=CL_Black, lines=4	; EN "!ATTENTION!"
		ui_sub
			AcLanguageText1	ATTEN_DEL_DIR_ATTENTION_Press_YES_for_confirmati, x=44, y=155, w=232, h=50, index=211, font=idCHARA1W, fontcolor=CL_Black, lines=3	; EN "Press YES for confirmation, NO to abort."
			AcLanguageText1	ATTEN_DEL_DIR_ATTENTION_Would_you_really_delete_, x=44, y=108, w=232, h=48, index=1, font=idCHARA1W, fontcolor=CL_FireRed, lines=3	; EN "Would you really delete the selected directory?"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; WAIT_DEL_DIR -- Window
; opened by: HDAE5000_AttenDelDirSwCatch_Join
; -----------------------------------------------------------------------------
	Window	WAIT_DEL_DIR, x=26, y=30, w=268, h=52, border=BD_3D_UP1, parent=HdaeUiVar_WAIT_DEL_DIR_parent, child=HdaeUiVar_WAIT_DEL_DIR_child
	ui_sub
		Label	WAIT_DEL_DIR_DELETE_DIRECTORY_FROM_HA, x=30, y=32, w=260, h=19, font=idCHARA1, fontcolor=CL_Black, str="DELETE DIRECTORY FROM HARD DISK:"
		Label	WAIT_DEL_DIR_PLEASE_WAIT, x=30, y=54, w=244, h=19, font=idCHARA3, fontcolor=CL_FireRed, str="PLEASE WAIT ..."
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_DEL_FILE -- TtlScreenR2
; opened by: HDAE5000_DelOptSwEventCatch
; -----------------------------------------------------------------------------
	TtlScreenR2	ATTEN_DEL_FILE, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_DEL_FILE_window, icon=idICON_None, title=""
	ui_sub
		VwWideESBox	ATTEN_DEL_FILE_VwWideESBox, x=4, y=216, w=72, h=23, editsw=ES_Bottom1, editsw2=ES_Bottom2, str=""
		IvCatchEvent	ATTEN_DEL_FILE_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_AttenDelFileSwCatch
		VwWideESBox	ATTEN_DEL_FILE_VwWideESBox_2, x=244, y=216, w=72, h=23, editsw=ES_Bottom7, editsw2=ES_Bottom8, str=""
		AcLanguageText1	ATTEN_DEL_FILE_ATTENTION, x=40, y=76, w=240, h=130, color=CL_Silver, border=BD_EditSwitch, index=210, font=idCHARA3, fontcolor=CL_Black, lines=4	; EN "!ATTENTION!"
		ui_sub
			AcLanguageText1	ATTEN_DEL_FILE_ATTENTION_Press_YES_for_confirmati, x=44, y=155, w=232, h=50, index=211, font=idCHARA1W, fontcolor=CL_Black, lines=3	; EN "Press YES for confirmation, NO to abort."
			AcLanguageText1	ATTEN_DEL_FILE_ATTENTION_Would_you_really_delete_, x=44, y=108, w=232, h=48, index=2, font=idCHARA1W, fontcolor=CL_FireRed, lines=3	; EN "Would you really delete the selected title?"
		ui_endsub
		AcLanguageText1	ATTEN_DEL_FILE_YES, x=4, y=220, w=72, h=20, index=200, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "YES"
		AcLanguageText1	ATTEN_DEL_FILE_NO, x=248, y=220, w=68, h=20, index=201, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "NO"
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_OVER_FLS -- TtlScreenR
; opened by: HDAE5000_FlsFileSelScreen_Skip
; -----------------------------------------------------------------------------
	TtlScreenR	ATTEN_OVER_FLS, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_OVER_FLS_window, icon=idICON_None, title=""
	ui_sub
		IvCatchEvent	ATTEN_OVER_FLS_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_FlsOverWrSwCatch
		VwWideESBox	ATTEN_OVER_FLS_YES, x=4, y=216, w=72, h=23, editsw=ES_Bottom1, editsw2=ES_Bottom2, str=""
		ui_sub
			AcLanguageText1	ATTEN_OVER_FLS_YES_Text, x=4, y=220, w=72, h=20, index=200, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "YES"
		ui_endsub
		VwWideESBox	ATTEN_OVER_FLS_NO, x=244, y=216, w=72, h=23, editsw=ES_Bottom7, editsw2=ES_Bottom8, str=""
		ui_sub
			AcLanguageText1	ATTEN_OVER_FLS_NO_Text, x=248, y=220, w=68, h=20, index=201, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "NO"
		ui_endsub
		AcLanguageText1	ATTEN_OVER_FLS_ATTENTION, x=40, y=76, w=240, h=130, color=CL_Silver, border=BD_EditSwitch, index=210, font=idCHARA3, fontcolor=CL_Black, lines=4	; EN "!ATTENTION!"
		ui_sub
			AcLanguageText1	ATTEN_OVER_FLS_ATTENTION_Press_YES_for_confirmati, x=44, y=155, w=232, h=50, index=211, font=idCHARA1W, fontcolor=CL_Black, lines=3	; EN "Press YES for confirmation, NO to abort."
			AcLanguageText1	ATTEN_OVER_FLS_ATTENTION_You_are_going_to_overwri, x=44, y=108, w=232, h=48, index=28, font=idCHARA1W, fontcolor=CL_FireRed, lines=3	; EN "You are going to overwrite a FLS entry. Are you sure?"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_DEL_FLS2 -- TtlScreenR
; opened by: HDAE5000_FlsEditScreen_Skip
; -----------------------------------------------------------------------------
	TtlScreenR	ATTEN_DEL_FLS2, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_DEL_FLS2_window, icon=idICON_None, title=""
	ui_sub
		IvCatchEvent	ATTEN_DEL_FLS2_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_FlsDel2SwCatch
		VwWideESBox	ATTEN_DEL_FLS2_YES, x=4, y=216, w=72, h=23, editsw=ES_Bottom1, editsw2=ES_Bottom2, str=""
		ui_sub
			AcLanguageText1	ATTEN_DEL_FLS2_YES_Text, x=4, y=220, w=72, h=20, index=200, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "YES"
		ui_endsub
		VwWideESBox	ATTEN_DEL_FLS2_NO, x=244, y=216, w=72, h=23, editsw=ES_Bottom7, editsw2=ES_Bottom8, str=""
		ui_sub
			AcLanguageText1	ATTEN_DEL_FLS2_NO_Text, x=248, y=220, w=68, h=20, index=201, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "NO"
		ui_endsub
		AcLanguageText1	ATTEN_DEL_FLS2_ATTENTION, x=40, y=44, w=240, h=166, color=CL_Silver, border=BD_EditSwitch, index=210, font=idCHARA3, fontcolor=CL_Black, lines=5	; EN "!ATTENTION!"
		ui_sub
			AcLanguageText1	ATTEN_DEL_FLS2_ATTENTION_Press_YES_for_confirmati, x=44, y=160, w=232, h=50, index=211, font=idCHARA1W, fontcolor=CL_Black, lines=3	; EN "Press YES for confirmation, NO to abort."
			AcLanguageText1	ATTEN_DEL_FLS2_ATTENTION_You_are_going_to_delete_, x=44, y=76, w=232, h=48, index=27, font=idCHARA1W, fontcolor=CL_FireRed, lines=3	; EN "You are going to delete a FLS entry. Are you sure?"
			AcLanguageText1	ATTEN_DEL_FLS2_ATTENTION_All_following_entries_wi, x=44, y=124, w=232, h=36, index=61, font=idCHARA1W, fontcolor=CL_Yellow, lines=2	; EN "All following entries will be moved."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; WAIT_DEL_FILE -- Window
; opened by: HDAE5000_AttenDelFileSwCatch_Join
; -----------------------------------------------------------------------------
	Window	WAIT_DEL_FILE, x=26, y=30, w=268, h=56, border=BD_EditSwitch, parent=HdaeUiVar_WAIT_DEL_FILE_parent, child=HdaeUiVar_WAIT_DEL_FILE_child
	ui_sub
		AcLanguageText1	WAIT_DEL_FILE_Delete_file_from_hard_di, x=40, y=34, w=240, h=24, index=56, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "Delete file from hard disk:"
		AcLanguageText1	WAIT_DEL_FILE_Please_wait, x=32, y=56, w=260, h=24, index=49, font=idCHARA3, fontcolor=CL_Red, lines=1	; EN "Please wait ..."
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_HD_FORMAT -- TtlScreenR2 "   HD FORMAT"
; opened by: ERR_HD_FORMAT_Exit_ATTEN_HD_FORMAT.screen,
;            AGAIN_HD_FORMAT_Exit_ATTEN_HD_FORMAT.screen, HDAE5000_SetupP2SwCatch,
;            HDAE5000_AttenHDFormatSwCatch_OnCancel
; -----------------------------------------------------------------------------
	TtlScreenR2	ATTEN_HD_FORMAT, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_HD_FORMAT_window, icon=idICON_None, title="   HD FORMAT"
	ui_sub
		TextBox	ATTEN_HD_FORMAT_HD_FORMAT_will_erase_all, x=36, y=38, w=248, h=176, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=5, text=""
		ui_sub
			AcLanguageText1	ATTEN_HD_FORMAT_HD_FORMAT_will_erase_all_Text, x=38, y=70, w=244, h=34, index=24, font=idCHARA1W, fontcolor=CL_Text, lines=2	; EN "HD FORMAT will erase all files at once."
			AcLanguageText1	ATTEN_After_your_code_input_al, x=38, y=164, w=244, h=48, index=26, font=idCHARA1W, fontcolor=CL_Text, lines=3	; EN "After your code input all data will be deleted irrevocable!"
			AcLanguageText1	ATTEN_Therefore_you_need_a_6_d, x=38, y=104, w=244, h=64, index=25, font=idCHARA1W, fontcolor=CL_Black, lines=4	; EN "Therefore you need a 6-digit key code. Please refer your owners manual chapter SETUP & TOOLS."
			AcLanguageText1	ATTEN_HD_FORMAT_HD_FORMAT_will_erase_all_ATTENTION, x=38, y=46, w=244, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
		ui_endsub
		VwUserBitmap	ATTEN_HD_FORMAT_VwUserBitmap, x=93, y=1, w=27, h=27
		VwWideESBox	ATTEN_HD_FORMAT_CANCEL, x=244, y=216, w=72, h=23, border=BD_3D_UP1, editsw=ES_Bottom7, editsw2=ES_Bottom8, str="CANCEL"
		IvCatchEvent	HD_FORMAT_CATCH, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_AttenHDFormatSwCatch
	ui_endsub

; -----------------------------------------------------------------------------
; WAIT_HD_FORMAT -- Window
; opened by: HDAE5000_AttenHDFormatSwCatch_OnCancel
; -----------------------------------------------------------------------------
	Window	WAIT_HD_FORMAT, x=26, y=30, w=268, h=184, border=BD_EditSwitch, parent=HdaeUiVar_WAIT_HD_FORMAT_parent, child=HdaeUiVar_WAIT_HD_FORMAT_child
	ui_sub
		AcLanguageText1	WAIT_HD_FORMAT_The_hard_disk_will_now_b, x=32, y=38, w=256, h=56, index=57, font=idCHARA1, fontcolor=CL_Black, alignment=AL_LeftJustify, lines=3	; EN "The hard disk will now be formatted. This procedure can take about 2-3 minutes."
		AcLanguageText1	WAIT_HD_FORMAT_We_recommend_to_turn_ON_, x=32, y=98, w=256, h=56, index=58, font=idCHARA1, fontcolor=CL_Black, alignment=AL_LeftJustify, lines=3	; EN "We recommend to turn ON and OFF again the power after the complete format."
		AcLanguageText1	WAIT_HD_FORMAT_Please_wait, x=32, y=154, w=260, h=48, index=49, font=idCHARA3, fontcolor=CL_Red, lines=1	; EN "Please wait ..."
	ui_endsub

; -----------------------------------------------------------------------------
; SETUP_HDINFO -- TtlScreenR2
; opened by: HDAE5000_SetupP2SwCatch
; -----------------------------------------------------------------------------
	TtlScreenR2	SETUP_HDINFO, x=0, y=0, w=320, h=240, window=HdaeUiVar_SETUP_HDINFO_window, icon=idICON_None, title=""
	ui_sub
		IvExitScreen	SETUP_HDINFO_Exit_SETUPS_TOOLS, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_SETUPS_TOOLS
		StringBox	SETUP_HDINFO_HD_INFO, x=100, y=12, w=120, h=40, color=CL_WallPattern, border=BD_3D_UP2, font=idCHARA5, fontcolor=CL_White, str="HD-INFO"
		SelectList	HD_INFO_LIST, x=3, y=72, w=314, h=150, color=CL_WallPattern, index=0xffff, font=idCHARA1, str_adr=HdaeUiVar_HD_INFO_LIST_str_adr, row=8, sel_num=HdaeUiVar_HD_INFO_LIST_sel_num, en_paradraw=HdaeUiVar_HD_INFO_LIST_en_paradraw
		ui_sub
			Line	HD_INFO_LIST_Line, x=3, y=199, w=314, h=1
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; DBG_MEMO_SCREEN -- TtlScreenR "DEBUG MEMO SCREEN"
; -----------------------------------------------------------------------------
	TtlScreenR	DBG_MEMO_SCREEN, x=0, y=0, w=320, h=240, window=HdaeUiVar_DBG_MEMO_SCREEN_window, icon=idICON_Default, title="DEBUG MEMO SCREEN"
	ui_sub
		IvExitScreen	DBG_MEMO_SCREEN_Exit_HDDMENU, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		DbMemo	DBG_MEMO_SCREEN_DbMemo, x=10, y=40, w=299, h=190
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_DEL_FLS1 -- TtlScreenR
; opened by: HDAE5000_FlsEditScreen_OnSwIn
; -----------------------------------------------------------------------------
	TtlScreenR	ATTEN_DEL_FLS1, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_DEL_FLS1_window, icon=idICON_None, title=""
	ui_sub
		IvCatchEvent	ATTEN_DEL_FLS1_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_FlsDel1SwCatch
		AcLanguageText1	ATTEN_DEL_FLS1_ATTENTION, x=40, y=44, w=240, h=166, color=CL_Silver, border=BD_EditSwitch, index=210, font=idCHARA3, fontcolor=CL_Black, lines=5	; EN "!ATTENTION!"
		ui_sub
			AcLanguageText1	ATTEN_DEL_FLS1_ATTENTION_Press_YES_for_confirmati, x=44, y=158, w=232, h=50, index=211, font=idCHARA1W, fontcolor=CL_Black, lines=3	; EN "Press YES for confirmation, NO to abort."
			AcLanguageText1	ATTEN_DEL_FLS1_ATTENTION_You_are_going_to_delete_, x=44, y=76, w=232, h=48, index=27, font=idCHARA1W, fontcolor=CL_FireRed, lines=3	; EN "You are going to delete a FLS entry. Are you sure?"
			AcLanguageText1	ATTEN_DEL_FLS1_ATTENTION_The_FLS_entry_remains_fr, x=44, y=124, w=232, h=36, index=60, font=idCHARA1W, fontcolor=CL_Yellow, lines=2	; EN "The FLS entry remains free."
		ui_endsub
		VwWideESBox	ATTEN_DEL_FLS1_YES, x=4, y=216, w=72, h=23, editsw=ES_Bottom1, editsw2=ES_Bottom2, str=""
		ui_sub
			AcLanguageText1	ATTEN_DEL_FLS1_YES_Text, x=4, y=220, w=72, h=20, index=200, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "YES"
		ui_endsub
		VwWideESBox	ATTEN_DEL_FLS1_YES_2, x=4, y=216, w=72, h=23, editsw=ES_Bottom1, editsw2=ES_Bottom2, str=""
		ui_sub
			AcLanguageText1	ATTEN_DEL_FLS1_YES_2_YES, x=4, y=220, w=72, h=20, index=200, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "YES"
		ui_endsub
		VwWideESBox	ATTEN_DEL_FLS1_NO, x=244, y=216, w=72, h=23, editsw=ES_Bottom7, editsw2=ES_Bottom8, str=""
		ui_sub
			AcLanguageText1	ATTEN_DEL_FLS1_NO_Text, x=248, y=220, w=68, h=20, index=201, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "NO"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_OVER_FILE -- TtlScreenR
; opened by: HDAE5000_HDDNamingCheck_Join, HDAE5000_SaveOptSwEventCatch_OnSwIn
; -----------------------------------------------------------------------------
	TtlScreenR	ATTEN_OVER_FILE, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_OVER_FILE_window, icon=idICON_None, title=""
	ui_sub
		IvCatchEvent	ATTEN_OVER_FILE_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_WrConfirmEventCatch
		VwWideESBox	ATTEN_OVER_FILE_JA, x=4, y=216, w=72, h=23, editsw=ES_Bottom1, editsw2=ES_Bottom2, str="JA"
		VwWideESBox	ATTEN_OVER_FILE_NEIN, x=244, y=216, w=72, h=23, editsw=ES_Bottom7, editsw2=ES_Bottom8, str="NEIN"
		TextBox	ATTEN_OVER_FILE_ACHTUNG, x=40, y=84, w=240, h=88, color=CL_IconBack, border=BD_EditSwDown, font=idCHARA3, lines=3, text="!ACHTUNG!"
		ui_sub
			TextBox	ATTEN_OVER_FILE_ACHTUNG_Sie_berschreiben_einen_b, x=50, y=116, w=220, h=50, color=CL_Transparent, border=BD_None, font=idCHARA1W, fontcolor=CL_Selected, lines=3, text="Sie \374berschreiben einen bestehenden Titel. Sind Sie sicher?"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; HDD_FLS_NAMING2 -- TtlScreenR "EDIT FLS NAME"
; opened by: HDAE5000_FlsLoadScreen_OnHdaeSelectSave
; -----------------------------------------------------------------------------
	TtlScreenR	HDD_FLS_NAMING2, x=0, y=0, w=320, h=240, window=HdaeUiVar_HDD_FLS_NAMING2_window, icon=idICON_i173, title="EDIT FLS NAME"
	ui_sub
		IvNaming	HDD_FLS_NAMING2_IvNaming, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_FlsNamingCheck2
		IvExitScreen	HDD_FLS_NAMING2_Exit_FLS_EDIT, x=32, y=0, w=32, h=32, screen=HDAE5000_OBJ_FLS_EDIT
		AcFuncEditSw	HDD_FLS_NAMING2_AcFuncEditSw, x=281, y=160, w=31, h=18, color=CL_Selected, editsw=ES_Right4, style=SS_OK, func=NAKA_APFUNC_FlsNamingCheck
		AcFuncEditSw	HDD_FLS_NAMING2_AcFuncEditSw_2, x=8, y=118, w=31, h=18, color=CL_Silver, editsw=ES_Left3, style=SS_Special, func=NAKA_APFUNC_FlsNamingCheck
		ui_sub
			Label	HDD_FLS_NAMING2_AcFuncEditSw_2_LST, x=9, y=119, w=28, h=19, font=idCHARA1, fontcolor=CL_Red, str="LST"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_CPHD_WR -- TtlScreenR
; opened by: HDAE5000_HDDTitleSwCatch
; -----------------------------------------------------------------------------
	TtlScreenR	ATTEN_CPHD_WR, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_CPHD_WR_window, icon=idICON_None, title=""
	ui_sub
		IvCatchEvent	ATTEN_CPHD_WR_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_AttenCpToHDSwCatch
		VwWideESBox	ATTEN_CPHD_WR_VwWideESBox, x=244, y=216, w=72, h=23, editsw=ES_Bottom7, editsw2=ES_Bottom8, str=""
		TextBox	ATTEN_CPHD_WR_The_hard_disk_is_write_p, x=40, y=84, w=240, h=116, color=CL_IconBack, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		ui_sub
			AcLanguageText1	ATTEN_CPHD_WR_The_hard_disk_is_write_p_Text, x=42, y=120, w=244, h=38, index=29, font=idCHARA1W, fontcolor=CL_Red, lines=2	; EN "The hard disk is write protected!"
			AcLanguageText1	ATTEN_Please_set_the_write_pro, x=40, y=160, w=240, h=38, index=30, font=idCHARA1W, fontcolor=CL_Black, lines=2	; EN "Please set the write protect mode to OFF."
		ui_endsub
		AcLanguageText1	ATTEN_CPHD_WR_ATTENTION, x=40, y=94, w=240, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
		AcLanguageText1	ATTEN_CPHD_WR_CANCEL, x=248, y=220, w=68, h=20, index=203, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "CANCEL"
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_HD_NOT_FMT -- TtlScreenR
; -----------------------------------------------------------------------------
	TtlScreenR	ERR_HD_NOT_FMT, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_HD_NOT_FMT_window, icon=idICON_None, title=""
	ui_sub
		TextBox	ERR_HD_NOT_FMT_The_hard_disk_is_not_for, x=36, y=84, w=248, h=120, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		ui_sub
			AcLanguageText1	ERR_HD_NOT_FMT_The_hard_disk_is_not_for_Text, x=38, y=124, w=244, h=40, index=31, font=idCHARA1W, fontcolor=CL_Yellow, lines=2	; EN "The hard disk is not formatted!"
		ui_endsub
		AcLanguageText1	ERR_HD_NOT_FMT_SYSTEM_ERROR, x=39, y=94, w=244, h=24, index=209, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!SYSTEM ERROR!"
		AcLanguageText1	ERR_HD_NOT_FMT_Please_call_your_dealer_, x=40, y=164, w=240, h=40, index=212, font=idCHARA1, fontcolor=CL_Black, lines=2	; EN "Please call your dealer or service center."
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_HD_SRAM -- TtlScreenR
; -----------------------------------------------------------------------------
	TtlScreenR	ERR_HD_SRAM, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_HD_SRAM_window, icon=idICON_None, title=""
	ui_sub
		TextBox	ERR_HD_SRAM_TextBox, x=36, y=84, w=248, h=120, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		AcLanguageText1	ERR_HD_SRAM_Hard_disk_SRAM_error, x=40, y=122, w=240, h=40, index=32, font=idCHARA1, fontcolor=CL_Yellow, lines=2	; EN "Hard disk SRAM error."
		AcLanguageText1	ERR_HD_SRAM_SYSTEM_ERROR, x=39, y=94, w=244, h=24, index=209, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!SYSTEM ERROR!"
		AcLanguageText1	ERR_HD_SRAM_Please_call_your_dealer_, x=40, y=164, w=240, h=40, index=212, font=idCHARA1, fontcolor=CL_Black, lines=2	; EN "Please call your dealer or service center."
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_HD_RESET -- TtlScreenR
; -----------------------------------------------------------------------------
	TtlScreenR	ERR_HD_RESET, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_HD_RESET_window, icon=idICON_None, title=""
	ui_sub
		TextBox	ERR_HD_RESET_TextBox, x=36, y=84, w=248, h=120, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		AcLanguageText1	ERR_HD_RESET_Hard_disk_reset_error, x=40, y=122, w=240, h=40, index=33, font=idCHARA1, fontcolor=CL_Yellow, lines=2	; EN "Hard disk reset error."
		AcLanguageText1	ERR_HD_RESET_SYSTEM_ERROR, x=39, y=94, w=244, h=24, index=209, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!SYSTEM ERROR!"
		AcLanguageText1	ERR_HD_RESET_Please_call_your_dealer_, x=40, y=164, w=240, h=40, index=212, font=idCHARA1, fontcolor=CL_Black, lines=2	; EN "Please call your dealer or service center."
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_HD_READ -- TtlScreenR
; -----------------------------------------------------------------------------
	TtlScreenR	ERR_HD_READ, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_HD_READ_window, icon=idICON_None, title=""
	ui_sub
		TextBox	ERR_HD_READ_Hard_disk_read_error, x=36, y=84, w=248, h=120, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		ui_sub
			AcLanguageText1	ERR_HD_READ_Hard_disk_read_error_Text, x=34, y=124, w=244, h=38, index=34, font=idCHARA1W, fontcolor=CL_Yellow, lines=2	; EN "Hard disk read error."
		ui_endsub
		AcLanguageText1	ERR_HD_READ_SYSTEM_ERROR, x=39, y=94, w=244, h=24, index=209, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!SYSTEM ERROR!"
		AcLanguageText1	ERR_HD_READ_Please_call_your_dealer_, x=40, y=164, w=240, h=40, index=212, font=idCHARA1, fontcolor=CL_Black, lines=2	; EN "Please call your dealer or service center."
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_HD_ID_READ -- TtlScreenR
; -----------------------------------------------------------------------------
	TtlScreenR	ERR_HD_ID_READ, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_HD_ID_READ_window, icon=idICON_None, title=""
	ui_sub
		TextBox	ERR_HD_ID_READ_Hard_disk_ID_read_error, x=36, y=84, w=248, h=120, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		ui_sub
			AcLanguageText1	ERR_HD_ID_READ_Hard_disk_ID_read_error_Text, x=38, y=124, w=244, h=38, index=35, font=idCHARA1W, fontcolor=CL_Yellow, lines=2	; EN "Hard disk ID read error."
		ui_endsub
		AcLanguageText1	ERR_HD_ID_READ_SYSTEM_ERROR, x=39, y=94, w=244, h=24, index=209, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!SYSTEM ERROR!"
		AcLanguageText1	ERR_HD_ID_READ_Please_call_your_dealer_, x=40, y=164, w=240, h=40, index=212, font=idCHARA1, fontcolor=CL_Black, lines=2	; EN "Please call your dealer or service center."
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_HD_TRACK_0 -- TtlScreenR
; -----------------------------------------------------------------------------
	TtlScreenR	ERR_HD_TRACK_0, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_HD_TRACK_0_window, icon=idICON_None, title=""
	ui_sub
		TextBox	ERR_HD_TRACK_0_Hard_disk_track_0_error, x=36, y=84, w=248, h=120, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		ui_sub
			AcLanguageText1	ERR_HD_TRACK_0_Hard_disk_track_0_error_Text, x=38, y=120, w=244, h=38, index=36, font=idCHARA1W, fontcolor=CL_Yellow, lines=2	; EN "Hard disk track 0 error."
		ui_endsub
		AcLanguageText1	ERR_HD_TRACK_0_SYSTEM_ERROR, x=39, y=94, w=244, h=24, index=209, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!SYSTEM ERROR!"
		AcLanguageText1	ERR_HD_TRACK_0_Please_call_your_dealer_, x=40, y=164, w=240, h=40, index=212, font=idCHARA1, fontcolor=CL_Black, lines=2	; EN "Please call your dealer or service center."
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_HD_FAT -- TtlScreenR
; -----------------------------------------------------------------------------
	TtlScreenR	ERR_HD_FAT, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_HD_FAT_window, icon=idICON_None, title=""
	ui_sub
		TextBox	ERR_HD_FAT_SYSTEM_ERROR, x=36, y=84, w=248, h=120, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		ui_sub
			AcLanguageText1	ERR_HD_FAT_SYSTEM_ERROR_Text, x=39, y=94, w=244, h=24, index=209, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!SYSTEM ERROR!"
			AcLanguageText1	ERR_HD_FAT_SYSTEM_ERROR_Please_call_your_dealer_, x=40, y=164, w=240, h=40, index=212, font=idCHARA1, fontcolor=CL_Black, lines=2	; EN "Please call your dealer or service center."
			AcLanguageText1	ERR_HD_FAT_SYSTEM_ERROR_Hard_disk_FAT_read_error, x=38, y=120, w=244, h=38, index=37, font=idCHARA1W, fontcolor=CL_Yellow, lines=2	; EN "Hard disk FAT read error."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_HD_FSB -- TtlScreenR
; -----------------------------------------------------------------------------
	TtlScreenR	ERR_HD_FSB, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_HD_FSB_window, icon=idICON_None, title=""
	ui_sub
		TextBox	ERR_HD_FSB_Please_call_your_dealer_, x=36, y=84, w=248, h=120, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		ui_sub
			AcLanguageText1	ERR_HD_FSB_Please_call_your_dealer__Text, x=40, y=164, w=240, h=40, index=212, font=idCHARA1, fontcolor=CL_Black, lines=2	; EN "Please call your dealer or service center."
			AcLanguageText1	ERR_HD_FSB_Please_call_your_dealer__SYSTEM_ERROR, x=39, y=94, w=244, h=24, index=209, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!SYSTEM ERROR!"
			AcLanguageText1	ERR_HD_FSB_Please_call_your_dealer__Hard_disk_FSB_read_error, x=38, y=120, w=244, h=38, index=38, font=idCHARA1W, fontcolor=CL_Yellow, lines=2	; EN "Hard disk FSB read error."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_CPFD_MARK -- TtlScreenR
; opened by: HDAE5000_CopyToHDScreen
; -----------------------------------------------------------------------------
	TtlScreenR	ATTEN_CPFD_MARK, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_CPFD_MARK_window, icon=idICON_None, title=""
	ui_sub
		IvCatchEvent	ATTEN_CPFD_MARK_IvCatchEvent, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_AttenCpToMarkSwCatch
		VwWideESBox	ATTEN_CPFD_MARK_CANCEL, x=244, y=216, w=72, h=23, editsw=ES_Bottom7, editsw2=ES_Bottom8, str=""
		ui_sub
			AcLanguageText1	ATTEN_CPFD_MARK_CANCEL_Text, x=248, y=220, w=68, h=20, index=203, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "CANCEL"
		ui_endsub
		TextBox	ATTEN_CPFD_MARK_ATTENTION, x=40, y=84, w=240, h=85, color=CL_IconBack, border=BD_EditSwitch, font=idCHARA3, lines=2, text=""
		ui_sub
			AcLanguageText1	ATTEN_CPFD_MARK_ATTENTION_Text, x=40, y=94, w=240, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
			AcLanguageText1	ATTEN_CPFD_MARK_ATTENTION_There_are_no_files_marke, x=40, y=122, w=240, h=38, index=39, font=idCHARA1W, fontcolor=CL_Red, lines=2	; EN "There are no files marked for copy to HD!"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; ABOUT_HELP -- TtlScreenR "            "
; opened by: SETUP_TOOLS_P2_Go_ABOUT_HELP.screen
; -----------------------------------------------------------------------------
	TtlScreenR	ABOUT_HELP, x=0, y=0, w=320, h=240, window=HdaeUiVar_ABOUT_HELP_window, icon=idICON_Default, title="            "
	ui_sub
		VwUserBitmap	ABOUT_HELP_VwUserBitmap, x=76, y=1, w=27, h=27
		TextBox	ABOUT_HELP_TextBox, x=25, y=68, w=270, h=52, color=CL_Silver, border=BD_3D_UP1, font=idCHARA1, alignment=AL_LeftJustify, lines=3, text=""
		ui_sub
			Label	ABOUT_HELP_TextBox_Label, x=29, y=69, w=4, h=11, font=idCHARA4, fontcolor=CL_Black, str=""
			Label	ABOUT_HELP_TextBox_Technosoft_CH_Samstagern, x=29, y=84, w=204, h=19, font=idCHARA1, fontcolor=CL_Black, str="Technosoft, CH-Samstagern"
			Label	ABOUT_HELP_TextBox_Pointstyle_CH_Buttisholz, x=29, y=100, w=204, h=19, font=idCHARA1, fontcolor=CL_Black, str="Pointstyle, CH-Buttisholz"
			AcLanguageText1	ABOUT_HELP_TextBox_Hardware_and_software_de, x=27, y=69, w=260, h=16, index=17, font=idCHARA4, fontcolor=CL_Black, alignment=AL_LeftJustify, lines=1	; EN "Hardware and software developement:"
		ui_endsub
		TextBox	ABOUT_HELP_TextBox_2, x=25, y=120, w=270, h=60, color=CL_Silver, border=BD_3D_UP1, font=idCHARA1, alignment=AL_LeftJustify, lines=3, text=""
		ui_sub
			Label	ABOUT_HELP_TextBox_2_KEY_SOFT_SERVICE_CH_Sche, x=29, y=137, w=236, h=19, font=idCHARA1, fontcolor=CL_Black, str="KEY SOFT SERVICE, CH-Schenkon"
			Label	ABOUT_HELP_TextBox_2_Fax_41_41_922_03_15, x=29, y=154, w=136, h=11, font=idCHARA4, fontcolor=CL_Black, str="Fax.  +41-41-922 03 15"
			Label	ABOUT_HELP_TextBox_2_email_keysoftservice_blu, x=29, y=165, w=190, h=11, font=idCHARA4, fontcolor=CL_Black, str="email:keysoftservice@bluewin.ch"
			AcLanguageText1	ABOUT_HELP_TextBox_2_Conception_marketing_sal, x=27, y=122, w=260, h=16, index=18, font=idCHARA4, fontcolor=CL_Black, alignment=AL_LeftJustify, lines=1	; EN "Conception, marketing, sales and service:"
		ui_endsub
		TextBox	ABOUT_HELP_All_rigths_reserved_by_t, x=25, y=180, w=270, h=20, color=CL_Silver, border=BD_3D_UP1, font=idCHARA1, alignment=AL_LeftJustify, lines=3, text=""
		ui_sub
			AcLanguageText1	ABOUT_HELP_All_rigths_reserved_by_t_Text, x=27, y=182, w=268, h=16, index=19, font=idCHARA4, fontcolor=CL_Black, alignment=AL_LeftJustify, lines=1	; EN "All rigths reserved by the called companies"
		ui_endsub
		TextBox	ABOUT_HELP_TextBox_3, x=25, y=205, w=270, h=33, color=CL_Silver, border=BD_3D_UP1, font=idCHARA1, alignment=AL_LeftJustify, lines=3, text=""
		ui_sub
			Label	ABOUT_HELP_TextBox_3_Mr_T_Hamaguchi_and_Mr_M_, x=29, y=218, w=261, h=19, font=idCHARA1P, fontcolor=CL_Black, str="Mr. T.Hamaguchi and Mr. M.Kitajima"
			AcLanguageText1	ABOUT_HELP_TextBox_3_Special_thanks_to, x=27, y=206, w=200, h=16, index=20, font=idCHARA4, fontcolor=CL_Black, alignment=AL_LeftJustify, lines=1	; EN "Special thanks to:"
		ui_endsub
		IvExitScreen	ABOUT_HELP_Exit_SETUPS_TOOLS, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_SETUPS_TOOLS
		AcLanguageText1	ABOUT_HELP_Text, x=101, y=0, w=180, h=32, index=10, font=idCHARA5W, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1	; EN "ABOUT & HELP "
	ui_endsub

; -----------------------------------------------------------------------------
; WAIT_TR0_RECOVER -- Window
; opened by: HDAE5000_AttenHDFormatSwCatch_OnCancel
; -----------------------------------------------------------------------------
	Window	WAIT_TR0_RECOVER, x=26, y=30, w=268, h=60, border=BD_EditSwitch, parent=HdaeUiVar_WAIT_TR0_RECOVER_parent, child=HdaeUiVar_WAIT_TR0_RECOVER_child
	ui_sub
		AcLanguageText1	WAIT_TR0_RECOVER_Track_O_will_be_recovere, x=40, y=34, w=240, h=24, index=59, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "Track O will be recovered:"
		AcLanguageText1	WAIT_TR0_RECOVER_Please_wait, x=32, y=58, w=260, h=24, index=49, font=idCHARA3, fontcolor=CL_Red, lines=1	; EN "Please wait ..."
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_SAVE -- IvScreenR2
; opened by: HDAE5000_AttenHDFormatSwCatch_OnCancel, HDAE5000_FlsEditScreen_OnHdaeSelectSave,
;            HDAE5000_CopyToHd_Execute, HDAE5000_DirName_StoreWithUi, HDAE5000_FlsName_StoreWithUi,
;            HDAE5000_SaveSongWithUi
; -----------------------------------------------------------------------------
	IvScreenR2	ERR_SAVE, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_SAVE_window
	ui_sub
		ui_ram_object	ERR_SAVE_EXIT, IvExitScreen
		IvCatchEvent	ERR_SAVE_CATCH, x=0, y=32, w=32, h=32, func=NAKA_APFUNC_ErrMsgTimerCatch
		TextBox	ERR_SAVE_Please_make_a_safety_bac, x=40, y=84, w=240, h=110, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		ui_sub
			AcLanguageText1	ERR_SAVE_Please_make_a_safety_bac_Text, x=40, y=120, w=240, h=72, index=41, font=idCHARA1W, fontcolor=CL_Yellow, lines=4	; EN "Please make a safety backup of your data and call your service center."
		ui_endsub
		AcLanguageText1	ERR_SAVE_ATTENTION, x=40, y=94, w=240, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_LOAD -- IvScreenR2
; opened by: HDAE5000_LoadSongWithUi
; -----------------------------------------------------------------------------
	IvScreenR2	ERR_LOAD, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_LOAD_window
	ui_sub
		ui_ram_object	ERR_LOAD_EXIT, IvExitScreen
		IvCatchEvent	ERR_LOAD_CATCH, x=0, y=36, w=32, h=32, func=NAKA_APFUNC_ErrMsgTimerCatch
		TextBox	ERR_LOAD_ATTENTION, x=40, y=84, w=240, h=110, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=3, text=""
		ui_sub
			AcLanguageText1	ERR_LOAD_ATTENTION_Text, x=40, y=94, w=240, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
		ui_endsub
		AcLanguageText1	ERR_LOAD_Please_make_a_safety_bac, x=40, y=120, w=240, h=72, index=41, font=idCHARA1W, fontcolor=CL_Yellow, lines=4	; EN "Please make a safety backup of your data and call your service center."
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_NO_HK_DATA -- IvScreenR2
; opened by: HDAE5000_CopyToHd_Execute
; -----------------------------------------------------------------------------
	IvScreenR2	ERR_NO_HK_DATA, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_NO_HK_DATA_window
	ui_sub
		IvExitScreen	ERR_NO_HK_DATA_Exit_CP_FD, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_CP_FD
		IvCatchEvent	ERR_NO_HK_DATA_CATCH, x=0, y=32, w=32, h=32, func=NAKA_APFUNC_ErrMsgTimerCatch
		TextBox	ERR_NO_HK_DATA_ATTENTION, x=40, y=84, w=240, h=120, color=CL_Silver, border=BD_EditSwitch, font=idCHARA1, lines=5, text=""
		ui_sub
			AcLanguageText1	ERR_NO_HK_DATA_ATTENTION_Text, x=40, y=94, w=240, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
			AcLanguageText1	ERR_NO_HK_DATA_ATTENTION_The_data_on_the_disk_you, x=40, y=124, w=240, h=72, index=42, font=idCHARA1W, fontcolor=CL_Red, lines=4	; EN "The data on the disk you would like to copy to HD has no KN5000 format or some data are corrupted."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_FULL_DIR -- IvScreenR2
; opened by: HDAE5000_CopyToHDDirSelScreen
; -----------------------------------------------------------------------------
	IvScreenR2	ATTEN_FULL_DIR, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_FULL_DIR_window
	ui_sub
		IvExitScreen	ATTEN_FULL_DIR_Exit_CP_FD_DIRSEL, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_CP_FD_DIRSEL
		IvCatchEvent	ATTEN_FULL_DIR_CATCH, x=0, y=32, w=32, h=32, func=NAKA_APFUNC_ErrMsgTimerCatch
		TextBox	ATTEN_FULL_DIR_ATTENTION, x=40, y=50, w=240, h=160, color=CL_IconBack, border=BD_EditSwitch, font=idCHARA3, lines=4, text=""
		ui_sub
			AcLanguageText1	ATTEN_FULL_DIR_ATTENTION_Text, x=40, y=56, w=240, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
			AcLanguageText1	ATTEN_FULL_DIR_ATTENTION_The_number_or_marked_son, x=40, y=82, w=240, h=72, index=43, font=idCHARA1W, fontcolor=CL_Red, lines=4	; EN "The number or marked songs cannot fit in the free space of the selected directory."
			AcLanguageText1	ATTEN_FULL_DIR_ATTENTION_Reduce_the_number_of_sel, x=40, y=152, w=240, h=52, index=44, font=idCHARA1W, fontcolor=CL_Yellow, lines=3	; EN "Reduce the number of selected songs or find a free directory."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; ATTEN_CP_UNNAMED -- IvScreenR2
; opened by: HDAE5000_CopyToHDDirSelScreen
; -----------------------------------------------------------------------------
	IvScreenR2	ATTEN_CP_UNNAMED, x=0, y=0, w=320, h=240, window=HdaeUiVar_ATTEN_CP_UNNAMED_window
	ui_sub
		IvExitScreen	ATTEN_CP_UNNAMED_Exit_CP_FD_DIRSEL, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_CP_FD_DIRSEL
		IvCatchEvent	ATTEN_CP_UNNAMED_CATCH, x=0, y=32, w=32, h=32, func=NAKA_APFUNC_ErrMsgTimerCatch
		TextBox	ATTEN_CP_UNNAMED_Please_use_a_named_direc, x=40, y=50, w=240, h=160, color=CL_IconBack, border=BD_EditSwitch, font=idCHARA3, lines=4, text=""
		ui_sub
			AcLanguageText1	ATTEN_CP_UNNAMED_Please_use_a_named_direc_Text, x=40, y=140, w=240, h=68, index=46, font=idCHARA1, fontcolor=CL_Black, lines=4	; EN "Please use a named directory or create the new directory with EDIT first."
			AcLanguageText1	ATTEN_CP_UNNAMED_Please_use_a_named_direc_ATTENTION, x=40, y=56, w=240, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
			AcLanguageText1	ATTEN_You_cannot_copy_files_so, x=40, y=84, w=240, h=52, index=45, font=idCHARA1W, fontcolor=CL_Red, lines=3	; EN "You cannot copy files/songs to an unnamed directory."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; DIR_OUT_RANGE -- IvScreenR2
; opened by: HDAE5000_Lbn_TypeDigit
; -----------------------------------------------------------------------------
	IvScreenR2	DIR_OUT_RANGE, x=0, y=0, w=320, h=240, window=HdaeUiVar_DIR_OUT_RANGE_window
	ui_sub
		IvCatchEvent	DIR_OUT_RANGE_CATCH, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_ErrMsgTimerCatchLBN
		TextBox	DIR_OUT_RANGE_The_DIR_number_is_out_of, x=40, y=84, w=240, h=80, color=CL_Silver, border=BD_EditSwitch, font=idCHARA3, lines=2, text=""
		ui_sub
			AcLanguageText1	DIR_OUT_RANGE_The_DIR_number_is_out_of_Text, x=40, y=120, w=240, h=40, index=47, font=idCHARA1W, fontcolor=CL_Red, lines=2	; EN "The DIR number is out of range."
		ui_endsub
		AcLanguageText1	DIR_OUT_RANGE_ATTENTION, x=40, y=92, w=240, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
	ui_endsub

; -----------------------------------------------------------------------------
; FILE_OUT_RANGE -- IvScreenR2
; opened by: HDAE5000_Lbn_TypeDigit
; -----------------------------------------------------------------------------
	IvScreenR2	FILE_OUT_RANGE, x=0, y=0, w=320, h=240, window=HdaeUiVar_FILE_OUT_RANGE_window
	ui_sub
		IvCatchEvent	FILE_OUT_RANGE_CATCH, x=0, y=0, w=32, h=32, func=NAKA_APFUNC_ErrMsgTimerCatchLBN
		TextBox	FILE_OUT_RANGE_ATTENTION, x=40, y=84, w=240, h=80, color=CL_Silver, border=BD_EditSwitch, font=idCHARA3, lines=2, text=""
		ui_sub
			AcLanguageText1	FILE_OUT_RANGE_ATTENTION_Text, x=40, y=92, w=240, h=24, index=210, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!ATTENTION!"
		ui_endsub
		AcLanguageText1	FILE_OUT_RANGE_The_file_number_is_out_o, x=44, y=120, w=230, h=40, index=48, font=idCHARA1W, fontcolor=CL_Red, lines=2	; EN "The file number is out of range."
	ui_endsub

; -----------------------------------------------------------------------------
; HD_PLEASE -- IvScreenR2
; opened by: HDAE5000_SetupP2SwCatch, HDAE5000_FlsEditScreen_OnHdaeSelectSave,
;            HDAE5000_FlsFileSelScreen_OnHdaeSelectOk, HDAE5000_FlsOverWrSwCatch_Join,
;            HDAE5000_CopyToHDDirSelScreen, HDAE5000_DirName_StoreWithUi,
;            HDAE5000_FlsName_StoreWithUi, HDAE5000_LoadSongWithUi, HDAE5000_SaveSongWithUi
; -----------------------------------------------------------------------------
	IvScreenR2	HD_PLEASE, x=0, y=0, w=320, h=240, window=HdaeUiVar_HD_PLEASE_window
	ui_sub
		TextBox	HD_PLEASE_Please_wait, x=60, y=84, w=200, h=48, color=CL_Orange, border=BD_3D_UP2, font=idCHARA2, lines=1, text=""
		ui_sub
			AcLanguageText1	HD_PLEASE_Please_wait_Text, x=72, y=98, w=170, h=24, index=49, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "Please wait ..."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; ERR_HD_FORMAT -- IvScreenR2
; opened by: HDAE5000_AttenHDFormatSwCatch_OnCancel
; -----------------------------------------------------------------------------
	IvScreenR2	ERR_HD_FORMAT, x=0, y=0, w=320, h=240, window=HdaeUiVar_ERR_HD_FORMAT_window
	ui_sub
		IvExitScreen	ERR_HD_FORMAT_Exit_ATTEN_HD_FORMAT, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_ATTEN_HD_FORMAT
		IvCatchEvent	ERR_HD_FORMAT_CATCH, x=0, y=32, w=32, h=32, func=NAKA_APFUNC_ErrMsgTimerCatch
		TextBox	ERR_HD_FORMAT_The_automatic_HD_format_, x=32, y=78, w=256, h=150, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=5, text=""
		ui_sub
			AcLanguageText1	ERR_HD_FORMAT_The_automatic_HD_format__Text, x=40, y=116, w=240, h=36, index=51, font=idCHARA1, fontcolor=CL_Yellow, lines=2	; EN "The automatic HD format was not successful!"
			AcLanguageText1	ERR_HD_FORMAT_The_automatic_HD_format__FORMAT_ERROR, x=30, y=80, w=260, h=36, index=50, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "!FORMAT ERROR!"
			AcLanguageText1	ERR_Please_try_once_more_ref, x=40, y=156, w=240, h=72, index=52, font=idCHARA1W, fontcolor=CL_Black, lines=4	; EN "Please try once more, refer your owners manual or ask your dealer/service center."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; AGAIN_HD_FORMAT -- IvScreenR2
; opened by: HDAE5000_AttenHDFormatSwCatch_OnCancel
; -----------------------------------------------------------------------------
	IvScreenR2	AGAIN_HD_FORMAT, x=0, y=0, w=320, h=240, window=HdaeUiVar_AGAIN_HD_FORMAT_window
	ui_sub
		IvExitScreen	AGAIN_HD_FORMAT_Exit_ATTEN_HD_FORMAT, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_ATTEN_HD_FORMAT
		IvCatchEvent	AGAIN_HD_FORMAT_CATCH, x=0, y=32, w=32, h=32, func=NAKA_APFUNC_ErrMsgTimerCatch
		TextBox	AGAIN_HD_FORMAT_Input_error, x=32, y=78, w=256, h=150, color=CL_Red, border=BD_EditSwitch, font=idCHARA3, lines=5, text=""
		ui_sub
			AcLanguageText1	AGAIN_HD_FORMAT_Input_error_Text, x=34, y=80, w=260, h=36, index=53, font=idCHARA3, fontcolor=CL_Black, lines=1	; EN "Input error!"
			AcLanguageText1	AGAIN_HD_FORMAT_Input_error_The_key_code_input_was_w, x=40, y=116, w=240, h=36, index=54, font=idCHARA1, fontcolor=CL_Yellow, lines=2	; EN "The key code input was wrong!"
			AcLanguageText1	AGAIN_HD_FORMAT_Input_error_Please_try_once_more_ref, x=40, y=152, w=240, h=72, index=55, font=idCHARA1W, fontcolor=CL_Black, lines=4	; EN "Please try once more, refer your owners manual or ask your dealer/service center."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; SELECT_FILE_A_Z -- TtlScreenR2
; -----------------------------------------------------------------------------
	TtlScreenR2	SELECT_FILE_A_Z, x=0, y=0, w=320, h=240, window=HdaeUiVar_SELECT_FILE_A_Z_window, icon=idICON_None, title=""
	ui_sub
		IvExitScreen	SELECT_FILE_A_Z_Exit_SELECT_DIR, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_SELECT_DIR
		IvPageControl	SELECT_FILE_A_Z_Page_FILE_LOAD_A_Z, x=0, y=32, w=32, h=32, page=1, window=HDAE5000_OBJ_FILE_LOAD_A_Z
		IvPageControl	SELECT_FILE_A_Z_Page_HD_FILE_LOAD_P2, x=0, y=64, w=32, h=32, page=2, window=HDAE5000_OBJ_HD_FILE_LOAD_P2
		IvMainEditSw	SELECT_FILE_A_Z_IvMainEditSw, x=0, y=96, w=32, h=32, func=NAKA_MAINFUNC_FileLoadSwCatch
		AcWindowPage1	SELECT_FILE_A_Z_AcWindowPage1, x=245, y=6, w=71, h=18, border=BD_3D_UP1, page=HdaeUiVar_SELECT_FILE_A_Z_AcWindowPage1_page
	ui_endsub

; -----------------------------------------------------------------------------
; FILE_LOAD_A_Z -- Window
; opened by: SELECT_FILE_A_Z_Page_FILE_LOAD_A_Z.window
; -----------------------------------------------------------------------------
	Window	FILE_LOAD_A_Z, x=0, y=0, w=320, h=240, color=CL_Transparent, border=BD_None, parent=HdaeUiVar_FILE_LOAD_A_Z_parent, child=HdaeUiVar_FILE_LOAD_A_Z_child
	ui_sub
		AcIndexEditSw	FILE_LOAD_A_Z_AcIndexEditSw, x=44, y=220, w=32, h=18, index=2, editsw=ES_Bottom2, style=SS_Left
		AcIndexWideES	FILE_LOAD_A_Z_AcIndexWideES, x=84, y=220, w=112, h=18, index=0xffff
		SelectList	FILE_LOAD_A_Z_SelectList, x=44, y=52, w=192, h=164, color=CL_DarkGray, index=0xffff, str_adr=HdaeUiVar_FILE_LOAD_A_Z_SelectList_str_adr, row=16, sel_num=HdaeUiVar_FILE_LOAD_A_Z_SelectList_sel_num, en_paradraw=HdaeUiVar_FILE_LOAD_A_Z_SelectList_en_paradraw
		AcIndexEditSw	FILE_LOAD_A_Z_AcIndexEditSw_2, x=204, y=220, w=32, h=18, index=1, editsw=ES_Bottom6, style=SS_Right
		Icon	FILE_LOAD_A_Z_Icon, x=42, y=0, w=28, h=28
		Label	FILE_LOAD_A_Z_FILE_SELECT_A_Z, x=70, y=7, w=169, h=19, font=idCHARA5, fontcolor=CL_White, str="FILE SELECT A-Z"
		AcIndexEditSw	FILE_LOAD_A_Z_AcIndexEditSw_3, x=265, y=36, w=47, h=26, border=BD_3D_UP1, index=3, editsw=ES_Right1, style=SS_OK
		EditSw	FILE_LOAD_A_Z_80, x=310, y=77, w=10, h=19, index=6, str="~80"
		Line	FILE_LOAD_A_Z_Line, x=313, y=40, w=1, h=40, color=CL_EditSw
		SelectList	FILE_LOAD_A_Z_SelectList_2, x=44, y=30, w=192, h=18, color=CL_DarkGray, index=100, str_adr=HdaeUiVar_FILE_LOAD_A_Z_SelectList_2_str_adr, row=1, sel_num=HdaeUiVar_FILE_LOAD_A_Z_SelectList_2_sel_num, en_paradraw=HdaeUiVar_FILE_LOAD_A_Z_SelectList_2_en_paradraw
		ui_sub
			TextBox	FILE_LOAD_A_Z_SelectList_2_Evergreens_slow_12, x=78, y=32, w=160, h=16, color=CL_DarkGray, border=BD_None, font=idCHARA4, fontcolor=CL_Red, alignment=AL_LeftJustify, lines=1, text="Evergreens slow / 12"
			ui_sub
				TextBox	FILE_LOAD_A_Z_SelectList_2_Evergreens_slow_12_LOC, x=44, y=32, w=84, h=16, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1, text="LOC.:"
			ui_endsub
		ui_endsub
		Viewable	FILE_LOAD_A_Z_Viewable, x=60, y=84, w=200, h=48, flag=VF_Const
		TextBox	FILE_LOAD_A_Z_TextBox, x=236, y=100, w=84, h=116, color=CL_DarkGray, border=BD_3D_UP1, font=idCHARA1, alignment=AL_LeftJustify, lines=3, text=""
		ui_sub
			TextBox	FILE_LOAD_A_Z_TextBox_RHYTHM_CUSTOM, x=236, y=174, w=84, h=18, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_White, lines=1, text="RHYTHM CUSTOM"
			TextBox	FILE_LOAD_A_Z_TextBox_USER_MIDI, x=236, y=186, w=84, h=18, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_White, lines=1, text="USER MIDI"
			TextBox	FILE_LOAD_A_Z_TextBox_TECH_LYRICS, x=236, y=198, w=84, h=18, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_LightGreen, lines=1, text="TECH LYRICS"
			TextBox	FILE_LOAD_A_Z_TextBox_MSP, x=236, y=162, w=84, h=18, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_White, lines=1, text="MSP"
			TextBox	FILE_LOAD_A_Z_TextBox_SOUND_MEMORY, x=236, y=150, w=84, h=18, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_White, lines=1, text="SOUND MEMORY"
			ui_sub
				TextBox	FILE_LOAD_A_Z_TextBox_SOUND_MEMORY_COMPOSER, x=236, y=138, w=84, h=18, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_White, lines=1, text="COMPOSER"
			ui_endsub
			TextBox	FILE_LOAD_A_Z_TextBox_SEQUENCER, x=236, y=126, w=84, h=18, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_White, lines=1, text="SEQUENCER"
			TextBox	FILE_LOAD_A_Z_TextBox_PANEL_MEMORY, x=236, y=114, w=84, h=18, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_White, lines=1, text="PANEL MEMORY"
			TextBox	FILE_LOAD_A_Z_TextBox_CURRENT_PANEL, x=236, y=102, w=84, h=18, color=CL_Transparent, border=BD_None, font=idCHARA4, fontcolor=CL_White, lines=1, text="CURRENT PANEL"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; Tech_lyrics -- TtlScreenR2 "TECH LYRIC"
; opened by: HDDMENU_Go_Tech_lyrics.screen, LoadLyricFD_Exit_Tech_lyrics.screen,
;            HDAE5000_FileLoadSwCatch_Join, HDAE5000_LBNLoadSwCatch, HDAE5000_Lbn_TypeDigit,
;            HDAE5000_FlsLoadScreen_Join3, HDAE5000_FlsLoadScreen_Join5, HDAE5000_FDFileSelectProc
; -----------------------------------------------------------------------------
	TtlScreenR2	Tech_lyrics, x=0, y=0, w=320, h=240, window=HdaeUiVar_Tech_lyrics_window, icon=idICON_i160, title="TECH LYRIC"
	ui_sub
		IvExitScreen	Tech_lyrics_Exit_HDDMENU, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_HDDMENU
		TextBox	Tech_lyrics_TextBox, x=20, y=33, w=280, h=24, color=CL_DarkGray, border=BD_3D_UP1, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1, text=""
		ui_sub
			PsParaBox	SongTitle, x=21, y=34, w=278, h=22, font=idCHARA1P
		ui_endsub
		TextBox	Tech_lyrics_TextBox_2, x=20, y=56, w=280, h=18, color=CL_DarkGray, border=BD_3D_UP1, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1, text=""
		ui_sub
			PsParaBox	Conductor, x=21, y=57, w=278, h=15
		ui_endsub
		PsParaBox	bottom01, x=0, y=224, w=40, h=16
		PsParaBox	bottom02, x=40, y=224, w=40, h=16
		PsParaBox	bottom03, x=80, y=224, w=40, h=16
		PsParaBox	bottom04, x=120, y=224, w=40, h=16
		PsParaBox	bottom05, x=160, y=224, w=40, h=16
		PsParaBox	bottom06, x=200, y=224, w=40, h=16
		PsParaBox	bottom07, x=240, y=224, w=40, h=16
		PsParaBox	bottom08, x=280, y=224, w=40, h=16
		TextBox	Tech_lyrics_TextBox_3, x=0, y=209, w=320, h=16, color=CL_DarkGray, border=BD_3D_UP1, font=idCHARA1, alignment=AL_LeftJustify, lines=1, text=""
		ui_sub
			ui_ram_object	ChordinLyric, PsParaBox
			ui_ram_object	TempoinLyric, PsParaBox
			ui_ram_object	MeasureinLyric, PsParaBox
			ui_ram_object	TimeSigInLyric, PsParaBox
		ui_endsub
		LyricBox	Tech_lyrics_LyricBox, x=19, y=75, w=284, h=132, flag=VF_Const, color=CL_White, border=BD_Shadow2, index=0xffff, pEnable=HdaeUiVar_Tech_lyrics_LyricBox_pEnable, font=idCHARA1W, fontcolor=CL_Blue, reversecolor=CL_LightGreen, infofont=idCHARA4, infocolor=CL_Red
	ui_endsub

; -----------------------------------------------------------------------------
; LoadLyricFD -- TtlScreenR3 "Load Lyric From FD"
; opened by: HDAE5000_LyricBoxProc_OnLoad
; -----------------------------------------------------------------------------
	TtlScreenR3	LoadLyricFD, x=0, y=0, w=320, h=240, flag=VF_Fixed|VF_Const, color=CL_Black, border=BD_None, exit=TITLE_PS, window=HdaeUiVar_LoadLyricFD_window, icon=idICON_i37, title="Load Lyric From FD"
	ui_sub
		IvExitScreen	LoadLyricFD_Exit_Tech_lyrics, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_Tech_lyrics
		Label	LoadLyricFD_Info, x=12, y=225, w=28, h=11, font=idCHARA4, fontcolor=CL_Black, str="Info"
		Label	LoadLyricFD_New, x=54, y=225, w=22, h=11, font=idCHARA4, fontcolor=CL_Black, str="New"
		Label	LoadLyricFD_Load, x=241, y=225, w=28, h=11, font=idCHARA4, fontcolor=CL_Black, str="Load"
		Label	LoadLyricFD_Save, x=279, y=225, w=28, h=11, font=idCHARA4, fontcolor=CL_Red, str="Save"
		FDFileSelect	LoadLyricFD_FDFileSelect, x=0, y=0, w=32, h=32, flag=VF_Const|VF_InvisibleBox, dial=0, sel_num=HdaeUiVar_LoadLyricFD_FDFileSelect_sel_num, sel_pos=HdaeUiVar_LoadLyricFD_FDFileSelect_sel_pos
	ui_endsub

; -----------------------------------------------------------------------------
; FD_PLEASE -- TtlScreenR2
; -----------------------------------------------------------------------------
	TtlScreenR2	FD_PLEASE, x=0, y=0, w=320, h=240, window=HdaeUiVar_FD_PLEASE_window, icon=idICON_None, title=""
	ui_sub
		TextBox	FD_PLEASE_Please_wait, x=60, y=84, w=200, h=48, color=CL_Orange, border=BD_3D_UP2, font=idCHARA2, lines=1, text=""
		ui_sub
			AcLanguageText1	FD_PLEASE_Please_wait_Text, x=72, y=98, w=170, h=24, index=49, font=idCHARA1, fontcolor=CL_Black, lines=1	; EN "Please wait ..."
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; LyrSettings -- TtlScreenR2 "Lyric Settings"
; opened by: SETUP_TOOLS_P1_LYRIC_SETTINGS.screen
; -----------------------------------------------------------------------------
	TtlScreenR2	LyrSettings, x=0, y=0, w=320, h=240, window=HdaeUiVar_LyrSettings_window, icon=idICON_i58, title="Lyric Settings"
	ui_sub
		IvExitScreen	LyrSettings_Exit_SETUPS_TOOLS, x=0, y=0, w=32, h=32, screen=HDAE5000_OBJ_SETUPS_TOOLS
		AcRamEditBox	LyrSettings_Jump_after_Load, x=8, y=72, w=156, h=26, index=0, align=AL_RightJustify, length=4, editsw=ES_Left2, dial=1, selected=HdaeUiVar_LyrSettings_Jump_after_Load_selected, func=NAKA_APFUNC_LyricJumpEditCheck, data=HdaeUiVar_LyrSettings_Jump_after_Load_data, caption=""
		ui_sub
			AcLanguageText1	LyrSettings_Jump_after_Load_Text, x=8, y=72, w=135, h=32, index=64, font=idCHARA1, fontcolor=CL_White, alignment=AL_LeftJustify, lines=1	; EN "Jump after Load"
		ui_endsub
	ui_endsub

; -----------------------------------------------------------------------------
; WriteIn -- Window
; -----------------------------------------------------------------------------
	Window	WriteIn, x=16, y=112, w=292, h=112, border=BD_3D_UP2, parent=HdaeUiVar_WriteIn_parent, child=HdaeUiVar_WriteIn_child
	ui_tree_end

; =============================================================================
; HDAE5000_UiObject_PtrTable: object table 0x7F, registered by HDAE5000_Handler_Registration
; (class id NAKA_CLASS_Viewable, RootFn_ViewableProc, entry count HDAE5000_UI_OBJECT_COUNT
; = 786): one pointer per object in tree order -- its HdaeUi_ record, or the RAM
; address of its HdaeUiRam_ record -- then NULL.
; =============================================================================
HDAE5000_UiObject_PtrTable:
	ui_object_table

; =============================================================================
; HDAE5000_UiObjectName_PtrTable: object table 0x37F (NAKA_CLASS_ResName,
; RootFn_ResNameProc): the name of every object, same order, then one more slot
; (pairing with the NULL above) that points at the pool's first, empty, string.
; =============================================================================
HDAE5000_UiObjectName_PtrTable:
	ui_name_table
	.long	HdaeUiName__TableEnd

; =============================================================================
; HDAE5000_UiObjectName_Pool: the names, highest object first (the order the toolchain
; emitted them).  ui_name writes the object's own symbol as its name; ui_noname an empty
; string (the 608 objects the firmware left unnamed).
; =============================================================================
HDAE5000_UiObjectName_Pool:
	ui_noname	_TableEnd
	ui_name	WriteIn
	ui_noname	LyrSettings_Jump_after_Load_Text
	ui_noname	LyrSettings_Jump_after_Load
	ui_noname	LyrSettings_Exit_SETUPS_TOOLS
	ui_name	LyrSettings
	ui_noname	FD_PLEASE_Please_wait_Text
	ui_noname	FD_PLEASE_Please_wait
	ui_name	FD_PLEASE
	ui_noname	LoadLyricFD_FDFileSelect
	ui_noname	LoadLyricFD_Save
	ui_noname	LoadLyricFD_Load
	ui_noname	LoadLyricFD_New
	ui_noname	LoadLyricFD_Info
	ui_noname	LoadLyricFD_Exit_Tech_lyrics
	ui_name	LoadLyricFD
	ui_noname	Tech_lyrics_LyricBox
	ui_name	TimeSigInLyric
	ui_name	MeasureinLyric
	ui_name	TempoinLyric
	ui_name	ChordinLyric
	ui_noname	Tech_lyrics_TextBox_3
	ui_name	bottom08
	ui_name	bottom07
	ui_name	bottom06
	ui_name	bottom05
	ui_name	bottom04
	ui_name	bottom03
	ui_name	bottom02
	ui_name	bottom01
	ui_name	Conductor
	ui_noname	Tech_lyrics_TextBox_2
	ui_name	SongTitle
	ui_noname	Tech_lyrics_TextBox
	ui_noname	Tech_lyrics_Exit_HDDMENU
	ui_name	Tech_lyrics
	ui_noname	FILE_LOAD_A_Z_TextBox_CURRENT_PANEL
	ui_noname	FILE_LOAD_A_Z_TextBox_PANEL_MEMORY
	ui_noname	FILE_LOAD_A_Z_TextBox_SEQUENCER
	ui_noname	FILE_LOAD_A_Z_TextBox_SOUND_MEMORY_COMPOSER
	ui_noname	FILE_LOAD_A_Z_TextBox_SOUND_MEMORY
	ui_noname	FILE_LOAD_A_Z_TextBox_MSP
	ui_noname	FILE_LOAD_A_Z_TextBox_TECH_LYRICS
	ui_noname	FILE_LOAD_A_Z_TextBox_USER_MIDI
	ui_noname	FILE_LOAD_A_Z_TextBox_RHYTHM_CUSTOM
	ui_noname	FILE_LOAD_A_Z_TextBox
	ui_noname	FILE_LOAD_A_Z_Viewable
	ui_noname	FILE_LOAD_A_Z_SelectList_2_Evergreens_slow_12_LOC
	ui_noname	FILE_LOAD_A_Z_SelectList_2_Evergreens_slow_12
	ui_noname	FILE_LOAD_A_Z_SelectList_2
	ui_noname	FILE_LOAD_A_Z_Line
	ui_noname	FILE_LOAD_A_Z_80
	ui_noname	FILE_LOAD_A_Z_AcIndexEditSw_3
	ui_noname	FILE_LOAD_A_Z_FILE_SELECT_A_Z
	ui_noname	FILE_LOAD_A_Z_Icon
	ui_noname	FILE_LOAD_A_Z_AcIndexEditSw_2
	ui_noname	FILE_LOAD_A_Z_SelectList
	ui_noname	FILE_LOAD_A_Z_AcIndexWideES
	ui_noname	FILE_LOAD_A_Z_AcIndexEditSw
	ui_name	FILE_LOAD_A_Z
	ui_noname	SELECT_FILE_A_Z_AcWindowPage1
	ui_noname	SELECT_FILE_A_Z_IvMainEditSw
	ui_noname	SELECT_FILE_A_Z_Page_HD_FILE_LOAD_P2
	ui_noname	SELECT_FILE_A_Z_Page_FILE_LOAD_A_Z
	ui_noname	SELECT_FILE_A_Z_Exit_SELECT_DIR
	ui_name	SELECT_FILE_A_Z
	ui_noname	AGAIN_HD_FORMAT_Input_error_Please_try_once_more_ref
	ui_noname	AGAIN_HD_FORMAT_Input_error_The_key_code_input_was_w
	ui_noname	AGAIN_HD_FORMAT_Input_error_Text
	ui_noname	AGAIN_HD_FORMAT_Input_error
	ui_name	AGAIN_HD_FORMAT_CATCH
	ui_noname	AGAIN_HD_FORMAT_Exit_ATTEN_HD_FORMAT
	ui_name	AGAIN_HD_FORMAT
	ui_noname	ERR_Please_try_once_more_ref
	ui_noname	ERR_HD_FORMAT_The_automatic_HD_format__FORMAT_ERROR
	ui_noname	ERR_HD_FORMAT_The_automatic_HD_format__Text
	ui_noname	ERR_HD_FORMAT_The_automatic_HD_format_
	ui_name	ERR_HD_FORMAT_CATCH
	ui_noname	ERR_HD_FORMAT_Exit_ATTEN_HD_FORMAT
	ui_name	ERR_HD_FORMAT
	ui_noname	HD_PLEASE_Please_wait_Text
	ui_noname	HD_PLEASE_Please_wait
	ui_name	HD_PLEASE
	ui_noname	FILE_OUT_RANGE_The_file_number_is_out_o
	ui_noname	FILE_OUT_RANGE_ATTENTION_Text
	ui_noname	FILE_OUT_RANGE_ATTENTION
	ui_name	FILE_OUT_RANGE_CATCH
	ui_name	FILE_OUT_RANGE
	ui_noname	DIR_OUT_RANGE_ATTENTION
	ui_noname	DIR_OUT_RANGE_The_DIR_number_is_out_of_Text
	ui_noname	DIR_OUT_RANGE_The_DIR_number_is_out_of
	ui_name	DIR_OUT_RANGE_CATCH
	ui_name	DIR_OUT_RANGE
	ui_noname	ATTEN_You_cannot_copy_files_so
	ui_noname	ATTEN_CP_UNNAMED_Please_use_a_named_direc_ATTENTION
	ui_noname	ATTEN_CP_UNNAMED_Please_use_a_named_direc_Text
	ui_noname	ATTEN_CP_UNNAMED_Please_use_a_named_direc
	ui_name	ATTEN_CP_UNNAMED_CATCH
	ui_noname	ATTEN_CP_UNNAMED_Exit_CP_FD_DIRSEL
	ui_name	ATTEN_CP_UNNAMED
	ui_noname	ATTEN_FULL_DIR_ATTENTION_Reduce_the_number_of_sel
	ui_noname	ATTEN_FULL_DIR_ATTENTION_The_number_or_marked_son
	ui_noname	ATTEN_FULL_DIR_ATTENTION_Text
	ui_noname	ATTEN_FULL_DIR_ATTENTION
	ui_name	ATTEN_FULL_DIR_CATCH
	ui_noname	ATTEN_FULL_DIR_Exit_CP_FD_DIRSEL
	ui_name	ATTEN_FULL_DIR
	ui_noname	ERR_NO_HK_DATA_ATTENTION_The_data_on_the_disk_you
	ui_noname	ERR_NO_HK_DATA_ATTENTION_Text
	ui_noname	ERR_NO_HK_DATA_ATTENTION
	ui_name	ERR_NO_HK_DATA_CATCH
	ui_noname	ERR_NO_HK_DATA_Exit_CP_FD
	ui_name	ERR_NO_HK_DATA
	ui_noname	ERR_LOAD_Please_make_a_safety_bac
	ui_noname	ERR_LOAD_ATTENTION_Text
	ui_noname	ERR_LOAD_ATTENTION
	ui_name	ERR_LOAD_CATCH
	ui_name	ERR_LOAD_EXIT
	ui_name	ERR_LOAD
	ui_noname	ERR_SAVE_ATTENTION
	ui_noname	ERR_SAVE_Please_make_a_safety_bac_Text
	ui_noname	ERR_SAVE_Please_make_a_safety_bac
	ui_name	ERR_SAVE_CATCH
	ui_name	ERR_SAVE_EXIT
	ui_name	ERR_SAVE
	ui_noname	WAIT_TR0_RECOVER_Please_wait
	ui_noname	WAIT_TR0_RECOVER_Track_O_will_be_recovere
	ui_name	WAIT_TR0_RECOVER
	ui_noname	ABOUT_HELP_Text
	ui_noname	ABOUT_HELP_Exit_SETUPS_TOOLS
	ui_noname	ABOUT_HELP_TextBox_3_Special_thanks_to
	ui_noname	ABOUT_HELP_TextBox_3_Mr_T_Hamaguchi_and_Mr_M_
	ui_noname	ABOUT_HELP_TextBox_3
	ui_noname	ABOUT_HELP_All_rigths_reserved_by_t_Text
	ui_noname	ABOUT_HELP_All_rigths_reserved_by_t
	ui_noname	ABOUT_HELP_TextBox_2_Conception_marketing_sal
	ui_noname	ABOUT_HELP_TextBox_2_email_keysoftservice_blu
	ui_noname	ABOUT_HELP_TextBox_2_Fax_41_41_922_03_15
	ui_noname	ABOUT_HELP_TextBox_2_KEY_SOFT_SERVICE_CH_Sche
	ui_noname	ABOUT_HELP_TextBox_2
	ui_noname	ABOUT_HELP_TextBox_Hardware_and_software_de
	ui_noname	ABOUT_HELP_TextBox_Pointstyle_CH_Buttisholz
	ui_noname	ABOUT_HELP_TextBox_Technosoft_CH_Samstagern
	ui_noname	ABOUT_HELP_TextBox_Label
	ui_noname	ABOUT_HELP_TextBox
	ui_noname	ABOUT_HELP_VwUserBitmap
	ui_name	ABOUT_HELP
	ui_noname	ATTEN_CPFD_MARK_ATTENTION_There_are_no_files_marke
	ui_noname	ATTEN_CPFD_MARK_ATTENTION_Text
	ui_noname	ATTEN_CPFD_MARK_ATTENTION
	ui_noname	ATTEN_CPFD_MARK_CANCEL_Text
	ui_noname	ATTEN_CPFD_MARK_CANCEL
	ui_noname	ATTEN_CPFD_MARK_IvCatchEvent
	ui_name	ATTEN_CPFD_MARK
	ui_noname	ERR_HD_FSB_Please_call_your_dealer__Hard_disk_FSB_read_error
	ui_noname	ERR_HD_FSB_Please_call_your_dealer__SYSTEM_ERROR
	ui_noname	ERR_HD_FSB_Please_call_your_dealer__Text
	ui_noname	ERR_HD_FSB_Please_call_your_dealer_
	ui_name	ERR_HD_FSB
	ui_noname	ERR_HD_FAT_SYSTEM_ERROR_Hard_disk_FAT_read_error
	ui_noname	ERR_HD_FAT_SYSTEM_ERROR_Please_call_your_dealer_
	ui_noname	ERR_HD_FAT_SYSTEM_ERROR_Text
	ui_noname	ERR_HD_FAT_SYSTEM_ERROR
	ui_name	ERR_HD_FAT
	ui_noname	ERR_HD_TRACK_0_Please_call_your_dealer_
	ui_noname	ERR_HD_TRACK_0_SYSTEM_ERROR
	ui_noname	ERR_HD_TRACK_0_Hard_disk_track_0_error_Text
	ui_noname	ERR_HD_TRACK_0_Hard_disk_track_0_error
	ui_name	ERR_HD_TRACK_0
	ui_noname	ERR_HD_ID_READ_Please_call_your_dealer_
	ui_noname	ERR_HD_ID_READ_SYSTEM_ERROR
	ui_noname	ERR_HD_ID_READ_Hard_disk_ID_read_error_Text
	ui_noname	ERR_HD_ID_READ_Hard_disk_ID_read_error
	ui_name	ERR_HD_ID_READ
	ui_noname	ERR_HD_READ_Please_call_your_dealer_
	ui_noname	ERR_HD_READ_SYSTEM_ERROR
	ui_noname	ERR_HD_READ_Hard_disk_read_error_Text
	ui_noname	ERR_HD_READ_Hard_disk_read_error
	ui_name	ERR_HD_READ
	ui_noname	ERR_HD_RESET_Please_call_your_dealer_
	ui_noname	ERR_HD_RESET_SYSTEM_ERROR
	ui_noname	ERR_HD_RESET_Hard_disk_reset_error
	ui_noname	ERR_HD_RESET_TextBox
	ui_name	ERR_HD_RESET
	ui_noname	ERR_HD_SRAM_Please_call_your_dealer_
	ui_noname	ERR_HD_SRAM_SYSTEM_ERROR
	ui_noname	ERR_HD_SRAM_Hard_disk_SRAM_error
	ui_noname	ERR_HD_SRAM_TextBox
	ui_name	ERR_HD_SRAM
	ui_noname	ERR_HD_NOT_FMT_Please_call_your_dealer_
	ui_noname	ERR_HD_NOT_FMT_SYSTEM_ERROR
	ui_noname	ERR_HD_NOT_FMT_The_hard_disk_is_not_for_Text
	ui_noname	ERR_HD_NOT_FMT_The_hard_disk_is_not_for
	ui_name	ERR_HD_NOT_FMT
	ui_noname	ATTEN_CPHD_WR_CANCEL
	ui_noname	ATTEN_CPHD_WR_ATTENTION
	ui_noname	ATTEN_Please_set_the_write_pro
	ui_noname	ATTEN_CPHD_WR_The_hard_disk_is_write_p_Text
	ui_noname	ATTEN_CPHD_WR_The_hard_disk_is_write_p
	ui_noname	ATTEN_CPHD_WR_VwWideESBox
	ui_noname	ATTEN_CPHD_WR_IvCatchEvent
	ui_name	ATTEN_CPHD_WR
	ui_noname	HDD_FLS_NAMING2_AcFuncEditSw_2_LST
	ui_noname	HDD_FLS_NAMING2_AcFuncEditSw_2
	ui_noname	HDD_FLS_NAMING2_AcFuncEditSw
	ui_noname	HDD_FLS_NAMING2_Exit_FLS_EDIT
	ui_noname	HDD_FLS_NAMING2_IvNaming
	ui_name	HDD_FLS_NAMING2
	ui_noname	ATTEN_OVER_FILE_ACHTUNG_Sie_berschreiben_einen_b
	ui_noname	ATTEN_OVER_FILE_ACHTUNG
	ui_noname	ATTEN_OVER_FILE_NEIN
	ui_noname	ATTEN_OVER_FILE_JA
	ui_noname	ATTEN_OVER_FILE_IvCatchEvent
	ui_name	ATTEN_OVER_FILE
	ui_noname	ATTEN_DEL_FLS1_NO_Text
	ui_noname	ATTEN_DEL_FLS1_NO
	ui_noname	ATTEN_DEL_FLS1_YES_2_YES
	ui_noname	ATTEN_DEL_FLS1_YES_2
	ui_noname	ATTEN_DEL_FLS1_YES_Text
	ui_noname	ATTEN_DEL_FLS1_YES
	ui_noname	ATTEN_DEL_FLS1_ATTENTION_The_FLS_entry_remains_fr
	ui_noname	ATTEN_DEL_FLS1_ATTENTION_You_are_going_to_delete_
	ui_noname	ATTEN_DEL_FLS1_ATTENTION_Press_YES_for_confirmati
	ui_noname	ATTEN_DEL_FLS1_ATTENTION
	ui_noname	ATTEN_DEL_FLS1_IvCatchEvent
	ui_name	ATTEN_DEL_FLS1
	ui_noname	DBG_MEMO_SCREEN_DbMemo
	ui_noname	DBG_MEMO_SCREEN_Exit_HDDMENU
	ui_name	DBG_MEMO_SCREEN
	ui_noname	HD_INFO_LIST_Line
	ui_name	HD_INFO_LIST
	ui_noname	SETUP_HDINFO_HD_INFO
	ui_noname	SETUP_HDINFO_Exit_SETUPS_TOOLS
	ui_name	SETUP_HDINFO
	ui_noname	WAIT_HD_FORMAT_Please_wait
	ui_noname	WAIT_HD_FORMAT_We_recommend_to_turn_ON_
	ui_noname	WAIT_HD_FORMAT_The_hard_disk_will_now_b
	ui_name	WAIT_HD_FORMAT
	ui_name	HD_FORMAT_CATCH
	ui_noname	ATTEN_HD_FORMAT_CANCEL
	ui_noname	ATTEN_HD_FORMAT_VwUserBitmap
	ui_noname	ATTEN_HD_FORMAT_HD_FORMAT_will_erase_all_ATTENTION
	ui_noname	ATTEN_Therefore_you_need_a_6_d
	ui_noname	ATTEN_After_your_code_input_al
	ui_noname	ATTEN_HD_FORMAT_HD_FORMAT_will_erase_all_Text
	ui_noname	ATTEN_HD_FORMAT_HD_FORMAT_will_erase_all
	ui_name	ATTEN_HD_FORMAT
	ui_noname	WAIT_DEL_FILE_Please_wait
	ui_noname	WAIT_DEL_FILE_Delete_file_from_hard_di
	ui_name	WAIT_DEL_FILE
	ui_noname	ATTEN_DEL_FLS2_ATTENTION_All_following_entries_wi
	ui_noname	ATTEN_DEL_FLS2_ATTENTION_You_are_going_to_delete_
	ui_noname	ATTEN_DEL_FLS2_ATTENTION_Press_YES_for_confirmati
	ui_noname	ATTEN_DEL_FLS2_ATTENTION
	ui_noname	ATTEN_DEL_FLS2_NO_Text
	ui_noname	ATTEN_DEL_FLS2_NO
	ui_noname	ATTEN_DEL_FLS2_YES_Text
	ui_noname	ATTEN_DEL_FLS2_YES
	ui_noname	ATTEN_DEL_FLS2_IvCatchEvent
	ui_name	ATTEN_DEL_FLS2
	ui_noname	ATTEN_OVER_FLS_ATTENTION_You_are_going_to_overwri
	ui_noname	ATTEN_OVER_FLS_ATTENTION_Press_YES_for_confirmati
	ui_noname	ATTEN_OVER_FLS_ATTENTION
	ui_noname	ATTEN_OVER_FLS_NO_Text
	ui_noname	ATTEN_OVER_FLS_NO
	ui_noname	ATTEN_OVER_FLS_YES_Text
	ui_noname	ATTEN_OVER_FLS_YES
	ui_noname	ATTEN_OVER_FLS_IvCatchEvent
	ui_name	ATTEN_OVER_FLS
	ui_noname	ATTEN_DEL_FILE_NO
	ui_noname	ATTEN_DEL_FILE_YES
	ui_noname	ATTEN_DEL_FILE_ATTENTION_Would_you_really_delete_
	ui_noname	ATTEN_DEL_FILE_ATTENTION_Press_YES_for_confirmati
	ui_noname	ATTEN_DEL_FILE_ATTENTION
	ui_noname	ATTEN_DEL_FILE_VwWideESBox_2
	ui_noname	ATTEN_DEL_FILE_IvCatchEvent
	ui_noname	ATTEN_DEL_FILE_VwWideESBox
	ui_name	ATTEN_DEL_FILE
	ui_noname	WAIT_DEL_DIR_PLEASE_WAIT
	ui_noname	WAIT_DEL_DIR_DELETE_DIRECTORY_FROM_HA
	ui_name	WAIT_DEL_DIR
	ui_noname	ATTEN_DEL_DIR_ATTENTION_Would_you_really_delete_
	ui_noname	ATTEN_DEL_DIR_ATTENTION_Press_YES_for_confirmati
	ui_noname	ATTEN_DEL_DIR_ATTENTION
	ui_noname	ATTEN_DEL_DIR_IvCatchEvent
	ui_noname	ATTEN_DEL_DIR_NO_Text
	ui_noname	ATTEN_DEL_DIR_NO
	ui_noname	ATTEN_DEL_DIR_YES_Text
	ui_noname	ATTEN_DEL_DIR_YES
	ui_name	ATTEN_DEL_DIR
	ui_name	IV_HDDMENU
	ui_name	HD_MENU_BMP
	ui_name	HDD_ICON_DISPLAY
	ui_noname	FILE_DEL_SCREEN_Line_5
	ui_noname	FILE_DEL_SCREEN_Line_4
	ui_name	DEL_EDIT_TLX
	ui_noname	FILE_DEL_SCREEN_LYRIC
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_12
	ui_noname	FILE_DEL_SCREEN_AcRamEditBox
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_11_ALL_OFF
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_11
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_10_ALL_DEL
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_10
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_9_DEL
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_9
	ui_noname	FILE_DEL_SCREEN_IvCatchEvent
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_8
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_7
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_6
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_5
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_4
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_3
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw_2
	ui_noname	FILE_DEL_SCREEN_AcIndexEditSw
	ui_name	DEL_EDIT_MD
	ui_name	DEL_EDIT_RCM
	ui_name	DEL_EDIT_MSP
	ui_name	DEL_EDIT_TM
	ui_name	DEL_EDIT_CMP
	ui_name	DEL_EDIT_SQT
	ui_name	DEL_EDIT_PMT
	ui_name	DEL_EDIT_LSW
	ui_noname	FILE_DEL_SCREEN_Line_3
	ui_noname	FILE_DEL_SCREEN_Line_2
	ui_noname	FILE_DEL_SCREEN_Line
	ui_noname	FILE_DEL_SCREEN_MIDI
	ui_noname	FILE_DEL_SCREEN_CUSTOM
	ui_noname	FILE_DEL_SCREEN_MSP
	ui_noname	FILE_DEL_SCREEN_SOUND
	ui_noname	FILE_DEL_SCREEN_COMP
	ui_noname	FILE_DEL_SCREEN_SEQ
	ui_noname	FILE_DEL_SCREEN_P_MEM
	ui_noname	FILE_DEL_SCREEN_PNL
	ui_noname	FILE_DEL_SCREEN_Exit_SELECT_FILE
	ui_name	FILE_DEL_SCREEN
	ui_name	HddNamingLabel
	ui_noname	HddNamingWindow_AcIndexEditSw_9
	ui_noname	HddNamingWindow_AcIndexEditSw_8
	ui_noname	HddNamingWindow_AcIndexEditSw_7
	ui_name	HddNamingSymbol
	ui_name	HddNamingabc
	ui_name	HddNamingABC
	ui_name	HddNamingCursorBox
	ui_noname	HddNamingWindow_POSITION
	ui_noname	HddNamingWindow_AcIndexEditSw_6
	ui_noname	HddNamingWindow_AcIndexEditSw_5
	ui_noname	HddNamingWindow_AcIndexEditSw_4_8d_8b
	ui_noname	HddNamingWindow_AcIndexEditSw_4
	ui_noname	HddNamingWindow_AcIndexEditSw_3_CLR
	ui_noname	HddNamingWindow_AcIndexEditSw_3
	ui_noname	HddNamingWindow_AcIndexEditSw_2_INS
	ui_noname	HddNamingWindow_AcIndexEditSw_2
	ui_noname	HddNamingWindow_AcIndexEditSw_DEL
	ui_noname	HddNamingWindow_AcIndexEditSw
	ui_name	HddNamingWindow
	ui_noname	SAVE_OPT_SCREEN_Line_5
	ui_noname	SAVE_OPT_SCREEN_LYRIC
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_13
	ui_name	RAM_EDIT_TLX
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_12_BACKUP
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_12
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_11_ALL_OFF
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_11
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_10_PERFORM
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_10
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_9_SAVE
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_9
	ui_noname	SAVE_OPT_SCREEN_IvCatchEvent
	ui_noname	SAVE_OPT_SCREEN_Line_4
	ui_noname	SAVE_OPT_SCREEN_Line_3
	ui_noname	SAVE_OPT_SCREEN_Line_2
	ui_noname	SAVE_OPT_SCREEN_Line
	ui_name	RAM_EDIT_MD
	ui_name	RAM_EDIT_RCM
	ui_name	RAM_EDIT_MSP
	ui_name	RAM_EDIT_TM
	ui_name	RAM_EDIT_SQT
	ui_name	RAM_EDIT_PMT
	ui_name	RAM_EDIT_LSW
	ui_noname	SAVE_OPT_SCREEN_AcRamEditBox
	ui_name	RAM_EDIT_CMP
	ui_noname	SAVE_OPT_SCREEN_MIDI
	ui_noname	SAVE_OPT_SCREEN_CUSTOM
	ui_noname	SAVE_OPT_SCREEN_MSP
	ui_noname	SAVE_OPT_SCREEN_SOUND
	ui_noname	SAVE_OPT_SCREEN_COMP
	ui_noname	SAVE_OPT_SCREEN_SEQ
	ui_noname	SAVE_OPT_SCREEN_P_MEM
	ui_noname	SAVE_OPT_SCREEN_PNL
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_8
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_7
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_6
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_5
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_4
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_3
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw_2
	ui_noname	SAVE_OPT_SCREEN_AcIndexEditSw
	ui_noname	SAVE_OPT_SCREEN_Exit_HDD_FILE_NAMING
	ui_name	SAVE_OPT_SCREEN
	ui_noname	Root_AcNamingWindow
	ui_noname	CP_FD_DIR_NAMING_LST
	ui_noname	CP_FD_DIR_NAMING_AcFuncEditSw_2
	ui_noname	CP_FD_DIR_NAMING_AcFuncEditSw
	ui_noname	CP_FD_DIR_NAMING_IvNaming
	ui_noname	CP_FD_DIR_NAMING_Exit_CP_FD_DIRSEL
	ui_name	CP_FD_DIR_NAMING
	ui_noname	FLS_EDIT_Line_2
	ui_noname	FLS_EDIT_Line
	ui_noname	FLS_EDIT_IvMainEditSw
	ui_name	FLS_EDIT_OPT_BOX
	ui_name	FLS_EDIT_LOC_BOX
	ui_noname	FLS_EDIT_A_L
	ui_noname	FLS_EDIT_A_S
	ui_noname	FLS_EDIT_INS
	ui_noname	FLS_EDIT_DEL2
	ui_noname	FLS_EDIT_DEL1
	ui_noname	FLS_EDIT_AcIndexEditSw_2_F_L_S
	ui_noname	FLS_EDIT_AcIndexEditSw_2_SAVE
	ui_noname	FLS_EDIT_AcIndexEditSw_2
	ui_noname	FLS_EDIT_AcIndexEditSw_SEARCH
	ui_noname	FLS_EDIT_AcIndexEditSw
	ui_name	FLS_EDIT_LINE1
	ui_name	FLS_EDIT_LINE2
	ui_name	FLS_EDIT_LIST_BOX
	ui_noname	FLS_EDIT_NAME_BOX_AL
	ui_noname	FLS_EDIT_NAME_BOX_AS
	ui_name	FLS_EDIT_NAME_BOX
	ui_noname	FLS_EDIT_AcIndexWideES
	ui_noname	FLS_EDIT_Exit_FLS_FILE_LOAD
	ui_name	FLS_EDIT
	ui_noname	FLS_FILE_SEL_AcIndexEditSw_3_SELECT
	ui_noname	FLS_FILE_SEL_AcIndexEditSw_3
	ui_name	FLS_FILE_SEL_OPTBOX
	ui_noname	FLS_FILE_SEL_AcIndexEditSw_2
	ui_noname	FLS_FILE_SEL_AcIndexEditSw
	ui_noname	FLS_FILE_SEL_AcIndexWideES
	ui_name	FLS_FILE_SEL_LISTBOX
	ui_name	FLS_FILE_SEL_DIRBOX
	ui_noname	FLS_FILE_SEL_Exit_FLS_DIR_SEL
	ui_name	FLS_FILE_SEL
	ui_noname	FLS_DIR_SEL_IvMainEditSw
	ui_noname	FLS_DIR_SEL_97_120
	ui_noname	FLS_DIR_SEL_73_96
	ui_noname	FLS_DIR_SEL_49_72
	ui_noname	FLS_DIR_SEL_AcIndexWideES
	ui_noname	FLS_DIR_SEL_25_48
	ui_noname	FLS_DIR_SEL_01_24
	ui_name	FLS_DIR_BOX
	ui_noname	FLS_DIR_SEL_AcIndexEditSw
	ui_noname	FLS_DIR_SEL_Exit_FLS_FILE_LOAD
	ui_name	FLS_DIR_SEL
	ui_noname	FLS_FILE_LOAD_AcIndexWideES_2_PANIC
	ui_noname	FLS_FILE_LOAD_AcIndexWideES_2
	ui_noname	FLS_FILE_LOAD_IvCatchEvent
	ui_name	FLS_LOAD_LINE2
	ui_name	FLS_LOAD_LINE1
	ui_name	FLS_FILE_BOX
	ui_noname	FLS_NAME_BOX_AL
	ui_noname	FLS_NAME_BOX_AS
	ui_name	FLS_NAME_BOX
	ui_name	FLS_LOC_BOX
	ui_name	FLS_OPT_BOX
	ui_noname	FLS_FILE_LOAD_AcIndexEditSw_3
	ui_noname	FLS_FILE_LOAD_AcIndexEditSw_2
	ui_noname	FLS_FILE_LOAD_AcIndexWideES
	ui_noname	FLS_FILE_LOAD_SW_EDIT_EDIT
	ui_name	FLS_FILE_LOAD_SW_EDIT
	ui_noname	FLS_FILE_LOAD_AcIndexEditSw_LOAD
	ui_noname	FLS_FILE_LOAD_AcIndexEditSw
	ui_noname	FLS_FILE_LOAD_Exit_FLS_SELECT
	ui_name	FLS_FILE_LOAD
	ui_noname	HDD_FLS_NAMING_AcFuncEditSw_2_LST
	ui_noname	HDD_FLS_NAMING_AcFuncEditSw_2
	ui_noname	HDD_FLS_NAMING_AcFuncEditSw
	ui_noname	HDD_FLS_NAMING_Exit_FLS_SELECT
	ui_noname	HDD_FLS_NAMING_IvNaming
	ui_name	HDD_FLS_NAMING
	ui_noname	HD_FILE_LOAD_P2_Line_5
	ui_noname	HD_FILE_LOAD_P2_Line_4
	ui_noname	HD_FILE_LOAD_P2_Line_3
	ui_noname	HD_FILE_LOAD_P2_USER_MIDI_SETTINGS
	ui_noname	HD_FILE_LOAD_P2_LYRIC
	ui_noname	HD_FILE_LOAD_P2_AcIndexEditSw_9
	ui_noname	HD_FILE_LOAD_P2_Line_2
	ui_noname	HD_FILE_LOAD_P2_PANEL_MEMORY
	ui_noname	HD_FILE_LOAD_P2_AcRamEditBox
	ui_noname	HD_FILE_LOAD_P2_Line
	ui_noname	HD_FILE_LOAD_P2_TECHNICS_LYRICS
	ui_noname	HD_FILE_LOAD_P2_RHYTHM_CUSTOM
	ui_noname	HD_FILE_LOAD_P2_MSP_2
	ui_noname	HD_FILE_LOAD_P2_SOUND_MEMORY
	ui_noname	HD_FILE_LOAD_P2_COMPOSER
	ui_noname	HD_FILE_LOAD_P2_SEQUENCER
	ui_noname	HD_FILE_LOAD_P2_MIDI
	ui_noname	HD_FILE_LOAD_P2_CUSTOM
	ui_noname	HD_FILE_LOAD_P2_MSP
	ui_noname	HD_FILE_LOAD_P2_SOUND
	ui_noname	HD_FILE_LOAD_P2_COMP
	ui_noname	HD_FILE_LOAD_P2_SEQ
	ui_noname	HD_FILE_LOAD_P2_P_MEM
	ui_noname	HD_FILE_LOAD_P2_AcIndexEditSw_8
	ui_noname	HD_FILE_LOAD_P2_AcIndexEditSw_7
	ui_noname	HD_FILE_LOAD_P2_AcIndexEditSw_6
	ui_noname	HD_FILE_LOAD_P2_AcIndexEditSw_5
	ui_noname	HD_FILE_LOAD_P2_AcIndexEditSw_4
	ui_noname	HD_FILE_LOAD_P2_AcIndexEditSw_3
	ui_noname	HD_FILE_LOAD_P2_AcIndexEditSw_2
	ui_noname	HD_FILE_LOAD_P2_PNL
	ui_noname	HD_FILE_LOAD_P2_AcIndexEditSw
	ui_noname	HD_FILE_LOAD_P2_CURRENT_PANEL
	ui_noname	HD_FILE_LOAD_P2_Icon
	ui_noname	HD_FILE_LOAD_P2_HD_LOAD_OPTION
	ui_name	HD_FILE_LOAD_P2
	ui_noname	HD_FILE_LOAD_SW_DELFILE_FILE
	ui_noname	HD_FILE_LOAD_SW_DELFILE_DEL
	ui_name	HD_FILE_LOAD_SW_DELFILE
	ui_noname	HD_FILE_LOAD_SW_DEL_DIR
	ui_noname	HD_FILE_LOAD_SW_DEL_DEL
	ui_name	HD_FILE_LOAD_SW_DEL
	ui_noname	HD_FILE_LOAD_P1_HD_FILE_SELECT
	ui_noname	HD_FILE_LOAD_P1_Icon
	ui_noname	HD_FILE_LOAD_P1_AcIndexEditSw_2
	ui_noname	HD_FILE_LOAD_P1_AcIndexWideES
	ui_noname	HD_FILE_LOAD_P1_AcIndexEditSw
	ui_name	FILE_LOAD_DIRBOX
	ui_name	HD_FILE_LIST
	ui_name	HD_FILE_OPTION
	ui_noname	HD_FILE_LOAD_SW_SAVE_SAVE
	ui_name	HD_FILE_LOAD_SW_SAVE
	ui_name	HD_FILE_LOAD_P1
	ui_noname	FLS_SELECT_Line
	ui_noname	FLS_SELECT_80
	ui_noname	FLS_SELECT_IvMainEditSw
	ui_name	SEL_FLS
	ui_noname	FLS_SELECT_SW_EDIT_EDIT
	ui_name	FLS_SELECT_SW_EDIT
	ui_name	FLS_SEL
	ui_noname	FLS_SELECT_97_120
	ui_noname	FLS_SELECT_73_96
	ui_noname	FLS_SELECT_49_72
	ui_noname	FLS_SELECT_AcIndexWideES
	ui_noname	FLS_SELECT_25_48
	ui_noname	FLS_SELECT_01_24
	ui_noname	FLS_SELECT_Exit_HDDMENU
	ui_name	FLS_SELECT
	ui_noname	CP_FD_DIRSEL_IvMainEditSw
	ui_noname	CP_FD_DIRSEL_AcIndexEditSw_2_EDIT
	ui_noname	CP_FD_DIRSEL_AcIndexEditSw_2
	ui_noname	CP_FD_DIRSEL_97_120
	ui_noname	CP_FD_DIRSEL_73_96
	ui_noname	CP_FD_DIRSEL_49_72
	ui_noname	CP_FD_DIRSEL_AcIndexWideES
	ui_noname	CP_FD_DIRSEL_25_48
	ui_noname	CP_FD_DIRSEL_01_24
	ui_name	CP_FD_DIRBOX
	ui_noname	CP_FD_DIRSEL_AcIndexEditSw_COPY
	ui_noname	CP_FD_DIRSEL_AcIndexEditSw
	ui_noname	CP_FD_DIRSEL_Exit_CP_FD
	ui_name	CP_FD_DIRSEL
	ui_noname	CP_FD_HDALLSEL_SEL_ALL
	ui_name	CP_FD_HDALLSEL
	ui_noname	CP_FD_StringBox
	ui_name	CP_FD_VOLLABEL
	ui_noname	CP_FD_HDSWSEL_SELECT
	ui_name	CP_FD_HDSWSEL
	ui_noname	CP_FD_HDSWTO_TO
	ui_name	CP_FD_HDSWTO
	ui_name	CP_FD_LINE1
	ui_name	CP_FD_LINE2
	ui_name	CP_FD_LIST
	ui_noname	CP_FD_AcIndexWideES
	ui_noname	CP_FD_AcIndexEditSw_2
	ui_noname	CP_FD_AcIndexEditSw
	ui_noname	CP_FD_Exit_HDDMENU
	ui_name	CP_FD
	ui_noname	LBN_P2_80
	ui_noname	LBN_P2_Line_5
	ui_noname	LBN_P2_AcIndexEditSw_9_LOAD
	ui_noname	LBN_P2_AcIndexEditSw_9
	ui_noname	LBN_P2_Line_4
	ui_noname	LBN_P2_MIDI
	ui_noname	LBN_P2_CUSTOM
	ui_noname	LBN_P2_MSP_2
	ui_noname	LBN_P2_SOUND
	ui_noname	LBN_P2_COMP
	ui_noname	LBN_P2_SEQ
	ui_noname	LBN_P2_P_MEM
	ui_noname	LBN_P2_PNL
	ui_noname	LBN_P2_AcIndexEditSw_8
	ui_noname	LBN_P2_AcIndexEditSw_7
	ui_noname	LBN_P2_AcIndexEditSw_6
	ui_noname	LBN_P2_AcIndexEditSw_5
	ui_noname	LBN_P2_AcIndexEditSw_4
	ui_noname	LBN_P2_AcIndexEditSw_3
	ui_noname	LBN_P2_AcIndexEditSw_2
	ui_noname	LBN_P2_AcIndexEditSw
	ui_noname	LBN_P2_Line_3
	ui_noname	LBN_P2_Line_2
	ui_noname	LBN_P2_Line
	ui_noname	LBN_P2_USER_MIDI_SETTINGS
	ui_noname	LBN_P2_RHYTHM_CUSTOM
	ui_noname	LBN_P2_MSP
	ui_noname	LBN_P2_SOUND_MEMORY
	ui_noname	LBN_P2_COMPOSER
	ui_noname	LBN_P2_SEQUENCER
	ui_noname	LBN_P2_PANEL_MEMORY_Line
	ui_noname	LBN_P2_PANEL_MEMORY
	ui_noname	LBN_P2_CURRENT_PANEL
	ui_noname	LBN_P2_AcRamEditBox
	ui_name	LBN_P2
	ui_noname	LBN_P1_Press_3_digits_for_direc
	ui_noname	LBN_P1_AcIndexWideES
	ui_noname	LBN_P1_IvCatchEvent
	ui_name	LBN_FILENAME_BOX
	ui_name	LBN_FILENO_BOX
	ui_name	LBN_DIRNAME_BOX
	ui_name	LBN_DIRNO_BOX
	ui_noname	LBN_P1_9
	ui_noname	LBN_P1_8
	ui_noname	LBN_P1_7
	ui_noname	LBN_P1_6
	ui_noname	LBN_P1_5
	ui_noname	LBN_P1_4
	ui_noname	LBN_P1_3
	ui_noname	LBN_P1_2
	ui_noname	LBN_P1_TextBox_1
	ui_noname	LBN_P1_TextBox_0
	ui_noname	LBN_P1_TextBox
	ui_noname	LBN_P1_Line
	ui_noname	LBN_P1_80
	ui_noname	LBN_P1_AcIndexEditSw_LOAD
	ui_noname	LBN_P1_AcIndexEditSw
	ui_name	LBN_OPTION
	ui_noname	LBN_P1_PsMenuBox_CLEAR
	ui_noname	LBN_P1_PsMenuBox
	ui_name	LBN_P1
	ui_noname	LOAD_BY_NUM_IvCatchEvent
	ui_noname	LOAD_BY_NUM_AcWindowPage1
	ui_noname	LOAD_BY_NUM_Page_LBN_P2
	ui_noname	LOAD_BY_NUM_Page_LBN_P1
	ui_noname	LOAD_BY_NUM_Exit_HDDMENU
	ui_name	LOAD_BY_NUM
	ui_noname	OUTPUT_SETTING_The_separate_outputs_can
	ui_noname	OUTPUT_SETTING_PART_SELECT_FOR_SEQ_BASS
	ui_noname	OUTPUT_SETTING_PART_SELECT_FOR_SEQ_DRUM
	ui_noname	OUTPUT_SETTING_SEPARATE_OUTPUT_MODE
	ui_noname	OUTPUT_SETTING_AcRamEditBox_3
	ui_noname	OUTPUT_SETTING_AcRamEditBox_2
	ui_noname	OUTPUT_SETTING_AcRamEditBox
	ui_noname	OUTPUT_SETTING_AcIndexWideES
	ui_noname	OUTPUT_SETTING_Exit_HDDMENU
	ui_name	OUTPUT_SETTING
	ui_noname	SETUP_TOOLS_P2_Go_ABOUT_HELP_Text
	ui_noname	SETUP_TOOLS_P2_Go_ABOUT_HELP_VwUserBitmap
	ui_noname	SETUP_TOOLS_P2_Go_ABOUT_HELP
	ui_noname	SW_HD_FORMAT_VwUserBitmap
	ui_name	SW_HD_FORMAT
	ui_noname	SETUP_TOOLS_P2_IvMainEditSw
	ui_noname	SETUP_TOOLS_P2_HD_AE_INFOS_VwUserBitmap
	ui_noname	SETUP_TOOLS_P2_HD_AE_INFOS
	ui_noname	SETUP_TOOLS_P2_SAVE_SETUP_Text
	ui_noname	SETUP_TOOLS_P2_SAVE_SETUP
	ui_name	SETUP_TOOLS_P2
	ui_noname	SETUP_TOOLS_P1_LYRIC_SETTINGS_VwUserBitmap
	ui_noname	SETUP_TOOLS_P1_LYRIC_SETTINGS
	ui_noname	SETUP_TOOLS_P1_LD_BY_NUM_M
	ui_noname	SETUP_TOOLS_P1_WRITE_CONFIRM_Text
	ui_noname	SETUP_TOOLS_P1_WRITE_CONFIRM
	ui_noname	SETUP_TOOLS_P1_JUMP_AFTER_LD
	ui_noname	SETUP_TOOLS_P1_QUICK_LD_MODE
	ui_noname	SETUP_TOOLS_P1_WRITE_PROTECT_Text
	ui_noname	SETUP_TOOLS_P1_WRITE_PROTECT
	ui_noname	SETUP_TOOLS_P1_AcIndexWideES
	ui_noname	SETUP_TOOLS_P1_PC_DATA_LINK_VwUserBitmap
	ui_noname	SETUP_TOOLS_P1_PC_DATA_LINK
	ui_name	SETUP_TOOLS_P1
	ui_noname	PC_DATA_LINK_VwUserBitmap
	ui_noname	PC_DATA_LINK_AcIndexWideES_2_START
	ui_noname	PC_DATA_LINK_AcIndexWideES_2
	ui_noname	PC_DATA_LINK_AcIndexWideES_CANCEL
	ui_noname	PC_DATA_LINK_AcIndexWideES
	ui_name	PP_STATUS
	ui_noname	PC_DATA_LINK_IvCatchEvent
	ui_name	PC_DATA_LINK
	ui_noname	HD_UTIL_READ_ID
	ui_noname	HD_UTIL_FORMAT
	ui_noname	HD_UTIL_DbMemo
	ui_noname	HD_UTIL_IvCatchEvent
	ui_noname	HD_UTIL_Exit_SETUPS_TOOLS
	ui_name	HD_UTIL
	ui_noname	HD_PLEASE_WIN_PLEASE_WAIT
	ui_name	HD_PLEASE_WIN
	ui_noname	HDD_DIR_NAMING_AcFuncEditSw_2_LST
	ui_noname	HDD_DIR_NAMING_AcFuncEditSw_2
	ui_noname	HDD_DIR_NAMING_Exit_SELECT_DIR
	ui_noname	HDD_DIR_NAMING_AcFuncEditSw
	ui_noname	HDD_DIR_NAMING_IvNaming
	ui_name	HDD_DIR_NAMING
	ui_name	HD_FILE_NAME
	ui_noname	HDD_FILE_NAMING_AcFuncEditSw_3_LST
	ui_noname	HDD_FILE_NAMING_AcFuncEditSw_3
	ui_noname	HDD_FILE_NAMING_IvHddNaming
	ui_noname	HDD_FILE_NAMING_AcFuncEditSw_2_OPT
	ui_noname	HDD_FILE_NAMING_AcFuncEditSw_2
	ui_noname	HDD_FILE_NAMING_Exit_SELECT_FILE
	ui_noname	HDD_FILE_NAMING_AcFuncEditSw
	ui_noname	HDD_FILE_NAMING_IvMainEditSw
	ui_name	HDD_FILE_NAMING
	ui_name	HDD_SW
	ui_name	FD_SW
	ui_name	PPORT_SW
	ui_noname	HARD_TEST_DbMemoCl
	ui_name	RUN_STOP
	ui_noname	HARD_TEST_Exit_HDDMENU_2
	ui_noname	HARD_TEST_Exit_HDDMENU_IvCatchEvent
	ui_noname	HARD_TEST_Exit_HDDMENU
	ui_name	HARD_TEST
	ui_noname	FD_FILE_SELECT_SelectList
	ui_noname	FD_FILE_SELECT_AcIndexWideES_2_SELECT
	ui_noname	FD_FILE_SELECT_AcIndexWideES_2
	ui_noname	FD_FILE_SELECT_AcIndexEditSw_2
	ui_noname	FD_FILE_SELECT_Line
	ui_noname	FD_FILE_SELECT_Go_SELECT_FILE_2
	ui_noname	FD_FILE_SELECT_AcIndexEditSw
	ui_noname	FD_FILE_SELECT_AcIndexWideES
	ui_noname	FD_FILE_SELECT_Go_SELECT_FILE_COPY
	ui_noname	FD_FILE_SELECT_Go_SELECT_FILE
	ui_name	FD_FILE_SELECT
	ui_noname	SELECT_DIR2_AcIndexEditSw_2
	ui_noname	SELECT_DIR2_Line
	ui_noname	SELECT_DIR2_Go_SELECT_FILE_2_OK
	ui_noname	SELECT_DIR2_Go_SELECT_FILE_2
	ui_noname	SELECT_DIR2_AcIndexEditSw
	ui_noname	SELECT_DIR2_AcIndexWideES
	ui_noname	SELECT_DIR2_Go_SELECT_FILE_OK
	ui_noname	SELECT_DIR2_Go_SELECT_FILE
	ui_name	SELECT_DIR2
	ui_noname	SELECT_DIR_Line
	ui_noname	SELECT_DIR_80
	ui_noname	SELECT_DIR_Exit_HDDMENU
	ui_noname	SELECT_DIR_SW_EDIT_EDIT
	ui_name	SELECT_DIR_SW_EDIT
	ui_noname	SELECT_DIR_AcIndexEditSw
	ui_noname	SELECT_DIR_73_96
	ui_noname	SELECT_DIR_49_72
	ui_noname	SELECT_DIR_25_48
	ui_noname	SELECT_DIR_01_24
	ui_noname	SELECT_DIR_97_120
	ui_name	SEL_DIR
	ui_noname	SELECT_DIR_IvMainEditSw
	ui_noname	SELECT_DIR_AcIndexWideES
	ui_name	SELECT_DIR
	ui_noname	SELECT_FILE_AcWindowPage1
	ui_noname	SELECT_FILE_IvMainEditSw
	ui_noname	SELECT_FILE_80
	ui_noname	SELECT_FILE_Line
	ui_noname	SELECT_FILE_AcIndexEditSw_LOAD
	ui_noname	SELECT_FILE_AcIndexEditSw
	ui_name	HD_LOAD_OPTION
	ui_name	HD_FILE_LOAD
	ui_noname	SELECT_FILE_Exit_SELECT_DIR
	ui_name	SELECT_FILE
	ui_noname	SETUPS_TOOLS_AcWindowPage1
	ui_noname	SETUPS_TOOLS_Page_SETUP_TOOLS_P1
	ui_noname	SETUPS_TOOLS_Page_SETUP_TOOLS_P2
	ui_noname	SETUPS_TOOLS_Exit_HDDMENU
	ui_name	SETUPS_TOOLS
	ui_noname	HDDMENU_LYRIC_WINDOW
	ui_noname	HDDMENU_Go_Tech_lyrics_Text
	ui_noname	HDDMENU_Go_Tech_lyrics
	ui_noname	HDDMENU_Evaluation_01_01_99
	ui_noname	HDDMENU_Go_SELECT_DIR_Text
	ui_noname	HDDMENU_Go_SELECT_DIR
	ui_noname	HDDMENU_VwUserBitmap
	ui_noname	HDDMENU_IvMainEditSw
	ui_noname	HDDMENU_IvCatchEvent
	ui_name	HARD_DISK_OPT
	ui_noname	HDDMENU_Go_OUTPUT_SETTING_Text
	ui_noname	HDDMENU_Go_OUTPUT_SETTING
	ui_noname	HDDMENU_COPY_FD_TO_HARD_DISK_Text
	ui_noname	HDDMENU_COPY_FD_TO_HARD_DISK
	ui_noname	HDDMENU_Go_FLS_SELECT_Text
	ui_noname	HDDMENU_Go_FLS_SELECT
	ui_noname	HDDMENU_Go_LOAD_BY_NUM_Text
	ui_noname	HDDMENU_Go_LOAD_BY_NUM
	ui_noname	HDDMENU_SETUP_TOOLS
	ui_name	HDDMENU
