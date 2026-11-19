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
HDAE5000_TitleInfo_Build:
	lda	xsp, (xsp-32)

	; --- Format CHS display strings ---
	; Block 1: cylinder type (0x229d99) → display buffer 0x22ada6
	pushw 0x0097
	lda xwa, (HDAE5000_TitleInfo_Template:24); f2 d2 1a 2e 30
	push xwa				; 38
	lda xwa, (HDAE5000_RAM_TitleInfoText:24); f2 a6 ad 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	ld a, (HDAE5000_RAM_WriteProtect:24)
	extz wa					; d8 12
	sla wa, 2				; d8 ec 02
	lda xbc, (HDAE5000_TextPtrs_OFF_ON:24); f2 4a 16 2e 31
	ld	xwa, (xbc+wa)		; e3 07 e4 e0 20 — ld xwa, (xbc+wa)
	push xwa				; 38
	pushw	HDAE5000_Fmt_s@hi16
	pushw	HDAE5000_Fmt_s@lo16		; low half of HDAE5000_Fmt_s
	lda xwa, (xsp + 0x12)			; bf 12 30
	push xwa				; 38
	call HDAE5000_SPrintf		; 1d a0 a4 29
	lda xwa, (xsp + 0x16)			; bf 16 30
	push xwa				; 38
	call HDAE5000_StrLen				; 1d 71 af 29 — Display_Buffer_Validate
	lda xsp, (xsp + 0x1a)			; bf 1a 37

	; Block 2: heads (0x229d9a) → display buffer 0x22adba
	pushw hl                                ; push hl (compact 16-bit)
	lda xwa, (xsp + 0x02)			; bf 02 30
	push xwa				; 38
	lda xwa, (0x22adba:24); f2 ba ad 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	ld a, (HDAE5000_RAM_WriteConfirm:24)
	extz wa					; d8 12
	sla wa, 2				; d8 ec 02
	lda xbc, (HDAE5000_TextPtrs_OFF_ON:24); f2 4a 16 2e 31
	ld	xwa, (xbc+wa)		; e3 07 e4 e0 20 — ld xwa, (xbc+wa)
	push xwa				; 38
	pushw	HDAE5000_Fmt_s_TitleInfo_Build@hi16
	pushw	HDAE5000_Fmt_s_TitleInfo_Build@lo16		; low half of HDAE5000_Fmt_s_TitleInfo_Build
	lda xwa, (xsp + 0x12)			; bf 12 30
	push xwa				; 38
	call HDAE5000_SPrintf		; 1d a0 a4 29
	lda xwa, (xsp + 0x16)			; bf 16 30
	push xwa				; 38
	call HDAE5000_StrLen				; 1d 71 af 29 — Display_Buffer_Validate
	lda xsp, (xsp + 0x1a)			; bf 1a 37

	; Block 3: sectors (0x229daa) → display buffer 0x22adec
	pushw hl                                ; push hl (compact 16-bit)
	lda xwa, (xsp + 0x02)			; bf 02 30
	push xwa				; 38
	lda xwa, (0x22adec:24); f2 ec ad 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	ld a, (HDAE5000_RAM_LoadByNumberMode:24)
	extz wa					; d8 12
	pushw wa                                ; push wa (compact 16-bit)
	pushw HDAE5000_Fmt_d@hi16
	pushw	HDAE5000_Fmt_d@lo16		; low half of HDAE5000_Fmt_d
	lda xwa, (xsp + 0x10)			; bf 10 30
	push xwa				; 38
	call HDAE5000_SPrintf		; 1d a0 a4 29
	lda xwa, (xsp + 0x14)			; bf 14 30
	push xwa				; 38
	call HDAE5000_StrLen				; 1d 71 af 29 — Display_Buffer_Validate
	lda xsp, (xsp + 0x18)			; bf 18 37

	; Block 4: cylinder count high (0x229da9) → display buffer 0x22ae1e
	pushw hl                                ; push hl (compact 16-bit)
	lda xwa, (xsp + 0x02)			; bf 02 30
	push xwa				; 38
	lda xwa, (0x22ae1e:24); f2 1e ae 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	ld a, (HDAE5000_RAM_QuickLoadMode:24)
	extz wa					; d8 12
	pushw wa                                ; push wa (compact 16-bit)
	pushw HDAE5000_Fmt_d_TitleInfo_Build@hi16
	pushw	HDAE5000_Fmt_d_TitleInfo_Build@lo16		; low half of HDAE5000_Fmt_d_TitleInfo_Build
	lda xwa, (xsp + 0x10)			; bf 10 30
	push xwa				; 38
	call HDAE5000_SPrintf		; 1d a0 a4 29
	lda xwa, (xsp + 0x14)			; bf 14 30
	push xwa				; 38
	call HDAE5000_StrLen				; 1d 71 af 29 — Display_Buffer_Validate
	lda xsp, (xsp + 0x18)			; bf 18 37

	; Block 5: cylinder count (0x229dab) → display buffer 0x22add1
	pushw hl                                ; push hl (compact 16-bit)
	lda xwa, (xsp + 0x02)			; bf 02 30
	push xwa				; 38
	lda xwa, (0x22add1:24); f2 d1 ad 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	ld a, (HDAE5000_RAM_JumpAfterLoad:24)
	extz wa					; d8 12
	pushw wa                                ; push wa (compact 16-bit)
	pushw HDAE5000_Fmt_d_TitleInfo_Build_2@hi16
	pushw	HDAE5000_Fmt_d_TitleInfo_Build_2@lo16		; low half of HDAE5000_Fmt_d_TitleInfo_Build_2
	lda xwa, (xsp + 0x10)			; bf 10 30
	push xwa				; 38
	call HDAE5000_SPrintf		; 1d a0 a4 29
	lda xwa, (xsp + 0x14)			; bf 14 30
	push xwa				; 38
	call HDAE5000_StrLen				; 1d 71 af 29 — Display_Buffer_Validate
	lda xsp, (xsp + 0x18)			; bf 18 37

	; Block 6: total size string → display buffer 0x22ae03
	pushw hl                                ; push hl (compact 16-bit)
	lda xwa, (xsp + 0x02)			; bf 02 30
	push xwa				; 38
	lda xwa, (0x22ae03:24); f2 03 ae 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	lda xsp, (xsp + 0x0a)			; bf 0a 37

	; Compute capacity: divide total sectors by 100
	lda xwa, (xsp + 0x10)			; bf 10 30
	call HDAE5000_HD_GetDiskUsage				; 1d 54 84 29
	ld xwa, (xsp + 0x1c)			; af 1c 20 — load dividend
	ld xbc, 0x00000064			; 41 64 00 00 00 — divisor = 100
	call HDAE5000_UDivMod32		; 1d 8d b1 29
	push xhl				; 3b — push remainder
	pushw	HDAE5000_Fmt_4ldMB@hi16
	pushw	HDAE5000_Fmt_4ldMB@lo16		; low half of HDAE5000_Fmt_4ldMB
	lda xwa, (xsp + 0x08)			; bf 08 30
	push xwa				; 38
	call HDAE5000_SPrintf		; 1d a0 a4 29
	lda xwa, (xsp + 0x0c)			; bf 0c 30
	push xwa				; 38
	call HDAE5000_StrLen				; 1d 71 af 29 — Display_Buffer_Validate

	; Block 7: capacity text → display buffer 0x22ae35
	pushw hl                                ; push hl (compact 16-bit)
	lda xwa, (xsp + 0x12)			; bf 12 30
	push xwa				; 38
	lda xwa, (0x22ae35:24); f2 35 ae 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	lda xsp, (xsp + 0x1a)			; bf 1a 37

	; --- Register event handlers ---
	; EVT_HDAE_SET_STR_ADR (MT_SetStrAdr, 0x01EA000A): give the list its row-string table
	lda xwa, (HDAE5000_RAM_TitleInfoText:24); f2 a6 ad 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23 — ld xhl, (xwa+0x0100)
	ld xwa, HDAE5000_OBJ_HARD_DISK_OPT			; 40 0a 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR			; 41 0a 00 ea 01
	call (xhl)				; b3 e8

	; Register event 0x01C0000F with XDE=0xFFFFFFFF (deregister)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23 — ld xhl, (xwa+0x0100)
	ld xwa, HDAE5000_OBJ_HARD_DISK_OPT			; 40 0a 00 7f 00
	ld xbc, EVT_PARA_DRAW			; 41 0f 00 c0 01
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8

	; --- Epilogue ---
	lda xsp, (xsp + 0x20)			; bf 20 37
	ret					; 0e

