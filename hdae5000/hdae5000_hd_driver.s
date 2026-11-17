; ---------------------------------------------------------------------------
; Scan the floppy: needs media type 2 or 3 from the main CPU
; (HamaFn_GetMediaType; else HDAE5000_ShowErrorMessageTitle(2) and HL =
; 0xFFFF), blanks the list (HDAE5000_FdList_Clear), shows the volume label,
; then walks "*.*" with HamaFn__findfirst / _findnext / _findclose: every name
; whose HDAE5000_FdName_SongNumber is n sets present flag n (FdList+0x100) and
; puts its 6 characters in row n.  Caller: HDDTitleSwCatch.
; ---------------------------------------------------------------------------
HDAE5000_FdList_Scan:
	lda xsp, (xsp-268)	; lda xsp, (xsp + 0xfef4) — alloc 268-byte frame
	push xiz					; 3e
	ldw	(xsp+4), 0x0000
	; Check disk status via 0x0e88 vtable
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_HamaFnTable)             ; e3 e1 88 0e 20
	ld xix, (xwa + HamaFn_GetMediaType)				; a8 08 24
	call (xix)					; b4 e8
	cp l, 3:i3					; cf db
	jr z, .Lsd_status_ok				; 66 05
	cp l, 2:i3					; cf da
	jrl nz, .Lsd_not_ready			; 7e 49 02
.Lsd_status_ok:
	; Register event 0xD2 via vtable 0x0124
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_CP_FD				; 40 d2 00 7f 00
	ld xbc, EVT_SHOW				; 41 01 00 c0 01
	ld xde, 0xffffffff				; 42 ff ff ff ff
	call (xhl)					; b3 e8
	calr HDAE5000_FdList_Clear			; 1e 5b fe
	; Get drive info via 0x0e88.0x0090 vtable
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_HamaFnTable)             ; e3 e1 88 0e 20
	ld_sril xhl, (xwa + HamaFn_GetVolumeLabel)             ; e3 e1 90 00 23
	call (xhl)					; b3 e8
	ld xiz, xhl					; eb 8e
	ld xwa, xiz					; ee 88
	or xwa, xwa					; e8 e0 — test if null
	jr z, .Lsd_skip_copy				; 66 18
	; Copy drive info to 0x22aa9c buffer
	ld xwa, xiz					; ee 88
	push xwa					; 38
	call HDAE5000_StrLen					; 1d 71 af 29
	pushw hl                                ; push hl (compact)
	ld xwa, xiz					; ee 88
	push xwa					; 38
	lda xwa, (HDAE5000_RAM_FdList:24); f2 9c aa 22 30
	push xwa					; 38
	call HDAE5000_MemCopy					; 1d 9f ae 29
	lda xsp, (xsp + 0x0e)			; bf 0e 37
.Lsd_skip_copy:
	; Register event 0xDE via vtable, with 0x22aa9c as data
	lda xwa, (HDAE5000_RAM_FdList:24); f2 9c aa 22 30
	ld xde, xwa					; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL				; 40 de 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR				; 41 0a 00 ea 01
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL				; 40 de 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 0xffffffff				; 42 ff ff ff ff
	call (xhl)					; b3 e8
	; Identify drive: call via 0x0e88.0x0094
	lda xwa, (HDAE5000_Str_AllFilesPattern:24); f2 b4 22 2e 30
	ld xde, xwa					; e8 8a
	lda xwa, (xsp + 0x06)			; bf 06 30
	ld xbc, xwa					; e8 89
	ld xwa, xde					; ea 88
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 22
	ld xde, (xde + WS_HamaFnTable)             ; e3 e9 88 0e 22
	ld_sril xhl, (xde + HamaFn__findfirst)             ; e3 e9 94 00 23
	call (xhl)					; b3 e8
	ld xiz, xhl					; eb 8e
	; Check identify result
	ld xwa, xiz					; ee 88
	cp xwa, 0x00000000				; e8 cf 00 00 00 00
	jrl lt, .Lsd_post_loop			; 71 ab 00
	; First pass: process partitions
	lda xwa, (xsp + 0x0c)			; bf 0c 30
	calr HDAE5000_FdName_SongNumber		; 1e c4 fe
	ld wa, hl					; db 88
	cp wa, 0xffff					; d8 cf ff ff
	jr z, .Lsd_loop_done				; 66 6e
	ld wa, hl					; db 88
	add wa, 0x0100				; d8 c8 00 01
	lda xbc, (HDAE5000_RAM_FdList:24); f2 9c aa 22 31
	ld	(xbc+wa), 0x01
	pushw 0x0006					; 0b 06 00
	lda xwa, (xsp + 0x10)			; bf 10 30
	push xwa					; 38
	ld wa, hl					; db 88
	muls wa, 0x000c				; d8 09 0c 00
	lda xbc, (HDAE5000_RAM_FdList+17:24); f2 ad aa 22 31
	exts xwa					; e8 13
	add xwa, xbc					; e9 80
	push xwa					; 38
	call HDAE5000_MemCopy					; 1d 9f ae 29
	lda xsp, (xsp + 0x0a)			; bf 0a 37
	jr t, .Lsd_loop_done				; 68 3d
	; Second pass (loop target for retry)
.Lsd_retry:
	lda xwa, (xsp + 0x0c)			; bf 0c 30
	calr HDAE5000_FdName_SongNumber		; 1e 85 fe
	ld wa, hl					; db 88
	cp wa, 0xffff					; d8 cf ff ff
	jr z, .Lsd_loop_done				; 66 2f
	ld wa, hl					; db 88
	add wa, 0x0100				; d8 c8 00 01
	lda xbc, (HDAE5000_RAM_FdList:24); f2 9c aa 22 31
	ld	(xbc+wa), 0x01
	pushw 0x0006					; 0b 06 00
	lda xwa, (xsp + 0x10)			; bf 10 30
	push xwa					; 38
	ld wa, hl					; db 88
	muls wa, 0x000c				; d8 09 0c 00
	lda xbc, (HDAE5000_RAM_FdList+17:24); f2 ad aa 22 31
	exts xwa					; e8 13
	add xwa, xbc					; e9 80
	push xwa					; 38
	call HDAE5000_MemCopy					; 1d 9f ae 29
	lda xsp, (xsp + 0x0a)			; bf 0a 37
.Lsd_loop_done:
	; Get next partition via 0x0e88.0x0098
	lda xwa, (xsp + 0x06)			; bf 06 30
	ld xbc, xwa					; e8 89
	ld xwa, xiz					; ee 88
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 22
	ld xde, (xde + WS_HamaFnTable)             ; e3 e9 88 0e 22
	ld_sril xix, (xde + HamaFn__findnext)             ; e3 e9 98 00 24
	call (xix)					; b4 e8
	cp hl, 0:i3					; db d8
	jr z, .Lsd_retry				; 66 a7
	; Cleanup: call via 0x0e88.0x009c
	ld xwa, xiz					; ee 88
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 21
	ld xbc, (xbc + WS_HamaFnTable)             ; e3 e5 88 0e 21
	ld_sril xhl, (xbc + HamaFn__findclose)             ; e3 e5 9c 00 23
	call (xhl)					; b3 e8
.Lsd_post_loop:
	; Format partition display table: loop over 20 entries
	ld de, 0:i3					; da a8
	cp de, 0x0014					; da cf 14 00
	jr nc, .Lsd_display_done			; 6f 56
.Lsd_display_loop:
	ld wa, de					; da 88
	mul wa, 0x000c				; d8 08 0c 00
	add wa, 0x000a				; d8 c8 0a 00
	extz xwa					; e8 12
	add xwa, 0x0000000e				; e8 c8 0e 00 00 00
	ld xbc, HDAE5000_RAM_FdList				; 41 9c aa 22 00
	add xbc, xwa					; e8 81
	ld	(xbc), 0x20
	; Check if partition marked active
	ld wa, de					; da 88
	extz xwa					; e8 12
	add xwa, 0x00000114				; e8 c8 14 01 00 00
	ld xbc, HDAE5000_RAM_FdList				; 41 9c aa 22 00
	add xbc, xwa					; e8 81
	cp	(xbc), 0x01
	jr nz, .Lsd_display_next			; 6e 1c
	; Active partition: mark with asterisk
	ld wa, de					; da 88
	mul wa, 0x000c				; d8 08 0c 00
	add wa, 0x000a				; d8 c8 0a 00
	extz xwa					; e8 12
	add xwa, 0x0000000e				; e8 c8 0e 00 00 00
	ld xbc, HDAE5000_RAM_FdList				; 41 9c aa 22 00
	add xbc, xwa					; e8 81
	ld	(xbc), 0x2a
.Lsd_display_next:
	inc 1, de					; da 61
	cp de, 0x0014					; da cf 14 00
	jr c, .Lsd_display_loop			; 67 aa
.Lsd_display_done:
	; Register display events via vtable 0x0124
	lda xwa, (HDAE5000_RAM_FdList+14:24); f2 aa aa 22 30
	ld xde, xwa					; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LIST				; 40 d7 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR				; 41 0a 00 ea 01
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LIST				; 40 d7 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 0xffffffff				; 42 ff ff ff ff
	call (xhl)					; b3 e8
	; Register event 0xD9 + 0xD8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LINE1				; 40 d9 00 7f 00
	ld xbc, EVT_DRAW				; 41 0d 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LINE2				; 40 d8 00 7f 00
	ld xbc, EVT_DRAW				; 41 0d 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
	jr t, .Lsd_epilogue				; 68 0a
