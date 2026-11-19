; ---------------------------------------------------------------------------
; Scan the floppy: needs media type 2 or 3 from the main CPU
; (HamaFn_GetMediaType; else HDAE5000_ShowErrorMessageTitle(2) and HL =
; 0xFFFF), blanks the list (HDAE5000_FdList_Clear), shows the volume label,
; then walks "*.*" with HamaFn__findfirst / _findnext / _findclose: every name
; whose HDAE5000_FdName_SongNumber is n sets present flag n (FdList+0x100) and
; puts its 6 characters in row n.  Caller: HDDTitleSwCatch.
; ---------------------------------------------------------------------------
HDAE5000_FdList_Scan:	.include "includes/generated/cc900/HDAE5000_FdList_Scan.s"	; C: cc900/hdae5000_fdlist_scan.c
	; --- Sub-handler 1: event 0x01C00007 dispatch (0x28310D) ---
HDAE5000_HDDTitleSwCatch:	.include "includes/generated/cc900/HDAE5000_HDDTitleSwCatch.s"	; C: cc900/hdae5000_drv_screens4_hd_driver.c
	; --- Sub-handler 2: event handler for 0xD9 (0x28317B) ---
HDAE5000_AttenCpToHDSwCatch:	.include "includes/generated/cc900/HDAE5000_AttenCpToHDSwCatch.s"	; C: cc900/hdae5000_song_io_hd_driver.c
	; --- Sub-handler 3: event handler for 0xD8 (0x283237) ---
HDAE5000_AttenCpToMarkSwCatch:	.include "includes/generated/cc900/HDAE5000_AttenCpToMarkSwCatch.s"	; C: cc900/hdae5000_song_io_hd_driver.c

; ---------------------------------------------------------------------------
; Build the settings / status text of the HD title screen in
; HDAE5000_RAM_TitleInfoText from HDAE5000_TitleInfo_Template and show it in
; object 0x7F000A: "WRITE PROTECTION :" <- HDAE5000_RAM_WriteProtect (ON/OFF),
; "WRITE CONFIRM :" <- _WriteConfirm, "QUICK LOAD MODE:" <- _QuickLoadMode,
; "JUMP AFTER LOAD:" <- _JumpAfterLoad, "LOAD BY NUMBER MODE:" <-
; _LoadByNumberMode, "FREE HDD SPACE :" <- HDAE5000_HD_GetDiskUsage's free
; space / 100, in MB.  Caller: HdTitleEventCatch.
; ---------------------------------------------------------------------------
HDAE5000_TitleInfo_Build:	.include "includes/generated/cc900/HDAE5000_TitleInfo_Build.s"	; C: cc900/hdae5000_title_info.c

; --- Event handler sub-function ---
HDAE5000_HdTitleEventCatch:	.include "includes/generated/cc900/HDAE5000_HdTitleEventCatch.s"	; C: cc900/hdae5000_title_info.c

; --- Jump table dispatcher sub-function ---
HDAE5000_HDAETitleFunc:	.include "includes/generated/cc900/HDAE5000_HDAETitleFunc.s"	; C: cc900/hdae5000_drv_screens6.c

; ---------------------------------------------------------------------------
; Build one page of the directory list in HDAE5000_RAM_DirListText: 24 rows of
; 21 bytes, each the row template HDAE5000_Str_Chr2020203A2020 with the
; directory number (HDAE5000_RAM_DirPageBase + row + 1, "%3d") at +0 and the
; 16-byte directory name (HDAE5000_DirName_Address) at +4.  Then
; RootFn_ApPostEvent posts EVT_HDAE_SET_STR_ADR (XDE = the text) and
; EVT_PARA_DRAW to the list object.
; In:  XWA = list object
; RAM: HDAE5000_RAM_DirListText, HDAE5000_RAM_DirPageBase,
;      HDAE5000_RAM_MainWorkspacePtr
; ---------------------------------------------------------------------------
HDAE5000_DirList_BuildPage:	.include "includes/generated/cc900/HDAE5000_DirList_BuildPage.s"	; C: cc900/hdae5000_list_pages_hd_driver.c

; --- HDAE5000_SEL_DIR_Screen (0x2837F2) -------------------------------------
; Firmware's own name: HDAE5000_ScreenProc_Table entry 1 is 0x2837F2 and the
; parallel HDAE5000_ScreenName_Table entry points at 0x2A8570 =
; "SEL_DIR_Screen".  The old label HD_Format_Dispatch was a misnomer: the
; routine formats nothing.  It is the directory-selection screen procedure --
; every arm drives RAM 0x23A08E, which HDAE5000_Browser_State documents as the
; row-base offset added to every browser row address, over the five row slots
; 0x0000/0x0018/0x0030/0x0048/0x0060 (5 x 24 bytes).  0x01EA0000 adds 0x18 to
; that offset and gives up once it has reached the 0x0060 ceiling; 0x01EA0001
; subtracts 0x18 and gives up below the 0x0018 floor; both then post
; 0x01EA0003 back to the UI.  [INFERENCE] which of the two moves the list
; "down" on screen is not proven by this ROM.
;
; The 0x01EA000n codes are this module's own ResMethod ids: HDAE5000_Handler_Registration
; registers HDAE5000_MessageName_Table (copied to HDAE5000_RAM_MessageName_Table) at
; object slot 0x1EA with ResMethodProc, and the main CPU's ResMethodProc names id
; 0x01EAKKKK as entry KKKK of that table: n=0 MT_OverFlow, n=1 MT_UnderFlow,
; n=3 MT_SetSelNum, n=6/7 MT_SelectOK/MT_SelectOK2, n=8 MT_SelectSAVE
; (notes/event-codes-2026-10-02, group evt-01E8-01EF).  OverFlow / UnderFlow are what
; HDAE5000_SelectListProc sends when ChangeSelNum leaves the list; SelectOK / OK2 /
; SAVE are the list's soft buttons, forwarded with the current selection in IZ.
; Dispatches 0x01EA0000, 0x01EA0001, 0x01EA0006, 0x01EA0007, 0x01EA0008 and
; 0x01C00007; every other code falls straight through to .Lfd_done.
HDAE5000_SEL_DIR_Screen:	.include "includes/generated/cc900/HDAE5000_SEL_DIR_Screen.s"	; C: cc900/hdae5000_drv_screens3.c

; ---------------------------------------------------------------------------
; Fill the part list of a song's list object: HDAE5000_RAM_PartListText gets
; the eight 14-byte names of HDAE5000_PartNames_Text ("CURRENT PANEL" ...,
; parts LSW..MD; v1.x has no LYRICS part), each part whose bit is clear in the mask is
; overwritten with HDAE5000_PartName_Blank, and the whole text is blank when
; BC or DE is 0xFFFF or the mask is 0xFFFF.  Then RootFn_ApPostEvent posts
; EVT_HDAE_SET_STR_ADR (XDE = the text) and EVT_PARA_DRAW to the object.
; In:  XWA = list object, BC = directory, DE = song (only tested for 0xFFFF),
;      (xsp+4) = part mask word (bit k = part k present); retd pops it
; RAM: HDAE5000_RAM_PartListText, HDAE5000_RAM_MainWorkspacePtr
; ---------------------------------------------------------------------------
HDAE5000_PartList_Build:	.include "includes/generated/cc900/HDAE5000_PartList_Build.s"	; C: cc900/hdae5000_partlist__build_r72.c

; ---------------------------------------------------------------------------
; Refresh the song-selection screen: title "DIRECTORY NN:<name>"
; (HDAE5000_RAM_SongScreenTitle), the 16 song rows of directory
; HDAE5000_RAM_CurDir (HDAE5000_RAM_SongListText, 30 bytes each) and the part
; list of song HDAE5000_RAM_CurSong (HDAE5000_PartList_Build with
; HDAE5000_Song_PartMask); one variant picks the object-id pairs of another
; screen; C != 0 skips the static parts.
; In:  A = variant (which object-id pairs), C = 0 to redraw the title as well
; ---------------------------------------------------------------------------
HDAE5000_SongScreen_Refresh:	.include "includes/generated/cc900/HDAE5000_SongScreen_Refresh.s"	; C: cc900/hdae5000_song_refresh.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SongScreen_Refresh_Join, HDAE5000_SongScreen_Refresh + 245
	.set	HDAE5000_SongScreen_Refresh_Loop, HDAE5000_SongScreen_Refresh + 260
	.set	HDAE5000_SongScreen_Refresh_Join2, HDAE5000_SongScreen_Refresh + 381
	.set	HDAE5000_SongScreen_Refresh_Join3, HDAE5000_SongScreen_Refresh + 477
	.set	HDAE5000_SongScreen_Refresh_Skip, HDAE5000_SongScreen_Refresh + 533
	.set	HDAE5000_SongScreen_Refresh_Epilogue, HDAE5000_SongScreen_Refresh + 563

HDAE5000_FILE_LOAD_Screen:
	; registered as "FILE_LOAD_Screen" in HDAE5000_ScreenProc_Table
	push xiz
	ld	xiz, xde
	ld	xwa, xbc
	cp	xwa, EVT_SW_IN
	jrl	z, HDAE5000_FILE_LOAD_Screen_Default
	cp	xwa, EVT_SHOW
	jr	z, HDAE5000_FILE_LOAD_Screen_Ev01C00001
	sub	xwa, EVT_HDAE_OVER_FLOW
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_FILE_LOAD_Screen_Default
	cp	xwa, 0x0000000c
	jrl	gt, HDAE5000_FILE_LOAD_Screen_Default
	add	xwa, xwa
	add	xwa, HDAE5000_FILE_LOAD_Screen_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_FILE_LOAD_Screen_Ev01C00001:24)
	jp	t, (xix+wa)
HDAE5000_FILE_LOAD_Screen_Ev01C00001:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_HD_FILE_LIST
	ld	xbc, EVT_HDAE_CHANGE_SEL_NUM
	ld	xde, 0:i3
	call	(xhl)
	jrl	t, HDAE5000_FILE_LOAD_Screen_Default