; --- Event handler sub-function ---
HDAE5000_HdTitleEventCatch:	.include "includes/generated/cc900/HDAE5000_HdTitleEventCatch.s"	; C: cc900/hdae5000_title_info.c

; --- Jump table dispatcher sub-function ---
HDAE5000_HDAETitleFunc:
	; registered as "HDAETitleFunc" in HDAE5000_ScreenProc_Table
	cp xbc, EVT_ACTIVATE_STATE			; e9 cf 13 00 c0 01
	jrl nz, .Lri_done			; 7e xx xx
	ld xwa, xde				; ea 88
	dec 2, xwa				; e8 6a — subtract 2 (cases start at 2)
	cp xwa, 0x00000000			; e8 cf 00 00 00 00
	jrl c, .Lri_done			; 77 xx xx — unsigned < 0
	cp xwa, 0x00000007			; e8 cf 07 00 00 00
	jrl ugt, .Lri_done			; 7b xx xx — > 7
	add xwa, xwa				; e8 80 — multiply by 2 (word offsets)
	add xwa, HDAE5000_HDAETitleFunc_CaseTable			; e8 c8 ac 23 2e 00 — add table base
	ld wa, (xwa)				; 90 20 — load 16-bit jump offset
	lda xix, (.Lri_jt_base:24); f2 4b 35 28 34 — jump base
	jp	t, (xix+wa)	; jp t, (xix+wa) — F3 indexed jump

	; === Case 2: main setup — read/write, format, init filesystem ===
