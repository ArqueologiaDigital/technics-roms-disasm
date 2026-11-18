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
; the nine 14-byte names of HDAE5000_PartNames_Text ("CURRENT PANEL" ...
; "LYRICS", parts LSW..TLX), each part whose bit is clear in the mask is
; overwritten with HDAE5000_PartName_Blank, and the whole text is blank when
; BC or DE is 0xFFFF or the mask is 0xFFFF.  Then RootFn_ApPostEvent posts
; EVT_HDAE_SET_STR_ADR (XDE = the text) and EVT_PARA_DRAW to the object.
; In:  XWA = list object, BC = directory, DE = song (only tested for 0xFFFF),
;      (xsp+4) = part mask word (bit k = part k present); retd pops it
; RAM: HDAE5000_RAM_PartListText, HDAE5000_RAM_MainWorkspacePtr
; ---------------------------------------------------------------------------
HDAE5000_PartList_Build:	.include "includes/generated/cc900/HDAE5000_PartList_Build.s"	; C: cc900/hdae5000_partlist.c

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

HDAE5000_FILE_LOAD_Screen:	.include "includes/generated/cc900/HDAE5000_FILE_LOAD_Screen.s"	; C: cc900/hdae5000_file_load_screen.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FILE_LOAD_Screen_Ev01C00001, HDAE5000_FILE_LOAD_Screen + 66
	.set	HDAE5000_FILE_LOAD_Screen_Ev01EA0008, HDAE5000_FILE_LOAD_Screen + 98
	.set	HDAE5000_FILE_LOAD_Screen_Ev01EA000D, HDAE5000_FILE_LOAD_Screen + 197
	.set	HDAE5000_FILE_LOAD_Screen_Ev01EA000C, HDAE5000_FILE_LOAD_Screen + 249
	.set	HDAE5000_FILE_LOAD_Screen_Ev01EA0001, HDAE5000_FILE_LOAD_Screen + 281
	.set	HDAE5000_FILE_LOAD_Screen_Ev01EA0000, HDAE5000_FILE_LOAD_Screen + 343
	.set	HDAE5000_FILE_LOAD_Screen_Ev01EA0002, HDAE5000_FILE_LOAD_Screen + 403
	.set	HDAE5000_FILE_LOAD_Screen_Ev01EA0002_Skip, HDAE5000_FILE_LOAD_Screen + 450
	.set	HDAE5000_FILE_LOAD_Screen_Ev01EA0002_Join, HDAE5000_FILE_LOAD_Screen + 468
	.set	HDAE5000_FILE_LOAD_Screen_Default, HDAE5000_FILE_LOAD_Screen + 475

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

HDAE5000_FileLoadSwCatch:	.include "includes/generated/cc900/HDAE5000_FileLoadSwCatch.s"	; C: cc900/hdae5000_drv_screens4_hd_driver.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FileLoadSwCatch_Join, HDAE5000_FileLoadSwCatch + 51
	.set	HDAE5000_FileLoadSwCatch_Done, HDAE5000_FileLoadSwCatch + 130

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

HDAE5000_HDD_UTIL_PAGE:	.include "includes/generated/cc900/HDAE5000_HDD_UTIL_PAGE.s"	; C: cc900/hdae5000_drv_screens.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_HDD_UTIL_PAGE_OnDraw, HDAE5000_HDD_UTIL_PAGE + 44
	.set	HDAE5000_HDD_UTIL_PAGE_OnSwIn, HDAE5000_HDD_UTIL_PAGE + 108
	.set	HDAE5000_HDD_UTIL_PAGE_Join, HDAE5000_HDD_UTIL_PAGE + 1995
	.set	HDAE5000_HDD_UTIL_PAGE_Epilogue, HDAE5000_HDD_UTIL_PAGE + 2020

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
; 0 "---", 1 "NO ", 2 "YES"; parts LSW..TLX.  Records: HDAE5000_RAM_SaveOptions
; and HDAE5000_RAM_DeleteOptions.
; In:  XWA = record, XDE = template, BC = part mask, (xsp+4) = flag value
;      (low byte of the stacked word; retd pops it)
; Out: clobbers XIX, XIY, HL, E.
; ---------------------------------------------------------------------------
HDAE5000_TypeSel_Init:	.include "includes/generated/cc900/HDAE5000_TypeSel_Init.s"	; C: cc900/hdae5000_uistate_hd_driver.c