.Lsd_not_ready:
	; Disk not ready: call shutdown with error code 2
	ld wa, 2:i3					; d8 aa
	calr HDAE5000_ShowErrorMessageTitle			; 1e fc 7b
	ldw	(xsp+4), 0xffff
.Lsd_epilogue:
	ld hl, (xsp + 0x04)				; 9f 04 23
	pop xiz					; 5e
	lda xsp, (xsp+268)	; lda xsp, (xsp + 0x010c) — dealloc frame
	ret						; 0e
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
HDAE5000_DirList_BuildPage:
	lda	xsp, (xsp-26)
	pushw iz                                ; push iz (compact 1-byte)
	ld (xsp + 0x18), xwa		; save context ptr

	; --- Format 0x01F9 entries into buffer ---
	pushw 0x01f9
	pushw 0x0000
	lda xwa, (HDAE5000_RAM_DirListText:24)
	push xwa
	call HDAE5000_MemFill
	inc 8, xsp			; (NOP — callee cleaned stack)

	; --- Loop: format 24 (0x18) entries ---
	ld iz, 0:i3			; IZ = loop counter
	cp iz, 0x0018
	jr ge, .Lfp_loop_done

.Lfp_format_entry:
	; Format field name
	pushw 0x0015
	lda xwa, (HDAE5000_Str_Chr2020203A2020:24)
	push xwa
	ldw wa, 0x0015
	muls xwa, iz			; XWA = IZ * 21
	lda xbc, (HDAE5000_RAM_DirListText:24)
	exts xwa
	add xwa, xbc			; XWA = buffer + IZ*21
	push xwa
	call HDAE5000_MemCopy
	; Format entry number
	ld wa, iz
	add wa, (HDAE5000_RAM_DirPageBase:24); WA += base offset
	inc 1, wa
	pushw wa                                ; push wa (compact 1-byte)
	pushw HDAE5000_Fmt_3_3d@hi16
	pushw HDAE5000_Fmt_3_3d@lo16		; low half of HDAE5000_Fmt_3_3d
	lda xwa, (xsp + 0x12)
	push xwa
	call HDAE5000_SPrintf
	; Format second field
	pushw 0x0003
	lda xwa, (xsp + 0x18)
	push xwa
	ldw wa, 0x0015
	muls xwa, iz
	lda xbc, (HDAE5000_RAM_DirListText:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x1e)		; clean stack (30 bytes)

	; Load sector address for this entry
	ld wa, (HDAE5000_RAM_DirPageBase:24); WA = base offset
	add wa, iz			; WA = base + IZ
	call HDAE5000_DirName_Address			; XHL = sector address
	; Format sector data
	pushw 0x0010
	push xhl
	ldw wa, 0x0015
	muls xwa, iz
	lda xbc, (HDAE5000_RAM_DirListText+4:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)		; clean stack

	inc 1, iz
	cp iz, 0x0018
	jr lt, .Lfp_format_entry

.Lfp_loop_done:
	; --- Epilogue: vtable calls ---
	lda xwa, (HDAE5000_RAM_DirListText:24)
	ld xbc, xwa
	ld xwa, (xsp + 0x18)		; restore context ptr
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)             ; XBC = (XBC + 0x0e0a)
	ld xhl, (xbc + RootFn_ApPostEvent)             ; XHL = (XBC + 0x0124)
	ld xbc, EVT_HDAE_SET_STR_ADR
	call (xhl)

	ld xwa, (xsp + 0x18)		; restore context ptr
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld xhl, (xbc + RootFn_ApPostEvent)
	ld xbc, EVT_PARA_DRAW
	ld xde, 0xffffffff
	call (xhl)

	popw iz                                 ; pop iz (compact 1-byte)
	lda xsp, (xsp + 0x1a)		; deallocate 26-byte frame
	ret

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
	cp	xwa, 0x0000000d
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
HDAE5000_FILE_LOAD_Screen_Ev01EA000D:
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
HDAE5000_FILE_LOAD_Screen_Ev01EA000C:
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
HDAE5000_SeparateOutput_SendPartMsg:
	dec 8, xsp			; allocate 8 bytes on stack
	ld l, c				; save C in L
	ld xiy, HDAE5000_SeparateOutput_MsgTemplateA		; source template address (first block)
	lda xix, (xsp + 4)		; XIX = destination: stack+4
	ldiw				; copy word (XIY→XIX, both advance)
	ldiw				; copy second word
	ld xiy, HDAE5000_SeparateOutput_MsgTemplateB		; source template address (second block)
	ld xix, xsp			; XIX = destination: stack base
	ldiw				; copy word
	ldiw				; copy second word
	; --- Parameter validation ---
	cp a, 0x10			; A must be < 16
	jr nc, .Lwr_exit		; if A >= 16, bail out
	cp l, 1:i3			; L must be <= 1
	jr ugt, .Lwr_exit		; if L > 1, bail out
	cp e, 2:i3			; E must be <= 2
	jr ugt, .Lwr_exit		; if E > 2, bail out
	; --- Fill parameter blocks ---
	ld (xsp + 5), a			; store register index at offset 5
	ld (xsp + 1), a			; store register index at offset 1
	cp l, 0:i3			; check bank
	jr nz, .Lwr_bank1
	ld (xsp + 7), 0x01		; bank 0: store 0x01 at offset 7
	jr t, .Lwr_mode
.Lwr_bank1:
	ld (xsp + 7), 0x20		; bank 1: store 0x20 at offset 7
.Lwr_mode:
	cp e, 0:i3			; check mode
	jr nz, .Lwr_mode1
	ld (xsp + 3), 0x00		; mode 0: store 0x00 at offset 3
	jr t, .Lwr_call
.Lwr_mode1:
	cp e, 1:i3			; mode 1?
	jr nz, .Lwr_mode2
	ld (xsp + 3), 0x01		; mode 1: store 0x01 at offset 3
	jr t, .Lwr_call
.Lwr_mode2:
	ld (xsp + 3), 0x02		; mode 2: store 0x02 at offset 3
.Lwr_call:
	; --- First workspace call (stack+4 block) ---
	lda xwa, (xsp + 4)		; XWA = pointer to first param block
	ld xde, xwa			; XDE = param block ptr
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_sendCOMM)
	ld wa, 0:i3			; WA = 0
	ld bc, 4:i3			; BC = 4 (param count)
	call (xhl)			; call handler
	; --- Second workspace call (stack base block) ---
	lda xwa, (xsp)			; XWA = pointer to second param block
	ld xde, xwa			; XDE = param block ptr
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_sendCOMM)
	ld wa, 0:i3			; WA = 0
	ld bc, 4:i3			; BC = 4
	call (xhl)			; call handler
.Lwr_exit:
	inc 8, xsp			; deallocate 8 bytes
	ret

; ---------------------------------------------------------------------------
; Apply the SEPARATE OUTPUT setting: HDAE5000_RAM_SeparateOutputMode ("OFF",
; "DRUMS L/R", "BASS+DRUMS MIX", "BASS/DRUMS MONO") goes to the main CPU
; (HamaFn_SetSepaOutMode); the previous parts (SeparateDrumPartSent /
; SeparateBassPartSent) are undone and the new ones (SeparateDrumPart /
; SeparateBassPart) sent with HDAE5000_SeparateOutput_SendPartMsg.
; ---------------------------------------------------------------------------
HDAE5000_SeparateOutput_Apply:
	ld a, (HDAE5000_RAM_SeparateOutputMode:24)
	extz wa
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn_SetSepaOutMode)             ; ld XHL, (XBC + 0x0084)
	call (xhl)			; callback
	cp (HDAE5000_RAM_SeparateDrumPartSent:24), 0x00
	jr z, .LHD_SC__skip_a2
	ld a, (HDAE5000_RAM_SeparateDrumPartSent:24)
	dec 1, a
	extz wa
	ld bc, 0:i3
	ld de, 0:i3
	calr HDAE5000_SeparateOutput_SendPartMsg
	ld (HDAE5000_RAM_SeparateDrumPartSent:24), 0x00
.LHD_SC__skip_a2:
	cp (HDAE5000_RAM_SeparateBassPartSent:24), 0x00
	jr z, .LHD_SC__dispatch
	ld a, (HDAE5000_RAM_SeparateBassPartSent:24)
	dec 1, a
	extz wa
	ld bc, 0:i3
	ld de, 0:i3
	calr HDAE5000_SeparateOutput_SendPartMsg
	ld (HDAE5000_RAM_SeparateBassPartSent:24), 0x00
.LHD_SC__dispatch:
	ld a, (HDAE5000_RAM_SeparateOutputMode:24); re-read state byte
	cp a, 3:i3
	jr z, .LHD_SC__state3
	cp a, 2:i3
	jr z, .LHD_SC__state2
	cp a, 1:i3
	jr z, .LHD_SC__state1
	cp a, 0:i3
	ret z
	ret
.LHD_SC__state1:			; state=1: process A0A0, copy to A0A2
	cp (HDAE5000_RAM_SeparateDrumPart:24), 0x00
	ret z
	ld a, (HDAE5000_RAM_SeparateDrumPart:24)
	dec 1, a
	extz wa
	ld bc, 1:i3
	ld de, 0:i3
	calr HDAE5000_SeparateOutput_SendPartMsg
	ld a, (HDAE5000_RAM_SeparateDrumPart:24)
	ld (HDAE5000_RAM_SeparateDrumPartSent:24), a
	ret