HDAE5000_FILE_LOAD_Screen_Ev01EA0008:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateAllNo:24)
	ldw	bc, 0x003f
	calr	HDAE5000_TypeSel_Init
	ld	(HDAE5000_RAM_CurSong), iz
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_SongRecord_Address
	ld	xde, xhl
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApFuncCall)
	ld	xwa, NAKA_APFUNC_HDDNamingCheck
	ld	xbc, EVT_SET_STRING
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_HDD_FILE_NAMING
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl	t, HDAE5000_FILE_LOAD_Screen_Default
HDAE5000_FILE_LOAD_Screen_Ev01EA000C:
	ld	(HDAE5000_RAM_CurSong), iz
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	ld	de, 0:i3
	calr	HDAE5000_DelOpt_InitFromSong
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FILE_DEL_SCREEN
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl	t, HDAE5000_FILE_LOAD_Screen_Default
HDAE5000_FILE_LOAD_Screen_Ev01EA000B:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_ATTEN_DEL_DIR
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl	t, HDAE5000_FILE_LOAD_Screen_Default
HDAE5000_FILE_LOAD_Screen_Ev01EA0001:
	cpw	(HDAE5000_RAM_CurDir:24), 0
	jrl	z, HDAE5000_FILE_LOAD_Screen_Default
	decw	1, (HDAE5000_RAM_CurDir:24)
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_SongScreen_Refresh
	ld	xwa, xiz
	add	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_HD_FILE_LIST
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jrl	t, HDAE5000_FILE_LOAD_Screen_Default
HDAE5000_FILE_LOAD_Screen_Ev01EA0000:
	cpw	(HDAE5000_RAM_CurDir:24), 119
	jr	nc, HDAE5000_FILE_LOAD_Screen_Default
	incw	1, (HDAE5000_RAM_CurDir:24)
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_SongScreen_Refresh
	ld	xwa, xiz
	sub	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_HD_FILE_LIST
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jr	t, HDAE5000_FILE_LOAD_Screen_Default
HDAE5000_FILE_LOAD_Screen_Ev01EA0002:
	ld	(HDAE5000_RAM_CurSong), iz
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_PartMask
	ld	wa, hl
	cp	wa, 0xffff
	jr	z, HDAE5000_FILE_LOAD_Screen_Ev01EA0002_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	ld	bc, hl
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	calr	HDAE5000_TypeSel_Init
	jr	t, HDAE5000_FILE_LOAD_Screen_Ev01EA0002_Join
HDAE5000_FILE_LOAD_Screen_Ev01EA0002_Skip:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	ld	bc, 0:i3
	calr	HDAE5000_TypeSel_Init
HDAE5000_FILE_LOAD_Screen_Ev01EA0002_Join:
	ld	wa, 0:i3
	ld	bc, 1:i3
	calr	HDAE5000_SongScreen_Refresh
HDAE5000_FILE_LOAD_Screen_Default:
	ld	xhl, 0:i3
	pop xiz
	ret

HDAE5000_AttenDelDirSwCatch:	.include "includes/generated/cc900/HDAE5000_AttenDelDirSwCatch.s"	; C: cc900/hdae5000_drv_screens.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_AttenDelDirSwCatch_OnAreYouClassProc, HDAE5000_AttenDelDirSwCatch + 51
	.set	HDAE5000_AttenDelDirSwCatch_OnDraw, HDAE5000_AttenDelDirSwCatch + 56
	.set	HDAE5000_AttenDelDirSwCatch_OnSwIn, HDAE5000_AttenDelDirSwCatch + 113
	.set	HDAE5000_AttenDelDirSwCatch_Join, HDAE5000_AttenDelDirSwCatch + 168
	.set	HDAE5000_AttenDelDirSwCatch_Skip, HDAE5000_AttenDelDirSwCatch + 259
	.set	HDAE5000_AttenDelDirSwCatch_Done, HDAE5000_AttenDelDirSwCatch + 288
	.set	HDAE5000_AttenDelDirSwCatch_Epilogue, HDAE5000_AttenDelDirSwCatch + 290

HDAE5000_AttenDelFileSwCatch:	.include "includes/generated/cc900/HDAE5000_AttenDelFileSwCatch.s"	; C: cc900/hdae5000_drv_screens3.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_AttenDelFileSwCatch_OnAreYouClassProc, HDAE5000_AttenDelFileSwCatch + 51
	.set	HDAE5000_AttenDelFileSwCatch_OnDraw, HDAE5000_AttenDelFileSwCatch + 56
	.set	HDAE5000_AttenDelFileSwCatch_OnSwIn, HDAE5000_AttenDelFileSwCatch + 113
	.set	HDAE5000_AttenDelFileSwCatch_Join, HDAE5000_AttenDelFileSwCatch + 171
	.set	HDAE5000_AttenDelFileSwCatch_Skip, HDAE5000_AttenDelFileSwCatch + 289
	.set	HDAE5000_AttenDelFileSwCatch_Done, HDAE5000_AttenDelFileSwCatch + 318
	.set	HDAE5000_AttenDelFileSwCatch_Epilogue, HDAE5000_AttenDelFileSwCatch + 320

HDAE5000_FileLoadSwCatch:
	; registered as "FileLoadSwCatch" in HDAE5000_ScreenProc_Table
	cp	xbc, EVT_SW_IN
	jr	nz, HDAE5000_FileLoadSwCatch_Done
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000009
	jr	z, HDAE5000_FileLoadSwCatch_Join
	cp	xhl, 0x00000008
	jr	nz, HDAE5000_FileLoadSwCatch_Done
HDAE5000_FileLoadSwCatch_Join:
	pushw 0x0000
	ld	xwa, HDAE5000_OBJ_SELECT_FILE
	push xwa
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	ld	de, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_LoadSongWithUi
HDAE5000_FileLoadSwCatch_Done:
	ld	xhl, 0:i3
	ret

HDAE5000_FILE_Naming_Screen:
	; registered as "FILE_Naming_Screen" in HDAE5000_ScreenProc_Table
	cp	xbc, EVT_SW_IN
	jr	nz, HDAE5000_FILE_Naming_Screen_Done
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x0000000b
	jr	z, HDAE5000_FILE_Naming_Screen_Done
HDAE5000_FILE_Naming_Screen_Done:
	ld	xhl, 0:i3
	ret

HDAE5000_HDDNamingCheck:	.include "includes/generated/cc900/HDAE5000_HDDNamingCheck.s"	; C: cc900/hdae5000_drv_screens3.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_HDDNamingCheck_OnSetString, HDAE5000_HDDNamingCheck + 66
	.set	HDAE5000_HDDNamingCheck_OnGetNamingMode, HDAE5000_HDDNamingCheck + 88
	.set	HDAE5000_HDDNamingCheck_OnGetStringLength, HDAE5000_HDDNamingCheck + 93
	.set	HDAE5000_HDDNamingCheck_OnSwIn, HDAE5000_HDDNamingCheck + 101
	.set	HDAE5000_HDDNamingCheck_Skip, HDAE5000_HDDNamingCheck + 205
	.set	HDAE5000_HDDNamingCheck_Skip2, HDAE5000_HDDNamingCheck + 248
	.set	HDAE5000_HDDNamingCheck_Join, HDAE5000_HDDNamingCheck + 266
	.set	HDAE5000_HDDNamingCheck_Skip3, HDAE5000_HDDNamingCheck + 332
	.set	HDAE5000_HDDNamingCheck_Skip4, HDAE5000_HDDNamingCheck + 425
	.set	HDAE5000_HDDNamingCheck_Join2, HDAE5000_HDDNamingCheck + 458
	.set	HDAE5000_HDDNamingCheck_Done, HDAE5000_HDDNamingCheck + 465
	.set	HDAE5000_HDDNamingCheck_Epilogue, HDAE5000_HDDNamingCheck + 467

HDAE5000_HDD_DIRNAMECheck:	.include "includes/generated/cc900/HDAE5000_HDD_DIRNAMECheck.s"	; C: cc900/hdae5000_drv_screens2.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_HDD_DIRNAMECheck_OnSetString, HDAE5000_HDD_DIRNAMECheck + 66
	.set	HDAE5000_HDD_DIRNAMECheck_OnGetNamingMode, HDAE5000_HDD_DIRNAMECheck + 94
	.set	HDAE5000_HDD_DIRNAMECheck_OnGetStringLength, HDAE5000_HDD_DIRNAMECheck + 99
	.set	HDAE5000_HDD_DIRNAMECheck_OnSwIn, HDAE5000_HDD_DIRNAMECheck + 107
	.set	HDAE5000_HDD_DIRNAMECheck_Skip, HDAE5000_HDD_DIRNAMECheck + 217
	.set	HDAE5000_HDD_DIRNAMECheck_Done, HDAE5000_HDD_DIRNAMECheck + 293
	.set	HDAE5000_HDD_DIRNAMECheck_Epilogue, HDAE5000_HDD_DIRNAMECheck + 295

; ---------------------------------------------------------------------------
; The hard-disk utility page.  Switch 11 prints the drive's identity and the
; panel's resource information (HDAE5000_HardTest_HddIdRead, HamaFn_GetResouceInfo:
; v2.01i lists LSW, SDA, PMT and SQF; v2.06i also SEQ, CMP, TM, MSP, RCM and MD).
; Switch 9, which v2.06i's handler does not have, formats the drive from here:
; "FORMAT TRY !!!", HDAE5000_HD_FormatDrive, then "FORMAT FINISHED !!!" or
; "FORMAT ERROR !!!" and the error number (HD_FormatDrive's result in L, kept in QIZH).
; ---------------------------------------------------------------------------
HDAE5000_HDD_UTIL_PAGE:
	; registered as "HDD_UTIL_PAGE" in HDAE5000_ObjHandler_Table
	lda	xsp, (xsp-116)
	push	qiz
	ld (xsp + 0x6a), xde
	ld	(xsp + 0x6e), xbc
	ld (xsp + 0x72), xwa
	ld	xwa, (xsp + 0x6e)
	cp	xwa, EVT_SW_IN
	jr	z, HDAE5000_HDD_UTIL_PAGE_OnSwIn
	cp	xwa, EVT_DRAW
	jr	z, HDAE5000_HDD_UTIL_PAGE_OnDraw
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jrl	nz, HDAE5000_HDD_UTIL_PAGE_Join
	ld	xhl, 1:i3
	jrl	t, HDAE5000_HDD_UTIL_PAGE_Epilogue
HDAE5000_HDD_UTIL_PAGE_OnDraw:
	ld xwa, (xsp + 0x72)
	ld	xbc, (xsp + 0x6e)
	ld xde, (xsp + 0x6a)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_UTIL:24)
	ld	xbc, xwa
	ld xwa, (xsp + 0x72)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_HDD_UTIL_PAGE_Epilogue