.Lri_jt_base:					; (jump table base)
	ld (0x22ae3c:24), 0x00; f2 3c ae 22 00 00
	lda xwa, (HDAE5000_RAM_TitleInfoText:24); f2 a6 ad 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_HARD_DISK_OPT			; 40 0a 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR			; 41 0a 00 ea 01
	call (xhl)				; b3 e8
	ld wa, 0:i3				; d8 a8
	ld bc, 0:i3				; d9 a8
	calr HDAE5000_SongScreen_Refresh		; 1e xx xx

	ld (0x22aa4a:24), 0x00; f2 4a aa 22 00 00
	lda xwa, (HDAE5000_RAM_FlsListText:24); f2 ca a2 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_SEL_FLS			; 40 fd 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR			; 41 0a 00 ea 01
	call (xhl)				; b3 e8
	ld wa, 0:i3				; d8 a8
	ld bc, 2:i3				; d9 aa
	calr HDAE5000_FlsScreen_Refresh		; 1e xx xx

	ld (HDAE5000_RAM_DirListText+504:24), 0x00; f2 c8 a2 22 00 00
	lda xwa, (HDAE5000_RAM_DirListText:24); f2 d0 a0 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_SEL_DIR			; 40 26 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR			; 41 0a 00 ea 01
	call (xhl)				; b3 e8
	ld xwa, HDAE5000_OBJ_SEL_DIR			; 40 26 00 7f 00
	calr HDAE5000_DirList_BuildPage		; 1e xx xx
	calr HDAE5000_FlsList_BuildPage		; 1e xx xx
	pushw 0x0000
	ld wa, 0:i3				; d8 a8
	ld bc, 0:i3				; d9 a8
	ld de, 6:i3				; da ae
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx

	; Copy volume label string
	pushw 0x0021
	lda xwa, (HDAE5000_Str_STATUS:24); f2 f4 15 2e 30
	push xwa				; 38
	lda xwa, (HDAE5000_RAM_PcLinkStatusText:24); f2 c4 ab 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	lda xsp, (xsp + 0x0a)			; bf 0a 37

	; Register event for volume label display
	lda xwa, (HDAE5000_RAM_PcLinkStatusText:24); f2 c4 ab 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_PP_STATUS			; 40 69 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR			; 41 0a 00 ea 01
	call (xhl)				; b3 e8

	; Set initial disk status
	ld xwa, HDAE5000_OBJ_HDDMENU			; 40 00 00 7f 00
	ld (HDAE5000_RAM_Browser_State+12:24), xwa; f2 22 a0 23 60
	cp (HDAE5000_RAM_FlsAutoLoadPending:24), 0x01; c2 9a ad 22 3f 01
	jrl nz, .Lri_done			; 7e xx xx
	cp (HDAE5000_RAM_FlsSeqStopPending:24), 0x01; c2 9b ad 22 3f 01
	jrl nz, .Lri_done			; 7e xx xx
	ld xwa, HDAE5000_OBJ_FLS_FILE_LOAD			; 40 3c 01 7f 00
	ld (HDAE5000_RAM_Browser_State+12:24), xwa; f2 22 a0 23 60
	jrl t, .Lri_done			; 78 xx xx

	; === Case 9: check cylinder count, set disk capacity ===
.Lri_case9:
	ld a, (HDAE5000_RAM_QuickLoadMode:24)
	cp a, 3:i3				; c9 db
	jr z, .Lri_case9_cyl3			; 66 xx
	cp a, 2:i3				; c9 da
	jr z, .Lri_case9_cyl2			; 66 xx
	cp a, 1:i3				; c9 d9
	jrl nz, .Lri_done			; 7e xx xx
	ld xwa, HDAE5000_OBJ_SELECT_FILE			; 40 19 00 7f 00
	ld (HDAE5000_RAM_Browser_State+12:24), xwa; f2 22 a0 23 60
	jrl t, .Lri_done			; 78 xx xx

.Lri_case9_cyl2:
	ld xwa, HDAE5000_OBJ_LOAD_BY_NUM			; 40 91 00 7f 00
	ld (HDAE5000_RAM_Browser_State+12:24), xwa; f2 22 a0 23 60
	jrl t, .Lri_done			; 78 xx xx

.Lri_case9_cyl3:
	ld xwa, HDAE5000_OBJ_FLS_FILE_LOAD			; 40 3c 01 7f 00
	ld (HDAE5000_RAM_Browser_State+12:24), xwa; f2 22 a0 23 60
	jrl t, .Lri_done			; 78 xx xx

	; === Case 8: dispatch event to sub-device ===
.Lri_case8:
	ld xwa, (HDAE5000_RAM_Browser_State+12:24); e2 22 a0 23 20
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 21
	ld xbc, (xbc + WS_RootFnTable)             ; e3 e5 0a 0e 21 — ld xbc, (xbc+0x0e0a)
	ld xhl, (xbc + RootFn_ApPostEvent)             ; e3 e5 24 01 23 — ld xhl, (xbc+0x0124)
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8

	; Deregister event 0x01C00018
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, 0xffffffff			; 40 ff ff ff ff
	ld xbc, EVT_INDEXSW_DOWN			; 41 18 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8

	; an FLS AUTO LOAD chain is pending and the sequencer stopped meanwhile?
	cp (HDAE5000_RAM_FlsAutoLoadPending:24), 0x01; c2 9a ad 22 3f 01
	jr nz, .Lri_done			; 6e xx
	cp (HDAE5000_RAM_FlsSeqStopPending:24), 0x01; c2 9b ad 22 3f 01
	jr nz, .Lri_done			; 6e xx

	; then clear the stop flag and post EVT_HDAE_SEQ_STOP to the FLS load page
	ld (HDAE5000_RAM_FlsSeqStopPending:24), 0x00; f2 9b ad 22 00 00
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_FLS_FILE_LOAD			; 40 3c 01 7f 00
	ld xbc, EVT_HDAE_SEQ_STOP			; 41 00 00 ca 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	jr t, .Lri_done				; 68 xx

	; === Case 6: init flag check, set disk size from table ===