; ---------------------------------------------------------------------------
; Recompute the mask word of a part-selection record (see
; HDAE5000_TypeSel_Init): bit k set for every part k whose flag byte (+2+k)
; is 2 ("YES").
; In:  XWA = record (HDAE5000_RAM_SaveOptions or _DeleteOptions)
; Out: (XWA+0) = mask.  No register changes.
; ---------------------------------------------------------------------------
HDAE5000_TypeSel_BuildMask:	.include "includes/generated/cc900/HDAE5000_TypeSel_BuildMask.s"	; C: cc900/hdae5000_hd_driver.c
	; Sub-routine 2: Command dispatcher with computed jump table
	; Input: XWA = context pointer (saved as XIZ), XBC = command ID
	; Returns XHL = result

HDAE5000_SaveOptNameCheck:	.include "includes/generated/cc900/HDAE5000_SaveOptNameCheck.s"	; C: cc900/hdae5000_saveopt_name.c

; --- HD Configuration Manager and CHS Geometry ---
HDAE5000_TypeSel_ShowSaveFlags:	.include "includes/generated/cc900/HDAE5000_TypeSel_ShowSaveFlags.s"	; C: cc900/hdae5000_showflags_drv.c

HDAE5000_SaveOptSwEventCatch:	.include "includes/generated/cc900/HDAE5000_SaveOptSwEventCatch.s"	; C: cc900/hdae5000_drv_screens3.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SaveOptSwEventCatch_OnAreYouClassProc, HDAE5000_SaveOptSwEventCatch + 51
	.set	HDAE5000_SaveOptSwEventCatch_OnDraw, HDAE5000_SaveOptSwEventCatch + 56
	.set	HDAE5000_SaveOptSwEventCatch_OnSwIn, HDAE5000_SaveOptSwEventCatch + 113
	.set	HDAE5000_SaveOptSwEventCatch_Skip, HDAE5000_SaveOptSwEventCatch + 278
	.set	HDAE5000_SaveOptSwEventCatch_Join, HDAE5000_SaveOptSwEventCatch + 311
	.set	HDAE5000_SaveOptSwEventCatch_Skip2, HDAE5000_SaveOptSwEventCatch + 320
	.set	HDAE5000_SaveOptSwEventCatch_Skip3, HDAE5000_SaveOptSwEventCatch + 344
	.set	HDAE5000_SaveOptSwEventCatch_Skip4, HDAE5000_SaveOptSwEventCatch + 368
	.set	HDAE5000_SaveOptSwEventCatch_Skip5, HDAE5000_SaveOptSwEventCatch + 391
	.set	HDAE5000_SaveOptSwEventCatch_Skip6, HDAE5000_SaveOptSwEventCatch + 414
	.set	HDAE5000_SaveOptSwEventCatch_Join2, HDAE5000_SaveOptSwEventCatch + 418
	.set	HDAE5000_SaveOptSwEventCatch_Done, HDAE5000_SaveOptSwEventCatch + 437
	.set	HDAE5000_SaveOptSwEventCatch_Epilogue, HDAE5000_SaveOptSwEventCatch + 439

HDAE5000_FileOptNameCheck:	.include "includes/generated/cc900/HDAE5000_FileOptNameCheck.s"	; C: cc900/hdae5000_name_checks_hd_driver.c
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

HDAE5000_SfxTlxBitCheck:	.include "includes/generated/cc900/HDAE5000_SfxTlxBitCheck.s"	; C: cc900/hdae5000_sfx_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SfxTlxBitCheck_Ev01E00047, HDAE5000_SfxTlxBitCheck + 61
	.set	HDAE5000_SfxTlxBitCheck_Ev01E0003E, HDAE5000_SfxTlxBitCheck + 109
	.set	HDAE5000_SfxTlxBitCheck_Ev01E0003F, HDAE5000_SfxTlxBitCheck + 113
	.set	HDAE5000_SfxTlxBitCheck_Ev01E00043, HDAE5000_SfxTlxBitCheck + 117
	.set	HDAE5000_SfxTlxBitCheck_Ev01E00043_Join, HDAE5000_SfxTlxBitCheck + 129
	.set	HDAE5000_SfxTlxBitCheck_Ev01E00044, HDAE5000_SfxTlxBitCheck + 131
	.set	HDAE5000_SfxTlxBitCheck_Ev01E00044_Skip, HDAE5000_SfxTlxBitCheck + 155
	.set	HDAE5000_SfxTlxBitCheck_Ev01E00044_Join, HDAE5000_SfxTlxBitCheck + 164
	.set	HDAE5000_SfxTlxBitCheck_Ev01E00044_Join2, HDAE5000_SfxTlxBitCheck + 174
	.set	HDAE5000_SfxTlxBitCheck_Ev01E00045, HDAE5000_SfxTlxBitCheck + 176
	.set	HDAE5000_SfxTlxBitCheck_Ev01E00046, HDAE5000_SfxTlxBitCheck + 183
	.set	HDAE5000_SfxTlxBitCheck_OnRamDataReq, HDAE5000_SfxTlxBitCheck + 187
	.set	HDAE5000_SfxTlxBitCheck_Default, HDAE5000_SfxTlxBitCheck + 223
	.set	HDAE5000_SfxTlxBitCheck_Epilogue, HDAE5000_SfxTlxBitCheck + 225

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