HDAE5000_HDD_UTIL_PAGE_OnSwIn:
	ld xwa, (xsp + 0x6a)
	cp	xwa, 0x0000000b
	jr	z, HDAE5000_HDD_UTIL_PAGE_OnSwIn_DriveInfo
	cp	xwa, 0x00000009
	jrl	nz, HDAE5000_HDD_UTIL_PAGE_Join
	; switch 9: format the drive (v2.01i only)
	lda	xwa, (HDAE5000_Str_FORMATTRY:24)
	calr	HDAE5000_HardTest_Print
	lda	xwa, (HDAE5000_Str_PleaseWait:24)
	calr	HDAE5000_HardTest_Print
	ld	wa, 1:i3
	call	HDAE5000_HD_FormatDrive
	ldfr_berp	l, 0xfb
	ldto_berp	a, 0xfb
	cp	a, 0:i3
	jr	nz, HDAE5000_HDD_UTIL_PAGE_OnSwIn_FormatError
	lda	xwa, (HDAE5000_Str_FORMATFINISHED:24)
	calr	HDAE5000_HardTest_Print
	jrl	t, HDAE5000_HDD_UTIL_PAGE_Join
HDAE5000_HDD_UTIL_PAGE_OnSwIn_FormatError:
	lda	xwa, (HDAE5000_Str_FORMATERROR:24)
	calr	HDAE5000_HardTest_Print
	pushw	0x40
	pushw	0x0
	lda	xwa, (xsp+46)
	push	xwa
	call	HDAE5000_MemFill
	pushw	HDAE5000_Str_ERRORNO@hi16
	pushw	HDAE5000_Str_ERRORNO@lo16		; low half of HDAE5000_Str_ERRORNO
	lda	xwa, (xsp+54)
	push	xwa
	call	HDAE5000_StrCpy
	pushw	0xa
	lda	xwa, (xsp+28)
	push	xwa
	ldto_berp	a, 0xfb
	extz	wa
	pushw	wa
	call	HDAE5000_IToA
	push	xhl
	lda	xwa, (xsp+70)
	push	xwa
	call	HDAE5000_StrCat
	lda	xsp, (xsp + 32)
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	jrl	t, HDAE5000_HDD_UTIL_PAGE_Join
HDAE5000_HDD_UTIL_PAGE_OnSwIn_DriveInfo:
	calr	HDAE5000_HardTest_HddIdRead
	lda	xwa, (xsp+2)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 0:i3
	call	(xhl)
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_LSWFileInfo@hi16
	pushw	HDAE5000_Str_LSWFileInfo@lo16		; low half of HDAE5000_Str_LSWFileInfo
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	lda	xsp, (xsp+16)
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_Adr@hi16
	pushw	HDAE5000_Str_Adr@lo16		; low half of HDAE5000_Str_Adr
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	pushw 0x000a
	lda	xwa, (xsp+28)
	push xwa
	ld xwa, (xsp + 0x18)
	push xwa
	call HDAE5000_LToA
	lda	xsp, (xsp+26)
	push xhl
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_StrCat
	inc 8, xsp
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_Size@hi16
	pushw	HDAE5000_Str_Size@lo16		; low half of HDAE5000_Str_Size
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	pushw 0x000a
	lda	xwa, (xsp+28)
	push xwa
	ld xwa, (xsp + 0x1c)
	push xwa
	call HDAE5000_LToA
	lda	xsp, (xsp+26)
	push xhl
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_StrCat
	inc 8, xsp
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	lda	xwa, (xsp+2)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 1:i3
	call	(xhl)
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_SDAFileInfo@hi16
	pushw	HDAE5000_Str_SDAFileInfo@lo16		; low half of HDAE5000_Str_SDAFileInfo
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	lda	xsp, (xsp+16)
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_Adr_HDD_UTIL_PAGE@hi16
	pushw	HDAE5000_Str_Adr_HDD_UTIL_PAGE@lo16		; low half of HDAE5000_Str_Adr_HDD_UTIL_PAGE
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	pushw 0x000a
	lda	xwa, (xsp+28)
	push xwa
	ld xwa, (xsp + 0x18)
	push xwa
	call HDAE5000_LToA
	lda	xsp, (xsp+26)
	push xhl
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_StrCat
	inc 8, xsp
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_Size_HDD_UTIL_PAGE@hi16
	pushw	HDAE5000_Str_Size_HDD_UTIL_PAGE@lo16		; low half of HDAE5000_Str_Size_HDD_UTIL_PAGE
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	pushw 0x000a
	lda	xwa, (xsp+28)
	push xwa
	ld xwa, (xsp + 0x1c)
	push xwa
	call HDAE5000_LToA
	lda	xsp, (xsp+26)
	push xhl
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_StrCat
	inc 8, xsp
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	lda	xwa, (xsp+2)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 2:i3
	call	(xhl)
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_PMTFileInfo@hi16
	pushw	HDAE5000_Str_PMTFileInfo@lo16		; low half of HDAE5000_Str_PMTFileInfo
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	lda	xsp, (xsp+16)
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_Adr_HDD_UTIL_PAGE_2@hi16
	pushw	HDAE5000_Str_Adr_HDD_UTIL_PAGE_2@lo16		; low half of HDAE5000_Str_Adr_HDD_UTIL_PAGE_2
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	pushw 0x000a
	lda	xwa, (xsp+28)
	push xwa
	ld xwa, (xsp + 0x18)
	push xwa
	call HDAE5000_LToA
	lda	xsp, (xsp+26)
	push xhl
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_StrCat
	inc 8, xsp
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_Size_HDD_UTIL_PAGE_2@hi16
	pushw	HDAE5000_Str_Size_HDD_UTIL_PAGE_2@lo16		; low half of HDAE5000_Str_Size_HDD_UTIL_PAGE_2
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	pushw 0x000a
	lda	xwa, (xsp+28)
	push xwa
	ld xwa, (xsp + 0x1c)
	push xwa
	call HDAE5000_LToA
	lda	xsp, (xsp+26)
	push xhl
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_StrCat
	inc 8, xsp
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	lda	xwa, (xsp+2)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 3:i3
	call	(xhl)
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_SQFFileInfo@hi16
	pushw	HDAE5000_Str_SQFFileInfo@lo16		; low half of HDAE5000_Str_SQFFileInfo
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	lda	xsp, (xsp+16)
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_Adr_HDD_UTIL_PAGE_3@hi16
	pushw	HDAE5000_Str_Adr_HDD_UTIL_PAGE_3@lo16		; low half of HDAE5000_Str_Adr_HDD_UTIL_PAGE_3
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	pushw 0x000a
	lda	xwa, (xsp+28)
	push xwa
	ld xwa, (xsp + 0x18)
	push xwa
	call HDAE5000_LToA
	lda	xsp, (xsp+26)
	push xhl
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_StrCat
	inc 8, xsp
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
	pushw 0x0040
	pushw 0x0000
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_Size_HDD_UTIL_PAGE_3@hi16
	pushw	HDAE5000_Str_Size_HDD_UTIL_PAGE_3@lo16		; low half of HDAE5000_Str_Size_HDD_UTIL_PAGE_3
	lda	xwa, (xsp+54)
	push xwa
	call HDAE5000_StrCpy
	pushw 0x000a
	lda	xwa, (xsp+28)
	push xwa
	ld xwa, (xsp + 0x1c)
	push xwa
	call HDAE5000_LToA
	lda	xsp, (xsp+26)
	push xhl
	lda	xwa, (xsp+46)
	push xwa
	call HDAE5000_StrCat
	inc 8, xsp
	lda	xwa, (xsp+42)
	calr	HDAE5000_HardTest_Print
HDAE5000_HDD_UTIL_PAGE_Join:
	ld xwa, (xsp + 0x72)
	ld	xbc, (xsp + 0x6e)
	ld xde, (xsp + 0x6a)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
HDAE5000_HDD_UTIL_PAGE_Epilogue:
	pop	qiz
	lda	xsp, (xsp+116)
	ret

; ---------------------------------------------------------------------------
; PC-link service 26: show a status string on the PC-link page -- at most 25
; characters (HDAE5000_StrLen, clamped; HDAE5000_StrNCpy) into
; HDAE5000_RAM_PcLinkStatusText+7, then RootFn_ApPostEvent posts
; EVT_HDAE_SET_STR_ADR (XDE = the text) and EVT_PARA_DRAW to
; HDAE5000_OBJ_PP_STATUS.  The link loop uses it for its status and error
; strings.  HDAE5000_PcLink_ShowStatus is the same with RootFn_SendEvent.
; In:  XWA = string.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc26_ShowStatus:	.include "includes/generated/cc900/HDAE5000_PPORT_Svc26_ShowStatus.s"	; C: cc900/hdae5000_misc3_hd_driver.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_PPORT_Svc26_ShowStatus_Join, HDAE5000_PPORT_Svc26_ShowStatus + 21


; ---------------------------------------------------------------------------
; Show a status string on the PC-link page, as service 26
; (HDAE5000_PPORT_Svc26_ShowStatus) but sending the two events with
; RootFn_SendEvent instead of posting them.
; In:  XWA = string.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PcLink_ShowStatus:	.include "includes/generated/cc900/HDAE5000_PcLink_ShowStatus.s"	; C: cc900/hdae5000_pclink_status.c
	; Part 2: Error handler dispatcher (0x284E53)
	; XWA = original params, XBC = error code, XDE = extra data

