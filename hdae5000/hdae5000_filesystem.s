HDAE5000_Lbn_ShowEntry:	; 0x2870D6 (3711 bytes)
; FS_Init: 0x2870D6 (3711 bytes) — disassembled from original ROM
; ^ now HDAE5000_Lbn_ShowEntry: draw the load-by-number entry -- WA =
;   directory number, BC = song number, DE = digit position 0..6 (switch
;   HDAE5000_Lbn_ShowEntry_CaseTable) -- digits, directory name and song
;   name into 0x22AA62.. .  The size is the conversion region's, not the
;   routine's.
; Main entry + 10 event handler callbacks

	lda	xsp, (xsp-36)
	pushw iz                                ; push IZ
	ld (xsp + 0x24), bc
	ld	iz, wa
	ldw (xsp + 0x02), 0
	ld	wa, de
	cp	wa, 6:i3
	jrl ugt, HDAE5000_Lbn_ShowEntry_Join                     ; [7b 49 02] jrl UGT,0x287334
	add	wa, wa
	lda xix, (HDAE5000_Lbn_ShowEntry_CaseTable:24)
	ld	wa, (xix+wa)
	lda xix, (HDAE5000_Lbn_ShowEntry_NoDigitTyped:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
; HDAE5000_Lbn_ShowEntry_NoDigitTyped: blank the directory number, directory name, song number and song name fields
HDAE5000_Lbn_ShowEntry_NoDigitTyped:
	pushw 0x0005
	lda xwa, (HDAE5000_Str_Blank3Tab:24)
	push xwa
	lda xwa, (0x22aa62:24)
	push xwa
	call HDAE5000_MemCopy
	pushw 0x0012
	lda xwa, (HDAE5000_Str_Blank16Tab:24)
	push xwa
	lda xwa, (0x22aa68:24)
	push xwa
	call HDAE5000_MemCopy
	pushw 0x0005
	lda xwa, (HDAE5000_Str_Blank3Tab_Lbn_ShowEntry:24)
	push xwa
	lda xwa, (0x22aa7a:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+30)
	pushw 0x001c
	lda xwa, (HDAE5000_Str_Blank26Tab:24)
	push xwa
	lda xwa, (0x22aa80:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	jrl t, HDAE5000_Lbn_ShowEntry_Join                       ; [78 de 01] jrl T,0x287334
; HDAE5000_Lbn_ShowEntry_DirHundredsTyped: show the directory number's first digit (dir/100, %1.1d)
HDAE5000_Lbn_ShowEntry_DirHundredsTyped:
	ld	wa, iz
	extz xwa
	div wa, 0x0064
	pushw wa                                ; push WA
	pushw HDAE5000_Fmt_1_1d@hi16
	pushw HDAE5000_Fmt_1_1d@lo16		; low half of HDAE5000_Fmt_1_1d
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push HL
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (0x22aa62:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	jrl t, HDAE5000_Lbn_ShowEntry_Join                       ; [78 aa 01] jrl T,0x287334
; HDAE5000_Lbn_ShowEntry_DirTensTyped: show the directory number's first two digits (dir/10, %2.2d)
HDAE5000_Lbn_ShowEntry_DirTensTyped:
	ld	wa, iz
	extz xwa
	div wa, 0x000a
	pushw wa                                ; push WA
	pushw HDAE5000_Fmt_2_2d_Lbn_ShowEntry@hi16
	pushw HDAE5000_Fmt_2_2d_Lbn_ShowEntry@lo16		; low half of HDAE5000_Fmt_2_2d_Lbn_ShowEntry
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push HL
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (0x22aa62:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	jrl t, HDAE5000_Lbn_ShowEntry_Join                       ; [78 76 01] jrl T,0x287334
; HDAE5000_Lbn_ShowEntry_DirUnitsTyped: show the 3-digit directory number and, for 1..120, the directory name;
;   otherwise return -1
HDAE5000_Lbn_ShowEntry_DirUnitsTyped:
	pushw iz                                ; push IZ
	pushw HDAE5000_Fmt_3_3d_Lbn_ShowEntry@hi16
	pushw HDAE5000_Fmt_3_3d_Lbn_ShowEntry@lo16		; low half of HDAE5000_Fmt_3_3d_Lbn_ShowEntry
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push HL
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (0x22aa62:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	cp	iz, 0:i3
	jr z, HDAE5000_Lbn_ShowEntry_DirUnitsTyped_Skip                        ; [66 22] jr Z,0x28720d
	cp	iz, 0x0078
	jr ugt, HDAE5000_Lbn_ShowEntry_DirUnitsTyped_Skip                      ; [6b 1c] jr UGT,0x28720d
	pushw 0x0010
	ld	wa, iz
	dec	1, wa
	call HDAE5000_DirName_Address
	push xhl
	lda xwa, (0x22aa68:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	jrl t, HDAE5000_Lbn_ShowEntry_Join                       ; [78 27 01] jrl T,0x287334
HDAE5000_Lbn_ShowEntry_DirUnitsTyped_Skip:
	ldw (xsp + 0x02), 65535
	jrl t, HDAE5000_Lbn_ShowEntry_Join                       ; [78 1f 01] jrl T,0x287334
; HDAE5000_Lbn_ShowEntry_SongTensTyped: show the song number's first digit (song/10, " %1.1d")
HDAE5000_Lbn_ShowEntry_SongTensTyped:
	ld	wa, (xsp+36)
	extz xwa
	div wa, 0x000a
	pushw wa                                ; push WA
	pushw HDAE5000_Fmt_1_1d_Lbn_ShowEntry@hi16
	pushw HDAE5000_Fmt_1_1d_Lbn_ShowEntry@lo16		; low half of HDAE5000_Fmt_1_1d_Lbn_ShowEntry
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push HL
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (0x22aa7a:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	jrl t, HDAE5000_Lbn_ShowEntry_Join                       ; [78 ea 00] jrl T,0x287334
; HDAE5000_Lbn_ShowEntry_SongUnitsTyped: show the 2-digit song number and, for directory 1..120 and song 1..16, the
;   song name; otherwise return -2 (bad song) or -1
HDAE5000_Lbn_ShowEntry_SongUnitsTyped:
	pushm	(xsp+36)
	pushw HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2@hi16
	pushw HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2@lo16		; low half of HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push HL
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (0x22aa7a:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	cp	iz, 0:i3
	jr z, HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip2                        ; [66 3c] jr Z,0x2872b5
	cp	iz, 0x0078
	jr ugt, HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip2                      ; [6b 36] jr UGT,0x2872b5
	cpw	(xsp+36), 0x0000
	jr z, HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip                        ; [66 28] jr Z,0x2872ae
	cpw	(xsp+36), 0x0010
	jr ugt, HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip                      ; [6b 21] jr UGT,0x2872ae
	pushw 0x001a
	ld	wa, iz
	dec	1, wa
	ld	bc, (xsp+38)
	dec	1, bc
	call HDAE5000_SongRecord_Address
	push xhl
	lda xwa, (0x22aa80:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	jrl t, HDAE5000_Lbn_ShowEntry_Join                       ; [78 86 00] jrl T,0x287334
HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip:
	ldw (xsp + 0x02), 65534
	jr t, HDAE5000_Lbn_ShowEntry_Join                        ; [68 7f] jr T,0x287334
HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip2:
	ldw (xsp + 0x02), 65535
	jr t, HDAE5000_Lbn_ShowEntry_Join                        ; [68 78] jr T,0x287334
; HDAE5000_Lbn_ShowEntry_Reset: blank the fields, zero LbnDir/LbnSong/LbnDigitPos and rebuild LBN_OPTION with no song
HDAE5000_Lbn_ShowEntry_Reset:
	pushw 0x0005
	lda xwa, (HDAE5000_Str_Blank3Tab:24)
	push xwa
	lda xwa, (0x22aa62:24)
	push xwa
	call HDAE5000_MemCopy
	pushw 0x0012
	lda xwa, (HDAE5000_Str_Blank16Tab:24)
	push xwa
	lda xwa, (0x22aa68:24)
	push xwa
	call HDAE5000_MemCopy
	pushw 0x0005
	lda xwa, (HDAE5000_Str_Blank3Tab_Lbn_ShowEntry:24)
	push xwa
	lda xwa, (0x22aa7a:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+30)
	pushw 0x001c
	lda xwa, (HDAE5000_Str_Blank26Tab:24)
	push xwa
	lda xwa, (0x22aa80:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	ldw	(HDAE5000_RAM_LbnDir:24), 0
	ldw	(HDAE5000_RAM_LbnSong:24), 0
	ldw	(HDAE5000_RAM_LbnDigitPos:24), 0
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_LBN_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_Lbn_ShowEntry_Join:
	cpw	(xsp+42), 0x0001
	jrl nz, HDAE5000_Lbn_ShowEntry_Reset_Skip                      ; [7e 0b 01] jrl NZ,0x287447
	lda xwa, (0x22aa62:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_LBN_DIRNO_BOX
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_LBN_DIRNO_BOX
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	lda xwa, (0x22aa68:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_LBN_DIRNAME_BOX
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_LBN_DIRNAME_BOX
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	lda xwa, (0x22aa7a:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_LBN_FILENO_BOX
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_LBN_FILENO_BOX
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	lda xwa, (0x22aa80:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_LBN_FILENAME_BOX
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_LBN_FILENAME_BOX
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	jrl t, HDAE5000_Lbn_ShowEntry_Reset_Done                       ; [78 08 01] jrl T,0x28754f
HDAE5000_Lbn_ShowEntry_Reset_Skip:
	lda xwa, (0x22aa62:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_LBN_DIRNO_BOX
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_LBN_DIRNO_BOX
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	lda xwa, (0x22aa68:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_LBN_DIRNAME_BOX
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_LBN_DIRNAME_BOX
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	lda xwa, (0x22aa7a:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_LBN_FILENO_BOX
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_LBN_FILENO_BOX
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	lda xwa, (0x22aa80:24)
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_LBN_FILENAME_BOX
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_LBN_FILENAME_BOX
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
HDAE5000_Lbn_ShowEntry_Reset_Done:
	ld	hl, (xsp+2)
	popw iz                                 ; pop IZ
	lda	xsp, (xsp+36)
	retd 0x0002

HDAE5000_FileLBNNameCheck:
	; registered as "FileLBNNameCheck" in HDAE5000_ObjHandler_Table
	dec	4, xsp
	push xiz
	ld (xsp + 0x04), xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_FileLBNNameCheck_OnRamDataReq                       ; [76 87 00] jrl Z,0x2875f1
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr lt, HDAE5000_FileLBNNameCheck_Default                       ; [61 7d] jr LT,0x2875f5
	cp	xwa, 0x00000009
	jr gt, HDAE5000_FileLBNNameCheck_Default                       ; [6a 75] jr GT,0x2875f5
	add	xwa, xwa
	add	xwa, HDAE5000_FileLBNNameCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_FileLBNNameCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_FileLBNNameCheck_Ev01E00047:
	ld	xiz, xde
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_FileLBNNameCheck_Ev01E00047_Skip                       ; [6e 22] jr NZ,0x2875c1
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_SongRecord_Address
	push xhl
	pushw HDAE5000_Fmt_s_FileLBNNameCheck@hi16
	pushw HDAE5000_Fmt_s_FileLBNNameCheck@lo16		; low half of HDAE5000_Fmt_s_FileLBNNameCheck
	ld xwa, (xiz + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_FileLBNNameCheck_Ev01E00047_Join                        ; [68 10] jr T,0x2875d1
HDAE5000_FileLBNNameCheck_Ev01E00047_Skip:
	pushw HDAE5000_Str_Blank26@hi16
	pushw HDAE5000_Str_Blank26@lo16		; low half of HDAE5000_Str_Blank26
	ld xwa, (xiz + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_FileLBNNameCheck_Ev01E00047_Join:
	ld xhl, (xsp + 0x04)
	jr t, HDAE5000_FileLBNNameCheck_Epilogue                        ; [68 21] jr T,0x2875f7
HDAE5000_FileLBNNameCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr t, HDAE5000_FileLBNNameCheck_Epilogue                        ; [68 1d] jr T,0x2875f7
HDAE5000_FileLBNNameCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr t, HDAE5000_FileLBNNameCheck_Epilogue                        ; [68 19] jr T,0x2875f7
HDAE5000_FileLBNNameCheck_Ev01E00043:
	ld	xhl, 0:i3
	jr t, HDAE5000_FileLBNNameCheck_Epilogue                        ; [68 15] jr T,0x2875f7
HDAE5000_FileLBNNameCheck_Ev01E00044:
	ld	xhl, 0:i3
	jr t, HDAE5000_FileLBNNameCheck_Epilogue                        ; [68 11] jr T,0x2875f7
HDAE5000_FileLBNNameCheck_Ev01E00045:
	lda xhl, (0x22aa57:24)
	jr t, HDAE5000_FileLBNNameCheck_Epilogue                        ; [68 0a] jr T,0x2875f7
HDAE5000_FileLBNNameCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_FileLBNNameCheck_Epilogue                        ; [68 06] jr T,0x2875f7
HDAE5000_FileLBNNameCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr t, HDAE5000_FileLBNNameCheck_Epilogue                        ; [68 02] jr T,0x2875f7
HDAE5000_FileLBNNameCheck_Default:
	ld	xhl, 0:i3
HDAE5000_FileLBNNameCheck_Epilogue:
	pop xiz
	inc 4, xsp
	ret

HDAE5000_LBNLswBitCheck:
	; registered as "LBNLswBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_LBNLswBitCheck_OnRamDataReq                       ; [76 b8 00] jrl Z,0x2876c1
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl lt, HDAE5000_LBNLswBitCheck_Default                      ; [71 e9 00] jrl LT,0x287701
	cp	xwa, 0x00000009
	jrl gt, HDAE5000_LBNLswBitCheck_Default                      ; [7a e0 00] jrl GT,0x287701
	add	xwa, xwa
	add	xwa, HDAE5000_LBNLswBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNLswBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_LBNLswBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNLswBitCheck_Ev01E00047_Skip                       ; [6e 23] jr NZ,0x287661
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LBNLswBitCheck@hi16
	pushw HDAE5000_Fmt_s_LBNLswBitCheck@lo16		; low half of HDAE5000_Fmt_s_LBNLswBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_LBNLswBitCheck_Ev01E00047_Join                        ; [68 10] jr T,0x287671
HDAE5000_LBNLswBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_LBNLswBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl t, HDAE5000_LBNLswBitCheck_Epilogue                       ; [78 8d 00] jrl T,0x287703
HDAE5000_LBNLswBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNLswBitCheck_Epilogue                       ; [78 88 00] jrl T,0x287703
HDAE5000_LBNLswBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNLswBitCheck_Epilogue                       ; [78 83 00] jrl T,0x287703
HDAE5000_LBNLswBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNLswBitCheck_Ev01E00043_Skip                       ; [6e 0e] jr NZ,0x287697
	ld	xhl, 2:i3
	cp	(0x22AA4E:24), 0
	jr nz, HDAE5000_LBNLswBitCheck_Ev01E00043_Join                       ; [6e 06] jr NZ,0x287699
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNLswBitCheck_Ev01E00043_Join                        ; [68 02] jr T,0x287699
HDAE5000_LBNLswBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNLswBitCheck_Ev01E00043_Join:
	jr t, HDAE5000_LBNLswBitCheck_Epilogue                        ; [68 68] jr T,0x287703
HDAE5000_LBNLswBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNLswBitCheck_Ev01E00044_Skip                       ; [6e 0e] jr NZ,0x2876b2
	ld	xhl, 1:i3
	cp	(0x22AA4E:24), 0
	jr nz, HDAE5000_LBNLswBitCheck_Ev01E00044_Join                       ; [6e 06] jr NZ,0x2876b4
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNLswBitCheck_Ev01E00044_Join                        ; [68 02] jr T,0x2876b4
HDAE5000_LBNLswBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNLswBitCheck_Ev01E00044_Join:
	jr t, HDAE5000_LBNLswBitCheck_Epilogue                        ; [68 4d] jr T,0x287703
HDAE5000_LBNLswBitCheck_Ev01E00045:
	lda xhl, (0x22aa4e:24)
	jr t, HDAE5000_LBNLswBitCheck_Epilogue                        ; [68 46] jr T,0x287703
HDAE5000_LBNLswBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_LBNLswBitCheck_Epilogue                        ; [68 42] jr T,0x287703
HDAE5000_LBNLswBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNLswBitCheck_Ev01E00046_Skip                       ; [6e 22] jr NZ,0x2876ec
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa                                ; push WA
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_LBNLswBitCheck_Ev01E00046_Join                        ; [68 11] jr T,0x2876fd
HDAE5000_LBNLswBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNLswBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNLswBitCheck_Epilogue                        ; [68 02] jr T,0x287703
HDAE5000_LBNLswBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LBNLswBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LBNPmtBitCheck:
	; registered as "LBNPmtBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_LBNPmtBitCheck_OnRamDataReq                       ; [76 b8 00] jrl Z,0x2877cb
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl lt, HDAE5000_LBNPmtBitCheck_Default                      ; [71 e9 00] jrl LT,0x28780b
	cp	xwa, 0x00000009
	jrl gt, HDAE5000_LBNPmtBitCheck_Default                      ; [7a e0 00] jrl GT,0x28780b
	add	xwa, xwa
	add	xwa, HDAE5000_LBNPmtBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNPmtBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_LBNPmtBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNPmtBitCheck_Ev01E00047_Skip                       ; [6e 23] jr NZ,0x28776b
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LBNPmtBitCheck@hi16
	pushw HDAE5000_Fmt_s_LBNPmtBitCheck@lo16		; low half of HDAE5000_Fmt_s_LBNPmtBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_LBNPmtBitCheck_Ev01E00047_Join                        ; [68 10] jr T,0x28777b
HDAE5000_LBNPmtBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_LBNPmtBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl t, HDAE5000_LBNPmtBitCheck_Epilogue                       ; [78 8d 00] jrl T,0x28780d
HDAE5000_LBNPmtBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNPmtBitCheck_Epilogue                       ; [78 88 00] jrl T,0x28780d
HDAE5000_LBNPmtBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNPmtBitCheck_Epilogue                       ; [78 83 00] jrl T,0x28780d
HDAE5000_LBNPmtBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNPmtBitCheck_Ev01E00043_Skip                       ; [6e 0e] jr NZ,0x2877a1
	ld	xhl, 2:i3
	cp	(0x22AA4F:24), 0
	jr nz, HDAE5000_LBNPmtBitCheck_Ev01E00043_Join                       ; [6e 06] jr NZ,0x2877a3
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNPmtBitCheck_Ev01E00043_Join                        ; [68 02] jr T,0x2877a3
HDAE5000_LBNPmtBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNPmtBitCheck_Ev01E00043_Join:
	jr t, HDAE5000_LBNPmtBitCheck_Epilogue                        ; [68 68] jr T,0x28780d
HDAE5000_LBNPmtBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNPmtBitCheck_Ev01E00044_Skip                       ; [6e 0e] jr NZ,0x2877bc
	ld	xhl, 1:i3
	cp	(0x22AA4F:24), 0
	jr nz, HDAE5000_LBNPmtBitCheck_Ev01E00044_Join                       ; [6e 06] jr NZ,0x2877be
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNPmtBitCheck_Ev01E00044_Join                        ; [68 02] jr T,0x2877be
HDAE5000_LBNPmtBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNPmtBitCheck_Ev01E00044_Join:
	jr t, HDAE5000_LBNPmtBitCheck_Epilogue                        ; [68 4d] jr T,0x28780d
HDAE5000_LBNPmtBitCheck_Ev01E00045:
	lda xhl, (0x22aa4f:24)
	jr t, HDAE5000_LBNPmtBitCheck_Epilogue                        ; [68 46] jr T,0x28780d
HDAE5000_LBNPmtBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_LBNPmtBitCheck_Epilogue                        ; [68 42] jr T,0x28780d
HDAE5000_LBNPmtBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNPmtBitCheck_Ev01E00046_Skip                       ; [6e 22] jr NZ,0x2877f6
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa                                ; push WA
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_LBNPmtBitCheck_Ev01E00046_Join                        ; [68 11] jr T,0x287807
HDAE5000_LBNPmtBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNPmtBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNPmtBitCheck_Epilogue                        ; [68 02] jr T,0x28780d
HDAE5000_LBNPmtBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LBNPmtBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LBNSqtBitCheck:
	; registered as "LBNSqtBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_LBNSqtBitCheck_OnRamDataReq                       ; [76 b8 00] jrl Z,0x2878d5
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl lt, HDAE5000_LBNSqtBitCheck_Default                      ; [71 e9 00] jrl LT,0x287915
	cp	xwa, 0x00000009
	jrl gt, HDAE5000_LBNSqtBitCheck_Default                      ; [7a e0 00] jrl GT,0x287915
	add	xwa, xwa
	add	xwa, HDAE5000_LBNSqtBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNSqtBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_LBNSqtBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNSqtBitCheck_Ev01E00047_Skip                       ; [6e 23] jr NZ,0x287875
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LBNSqtBitCheck@hi16
	pushw HDAE5000_Fmt_s_LBNSqtBitCheck@lo16		; low half of HDAE5000_Fmt_s_LBNSqtBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_LBNSqtBitCheck_Ev01E00047_Join                        ; [68 10] jr T,0x287885
HDAE5000_LBNSqtBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_LBNSqtBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl t, HDAE5000_LBNSqtBitCheck_Epilogue                       ; [78 8d 00] jrl T,0x287917
HDAE5000_LBNSqtBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNSqtBitCheck_Epilogue                       ; [78 88 00] jrl T,0x287917
HDAE5000_LBNSqtBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNSqtBitCheck_Epilogue                       ; [78 83 00] jrl T,0x287917
HDAE5000_LBNSqtBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNSqtBitCheck_Ev01E00043_Skip                       ; [6e 0e] jr NZ,0x2878ab
	ld	xhl, 2:i3
	cp	(0x22AA50:24), 0
	jr nz, HDAE5000_LBNSqtBitCheck_Ev01E00043_Join                       ; [6e 06] jr NZ,0x2878ad
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNSqtBitCheck_Ev01E00043_Join                        ; [68 02] jr T,0x2878ad
HDAE5000_LBNSqtBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNSqtBitCheck_Ev01E00043_Join:
	jr t, HDAE5000_LBNSqtBitCheck_Epilogue                        ; [68 68] jr T,0x287917
HDAE5000_LBNSqtBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNSqtBitCheck_Ev01E00044_Skip                       ; [6e 0e] jr NZ,0x2878c6
	ld	xhl, 1:i3
	cp	(0x22AA50:24), 0
	jr nz, HDAE5000_LBNSqtBitCheck_Ev01E00044_Join                       ; [6e 06] jr NZ,0x2878c8
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNSqtBitCheck_Ev01E00044_Join                        ; [68 02] jr T,0x2878c8
HDAE5000_LBNSqtBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNSqtBitCheck_Ev01E00044_Join:
	jr t, HDAE5000_LBNSqtBitCheck_Epilogue                        ; [68 4d] jr T,0x287917
HDAE5000_LBNSqtBitCheck_Ev01E00045:
	lda xhl, (0x22aa50:24)
	jr t, HDAE5000_LBNSqtBitCheck_Epilogue                        ; [68 46] jr T,0x287917
HDAE5000_LBNSqtBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_LBNSqtBitCheck_Epilogue                        ; [68 42] jr T,0x287917
HDAE5000_LBNSqtBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNSqtBitCheck_Ev01E00046_Skip                       ; [6e 22] jr NZ,0x287900
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa                                ; push WA
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_LBNSqtBitCheck_Ev01E00046_Join                        ; [68 11] jr T,0x287911
HDAE5000_LBNSqtBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNSqtBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNSqtBitCheck_Epilogue                        ; [68 02] jr T,0x287917
HDAE5000_LBNSqtBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LBNSqtBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LBNCmpBitCheck:
	; registered as "LBNCmpBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_LBNCmpBitCheck_OnRamDataReq                       ; [76 b8 00] jrl Z,0x2879df
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl lt, HDAE5000_LBNCmpBitCheck_Default                      ; [71 e9 00] jrl LT,0x287a1f
	cp	xwa, 0x00000009
	jrl gt, HDAE5000_LBNCmpBitCheck_Default                      ; [7a e0 00] jrl GT,0x287a1f
	add	xwa, xwa
	add	xwa, HDAE5000_LBNCmpBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNCmpBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_LBNCmpBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNCmpBitCheck_Ev01E00047_Skip                       ; [6e 23] jr NZ,0x28797f
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LBNCmpBitCheck@hi16
	pushw HDAE5000_Fmt_s_LBNCmpBitCheck@lo16		; low half of HDAE5000_Fmt_s_LBNCmpBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_LBNCmpBitCheck_Ev01E00047_Join                        ; [68 10] jr T,0x28798f
HDAE5000_LBNCmpBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_LBNCmpBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl t, HDAE5000_LBNCmpBitCheck_Epilogue                       ; [78 8d 00] jrl T,0x287a21
HDAE5000_LBNCmpBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNCmpBitCheck_Epilogue                       ; [78 88 00] jrl T,0x287a21
HDAE5000_LBNCmpBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNCmpBitCheck_Epilogue                       ; [78 83 00] jrl T,0x287a21
HDAE5000_LBNCmpBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNCmpBitCheck_Ev01E00043_Skip                       ; [6e 0e] jr NZ,0x2879b5
	ld	xhl, 2:i3
	cp	(0x22AA51:24), 0
	jr nz, HDAE5000_LBNCmpBitCheck_Ev01E00043_Join                       ; [6e 06] jr NZ,0x2879b7
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNCmpBitCheck_Ev01E00043_Join                        ; [68 02] jr T,0x2879b7
HDAE5000_LBNCmpBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNCmpBitCheck_Ev01E00043_Join:
	jr t, HDAE5000_LBNCmpBitCheck_Epilogue                        ; [68 68] jr T,0x287a21
HDAE5000_LBNCmpBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNCmpBitCheck_Ev01E00044_Skip                       ; [6e 0e] jr NZ,0x2879d0
	ld	xhl, 1:i3
	cp	(0x22AA51:24), 0
	jr nz, HDAE5000_LBNCmpBitCheck_Ev01E00044_Join                       ; [6e 06] jr NZ,0x2879d2
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNCmpBitCheck_Ev01E00044_Join                        ; [68 02] jr T,0x2879d2
HDAE5000_LBNCmpBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNCmpBitCheck_Ev01E00044_Join:
	jr t, HDAE5000_LBNCmpBitCheck_Epilogue                        ; [68 4d] jr T,0x287a21
HDAE5000_LBNCmpBitCheck_Ev01E00045:
	lda xhl, (0x22aa51:24)
	jr t, HDAE5000_LBNCmpBitCheck_Epilogue                        ; [68 46] jr T,0x287a21
HDAE5000_LBNCmpBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_LBNCmpBitCheck_Epilogue                        ; [68 42] jr T,0x287a21
HDAE5000_LBNCmpBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNCmpBitCheck_Ev01E00046_Skip                       ; [6e 22] jr NZ,0x287a0a
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa                                ; push WA
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_LBNCmpBitCheck_Ev01E00046_Join                        ; [68 11] jr T,0x287a1b
HDAE5000_LBNCmpBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNCmpBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNCmpBitCheck_Epilogue                        ; [68 02] jr T,0x287a21
HDAE5000_LBNCmpBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LBNCmpBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LBNTmBitCheck:
	; registered as "LBNTmBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_LBNTmBitCheck_OnRamDataReq                       ; [76 b8 00] jrl Z,0x287ae9
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl lt, HDAE5000_LBNTmBitCheck_Default                      ; [71 e9 00] jrl LT,0x287b29
	cp	xwa, 0x00000009
	jrl gt, HDAE5000_LBNTmBitCheck_Default                      ; [7a e0 00] jrl GT,0x287b29
	add	xwa, xwa
	add	xwa, HDAE5000_LBNTmBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNTmBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_LBNTmBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNTmBitCheck_Ev01E00047_Skip                       ; [6e 23] jr NZ,0x287a89
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LBNTmBitCheck@hi16
	pushw HDAE5000_Fmt_s_LBNTmBitCheck@lo16		; low half of HDAE5000_Fmt_s_LBNTmBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_LBNTmBitCheck_Ev01E00047_Join                        ; [68 10] jr T,0x287a99
HDAE5000_LBNTmBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_LBNTmBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl t, HDAE5000_LBNTmBitCheck_Epilogue                       ; [78 8d 00] jrl T,0x287b2b
HDAE5000_LBNTmBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNTmBitCheck_Epilogue                       ; [78 88 00] jrl T,0x287b2b
HDAE5000_LBNTmBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNTmBitCheck_Epilogue                       ; [78 83 00] jrl T,0x287b2b
HDAE5000_LBNTmBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNTmBitCheck_Ev01E00043_Skip                       ; [6e 0e] jr NZ,0x287abf
	ld	xhl, 2:i3
	cp	(0x22AA52:24), 0
	jr nz, HDAE5000_LBNTmBitCheck_Ev01E00043_Join                       ; [6e 06] jr NZ,0x287ac1
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNTmBitCheck_Ev01E00043_Join                        ; [68 02] jr T,0x287ac1
HDAE5000_LBNTmBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNTmBitCheck_Ev01E00043_Join:
	jr t, HDAE5000_LBNTmBitCheck_Epilogue                        ; [68 68] jr T,0x287b2b
HDAE5000_LBNTmBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNTmBitCheck_Ev01E00044_Skip                       ; [6e 0e] jr NZ,0x287ada
	ld	xhl, 1:i3
	cp	(0x22AA52:24), 0
	jr nz, HDAE5000_LBNTmBitCheck_Ev01E00044_Join                       ; [6e 06] jr NZ,0x287adc
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNTmBitCheck_Ev01E00044_Join                        ; [68 02] jr T,0x287adc
HDAE5000_LBNTmBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNTmBitCheck_Ev01E00044_Join:
	jr t, HDAE5000_LBNTmBitCheck_Epilogue                        ; [68 4d] jr T,0x287b2b
HDAE5000_LBNTmBitCheck_Ev01E00045:
	lda xhl, (0x22aa52:24)
	jr t, HDAE5000_LBNTmBitCheck_Epilogue                        ; [68 46] jr T,0x287b2b
HDAE5000_LBNTmBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_LBNTmBitCheck_Epilogue                        ; [68 42] jr T,0x287b2b
HDAE5000_LBNTmBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNTmBitCheck_Ev01E00046_Skip                       ; [6e 22] jr NZ,0x287b14
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa                                ; push WA
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_LBNTmBitCheck_Ev01E00046_Join                        ; [68 11] jr T,0x287b25
HDAE5000_LBNTmBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNTmBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNTmBitCheck_Epilogue                        ; [68 02] jr T,0x287b2b
HDAE5000_LBNTmBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LBNTmBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LBNMspBitCheck:
	; registered as "LBNMspBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_LBNMspBitCheck_OnRamDataReq                       ; [76 b8 00] jrl Z,0x287bf3
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl lt, HDAE5000_LBNMspBitCheck_Default                      ; [71 e9 00] jrl LT,0x287c33
	cp	xwa, 0x00000009
	jrl gt, HDAE5000_LBNMspBitCheck_Default                      ; [7a e0 00] jrl GT,0x287c33
	add	xwa, xwa
	add	xwa, HDAE5000_LBNMspBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNMspBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_LBNMspBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNMspBitCheck_Ev01E00047_Skip                       ; [6e 23] jr NZ,0x287b93
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LBNMspBitCheck@hi16
	pushw HDAE5000_Fmt_s_LBNMspBitCheck@lo16		; low half of HDAE5000_Fmt_s_LBNMspBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_LBNMspBitCheck_Ev01E00047_Join                        ; [68 10] jr T,0x287ba3
HDAE5000_LBNMspBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_LBNMspBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl t, HDAE5000_LBNMspBitCheck_Epilogue                       ; [78 8d 00] jrl T,0x287c35
HDAE5000_LBNMspBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNMspBitCheck_Epilogue                       ; [78 88 00] jrl T,0x287c35
HDAE5000_LBNMspBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNMspBitCheck_Epilogue                       ; [78 83 00] jrl T,0x287c35
HDAE5000_LBNMspBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNMspBitCheck_Ev01E00043_Skip                       ; [6e 0e] jr NZ,0x287bc9
	ld	xhl, 2:i3
	cp	(0x22AA53:24), 0
	jr nz, HDAE5000_LBNMspBitCheck_Ev01E00043_Join                       ; [6e 06] jr NZ,0x287bcb
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNMspBitCheck_Ev01E00043_Join                        ; [68 02] jr T,0x287bcb
HDAE5000_LBNMspBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNMspBitCheck_Ev01E00043_Join:
	jr t, HDAE5000_LBNMspBitCheck_Epilogue                        ; [68 68] jr T,0x287c35
HDAE5000_LBNMspBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNMspBitCheck_Ev01E00044_Skip                       ; [6e 0e] jr NZ,0x287be4
	ld	xhl, 1:i3
	cp	(0x22AA53:24), 0
	jr nz, HDAE5000_LBNMspBitCheck_Ev01E00044_Join                       ; [6e 06] jr NZ,0x287be6
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNMspBitCheck_Ev01E00044_Join                        ; [68 02] jr T,0x287be6
HDAE5000_LBNMspBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNMspBitCheck_Ev01E00044_Join:
	jr t, HDAE5000_LBNMspBitCheck_Epilogue                        ; [68 4d] jr T,0x287c35
HDAE5000_LBNMspBitCheck_Ev01E00045:
	lda xhl, (0x22aa53:24)
	jr t, HDAE5000_LBNMspBitCheck_Epilogue                        ; [68 46] jr T,0x287c35
HDAE5000_LBNMspBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_LBNMspBitCheck_Epilogue                        ; [68 42] jr T,0x287c35
HDAE5000_LBNMspBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNMspBitCheck_Ev01E00046_Skip                       ; [6e 22] jr NZ,0x287c1e
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa                                ; push WA
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_LBNMspBitCheck_Ev01E00046_Join                        ; [68 11] jr T,0x287c2f
HDAE5000_LBNMspBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNMspBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNMspBitCheck_Epilogue                        ; [68 02] jr T,0x287c35
HDAE5000_LBNMspBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LBNMspBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LBNRcmBitCheck:
	; registered as "LBNRcmBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_LBNRcmBitCheck_OnRamDataReq                       ; [76 b8 00] jrl Z,0x287cfd
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl lt, HDAE5000_LBNRcmBitCheck_Default                      ; [71 e9 00] jrl LT,0x287d3d
	cp	xwa, 0x00000009
	jrl gt, HDAE5000_LBNRcmBitCheck_Default                      ; [7a e0 00] jrl GT,0x287d3d
	add	xwa, xwa
	add	xwa, HDAE5000_LBNRcmBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNRcmBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_LBNRcmBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNRcmBitCheck_Ev01E00047_Skip                       ; [6e 23] jr NZ,0x287c9d
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LBNRcmBitCheck@hi16
	pushw HDAE5000_Fmt_s_LBNRcmBitCheck@lo16		; low half of HDAE5000_Fmt_s_LBNRcmBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_LBNRcmBitCheck_Ev01E00047_Join                        ; [68 10] jr T,0x287cad
HDAE5000_LBNRcmBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_LBNRcmBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl t, HDAE5000_LBNRcmBitCheck_Epilogue                       ; [78 8d 00] jrl T,0x287d3f
HDAE5000_LBNRcmBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNRcmBitCheck_Epilogue                       ; [78 88 00] jrl T,0x287d3f
HDAE5000_LBNRcmBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNRcmBitCheck_Epilogue                       ; [78 83 00] jrl T,0x287d3f
HDAE5000_LBNRcmBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNRcmBitCheck_Ev01E00043_Skip                       ; [6e 0e] jr NZ,0x287cd3
	ld	xhl, 2:i3
	cp	(0x22AA54:24), 0
	jr nz, HDAE5000_LBNRcmBitCheck_Ev01E00043_Join                       ; [6e 06] jr NZ,0x287cd5
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNRcmBitCheck_Ev01E00043_Join                        ; [68 02] jr T,0x287cd5
HDAE5000_LBNRcmBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNRcmBitCheck_Ev01E00043_Join:
	jr t, HDAE5000_LBNRcmBitCheck_Epilogue                        ; [68 68] jr T,0x287d3f
HDAE5000_LBNRcmBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNRcmBitCheck_Ev01E00044_Skip                       ; [6e 0e] jr NZ,0x287cee
	ld	xhl, 1:i3
	cp	(0x22AA54:24), 0
	jr nz, HDAE5000_LBNRcmBitCheck_Ev01E00044_Join                       ; [6e 06] jr NZ,0x287cf0
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNRcmBitCheck_Ev01E00044_Join                        ; [68 02] jr T,0x287cf0
HDAE5000_LBNRcmBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNRcmBitCheck_Ev01E00044_Join:
	jr t, HDAE5000_LBNRcmBitCheck_Epilogue                        ; [68 4d] jr T,0x287d3f
HDAE5000_LBNRcmBitCheck_Ev01E00045:
	lda xhl, (0x22aa54:24)
	jr t, HDAE5000_LBNRcmBitCheck_Epilogue                        ; [68 46] jr T,0x287d3f
HDAE5000_LBNRcmBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_LBNRcmBitCheck_Epilogue                        ; [68 42] jr T,0x287d3f
HDAE5000_LBNRcmBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNRcmBitCheck_Ev01E00046_Skip                       ; [6e 22] jr NZ,0x287d28
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa                                ; push WA
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_LBNRcmBitCheck_Ev01E00046_Join                        ; [68 11] jr T,0x287d39
HDAE5000_LBNRcmBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNRcmBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNRcmBitCheck_Epilogue                        ; [68 02] jr T,0x287d3f
HDAE5000_LBNRcmBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LBNRcmBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LBNMdBitCheck:
	; registered as "LBNMdBitCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_LBNMdBitCheck_OnRamDataReq                       ; [76 b8 00] jrl Z,0x287e07
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl lt, HDAE5000_LBNMdBitCheck_Default                      ; [71 e9 00] jrl LT,0x287e47
	cp	xwa, 0x00000009
	jrl gt, HDAE5000_LBNMdBitCheck_Default                      ; [7a e0 00] jrl GT,0x287e47
	add	xwa, xwa
	add	xwa, HDAE5000_LBNMdBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNMdBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_LBNMdBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNMdBitCheck_Ev01E00047_Skip                       ; [6e 23] jr NZ,0x287da7
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LBNMdBitCheck@hi16
	pushw HDAE5000_Fmt_s_LBNMdBitCheck@lo16		; low half of HDAE5000_Fmt_s_LBNMdBitCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_LBNMdBitCheck_Ev01E00047_Join                        ; [68 10] jr T,0x287db7
HDAE5000_LBNMdBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_LBNMdBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl t, HDAE5000_LBNMdBitCheck_Epilogue                       ; [78 8d 00] jrl T,0x287e49
HDAE5000_LBNMdBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNMdBitCheck_Epilogue                       ; [78 88 00] jrl T,0x287e49
HDAE5000_LBNMdBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNMdBitCheck_Epilogue                       ; [78 83 00] jrl T,0x287e49
HDAE5000_LBNMdBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNMdBitCheck_Ev01E00043_Skip                       ; [6e 0e] jr NZ,0x287ddd
	ld	xhl, 2:i3
	cp	(0x22AA55:24), 0
	jr nz, HDAE5000_LBNMdBitCheck_Ev01E00043_Join                       ; [6e 06] jr NZ,0x287ddf
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNMdBitCheck_Ev01E00043_Join                        ; [68 02] jr T,0x287ddf
HDAE5000_LBNMdBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNMdBitCheck_Ev01E00043_Join:
	jr t, HDAE5000_LBNMdBitCheck_Epilogue                        ; [68 68] jr T,0x287e49
HDAE5000_LBNMdBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNMdBitCheck_Ev01E00044_Skip                       ; [6e 0e] jr NZ,0x287df8
	ld	xhl, 1:i3
	cp	(0x22AA55:24), 0
	jr nz, HDAE5000_LBNMdBitCheck_Ev01E00044_Join                       ; [6e 06] jr NZ,0x287dfa
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNMdBitCheck_Ev01E00044_Join                        ; [68 02] jr T,0x287dfa
HDAE5000_LBNMdBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNMdBitCheck_Ev01E00044_Join:
	jr t, HDAE5000_LBNMdBitCheck_Epilogue                        ; [68 4d] jr T,0x287e49
HDAE5000_LBNMdBitCheck_Ev01E00045:
	lda xhl, (0x22aa55:24)
	jr t, HDAE5000_LBNMdBitCheck_Epilogue                        ; [68 46] jr T,0x287e49
HDAE5000_LBNMdBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_LBNMdBitCheck_Epilogue                        ; [68 42] jr T,0x287e49
HDAE5000_LBNMdBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNMdBitCheck_Ev01E00046_Skip                       ; [6e 22] jr NZ,0x287e32
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa                                ; push WA
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_LBNMdBitCheck_Ev01E00046_Join                        ; [68 11] jr T,0x287e43
HDAE5000_LBNMdBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNMdBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNMdBitCheck_Epilogue                        ; [68 02] jr T,0x287e49
HDAE5000_LBNMdBitCheck_Default:
	ld	xhl, 0:i3
HDAE5000_LBNMdBitCheck_Epilogue:
	pop xiz
	ret

HDAE5000_LBNTlxBitCheck_Unregistered:
	; The ninth member of the LBN*BitCheck family: the same code as
	; HDAE5000_LBNMdBitCheck, but on flag byte 0x22AA56 -- the byte
	; HDAE5000_SfxTlxBitCheck reads, so this is the TLX-file counterpart.
	; It has no entry in HDAE5000_ObjHandler_Table (HDAE5000_ObjName_Table
	; holds no "LBNTlxBitCheck"), no reference anywhere in the image
	; (scripts/analysis/hdae5000_reachability.py), and so never runs.
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl z, HDAE5000_LBNTlxBitCheck_Unregistered_OnRamDataReq                       ; [76 b8 00] jrl Z,0x287f11
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl lt, HDAE5000_LBNTlxBitCheck_Unregistered_Default                      ; [71 e9 00] jrl LT,0x287f51
	cp	xwa, 0x00000009
	jrl gt, HDAE5000_LBNTlxBitCheck_Unregistered_Default                      ; [7a e0 00] jrl GT,0x287f51
	add	xwa, xwa
	add	xwa, HDAE5000_LBNTlxBitCheck_Unregistered_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047:24)
	jp	t, (xix+wa)	; jp T,XIX+WA
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Skip                       ; [6e 23] jr NZ,0x287eb1
	ld xwa, (xde + 0x0e)
	sll	xwa, 0x02
	ld	xbc, HDAE5000_TextPtrs_Chr2D2D2D_NO_YES
	add	xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_LBNTlxBitCheck_Unregistered@hi16
	pushw HDAE5000_Fmt_s_LBNTlxBitCheck_Unregistered@lo16		; low half of HDAE5000_Fmt_s_LBNTlxBitCheck_Unregistered
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Join                        ; [68 10] jr T,0x287ec1
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Join:
	ld	xhl, xiz
	jrl t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue                       ; [78 8d 00] jrl T,0x287f53
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E0003E:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue                       ; [78 88 00] jrl T,0x287f53
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E0003F:
	ld	xhl, 1:i3
	jrl t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue                       ; [78 83 00] jrl T,0x287f53
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Skip                       ; [6e 0e] jr NZ,0x287ee7
	ld	xhl, 2:i3
	cp	(0x22AA56:24), 0
	jr nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Join                       ; [6e 06] jr NZ,0x287ee9
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Join                        ; [68 02] jr T,0x287ee9
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Join:
	jr t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue                        ; [68 68] jr T,0x287f53
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Skip                       ; [6e 0e] jr NZ,0x287f02
	ld	xhl, 1:i3
	cp	(0x22AA56:24), 0
	jr nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Join                       ; [6e 06] jr NZ,0x287f04
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Join                        ; [68 02] jr T,0x287f04
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Join:
	jr t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue                        ; [68 4d] jr T,0x287f53
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00045:
	lda xhl, (0x22aa56:24)
	jr t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue                        ; [68 46] jr T,0x287f53
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046:
	ld	xhl, 1:i3
	jr t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue                        ; [68 42] jr T,0x287f53
HDAE5000_LBNTlxBitCheck_Unregistered_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Skip                       ; [6e 22] jr NZ,0x287f3c
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa                                ; push WA
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Join                        ; [68 11] jr T,0x287f4d
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue                        ; [68 02] jr T,0x287f53
HDAE5000_LBNTlxBitCheck_Unregistered_Default:
	ld	xhl, 0:i3
HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue:
	pop xiz
	ret



HDAE5000_FlsList_BuildPage:	; 0x287F55 (832 bytes)
	; FS_Read_FSB: Initialize the FSB directory listing display.
	; ^ corrected: one page of the FLS list -- 24 rows of 21 bytes at 0x22A2CA,
	;   "NNN:" (page base 0x23A090 + row + 1) and the FLS name -- the FLS
	;   counterpart of HDAE5000_DirList_BuildPage.  "FSB" and "tile" were guesses.
	; Populates 24 display tile entries in RAM from a ROM template, formats
	; entry numbers (1-24 per page), copies 16-byte tiles to VRAM, then
	; registers two event handlers for the left/right file browser panes.
	;
	; The FSB supports 5 pages x 24 entries = 120 total directory slots.
	; Page selector at 0x23A090 steps by 24 (values: 0, 24, 48, 72, 96).
	;
	; 21-byte in-RAM directory entry layout (at 0x22A2CA + IZ*21):
	;   [0-3]   Header: " N:" where N=entry number (formatted by PPI_Block_Copy)
	;   [4-19]  Display tile: 16-byte text block (filename, initially spaces)
	;   [20]    Terminator: 0x09 (tab character)
	;
	; Part 1: Init loop — populate 24 directory entries from ROM template
	lda	xsp, (xsp-22)
	pushw iz                                ; push iz (compact)
	pushw 0x0781                            ; MemFill pattern (clear display buffer)
	pushw 0x0000
	lda xwa, (0x22a2ca:24); dest = FSB display buffer base
	push xwa
	call HDAE5000_MemFill			; MemFill — clear all 24 entries
	inc 8, xsp			; dealloc 8 bytes
	ld iz, 0:i3			; IZ = 0 (entry index, 0-23)
	cp iz, 0x0018			; pre-check: 24 iterations?
	jrl nc, .LFS_RdFSB__loop_done
.LFS_RdFSB__loop:			; --- per-entry initialization ---
	pushw 0x0015                            ; size = 21 bytes
	lda xwa, (HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage:24); src = ROM template "   :                \t"
	push xwa
	ldw wa, 0x0015			; 21 bytes per entry
	mul xwa, iz			; offset = IZ * 21
	ld xbc, 0x0022a2ca                      ; dest = display buffer + offset
	add xbc, xwa
	push xbc
	call HDAE5000_MemCopy			; MemCopy — copy ROM template to entry slot
	ld wa, (HDAE5000_RAM_FlsPageBase:24); WA = page_base (0/24/48/72/96)
	add wa, iz                              ; WA = page_base + index
	inc 1, wa                               ; WA = entry_number (1-based)
	pushw wa                                ; push entry number
	pushw HDAE5000_Fmt_3_3d_FlsList_BuildPage@hi16		; format spec offset (decimal number formatting) -- high half of HDAE5000_Fmt_3_3d_FlsList_BuildPage
	pushw HDAE5000_Fmt_3_3d_FlsList_BuildPage@lo16		; format handler ROM address		; low half of HDAE5000_Fmt_3_3d_FlsList_BuildPage
	lda xwa, (xsp + 0x12)                   ; XWA = entry buffer ptr
	push xwa
	call HDAE5000_SPrintf            ; format entry number into header bytes [0-2]
	lda xwa, (xsp + 0x16)                   ; XWA = entry buffer ptr
	push xwa
	call HDAE5000_StrLen			; Display_Buffer_Validate — validate display string
	lda xsp, (xsp + 0x18)
	pushw hl                                ; push validated length
	lda xwa, (xsp + 0x04)                   ; XWA = validated string ptr
	push xwa
	ldw wa, 0x0015
	mul xwa, iz
	ld xbc, 0x0022a2ca
	add xbc, xwa
	push xbc                                ; dest = entry buffer
	call HDAE5000_MemCopy                           ; MemCopy — copy validated data back
	lda xsp, (xsp + 0x0a)
	ld wa, (HDAE5000_RAM_FlsPageBase:24); WA = page_base
	add wa, iz                              ; WA = page_base + index (0-based display row)
	call HDAE5000_FlsRecord_Address     ; XHL = VRAM address for this tile row
	pushw 0x0010                            ; size = 16 bytes (display tile only)
	push xhl                                ; dest = VRAM tile address
	ldw wa, 0x0015
	mul xwa, iz
	inc 4, wa			; offset + 4 → skip 4-byte header, point to tile data
	extz xwa
	ld xbc, 0x0022a2ca
	add xbc, xwa                            ; src = entry[4..19] = 16-byte display tile
	push xbc
	call HDAE5000_MemCopy                           ; MemCopy — copy tile to VRAM
	lda xsp, (xsp + 0x0a)
	inc 1, iz			; IZ++ (next entry)
	cp iz, 0x0018
	jrl c, .LFS_RdFSB__loop	; loop while IZ < 24
.LFS_RdFSB__loop_done:
	; --- post two events to the list object SEL_FLS ---
	; (workspace + 0x0E0A = WS_RootFnTable, the main CPU's function table
	; 0x100; the offsets are the firmware's own function names:
	; +0x0124 ApPostEvent, +0x050C GetNamingWindowID, +0x0100 SendEvent --
	; scripts/converters/hdae5000_symbolize_fn_tables.py)
	lda xwa, (0x22a2ca:24); XWA = display buffer base (handler data ptr)
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_SEL_FLS		; object SEL_FLS
	ld xbc, EVT_HDAE_SET_STR_ADR		; event 0x01EA000A
	call (xhl)		; RootFn_ApPostEvent
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_SEL_FLS		; object SEL_FLS
	ld xbc, EVT_PARA_DRAW		; event 0x01C0000F
	ld xde, 0xffffffff		; param 0xFFFFFFFF
	call (xhl)		; RootFn_ApPostEvent
	popw iz                                 ; pop iz (compact)
	lda xsp, (xsp + 0x16)		; dealloc stack frame
	ret
	;
	; Part 2: Event handler A — left pane of file browser (0x288041)
	; Called by UI framework when user interacts with left column.
	; Input: XWA=context, XBC=event_code, XDE=event_param
	; Events handled:
	;   0x01C00007: Action event (sub-codes: 0x0B=navigate, 0x8A=validate string)
	;   0x01E0003A: Copy display tile data (16 bytes from tile buffer)
	;   0x01E0007C: Query tile size → returns 16
	;   0x01E00084: Acknowledge/no-op → returns 0
	;   0x01E00086: Copy display tile data + clear dirty flag
HDAE5000_FlsNamingCheck:
	; registered as "FlsNamingCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa			; save UI context
	cp xbc, EVT_SW_IN
	jr z, .LFS_RdFSB__a_evt07
	cp xbc, EVT_GET_STRING_LENGTH
	jr z, .LFS_RdFSB__a_evt7c
	cp xbc, EVT_GET_NAMING_MODE
	jr z, .LFS_RdFSB__a_evt84
	cp xbc, EVT_SET_STRING
	jr z, .LFS_RdFSB__a_evt86
	cp xbc, EVT_GET_STRING
	jr z, .LFS_RdFSB__a_evt3a
	ld xhl, 0:i3			; unrecognized event → return 0
	jrl t, .LFS_RdFSB__a_exit
.LFS_RdFSB__a_evt3a:			; EVT 0x3A: Read tile — copy 16-byte tile to caller
	pushw 0x0010                            ; size = 16 bytes (tile data)
	lda xwa, (0x23a06e:24); src = current tile buffer
	push xwa
	push xde                                ; dest = caller's buffer (from event param)
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 0x0a)
	ld xhl, xiz                             ; return context pointer
	jrl t, .LFS_RdFSB__a_exit
.LFS_RdFSB__a_evt86:			; EVT 0x86: Write tile + clear dirty flag
	pushw 0x0010                            ; size = 16 bytes
	push xde                                ; src = caller's new tile data
	pushw 0x0023
	pushw 0xa06e		; dest = tile buffer at 0x23A06E
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 0x0a)
	ld (0x23a07e:24), 0x00; clear dirty flag (tile updated)
	ld xhl, xiz
	jrl t, .LFS_RdFSB__a_exit
.LFS_RdFSB__a_evt84:                           ; EVT 0x84: Acknowledge — no action needed
	ld xhl, 0:i3
	jrl t, .LFS_RdFSB__a_exit
.LFS_RdFSB__a_evt7c:                           ; EVT 0x7C: Query tile size → 16 bytes
	ld xhl, 0x00000010
	jrl t, .LFS_RdFSB__a_exit
.LFS_RdFSB__a_evt07:			; EVT 0x07: Action — dispatch on sub-code in XDE
	cp xde, 0x0000000b
	jr z, .LFS_RdFSB__a_case0b
	cp xde, 0x0000008a
	jrl nz, .LFS_RdFSB__a_done
	; Sub-code 0x8A: Validate filename string and update display
	lda xwa, (0x22ad0a:24); XWA = filename string buffer
	calr HDAE5000_NameHistory_Recall            ; validate/sanitize string
	ld xiz, xhl                              ; XIZ = validated string ptr (or NULL)
	ld xwa, xiz
	or xwa, xwa
	jrl z, .LFS_RdFSB__a_done               ; skip if validation failed (NULL)
	ld xwa, xiz
	push xwa
	call HDAE5000_StrLen                            ; Display_Buffer_Validate
	pushw hl                                ; push validated length
	ld xwa, xiz
	push xwa
	lda xwa, (0x23a06e:24); dest = current tile buffer
	push xwa
	call HDAE5000_MemCopy                            ; MemCopy — copy validated name to tile
	lda xsp, (xsp + 0x0e)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)		; RootFn_GetNamingWindowID: the naming window's object id
	ld xwa, (xwa + WS_RootFnTable)
	ld xix, (xwa + RootFn_GetNamingWindowID)
	call (xix)		; XHL = the naming window
	lda xwa, (0x23a06e:24); XDE = tile buffer ptr
	ld xbc, xwa
	ld xwa, xhl                              ; XWA = the naming window
	ld xde, xbc                              ; XDE = tile data
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)		; RootFn_SendEvent(window, 0x01E00086, name): show the recalled name
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_SET_STRING                       ; event 0x01E00086 (this handler answers it at .LFS_RdFSB__a_evt86)
	call (xhl)		; RootFn_SendEvent(window, 0x01E00086, name): show the recalled name
	jr t, .LFS_RdFSB__a_done
.LFS_RdFSB__a_case0b:			; Sub-code 0x0B: Navigate to item — refresh display
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)		; RootFn_GetNamingWindowID: the naming window's object id
	ld xwa, (xwa + WS_RootFnTable)
	ld xix, (xwa + RootFn_GetNamingWindowID)
	call (xix)
	lda xwa, (0x23a06e:24)
	ld xbc, xwa
	ld xwa, xhl
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)		; RootFn_SendEvent(window, 0x01E0003A, buffer): read the typed name
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_GET_STRING
	call (xhl)
	ld wa, (HDAE5000_RAM_CurFls:24); WA = display row base
	lda xbc, (0x23a06e:24); XBC = tile buffer
	ld xde, HDAE5000_OBJ_FLS_SELECT                       ; params: left pane tile ID 0xF0
	calr HDAE5000_FlsName_StoreWithUi		; store the name: please-wait, error screen, name history
	calr HDAE5000_FlsList_BuildPage	; recursive call — refresh page
.LFS_RdFSB__a_done:
	ld xhl, 0:i3
.LFS_RdFSB__a_exit:
	pop xiz
	ret
	;
	; Part 3: Event handler B — right pane of file browser (0x288169)
	; Same event handling as handler A, but operates on the right display column.
	; Key differences: uses tile ID 0x0163 (right pane), and sub-code 0x0B
	; calls FS_Write_FSB instead of FS_Read_FSB (save operation).
HDAE5000_FlsNamingCheck2:
	; registered as "FlsNamingCheck2" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa			; save UI context
	cp xbc, EVT_SW_IN
	jr z, .LFS_RdFSB__b_evt07
	cp xbc, EVT_GET_STRING_LENGTH
	jr z, .LFS_RdFSB__b_evt7c
	cp xbc, EVT_GET_NAMING_MODE
	jr z, .LFS_RdFSB__b_evt84
	cp xbc, EVT_SET_STRING
	jr z, .LFS_RdFSB__b_evt86
	cp xbc, EVT_GET_STRING
	jr z, .LFS_RdFSB__b_evt3a
	ld xhl, 0:i3			; unrecognized event → return 0
	jrl t, .LFS_RdFSB__b_exit
.LFS_RdFSB__b_evt3a:			; EVT 0x3A: Read tile — copy 16-byte tile to caller
	pushw 0x0010
	lda xwa, (0x23a06e:24)
	push xwa
	push xde
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 0x0a)
	ld xhl, xiz
	jrl t, .LFS_RdFSB__b_exit
.LFS_RdFSB__b_evt86:			; EVT 0x86: Write tile + clear dirty flag
	pushw 0x0010
	push xde
	pushw 0x0023
	pushw 0xa06e		; dest = tile buffer at 0x23A06E
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 0x0a)
	ld (0x23a07e:24), 0x00; clear dirty flag
	ld xhl, xiz
	jrl t, .LFS_RdFSB__b_exit
.LFS_RdFSB__b_evt84:                           ; EVT 0x84: Acknowledge — no-op
	ld xhl, 0:i3
	jrl t, .LFS_RdFSB__b_exit
.LFS_RdFSB__b_evt7c:                           ; EVT 0x7C: Query tile size → 16 bytes
	ld xhl, 0x00000010
	jrl t, .LFS_RdFSB__b_exit
.LFS_RdFSB__b_evt07:			; EVT 0x07: Action — dispatch on sub-code
	cp xde, 0x0000000b
	jr z, .LFS_RdFSB__b_case0b
	cp xde, 0x0000008a
	jrl nz, .LFS_RdFSB__b_done
	; Sub-code 0x8A: Validate filename and update display (same as handler A)
	lda xwa, (0x22ad0a:24); filename string buffer
	calr HDAE5000_NameHistory_Recall
	ld xiz, xhl
	ld xwa, xiz
	or xwa, xwa
	jrl z, .LFS_RdFSB__b_done
	ld xwa, xiz
	push xwa
	call HDAE5000_StrLen                            ; Display_Buffer_Validate
	pushw hl                                ; validated length
	ld xwa, xiz
	push xwa
	lda xwa, (0x23a06e:24)
	push xwa
	call HDAE5000_MemCopy                            ; MemCopy — name to tile buffer
	lda xsp, (xsp + 0x0e)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)		; RootFn_GetNamingWindowID: the naming window's object id
	ld xwa, (xwa + WS_RootFnTable)
	ld xix, (xwa + RootFn_GetNamingWindowID)
	call (xix)
	lda xwa, (0x23a06e:24)
	ld xbc, xwa
	ld xwa, xhl
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)		; RootFn_SendEvent(window, 0x01E00086, name): show the recalled name
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_SET_STRING
	call (xhl)
	jr t, .LFS_RdFSB__b_done
.LFS_RdFSB__b_case0b:			; Sub-code 0x0B: Navigate — save and refresh
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)		; RootFn_GetNamingWindowID: the naming window's object id
	ld xwa, (xwa + WS_RootFnTable)
	ld xix, (xwa + RootFn_GetNamingWindowID)
	call (xix)
	lda xwa, (0x23a06e:24)
	ld xbc, xwa
	ld xwa, xhl
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)		; RootFn_SendEvent(window, 0x01E0003A, buffer): read the typed name
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_GET_STRING
	call (xhl)
	ld wa, (HDAE5000_RAM_CurFls:24); WA = display row base
	lda xbc, (0x23a06e:24); XBC = tile buffer
	ld xde, HDAE5000_OBJ_FLS_EDIT                       ; params: right pane tile ID 0x0163
	calr HDAE5000_FlsName_StoreWithUi		; store the name: please-wait, error screen, name history
	ld wa, 1:i3                                ; WA = operation mode 1
	ld bc, 2:i3                                ; BC = sector count 2
	calr HDAE5000_FlsScreen_Refresh               ; → write FSB to disk (save operation)
.LFS_RdFSB__b_done:
	ld xhl, 0:i3
.LFS_RdFSB__b_exit:
	pop xiz
	ret

HDAE5000_FlsScreen_Refresh:	; 0x288295 (5072 bytes)
; FS_Write_FSB: 0x288295 (5072 bytes) — disassembled from original ROM
; ^ now HDAE5000_FlsScreen_Refresh: the FLS screen -- title "... NN:" +
;   the name of FLS 0x23A096, then its items -- the FLS counterpart of
;   HDAE5000_SongScreen_Refresh.  Size = conversion region.

	lda	xsp, (xsp-32)
	pushw iz                                ; push IZ
	ld	(xsp+30), c
	ld	(xsp+32), a
	cp	(xsp+30), 0x00
	jr z, HDAE5000_FlsScreen_Refresh_Join                       ; [66 07] jr Z,0x2882ac
	cp	(xsp+30), 0x02
	jrl nz, HDAE5000_FlsScreen_Refresh_Join2                     ; [7e e4 00] jrl NZ,0x288390
HDAE5000_FlsScreen_Refresh_Join:
	pushw 0x0020
	pushw 0x0000
	lda xwa, (0x22a058:24)
	push xwa
	call HDAE5000_MemFill
	pushw HDAE5000_Str_FLSNAME@hi16
	pushw HDAE5000_Str_FLSNAME@lo16		; low half of HDAE5000_Str_FLSNAME
	pushw 0x0022
	pushw 0xa058
	call HDAE5000_StrCat
	ld	wa, (HDAE5000_RAM_CurFls:24)
	inc	1, wa
	pushw wa                                ; push WA
	pushw HDAE5000_Fmt_2_2d_FlsScreen_Refresh@hi16
	pushw HDAE5000_Fmt_2_2d_FlsScreen_Refresh@lo16		; low half of HDAE5000_Fmt_2_2d_FlsScreen_Refresh
	lda	xwa, (xsp+30)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+26)
	lda	xwa, (xsp+8)
	push xwa
	pushw 0x0022
	pushw 0xa058
	call HDAE5000_StrCat
	pushw HDAE5000_Str_Chr3A_FlsScreen_Refresh@hi16
	pushw HDAE5000_Str_Chr3A_FlsScreen_Refresh@lo16		; low half of HDAE5000_Str_Chr3A_FlsScreen_Refresh
	pushw 0x0022
	pushw 0xa058
	call HDAE5000_StrCat
	lda	xsp, (xsp+16)
	pushw 0x0010
	ld	wa, (HDAE5000_RAM_CurFls:24)
	call HDAE5000_FlsRecord_Address
	push xhl
	pushw 0x0022
	pushw 0xa058
	call HDAE5000_StrNCat
	pushw HDAE5000_Str_Blank0Tab_FlsScreen_Refresh@hi16
	pushw HDAE5000_Str_Blank0Tab_FlsScreen_Refresh@lo16		; low half of HDAE5000_Str_Blank0Tab_FlsScreen_Refresh
	pushw 0x0022
	pushw 0xa058
	call HDAE5000_StrCat
	lda	xsp, (xsp+18)
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds:24)
	ld	xde, (xbc+wa)
	lda xwa, (0x22a058:24)
	ld	xbc, xwa
	ld	xwa, xde
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds:24)
	ld	xwa, (xbc+wa)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
HDAE5000_FlsScreen_Refresh_Join2:
	cp	(xsp+30), 0x00
	jr z, HDAE5000_FlsScreen_Refresh_Join3                       ; [66 07] jr Z,0x28839d
	cp	(xsp+30), 0x02
	jrl nz, HDAE5000_FlsScreen_Refresh_Join6                     ; [7e 49 01] jrl NZ,0x2884e6
HDAE5000_FlsScreen_Refresh_Join3:
	ld	iz, 0:i3
	cp	iz, 0x0010
	jrl nc, HDAE5000_FlsScreen_Refresh_Join5                     ; [7f e0 00] jrl NC,0x288486
HDAE5000_FlsScreen_Refresh_Loop:
	pushw 0x0023
	lda xwa, (HDAE5000_Str_Chr3A2020202020_FlsScreen_Refresh:24)
	push xwa
	ldw	wa, 0x0025
	mul	xwa, iz
	inc	2, wa
	extz xwa
	ld	xbc, 0x0022b020
	add	xbc, xwa
	push xbc
	call HDAE5000_MemCopy
	ld	wa, (0x22B272:24)
	add	wa, iz
	inc	1, wa
	pushw wa                                ; push WA
	pushw HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2@hi16
	pushw HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2@lo16		; low half of HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2
	lda	xwa, (xsp+24)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+28)
	push xwa
	call HDAE5000_StrLen
	lda	xsp, (xsp+24)
	pushw hl                                ; push HL
	lda	xwa, (xsp+10)
	push xwa
	ldw	wa, 0x0025
	mul	xwa, iz
	ld	xbc, 0x0022b020
	add	xbc, xwa
	push xbc
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	ld	bc, (0x22B272:24)
	add	bc, iz
	ld	wa, (HDAE5000_RAM_CurFls:24)
	call HDAE5000_FlsItem_SongRecord
	pushw 0x001a
	push xhl
	ldw	wa, 0x0025
	mul	xwa, iz
	inc	3, wa
	extz xwa
	ld	xbc, 0x0022b020
	add	xbc, xwa
	push xbc
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	ld	bc, (0x22B272:24)
	add	bc, iz
	lda	xwa, (xsp+2)
	ld	xde, xwa
	ld	wa, (HDAE5000_RAM_CurFls:24)
	call HDAE5000_FlsItem_Get
	cp	hl, 0xffff
	jr z, HDAE5000_FlsScreen_Refresh_Next                       ; [66 36] jr Z,0x28847d
	cp	(xsp+6), 0x01
	jr nz, HDAE5000_FlsScreen_Refresh_Join4                      ; [6e 15] jr NZ,0x288462
	ldw	wa, 0x0025
	mul	xwa, iz
	add	wa, 0x0020
	extz xwa
	ld	xbc, 0x0022b020
	add	xbc, xwa
	ld	(xbc), 0x2a
HDAE5000_FlsScreen_Refresh_Join4:
	cp	(xsp+7), 0x01
	jr nz, HDAE5000_FlsScreen_Refresh_Next                      ; [6e 15] jr NZ,0x28847d
	ldw	wa, 0x0025
	mul	xwa, iz
	add	wa, 0x0023
	extz xwa
	ld	xbc, 0x0022b020
	add	xbc, xwa
	ld	(xbc), 0x2a
HDAE5000_FlsScreen_Refresh_Next:
	inc	1, iz
	cp	iz, 0x0010
	jrl c, HDAE5000_FlsScreen_Refresh_Loop                      ; [77 20 ff] jrl C,0x2883a6
HDAE5000_FlsScreen_Refresh_Join5:
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds_2:24)
	ld	xde, (xbc+wa)
	lda xwa, (0x22b020:24)
	ld	xbc, xwa
	ld	xwa, xde
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds_2:24)
	ld	xwa, (xbc+wa)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
