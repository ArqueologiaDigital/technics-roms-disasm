; ---------------------------------------------------------------------------
; Request a mode change: cancel a queued (0xFFFFFFFF, EVT_CHANGE_MODE) event
; (RootFn_DeleteEvent) and post it anew with param 0x01800000 + A
; (RootFn_ApPostEvent).  0x0180nnnn are mode ids: the main CPU's GetModeNow
; returns them, and its boot posts mode 1.  Caller: HDAE5000_LoadSongWithUi,
; mode 1 when JUMP AFTER LOAD is on.
; In:  A = mode number
; ---------------------------------------------------------------------------
HDAE5000_RequestMode:	.include "includes/generated/cc900/HDAE5000_RequestMode.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Request a title (screen): cancel a queued (0xFFFFFFFF, 0x01C00015) event and
; post it anew with param 0x01A00000 + A.  0x01A0nnnn are title ids: the main
; CPU's GetTitleNow returns them; title 0x7F is the one this ROM registers as
; "TT_HDDEXT" (RootFn_RegisterTitle in HDAE5000_Handler_Registration).
; Caller: the frame handler, with 0x7F, when the HD title is not the current
; one.
; In:  A = title number
; ---------------------------------------------------------------------------
HDAE5000_RequestTitle15:	.include "includes/generated/cc900/HDAE5000_RequestTitle15.s"	; C: cc900/hdae5000_ui_display.c

HDAE5000_RequestTitle16:	.include "includes/generated/cc900/HDAE5000_RequestTitle16.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Show the main CPU's message screen for an error: HamaFn_SetGlobalError(WA)
; (the main CPU stores it in its byte 0x7F42), then cancel a queued
; (0xFFFFFFFF, 0x01C00016) event and post it anew with title id 0x01A000EE --
; title 0xEE, which the main CPU registers as "TT_MESAGE".  Caller:
; HDAE5000_FdList_Scan, code 2 when the floppy is not ready.
; In:  WA = error code
; ---------------------------------------------------------------------------
HDAE5000_ShowErrorMessageTitle:
	extz wa
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld xhl, (xbc + HamaFn_SetGlobalError)             ; ld XHL, (XBC + 0x012C) — shutdown handler
	call (xhl)		; HamaFn_SetGlobalError(WA)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_DeleteEvent)
	ld xwa, 0xFFFFFFFF
	ld xbc, EVT_INTERRUPT_TITLE		; event 0x01C00016
	call (xhl)		; RootFn_DeleteEvent
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, 0xFFFFFFFF
	ld xbc, EVT_INTERRUPT_TITLE
	ld xde, TITLE_MESAGE		; title 0xEE (TT_MESAGE)
	jp (xhl)		; tail-call RootFn_ApPostEvent

; ---------------------------------------------------------------------------
; Rename a directory with its screen messages: shows HD_PLEASE on the asking
; object (RootFn_SendEvent(obj, 0x01C00001, 3)), waits
; (HDAE5000_YieldUntilSem1Zero), then HDAE5000_DirName_SetAndStore(WA, name,
; 0).  Success: RootFn_PostEvent(XDE, 0x01C00001, 0).  Failure (HL = 0xFFFF):
; shows ERR_SAVE, captions XDE with ERR_SAVE_EXIT and restarts its timer
; (RootFn_KillApTimer / SetApTimer 0x14D, ERR_SAVE_CATCH, event 0x01CA0002).
; Either way the name goes on HDAE5000_RAM_DirNameHistory
; (HDAE5000_NameHistory_Push).
; In:  WA = directory, XBC = the new 16-byte name, XDE = the asking object
;      (a naming window)
; ---------------------------------------------------------------------------
HDAE5000_DirName_StoreWithUi:
	lda xsp, (xsp - 22)		; allocate 22 bytes on stack
	pushw iz
	ld (xsp + 20), xde		; save the requesting object
	ld iz, wa		; IZ = directory number
	pushw 0x0010		; 16 bytes
	push xbc		; the new name
	lda xwa, (xsp + 8)		; local copy
	push xwa
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 10)		; pop 3 args (10 bytes)
	ld (xsp + 18), 0x00		; NUL after the 16 chars
	; --- show HD_PLEASE, wait ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; ld XHL, (XWA + 0x0100)
	ld xwa, HDAE5000_OBJ_HD_PLEASE		; object HD_PLEASE
	ld xbc, EVT_SHOW		; param
	ld xde, 3:i3		; param 3
	call (xhl)
	calr HDAE5000_YieldUntilSem1Zero
	; --- store the name ---
	lda xwa, (xsp + 2)
	ld xbc, xwa			; XBC = buffer
	ld wa, iz		; WA = directory number
	ld de, 0:i3			; DE = 0
	call HDAE5000_DirName_SetAndStore
	cp hl, 0xFFFF		; 0xFFFF = failed
	jr z, .Lmh_alt
	; --- success: PostEvent(requester, 0x01C00001, 0) ---
	ld xwa, (xsp + 20)		; the requester
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld xhl, (xbc + RootFn_PostEvent)
	ld xbc, EVT_SHOW		; param
	ld xde, 0:i3			; mode = 0
	call (xhl)
	jr t, .Lmh_finish
.Lmh_alt:
	; --- failure: ERR_SAVE, caption ERR_SAVE_EXIT ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; ld XHL, (XWA + 0x0100)
	ld xwa, HDAE5000_OBJ_ERR_SAVE		; object ERR_SAVE
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	ld xbc, (xsp + 20)		; XBC = the requester
	ld xwa, HDAE5000_OBJ_ERR_SAVE_EXIT
	calr HDAE5000_UiObj_SetCaption
	; --- restart the ERR_SAVE_CATCH timer: KillApTimer, SetApTimer ---
	ld xwa, EVT_HDAE_TIMER_BACK		; event 0x01CA0002
	push xwa
	ld xwa, (xsp + 24)		; the requester
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_KillApTimer)
	ld xwa, 0x0000014D		; 0x14D
	ld xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld xde, 0xFFFFFFFF		; param
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK		; event 0x01CA0002
	push xwa
	ld xwa, (xsp + 24)		; the requester
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)
	ld xwa, 0x0000014D
	ld xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld xde, 0xFFFFFFFF
	call (xhl)
.Lmh_finish:
	lda xwa, (HDAE5000_RAM_DirNameHistory:24)
	lda xbc, (xsp + 2)		; XBC = stack buffer
	calr HDAE5000_NameHistory_Push
	popw iz
	lda xsp, (xsp + 22)		; deallocate stack
	ret

; ---------------------------------------------------------------------------
; Rename an FLS with its screen messages, as HDAE5000_DirName_StoreWithUi
; but with HDAE5000_FlsName_SetAndStore and HDAE5000_RAM_FlsNameHistory.
; In:  WA = FLS, XBC = the new 16-byte name, XDE = the asking object
; ---------------------------------------------------------------------------
HDAE5000_FlsName_StoreWithUi:
	lda xsp, (xsp - 22)		; allocate 22 bytes on stack
	pushw iz
	ld (xsp + 20), xde		; save the requesting object
	ld iz, wa		; IZ = FLS number
	pushw 0x0010		; 16 bytes
	push xbc		; the new name
	lda xwa, (xsp + 8)		; local copy
	push xwa
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 10)		; pop 3 args
	ld (xsp + 18), 0x00		; NUL after the 16 chars
	; --- show HD_PLEASE, wait ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; ld XHL, (XWA + 0x0100)
	ld xwa, HDAE5000_OBJ_HD_PLEASE
	ld xbc, EVT_SHOW
	ld xde, 3:i3
	call (xhl)
	calr HDAE5000_YieldUntilSem1Zero
	; --- store the name ---
	lda xwa, (xsp + 2)
	ld xbc, xwa
	ld wa, iz
	ld de, 0:i3
	call HDAE5000_FlsName_SetAndStore
	cp hl, 0xFFFF
	jr z, .Lmc_alt
	; --- success: PostEvent(requester, 0x01C00001, 0) ---
	ld xwa, (xsp + 20)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld xhl, (xbc + RootFn_PostEvent)
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jr t, .Lmc_finish
.Lmc_alt:
	; --- failure: ERR_SAVE, caption ERR_SAVE_EXIT ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)
	ld xwa, HDAE5000_OBJ_ERR_SAVE
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	ld xbc, (xsp + 20)
	ld xwa, HDAE5000_OBJ_ERR_SAVE_EXIT
	calr HDAE5000_UiObj_SetCaption
	; --- restart the ERR_SAVE_CATCH timer: KillApTimer, SetApTimer ---
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, (xsp + 24)
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_KillApTimer)
	ld xwa, 0x0000014D
	ld xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld xde, 0xFFFFFFFF
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, (xsp + 24)
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)
	ld xwa, 0x0000014D
	ld xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld xde, 0xFFFFFFFF
	call (xhl)
.Lmc_finish:
	lda xwa, (HDAE5000_RAM_FlsNameHistory:24)
	lda xbc, (xsp + 2)
	calr HDAE5000_NameHistory_Push
	popw iz
	lda xsp, (xsp + 22)
	ret

; ---------------------------------------------------------------------------
; Load a song with its screen messages: shows object 0x7F02C1 ("HD_PLEASE" in
; HDAE5000_UiObjectName_PtrTable), runs HDAE5000_LoadSong and, on failure,
; shows "ERR_LOAD" (0x29D) and arms "ERR_LOAD_EXIT" / "ERR_LOAD_CATCH"
; (0x29E / 0x29F) with event 0x01CA0002; after a load it may change mode
; (HDAE5000_RequestMode; HDAE5000_RAM_JumpAfterLoad).  Callers:
; FileLoadSwCatch, LBNLoadSwCatch, FlsLoadScreen (twice) and one more.
; In:  WA = directory, BC = song, DE = part mask, (xsp+4..) stacked flags
; ---------------------------------------------------------------------------
HDAE5000_LoadSongWithUi:
	dec 8, xsp				; ef 68 — allocate 4 bytes
	pushw iz                                ; push iz (compact 16-bit)
	ld (xsp + 0x04), de			; bf 04 52
	ld (xsp + 0x06), bc			; bf 06 51
	ld (xsp + 0x08), wa			; bf 08 50
	ld iz, (xsp + 0x12)			; 9f 12 26 — load mode arg
	cp iz, 1:i3				; de d9

	; --- Branch on mode ---
	jr nz, .Ldm_mode2			; 6e xx

	; Mode 1: register event via +0x0100 vtable
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23 — ld xhl, (xwa+0x0100)
	ld xwa, HDAE5000_OBJ_HD_PLEASE			; 40 c0 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 5:i3				; ea ad
	call (xhl)				; b3 e8
	calr HDAE5000_YieldUntilSem1Zero	; 1e xx xx
	jr t, .Ldm_common			; 68 xx

.Ldm_mode2:
	; Mode 2: register event via +0x0124 vtable, then call +0x0E88/+0x00E4
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_HD_PLEASE			; 40 c0 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 5:i3				; ea ad
	call (xhl)				; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_HamaFnTable)             ; e3 e1 88 0e 20 — ld xwa, (xwa+0x0e88)
	ld_sril xhl, (xwa + HamaFn_pdly_tim_X)             ; e3 e1 e4 00 23 — ld xhl, (xwa+0x00e4)
	ldw wa, 0x0064				; 30 64 00
	call (xhl)				; b3 e8
	calr HDAE5000_YieldUntilSem1Zero	; 1e xx xx

.Ldm_common:
	; Common: dispatch via saved args
	pushw iz                                ; push iz (compact 16-bit)
	pushw 0x0000
	ld wa, (xsp + 0x0c)			; 9f 0c 20
	ld bc, (xsp + 0x0a)			; 9f 0a 21
	ld de, (xsp + 0x08)			; 9f 08 22
	call HDAE5000_LoadSong				; 1d 9c ff 28
	ld (xsp + 0x02), hl			; bf 02 53 — save result
	ld wa, (xsp + 0x02)			; 9f 02 20
	cp wa, 0xffff				; d8 cf ff ff
	jrl z, .Ldm_fail			; 76 xx xx — WA == -1 → failure

	; --- Success path ---
	cp (HDAE5000_RAM_JumpAfterLoad:24), 0x01; c2 ab 9d 22 3f 01
	jr nz, .Ldm_success_check		; 6e xx
	ld wa, 1:i3				; d8 a9
	calr HDAE5000_RequestMode		; 1e xx xx
	jrl t, .Ldm_done			; 78 xx xx

.Ldm_success_check:
	cp iz, 1:i3				; de d9
	jr nz, .Ldm_mode2_dereg		; 6e xx

	; Mode 1 deregistration: via +0x0104 vtable
	ld xwa, (xsp + 0x0e)			; af 0e 20
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 21
	ld xbc, (xbc + WS_RootFnTable)             ; e3 e5 0a 0e 21 — ld xbc, (xbc+0x0e0a)
	ld xhl, (xbc + RootFn_PostEvent)             ; e3 e5 04 01 23 — ld xhl, (xbc+0x0104)
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_PostEvent)             ; e3 e1 04 01 23 — ld xhl, (xwa+0x0104)
	ld xwa, 0xffffffff			; 40 ff ff ff ff
	ld xbc, EVT_INDEXSW_DOWN			; 41 18 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	jrl t, .Ldm_done			; 78 xx xx

.Ldm_mode2_dereg:
	; Mode 2 deregistration: via +0x0124 vtable
	ld xwa, (xsp + 0x0e)			; af 0e 20
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 21
	ld xbc, (xbc + WS_RootFnTable)             ; e3 e5 0a 0e 21 — ld xbc, (xbc+0x0e0a)
	ld xhl, (xbc + RootFn_ApPostEvent)             ; e3 e5 24 01 23 — ld xhl, (xbc+0x0124)
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, 0xffffffff			; 40 ff ff ff ff
	ld xbc, EVT_INDEXSW_DOWN			; 41 18 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	jrl t, .Ldm_done			; 78 xx xx

.Ldm_fail:
	; Failure path: register error event
	cp iz, 1:i3				; de d9
	jr nz, .Ldm_fail_mode2			; 6e xx

	; Fail mode 1: via +0x0100 vtable
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23 — ld xhl, (xwa+0x0100)
	ld xwa, HDAE5000_OBJ_ERR_LOAD			; 40 9c 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	jr t, .Ldm_fail_common			; 68 xx

.Ldm_fail_mode2:
	; Fail mode 2: via +0x0124 vtable
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_ERR_LOAD			; 40 9c 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8

.Ldm_fail_common:
	; Register error display handlers
	ld xbc, (xsp + 0x0e)			; af 0e 21
	ld xwa, HDAE5000_OBJ_ERR_LOAD_EXIT			; 40 9d 02 7f 00
	calr HDAE5000_UiObj_SetCaption		; 1e xx xx
	; Register via +0x0418 vtable (timer handler)
	ld xwa, EVT_HDAE_TIMER_BACK			; 40 02 00 ca 01
	push xwa				; 38
	ld xwa, (xsp + 0x12)			; af 12 20
	push xwa				; 38
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_KillApTimer)             ; e3 e1 18 04 23 — ld xhl, (xwa+0x0418)
	ld xwa, 0x0000014d			; 40 4d 01 00 00
	ld xbc, HDAE5000_OBJ_ERR_LOAD_CATCH			; 41 9e 02 7f 00
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8
	; Register via +0x0410 vtable (second timer handler)
	ld xwa, EVT_HDAE_TIMER_BACK			; 40 02 00 ca 01
	push xwa				; 38
	ld xwa, (xsp + 0x12)			; af 12 20
	push xwa				; 38
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_SetApTimer)             ; e3 e1 10 04 23 — ld xhl, (xwa+0x0410)
	ld xwa, 0x0000014d			; 40 4d 01 00 00
	ld xbc, HDAE5000_OBJ_ERR_LOAD_CATCH			; 41 9e 02 7f 00
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8

.Ldm_done:
	; --- Epilogue ---
	ld hl, (xsp + 0x02)			; 9f 02 23
	popw iz                                 ; pop iz (compact 16-bit)
	inc 8, xsp				; ef 60
	retd 0x0006				; 0f 06 00

; ---------------------------------------------------------------------------
; The save counterpart of HDAE5000_LoadSongWithUi around HDAE5000_SaveSong
; (the new name is also pushed on the name history, HDAE5000_NameHistory_Push).
; Callers: HDDNamingCheck, SaveOptSwEventCatch (part mask = the save-option
; word HDAE5000_RAM_SaveOptions), WrConfirmEventCatch.
; In:  WA = directory, BC = song, DE = part mask
; ---------------------------------------------------------------------------
HDAE5000_SaveSongWithUi:
	lda xsp, (xsp - 34)		; allocate 34 bytes on stack (0xDE = -34)
	pushw iz
	ld iz, de			; IZ = context ptr
	ld (xsp + 32), bc		; save BC param at offset 0x20
	ld (xsp + 34), wa		; save WA index at offset 0x22
	; --- Register handler via workspace ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; ld XHL, (XWA + 0x0100)
	ld xwa, HDAE5000_OBJ_HD_PLEASE
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	; --- Copy data to stack buffer ---
	pushw 0x001A			; param: size 26
	ld xwa, (xsp + 48)		; reload source (+2 for pushw) = XSP+0x30
	push xwa
	lda xwa, (xsp + 10)		; destination (stack buffer at +0x0A)
	push xwa
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 10)		; pop 3 args
	ld (xsp + 30), 0x00		; clear status byte at offset 0x1E
	; --- Prepare and call 0x291140 ---
	lda xwa, (xsp + 4)		; XWA = buffer ptr at stack+4
	ld xde, xwa			; XDE = buffer
	pushw iz			; push context ptr
	pushm (xsp + 46)		; push word from (XSP+0x2E)
	pushw 0x0000
	ld wa, (xsp + 40)		; WA = saved index (XSP+0x28)
	ld bc, (xsp + 38)		; BC = saved param (XSP+0x26)
	call HDAE5000_SaveSong			; call scroll handler
	ld (xsp + 2), hl		; save result at offset 2
	; --- Check result ---
	ld wa, (xsp + 2)		; reload result
	cp wa, 0xFFFF			; check for failure
	jr z, .Lds_alt			; if failed, try alternate
	; --- Direct dispatch ---
	ld xwa, (xsp + 40)		; load context (XSP+0x28)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld xhl, (xbc + RootFn_PostEvent)
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jr t, .Lds_finish
.Lds_alt:
	; --- Alternate handler ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)
	ld xwa, HDAE5000_OBJ_ERR_SAVE
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	ld xbc, (xsp + 40)		; XBC = context (XSP+0x28)
	ld xwa, HDAE5000_OBJ_ERR_SAVE_EXIT
	calr HDAE5000_UiObj_SetCaption
	; --- Register display handlers ---
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, (xsp + 44)		; XSP+0x2C
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_KillApTimer)             ; +0x0418
	ld xwa, 0x0000014D
	ld xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld xde, 0xFFFFFFFF
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, (xsp + 44)		; XSP+0x2C
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)             ; +0x0410
	ld xwa, 0x0000014D
	ld xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld xde, 0xFFFFFFFF
	call (xhl)
.Lds_finish:
	lda xwa, (0x22ac7e:24); lda XWA, 0x22AC7E
	lda xbc, (xsp + 4)
	calr HDAE5000_NameHistory_Push
	ld hl, (xsp + 2)		; restore result to HL
	popw iz
	lda xsp, (xsp + 34)		; deallocate stack
	retd 0x000A			; return and pop 10 bytes

; ---------------------------------------------------------------------------
; Copy "V2.01i" with its NUL (7 bytes of HDAE5000_Str_V201i) to a buffer.
; Caller: HDAE5000_SetupPage_BuildDriveInfo.
; In:  XWA = buffer
; Out: HL = 6 (HDAE5000_StrLen of the string).
; ---------------------------------------------------------------------------
HDAE5000_CopyVersionString:
	ld ix, 0:i3
	cp ix, 7:i3
	jr nc, HDAE5000_CopyVersionString__len
HDAE5000_CopyVersionString__loop:
	lda xhl, (xwa+:1)
	ld bc, ix
	extz xbc
	ld xde, HDAE5000_Str_V201i		; "V2.01i"
	add xde, xbc
	ld c, (xde)
	ld (xhl), c
	inc 1, ix
	cp ix, 7:i3
	jr c, HDAE5000_CopyVersionString__loop
HDAE5000_CopyVersionString__len:
	pushw HDAE5000_Str_V201i@hi16
	pushw	HDAE5000_Str_V201i@lo16		; low half of HDAE5000_Str_V201i
	call HDAE5000_StrLen
	inc 4, xsp
	ret

; ---------------------------------------------------------------------------
; Wait until the main CPU's semaphore 1 is free: HamaFn_ref_sem_X(1) returns
; its count (byte 0x533; ref_sem_X jumps to the routine the v10 build calls
; AudioLock_GetCount), and while it is not 0, HamaFn_rot_rdq_X(3) (rotate
; ready queue 3: let the other tasks run).  Called before every disk
; operation that follows a "please wait" screen.
; ---------------------------------------------------------------------------
HDAE5000_YieldUntilSem1Zero:	.include "includes/generated/cc900/HDAE5000_YieldUntilSem1Zero.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Show (A = 0) or hide (A != 0) nine of this ROM's buttons through
; RootFn_SetVisible: HDAE5000_OBJ_SELECT_DIR_SW_EDIT, _HD_FILE_LOAD_SW_SAVE,
; _HD_FILE_LOAD_SW_DEL, _FLS_SELECT_SW_EDIT, _FLS_FILE_LOAD_SW_EDIT and four
; more.
; In:  A = 0 to show.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_Set_Menu_Visibility:
	pushw iz
	cp a, 0:i3
	jr nz, .Lsmv_hide
	ld iz, 1:i3
	jr t, .Lsmv_start
.Lsmv_hide:
	ld iz, 0:i3
.Lsmv_start:
	ld bc, iz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetVisible)
	ld xwa, HDAE5000_OBJ_SELECT_DIR_SW_EDIT
	call (xhl)
	ld bc, iz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetVisible)
	ld xwa, HDAE5000_OBJ_HD_FILE_LOAD_SW_SAVE
	call (xhl)
	ld bc, iz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetVisible)
	ld xwa, HDAE5000_OBJ_HD_FILE_LOAD_SW_DEL
	call (xhl)
	ld bc, iz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetVisible)
	ld xwa, HDAE5000_OBJ_FLS_SELECT_SW_EDIT
	call (xhl)
	ld bc, iz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetVisible)
	ld xwa, HDAE5000_OBJ_FLS_FILE_LOAD_SW_EDIT
	call (xhl)
	ld bc, iz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetVisible)
	ld xwa, HDAE5000_OBJ_HD_FILE_LOAD_SW_DELFILE
	call (xhl)
	ld bc, iz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetVisible)
	ld xwa, HDAE5000_OBJ_CP_FD_HDSWTO
	call (xhl)
	ld bc, iz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetVisible)
	ld xwa, HDAE5000_OBJ_CP_FD_HDSWSEL
	call (xhl)
	ld bc, iz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetVisible)
	ld xwa, HDAE5000_OBJ_SW_HD_FORMAT
	call (xhl)
	popw iz
	ret

; HDAE5000_NameHistory_AfterPushNop: Empty routine (a lone ret) that HDAE5000_NameHistory_Push calls last, with XWA =
;   the history it just updated; its only caller. Basis: the single calr in NameHistory_Push (ROM search finds no
;   other reference to 0x28B33D).
HDAE5000_NameHistory_AfterPushNop:	; (1 bytes)
	ret

; ---------------------------------------------------------------------------
; Add a name to a 5-entry history {u8 count, u8 recall index, u8 next slot,
; pad, 5 x 27-byte names}: copy it into the next slot, make that slot the
; recall index, advance the slot modulo 5 and the count up to 5.  Histories:
; HDAE5000_RAM_DirNameHistory and HDAE5000_RAM_FlsNameHistory.
; In:  XWA = history, XBC = name
; ---------------------------------------------------------------------------
HDAE5000_NameHistory_Push:
	push xiz
	ld xiz, xwa		; XIZ = the history
	push xbc
	ld a, (xiz + 2)		; A = next slot
	extz wa
	muls wa, 0x001B			; offset = index * 27 (entry size)
	inc 4, wa		; past the 4-byte header
	exts xwa			; sign-extend to 32-bit
	add xwa, xiz		; XWA = &name[slot]
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp			; clean up 8 bytes (arg + saved XBC)
	ld a, (xiz + 2)		; recall index = the slot just written
	ld (xiz + 1), a
	lda xwa, (xiz + 2)
	incm8 1, (xwa)		; next slot
	ld a, (xwa)			; read new index value
	cp a, 5:i3
	jr c, .Lgte_no_wrap
	ld (xiz + 2), 0x00		; reset to 0
.Lgte_no_wrap:
	cp (xiz), 0x05		; count < 5?
	jr nc, .Lgte_no_inc
	incm8 1, (xiz)		; count++
.Lgte_no_inc:
	ld xwa, xiz
	calr HDAE5000_NameHistory_AfterPushNop	; NOP call (returns immediately)
	pop xiz
	ret

; ---------------------------------------------------------------------------
; The name at a history's recall index; the index steps back (from 0 to
; count - 1).  The naming windows' recall key (event 0x01C00007, code 0x8A)
; cycles through earlier names with it.
; In:  XWA = history (see HDAE5000_NameHistory_Push)
; Out: XHL = the name, or 0 when the history is empty.
; ---------------------------------------------------------------------------
HDAE5000_NameHistory_Recall:
	cp (xwa), 0x00		; empty history?
	jr z, .LNameHistory_Recall__empty
	ld c, (xwa + 1)		; recall index
	extz bc				; zero-extend to 16-bit
	muls bc, 0x001B		; 27 bytes per name
	inc 4, bc		; past the 4-byte header
	lda	xhl, (xwa+bc)		; XHL = &name[recall index]
	cp (xwa + 1), 0x00		; check if index is non-zero
	jr nz, .LNameHistory_Recall__dec
	ld c, (xwa)			; get count
	cp c, 5:i3			; count == 5?
	jr nz, .LNameHistory_Recall__dec_count
	ld (xwa + 1), 0x04		; wrap: index = 4 (max-1)
	jr t, .LNameHistory_Recall__ret
.LNameHistory_Recall__dec_count:
	ld c, (xwa)			; get count
	dec 1, c			; count - 1
	ld (xwa + 1), c			; index = count - 1
	jr t, .LNameHistory_Recall__ret
.LNameHistory_Recall__dec:
	decm8 1, (xwa + 1)		; index--
	jr t, .LNameHistory_Recall__ret
.LNameHistory_Recall__empty:
	ld xhl, 0:i3			; return NULL
.LNameHistory_Recall__ret:
	ret

; ---------------------------------------------------------------------------
; L = the byte at RAM HDAE5000_RAM_FlsAutoLoadPending (its role is not established).
; ---------------------------------------------------------------------------
HDAE5000_Fls_GetAutoLoadPending:	.include "includes/generated/cc900/HDAE5000_Fls_GetAutoLoadPending.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Store A at RAM HDAE5000_RAM_FlsSeqStopPending (its role is not established).
; ---------------------------------------------------------------------------
HDAE5000_Fls_SetSeqStopPending:	.include "includes/generated/cc900/HDAE5000_Fls_SetSeqStopPending.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Number of the 20 entries (0x114 bytes apart) of the floppy file list at RAM
; 0x22AA9C whose status byte is 1.
; Out: HL = the count.
; ---------------------------------------------------------------------------
HDAE5000_Count_Active_Files:
	ld hl, 0:i3		; HL = count = 0
	ld de, 0:i3		; DE = index = 0
	cp de, 0x0014		; check if index >= 20
	ret nc			; return if index >= 20 (unsigned)
HDAE5000_Count_Active_Files__loop:
	ld wa, de		; WA = current index
	extz xwa		; zero-extend to 32 bits
	add xwa, 0x00000114	; add entry size offset
	ld xbc, HDAE5000_RAM_FdList	; table base address
	add xbc, xwa		; XBC = &table[index]
	cp (xbc), 0x01	; compare status byte with 1
	jr nz, HDAE5000_Count_Active_Files__skip
	inc 1, hl		; count++
HDAE5000_Count_Active_Files__skip:
	inc 1, de		; index++
	cp de, 0x0014		; check if index < 20
	jr c, HDAE5000_Count_Active_Files__loop
	ret

; --- UI Handler, File Operations, Path/String Utilities ---
HDAE5000_UiObj_SetCaption:	.include "includes/generated/cc900/HDAE5000_UiObj_SetCaption.s"	; C: cc900/hdae5000_ui_display.c

HDAE5000_ErrMsgTimerCatch:
	; registered as "ErrMsgTimerCatch" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_HDAE_TIMER_BACK
	jr	z, HDAE5000_ErrMsgTimerCatch_OnHdaeTimerBack
	cp	xwa, EVT_DRAW
	jr	z, HDAE5000_ErrMsgTimerCatch_OnDraw
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jr	z, HDAE5000_ErrMsgTimerCatch_OnAreYouClassProc
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jr	t, HDAE5000_ErrMsgTimerCatch_Epilogue
HDAE5000_ErrMsgTimerCatch_OnAreYouClassProc:
	ld	xhl, 1:i3
	jr	t, HDAE5000_ErrMsgTimerCatch_Epilogue
HDAE5000_ErrMsgTimerCatch_OnDraw:
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_Timb:24)
	ld	xbc, xwa
	ld	xwa, xiz
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jr	t, HDAE5000_ErrMsgTimerCatch_Epilogue
HDAE5000_ErrMsgTimerCatch_OnHdaeTimerBack:
	ld	xwa, xde
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_PostEvent)
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	ld	xhl, 0:i3
HDAE5000_ErrMsgTimerCatch_Epilogue:
	pop xiz
	ret

HDAE5000_ErrMsgTimerCatchLBN:
	; registered as "ErrMsgTimerCatchLBN" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_HDAE_TIMER_BACK
	jr	z, HDAE5000_ErrMsgTimerCatchLBN_OnHdaeTimerBack
	cp	xwa, EVT_DRAW
	jr	z, HDAE5000_ErrMsgTimerCatchLBN_OnDraw
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jr	z, HDAE5000_ErrMsgTimerCatchLBN_OnAreYouClassProc
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jr	t, HDAE5000_ErrMsgTimerCatchLBN_Epilogue
HDAE5000_ErrMsgTimerCatchLBN_OnAreYouClassProc:
	ld	xhl, 1:i3
	jr	t, HDAE5000_ErrMsgTimerCatchLBN_Epilogue
HDAE5000_ErrMsgTimerCatchLBN_OnDraw:
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_TLBN:24)
	ld	xbc, xwa
	ld	xwa, xiz
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jr	t, HDAE5000_ErrMsgTimerCatchLBN_Epilogue
HDAE5000_ErrMsgTimerCatchLBN_OnHdaeTimerBack:
	ld	xwa, xde
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xhl, (xbc + RootFn_PostEvent)
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	pushw 0x0001
	ld	wa, 0:i3
	ld	bc, 0:i3
	ld	de, 6:i3
	calr	HDAE5000_Lbn_ShowEntry
	ld	xhl, 0:i3
HDAE5000_ErrMsgTimerCatchLBN_Epilogue:
	pop xiz
	ret

HDAE5000_BitmapButt01:
	; registered as "BitmapButt01" in HDAE5000_ObjHandler_Table
	cp	xbc, EVT_GET_BITMAP_HEIGHT
	jr	z, HDAE5000_BitmapButt01_OnGetBitmapHeight
	cp	xbc, EVT_GET_BITMAP_WIDTH
	jr	z, HDAE5000_BitmapButt01_OnGetBitmapWidth
	cp	xbc, EVT_GET_BITMAP_DATA
	jr	z, HDAE5000_BitmapButt01_OnGetBitmapData
	ld	xhl, 0:i3
	ret

HDAE5000_BitmapButt01_OnGetBitmapData:
	lda xhl, (HDAE5000_Bitmap_Button01:24)
	ret

HDAE5000_BitmapButt01_OnGetBitmapWidth:
	ld	xhl, 0x0000002a
	ret

HDAE5000_BitmapButt01_OnGetBitmapHeight:
	ld	xhl, 0x0000000f
	ret

HDAE5000_AcLanguageText1Proc:
	; registered as "AcLanguageText1Proc" in HDAE5000_ClassProc_Table
	lda xsp, (xsp-214)
	push xiz
	ld	(xsp+206), xde
	ld	(xsp+210), xbc
	ld	(xsp+214), xwa
	ld	xwa, (xsp+210)
	cp	xwa, EVT_PARA_DRAW
	jr	z, HDAE5000_AcLanguageText1Proc_OnParaDraw
	cp	xwa, EVT_GET_STR_PTR
	jr	z, HDAE5000_AcLanguageText1Proc_OnGetStrPtr
	ld	xwa, (xsp+214)
	ld	xbc, (xsp+210)
	ld	xde, (xsp+206)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl	t, HDAE5000_AcLanguageText1Proc_Epilogue
HDAE5000_AcLanguageText1Proc_OnGetStrPtr:
	lda xhl, (HDAE5000_Str_Aclanguage1:24)
	jrl	t, HDAE5000_AcLanguageText1Proc_Epilogue
HDAE5000_AcLanguageText1Proc_OnParaDraw:
	ld	xwa, (xsp+206)
	or xwa, xwa
	jr	nz, HDAE5000_AcLanguageText1Proc_Skip
	ld	xwa, (xsp+214)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xix, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_GET_STR_PTR
	ld	xde, 0:i3
	call	(xix)
	ld	xiz, xhl
	cp	(xiz), 0x00
	jr	nz, HDAE5000_AcLanguageText1Proc_Join
	ld	xwa, (xsp+214)
	ld	xbc, (xsp+210)
	ld	xde, (xsp+206)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcLanguageText1Proc_Epilogue
HDAE5000_AcLanguageText1Proc_Skip:
	ld	xiz, (xsp+206)
HDAE5000_AcLanguageText1Proc_Join:
	ldw (xsp + 0x04), 65535
	pushw 0x0008
	pushw HDAE5000_Str_LANENG00@hi16
	pushw	HDAE5000_Str_LANENG00@lo16		; low half of HDAE5000_Str_LANENG00
	ld	xwa, xiz
	push xwa
	call HDAE5000_StrNCmp
	add	xsp, 0x0000000a
	cp	hl, 0:i3
	jr	nz, HDAE5000_AcLanguageText1Proc_Join2
	ldw (xsp + 0x04), 1
HDAE5000_AcLanguageText1Proc_Join2:
	pushw 0x0008
	pushw HDAE5000_Str_LANDEU00@hi16
	pushw	HDAE5000_Str_LANDEU00@lo16		; low half of HDAE5000_Str_LANDEU00
	ld	xwa, xiz
	push xwa
	call HDAE5000_StrNCmp
	add	xsp, 0x0000000a
	cp	hl, 0:i3
	jr	nz, HDAE5000_AcLanguageText1Proc_Join3
	ldw (xsp + 0x04), 2
HDAE5000_AcLanguageText1Proc_Join3:
	pushw 0x0008
	pushw HDAE5000_Str_LANFRA00@hi16
	pushw	HDAE5000_Str_LANFRA00@lo16		; low half of HDAE5000_Str_LANFRA00
	ld	xwa, xiz
	push xwa
	call HDAE5000_StrNCmp
	add	xsp, 0x0000000a
	cp	hl, 0:i3
	jr	nz, HDAE5000_AcLanguageText1Proc_Join4
	ldw (xsp + 0x04), 3
HDAE5000_AcLanguageText1Proc_Join4:
	cpw	(xsp+4), 0x0000
	jr	ge, HDAE5000_AcLanguageText1Proc_Skip2
	ld	xwa, (xsp+214)
	ld	xbc, (xsp+210)
	ld	xde, (xsp+206)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AcLanguageText1Proc_Epilogue
HDAE5000_AcLanguageText1Proc_Skip2:
	ld	xwa, (xsp+214)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld	wa, (xhl+26)
	dec	1, wa
	cp	wa, 0:i3
	jrl	lt, HDAE5000_AcLanguageText1Proc_NoMessage
	cp	wa, 0x003f
	jr	le, HDAE5000_AcLanguageText1Proc_Join5
	sub	wa, 0x0087
	cp	wa, 0x0040
	jrl	lt, HDAE5000_AcLanguageText1Proc_NoMessage
	cp	wa, 0x004c
	jrl	gt, HDAE5000_AcLanguageText1Proc_NoMessage
HDAE5000_AcLanguageText1Proc_Join5:
	add	wa, wa
	lda xix, (HDAE5000_LangText_CaseTable:24)
	ld	wa, (xix+wa)
	lda xix, (HDAE5000_AcLanguageText1Proc_Msg001:24)
	jp	t, (xix+wa)
HDAE5000_AcLanguageText1Proc_Msg001:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg001_LangDE
	pushw HDAE5000_LangMsg_001_EN@hi16
	pushw	HDAE5000_LangMsg_001_EN@lo16		; low half of HDAE5000_LangMsg_001_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg001_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg001_LangFR
	pushw	HDAE5000_LangMsg_001_DE@hi16
	pushw	HDAE5000_LangMsg_001_DE@lo16		; low half of HDAE5000_LangMsg_001_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg001_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_001_FR@hi16
	pushw	HDAE5000_LangMsg_001_FR@lo16		; low half of HDAE5000_LangMsg_001_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg002:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg002_LangDE
	pushw HDAE5000_LangMsg_002_EN@hi16
	pushw	HDAE5000_LangMsg_002_EN@lo16		; low half of HDAE5000_LangMsg_002_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg002_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg002_LangFR
	pushw	HDAE5000_LangMsg_002_DE@hi16
	pushw	HDAE5000_LangMsg_002_DE@lo16		; low half of HDAE5000_LangMsg_002_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg002_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_002_FR@hi16
	pushw	HDAE5000_LangMsg_002_FR@lo16		; low half of HDAE5000_LangMsg_002_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg003:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg003_LangDE
	pushw HDAE5000_LangMsg_003_EN@hi16
	pushw	HDAE5000_LangMsg_003_EN@lo16		; low half of HDAE5000_LangMsg_003_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg003_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg003_LangFR
	pushw	HDAE5000_LangMsg_003_DE@hi16
	pushw	HDAE5000_LangMsg_003_DE@lo16		; low half of HDAE5000_LangMsg_003_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg003_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_003_FR@hi16
	pushw	HDAE5000_LangMsg_003_FR@lo16		; low half of HDAE5000_LangMsg_003_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg004:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg004_LangDE
	pushw HDAE5000_LangMsg_004_EN@hi16
	pushw	HDAE5000_LangMsg_004_EN@lo16		; low half of HDAE5000_LangMsg_004_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg004_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg004_LangFR
	pushw	HDAE5000_LangMsg_004_DE@hi16
	pushw	HDAE5000_LangMsg_004_DE@lo16		; low half of HDAE5000_LangMsg_004_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg004_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_004_FR@hi16
	pushw	HDAE5000_LangMsg_004_FR@lo16		; low half of HDAE5000_LangMsg_004_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg005:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg005_LangDE
	pushw HDAE5000_LangMsg_005_EN@hi16
	pushw	HDAE5000_LangMsg_005_EN@lo16		; low half of HDAE5000_LangMsg_005_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg005_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg005_LangFR
	pushw	HDAE5000_LangMsg_005_DE@hi16
	pushw	HDAE5000_LangMsg_005_DE@lo16		; low half of HDAE5000_LangMsg_005_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg005_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_005_FR@hi16
	pushw	HDAE5000_LangMsg_005_FR@lo16		; low half of HDAE5000_LangMsg_005_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg006:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg006_LangDE
	pushw HDAE5000_LangMsg_006_EN@hi16
	pushw	HDAE5000_LangMsg_006_EN@lo16		; low half of HDAE5000_LangMsg_006_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg006_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg006_LangFR
	pushw	HDAE5000_LangMsg_006_DE@hi16
	pushw	HDAE5000_LangMsg_006_DE@lo16		; low half of HDAE5000_LangMsg_006_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg006_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_006_FR@hi16
	pushw	HDAE5000_LangMsg_006_FR@lo16		; low half of HDAE5000_LangMsg_006_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg007:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg007_LangDE
	pushw HDAE5000_LangMsg_007_EN@hi16
	pushw	HDAE5000_LangMsg_007_EN@lo16		; low half of HDAE5000_LangMsg_007_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg007_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg007_LangFR
	pushw	HDAE5000_LangMsg_007_DE@hi16
	pushw	HDAE5000_LangMsg_007_DE@lo16		; low half of HDAE5000_LangMsg_007_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg007_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_007_FR@hi16
	pushw	HDAE5000_LangMsg_007_FR@lo16		; low half of HDAE5000_LangMsg_007_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg008:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg008_LangDE
	pushw HDAE5000_LangMsg_008_EN@hi16
	pushw	HDAE5000_LangMsg_008_EN@lo16		; low half of HDAE5000_LangMsg_008_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg008_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg008_LangFR
	pushw	HDAE5000_LangMsg_008_DE@hi16
	pushw	HDAE5000_LangMsg_008_DE@lo16		; low half of HDAE5000_LangMsg_008_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg008_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_008_FR@hi16
	pushw	HDAE5000_LangMsg_008_FR@lo16		; low half of HDAE5000_LangMsg_008_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg009:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg009_LangDE
	pushw HDAE5000_LangMsg_009_EN@hi16
	pushw	HDAE5000_LangMsg_009_EN@lo16		; low half of HDAE5000_LangMsg_009_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg009_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg009_LangFR
	pushw	HDAE5000_LangMsg_009_DE@hi16
	pushw	HDAE5000_LangMsg_009_DE@lo16		; low half of HDAE5000_LangMsg_009_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg009_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_009_FR@hi16
	pushw	HDAE5000_LangMsg_009_FR@lo16		; low half of HDAE5000_LangMsg_009_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg010:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg010_LangDE
	pushw HDAE5000_LangMsg_010_EN@hi16
	pushw	HDAE5000_LangMsg_010_EN@lo16		; low half of HDAE5000_LangMsg_010_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg010_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg010_LangFR
	pushw	HDAE5000_LangMsg_010_DE@hi16
	pushw	HDAE5000_LangMsg_010_DE@lo16		; low half of HDAE5000_LangMsg_010_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg010_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_010_FR@hi16
	pushw	HDAE5000_LangMsg_010_FR@lo16		; low half of HDAE5000_LangMsg_010_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg011:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg011_LangDE
	pushw HDAE5000_LangMsg_011_EN@hi16
	pushw	HDAE5000_LangMsg_011_EN@lo16		; low half of HDAE5000_LangMsg_011_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg011_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg011_LangFR
	pushw	HDAE5000_LangMsg_011_DE@hi16
	pushw	HDAE5000_LangMsg_011_DE@lo16		; low half of HDAE5000_LangMsg_011_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg011_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_011_FR@hi16
	pushw	HDAE5000_LangMsg_011_FR@lo16		; low half of HDAE5000_LangMsg_011_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg012:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg012_LangDE
	pushw HDAE5000_LangMsg_012_EN@hi16
	pushw	HDAE5000_LangMsg_012_EN@lo16		; low half of HDAE5000_LangMsg_012_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg012_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg012_LangFR
	pushw	HDAE5000_LangMsg_012_DE@hi16
	pushw	HDAE5000_LangMsg_012_DE@lo16		; low half of HDAE5000_LangMsg_012_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg012_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_012_FR@hi16
	pushw	HDAE5000_LangMsg_012_FR@lo16		; low half of HDAE5000_LangMsg_012_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg013:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg013_LangDE
	pushw HDAE5000_LangMsg_013_EN@hi16
	pushw	HDAE5000_LangMsg_013_EN@lo16		; low half of HDAE5000_LangMsg_013_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg013_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg013_LangFR
	pushw	HDAE5000_LangMsg_013_DE@hi16
	pushw	HDAE5000_LangMsg_013_DE@lo16		; low half of HDAE5000_LangMsg_013_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg013_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_013_FR@hi16
	pushw	HDAE5000_LangMsg_013_FR@lo16		; low half of HDAE5000_LangMsg_013_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg014:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg014_LangDE
	pushw HDAE5000_LangMsg_014_EN@hi16
	pushw	HDAE5000_LangMsg_014_EN@lo16		; low half of HDAE5000_LangMsg_014_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg014_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg014_LangFR
	pushw	HDAE5000_LangMsg_014_DE@hi16
	pushw	HDAE5000_LangMsg_014_DE@lo16		; low half of HDAE5000_LangMsg_014_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg014_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_014_FR@hi16
	pushw	HDAE5000_LangMsg_014_FR@lo16		; low half of HDAE5000_LangMsg_014_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg015:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg015_LangDE
	pushw HDAE5000_LangMsg_015_EN@hi16
	pushw	HDAE5000_LangMsg_015_EN@lo16		; low half of HDAE5000_LangMsg_015_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg015_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg015_LangFR
	pushw	HDAE5000_LangMsg_015_DE@hi16
	pushw	HDAE5000_LangMsg_015_DE@lo16		; low half of HDAE5000_LangMsg_015_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg015_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_015_FR@hi16
	pushw	HDAE5000_LangMsg_015_FR@lo16		; low half of HDAE5000_LangMsg_015_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg016:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg016_LangDE
	pushw HDAE5000_LangMsg_016_EN@hi16
	pushw	HDAE5000_LangMsg_016_EN@lo16		; low half of HDAE5000_LangMsg_016_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg016_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg016_LangFR
	pushw	HDAE5000_LangMsg_016_DE@hi16
	pushw	HDAE5000_LangMsg_016_DE@lo16		; low half of HDAE5000_LangMsg_016_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg016_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_016_FR@hi16
	pushw	HDAE5000_LangMsg_016_FR@lo16		; low half of HDAE5000_LangMsg_016_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg017:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg017_LangDE
	pushw HDAE5000_LangMsg_017_EN@hi16
	pushw	HDAE5000_LangMsg_017_EN@lo16		; low half of HDAE5000_LangMsg_017_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg017_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg017_LangFR
	pushw	HDAE5000_LangMsg_017_DE@hi16
	pushw	HDAE5000_LangMsg_017_DE@lo16		; low half of HDAE5000_LangMsg_017_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg017_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_017_FR@hi16
	pushw	HDAE5000_LangMsg_017_FR@lo16		; low half of HDAE5000_LangMsg_017_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg018:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg018_LangDE
	pushw HDAE5000_LangMsg_018_EN@hi16
	pushw	HDAE5000_LangMsg_018_EN@lo16		; low half of HDAE5000_LangMsg_018_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg018_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg018_LangFR
	pushw	HDAE5000_LangMsg_018_DE@hi16
	pushw	HDAE5000_LangMsg_018_DE@lo16		; low half of HDAE5000_LangMsg_018_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg018_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_018_FR@hi16
	pushw	HDAE5000_LangMsg_018_FR@lo16		; low half of HDAE5000_LangMsg_018_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg019:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg019_LangDE
	pushw HDAE5000_LangMsg_019_EN@hi16
	pushw	HDAE5000_LangMsg_019_EN@lo16		; low half of HDAE5000_LangMsg_019_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg019_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg019_LangFR
	pushw	HDAE5000_LangMsg_019_DE@hi16
	pushw	HDAE5000_LangMsg_019_DE@lo16		; low half of HDAE5000_LangMsg_019_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg019_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_019_FR@hi16
	pushw	HDAE5000_LangMsg_019_FR@lo16		; low half of HDAE5000_LangMsg_019_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg020:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg020_LangDE
	pushw HDAE5000_LangMsg_020_EN@hi16
	pushw	HDAE5000_LangMsg_020_EN@lo16		; low half of HDAE5000_LangMsg_020_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg020_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg020_LangFR
	pushw	HDAE5000_LangMsg_020_DE@hi16
	pushw	HDAE5000_LangMsg_020_DE@lo16		; low half of HDAE5000_LangMsg_020_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg020_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_020_FR@hi16
	pushw	HDAE5000_LangMsg_020_FR@lo16		; low half of HDAE5000_LangMsg_020_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg021:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg021_LangDE
	pushw HDAE5000_LangMsg_021_EN@hi16
	pushw	HDAE5000_LangMsg_021_EN@lo16		; low half of HDAE5000_LangMsg_021_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg021_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg021_LangFR
	pushw	HDAE5000_LangMsg_021_DE@hi16
	pushw	HDAE5000_LangMsg_021_DE@lo16		; low half of HDAE5000_LangMsg_021_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg021_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_021_FR@hi16
	pushw	HDAE5000_LangMsg_021_FR@lo16		; low half of HDAE5000_LangMsg_021_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg022:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg022_LangDE
	pushw HDAE5000_LangMsg_022_EN@hi16
	pushw	HDAE5000_LangMsg_022_EN@lo16		; low half of HDAE5000_LangMsg_022_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg022_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg022_LangFR
	pushw	HDAE5000_LangMsg_022_DE@hi16
	pushw	HDAE5000_LangMsg_022_DE@lo16		; low half of HDAE5000_LangMsg_022_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg022_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_022_FR@hi16
	pushw	HDAE5000_LangMsg_022_FR@lo16		; low half of HDAE5000_LangMsg_022_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg023:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg023_LangDE
	pushw HDAE5000_LangMsg_023_EN@hi16
	pushw	HDAE5000_LangMsg_023_EN@lo16		; low half of HDAE5000_LangMsg_023_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg023_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg023_LangFR
	pushw	HDAE5000_LangMsg_023_DE@hi16
	pushw	HDAE5000_LangMsg_023_DE@lo16		; low half of HDAE5000_LangMsg_023_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg023_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_023_FR@hi16
	pushw	HDAE5000_LangMsg_023_FR@lo16		; low half of HDAE5000_LangMsg_023_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg024:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg024_LangDE
	pushw HDAE5000_LangMsg_024_EN@hi16
	pushw	HDAE5000_LangMsg_024_EN@lo16		; low half of HDAE5000_LangMsg_024_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg024_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg024_LangFR
	pushw	HDAE5000_LangMsg_024_DE@hi16
	pushw	HDAE5000_LangMsg_024_DE@lo16		; low half of HDAE5000_LangMsg_024_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg024_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_024_FR@hi16
	pushw	HDAE5000_LangMsg_024_FR@lo16		; low half of HDAE5000_LangMsg_024_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg025:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg025_LangDE
	pushw HDAE5000_LangMsg_025_EN@hi16
	pushw	HDAE5000_LangMsg_025_EN@lo16		; low half of HDAE5000_LangMsg_025_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg025_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg025_LangFR
	pushw	HDAE5000_LangMsg_025_DE@hi16
	pushw	HDAE5000_LangMsg_025_DE@lo16		; low half of HDAE5000_LangMsg_025_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg025_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_025_FR@hi16
	pushw	HDAE5000_LangMsg_025_FR@lo16		; low half of HDAE5000_LangMsg_025_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg026:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg026_LangDE
	pushw HDAE5000_LangMsg_026_EN@hi16
	pushw	HDAE5000_LangMsg_026_EN@lo16		; low half of HDAE5000_LangMsg_026_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg026_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg026_LangFR
	pushw	HDAE5000_LangMsg_026_DE@hi16
	pushw	HDAE5000_LangMsg_026_DE@lo16		; low half of HDAE5000_LangMsg_026_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg026_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_026_FR@hi16
	pushw	HDAE5000_LangMsg_026_FR@lo16		; low half of HDAE5000_LangMsg_026_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg027:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg027_LangDE
	pushw HDAE5000_LangMsg_027_EN@hi16
	pushw	HDAE5000_LangMsg_027_EN@lo16		; low half of HDAE5000_LangMsg_027_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg027_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg027_LangFR
	pushw	HDAE5000_LangMsg_027_DE@hi16
	pushw	HDAE5000_LangMsg_027_DE@lo16		; low half of HDAE5000_LangMsg_027_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg027_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_027_FR@hi16
	pushw	HDAE5000_LangMsg_027_FR@lo16		; low half of HDAE5000_LangMsg_027_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg028:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg028_LangDE
	pushw HDAE5000_LangMsg_028_EN@hi16
	pushw	HDAE5000_LangMsg_028_EN@lo16		; low half of HDAE5000_LangMsg_028_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg028_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg028_LangFR
	pushw	HDAE5000_LangMsg_028_DE@hi16
	pushw	HDAE5000_LangMsg_028_DE@lo16		; low half of HDAE5000_LangMsg_028_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg028_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_028_FR@hi16
	pushw	HDAE5000_LangMsg_028_FR@lo16		; low half of HDAE5000_LangMsg_028_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg029:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg029_LangDE
	pushw HDAE5000_LangMsg_029_EN@hi16
	pushw	HDAE5000_LangMsg_029_EN@lo16		; low half of HDAE5000_LangMsg_029_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg029_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg029_LangFR
	pushw	HDAE5000_LangMsg_029_DE@hi16
	pushw	HDAE5000_LangMsg_029_DE@lo16		; low half of HDAE5000_LangMsg_029_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg029_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_029_FR@hi16
	pushw	HDAE5000_LangMsg_029_FR@lo16		; low half of HDAE5000_LangMsg_029_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg030:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg030_LangDE
	pushw HDAE5000_LangMsg_030_EN@hi16
	pushw	HDAE5000_LangMsg_030_EN@lo16		; low half of HDAE5000_LangMsg_030_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg030_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg030_LangFR
	pushw	HDAE5000_LangMsg_030_DE@hi16
	pushw	HDAE5000_LangMsg_030_DE@lo16		; low half of HDAE5000_LangMsg_030_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg030_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_030_FR@hi16
	pushw	HDAE5000_LangMsg_030_FR@lo16		; low half of HDAE5000_LangMsg_030_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg031:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg031_LangDE
	pushw HDAE5000_LangMsg_031_EN@hi16
	pushw	HDAE5000_LangMsg_031_EN@lo16		; low half of HDAE5000_LangMsg_031_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg031_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg031_LangFR
	pushw	HDAE5000_LangMsg_031_DE@hi16
	pushw	HDAE5000_LangMsg_031_DE@lo16		; low half of HDAE5000_LangMsg_031_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg031_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_031_FR@hi16
	pushw	HDAE5000_LangMsg_031_FR@lo16		; low half of HDAE5000_LangMsg_031_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg032:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg032_LangDE
	pushw HDAE5000_LangMsg_032_EN@hi16
	pushw	HDAE5000_LangMsg_032_EN@lo16		; low half of HDAE5000_LangMsg_032_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg032_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg032_LangFR
	pushw	HDAE5000_LangMsg_032_DE@hi16
	pushw	HDAE5000_LangMsg_032_DE@lo16		; low half of HDAE5000_LangMsg_032_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg032_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_032_FR@hi16
	pushw	HDAE5000_LangMsg_032_FR@lo16		; low half of HDAE5000_LangMsg_032_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg033:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg033_LangDE
	pushw HDAE5000_LangMsg_033_EN@hi16
	pushw	HDAE5000_LangMsg_033_EN@lo16		; low half of HDAE5000_LangMsg_033_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg033_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg033_LangFR
	pushw	HDAE5000_LangMsg_033_DE@hi16
	pushw	HDAE5000_LangMsg_033_DE@lo16		; low half of HDAE5000_LangMsg_033_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg033_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_033_FR@hi16
	pushw	HDAE5000_LangMsg_033_FR@lo16		; low half of HDAE5000_LangMsg_033_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg034:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg034_LangDE
	pushw HDAE5000_LangMsg_034_EN@hi16
	pushw	HDAE5000_LangMsg_034_EN@lo16		; low half of HDAE5000_LangMsg_034_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg034_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg034_LangFR
	pushw	HDAE5000_LangMsg_034_DE@hi16
	pushw	HDAE5000_LangMsg_034_DE@lo16		; low half of HDAE5000_LangMsg_034_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg034_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_034_FR@hi16
	pushw	HDAE5000_LangMsg_034_FR@lo16		; low half of HDAE5000_LangMsg_034_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg035:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg035_LangDE
	pushw HDAE5000_LangMsg_035_EN@hi16
	pushw	HDAE5000_LangMsg_035_EN@lo16		; low half of HDAE5000_LangMsg_035_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg035_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg035_LangFR
	pushw	HDAE5000_LangMsg_035_DE@hi16
	pushw	HDAE5000_LangMsg_035_DE@lo16		; low half of HDAE5000_LangMsg_035_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg035_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_035_FR@hi16
	pushw	HDAE5000_LangMsg_035_FR@lo16		; low half of HDAE5000_LangMsg_035_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg036:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg036_LangDE
	pushw HDAE5000_LangMsg_036_EN@hi16
	pushw	HDAE5000_LangMsg_036_EN@lo16		; low half of HDAE5000_LangMsg_036_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg036_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg036_LangFR
	pushw	HDAE5000_LangMsg_036_DE@hi16
	pushw	HDAE5000_LangMsg_036_DE@lo16		; low half of HDAE5000_LangMsg_036_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg036_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_036_FR@hi16
	pushw	HDAE5000_LangMsg_036_FR@lo16		; low half of HDAE5000_LangMsg_036_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg037:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg037_LangDE
	pushw HDAE5000_LangMsg_037_EN@hi16
	pushw	HDAE5000_LangMsg_037_EN@lo16		; low half of HDAE5000_LangMsg_037_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg037_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg037_LangFR
	pushw	HDAE5000_LangMsg_037_DE@hi16
	pushw	HDAE5000_LangMsg_037_DE@lo16		; low half of HDAE5000_LangMsg_037_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg037_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_037_FR@hi16
	pushw	HDAE5000_LangMsg_037_FR@lo16		; low half of HDAE5000_LangMsg_037_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg038:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg038_LangDE
	pushw HDAE5000_LangMsg_038_EN@hi16
	pushw	HDAE5000_LangMsg_038_EN@lo16		; low half of HDAE5000_LangMsg_038_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg038_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg038_LangFR
	pushw	HDAE5000_LangMsg_038_DE@hi16
	pushw	HDAE5000_LangMsg_038_DE@lo16		; low half of HDAE5000_LangMsg_038_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg038_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_038_FR@hi16
	pushw	HDAE5000_LangMsg_038_FR@lo16		; low half of HDAE5000_LangMsg_038_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg039:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg039_LangDE
	pushw HDAE5000_LangMsg_039_EN@hi16
	pushw	HDAE5000_LangMsg_039_EN@lo16		; low half of HDAE5000_LangMsg_039_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg039_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg039_LangFR
	pushw	HDAE5000_LangMsg_039_DE@hi16
	pushw	HDAE5000_LangMsg_039_DE@lo16		; low half of HDAE5000_LangMsg_039_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg039_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_039_FR@hi16
	pushw	HDAE5000_LangMsg_039_FR@lo16		; low half of HDAE5000_LangMsg_039_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg040:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg040_LangDE
	pushw HDAE5000_LangMsg_040_EN@hi16
	pushw	HDAE5000_LangMsg_040_EN@lo16		; low half of HDAE5000_LangMsg_040_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg040_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg040_LangFR
	pushw	HDAE5000_LangMsg_040_DE@hi16
	pushw	HDAE5000_LangMsg_040_DE@lo16		; low half of HDAE5000_LangMsg_040_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg040_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_040_FR@hi16
	pushw	HDAE5000_LangMsg_040_FR@lo16		; low half of HDAE5000_LangMsg_040_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg041:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg041_LangDE
	pushw HDAE5000_LangMsg_041_EN@hi16
	pushw	HDAE5000_LangMsg_041_EN@lo16		; low half of HDAE5000_LangMsg_041_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg041_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg041_LangFR
	pushw	HDAE5000_LangMsg_041_DE@hi16
	pushw	HDAE5000_LangMsg_041_DE@lo16		; low half of HDAE5000_LangMsg_041_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg041_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_041_FR@hi16
	pushw	HDAE5000_LangMsg_041_FR@lo16		; low half of HDAE5000_LangMsg_041_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg042:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg042_LangDE
	pushw HDAE5000_LangMsg_042_EN@hi16
	pushw	HDAE5000_LangMsg_042_EN@lo16		; low half of HDAE5000_LangMsg_042_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg042_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg042_LangFR
	pushw	HDAE5000_LangMsg_042_DE@hi16
	pushw	HDAE5000_LangMsg_042_DE@lo16		; low half of HDAE5000_LangMsg_042_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg042_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_042_FR@hi16
	pushw	HDAE5000_LangMsg_042_FR@lo16		; low half of HDAE5000_LangMsg_042_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg043:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg043_LangDE
	pushw HDAE5000_LangMsg_043_EN@hi16
	pushw	HDAE5000_LangMsg_043_EN@lo16		; low half of HDAE5000_LangMsg_043_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg043_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg043_LangFR
	pushw	HDAE5000_LangMsg_043_DE@hi16
	pushw	HDAE5000_LangMsg_043_DE@lo16		; low half of HDAE5000_LangMsg_043_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg043_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_043_FR@hi16
	pushw	HDAE5000_LangMsg_043_FR@lo16		; low half of HDAE5000_LangMsg_043_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg044:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg044_LangDE
	pushw HDAE5000_LangMsg_044_EN@hi16
	pushw	HDAE5000_LangMsg_044_EN@lo16		; low half of HDAE5000_LangMsg_044_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg044_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg044_LangFR
	pushw	HDAE5000_LangMsg_044_DE@hi16
	pushw	HDAE5000_LangMsg_044_DE@lo16		; low half of HDAE5000_LangMsg_044_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg044_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_044_FR@hi16
	pushw	HDAE5000_LangMsg_044_FR@lo16		; low half of HDAE5000_LangMsg_044_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg045:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg045_LangDE
	pushw HDAE5000_LangMsg_045_EN@hi16
	pushw	HDAE5000_LangMsg_045_EN@lo16		; low half of HDAE5000_LangMsg_045_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg045_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg045_LangFR
	pushw	HDAE5000_LangMsg_045_DE@hi16
	pushw	HDAE5000_LangMsg_045_DE@lo16		; low half of HDAE5000_LangMsg_045_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg045_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_045_FR@hi16
	pushw	HDAE5000_LangMsg_045_FR@lo16		; low half of HDAE5000_LangMsg_045_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg046:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg046_LangDE
	pushw HDAE5000_LangMsg_046_EN@hi16
	pushw	HDAE5000_LangMsg_046_EN@lo16		; low half of HDAE5000_LangMsg_046_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg046_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg046_LangFR
	pushw	HDAE5000_LangMsg_046_DE@hi16
	pushw	HDAE5000_LangMsg_046_DE@lo16		; low half of HDAE5000_LangMsg_046_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg046_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_046_FR@hi16
	pushw	HDAE5000_LangMsg_046_FR@lo16		; low half of HDAE5000_LangMsg_046_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg047:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg047_LangDE
	pushw HDAE5000_LangMsg_047_EN@hi16
	pushw	HDAE5000_LangMsg_047_EN@lo16		; low half of HDAE5000_LangMsg_047_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg047_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg047_LangFR
	pushw	HDAE5000_LangMsg_047_DE@hi16
	pushw	HDAE5000_LangMsg_047_DE@lo16		; low half of HDAE5000_LangMsg_047_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg047_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_047_FR@hi16
	pushw	HDAE5000_LangMsg_047_FR@lo16		; low half of HDAE5000_LangMsg_047_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg048:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg048_LangDE
	pushw HDAE5000_LangMsg_048_EN@hi16
	pushw	HDAE5000_LangMsg_048_EN@lo16		; low half of HDAE5000_LangMsg_048_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg048_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg048_LangFR
	pushw	HDAE5000_LangMsg_048_DE@hi16
	pushw	HDAE5000_LangMsg_048_DE@lo16		; low half of HDAE5000_LangMsg_048_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg048_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_048_FR@hi16
	pushw	HDAE5000_LangMsg_048_FR@lo16		; low half of HDAE5000_LangMsg_048_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg049:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg049_LangDE
	pushw HDAE5000_LangMsg_049_EN@hi16
	pushw	HDAE5000_LangMsg_049_EN@lo16		; low half of HDAE5000_LangMsg_049_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg049_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg049_LangFR
	pushw	HDAE5000_LangMsg_049_DE@hi16
	pushw	HDAE5000_LangMsg_049_DE@lo16		; low half of HDAE5000_LangMsg_049_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg049_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_049_FR@hi16
	pushw	HDAE5000_LangMsg_049_FR@lo16		; low half of HDAE5000_LangMsg_049_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg050:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg050_LangDE
	pushw HDAE5000_LangMsg_050_EN@hi16
	pushw	HDAE5000_LangMsg_050_EN@lo16		; low half of HDAE5000_LangMsg_050_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg050_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg050_LangFR
	pushw	HDAE5000_LangMsg_050_DE@hi16
	pushw	HDAE5000_LangMsg_050_DE@lo16		; low half of HDAE5000_LangMsg_050_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg050_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_050_FR@hi16
	pushw	HDAE5000_LangMsg_050_FR@lo16		; low half of HDAE5000_LangMsg_050_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg051:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg051_LangDE
	pushw HDAE5000_LangMsg_051_EN@hi16
	pushw	HDAE5000_LangMsg_051_EN@lo16		; low half of HDAE5000_LangMsg_051_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg051_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg051_LangFR
	pushw	HDAE5000_LangMsg_051_DE@hi16
	pushw	HDAE5000_LangMsg_051_DE@lo16		; low half of HDAE5000_LangMsg_051_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg051_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_051_FR@hi16
	pushw	HDAE5000_LangMsg_051_FR@lo16		; low half of HDAE5000_LangMsg_051_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg052:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg052_LangDE
	pushw HDAE5000_LangMsg_052_EN@hi16
	pushw	HDAE5000_LangMsg_052_EN@lo16		; low half of HDAE5000_LangMsg_052_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg052_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg052_LangFR
	pushw	HDAE5000_LangMsg_052_DE@hi16
	pushw	HDAE5000_LangMsg_052_DE@lo16		; low half of HDAE5000_LangMsg_052_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg052_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_052_FR@hi16
	pushw	HDAE5000_LangMsg_052_FR@lo16		; low half of HDAE5000_LangMsg_052_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg053:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg053_LangDE
	pushw HDAE5000_LangMsg_053_EN@hi16
	pushw	HDAE5000_LangMsg_053_EN@lo16		; low half of HDAE5000_LangMsg_053_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg053_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg053_LangFR
	pushw	HDAE5000_LangMsg_053_DE@hi16
	pushw	HDAE5000_LangMsg_053_DE@lo16		; low half of HDAE5000_LangMsg_053_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg053_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_053_FR@hi16
	pushw	HDAE5000_LangMsg_053_FR@lo16		; low half of HDAE5000_LangMsg_053_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg054:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg054_LangDE
	pushw HDAE5000_LangMsg_054_EN@hi16
	pushw	HDAE5000_LangMsg_054_EN@lo16		; low half of HDAE5000_LangMsg_054_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg054_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg054_LangFR
	pushw	HDAE5000_LangMsg_054_DE@hi16
	pushw	HDAE5000_LangMsg_054_DE@lo16		; low half of HDAE5000_LangMsg_054_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg054_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_054_FR@hi16
	pushw	HDAE5000_LangMsg_054_FR@lo16		; low half of HDAE5000_LangMsg_054_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg055:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg055_LangDE
	pushw HDAE5000_LangMsg_055_EN@hi16
	pushw	HDAE5000_LangMsg_055_EN@lo16		; low half of HDAE5000_LangMsg_055_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg055_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg055_LangFR
	pushw	HDAE5000_LangMsg_055_DE@hi16
	pushw	HDAE5000_LangMsg_055_DE@lo16		; low half of HDAE5000_LangMsg_055_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg055_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_055_FR@hi16
	pushw	HDAE5000_LangMsg_055_FR@lo16		; low half of HDAE5000_LangMsg_055_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg056:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg056_LangDE
	pushw HDAE5000_LangMsg_056_EN@hi16
	pushw	HDAE5000_LangMsg_056_EN@lo16		; low half of HDAE5000_LangMsg_056_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg056_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg056_LangFR
	pushw	HDAE5000_LangMsg_056_DE@hi16
	pushw	HDAE5000_LangMsg_056_DE@lo16		; low half of HDAE5000_LangMsg_056_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg056_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_056_FR@hi16
	pushw	HDAE5000_LangMsg_056_FR@lo16		; low half of HDAE5000_LangMsg_056_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg057:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg057_LangDE
	pushw HDAE5000_LangMsg_057_EN@hi16
	pushw	HDAE5000_LangMsg_057_EN@lo16		; low half of HDAE5000_LangMsg_057_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg057_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg057_LangFR
	pushw	HDAE5000_LangMsg_057_DE@hi16
	pushw	HDAE5000_LangMsg_057_DE@lo16		; low half of HDAE5000_LangMsg_057_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg057_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_057_FR@hi16
	pushw	HDAE5000_LangMsg_057_FR@lo16		; low half of HDAE5000_LangMsg_057_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg058:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg058_LangDE
	pushw HDAE5000_LangMsg_058_EN@hi16
	pushw	HDAE5000_LangMsg_058_EN@lo16		; low half of HDAE5000_LangMsg_058_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg058_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg058_LangFR
	pushw	HDAE5000_LangMsg_058_DE@hi16
	pushw	HDAE5000_LangMsg_058_DE@lo16		; low half of HDAE5000_LangMsg_058_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg058_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_058_FR@hi16
	pushw	HDAE5000_LangMsg_058_FR@lo16		; low half of HDAE5000_LangMsg_058_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg059:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg059_LangDE
	pushw HDAE5000_LangMsg_059_EN@hi16
	pushw	HDAE5000_LangMsg_059_EN@lo16		; low half of HDAE5000_LangMsg_059_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg059_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg059_LangFR
	pushw	HDAE5000_LangMsg_059_DE@hi16
	pushw	HDAE5000_LangMsg_059_DE@lo16		; low half of HDAE5000_LangMsg_059_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg059_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_059_FR@hi16
	pushw	HDAE5000_LangMsg_059_FR@lo16		; low half of HDAE5000_LangMsg_059_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg060:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg060_LangDE
	pushw HDAE5000_LangMsg_060_EN@hi16
	pushw	HDAE5000_LangMsg_060_EN@lo16		; low half of HDAE5000_LangMsg_060_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg060_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg060_LangFR
	pushw	HDAE5000_LangMsg_060_DE@hi16
	pushw	HDAE5000_LangMsg_060_DE@lo16		; low half of HDAE5000_LangMsg_060_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg060_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_060_FR@hi16
	pushw	HDAE5000_LangMsg_060_FR@lo16		; low half of HDAE5000_LangMsg_060_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg061:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg061_LangDE
	pushw HDAE5000_LangMsg_061_EN@hi16
	pushw	HDAE5000_LangMsg_061_EN@lo16		; low half of HDAE5000_LangMsg_061_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg061_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg061_LangFR
	pushw	HDAE5000_LangMsg_061_DE@hi16
	pushw	HDAE5000_LangMsg_061_DE@lo16		; low half of HDAE5000_LangMsg_061_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg061_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_061_FR@hi16
	pushw	HDAE5000_LangMsg_061_FR@lo16		; low half of HDAE5000_LangMsg_061_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg062:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg062_LangDE
	pushw HDAE5000_LangMsg_062_EN@hi16
	pushw	HDAE5000_LangMsg_062_EN@lo16		; low half of HDAE5000_LangMsg_062_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg062_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg062_LangFR
	pushw	HDAE5000_LangMsg_062_DE@hi16
	pushw	HDAE5000_LangMsg_062_DE@lo16		; low half of HDAE5000_LangMsg_062_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg062_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_062_FR@hi16
	pushw	HDAE5000_LangMsg_062_FR@lo16		; low half of HDAE5000_LangMsg_062_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg064:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg064_LangDE
	pushw HDAE5000_LangMsg_064_EN@hi16
	pushw	HDAE5000_LangMsg_064_EN@lo16		; low half of HDAE5000_LangMsg_064_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg064_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg064_LangFR
	pushw	HDAE5000_LangMsg_064_DE@hi16
	pushw	HDAE5000_LangMsg_064_DE@lo16		; low half of HDAE5000_LangMsg_064_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg064_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_064_FR@hi16
	pushw	HDAE5000_LangMsg_064_FR@lo16		; low half of HDAE5000_LangMsg_064_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg200:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg200_LangDE
	pushw HDAE5000_LangMsg_200_EN@hi16
	pushw	HDAE5000_LangMsg_200_EN@lo16		; low half of HDAE5000_LangMsg_200_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg200_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg200_LangFR
	pushw	HDAE5000_LangMsg_200_DE@hi16
	pushw	HDAE5000_LangMsg_200_DE@lo16		; low half of HDAE5000_LangMsg_200_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg200_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_200_FR@hi16
	pushw	HDAE5000_LangMsg_200_FR@lo16		; low half of HDAE5000_LangMsg_200_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg201:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg201_LangDE
	pushw HDAE5000_LangMsg_201_EN@hi16
	pushw	HDAE5000_LangMsg_201_EN@lo16		; low half of HDAE5000_LangMsg_201_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg201_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg201_LangFR
	pushw	HDAE5000_LangMsg_201_DE@hi16
	pushw	HDAE5000_LangMsg_201_DE@lo16		; low half of HDAE5000_LangMsg_201_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg201_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_201_FR@hi16
	pushw	HDAE5000_LangMsg_201_FR@lo16		; low half of HDAE5000_LangMsg_201_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg202:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg202_LangDE
	pushw HDAE5000_LangMsg_202_EN@hi16
	pushw	HDAE5000_LangMsg_202_EN@lo16		; low half of HDAE5000_LangMsg_202_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg202_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg202_LangFR
	pushw	HDAE5000_LangMsg_202_DE@hi16
	pushw	HDAE5000_LangMsg_202_DE@lo16		; low half of HDAE5000_LangMsg_202_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg202_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_202_FR@hi16
	pushw	HDAE5000_LangMsg_202_FR@lo16		; low half of HDAE5000_LangMsg_202_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg203:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg203_LangDE
	pushw HDAE5000_LangMsg_203_EN@hi16
	pushw	HDAE5000_LangMsg_203_EN@lo16		; low half of HDAE5000_LangMsg_203_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg203_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg203_LangFR
	pushw	HDAE5000_LangMsg_203_DE@hi16
	pushw	HDAE5000_LangMsg_203_DE@lo16		; low half of HDAE5000_LangMsg_203_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg203_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_203_FR@hi16
	pushw	HDAE5000_LangMsg_203_FR@lo16		; low half of HDAE5000_LangMsg_203_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg206:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg206_LangDE
	pushw HDAE5000_LangMsg_206_EN@hi16
	pushw	HDAE5000_LangMsg_206_EN@lo16		; low half of HDAE5000_LangMsg_206_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg206_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg206_LangFR
	pushw	HDAE5000_LangMsg_206_DE@hi16
	pushw	HDAE5000_LangMsg_206_DE@lo16		; low half of HDAE5000_LangMsg_206_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg206_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_206_FR@hi16
	pushw	HDAE5000_LangMsg_206_FR@lo16		; low half of HDAE5000_LangMsg_206_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg207:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg207_LangDE
	pushw HDAE5000_LangMsg_207_EN@hi16
	pushw	HDAE5000_LangMsg_207_EN@lo16		; low half of HDAE5000_LangMsg_207_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg207_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg207_LangFR
	pushw	HDAE5000_LangMsg_207_DE@hi16
	pushw	HDAE5000_LangMsg_207_DE@lo16		; low half of HDAE5000_LangMsg_207_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg207_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_207_FR@hi16
	pushw	HDAE5000_LangMsg_207_FR@lo16		; low half of HDAE5000_LangMsg_207_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg208:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg208_LangDE
	pushw HDAE5000_LangMsg_208_EN@hi16
	pushw	HDAE5000_LangMsg_208_EN@lo16		; low half of HDAE5000_LangMsg_208_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg208_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg208_LangFR
	pushw	HDAE5000_LangMsg_208_DE@hi16
	pushw	HDAE5000_LangMsg_208_DE@lo16		; low half of HDAE5000_LangMsg_208_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg208_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_208_FR@hi16
	pushw	HDAE5000_LangMsg_208_FR@lo16		; low half of HDAE5000_LangMsg_208_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg209:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg209_LangDE
	pushw HDAE5000_LangMsg_209_EN@hi16
	pushw	HDAE5000_LangMsg_209_EN@lo16		; low half of HDAE5000_LangMsg_209_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg209_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg209_LangFR
	pushw	HDAE5000_LangMsg_209_DE@hi16
	pushw	HDAE5000_LangMsg_209_DE@lo16		; low half of HDAE5000_LangMsg_209_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg209_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_209_FR@hi16
	pushw	HDAE5000_LangMsg_209_FR@lo16		; low half of HDAE5000_LangMsg_209_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg210:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg210_LangDE
	pushw HDAE5000_LangMsg_210_EN@hi16
	pushw	HDAE5000_LangMsg_210_EN@lo16		; low half of HDAE5000_LangMsg_210_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg210_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg210_LangFR
	pushw	HDAE5000_LangMsg_210_DE@hi16
	pushw	HDAE5000_LangMsg_210_DE@lo16		; low half of HDAE5000_LangMsg_210_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg210_LangFR:
	cpw	(xsp+4), 0x0003
	jrl	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_210_FR@hi16
	pushw	HDAE5000_LangMsg_210_FR@lo16		; low half of HDAE5000_LangMsg_210_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jrl	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg211:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg211_LangDE
	pushw HDAE5000_LangMsg_211_EN@hi16
	pushw	HDAE5000_LangMsg_211_EN@lo16		; low half of HDAE5000_LangMsg_211_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg211_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg211_LangFR
	pushw	HDAE5000_LangMsg_211_DE@hi16
	pushw	HDAE5000_LangMsg_211_DE@lo16		; low half of HDAE5000_LangMsg_211_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg211_LangFR:
	cpw	(xsp+4), 0x0003
	jr	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_211_FR@hi16
	pushw	HDAE5000_LangMsg_211_FR@lo16		; low half of HDAE5000_LangMsg_211_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jr	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_Msg212:
	cpw	(xsp+4), 0x0001
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg212_LangDE
	pushw HDAE5000_LangMsg_212_EN@hi16
	pushw	HDAE5000_LangMsg_212_EN@lo16		; low half of HDAE5000_LangMsg_212_EN
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg212_LangDE:
	cpw	(xsp+4), 0x0002
	jr	nz, HDAE5000_AcLanguageText1Proc_Msg212_LangFR
	pushw	HDAE5000_LangMsg_212_DE@hi16
	pushw	HDAE5000_LangMsg_212_DE@lo16		; low half of HDAE5000_LangMsg_212_DE
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Msg212_LangFR:
	cpw	(xsp+4), 0x0003
	jr	nz, HDAE5000_AcLanguageText1Proc_Join6
	pushw HDAE5000_LangMsg_212_FR@hi16
	pushw	HDAE5000_LangMsg_212_FR@lo16		; low half of HDAE5000_LangMsg_212_FR
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	jr	t, HDAE5000_AcLanguageText1Proc_Join6
HDAE5000_AcLanguageText1Proc_NoMessage:
	pushw HDAE5000_LangMsg_NoMessage@hi16
	pushw	HDAE5000_LangMsg_NoMessage@lo16		; low half of HDAE5000_LangMsg_NoMessage
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_AcLanguageText1Proc_Join6:
	lda	xwa, (xsp+6)
	ld	xbc, xwa
	ld	xwa, (xsp+214)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
HDAE5000_AcLanguageText1Proc_Epilogue:
	pop xiz
	lda xsp, (xsp+214:16)
	ret

HDAE5000_LyricBoxProc:
	; registered as "LyricBoxProc" in HDAE5000_ClassProc_Table
	lda	xsp, (xsp-22)
	push	xiz
	ld (xsp + 0x0e), xde
	ld (xsp + 0x12), xbc
	ld (xsp + 0x16), xwa
	ld xwa, (xsp + 0x12)
	cp	xwa, EVT_SW_IN
	jrl	z, HDAE5000_LyricBoxProc_OnSwIn
	cp	xwa, EVT_HIDE
	jrl	z, HDAE5000_LyricBoxProc_OnHide
	cp	xwa, EVT_SHOW
	jrl	z, HDAE5000_LyricBoxProc_OnShow
	cp	xwa, EVT_PAINT
	jr	z, HDAE5000_LyricBoxProc_OnPaint
	cp	xwa, EVT_DRAW
	jr	z, HDAE5000_LyricBoxProc_Ev01C0000D
	sub	xwa, EVT_HDAE_INIT_LYRIC_PARAM
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LyricBoxProc_Default1
	cp	xwa, 0x00000006
	jrl	gt, HDAE5000_LyricBoxProc_Default1
	add	xwa, xwa
	add	xwa, HDAE5000_LyricBoxProc_CaseTable1
	ld	wa, (xwa)
	lda xix, (HDAE5000_LyricBoxProc_Ev01C0000D:24)
	jp	t, (xix+wa)
HDAE5000_LyricBoxProc_Ev01C0000D:
	ld xwa, (xsp + 0x16)
	ld xbc, (xsp + 0x12)
	ld xde, (xsp + 0x0e)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_LYRIC_ALL_DRAW
	ld	xde, 0:i3
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_LyricBoxProc_Epilogue
HDAE5000_LyricBoxProc_OnPaint:
	ld xwa, (xsp + 0x16)
	ld xbc, (xsp + 0x12)
	ld xde, (xsp + 0x0e)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_INIT_LYRIC_PARAM
	ld	xde, 0:i3
	call	(xhl)
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_INIT_LYRICS
	ld	xde, 0:i3
	call	(xhl)
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_LYRIC_ALL_DRAW
	ld	xde, 1:i3
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_LyricBoxProc_Epilogue
HDAE5000_LyricBoxProc_Ev01CA0003:
	cp	(HDAE5000_RAM_LyricLines_Init+210:24), 0
	jrl	nz, HDAE5000_LyricBoxProc_Ev01CA0003_Join3
	ld	(HDAE5000_RAM_LyricLines_Init+210:24), 1
	lda xwa, (0x22a08c:24)
	ld	xbc, xwa
	ld xwa, (xsp + 0x16)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_RootFnTable)
	ld	xhl, (xde + RootFn_GetClientBox)
	call	(xhl)
	incw	2, (0x22A08C:24)
	incw	4, (0x22A08E:24)
	decw	1, (0x22A090:24)
	decw	2, (0x22A092:24)
	ld	wa, (0x22A08C:24)
	inc	2, wa
	ld	(0x22a094), wa
	ld	wa, (0x22A08E:24)
	dec	2, wa
	ld	(0x22a096), wa
	ld	wa, (0x22A090:24)
	dec	2, wa
	ld	(0x22a098), wa
	ld	wa, (0x22A096:24)
	add	wa, 0x000d
	ld	(0x22a09a), wa
	ld	wa, (0x22A08C:24)
	inc	6, wa
	ld	(0x22a09c), wa
	ld	wa, (0x22A08E:24)
	inc	2, wa
	ld	(0x22a09e), wa
	lda xwa, (0x22a0a0:24)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_GetClientBox)
	ld	xwa, HDAE5000_OBJ_MeasureinLyric
	call	(xhl)
	ld	wa, (0x22A0A0:24)
	add	wa, 0x0014
	ld	(0x22a0a8), wa
	ld	wa, (0x22A0A2:24)
	inc	5, wa
	ld	(0x22a0aa), wa
	lda xwa, (0x22a0ac:24)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_GetClientBox)
	ld	xwa, HDAE5000_OBJ_TimeSigInLyric
	call	(xhl)
	ld	wa, (0x22A0AC:24)
	add	wa, 0x0014
	ld	(0x22a0b4), wa
	ld	wa, (0x22A0AE:24)
	inc	5, wa
	ld	(0x22a0b6), wa
	ldw	(0x230774:24), 0
	ld	hl, 0:i3
	cp	hl, 0x0022
	jr	ge, HDAE5000_LyricBoxProc_Ev01CA0003_Join
HDAE5000_LyricBoxProc_Ev01CA0003_Loop:
	ld	wa, hl
	sla	wa, 0x02
	ld	bc, wa
	inc	4, bc
	ld	wa, (0x22A08C:24)
	add	wa, 0x0088
	ld	de, wa
	sub	de, bc
	ld	wa, hl
	add	wa, wa
	lda xbc, (0x230776:24)
	ld	(xbc+wa), de
	inc	1, hl
	cp	hl, 0x0022
	jr	lt, HDAE5000_LyricBoxProc_Ev01CA0003_Loop
HDAE5000_LyricBoxProc_Ev01CA0003_Join:
	ld	hl, 0:i3
	cp	hl, 0x0022
	jr	ge, HDAE5000_LyricBoxProc_Ev01CA0003_Join2
HDAE5000_LyricBoxProc_Ev01CA0003_Loop2:
	ld	wa, hl
	add	wa, wa
	lda xbc, (0x2307c0:24)
	ld	de, hl
	sla	de, 0x03
	ld	(xbc+wa), de
	inc	1, hl
	cp	hl, 0x0022
	jr	lt, HDAE5000_LyricBoxProc_Ev01CA0003_Loop2
HDAE5000_LyricBoxProc_Ev01CA0003_Join2:
	ld	hl, 0:i3
	cp	hl, 6:i3
	jr	ge, HDAE5000_LyricBoxProc_Ev01CA0003_Join3
HDAE5000_LyricBoxProc_Ev01CA0003_Loop3:
	ld	wa, hl
	muls	wa, 0x0012
	add	wa, (0x22A08E:24)
	add	a, 0x0f
	ld	c, a
	lda xwa, (0x2307ba:24)
	ld	(xwa+hl), c
	inc	1, hl
	cp	hl, 6:i3
	jr	lt, HDAE5000_LyricBoxProc_Ev01CA0003_Loop3
HDAE5000_LyricBoxProc_Ev01CA0003_Join3:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_LyricBoxProc_Epilogue
HDAE5000_LyricBoxProc_Ev01CA0007:
	ld xwa, (xsp + 0x0e)
	cp	xwa, 0x00000001
	jr	z, HDAE5000_LyricBoxProc_Ev01CA0007_Skip2
	or xwa, xwa
	jr	z, HDAE5000_LyricBoxProc_Ev01CA0007_Skip
	ld	xhl, 0:i3
	jrl	t, HDAE5000_LyricBoxProc_Epilogue
HDAE5000_LyricBoxProc_Ev01CA0007_Skip:
	cpw	(0x23076e:24), 0
	jr	z, HDAE5000_LyricBoxProc_Ev01CA0007_Join
	ldw	(0x23076e:24), 0
	ldw	(0x230770:24), 1
	calr	HDAE5000_Lyrics_ResetState
	ld	xwa, 0:i3
	calr	HDAE5000_Lyrics_ReadSongInfo
	ldw	(0x22A0B8:24), 0
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_Lyrics_FillLines
	ld	(0x230818), hl
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	call	(xhl)
	ldw	(0x230770:24), 0
HDAE5000_LyricBoxProc_Ev01CA0007_Join:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_LyricBoxProc_Epilogue
HDAE5000_LyricBoxProc_Ev01CA0007_Skip2:
	calr	HDAE5000_Lyrics_ResetState
	ld	xwa, 0:i3
	calr	HDAE5000_Lyrics_ReadSongInfo
	ldw	(0x22A0B8:24), 0
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_LyricBoxProc_Epilogue
HDAE5000_LyricBoxProc_Ev01CA0008:
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld	(0x22a088), xhl
	ldw	(xsp + 0x04), 0
	cpw	(xsp+4), 0x0006
	jrl	nc, HDAE5000_LyricBoxProc_Ev01CA0008_Join
HDAE5000_LyricBoxProc_Ev01CA0008_Loop:
	ld	wa, (xsp+4)
	extz xwa
	ld	xbc, 0x00000023
	call	HDAE5000_Multiply
	ld	xwa, HDAE5000_RAM_LyricLines
	add	xwa, xhl
	push xwa
	call HDAE5000_StrLen
	inc 4, xsp
	ld	wa, (xsp+4)
	extz xwa
	add	xwa, 0x00000010
	ld	xbc, 0x002304d8
	add	xbc, xwa
	ld_dst8_ri xbc, l		; ld (XBC),L
	ld	wa, (0x2307b8:24)
	ld (xsp + 0x0a), wa
	ld	wa, (xsp+4)
	extz xwa
	ld	xbc, 0x002307ba
	add	xbc, xwa
	ld	a, (xbc)
	extz wa
	ld (xsp + 0x0c), wa
	lda xhl, (0x22a08c:24)
	lda	xbc, (xsp+10)
	lda	xde, (HDAE5000_Str_Blank34:24)
	ld	xwa, (0x22a088)
	ld xwa, (xwa + 0x20)
	push xwa
	ld	xwa, (0x22a088:24)
	pushm	(xwa+36)
	ld	xwa, (0x22a088)
	pushm	(xwa+22)
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	ld	wa, (xsp+4)
	extz xwa
	add	xwa, 0x00000010
	ld	xbc, 0x002304d8
	add	xbc, xwa
	ld	a, (xbc)
	extz wa
	add	wa, wa
	lda xbc, (0x230774:24)
	ld	wa, (xbc+wa)
	ld (xsp + 0x0a), wa
	ld	a, (0x2304EE:24)
	extz wa
	cp	wa, (xsp+4)
	jr	ule, HDAE5000_LyricBoxProc_Ev01CA0008_Skip
	lda	xwa, (0x22a08c:24)
	ld	(xsp + 6:8), xwa
	lda	xwa, (xsp+10)
	ld	xiz, xwa
	ld	wa, (xsp+4)
	extz xwa
	ld	xbc, 0x00000023
	call	HDAE5000_Multiply
	ld	xde, HDAE5000_RAM_LyricLines
	add	xde, xhl
	ld	xwa, (0x22a088)
	ld xwa, (xwa + 0x20)
	push xwa
	ld	xwa, (0x22a088)
	pushm	(xwa+38)
	ld	xwa, (0x22a088:24)
	pushm	(xwa+22)
	ld	xwa, (xsp + 0x0e)
	ld	xbc, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	jr	t, HDAE5000_LyricBoxProc_Ev01CA0008_Next
HDAE5000_LyricBoxProc_Ev01CA0008_Skip:
	lda	xwa, (0x22a08c:24)
	ld	(xsp + 6:8), xwa
	lda	xwa, (xsp+10)
	ld	xiz, xwa
	ld	wa, (xsp+4)
	extz xwa
	ld	xbc, 0x00000023
	call	HDAE5000_Multiply
	ld	xde, HDAE5000_RAM_LyricLines
	add	xde, xhl
	ld	xwa, (0x22a088)
	ld xwa, (xwa + 0x20)
	push xwa
	ld	xwa, (0x22a088)
	pushm	(xwa+36)
	ld	xwa, (0x22a088:24)
	pushm	(xwa+22)
	ld	xwa, (xsp + 0x0e)
	ld	xbc, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
HDAE5000_LyricBoxProc_Ev01CA0008_Next:
	incw	1, (xsp+4)
	cpw	(xsp+4), 0x0006
	jrl	c, HDAE5000_LyricBoxProc_Ev01CA0008_Loop
HDAE5000_LyricBoxProc_Ev01CA0008_Join:
	lda xwa, (0x22a094:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_DrawFrame)
	ldw	bc, 0x00f9
	call	(xhl)
	lda xhl, (0x22a08c:24)
	lda xbc, (0x22a09c:24)
	lda xde, (0x230690:24)
	ld	xwa, (0x22a088)
	ld xwa, (xwa + 0x28)
	push xwa
	ld	xwa, (0x22a088)
	pushm	(xwa+44)
	ld	xwa, (0x22a088)
	pushm	(xwa+22)
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	ld xwa, (xsp + 0x0e)
	cp	xwa, 0x00000001
	jrl	nz, HDAE5000_LyricBoxProc_Ev01CA0008_Join2
	lda xwa, (0x230710:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_Conductor
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	lda xwa, (0x230734:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_SongTitle
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_DRAW_SYLLABLE
	ld	xde, 4:i3
	call	(xhl)
	lda xwa, (HDAE5000_Str_Reset:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_bottom01
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	lda xwa, (HDAE5000_Str_Load:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_bottom08
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
HDAE5000_LyricBoxProc_Ev01CA0008_Join2:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_LyricBoxProc_Epilogue
HDAE5000_LyricBoxProc_Ev01CA0009:
	ld xwa, (xsp + 0x0e)
	cp	xwa, 0x00000004
	jrl	z, HDAE5000_LyricBoxProc_Skip4
	cp	xwa, 0x00000003
	jrl	z, HDAE5000_LyricBoxProc_Skip3
	cp	xwa, 0x00000002
	jrl	z, HDAE5000_LyricBoxProc_Skip2
	cp	xwa, 0x00000001
	jr	z, HDAE5000_LyricBoxProc_Skip
	or xwa, xwa
	jr	nz, HDAE5000_LyricBoxProc_Default1
	lda xhl, (0x22a08c:24)
	lda xbc, (0x230822:24)
	lda	xde, (0x23051a:24)
	ld	xwa, (0x22a088)
	ld xwa, (xwa + 0x20)
	push xwa
	ld	xwa, (0x22a088:24)
	pushm	(xwa+38)
	ld	xwa, (0x22a088)
	pushm	(xwa+22)
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
HDAE5000_LyricBoxProc_Default1:
	ld xwa, (xsp + 0x16)
	ld xbc, (xsp + 0x12)
	ld xde, (xsp + 0x0e)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl	t, HDAE5000_LyricBoxProc_Epilogue
HDAE5000_LyricBoxProc_Skip:
	lda xhl, (0x22a08c:24)
	lda xbc, (0x230822:24)
	lda	xde, (0x23051a:24)
	ld	xwa, (0x22a088)
	ld xwa, (xwa + 0x20)
	push xwa
	ld	xwa, (0x22a088:24)
	pushm	(xwa+36)
	ld	xwa, (0x22a088)
	pushm	(xwa+22)
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	jr	t, HDAE5000_LyricBoxProc_Default1
HDAE5000_LyricBoxProc_Skip2:
	lda xhl, (0x22a08c:24)
	lda xbc, (0x22a09c:24)
	lda xde, (0x230690:24)
	ld	xwa, (0x22a088)
	ld xwa, (xwa + 0x28)
	push xwa
	ld	xwa, (0x22a088)
	pushm	(xwa+44)
	ld	xwa, (0x22a088)
	pushm	(xwa+22)
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	jrl	t, HDAE5000_LyricBoxProc_Default1
HDAE5000_LyricBoxProc_Skip3:
	lda xwa, (0x22a0a0:24)
	ld	xhl, xwa
	lda xwa, (0x22a0a8:24)
	ld	xbc, xwa
	lda xwa, (0x230756:24)
	ld	xde, xwa
	ld	xwa, (0x22a088)
	ld xwa, (xwa + 0x28)
	push xwa
	pushw 0x00ff
	pushw 0x0008
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	jrl	t, HDAE5000_LyricBoxProc_Default1
HDAE5000_LyricBoxProc_Skip4:
	lda xwa, (0x22a0ac:24)
	ld	xhl, xwa
	lda xwa, (0x22a0b4:24)
	ld	xbc, xwa
	lda xwa, (0x23074c:24)
	ld	xde, xwa
	ld	xwa, (0x22a088)
	ld xwa, (xwa + 0x28)
	push xwa
	pushw 0x00ff
	pushw 0x0008
	ld	xwa, xhl
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_DrawString)
	call	(xhl)
	jrl	t, HDAE5000_LyricBoxProc_Default1
HDAE5000_LyricBoxProc_Ev01CA0004:
	cpw	(0x230770:24), 0
	jrl	nz, HDAE5000_LyricBoxProc_Default1
	ld xwa, (xsp + 0x0e)
	ld	bc, 1:i3
	calr	HDAE5000_Lyrics_PlayToPosition
	ld	wa, (0x23081c:24)
	cp	wa, (0x23076c:24)
	jr	c, HDAE5000_LyricBoxProc_Ev01CA0004_Join
	ld	wa, (0x23076a:24)
	ld	(0x23076c), wa
	incw	1, (0x23081a:24)
	ldw	(0x23081c:24), 0
	ld	xwa, (HDAE5000_RAM_LyricBoxObj)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_BEAT_MESSAGE
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_LyricBoxProc_Ev01CA0004_Join:
	incw	1, (0x23081c:24)
	ld	xwa, 1:i3
	add	(0x23081e:24), xwa
	jrl	t, HDAE5000_LyricBoxProc_Default1
HDAE5000_LyricBoxProc_Ev01CA0005:
	incw	1, (0x230768:24)
	ld	a, (0x230762:24)
	extz wa
	cp	(0x230768:24), wa
	jr	ule, HDAE5000_LyricBoxProc_Ev01CA0005_Join
	ld	a, (0x230760:24)
	ld	(0x230762:24), a
	incw	1, (0x230766:24)
	ldw	(0x230768:24), 1
HDAE5000_LyricBoxProc_Ev01CA0005_Join:
	ld	wa, (0x230768:24)
	pushw wa
	ld	wa, (0x230766:24)
	pushw wa
	pushw HDAE5000_Fmt_03i_i@hi16
	pushw	HDAE5000_Fmt_03i_i@lo16		; low half of HDAE5000_Fmt_03i_i
	lda xwa, (0x230756:24)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_DRAW_SYLLABLE
	ld	xde, 3:i3
	call	(xhl)
	jrl	t, HDAE5000_LyricBoxProc_Default1
HDAE5000_LyricBoxProc_OnShow:
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld	(0x22a088), xhl
	ld xwa, (xhl + 0x1c)
	ldw	(xwa), 0x0001
	ld xwa, (xsp + 0x16)
	ld	(HDAE5000_RAM_LyricBoxObj), xwa
	ldw	(0x23076e:24), 1
	jrl	t, HDAE5000_LyricBoxProc_Default1
HDAE5000_LyricBoxProc_OnHide:
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld	(0x22a088), xhl
	ld xwa, (xhl + 0x1c)
	ldw	(xwa), 0x0000
	ld	xwa, 0xffffffff
	ld	(HDAE5000_RAM_LyricBoxObj), xwa
	jrl	t, HDAE5000_LyricBoxProc_Default1
HDAE5000_LyricBoxProc_OnSwIn:
	ld xde, (xsp + 0x0e)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	ld	xwa, xhl
	cp	xwa, 0x00000007
	jrl	ugt, HDAE5000_LyricBoxProc_Default2
	add	xwa, xwa
	add	xwa, HDAE5000_LyricBoxProc_CaseTable2
	ld	wa, (xwa)
	lda xix, (HDAE5000_LyricBoxProc_OnReset:24)
	jp	t, (xix+wa)
; HDAE5000_LyricBoxProc_OnReset: EVT_SW_IN on the lyric box, edit switch 0 = the bottom01 button captioned "Reset":
;   re-init the lyrics (EVT_HDAE_INIT_LYRICS 1, HDAE5000_Lyrics_FillLines(0,0)) and redraw. Also the base of
;   HDAE5000_LyricBoxProc_CaseTable2. Basis: switch on EVT_MAKE_EDIT_SW_ID + the caption drawn on bottom01.
HDAE5000_LyricBoxProc_OnReset:
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_INIT_LYRICS
	ld	xde, 1:i3
	call	(xhl)
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_Lyrics_FillLines
	ld	(0x230818), hl
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	call	(xhl)
	jr	t, HDAE5000_LyricBoxProc_Default2
; HDAE5000_LyricBoxProc_OnLoad: EVT_SW_IN on the lyric box, edit switch 7 = the bottom08 button captioned "Load":
;   clear the lyric buffer and post EVT_SHOW to the LoadLyricFD screen. Basis: case 7 of
;   HDAE5000_LyricBoxProc_CaseTable2 + the caption drawn on bottom08.
HDAE5000_LyricBoxProc_OnLoad:
	ld xwa, (xsp + 0x16)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld	xix, (xbc + RootFn_GetViewInstance)
	call	(xix)
	ld	(0x22a088), xhl
	calr	HDAE5000_Lyrics_ClearBuffer
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_LoadLyricFD
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_LyricBoxProc_Default2:
	ld	xhl, 0:i3
HDAE5000_LyricBoxProc_Epilogue:
	pop	xiz
	lda	xsp, (xsp+22)
	ret


; ---------------------------------------------------------------------------
; Clear HDAE5000_RAM_LyricBuffer (0x5000 bytes), HDAE5000_RAM_LyricFileLength
; and HDAE5000_RAM_LyricLoaded.  Called by HDAE5000_LyricBoxProc (case 7) and
; HDAE5000_LoadSong_Tlx.
; The lyrics player keeps the whole lyric file in RAM.  Its layout is that of
; a one-track Standard MIDI File with the chunk ids renamed: "TLhd" (+0,
; length 6, format, tracks, division) and "TLtr" (+14, length), events from
; +22, each <VarLen delta> FF <type> <VarLen length> <data> -- see
; HDAE5000_Lyrics_CheckHeaderChunk and HDAE5000_Lyrics_ParseEvent.
; ---------------------------------------------------------------------------
HDAE5000_Lyrics_ClearBuffer:	.include "includes/generated/cc900/HDAE5000_Lyrics_ClearBuffer.s"	; C: cc900/hdae5000_lyrics.c

HDAE5000_Lyrics_CheckFile:	.include "includes/generated/cc900/HDAE5000_Lyrics_CheckFile.s"	; C: cc900/hdae5000_lyrics.c

HDAE5000_Lyrics_LoadTestFile:	.include "includes/generated/cc900/HDAE5000_Lyrics_LoadTestFile.s"	; C: cc900/hdae5000_lyrics.c

; ---------------------------------------------------------------------------
; Advance the lyric display to the song position.  The target tick is
; (XWA+4) * (RAM 0x230868, = division / 12, HDAE5000_Lyrics_ResetState); from
; the last position (RAM 0x23086C) it takes event after event with
; HDAE5000_Lyrics_FindEvent (0x7C = any type) until the running tick passes
; the target or the end-of-track flag (LyricEvent+4) is set, and acts on the
; meta type in HDAE5000_RAM_LyricEvent:
;   0x05  lyric syllable: append it to the current line (<= 39 characters)
;         and move the highlight; CR / LF end the line, and after the third
;         line HDAE5000_Lyrics_FillLines(1, ...) scrolls the window;
;   0x58  time signature: numerator (RAM 0x2307A4), 2^denominator (RAM
;         0x2307A8), printed with "%i/%i" (HDAE5000_Fmt_i_i);
;   0x7E  data "0...": the chord name, printed with "Chord : %s".
; A parse error prints "Fault : No Lyrics loaded or corrupt Data - Code %i
; %i %i".  Redraw requests go to HDAE5000_RAM_LyricBoxObj as SendEvent
; 0x01CA0008 / 0x01CA0009.
; In:  XWA = the parameter of HDAE5000_LyricBoxProc's event 0x01CA0004 (its
;      only caller), C = 1 to redraw
; ---------------------------------------------------------------------------
HDAE5000_Lyrics_PlayToPosition:
	dec 6, xsp
	push xiz
	ld (xsp + 8), c			; save display flag
	ld xiz, xwa			; XIZ = param struct ptr

	; --- Compute sector count, check limits ---
	ld xbc, (0x230810:24); XBC = (0x230810)
	ld xwa, (xiz + 4)		; XWA = param[4]
	call HDAE5000_Multiply		; target tick = (0x230868) * (XWA+4)
	cp (2295820:24), xhl; cp (0x23080c), XHL
	jrl z, .Lfo_epilogue		; same tick as last time: nothing to do
	ld (0x23080c:24), xhl; (0x23080c) = XHL
	ld xwa, (0x230444:24); XWA = (0x230444)
	cp xwa, (2295820:24); cp XWA, (0x23080c)
	jrl ugt, .Lfo_epilogue		; running tick already past it: exit
	cpw (2294836:24), 0		; end-of-track flag
	jrl nz, .Lfo_epilogue		; if abort, exit
	ldw (xsp + 6), 0		; iteration counter = 0

	; --- next event ---
.Lfo_loop:
	ld wa, (0x230814:24)		; WA = (0x230814): position of the last event
	extz xwa
	push xwa			; push offset arg
	ldw wa, 124			; WA = 0x7C
	ld bc, 2:i3
	ldw de, 65534			; DE = 0xFFFE
	calr HDAE5000_Lyrics_FindEvent
	ld xiz, xhl			; XIZ = result
	cpw (2294836:24), 1		; end-of-track flag
	jrl z, .Lfo_epilogue
	cp xiz, 0
	jr le, .Lfo_display		; result <= 0 → display handler

	; --- event found: advance, dispatch on its meta type ---
	ld wa, iz
	add (2295828:24), wa; (0x230814) += IZ
	incw 1, (xsp + 6)		; iteration counter++
	ld wa, (HDAE5000_RAM_LyricEvent:24)
	cp wa, 126			; type 0x7E?
	jrl z, .Lfo_type_7E
	cp wa, 88			; type 0x58?
	jrl z, .Lfo_type_58
	cp wa, 5:i3			; type 5?
	jrl nz, .Lfo_end_iter		; other types: ignored

	; --- type 0x05 (lyric): CR / LF end the line ---
	cp (0x230610:24), 0x0d; cp (0x230610), 0x0D
	jr z, .Lfo_type5_newline
	cp (0x230610:24), 0x0a; cp (0x230610), 0x0A
	jrl nz, .Lfo_string_handler	; not newline → string handler

.Lfo_type5_newline:
	ldw (0x2304e4:24), 0x0000		; (0x2304E4) = 0: column
	cp (0x2304ee:24), 0x02; cp (0x2304EE), 2
	jr nc, .Lfo_file_delete		; from the third line on: scroll
	inc 1, (2295022:24); (0x2304EE)++
	jrl t, .Lfo_epilogue

	; --- parse error: print the fault message ---
.Lfo_display:
	pushm (xsp + 6)		; push iteration counter
	pushw_da 0x72, 0x07, 0x23	; pushw (0x230772)
	push xiz			; push result
	pushw HDAE5000_Fmt_Fault_No_Lyrics_loaded_o@hi16			; width -- high half of HDAE5000_Fmt_Fault_No_Lyrics_loaded_o
	pushw	HDAE5000_Fmt_Fault_No_Lyrics_loaded_o@lo16		; low half of HDAE5000_Fmt_Fault_No_Lyrics_loaded_o
	lda xwa, (0x230690:24); &0x230690
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 16)		; pop 16 bytes
	; Vtable call: notify display
	ld xwa, (HDAE5000_RAM_LyricBoxObj:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)             ; XBC = (XBC + 0x0E0A)
	ld_sril xhl, (xbc + RootFn_SendEvent)             ; XHL = (XBC + 0x0100)
	ld xbc, EVT_HDAE_DRAW_SYLLABLE		; XBC = 0x01CA0009
	ld xde, 2:i3
	call (xhl)
	jrl t, .Lfo_epilogue

	; --- scroll the window one line, refill the last ---
.Lfo_file_delete:
	ld bc, (0x230818:24); BC = (0x230818)
	ld wa, 1:i3
	calr HDAE5000_Lyrics_FillLines
	ld xiz, xhl
	ld (0x2304f0:24), 0x00; (0x2304F0) = 0
	cp xiz, 0
	jr le, .Lfo_skip_iz_store1
	ld (0x230818:24), iz; (0x230818) = IZ
.Lfo_skip_iz_store1:
	cp (xsp + 8), 1		; check display flag
	jr nz, .Lfo_after_vtable1
	; Vtable call: update display
	ld xwa, (HDAE5000_RAM_LyricBoxObj:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_HDAE_LYRIC_ALL_DRAW		; 0x01CA0008
	ld xde, 0:i3
	call (xhl)
.Lfo_after_vtable1:
	jrl t, .Lfo_epilogue

	; --- syllable: append to the line ---
.Lfo_string_handler:
	lda xwa, (0x230610:24); &0x230610
	push xwa
	call HDAE5000_StrLen
	inc 4, xsp			; pop 8 bytes
	ld (xsp + 4), hl		; save strlen result
	cp hl, 34
	jrl gt, .Lfo_epilogue		; if > 39, exit
	lda xwa, (0x230610:24); &0x230610
	push xwa
	lda xwa, (0x23051a:24)		; &0x23051A: syllable copy
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp			; pop stack frame
	; Check cumulative length
	ld wa, (xsp + 4)		; WA = strlen result
	add wa, (2295012:24); WA += (0x2304E4)
	cp wa, 34
	jr ule, .Lfo_after_trunc	; if <= 39, no overflow
	; line full: next line (scroll from the third)
	ldw (0x2304e4:24), 0x0000; (0x2304E4) = 0
	cp (0x2304ee:24), 0x02; cp (0x2304EE), 2
	jr nc, .Lfo_file_delete2		; from the third line on: scroll
	inc 1, (2295022:24); (0x2304EE)++
	jr t, .Lfo_after_trunc

.Lfo_file_delete2:
	ld bc, (0x230818:24); BC = (0x230818)
	ld wa, 1:i3
	calr HDAE5000_Lyrics_FillLines
	ld xiz, xhl
	cp xiz, 0
	jr le, .Lfo_skip_iz_store2
	ld (0x230818:24), iz; (0x230818) = IZ
.Lfo_skip_iz_store2:
	cp (xsp + 8), 1		; check display flag
	jr nz, .Lfo_after_trunc
	; Vtable call
	ld xwa, (HDAE5000_RAM_LyricBoxObj:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_HDAE_LYRIC_ALL_DRAW		; 0x01CA0008
	ld xde, 0:i3
	call (xhl)

	; --- highlight: pixel position of the syllable in the line ---
.Lfo_after_trunc:
	ld a, (0x2304ee:24); A = (0x2304EE)
	extz wa
	add wa, 16			; WA += 0x10
	lda xbc, (0x2304d8:24); XBC = &0x2304D8
	ld	a, (xbc+wa)	; A = (XBC + WA) — table lookup
	extz wa
	ld bc, wa			; BC = index
	add bc, bc			; BC *= 2
	lda xde, (0x230774:24); XDE = &0x230774
	ld wa, (0x2304e4:24); WA = (0x2304E4)
	extz xwa
	add xwa, xwa			; XWA *= 2
	ld xhl, 2295744		; XHL = 0x002307C0
	add xhl, xwa			; XHL += XWA*2
	ld wa, (xhl)			; WA = offset table[position]
	add	wa, (xde+bc)	; WA += (XDE + BC)
	ld (0x230822:24), wa; (0x230822) = WA
	; (0x23087C) = width entry of the current line
	ld a, (0x2304ee:24); A = (0x2304EE)
	extz wa
	lda xbc, (0x2307ba:24); XBC = &0x2307ba
	ld	a, (xbc+wa)	; A = (XBC + WA)
	extz wa
	ld (0x230824:24), wa; (0x230824) = WA
	; Update position
	ld wa, (xsp + 4)		; WA = strlen
	add (2295012:24), wa; (0x2304E4) += strlen
	ld (0x2304f0:24), 0x01; (0x2304F0) = 1
	; Optional vtable call
	cp (xsp + 8), 1		; check display flag
	jr nz, .Lfo_after_vtable3
	ld xwa, (HDAE5000_RAM_LyricBoxObj:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_HDAE_DRAW_SYLLABLE		; 0x01CA0009
	ld xde, 0:i3
	call (xhl)

	; --- Check if at end position ---
.Lfo_after_vtable3:
	ld wa, (0x2304e4:24); WA = (0x2304E4)
	cp wa, (2295832:24); cp WA, (0x230818)
	jrl nz, .Lfo_end_iter		; if not at end, continue
	; Check terminator byte
	cp (0x230826:24), 0x0d; cp (0x230826), 0x0D
	jr nz, .Lfo_not_cr
	cp (0x230826:24), 0x0a; cp (0x230826), 0x0A
	jrl z, .Lfo_end_iter		; if CR+LF, end iteration
.Lfo_not_cr:
	ldw (0x2304e4:24), 0x0000		; (0x2304E4) = 0: column
	cp (0x2304ee:24), 0x02; cp (0x2304EE), 2
	jr nc, .Lfo_file_delete3
	inc 1, (2295022:24)
	jrl t, .Lfo_end_iter

.Lfo_file_delete3:
	ld bc, (0x230818:24); BC = (0x230818)
	ld wa, 1:i3
	calr HDAE5000_Lyrics_FillLines
	ld xiz, xhl
	cp xiz, 0
	jr le, .Lfo_skip_iz_store3
	ld (0x230818:24), iz; (0x230818) = IZ
.Lfo_skip_iz_store3:
	cp (xsp + 8), 1
	jrl nz, .Lfo_end_iter
	; Vtable call
	ld xwa, (HDAE5000_RAM_LyricBoxObj:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_HDAE_LYRIC_ALL_DRAW		; 0x01CA0008
	ld xde, 0:i3
	call (xhl)
	jrl t, .Lfo_end_iter

	; --- type 0x58: time signature ---
.Lfo_type_58:
	ld a, (0x230610:24)		; A = numerator
	ld (0x230760:24), a; (0x230760) = A
	cp (0x230611:24), 0x01		; denominator as a power of two
	jr nz, .Lfo_58_check2
	ld (0x230764:24), 0x02; (0x230764) = 2
	ldw (0x23076a:24), 0x0018; (0x23076A) = 0x0018
.Lfo_58_check2:
	cp (0x230611:24), 0x02
	jr nz, .Lfo_58_check3
	ld (0x230764:24), 0x04
	ldw (0x23076a:24), 0x000c; 0x000C
.Lfo_58_check3:
	cp (0x230611:24), 0x03
	jr nz, .Lfo_58_check4
	ld (0x230764:24), 0x08
	ldw (0x23076a:24), 0x0006; 0x0006
.Lfo_58_check4:
	cp (0x230611:24), 0x04
	jr nz, .Lfo_58_done_checks
	ld (0x230764:24), 0x10; 0x10
	ldw (0x23076a:24), 0x0003; 0x0003
.Lfo_58_done_checks:
	; print "%i/%i"
	ld a, (0x230764:24); A = (0x230764)
	extz wa
	pushw wa
	ld a, (0x230760:24); A = (0x230760)
	extz wa
	pushw wa
	pushw HDAE5000_Fmt_i_i@hi16			; width -- high half of HDAE5000_Fmt_i_i
	pushw	HDAE5000_Fmt_i_i@lo16		; low half of HDAE5000_Fmt_i_i
	lda xwa, (0x23074c:24); &0x23074c
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 12)		; pop 12 bytes
	; Vtable call
	ld xwa, (HDAE5000_RAM_LyricBoxObj:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_HDAE_DRAW_SYLLABLE		; 0x01CA0009
	ld xde, 4:i3
	call (xhl)
	jr t, .Lfo_end_iter

	; --- type 0x7E: chord name when the data starts with '0' ---
.Lfo_type_7E:
	ld a, (0x230610:24); A = (0x230610)
	cp a, 48
	jr nz, .Lfo_end_iter
	; print "Chord : %s" with the rest of the data
	lda xwa, (0x230611:24); &0x230611
	push xwa
	pushw HDAE5000_Fmt_Chord_s@hi16			; width -- high half of HDAE5000_Fmt_Chord_s
	pushw	HDAE5000_Fmt_Chord_s@lo16		; low half of HDAE5000_Fmt_Chord_s
	lda xwa, (0x230690:24); &0x230690
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 12)		; pop 12 bytes
	; Vtable call
	ld xwa, (HDAE5000_RAM_LyricBoxObj:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_HDAE_DRAW_SYLLABLE		; 0x01CA0009
	ld xde, 2:i3
	call (xhl)

	; --- End of iteration: check loop condition ---
.Lfo_end_iter:
	ld xwa, (0x230444:24)		; XWA = (0x230444): running tick
	cp xwa, (2295820:24); cp XWA, (0x23080c)
	jr ugt, .Lfo_epilogue		; if past limit, exit
	cp xiz, 0
	jrl gt, .Lfo_loop		; if XIZ > 0, continue loop

	; --- Epilogue ---
.Lfo_epilogue:
	pop xiz
	inc 6, xsp
	ret

	; ============================================================
	; Reset the lyrics player for a newly loaded file (called by
	; HDAE5000_LyricBoxProc, event 0x01CA0007 and its sibling case):
	; clear the line and position state 0x2304D8-0x2304EF and
	; 0x230438-0x230876, blank the six 40-byte text lines at 0x23A0AA,
	; set (0x230864) = -1 (no position yet) and the info line to "Info",
	; and derive (0x230868) = division / 12 from the TLhd chunk
	; (0x22B43C, big-endian: HDAE5000_SwapBytes16).  The two colour
	; settings pick palette codes 0 -> 0xF9, 1 -> 0x02, 2 -> 0xFC,
	; 3 -> 0x00, 4 -> 0xFB: LyricForeColor (0x229DAD) into (0x23087E),
	; default 0xFC, and LyricBackColor (0x229DAE) into (0x230880),
	; default 0x00 (setting names: the firmware's LyricForeColorCheck /
	; LyricBackColorCheck handlers, which read those bytes).
	; Sets (0x23A19A) = 1.  Returns XHL = 0.
	; ============================================================
HDAE5000_Lyrics_ResetState:	; (381 bytes)

	; --- clear the line state ---
	ld (HDAE5000_RAM_LyricLines_Init+210:24), 0x01		; (0x23A104) = 1
	ldw (0x2304e0:24), 0x0000; (0x2304E0) = 0
	ldw (0x2304e2:24), 0x0000; (0x2304E2) = 0
	ldw (0x2304e4:24), 0x0000; (0x2304E4) = 0
	ld (0x2304ee:24), 0x00; (0x2304EE) = 0
	ldw (0x2304e6:24), 0x0000; (0x2304E6) = 0
	ld (0x2304ef:24), 0x00; (0x2304EF) = 0
	ld xwa, 0:i3
	ld (0x2304d8:24), xwa; (0x2304D8) = 0
	; blank the text lines: 240 bytes at 0x23A0AA

	; --- clear the event/position state ---
	ldw (0x230818:24), 0x0000; (0x230818) = 0
	ldw (0x230814:24), 0x0000; (0x230814) = 0
	ldw (0x230438:24), 0x0000; (0x230438) = 0
	ldw (0x23043a:24), 0x0000; (0x23043A) = 0
	ldw (0x23043c:24), 0x0000; (0x23043C) = 0
	ld xwa, 0:i3
	ld (0x230440:24), xwa; (0x230440) = 0
	ld xwa, 0:i3
	ld (0x230444:24), xwa; (0x230444) = 0
	ld xwa, 0:i3
	ld (0x230448:24), xwa; (0x230448) = 0
	ld xwa, 0:i3
	ld (0x23044c:24), xwa; (0x23044C) = 0
	ld xwa, 0:i3
	ld (0x230450:24), xwa; (0x230450) = 0
	ld xwa, 0:i3
	ld (0x230454:24), xwa; (0x230454) = 0
	ld xwa, 4294967295		; 0xFFFFFFFF
	ld (0x23080c:24), xwa; (0x23080c) = 0xFFFFFFFF
	ldw (0x23081a:24), 0x0000; (0x23081a) = 0
	ldw (0x23081c:24), 0x0000; (0x23081c) = 0
	ld xwa, 0:i3
	ld (0x23081e:24), xwa; (0x23081e) = 0

	; --- info line = "Info" ---
	pushw HDAE5000_Str_Info@hi16		; high half of HDAE5000_Str_Info
	pushw	HDAE5000_Str_Info@lo16		; low half of HDAE5000_Str_Info
	lda xwa, (0x230690:24)		; &0x230690: info line
	push xwa
	call HDAE5000_StrCpy
	inc	8, xsp

	ldw (0x230766:24), 0x0001; (0x230766) = 1
	ldw (0x230768:24), 0x0000; (0x230768) = 0

	; --- (0x230868) = division / 12 ---
	ld wa, (HDAE5000_RAM_LyricBuffer+12:24)		; WA = TLhd division (big-endian)
	calr HDAE5000_SwapBytes16
	ld wa, hl			; result WA = HL
	extz xwa			; zero-extend to 32-bit
	ld xbc, 12			; divisor
	call HDAE5000_UDivMod32	; divide
	ld (0x230810:24), xhl		; (0x230868) = division / 12
	; --- LyricForeColor (0x229DAD) -> palette code (0x23087E) ---
	; --- LyricBackColor (0x229DAE) -> palette code (0x230880) ---
.Lfs_type2_done:
	ld xhl, 0:i3		; return 0
	ret

	; ============================================================
	; Read the song information events of the loaded lyric file
	; (HDAE5000_Lyrics_FindEvent from the start of the track):
	;   meta 0x02 (copyright): up to 50 chars -> 0x230736, else
	;        "No Copyright Info";
	;   meta 0x03 (track name = song title): up to 40 chars ->
	;        0x230768, else "No Song Title" -- copied, as the code
	;        has it, to 0x230736, the copyright line;
	;   meta 0x58 (time signature nn dd): numerator -> (0x2307A4)
	;        and (0x2307A6), 2^dd -> (0x2307A8) for dd = 1..4 (2, 4,
	;        8, 16) with 24 / 12 / 6 / 3 -> (0x2307AE)/(0x2307B0)
	;        (i.e. 48 / 2^dd), else 4/4 and 12; printed with
	;        "%i/%i" into 0x230790.
	; Then SendEvent(lyric box (0x23A19E), 0x01CA0005, 0), reset the
	; parse state and position on the first event.  Returns 0.
	; ============================================================
HDAE5000_Lyrics_ReadSongInfo:	; (564 bytes)

	; --- meta 0x02 (copyright) -> 0x230736, <= 50 chars ---
	ld xwa, 0:i3
	push xwa
	ld wa, 2:i3
	ld bc, 2:i3
	ldw de, 65534			; DE = 0xFFFE
	calr HDAE5000_Lyrics_FindEvent
	cp xhl, 0
	jr le, .Lfl_default1		; if result <= 0, use default

	; found: copy, at most 50
	cpw (2294838:24), 36; cp (0x230436), 0x24
	jr c, .Lfl_short1
	pushw 36
	lda xwa, (0x230610:24); &0x230610
	push xwa
	lda xwa, (0x230710:24); &0x230710
	push xwa
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 10)		; pop 10 bytes
	ld (0x230733:24), 0x00; (0x230733) = null terminator
	jr t, .Lfl_block2
.Lfl_short1:
	; Copy actual length
	ld wa, (0x230436:24); WA = (0x230436)
	pushw wa
	lda xwa, (0x230610:24); &0x230610
	push xwa
	lda xwa, (0x230710:24); &0x230710
	push xwa
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 10)		; pop 10 bytes
	; Null-terminate at actual length
	ld wa, (0x230436:24); WA = (0x230436)
	extz xwa
	ld xbc, 2295568			; XBC = 0x00230710
	add xbc, xwa
	ld (xbc), 0			; *(base + len) = 0
	jr t, .Lfl_block2
.Lfl_default1:
	; not found: "No Copyright Info"
	pushw HDAE5000_Str_NoCopyrightInfo@hi16		; high half of HDAE5000_Str_NoCopyrightInfo
	pushw	HDAE5000_Str_NoCopyrightInfo@lo16		; low half of HDAE5000_Str_NoCopyrightInfo
	lda xwa, (0x230710:24); &0x230710
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp			; pop stack frame

.Lfl_block2:
	; --- meta 0x03 (track name) -> 0x230768, <= 40 chars ---
	ld xwa, 0:i3
	push xwa
	ld wa, 3:i3
	ld bc, 2:i3
	ldw de, 65534			; DE = 0xFFFE
	calr HDAE5000_Lyrics_FindEvent
	cp xhl, 0
	jr le, .Lfl_default2		; if result <= 0, use default

	; found: copy, at most 40
	cpw (2294838:24), 23; cp (0x230436), 0x17
	jr c, .Lfl_short2
	; Truncate at 40
	pushw 23
	lda xwa, (0x230610:24); &0x230610
	push xwa
	lda xwa, (0x230734:24); &0x230734
	push xwa
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 10)
	ld (0x23074a:24), 0x00; (0x23074A) = null terminator
	jr t, .Lfl_block3
.Lfl_short2:
	; Copy actual length
	ld wa, (0x230436:24); WA = (0x230436)
	pushw wa
	lda xwa, (0x230610:24); &0x230610
	push xwa
	lda xwa, (0x230734:24); &0x230734
	push xwa
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 10)
	ld wa, (0x230436:24); WA = (0x230436)
	extz xwa
	ld xbc, 2295604			; XBC = 0x00230734
	add xbc, xwa
	ld (xbc), 0			; *(base + len) = 0
	jr t, .Lfl_block3
.Lfl_default2:
	; not found: "No Song Title" (into 0x230736)
	pushw HDAE5000_Str_NoSongTitle@hi16		; high half of HDAE5000_Str_NoSongTitle
	pushw	HDAE5000_Str_NoSongTitle@lo16		; low half of HDAE5000_Str_NoSongTitle
	lda xwa, (0x230710:24); &0x230710
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp			; pop stack frame

.Lfl_block3:
	; --- meta 0x58 (time signature) ---
	ld xwa, 0:i3
	push xwa
	ldw wa, 88			; WA = 0x58
	ld bc, 2:i3
	ldw de, 65534			; DE = 0xFFFE
	calr HDAE5000_Lyrics_FindEvent
	cp xhl, 0
	jrl le, .Lfl_audio_default		; not found: 4/4

	; found: nn = numerator, dd = log2(denominator)
	ld a, (0x230610:24)		; numerator
	ld (0x230760:24), a; (0x230760) = A
	ld (0x230762:24), a; (0x230762) = A

	; denominator 2^dd -> (0x2307A8), 48 / 2^dd -> (0x2307AE)/(0x2307B0):
	cp (0x230611:24), 0x01		; dd = 1: /2
	jr nz, .Lfl_audio_ch2
	ld (0x230764:24), 0x02
	ldw (0x23076a:24), 0x0018
	ldw (0x23076c:24), 0x0018
.Lfl_audio_ch2:
	cp (0x230611:24), 0x02		; dd = 2: /4
	jr nz, .Lfl_audio_ch3
	ld (0x230764:24), 0x04
	ldw (0x23076a:24), 0x000c
	ldw (0x23076c:24), 0x000c
.Lfl_audio_ch3:
	cp (0x230611:24), 0x03		; dd = 3: /8
	jr nz, .Lfl_audio_ch4
	ld (0x230764:24), 0x08
	ldw (0x23076a:24), 0x0006
	ldw (0x23076c:24), 0x0006
.Lfl_audio_ch4:
	cp (0x230611:24), 0x04		; dd = 4: /16
	jr nz, .Lfl_audio_done
	ld (0x230764:24), 0x10
	ldw (0x23076a:24), 0x0003
	ldw (0x23076c:24), 0x0003
	jr t, .Lfl_audio_done
.Lfl_audio_default:
	; not found: 4/4, 12
	ld (0x230762:24), 0x04; (0x230762) = 4
	ld (0x230760:24), 0x04; (0x230760) = 4
	ld (0x230764:24), 0x04; (0x230764) = 4
	ldw (0x23076a:24), 0x000c; (0x23076A) = 12
	ldw (0x23076c:24), 0x000c; (0x23076C) = 12

.Lfl_audio_done:
	; --- print "%i/%i" into 0x230790 ---
	ld a, (0x230764:24); A = (0x230764)
	extz wa
	pushw wa
	ld a, (0x230760:24); A = (0x230760)
	extz wa
	pushw wa
	pushw HDAE5000_Fmt_i_i_File_Load@hi16			; 0x2E -- high half of HDAE5000_Fmt_i_i_File_Load
	pushw	HDAE5000_Fmt_i_i_File_Load@lo16		; low half of HDAE5000_Fmt_i_i_File_Load
	lda xwa, (0x23074c:24); &0x23074c
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 12)		; pop 12 bytes

	; --- SendEvent(lyric box, 0x01CA0005, 0) ---
	ld xwa, (HDAE5000_RAM_LyricBoxObj:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_HDAE_BEAT_MESSAGE		; XBC = 0x01CA0005
	ld xde, 0:i3
	call (xhl)

	; --- reset the parse state ---
	ldw (HDAE5000_RAM_LyricEvent:24), 0x00ff
	ldw (0x230432:24), 0x0000; (0x230432) = 0
	ldw (0x230434:24), 0x0000; (0x230434) = 0
	ldw (0x230436:24), 0x0000; (0x230436) = 0
	ld (0x2304f0:24), 0x00; (0x2304F0) = 0
	ldw (0x230816:24), 0x0000; (0x230816) = 0
	ld xwa, 0:i3
	ld (0x230440:24), xwa; (0x230440) = 0

	; --- position on the first event (0x7C = any type) ---
	ld xwa, 0:i3
	push xwa
	ldw wa, 124			; WA = 0x7C
	ld bc, 2:i3
	ldw de, 65534			; DE = 0xFFFE
	calr HDAE5000_Lyrics_FindEvent
	ld xwa, 0:i3
	ld (0x230440:24), xwa; (0x230440) = 0
	ld xhl, 0:i3		; return 0
	ret

	; ============================================================
	; Fill the lyric text lines: six lines of up to 39 chars, 40
	; bytes apart at 0x23A0AA, their lengths at 0x2304E8+line.
	; A = 1: first scroll lines 1..5 up into 0..4 (line[i] =
	; line[i+1], the copy runs 0x23A0D2+40i -> 0x23A0AA+40i) and fill
	; only line 5; A = 0: fill lines 0..5.  From event position BC
	; it takes lyric events (meta 0x05, HDAE5000_Lyrics_FindEvent)
	; and appends each to the line while it fits; CR (0x0D) ends the
	; line, LF (0x0A) gives an empty line (HDAE5000_Str_Empty_File_
	; Delete).  The running tick and the target (0x230440/0x230444)
	; are saved and restored.  Returns XHL = position after the
	; last event used.  Callers: HDAE5000_Lyrics_PlayToPosition
	; (scroll) and HDAE5000_LyricBoxProc (initial fill).
	; ============================================================
HDAE5000_Lyrics_FillLines:	; (579 bytes)

	; --- Prologue: allocate stack frame, save registers ---
	lda xsp, (xsp - 54)		; allocate 54 bytes of locals
	pushw iz			; save IZ
	ld (xsp + 54), bc		; save the event position
	ld xbc, (0x230440:24); XBC = (0x230440)
	ld (xsp + 10), xbc		; save to local[0x0A]
	ld xbc, (0x230444:24); XBC = (0x230444)
	ld (xsp + 14), xbc		; save to local[0x0E]

	; --- A == 1: scroll lines 1..5 up one line ---
	cp a, 1:i3
	jr nz, .Lfd_else

	ldw (xsp + 2), 0		; slot = 0
	cpw (xsp + 2), 5		; while slot < 5
	jr ge, .Lfd_copy_done
.Lfd_copy_loop:
	; second argument: line[slot+1] = 0x23A0D2 + 40*slot
	ld wa, (xsp + 2)
	muls wa, 35
	lda xbc, (HDAE5000_RAM_LyricLines_Init+35:24); XBC = 0x23A055
	exts xwa
	add xwa, xbc
	push xwa
	; first argument: line[slot] = 0x23A0AA + 40*slot
	ld wa, (xsp + 6)		; slot (offset by push)
	muls wa, 35
	lda xbc, (HDAE5000_RAM_LyricLines:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_StrCpy
	; and its new length
	ld wa, (xsp + 10)		; slot (offset by 2 pushes)
	muls wa, 35
	lda xbc, (HDAE5000_RAM_LyricLines:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_StrLen
	lda xsp, (xsp + 12)		; pop 12 bytes
	; Store length at 0x2304D8 + slot + 16
	ld wa, (xsp + 2)		; slot
	add wa, 16
	lda xbc, (0x2304d8:24); XBC = 0x2304D8
	ld	(xbc+wa), l
	incw 1, (xsp + 2)		; slot++
	cpw (xsp + 2), 5
	jr lt, .Lfd_copy_loop
.Lfd_copy_done:
	ld c, 5:opc		; C = 5: fill only the last line
	jr t, .Lfd_setup_loop
.Lfd_else:
	ld c, 0:opc			; C = 0

.Lfd_setup_loop:
	; --- fill lines C..5 ---
	ld wa, (xsp + 54)		; WA = saved BC param
	ld (xsp + 4), wa		; local[4] = event position
	ld a, c				; A = count
	extz wa
	ld (xsp + 2), wa		; local[2] = line
	cpw (xsp + 2), 6		; if count >= 6
	jrl ge, .Lfd_epilogue		;   skip to epilogue

.Lfd_outer_loop:
	; --- next lyric event (meta 0x05) ---
	ld (xsp + 18), 0		; line being built at local[0x12] = ""
	ld wa, (xsp + 4)		; WA = entry index
	extz xwa
	push xwa
	ld wa, 5:i3		; meta type 0x05: lyric
	ld bc, 2:i3
	ldw de, 65534			; DE = 0xFFFE
	calr HDAE5000_Lyrics_FindEvent
	ld (xsp + 6), xhl		; local[0x06] = result
	cpw (2294836:24), 1; if (0x230434) == 1
	jrl z, .Lfd_tail_copy		; end of track: store the line and stop
	ld xwa, (xsp + 6)		; XWA = result
	cp xwa, 0
	jrl le, .Lfd_no_entry

	; CR: end of line
	cp (0x230610:24), 0x0d; cp (0x230610), 0x0D
	jr nz, .Lfd_try_0a		; if != 0x0D, try next type

	; --- CR: store the line built so far ---
	ld xwa, (xsp + 6)		; result
	ld (xsp + 4), wa		; save low word
	lda xwa, (xsp + 18)		; XWA = &local[0x12]
	push xwa
	ld wa, (xsp + 6)		; slot (offset by push)
	muls wa, 35
	lda xbc, (HDAE5000_RAM_LyricLines:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_StrCpy			; memcpy
	inc 8, xsp			; pop stack frame

.Lfd_strlen_store:
	; store the line length, next line
	ld wa, (xsp + 2)		; slot
	muls wa, 35
	lda xbc, (HDAE5000_RAM_LyricLines:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_StrLen			; strlen
	inc 4, xsp			; pop 4 bytes
	ld wa, (xsp + 2)		; slot
	add wa, 16
	lda xbc, (0x2304d8:24); XBC = 0x2304D8
	ld	(xbc+wa), l
	incw 1, (xsp + 2)		; slot++
	cpw (xsp + 2), 6		; if slot < 6
	jrl lt, .Lfd_outer_loop		;   continue outer loop

.Lfd_epilogue:
	; --- Restore state and return ---
	ld xwa, (xsp + 10)
	ld (0x230440:24), xwa; restore (0x230440)
	ld xwa, (xsp + 14)
	ld (0x230444:24), xwa; restore (0x230444)
	ld hl, (xsp + 4)		; HL = local[0x04]
	extz xhl			; XHL = zero-extend(HL)
	popw iz				; restore IZ
	lda xsp, (xsp + 54)		; deallocate stack frame
	ret

.Lfd_try_0a:
	; --- LF: an empty line ---
	cp (0x230610:24), 0x0a; cp (0x230610), 0x0A
	jr nz, .Lfd_other_type
	ld xwa, (xsp + 6)		; result
	ld (xsp + 4), wa		; save
	pushw HDAE5000_Str_Empty_File_Delete@hi16			; max = 0x2E -- high half of HDAE5000_Str_Empty_File_Delete
	pushw	HDAE5000_Str_Empty_File_Delete@lo16		; low half of HDAE5000_Str_Empty_File_Delete
	ld wa, (xsp + 6)		; slot (offset)
	muls wa, 35
	lda xbc, (HDAE5000_RAM_LyricLines:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_StrCpy			; memcpy
	inc 8, xsp			; pop frame
	jr t, .Lfd_strlen_store		; goto strlen/store

.Lfd_other_type:
	; --- syllable: append if the line stays <= 39 chars ---
	lda xwa, (0x230610:24); XWA = &0x230610
	push xwa
	call HDAE5000_StrLen			; strlen(0x230636)
	inc 4, xsp			; pop 4 bytes
	cp hl, 34			; if strlen <= 34
	jr ule, .Lfd_short_string	;   handle short string
	; syllable alone longer than a line: skip it
	ld xwa, (xsp + 6)		; result
	ld (xsp + 4), wa
	jrl t, .Lfd_outer_loop

.Lfd_short_string:
	lda xwa, (xsp + 18)		; &local[0x12]
	push xwa
	call HDAE5000_StrLen			; strlen(&local)
	ld iz, hl			; IZ = local strlen
	lda xwa, (0x230610:24); &0x230610
	push xwa
	call HDAE5000_StrLen			; strlen(0x230636)
	inc 8, xsp			; pop frame
	add hl, iz			; HL = combined length
	cp hl, 34			; if combined > 34
	jr ugt, .Lfd_tail_copy		; does not fit: store the line
	lda xwa, (0x230610:24); &0x230610
	push xwa
	lda xwa, (xsp + 22)		; &local[0x12] (offset by push)
	push xwa
	call HDAE5000_StrCat
	inc 8, xsp			; pop frame
	ld xwa, (xsp + 6)		; result
	ld (xsp + 4), wa		; save

.Lfd_no_entry:
	; --- no event (0): empty line ---
	ld xwa, (xsp + 6)		; XWA = result
	or xwa, xwa			; test zero
	jr nz, .Lfd_check_positive	; if nonzero, check further
	pushw HDAE5000_Str_Empty_File_Delete_2@hi16			; max = 0x2E -- high half of HDAE5000_Str_Empty_File_Delete_2
	pushw	HDAE5000_Str_Empty_File_Delete_2@lo16		; low half of HDAE5000_Str_Empty_File_Delete_2
	ld wa, (xsp + 6)		; slot (offset)
	muls wa, 35
	lda xbc, (HDAE5000_RAM_LyricLines:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_StrCpy			; memcpy
	inc 8, xsp			; pop frame
	jrl t, .Lfd_strlen_store	; goto strlen/store

.Lfd_check_positive:
	ld xwa, (xsp + 6)		; XWA = result
	cp xwa, 0
	jrl gt, .Lfd_outer_loop + 4	; if result > 0, continue

.Lfd_tail_copy:
	; --- store the built line ---
	lda xwa, (xsp + 18)		; &local[0x12]
	push xwa
	ld wa, (xsp + 6)		; slot (offset)
	muls wa, 35
	lda xbc, (HDAE5000_RAM_LyricLines:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_StrCpy			; memcpy
	ld wa, (xsp + 10)		; slot (offset by 2 pushes)
	muls wa, 35
	lda xbc, (HDAE5000_RAM_LyricLines:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_StrLen			; strlen
	lda xsp, (xsp + 12)		; pop 12 bytes
	ld wa, (xsp + 2)		; slot
	add wa, 16
	lda xbc, (0x2304d8:24); XBC = 0x2304D8
	ld	(xbc+wa), l
	cpw (2294836:24), 1; if (0x230434) != 1
	jrl nz, .Lfd_strlen_store	;   goto strlen/store
	ldw (0x230434:24), 0x0000; (0x230434) = 0
	jrl t, .Lfd_epilogue		; done

	; ============================================================
	; Find a meta event in the lyric track.  A = meta type wanted,
	; 0x7C meaning "the event at the position, whatever its type";
	; C = HDAE5000_Lyrics_ParseEvent flags (bit 1: copy the data to
	; 0x230636); DE = start: >= 0 skip that many events from the
	; track start, -2 start at the position passed on the stack
	; (retd 4), -1 fail.  Walks the events with ParseEvent until the
	; type matches (0x230430) or the track ends.
	; Output: XHL = position after the event found (for 0x7C: its
	; size), -1 when none, 0 for DE < -2.
	; Callers: HDAE5000_Lyrics_PlayToPosition, _ReadSongInfo,
	; _FillLines.
	; ============================================================
HDAE5000_Lyrics_FindEvent:	.include "includes/generated/cc900/HDAE5000_Lyrics_FindEvent.s"	; C: cc900/hdae5000_lyrics.c

	; ============================================================
	; Parse one event of the lyric track at position BC (offset from
	; the first event, buffer 0x22B430 + 22 + BC):
	;   <VarLen delta>  -> (0x230860); running tick (0x230440) += it
	;   0xFF             (anything else: error 0xFFFD)
	;   <type>           -> (0x230430); 0x2F (end of track) sets
	;                      (0x230434) = 1 and returns 0
	;   <VarLen length>  -> (0x230436)
	;   <data>           flag bit 0: copied to 0x230458 (<= 127) and the
	;                      previous position/tick kept (0x23043C, 0x230448,
	;                      0x230454); bit 1: copied to 0x230636, NUL-ended
	; The next event's delta is read too: (0x230444) = running tick +
	; that delta (the tick of the next event).
	; Output: HL = event size, or 0 with an error code in (0x2307B6):
	;   0xFFFF position + 4 > 20457 (outside the 0x5000-byte buffer)
	;   0xFFFE / 0xFFFC / 0xFFFA  delta / length / next delta VarLen
	;          longer than 4 bytes (HDAE5000_Lyrics_ReadVarLen = -1)
	;   0xFFFD no 0xFF status byte
	;   0xFFFB event runs past 20457
	; QIZH holds flag bit 0.
	; ============================================================
HDAE5000_Lyrics_ParseEvent:	; (772 bytes)

	; --- Prologue ---
	dec 4, xsp			; allocate 8 bytes
	push xiz
	ld (xsp + 4), bc		; save the event position
	ld (xsp + 6), a		; save the flags
	ldib_erp 0xfb, 0		; QIZH = 0: flag bit 0 clear

	; --- position + 4 must stay inside the buffer ---
	ld wa, (xsp + 4)		; WA = event position
	inc 4, wa		; WA += 4
	cp wa, 20457			; start+4 within addressable range?
	jr ule, .Lff_start
	ldw (0x230772:24), 0xffff; (0x230772) = 0xFFFF — error
	ld hl, 0:i3
	jrl t, .Lff_epilogue

.Lff_start:
	ld iz, (xsp + 4)		; IZ = event position
	ld a, (xsp + 6)		; A = flags
	and a, 1			; isolate bit 0
	cp a, 1:i3
	jr nz, .Lff_skip_backup_flag
	ldib_erp 0xfb, 1		; QIZH = 1: flag bit 0 set

.Lff_skip_backup_flag:
	cpib_erp 0xfb, 1		; check QIZH == 1
	jr nz, .Lff_skip_backup_save
	; Save current position before overwriting
	ld wa, (0x230438:24); WA = (0x230438)
	ld (0x23043c:24), wa; (0x23043C) = WA
	ld wa, (xsp + 4)
	ld (0x230438:24), wa		; (0x230438) = event position

.Lff_skip_backup_save:
	ld wa, iz
	calr HDAE5000_Lyrics_ReadVarLen
	ld (0x230808:24), xhl		; (0x230808) = delta time
	cp xhl, 4294967295		; == 0xFFFFFFFF?
	jr nz, .Lff_after_space_check
	ldw (0x230772:24), 0xfffe; (0x230772) = 0xFFFE — error
	ld hl, 0:i3
	jrl t, .Lff_epilogue

.Lff_after_space_check:
	cpib_erp 0xfb, 1
	jr nz, .Lff_skip_backup_copy
	; flag bit 0: keep the previous tick values
	ld xwa, (0x230440:24); XWA = (0x230440)
	ld (0x230448:24), xwa; (0x230448) = XWA
	ld xwa, (0x23044c:24); XWA = (0x23044C)
	ld (0x230454:24), xwa; (0x230454) = XWA
	ld xwa, (0x230808:24); XWA = (0x230808)
	ld (0x23044c:24), xwa; (0x23044C) = XWA

.Lff_skip_backup_copy:
	ld xwa, (0x230808:24); XWA = (0x230808)
	add (0x230440:24), xwa                ; (0x230440) += XWA
	add iz, (2295814:24); IZ += (0x230806)
	ld wa, iz
	inc 1, iz			; IZ++
	; status byte at buffer[pos + 22]
	extz xwa
	add xwa, 22		; +22: past the TLhd and TLtr chunk headers
	ld xbc, HDAE5000_RAM_LyricBuffer
	add xbc, xwa
	cp (xbc), 255		; 0xFF: a meta event?
	jr z, .Lff_byte2_read		; yes: read its type
	ldw (0x230772:24), 0xfffd		; error 0xFFFD: not a meta event
	ld hl, 0:i3
	jrl t, .Lff_epilogue

.Lff_byte2_read:
	ld wa, iz
	inc 1, iz			; IZ++
	extz xwa
	add xwa, 22
	ld xbc, HDAE5000_RAM_LyricBuffer		; lyric buffer
	add xbc, xwa
	ld a, (xbc)		; A = meta event type
	extz wa
	ld (HDAE5000_RAM_LyricEvent:24), wa
	cpw (HDAE5000_RAM_LyricEvent:24), 47		; type 0x2F: end of track?
	jr nz, .Lff_after_type_check
	; end of track: set the end flag, return 0
	ldw (0x230434:24), 0x0001		; (0x230434) = 1: end of track
	ld xwa, 4294967295		; 0xFFFFFFFF
	ld (0x230808:24), xwa; (0x230808) = -1
	ld hl, 0:i3
	jrl t, .Lff_epilogue

.Lff_after_type_check:
	ld wa, iz
	calr HDAE5000_Lyrics_ReadVarLen
	ld xwa, xhl
	cp xwa, 4294967295		; == 0xFFFFFFFF?
	jr nz, .Lff_after_format_calc
	ldw (0x230772:24), 0xfffc; (0x230772) = 0xFFFC — error
	ld hl, 0:i3
	jrl t, .Lff_epilogue

.Lff_after_format_calc:
	add iz, (2295814:24); IZ += (0x230806)
	ld (0x230436:24), hl		; (0x230436) = data length
	; the event must end inside the buffer
	ld wa, iz
	add wa, (2294838:24); WA += (0x230436)
	cp wa, 20457
	jr ule, .Lff_after_limit2
	ldw (0x230772:24), 0xfffb; (0x230772) = 0xFFFB — error
	ld hl, 0:i3
	jrl t, .Lff_epilogue

.Lff_after_limit2:
	ld wa, iz
	add wa, (2294838:24); WA += (0x230436)
	ld (0x23043a:24), wa; (0x23043A) = WA — end position
	; the next event's delta time
	ld wa, iz
	add wa, (2294838:24); WA += (0x230436)
	calr HDAE5000_Lyrics_ReadVarLen
	ld (0x230450:24), xhl; (0x230450) = XHL
	cp xhl, 4294967295
	jr nz, .Lff_after_error3
	ldw (0x230772:24), 0xfffa; (0x230772) = 0xFFFA — error
	ld hl, 0:i3
	jrl t, .Lff_epilogue

.Lff_after_error3:
	; byte at next event + its delta size + 4 -> (0x230882)
	ld wa, iz
	add wa, (2294838:24); WA += (0x230436)
	add wa, (2295814:24); WA += (0x230806)
	inc 4, wa			; WA += 4
	extz xwa
	add xwa, 22
	ld xbc, HDAE5000_RAM_LyricBuffer
	add xbc, xwa
	ld a, (xbc)
	ld (0x230826:24), a; (0x230826) = A

	; --- flag bit 0: data -> 0x230458 (<= 127) ---
	cpib_erp 0xfb, 1
	jr nz, .Lff_after_copy1
	cpw (2294838:24), 127; cp (0x230436), 0x7F
	jr ugt, .Lff_long_copy1	; if > 127, truncate
	; Short copy: actual length
	ld wa, (0x230436:24); WA = (0x230436)
	extz xwa
	pushw wa			; push length
	ld wa, iz
	extz xwa
	add xwa, 22
	ld xbc, HDAE5000_RAM_LyricBuffer
	add xbc, xwa
	push xbc			; push source
	lda xwa, (0x230458:24); &0x230458 — dest
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 10)		; pop 10 bytes
	; Null-terminate
	ld wa, (0x230436:24); WA = length
	extz xwa
	add xwa, 40			; + 0x28
	ld xbc, HDAE5000_RAM_LyricEvent
	add xbc, xwa
	ld (xbc), 0			; null terminate
	jr t, .Lff_after_copy1

.Lff_long_copy1:
	pushw 127			; max = 0x7F
	ld wa, iz
	extz xwa
	add xwa, 22
	ld xbc, HDAE5000_RAM_LyricBuffer
	add xbc, xwa
	push xbc			; push source
	lda xwa, (0x230458:24); &0x230458
	push xwa
	call HDAE5000_MemCopy			; strcpy_len
	lda xsp, (xsp + 10)
	ld (0x2304d7:24), 0x00; (0x2304D7) = 0 — null terminate at 127

.Lff_after_copy1:
	; --- (0x230444) = tick of the next event ---
	ld xwa, (0x230440:24); XWA = (0x230440)
	add xwa, (2294864:24); XWA += (0x230450)
	ld (0x230444:24), xwa; (0x230444) = XWA — total

	; --- flag bit 1: data -> 0x230636 (<= 127), NUL-ended ---
	ld a, (xsp + 6)		; A = flags
	and a, 2			; isolate bit 1
	cp a, 2:i3
	jr nz, .Lff_after_copy2		; skip if bit 1 not set
	cpw (2294838:24), 127; cp (0x230436), 0x7F
	jr ugt, .Lff_long_copy2
	; Short copy
	ld wa, (0x230436:24)
	extz xwa
	pushw wa
	ld wa, iz
	extz xwa
	add xwa, 22
	ld xbc, HDAE5000_RAM_LyricBuffer
	add xbc, xwa
	push xbc
	lda xwa, (0x230610:24); &0x230610
	push xwa
	call HDAE5000_MemCopy			; strcpy_len
	lda xsp, (xsp + 10)
	; Null-terminate
	ld wa, (0x230436:24)
	extz xwa
	ld xbc, 2295312			; 0x00230610
	add xbc, xwa
	ld (xbc), 0
	jr t, .Lff_after_copy2

.Lff_long_copy2:
	pushw 127
	ld wa, iz
	extz xwa
	add xwa, 22
	ld xbc, HDAE5000_RAM_LyricBuffer
	add xbc, xwa
	push xbc
	lda xwa, (0x230610:24); &0x230610
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 10)
	ld (0x23068f:24), 0x00; (0x23068F) = 0

.Lff_after_copy2:
	ld hl, (0x23043a:24); HL = (0x23043A) — end position
	sub hl, (xsp + 4)		; HL = event size

	; --- Epilogue ---
.Lff_epilogue:
	pop xiz
	inc 4, xsp
	ret

	; ============================================================
	; Read 16-bit big-endian word from sector allocation table
	; Reads table[WA+23] as low byte and table[WA+22] as high byte,
	; combining into HL = (high << 8) | low.
	; Input: WA = sector index
	; Output: HL = 16-bit value from two consecutive table entries
	; ============================================================
HDAE5000_Read_Table_Word:	.include "includes/generated/cc900/HDAE5000_Read_Table_Word.s"	; C: cc900/hdae5000_lyrics.c

	; ============================================================
	; Read 24-bit big-endian value from sector allocation table
	; Reads up to 3 consecutive bytes from table[WA+22..WA+24],
	; accumulating as XHL = (byte0 << 16) | (byte1 << 8) | byte2.
	; Input: WA = sector index
	; Output: XHL = 24-bit value from 3 consecutive table entries
	; ============================================================
HDAE5000_Read_Table_Multi:	.include "includes/generated/cc900/HDAE5000_Read_Table_Multi.s"	; C: cc900/hdae5000_lyrics.c

	; ============================================================
	; Read a MIDI variable-length number (7 bits per byte, most
	; significant first, bit 7 = more bytes follow; at most 4 bytes)
	; at lyric-track position WA (buffer 0x22B430 + 22 + WA).
	; Output: XHL = the value, or -1 when no byte of the first four
	; ends it; (0x23085E) = number of bytes read.
	; ============================================================
HDAE5000_Lyrics_ReadVarLen:	; (87 bytes)
	ld xhl, 0:i3			; XHL = accumulator (decoded value)
	ld ix, 0:i3			; IX = byte index (0-3)
	cp ix, 4:i3			; guard: max 4 bytes per VarInt
	jr nc, .Lcds_overflow
.Lcds_loop:
	; byte at buffer[WA + IX + 22]
	ld bc, wa		; BC = position
	add bc, ix			; BC += byte offset
	extz xbc
	add xbc, 0x00000016		; +22: past the chunk headers
	ld xde, HDAE5000_RAM_LyricBuffer
	add xde, xbc			; XDE → table[sector + 22]
	ld c, (xde)		; C = VarLen byte
	res 7, c			; strip VarInt continuation bit → 7-bit payload
	ld b, 0x00:opc
	extz xbc			; XBC = payload (zero-extended)
	add xhl, xbc			; accumulate: XHL += payload
	; Re-read byte to check continuation bit (bit 7)
	ld bc, wa
	add bc, ix
	extz xbc
	add xbc, 0x00000016
	ld xde, HDAE5000_RAM_LyricBuffer
	add xde, xbc
	cp (xde), 0x80		; bit 7 set? (continuation)
	jr nc, .Lcds_continue		; yes → more bytes follow
	; Continuation=0 → VarInt complete, return decoded value
	ld wa, ix			; WA = bytes consumed (0-based)
	inc 1, wa			; WA = byte count (1-based)
	ld (0x230806:24), wa; store bytes consumed to (0x230806)
	ret		; return XHL = value
.Lcds_continue:
	sll xhl, 7			; make room for next 7-bit chunk
	inc 1, ix
	cp ix, 4:i3			; max 4 continuation bytes
	jr c, .Lcds_loop
.Lcds_overflow:
	ld xhl, 0xFFFFFFFF		; overflow: VarInt > 4 bytes
	ret
	; Finds how many 7-bit chunks are needed, then serializes
	; MSB-first with bit 7 = continuation on all but last byte.
	; Input: XWA = value to encode, XBC = output buffer pointer
	; Output: HL = 0xFFFF (sentinel)

HDAE5000_Lyrics_WriteVarLen:
	; The encoder matching HDAE5000_Lyrics_ReadVarLen: write XWA as a
	; variable-length number to (XBC), at most 5 bytes.  No caller was found
	; (scripts/analysis/hdae5000_reachability.py).
	; Step 1: Count how many 7-bit chunks are needed
	ld xde, xwa			; XDE = value to encode
	ld hl, 1:i3			; HL = chunk count (start at 1)
	cp hl, 5:i3			; max 5 chunks
	jr nc, .Lcds_apply
.Lcds_search:
	srl xde, 7			; shift out 7 bits
	jr nz, .Lcds_next		; still nonzero? need more chunks
	ld ix, hl			; IX = total chunks needed
	jr t, .Lcds_apply		; done counting
.Lcds_next:
	inc 1, hl
	cp hl, 5:i3
	jr c, .Lcds_search
	; Step 2: Serialize chunks MSB-first into buffer
.Lcds_apply:
	ld xde, xwa			; XDE = value (fresh copy)
	ld hl, ix			; HL = chunk count
	cp hl, 0:i3
	jr z, .Lcds_done		; nothing to write
.Lcds_apply_loop:
	ld wa, hl
	dec 1, wa			; WA = output index (HL-1)
	extz xwa
	ld xix, xwa
	add xix, xbc			; XIX = &buffer[index]
	ld a, e				; A = low 7 bits of XDE
	res 7, a			; clear continuation bit (initially)
	ld (xix), a			; buffer[index] = 7-bit payload
	srl xde, 7			; shift out the 7 bits we just wrote
	cp xde, 0x0000007F		; remaining value fits in 7 bits?
	ret ule				; yes → last byte already written, done
	; More bytes needed: set continuation bit on byte we just wrote
	ld wa, hl
	dec 1, wa
	extz xwa
	ld xix, xwa
	add xix, xbc			; XIX = &buffer[index]
	ld wa, hl
	dec 1, wa
	extz xwa
	add xwa, xbc
	ld a, (xwa)			; re-read byte we just stored
	set 7, a			; set continuation bit (more bytes follow)
	ld (xix), a			; write back with continuation
	djnz16 hl, .Lcds_apply_loop	; next chunk
.Lcds_done:
	ldw hl, 0xFFFF			; return sentinel
	ret

; ---------------------------------------------------------------------------
; Check the lyric file's header chunk (the SMF MThd checks with its own id):
; "TLhd" at +0 (HDAE5000_MemCmp against HDAE5000_Str_Tlhd, else -1),
; big-endian length 6 at +4 (else -2), format <= 0 at +8 (else -3), track
; count <= 1 at +10 (else -4), division bit 15 (SMPTE) clear at +12 (else
; -5).  Only caller: HDAE5000_Lyrics_CheckFile.
; Out: XHL = 0 when all hold, else the negative code.
; ---------------------------------------------------------------------------
HDAE5000_Lyrics_CheckHeaderChunk:	.include "includes/generated/cc900/HDAE5000_Lyrics_CheckHeaderChunk.s"	; C: cc900/hdae5000_lyrics.c

; ---------------------------------------------------------------------------
; Check the lyric file's track chunk: "TLtr" at +14 (else XHL = -10), then
; HDAE5000_RAM_LyricFileLength = its big-endian length + 22, the end of the
; events.  Only caller: HDAE5000_Lyrics_CheckFile.
; Out: XHL = 0, or -10.
; ---------------------------------------------------------------------------
HDAE5000_Lyrics_CheckTrackChunk:	.include "includes/generated/cc900/HDAE5000_Lyrics_CheckTrackChunk.s"	; C: cc900/hdae5000_lyrics.c

; ---------------------------------------------------------------------------
; Reverse the four bytes of XWA (big-endian <-> little-endian).  Reads the
; TLhd/TLtr chunk lengths of a lyric file (HDAE5000_Lyrics_CheckHeaderChunk,
; _CheckTrackChunk) and two more values in this file.
; In:  XWA
; Out: XHL = XWA byte-reversed.  Clobbers XWA, DE.
; ---------------------------------------------------------------------------
HDAE5000_SwapBytes32:	.include "includes/generated/cc900/HDAE5000_SwapBytes32.s"	; C: cc900/hdae5000_lyrics.c

; ---------------------------------------------------------------------------
; Swap the two bytes of WA.
; In:  WA
; Out: HL = WA byte-swapped.  Clobbers WA.
; ---------------------------------------------------------------------------
HDAE5000_SwapBytes16:	.include "includes/generated/cc900/HDAE5000_SwapBytes16.s"	; C: cc900/hdae5000_lyrics.c

	; --- Main dispatch function (2384 bytes) ---
HDAE5000_FDFileSelectProc:
	; registered as "FDFileSelectProc" in HDAE5000_ClassProc_Table
	lda xsp, (xsp-130)	; lda XSP, XSP-130 (stack frame)
	push xiz
	ld (xsp + 0x7a), xde		; save arg3
	ld (xsp + 0x7e), xbc		; save arg2
	ld	(xsp+130), xwa	; save arg1 at (XSP+0x82)

	; --- Case dispatch on arg2 ---
	ld xwa, (xsp + 0x7e)
	cp xwa, EVT_SW_IN
	jrl z, .Lsc_case_07
	cp xwa, EVT_INDEXSW_DOWN
	jrl z, .Lsc_case_18
	cp xwa, EVT_INDEXSW_UP
	jrl z, .Lsc_case_17
	cp xwa, EVT_HDAE_FD_SAVE_LYRIC
	jrl z, .Lsc_case_11_ea
	cp xwa, EVT_HDAE_FD_LOAD_LYRIC
	jrl z, .Lsc_case_10_ea
	cp xwa, EVT_HDAE_FD_INFO
	jrl z, .Lsc_case_0f_ea
	cp xwa, EVT_HDAE_FD_FRESH_UP
	jrl z, .Lsc_case_0e
	cp xwa, EVT_PARA_DRAW
	jrl z, .Lsc_case_0f
	cp xwa, EVT_HDAE_DRAW_FD_TEXT
	jrl z, .Lsc_case_0c
	cp xwa, EVT_HIDE
	jrl z, .Lsc_case_02
	cp xwa, EVT_SHOW
	jr z, .Lsc_case_01
	cp xwa, EVT_DRAW
	jrl nz, .Lsc_default

	; ============================================================
	; Case 0x01C0000D — dispatch vtable calls + send messages
	; ============================================================
.Lsc_case_0d:
	ld	xwa, (xsp+130)             ; reload arg1
	ld xbc, (xsp + 0x7e)
	ld xde, (xsp + 0x7a)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)             ; vtable base
	ld_sril XHL, (xhl + RootFn_InheritedProc)             ; method 0x00DC
	call (xhl)

	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld XIX, (xbc + RootFn_GetViewInstance)             ; method 0x02C4
	call (xix)

	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_SendEvent)             ; method 0x0100
	ld xbc, EVT_HDAE_DRAW_FD_TEXT
	ld xde, 0:i3
	call (xhl)

	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_SendEvent)             ; method 0x0100
	ld xbc, EVT_PARA_DRAW
	ld xde, 0:i3
	call (xhl)

	ld xhl, 0:i3
	jrl	t, .Lsc_epilogue

	; ============================================================
	; Case 0x01C00001 — vtable dispatch + display setup
	; ============================================================
.Lsc_case_01:
	ld	xwa, (xsp+130)
	ld xbc, (xsp + 0x7e)
	ld xde, (xsp + 0x7a)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_InheritedProc)
	call (xhl)

	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld XIX, (xbc + RootFn_GetViewInstance)
	call (xix)

	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld XHL, (xbc + RootFn_SetDialUp)             ; method 0x03C8
	ld xbc, EVT_INDEXSW_DOWN
	ld xde, 0:i3
	call (xhl)

	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld XHL, (xbc + RootFn_SetDialDown)             ; method 0x03CC
	ld xbc, EVT_INDEXSW_UP
	ld xde, 0:i3
	call (xhl)

	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XHL, (xwa + RootFn_SetDialEnable)             ; method 0x03C4
	ld wa, 1:i3
	call (xhl)

	pushw HDAE5000_Str_Empty_FDFileSelectProc@hi16
	pushw	HDAE5000_Str_Empty_FDFileSelectProc@lo16		; low half of HDAE5000_Str_Empty_FDFileSelectProc
	pushw	0x0023
	pushw	0x0e1e
	call HDAE5000_StrCpy
	inc 8, xsp			; clean 8 bytes

	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_SendEvent)             ; method 0x0100
	ld xbc, EVT_HDAE_FD_FRESH_UP
	ld xde, 0:i3
	call (xhl)

	ldw (0x22a0c8:24), 0x0021
	ldw (0x22a0cc:24), 0x0118
	ldw (0x22a0ca:24), 0x00c5
	ldw (0x22a0ce:24), 0x00d1
	ld wa, (0x22a0c8:24)
	inc 2, wa
	ld (0x22a0bc:24), wa
	ld wa, (0x22a0ca:24)
	inc 3, wa
	ld (0x22a0be:24), wa

	ld xhl, 0:i3
	jrl	t, .Lsc_epilogue

	; ============================================================
	; Case 0x01C00002 — simple vtable call
	; ============================================================
.Lsc_case_02:
	ld	xwa, (xsp+130)
	ld xbc, (xsp + 0x7e)
	ld xde, (xsp + 0x7a)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_InheritedProc)
	call (xhl)
	ld xhl, 0:i3
	jrl	t, .Lsc_epilogue

	; ============================================================
	; Case 0x01CA000C — 3-section loop UI setup
	; ============================================================
.Lsc_case_0c:
	ldw (xsp + 0x6e), 0x0016
	ldw wa, 0x0016
	add wa, 0x0037
	ld (xsp + 0x72), wa
	ld wa, (xsp + 0x6e)
	inc 2, wa
	ld (xsp + 0x76), wa
	ldw (xsp + 0x04), 0x0000
	cpw (xsp + 0x04), 0x000c
	jrl nc, .Lsc_0c_sect2

	; --- Section 1 loop: 12 iterations ---
.Lsc_0c_loop1:
	ld wa, (xsp + 0x04)
	mul wa, 0x000c
	add wa, 0x0028
	ld (xsp + 0x70), wa
	add wa, 0x000c
	ld (xsp + 0x74), wa
	ld wa, (xsp + 0x70)
	inc 3, wa
	ld (xsp + 0x78), wa
	lda xwa, (xsp + 0x6e)
	ld xhl, xwa
	lda xwa, (xsp + 0x76)
	ld xbc, xwa
	lda xwa, (HDAE5000_Str_Blank27:24)
	ld xde, xwa
	ld xwa, 3:i3
	push xwa
	pushw 0x00ff
	pushw 0x00f5
	ld xwa, xhl
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_DrawString)             ; method 0x00C4
	call (xhl)

	lda xwa, (xsp + 0x6e)
	ld xix, xwa
	lda xwa, (xsp + 0x76)
	ld xhl, xwa
	ld wa, (0x230e1c:24)
	add wa, (xsp + 0x04)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	add xbc, xwa
	ld xde, HDAE5000_RAM_FdLyricNames
	add xde, xbc
	ld xwa, 3:i3
	push xwa
	pushw 0x00ff
	pushw 0x00f5
	ld xwa, xix
	ld xbc, xhl
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_DrawString)
	call (xhl)

	incw 1, (xsp + 0x04)
	cpw (xsp + 0x04), 0x000c
	jrl c, .Lsc_0c_loop1

	; --- Section 2: offset 0x5C, 12 iterations ---
.Lsc_0c_sect2:
	ldw (xsp + 0x6e), 0x005c
	ldw wa, 0x005c
	add wa, 0x00a2
	ld (xsp + 0x72), wa
	ld wa, (xsp + 0x6e)
	inc 2, wa
	ld (xsp + 0x76), wa
	ldw (xsp + 0x04), 0x0000
	cpw (xsp + 0x04), 0x000c
	jrl nc, .Lsc_0c_sect3

.Lsc_0c_loop2:
	ld wa, (xsp + 0x04)
	mul wa, 0x000c
	add wa, 0x0028
	ld (xsp + 0x70), wa
	add wa, 0x000c
	ld (xsp + 0x74), wa
	ld wa, (xsp + 0x70)
	inc 3, wa
	ld (xsp + 0x78), wa
	lda xwa, (xsp + 0x6e)
	ld xhl, xwa
	lda xwa, (xsp + 0x76)
	ld xbc, xwa
	lda xwa, (HDAE5000_Str_Blank27_FDFileSelectProc:24)
	ld xde, xwa
	ld xwa, 3:i3
	push xwa
	pushw 0x00ff
	pushw 0x00f5
	ld xwa, xhl
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_DrawString)
	call (xhl)

	lda xwa, (xsp + 0x6e)
	ld (xsp + 0x06), xwa
	lda xwa, (xsp + 0x76)
	ld xiz, xwa
	ld wa, (0x230e1c:24)
	add wa, (xsp + 0x04)
	extz xwa
	ld xbc, 0x0000001b
	call HDAE5000_Multiply
	ld xde, HDAE5000_RAM_FdLyricTitles
	add xde, xhl
	ld xwa, 3:i3
	push xwa
	pushw 0x00ff
	pushw 0x00f5
	ld xwa, (xsp + 0x0e)
	ld xbc, xiz
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_DrawString)
	call (xhl)

	incw 1, (xsp + 0x04)
	cpw (xsp + 0x04), 0x000c
	jrl c, .Lsc_0c_loop2

	; --- Section 3: offset 0x10C, 12 iterations ---
.Lsc_0c_sect3:
	ldw (xsp + 0x6e), 0x010c
	ldw wa, 0x010c
	add wa, 0x001f
	ld (xsp + 0x72), wa
	ld wa, (xsp + 0x6e)
	inc 2, wa
	ld (xsp + 0x76), wa
	ldw (xsp + 0x04), 0x0000
	cpw (xsp + 0x04), 0x000c
	jrl nc, .Lsc_0c_done

.Lsc_0c_loop3:
	ld wa, (xsp + 0x04)
	mul wa, 0x000c
	add wa, 0x0028
	ld (xsp + 0x70), wa
	add wa, 0x000c
	ld (xsp + 0x74), wa
	ld wa, (xsp + 0x70)
	inc 3, wa
	ld (xsp + 0x78), wa
	ld wa, (0x230e1c:24)
	add wa, (xsp + 0x04)
	extz xwa
	ld xbc, HDAE5000_RAM_FdLyricHasMid
	add xbc, xwa
	cp (xbc), 0x00
	jr z, .Lsc_0c_z

	; nonzero: slot occupied
.Lsc_0c_nz:
	lda xwa, (xsp + 0x6e)
	ld xhl, xwa
	lda xwa, (xsp + 0x76)
	ld xbc, xwa
	lda xwa, (HDAE5000_Str_Mid:24)
	ld xde, xwa
	ld xwa, 3:i3
	push xwa
	pushw 0x00ff
	pushw 0x00f5
	ld xwa, xhl
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_DrawString)
	call (xhl)
	jr t, .Lsc_0c_loop3end

	; zero: slot empty
.Lsc_0c_z:
	lda xwa, (xsp + 0x6e)
	ld xhl, xwa
	lda xwa, (xsp + 0x76)
	ld xbc, xwa
	lda xwa, (HDAE5000_Str_Blank3:24)
	ld xde, xwa
	ld xwa, 3:i3
	push xwa
	pushw 0x00ff
	pushw 0x00f5
	ld xwa, xhl
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_DrawString)
	call (xhl)

.Lsc_0c_loop3end:
	incw 1, (xsp + 0x04)
	cpw (xsp + 0x04), 0x000c
	jrl c, .Lsc_0c_loop3

.Lsc_0c_done:
	ld xhl, 0:i3
	jrl	t, .Lsc_epilogue

	; ============================================================
	; Case 0x01C0000F — display region configuration
	; ============================================================
.Lsc_case_0f:
	ld wa, (0x230e18:24)
	mul wa, 0x000c
	add wa, 0x0028
	ld (xsp + 0x70), wa
	add wa, 0x000c
	ld (xsp + 0x74), wa

	; Region 1: y=0x14
	ldw (xsp + 0x6e), 0x0014
	ldw (0x22a0c0:24), 0x0014
	ld wa, (xsp + 0x6e)
	add wa, 0x0039
	ld (xsp + 0x72), wa
	ld (0x22a0c4:24), wa
	lda xwa, (0x22a0c0:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_DrawFrame)             ; method 0x00A8
	ldw bc, 0x00f5
	call (xhl)

	lda xwa, (xsp + 0x6e)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_DrawFrame)
	ldw bc, 0x00f2
	call (xhl)

	; Region 2: y=0x5C
	ldw (xsp + 0x6e), 0x005c
	ldw (0x22a0c0:24), 0x005c
	ld wa, (xsp + 0x6e)
	add wa, 0x00a2
	ld (xsp + 0x72), wa
	ld (0x22a0c4:24), wa
	lda xwa, (0x22a0c0:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_DrawFrame)
	ldw bc, 0x00f5
	call (xhl)

	lda xwa, (xsp + 0x6e)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_DrawFrame)
	ldw bc, 0x00f2
	call (xhl)

	; Region 3: y=0x10C
	ldw (xsp + 0x6e), 0x010c
	ldw (0x22a0c0:24), 0x010c
	ld wa, (xsp + 0x6e)
	add wa, 0x001f
	ld (xsp + 0x72), wa
	ld (0x22a0c4:24), wa
	lda xwa, (0x22a0c0:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_DrawFrame)
	ldw bc, 0x00f5
	call (xhl)

	lda xwa, (xsp + 0x6e)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_DrawFrame)
	ldw bc, 0x00f2
	call (xhl)

	; Store current slot bounds
	ld wa, (xsp + 0x70)
	ld (0x22a0c2:24), wa
	ld wa, (xsp + 0x74)
	ld (0x22a0c6:24), wa

	; Setup display frame rect
	lda xwa, (0x22a0c8:24)
	ld xhl, xwa
	lda xwa, (0x22a0bc:24)
	ld xbc, xwa
	lda xwa, (HDAE5000_Str_Blank49:24)
	ld xde, xwa
	ld xwa, 3:i3
	push xwa
	pushw 0x00ff
	pushw 0x00f5
	ld xwa, xhl
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_DrawString)
	call (xhl)

	; String lookup for current slot
	ld wa, (0x230e1a:24)
	extz xwa
	ld xbc, 0x0000001b
	call HDAE5000_Multiply
	ld xwa, HDAE5000_RAM_FdLyricTitles
	add xwa, xhl
	push xwa
	call HDAE5000_StrLen
	inc 4, xsp
	cp hl, 0:i3
	jr z, .Lsc_0f_notfound

	; Found: format with name
	ld wa, (0x230e1a:24)
	extz xwa
	ld xbc, 0x0000001b
	call HDAE5000_Multiply
	ld xwa, HDAE5000_RAM_FdLyricTitles
	add xwa, xhl
	push xwa
	pushw 0x0023
	pushw 0x0e1e
	pushw HDAE5000_Fmt_s_s@hi16
	pushw	HDAE5000_Fmt_s_s@lo16		; low half of HDAE5000_Fmt_s_s
	lda xwa, (xsp + 0x16)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x10)
	jr t, .Lsc_0f_merge

	; Not found: format with slot index
.Lsc_0f_notfound:
	ld wa, (0x230e1a:24)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	add xbc, xwa
	ld xwa, HDAE5000_RAM_FdLyricNames
	add xwa, xbc
	push xwa
	pushw 0x0023
	pushw 0x0e1e
	pushw HDAE5000_Fmt_s_s_FDFileSelectProc@hi16
	pushw	HDAE5000_Fmt_s_s_FDFileSelectProc@lo16		; low half of HDAE5000_Fmt_s_s_FDFileSelectProc
	lda xwa, (xsp + 0x16)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x10)

.Lsc_0f_merge:
	lda xwa, (0x22a0c8:24)
	ld xhl, xwa
	lda xwa, (0x22a0bc:24)
	ld xbc, xwa
	lda xwa, (xsp + 0x0a)
	ld xde, xwa
	ld xwa, 3:i3
	push xwa
	pushw 0x00ff
	pushw 0x00f5
	ld xwa, xhl
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_DrawString)
	call (xhl)

	ld xhl, 0:i3
	jrl	t, .Lsc_epilogue

	; ============================================================
	; Case 0x01EA000E — memory initialization + path builder
	; ============================================================
.Lsc_case_0e:
	ldw (0x230e1a:24), 0x0000
	ldw (0x230e1c:24), 0x0000
	ldw (HDAE5000_RAM_FdLyricCount:24), 0x0000
	ldw (0x230e18:24), 0x0000

	pushw 0x0171
	pushw 0x0000
	lda xwa, (HDAE5000_RAM_FdLyricNames:24)
	push xwa
	call HDAE5000_MemFill
	pushw 0x0453
	pushw 0x0000
	lda xwa, (HDAE5000_RAM_FdLyricTitles:24)
	push xwa
	call HDAE5000_MemFill
	pushw 40			; count: 40 bytes (not an address: the pair once read as 0x280000)
	pushw 0				; fill value
	lda xwa, (HDAE5000_RAM_FdLyricHasMid:24)
	push xwa
	call HDAE5000_MemFill
	lda xsp, (xsp + 0x18)		; clean 24 bytes (3 calls x 8)

	calr HDAE5000_FdLyricList_Scan
	ld xhl, 0:i3
	jrl	t, .Lsc_epilogue

	; ============================================================
	; Cases 0x01EA000F/0010/0011 — return 0
	; ============================================================
.Lsc_case_0f_ea:
	ld xhl, 0:i3
	jrl	t, .Lsc_epilogue
.Lsc_case_10_ea:
	ld xhl, 0:i3
	jrl	t, .Lsc_epilogue
.Lsc_case_11_ea:
	ld xhl, 0:i3
	jrl	t, .Lsc_epilogue

	; ============================================================
	; Case 0x01C00017 — vtable call + send message 0x01C00007
	; ============================================================
.Lsc_case_17:
	ld	xwa, (xsp+130)
	ld xbc, (xsp + 0x7e)
	ld xde, (xsp + 0x7a)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_InheritedProc)
	call (xhl)

	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_SendEvent)
	ld xbc, EVT_SW_IN
	ld xde, 3:i3
	call (xhl)

	; ============================================================
	; Default case — vtable call + forward to case_01
	; ============================================================
.Lsc_default:
	ld	xwa, (xsp+130)
	ld xbc, (xsp + 0x7e)
	ld xde, (xsp + 0x7a)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XIX, (xhl + RootFn_InheritedProc)
	call (xix)
	jrl	t, .Lsc_epilogue

	; ============================================================
	; Case 0x01C00018 — vtable calls + send 0x01C00007 with flag
	; ============================================================
.Lsc_case_18:
	ld	xwa, (xsp+130)
	ld xbc, (xsp + 0x7e)
	ld xde, (xsp + 0x7a)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld_sril XHL, (xhl + RootFn_InheritedProc)
	call (xhl)

	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_SendEvent)
	ld xbc, EVT_SW_IN
	ld xde, 0x00000083
	call (xhl)
	jr t, .Lsc_default

	; ============================================================
	; Case 0x01C00007 — button handler with sub-dispatch
	; ============================================================
.Lsc_case_07:
	ld xwa, (xsp + 0x7a)		; XWA = arg3 (button code)
	cp xwa, 0x00000007
	jr	ule, .Lsc_07_inrange
	sub xwa, 0x00000078
	cp xwa, 0x00000008
	jrl	c, .Lsc_ret0
	cp xwa, 0x0000000f
	jrl	ugt, .Lsc_ret0
.Lsc_07_inrange:
	add	xwa, xwa			; word index
	add	xwa, HDAE5000_FDFileSelectProc_KeyCaseTable
	ld wa, (xwa)
	lda	xix, (.Lsc_07_btn_k1:24)
	jp	t, (xix+wa)

	; --- keys 1 / 0x81 (v2.01i only): events 0x01EA000E and 0x01CA000C,
	; then EVT_PARA_DRAW, to this object ---
.Lsc_07_btn_k1:
	ld	xwa, (xsp+130)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, 0x01ea000e
	ld	xde, 0:i3
	call	(xhl)
	ld	xwa, (xsp+130)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, 0x01ca000c
	ld	xde, 0:i3
	call	(xhl)
	ld	xwa, (xsp+130)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0:i3
	call	(xhl)
	jrl	t, .Lsc_ret0

	; --- Down button handler ---
.Lsc_07_btn_down:
	cpw (0x230e1a:24), 0x0000
	jr nz, .Lsc_down_nz
	ld xhl, 0xffffffff		; return -1
	jrl t, .Lsc_epilogue

.Lsc_down_nz:
	decw 1, (0x230e1a:24); slot_index--
	cpw (0x230e18:24), 0x0000
	jr nz, .Lsc_down_74nz

	; page_offset == 0: check scroll_offset
	cpw (0x230e1c:24), 0x0000
	jr nz, .Lsc_down_78nz
	ld xhl, 0xffffffff
	jrl t, .Lsc_epilogue

.Lsc_down_78nz:
	decw 1, (0x230e1c:24)
	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_SendEvent)
	ld xbc, EVT_DRAW
	ld xde, 0:i3
	call (xhl)
	jr t, .Lsc_down_merge

.Lsc_down_74nz:
	decw 1, (0x230e18:24)
	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_SendEvent)
	ld xbc, EVT_PARA_DRAW
	ld xde, 0:i3
	call (xhl)

.Lsc_down_merge:
	ld	xwa, (xsp+130)
	ld xbc, (xsp + 0x7e)
	ld xde, (xsp + 0x7a)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld XHL, (xhl + RootFn_SetAutoInc)             ; method 0x042C
	call (xhl)
	jrl t, .Lsc_ret0

	; --- Up button handler ---
.Lsc_07_btn_up:
	ld wa, (HDAE5000_RAM_FdLyricCount:24)
	dec 1, wa
	cp (0x230e1a:24), wa; compare slot_index with limit
	jr c, .Lsc_up_ok
	ld xhl, 0xffffffff
	jrl t, .Lsc_epilogue

.Lsc_up_ok:
	incw 1, (0x230e1a:24)
	cpw (0x230e18:24), 0x000b
	jr c, .Lsc_up_inc74

	; page_offset >= 11: scroll
	incw 1, (0x230e1c:24)
	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_SendEvent)
	ld xbc, EVT_DRAW
	ld xde, 0:i3
	call (xhl)
	jr t, .Lsc_up_merge

.Lsc_up_inc74:
	incw 1, (0x230e18:24)
	ld	xwa, (xsp+130)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_RootFnTable)
	ld_sril XHL, (xbc + RootFn_SendEvent)
	ld xbc, EVT_PARA_DRAW
	ld xde, 0:i3
	call (xhl)

.Lsc_up_merge:
	ld	xwa, (xsp+130)
	ld xbc, (xsp + 0x7e)
	ld xde, (xsp + 0x7a)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XHL, (xhl + WS_RootFnTable)
	ld XHL, (xhl + RootFn_SetAutoInc)
	call (xhl)
	jrl t, .Lsc_ret0

	; --- Enter/Select button handler ---
.Lsc_07_btn_enter:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_HamaFnTable)             ; (XWA+0x0E88) status obj
	ld xix, (xwa + HamaFn_GetMediaType)
	call (xix)			; get status
	cp l, 3:i3
	jr z, .Lsc_enter_active
	cp l, 2:i3
	jrl nz, .Lsc_enter_skip

.Lsc_enter_active:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XHL, (xwa + RootFn_SleepMainTask)             ; method 0x0538
	call (xhl)

	ld wa, (0x230e1a:24)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	add xbc, xwa
	ld xwa, HDAE5000_RAM_FdLyricNames
	add xwa, xbc
	push xwa			; slot data address
	lda xwa, (xsp + 0x0e)
	push xwa			; format buffer
	call HDAE5000_StrCpy
	pushw	HDAE5000_Str_TLX_FDFileSelectProc@hi16
	pushw	HDAE5000_Str_TLX_FDFileSelectProc@lo16		; low half of HDAE5000_Str_TLX_FDFileSelectProc
	lda xwa, (xsp + 0x16)
	push xwa
	call HDAE5000_StrCat
	lda xsp, (xsp + 0x10)		; clean 16 bytes

	lda xwa, (xsp + 0x0a)
	lda xbc, (HDAE5000_Str_Rb_FDFileSelectProc:24)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XDE, (xde + WS_HamaFnTable)
	ld_sril XHL, (xde + HamaFn_fopen_ext)             ; method 0x00A0
	call (xhl)

	lda xwa, (HDAE5000_RAM_LyricBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XBC, (xbc + WS_HamaFnTable)
	ld_sril XHL, (xbc + HamaFn_fread_ext)
	ld xbc, 0x00005000
	call (xhl)

	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_HamaFnTable)
	ld_sril XHL, (xwa + HamaFn_fclose_ext)             ; method 0x00AC
	call (xhl)

	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XHL, (xwa + RootFn_WakeUpMainTask)             ; method 0x053C
	call (xhl)

.Lsc_enter_skip:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XHL, (xwa + RootFn_ApPostEvent)             ; method 0x0124
	ld xwa, HDAE5000_OBJ_Tech_lyrics
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)

	; ============================================================
	; Epilogue
	; ============================================================
.Lsc_ret0:
	ld xhl, 0:i3
.Lsc_epilogue:
	pop xiz
	lda xsp, (xsp+130:16)	; lda XSP, XSP+130 (restore stack)
	ret

; ---------------------------------------------------------------------------
; Build the floppy's lyric-file list (the "LOAD LYRICS FROM FD" screen), all
; through the main CPU's file functions: HamaFn_GetMediaType must be 2 or 3,
; else return; RootFn_SleepMainTask; HamaFn_GetVolumeLabel ->
; HDAE5000_RAM_FdVolumeLabel + " ->"; _findfirst("*.*") / _findnext /
; _findclose: every name goes to HDAE5000_FdLyricList_AddTlx, which keeps the
; *.TLX ones (sorted, <= 40); for each kept name, fopen_ext(name + ".TTX",
; "rb"), fread_ext 26 bytes into HDAE5000_RAM_FdLyricTitles + 27 * i,
; fclose_ext; and HDAE5000_RAM_FdLyricHasMid[i] = (fopen_ext(name + ".MID",
; "rb") >= 0); RootFn_WakeUpMainTask.
; ---------------------------------------------------------------------------
HDAE5000_FdLyricList_Scan:
	lda xsp, (xsp-370)
	push xiz			; save XIZ
	ld xwa, 0:i3
	ld (xsp + 4), xwa		; local[0x04] = 0 (result)

	; --- Get vtable, call method at +0x08 via XIX ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)	; vtable base
	ld xwa, (xwa + WS_HamaFnTable)             ; XWA = (XWA + 0x0E88)
	ld xix, (xwa + HamaFn_GetMediaType)		; XIX = (XWA + 0x08) — method ptr
	call (xix)			; call method
	cp l, 3:i3			; if L != 3
	jr z, .Lpb_continue		;   (L==3 → continue)
	cp l, 2:i3			; if L != 2 either
	jrl nz, .Lpb_exit		;   return

.Lpb_continue:
	; --- Call vtable method at +0x0538 ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)             ; XWA = (XWA + 0x0E0A)
	ld xhl, (xwa + RootFn_SleepMainTask)             ; XHL = (XWA + 0x0538)
	call (xhl)

	; --- Call vtable method at +0x0090, get XIZ ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)             ; XWA = (XWA + 0x0E88)
	ld_sril xhl, (xwa + HamaFn_GetVolumeLabel)             ; XHL = (XWA + 0x0090)
	call (xhl)
	ld xiz, xhl			; XIZ = result

	; --- If XIZ != 0: get strlen, copy to buffer ---
	ld xwa, xiz
	or xwa, xwa			; test zero
	jr z, .Lpb_empty_path		; if zero, clear buffer

	ld xwa, xiz
	push xwa
	call HDAE5000_StrLen			; strlen(XIZ)
	pushw hl			; push strlen
	ld xwa, xiz
	push xwa
	lda xwa, (HDAE5000_RAM_FdVolumeLabel:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 14)		; pop 14 bytes
	jr t, .Lpb_after_path

.Lpb_empty_path:
	ld (HDAE5000_RAM_FdVolumeLabel:24), 0x00

.Lpb_after_path:
	ld (0x230e26:24), 0x00; (0x230E26) = '\0'
	lda xwa, (HDAE5000_RAM_FdVolumeLabel:24)
	push xwa
	call HDAE5000_StrLen			; strlen(path buffer)
	inc 4, xsp
	cp hl, 0:i3			; if strlen > 0
	jr z, .Lpb_no_separator		;   skip separator append

	; Append separator
	pushw HDAE5000_Str_Chr202D3E@hi16			; max = 0x2E -- high half of HDAE5000_Str_Chr202D3E
	pushw	HDAE5000_Str_Chr202D3E@lo16		; low half of HDAE5000_Str_Chr202D3E
	pushw	0x0023
	pushw	0x0e1e
	call HDAE5000_StrCat
	inc 8, xsp

.Lpb_no_separator:
	; --- Call vtable method at +0x0094 to scan directory ---
	lda xwa, (HDAE5000_Str_Chr2A2E2A:24); XWA = 0x2E524A (param)
	ld xde, xwa
	lda xwa, (xsp + 8)		; XWA = &local[0x08]
	ld xbc, xwa
	ld xwa, xde			; restore XWA
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)             ; XDE = (XDE + 0x0E88)
	ld_sril xhl, (xde + HamaFn__findfirst)             ; XHL = (XDE + 0x0094)
	call (xhl)
	ld xiz, xhl			; XIZ = scan result

	; --- each name found: HDAE5000_FdLyricList_AddTlx ---
	lda xwa, (xsp + 14)		; XWA = &local[0x0E]
	calr HDAE5000_FdLyricList_AddTlx
	ld (xsp + 4), xhl		; save result

	jr t, .Lpb_validate		; always jump to validation

.Lpb_retry:
	lda xwa, (xsp + 14)
	calr HDAE5000_FdLyricList_AddTlx
	ld (xsp + 4), xhl

.Lpb_validate:
	; --- Call vtable method at +0x0098 (validate/next) ---
	lda xwa, (xsp + 8)		; XWA = &local[0x08]
	ld xbc, xwa
	ld xwa, xiz
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)             ; XDE = (XDE + 0x0E88)
	ld_sril xix, (xde + HamaFn__findnext)             ; XIX = (XDE + 0x0098)
	call (xix)
	cp hl, 0:i3
	jr z, .Lpb_retry		; if HL == 0, retry

	; --- Call vtable method at +0x009C ---
	ld xwa, xiz
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)             ; XBC = (XBC + 0x0E88)
	ld_sril xhl, (xbc + HamaFn__findclose)             ; XHL = (XBC + 0x009C)
	call (xhl)

	; --- Directory entry loop ---
	ld iz, 0:i3			; IZ = 0 (loop counter)
	cp iz, (HDAE5000_RAM_FdLyricCount:24)	; entry count
	jrl nc, .Lpb_loop_done		; if IZ >= count, done

.Lpb_entry_loop:
	; Compute entry address: 0x230884 + IZ*9
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3			; XBC = IZ * 8
	add xbc, xwa			; XBC = IZ * 9
	ld xwa, HDAE5000_RAM_FdLyricNames
	add xwa, xbc			; XWA = entry address
	push xwa
	lda xwa, (xsp+278)
	push xwa
	call HDAE5000_StrCpy

	; Append separator string
	pushw	HDAE5000_Str_TTX@hi16
	pushw	HDAE5000_Str_TTX@lo16		; low half of HDAE5000_Str_TTX
	lda xwa, (xsp+286)
	push xwa
	call HDAE5000_StrCat
	lda xsp, (xsp + 16)		; pop 16 bytes

	; --- Call vtable method at +0x00A0 (display entry) ---
	lda xwa, (xsp+274)
	lda xbc, (HDAE5000_Str_Rb_FdLyricTtx:24); XBC = 0x2E5254
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)             ; XDE = (XDE + 0x0E88)
	ld_sril xhl, (xde + HamaFn_fopen_ext)             ; XHL = (XDE + 0x00A0)
	call (xhl)

	; --- Compute entry index * 27, add to base ---
	ld wa, iz
	extz xwa
	ld xbc, 27			; 0x1B
	call HDAE5000_Multiply
	ld xwa, HDAE5000_RAM_FdLyricTitles
	add xwa, xhl			; XWA = base + IZ*27

	; --- Call vtable method at +0x00A8 ---
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)             ; XBC = (XBC + 0x0E88)
	ld_sril xhl, (xbc + HamaFn_fread_ext)             ; XHL = (XBC + 0x00A8)
	ld xbc, 26			; 0x1A
	call (xhl)

	; --- Call vtable method at +0x00AC ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)             ; XHL = (XWA + 0x00AC)
	call (xhl)

	; --- Same pattern: entry address IZ*9, copy, append, display ---
	ld wa, iz
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	add xbc, xwa
	ld xwa, HDAE5000_RAM_FdLyricNames
	add xwa, xbc
	push xwa
	lda xwa, (xsp+278)
	push xwa
	call HDAE5000_StrCpy			; memcpy
	pushw	HDAE5000_Str_MID@hi16
	pushw	HDAE5000_Str_MID@lo16		; low half of HDAE5000_Str_MID
	lda xwa, (xsp+286)
	push xwa
	call HDAE5000_StrCat			; strcat
	lda xsp, (xsp + 16)		; pop 16 bytes

	; --- Call vtable method at +0x00A0 via XIX ---
	lda xwa, (xsp+274)
	lda xbc, (HDAE5000_Str_Rb_FdLyricMid:24); XBC = 0x2E525E
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn_fopen_ext)             ; XIX = (XDE + 0x00A0)
	call (xix)

	; --- Check result and set flag ---
	cp hl, 0:i3
	jr lt, .Lpb_set_zero		; if HL < 0, set 0
	; HL >= 0: set flag to 1
	ld wa, iz
	extz xwa
	ld xbc, HDAE5000_RAM_FdLyricHasMid
	add xbc, xwa
	ld (xbc), 1			; flag[IZ] = 1
	jr t, .Lpb_entry_next

.Lpb_set_zero:
	ld wa, iz
	extz xwa
	ld xbc, HDAE5000_RAM_FdLyricHasMid
	add xbc, xwa
	ld (xbc), 0			; flag[IZ] = 0

.Lpb_entry_next:
	; --- Call vtable method at +0x00AC (advance) ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)
	call (xhl)

	; --- Loop control ---
	inc 1, iz			; IZ++
	cp iz, (HDAE5000_RAM_FdLyricCount:24)
	jrl c, .Lpb_entry_loop		; if IZ < count, loop

.Lpb_loop_done:
	; --- Call vtable method at +0x053C (finalize) ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_WakeUpMainTask)             ; XHL = (XWA + 0x053C)
	call (xhl)

.Lpb_exit:
	; --- Epilogue: return result and deallocate ---
	ld xhl, (xsp + 4)		; XHL = result
	pop xiz				; restore XIZ
	lda xsp, (xsp+370)
	ret

; ---------------------------------------------------------------------------
; Keep a file name from the floppy scan when it ends in ".TLX" (the reversed,
; upper-cased name must start with "XLT.": HDAE5000_StrRev, HDAE5000_StrUpr,
; HDAE5000_StrNCmp against HDAE5000_Str_XLT) and the list holds fewer than 40:
; its base name is inserted in HDAE5000_StrPrefixCmp order into the 9-byte
; slots of HDAE5000_RAM_FdLyricNames, HDAE5000_RAM_FdLyricCount + 1.
; In:  XWA = file name
; Out: HL = 0, or -1 when the list is full.
; ---------------------------------------------------------------------------
HDAE5000_FdLyricList_AddTlx:
	lda	xsp, (xsp-100)
	push xiz
	push xwa			; save arg1
	lda xwa, (xsp + 0x3a)
	push xwa
	call HDAE5000_StrCpy			; format string
	lda xwa, (xsp + 0x3e)
	push xwa
	call HDAE5000_StrRev			; parse name
	lda xwa, (xsp + 0x42)
	push xwa
	call HDAE5000_StrUpr			; validate
	pushw 0x0004
	pushw HDAE5000_Str_XLT@hi16
	pushw	HDAE5000_Str_XLT@lo16		; low half of HDAE5000_Str_XLT
	lda xwa, (xsp + 0x4c)
	push xwa
	call HDAE5000_StrNCmp			; search/match
	add xsp, 0x0000001a		; clean 26 bytes
	cp hl, 0:i3
	jrl nz, .Ldh_ret0

	; Check max entries
	cpw (HDAE5000_RAM_FdLyricCount:24), 0x0028
	jr c, .Ldh_under_limit
	ld xhl, 0xffffffff		; return -1 (full)
	jrl t, .Ldh_epilogue

.Ldh_under_limit:
	lda xwa, (xsp + 0x36)
	push xwa
	call HDAE5000_StrRev
	lda xwa, (xsp + 0x3a)
	push xwa
	lda xwa, (xsp + 0x0c)
	push xwa
	call HDAE5000_StrCpy
	lda xwa, (xsp + 0x10)
	push xwa
	call HDAE5000_StrLen			; string compare
	lda xsp, (xsp + 0x10)		; clean 16 bytes
	dec 4, hl
	ld wa, hl
	extz xwa
	lda xbc, (xsp + 0x04)
	add xbc, xwa
	ld (xbc), 0x00		; null-terminate

	; First entry? (count == 0)
	cpw (HDAE5000_RAM_FdLyricCount:24), 0x0000
	jr nz, .Ldh_search

	; Direct insert at slot 0
	lda xwa, (xsp + 0x04)
	push xwa
	lda xwa, (HDAE5000_RAM_FdLyricNames:24)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp			; clean 8 bytes
	incw 1, (HDAE5000_RAM_FdLyricCount:24)
	ld xhl, 0:i3
	jrl t, .Ldh_epilogue

	; Sorted insertion search
.Ldh_search:
	ldiw_erp 0xfa, 0		; QIZ = 0 (search index)
	ldto_werp wa, 0xfa		; WA = QIZ
	cp wa, (HDAE5000_RAM_FdLyricCount:24); compare QIZ with count
	jrl nc, .Ldh_append

.Ldh_search_loop:
	ldto_werp wa, 0xfa		; WA = QIZ
	muls wa, 0x0009			; slot offset = QIZ * 9
	lda xbc, (HDAE5000_RAM_FdLyricNames:24)
	exts xwa
	add xwa, xbc			; XWA = slot address
	push xwa
	lda xwa, (xsp + 0x08)
	push xwa
	call HDAE5000_StrPrefixCmp			; string compare
	inc 8, xsp			; clean 8 bytes
	cp hl, 0:i3
	jr ge, .Ldh_next_slot

	; Found insert position — shift entries down
	ld iz, (HDAE5000_RAM_FdLyricCount:24); IZ = total count
	cpw_erp iz, 0xfa		; compare IZ with QIZ
	jr le, .Ldh_do_insert

	; Shift loop: move entries [QIZ..IZ-1] down by one slot
.Ldh_shift_loop:
	ld wa, iz
	muls wa, 0x0009
	lda xbc, (HDAE5000_RAM_FdLyricNames - 9:24); offset -9 from table base (src)
	exts xwa
	add xwa, xbc
	push xwa			; source
	ld wa, iz
	muls wa, 0x0009
	lda xbc, (HDAE5000_RAM_FdLyricNames:24); table base (dst)
	exts xwa
	add xwa, xbc
	push xwa			; destination
	call HDAE5000_StrCpy			; copy 9-byte entry
	inc 8, xsp
	dec 1, iz
	cpw_erp iz, 0xfa
	jr gt, .Ldh_shift_loop

.Ldh_do_insert:
	lda xwa, (xsp + 0x04)
	push xwa
	ldto_werp wa, 0xfa
	muls wa, 0x0009
	lda xbc, (HDAE5000_RAM_FdLyricNames:24)
	exts xwa
	add xwa, xbc
	push xwa
	call HDAE5000_StrCpy			; copy entry to insert position
	inc 8, xsp
	incw 1, (HDAE5000_RAM_FdLyricCount:24)
	ld xhl, 0:i3
	jr t, .Ldh_epilogue

.Ldh_next_slot:
	inc1w_erp 0xfa			; QIZ++
	ldto_werp wa, 0xfa
	cp wa, (HDAE5000_RAM_FdLyricCount:24)
	jrl c, .Ldh_search_loop

	; Append at end (no sorted position found)
.Ldh_append:
	lda xwa, (xsp + 0x04)
	push xwa
	ld wa, (HDAE5000_RAM_FdLyricCount:24)
	extz xwa
	ld xbc, xwa
	sll xbc, 3
	add xbc, xwa
	ld xwa, HDAE5000_RAM_FdLyricNames
	add xwa, xbc
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	incw 1, (HDAE5000_RAM_FdLyricCount:24)
	ld xhl, 0:i3
	jr t, .Ldh_epilogue

.Ldh_ret0:
	ld xhl, 0:i3
.Ldh_epilogue:
	pop xiz
	lda xsp, (xsp + 0x64)		; restore stack (+100)
	ret

	; ============================================================
	; Event code matcher — check for 0x01E0009F
	; ============================================================
	; Firmware's own name: HDAE5000_ObjHandler_Table entry 64 is 0x28F2F7
	; and the parallel HDAE5000_ObjName_Table entry points at 0x29BB48 =
	; "LanguageTextReturn".  0x2E5D72 is a table of six 32-bit pointers to
	; the nine-character language-text names "LANENG001" (0x2E5DBC),
	; "LANDEU002" (0x2E5DB2), "LANFRA003" (0x2E5DA8), "LANENG004"
	; (0x2E5D9E), "LANENG005" (0x2E5D94) and "LANENG006" (0x2E5D8A).
	; [INFERENCE] they read as file stems: ".TTX", ".MID" and "XLT." sit a
	; few bytes earlier.  Nothing here concerns directories: the old name
	; Dir_Event_Check was a misnomer.
HDAE5000_LanguageTextReturn:
	cp xbc, EVT_GET_LANGUAGE_PTR
	jr nz, .Ldec_no
	lda xhl, (HDAE5000_TextPtrs_LANENG001_to_LANENG006:24)
	ret
.Ldec_no:
	ld xhl, 0:i3
	ret

	; ============================================================
	; Format + ROM region setup helper
	; ============================================================
HDAE5000_PPORT_Svc28_FlashXapFile:
	; PC-link service 28 (HDAE5000_PPORT_ServiceTable[28]; no trace banner):
	; builds a descriptor on the stack -- "XAP" (0x2E5DC6), XBC, 0x280000,
	; 0x2F0000 (this ROM's own range) -- and calls RAM 0x23FEB0 with it;
	; command 20 is "Send XapFile flash".  Nothing in this ROM puts code at
	; 0x23FEB0, so what runs there is not established here.
	lda	xsp, (xsp-24)
	push xiz
	ld xiz, xbc			; save XBC in XIZ
	ld (xsp + 0x18), xwa		; save arg1
	pushw HDAE5000_Str_XAP@hi16
	pushw	HDAE5000_Str_XAP@lo16		; low half of HDAE5000_Str_XAP
	lda xwa, (xsp + 0x08)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	ld (xsp + 0x08), xiz		; store XIZ to stack
	ld xwa, HDAE5000_ROM_HEADER
	ld (xsp + 0x14), xwa
	ld xwa, HDAE5000_XAP_DESC_LIMIT
	ld (xsp + 0x0c), xwa
	ld xwa, (xsp + 0x18)
	ld xbc, (xsp + 0x04)
	call HDAE5000_RAM_XAP_FLASH_ENTRY
	pop xiz
	lda xsp, (xsp + 0x18)
	ret

	; ============================================================
	; Vtable helper: call method 0x0538 (flush), return HL=0
	; ^ "flush" is not established: see the header below.
	; ============================================================
HDAE5000_PPORT_Svc29_SleepMainTask:
	; PC-link service 29: call the main-CPU hook 0x0E0A table +0x538 -- the
	; one HDAE5000_LoadSong/SaveSong call before a long operation when their
	; UI flag is 1 -- and return HL = 0.
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XHL, (xwa + RootFn_SleepMainTask)             ; method 0x0538
	call (xhl)
	ld hl, 0:i3
	ret

	; ============================================================
	; Vtable helper: call method 0x053C (close), return HL=0
	; ^ "close" is not established: see the header below.
	; ============================================================
HDAE5000_PPORT_Svc30_WakeUpMainTask:
	; PC-link service 30: the matching +0x53C hook (called after the
	; operation); HL = 0.
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld XWA, (xwa + WS_RootFnTable)
	ld XHL, (xwa + RootFn_WakeUpMainTask)             ; method 0x053C
	call (xhl)
	ld hl, 0:i3
	ret

	; ============================================================
	; Variable-length integer encoder (MIDI-style VarInt)
	; Encodes a 32-bit value using 7-bit chunks, MSB-first.
	; Format: bit 7 = 1 means "more bytes follow" (continuation)
	;         bit 7 = 0 means "this is the last byte"
	; Example: 389 (0x185) → [0x83, 0x05]
	;   0x83 = 1_0000011 (cont=1, payload=3)
	;   0x05 = 0_0000101 (cont=0, payload=5)
	;   Decoded: (3 << 7) | 5 = 389
	; Max 5 bytes for 32-bit values (5 × 7 = 35 bits)
	; Algorithm: Extract 7-bit chunks LSB-first into temp buffer,
	;   then reverse into output setting bit 7 on all but last
	; Input: XWA = value to encode, XBC = output buffer pointer
	; Output: XHL = number of bytes written (1-5)
	; ============================================================
HDAE5000_VarInt_Encode:
	dec 6, xsp			; allocate 6-byte temp buffer
	ld xix, xwa			; XIX = value to encode
	ld hl, 0:i3			; HL = byte count

	; --- Phase 1: Extract 7-bit chunks LSB-first into temp buffer ---
.Lve_extract:
	lda xde, (xsp + 0x00)		; XDE = temp buffer base on stack
	ld xwa, xix
	and xwa, 0x0000007f		; extract low 7 bits of remaining value
	ld	(xde+hl), a	; temp[HL] = A (store 7-bit chunk)
	srl xix, 7			; shift remaining value right by 7
	inc 1, hl			; HL = chunk count
	or xix, xix			; any bits left?
	jr nz, .Lve_extract		; loop until value fully consumed

	; --- Phase 2: Reverse chunks into output, set continuation bits ---
	; temp[] has chunks in LSB-first order; output needs MSB-first
	ld ix, 1:i3			; IX = reverse index (skip first temp byte)
	cp ix, hl			; only one chunk? skip to last
	jr ge, .Lve_copy_last

.Lve_set_msb:
	ld wa, hl
	sub wa, ix			; WA = count - reverse_index
	ld de, wa
	dec 1, de			; DE = output position
	lda xwa, (xsp + 0x00)
	ld	a, (xwa+ix)	; A = temp[IX] — load chunk (MSB-first order)
	set 7, a			; set continuation bit (more bytes follow)
	ld	(xbc+de), a	; output[DE] = A — store to caller's buffer
	inc 1, ix
	cp ix, hl
	jr lt, .Lve_set_msb

	; --- Phase 3: Copy final byte WITHOUT continuation bit ---
.Lve_copy_last:
	ld de, hl
	dec 1, de			; DE = last output position
	ld8_src_rid8 xsp, 0x00, a		; A = temp[0] — LSB chunk (becomes last output byte)
	ld	(xbc+de), a	; output[DE] = A (bit 7 clear = final byte)
	exts xhl			; sign-extend HL to XHL (byte count)
	inc 6, xsp			; free temp buffer
	ret

	; ============================================================
	; Variable-length integer decoder (MIDI-style VarInt)
	; Reads MSB-first 7-bit chunks; bit 7 = 1 means "more bytes"
	; Max 5 bytes (35 bits). Returns -1 if encoding is invalid.
	; Input: XWA = data pointer, XBC = output byte count pointer
	; Output: XHL = decoded value, or 0xFFFFFFFF on error
	; Side effect: stores bytes consumed to (XBC)
	; ============================================================
HDAE5000_VarInt_Decode:
	ld xde, xwa			; XDE = data pointer
	ld ix, 0:i3			; IX = byte index
	ld xhl, 0:i3			; XHL = accumulator

	ld a, (xde)			; A = first byte (for length check)
	ldfr_berp a, 0xf4		; IYL = A (save first byte)

.Lvd_loop:
	ld	a, (xde+ix)	; A = data[IX] — load current byte
	res 7, a			; strip continuation bit → 7-bit payload
	ld w, 0:opc			; W = 0
	extz xwa			; XWA = payload (zero-extended to 32-bit)
	add xhl, xwa			; accumulate: XHL += payload

	bit	7, (xde+ix)	; test continuation bit of data[IX]
	jr nz, .Lvd_continue
	; Continuation=0 → this was the last byte, decoding complete
	ldto_berp a, 0xf0		; A = IXL (byte index)
	inc 1, a			; A = bytes consumed
	ld (xbc), a			; store byte count to caller's pointer
	ret

.Lvd_continue:
	; Continuation=1 → more bytes follow
	inc 1, ix			; advance to next byte
	sll xhl, 7			; make room for next 7-bit chunk
	cp ix, 4:i3
	jr le, .Lvd_length_check
	cpib_erp 0xf4, 7		; if first byte > 7 and >4 bytes: invalid
	jr ugt, .Lvd_error

.Lvd_length_check:
	cp ix, 5:i3			; max 5 bytes (35 bits for 32-bit values)
	jr le, .Lvd_loop

.Lvd_error:
	ld xhl, 0xffffffff		; return -1 (invalid VarInt encoding)
	ret

; ---------------------------------------------------------------------------
; Reverse the four bytes of XWA (a big-endian SMF long -> native), unrolled.
; In:  XWA
; Out: XHL = XWA byte-reversed.  Clobbers XWA, XBC.
; ---------------------------------------------------------------------------
HDAE5000_Smf_SwapBytes32:	.include "includes/generated/cc900/HDAE5000_Smf_SwapBytes32.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Swap the two bytes of WA (a big-endian SMF word -> native).
; In:  WA
; Out: HL = WA byte-swapped.  Clobbers WA.
; The code after its `ret` is HDAE5000_Smf_ReadHeader (no caller).
; ---------------------------------------------------------------------------
HDAE5000_Smf_SwapBytes16:	.include "includes/generated/cc900/HDAE5000_Smf_SwapBytes16.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Unreachable (no reference anywhere): with media type 2 or 3
; (HamaFn_GetMediaType), open floppy file XWA "rb" (HamaFn_fopen_ext,
; HDAE5000_Str_Rb_Smf_ReadHeader), read its first 14 bytes into
; HDAE5000_RAM_SmfHeader and close it, the main task asleep meanwhile; then
; HDAE5000_Smf_CheckHeader on the buffer either way.
; In:  XWA = file name
; Out: XHL = HDAE5000_Smf_CheckHeader's result.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_Smf_ReadHeader:
	push xiz
	ld xiz, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld xix, (xwa + HamaFn_GetMediaType)
	call (xix)
	cp l, 3:i3
	jr z, .Lec_process
	cp l, 2:i3
	jr nz, .Lec_finish
.Lec_process:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SleepMainTask)
	call (xhl)
	ld xwa, xiz
	lda xbc, (HDAE5000_Str_Rb_Smf_ReadHeader:24)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xhl, (xde + HamaFn_fopen_ext)
	call (xhl)
	lda xwa, (HDAE5000_RAM_SmfHeader:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn_fread_ext)
	ld xbc, 0x0000000E
	call (xhl)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)
	call (xhl)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_WakeUpMainTask)
	call (xhl)
.Lec_finish:
	lda xwa, (HDAE5000_RAM_SmfHeader:24)
	calr HDAE5000_Smf_CheckHeader
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Check a 14-byte Standard MIDI File header: "MThd" (0x4D546864 after
; HDAE5000_Smf_SwapBytes32, else -1), length 6 (else -2), format <= 1 (kept in
; HDAE5000_RAM_SmfFormat, else -3), the track count (HDAE5000_RAM_SmfTrackCount)
; and the division (HDAE5000_RAM_SmfDivision), whose bit 15 (SMPTE) must be
; clear (else -4).
; In:  XWA = header
; Out: XHL = 0 when it passes, else the negative code.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_Smf_CheckHeader:
	push xiz
	ld xiz, xwa
	ld xwa, (xiz)
	calr HDAE5000_Smf_SwapBytes32
	cp xhl, 0x4D546864		; check magic "MThd" (MIDI header, reversed)
	jr z, .Lci_check1
	ld xhl, 0xFFFFFFFF
	jr t, .Lci_exit
.Lci_check1:
	ld xwa, (xiz + 4)
	calr HDAE5000_Smf_SwapBytes32
	cp xhl, 0x00000006
	jr z, .Lci_check2
	ld xhl, 0xFFFFFFFE
	jr t, .Lci_exit
.Lci_check2:
	ld wa, (xiz + 8)
	calr HDAE5000_Smf_SwapBytes16
	ld (HDAE5000_RAM_SmfFormat:24), hl
	cpw (HDAE5000_RAM_SmfFormat:24), 0x0001
	jr ule, .Lci_check3
	ld xhl, 0xFFFFFFFD
	jr t, .Lci_exit
.Lci_check3:
	ld wa, (xiz + 10)
	calr HDAE5000_Smf_SwapBytes16
	ld (HDAE5000_RAM_SmfTrackCount:24), hl
	ld wa, (xiz + 12)
	calr HDAE5000_Smf_SwapBytes16
	ld (HDAE5000_RAM_SmfDivision:24), hl
	ld wa, (HDAE5000_RAM_SmfDivision:24)
	bit 15, wa
	jr z, .Lci_ok
	ld xhl, 0xFFFFFFFC
	jr t, .Lci_exit
.Lci_ok:
	ld xhl, 0:i3
.Lci_exit:
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Bitmap resource descriptor of the boot splash screen (it allocates nothing:
; a constant lookup, the fifth of five alike -- Logo, DriveMech, FilePanel,
; Icon and this one).  320 x 240 at 8 bpp is 76,800 bytes, which agrees with
; the two 0x9600-byte VRAM copies in HDAE5000_Boot_Init and with the extent
; of HDAE5000_Bitmap_BootSplash.
; In:  XBC = EVT_GET_BITMAP_DATA / _WIDTH / _HEIGHT
; Out: XHL = HDAE5000_Bitmap_BootSplash, 0x140 (320) or 0xF0 (240); 0 for any
;      other event.
; ---------------------------------------------------------------------------
HDAE5000_Alloc_Memory:
	cp xbc, EVT_GET_BITMAP_HEIGHT
	jr z, HDAE5000_Alloc_Memory__type_A3
	cp xbc, EVT_GET_BITMAP_WIDTH
	jr z, HDAE5000_Alloc_Memory__type_A2
	cp xbc, EVT_GET_BITMAP_DATA
	jr z, HDAE5000_Alloc_Memory__type_A1
	ld xhl, 0:i3
	ret
HDAE5000_Alloc_Memory__type_A1:
	lda xhl, (HDAE5000_Bitmap_BootSplash:24)
	ret
HDAE5000_Alloc_Memory__type_A2:
	ld xhl, 0x140
	ret
HDAE5000_Alloc_Memory__type_A3:
	ld xhl, 0xF0
	ret

; ---------------------------------------------------------------------------
; L = HDAE5000_RAM_HdPresent, HDAE5000_Check_HD_Present's result at boot.
; ---------------------------------------------------------------------------
HDAE5000_Get_Init_Flag:
	ld l, (HDAE5000_RAM_HdPresent:24)
	ret

; ============================================================================
; BOOT INITIALIZATION ROUTINE (0x28F576 - 0x28F661)
; Called once at startup when HDAE5000 is detected via header validation
;
; Input: XWA = workspace structure pointer from main CPU
; Output: L = HD presence flag (stored at 0x230EDA)
;
; This routine:
;   1. Clears work buffer (0xF52A bytes at 0x22A000)
;   2. Registers handlers with main CPU via callback at 0x280020
;   3. Loads the VGA palette HDAE5000_Palette_BootSplash (ROM 0x2E5DCE)
;   4. Blits HDAE5000_Bitmap_BootSplash (ROM 0x2E61CE, 320x240x8bpp = 0x12C00
;      bytes) INTO VRAM at 0x1A0000, as two contiguous 0x9600-byte copies
;   5. Initializes handler function pointers at 0x230ECC/ED2/ED6
;   6. Checks for HD presence via 0x2971A3
;   7. Registers frame handler callback via 0x2803C2
;
; Key addresses called:
;   0x28F785 - Clear work buffer
;   0x280020 - Handler registration (code section 1)
;   0x28F8E0 - Load palette
;   0x28F543 - Memory allocation (code section 1)
;   0x29AE9F - Memory copy
;   0x2971A3 - Check HD present
;   0x28F90B - Finalize init
;   0x2803C2 - Register frame handler (code section 1)
; ============================================================================

; RAM variable addresses
.equ HDAE5000_WORKSPACE_PTR, 0x23A1A2
.equ HDAE5000_HANDLER_1, 0x230ECC
.equ HDAE5000_HANDLER_2, 0x230ED2
.equ HDAE5000_HANDLER_3, 0x230ED6
.equ HDAE5000_INIT_FLAG, 0x230EDA

; Handler registration data addresses (used by HDAE5000_Handler_Registration)
	; (EQU→inline label) HDAE5000_RECORD_COUNT = 0x29D97E
	; (EQU→inline label) HDAE5000_RECORD_TABLE = 0x29C0AA
					; Records: SelectList, DbMemoCl, TtlScreenR, AcHddNamingWindow,
					; IvHddNaming, HDTitleMenu, TtlScreenR2, TtlScreenR3,
					; AcWindowPage1, IvScreenR2, AcLanguageText1, LyricBox, FDFileSelect
; The RAM tables registered by HDAE5000_Handler_Registration (and the other image labels the
; code reaches) are HDAE5000_RAM_<label>, defined at the end of hdae5000_init_data.s from the
; labels themselves.  (The .equs that used to stand here, HDAE5000_RAM_DATA_A_SIZE ...
; HDAE5000_PARALLEL_DATA_2, were unused and misnamed: 0x239822 is the ResEvent count,
; 0x239872 the Function table, 0x239FD2 the MainFunction table.)
.equ HDAE5000_DATA_COPY_DEST, 0x2394ce	; Init data copy destination (v2.01i: 0x2394ce, see hdae5000_init_data.s)
.equ HDAE5000_RAM_XAP_FLASH_ENTRY, 0x23feb0	; main-CPU RAM; HDAE5000_PPORT_Svc28_FlashXapFile calls it with the "XAP" descriptor.  Nothing in this ROM writes code there; what the main CPU puts there is not established
.equ HDAE5000_XAP_DESC_LIMIT, 0x2f0000	; the descriptor's fourth word, after HDAE5000_ROM_HEADER (0x280000); 0x2F0000 is inside image data here, so it is a value, not a pointer.  Its meaning is not established
	; (EQU→inline label) HDAE5000_UiObject_PtrTable = 0x2A5D2C
	; (EQU→inline label) HDAE5000_UiObjectName_PtrTable = 0x2A6984
	; (EQU→inline label) HDAE5000_GFX_INIT_PARAMS = 0x2A849A

; ROM data addresses
	; (EQU→inline label) HDAE5000_Palette_BootSplash = 0x2E5DCE
	; (EQU→inline label) HDAE5000_Bitmap_BootSplash = 0x2E61CE
	; (EQU→inline label) HDAE5000_Display_Params = 0x2F8DCE

; All routine addresses are now exposed as labels in split binary sections

; PPORT state machine handler (in code_28f90c_2953e1.bin)
	; (EQU→inline label) HDAE5000_PPORT_ServicePending = 0x29501C

; PPORT command handler addresses (in code_295642_2fffff.bin)
	; (EQU→inline label) HDAE5000_PPORT_Cmd06_WriteFsbToHd = 0x2958D6
	; (EQU→inline label) HDAE5000_PPORT_Cmd07_LoadHdToMemory = 0x295914
	; (EQU→inline label) HDAE5000_PPORT_Cmd08_SendDataToPc = 0x2959F6
	; (EQU→inline label) HDAE5000_PPORT_Cmd09_SendFilesToPc = 0x295D3C
	; (EQU→inline label) HDAE5000_PPORT_Cmd10_RcvDataFromPc = 0x29605A
	; (EQU→inline label) HDAE5000_PPORT_Cmd11_SaveMemoryToHd = 0x296294
	; (EQU→inline label) HDAE5000_PPORT_Cmd12_Nothing = 0x29632A
	; (EQU→inline label) HDAE5000_PPORT_Cmd13_RcvDataFromPc = 0x29633C
	; (EQU→inline label) HDAE5000_PPORT_Cmd14_SendInfosToPc = 0x2964A6
	; (EQU→inline label) HDAE5000_PPORT_Cmd15_Nothing = 0x296588
	; (EQU→inline label) HDAE5000_PPORT_Cmd16_DeleteFiles = 0x29659A
	; (EQU→inline label) HDAE5000_PPORT_Cmd17_FormatHd = 0x296680

HDAE5000_Boot_Init:	.include "includes/generated/cc900/HDAE5000_Boot_Init.s"	; C: cc900/hdae5000_boot.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_Boot_Init__skip_hd_init, HDAE5000_Boot_Init + 226

; ============================================================================
; CODE SECTION 2 PART A (0x28F662 - 0x2953E1)
; Frame handler and utility routines before PPORT command table
;
; Key routines in this section:
;   0x28F662  Frame_Handler - Main frame handler entry
;   0x28F781  Frame_Handler_Exit - JP to PPORT handler
;   0x28F785  Clear_Work_Buffer - Clear work area, copy init data
;   0x28F7DD  Delay_Loop - Timing utility
;   0x28F7EE  VGA_Port_Write - Write to VGA DAC registers
;   0x28F813  Palette_Setup - Configure single palette entry
;   0x28F8E0  Load_Palette - Load all 256 palette entries
;   0x28F90B  Finalize_Init - Just returns (stub)
;   0x28F90C  Display_Init - Display initialization
; ============================================================================

HDAE5000_Frame_Handler:	.include "includes/generated/cc900/HDAE5000_Frame_Handler.s"	; C: cc900/hdae5000_boot.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_Frame_Handler_Status, HDAE5000_Frame_Handler + 126
	.set	HDAE5000_Frame_Handler_Status__init_display, HDAE5000_Frame_Handler + 202
	.set	HDAE5000_Frame_Handler_Exit, HDAE5000_Frame_Handler + 287

; ----------------------------------------------------------------------------
; Utility routines (0x28F785 - 0x2953E1)
; ----------------------------------------------------------------------------

HDAE5000_Clear_Work_Buffer:
	; Clear work buffer and copy initialization data from ROM
	; Part 1: Clear 0xF4CE bytes (62,670) at 0x22A000 using word operations,
	;         up to 0x2394CE where Part 2's image starts
	; Part 2: Copy 0x0C48 bytes (3,144) from ROM 0x2F899E to RAM 0x2394CE
	;
	; Uses LDIRW for word block copy, LDIR for byte copy
	; Handles large counts via QBC (high word of XBC) loop
	;
	; === Part 1: Clear work buffer ===
	ld xde, HDAE5000_RAM_NamingText	; Destination = work buffer
	ld xbc, 0xf4ce	; Count = 62,670 bytes
	ld ix, bc	; Save low word for odd byte check
	srl xbc, 1	; srl 1, XBC  ; divide by 2 for word ops
	jr z, HDAE5000_Clear_Work_Buffer__clear_done	; Skip if count was 0 or 1
	ld xhl, xde	; Source = destination (for LDIRW)
	ldw (xde+), 0x0000	; ld (XDE+), 0x0000  ; store first word
	dec 1, xbc
	or xbc, xbc
	jr z, HDAE5000_Clear_Work_Buffer__clear_done
	mriw2 0x93, 0x11	; ldirw  ; copy words (fills with zeros)
	cpiw_erp 0xE6, 0	; cp QBC, 0  ; check high word
	jr z, HDAE5000_Clear_Work_Buffer__clear_done
	ldto_werp WA, 0xE6	; ld WA, QBC  ; get high word count
HDAE5000_Clear_Work_Buffer__clear_loop:
	mriw2 0x93, 0x11	; ldirw  ; continue word copy
	djnz16 wa, HDAE5000_Clear_Work_Buffer__clear_loop	; djnz WA, .clear_loop
HDAE5000_Clear_Work_Buffer__clear_done:
	bit 0, ix	; bit 0, IX  ; check if odd byte
	jr z, HDAE5000_Clear_Work_Buffer__no_odd_byte
	ld (xde), 0x0	; Clear final odd byte
HDAE5000_Clear_Work_Buffer__no_odd_byte:
	; === Part 2: Copy init data from ROM to RAM ===
	ld xde, HDAE5000_DATA_COPY_DEST	; Destination = RAM init area (the image's copy)
	ld xhl, HDAE5000_DataSegmentImage	; Source = ROM init data
	ld xbc, 0xc48	; Count = 3,144 bytes
	or xbc, xbc
	jr z, HDAE5000_Clear_Work_Buffer__copy_done
	ldir83	; ldir  ; copy bytes
	cpiw_erp 0xE6, 0	; cp QBC, 0
	jr z, HDAE5000_Clear_Work_Buffer__copy_done
	ldto_werp WA, 0xE6	; ld WA, QBC
HDAE5000_Clear_Work_Buffer__copy_loop:
	ldir83	; ldir
	djnz16 wa, HDAE5000_Clear_Work_Buffer__copy_loop	; djnz WA, .copy_loop
HDAE5000_Clear_Work_Buffer__copy_done:
	ret

; ---------------------------------------------------------------------------
; Busy-wait: count XWA down to zero.
; In:  XWA = count
; Out: clobbers XWA, XBC.
; ---------------------------------------------------------------------------
HDAE5000_Delay_Loop:	.include "includes/generated/cc900/HDAE5000_Delay_Loop.s"	; C: cc900/hdae5000_ui_display.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_Delay_Loop__inner_loop, HDAE5000_Delay_Loop + 8

; ---------------------------------------------------------------------------
; Write a byte to a display-controller I/O port, at HDAE5000_IO_VgaPorts +
; port, after a 0x100 busy-wait (HDAE5000_Delay_Loop).  Ports used: 0x3C8
; (palette index), 0x3C9 (palette data).
; In:  WA = port, C = byte.  IZ preserved; clobbers XWA, XBC.
; ---------------------------------------------------------------------------
HDAE5000_VGA_Port_Write:
	dec 2, xsp
	pushw iz
	ld (xsp + 2), c
	ld iz, wa
	ld xwa, 0x100
	calr HDAE5000_Delay_Loop
	ld wa, iz
	extz xwa
	add xwa, HDAE5000_IO_VgaPorts
	ld xbc, xwa
	ld a, (xsp + 2)
	ld (xbc), a
	popw iz
	inc 2, xsp
	ret

; ---------------------------------------------------------------------------
; Set one palette entry: the index to port 0x3C8, then the R, G, B bytes of
; the 4-byte RGBx entry to port 0x3C9, each as value >> 4, plus 1 when its bit
; 3 is set and the value is below 0xF0 (rounding) (HDAE5000_VGA_Port_Write).
; In:  A = index, XBC = the RGBx entry.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_Palette_Setup:
	push xiz
	ld xiz, xbc
	extz wa
	ld bc, wa
	ldw wa, 0x3C8
	calr HDAE5000_VGA_Port_Write
	;
	; === Process Red component (XIZ+0) ===
	bitm 3, (xiz)
	jr z, HDAE5000_Palette_Setup__red_no_round
	cp (xiz), 0xF0
	jr nc, HDAE5000_Palette_Setup__red_high
	ld a, (xiz)
	srl a, 4
	inc 1, a
	extz wa
	ld bc, wa
	ldw wa, 0x3C9
	calr HDAE5000_VGA_Port_Write
	jr HDAE5000_Palette_Setup__green_start
HDAE5000_Palette_Setup__red_high:
	ld a, (xiz)
	srl a, 4
	extz wa
	ld bc, wa
	ldw wa, 0x3C9
	calr HDAE5000_VGA_Port_Write
	jr HDAE5000_Palette_Setup__green_start
HDAE5000_Palette_Setup__red_no_round:
	ld a, (xiz)
	srl a, 4
	extz wa
	ld bc, wa
	ldw wa, 0x3C9
	calr HDAE5000_VGA_Port_Write
	;
	; === Process Green component (XIZ+1) ===
HDAE5000_Palette_Setup__green_start:
	bitm 3, (xiz + 1)
	jr z, HDAE5000_Palette_Setup__green_no_round
	cp (xiz + 1), 0xF0
	jr nc, HDAE5000_Palette_Setup__green_high
	ld a, (xiz + 1)
	srl a, 4
	inc 1, a
	extz wa
	ld bc, wa
	ldw wa, 0x3C9
	calr HDAE5000_VGA_Port_Write
	jr HDAE5000_Palette_Setup__blue_start
HDAE5000_Palette_Setup__green_high:
	ld a, (xiz + 1)
	srl a, 4
	extz wa
	ld bc, wa
	ldw wa, 0x3C9
	calr HDAE5000_VGA_Port_Write
	jr HDAE5000_Palette_Setup__blue_start
HDAE5000_Palette_Setup__green_no_round:
	ld a, (xiz + 1)
	srl a, 4
	extz wa
	ld bc, wa
	ldw wa, 0x3C9
	calr HDAE5000_VGA_Port_Write
	;
	; === Process Blue component (XIZ+2) ===
HDAE5000_Palette_Setup__blue_start:
	bitm 3, (xiz + 2)
	jr z, HDAE5000_Palette_Setup__blue_no_round
	cp (xiz + 2), 0xF0
	jr nc, HDAE5000_Palette_Setup__blue_high
	ld a, (xiz + 2)
	srl a, 4
	inc 1, a
	extz wa
	ld bc, wa
	ldw wa, 0x3C9
	calr HDAE5000_VGA_Port_Write
	jr HDAE5000_Palette_Setup__done
HDAE5000_Palette_Setup__blue_high:
	ld a, (xiz + 2)
	srl a, 4
	extz wa
	ld bc, wa
	ldw wa, 0x3C9
	calr HDAE5000_VGA_Port_Write
	jr HDAE5000_Palette_Setup__done
HDAE5000_Palette_Setup__blue_no_round:
	ld a, (xiz + 2)
	srl a, 4
	extz wa
	ld bc, wa
	ldw wa, 0x3C9
	calr HDAE5000_VGA_Port_Write
HDAE5000_Palette_Setup__done:
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Load all 256 palette entries from a table of 4-byte RGBx entries, index 255
; down to 0 (HDAE5000_Palette_Setup).
; In:  XWA = the table.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_Load_Palette:
	dec 4, xsp
	pushw iz
	ld (xsp + 2), xwa
	ldw iz, 0xFF
	cp iz, 0:i3
	jr lt, HDAE5000_Load_Palette__done
HDAE5000_Load_Palette__loop:
	ldto_berp E, 0xF8
	ld wa, iz
	exts xwa
	sll xwa, 2
	ld xbc, xwa
	add xbc, (xsp + 2)
	ld a, e
	calr HDAE5000_Palette_Setup
	sub iz, 0x1
	jr ge, HDAE5000_Load_Palette__loop
HDAE5000_Load_Palette__done:
	popw iz
	inc 4, xsp
	ret

; ---------------------------------------------------------------------------
; Empty: a lone `ret`, called at the end of HDAE5000_Boot_Init.
; ---------------------------------------------------------------------------
HDAE5000_Finalize_Init:
	ret

; ---------------------------------------------------------------------------
; Format the hard disk (HDAE5000_HD_Format) inside the main-CPU bracket:
; HamaFn_PlayHalt(1) before, HamaFn_PlayStandBy and HamaFn_EditSwRefresh
; after; with WA = 1 also RootFn_SleepMainTask before the format and
; RootFn_WakeUpMainTask after it.  Callers: HDAE5000_AttenHDFormatSwCatch
; and HDAE5000_PPORT_Svc17_FormatHd.
; In:  WA = 1 to put the main task to sleep during the format
; Out: HL = HDAE5000_HD_Format's result (0 = formatted).  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_FormatDrive:
	dec 2, xsp
	pushw iz
	ld iz, wa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_PlayHalt)
	ld wa, 1:i3
	call (xhl)
	cp iz, 1:i3
	jr nz, .Ldi_skip1
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SleepMainTask)
	call (xhl)
.Ldi_skip1:
	call HDAE5000_HD_Format
	ld (xsp + 2), hl
	cp iz, 1:i3
	jr nz, .Ldi_skip2
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_WakeUpMainTask)
	call (xhl)
.Ldi_skip2:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_PlayStandBy)
	call (xhl)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_EditSwRefresh)
	call (xhl)
	ld hl, (xsp + 2)
	popw iz
	inc 2, xsp
	ret

; ---------------------------------------------------------------------------
; Address of a directory's 16-byte name in HDAE5000_RAM_DirNames.
; In:  WA = directory
; Out: XHL = DirNames + WA * 16.  Clobbers XWA.
; ---------------------------------------------------------------------------
HDAE5000_DirName_Address:	.include "includes/generated/cc900/HDAE5000_DirName_Address.s"	; C: cc900/hdae5000_record_addr.c

; ---------------------------------------------------------------------------
; Set a directory's 16-byte name (HDAE5000_StrNCpy into HDAE5000_RAM_DirNames)
; and write the tables (HDAE5000_HD_StoreTables(DE)).
; In:  WA = directory, XBC = name, DE = 1 to leave the drive spinning
; Out: HL as HDAE5000_HD_StoreTables returns it.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_DirName_SetAndStore:	.include "includes/generated/cc900/HDAE5000_DirName_SetAndStore.s"	; C: cc900/hdae5000_hd_tables.c

; ---------------------------------------------------------------------------
; Is a directory unused?  Compares its 16-byte name in HDAE5000_RAM_DirNames
; with the 16-space blank string (HDAE5000_StrNCmp).
; In:  WA = directory
; Out: HL = 0xFFFF when the name is blank (unused), 0 otherwise.
; ---------------------------------------------------------------------------
HDAE5000_Dir_IsBlankName:
	push xiz		; save XIZ
	ld iz, wa		; IZ = tile index
	ld	qiz, 0
	pushw HDAE5000_Dir_IsBlankName_Str_Blank16@hi16		; push max length (47)
	pushw	HDAE5000_Dir_IsBlankName_Str_Blank16@lo16		; low half of HDAE5000_Dir_IsBlankName_Str_Blank16
	call HDAE5000_StrLen
	pushw hl		; push reference length
	pushw	HDAE5000_Dir_IsBlankName_Str_Blank16@hi16
	pushw	HDAE5000_Dir_IsBlankName_Str_Blank16@lo16		; low half of HDAE5000_Dir_IsBlankName_Str_Blank16
	ld wa, iz		; restore tile index
	extz xwa		; zero-extend
	sll xwa, 4		; XWA *= 16
	ld xbc, HDAE5000_RAM_DirNames	; table base address
	add xbc, xwa		; XBC = base + index*16
	push xbc		; push tile address
	call HDAE5000_StrNCmp
	add xsp, 0x0000000E	; clean up 14 bytes
	cp hl, 0:i3		; check compare result
	jr nz, .Lgdd_done	; skip if mismatch
	ldw	qiz, 0xffff
.Lgdd_done:
	ld	hl, qiz
	pop xiz			; restore XIZ
	ret

; ---------------------------------------------------------------------------
; Number of the 16 songs of a directory that hold no part at all
; (HDAE5000_Song_IsUsed = 0xFFFF).
; In:  WA = directory
; Out: HL = that count.
; ---------------------------------------------------------------------------
HDAE5000_Dir_CountEmptySongs:
	dec 2, xsp		; allocate 2 bytes
	push xiz		; save XIZ
	ld (xsp + 4), wa	; save WA param on stack
	ld iz, 0:i3		; IZ = 0 (invalid counter)
	ld	qiz, 0
	cpw	qiz, 0x0010
	jr nc, .Lcic_done	; if >= 16, done
.Lcic_loop:
	ld wa, (xsp + 4)	; restore WA param
	ld	bc, qiz
	calr HDAE5000_Song_IsUsed
	cp hl, 0xFFFF		; check if invalid (-1)
	jr nz, .Lcic_skip	; skip if valid
	inc 1, iz		; count invalid
.Lcic_skip:
	inc	1, qiz
	cpw	qiz, 0x0010
	jr c, .Lcic_loop	; if < 16, continue loop
.Lcic_done:
	ld hl, iz		; HL = invalid count
	pop xiz			; restore XIZ
	inc 2, xsp		; deallocate 2 bytes
	ret

; ---------------------------------------------------------------------------
; Address of a song's 76-byte record:
; HDAE5000_RAM_SongRecords + dir * 0x4C0 + song * 0x4C.
; In:  WA = directory, BC = song
; Out: XHL = the record.
; ---------------------------------------------------------------------------
HDAE5000_SongRecord_Address:	.include "includes/generated/cc900/HDAE5000_SongRecord_Address.s"	; C: cc900/hdae5000_record_addr.c

HDAE5000_SongName_SetAndStore:	.include "includes/generated/cc900/HDAE5000_SongName_SetAndStore.s"	; C: cc900/hdae5000_hd_tables.c

; ---------------------------------------------------------------------------
; Address of an FLS record: HDAE5000_RAM_FlsRecords + fls * 144 (computed as
; DirNames + 0x24180 + ((fls << 3) + fls) << 4).
; In:  WA = FLS
; Out: XHL = the record.
; ---------------------------------------------------------------------------
HDAE5000_FlsRecord_Address:	.include "includes/generated/cc900/HDAE5000_FlsRecord_Address.s"	; C: cc900/hdae5000_record_addr.c

; ---------------------------------------------------------------------------
; Set an FLS record's 16-byte name and write the tables
; (HDAE5000_HD_StoreTables(DE)).
; In:  WA = FLS, XBC = name, DE = 1 to leave the drive spinning
; ---------------------------------------------------------------------------
HDAE5000_FlsName_SetAndStore:	.include "includes/generated/cc900/HDAE5000_FlsName_SetAndStore.s"	; C: cc900/hdae5000_hd_tables.c

; ---------------------------------------------------------------------------
; Is an FLS unused?  Compares its 16-byte name with the 16-space blank string.
; In:  WA = FLS
; Out: HL = 0xFFFF when the name is blank (unused), 0 otherwise.
; ---------------------------------------------------------------------------
HDAE5000_Fls_IsBlankName:
	dec 2, xsp		; allocate 2 bytes for result
	pushw iz		; save IZ
	ld iz, wa		; IZ = tile index
	ldw (xsp + 2), 0x0000	; result = 0 (valid)
	pushw HDAE5000_Fls_IsBlankName_Str_Blank16@hi16		; push max length (47)
	pushw	HDAE5000_Fls_IsBlankName_Str_Blank16@lo16		; low half of HDAE5000_Fls_IsBlankName_Str_Blank16
	call HDAE5000_StrLen
	inc 4, xsp		; clean up 2 args
	pushw hl		; push reference length
	pushw HDAE5000_Fls_IsBlankName_Str_Blank16@hi16		; push max length
	pushw	HDAE5000_Fls_IsBlankName_Str_Blank16@lo16		; low half of HDAE5000_Fls_IsBlankName_Str_Blank16
	ld wa, iz		; restore tile index
	calr HDAE5000_FlsRecord_Address	; XHL = tile address
	push xhl		; push tile address (32-bit)
	call HDAE5000_StrNCmp
	add xsp, 0x0000000A	; clean up 10 bytes
	cp hl, 0:i3		; compare result
	jr nz, .Lvcc_done	; if not equal, valid (keep 0)
	ldw (xsp + 2), 0xFFFF	; mark invalid (-1)
.Lvcc_done:
	ld hl, (xsp + 2)	; load result
	popw iz			; restore IZ
	inc 2, xsp		; deallocate 2 bytes
	ret

; ---------------------------------------------------------------------------
; Song record of item BC of FLS record WA: SongRecords + (dir byte - 1) *
; 0x4C0 + (song byte - 1) * 0x4C, from the item's 1-based directory and song
; bytes; the 26-space blank name HDAE5000_FlsItem_SongRecord_Str_Blank26 when
; the item is empty (HDAE5000_FlsItem_IsSet).
; In:  WA = FLS record, BC = item
; Out: XHL = the record (its name comes first), or the blank name.
; ---------------------------------------------------------------------------
HDAE5000_FlsItem_SongRecord:
	dec 4, xsp		; allocate 4 bytes
	pushw iz		; save IZ
	ld iz, bc		; IZ = column
	ld (xsp + 4), wa	; save row on stack
	; First: validate the cell
	ld wa, (xsp + 4)	; WA = row
	ld bc, iz		; BC = column
	calr HDAE5000_FlsItem_IsSet
	cp hl, 0xFFFF		; invalid?
	jr z, .Lrca_fail	; if -1, use fallback address
	; song offset: the item's song+1 byte (FLS record +48+item, 0x2257E2 base)
	ld bc, iz		; BC = column
	extz xbc		; zero-extend column
	ld wa, (xsp + 4)	; WA = row
	extz xwa		; zero-extend row
	ld xde, xwa		; XDE = row
	sll xde, 3		; XDE = row * 8
	add xde, xwa		; XDE = row * 9
	sll xde, 4		; XDE = row * 144
	add xde, xbc		; XDE = row*144 + col
	lda xwa, (HDAE5000_RAM_FlsRecords+48:24); song+1 bytes of the FLS items
	add xwa, xde		; XWA = table + row*144 + col
	ld a, (xwa)		; A = dimension value
	dec 1, a		; A -= 1
	extz wa			; zero-extend A to WA
	muls wa, 0x004C		; WA = (dim-1) * 76
	ld (xsp + 2), wa	; save row_offset
	; directory offset: the item's dir+1 byte (FLS record +16+item, 0x2257C2 base)
	ld bc, iz		; BC = column
	extz xbc		; zero-extend
	ld wa, (xsp + 4)	; WA = row
	extz xwa		; zero-extend
	ld xde, xwa		; XDE = row
	sll xde, 3		; XDE = row * 8
	add xde, xwa		; XDE = row * 9
	sll xde, 4		; XDE = row * 144
	add xde, xbc		; XDE = row*144 + col
	lda xwa, (HDAE5000_RAM_FlsRecords+16:24); dir+1 bytes of the FLS items
	add xwa, xde		; XWA = table + index
	ld a, (xwa)		; A = directory + 1
	dec 1, a		; A -= 1
	ld w, 0x00:opc		; W = 0 (zero-extend A to WA manually)
	extz xwa		; zero-extend WA to XWA
	ld xbc, 0x000004C0	; multiplier = 1216
	call HDAE5000_Multiply	; XHL = col_dim * 1216
	add xhl, 0x780		; XHL += 1920
	ld wa, (xsp + 2)	; WA = row_offset
	exts xwa		; sign-extend WA to XWA
	add xwa, xhl		; XWA = total offset
	ld xhl, HDAE5000_RAM_DirNames	; table base address
	add xhl, xwa		; XHL = final entry address
	jr t, .Lrca_done	; jump to epilogue
.Lrca_fail:
	lda xhl, (HDAE5000_FlsItem_SongRecord_Str_Blank26:24); lda XHL, (0x2F82FA) - fallback/error address
.Lrca_done:
	popw iz			; restore IZ
	inc 4, xsp		; deallocate 4 bytes
	ret

; ============================================================================
; Display Table Management and UI Cell Rendering (0x28FBB1-0x295008)
; ^ PROVEN WRONG TITLE, kept for the record: this is the song/FLS record
;   layer and the song load/save/copy/delete code (see
;   scripts/renaming/rename_hdae5000_songio.sed and each header).
; 21,592 bytes, 50 routines
;
; Table operations use 0x4C (76) byte stride for row addressing
; and 0x90 (144) byte stride for tile addressing.
; Eight routines at 0x2934C8-0x293BB8 are exactly 222 bytes each,
; likely one per UI cell/widget type.
; ^ They are one per song PART: HDAE5000_DeleteSongPart_Lsw .. _Tlx, and
;   there are nine (0x2934C8-0x293C95), not eight.
; ============================================================================

HDAE5000_FlsItem_IsSet:	.include "includes/generated/cc900/HDAE5000_FlsItem_IsSet.s"	; C: cc900/hdae5000_flsitem.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsItem_IsSet_Done, HDAE5000_FlsItem_IsSet + 62

; ---------------------------------------------------------------------------
; Copy item BC of FLS record WA out as {u16 dir; u16 song; u8 AS; u8
; AL} (the stored 1-based directory and song bytes minus 1); nothing is
; stored when the item is empty (HDAE5000_FlsItem_IsSet).  FLS records hold
; 32 items as parallel byte arrays at +16 (dir + 1), +48 (song + 1), +80 (AS), +112 (AL).
; In:  WA = FLS, BC = item, XDE = destination
; ---------------------------------------------------------------------------
HDAE5000_FlsItem_Get:
	dec	6, xsp
	pushw iz
	ld (xsp + 0x02), xde
	ld	iz, bc
	ld (xsp + 0x06), wa
	ld	wa, (xsp+6)
	ld	bc, iz
	calr	HDAE5000_FlsItem_IsSet
	ld	wa, hl
	cp	wa, 0xffff
	jrl	z, HDAE5000_FlsItem_Get_Epilogue
	ld	bc, iz
	extz xbc
	ld	wa, (xsp+6)
	extz xwa
	ld	xde, xwa
	sll	xde, 0x03
	add	xde, xwa
	sll	xde, 0x04
	add	xde, xbc
	lda xwa, (HDAE5000_RAM_FlsRecords+16:24)
	add	xwa, xde
	ld	a, (xwa)
	dec	1, a
	ld	c, a
	extz bc
	ld xwa, (xsp + 0x02)
	ld (xwa), bc
	ld	bc, iz
	extz xbc
	ld	wa, (xsp+6)
	extz xwa
	ld	xde, xwa
	sll	xde, 0x03
	add	xde, xwa
	sll	xde, 0x04
	add	xde, xbc
	lda xwa, (HDAE5000_RAM_FlsRecords+48:24)
	add	xwa, xde
	ld	a, (xwa)
	dec	1, a
	ld	c, a
	extz bc
	ld xwa, (xsp + 0x02)
	ld (xwa + 0x02), bc
	ld	bc, iz
	extz xbc
	ld	wa, (xsp+6)
	extz xwa
	ld	xde, xwa
	sll	xde, 0x03
	add	xde, xwa
	sll	xde, 0x04
	add	xde, xbc
	lda xwa, (HDAE5000_RAM_FlsRecords+80:24)
	ld	xbc, xwa
	add	xbc, xde
	ld xwa, (xsp + 0x02)
	ld	c, (xbc)
	ld	(xwa+4), c
	ld	bc, iz
	extz xbc
	ld	wa, (xsp+6)
	extz xwa
	ld	xde, xwa
	sll	xde, 0x03
	add	xde, xwa
	sll	xde, 0x04
	add	xde, xbc
	lda xwa, (HDAE5000_RAM_FlsRecords+112:24)
	ld	xbc, xwa
	add	xbc, xde
	ld xwa, (xsp + 0x02)
	ld	c, (xbc)
	ld	(xwa+5), c
HDAE5000_FlsItem_Get_Epilogue:
	popw iz
	inc	6, xsp
	ret

; ---------------------------------------------------------------------------
; Zero the four bytes of item BC of FLS record WA (+16, +48, +80, +112).
; In:  WA = FLS, BC = item
; Out: HL = 0
; ---------------------------------------------------------------------------
HDAE5000_FlsItem_Clear:	.include "includes/generated/cc900/HDAE5000_FlsItem_Clear.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Remove item BC of FLS record WA: items BC+1..31 move down one, item 31 is
; zeroed.
; In:  WA = FLS, BC = item
; Out: HL = 0
; ---------------------------------------------------------------------------
HDAE5000_FlsItem_Remove:
	ld	ix, bc
	inc	1, ix
	cp	ix, 0x0020
	jrl	nc, HDAE5000_FlsItem_Remove_Join
HDAE5000_FlsItem_Remove_Loop:
	ld	bc, ix
	dec	1, bc
	ld	de, bc
	extz xde
	ld	bc, wa
	extz xbc
	ld	xhl, xbc
	sll	xhl, 0x03
	add	xhl, xbc
	sll	xhl, 0x04
	add	xhl, xde
	lda xiy, (HDAE5000_RAM_FlsRecords+16:24)
	add	xiy, xhl
	ld	de, ix
	extz xde
	ld	bc, wa
	extz xbc
	ld	xhl, xbc
	sll	xhl, 0x03
	add	xhl, xbc
	sll	xhl, 0x04
	add	xhl, xde
	lda xbc, (HDAE5000_RAM_FlsRecords+16:24)
	add	xbc, xhl
	ld	c, (xbc)
	ld	(xiy), c
	ld	bc, ix
	dec	1, bc
	ld	de, bc
	extz xde
	ld	bc, wa
	extz xbc
	ld	xhl, xbc
	sll	xhl, 0x03
	add	xhl, xbc
	sll	xhl, 0x04
	add	xhl, xde
	lda xiy, (HDAE5000_RAM_FlsRecords+48:24)
	add	xiy, xhl
	ld	de, ix
	extz xde
	ld	bc, wa
	extz xbc
	ld	xhl, xbc
	sll	xhl, 0x03
	add	xhl, xbc
	sll	xhl, 0x04
	add	xhl, xde
	lda xbc, (HDAE5000_RAM_FlsRecords+48:24)
	add	xbc, xhl
	ld	c, (xbc)
	ld	(xiy), c
	ld	bc, ix
	dec	1, bc
	ld	de, bc
	extz xde
	ld	bc, wa
	extz xbc
	ld	xhl, xbc
	sll	xhl, 0x03
	add	xhl, xbc
	sll	xhl, 0x04
	add	xhl, xde
	lda xiy, (HDAE5000_RAM_FlsRecords+80:24)
	add	xiy, xhl
	ld	de, ix
	extz xde
	ld	bc, wa
	extz xbc
	ld	xhl, xbc
	sll	xhl, 0x03
	add	xhl, xbc
	sll	xhl, 0x04
	add	xhl, xde
	lda xbc, (HDAE5000_RAM_FlsRecords+80:24)
	add	xbc, xhl
	ld	c, (xbc)
	ld	(xiy), c
	ld	bc, ix
	dec	1, bc
	ld	de, bc
	extz xde
	ld	bc, wa
	extz xbc
	ld	xhl, xbc
	sll	xhl, 0x03
	add	xhl, xbc
	sll	xhl, 0x04
	add	xhl, xde
	lda xiy, (HDAE5000_RAM_FlsRecords+112:24)
	add	xiy, xhl
	ld	de, ix
	extz xde
	ld	bc, wa
	extz xbc
	ld	xhl, xbc
	sll	xhl, 0x03
	add	xhl, xbc
	sll	xhl, 0x04
	add	xhl, xde
	lda xbc, (HDAE5000_RAM_FlsRecords+112:24)
	add	xbc, xhl
	ld	c, (xbc)
	ld	(xiy), c
	inc	1, ix
	cp	ix, 0x0020
	jrl	c, HDAE5000_FlsItem_Remove_Loop
HDAE5000_FlsItem_Remove_Join:
	ld	bc, wa
	extz xbc
	ld	xde, xbc
	sll	xde, 0x03
	add	xde, xbc
	sll	xde, 0x04
	add	xde, 0x00024180
	lda xbc, (HDAE5000_RAM_FlsRecords-0x24180+47:24)
	add	xbc, xde
	ld	(xbc), 0x00
	ld	bc, wa
	extz xbc
	ld	xde, xbc
	sll	xde, 0x03
	add	xde, xbc
	sll	xde, 0x04
	add	xde, 0x00024180
	lda xbc, (HDAE5000_RAM_FlsRecords-0x24180+79:24)
	add	xbc, xde
	ld	(xbc), 0x00
	ld	bc, wa
	extz xbc
	ld	xde, xbc
	sll	xde, 0x03
	add	xde, xbc
	sll	xde, 0x04
	add	xde, 0x00024180
	lda xbc, (HDAE5000_RAM_FlsRecords-0x24180+111:24)
	add	xbc, xde
	ld	(xbc), 0x00
	extz xwa
	ld	xbc, xwa
	sll	xbc, 0x03
	add	xbc, xwa
	sll	xbc, 0x04
	add	xbc, 0x00024180
	lda xwa, (HDAE5000_RAM_FlsRecords-0x24180+143:24)
	add	xwa, xbc
	ld	(xwa), 0x00
	ld	hl, 0:i3
	ret

; ---------------------------------------------------------------------------
; Open a gap at item BC of FLS record WA: items BC..30 move up one (item 31 is
; lost) and item BC is zeroed.
; In:  WA = FLS, BC = item
; Out: HL = 0
; ---------------------------------------------------------------------------
HDAE5000_FlsItem_Insert:
	push xiz
	ldw	iy, 0x001f
	cp	iy, bc
	jrl	ule, HDAE5000_FlsItem_Insert_Join
HDAE5000_FlsItem_Insert_Loop:
	ld	hl, iy
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xiz, (HDAE5000_RAM_FlsRecords+16:24)
	add	xiz, xix
	ld	de, iy
	dec	1, de
	ld	hl, de
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+16:24)
	add	xde, xix
	ld	e, (xde)
	ld	(xiz), e
	ld	hl, iy
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xiz, (HDAE5000_RAM_FlsRecords+48:24)
	add	xiz, xix
	ld	de, iy
	dec	1, de
	ld	hl, de
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+48:24)
	add	xde, xix
	ld	e, (xde)
	ld	(xiz), e
	ld	hl, iy
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xiz, (HDAE5000_RAM_FlsRecords+80:24)
	add	xiz, xix
	ld	de, iy
	dec	1, de
	ld	hl, de
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+80:24)
	add	xde, xix
	ld	e, (xde)
	ld	(xiz), e
	ld	hl, iy
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xiz, (HDAE5000_RAM_FlsRecords+112:24)
	add	xiz, xix
	ld	de, iy
	dec	1, de
	ld	hl, de
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+112:24)
	add	xde, xix
	ld	e, (xde)
	ld	(xiz), e
	dec	1, iy
	cp	iy, bc
	jrl	ugt, HDAE5000_FlsItem_Insert_Loop
HDAE5000_FlsItem_Insert_Join:
	ld	hl, bc
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+16:24)
	add	xde, xix
	ld	(xde), 0x00
	ld	hl, bc
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+48:24)
	add	xde, xix
	ld	(xde), 0x00
	ld	hl, bc
	extz xhl
	ld	de, wa
	extz xde
	ld	xix, xde
	sll	xix, 0x03
	add	xix, xde
	sll	xix, 0x04
	add	xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+80:24)
	add	xde, xix
	ld	(xde), 0x00
	extz xbc
	extz xwa
	ld	xde, xwa
	sll	xde, 0x03
	add	xde, xwa
	sll	xde, 0x04
	add	xde, xbc
	lda xwa, (HDAE5000_RAM_FlsRecords+112:24)
	add	xwa, xde
	ld	(xwa), 0x00
	ld	hl, 0:i3
	pop xiz
	ret

HDAE5000_FlsItem_Set:
	; item BC of FLS record WA = XDE {u16 dir; u16 song; u8 byte80; u8 byte112}
	; (stored as dir+1, song+1), then HDAE5000_HD_StoreTables(stacked word);
	; retd 2.  No reference to 0x29002E was found: the one LE32 hit of a
	; nearby address (0x290030, at 0x29E158) lies inside a UI object
	; descriptor record, so this looks unreachable.
	ld	hl, wa
	ld	ix, bc
	extz xix
	ld	wa, hl
	extz xwa
	ld	xiy, xwa
	sll	xiy, 0x03
	add	xiy, xwa
	sll	xiy, 0x04
	add	xiy, xix
	lda xwa, (HDAE5000_RAM_FlsRecords+16:24)
	ld	xix, xwa
	add	xix, xiy
	ld	wa, (xde)
	inc	1, a
	ld	(xix), a
	ld	ix, bc
	extz xix
	ld	wa, hl
	extz xwa
	ld	xiy, xwa
	sll	xiy, 0x03
	add	xiy, xwa
	sll	xiy, 0x04
	add	xiy, xix
	lda xwa, (HDAE5000_RAM_FlsRecords+48:24)
	ld	xix, xwa
	add	xix, xiy
	ld	wa, (xde+2)
	inc	1, a
	ld	(xix), a
	ld	ix, bc
	extz xix
	ld	wa, hl
	extz xwa
	ld	xiy, xwa
	sll	xiy, 0x03
	add	xiy, xwa
	sll	xiy, 0x04
	add	xiy, xix
	lda xwa, (HDAE5000_RAM_FlsRecords+80:24)
	ld	xix, xwa
	add	xix, xiy
	ld	a, (xde+4)
	ld	(xix), a
	extz xbc
	ld	wa, hl
	extz xwa
	ld	xhl, xwa
	sll	xhl, 0x03
	add	xhl, xwa
	sll	xhl, 0x04
	add	xhl, xbc
	lda xwa, (HDAE5000_RAM_FlsRecords+112:24)
	ld	xbc, xwa
	add	xbc, xhl
	ld	a, (xde+5)
	ld	(xbc), a
	ld	wa, (xsp+4)
	calr	HDAE5000_HD_StoreTables
	retd 0x0002

; ---------------------------------------------------------------------------
; Item BC of FLS record WA: its directory byte (+16) = E + 1.
; In:  WA = FLS, BC = item, E = directory
; Out: HL = 0
; ---------------------------------------------------------------------------
HDAE5000_FlsItem_SetDir:
	extz xbc
	extz xwa
	ld	xhl, xwa
	sll	xhl, 0x03
	add	xhl, xwa
	sll	xhl, 0x04
	add	xhl, xbc
	lda xwa, (HDAE5000_RAM_FlsRecords+16:24)
	ld	xbc, xwa
	add	xbc, xhl
	ld	a, e
	inc	1, a
	ld	(xbc), a
	ld	hl, 0:i3
	ret

; ---------------------------------------------------------------------------
; Item BC of FLS record WA: its song byte (+48) = E + 1.
; In:  WA = FLS, BC = item, E = song
; Out: HL = 0
; ---------------------------------------------------------------------------
HDAE5000_FlsItem_SetSong:
	extz xbc
	extz xwa
	ld	xhl, xwa
	sll	xhl, 0x03
	add	xhl, xwa
	sll	xhl, 0x04
	add	xhl, xbc
	lda xwa, (HDAE5000_RAM_FlsRecords+48:24)
	ld	xbc, xwa
	add	xbc, xhl
	ld	a, e
	inc	1, a
	ld	(xbc), a
	ld	hl, 0:i3
	ret

; ---------------------------------------------------------------------------
; Item BC of FLS record WA, when set: its AS (AUTO START) option byte at +80 =
; E (0/1).  HDAE5000_FlsLoadScreen starts the sequencer after loading an item
; whose AS byte is 1 (HamaFn_SwbtWr panel code 0x48 bit 5); the FLS lists
; mark it with "*" (owner's manual: "AUTO START (AS)").
; In:  WA = FLS, BC = item, E = value
; ---------------------------------------------------------------------------
HDAE5000_FlsItem_SetAutoStart:	.include "includes/generated/cc900/HDAE5000_FlsItem_SetAutoStart.s"	; C: cc900/hdae5000_flsitem_set.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsItem_SetAutoStart_Epilogue, HDAE5000_FlsItem_SetAutoStart + 62

; ---------------------------------------------------------------------------
; Item BC of FLS record WA, when set: its AL (AUTO LOAD) option byte at +112 =
; E (0/1).  Loading an item whose AL byte is 1 arms the chain
; (HDAE5000_RAM_FlsAutoLoadPending): when the sequencer stops, the next item
; is loaded (owner's manual: "AUTO LOAD (AL)").
; In:  WA = FLS, BC = item, E = value
; ---------------------------------------------------------------------------
HDAE5000_FlsItem_SetAutoLoad:	.include "includes/generated/cc900/HDAE5000_FlsItem_SetAutoLoad.s"	; C: cc900/hdae5000_flsitem_set.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsItem_SetAutoLoad_Epilogue, HDAE5000_FlsItem_SetAutoLoad + 62


; ---------------------------------------------------------------------------
; Does a song hold any part?  Tests the nine first-cluster slots (+36.. of the
; song record; 0xFFFFFFFF = part absent).
; In:  WA = directory, BC = song
; Out: HL = 0 when at least one part is present, 0xFFFF when none is.
; ---------------------------------------------------------------------------
HDAE5000_Song_IsUsed:	.include "includes/generated/cc900/HDAE5000_Song_IsUsed.s"	; C: cc900/hdae5000_song_check.c

; ---------------------------------------------------------------------------
; The mask of the parts a song holds: bit k for part k (LSW PMT SQT CMP TM MSP
; RCM MD TLX) whose first-cluster slot is not 0xFFFFFFFF.
; In:  WA = directory, BC = song
; Out: HL = the mask, or 0xFFFF when the song holds no part.
; ---------------------------------------------------------------------------
HDAE5000_Song_PartMask:	.include "includes/generated/cc900/HDAE5000_Song_PartMask.s"	; C: cc900/hdae5000_song_module.c
	; Part 2: Entry setup handler (0x2905E9)
	; Uses bitmask in WA, dispatches Cell_Render routines per bit
	; ^ corrected: WA = directory, BC = song, DE = part mask; bit k calls
	;   HDAE5000_LoadSong_<part k>, stopping at the first that returns
	;   0xFFFF.  Bracketed by the main-CPU callbacks (0x0E88 table +0xE8, +0xEC,
	;   +0xF0; with the stacked flag = 1 also 0x0E0A +0x538/+0x53C).  HL = the
	;   last loader's result.  Callers: HDAE5000_LoadSongWithUi and PC-link
	;   service 14 ("LoadSongFromHdToMemory").
	; IZ = entry ID, DE = param, BC = flags
HDAE5000_LoadSong:
	dec 4, xsp
	push xiz
	ld (xsp + 4), de		; save DE
	ld (xsp + 6), bc		; save BC (flags)
	ld iz, wa			; IZ = bitmask
	; Workspace handler init
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)             ; XWA = (XWA+0x0E88)
	ld_sril xhl, (xwa + HamaFn_PlayHalt)             ; XHL = (XWA+0x00E8)
	ld wa, 1:i3
	call (xhl)
	; Conditional extra handler (if BC == 1)
	cpw (xsp + 14), 0x0001
	jr nz, .Ltl2_skip_extra
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SleepMainTask)
	call (xhl)
.Ltl2_skip_extra:
	call HDAE5000_ATA_SoftReset_Status
	; Test bits 0-8, calling the part loaders (was "Cell_Render subroutines")
	ld wa, (xsp + 4)		; reload DE (bitmask param)
	; --- Bit 0 ---
	bit 0, wa
	jr z, .Ltl2_bit1
	ld wa, iz
	ld bc, (xsp + 6)
	calr HDAE5000_LoadSong_Lsw
	ld qiz, hl		; ld QIZ, HL (previous-bank store)
	; --- Bit 1 ---
.Ltl2_bit1:
	cpw qiz, 0xffff
	jr z, .Ltl2_bit2
	ld wa, (xsp + 4)
	bit 1, wa
	jr z, .Ltl2_bit2
	ld wa, iz
	ld bc, (xsp + 6)
	calr HDAE5000_LoadSong_Pmt
	ld qiz, hl
	; --- Bit 2 ---
.Ltl2_bit2:
	cpw qiz, 0xffff
	jr z, .Ltl2_bit3
	ld wa, (xsp + 4)
	bit 2, wa
	jr z, .Ltl2_bit3
	ld wa, iz
	ld bc, (xsp + 6)
	calr HDAE5000_LoadSong_Sqt
	ld qiz, hl
	; --- Bit 3 ---
.Ltl2_bit3:
	cpw qiz, 0xffff
	jr z, .Ltl2_bit4
	ld wa, (xsp + 4)
	bit 3, wa
	jr z, .Ltl2_bit4
	ld wa, iz
	ld bc, (xsp + 6)
	calr HDAE5000_LoadSong_Cmp
	ld qiz, hl
	; --- Bit 4 ---
.Ltl2_bit4:
	cpw qiz, 0xffff
	jr z, .Ltl2_bit5
	ld wa, (xsp + 4)
	bit 4, wa
	jr z, .Ltl2_bit5
	ld wa, iz
	ld bc, (xsp + 6)
	calr HDAE5000_LoadSong_Tm
	ld qiz, hl
	; --- Bit 5 ---
.Ltl2_bit5:
	cpw qiz, 0xffff
	jr z, .Ltl2_bit6
	ld wa, (xsp + 4)
	bit 5, wa
	jr z, .Ltl2_bit6
	ld wa, iz
	ld bc, (xsp + 6)
	calr HDAE5000_LoadSong_Msp
	ld qiz, hl
	; --- Bit 6 ---
.Ltl2_bit6:
	cpw qiz, 0xffff
	jr z, .Ltl2_bit7
	ld wa, (xsp + 4)
	bit 6, wa
	jr z, .Ltl2_bit7
	ld wa, iz
	ld bc, (xsp + 6)
	calr HDAE5000_LoadSong_Rcm
	ld qiz, hl
	; --- Bit 7 ---
.Ltl2_bit7:
	cpw qiz, 0xffff
	jr z, .Ltl2_bit8
	ld wa, (xsp + 4)
	bit 7, wa
	jr z, .Ltl2_bit8
	ld wa, iz
	ld bc, (xsp + 6)
	calr HDAE5000_LoadSong_Md
	ld qiz, hl
	; --- Bit 8 ---
.Ltl2_bit8:
	cpw qiz, 0xffff
	jr z, .Ltl2_final
	ld wa, (xsp + 4)
	bit 8, wa
	jr z, .Ltl2_final
	ld wa, iz
	ld bc, (xsp + 6)
	calr HDAE5000_LoadSong_Tlx
	ld qiz, hl
	; --- Final workspace cleanup ---
.Ltl2_final:
	cpw (xsp + 12), 0x0001	; check param
	call nz, (HDAE5000_ATA_Standby_Status:24)
	cpw (xsp + 14), 0x0001	; check BC == 1?
	jr nz, .Ltl2_skip_final
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_WakeUpMainTask)
	call (xhl)
.Ltl2_skip_final:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_PlayStandBy)
	call (xhl)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_EditSwRefresh)
	call (xhl)
	ld hl, qiz		; ld HL, QIZ (load from previous-bank)
	pop xiz
	inc 4, xsp
	retd 4

; ---------------------------------------------------------------------------
; Load part 0 (LSW) of a song: when its first-cluster slot (song record
; +36) is not 0xFFFFFFFF, read the chain with HDAE5000_HD_ReadFile and hand
; the data to the main CPU through its hooks.  Called by HDAE5000_LoadSong for
; mask bit 0.
; In:  WA = directory, BC = song
; Out: HL = 0 when the song has no such part, else HD_ReadFile's result.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_PreLswLoad, HamaFn_PostLswLoad
; Calls: HDAE5000_RoundUpToSector, HDAE5000_HD_ReadFile, HDAE5000_MemCopy,
;      HDAE5000_SeparateOutput_Apply
; ---------------------------------------------------------------------------
HDAE5000_LoadSong_Lsw:	.include "includes/generated/cc900/HDAE5000_LoadSong_Lsw.s"	; C: cc900/hdae5000_song_module.c

; ---------------------------------------------------------------------------
; Load part 1 (PMT) of a song: when its first-cluster slot (song record
; +40) is not 0xFFFFFFFF, read the chain with HDAE5000_HD_ReadFile and hand
; the data to the main CPU through its hooks.  Called by HDAE5000_LoadSong for
; mask bit 1.
; In:  WA = directory, BC = song
; Out: HL = 0 when the song has no such part, else HD_ReadFile's result.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_PrePmLoad, HamaFn_PostPmLoad
; Calls: HDAE5000_HD_ReadFile, HDAE5000_MemCopy
; ---------------------------------------------------------------------------
HDAE5000_LoadSong_Pmt:	.include "includes/generated/cc900/HDAE5000_LoadSong_Pmt.s"	; C: cc900/hdae5000_song_io_ui_display.c

; ---------------------------------------------------------------------------
; Load part 2 (SQT) of a song: when its first-cluster slot (song record
; +44) is not 0xFFFFFFFF, read the chain with HDAE5000_HD_ReadFile and hand
; the data to the main CPU through its hooks.  Called by HDAE5000_LoadSong for
; mask bit 2.
; In:  WA = directory, BC = song
; Out: HL = 0 when the song has no such part, else HD_ReadFile's result.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_SeqLoadPre, HamaFn_SeqLoadPost,
;      indirect (xhl)
; Calls: HDAE5000_HD_ReadFile
; ---------------------------------------------------------------------------
HDAE5000_LoadSong_Sqt:
	lda xsp, (xsp - 28)
	push xiz
	ld (xsp + 28), bc	; save file number
	ld (xsp + 30), wa	; save directory
	ldw (xsp + 10), 0x0000	; init result = 0
	; First multiply: compute table offset
	ld wa, (xsp + 28)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 30)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	; Check if entry exists
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+44:24)	; table base
	add xwa, xhl
	ld xwa, (xwa)
	cp xwa, 0xFFFFFFFF
	jrl z, .Lts0a0_load	; entry doesn't exist
	; Workspace dispatch WA=3 (buffer at xsp+20)
	lda xwa, (xsp + 20)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_GetResouceInfo)
	ld wa, 3:i3
	call (xhl)
	; Workspace dispatch WA=4 (buffer at xsp+12)
	lda xwa, (xsp + 12)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_GetResouceInfo)
	ld wa, 4:i3
	call (xhl)
	; Save workspace ptr
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 8), xwa
	; Second multiply: compute table offset
	ld wa, (xsp + 28)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 30)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	; Table lookup via 0x29811C
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+44:24)
	add xwa, xhl
	ld xbc, xwa
	ld xwa, (xsp + 8)
	ld xde, xbc
	ld xbc, 0x00005000
	call HDAE5000_HD_ReadFile
	; Check result
	cp hl, 0xFFFF
	jr nz, .Lts0a0_process
	ldw hl, 0xFFFF
	jrl .Lts0a0_exit	; skip result load
.Lts0a0_process:
	; Compute slot address from workspace data
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	e, (xwa+199)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, xwa
	ld a, e
	extz wa
	sla wa, 10
	exts xwa
	add xwa, xwa
	add xbc, xwa
	lda xwa, (xbc + 78)	; XBC + 0x4E
	ld xbc, xwa
	ld wa, (xbc)
	extz xwa
	ld (xsp + 4), xwa
	sll xwa, 4
	ld (xsp + 4), xwa
	ld xwa, (xsp + 24)
	add (xsp + 4), xwa	; add workspace value to slot
	; Workspace dispatch (d8 0x2C)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_SeqLoadPre)	; (XWA+0x2C)
	call (xhl)
	; Save ptr
	lda xwa, (xsp + 20)
	ld (xsp + 8), xwa
	; Third multiply: compute table offset
	ld wa, (xsp + 28)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 30)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	; Table update via 0x29811C
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+44:24)
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 8)
	ld xwa, (xwa)
	ld xbc, (xsp + 4)
	call HDAE5000_HD_ReadFile
	ld (xsp + 10), hl	; save result
	; Final workspace dispatch at (XBC+0x30)
	ld wa, (xsp + 10)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld xhl, (xbc + HamaFn_SeqLoadPost)	; (XBC+0x30)
	call (xhl)
	; Extra function call via workspace chain
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + 0x11fa)
	ld xhl, (xwa + 24)	; (XWA+0x18)
	ld xwa, 0xFFFFFFFF
	ld xbc, EVT_ACTIVATE_STATE
	ld xde, 0:i3
	call (xhl)
.Lts0a0_load:
	ld hl, (xsp + 10)
.Lts0a0_exit:
	pop xiz
	lda xsp, (xsp + 28)
	ret

; ---------------------------------------------------------------------------
; Load part 3 (CMP) of a song: when its first-cluster slot (song record
; +48) is not 0xFFFFFFFF, read the chain with HDAE5000_HD_ReadFile and hand
; the data to the main CPU through its hooks.  Called by HDAE5000_LoadSong for
; mask bit 3.
; In:  WA = directory, BC = song
; Out: HL = 0 when the song has no such part, else HD_ReadFile's result.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_cmp_ld_mae, HamaFn_cmp_ld_ato
; Calls: HDAE5000_HD_ReadFile
; ---------------------------------------------------------------------------
HDAE5000_LoadSong_Cmp:
	lda xsp, (xsp - 20)
	push xiz
	ld (xsp + 20), bc	; save file number
	ld (xsp + 22), wa	; save directory
	ldw (xsp + 10), 0x0000	; init result = 0
	; 1st multiply: check entry existence
	ld wa, (xsp + 20)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 22)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+48:24)	; table base
	add xwa, xhl
	ld xwa, (xwa)
	cp xwa, 0xFFFFFFFF
	jrl z, .Lts90b_load
	; Workspace dispatch with WA=5
	lda xwa, (xsp + 12)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); workspace ptr
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_GetResouceInfo)             ; (XWA+0x0080)
	ld wa, 5:i3
	call (xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 8), xwa
	; 2nd multiply: table lookup
	ld wa, (xsp + 20)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 22)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+48:24)
	add xwa, xhl
	ld xbc, xwa
	ld xwa, (xsp + 8)
	ld xde, xbc
	ld xbc, 0x00000200
	call HDAE5000_HD_ReadFile
	cp hl, 0xFFFF
	jr nz, .Lts90b_ok
	ldw hl, 0xFFFF
	jr .Lts90b_exit
.Lts90b_ok:
	; Load workspace param and shift
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld wa, (xwa + 46)	; workspace offset 0x2E
	extz xwa
	ld (xsp + 4), xwa
	sll xwa, 4
	ld (xsp + 4), xwa
	; Dispatch workspace handler
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_cmp_ld_mae)	; handler at offset 0x3C
	call (xhl)
	; 3rd multiply: final table lookup
	lda xwa, (xsp + 12)
	ld (xsp + 8), xwa
	ld wa, (xsp + 20)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 22)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+48:24)
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 8)
	ld xwa, (xwa)
	ld xbc, (xsp + 4)
	call HDAE5000_HD_ReadFile
	ld (xsp + 10), hl
	; Post-processing dispatch
	ld wa, (xsp + 10)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld xhl, (xbc + HamaFn_cmp_ld_ato)	; post offset 0x40
	call (xhl)
.Lts90b_load:
	ld hl, (xsp + 10)	; load result
.Lts90b_exit:
	pop xiz
	lda xsp, (xsp + 20)
	ret

; ---------------------------------------------------------------------------
; Load part 4 (TM) of a song: when its first-cluster slot (song record
; +52) is not 0xFFFFFFFF, read the chain with HDAE5000_HD_ReadFile and hand
; the data to the main CPU through its hooks.  Called by HDAE5000_LoadSong for
; mask bit 4.
; In:  WA = directory, BC = song
; Out: HL = 0 when the song has no such part, else HD_ReadFile's result.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_PreTmLoad, HamaFn_PostTmLoad
; Calls: HDAE5000_HD_ReadFile
; ---------------------------------------------------------------------------
HDAE5000_LoadSong_Tm:	.include "includes/generated/cc900/HDAE5000_LoadSong_Tm.s"	; C: cc900/hdae5000_song_io_ui_display.c

; ---------------------------------------------------------------------------
; Load part 5 (MSP) of a song: when its first-cluster slot (song record
; +56) is not 0xFFFFFFFF, read the chain with HDAE5000_HD_ReadFile and hand
; the data to the main CPU through its hooks.  Called by HDAE5000_LoadSong for
; mask bit 5.
; In:  WA = directory, BC = song
; Out: HL = 0 when the song has no such part, else HD_ReadFile's result.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_msp_ld_mae, HamaFn_msp_ld_ato
; Calls: HDAE5000_HD_ReadFile
; ---------------------------------------------------------------------------
HDAE5000_LoadSong_Msp:
	lda xsp, (xsp - 20)
	push xiz
	ld (xsp + 20), bc
	ld (xsp + 22), wa
	ldw (xsp + 10), 0x0000
	ld wa, (xsp + 20)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 22)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+56:24)	; table base
	add xwa, xhl
	ld xwa, (xwa)
	cp xwa, 0xFFFFFFFF
	jrl z, .Lts90d_load
	lda xwa, (xsp + 12)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_GetResouceInfo)
	ld wa, 7:i3
	call (xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 8), xwa
	ld wa, (xsp + 20)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 22)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+56:24)
	add xwa, xhl
	ld xbc, xwa
	ld xwa, (xsp + 8)
	ld xde, xbc
	ld xbc, 0x00000200
	call HDAE5000_HD_ReadFile
	cp hl, 0xFFFF
	jr nz, .Lts90d_ok
	ldw hl, 0xFFFF
	jr .Lts90d_exit
.Lts90d_ok:
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld wa, (xwa + 28)	; workspace offset 0x1C
	extz xwa
	ld (xsp + 4), xwa
	sll xwa, 4
	ld (xsp + 4), xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_msp_ld_mae)	; handler at offset 0x5C
	call (xhl)
	lda xwa, (xsp + 12)
	ld (xsp + 8), xwa
	ld wa, (xsp + 20)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 22)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+56:24)
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 8)
	ld xwa, (xwa)
	ld xbc, (xsp + 4)
	call HDAE5000_HD_ReadFile
	ld (xsp + 10), hl
	ld wa, (xsp + 10)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld xhl, (xbc + HamaFn_msp_ld_ato)	; post offset 0x60
	call (xhl)
.Lts90d_load:
	ld hl, (xsp + 10)
.Lts90d_exit:
	pop xiz
	lda xsp, (xsp + 20)
	ret

; ---------------------------------------------------------------------------
; Load part 6 (RCM) of a song by letting the main CPU pull it: when slot +60
; of the song record is not 0xFFFFFFFF, reset the RCM stream state (8 zero
; bytes from HDAE5000_RcmStream_InitialState at RcmStreamState), note the
; song in HDAE5000_RAM_RcmStreamDir / _RcmStreamSong and call
; HamaFn_rcm_ld_XAPR_j with the read callback HDAE5000_RcmStream_Read and
; HDAE5000_RcmStream_LastResult.  Called by HDAE5000_LoadSong for mask bit 6.
; In:  WA = directory, BC = song
; Out: HL = 0.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_LoadSong_Rcm:	.include "includes/generated/cc900/HDAE5000_LoadSong_Rcm.s"	; C: cc900/hdae5000_song_module.c

; ---------------------------------------------------------------------------
; Load part 7 (MD) of a song: when its first-cluster slot (song record
; +64) is not 0xFFFFFFFF, read the chain with HDAE5000_HD_ReadFile and hand
; the data to the main CPU through its hooks.  Called by HDAE5000_LoadSong for
; mask bit 7.
; In:  WA = directory, BC = song
; Out: HL = 0 when the song has no such part, else HD_ReadFile's result.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_PreMidiLoad, HamaFn_FlashWrite,
;      HamaFn_PostMidiLoad
; Calls: HDAE5000_HD_ReadFile
; ---------------------------------------------------------------------------
HDAE5000_LoadSong_Md:	.include "includes/generated/cc900/HDAE5000_LoadSong_Md.s"	; C: cc900/hdae5000_song_io_ui_display.c

; ---------------------------------------------------------------------------
; Load part 8 (TLX, the lyrics) of a song into HDAE5000_RAM_LyricBuffer: when
; slot +68 of the song record is not 0xFFFFFFFF, clear the buffer
; (HDAE5000_Lyrics_ClearBuffer), read the first 22 bytes (the chunk headers)
; with HDAE5000_HD_ReadFile, then the whole file, its length now known from
; HDAE5000_TlxPart_Describe.  Called by HDAE5000_LoadSong for mask bit 8.
; In:  WA = directory, BC = song
; Out: HL = 0 when the song has no TLX part, else HD_ReadFile's result.
;      IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_LoadSong_Tlx:
	lda	xsp, (xsp-24)
	pushw iz
	ld (xsp + 0x16), bc
	ld (xsp + 0x18), wa
	ld	iz, 0:i3
	ld	wa, (xsp+22)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld (xsp + 0x0a), xhl
	ld	wa, (xsp+24)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, (xsp+10)
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+68:24)
	add	xwa, xhl
	ld xwa, (xwa)
	cp	xwa, 0xffffffff
	jrl	z, HDAE5000_LoadSong_Tlx_Done
	call HDAE5000_Lyrics_ClearBuffer
	lda	xwa, (xsp+14)
	ld	xbc, xwa
	ldw	wa, 0x000a
	calr	HDAE5000_TlxPart_Describe
	lda	xwa, (xsp+14)
	ld (xsp + 0x06), xwa
	ld	wa, (xsp+22)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld (xsp + 0x0a), xhl
	ld	wa, (xsp+24)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, (xsp+10)
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+68:24)
	add	xwa, xhl
	ld	xbc, xwa
	ld xwa, (xsp + 0x06)
	ld xwa, (xwa)
	ld	xde, xbc
	ld	xbc, 0x00000016
	call HDAE5000_HD_ReadFile
	ld	iz, hl
	cp	iz, 0xffff
	jr	z, HDAE5000_LoadSong_Tlx_Done
	lda	xwa, (xsp+14)
	ld	xbc, xwa
	ldw	wa, 0x000a
	calr	HDAE5000_TlxPart_Describe
	lda	xwa, (xsp+14)
	ld (xsp + 0x02), xwa
	lda	xwa, (xsp+18)
	ld (xsp + 0x06), xwa
	ld	wa, (xsp+22)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld (xsp + 0x0a), xhl
	ld	wa, (xsp+24)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, (xsp+10)
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+68:24)
	add	xwa, xhl
	ld	xde, xwa
	ld xwa, (xsp + 0x02)
	ld xwa, (xwa)
	ld xbc, (xsp + 0x06)
	ld xbc, (xbc)
	call HDAE5000_HD_ReadFile
	ld	iz, hl
HDAE5000_LoadSong_Tlx_Done:
	ld	hl, iz
	popw iz
	lda	xsp, (xsp+24)
	ret

; ---------------------------------------------------------------------------
; Save a song.  Mask 0 returns HL = 0 at once; not enough free clusters
; (HDAE5000_Song_CheckFreeSpace) returns 0xFFFF.  Otherwise, between the
; main-CPU calls (HamaFn_PlayHalt; RootFn_SleepMainTask / WakeUpMainTask when
; asked; HamaFn_EditSwRefresh, _PlayStandBy), for k = 0..8: bit k set ->
; HDAE5000_SaveSong_<part k>, a part that fails is deleted again; bit k clear,
; or any part after a failure -> HDAE5000_DeleteSongPart_<part k>.  On success
; the 26-byte name is copied into the song record and the tables written
; (HDAE5000_HD_WriteTables_Status); after a failure every part of the song is
; deleted (HDAE5000_DeleteSongParts, mask 0x1FF).  Callers:
; HDAE5000_SaveSongWithUi and PC-link service 15 ("SaveSongInMemoryToHd").
; In:  WA = directory, BC = song, XDE = the song's name; stacked words (retd
;      pops them): +4 = 1 to leave the drive spinning, +6 = 1 to put the main
;      task to sleep, +8 = part mask
; Out: HL = 0, or 0xFFFF.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_SaveSong:
	lda	xsp, (xsp-10)
	push xiz
	ld (xsp + 0x06), xde
	ld (xsp + 0x0a), bc
	ld (xsp + 0x0c), wa
	ldw (xsp + 0x04), 0
	cpw	(xsp+22), 0x0000
	jr	nz, HDAE5000_SaveSong_Skip
	ld	hl, (xsp+4)
	jrl	t, HDAE5000_SaveSong_Epilogue
HDAE5000_SaveSong_Skip:
	ld	wa, (xsp+22)
	calr	HDAE5000_Song_CheckFreeSpace
	cp	hl, 0xffff
	jrl	z, HDAE5000_SaveSong_Skip12
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayHalt)
	ld	wa, 1:i3
	call	(xhl)
	cpw	(xsp+20), 0x0001
	jr	nz, HDAE5000_SaveSong_Join
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SleepMainTask)
	call	(xhl)
HDAE5000_SaveSong_Join:
	call HDAE5000_ATA_SoftReset_Status
	ld	wa, (xsp+22)
	bit	0x00, wa
	jr	z, HDAE5000_SaveSong_Skip2
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_SaveSong_Lsw
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_SaveSong_Join2
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Lsw
	jr	t, HDAE5000_SaveSong_Join2
HDAE5000_SaveSong_Skip2:
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Lsw
HDAE5000_SaveSong_Join2:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_SaveSong_Skip3
	ld	wa, (xsp+22)
	bit	0x01, wa
	jr	z, HDAE5000_SaveSong_Skip3
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_SaveSong_Pmt
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_SaveSong_Join3
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Pmt
	jr	t, HDAE5000_SaveSong_Join3
HDAE5000_SaveSong_Skip3:
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Pmt
HDAE5000_SaveSong_Join3:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_SaveSong_Skip4
	ld	wa, (xsp+22)
	bit	0x02, wa
	jr	z, HDAE5000_SaveSong_Skip4
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_SaveSong_Sqt
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_SaveSong_Join4
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Sqt
	jr	t, HDAE5000_SaveSong_Join4
HDAE5000_SaveSong_Skip4:
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Sqt
HDAE5000_SaveSong_Join4:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_SaveSong_Skip5
	ld	wa, (xsp+22)
	bit	0x03, wa
	jr	z, HDAE5000_SaveSong_Skip5
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_SaveSong_Cmp
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_SaveSong_Join5
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Cmp
	jr	t, HDAE5000_SaveSong_Join5
HDAE5000_SaveSong_Skip5:
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Cmp
HDAE5000_SaveSong_Join5:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_SaveSong_Skip6
	ld	wa, (xsp+22)
	bit	0x04, wa
	jr	z, HDAE5000_SaveSong_Skip6
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_SaveSong_Tm
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_SaveSong_Join6
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Tm
	jr	t, HDAE5000_SaveSong_Join6
HDAE5000_SaveSong_Skip6:
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Tm
HDAE5000_SaveSong_Join6:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_SaveSong_Skip7
	ld	wa, (xsp+22)
	bit	0x05, wa
	jr	z, HDAE5000_SaveSong_Skip7
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_SaveSong_Msp
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_SaveSong_Join7
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Msp
	jr	t, HDAE5000_SaveSong_Join7
HDAE5000_SaveSong_Skip7:
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Msp
HDAE5000_SaveSong_Join7:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_SaveSong_Skip8
	ld	wa, (xsp+22)
	bit	0x06, wa
	jr	z, HDAE5000_SaveSong_Skip8
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_SaveSong_Rcm
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_SaveSong_Join8
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Rcm
	jr	t, HDAE5000_SaveSong_Join8
HDAE5000_SaveSong_Skip8:
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Rcm
HDAE5000_SaveSong_Join8:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_SaveSong_Skip9
	ld	wa, (xsp+22)
	bit	0x07, wa
	jr	z, HDAE5000_SaveSong_Skip9
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_SaveSong_Md
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_SaveSong_Join9
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Md
	jr	t, HDAE5000_SaveSong_Join9
HDAE5000_SaveSong_Skip9:
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Md
HDAE5000_SaveSong_Join9:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_SaveSong_Skip10
	ld	wa, (xsp+22)
	bit	0x08, wa
	jr	z, HDAE5000_SaveSong_Skip10
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_SaveSong_Tlx
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_SaveSong_Join10
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Tlx
	jr	t, HDAE5000_SaveSong_Join10
HDAE5000_SaveSong_Skip10:
	ld	wa, (xsp+12)
	ld	bc, (xsp+10)
	calr	HDAE5000_DeleteSongPart_Tlx
HDAE5000_SaveSong_Join10:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_SaveSong_Skip11
	pushw 0x001a
	ld xwa, (xsp + 0x08)
	push xwa
	ld	wa, (xsp+16)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld	xiz, xhl
	ld	wa, (xsp+18)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, xiz
	ld	xwa, HDAE5000_RAM_DirNames
	add	xwa, xhl
	push xwa
	call HDAE5000_StrNCpy
	lda	xsp, (xsp+10)
	call HDAE5000_HD_WriteTables_Status
	jr	t, HDAE5000_SaveSong_Join11
HDAE5000_SaveSong_Skip11:
	pushw 0x0000
	pushm	(xsp+20)
	ld	wa, (xsp+16)
	ld	bc, (xsp+14)
	ldw	de, 0x01ff
	calr	HDAE5000_DeleteSongParts
HDAE5000_SaveSong_Join11:
	cpw	(xsp+18), 0x0001
	call	nz, (HDAE5000_ATA_Standby_Status:24)
	cpw	(xsp+20), 0x0001
	jr	nz, HDAE5000_SaveSong_Join12
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_WakeUpMainTask)
	call	(xhl)
HDAE5000_SaveSong_Join12:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_EditSwRefresh)
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayStandBy)
	call	(xhl)
	jr	t, HDAE5000_SaveSong_Done
HDAE5000_SaveSong_Skip12:
	ldw (xsp + 0x04), 65535
HDAE5000_SaveSong_Done:
	ld	hl, (xsp+4)
HDAE5000_SaveSong_Epilogue:
	pop xiz
	lda	xsp, (xsp+10)
	retd 0x0006


; ---------------------------------------------------------------------------
; Save part 0 (LSW) of a song from the main CPU's memory (through its hooks)
; to a new cluster chain whose first cluster goes to slot +36 of the song
; record; the record's part byte +26 is set.  Called by HDAE5000_SaveSong
; for mask bit 0.
; In:  WA = directory, BC = song
; Out: HL = 0, or 0xFFFF on a failure.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_PreLswSave, HamaFn_PostLswSave
; Calls: HDAE5000_RoundUpToSector, HDAE5000_MemFill, HDAE5000_MemCopy,
;      HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_SaveSong_Lsw:	.include "includes/generated/cc900/HDAE5000_SaveSong_Lsw.s"	; C: cc900/hdae5000_song_module.c

; ---------------------------------------------------------------------------
; Save part 1 (PMT) of a song from the main CPU's memory (through its hooks)
; to a new cluster chain whose first cluster goes to slot +40 of the song
; record; the record's part byte +27 is set.  Called by HDAE5000_SaveSong
; for mask bit 1.
; In:  WA = directory, BC = song
; Out: HL = 0, or 0xFFFF on a failure.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_PrePmSave, HamaFn_PostPmSave
; Calls: HDAE5000_RoundUpToSector, HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_SaveSong_Pmt:	.include "includes/generated/cc900/HDAE5000_SaveSong_Pmt.s"	; C: cc900/hdae5000_song_module.c

; ---------------------------------------------------------------------------
; Save part 2 (SQT) of a song from the main CPU's memory (through its hooks)
; to a new cluster chain whose first cluster goes to slot +44 of the song
; record; the record's part byte +28 is set.  Called by HDAE5000_SaveSong
; for mask bit 2.
; In:  WA = directory, BC = song
; Out: HL = 0, or 0xFFFF on a failure.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_SeqSavePre, HamaFn_SeqSavePost
; Calls: HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_SaveSong_Sqt:	.include "includes/generated/cc900/HDAE5000_SaveSong_Sqt.s"	; C: cc900/hdae5000_song_io_ui_display.c

; ---------------------------------------------------------------------------
; Save part 3 (CMP) of a song from the main CPU's memory (through its hooks)
; to a new cluster chain whose first cluster goes to slot +48 of the song
; record; the record's part byte +29 is set.  Called by HDAE5000_SaveSong
; for mask bit 3.
; In:  WA = directory, BC = song
; Out: HL = 0, or 0xFFFF on a failure.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_cmp_sv_mae, HamaFn_cmp_sv_ato
; Calls: HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_SaveSong_Cmp:	.include "includes/generated/cc900/HDAE5000_SaveSong_Cmp.s"	; C: cc900/hdae5000_song_io_ui_display.c

; ---------------------------------------------------------------------------
; Save part 4 (TM) of a song from the main CPU's memory (through its hooks)
; to a new cluster chain whose first cluster goes to slot +52 of the song
; record; the record's part byte +30 is set.  Called by HDAE5000_SaveSong
; for mask bit 4.
; In:  WA = directory, BC = song
; Out: HL = 0, or 0xFFFF on a failure.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_PreTmSave, HamaFn_PostTmSave
; Calls: HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_SaveSong_Tm:	.include "includes/generated/cc900/HDAE5000_SaveSong_Tm.s"	; C: cc900/hdae5000_song_io_ui_display.c

; ---------------------------------------------------------------------------
; Save part 5 (MSP) of a song from the main CPU's memory (through its hooks)
; to a new cluster chain whose first cluster goes to slot +56 of the song
; record; the record's part byte +31 is set.  Called by HDAE5000_SaveSong
; for mask bit 5.
; In:  WA = directory, BC = song
; Out: HL = 0, or 0xFFFF on a failure.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_msp_sv_mae, HamaFn_msp_sv_ato
; Calls: HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_SaveSong_Msp:	.include "includes/generated/cc900/HDAE5000_SaveSong_Msp.s"	; C: cc900/hdae5000_song_io_ui_display.c

; ---------------------------------------------------------------------------
; Save part 6 (RCM) of a song by letting the main CPU push it: reset the RCM
; stream state, note the song in HDAE5000_RAM_RcmStreamDir / _RcmStreamSong,
; open a buffered write on slot +60 of the song record (HDAE5000_HD_WriteOpen)
; and call HamaFn_rcm_sv_XAPR_j with HDAE5000_RcmStream_FreeSpace,
; HDAE5000_RcmStream_Write and HDAE5000_RcmStream_LastResult, then
; HDAE5000_HD_WriteClose.  Called by HDAE5000_SaveSong for mask bit 6.
; In:  WA = directory, BC = song
; Out: HL = 0xFFFF when the write could not be opened.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_SaveSong_Rcm:
	push xiz
	ld de, bc
	ld hl, 0:i3
	ld xiy, HDAE5000_RcmStream_InitialState
	ld xix, HDAE5000_RAM_RcmStreamState
	ld bc, 4:i3
	ldirw
	ld (HDAE5000_RAM_RcmStreamDir:24), wa
	ld (HDAE5000_RAM_RcmStreamSong:24), de
	ld wa, (HDAE5000_RAM_RcmStreamSong:24)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (HDAE5000_RAM_RcmStreamDir:24)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+60:24)
	add xwa, xhl
	calr HDAE5000_HD_WriteOpen
	ld wa, hl
	cp wa, 0xFFFF
	jr z, .Lts919_exit
	lda xwa, (HDAE5000_RcmStream_FreeSpace:24)
	ld xhl, xwa
	lda xwa, (HDAE5000_RcmStream_Write:24)
	ld xbc, xwa
	lda xwa, (HDAE5000_RcmStream_LastResult:24)
	ld xde, xwa
	ld xwa, xhl
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_HamaFnTable)
	ld_sril xix, (xhl + HamaFn_rcm_sv_XAPR_j)
	call (xix)
	calr HDAE5000_HD_WriteClose
.Lts919_exit:
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Save part 7 (MD) of a song from the main CPU's memory (through its hooks)
; to a new cluster chain whose first cluster goes to slot +64 of the song
; record; the record's part byte +33 is set.  Called by HDAE5000_SaveSong
; for mask bit 7.
; In:  WA = directory, BC = song
; Out: HL = 0, or 0xFFFF on a failure.
; Main CPU: HamaFn_GetResouceInfo, HamaFn_PreMidiSave, HamaFn_PostMidiSave
; Calls: HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_SaveSong_Md:	.include "includes/generated/cc900/HDAE5000_SaveSong_Md.s"	; C: cc900/hdae5000_song_io_ui_display.c

; ---------------------------------------------------------------------------
; Save part 8 (TLX) of a song: HDAE5000_RAM_LyricBuffer, its length
; (HDAE5000_TlxPart_Describe) rounded up to whole sectors
; (HDAE5000_RoundUpToSector), written with HDAE5000_HD_WriteFile to slot +68
; of the song record; on success the part byte +34 is set.  Called by
; HDAE5000_SaveSong for mask bit 8.
; In:  WA = directory, BC = song
; Out: HL = HD_WriteFile's result (0 / 0xFFFF).  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_SaveSong_Tlx:	.include "includes/generated/cc900/HDAE5000_SaveSong_Tlx.s"	; C: cc900/hdae5000_song_module.c

; ---------------------------------------------------------------------------
; The TLX part's extent for the part loaders / savers and PC-link service 13:
; {long HDAE5000_RAM_LyricBuffer; long length}, the length being the TLtr
; length (big-endian at LyricBuffer+18, HDAE5000_SwapBytes32) + 22, also
; stored to HDAE5000_RAM_LyricFileLength.
; In:  WA = passed through, XBC = the 8-byte record to fill
; Out: HL = WA.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_TlxPart_Describe:	.include "includes/generated/cc900/HDAE5000_TlxPart_Describe.s"	; C: cc900/hdae5000_song_module.c

; ---------------------------------------------------------------------------
; Does file data carry a part's signature?  HDAE5000_PartSignatureTable has
; 8-byte records {long string; u16 offset; u16 length} indexed by part: "HK"
; at +4 (LSW), "HK" (PMT), 01 08 at +5 (SQT), "H\0K" (CMP), "KN5000 SOUND RAM"
; (TM), "H\0K" (MSP, RCM), "HK" (MD), "TLhd" (TLX); compared with
; HDAE5000_StrNCmp.  Caller: HDAE5000_FdSong_CheckFiles.
; In:  WA = part, XBC = the file's first bytes
; Out: HL = 0 when it matches, else 0xFFFF.
; ---------------------------------------------------------------------------
HDAE5000_CheckFileSignature:
	ld	de, wa
	extz xde
	sll	xde, 0x03
	lda xhl, (HDAE5000_PartSignatureTable_Length:24)
	add	xhl, xde
	ld	de, (xhl)
	pushw de
	ld	de, wa
	extz xde
	sll	xde, 0x03
	lda xhl, (HDAE5000_PartSignatureTable_FileOffset:24)
	add	xhl, xde
	ld	de, (xhl)
	extz xde
	add	xde, xbc
	push xde
	extz xwa
	sll	xwa, 0x03
	ld	xbc, HDAE5000_PartSignatureTable
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	call HDAE5000_StrNCmp
	add	xsp, 0x0000000a
	cp	hl, 0:i3
	jr	nz, HDAE5000_CheckFileSignature_Done
	ld	hl, 0:i3
	jr	t, HDAE5000_CheckFileSignature_Return
HDAE5000_CheckFileSignature_Done:
	ldw	hl, 0xffff
HDAE5000_CheckFileSignature_Return:
	ret

; ---------------------------------------------------------------------------
; Check a song on floppy before copying it.  Fails (HL = 0xFFFF) when a
; "<name>.SEQ" or the other name it tries is found (HamaFn__findfirst, closed
; with _findclose), or when, for any part k in the mask, the first 512 bytes
; of "<name><extension k>" (HamaFn_fopen_ext "rb", _fread_ext,
; _fclose_ext into HDAE5000_RAM_HdStreamBuffer) fail
; HDAE5000_CheckFileSignature(k).
; In:  XWA = the song's 8-character name, BC = part mask
; Out: HL = 0 when the copy may go ahead, else 0xFFFF.
; ---------------------------------------------------------------------------
HDAE5000_FdSong_CheckFiles:
	lda xsp, (xsp-282)
	push xiz
	ld	(xsp+284), bc
	ld	xiz, xwa
	pushw 0x000d
	pushw 0x0000
	lda	xwa, (xsp+8)
	push xwa
	call HDAE5000_MemFill
	pushw 0x0008
	ld	xwa, xiz
	push xwa
	lda	xwa, (xsp+18)
	push xwa
	call HDAE5000_MemCopy
	pushw	HDAE5000_FdSong_CheckFiles_Str_SEQ@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_SEQ@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_SEQ
	lda	xwa, (xsp+34)
	push xwa
	call HDAE5000_StrCpy
	lda	xsp, (xsp+26)
	lda	xwa, (xsp+18)
	ld	xbc, xwa
	lda	xwa, (xsp+4)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xix, (xde + HamaFn__findfirst)
	call	(xix)
	ld	xwa, xhl
	cp	xwa, 0xffffffff
	jr	z, HDAE5000_FdSong_CheckFiles_Skip
	ld	xwa, xhl
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn__findclose)
	call	(xhl)
	ldw	hl, 0xffff
	jrl	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip:
	pushw HDAE5000_FdSong_CheckFiles_Str_SQF@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_SQF@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_SQF
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+18)
	ld	xbc, xwa
	lda	xwa, (xsp+4)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xix, (xde + HamaFn__findfirst)
	call	(xix)
	ld	xwa, xhl
	cp	xwa, 0xffffffff
	jr	z, HDAE5000_FdSong_CheckFiles_Skip2
	ld	xwa, xhl
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn__findclose)
	call	(xhl)
	ldw	hl, 0xffff
	jrl	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip2:
	ld	wa, (xsp+284)
	bit	0x00, wa
	jr	z, HDAE5000_FdSong_CheckFiles_Skip3
	pushw HDAE5000_FdSong_CheckFiles_Str_LSW@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_LSW@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_LSW
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+4)
	lda xbc, (HDAE5000_FdSong_CheckFiles_Str_rb:24)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xhl, (xde + HamaFn_fopen_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn_fread_ext)
	ld	xbc, 0x00000200
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_fclose_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, xwa
	ld	wa, 0:i3
	calr	HDAE5000_CheckFileSignature
	cp	hl, 0xffff
	jr	nz, HDAE5000_FdSong_CheckFiles_Skip3
	ldw	hl, 0xffff
	jrl	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip3:
	ld	wa, (xsp+284)
	bit	0x01, wa
	jr	z, HDAE5000_FdSong_CheckFiles_Skip4
	pushw HDAE5000_FdSong_CheckFiles_Str_PMT@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_PMT@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_PMT
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+4)
	lda xbc, (HDAE5000_FdSong_CheckFiles_Str_rb_2:24)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xhl, (xde + HamaFn_fopen_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn_fread_ext)
	ld	xbc, 0x00000200
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_fclose_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, xwa
	ld	wa, 1:i3
	calr	HDAE5000_CheckFileSignature
	cp	hl, 0xffff
	jr	nz, HDAE5000_FdSong_CheckFiles_Skip4
	ldw	hl, 0xffff
	jrl	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip4:
	ld	wa, (xsp+284)
	bit	0x02, wa
	jr	z, HDAE5000_FdSong_CheckFiles_Skip5
	pushw HDAE5000_FdSong_CheckFiles_Str_SQT@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_SQT@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_SQT
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+4)
	lda xbc, (HDAE5000_FdSong_CheckFiles_Str_rb_3:24)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xhl, (xde + HamaFn_fopen_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn_fread_ext)
	ld	xbc, 0x00000200
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_fclose_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, xwa
	ld	wa, 2:i3
	calr	HDAE5000_CheckFileSignature
	cp	hl, 0xffff
	jr	nz, HDAE5000_FdSong_CheckFiles_Skip5
	ldw	hl, 0xffff
	jrl	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip5:
	ld	wa, (xsp+284)
	bit	0x03, wa
	jr	z, HDAE5000_FdSong_CheckFiles_Skip6
	pushw HDAE5000_FdSong_CheckFiles_Str_CMP@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_CMP@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_CMP
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+4)
	lda xbc, (HDAE5000_FdSong_CheckFiles_Str_rb_4:24)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xhl, (xde + HamaFn_fopen_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn_fread_ext)
	ld	xbc, 0x00000200
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_fclose_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, xwa
	ld	wa, 3:i3
	calr	HDAE5000_CheckFileSignature
	cp	hl, 0xffff
	jr	nz, HDAE5000_FdSong_CheckFiles_Skip6
	ldw	hl, 0xffff
	jrl	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip6:
	ld	wa, (xsp+284)
	bit	0x04, wa
	jr	z, HDAE5000_FdSong_CheckFiles_Skip7
	pushw HDAE5000_FdSong_CheckFiles_Str_TM@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_TM@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_TM
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+4)
	lda xbc, (HDAE5000_FdSong_CheckFiles_Str_rb_5:24)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xhl, (xde + HamaFn_fopen_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn_fread_ext)
	ld	xbc, 0x00000200
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_fclose_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, xwa
	ld	wa, 4:i3
	calr	HDAE5000_CheckFileSignature
	cp	hl, 0xffff
	jr	nz, HDAE5000_FdSong_CheckFiles_Skip7
	ldw	hl, 0xffff
	jrl	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip7:
	ld	wa, (xsp+284)
	bit	0x05, wa
	jr	z, HDAE5000_FdSong_CheckFiles_Skip8
	pushw HDAE5000_FdSong_CheckFiles_Str_MSP@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_MSP@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_MSP
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+4)
	lda xbc, (HDAE5000_FdSong_CheckFiles_Str_rb_6:24)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xhl, (xde + HamaFn_fopen_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn_fread_ext)
	ld	xbc, 0x00000200
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_fclose_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, xwa
	ld	wa, 5:i3
	calr	HDAE5000_CheckFileSignature
	cp	hl, 0xffff
	jr	nz, HDAE5000_FdSong_CheckFiles_Skip8
	ldw	hl, 0xffff
	jrl	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip8:
	ld	wa, (xsp+284)
	bit	0x06, wa
	jr	z, HDAE5000_FdSong_CheckFiles_Skip9
	pushw HDAE5000_FdSong_CheckFiles_Str_RCM@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_RCM@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_RCM
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+4)
	lda xbc, (HDAE5000_FdSong_CheckFiles_Str_rb_7:24)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xhl, (xde + HamaFn_fopen_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn_fread_ext)
	ld	xbc, 0x00000200
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_fclose_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, xwa
	ld	wa, 6:i3
	calr	HDAE5000_CheckFileSignature
	cp	hl, 0xffff
	jr	nz, HDAE5000_FdSong_CheckFiles_Skip9
	ldw	hl, 0xffff
	jrl	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip9:
	ld	wa, (xsp+284)
	bit	0x07, wa
	jr	z, HDAE5000_FdSong_CheckFiles_Skip10
	pushw HDAE5000_FdSong_CheckFiles_Str_MD@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_MD@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_MD
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+4)
	lda xbc, (HDAE5000_FdSong_CheckFiles_Str_rb_8:24)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xhl, (xde + HamaFn_fopen_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn_fread_ext)
	ld	xbc, 0x00000200
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_fclose_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, xwa
	ld	wa, 7:i3
	calr	HDAE5000_CheckFileSignature
	cp	hl, 0xffff
	jr	nz, HDAE5000_FdSong_CheckFiles_Skip10
	ldw	hl, 0xffff
	jr	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Skip10:
	ld	wa, (xsp+284)
	bit	0x08, wa
	jr	z, HDAE5000_FdSong_CheckFiles_Done
	pushw HDAE5000_FdSong_CheckFiles_Str_TLX@hi16
	pushw	HDAE5000_FdSong_CheckFiles_Str_TLX@lo16		; low half of HDAE5000_FdSong_CheckFiles_Str_TLX
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda	xwa, (xsp+4)
	lda xbc, (HDAE5000_FdSong_CheckFiles_Str_rb_9:24)
	ld	xde, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xde, (xde + WS_HamaFnTable)
	ld_sril	xhl, (xde + HamaFn_fopen_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_HamaFnTable)
	ld_sril	xhl, (xbc + HamaFn_fread_ext)
	ld	xbc, 0x00000200
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_fclose_ext)
	call	(xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld	xbc, xwa
	ldw	wa, 0x0008
	calr	HDAE5000_CheckFileSignature
	cp	hl, 0xffff
	jr	nz, HDAE5000_FdSong_CheckFiles_Done
	ldw	hl, 0xffff
	jr	t, HDAE5000_FdSong_CheckFiles_Epilogue
HDAE5000_FdSong_CheckFiles_Done:
	ld	hl, 0:i3
HDAE5000_FdSong_CheckFiles_Epilogue:
	pop xiz
	lda xsp, (xsp+282)
	ret

; ---------------------------------------------------------------------------
; Copy a floppy song into a song of the HD: checks the free space
; (HDAE5000_Song_CheckFreeSpace), then, inside the usual main-CPU bracket, per
; bit k of the mask HDAE5000_CopyFdSongToHd_<part k> (clear bits delete that
; part, HDAE5000_DeleteSongParts).  Caller: HDAE5000_CopyToHd_Execute (the
; copy-to-HD screen).
; In:  WA = directory, BC = song, XDE = the floppy song's name; stacked: the
;      part mask and flags
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd:
	lda	xsp, (xsp-38)
	push xiz
	ld (xsp + 0x22), xde
	ld (xsp + 0x26), bc
	ld (xsp + 0x28), wa
	ldw (xsp + 0x04), 0
	ld	wa, (xsp+50)
	calr	HDAE5000_Song_CheckFreeSpace
	cp	hl, 0xffff
	jrl	z, HDAE5000_CopyFdSongToHd_Skip3
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayHalt)
	ld	wa, 1:i3
	call	(xhl)
	cpw	(xsp+48), 0x0001
	jr	nz, HDAE5000_CopyFdSongToHd_Join
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SleepMainTask)
	call	(xhl)
HDAE5000_CopyFdSongToHd_Join:
	call HDAE5000_ATA_SoftReset_Status
	ld	wa, (xsp+50)
	bit	0x00, wa
	jr	z, HDAE5000_CopyFdSongToHd_Join2
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	ld xde, (xsp + 0x22)
	calr	HDAE5000_CopyFdSongToHd_Lsw
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_CopyFdSongToHd_Join2
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	calr	HDAE5000_DeleteSongPart_Lsw
HDAE5000_CopyFdSongToHd_Join2:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_CopyFdSongToHd_Join3
	ld	wa, (xsp+50)
	bit	0x01, wa
	jr	z, HDAE5000_CopyFdSongToHd_Join3
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	ld xde, (xsp + 0x22)
	calr	HDAE5000_CopyFdSongToHd_Pmt
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_CopyFdSongToHd_Join3
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	calr	HDAE5000_DeleteSongPart_Pmt
HDAE5000_CopyFdSongToHd_Join3:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_CopyFdSongToHd_Join4
	ld	wa, (xsp+50)
	bit	0x02, wa
	jr	z, HDAE5000_CopyFdSongToHd_Join4
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	ld xde, (xsp + 0x22)
	calr	HDAE5000_CopyFdSongToHd_Sqt
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_CopyFdSongToHd_Join4
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	calr	HDAE5000_DeleteSongPart_Sqt
HDAE5000_CopyFdSongToHd_Join4:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_CopyFdSongToHd_Join5
	ld	wa, (xsp+50)
	bit	0x03, wa
	jr	z, HDAE5000_CopyFdSongToHd_Join5
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	ld xde, (xsp + 0x22)
	calr	HDAE5000_CopyFdSongToHd_Cmp
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_CopyFdSongToHd_Join5
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	calr	HDAE5000_DeleteSongPart_Cmp
HDAE5000_CopyFdSongToHd_Join5:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_CopyFdSongToHd_Join6
	ld	wa, (xsp+50)
	bit	0x04, wa
	jr	z, HDAE5000_CopyFdSongToHd_Join6
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	ld xde, (xsp + 0x22)
	calr	HDAE5000_CopyFdSongToHd_Tm
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_CopyFdSongToHd_Join6
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	calr	HDAE5000_DeleteSongPart_Tm
HDAE5000_CopyFdSongToHd_Join6:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_CopyFdSongToHd_Join8
	ld	wa, (xsp+50)
	bit	0x05, wa
	jr	z, HDAE5000_CopyFdSongToHd_Join8
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	ld xde, (xsp + 0x22)
	calr	HDAE5000_CopyFdSongToHd_Msp
	ld	(xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_CopyFdSongToHd_Join8
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	calr	HDAE5000_DeleteSongPart_Msp
HDAE5000_CopyFdSongToHd_Join8:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_CopyFdSongToHd_Join7
	ld	wa, (xsp+50)
	bit	0x06, wa
	jr	z, HDAE5000_CopyFdSongToHd_Join7
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	ld	xde, (xsp + 0x22)
	calr	HDAE5000_CopyFdSongToHd_Rcm
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_CopyFdSongToHd_Join7
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	calr	HDAE5000_DeleteSongPart_Rcm
HDAE5000_CopyFdSongToHd_Join7:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_CopyFdSongToHd_Join9
	ld	wa, (xsp+50)
	bit	0x07, wa
	jr	z, HDAE5000_CopyFdSongToHd_Join9
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	ld xde, (xsp + 0x22)
	calr	HDAE5000_CopyFdSongToHd_Md
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_CopyFdSongToHd_Join9
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	calr	HDAE5000_DeleteSongPart_Md
HDAE5000_CopyFdSongToHd_Join9:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_CopyFdSongToHd_Join10
	ld	wa, (xsp+50)
	bit	0x08, wa
	jr	z, HDAE5000_CopyFdSongToHd_Join10
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	ld xde, (xsp + 0x22)
	calr	HDAE5000_CopyFdSongToHd_Tlx
	ld (xsp + 0x04), hl
	ld	wa, (xsp+4)
	cp	wa, 0xffff
	jr	nz, HDAE5000_CopyFdSongToHd_Join10
	ld	wa, (xsp+40)
	ld	bc, (xsp+38)
	calr	HDAE5000_DeleteSongPart_Tlx
HDAE5000_CopyFdSongToHd_Join10:
	cpw	(xsp+4), 0xffff
	jr	z, HDAE5000_CopyFdSongToHd_Skip2
	pushw 0x001a
	pushw 0x0020
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_MemFill
	ld	(xsp+40), 0x00
	pushw 0x0006
	ld xwa, (xsp + 0x2c)
	inc 2, xwa
	push xwa
	lda	xwa, (xsp+20)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+18)
	pushw 0x001a
	lda	xwa, (xsp+8)
	push xwa
	ld	wa, (xsp+44)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld	xiz, xhl
	ld	wa, (xsp+46)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, xiz
	ld	xwa, HDAE5000_RAM_DirNames
	add	xwa, xhl
	push xwa
	call HDAE5000_StrNCpy
	lda	xsp, (xsp+10)
	call HDAE5000_HD_WriteTables_Status
	jr	t, HDAE5000_CopyFdSongToHd_Join12
HDAE5000_CopyFdSongToHd_Skip2:
	pushw 0x0000
	pushm	(xsp+48)
	ld	wa, (xsp+44)
	ld	bc, (xsp+42)
	ldw	de, 0x01ff
	calr	HDAE5000_DeleteSongParts
HDAE5000_CopyFdSongToHd_Join12:
	cpw	(xsp+46), 0x0001
	call	nz, (HDAE5000_ATA_Standby_Status:24)
	cpw	(xsp+48), 0x0001
	jr	nz, HDAE5000_CopyFdSongToHd_Join13
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_WakeUpMainTask)
	call	(xhl)
HDAE5000_CopyFdSongToHd_Join13:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayStandBy)
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_EditSwRefresh)
	call	(xhl)
	jr	t, HDAE5000_CopyFdSongToHd_Done
HDAE5000_CopyFdSongToHd_Skip3:
	ldw (xsp + 0x04), 65535
HDAE5000_CopyFdSongToHd_Done:
	ld	hl, (xsp+4)
	pop xiz
	lda	xsp, (xsp+38)
	retd 0x0006


; ---------------------------------------------------------------------------
; Copy the floppy file of part 0 (LSW) into a song: read through the main
; CPU's file hooks (HamaFn_fopen_ext with mode "rb", HamaFn_fread_ext into
; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new
; cluster chain at slot +36 of the song record (the calls below).  Called
; by HDAE5000_CopyFdSongToHd.
; In:  WA = directory, BC = song
; Main CPU: HamaFn_GetResouceInfo, HamaFn_fopen_ext, HamaFn_fread_ext,
;      HamaFn_fclose_ext
; Calls: HDAE5000_MemCopy, HDAE5000_StrCpy, HDAE5000_RoundUpToSector,
;      HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd_Lsw:
	lda xsp, (xsp - 42)
	push xiz
	ld (xsp + 42), bc	; save file number
	ld (xsp + 44), wa	; save directory
	ldw (xsp + 10), 0x0000	; init result = 0
	; Call 0x29AE9F with args
	pushw 0x0008
	push xde
	lda xwa, (xsp + 18)
	push xwa
	call HDAE5000_MemCopy
	; Call 0x29AF45 with args
	pushw	HDAE5000_CopyFdSongToHd_Lsw_Str_LSW@hi16
	pushw	HDAE5000_CopyFdSongToHd_Lsw_Str_LSW@lo16		; low half of HDAE5000_CopyFdSongToHd_Lsw_Str_LSW
	lda xwa, (xsp + 34)
	push xwa
	call HDAE5000_StrCpy
	lda xsp, (xsp + 18)	; cleanup 18 bytes
	; Workspace dispatch WA=0 (buffer at xsp+34)
	lda xwa, (xsp + 34)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_GetResouceInfo)
	ld wa, 0:i3
	call (xhl)
	; Workspace dispatch WA=1 (buffer at xsp+26)
	lda xwa, (xsp + 26)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_GetResouceInfo)
	ld wa, 1:i3
	call (xhl)
	; Cell_Get_Params
	ld xwa, (xsp + 30)
	add xwa, (xsp + 38)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 4), xhl
	; Call workspace handler via XIX chain
	lda xwa, (xsp + 12)
	lda xbc, (HDAE5000_CopyFdSongToHd_Lsw_Str_rb:24); 0x2F83FA
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn_fopen_ext)
	call (xix)
	; Check if result < 0
	cp hl, 0:i3
	jrl lt, .Lts488_error
	; Workspace dispatch via XDE chain at 0xA8
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (xsp + 4)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xhl, (xde + HamaFn_fread_ext)
	call (xhl)
	; Write metadata: store 0x00, 0x10, 0x00 at workspace+offset
	ld xwa, (xsp + 30)
	add xwa, (xsp + 38)
	ld xbc, HDAE5000_RAM_HdStreamBuffer
	add xbc, xwa
	ld (xbc), 0x00
	; offset+1: store 0x10
	ld xwa, (xsp + 30)
	add xwa, (xsp + 38)
	inc 1, xwa
	ld xbc, HDAE5000_RAM_HdStreamBuffer
	add xbc, xwa
	ld (xbc), 0x10
	; offset+2: store 0x00
	ld xwa, (xsp + 30)
	add xwa, (xsp + 38)
	inc 2, xwa
	ld xbc, HDAE5000_RAM_HdStreamBuffer
	add xbc, xwa
	ld (xbc), 0x00
	; Save workspace ptr
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 8), xwa
	; First multiply: compute table offset
	ld wa, (xsp + 42)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 44)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	; Table write via 0x297E16
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+36:24)	; table base
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 8)
	ld xbc, (xsp + 4)
	call HDAE5000_HD_WriteFile
	ld (xsp + 10), hl	; save result
	; Second multiply: compute table offset
	ld wa, (xsp + 42)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 44)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	; Set flag byte to 1
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+26:24)	; flag base
	add xwa, xhl
	ld (xwa), 0x01
	; Final workspace dispatch at 0xAC
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)
	call (xhl)
	jr .Lts488_done
.Lts488_error:
	ldw (xsp + 10), 0xFFFF
.Lts488_done:
	ld hl, (xsp + 10)
	pop xiz
	lda xsp, (xsp + 42)
	ret

; ---------------------------------------------------------------------------
; Copy the floppy file of part 1 (PMT) into a song: read through the main
; CPU's file hooks (HamaFn_fopen_ext with mode "rb", HamaFn_fread_ext into
; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new
; cluster chain at slot +40 of the song record (the calls below).  Called
; by HDAE5000_CopyFdSongToHd.
; In:  WA = directory, BC = song
; Main CPU: HamaFn_fopen_ext, HamaFn_fread_ext, HamaFn_fclose_ext
; Calls: HDAE5000_MemCopy, HDAE5000_StrCpy, HDAE5000_RoundUpToSector,
;      HDAE5000_HD_WriteFile, HDAE5000_HD_AppendFile
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd_Pmt:
	lda xsp, (xsp - 30)
	push xiz
	ld (xsp + 30), bc	; save file number
	ld (xsp + 32), wa	; save directory
	ldw (xsp + 14), 0x0000	; init result = 0
	; Call 0x29AE9F with args
	pushw 0x0008
	push xde
	lda xwa, (xsp + 22)
	push xwa
	call HDAE5000_MemCopy
	; Call 0x29AF45 with args
	pushw	HDAE5000_CopyFdSongToHd_Pmt_Str_PMT@hi16
	pushw	HDAE5000_CopyFdSongToHd_Pmt_Str_PMT@lo16		; low half of HDAE5000_CopyFdSongToHd_Pmt_Str_PMT
	lda xwa, (xsp + 38)
	push xwa
	call HDAE5000_StrCpy
	lda xsp, (xsp + 18)	; clean up pushed args
	; First workspace dispatch
	lda xwa, (xsp + 16)
	lda xbc, (HDAE5000_CopyFdSongToHd_Pmt_Str_rb:24); 0x2F8404
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)             ; (XDE+0x0E88)
	ld_sril xix, (xde + HamaFn_fopen_ext)             ; (XDE+0x00A0)
	call (xix)
	; Check result
	cp hl, 0:i3
	jr ge, .Lts925_1
	ldw hl, 0xFFFF
	jrl .Lts925_exit
.Lts925_1:
	; Second workspace dispatch
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)             ; (XBC+0x0E88)
	ld_sril xhl, (xbc + HamaFn_fread_ext)             ; (XBC+0x00A8)
	ld xbc, 0x00008000
	call (xhl)
	ld (xsp + 4), xhl
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 8), xwa
	ld xwa, (xsp + 4)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 12), xhl
	; Multiply: compute table offset
	ld wa, (xsp + 30)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	; Table lookup
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+40:24)	; table base
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 8)
	ld xbc, (xsp + 12)
	call HDAE5000_HD_WriteFile
	ld (xsp + 14), hl	; store result
	ld wa, (xsp + 14)	; reload for compare
	cp wa, 0xFFFF
	jr nz, .Lts925_2
	ldw hl, 0xFFFF
	jrl .Lts925_exit
.Lts925_2:
	; Check if dispatch returned 0x8000
	ld xwa, (xsp + 4)
	cp xwa, 0x00008000
	jrl nz, .Lts925_5
.Lts925_loop:
	; Re-dispatch
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn_fread_ext)
	ld xbc, 0x00008000
	call (xhl)
	ld (xsp + 4), xhl
	ld xwa, (xsp + 4)
	cp xwa, 0x00000000
	jr le, .Lts925_4
	; Retry with new params
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 8), xwa
	ld xwa, (xsp + 4)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 12), xhl
	ld wa, (xsp + 30)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+40:24)
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 8)
	ld xbc, (xsp + 12)
	call HDAE5000_HD_AppendFile
	ld (xsp + 14), hl
	ld wa, (xsp + 14)
	cp wa, 0xFFFF
	jr z, .Lts925_5
.Lts925_4:
	ld xwa, (xsp + 4)
	cp xwa, 0x00008000
	jrl z, .Lts925_loop
.Lts925_5:
	; Post-processing: set flag
	ld wa, (xsp + 30)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+27:24)	; flag base
	add xwa, xhl
	ld (xwa), 0x01
	; Final workspace dispatch
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)             ; (XWA+0x0E88)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)             ; (XWA+0x00AC)
	call (xhl)
	ld hl, (xsp + 14)	; normal exit: load result
.Lts925_exit:			; error exit: HL already set
	pop xiz
	lda xsp, (xsp + 30)
	ret

; ---------------------------------------------------------------------------
; Copy the floppy file of part 2 (SQT) into a song: read through the main
; CPU's file hooks (HamaFn_fopen_ext with mode "rb", HamaFn_fread_ext into
; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new
; cluster chain at slot +44 of the song record (the calls below).  Called
; by HDAE5000_CopyFdSongToHd.
; In:  WA = directory, BC = song
; Main CPU: HamaFn_fopen_ext, HamaFn_fread_ext, HamaFn_fclose_ext
; Calls: HDAE5000_MemCopy, HDAE5000_StrCpy, HDAE5000_RoundUpToSector,
;      HDAE5000_HD_WriteFile, HDAE5000_HD_AppendFile
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd_Sqt:
	lda xsp, (xsp - 32)
	push xiz
	ld (xsp + 32), bc	; save file number
	ld (xsp + 34), wa	; save directory
	ldw (xsp + 4), 0x0000	; init result = 0
	; Call 0x29AE9F with args
	pushw 0x0008
	push xde
	lda xwa, (xsp + 24)
	push xwa
	call HDAE5000_MemCopy
	; Call 0x29AF45 with args
	pushw	HDAE5000_CopyFdSongToHd_Sqt_Str_SQT@hi16
	pushw	HDAE5000_CopyFdSongToHd_Sqt_Str_SQT@lo16		; low half of HDAE5000_CopyFdSongToHd_Sqt_Str_SQT
	lda xwa, (xsp + 40)
	push xwa
	call HDAE5000_StrCpy
	lda xsp, (xsp + 18)	; clean up pushed args
	; First workspace dispatch
	lda xwa, (xsp + 18)
	lda xbc, (HDAE5000_CopyFdSongToHd_Sqt_Str_rb:24); 0x2F840E
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)             ; (XDE+0x0E88)
	ld_sril xix, (xde + HamaFn_fopen_ext)             ; (XDE+0x00A0)
	call (xix)
	; Check result
	cp hl, 0:i3
	jr ge, .Lts927_1
	ldw hl, 0xFFFF
	jrl .Lts927_exit
.Lts927_1:
	; Second workspace dispatch
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)             ; (XBC+0x0E88)
	ld_sril xhl, (xbc + HamaFn_fread_ext)             ; (XBC+0x00A8)
	ld xbc, 0x00008000
	call (xhl)
	ld (xsp + 6), xhl
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 10), xwa
	ld xwa, (xsp + 6)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 14), xhl
	; Multiply: compute table offset
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x0000004c
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	; Table lookup
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+44:24)	; table base
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 10)
	ld xbc, (xsp + 14)
	call HDAE5000_HD_WriteFile
	cp hl, 0xFFFF
	jr nz, .Lts927_2
	ldw hl, 0xFFFF
	jrl .Lts927_exit
.Lts927_2:
	; Check if dispatch returned 0x8000
	ld xwa, (xsp + 6)
	cp xwa, 0x00008000
	jrl nz, .Lts927_5
.Lts927_loop:
	; Re-dispatch
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn_fread_ext)
	ld xbc, 0x00008000
	call (xhl)
	ld (xsp + 6), xhl
	ld xwa, (xsp + 6)
	cp xwa, 0x00000000
	jr le, .Lts927_4
	; Retry with new params
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 10), xwa
	ld xwa, (xsp + 6)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 14), xhl
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x0000004c
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+44:24)
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 10)
	ld xbc, (xsp + 14)
	call HDAE5000_HD_AppendFile
	ld (xsp + 4), hl
	ld wa, (xsp + 4)
	cp wa, 0xFFFF
	jr z, .Lts927_5
.Lts927_4:
	ld xwa, (xsp + 6)
	cp xwa, 0x00008000
	jrl z, .Lts927_loop
.Lts927_5:
	; Post-processing: set flag
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+28:24)	; flag base
	add xwa, xhl
	ld (xwa), 0x01
	; Final workspace dispatch
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)             ; (XWA+0x0E88)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)             ; (XWA+0x00AC)
	call (xhl)
	ld hl, (xsp + 4)	; normal exit: load result
.Lts927_exit:			; error exit: HL already set
	pop xiz
	lda xsp, (xsp + 32)
	ret

; ---------------------------------------------------------------------------
; Copy the floppy file of part 3 (CMP) into a song: read through the main
; CPU's file hooks (HamaFn_fopen_ext with mode "rb", HamaFn_fread_ext into
; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new
; cluster chain at slot +48 of the song record (the calls below).  Called
; by HDAE5000_CopyFdSongToHd.
; In:  WA = directory, BC = song
; Main CPU: HamaFn_fopen_ext, HamaFn_fread_ext, HamaFn_fclose_ext
; Calls: HDAE5000_MemCopy, HDAE5000_StrCpy, HDAE5000_RoundUpToSector,
;      HDAE5000_HD_WriteFile, HDAE5000_HD_AppendFile
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd_Cmp:
	lda xsp, (xsp - 32)
	push xiz
	ld (xsp + 32), bc
	ld (xsp + 34), wa
	ldw (xsp + 4), 0x0000
	pushw 0x0008
	push xde
	lda xwa, (xsp + 24)
	push xwa
	call HDAE5000_MemCopy
	pushw	HDAE5000_CopyFdSongToHd_Cmp_Str_CMP@hi16
	pushw	HDAE5000_CopyFdSongToHd_Cmp_Str_CMP@lo16		; low half of HDAE5000_CopyFdSongToHd_Cmp_Str_CMP
	lda xwa, (xsp + 40)
	push xwa
	call HDAE5000_StrCpy
	lda xsp, (xsp + 18)
	lda xwa, (xsp + 18)
	lda xbc, (HDAE5000_CopyFdSongToHd_Cmp_Str_rb:24); 0x2F8418
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn_fopen_ext)
	call (xix)
	cp hl, 0:i3
	jr ge, .Lts929_1
	ldw hl, 0xFFFF
	jrl .Lts929_exit
.Lts929_1:
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn_fread_ext)
	ld xbc, 0x00008000
	call (xhl)
	ld (xsp + 6), xhl
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 10), xwa
	ld xwa, (xsp + 6)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 14), xhl
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+48:24)	; table base
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 10)
	ld xbc, (xsp + 14)
	call HDAE5000_HD_WriteFile
	cp hl, 0xFFFF
	jr nz, .Lts929_2
	ldw hl, 0xFFFF
	jrl .Lts929_exit
.Lts929_2:
	ld xwa, (xsp + 6)
	cp xwa, 0x00008000
	jrl nz, .Lts929_5
.Lts929_loop:
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn_fread_ext)
	ld xbc, 0x00008000
	call (xhl)
	ld (xsp + 6), xhl
	ld xwa, (xsp + 6)
	cp xwa, 0x00000000
	jr le, .Lts929_4
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 10), xwa
	ld xwa, (xsp + 6)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 14), xhl
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+48:24)
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 10)
	ld xbc, (xsp + 14)
	call HDAE5000_HD_AppendFile
	ld (xsp + 4), hl
	ld wa, (xsp + 4)
	cp wa, 0xFFFF
	jr z, .Lts929_5
.Lts929_4:
	ld xwa, (xsp + 6)
	cp xwa, 0x00008000
	jrl z, .Lts929_loop
.Lts929_5:
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+29:24)	; flag base
	add xwa, xhl
	ld (xwa), 0x01
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)
	call (xhl)
	ld hl, (xsp + 4)
.Lts929_exit:
	pop xiz
	lda xsp, (xsp + 32)
	ret

; ---------------------------------------------------------------------------
; Copy the floppy file of part 4 (TM) into a song: read through the main
; CPU's file hooks (HamaFn_fopen_ext with mode "rb", HamaFn_fread_ext into
; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new
; cluster chain at slot +52 of the song record (the calls below).  Called
; by HDAE5000_CopyFdSongToHd.
; In:  WA = directory, BC = song
; Main CPU: HamaFn_GetResouceInfo, HamaFn_fopen_ext, HamaFn_fread_ext,
;      HamaFn_fclose_ext
; Calls: HDAE5000_MemCopy, HDAE5000_StrCpy, HDAE5000_RoundUpToSector,
;      HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd_Tm:
	lda xsp, (xsp - 34)
	push xiz
	ld (xsp + 34), bc	; save file number
	ld (xsp + 36), wa	; save directory
	ldw (xsp + 10), 0x0000	; init result = 0
	; Call 0x29AE9F with args
	pushw 0x0008
	push xde
	lda xwa, (xsp + 18)
	push xwa
	call HDAE5000_MemCopy
	; Call 0x29AF45 with args
	pushw	HDAE5000_CopyFdSongToHd_Tm_Str_TM@hi16
	pushw	HDAE5000_CopyFdSongToHd_Tm_Str_TM@lo16		; low half of HDAE5000_CopyFdSongToHd_Tm_Str_TM
	lda xwa, (xsp + 34)
	push xwa
	call HDAE5000_StrCpy
	lda xsp, (xsp + 18)	; clean up pushed args
	; Workspace dispatch with WA=6
	lda xwa, (xsp + 26)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_GetResouceInfo)             ; (XWA+0x0080)
	ld wa, 6:i3
	call (xhl)
	; Load constant and save
	ld xwa, 0x000072AA
	ld (xsp + 30), xwa
	; Second dispatch via XIX
	lda xwa, (xsp + 12)
	lda xbc, (HDAE5000_CopyFdSongToHd_Tm_Str_rb:24); 0x2F8420
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn_fopen_ext)
	call (xix)
	cp hl, 0:i3
	jrl lt, .Lts92a_error
	; Workspace dispatch: get handler
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (xsp + 30)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xhl, (xde + HamaFn_fread_ext)             ; (XDE+0x00A8)
	call (xhl)
	; Save workspace base and get cell params
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 4), xwa
	ld xwa, (xsp + 30)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 8), xhl
	; Multiply: compute table offset
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 36)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	; Table lookup
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+52:24)	; table base
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 4)
	ld xbc, (xsp + 8)
	call HDAE5000_HD_WriteFile
	ld (xsp + 10), hl
	; Set flag
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 36)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+30:24)	; flag base
	add xwa, xhl
	ld (xwa), 0x01
	; Final workspace dispatch
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)             ; (XWA+0x00AC)
	call (xhl)
	jr .Lts92a_load
.Lts92a_error:
	ldw (xsp + 10), 0xFFFF	; error: result = -1
.Lts92a_load:
	ld hl, (xsp + 10)
	pop xiz
	lda xsp, (xsp + 34)
	ret

; ---------------------------------------------------------------------------
; Copy the floppy file of part 5 (MSP) into a song: read through the main
; CPU's file hooks (HamaFn_fopen_ext with mode "rb", HamaFn_fread_ext into
; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new
; cluster chain at slot +56 of the song record (the calls below).  Called
; by HDAE5000_CopyFdSongToHd.
; In:  WA = directory, BC = song
; Main CPU: HamaFn_GetResouceInfo, HamaFn_fopen_ext, HamaFn_fread_ext,
;      HamaFn_fclose_ext
; Calls: HDAE5000_MemCopy, HDAE5000_StrCpy, HDAE5000_RoundUpToSector,
;      HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd_Msp:
	lda xsp, (xsp - 34)
	push xiz
	ld (xsp + 34), bc
	ld (xsp + 36), wa
	ldw (xsp + 10), 0x0000
	pushw 0x0008
	push xde
	lda xwa, (xsp + 18)
	push xwa
	call HDAE5000_MemCopy
	pushw	HDAE5000_CopyFdSongToHd_Msp_Str_MSP@hi16
	pushw	HDAE5000_CopyFdSongToHd_Msp_Str_MSP@lo16		; low half of HDAE5000_CopyFdSongToHd_Msp_Str_MSP
	lda xwa, (xsp + 34)
	push xwa
	call HDAE5000_StrCpy
	lda xsp, (xsp + 18)
	; Workspace dispatch with WA=7
	lda xwa, (xsp + 26)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_GetResouceInfo)
	ld wa, 7:i3
	call (xhl)
	; Second dispatch via XIX (no constant store)
	lda xwa, (xsp + 12)
	lda xbc, (HDAE5000_CopyFdSongToHd_Msp_Str_rb:24); 0x2F842A
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn_fopen_ext)
	call (xix)
	cp hl, 0:i3
	jrl lt, .Lts92b_error
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (xsp + 30)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xhl, (xde + HamaFn_fread_ext)
	call (xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 4), xwa
	ld xwa, (xsp + 30)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 8), xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 36)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+56:24)	; table base
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 4)
	ld xbc, (xsp + 8)
	call HDAE5000_HD_WriteFile
	ld (xsp + 10), hl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 36)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+31:24)	; flag base
	add xwa, xhl
	ld (xwa), 0x01
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)
	call (xhl)
	jr .Lts92b_load
.Lts92b_error:
	ldw (xsp + 10), 0xFFFF
.Lts92b_load:
	ld hl, (xsp + 10)
	pop xiz
	lda xsp, (xsp + 34)
	ret

; ---------------------------------------------------------------------------
; Copy the floppy file of part 6 (RCM) into a song: read through the main
; CPU's file hooks (HamaFn_fopen_ext with mode "rb", HamaFn_fread_ext into
; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new
; cluster chain at slot +60 of the song record (the calls below).  Called
; by HDAE5000_CopyFdSongToHd.
; In:  WA = directory, BC = song
; Main CPU: HamaFn_fopen_ext, HamaFn_fread_ext, HamaFn_fclose_ext
; Calls: HDAE5000_MemCopy, HDAE5000_StrCpy, HDAE5000_RoundUpToSector,
;      HDAE5000_HD_WriteFile, HDAE5000_HD_AppendFile
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd_Rcm:
	lda xsp, (xsp - 32)
	push xiz
	ld (xsp + 32), bc
	ld (xsp + 34), wa
	ldw (xsp + 4), 0x0000
	pushw 0x0008
	push xde
	lda xwa, (xsp + 24)
	push xwa
	call HDAE5000_MemCopy
	pushw	HDAE5000_CopyFdSongToHd_Rcm_Str_RCM@hi16
	pushw	HDAE5000_CopyFdSongToHd_Rcm_Str_RCM@lo16		; low half of HDAE5000_CopyFdSongToHd_Rcm_Str_RCM
	lda xwa, (xsp + 40)
	push xwa
	call HDAE5000_StrCpy
	lda xsp, (xsp + 18)
	lda xwa, (xsp + 18)
	lda xbc, (HDAE5000_CopyFdSongToHd_Rcm_Str_rb:24); 0x2F8434
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn_fopen_ext)
	call (xix)
	cp hl, 0:i3
	jr ge, .Lts92d_1
	ldw hl, 0xFFFF
	jrl .Lts92d_exit
.Lts92d_1:
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn_fread_ext)
	ld xbc, 0x00008000
	call (xhl)
	ld (xsp + 6), xhl
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 10), xwa
	ld xwa, (xsp + 6)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 14), xhl
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+60:24)	; table base
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 10)
	ld xbc, (xsp + 14)
	call HDAE5000_HD_WriteFile
	cp hl, 0xFFFF
	jr nz, .Lts92d_2
	ldw hl, 0xFFFF
	jrl .Lts92d_exit
.Lts92d_2:
	ld xwa, (xsp + 6)
	cp xwa, 0x00008000
	jrl nz, .Lts92d_5
.Lts92d_loop:
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn_fread_ext)
	ld xbc, 0x00008000
	call (xhl)
	ld (xsp + 6), xhl
	ld xwa, (xsp + 6)
	cp xwa, 0x00000000
	jr le, .Lts92d_4
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 10), xwa
	ld xwa, (xsp + 6)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 14), xhl
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+60:24)
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 10)
	ld xbc, (xsp + 14)
	call HDAE5000_HD_AppendFile
	ld (xsp + 4), hl
	ld wa, (xsp + 4)
	cp wa, 0xFFFF
	jr z, .Lts92d_5
.Lts92d_4:
	ld xwa, (xsp + 6)
	cp xwa, 0x00008000
	jrl z, .Lts92d_loop
.Lts92d_5:
	ld wa, (xsp + 32)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+32:24)	; flag base
	add xwa, xhl
	ld (xwa), 0x01
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)
	call (xhl)
	ld hl, (xsp + 4)
.Lts92d_exit:
	pop xiz
	lda xsp, (xsp + 32)
	ret

; ---------------------------------------------------------------------------
; Copy the floppy file of part 7 (MD) into a song: read through the main
; CPU's file hooks (HamaFn_fopen_ext with mode "rb", HamaFn_fread_ext into
; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new
; cluster chain at slot +64 of the song record (the calls below).  Called
; by HDAE5000_CopyFdSongToHd.
; In:  WA = directory, BC = song
; Main CPU: HamaFn_GetResouceInfo, HamaFn_fopen_ext, HamaFn_fread_ext,
;      HamaFn_fclose_ext
; Calls: HDAE5000_MemCopy, HDAE5000_StrCpy, HDAE5000_RoundUpToSector,
;      HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd_Md:
	lda xsp, (xsp - 34)
	push xiz
	ld (xsp + 34), bc
	ld (xsp + 36), wa
	ldw (xsp + 10), 0x0000
	pushw 0x0008
	push xde
	lda xwa, (xsp + 18)
	push xwa
	call HDAE5000_MemCopy
	pushw	HDAE5000_CopyFdSongToHd_Md_Str_MD@hi16
	pushw	HDAE5000_CopyFdSongToHd_Md_Str_MD@lo16		; low half of HDAE5000_CopyFdSongToHd_Md_Str_MD
	lda xwa, (xsp + 34)
	push xwa
	call HDAE5000_StrCpy
	lda xsp, (xsp + 18)
	; Workspace dispatch with WA=9
	lda xwa, (xsp + 26)
	ld xbc, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_GetResouceInfo)
	ldw wa, 0x0009
	call (xhl)
	; Second dispatch via XIX
	lda xwa, (xsp + 12)
	lda xbc, (HDAE5000_CopyFdSongToHd_Md_Str_rb:24); 0x2F843C
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn_fopen_ext)
	call (xix)
	cp hl, 0:i3
	jrl lt, .Lts92e_error
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (xsp + 30)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xhl, (xde + HamaFn_fread_ext)
	call (xhl)
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 4), xwa
	ld xwa, (xsp + 30)
	calr HDAE5000_RoundUpToSector
	ld (xsp + 8), xhl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 36)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+64:24)	; table base
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 4)
	ld xbc, (xsp + 8)
	call HDAE5000_HD_WriteFile
	ld (xsp + 10), hl
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 36)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+33:24)	; flag base
	add xwa, xhl
	ld (xwa), 0x01
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)
	call (xhl)
	jr .Lts92e_load
.Lts92e_error:
	ldw (xsp + 10), 0xFFFF
.Lts92e_load:
	ld hl, (xsp + 10)
	pop xiz
	lda xsp, (xsp + 34)
	ret

; ---------------------------------------------------------------------------
; Copy the floppy file of part 8 (TLX) into a song: read through the main
; CPU's file hooks (HamaFn_fopen_ext with mode "rb", HamaFn_fread_ext into
; HDAE5000_RAM_HdStreamBuffer, HamaFn_fclose_ext) and written to a new
; cluster chain at slot +68 of the song record (the calls below).  Called
; by HDAE5000_CopyFdSongToHd.
; In:  WA = directory, BC = song
; Main CPU: HamaFn_fopen_ext, HamaFn_fread_ext, HamaFn_fclose_ext
; Calls: HDAE5000_MemCopy, HDAE5000_StrCpy, HDAE5000_MemFill,
;      HDAE5000_SwapBytes32, HDAE5000_RoundUpToSector, HDAE5000_HD_WriteFile
; ---------------------------------------------------------------------------
HDAE5000_CopyFdSongToHd_Tlx:
	lda xsp, (xsp - 34)
	push xiz
	ld (xsp + 34), bc
	ld (xsp + 36), wa
	ldw (xsp + 10), 0x0000
	pushw 0x0008
	push xde
	lda xwa, (xsp + 18)
	push xwa
	call HDAE5000_MemCopy
	pushw	HDAE5000_CopyFdSongToHd_Tlx_Str_TLX@hi16
	pushw	HDAE5000_CopyFdSongToHd_Tlx_Str_TLX@lo16		; low half of HDAE5000_CopyFdSongToHd_Tlx_Str_TLX
	lda xwa, (xsp + 34)
	push xwa
	call HDAE5000_StrCpy
	lda xsp, (xsp + 18)
	; Dispatch via XIX
	lda xwa, (xsp + 12)
	lda xbc, (HDAE5000_CopyFdSongToHd_Tlx_Str_rb:24); 0x2F8446
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn_fopen_ext)
	call (xix)
	cp hl, 0:i3
	jrl	lt, .Lts92f_error
	; Call 0x29AEC7 with args (8 bytes pushed, cleaned by inc 0)
	; Workspace dispatch with XBC=0x16
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn_fread_ext)
	ld xbc, 0x00000016
	call (xhl)
	; Load param, call 0x28E5E9, sign extend result
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xwa, (xwa + 18)	; offset 0x12
	add xwa, 0x00000016
	calr HDAE5000_RoundUpToSector
	ld (xsp + 30), xhl
	; Dispatch with XIZ as XBC param
	lda xwa, (0x230ec0:24); 0x230EC0
	ld	xbc, (xsp + 0x1e)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xhl, (xde + HamaFn_fread_ext)
	call (xhl)
	; Table lookup
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld (xsp + 4), xwa
	lda xwa, (xsp + 30)
	ld (xsp + 8), xwa
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 36)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+68:24)	; table base
	add xwa, xhl
	ld xde, xwa
	ld xwa, (xsp + 4)
	ld xbc, (xsp + 8)
	ld xbc, (xbc)		; double dereference
	call HDAE5000_HD_WriteFile
	ld (xsp + 10), hl
	; Set flag
	ld wa, (xsp + 34)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 36)
	extz xwa
	ld xbc, 0x000004c0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+34:24)	; flag base
	add xwa, xhl
	ld (xwa), 0x01
	; Final workspace dispatch
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_fclose_ext)
	call (xhl)
	jr .Lts92f_load
.Lts92f_error:
	ldw (xsp + 10), 0xFFFF
.Lts92f_load:
	ld hl, (xsp + 10)
	pop xiz
	lda xsp, (xsp + 34)
	ret

; ---------------------------------------------------------------------------
; Remove a song from every FLS list: for the 120 FLS records x 32 items, an
; item whose directory byte is dir + 1 and song byte is song + 1 has its four
; bytes cleared.
; In:  WA = directory, BC = song
; ---------------------------------------------------------------------------
HDAE5000_Fls_ForgetSong:
	pushw iz
	ld iz, 0:i3
	cp iz, 0x0078
	jrl nc, .Lwh_outer_done
.Lwh_outer_loop:
	ld iy, 0:i3
	cp iy, 0x0020
	jrl nc, .Lwh_inner_done
.Lwh_inner_loop:
	; Compute table index: XIX = IZ * 144 + IY
	ld hl, iy
	extz xhl
	ld de, iz
	extz xde
	ld xix, xde
	sll xix, 3
	add xix, xde
	sll xix, 4
	add xix, xhl
	; Check WA match at base 0x2257C2
	lda xde, (HDAE5000_RAM_FlsRecords+16:24)
	add xde, xix
	ld e, (xde)
	ld l, e
	extz hl
	ld de, wa
	inc 1, de
	cp de, hl
	jrl nz, .Lwh_next_inner
	; Check BC match at base 0x2257E2
	ld hl, iy
	extz xhl
	ld de, iz
	extz xde
	ld xix, xde
	sll xix, 3
	add xix, xde
	sll xix, 4
	add xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+48:24)
	add xde, xix
	ld e, (xde)
	ld l, e
	extz hl
	ld de, bc
	inc 1, de
	cp de, hl
	jr nz, .Lwh_next_inner
	; Both match — clear 4 table entries
	; Clear entry at base 0x2257C2
	ld hl, iy
	extz xhl
	ld de, iz
	extz xde
	ld xix, xde
	sll xix, 3
	add xix, xde
	sll xix, 4
	add xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+16:24)
	add xde, xix
	ld (xde), 0x00
	; Clear entry at base 0x2257E2
	ld hl, iy
	extz xhl
	ld de, iz
	extz xde
	ld xix, xde
	sll xix, 3
	add xix, xde
	sll xix, 4
	add xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+48:24)
	add xde, xix
	ld (xde), 0x00
	; Clear entry at base 0x225802
	ld hl, iy
	extz xhl
	ld de, iz
	extz xde
	ld xix, xde
	sll xix, 3
	add xix, xde
	sll xix, 4
	add xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+80:24)
	add xde, xix
	ld (xde), 0x00
	; Clear entry at base 0x225822
	ld hl, iy
	extz xhl
	ld de, iz
	extz xde
	ld xix, xde
	sll xix, 3
	add xix, xde
	sll xix, 4
	add xix, xhl
	lda xde, (HDAE5000_RAM_FlsRecords+112:24)
	add xde, xix
	ld (xde), 0x00
.Lwh_next_inner:
	inc 1, iy
	cp iy, 0x0020
	jrl c, .Lwh_inner_loop
.Lwh_inner_done:
	inc 1, iz
	cp iz, 0x0078
	jrl c, .Lwh_outer_loop
.Lwh_outer_done:
	popw iz
	ret
	; Part 2: Main workspace handler entry (0x29320D)
	; Called by firmware — saves regs, dispatches through handler chain
HDAE5000_DeleteDirectory:
	; Delete directory WA: every used song of it loses its nine parts
	; (HDAE5000_DeleteSongPart_*) and its FLS references
	; (HDAE5000_Fls_ForgetSong) and gets a blank name (26 spaces); the
	; directory name is blanked (16 spaces); tables written
	; (HDAE5000_HD_WriteTables_Status).  BC = 1: also the 0x0E0A +0x538/+0x53C
	; UI callbacks; DE != 1: spin down.  Caller: AttenDelDirSwCatch.
	dec 8, xsp			; callee cleanup placeholder
	push xiz
	ld (xsp + 6), de		; save DE (param)
	ld (xsp + 8), bc		; save BC (param)
	ld (xsp + 10), wa		; save WA (param)
	; Get handler through workspace chain
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)             ; XWA = (XWA+0x0E88)
	ld_sril xhl, (xwa + HamaFn_PlayHalt)             ; XHL = (XWA+0x00E8) — handler
	ld wa, 1:i3			; param = 1
	call (xhl)
	; Conditional: if BC == 1, call extra handler
	cpw (xsp + 8), 0x0001
	jr nz, .Lwh_skip_extra
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)             ; XWA = (XWA+0x0E0A)
	ld xhl, (xwa + RootFn_SleepMainTask)             ; XHL = (XWA+0x0538)
	call (xhl)
.Lwh_skip_extra:
	call HDAE5000_ATA_SoftReset_Status
	ldw (xsp + 4), 0x0000		; slot counter = 0
	; Loop over 16 slots
	cpw (xsp + 4), 0x0010
	jrl nc, .Lwh_loop_done
.Lwh_slot_loop:
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_Song_IsUsed
	cp hl, 0xFFFF
	jr z, .Lwh_slot_fill
	; Process slot — call all 10 render types
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Lsw
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Pmt
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Sqt
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Cmp
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Tm
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Msp
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Rcm
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Md
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Tlx
	ld wa, (xsp + 10)
	ld bc, (xsp + 4)
	calr HDAE5000_Fls_ForgetSong	; recursive call (clear matching)
.Lwh_slot_fill:
	; Compute fill address and call MemFill
	pushw 0x001A			; fill count
	pushw 0x0020			; fill value/params
	ld wa, (xsp + 8)		; BC (adjusted for pushes)
	extz xwa
	ld xbc, 0x0000004C		; stride
	call HDAE5000_Multiply
	ld xiz, xhl			; save offset
	ld wa, (xsp + 14)		; WA (adjusted)
	extz xwa
	ld xbc, 0x000004C0		; stride
	call HDAE5000_Multiply
	add xhl, 0x00000780		; base offset
	add xhl, xiz			; total offset
	ld xwa, HDAE5000_RAM_DirNames		; table base address
	add xwa, xhl			; absolute address
	push xwa			; push fill dest
	call HDAE5000_MemFill
	inc 8, xsp			; pop MemFill's 8 argument bytes (two pushw, push xwa)
	incw 1, (xsp + 4)		; slot counter++
	cpw (xsp + 4), 0x0010
	jrl c, .Lwh_slot_loop
.Lwh_loop_done:
	; Post-loop: fill final block
	pushw 0x0010			; block count
	pushw 0x0020			; block params
	ld wa, (xsp + 14)		; WA (adjusted)
	extz xwa
	sll xwa, 4			; * 16
	ld xbc, HDAE5000_RAM_DirNames		; table base
	add xbc, xwa
	push xbc			; push fill dest
	call HDAE5000_MemFill
	inc 8, xsp			; stack cleanup
	; Final handler calls
	call HDAE5000_HD_WriteTables_Status
	cpw (xsp + 6), 0x0001	; DE == 1?
	call nz, (HDAE5000_ATA_Standby_Status:24)
	cpw (xsp + 8), 0x0001	; BC == 1?
	jr nz, .Lwh_skip_final
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)             ; XWA = (XWA+0x0E0A)
	ld xhl, (xwa + RootFn_WakeUpMainTask)             ; XHL = (XWA+0x053C)
	call (xhl)
.Lwh_skip_final:
	; Workspace cleanup calls
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_PlayStandBy)             ; XHL = (XWA+0x00EC)
	call (xhl)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_EditSwRefresh)             ; XHL = (XWA+0x00F0)
	call (xhl)
	pop xiz
	inc 8, xsp			; stack cleanup
	ret

; ---------------------------------------------------------------------------
; Delete the parts in mask DE of a song (HDAE5000_DeleteSongPart_<k> per bit),
; inside the main-CPU bracket (HamaFn_PlayHalt, optional RootFn_SleepMainTask
; / WakeUpMainTask, HamaFn_PlayStandBy, _EditSwRefresh); a song left with no
; part also leaves the FLS lists (HDAE5000_Fls_ForgetSong).  Callers:
; AttenDelFileSwCatch, SaveSong, CopyFdSongToHd, PC-link service 27.
; In:  WA = directory, BC = song, DE = part mask; two stacked words of flags
; ---------------------------------------------------------------------------
HDAE5000_DeleteSongParts:
	dec 4, xsp
	push xiz
	ld iz, de
	ld (xsp + 4), bc	; save file number
	ld (xsp + 6), wa	; save directory
	cp iz, 0:i3
	jrl z, .Lws36b_exit	; nothing to do
	; Workspace dispatch at 0xE8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_PlayHalt)
	ld wa, 1:i3
	call (xhl)
	; Check workspace flag at (xsp+14)
	cpw (xsp + 14), 0x0001
	jr nz, .Lws36b_skip1
	; Workspace dispatch at 0x0538
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SleepMainTask)
	call (xhl)
.Lws36b_skip1:
	call HDAE5000_ATA_SoftReset_Status
	; Bitmask dispatch: test bits of IZ, call corresponding renderers
	bit 0, iz
	jr z, .Lws36b_bit1
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Lsw
.Lws36b_bit1:
	bit 1, iz
	jr z, .Lws36b_bit2
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Pmt
.Lws36b_bit2:
	bit 2, iz
	jr z, .Lws36b_bit3
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Sqt
.Lws36b_bit3:
	bit 3, iz
	jr z, .Lws36b_bit4
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Cmp
.Lws36b_bit4:
	bit 4, iz
	jr z, .Lws36b_bit5
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Tm
.Lws36b_bit5:
	bit 5, iz
	jr z, .Lws36b_bit6
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Msp
.Lws36b_bit6:
	bit 6, iz
	jr z, .Lws36b_bit7
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Rcm
.Lws36b_bit7:
	bit 7, iz
	jr z, .Lws36b_bit8
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Md
.Lws36b_bit8:
	bit 8, iz
	jr z, .Lws36b_calc
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_DeleteSongPart_Tlx
.Lws36b_calc:
	; Calculate table offset
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_Song_IsUsed
	cp hl, 0xFFFF
	jr nz, .Lws36b_post
	; Push args and call 0x29AEC7
	pushw 0x001A
	pushw 0x0020
	ld wa, (xsp + 8)
	extz xwa
	ld xbc, 0x0000004C
	call HDAE5000_Multiply
	ld xiz, xhl
	ld wa, (xsp + 10)
	extz xwa
	ld xbc, 0x000004C0
	call HDAE5000_Multiply
	add xhl, 0x780
	add xhl, xiz
	ld xwa, HDAE5000_RAM_DirNames
	add xwa, xhl
	push xwa
	call HDAE5000_MemFill
	inc 8, xsp
	; Call workspace handler
	ld wa, (xsp + 6)
	ld bc, (xsp + 4)
	calr HDAE5000_Fls_ForgetSong
.Lws36b_post:
	call HDAE5000_HD_WriteTables_Status
	cpw (xsp + 12), 0x0001
	call nz, (HDAE5000_ATA_Standby_Status:24)
	; Check workspace flag at (xsp+14)
	cpw (xsp + 14), 0x0001
	jr nz, .Lws36b_skip2
	; Workspace dispatch at 0x053C
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_WakeUpMainTask)
	call (xhl)
.Lws36b_skip2:
	; Workspace dispatch at 0xEC
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_PlayStandBy)
	call (xhl)
	; Workspace dispatch at 0xF0
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)
	ld_sril xhl, (xwa + HamaFn_EditSwRefresh)
	call (xhl)
.Lws36b_exit:
	pop xiz
	inc 4, xsp
	retd 4

; --- UI Cell Renderers (9 x 222 bytes each) ---
; Delete table entry: check existence, call handler, clear entry (-1), clear flag (0)
HDAE5000_DeleteSongPart_Lsw:	.include "includes/generated/cc900/HDAE5000_DeleteSongPart_Lsw.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Delete part 1 (PMT) of a song: when slot +40 of the song record is not
; 0xFFFFFFFF, free its chain (HDAE5000_HD_FreeChain), set the slot to
; 0xFFFFFFFF and the part byte +27 to 0.
; In:  WA = directory, BC = song
; Calls: HDAE5000_HD_FreeChain
; ---------------------------------------------------------------------------
HDAE5000_DeleteSongPart_Pmt:	.include "includes/generated/cc900/HDAE5000_DeleteSongPart_Pmt.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Delete part 2 (SQT) of a song: when slot +44 of the song record is not
; 0xFFFFFFFF, free its chain (HDAE5000_HD_FreeChain), set the slot to
; 0xFFFFFFFF and the part byte +28 to 0.
; In:  WA = directory, BC = song
; Calls: HDAE5000_HD_FreeChain
; ---------------------------------------------------------------------------
HDAE5000_DeleteSongPart_Sqt:	.include "includes/generated/cc900/HDAE5000_DeleteSongPart_Sqt.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Delete part 3 (CMP) of a song: when slot +48 of the song record is not
; 0xFFFFFFFF, free its chain (HDAE5000_HD_FreeChain), set the slot to
; 0xFFFFFFFF and the part byte +29 to 0.
; In:  WA = directory, BC = song
; Calls: HDAE5000_HD_FreeChain
; ---------------------------------------------------------------------------
HDAE5000_DeleteSongPart_Cmp:	.include "includes/generated/cc900/HDAE5000_DeleteSongPart_Cmp.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Delete part 4 (TM) of a song: when slot +52 of the song record is not
; 0xFFFFFFFF, free its chain (HDAE5000_HD_FreeChain), set the slot to
; 0xFFFFFFFF and the part byte +30 to 0.
; In:  WA = directory, BC = song
; Calls: HDAE5000_HD_FreeChain
; ---------------------------------------------------------------------------
HDAE5000_DeleteSongPart_Tm:	.include "includes/generated/cc900/HDAE5000_DeleteSongPart_Tm.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Delete part 5 (MSP) of a song: when slot +56 of the song record is not
; 0xFFFFFFFF, free its chain (HDAE5000_HD_FreeChain), set the slot to
; 0xFFFFFFFF and the part byte +31 to 0.
; In:  WA = directory, BC = song
; Calls: HDAE5000_HD_FreeChain
; ---------------------------------------------------------------------------
HDAE5000_DeleteSongPart_Msp:	.include "includes/generated/cc900/HDAE5000_DeleteSongPart_Msp.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Delete part 6 (RCM) of a song: when slot +60 of the song record is not
; 0xFFFFFFFF, free its chain (HDAE5000_HD_FreeChain), set the slot to
; 0xFFFFFFFF and the part byte +32 to 0.
; In:  WA = directory, BC = song
; Calls: HDAE5000_HD_FreeChain
; ---------------------------------------------------------------------------
HDAE5000_DeleteSongPart_Rcm:	.include "includes/generated/cc900/HDAE5000_DeleteSongPart_Rcm.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Delete part 7 (MD) of a song: when slot +64 of the song record is not
; 0xFFFFFFFF, free its chain (HDAE5000_HD_FreeChain), set the slot to
; 0xFFFFFFFF and the part byte +33 to 0.
; In:  WA = directory, BC = song
; Calls: HDAE5000_HD_FreeChain
; ---------------------------------------------------------------------------
HDAE5000_DeleteSongPart_Md:	.include "includes/generated/cc900/HDAE5000_DeleteSongPart_Md.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Delete part 8 (TLX) of a song: when slot +68 of the song record is not
; 0xFFFFFFFF, free its chain (HDAE5000_HD_FreeChain), set the slot to
; 0xFFFFFFFF and the part byte +34 to 0.
; In:  WA = directory, BC = song
; Calls: HDAE5000_HD_FreeChain
; ---------------------------------------------------------------------------
HDAE5000_DeleteSongPart_Tlx:	.include "includes/generated/cc900/HDAE5000_DeleteSongPart_Tlx.s"	; C: cc900/hdae5000_ui_display.c

; ---------------------------------------------------------------------------
; Do the parts of a mask fit on the disk?  Sums their sizes as the main CPU
; reports them (HamaFn_GetResouceInfo per area, HamaFn_SeqSavePre,
; _cmp_sv_mae, _msp_sv_mae; TM counts 0x72AA bytes, TLX 0x5000), converts each
; to clusters (HDAE5000_HD_ClusterCount) and compares the total with the free
; clusters (HDAE5000_HD_CountFreeClusters_Status).
; In:  WA = part mask
; Out: HL = 0 when they fit, else 0xFFFF.
; ---------------------------------------------------------------------------
HDAE5000_Song_CheckFreeSpace:	.include "includes/generated/cc900/HDAE5000_Song_CheckFreeSpace.s"	; C: cc900/hdae5000_song_check.c

; ---------------------------------------------------------------------------
; Round a byte count up to whole 512-byte sectors with HDAE5000_LDiv:
; quotient * 512 + 512 when there is a remainder, the count itself when it
; is already a multiple, and 512 for a count of 0.  Used for part sizes.
; In:  XWA = byte count
; Out: XHL = rounded count.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_RoundUpToSector:	.include "includes/generated/cc900/HDAE5000_RoundUpToSector.s"	; C: cc900/hdae5000_song_module.c

; ---------------------------------------------------------------------------
; Write the filesystem tables to disk inside the main-CPU bracket every
; HD operation uses: HamaFn_PlayHalt(1), HDAE5000_ATA_SoftReset_Status,
; HDAE5000_HD_WriteTables_Status, HDAE5000_ATA_Standby_Status unless WA = 1,
; then HamaFn_PlayStandBy and HamaFn_EditSwRefresh.  PC-link services 10-12
; and 22 call it.
; In:  WA = 1 to leave the drive spinning
; Out: HL = the OR of the three statuses (0 = ok).  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_StoreTables:	.include "includes/generated/cc900/HDAE5000_HD_StoreTables.s"	; C: cc900/hdae5000_hd_tables.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_HD_StoreTables_Join, HDAE5000_HD_StoreTables + 50

; ---------------------------------------------------------------------------
; Read the filesystem tables from disk: the bracket of HDAE5000_HD_StoreTables
; around HDAE5000_HD_ReadTables_Status.  PC-link services 7-9 and
; PPI_Write_Sector call it.
; In:  WA = 1 to leave the drive spinning
; Out: HL = the OR of the statuses (0 = ok).
; ---------------------------------------------------------------------------
HDAE5000_HD_LoadTables:
	dec	2, xsp
	pushw iz
	ld (xsp + 0x02), wa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayHalt)
	ld	wa, 1:i3
	call	(xhl)
	call HDAE5000_ATA_SoftReset_Status
	ld	iz, hl
	call HDAE5000_HD_ReadTables_Status
	or	iz, hl
	cpw	(xsp+2), 0x0001
	jr	z, HDAE5000_HD_LoadTables_Join
	call HDAE5000_ATA_Standby_Status
	or	iz, hl
HDAE5000_HD_LoadTables_Join:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayStandBy)
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_EditSwRefresh)
	call	(xhl)
	ld	hl, iz
	popw iz
	inc 2, xsp
	ret

HDAE5000_HD_RestoreSettings:
	; The HDAE5000_HD_LoadSettings counterpart of HDAE5000_HD_StoreSettings
	; (same main-CPU bracket).  No reference to it was found
	; (scripts/analysis/hdae5000_reachability.py): unreachable.
	dec	2, xsp
	pushw iz
	ld (xsp + 0x02), wa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayHalt)
	ld	wa, 1:i3
	call	(xhl)
	call HDAE5000_ATA_SoftReset_Status
	ld	iz, hl
	call HDAE5000_HD_LoadSettings
	or	iz, hl
	cpw	(xsp+2), 0x0001
	jr	z, HDAE5000_HD_RestoreSettings_Join
	call HDAE5000_ATA_Standby_Status
	or	iz, hl
HDAE5000_HD_RestoreSettings_Join:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayStandBy)
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_EditSwRefresh)
	call	(xhl)
	ld	hl, iz
	popw iz
	inc 2, xsp
	ret

; ---------------------------------------------------------------------------
; Write the settings sector (HDAE5000_HD_SaveSettings) inside the bracket of
; HDAE5000_HD_StoreTables.  Callers: SetupP2SwCatch, AttenHDFormatSwCatch
; (case 6).
; In:  WA = 1 to leave the drive spinning
; Out: HL = the OR of the statuses (0 = ok).
; ---------------------------------------------------------------------------
HDAE5000_HD_StoreSettings:
	dec	2, xsp
	pushw iz
	ld (xsp + 0x02), wa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayHalt)
	ld	wa, 1:i3
	call	(xhl)
	call HDAE5000_ATA_SoftReset_Status
	ld	iz, hl
	call HDAE5000_HD_SaveSettings
	or	iz, hl
	cpw	(xsp+2), 0x0001
	jr	z, HDAE5000_HD_StoreSettings_Join
	call HDAE5000_ATA_Standby_Status
	or	iz, hl
HDAE5000_HD_StoreSettings_Join:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayStandBy)
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_EditSwRefresh)
	call	(xhl)
	ld	hl, iz
	popw iz
	inc 2, xsp
	ret

HDAE5000_RcmStream_Read:
	; Read callback handed to the main CPU by HDAE5000_LoadSong_Rcm (workspace
	; 0x0E88 table +0xB0, with HDAE5000_RcmStream_LastResult): XWA = buffer,
	; XBC = byte count.  The first call (state 0x238F1C = 0) starts
	; HDAE5000_HD_ReadFile on the RCM slot (+60) of song (0x238F1E dir,
	; 0x238F20 song), later calls continue with HDAE5000_HD_ReadFileNext
	; (state 1); the result goes to 0x238F22.  Returns XHL = XBC.
	lda	xsp, (xsp-12)
	push xiz
	ld (xsp + 0x0c), xbc
	ld	bc, (HDAE5000_RAM_RcmStreamState:24)
	cp	bc, 1:i3
	jr	z, HDAE5000_RcmStream_Read_Skip
	cp	bc, 0:i3
	jrl	nz, HDAE5000_RcmStream_Read_Skip2
	ld (xsp + 0x04), xwa
	ld xwa, (xsp + 0x0c)
	ld (xsp + 0x08), xwa
	ld	wa, (HDAE5000_RAM_RcmStreamSong:24)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld	xiz, xhl
	ld	wa, (HDAE5000_RAM_RcmStreamDir:24)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+60:24)
	add	xwa, xhl
	ld	xde, xwa
	ld xwa, (xsp + 0x04)
	ld xbc, (xsp + 0x08)
	call HDAE5000_HD_ReadFile
	ld	(HDAE5000_RAM_RcmStreamResult), hl
	ldw	(HDAE5000_RAM_RcmStreamState:24), 1
	jr	t, HDAE5000_RcmStream_Read_Done
HDAE5000_RcmStream_Read_Skip:
	ld (xsp + 0x04), xwa
	ld xwa, (xsp + 0x0c)
	ld (xsp + 0x08), xwa
	ld	wa, (HDAE5000_RAM_RcmStreamSong:24)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld	xiz, xhl
	ld	wa, (HDAE5000_RAM_RcmStreamDir:24)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+60:24)
	add	xwa, xhl
	ld	xde, xwa
	ld xwa, (xsp + 0x04)
	ld xbc, (xsp + 0x08)
	call HDAE5000_HD_ReadFileNext
	ld	(HDAE5000_RAM_RcmStreamResult), hl
	ldw	(HDAE5000_RAM_RcmStreamState:24), 1
	jr	t, HDAE5000_RcmStream_Read_Done
HDAE5000_RcmStream_Read_Skip2:
	ldw	(HDAE5000_RAM_RcmStreamResult:24), 65535
	ldw	(HDAE5000_RAM_RcmStreamState:24), 0
HDAE5000_RcmStream_Read_Done:
	ld xhl, (xsp + 0x0c)
	pop xiz
	lda	xsp, (xsp+12)
	ret

HDAE5000_RcmStream_Write:
	; Write callback handed to the main CPU by HDAE5000_SaveSong_Rcm (workspace
	; 0x0E88 table +0xB4, after HDAE5000_HD_WriteOpen on the RCM slot): XWA =
	; data, XBC = byte count, through HDAE5000_HD_WriteStream; marks the RCM
	; part byte (+32) of song (0x238F1E, 0x238F20); state 0x238F1C -> 2,
	; result -> 0x238F22.  Returns XHL = XBC.
	dec	6, xsp
	push xiz
	ld (xsp + 0x06), xbc
	ld	bc, (HDAE5000_RAM_RcmStreamState:24)
	cp	bc, 2:i3
	jr	z, HDAE5000_RcmStream_Write_Skip2
	cp	bc, 0:i3
	jrl	nz, HDAE5000_RcmStream_Write_Skip4
	ld xbc, (xsp + 0x06)
	calr	HDAE5000_HD_WriteStream
	cp	hl, 0xffff
	jr	z, HDAE5000_RcmStream_Write_Skip
	ldw (xsp + 0x04), 0
	ld	wa, (HDAE5000_RAM_RcmStreamSong:24)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld	xiz, xhl
	ld	wa, (HDAE5000_RAM_RcmStreamDir:24)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+32:24)
	add	xwa, xhl
	ld	(xwa), 0x01
	ldw	(HDAE5000_RAM_RcmStreamState:24), 2
	jr	t, HDAE5000_RcmStream_Write_Join
HDAE5000_RcmStream_Write_Skip:
	ldw (xsp + 0x04), 65535
HDAE5000_RcmStream_Write_Join:
	ld	wa, (xsp+4)
	ld	(HDAE5000_RAM_RcmStreamResult), wa
	jr	t, HDAE5000_RcmStream_Write_Done
HDAE5000_RcmStream_Write_Skip2:
	ld xbc, (xsp + 0x06)
	calr	HDAE5000_HD_WriteStream
	cp	hl, 0xffff
	jr	z, HDAE5000_RcmStream_Write_Skip3
	ldw (xsp + 0x04), 0
	ld	wa, (HDAE5000_RAM_RcmStreamSong:24)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld	xiz, xhl
	ld	wa, (HDAE5000_RAM_RcmStreamDir:24)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, xiz
	lda xwa, (HDAE5000_RAM_SongRecords-0x780+32:24)
	add	xwa, xhl
	ld	(xwa), 0x01
	ldw	(HDAE5000_RAM_RcmStreamState:24), 2
	jr	t, HDAE5000_RcmStream_Write_Join2
HDAE5000_RcmStream_Write_Skip3:
	ldw (xsp + 0x04), 65535
HDAE5000_RcmStream_Write_Join2:
	ld	wa, (xsp+4)
	ld	(HDAE5000_RAM_RcmStreamResult), wa
	jr	t, HDAE5000_RcmStream_Write_Done
HDAE5000_RcmStream_Write_Skip4:
	ldw	(HDAE5000_RAM_RcmStreamResult:24), 65535
	ldw	(HDAE5000_RAM_RcmStreamState:24), 0
HDAE5000_RcmStream_Write_Done:
	ld xhl, (xsp + 0x06)
	pop xiz
	inc	6, xsp
	ret

HDAE5000_RcmStream_LastResult:	.include "includes/generated/cc900/HDAE5000_RcmStream_LastResult.s"	; C: cc900/hdae5000_ui_display.c

HDAE5000_RcmStream_FreeSpace:
	; XHL = the free-space field of HDAE5000_HD_GetDiskUsage (units of
	; 10,000 bytes) shifted left by 10; handed to the main CPU by
	; HDAE5000_SaveSong_Rcm.
	lda	xsp, (xsp-16)
	lda	xwa, (xsp)
	call HDAE5000_HD_GetDiskUsage
	ld xhl, (xsp + 0x0c)
	sll	xhl, 0x0a
	lda	xsp, (xsp+16)
	ret

; ---------------------------------------------------------------------------
; Describe one in-RAM filesystem table for the PC link: {long address; word
; record width; word record count[; word items]} -- block 0 the directory
; names (HDAE5000_RAM_DirNames, 16, 120: the "FGB" of the service-4 trace),
; 1 the song records (HDAE5000_RAM_SongRecords, 76, 1920: "FEB"), 2 the FLS
; records (HDAE5000_RAM_FlsRecords, 144, 120, 32: "FLS").  Any other block
; returns without storing.  Callers: PC-link services 4-6
; (SendInfosAbout{Dir,FileSystem,Fls}Block).
; In:  WA = block, XBC = destination
; ---------------------------------------------------------------------------
HDAE5000_HD_GetBlockInfo:	.include "includes/generated/cc900/HDAE5000_HD_GetBlockInfo.s"	; C: cc900/hdae5000_ui_display.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_HD_GetBlockInfo_Skip, HDAE5000_HD_GetBlockInfo + 30
	.set	HDAE5000_HD_GetBlockInfo_Skip2, HDAE5000_HD_GetBlockInfo + 48

; ---------------------------------------------------------------------------
; Song information for PC-link service 13 (SendInfosAboutSong): dest+0 =
; HDAE5000_Song_PartMask(dir, song) (when that is 0xFFFF nothing else is
; stored and HL = 0xFFFF), dest+2 = the 16-byte directory name, dest+18 =
; the 26-byte song name, dest+44 = bytes 26..35 of the 76-byte song record
; (song records sit 0x780 bytes after DirNames, 0x4C0 per directory, 0x4C
; per song).
; In:  WA = directory, BC = song, XDE = destination
; Out: HL = 0, or 0xFFFF for an empty song.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_GetSongInfo:	.include "includes/generated/cc900/HDAE5000_HD_GetSongInfo.s"	; C: cc900/hdae5000_song_module.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_HD_GetSongInfo_Epilogue, HDAE5000_HD_GetSongInfo + 195


; ---------------------------------------------------------------------------
; Open a buffered write ("WriteOpenHD", PC-link service 21): keep the slot
; pointer in HDAE5000_RAM_HdStreamSlot (later the XDE of
; HDAE5000_HD_WriteFile / _AppendFile), fill pointer = start of
; HDAE5000_RAM_HdStreamBuffer, state 1 (open, nothing written).  When a write
; was already open the state is reset to 0 instead and HL = 0xFFFF.
; In:  XWA = pointer to the file's first-cluster slot
; Out: HL = 0 (opened) or 0xFFFF.
; ---------------------------------------------------------------------------
HDAE5000_HD_WriteOpen:	.include "includes/generated/cc900/HDAE5000_HD_WriteOpen.s"	; C: cc900/hdae5000_song_module.c

; ---------------------------------------------------------------------------
; Close a buffered write ("WriteCloseHD", PC-link service 22): the bytes
; still in HDAE5000_RAM_HdStreamBuffer go out with HDAE5000_HD_WriteFile
; while HdStreamState is 1 (nothing on disk yet), with
; HDAE5000_HD_AppendFile otherwise; state -> 0.
; Out: clobbers XWA, XBC, XDE, XHL.
; ---------------------------------------------------------------------------
HDAE5000_HD_WriteClose:
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	cp xwa, (HDAE5000_RAM_HdStreamFill:24)
	jr z, .Lds29e_clear
	cp (HDAE5000_RAM_HdStreamState:24), 0x01
	jr nz, .Lds29e_restore
	; State 1: the buffer is the whole file -> HD_WriteFile
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xhl, xwa
	lda xbc, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xwa, (HDAE5000_RAM_HdStreamFill:24)
	sub xwa, xbc
	ld xbc, xwa
	ld xde, (HDAE5000_RAM_HdStreamSlot:24)
	ld xwa, xhl
	call HDAE5000_HD_WriteFile
	ld (HDAE5000_RAM_HdStreamState:24), 0x02
	jr t, .Lds29e_clear
.Lds29e_restore:
	; State 2: earlier chunks written -> HD_AppendFile
	lda xwa, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xhl, xwa
	lda xbc, (HDAE5000_RAM_HdStreamBuffer:24)
	ld xwa, (HDAE5000_RAM_HdStreamFill:24)
	sub xwa, xbc
	ld xbc, xwa
	ld xde, (HDAE5000_RAM_HdStreamSlot:24)
	ld xwa, xhl
	call HDAE5000_HD_AppendFile
.Lds29e_clear:
	ld (HDAE5000_RAM_HdStreamState:24), 0x00
	ret

; ---------------------------------------------------------------------------
; Buffered write ("WriteFileHD", PC-link service 23): copy the source into
; HDAE5000_RAM_HdStreamBuffer at HdStreamFill (HDAE5000_MemCopy pieces of at
; most 0xFFFF bytes); each time the 0x8000-byte buffer fills it goes to disk
; -- HDAE5000_HD_WriteFile the first time (HdStreamState 1 -> 2),
; HDAE5000_HD_AppendFile after that -- and the fill pointer restarts.
; In:  XWA = source, XBC = byte count
; Out: HL = 0; 0xFFFF when no write is open or XBC = 0; a failed disk write's
;      result stops the copy and is returned.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_WriteStream:	.include "includes/generated/cc900/HDAE5000_HD_WriteStream.s"	; C: cc900/hdae5000_fd_stream.c

; ---------------------------------------------------------------------------
; Debug trace, compiled out: the routine is the lone `ret` below.  Its call
; sites load XWA with either a banner "---[ <FunctionName> ]---" (the strings
; in the block under HDAE5000_Display_Params) or a line just formatted into a
; stack buffer with HDAE5000_SPrintf ("FGB wid : %d" ...).  The banners are
; the only surviving developer names of the PC-link services, which is where
; the HDAE5000_PPORT_Svc01..Svc25 names come from.
; In:  XWA = string (ignored)
; ---------------------------------------------------------------------------
HDAE5000_DebugTrace:	.include "includes/generated/cc900/HDAE5000_DebugTrace.s"	; C: cc900/hdae5000_pport_services.c

	; a second one-byte `ret` (0x294415); nothing in this ROM calls or
	; points at it (searched: symbolic references and the literal 0x294415).
	ret

; ---------------------------------------------------------------------------
; PC-link service 1, "GetInfoBlockPointer" (the name is its HDAE5000_DebugTrace
; banner, like every SvcNN name): the address of the info block the PC reads.
; Out: XHL = HDAE5000_RAM_PportInfoBlock
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc01_GetInfoBlockPointer:
	lda	xsp, (xsp-32)
	lda xwa, (HDAE5000_PPORT_Svc01_GetInfoBlockPointer_Str_GetInfoBlockPointer:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_RAM_PportInfoBlock:24)
	push xwa
	pushw HDAE5000_PPORT_Svc01_GetInfoBlockPointer_Str_ppib_adr_Fmtx@hi16
	pushw	HDAE5000_PPORT_Svc01_GetInfoBlockPointer_Str_ppib_adr_Fmtx@lo16		; low half of HDAE5000_PPORT_Svc01_GetInfoBlockPointer_Str_ppib_adr_Fmtx
	lda	xwa, (xsp+8)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc01_GetInfoBlockPointer_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	lda xhl, (HDAE5000_RAM_PportInfoBlock:24)
	lda	xsp, (xsp+32)
	ret

; ---------------------------------------------------------------------------
; PC-link service 2, "TurnHdMotorOff": HDAE5000_ATA_Standby_Status.
; Out: HL = 0, or 1 when the standby failed.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc02_TurnHdMotorOff:
	pushw iz
	ld	iz, 0:i3
	call HDAE5000_ATA_Standby_Status
	cp	hl, 0xffff
	jr	nz, HDAE5000_PPORT_Svc02_TurnHdMotorOff_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc02_TurnHdMotorOff_Join:
	lda xwa, (HDAE5000_PPORT_Svc02_TurnHdMotorOff_Str_TurnHdMotorOff:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc02_TurnHdMotorOff_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 3, "SendInfosAboutHd": HDAE5000_HD_GetGeometry, then into
; HDAE5000_RAM_PportInfoBlock the 30-byte drive model (+0x97), cylinders
; (+0xB5, long), heads (+0xB9), sectors per track (+0xBB), 512 bytes per
; sector (+0xBD), and two bytes copied from RAM 0x23A04A / 0x23A04C (+0xC8,
; +0xC9; their meaning is not established).
; Out: HL = 0
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc03_SendInfosAboutHd:
	lda	xsp, (xsp-116)
	lda	xwa, (xsp+64)
	call HDAE5000_HD_GetGeometry
	pushw 0x001e
	lda	xwa, (xsp+76)
	push xwa
	lda xwa, (HDAE5000_RAM_PportInfoBlock+151:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	ld	wa, (xsp+64)
	extz xwa
	ld	(HDAE5000_RAM_PportInfoBlock+181), xwa
	ld	wa, (xsp+66)
	ld	(HDAE5000_RAM_PportInfoBlock+185), wa
	ld	wa, (xsp+68)
	ld	(HDAE5000_RAM_PportInfoBlock+187), wa
	ldw	(HDAE5000_RAM_PportInfoBlock+189:24), 512
	ld	a, (HDAE5000_RAM_FileFormat_VersionMajor:24)
	ld	(HDAE5000_RAM_PportInfoBlock+200:24), a
	ld	a, (HDAE5000_RAM_FileFormat_VersionMinor:24)
	ld	(HDAE5000_RAM_PportInfoBlock+201:24), a
	lda xwa, (HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_SendInfosAboutHd:24)
	calr	HDAE5000_DebugTrace
	pushw HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddname@hi16
	pushw	HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddname@lo16		; low half of HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddname
	lda	xwa, (xsp+4)
	push xwa
	call HDAE5000_SPrintf
	pushw 0x001e
	lda xwa, (HDAE5000_RAM_PportInfoBlock+151:24)
	push xwa
	lda	xwa, (xsp+24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+18)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	ld	xwa, (HDAE5000_RAM_PportInfoBlock+181)
	push xwa
	pushw HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddtrck_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddtrck_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddtrck_Fmtd
	lda	xwa, (xsp+8)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+185:24)
	pushw HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddhead_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddhead_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddhead_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+187:24)
	pushw HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddsctr_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddsctr_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddsctr_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+189:24)
	pushw HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddscby_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddscby_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_hddscby_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc03_SendInfosAboutHd_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, 0:i3
	lda	xsp, (xsp+116)
	ret

; ---------------------------------------------------------------------------
; PC-link service 4, "SendInfosAboutDirBlock": HDAE5000_HD_GetBlockInfo(0)
; (the directory names: address, record width, count) into
; HDAE5000_RAM_PportInfoBlock+0x2C ("FGB ptr / wid / num" in its trace).
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock:
	lda	xsp, (xsp-74)
	lda	xwa, (xsp+64)
	ld	xbc, xwa
	ld	wa, 0:i3
	call HDAE5000_HD_GetBlockInfo
	ld xwa, (xsp + 0x40)
	ld	(HDAE5000_RAM_PportInfoBlock+44), xwa
	ld	wa, (xsp+68)
	ld	(HDAE5000_RAM_PportInfoBlock+48), wa
	ld	wa, (xsp+70)
	ld	(HDAE5000_RAM_PportInfoBlock+50), wa
	lda xwa, (HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_SendInfosAboutDirBlock:24)
	calr	HDAE5000_DebugTrace
	ld	xwa, (HDAE5000_RAM_PportInfoBlock+44)
	push xwa
	pushw HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_ptr_Fmtx@hi16
	pushw	HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_ptr_Fmtx@lo16		; low half of HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_ptr_Fmtx
	lda	xwa, (xsp+8)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+48:24)
	pushw HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_wid_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_wid_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_wid_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+50:24)
	pushw HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_num_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_num_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_FGB_num_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	lda	xsp, (xsp+74)
	ret

; ---------------------------------------------------------------------------
; PC-link service 5, "SendInfosAboutFileSystemBlock": HDAE5000_HD_GetBlockInfo(1)
; (the song records) into HDAE5000_RAM_PportInfoBlock+0x34 ("FEB ...").
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock:
	lda	xsp, (xsp-74)
	lda	xwa, (xsp+64)
	ld	xbc, xwa
	ld	wa, 1:i3
	call HDAE5000_HD_GetBlockInfo
	ld xwa, (xsp + 0x40)
	ld	(HDAE5000_RAM_PportInfoBlock+52), xwa
	ld	wa, (xsp+68)
	ld	(HDAE5000_RAM_PportInfoBlock+56), wa
	ld	wa, (xsp+70)
	ld	(HDAE5000_RAM_PportInfoBlock+58), wa
	lda xwa, (HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_SendInfosAboutFileSystemBlock:24)
	calr	HDAE5000_DebugTrace
	ld	xwa, (HDAE5000_RAM_PportInfoBlock+52)
	push xwa
	pushw HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_ptr_Fmtx@hi16
	pushw	HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_ptr_Fmtx@lo16		; low half of HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_ptr_Fmtx
	lda	xwa, (xsp+8)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+56:24)
	pushw HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_wid_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_wid_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_wid_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+58:24)
	pushw HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_num_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_num_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_FEB_num_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	lda	xsp, (xsp+74)
	ret

; ---------------------------------------------------------------------------
; PC-link service 6, "SendInfosAboutFlsBlock": HDAE5000_HD_GetBlockInfo(2)
; (the FLS records, with their item count) into
; HDAE5000_RAM_PportInfoBlock+0x3C ("FLS ptr / wid / num / ent").
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock:
	lda	xsp, (xsp-74)
	lda	xwa, (xsp+64)
	ld	xbc, xwa
	ld	wa, 2:i3
	call HDAE5000_HD_GetBlockInfo
	ld xwa, (xsp + 0x40)
	ld	(HDAE5000_RAM_PportInfoBlock+60), xwa
	ld	wa, (xsp+68)
	ld	(HDAE5000_RAM_PportInfoBlock+64), wa
	ld	wa, (xsp+70)
	ld	(HDAE5000_RAM_PportInfoBlock+66), wa
	ld	wa, (xsp+72)
	ld	(HDAE5000_RAM_PportInfoBlock+68), wa
	lda xwa, (HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_SendInfosAboutFlsBlock:24)
	calr	HDAE5000_DebugTrace
	ld	xwa, (HDAE5000_RAM_PportInfoBlock+60)
	push xwa
	pushw HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_ptr_Fmtx@hi16
	pushw	HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_ptr_Fmtx@lo16		; low half of HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_ptr_Fmtx
	lda	xwa, (xsp+8)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+64:24)
	pushw HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_wid_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_wid_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_wid_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+66:24)
	pushw HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_num_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_num_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_num_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	pushw	(HDAE5000_RAM_PportInfoBlock+68:24)
	pushw HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_ent_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_ent_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_FLS_ent_Fmtd
	lda	xwa, (xsp+6)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	lda	xsp, (xsp+74)
	ret

; ---------------------------------------------------------------------------
; PC-link service 7, "ReadDirBlockFromHd": HDAE5000_HD_LoadTables(1) -- all
; the tables are read; services 8 and 9 do exactly the same.
; Out: HL = 0, or 1 when the load failed.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc07_ReadDirBlockFromHd:
	pushw iz
	ld	iz, 0:i3
	ld	wa, 1:i3
	call HDAE5000_HD_LoadTables
	cp	hl, 0xffff
	jr	nz, HDAE5000_PPORT_Svc07_ReadDirBlockFromHd_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc07_ReadDirBlockFromHd_Join:
	lda xwa, (HDAE5000_PPORT_Svc07_ReadDirBlockFromHd_Str_ReadDirBlockFromHd:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc07_ReadDirBlockFromHd_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 8, "ReadFileBlockFromHd": HDAE5000_HD_LoadTables(1), as
; service 7.
; Out: HL = 0, or 1 when the load failed.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc08_ReadFileBlockFromHd:
	pushw iz
	ld	iz, 0:i3
	ld	wa, 1:i3
	call HDAE5000_HD_LoadTables
	cp	hl, 0xffff
	jr	nz, HDAE5000_PPORT_Svc08_ReadFileBlockFromHd_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc08_ReadFileBlockFromHd_Join:
	lda xwa, (HDAE5000_PPORT_Svc08_ReadFileBlockFromHd_Str_ReadFileBlockFromHd:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc08_ReadFileBlockFromHd_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 9, "ReadFlsBlockFromHd": HDAE5000_HD_LoadTables(1), as
; service 7.
; Out: HL = 0, or 1 when the load failed.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd:
	pushw iz
	ld	iz, 0:i3
	ld	wa, 1:i3
	call HDAE5000_HD_LoadTables
	cp	hl, 0xffff
	jr	nz, HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd_Join:
	lda xwa, (HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd_Str_ReadFlsBlockFromHd:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 10, "WriteDirBlockToHd": HDAE5000_HD_StoreTables(1) -- all
; the tables are written; services 11 and 12 do exactly the same.
; Out: HL = 0, or 1 when the store failed.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc10_WriteDirBlockToHd:
	pushw iz
	ld	iz, 0:i3
	ld	wa, 1:i3
	call HDAE5000_HD_StoreTables
	cp	hl, 0xffff
	jr	nz, HDAE5000_PPORT_Svc10_WriteDirBlockToHd_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc10_WriteDirBlockToHd_Join:
	lda xwa, (HDAE5000_PPORT_Svc10_WriteDirBlockToHd_Str_WriteDirBlockToHd:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc10_WriteDirBlockToHd_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 11, "WriteFileSystemBlockToHd": HDAE5000_HD_StoreTables(1),
; as service 10.
; Out: HL = 0, or 1 when the store failed.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd:
	pushw iz
	ld	iz, 0:i3
	ld	wa, 1:i3
	call HDAE5000_HD_StoreTables
	cp	hl, 0xffff
	jr	nz, HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd_Join:
	lda xwa, (HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd_Str_WriteFileSystemBlockToHd:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 12, "WriteFlsBlockToHd": HDAE5000_HD_StoreTables(1), as
; service 10.
; Out: HL = 0, or 1 when the store failed.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc12_WriteFlsBlockToHd:
	pushw iz
	ld	iz, 0:i3
	ld	wa, 1:i3
	call HDAE5000_HD_StoreTables
	cp	hl, 0xffff
	jr	nz, HDAE5000_PPORT_Svc12_WriteFlsBlockToHd_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc12_WriteFlsBlockToHd_Join:
	lda xwa, (HDAE5000_PPORT_Svc12_WriteFlsBlockToHd_Str_WriteFlsBlockToHd:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc12_WriteFlsBlockToHd_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 13, "SendInfosAboutSong": fill HDAE5000_RAM_PportInfoBlock
; for one song.  The names (+2, 26 bytes; +0x1C, 16 bytes) are blanked and
; the part mask zeroed; then one 9-byte record per part from +0x46 {long
; address; long size; byte present} out of HamaFn_GetResouceInfo(part) --
; with the sizes of parts 3, 5 and 7 taken from HamaFn_SeqSavePre (added),
; HamaFn_cmp_sv_mae and HamaFn_msp_sv_mae, 0x72AA for part 6, 0xAD000 for
; part 8, and HDAE5000_TlxPart_Describe for the lyrics (+0xBF).  When
; HDAE5000_HD_GetSongInfo finds the song, the mask, both names and the nine
; present bytes come from it.
; In:  WA = directory, BC = song
; Out: HL = 0 when the song exists, 1 when it does not.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc13_SendInfosAboutSong:
	lda	xsp, (xsp-128)
	push xiz
	ld	(xsp+130), bc
	ld	iz, wa
	ld	qiz, 1
	ldw	(HDAE5000_RAM_PportInfoBlock:24), 0
	pushw 0x0010
	pushw 0x0020
	lda xwa, (HDAE5000_RAM_PportInfoBlock+28:24)
	push xwa
	call HDAE5000_MemFill
	pushw 0x001a
	pushw 0x0020
	lda xwa, (HDAE5000_RAM_PportInfoBlock+2:24)
	push xwa
	call HDAE5000_MemFill
	lda	xsp, (xsp+16)
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 0:i3
	call	(xhl)
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+70), xwa
	ld xwa, (xsp + 0x48)
	ld	(HDAE5000_RAM_PportInfoBlock+74), xwa
	ld	(HDAE5000_RAM_PportInfoBlock+78:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 1:i3
	call	(xhl)
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+79), xwa
	ld xwa, (xsp + 0x48)
	ld	(HDAE5000_RAM_PportInfoBlock+83), xwa
	ld	(HDAE5000_RAM_PportInfoBlock+87:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 2:i3
	call	(xhl)
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+88), xwa
	ld xwa, (xsp + 0x48)
	ld	(HDAE5000_RAM_PportInfoBlock+92), xwa
	ld	(HDAE5000_RAM_PportInfoBlock+96:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 3:i3
	call	(xhl)
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+97), xwa
	ld xwa, (xsp + 0x48)
	ld	(HDAE5000_RAM_PportInfoBlock+101), xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xix, (xwa + HamaFn_SeqSavePre)
	call	(xix)
	add	(HDAE5000_RAM_PportInfoBlock+101:24), xhl
	ld	(HDAE5000_RAM_PportInfoBlock+105:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 5:i3
	call	(xhl)
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+106), xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xix, (xwa + HamaFn_cmp_sv_mae)
	call	(xix)
	ld	(HDAE5000_RAM_PportInfoBlock+110), xhl
	ld	(HDAE5000_RAM_PportInfoBlock+114:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 6:i3
	call	(xhl)
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+115), xwa
	ld	xwa, 0x000072aa
	ld	(HDAE5000_RAM_PportInfoBlock+119), xwa
	ld	(HDAE5000_RAM_PportInfoBlock+123:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ld	wa, 7:i3
	call	(xhl)
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+124), xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xix, (xwa + HamaFn_msp_sv_mae)
	call	(xix)
	ld	(HDAE5000_RAM_PportInfoBlock+128), xhl
	ld	(HDAE5000_RAM_PportInfoBlock+132:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ldw	wa, 0x0008
	call	(xhl)
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+133), xwa
	ld	xwa, 0x000ad000
	ld	(HDAE5000_RAM_PportInfoBlock+137), xwa
	ld	(HDAE5000_RAM_PportInfoBlock+141:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_GetResouceInfo)
	ldw	wa, 0x0009
	call	(xhl)
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+142), xwa
	ld xwa, (xsp + 0x48)
	ld	(HDAE5000_RAM_PportInfoBlock+146), xwa
	ld	(HDAE5000_RAM_PportInfoBlock+150:24), 0
	lda	xwa, (xsp+68)
	ld	xbc, xwa
	ldw	wa, 0x000a
	call HDAE5000_TlxPart_Describe
	ld xwa, (xsp + 0x44)
	ld	(HDAE5000_RAM_PportInfoBlock+191), xwa
	ld xwa, (xsp + 0x48)
	ld	(HDAE5000_RAM_PportInfoBlock+195), xwa
	ld	(HDAE5000_RAM_PportInfoBlock+199:24), 0
	lda	xwa, (xsp+76)
	ld	xde, xwa
	ld	wa, iz
	ld	bc, (xsp+130)
	call HDAE5000_HD_GetSongInfo
	cp	hl, 0xffff
	jr	z, HDAE5000_PPORT_Svc13_SendInfosAboutSong_Join
	ld	wa, (xsp+76)
	ld	(HDAE5000_RAM_PportInfoBlock), wa
	pushw 0x0010
	lda	xwa, (xsp+80)
	push xwa
	lda xwa, (HDAE5000_RAM_PportInfoBlock+28:24)
	push xwa
	call HDAE5000_MemCopy
	pushw 0x001a
	lda	xwa, (xsp+106)
	push xwa
	lda xwa, (HDAE5000_RAM_PportInfoBlock+2:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+20)
	ld	a, (xsp+120)
	ld	(HDAE5000_RAM_PportInfoBlock+78:24), a
	ld	a, (xsp+121)
	ld	(HDAE5000_RAM_PportInfoBlock+96:24), a
	ld	a, (xsp+122)
	ld	(HDAE5000_RAM_PportInfoBlock+105:24), a
	ld	a, (xsp+123)
	ld	(HDAE5000_RAM_PportInfoBlock+114:24), a
	ld	a, (xsp+124)
	ld	(HDAE5000_RAM_PportInfoBlock+123:24), a
	ld	a, (xsp+125)
	ld	(HDAE5000_RAM_PportInfoBlock+132:24), a
	ld	a, (xsp+126)
	ld	(HDAE5000_RAM_PportInfoBlock+141:24), a
	ld	a, (xsp+127)
	ld	(HDAE5000_RAM_PportInfoBlock+150:24), a
	ld	a, (xsp+128)
	ld	(HDAE5000_RAM_PportInfoBlock+199:24), a
	ld	qiz, 0
HDAE5000_PPORT_Svc13_SendInfosAboutSong_Join:
	lda xwa, (HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_SendInfosAboutSong:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_RAM_PportInfoBlock+28:24)
	push xwa
	pushw HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_dirname_Fmts@hi16
	pushw	HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_dirname_Fmts@lo16		; low half of HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_dirname_Fmts
	lda	xwa, (xsp+12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	lda	xwa, (xsp+4)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_RAM_PportInfoBlock+2:24)
	push xwa
	pushw HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_sngname_Fmts@hi16
	pushw	HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_sngname_Fmts@lo16		; low half of HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_sngname_Fmts
	lda	xwa, (xsp+12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	lda	xwa, (xsp+4)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc13_SendInfosAboutSong_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, qiz
	pop xiz
	lda xsp, (xsp+128:16)
	ret

; ---------------------------------------------------------------------------
; PC-link service 14, "LoadSongFromHdToMemory": HDAE5000_LoadSong(WA, BC,
; part mask = PportInfoBlock+0, stacked words 1, 0).
; In:  WA = directory, BC = song
; Out: HL = 0, or 1 when LoadSong returned 0xFFFF.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory:
	pushw iz
	ld	iz, 0:i3
	pushw 0x0000
	pushw 0x0001
	ld	de, (HDAE5000_RAM_PportInfoBlock:24)
	call HDAE5000_LoadSong
	cp	hl, 0xffff
	jr	nz, HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory_Join:
	lda xwa, (HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory_Str_LoadSongFromHdToMemory:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 15, "SaveSongInMemoryToHd": HDAE5000_SaveSong(WA, BC,
; XDE = the song name at PportInfoBlock+2, stacked words 1, 0 and the part
; mask from PportInfoBlock+0, in argument order).
; In:  WA = directory, BC = song
; Out: HL = 0, or 1 when SaveSong returned 0xFFFF.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd:
	pushw iz
	ld	iz, 0:i3
	lda xde, (HDAE5000_RAM_PportInfoBlock+2:24)
	pushw	(HDAE5000_RAM_PportInfoBlock:24)
	pushw 0x0000
	pushw 0x0001
	call HDAE5000_SaveSong
	cp	hl, 0xffff
	jr	nz, HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd_Join:
	lda xwa, (HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd_Str_SaveSongInMemoryToHd:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 16, "InitWholeSongInMemory": for every part bit set in
; PportInfoBlock+0, the main CPU's post-load hook with WA = 0 --
; HamaFn_PostLswLoad (bit 0), _PostPmLoad (1), _SeqLoadPost (2, followed by
; an EVT_ACTIVATE_STATE send through the workspace's 0x11FA object),
; _cmp_ld_ato (3), _PostTmLoad (4), _msp_ld_ato (5), _PostMidiLoad (7).
; Ends with a tail jump to HDAE5000_DebugTrace.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc16_InitWholeSongInMemory:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x00, wa
	jr	z, HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_PostLswLoad)
	ld	wa, 0:i3
	call	(xhl)
HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x01, wa
	jr	z, HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join2
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_PostPmLoad)
	ld	wa, 0:i3
	call	(xhl)
HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join2:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x02, wa
	jr	z, HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join3
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_SeqLoadPost)
	ld	wa, 0:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + 0x11fa)
	ld xhl, (xwa + 0x18)
	ld	xwa, 0xffffffff
	ld	xbc, EVT_ACTIVATE_STATE
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join3:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x03, wa
	jr	z, HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join4
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_cmp_ld_ato)
	ld	wa, 0:i3
	call	(xhl)
HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join4:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x04, wa
	jr	z, HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join5
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_PostTmLoad)
	ld	wa, 0:i3
	call	(xhl)
HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join5:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x05, wa
	jr	z, HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join6
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_msp_ld_ato)
	ld	wa, 0:i3
	call	(xhl)
HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join6:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x07, wa
	jr	z, HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join7
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_PostMidiLoad)
	ld	wa, 0:i3
	call	(xhl)
HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Join7:
	lda xwa, (HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Str_InitWholeSongInMemory:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc16_InitWholeSongInMemory_Str_Blank1:24)
	jrl	t, HDAE5000_DebugTrace

; ---------------------------------------------------------------------------
; PC-link service 17, "FormatHd": HDAE5000_HD_FormatDrive(0) (the main task
; keeps running).
; Out: HL = 0, or 1 when the format failed.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc17_FormatHd:
	pushw iz
	ld	iz, 0:i3
	ld	wa, 0:i3
	call HDAE5000_HD_FormatDrive
	cp	hl, 0:i3
	jr	z, HDAE5000_PPORT_Svc17_FormatHd_Join
	ld	iz, 1:i3
HDAE5000_PPORT_Svc17_FormatHd_Join:
	lda xwa, (HDAE5000_PPORT_Svc17_FormatHd_Str_FormatHd:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc17_FormatHd_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 18 (no trace banner): tail-jumps to RootFn_ApPostEvent
; with XWA = 0xFFFFFFFF, XBC = EVT_CHANGE_MODE, XDE = NAKA_MODE_MD_NORMAL --
; the mode request the main CPU's own boot makes (HDAE5000_RequestMode does
; the same after cancelling a queued one).
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc18_RequestNormalMode:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, 0xffffffff
	ld	xbc, EVT_CHANGE_MODE
	ld	xde, NAKA_MODE_MD_NORMAL
	jp	(xhl)

; ---------------------------------------------------------------------------
; PC-link service 19, "SendPointerToFreeBufferSpace": the address of
; PportInfoBlock+0xCA, printed by its trace as "work adr".
; Out: XHL = HDAE5000_RAM_PportInfoBlock+202
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace:
	lda	xsp, (xsp-64)
	lda xwa, (HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace_Str_SendPointerToFreeBufferSpace:24)
	calr	HDAE5000_DebugTrace
	ld	xwa, 0:i3
	ld	a, (HDAE5000_RAM_PportInfoBlock+202:24)
	push xwa
	pushw HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace_Str_work_adr_Fmtx@hi16
	pushw	HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace_Str_work_adr_Fmtx@lo16		; low half of HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace_Str_work_adr_Fmtx
	lda	xwa, (xsp+8)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	lda xwa, (HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace_Str_Blank1:24)
	calr	HDAE5000_DebugTrace
	lda xhl, (HDAE5000_RAM_PportInfoBlock+202:24)
	lda	xsp, (xsp+64)
	ret

; ---------------------------------------------------------------------------
; PC-link service 20, "PreWholeSongInMemory": for every part bit set in
; PportInfoBlock+0, the main CPU's pre-load hook -- HamaFn_PreLswLoad (bit
; 0), _PrePmLoad (1), _SeqLoadPre (2), _cmp_ld_mae (3), _PreTmLoad (4),
; _msp_ld_mae (5), _PreMidiLoad (7).  The counterpart of service 16.  Ends
; with a tail jump to HDAE5000_DebugTrace.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc20_PreWholeSongInMemory:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x00, wa
	jr	z, HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_PreLswLoad)
	call	(xhl)
HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x01, wa
	jr	z, HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join2
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_PrePmLoad)
	call	(xhl)
HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join2:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x02, wa
	jr	z, HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join3
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_SeqLoadPre)
	call	(xhl)
HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join3:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x03, wa
	jr	z, HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join4
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_cmp_ld_mae)
	call	(xhl)
HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join4:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x04, wa
	jr	z, HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join5
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_PreTmLoad)
	call	(xhl)
HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join5:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x05, wa
	jr	z, HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join6
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_msp_ld_mae)
	call	(xhl)
HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join6:
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	bit	0x07, wa
	jr	z, HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join7
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld xhl, (xwa + HamaFn_PreMidiLoad)
	call	(xhl)
HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Join7:
	lda xwa, (HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Str_PreWholeSongInMemory:24)
	calr	HDAE5000_DebugTrace
	lda xwa, (HDAE5000_PPORT_Svc20_PreWholeSongInMemory_Str_Blank1:24)
	jrl	t, HDAE5000_DebugTrace

; ---------------------------------------------------------------------------
; PC-link service 21, "WriteOpenHD": for the lowest part k (0..8) whose bit
; is set in PportInfoBlock+0, open a buffered write (HDAE5000_HD_WriteOpen)
; on that part's first-cluster slot (+36 + 4k of the song record); when it
; opens, copy the 26-byte song name from PportInfoBlock+2 into the record and
; set the record's part flag (+26 + k) to 1.
; In:  WA = directory, BC = song
; Out: HL = 0 when a write was opened, else 1.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc21_WriteOpenHD:
	lda	xsp, (xsp-28)
	push xiz
	ld (xsp + 0x1c), bc
	ld (xsp + 0x1e), wa
	ldw (xsp + 0x04), 1
	lda xwa, (HDAE5000_PPORT_Svc21_WriteOpenHD_Str_WriteOpenHD:24)
	calr	HDAE5000_DebugTrace
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	ld	(xsp+6), 0x00
	cp	(xsp+6), 0x09
	jrl	nc, HDAE5000_PPORT_Svc21_WriteOpenHD_Done
HDAE5000_PPORT_Svc21_WriteOpenHD_Loop:
	bit	0x00, wa
	jrl	z, HDAE5000_PPORT_Svc21_WriteOpenHD_Next
	ld	wa, (xsp+28)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld	xiz, xhl
	ld	wa, (xsp+30)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, xiz
	ld	xbc, HDAE5000_RAM_DirNames
	add	xbc, xhl
	ld	a, (xsp+6)
	extz wa
	sla	wa, 0x02
	add	wa, 0x0024
	exts xwa
	add	xwa, xbc
	call HDAE5000_HD_WriteOpen
	cp	hl, 0xffff
	jr	z, HDAE5000_PPORT_Svc21_WriteOpenHD_Join
	pushw 0x001a
	lda xwa, (HDAE5000_RAM_PportInfoBlock+2:24)
	push xwa
	ld	wa, (xsp+34)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld	xiz, xhl
	ld	wa, (xsp+36)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, xiz
	ld	xwa, HDAE5000_RAM_DirNames
	add	xwa, xhl
	push xwa
	call HDAE5000_StrNCpy
	lda	xsp, (xsp+10)
	ld	wa, (xsp+28)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld	xiz, xhl
	ld	wa, (xsp+30)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, xiz
	ld	xbc, HDAE5000_RAM_DirNames
	add	xbc, xhl
	ld	a, (xsp+6)
	extz wa
	add	wa, 0x001a
	ld	(xbc+wa), 0x01
	ldw (xsp + 0x04), 0
HDAE5000_PPORT_Svc21_WriteOpenHD_Join:
	ld	a, (xsp+6)
	extz wa
	pushw wa
	pushw HDAE5000_PPORT_Svc21_WriteOpenHD_Str_SUFFIX_Fmtd@hi16
	pushw	HDAE5000_PPORT_Svc21_WriteOpenHD_Str_SUFFIX_Fmtd@lo16		; low half of HDAE5000_PPORT_Svc21_WriteOpenHD_Str_SUFFIX_Fmtd
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+10)
	lda	xwa, (xsp+8)
	calr	HDAE5000_DebugTrace
	jr	t, HDAE5000_PPORT_Svc21_WriteOpenHD_Done
HDAE5000_PPORT_Svc21_WriteOpenHD_Next:
	srl	wa, 0x01
	incm8	1, (xsp+6)
	cp	(xsp+6), 0x09
	jrl	c, HDAE5000_PPORT_Svc21_WriteOpenHD_Loop
HDAE5000_PPORT_Svc21_WriteOpenHD_Done:
	ld	hl, (xsp+4)
	pop xiz
	lda	xsp, (xsp+28)
	ret

; ---------------------------------------------------------------------------
; PC-link service 22, "WriteCloseHD": HDAE5000_HD_WriteClose, then the tables
; to disk (HDAE5000_HD_StoreTables(1)).
; Out: HL = 0 when both succeeded, else 1.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc22_WriteCloseHD:
	pushw iz
	ld	iz, 1:i3
	call HDAE5000_HD_WriteClose
	cp	hl, 0xffff
	jr	z, HDAE5000_PPORT_Svc22_WriteCloseHD_Join
	ld	wa, 1:i3
	call HDAE5000_HD_StoreTables
	cp	hl, 0xffff
	jr	z, HDAE5000_PPORT_Svc22_WriteCloseHD_Join
	ld	iz, 0:i3
HDAE5000_PPORT_Svc22_WriteCloseHD_Join:
	lda xwa, (HDAE5000_PPORT_Svc22_WriteCloseHD_Str_WriteCloseHD:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 23, "WriteFileHD": HDAE5000_HD_WriteStream(XWA, XBC).
; In:  XWA = source, XBC = byte count
; Out: HL = 0 when the bytes were taken, else 1.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc23_WriteFileHD:
	pushw iz
	ld	iz, 1:i3
	call HDAE5000_HD_WriteStream
	cp	hl, 0xffff
	jr	z, HDAE5000_PPORT_Svc23_WriteFileHD_Join
	ld	iz, 0:i3
HDAE5000_PPORT_Svc23_WriteFileHD_Join:
	lda xwa, (HDAE5000_PPORT_Svc23_WriteFileHD_Str_WriteFileHD:24)
	calr	HDAE5000_DebugTrace
	ld	hl, iz
	popw iz
	ret

; ---------------------------------------------------------------------------
; PC-link service 24, "ReadOpenHD": for the lowest part k (0..8) whose bit is
; set in PportInfoBlock+0, keep the address of the song record's slot (+36 +
; 4k) in PportInfoBlock+0xCE and set HDAE5000_RAM_PportReadState = 1.
; In:  WA = directory, BC = song
; Out: HL = 0 when a part was found, else 1.  QIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc24_ReadOpenHD:
	dec 8, xsp
	push	qiz
	ld (xsp + 0x06), bc
	ld (xsp + 0x08), wa
	ldw (xsp + 0x04), 1
	lda xwa, (HDAE5000_PPORT_Svc24_ReadOpenHD_Str_ReadOpenHD:24)
	calr	HDAE5000_DebugTrace
	ld	wa, (HDAE5000_RAM_PportInfoBlock:24)
	ldib_erp 0xfb, 0		; ld QIZH,0
	cp_erpb 0xfb, 0x09		; cp QIZH,0x09
	jr	nc, HDAE5000_PPORT_Svc24_ReadOpenHD_Done
HDAE5000_PPORT_Svc24_ReadOpenHD_Loop:
	bit	0x00, wa
	jr	z, HDAE5000_PPORT_Svc24_ReadOpenHD_Next
	ld	wa, (xsp+6)
	extz xwa
	ld	xbc, 0x0000004c
	call HDAE5000_Multiply
	ld (xsp + 0x02), xhl
	ld	wa, (xsp+8)
	extz xwa
	ld	xbc, 0x000004c0
	call HDAE5000_Multiply
	add	xhl, 0x00000780
	add	xhl, (xsp+2)
	ld	xbc, HDAE5000_RAM_DirNames
	add	xbc, xhl
	ldto_berp a, 0xfb		; ld A,QIZH
	extz wa
	sla	wa, 0x02
	add	wa, 0x0024
	exts xwa
	add	xwa, xbc
	ld	(HDAE5000_RAM_PportInfoBlock+206), xwa
	ld	(HDAE5000_RAM_PportReadState:24), 1
	ldw (xsp + 0x04), 0
	jr	t, HDAE5000_PPORT_Svc24_ReadOpenHD_Done
HDAE5000_PPORT_Svc24_ReadOpenHD_Next:
	srl	wa, 0x01
	incb_erp 0xfb, 1		; inc 1,QIZH
	cp_erpb 0xfb, 0x09		; cp QIZH,0x09
	jr	c, HDAE5000_PPORT_Svc24_ReadOpenHD_Loop
HDAE5000_PPORT_Svc24_ReadOpenHD_Done:
	ld	hl, (xsp+4)
	pop	qiz
	inc 8, xsp
	ret

; ---------------------------------------------------------------------------
; PC-link service 25, "ReadFileHD": with HDAE5000_RAM_PportReadState 1,
; HDAE5000_HD_ReadFile from the slot service 24 chose (state -> 2); with
; state 2, HDAE5000_HD_ReadFileNext; any other state is reset to 0.
; In:  XWA = destination, XBC = byte count
; Out: HL = 0 when the read succeeded, else 1.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc25_ReadFileHD:
	dec	6, xsp
	push xiz
	ld (xsp + 0x06), xbc
	ld	xiz, xwa
	ldw (xsp + 0x04), 1
	lda xwa, (HDAE5000_PPORT_Svc25_ReadFileHD_Str_ReadFileHD:24)
	calr	HDAE5000_DebugTrace
	cp	(HDAE5000_RAM_PportReadState:24), 1
	jr	nz, HDAE5000_PPORT_Svc25_ReadFileHD_Skip
	ld	(HDAE5000_RAM_PportReadState:24), 2
	ld	xwa, xiz
	ld xbc, (xsp + 0x06)
	ld	xde, (HDAE5000_RAM_PportInfoBlock+206)
	call HDAE5000_HD_ReadFile
	cp	hl, 0xffff
	jr	z, HDAE5000_PPORT_Svc25_ReadFileHD_Done
	ldw (xsp + 0x04), 0
	jr	t, HDAE5000_PPORT_Svc25_ReadFileHD_Done
HDAE5000_PPORT_Svc25_ReadFileHD_Skip:
	cp	(HDAE5000_RAM_PportReadState:24), 2
	jr	nz, HDAE5000_PPORT_Svc25_ReadFileHD_Skip2
	ld	xwa, xiz
	ld xbc, (xsp + 0x06)
	ld	xde, (HDAE5000_RAM_PportInfoBlock+206)
	call HDAE5000_HD_ReadFileNext
	cp	hl, 0xffff
	jr	z, HDAE5000_PPORT_Svc25_ReadFileHD_Done
	ldw (xsp + 0x04), 0
	jr	t, HDAE5000_PPORT_Svc25_ReadFileHD_Done
HDAE5000_PPORT_Svc25_ReadFileHD_Skip2:
	ld	(HDAE5000_RAM_PportReadState:24), 0
HDAE5000_PPORT_Svc25_ReadFileHD_Done:
	ld	hl, (xsp+4)
	pop xiz
	inc	6, xsp
	ret


; ---------------------------------------------------------------------------
; PC-link service 27 (no trace banner): HDAE5000_DeleteSongParts(WA, BC,
; DE = the part mask at PportInfoBlock+0, stacked words 1, 0).
; In:  WA = directory, BC = song (passed through)
; Out: HL = 0
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Svc27_DeleteSongParts:
	pushw 0x0000
	pushw 0x0001
	ld de, (HDAE5000_RAM_PportInfoBlock:24)
	call HDAE5000_DeleteSongParts
	ld hl, 0:i3
	ret
	nop

; ============================================================================
; PC-LINK (PPORT) COROUTINE
; The parallel-port link to HD-TechManager runs as a second execution context
; with its own stack, switched by swapping XSP through two RAM slots:
;   0x239002  the link context's saved XSP   0x239006  the main context's
;   0x239000  1 = link active                0x239014  1 = service requested
;   0x23900A  service number (WA); -1 once the link has ended
;   0x23900C  argument XBC                   0x239010  argument XDE
; HDAE5000_PPORT_StartLink builds the link stack at 0x23FFFC with
; HDAE5000_PPORT_LinkEntry as its return address and switches to it.  The
; link never touches the HD itself: HDAE5000_PPORT_CallService posts a
; service number in the mailbox and yields; HDAE5000_PPORT_ServicePending
; (entered from the end of HDAE5000_Frame_Handler, via its _Exit jp) runs it on the
; main context and switches back.  Service 0 is an empty `ret`, so
; CallService(0) is a plain "yield until next frame" (the link's polling
; loops use it).
; ============================================================================
HDAE5000_PPORT_ServicePending:
	; main context, once per frame-handler pass: if a link is active, run the service it
	; posted (HDAE5000_PPORT_ServiceDispatch) and resume it
	; (HDAE5000_PPORT_ReturnToLink).
	; PPORT state machine entry - check active, load params, dispatch
	cp (HDAE5000_RAM_PportLinkActive:24), 0x01	; check if PPORT active
	jr nz, .Lpph_done
	ld wa, (HDAE5000_RAM_PportService:24)
	nop
	ld xbc, (HDAE5000_RAM_PportServiceArgBc:24)
	nop
	ld xde, (HDAE5000_RAM_PportServiceArgDe:24)
	nop
	call HDAE5000_PPORT_ServiceDispatch
	call HDAE5000_PPORT_ReturnToLink
.Lpph_done:
	ret
	nop
	; --- Secondary entry: menu init ---
HDAE5000_PPORT_LinkEntry:
	; first code the link context runs (HDAE5000_PPORT_StartLink plants this
	; address at the top of the link stack); when the link program returns,
	; it yields for good with the request flag clear, which
	; HDAE5000_PPORT_ReturnToLink / _StartLink read as "link finished".
	call HDAE5000_PPORT_LinkMain
	jr t, HDAE5000_PPORT_YieldToMain

; ---------------------------------------------------------------------------
; Main -> link: save XSP in HDAE5000_RAM_PportMainSp, load the link's from
; HDAE5000_RAM_PportLinkSp; the `ret` resumes the link wherever it last
; yielded.  Interrupts are masked (ei 6) around the swap.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_SwitchToLink:
	ei 0x06
	ld (HDAE5000_RAM_PportMainSp:24), xsp
	nop
	ld xsp, (HDAE5000_RAM_PportLinkSp:24)
	nop
	ei 0x00
	ret
	nop

; ---------------------------------------------------------------------------
; Link -> main, the mirror image of HDAE5000_PPORT_SwitchToLink: XSP to
; HDAE5000_RAM_PportLinkSp, the main context's from PportMainSp.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_YieldToMain:
	ei 0x06
	ld (HDAE5000_RAM_PportLinkSp:24), xsp
	nop
	ld xsp, (HDAE5000_RAM_PportMainSp:24)
	nop
	ei 0x00
	ret
	nop

; ---------------------------------------------------------------------------
; Create and enter the link context, unless one is active: request flag
; cleared, active flag set, the link stack built at
; HDAE5000_RAM_PportLinkStackTop with HDAE5000_PPORT_LinkEntry as its return
; address, A = 0 (the mode HDAE5000_PPORT_Execute reads), then
; HDAE5000_PPORT_SwitchToLink.  When the link yields back without a request
; it has already ended: PportService = 0xFFFF and the active flag cleared.
; XHL, XWA preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_StartLink:
	push xhl
	nop
	push xwa
	nop
	cp (HDAE5000_RAM_PportLinkActive:24), 0x01
	jr z, .Lpi_exit
	ld (HDAE5000_RAM_PportServiceRequested:24), 0x00
	ld (HDAE5000_RAM_PportLinkActive:24), 0x01
	ld xhl, HDAE5000_RAM_PportLinkStackTop
	nop
	ld (HDAE5000_RAM_PportLinkSp:24), xhl
	nop
	ld xwa, HDAE5000_PPORT_LinkEntry
	nop
	ld (xhl), xwa
	ld a, 0x00:opc
	call HDAE5000_PPORT_SwitchToLink
	cp (HDAE5000_RAM_PportServiceRequested:24), 0x00
	jr nz, .Lpi_exit
	ldw hl, 0xFFFF
	nop
	ld (HDAE5000_RAM_PportService:24), hl
	nop
	ld (HDAE5000_RAM_PportLinkActive:24), 0x00
.Lpi_exit:
	pop xwa
	nop
	pop xhl
	nop
	ret
	nop

; ---------------------------------------------------------------------------
; Mark the link ended: HDAE5000_RAM_PportService = 0xFFFF, PportLinkActive = 0.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Reset:
	ldw hl, 0xFFFF
	nop
	ld (HDAE5000_RAM_PportService:24), hl
	nop
	ld (HDAE5000_RAM_PportLinkActive:24), 0x00
	ret
	nop

; ---------------------------------------------------------------------------
; Resume the link after a service (HDAE5000_PPORT_SwitchToLink).  When it
; yields back WITHOUT a new request (PportServiceRequested = 0) the link
; program has ended: PportService = 0xFFFF and PportLinkActive = 0.
; XHL preserved.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_ReturnToLink:
	push xhl
	nop
	call HDAE5000_PPORT_SwitchToLink
	cp (HDAE5000_RAM_PportServiceRequested:24), 0x00
	jr nz, .Lppd_done
	ldw hl, 0xFFFF
	nop
	ld (HDAE5000_RAM_PportService:24), hl
	nop
	ld (HDAE5000_RAM_PportLinkActive:24), 0x00
.Lppd_done:
	pop xhl
	nop
	ret
	nop
	; --- Secondary entry: get result ---
HDAE5000_PPORT_GetResult:
	; no caller in this ROM (searched: symbolic references and the literal
	; 0x2950EE).
	ld hl, (HDAE5000_RAM_PportService:24)
	nop
	exts xhl			; sign-extend to 32-bit
	ret
	nop

; ---------------------------------------------------------------------------
; Link context: post service WA (0..30, an index into
; HDAE5000_PPORT_ServiceTable) with arguments XBC, XDE in the mailbox, raise
; HDAE5000_RAM_PportServiceRequested and yield to the main context
; (HDAE5000_PPORT_YieldToMain).  HDAE5000_PPORT_ServicePending runs the
; service on the main context and switches back, so this returns once it
; has run; the request flag is cleared again.  Service 0 is an empty `ret`:
; CallService(0) is "yield until the next frame".
; In:  WA = service number, XBC, XDE = its arguments
; Out: the registers as the main context's service left them (only XSP is
;      swapped by the context switch); its HL result is also in
;      HDAE5000_RAM_PportService.
; RAM: HDAE5000_RAM_PportService, _PportServiceArgBc, _PportServiceArgDe,
;      _PportServiceRequested
; ---------------------------------------------------------------------------
HDAE5000_PPORT_CallService:
	ld (HDAE5000_RAM_PportService:24), wa
	nop
	ld (HDAE5000_RAM_PportServiceArgBc:24), xbc
	nop
	ld (HDAE5000_RAM_PportServiceArgDe:24), xde
	nop
	ld (HDAE5000_RAM_PportServiceRequested:24), 0x01
	call HDAE5000_PPORT_YieldToMain
	ld (HDAE5000_RAM_PportServiceRequested:24), 0x00
	ret
	nop

; ---------------------------------------------------------------------------
; Main context: run service WA (1..30) through HDAE5000_PPORT_ServiceTable;
; each entry is a stub that moves XBC / XDE into the service's argument
; registers and its HL result into WA (or XHL into XIX).
; In:  WA = service, XBC, XDE = its arguments
; Out: WA (or XIX) = the result; WA = 1 for a service number <= 0 or > 30.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_ServiceDispatch:
	cp wa, 0:i3
	jr le, .Lpps_error
	cp wa, 0x001E
	jr gt, .Lpps_error
	push xhl
	nop
	ld hl, wa
	sla xhl, 2
	nop
	extz xhl
	ld xix, HDAE5000_PPORT_ServiceTable
	nop
	ld	xhl, (xix+hl)
	nop
	call (xhl)
	pop xhl
	nop
	ret
	nop
.Lpps_error:
	ld wa, 1:i3
	ret
	nop
HDAE5000_PPORT_ServiceTable:
	; 31-entry jump table (entry 0 unused, entries 1-30 = commands)
	.long .Lpps_handler_0	; entry 0 (unused)
	.long .Lpps_handler_1	; entry 1
	.long .Lpps_handler_2	; entry 2
	.long .Lpps_handler_3	; entry 3
	.long .Lpps_handler_4	; entry 4
	.long .Lpps_handler_5	; entry 5
	.long .Lpps_handler_6	; entry 6
	.long .Lpps_handler_7	; entry 7
	.long .Lpps_handler_8	; entry 8
	.long .Lpps_handler_9	; entry 9
	.long .Lpps_handler_10	; entry 10
	.long .Lpps_handler_11	; entry 11
	.long .Lpps_handler_12	; entry 12
	.long .Lpps_handler_13	; entry 13
	.long .Lpps_handler_14	; entry 14
	.long .Lpps_handler_15	; entry 15
	.long .Lpps_handler_16	; entry 16
	.long .Lpps_handler_17	; entry 17
	.long .Lpps_handler_18	; entry 18
	.long .Lpps_handler_19	; entry 19
	.long .Lpps_handler_20	; entry 20
	.long .Lpps_handler_21	; entry 21
	.long .Lpps_handler_22	; entry 22
	.long .Lpps_handler_23	; entry 23
	.long .Lpps_handler_24	; entry 24
	.long .Lpps_handler_25	; entry 25
	.long .Lpps_handler_26	; entry 26
	.long .Lpps_handler_27	; entry 27
	.long .Lpps_handler_28	; entry 28
	.long .Lpps_handler_29	; entry 29
	.long .Lpps_handler_30	; entry 30
	; --- Handler stubs (commands 0-30) ---
.Lpps_handler_0:
	ret
	nop
.Lpps_handler_1:
	call HDAE5000_PPORT_Svc01_GetInfoBlockPointer
	ld xix, xhl
	ret
	nop
.Lpps_handler_2:
	call HDAE5000_PPORT_Svc02_TurnHdMotorOff
	ld wa, hl
	ret
	nop
.Lpps_handler_3:
	call HDAE5000_PPORT_Svc03_SendInfosAboutHd
	ld wa, hl
	ret
	nop
.Lpps_handler_4:
	call HDAE5000_PPORT_Svc04_SendInfosAboutDirBlock
	ret
	nop
.Lpps_handler_5:
	call HDAE5000_PPORT_Svc05_SendInfosAboutFileSystemBlock
	ret
	nop
.Lpps_handler_6:
	call HDAE5000_PPORT_Svc06_SendInfosAboutFlsBlock
	ret
	nop
.Lpps_handler_7:
	call HDAE5000_PPORT_Svc07_ReadDirBlockFromHd
	ld wa, hl
	ret
	nop
.Lpps_handler_8:
	call HDAE5000_PPORT_Svc08_ReadFileBlockFromHd
	ld wa, hl
	ret
	nop
.Lpps_handler_9:
	call HDAE5000_PPORT_Svc09_ReadFlsBlockFromHd
	ld wa, hl
	ret
	nop
.Lpps_handler_10:
	call HDAE5000_PPORT_Svc10_WriteDirBlockToHd
	ld wa, hl
	ret
	nop
.Lpps_handler_11:
	call HDAE5000_PPORT_Svc11_WriteFileSystemBlockToHd
	ld wa, hl
	ret
	nop
.Lpps_handler_12:
	call HDAE5000_PPORT_Svc12_WriteFlsBlockToHd
	ld wa, hl
	ret
	nop
.Lpps_handler_13:
	ld wa, bc			; shuffle args
	ld bc, de
	call HDAE5000_PPORT_Svc13_SendInfosAboutSong
	ld wa, hl
	ret
	nop
.Lpps_handler_14:
	ld wa, bc
	ld bc, de
	call HDAE5000_PPORT_Svc14_LoadSongFromHdToMemory
	ld wa, hl
	ret
	nop
.Lpps_handler_15:
	ld wa, bc
	ld bc, de
	call	HDAE5000_PPORT_Svc15_SaveSongInMemoryToHd
	ld wa, hl
	ret
	nop
.Lpps_handler_16:
	call HDAE5000_PPORT_Svc16_InitWholeSongInMemory
	ret
	nop
.Lpps_handler_17:
	call HDAE5000_PPORT_Svc17_FormatHd
	ld wa, hl
	ret
	nop
.Lpps_handler_18:
	call HDAE5000_PPORT_Svc18_RequestNormalMode
	ret
	nop
.Lpps_handler_19:
	call HDAE5000_PPORT_Svc19_SendPointerToFreeBufferSpace
	ld xix, xhl
	ret
	nop
.Lpps_handler_20:
	call HDAE5000_PPORT_Svc20_PreWholeSongInMemory
	ret
	nop
.Lpps_handler_21:
	ld wa, bc
	ld bc, de
	call HDAE5000_PPORT_Svc21_WriteOpenHD
	ld wa, hl
	ret
	nop
.Lpps_handler_22:
	call HDAE5000_PPORT_Svc22_WriteCloseHD
	ld wa, hl
	ret
	nop
.Lpps_handler_23:
	ld xwa, xbc			; 32-bit arg shuffle
	ld xbc, xde
	call HDAE5000_PPORT_Svc23_WriteFileHD
	ld wa, hl
	ret
	nop
.Lpps_handler_24:
	ld wa, bc
	ld bc, de
	call HDAE5000_PPORT_Svc24_ReadOpenHD
	ld wa, hl
	ret
	nop
.Lpps_handler_25:
	ld xwa, xbc
	ld xbc, xde
	call HDAE5000_PPORT_Svc25_ReadFileHD
	ld wa, hl
	ret
	nop
.Lpps_handler_26:
	ld xwa, xbc
	call HDAE5000_PPORT_Svc26_ShowStatus
	ld wa, 0:i3
	ret
	nop
.Lpps_handler_27:
	ld wa, bc
	ld bc, de
	call HDAE5000_PPORT_Svc27_DeleteSongParts
	ld wa, hl
	ret
	nop
.Lpps_handler_28:
	ld xwa, xbc
	ld xbc, xde
	call HDAE5000_PPORT_Svc28_FlashXapFile
	ld wa, hl
	ret
	nop
.Lpps_handler_29:
	ld xwa, xbc
	ld xbc, xde
	call HDAE5000_PPORT_Svc29_SleepMainTask
	ld wa, hl
	ret
	nop
.Lpps_handler_30:
	ld xwa, xbc
	ld xbc, xde
	call HDAE5000_PPORT_Svc30_WakeUpMainTask
	ld wa, hl
	ret
	nop

; ---------------------------------------------------------------------------
; The link program: HDAE5000_PPORT_Execute with every register kept.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_LinkMain:
	push xwa
	nop
	push xbc
	nop
	push xde
	nop
	push xhl
	nop
	push xix
	nop
	push xiy
	nop
	push xiz
	nop
	call HDAE5000_PPORT_Execute
	pop xiz
	nop
	pop xiy
	nop
	pop xix
	nop
	pop xhl
	nop
	pop xde
	nop
	pop xbc
	nop
	pop xwa
	nop
	ret
	nop

; ---------------------------------------------------------------------------
; A & 0x7F = 0 or 1 enters the link's command loop
; (HDAE5000_PPORT_CommandLoop, which dispatches the commands through
; HDAE5000_PPORT_CommandTable); every other value returns at once.
; In:  A = mode (HDAE5000_PPORT_StartLink passes 0)
; ---------------------------------------------------------------------------
HDAE5000_PPORT_Execute:
	and a, 0x7F
	nop
	cp a, 0:i3
	jr nz, .Lppe_cmd1
	jp HDAE5000_PPORT_CommandLoop
.Lppe_cmd1:
	cp a, 1:i3
	jr nz, .Lppe_cmd2
	jp HDAE5000_PPORT_CommandLoop
.Lppe_cmd2:
	cp a, 2:i3
	jr nz, .Lppe_cmd3
	jp .Lppe_simple_ret
.Lppe_cmd3:
	cp a, 3:i3
	jr nz, .Lppe_cmd4
	jp .Lppe_simple_ret
.Lppe_cmd4:
	cp a, 4:i3
	jr nz, .Lppe_cmd5
	jp .Lppe_simple_ret
.Lppe_cmd5:
	cp a, 5:i3
	jr nz, .Lppe_cmd6
	jp .Lppe_simple_ret
.Lppe_cmd6:
	cp a, 6:i3
	jr nz, .Lppe_cmd7
	jp .Lppe_simple_ret
.Lppe_cmd7:
	cp a, 7:i3
	jr nz, .Lppe_default
	jp .Lppe_simple_ret
.Lppe_default:
	jp .Lppe_simple_ret
.Lppe_simple_ret:
	ret
	; Padding (17 bytes)
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop

; ---------------------------------------------------------------------------
; Set the 8255 for the link: control word 0x89 (port A output, port C low
; nibble input), port B = 0x28; clear HDAE5000_RAM_PportError.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_InitPort:
	ld a, 0x89:opc
	ld (HDAE5000_IO_PpiControl:24), a
	nop
	ld a, 0x28:opc
	ld (HDAE5000_IO_PpiPortB:24), a
	nop
	ld (HDAE5000_RAM_PportError:24), 0x00
	ret
	nop
HDAE5000_PPORT_CommandLoop:
	; Read/execute with polling loop
	ei 0x07				; IFF=7: masks every maskable level -- this IS the real DI (06 07)
	ld a, 0x89:opc
	ld (HDAE5000_IO_PpiControl:24), a
	nop
HDAE5000_PPORT_CommandLoop_Poll:
	ld wa, 0:i3			; WA = 0
	call HDAE5000_PPORT_CallService
	ld a, (HDAE5000_IO_PpiPortC:24)	; read
	nop
	and a, 0x04			; test bit 2
	nop
	cp a, 4:i3			; bit 2 set?
	jr nz, HDAE5000_PPORT_CommandLoop_Poll		; keep polling if not
	ld a, 0x18:opc
	ld (HDAE5000_IO_PpiPortB:24), a
	nop
	ld (HDAE5000_RAM_PportError:24), 0x00
	call HDAE5000_PPORT_RecvPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)		; if Z, go back to polling
	nop
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	xor xwa, xwa			; XWA = 0
	ld a, (xix)			; A = command index
	cp xwa, 0x00000014		; compare with 20
	jp ugt, (HDAE5000_PPORT_CommandLoop_Poll:24)		; if UGT 20, invalid → repoll
	nop
	dec 1, xwa			; XWA = index - 1
	sll xwa, 2			; XWA *= 4 (table entry size)
	nop
	lda xix, (HDAE5000_PPORT_CommandTable:24); XIX = jump table base (0x294CFC)
	nop
	add xix, xwa			; XIX += offset
	ld xiy, (xix)			; XIY = handler address
	jp (xiy)			; jump to handler
; ----------------------------------------------------------------------------
; HDAE5000_PPORT_CommandTable (0x2953CE, 20 x .long): the PC-link command
; handlers.  Reader: HDAE5000_PPORT_CommandLoop, which takes the command byte n
; (packet 0x239168 byte 0, rejected above 20), and jumps through entry n-1:
; `dec 1,xwa / sll xwa,2 / lda xix,(HDAE5000_PPORT_CommandTable) / add xix,xwa
; / ld xiy,(xix) / jp (xiy)`.  The table runs on through the labels
; HDAE5000_PPORT_Cmd_Table (entries 6-17) and HDAE5000_PPORT_Ptrs (18-20); the
; handler names come from the "NN>..." status record each one shows first.
; ----------------------------------------------------------------------------
HDAE5000_PPORT_CommandTable:
	; 5-entry jump table (4 bytes each)
	; ^ entries 1-5 of the 20: see the header above
	.long HDAE5000_PPORT_Cmd01_SendInfosAboutHd		; entry 0
	.long HDAE5000_PPORT_Cmd02_ExitPport		; entry 1
	.long HDAE5000_PPORT_Cmd03_ReadFsbFromHd		; entry 2
	.long HDAE5000_PPORT_Cmd04_SendFsbToPc		; entry 3
	.long HDAE5000_PPORT_Cmd05_RcvFsbFromPc		; entry 4

; ============================================================================
; PPORT COMMAND HANDLER JUMP TABLE (0x2953E2 - 0x295411)
; 12 entries × 4 bytes = 48 bytes
; ^ CORRECTION: these are entries 6-17 of HDAE5000_PPORT_CommandTable
;   (0x2953CE), i.e. commands 6..17; the index list below numbered them 1..12
;   ("Cmd01_SendInfo" is the handler of command 06, "Writing FSB to HD").
; Each entry is a 32-bit pointer to a command handler routine
;
; Index  Address   Description
;   0    0x2958D6  Cmd01_SendInfo - Send HD info to PC
;   1    0x295914  Cmd02_Exit - Exit PPORT mode
;   2    0x2959F6  Cmd03_ReadFSB - Read FSB from HD
;   3    0x295D3C  Cmd04_SendFSB - Send FSB to PC
;   4    0x29605A  Cmd05_RcvFSB - Receive FSB from PC
;   5    0x296294  Cmd06_WriteFSB - Write FSB to HD
;   6    0x29632A  Cmd07_LoadHD - Load HD to Memory
;   7    0x29633C  Cmd08_SendData - Send data to PC
;   8    0x2964A6  Cmd09_SendFiles - Send files to PC
;   9    0x296588  Cmd10_RcvData - Receive data from PC
;  10    0x29659A  Cmd11_SaveMem - Save memory to HD
;  11    0x296680  Cmd12_Nothing - (reserved)
; ============================================================================

HDAE5000_PPORT_Cmd_Table:
	.long HDAE5000_PPORT_Cmd06_WriteFsbToHd
	.long HDAE5000_PPORT_Cmd07_LoadHdToMemory
	.long HDAE5000_PPORT_Cmd08_SendDataToPc
	.long HDAE5000_PPORT_Cmd09_SendFilesToPc
	.long HDAE5000_PPORT_Cmd10_RcvDataFromPc
	.long HDAE5000_PPORT_Cmd11_SaveMemoryToHd
	.long HDAE5000_PPORT_Cmd12_Nothing
	.long HDAE5000_PPORT_Cmd13_RcvDataFromPc
	.long HDAE5000_PPORT_Cmd14_SendInfosToPc
	.long HDAE5000_PPORT_Cmd15_Nothing
	.long HDAE5000_PPORT_Cmd16_DeleteFiles
	.long HDAE5000_PPORT_Cmd17_FormatHd

; ============================================================================
; PPORT COMMAND MENU STRINGS (0x295412 - 0x295641)
; 21 null-terminated strings for PPORT menu display
; Format: "NN>Description" where NN is the command number (01-20)
;
; Strings:
;   01>Send Infos About HD
;   02>Exit PPORT
;   03>Read FSB from HD
;   04>Sending FSB to PC
;   05>Rcv FSB from PC
;   06>Writing FSB to HD
;   07>Load HD to Memory
;   08>Send data to PC
;   09>Sending files to PC
;   10>Rcv data from PC
;   11>Save memory to HD
;   12>nothing
;   13>Rcv data from PC
;   14>Sending infos to PC
;   15>nothing
;   16>Delete files
;   17>Formating HD
;   18>Switch HD-motor off
;   19>nothing
;   20>Send XapFile flash
;   20>End flash right.
;   20>End flash false.
;   Error : Wrong Dll Ver
; ============================================================================

HDAE5000_PPORT_Ptrs:
	; 3 pointers to PPORT utility routines (in code_295642_2971a2.bin)
	; ^ = entries 18-20 of HDAE5000_PPORT_CommandTable (commands 18, 19, 20)
	.long HDAE5000_PPORT_Cmd18_SwitchHdMotorOff
	.long HDAE5000_PPORT_Cmd19_Nothing
	.long HDAE5000_PPORT_Cmd20_SendXapFileFlash

; -----------------------------------------------------------------------------
; PPORT status/menu string table -- FIXED 24-BYTE RECORD STRIDE, PROVEN BY THE
; CONSUMER, not just by how the strings happen to be padded.
;
; 23 records, 0x29541E-0x29562A(+len): 20 numbered "NN>Description" command
; strings (22 chars, space-padded, .asciz -> 23B + one closing .byte 0x00 pad
; = 24B/record), 2 irregular 22-byte flash-result continuations of command 20
; ("End flash right"/"End flash false", .ascii + a literal 0x09 TAB, two
; spaces and a NUL instead of the usual pad -- same 22-char field width,
; different filler bytes), then a final 24-byte "Error : Wrong Dll Ver"
; record back on the regular pad.
;
; EVIDENCE: HDAE5000_PPORT_Cmd01_SendInfosAboutHd's PPORT command handlers load a status
; ["Cmd01..'s handlers" was "Code_2_PartB's", the name of the whole
;  conversion region: all twenty HDAE5000_PPORT_CmdNN handlers are meant]
; string via `lda_24 xbc, (0x2954xx/0x2955xx)` before every
; HDAE5000_PPORT_CallService call. There are 23 such literals in this file, one
; per record, and ALL 23 land exactly on a record start computed
; independently from these lines' own linked addresses (get_lprobe_addrs.py) --
; including both irregular 22-byte records and the trailing "Error" one.
; Reproduce: hdae5000/tools/verify_pport_strings_stride.py (23/23 PASS).
; This makes each `.byte` below a proven per-record terminator/pad, not
; unexplained filler: shortening or lengthening any string here (other than
; swapping its trailing spaces) would desync every one of those 23 call sites.
; -----------------------------------------------------------------------------
HDAE5000_PPORT_Strings:
	; PPORT command menu strings (21 null-terminated strings)
	; Format: "NN>Description" where NN = command number
	.asciz "01>Send Infos About HD"
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd02_ExitPport_Str_N02_Exit_PPORT:	.asciz "02>Exit PPORT         "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd03_ReadFsbFromHd_Str_N03_Read_FSB_from_HD:	.asciz "03>Read FSB from HD   "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd04_SendFsbToPc_Str_N04_Sending_FSB_to_PC:	.asciz "04>Sending FSB to PC  "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd05_RcvFsbFromPc_Str_N05_Rcv_FSB_from_PC:	.asciz "05>Rcv FSB from PC    "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd06_WriteFsbToHd_Str_N06_Writing_FSB_to_HD:	.asciz "06>Writing FSB to HD  "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd07_LoadHdToMemory_Str_N07_Load_HD_to_Memory:	.asciz "07>Load HD to Memory  "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd08_SendDataToPc_Str_N08_Send_data_to_PC:	.asciz "08>Send data to PC    "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd09_SendFilesToPc_Str_N09_Sending_files_to_PC:	.asciz "09>Sending files to PC"
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd10_RcvDataFromPc_Str_N10_Rcv_data_from_PC:	.asciz "10>Rcv data from PC   "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd11_SaveMemoryToHd_Str_N11_Save_memory_to_HD:	.asciz "11>Save memory to HD  "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd12_Nothing_Str_N12_nothing:	.asciz "12>nothing            "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd13_RcvDataFromPc_Str_N13_Rcv_data_from_PC:	.asciz "13>Rcv data from PC   "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd14_SendInfosToPc_Str_N14_Sending_infos_to_PC:	.asciz "14>Sending infos to PC"
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd15_Nothing_Str_N15_nothing:	.asciz "15>nothing            "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd16_DeleteFiles_Str_N16_Delete_files:	.asciz "16>Delete files       "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd17_FormatHd_Str_N17_Formating_HD:	.asciz "17>Formating HD       "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd18_SwitchHdMotorOff_Str_N18_Switch_HD_motor_off:	.asciz "18>Switch HD-motor off"
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd19_Nothing_Str_N19_nothing:	.asciz "19>nothing            "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd20_SendXapFileFlash_Str_N20_Send_XapFile_flash:	.asciz "20>Send XapFile flash "
	.byte 0x00                            ; record terminator (24B stride; see header above)
HDAE5000_PPORT_Cmd20_Str_EndFlashRight:
	.ascii "20>End flash right"
	.byte 0x09, 0x20, 0x20, 0x00          ; 22B record filler: TAB + 2 spaces + NUL (record start 0x294F2C is a direct call-site literal, see header above)
HDAE5000_PPORT_Cmd20_Str_EndFlashFalse:
	.ascii "20>End flash false"
	.byte 0x09, 0x20, 0x20, 0x00          ; 22B record filler: TAB + 2 spaces + NUL (record start 0x294f42 is a direct call-site literal, see header above)
HDAE5000_PPORT_Cmd01_SendInfosAboutHd_Str_Error_Wrong_Dll_Ver:	.asciz "Error : Wrong Dll Ver "
	.byte 0x00                            ; record terminator (24B stride; see header above)

; ============================================================================
; CODE SECTION 2 PART B (0x295642 - 0x2FFFFF)
; All remaining code and data including:
;   - PPORT command handler implementations (Cmd01-Cmd12)
;   - HD file management routines
;   - Check_HD_Present (0x2971A3)
;   - MemCopy utility (0x29AE9F)
;   - UI configuration data
;   - Version information (0x2999B0)
;   - German language error messages
;   - Zero padding at end (~65KB)
; ============================================================================

HDAE5000_PPORT_Cmd01_SendInfosAboutHd:	; (660 bytes)
	; PC-link command 01: HDAE5000_PPORT_CommandTable entry 0; first shows the
	; status record "01>Send Infos About HD" (HDAE5000_PPORT_Strings + 0, service 26).
	; The description lines below predate this name and are not re-verified.
	; PPORT command handler: initialize HD — display status, read flag bytes,
	; check compatibility, call utility with params, sum buffer
	ldw wa, 0x001A				; display command
	nop
	lda xbc, (HDAE5000_PPORT_Strings:24); lda XBC, 0x294D4C — status string
	nop
	call HDAE5000_PPORT_CallService
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld a, (xix + 1)			; read flag byte 1
	nop
	ld (0x239098:24), a; st (0x239098), A
	nop
	ld a, (xix + 2)			; read flag byte 2
	nop
	ld (0x23909a:24), a; st (0x23909A), A
	nop
	call HDAE5000_PPORT_ClearPacket
	ld wa, 3:i3				; display command
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3				; check result
	jp z, (.Lc2b_check_compat:24)			; success path
	nop
	jp .Lc2b_do_cleanup
.Lc2b_check_compat:
	ld a, (HDAE5000_RAM_FileFormat_VersionMajor:24); ld A, (0x239FD2) — compatibility byte
	nop
	cp (2330776:24), a; cp (0x239098), A — match?
	nop
	jp z, (.Lc2b_compat_ok:24)			; match, skip error
	nop
	ldw wa, 0x001A
	nop
	lda xbc, (HDAE5000_PPORT_Cmd01_SendInfosAboutHd_Str_Error_Wrong_Dll_Ver:24); lda XBC, 0x294F58 — error string
	nop
	call HDAE5000_PPORT_CallService
.Lc2b_do_cleanup:
	call HDAE5000_PPORT_FlagPacketError
	jp .Lc2b_sum_and_done
.Lc2b_compat_ok:
	ldw bc, 0x0097				; BC param
	nop
	ldw hl, 0x00CA				; HL param
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
.Lc2b_sum_and_done:
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01; error check
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; jp Z, abort
	nop
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd02_ExitPport:			; — command 02 "Exit PPORT" (was: Format HD command handler)
	; PC-link command 02: HDAE5000_PPORT_CommandTable entry 1; first shows the
	; status record "02>Exit PPORT" (HDAE5000_PPORT_Strings + 24, service 26).
	; The description lines below predate this name and are not re-verified.
	ei	0
	ldw wa, 0x001A
	nop
	lda xbc, (HDAE5000_PPORT_Cmd02_ExitPport_Str_N02_Exit_PPORT:24); lda XBC, 0x294d64 — format string
	nop
	call HDAE5000_PPORT_CallService
	ld wa, 1:i3				; display command
	call HDAE5000_PPORT_CallService
	xor wa, wa				; WA = 0
	ld a, 0xFF:opc				; A = 0xFF, so WA = 0x00FF
	ld (xix), wa				; store to PPORT data
	ldw wa, 0x0012				; display command
	nop
	call HDAE5000_PPORT_CallService
	ret
	nop

HDAE5000_PPORT_Cmd03_ReadFsbFromHd:			; — command 03 "Read FSB from HD" (was: Read status command handler)
	; PC-link command 03: HDAE5000_PPORT_CommandTable entry 2; first shows the
	; status record "03>Read FSB from HD" (HDAE5000_PPORT_Strings + 48, service 26).
	; The description lines below predate this name and are not re-verified.
	ldw wa, 0x001A
	nop
	lda xbc, (HDAE5000_PPORT_Cmd03_ReadFsbFromHd_Str_N03_Read_FSB_from_HD:24); lda XBC, 0x294D7C — status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_ClearPacket
	ld wa, 7:i3				; display command
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3
	jp z, (.Lc2b_rs_sum:24)			; skip cleanup
	nop
	call HDAE5000_PPORT_FlagPacketError
.Lc2b_rs_sum:
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd04_SendFsbToPc:			; — command 04 "Sending FSB to PC" (was: Read HD sectors command handler)
	; PC-link command 04: HDAE5000_PPORT_CommandTable entry 3; first shows the
	; status record "04>Sending FSB to PC" (HDAE5000_PPORT_Strings + 72, service 26).
	; The description lines below predate this name and are not re-verified.
	; Display status, read 3 CHS parameter sets, call read function for each
	ldw wa, 0x001a
	nop
	lda xbc, (HDAE5000_PPORT_Cmd04_SendFsbToPc_Str_N04_Sending_FSB_to_PC:24); lda XBC, 0x294d94 — status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_ClearPacket
	ld wa, 4:i3				; display progress step 1
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ldw bc, 0x002c
	nop
	ldw hl, 0x0034
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	ld wa, 5:i3				; step 2
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ldw bc, 0x0034
	nop
	ldw hl, 0x003c
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	ld wa, 6:i3				; step 3
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ldw bc, 0x003c
	nop
	ldw hl, 0x0046
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
	; Read 3 CHS regions from PPORT data
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld bc, (xix + 0x30)			; sectors low
	nop
	ld de, (xix + 0x32)			; sectors high
	nop
	mul xde, bc				; XDE = DE × BC (total sectors)
	ld xiy, (xix + 0x2c)			; region start
	nop
	call HDAE5000_PPORT_SendBlock				; read region
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld bc, (xix + 0x38)
	nop
	ld de, (xix + 0x3a)
	nop
	mul xde, bc
	ld xiy, (xix + 0x34)
	nop
	call HDAE5000_PPORT_SendBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld bc, (xix + 0x40)
	nop
	ld de, (xix + 0x42)
	nop
	mul xde, bc
	ld xiy, (xix + 0x3c)
	nop
	call HDAE5000_PPORT_SendBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd05_RcvFsbFromPc:			; — command 05 "Rcv FSB from PC" (was: Write HD sectors command handler)
	; PC-link command 05: HDAE5000_PPORT_CommandTable entry 4; first shows the
	; status record "05>Rcv FSB from PC" (HDAE5000_PPORT_Strings + 96, service 26).
	; The description lines below predate this name and are not re-verified.
	; Same as read but calls write function (0x296B7E) instead
	ldw wa, 0x001a
	nop
	lda xbc, (HDAE5000_PPORT_Cmd05_RcvFsbFromPc_Str_N05_Rcv_FSB_from_PC:24); lda XBC, 0x294DAC — status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_ClearPacket
	ld wa, 4:i3
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ldw bc, 0x002c
	nop
	ldw hl, 0x0034
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	ld wa, 5:i3
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ldw bc, 0x0034
	nop
	ldw hl, 0x003c
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	ld wa, 6:i3
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ldw bc, 0x003c
	nop
	ldw hl, 0x0046
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
	; Write 3 CHS regions from PPORT data
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld bc, (xix + 0x30)
	nop
	ld de, (xix + 0x32)
	nop
	mul xde, bc
	ld xiy, (xix + 0x2c)
	nop
	call HDAE5000_PPORT_RecvBlock				; write region
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld bc, (xix + 0x38)
	nop
	ld de, (xix + 0x3a)
	nop
	mul xde, bc
	ld xiy, (xix + 0x34)
	nop
	call HDAE5000_PPORT_RecvBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld bc, (xix + 0x40)
	nop
	ld de, (xix + 0x42)
	nop
	mul xde, bc
	ld xiy, (xix + 0x3c)
	nop
	call HDAE5000_PPORT_RecvBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd06_WriteFsbToHd:	; (62 bytes)
	; PC-link command 06: HDAE5000_PPORT_CommandTable entry 5; first shows the
	; status record "06>Writing FSB to HD" (HDAE5000_PPORT_Strings + 120, service 26).
	; The description lines below predate this name and are not re-verified.
	; Handler: Send HD info - display status, clear buffer, check result
	ldw wa, 0x001a			; display row/column
	nop
	lda xbc, (HDAE5000_PPORT_Cmd06_WriteFsbToHd_Str_N06_Writing_FSB_to_HD:24); lda XBC, (0x294dc4) - status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_ClearPacket
	ldw wa, 0x000A			; display row/column
	nop
	ei 0x00				; enable interrupts
	call HDAE5000_PPORT_CallService
	ei 0x07				; disable interrupts
	cp wa, 0:i3			; check result
	jp z, (.LPPORT_Cmd06_WriteFsbToHd_Skip1:24)		; jp Z - skip cleanup if zero
	nop
	call HDAE5000_PPORT_FlagPacketError
.LPPORT_Cmd06_WriteFsbToHd_Skip1:
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)		; jp Z - exit to PPORT finish
	nop
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd07_LoadHdToMemory:	; (226 bytes)
	; PC-link command 07: HDAE5000_PPORT_CommandTable entry 6; first shows the
	; status record "07>Load HD to Memory" (HDAE5000_PPORT_Strings + 144, service 26).
	; The description lines below predate this name and are not re-verified.
	; Handler: Exit PPORT — display status, render, read sector/head masks,
	; AND with data bytes, write back, sum buffer, check results
	ldw wa, 0x001a				; display command
	nop
	lda xbc, (HDAE5000_PPORT_Cmd07_LoadHdToMemory_Str_N07_Load_HD_to_Memory:24); lda XBC, 0x294DDC — status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_LatchPacketArgs
	call HDAE5000_PPORT_RequestSongInfo
	call HDAE5000_PPORT_GetInfoBlock				; register XIX
	call HDAE5000_PPORT_ClearPacket
	ld bc, 0:i3				; BC = 0
	ldw hl, 0x00C8				; HL = 200
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld a, (xix)				; read byte 0 from PPORT data
	ld (0x239082:24), a; st (0x239082), A — save sector byte
	nop
	ld w, (HDAE5000_RAM_PportArg3:24)
	nop
	and w, a				; W = mask AND data
	ld (HDAE5000_RAM_PportPartMask:24), w
	nop
	ld a, (xix + 1)			; read byte 1 from PPORT data
	nop
	ld (0x239084:24), a; st (0x239084), A — save head byte
	nop
	ld w, (HDAE5000_RAM_PportArg4:24)
	nop
	and w, a				; W = mask AND data
	ld (HDAE5000_RAM_PportPartMaskHi:24), w
	nop
	ld (xix), w				; write masked head to PPORT[0]
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; abort
	nop
	cp (HDAE5000_RAM_PportPartMask:24), 0x00
	jp z, (.LPPORT_Cmd07_LoadHdToMemory_Skip1:24)			; skip to end
	nop
	jp .Lce_continue
.Lce_check_head:
	cp (HDAE5000_RAM_PportPartMaskHi:24), 0x00
	jp z, (.LPPORT_Cmd07_LoadHdToMemory_Skip1:24)			; skip to end
	nop
.Lce_continue:
	call HDAE5000_PPORT_ClearPacket
	ld xix, (HDAE5000_RAM_PportInfoPtr:24)	; data source ptr
	nop
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	ld (xix), a				; write sector to buffer[0]
	ld a, (HDAE5000_RAM_PportPartMaskHi:24)
	nop
	ld (xix + 1), a			; write head to buffer[1]
	nop
	xor xbc, xbc
	xor xde, xde
	ld c, (HDAE5000_RAM_PportArg1:24)
	nop
	ld e, (HDAE5000_RAM_PportArg2:24)
	nop
	ldw wa, 0x000E				; display command
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3				; check result
	jp z, (.Lce_final_sum:24)			; skip cleanup
	nop
	call HDAE5000_PPORT_FlagPacketError
.Lce_final_sum:
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; abort
	nop
.LPPORT_Cmd07_LoadHdToMemory_Skip1:
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd08_SendDataToPc:	; (838 bytes)
	; PC-link command 08: HDAE5000_PPORT_CommandTable entry 7; first shows the
	; status record "08>Send data to PC" (HDAE5000_PPORT_Strings + 168, service 26).
	; The description lines below predate this name and are not re-verified.
	; Handler: Read FSB from HD — display status, render, read sector/head masks,
	; copy 18 region descriptors from PPORT buffer, then read each flagged region
	ldw wa, 0x001a				; display command
	nop
	lda xbc, (HDAE5000_PPORT_Cmd08_SendDataToPc_Str_N08_Send_data_to_PC:24); lda XBC, 0x294DF4 — status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_LatchPacketArgs
	call HDAE5000_PPORT_RequestSongInfo
	call HDAE5000_PPORT_GetInfoBlock				; register XIX
	call HDAE5000_PPORT_ClearPacket
	ld bc, 0:i3
	ldw hl, 0x002C
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld a, (xix)				; sector mask byte
	ld (0x239082:24), a; st (0x239082), A
	nop
	ld w, (HDAE5000_RAM_PportArg3:24)
	nop
	and w, a				; apply mask
	and w, 0xBF				; clear bit 6
	nop
	ld (HDAE5000_RAM_PportPartMask:24), w
	nop
	ld a, (xix + 1)			; head mask byte
	nop
	ld (0x239084:24), a; st (0x239084), A
	nop
	ld w, (HDAE5000_RAM_PportArg4:24)
	nop
	and w, a
	ld (HDAE5000_RAM_PportPartMaskHi:24), w
	nop
	ld (xix + 1), w			; write back
	nop
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01; error check
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; jp Z, abort
	nop
	cp (HDAE5000_RAM_PportPartMask:24), 0x00
	jp z, (.Lrfsb_exit:24)			; skip to end
	nop
	jp .Lrfsb_continue
.Lrfsb_check_head:
	cp (HDAE5000_RAM_PportPartMaskHi:24), 0x00
	jp z, (.Lrfsb_exit:24)			; jp Z, skip to end
	nop
.Lrfsb_continue:
	ld (HDAE5000_RAM_PportStepError:24), 0x00	; clear error flag
	call HDAE5000_PPORT_ClearPacket
	ld xix, (HDAE5000_RAM_PportInfoPtr:24)	; data ptr
	nop
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	ld (xix), a
	ld a, (HDAE5000_RAM_PportPartMaskHi:24)
	nop
	ld (xix + 1), a
	nop
	xor xbc, xbc
	xor xde, xde
	ld c, (HDAE5000_RAM_PportArg1:24)
	nop
	ld e, (HDAE5000_RAM_PportArg2:24)
	nop
	ldw wa, 0x000E				; display command
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3
	jr z, .Lrfsb_no_error_flag
	ld (HDAE5000_RAM_PportStepError:24), 0x01; set error flag
.Lrfsb_no_error_flag:
	call HDAE5000_PPORT_RequestSongInfo
	ld xix, (HDAE5000_RAM_PportInfoPtr:24)
	nop
	; Copy 18 region descriptors from PPORT buffer to memory
	; Short displacement (8-bit signed): offsets 0x46-0x7C
	ld xwa, (xix + 0x46)
	nop
	ld (HDAE5000_RAM_PportRegions:24), xwa
	nop
	ld xwa, (xix + 0x4A)
	nop
	ld (HDAE5000_RAM_PportRegions+4:24), xwa
	nop
	ld xwa, (xix + 0x4F)
	nop
	ld (HDAE5000_RAM_PportRegions+8:24), xwa
	nop
	ld xwa, (xix + 0x53)
	nop
	ld (HDAE5000_RAM_PportRegions+12:24), xwa
	nop
	ld xwa, (xix + 0x58)
	nop
	ld (HDAE5000_RAM_PportRegions+16:24), xwa
	nop
	ld xwa, (xix + 0x5C)
	nop
	ld (HDAE5000_RAM_PportRegions+20:24), xwa
	nop
	ld xwa, (xix + 0x61)
	nop
	ld (HDAE5000_RAM_PportRegions+24:24), xwa
	nop
	ld xwa, (xix + 0x65)
	nop
	ld (HDAE5000_RAM_PportRegions+28:24), xwa
	nop
	ld xwa, (xix + 0x6A)
	nop
	ld (HDAE5000_RAM_PportRegions+32:24), xwa
	nop
	ld xwa, (xix + 0x6E)
	nop
	ld (HDAE5000_RAM_PportRegions+36:24), xwa
	nop
	ld xwa, (xix + 0x73)
	nop
	ld (HDAE5000_RAM_PportRegions+40:24), xwa
	nop
	ld xwa, (xix + 0x77)
	nop
	ld (HDAE5000_RAM_PportRegions+44:24), xwa
	nop
	ld xwa, (xix + 0x7C)
	nop
	ld (HDAE5000_RAM_PportRegions+48:24), xwa
	nop
	; Extended displacement (16-bit): offsets >= 0x80
	ld	xwa, (xix+128)
	nop
	ld (HDAE5000_RAM_PportRegions+52:24), xwa
	nop
	ld	xwa, (xix+142)
	nop
	ld (HDAE5000_RAM_PportRegions+60:24), xwa
	nop
	ld	xwa, (xix+146)
	nop
	ld (HDAE5000_RAM_PportRegions+64:24), xwa
	nop
	ld	xwa, (xix+191)
	nop
	ld (HDAE5000_RAM_PportRegions+68:24), xwa
	nop
	ld	xwa, (xix+195)
	nop
	ld (HDAE5000_RAM_PportRegions+72:24), xwa
	nop
	; Setup for final sum/check
	call HDAE5000_PPORT_ClearPacket
	ld bc, 0:i3
	ldw hl, 0x00C8
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	cp (HDAE5000_RAM_PportStepError:24), 0x00; error flag clear?
	jr z, .Lrfsb_sum
	call HDAE5000_PPORT_FlagPacketError
.Lrfsb_sum:
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; jp Z, abort
	nop
	cp (HDAE5000_RAM_PportStepError:24), 0x01; error flag set?
	jp z, (.Lrfsb_exit:24)			; jp Z, exit
	nop
	; Test flag bits and read corresponding regions
	; Bit 0: custom region
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x01
	nop
	cp a, 1:i3
	jp nz, (.Lrfsb_bit1:24)			; jp NZ, skip
	nop
	call HDAE5000_PPORT_SendTwoRegions				; read custom region
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrfsb_bit1:				; — Bit 1
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x02
	nop
	cp a, 2:i3
	jp nz, (.Lrfsb_bit2:24)			; jp NZ, skip
	nop
	ld xiy, (HDAE5000_RAM_PportRegions+16:24)
	nop
	ld xde, (HDAE5000_RAM_PportRegions+20:24)
	nop
	call HDAE5000_PPORT_SendBlock				; read region
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrfsb_bit2:				; — Bit 2
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x04
	nop
	cp a, 4:i3
	jp nz, (.Lrfsb_bit3:24)
	nop
	ld xiy, (HDAE5000_RAM_PportRegions+24:24)
	nop
	ld xde, (HDAE5000_RAM_PportRegions+28:24)
	nop
	call HDAE5000_PPORT_SendBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrfsb_bit3:				; — Bit 3
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x08
	nop
	cp a, 0x08
	nop
	jp nz, (.Lrfsb_bit4:24)
	nop
	ld xiy, (HDAE5000_RAM_PportRegions+32:24)
	nop
	ld xde, (HDAE5000_RAM_PportRegions+36:24)
	nop
	call HDAE5000_PPORT_SendBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrfsb_bit4:				; — Bit 4
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x10
	nop
	cp a, 0x10
	nop
	jp nz, (.Lrfsb_bit5:24)
	nop
	ld xiy, (HDAE5000_RAM_PportRegions+40:24)
	nop
	ld xde, (HDAE5000_RAM_PportRegions+44:24)
	nop
	call HDAE5000_PPORT_SendBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrfsb_bit5:				; — Bit 5
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x20
	nop
	cp a, 0x20
	nop
	jp nz, (.Lrfsb_bit7:24)
	nop
	ld xiy, (HDAE5000_RAM_PportRegions+48:24)
	nop
	ld xde, (HDAE5000_RAM_PportRegions+52:24)
	nop
	call HDAE5000_PPORT_SendBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrfsb_bit7:				; — Bit 7
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x80
	nop
	cp a, 0x80
	nop
	jp nz, (.Lrfsb_flag2_bit0:24)
	nop
	ld xiy, (HDAE5000_RAM_PportRegions+60:24)
	nop
	ld xde, (HDAE5000_RAM_PportRegions+64:24)
	nop
	call HDAE5000_PPORT_SendBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrfsb_flag2_bit0:			; — Head flag bit 0
	ld a, (HDAE5000_RAM_PportPartMaskHi:24)
	nop
	and a, 0x01
	nop
	cp a, 1:i3
	jp nz, (.Lrfsb_exit:24)			; jp NZ, exit
	nop
	ld xiy, (HDAE5000_RAM_PportRegions+68:24)
	nop
	ld xde, (HDAE5000_RAM_PportRegions+72:24)
	nop
	call HDAE5000_PPORT_SendBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrfsb_exit:
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd09_SendFilesToPc:	; (798 bytes)
	; PC-link command 09: HDAE5000_PPORT_CommandTable entry 8; first shows the
	; status record "09>Sending files to PC" (HDAE5000_PPORT_Strings + 192, service 26).
	; The description lines below predate this name and are not re-verified.
	; Handler: Send FSB to PC — display status, read sector/head masks,
	; build transfer buffer (masked bytes + 9 region descriptors),
	; send to PC via PPORT, then conditionally send each region
	; based on flag bits (8 bits from byte 1 + 1 bit from byte 2)
	ldw wa, 0x001a				; display command
	nop
	lda xbc, (HDAE5000_PPORT_Cmd09_SendFilesToPc_Str_N09_Sending_files_to_PC:24); lda XBC, 0x294E0C — status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_LatchPacketArgs
	call HDAE5000_PPORT_RequestSongInfo
	call HDAE5000_PPORT_GetInfoBlock				; register XIX
	ld xix, (HDAE5000_RAM_PportInfoPtr:24)	; data source ptr
	nop
	ld a, (xix)				; read byte 0 from data source
	ld (0x239082:24), a; st (0x239082), A — save sector raw
	nop
	ld w, (HDAE5000_RAM_PportArg3:24)
	nop
	and w, a				; W = mask AND data
	ld (HDAE5000_RAM_PportPartMask:24), w
	nop
	ld a, (xix + 1)			; read byte 1 from data source
	nop
	ld (0x239084:24), a; st (0x239084), A — save head raw
	nop
	ld w, (HDAE5000_RAM_PportArg4:24)
	nop
	and w, a				; W = mask AND data
	ld (HDAE5000_RAM_PportPartMaskHi:24), w
	nop
	call HDAE5000_PPORT_InitRegionDescriptors
	call HDAE5000_PPORT_RequestSongInfo
	call HDAE5000_PPORT_ClearPacket
	ld bc, 0:i3				; BC = 0 (offset)
	ldw hl, 0x002C				; HL = 44 (length)
	nop
	call HDAE5000_PPORT_CopyInfoToPacket
	cp (HDAE5000_RAM_PportStepError:24), 0x00	; cleanup needed?
	jp z, (.Lsfsb_build_buffer:24)			; jp Z, .Lsfsb_build_buffer — skip cleanup
	nop
	call HDAE5000_PPORT_FlagPacketError
.Lsfsb_build_buffer:			; — Build transfer buffer
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	ld (xix), a				; store to buffer[0]
	ld a, (HDAE5000_RAM_PportPartMaskHi:24)
	nop
	ld (xix + 1), a			; store to buffer[1]
	nop
	add xix, 44				; advance XIX by 0x2C (44 bytes)
	; Copy 9 × 32-bit region descriptors to buffer
	ld xwa, (HDAE5000_RAM_PportRegions+4:24)	; region 0
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+20:24)	; region 1
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+28:24)	; region 2
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+36:24)	; region 3
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+44:24)	; region 4
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+52:24)	; region 5
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+56:24)	; region 6
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+64:24)	; region 7
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+72:24)	; region 8
	nop
	ld (xix), xwa
	; Send buffer via PPORT
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; abort
	nop
	cp (HDAE5000_RAM_PportStepError:24), 0x01	; skip bit tests?
	jp z, (.Lsfsb_exit:24)			; jp Z, .Lsfsb_exit
	nop
	; Test flag byte 1 bit by bit, send corresponding region data
	; Bit 0 (0x01)
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x01
	nop
	cp a, 1:i3
	jp nz, (.Lsfsb_bit1:24)			; jp NZ, .Lsfsb_bit1
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+4:24)	; region 0
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	ld (HDAE5000_RAM_PportSendMaskLo:24), 0x01
	ld (HDAE5000_RAM_PportSendMaskHi:24), 0x00
	call HDAE5000_PPORT_SendRegionToPc
	cp (HDAE5000_RAM_PportError:24), 0x01; error check
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; jp Z, abort
	nop
.Lsfsb_bit1:				; — Bit 1 (0x02)
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x02
	nop
	cp a, 2:i3
	jp nz, (.Lsfsb_bit2:24)			; jp NZ, .Lsfsb_bit2
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+20:24)	; region 1
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	ld (HDAE5000_RAM_PportSendMaskLo:24), 0x02
	ld (HDAE5000_RAM_PportSendMaskHi:24), 0x00
	call HDAE5000_PPORT_SendRegionToPc
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lsfsb_bit2:				; — Bit 2 (0x04)
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x04
	nop
	cp a, 4:i3
	jp nz, (.Lsfsb_bit3:24)			; jp NZ, .Lsfsb_bit3
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+28:24)	; region 2
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	ld (HDAE5000_RAM_PportSendMaskLo:24), 0x04
	ld (HDAE5000_RAM_PportSendMaskHi:24), 0x00
	call HDAE5000_PPORT_SendRegionToPc
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lsfsb_bit3:				; — Bit 3 (0x08)
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x08
	nop
	cp a, 0x08
	nop
	jp nz, (.Lsfsb_bit4:24)			; jp NZ, .Lsfsb_bit4
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+36:24)	; region 3
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	ld (HDAE5000_RAM_PportSendMaskLo:24), 0x08
	ld (HDAE5000_RAM_PportSendMaskHi:24), 0x00
	call HDAE5000_PPORT_SendRegionToPc
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lsfsb_bit4:				; — Bit 4 (0x10)
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x10
	nop
	cp a, 0x10
	nop
	jp nz, (.Lsfsb_bit5:24)			; jp NZ, .Lsfsb_bit5
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+44:24)	; region 4
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	ld (HDAE5000_RAM_PportSendMaskLo:24), 0x10
	ld (HDAE5000_RAM_PportSendMaskHi:24), 0x00
	call HDAE5000_PPORT_SendRegionToPc
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lsfsb_bit5:				; — Bit 5 (0x20)
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x20
	nop
	cp a, 0x20
	nop
	jp nz, (.Lsfsb_bit6:24)			; jp NZ, .Lsfsb_bit6
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+52:24)	; region 5
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	ld (HDAE5000_RAM_PportSendMaskLo:24), 0x20
	ld (HDAE5000_RAM_PportSendMaskHi:24), 0x00
	call HDAE5000_PPORT_SendRegionToPc
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lsfsb_bit6:				; — Bit 6 (0x40)
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x40
	nop
	cp a, 0x40
	nop
	jp nz, (.Lsfsb_bit7:24)			; jp NZ, .Lsfsb_bit7
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+56:24)	; region 6
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	ld (HDAE5000_RAM_PportSendMaskLo:24), 0x40
	ld (HDAE5000_RAM_PportSendMaskHi:24), 0x00
	call HDAE5000_PPORT_SendRegionToPc
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lsfsb_bit7:				; — Bit 7 (0x80)
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x80
	nop
	cp a, 0x80
	nop
	jp nz, (.Lsfsb_bit8:24)			; jp NZ, .Lsfsb_bit8
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+64:24)	; region 7
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	ld (HDAE5000_RAM_PportSendMaskLo:24), 0x80
	ld (HDAE5000_RAM_PportSendMaskHi:24), 0x00
	call HDAE5000_PPORT_SendRegionToPc
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lsfsb_bit8:				; — Flag byte 2, bit 0 (0x01)
	ld a, (HDAE5000_RAM_PportPartMaskHi:24)
	nop
	and a, 0x01
	nop
	cp a, 1:i3
	jp nz, (.Lsfsb_exit:24)			; jp NZ, .Lsfsb_exit
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+72:24)	; region 8
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	ld (HDAE5000_RAM_PportSendMaskLo:24), 0x00	; byte 1 = 0
	ld (HDAE5000_RAM_PportSendMaskHi:24), 0x01	; byte 2 = 1
	call HDAE5000_PPORT_SendRegionToPc
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lsfsb_exit:
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd10_RcvDataFromPc:	; (570 bytes)
	; PC-link command 10: HDAE5000_PPORT_CommandTable entry 9; first shows the
	; status record "10>Rcv data from PC" (HDAE5000_PPORT_Strings + 216, service 26).
	; The description lines below predate this name and are not re-verified.
	; Handler: Receive FSB from PC — reads command params (flag bytes +
	; 8 × 32-bit region descriptors), then conditionally writes each
	; region to HD based on flag bits
	ldw wa, 0x001a				; display command
	nop
	lda xbc, (HDAE5000_PPORT_Cmd10_RcvDataFromPc_Str_N10_Rcv_data_from_PC:24); lda XBC, 0x294E24 — status string
	nop
	call HDAE5000_PPORT_CallService
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld a, (xix + 1)			; flag byte 1
	nop
	ld (0x23908c:24), a; st (0x23908C), A
	nop
	ld a, (xix + 2)			; flag byte 2
	nop
	ld (0x23908e:24), a; st (0x23908E), A
	nop
	; Copy 8 × 32-bit region descriptors from PPORT data to memory
	ld xwa, (xix + 3)
	nop
	ld (HDAE5000_RAM_PportRegions+4:24), xwa
	nop
	ld xwa, (xix + 7)
	nop
	ld (HDAE5000_RAM_PportRegions+20:24), xwa
	nop
	ld xwa, (xix + 0x0B)
	nop
	ld (HDAE5000_RAM_PportRegions+28:24), xwa
	nop
	ld xwa, (xix + 0x0F)
	nop
	ld (HDAE5000_RAM_PportRegions+36:24), xwa
	nop
	ld xwa, (xix + 0x13)
	nop
	ld (HDAE5000_RAM_PportRegions+44:24), xwa
	nop
	ld xwa, (xix + 0x17)
	nop
	ld (HDAE5000_RAM_PportRegions+52:24), xwa
	nop
	ld xwa, (xix + 0x1B)
	nop
	ld (HDAE5000_RAM_PportRegions+64:24), xwa
	nop
	ld xwa, (xix + 0x1F)
	nop
	ld (HDAE5000_RAM_PportRegions+72:24), xwa
	nop
	ld wa, 1:i3				; display command
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ld (HDAE5000_RAM_PportInfoPtr:24), xix	; save data ptr
	nop
	; Write saved flag bytes back to buffer
	ld a, (0x23908c:24); ld A, (0x23908C)
	nop
	ld (xix), a
	ld a, (0x23908e:24); ld A, (0x23908E)
	nop
	ld (xix + 1), a
	nop
	ldw wa, 0x0014				; display progress command
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	; Test flag byte 1 bit by bit, write corresponding region to HD
	; Bit 0: custom region
	ld a, (0x23908c:24); ld A, (0x23908C)
	nop
	and a, 0x01
	nop
	cp a, 1:i3
	jp nz, (.Lrcv_bit1:24)			; jp NZ, skip bit 0
	nop
	call HDAE5000_PPORT_RecvCustomData				; write custom region
	cp (HDAE5000_RAM_PportError:24), 0x01; error check
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; jp Z, abort
	nop
.Lrcv_bit1:				; — Bit 1
	ld a, (0x23908c:24)
	nop
	and a, 0x02
	nop
	cp a, 2:i3
	jp nz, (.Lrcv_bit2:24)			; jp NZ, skip
	nop
	ld xiy, 0x001ED350			; region size
	nop
	ld xde, (HDAE5000_RAM_PportRegions+20:24)	; sector count
	nop
	call HDAE5000_PPORT_RecvBlock				; write region
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrcv_bit2:				; — Bit 2
	ld a, (0x23908c:24)
	nop
	and a, 0x04
	nop
	cp a, 4:i3
	jp nz, (.Lrcv_bit3:24)			; jp NZ, skip
	nop
	ld xiy, 0x000AB000
	nop
	ld xde, (HDAE5000_RAM_PportRegions+28:24)
	nop
	call HDAE5000_PPORT_RecvBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrcv_bit3:				; — Bit 3
	ld a, (0x23908c:24)
	nop
	and a, 0x08
	nop
	cp a, 0x08
	nop
	jp nz, (.Lrcv_bit4:24)			; jp NZ, skip
	nop
	ld xiy, 0x00094800
	nop
	ld xde, (HDAE5000_RAM_PportRegions+36:24)
	nop
	call HDAE5000_PPORT_RecvBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrcv_bit4:				; — Bit 4
	ld a, (0x23908c:24)
	nop
	and a, 0x10
	nop
	cp a, 0x10
	nop
	jp nz, (.Lrcv_bit5:24)			; jp NZ, skip
	nop
	ld xiy, 0x001E0000
	nop
	ld xde, (HDAE5000_RAM_PportRegions+44:24)
	nop
	call HDAE5000_PPORT_RecvBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrcv_bit5:				; — Bit 5
	ld a, (0x23908c:24)
	nop
	and a, 0x20
	nop
	cp a, 0x20
	nop
	jp nz, (.Lrcv_bit7:24)			; jp NZ, skip
	nop
	ld xiy, 0x001E8800
	nop
	ld xde, (HDAE5000_RAM_PportRegions+52:24)
	nop
	call HDAE5000_PPORT_RecvBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrcv_bit7:				; — Bit 7
	ld a, (0x23908c:24)
	nop
	and a, 0x80
	nop
	cp a, 0x80
	nop
	jp nz, (.Lrcv_flag2_bit0:24)			; jp NZ, skip
	nop
	ld xiy, 0x003D3000
	nop
	ld xde, (HDAE5000_RAM_PportRegions+64:24)
	nop
	call HDAE5000_PPORT_RecvBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrcv_flag2_bit0:			; — Flag byte 2, bit 0
	ld a, (0x23908e:24); ld A, (0x23908E)
	nop
	and a, 0x01
	nop
	cp a, 1:i3
	jp nz, (.Lrcv_finish:24)			; jp NZ, skip
	nop
	ld xiy, HDAE5000_RAM_LyricBuffer
	nop
	ld xde, (HDAE5000_RAM_PportRegions+72:24)
	nop
	call HDAE5000_PPORT_RecvBlock
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)
	nop
.Lrcv_finish:
	; Restore XIX, write flag bytes back, display final status
	ld xix, (HDAE5000_RAM_PportInfoPtr:24)
	nop
	ld a, (0x23908c:24); ld A, (0x23908C)
	nop
	ld (xix), a
	ld a, (0x23908e:24); ld A, (0x23908E)
	nop
	ld (xix + 1), a
	nop
	ldw wa, 0x0010				; display final command
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd11_SaveMemoryToHd:	; (150 bytes)
	; PC-link command 11: HDAE5000_PPORT_CommandTable entry 10; first shows the
	; status record "11>Save memory to HD" (HDAE5000_PPORT_Strings + 240, service 26).
	; The description lines below predate this name and are not re-verified.
	; Handler: Write FSB (File System Block) to HD
	; Displays "Write FSB" status, calls render, copies PPORT data to XIX buffer,
	; loads sector/head params, calls Display_String with result, sums and cleans up.
	ldw wa, 0x001a			; display row/column
	nop
	lda xbc, (HDAE5000_PPORT_Cmd11_SaveMemoryToHd_Str_N11_Save_memory_to_HD:24); 0x294E3C - "Write FSB" string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_LatchPacketArgs
	ld wa, 1:i3			; WA = 1
	ei 0x00				; IFF=0: accepts every interrupt level (06 00; was mis-spelled `di`)
	call HDAE5000_PPORT_CallService
	ei 0x07				; IFF=7: masks every maskable level -- this IS the real DI (06 07)
	xor wa, wa			; WA = 0
	ld a, (HDAE5000_RAM_PportArg3:24)
	nop
	ld (xix), a			; store to buffer[0]
	ld a, (HDAE5000_RAM_PportArg4:24)
	nop
	ld (xix + 1), a			; store to buffer[1]
	nop
	add xix, 0x00000002		; advance buffer pointer past header
	ld bc, 0:i3			; BC = 0 (loop counter)
	lda xiy, (HDAE5000_RAM_PportPacket:24)
	nop
	add xiy, 0x00000005		; skip 5-byte header
.Lwfsb_copy_loop:
	cp bc, 0x001A			; copied 26 bytes?
	jr z, .Lwfsb_done_copy		; yes, done
	ld	a, (xiy+bc)	; A = (XIY + BC) — read from PPORT data
	nop
	ld	(xix+bc), a	; (XIX + BC) = A — write to buffer
	nop
	inc 1, bc			; BC++
	jr t, .Lwfsb_copy_loop		; always loop
.Lwfsb_done_copy:
	xor xbc, xbc			; XBC = 0
	xor xde, xde			; XDE = 0
	ld c, (HDAE5000_RAM_PportArg1:24)
	nop
	ld e, (HDAE5000_RAM_PportArg2:24)
	nop
	ldw wa, 0x000F			; WA = 0x0F (command code)
	nop
	ei 0x00				; IFF=0: accepts every interrupt level (06 00; was mis-spelled `di`)
	call HDAE5000_PPORT_CallService
	ei 0x07				; IFF=7: masks every maskable level -- this IS the real DI (06 07)
	cp wa, 0:i3			; result == 0?
	jp z, (.Lwfsb_after_error:24)		; skip error handling
	nop
	call HDAE5000_PPORT_FlagPacketError
.Lwfsb_after_error:
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)		; exit to PPORT finish
	nop
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd12_Nothing:
	; PC-link command 12: HDAE5000_PPORT_CommandTable entry 11; first shows the
	; status record "12>nothing" (HDAE5000_PPORT_Strings + 264, service 26).
	; The description lines below predate this name and are not re-verified.
	; Load HD to memory - display status and finish
	ldw wa, 0x001a			; display row/column
	nop
	lda xbc, (HDAE5000_PPORT_Cmd12_Nothing_Str_N12_nothing:24); 0x294e54 - "Load HD" string
	nop
	call HDAE5000_PPORT_CallService
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd13_RcvDataFromPc:	; (362 bytes)
	; PC-link command 13: HDAE5000_PPORT_CommandTable entry 12; first shows the
	; status record "13>Rcv data from PC" (HDAE5000_PPORT_Strings + 288, service 26).
	; The description lines below predate this name and are not re-verified.
	; Send data block to PC — display status, render, build transfer buffer
	; from PPORT data, then loop sending 512-byte sectors until count exhausted
	ldw wa, 0x001a				; display command
	nop
	lda xbc, (HDAE5000_PPORT_Cmd13_RcvDataFromPc_Str_N13_Rcv_data_from_PC:24); lda XBC, 0x294E6C — status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_LatchPacketArgs
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	add xix, 0x00000005			; advance to data offset +5
	ld xwa, (xix)				; read 32-bit sector count
	ld (HDAE5000_RAM_PportRegions+76:24), xwa	; save count
	nop
	ld wa, 1:i3				; WA = 1 (display command)
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	xor wa, wa				; clear WA
	ld a, (HDAE5000_RAM_PportArg3:24)
	nop
	ld (xix), a				; store to buffer
	ld a, (HDAE5000_RAM_PportArg4:24)
	nop
	ld (xix + 1), a			; store to buffer+1
	nop
	add xix, 0x00000002			; advance past sector/head bytes
	ld bc, 0:i3				; counter = 0
	lda xiy, (HDAE5000_RAM_PportPacket:24)
	nop
	add xiy, 0x00000009			; XIY points to source data offset +9
.Lsdb_copy_loop:			; — copy 26 bytes from XIY+BC to XIX+BC
	cp bc, 0x001A				; 26 bytes?
	jr z, .Lsdb_copy_done			; exit loop
	ld	a, (xiy+bc)		; ld A, (XIY+BC) — source byte
	nop
	ld	(xix+bc), a		; ld (XIX+BC), A — store to dest
	nop
	inc 1, bc
	jr t, .Lsdb_copy_loop
.Lsdb_copy_done:
	ld (HDAE5000_RAM_PportStepError:24), 0x00	; clear error flag
	xor xbc, xbc
	xor xde, xde
	ld c, (HDAE5000_RAM_PportArg1:24)
	nop
	ld e, (HDAE5000_RAM_PportArg2:24)
	nop
	ldw wa, 0x0015				; display command
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3				; check display result
	jp z, (.Lsdb_send_header:24)			; skip error setup
	nop
	ldw wa, 0xff00				; error indicator
	nop
	ld (HDAE5000_RAM_PportStepError:24), 0x01	; set error flag
.Lsdb_send_header:
	call HDAE5000_PPORT_SendByte			; send header byte via PPORT
	cp (HDAE5000_RAM_PportError:24), 0x01; error check
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; jp Z, abort
	nop
	cp (HDAE5000_RAM_PportStepError:24), 0x01	; error flag set?
	jp z, (.LPPORT_Cmd13_RcvDataFromPc_Skip1:24)			; exit
	nop
.Lsdb_sector_loop:			; — main sector send loop
	ld xwa, (HDAE5000_RAM_PportRegions+76:24)	; remaining count
	nop
	cp xwa, 0x00000000			; all done?
	jp z, (.Lsdb_send_final:24)			; send final status
	nop
	call HDAE5000_PPORT_RecvSector				; read sector from HD
	cp (HDAE5000_RAM_PportError:24), 0x01; error check
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; jp Z, abort
	nop
	ld (HDAE5000_RAM_PportStepError:24), 0x00; clear error flag
	lda xbc, (HDAE5000_RAM_PportSectorBuffer:24)	; sector data buffer
	nop
	ld xde, 0x00000200			; 512 bytes
	nop
	ldw wa, 0x0017				; display command (send data)
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3				; check result
	jp z, (.Lsdb_send_sector:24)			; skip error
	nop
	ldw wa, 0xff00				; error indicator
	nop
	ld (HDAE5000_RAM_PportStepError:24), 0x01; set error flag
.Lsdb_send_sector:
	call HDAE5000_PPORT_SendByte			; send byte
	cp (HDAE5000_RAM_PportError:24), 0x01; error check
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; jp Z, abort
	nop
	cp (HDAE5000_RAM_PportStepError:24), 0x01; error flag?
	jp z, (.LPPORT_Cmd13_RcvDataFromPc_Skip1:24)			; jp Z, exit
	nop
	ld xwa, (HDAE5000_RAM_PportRegions+76:24); reload count
	nop
	dec 1, xwa				; decrement sector count
	ld (HDAE5000_RAM_PportRegions+76:24), xwa; store back
	nop
	jp .Lsdb_sector_loop			; next sector
.Lsdb_send_final:			; — send final status byte
	ldw wa, 0x0016				; display command (final)
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3
	jp z, (.Lsdb_send_final2:24)			; skip error
	nop
	ldw wa, 0xFF00				; error indicator
	nop
.Lsdb_send_final2:
	call HDAE5000_PPORT_SendByte			; send final byte
	cp (HDAE5000_RAM_PportError:24), 0x01; error check
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; jp Z, abort
	nop
.LPPORT_Cmd13_RcvDataFromPc_Skip1:
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd14_SendInfosToPc:	; (226 bytes)
	; PC-link command 14: HDAE5000_PPORT_CommandTable entry 13; first shows the
	; status record "14>Sending infos to PC" (HDAE5000_PPORT_Strings + 312, service 26).
	; The description lines below predate this name and are not re-verified.
	; Send file list to PC - displays status, builds transfer buffer
	; with disk info from 0x23910C-0x239150, then sends via PPORT.
	ldw wa, 0x001a			; display row/column
	nop
	lda xbc, (HDAE5000_PPORT_Cmd14_SendInfosToPc_Str_N14_Sending_infos_to_PC:24); 0x294e84 - "Send File List" string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_LatchPacketArgs
	call HDAE5000_PPORT_RequestSongInfo
	call HDAE5000_PPORT_GetInfoBlock			; prepare file list
	ld xix, (HDAE5000_RAM_PportInfoPtr:24)
	nop
	ld a, (xix)			; A = first byte
	ld (HDAE5000_RAM_PportPartMask:24), a
	nop
	ld a, (xix + 1)			; A = second byte
	nop
	ld (HDAE5000_RAM_PportPartMaskHi:24), a
	nop
	call HDAE5000_PPORT_InitRegionDescriptors			; process file list
	call HDAE5000_PPORT_RequestSongInfo
	call HDAE5000_PPORT_ClearPacket
	ld bc, 0:i3			; BC = 0 (offset)
	ldw hl, 0x002C			; HL = 44 (block size)
	nop
	call HDAE5000_PPORT_CopyInfoToPacket			; transfer setup
	cp (HDAE5000_RAM_PportStepError:24), 0x00
	jp z, (.Lsfl_build_buffer:24)		; skip cleanup
	nop
	call HDAE5000_PPORT_FlagPacketError
.Lsfl_build_buffer:
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	ld (xix), a			; store to cmd[0]
	ld a, (HDAE5000_RAM_PportPartMaskHi:24)
	nop
	ld (xix + 1), a			; store to cmd[1]
	nop
	add xix, 0x0000002C		; advance past header (44 bytes)
	; Copy 9 disk info fields (32-bit each) from 0x23910C-0x239150
	ld xwa, (HDAE5000_RAM_PportRegions+4:24)
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+20:24)
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+28:24)
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+36:24)
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+44:24)
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+52:24)
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+56:24)
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+64:24)
	nop
	ld (xix), xwa
	inc 4, xix
	ld xwa, (HDAE5000_RAM_PportRegions+72:24)
	nop
	ld (xix), xwa
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)		; exit to PPORT finish
	nop
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd15_Nothing:
	; PC-link command 15: HDAE5000_PPORT_CommandTable entry 14; first shows the
	; status record "15>nothing" (HDAE5000_PPORT_Strings + 336, service 26).
	; The description lines below predate this name and are not re-verified.
	; Receive data from PC - display status and finish
	ldw wa, 0x001a			; display row/column
	nop
	lda xbc, (HDAE5000_PPORT_Cmd15_Nothing_Str_N15_nothing:24); 0x294E9C - "Receive Data" string
	nop
	call HDAE5000_PPORT_CallService
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd16_DeleteFiles:	; (230 bytes)
	; PC-link command 16: HDAE5000_PPORT_CommandTable entry 15; first shows the
	; status record "16>Delete files" (HDAE5000_PPORT_Strings + 360, service 26).
	; The description lines below predate this name and are not re-verified.
	; Save memory to HD with sector/head masking and multi-step transfer.
	ldw wa, 0x001a			; display row/column
	nop
	lda xbc, (HDAE5000_PPORT_Cmd16_DeleteFiles_Str_N16_Delete_files:24); 0x294eb4 - "Write Memory" string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_LatchPacketArgs
	call HDAE5000_PPORT_RequestSongInfo
	call HDAE5000_PPORT_GetInfoBlock			; prepare data
	call HDAE5000_PPORT_ClearPacket
	ld bc, 0:i3			; BC = 0
	ldw hl, 0x00C8			; HL = 200 (block size)
	nop
	call HDAE5000_PPORT_CopyInfoToPacket			; transfer setup
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld a, (xix)			; A = cmd[0]
	ld (0x239082:24), a; [0x239082] = cmd[0] (raw sector byte)
	nop
	ld w, (HDAE5000_RAM_PportArg3:24)
	nop
	and w, a			; W = cmd[0] AND sector_mask
	ld (HDAE5000_RAM_PportPartMask:24), w
	nop
	ld (xix), w			; update cmd[0] with masked value
	ld a, (xix + 1)			; A = cmd[1]
	nop
	ld (0x239084:24), a; [0x239084] = cmd[1] (raw head byte)
	nop
	ld w, (HDAE5000_RAM_PportArg4:24)
	nop
	and w, a			; W = cmd[1] AND head_mask
	ld (HDAE5000_RAM_PportPartMaskHi:24), w
	nop
	ld (xix + 1), w			; update cmd[1] with masked value
	nop
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)		; exit to PPORT finish
	nop
	cp (HDAE5000_RAM_PportPartMask:24), 0x00
	jp z, (.Lwmhd_done:24)
	nop
	jp .Lwmhd_do_write
.Lwmhd_check_head:
	cp (HDAE5000_RAM_PportPartMaskHi:24), 0x00
	jp z, (.Lwmhd_done:24)
	nop
.Lwmhd_do_write:
	call HDAE5000_PPORT_ClearPacket
	ld xix, (HDAE5000_RAM_PportInfoPtr:24)
	nop
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	ld (xix), a			; store to data[0]
	ld a, (HDAE5000_RAM_PportPartMaskHi:24)
	nop
	ld (xix + 1), a			; store to data[1]
	nop
	xor xbc, xbc			; XBC = 0
	xor xde, xde			; XDE = 0
	ld c, (HDAE5000_RAM_PportArg1:24)
	nop
	ld e, (HDAE5000_RAM_PportArg2:24)
	nop
	ldw wa, 0x001B			; WA = 0x1B (write command)
	nop
	ei 0x00				; IFF=0: accepts every interrupt level (06 00; was mis-spelled `di`)
	call HDAE5000_PPORT_CallService
	ei 0x07				; IFF=7: masks every maskable level -- this IS the real DI (06 07)
	cp wa, 0:i3			; result == 0?
	jp z, (.Lwmhd_after_write:24)		; skip error
	nop
	call HDAE5000_PPORT_FlagPacketError
.Lwmhd_after_write:
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)		; exit
	nop
.Lwmhd_done:
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd17_FormatHd:	; (62 bytes)
	; PC-link command 17: HDAE5000_PPORT_CommandTable entry 16; first shows the
	; status record "17>Formating HD" (HDAE5000_PPORT_Strings + 384, service 26).
	; The description lines below predate this name and are not re-verified.
	; Reserved PPORT command - display status, clear buffer, check result
	ldw wa, 0x001a			; display row/column
	nop
	lda xbc, (HDAE5000_PPORT_Cmd17_FormatHd_Str_N17_Formating_HD:24); lda XBC, (0x294ECC) - status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_ClearPacket
	ldw wa, 0x0011			; display row/column
	nop
	ei 0x00				; enable interrupts
	call HDAE5000_PPORT_CallService
	ei 0x07				; disable interrupts
	cp wa, 0:i3			; check result
	jp z, (.LPPORT_Cmd17_FormatHd_Skip1:24)		; jp Z - skip cleanup if zero
	nop
	call HDAE5000_PPORT_FlagPacketError
.LPPORT_Cmd17_FormatHd_Skip1:
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)		; jp Z - exit to PPORT finish
	nop
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd18_SwitchHdMotorOff:	; (60 bytes)
	; PC-link command 18: HDAE5000_PPORT_CommandTable entry 17; first shows the
	; status record "18>Switch HD-motor off" (HDAE5000_PPORT_Strings + 408, service 26).
	; The description lines below predate this name and are not re-verified.
	; PPORT utility - display status, clear buffer, check result
	ldw wa, 0x001a			; display row/column
	nop
	lda xbc, (HDAE5000_PPORT_Cmd18_SwitchHdMotorOff_Str_N18_Switch_HD_motor_off:24); lda XBC, (0x294EE4) - status string
	nop
	call HDAE5000_PPORT_CallService
	call HDAE5000_PPORT_ClearPacket
	ld wa, 2:i3			; WA = 2
	ei 0x00				; enable interrupts
	call HDAE5000_PPORT_CallService
	ei 0x07				; disable interrupts
	cp wa, 0:i3			; check result
	jp z, (.LPPORT_Cmd18_SwitchHdMotorOff_Skip1:24)		; jp Z - skip cleanup if zero
	nop
	call HDAE5000_PPORT_FlagPacketError
.LPPORT_Cmd18_SwitchHdMotorOff_Skip1:
	call HDAE5000_PPORT_SendPacket
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)		; jp Z - exit to PPORT finish
	nop
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd19_Nothing:
	; PC-link command 19: HDAE5000_PPORT_CommandTable entry 18; first shows the
	; status record "19>nothing" (HDAE5000_PPORT_Strings + 432, service 26).
	; The description lines below predate this name and are not re-verified.
	; PPORT utility routine 2 - display status and finish
	ldw wa, 0x001a			; display row/column
	nop
	lda xbc, (HDAE5000_PPORT_Cmd19_Nothing_Str_N19_nothing:24); 0x294EFC - status string
	nop
	call HDAE5000_PPORT_CallService
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_Cmd20_SendXapFileFlash:	; (164 bytes)
	; PC-link command 20: HDAE5000_PPORT_CommandTable entry 19; first shows the
	; status record "20>Send XapFile flash" (HDAE5000_PPORT_Strings + 456, service 26).
	; The description lines below predate this name and are not re-verified.
	; PPORT utility routine 3 — display string, read PPORT data, execute,
	; check status, display result string (success or error)
	ldw wa, 0x001a				; display command
	nop
	lda xbc, (HDAE5000_PPORT_Cmd20_SendXapFileFlash_Str_N20_Send_XapFile_flash:24); lda XBC, 0x294F14 — string pointer
	nop
	call HDAE5000_PPORT_CallService
	ld xbc, 0:i3
	ld xde, 0:i3
	ldw wa, 0x001D				; display command
	nop
	call HDAE5000_PPORT_CallService
	ei 7					; IFF=7: masks every maskable level -- this IS the real DI (06 07)
	lda xix, (HDAE5000_RAM_PportPacket:24)	; PPORT command area
	nop
	ld xwa, (xix + 2)			; read 32-bit parameter
	nop
	ld (0x2390a8:24), xwa; st (0x2390a8), XWA — store parameter
	nop
	ld xiy, 0x00010000			; block size 64KB
	nop
	ld xde, (0x2390a8:24); ld XDE, (0x2390a8)
	nop
	call HDAE5000_PPORT_RecvBlock				; execute operation
	cp (HDAE5000_RAM_PportError:24), 0x01	; check status flag
	jp z, (HDAE5000_PPORT_CommandLoop_Poll:24)			; abort if status=1
	nop
	ld xbc, 0x00010000			; block size
	nop
	ld xde, 0x002390a8			; data address (immediate)
	nop
	ldw wa, 0x001C				; display command
	nop
	call HDAE5000_PPORT_CallService
	ld (0x23909e:24), wa; st (0x23909E), WA — save result
	nop
	ei	0					; IFF=0: accepts every interrupt level (06 00; was mis-spelled `di`)
	ld xbc, 0:i3
	ld xde, 0:i3
	ldw wa, 0x001E				; display command
	nop
	call HDAE5000_PPORT_CallService
	ld wa, (0x23909e:24); ld WA, (0x23909E) — reload result
	nop
	cp wa, 0x0058				; check result value
	jp z, (.Lpu3_success:24)			; jump if success
	nop
	; Error path
	ldw wa, 0x001A				; display command
	nop
	lda xbc, (HDAE5000_PPORT_Cmd20_Str_EndFlashFalse:24); lda XBC, 0x294f42 — error string
	nop
	call HDAE5000_PPORT_CallService
	jp HDAE5000_PPORT_CommandDone
.Lpu3_success:
	; Success path
	ldw wa, 0x001a				; display command
	nop
	lda xbc, (HDAE5000_PPORT_Cmd20_Str_EndFlashRight:24); lda XBC, 0x294F2C — success string
	nop
	call HDAE5000_PPORT_CallService
	jp HDAE5000_PPORT_CommandDone

HDAE5000_PPORT_CommandDone:	; (4 bytes)
	; PPORT command completion - jump to finish handler
	jp HDAE5000_PPORT_CommandLoop_Poll

; ---------------------------------------------------------------------------
; Latch bytes 1..4 of the link packet (the command's arguments) into
; HDAE5000_RAM_PportArg1..PportArg4.  Out: XIX = HDAE5000_RAM_PportPacket.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_LatchPacketArgs:
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld a, (xix + 1)
	nop
	ld (HDAE5000_RAM_PportArg1:24), a
	nop
	ld a, (xix + 2)
	nop
	ld (HDAE5000_RAM_PportArg2:24), a
	nop
	ld a, (xix + 3)
	nop
	ld (HDAE5000_RAM_PportArg3:24), a
	nop
	ld a, (xix + 4)
	nop
	ld (HDAE5000_RAM_PportArg4:24), a
	nop
	ret
	nop

; ---------------------------------------------------------------------------
; Run service 13 (SendInfosAboutSong) for directory PportArg1, song
; PportArg2 through HDAE5000_PPORT_CallService, with interrupts enabled
; around the call (ei 0 ... ei 7).
; Out: WA = the service's result (0 = the song exists).
; ---------------------------------------------------------------------------
HDAE5000_PPORT_RequestSongInfo:
	xor xbc, xbc
	xor xde, xde
	ld c, (HDAE5000_RAM_PportArg1:24)
	nop
	ld e, (HDAE5000_RAM_PportArg2:24)
	nop
	ldw wa, 0x000D
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ret
	nop

; ---------------------------------------------------------------------------
; Run service 1 (GetInfoBlockPointer) and keep its XIX, the address of
; HDAE5000_RAM_PportInfoBlock, in HDAE5000_RAM_PportInfoPtr.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_GetInfoBlock:
	ld wa, 1:i3
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ld (HDAE5000_RAM_PportInfoPtr:24), xix
	nop
	ret
	nop

; ---------------------------------------------------------------------------
; Receive the 256-byte link packet into HDAE5000_RAM_PportPacket
; (HDAE5000_PPORT_RecvByte), summing it into PportChecksum; send the 4
; checksum bytes back, then HDAE5000_PPORT_EndBlock; the whole packet is
; received again while EndBlock returns W != 0.  Returns at once when a byte
; sets HDAE5000_RAM_PportError.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_RecvPacket:
	xor xwa, xwa
	ld (HDAE5000_RAM_PportChecksum:24), xwa
	nop
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
.Lrdr2_loop1:
	cp bc, 0x0100
	jp z, (.Lrdr2_send_checksum:24)
	nop
	call HDAE5000_PPORT_RecvByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lrdr2_exit:24)
	nop
	ld	(xix+bc), w
	nop
	xor xhl, xhl
	ld l, w
	add (HDAE5000_RAM_PportChecksum:24), xhl
	nop
	inc 1, bc
	jr t, .Lrdr2_loop1
.Lrdr2_send_checksum:
	; Send 4 checksum bytes
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportChecksum:24)
	nop
.Lrdr2_loop2:
	cp bc, 4:i3
	jp z, (.Lrdr2_finalize:24)
	nop
	ld	w, (xix+bc)
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lrdr2_exit:24)
	nop
	inc 1, bc
	jr t, .Lrdr2_loop2
.Lrdr2_finalize:
	call HDAE5000_PPORT_EndBlock
	cp w, 0:i3
	jr z, .Lrdr2_exit
	jp HDAE5000_PPORT_RecvPacket
.Lrdr2_exit:
	ret
	nop

; ---------------------------------------------------------------------------
; Send the 256-byte PC-link packet: each byte through HDAE5000_PPORT_SendByte
; while summing it into HDAE5000_RAM_PportChecksum, then the 4 checksum
; bytes, then HDAE5000_PPORT_EndBlock; the whole packet is sent again while
; EndBlock returns W != 0.  Returns at once when a byte sets
; HDAE5000_RAM_PportError.
; RAM: HDAE5000_RAM_PportPacket, HDAE5000_RAM_PportChecksum,
;      HDAE5000_RAM_PportError
; ---------------------------------------------------------------------------
HDAE5000_PPORT_SendPacket:
	xor xwa, xwa
	ld (HDAE5000_RAM_PportChecksum:24), xwa	; clear 32-bit checksum
	nop
	ld bc, 0:i3				; counter = 0
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
.Lpsb_loop1:				; — send buffer bytes and accumulate checksum
	cp bc, 0x0100				; 256 iterations?
	jp z, (.Lpsb_send_checksum:24)			; done, send checksum
	nop
	ld	w, (xix+bc)		; ld W, (XIX+BC) — read buffer byte
	nop
	xor xhl, xhl
	ld l, w					; L = W (zero-extend to 32-bit)
	add (HDAE5000_RAM_PportChecksum:24), xhl	; accumulate
	nop
	call HDAE5000_PPORT_SendByte			; send byte via PPORT
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lpsb_exit:24)			; exit on error
	nop
	inc 1, bc
	jr t, .Lpsb_loop1
.Lpsb_send_checksum:
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportChecksum:24)	; checksum bytes
	nop
.Lpsb_loop2:				; — send 4 checksum bytes
	cp bc, 4:i3
	jp z, (.Lpsb_finalize:24)			; done
	nop
	ld	w, (xix+bc)		; ld W, (XIX+BC) — checksum byte
	nop
	call HDAE5000_PPORT_SendByte			; send byte
	cp (HDAE5000_RAM_PportError:24), 0x01; error check
	jp z, (.Lpsb_exit:24)			; exit on error
	nop
	inc 1, bc
	jr t, .Lpsb_loop2
.Lpsb_finalize:
	call HDAE5000_PPORT_EndBlock			; finalize transfer
	cp w, 0:i3				; check result
	jr z, .Lpsb_exit
	jp HDAE5000_PPORT_SendPacket		; retry
.Lpsb_exit:
	ret
	nop

; ---------------------------------------------------------------------------
; Receive byte W from the PC over the 8255: wait for port C bit 0 = 1, then
; bit 1 = 0; control word 0x99 (port A input), pulse port B bit 3 low, wait
; for port C bit 1 = 1, read port A, control word 0x89 again and port B bit
; 3 high.  Port C bit 2 must stay 1 throughout: when it drops,
; HDAE5000_RAM_PportError = 1 and the byte is abandoned.
; Out: W = byte.  Clobbers A, L.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_RecvByte:			; — Read one byte from parallel port → W
	ld a, (HDAE5000_IO_PpiPortC:24)
	nop
	ld l, a
	and l, 0x04
	nop
	cp l, 4:i3
	jp nz, (.Lpsb_read_error:24)
	nop
	and a, 0x01
	nop
	cp a, 1:i3
	jp nz, (HDAE5000_PPORT_RecvByte:24)
	nop
.Lpsb_read_phase2:
	ld a, (HDAE5000_IO_PpiPortC:24)
	nop
	ld l, a
	and l, 0x04
	nop
	cp l, 4:i3
	jp nz, (.Lpsb_read_error:24)
	nop
	and a, 0x02
	nop
	cp a, 0:i3
	jp nz, (.Lpsb_read_phase2:24)
	nop
	ld a, 0x99:opc
	ld (HDAE5000_IO_PpiControl:24), a
	nop
	ld a, (HDAE5000_IO_PpiPortB:24)
	nop
	and a, 0xF7
	nop
	ld (HDAE5000_IO_PpiPortB:24), a
	nop
.Lpsb_read_phase3:
	ld a, (HDAE5000_IO_PpiPortC:24)
	nop
	ld l, a
	and l, 0x04
	nop
	cp l, 4:i3
	jp nz, (.Lpsb_read_error:24)
	nop
	and a, 0x02
	nop
	cp a, 2:i3
	jp nz, (.Lpsb_read_phase3:24)
	nop
	ld w, (HDAE5000_IO_PpiPortA:24)
	nop
	ld a, 0x89:opc
	ld (HDAE5000_IO_PpiControl:24), a
	nop
	ld a, (HDAE5000_IO_PpiPortB:24)
	nop
	or a, 0x08
	nop
	ld (HDAE5000_IO_PpiPortB:24), a
	nop
	ret
	nop
.Lpsb_read_error:
	ld (HDAE5000_RAM_PportError:24), 0x01
	ret
	nop

; ---------------------------------------------------------------------------
; Send byte W to the PC over the 8255: wait for port C bit 0 = 0, write W to
; port A, pulse port B bit 3 low, wait for port C bit 1 = 0, raise port B bit 3
; again, wait for port C bit 1 = 1.  Port C bit 2 must stay 1 throughout:
; when it drops, HDAE5000_RAM_PportError is set to 1 and the byte is
; abandoned.
; In:  W = byte
; Out: clobbers A, L.
; I/O: HDAE5000_IO_PpiPortA, _PpiPortB, _PpiPortC
; ---------------------------------------------------------------------------
HDAE5000_PPORT_SendByte:			; — Write byte W to parallel port
	ld a, (HDAE5000_IO_PpiPortC:24)	; status
	nop
	ld l, a
	and l, 0x04
	nop
	cp l, 4:i3
	jp nz, (.Lpsb_write_error:24)
	nop
	and a, 0x01
	nop
	cp a, 0:i3				; wait for bit0=0
	jp nz, (HDAE5000_PPORT_SendByte:24)			; retry
	nop
	ld (HDAE5000_IO_PpiPortA:24), w	; write data
	nop
	ld a, (HDAE5000_IO_PpiPortB:24)
	nop
	and a, 0xF7				; clear bit 3
	nop
	ld (HDAE5000_IO_PpiPortB:24), a
	nop
.Lpsb_write_phase2:
	ld a, (HDAE5000_IO_PpiPortC:24)
	nop
	ld l, a
	and l, 0x04
	nop
	cp l, 4:i3
	jp nz, (.Lpsb_write_error:24)			; jp NZ, error
	nop
	and a, 0x02
	nop
	cp a, 0:i3				; wait for bit1=0
	jp nz, (.Lpsb_write_phase2:24)			; retry
	nop
	ld a, (HDAE5000_IO_PpiPortB:24)
	nop
	or a, 0x08				; set bit 3
	nop
	ld (HDAE5000_IO_PpiPortB:24), a
	nop
.Lpsb_write_phase3:
	ld a, (HDAE5000_IO_PpiPortC:24)
	nop
	ld l, a
	and l, 0x04
	nop
	cp l, 4:i3
	jp nz, (.Lpsb_write_error:24)			; jp NZ, error
	nop
	and a, 0x02
	nop
	cp a, 2:i3				; wait for bit1=1
	jp nz, (.Lpsb_write_phase3:24)			; retry
	nop
	ret
	nop
.Lpsb_write_error:
	ld (HDAE5000_RAM_PportError:24), 0x01	; set error flag
	ret
	nop

; ---------------------------------------------------------------------------
; Close a checksummed block: port B bit 3 low, wait for port C bit 1 = 0,
; W = port C bit 0 (the PC's verdict: nonzero = send the block again), port B
; bit 3 high, wait for port C bit 1 = 1.  A drop of port C bit 2 sets
; HDAE5000_RAM_PportError = 1.
; Out: W = 0 (block accepted) or 1 (resend).  Clobbers A, L.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_EndBlock:				; — Finalize parallel port transfer
	ld a, (HDAE5000_IO_PpiPortB:24)
	nop
	and a, 0xF7
	nop
	ld (HDAE5000_IO_PpiPortB:24), a
	nop
.Lpsb_fin_wait1:
	ld a, (HDAE5000_IO_PpiPortC:24)
	nop
	ld l, a
	and l, 0x04
	nop
	cp l, 4:i3
	jp nz, (.Lpsb_fin_error:24)
	nop
	and a, 0x02
	nop
	cp a, 0:i3
	jr nz, .Lpsb_fin_wait1
	ld w, (HDAE5000_IO_PpiPortC:24)
	nop
	and w, 0x01
	nop
	ld a, (HDAE5000_IO_PpiPortB:24)
	nop
	or a, 0x08
	nop
	ld (HDAE5000_IO_PpiPortB:24), a
	nop
.Lpsb_fin_wait2:
	ld a, (HDAE5000_IO_PpiPortC:24)
	nop
	ld l, a
	and l, 0x04
	nop
	cp l, 4:i3
	jp nz, (.Lpsb_fin_error:24)
	nop
	and a, 0x02
	nop
	cp a, 2:i3
	jr nz, .Lpsb_fin_wait2
	ret
	nop
.Lpsb_fin_error:
	ld (HDAE5000_RAM_PportError:24), 0x01
	ret
	nop

; ---------------------------------------------------------------------------
; Zero the 256-byte PC-link packet.
; Out: XIX = HDAE5000_RAM_PportPacket, BC = 0x0100.
; RAM: HDAE5000_RAM_PportPacket
; ---------------------------------------------------------------------------
HDAE5000_PPORT_ClearPacket:
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld bc, 0:i3		; BC = 0 (loop counter)
.Lprc_loop:
	cp bc, 0x0100		; compare BC with 256
	jr z, .Lprc_done	; if BC == 256, done
	ld	(xix+bc), 0x00
	inc 1, bc		; BC++
	jr t, .Lprc_loop	; always loop back
.Lprc_done:
	ret
	nop

; ---------------------------------------------------------------------------
; Mark the reply packet failed: byte 255 of HDAE5000_RAM_PportPacket = 0xFF.
; The command handlers call it when a step fails, before
; HDAE5000_PPORT_SendPacket.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_FlagPacketError:
	lda xix, (HDAE5000_RAM_PportPacket:24)
	nop
	ld	(xix+255), 0xff
	ret
	nop

; ---------------------------------------------------------------------------
; Run service 1 (the info block address, kept in PportInfoPtr), then copy
; bytes BC..HL-1 of HDAE5000_RAM_PportInfoBlock to the same offsets of the
; link packet.
; In:  BC = first offset, HL = end offset
; ---------------------------------------------------------------------------
HDAE5000_PPORT_CopyInfoToPacket:				; — Display + save XIX + copy buffer
	pushw bc
	nop
	pushw hl
	nop
	ld wa, 1:i3
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	ld (HDAE5000_RAM_PportInfoPtr:24), xix
	nop
	popw hl
	nop
	popw bc
	nop
	lda xiy, (HDAE5000_RAM_PportPacket:24)
	nop
.Lutl_copy_loop:
	cp bc, hl
	jr z, .Lutl_ret
	ld	a, (xix+bc)
	nop
	ld	(xiy+bc), a
	nop
	inc 1, bc
	jr t, .Lutl_copy_loop
.Lutl_ret:
	ret
	nop

; ---------------------------------------------------------------------------
; Send XDE bytes from XIY to the PC (HDAE5000_PPORT_SendByte) with the
; running sum, then the 4 checksum bytes and HDAE5000_PPORT_EndBlock; the
; block is sent again (from PportBlockPtr / PportBlockLen) while EndBlock
; returns W != 0.  Stops when HDAE5000_RAM_PportError is set.
; In:  XIY = data, XDE = byte count
; ---------------------------------------------------------------------------
HDAE5000_PPORT_SendBlock:			; — Send XIY bytes to PPORT with checksum
	ld (HDAE5000_RAM_PportBlockPtr:24), xiy
	nop
	ld (HDAE5000_RAM_PportBlockLen:24), xde
	nop
.Lsb_loop_start:
	xor xwa, xwa
	ld (HDAE5000_RAM_PportChecksum:24), xwa
	nop
	ld xbc, 0:i3
.Lsb_send_loop:
	cp xde, xbc
	jp z, (.Lsb_checksum:24)
	nop
	ld w, (xiy)
	xor xhl, xhl
	ld l, w
	add (HDAE5000_RAM_PportChecksum), xhl
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lsb_ret:24)
	nop
	inc 1, xbc
	inc 1, xiy
	jp .Lsb_send_loop
.Lsb_checksum:
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportChecksum:24)
	nop
.Lsb_cksum_loop:
	cp bc, 4:i3
	jp z, (.Lsb_finalize:24)
	nop
	ld	w, (xix+bc)
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lsb_ret:24)
	nop
	inc 1, bc
	jr t, .Lsb_cksum_loop
.Lsb_finalize:
	call HDAE5000_PPORT_EndBlock
	cp w, 0:i3
	jr z, .Lsb_ret
	ld xiy, (HDAE5000_RAM_PportBlockPtr:24)
	nop
	ld xde, (HDAE5000_RAM_PportBlockLen:24)
	nop
	jp .Lsb_loop_start
.Lsb_ret:
	ret
	nop

; ---------------------------------------------------------------------------
; Receive XDE bytes into XIY from the PC with the running sum, wait for
; port C bit 0 = 0, send the 4 checksum bytes back and HDAE5000_PPORT_EndBlock;
; the block is received again while EndBlock returns W != 0.  Stops when
; HDAE5000_RAM_PportError is set.
; In:  XIY = buffer, XDE = byte count
; ---------------------------------------------------------------------------
HDAE5000_PPORT_RecvBlock:		; — Receive XDE bytes into XIY with checksum
	ld (HDAE5000_RAM_PportBlockPtr:24), xiy
	nop
	ld (HDAE5000_RAM_PportBlockLen:24), xde
	nop
.Lrb_loop_start:
	xor xwa, xwa
	ld (HDAE5000_RAM_PportChecksum:24), xwa
	nop
	ld xbc, 0:i3
.Lrb_recv_loop:
	cp xde, xbc
	jp z, (.Lrb_status_check:24)
	nop
	call HDAE5000_PPORT_RecvByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lrb_ret:24)
	nop
	ld (xiy), w
	xor xhl, xhl
	ld l, w
	add (HDAE5000_RAM_PportChecksum), xhl
	nop
	inc 1, xbc
	inc 1, xiy
	jp .Lrb_recv_loop
.Lrb_status_check:
	ld a, (HDAE5000_IO_PpiPortC:24)
	nop
	ld l, a
	and l, 0x04
	nop
	cp l, 4:i3
	jp nz, (.Lrb_set_error:24)
	nop
	and a, 0x01
	nop
	cp a, 0:i3
	jr nz, .Lrb_status_check
.Lrb_recv_cksum:
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportChecksum:24)
	nop
.Lrb_cksum_loop:
	cp bc, 4:i3
	jp z, (.Lrb_finalize:24)
	nop
	ld	w, (xix+bc)
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lrb_ret:24)
	nop
	inc 1, bc
	jr t, .Lrb_cksum_loop
.Lrb_finalize:
	call HDAE5000_PPORT_EndBlock
	cp w, 0:i3
	jp z, (.Lrb_ret:24)
	nop
	ld xiy, (HDAE5000_RAM_PportBlockPtr:24)
	nop
	ld xde, (HDAE5000_RAM_PportBlockLen:24)
	nop
	jp .Lrb_loop_start
.Lrb_set_error:
	ld (HDAE5000_RAM_PportError:24), 0x01
.Lrb_ret:
	ret
	nop

; ---------------------------------------------------------------------------
; Receive 512 bytes into HDAE5000_RAM_PportSectorBuffer with the running sum,
; send the 4 checksum bytes back and HDAE5000_PPORT_EndBlock; again while it
; returns W != 0.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_RecvSector:		; — Receive 512-byte sector block
	xor xwa, xwa
	ld (HDAE5000_RAM_PportChecksum:24), xwa
	nop
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportSectorBuffer:24)
	nop
.Lrs_recv_loop:
	cp bc, 0x0200
	jp z, (.Lrs_checksum:24)
	nop
	call HDAE5000_PPORT_RecvByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lrs_ret:24)
	nop
	ld	(xix+bc), w
	nop
	xor xhl, xhl
	ld l, w
	add (HDAE5000_RAM_PportChecksum), xhl
	nop
	inc 1, bc
	jr t, .Lrs_recv_loop
.Lrs_checksum:
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportChecksum:24)
	nop
.Lrs_cksum_loop:
	cp bc, 4:i3
	jp z, (.Lrs_finalize:24)
	nop
	ld	w, (xix+bc)
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lrs_ret:24)
	nop
	inc 1, bc
	jr t, .Lrs_cksum_loop
.Lrs_finalize:
	call HDAE5000_PPORT_EndBlock
	cp w, 0:i3
	jr z, .Lrs_ret
	jp HDAE5000_PPORT_RecvSector
.Lrs_ret:
	ret
	nop

; ---------------------------------------------------------------------------
; Send the regions of pairs 0 and 1 of HDAE5000_RAM_PportRegions ({address,
; size} longs) as one checksummed block, then HDAE5000_PPORT_EndBlock; again
; while it returns W != 0.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_SendTwoRegions:			; — Send two descriptor regions + checksum
	ld xiy, (HDAE5000_RAM_PportRegions:24)
	nop
	ld xde, (HDAE5000_RAM_PportRegions+4:24)
	nop
	xor xwa, xwa
	ld (HDAE5000_RAM_PportChecksum:24), xwa
	nop
	ld xbc, 0:i3
.Lsr_loop1:
	cp xde, xbc
	jp z, (.Lsr_region2:24)
	nop
	ld w, (xiy)
	xor xhl, xhl
	ld l, w
	add (HDAE5000_RAM_PportChecksum), xhl
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lsr_ret:24)
	nop
	inc 1, xbc
	inc 1, xiy
	jp .Lsr_loop1
.Lsr_region2:
	ld xiy, (HDAE5000_RAM_PportRegions+8:24)
	nop
	ld xde, (HDAE5000_RAM_PportRegions+12:24)
	nop
	ld xbc, 0:i3
.Lsr_loop2:
	cp xde, xbc
	jp z, (.Lsr_checksum:24)
	nop
	ld w, (xiy)
	xor xhl, xhl
	ld l, w
	add (HDAE5000_RAM_PportChecksum), xhl
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lsr_ret:24)
	nop
	inc 1, xbc
	inc 1, xiy
	jp .Lsr_loop2
.Lsr_checksum:
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportChecksum:24)
	nop
.Lsr_cksum_loop:
	cp bc, 4:i3
	jp z, (.Lsr_finalize:24)
	nop
	ld	w, (xix+bc)
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lsr_ret:24)
	nop
	inc 1, bc
	jr t, .Lsr_cksum_loop
.Lsr_finalize:
	call HDAE5000_PPORT_EndBlock
	cp w, 0:i3
	jr z, .Lsr_ret
	jp HDAE5000_PPORT_SendTwoRegions
.Lsr_ret:
	ret
	nop

; ---------------------------------------------------------------------------
; Receive one checksummed block of 0x640 bytes into 0xF980 followed by 0x800
; bytes into 0x1E7800 (both outside this ROM's RAM; what they hold is not
; established), then the 4 checksum bytes back and HDAE5000_PPORT_EndBlock;
; again while it returns W != 0.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_RecvCustomData:		; — Receive custom ROM data
	ld xiy, 0x0000F980
	nop
	ld xde, 0x00000640
	nop
	xor xwa, xwa
	ld (HDAE5000_RAM_PportChecksum:24), xwa
	nop
	ld xbc, 0:i3
.Lrc_loop1:
	cp xde, xbc
	jp z, (.Lrc_phase2:24)
	nop
	call HDAE5000_PPORT_RecvByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lrc_ret:24)
	nop
	ld (xiy), w
	xor xhl, xhl
	ld l, w
	add (HDAE5000_RAM_PportChecksum), xhl
	nop
	inc 1, xbc
	inc 1, xiy
	jp .Lrc_loop1
.Lrc_phase2:
	ld xiy, 0x001E7800
	nop
	ld xde, 0x00000800
	nop
	ld xbc, 0:i3
.Lrc_loop2:
	cp xde, xbc
	jp z, (.Lrc_checksum:24)
	nop
	call HDAE5000_PPORT_RecvByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lrc_ret:24)
	nop
	ld (xiy), w
	xor xhl, xhl
	ld l, w
	add (HDAE5000_RAM_PportChecksum), xhl
	nop
	inc 1, xbc
	inc 1, xiy
	jp .Lrc_loop2
.Lrc_checksum:
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportChecksum:24)
	nop
.Lrc_cksum_loop:
	cp bc, 4:i3
	jp z, (.Lrc_finalize:24)
	nop
	ld	w, (xix+bc)
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lrc_ret:24)
	nop
	inc 1, bc
	jr t, .Lrc_cksum_loop
.Lrc_finalize:
	call HDAE5000_PPORT_EndBlock
	cp w, 0:i3
	jr z, .Lrc_ret
	jp HDAE5000_PPORT_RecvCustomData
.Lrc_ret:
	ret
	nop

; ---------------------------------------------------------------------------
; Size one region per part bit of HDAE5000_RAM_PportPartMask (and bit 0 of
; PportPartMaskHi): fixed sizes 0xE40 (bit 0), 0x12CB0 (1), 0x72AA (4) and
; 0x400 (7), and for the ninth part (TLX) the ADDRESS of
; HDAE5000_RAM_LyricFileLength; bits 2, 3, 5, 6 read the size from
; the part file's first sector (HDAE5000_PPORT_InitRegionDescriptors_Lookup
; with field offset 0x4E / 0x2E / 0x1E word fields, 0x1C long; bit 2 adds
; 0x5000).  The slots of HDAE5000_RAM_PportRegions are cleared first.  Stops
; at the first lookup that fails (PportStepError = 1).
; ---------------------------------------------------------------------------
HDAE5000_PPORT_InitRegionDescriptors:	; — Initialize region descriptors
	ld xwa, 0:i3
	ld (HDAE5000_RAM_PportRegions+4:24), xwa
	nop
	ld (HDAE5000_RAM_PportRegions+12:24), xwa
	nop
	ld (HDAE5000_RAM_PportRegions+20:24), xwa
	nop
	ld (HDAE5000_RAM_PportRegions+28:24), xwa
	nop
	ld (HDAE5000_RAM_PportRegions+36:24), xwa
	nop
	ld (HDAE5000_RAM_PportRegions+44:24), xwa
	nop
	ld (HDAE5000_RAM_PportRegions+52:24), xwa
	nop
	ld (HDAE5000_RAM_PportRegions+56:24), xwa
	nop
	ld (HDAE5000_RAM_PportRegions+64:24), xwa
	nop
	ld (HDAE5000_RAM_PportRegions+72:24), xwa
	nop
	; Bit 0: custom region size
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x01
	nop
	cp a, 1:i3
	jp nz, (.Lir_bit1:24)
	nop
	ld xwa, 0x00000E40
	nop
	ld (HDAE5000_RAM_PportRegions+4:24), xwa
	nop
.Lir_bit1:
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x02
	nop
	cp a, 2:i3
	jp nz, (.Lir_bit2:24)
	nop
	ld xwa, 0x00012CB0
	nop
	ld (HDAE5000_RAM_PportRegions+20:24), xwa
	nop
.Lir_bit2:
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x04
	nop
	cp a, 4:i3
	jp nz, (.Lir_bit3:24)
	nop
	ld e, 0x04:opc
	ld (HDAE5000_RAM_PportSizeFieldWidth:24), 0x10
	ld (HDAE5000_RAM_PportSizeFieldOffset:24), 0x4E
	call HDAE5000_PPORT_InitRegionDescriptors_Lookup
	cp (HDAE5000_RAM_PportStepError:24), 0x01
	jp z, (.Lir_ret:24)
	nop
	add xiy, 0x00005000
	ld (HDAE5000_RAM_PportRegions+28:24), xiy
	nop
.Lir_bit3:
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x08
	nop
	cp a, 0x08
	nop
	jp nz, (.Lir_bit4:24)
	nop
	ld e, 0x08:opc
	ld (HDAE5000_RAM_PportSizeFieldWidth:24), 0x10
	ld (HDAE5000_RAM_PportSizeFieldOffset:24), 0x2E
	call HDAE5000_PPORT_InitRegionDescriptors_Lookup
	cp (HDAE5000_RAM_PportStepError:24), 0x01
	jp z, (.Lir_ret:24)
	nop
	ld (HDAE5000_RAM_PportRegions+36:24), xiy
	nop
.Lir_bit4:
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x10
	nop
	cp a, 0x10
	nop
	jp nz, (.Lir_bit5:24)
	nop
	ld xwa, 0x000072AA
	nop
	ld (HDAE5000_RAM_PportRegions+44:24), xwa
	nop
.Lir_bit5:
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x20
	nop
	cp a, 0x20
	nop
	jp nz, (.Lir_bit6:24)
	nop
	ld e, 0x20:opc
	ld (HDAE5000_RAM_PportSizeFieldWidth:24), 0x10
	ld (HDAE5000_RAM_PportSizeFieldOffset:24), 0x1E
	call HDAE5000_PPORT_InitRegionDescriptors_Lookup
	cp (HDAE5000_RAM_PportStepError:24), 0x01
	jp z, (.Lir_ret:24)
	nop
	ld (HDAE5000_RAM_PportRegions+52:24), xiy
	nop
.Lir_bit6:
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x40
	nop
	cp a, 0x40
	nop
	jp nz, (.Lir_bit7:24)
	nop
	ld e, 0x40:opc
	ld (HDAE5000_RAM_PportSizeFieldWidth:24), 0x20
	ld (HDAE5000_RAM_PportSizeFieldOffset:24), 0x1C
	call HDAE5000_PPORT_InitRegionDescriptors_Lookup
	cp (HDAE5000_RAM_PportStepError:24), 0x01
	jp z, (.Lir_ret:24)
	nop
	ld (HDAE5000_RAM_PportRegions+56:24), xiy
	nop
.Lir_bit7:
	ld a, (HDAE5000_RAM_PportPartMask:24)
	nop
	and a, 0x80
	nop
	cp a, 0x80
	nop
	jp nz, (.Lir_flag2_bit0:24)
	nop
	ld xwa, 0x00000400
	nop
	ld (HDAE5000_RAM_PportRegions+64:24), xwa
	nop
.Lir_flag2_bit0:
	ld a, (HDAE5000_RAM_PportPartMaskHi:24)
	nop
	and a, 0x01
	nop
	cp a, 1:i3
	jp nz, (.Lir_ret:24)
	nop
	ld xwa, HDAE5000_RAM_LyricFileLength
	nop
	ld (HDAE5000_RAM_PportRegions+72:24), xwa
	nop
.Lir_ret:
	ret
	nop

; ---------------------------------------------------------------------------
; Read the size field of one part file: put the part bit E as mask word at
; PportInfoBlock+0, service 24 (ReadOpenHD) for directory PportArg1, song
; PportArg2, service 25 (ReadFileHD) of 512 bytes into
; HDAE5000_RAM_PportSectorBuffer, then the field at PportSizeFieldOffset:
; a long when PportSizeFieldWidth is 0x20, else a word x 16.  A failed service
; sets HDAE5000_RAM_PportStepError = 1.
; In:  E = part bit
; Out: XIY = size.  Clobbers XWA, XBC, XDE, XIX.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_InitRegionDescriptors_Lookup:
	ld xix, (HDAE5000_RAM_PportInfoPtr:24)
	nop
	ld (HDAE5000_RAM_PportStepError:24), 0x00
	xor wa, wa
	ld a, e
	ld (xix), wa
	xor xbc, xbc
	xor xde, xde
	ld c, (HDAE5000_RAM_PportArg1:24)
	nop
	ld e, (HDAE5000_RAM_PportArg2:24)
	nop
	ldw wa, 0x0018
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3
	jp z, (.Lcs_read_sector:24)
	nop
	ld (HDAE5000_RAM_PportStepError:24), 0x01
	jr t, .Lcs_ret
.Lcs_read_sector:
	lda xbc, (HDAE5000_RAM_PportSectorBuffer:24)
	nop
	ld xde, 0x00000200
	nop
	ldw wa, 0x0019
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3
	jp z, (.Lcs_process:24)
	nop
	ld (HDAE5000_RAM_PportStepError:24), 0x01
	jr t, .Lcs_ret
.Lcs_process:
	xor xwa, xwa
	lda xix, (HDAE5000_RAM_PportSectorBuffer:24)
	nop
	ld a, (HDAE5000_RAM_PportSizeFieldOffset:24)
	nop
	add xix, xwa
	cp (HDAE5000_RAM_PportSizeFieldWidth:24), 0x20
	jr z, .Lcs_load_xiy
	xor xwa, xwa
	ld wa, (xix)
	mul wa, 0x0010
	ld xiy, xwa
	jr t, .Lcs_ret
.Lcs_load_xiy:
	ld xiy, (xix)
.Lcs_ret:
	ret
	nop

; ---------------------------------------------------------------------------
; Send PportBytesLeft bytes of a part file to the PC as one checksummed
; block: put the part mask (PportSendMaskLo/Hi) in PportInfoBlock+0, open the
; read for directory PportArg1, song PportArg2 (service 24) and send one
; status byte first (0, or 0xFF when the open failed, which ends here); then
; read the file 512 bytes at a time (service 25) into PportSectorBuffer and
; send it byte by byte, then the checksum and HDAE5000_PPORT_EndBlock; the whole
; transfer is repeated while EndBlock returns W != 0.
; ---------------------------------------------------------------------------
HDAE5000_PPORT_SendRegionToPc:		; — Send region data to PC
	ld xwa, (HDAE5000_RAM_PportBytesLeft:24)
	nop
	ld (HDAE5000_RAM_PportBlockPtr:24), xwa
	nop
	xor xwa, xwa
	ld (HDAE5000_RAM_PportChecksum:24), xwa
	nop
	ld (HDAE5000_RAM_PportStepError:24), 0x00
	call HDAE5000_PPORT_GetInfoBlock
	ld xix, (HDAE5000_RAM_PportInfoPtr:24)
	nop
	xor wa, wa
	ld a, (HDAE5000_RAM_PportSendMaskLo:24)
	nop
	ld (xix), a
	ld a, (HDAE5000_RAM_PportSendMaskHi:24)
	nop
	ld (xix + 1), a
	nop
	xor bc, bc
	xor de, de
	ld c, (HDAE5000_RAM_PportArg1:24)
	nop
	ld e, (HDAE5000_RAM_PportArg2:24)
	nop
	ldw wa, 0x0018
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	cp wa, 0:i3
	jp z, (.Lsrpc_send_init:24)
	nop
	ldw wa, 0xFF00
	nop
	ld (HDAE5000_RAM_PportStepError:24), 0x01
.Lsrpc_send_init:
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lsrpc_ret:24)
	nop
	cp (HDAE5000_RAM_PportStepError:24), 0x01
	jp z, (.Lsrpc_ret:24)
	nop
	lda xix, (HDAE5000_RAM_PportSectorBuffer:24)
	nop
	ldw (HDAE5000_RAM_PportSectorOffset:24), 0x0200
	nop
.Lsrpc_main_loop:
	ld xwa, (HDAE5000_RAM_PportBytesLeft:24)
	nop
	cp xwa, 0
	jp z, (.Lsrpc_final_checksum:24)
	nop
	cpw (HDAE5000_RAM_PportSectorOffset:24), 0x0200
	nop
	jr z, .Lsrpc_read_block
	jr t, .Lsrpc_send_byte
.Lsrpc_read_block:
	push xix
	nop
	lda xbc, (xix)
	ld xde, 0x00000200
	nop
	ldw wa, 0x0019
	nop
	ei	0
	call HDAE5000_PPORT_CallService
	ei 7
	pop xix
	nop
	ldw (HDAE5000_RAM_PportSectorOffset:24), 0x0000
	nop
.Lsrpc_send_byte:
	ld bc, (HDAE5000_RAM_PportSectorOffset:24)
	nop
	ld	w, (xix+bc)
	nop
	xor xhl, xhl
	ld l, w
	add (HDAE5000_RAM_PportChecksum), xhl
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lsrpc_ret:24)
	nop
	incw	1, (HDAE5000_RAM_PportSectorOffset:24)
	nop
	ld xwa, (HDAE5000_RAM_PportBytesLeft:24)
	nop
	dec 1, xwa
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	jp .Lsrpc_main_loop
.Lsrpc_final_checksum:
	ld bc, 0:i3
	lda xix, (HDAE5000_RAM_PportChecksum:24)
	nop
.Lsrpc_cksum_loop:
	cp bc, 4:i3
	jp z, (.Lsrpc_finalize:24)
	nop
	ld	w, (xix+bc)
	nop
	call HDAE5000_PPORT_SendByte
	cp (HDAE5000_RAM_PportError:24), 0x01
	jp z, (.Lsrpc_ret:24)
	nop
	inc 1, bc
	jr t, .Lsrpc_cksum_loop
.Lsrpc_finalize:
	call HDAE5000_PPORT_EndBlock
	cp w, 0:i3
	jr z, .Lsrpc_ret
	ld xwa, (HDAE5000_RAM_PportBlockPtr:24)
	nop
	ld (HDAE5000_RAM_PportBytesLeft:24), xwa
	nop
	jp HDAE5000_PPORT_SendRegionToPc
.Lsrpc_ret:
	ret

; ---------------------------------------------------------------------------
; Clear HDAE5000_RAM_HdInitResult, run HDAE5000_HD_Init and return its step
; code.
; Out: HL = HdInitResult: 0 = drive up, ready and formatted; otherwise the
;      HD_Init step that failed (a missing drive times out in
;      HDAE5000_ATA_WaitReady and reports 3).  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_Check_HD_Present:
	push xiz
	ld (HDAE5000_RAM_HdInitResult:24), 0x00
	call HDAE5000_HD_Init
	pop xiz
	xor hl, hl
	ld l, (HDAE5000_RAM_HdInitResult:24)
	ret

; ============================================================================
; HD Detection, RAM Test, and String Formatting Library
; 0x2971B7-0x29AE9E (15,592 bytes, 11 identified routines)
;
; Contains:
;   - RAM test and verification (32KB at 0x230F1C-0x238F1C)
;   - HD initialization and drive detection (ATA IDENTIFY)
;   - CHS geometry configuration
;   - Version strings ("Technics Software section M. Kitajima", "2.33J")
;   - sprintf-like string formatting library (decimal/hex/octal conversion)
; ============================================================================

HDAE5000_HD_Init:	; (1902 bytes)
	; HD bring-up.  Each step's failure stores its code in RAM 0x229D92
	; (read back by HDAE5000_Check_HD_Present) and ends at HDAE5000_HD_Init_Fail:
	;   2  the 32 KB SRAM at 0x230F1C-0x238F1B does not hold 0x5A5A
	;   3  HDAE5000_ATA_SoftReset failed      5  HDAE5000_ATA_IdentifyDevice failed
	;   6  reading sector 1 (to 0x200628) failed
	;   1  sector 1 lacks the AA55AA55 F4F1F2F3 signature (not formatted);
	;      the free-cluster count 0x229C80 is zeroed
	;   7  HDAE5000_HD_CountFreeClusters failed
	;   8  HDAE5000_HD_ReadTables failed
	; Between those: HDAE5000_HD_ParseIdentify (via HDAE5000_ATA_IdentifyDevice's
	; data), six setting bytes copied from sector 1's image (0x2006A0) to
	; 0x229DA9..AE, blank tables (HDAE5000_HD_InitTables).  Always ends with
	; HDAE5000_ATA_Standby.  0 in 0x229D92 = drive ready and formatted.
	; RAM test: fill/verify 32KB at 0x230F1C-0x238F1C with 0x5A5A pattern
; LRT: 0x2971B7 (1902 bytes)
	; ^ region size, not routine size: the ATA primitives, geometry and
	;   table I/O routines below each carry their own label now.

	ldw	wa, 0x5a5a
	lda xiy, (HDAE5000_RAM_HdStreamBuffer:24)
HDAE5000_HD_Init_SramFillLoop:
	cp	xiy, HDAE5000_RAM_RcmStreamState
	jp	z, (.LHD_Init_SramFillLoop_Skip1:24)
	ld (xiy), wa
	inc 2, xiy
	jp HDAE5000_HD_Init_SramFillLoop
.LHD_Init_SramFillLoop_Skip1:
	lda xiy, (HDAE5000_RAM_HdStreamBuffer:24)
HDAE5000_HD_Init_SramVerifyLoop:
	cp	xiy, HDAE5000_RAM_RcmStreamState
	jp	z, (.LHD_Init_SramVerifyLoop_Skip2:24)
	cp	(xiy), wa
	jp	z, (.LHD_Init_SramVerifyLoop_Skip1:24)
	ld	a, 0x02:opc
	jp HDAE5000_HD_Init_Fail
.LHD_Init_SramVerifyLoop_Skip1:
	inc 2, xiy
	jp HDAE5000_HD_Init_SramVerifyLoop
.LHD_Init_SramVerifyLoop_Skip2:
	xor	wa, wa
	lda xiy, (HDAE5000_RAM_HdStreamBuffer:24)
HDAE5000_HD_Init_SramClearLoop:
	cp	xiy, HDAE5000_RAM_RcmStreamState
	jp	z, (.LHD_Init_SramClearLoop_Skip1:24)
	ld (xiy), wa
	inc 2, xiy
	jp HDAE5000_HD_Init_SramClearLoop
.LHD_Init_SramClearLoop_Skip1:
	call HDAE5000_HD_ClearStatusBytes
	call HDAE5000_PPORT_InitPort
	lda xwa, (HDAE5000_HD_CheckVersionKey:24)
	ld	(0x229d6c), xwa
	ld	(0x229D90:24), 0
	ld	(HDAE5000_RAM_HdInitResult:24), 0
	ld	(HDAE5000_RAM_WriteProtect:24), 1
	ld	(HDAE5000_RAM_WriteConfirm:24), 1
	ld	(HDAE5000_RAM_QuickLoadMode:24), 1
	ld	(HDAE5000_RAM_LoadByNumberMode:24), 1
	ld	(HDAE5000_RAM_JumpAfterLoad:24), 1
	ld	(HDAE5000_RAM_LyricJump:24), 1
	ld	(0x229dc6:24), 0
	ld	(0x229dd7:24), 1
	ld	xwa, 0x000017a8
	ld	(0x229d78), xwa
	lda xix, (0x2013b2:24)
	ld	xbc, 0x00000186
	ld	(0x229dc0:24), 0
	ld	(0x229dc1:24), 0x00
	ld	(0x229dc2:24), 0x00
	ld	(0x229DC3:24), 0
	ld	(0x229DC4:24), 0
	ld	(0x229DC5:24), 0
HDAE5000_HD_Init_SpaceFillLoop:
	cp	xbc, 0x00000000
	jp	z, (.LHD_Init_SpaceFillLoop_Skip1:24)
	ld	(xix), 0x20
	dec	1, xbc
	inc 1, xix
	jp HDAE5000_HD_Init_SpaceFillLoop
.LHD_Init_SpaceFillLoop_Skip1:
	ld	(HDAE5000_RAM_DirBrowserPage:24), 0
	ld	(HDAE5000_RAM_DirBrowserCursors:24), 0
	ld	(0x229dd9:24), 0
	ld	(0x229dda:24), 0x00
	ld	(0x229ddb:24), 0x00
	ld	(0x229DDC:24), 0
	ld	(0x229DDD:24), 0
	ld	(0x229dd4:24), 0
	ld	(HDAE5000_RAM_FlsBrowserPage:24), 0
	ld	(HDAE5000_RAM_FlsBrowserCursors:24), 0
	ld	(0x229e56:24), 0
	ld	(0x229e57:24), 0x00
	ld	(0x229e58:24), 0x00
	ld	(0x229E59:24), 0
	ld	(0x229E5A:24), 0
	xor	bc, bc
	lda xix, (HDAE5000_RAM_FlsBrowserRowBytes:24)
HDAE5000_HD_Init_ClearLoop1:
	cp	bc, 0x0078
	jp	z, (.LHD_Init_ClearLoop1_Skip1:24)
	ld	(xix), 0x00
	inc 1, xix
	inc	1, bc
	jp HDAE5000_HD_Init_ClearLoop1
.LHD_Init_ClearLoop1_Skip1:
	xor	bc, bc
	lda xix, (HDAE5000_RAM_DirBrowserRowBytes:24)
HDAE5000_HD_Init_ClearLoop2:
	cp	bc, 0x0078
	jp	z, (.LHD_Init_ClearLoop2_Skip1:24)
	ld	(xix), 0x00
	inc 1, xix
	inc	1, bc
	jp HDAE5000_HD_Init_ClearLoop2
.LHD_Init_ClearLoop2_Skip1:
	call HDAE5000_ATA_SoftReset
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Init_ClearLoop2_Skip2:24)
	ld	a, 0x03:opc
	jp HDAE5000_HD_Init_Fail
.LHD_Init_ClearLoop2_Skip2:
	call HDAE5000_ATA_IdentifyDevice
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Init_ClearLoop2_Skip3:24)
	ld	a, 0x05:opc
	jp HDAE5000_HD_Init_Fail
.LHD_Init_ClearLoop2_Skip3:
	call HDAE5000_HD_ParseIdentify
	ld	xhl, 1:i3
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	ld	xde, 0x00000200
	call HDAE5000_ATA_ReadSector
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Init_ClearLoop2_Skip4:24)
	ld	a, 0x06:opc
	jp HDAE5000_HD_Init_Fail
.LHD_Init_ClearLoop2_Skip4:
	call HDAE5000_HD_CheckSignature
	cp	(HDAE5000_RAM_HdSignatureOk:24), 1
	jp	z, (.LHD_Init_ClearLoop2_Skip5:24)
	ld	xwa, 0:i3
	ld	(HDAE5000_RAM_FreeClusters), xwa
	ld	a, 0x01:opc
	jp HDAE5000_HD_Init_Fail
.LHD_Init_ClearLoop2_Skip5:
	lda xix, (HDAE5000_RAM_HdSettingsSector+120:24)
	ld	a, (xix)
	ld	(HDAE5000_RAM_QuickLoadMode:24), a
	inc 1, xix
	ld	a, (xix)
	ld	(HDAE5000_RAM_LoadByNumberMode:24), a
	inc 1, xix
	ld	a, (xix)
	ld	(HDAE5000_RAM_JumpAfterLoad:24), a
	inc 1, xix
	ld	a, (xix)
	ld	(HDAE5000_RAM_LyricJump:24), a
	call HDAE5000_HD_CountFreeClusters
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Init_ClearLoop2_Skip6:24)
	ld	a, 0x07:opc
	jp HDAE5000_HD_Init_Fail
.LHD_Init_ClearLoop2_Skip6:
	call HDAE5000_HD_InitTables
	cp	(HDAE5000_RAM_HdSignatureOk:24), 1
	jp	nz, (.LHD_Init_ClearLoop2_Skip7:24)
	call HDAE5000_HD_ReadTables
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Init_ClearLoop2_Skip7:24)
	ld	a, 0x08:opc
	jp HDAE5000_HD_Init_Fail
.LHD_Init_ClearLoop2_Skip7:
	ld	(HDAE5000_RAM_HdInitResult:24), 0
HDAE5000_HD_Init_Exit:
	call HDAE5000_ATA_Standby
	ret

HDAE5000_HD_Init_Fail:
	ld	(HDAE5000_RAM_HdInitResult:24), a
	jp HDAE5000_HD_Init_Exit

; ---------------------------------------------------------------------------
; Poll HDAE5000_IO_AtaStatusCommand until (status & 0xC0) == 0x40 (BSY clear,
; DRDY set); after 0x3FFFFF polls give up with HDAE5000_RAM_AtaError = 1.
; Preserves XIX and WA.
; ---------------------------------------------------------------------------
HDAE5000_ATA_WaitReady:
	push xix
	pushw wa
	ld	xix, 0:i3
HDAE5000_ATA_WaitReady_Poll:
	cp	xix, 0x003fffff
	jp	z, (.LATA_WaitReady_Poll_Skip1:24)
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc0
	cp	a, 0x40
	jp	z, (.LATA_WaitReady_Poll_Skip2:24)
	inc 1, xix
	jp HDAE5000_ATA_WaitReady_Poll
.LATA_WaitReady_Poll_Skip1:
	ld	(HDAE5000_RAM_AtaError:24), 1
.LATA_WaitReady_Poll_Skip2:
	popw wa
	pop xix
	ret

; ---------------------------------------------------------------------------
; C-callable HDAE5000_ATA_SoftReset.
; Out: HL = 0, or 0xFFFF when HDAE5000_RAM_AtaError is set.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_ATA_SoftReset_Status:
	push xiz
	call HDAE5000_ATA_SoftReset
	xor	hl, hl
	cp	(HDAE5000_RAM_AtaError:24), 0
	jr	z, HDAE5000_ATA_SoftReset_Status_Epilogue
	ldw	hl, 0xffff
HDAE5000_ATA_SoftReset_Status_Epilogue:
	pop xiz
	ret

; ---------------------------------------------------------------------------
; ATA software reset: clear HDAE5000_RAM_AtaError, wait ready, write 0x0E
; (SRST + nIEN) and then 0x0A (nIEN) to HDAE5000_IO_AtaDeviceControl, wait
; ready again.  A timeout leaves AtaError = 1.
; ---------------------------------------------------------------------------
HDAE5000_ATA_SoftReset:
	ld	(HDAE5000_RAM_AtaError:24), 0
	call HDAE5000_ATA_WaitReady
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LATA_SoftReset_Skip1:24)
	jp HDAE5000_ATA_SoftReset_Return
.LATA_SoftReset_Skip1:
	ld	(HDAE5000_IO_AtaDeviceControl:24), 14
	ld	(HDAE5000_IO_AtaDeviceControl:24), 10
	call HDAE5000_ATA_WaitReady
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (HDAE5000_ATA_SoftReset_Return:24)
	ld	(HDAE5000_RAM_AtaError:24), 1
HDAE5000_ATA_SoftReset_Return:
	ret

; ---------------------------------------------------------------------------
; C-callable HDAE5000_ATA_Standby; several UI paths reach it with a
; conditional `call nz`.
; Out: HL = 0, or 0xFFFF when HDAE5000_RAM_AtaError is set.
; ---------------------------------------------------------------------------
HDAE5000_ATA_Standby_Status:
	call HDAE5000_ATA_Standby
	xor	hl, hl
	cp	(HDAE5000_RAM_AtaError:24), 0
	jr	z, HDAE5000_ATA_Standby_Status_Return
	ldw	hl, 0xffff
HDAE5000_ATA_Standby_Status_Return:
	ret

; ---------------------------------------------------------------------------
; Spin the drive down: wait ready, then features, sector number and cylinder
; registers 0xFF, sector count 0, drive/head 0xA0 and command 0x94 (STANDBY
; IMMEDIATE in the ATA-1/2 opcode map).  Skipped when the wait times out.
; All registers kept.
; ---------------------------------------------------------------------------
HDAE5000_ATA_Standby:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	call HDAE5000_ATA_WaitReady
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	nz, (.LATA_Standby_Skip1:24)
	ld	(HDAE5000_IO_AtaFeatures:24), 255
	ld	(HDAE5000_IO_AtaSectorCount:24), 0
	ld	(HDAE5000_IO_AtaSectorNumber:24), 255
	ld	(HDAE5000_IO_AtaCylinderLow:24), 255
	ld	(HDAE5000_IO_AtaCylinderHigh:24), 255
	ld	(HDAE5000_IO_AtaDriveHead:24), 160
	ld	(HDAE5000_IO_AtaStatusCommand:24), 148
.LATA_Standby_Skip1:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

; ---------------------------------------------------------------------------
; HDAE5000_RAM_HdSignatureOk = 1 when HDAE5000_RAM_HdSettingsSector starts
; with the longs 0xAA55AA55, 0xF4F1F2F3 (the signature HDAE5000_HD_SaveSettings
; writes to sector 1), else 0; then HDAE5000_HD_ResetVersionKeyWord.
; XIX, XBC, XWA preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_CheckSignature:
	push xix
	push xbc
	push xwa
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	ld xwa, (xix)
	ld xbc, (xix + 0x04)
	cp	xwa, 0xaa55aa55
	jp	z, (.LHD_CheckSignature_Skip1:24)
	ld	(HDAE5000_RAM_HdSignatureOk:24), 0
	jp HDAE5000_HD_CheckSignature_Done
.LHD_CheckSignature_Skip1:
	cp	xbc, 0xf4f1f2f3
	jp	z, (.LHD_CheckSignature_Skip2:24)
	ld	(HDAE5000_RAM_HdSignatureOk:24), 0
	jp HDAE5000_HD_CheckSignature_Done
.LHD_CheckSignature_Skip2:
	ld	(HDAE5000_RAM_HdSignatureOk:24), 1
HDAE5000_HD_CheckSignature_Done:
	call HDAE5000_HD_ResetVersionKeyWord
	pop xwa
	pop xbc
	pop xix
	ret

	push xwa
	push xbc
	push xix
	lda xix, (HDAE5000_Version_Key:24)
	ld xwa, (xix)
	ld	xbc, (HDAE5000_RAM_HdVersionKeyWord)
	cp	xwa, xbc
	jp	z, (.LHD_CheckSignature_Done_Skip1:24)
	pop xix
	pop xbc
	pop xwa
	pop xwa
	ret

.LHD_CheckSignature_Done_Skip1:
	pop xix
	pop xbc
	pop xwa
	ret

; ---------------------------------------------------------------------------
; HDAE5000_HD_ParseIdentify, then copy the drive geometry out: +0 cylinders,
; +2 heads, +4 sectors per track (words), +6 usable sectors (long), +10 the
; 40-byte model string.
; In:  XWA = destination
; RAM: HDAE5000_RAM_HdCylinders, _HdHeads, _HdSectorsPerTrack,
;      _HdUsableSectors, _HdModelString.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_GetGeometry:
	push xiz
	push xwa
	call HDAE5000_HD_ParseIdentify
	pop xwa
	ld	xix, xwa
	ld	wa, (HDAE5000_RAM_HdCylinders:24)
	ld (xix), wa
	ld	wa, (HDAE5000_RAM_HdHeads:24)
	ld (xix + 0x02), wa
	ld	wa, (HDAE5000_RAM_HdSectorsPerTrack:24)
	ld (xix + 0x04), wa
	ld	xwa, (HDAE5000_RAM_HdUsableSectors)
	ld (xix + 0x06), xwa
	add	xix, 0x0000000a
	ld	xiy, HDAE5000_RAM_HdModelString
	ldw	bc, 0x0014
	ldirw
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Read the IDENTIFY DEVICE block in HDAE5000_RAM_AtaIdentifyBuffer: words
; 54/55/56 (current cylinders, heads, sectors per track) and 57-58 (current
; capacity, minus 2), then derive the disk layout: clusters of 0x20 sectors,
; or 0x40 when the capacity is >= 0x14DC93 (SectorsPerCluster, ClusterBytes);
; HdSectorsPerHead = cylinders x sectors per track; the FAT at sector 2, the
; 323 table sectors at 3908, data from 4231; DataSectorCount and FatEntryCount
; (whole 128-entry FAT sectors).  Finally words 27-46 (the model number) go
; byte-swapped to HDAE5000_RAM_HdModelString.
; Clobbers XWA, XBC, XIX, XIY, BC.
; ---------------------------------------------------------------------------
HDAE5000_HD_ParseIdentify:
	lda xix, (HDAE5000_RAM_AtaIdentifyBuffer:24)
	ld	wa, (xix+108)
	ld	(HDAE5000_RAM_HdCylinders), wa
	ld	wa, (xix+110)
	ld	(HDAE5000_RAM_HdHeads), wa
	ld	wa, (xix+112)
	ld	(HDAE5000_RAM_HdSectorsPerTrack), wa
	ld xwa, (xix + 0x72)
	dec	2, xwa
	ld	(HDAE5000_RAM_HdUsableSectors), xwa
	ld	xbc, 0x0014dc93
	cp	xwa, xbc
	jp	ge, (.LHD_ParseIdentify_Skip1:24)
	ld	xwa, 0x00000020
	ld	(HDAE5000_RAM_SectorsPerCluster), xwa
	jp HDAE5000_HD_ParseIdentify_ClusterSet
.LHD_ParseIdentify_Skip1:
	ld	xwa, 0x00000040
	ld	(HDAE5000_RAM_SectorsPerCluster), xwa
HDAE5000_HD_ParseIdentify_ClusterSet:
	ld	xbc, 0x00000200
	call HDAE5000_HD_Mul32
	ld	(HDAE5000_RAM_ClusterBytes), xwa
	xor	xwa, xwa
	xor	xbc, xbc
	ld	wa, (HDAE5000_RAM_HdCylinders:24)
	ld	bc, (HDAE5000_RAM_HdSectorsPerTrack:24)
	call HDAE5000_HD_Mul32
	ld	(HDAE5000_RAM_HdSectorsPerHead), xwa
	ld	xwa, 2:i3
	ld	(HDAE5000_RAM_FatStartSector), xwa
	add	xwa, 0x00000f42
	ld	(HDAE5000_RAM_TablesStartSector), xwa
	add	xwa, 0x00000143
	ld	(HDAE5000_RAM_DataStartSector), xwa
	ld	xwa, (HDAE5000_RAM_HdUsableSectors)
	ld	xbc, (HDAE5000_RAM_DataStartSector)
	sub	xwa, xbc
	inc 1, xwa
	ld	(HDAE5000_RAM_DataSectorCount), xwa
	ld	xwa, (HDAE5000_RAM_SectorsPerCluster)
	ld	xbc, 0x00000080
	call HDAE5000_HD_Mul32
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_DataSectorCount)
	call HDAE5000_HD_UDiv32
	ld	xbc, 0x00000080
	call HDAE5000_HD_Mul32
	ld	(HDAE5000_RAM_FatEntryCount), xwa
	lda xiy, (HDAE5000_RAM_HdModelString:24)
	lda xix, (HDAE5000_RAM_AtaIdentifyBuffer+54:24)
	ld	bc, 0:i3
HDAE5000_HD_ParseIdentify_ModelLoop:
	cp	bc, 0x0028
	jp	z, (.LHD_ParseIdentify_ModelLoop_Return1:24)
	ld	wa, (xix)
	ld	(xiy), w
	ld	(xiy+1), a
	inc	2, bc
	inc 2, xix
	inc 2, xiy
	jp HDAE5000_HD_ParseIdentify_ModelLoop
.LHD_ParseIdentify_ModelLoop_Return1:
	ret

; ---------------------------------------------------------------------------
; Write one 512-byte sector.  The sector number is split with
; HDAE5000_HD_UDiv32 by HDAE5000_RAM_HdSectorsPerHead and by
; HdSectorsPerTrack into head (drive/head register, | 0xA0), cylinder (low,
; high) and sector; sector count 1, command 0x30 (WRITE SECTORS), wait for DRQ
; ((status & 0xC8) == 0x48), 256 words to HDAE5000_IO_AtaData, wait ready.
; HDAE5000_RAM_AtaError = status bit 0 (ERR).  The ready and DRQ waits have no
; timeout.
; In:  XHL = sector number (1-based), XIX = data
; Out: clobbers XWA, XBC, XIX, XIY, E.
; ---------------------------------------------------------------------------
HDAE5000_ATA_WriteSector:
	ld	(HDAE5000_RAM_AtaWriteSectorNo), xhl
	ld	(HDAE5000_RAM_AtaWriteData), xix
	ld	(HDAE5000_RAM_AtaError:24), 0
HDAE5000_ATA_WriteSector_WaitReady:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc0
	cp	a, 0x40
	jp	z, (.LATA_WriteSector_WaitReady_Skip1:24)
	jp HDAE5000_ATA_WriteSector_WaitReady
.LATA_WriteSector_WaitReady_Skip1:
	ld	(HDAE5000_IO_AtaSectorCount:24), 1
	ld	xwa, (HDAE5000_RAM_AtaWriteSectorNo)
	dec	1, xwa
	ld	xbc, (HDAE5000_RAM_HdSectorsPerHead)
	calr	HDAE5000_HD_UDiv32
	ld	e, a
	or	a, 0xa0
	ld	(HDAE5000_IO_AtaDriveHead:24), a
	xor	xwa, xwa
	ld	a, e
	ld	xbc, (HDAE5000_RAM_HdSectorsPerHead)
	calr	HDAE5000_HD_Mul32
	ld	(HDAE5000_RAM_AtaWriteHeadBase), xwa
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_AtaWriteSectorNo)
	sub	xwa, xbc
	dec	1, xwa
	xor	xbc, xbc
	ld	bc, (HDAE5000_RAM_HdSectorsPerTrack:24)
	calr	HDAE5000_HD_UDiv32
	ld	(HDAE5000_IO_AtaCylinderLow:24), a
	ld	(HDAE5000_IO_AtaCylinderHigh:24), w
	xor	xbc, xbc
	ld	bc, (HDAE5000_RAM_HdSectorsPerTrack:24)
	calr	HDAE5000_HD_Mul32
	ld	xbc, (HDAE5000_RAM_AtaWriteHeadBase)
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_AtaWriteSectorNo)
	sub	xwa, xbc
	ld	(HDAE5000_IO_AtaSectorNumber:24), a
	ld	(HDAE5000_IO_AtaStatusCommand:24), 48
HDAE5000_ATA_WriteSector_WaitDrq:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc8
	cp	a, 0x48
	jp	z, (.LATA_WriteSector_WaitDrq_Skip1:24)
	jp HDAE5000_ATA_WriteSector_WaitDrq
.LATA_WriteSector_WaitDrq_Skip1:
	ld	bc, 0:i3
	ld	xix, (HDAE5000_RAM_AtaWriteData)
HDAE5000_ATA_WriteSector_DataLoop:
	cp	bc, 0x0200
	jp	nc, (HDAE5000_ATA_WriteSector_WaitDone:24)
	ld	wa, (xix)
	ld	(HDAE5000_IO_AtaData), wa
	inc 2, xix
	inc 2, xiy
	inc	2, bc
	jp HDAE5000_ATA_WriteSector_DataLoop
HDAE5000_ATA_WriteSector_WaitDone:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc0
	cp	a, 0x40
	jp	z, (.LATA_WriteSector_WaitDone_Skip1:24)
	jp HDAE5000_ATA_WriteSector_WaitDone
.LATA_WriteSector_WaitDone_Skip1:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0x01
	ld	(HDAE5000_RAM_AtaError:24), a
	ret

; ---------------------------------------------------------------------------
; Read one sector: the CHS split and handshake of HDAE5000_ATA_WriteSector
; with command 0x20 (READ SECTORS); all 256 words are read from
; HDAE5000_IO_AtaData, the first XDE bytes are stored.
; HDAE5000_RAM_AtaError = status bit 0 (ERR).
; In:  XHL = sector number (1-based), XIX = buffer, XDE = bytes to keep
; Out: clobbers XWA, XBC, XDE, XIX, E.
; ---------------------------------------------------------------------------
HDAE5000_ATA_ReadSector:
	ld	(HDAE5000_RAM_AtaReadSectorNo), xhl
	ld	(HDAE5000_RAM_AtaReadData), xix
	ld	(HDAE5000_RAM_AtaReadKeepBytes), xde
	ld	(HDAE5000_RAM_AtaError:24), 0
HDAE5000_ATA_ReadSector_WaitReady:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc0
	cp	a, 0x40
	jp	z, (.LATA_ReadSector_WaitReady_Skip1:24)
	jp HDAE5000_ATA_ReadSector_WaitReady
.LATA_ReadSector_WaitReady_Skip1:
	ld	(HDAE5000_IO_AtaSectorCount:24), 1
	ld	xwa, (HDAE5000_RAM_AtaReadSectorNo)
	dec	1, xwa
	ld	xbc, (HDAE5000_RAM_HdSectorsPerHead)
	calr	HDAE5000_HD_UDiv32
	ld	e, a
	or	a, 0xa0
	ld	(HDAE5000_IO_AtaDriveHead:24), a
	xor	xwa, xwa
	ld	a, e
	ld	xbc, (HDAE5000_RAM_HdSectorsPerHead)
	calr	HDAE5000_HD_Mul32
	ld	(HDAE5000_RAM_AtaReadHeadBase), xwa
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_AtaReadSectorNo)
	sub	xwa, xbc
	dec	1, xwa
	xor	xbc, xbc
	ld	bc, (HDAE5000_RAM_HdSectorsPerTrack:24)
	calr	HDAE5000_HD_UDiv32
	ld	(HDAE5000_IO_AtaCylinderLow:24), a
	ld	(HDAE5000_IO_AtaCylinderHigh:24), w
	xor	xbc, xbc
	ld	bc, (HDAE5000_RAM_HdSectorsPerTrack:24)
	calr	HDAE5000_HD_Mul32
	ld	xbc, (HDAE5000_RAM_AtaReadHeadBase)
	add	xbc, xwa
	ld	xwa, (HDAE5000_RAM_AtaReadSectorNo)
	sub	xwa, xbc
	ld	(HDAE5000_IO_AtaSectorNumber:24), a
	ld	(HDAE5000_IO_AtaStatusCommand:24), 32
HDAE5000_ATA_ReadSector_WaitDrq:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc8
	cp	a, 0x48
	jp	z, (.LATA_ReadSector_WaitDrq_Skip1:24)
	jp HDAE5000_ATA_ReadSector_WaitDrq
.LATA_ReadSector_WaitDrq_Skip1:
	ld	bc, 0:i3
	ld	xix, (HDAE5000_RAM_AtaReadData)
	ld	xde, (HDAE5000_RAM_AtaReadKeepBytes)
HDAE5000_ATA_ReadSector_DataLoop:
	cp	bc, 0x0200
	jp	nc, (HDAE5000_ATA_ReadSector_WaitDone:24)
	ld	wa, (HDAE5000_IO_AtaData:24)
	cp	bc, de
	jp	nc, (.LATA_ReadSector_DataLoop_Skip1:24)
	ld (xix), wa
.LATA_ReadSector_DataLoop_Skip1:
	inc 2, xix
	inc	2, bc
	jp HDAE5000_ATA_ReadSector_DataLoop
HDAE5000_ATA_ReadSector_WaitDone:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc0
	cp	a, 0x40
	jp	z, (.LATA_ReadSector_WaitDone_Skip1:24)
	jp HDAE5000_ATA_ReadSector_WaitDone
.LATA_ReadSector_WaitDone_Skip1:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0x01
	ld	(HDAE5000_RAM_AtaError:24), a
	ret

; ---------------------------------------------------------------------------
; Command 0xEC (IDENTIFY DEVICE) with 0xFF in the task-file registers and
; drive/head 0xA0; the 512-byte answer goes to HDAE5000_RAM_AtaIdentifyBuffer
; (parsed by HDAE5000_HD_ParseIdentify).  HDAE5000_RAM_AtaError = status
; bit 0.  All registers kept.
; ---------------------------------------------------------------------------
HDAE5000_ATA_IdentifyDevice:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
HDAE5000_ATA_Identify_WaitReady:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc0
	cp	a, 0x40
	jp	z, (.LATA_Identify_WaitReady_Skip1:24)
	jp HDAE5000_ATA_Identify_WaitReady
.LATA_Identify_WaitReady_Skip1:
	ld	(HDAE5000_IO_AtaFeatures:24), 255
	ld	(HDAE5000_IO_AtaSectorCount:24), 255
	ld	(HDAE5000_IO_AtaSectorNumber:24), 255
	ld	(HDAE5000_IO_AtaCylinderLow:24), 255
	ld	(HDAE5000_IO_AtaCylinderHigh:24), 255
	ld	(HDAE5000_IO_AtaDriveHead:24), 160
	ld	(HDAE5000_IO_AtaStatusCommand:24), 236
HDAE5000_ATA_Identify_WaitDrq:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc8
	cp	a, 0x48
	jp	z, (.LATA_Identify_WaitDrq_Skip1:24)
	jp HDAE5000_ATA_Identify_WaitDrq
.LATA_Identify_WaitDrq_Skip1:
	ld	bc, 0:i3
	ld	xix, HDAE5000_RAM_AtaIdentifyBuffer
HDAE5000_ATA_Identify_DataLoop:
	cp	bc, 0x0200
	jp	nc, (HDAE5000_ATA_Identify_WaitDone:24)
	ld	wa, (HDAE5000_IO_AtaData:24)
	ld (xix), wa
	inc 2, xix
	inc	2, bc
	jp HDAE5000_ATA_Identify_DataLoop
HDAE5000_ATA_Identify_WaitDone:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0xc0
	cp	a, 0x40
	jp	z, (.LATA_Identify_WaitDone_Skip1:24)
	jp HDAE5000_ATA_Identify_WaitDone
.LATA_Identify_WaitDone_Skip1:
	ld	a, (HDAE5000_IO_AtaStatusCommand:24)
	and	a, 0x01
	ld	(HDAE5000_RAM_AtaError:24), a
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret


; ---------------------------------------------------------------------------
; 32 x 32 -> 32-bit multiply, the HD driver's copy of HDAE5000_Multiply with
; the result in XWA: BC*WA + (BC*QWA) << 16 + (QBC*WA) << 16, nothing above
; bit 31 kept.
; In:  XWA, XBC
; Out: XWA = XWA * XBC (low 32 bits).  XHL and XIX preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_Mul32:
	push xhl
	push xix
	ld hl, bc			; HL = low(BC)
	mul xhl, wa			; XHL = low(BC) * WA
	ld xix, xhl			; accumulate in XIX
	ld hl, bc			; HL = low(BC) again
	mul	xhl, qwa
	ld	qhl, hl
	ld hl, 0:i3			; clear low HL
	add xix, xhl			; add shifted partial product
	ld	hl, qbc
	mul xhl, wa			; XHL = high(BC) * WA
	ld	qhl, hl
	ld hl, 0:i3			; clear low HL
	add xix, xhl			; add shifted partial product
	ld xwa, xix			; result in XWA
	pop xix
	pop xhl
	ret

; ---------------------------------------------------------------------------
; 32-bit unsigned division, one quotient bit per iteration (32 shifts).
; In:  XWA = dividend, XBC = divisor
; Out: XWA = quotient, XBC = remainder.  XIX, XIY, XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_UDiv32:
	push xix
	push xiy
	push xiz
	xor xix, xix			; remainder = 0
	xor xiy, xiy			; quotient = 0
	ldw iz, 32			; 32-bit counter
.Lhciv_div_loop:
	cp iz, 0:i3
	jr z, .Lhciv_div_done
	dec 1, iz
	sll xix, 1			; shift remainder left
	sll xiy, 1			; shift quotient left
	sll xwa, 1			; shift dividend (MSB → carry)
	jr nc, .Lhciv_div_no_carry
	inc 1, xix			; shift carry into remainder
.Lhciv_div_no_carry:
	cp xix, xbc			; remainder >= divisor?
	jr nc, .Lhciv_div_sub
	jp .Lhciv_div_loop
.Lhciv_div_sub:
	sub xix, xbc			; remainder -= divisor
	inc 1, xiy			; quotient++
	jp .Lhciv_div_loop
.Lhciv_div_done:
	ld xwa, xiy			; quotient → XWA
	ld xbc, xix			; remainder → XBC
	pop xiz
	pop xiy
	pop xix
	ret

	; --- Memory region initialization ---
	; Fill HD file allocation tables with spaces, zeros, 0xFFFFFFFF markers
	; (blank images of the filesystem tables before HDAE5000_HD_ReadTables
	; or a format; called from HDAE5000_HD_Init and one other site)
HDAE5000_HD_InitTables:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	; Region 1: fill 0x201632-0x201DB2 with 0x20 (space)
	ld xix, HDAE5000_RAM_DirNames
	ld xiy, HDAE5000_RAM_SongRecords
.Lhciv_fill1:
	cp xix, xiy
	jp z, (.Lhciv_section2:24)		; jp Z, .Lhciv_section2
	ld (xix), 32		; store 0x20 (space)
	inc 1, xix
	jp .Lhciv_fill1
	; Region 2: structured fill 0x201DB2-0x2257B2 (76-byte records)
.Lhciv_section2:
	ld xix, HDAE5000_RAM_SongRecords
	ld xiy, HDAE5000_RAM_FlsRecords
.Lhciv_outer2:
	cp xix, xiy
	jp z, (.Lhciv_section3:24)		; jp Z, .Lhciv_section3
	; Inner: 26 bytes of 0x20 (space)
	xor xbc, xbc
.Lhciv_space26:
	cp xbc, 26
	jp z, (.Lhciv_zeros:24)		; jp Z, .Lhciv_zeros
	push xix
	add xix, xbc
	ld (xix), 32
	pop xix
	inc 1, xbc
	jp .Lhciv_space26
	; Inner: 10 bytes of 0x00 at offset 26
.Lhciv_zeros:
	ld bc, 0:i3
.Lhciv_zeros_loop:
	cp bc, 10
	jp z, (HDAE5000_HD_InitTables_Skip:24)		; jp Z, HDAE5000_HD_InitTables_Skip
	pushw bc
	ldw wa, 26
	add bc, wa			; offset = counter + 26
	ld	(xix+bc), 0x00
	popw bc
	inc 1, bc
	jp .Lhciv_zeros_loop
	; Inner: 10 × 32-bit 0xFFFFFFFF at offset 36
HDAE5000_HD_InitTables_Skip:
	xor xbc, xbc
.Lhciv_ff_loop:
	cp xbc, 10
	jp z, (.Lhciv_next_record:24)		; jp Z, .Lhciv_next_record
	push xbc
	ld xwa, 4:i3			; entry size = 4 bytes
	call HDAE5000_HD_Mul32	; XWA = XBC * 4 (multiply)
	add xwa, 36			; offset = 4*i + 36
	ld xbc, xwa
	push xix
	add xix, xbc
	ld xwa, 4294967295		; 0xFFFFFFFF marker
	ld (xix), xwa
	inc 1, xiz
	pop xix
	pop xbc
	inc 1, xbc
	jp .Lhciv_ff_loop
	; Advance to next 76-byte record
.Lhciv_next_record:
	add xix, 76
	jp .Lhciv_outer2
	; Region 3: fill 0x2257B2-0x229B32 with 0x00
.Lhciv_section3:
	ld xix, HDAE5000_RAM_FlsRecords
	ld xiy, 2267954		; 0x229B32
.Lhciv_fill_zero:
	cp xix, xiy
	jp z, (.Lhciv_section4:24)		; jp Z, .Lhciv_section4
	ld (xix), 0
	inc 1, xix
	jp .Lhciv_fill_zero
	; Region 4: fill 0x2257B2 in blocks of 144-byte rows, 120 rows,
	; 16 bytes of 0x20 per row
.Lhciv_section4:
	ld xix, HDAE5000_RAM_FlsRecords
	ld hl, 0:i3			; row counter
.Lhciv_row_loop:
	cp hl, 120			; 0x78 rows total
	jp z, (.Lhciv_mem_exit:24)		; jp Z, .Lhciv_mem_exit
	ld bc, 0:i3			; column counter
.Lhciv_col_loop:
	cp bc, 16			; 16 bytes per row
	jp z, (.Lhciv_next_row:24)		; jp Z, .Lhciv_next_row
	ld	(xix+bc), 0x20
	inc 1, bc
	jp .Lhciv_col_loop
.Lhciv_next_row:
	add xix, 144			; 0x90 bytes per row stride
	inc 1, hl
	jp .Lhciv_row_loop
.Lhciv_mem_exit:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

	; --- HD presence check wrapper ---
	; Calls HD config init, returns HL = 0 (success) or 0xFFFF (error)
	; (C-callable wrapper of HDAE5000_HD_WriteTables, not a presence check.)
HDAE5000_HD_WriteTables_Status:
	call HDAE5000_HD_WriteTables
	xor hl, hl
	cp (HDAE5000_RAM_AtaError:24), 0x00
	jp z, (.LHD_WriteTables_Status_Return1:24)		; jp Z, ret (no error)
	ldw hl, 65535			; HL = 0xFFFF (error)
.LHD_WriteTables_Status_Return1:
	ret

	; --- HD config initialization (start — continues in next block) ---
	; Write all 323 sectors from RAM to HD, with retry
	; The 323 sectors are the filesystem tables held in RAM 0x201632-
	; 0x229B31 (HDAE5000_HD_InitTables' regions), written to sector
	; (0x229C64) = 3908 on; then every sector is read back into 0x200228 and
	; compared 4 bytes at a time.  7 retries; failure -> 0x200222 = 1.
HDAE5000_HD_WriteTables:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	ld (HDAE5000_RAM_HdRetries:24), 0x07	; retry counter
.Lhciv_config_restart:
	ld xwa, (HDAE5000_RAM_TablesStartSector:24)	; HD base sector
	ld (HDAE5000_RAM_HdTablesSector:24), xwa
	ld xwa, HDAE5000_RAM_DirNames	; RAM buffer base
	ld (HDAE5000_RAM_HdTablesPtr:24), xwa
	xor xwa, xwa
	ld (HDAE5000_RAM_HdTablesCount:24), xwa
.Lhciv_write_loop:
	ld xwa, 323			; 0x143 — total sectors
	cp (HDAE5000_RAM_HdTablesCount:24), xwa	; counter == 323?
	jp z, (.Lhdd_verify1:24)		; verify phase
	ld xhl, (HDAE5000_RAM_HdTablesSector:24)	; current sector
	ld xix, (HDAE5000_RAM_HdTablesPtr:24)	; current buffer ptr
	call HDAE5000_ATA_WriteSector			; write sector to HD
	; Function continues in next block (HD_Detect_Drive)

HDAE5000_HD_WriteTables_Next:	; (836 bytes)
	; (no caller: this label sits inside HDAE5000_HD_WriteTables, right after
	; its HDAE5000_ATA_WriteSector call; it was HD_Detect_Drive, a region
	; name.  The region also holds HDAE5000_HD_ReadTables and
	; HDAE5000_HD_CountFreeClusters below.)
	; HD config write+verify (continuation), read+verify, sector counting

	; --- Write phase continuation (from HDAE5000_HD_WriteTables in prev block) ---
	; After calling write sector, check error and increment counters
	cp (HDAE5000_RAM_AtaError:24), 0x00
	jp nz, (.Lhdd_error1:24)		; jp NZ, .Lhdd_error1
	ld xwa, (HDAE5000_RAM_HdTablesSector:24)
	inc 1, xwa
	ld (HDAE5000_RAM_HdTablesSector:24), xwa
	ld xwa, (HDAE5000_RAM_HdTablesCount:24)
	inc 1, xwa
	ld (HDAE5000_RAM_HdTablesCount:24), xwa
	ld xwa, (HDAE5000_RAM_HdTablesPtr:24)
	add xwa, 512
	ld (HDAE5000_RAM_HdTablesPtr:24), xwa
	jp .Lhciv_write_loop		; loop back to write phase

	; --- Verify phase: read back each sector, compare with RAM ---
.Lhdd_verify1:
	ld xwa, (HDAE5000_RAM_TablesStartSector:24)	; base sector
	ld (HDAE5000_RAM_HdTablesSector:24), xwa
	ld xwa, HDAE5000_RAM_DirNames
	ld (HDAE5000_RAM_HdTablesPtr:24), xwa
	xor xwa, xwa
	ld (HDAE5000_RAM_HdTablesCount:24), xwa; counter = 0
.Lhdd_verify_loop1:
	ld xwa, 323
	cp (HDAE5000_RAM_HdTablesCount:24), xwa; counter == 323?
	jp z, (.Lhdd_success1:24)		; jp Z, .Lhdd_success1
	ld xhl, (HDAE5000_RAM_HdTablesSector:24); XHL = current sector
	ld xde, 512			; 512 bytes
	ld xix, HDAE5000_RAM_HdSectorBuffer
	call HDAE5000_ATA_ReadSector			; read sector to buffer
	cp (HDAE5000_RAM_AtaError:24), 0x00; error check
	jp nz, (.Lhdd_error1:24)		; jp NZ, .Lhdd_error1
	ld xix, (HDAE5000_RAM_HdTablesPtr:24); XIX = RAM buffer ptr
	ld xiy, HDAE5000_RAM_HdSectorBuffer			; XIY = read buffer
	ld bc, 0:i3
.Lhdd_compare_loop1:
	cp bc, 512			; compared all 512 bytes?
	jp z, (.Lhdd_verify_next1:24)		; jp Z, .Lhdd_verify_next1
	ld	xwa, (xix+bc)	; XWA = (XIX+BC)
	cp	xwa, (xiy+bc)
	jp nz, (.Lhdd_error1:24)		; jp NZ, .Lhdd_error1
	inc 4, bc			; 4 bytes at a time
	jp .Lhdd_compare_loop1
.Lhdd_verify_next1:
	ld xwa, (HDAE5000_RAM_HdTablesSector:24); sector++
	inc 1, xwa
	ld (HDAE5000_RAM_HdTablesSector:24), xwa
	ld xwa, (HDAE5000_RAM_HdTablesCount:24); counter++
	inc 1, xwa
	ld (HDAE5000_RAM_HdTablesCount:24), xwa
	ld xwa, (HDAE5000_RAM_HdTablesPtr:24); buffer += 512
	add xwa, 512
	ld (HDAE5000_RAM_HdTablesPtr:24), xwa
	jp .Lhdd_verify_loop1

	; --- Success exit 1 ---
.Lhdd_success1:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

	; --- Error handler 1: retry or set error flag ---
.Lhdd_error1:
	cp (HDAE5000_RAM_HdRetries:24), 0x00
	jp z, (.Lhdd_final_error1:24)		; jp Z, .Lhdd_final_error1
	dec 1, (HDAE5000_RAM_HdRetries:24); retry--
	jp .Lhciv_config_restart	; restart from scratch
.Lhdd_final_error1:
	ld (HDAE5000_RAM_AtaError:24), 0x01
	xor xwa, xwa
	ld (HDAE5000_RAM_FreeClusters:24), xwa	; clear
	jp .Lhdd_success1		; clean up and return

	; === HD Config Read+Verify Wrapper ===
	; Calls config init 2, returns HL = 0 (ok) or 0xFFFF (error)
HDAE5000_HD_ReadTables_Status:
	call HDAE5000_HD_ReadTables
	xor hl, hl
	cp (HDAE5000_RAM_AtaError:24), 0x00; error?
	jp z, (.Lhdd_wrapper2_ret:24)		; jp Z, .Lhdd_wrapper2_ret
	ldw hl, 65535
.Lhdd_wrapper2_ret:
	ret

	; === HD Config Init 2: Read all sectors, then verify by re-reading ===
	; (the 323 filesystem-table sectors at (0x229C64) into RAM 0x201632)
HDAE5000_HD_ReadTables:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	ld (HDAE5000_RAM_HdRetries:24), 0x07; retry = 7
.Lhdd_restart2:
	ld xwa, (HDAE5000_RAM_TablesStartSector:24); base sector
	ld (HDAE5000_RAM_HdTablesSector:24), xwa
	ld xwa, HDAE5000_RAM_DirNames
	ld (HDAE5000_RAM_HdTablesPtr:24), xwa	; buffer
	xor xwa, xwa
	ld (HDAE5000_RAM_HdTablesCount:24), xwa; counter = 0
	; Read phase: read each of 323 sectors into RAM
.Lhdd_read_loop2:
	ld xwa, 323
	cp (HDAE5000_RAM_HdTablesCount:24), xwa; counter == 323?
	jp z, (.Lhdd_verify_start2:24)		; jp Z, .Lhdd_verify_start2
	ld xde, 512
	ld xhl, (HDAE5000_RAM_HdTablesSector:24); current sector
	ld xix, (HDAE5000_RAM_HdTablesPtr:24); current buffer ptr
	call HDAE5000_ATA_ReadSector			; read sector
	cp (HDAE5000_RAM_AtaError:24), 0x00
	jp nz, (.Lhdd_error2:24)		; jp NZ, .Lhdd_error2
	ld xwa, (HDAE5000_RAM_HdTablesCount:24); counter++
	inc 1, xwa
	ld (HDAE5000_RAM_HdTablesCount:24), xwa
	ld xwa, (HDAE5000_RAM_HdTablesSector:24); sector++
	inc 1, xwa
	ld (HDAE5000_RAM_HdTablesSector:24), xwa
	ld xwa, (HDAE5000_RAM_HdTablesPtr:24); buffer += 512
	add xwa, 512
	ld (HDAE5000_RAM_HdTablesPtr:24), xwa
	jp .Lhdd_read_loop2
	; Verify phase: re-read each sector, compare with RAM copy
.Lhdd_verify_start2:
	ld xwa, (HDAE5000_RAM_TablesStartSector:24)
	ld (HDAE5000_RAM_HdTablesSector:24), xwa
	ld xwa, HDAE5000_RAM_DirNames
	ld (HDAE5000_RAM_HdTablesPtr:24), xwa
	xor xwa, xwa
	ld (HDAE5000_RAM_HdTablesCount:24), xwa
.Lhdd_verify_loop2:
	ld xwa, 323
	cp (HDAE5000_RAM_HdTablesCount:24), xwa
	jp z, (.Lhdd_success2:24)		; jp Z, .Lhdd_success2
	ld xhl, (HDAE5000_RAM_HdTablesSector:24)
	ld xde, 512
	ld xix, HDAE5000_RAM_HdSectorBuffer
	call HDAE5000_ATA_ReadSector
	cp (HDAE5000_RAM_AtaError:24), 0x00
	jp nz, (.Lhdd_error2:24)		; jp NZ, .Lhdd_error2
	ld xix, (HDAE5000_RAM_HdTablesPtr:24); RAM buffer
	ld xiy, HDAE5000_RAM_HdSectorBuffer			; read buffer
	ld bc, 0:i3
.Lhdd_compare_loop2:
	cp bc, 512
	jp z, (.Lhdd_verify_next2:24)		; jp Z, .Lhdd_verify_next2
	ld	xwa, (xix+bc)	; XWA = (XIX+BC)
	cp	xwa, (xiy+bc)
	jp nz, (.Lhdd_error2:24)		; jp NZ, .Lhdd_error2
	inc 4, bc
	jp .Lhdd_compare_loop2
.Lhdd_verify_next2:
	ld xwa, (HDAE5000_RAM_HdTablesSector:24)
	inc 1, xwa
	ld (HDAE5000_RAM_HdTablesSector:24), xwa
	ld xwa, (HDAE5000_RAM_HdTablesCount:24)
	inc 1, xwa
	ld (HDAE5000_RAM_HdTablesCount:24), xwa
	ld xwa, (HDAE5000_RAM_HdTablesPtr:24)
	add xwa, 512
	ld (HDAE5000_RAM_HdTablesPtr:24), xwa
	jp .Lhdd_verify_loop2

.Lhdd_success2:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

.Lhdd_error2:
	cp (HDAE5000_RAM_HdRetries:24), 0x00
	jp z, (.Lhdd_final_error2:24)		; jp Z, .Lhdd_final_error2
	dec 1, (HDAE5000_RAM_HdRetries:24)
	jp .Lhdd_restart2
.Lhdd_final_error2:
	ld (HDAE5000_RAM_AtaError:24), 0x01
	xor xwa, xwa
	ld (HDAE5000_RAM_FreeClusters:24), xwa
	jp .Lhdd_success2

	; === HD Count Used Sectors Wrapper ===
	; Returns XHL = the FREE-cluster count (0x229C80), or 0 on error.
HDAE5000_HD_CountFreeClusters_Status:
	call HDAE5000_HD_CountFreeClusters
	ld xhl, (HDAE5000_RAM_FreeClusters:24)
	cp (HDAE5000_RAM_AtaError:24), 0x00
	jr z, .Lhdd_wrapper3_ret
	xor xhl, xhl			; error → return 0
.Lhdd_wrapper3_ret:
	ret

	; === Count Used Sectors ===
	; Reads the FAT from sector (0x229C68) = 2 and counts its ZERO 32-bit
	; entries, (0x229C70) entries in all, into 0x229C80.  Zero = free: the
	; allocator at 0x297E16 writes chains ending 0xFFFFFFFE and then
	; subtracts the clusters it took from this same count.  5 retries.
HDAE5000_HD_CountFreeClusters:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	ld (HDAE5000_RAM_HdRetries:24), 0x05; retry = 5
.Lhdd_restart3:
	xor xwa, xwa
	ld (HDAE5000_RAM_FreeClusters:24), xwa; free count = 0
	ld xwa, (HDAE5000_RAM_FatStartSector:24)	; base sector from
	ld (HDAE5000_RAM_HdCountSector:24), xwa	; → current sector
	xor xwa, xwa
	ld (HDAE5000_RAM_HdCountEntries:24), xwa
.Lhdd_outer3:
	ld xwa, (HDAE5000_RAM_FatEntryCount:24)	; total sectors
	cp (HDAE5000_RAM_HdCountEntries:24), xwa; counter >= total?
	jp nc, (.Lhdd_success3:24)		; jp NC, .Lhdd_success3
	ld xde, 512
	ld xhl, (HDAE5000_RAM_HdCountSector:24); current sector
	lda xix, (HDAE5000_RAM_HdSectorBuffer:24)
	call HDAE5000_ATA_ReadSector			; read sector
	cp (HDAE5000_RAM_AtaError:24), 0x00
	jp nz, (.Lhdd_error3:24)		; jp NZ, .Lhdd_error3
	lda xix, (HDAE5000_RAM_HdSectorBuffer:24)
	ld bc, 0:i3
.Lhdd_inner3:
	cp bc, 512			; scanned all bytes?
	jp z, (.Lhdd_next_sector3:24)		; jp Z, .Lhdd_next_sector3
	ld xwa, (HDAE5000_RAM_HdCountEntries:24); increment scan counter
	inc 1, xwa
	ld (HDAE5000_RAM_HdCountEntries:24), xwa
	ld	xwa, (xix+bc)	; XWA = (XIX+BC)
	inc 4, bc
	cp xwa, 0			; is this 32-bit word zero?
	jp nz, (.Lhdd_inner3:24)		; jp NZ, .Lhdd_inner3 (non-zero, keep scanning)
	ld xwa, (HDAE5000_RAM_FreeClusters:24); free count++ (this entry is 0)
	inc 1, xwa
	ld (HDAE5000_RAM_FreeClusters:24), xwa
	jp .Lhdd_inner3			; continue scanning
.Lhdd_next_sector3:
	ld xwa, (HDAE5000_RAM_HdCountSector:24); sector++
	inc 1, xwa
	ld (HDAE5000_RAM_HdCountSector:24), xwa
	jp .Lhdd_outer3

.Lhdd_success3:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

.Lhdd_error3:
	cp (HDAE5000_RAM_HdRetries:24), 0x00
	jp z, (.Lhdd_final_error3:24)		; jp Z, .Lhdd_final_error3
	dec 1, (HDAE5000_RAM_HdRetries:24)
	jp .Lhdd_restart3
.Lhdd_final_error3:
	ld (HDAE5000_RAM_AtaError:24), 0x01
	xor xwa, xwa
	ld (HDAE5000_RAM_FreeClusters:24), xwa
	jp .Lhdd_success3

; ---------------------------------------------------------------------------
; Write a buffer to the disk as a NEW cluster chain.  Does nothing (HL =
; 0xFFFF) while HDAE5000_RAM_AtaError is set.  An old chain (*slot !=
; 0xFFFFFFFF) is released first (HDAE5000_HD_FreeChain_Worker).  Then
; ceil(bytes / ClusterBytes) clusters are taken one by one with
; HDAE5000_HD_FindFreeCluster (the scan restarts at FAT sector 0), written
; with HDAE5000_HD_WriteCluster and linked from the previous one with
; HDAE5000_HD_FatSetEntry; the last gets 0xFFFFFFFE (end of chain).  The
; first cluster goes to *slot, the count comes off HDAE5000_RAM_FreeClusters
; (clamped at 0), and HdFatSetCluster is left on the last cluster for
; HDAE5000_HD_AppendFile.  Disk full sets HDAE5000_RAM_HdDiskFull and stops.
; A failed cluster write stores 0xFFFFFFFF in the FAT entry of
; HdFatSetCluster and takes the next free cluster.
; In:  XWA = source, XBC = byte count, XDE = pointer to the file's
;      first-cluster slot (one of the ten longs at +36.. of a 76-byte song
;      record in HDAE5000_RAM_SongRecords, or the slot HDAE5000_HD_WriteOpen
;      was given)
; Out: HL = 0, or 0xFFFF when HDAE5000_RAM_AtaError is set.  XIZ preserved;
;      the worker below preserves every other register.
; RAM: HDAE5000_RAM_HdXfer*, _HdFatSet*, _HdFreeScan*, _HdFatCacheSector,
;      _HdDiskFull, _FreeClusters, _AtaError
; ---------------------------------------------------------------------------
HDAE5000_HD_WriteFile:
	push xiz
	ldw hl, 65535
	cp (HDAE5000_RAM_AtaError:24), 0x00
	jp nz, (.Ldc_exit:24)
	ld (HDAE5000_RAM_HdXferPtr:24), xwa
	ld (HDAE5000_RAM_HdXferBytes:24), xbc
	ld (HDAE5000_RAM_HdXferSlotPtr:24), xde
	call .Ldc_main
	xor hl, hl
	cp (HDAE5000_RAM_AtaError:24), 0x00
	jp z, (.Ldc_exit:24)
	ldw hl, 65535
.Ldc_exit:
	pop xiz
	ret

	; --- the register-preserving worker ---
.Ldc_main:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	; clusters needed = ceil(bytes / ClusterBytes)
	xor xwa, xwa
	xor xbc, xbc
	ld xwa, (HDAE5000_RAM_HdXferBytes:24)
	ld xbc, (HDAE5000_RAM_ClusterBytes:24)
	call HDAE5000_HD_UDiv32
	cp xbc, 0
	jp z, (.Ldc_no_roundup:24)
	inc 1, xwa
.Ldc_no_roundup:
	ld (HDAE5000_RAM_HdXferClusters:24), xwa
	ld (HDAE5000_RAM_HdDiskFull:24), 0x00
	; release the file's old chain, if any
	ld xix, (HDAE5000_RAM_HdXferSlotPtr:24)
	ld xwa, (xix)
	cp xwa, 4294967295
	jp z, (.Ldc_skip_first:24)
	ld (HDAE5000_RAM_HdFreeChainStart:24), xwa
	call HDAE5000_HD_FreeChain_Worker
.Ldc_skip_first:
	; restart the free-cluster scan: offset 512 makes HD_FindFreeCluster load FAT sector 0 first
	ld xwa, (HDAE5000_RAM_FatStartSector:24)
	ld (HDAE5000_RAM_HdFreeScanDiskSector:24), xwa
	xor xwa, xwa
	ld (HDAE5000_RAM_HdFreeScanFatSector:24), xwa
	ld xwa, 512
	ld (HDAE5000_RAM_HdFreeScanOffset:24), xwa
	ld xwa, 4294967295
	ld (HDAE5000_RAM_HdFatCacheSector:24), xwa
	xor xwa, xwa
	ld (HDAE5000_RAM_HdXferClustersDone:24), xwa
	ld (HDAE5000_RAM_HdXferLinkFromPrev:24), 0x00
	ld (HDAE5000_RAM_HdXferSlotSet:24), 0x00
	ld (HDAE5000_RAM_HdFreeScanStarted:24), 0x00
	; one cluster per pass
.Ldc_loop:
	call HDAE5000_HD_FindFreeCluster
	ld xwa, (HDAE5000_RAM_HdFreeCluster:24)
	cp xwa, 4294967293
	jp nz, (.Ldc_not_full:24)
	ld (HDAE5000_RAM_HdDiskFull:24), 0x01
	jp .Ldc_cleanup
.Ldc_not_full:
	ld xwa, (HDAE5000_RAM_HdFreeCluster:24)
	cp (HDAE5000_RAM_HdXferLinkFromPrev:24), 0x00
	jp nz, (.Ldc_not_first:24)
	ld (HDAE5000_RAM_HdFatSetCluster:24), xwa
	ld (HDAE5000_RAM_HdFatSetValue:24), xwa
	jp .Ldc_after_first
.Ldc_not_first:
	ld (HDAE5000_RAM_HdFatSetValue:24), xwa
.Ldc_after_first:
	call HDAE5000_HD_WriteCluster
	cp (HDAE5000_RAM_HdWriteClusterError:24), 0x00
	jp z, (.Ldc_alloc_ok:24)
	; the cluster write failed: mark the entry 0xFFFFFFFF and take the next free cluster
	ld xwa, 4294967295
	ld (HDAE5000_RAM_HdFatSetValue:24), xwa
	call HDAE5000_HD_FatSetEntry
	jp .Ldc_loop
.Ldc_alloc_ok:
	cp (HDAE5000_RAM_HdXferSlotSet:24), 0x00
	jp nz, (.Ldc_after_alloc:24)
	ld (HDAE5000_RAM_HdXferSlotSet:24), 0x01
	ld xwa, (HDAE5000_RAM_HdFreeCluster:24)
	ld xix, (HDAE5000_RAM_HdXferSlotPtr:24)
	ld (xix), xwa
.Ldc_after_alloc:
	ld xwa, (HDAE5000_RAM_HdXferClustersDone:24)
	inc 1, xwa
	ld (HDAE5000_RAM_HdXferClustersDone:24), xwa
	cp xwa, (HDAE5000_RAM_HdXferClusters:24)
	jp z, (.Ldc_all_done:24)
	cp (HDAE5000_RAM_HdXferLinkFromPrev:24), 0x00
	jp nz, (.Ldc_mid_sector:24)
	ld (HDAE5000_RAM_HdXferLinkFromPrev:24), 0x01
	jp .Ldc_loop
.Ldc_mid_sector:
	call HDAE5000_HD_FatSetEntry
	ld xwa, (HDAE5000_RAM_HdFatSetValue:24)
	ld (HDAE5000_RAM_HdFatSetCluster:24), xwa
	jp .Ldc_loop
.Ldc_all_done:
	call HDAE5000_HD_FatSetEntry
	ld xwa, (HDAE5000_RAM_HdFatSetValue:24)
	ld (HDAE5000_RAM_HdFatSetCluster:24), xwa
	ld xwa, 4294967294
	ld (HDAE5000_RAM_HdFatSetValue:24), xwa
	call HDAE5000_HD_FatSetEntry
	; the clusters taken come off the free count (clamped at 0)
	ld xwa, (HDAE5000_RAM_FreeClusters:24)
	ld xbc, (HDAE5000_RAM_HdXferClusters:24)
	sub xwa, xbc
	ld (HDAE5000_RAM_FreeClusters:24), xwa
	jp ge, (.Ldc_cleanup:24)
	xor xwa, xwa
	ld (HDAE5000_RAM_FreeClusters:24), xwa
.Ldc_cleanup:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

; ---------------------------------------------------------------------------
; As HDAE5000_HD_WriteFile, but the new clusters CONTINUE the chain whose
; last cluster is in HDAE5000_RAM_HdFatSetCluster (left there by the previous
; WriteFile / AppendFile); *slot is only tested (0xFFFFFFFF: nothing to
; append to) and the free-cluster scan goes on where it stopped.  Every
; caller streams a file through HDAE5000_RAM_HdStreamBuffer: the first chunk
; with WriteFile, the rest with this (HDAE5000_HD_WriteClose / _WriteStream
; and four savers).
; AS WRITTEN, when one call needs more than one cluster the first new
; cluster is written but never linked: its pass neither links
; HdFatSetCluster to it nor makes it the new tail, so the second cluster is
; linked straight from the old tail and the first stays free (0) in the FAT.
; With 64-sector clusters (drives of >= 0x14DC93 sectors,
; HDAE5000_HD_ParseIdentify) a 0x8000-byte chunk is one cluster and this
; never happens; with 32-sector clusters every full chunk would lose 16 KB.
; In:  XWA = source, XBC = byte count, XDE = pointer to the first-cluster slot
; Out: HL = 0, or 0xFFFF when HDAE5000_RAM_AtaError is set.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_AppendFile:
	push xiz
	ldw	hl, 0xffff
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	nz, (.LHD_AppendFile_Skip1:24)
	ld	(HDAE5000_RAM_HdXferPtr), xwa
	ld	(HDAE5000_RAM_HdXferBytes), xbc
	ld	(HDAE5000_RAM_HdXferSlotPtr), xde
	call HDAE5000_HD_AppendFile_Worker
	xor	hl, hl
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_AppendFile_Skip1:24)
	ldw	hl, 0xffff
.LHD_AppendFile_Skip1:
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Register-preserving body of HDAE5000_HD_AppendFile (all registers kept).
; ---------------------------------------------------------------------------
HDAE5000_HD_AppendFile_Worker:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	xor	xwa, xwa
	xor	xbc, xbc
	ld	xwa, (HDAE5000_RAM_HdXferBytes)
	ld	xbc, (HDAE5000_RAM_ClusterBytes)
	call HDAE5000_HD_UDiv32
	cp	xbc, 0x00000000
	jp	z, (.LHD_AppendFile_Worker_Skip1:24)
	inc 1, xwa
.LHD_AppendFile_Worker_Skip1:
	ld	(HDAE5000_RAM_HdXferClusters), xwa
	ld	(HDAE5000_RAM_HdDiskFull:24), 0
	ld	xix, (HDAE5000_RAM_HdXferSlotPtr)
	ld xwa, (xix)
	cp	xwa, 0xffffffff
	jp	z, (HDAE5000_HD_AppendFile_Exit:24)
	xor	xwa, xwa
	ld	(HDAE5000_RAM_HdXferClustersDone), xwa
	ld	(HDAE5000_RAM_HdXferLinkFromPrev:24), 0
HDAE5000_HD_AppendFile_Loop:
	call HDAE5000_HD_FindFreeCluster
	ld	xwa, (HDAE5000_RAM_HdFreeCluster)
	cp	xwa, 0xfffffffd
	jp	nz, (.LHD_AppendFile_Worker_Skip2:24)
	ld	(HDAE5000_RAM_HdDiskFull:24), 1
	jp HDAE5000_HD_AppendFile_Exit
.LHD_AppendFile_Worker_Skip2:
	ld	xwa, (HDAE5000_RAM_HdFreeCluster)
	ld	(HDAE5000_RAM_HdFatSetValue), xwa
	call HDAE5000_HD_WriteCluster
	cp	(HDAE5000_RAM_HdWriteClusterError:24), 0
	jp	z, (.LHD_AppendFile_Worker_Skip3:24)
	ld	xwa, 0xffffffff
	ld	(HDAE5000_RAM_HdFatSetValue), xwa
	call HDAE5000_HD_FatSetEntry
	jp HDAE5000_HD_AppendFile_Loop
.LHD_AppendFile_Worker_Skip3:
	ld	xwa, (HDAE5000_RAM_HdXferClustersDone)
	inc 1, xwa
	ld	(HDAE5000_RAM_HdXferClustersDone), xwa
	cp	xwa, (HDAE5000_RAM_HdXferClusters)
	jp	z, (.LHD_AppendFile_Worker_Skip5:24)
	cp	(HDAE5000_RAM_HdXferLinkFromPrev:24), 0
	jp	nz, (.LHD_AppendFile_Worker_Skip4:24)
	ld	(HDAE5000_RAM_HdXferLinkFromPrev:24), 1
	jp HDAE5000_HD_AppendFile_Loop
.LHD_AppendFile_Worker_Skip4:
	call HDAE5000_HD_FatSetEntry
	ld	xwa, (HDAE5000_RAM_HdFatSetValue)
	ld	(HDAE5000_RAM_HdFatSetCluster), xwa
	jp HDAE5000_HD_AppendFile_Loop
.LHD_AppendFile_Worker_Skip5:
	call HDAE5000_HD_FatSetEntry
	ld	xwa, (HDAE5000_RAM_HdFatSetValue)
	ld	(HDAE5000_RAM_HdFatSetCluster), xwa
	ld	xwa, 0xfffffffe
	ld	(HDAE5000_RAM_HdFatSetValue), xwa
	call HDAE5000_HD_FatSetEntry
	ld	xwa, (HDAE5000_RAM_FreeClusters)
	ld	xbc, (HDAE5000_RAM_HdXferClusters)
	sub	xwa, xbc
	ld	(HDAE5000_RAM_FreeClusters), xwa
	jp	ge, (HDAE5000_HD_AppendFile_Exit:24)
	xor	xwa, xwa
	ld	(HDAE5000_RAM_FreeClusters), xwa
HDAE5000_HD_AppendFile_Exit:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

; ---------------------------------------------------------------------------
; Read a file's cluster chain into memory: follows the chain
; (HDAE5000_HD_ReadCluster, HDAE5000_HD_FatNextCluster) to the end marker
; 0xFFFFFFFE or until the byte count runs out.  The position stays in
; HDAE5000_RAM_HdChainCluster / _HdChainSector for HDAE5000_HD_ReadFileNext.
; A read error sets HDAE5000_RAM_AtaError = 1.  Does nothing while AtaError
; is already set.
; In:  XWA = destination, XBC = byte count, XDE = pointer to the first-cluster
;      slot (as HDAE5000_HD_WriteFile); 0xFFFFFFFF there reads nothing
; Out: HL = 0, or 0xFFFF when HDAE5000_RAM_AtaError is set.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_ReadFile:
	push xiz
	ldw	hl, 0xffff
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	nz, (.LHD_ReadFile_Skip1:24)
	ld	(HDAE5000_RAM_HdXferPtr), xwa
	ld	(HDAE5000_RAM_HdXferBytes), xbc
	ld	(HDAE5000_RAM_HdXferSlotPtr), xde
	call HDAE5000_HD_ReadFile_Worker
	xor	hl, hl
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_ReadFile_Skip1:24)
	ldw	hl, 0xffff
.LHD_ReadFile_Skip1:
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Register-preserving body of HDAE5000_HD_ReadFile (all registers kept);
; also invalidates the FAT cache (HdFatCacheSector = 0xFFFFFFFF).
; ---------------------------------------------------------------------------
HDAE5000_HD_ReadFile_Worker:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	ld	xwa, 0xffffffff
	ld	(HDAE5000_RAM_HdFatCacheSector), xwa
	ld	xix, (HDAE5000_RAM_HdXferSlotPtr)
	ld xwa, (xix)
	ld	(HDAE5000_RAM_HdChainCluster), xwa
	cp	xwa, 0xffffffff
	jp	z, (HDAE5000_HD_ReadFile_Exit:24)
HDAE5000_HD_ReadFile_Loop:
	ld	xwa, (HDAE5000_RAM_HdChainCluster)
	cp	xwa, 0xfffffffe
	jp	nz, (.LHD_ReadFile_Worker_Skip1:24)
	jp HDAE5000_HD_ReadFile_Exit
.LHD_ReadFile_Worker_Skip1:
	call HDAE5000_HD_ReadCluster
	cp	(HDAE5000_RAM_HdReadClusterError:24), 0
	jp	z, (.LHD_ReadFile_Worker_Skip2:24)
	ld	(HDAE5000_RAM_AtaError:24), 1
	jp HDAE5000_HD_ReadFile_Exit
.LHD_ReadFile_Worker_Skip2:
	cp	(HDAE5000_RAM_HdReadLastSector:24), 1
	jp	z, (HDAE5000_HD_ReadFile_Exit:24)
	call HDAE5000_HD_FatNextCluster
	jp HDAE5000_HD_ReadFile_Loop
HDAE5000_HD_ReadFile_Exit:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

; ---------------------------------------------------------------------------
; Continue a read begun by HDAE5000_HD_ReadFile at HDAE5000_RAM_HdChainCluster
; / _HdChainSector (HDAE5000_HD_ReadClusterFrom), for the next XBC bytes.
; In:  XWA = destination, XBC = byte count; XDE is stored in
;      HDAE5000_RAM_HdXferSlotPtr but not used
; Out: HL = 0, or 0xFFFF when HDAE5000_RAM_AtaError is set.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_ReadFileNext:
	push xiz
	ldw	hl, 0xffff
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	nz, (.LHD_ReadFileNext_Skip1:24)
	ld	(HDAE5000_RAM_HdXferPtr), xwa
	ld	(HDAE5000_RAM_HdXferBytes), xbc
	ld	(HDAE5000_RAM_HdXferSlotPtr), xde
	call HDAE5000_HD_ReadFileNext_Worker
	xor	hl, hl
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_ReadFileNext_Skip1:24)
	ldw	hl, 0xffff
.LHD_ReadFileNext_Skip1:
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Register-preserving body of HDAE5000_HD_ReadFileNext (all registers kept).
; ---------------------------------------------------------------------------
HDAE5000_HD_ReadFileNext_Worker:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
HDAE5000_HD_ReadFileNext_Loop:
	ld	xwa, (HDAE5000_RAM_HdChainCluster)
	cp	xwa, 0xfffffffe
	jp	nz, (.LHD_ReadFileNext_Worker_Skip1:24)
	jp HDAE5000_HD_ReadFileNext_Exit
.LHD_ReadFileNext_Worker_Skip1:
	call HDAE5000_HD_ReadClusterFrom
	cp	(HDAE5000_RAM_HdReadClusterError:24), 0
	jp	z, (.LHD_ReadFileNext_Worker_Skip2:24)
	ld	(HDAE5000_RAM_AtaError:24), 1
	jp HDAE5000_HD_ReadFileNext_Exit
.LHD_ReadFileNext_Worker_Skip2:
	cp	(HDAE5000_RAM_HdReadLastSector:24), 1
	jp	z, (HDAE5000_HD_ReadFileNext_Exit:24)
	call HDAE5000_HD_FatNextCluster
	jp HDAE5000_HD_ReadFileNext_Loop
HDAE5000_HD_ReadFileNext_Exit:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

; ---------------------------------------------------------------------------
; Next FREE (zero) FAT entry, scanning on from the saved position
; (HDAE5000_RAM_HdFreeScanOffset in HdFreeScanBuffer, FAT sector
; HdFreeScanFatSector = disk sector HdFreeScanDiskSector; both sector
; counters advance by HdFreeScanStarted, 0 until the first sector has been
; loaded, then 1).  The result is the cluster number, 1-based (sector index *
; 128 + offset / 4 + 1); the scan steps past it.  0xFFFFFFFD when a read
; fails or the sector index reaches HDAE5000_RAM_FatEntryCount (note:
; HDAE5000_HD_ParseIdentify sets that to the number of FAT ENTRIES, which
; HDAE5000_HD_CountFreeClusters compares with an entry counter; here it is
; compared with a sector index).
; Out: HDAE5000_RAM_HdFreeCluster.  Clobbers XWA, XBC, XDE, XHL, XIX.
; ---------------------------------------------------------------------------
HDAE5000_HD_FindFreeCluster:
	ld	xwa, 0x00000200
	cp	(HDAE5000_RAM_HdFreeScanOffset), xwa
	jp	nz, (.LHD_FindFreeCluster_Skip2:24)
	xor	xwa, xwa
	ld	(HDAE5000_RAM_HdFreeScanOffset), xwa
	ld	a, (HDAE5000_RAM_HdFreeScanStarted:24)
	add	(HDAE5000_RAM_HdFreeScanFatSector:24), xwa
	add	(HDAE5000_RAM_HdFreeScanDiskSector:24), xwa
	ld	(HDAE5000_RAM_HdFreeScanStarted:24), 1
	ld	xwa, (HDAE5000_RAM_FatEntryCount)
	cp	(HDAE5000_RAM_HdFreeScanFatSector), xwa
	jp	nz, (.LHD_FindFreeCluster_Skip1:24)
	ld	xwa, 0xfffffffd
	ld	(HDAE5000_RAM_HdFreeCluster), xwa
	jp HDAE5000_HD_FindFreeCluster_Return
.LHD_FindFreeCluster_Skip1:
	ld	xhl, (HDAE5000_RAM_HdFreeScanDiskSector)
	ld	xde, 0x00000200
	lda xix, (HDAE5000_RAM_HdFreeScanBuffer:24)
	call HDAE5000_ATA_ReadSector
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_FindFreeCluster_Skip2:24)
	ld	xwa, 0xfffffffd
	ld	(HDAE5000_RAM_HdFreeCluster), xwa
	jp HDAE5000_HD_FindFreeCluster_Return
.LHD_FindFreeCluster_Skip2:
	lda xix, (HDAE5000_RAM_HdFreeScanBuffer:24)
	ld	xbc, (HDAE5000_RAM_HdFreeScanOffset)
	add	xix, xbc
	ld xwa, (xix)
	cp	xwa, 0x00000000
	jp	z, (.LHD_FindFreeCluster_Skip3:24)
	ld	xwa, (HDAE5000_RAM_HdFreeScanOffset)
	add	xwa, 0x00000004
	ld	(HDAE5000_RAM_HdFreeScanOffset), xwa
	jp HDAE5000_HD_FindFreeCluster
.LHD_FindFreeCluster_Skip3:
	ld	xwa, (HDAE5000_RAM_HdFreeScanFatSector)
	ld	xbc, 0x00000080
	call HDAE5000_HD_Mul32
	push xwa
	ld	xwa, (HDAE5000_RAM_HdFreeScanOffset)
	ld	xbc, 4:i3
	call HDAE5000_HD_UDiv32
	ld	xbc, xwa
	pop xwa
	add	xwa, xbc
	inc 1, xwa
	ld	(HDAE5000_RAM_HdFreeCluster), xwa
	ld	xwa, (HDAE5000_RAM_HdFreeScanOffset)
	add	xwa, 0x00000004
	ld	(HDAE5000_RAM_HdFreeScanOffset), xwa
HDAE5000_HD_FindFreeCluster_Return:
	ret

; ---------------------------------------------------------------------------
; Write cluster HDAE5000_RAM_HdFreeCluster: its SectorsPerCluster sectors,
; disk sector DataStartSector + (cluster - 1) * SectorsPerCluster + i, from
; HDAE5000_RAM_HdXferPtr, which advances by 512 per sector.  A failed sector
; write sets HDAE5000_RAM_HdWriteClusterError = 1 and puts HdXferPtr back to
; its value on entry.
; Clobbers XWA, XBC, XHL, XIX.
; ---------------------------------------------------------------------------
HDAE5000_HD_WriteCluster:
	ld	(HDAE5000_RAM_HdWriteClusterError:24), 0
	xor	xwa, xwa
	ld	(HDAE5000_RAM_HdWriteClusterSector), xwa
	ld	xwa, (HDAE5000_RAM_HdXferPtr)
	ld	(HDAE5000_RAM_HdWriteClusterPtr0), xwa
HDAE5000_HD_WriteCluster_Loop:
	ld	xwa, (HDAE5000_RAM_SectorsPerCluster)
	cp	(HDAE5000_RAM_HdWriteClusterSector), xwa
	jp	z, (HDAE5000_HD_WriteCluster_Return:24)
	ld	xwa, (HDAE5000_RAM_HdFreeCluster)
	dec	1, xwa
	ld	xbc, (HDAE5000_RAM_SectorsPerCluster)
	call HDAE5000_HD_Mul32
	ld	xbc, (HDAE5000_RAM_DataStartSector)
	add	xwa, xbc
	ld	xbc, (HDAE5000_RAM_HdWriteClusterSector)
	add	xwa, xbc
	ld	xhl, xwa
	ld	xix, (HDAE5000_RAM_HdXferPtr)
	call HDAE5000_ATA_WriteSector
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_WriteCluster_Skip1:24)
	ld	(HDAE5000_RAM_HdWriteClusterError:24), 1
	ld	xwa, (HDAE5000_RAM_HdWriteClusterPtr0)
	ld	(HDAE5000_RAM_HdXferPtr), xwa
	jp HDAE5000_HD_WriteCluster_Return
.LHD_WriteCluster_Skip1:
	ld	xwa, (HDAE5000_RAM_HdWriteClusterSector)
	inc 1, xwa
	ld	(HDAE5000_RAM_HdWriteClusterSector), xwa
	ld	xwa, (HDAE5000_RAM_HdXferPtr)
	add	xwa, 0x00000200
	ld	(HDAE5000_RAM_HdXferPtr), xwa
	jp HDAE5000_HD_WriteCluster_Loop
HDAE5000_HD_WriteCluster_Return:
	ret

; ---------------------------------------------------------------------------
; FAT[HDAE5000_RAM_HdFatSetCluster] = HDAE5000_RAM_HdFatSetValue.  Entry
; cluster-1 lives in FAT sector (cluster-1)/128 (-> HdFatSector) at byte
; ((cluster-1)%128)*4 (-> HdFatEntryOffset).  One FAT sector is cached in
; HDAE5000_RAM_HdFatCache, its index in HdFatCacheSector (0xFFFFFFFF = none):
; a different sector is flushed and then loaded (HDAE5000_HD_FatFlushSector,
; HDAE5000_HD_FatLoadSector); storing the end marker 0xFFFFFFFE also flushes.
; Clobbers XWA, XBC, XHL, XIX.
; ---------------------------------------------------------------------------
HDAE5000_HD_FatSetEntry:
	ld	xwa, (HDAE5000_RAM_HdFatSetCluster)
	dec	1, xwa
	ld	xbc, 0x00000080
	call HDAE5000_HD_UDiv32
	push xwa
	ld	xwa, 4:i3
	call HDAE5000_HD_Mul32
	ld	xbc, xwa
	pop xwa
	ld	(HDAE5000_RAM_HdFatSector), xwa
	ld	(HDAE5000_RAM_HdFatEntryOffset), xbc
	ld	xwa, (HDAE5000_RAM_HdFatCacheSector)
	cp	xwa, 0xffffffff
	jp	nz, (.LHD_FatSetEntry_Skip1:24)
	call HDAE5000_HD_FatLoadSector
	jp HDAE5000_HD_FatSetEntry_Store
.LHD_FatSetEntry_Skip1:
	ld	xwa, (HDAE5000_RAM_HdFatSector)
	ld	xbc, (HDAE5000_RAM_HdFatCacheSector)
	cp	xwa, xbc
	jp	nz, (.LHD_FatSetEntry_Store_Skip1:24)
HDAE5000_HD_FatSetEntry_Store:
	lda xix, (HDAE5000_RAM_HdFatCache:24)
	ld	xbc, (HDAE5000_RAM_HdFatEntryOffset)
	add	xix, xbc
	ld	xwa, (HDAE5000_RAM_HdFatSetValue)
	ld (xix), xwa
	cp	xwa, 0xfffffffe
	jp	nz, (HDAE5000_HD_FatSetEntry_Return:24)
	call HDAE5000_HD_FatFlushSector
	jp HDAE5000_HD_FatSetEntry_Return
.LHD_FatSetEntry_Store_Skip1:
	call HDAE5000_HD_FatFlushSector
	call HDAE5000_HD_FatLoadSector
	jp HDAE5000_HD_FatSetEntry_Store
HDAE5000_HD_FatSetEntry_Return:
	ret

; ---------------------------------------------------------------------------
; Read FAT sector HDAE5000_RAM_HdFatSector (disk sector FatStartSector + it)
; into HDAE5000_RAM_HdFatCache and record it in HdFatCacheSector.
; ---------------------------------------------------------------------------
HDAE5000_HD_FatLoadSector:
	ld	xhl, (HDAE5000_RAM_FatStartSector)
	ld	xwa, (HDAE5000_RAM_HdFatSector)
	add	xhl, xwa
	ld	xde, 0x00000200
	lda xix, (HDAE5000_RAM_HdFatCache:24)
	call HDAE5000_ATA_ReadSector
	ld	xwa, (HDAE5000_RAM_HdFatSector)
	ld	(HDAE5000_RAM_HdFatCacheSector), xwa
	ret

; ---------------------------------------------------------------------------
; Write HDAE5000_RAM_HdFatCache back to FAT sector HdFatCacheSector (disk
; sector FatStartSector + it).
; ---------------------------------------------------------------------------
HDAE5000_HD_FatFlushSector:
	ld	xhl, (HDAE5000_RAM_FatStartSector)
	ld	xwa, (HDAE5000_RAM_HdFatCacheSector)
	add	xhl, xwa
	lda xix, (HDAE5000_RAM_HdFatCache:24)
	call HDAE5000_ATA_WriteSector
	ret

; ---------------------------------------------------------------------------
; Read cluster HDAE5000_RAM_HdChainCluster from its first sector:
; HdChainSector = 0, then falls into HDAE5000_HD_ReadClusterFrom.
; ---------------------------------------------------------------------------
HDAE5000_HD_ReadCluster:
	ld	xwa, 0:i3
	ld	(HDAE5000_RAM_HdChainSector), xwa

; ---------------------------------------------------------------------------
; Read cluster HDAE5000_RAM_HdChainCluster from sector HdChainSector on into
; HDAE5000_RAM_HdXferPtr (advanced by 512 per sector), counting
; HdXferBytes down; a last sector with fewer than 512 bytes left is read
; partially (HdSectorBytes) and sets HdReadLastSector = 1.  HdChainSector
; goes back to 0 once the whole cluster is read.  A failed sector read sets
; HdReadClusterError = 1.  Clobbers XWA, XBC, XDE, XHL, XIX.
; ---------------------------------------------------------------------------
HDAE5000_HD_ReadClusterFrom:
	ld	(HDAE5000_RAM_HdReadLastSector:24), 0
	ld	(HDAE5000_RAM_HdReadClusterError:24), 0
HDAE5000_HD_ReadClusterFrom_Loop:
	ld	xwa, (HDAE5000_RAM_HdChainSector)
	cp	xwa, (HDAE5000_RAM_SectorsPerCluster)
	jp	nz, (.LHD_ReadClusterFrom_Skip1:24)
	ld	xwa, 0:i3
	ld	(HDAE5000_RAM_HdChainSector), xwa
	jp HDAE5000_HD_ReadClusterFrom_Return
.LHD_ReadClusterFrom_Skip1:
	ld	xwa, (HDAE5000_RAM_HdChainCluster)
	dec	1, xwa
	ld	xbc, (HDAE5000_RAM_SectorsPerCluster)
	call HDAE5000_HD_Mul32
	ld	xbc, (HDAE5000_RAM_DataStartSector)
	add	xwa, xbc
	ld	xbc, (HDAE5000_RAM_HdChainSector)
	add	xwa, xbc
	ld	xhl, xwa
	ld	xwa, (HDAE5000_RAM_HdXferBytes)
	cp	xwa, 0x00000200
	jp	nc, (.LHD_ReadClusterFrom_Skip2:24)
	ld	xwa, (HDAE5000_RAM_HdXferBytes)
	ld	(HDAE5000_RAM_HdSectorBytes), xwa
	ld	(HDAE5000_RAM_HdReadLastSector:24), 1
	jp HDAE5000_HD_ReadClusterFrom_Read
.LHD_ReadClusterFrom_Skip2:
	ld	xwa, 0x00000200
	ld	(HDAE5000_RAM_HdSectorBytes), xwa
HDAE5000_HD_ReadClusterFrom_Read:
	ld	xix, (HDAE5000_RAM_HdXferPtr)
	ld	xde, (HDAE5000_RAM_HdSectorBytes)
	call HDAE5000_ATA_ReadSector
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_ReadClusterFrom_Read_Skip1:24)
	ld	(HDAE5000_RAM_HdReadClusterError:24), 1
	jp HDAE5000_HD_ReadClusterFrom_Return
.LHD_ReadClusterFrom_Read_Skip1:
	cp	(HDAE5000_RAM_HdReadLastSector:24), 1
	jp	z, (HDAE5000_HD_ReadClusterFrom_Return:24)
	ld	xwa, (HDAE5000_RAM_HdXferBytes)
	ld	xbc, 0x00000200
	sub	xwa, xbc
	ld	(HDAE5000_RAM_HdXferBytes), xwa
	ld	xwa, (HDAE5000_RAM_HdChainSector)
	inc 1, xwa
	ld	(HDAE5000_RAM_HdChainSector), xwa
	ld	xwa, (HDAE5000_RAM_HdXferPtr)
	ld	xbc, 0x00000200
	add	xwa, xbc
	ld	(HDAE5000_RAM_HdXferPtr), xwa
	jp HDAE5000_HD_ReadClusterFrom_Loop
HDAE5000_HD_ReadClusterFrom_Return:
	ret

; ---------------------------------------------------------------------------
; HDAE5000_RAM_HdChainCluster = FAT[HdChainCluster], the next cluster of the
; chain (the entry's offset is left in HdFatEntryOffset).  Loads the FAT
; sector into HdFatCache when it is not the cached one -- without flushing
; the old one: read-only use.
; ---------------------------------------------------------------------------
HDAE5000_HD_FatNextCluster:
	ld	xwa, (HDAE5000_RAM_HdChainCluster)
	dec	1, xwa
	ld	xbc, 0x00000080
	call HDAE5000_HD_UDiv32
	ld	(HDAE5000_RAM_HdFatSector), xwa
	ld	xwa, 4:i3
	call HDAE5000_HD_Mul32
	ld	(HDAE5000_RAM_HdFatEntryOffset), xwa
	ld	xwa, (HDAE5000_RAM_HdFatSector)
	cp	xwa, (HDAE5000_RAM_HdFatCacheSector)
	jp	nz, (.LHD_FatNextCluster_Read_Skip1:24)
HDAE5000_HD_FatNextCluster_Read:
	lda xix, (HDAE5000_RAM_HdFatCache:24)
	ld	xwa, (HDAE5000_RAM_HdFatEntryOffset)
	add	xix, xwa
	ld xwa, (xix)
	ld	(HDAE5000_RAM_HdChainCluster), xwa
	jp HDAE5000_HD_FatNextCluster_Return
.LHD_FatNextCluster_Read_Skip1:
	call HDAE5000_HD_FatLoadSector
	jp HDAE5000_HD_FatNextCluster_Read
HDAE5000_HD_FatNextCluster_Return:
	ret

; ---------------------------------------------------------------------------
; Release the cluster chain starting at XWA (HDAE5000_HD_FreeChain_Worker).
; In:  XWA = first cluster
; RAM: HDAE5000_RAM_HdFreeChainStart
; ---------------------------------------------------------------------------
HDAE5000_HD_FreeChain:
	ld	(HDAE5000_RAM_HdFreeChainStart), xwa
	call HDAE5000_HD_FreeChain_Worker
	ret

; ---------------------------------------------------------------------------
; Release the chain starting at HDAE5000_RAM_HdFreeChainStart: each entry is
; set to 0 (free) and its FAT sector written back, up to the end marker
; 0xFFFFFFFE; the number released (HdFreeChainCount) is added to
; HDAE5000_RAM_FreeClusters.  An entry that is already 0 stops it early,
; without that update.  Invalidates the FAT cache first.  All registers kept.
; ---------------------------------------------------------------------------
HDAE5000_HD_FreeChain_Worker:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	ld	xwa, 0xffffffff
	xor	xbc, xbc
	ld	(HDAE5000_RAM_HdFatCacheSector), xwa
	ld	(HDAE5000_RAM_HdFatEntryOffset), xbc
	ld	(HDAE5000_RAM_HdFreeChainCount), xbc
	ld	xwa, (HDAE5000_RAM_HdFreeChainStart)
	ld	(HDAE5000_RAM_HdChainCluster), xwa
.LHD_FreeChain_Worker_Loop1:
	call HDAE5000_HD_FatNextCluster
	ld	xwa, (HDAE5000_RAM_HdChainCluster)
	cp	xwa, 0x00000000
	jp	z, (.LHD_FreeChain_Worker_Skip1:24)
	lda xix, (HDAE5000_RAM_HdFatCache:24)
	ld	xbc, (HDAE5000_RAM_HdFatEntryOffset)
	add	xix, xbc
	xor	xwa, xwa
	ld (xix), xwa
	ld	xwa, (HDAE5000_RAM_HdFreeChainCount)
	inc 1, xwa
	ld	(HDAE5000_RAM_HdFreeChainCount), xwa
	call HDAE5000_HD_FatFlushSector
	ld	xwa, (HDAE5000_RAM_HdChainCluster)
	cp	xwa, 0xfffffffe
	jp	nz, (.LHD_FreeChain_Worker_Loop1:24)
	call HDAE5000_HD_FatFlushSector
	ld	xwa, (HDAE5000_RAM_FreeClusters)
	ld	xbc, (HDAE5000_RAM_HdFreeChainCount)
	add	xwa, xbc
	ld	(HDAE5000_RAM_FreeClusters), xwa
.LHD_FreeChain_Worker_Skip1:
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

; ---------------------------------------------------------------------------
; C-callable format: HDAE5000_HD_Format_Worker, then HDAE5000_ATA_Standby and
; HDAE5000_HD_ClearStatusBytes.  Only caller: HDAE5000_HD_FormatDrive.
; Out: HL = HDAE5000_RAM_AtaError, the worker's step code (0 = formatted).
; ---------------------------------------------------------------------------
HDAE5000_HD_Format:	; (cross-reference from Display_Init)
	call HDAE5000_HD_Format_Worker
	xor	hl, hl
	ld	l, (HDAE5000_RAM_AtaError:24)
	pushw hl
	call HDAE5000_ATA_Standby
	call HDAE5000_HD_ClearStatusBytes
	popw hl
	ret

; ---------------------------------------------------------------------------
; Format the drive; the step that fails leaves its code in
; HDAE5000_RAM_AtaError:
; 1. IDENTIFY and HDAE5000_HD_ParseIdentify; blank tables
;    (HDAE5000_HD_InitTables) written (HDAE5000_HD_WriteTables; error 1).
;    An IDENTIFY failure loads 6 into A, which the register restore at the
;    exit discards: AtaError keeps ATA_IdentifyDevice's own code.
; 2. Zero the 3,906 sectors from FatStartSector (2) -- the whole FAT area,
;    up to the tables at 3908 (write error 2) -- then read every one back
;    into HdVerifyBuffer and compare it with the zero sector HdSectorBuffer
;    (3 = read error, 4 = mismatch).
; 3. Build the settings sector (HDAE5000_HD_BuildSettingsSector) and write
;    it to sector 1 (error 5).
; 4. Remount as HDAE5000_HD_Init does: soft reset (11), IDENTIFY (6), read
;    sector 1 (7), signature (8), its six setting bytes to QuickLoadMode ..
;    LyricBackColor, free clusters (9), tables (10).
; Always ends with HDAE5000_ATA_Standby.  All registers kept.
; RAM: HDAE5000_RAM_HdFormatSector, _HdFormatCount, _HdSectorBuffer,
;      _HdVerifyBuffer, _HdSettingsSector
; ---------------------------------------------------------------------------
HDAE5000_HD_Format_Worker:
	push xwa
	push xbc
	push xde
	push xhl
	push xix
	push xiy
	push xiz
	call HDAE5000_ATA_IdentifyDevice
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Format_Worker_Skip1:24)
	ld	a, 0x06:opc
	jp HDAE5000_HD_Format_Exit
.LHD_Format_Worker_Skip1:
	call HDAE5000_HD_ParseIdentify
	call HDAE5000_HD_InitTables
	call HDAE5000_HD_WriteTables
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Format_Worker_Skip2:24)
	ld	(HDAE5000_RAM_AtaError:24), 1
	jp HDAE5000_HD_Format_Exit
.LHD_Format_Worker_Skip2:
	lda xix, (HDAE5000_RAM_HdSectorBuffer:24)
	call HDAE5000_HD_ZeroSector
	ld	xwa, (HDAE5000_RAM_FatStartSector)
	ld	(HDAE5000_RAM_HdFormatSector), xwa
	xor	xwa, xwa
	ld	(HDAE5000_RAM_HdFormatCount), xwa
HDAE5000_HD_Format_ClearLoop:
	ld	xwa, (HDAE5000_RAM_HdFormatCount)
	cp	xwa, 0x00000f42
	jp	z, (.LHD_Format_ClearLoop_Skip2:24)
	ld	xhl, (HDAE5000_RAM_HdFormatSector)
	lda xix, (HDAE5000_RAM_HdSectorBuffer:24)
	call HDAE5000_ATA_WriteSector
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Format_ClearLoop_Skip1:24)
	ld	(HDAE5000_RAM_AtaError:24), 2
	jp HDAE5000_HD_Format_Exit
.LHD_Format_ClearLoop_Skip1:
	ld	xwa, (HDAE5000_RAM_HdFormatSector)
	add	xwa, 0x00000001
	ld	(HDAE5000_RAM_HdFormatSector), xwa
	ld	xwa, (HDAE5000_RAM_HdFormatCount)
	add	xwa, 0x00000001
	ld	(HDAE5000_RAM_HdFormatCount), xwa
	jp HDAE5000_HD_Format_ClearLoop
.LHD_Format_ClearLoop_Skip2:
	ld	xwa, (HDAE5000_RAM_FatStartSector)
	ld	(HDAE5000_RAM_HdFormatSector), xwa
	xor	xwa, xwa
	ld	(HDAE5000_RAM_HdFormatCount), xwa
HDAE5000_HD_Format_VerifyLoop:
	ld	xwa, (HDAE5000_RAM_HdFormatCount)
	cp	xwa, 0x00000f42
	jp	z, (.LHD_Format_CompareLoop_Skip2:24)
	ld	xhl, (HDAE5000_RAM_HdFormatSector)
	ld	xde, 0x00000200
	lda xix, (HDAE5000_RAM_HdVerifyBuffer:24)
	call HDAE5000_ATA_ReadSector
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Format_VerifyLoop_Skip1:24)
	ld	(HDAE5000_RAM_AtaError:24), 3
	jp HDAE5000_HD_Format_Exit
.LHD_Format_VerifyLoop_Skip1:
	lda xix, (HDAE5000_RAM_HdSectorBuffer:24)
	lda xiy, (HDAE5000_RAM_HdVerifyBuffer:24)
	ld	bc, 0:i3
HDAE5000_HD_Format_CompareLoop:
	cp	bc, 0x0200
	jp	z, (.LHD_Format_CompareLoop_Skip1:24)
	ld	xwa, (xix+bc)
	cp	xwa, (xiy+bc)
	jr	z, HDAE5000_HD_Format_CompareLoop_Skip
	ld	(HDAE5000_RAM_AtaError:24), 4
	jp HDAE5000_HD_Format_Exit
HDAE5000_HD_Format_CompareLoop_Skip:
	inc	4, bc
	jp HDAE5000_HD_Format_CompareLoop
.LHD_Format_CompareLoop_Skip1:
	ld	xwa, (HDAE5000_RAM_HdFormatSector)
	add	xwa, 0x00000001
	ld	(HDAE5000_RAM_HdFormatSector), xwa
	ld	xwa, (HDAE5000_RAM_HdFormatCount)
	add	xwa, 0x00000001
	ld	(HDAE5000_RAM_HdFormatCount), xwa
	jp HDAE5000_HD_Format_VerifyLoop
.LHD_Format_CompareLoop_Skip2:
	call HDAE5000_HD_BuildSettingsSector
	ld	xhl, 1:i3
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	call HDAE5000_ATA_WriteSector
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Format_CompareLoop_Skip3:24)
	ld	(HDAE5000_RAM_AtaError:24), 5
	jp HDAE5000_HD_Format_Exit
.LHD_Format_CompareLoop_Skip3:
	call HDAE5000_ATA_SoftReset
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Format_CompareLoop_Skip4:24)
	ld	(HDAE5000_RAM_AtaError:24), 11
	jp HDAE5000_HD_Format_Exit
.LHD_Format_CompareLoop_Skip4:
	call HDAE5000_ATA_IdentifyDevice
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Format_CompareLoop_Skip5:24)
	ld	(HDAE5000_RAM_AtaError:24), 6
	jp HDAE5000_HD_Format_Exit
.LHD_Format_CompareLoop_Skip5:
	call HDAE5000_HD_ParseIdentify
	ld	xhl, 1:i3
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	ld	xde, 0x00000200
	call HDAE5000_ATA_ReadSector
	cp	(HDAE5000_RAM_AtaError:24), 0
	jr	z, HDAE5000_HD_Format_CompareLoop_Skip2
	ld	(HDAE5000_RAM_AtaError:24), 7
	jp HDAE5000_HD_Format_Exit
HDAE5000_HD_Format_CompareLoop_Skip2:
	call HDAE5000_HD_CheckSignature
	cp	(HDAE5000_RAM_HdSignatureOk:24), 1
	jp	z, (.LHD_Format_CompareLoop_Skip6:24)
	ld	(HDAE5000_RAM_AtaError:24), 8
	jp HDAE5000_HD_Format_Exit
.LHD_Format_CompareLoop_Skip6:
	ld	xix, HDAE5000_RAM_HdSettingsSector+120
	ld	a, (xix)
	ld	(HDAE5000_RAM_QuickLoadMode:24), a
	inc 1, xix
	ld	a, (xix)
	ld	(HDAE5000_RAM_LoadByNumberMode:24), a
	inc 1, xix
	ld	a, (xix)
	ld	(HDAE5000_RAM_JumpAfterLoad:24), a
	inc 1, xix
	ld	a, (xix)
	ld	(HDAE5000_RAM_LyricJump:24), a
	call HDAE5000_HD_CountFreeClusters
	cp	(HDAE5000_RAM_AtaError:24), 0
	cp	(HDAE5000_RAM_AtaError:24), 0
	jp	z, (.LHD_Format_CompareLoop_Skip7:24)
	ld	(HDAE5000_RAM_AtaError:24), 9
	jp HDAE5000_HD_Format_Exit
.LHD_Format_CompareLoop_Skip7:
	call HDAE5000_HD_ReadTables
	cp	(HDAE5000_RAM_AtaError:24), 0x00
	jp	z, (HDAE5000_HD_Format_Exit:24)
	ld	(HDAE5000_RAM_AtaError), 0x0a
	jp	HDAE5000_HD_Format_Exit
HDAE5000_HD_Format_Exit:
	call	HDAE5000_ATA_Standby
	pop xiz
	pop xiy
	pop xix
	pop xhl
	pop xde
	pop xbc
	pop xwa
	ret

; ---------------------------------------------------------------------------
; Zero 512 bytes.
; In:  XIX = buffer
; Out: A = 0, BC = 0x200.
; ---------------------------------------------------------------------------
HDAE5000_HD_ZeroSector:
	ld	a, 0x00:opc
	xor	bc, bc
HDAE5000_HD_ZeroSector_Loop:
	cp	bc, 0x0200
	jp	z, (.LHD_ZeroSector_Return1:24)
	ld	(xix+bc), a
	inc	1, bc
	jp HDAE5000_HD_ZeroSector_Loop
.LHD_ZeroSector_Return1:
	ret

; ---------------------------------------------------------------------------
; Build a fresh sector-1 image in HDAE5000_RAM_HdSettingsSector: zeroed, the
; signature AA55AA55 F4F1F2F3, the 112-byte HDAE5000_Version_Info, the six
; setting bytes = 1 (also stored to QuickLoadMode .. LyricBackColor), then
; 0xFFFFFFFF.  The format's counterpart of HDAE5000_HD_SaveSettings, which
; writes the current settings instead of 1s.
; Out: clobbers XWA, XIX, XIY, XIZ.
; ---------------------------------------------------------------------------
HDAE5000_HD_BuildSettingsSector:
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	call HDAE5000_HD_ZeroSector
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	ld	xwa, 0xaa55aa55
	ld (xix), xwa
	inc 4, xix
	ld	xwa, 0xf4f1f2f3
	ld (xix), xwa
	inc 4, xix
	lda xiy, (HDAE5000_Version_Info:24)
	lda xiz, (HDAE5000_Version_Info_End:24)
HDAE5000_HD_BuildSettingsSector_CopyVersion:
	cp	xiy, xiz
	jp	z, (.LHD_BuildSettingsSector_CopyVersion_Skip1:24)
	ld	a, (xiy)
	ld	(xix), a
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_HD_BuildSettingsSector_CopyVersion
.LHD_BuildSettingsSector_CopyVersion_Skip1:
	ld	(xix), 0x01
	ld	(HDAE5000_RAM_QuickLoadMode:24), 1
	inc 1, xix
	ld	(xix), 0x01
	ld	(HDAE5000_RAM_LoadByNumberMode:24), 1
	inc 1, xix
	ld	(xix), 0x01
	ld	(HDAE5000_RAM_JumpAfterLoad:24), 1
	inc 1, xix
	ld	(xix), 0x01
	ld	(HDAE5000_RAM_LyricJump:24), 1
	inc 1, xix
	ld	xwa, 0xffffffff
	ld (xix), xwa
	ret

HDAE5000_DeadLib_Block64Differs:
	ld	xix, (0x229d80)
	lda xiy, (0x201556:24)
	ld	bc, 0:i3
HDAE5000_DeadLib_Block64Differs_Loop:
	cp	bc, 0x0040
	jp	z, (.LDeadLib_Block64Differs_Done:24)
	ld	a, (xix)
	cp	a, (xiy)
	jp	nz, (.LDeadLib_Block64Differs_Skip:24)
	inc 1, xix
	inc 1, xiy
	inc	1, bc
	jp HDAE5000_DeadLib_Block64Differs_Loop
.LDeadLib_Block64Differs_Skip:
	ld	a, 0x01:opc
	jp HDAE5000_DeadLib_Block64Differs_Return
.LDeadLib_Block64Differs_Done:
	ld	a, 0x00:opc
HDAE5000_DeadLib_Block64Differs_Return:
	ret

HDAE5000_DeadLib_CopyName26:
	push xix
	push xiy
	push xbc
	push xwa
	ld	bc, 0:i3
	lda xix, (0x200c98:24)
	lda xiy, (0x201538:24)
HDAE5000_DeadLib_CopyName26_Loop:
	cp	bc, 0x001a
	jp	z, (.LDeadLib_CopyName26_Epilogue:24)
	ld	a, (xiy)
	ld	(xix), a
	inc	1, bc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_CopyName26_Loop
.LDeadLib_CopyName26_Epilogue:
	pop xwa
	pop xbc
	pop xiy
	pop xix
	ret

; ---------------------------------------------------------------------------
; HDAE5000_RAM_HdVersionKeyWord = 0x0000FFEE: the long
; HDAE5000_HD_CheckVersionKey compares with the "XXXX" of
; HDAE5000_Version_Key.  Called by HDAE5000_HD_CheckSignature.
; ---------------------------------------------------------------------------
HDAE5000_HD_ResetVersionKeyWord:
	ld	xwa, 0x0000ffee
	ld	(HDAE5000_RAM_HdVersionKeyWord), xwa
	ret

; ----------------------------------------------------------------------------
; UNREACHABLE CODE, 0x298936-0x298B6B and 0x298C52-0x298C7C, 0x298CBC-0x29992A
; minus the live routines labelled in it (HDAE5000_HD_GetDiskUsage,
; HDAE5000_HD_ComputeDiskUsage, HDAE5000_HD_ClearStatusBytes,
; HDAE5000_HD_ClusterCount, HDAE5000_HD_BytesToClusters,
; HDAE5000_HD_CheckVersionKey, HDAE5000_HD_LoadSettings,
; HDAE5000_HD_SaveSettings):
; no path from any entry reaches it (scripts/analysis/hdae5000_reachability.py:
; no symbolic or numeric operand, no .long pointer, no switch table names
; it).  It is a browser/name-history library over the in-RAM tables that
; HDAE5000_HD_GetBlockInfo describes -- a cursor per page of 24 rows for the
; directory names (page 0x229D9F, cursors 0x229DDA[5], per-row byte
; 0x229DDF[120]) and for the FLS rows (page 0x229DA0, cursors 0x229E57[5],
; per-row byte 0x229E5C[120]), 5-deep rings of recent names (0x201434 x26,
; 0x2013B2 x16, 0x2014B6 x16, indexes 0x229DC2..0x229DC7) and the name
; buffers 0x200C98 / 0x200870.  Routines that had no name of their own are
; labelled HDAE5000_DeadLib_<what the body does> (FindFreeSlot32, Copy64Out ...;
; scripts/renaming/fix_hdae5000_dead_owners.py placed the entry labels, and
; nothing refers to them).  Some of it does
; not fit the live layout (it uses 0x229C94, the data-sector count of
; HDAE5000_HD_ParseIdentify, as a pointer), so it may predate it.
; ----------------------------------------------------------------------------
HDAE5000_NameList5_Contains:
	; A = 1 if the 26 bytes at XIY equal one of the five 26-byte entries at XIX, else 0 (unreachable)
	ld	xbc, 0:i3
HDAE5000_NameList5_Contains_EntryLoop:
	cp	xbc, 0x00000005
	jp	z, (.LNameList5_Contains_CharLoop_Skip3:24)
	ld	xhl, 0:i3
HDAE5000_NameList5_Contains_CharLoop:
	cp	xhl, 0x0000001a
	jp	z, (.LNameList5_Contains_CharLoop_Skip2:24)
	ld	a, (xiy+hl)
	cp	(xix+hl), a
	jp	nz, (.LNameList5_Contains_CharLoop_Skip1:24)
	inc 1, xhl
	jp HDAE5000_NameList5_Contains_CharLoop
.LNameList5_Contains_CharLoop_Skip1:
	add	xix, 0x0000001a
	inc 1, xbc
	jp HDAE5000_NameList5_Contains_EntryLoop
.LNameList5_Contains_CharLoop_Skip2:
	ld	a, 0x01:opc
	jp HDAE5000_NameList5_Contains_Return
.LNameList5_Contains_CharLoop_Skip3:
	ld	a, 0x00:opc
HDAE5000_NameList5_Contains_Return:
	ret

; ---------------------------------------------------------------------------
; A = 1 when the 26 bytes at XIX are all spaces, else 0 (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_Name26_IsBlank:
	ld	xbc, 0:i3
HDAE5000_Name26_IsBlank_Loop:
	cp	xbc, 0x0000001a
	jp	z, (.LName26_IsBlank_Skip1:24)
	cp	(xix+bc), 0x20
	jp	nz, (.LName26_IsBlank_Skip2:24)
	inc 1, xbc
	jp HDAE5000_Name26_IsBlank_Loop
.LName26_IsBlank_Skip1:
	ld	a, 0x01:opc
	jp HDAE5000_Name26_IsBlank_Return
.LName26_IsBlank_Skip2:
	ld	a, 0x00:opc
HDAE5000_Name26_IsBlank_Return:
	ret

	push xix
	push xbc
	push xwa
	xor	xwa, xwa
	ld	a, (0x229D9E:24)
	add	xix, xwa
	ld	c, (xix)
	lda xix, (0x200c98:24)
	xor	xwa, xwa
	ld	a, (0x229D9D:24)
	add	xix, xwa
	ld	(xix), c
	pop xwa
	pop xbc
	pop xix
	ret

; ---------------------------------------------------------------------------
; Fill the 12-byte field at 0x200864 with "0" (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_Field12_FillZeros:
	push xix
	push xbc
	lda xix, (0x200864:24)
	ld	bc, 0:i3
HDAE5000_Field12_FillZeros_Loop:
	cp	bc, 0x000c
	jp	z, (.LField12_FillZeros_Skip1:24)
	ld	(xix+bc), 0x30
	inc	1, bc
	jp HDAE5000_Field12_FillZeros_Loop
.LField12_FillZeros_Skip1:
	pop xbc
	pop xix
	ret

; ---------------------------------------------------------------------------
; Fill the 12-byte field at 0x200864 with spaces (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_Field12_FillSpaces:
	push xix
	push xbc
	lda xix, (0x200864:24)
	ld	bc, 0:i3
HDAE5000_Field12_FillSpaces_Loop:
	cp	bc, 0x000c
	jp	z, (.LField12_FillSpaces_Skip1:24)
	ld	(xix+bc), 0x20
	inc	1, bc
	jp HDAE5000_Field12_FillSpaces_Loop
.LField12_FillSpaces_Skip1:
	pop xbc
	pop xix
	ret

HDAE5000_DeadLib_Fill40Spaces:
	push xix
	push xbc
	lda xix, (0x200870:24)
	ld	bc, 0:i3
HDAE5000_DeadLib_Fill40Spaces_Loop:
	cp	bc, 0x0028
	jp	z, (.LDeadLib_Fill40Spaces_Epilogue:24)
	ld	(xix+bc), 0x20
	inc	1, bc
	jp HDAE5000_DeadLib_Fill40Spaces_Loop
.LDeadLib_Fill40Spaces_Epilogue:
	pop xbc
	pop xix
	ret

; ---------------------------------------------------------------------------
; XWA in decimal, right-aligned in the field ending at 0x20086E and
; zero-filled; digits from HDAE5000_DecimalDigits (unreachable).
; In:  XWA = value
; ---------------------------------------------------------------------------
HDAE5000_FormatDecimal12_ZeroFill:
	push xix
	push xiy
	push xde
	push xbc
	call HDAE5000_Field12_FillZeros
HDAE5000_FormatDecimal12_Digits:
	ld	xde, 0:i3
.LFormatDecimal12_Digits_Loop1:
	ld	xbc, 0x0000000a
	call HDAE5000_HD_UDiv32
	push xbc
	inc 1, xde
	cp	xwa, 0x00000000
	jp	nz, (.LFormatDecimal12_Digits_Loop1:24)
	lda xix, (0x20086e:24)
	sub	xix, xde
.LFormatDecimal12_Digits_Loop2:
	lda xiy, (HDAE5000_DecimalDigits:24)
	pop xbc
	ld	qbc, 0
	add	xiy, xbc
	ld	a, (xiy)
	ld	(xix), a
	inc 1, xix
	dec	1, xde
	cp	xde, 0x00000000
	jp	nz, (.LFormatDecimal12_Digits_Loop2:24)
	pop xbc
	pop xde
	pop xiy
	pop xix
	ret

	push xix
	push xiy
	push xde
	push xbc
	call HDAE5000_Field12_FillSpaces
	jp HDAE5000_FormatDecimal12_Digits
HDAE5000_DeadLib_Delay6x4095:
	push xwa
	push xbc
	ld	xwa, 6:i3
HDAE5000_DeadLib_Delay6x4095_Outer:
	cp	xwa, 0x00000000
	jp	z, (.LDeadLib_Delay6x4095_Inner_Skip2:24)
	ld	xbc, 0:i3
HDAE5000_DeadLib_Delay6x4095_Inner:
	cp	xbc, 0x00000fff
	jp	z, (.LDeadLib_Delay6x4095_Inner_Skip1:24)
	inc 1, xbc
	jp HDAE5000_DeadLib_Delay6x4095_Inner
.LDeadLib_Delay6x4095_Inner_Skip1:
	dec	1, xwa
	jp HDAE5000_DeadLib_Delay6x4095_Outer
.LDeadLib_Delay6x4095_Inner_Skip2:
	pop xbc
	pop xwa
	ret

HDAE5000_DeadLib_Delay70x4095:
	push xwa
	push xbc
	ld	xwa, 0x00000046
HDAE5000_DeadLib_Delay70x4095_Outer:
	cp	xwa, 0x00000000
	jp	z, (.LDeadLib_Delay70x4095_Inner_Skip2:24)
	ld	xbc, 0:i3
HDAE5000_DeadLib_Delay70x4095_Inner:
	cp	xbc, 0x00000fff
	jp	z, (.LDeadLib_Delay70x4095_Inner_Skip1:24)
	inc 1, xbc
	jp HDAE5000_DeadLib_Delay70x4095_Inner
.LDeadLib_Delay70x4095_Inner_Skip1:
	dec	1, xwa
	jp HDAE5000_DeadLib_Delay70x4095_Outer
.LDeadLib_Delay70x4095_Inner_Skip2:
	pop xbc
	pop xwa
	ret

HDAE5000_DeadLib_Delay37x4095:
	push xwa
	push xbc
	ld	xwa, 0x00000025
HDAE5000_DeadLib_Delay37x4095_Outer:
	cp	xwa, 0x00000000
	jp	z, (.LDeadLib_Delay37x4095_Inner_Skip2:24)
	ld	xbc, 0:i3
HDAE5000_DeadLib_Delay37x4095_Inner:
	cp	xbc, 0x00000fff
	jp	z, (.LDeadLib_Delay37x4095_Inner_Skip1:24)
	inc 1, xbc
	jp HDAE5000_DeadLib_Delay37x4095_Inner
.LDeadLib_Delay37x4095_Inner_Skip1:
	dec	1, xwa
	jp HDAE5000_DeadLib_Delay37x4095_Outer
.LDeadLib_Delay37x4095_Inner_Skip2:
	pop xbc
	pop xwa
	ret

; ---------------------------------------------------------------------------
; Four longs in units of 10,000 bytes (HDAE5000_HD_ComputeDiskUsage): +0 the
; drive (HdUsableSectors), +4 the system area (DataStartSector + 1
; sectors), +8 the data area (cluster bytes x FatEntryCount), +12 the free
; space (cluster bytes x FreeClusters).
; In:  XWA = destination.  XIZ preserved; clobbers XBC.
; ---------------------------------------------------------------------------
HDAE5000_HD_GetDiskUsage:
	push xiz
	call HDAE5000_HD_ComputeDiskUsage
	ld	xbc, (HDAE5000_RAM_HdUsageDrive)
	ld (xwa), xbc
	ld	xbc, (HDAE5000_RAM_HdUsageSystem)
	ld (xwa + 0x04), xbc
	ld	xbc, (HDAE5000_RAM_HdUsageData)
	ld (xwa + 0x08), xbc
	ld	xbc, (HDAE5000_RAM_HdUsageFree)
	ld (xwa + 0x0c), xbc
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Fill HDAE5000_RAM_HdUsageDrive, _HdUsageSystem, _HdUsageData and
; _HdUsageFree (units of 10,000 bytes) for HDAE5000_HD_GetDiskUsage.
; XWA, XBC preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_ComputeDiskUsage:
	push xwa
	push xbc
	ld	xwa, (HDAE5000_RAM_HdUsableSectors)
	ld	xbc, 0x00000200
	call HDAE5000_HD_Mul32
	ld	xbc, 0x00002710
	call HDAE5000_HD_UDiv32
	ld	(HDAE5000_RAM_HdUsageDrive), xwa
	ld	xwa, (HDAE5000_RAM_DataStartSector)
	dec	1, xwa
	add	xwa, 0x00000002
	ld	xbc, 0x00000200
	call HDAE5000_HD_Mul32
	ld	xbc, 0x00002710
	call HDAE5000_HD_UDiv32
	ld	(HDAE5000_RAM_HdUsageSystem), xwa
	ld	xwa, (HDAE5000_RAM_SectorsPerCluster)
	ld	xbc, 0x00000200
	call HDAE5000_HD_Mul32
	push xwa
	ld	xbc, (HDAE5000_RAM_FatEntryCount)
	call HDAE5000_HD_Mul32
	ld	xbc, 0x00002710
	call HDAE5000_HD_UDiv32
	ld	(HDAE5000_RAM_HdUsageData), xwa
	pop xwa
	ld	xbc, (HDAE5000_RAM_FreeClusters)
	call HDAE5000_HD_Mul32
	ld	xbc, 0x00002710
	call HDAE5000_HD_UDiv32
	ld	(HDAE5000_RAM_HdUsageFree), xwa
	pop xbc
	pop xwa
	ret
; ---------------------------------------------------------------------------
; Zero the ten bytes of HDAE5000_RAM_HdStatusBytes.  No reader of them was
; found (each address literal searched in all seven hdae5000 sources).
; Callers: HDAE5000_HD_Init, HDAE5000_HD_Format.
; ---------------------------------------------------------------------------
HDAE5000_HD_ClearStatusBytes:
	ld	(HDAE5000_RAM_HdStatusBytes:24), 0x00
	ld	(HDAE5000_RAM_HdStatusBytes+1:24), 0
	ld	(HDAE5000_RAM_HdStatusBytes+2:24), 0
	ld	(HDAE5000_RAM_HdStatusBytes+3:24), 0
	ld	(HDAE5000_RAM_HdStatusBytes+4:24), 0
	ld	(HDAE5000_RAM_HdStatusBytes+5:24), 0
	ld	(HDAE5000_RAM_HdStatusBytes+6:24), 0
	ld	(HDAE5000_RAM_HdStatusBytes+7:24), 0
	ld	(0x229db5:24), 0x00
	ld	(0x229db6:24), 0x00
	ret

; ---------------------------------------------------------------------------
; A = 1 when the 26-byte name buffer at 0x200C98 holds a non-space, else 0
; (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_NameBuf_IsNotBlank:
	push xbc
	push xix
	ld	a, 0x00:opc
	ld	xbc, 0:i3
	ld	xix, 0x00200c98
HDAE5000_NameBuf_IsNotBlank_Loop:
	cp	xbc, 0x0000001a
	jp	z, (.LNameBuf_IsNotBlank_Skip2:24)
	cp	(xix), 0x20
	jp	nz, (.LNameBuf_IsNotBlank_Skip1:24)
	inc 1, xbc
	inc 1, xix
	jp HDAE5000_NameBuf_IsNotBlank_Loop
.LNameBuf_IsNotBlank_Skip1:
	ld	a, 0x01:opc
.LNameBuf_IsNotBlank_Skip2:
	pop xix
	pop xbc
	ret

; ---------------------------------------------------------------------------
; Clusters needed for a byte count (HDAE5000_HD_BytesToClusters).
; In:  XWA = byte count
; Out: XHL = clusters.  XIZ preserved; clobbers XWA, XBC.
; ---------------------------------------------------------------------------
HDAE5000_HD_ClusterCount:
	push xiz
	call HDAE5000_HD_BytesToClusters
	ld	xhl, xwa
	pop xiz
	ret

; ---------------------------------------------------------------------------
; XWA = ceil(XWA / HDAE5000_RAM_ClusterBytes).  Clobbers XBC.
; ---------------------------------------------------------------------------
HDAE5000_HD_BytesToClusters:
	ld	xbc, (HDAE5000_RAM_ClusterBytes)
	call HDAE5000_HD_UDiv32
	cp	xbc, 0x00000000
	jp	z, (.LHD_BytesToClusters_Return1:24)
	inc 1, xwa
.LHD_BytesToClusters_Return1:
	ret

HDAE5000_HD_CheckVersionKey:
	; compares the long at HDAE5000_Version_Key ("XXXX") with RAM 0x229C60;
	; on a mismatch it pops one extra long and returns to its caller's
	; caller.  Not called directly: HDAE5000_HD_Init stores its address in
	; RAM 0x229D6C (`lda xwa,(...)` / `ld (0x229d6c),xwa`), and no read of
	; 0x229D6C was found in this ROM (searched the literal).
	push xwa
	push xbc
	push xix
	lda xix, (HDAE5000_Version_Key:24)
	ld xwa, (xix)
	ld	xbc, (HDAE5000_RAM_HdVersionKeyWord)
	cp	xwa, xbc
	jp	z, (.LHD_CheckVersionKey_Skip1:24)
	pop xix
	pop xbc
	pop xwa
	pop xwa
	ret

.LHD_CheckVersionKey_Skip1:
	pop xix
	pop xbc
	pop xwa
	ret

	xor	xwa, xwa
	xor	xbc, xbc
	ld	wa, (0x229C4E:24)
	dec	1, wa
	ld	xbc, 0x000004c0
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	ld	wa, (0x229C50:24)
	dec	1, wa
	ld	xbc, 0x0000004c
	call HDAE5000_HD_Mul32
	add	xix, xwa
	lda xwa, (HDAE5000_RAM_SongRecords:24)
	add	xix, xwa
	ld	(0x229cf0), xix
	ret

HDAE5000_DeadLib_FindFreeSlot32:
	lda xix, (0x201556:24)
	ld	bc, 0:i3
HDAE5000_DeadLib_FindFreeSlot32_Loop:
	cp	bc, 0x0020
	jp	z, (.LDeadLib_FindFreeSlot32_Done:24)
	ld xiy, (xix + 0x04)
	cp	xiy, 0x00000000
	jp	nz, (.LDeadLib_FindFreeSlot32_Skip:24)
	ld	xwa, xix
	jp HDAE5000_DeadLib_FindFreeSlot32_Return
.LDeadLib_FindFreeSlot32_Skip:
	add	xix, 0x00000008
	inc	1, bc
	jp HDAE5000_DeadLib_FindFreeSlot32_Loop
.LDeadLib_FindFreeSlot32_Done:
	ld	xwa, 0:i3
HDAE5000_DeadLib_FindFreeSlot32_Return:
	ret

HDAE5000_DeadLib_SelectNextFile:
	ld	(0x229dc6:24), 0
	call HDAE5000_DirBrowser_GetRowByte
	cp	a, 0x0f
	jp	c, (.LDeadLib_SelectNextFile_Skip:24)
	jp HDAE5000_DeadLib_SelectNextFile_NextDir
.LDeadLib_SelectNextFile_Skip:
	call HDAE5000_DirBrowser_IncRowByte
	jp HDAE5000_DeadLib_SelectNextFile_Return
HDAE5000_DeadLib_SelectNextFile_NextDir:
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	add	xwa, xix
	cp	xwa, 0x00000077
	jp	z, (HDAE5000_DeadLib_SelectNextFile_Return:24)
	call HDAE5000_DirBrowser_GetCursor
	cp	a, 0x17
	jp	c, (.LDeadLib_SelectNextFile_NextDir_Skip1:24)
	inc	1, (HDAE5000_RAM_DirBrowserPage:24)
	call HDAE5000_DirBrowser_ClearCursor
	call HDAE5000_DirBrowser_ClearRowByte
	jp HDAE5000_DeadLib_SelectNextFile_Return
.LDeadLib_SelectNextFile_NextDir_Skip1:
	call HDAE5000_DirBrowser_IncCursor
	call HDAE5000_DirBrowser_ClearRowByte
HDAE5000_DeadLib_SelectNextFile_Return:
	ret

HDAE5000_DeadLib_SelectNextFlsItem:
	ld	(0x229dc6:24), 0
	call HDAE5000_FlsBrowser_GetRowByte
	cp	a, 0x1f
	jp	c, (.LDeadLib_SelectNextFlsItem_Skip:24)
	jp HDAE5000_DeadLib_SelectNextFlsItem_NextRow
.LDeadLib_SelectNextFlsItem_Skip:
	call HDAE5000_FlsBrowser_IncRowByte
	jp HDAE5000_DeadLib_SelectNextFlsItem_Return
HDAE5000_DeadLib_SelectNextFlsItem_NextRow:
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_FlsBrowser_GetCursor
	add	xwa, xix
	cp	xwa, 0x00000077
	jp	z, (HDAE5000_DeadLib_SelectNextFlsItem_Return:24)
	call HDAE5000_FlsBrowser_GetCursor
	cp	a, 0x17
	jp	c, (.LDeadLib_SelectNextFlsItem_NextRow_Skip1:24)
	inc	1, (HDAE5000_RAM_FlsBrowserPage:24)
	call HDAE5000_FlsBrowser_ClearCursor
	call HDAE5000_FlsBrowser_ClearRowByte
	call HDAE5000_FlsBrowser_RowAddress
	ld	xbc, 0x00000010
	add	xwa, xbc
	ld	(0x229d7c), xwa
	jp HDAE5000_DeadLib_SelectNextFlsItem_Return
.LDeadLib_SelectNextFlsItem_NextRow_Skip1:
	call HDAE5000_FlsBrowser_IncCursor
	call HDAE5000_FlsBrowser_ClearRowByte
	call HDAE5000_FlsBrowser_RowAddress
	ld	xbc, 0x00000010
	add	xwa, xbc
	ld	(0x229d7c), xwa
HDAE5000_DeadLib_SelectNextFlsItem_Return:
	ret

HDAE5000_DeadLib_ClearRefsToEntry:
	lda xix, (HDAE5000_RAM_FlsRecords+16:24)
	ld	xiy, 0:i3
HDAE5000_DeadLib_ClearRefsToEntry_RowLoop:
	cp	xiy, 0x00000078
	jp	z, (.LDeadLib_ClearRefsToEntry_ItemLoop_Return1:24)
	ld	bc, 0:i3
HDAE5000_DeadLib_ClearRefsToEntry_ItemLoop:
	cp	bc, 0x0020
	jp	z, (.LDeadLib_ClearRefsToEntry_ItemLoop_Skip2:24)
	ld xwa, (xix + 0x04)
	cp	xwa, (0x229cf0)
	jp	nz, (.LDeadLib_ClearRefsToEntry_ItemLoop_Skip1:24)
	xor	xwa, xwa
	ld (xix), xwa
	ld (xix + 0x04), xwa
.LDeadLib_ClearRefsToEntry_ItemLoop_Skip1:
	add	xix, 0x00000002
	inc	1, bc
	jp HDAE5000_DeadLib_ClearRefsToEntry_ItemLoop
.LDeadLib_ClearRefsToEntry_ItemLoop_Skip2:
	add	xix, 0x00000010
	inc 1, xiy
	jp HDAE5000_DeadLib_ClearRefsToEntry_RowLoop
.LDeadLib_ClearRefsToEntry_ItemLoop_Return1:
	ret

HDAE5000_DeadLib_DeleteSlotShift:
	ld	xix, (HDAE5000_RAM_DataSectorCount)
	lda xiy, (0x20158e:24)
HDAE5000_DeadLib_DeleteSlotShift_Loop:
	cp	xix, xiy
	jp	z, (.LDeadLib_DeleteSlotShift_Skip:24)
	ld xwa, (xix + 0x08)
	ld (xix), xwa
	ld xwa, (xix + 0x0c)
	ld (xix + 0x04), xwa
	add	xix, 0x00000008
	jp HDAE5000_DeadLib_DeleteSlotShift_Loop
.LDeadLib_DeleteSlotShift_Skip:
	xor	xwa, xwa
	lda xix, (0x20158e:24)
	ld (xix), xwa
	ld (xix + 0x04), xwa
	ret

HDAE5000_DeadLib_FindNextUsedSlot:
	ld	xix, (0x229d84)
	add	xix, 0x00000002
	lda xiy, (0x201596:24)
	xor	xwa, xwa
	ld	(0x229d8c), xwa
HDAE5000_DeadLib_FindNextUsedSlot_Loop:
	cp	xix, xiy
	jp	z, (HDAE5000_DeadLib_FindNextUsedSlot_Return:24)
	ld xwa, (xix + 0x04)
	cp	xwa, 0x00000000
	jp	z, (.LDeadLib_FindNextUsedSlot_Skip:24)
	ld	(0x229d8c), xix
	jp HDAE5000_DeadLib_FindNextUsedSlot_Return
.LDeadLib_FindNextUsedSlot_Skip:
	add	xix, 0x00000002
	jp HDAE5000_DeadLib_FindNextUsedSlot_Loop
HDAE5000_DeadLib_FindNextUsedSlot_Return:
	ret

HDAE5000_DeadLib_FindLastFreeSlot:
	lda xix, (0x201596:24)
	sub	xix, 0x00000002
	ld	xiy, (0x229d84)
	xor	xwa, xwa
	ld	(0x229d88), xwa
HDAE5000_DeadLib_FindLastFreeSlot_Loop:
	cp	xix, xiy
	jp	z, (HDAE5000_DeadLib_FindLastFreeSlot_Return:24)
	ld xwa, (xix + 0x04)
	cp	xwa, 0x00000000
	jp	nz, (.LDeadLib_FindLastFreeSlot_Skip:24)
	ld	(0x229d88), xix
	jp HDAE5000_DeadLib_FindLastFreeSlot_Return
.LDeadLib_FindLastFreeSlot_Skip:
	sub	xix, 0x00000002
	jp HDAE5000_DeadLib_FindLastFreeSlot_Loop
HDAE5000_DeadLib_FindLastFreeSlot_Return:
	ret

HDAE5000_DeadLib_InsertSlotShift:
	ld	xix, (0x229d88)
	ld	xiy, (0x229d84)
HDAE5000_DeadLib_InsertSlotShift_Loop:
	cp	xix, xiy
	jp	z, (.LDeadLib_InsertSlotShift_Skip:24)
	ld	xwa, (xix-8)
	ld (xix), xwa
	ld	xwa, (xix-4)
	ld (xix + 0x04), xwa
	sub	xix, 0x00000002
	jp HDAE5000_DeadLib_InsertSlotShift_Loop
.LDeadLib_InsertSlotShift_Skip:
	xor	xwa, xwa
	ld	xix, (0x229d84)
	ld (xix), xwa
	ld (xix + 0x04), xwa
	ret

HDAE5000_DeadLib_LoadFileName:
	push xix
	push xiy
	push xbc
	push xwa
	ld	xbc, 0:i3
	ld	xix, (0x229cf0)
	lda xiy, (0x200c98:24)
HDAE5000_DeadLib_LoadFileName_Loop:
	cp	xbc, 0x0000001a
	jp	z, (.LDeadLib_LoadFileName_Epilogue:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_LoadFileName_Loop
.LDeadLib_LoadFileName_Epilogue:
	pop xwa
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_StoreFileName:
	push xix
	push xiy
	push xbc
	push xwa
	ld	xbc, 0:i3
	ld	xix, (0x229cf0)
	lda xiy, (0x200c98:24)
HDAE5000_DeadLib_StoreFileName_Loop:
	cp	xbc, 0x0000001a
	jp	z, (.LDeadLib_StoreFileName_Epilogue:24)
	ld	a, (xiy)
	ld	(xix), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_StoreFileName_Loop
.LDeadLib_StoreFileName_Epilogue:
	pop xwa
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_RememberFileName:
	push xix
	push xiy
	push xbc
	call HDAE5000_NameBuf_IsNotBlank
	cp	a, 0:i3
	jp	z, (.LDeadLib_RememberFileName_Copy_Skip2:24)
	lda xix, (0x201434:24)
	lda xiy, (0x200c98:24)
	call HDAE5000_NameList5_Contains
	cp	a, 1:i3
	jp	z, (.LDeadLib_RememberFileName_Copy_Skip2:24)
	cp	(0x229dc1:24), 5
	jp	c, (.LDeadLib_RememberFileName_Join:24)
	ld	(0x229dc1:24), 0
.LDeadLib_RememberFileName_Join:
	lda xix, (0x201434:24)
	xor	xwa, xwa
	ld	a, (0x229dc1:24)
	ld	xbc, 0x0000001a
	call HDAE5000_HD_Mul32
	add	xix, xwa
	lda xiy, (0x200c98:24)
	ld	xbc, 0:i3
HDAE5000_DeadLib_RememberFileName_Copy:
	cp	xbc, 0x0000001a
	jp	z, (.LDeadLib_RememberFileName_Copy_Skip1:24)
	ld	a, (xiy)
	ld	(xix), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_RememberFileName_Copy
.LDeadLib_RememberFileName_Copy_Skip1:
	inc	1, (0x229dc1:24)
.LDeadLib_RememberFileName_Copy_Skip2:
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_RememberEntryName:
	push xix
	push xiy
	push xbc
	lda xix, (0x201434:24)
	ld	xiy, (0x229cf0)
	call HDAE5000_NameList5_Contains
	cp	a, 1:i3
	jp	z, (.LDeadLib_RememberEntryName_Copy_Skip2:24)
	cp	(0x229dc1:24), 5
	jp	c, (.LDeadLib_RememberEntryName_Join:24)
	ld	(0x229dc1:24), 0
.LDeadLib_RememberEntryName_Join:
	lda xix, (0x201434:24)
	xor	xwa, xwa
	ld	a, (0x229dc1:24)
	ld	xbc, 0x0000001a
	call HDAE5000_HD_Mul32
	add	xix, xwa
	ld	xiy, (0x229cf0)
	ld	xbc, 0:i3
HDAE5000_DeadLib_RememberEntryName_Copy:
	cp	xbc, 0x0000001a
	jp	z, (.LDeadLib_RememberEntryName_Copy_Skip1:24)
	ld	a, (xiy)
	ld	(xix), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_RememberEntryName_Copy
.LDeadLib_RememberEntryName_Copy_Skip1:
	inc	1, (0x229dc1:24)
.LDeadLib_RememberEntryName_Copy_Skip2:
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_RecallRecentFileName:
	push xix
	push xiy
	push xbc
	cp	(0x229dc4:24), 5
	jp	c, (.LDeadLib_RecallRecentFileName_Join:24)
	ld	(0x229dc4:24), 0
.LDeadLib_RecallRecentFileName_Join:
	lda xix, (0x201434:24)
	xor	xwa, xwa
	ld	a, (0x229dc4:24)
	ld	xbc, 0x0000001a
	call HDAE5000_HD_Mul32
	add	xix, xwa
	push xix
	call HDAE5000_Name26_IsBlank
	pop xix
	cp	a, 1:i3
	jp	nz, (.LDeadLib_RecallRecentFileName_Skip:24)
	ld	(0x229dc4:24), 0
	jp HDAE5000_DeadLib_RecallRecentFileName_Exit
.LDeadLib_RecallRecentFileName_Skip:
	lda xiy, (0x200c98:24)
	ld	xbc, 0:i3
HDAE5000_DeadLib_RecallRecentFileName_Copy:
	cp	xbc, 0x0000001a
	jp	z, (.LDeadLib_RecallRecentFileName_Copy_Skip1:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_RecallRecentFileName_Copy
.LDeadLib_RecallRecentFileName_Copy_Skip1:
	inc	1, (0x229dc4:24)
HDAE5000_DeadLib_RecallRecentFileName_Exit:
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_CopyEntryNameOut:
	push xix
	push xiy
	push xbc
	push xwa
	ld	xbc, 0:i3
	ld	xix, (0x229cf0)
	lda xiy, (0x201618:24)
HDAE5000_DeadLib_CopyEntryNameOut_Loop:
	cp	xbc, 0x0000001a
	jp	z, (.LDeadLib_CopyEntryNameOut_Epilogue:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_CopyEntryNameOut_Loop
.LDeadLib_CopyEntryNameOut_Epilogue:
	pop xwa
	pop xbc
	pop xiy
	pop xix
	ret

	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetRowByte
	inc 1, xwa
	call HDAE5000_FormatDecimal12_ZeroFill
	ret

	push xbc
	push xix
	xor	xwa, xwa
	xor	xbc, xbc
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000180
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	ld	xbc, 0x00000010
	call HDAE5000_HD_Mul32
	add	xwa, xix
	ld	xbc, 0x0000004c
	call HDAE5000_HD_Mul32
	lda xix, (HDAE5000_RAM_SongRecords:24)
	add	xwa, xix
	ld	(0x229cf0), xwa
	pop xix
	pop xbc
	ret

	push xbc
	push xix
	xor	xwa, xwa
	xor	xbc, xbc
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000180
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	ld	xbc, 0x00000010
	call HDAE5000_HD_Mul32
	add	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetRowByte
	add	xwa, xix
	ld	xbc, 0x0000004c
	call HDAE5000_HD_Mul32
	lda xix, (HDAE5000_RAM_SongRecords:24)
	add	xwa, xix
	ld	(0x229cf0), xwa
	pop xix
	pop xbc
	ret

; ---------------------------------------------------------------------------
; A = HDAE5000_RAM_DirBrowserRowBytes[DirBrowserPage * 24 + the page's cursor]
; (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_DirBrowser_GetRowByte:
	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_DirBrowserRowBytes:24)
	add	xix, xwa
	ld	a, (xix)
	pop xbc
	pop xix
	ret

; ---------------------------------------------------------------------------
; DirBrowserRowBytes[page * 24 + cursor] += 1 (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_DirBrowser_IncRowByte:
	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_DirBrowserRowBytes:24)
	add	xix, xwa
	incm8	1, (xix)
	pop xbc
	pop xix
	ret

; ---------------------------------------------------------------------------
; DirBrowserRowBytes[page * 24 + cursor] -= 1 (unreachable): the twin of
; HDAE5000_DirBrowser_IncRowByte.
; ---------------------------------------------------------------------------
HDAE5000_DirBrowser_DecRowByte:
	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_DirBrowserRowBytes:24)
	add	xix, xwa
	decm8	1, (xix)
	pop xbc
	pop xix
	ret

; ---------------------------------------------------------------------------
; DirBrowserRowBytes[page * 24 + cursor] = 0 (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_DirBrowser_ClearRowByte:
	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_DirBrowserRowBytes:24)
	add	xix, xwa
	ld	(xix), 0x00
	ld	a, (xix)
	pop xbc
	pop xix
	ret

	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_DirBrowserRowBytes:24)
	add	xix, xwa
	ld	(xix), 0x0f
	ld	a, (xix)
	pop xbc
	pop xix
	ret

HDAE5000_DeadLib_LoadDirName:
	push xix
	push xiy
	push xbc
	push xwa
	xor	xwa, xwa
	xor	xbc, xbc
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000180
	call HDAE5000_HD_Mul32
	lda xix, (HDAE5000_RAM_DirNames:24)
	add	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	ld	xbc, 0x00000010
	call HDAE5000_HD_Mul32
	add	xix, xwa
	ld	(0x229cec), xix
	ld	xbc, 0:i3
	lda xiy, (0x200c98:24)
HDAE5000_DeadLib_LoadDirName_Loop:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_LoadDirName_Epilogue:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_LoadDirName_Loop
.LDeadLib_LoadDirName_Epilogue:
	pop xwa
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_StoreDirName:
	push xix
	push xiy
	push xbc
	lda xix, (0x200c98:24)
	ld	xiy, (0x229cec)
	ld	xbc, 0:i3
HDAE5000_DeadLib_StoreDirName_Loop:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_StoreDirName_Epilogue:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_StoreDirName_Loop
.LDeadLib_StoreDirName_Epilogue:
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_RememberDirName:
	push xix
	push xiy
	push xbc
	call HDAE5000_NameBuf_IsNotBlank
	cp	a, 0:i3
	jp	z, (.LDeadLib_RememberDirName_Copy_Skip2:24)
	lda xix, (0x2013b2:24)
	lda xiy, (0x200c98:24)
	call HDAE5000_NameList5_Contains
	cp	a, 1:i3
	jp	z, (.LDeadLib_RememberDirName_Copy_Skip2:24)
	cp	(0x229dc0:24), 5
	jp	c, (.LDeadLib_RememberDirName_Join:24)
	ld	(0x229dc0:24), 0
.LDeadLib_RememberDirName_Join:
	lda xix, (0x2013b2:24)
	xor	xwa, xwa
	ld	a, (0x229dc0:24)
	ld	xbc, 0x00000010
	call HDAE5000_HD_Mul32
	add	xix, xwa
	lda xiy, (0x200c98:24)
	ld	xbc, 0:i3
HDAE5000_DeadLib_RememberDirName_Copy:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_RememberDirName_Copy_Skip1:24)
	ld	a, (xiy)
	ld	(xix), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_RememberDirName_Copy
.LDeadLib_RememberDirName_Copy_Skip1:
	inc	1, (0x229dc0:24)
.LDeadLib_RememberDirName_Copy_Skip2:
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_RecallRecentDirName:
	push xix
	push xiy
	push xbc
	cp	(0x229dc3:24), 5
	jp	c, (.LDeadLib_RecallRecentDirName_Join:24)
	ld	(0x229dc3:24), 0
.LDeadLib_RecallRecentDirName_Join:
	lda xix, (0x2013b2:24)
	xor	xwa, xwa
	ld	a, (0x229dc3:24)
	ld	xbc, 0x00000010
	call HDAE5000_HD_Mul32
	add	xix, xwa
	push xix
	call HDAE5000_Name26_IsBlank
	pop xix
	cp	a, 1:i3
	jp	nz, (.LDeadLib_RecallRecentDirName_Skip:24)
	ld	(0x229dc3:24), 0
	jp HDAE5000_DeadLib_RecallRecentDirName_Exit
.LDeadLib_RecallRecentDirName_Skip:
	lda xiy, (0x200c98:24)
	ld	xbc, 0:i3
HDAE5000_DeadLib_RecallRecentDirName_Copy:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_RecallRecentDirName_Copy_Skip1:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_RecallRecentDirName_Copy
.LDeadLib_RecallRecentDirName_Copy_Skip1:
	inc	1, (0x229dc3:24)
HDAE5000_DeadLib_RecallRecentDirName_Exit:
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_CopyDirNameOut:
	push xix
	push xiy
	push xbc
	push xwa
	xor	xwa, xwa
	xor	xbc, xbc
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000180
	call HDAE5000_HD_Mul32
	lda xix, (HDAE5000_RAM_DirNames:24)
	add	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	ld	xbc, 0x00000010
	call HDAE5000_HD_Mul32
	add	xix, xwa
	ld	xbc, 0:i3
	lda xiy, (0x200870:24)
HDAE5000_DeadLib_CopyDirNameOut_Loop:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_CopyDirNameOut_Epilogue:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_CopyDirNameOut_Loop
.LDeadLib_CopyDirNameOut_Epilogue:
	pop xwa
	pop xbc
	pop xiy
	pop xix
	ret

	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	add	xwa, xix
	inc 1, xwa
	call HDAE5000_FormatDecimal12_ZeroFill
	ret

	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	inc 1, xwa
	pop xbc
	ret

	push xbc
	push xde
	xor	xwa, xwa
	xor	xbc, xbc
	xor	xde, xde
	ld	xde, HDAE5000_RAM_DirNames
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000180
	call HDAE5000_HD_Mul32
	add	xwa, xde
	pop xde
	pop xbc
	ret

; ---------------------------------------------------------------------------
; A = HDAE5000_RAM_DirBrowserCursors[DirBrowserPage] (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_DirBrowser_GetCursor:
	push xix
	lda xix, (HDAE5000_RAM_DirBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	add	xix, xwa
	ld	a, (xix)
	pop xix
	ret

; ---------------------------------------------------------------------------
; DirBrowserCursors[page] += 1; A = the new value (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_DirBrowser_IncCursor:
	push xix
	lda xix, (HDAE5000_RAM_DirBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	add	xix, xwa
	incm8	1, (xix)
	ld	a, (xix)
	pop xix
	ret

	push xix
	lda xix, (HDAE5000_RAM_DirBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	add	xix, xwa
	decm8	1, (xix)
	ld	a, (xix)
	pop xix
	ret

; ---------------------------------------------------------------------------
; DirBrowserCursors[page] = 0 (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_DirBrowser_ClearCursor:
	push xix
	lda xix, (HDAE5000_RAM_DirBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	add	xix, xwa
	ld	(xix), 0x00
	pop xix
	ret

	push xix
	lda xix, (HDAE5000_RAM_DirBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	add	xix, xwa
	ld	(xix), 0x17
	pop xix
	ret

	push xix
	push xwa
	lda xix, (HDAE5000_RAM_DirBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	add	xix, xwa
	pop xwa
	ld	(xix), a
	pop xix
	ret

HDAE5000_DeadLib_LoadFlsName:
	push xix
	push xiy
	push xbc
	push xwa
	xor	xwa, xwa
	xor	xbc, xbc
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000d80
	call HDAE5000_HD_Mul32
	lda xix, (HDAE5000_RAM_FlsRecords:24)
	add	xix, xwa
	xor	xwa, xwa
	call HDAE5000_FlsBrowser_GetCursor
	ld	xbc, 0x00000090
	call HDAE5000_HD_Mul32
	add	xix, xwa
	ld	(0x229cec), xix
	ld	xbc, 0:i3
	lda xiy, (0x200c98:24)
HDAE5000_DeadLib_LoadFlsName_Loop:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_LoadFlsName_Epilogue:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_LoadFlsName_Loop
.LDeadLib_LoadFlsName_Epilogue:
	pop xwa
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_StoreFlsName:
	push xix
	push xiy
	push xbc
	lda xix, (0x200c98:24)
	ld	xiy, (0x229cec)
	ld	xbc, 0:i3
HDAE5000_DeadLib_StoreFlsName_Loop:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_StoreFlsName_Epilogue:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_StoreFlsName_Loop
.LDeadLib_StoreFlsName_Epilogue:
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_RememberFlsName:
	push xix
	push xiy
	push xbc
	call HDAE5000_NameBuf_IsNotBlank
	cp	a, 0:i3
	jp	z, (.LDeadLib_RememberFlsName_Copy_Skip2:24)
	lda xix, (0x2014b6:24)
	lda xiy, (0x200c98:24)
	call HDAE5000_NameList5_Contains
	cp	a, 1:i3
	jp	z, (.LDeadLib_RememberFlsName_Copy_Skip2:24)
	cp	(0x229dc2:24), 5
	jp	c, (.LDeadLib_RememberFlsName_Join:24)
	ld	(0x229dc2:24), 0
.LDeadLib_RememberFlsName_Join:
	lda xix, (0x2014b6:24)
	xor	xwa, xwa
	ld	a, (0x229dc2:24)
	ld	xbc, 0x00000010
	call HDAE5000_HD_Mul32
	add	xix, xwa
	lda xiy, (0x200c98:24)
	ld	xbc, 0:i3
HDAE5000_DeadLib_RememberFlsName_Copy:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_RememberFlsName_Copy_Skip1:24)
	ld	a, (xiy)
	ld	(xix), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_RememberFlsName_Copy
.LDeadLib_RememberFlsName_Copy_Skip1:
	inc	1, (0x229dc2:24)
.LDeadLib_RememberFlsName_Copy_Skip2:
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_RecallRecentFlsName:
	push xix
	push xiy
	push xbc
	cp	(0x229dc5:24), 5
	jp	c, (.LDeadLib_RecallRecentFlsName_Join:24)
	ld	(0x229dc5:24), 0
.LDeadLib_RecallRecentFlsName_Join:
	lda xix, (0x2014b6:24)
	xor	xwa, xwa
	ld	a, (0x229dc5:24)
	ld	xbc, 0x00000010
	call HDAE5000_HD_Mul32
	add	xix, xwa
	push xix
	call HDAE5000_Name26_IsBlank
	pop xix
	cp	a, 1:i3
	jp	nz, (.LDeadLib_RecallRecentFlsName_Skip:24)
	ld	(0x229dc5:24), 0
	jp HDAE5000_DeadLib_RecallRecentFlsName_Exit
.LDeadLib_RecallRecentFlsName_Skip:
	lda xiy, (0x200c98:24)
	ld	xbc, 0:i3
HDAE5000_DeadLib_RecallRecentFlsName_Copy:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_RecallRecentFlsName_Copy_Skip1:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_RecallRecentFlsName_Copy
.LDeadLib_RecallRecentFlsName_Copy_Skip1:
	inc	1, (0x229dc5:24)
HDAE5000_DeadLib_RecallRecentFlsName_Exit:
	pop xbc
	pop xiy
	pop xix
	ret

HDAE5000_DeadLib_CopyFlsNameOut:
	push xix
	push xiy
	push xbc
	push xwa
	xor	xwa, xwa
	xor	xbc, xbc
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000d80
	call HDAE5000_HD_Mul32
	lda xix, (HDAE5000_RAM_FlsRecords:24)
	add	xix, xwa
	xor	xwa, xwa
	call HDAE5000_FlsBrowser_GetCursor
	ld	xbc, 0x00000090
	call HDAE5000_HD_Mul32
	add	xix, xwa
	ld	xbc, 0:i3
	lda xiy, (0x200870:24)
HDAE5000_DeadLib_CopyFlsNameOut_Loop:
	cp	xbc, 0x00000010
	jp	z, (.LDeadLib_CopyFlsNameOut_Epilogue:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xbc
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_DeadLib_CopyFlsNameOut_Loop
.LDeadLib_CopyFlsNameOut_Epilogue:
	pop xwa
	pop xbc
	pop xiy
	pop xix
	ret

; ---------------------------------------------------------------------------
; XWA = HDAE5000_RAM_FlsRecords + FlsBrowserPage * 0xD80 + cursor * 0x90, the
; current FLS row (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_FlsBrowser_RowAddress:
	push xbc
	push xde
	xor	xwa, xwa
	xor	xbc, xbc
	xor	xde, xde
	ld	xde, HDAE5000_RAM_FlsRecords
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000d80
	call HDAE5000_HD_Mul32
	add	xde, xwa
	xor	xwa, xwa
	call HDAE5000_FlsBrowser_GetCursor
	ld	xbc, 0x00000090
	call HDAE5000_HD_Mul32
	add	xwa, xde
	pop xde
	pop xbc
	ret

	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	inc 1, xwa
	pop xbc
	ret

	push xbc
	push xde
	xor	xwa, xwa
	xor	xbc, xbc
	xor	xde, xde
	ld	xde, HDAE5000_RAM_FlsRecords
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000d80
	call HDAE5000_HD_Mul32
	add	xwa, xde
	pop xde
	pop xbc
	ret

	xor	xwa, xwa
	xor	xbc, xbc
	ld	a, (HDAE5000_RAM_DirBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_DirBrowser_GetCursor
	add	xwa, xix
	ld	(0x229c54), wa
	ret

; ---------------------------------------------------------------------------
; A = HDAE5000_RAM_FlsBrowserCursors[FlsBrowserPage] (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_FlsBrowser_GetCursor:
	push xix
	lda xix, (HDAE5000_RAM_FlsBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	add	xix, xwa
	ld	a, (xix)
	pop xix
	ret

; ---------------------------------------------------------------------------
; A = HDAE5000_RAM_FlsBrowserRowBytes[page * 24 + cursor] (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_FlsBrowser_GetRowByte:
	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_FlsBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_FlsBrowserRowBytes:24)
	add	xix, xwa
	ld	a, (xix)
	pop xbc
	pop xix
	ret

; ---------------------------------------------------------------------------
; FlsBrowserCursors[page] += 1; A = the new value (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_FlsBrowser_IncCursor:
	push xix
	lda xix, (HDAE5000_RAM_FlsBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	add	xix, xwa
	incm8	1, (xix)
	ld	a, (xix)
	pop xix
	ret

	push xix
	lda xix, (HDAE5000_RAM_FlsBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	add	xix, xwa
	decm8	1, (xix)
	ld	a, (xix)
	pop xix
	ret

; ---------------------------------------------------------------------------
; FlsBrowserRowBytes[page * 24 + cursor] += 1 (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_FlsBrowser_IncRowByte:
	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_FlsBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_FlsBrowserRowBytes:24)
	add	xix, xwa
	incm8	1, (xix)
	pop xbc
	pop xix
	ret

	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_FlsBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_FlsBrowserRowBytes:24)
	add	xix, xwa
	decm8	1, (xix)
	pop xbc
	pop xix
	ret

; ---------------------------------------------------------------------------
; FlsBrowserCursors[page] = 0 (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_FlsBrowser_ClearCursor:
	push xix
	lda xix, (HDAE5000_RAM_FlsBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	add	xix, xwa
	ld	(xix), 0x00
	pop xix
	ret

	push xix
	lda xix, (HDAE5000_RAM_FlsBrowserCursors:24)
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	add	xix, xwa
	ld	(xix), 0x17
	pop xix
	ret

; ---------------------------------------------------------------------------
; FlsBrowserRowBytes[page * 24 + cursor] = 0 (unreachable).
; ---------------------------------------------------------------------------
HDAE5000_FlsBrowser_ClearRowByte:
	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_FlsBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_FlsBrowserRowBytes:24)
	add	xix, xwa
	ld	(xix), 0x00
	pop xbc
	pop xix
	ret

	push xix
	push xbc
	xor	xwa, xwa
	ld	a, (HDAE5000_RAM_FlsBrowserPage:24)
	ld	xbc, 0x00000018
	call HDAE5000_HD_Mul32
	ld	xix, xwa
	xor	xwa, xwa
	call HDAE5000_FlsBrowser_GetCursor
	add	xwa, xix
	lda xix, (HDAE5000_RAM_FlsBrowserRowBytes:24)
	add	xix, xwa
	ld	(xix), 0x1f
	pop xbc
	pop xix
	ret

HDAE5000_DeadLib_Copy64Out:
	call HDAE5000_FlsBrowser_RowAddress
	ld	xbc, 0x00000010
	add	xwa, xbc
	ld	xix, xwa
	ld	(0x229d80), xix
	lda xiy, (0x201556:24)
	ld	bc, 0:i3
HDAE5000_DeadLib_Copy64Out_Loop:
	cp	bc, 0x0040
	jp	z, (.LDeadLib_Copy64Out_Return:24)
	ld	a, (xix)
	ld	(xiy), a
	inc 1, xix
	inc 1, xiy
	inc	1, bc
	jp HDAE5000_DeadLib_Copy64Out_Loop
.LDeadLib_Copy64Out_Return:
	ret

HDAE5000_DeadLib_Copy64Back:
	ld	xix, (0x229d80)
	lda xiy, (0x201556:24)
	ld	bc, 0:i3
HDAE5000_DeadLib_Copy64Back_Loop:
	cp	bc, 0x0040
	jp	z, (.LDeadLib_Copy64Back_Return:24)
	ld	a, (xiy)
	ld	(xix), a
	inc 1, xix
	inc 1, xiy
	inc	1, bc
	jp HDAE5000_DeadLib_Copy64Back_Loop
.LDeadLib_Copy64Back_Return:
	ret

	ld	xix, (0x229d7c)
	xor	xwa, xwa
	xor	xbc, xbc
	call HDAE5000_FlsBrowser_GetRowByte
	ld	xbc, 2:i3
	call HDAE5000_HD_Mul32
	add	xwa, xix
	ret

; HDAE5000_DecimalDigits (0x2998D9, 11 bytes): "0123456789 ", the digit table
; of HDAE5000_FormatDecimal12_ZeroFill (0x298A8E), which divides by 10
; with HDAE5000_HD_UDiv32 and then indexes this string with each remainder
; (`lda xiy,(HDAE5000_DecimalDigits:24)` / `add xiy,xbc` / `ld a,(xiy)`).
; It used to be decoded as `ldw wa,0x3231 / ldw hl,0x3534 / ldw iz,0x3837 /
; push xbc` plus `ld w,0x3e`, whose 0x3E was really the first opcode of
; HDAE5000_HD_LoadSettings -- the misframe behind the branch symboliser's
; "mid-line" refusal of `call 0x2998e4` (a call into the middle of `ld w`).
HDAE5000_DecimalDigits:
	.ascii	"0123456789 "

; ---------------------------------------------------------------------------
; Read sector 1 into HDAE5000_RAM_HdSettingsSector and restore the six setting
; bytes it carries at +120 into QuickLoadMode .. LyricBackColor -- the
; mirror image of HDAE5000_HD_SaveSettings.  Only caller:
; HDAE5000_HD_RestoreSettings, itself unreachable.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_HD_LoadSettings:
	push	xiz
	ld	xhl, 1:i3
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	ld	xde, 0x00000200
	call HDAE5000_ATA_ReadSector
	lda xix, (HDAE5000_RAM_HdSettingsSector+120:24)
	ld a, (xix+)
	ld	(HDAE5000_RAM_QuickLoadMode:24), a
	ld a, (xix+)
	ld	(HDAE5000_RAM_LoadByNumberMode:24), a
	ld a, (xix+)
	ld	(HDAE5000_RAM_JumpAfterLoad:24), a
	ld	a, (xix)
	ld	(HDAE5000_RAM_LyricJump:24), a
	pop xiz
	ret

; ---------------------------------------------------------------------------
; Build and write the signature sector: in HDAE5000_RAM_HdSettingsSector,
; after HDAE5000_HD_ZeroSector, the longs 0xAA55AA55 and 0xF4F1F2F3 (what
; HDAE5000_HD_CheckSignature looks for), the 112-byte HDAE5000_Version_Info,
; the six setting bytes QuickLoadMode .. LyricBackColor at +120, a
; 0xFFFFFFFF long, then HDAE5000_ATA_WriteSector(1).
; ---------------------------------------------------------------------------
HDAE5000_HD_SaveSettings:
	push xiz
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	call HDAE5000_HD_ZeroSector
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	ld	xwa, 0xaa55aa55
	ld (xix), xwa
	inc 4, xix
	ld	xwa, 0xf4f1f2f3
	ld (xix), xwa
	inc 4, xix
	lda xiy, (HDAE5000_Version_Info:24)
	lda xiz, (HDAE5000_Version_Info_End:24)
HDAE5000_HD_SaveSettings_CopyLoop:
	cp	xiy, xiz
	jp	z, (.LHD_SaveSettings_CopyLoop_Skip1:24)
	ld	a, (xiy)
	ld	(xix), a
	inc 1, xix
	inc 1, xiy
	jp HDAE5000_HD_SaveSettings_CopyLoop
.LHD_SaveSettings_CopyLoop_Skip1:
	lda xix, (HDAE5000_RAM_HdSettingsSector+120:24)
	ld	a, (HDAE5000_RAM_QuickLoadMode:24)
	ld (xix+), a
	ld	a, (HDAE5000_RAM_LoadByNumberMode:24)
	ld (xix+), a
	ld	a, (HDAE5000_RAM_JumpAfterLoad:24)
	ld (xix+), a
	ld	a, (HDAE5000_RAM_LyricJump:24)
	ld (xix+), a
	ld	xwa, 0xffffffff
	ld (xix), xwa
	ld	xhl, 1:i3
	lda xix, (HDAE5000_RAM_HdSettingsSector:24)
	call HDAE5000_ATA_WriteSector
	pop xiz
	ret

	; The 148 lines this replaces (through the old `ld xde, 0x3e37b6bf`) were NOT code:
	; llvm-mc's disassembler happened to find a valid TLCS900 encoding in every one of these
	; 309 bytes, chained by internal .LDSR_9a18/25/46/49/ab8 jr/jrl targets that referenced
	; nothing outside this span -- a self-contained illusion of code. The bytes are the
	; firmware's own version-info block plus a charset/reference-digit table, confirmed
	; directly against original_ROMs/hd-ae5000_v2_06i.ic4 at 0x2999B2-0x299AE6 (309 bytes).
	; Real code resumes at 0x299AE7; the old fake `ld xde,...` opcode byte (0x42, the 'B' of
	; "CVNB" here) had swallowed the first real instruction's bytes with it, so the true next
	; two instructions are given explicitly below and match ROM bytes 0x299AE7-0x299AEA.
; HDAE5000_Version_Info (0x2999B2, 112 bytes): four space-padded fields --
; author (40), version "2.33J" (24), "2.21" (24), "TECHNICS KN5000" (24).
; READERS: HDAE5000_HD_SaveSettings copies exactly these 112 bytes
; (HDAE5000_Version_Info .. HDAE5000_Version_Info_End) into the signature
; sector; the routine at 0x2988CF copies the same range.
HDAE5000_Version_Info:
	.ascii "Technics Software section    M. Kitajima"
	.ascii "2.33J                   "
	.ascii "2.21                    "
	.ascii "TECHNICS KN5000         "
HDAE5000_Version_Info_End:
	.ascii "                        "
	.ascii "Juli-Oktober 1996"
; HDAE5000_Version_Key (0x299A4B): the long "XXXX" that
; HDAE5000_HD_CheckVersionKey (0x298C9D) and the identical unlabelled copy
; at 0x297551 compare with RAM 0x229C60.
HDAE5000_Version_Key:
	.ascii "XXXXXXXX"
	.byte 0x1b, 0x1c, 0x1f                ; non-ASCII control bytes inside the confirmed-data version/reference-digit block documented above (0x2999B2-0x299AE6) -- not code, individual meaning not determined
	.ascii "\"VE \""
	.ascii "E12345678910111213141516171819202122232425ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvw #.-,;:_portuoirutoiurtUPOTRUJRNGERIUT7457890CVNB"
;
; HDAE5000_DoPrintf -- the C library's formatted-output engine (_doprnt shape)
;   in:  (xsp+4) const char *fmt, (xsp+8) va_list *ap, (xsp+0xC) void (*putc)(int)
;   out: HL = number of characters emitted
; Walks fmt; every byte that is not '%' (0x25, first compare below) is passed to
; the putc callback (`ld xwa,(xsp+0x5c) / call (xwa)` = the third argument once
; the 74-byte frame and a pushed word are allowed for).  After '%' it parses
; flags/width/precision and dispatches: integers through
; HDAE5000_Int_To_Decimal_String / _UInt_ / _Hex_ / _Octal_, doubles through
; HDAE5000_FormatFloat (8-byte va_arg fetched by HDAE5000_Copy8, or 10 bytes by
; HDAE5000_Copy10 when flag bit 7 is set).
; Callers: HDAE5000_SPrintf and HDAE5000_VSPrintf, which pass
; HDAE5000_SPrintf_PutChar as putc.  It was named PPI_Block_Copy_Helper, after
; nothing in its code: it touches no PPI port.
HDAE5000_DoPrintf:
	lda xsp, (xsp - 74)
	push xiz
	ldw (xsp + 0x04), 0
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Loop:
	cp	iz, 0x0025
	jr	z, HDAE5000_DoPrintf_Skip
	pushw iz
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
	incw	1, (xsp+4)
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Skip:
	ldw (xsp + 0x08), 0
	ldw (xsp + 0x0a), 0
	ldw (xsp + 0x06), 0
	ldw	(HDAE5000_RAM_PrintfPadChar:24), 32
HDAE5000_DoPrintf_Loop2:
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
	ld	wa, iz
	cp	iz, 0x0030
	jr	z, HDAE5000_DoPrintf_Skip6
	cp	wa, 0x002d
	jr	z, HDAE5000_DoPrintf_Skip5
	cp	wa, 0x002b
	jr	z, HDAE5000_DoPrintf_Skip4
	cp	wa, 0x0023
	jr	z, HDAE5000_DoPrintf_Skip3
	cp	wa, 0x0020
	jr	z, HDAE5000_DoPrintf_Skip2
	cp	iz, 0x002a
	jr	nz, HDAE5000_DoPrintf_Next
	ld xbc, (xsp + 0x56)
	ld	xwa, 2:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	wa, (xwa-2)
	ld (xsp + 0x08), wa
	cpw	(xsp+8), 0x0000
	jr	ge, HDAE5000_DoPrintf_Join
	ld	wa, (xsp+8)
	neg	wa
	ld (xsp + 0x08), wa
	setm	1, (xsp+6)
HDAE5000_DoPrintf_Join:
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
	jr	t, HDAE5000_DoPrintf_Join2
HDAE5000_DoPrintf_Skip2:
	setm	2, (xsp+6)
	jr	t, HDAE5000_DoPrintf_Loop2
HDAE5000_DoPrintf_Skip3:
	setm	3, (xsp+6)
	jr	t, HDAE5000_DoPrintf_Loop2
HDAE5000_DoPrintf_Skip4:
	setm	0, (xsp+6)
	jr	t, HDAE5000_DoPrintf_Loop2
HDAE5000_DoPrintf_Skip5:
	setm	1, (xsp+6)
	jr	t, HDAE5000_DoPrintf_Loop2
HDAE5000_DoPrintf_Skip6:
	ldw	(HDAE5000_RAM_PrintfPadChar:24), 48
	jrl	t, HDAE5000_DoPrintf_Loop2
HDAE5000_DoPrintf_Loop3:
	ld	bc, iz
	sub	bc, 0x0030
	ld	wa, (xsp+8)
	muls	wa, 0x000a
	ld (xsp + 0x08), wa
	add	(xsp+8), bc
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
HDAE5000_DoPrintf_Next:
	ldto_berp a, 0xf8		; ld A,IZL
	extz wa
	lda xbc, (HDAE5000_CType_Table:24)
	bit	2, (xbc+wa)
	jr	nz, HDAE5000_DoPrintf_Loop3
HDAE5000_DoPrintf_Join2:
	cp	iz, 0x002e
	jr	nz, HDAE5000_DoPrintf_Join4
	setm	4, (xsp+6)
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
	cp	iz, 0x002a
	jr	nz, HDAE5000_DoPrintf_Next2
	ld xbc, (xsp + 0x56)
	ld	xwa, 2:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	wa, (xwa-2)
	ld (xsp + 0x0a), wa
	cpw	(xsp+10), 0x0000
	jr	ge, HDAE5000_DoPrintf_Join3
	resm	4, (xsp+6)
HDAE5000_DoPrintf_Join3:
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
	jr	t, HDAE5000_DoPrintf_Join4
HDAE5000_DoPrintf_Loop4:
	ld	bc, iz
	sub	bc, 0x0030
	ld	wa, (xsp+10)
	muls	wa, 0x000a
	ld (xsp + 0x0a), wa
	add	(xsp+10), bc
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
HDAE5000_DoPrintf_Next2:
	ldto_berp a, 0xf8		; ld A,IZL
	extz wa
	lda xbc, (HDAE5000_CType_Table:24)
	bit	2, (xbc+wa)
	jr	nz, HDAE5000_DoPrintf_Loop4
HDAE5000_DoPrintf_Join4:
	cp	iz, 0x0068
	jr	nz, HDAE5000_DoPrintf_Skip7
	setm	5, (xsp+6)
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
	jr	t, HDAE5000_DoPrintf_Join5
HDAE5000_DoPrintf_Skip7:
	cp	iz, 0x006c
	jr	nz, HDAE5000_DoPrintf_Skip8
	setm	6, (xsp+6)
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
	jr	t, HDAE5000_DoPrintf_Join5
HDAE5000_DoPrintf_Skip8:
	cp	iz, 0x004c
	jr	nz, HDAE5000_DoPrintf_Join5
	setm	7, (xsp+6)
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
HDAE5000_DoPrintf_Join5:
	ld	wa, iz
	cp	iz, 0x0047
	jrl	z, HDAE5000_DoPrintf_Case_Float
	cp	wa, 0x0045
	jrl	z, HDAE5000_DoPrintf_Case_Float
	cp	wa, 0x0058
	jrl	z, HDAE5000_DoPrintf_Case_Hex
	cp	wa, 0x0025
	jr	z, HDAE5000_DoPrintf_Case_Char
	sub	wa, 0x0063
	cp	wa, 0:i3
	jrl	lt, HDAE5000_DoPrintf_NextChar
	cp	wa, 0x0015
	jrl	gt, HDAE5000_DoPrintf_NextChar
	add	wa, wa
	lda xix, (HDAE5000_DoPrintf_ConvTable:24)
	ld	wa, (xix+wa)
	lda xix, (HDAE5000_DoPrintf_Case_Char:24)
	jp	t, (xix+wa)
HDAE5000_DoPrintf_Case_Char:
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	z, HDAE5000_DoPrintf_Case_Char_Next
	jr	t, HDAE5000_DoPrintf_Case_Char_Join
HDAE5000_DoPrintf_Case_Char_Loop:
	incw	1, (xsp+4)
	pushw	(HDAE5000_RAM_PrintfPadChar:24)
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Char_Next:
	decm	1, (xsp+8)
	cpw	(xsp+8), 0x0000
	jr	gt, HDAE5000_DoPrintf_Case_Char_Loop
HDAE5000_DoPrintf_Case_Char_Join:
	incw	1, (xsp+4)
	cp	iz, 0x0063
	jr	nz, HDAE5000_DoPrintf_Case_Char_Skip
	ld xbc, (xsp + 0x56)
	ld	xwa, 2:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	pushm	(xwa-2)
	jr	t, HDAE5000_DoPrintf_Case_Char_Join2
HDAE5000_DoPrintf_Case_Char_Skip:
	pushw 0x0025
HDAE5000_DoPrintf_Case_Char_Join2:
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Char_Next2
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Char_Loop2:
	incw	1, (xsp+4)
	pushw 0x0020
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Char_Next2:
	decm	1, (xsp+8)
	cpw	(xsp+8), 0x0000
	jr	gt, HDAE5000_DoPrintf_Case_Char_Loop2
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_String:
	ld xbc, (xsp + 0x56)
	ld	xwa, 4:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	xwa, (xwa-4)
	ld (xsp + 0x10), xwa
	push xwa
	call HDAE5000_StrLen
	inc 4, xsp
	ld	wa, (xsp+6)
	bit	0x04, wa
	jr	z, HDAE5000_DoPrintf_Case_String_Join
	cp	(xsp+10), hl
	jr	lt, HDAE5000_DoPrintf_Case_String_Skip
HDAE5000_DoPrintf_Case_String_Join:
	ld (xsp + 0x0a), hl
	jr	t, HDAE5000_DoPrintf_Case_String_Join2
HDAE5000_DoPrintf_Case_String_Skip:
	ld	hl, (xsp+10)
HDAE5000_DoPrintf_Case_String_Join2:
	cp	hl, (xsp+8)
	jr	le, HDAE5000_DoPrintf_Case_String_Skip2
	ldw (xsp + 0x08), 0
	add	(xsp+4), hl
	jr	t, HDAE5000_DoPrintf_Case_String_Join3
HDAE5000_DoPrintf_Case_String_Skip2:
	ld	wa, (xsp+8)
	add	(xsp+4), wa
	sub	(xsp+8), hl
HDAE5000_DoPrintf_Case_String_Join3:
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	z, HDAE5000_DoPrintf_Case_String_Next
	jr	t, HDAE5000_DoPrintf_Case_String_Next2
HDAE5000_DoPrintf_Case_String_Loop:
	pushw	(HDAE5000_RAM_PrintfPadChar:24)
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_String_Next:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_String_Loop
	jr	t, HDAE5000_DoPrintf_Case_String_Next2
HDAE5000_DoPrintf_Case_String_Loop2:
	ld xwa, (xsp + 0x10)
	ld c, (xwa+)
	ld (xsp + 0x10), xwa
	exts bc
	pushw bc
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_String_Next2:
	ld	wa, (xsp+10)
	decm	1, (xsp+10)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_String_Loop2
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_String_Next3
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_String_Loop3:
	pushw 0x0020
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_String_Next3:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_String_Loop3
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Int:
	ld	wa, (xsp+6)
	bit	0x06, wa
	jr	z, HDAE5000_DoPrintf_Case_Int_Skip
	ld xbc, (xsp + 0x56)
	ld	xwa, 4:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	xwa, (xwa-4)
	ld (xsp + 0x10), xwa
	jr	t, HDAE5000_DoPrintf_Case_Int_Join
HDAE5000_DoPrintf_Case_Int_Skip:
	ld xbc, (xsp + 0x56)
	ld	xwa, 2:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	wa, (xwa-2)
	exts xwa
	ld (xsp + 0x10), xwa
HDAE5000_DoPrintf_Case_Int_Join:
	ldw (xsp + 0x0e), 0
	lda	xbc, (xsp+56)
	ld	wa, (xsp+6)
	bit	0x04, wa
	jr	z, HDAE5000_DoPrintf_Case_Int_Skip2
	cpw	(xsp+10), 0x0000
	jr	nz, HDAE5000_DoPrintf_Case_Int_Skip2
	ld xwa, (xsp + 0x10)
	or xwa, xwa
	jr	nz, HDAE5000_DoPrintf_Case_Int_Skip2
	ld	(xbc), 0x00
	ldw (xsp + 0x0c), 0
	jr	t, HDAE5000_DoPrintf_Case_Int_Join2
HDAE5000_DoPrintf_Case_Int_Skip2:
	ld xwa, (xsp + 0x10)
	push xwa
	push xbc
	calr	HDAE5000_Int_To_Decimal_String
	lda	xwa, (xsp+64)
	push xwa
	call HDAE5000_StrLen
	lda	xsp, (xsp+12)
	ld (xsp + 0x0c), hl
	ld xwa, (xsp + 0x10)
	cp	xwa, 0x00000000
	jr	ge, HDAE5000_DoPrintf_Case_Int_Join2
	ldw (xsp + 0x0e), 1
HDAE5000_DoPrintf_Case_Int_Join2:
	ld	wa, (xsp+6)
	bit	0x04, wa
	jr	z, HDAE5000_DoPrintf_Case_Int_Join3
	ld	wa, (xsp+10)
	cp	wa, (xsp+12)
	jr	ge, HDAE5000_DoPrintf_Case_Int_Skip3
HDAE5000_DoPrintf_Case_Int_Join3:
	ldw (xsp + 0x0a), 0
	jr	t, HDAE5000_DoPrintf_Case_Int_Join4
HDAE5000_DoPrintf_Case_Int_Skip3:
	ld	wa, (xsp+12)
	sub	(xsp+10), wa
HDAE5000_DoPrintf_Case_Int_Join4:
	ld	wa, (xsp+6)
	and	wa, 0x0005
	jr	z, HDAE5000_DoPrintf_Case_Int_Join5
	ldw (xsp + 0x0e), 1
HDAE5000_DoPrintf_Case_Int_Join5:
	ld	wa, (xsp+12)
	add	wa, (xsp+10)
	add	wa, (xsp+14)
	sub	(xsp+8), wa
	jr	ge, HDAE5000_DoPrintf_Case_Int_Join6
	ldw (xsp + 0x08), 0
HDAE5000_DoPrintf_Case_Int_Join6:
	ld	wa, (xsp+8)
	add	wa, (xsp+12)
	add	wa, (xsp+10)
	add	wa, (xsp+14)
	add	(xsp+4), wa
	cpw	(xsp+8), 0x0000
	jr	z, HDAE5000_DoPrintf_Case_Int_Join7
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Int_Join7
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 32
	jr	z, HDAE5000_DoPrintf_Case_Int_Next
	bit	0x04, wa
	jr	nz, HDAE5000_DoPrintf_Case_Int_Next
	jr	t, HDAE5000_DoPrintf_Case_Int_Join7
HDAE5000_DoPrintf_Case_Int_Loop:
	pushw 0x0020
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Int_Next:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Int_Loop
	ldw (xsp + 0x08), 0
HDAE5000_DoPrintf_Case_Int_Join7:
	ld xwa, (xsp + 0x10)
	cp	xwa, 0x00000000
	jr	ge, HDAE5000_DoPrintf_Case_Int_Skip4
	pushw 0x002d
	jr	t, HDAE5000_DoPrintf_Case_Int_Join8
HDAE5000_DoPrintf_Case_Int_Skip4:
	ld	wa, (xsp+6)
	bit	0x00, wa
	jr	z, HDAE5000_DoPrintf_Case_Int_Skip5
	pushw 0x002b
	jr	t, HDAE5000_DoPrintf_Case_Int_Join8
HDAE5000_DoPrintf_Case_Int_Skip5:
	ld	wa, (xsp+6)
	bit	0x02, wa
	jr	z, HDAE5000_DoPrintf_Case_Int_Join9
	pushw 0x0020
HDAE5000_DoPrintf_Case_Int_Join8:
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Int_Join9:
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Int_Next3
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 48
	jr	z, HDAE5000_DoPrintf_Case_Int_Next2
	jr	t, HDAE5000_DoPrintf_Case_Int_Next3
HDAE5000_DoPrintf_Case_Int_Loop2:
	pushw 0x0030
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Int_Next2:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Int_Loop2
	jr	t, HDAE5000_DoPrintf_Case_Int_Next3
HDAE5000_DoPrintf_Case_Int_Loop3:
	pushw 0x0030
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Int_Next3:
	ld	wa, (xsp+10)
	decm	1, (xsp+10)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Int_Loop3
	jr	t, HDAE5000_DoPrintf_Case_Int_Next4
HDAE5000_DoPrintf_Case_Int_Loop4:
	decm	1, (xsp+12)
	lda	xbc, (xsp+56)
	ld	wa, (xsp+12)
	ld	a, (xbc+wa)
	exts wa
	pushw wa
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Int_Next4:
	cpw	(xsp+12), 0x0000
	jr	nz, HDAE5000_DoPrintf_Case_Int_Loop4
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Int_Next5
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Int_Loop5:
	pushw 0x0020
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Int_Next5:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Int_Loop5
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Unsigned:
	ld	wa, (xsp+6)
	bit	0x06, wa
	jr	z, HDAE5000_DoPrintf_Case_Unsigned_Skip
	ld xbc, (xsp + 0x56)
	ld	xwa, 4:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	xde, (xwa-4)
	jr	t, HDAE5000_DoPrintf_Case_Unsigned_Join
HDAE5000_DoPrintf_Case_Unsigned_Skip:
	ld xbc, (xsp + 0x56)
	ld	xwa, 2:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	de, (xwa-2)
	extz xde
HDAE5000_DoPrintf_Case_Unsigned_Join:
	lda	xbc, (xsp+44)
	ld	wa, (xsp+6)
	bit	0x04, wa
	jr	z, HDAE5000_DoPrintf_Case_Unsigned_Skip2
	cpw	(xsp+10), 0x0000
	jr	nz, HDAE5000_DoPrintf_Case_Unsigned_Skip2
	or xde, xde
	jr	nz, HDAE5000_DoPrintf_Case_Unsigned_Skip2
	ld	(xbc), 0x00
	ld	iz, 0:i3
	jr	t, HDAE5000_DoPrintf_Case_Unsigned_Join2
HDAE5000_DoPrintf_Case_Unsigned_Skip2:
	push xde
	push xbc
	calr	HDAE5000_UInt_To_Decimal_String
	lda	xwa, (xsp+52)
	push xwa
	call HDAE5000_StrLen
	lda	xsp, (xsp+12)
	ld	iz, hl
HDAE5000_DoPrintf_Case_Unsigned_Join2:
	ld	wa, (xsp+6)
	bit	0x04, wa
	jr	z, HDAE5000_DoPrintf_Case_Unsigned_Join3
	cp	(xsp+10), iz
	jr	ge, HDAE5000_DoPrintf_Case_Unsigned_Skip3
HDAE5000_DoPrintf_Case_Unsigned_Join3:
	ldw (xsp + 0x0a), 0
	jr	t, HDAE5000_DoPrintf_Case_Unsigned_Join4
HDAE5000_DoPrintf_Case_Unsigned_Skip3:
	sub	(xsp+10), iz
HDAE5000_DoPrintf_Case_Unsigned_Join4:
	ld	wa, iz
	add	wa, (xsp+10)
	sub	(xsp+8), wa
	jr	ge, HDAE5000_DoPrintf_Case_Unsigned_Join5
	ldw (xsp + 0x08), 0
HDAE5000_DoPrintf_Case_Unsigned_Join5:
	ld	wa, (xsp+8)
	add	wa, iz
	add	wa, (xsp+10)
	add	(xsp+4), wa
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	z, HDAE5000_DoPrintf_Case_Unsigned_Next
	jr	t, HDAE5000_DoPrintf_Case_Unsigned_Next2
HDAE5000_DoPrintf_Case_Unsigned_Loop:
	pushw	(HDAE5000_RAM_PrintfPadChar:24)
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Unsigned_Next:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Unsigned_Loop
	jr	t, HDAE5000_DoPrintf_Case_Unsigned_Next2
HDAE5000_DoPrintf_Case_Unsigned_Loop2:
	pushw 0x0030
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Unsigned_Next2:
	ld	wa, (xsp+10)
	decm	1, (xsp+10)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Unsigned_Loop2
	jr	t, HDAE5000_DoPrintf_Case_Unsigned_Next3
HDAE5000_DoPrintf_Case_Unsigned_Loop3:
	dec	1, iz
	lda	xwa, (xsp+44)
	ld	a, (xwa+iz)
	exts wa
	pushw wa
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Unsigned_Next3:
	cp	iz, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Unsigned_Loop3
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Unsigned_Next4
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Unsigned_Loop4:
	pushw 0x0020
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Unsigned_Next4:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Unsigned_Loop4
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Pointer:
	setm	6, (xsp+6)
HDAE5000_DoPrintf_Case_Hex:
	ld	wa, (xsp+6)
	bit	0x06, wa
	jr	z, HDAE5000_DoPrintf_Case_Hex_Skip
	ld xbc, (xsp + 0x56)
	ld	xwa, 4:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	xde, (xwa-4)
	jr	t, HDAE5000_DoPrintf_Case_Hex_Join
HDAE5000_DoPrintf_Case_Hex_Skip:
	ld xbc, (xsp + 0x56)
	ld	xwa, 2:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	de, (xwa-2)
	extz xde
HDAE5000_DoPrintf_Case_Hex_Join:
	lda	xbc, (xsp+32)
	ld	wa, (xsp+6)
	bit	0x04, wa
	jr	z, HDAE5000_DoPrintf_Case_Hex_Skip2
	cpw	(xsp+10), 0x0000
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Skip2
	or xde, xde
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Skip2
	ld	(xbc), 0x00
	ldw (xsp + 0x12), 0
	jr	t, HDAE5000_DoPrintf_Case_Hex_Join2
HDAE5000_DoPrintf_Case_Hex_Skip2:
	pushw iz
	push xde
	push xbc
	calr	HDAE5000_Int_To_Hex_String
	lda	xwa, (xsp+42)
	push xwa
	call HDAE5000_StrLen
	lda	xsp, (xsp+14)
	ld (xsp + 0x12), hl
HDAE5000_DoPrintf_Case_Hex_Join2:
	ld	wa, (xsp+6)
	bit	0x04, wa
	jr	z, HDAE5000_DoPrintf_Case_Hex_Join3
	ld	wa, (xsp+10)
	cp	wa, (xsp+18)
	jr	ge, HDAE5000_DoPrintf_Case_Hex_Skip3
HDAE5000_DoPrintf_Case_Hex_Join3:
	ldw (xsp + 0x0a), 0
	jr	t, HDAE5000_DoPrintf_Case_Hex_Join4
HDAE5000_DoPrintf_Case_Hex_Skip3:
	ld	wa, (xsp+18)
	sub	(xsp+10), wa
HDAE5000_DoPrintf_Case_Hex_Join4:
	ld	qiz, 0
	ld	wa, (xsp+6)
	bit	0x03, wa
	jr	z, HDAE5000_DoPrintf_Case_Hex_Join5
	ld	qiz, 2
HDAE5000_DoPrintf_Case_Hex_Join5:
	ld	wa, (xsp+18)
	add	wa, (xsp+10)
	add	wa, qiz
	sub	(xsp+8), wa
	jr	ge, HDAE5000_DoPrintf_Case_Hex_Join6
	ldw (xsp + 0x08), 0
HDAE5000_DoPrintf_Case_Hex_Join6:
	ld	wa, (xsp+8)
	add	wa, (xsp+18)
	add	wa, (xsp+10)
	add	wa, qiz
	add	(xsp+4), wa
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Join7
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 32
	jr	z, HDAE5000_DoPrintf_Case_Hex_Next
	jr	t, HDAE5000_DoPrintf_Case_Hex_Join7
HDAE5000_DoPrintf_Case_Hex_Loop:
	pushw 0x0020
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Hex_Next:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Loop
HDAE5000_DoPrintf_Case_Hex_Join7:
	cp	qiz, 0
	jr	z, HDAE5000_DoPrintf_Case_Hex_Join8
	cpw	(xsp+18), 0x0000
	jr	z, HDAE5000_DoPrintf_Case_Hex_Join8
	pushw 0x0030
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	pushw iz
	ld xwa, (xsp + 0x5e)
	call	(xwa)
	inc 4, xsp
HDAE5000_DoPrintf_Case_Hex_Join8:
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Next3
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 48
	jr	z, HDAE5000_DoPrintf_Case_Hex_Next2
	jr	t, HDAE5000_DoPrintf_Case_Hex_Next3
HDAE5000_DoPrintf_Case_Hex_Loop2:
	pushw 0x0030
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Hex_Next2:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Loop2
	jr	t, HDAE5000_DoPrintf_Case_Hex_Next3
HDAE5000_DoPrintf_Case_Hex_Loop3:
	pushw 0x0030
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Hex_Next3:
	ld	wa, (xsp+10)
	decm	1, (xsp+10)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Loop3
	jr	t, HDAE5000_DoPrintf_Case_Hex_Next4
HDAE5000_DoPrintf_Case_Hex_Loop4:
	decm	1, (xsp+18)
	lda	xbc, (xsp+32)
	ld	wa, (xsp+18)
	ld	a, (xbc+wa)
	exts wa
	pushw wa
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Hex_Next4:
	cpw	(xsp+18), 0x0000
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Loop4
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Next5
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Hex_Loop5:
	pushw 0x0020
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Hex_Next5:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Hex_Loop5
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Octal:
	ld	wa, (xsp+6)
	bit	0x06, wa
	jr	z, HDAE5000_DoPrintf_Case_Octal_Skip
	ld xbc, (xsp + 0x56)
	ld	xwa, 4:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	xde, (xwa-4)
	jr	t, HDAE5000_DoPrintf_Case_Octal_Join
HDAE5000_DoPrintf_Case_Octal_Skip:
	ld xbc, (xsp + 0x56)
	ld	xwa, 2:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	de, (xwa-2)
	extz xde
HDAE5000_DoPrintf_Case_Octal_Join:
	lda	xbc, (xsp+20)
	ld	wa, (xsp+6)
	bit	0x04, wa
	jr	z, HDAE5000_DoPrintf_Case_Octal_Skip2
	cpw	(xsp+10), 0x0000
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Skip2
	or xde, xde
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Skip2
	ld	(xbc), 0x00
	ld	iz, 0:i3
	jr	t, HDAE5000_DoPrintf_Case_Octal_Join2
HDAE5000_DoPrintf_Case_Octal_Skip2:
	push xde
	push xbc
	calr	HDAE5000_Int_To_Octal_String
	lda	xwa, (xsp+28)
	push xwa
	call HDAE5000_StrLen
	lda	xsp, (xsp+12)
	ld	iz, hl
HDAE5000_DoPrintf_Case_Octal_Join2:
	ld	wa, (xsp+6)
	bit	0x04, wa
	jr	z, HDAE5000_DoPrintf_Case_Octal_Join3
	cp	(xsp+10), iz
	jr	ge, HDAE5000_DoPrintf_Case_Octal_Skip3
HDAE5000_DoPrintf_Case_Octal_Join3:
	ldw (xsp + 0x0a), 0
	jr	t, HDAE5000_DoPrintf_Case_Octal_Join4
HDAE5000_DoPrintf_Case_Octal_Skip3:
	sub	(xsp+10), iz
HDAE5000_DoPrintf_Case_Octal_Join4:
	ld	wa, (xsp+6)
	and	wa, 0x0008
	cp	wa, 0:i3
	scc16	nz, wa
	ld (xsp + 0x12), wa
	ld	wa, iz
	add	wa, (xsp+10)
	add	wa, (xsp+18)
	sub	(xsp+8), wa
	jr	ge, HDAE5000_DoPrintf_Case_Octal_Join5
	ldw (xsp + 0x08), 0
HDAE5000_DoPrintf_Case_Octal_Join5:
	ld	wa, (xsp+8)
	add	wa, iz
	add	wa, (xsp+10)
	add	wa, (xsp+18)
	add	(xsp+4), wa
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Join6
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 32
	jr	z, HDAE5000_DoPrintf_Case_Octal_Next
	jr	t, HDAE5000_DoPrintf_Case_Octal_Join6
HDAE5000_DoPrintf_Case_Octal_Loop:
	pushw 0x0020
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Octal_Next:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Loop
HDAE5000_DoPrintf_Case_Octal_Join6:
	cpw	(xsp+18), 0x0000
	jr	z, HDAE5000_DoPrintf_Case_Octal_Join7
	cp	iz, 0:i3
	jr	z, HDAE5000_DoPrintf_Case_Octal_Join7
	pushw 0x0030
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Octal_Join7:
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Next3
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 48
	jr	z, HDAE5000_DoPrintf_Case_Octal_Next2
	jr	t, HDAE5000_DoPrintf_Case_Octal_Next3
HDAE5000_DoPrintf_Case_Octal_Loop2:
	pushw 0x0030
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Octal_Next2:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Loop2
	jr	t, HDAE5000_DoPrintf_Case_Octal_Next3
HDAE5000_DoPrintf_Case_Octal_Loop3:
	pushw 0x0030
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Octal_Next3:
	ld	wa, (xsp+10)
	decm	1, (xsp+10)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Loop3
	jr	t, HDAE5000_DoPrintf_Case_Octal_Next4
HDAE5000_DoPrintf_Case_Octal_Loop4:
	dec	1, iz
	lda	xwa, (xsp+20)
	ld	a, (xwa+iz)
	exts wa
	pushw wa
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Octal_Next4:
	cp	iz, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Loop4
	ld	wa, (xsp+6)
	bit	0x01, wa
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Next5
	jrl	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Octal_Loop5:
	pushw 0x0020
	ld xwa, (xsp + 0x5c)
	call	(xwa)
	inc 2, xsp
HDAE5000_DoPrintf_Case_Octal_Next5:
	ld	wa, (xsp+8)
	decm	1, (xsp+8)
	cp	wa, 0:i3
	jr	nz, HDAE5000_DoPrintf_Case_Octal_Loop5
	jr	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Count:
	ld xbc, (xsp + 0x56)
	ld	xwa, 4:i3
	add	(xbc), xwa
	ld xwa, (xbc)
	ld	xbc, (xwa-4)
	ld	wa, (xsp+6)
	bit	0x06, wa
	jr	z, HDAE5000_DoPrintf_Case_Count_Skip
	ld	wa, (xsp+4)
	exts xwa
	ld (xbc), xwa
	jr	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Count_Skip:
	ld	wa, (xsp+4)
	ld (xbc), wa
	jr	t, HDAE5000_DoPrintf_NextChar
HDAE5000_DoPrintf_Case_Float:
	lda	xbc, (xsp+68)
	ld	wa, (xsp+6)
	bit	0x07, wa
	jr	z, HDAE5000_DoPrintf_Case_Float_Skip
	ld	xwa, xbc
	ld xde, (xsp + 0x56)
	lda_dd8l	xbc, (10); lda XBC,0x0a (F0 8-bit direct)
	add	(xde), xbc
	ld xbc, (xde)
	lda	xbc, (xbc-10)
	call HDAE5000_Copy10
	jr	t, HDAE5000_DoPrintf_Case_Float_Join
HDAE5000_DoPrintf_Case_Float_Skip:
	ld	xwa, xbc
	ld xde, (xsp + 0x56)
	lda_dd8l	xbc, (8); lda XBC,0x08 (F0 8-bit direct)
	add	(xde), xbc
	ld xbc, (xde)
	dec 8, xbc
	call HDAE5000_Copy8
HDAE5000_DoPrintf_Case_Float_Join:
	pushm	(xsp+10)
	pushm	(xsp+10)
	pushm	(xsp+10)
	lda	xwa, (xsp+74)
	push xwa
	ld xwa, (xsp + 0x64)
	push xwa
	ldto_berp a, 0xf8		; ld A,IZL
	exts wa
	pushw wa
	calr	HDAE5000_FormatFloat
	lda	xsp, (xsp+16)
	ld	wa, (HDAE5000_RAM_PrintfFloatCount:24)
	add	(xsp+4), wa
HDAE5000_DoPrintf_NextChar:
	ld xwa, (xsp + 0x52)
	ld c, (xwa+)
	ld (xsp + 0x52), xwa
	ldfr_berp c, 0xf8		; ld IZL,C
	exts	iz
	cp	iz, 0:i3
	jrl	nz, HDAE5000_DoPrintf_Loop
	ld	hl, (xsp+4)
	pop xiz
	lda	xsp, (xsp+74)
	ret


; --- String Formatting Library (sprintf-like) ---
HDAE5000_Int_To_Decimal_String:	; (80 bytes)
	; Convert signed 32-bit integer to decimal string
	; Stack: [+0x0C] = output buffer ptr (with write-ahead), [+0x10] = signed value
	; Negates if negative, then extracts digits via repeated /10
	dec 4, xsp			; allocate local scratch space
	push xiz
	ld xwa, (xsp + 16)		; load signed value
	cp xwa, 0x00000000		; check sign
	jr ge, .LInt_To_Dec__positive
	cpl wa				; negate low word
	cpl	qwa
	inc 1, xwa			; two's complement
.LInt_To_Dec__positive:
	ld xiz, xwa			; XIZ = |value|
.LInt_To_Dec__loop:
	ld xwa, (xsp + 12)		; get buffer state
	lda xbc, (xwa+:1)			; lda XBC, (XWA+) — advance write ptr
	ld (xsp + 4), xbc		; save digit write position
	ld (xsp + 12), xwa		; save advanced buffer ptr
	ld xwa, xiz			; value to divide
	lda_dd8l xbc, (0x0A); divisor = 10
	call HDAE5000_UMod32	; XHL = remainder
	add xhl, 0x00000030		; remainder + '0' → ASCII digit
	ld xwa, (xsp + 4)		; get digit write position
	ld (xwa), l			; store digit character
	ld xwa, xiz			; reload value
	lda_dd8l xbc, (0x0A); divisor = 10
	call HDAE5000_UDivMod32	; XHL = quotient
	ld xiz, xhl			; update remaining value
	or xiz, xiz			; check if zero
	jr nz, .LInt_To_Dec__loop	; continue if non-zero
	ld xwa, (xsp + 12)		; get end-of-string position
	ld (xwa), 0x00		; null-terminate
	pop xiz
	inc 4, xsp			; deallocate scratch space
	ret

; ---------------------------------------------------------------------------
; Unsigned decimal digits of a long, LEAST significant first (value % 10 by
; HDAE5000_UMod32, / 10 by HDAE5000_UDivMod32), then a NUL.  One digit for 0.
; In:  (xsp+4) = buffer, (xsp+8) = value.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_UInt_To_Decimal_String:
	dec 4, xsp
	push xiz
	ld xiz, (xsp + 16)
.LUInt_To_Dec__loop:
	ld xwa, (xsp + 12)
	lda xbc, (xwa+:1)
	ld (xsp + 4), xbc
	ld (xsp + 12), xwa
	ld xwa, xiz
	lda_dd8l xbc, (0x0A)
	call HDAE5000_UMod32
	add xhl, 0x00000030
	ld xwa, (xsp + 4)
	ld (xwa), l
	ld xwa, xiz
	lda_dd8l xbc, (0x0A)
	call HDAE5000_UDivMod32
	ld xiz, xhl
	or xiz, xiz
	jr nz, .LUInt_To_Dec__loop
	ld xwa, (xsp + 12)
	ld (xwa), 0x00
	pop xiz
	inc 4, xsp
	ret

; ---------------------------------------------------------------------------
; Hex digits of a long, least significant first, then a NUL; lower case
; (HDAE5000_HexDigits_Lower) when the format character is 'x', else upper
; case.
; In:  (xsp+4) = buffer, (xsp+8) = value, (xsp+12) = format character (word)
; Out: clobbers XWA, XBC, XDE, XHL, XIX.
; ---------------------------------------------------------------------------
HDAE5000_Int_To_Hex_String:
	ld xwa, HDAE5000_HexDigits_Upper
	cpw (xsp + 12), 0x0078
	jr nz, .LInt_To_Hex__start
	ld xwa, HDAE5000_HexDigits_Lower
.LInt_To_Hex__start:
	ld xix, xwa
	ld xhl, (xsp + 4)
	ld xde, (xsp + 8)
.LInt_To_Hex__loop:
	lda xbc, (xhl+:1)
	ld xwa, xde
	and xwa, 0x0000000F
	add xwa, xix
	ld a, (xwa)
	ld (xbc), a
	srl xde, 4
	jr nz, .LInt_To_Hex__loop
	ld (xhl), 0x00
	ret

; ---------------------------------------------------------------------------
; Octal digits of a long, least significant first, then a NUL.
; In:  (xsp+4) = buffer, (xsp+8) = value
; Out: clobbers XWA, XBC, XDE, XHL.
; ---------------------------------------------------------------------------
HDAE5000_Int_To_Octal_String:
	ld xde, (xsp + 8)
	ld xhl, (xsp + 4)
.LInt_To_Octal__loop:
	lda xbc, (xhl+:1)
	ld xwa, xde
	and xwa, 0x00000007
	add xwa, 0x00000030
	ld (xbc), a
	srl xde, 3
	jr nz, .LInt_To_Octal__loop
	ld (xhl), 0x00
	ret

; ---------------------------------------------------------------------------
; printf's floating-point conversions (%e %E %f %F %g %G) for
; HDAE5000_DoPrintf: HDAE5000_FltDec_Convert turns the value into decimal
; digits and an exponent, then HDAE5000_FormatFloat_Fixed (%f / %F) or
; HDAE5000_FormatFloat_Exp (%e / %E) emits them; %g / %G picks one by
; comparing that exponent with -4 and with the precision.  The characters go
; out through DoPrintf's putc callback; HDAE5000_RAM_PrintfFloatCount counts
; them.
; ---------------------------------------------------------------------------
HDAE5000_FormatFloat:
	lda xsp, (xsp - 26)		; allocate 26-byte stack frame
	push xiz			; save XIZ
	ldw (xsp + 4), 0x0000		; clear local variable
	lda xwa, (xsp + 6)		; XWA = &local[2]
	push xwa			; push output buffer ptr
	lda xwa, (xsp + 8)		; XWA = &local[4] (adjusted)
	push xwa			; push another ptr
	pushm (xsp + 0x34)		; push caller param
	lda xwa, (xsp + 0x12)		; XWA = &local[14]
	push xwa			; push ptr
	ld xwa, (xsp + 0x36)		; load caller's 32-bit param
	push xwa			; push value
	call HDAE5000_FltDec_Convert
	lda xsp, (xsp + 0x12)		; deallocate 18 bytes of args
	ldw (HDAE5000_RAM_PrintfFloatCount:24), 0x0000
	lda xde, (xsp + 8)		; XDE = &local[4]
	ld xiy, xde			; XIY = format output ptr
	ld c, (xsp + 0x22)		; C = format specifier char
	ld xiz, (xsp + 0x24)		; XIZ = caller param
	ld ix, (xsp + 0x2E)		; IX = precision
	ld hl, (xsp + 0x30)		; HL = width
	ld a, c				; A = specifier char
	exts wa				; sign-extend A to WA
	cp c, 0x65			; specifier == 'e'?
	jr z, .Lsf_e_format
	cp c, 0x45			; specifier == 'E'?
	jr nz, .Lsf_not_eE
.Lsf_e_format:
	pushm (xsp + 0x06)		; push param
	pushm (xsp + 0x06)		; push param
	push xiy			; push output ptr
	pushw hl			; push width
	pushw ix			; push precision
	pushm (xsp + 0x38)		; push caller param
	push xiz
	pushw wa			; push specifier
	jr t, .Lsf_call_output		; always → String_Format_Output
.Lsf_not_eE:
	cp c, 0x66			; specifier == 'f'?
	jr z, .Lsf_f_format
	cp c, 0x46			; specifier == 'F'?
	jr nz, .Lsf_not_fF
.Lsf_f_format:
	pushm (xsp + 0x06)		; push param
	pushm (xsp + 0x06)		; push param
	push xiy			; push output ptr
	pushw hl			; push width
	pushw ix			; push precision
	pushm (xsp + 0x38)		; push caller param
	push xiz
	pushw wa			; push specifier
.Lsf_call_core:
	calr HDAE5000_FormatFloat_Fixed
	lda xsp, (xsp + 0x14)		; deallocate 20 bytes of args
	jr t, .Lsf_cleanup		; always → cleanup
.Lsf_not_fF:				; g/G format handling
	ld wa, (xsp + 0x2C)		; WA = flags
	bit 4, wa			; bit 4 set?
	jr nz, .Lsf_have_precision
	ld hl, 6:i3			; default precision = 6
	setm 4, (xsp + 0x2C)		; set precision flag
.Lsf_have_precision:
	exts bc				; sign-extend C to BC
	pushm (xsp + 0x06)		; push param
	pushm (xsp + 0x06)		; push param
	push xde
	pushw hl			; push width
	pushw ix			; push precision
	pushm (xsp + 0x38)		; push caller param
	push xiz
	pushw bc			; push specifier (extended)
	cpw (xsp + 0x18), 0xFFFC	; compare local with -4?
	jr le, .Lsf_call_output		; if LE → output
	cp (xsp + 0x18), hl		; compare local with width
	jr le, .Lsf_call_core		; if LE → use Core formatter
.Lsf_call_output:
	calr HDAE5000_FormatFloat_Exp
	lda xsp, (xsp + 0x14)		; deallocate 20 bytes of args
.Lsf_cleanup:
	pop xiz				; restore XIZ
	lda xsp, (xsp + 0x1A)		; deallocate 26-byte stack frame
	ret

; ---------------------------------------------------------------------------
; Fixed-point conversion (%f / %F, and %g in fixed range) of the digits
; HDAE5000_FltDec_Convert produced: pads (HDAE5000_RAM_PrintfPadChar) and
; rounds to the precision, emitting every character through the putc
; callback (the `call (xwa)` convention of HDAE5000_DoPrintf) and counting it
; in HDAE5000_RAM_PrintfFloatCount.  Only caller: HDAE5000_FormatFloat.
; ---------------------------------------------------------------------------
HDAE5000_FormatFloat_Fixed:
	dec	4, xsp
	pushw iz
	ldw (xsp + 0x04), 15
	cpw	(xsp+26), 0x0001
	jr	ge, HDAE5000_FormatFloat_Fixed_Skip
	ldw (xsp + 0x02), 0
	jr	t, HDAE5000_FormatFloat_Fixed_Join
HDAE5000_FormatFloat_Fixed_Skip:
	ld	wa, (xsp+26)
	ld (xsp + 0x02), wa
HDAE5000_FormatFloat_Fixed_Join:
	ld	wa, (xsp+16)
	bit	0x04, wa
	jr	nz, HDAE5000_FormatFloat_Fixed_Join2
	ldw (xsp + 0x14), 6
HDAE5000_FormatFloat_Fixed_Join2:
	ld	wa, (xsp+16)
	bit	0x07, wa
	jr	z, HDAE5000_FormatFloat_Fixed_Join3
	ldw (xsp + 0x04), 18
HDAE5000_FormatFloat_Fixed_Join3:
	ld	c, (xsp+10)
	ld	a, c
	extz wa
	lda xde, (HDAE5000_CType_Table:24)
	lda	xde, (xde+wa)
	bitm	1, (xde)
	jr	z, HDAE5000_FormatFloat_Fixed_Skip2
	ld	a, c
	sub	a, 0x20
	jr	t, HDAE5000_FormatFloat_Fixed_Join4
HDAE5000_FormatFloat_Fixed_Skip2:
	ld	a, c
HDAE5000_FormatFloat_Fixed_Join4:
	cp	a, 0x47
	jr	nz, HDAE5000_FormatFloat_Fixed_Skip3
	ld	iz, (xsp+20)
	jr	t, HDAE5000_FormatFloat_Fixed_Join5
HDAE5000_FormatFloat_Fixed_Skip3:
	ld	iz, (xsp+20)
	add	iz, (xsp+26)
HDAE5000_FormatFloat_Fixed_Join5:
	ld	wa, (xsp+4)
	inc	1, wa
	cp	iz, wa
	jr	ge, HDAE5000_FormatFloat_Fixed_Join6
	ld xwa, (xsp + 0x16)
	cp	(xwa+iz), 0x34
	jr	le, HDAE5000_FormatFloat_Fixed_Join6
	cp	iz, 0:i3
	jr	ge, HDAE5000_FormatFloat_Fixed_Next
	jr	t, HDAE5000_FormatFloat_Fixed_Join6
HDAE5000_FormatFloat_Fixed_Loop:
	ld xwa, (xsp + 0x16)
	ld	(xwa+iz), 0x30
HDAE5000_FormatFloat_Fixed_Next:
	dec	1, iz
	ld xwa, (xsp + 0x16)
	inc	1, (xwa+iz)
	cp	iz, 0:i3
	jr	le, HDAE5000_FormatFloat_Fixed_Join6
	cp	(xwa+iz), 0x39
	jr	gt, HDAE5000_FormatFloat_Fixed_Loop
HDAE5000_FormatFloat_Fixed_Join6:
	ld	e, (xde)
	bit	0x01, e
	jr	z, HDAE5000_FormatFloat_Fixed_Skip4
	ld	a, c
	sub	a, 0x20
	jr	t, HDAE5000_FormatFloat_Fixed_Join7
HDAE5000_FormatFloat_Fixed_Skip4:
	ld	a, c
HDAE5000_FormatFloat_Fixed_Join7:
	cp	a, 0x47
	jr	nz, HDAE5000_FormatFloat_Fixed_Join8
	ld	iz, (xsp+20)
	dec	1, iz
	ld	wa, (xsp+26)
	neg	wa
	add	(xsp+20), wa
HDAE5000_FormatFloat_Fixed_Join8:
	bit	0x01, e
	jr	z, HDAE5000_FormatFloat_Fixed_Join9
	sub	c, 0x20
HDAE5000_FormatFloat_Fixed_Join9:
	cp	c, 0x47
	jr	nz, HDAE5000_FormatFloat_Fixed_Join10
	ld	wa, (xsp+16)
	bit	0x03, wa
	jr	z, HDAE5000_FormatFloat_Fixed_Next2
	jr	t, HDAE5000_FormatFloat_Fixed_Join10
HDAE5000_FormatFloat_Fixed_Loop2:
	dec	1, iz
	decm	1, (xsp+20)
HDAE5000_FormatFloat_Fixed_Next2:
	ld xwa, (xsp + 0x16)
	cp	(xwa+iz), 0x30
	jr	z, HDAE5000_FormatFloat_Fixed_Loop2
HDAE5000_FormatFloat_Fixed_Join10:
	ld	wa, (xsp+16)
	bit	0x04, wa
	jr	z, HDAE5000_FormatFloat_Fixed_Join11
	cpw	(xsp+20), 0x0000
	jr	z, HDAE5000_FormatFloat_Fixed_Join12
HDAE5000_FormatFloat_Fixed_Join11:
	decm	1, (xsp+18)
HDAE5000_FormatFloat_Fixed_Join12:
	ld	iz, (xsp+28)
	cp	iz, 0:i3
	jr	nz, HDAE5000_FormatFloat_Fixed_Join13
	ld	wa, (xsp+16)
	and	wa, 0x0005
	jr	z, HDAE5000_FormatFloat_Fixed_Join14
HDAE5000_FormatFloat_Fixed_Join13:
	decm	1, (xsp+18)
HDAE5000_FormatFloat_Fixed_Join14:
	ld	wa, (xsp+2)
	add	wa, (xsp+20)
	sub	(xsp+18), wa
	ld xwa, (xsp + 0x16)
	cp	(xwa), 0x39
	jr	le, HDAE5000_FormatFloat_Fixed_Join15
	decm	1, (xsp+18)
HDAE5000_FormatFloat_Fixed_Join15:
	cpw	(xsp+18), 0x0000
	jr	ge, HDAE5000_FormatFloat_Fixed_Join16
	ldw (xsp + 0x12), 0
HDAE5000_FormatFloat_Fixed_Join16:
	ld	wa, (xsp+16)
	bit	0x01, wa
	jr	nz, HDAE5000_FormatFloat_Fixed_Join17
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 32
	jr	z, HDAE5000_FormatFloat_Fixed_Next3
	jr	t, HDAE5000_FormatFloat_Fixed_Join17
HDAE5000_FormatFloat_Fixed_Loop3:
	pushw 0x0020
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Fixed_Next3:
	ld	wa, (xsp+18)
	decm	1, (xsp+18)
	cp	wa, 0:i3
	jr	gt, HDAE5000_FormatFloat_Fixed_Loop3
HDAE5000_FormatFloat_Fixed_Join17:
	cp	iz, 0:i3
	jr	z, HDAE5000_FormatFloat_Fixed_Skip5
	pushw 0x002d
	jr	t, HDAE5000_FormatFloat_Fixed_Join18
HDAE5000_FormatFloat_Fixed_Skip5:
	ld	wa, (xsp+16)
	bit	0x00, wa
	jr	z, HDAE5000_FormatFloat_Fixed_Skip6
	pushw 0x002b
	jr	t, HDAE5000_FormatFloat_Fixed_Join18
HDAE5000_FormatFloat_Fixed_Skip6:
	ld	wa, (xsp+16)
	bit	0x02, wa
	jr	z, HDAE5000_FormatFloat_Fixed_Join19
	pushw 0x0020
HDAE5000_FormatFloat_Fixed_Join18:
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Fixed_Join19:
	ld	wa, (xsp+16)
	bit	0x01, wa
	jr	nz, HDAE5000_FormatFloat_Fixed_Join20
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 48
	jr	z, HDAE5000_FormatFloat_Fixed_Next4
	jr	t, HDAE5000_FormatFloat_Fixed_Join20
HDAE5000_FormatFloat_Fixed_Loop4:
	pushw 0x0030
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Fixed_Next4:
	ld	wa, (xsp+18)
	decm	1, (xsp+18)
	cp	wa, 0:i3
	jr	gt, HDAE5000_FormatFloat_Fixed_Loop4
HDAE5000_FormatFloat_Fixed_Join20:
	ld xwa, (xsp + 0x16)
	cp	(xwa), 0x39
	jr	le, HDAE5000_FormatFloat_Fixed_Skip7
	cpw	(xsp+26), 0x0000
	jr	lt, HDAE5000_FormatFloat_Fixed_Skip7
	pushw 0x0031
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	ld xwa, (xsp + 0x16)
	ld	(xwa), 0x30
	jr	t, HDAE5000_FormatFloat_Fixed_Join21
HDAE5000_FormatFloat_Fixed_Skip7:
	cpw	(xsp+26), 0x0000
	jr	gt, HDAE5000_FormatFloat_Fixed_Join22
	pushw 0x0030
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
HDAE5000_FormatFloat_Fixed_Join21:
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Fixed_Join22:
	ld	iz, 0:i3
	jr	t, HDAE5000_FormatFloat_Fixed_Next5
HDAE5000_FormatFloat_Fixed_Loop5:
	ld xwa, (xsp + 0x16)
	ld	a, (xwa+iz)
	exts wa
	pushw wa
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
	inc	1, iz
HDAE5000_FormatFloat_Fixed_Next5:
	ld	wa, (xsp+4)
	inc	1, wa
	cp	iz, wa
	jr	ge, HDAE5000_FormatFloat_Fixed_Next6
	ld	wa, (xsp+2)
	decm	1, (xsp+2)
	cp	wa, 0:i3
	jr	gt, HDAE5000_FormatFloat_Fixed_Loop5
	jr	t, HDAE5000_FormatFloat_Fixed_Next6
HDAE5000_FormatFloat_Fixed_Loop6:
	pushw 0x0030
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Fixed_Next6:
	ld	wa, (xsp+2)
	decm	1, (xsp+2)
	cp	wa, 0:i3
	jr	gt, HDAE5000_FormatFloat_Fixed_Loop6
	ld	wa, (xsp+16)
	bit	0x03, wa
	jr	nz, HDAE5000_FormatFloat_Fixed_Join23
	cpw	(xsp+20), 0x0000
	jr	z, HDAE5000_FormatFloat_Fixed_Next7
HDAE5000_FormatFloat_Fixed_Join23:
	pushw 0x002e
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
	jr	t, HDAE5000_FormatFloat_Fixed_Next7
HDAE5000_FormatFloat_Fixed_Loop7:
	ld	wa, (xsp+26)
	add	wa, 0x0001
	jr	nz, HDAE5000_FormatFloat_Fixed_Skip8
	ld xwa, (xsp + 0x16)
	cp	(xwa), 0x39
	jr	le, HDAE5000_FormatFloat_Fixed_Skip8
	pushw 0x0031
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	ld xwa, (xsp + 0x16)
	ld	(xwa), 0x30
	jr	t, HDAE5000_FormatFloat_Fixed_Join24
HDAE5000_FormatFloat_Fixed_Skip8:
	pushw 0x0030
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
HDAE5000_FormatFloat_Fixed_Join24:
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
	incw	1, (xsp+26)
HDAE5000_FormatFloat_Fixed_Next7:
	cpw	(xsp+26), 0x0000
	jr	ge, HDAE5000_FormatFloat_Fixed_Join25
	ld	wa, (xsp+20)
	decm	1, (xsp+20)
	cp	wa, 0:i3
	jr	nz, HDAE5000_FormatFloat_Fixed_Loop7
HDAE5000_FormatFloat_Fixed_Join25:
	ld	wa, (xsp+4)
	inc	1, wa
	cp	iz, wa
	jr	lt, HDAE5000_FormatFloat_Fixed_Next8
	jr	t, HDAE5000_FormatFloat_Fixed_Next9
HDAE5000_FormatFloat_Fixed_Loop8:
	ld xwa, (xsp + 0x16)
	ld	a, (xwa+iz)
	exts wa
	pushw wa
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
	inc	1, iz
HDAE5000_FormatFloat_Fixed_Next8:
	ld	wa, (xsp+4)
	inc	1, wa
	cp	iz, wa
	jr	ge, HDAE5000_FormatFloat_Fixed_Next9
	ld	wa, (xsp+20)
	decm	1, (xsp+20)
	cp	wa, 0:i3
	jr	gt, HDAE5000_FormatFloat_Fixed_Loop8
	jr	t, HDAE5000_FormatFloat_Fixed_Next9
HDAE5000_FormatFloat_Fixed_Loop9:
	pushw 0x0030
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Fixed_Next9:
	ld	wa, (xsp+20)
	decm	1, (xsp+20)
	cp	wa, 0:i3
	jr	gt, HDAE5000_FormatFloat_Fixed_Loop9
	ld	wa, (xsp+16)
	bit	0x01, wa
	jr	nz, HDAE5000_FormatFloat_Fixed_Next10
	jr	t, HDAE5000_FormatFloat_Fixed_Epilogue
HDAE5000_FormatFloat_Fixed_Loop10:
	pushw 0x0020
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Fixed_Next10:
	ld	wa, (xsp+18)
	decm	1, (xsp+18)
	cp	wa, 0:i3
	jr	gt, HDAE5000_FormatFloat_Fixed_Loop10
HDAE5000_FormatFloat_Fixed_Epilogue:
	popw iz
	inc 4, xsp
	ret

	ld xwa, (xsp + 0x04)
HDAE5000_FormatFloat_Fixed_Loop11:
	cp	(xwa), 0x00
	jr	nz, HDAE5000_FormatFloat_Fixed_Next11
	ld	hl, 1:i3
	ret

HDAE5000_FormatFloat_Fixed_Next11:
	cp	(xwa+), 48
	jr	z, HDAE5000_FormatFloat_Fixed_Loop11
	ld	hl, 0:i3
	ret


; ---------------------------------------------------------------------------
; Exponential conversion (%e / %E, and %g out of fixed range): emits d.ddd,
; then the exponent letter (for %g / %G the spec letter - 2, i.e. 'e' / 'E')
; and the exponent through HDAE5000_Int_To_Decimal_String.  Case tests use
; HDAE5000_CType_Table bit 1 (lower case).  Counts its characters in
; HDAE5000_RAM_PrintfFloatCount.  Only caller: HDAE5000_FormatFloat.
; ---------------------------------------------------------------------------
HDAE5000_FormatFloat_Exp:
	dec	2, xsp
	push xiz
	ldw (xsp + 0x04), 15
	ld	wa, (xsp+16)
	bit	0x04, wa
	jr	nz, HDAE5000_FormatFloat_Exp_Join
	ldw (xsp + 0x14), 6
HDAE5000_FormatFloat_Exp_Join:
	ld	a, (xsp+10)
	extz wa
	lda xbc, (HDAE5000_CType_Table:24)
	lda	xbc, (xbc+wa)
	bitm	1, (xbc)
	jr	z, HDAE5000_FormatFloat_Exp_Skip
	ld	a, (xsp+10)
	sub	a, 0x20
	jr	t, HDAE5000_FormatFloat_Exp_Join2
HDAE5000_FormatFloat_Exp_Skip:
	ld	a, (xsp+10)
HDAE5000_FormatFloat_Exp_Join2:
	cp	a, 0x47
	jr	nz, HDAE5000_FormatFloat_Exp_Join3
	cpw	(xsp+20), 0x0000
	jr	z, HDAE5000_FormatFloat_Exp_Join3
	decm	1, (xsp+20)
HDAE5000_FormatFloat_Exp_Join3:
	ld	wa, (xsp+20)
	inc	1, wa
	ld	qiz, wa
	ld	wa, (xsp+16)
	bit	0x07, wa
	jr	z, HDAE5000_FormatFloat_Exp_Join4
	ldw (xsp + 0x04), 18
HDAE5000_FormatFloat_Exp_Join4:
	ld	de, (xsp+4)
	inc	1, de
	ld	wa, qiz
	cp	wa, de
	jr	ge, HDAE5000_FormatFloat_Exp_Join5
	ld	de, qiz
	dec	1, qiz
	ld xwa, (xsp + 0x16)
	cp	(xwa+de), 0x34
	jr	gt, HDAE5000_FormatFloat_Exp_Next
	jr	t, HDAE5000_FormatFloat_Exp_Join5
HDAE5000_FormatFloat_Exp_Loop:
	ld xwa, (xsp + 0x16)
	stib_ind 0x07, 0xE0, 0xFA, 0x30	; ld (XWA+QIZ),0x30
	dec	1, qiz
HDAE5000_FormatFloat_Exp_Next:
	ld xwa, (xsp + 0x16)
	inc_srib 1, 0x07, 0xE0, 0xFA	; inc 1,(XWA+QIZ)
	cp	qiz, 0
	jr	le, HDAE5000_FormatFloat_Exp_Join5
	cpib_sri 0x07, 0xE0, 0xFA, 0x39	; cp (XWA+QIZ),0x39
	jr	gt, HDAE5000_FormatFloat_Exp_Loop
HDAE5000_FormatFloat_Exp_Join5:
	bitm	1, (xbc)
	jr	z, HDAE5000_FormatFloat_Exp_Skip2
	ld	a, (xsp+10)
	sub	a, 0x20
	jr	t, HDAE5000_FormatFloat_Exp_Join6
HDAE5000_FormatFloat_Exp_Skip2:
	ld	a, (xsp+10)
HDAE5000_FormatFloat_Exp_Join6:
	cp	a, 0x47
	jr	nz, HDAE5000_FormatFloat_Exp_Join7
	ld	wa, (xsp+16)
	bit	0x03, wa
	jr	nz, HDAE5000_FormatFloat_Exp_Join7
	ld	wa, (xsp+20)
	ld	qiz, wa
	jr	t, HDAE5000_FormatFloat_Exp_Next2
HDAE5000_FormatFloat_Exp_Loop2:
	dec	1, qiz
	decm	1, (xsp+20)
HDAE5000_FormatFloat_Exp_Next2:
	cp	qiz, 0
	jr	le, HDAE5000_FormatFloat_Exp_Join7
	ld xwa, (xsp + 0x16)
	cpib_sri 0x07, 0xE0, 0xFA, 0x30	; cp (XWA+QIZ),0x30
	jr	z, HDAE5000_FormatFloat_Exp_Loop2
HDAE5000_FormatFloat_Exp_Join7:
	decm	5, (xsp+18)
	ld	wa, (xsp+16)
	bit	0x04, wa
	jr	z, HDAE5000_FormatFloat_Exp_Join8
	cpw	(xsp+20), 0x0000
	jr	z, HDAE5000_FormatFloat_Exp_Join9
HDAE5000_FormatFloat_Exp_Join8:
	decm	1, (xsp+18)
HDAE5000_FormatFloat_Exp_Join9:
	ld	iz, (xsp+28)
	cp	iz, 0:i3
	jr	nz, HDAE5000_FormatFloat_Exp_Join10
	ld	wa, (xsp+16)
	and	wa, 0x0005
	jr	z, HDAE5000_FormatFloat_Exp_Join11
HDAE5000_FormatFloat_Exp_Join10:
	decm	1, (xsp+18)
HDAE5000_FormatFloat_Exp_Join11:
	ld	wa, (xsp+20)
	sub	(xsp+18), wa
	jr	ge, HDAE5000_FormatFloat_Exp_Join12
	ldw (xsp + 0x12), 0
HDAE5000_FormatFloat_Exp_Join12:
	ld	wa, (xsp+16)
	bit	0x01, wa
	jr	nz, HDAE5000_FormatFloat_Exp_Join13
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 32
	jr	z, HDAE5000_FormatFloat_Exp_Next3
	jr	t, HDAE5000_FormatFloat_Exp_Join13
HDAE5000_FormatFloat_Exp_Loop3:
	pushw 0x0020
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Exp_Next3:
	decm	1, (xsp+18)
	cpw	(xsp+18), 0x0000
	jr	gt, HDAE5000_FormatFloat_Exp_Loop3
HDAE5000_FormatFloat_Exp_Join13:
	cp	iz, 0:i3
	jr	z, HDAE5000_FormatFloat_Exp_Skip3
	pushw 0x002d
	jr	t, HDAE5000_FormatFloat_Exp_Join14
HDAE5000_FormatFloat_Exp_Skip3:
	ld	wa, (xsp+16)
	bit	0x00, wa
	jr	z, HDAE5000_FormatFloat_Exp_Skip4
	pushw 0x002b
	jr	t, HDAE5000_FormatFloat_Exp_Join14
HDAE5000_FormatFloat_Exp_Skip4:
	ld	wa, (xsp+16)
	bit	0x02, wa
	jr	z, HDAE5000_FormatFloat_Exp_Join15
	pushw 0x0020
HDAE5000_FormatFloat_Exp_Join14:
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Exp_Join15:
	ld	wa, (xsp+16)
	bit	0x01, wa
	jr	nz, HDAE5000_FormatFloat_Exp_Join16
	cpw	(HDAE5000_RAM_PrintfPadChar:24), 48
	jr	z, HDAE5000_FormatFloat_Exp_Next4
	jr	t, HDAE5000_FormatFloat_Exp_Join16
HDAE5000_FormatFloat_Exp_Loop4:
	pushw 0x0030
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Exp_Next4:
	decm	1, (xsp+18)
	cpw	(xsp+18), 0x0000
	jr	gt, HDAE5000_FormatFloat_Exp_Loop4
HDAE5000_FormatFloat_Exp_Join16:
	ld xwa, (xsp + 0x16)
	cp	(xwa), 0x39
	jr	le, HDAE5000_FormatFloat_Exp_Skip6
	pushw 0x0031
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	ld xwa, (xsp + 0x16)
	ld	(xwa), 0x30
	ld	qiz, 0
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
	cpw	(xsp+26), 0x0000
	jr	ge, HDAE5000_FormatFloat_Exp_Skip5
	incw	1, (xsp+26)
	jr	t, HDAE5000_FormatFloat_Exp_Join17
HDAE5000_FormatFloat_Exp_Skip5:
	decm	1, (xsp+26)
	jr	t, HDAE5000_FormatFloat_Exp_Join17
HDAE5000_FormatFloat_Exp_Skip6:
	ld xwa, (xsp + 0x16)
	ld	a, (xwa)
	exts wa
	pushw wa
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
	ld	qiz, 1
HDAE5000_FormatFloat_Exp_Join17:
	cpw	(xsp+20), 0x0000
	jr	nz, HDAE5000_FormatFloat_Exp_Join18
	ld	wa, (xsp+16)
	bit	0x03, wa
	jr	z, HDAE5000_FormatFloat_Exp_Join19
HDAE5000_FormatFloat_Exp_Join18:
	pushw 0x002e
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Exp_Join19:
	ld	c, (xsp+10)
	extz bc
	lda xwa, (HDAE5000_CType_Table:24)
	bit	1, (xwa+bc)
	jr	z, HDAE5000_FormatFloat_Exp_Skip7
	ld	a, (xsp+10)
	sub	a, 0x20
	jr	t, HDAE5000_FormatFloat_Exp_Join20
HDAE5000_FormatFloat_Exp_Skip7:
	ld	a, (xsp+10)
HDAE5000_FormatFloat_Exp_Join20:
	cp	a, 0x47
	jr	nz, HDAE5000_FormatFloat_Exp_Join21
	cpw	(xsp+20), 0x0000
	jr	nz, HDAE5000_FormatFloat_Exp_Join21
	cpw	(xsp+26), 0x0001
	jrl	z, HDAE5000_FormatFloat_Exp_Epilogue
HDAE5000_FormatFloat_Exp_Join21:
	ld	bc, (xsp+4)
	inc	1, bc
	ld	wa, qiz
	cp	wa, bc
	jr	lt, HDAE5000_FormatFloat_Exp_Next5
	jr	t, HDAE5000_FormatFloat_Exp_Next6
HDAE5000_FormatFloat_Exp_Loop5:
	ld xwa, (xsp + 0x16)
	ld	a, (xwa+qiz)
	exts wa
	pushw wa
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
	inc	1, qiz
HDAE5000_FormatFloat_Exp_Next5:
	ld	bc, (xsp+4)
	inc	1, bc
	ld	wa, qiz
	cp	wa, bc
	jr	ge, HDAE5000_FormatFloat_Exp_Next6
	ld	wa, (xsp+20)
	decm	1, (xsp+20)
	cp	wa, 0:i3
	jr	gt, HDAE5000_FormatFloat_Exp_Loop5
	jr	t, HDAE5000_FormatFloat_Exp_Next6
HDAE5000_FormatFloat_Exp_Loop6:
	pushw 0x0030
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Exp_Next6:
	ld	wa, (xsp+20)
	decm	1, (xsp+20)
	cp	wa, 0:i3
	jr	gt, HDAE5000_FormatFloat_Exp_Loop6
	decm	1, (xsp+26)
	ld	wa, (xsp+26)
	exts xwa
	push xwa
	ld xwa, (xsp + 0x1a)
	push xwa
	calr	HDAE5000_Int_To_Decimal_String
	ld xwa, (xsp + 0x1e)
	push xwa
	call HDAE5000_StrLen
	lda	xsp, (xsp+12)
	ld	iz, hl
	ld	c, (xsp+10)
	extz bc
	lda xwa, (HDAE5000_CType_Table:24)
	bit	1, (xwa+bc)
	jr	z, HDAE5000_FormatFloat_Exp_Skip8
	ld	a, (xsp+10)
	sub	a, 0x20
	jr	t, HDAE5000_FormatFloat_Exp_Join22
HDAE5000_FormatFloat_Exp_Skip8:
	ld	a, (xsp+10)
HDAE5000_FormatFloat_Exp_Join22:
	cp	a, 0x47
	jr	nz, HDAE5000_FormatFloat_Exp_Skip9
	ld	a, (xsp+10)
	dec	2, a
	jr	t, HDAE5000_FormatFloat_Exp_Join23
HDAE5000_FormatFloat_Exp_Skip9:
	ld	a, (xsp+10)
HDAE5000_FormatFloat_Exp_Join23:
	exts wa
	pushw wa
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
	cpw	(xsp+26), 0x0000
	jr	ge, HDAE5000_FormatFloat_Exp_Skip10
	pushw 0x002d
	jr	t, HDAE5000_FormatFloat_Exp_Join24
HDAE5000_FormatFloat_Exp_Skip10:
	pushw 0x002b
HDAE5000_FormatFloat_Exp_Join24:
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
	ld	qiz, iz
	jr	t, HDAE5000_FormatFloat_Exp_Next7
HDAE5000_FormatFloat_Exp_Loop7:
	pushw 0x0030
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Exp_Next7:
	ld	wa, qiz
	inc	1, qiz
	cp	wa, 3:i3
	jr	lt, HDAE5000_FormatFloat_Exp_Loop7
	jr	t, HDAE5000_FormatFloat_Exp_Next8
HDAE5000_FormatFloat_Exp_Loop8:
	dec	1, iz
	ld xwa, (xsp + 0x16)
	ld	a, (xwa+iz)
	exts wa
	pushw wa
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Exp_Next8:
	cp	iz, 0:i3
	jr	nz, HDAE5000_FormatFloat_Exp_Loop8
	ld	wa, (xsp+16)
	bit	0x01, wa
	jr	nz, HDAE5000_FormatFloat_Exp_Next9
	jr	t, HDAE5000_FormatFloat_Exp_Epilogue
HDAE5000_FormatFloat_Exp_Loop9:
	pushw 0x0020
	ld xwa, (xsp + 0x0e)
	call	(xwa)
	inc 2, xsp
	incw	1, (HDAE5000_RAM_PrintfFloatCount:24)
HDAE5000_FormatFloat_Exp_Next9:
	decm	1, (xsp+18)
	cpw	(xsp+18), 0x0000
	jr	gt, HDAE5000_FormatFloat_Exp_Loop9
HDAE5000_FormatFloat_Exp_Epilogue:
	pop xiz
	inc 2, xsp
	ret


; ---------------------------------------------------------------------------
; sprintf(buf, fmt, ...): points HDAE5000_RAM_SPrintfCursor at buf, stores a
; NUL there, and runs HDAE5000_DoPrintf(fmt, &ap, HDAE5000_SPrintf_PutChar)
; with ap = the address of the first variadic argument, (xsp+12) on entry.
; In:  (xsp+4) = buf, (xsp+8) = fmt, (xsp+12)... = the arguments
; Out: XHL as HDAE5000_DoPrintf returns it.
; ---------------------------------------------------------------------------
HDAE5000_SPrintf:
	dec 4, xsp			; allocate 4 bytes
	ld xwa, (xsp + 8)		; XWA = buffer ptr
	ld (HDAE5000_RAM_SPrintfCursor:24), xwa
	ld (xwa), 0x00		; null-terminate buffer
	lda xwa, (xsp + 0x10)		; XWA = &param area
	ld (xsp), xwa			; save to local
	pushw HDAE5000_SPrintf_PutChar@hi16			; push callback addr high word
	pushw	HDAE5000_SPrintf_PutChar@lo16		; low half of HDAE5000_SPrintf_PutChar
	lda xwa, (xsp + 4)		; XWA = &ap (the local saved above): va_list *
	push xwa			; push &ap (the callback long just pushed is arg 3)
	ld xwa, (xsp + 0x14)		; XWA = format data
	push xwa
	call HDAE5000_DoPrintf
	lda xsp, (xsp + 0x10)		; cleanup 16 bytes
	ret
	;
	; --- Sub 2: Setup variant 2 (simpler) ---
	; vsprintf(buf, fmt, ap): as HDAE5000_SPrintf, but passes the address of
	; its own ap argument as the va_list *.  No caller in this ROM (searched:
	; symbolic call/calr/jp to this label, which did not exist before, and
	; the literal 0x29AC00 in every hdae5000 source).
HDAE5000_VSPrintf:
	ld xwa, (xsp + 4)		; XWA = buffer ptr
	ld (HDAE5000_RAM_SPrintfCursor:24), xwa
	ld (xwa), 0x00		; null-terminate buffer
	pushw HDAE5000_SPrintf_PutChar@hi16			; push callback addr high word
	pushw	HDAE5000_SPrintf_PutChar@lo16		; low half of HDAE5000_SPrintf_PutChar
	lda xwa, (xsp + 0x10)		; XWA = &ap argument: va_list *
	push xwa			; push &ap (the callback long just pushed is arg 3)
	ld xwa, (xsp + 0x10)		; XWA = format data
	push xwa
	call HDAE5000_DoPrintf
	lda xsp, (xsp + 0x0C)		; cleanup 12 bytes
	ret
	;
	; --- Sub 3: Byte-write callback (called by HDAE5000_DoPrintf) ---
	; Appends one byte to buffer at [0x239482], advances pointer, null-terminates.
HDAE5000_SPrintf_PutChar:
	ld xbc, (HDAE5000_RAM_SPrintfCursor:24)
	ld xwa, 1:i3			; XWA = 1
	add (HDAE5000_RAM_SPrintfCursor:24), xwa
	ld wa, (xsp + 4)		; WA = character to write
	ld (xbc), a			; store character at buffer
	ld xwa, (HDAE5000_RAM_SPrintfCursor:24); XWA = new buffer ptr
	ld (xwa), 0x00		; null-terminate
	ret
	;
	; --- Sub 4: Integer to base-N string converter ---
	; itoa(int value, char *buf, int radix) on a 16-bit int: HDAE5000_IToA.
	; Stack: [+0x1A] = value, [+0x1C] = output ptr, [+0x20] = radix
	; Handles signed decimal (radix 10), validates radix 2-36.
	; Uses QBC (previous register bank) to hold the working value.
HDAE5000_IToA:
	lda xsp, (xsp - 18)		; allocate 18-byte frame
	push xiz			; save XIZ
	ld xhl, (xsp + 0x1C)		; XHL = output buffer ptr
	ld ix, 0:i3			; IX = 0 (sign = positive)
	ld bc, (xsp + 0x20)		; BC = radix
	cp bc, 2:i3			; radix < 2?
	jr lt, .Lppi_empty		; → invalid, output empty string
	cp bc, 0x0024			; radix > 36?
	jr le, .Lppi_convert		; → valid, start conversion
.Lppi_empty:
	ld (xhl), 0x00		; *output = '\0'
	jr t, .Lppi_done		; → exit
.Lppi_convert:
	ld wa, (xsp + 0x1A)		; WA = value to convert
	ld qbc, wa		; ld QBC, WA (save value in prev bank)
	lda xiz, (xsp + 4)		; XIZ = &local scratch buffer
	ld (xiz + 0x11), 0x00	; null-terminate scratch[17]
	lda xiy, (xiz + 0x10)		; XIY = scratch end pointer
	cp bc, 0x000A			; radix == 10? (decimal)
	jr nz, .Lppi_div_loop		; → unsigned for other radixes
	ld wa, qbc		; ld WA, QBC (reload value)
	cp wa, 0:i3			; value < 0? (signed check)
	jr ge, .Lppi_div_loop		; → non-negative
	ld ix, 1:i3			; IX = 1 (negative flag)
	ld wa, qbc		; ld WA, QBC (reload value)
	neg wa				; negate (make positive)
	ld qbc, wa		; ld QBC, WA (save positive value)
.Lppi_div_loop:
	ld de, bc			; DE = radix (divisor)
	ld wa, qbc		; ld WA, QBC (current value)
	extz xwa			; zero-extend WA to XWA
	div xwa, de			; XWA = WA / DE (quot in WA, rem in high)
	ld wa, qwa		; ld WA, QWA (get remainder)
	add a, 0x30			; convert to ASCII '0'-'9'
	ld (xiy), a			; store digit
	cp (xiy), 0x39		; digit > '9'?
	jr le, .Lppi_digit_ok		; → it's 0-9
	addmi8 (xiy), 0x27		; adjust for 'a'-'z' (0x30+0x27=0x57→'W'+n)
.Lppi_digit_ok:
	ld wa, qbc		; ld WA, QBC (reload quotient)
	extz xwa			; zero-extend
	div xwa, de			; divide again to get next quotient
	ld qbc, wa		; ld QBC, WA (save new quotient)
	cp qbc, 0		; cp QBC, 0 (quotient == 0?)
	jr z, .Lppi_digits_done		; → all digits extracted
	dec 1, xiy			; move digit pointer back
	jr t, .Lppi_div_loop		; → next digit
.Lppi_digits_done:
	cp ix, 0:i3			; negative flag set?
	jr z, .Lppi_copy_digits		; → no sign needed
	ld (-xiy), 0x2D		; ld (-XIY), '-' (pre-decrement, store minus sign)
.Lppi_copy_digits:
	lda xwa, (xiz + 0x12)		; XWA = &scratch[18] (past null-terminator)
	sub xwa, xiy			; XWA = string length (including null)
	pushw wa			; push length
	push xiy			; push source ptr
	push xhl			; push destination ptr
	call HDAE5000_MemCopy		; copy digit string to output
	lda xsp, (xsp + 0x0A)		; cleanup 10 bytes
.Lppi_done:
	pop xiz				; restore XIZ
	lda xsp, (xsp + 0x12)		; deallocate 18-byte frame
	ret

; ---------------------------------------------------------------------------
; ldiv(): result->quot = num / den (HDAE5000_SDiv32), result->rem = num % den
; (HDAE5000_SMod32), built in a local and copied out with 4 x LDIRW.
; den == 0 skips both calls and copies the uninitialised local.
; In:  (xsp+4) = ldiv_t *result, (xsp+8) = num, (xsp+12) = den.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_LDiv:
	lda xsp, (xsp - 16)
	push xiz
	ld xwa, (xsp + 0x20)
	or xwa, xwa
	jr z, .Lccb_copy
	lda xwa, (xsp + 0x0C)
	ld (xsp + 8), xwa
	ld (xsp + 4), xwa
	ld xiz, (xsp + 0x1C)
	ld xwa, xiz
	ld xbc, (xsp + 0x20)
	call HDAE5000_SDiv32
	ld xwa, (xsp + 4)
	ld (xwa), xhl
	ld xwa, xiz
	ld xbc, (xsp + 0x20)
	call HDAE5000_SMod32
	ld xwa, (xsp + 8)
	ld (xwa + 4), xhl
.Lccb_copy:
	ld xix, (xsp + 0x18)
	lda xiy, (xsp + 0x0C)
	ld bc, 4:i3
	ldirw
	pop xiz
	lda xsp, (xsp + 0x10)
	ret
	;
	; --- Sub 2: Signed number format handler (0x29AD08-0x29AD43, 60 bytes) ---
	; Prepends '-' for negative values when radix==10, then calls Sub 3.
	; ltoa(long value, char *buf, int radix); returns XHL = buf (the
	; negative path hands buf+1 to HDAE5000_ULToA and backs the result up).
HDAE5000_LToA:
	ld xbc, (xsp + 8)		; XBC = output buffer ptr
	ld xde, (xsp + 4)		; XDE = value to convert
	ld wa, (xsp + 0x0C)		; WA = radix
	cp wa, 0x000A			; radix == 10? (decimal)
	jr nz, .Lccb_unsigned		; → unsigned conversion
	cp xde, 0x00000000		; value < 0? (signed check)
	jr ge, .Lccb_unsigned		; → non-negative
	; Negative decimal: prepend '-' and negate
	ld (xbc), 0x2D		; store '-' at buffer start
	pushw wa			; push radix
	lda xwa, (xbc + 1)		; XWA = buffer+1 (past '-')
	push xwa			; push output ptr
	cpl de				; complement DE (bitwise NOT)
	cpl qde		; cpl QDE (complement high word)
	inc 1, xde			; +1 → two's complement negate
	push xde			; push negated value
	call HDAE5000_ULToA		; call base-N converter
	lda xsp, (xsp + 0x0a)		; cleanup 10 bytes
	dec 1, xhl			; adjust string length for '-'
	ret
.Lccb_unsigned:
	pushw wa			; push radix
	push xbc			; push output ptr
	push xde			; push value
	call HDAE5000_ULToA		; call base-N converter
	lda xsp, (xsp + 0x0A)		; cleanup 10 bytes
	ret
	;
	; --- Sub 3: General base-N string converter (0x29AD44-0x29ADCB, 136 bytes) ---
	; Converts integer to string with radix 2-36.
	; Stack: [+0x36] = value, [+0x3A] = output ptr, [+0x3E] = radix
	; ultoa(unsigned long value, char *buf, int radix); returns XHL = buf.
	; Digits come from HDAE5000_UMod32 (remainder) and HDAE5000_UDivMod32
	; (quotient), i.e. the conversion is unsigned.
HDAE5000_ULToA:
	lda xsp, (xsp - 46)		; allocate 46-byte frame
	push xiz			; save XIZ
	cpw (xsp + 0x3E), 0x0002	; radix < 2?
	jr lt, .Lccb_invalid		; → invalid
	cpw (xsp + 0x3E), 0x0024	; radix > 36?
	jr le, .Lccb_start		; → valid
.Lccb_invalid:
	ld xwa, (xsp + 0x3A)		; XWA = output buffer
	ld (xwa), 0x00		; output empty string
	jr t, .Lccb_conv_done		; → exit
.Lccb_start:
	lda xwa, (xsp + 0x10)		; XWA = &local scratch
	ld (xsp + 8), xwa		; save scratch base ptr
	ld (xwa + 0x20), 0x00	; null-terminate scratch[32]
	ld xwa, (xsp + 8)		; reload scratch ptr
	lda xwa, (xwa + 0x1F)		; XWA = &scratch[31] (digit fill ptr)
	ld (xsp + 4), xwa		; save digit ptr
	ld xiz, (xsp + 0x36)		; XIZ = value to convert
.Lccb_digit_loop:
	ld wa, (xsp + 0x3E)		; WA = radix
	exts xwa			; sign-extend radix to XWA
	ld (xsp + 0x0C), xwa		; save 32-bit radix
	ld xwa, xiz			; XWA = current value
	ld xbc, (xsp + 0x0C)		; XBC = radix
	call HDAE5000_UMod32	; XHL = remainder (value % radix)
	add l, 0x30			; convert remainder to ASCII '0'-'9'
	ld xwa, (xsp + 4)		; reload digit ptr
	ld (xwa), l			; store digit char
	cp (xwa), 0x39		; digit > '9'?
	jr le, .Lccb_digit_ok		; → it's 0-9
	addmi8 (xwa), 0x27		; adjust for 'a'-'f' (+0x27)
.Lccb_digit_ok:
	ld xwa, xiz			; XWA = current value
	ld xbc, (xsp + 0x0C)		; XBC = radix
	call HDAE5000_UDivMod32	; XHL = quotient
	ld xiz, xhl			; XIZ = new quotient
	or xiz, xiz			; quotient == 0?
	jr z, .Lccb_copy_result	; → all digits extracted
	ld xwa, 1:i3			; XWA = 1
	sub (xsp + 4), xwa		; digit ptr-- (move backward)
	jr t, .Lccb_digit_loop		; → next digit
.Lccb_copy_result:
	ld xwa, (xsp + 8)		; reload scratch base
	lda xwa, (xwa + 0x21)		; XWA = &scratch[33] (past null-terminator)
	sub xwa, (xsp + 4)		; XWA = string length
	push xwa			; push length
	ld xwa, (xsp + 8)		; reload digit ptr
	push xwa			; push source
	ld xwa, (xsp + 0x42)		; XWA = output buffer (deep stack offset)
	push xwa			; push destination
	call HDAE5000_MemCopy		; copy digits to output
	lda xsp, (xsp + 0x0C)		; cleanup 12 bytes
.Lccb_conv_done:
	ld xhl, (xsp + 0x3A)		; XHL = output buffer (return value)
	pop xiz				; restore XIZ
	lda xsp, (xsp + 0x2E)		; deallocate 46-byte frame
	ret

; ---------------------------------------------------------------------------
; memccpy(dest, src, c, n): p = HDAE5000_MemChr(src, c, n); copies
; (p ? p - src + 1 : n) bytes with HDAE5000_MemCopy.  NOTE the return value is
; p itself -- the position of c in SRC, or 0 -- not the ISO pointer into
; dest; HDAE5000_StrCpy only tests it against 0.
; In:  (xsp+4) = dest, (xsp+8) = src, (xsp+12) = c (word), (xsp+14) = n (word)
; Out: XHL = p.  IZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_MemCCpy:
	dec 4, xsp
	pushw iz
	ld iz, (xsp + 0x14)
	pushw iz
	pushm (xsp + 0x14)
	ld xwa, (xsp + 0x12)
	push xwa
	call HDAE5000_MemChr
	inc 8, xsp
	ld (xsp + 2), xhl
	ld xwa, (xsp + 2)
	or xwa, xwa
	jr nz, .Lscn_found
	pushw iz
	jr t, .Lscn_copy
.Lscn_found:
	ld xwa, (xsp + 2)
	sub xwa, (xsp + 0x0E)
	inc 1, xwa
	pushw wa
.Lscn_copy:
	ld xwa, (xsp + 0x10)
	push xwa
	ld xwa, (xsp + 0x10)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0A)
	ld xhl, (xsp + 2)
	popw iz
	inc 4, xsp
	ret

; ---------------------------------------------------------------------------
; memchr(s, c, n) with CPIR.
; In:  (xsp+4) = s, (xsp+8) = c (low byte of the word), (xsp+10) = n (word)
; Out: XHL = pointer to the first c, or 0 (also for n = 0).  Clobbers BC, WA.
; ---------------------------------------------------------------------------
HDAE5000_MemChr:
	ld xhl, 0:i3
	ld bc, (xsp + 0x0A)
	cp bc, 0:i3
	ret z
	ld xhl, (xsp + 4)
	ld wa, (xsp + 8)
	cpir83
	dec 1, xhl
	ret z
	ld xhl, 0:i3
	ret

; ---------------------------------------------------------------------------
; memcmp(p1, p2, n): byte compares up to a 4-byte boundary of p1, then long
; compares, then the 0-3 remaining bytes.
; In:  (xsp+4) = p1, (xsp+8) = p2, (xsp+12) = n (word)
; Out: HL = 0 when equal (or n = 0, or p1 = p2), else the difference of the
;      first differing bytes (unsigned bytes, signed result).
;      Clobbers XIX, XIY, XWA, BC, DE.
; ---------------------------------------------------------------------------
HDAE5000_MemCmp:
	ld bc, (xsp + 12)
	ld hl, 0:i3
	cp bc, 0:i3
	ret z
	ld xix, (xsp + 4)
	ld xiy, (xsp + 8)
	cp xix, xiy
	ret z
	ld de, ix
	neg de
	and de, 0x0003
	jr z, .Lfr_aligned
.Lfr_byte_loop1:
	ld l, (xix+)
	extz hl
	ld a, (xiy+)
	extz wa
	sub hl, wa
	ret nz
	sub bc, 0x0001
	ret z
	djnz16 de, .Lfr_byte_loop1
.Lfr_aligned:
	ld de, bc
	srl bc, 2
	jr z, .Lfr_remainder
.Lfr_word_loop:
	ld xhl, (xix+)
	ld xwa, (xiy+)
	cp xhl, xwa
	jr z, .Lfr_word_next
	; Words differ — find which byte differs
	cp hl, wa
	jr nz, .Lfr_check_byte
	ld hl, qhl
	ld wa, qwa
.Lfr_check_byte:
	cp l, a
	jr nz, .Lfr_found_diff
	ld l, h
	ld a, w
.Lfr_found_diff:
	extz hl
	extz wa
	sub hl, wa
	ret
.Lfr_word_next:
	djnz16 bc, .Lfr_word_loop
	ld hl, 0:i3
.Lfr_remainder:
	and de, 0x0003
	ret z
.Lfr_byte_loop2:
	ld l, (xix+)
	extz hl
	ld a, (xiy+)
	extz wa
	sub hl, wa
	ret nz
	djnz16 de, .Lfr_byte_loop2
	ret

; ----------------------------------------------------------------------------
; Memory Utility Routines (0x29AE9F - 0x29AF2C)
;
; Optimized memory manipulation functions used throughout HDAE5000 firmware.
; All routines take parameters on the stack (C calling convention).
; ----------------------------------------------------------------------------

; ---------------------------------------------------------------------------
; memcpy(dest, src, n), n a 16-bit count: returns at once when n = 0 or
; src = dest; otherwise copies one byte to word-align dest, then words with
; LDIRW, then the odd last byte.  Forward copy only (no overlap check).
; In:  (xsp+4) = dest, (xsp+8) = src, (xsp+12) = n (word)
; Out: XHL = dest.  Clobbers XIX, XIY, BC.
; ---------------------------------------------------------------------------
HDAE5000_MemCopy:
	ld bc, (xsp + 12)	; ld BC, (XSP+0x0C) - count
	ld xhl, (xsp + 4)	; ld XHL, (XSP+0x04) - dest
	cp bc, 0:i3
	ret z	; Return if count = 0
	ld xix, xhl	; XIX = dest
	ld xiy, (xsp + 8)	; ld XIY, (XSP+0x08) - src
	cp xix, xiy
	ret z	; Return if src = dest
	bit 0, ix	; check odd alignment
	jr z, HDAE5000_MemCopy__copy_words
	ldi85	; ldi - copy one byte
	ret nov	; ret PO - return if count exhausted
HDAE5000_MemCopy__copy_words:
	srl bc, 1	; srl 1, BC - divide count by 2
	jr z, HDAE5000_MemCopy__check_odd
	ldirw			; 95 11: copy BC words from (XIY+) to (XIX+)
HDAE5000_MemCopy__check_odd:
	ret nc	; return if no odd byte
	ldi85	; ldi - copy final odd byte
	ret

; ---------------------------------------------------------------------------
; memset(dest, c, n), n a 16-bit count: byte stores up to the next 4-byte
; boundary of dest, then 32-bit stores of c replicated (via QWA), then the
; 0-3 remaining bytes.  Returns at once when n = 0.
; In:  (xsp+4) = dest, (xsp+8) = c (low byte of the word), (xsp+10) = n (word)
; Out: XHL = dest.  Clobbers XIX, XWA, BC, DE.
; ---------------------------------------------------------------------------
HDAE5000_MemFill:
	ld bc, (xsp + 10)	; ld BC, (XSP+0x0A) - count
	ld xhl, (xsp + 4)	; ld XHL, (XSP+0x04) - dest
	cp bc, 0:i3
	ret z	; Return if count = 0
	ld xix, xhl	; XIX = dest
	ld wa, (xsp + 8)	; ld WA, (XSP+0x08) - fill value in A
	ld de, ix	; DE = low word of dest address
	neg de	; Negate for alignment calc
	and de, 0x3	; DE = bytes to align (0-3)
	jr z, HDAE5000_MemFill__aligned
HDAE5000_MemFill__align_loop:
	ld (xix+), a	; store byte
	sub bc, 0x1	; sub BC, 1 - decrement count
	ret z	; Return if done
	djnz16 de, HDAE5000_MemFill__align_loop	; djnz DE, .align_loop
HDAE5000_MemFill__aligned:
	ld de, bc	; Save count for remainder calc
	srl bc, 2	; srl 2, BC - divide by 4
	jr z, HDAE5000_MemFill__remainder
	ld w, a	; W = A (fill byte)
	ldfr_werp WA, 0xE2	; ld QWA, WA - expand to 32-bit
HDAE5000_MemFill__fill_dwords:
	ld (xix+), XWA	; store 4 bytes
	djnz16 bc, HDAE5000_MemFill__fill_dwords	; djnz BC, .fill_dwords
HDAE5000_MemFill__remainder:
	and de, 0x3	; DE = remaining bytes (0-3)
	ret z	; Return if none
HDAE5000_MemFill__fill_bytes:
	ld (xix+), a
	djnz16 de, HDAE5000_MemFill__fill_bytes	; djnz DE, .fill_bytes
	ret

; ---------------------------------------------------------------------------
; strcat(dest, src): walks to dest's terminator, then copies src after it and
; terminates the result.
; In:  (xsp+4) = dest, (xsp+8) = src
; Out: XHL = dest.  Clobbers XBC, XDE, A.
; ---------------------------------------------------------------------------
HDAE5000_StrCat:
	ld xde, (xsp + 4)	; ld XDE, (XSP+0x04) - dest
	ld xhl, xde	; Save original dest
	jr HDAE5000_StrCat__find_end
HDAE5000_StrCat__find_loop:
	inc 1, xde
HDAE5000_StrCat__find_end:
	cp (xde), 0x0	; cp (XDE), 0 - check for null
	jr nz, HDAE5000_StrCat__find_loop
	ld xbc, (xsp + 8)	; ld XBC, (XSP+0x08) - src
	jr HDAE5000_StrCat__copy_check
HDAE5000_StrCat__copy_loop:
	ld A, (xbc+)	; read src byte
	ld (xde+), a	; write to dest
HDAE5000_StrCat__copy_check:
	cp (xbc), 0x0	; cp (XBC), 0 - check for null
	jr nz, HDAE5000_StrCat__copy_loop
	ld (xde), 0x0	; ld (XDE), 0 - write null terminator
	ret

; ----------------------------------------------------------------------------
; Remaining Code and Data (0x29AF2D - 0x2FA134)
; Contains additional utility routines, lookup tables, and data:
;   - String manipulation utilities (strlen, strncpy, etc.)
;   - Memory utilities (compare, search)
;   - Number formatting (itoa, hex conversion)
;   - 32-bit multiply routine (0x29B72D)
;   - UI configuration tables
;   - Graphics/image data
;
; Followed by 24,267 bytes of zero padding (0x2FA135 - 0x2FFFFF)
; ----------------------------------------------------------------------------