.LHD_SC__state2:			; state=2: process A0A0+A09E
	cp (HDAE5000_RAM_SeparateDrumPart:24), 0x00
	jr z, .LHD_SC__s2_check_9e
	ld a, (HDAE5000_RAM_SeparateDrumPart:24)
	dec 1, a
	extz wa
	ld bc, 1:i3
	ld de, 0:i3
	calr HDAE5000_SeparateOutput_SendPartMsg
	ld a, (HDAE5000_RAM_SeparateDrumPart:24)
	ld (HDAE5000_RAM_SeparateDrumPartSent:24), a
.LHD_SC__s2_check_9e:
	cp (HDAE5000_RAM_SeparateBassPart:24), 0x00
	ret z
	ld a, (HDAE5000_RAM_SeparateBassPart:24)
	dec 1, a
	extz wa
	ld bc, 1:i3
	ld de, 0:i3
	calr HDAE5000_SeparateOutput_SendPartMsg
	ld a, (HDAE5000_RAM_SeparateBassPart:24)
	ld (HDAE5000_RAM_SeparateBassPartSent:24), a
	ret
.LHD_SC__state3:			; state=3: process A0A0 (DE=2) + A09E (DE=1)
	cp (HDAE5000_RAM_SeparateDrumPart:24), 0x00
	jr z, .LHD_SC__s3_check_9e
	ld a, (HDAE5000_RAM_SeparateDrumPart:24)
	dec 1, a
	extz wa
	ld bc, 1:i3
	ld de, 2:i3
	calr HDAE5000_SeparateOutput_SendPartMsg
	ld a, (HDAE5000_RAM_SeparateDrumPart:24)
	ld (HDAE5000_RAM_SeparateDrumPartSent:24), a
.LHD_SC__s3_check_9e:
	cp (HDAE5000_RAM_SeparateBassPart:24), 0x00
	ret z
	ld a, (HDAE5000_RAM_SeparateBassPart:24)
	dec 1, a
	extz wa
	ld bc, 1:i3
	ld de, 1:i3
	calr HDAE5000_SeparateOutput_SendPartMsg
	ld a, (HDAE5000_RAM_SeparateBassPart:24)
	ld (HDAE5000_RAM_SeparateBassPartSent:24), a
	ret
	;
	; Part 2: Event handler 1 (0x2850ED) — jump table dispatch
HDAE5000_SeparateOutputModeCheck:
	; registered as "SeparateOutputModeCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa			; save context in XIZ
	ld xwa, xbc			; XWA = event code
	cp xwa, EVT_RAM_DATA_REQ		; special event?
	jr z, .LHD_SC__h1_event82
	sub xwa, EVT_GET_LARGE_STEP		; normalize to 0-based index
	cp xwa, 0x00000000
	jrl lt, .LHD_SC__h1_default
	cp xwa, 0x00000009
	jr gt, .LHD_SC__h1_default
	add xwa, xwa			; index * 2 (16-bit offsets)
	add xwa, HDAE5000_SeparateOutputModeCheck_CaseTable		; + jump table base
	ld wa, (xwa)			; WA = offset
	lda xix, (.LHD_SC__h1_case9:24); XIX = dispatch base (h1_case9)
	jp	t, (xix+wa)
.LHD_SC__h1_case9:			; case 9 (offset 0x0000): PPI block copy
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_OFF_DRUMSLR_BASSDRUMSMIX_BASSDRUMSMONO		; secondary data table
	add xbc, xwa
	ld xwa, (xbc)			; load address from table
	push xwa
	pushw HDAE5000_Fmt_s_SeparateOutputModeCheck@hi16		; push 0x002E -- high half of HDAE5000_Fmt_s_SeparateOutputModeCheck
	pushw HDAE5000_Fmt_s_SeparateOutputModeCheck@lo16		; low half of HDAE5000_Fmt_s_SeparateOutputModeCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)		; deallocate 12 bytes
	ld xhl, xiz			; return saved context
	jr t, .LHD_SC__h1_exit
.LHD_SC__h1_case0:			; case 0 (offset 0x0025)
	ld xhl, 1:i3
	jr t, .LHD_SC__h1_exit
.LHD_SC__h1_case1:			; case 1 (offset 0x0029)
	ld xhl, 1:i3
	jr t, .LHD_SC__h1_exit
.LHD_SC__h1_case5:			; case 5 (offset 0x002D)
	ld xhl, 3:i3
	jr t, .LHD_SC__h1_exit
.LHD_SC__h1_case6:			; case 6 (offset 0x0031)
	ld xhl, 0:i3
	jr t, .LHD_SC__h1_exit
.LHD_SC__h1_case7:			; case 7 (offset 0x0035)
	lda xhl, (HDAE5000_RAM_SeparateOutputMode:24)
	jr t, .LHD_SC__h1_exit
.LHD_SC__h1_case8:			; case 8 (offset 0x003C)
	ld xhl, 1:i3
	jr t, .LHD_SC__h1_exit
.LHD_SC__h1_event82:			; event 0x01E00082: callback chain
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SleepMainTask)
	call (xhl)
	calr HDAE5000_SeparateOutput_Apply	; recursive call
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_WakeUpMainTask)
	call (xhl)
	ld xhl, 0:i3
	jr t, .LHD_SC__h1_exit
.LHD_SC__h1_default:			; out-of-range
	ld xhl, 0:i3
.LHD_SC__h1_exit:
	pop xiz
	ret
	;
	; Part 3: Event handler 2 (0x285192) — same structure, different data
HDAE5000_SeparateDrumPartCheck:
	; registered as "SeparateDrumPartCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LHD_SC__h2_event82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jrl lt, .LHD_SC__h2_default
	cp xwa, 0x00000009
	jrl gt, .LHD_SC__h2_default
	add xwa, xwa
	add xwa, HDAE5000_SeparateDrumPartCheck_CaseTable		; jump table 2
	ld wa, (xwa)
	lda xix, (.LHD_SC__h2_case9:24); XIX = dispatch base (h2_case9)
	jp	t, (xix+wa)
.LHD_SC__h2_case9:			; case 9: PPI block copy
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_NONE_to_16		; secondary data table 2
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SeparateDrumPartCheck@hi16		; push 0x002E -- high half of HDAE5000_Fmt_s_SeparateDrumPartCheck
	pushw HDAE5000_Fmt_s_SeparateDrumPartCheck@lo16		; low half of HDAE5000_Fmt_s_SeparateDrumPartCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LHD_SC__h2_exit
.LHD_SC__h2_case0:
	ld xhl, 1:i3
	jr t, .LHD_SC__h2_exit
.LHD_SC__h2_case1:
	ld xhl, 1:i3
	jr t, .LHD_SC__h2_exit
.LHD_SC__h2_case5:			; case 5: XHL = 0x10
	ld xhl, 0x00000010
	jr t, .LHD_SC__h2_exit
.LHD_SC__h2_case6:
	ld xhl, 0:i3
	jr t, .LHD_SC__h2_exit
.LHD_SC__h2_case7:			; case 7: lda XHL, 0x23A0A0
	lda xhl, (HDAE5000_RAM_SeparateDrumPart:24)
	jr t, .LHD_SC__h2_exit
.LHD_SC__h2_case8:
	ld xhl, 1:i3
	jr t, .LHD_SC__h2_exit
.LHD_SC__h2_event82:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SleepMainTask)
	call (xhl)
	calr HDAE5000_SeparateOutput_Apply
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_WakeUpMainTask)
	call (xhl)
	ld xhl, 0:i3
	jr t, .LHD_SC__h2_exit
.LHD_SC__h2_default:
	ld xhl, 0:i3
.LHD_SC__h2_exit:
	pop xiz
	ret
	;
	; Part 4: Event handler 3 (0x28523B) — same structure, different data
HDAE5000_SeparateBassPartCheck:
	; registered as "SeparateBassPartCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LHD_SC__h3_event82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jrl lt, .LHD_SC__h3_default
	cp xwa, 0x00000009
	jrl gt, .LHD_SC__h3_default
	add xwa, xwa
	add xwa, HDAE5000_SeparateBassPartCheck_CaseTable		; jump table 3
	ld wa, (xwa)
	lda xix, (.LHD_SC__h3_case9:24); XIX = dispatch base (h3_case9)
	jp	t, (xix+wa)
.LHD_SC__h3_case9:			; case 9: PPI block copy
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_NONE_to_16_2		; secondary data table 3
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SeparateBassPartCheck@hi16		; push 0x002E -- high half of HDAE5000_Fmt_s_SeparateBassPartCheck
	pushw HDAE5000_Fmt_s_SeparateBassPartCheck@lo16		; push 0x290A		; low half of HDAE5000_Fmt_s_SeparateBassPartCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LHD_SC__h3_exit
.LHD_SC__h3_case0:
	ld xhl, 1:i3
	jr t, .LHD_SC__h3_exit
.LHD_SC__h3_case1:
	ld xhl, 1:i3
	jr t, .LHD_SC__h3_exit
.LHD_SC__h3_case5:			; case 5: XHL = 0x10
	ld xhl, 0x00000010
	jr t, .LHD_SC__h3_exit