HDAE5000_FlsScreen_Refresh_Join6:
	pushw 0x0010
	pushw 0x0000
	lda xwa, (0x22a078:24)
	push xwa
	call HDAE5000_MemFill
	inc 8, xsp                              ; inc 0,XSP
	lda	xwa, (xsp+2)
	ld	xde, xwa
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	call HDAE5000_FlsItem_Get
	ld	iz, hl
	ld	wa, iz
	cp	wa, 0xffff
	jr z, HDAE5000_FlsScreen_Refresh_Skip                       ; [66 1f] jr Z,0x288534
	ld	wa, (xsp+4)
	inc	1, wa
	pushw wa                                ; push WA
	ld	wa, (xsp+4)
	inc	1, wa
	pushw wa                                ; push WA
	pushw HDAE5000_Fmt_LOC_3_3d_2_2d@hi16
	pushw HDAE5000_Fmt_LOC_3_3d_2_2d@lo16		; low half of HDAE5000_Fmt_LOC_3_3d_2_2d
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr t, HDAE5000_FlsScreen_Refresh_Join7                       ; [68 10] jr T,0x288544
HDAE5000_FlsScreen_Refresh_Skip:
	pushw HDAE5000_Str_LOC00000@hi16
	pushw HDAE5000_Str_LOC00000@lo16		; low half of HDAE5000_Str_LOC00000
	lda	xwa, (xsp+12)
	push xwa
	call HDAE5000_SPrintf
	inc 8, xsp                              ; inc 0,XSP