.Lri_case6:
	call HDAE5000_Get_Init_Flag		; 1d 23 ef 28
	ld a, l					; cf 89
	extz wa					; d8 12
	sla wa, 2				; d8 ec 02
	lda xbc, (HDAE5000_HDAETitleFunc_ObjIds:24); f2 96 1b 2e 31
	ld	xwa, (xbc+wa)		; e3 07 e4 e0 20 — ld xwa, (xbc+wa)
	ld (HDAE5000_RAM_Browser_State+12:24), xwa; f2 22 a0 23 60

	; === Common exit ===
.Lri_done:
	ld xhl, 0:i3				; eb a8
	ret					; 0e

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
HDAE5000_DirList_BuildPage:	.include "includes/generated/cc900/HDAE5000_DirList_BuildPage.s"	; C: cc900/hdae5000_list_pages.c

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
HDAE5000_SongScreen_Refresh:
	lda	xsp, (xsp-26)
	pushw iz
	ld	(xsp+24), c
	ld	(xsp+26), a
	cp	(xsp+24), 0x00
	jrl	nz, HDAE5000_SongScreen_Refresh_Join
	pushw 0x0020
	pushw 0x0000
	lda xwa, (HDAE5000_RAM_SongScreenTitle:24)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_DIRECTORY@hi16
	pushw	HDAE5000_Str_DIRECTORY@lo16		; low half of HDAE5000_Str_DIRECTORY
	pushw	0x0022
	pushw	0xa038
	call HDAE5000_StrCat
	ld	wa, (HDAE5000_RAM_CurDir:24)
	inc	1, wa
	pushw wa
	pushw HDAE5000_Fmt_2_2d_SongScreen_Refresh@hi16
	pushw	HDAE5000_Fmt_2_2d_SongScreen_Refresh@lo16		; low half of HDAE5000_Fmt_2_2d_SongScreen_Refresh
	lda	xwa, (xsp+24)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+26)
	lda	xwa, (xsp+2)
	push xwa
	pushw 0x0022
	pushw 0xa038
	call HDAE5000_StrCat
	pushw	HDAE5000_Str_Chr3A_SongScreen_Refresh@hi16
	pushw	HDAE5000_Str_Chr3A_SongScreen_Refresh@lo16		; low half of HDAE5000_Str_Chr3A_SongScreen_Refresh
	pushw	0x0022
	pushw	0xa038
	call HDAE5000_StrCat
	lda	xsp, (xsp+16)
	pushw 0x0010
	ld	wa, (HDAE5000_RAM_CurDir:24)
	call HDAE5000_DirName_Address
	push xhl
	pushw 0x0022
	pushw 0xa038
	call HDAE5000_StrNCat
	pushw	HDAE5000_Str_Blank0Tab@hi16
	pushw	HDAE5000_Str_Blank0Tab@lo16		; low half of HDAE5000_Str_Blank0Tab
	pushw	0x0022
	pushw	0xa038
	call HDAE5000_StrCat
	lda	xsp, (xsp+18)
	ld	a, (xsp+26)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_SongScreen_Refresh_ObjIds:24)
	ld	xde, (xbc+wa)
	lda xwa, (HDAE5000_RAM_SongScreenTitle:24)
	ld	xbc, xwa
	ld	xwa, xde
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_ApPostEvent)
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	a, (xsp+26)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_SongScreen_Refresh_ObjIds:24)
	ld	xwa, (xbc+wa)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_ApPostEvent)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
HDAE5000_SongScreen_Refresh_Join:
	cp	(xsp+24), 0x00
	jrl	nz, HDAE5000_SongScreen_Refresh_Join3
	ld	iz, 0:i3
	cp	iz, 0x0010
	jr	ge, HDAE5000_SongScreen_Refresh_Join2
HDAE5000_SongScreen_Refresh_Loop:
	pushw 0x001c
	lda xwa, (HDAE5000_Str_Chr3A2020202020:24)
	push xwa
	ldw	wa, 0x001e
	muls	xwa, iz
	lda xbc, (HDAE5000_RAM_SongListText+2:24)
	exts xwa
	add	xwa, xbc
	push xwa
	call HDAE5000_MemCopy
	ld	wa, iz
	inc	1, wa
	pushw wa
	pushw HDAE5000_Fmt_2_2d_SongScreen_Refresh_2@hi16
	pushw	HDAE5000_Fmt_2_2d_SongScreen_Refresh_2@lo16		; low half of HDAE5000_Fmt_2_2d_SongScreen_Refresh_2
	lda	xwa, (xsp+18)
	push xwa
	call HDAE5000_SPrintf
	pushw 0x0002
	lda	xwa, (xsp+24)
	push xwa
	ldw	wa, 0x001e
	muls	xwa, iz
	lda xbc, (HDAE5000_RAM_SongListText:24)
	exts xwa
	add	xwa, xbc
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+30)
	ld	bc, iz
	ld	wa, (HDAE5000_RAM_CurDir:24)
	call HDAE5000_SongRecord_Address
	pushw 0x001a
	push xhl
	ldw	wa, 0x001e
	muls	xwa, iz
	lda xbc, (HDAE5000_RAM_SongListText+3:24)
	exts xwa
	add	xwa, xbc
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	inc	1, iz
	cp	iz, 0x0010
	jr	lt, HDAE5000_SongScreen_Refresh_Loop
