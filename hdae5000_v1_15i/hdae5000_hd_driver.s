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
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_HamaFnTable)             ; e3 e1 88 0e 20
	ld xix, (xwa + HamaFn_GetMediaType)				; a8 08 24
	call (xix)					; b4 e8
	cp l, 3:i3					; cf db
	jr z, .Lsd_status_ok				; 66 05
	cp l, 2:i3					; cf da
	jrl nz, .Lsd_not_ready			; 7e 49 02
.Lsd_status_ok:
	; Register event 0xD2 via vtable 0x0124
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_CP_FD				; 40 d4 00 7f 00
	ld xbc, EVT_SHOW				; 41 01 00 c0 01
	ld xde, 0xffffffff				; 42 ff ff ff ff
	call (xhl)					; b3 e8
	calr HDAE5000_FdList_Clear			; 1e 5b fe
	; Get drive info via 0x0e88.0x0090 vtable
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
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
	call HDAE5000_StrLen					; 1d 39 a8 29
	pushw hl                                ; push hl (compact)
	ld xwa, xiz					; ee 88
	push xwa					; 38
	lda xwa, (HDAE5000_RAM_FdList:24); f2 9c aa 22 30
	push xwa					; 38
	call HDAE5000_MemCopy					; 1d 67 a7 29
	lda xsp, (xsp + 0x0e)			; bf 0e 37
.Lsd_skip_copy:
	; Register event 0xDE via vtable, with 0x22aa9c as data
	lda xwa, (HDAE5000_RAM_FdList:24); f2 9c aa 22 30
	ld xde, xwa					; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL				; 40 e0 00 7f 00
	ld	xbc, 0x01ea0009
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL				; 40 e0 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 0xffffffff				; 42 ff ff ff ff
	call (xhl)					; b3 e8
	; Identify drive: call via 0x0e88.0x0094
	lda xwa, (HDAE5000_Str_AllFilesPattern:24); f2 c2 1a 2e 30
	ld xde, xwa					; e8 8a
	lda xwa, (xsp + 0x06)			; bf 06 30
	ld xbc, xwa					; e8 89
	ld xwa, xde					; ea 88
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 22
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
	call HDAE5000_MemCopy					; 1d 67 a7 29
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
	call HDAE5000_MemCopy					; 1d 67 a7 29
	lda xsp, (xsp + 0x0a)			; bf 0a 37
.Lsd_loop_done:
	; Get next partition via 0x0e88.0x0098
	lda xwa, (xsp + 0x06)			; bf 06 30
	ld xbc, xwa					; e8 89
	ld xwa, xiz					; ee 88
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 22
	ld xde, (xde + WS_HamaFnTable)             ; e3 e9 88 0e 22
	ld_sril xix, (xde + HamaFn__findnext)             ; e3 e9 98 00 24
	call (xix)					; b4 e8
	cp hl, 0:i3					; db d8
	jr z, .Lsd_retry				; 66 a7
	; Cleanup: call via 0x0e88.0x009c
	ld xwa, xiz					; ee 88
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 21
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
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LIST				; 40 d9 00 7f 00
	ld	xbc, 0x01ea0009
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LIST				; 40 d9 00 7f 00
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	ld xde, 0xffffffff				; 42 ff ff ff ff
	call (xhl)					; b3 e8
	; Register event 0xD9 + 0xD8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LINE1				; 40 db 00 7f 00
	ld xbc, EVT_DRAW				; 41 0d 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LINE2				; 40 da 00 7f 00
	ld xbc, EVT_DRAW				; 41 0d 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
	jr t, .Lsd_epilogue				; 68 0a
.Lsd_not_ready:
	; Disk not ready: call shutdown with error code 2
	ld wa, 2:i3					; d8 aa
	calr HDAE5000_ShowErrorMessageTitle			; 1e c4 76
	ldw	(xsp+4), 0xffff
.Lsd_epilogue:
	ld hl, (xsp + 0x04)				; 9f 04 23
	pop xiz					; 5e
	lda xsp, (xsp+268)	; lda xsp, (xsp + 0x010c) — dealloc frame
	ret						; 0e
	; --- Sub-handler 1: event 0x01C00007 dispatch (0x28310D) ---
HDAE5000_HDDTitleSwCatch:
	; registered as "HDDTitleSwCatch" in HDAE5000_ScreenProc_Table
	cp xbc, EVT_SW_IN				; e9 cf 07 00 c0 01
	jr nz, .Lsd_sub1_done			; 6e 63
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xix, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 24
	ld xwa, 0x02600024				; 40 24 00 60 02
	ld xbc, EVT_MAKE_EDIT_SW_ID				; 41 29 00 e0 01
	call (xix)					; b4 e8
	cp xhl, 0x0000000a				; eb cf 0a 00 00 00
	jr z, .Lsd_sub1_evt_0a			; 66 34
	cp xhl, 0x0000008a				; eb cf 8a 00 00 00
	jr nz, .Lsd_sub1_done			; 6e 38
	; Event 0x8A: check 0x229d99 config
	cp (HDAE5000_RAM_WriteProtect:24), 0x00; c2 99 9d 22 3f 00
	jr nz, .Lsd_sub1_configured			; 6e 05
	calr HDAE5000_FdList_Scan			; 1e 42 fd — recursive setup
	jr t, .Lsd_sub1_done				; 68 2b
.Lsd_sub1_configured:
	; Already configured: register event 0x024A
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_ATTEN_CPHD_WR				; 40 49 02 7f 00
	ld xbc, EVT_SHOW				; 41 01 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
	jr t, .Lsd_sub1_done				; 68 0c
.Lsd_sub1_evt_0a:
	; Event 0x0A: init filesystem
	pushw 0x0000					; 0b 00 00
	ld wa, 0:i3					; d8 a8
	ld bc, 0:i3					; d9 a8
	ld de, 6:i3					; da ae
	calr HDAE5000_Lbn_ShowEntry				; 1e 26 3a
.Lsd_sub1_done:
	ld xhl, 0:i3					; eb a8
	ret						; 0e
	; --- Sub-handler 2: event handler for 0xD9 (0x28317B) ---
HDAE5000_AttenCpToHDSwCatch:
	; registered as "AttenCpToHDSwCatch" in HDAE5000_ObjHandler_Table
	push xiz					; 3e
	ld xiz, xwa					; e8 8e
	ld xwa, xbc					; e9 88
	cp xwa, EVT_SW_IN				; e8 cf 07 00 c0 01
	jr z, .Lsd_sub2_c00007			; 66 63
	cp xwa, EVT_DRAW				; e8 cf 0d 00 c0 01
	jr z, .Lsd_sub2_c0000d			; 66 23
	cp xwa, EVT_ARE_YOU_CLASS_PROC				; e8 cf 85 00 e0 01
	jr z, .Lsd_sub2_e00085			; 66 16
	; Default: call cleanup callback
	ld xwa, xiz					; ee 88
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 23
	ld xhl, (xhl + WS_RootFnTable)             ; e3 ed 0a 0e 23
	ld_sril xix, (xhl + RootFn_InheritedProc)             ; e3 ed dc 00 24
	call (xix)					; b4 e8
	jrl t, .Lsd_sub2_done				; 78 87 00
.Lsd_sub2_e00085:
	ld xhl, 1:i3					; eb a9
	jrl t, .Lsd_sub2_done				; 78 82 00
.Lsd_sub2_c0000d:
	; Forward event via vtable
	ld xwa, xiz					; ee 88
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 23
	ld xhl, (xhl + WS_RootFnTable)             ; e3 ed 0a 0e 23
	ld_sril xhl, (xhl + RootFn_InheritedProc)             ; e3 ed dc 00 23
	call (xhl)					; b3 e8
	lda xwa, (HDAE5000_Str_Cphd:24); f2 c6 1a 2e 30
	ld xbc, xwa					; e8 89
	ld xwa, xiz					; ee 88
	ld xde, xbc					; e9 8a
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 21
	ld xbc, (xbc + WS_RootFnTable)             ; e3 e5 0a 0e 21
	ld_sril xhl, (xbc + RootFn_SendEvent)             ; e3 e5 00 01 23
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	call (xhl)					; b3 e8
	ld xhl, 0:i3					; eb a8
	jr t, .Lsd_sub2_done				; 68 4a
.Lsd_sub2_c00007:
	; Check for events 0x07 or 0x06
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xix, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 24
	ld xwa, 0x02600024				; 40 24 00 60 02
	ld xbc, EVT_MAKE_EDIT_SW_ID				; 41 29 00 e0 01
	call (xix)					; b4 e8
	cp xhl, 0x00000007				; eb cf 07 00 00 00
	jr z, .Lsd_sub2_deregister			; 66 08
	cp xhl, 0x00000006				; eb cf 06 00 00 00
	jr nz, .Lsd_sub2_skip_dereg			; 6e 1d
.Lsd_sub2_deregister:
	; Deregister event via vtable 0x0104
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_PostEvent)             ; e3 e1 04 01 23
	ld xwa, HDAE5000_OBJ_HDDMENU				; 40 00 00 7f 00
	ld xbc, EVT_SHOW				; 41 01 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
.Lsd_sub2_skip_dereg:
	ld xhl, 0:i3					; eb a8
.Lsd_sub2_done:
	pop xiz					; 5e
	ret						; 0e
	; --- Sub-handler 3: event handler for 0xD8 (0x283237) ---