HDAE5000_FlsScreen_Refresh_Join7:
	lda	xwa, (xsp+8)
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push HL
	lda	xwa, (xsp+14)
	push xwa
	lda xwa, (0x22a078:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+14)
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds_3:24)
	ld	xde, (xbc+wa)
	lda xwa, (0x22a078:24)
	ld	xbc, xwa
	ld	xwa, xde
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_HDAE_SET_STR_ADR
	call	(xhl)
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds_3:24)
	ld	xwa, (xbc+wa)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0xffffffff
	call	(xhl)
	cp	iz, 0xffff
	jr z, HDAE5000_FlsScreen_Refresh_Skip2                       ; [66 2a] jr Z,0x2885ee
	ld	wa, (xsp+2)
	ld	bc, (xsp+4)
	call HDAE5000_Song_PartMask
	ld	iz, hl
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds_4:24)
	ld	xwa, (xbc+wa)
	ld	bc, (xsp+2)
	ld	de, (xsp+4)
	pushw iz                                ; push IZ
	calr	HDAE5000_PartList_Build
	jr t, HDAE5000_FlsScreen_Refresh_Join8                       ; [68 1e] jr T,0x28860c
HDAE5000_FlsScreen_Refresh_Skip2:
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds_4:24)
	ld	xwa, (xbc+wa)
	pushw 0xffff
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_FlsScreen_Refresh_Join8:
	cp	(xsp+30), 0x02
	jr z, HDAE5000_FlsScreen_Refresh_Epilogue                       ; [66 54] jr Z,0x288666
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds_5:24)
	ld	xwa, (xbc+wa)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	call	(xhl)
	ld	a, (xsp+32)
	extz wa
	sla	wa, 0x02
	lda xbc, (HDAE5000_FlsScreen_Refresh_ObjIds_6:24)
	ld	xwa, (xbc+wa)
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_FlsScreen_Refresh_Epilogue:
	popw iz                                 ; pop IZ
	lda	xsp, (xsp+32)
	ret