HDAE5000_SongScreen_Refresh_Join2:
	ld	a, (xsp+26)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_SongScreen_Refresh_ObjIds_2:24)
	ld	xde, (xbc+wa)
	lda xwa, (HDAE5000_RAM_SongListText:24)
	ld	xbc, xwa
	ld	xwa, xde
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_ApPostEvent)
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	a, (xsp+26)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_SongScreen_Refresh_ObjIds_2:24)
	ld	xwa, (xbc+wa)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_ApPostEvent)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
HDAE5000_SongScreen_Refresh_Join3:
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_PartMask
	ld	wa, hl
	cp	wa, 0xffff
	jr	z, HDAE5000_SongScreen_Refresh_Skip
	ld	a, (xsp+26)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_SongScreen_Refresh_ObjIds_3:24)
	ld	xwa, (xbc+wa)
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	pushw hl
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_SongScreen_Refresh_Epilogue
HDAE5000_SongScreen_Refresh_Skip:
	ld	a, (xsp+26)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_SongScreen_Refresh_ObjIds_3:24)
	ld	xwa, (xbc+wa)
	pushw 0xffff
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_SongScreen_Refresh_Epilogue:
	popw iz
	lda	xsp, (xsp+26)
	ret

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

HDAE5000_HDDNamingCheck:
	; registered as "HDDNamingCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	cp	xbc, EVT_SW_IN
	jr	z, HDAE5000_HDDNamingCheck_OnSwIn
	cp	xbc, EVT_GET_STRING_LENGTH
	jr	z, HDAE5000_HDDNamingCheck_OnGetStringLength
	cp	xbc, EVT_GET_NAMING_MODE
	jr	z, HDAE5000_HDDNamingCheck_OnGetNamingMode
	cp	xbc, EVT_SET_STRING
	jr	z, HDAE5000_HDDNamingCheck_OnSetString
	cp	xbc, EVT_GET_STRING
	jrl	nz, HDAE5000_HDDNamingCheck_Done
	pushw 0x001a
	lda xwa, (HDAE5000_RAM_Name_ColumnRuler:24)
	push xwa
	push xde
	call HDAE5000_StrNCpy
	lda	xsp, (xsp+10)
	ld	xhl, xiz
	jrl	t, HDAE5000_HDDNamingCheck_Epilogue
HDAE5000_HDDNamingCheck_OnSetString:
	pushw 0x001a
	push xde
	pushw 0x0023
	pushw 0x9fd6
	call HDAE5000_StrNCpy
	lda	xsp, (xsp+10)
	ld	xhl, xiz
	jrl	t, HDAE5000_HDDNamingCheck_Epilogue
HDAE5000_HDDNamingCheck_OnGetNamingMode:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_HDDNamingCheck_Epilogue
HDAE5000_HDDNamingCheck_OnGetStringLength:
	ld	xhl, 0x0000001a
	jrl	t, HDAE5000_HDDNamingCheck_Epilogue
HDAE5000_HDDNamingCheck_OnSwIn:
	cp	xde, 0x0000000b
	jrl	z, HDAE5000_HDDNamingCheck_Skip3
	cp	xde, 0x0000000a
	jr	z, HDAE5000_HDDNamingCheck_Skip
	cp	xde, 0x0000008a
	jrl	nz, HDAE5000_HDDNamingCheck_Done
	lda xwa, (0x22ac7e:24)
	calr	HDAE5000_NameHistory_Recall
	ld	xiz, xhl
	ld	xwa, xiz
	or xwa, xwa
	jrl	z, HDAE5000_HDDNamingCheck_Done
	ld	xwa, xiz
	push xwa
	call HDAE5000_StrLen
	pushw hl
	ld	xwa, xiz
	push xwa
	lda xwa, (HDAE5000_RAM_Name_ColumnRuler:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+14)
	lda xwa, (HDAE5000_RAM_Name_ColumnRuler:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingWindow
	ld	xbc, EVT_SET_STRING
	call	(xhl)
	jrl	t, HDAE5000_HDDNamingCheck_Done
HDAE5000_HDDNamingCheck_Skip:
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_PartMask
	ld	wa, hl
	cp	wa, 0xffff
	jr	nz, HDAE5000_HDDNamingCheck_Skip2
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateAllNo:24)
	ldw	bc, 0x003f
	calr	HDAE5000_TypeSel_Init
	jr	t, HDAE5000_HDDNamingCheck_Join
HDAE5000_HDDNamingCheck_Skip2:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	ld	bc, hl
	lda xde, (HDAE5000_TypeSel_TemplateAllNo:24)
	calr	HDAE5000_TypeSel_Init