HDAE5000_LyricJumpEditCheck:	.include "includes/generated/cc900/HDAE5000_LyricJumpEditCheck.s"	; C: cc900/hdae5000_edit_checks.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LyricJumpEditCheck_Ev01E00047, HDAE5000_LyricJumpEditCheck + 55
	.set	HDAE5000_LyricJumpEditCheck_Ev01E0003E, HDAE5000_LyricJumpEditCheck + 80
	.set	HDAE5000_LyricJumpEditCheck_Ev01E00043, HDAE5000_LyricJumpEditCheck + 84
	.set	HDAE5000_LyricJumpEditCheck_Ev01E00044, HDAE5000_LyricJumpEditCheck + 88
	.set	HDAE5000_LyricJumpEditCheck_Ev01E00045, HDAE5000_LyricJumpEditCheck + 92
	.set	HDAE5000_LyricJumpEditCheck_Ev01E00046, HDAE5000_LyricJumpEditCheck + 99
	.set	HDAE5000_LyricJumpEditCheck_OnRamDataReq, HDAE5000_LyricJumpEditCheck + 103
	.set	HDAE5000_LyricJumpEditCheck_Default, HDAE5000_LyricJumpEditCheck + 107
	.set	HDAE5000_LyricJumpEditCheck_Epilogue, HDAE5000_LyricJumpEditCheck + 109

; ---------------------------------------------------------------------------
; A second, UNREGISTERED edit-check procedure of the LYRIC JUMP setting: no
; table entry and no instruction of the image refers to its address (0x285F8B
; in v2.06i; found 2026-11-16 by lane_hd, cc900 round 27).  It answers
; EVT_GET_RAM_STRING with SPrintf("%1d", ...) of the argument record,
; EVT_RAM_DATA_REQ with 0, and on EVT_SW_IN sends EVT_MAKE_EDIT_SW_ID to
; object 0x02600024.  Its inner labels keep their older
; HDAE5000_LyricJumpEditCheck_Default_* names.  Not in v2.01i or earlier.
; In:  XWA = object, XBC = event, XDE = argument.  Out: XHL.
; ---------------------------------------------------------------------------
HDAE5000_LyricJumpEditCheck_Unregistered:
	push xiz
	ld	xiz, xwa
	cp	xbc, EVT_SW_IN
	jr	z, HDAE5000_LyricJumpEditCheck_Default_OnSwIn
	cp	xbc, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_LyricJumpEditCheck_Default_OnRamDataReq
	cp	xbc, EVT_GET_RAM_STRING
	jr	nz, HDAE5000_LyricJumpEditCheck_Default_Done
	ld xwa, (xde + 0x0e)
	push xwa
	pushw HDAE5000_Fmt_1d_LyricJumpEditCheck@hi16
	pushw HDAE5000_Fmt_1d_LyricJumpEditCheck@lo16		; low half of HDAE5000_Fmt_1d_LyricJumpEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_LyricJumpEditCheck_Default_Epilogue
HDAE5000_LyricJumpEditCheck_Default_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LyricJumpEditCheck_Default_Epilogue
HDAE5000_LyricJumpEditCheck_Default_OnSwIn:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	or xhl, xhl
	jr	z, HDAE5000_LyricJumpEditCheck_Default_Done
HDAE5000_LyricJumpEditCheck_Default_Done:
	ld	xhl, 0:i3
HDAE5000_LyricJumpEditCheck_Default_Epilogue:
	pop xiz
	ret