HDAE5000_SelectFlsScreen:
	; registered as "SelectFlsScreen" in HDAE5000_ScreenProc_Table
	push xiz
	ld	xiz, xde
	cp	xbc, EVT_HDAE_OVER_FLOW
	jrl z, HDAE5000_SelectFlsScreen_OnHdaeOverFlow                      ; [76 6f 01] jrl Z,0x2887e6
	cp	xbc, EVT_HDAE_UNDER_FLOW
	jrl z, HDAE5000_SelectFlsScreen_OnHdaeUnderFlow                      ; [76 2c 01] jrl Z,0x2887ac
	cp	xbc, EVT_HDAE_SELECT_SAVE
	jrl z, HDAE5000_SelectFlsScreen_OnHdaeSelectSave                      ; [76 d3 00] jrl Z,0x28875c
	cp	xbc, EVT_HDAE_SELECT_OK2
	jrl z, HDAE5000_SelectFlsScreen_Skip5                      ; [76 95 00] jrl Z,0x288727
	cp	xbc, EVT_HDAE_SELECT_OK
	jrl z, HDAE5000_SelectFlsScreen_Skip5                      ; [76 8c 00] jrl Z,0x288727
	cp	xbc, EVT_SW_IN
	jrl nz, HDAE5000_SelectFlsScreen_Done                     ; [7e 7a 01] jrl NZ,0x28881e
	ld	xde, xiz
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jr z, HDAE5000_SelectFlsScreen_Skip4                       ; [66 51] jr Z,0x28871a
	cp	xhl, 0x00000006
	jr z, HDAE5000_SelectFlsScreen_Skip3                       ; [66 3c] jr Z,0x28870d
	cp	xhl, 0x00000005
	jr z, HDAE5000_SelectFlsScreen_Skip2                       ; [66 27] jr Z,0x288700
	cp	xhl, 0x00000001
	jr z, HDAE5000_SelectFlsScreen_Skip                       ; [66 12] jr Z,0x2886f3
	or xhl, xhl
	jrl nz, HDAE5000_SelectFlsScreen_Done                     ; [7e 38 01] jrl NZ,0x28881e
	ldw	(HDAE5000_RAM_FlsPageBase:24), 0
	calr	HDAE5000_FlsList_BuildPage
	jrl t, HDAE5000_SelectFlsScreen_Done                      ; [78 2b 01] jrl T,0x28881e
HDAE5000_SelectFlsScreen_Skip:
	ldw	(HDAE5000_RAM_FlsPageBase:24), 24
	calr	HDAE5000_FlsList_BuildPage
	jrl t, HDAE5000_SelectFlsScreen_Done                      ; [78 1e 01] jrl T,0x28881e
HDAE5000_SelectFlsScreen_Skip2:
	ldw	(HDAE5000_RAM_FlsPageBase:24), 48
	calr	HDAE5000_FlsList_BuildPage
	jrl t, HDAE5000_SelectFlsScreen_Done                      ; [78 11 01] jrl T,0x28881e
HDAE5000_SelectFlsScreen_Skip3:
	ldw	(HDAE5000_RAM_FlsPageBase:24), 72
	calr	HDAE5000_FlsList_BuildPage
	jrl t, HDAE5000_SelectFlsScreen_Done                      ; [78 04 01] jrl T,0x28881e
HDAE5000_SelectFlsScreen_Skip4:
	ldw	(HDAE5000_RAM_FlsPageBase:24), 96
	calr	HDAE5000_FlsList_BuildPage
	jrl t, HDAE5000_SelectFlsScreen_Done                      ; [78 f7 00] jrl T,0x28881e
HDAE5000_SelectFlsScreen_Skip5:
	ld	bc, (HDAE5000_RAM_FlsPageBase:24)
	ld	wa, iz
	add	wa, bc
	ld	(HDAE5000_RAM_CurFls), wa
	ld	wa, 0:i3
	ld	bc, 2:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_LOAD
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_SelectFlsScreen_Done                      ; [78 c2 00] jrl T,0x28881e
HDAE5000_SelectFlsScreen_OnHdaeSelectSave:
	ld	wa, (HDAE5000_RAM_FlsPageBase:24)
	ld	bc, iz
	add	bc, wa
	ld	(HDAE5000_RAM_CurFls), bc
	ld	wa, bc
	call HDAE5000_FlsRecord_Address
	ld	xde, xhl
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApFuncCall)
	ld	xwa, NAKA_APFUNC_FlsNamingCheck
	ld	xbc, EVT_SET_STRING
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_HDD_FLS_NAMING
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jr t, HDAE5000_SelectFlsScreen_Done                       ; [68 72] jr T,0x28881e
HDAE5000_SelectFlsScreen_OnHdaeUnderFlow:
	cpw	(HDAE5000_RAM_FlsPageBase:24), 24
	jr lt, HDAE5000_SelectFlsScreen_Done                      ; [61 69] jr LT,0x28881e
	subw	(HDAE5000_RAM_FlsPageBase:24), 24
	calr	HDAE5000_FlsList_BuildPage
	ld	xwa, xiz
	add	xwa, 0x00000018
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_SEL_FLS
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jr t, HDAE5000_SelectFlsScreen_Done                       ; [68 38] jr T,0x28881e
HDAE5000_SelectFlsScreen_OnHdaeOverFlow:
	cpw	(HDAE5000_RAM_FlsPageBase:24), 96
	jr ge, HDAE5000_SelectFlsScreen_Done                      ; [69 2f] jr GE,0x28881e
	addw	(HDAE5000_RAM_FlsPageBase:24), 24
	calr	HDAE5000_FlsList_BuildPage
	ld	xwa, xiz
	sub	xwa, 0x00000018
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_SEL_FLS
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
HDAE5000_SelectFlsScreen_Done:
	ld	xhl, 0:i3
	pop xiz
	ret

HDAE5000_FlsLoadScreen:
	; registered as "FlsLoadScreen" in HDAE5000_ScreenProc_Table
	dec	6, xsp
	push xiz
	ld	xiz, xde
	cp	xbc, EVT_HDAE_CHANGE_SEL_NUM
	jrl z, HDAE5000_FlsLoadScreen_OnHdaeChangeSelNum                      ; [76 d5 03] jrl Z,0x288c05
	cp	xbc, EVT_HDAE_OVER_FLOW
	jrl z, HDAE5000_FlsLoadScreen_OnHdaeOverFlow                      ; [76 4a 03] jrl Z,0x288b83
	cp	xbc, EVT_HDAE_UNDER_FLOW
	jrl z, HDAE5000_FlsLoadScreen_OnHdaeUnderFlow                      ; [76 bd 02] jrl Z,0x288aff
	cp	xbc, EVT_HDAE_SELECT_SAVE
	jrl z, HDAE5000_FlsLoadScreen_OnHdaeSelectSave                      ; [76 2a 02] jrl Z,0x288a75
	cp	xbc, EVT_HDAE_SELECT_OK
	jrl z, HDAE5000_FlsLoadScreen_OnHdaeSelectOk                      ; [76 54 01] jrl Z,0x2889a8
	cp	xbc, EVT_SW_IN
	jrl z, HDAE5000_FlsLoadScreen_Done                      ; [76 bd 03] jrl Z,0x288c1a
	cp	xbc, EVT_HDAE_AFTER_LOAD
	jr z, HDAE5000_FlsLoadScreen_OnHdaeAfterLoad                       ; [66 5a] jr Z,0x2888bf
	cp	xbc, EVT_HDAE_SEQ_STOP
	jr z, HDAE5000_FlsLoadScreen_OnHdaeSeqStop                       ; [66 29] jr Z,0x288896
	cp	xbc, EVT_SHOW
	jrl nz, HDAE5000_FlsLoadScreen_Done                     ; [7e a4 03] jrl NZ,0x288c1a
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_BOX
	ld	xbc, EVT_HDAE_CHANGE_SEL_NUM
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsLoadScreen_Done                      ; [78 84 03] jrl T,0x288c1a
HDAE5000_FlsLoadScreen_OnHdaeSeqStop:
	ld	xbc, EVT_HDAE_AFTER_LOAD
	push xbc
	ld	xbc, 0:i3
	push xbc
	ld	xbc, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetApTimer)
	ld	xwa, 0x00000053
	ld	xde, 0xffffffff
	call	(xhl)
	jrl t, HDAE5000_FlsLoadScreen_Done                      ; [78 5b 03] jrl T,0x288c1a
HDAE5000_FlsLoadScreen_OnHdaeAfterLoad:
	cp	(0x22AD9A:24), 1
	jrl nz, HDAE5000_FlsLoadScreen_Done                     ; [7e 52 03] jrl NZ,0x288c1a
	ld	iz, (0x22AD96:24)
	ld	wa, (0x22AD98:24)
	inc	1, wa
	ld	qiz, wa
	cp	wa, 0x0020
	jr c, HDAE5000_FlsLoadScreen_Join2                       ; [67 0f] jr C,0x2888ec
	inc	1, iz
	ld	wa, iz
	cp	wa, 0x0078
	jr c, HDAE5000_FlsLoadScreen_Join                       ; [67 02] jr C,0x2888e9
	ld	iz, 0:i3
HDAE5000_FlsLoadScreen_Join:
	ld	qiz, 0
HDAE5000_FlsLoadScreen_Join2:
	lda	xwa, (xsp+4)
	ld	xde, xwa
	ld	wa, iz
	ld	bc, qiz
	call HDAE5000_FlsItem_Get
	cp	hl, 0xffff
	jrl z, HDAE5000_FlsLoadScreen_Skip2                      ; [76 9e 00] jrl Z,0x28899f
	cp	(xsp+9), 0x01
	jr nz, HDAE5000_FlsLoadScreen_Skip                      ; [6e 15] jr NZ,0x28891c
	ld	(0x22AD9A:24), 1
	ld	(0x22ad96), iz
	ld	wa, qiz
	ld	(0x22ad98), wa
	jr t, HDAE5000_FlsLoadScreen_Join3                       ; [68 06] jr T,0x288922
HDAE5000_FlsLoadScreen_Skip:
	ld	(0x22AD9A:24), 0
HDAE5000_FlsLoadScreen_Join3:
	ld	wa, (xsp+4)
	ld	bc, (xsp+6)
	call HDAE5000_Song_PartMask
	ld	iz, hl
	ld	de, iz
	pushw 0x0000
	ld	xwa, HDAE5000_OBJ_FLS_FILE_LOAD
	push xwa
	ld	wa, (xsp+10)
	ld	bc, (xsp+12)
	calr	HDAE5000_LoadSongWithUi
	cp	hl, 0xffff
	jrl z, HDAE5000_FlsLoadScreen_Done                      ; [76 d1 02] jrl Z,0x288c1a
	cp	(HDAE5000_RAM_LyricJump:24), 2
	jr nz, HDAE5000_FlsLoadScreen_Join4                      ; [6e 29] jr NZ,0x28897a
	ld	wa, iz
	and	wa, 0x0100
	cp	wa, 0x0100
	jr nz, HDAE5000_FlsLoadScreen_Join4                      ; [6e 1d] jr NZ,0x28897a
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_Tech_lyrics
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_FlsLoadScreen_Join4:
	cp	(xsp+8), 0x01
	jrl nz, HDAE5000_FlsLoadScreen_Done                     ; [7e 99 02] jrl NZ,0x288c1a
	pushw 0x0001
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_SwbtWr)
	ldw	wa, 0x0048
	ld	bc, 5:i3
	ld	de, 1:i3
	call	(xhl)
	jrl t, HDAE5000_FlsLoadScreen_Done                      ; [78 7b 02] jrl T,0x288c1a
HDAE5000_FlsLoadScreen_Skip2:
	ld	(0x22AD9A:24), 0
	jrl t, HDAE5000_FlsLoadScreen_Done                      ; [78 72 02] jrl T,0x288c1a
HDAE5000_FlsLoadScreen_OnHdaeSelectOk:
	ld	bc, iz
	ld	wa, (0x22B272:24)
	add	wa, bc
	ld	(0x23a098), wa
	lda	xwa, (xsp+4)
	ld	xde, xwa
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	call HDAE5000_FlsItem_Get
	cp	hl, 0xffff
	jrl z, HDAE5000_FlsLoadScreen_Done                      ; [76 4a 02] jrl Z,0x288c1a
	cp	(xsp+9), 0x01
	jr nz, HDAE5000_FlsLoadScreen_Skip3                      ; [6e 1c] jr NZ,0x2889f2
	ld	(0x22AD9A:24), 1
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	(0x22ad96), wa
	ld	wa, (0x23A098:24)
	ld	(0x22ad98), wa
	jr t, HDAE5000_FlsLoadScreen_Join5                       ; [68 06] jr T,0x2889f8
HDAE5000_FlsLoadScreen_Skip3:
	ld	(0x22AD9A:24), 0
HDAE5000_FlsLoadScreen_Join5:
	ld	wa, (xsp+4)
	ld	bc, (xsp+6)
	call HDAE5000_Song_PartMask
	ld	iz, hl
	ld	de, iz
	pushw 0x0000
	ld	xwa, HDAE5000_OBJ_FLS_FILE_LOAD
	push xwa
	ld	wa, (xsp+10)
	ld	bc, (xsp+12)
	calr	HDAE5000_LoadSongWithUi
	cp	hl, 0xffff
	jrl z, HDAE5000_FlsLoadScreen_Done                      ; [76 fb 01] jrl Z,0x288c1a
	cp	(HDAE5000_RAM_LyricJump:24), 2
	jr nz, HDAE5000_FlsLoadScreen_Join6                      ; [6e 29] jr NZ,0x288a50
	ld	wa, iz
	and	wa, 0x0100
	cp	wa, 0x0100
	jr nz, HDAE5000_FlsLoadScreen_Join6                      ; [6e 1d] jr NZ,0x288a50
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_Tech_lyrics
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_FlsLoadScreen_Join6:
	cp	(xsp+8), 0x01
	jrl nz, HDAE5000_FlsLoadScreen_Done                     ; [7e c3 01] jrl NZ,0x288c1a
	pushw 0x0001
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_SwbtWr)
	ldw	wa, 0x0048
	ld	bc, 5:i3
	ld	de, 1:i3
	call	(xhl)
	jrl t, HDAE5000_FlsLoadScreen_Done                      ; [78 a5 01] jrl T,0x288c1a
HDAE5000_FlsLoadScreen_OnHdaeSelectSave:
	ld	bc, iz
	ld	wa, (0x22B272:24)
	add	wa, bc
	ld	(0x23a098), wa
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	wa, (HDAE5000_RAM_CurFls:24)
	call HDAE5000_Fls_IsBlankName
	cp	hl, 0xffff
	jr z, HDAE5000_FlsLoadScreen_Skip4                       ; [66 20] jr Z,0x288ab9
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsLoadScreen_Done                      ; [78 61 01] jrl T,0x288c1a
HDAE5000_FlsLoadScreen_Skip4:
	ld	wa, (HDAE5000_RAM_CurFls:24)
	call HDAE5000_FlsRecord_Address
	ld	xde, xhl
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApFuncCall)
	ld	xwa, NAKA_APFUNC_FlsNamingCheck
	ld	xbc, EVT_SET_STRING
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_HDD_FLS_NAMING2
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsLoadScreen_Done                      ; [78 1b 01] jrl T,0x288c1a
HDAE5000_FlsLoadScreen_OnHdaeUnderFlow:
	cpw	(0x22B272:24), 0
	jr nz, HDAE5000_FlsLoadScreen_Skip5                      ; [6e 45] jr NZ,0x288b4d
	cpw	(HDAE5000_RAM_CurFls:24), 0
	jrl z, HDAE5000_FlsLoadScreen_Done                      ; [76 08 01] jrl Z,0x288c1a
	decw	1, (HDAE5000_RAM_CurFls:24)
	ldw	(0x22B272:24), 16
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, xiz
	add	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_BOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jrl t, HDAE5000_FlsLoadScreen_Done                      ; [78 cd 00] jrl T,0x288c1a