HDAE5000_HDDNamingCheck_Join:
	lda xwa, (HDAE5000_RAM_Name_ColumnRuler:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingWindow
	ld	xbc, EVT_GET_STRING
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_SAVE_OPT_SCREEN
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl	t, HDAE5000_HDDNamingCheck_Done
HDAE5000_HDDNamingCheck_Skip3:
	lda xwa, (HDAE5000_RAM_Name_ColumnRuler:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingWindow
	ld	xbc, EVT_GET_STRING
	call	(xhl)
	cp	(HDAE5000_RAM_WriteConfirm:24), 1
	jr	nz, HDAE5000_HDDNamingCheck_Skip4
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_IsUsed
	cp	hl, 0xffff
	jr	z, HDAE5000_HDDNamingCheck_Skip4
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_ATTEN_OVER_FILE
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jr	t, HDAE5000_HDDNamingCheck_Join2
HDAE5000_HDDNamingCheck_Skip4:
	pushw 0x0023
	pushw 0x9fd6
	pushw 0x0001
	ld	xwa, HDAE5000_OBJ_SELECT_FILE
	push xwa
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	ld	de, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_SaveSongWithUi
HDAE5000_HDDNamingCheck_Join2:
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_SongScreen_Refresh
HDAE5000_HDDNamingCheck_Done:
	ld	xhl, 0:i3
HDAE5000_HDDNamingCheck_Epilogue:
	pop xiz
	ret

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
	pushw	HDAE5000_Fmt_s_SeparateOutputModeCheck@lo16		; low half of HDAE5000_Fmt_s_SeparateOutputModeCheck
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
	pushw	HDAE5000_Fmt_s_SeparateDrumPartCheck@lo16		; low half of HDAE5000_Fmt_s_SeparateDrumPartCheck
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
	pushw	HDAE5000_Fmt_s_SeparateBassPartCheck@lo16		; low half of HDAE5000_Fmt_s_SeparateBassPartCheck
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

HDAE5000_SaveOptNameCheck:
	; registered as "SaveOptNameCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa			; save context
	ld xwa, xbc			; command → XWA
	cp xwa, EVT_RAM_DATA_REQ		; special command?
	jr z, .Lhbi_special
	sub xwa, EVT_GET_LARGE_STEP		; normalize to index 0-9
	cp xwa, 0x00000000
	jr lt, .Lhbi_default
	cp xwa, 0x00000009
	jr gt, .Lhbi_default
	add xwa, xwa			; index * 2 (table has 16-bit entries)
	add xwa, HDAE5000_SaveOptNameCheck_CaseTable		; jump table base
	ld wa, (xwa + 0)		; load offset from table
	lda xix, (.Lhbi_case0:24); base of case handlers (0x284FF7)
	jp	t, (xix+wa)
.Lhbi_case0:
	; Case 0: PPI block copy from device
	pushw 0x0023
	pushw 0x9fd6
	pushw HDAE5000_Fmt_s_SaveOptNameCheck@hi16
	pushw	HDAE5000_Fmt_s_SaveOptNameCheck@lo16		; low half of HDAE5000_Fmt_s_SaveOptNameCheck
	ld xwa, (xde + 18)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 12)		; pop args
	ld xhl, xiz			; return context ptr
	jr t, .Lhbi_exit
.Lhbi_case1:
	ld xhl, 1:i3
	jr t, .Lhbi_exit
.Lhbi_case2:
	ld xhl, 1:i3
	jr t, .Lhbi_exit
.Lhbi_case3:
	ld xhl, 0:i3
	jr t, .Lhbi_exit
.Lhbi_case4:
	ld xhl, 0:i3
	jr t, .Lhbi_exit
.Lhbi_case5:
	lda xhl, (HDAE5000_RAM_SaveOptions+11:24)
	jr t, .Lhbi_exit
.Lhbi_case6:
	ld xhl, 1:i3
	jr t, .Lhbi_exit
.Lhbi_special:
	; Command 0x01E00082: init buffer then return 0
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .Lhbi_exit
.Lhbi_default:
	ld xhl, 0:i3
.Lhbi_exit:
	pop xiz
	ret

; --- HD Configuration Manager and CHS Geometry ---
HDAE5000_TypeSel_ShowSaveFlags:	.include "includes/generated/cc900/HDAE5000_TypeSel_ShowSaveFlags.s"	; C: cc900/hdae5000_showflags_drv.c

HDAE5000_SaveOptSwEventCatch:
	; registered as "SaveOptSwEventCatch" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_SW_IN
	jr	z, HDAE5000_SaveOptSwEventCatch_OnSwIn
	cp	xwa, EVT_DRAW
	jr	z, HDAE5000_SaveOptSwEventCatch_OnDraw
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jr	z, HDAE5000_SaveOptSwEventCatch_OnAreYouClassProc
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl	t, HDAE5000_SaveOptSwEventCatch_Epilogue
HDAE5000_SaveOptSwEventCatch_OnAreYouClassProc:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_SaveOptSwEventCatch_Epilogue
HDAE5000_SaveOptSwEventCatch_OnDraw:
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_SVOP:24)
	ld	xbc, xwa
	ld	xwa, xiz
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_SaveOptSwEventCatch_Epilogue
HDAE5000_SaveOptSwEventCatch_OnSwIn:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x0000008b
	jrl	z, HDAE5000_SaveOptSwEventCatch_Skip5
	cp	xhl, 0x0000000b
	jrl	z, HDAE5000_SaveOptSwEventCatch_Skip4
	cp	xhl, 0x0000000a
	jrl	z, HDAE5000_SaveOptSwEventCatch_Skip3
	cp	xhl, 0x00000009
	jrl	z, HDAE5000_SaveOptSwEventCatch_Skip2
	cp	xhl, 0x00000008
	jrl	nz, HDAE5000_SaveOptSwEventCatch_Done
	lda xwa, (HDAE5000_RAM_Name_ColumnRuler:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HddNamingWindow
	ld	xbc, EVT_GET_STRING
	call	(xhl)
	cp	(HDAE5000_RAM_WriteConfirm:24), 1
	jr	nz, HDAE5000_SaveOptSwEventCatch_Skip
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_IsUsed
	cp	hl, 0xffff
	jr	z, HDAE5000_SaveOptSwEventCatch_Skip
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_ATTEN_OVER_FILE
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jr	t, HDAE5000_SaveOptSwEventCatch_Join
HDAE5000_SaveOptSwEventCatch_Skip:
	pushw 0x0023
	pushw 0x9fd6
	pushw 0x0001
	ld	xwa, HDAE5000_OBJ_SELECT_FILE
	push xwa
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	ld	de, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_SaveSongWithUi
HDAE5000_SaveOptSwEventCatch_Join:
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_SongScreen_Refresh
	jr	t, HDAE5000_SaveOptSwEventCatch_Done
HDAE5000_SaveOptSwEventCatch_Skip2:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateAllNo:24)
	ldw	bc, 0x003f
	calr	HDAE5000_TypeSel_Init
	calr	HDAE5000_TypeSel_ShowSaveFlags
	jr	t, HDAE5000_SaveOptSwEventCatch_Done