HDAE5000_PC_DATA_LINK_PAGE:	.include "includes/generated/cc900/HDAE5000_PC_DATA_LINK_PAGE.s"	; C: cc900/hdae5000_pclink_page.c

; ---------------------------------------------------------------------------
; Send one part's separate-output setting as two 4-byte command blocks to
; the main CPU's sendCOMM (HamaFn_sendCOMM, WA = 0, BC = 4): the templates
; B0 00 9B 00 / B0 00 9D 00 with A in byte 1 of both, L selecting 0x01 or
; 0x20 for byte 3 of the first, E as byte 3 of the second.  Returns without
; sending unless A < 16, L <= 1, E <= 2.  What the sub CPU does with them is
; not established here.  Only caller: HDAE5000_SeparateOutput_Apply.
; In:  A = part - 1, L = selector, E = mode
; ---------------------------------------------------------------------------
HDAE5000_SeparateOutput_SendPartMsg:	.include "includes/generated/cc900/HDAE5000_SeparateOutput_SendPartMsg.s"	; C: cc900/hdae5000_sepout_msg.c

; ---------------------------------------------------------------------------
; Apply the SEPARATE OUTPUT setting: HDAE5000_RAM_SeparateOutputMode ("OFF",
; "DRUMS L/R", "BASS+DRUMS MIX", "BASS/DRUMS MONO") goes to the main CPU
; (HamaFn_SetSepaOutMode); the previous parts (SeparateDrumPartSent /
; SeparateBassPartSent) are undone and the new ones (SeparateDrumPart /
; SeparateBassPart) sent with HDAE5000_SeparateOutput_SendPartMsg.
; ---------------------------------------------------------------------------
HDAE5000_SeparateOutput_Apply:	.include "includes/generated/cc900/HDAE5000_SeparateOutput_Apply.s"	; C: cc900/hdae5000_sepout.c
	;
	; Part 2: Event handler 1 (0x2850ED) — jump table dispatch
HDAE5000_SeparateOutputModeCheck:	.include "includes/generated/cc900/HDAE5000_SeparateOutputModeCheck.s"	; C: cc900/hdae5000_sepout.c
	;
	; Part 3: Event handler 2 (0x285192) — same structure, different data
HDAE5000_SeparateDrumPartCheck:	.include "includes/generated/cc900/HDAE5000_SeparateDrumPartCheck.s"	; C: cc900/hdae5000_sepout.c
	;
	; Part 4: Event handler 3 (0x28523B) — same structure, different data
HDAE5000_SeparateBassPartCheck:	.include "includes/generated/cc900/HDAE5000_SeparateBassPartCheck.s"	; C: cc900/hdae5000_sepout.c

; ---------------------------------------------------------------------------
; Initialise a 12-byte part-selection record from a template: copy the 12
; bytes (6 words, LDIRW), store BC as its mask word, and set the flag byte
; (+2+k) of every part k whose bit is set in BC to the stacked value.  Flags:
; 0 "---", 1 "NO ", 2 "YES"; parts LSW..MD.  Records: HDAE5000_RAM_SaveOptions
; and HDAE5000_RAM_DeleteOptions.
; In:  XWA = record, XDE = template, BC = part mask, (xsp+4) = flag value
;      (low byte of the stacked word; retd pops it)
; Out: clobbers XIX, XIY, HL, E.
; ---------------------------------------------------------------------------
HDAE5000_TypeSel_Init:	.include "includes/generated/cc900/HDAE5000_TypeSel_Init.s"	; C: cc900/hdae5000_uistate_hd_driver__typesel_init_r72.c

; ---------------------------------------------------------------------------
; Recompute the mask word of a part-selection record (see
; HDAE5000_TypeSel_Init): bit k set for every part k whose flag byte (+2+k)
; is 2 ("YES").
; In:  XWA = record (HDAE5000_RAM_SaveOptions or _DeleteOptions)
; Out: (XWA+0) = mask.  No register changes.
; ---------------------------------------------------------------------------
HDAE5000_TypeSel_BuildMask:	.include "includes/generated/cc900/HDAE5000_TypeSel_BuildMask.s"	; C: cc900/hdae5000_hd_driver__typesel_buildmask_r72.c
	; Sub-routine 2: Command dispatcher with computed jump table
	; Input: XWA = context pointer (saved as XIZ), XBC = command ID
	; Returns XHL = result

HDAE5000_SaveOptNameCheck:	.include "includes/generated/cc900/HDAE5000_SaveOptNameCheck.s"	; C: cc900/hdae5000_saveopt_name__saveopt_r71.c

; --- HD Configuration Manager and CHS Geometry ---
HDAE5000_TypeSel_ShowSaveFlags:	; (3728 bytes)
	; Show the eight save-option flags (HDAE5000_RAM_SaveOptions+2..+9) as "---"/"NO "/"YES"
	; (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES) in the objects "RAM_EDIT_LSW".."RAM_EDIT_MD"
	; (0x7F0196.., names from HDAE5000_UiObjectName_PtrTable), event
	; 0x01C0000F.  (Was HD_Config_Manager.)
; LHCM: 0x28541C (3728 bytes)
	; ^ conversion-region size (local-label prefix .LHCM_), not a routine size.

	ld	a, (HDAE5000_RAM_SaveOptions+2:24)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:24)
	ld	xde, (xbc+wa)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_RAM_EDIT_LSW
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	a, (HDAE5000_RAM_SaveOptions+3:24)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:24)
	ld	xde, (xbc+wa)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_RAM_EDIT_PMT
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	a, (HDAE5000_RAM_SaveOptions+4:24)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:24)
	ld	xde, (xbc+wa)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_RAM_EDIT_SQT
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	a, (HDAE5000_RAM_SaveOptions+5:24)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:24)
	ld	xde, (xbc+wa)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_RAM_EDIT_CMP
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	a, (HDAE5000_RAM_SaveOptions+6:24)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:24)
	ld	xde, (xbc+wa)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_RAM_EDIT_TM
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	a, (HDAE5000_RAM_SaveOptions+7:24)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:24)
	ld	xde, (xbc+wa)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_RAM_EDIT_MSP
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	a, (HDAE5000_RAM_SaveOptions+8:24)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:24)
	ld	xde, (xbc+wa)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_RAM_EDIT_RCM
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	a, (HDAE5000_RAM_SaveOptions+9:24)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:24)
	ld	xde, (xbc+wa)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_RAM_EDIT_MD
	ld	xbc, EVT_PARA_DRAW
	jp	(xhl)

HDAE5000_SaveOptSwEventCatch:	.include "includes/generated/cc900/HDAE5000_SaveOptSwEventCatch.s"	; C: cc900/hdae5000_drv_screens3__saveoptsw_r71.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SaveOptSwEventCatch_OnAreYouClassProc, HDAE5000_SaveOptSwEventCatch + 51
	.set	HDAE5000_SaveOptSwEventCatch_OnDraw, HDAE5000_SaveOptSwEventCatch + 56
	.set	HDAE5000_SaveOptSwEventCatch_OnSwIn, HDAE5000_SaveOptSwEventCatch + 113
	.set	HDAE5000_SaveOptSwEventCatch_Skip, HDAE5000_SaveOptSwEventCatch + 269
	.set	HDAE5000_SaveOptSwEventCatch_Join, HDAE5000_SaveOptSwEventCatch + 302
	.set	HDAE5000_SaveOptSwEventCatch_Skip2, HDAE5000_SaveOptSwEventCatch + 311
	.set	HDAE5000_SaveOptSwEventCatch_Skip3, HDAE5000_SaveOptSwEventCatch + 335
	.set	HDAE5000_SaveOptSwEventCatch_Skip4, HDAE5000_SaveOptSwEventCatch + 359
	.set	HDAE5000_SaveOptSwEventCatch_Done, HDAE5000_SaveOptSwEventCatch + 380
	.set	HDAE5000_SaveOptSwEventCatch_Epilogue, HDAE5000_SaveOptSwEventCatch + 382

HDAE5000_FileOptNameCheck:	.include "includes/generated/cc900/HDAE5000_FileOptNameCheck.s"	; C: cc900/hdae5000_name_checks_hd_driver__fileopt_r71.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FileOptNameCheck_Ev01E00047, HDAE5000_FileOptNameCheck + 58
	.set	HDAE5000_FileOptNameCheck_Ev01E0003E, HDAE5000_FileOptNameCheck + 97
	.set	HDAE5000_FileOptNameCheck_Ev01E0003F, HDAE5000_FileOptNameCheck + 101
	.set	HDAE5000_FileOptNameCheck_Ev01E00043, HDAE5000_FileOptNameCheck + 105
	.set	HDAE5000_FileOptNameCheck_Ev01E00044, HDAE5000_FileOptNameCheck + 109
	.set	HDAE5000_FileOptNameCheck_Ev01E00045, HDAE5000_FileOptNameCheck + 113
	.set	HDAE5000_FileOptNameCheck_Ev01E00046, HDAE5000_FileOptNameCheck + 120
	.set	HDAE5000_FileOptNameCheck_OnRamDataReq, HDAE5000_FileOptNameCheck + 124
	.set	HDAE5000_FileOptNameCheck_Default, HDAE5000_FileOptNameCheck + 128
	.set	HDAE5000_FileOptNameCheck_Epilogue, HDAE5000_FileOptNameCheck + 130