HDAE5000_AttenCpToMarkSwCatch:
	; registered as "AttenCpToMarkSwCatch" in HDAE5000_ObjHandler_Table
	push xiz					; 3e
	ld xiz, xwa					; e8 8e
	ld xwa, xbc					; e9 88
	cp xwa, EVT_SW_IN				; e8 cf 07 00 c0 01
	jr z, .Lsd_sub3_c00007			; 66 63
	cp xwa, EVT_DRAW				; e8 cf 0d 00 c0 01
	jr z, .Lsd_sub3_c0000d			; 66 23
	cp xwa, EVT_ARE_YOU_CLASS_PROC				; e8 cf 85 00 e0 01
	jr z, .Lsd_sub3_e00085			; 66 16
	; Default: call cleanup callback
	ld xwa, xiz					; ee 88
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 23
	ld xhl, (xhl + WS_RootFnTable)             ; e3 ed 0a 0e 23
	ld_sril xix, (xhl + RootFn_InheritedProc)             ; e3 ed dc 00 24
	call (xix)					; b4 e8
	jrl t, .Lsd_sub3_done				; 78 87 00
.Lsd_sub3_e00085:
	ld xhl, 1:i3					; eb a9
	jrl t, .Lsd_sub3_done				; 78 82 00
.Lsd_sub3_c0000d:
	; Forward event via vtable
	ld xwa, xiz					; ee 88
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 23
	ld xhl, (xhl + WS_RootFnTable)             ; e3 ed 0a 0e 23
	ld_sril xhl, (xhl + RootFn_InheritedProc)             ; e3 ed dc 00 23
	call (xhl)					; b3 e8
	lda xwa, (HDAE5000_Str_Cphd_AttenCpToMarkSwCatch:24); f2 cc 1a 2e 30
	ld xbc, xwa					; e8 89
	ld xwa, xiz					; ee 88
	ld xde, xbc					; e9 8a
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 21
	ld xbc, (xbc + WS_RootFnTable)             ; e3 e5 0a 0e 21
	ld_sril xhl, (xbc + RootFn_SendEvent)             ; e3 e5 00 01 23
	ld xbc, EVT_PARA_DRAW				; 41 0f 00 c0 01
	call (xhl)					; b3 e8
	ld xhl, 0:i3					; eb a8
	jr t, .Lsd_sub3_done				; 68 4a
.Lsd_sub3_c00007:
	; Check for events 0x07 or 0x06
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld_sril xix, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 24
	ld xwa, 0x02600024				; 40 24 00 60 02
	ld xbc, EVT_MAKE_EDIT_SW_ID				; 41 29 00 e0 01
	call (xix)					; b4 e8
	cp xhl, 0x00000007				; eb cf 07 00 00 00
	jr z, .Lsd_sub3_deregister			; 66 08
	cp xhl, 0x00000006				; eb cf 06 00 00 00
	jr nz, .Lsd_sub3_skip_dereg			; 6e 1d
.Lsd_sub3_deregister:
	; Deregister event 0xD2 via vtable 0x0104
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_PostEvent)             ; e3 e1 04 01 23
	ld xwa, HDAE5000_OBJ_CP_FD				; 40 d4 00 7f 00
	ld xbc, EVT_SHOW				; 41 01 00 c0 01
	ld xde, 0:i3					; ea a8
	call (xhl)					; b3 e8
.Lsd_sub3_skip_dereg:
	ld xhl, 0:i3					; eb a8
.Lsd_sub3_done:
	pop xiz					; 5e
	ret						; 0e

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
	lda xwa, (0x22ad72:24); f2 ba ad 22 30
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
	lda xwa, (0x22ada4:24); f2 ec ad 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	ld a, (HDAE5000_RAM_LoadByNumberMode:24)
	extz wa					; d8 12
	pushw wa                                ; push wa (compact 16-bit)
	pushw	HDAE5000_Fmt_d@hi16
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
	lda xwa, (0x22add6:24); f2 1e ae 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	ld a, (HDAE5000_RAM_QuickLoadMode:24)
	extz wa					; d8 12
	pushw wa                                ; push wa (compact 16-bit)
	pushw	HDAE5000_Fmt_d_TitleInfo_Build@hi16
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
	lda xwa, (0x22ad89:24); f2 d1 ad 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	ld a, (HDAE5000_RAM_JumpAfterLoad:24)
	extz wa					; d8 12
	pushw wa                                ; push wa (compact 16-bit)
	pushw	HDAE5000_Fmt_d_TitleInfo_Build_2@hi16
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
	lda xwa, (0x22adbb:24); f2 03 ae 22 30
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
	lda xwa, (0x22aded:24); f2 35 ae 22 30
	push xwa				; 38
	call HDAE5000_MemCopy				; 1d 9f ae 29 — MemCopy
	lda xsp, (xsp + 0x1a)			; bf 1a 37

	; --- Register event handlers ---
	; Register event 0x01EA000A with display buffer
	lda xwa, (HDAE5000_RAM_TitleInfoText:24); f2 a6 ad 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; e3 e1 00 01 23 — ld xhl, (xwa+0x0100)
	ld xwa, HDAE5000_OBJ_HARD_DISK_OPT			; 40 0a 00 7f 00
	ld	xbc, 0x01ea0009
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
HDAE5000_HdTitleEventCatch:
	; registered as "HdTitleEventCatch" in HDAE5000_ObjHandler_Table
	dec 8, xsp				; ef 68 — allocate 4 bytes
	push xiz				; 3e
	ld (xsp + 0x04), xde			; bf 04 62
	ld xiz, xbc				; e9 8e
	ld (xsp + 0x08), xwa			; bf 08 60
	ld xwa, xiz				; ee 88
	cp xwa, EVT_DRAW			; e8 cf 0d 00 c0 01
	jr z, .Lri_evt_000d			; 66 xx
	cp xwa, EVT_ARE_YOU_CLASS_PROC			; e8 cf 85 00 e0 01
	jr z, .Lri_evt_0085			; 66 xx

	; Default: forward to vtable handler at +0x0EDC
	ld xwa, (xsp + 0x08)			; af 08 20
	ld xbc, xiz				; ee 89
	ld xde, (xsp + 0x04)			; af 04 22
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 23
	ld xhl, (xhl + WS_RootFnTable)             ; e3 ed 0a 0e 23 — ld xhl, (xhl+0x0e0a)
	ld_sril xix, (xhl + RootFn_InheritedProc)             ; e3 ed dc 00 24 — ld xix, (xhl+0x00dc)
	call (xix)				; b4 e8
	jr t, .Lri_evt_done			; 68 xx

.Lri_evt_0085:
	ld xhl, 1:i3				; eb a9
	jr t, .Lri_evt_done			; 68 xx

.Lri_evt_000d:
	calr HDAE5000_TitleInfo_Build		; 1e xx xx — recursive self-call
	ld xwa, (xsp + 0x08)			; af 08 20
	ld xbc, xiz				; ee 89
	ld xde, (xsp + 0x04)			; af 04 22
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 23
	ld xhl, (xhl + WS_RootFnTable)             ; e3 ed 0a 0e 23 — ld xhl, (xhl+0x0e0a)
	ld_sril xhl, (xhl + RootFn_InheritedProc)             ; e3 ed dc 00 23 — ld xhl, (xhl+0x00dc)
	call (xhl)				; b3 e8
	; Re-register event 0x01C0000F with new handler
	lda xwa, (HDAE5000_Str_HDAE:24); f2 90 1b 2e 30
	ld xbc, xwa				; e8 89
	ld xwa, (xsp + 0x08)			; af 08 20
	ld xde, xbc				; e9 8a
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 21
	ld xbc, (xbc + WS_RootFnTable)             ; e3 e5 0a 0e 21 — ld xbc, (xbc+0x0e0a)
	ld_sril xhl, (xbc + RootFn_SendEvent)             ; e3 e5 00 01 23 — ld xhl, (xbc+0x0100)
	ld xbc, EVT_PARA_DRAW			; 41 0f 00 c0 01
	call (xhl)				; b3 e8
	ld xhl, 0:i3				; eb a8

.Lri_evt_done:
	pop xiz					; 5e
	inc 8, xsp				; ef 60
	ret					; 0e

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
	ld (0x22adf4:24), 0x00; f2 3c ae 22 00 00
	lda xwa, (HDAE5000_RAM_TitleInfoText:24); f2 a6 ad 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_HARD_DISK_OPT			; 40 0a 00 7f 00
	ld	xbc, 0x01ea0009
	call (xhl)				; b3 e8
	ld wa, 0:i3				; d8 a8
	ld bc, 0:i3				; d9 a8
	calr HDAE5000_SongScreen_Refresh		; 1e xx xx

	ld (0x22aa02:24), 0x00; f2 4a aa 22 00 00
	lda xwa, (HDAE5000_RAM_FlsListText:24); f2 ca a2 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_SEL_FLS			; 40 fd 00 7f 00
	ld	xbc, 0x01ea0009
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
	ld	xbc, 0x01ea0009
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
	ld	xbc, 0x01ea0009
	call (xhl)				; b3 e8

	; Set initial disk status
	ld xwa, HDAE5000_OBJ_HDDMENU			; 40 00 00 7f 00
	ld	(0x23d2d2), xwa
	cp (0x22ad52:24), 0x01; c2 9a ad 22 3f 01
	jrl nz, .Lri_done			; 7e xx xx
	cp (0x22ad53:24), 0x01; c2 9b ad 22 3f 01
	jrl nz, .Lri_done			; 7e xx xx
	ld xwa, HDAE5000_OBJ_FLS_FILE_LOAD			; 40 3c 01 7f 00
	ld	(0x23d2d2), xwa
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
	ld	(0x23d2d2), xwa
	jrl t, .Lri_done			; 78 xx xx