HDAE5000_LyricForeColorCheck:	.include "includes/generated/cc900/HDAE5000_LyricForeColorCheck.s"	; C: cc900/hdae5000_edit_checks.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LyricForeColorCheck_Ev01E00047, HDAE5000_LyricForeColorCheck + 55
	.set	HDAE5000_LyricForeColorCheck_Ev01E0003E, HDAE5000_LyricForeColorCheck + 92
	.set	HDAE5000_LyricForeColorCheck_Ev01E0003F, HDAE5000_LyricForeColorCheck + 96
	.set	HDAE5000_LyricForeColorCheck_Ev01E00043, HDAE5000_LyricForeColorCheck + 100
	.set	HDAE5000_LyricForeColorCheck_Ev01E00044, HDAE5000_LyricForeColorCheck + 104
	.set	HDAE5000_LyricForeColorCheck_Ev01E00045, HDAE5000_LyricForeColorCheck + 108
	.set	HDAE5000_LyricForeColorCheck_Ev01E00046, HDAE5000_LyricForeColorCheck + 115
	.set	HDAE5000_LyricForeColorCheck_OnRamDataReq, HDAE5000_LyricForeColorCheck + 119
	.set	HDAE5000_LyricForeColorCheck_Default, HDAE5000_LyricForeColorCheck + 123
	.set	HDAE5000_LyricForeColorCheck_Epilogue, HDAE5000_LyricForeColorCheck + 125

HDAE5000_LyricBackColorCheck:	.include "includes/generated/cc900/HDAE5000_LyricBackColorCheck.s"	; C: cc900/hdae5000_edit_checks.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LyricBackColorCheck_Ev01E00047, HDAE5000_LyricBackColorCheck + 55
	.set	HDAE5000_LyricBackColorCheck_Ev01E0003E, HDAE5000_LyricBackColorCheck + 92
	.set	HDAE5000_LyricBackColorCheck_Ev01E0003F, HDAE5000_LyricBackColorCheck + 96
	.set	HDAE5000_LyricBackColorCheck_Ev01E00043, HDAE5000_LyricBackColorCheck + 100
	.set	HDAE5000_LyricBackColorCheck_Ev01E00044, HDAE5000_LyricBackColorCheck + 104
	.set	HDAE5000_LyricBackColorCheck_Ev01E00045, HDAE5000_LyricBackColorCheck + 108
	.set	HDAE5000_LyricBackColorCheck_Ev01E00046, HDAE5000_LyricBackColorCheck + 115
	.set	HDAE5000_LyricBackColorCheck_OnRamDataReq, HDAE5000_LyricBackColorCheck + 119
	.set	HDAE5000_LyricBackColorCheck_Default, HDAE5000_LyricBackColorCheck + 123
	.set	HDAE5000_LyricBackColorCheck_Epilogue, HDAE5000_LyricBackColorCheck + 125

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
	ld a, (0x22ad9c:24); A = current count
	extz wa
	ld bc, wa
	inc 2, bc			; BC = count + 2
	lda xde, (0x22ad9c:24); XDE = buffer base
	ld a, (xsp + 0x02)		; A = digit param
	ld	(xde+bc), a
	inc	1, (0x22AD9C:24)
	cp (0x22ad9c:24), 0x06; count == 6?
	jr nz, .LCHSC__not_full
	; 6 digits entered — match against patterns
	pushw HDAE5000_Str_HdFormatCode@hi16
	pushw HDAE5000_Str_HdFormatCode@lo16		; low half of HDAE5000_Str_HdFormatCode
	lda xwa, (HDAE5000_RAM_FormatCodeDigits:24)
	push xwa
	call HDAE5000_StrPrefixCmp			; string compare
	inc 8, xsp
	cp hl, 0:i3
	jr nz, .LCHSC__try2
	ld iz, 2:i3			; match pattern 1 → IZ=2
	jr t, .LCHSC__clear
.LCHSC__try2:
	pushw HDAE5000_Str_Track0RecoverCode@hi16
	pushw HDAE5000_Str_Track0RecoverCode@lo16		; low half of HDAE5000_Str_Track0RecoverCode
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
	lda xwa, (0x22ad9c:24)
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
HDAE5000_LBNLoadSwCatch:	.include "includes/generated/cc900/HDAE5000_LBNLoadSwCatch.s"	; C: cc900/hdae5000_drv_screens2.c

; ---------------------------------------------------------------------------
; Load-by-number: type digit BC at position HDAE5000_RAM_LbnDigitPos --
; hundreds, tens and units of the directory number HDAE5000_RAM_LbnDir, tens
; and units of the song number HDAE5000_RAM_LbnSong -- redraw
; (HDAE5000_Lbn_ShowEntry) and after the last digit load the song
; (HDAE5000_LoadSongWithUi).
; In:  BC = digit
; ---------------------------------------------------------------------------
HDAE5000_Lbn_TypeDigit:	.include "includes/generated/cc900/HDAE5000_Lbn_TypeDigit.s"	; C: cc900/hdae5000_drv_screens5.c

; --- Filesystem Operations ---