HDAE5000_SfxLswBitCheck:	.include "includes/generated/cc900/HDAE5000_SfxLswBitCheck.s"	; C: cc900/hdae5000_sfx_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SfxLswBitCheck_Ev01E00047, HDAE5000_SfxLswBitCheck + 58
	.set	HDAE5000_SfxLswBitCheck_Ev01E0003E, HDAE5000_SfxLswBitCheck + 95
	.set	HDAE5000_SfxLswBitCheck_Ev01E0003F, HDAE5000_SfxLswBitCheck + 99
	.set	HDAE5000_SfxLswBitCheck_Ev01E00043, HDAE5000_SfxLswBitCheck + 103
	.set	HDAE5000_SfxLswBitCheck_Ev01E00043_Join, HDAE5000_SfxLswBitCheck + 115
	.set	HDAE5000_SfxLswBitCheck_Ev01E00044, HDAE5000_SfxLswBitCheck + 117
	.set	HDAE5000_SfxLswBitCheck_Ev01E00044_Join, HDAE5000_SfxLswBitCheck + 129
	.set	HDAE5000_SfxLswBitCheck_Ev01E00045, HDAE5000_SfxLswBitCheck + 131
	.set	HDAE5000_SfxLswBitCheck_Ev01E00046, HDAE5000_SfxLswBitCheck + 138
	.set	HDAE5000_SfxLswBitCheck_OnRamDataReq, HDAE5000_SfxLswBitCheck + 142
	.set	HDAE5000_SfxLswBitCheck_Default, HDAE5000_SfxLswBitCheck + 178
	.set	HDAE5000_SfxLswBitCheck_Epilogue, HDAE5000_SfxLswBitCheck + 180

HDAE5000_SfxPmtBitCheck:	.include "includes/generated/cc900/HDAE5000_SfxPmtBitCheck.s"	; C: cc900/hdae5000_sfx_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SfxPmtBitCheck_Ev01E00047, HDAE5000_SfxPmtBitCheck + 58
	.set	HDAE5000_SfxPmtBitCheck_Ev01E0003E, HDAE5000_SfxPmtBitCheck + 95
	.set	HDAE5000_SfxPmtBitCheck_Ev01E0003F, HDAE5000_SfxPmtBitCheck + 99
	.set	HDAE5000_SfxPmtBitCheck_Ev01E00043, HDAE5000_SfxPmtBitCheck + 103
	.set	HDAE5000_SfxPmtBitCheck_Ev01E00043_Join, HDAE5000_SfxPmtBitCheck + 115
	.set	HDAE5000_SfxPmtBitCheck_Ev01E00044, HDAE5000_SfxPmtBitCheck + 117
	.set	HDAE5000_SfxPmtBitCheck_Ev01E00044_Join, HDAE5000_SfxPmtBitCheck + 129
	.set	HDAE5000_SfxPmtBitCheck_Ev01E00045, HDAE5000_SfxPmtBitCheck + 131
	.set	HDAE5000_SfxPmtBitCheck_Ev01E00046, HDAE5000_SfxPmtBitCheck + 138
	.set	HDAE5000_SfxPmtBitCheck_OnRamDataReq, HDAE5000_SfxPmtBitCheck + 142
	.set	HDAE5000_SfxPmtBitCheck_Default, HDAE5000_SfxPmtBitCheck + 178
	.set	HDAE5000_SfxPmtBitCheck_Epilogue, HDAE5000_SfxPmtBitCheck + 180

HDAE5000_SfxSqtBitCheck:	.include "includes/generated/cc900/HDAE5000_SfxSqtBitCheck.s"	; C: cc900/hdae5000_sfx_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SfxSqtBitCheck_Ev01E00047, HDAE5000_SfxSqtBitCheck + 58
	.set	HDAE5000_SfxSqtBitCheck_Ev01E0003E, HDAE5000_SfxSqtBitCheck + 95
	.set	HDAE5000_SfxSqtBitCheck_Ev01E0003F, HDAE5000_SfxSqtBitCheck + 99
	.set	HDAE5000_SfxSqtBitCheck_Ev01E00043, HDAE5000_SfxSqtBitCheck + 103
	.set	HDAE5000_SfxSqtBitCheck_Ev01E00043_Join, HDAE5000_SfxSqtBitCheck + 115
	.set	HDAE5000_SfxSqtBitCheck_Ev01E00044, HDAE5000_SfxSqtBitCheck + 117
	.set	HDAE5000_SfxSqtBitCheck_Ev01E00044_Join, HDAE5000_SfxSqtBitCheck + 129
	.set	HDAE5000_SfxSqtBitCheck_Ev01E00045, HDAE5000_SfxSqtBitCheck + 131
	.set	HDAE5000_SfxSqtBitCheck_Ev01E00046, HDAE5000_SfxSqtBitCheck + 138
	.set	HDAE5000_SfxSqtBitCheck_OnRamDataReq, HDAE5000_SfxSqtBitCheck + 142
	.set	HDAE5000_SfxSqtBitCheck_Default, HDAE5000_SfxSqtBitCheck + 178
	.set	HDAE5000_SfxSqtBitCheck_Epilogue, HDAE5000_SfxSqtBitCheck + 180

HDAE5000_SfxCmpBitCheck:	.include "includes/generated/cc900/HDAE5000_SfxCmpBitCheck.s"	; C: cc900/hdae5000_sfx_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SfxCmpBitCheck_Ev01E00047, HDAE5000_SfxCmpBitCheck + 58
	.set	HDAE5000_SfxCmpBitCheck_Ev01E0003E, HDAE5000_SfxCmpBitCheck + 95
	.set	HDAE5000_SfxCmpBitCheck_Ev01E0003F, HDAE5000_SfxCmpBitCheck + 99
	.set	HDAE5000_SfxCmpBitCheck_Ev01E00043, HDAE5000_SfxCmpBitCheck + 103
	.set	HDAE5000_SfxCmpBitCheck_Ev01E00043_Join, HDAE5000_SfxCmpBitCheck + 115
	.set	HDAE5000_SfxCmpBitCheck_Ev01E00044, HDAE5000_SfxCmpBitCheck + 117
	.set	HDAE5000_SfxCmpBitCheck_Ev01E00044_Join, HDAE5000_SfxCmpBitCheck + 129
	.set	HDAE5000_SfxCmpBitCheck_Ev01E00045, HDAE5000_SfxCmpBitCheck + 131
	.set	HDAE5000_SfxCmpBitCheck_Ev01E00046, HDAE5000_SfxCmpBitCheck + 138
	.set	HDAE5000_SfxCmpBitCheck_OnRamDataReq, HDAE5000_SfxCmpBitCheck + 142
	.set	HDAE5000_SfxCmpBitCheck_Default, HDAE5000_SfxCmpBitCheck + 178
	.set	HDAE5000_SfxCmpBitCheck_Epilogue, HDAE5000_SfxCmpBitCheck + 180

HDAE5000_SfxTmBitCheck:	.include "includes/generated/cc900/HDAE5000_SfxTmBitCheck.s"	; C: cc900/hdae5000_sfx_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SfxTmBitCheck_Ev01E00047, HDAE5000_SfxTmBitCheck + 58
	.set	HDAE5000_SfxTmBitCheck_Ev01E0003E, HDAE5000_SfxTmBitCheck + 95
	.set	HDAE5000_SfxTmBitCheck_Ev01E0003F, HDAE5000_SfxTmBitCheck + 99
	.set	HDAE5000_SfxTmBitCheck_Ev01E00043, HDAE5000_SfxTmBitCheck + 103
	.set	HDAE5000_SfxTmBitCheck_Ev01E00043_Join, HDAE5000_SfxTmBitCheck + 115
	.set	HDAE5000_SfxTmBitCheck_Ev01E00044, HDAE5000_SfxTmBitCheck + 117
	.set	HDAE5000_SfxTmBitCheck_Ev01E00044_Join, HDAE5000_SfxTmBitCheck + 129
	.set	HDAE5000_SfxTmBitCheck_Ev01E00045, HDAE5000_SfxTmBitCheck + 131
	.set	HDAE5000_SfxTmBitCheck_Ev01E00046, HDAE5000_SfxTmBitCheck + 138
	.set	HDAE5000_SfxTmBitCheck_OnRamDataReq, HDAE5000_SfxTmBitCheck + 142
	.set	HDAE5000_SfxTmBitCheck_Default, HDAE5000_SfxTmBitCheck + 178
	.set	HDAE5000_SfxTmBitCheck_Epilogue, HDAE5000_SfxTmBitCheck + 180

HDAE5000_SfxMspBitCheck:	.include "includes/generated/cc900/HDAE5000_SfxMspBitCheck.s"	; C: cc900/hdae5000_sfx_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SfxMspBitCheck_Ev01E00047, HDAE5000_SfxMspBitCheck + 58
	.set	HDAE5000_SfxMspBitCheck_Ev01E0003E, HDAE5000_SfxMspBitCheck + 95
	.set	HDAE5000_SfxMspBitCheck_Ev01E0003F, HDAE5000_SfxMspBitCheck + 99
	.set	HDAE5000_SfxMspBitCheck_Ev01E00043, HDAE5000_SfxMspBitCheck + 103
	.set	HDAE5000_SfxMspBitCheck_Ev01E00043_Join, HDAE5000_SfxMspBitCheck + 115
	.set	HDAE5000_SfxMspBitCheck_Ev01E00044, HDAE5000_SfxMspBitCheck + 117
	.set	HDAE5000_SfxMspBitCheck_Ev01E00044_Join, HDAE5000_SfxMspBitCheck + 129
	.set	HDAE5000_SfxMspBitCheck_Ev01E00045, HDAE5000_SfxMspBitCheck + 131
	.set	HDAE5000_SfxMspBitCheck_Ev01E00046, HDAE5000_SfxMspBitCheck + 138
	.set	HDAE5000_SfxMspBitCheck_OnRamDataReq, HDAE5000_SfxMspBitCheck + 142
	.set	HDAE5000_SfxMspBitCheck_Default, HDAE5000_SfxMspBitCheck + 178
	.set	HDAE5000_SfxMspBitCheck_Epilogue, HDAE5000_SfxMspBitCheck + 180