.Lri_case9_cyl2:
	ld xwa, HDAE5000_OBJ_LOAD_BY_NUM			; 40 91 00 7f 00
	ld	(0x23d2d2), xwa
	jrl t, .Lri_done			; 78 xx xx

.Lri_case9_cyl3:
	ld xwa, HDAE5000_OBJ_FLS_FILE_LOAD			; 40 3c 01 7f 00
	ld	(0x23d2d2), xwa
	jrl t, .Lri_done			; 78 xx xx

	; === Case 8: dispatch event to sub-device ===
.Lri_case8:
	ld	xwa, (0x23d2d2:24)
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

	; Check disk presence flags
	cp (0x22ad52:24), 0x01; c2 9a ad 22 3f 01
	jr nz, .Lri_done			; 6e xx
	cp (0x22ad53:24), 0x01; c2 9b ad 22 3f 01
	jr nz, .Lri_done			; 6e xx

	; Clear flag and register event 0x01CA0000
	ld (0x22ad53:24), 0x00; f2 9b ad 22 00 00
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
	ld	(0x23d2d2), xwa

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
	pushw	HDAE5000_Fmt_3_3d@hi16
	pushw	HDAE5000_Fmt_3_3d@lo16		; low half of HDAE5000_Fmt_3_3d
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
	ld	xbc, 0x01ea0009
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
; INFERENCE (not proven by this ROM): the 0x01EA000n codes index
; HDAE5000_MessageName_Table, giving n=0 MT_OverFlow, n=1 MT_UnderFlow,
; n=3 MT_SetSelNum, n=6/7 MT_SelectOK/MT_SelectOK2, n=8 MT_SelectSAVE.  The
; clamp arithmetic matches OverFlow/UnderFlow, but the main CPU assigns the
; codes and this ROM never spells the mapping out.  The per-arm comments
; below ("page down", "page up", "seek", "set format params") predate this
; note and have NOT been re-verified.
; Dispatches 0x01EA0000, 0x01EA0001, 0x01EA0006, 0x01EA0007, 0x01EA0008 and
; 0x01C00007; every other code falls straight through to .Lfd_done.
HDAE5000_SEL_DIR_Screen:
	push xiz
	ld xiz, xde			; save XDE in XIZ

	; Dispatch on event code in XBC
	cp xbc, EVT_HDAE_OVER_FLOW
	jrl z, .Lfd_page_down		; 0x01EA0000 = page down
	cp xbc, EVT_HDAE_UNDER_FLOW
	jrl z, .Lfd_page_up		; 0x01EA0001 = page up
	cp xbc, EVT_HDAE_SELECT_SAVE
	jrl z, .Lfd_seek		; 0x01EA0008 = seek
	cp xbc, EVT_HDAE_SELECT_OK2
	jrl z, .Lfd_set_format		; 0x01EA0007 = set format params
	cp xbc, EVT_HDAE_SELECT_OK
	jrl z, .Lfd_set_format		; 0x01EA0006 = same handler
	cp xbc, EVT_SW_IN
	jrl nz, .Lfd_done		; not 0x01C00007 → exit

	; --- Handle 0x01C00007: UI navigation ---
	ld xde, xiz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)             ; XWA = (XWA + 0x0e0a)
	ld_sril xix, (xwa + RootFn_SendEvent)             ; XIX = (XWA + 0x0100)
	ld xwa, 0x02600024
	ld xbc, EVT_MAKE_EDIT_SW_ID
	call (xix)			; call UI handler

	; Dispatch on XHL return value
	cp xhl, 0x00000007
	jr z, .Lfd_nav_case7
	cp xhl, 0x00000006
	jr z, .Lfd_nav_case6
	cp xhl, 0x00000005
	jr z, .Lfd_nav_case5
	cp xhl, 0x00000001
	jr z, .Lfd_nav_case1
	or xhl, xhl
	jrl nz, .Lfd_done		; XHL != 0 → exit

	; Case 0: offset = 0x0000
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0000
	ld xwa, HDAE5000_OBJ_SEL_DIR
	calr HDAE5000_DirList_BuildPage
	jrl t, .Lfd_done

.Lfd_nav_case1:
	; Case 1: offset = 0x0018
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0018
	ld xwa, HDAE5000_OBJ_SEL_DIR
	calr HDAE5000_DirList_BuildPage
	jrl t, .Lfd_done

.Lfd_nav_case5:
	; Case 5: offset = 0x0030
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0030
	ld xwa, HDAE5000_OBJ_SEL_DIR
	calr HDAE5000_DirList_BuildPage
	jrl t, .Lfd_done

.Lfd_nav_case6:
	; Case 6: offset = 0x0048
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0048
	ld xwa, HDAE5000_OBJ_SEL_DIR
	calr HDAE5000_DirList_BuildPage
	jrl t, .Lfd_done

.Lfd_nav_case7:
	; Case 7: offset = 0x0060
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0060
	ld xwa, HDAE5000_OBJ_SEL_DIR
	calr HDAE5000_DirList_BuildPage
	jrl t, .Lfd_done

.Lfd_set_format:
	; Handle 0x01EA0006/0007: set format parameters
	ld bc, (HDAE5000_RAM_DirPageBase:24); BC = base offset
	ld wa, iz
	add wa, bc
	ld (HDAE5000_RAM_CurDir:24), wa; store new position
	ld wa, 0:i3			; WA = 0
	ld bc, 0:i3			; BC = 0
	calr HDAE5000_SongScreen_Refresh	; call HD read/write

	; Notify UI
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; XHL = vtable method
	ld xwa, HDAE5000_OBJ_SELECT_FILE
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jrl t, .Lfd_done

.Lfd_seek:
	; Handle 0x01EA0008: seek operation
	ld wa, (HDAE5000_RAM_DirPageBase:24); WA = base offset
	ld bc, iz
	add bc, wa
	ld (HDAE5000_RAM_CurDir:24), bc; store seek position
	ld wa, bc
	call HDAE5000_DirName_Address			; XHL = sector address
	ld xde, xhl

	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApFuncCall)             ; XHL = (XWA + 0x0250) vtable method
	ld xwa, NAKA_APFUNC_HDD_DIRNAMECheck
	ld xbc, EVT_SET_STRING
	call (xhl)

	; Send completion notification
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_HDD_DIR_NAMING
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jr t, .Lfd_done

.Lfd_page_up:
	; Handle 0x01EA0001: page up
	cpw (HDAE5000_RAM_DirPageBase:24), 0x0018
	jr lt, .Lfd_done		; already at minimum
	subw (HDAE5000_RAM_DirPageBase:24), 0x0018; subtract 24 from offset
	ld xwa, HDAE5000_OBJ_SEL_DIR
	calr HDAE5000_DirList_BuildPage
	; Calculate new entry index
	ld xwa, xiz
	add xwa, 0x00000018
	ld xde, xwa

	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_SEL_DIR
	ld xbc, EVT_HDAE_SET_SEL_NUM
	call (xhl)
	jr t, .Lfd_done

.Lfd_page_down:
	; Handle 0x01EA0000: page down
	cpw (HDAE5000_RAM_DirPageBase:24), 0x0060
	jr ge, .Lfd_done		; already at maximum
	addw (HDAE5000_RAM_DirPageBase:24), 0x0018; add 24 to offset
	ld xwa, HDAE5000_OBJ_SEL_DIR
	calr HDAE5000_DirList_BuildPage
	; Calculate new entry index
	ld xwa, xiz
	sub xwa, 0x00000018
	ld xde, xwa

	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_SEL_DIR
	ld xbc, EVT_HDAE_SET_SEL_NUM
	call (xhl)

.Lfd_done:
	ld xhl, 0:i3
	pop xiz
	ret

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
HDAE5000_PartList_Build:
	dec 4, xsp			; allocate 4 bytes
	pushw iz                                ; push iz (compact 1-byte form)
	ld (xsp + 0x02), xwa		; save the list object
	ld iz, (xsp + 0x0a)		; IZ = part mask

	; --- no directory or no song (0xFFFF): blank list ---
	cp bc, 0xffff
	jr z, .Lhsk_bc_invalid
	cp de, 0xffff
	jr nz, .Lhsk_check_bits

.Lhsk_bc_invalid:
	pushw 0x0071
	lda xwa, (HDAE5000_PartNames_BlankText:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)
	jrl	t, .Lhsk_epilogue_vtable

.Lhsk_check_bits:
	pushw 0x0071
	lda xwa, (HDAE5000_PartNames_Text:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)

	cp iz, 0xffff
	jrl	z, .Lhsk_iz_invalid

	; --- Bit 0 ---
	bit 0, iz
	jr nz, .Lhsk_bit1
	pushw 0x000e
	lda xwa, (HDAE5000_PartName_Blank:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)

.Lhsk_bit1:
	bit 1, iz
	jr nz, .Lhsk_bit2
	pushw 0x000e
	lda xwa, (HDAE5000_PartName_Blank:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText+14:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)

.Lhsk_bit2:
	bit 2, iz
	jr nz, .Lhsk_bit3
	pushw 0x000e
	lda xwa, (HDAE5000_PartName_Blank:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText+28:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)

.Lhsk_bit3:
	bit 3, iz
	jr nz, .Lhsk_bit4
	pushw 0x000e
	lda xwa, (HDAE5000_PartName_Blank:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText+42:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)