.LHD_SC__h3_case6:
	ld xhl, 0:i3
	jr t, .LHD_SC__h3_exit
.LHD_SC__h3_case7:			; case 7: lda XHL, 0x23A09E
	lda xhl, (HDAE5000_RAM_SeparateBassPart:24)
	jr t, .LHD_SC__h3_exit
.LHD_SC__h3_case8:
	ld xhl, 1:i3
	jr t, .LHD_SC__h3_exit
.LHD_SC__h3_event82:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SleepMainTask)
	call (xhl)
	calr HDAE5000_SeparateOutput_Apply
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_WakeUpMainTask)
	call (xhl)
	ld xhl, 0:i3
	jr t, .LHD_SC__h3_exit
.LHD_SC__h3_default:
	ld xhl, 0:i3
.LHD_SC__h3_exit:
	pop xiz
	ret

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
HDAE5000_TypeSel_Init:
	ld xix, xde			; save source
	ld hl, bc			; HL = flags
	ld e, (xsp + 4)			; E = flag byte from stack
	ld xiy, xix			; XIY = source
	ld xix, xwa			; XIX = dest (for ldirw)
	ld bc, 6:i3			; count = 6 words (12 bytes)
	ldirw				; 95 11: copy 6 words from (XIY+) to (XIX+)
	ld (xwa), hl			; store flags at dest[0..1]
	bit 0, hl			; bit 0 set?
	jr z, .LHD_Data_Copy__bit1
	ld (xwa + 2), e			; dest[2] = flag value
.LHD_Data_Copy__bit1:
	bit 1, hl
	jr z, .LHD_Data_Copy__bit2
	ld (xwa + 3), e
.LHD_Data_Copy__bit2:
	bit 2, hl
	jr z, .LHD_Data_Copy__bit3
	ld (xwa + 4), e
.LHD_Data_Copy__bit3:
	bit 3, hl
	jr z, .LHD_Data_Copy__bit4
	ld (xwa + 5), e
.LHD_Data_Copy__bit4:
	bit 4, hl
	jr z, .LHD_Data_Copy__bit5
	ld (xwa + 6), e
.LHD_Data_Copy__bit5:
	bit 5, hl
	jr z, .LHD_Data_Copy__bit6
	ld (xwa + 7), e
.LHD_Data_Copy__bit6:
	bit 6, hl
	jr z, .LHD_Data_Copy__bit7
	ld (xwa + 8), e
.LHD_Data_Copy__bit7:
	bit 7, hl
	jr z, .LHD_Data_Copy__bit8
	ld (xwa + 9), e
.LHD_Data_Copy__bit8:
	bit 8, hl
	jr z, .LHD_Data_Copy__done
	ld (xwa + 10), e
.LHD_Data_Copy__done:
	retd 0x0002

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
HDAE5000_TypeSel_ShowSaveFlags:	; 0x28541C (3728 bytes)
	; Show the nine save-option flags (0x22AA4E..56) as "---"/"NO "/"YES"
	; (pointer table 0x2E2922) in the objects "RAM_EDIT_LSW".."RAM_EDIT_TLX"
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
	call	(xhl)
	ld	a, (HDAE5000_RAM_SaveOptions+10:24)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES:24)
	ld	xde, (xbc+wa)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_RAM_EDIT_TLX
	ld	xbc, EVT_PARA_DRAW
	jp	(xhl)

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

HDAE5000_FileOptNameCheck:
	; registered as "FileOptNameCheck" in HDAE5000_ObjHandler_Table
	dec	4, xsp
	push xiz
	ld (xsp + 0x04), xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_FileOptNameCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_FileOptNameCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_FileOptNameCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_FileOptNameCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_FileOptNameCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_FileOptNameCheck_Ev01E00047:
	ld	xiz, xde
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_SongRecord_Address
	push xhl
	pushw HDAE5000_Fmt_s_FileOptNameCheck@hi16
	pushw HDAE5000_Fmt_s_FileOptNameCheck@lo16		; low half of HDAE5000_Fmt_s_FileOptNameCheck
	ld xwa, (xiz + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld xhl, (xsp + 0x04)
	jr	t, HDAE5000_FileOptNameCheck_Epilogue
HDAE5000_FileOptNameCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_FileOptNameCheck_Epilogue
HDAE5000_FileOptNameCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_FileOptNameCheck_Epilogue
HDAE5000_FileOptNameCheck_Ev01E00043:
	ld	xhl, 0:i3
	jr	t, HDAE5000_FileOptNameCheck_Epilogue
HDAE5000_FileOptNameCheck_Ev01E00044:
	ld	xhl, 0:i3
	jr	t, HDAE5000_FileOptNameCheck_Epilogue
HDAE5000_FileOptNameCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+11:24)
	jr	t, HDAE5000_FileOptNameCheck_Epilogue
HDAE5000_FileOptNameCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_FileOptNameCheck_Epilogue
HDAE5000_FileOptNameCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_FileOptNameCheck_Epilogue
HDAE5000_FileOptNameCheck_Default:
	ld	xhl, 0:i3
HDAE5000_FileOptNameCheck_Epilogue:
	pop xiz
	inc 4, xsp
	ret

HDAE5000_SfxLswBitCheck:
	; registered as "SfxLswBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_SfxLswBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_SfxLswBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_SfxLswBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_SfxLswBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_SfxLswBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_SfxLswBitCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SfxLswBitCheck@hi16
	pushw HDAE5000_Fmt_s_SfxLswBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxLswBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_SfxLswBitCheck_Epilogue
HDAE5000_SfxLswBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxLswBitCheck_Epilogue
HDAE5000_SfxLswBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxLswBitCheck_Epilogue
HDAE5000_SfxLswBitCheck_Ev01E00043:
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+2:24), 0
	jr	nz, HDAE5000_SfxLswBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
HDAE5000_SfxLswBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_SfxLswBitCheck_Epilogue
HDAE5000_SfxLswBitCheck_Ev01E00044:
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+2:24), 0
	jr	nz, HDAE5000_SfxLswBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
HDAE5000_SfxLswBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_SfxLswBitCheck_Epilogue
HDAE5000_SfxLswBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+2:24)
	jr	t, HDAE5000_SfxLswBitCheck_Epilogue
HDAE5000_SfxLswBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxLswBitCheck_Epilogue
HDAE5000_SfxLswBitCheck_OnRamDataReq:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	ld	xhl, 0:i3
	jr	t, HDAE5000_SfxLswBitCheck_Epilogue
HDAE5000_SfxLswBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_SfxLswBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_SfxPmtBitCheck:
	; registered as "SfxPmtBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_SfxPmtBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_SfxPmtBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_SfxPmtBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_SfxPmtBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_SfxPmtBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_SfxPmtBitCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SfxPmtBitCheck@hi16
	pushw HDAE5000_Fmt_s_SfxPmtBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxPmtBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_SfxPmtBitCheck_Epilogue
HDAE5000_SfxPmtBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxPmtBitCheck_Epilogue
HDAE5000_SfxPmtBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxPmtBitCheck_Epilogue
HDAE5000_SfxPmtBitCheck_Ev01E00043:
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+3:24), 0
	jr	nz, HDAE5000_SfxPmtBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
HDAE5000_SfxPmtBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_SfxPmtBitCheck_Epilogue
HDAE5000_SfxPmtBitCheck_Ev01E00044:
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+3:24), 0
	jr	nz, HDAE5000_SfxPmtBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
HDAE5000_SfxPmtBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_SfxPmtBitCheck_Epilogue
HDAE5000_SfxPmtBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+3:24)
	jr	t, HDAE5000_SfxPmtBitCheck_Epilogue
HDAE5000_SfxPmtBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxPmtBitCheck_Epilogue
HDAE5000_SfxPmtBitCheck_OnRamDataReq:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	ld	xhl, 0:i3
	jr	t, HDAE5000_SfxPmtBitCheck_Epilogue
HDAE5000_SfxPmtBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_SfxPmtBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_SfxSqtBitCheck:
	; registered as "SfxSqtBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_SfxSqtBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_SfxSqtBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_SfxSqtBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_SfxSqtBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_SfxSqtBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_SfxSqtBitCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SfxSqtBitCheck@hi16
	pushw HDAE5000_Fmt_s_SfxSqtBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxSqtBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_SfxSqtBitCheck_Epilogue
HDAE5000_SfxSqtBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxSqtBitCheck_Epilogue
HDAE5000_SfxSqtBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxSqtBitCheck_Epilogue
HDAE5000_SfxSqtBitCheck_Ev01E00043:
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+4:24), 0
	jr	nz, HDAE5000_SfxSqtBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
HDAE5000_SfxSqtBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_SfxSqtBitCheck_Epilogue
HDAE5000_SfxSqtBitCheck_Ev01E00044:
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+4:24), 0
	jr	nz, HDAE5000_SfxSqtBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
HDAE5000_SfxSqtBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_SfxSqtBitCheck_Epilogue
HDAE5000_SfxSqtBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+4:24)
	jr	t, HDAE5000_SfxSqtBitCheck_Epilogue
HDAE5000_SfxSqtBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxSqtBitCheck_Epilogue
HDAE5000_SfxSqtBitCheck_OnRamDataReq:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	ld	xhl, 0:i3
	jr	t, HDAE5000_SfxSqtBitCheck_Epilogue