HDAE5000_SfxRcmBitCheck:	.include "includes/generated/cc900/HDAE5000_SfxRcmBitCheck.s"	; C: cc900/hdae5000_sfx_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SfxRcmBitCheck_Ev01E00047, HDAE5000_SfxRcmBitCheck + 58
	.set	HDAE5000_SfxRcmBitCheck_Ev01E0003E, HDAE5000_SfxRcmBitCheck + 95
	.set	HDAE5000_SfxRcmBitCheck_Ev01E0003F, HDAE5000_SfxRcmBitCheck + 99
	.set	HDAE5000_SfxRcmBitCheck_Ev01E00043, HDAE5000_SfxRcmBitCheck + 103
	.set	HDAE5000_SfxRcmBitCheck_Ev01E00043_Join, HDAE5000_SfxRcmBitCheck + 115
	.set	HDAE5000_SfxRcmBitCheck_Ev01E00044, HDAE5000_SfxRcmBitCheck + 117
	.set	HDAE5000_SfxRcmBitCheck_Ev01E00044_Join, HDAE5000_SfxRcmBitCheck + 129
	.set	HDAE5000_SfxRcmBitCheck_Ev01E00045, HDAE5000_SfxRcmBitCheck + 131
	.set	HDAE5000_SfxRcmBitCheck_Ev01E00046, HDAE5000_SfxRcmBitCheck + 138
	.set	HDAE5000_SfxRcmBitCheck_OnRamDataReq, HDAE5000_SfxRcmBitCheck + 142
	.set	HDAE5000_SfxRcmBitCheck_Default, HDAE5000_SfxRcmBitCheck + 178
	.set	HDAE5000_SfxRcmBitCheck_Epilogue, HDAE5000_SfxRcmBitCheck + 180

HDAE5000_SfxMdBitCheck:	.include "includes/generated/cc900/HDAE5000_SfxMdBitCheck.s"	; C: cc900/hdae5000_sfx_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SfxMdBitCheck_Ev01E00047, HDAE5000_SfxMdBitCheck + 58
	.set	HDAE5000_SfxMdBitCheck_Ev01E0003E, HDAE5000_SfxMdBitCheck + 95
	.set	HDAE5000_SfxMdBitCheck_Ev01E0003F, HDAE5000_SfxMdBitCheck + 99
	.set	HDAE5000_SfxMdBitCheck_Ev01E00043, HDAE5000_SfxMdBitCheck + 103
	.set	HDAE5000_SfxMdBitCheck_Ev01E00043_Join, HDAE5000_SfxMdBitCheck + 115
	.set	HDAE5000_SfxMdBitCheck_Ev01E00044, HDAE5000_SfxMdBitCheck + 117
	.set	HDAE5000_SfxMdBitCheck_Ev01E00044_Join, HDAE5000_SfxMdBitCheck + 129
	.set	HDAE5000_SfxMdBitCheck_Ev01E00045, HDAE5000_SfxMdBitCheck + 131
	.set	HDAE5000_SfxMdBitCheck_Ev01E00046, HDAE5000_SfxMdBitCheck + 138
	.set	HDAE5000_SfxMdBitCheck_OnRamDataReq, HDAE5000_SfxMdBitCheck + 142
	.set	HDAE5000_SfxMdBitCheck_Default, HDAE5000_SfxMdBitCheck + 178
	.set	HDAE5000_SfxMdBitCheck_Epilogue, HDAE5000_SfxMdBitCheck + 180


HDAE5000_WriteProtectEditCheck:	.include "includes/generated/cc900/HDAE5000_WriteProtectEditCheck.s"	; C: cc900/hdae5000_edit_checks.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_WriteProtectEditCheck_Ev01E00047, HDAE5000_WriteProtectEditCheck + 55
	.set	HDAE5000_WriteProtectEditCheck_Ev01E0003E, HDAE5000_WriteProtectEditCheck + 92
	.set	HDAE5000_WriteProtectEditCheck_Ev01E00043, HDAE5000_WriteProtectEditCheck + 96
	.set	HDAE5000_WriteProtectEditCheck_Ev01E00044, HDAE5000_WriteProtectEditCheck + 100
	.set	HDAE5000_WriteProtectEditCheck_Ev01E00045, HDAE5000_WriteProtectEditCheck + 104
	.set	HDAE5000_WriteProtectEditCheck_Ev01E00046, HDAE5000_WriteProtectEditCheck + 111
	.set	HDAE5000_WriteProtectEditCheck_OnRamDataReq, HDAE5000_WriteProtectEditCheck + 115
	.set	HDAE5000_WriteProtectEditCheck_Default, HDAE5000_WriteProtectEditCheck + 129
	.set	HDAE5000_WriteProtectEditCheck_Epilogue, HDAE5000_WriteProtectEditCheck + 131


; v1.x has none of the lyric settings (LyricJumpEditCheck; v2.06i's LyricForeColorCheck /
; LyricBackColorCheck): WriteConfirmEditCheck follows WriteProtectEditCheck.
HDAE5000_WriteConfirmEditCheck:	.include "includes/generated/cc900/HDAE5000_WriteConfirmEditCheck.s"	; C: cc900/hdae5000_edit_checks.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_WriteConfirmEditCheck_Ev01E00047, HDAE5000_WriteConfirmEditCheck + 55
	.set	HDAE5000_WriteConfirmEditCheck_Ev01E0003E, HDAE5000_WriteConfirmEditCheck + 92
	.set	HDAE5000_WriteConfirmEditCheck_Ev01E00043, HDAE5000_WriteConfirmEditCheck + 96
	.set	HDAE5000_WriteConfirmEditCheck_Ev01E00044, HDAE5000_WriteConfirmEditCheck + 100
	.set	HDAE5000_WriteConfirmEditCheck_Ev01E00045, HDAE5000_WriteConfirmEditCheck + 104
	.set	HDAE5000_WriteConfirmEditCheck_Ev01E00046, HDAE5000_WriteConfirmEditCheck + 111
	.set	HDAE5000_WriteConfirmEditCheck_OnRamDataReq, HDAE5000_WriteConfirmEditCheck + 115
	.set	HDAE5000_WriteConfirmEditCheck_Default, HDAE5000_WriteConfirmEditCheck + 119
	.set	HDAE5000_WriteConfirmEditCheck_Epilogue, HDAE5000_WriteConfirmEditCheck + 121

HDAE5000_QuickLoadModeEditCheck:	.include "includes/generated/cc900/HDAE5000_QuickLoadModeEditCheck.s"	; C: cc900/hdae5000_edit_checks.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_QuickLoadModeEditCheck_Ev01E00047, HDAE5000_QuickLoadModeEditCheck + 55
	.set	HDAE5000_QuickLoadModeEditCheck_Ev01E0003E, HDAE5000_QuickLoadModeEditCheck + 80
	.set	HDAE5000_QuickLoadModeEditCheck_Ev01E00043, HDAE5000_QuickLoadModeEditCheck + 84
	.set	HDAE5000_QuickLoadModeEditCheck_Ev01E00044, HDAE5000_QuickLoadModeEditCheck + 88
	.set	HDAE5000_QuickLoadModeEditCheck_Ev01E00045, HDAE5000_QuickLoadModeEditCheck + 92
	.set	HDAE5000_QuickLoadModeEditCheck_Ev01E00046, HDAE5000_QuickLoadModeEditCheck + 99
	.set	HDAE5000_QuickLoadModeEditCheck_OnRamDataReq, HDAE5000_QuickLoadModeEditCheck + 103
	.set	HDAE5000_QuickLoadModeEditCheck_Default, HDAE5000_QuickLoadModeEditCheck + 107
	.set	HDAE5000_QuickLoadModeEditCheck_Epilogue, HDAE5000_QuickLoadModeEditCheck + 109

HDAE5000_LoadByNumberModeEditCheck:	.include "includes/generated/cc900/HDAE5000_LoadByNumberModeEditCheck.s"	; C: cc900/hdae5000_edit_checks.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LoadByNumberModeEditCheck_Ev01E00047, HDAE5000_LoadByNumberModeEditCheck + 55
	.set	HDAE5000_LoadByNumberModeEditCheck_Ev01E0003E, HDAE5000_LoadByNumberModeEditCheck + 80
	.set	HDAE5000_LoadByNumberModeEditCheck_Ev01E00043, HDAE5000_LoadByNumberModeEditCheck + 84
	.set	HDAE5000_LoadByNumberModeEditCheck_Ev01E00044, HDAE5000_LoadByNumberModeEditCheck + 88
	.set	HDAE5000_LoadByNumberModeEditCheck_Ev01E00045, HDAE5000_LoadByNumberModeEditCheck + 92
	.set	HDAE5000_LoadByNumberModeEditCheck_Ev01E00046, HDAE5000_LoadByNumberModeEditCheck + 99
	.set	HDAE5000_LoadByNumberModeEditCheck_OnRamDataReq, HDAE5000_LoadByNumberModeEditCheck + 103
	.set	HDAE5000_LoadByNumberModeEditCheck_Default, HDAE5000_LoadByNumberModeEditCheck + 107
	.set	HDAE5000_LoadByNumberModeEditCheck_Epilogue, HDAE5000_LoadByNumberModeEditCheck + 109

HDAE5000_JumpAfterLoadModeEditCheck:	.include "includes/generated/cc900/HDAE5000_JumpAfterLoadModeEditCheck.s"	; C: cc900/hdae5000_edit_checks.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047, HDAE5000_JumpAfterLoadModeEditCheck + 55
	.set	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E0003E, HDAE5000_JumpAfterLoadModeEditCheck + 80
	.set	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00043, HDAE5000_JumpAfterLoadModeEditCheck + 84
	.set	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00044, HDAE5000_JumpAfterLoadModeEditCheck + 88
	.set	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00045, HDAE5000_JumpAfterLoadModeEditCheck + 92
	.set	HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00046, HDAE5000_JumpAfterLoadModeEditCheck + 99
	.set	HDAE5000_JumpAfterLoadModeEditCheck_OnRamDataReq, HDAE5000_JumpAfterLoadModeEditCheck + 103
	.set	HDAE5000_JumpAfterLoadModeEditCheck_Default, HDAE5000_JumpAfterLoadModeEditCheck + 107
	.set	HDAE5000_JumpAfterLoadModeEditCheck_Epilogue, HDAE5000_JumpAfterLoadModeEditCheck + 109