.Lhsk_bit4:
	bit 4, iz
	jr nz, .Lhsk_bit5
	pushw 0x000e
	lda xwa, (HDAE5000_PartName_Blank:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText+56:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)

.Lhsk_bit5:
	bit 5, iz
	jr nz, .Lhsk_bit6
	pushw 0x000e
	lda xwa, (HDAE5000_PartName_Blank:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText+70:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)

.Lhsk_bit6:
	bit 6, iz
	jr nz, .Lhsk_bit7
	pushw 0x000e
	lda xwa, (HDAE5000_PartName_Blank:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText+84:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)
.Lhsk_bit7:

.Lhsk_bit8:
	bit 7, iz
	jr nz, .Lhsk_epilogue_vtable
	pushw 0x000e
	lda xwa, (HDAE5000_PartName_Blank:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText+98:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)
	jr t, .Lhsk_epilogue_vtable

.Lhsk_iz_invalid:
	pushw 0x0071
	lda xwa, (HDAE5000_PartNames_BlankText:24)
	push xwa
	lda xwa, (HDAE5000_RAM_PartListText:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)

.Lhsk_epilogue_vtable:
	; point the list object at the text, then have it redraw
	lda xwa, (HDAE5000_RAM_PartListText:24)
	ld xbc, xwa
	ld xwa, (xsp + 0x02)		; restore context ptr
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)             ; XBC = (XBC + 0x0e0a)
	ld xhl, (xbc + RootFn_ApPostEvent)             ; XHL = (XBC + 0x0124)
	ld	xbc, 0x01ea0009
	call (xhl)

	ld xwa, (xsp + 0x02)		; restore context ptr
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)             ; XBC = (XBC + 0x0e0a)
	ld xhl, (xbc + RootFn_ApPostEvent)             ; XHL = (XBC + 0x0124)
	ld xbc, EVT_PARA_DRAW
	ld xde, 0xffffffff
	call (xhl)

	; --- Epilogue ---
	popw iz                                 ; pop iz (compact 1-byte form)
	inc 4, xsp
	retd 0x0002

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
	pushw	HDAE5000_RAM_AtaIdentifyBuffer@hi16
	pushw	HDAE5000_RAM_AtaIdentifyBuffer@lo16		; low half of HDAE5000_RAM_AtaIdentifyBuffer
	lda xwa, (HDAE5000_RAM_SongScreenTitle:24)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_DIRECTORY@hi16
	pushw	HDAE5000_Str_DIRECTORY@lo16		; low half of HDAE5000_Str_DIRECTORY
	pushw	HDAE5000_RAM_SongScreenTitle@hi16
	pushw	HDAE5000_RAM_SongScreenTitle@lo16		; low half of HDAE5000_RAM_SongScreenTitle
	call HDAE5000_StrCat
	ld	wa, (HDAE5000_RAM_CurDir:24)
	inc	1, wa
	pushw wa
	pushw	HDAE5000_Fmt_2_2d_SongScreen_Refresh@hi16
	pushw	HDAE5000_Fmt_2_2d_SongScreen_Refresh@lo16		; low half of HDAE5000_Fmt_2_2d_SongScreen_Refresh
	lda	xwa, (xsp+24)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+26)
	lda	xwa, (xsp+2)
	push xwa
	pushw	HDAE5000_RAM_SongScreenTitle@hi16
	pushw	HDAE5000_RAM_SongScreenTitle@lo16		; low half of HDAE5000_RAM_SongScreenTitle
	call HDAE5000_StrCat
	pushw	HDAE5000_Str_Chr3A_SongScreen_Refresh@hi16
	pushw	HDAE5000_Str_Chr3A_SongScreen_Refresh@lo16		; low half of HDAE5000_Str_Chr3A_SongScreen_Refresh
	pushw	HDAE5000_RAM_SongScreenTitle@hi16
	pushw	HDAE5000_RAM_SongScreenTitle@lo16		; low half of HDAE5000_RAM_SongScreenTitle
	call HDAE5000_StrCat
	lda	xsp, (xsp+16)
	pushw 0x0010
	ld	wa, (HDAE5000_RAM_CurDir:24)
	call HDAE5000_DirName_Address
	push xhl
	pushw	HDAE5000_RAM_SongScreenTitle@hi16
	pushw	HDAE5000_RAM_SongScreenTitle@lo16		; low half of HDAE5000_RAM_SongScreenTitle
	call HDAE5000_StrNCat
	pushw	HDAE5000_Str_Blank0Tab@hi16
	pushw	HDAE5000_Str_Blank0Tab@lo16		; low half of HDAE5000_Str_Blank0Tab
	pushw	HDAE5000_RAM_SongScreenTitle@hi16
	pushw	HDAE5000_RAM_SongScreenTitle@lo16		; low half of HDAE5000_RAM_SongScreenTitle
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
	ld	xbc, 0x01ea0009
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
	pushw	HDAE5000_Fmt_2_2d_SongScreen_Refresh_2@hi16
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
	ld	xbc, 0x01ea0009
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

HDAE5000_AttenDelDirSwCatch:
	; registered as "AttenDelDirSwCatch" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_SW_IN
	jr	z, HDAE5000_AttenDelDirSwCatch_OnSwIn
	cp	xwa, EVT_DRAW
	jr	z, HDAE5000_AttenDelDirSwCatch_OnDraw
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jr	z, HDAE5000_AttenDelDirSwCatch_OnAreYouClassProc
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl	t, HDAE5000_AttenDelDirSwCatch_Epilogue
HDAE5000_AttenDelDirSwCatch_OnAreYouClassProc:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_AttenDelDirSwCatch_Epilogue
HDAE5000_AttenDelDirSwCatch_OnDraw:
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_DELD:24)
	ld	xbc, xwa
	ld	xwa, xiz
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AttenDelDirSwCatch_Epilogue
HDAE5000_AttenDelDirSwCatch_OnSwIn:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jr	z, HDAE5000_AttenDelDirSwCatch_Skip
	cp	xhl, 0x00000006
	jr	z, HDAE5000_AttenDelDirSwCatch_Skip
	cp	xhl, 0x00000001
	jr	z, HDAE5000_AttenDelDirSwCatch_Join
	or xhl, xhl
	jr	nz, HDAE5000_AttenDelDirSwCatch_Done
HDAE5000_AttenDelDirSwCatch_Join:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_WAIT_DEL_DIR
	ld	xbc, EVT_SHOW
	ld	xde, 3:i3
	call	(xhl)
	calr	HDAE5000_YieldUntilSem1Zero
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, 1:i3
	ld	de, 0:i3
	call HDAE5000_DeleteDirectory
	ld	xwa, HDAE5000_OBJ_SEL_DIR
	calr	HDAE5000_DirList_BuildPage
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_SongScreen_Refresh
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_SELECT_FILE
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jr	t, HDAE5000_AttenDelDirSwCatch_Done
HDAE5000_AttenDelDirSwCatch_Skip:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_SELECT_FILE
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_AttenDelDirSwCatch_Done:
	ld	xhl, 0:i3
HDAE5000_AttenDelDirSwCatch_Epilogue:
	pop xiz
	ret

HDAE5000_AttenDelFileSwCatch:
	; registered as "AttenDelFileSwCatch" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_SW_IN
	jr	z, HDAE5000_AttenDelFileSwCatch_OnSwIn
	cp	xwa, EVT_DRAW
	jr	z, HDAE5000_AttenDelFileSwCatch_OnDraw
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jr	z, HDAE5000_AttenDelFileSwCatch_OnAreYouClassProc
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl	t, HDAE5000_AttenDelFileSwCatch_Epilogue
HDAE5000_AttenDelFileSwCatch_OnAreYouClassProc:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_AttenDelFileSwCatch_Epilogue
HDAE5000_AttenDelFileSwCatch_OnDraw:
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_DELF:24)
	ld	xbc, xwa
	ld	xwa, xiz
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl	t, HDAE5000_AttenDelFileSwCatch_Epilogue
HDAE5000_AttenDelFileSwCatch_OnSwIn:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jrl	z, HDAE5000_AttenDelFileSwCatch_Skip
	cp	xhl, 0x00000006
	jrl	z, HDAE5000_AttenDelFileSwCatch_Skip
	cp	xhl, 0x00000001
	jr	z, HDAE5000_AttenDelFileSwCatch_Join
	or xhl, xhl
	jrl	nz, HDAE5000_AttenDelFileSwCatch_Done
HDAE5000_AttenDelFileSwCatch_Join:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_WAIT_DEL_FILE
	ld	xbc, EVT_SHOW
	ld	xde, 3:i3
	call	(xhl)
	calr	HDAE5000_YieldUntilSem1Zero
	pushw 0x0001
	pushw 0x0000
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	ld	de, (HDAE5000_RAM_DeleteOptions:24)
	call HDAE5000_DeleteSongParts
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	ld	de, 1:i3
	calr	HDAE5000_DelOpt_InitFromSong
	ld	xwa, HDAE5000_OBJ_SEL_DIR
	calr	HDAE5000_DirList_BuildPage
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_SongScreen_Refresh
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_SELECT_FILE
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jr	t, HDAE5000_AttenDelFileSwCatch_Done
HDAE5000_AttenDelFileSwCatch_Skip:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_FILE_DEL_SCREEN
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_AttenDelFileSwCatch_Done:
	ld	xhl, 0:i3