HDAE5000_SfxSqtBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_SfxSqtBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_SfxCmpBitCheck:
	; registered as "SfxCmpBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_SfxCmpBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_SfxCmpBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_SfxCmpBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_SfxCmpBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_SfxCmpBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_SfxCmpBitCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SfxCmpBitCheck@hi16
	pushw HDAE5000_Fmt_s_SfxCmpBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxCmpBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_SfxCmpBitCheck_Epilogue
HDAE5000_SfxCmpBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxCmpBitCheck_Epilogue
HDAE5000_SfxCmpBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxCmpBitCheck_Epilogue
HDAE5000_SfxCmpBitCheck_Ev01E00043:
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+5:24), 0
	jr	nz, HDAE5000_SfxCmpBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
HDAE5000_SfxCmpBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_SfxCmpBitCheck_Epilogue
HDAE5000_SfxCmpBitCheck_Ev01E00044:
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+5:24), 0
	jr	nz, HDAE5000_SfxCmpBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
HDAE5000_SfxCmpBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_SfxCmpBitCheck_Epilogue
HDAE5000_SfxCmpBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+5:24)
	jr	t, HDAE5000_SfxCmpBitCheck_Epilogue
HDAE5000_SfxCmpBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxCmpBitCheck_Epilogue
HDAE5000_SfxCmpBitCheck_OnRamDataReq:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	ld	xhl, 0:i3
	jr	t, HDAE5000_SfxCmpBitCheck_Epilogue
HDAE5000_SfxCmpBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_SfxCmpBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_SfxTmBitCheck:
	; registered as "SfxTmBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_SfxTmBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_SfxTmBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_SfxTmBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_SfxTmBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_SfxTmBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_SfxTmBitCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SfxTmBitCheck@hi16
	pushw HDAE5000_Fmt_s_SfxTmBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxTmBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_SfxTmBitCheck_Epilogue
HDAE5000_SfxTmBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxTmBitCheck_Epilogue
HDAE5000_SfxTmBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxTmBitCheck_Epilogue
HDAE5000_SfxTmBitCheck_Ev01E00043:
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+6:24), 0
	jr	nz, HDAE5000_SfxTmBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
HDAE5000_SfxTmBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_SfxTmBitCheck_Epilogue
HDAE5000_SfxTmBitCheck_Ev01E00044:
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+6:24), 0
	jr	nz, HDAE5000_SfxTmBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
HDAE5000_SfxTmBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_SfxTmBitCheck_Epilogue
HDAE5000_SfxTmBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+6:24)
	jr	t, HDAE5000_SfxTmBitCheck_Epilogue
HDAE5000_SfxTmBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxTmBitCheck_Epilogue
HDAE5000_SfxTmBitCheck_OnRamDataReq:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	ld	xhl, 0:i3
	jr	t, HDAE5000_SfxTmBitCheck_Epilogue
HDAE5000_SfxTmBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_SfxTmBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_SfxMspBitCheck:
	; registered as "SfxMspBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_SfxMspBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_SfxMspBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_SfxMspBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_SfxMspBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_SfxMspBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_SfxMspBitCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SfxMspBitCheck@hi16
	pushw HDAE5000_Fmt_s_SfxMspBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxMspBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_SfxMspBitCheck_Epilogue
HDAE5000_SfxMspBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxMspBitCheck_Epilogue
HDAE5000_SfxMspBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxMspBitCheck_Epilogue
HDAE5000_SfxMspBitCheck_Ev01E00043:
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+7:24), 0
	jr	nz, HDAE5000_SfxMspBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
HDAE5000_SfxMspBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_SfxMspBitCheck_Epilogue
HDAE5000_SfxMspBitCheck_Ev01E00044:
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+7:24), 0
	jr	nz, HDAE5000_SfxMspBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
HDAE5000_SfxMspBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_SfxMspBitCheck_Epilogue
HDAE5000_SfxMspBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+7:24)
	jr	t, HDAE5000_SfxMspBitCheck_Epilogue
HDAE5000_SfxMspBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxMspBitCheck_Epilogue
HDAE5000_SfxMspBitCheck_OnRamDataReq:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	ld	xhl, 0:i3
	jr	t, HDAE5000_SfxMspBitCheck_Epilogue
HDAE5000_SfxMspBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_SfxMspBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_SfxRcmBitCheck:
	; registered as "SfxRcmBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_SfxRcmBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_SfxRcmBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_SfxRcmBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_SfxRcmBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_SfxRcmBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_SfxRcmBitCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SfxRcmBitCheck@hi16
	pushw HDAE5000_Fmt_s_SfxRcmBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxRcmBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_SfxRcmBitCheck_Epilogue
HDAE5000_SfxRcmBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxRcmBitCheck_Epilogue
HDAE5000_SfxRcmBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxRcmBitCheck_Epilogue
HDAE5000_SfxRcmBitCheck_Ev01E00043:
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+8:24), 0
	jr	nz, HDAE5000_SfxRcmBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
HDAE5000_SfxRcmBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_SfxRcmBitCheck_Epilogue
HDAE5000_SfxRcmBitCheck_Ev01E00044:
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+8:24), 0
	jr	nz, HDAE5000_SfxRcmBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
HDAE5000_SfxRcmBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_SfxRcmBitCheck_Epilogue
HDAE5000_SfxRcmBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+8:24)
	jr	t, HDAE5000_SfxRcmBitCheck_Epilogue
HDAE5000_SfxRcmBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxRcmBitCheck_Epilogue
HDAE5000_SfxRcmBitCheck_OnRamDataReq:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	ld	xhl, 0:i3
	jr	t, HDAE5000_SfxRcmBitCheck_Epilogue
HDAE5000_SfxRcmBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_SfxRcmBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_SfxMdBitCheck:
	; registered as "SfxMdBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_SfxMdBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_SfxMdBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_SfxMdBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_SfxMdBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_SfxMdBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_SfxMdBitCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SfxMdBitCheck@hi16
	pushw HDAE5000_Fmt_s_SfxMdBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxMdBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_SfxMdBitCheck_Epilogue
HDAE5000_SfxMdBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxMdBitCheck_Epilogue
HDAE5000_SfxMdBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxMdBitCheck_Epilogue
HDAE5000_SfxMdBitCheck_Ev01E00043:
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+9:24), 0
	jr	nz, HDAE5000_SfxMdBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
HDAE5000_SfxMdBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_SfxMdBitCheck_Epilogue
HDAE5000_SfxMdBitCheck_Ev01E00044:
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+9:24), 0
	jr	nz, HDAE5000_SfxMdBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
HDAE5000_SfxMdBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_SfxMdBitCheck_Epilogue
HDAE5000_SfxMdBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+9:24)
	jr	t, HDAE5000_SfxMdBitCheck_Epilogue
HDAE5000_SfxMdBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxMdBitCheck_Epilogue
HDAE5000_SfxMdBitCheck_OnRamDataReq:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	ld	xhl, 0:i3
	jr	t, HDAE5000_SfxMdBitCheck_Epilogue
HDAE5000_SfxMdBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_SfxMdBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_SfxTlxBitCheck:
	; registered as "SfxTlxBitCheck" in HDAE5000_ObjHandler_Table
	dec	4, xsp
	push xiz
	ld (xsp + 0x04), xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_SfxTlxBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_SfxTlxBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_SfxTlxBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_SfxTlxBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_SfxTlxBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_SfxTlxBitCheck_Ev01E00047:
	ld	xiz, xde
	ld xwa, (xiz + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_SfxTlxBitCheck@hi16
	pushw HDAE5000_Fmt_s_SfxTlxBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxTlxBitCheck
	ld xwa, (xiz + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld xwa, (xiz + 0x0e)
	ld	(0x23a0a6), xwa
	ld xhl, (xsp + 0x04)
	jr	t, HDAE5000_SfxTlxBitCheck_Epilogue
HDAE5000_SfxTlxBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxTlxBitCheck_Epilogue
HDAE5000_SfxTlxBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxTlxBitCheck_Epilogue
HDAE5000_SfxTlxBitCheck_Ev01E00043:
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+10:24), 0
	jr	nz, HDAE5000_SfxTlxBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
HDAE5000_SfxTlxBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_SfxTlxBitCheck_Epilogue
HDAE5000_SfxTlxBitCheck_Ev01E00044:
	ld	xwa, (0x23a0a6)
	cp	xwa, 0x00000001
	jr	nz, HDAE5000_SfxTlxBitCheck_Ev01E00044_Skip
	ld	xwa, 2:i3
	ld	(0x23a0a6), xwa
	ld	xhl, 2:i3
	jr	t, HDAE5000_SfxTlxBitCheck_Ev01E00044_Join
HDAE5000_SfxTlxBitCheck_Ev01E00044_Skip:
	ld	xwa, 1:i3
	ld	(0x23a0a6), xwa
	ld	xhl, 1:i3
HDAE5000_SfxTlxBitCheck_Ev01E00044_Join:
	cp	(HDAE5000_RAM_SaveOptions+10:24), 0
	jr	nz, HDAE5000_SfxTlxBitCheck_Ev01E00044_Join2
	ld	xhl, 0:i3
HDAE5000_SfxTlxBitCheck_Ev01E00044_Join2:
	jr	t, HDAE5000_SfxTlxBitCheck_Epilogue
HDAE5000_SfxTlxBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+10:24)
	jr	t, HDAE5000_SfxTlxBitCheck_Epilogue