; ---------------------------------------------------------------------------
; Build the drive-information page of SetupP2 from its template ("HD-TYPE",
; "TRACKS", "HEADS", "SECTORS PER TRACK", "TOTAL HD (MB)", "USED BY SYSTEM
; (MB)", "FREE FOR USE (MB)", "SOFTWARE RELEASE"), filled from
; HDAE5000_HD_GetGeometry, HDAE5000_HD_GetDiskUsage (megabytes through the
; soft-float routines) and HDAE5000_CopyVersionString; shown with
; RootFn_ApPostEvent.
; ---------------------------------------------------------------------------
HDAE5000_SetupPage_BuildDriveInfo:	.include "includes/generated/cc900/HDAE5000_SetupPage_BuildDriveInfo.s"	; C: cc900/hdae5000_setup_hd_driver.c
	;
	; Part 2: Event handler (0x286502)
HDAE5000_SetupP2SwCatch:	.include "includes/generated/cc900/HDAE5000_SetupP2SwCatch.s"	; C: cc900/hdae5000_setup_copy_hd_driver.c

; ---------------------------------------------------------------------------
; Collect the digits typed on the HD-format attention dialog in
; HDAE5000_RAM_FormatCodeDigits; after six, "050354" gives IZ = 2, "965768"
; gives 3, anything else 1 (HDAE5000_StrPrefixCmp).  What 2 and 3 unlock is
; decided by the caller, HDAE5000_AttenHDFormatSwCatch.
; ---------------------------------------------------------------------------
HDAE5000_FormatDialog_CodeDigit:
	dec 8, xsp			; alloc 4 bytes
	pushw iz                                ; push iz (compact)
	pushw 0x000a
	lda xbc, (xsp + 0x04)
	push xbc
	pushw wa                                ; push wa (compact)
	call HDAE5000_IToA
	inc 8, xsp			; dealloc 4 bytes
	ld a, (0x22ad54:24); A = current count
	extz wa
	ld bc, wa
	inc 2, bc			; BC = count + 2
	lda xde, (0x22ad54:24); XDE = buffer base
	ld a, (xsp + 0x02)		; A = digit param
	ld	(xde+bc), a
	inc	1, (0x22ad54:24)
	cp (0x22ad54:24), 0x06; count == 6?
	jr nz, .LCHSC__not_full
	; 6 digits entered — match against patterns
	pushw	HDAE5000_Str_HdFormatCode@hi16
	pushw	HDAE5000_Str_HdFormatCode@lo16		; low half of HDAE5000_Str_HdFormatCode
	lda xwa, (HDAE5000_RAM_FormatCodeDigits:24)
	push xwa
	call HDAE5000_StrPrefixCmp			; string compare
	inc 8, xsp
	cp hl, 0:i3
	jr nz, .LCHSC__try2
	ld iz, 2:i3			; match pattern 1 → IZ=2
	jr t, .LCHSC__clear
.LCHSC__try2:
	pushw	HDAE5000_Str_Track0RecoverCode@hi16
	pushw	HDAE5000_Str_Track0RecoverCode@lo16		; low half of HDAE5000_Str_Track0RecoverCode
	lda xwa, (HDAE5000_RAM_FormatCodeDigits:24)
	push xwa
	call HDAE5000_StrPrefixCmp			; string compare
	inc 8, xsp
	cp hl, 0:i3
	jr nz, .LCHSC__no_match
	ld iz, 3:i3			; match pattern 2 → IZ=3
	jr t, .LCHSC__clear
.LCHSC__no_match:
	ld iz, 1:i3			; no match → IZ=1
.LCHSC__clear:
	pushw 0x000a
	pushw 0x0000
	lda xwa, (0x22ad54:24)
	push xwa
	call HDAE5000_MemFill			; MemFill (clear buffer)
	inc 8, xsp
	jr t, .LCHSC__return
.LCHSC__not_full:
	ld iz, 0:i3			; not full → IZ=0
.LCHSC__return:
	ld hl, iz			; return value in HL
	popw iz                                 ; pop iz (compact)
	inc 8, xsp			; dealloc 4 bytes
	ret
	;
	; Part 2: Event handler (0x286666)
HDAE5000_AttenHDFormatSwCatch:	.include "includes/generated/cc900/HDAE5000_AttenHDFormatSwCatch.s"	; C: cc900/hdae5000_drv_screens6.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1, HDAE5000_AttenHDFormatSwCatch + 199
	.set	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit2Or3, HDAE5000_AttenHDFormatSwCatch + 218
	.set	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit4Or5, HDAE5000_AttenHDFormatSwCatch + 237
	.set	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit6Or7, HDAE5000_AttenHDFormatSwCatch + 256
	.set	HDAE5000_AttenHDFormatSwCatch_OnCodeDigit8Or9, HDAE5000_AttenHDFormatSwCatch + 275
	.set	HDAE5000_AttenHDFormatSwCatch_OnCancel, HDAE5000_AttenHDFormatSwCatch + 296

; ---------------------------------------------------------------------------
; Load-by-number: step the digit at HDAE5000_RAM_LbnDigitPos of the number
; being entered (hundreds / tens / units of the directory, clamped to
; 0..120, then the song) by the stacked key value, refresh the part list
; (HDAE5000_TypeSel_Init, HDAE5000_PartList_Build) and redraw
; (HDAE5000_Lbn_ShowEntry).
; In:  XWA = the asking object, (xsp+4) = key value
; ---------------------------------------------------------------------------
HDAE5000_Lbn_StepDigit:	.include "includes/generated/cc900/HDAE5000_Lbn_StepDigit.s"	; C: cc900/hdae5000_lbn_page.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_Lbn_StepDigit_NoDigitTyped, HDAE5000_Lbn_StepDigit + 38
	.set	HDAE5000_Lbn_StepDigit_DirHundreds, HDAE5000_Lbn_StepDigit + 41
	.set	HDAE5000_Lbn_StepDigit_DirTens, HDAE5000_Lbn_StepDigit + 68
	.set	HDAE5000_Lbn_StepDigit_DirUnits, HDAE5000_Lbn_StepDigit + 95
	.set	HDAE5000_Lbn_StepDigit_SongTens, HDAE5000_Lbn_StepDigit + 116
	.set	HDAE5000_Lbn_StepDigit_SongUnits, HDAE5000_Lbn_StepDigit + 143
	;
	; Part 2: Event handler A (0x286B72)
HDAE5000_LBNPage1SwCatch:	.include "includes/generated/cc900/HDAE5000_LBNPage1SwCatch.s"	; C: cc900/hdae5000_lbn_page.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNPage1SwCatch_OnClear, HDAE5000_LBNPage1SwCatch + 168
	.set	HDAE5000_LBNPage1SwCatch_OnStepDigit, HDAE5000_LBNPage1SwCatch + 183
	.set	HDAE5000_LBNPage1SwCatch_OnDigit0Or1, HDAE5000_LBNPage1SwCatch + 220
	.set	HDAE5000_LBNPage1SwCatch_OnDigit2Or3, HDAE5000_LBNPage1SwCatch + 246
	.set	HDAE5000_LBNPage1SwCatch_OnDigit4Or5, HDAE5000_LBNPage1SwCatch + 272
	.set	HDAE5000_LBNPage1SwCatch_OnDigit6Or7, HDAE5000_LBNPage1SwCatch + 298
	.set	HDAE5000_LBNPage1SwCatch_OnDigit8Or9, HDAE5000_LBNPage1SwCatch + 324
	;
	; Part 3: Event handler B (0x286CED)
HDAE5000_LBNLoadSwCatch:
	; registered as "LBNLoadSwCatch" in HDAE5000_ObjHandler_Table
	dec 8, xsp
	push xiz
	ld (xsp + 0x04), xde
	ld xiz, xbc			; save event code in XIZ
	ld (xsp + 0x08), xwa
	ld xwa, xiz			; XWA = event code
	cp xwa, EVT_SW_IN
	jrl	z, .LHD_SR__b_evt07
	cp xwa, EVT_DRAW
	jr z, .LHD_SR__b_evt0d
	cp xwa, EVT_ARE_YOU_CLASS_PROC
	jr z, .LHD_SR__b_evt85
	cp xwa, EVT_SHOW
	jrl	nz, .LHD_SR__b_exit
	; Event 0x01: table lookup and copy
	ld wa, (HDAE5000_RAM_CurDir:24)
	ld bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_PartMask
	ld wa, hl
	cp wa, 0xffff
	jr z, .LHD_SR__b_nomatch
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	ld bc, hl
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	calr HDAE5000_TypeSel_Init
	jrl	t, .LHD_SR__b_exit
.LHD_SR__b_nomatch:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	ld bc, 0:i3
	calr HDAE5000_TypeSel_Init
	jrl	t, .LHD_SR__b_exit
.LHD_SR__b_evt85:			; event 0x85: XHL = 1
	ld xhl, 1:i3
	jrl	t, .LHD_SR__b_epilogue
.LHD_SR__b_evt0d:			; event 0x0D: display update
	ld xwa, (xsp + 0x08)
	ld xbc, xiz
	ld xde, (xsp + 0x04)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)
	ld_sril xhl, (xhl + RootFn_InheritedProc)
	call (xhl)
	lda xwa, (HDAE5000_Str_LBN:24)
	ld xbc, xwa
	ld xwa, (xsp + 0x08)
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	ld xhl, 0:i3
	jr	t, .LHD_SR__b_epilogue
.LHD_SR__b_evt07:			; event 0x07: sector operations
	ld xde, (xsp + 0x04)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xix, (xwa + RootFn_SendEvent)
	ld xwa, 0x02600024
	ld xbc, EVT_MAKE_EDIT_SW_ID
	call (xix)
	cp xhl, 0x00000009
	jr z, .LHD_SR__b_check_state
	cp xhl, 0x00000008
	jr nz, .LHD_SR__b_exit