HDAE5000_SaveOptSwEventCatch_Skip3:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateAllNo:24)
	ldw	bc, 0x01ff
	calr	HDAE5000_TypeSel_Init
	calr	HDAE5000_TypeSel_ShowSaveFlags
	jr	t, HDAE5000_SaveOptSwEventCatch_Done
HDAE5000_SaveOptSwEventCatch_Skip4:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateAllNo:24)
	ld	bc, 0:i3
	calr	HDAE5000_TypeSel_Init
	calr	HDAE5000_TypeSel_ShowSaveFlags
	jr	t, HDAE5000_SaveOptSwEventCatch_Done
HDAE5000_SaveOptSwEventCatch_Skip5:
	ld	bc, (HDAE5000_RAM_SaveOptions:24)
	ld	wa, bc
	and	wa, 0x0100
	cp	wa, 0x0100
	jr	nz, HDAE5000_SaveOptSwEventCatch_Skip6
	sub	bc, 0x0100
	jr	t, HDAE5000_SaveOptSwEventCatch_Join2
HDAE5000_SaveOptSwEventCatch_Skip6:
	add	bc, 0x0100
HDAE5000_SaveOptSwEventCatch_Join2:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateAllNo:24)
	calr	HDAE5000_TypeSel_Init
	calr	HDAE5000_TypeSel_ShowSaveFlags
HDAE5000_SaveOptSwEventCatch_Done:
	ld	xhl, 0:i3