HDAE5000_SfxTlxBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_SfxTlxBitCheck_Epilogue
HDAE5000_SfxTlxBitCheck_OnRamDataReq:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	ld	xhl, 0:i3
	jr	t, HDAE5000_SfxTlxBitCheck_Epilogue
HDAE5000_SfxTlxBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_SfxTlxBitCheck_Epilogue:
	pop xiz
	inc 4, xsp
	ret

HDAE5000_WriteProtectEditCheck:
	; registered as "WriteProtectEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_WriteProtectEditCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_WriteProtectEditCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_WriteProtectEditCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_WriteProtectEditCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_WriteProtectEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_WriteProtectEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_OFF_ON
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_WriteProtectEditCheck@hi16
	pushw HDAE5000_Fmt_s_WriteProtectEditCheck@lo16		; low half of HDAE5000_Fmt_s_WriteProtectEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_WriteProtectEditCheck_Epilogue
HDAE5000_WriteProtectEditCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_WriteProtectEditCheck_Epilogue
HDAE5000_WriteProtectEditCheck_Ev01E00043:
	ld	xhl, 1:i3
	jr	t, HDAE5000_WriteProtectEditCheck_Epilogue
HDAE5000_WriteProtectEditCheck_Ev01E00044:
	ld	xhl, 0:i3
	jr	t, HDAE5000_WriteProtectEditCheck_Epilogue
HDAE5000_WriteProtectEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_WriteProtect:24)
	jr	t, HDAE5000_WriteProtectEditCheck_Epilogue
HDAE5000_WriteProtectEditCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_WriteProtectEditCheck_Epilogue
HDAE5000_WriteProtectEditCheck_OnRamDataReq:
	ld	a, (HDAE5000_RAM_WriteProtect:24)
	extz wa
	calr	HDAE5000_Set_Menu_Visibility
	ld	xhl, 0:i3
	jr	t, HDAE5000_WriteProtectEditCheck_Epilogue
HDAE5000_WriteProtectEditCheck_Default:
	ld	xhl, 0:i3
HDAE5000_WriteProtectEditCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LyricJumpEditCheck:
	; registered as "LyricJumpEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_LyricJumpEditCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_LyricJumpEditCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_LyricJumpEditCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LyricJumpEditCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LyricJumpEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LyricJumpEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	push xwa
	pushw HDAE5000_Fmt_1d@hi16
	pushw HDAE5000_Fmt_1d@lo16		; low half of HDAE5000_Fmt_1d
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_LyricJumpEditCheck_Epilogue
HDAE5000_LyricJumpEditCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LyricJumpEditCheck_Epilogue
HDAE5000_LyricJumpEditCheck_Ev01E00043:
	ld	xhl, 2:i3
	jr	t, HDAE5000_LyricJumpEditCheck_Epilogue
HDAE5000_LyricJumpEditCheck_Ev01E00044:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LyricJumpEditCheck_Epilogue
HDAE5000_LyricJumpEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_LyricJump:24)
	jr	t, HDAE5000_LyricJumpEditCheck_Epilogue
HDAE5000_LyricJumpEditCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LyricJumpEditCheck_Epilogue
HDAE5000_LyricJumpEditCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LyricJumpEditCheck_Epilogue
HDAE5000_LyricJumpEditCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LyricJumpEditCheck_Epilogue:
	pop xiz
	ret

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

HDAE5000_LyricForeColorCheck:
	; registered as "LyricForeColorCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_LyricForeColorCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_LyricForeColorCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_LyricForeColorCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LyricForeColorCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LyricForeColorCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LyricForeColorCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_RED_to_YELLOW
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LyricForeColorCheck@hi16
	pushw HDAE5000_Fmt_s_LyricForeColorCheck@lo16		; low half of HDAE5000_Fmt_s_LyricForeColorCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_LyricForeColorCheck_Epilogue
HDAE5000_LyricForeColorCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LyricForeColorCheck_Epilogue
HDAE5000_LyricForeColorCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LyricForeColorCheck_Epilogue
HDAE5000_LyricForeColorCheck_Ev01E00043:
	ld	xhl, 4:i3
	jr	t, HDAE5000_LyricForeColorCheck_Epilogue
HDAE5000_LyricForeColorCheck_Ev01E00044:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LyricForeColorCheck_Epilogue
HDAE5000_LyricForeColorCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_LyricForeColor:24)
	jr	t, HDAE5000_LyricForeColorCheck_Epilogue
HDAE5000_LyricForeColorCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LyricForeColorCheck_Epilogue
HDAE5000_LyricForeColorCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LyricForeColorCheck_Epilogue
HDAE5000_LyricForeColorCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LyricForeColorCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LyricBackColorCheck:
	; registered as "LyricBackColorCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_LyricBackColorCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_LyricBackColorCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_LyricBackColorCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LyricBackColorCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LyricBackColorCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LyricBackColorCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_RED_to_YELLOW_2
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LyricBackColorCheck@hi16
	pushw HDAE5000_Fmt_s_LyricBackColorCheck@lo16		; low half of HDAE5000_Fmt_s_LyricBackColorCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_LyricBackColorCheck_Epilogue
HDAE5000_LyricBackColorCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LyricBackColorCheck_Epilogue
HDAE5000_LyricBackColorCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LyricBackColorCheck_Epilogue
HDAE5000_LyricBackColorCheck_Ev01E00043:
	ld	xhl, 4:i3
	jr	t, HDAE5000_LyricBackColorCheck_Epilogue
HDAE5000_LyricBackColorCheck_Ev01E00044:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LyricBackColorCheck_Epilogue
HDAE5000_LyricBackColorCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_LyricBackColor:24)
	jr	t, HDAE5000_LyricBackColorCheck_Epilogue
HDAE5000_LyricBackColorCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LyricBackColorCheck_Epilogue
HDAE5000_LyricBackColorCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LyricBackColorCheck_Epilogue
HDAE5000_LyricBackColorCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LyricBackColorCheck_Epilogue:
	pop xiz
	ret

HDAE5000_WriteConfirmEditCheck:
	; registered as "WriteConfirmEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_WriteConfirmEditCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_WriteConfirmEditCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_WriteConfirmEditCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_WriteConfirmEditCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_WriteConfirmEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_WriteConfirmEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_OFF_ON
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_WriteConfirmEditCheck@hi16
	pushw HDAE5000_Fmt_s_WriteConfirmEditCheck@lo16		; low half of HDAE5000_Fmt_s_WriteConfirmEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_WriteConfirmEditCheck_Epilogue
HDAE5000_WriteConfirmEditCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_WriteConfirmEditCheck_Epilogue
HDAE5000_WriteConfirmEditCheck_Ev01E00043:
	ld	xhl, 1:i3
	jr	t, HDAE5000_WriteConfirmEditCheck_Epilogue
HDAE5000_WriteConfirmEditCheck_Ev01E00044:
	ld	xhl, 0:i3
	jr	t, HDAE5000_WriteConfirmEditCheck_Epilogue
HDAE5000_WriteConfirmEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_WriteConfirm:24)
	jr	t, HDAE5000_WriteConfirmEditCheck_Epilogue
HDAE5000_WriteConfirmEditCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_WriteConfirmEditCheck_Epilogue
HDAE5000_WriteConfirmEditCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_WriteConfirmEditCheck_Epilogue
HDAE5000_WriteConfirmEditCheck_Default:
	ld	xhl, 0:i3
HDAE5000_WriteConfirmEditCheck_Epilogue:
	pop xiz
	ret

HDAE5000_QuickLoadModeEditCheck:
	; registered as "QuickLoadModeEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_QuickLoadModeEditCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_QuickLoadModeEditCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_QuickLoadModeEditCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_QuickLoadModeEditCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_QuickLoadModeEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_QuickLoadModeEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	push xwa
	pushw HDAE5000_Fmt_1d_QuickLoadModeEditCheck@hi16
	pushw HDAE5000_Fmt_1d_QuickLoadModeEditCheck@lo16		; low half of HDAE5000_Fmt_1d_QuickLoadModeEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_QuickLoadModeEditCheck_Epilogue
HDAE5000_QuickLoadModeEditCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_QuickLoadModeEditCheck_Epilogue
HDAE5000_QuickLoadModeEditCheck_Ev01E00043:
	ld	xhl, 3:i3
	jr	t, HDAE5000_QuickLoadModeEditCheck_Epilogue
HDAE5000_QuickLoadModeEditCheck_Ev01E00044:
	ld	xhl, 1:i3
	jr	t, HDAE5000_QuickLoadModeEditCheck_Epilogue
HDAE5000_QuickLoadModeEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_QuickLoadMode:24)
	jr	t, HDAE5000_QuickLoadModeEditCheck_Epilogue
HDAE5000_QuickLoadModeEditCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_QuickLoadModeEditCheck_Epilogue
HDAE5000_QuickLoadModeEditCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_QuickLoadModeEditCheck_Epilogue
HDAE5000_QuickLoadModeEditCheck_Default:
	ld	xhl, 0:i3