HDAE5000_AttenDelFileSwCatch_Epilogue:
	pop xiz
	ret

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
	lda	xwa, (0x23d286:24)
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
	pushw 0xd286
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
	lda xwa, (0x22ac36:24)
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
	lda	xwa, (0x23d286:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+14)
	lda	xwa, (0x23d286:24)
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
	lda	xwa, (0x23d286:24)
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
	lda	xwa, (0x23d286:24)
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
	pushw 0xd286
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

HDAE5000_HDD_DIRNAMECheck:
	; registered as "HDD_DIRNAMECheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	cp	xbc, EVT_SW_IN
	jr	z, HDAE5000_HDD_DIRNAMECheck_OnSwIn
	cp	xbc, EVT_GET_STRING_LENGTH
	jr	z, HDAE5000_HDD_DIRNAMECheck_OnGetStringLength
	cp	xbc, EVT_GET_NAMING_MODE
	jr	z, HDAE5000_HDD_DIRNAMECheck_OnGetNamingMode
	cp	xbc, EVT_SET_STRING
	jr	z, HDAE5000_HDD_DIRNAMECheck_OnSetString
	cp	xbc, EVT_GET_STRING
	jrl	nz, HDAE5000_HDD_DIRNAMECheck_Done
	pushw 0x0010
	lda xwa, (HDAE5000_RAM_NameEditBuffer:24)
	push xwa
	push xde
	call HDAE5000_StrNCpy
	lda	xsp, (xsp+10)
	ld	xhl, xiz
	jrl	t, HDAE5000_HDD_DIRNAMECheck_Epilogue
HDAE5000_HDD_DIRNAMECheck_OnSetString:
	pushw 0x0010
	push xde
	pushw	HDAE5000_RAM_NameEditBuffer@hi16
	pushw	HDAE5000_RAM_NameEditBuffer@lo16		; low half of HDAE5000_RAM_NameEditBuffer
	call HDAE5000_StrNCpy
	lda	xsp, (xsp+10)
	ld	(0x23d2b6:24), 0x00
	ld	xhl, xiz
	jrl	t, HDAE5000_HDD_DIRNAMECheck_Epilogue
HDAE5000_HDD_DIRNAMECheck_OnGetNamingMode:
	ld	xhl, 0:i3
	jrl	t, HDAE5000_HDD_DIRNAMECheck_Epilogue
HDAE5000_HDD_DIRNAMECheck_OnGetStringLength:
	ld	xhl, 0x00000010
	jrl	t, HDAE5000_HDD_DIRNAMECheck_Epilogue
HDAE5000_HDD_DIRNAMECheck_OnSwIn:
	cp	xde, 0x0000000b
	jr	z, HDAE5000_HDD_DIRNAMECheck_Skip
	cp	xde, 0x0000008a
	jrl	nz, HDAE5000_HDD_DIRNAMECheck_Done
	lda xwa, (HDAE5000_RAM_DirNameHistory:24)
	calr	HDAE5000_NameHistory_Recall
	ld	xiz, xhl
	ld	xwa, xiz
	or xwa, xwa
	jrl	z, HDAE5000_HDD_DIRNAMECheck_Done
	ld	xwa, xiz
	push xwa
	call HDAE5000_StrLen
	pushw hl
	ld	xwa, xiz
	push xwa
	lda xwa, (HDAE5000_RAM_NameEditBuffer:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+14)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xix, (xwa + RootFn_GetNamingWindowID)
	call	(xix)
	lda xwa, (HDAE5000_RAM_NameEditBuffer:24)
	ld	xbc, xwa
	ld	xwa, xhl
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_SET_STRING
	call	(xhl)
	jr	t, HDAE5000_HDD_DIRNAMECheck_Done
HDAE5000_HDD_DIRNAMECheck_Skip:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xix, (xwa + RootFn_GetNamingWindowID)
	call	(xix)
	lda xwa, (HDAE5000_RAM_NameEditBuffer:24)
	ld	xbc, xwa
	ld	xwa, xhl
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_GET_STRING
	call	(xhl)
	ld	wa, (HDAE5000_RAM_CurDir:24)
	lda xbc, (HDAE5000_RAM_NameEditBuffer:24)
	ld	xde, HDAE5000_OBJ_SELECT_DIR
	calr	HDAE5000_DirName_StoreWithUi
	ld	xwa, HDAE5000_OBJ_SEL_DIR
	calr	HDAE5000_DirList_BuildPage
HDAE5000_HDD_DIRNAMECheck_Done:
	ld	xhl, 0:i3
HDAE5000_HDD_DIRNAMECheck_Epilogue:
	pop xiz
	ret

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
HDAE5000_PPORT_Svc26_ShowStatus:
	push xiz
	ld	xiz, xwa
	ld	xwa, xiz
	push xwa
	call HDAE5000_StrLen
	inc 4, xsp
	cp	hl, 0x0019
	jr	ule, HDAE5000_PPORT_Svc26_ShowStatus_Join
	ldw	hl, 0x0019
HDAE5000_PPORT_Svc26_ShowStatus_Join:
	pushw hl
	ld	xwa, xiz
	push xwa
	lda xwa, (HDAE5000_RAM_PcLinkStatusText+7:24)
	push xwa
	call HDAE5000_StrNCpy
	lda	xsp, (xsp+10)
	lda xwa, (HDAE5000_RAM_PcLinkStatusText:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_PP_STATUS
	ld	xbc, 0x01ea0009
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_PP_STATUS
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	pop xiz
	ret


; ---------------------------------------------------------------------------
; Show a status string on the PC-link page, as service 26
; (HDAE5000_PPORT_Svc26_ShowStatus) but sending the two events with
; RootFn_SendEvent instead of posting them.
; In:  XWA = string.  XIZ preserved.
; ---------------------------------------------------------------------------
HDAE5000_PcLink_ShowStatus:
	push xiz
	ld xiz, xwa
	ld xwa, xiz
	push xwa
	call HDAE5000_StrLen
	inc 4, xsp
	cp hl, 0x0019
	jr ule, .Lhec_len_ok
	ldw hl, 0x0019
.Lhec_len_ok:
	pushw hl
	ld xwa, xiz
	push xwa
	lda xwa, (HDAE5000_RAM_PcLinkStatusText+7:24)
	push xwa
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 10)
	; Display error string
	lda xwa, (HDAE5000_RAM_PcLinkStatusText:24)
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)
	ld xwa, HDAE5000_OBJ_PP_STATUS
	ld	xbc, 0x01ea0009
	call (xhl)
	; Clear display line
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)
	ld xwa, HDAE5000_OBJ_PP_STATUS
	ld xbc, EVT_PARA_DRAW
	ld xde, 0xFFFFFFFF
	call (xhl)
	pop xiz
	ret
	; Part 2: Error handler dispatcher (0x284E53)
	; XWA = original params, XBC = error code, XDE = extra data

HDAE5000_PC_DATA_LINK_PAGE:
	; registered as "PC_DATA_LINK_PAGE" in HDAE5000_ObjHandler_Table
	dec 8, xsp
	push xiz
	ld (xsp + 4), xde		; save extra data
	ld xiz, xbc			; XIZ = error code
	ld (xsp + 8), xwa		; save original params
	; Dispatch on error code
	ld xwa, xiz
	cp xwa, EVT_SW_IN		; error 7 (command failed)?
	jr z, .Lhd_err7
	cp xwa, EVT_DRAW		; error 13 (retry)?
	jr z, .Lhd_err13
	cp xwa, EVT_ARE_YOU_CLASS_PROC		; error 0x85 (fatal)?
	jrl nz, .Lhd_cleanup
	ld xhl, 1:i3			; return 1 (fatal)
	jrl .Lhd_exit
.Lhd_err13:
	; Error 13: retry — call callback, copy buffer, redisplay
	ld xwa, (xsp + 8)
	ld xbc, xiz
	ld xde, (xsp + 4)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)             ; (XHL+0x0E0A)
	ld_sril xhl, (xhl + RootFn_InheritedProc)             ; (XHL+0x00DC) — callback
	call (xhl)
	lda xwa, (HDAE5000_Str_PCLK:24); 0x2E1E72 — status buffer
	ld xbc, xwa
	ld xwa, (xsp + 8)
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)             ; (XBC+0x0E0A)
	ld_sril xhl, (xbc + RootFn_SendEvent)             ; (XBC+0x0100) — display handler
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	ld xhl, 0:i3			; return 0 (retry ok)
	jrl .Lhd_exit
.Lhd_err7:
	; Error 7: command failed — check sub-code
	ld xde, (xsp + 4)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xix, (xwa + RootFn_SendEvent)             ; XIX = display handler
	ld xwa, 0x02600024
	ld xbc, EVT_MAKE_EDIT_SW_ID
	call (xix)
	cp xhl, 0x00000007		; sub-code 7?
	jr z, .Lhd_err7_display
	cp xhl, 0x00000006		; sub-code 6?
	jr z, .Lhd_err7_display
	cp xhl, 0x00000001		; sub-code 1?
	jr z, .Lhd_err7_minor
	or xhl, xhl			; sub-code 0?
	jr nz, .Lhd_cleanup
.Lhd_err7_minor:
	lda xwa, (HDAE5000_Str_PORTISACTIVE:24); 0x2E1E78 — error string
	calr HDAE5000_PcLink_ShowStatus	; recursive: display error
	call HDAE5000_PPORT_StartLink
	jr .Lhd_cleanup