HDAE5000_FlsLoadScreen_Skip5:
	ldw	(0x22B272:24), 0
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, xiz
	add	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_BOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jrl t, HDAE5000_FlsLoadScreen_Done                      ; [78 97 00] jrl T,0x288c1a
HDAE5000_FlsLoadScreen_OnHdaeOverFlow:
	cpw	(0x22B272:24), 0
	jr z, HDAE5000_FlsLoadScreen_Skip6                       ; [66 44] jr Z,0x288bd0
	cpw	(HDAE5000_RAM_CurFls:24), 119
	jrl nc, HDAE5000_FlsLoadScreen_Done                     ; [7f 84 00] jrl NC,0x288c1a
	incw	1, (HDAE5000_RAM_CurFls:24)
	ldw	(0x22B272:24), 0
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, xiz
	sub	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_BOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jr t, HDAE5000_FlsLoadScreen_Done                       ; [68 4a] jr T,0x288c1a
HDAE5000_FlsLoadScreen_Skip6:
	ldw	(0x22B272:24), 16
	ld	wa, 0:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, xiz
	sub	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_BOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jr t, HDAE5000_FlsLoadScreen_Done                       ; [68 15] jr T,0x288c1a
HDAE5000_FlsLoadScreen_OnHdaeChangeSelNum:
	ld	bc, iz
	ld	wa, (0x22B272:24)
	add	wa, bc
	ld	(0x23a098), wa
	ld	wa, 0:i3
	ld	bc, 1:i3
	calr	HDAE5000_FlsScreen_Refresh
HDAE5000_FlsLoadScreen_Done:
	ld	xhl, 0:i3
	pop xiz
	inc	6, xsp
	ret

HDAE5000_FlsFileLoadSwCatch:
	; registered as "FlsFileLoadSwCatch" in HDAE5000_ObjHandler_Table
	dec 8, xsp                              ; dec 0,XSP
	push xiz
	ld (xsp + 0x04), xde
	ld	xiz, xbc
	ld (xsp + 0x08), xwa
	ld	xwa, xiz
	cp	xwa, EVT_SW_IN
	jr z, HDAE5000_FlsFileLoadSwCatch_OnSwIn                       ; [66 55] jr Z,0x288c8a
	cp	xwa, EVT_DRAW
	jr z, HDAE5000_FlsFileLoadSwCatch_OnDraw                       ; [66 0e] jr Z,0x288c4b
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jrl nz, HDAE5000_FlsFileLoadSwCatch_Join2                     ; [7e 8b 00] jrl NZ,0x288cd1
	ld	xhl, 1:i3
	jrl t, HDAE5000_FlsFileLoadSwCatch_Epilogue                      ; [78 9f 00] jrl T,0x288cea
HDAE5000_FlsFileLoadSwCatch_OnDraw:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_FLS:24)
	ld	xbc, xwa
	ld xwa, (xsp + 0x08)
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jr t, HDAE5000_FlsFileLoadSwCatch_Epilogue                       ; [68 60] jr T,0x288cea
HDAE5000_FlsFileLoadSwCatch_OnSwIn:
	ld xde, (xsp + 0x04)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jr z, HDAE5000_FlsFileLoadSwCatch_Join                       ; [66 08] jr Z,0x288cb8
	cp	xhl, 0x00000006
	jr nz, HDAE5000_FlsFileLoadSwCatch_Join2                      ; [6e 19] jr NZ,0x288cd1
HDAE5000_FlsFileLoadSwCatch_Join:
	ld	(0x22AD9A:24), 0
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_PlayHalt)
	ld	wa, 0:i3
	call	(xhl)
HDAE5000_FlsFileLoadSwCatch_Join2:
	ld xwa, (xsp + 0x08)
	ld	xbc, xiz
	ld xde, (xsp + 0x04)
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
HDAE5000_FlsFileLoadSwCatch_Epilogue:
	pop xiz
	inc 8, xsp                              ; inc 0,XSP
	ret

HDAE5000_FlsEditScreen:
	; registered as "FlsEditScreen" in HDAE5000_ScreenProc_Table
	push xiz
	ld	xiz, xde
	cp	xbc, EVT_HDAE_CHANGE_SEL_NUM
	jrl z, HDAE5000_FlsEditScreen_OnHdaeChangeSelNum                      ; [76 dc 02] jrl Z,0x288fd6
	cp	xbc, EVT_HDAE_OVER_FLOW
	jrl z, HDAE5000_FlsEditScreen_OnHdaeOverFlow                      ; [76 95 02] jrl Z,0x288f98
	cp	xbc, EVT_HDAE_UNDER_FLOW
	jrl z, HDAE5000_FlsEditScreen_OnHdaeUnderFlow                      ; [76 4d 02] jrl Z,0x288f59
	cp	xbc, EVT_HDAE_SELECT_SAVE
	jrl z, HDAE5000_FlsEditScreen_OnHdaeSelectSave                      ; [76 5f 01] jrl Z,0x288e74
	cp	xbc, EVT_HDAE_SELECT_OK
	jrl z, HDAE5000_FlsEditScreen_OnHdaeSelectOk                      ; [76 2e 01] jrl Z,0x288e4c
	cp	xbc, EVT_SW_IN
	jr z, HDAE5000_FlsEditScreen_OnSwIn                       ; [66 29] jr Z,0x288d4f
	cp	xbc, EVT_SHOW
	jrl nz, HDAE5000_FlsEditScreen_Done                     ; [7e ba 02] jrl NZ,0x288fe9
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT_LIST_BOX
	ld	xbc, EVT_HDAE_CHANGE_SEL_NUM
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsEditScreen_Done                      ; [78 9a 02] jrl T,0x288fe9
HDAE5000_FlsEditScreen_OnSwIn:
	ld	xde, xiz
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jrl z, HDAE5000_FlsEditScreen_Skip5                      ; [76 a6 00] jrl Z,0x288e1b
	cp	xhl, 0x00000006
	jr z, HDAE5000_FlsEditScreen_Skip3                       ; [66 6d] jr Z,0x288dea
	cp	xhl, 0x00000005
	jr z, HDAE5000_FlsEditScreen_Skip2                       ; [66 4d] jr Z,0x288dd2
	cp	xhl, 0x00000001
	jr z, HDAE5000_FlsEditScreen_Skip                       ; [66 25] jr Z,0x288db2
	or xhl, xhl
	jrl nz, HDAE5000_FlsEditScreen_Done                     ; [7e 57 02] jrl NZ,0x288fe9
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_ATTEN_DEL_FLS1
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsEditScreen_Done                      ; [78 37 02] jrl T,0x288fe9
HDAE5000_FlsEditScreen_Skip:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_ATTEN_DEL_FLS2
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsEditScreen_Done                      ; [78 17 02] jrl T,0x288fe9
HDAE5000_FlsEditScreen_Skip2:
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	call HDAE5000_FlsItem_Insert
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	jrl t, HDAE5000_FlsEditScreen_Done                      ; [78 ff 01] jrl T,0x288fe9
HDAE5000_FlsEditScreen_Skip3:
	bit	0x07, iz
	jr z, HDAE5000_FlsEditScreen_Skip4                       ; [66 12] jr Z,0x288e01
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	ld	de, 0:i3
	call HDAE5000_FlsItem_SetByte80
	jr t, HDAE5000_FlsEditScreen_Join                       ; [68 10] jr T,0x288e11
HDAE5000_FlsEditScreen_Skip4:
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	ld	de, 1:i3
	call HDAE5000_FlsItem_SetByte80
HDAE5000_FlsEditScreen_Join:
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	jrl t, HDAE5000_FlsEditScreen_Done                      ; [78 ce 01] jrl T,0x288fe9
HDAE5000_FlsEditScreen_Skip5:
	bit	0x07, iz
	jr z, HDAE5000_FlsEditScreen_Skip6                       ; [66 12] jr Z,0x288e32
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	ld	de, 0:i3
	call HDAE5000_FlsItem_SetByte112
	jr t, HDAE5000_FlsEditScreen_Join2                       ; [68 10] jr T,0x288e42
HDAE5000_FlsEditScreen_Skip6:
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	ld	de, 1:i3
	call HDAE5000_FlsItem_SetByte112
HDAE5000_FlsEditScreen_Join2:
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	jrl t, HDAE5000_FlsEditScreen_Done                      ; [78 9d 01] jrl T,0x288fe9
HDAE5000_FlsEditScreen_OnHdaeSelectOk:
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	calr	HDAE5000_DirList_BuildPage
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_DIR_SEL
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsEditScreen_Done                      ; [78 75 01] jrl T,0x288fe9
HDAE5000_FlsEditScreen_OnHdaeSelectSave:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_HD_PLEASE
	ld	xbc, EVT_SHOW
	ld	xde, 5:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_pdly_tim_X)
	ldw	wa, 0x0064
	call	(xhl)
	calr	HDAE5000_YieldUntilSem1Zero
	ld	wa, 0:i3
	call HDAE5000_HD_StoreTables
	cp	hl, 0xffff
	jr z, HDAE5000_FlsEditScreen_Skip7                       ; [66 20] jr Z,0x288ed4
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsEditScreen_Done                      ; [78 15 01] jrl T,0x288fe9
HDAE5000_FlsEditScreen_Skip7:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_ERR_SAVE
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	ld	xwa, HDAE5000_OBJ_ERR_SAVE_EXIT
	ld	xbc, HDAE5000_OBJ_FLS_EDIT
	calr	HDAE5000_UiObj_SetCaption
	ld	xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	push xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_KillApTimer)
	ld	xwa, 0x0000014d
	ld	xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld	xde, 0xffffffff
	call	(xhl)
	ld	xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	push xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_SetApTimer)
	ld	xwa, 0x0000014d
	ld	xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld	xde, 0xffffffff
	call	(xhl)
	jrl t, HDAE5000_FlsEditScreen_Done                      ; [78 90 00] jrl T,0x288fe9
HDAE5000_FlsEditScreen_OnHdaeUnderFlow:
	cpw	(0x22B272:24), 0
	jrl z, HDAE5000_FlsEditScreen_Done                      ; [76 86 00] jrl Z,0x288fe9
	ldw	(0x22B272:24), 0
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, xiz
	add	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT_LIST_BOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jr t, HDAE5000_FlsEditScreen_Done                       ; [68 51] jr T,0x288fe9
HDAE5000_FlsEditScreen_OnHdaeOverFlow:
	cpw	(0x22B272:24), 0
	jr nz, HDAE5000_FlsEditScreen_Done                      ; [6e 48] jr NZ,0x288fe9
	ldw	(0x22B272:24), 16
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, xiz
	sub	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT_LIST_BOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jr t, HDAE5000_FlsEditScreen_Done                       ; [68 13] jr T,0x288fe9
HDAE5000_FlsEditScreen_OnHdaeChangeSelNum:
	ld	wa, iz
	add	wa, (0x22B272:24)
	ld	(0x23a098), wa
	ld	wa, 1:i3
	ld	bc, 1:i3
	calr	HDAE5000_FlsScreen_Refresh
HDAE5000_FlsEditScreen_Done:
	ld	xhl, 0:i3
	pop xiz
	ret

HDAE5000_FlsDel1SwCatch:
	; registered as "FlsDel1SwCatch" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_SW_IN
	jr z, HDAE5000_FlsDel1SwCatch_OnSwIn                       ; [66 64] jr Z,0x28905e
	cp	xwa, EVT_DRAW
	jr z, HDAE5000_FlsDel1SwCatch_OnDraw                       ; [66 23] jr Z,0x289025
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jr z, HDAE5000_FlsDel1SwCatch_OnAreYouClassProc                       ; [66 16] jr Z,0x289020
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl t, HDAE5000_FlsDel1SwCatch_Epilogue                      ; [78 c8 00] jrl T,0x2890e8
HDAE5000_FlsDel1SwCatch_OnAreYouClassProc:
	ld	xhl, 1:i3
	jrl t, HDAE5000_FlsDel1SwCatch_Epilogue                      ; [78 c3 00] jrl T,0x2890e8
HDAE5000_FlsDel1SwCatch_OnDraw:
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_DEL1:24)
	ld	xbc, xwa
	ld	xwa, xiz
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl t, HDAE5000_FlsDel1SwCatch_Epilogue                      ; [78 8a 00] jrl T,0x2890e8
HDAE5000_FlsDel1SwCatch_OnSwIn:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jr z, HDAE5000_FlsDel1SwCatch_Skip                       ; [66 48] jr Z,0x2890c9
	cp	xhl, 0x00000006
	jr z, HDAE5000_FlsDel1SwCatch_Skip                       ; [66 40] jr Z,0x2890c9
	cp	xhl, 0x00000001
	jr z, HDAE5000_FlsDel1SwCatch_Join                       ; [66 04] jr Z,0x289095
	or xhl, xhl
	jr nz, HDAE5000_FlsDel1SwCatch_Done                      ; [6e 51] jr NZ,0x2890e6
HDAE5000_FlsDel1SwCatch_Join:
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	call HDAE5000_FlsItem_Clear
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jr t, HDAE5000_FlsDel1SwCatch_Done                       ; [68 1d] jr T,0x2890e6
HDAE5000_FlsDel1SwCatch_Skip:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_FlsDel1SwCatch_Done:
	ld	xhl, 0:i3
HDAE5000_FlsDel1SwCatch_Epilogue:
	pop xiz
	ret

HDAE5000_FlsDel2SwCatch:
	; registered as "FlsDel2SwCatch" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_SW_IN
	jr z, HDAE5000_FlsDel2SwCatch_OnSwIn                       ; [66 64] jr Z,0x28915b
	cp	xwa, EVT_DRAW
	jr z, HDAE5000_FlsDel2SwCatch_OnDraw                       ; [66 23] jr Z,0x289122
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jr z, HDAE5000_FlsDel2SwCatch_OnAreYouClassProc                       ; [66 16] jr Z,0x28911d
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl t, HDAE5000_FlsDel2SwCatch_Epilogue                      ; [78 c8 00] jrl T,0x2891e5
HDAE5000_FlsDel2SwCatch_OnAreYouClassProc:
	ld	xhl, 1:i3
	jrl t, HDAE5000_FlsDel2SwCatch_Epilogue                      ; [78 c3 00] jrl T,0x2891e5
HDAE5000_FlsDel2SwCatch_OnDraw:
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_DEL2:24)
	ld	xbc, xwa
	ld	xwa, xiz
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl t, HDAE5000_FlsDel2SwCatch_Epilogue                      ; [78 8a 00] jrl T,0x2891e5
HDAE5000_FlsDel2SwCatch_OnSwIn:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jr z, HDAE5000_FlsDel2SwCatch_Skip                       ; [66 48] jr Z,0x2891c6
	cp	xhl, 0x00000006
	jr z, HDAE5000_FlsDel2SwCatch_Skip                       ; [66 40] jr Z,0x2891c6
	cp	xhl, 0x00000001
	jr z, HDAE5000_FlsDel2SwCatch_Join                       ; [66 04] jr Z,0x289192
	or xhl, xhl
	jr nz, HDAE5000_FlsDel2SwCatch_Done                      ; [6e 51] jr NZ,0x2891e3
HDAE5000_FlsDel2SwCatch_Join:
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	call HDAE5000_FlsItem_Remove
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jr t, HDAE5000_FlsDel2SwCatch_Done                       ; [68 1d] jr T,0x2891e3
HDAE5000_FlsDel2SwCatch_Skip:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_FlsDel2SwCatch_Done:
	ld	xhl, 0:i3
HDAE5000_FlsDel2SwCatch_Epilogue:
	pop xiz
	ret

HDAE5000_FlsDirSelScreen:
	; registered as "FlsDirSelScreen" in HDAE5000_ScreenProc_Table
	push xiz
	ld	xiz, xde
	cp	xbc, EVT_HDAE_OVER_FLOW
	jrl z, HDAE5000_FlsDirSelScreen_OnHdaeOverFlow                      ; [76 2a 01] jrl Z,0x28931d
	cp	xbc, EVT_HDAE_UNDER_FLOW
	jrl z, HDAE5000_FlsDirSelScreen_OnHdaeUnderFlow                      ; [76 e2 00] jrl Z,0x2892de
	cp	xbc, EVT_HDAE_SELECT_OK
	jrl z, HDAE5000_FlsDirSelScreen_OnHdaeSelectOk                      ; [76 a5 00] jrl Z,0x2892aa
	cp	xbc, EVT_SW_IN
	jrl nz, HDAE5000_FlsDirSelScreen_Done                     ; [7e 4c 01] jrl NZ,0x28935a
	ld	xde, xiz
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jr z, HDAE5000_FlsDirSelScreen_Skip4                       ; [66 65] jr Z,0x289298
	cp	xhl, 0x00000006
	jr z, HDAE5000_FlsDirSelScreen_Skip3                       ; [66 4b] jr Z,0x289286
	cp	xhl, 0x00000005
	jr z, HDAE5000_FlsDirSelScreen_Skip2                       ; [66 31] jr Z,0x289274
	cp	xhl, 0x00000001
	jr z, HDAE5000_FlsDirSelScreen_Skip                       ; [66 17] jr Z,0x289262
	or xhl, xhl
	jrl nz, HDAE5000_FlsDirSelScreen_Done                     ; [7e 0a 01] jrl NZ,0x28935a
	ldw	(HDAE5000_RAM_DirPageBase:24), 0
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	calr	HDAE5000_DirList_BuildPage
	jrl t, HDAE5000_FlsDirSelScreen_Done                      ; [78 f8 00] jrl T,0x28935a
HDAE5000_FlsDirSelScreen_Skip:
	ldw	(HDAE5000_RAM_DirPageBase:24), 24
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	calr	HDAE5000_DirList_BuildPage
	jrl t, HDAE5000_FlsDirSelScreen_Done                      ; [78 e6 00] jrl T,0x28935a
HDAE5000_FlsDirSelScreen_Skip2:
	ldw	(HDAE5000_RAM_DirPageBase:24), 48
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	calr	HDAE5000_DirList_BuildPage
	jrl t, HDAE5000_FlsDirSelScreen_Done                      ; [78 d4 00] jrl T,0x28935a
HDAE5000_FlsDirSelScreen_Skip3:
	ldw	(HDAE5000_RAM_DirPageBase:24), 72
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	calr	HDAE5000_DirList_BuildPage
	jrl t, HDAE5000_FlsDirSelScreen_Done                      ; [78 c2 00] jrl T,0x28935a
HDAE5000_FlsDirSelScreen_Skip4:
	ldw	(HDAE5000_RAM_DirPageBase:24), 96
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	calr	HDAE5000_DirList_BuildPage
	jrl t, HDAE5000_FlsDirSelScreen_Done                      ; [78 b0 00] jrl T,0x28935a
HDAE5000_FlsDirSelScreen_OnHdaeSelectOk:
	ld	bc, (HDAE5000_RAM_DirPageBase:24)
	ld	wa, iz
	add	wa, bc
	ld	(HDAE5000_RAM_CurDir), wa
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_SongScreen_Refresh
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_SEL
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jr t, HDAE5000_FlsDirSelScreen_Done                       ; [68 7c] jr T,0x28935a
HDAE5000_FlsDirSelScreen_OnHdaeUnderFlow:
	cpw	(HDAE5000_RAM_DirPageBase:24), 24
	jr lt, HDAE5000_FlsDirSelScreen_Done                      ; [61 73] jr LT,0x28935a
	subw	(HDAE5000_RAM_DirPageBase:24), 24
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	calr	HDAE5000_DirList_BuildPage
	ld	xwa, xiz
	add	xwa, 0x00000018
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jr t, HDAE5000_FlsDirSelScreen_Done                       ; [68 3d] jr T,0x28935a
HDAE5000_FlsDirSelScreen_OnHdaeOverFlow:
	cpw	(HDAE5000_RAM_DirPageBase:24), 96
	jr ge, HDAE5000_FlsDirSelScreen_Done                      ; [69 34] jr GE,0x28935a
	addw	(HDAE5000_RAM_DirPageBase:24), 24
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	calr	HDAE5000_DirList_BuildPage
	ld	xwa, xiz
	sub	xwa, 0x00000018
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_DIR_BOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
HDAE5000_FlsDirSelScreen_Done:
	ld	xhl, 0:i3
	pop xiz
	ret