HDAE5000_QuickLoadModeEditCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LoadByNumberModeEditCheck:
	; registered as "LoadByNumberModeEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_LoadByNumberModeEditCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_LoadByNumberModeEditCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_LoadByNumberModeEditCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LoadByNumberModeEditCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LoadByNumberModeEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LoadByNumberModeEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	push xwa
	pushw HDAE5000_Fmt_1d_LoadByNumberModeEditCheck@hi16
	pushw HDAE5000_Fmt_1d_LoadByNumberModeEditCheck@lo16		; low half of HDAE5000_Fmt_1d_LoadByNumberModeEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_LoadByNumberModeEditCheck_Epilogue
HDAE5000_LoadByNumberModeEditCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LoadByNumberModeEditCheck_Epilogue
HDAE5000_LoadByNumberModeEditCheck_Ev01E00043:
	ld	xhl, 2:i3
	jr	t, HDAE5000_LoadByNumberModeEditCheck_Epilogue
HDAE5000_LoadByNumberModeEditCheck_Ev01E00044:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LoadByNumberModeEditCheck_Epilogue
HDAE5000_LoadByNumberModeEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_LoadByNumberMode:24)
	jr	t, HDAE5000_LoadByNumberModeEditCheck_Epilogue
HDAE5000_LoadByNumberModeEditCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LoadByNumberModeEditCheck_Epilogue
HDAE5000_LoadByNumberModeEditCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LoadByNumberModeEditCheck_Epilogue
HDAE5000_LoadByNumberModeEditCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LoadByNumberModeEditCheck_Epilogue:
	pop xiz
	ret

HDAE5000_JumpAfterLoadModeEditCheck:
	; registered as "JumpAfterLoadModeEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jr	z, HDAE5000_JumpAfterLoadModeEditCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_JumpAfterLoadModeEditCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_JumpAfterLoadModeEditCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_JumpAfterLoadModeEditCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	push xwa
	pushw HDAE5000_Fmt_1d_JumpAfterLoadModeEditCheck@hi16
	pushw HDAE5000_Fmt_1d_JumpAfterLoadModeEditCheck@lo16		; low half of HDAE5000_Fmt_1d_JumpAfterLoadModeEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld	xhl, xiz
	jr	t, HDAE5000_JumpAfterLoadModeEditCheck_Epilogue
HDAE5000_JumpAfterLoadModeEditCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_JumpAfterLoadModeEditCheck_Epilogue
HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00043:
	ld	xhl, 2:i3
	jr	t, HDAE5000_JumpAfterLoadModeEditCheck_Epilogue
HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00044:
	ld	xhl, 1:i3
	jr	t, HDAE5000_JumpAfterLoadModeEditCheck_Epilogue
HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_JumpAfterLoad:24)
	jr	t, HDAE5000_JumpAfterLoadModeEditCheck_Epilogue
HDAE5000_JumpAfterLoadModeEditCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_JumpAfterLoadModeEditCheck_Epilogue
HDAE5000_JumpAfterLoadModeEditCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_JumpAfterLoadModeEditCheck_Epilogue
HDAE5000_JumpAfterLoadModeEditCheck_Default:
	ld	xhl, 0:i3
HDAE5000_JumpAfterLoadModeEditCheck_Epilogue:
	pop xiz
	ret


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
HDAE5000_SetupP2SwCatch:
	; registered as "SetupP2SwCatch" in HDAE5000_ScreenProc_Table
	cp xbc, EVT_SW_IN
	jrl nz, .LHD_PS__exit
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xix, (xwa + RootFn_SendEvent)             ; ld XIX, (XWA + 0x0100)
	ld xwa, 0x02600024
	ld xbc, EVT_MAKE_EDIT_SW_ID
	call (xix)
	; Check return value
	cp xhl, 0x0000000c
	jrl z, .LHD_PS__case_0c
	cp xhl, 0x00000009
	jr z, .LHD_PS__case_09
	cp xhl, 0x0000008c
	jrl nz, .LHD_PS__exit
	; Case 0x8C: update display with error code
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_HD_PLEASE
	ld xbc, EVT_SHOW
	ld xde, 5:i3
	call (xhl)
	ld wa, 0:i3
	call HDAE5000_HD_StoreSettings
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_SETUPS_TOOLS
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jr t, .LHD_PS__exit
.LHD_PS__case_09:			; case 0x09: format and validate
	pushw 0x000a
	pushw 0x0000
	lda xwa, (0x22ad9c:24)
	push xwa
	call HDAE5000_MemFill
	inc 8, xsp			; deallocate 8 bytes
	cp (HDAE5000_RAM_WriteProtect:24), 0x00
	jr nz, .LHD_PS__exit
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_ATTEN_HD_FORMAT
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jr t, .LHD_PS__exit
.LHD_PS__case_0c:			; case 0x0C: recursive re-setup
	calr HDAE5000_SetupPage_BuildDriveInfo
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_SETUP_HDINFO
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
.LHD_PS__exit:
	ld xhl, 0:i3
	ret

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
HDAE5000_Lbn_StepDigit:
	pushw iz                                ; push iz (compact)
	ld hl, (xsp + 0x06)		; HL = param from stack
	ld de, wa			; DE = input digit
	ld wa, (HDAE5000_RAM_LbnDigitPos:24); load current state
	cp wa, 5:i3			; state >= 6? (unsigned)
	jrl ugt, .LHD_SR__apply	; yes → apply values
	add wa, wa			; state * 2
	lda xix, (HDAE5000_Lbn_StepDigit_CaseTable:24); jump table base
	ld	wa, (xix+wa)
	lda xix, (HDAE5000_Lbn_StepDigit_NoDigitTyped:24); dispatch base
	jp	t, (xix+wa)
	; Case 0 (offset 0x0000): jump to FS_Init directly
; HDAE5000_Lbn_StepDigit_NoDigitTyped: nothing typed yet: no step and no redraw
HDAE5000_Lbn_StepDigit_NoDigitTyped:
	jrl t, .LHD_SR__cleanup
	; Case 1 (offset 0x0003): directory hundreds digit
; HDAE5000_Lbn_StepDigit_DirHundreds: step the directory number by 100, clamped to 0..100
HDAE5000_Lbn_StepDigit_DirHundreds:
	ld wa, hl
	muls wa, 0x0064			; WA = digit * 100
	add de, wa			; DE += WA
	cp de, 0x0064			; DE >= 100?
	jr lt, .LHD_SR__c1_lo
	ldw de, 0x0064			; clamp to 100
	jr t, .LHD_SR__apply
.LHD_SR__c1_lo:
	cp de, 0:i3			; DE > 0?
	jr gt, .LHD_SR__apply
	ld de, 0:i3			; clamp to 0
	jr t, .LHD_SR__apply
	; Case 2 (offset 0x001E): directory tens digit
; HDAE5000_Lbn_StepDigit_DirTens: step the directory number by 10, at most 120 (1 or less becomes 0)
HDAE5000_Lbn_StepDigit_DirTens:
	ld wa, hl
	muls wa, 0x000a			; WA = digit * 10
	add de, wa
	cp de, 0x0078			; DE >= 120?
	jr lt, .LHD_SR__c2_lo
	ldw de, 0x0078			; clamp to 120
	jr t, .LHD_SR__apply
.LHD_SR__c2_lo:
	cp de, 1:i3			; DE > 1?
	jr gt, .LHD_SR__apply
	ld de, 0:i3
	jr t, .LHD_SR__apply
	; Case 3 (offset 0x0039): directory units digit
; HDAE5000_Lbn_StepDigit_DirUnits: step the directory number by 1, clamped to 1..120
HDAE5000_Lbn_StepDigit_DirUnits:
	add de, hl
	cp de, 0x0078
	jr le, .LHD_SR__c3_lo
	ldw de, 0x0078
	jr t, .LHD_SR__apply
.LHD_SR__c3_lo:
	cp de, 0:i3
	jr gt, .LHD_SR__apply
	ld de, 1:i3
	jr t, .LHD_SR__apply
	; Case 4 (offset 0x004E): song tens digit
; HDAE5000_Lbn_StepDigit_SongTens: step the song number by 10, clamped to 0..10
HDAE5000_Lbn_StepDigit_SongTens:
	ld wa, hl
	muls wa, 0x000a
	add bc, wa
	cp bc, 0x000a			; BC >= 10?
	jr lt, .LHD_SR__c4_lo
	ldw bc, 0x000a
	jr t, .LHD_SR__apply
.LHD_SR__c4_lo:
	cp bc, 0:i3
	jr gt, .LHD_SR__apply
	ld bc, 0:i3
	jr t, .LHD_SR__apply
	; Case 5 (offset 0x0069): song units digit
; HDAE5000_Lbn_StepDigit_SongUnits: step the song number by 1, clamped to 1..16; the complete number is then looked up
;   (HDAE5000_Song_PartMask)
HDAE5000_Lbn_StepDigit_SongUnits:
	add bc, hl
	cp bc, 0x0010			; BC >= 16?
	jr le, .LHD_SR__c5_lo
	ldw bc, 0x0010
	jr t, .LHD_SR__apply
.LHD_SR__c5_lo:
	cp bc, 0:i3
	jr gt, .LHD_SR__apply
	ld bc, 1:i3