.Lhd_err7_display:
	call HDAE5000_PPORT_Reset
	lda xwa, (HDAE5000_Str_Blank14:24); 0x2E1E88 — error string
	calr HDAE5000_PcLink_ShowStatus	; recursive: display error
	; Reinit display handler
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)             ; (XWA+0x0104) — init handler
	ld xwa, HDAE5000_OBJ_SETUPS_TOOLS
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
.Lhd_cleanup:
	; Final cleanup: call error callback
	ld xwa, (xsp + 8)
	ld xbc, xiz
	ld xde, (xsp + 4)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)
	ld_sril xix, (xhl + RootFn_InheritedProc)             ; XIX = callback
	call (xix)
.Lhd_exit:
	pop xiz
	inc 8, xsp
	ret

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
	pushw	HDAE5000_Fmt_s_SeparateOutputModeCheck@hi16
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
	pushw	HDAE5000_Fmt_s_SeparateDrumPartCheck@hi16
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
	pushw	HDAE5000_Fmt_s_SeparateBassPartCheck@hi16
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
.LHD_Data_Copy__done:
	retd 0x0002

; ---------------------------------------------------------------------------
; Recompute the mask word of a part-selection record (see
; HDAE5000_TypeSel_Init): bit k set for every part k whose flag byte (+2+k)
; is 2 ("YES").
; In:  XWA = record (HDAE5000_RAM_SaveOptions or _DeleteOptions)
; Out: (XWA+0) = mask.  No register changes.
; ---------------------------------------------------------------------------
HDAE5000_TypeSel_BuildMask:
	ldw (xwa + 0), 0x0000		; clear output flags
	cp (xwa + 2), 0x02
	jr nz, .Lhbi_skip0
	ldw (xwa + 0), 0x0001		; set bit 0
.Lhbi_skip0:
	cp (xwa + 3), 0x02
	jr nz, .Lhbi_skip1
	ormi16 (xwa + 0), 0x0002	; set bit 1
.Lhbi_skip1:
	cp (xwa + 4), 0x02
	jr nz, .Lhbi_skip2
	ormi16 (xwa + 0), 0x0004	; set bit 2
.Lhbi_skip2:
	cp (xwa + 5), 0x02
	jr nz, .Lhbi_skip3
	ormi16 (xwa + 0), 0x0008	; set bit 3
.Lhbi_skip3:
	cp (xwa + 6), 0x02
	jr nz, .Lhbi_skip4
	ormi16 (xwa + 0), 0x0010	; set bit 4
.Lhbi_skip4:
	cp (xwa + 7), 0x02
	jr nz, .Lhbi_skip5
	ormi16 (xwa + 0), 0x0020	; set bit 5
.Lhbi_skip5:
	cp (xwa + 8), 0x02
	jr nz, .Lhbi_skip6
	ormi16 (xwa + 0), 0x0040	; set bit 6
.Lhbi_skip6:
.Lhbi_skip7:
	cp (xwa + 9), 0x02
	ret nz
	ormi16 (xwa + 0), 0x0080	; set bit 8
	ret
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
	pushw 0xd286
	pushw	HDAE5000_Fmt_s_SaveOptNameCheck@hi16
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
	lda xhl, (HDAE5000_RAM_SaveOptions+10:24)
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
HDAE5000_TypeSel_ShowSaveFlags:	; (3728 bytes)
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
	jp	(xhl)

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
	cp	xhl, 0x0000000b
	jrl	z, HDAE5000_SaveOptSwEventCatch_Skip4
	cp	xhl, 0x0000000a
	jrl	z, HDAE5000_SaveOptSwEventCatch_Skip7
	cp	xhl, 0x00000009
	jrl	z, HDAE5000_SaveOptSwEventCatch_Skip2
	cp	xhl, 0x00000008
	jrl	nz, HDAE5000_SaveOptSwEventCatch_Done
	lda	xwa, (0x23d286:24)
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
	pushw 0xd286
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
HDAE5000_SaveOptSwEventCatch_Skip3:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateAllNo:24)
	ldw	bc, 0x003f
	calr	HDAE5000_TypeSel_Init
	calr	HDAE5000_TypeSel_ShowSaveFlags
	jr	t, HDAE5000_SaveOptSwEventCatch_Done
HDAE5000_SaveOptSwEventCatch_Skip7:
	lda	xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw	0x2
	lda	xde, (HDAE5000_TypeSel_TemplateAllNo:24)
	ldw	bc, 0x00ff
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
HDAE5000_SaveOptSwEventCatch_Skip5:
HDAE5000_SaveOptSwEventCatch_Skip6:
HDAE5000_SaveOptSwEventCatch_Join2:
HDAE5000_SaveOptSwEventCatch_Done:
	ld	xhl, 0:i3
HDAE5000_SaveOptSwEventCatch_Epilogue:
	pop xiz
	ret

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
	pushw	HDAE5000_Fmt_s_FileOptNameCheck@hi16
	pushw	HDAE5000_Fmt_s_FileOptNameCheck@lo16		; low half of HDAE5000_Fmt_s_FileOptNameCheck
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
	lda xhl, (HDAE5000_RAM_SaveOptions+10:24)
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
	pushw	HDAE5000_Fmt_s_SfxLswBitCheck@hi16
	pushw	HDAE5000_Fmt_s_SfxLswBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxLswBitCheck
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
	pushw	HDAE5000_Fmt_s_SfxPmtBitCheck@hi16
	pushw	HDAE5000_Fmt_s_SfxPmtBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxPmtBitCheck
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
	pushw	HDAE5000_Fmt_s_SfxSqtBitCheck@hi16
	pushw	HDAE5000_Fmt_s_SfxSqtBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxSqtBitCheck
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
	pushw	HDAE5000_Fmt_s_SfxCmpBitCheck@hi16
	pushw	HDAE5000_Fmt_s_SfxCmpBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxCmpBitCheck
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
	pushw	HDAE5000_Fmt_s_SfxTmBitCheck@hi16
	pushw	HDAE5000_Fmt_s_SfxTmBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxTmBitCheck
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
	pushw	HDAE5000_Fmt_s_SfxMspBitCheck@hi16
	pushw	HDAE5000_Fmt_s_SfxMspBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxMspBitCheck
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
	pushw	HDAE5000_Fmt_s_SfxRcmBitCheck@hi16
	pushw	HDAE5000_Fmt_s_SfxRcmBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxRcmBitCheck
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
	pushw	HDAE5000_Fmt_s_SfxMdBitCheck@hi16
	pushw	HDAE5000_Fmt_s_SfxMdBitCheck@lo16		; low half of HDAE5000_Fmt_s_SfxMdBitCheck
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
	pushw	HDAE5000_Fmt_s_WriteProtectEditCheck@hi16
	pushw	HDAE5000_Fmt_s_WriteProtectEditCheck@lo16		; low half of HDAE5000_Fmt_s_WriteProtectEditCheck
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


; v2.01i has no LyricForeColorCheck / LyricBackColorCheck (the lyric colour
; settings of v2.06i): WriteConfirmEditCheck follows LyricJumpEditCheck.
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
	pushw	HDAE5000_Fmt_s_WriteConfirmEditCheck@hi16
	pushw	HDAE5000_Fmt_s_WriteConfirmEditCheck@lo16		; low half of HDAE5000_Fmt_s_WriteConfirmEditCheck
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
	pushw	HDAE5000_Fmt_1d_QuickLoadModeEditCheck@hi16
	pushw	HDAE5000_Fmt_1d_QuickLoadModeEditCheck@lo16		; low half of HDAE5000_Fmt_1d_QuickLoadModeEditCheck
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
	pushw	HDAE5000_Fmt_1d_LoadByNumberModeEditCheck@hi16
	pushw	HDAE5000_Fmt_1d_LoadByNumberModeEditCheck@lo16		; low half of HDAE5000_Fmt_1d_LoadByNumberModeEditCheck
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
	pushw	HDAE5000_Fmt_1d_JumpAfterLoadModeEditCheck@hi16
	pushw	HDAE5000_Fmt_1d_JumpAfterLoadModeEditCheck@lo16		; low half of HDAE5000_Fmt_1d_JumpAfterLoadModeEditCheck
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
HDAE5000_SetupPage_BuildDriveInfo:
	lda	xsp, (xsp-108)
	pushw 0x0139
	lda xwa, (HDAE5000_DriveInfo_Template:24)
	push xwa
	lda xwa, (0x22b2a0:24)
	push xwa
	call HDAE5000_MemCopy			; HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)
	lda xwa, (xsp + 0x38)
	call HDAE5000_HD_GetGeometry
	pushw 0x0010
	lda xwa, (xsp + 0x44)
	push xwa
	lda xwa, (0x22b2b6:24)
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
	lda xwa, (0x22b2dd:24)
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
	lda xwa, (0x22b304:24)
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
	lda xwa, (0x22b32b:24)
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
	lda xwa, (0x22b352:24)
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
	pushw	HDAE5000_Fmt_6_1f_SetupPage_BuildDriveInfo@hi16
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
	lda xwa, (0x22b379:24)
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
	lda xwa, (0x22b3a0:24)
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
	lda xwa, (0x22b3c7:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0e)
	; Register partition display handler
	lda xwa, (0x22b2a0:24)
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_HD_INFO_LIST
	ld	xbc, 0x01ea0009
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
	lda xwa, (0x22ad54:24)
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
HDAE5000_AttenHDFormatSwCatch:
	; registered as "AttenHDFormatSwCatch" in HDAE5000_ObjHandler_Table
	dec 6, xsp			; alloc 24 bytes
	push xiz
	ld xiz, xde			; XIZ = param
	ld (xsp + 0x06), xwa		; save event code
	ld xwa, xbc			; XWA = event code
	cp xwa, EVT_HDAE_TIMER_BACK
	jrl z, .LCHSC__ev_close
	cp xwa, EVT_SW_IN
	jr z, .LCHSC__ev_key
	cp xwa, EVT_DRAW
	jr z, .LCHSC__ev_0d
	cp xwa, EVT_ARE_YOU_CLASS_PROC
	jr z, .LCHSC__ev_85
	; Default: pass through to registered handler
	ld xwa, (xsp + 0x06)
	ld xde, xiz
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)             ; XHL = (XHL + 0x0E0A)
	ld_sril xix, (xhl + RootFn_InheritedProc)             ; XIX = (XHL + 0x00DC)
	call (xix)
	jrl t, .LCHSC__exit