HDAE5000_FlsFileSelScreen:
	; registered as "FlsFileSelScreen" in HDAE5000_ScreenProc_Table
	push xiz
	ld	xiz, xde
	cp	xbc, EVT_HDAE_CHANGE_SEL_NUM
	jrl z, HDAE5000_FlsFileSelScreen_OnHdaeChangeSelNum                      ; [76 78 01] jrl Z,0x2894e2
	cp	xbc, EVT_HDAE_OVER_FLOW
	jrl z, HDAE5000_FlsFileSelScreen_OnHdaeOverFlow                      ; [76 33 01] jrl Z,0x2894a6
	cp	xbc, EVT_HDAE_UNDER_FLOW
	jrl z, HDAE5000_FlsFileSelScreen_OnHdaeUnderFlow                      ; [76 ec 00] jrl Z,0x289468
	cp	xbc, EVT_HDAE_SELECT_OK
	jr z, HDAE5000_FlsFileSelScreen_OnHdaeSelectOk                       ; [66 29] jr Z,0x2893ad
	cp	xbc, EVT_SHOW
	jrl nz, HDAE5000_FlsFileSelScreen_Done                     ; [7e 9d 01] jrl NZ,0x28952a
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_SEL_LISTBOX
	ld	xbc, EVT_HDAE_CHANGE_SEL_NUM
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsFileSelScreen_Done                      ; [78 7d 01] jrl T,0x28952a
HDAE5000_FlsFileSelScreen_OnHdaeSelectOk:
	ld	(HDAE5000_RAM_CurSong), iz
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	call HDAE5000_FlsItem_IsSet
	cp	hl, 0xffff
	jrl nz, HDAE5000_FlsFileSelScreen_Skip                     ; [7e 81 00] jrl NZ,0x289448
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_HD_PLEASE
	ld	xbc, EVT_SHOW
	ld	xde, 5:i3
	call	(xhl)
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld_sril	xhl, (xwa + HamaFn_pdly_tim_X)
	ldw	wa, 0x0064
	call	(xhl)
	calr	HDAE5000_YieldUntilSem1Zero
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	ld	de, (HDAE5000_RAM_CurDir:24)
	call HDAE5000_FlsItem_SetDir
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_FlsItem_SetSong
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsFileSelScreen_Done                      ; [78 e2 00] jrl T,0x28952a
HDAE5000_FlsFileSelScreen_Skip:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_ATTEN_OVER_FLS
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl t, HDAE5000_FlsFileSelScreen_Done                      ; [78 c2 00] jrl T,0x28952a
HDAE5000_FlsFileSelScreen_OnHdaeUnderFlow:
	cpw	(HDAE5000_RAM_CurDir:24), 0
	jrl z, HDAE5000_FlsFileSelScreen_Done                      ; [76 b8 00] jrl Z,0x28952a
	decw	1, (HDAE5000_RAM_CurDir:24)
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_SongScreen_Refresh
	ld	xwa, xiz
	add	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_SEL_LISTBOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jrl t, HDAE5000_FlsFileSelScreen_Done                      ; [78 84 00] jrl T,0x28952a
HDAE5000_FlsFileSelScreen_OnHdaeOverFlow:
	cpw	(HDAE5000_RAM_CurDir:24), 119
	jr nc, HDAE5000_FlsFileSelScreen_Done                      ; [6f 7b] jr NC,0x28952a
	incw	1, (HDAE5000_RAM_CurDir:24)
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_SongScreen_Refresh
	ld	xwa, xiz
	sub	xwa, 0x00000010
	ld	xde, xwa
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_SEL_LISTBOX
	ld	xbc, EVT_HDAE_SET_SEL_NUM
	call	(xhl)
	jr t, HDAE5000_FlsFileSelScreen_Done                       ; [68 48] jr T,0x28952a
HDAE5000_FlsFileSelScreen_OnHdaeChangeSelNum:
	ld	(HDAE5000_RAM_CurSong), iz
	ld	wa, (HDAE5000_RAM_CurDir:24)
	ld	bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_PartMask
	ld	wa, hl
	cp	wa, 0xffff
	jr z, HDAE5000_FlsFileSelScreen_Skip2                       ; [66 14] jr Z,0x289511
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	ld	bc, hl
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	calr	HDAE5000_TypeSel_Init
	jr t, HDAE5000_FlsFileSelScreen_Join                       ; [68 12] jr T,0x289523
HDAE5000_FlsFileSelScreen_Skip2:
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_TypeSel_TemplateBlank:24)
	ld	bc, 0:i3
	calr	HDAE5000_TypeSel_Init
HDAE5000_FlsFileSelScreen_Join:
	ld	wa, 1:i3
	ld	bc, 1:i3
	calr	HDAE5000_SongScreen_Refresh
HDAE5000_FlsFileSelScreen_Done:
	ld	xhl, 0:i3
	pop xiz
	ret

HDAE5000_FlsOverWrSwCatch:
	; registered as "FlsOverWrSwCatch" in HDAE5000_ObjHandler_Table
	push xiz
	ld	xiz, xwa
	ld	xwa, xbc
	cp	xwa, EVT_SW_IN
	jr z, HDAE5000_FlsOverWrSwCatch_OnSwIn                       ; [66 64] jr Z,0x28959f
	cp	xwa, EVT_DRAW
	jr z, HDAE5000_FlsOverWrSwCatch_OnDraw                       ; [66 23] jr Z,0x289566
	cp	xwa, EVT_ARE_YOU_CLASS_PROC
	jr z, HDAE5000_FlsOverWrSwCatch_OnAreYouClassProc                       ; [66 16] jr Z,0x289561
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xix, (xhl + RootFn_InheritedProc)
	call	(xix)
	jrl t, HDAE5000_FlsOverWrSwCatch_Epilogue                      ; [78 02 01] jrl T,0x289663
HDAE5000_FlsOverWrSwCatch_OnAreYouClassProc:
	ld	xhl, 1:i3
	jrl t, HDAE5000_FlsOverWrSwCatch_Epilogue                      ; [78 fd 00] jrl T,0x289663
HDAE5000_FlsOverWrSwCatch_OnDraw:
	ld	xwa, xiz
	ld	xhl, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xhl, (xhl + WS_RootFnTable)
	ld_sril	xhl, (xhl + RootFn_InheritedProc)
	call	(xhl)
	lda xwa, (HDAE5000_Str_OVWR:24)
	ld	xbc, xwa
	ld	xwa, xiz
	ld	xde, xbc
	ld	xbc, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xbc, (xbc + WS_RootFnTable)
	ld_sril	xhl, (xbc + RootFn_SendEvent)
	ld	xbc, EVT_PARA_DRAW
	call	(xhl)
	ld	xhl, 0:i3
	jrl t, HDAE5000_FlsOverWrSwCatch_Epilogue                      ; [78 c4 00] jrl T,0x289663
HDAE5000_FlsOverWrSwCatch_OnSwIn:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jrl z, HDAE5000_FlsOverWrSwCatch_Skip                      ; [76 81 00] jrl Z,0x289644
	cp	xhl, 0x00000006
	jr z, HDAE5000_FlsOverWrSwCatch_Skip                       ; [66 79] jr Z,0x289644
	cp	xhl, 0x00000001
	jr z, HDAE5000_FlsOverWrSwCatch_Join                       ; [66 05] jr Z,0x2895d8
	or xhl, xhl
	jrl nz, HDAE5000_FlsOverWrSwCatch_Done                     ; [7e 89 00] jrl NZ,0x289661
HDAE5000_FlsOverWrSwCatch_Join:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xhl, (xwa + RootFn_SendEvent)
	ld	xwa, HDAE5000_OBJ_HD_PLEASE
	ld	xbc, EVT_SHOW
	ld	xde, 5:i3
	call	(xhl)
	calr	HDAE5000_YieldUntilSem1Zero
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	ld	de, (HDAE5000_RAM_CurDir:24)
	call HDAE5000_FlsItem_SetDir
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (0x23A098:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_FlsItem_SetSong
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jr t, HDAE5000_FlsOverWrSwCatch_Done                       ; [68 1d] jr T,0x289661
HDAE5000_FlsOverWrSwCatch_Skip:
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_PostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
HDAE5000_FlsOverWrSwCatch_Done:
	ld	xhl, 0:i3
HDAE5000_FlsOverWrSwCatch_Epilogue:
	pop xiz
	ret


HDAE5000_FdList_Redisplay:	; 0x289665 (548 bytes)
	; Set up filesystem buffers at 0x22AA9C
	; (= redisplay the floppy list built by HDAE5000_FdList_Scan: title
	; 0x22AA9C to object 0x7F00DE, "*" on the rows whose flag is set.)
	; --- Register events for filesystem buffer at 0x22AA9C ---
	lda xwa, (0x22aa9c:24); f2 9c aa 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL			; 40 de 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR			; 41 0a 00 ea 01
	call (xhl)				; b3 e8

	; Deregister event 0x01C0000F
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL			; 40 de 00 7f 00
	ld xbc, EVT_PARA_DRAW			; 41 0f 00 c0 01
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8

	; --- Initialize 20 buffer entries ---
	ld de, 0:i3				; da a8
	cp de, 0x0014				; da cf 14 00
	jr nc, .Lfbs_after_loop			; 6f xx

.Lfbs_loop:					; 0x2896AF
	ld wa, de				; da 88
	mul wa, 0x000c				; d8 08 0c 00
	add wa, 0x000a				; d8 c8 0a 00
	extz xwa				; e8 12
	add xwa, 0x0000000e			; e8 c8 0e 00 00 00
	ld xbc, 0x0022aa9c			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	ld	(xbc), 0x20

	; Check status flag at +0x0114
	ld wa, de				; da 88
	extz xwa				; e8 12
	add xwa, 0x00000114			; e8 c8 14 01 00 00
	ld xbc, 0x0022aa9c			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_loop_next			; 6e xx

	; Entry is active: set flag to 0x2A (asterisk)
	ld wa, de				; da 88
	mul wa, 0x000c				; d8 08 0c 00
	add wa, 0x000a				; d8 c8 0a 00
	extz xwa				; e8 12
	add xwa, 0x0000000e			; e8 c8 0e 00 00 00
	ld xbc, 0x0022aa9c			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	ld	(xbc), 0x2a

.Lfbs_loop_next:				; 0x2896FD
	inc 1, de				; da 61
	cp de, 0x0014				; da cf 14 00
	jr c, .Lfbs_loop			; 67 xx

.Lfbs_after_loop:				; 0x289705
	; --- Register events for second buffer at 0x22AAAA ---
	lda xwa, (0x22aaaa:24); f2 aa aa 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LIST			; 40 d7 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR			; 41 0a 00 ea 01
	call (xhl)				; b3 e8

	; Deregister event 0x01C0000F
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LIST			; 40 d7 00 7f 00
	ld xbc, EVT_PARA_DRAW			; 41 0f 00 c0 01
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8

	; Register event 0x01C0000D (handler 1)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LINE1			; 40 d9 00 7f 00
	ld xbc, EVT_DRAW			; 41 0d 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8

	; Register event 0x01C0000D (handler 2) — tail call via jp
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LINE2			; 40 d8 00 7f 00
	ld xbc, EVT_DRAW			; 41 0d 00 c0 01
	ld xde, 0:i3				; ea a8
	jp (xhl)				; b3 d8 — tail call

; --- Event handler sub-function ---
HDAE5000_CopyToHDScreen:
	; registered as "CopyToHDScreen" in HDAE5000_ScreenProc_Table
	pushw iz                                ; push iz (compact 16-bit)
	cp xbc, EVT_HDAE_CHANGE_SEL_NUM			; e9 cf 02 00 ea 01
	jrl z, .Lfbs_evt_0002			; 76 xx xx
	cp xbc, EVT_HDAE_SELECT_SAVE			; e9 cf 08 00 ea 01
	jrl z, .Lfbs_evt_0008			; 76 xx xx
	cp xbc, EVT_HDAE_SELECT_OK			; e9 cf 06 00 ea 01
	jr z, .Lfbs_evt_0006			; 66 xx
	cp xbc, EVT_HDAE_SELECT_ALL			; e9 cf 09 00 ea 01
	jrl nz, .Lfbs_evt_done			; 7e xx xx

	; Event 0x01EA0009: scan all 20 entries, mark active ones
.Lfbs_evt_0009:					; 0x2897A5
	ld iz, 0:i3				; de a8
	cp iz, 0x0014				; de cf 14 00
	jrl nc, .Lfbs_evt_done			; 7f xx xx

.Lfbs_evt_0009_loop:				; 0x2897AE
	ld wa, iz				; de 88
	extz xwa				; e8 12
	add xwa, 0x00000100			; e8 c8 00 01 00 00
	ld xbc, 0x0022aa9c			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_evt_0009_next		; 6e xx
	; Entry is active: mark status flag
	ld wa, iz				; de 88
	extz xwa				; e8 12
	add xwa, 0x00000114			; e8 c8 14 01 00 00
	ld xbc, 0x0022aa9c			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	ld	(xbc), 0x01
	calr HDAE5000_FdList_Redisplay		; 1e xx xx — self-call

.Lfbs_evt_0009_next:				; 0x2897DB
	inc 1, iz				; de 61
	cp iz, 0x0014				; de cf 14 00
	jr c, .Lfbs_evt_0009_loop		; 67 xx
	jrl t, .Lfbs_evt_done			; 78 xx xx

	; Event 0x01EA0006: format params and check active files
.Lfbs_evt_0006:					; 0x2897E6
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX			; 40 e6 00 7f 00
	calr HDAE5000_DirList_BuildPage		; 1e xx xx
	calr HDAE5000_Count_Active_Files	; 1e xx xx
	cp hl, 0:i3				; db d8
	jr z, .Lfbs_evt_0006_empty		; 66 xx
	; Has active files: register status 0x007f00e2
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_DIRSEL			; 40 e2 00 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	jr t, .Lfbs_evt_done			; 68 xx

.Lfbs_evt_0006_empty:				; 0x289814
	; No active files: register status 0x007f027a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 a2 a1 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_ATTEN_CPFD_MARK			; 40 7a 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	jr t, .Lfbs_evt_done			; 68 xx

	; Event 0x01EA0008: check entry, toggle flag
.Lfbs_evt_0008:					; 0x289833
	ld xwa, xde				; ea 88
	add xwa, 0x00000100			; e8 c8 00 01 00 00
	ld xbc, 0x0022aa9c			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_evt_done			; 6e xx
	; First flag is set: check second flag at +0x0114
	ld xwa, xde				; ea 88
	add xwa, 0x00000114			; e8 c8 14 01 00 00
	ld xbc, 0x0022aa9c			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_evt_0008_set1		; 6e xx
	; Second flag is set: clear it to 0
	add xde, 0x00000114			; ea c8 14 01 00 00
	ld xwa, 0x0022aa9c			; 40 9c aa 22 00
	add xwa, xde				; ea 80
	ld	(xwa), 0x00
	jr t, .Lfbs_evt_0008_done		; 68 xx

.Lfbs_evt_0008_set1:				; 0x28986D
	; Second flag not set: set it to 1
	add xde, 0x00000114			; ea c8 14 01 00 00
	ld xwa, 0x0022aa9c			; 40 9c aa 22 00
	add xwa, xde				; ea 80
	ld	(xwa), 0x01

.Lfbs_evt_0008_done:				; 0x28987D
	calr HDAE5000_FdList_Redisplay		; 1e xx xx — self-call
	jr t, .Lfbs_evt_done			; 68 xx

.Lfbs_evt_0002:					; 0x289882
	calr HDAE5000_FdList_Redisplay		; 1e xx xx — self-call

.Lfbs_evt_done:					; 0x289885
	ld xhl, 0:i3				; eb a8
	popw iz                                 ; pop iz (compact 16-bit)
	ret					; 0e

HDAE5000_CopyToHd_Execute:	; 0x289889 (2663 bytes)
	; Part 1: Main scan loop — iterate directory entries, search partitions
	; (= the copy-to-HD run: checks the floppy song (HDAE5000_FdSong_CheckFiles)
	; and copies it into the chosen directory (HDAE5000_CopyFdSongToHd).
	; There are no partitions.)
	lda xsp, (xsp-300)	; lda XSP, XSP+0xFED4 (alloc ~300 bytes)
	push xiz
	ld	(xsp+300), de	; ld (XSP+0x012C), DE
	ld	(xsp+302), bc	; ld (XSP+0x012E), BC
	ld iz, 0:i3
.LFSD__loop:
	cp	iz, (xsp+302)	; cp IZ, (XSP+0x012E)
	jrl nc, .LFSD__loop_done
.LFSD__loop_body:
	ld wa, iz
	extz xwa
	add xwa, 0x00000114
	ld xbc, 0x0022aa9c
	add xbc, xwa
	cp	(xbc), 0x01
	jrl nz, .LFSD__loop_next
	; Valid entry — format and display
	pushw 0x000d
	pushw 0x0000
	lda xwa, (xsp+290)	; lda XWA, XSP+0x0122
	push xwa
	call HDAE5000_MemFill			; MemFill
	ld wa, iz
	inc 1, wa
	pushw wa                                ; push wa (compact)
	pushw HDAE5000_Fmt_2_2d_CopyToHd_Execute@hi16
	pushw HDAE5000_Fmt_2_2d_CopyToHd_Execute@lo16		; low half of HDAE5000_Fmt_2_2d_CopyToHd_Execute
	lda xwa, (xsp+300)	; lda XWA, XSP+0x012C
	push xwa
	call HDAE5000_SPrintf
	pushw 0x0006
	ld wa, iz
	mul wa, 0x000c
	inc 3, wa
	extz xwa
	add xwa, 0x0000000e
	ld xbc, 0x0022aa9c
	add xbc, xwa
	push xbc
	lda xwa, (xsp+312)	; lda XWA, XSP+0x0138
	push xwa
	call HDAE5000_StrNCpy			; MemCopy_Reverse
	lda xsp, (xsp + 0x1c)
	ldw	(xsp+4), 0xffff
	; QIZ loop: search 16 partitions
	ld	qiz, 0
	cpw	qiz, 0x0010
	jr nc, .LFSD__qiz_done
.LFSD__qiz_loop:
	ld	bc, qiz
	ld	wa, (xsp+300)
	call HDAE5000_Song_IsUsed
	cp hl, 0xffff
	jr nz, .LFSD__qiz_found
	ld	wa, qiz
	ld (xsp + 0x04), wa
	jr t, .LFSD__qiz_done
.LFSD__qiz_found:
	inc	1, qiz
	cpw	qiz, 0x0010
	jr c, .LFSD__qiz_loop
.LFSD__qiz_done:
	cpw	(xsp+4), 0xffff
	jrl z, .LFSD__loop_next
	; Copy 8 bytes from entry
	pushw 0x0008
	lda xwa, (xsp+288)	; lda XWA, XSP+0x0120
	push xwa
	lda xwa, (xsp+278)	; lda XWA, XSP+0x0116
	push xwa
	call HDAE5000_MemCopy			; MemCopy
	lda xsp, (xsp + 0x0a)
	; Search 8 format fields (set QIZ bits 0-7)
	ld	qiz, 0
	; Field 0 (0x2F2A)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_HamaFnTable)             ; XWA = (XWA+0x0E88)
	ld xhl, (xwa + HamaFn_GetMediaType)
	call (xhl)
	pushw HDAE5000_Str_LSW@hi16
	pushw HDAE5000_Str_LSW@lo16		; low half of HDAE5000_Str_LSW
	lda xwa, (xsp+284)	; lda XWA, XSP+0x011C
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)	; lda XWA, XSP+0x0110
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)             ; XDE = (XDE+0x0E88)
	ld_sril xix, (xde + HamaFn__findfirst)             ; XIX = (XDE+0x0094)
	call (xix)
	ld xwa, xhl
	cp xwa, 0xffffffff
	jr z, .LFSD__f1
	ld	qiz, 1
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)             ; XHL = (XBC+0x009C)
	call (xhl)
.LFSD__f1:				; Field 1 (0x2F30)
	pushw HDAE5000_Str_PMT@hi16
	pushw HDAE5000_Str_PMT@lo16		; low half of HDAE5000_Str_PMT
	lda xwa, (xsp+284)	; lda XWA, XSP+0x011C
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)	; lda XWA, XSP+0x0110
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn__findfirst)
	call (xix)
	ld xwa, xhl
	cp xwa, 0xffffffff
	jr z, .LFSD__f2
	set	0x01, qiz
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)
	call (xhl)
.LFSD__f2:				; Field 2 (0x2F36)
	pushw HDAE5000_Str_SQT@hi16
	pushw HDAE5000_Str_SQT@lo16		; low half of HDAE5000_Str_SQT
	lda xwa, (xsp+284)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn__findfirst)
	call (xix)
	ld xwa, xhl
	cp xwa, 0xffffffff
	jr z, .LFSD__f3
	set	0x02, qiz
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)
	call (xhl)
.LFSD__f3:				; Field 3 (0x2F3C)
	pushw HDAE5000_Str_CMP@hi16
	pushw HDAE5000_Str_CMP@lo16		; low half of HDAE5000_Str_CMP
	lda xwa, (xsp+284)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn__findfirst)
	call (xix)
	ld xwa, xhl
	cp xwa, 0xffffffff
	jr z, .LFSD__f4
	set	0x03, qiz
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)
	call (xhl)
.LFSD__f4:				; Field 4 (0x2F42)
	pushw HDAE5000_Str_TM@hi16
	pushw HDAE5000_Str_TM@lo16		; low half of HDAE5000_Str_TM
	lda xwa, (xsp+284)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn__findfirst)
	call (xix)
	ld xwa, xhl
	cp xwa, 0xffffffff
	jr z, .LFSD__f5
	set	0x04, qiz
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)
	call (xhl)
.LFSD__f5:				; Field 5 (0x2F46)
	pushw HDAE5000_Str_MSP@hi16
	pushw HDAE5000_Str_MSP@lo16		; low half of HDAE5000_Str_MSP
	lda xwa, (xsp+284)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn__findfirst)
	call (xix)
	ld xwa, xhl
	cp xwa, 0xffffffff
	jr z, .LFSD__f6
	set	0x05, qiz
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)
	call (xhl)
.LFSD__f6:				; Field 6 (0x2F4C)
	pushw HDAE5000_Str_RCM@hi16
	pushw HDAE5000_Str_RCM@lo16		; low half of HDAE5000_Str_RCM
	lda xwa, (xsp+284)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn__findfirst)
	call (xix)
	ld xwa, xhl
	cp xwa, 0xffffffff
	jr z, .LFSD__f7
	set	0x06, qiz
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)
	call (xhl)