.LHD_SR__b_check_state:
	cpw (HDAE5000_RAM_LbnDigitPos:24), 0x0005; state == 5?
	jr nz, .LHD_SR__b_exit
	; State 5: display manager call + sector read
	pushw 0x0001
	ld xwa, HDAE5000_OBJ_LOAD_BY_NUM
	push xwa
	ld wa, (HDAE5000_RAM_CurDir:24)
	ld bc, (HDAE5000_RAM_CurSong:24)
	ld de, (HDAE5000_RAM_SaveOptions:24)
	calr HDAE5000_LoadSongWithUi
	pushw 0x0001
	ld wa, 0:i3
	ld bc, 0:i3
	ld de, 6:i3
	calr HDAE5000_Lbn_ShowEntry
.LHD_SR__b_exit:			; common exit
	ld xwa, (xsp + 0x08)
	ld xbc, xiz
	ld xde, (xsp + 0x04)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)
	ld_sril xix, (xhl + RootFn_InheritedProc)
	call (xix)
.LHD_SR__b_epilogue:
	pop xiz
	inc 8, xsp
	ret

; ---------------------------------------------------------------------------
; Load-by-number: type digit BC at position HDAE5000_RAM_LbnDigitPos --
; hundreds, tens and units of the directory number HDAE5000_RAM_LbnDir, tens
; and units of the song number HDAE5000_RAM_LbnSong -- redraw
; (HDAE5000_Lbn_ShowEntry) and after the last digit load the song
; (HDAE5000_LoadSongWithUi).
; In:  BC = digit
; ---------------------------------------------------------------------------
HDAE5000_Lbn_TypeDigit:
	push xiz				; 3e
	ld	qiz, 0

	; --- Switch on state variable at 0x22AA5C ---
	ld wa, (HDAE5000_RAM_LbnDigitPos:24)
	cp wa, 4:i3				; d8 dc
	jrl z, .Lsw_case4			; 76 xx xx
	cp wa, 3:i3				; d8 db
	jrl z, .Lsw_case3			; 76 xx xx
	cp wa, 2:i3				; d8 da
	jr z, .Lsw_case2			; 66 xx
	cp wa, 1:i3				; d8 d9
	jr z, .Lsw_case1			; 66 xx
	cp wa, 0:i3				; d8 d8
	jrl nz, .Lsw_exit			; 7e xx xx

	; === Case 0: initialize cylinder from BC*100, set state=1 ===
	ld wa, bc				; d9 88
	mul wa, 0x0064				; d8 08 64 00
	ld (HDAE5000_RAM_LbnDir:24), wa
	ldw (HDAE5000_RAM_LbnSong:24), 0x0000; f2 18 aa 22 02 00 00
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0001; f2 14 aa 22 02 01 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 16 aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 18 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 14 aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl
	jrl t, .Lsw_exit			; 78 xx xx

	; === Case 1: add BC*10 to cylinder, set state=2 ===
.Lsw_case1:
	ld wa, bc				; d9 88
	mul wa, 0x000a				; d8 08 0a 00
	add (HDAE5000_RAM_LbnDir:24), wa; d2 16 aa 22 88
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0002; f2 14 aa 22 02 02 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 16 aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 18 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 14 aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl
	jrl t, .Lsw_exit			; 78 xx xx

	; === Case 2: add BC to cylinder, set state=3 ===
.Lsw_case2:
	add (HDAE5000_RAM_LbnDir:24), bc; d2 16 aa 22 89
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0003; f2 14 aa 22 02 03 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 16 aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 18 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 14 aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl
	jrl t, .Lsw_exit			; 78 xx xx

	; === Case 3: set head from BC*10, set state=4 ===
.Lsw_case3:
	ld wa, bc				; d9 88
	mul wa, 0x000a				; d8 08 0a 00
	ld (HDAE5000_RAM_LbnSong:24), wa; f2 18 aa 22 50
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0004; f2 14 aa 22 02 04 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 16 aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 18 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 14 aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl
	jrl t, .Lsw_exit			; 78 xx xx

	; === Case 4: add BC to head, set state=5, then process ===
.Lsw_case4:
	add (HDAE5000_RAM_LbnSong:24), bc; d2 18 aa 22 89
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0005; f2 14 aa 22 02 05 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 16 aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 18 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 14 aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl

	; --- After all cases: check result ---
	ld	wa, qiz
	cp wa, 0:i3				; d8 d8
	jrl nz, .Lsw_exit			; 7e xx xx — error → exit

	; --- Compute sector address and look up in table ---
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 5e aa 22 20 — directory number
	dec 1, wa				; d8 69
	ld (HDAE5000_RAM_CurDir:24), wa; f2 ca d2 23 50
	ld wa, (HDAE5000_RAM_LbnSong:24); d2 60 aa 22 20 — song number
	dec 1, wa				; d8 69
	ld (HDAE5000_RAM_CurSong:24), wa; f2 cc d2 23 50
	ld wa, (HDAE5000_RAM_CurDir:24); d2 ca d2 23 20
	ld bc, (HDAE5000_RAM_CurSong:24); d2 cc d2 23 21
	call HDAE5000_Song_PartMask		; 1d 56 cd 28
	ld iz, hl				; db 8e
	ld wa, iz				; de 88
	cp wa, 0xffff				; d8 cf ff ff
	jr z, .Lsw_lookup_notfound		; 66 xx

	; --- Found: copy data and seek ---
.Lsw_lookup_found:
	lda xwa, (HDAE5000_RAM_SaveOptions:24); f2 04 aa 22 30
	ld bc, iz				; de 89
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24); f2 c0 a2 2c 32
	calr HDAE5000_TypeSel_Init		; 1e xx xx
	ld bc, (HDAE5000_RAM_CurDir:24); d2 ca d2 23 21
	ld de, (HDAE5000_RAM_CurSong:24); d2 cc d2 23 22
	ld wa, iz				; de 88
	pushw wa                                ; push wa (compact 16-bit)
	ld xwa, HDAE5000_OBJ_LBN_OPTION			; 40 94 00 7f 00
	calr HDAE5000_PartList_Build			; 1e xx xx
	jr t, .Lsw_after_lookup			; 68 xx

	; --- Not found: copy default data and seek with -1 ---
.Lsw_lookup_notfound:
	lda xwa, (HDAE5000_RAM_SaveOptions:24); f2 04 aa 22 30
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24); f2 c0 a2 2c 32
	ld bc, 0:i3				; d9 a8
	calr HDAE5000_TypeSel_Init		; 1e xx xx
	pushw 0xffff
	ld xwa, HDAE5000_OBJ_LBN_OPTION			; 40 94 00 7f 00
	ldw bc, 0xffff				; 31 ff ff
	ldw de, 0xffff				; 32 ff ff
	calr HDAE5000_PartList_Build			; 1e xx xx

	; --- After table lookup: check sectors per track ---
.Lsw_after_lookup:
	cp (HDAE5000_RAM_LoadByNumberMode:24), 0x02; c2 aa 9d 22 3f 02
	jr nz, .Lsw_exit			; 6e xx
	; Sectors per track == 2: do display and FS operations
	pushw 0x0001
	ld xwa, HDAE5000_OBJ_LOAD_BY_NUM			; 40 8b 00 7f 00
	push xwa				; 38
	ld wa, (HDAE5000_RAM_CurDir:24); d2 ca d2 23 20
	ld bc, (HDAE5000_RAM_CurSong:24); d2 cc d2 23 21
	ld de, (HDAE5000_RAM_SaveOptions:24); d2 04 aa 22 22
	calr HDAE5000_LoadSongWithUi		; 1e xx xx
	pushw 0x0001
	ld wa, 0:i3				; d8 a8
	ld bc, 0:i3				; d9 a8
	ld de, 6:i3				; da ae
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	; Check second disk flag

	; === Exit: check QIZ result ===
.Lsw_exit:
	ld	wa, qiz
	cp wa, 0xfffe				; d8 cf fe ff
	jr z, .Lsw_err_fffe			; 66 xx
	cp wa, 0xffff				; d8 cf ff ff
	jrl nz, .Lsw_done			; 7e xx xx

	; --- Error 0xFFFF: register error + timer ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_PostEvent)             ; e3 e1 04 01 23 — ld xhl, (xwa+0x0104)
	ld xwa, HDAE5000_OBJ_DIR_OUT_RANGE			; 40 a8 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 5:i3				; ea ad
	call (xhl)				; b3 e8
	ld xwa, EVT_HDAE_TIMER_BACK			; 40 02 00 ca 01
	push xwa				; 38
	ld xwa, HDAE5000_OBJ_LOAD_BY_NUM			; 40 8b 00 7f 00
	push xwa				; 38
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_SetApTimer)             ; e3 e1 10 04 23 — ld xhl, (xwa+0x0410)
	ld xwa, 0x00000021			; 40 21 00 00 00
	ld xbc, HDAE5000_OBJ_DIR_OUT_RANGE_CATCH			; 41 a9 02 7f 00
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8
	jr t, .Lsw_done				; 68 xx

	; --- Error 0xFFFE: register different error + timer ---
.Lsw_err_fffe:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_PostEvent)             ; e3 e1 04 01 23 — ld xhl, (xwa+0x0104)
	ld xwa, HDAE5000_OBJ_FILE_OUT_RANGE			; 40 ad 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 5:i3				; ea ad
	call (xhl)				; b3 e8
	ld xwa, EVT_HDAE_TIMER_BACK			; 40 02 00 ca 01
	push xwa				; 38
	ld xwa, HDAE5000_OBJ_LOAD_BY_NUM			; 40 8b 00 7f 00
	push xwa				; 38
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_SetApTimer)             ; e3 e1 10 04 23 — ld xhl, (xwa+0x0410)
	ld xwa, 0x00000021			; 40 21 00 00 00
	ld xbc, HDAE5000_OBJ_FILE_OUT_RANGE_CATCH			; 41 ae 02 7f 00
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8

	; --- Epilogue ---
.Lsw_done:
	pop xiz					; 5e
	ret					; 0e

; --- Filesystem Operations ---