.LCHSC__ev_85:				; Event 0x01E00085
	ld xhl, 1:i3
	jrl t, .LCHSC__exit
.LCHSC__ev_0d:				; Event 0x01C0000D
	ld xwa, (xsp + 0x06)
	ld xde, xiz
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)
	ld_sril xhl, (xhl + RootFn_InheritedProc)             ; XHL = (XHL + 0x00DC)
	call (xhl)
	lda xwa, (HDAE5000_Str_FMT:24)
	ld xbc, xwa
	ld xwa, (xsp + 0x06)
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)             ; XBC = (XBC + 0x0E0A)
	ld_sril xhl, (xbc + RootFn_SendEvent)             ; XHL = (XBC + 0x0100)
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	ld xhl, 0:i3
	jrl t, .LCHSC__exit
.LCHSC__ev_key:				; Event 0x01C00007
	ldw	(xsp+4), 0x0000
	ld xde, xiz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)             ; XWA = (XWA + 0x0E0A)
	ld_sril xix, (xwa + RootFn_SendEvent)             ; XIX = (XWA + 0x0100)
	ld xwa, 0x02600024
	ld xbc, EVT_MAKE_EDIT_SW_ID
	call (xix)
	ld xwa, xhl
	cp xwa, 0x00000007
	jrl ugt, .LCHSC__post_switch		; > 7 → skip
	add xwa, xwa				; XWA * 2
	add xwa, HDAE5000_AttenHDFormatSwCatch_CaseTable			; jump table base
	ld wa, (xwa)				; WA = offset
	lda xix, (HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1:24); dispatch base
	jp	t, (xix+wa)
	; Case 0: bit test → call with 0/1
; HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1: edit switch 0 (no caption on ATTEN_HD_FORMAT): append code digit 0
;   (switch code bit 7 set) or 1
HDAE5000_AttenHDFormatSwCatch_OnCodeDigit0Or1:
	bit 0x07, iz
	jr z, .LCHSC__c0_even
	ld wa, 0:i3
	jr t, .LCHSC__c0_call
.LCHSC__c0_even:
	ld wa, 1:i3
.LCHSC__c0_call:
	calr HDAE5000_FormatDialog_CodeDigit		; recursive
	ld (xsp + 0x04), hl
	jr t, .LCHSC__post_switch
	; Case 1: bit test → call with 2/3
; HDAE5000_AttenHDFormatSwCatch_OnCodeDigit2Or3: edit switch 1 (no caption on ATTEN_HD_FORMAT): append code digit 2
;   (switch code bit 7 set) or 3
HDAE5000_AttenHDFormatSwCatch_OnCodeDigit2Or3:
	bit 0x07, iz
	jr z, .LCHSC__c1_even
	ld wa, 2:i3
	jr t, .LCHSC__c1_call
.LCHSC__c1_even:
	ld wa, 3:i3
.LCHSC__c1_call:
	calr HDAE5000_FormatDialog_CodeDigit
	ld (xsp + 0x04), hl
	jr t, .LCHSC__post_switch
	; Case 2: bit test → call with 4/5
; HDAE5000_AttenHDFormatSwCatch_OnCodeDigit4Or5: edit switch 2 (no caption on ATTEN_HD_FORMAT): append code digit 4
;   (switch code bit 7 set) or 5
HDAE5000_AttenHDFormatSwCatch_OnCodeDigit4Or5:
	bit 0x07, iz
	jr z, .LCHSC__c2_even
	ld wa, 4:i3
	jr t, .LCHSC__c2_call
.LCHSC__c2_even:
	ld wa, 5:i3
.LCHSC__c2_call:
	calr HDAE5000_FormatDialog_CodeDigit
	ld (xsp + 0x04), hl
	jr t, .LCHSC__post_switch
	; Case 3: bit test → call with 6/7
; HDAE5000_AttenHDFormatSwCatch_OnCodeDigit6Or7: edit switch 3 (no caption on ATTEN_HD_FORMAT): append code digit 6
;   (switch code bit 7 set) or 7
HDAE5000_AttenHDFormatSwCatch_OnCodeDigit6Or7:
	bit 0x07, iz
	jr z, .LCHSC__c3_even
	ld wa, 6:i3
	jr t, .LCHSC__c3_call
.LCHSC__c3_even:
	ld wa, 7:i3
.LCHSC__c3_call:
	calr HDAE5000_FormatDialog_CodeDigit
	ld (xsp + 0x04), hl
	jr t, .LCHSC__post_switch
	; Case 4: bit test → call with 8/9 (ldw for values > 7)
; HDAE5000_AttenHDFormatSwCatch_OnCodeDigit8Or9: edit switch 4 (no caption on ATTEN_HD_FORMAT): append code digit 8
;   (switch code bit 7 set) or 9
HDAE5000_AttenHDFormatSwCatch_OnCodeDigit8Or9:
	bit 0x07, iz
	jr z, .LCHSC__c4_even
	ldw wa, 0x0008
	jr t, .LCHSC__c4_call
.LCHSC__c4_even:
	ldw wa, 0x0009
.LCHSC__c4_call:
	calr HDAE5000_FormatDialog_CodeDigit
	ld (xsp + 0x04), hl
	jr t, .LCHSC__post_switch
	; Case 6/7: clear buffer + display setup
; HDAE5000_AttenHDFormatSwCatch_OnCancel: edit switches 6 and 7, the CANCEL key: clear the code buffer and show
;   SETUPS_TOOLS
HDAE5000_AttenHDFormatSwCatch_OnCancel:
	pushw 0x000a
	pushw 0x0000
	lda xwa, (0x22ad54:24)
	push xwa
	call HDAE5000_MemFill			; MemFill
	inc 8, xsp
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)             ; XHL = (XWA + 0x0104)
	ld xwa, HDAE5000_OBJ_SETUPS_TOOLS
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	; Post-switch: dispatch on result
.LCHSC__post_switch:
	ld wa, (xsp + 0x04)
	cp wa, 3:i3
	jrl z, .LCHSC__res3
	cp wa, 2:i3
	jr z, .LCHSC__res2
	cp wa, 1:i3
	jrl nz, .LCHSC__done
	; Result 1: setup with 0x007f02cb + two dialog boxes
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)             ; XHL = (XWA + 0x0100)
	ld xwa, HDAE5000_OBJ_AGAIN_HD_FORMAT
	ld xbc, EVT_SHOW
	ld xde, 3:i3
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_ATTEN_HD_FORMAT
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_KillApTimer)             ; XHL = (XWA + 0x0418)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_AGAIN_HD_FORMAT_CATCH
	ld xde, 0xffffffff
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_ATTEN_HD_FORMAT
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)             ; XHL = (XWA + 0x0410)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_AGAIN_HD_FORMAT_CATCH
	ld xde, 0xffffffff
	call (xhl)
	jrl t, .LCHSC__done
.LCHSC__res2:				; Result 2: display setup + validate + FS init
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)
	ld xwa, HDAE5000_OBJ_WAIT_HD_FORMAT
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	calr HDAE5000_YieldUntilSem1Zero
	ld wa, 1:i3
	call HDAE5000_HD_FormatDrive
	cp hl, 0:i3
	jr nz, .LCHSC__res2_err
	; Success: display + FS read
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_SETUPS_TOOLS
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	ld xwa, HDAE5000_OBJ_SEL_DIR
	calr HDAE5000_DirList_BuildPage
	ld wa, 0:i3
	ld bc, 0:i3
	calr HDAE5000_SongScreen_Refresh
	calr HDAE5000_FlsList_BuildPage
	ld wa, 0:i3
	ld bc, 2:i3
	calr HDAE5000_FlsScreen_Refresh
	jrl t, .LCHSC__done
.LCHSC__res2_err:			; Error: display error + two dialog boxes
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_ERR_HD_FORMAT
	ld xbc, EVT_SHOW
	ld xde, 3:i3
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_ATTEN_HD_FORMAT
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_KillApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ERR_HD_FORMAT_CATCH
	ld xde, 0xffffffff
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_ATTEN_HD_FORMAT
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ERR_HD_FORMAT_CATCH
	ld xde, 0xffffffff
	call (xhl)
	jrl t, .LCHSC__done