.LHD_SR__apply:				; store results
	ld (HDAE5000_RAM_LbnDir:24), de; store the directory number
	ld (HDAE5000_RAM_LbnSong:24), bc; store the song number
	cpw (HDAE5000_RAM_LbnDigitPos:24), 0x0005; state == 5?
	jr nz, .LHD_SR__fs_init
	; State 5: complete — do table lookup and seek
	ld wa, (HDAE5000_RAM_LbnDir:24)
	dec 1, wa
	ld (HDAE5000_RAM_CurDir:24), wa
	ld wa, (HDAE5000_RAM_LbnSong:24)
	dec 1, wa
	ld (HDAE5000_RAM_CurSong:24), wa
	ld wa, (HDAE5000_RAM_CurDir:24)
	ld bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_PartMask
	ld iz, hl
	ld wa, iz
	cp wa, 0xffff
	jr z, .LHD_SR__no_match
	; Match found — copy data and seek
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	ld bc, iz
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	calr HDAE5000_TypeSel_Init
	ld bc, (HDAE5000_RAM_CurDir:24)
	ld de, (HDAE5000_RAM_CurSong:24)
	ld wa, iz
	pushw wa                                ; push wa (compact)
	ld xwa, HDAE5000_OBJ_LBN_OPTION
	calr HDAE5000_PartList_Build
	jr t, .LHD_SR__fs_init
.LHD_SR__no_match:			; No match — clear and seek with 0xFFFF
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	ld bc, 0:i3
	calr HDAE5000_TypeSel_Init
	pushw 0xffff
	ld xwa, HDAE5000_OBJ_LBN_OPTION
	ldw bc, 0xffff
	ldw de, 0xffff
	calr HDAE5000_PartList_Build
.LHD_SR__fs_init:			; Re-init filesystem display
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24)
	ld bc, (HDAE5000_RAM_LbnSong:24)
	ld de, (HDAE5000_RAM_LbnDigitPos:24)
	calr HDAE5000_Lbn_ShowEntry
.LHD_SR__cleanup:
	popw iz                                 ; pop iz (compact)
	retd 0x0002			; return, dealloc 2 bytes
	;
	; Part 2: Event handler A (0x286B72)
HDAE5000_LBNPage1SwCatch:
	; registered as "LBNPage1SwCatch" in HDAE5000_ObjHandler_Table
	dec 8, xsp			; alloc 8 bytes
	push xiz
	ld (xsp + 0x04), xde
	ld (xsp + 0x08), xbc
	ld xiz, xwa
	ld xwa, (xsp + 0x08)		; XWA = event code
	cp xwa, EVT_SW_IN
	jr z, .LHD_SR__a_evt07
	cp xwa, EVT_DRAW
	jr z, .LHD_SR__a_evt0d
	cp xwa, EVT_ARE_YOU_CLASS_PROC
	jrl nz, .LHD_SR__a_exit
	ld xhl, 1:i3			; event 0x85: XHL = 1
	jrl t, .LHD_SR__a_epilogue
.LHD_SR__a_evt0d:			; event 0x0D: display update
	ld xwa, xiz
	ld xbc, (xsp + 0x08)
	ld xde, (xsp + 0x04)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)
	ld_sril xhl, (xhl + RootFn_InheritedProc)
	call (xhl)
	lda xwa, (HDAE5000_Str_LBNS:24)
	ld xbc, xwa
	ld xwa, xiz
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	ld xhl, 0:i3
	jrl t, .LHD_SR__a_epilogue
.LHD_SR__a_evt07:			; event 0x07: jump table dispatch
	ld xde, (xsp + 0x04)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xix, (xwa + RootFn_SendEvent)
	ld xwa, 0x02600024
	ld xbc, EVT_MAKE_EDIT_SW_ID
	call (xix)
	ld xwa, xhl
	cp xwa, 0x0000000c		; case > 12?
	jrl ugt, .LHD_SR__a_exit
	add xwa, xwa			; index * 2
	add xwa, HDAE5000_LBNPage1SwCatch_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_LBNPage1SwCatch_OnClear:24); dispatch base
	jp	t, (xix+wa)
	; Case 0: re-init FS
; HDAE5000_LBNPage1SwCatch_OnClear: edit switch 12, the CLEAR key: reset the load-by-number entry (Lbn_ShowEntry
;   position 6)
HDAE5000_LBNPage1SwCatch_OnClear:
	pushw 0x0001
	ld wa, 0:i3
	ld bc, 0:i3
	ld de, 6:i3
	calr HDAE5000_Lbn_ShowEntry
	jrl t, .LHD_SR__a_exit
	; edit switches 5-7 (the CHS-era reading "toggle read/write direction" was wrong)
; HDAE5000_LBNPage1SwCatch_OnStepDigit: edit switches 5-7: step the last typed digit +1 (switch code bit 7 clear) or
;   -1 (set)
HDAE5000_LBNPage1SwCatch_OnStepDigit:
	ld xwa, (xsp + 0x04)
	bit 0x07, wa			; bit 7?
	jr nz, .LHD_SR__a_c1_set
	ld wa, 1:i3
	jr t, .LHD_SR__a_c1_push
.LHD_SR__a_c1_set:
	ldw wa, 0xffff
.LHD_SR__a_c1_push:
	pushw wa                                ; push wa
	ld wa, (HDAE5000_RAM_LbnDir:24)
	ld bc, (HDAE5000_RAM_LbnSong:24)
	ld de, (HDAE5000_RAM_LbnDigitPos:24)
	calr HDAE5000_Lbn_StepDigit	; recursive call
	jrl t, .LHD_SR__a_exit
	; edit switch 0: digit 0 or 1
; HDAE5000_LBNPage1SwCatch_OnDigit0Or1: edit switch 0: type digit 0 (lower half, switch code bit 7 set) or 1 (upper
;   half)
HDAE5000_LBNPage1SwCatch_OnDigit0Or1:
	ld xwa, (xsp + 0x04)
	bit 0x07, wa
	jr z, .LHD_SR__a_c2b
	ld xwa, xiz
	ld bc, 0:i3
	calr HDAE5000_Lbn_TypeDigit
	jr t, .LHD_SR__a_exit
.LHD_SR__a_c2b:
	ld xwa, xiz
	ld bc, 1:i3
	calr HDAE5000_Lbn_TypeDigit
	jr t, .LHD_SR__a_exit
	; edit switch 1: digit 2 or 3
; HDAE5000_LBNPage1SwCatch_OnDigit2Or3: edit switch 1: type digit 2 (lower half, switch code bit 7 set) or 3 (upper
;   half)
HDAE5000_LBNPage1SwCatch_OnDigit2Or3:
	ld xwa, (xsp + 0x04)
	bit 0x07, wa
	jr z, .LHD_SR__a_c3b
	ld xwa, xiz
	ld bc, 2:i3
	calr HDAE5000_Lbn_TypeDigit
	jr t, .LHD_SR__a_exit
.LHD_SR__a_c3b:
	ld xwa, xiz
	ld bc, 3:i3
	calr HDAE5000_Lbn_TypeDigit
	jr t, .LHD_SR__a_exit
	; edit switch 2: digit 4 or 5
; HDAE5000_LBNPage1SwCatch_OnDigit4Or5: edit switch 2: type digit 4 (lower half, switch code bit 7 set) or 5 (upper
;   half)
HDAE5000_LBNPage1SwCatch_OnDigit4Or5:
	ld xwa, (xsp + 0x04)
	bit 0x07, wa
	jr z, .LHD_SR__a_c4b
	ld xwa, xiz
	ld bc, 4:i3
	calr HDAE5000_Lbn_TypeDigit
	jr t, .LHD_SR__a_exit
.LHD_SR__a_c4b:
	ld xwa, xiz
	ld bc, 5:i3
	calr HDAE5000_Lbn_TypeDigit
	jr t, .LHD_SR__a_exit
	; edit switch 3: digit 6 or 7
; HDAE5000_LBNPage1SwCatch_OnDigit6Or7: edit switch 3: type digit 6 (lower half, switch code bit 7 set) or 7 (upper
;   half)
HDAE5000_LBNPage1SwCatch_OnDigit6Or7:
	ld xwa, (xsp + 0x04)
	bit 0x07, wa
	jr z, .LHD_SR__a_c5b
	ld xwa, xiz
	ld bc, 6:i3
	calr HDAE5000_Lbn_TypeDigit
	jr t, .LHD_SR__a_exit
.LHD_SR__a_c5b:
	ld xwa, xiz
	ld bc, 7:i3
	calr HDAE5000_Lbn_TypeDigit
	jr t, .LHD_SR__a_exit
	; edit switch 4: digit 8 or 9
; HDAE5000_LBNPage1SwCatch_OnDigit8Or9: edit switch 4: type digit 8 (lower half, switch code bit 7 set) or 9 (upper
;   half)
HDAE5000_LBNPage1SwCatch_OnDigit8Or9:
	ld xwa, (xsp + 0x04)
	bit 0x07, wa
	jr z, .LHD_SR__a_c6b
	ld xwa, xiz
	ldw bc, 0x0008
	calr HDAE5000_Lbn_TypeDigit
	jr t, .LHD_SR__a_exit
.LHD_SR__a_c6b:
	ld xwa, xiz
	ldw bc, 0x0009
	calr HDAE5000_Lbn_TypeDigit
.LHD_SR__a_exit:			; common exit for handler A
	ld xwa, xiz
	ld xbc, (xsp + 0x08)
	ld xde, (xsp + 0x04)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)
	ld_sril xix, (xhl + RootFn_InheritedProc)
	call (xix)
.LHD_SR__a_epilogue:
	pop xiz
	inc 8, xsp
	ret
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