.LFSD__f7:				; Field 7 (0x2F52)
	pushw HDAE5000_Str_MD@hi16
	pushw HDAE5000_Str_MD@lo16		; low half of HDAE5000_Str_MD
	lda xwa, (xsp+284)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn__findfirst)
	call (xix)
	ld xwa, xhl
	cp xwa, 0xffffffff
	jr z, .LFSD__f8
	set	0x07, qiz
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)
	call (xhl)
.LFSD__f8:				; Field 8 (0x2F56)
	pushw HDAE5000_Str_TLX@hi16
	pushw HDAE5000_Str_TLX@lo16		; low half of HDAE5000_Str_TLX
	lda xwa, (xsp+284)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)
	ld xde, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xde, (xde + WS_HamaFnTable)
	ld_sril xix, (xde + HamaFn__findfirst)
	call (xix)
	ld xwa, xhl
	cp xwa, 0xffffffff
	jr z, .LFSD__post_search
	set	0x08, qiz
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)
	call (xhl)
.LFSD__post_search:
	; Check results and call directory handler
	lda xwa, (xsp+286)	; lda XWA, XSP+0x011E
	ld	bc, qiz
	call HDAE5000_FdSong_CheckFiles
	cp hl, 0xffff
	jrl z, .LFSD__no_match
	; Match — attempt write
	ld bc, (xsp + 0x04)
	lda xwa, (xsp+286)	; lda XWA, XSP+0x011E
	ld xde, xwa
	push	qiz
	pushw 0x0000
	pushw 0x0000
	ld	wa, (xsp+306)
	call HDAE5000_CopyFdSongToHd
	cp hl, 0xffff
	jrl nz, .LFSD__loop_next
	; Write failed — error display
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; XHL = (XWA+0x0124)
	ld xwa, HDAE5000_OBJ_ERR_SAVE
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	ld xwa, HDAE5000_OBJ_ERR_SAVE_EXIT
	ld xbc, HDAE5000_OBJ_CP_FD
	calr HDAE5000_UiObj_SetCaption
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_CP_FD
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
	ld xwa, HDAE5000_OBJ_CP_FD
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ERR_SAVE_CATCH
	ld xde, 0xffffffff
	call (xhl)
	ldw hl, 0xffff
	jrl t, .LFSD__exit
.LFSD__no_match:
	; No match — confirmation display
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_ERR_NO_HK_DATA
	ld xbc, EVT_SHOW
	ld xde, 3:i3
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_CP_FD
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_KillApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ERR_NO_HK_DATA_CATCH
	ld xde, 0xffffffff
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_CP_FD
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ERR_NO_HK_DATA_CATCH
	ld xde, 0xffffffff
	call (xhl)
	ldw hl, 0xffff
	jr t, .LFSD__exit
.LFSD__loop_next:
	inc 1, iz
	cp	iz, (xsp+302)	; cp IZ, (XSP+0x012E)
	jrl c, .LFSD__loop_body
.LFSD__loop_done:
	ld hl, 0:i3
.LFSD__exit:
	pop xiz
	lda xsp, (xsp+300)	; lda XSP, XSP+0x012C (dealloc)
	ret
	;
	; Part 2: Event handler — navigation (0x289D72)
HDAE5000_CopyToHDDirSelScreen:
	; registered as "CopyToHDDirSelScreen" in HDAE5000_ScreenProc_Table
	push xiz
	ld xiz, xde
	cp xbc, EVT_HDAE_OVER_FLOW
	jrl z, .LFSD__hA_scroll_down
	cp xbc, EVT_HDAE_UNDER_FLOW
	jrl z, .LFSD__hA_scroll_up
	cp xbc, EVT_HDAE_SELECT_SAVE
	jrl z, .LFSD__hA_sector_info
	cp xbc, EVT_HDAE_SELECT_OK
	jrl z, .LFSD__hA_cyl_calc
	cp xbc, EVT_SW_IN
	jrl nz, .LFSD__hA_exit
	; Event 0x01C00007: page select
	ld xde, xiz
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xix, (xwa + RootFn_SendEvent)
	ld xwa, 0x02600024
	ld xbc, EVT_MAKE_EDIT_SW_ID
	call (xix)
	cp xhl, 0x00000007
	jr z, .LFSD__hA_page7
	cp xhl, 0x00000006
	jr z, .LFSD__hA_page6
	cp xhl, 0x00000005
	jr z, .LFSD__hA_page5
	cp xhl, 0x00000001
	jr z, .LFSD__hA_page1
	or xhl, xhl
	jrl nz, .LFSD__hA_exit
	; Page 0: offset = 0x0000
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0000
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX
	calr HDAE5000_DirList_BuildPage
	jrl t, .LFSD__hA_exit
.LFSD__hA_page1:			; Page 1: offset = 0x0018
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0018
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX
	calr HDAE5000_DirList_BuildPage
	jrl t, .LFSD__hA_exit
.LFSD__hA_page5:			; Page 5: offset = 0x0030
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0030
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX
	calr HDAE5000_DirList_BuildPage
	jrl t, .LFSD__hA_exit
.LFSD__hA_page6:			; Page 6: offset = 0x0048
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0048
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX
	calr HDAE5000_DirList_BuildPage
	jrl t, .LFSD__hA_exit
.LFSD__hA_page7:			; Page 7: offset = 0x0060
	ldw (HDAE5000_RAM_DirPageBase:24), 0x0060
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX
	calr HDAE5000_DirList_BuildPage
	jrl t, .LFSD__hA_exit
.LFSD__hA_cyl_calc:			; Event 0x01EA0006: cylinder select
	ld wa, (HDAE5000_RAM_DirPageBase:24)
	ld bc, iz
	add bc, wa
	ld (HDAE5000_RAM_CurDir:24), bc
	ld wa, bc
	call HDAE5000_Dir_IsBlankName
	cp hl, 0xffff
	jr nz, .LFSD__hA_cyl_ok
	; Invalid — error display
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_ATTEN_CP_UNNAMED
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_CP_FD_DIRSEL
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_KillApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ATTEN_CP_UNNAMED_CATCH
	ld xde, 0xffffffff
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_CP_FD_DIRSEL
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ATTEN_CP_UNNAMED_CATCH
	ld xde, 0xffffffff
	call (xhl)
	jrl t, .LFSD__hA_exit
.LFSD__hA_cyl_ok:
	; Valid cylinder — check bounds
	calr HDAE5000_Count_Active_Files
	ld iz, hl
	ld wa, (HDAE5000_RAM_CurDir:24)
	call HDAE5000_Dir_CountEmptySongs
	cp hl, iz
	jr c, .LFSD__hA_cyl_fits
	; Too many — error + recursive scan
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_HD_PLEASE
	ld xbc, EVT_SHOW
	ld xde, 5:i3
	call (xhl)
	lda xwa, (0x22abb0:24)
	ld de, (HDAE5000_RAM_CurDir:24)
	ldw bc, 0x0014
	calr HDAE5000_CopyToHd_Execute	; recursive
	cp hl, 0xffff
	jrl z, .LFSD__hA_exit
	; Display clear + redraw
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jrl t, .LFSD__hA_exit
.LFSD__hA_cyl_fits:
	; Fits — setup display + dialog boxes
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_ATTEN_FULL_DIR
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_CP_FD_DIRSEL
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_KillApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ATTEN_FULL_DIR_CATCH
	ld xde, 0xffffffff
	call (xhl)
	ld xwa, EVT_HDAE_TIMER_BACK
	push xwa
	ld xwa, HDAE5000_OBJ_CP_FD_DIRSEL
	push xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_SetApTimer)
	ld xwa, 0x0000014d
	ld xbc, HDAE5000_OBJ_ATTEN_FULL_DIR_CATCH
	ld xde, 0xffffffff
	call (xhl)
	jrl t, .LFSD__hA_exit
.LFSD__hA_sector_info:			; Event 0x01EA0008: sector info display
	ld wa, (HDAE5000_RAM_DirPageBase:24)
	ld bc, iz
	add bc, wa
	ld (HDAE5000_RAM_CurDir:24), bc
	ld wa, bc
	call HDAE5000_DirName_Address
	ld xde, xhl
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApFuncCall)             ; XHL = (XWA+0x0250)
	ld xwa, NAKA_APFUNC_CP_FD_DIRNAMECheck
	ld xbc, EVT_SET_STRING
	call (xhl)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD_DIR_NAMING
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jr t, .LFSD__hA_exit
.LFSD__hA_scroll_up:			; Event 0x01EA0001: scroll up
	cpw (HDAE5000_RAM_DirPageBase:24), 0x0018
	jr lt, .LFSD__hA_exit
	subw	(HDAE5000_RAM_DirPageBase:24), 24
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX
	calr HDAE5000_DirList_BuildPage
	ld xwa, xiz
	add xwa, 0x00000018
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX
	ld xbc, EVT_HDAE_SET_SEL_NUM
	call (xhl)
	jr t, .LFSD__hA_exit
.LFSD__hA_scroll_down:			; Event 0x01EA0000: scroll down
	cpw (HDAE5000_RAM_DirPageBase:24), 0x0060
	jr ge, .LFSD__hA_exit
	addw	(HDAE5000_RAM_DirPageBase:24), 24
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX
	calr HDAE5000_DirList_BuildPage
	ld xwa, xiz
	sub xwa, 0x00000018
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX
	ld xbc, EVT_HDAE_SET_SEL_NUM
	call (xhl)
.LFSD__hA_exit:
	ld xhl, 0:i3
	pop xiz
	ret
	;
	; Part 3: Event handler — file operations (0x28A07E)
HDAE5000_CP_FD_DIRNAMECheck:
	; registered as "CP_FD_DIRNAMECheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	cp xbc, EVT_SW_IN
	jr z, .LFSD__hB_key
	cp xbc, EVT_GET_STRING_LENGTH
	jr z, .LFSD__hB_7c
	cp xbc, EVT_GET_NAMING_MODE
	jr z, .LFSD__hB_84
	cp xbc, EVT_SET_STRING
	jr z, .LFSD__hB_86
	cp xbc, EVT_GET_STRING
	jrl nz, .LFSD__hB_default
	; Event 0x01E0003A: copy data block
	pushw 0x0010
	lda xwa, (0x23a06e:24)
	push xwa
	push xde
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 0x0a)
	ld xhl, xiz
	jrl t, .LFSD__hB_exit2
.LFSD__hB_86:				; Event 0x01E00086: copy + clear flag
	pushw 0x0010
	push xde
	pushw 0x0023
	pushw 0xa06e
	call HDAE5000_StrNCpy
	lda xsp, (xsp + 0x0a)
	ld (0x23a07e:24), 0x00
	ld xhl, xiz
	jrl t, .LFSD__hB_exit2
.LFSD__hB_84:				; Event 0x01E00084
	ld xhl, 0:i3
	jrl t, .LFSD__hB_exit2
.LFSD__hB_7c:				; Event 0x01E0007C
	ld xhl, 0x00000010
	jrl t, .LFSD__hB_exit2
.LFSD__hB_key:				; Event 0x01C00007: key dispatch
	cp xde, 0x0000000b
	jr z, .LFSD__hB_key_0b
	cp xde, 0x0000008a
	jrl nz, .LFSD__hB_default
	; Key 0x8A: validate string + copy
	lda xwa, (0x22abf2:24)
	calr HDAE5000_NameHistory_Recall
	ld xiz, xhl
	ld xwa, xiz
	or xwa, xwa
	jrl z, .LFSD__hB_default
	ld xwa, xiz
	push xwa
	call HDAE5000_StrLen
	pushw hl                                ; push hl (compact)
	ld xwa, xiz
	push xwa
	lda xwa, (0x23a06e:24)
	push xwa
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0e)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xix, (xwa + RootFn_GetNamingWindowID)             ; XIX = (XWA+0x050C)
	call (xix)
	lda xwa, (0x23a06e:24)
	ld xbc, xwa
	ld xwa, xhl
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_SET_STRING
	call (xhl)
	jr t, .LFSD__hB_default
.LFSD__hB_key_0b:			; Key 0x0B: direct lookup
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xix, (xwa + RootFn_GetNamingWindowID)
	call (xix)
	lda xwa, (0x23a06e:24)
	ld xbc, xwa
	ld xwa, xhl
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_GET_STRING
	call (xhl)
	; Update display
	ld wa, (HDAE5000_RAM_CurDir:24)
	lda xbc, (0x23a06e:24)
	ld xde, HDAE5000_OBJ_CP_FD_DIRSEL
	calr HDAE5000_DirName_StoreWithUi
	ld xwa, HDAE5000_OBJ_SEL_DIR
	calr HDAE5000_DirList_BuildPage
.LFSD__hB_default:
	ld xhl, 0:i3
.LFSD__hB_exit2:
	pop xiz
	ret
	;
	; Part 4: Event handler — menu selection (0x28A1A7)
HDAE5000_WrConfirmEventCatch:
	; registered as "WrConfirmEventCatch" in HDAE5000_ObjHandler_Table
	dec 8, xsp			; alloc 4 bytes
	push xiz
	ld (xsp + 0x04), xde
	ld xiz, xbc
	ld (xsp + 0x08), xwa
	ld xwa, xiz
	cp xwa, EVT_SW_IN
	jr z, .LFSD__hC_key
	cp xwa, EVT_DRAW
	jr z, .LFSD__hC_0d
	cp xwa, EVT_ARE_YOU_CLASS_PROC
	jrl nz, .LFSD__hC_default
	; Event 0x01E00085
	ld xhl, 1:i3
	jrl t, .LFSD__hC_exit
.LFSD__hC_0d:				; Event 0x01C0000D: pass-through
	ld xwa, (xsp + 0x08)
	ld xbc, xiz
	ld xde, (xsp + 0x04)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)
	ld_sril xhl, (xhl + RootFn_InheritedProc)
	call (xhl)
	lda xwa, (HDAE5000_Str_Wrcn:24)
	ld xbc, xwa
	ld xwa, (xsp + 0x08)
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)
	ld_sril xhl, (xbc + RootFn_SendEvent)
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	ld xhl, 0:i3
	jrl t, .LFSD__hC_exit
.LFSD__hC_key:				; Event 0x01C00007: key dispatch
	ld xde, (xsp + 0x04)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xix, (xwa + RootFn_SendEvent)
	ld xwa, 0x02600024
	ld xbc, EVT_MAKE_EDIT_SW_ID
	call (xix)
	cp xhl, 0x00000007
	jr z, .LFSD__hC_key_67
	cp xhl, 0x00000006
	jr z, .LFSD__hC_key_67
	cp xhl, 0x00000001
	jr z, .LFSD__hC_key_1
	or xhl, xhl
	jrl nz, .LFSD__hC_default
.LFSD__hC_key_1:			; Key 0 or 1: register menu + display
	lda xwa, (0x23a04e:24)
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)
	ld xwa, HDAE5000_OBJ_HddNamingWindow
	ld xbc, EVT_GET_STRING
	call (xhl)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xhl, (xwa + RootFn_SendEvent)
	ld xwa, HDAE5000_OBJ_HDD_FILE_NAMING
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	pushw 0x0023
	pushw 0xa04e
	pushw 0x0001
	ld xwa, HDAE5000_OBJ_SELECT_FILE
	push xwa
	ld wa, (HDAE5000_RAM_CurDir:24)
	ld bc, (HDAE5000_RAM_CurSong:24)
	ld de, (HDAE5000_RAM_SaveOptions:24)
	calr HDAE5000_SaveSongWithUi
	ld wa, 0:i3
	ld bc, 0:i3
	calr HDAE5000_SongScreen_Refresh
	jr t, .LFSD__hC_default
.LFSD__hC_key_67:			; Key 6 or 7: close display
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_SELECT_FILE
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
.LFSD__hC_default:			; Default: pass-through to registered handler
	ld xwa, (xsp + 0x08)
	ld xbc, xiz
	ld xde, (xsp + 0x04)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)
	ld_sril xix, (xhl + RootFn_InheritedProc)
	call (xix)
.LFSD__hC_exit:
	pop xiz
	inc 8, xsp
	ret