HDAE5000_SaveOptSwEventCatch_Epilogue:
	pop xiz
	ret

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
	pushw	HDAE5000_Fmt_s_SfxTlxBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxTlxBitCheck
	ld xwa, (xiz + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld xwa, (xiz + 0x0e)
	ld	(0x23a02e), xwa
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
	ld	xwa, (0x23a02e)
	cp	xwa, 0x00000001
	jr	nz, HDAE5000_SfxTlxBitCheck_Ev01E00044_Skip
	ld	xwa, 2:i3
	ld	(0x23a02e), xwa
	ld	xhl, 2:i3
	jr	t, HDAE5000_SfxTlxBitCheck_Ev01E00044_Join
HDAE5000_SfxTlxBitCheck_Ev01E00044_Skip:
	ld	xwa, 1:i3
	ld	(0x23a02e), xwa
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

; v2.01i has no LyricForeColorCheck / LyricBackColorCheck (the lyric colour
; settings of v2.06i): WriteConfirmEditCheck follows LyricJumpEditCheck.
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
HDAE5000_SetupPage_BuildDriveInfo:
	lda	xsp, (xsp-108)
	pushw 0x0139
	lda xwa, (HDAE5000_DriveInfo_Template:24)
	push xwa
	lda xwa, (0x22b2f6:24)
	push xwa
	call HDAE5000_MemCopy			; HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)
	lda xwa, (xsp + 0x38)
	call HDAE5000_HD_GetGeometry
	pushw 0x0010
	lda xwa, (xsp + 0x44)
	push xwa
	lda xwa, (0x22b30c:24)
	push xwa
	call HDAE5000_MemCopy
	pushw 0x000a
	lda xwa, (xsp + 0x24)
	push xwa
	ld wa, (xsp + 0x48)
	pushw wa                                ; push wa (compact)
	call HDAE5000_IToA
	lda xwa, (xsp + 0x2a)
	push xwa
	call HDAE5000_StrLen			; HDAE5000_StrLen
	pushw hl                                ; push hl (compact)
	lda xwa, (xsp + 0x30)
	push xwa
	lda xwa, (0x22b333:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x20)
	pushw 0x000a
	lda xwa, (xsp + 0x1a)
	push xwa
	ld wa, (xsp + 0x40)
	pushw wa                                ; push wa
	call HDAE5000_IToA
	lda xwa, (xsp + 0x20)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push hl
	lda xwa, (xsp + 0x26)
	push xwa
	lda xwa, (0x22b35a:24)
	push xwa
	call HDAE5000_MemCopy
	pushw 0x000a
	lda xwa, (xsp + 0x30)
	push xwa
	ld wa, (xsp + 0x58)
	pushw wa                                ; push wa
	call HDAE5000_IToA
	lda xsp, (xsp + 0x1e)
	lda xwa, (xsp + 0x18)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push hl
	lda xwa, (xsp + 0x1e)
	push xwa
	lda xwa, (0x22b381:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0e)
	lda xwa, (xsp + 0x28)
	call HDAE5000_HD_GetDiskUsage
	pushw 0x0010
	pushw 0x0000
	lda xwa, (xsp + 0x1c)
	push xwa
	call HDAE5000_MemFill			; HDAE5000_MemFill
	lda xbc, (xsp + 0x30)
	lda xwa, (xsp + 0x14)
	call HDAE5000_ULongToFloat
	lda xbc, (xsp + 0x14)
	lda xde, (HDAE5000_Float_100_DriveInfo:24)
	lda xwa, (xsp + 0x14)
	call HDAE5000_FloatDiv
	lda xbc, (xsp + 0x14)
	lda xwa, (xsp + 0x18)
	call HDAE5000_FloatToDouble
	lda xiy, (xsp + 0x18)
	ld xix, (xiy + 0x04)
	push xix
	ld xix, (xiy)
	push xix
	pushw	HDAE5000_Fmt_6_1f@hi16
	pushw	HDAE5000_Fmt_6_1f@lo16		; low half of HDAE5000_Fmt_6_1f
	lda xwa, (xsp + 0x2c)
	push xwa
	call HDAE5000_SPrintf
	lda xwa, (xsp + 0x30)
	push xwa
	call HDAE5000_StrLen
	lda xsp, (xsp + 0x1c)
	pushw hl                                ; push hl
	lda xwa, (xsp + 0x1a)
	push xwa
	lda xwa, (0x22b3a8:24)
	push xwa
	call HDAE5000_MemCopy
	pushw 0x0010
	pushw 0x0000
	lda xwa, (xsp + 0x26)
	push xwa
	call HDAE5000_MemFill
	lda xsp, (xsp + 0x12)
	lda xbc, (xsp + 0x2c)
	lda xwa, (xsp + 0x0c)
	call HDAE5000_ULongToFloat
	lda xbc, (xsp + 0x0c)
	lda xde, (HDAE5000_Float_100_DriveInfo_2:24)
	lda xwa, (xsp + 0x0c)
	call HDAE5000_FloatDiv
	lda xbc, (xsp + 0x0c)
	lda xwa, (xsp + 0x10)
	call HDAE5000_FloatToDouble
	lda xiy, (xsp + 0x10)
	ld xix, (xiy + 0x04)
	push xix
	ld xix, (xiy)
	push xix
	pushw HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo@hi16		; push 0x002E -- high half of HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo
	pushw	HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo@lo16		; low half of HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo
	lda xwa, (xsp + 0x24)
	push xwa
	call HDAE5000_SPrintf
	lda xwa, (xsp + 0x28)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push hl
	lda xwa, (xsp + 0x2e)
	push xwa
	lda xwa, (0x22b3cf:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x1e)
	pushw 0x0010
	pushw 0x0000
	lda xwa, (xsp + 0x1c)
	push xwa
	call HDAE5000_MemFill
	lda xbc, (xsp + 0x3c)
	lda xwa, (xsp + 0x14)
	call HDAE5000_ULongToFloat
	lda xbc, (xsp + 0x14)
	lda xde, (HDAE5000_Float_100_DriveInfo_3:24)
	lda xwa, (xsp + 0x14)
	call HDAE5000_FloatDiv
	lda xbc, (xsp + 0x14)
	lda xwa, (xsp + 0x18)
	call HDAE5000_FloatToDouble
	lda xiy, (xsp + 0x18)
	ld xix, (xiy + 0x04)
	push xix
	ld xix, (xiy)
	push xix
	pushw	HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo_2@hi16
	pushw	HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo_2@lo16		; low half of HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo_2
	lda xwa, (xsp + 0x2c)
	push xwa
	call HDAE5000_SPrintf
	lda xwa, (xsp + 0x30)
	push xwa
	call HDAE5000_StrLen
	lda xsp, (xsp + 0x1c)
	pushw hl                                ; push hl
	lda xwa, (xsp + 0x1a)
	push xwa
	lda xwa, (0x22b3f6:24)
	push xwa
	call HDAE5000_MemCopy
	pushw 0x0010
	pushw 0x0000
	lda xwa, (xsp + 0x26)
	push xwa
	call HDAE5000_MemFill
	lda xsp, (xsp + 0x12)
	lda xwa, (xsp + 0x18)
	calr HDAE5000_CopyVersionString
	lda xwa, (xsp + 0x18)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push hl
	lda xwa, (xsp + 0x1e)
	push xwa
	lda xwa, (0x22b41d:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0e)
	; Register partition display handler
	lda xwa, (0x22b2f6:24)
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_HD_INFO_LIST
	ld xbc, EVT_HDAE_SET_STR_ADR
	call (xhl)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_HD_INFO_LIST
	ld xbc, EVT_PARA_DRAW
	ld xde, 0xffffffff
	call (xhl)
	lda xsp, (xsp + 0x6c)		; deallocate stack frame
	ret
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
	pushw HDAE5000_Str_Track0RecoverCode@hi16
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