.LCHSC__res3:				; Result 3: set flags + validate + check match
	ld (HDAE5000_RAM_QuickLoadMode:24), 0x01
	ld (HDAE5000_RAM_LoadByNumberMode:24), 0x01
	ld (HDAE5000_RAM_JumpAfterLoad:24), 0x01
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)
	ld xwa, HDAE5000_OBJ_WAIT_TR0_RECOVER
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	calr HDAE5000_YieldUntilSem1Zero
	ld wa, 0:i3
	call HDAE5000_HD_StoreSettings
	cp hl, 0xffff
	jr z, .LCHSC__res3_nomatch
	; Match found
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_SETUPS_TOOLS
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jrl t, .LCHSC__done
.LCHSC__res3_nomatch:			; No match — setup error display + dialog boxes
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_ERR_SAVE
	ld xbc, EVT_SHOW
	ld xde, 3:i3
	call (xhl)
	ld xwa, HDAE5000_OBJ_ERR_SAVE_EXIT
	ld xbc, HDAE5000_OBJ_ATTEN_HD_FORMAT
	calr HDAE5000_UiObj_SetCaption
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_ATTEN_HD_FORMAT
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_KillApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld xde, 0xffffffff
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_ATTEN_HD_FORMAT
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld xde, 0xffffffff
	call (xhl)
.LCHSC__done:				; Common exit
	ld xhl, 0:i3
	jr t, .LCHSC__exit
.LCHSC__ev_close:			; Event 0x01CA0002: close display
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_ATTEN_HD_FORMAT
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	ld xhl, 0:i3
.LCHSC__exit:
	pop xiz
	inc 6, xsp			; dealloc 24 bytes
	ret

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
	jr	nz, .LHD_SR__b_exit
.LHD_SR__b_check_state:
	cpw (HDAE5000_RAM_LbnDigitPos:24), 0x0005; state == 5?
	jr	nz, .LHD_SR__b_exit
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
	; Flag set: register display handler
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
	jrl	nz, .Lsw_exit

	; === Case 0: initialize cylinder from BC*100, set state=1 ===
	ld wa, bc				; d9 88
	mul wa, 0x0064				; d8 08 64 00
	ld (HDAE5000_RAM_LbnDir:24), wa
	ldw (HDAE5000_RAM_LbnSong:24), 0x0000; f2 60 aa 22 02 00 00
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0001; f2 5c aa 22 02 01 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 5e aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 60 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 5c aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl
	jrl	t, .Lsw_exit

	; === Case 1: add BC*10 to cylinder, set state=2 ===
.Lsw_case1:
	ld wa, bc				; d9 88
	mul wa, 0x000a				; d8 08 0a 00
	add (HDAE5000_RAM_LbnDir:24), wa; d2 5e aa 22 88
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0002; f2 5c aa 22 02 02 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 5e aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 60 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 5c aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl
	jrl	t, .Lsw_exit

	; === Case 2: add BC to cylinder, set state=3 ===
.Lsw_case2:
	add (HDAE5000_RAM_LbnDir:24), bc; d2 5e aa 22 89
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0003; f2 5c aa 22 02 03 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 5e aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 60 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 5c aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl
	jrl	t, .Lsw_exit

	; === Case 3: set head from BC*10, set state=4 ===
.Lsw_case3:
	ld wa, bc				; d9 88
	mul wa, 0x000a				; d8 08 0a 00
	ld (HDAE5000_RAM_LbnSong:24), wa; f2 60 aa 22 50
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0004; f2 5c aa 22 02 04 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 5e aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 60 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 5c aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl
	jrl	t, .Lsw_exit

	; === Case 4: add BC to head, set state=5, then process ===
.Lsw_case4:
	add (HDAE5000_RAM_LbnSong:24), bc; d2 60 aa 22 89
	ldw (HDAE5000_RAM_LbnDigitPos:24), 0x0005; f2 5c aa 22 02 05 00
	pushw 0x0001
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 5e aa 22 20
	ld bc, (HDAE5000_RAM_LbnSong:24); d2 60 aa 22 21
	ld de, (HDAE5000_RAM_LbnDigitPos:24); d2 5c aa 22 22
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	ld	qiz, hl

	; --- After all cases: check result ---
	ld	wa, qiz
	cp wa, 0:i3				; d8 d8
	jrl	nz, .Lsw_exit

	; --- Compute sector address and look up in table ---
	ld wa, (HDAE5000_RAM_LbnDir:24); d2 5e aa 22 20 — directory number
	dec 1, wa				; d8 69
	ld (HDAE5000_RAM_CurDir:24), wa; f2 1a a0 23 50
	ld wa, (HDAE5000_RAM_LbnSong:24); d2 60 aa 22 20 — song number
	dec 1, wa				; d8 69
	ld (HDAE5000_RAM_CurSong:24), wa; f2 1c a0 23 50
	ld wa, (HDAE5000_RAM_CurDir:24); d2 1a a0 23 20
	ld bc, (HDAE5000_RAM_CurSong:24); d2 1c a0 23 21
	call HDAE5000_Song_PartMask		; 1d 66 fd 28
	ld iz, hl				; db 8e
	ld wa, iz				; de 88
	cp wa, 0xffff				; d8 cf ff ff
	jr z, .Lsw_lookup_notfound		; 66 xx

	; --- Found: copy data and seek ---
.Lsw_lookup_found:
	lda xwa, (HDAE5000_RAM_SaveOptions:24); f2 4c aa 22 30
	ld bc, iz				; de 89
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24); f2 a4 14 2e 32
	calr HDAE5000_TypeSel_Init		; 1e xx xx
	ld bc, (HDAE5000_RAM_CurDir:24); d2 1a a0 23 21
	ld de, (HDAE5000_RAM_CurSong:24); d2 1c a0 23 22
	ld wa, iz				; de 88
	pushw wa                                ; push wa (compact 16-bit)
	ld xwa, HDAE5000_OBJ_LBN_OPTION			; 40 9a 00 7f 00
	calr HDAE5000_PartList_Build			; 1e xx xx
	jr t, .Lsw_after_lookup			; 68 xx

	; --- Not found: copy default data and seek with -1 ---
.Lsw_lookup_notfound:
	lda xwa, (HDAE5000_RAM_SaveOptions:24); f2 4c aa 22 30
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24); f2 a4 14 2e 32
	ld bc, 0:i3				; d9 a8
	calr HDAE5000_TypeSel_Init		; 1e xx xx
	pushw 0xffff
	ld xwa, HDAE5000_OBJ_LBN_OPTION			; 40 9a 00 7f 00
	ldw bc, 0xffff				; 31 ff ff
	ldw de, 0xffff				; 32 ff ff
	calr HDAE5000_PartList_Build			; 1e xx xx

	; --- After table lookup: check sectors per track ---
.Lsw_after_lookup:
	cp (HDAE5000_RAM_LoadByNumberMode:24), 0x02; c2 aa 9d 22 3f 02
	jr	nz, .Lsw_exit
	; Sectors per track == 2: do display and FS operations
	pushw 0x0001
	ld xwa, HDAE5000_OBJ_LOAD_BY_NUM			; 40 91 00 7f 00
	push xwa				; 38
	ld wa, (HDAE5000_RAM_CurDir:24); d2 1a a0 23 20
	ld bc, (HDAE5000_RAM_CurSong:24); d2 1c a0 23 21
	ld de, (HDAE5000_RAM_SaveOptions:24); d2 4c aa 22 22
	calr HDAE5000_LoadSongWithUi		; 1e xx xx
	pushw 0x0001
	ld wa, 0:i3				; d8 a8
	ld bc, 0:i3				; d9 a8
	ld de, 6:i3				; da ae
	calr HDAE5000_Lbn_ShowEntry			; 1e xx xx
	; Check second disk flag
	; Check bit 8 of aa4c entry
	; Register event: format complete

	; === Exit: check QIZ result ===
.Lsw_exit:
	ld	wa, qiz
	cp wa, 0xfffe				; d8 cf fe ff
	jr z, .Lsw_err_fffe			; 66 xx
	cp wa, 0xffff				; d8 cf ff ff
	jrl nz, .Lsw_done			; 7e xx xx

	; --- Error 0xFFFF: register error + timer ---
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_PostEvent)             ; e3 e1 04 01 23 — ld xhl, (xwa+0x0104)
	ld xwa, HDAE5000_OBJ_DIR_OUT_RANGE			; 40 b6 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 5:i3				; ea ad
	call (xhl)				; b3 e8
	ld xwa, EVT_HDAE_TIMER_BACK			; 40 02 00 ca 01
	push xwa				; 38
	ld xwa, HDAE5000_OBJ_LOAD_BY_NUM			; 40 91 00 7f 00
	push xwa				; 38
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_SetApTimer)             ; e3 e1 10 04 23 — ld xhl, (xwa+0x0410)
	ld xwa, 0x00000021			; 40 21 00 00 00
	ld xbc, HDAE5000_OBJ_DIR_OUT_RANGE_CATCH			; 41 b7 02 7f 00
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8
	jr t, .Lsw_done				; 68 xx

	; --- Error 0xFFFE: register different error + timer ---
.Lsw_err_fffe:
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_PostEvent)             ; e3 e1 04 01 23 — ld xhl, (xwa+0x0104)
	ld xwa, HDAE5000_OBJ_FILE_OUT_RANGE			; 40 bb 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 5:i3				; ea ad
	call (xhl)				; b3 e8
	ld xwa, EVT_HDAE_TIMER_BACK			; 40 02 00 ca 01
	push xwa				; 38
	ld xwa, HDAE5000_OBJ_LOAD_BY_NUM			; 40 91 00 7f 00
	push xwa				; 38
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 0c a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_SetApTimer)             ; e3 e1 10 04 23 — ld xhl, (xwa+0x0410)
	ld xwa, 0x00000021			; 40 21 00 00 00
	ld xbc, HDAE5000_OBJ_FILE_OUT_RANGE_CATCH			; 41 bc 02 7f 00
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8

	; --- Epilogue ---
.Lsw_done:
	pop xiz					; 5e
	ret					; 0e

; --- Filesystem Operations ---