HDAE5000_DelOpt_ShowFlags:	; 0x28A2F0 (739 bytes)
	; Look up a file entry in the filesystem
	; ^ corrected: show the nine delete-option flags (0x22ABE8..) as the
	;   texts of the pointer table 0x2E1E14 ("---", "OFF", "DEL") in objects
	;   0x7F01CF.., event 0x01C0000F.
	; Part 1: 9 lookup blocks — read byte, lookup table, call handler
	; Block 1: address 0x22ABE8, command 0x007F01CF
	ld a, (0x22abe8:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)             ; ld XWA, (XWA + 0x0E0A)
	ld xhl, (xwa + RootFn_PostEvent)             ; ld XHL, (XWA + 0x0104)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_LSW
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	; Block 2: address 0x22ABE9, command 0x007F01D0
	ld a, (0x22abe9:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_PMT
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	; Block 3: address 0x22ABEA, command 0x007F01D1
	ld a, (0x22abea:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_SQT
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	; Block 4: address 0x22ABEB, command 0x007F01D2
	ld a, (0x22abeb:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_CMP
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	; Block 5: address 0x22ABEC, command 0x007F01D3
	ld a, (0x22abec:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_TM
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	; Block 6: address 0x22ABED, command 0x007F01D4
	ld a, (0x22abed:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_MSP
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	; Block 7: address 0x22ABEE, command 0x007F01D5
	ld a, (0x22abee:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_RCM
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	; Block 8: address 0x22ABEF, command 0x007F01D6
	ld a, (0x22abef:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_MD
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	; Block 9: address 0x22ABF0, command 0x007F01E9 (tail call)
	ld a, (0x22abf0:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_TLX
	ld xbc, EVT_PARA_DRAW
	jp (xhl)			; tail call (not call)
	;
	; Part 2: Event handler (0x28A497) — dispatches on event codes
HDAE5000_DelOptSwEventCatch:
	; registered as "DelOptSwEventCatch" in HDAE5000_ObjHandler_Table
	dec 8, xsp			; allocate 8 bytes
	push xiz
	ld (xsp + 0x04), xde		; save XDE to stack
	ld xiz, xbc			; save event code in XIZ
	ld (xsp + 0x08), xwa		; save XWA to stack
	ld xwa, xiz			; XWA = event code
	cp xwa, EVT_SW_IN		; event 0x01C00007?
	jr z, .LFS_EL__evt_07
	cp xwa, EVT_DRAW		; event 0x01C0000D?
	jr z, .LFS_EL__evt_0d
	cp xwa, EVT_ARE_YOU_CLASS_PROC		; event 0x01E00085?
	jrl nz, .LFS_EL__exit		; no match → exit
	ld xhl, 1:i3			; XHL = 1
	jrl t, .LFS_EL__epilogue
.LFS_EL__evt_0d:			; handler for event 0x0D
	ld xwa, (xsp + 0x08)		; restore XWA
	ld xbc, xiz
	ld xde, (xsp + 0x04)		; restore XDE
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)             ; ld XHL, (XHL + 0x0E0A)
	ld_sril xhl, (xhl + RootFn_InheritedProc)             ; ld XHL, (XHL + 0x00DC)
	call (xhl)
	lda xwa, (HDAE5000_Str_DEL_DelOptSwEventCatch:24); status display data
	ld xbc, xwa
	ld xwa, (xsp + 0x08)
	ld xde, xbc
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_RootFnTable)             ; ld XBC, (XBC + 0x0E0A)
	ld_sril xhl, (xbc + RootFn_SendEvent)             ; ld XHL, (XBC + 0x0100)
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	ld xhl, 0:i3
	jrl t, .LFS_EL__epilogue
.LFS_EL__evt_07:			; handler for event 0x07
	ld xde, (xsp + 0x04)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld_sril xix, (xwa + RootFn_SendEvent)             ; ld XIX, (XWA + 0x0100)
	ld xwa, 0x02600024
	ld xbc, EVT_MAKE_EDIT_SW_ID
	call (xix)
	; Check return value in XHL
	cp xhl, 0x0000000b
	jr z, .LFS_EL__case_0b
	cp xhl, 0x0000000a
	jr z, .LFS_EL__case_0a
	cp xhl, 0x00000008
	jr nz, .LFS_EL__exit
	; Case 0x08: delete file entry
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; ld XHL, (XWA + 0x0124)
	ld xwa, HDAE5000_OBJ_ATTEN_DEL_FILE
	ld xbc, EVT_SHOW
	ld xde, 0:i3
	call (xhl)
	jr t, .LFS_EL__exit
.LFS_EL__case_0a:			; Case 0x0A: copy file
	ld wa, (HDAE5000_RAM_CurDir:24)
	ld bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_PartMask
	ld wa, hl
	cp wa, 0xffff
	jr z, .LFS_EL__0a_skip
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	pushw 0x0002
	ld bc, hl
	lda xde, (HDAE5000_DelOpt_TemplateBlank:24)
	calr HDAE5000_TypeSel_Init
.LFS_EL__0a_skip:
	calr HDAE5000_DelOpt_ShowFlags	; recursive call
	jr t, .LFS_EL__exit
.LFS_EL__case_0b:			; Case 0x0B: save file
	ld wa, (HDAE5000_RAM_CurDir:24)
	ld bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_Song_PartMask
	ld wa, hl
	cp wa, 0xffff
	jr z, .LFS_EL__0b_skip
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	pushw 0x0001
	ld bc, hl
	lda xde, (HDAE5000_DelOpt_TemplateBlank:24)
	calr HDAE5000_TypeSel_Init
.LFS_EL__0b_skip:
	ldw (HDAE5000_RAM_DeleteOptions:24), 0x0000; clear entry
	calr HDAE5000_DelOpt_ShowFlags	; recursive call
.LFS_EL__exit:				; common exit path
	ld xwa, (xsp + 0x08)		; restore registers
	ld xbc, xiz
	ld xde, (xsp + 0x04)
	ld xhl, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xhl, (xhl + WS_RootFnTable)             ; ld XHL, (XHL + 0x0E0A)
	ld_sril xix, (xhl + RootFn_InheritedProc)             ; ld XIX, (XHL + 0x00DC)
	call (xix)
.LFS_EL__epilogue:
	pop xiz
	inc 8, xsp			; deallocate 8 bytes
	ret

; --- Display, Menu, and Utility Routines ---
HDAE5000_DelOpt_InitFromSong:	; 0x28A5D3 (1612 bytes)
	; Part 1: Table lookup + data copy utility (68 bytes)
	; (= init the delete options 0x22ABE6 (HDAE5000_TypeSel_Init with template
	; 0x2E1E08) to "DEL" (2) for the parts song 0x23A092/0x23A094 holds.)
	ld wa, (HDAE5000_RAM_CurDir:24); WA = cylinder
	ld bc, (HDAE5000_RAM_CurSong:24); BC = head
	call HDAE5000_Song_PartMask
	ld wa, hl
	cp wa, 0xffff
	jr z, .LDUO__not_found
	; Found — copy data
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	pushw 0x0002
	ld bc, hl
	lda xde, (HDAE5000_DelOpt_TemplateBlank:24)
	calr HDAE5000_TypeSel_Init
	jr t, .LDUO__done_p1
.LDUO__not_found:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	pushw 0x0002
	lda xde, (HDAE5000_DelOpt_TemplateBlank:24)
	ld bc, 0:i3
	calr HDAE5000_TypeSel_Init
.LDUO__done_p1:
	ldw (HDAE5000_RAM_DeleteOptions:24), 0x0000
	ret
	;
	; Part 2: Handler A (0x28A617) — event handler with stack frame
HDAE5000_DelOptNameCheck:
	; registered as "DelOptNameCheck" in HDAE5000_ObjHandler_Table
	dec 4, xsp			; alloc 16 bytes
	push xiz
	ld (xsp + 0x04), xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LDUO__hA_ev82
	sub xwa, EVT_GET_LARGE_STEP		; normalize event code
	cp xwa, 0x00000000
	jr lt, .LDUO__hA_default
	cp xwa, 0x00000009
	jr gt, .LDUO__hA_default
	add xwa, xwa
	add xwa, HDAE5000_DelOptNameCheck_CaseTable		; jump table
	ld wa, (xwa)
	lda xix, (HDAE5000_DelOptNameCheck_Ev01E00047:24); dispatch base
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0: full lookup
HDAE5000_DelOptNameCheck_Ev01E00047:
	ld xiz, xde
	ld wa, (HDAE5000_RAM_CurDir:24)
	ld bc, (HDAE5000_RAM_CurSong:24)
	call HDAE5000_SongRecord_Address
	push xhl
	pushw HDAE5000_Fmt_s_DelOptNameCheck@hi16
	pushw HDAE5000_Fmt_s_DelOptNameCheck@lo16		; low half of HDAE5000_Fmt_s_DelOptNameCheck
	ld xwa, (xiz + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, (xsp + 0x04)
	jr t, .LDUO__hA_exit
	; Case 1
HDAE5000_DelOptNameCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hA_exit
	; Case 2
HDAE5000_DelOptNameCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hA_exit
	; Case 3
HDAE5000_DelOptNameCheck_Ev01E00043:
	ld xhl, 0:i3
	jr t, .LDUO__hA_exit
	; Case 4
HDAE5000_DelOptNameCheck_Ev01E00044:
	ld xhl, 0:i3
	jr t, .LDUO__hA_exit
	; Case 5
HDAE5000_DelOptNameCheck_Ev01E00045:
	lda xhl, (0x22aa57:24)
	jr t, .LDUO__hA_exit
	; Case 6
HDAE5000_DelOptNameCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hA_exit
.LDUO__hA_ev82:
	ld xhl, 0:i3
	jr t, .LDUO__hA_exit
.LDUO__hA_default:
	ld xhl, 0:i3
.LDUO__hA_exit:
	pop xiz
	inc 4, xsp
	ret
	;
	; Part 3: Handler B (0x28A69D) — digit callback for slot 0 (0x22ABE8)
HDAE5000_DelLswEditCheck:
	; registered as "DelLswEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LDUO__hB_ev82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jr lt, .LDUO__hB_default
	cp xwa, 0x00000009
	jr gt, .LDUO__hB_default
	add xwa, xwa
	add xwa, HDAE5000_DelLswEditCheck_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_DelLswEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0: index + format + display
HDAE5000_DelLswEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_DelLswEditCheck@hi16
	pushw HDAE5000_Fmt_s_DelLswEditCheck@lo16		; low half of HDAE5000_Fmt_s_DelLswEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LDUO__hB_exit
	; Case 1
HDAE5000_DelLswEditCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hB_exit
	; Case 2
HDAE5000_DelLswEditCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hB_exit
	; Case 3: conditional on (0x22abe8)
HDAE5000_DelLswEditCheck_Ev01E00043:
	ld xhl, 2:i3
	cp (0x22abe8:24), 0x00
	jr nz, .LDUO__hB_c3_nz
	ld xhl, 0:i3
.LDUO__hB_c3_nz:
	jr t, .LDUO__hB_exit
	; Case 4: conditional on (0x22abe8)
HDAE5000_DelLswEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (0x22abe8:24), 0x00
	jr nz, .LDUO__hB_c4_nz
	ld xhl, 0:i3
.LDUO__hB_c4_nz:
	jr t, .LDUO__hB_exit
	; Case 5
HDAE5000_DelLswEditCheck_Ev01E00045:
	lda xhl, (0x22abe8:24)
	jr t, .LDUO__hB_exit
	; Case 6
HDAE5000_DelLswEditCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hB_exit
.LDUO__hB_ev82:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .LDUO__hB_exit
.LDUO__hB_default:
	ld xhl, 0:i3
.LDUO__hB_exit:
	pop xiz
	ret
	;
	; Part 4: Handler C (0x28A738) — slot 1 (0x22ABE9)
HDAE5000_DelPmtEditCheck:
	; registered as "DelPmtEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LDUO__hC_ev82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jr lt, .LDUO__hC_default
	cp xwa, 0x00000009
	jr gt, .LDUO__hC_default
	add xwa, xwa
	add xwa, HDAE5000_DelPmtEditCheck_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_DelPmtEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0
HDAE5000_DelPmtEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_DelPmtEditCheck@hi16
	pushw HDAE5000_Fmt_s_DelPmtEditCheck@lo16		; low half of HDAE5000_Fmt_s_DelPmtEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LDUO__hC_exit
	; Case 1
HDAE5000_DelPmtEditCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hC_exit
	; Case 2
HDAE5000_DelPmtEditCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hC_exit
	; Case 3
HDAE5000_DelPmtEditCheck_Ev01E00043:
	ld xhl, 2:i3
	cp (0x22abe9:24), 0x00
	jr nz, .LDUO__hC_c3_nz
	ld xhl, 0:i3
.LDUO__hC_c3_nz:
	jr t, .LDUO__hC_exit
	; Case 4
HDAE5000_DelPmtEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (0x22abe9:24), 0x00
	jr nz, .LDUO__hC_c4_nz
	ld xhl, 0:i3
.LDUO__hC_c4_nz:
	jr t, .LDUO__hC_exit
	; Case 5
HDAE5000_DelPmtEditCheck_Ev01E00045:
	lda xhl, (0x22abe9:24)
	jr t, .LDUO__hC_exit
	; Case 6
HDAE5000_DelPmtEditCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hC_exit
.LDUO__hC_ev82:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .LDUO__hC_exit
.LDUO__hC_default:
	ld xhl, 0:i3
.LDUO__hC_exit:
	pop xiz
	ret
	;
	; Part 5: Handler D (0x28A7D3) — slot 2 (0x22ABEA)
HDAE5000_DelSqtEditCheck:
	; registered as "DelSqtEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LDUO__hD_ev82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jr lt, .LDUO__hD_default
	cp xwa, 0x00000009
	jr gt, .LDUO__hD_default
	add xwa, xwa
	add xwa, HDAE5000_DelSqtEditCheck_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_DelSqtEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0
HDAE5000_DelSqtEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_DelSqtEditCheck@hi16
	pushw HDAE5000_Fmt_s_DelSqtEditCheck@lo16		; low half of HDAE5000_Fmt_s_DelSqtEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LDUO__hD_exit
	; Case 1
HDAE5000_DelSqtEditCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hD_exit
	; Case 2
HDAE5000_DelSqtEditCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hD_exit
	; Case 3
HDAE5000_DelSqtEditCheck_Ev01E00043:
	ld xhl, 2:i3
	cp (0x22abea:24), 0x00
	jr nz, .LDUO__hD_c3_nz
	ld xhl, 0:i3
.LDUO__hD_c3_nz:
	jr t, .LDUO__hD_exit
	; Case 4
HDAE5000_DelSqtEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (0x22abea:24), 0x00
	jr nz, .LDUO__hD_c4_nz
	ld xhl, 0:i3
.LDUO__hD_c4_nz:
	jr t, .LDUO__hD_exit
	; Case 5
HDAE5000_DelSqtEditCheck_Ev01E00045:
	lda xhl, (0x22abea:24)
	jr t, .LDUO__hD_exit
	; Case 6
HDAE5000_DelSqtEditCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hD_exit
.LDUO__hD_ev82:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .LDUO__hD_exit
.LDUO__hD_default:
	ld xhl, 0:i3
.LDUO__hD_exit:
	pop xiz
	ret
	;
	; Part 6: Handler E (0x28A86E) — slot 3 (0x22ABEB)
HDAE5000_DelCmpEditCheck:
	; registered as "DelCmpEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LDUO__hE_ev82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jr lt, .LDUO__hE_default
	cp xwa, 0x00000009
	jr gt, .LDUO__hE_default
	add xwa, xwa
	add xwa, HDAE5000_DelCmpEditCheck_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_DelCmpEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0
HDAE5000_DelCmpEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_DelCmpEditCheck@hi16
	pushw HDAE5000_Fmt_s_DelCmpEditCheck@lo16		; low half of HDAE5000_Fmt_s_DelCmpEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LDUO__hE_exit
	; Case 1
HDAE5000_DelCmpEditCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hE_exit
	; Case 2
HDAE5000_DelCmpEditCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hE_exit
	; Case 3
HDAE5000_DelCmpEditCheck_Ev01E00043:
	ld xhl, 2:i3
	cp (0x22abeb:24), 0x00
	jr nz, .LDUO__hE_c3_nz
	ld xhl, 0:i3
.LDUO__hE_c3_nz:
	jr t, .LDUO__hE_exit
	; Case 4
HDAE5000_DelCmpEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (0x22abeb:24), 0x00
	jr nz, .LDUO__hE_c4_nz
	ld xhl, 0:i3
.LDUO__hE_c4_nz:
	jr t, .LDUO__hE_exit
	; Case 5
HDAE5000_DelCmpEditCheck_Ev01E00045:
	lda xhl, (0x22abeb:24)
	jr t, .LDUO__hE_exit
	; Case 6
HDAE5000_DelCmpEditCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hE_exit
.LDUO__hE_ev82:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .LDUO__hE_exit
.LDUO__hE_default:
	ld xhl, 0:i3
.LDUO__hE_exit:
	pop xiz
	ret
	;
	; Part 7: Handler F (0x28A909) — slot 4 (0x22ABEC)
HDAE5000_DelTmEditCheck:
	; registered as "DelTmEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LDUO__hF_ev82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jr lt, .LDUO__hF_default
	cp xwa, 0x00000009
	jr gt, .LDUO__hF_default
	add xwa, xwa
	add xwa, HDAE5000_DelTmEditCheck_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_DelTmEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0
HDAE5000_DelTmEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_DelTmEditCheck@hi16
	pushw HDAE5000_Fmt_s_DelTmEditCheck@lo16		; low half of HDAE5000_Fmt_s_DelTmEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LDUO__hF_exit
	; Case 1
HDAE5000_DelTmEditCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hF_exit
	; Case 2
HDAE5000_DelTmEditCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hF_exit
	; Case 3
HDAE5000_DelTmEditCheck_Ev01E00043:
	ld xhl, 2:i3
	cp (0x22abec:24), 0x00
	jr nz, .LDUO__hF_c3_nz
	ld xhl, 0:i3
.LDUO__hF_c3_nz:
	jr t, .LDUO__hF_exit
	; Case 4
HDAE5000_DelTmEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (0x22abec:24), 0x00
	jr nz, .LDUO__hF_c4_nz
	ld xhl, 0:i3
.LDUO__hF_c4_nz:
	jr t, .LDUO__hF_exit
	; Case 5
HDAE5000_DelTmEditCheck_Ev01E00045:
	lda xhl, (0x22abec:24)
	jr t, .LDUO__hF_exit
	; Case 6
HDAE5000_DelTmEditCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hF_exit
.LDUO__hF_ev82:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .LDUO__hF_exit
.LDUO__hF_default:
	ld xhl, 0:i3
.LDUO__hF_exit:
	pop xiz
	ret
	;
	; Part 8: Handler G (0x28A9A4) — slot 5 (0x22ABED)
HDAE5000_DelMspEditCheck:
	; registered as "DelMspEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LDUO__hG_ev82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jr lt, .LDUO__hG_default
	cp xwa, 0x00000009
	jr gt, .LDUO__hG_default
	add xwa, xwa
	add xwa, HDAE5000_DelMspEditCheck_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_DelMspEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0
HDAE5000_DelMspEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_DelMspEditCheck@hi16
	pushw HDAE5000_Fmt_s_DelMspEditCheck@lo16		; low half of HDAE5000_Fmt_s_DelMspEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LDUO__hG_exit
	; Case 1
HDAE5000_DelMspEditCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hG_exit
	; Case 2
HDAE5000_DelMspEditCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hG_exit
	; Case 3
HDAE5000_DelMspEditCheck_Ev01E00043:
	ld xhl, 2:i3
	cp (0x22abed:24), 0x00
	jr nz, .LDUO__hG_c3_nz
	ld xhl, 0:i3
.LDUO__hG_c3_nz:
	jr t, .LDUO__hG_exit
	; Case 4
HDAE5000_DelMspEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (0x22abed:24), 0x00
	jr nz, .LDUO__hG_c4_nz
	ld xhl, 0:i3
.LDUO__hG_c4_nz:
	jr t, .LDUO__hG_exit
	; Case 5
HDAE5000_DelMspEditCheck_Ev01E00045:
	lda xhl, (0x22abed:24)
	jr t, .LDUO__hG_exit
	; Case 6
HDAE5000_DelMspEditCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hG_exit
.LDUO__hG_ev82:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .LDUO__hG_exit
.LDUO__hG_default:
	ld xhl, 0:i3
.LDUO__hG_exit:
	pop xiz
	ret
	;
	; Part 9: Handler H (0x28AA3F) — slot 6 (0x22ABEE)
HDAE5000_DelRcmEditCheck:
	; registered as "DelRcmEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LDUO__hH_ev82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jr lt, .LDUO__hH_default
	cp xwa, 0x00000009
	jr gt, .LDUO__hH_default
	add xwa, xwa
	add xwa, HDAE5000_DelRcmEditCheck_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_DelRcmEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0
HDAE5000_DelRcmEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_DelRcmEditCheck@hi16
	pushw HDAE5000_Fmt_s_DelRcmEditCheck@lo16		; low half of HDAE5000_Fmt_s_DelRcmEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LDUO__hH_exit
	; Case 1
HDAE5000_DelRcmEditCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hH_exit
	; Case 2
HDAE5000_DelRcmEditCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hH_exit
	; Case 3
HDAE5000_DelRcmEditCheck_Ev01E00043:
	ld xhl, 2:i3
	cp (0x22abee:24), 0x00
	jr nz, .LDUO__hH_c3_nz
	ld xhl, 0:i3
.LDUO__hH_c3_nz:
	jr t, .LDUO__hH_exit
	; Case 4
HDAE5000_DelRcmEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (0x22abee:24), 0x00
	jr nz, .LDUO__hH_c4_nz
	ld xhl, 0:i3
.LDUO__hH_c4_nz:
	jr t, .LDUO__hH_exit
	; Case 5
HDAE5000_DelRcmEditCheck_Ev01E00045:
	lda xhl, (0x22abee:24)
	jr t, .LDUO__hH_exit
	; Case 6
HDAE5000_DelRcmEditCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hH_exit
.LDUO__hH_ev82:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .LDUO__hH_exit
.LDUO__hH_default:
	ld xhl, 0:i3
.LDUO__hH_exit:
	pop xiz
	ret
	;
	; Part 10: Handler I (0x28AADA) — slot 7 (0x22ABEF)
HDAE5000_DelMdEditCheck:
	; registered as "DelMdEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jr z, .LDUO__hI_ev82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jr lt, .LDUO__hI_default
	cp xwa, 0x00000009
	jr gt, .LDUO__hI_default
	add xwa, xwa
	add xwa, HDAE5000_DelMdEditCheck_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_DelMdEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0
HDAE5000_DelMdEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_DelMdEditCheck@hi16
	pushw HDAE5000_Fmt_s_DelMdEditCheck@lo16		; low half of HDAE5000_Fmt_s_DelMdEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LDUO__hI_exit
	; Case 1
HDAE5000_DelMdEditCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hI_exit
	; Case 2
HDAE5000_DelMdEditCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hI_exit
	; Case 3
HDAE5000_DelMdEditCheck_Ev01E00043:
	ld xhl, 2:i3
	cp (0x22abef:24), 0x00
	jr nz, .LDUO__hI_c3_nz
	ld xhl, 0:i3
.LDUO__hI_c3_nz:
	jr t, .LDUO__hI_exit
	; Case 4
HDAE5000_DelMdEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (0x22abef:24), 0x00
	jr nz, .LDUO__hI_c4_nz
	ld xhl, 0:i3
.LDUO__hI_c4_nz:
	jr t, .LDUO__hI_exit
	; Case 5
HDAE5000_DelMdEditCheck_Ev01E00045:
	lda xhl, (0x22abef:24)
	jr t, .LDUO__hI_exit
	; Case 6
HDAE5000_DelMdEditCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hI_exit
.LDUO__hI_ev82:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .LDUO__hI_exit
.LDUO__hI_default:
	ld xhl, 0:i3
.LDUO__hI_exit:
	pop xiz
	ret
	;
	; Part 11: Handler J (0x28AB75) — slot 8 (0x22ABF0), variant with jrl
HDAE5000_DelTlxEditCheck:
	; registered as "DelTlxEditCheck" in HDAE5000_ObjHandler_Table
	push xiz
	ld xiz, xwa
	ld xwa, xbc
	cp xwa, EVT_RAM_DATA_REQ
	jrl z, .LDUO__hJ_ev82
	sub xwa, EVT_GET_LARGE_STEP
	cp xwa, 0x00000000
	jrl lt, .LDUO__hJ_default
	cp xwa, 0x00000009
	jrl gt, .LDUO__hJ_default
	add xwa, xwa
	add xwa, HDAE5000_DelTlxEditCheck_CaseTable
	ld wa, (xwa)
	lda xix, (HDAE5000_DelTlxEditCheck_Ev01E00047:24)
	jp	t, (xix+wa)	; jp (XIX + WA)
	; Case 0
HDAE5000_DelTlxEditCheck_Ev01E00047:
	ld xwa, (xde + 0x0e)
	sll xwa, 2
	ld xbc, HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL
	add xbc, xwa
	ld xwa, (xbc)
	push xwa
	pushw HDAE5000_Fmt_s_DelTlxEditCheck@hi16
	pushw HDAE5000_Fmt_s_DelTlxEditCheck@lo16		; low half of HDAE5000_Fmt_s_DelTlxEditCheck
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xsp, (xsp + 0x0c)
	ld xhl, xiz
	jr t, .LDUO__hJ_exit
	; Case 1
HDAE5000_DelTlxEditCheck_Ev01E0003E:
	ld xhl, 1:i3
	jr t, .LDUO__hJ_exit
	; Case 2
HDAE5000_DelTlxEditCheck_Ev01E0003F:
	ld xhl, 1:i3
	jr t, .LDUO__hJ_exit
	; Case 3
HDAE5000_DelTlxEditCheck_Ev01E00043:
	ld xhl, 2:i3
	cp (0x22abf0:24), 0x00
	jr nz, .LDUO__hJ_c3_nz
	ld xhl, 0:i3
.LDUO__hJ_c3_nz:
	jr t, .LDUO__hJ_exit
	; Case 4: extra comparison vs 0x01
HDAE5000_DelTlxEditCheck_Ev01E00044:
	cp (0x22abf0:24), 0x01
	jr nz, .LDUO__hJ_c4_ne1
	ld xhl, 2:i3
	jr t, .LDUO__hJ_c4_chk
.LDUO__hJ_c4_ne1:
	ld xhl, 1:i3
.LDUO__hJ_c4_chk:
	cp (0x22abf0:24), 0x00
	jr nz, .LDUO__hJ_c4_nz
	ld xhl, 0:i3
.LDUO__hJ_c4_nz:
	jr t, .LDUO__hJ_exit
	; Case 5
HDAE5000_DelTlxEditCheck_Ev01E00045:
	lda xhl, (0x22abf0:24)
	jr t, .LDUO__hJ_exit
	; Case 6
HDAE5000_DelTlxEditCheck_Ev01E00046:
	ld xhl, 1:i3
	jr t, .LDUO__hJ_exit
.LDUO__hJ_ev82:
	lda xwa, (HDAE5000_RAM_DeleteOptions:24)
	calr HDAE5000_TypeSel_BuildMask
	ld xhl, 0:i3
	jr t, .LDUO__hJ_exit
.LDUO__hJ_default:
	ld xhl, 0:i3
.LDUO__hJ_exit:
	pop xiz
	ret

