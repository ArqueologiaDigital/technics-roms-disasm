; ---------------------------------------------------------------------------
; Draw the load-by-number entry into HDAE5000_RAM_LbnEntryText: the typed
; digits, the directory name and the song name, according to the digit
; position (switch HDAE5000_Lbn_ShowEntry_CaseTable, cases NoDigitTyped,
; DirHundredsTyped .. SongUnitsTyped, Reset), and the song's part list
; (HDAE5000_PartList_Build); then the objects are told through
; RootFn_SendEvent / _ApPostEvent.
; In:  WA = directory number, BC = song number, DE = digit position 0..6
; ---------------------------------------------------------------------------
HDAE5000_Lbn_ShowEntry:
	lda	xsp, (xsp-36)
	pushw iz
	ld (xsp + 0x24), bc
	ld	iz, wa
	ldw (xsp + 0x02), 0
	ld	wa, de
	cp	wa, 6:i3
	jrl	ugt, HDAE5000_Lbn_ShowEntry_Join
	add	wa, wa
	lda xix, (HDAE5000_Lbn_ShowEntry_CaseTable:24)
	ld	wa, (xix+wa)
	lda xix, (HDAE5000_Lbn_ShowEntry_NoDigitTyped:24)
	jp	t, (xix+wa)
; HDAE5000_Lbn_ShowEntry_NoDigitTyped: blank the directory number, directory name, song number and song name fields
HDAE5000_Lbn_ShowEntry_NoDigitTyped:
	pushw 0x0005
	lda xwa, (HDAE5000_Str_Blank3Tab:24)
	push xwa
	lda xwa, (HDAE5000_RAM_LbnEntryText:24)
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
	jrl	t, HDAE5000_Lbn_ShowEntry_Join
; HDAE5000_Lbn_ShowEntry_DirHundredsTyped: show the directory number's first digit (dir/100, %1.1d)
HDAE5000_Lbn_ShowEntry_DirHundredsTyped:
	ld	wa, iz
	extz xwa
	div wa, 0x0064
	pushw wa
	pushw HDAE5000_Fmt_1_1d@hi16
	pushw	HDAE5000_Fmt_1_1d@lo16		; low half of HDAE5000_Fmt_1_1d
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (HDAE5000_RAM_LbnEntryText:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	jrl	t, HDAE5000_Lbn_ShowEntry_Join
; HDAE5000_Lbn_ShowEntry_DirTensTyped: show the directory number's first two digits (dir/10, %2.2d)
HDAE5000_Lbn_ShowEntry_DirTensTyped:
	ld	wa, iz
	extz xwa
	div wa, 0x000a
	pushw wa
	pushw HDAE5000_Fmt_2_2d_Lbn_ShowEntry@hi16
	pushw	HDAE5000_Fmt_2_2d_Lbn_ShowEntry@lo16		; low half of HDAE5000_Fmt_2_2d_Lbn_ShowEntry
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (HDAE5000_RAM_LbnEntryText:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	jrl	t, HDAE5000_Lbn_ShowEntry_Join
; HDAE5000_Lbn_ShowEntry_DirUnitsTyped: show the 3-digit directory number and, for 1..120, the directory name;
;   otherwise return -1
HDAE5000_Lbn_ShowEntry_DirUnitsTyped:
	pushw iz
	pushw HDAE5000_Fmt_3_3d_Lbn_ShowEntry@hi16
	pushw	HDAE5000_Fmt_3_3d_Lbn_ShowEntry@lo16		; low half of HDAE5000_Fmt_3_3d_Lbn_ShowEntry
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (HDAE5000_RAM_LbnEntryText:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	cp	iz, 0:i3
	jr	z, HDAE5000_Lbn_ShowEntry_DirUnitsTyped_Skip
	cp	iz, 0x0078
	jr	ugt, HDAE5000_Lbn_ShowEntry_DirUnitsTyped_Skip
	pushw 0x0010
	ld	wa, iz
	dec	1, wa
	call HDAE5000_DirName_Address
	push xhl
	lda xwa, (0x22aa68:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	jrl	t, HDAE5000_Lbn_ShowEntry_Join
HDAE5000_Lbn_ShowEntry_DirUnitsTyped_Skip:
	ldw (xsp + 0x02), 65535
	jrl	t, HDAE5000_Lbn_ShowEntry_Join
; HDAE5000_Lbn_ShowEntry_SongTensTyped: show the song number's first digit (song/10, " %1.1d")
HDAE5000_Lbn_ShowEntry_SongTensTyped:
	ld	wa, (xsp+36)
	extz xwa
	div wa, 0x000a
	pushw wa
	pushw HDAE5000_Fmt_1_1d_Lbn_ShowEntry@hi16
	pushw	HDAE5000_Fmt_1_1d_Lbn_ShowEntry@lo16		; low half of HDAE5000_Fmt_1_1d_Lbn_ShowEntry
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (0x22aa7a:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	jrl	t, HDAE5000_Lbn_ShowEntry_Join
; HDAE5000_Lbn_ShowEntry_SongUnitsTyped: show the 2-digit song number and, for directory 1..120 and song 1..16, the
;   song name; otherwise return -2 (bad song) or -1
HDAE5000_Lbn_ShowEntry_SongUnitsTyped:
	pushm	(xsp+36)
	pushw HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2@hi16
	pushw	HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2@lo16		; low half of HDAE5000_Fmt_2_2d_Lbn_ShowEntry_2
	lda	xwa, (xsp+10)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+14)
	push xwa
	call HDAE5000_StrLen
	pushw hl
	lda	xwa, (xsp+20)
	push xwa
	lda xwa, (0x22aa7a:24)
	push xwa
	call HDAE5000_MemCopy
	lda	xsp, (xsp+24)
	cp	iz, 0:i3
	jr	z, HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip2
	cp	iz, 0x0078
	jr	ugt, HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip2
	cpw	(xsp+36), 0x0000
	jr	z, HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip
	cpw	(xsp+36), 0x0010
	jr	ugt, HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip
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
	jrl	t, HDAE5000_Lbn_ShowEntry_Join
HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip:
	ldw (xsp + 0x02), 65534
	jr	t, HDAE5000_Lbn_ShowEntry_Join
HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip2:
	ldw (xsp + 0x02), 65535
	jr	t, HDAE5000_Lbn_ShowEntry_Join
; HDAE5000_Lbn_ShowEntry_Reset: blank the fields, zero LbnDir/LbnSong/LbnDigitPos and rebuild LBN_OPTION with no song
HDAE5000_Lbn_ShowEntry_Reset:
	pushw 0x0005
	lda xwa, (HDAE5000_Str_Blank3Tab:24)
	push xwa
	lda xwa, (HDAE5000_RAM_LbnEntryText:24)
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
	jrl	nz, HDAE5000_Lbn_ShowEntry_Reset_Skip
	lda xwa, (HDAE5000_RAM_LbnEntryText:24)
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
	jrl	t, HDAE5000_Lbn_ShowEntry_Reset_Done
HDAE5000_Lbn_ShowEntry_Reset_Skip:
	lda xwa, (HDAE5000_RAM_LbnEntryText:24)
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
	popw iz
	lda	xsp, (xsp+36)
	retd 0x0002

HDAE5000_FileLBNNameCheck:	.include "includes/generated/cc900/HDAE5000_FileLBNNameCheck.s"	; C: cc900/hdae5000_name_checks_filesystem.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FileLBNNameCheck_Ev01E00047, HDAE5000_FileLBNNameCheck + 59
	.set	HDAE5000_FileLBNNameCheck_Ev01E00047_Skip, HDAE5000_FileLBNNameCheck + 104
	.set	HDAE5000_FileLBNNameCheck_Ev01E00047_Join, HDAE5000_FileLBNNameCheck + 120
	.set	HDAE5000_FileLBNNameCheck_Ev01E0003E, HDAE5000_FileLBNNameCheck + 125
	.set	HDAE5000_FileLBNNameCheck_Ev01E0003F, HDAE5000_FileLBNNameCheck + 129
	.set	HDAE5000_FileLBNNameCheck_Ev01E00043, HDAE5000_FileLBNNameCheck + 133
	.set	HDAE5000_FileLBNNameCheck_Ev01E00044, HDAE5000_FileLBNNameCheck + 137
	.set	HDAE5000_FileLBNNameCheck_Ev01E00045, HDAE5000_FileLBNNameCheck + 141
	.set	HDAE5000_FileLBNNameCheck_Ev01E00046, HDAE5000_FileLBNNameCheck + 148
	.set	HDAE5000_FileLBNNameCheck_OnRamDataReq, HDAE5000_FileLBNNameCheck + 152
	.set	HDAE5000_FileLBNNameCheck_Default, HDAE5000_FileLBNNameCheck + 156
	.set	HDAE5000_FileLBNNameCheck_Epilogue, HDAE5000_FileLBNNameCheck + 158

HDAE5000_LBNLswBitCheck:	.include "includes/generated/cc900/HDAE5000_LBNLswBitCheck.s"	; C: cc900/hdae5000_lbn_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNLswBitCheck_Ev01E00047, HDAE5000_LBNLswBitCheck + 58
	.set	HDAE5000_LBNLswBitCheck_Ev01E00047_Skip, HDAE5000_LBNLswBitCheck + 102
	.set	HDAE5000_LBNLswBitCheck_Ev01E00047_Join, HDAE5000_LBNLswBitCheck + 118
	.set	HDAE5000_LBNLswBitCheck_Ev01E0003E, HDAE5000_LBNLswBitCheck + 123
	.set	HDAE5000_LBNLswBitCheck_Ev01E0003F, HDAE5000_LBNLswBitCheck + 128
	.set	HDAE5000_LBNLswBitCheck_Ev01E00043, HDAE5000_LBNLswBitCheck + 133
	.set	HDAE5000_LBNLswBitCheck_Ev01E00043_Skip, HDAE5000_LBNLswBitCheck + 156
	.set	HDAE5000_LBNLswBitCheck_Ev01E00043_Join, HDAE5000_LBNLswBitCheck + 158
	.set	HDAE5000_LBNLswBitCheck_Ev01E00044, HDAE5000_LBNLswBitCheck + 160
	.set	HDAE5000_LBNLswBitCheck_Ev01E00044_Skip, HDAE5000_LBNLswBitCheck + 183
	.set	HDAE5000_LBNLswBitCheck_Ev01E00044_Join, HDAE5000_LBNLswBitCheck + 185
	.set	HDAE5000_LBNLswBitCheck_Ev01E00045, HDAE5000_LBNLswBitCheck + 187
	.set	HDAE5000_LBNLswBitCheck_Ev01E00046, HDAE5000_LBNLswBitCheck + 194
	.set	HDAE5000_LBNLswBitCheck_OnRamDataReq, HDAE5000_LBNLswBitCheck + 198
	.set	HDAE5000_LBNLswBitCheck_Ev01E00046_Skip, HDAE5000_LBNLswBitCheck + 241
	.set	HDAE5000_LBNLswBitCheck_Ev01E00046_Join, HDAE5000_LBNLswBitCheck + 258
	.set	HDAE5000_LBNLswBitCheck_Default, HDAE5000_LBNLswBitCheck + 262
	.set	HDAE5000_LBNLswBitCheck_Epilogue, HDAE5000_LBNLswBitCheck + 264

HDAE5000_LBNPmtBitCheck:	.include "includes/generated/cc900/HDAE5000_LBNPmtBitCheck.s"	; C: cc900/hdae5000_lbn_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00047, HDAE5000_LBNPmtBitCheck + 58
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00047_Skip, HDAE5000_LBNPmtBitCheck + 102
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00047_Join, HDAE5000_LBNPmtBitCheck + 118
	.set	HDAE5000_LBNPmtBitCheck_Ev01E0003E, HDAE5000_LBNPmtBitCheck + 123
	.set	HDAE5000_LBNPmtBitCheck_Ev01E0003F, HDAE5000_LBNPmtBitCheck + 128
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00043, HDAE5000_LBNPmtBitCheck + 133
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00043_Skip, HDAE5000_LBNPmtBitCheck + 156
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00043_Join, HDAE5000_LBNPmtBitCheck + 158
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00044, HDAE5000_LBNPmtBitCheck + 160
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00044_Skip, HDAE5000_LBNPmtBitCheck + 183
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00044_Join, HDAE5000_LBNPmtBitCheck + 185
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00045, HDAE5000_LBNPmtBitCheck + 187
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00046, HDAE5000_LBNPmtBitCheck + 194
	.set	HDAE5000_LBNPmtBitCheck_OnRamDataReq, HDAE5000_LBNPmtBitCheck + 198
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00046_Skip, HDAE5000_LBNPmtBitCheck + 241
	.set	HDAE5000_LBNPmtBitCheck_Ev01E00046_Join, HDAE5000_LBNPmtBitCheck + 258
	.set	HDAE5000_LBNPmtBitCheck_Default, HDAE5000_LBNPmtBitCheck + 262
	.set	HDAE5000_LBNPmtBitCheck_Epilogue, HDAE5000_LBNPmtBitCheck + 264

HDAE5000_LBNSqtBitCheck:	.include "includes/generated/cc900/HDAE5000_LBNSqtBitCheck.s"	; C: cc900/hdae5000_lbn_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00047, HDAE5000_LBNSqtBitCheck + 58
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00047_Skip, HDAE5000_LBNSqtBitCheck + 102
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00047_Join, HDAE5000_LBNSqtBitCheck + 118
	.set	HDAE5000_LBNSqtBitCheck_Ev01E0003E, HDAE5000_LBNSqtBitCheck + 123
	.set	HDAE5000_LBNSqtBitCheck_Ev01E0003F, HDAE5000_LBNSqtBitCheck + 128
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00043, HDAE5000_LBNSqtBitCheck + 133
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00043_Skip, HDAE5000_LBNSqtBitCheck + 156
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00043_Join, HDAE5000_LBNSqtBitCheck + 158
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00044, HDAE5000_LBNSqtBitCheck + 160
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00044_Skip, HDAE5000_LBNSqtBitCheck + 183
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00044_Join, HDAE5000_LBNSqtBitCheck + 185
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00045, HDAE5000_LBNSqtBitCheck + 187
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00046, HDAE5000_LBNSqtBitCheck + 194
	.set	HDAE5000_LBNSqtBitCheck_OnRamDataReq, HDAE5000_LBNSqtBitCheck + 198
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00046_Skip, HDAE5000_LBNSqtBitCheck + 241
	.set	HDAE5000_LBNSqtBitCheck_Ev01E00046_Join, HDAE5000_LBNSqtBitCheck + 258
	.set	HDAE5000_LBNSqtBitCheck_Default, HDAE5000_LBNSqtBitCheck + 262
	.set	HDAE5000_LBNSqtBitCheck_Epilogue, HDAE5000_LBNSqtBitCheck + 264

HDAE5000_LBNCmpBitCheck:	.include "includes/generated/cc900/HDAE5000_LBNCmpBitCheck.s"	; C: cc900/hdae5000_lbn_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00047, HDAE5000_LBNCmpBitCheck + 58
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00047_Skip, HDAE5000_LBNCmpBitCheck + 102
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00047_Join, HDAE5000_LBNCmpBitCheck + 118
	.set	HDAE5000_LBNCmpBitCheck_Ev01E0003E, HDAE5000_LBNCmpBitCheck + 123
	.set	HDAE5000_LBNCmpBitCheck_Ev01E0003F, HDAE5000_LBNCmpBitCheck + 128
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00043, HDAE5000_LBNCmpBitCheck + 133
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00043_Skip, HDAE5000_LBNCmpBitCheck + 156
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00043_Join, HDAE5000_LBNCmpBitCheck + 158
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00044, HDAE5000_LBNCmpBitCheck + 160
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00044_Skip, HDAE5000_LBNCmpBitCheck + 183
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00044_Join, HDAE5000_LBNCmpBitCheck + 185
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00045, HDAE5000_LBNCmpBitCheck + 187
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00046, HDAE5000_LBNCmpBitCheck + 194
	.set	HDAE5000_LBNCmpBitCheck_OnRamDataReq, HDAE5000_LBNCmpBitCheck + 198
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00046_Skip, HDAE5000_LBNCmpBitCheck + 241
	.set	HDAE5000_LBNCmpBitCheck_Ev01E00046_Join, HDAE5000_LBNCmpBitCheck + 258
	.set	HDAE5000_LBNCmpBitCheck_Default, HDAE5000_LBNCmpBitCheck + 262
	.set	HDAE5000_LBNCmpBitCheck_Epilogue, HDAE5000_LBNCmpBitCheck + 264

HDAE5000_LBNTmBitCheck:	.include "includes/generated/cc900/HDAE5000_LBNTmBitCheck.s"	; C: cc900/hdae5000_lbntm_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNTmBitCheck_Ev01E00047, HDAE5000_LBNTmBitCheck + 58
	.set	HDAE5000_LBNTmBitCheck_Ev01E00047_Skip, HDAE5000_LBNTmBitCheck + 102
	.set	HDAE5000_LBNTmBitCheck_Ev01E00047_Join, HDAE5000_LBNTmBitCheck + 118
	.set	HDAE5000_LBNTmBitCheck_Ev01E0003E, HDAE5000_LBNTmBitCheck + 123
	.set	HDAE5000_LBNTmBitCheck_Ev01E0003F, HDAE5000_LBNTmBitCheck + 128
	.set	HDAE5000_LBNTmBitCheck_Ev01E00043, HDAE5000_LBNTmBitCheck + 133
	.set	HDAE5000_LBNTmBitCheck_Ev01E00043_Skip, HDAE5000_LBNTmBitCheck + 156
	.set	HDAE5000_LBNTmBitCheck_Ev01E00043_Join, HDAE5000_LBNTmBitCheck + 158
	.set	HDAE5000_LBNTmBitCheck_Ev01E00044, HDAE5000_LBNTmBitCheck + 160
	.set	HDAE5000_LBNTmBitCheck_Ev01E00044_Skip, HDAE5000_LBNTmBitCheck + 183
	.set	HDAE5000_LBNTmBitCheck_Ev01E00044_Join, HDAE5000_LBNTmBitCheck + 185
	.set	HDAE5000_LBNTmBitCheck_Ev01E00045, HDAE5000_LBNTmBitCheck + 187
	.set	HDAE5000_LBNTmBitCheck_Ev01E00046, HDAE5000_LBNTmBitCheck + 194
	.set	HDAE5000_LBNTmBitCheck_OnRamDataReq, HDAE5000_LBNTmBitCheck + 198
	.set	HDAE5000_LBNTmBitCheck_Ev01E00046_Skip, HDAE5000_LBNTmBitCheck + 241
	.set	HDAE5000_LBNTmBitCheck_Ev01E00046_Join, HDAE5000_LBNTmBitCheck + 258
	.set	HDAE5000_LBNTmBitCheck_Default, HDAE5000_LBNTmBitCheck + 262
	.set	HDAE5000_LBNTmBitCheck_Epilogue, HDAE5000_LBNTmBitCheck + 264

HDAE5000_LBNMspBitCheck:	.include "includes/generated/cc900/HDAE5000_LBNMspBitCheck.s"	; C: cc900/hdae5000_lbn_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNMspBitCheck_Ev01E00047, HDAE5000_LBNMspBitCheck + 58
	.set	HDAE5000_LBNMspBitCheck_Ev01E00047_Skip, HDAE5000_LBNMspBitCheck + 102
	.set	HDAE5000_LBNMspBitCheck_Ev01E00047_Join, HDAE5000_LBNMspBitCheck + 118
	.set	HDAE5000_LBNMspBitCheck_Ev01E0003E, HDAE5000_LBNMspBitCheck + 123
	.set	HDAE5000_LBNMspBitCheck_Ev01E0003F, HDAE5000_LBNMspBitCheck + 128
	.set	HDAE5000_LBNMspBitCheck_Ev01E00043, HDAE5000_LBNMspBitCheck + 133
	.set	HDAE5000_LBNMspBitCheck_Ev01E00043_Skip, HDAE5000_LBNMspBitCheck + 156
	.set	HDAE5000_LBNMspBitCheck_Ev01E00043_Join, HDAE5000_LBNMspBitCheck + 158
	.set	HDAE5000_LBNMspBitCheck_Ev01E00044, HDAE5000_LBNMspBitCheck + 160
	.set	HDAE5000_LBNMspBitCheck_Ev01E00044_Skip, HDAE5000_LBNMspBitCheck + 183
	.set	HDAE5000_LBNMspBitCheck_Ev01E00044_Join, HDAE5000_LBNMspBitCheck + 185
	.set	HDAE5000_LBNMspBitCheck_Ev01E00045, HDAE5000_LBNMspBitCheck + 187
	.set	HDAE5000_LBNMspBitCheck_Ev01E00046, HDAE5000_LBNMspBitCheck + 194
	.set	HDAE5000_LBNMspBitCheck_OnRamDataReq, HDAE5000_LBNMspBitCheck + 198
	.set	HDAE5000_LBNMspBitCheck_Ev01E00046_Skip, HDAE5000_LBNMspBitCheck + 241
	.set	HDAE5000_LBNMspBitCheck_Ev01E00046_Join, HDAE5000_LBNMspBitCheck + 258
	.set	HDAE5000_LBNMspBitCheck_Default, HDAE5000_LBNMspBitCheck + 262
	.set	HDAE5000_LBNMspBitCheck_Epilogue, HDAE5000_LBNMspBitCheck + 264

HDAE5000_LBNRcmBitCheck:	.include "includes/generated/cc900/HDAE5000_LBNRcmBitCheck.s"	; C: cc900/hdae5000_lbn_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00047, HDAE5000_LBNRcmBitCheck + 58
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00047_Skip, HDAE5000_LBNRcmBitCheck + 102
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00047_Join, HDAE5000_LBNRcmBitCheck + 118
	.set	HDAE5000_LBNRcmBitCheck_Ev01E0003E, HDAE5000_LBNRcmBitCheck + 123
	.set	HDAE5000_LBNRcmBitCheck_Ev01E0003F, HDAE5000_LBNRcmBitCheck + 128
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00043, HDAE5000_LBNRcmBitCheck + 133
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00043_Skip, HDAE5000_LBNRcmBitCheck + 156
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00043_Join, HDAE5000_LBNRcmBitCheck + 158
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00044, HDAE5000_LBNRcmBitCheck + 160
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00044_Skip, HDAE5000_LBNRcmBitCheck + 183
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00044_Join, HDAE5000_LBNRcmBitCheck + 185
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00045, HDAE5000_LBNRcmBitCheck + 187
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00046, HDAE5000_LBNRcmBitCheck + 194
	.set	HDAE5000_LBNRcmBitCheck_OnRamDataReq, HDAE5000_LBNRcmBitCheck + 198
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00046_Skip, HDAE5000_LBNRcmBitCheck + 241
	.set	HDAE5000_LBNRcmBitCheck_Ev01E00046_Join, HDAE5000_LBNRcmBitCheck + 258
	.set	HDAE5000_LBNRcmBitCheck_Default, HDAE5000_LBNRcmBitCheck + 262
	.set	HDAE5000_LBNRcmBitCheck_Epilogue, HDAE5000_LBNRcmBitCheck + 264

HDAE5000_LBNMdBitCheck:	.include "includes/generated/cc900/HDAE5000_LBNMdBitCheck.s"	; C: cc900/hdae5000_lbn_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNMdBitCheck_Ev01E00047, HDAE5000_LBNMdBitCheck + 58
	.set	HDAE5000_LBNMdBitCheck_Ev01E00047_Skip, HDAE5000_LBNMdBitCheck + 102
	.set	HDAE5000_LBNMdBitCheck_Ev01E00047_Join, HDAE5000_LBNMdBitCheck + 118
	.set	HDAE5000_LBNMdBitCheck_Ev01E0003E, HDAE5000_LBNMdBitCheck + 123
	.set	HDAE5000_LBNMdBitCheck_Ev01E0003F, HDAE5000_LBNMdBitCheck + 128
	.set	HDAE5000_LBNMdBitCheck_Ev01E00043, HDAE5000_LBNMdBitCheck + 133
	.set	HDAE5000_LBNMdBitCheck_Ev01E00043_Skip, HDAE5000_LBNMdBitCheck + 156
	.set	HDAE5000_LBNMdBitCheck_Ev01E00043_Join, HDAE5000_LBNMdBitCheck + 158
	.set	HDAE5000_LBNMdBitCheck_Ev01E00044, HDAE5000_LBNMdBitCheck + 160
	.set	HDAE5000_LBNMdBitCheck_Ev01E00044_Skip, HDAE5000_LBNMdBitCheck + 183
	.set	HDAE5000_LBNMdBitCheck_Ev01E00044_Join, HDAE5000_LBNMdBitCheck + 185
	.set	HDAE5000_LBNMdBitCheck_Ev01E00045, HDAE5000_LBNMdBitCheck + 187
	.set	HDAE5000_LBNMdBitCheck_Ev01E00046, HDAE5000_LBNMdBitCheck + 194
	.set	HDAE5000_LBNMdBitCheck_OnRamDataReq, HDAE5000_LBNMdBitCheck + 198
	.set	HDAE5000_LBNMdBitCheck_Ev01E00046_Skip, HDAE5000_LBNMdBitCheck + 241
	.set	HDAE5000_LBNMdBitCheck_Ev01E00046_Join, HDAE5000_LBNMdBitCheck + 258
	.set	HDAE5000_LBNMdBitCheck_Default, HDAE5000_LBNMdBitCheck + 262
	.set	HDAE5000_LBNMdBitCheck_Epilogue, HDAE5000_LBNMdBitCheck + 264

HDAE5000_LBNTlxBitCheck_Unregistered:	.include "includes/generated/cc900/HDAE5000_LBNTlxBitCheck_Unregistered.s"	; C: cc900/hdae5000_lbn_bitcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047, HDAE5000_LBNTlxBitCheck_Unregistered + 58
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Skip, HDAE5000_LBNTlxBitCheck_Unregistered + 102
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Join, HDAE5000_LBNTlxBitCheck_Unregistered + 118
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E0003E, HDAE5000_LBNTlxBitCheck_Unregistered + 123
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E0003F, HDAE5000_LBNTlxBitCheck_Unregistered + 128
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043, HDAE5000_LBNTlxBitCheck_Unregistered + 133
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Skip, HDAE5000_LBNTlxBitCheck_Unregistered + 156
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Join, HDAE5000_LBNTlxBitCheck_Unregistered + 158
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044, HDAE5000_LBNTlxBitCheck_Unregistered + 160
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Skip, HDAE5000_LBNTlxBitCheck_Unregistered + 183
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Join, HDAE5000_LBNTlxBitCheck_Unregistered + 185
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00045, HDAE5000_LBNTlxBitCheck_Unregistered + 187
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046, HDAE5000_LBNTlxBitCheck_Unregistered + 194
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_OnRamDataReq, HDAE5000_LBNTlxBitCheck_Unregistered + 198
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Skip, HDAE5000_LBNTlxBitCheck_Unregistered + 241
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Join, HDAE5000_LBNTlxBitCheck_Unregistered + 258
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Default, HDAE5000_LBNTlxBitCheck_Unregistered + 262
	.set	HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue, HDAE5000_LBNTlxBitCheck_Unregistered + 264



; ---------------------------------------------------------------------------
; Build one page of the FLS list in HDAE5000_RAM_FlsListText: 24 rows of 21
; bytes, each "NNN:" (HDAE5000_RAM_FlsPageBase + row + 1, "%3d") and the FLS
; record's 16-byte name (HDAE5000_FlsRecord_Address); then RootFn_ApPostEvent
; posts EVT_HDAE_SET_STR_ADR (the text) and EVT_PARA_DRAW to the list object.
; The FLS counterpart of HDAE5000_DirList_BuildPage.
; In:  XWA = list object
; ---------------------------------------------------------------------------
HDAE5000_FlsList_BuildPage:
	lda	xsp, (xsp-22)
	pushw iz
	pushw 0x0781
	pushw 0x0000
	lda xwa, (HDAE5000_RAM_FlsListText:24)
	push xwa
	call HDAE5000_MemFill
	inc 8, xsp
	ld iz, 0:i3
	cp iz, 0x0018
	jrl nc, .LFS_RdFSB__loop_done
.LFS_RdFSB__loop:
	pushw 0x0015
	lda xwa, (HDAE5000_Str_Chr2020203A2020_FlsList_BuildPage:24); src = ROM template "   :                \t"
	push xwa
	ldw wa, 0x0015
	mul xwa, iz
	ld xbc, HDAE5000_RAM_FlsListText
	add xbc, xwa
	push xbc
	call HDAE5000_MemCopy
	ld wa, (HDAE5000_RAM_FlsPageBase:24)
	add wa, iz
	inc 1, wa
	pushw wa
	pushw HDAE5000_Fmt_3_3d_FlsList_BuildPage@hi16
	pushw	HDAE5000_Fmt_3_3d_FlsList_BuildPage@lo16		; low half of HDAE5000_Fmt_3_3d_FlsList_BuildPage
	lda xwa, (xsp + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda xwa, (xsp + 0x16)
	push xwa
	call HDAE5000_StrLen
	lda xsp, (xsp + 0x18)
	pushw hl
	lda xwa, (xsp + 0x04)
	push xwa
	ldw wa, 0x0015
	mul xwa, iz
	ld xbc, HDAE5000_RAM_FlsListText
	add xbc, xwa
	push xbc
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)
	ld wa, (HDAE5000_RAM_FlsPageBase:24)
	add wa, iz
	call HDAE5000_FlsRecord_Address
	pushw 0x0010
	push xhl
	ldw wa, 0x0015
	mul xwa, iz
	inc 4, wa
	extz xwa
	ld xbc, HDAE5000_RAM_FlsListText
	add xbc, xwa
	push xbc
	call HDAE5000_MemCopy
	lda xsp, (xsp + 0x0a)
	inc 1, iz
	cp iz, 0x0018
	jrl c, .LFS_RdFSB__loop
.LFS_RdFSB__loop_done:
	; --- post two events to the list object SEL_FLS ---
	; (workspace + 0x0E0A = WS_RootFnTable, the main CPU's function table
	; 0x100; the offsets are the firmware's own function names:
	; +0x0124 ApPostEvent, +0x050C GetNamingWindowID, +0x0100 SendEvent --
	; scripts/converters/hdae5000_symbolize_fn_tables.py)
	lda xwa, (HDAE5000_RAM_FlsListText:24)
	ld xde, xwa
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_SEL_FLS
	ld xbc, EVT_HDAE_SET_STR_ADR
	call (xhl)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_ApPostEvent)
	ld xwa, HDAE5000_OBJ_SEL_FLS
	ld xbc, EVT_PARA_DRAW
	ld xde, 0xffffffff
	call (xhl)
	popw iz
	lda xsp, (xsp + 0x16)
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
HDAE5000_FlsNamingCheck:	.include "includes/generated/cc900/HDAE5000_FlsNamingCheck.s"	; C: cc900/hdae5000_fs_naming.c
	;
	; Part 3: Event handler B — right pane of file browser (0x288169)
	; Same event handling as handler A, but operates on the right display column.
	; Key differences: uses tile ID 0x0163 (right pane), and sub-code 0x0B
	; calls FS_Write_FSB instead of FS_Read_FSB (save operation).
HDAE5000_FlsNamingCheck2:	.include "includes/generated/cc900/HDAE5000_FlsNamingCheck2.s"	; C: cc900/hdae5000_fs_naming.c

; ---------------------------------------------------------------------------
; Refresh the FLS screen: title "... NN:" with the name of FLS
; HDAE5000_RAM_CurFls, then its items (HDAE5000_FlsItem_Get: each item's
; directory / song and their names) and the part list of the selected item
; (HDAE5000_PartList_Build), all sent with RootFn_SendEvent.  The FLS
; counterpart of HDAE5000_SongScreen_Refresh.
; In:  A = variant, C = 0 or 2 to redraw the title as well
; ---------------------------------------------------------------------------
HDAE5000_FlsScreen_Refresh:
	lda	xsp, (xsp-32)
	pushw iz
	ld	(xsp+30), c
	ld	(xsp+32), a
	cp	(xsp+30), 0x00
	jr	z, HDAE5000_FlsScreen_Refresh_Join
	cp	(xsp+30), 0x02
	jrl	nz, HDAE5000_FlsScreen_Refresh_Join2
HDAE5000_FlsScreen_Refresh_Join:
	pushw 0x0020
	pushw 0x0000
	lda xwa, (0x22a058:24)
	push xwa
	call HDAE5000_MemFill
	pushw	HDAE5000_Str_FLSNAME@hi16
	pushw	HDAE5000_Str_FLSNAME@lo16		; low half of HDAE5000_Str_FLSNAME
	pushw 0x0022
	pushw 0xa058
	call HDAE5000_StrCat
	ld	wa, (HDAE5000_RAM_CurFls:24)
	inc	1, wa
	pushw wa
	pushw HDAE5000_Fmt_2_2d_FlsScreen_Refresh@hi16
	pushw	HDAE5000_Fmt_2_2d_FlsScreen_Refresh@lo16		; low half of HDAE5000_Fmt_2_2d_FlsScreen_Refresh
	lda	xwa, (xsp+30)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+26)
	lda	xwa, (xsp+8)
	push xwa
	pushw 0x0022
	pushw 0xa058
	call HDAE5000_StrCat
	pushw	HDAE5000_Str_Chr3A_FlsScreen_Refresh@hi16
	pushw	HDAE5000_Str_Chr3A_FlsScreen_Refresh@lo16		; low half of HDAE5000_Str_Chr3A_FlsScreen_Refresh
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
	pushw	HDAE5000_Str_Blank0Tab_FlsScreen_Refresh@hi16
	pushw	HDAE5000_Str_Blank0Tab_FlsScreen_Refresh@lo16		; low half of HDAE5000_Str_Blank0Tab_FlsScreen_Refresh
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
	jr	z, HDAE5000_FlsScreen_Refresh_Join3
	cp	(xsp+30), 0x02
	jrl	nz, HDAE5000_FlsScreen_Refresh_Join6
HDAE5000_FlsScreen_Refresh_Join3:
	ld	iz, 0:i3
	cp	iz, 0x0010
	jrl	nc, HDAE5000_FlsScreen_Refresh_Join5
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
	ld	wa, (HDAE5000_RAM_FlsItemPageBase:24)
	add	wa, iz
	inc	1, wa
	pushw wa
	pushw HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2@hi16
	pushw	HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2@lo16		; low half of HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2
	lda	xwa, (xsp+24)
	push xwa
	call HDAE5000_SPrintf
	lda	xwa, (xsp+28)
	push xwa
	call HDAE5000_StrLen
	lda	xsp, (xsp+24)
	pushw hl
	lda	xwa, (xsp+10)
	push xwa
	ldw	wa, 0x0025
	mul	xwa, iz
	ld	xbc, 0x0022b020
	add	xbc, xwa
	push xbc
	call HDAE5000_MemCopy
	lda	xsp, (xsp+10)
	ld	bc, (HDAE5000_RAM_FlsItemPageBase:24)
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
	ld	bc, (HDAE5000_RAM_FlsItemPageBase:24)
	add	bc, iz
	lda	xwa, (xsp+2)
	ld	xde, xwa
	ld	wa, (HDAE5000_RAM_CurFls:24)
	call HDAE5000_FlsItem_Get
	cp	hl, 0xffff
	jr	z, HDAE5000_FlsScreen_Refresh_Next
	cp	(xsp+6), 0x01
	jr	nz, HDAE5000_FlsScreen_Refresh_Join4
	ldw	wa, 0x0025
	mul	xwa, iz
	add	wa, 0x0020
	extz xwa
	ld	xbc, 0x0022b020
	add	xbc, xwa
	ld	(xbc), 0x2a
HDAE5000_FlsScreen_Refresh_Join4:
	cp	(xsp+7), 0x01
	jr	nz, HDAE5000_FlsScreen_Refresh_Next
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
	jrl	c, HDAE5000_FlsScreen_Refresh_Loop
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
	inc 8, xsp
	lda	xwa, (xsp+2)
	ld	xde, xwa
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (HDAE5000_RAM_CurFlsItem:24)
	call HDAE5000_FlsItem_Get
	ld	iz, hl
	ld	wa, iz
	cp	wa, 0xffff
	jr	z, HDAE5000_FlsScreen_Refresh_Skip
	ld	wa, (xsp+4)
	inc	1, wa
	pushw wa
	ld	wa, (xsp+4)
	inc	1, wa
	pushw wa
	pushw HDAE5000_Fmt_LOC_3_3d_2_2d@hi16
	pushw	HDAE5000_Fmt_LOC_3_3d_2_2d@lo16		; low half of HDAE5000_Fmt_LOC_3_3d_2_2d
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr	t, HDAE5000_FlsScreen_Refresh_Join7
HDAE5000_FlsScreen_Refresh_Skip:
	pushw HDAE5000_Str_LOC00000@hi16
	pushw	HDAE5000_Str_LOC00000@lo16		; low half of HDAE5000_Str_LOC00000
	lda	xwa, (xsp+12)
	push xwa
	call HDAE5000_SPrintf
	inc 8, xsp
HDAE5000_FlsScreen_Refresh_Join7:
	lda	xwa, (xsp+8)
	push xwa
	call HDAE5000_StrLen
	pushw hl
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
	jr	z, HDAE5000_FlsScreen_Refresh_Skip2
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
	pushw iz
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_FlsScreen_Refresh_Join8
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
	jr	z, HDAE5000_FlsScreen_Refresh_Epilogue
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
	popw iz
	lda	xsp, (xsp+32)
	ret

HDAE5000_SelectFlsScreen:	.include "includes/generated/cc900/HDAE5000_SelectFlsScreen.s"	; C: cc900/hdae5000_fs_screens2.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_SelectFlsScreen_Skip, HDAE5000_SelectFlsScreen + 136
	.set	HDAE5000_SelectFlsScreen_Skip2, HDAE5000_SelectFlsScreen + 149
	.set	HDAE5000_SelectFlsScreen_Skip3, HDAE5000_SelectFlsScreen + 162
	.set	HDAE5000_SelectFlsScreen_Skip4, HDAE5000_SelectFlsScreen + 175
	.set	HDAE5000_SelectFlsScreen_Skip5, HDAE5000_SelectFlsScreen + 188
	.set	HDAE5000_SelectFlsScreen_OnHdaeSelectSave, HDAE5000_SelectFlsScreen + 241
	.set	HDAE5000_SelectFlsScreen_OnHdaeUnderFlow, HDAE5000_SelectFlsScreen + 321
	.set	HDAE5000_SelectFlsScreen_OnHdaeOverFlow, HDAE5000_SelectFlsScreen + 379
	.set	HDAE5000_SelectFlsScreen_Done, HDAE5000_SelectFlsScreen + 435

HDAE5000_FlsLoadScreen:	.include "includes/generated/cc900/HDAE5000_FlsLoadScreen.s"	; C: cc900/hdae5000_fs_screens2.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsLoadScreen_OnHdaeSeqStop, HDAE5000_FlsLoadScreen + 116
	.set	HDAE5000_FlsLoadScreen_OnHdaeAfterLoad, HDAE5000_FlsLoadScreen + 157
	.set	HDAE5000_FlsLoadScreen_Join, HDAE5000_FlsLoadScreen + 199
	.set	HDAE5000_FlsLoadScreen_Join2, HDAE5000_FlsLoadScreen + 202
	.set	HDAE5000_FlsLoadScreen_Skip, HDAE5000_FlsLoadScreen + 250
	.set	HDAE5000_FlsLoadScreen_Join3, HDAE5000_FlsLoadScreen + 256
	.set	HDAE5000_FlsLoadScreen_Join4, HDAE5000_FlsLoadScreen + 344
	.set	HDAE5000_FlsLoadScreen_Skip2, HDAE5000_FlsLoadScreen + 381
	.set	HDAE5000_FlsLoadScreen_OnHdaeSelectOk, HDAE5000_FlsLoadScreen + 390
	.set	HDAE5000_FlsLoadScreen_Skip3, HDAE5000_FlsLoadScreen + 464
	.set	HDAE5000_FlsLoadScreen_Join5, HDAE5000_FlsLoadScreen + 470
	.set	HDAE5000_FlsLoadScreen_Join6, HDAE5000_FlsLoadScreen + 558
	.set	HDAE5000_FlsLoadScreen_OnHdaeSelectSave, HDAE5000_FlsLoadScreen + 595
	.set	HDAE5000_FlsLoadScreen_Skip4, HDAE5000_FlsLoadScreen + 663
	.set	HDAE5000_FlsLoadScreen_OnHdaeUnderFlow, HDAE5000_FlsLoadScreen + 733
	.set	HDAE5000_FlsLoadScreen_Skip5, HDAE5000_FlsLoadScreen + 811
	.set	HDAE5000_FlsLoadScreen_OnHdaeOverFlow, HDAE5000_FlsLoadScreen + 865
	.set	HDAE5000_FlsLoadScreen_Skip6, HDAE5000_FlsLoadScreen + 942
	.set	HDAE5000_FlsLoadScreen_OnHdaeChangeSelNum, HDAE5000_FlsLoadScreen + 995
	.set	HDAE5000_FlsLoadScreen_Done, HDAE5000_FlsLoadScreen + 1016

HDAE5000_FlsFileLoadSwCatch:	.include "includes/generated/cc900/HDAE5000_FlsFileLoadSwCatch.s"	; C: cc900/hdae5000_fs_screens3.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsFileLoadSwCatch_OnDraw, HDAE5000_FlsFileLoadSwCatch + 43
	.set	HDAE5000_FlsFileLoadSwCatch_OnSwIn, HDAE5000_FlsFileLoadSwCatch + 106
	.set	HDAE5000_FlsFileLoadSwCatch_Join, HDAE5000_FlsFileLoadSwCatch + 152
	.set	HDAE5000_FlsFileLoadSwCatch_Join2, HDAE5000_FlsFileLoadSwCatch + 177
	.set	HDAE5000_FlsFileLoadSwCatch_Epilogue, HDAE5000_FlsFileLoadSwCatch + 202

HDAE5000_FlsEditScreen:	.include "includes/generated/cc900/HDAE5000_FlsEditScreen.s"	; C: cc900/hdae5000_fs_screens2.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsEditScreen_OnSwIn, HDAE5000_FlsEditScreen + 97
	.set	HDAE5000_FlsEditScreen_Skip, HDAE5000_FlsEditScreen + 196
	.set	HDAE5000_FlsEditScreen_Skip2, HDAE5000_FlsEditScreen + 228
	.set	HDAE5000_FlsEditScreen_Skip3, HDAE5000_FlsEditScreen + 252
	.set	HDAE5000_FlsEditScreen_Skip4, HDAE5000_FlsEditScreen + 275
	.set	HDAE5000_FlsEditScreen_Join, HDAE5000_FlsEditScreen + 291
	.set	HDAE5000_FlsEditScreen_Skip5, HDAE5000_FlsEditScreen + 301
	.set	HDAE5000_FlsEditScreen_Skip6, HDAE5000_FlsEditScreen + 324
	.set	HDAE5000_FlsEditScreen_Join2, HDAE5000_FlsEditScreen + 340
	.set	HDAE5000_FlsEditScreen_OnHdaeSelectOk, HDAE5000_FlsEditScreen + 350
	.set	HDAE5000_FlsEditScreen_OnHdaeSelectSave, HDAE5000_FlsEditScreen + 390
	.set	HDAE5000_FlsEditScreen_Skip7, HDAE5000_FlsEditScreen + 486
	.set	HDAE5000_FlsEditScreen_OnHdaeUnderFlow, HDAE5000_FlsEditScreen + 619
	.set	HDAE5000_FlsEditScreen_OnHdaeOverFlow, HDAE5000_FlsEditScreen + 682
	.set	HDAE5000_FlsEditScreen_OnHdaeChangeSelNum, HDAE5000_FlsEditScreen + 744
	.set	HDAE5000_FlsEditScreen_Done, HDAE5000_FlsEditScreen + 763

HDAE5000_FlsDel1SwCatch:	.include "includes/generated/cc900/HDAE5000_FlsDel1SwCatch.s"	; C: cc900/hdae5000_fs_screens3.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsDel1SwCatch_OnAreYouClassProc, HDAE5000_FlsDel1SwCatch + 51
	.set	HDAE5000_FlsDel1SwCatch_OnDraw, HDAE5000_FlsDel1SwCatch + 56
	.set	HDAE5000_FlsDel1SwCatch_OnSwIn, HDAE5000_FlsDel1SwCatch + 113
	.set	HDAE5000_FlsDel1SwCatch_Join, HDAE5000_FlsDel1SwCatch + 168
	.set	HDAE5000_FlsDel1SwCatch_Skip, HDAE5000_FlsDel1SwCatch + 220
	.set	HDAE5000_FlsDel1SwCatch_Done, HDAE5000_FlsDel1SwCatch + 249
	.set	HDAE5000_FlsDel1SwCatch_Epilogue, HDAE5000_FlsDel1SwCatch + 251

HDAE5000_FlsDel2SwCatch:	.include "includes/generated/cc900/HDAE5000_FlsDel2SwCatch.s"	; C: cc900/hdae5000_fs_screens3.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsDel2SwCatch_OnAreYouClassProc, HDAE5000_FlsDel2SwCatch + 51
	.set	HDAE5000_FlsDel2SwCatch_OnDraw, HDAE5000_FlsDel2SwCatch + 56
	.set	HDAE5000_FlsDel2SwCatch_OnSwIn, HDAE5000_FlsDel2SwCatch + 113
	.set	HDAE5000_FlsDel2SwCatch_Join, HDAE5000_FlsDel2SwCatch + 168
	.set	HDAE5000_FlsDel2SwCatch_Skip, HDAE5000_FlsDel2SwCatch + 220
	.set	HDAE5000_FlsDel2SwCatch_Done, HDAE5000_FlsDel2SwCatch + 249
	.set	HDAE5000_FlsDel2SwCatch_Epilogue, HDAE5000_FlsDel2SwCatch + 251

HDAE5000_FlsDirSelScreen:	.include "includes/generated/cc900/HDAE5000_FlsDirSelScreen.s"	; C: cc900/hdae5000_fs_screens.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsDirSelScreen_Skip, HDAE5000_FlsDirSelScreen + 123
	.set	HDAE5000_FlsDirSelScreen_Skip2, HDAE5000_FlsDirSelScreen + 141
	.set	HDAE5000_FlsDirSelScreen_Skip3, HDAE5000_FlsDirSelScreen + 159
	.set	HDAE5000_FlsDirSelScreen_Skip4, HDAE5000_FlsDirSelScreen + 177
	.set	HDAE5000_FlsDirSelScreen_OnHdaeSelectOk, HDAE5000_FlsDirSelScreen + 195
	.set	HDAE5000_FlsDirSelScreen_OnHdaeUnderFlow, HDAE5000_FlsDirSelScreen + 247
	.set	HDAE5000_FlsDirSelScreen_OnHdaeOverFlow, HDAE5000_FlsDirSelScreen + 310
	.set	HDAE5000_FlsDirSelScreen_Done, HDAE5000_FlsDirSelScreen + 371

HDAE5000_FlsFileSelScreen:	.include "includes/generated/cc900/HDAE5000_FlsFileSelScreen.s"	; C: cc900/hdae5000_fs_screens2.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsFileSelScreen_OnHdaeSelectOk, HDAE5000_FlsFileSelScreen + 79
	.set	HDAE5000_FlsFileSelScreen_Skip, HDAE5000_FlsFileSelScreen + 234
	.set	HDAE5000_FlsFileSelScreen_OnHdaeUnderFlow, HDAE5000_FlsFileSelScreen + 266
	.set	HDAE5000_FlsFileSelScreen_OnHdaeOverFlow, HDAE5000_FlsFileSelScreen + 328
	.set	HDAE5000_FlsFileSelScreen_OnHdaeChangeSelNum, HDAE5000_FlsFileSelScreen + 388
	.set	HDAE5000_FlsFileSelScreen_Skip2, HDAE5000_FlsFileSelScreen + 435
	.set	HDAE5000_FlsFileSelScreen_Join, HDAE5000_FlsFileSelScreen + 453
	.set	HDAE5000_FlsFileSelScreen_Done, HDAE5000_FlsFileSelScreen + 460

HDAE5000_FlsOverWrSwCatch:	.include "includes/generated/cc900/HDAE5000_FlsOverWrSwCatch.s"	; C: cc900/hdae5000_fs_screens2.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsOverWrSwCatch_OnAreYouClassProc, HDAE5000_FlsOverWrSwCatch + 51
	.set	HDAE5000_FlsOverWrSwCatch_OnDraw, HDAE5000_FlsOverWrSwCatch + 56
	.set	HDAE5000_FlsOverWrSwCatch_OnSwIn, HDAE5000_FlsOverWrSwCatch + 113
	.set	HDAE5000_FlsOverWrSwCatch_Join, HDAE5000_FlsOverWrSwCatch + 170
	.set	HDAE5000_FlsOverWrSwCatch_Skip, HDAE5000_FlsOverWrSwCatch + 278
	.set	HDAE5000_FlsOverWrSwCatch_Done, HDAE5000_FlsOverWrSwCatch + 307
	.set	HDAE5000_FlsOverWrSwCatch_Epilogue, HDAE5000_FlsOverWrSwCatch + 309


; ---------------------------------------------------------------------------
; Redisplay the floppy list HDAE5000_FdList_Scan built: the text of
; HDAE5000_RAM_FdList to object 0x7F00DE, and a "*" in front of each row whose
; selected flag (FdList+0x114) is set, a space otherwise.
; ---------------------------------------------------------------------------
HDAE5000_FdList_Redisplay:	.include "includes/generated/cc900/HDAE5000_FdList_Redisplay.s"	; C: cc900/hdae5000_showflags_fs.c

; --- Event handler sub-function ---
HDAE5000_CopyToHDScreen:	.include "includes/generated/cc900/HDAE5000_CopyToHDScreen.s"	; C: cc900/hdae5000_setup_copy_filesystem.c

; ---------------------------------------------------------------------------
; The copy-to-HD run of the copy screen: checks the floppy song
; (HDAE5000_FdSong_CheckFiles) and copies it into the chosen directory
; (HDAE5000_CopyFdSongToHd), with its status and error messages.
; Out: HL = 0
; ---------------------------------------------------------------------------
HDAE5000_CopyToHd_Execute:
	lda xsp, (xsp-300)	; lda XSP, XSP+0xFED4 (alloc ~300 bytes)
	push xiz
	ld	(xsp+300), de
	ld	(xsp+302), bc
	ld iz, 0:i3
.LFSD__loop:
	cp	iz, (xsp+302)
	jrl nc, .LFSD__loop_done
.LFSD__loop_body:
	ld wa, iz
	extz xwa
	add xwa, 0x00000114
	ld xbc, HDAE5000_RAM_FdList
	add xbc, xwa
	cp	(xbc), 0x01
	jrl nz, .LFSD__loop_next
	; Valid entry — format and display
	pushw 0x000d
	pushw 0x0000
	lda xwa, (xsp+290)
	push xwa
	call HDAE5000_MemFill			; MemFill
	ld wa, iz
	inc 1, wa
	pushw wa                                ; push wa (compact)
	pushw HDAE5000_Fmt_2_2d_CopyToHd_Execute@hi16
	pushw	HDAE5000_Fmt_2_2d_CopyToHd_Execute@lo16		; low half of HDAE5000_Fmt_2_2d_CopyToHd_Execute
	lda xwa, (xsp+300)
	push xwa
	call HDAE5000_SPrintf
	pushw 0x0006
	ld wa, iz
	mul wa, 0x000c
	inc 3, wa
	extz xwa
	add xwa, 0x0000000e
	ld xbc, HDAE5000_RAM_FdList
	add xbc, xwa
	push xbc
	lda xwa, (xsp+312)
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
	lda xwa, (xsp+288)
	push xwa
	lda xwa, (xsp+278)
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
	pushw	HDAE5000_Str_LSW@lo16		; low half of HDAE5000_Str_LSW
	lda xwa, (xsp+284)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
	lda xwa, (xsp + 0x06)
	ld xbc, xwa
	lda xwa, (xsp+272)
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
	pushw	HDAE5000_Str_PMT@lo16		; low half of HDAE5000_Str_PMT
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
	jr z, .LFSD__f2
	set	0x01, qiz
	ld xwa, xhl
	ld xbc, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xbc, (xbc + WS_HamaFnTable)
	ld_sril xhl, (xbc + HamaFn__findclose)
	call (xhl)
.LFSD__f2:				; Field 2 (0x2F36)
	pushw HDAE5000_Str_SQT@hi16
	pushw	HDAE5000_Str_SQT@lo16		; low half of HDAE5000_Str_SQT
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
	pushw	HDAE5000_Str_CMP@lo16		; low half of HDAE5000_Str_CMP
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
	pushw	HDAE5000_Str_TM@lo16		; low half of HDAE5000_Str_TM
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
	pushw	HDAE5000_Str_MSP@lo16		; low half of HDAE5000_Str_MSP
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
	pushw	HDAE5000_Str_RCM@lo16		; low half of HDAE5000_Str_RCM
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
	pushw	HDAE5000_Str_MD@lo16		; low half of HDAE5000_Str_MD
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
	pushw	HDAE5000_Str_TLX@lo16		; low half of HDAE5000_Str_TLX
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
	lda xwa, (xsp+286)
	ld	bc, qiz
	call HDAE5000_FdSong_CheckFiles
	cp hl, 0xffff
	jrl z, .LFSD__no_match
	; Match — attempt write
	ld bc, (xsp + 0x04)
	lda xwa, (xsp+286)
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
	cp	iz, (xsp+302)
	jrl c, .LFSD__loop_body
.LFSD__loop_done:
	ld hl, 0:i3
.LFSD__exit:
	pop xiz
	lda xsp, (xsp+300)	; lda XSP, XSP+0x012C (dealloc)
	ret
	;
	; Part 2: Event handler — navigation (0x289D72)
HDAE5000_CopyToHDDirSelScreen:	.include "includes/generated/cc900/HDAE5000_CopyToHDDirSelScreen.s"	; C: cc900/hdae5000_fs_screens.c
	;
	; Part 3: Event handler — file operations (0x28A07E)
HDAE5000_CP_FD_DIRNAMECheck:	.include "includes/generated/cc900/HDAE5000_CP_FD_DIRNAMECheck.s"	; C: cc900/hdae5000_fs_naming.c
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
	lda xwa, (HDAE5000_RAM_Name_ColumnRuler:24)
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
	pushw 0x9fd6
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

; ---------------------------------------------------------------------------
; Show the nine delete-option flags (HDAE5000_RAM_DeleteOptions+2..+10) as the
; texts of the pointer table HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL ("---",
; "OFF", "DEL") in objects HDAE5000_OBJ_DEL_EDIT_LSW.. (RootFn_PostEvent,
; EVT_PARA_DRAW).
; ---------------------------------------------------------------------------
HDAE5000_DelOpt_ShowFlags:	.include "includes/generated/cc900/HDAE5000_DelOpt_ShowFlags.s"	; C: cc900/hdae5000_showflags_fs.c
	;
	; Part 2: Event handler (0x28A497) — dispatches on event codes
HDAE5000_DelOptSwEventCatch:	.include "includes/generated/cc900/HDAE5000_DelOptSwEventCatch.s"	; C: cc900/hdae5000_fs_screens.c

; --- Display, Menu, and Utility Routines ---
HDAE5000_DelOpt_InitFromSong:	.include "includes/generated/cc900/HDAE5000_DelOpt_InitFromSong.s"	; C: cc900/hdae5000_small2_filesystem.c
	;
	; Part 2: Handler A (0x28A617) — event handler with stack frame
HDAE5000_DelOptNameCheck:	.include "includes/generated/cc900/HDAE5000_DelOptNameCheck.s"	; C: cc900/hdae5000_name_checks_filesystem.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelOptNameCheck_Ev01E00047, HDAE5000_DelOptNameCheck + 58
	.set	HDAE5000_DelOptNameCheck_Ev01E0003E, HDAE5000_DelOptNameCheck + 97
	.set	HDAE5000_DelOptNameCheck_Ev01E0003F, HDAE5000_DelOptNameCheck + 101
	.set	HDAE5000_DelOptNameCheck_Ev01E00043, HDAE5000_DelOptNameCheck + 105
	.set	HDAE5000_DelOptNameCheck_Ev01E00044, HDAE5000_DelOptNameCheck + 109
	.set	HDAE5000_DelOptNameCheck_Ev01E00045, HDAE5000_DelOptNameCheck + 113
	.set	HDAE5000_DelOptNameCheck_Ev01E00046, HDAE5000_DelOptNameCheck + 120
	;
	; Part 3: Handler B (0x28A69D) — digit callback for slot 0 (0x22ABE8)
HDAE5000_DelLswEditCheck:	.include "includes/generated/cc900/HDAE5000_DelLswEditCheck.s"	; C: cc900/hdae5000_del_editcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelLswEditCheck_Ev01E00047, HDAE5000_DelLswEditCheck + 55
	.set	HDAE5000_DelLswEditCheck_Ev01E0003E, HDAE5000_DelLswEditCheck + 92
	.set	HDAE5000_DelLswEditCheck_Ev01E0003F, HDAE5000_DelLswEditCheck + 96
	.set	HDAE5000_DelLswEditCheck_Ev01E00043, HDAE5000_DelLswEditCheck + 100
	.set	HDAE5000_DelLswEditCheck_Ev01E00044, HDAE5000_DelLswEditCheck + 114
	.set	HDAE5000_DelLswEditCheck_Ev01E00045, HDAE5000_DelLswEditCheck + 128
	.set	HDAE5000_DelLswEditCheck_Ev01E00046, HDAE5000_DelLswEditCheck + 135
	;
	; Part 4: Handler C (0x28A738) — slot 1 (0x22ABE9)
HDAE5000_DelPmtEditCheck:	.include "includes/generated/cc900/HDAE5000_DelPmtEditCheck.s"	; C: cc900/hdae5000_del_editcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelPmtEditCheck_Ev01E00047, HDAE5000_DelPmtEditCheck + 55
	.set	HDAE5000_DelPmtEditCheck_Ev01E0003E, HDAE5000_DelPmtEditCheck + 92
	.set	HDAE5000_DelPmtEditCheck_Ev01E0003F, HDAE5000_DelPmtEditCheck + 96
	.set	HDAE5000_DelPmtEditCheck_Ev01E00043, HDAE5000_DelPmtEditCheck + 100
	.set	HDAE5000_DelPmtEditCheck_Ev01E00044, HDAE5000_DelPmtEditCheck + 114
	.set	HDAE5000_DelPmtEditCheck_Ev01E00045, HDAE5000_DelPmtEditCheck + 128
	.set	HDAE5000_DelPmtEditCheck_Ev01E00046, HDAE5000_DelPmtEditCheck + 135
	;
	; Part 5: Handler D (0x28A7D3) — slot 2 (0x22ABEA)
HDAE5000_DelSqtEditCheck:	.include "includes/generated/cc900/HDAE5000_DelSqtEditCheck.s"	; C: cc900/hdae5000_del_editcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelSqtEditCheck_Ev01E00047, HDAE5000_DelSqtEditCheck + 55
	.set	HDAE5000_DelSqtEditCheck_Ev01E0003E, HDAE5000_DelSqtEditCheck + 92
	.set	HDAE5000_DelSqtEditCheck_Ev01E0003F, HDAE5000_DelSqtEditCheck + 96
	.set	HDAE5000_DelSqtEditCheck_Ev01E00043, HDAE5000_DelSqtEditCheck + 100
	.set	HDAE5000_DelSqtEditCheck_Ev01E00044, HDAE5000_DelSqtEditCheck + 114
	.set	HDAE5000_DelSqtEditCheck_Ev01E00045, HDAE5000_DelSqtEditCheck + 128
	.set	HDAE5000_DelSqtEditCheck_Ev01E00046, HDAE5000_DelSqtEditCheck + 135
	;
	; Part 6: Handler E (0x28A86E) — slot 3 (0x22ABEB)
HDAE5000_DelCmpEditCheck:	.include "includes/generated/cc900/HDAE5000_DelCmpEditCheck.s"	; C: cc900/hdae5000_del_editcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelCmpEditCheck_Ev01E00047, HDAE5000_DelCmpEditCheck + 55
	.set	HDAE5000_DelCmpEditCheck_Ev01E0003E, HDAE5000_DelCmpEditCheck + 92
	.set	HDAE5000_DelCmpEditCheck_Ev01E0003F, HDAE5000_DelCmpEditCheck + 96
	.set	HDAE5000_DelCmpEditCheck_Ev01E00043, HDAE5000_DelCmpEditCheck + 100
	.set	HDAE5000_DelCmpEditCheck_Ev01E00044, HDAE5000_DelCmpEditCheck + 114
	.set	HDAE5000_DelCmpEditCheck_Ev01E00045, HDAE5000_DelCmpEditCheck + 128
	.set	HDAE5000_DelCmpEditCheck_Ev01E00046, HDAE5000_DelCmpEditCheck + 135
	;
	; Part 7: Handler F (0x28A909) — slot 4 (0x22ABEC)
HDAE5000_DelTmEditCheck:	.include "includes/generated/cc900/HDAE5000_DelTmEditCheck.s"	; C: cc900/hdae5000_del_editcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelTmEditCheck_Ev01E00047, HDAE5000_DelTmEditCheck + 55
	.set	HDAE5000_DelTmEditCheck_Ev01E0003E, HDAE5000_DelTmEditCheck + 92
	.set	HDAE5000_DelTmEditCheck_Ev01E0003F, HDAE5000_DelTmEditCheck + 96
	.set	HDAE5000_DelTmEditCheck_Ev01E00043, HDAE5000_DelTmEditCheck + 100
	.set	HDAE5000_DelTmEditCheck_Ev01E00044, HDAE5000_DelTmEditCheck + 114
	.set	HDAE5000_DelTmEditCheck_Ev01E00045, HDAE5000_DelTmEditCheck + 128
	.set	HDAE5000_DelTmEditCheck_Ev01E00046, HDAE5000_DelTmEditCheck + 135
	;
	; Part 8: Handler G (0x28A9A4) — slot 5 (0x22ABED)
HDAE5000_DelMspEditCheck:	.include "includes/generated/cc900/HDAE5000_DelMspEditCheck.s"	; C: cc900/hdae5000_del_editcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelMspEditCheck_Ev01E00047, HDAE5000_DelMspEditCheck + 55
	.set	HDAE5000_DelMspEditCheck_Ev01E0003E, HDAE5000_DelMspEditCheck + 92
	.set	HDAE5000_DelMspEditCheck_Ev01E0003F, HDAE5000_DelMspEditCheck + 96
	.set	HDAE5000_DelMspEditCheck_Ev01E00043, HDAE5000_DelMspEditCheck + 100
	.set	HDAE5000_DelMspEditCheck_Ev01E00044, HDAE5000_DelMspEditCheck + 114
	.set	HDAE5000_DelMspEditCheck_Ev01E00045, HDAE5000_DelMspEditCheck + 128
	.set	HDAE5000_DelMspEditCheck_Ev01E00046, HDAE5000_DelMspEditCheck + 135
	;
	; Part 9: Handler H (0x28AA3F) — slot 6 (0x22ABEE)
HDAE5000_DelRcmEditCheck:	.include "includes/generated/cc900/HDAE5000_DelRcmEditCheck.s"	; C: cc900/hdae5000_del_editcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelRcmEditCheck_Ev01E00047, HDAE5000_DelRcmEditCheck + 55
	.set	HDAE5000_DelRcmEditCheck_Ev01E0003E, HDAE5000_DelRcmEditCheck + 92
	.set	HDAE5000_DelRcmEditCheck_Ev01E0003F, HDAE5000_DelRcmEditCheck + 96
	.set	HDAE5000_DelRcmEditCheck_Ev01E00043, HDAE5000_DelRcmEditCheck + 100
	.set	HDAE5000_DelRcmEditCheck_Ev01E00044, HDAE5000_DelRcmEditCheck + 114
	.set	HDAE5000_DelRcmEditCheck_Ev01E00045, HDAE5000_DelRcmEditCheck + 128
	.set	HDAE5000_DelRcmEditCheck_Ev01E00046, HDAE5000_DelRcmEditCheck + 135
	;
	; Part 10: Handler I (0x28AADA) — slot 7 (0x22ABEF)
HDAE5000_DelMdEditCheck:	.include "includes/generated/cc900/HDAE5000_DelMdEditCheck.s"	; C: cc900/hdae5000_del_editcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelMdEditCheck_Ev01E00047, HDAE5000_DelMdEditCheck + 55
	.set	HDAE5000_DelMdEditCheck_Ev01E0003E, HDAE5000_DelMdEditCheck + 92
	.set	HDAE5000_DelMdEditCheck_Ev01E0003F, HDAE5000_DelMdEditCheck + 96
	.set	HDAE5000_DelMdEditCheck_Ev01E00043, HDAE5000_DelMdEditCheck + 100
	.set	HDAE5000_DelMdEditCheck_Ev01E00044, HDAE5000_DelMdEditCheck + 114
	.set	HDAE5000_DelMdEditCheck_Ev01E00045, HDAE5000_DelMdEditCheck + 128
	.set	HDAE5000_DelMdEditCheck_Ev01E00046, HDAE5000_DelMdEditCheck + 135
	;
	; Part 11: Handler J (0x28AB75) — slot 8 (0x22ABF0), variant with jrl
HDAE5000_DelTlxEditCheck:	.include "includes/generated/cc900/HDAE5000_DelTlxEditCheck.s"	; C: cc900/hdae5000_deltlx_editcheck.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_DelTlxEditCheck_Ev01E00047, HDAE5000_DelTlxEditCheck + 58
	.set	HDAE5000_DelTlxEditCheck_Ev01E0003E, HDAE5000_DelTlxEditCheck + 95
	.set	HDAE5000_DelTlxEditCheck_Ev01E0003F, HDAE5000_DelTlxEditCheck + 99
	.set	HDAE5000_DelTlxEditCheck_Ev01E00043, HDAE5000_DelTlxEditCheck + 103
	.set	HDAE5000_DelTlxEditCheck_Ev01E00044, HDAE5000_DelTlxEditCheck + 117
	.set	HDAE5000_DelTlxEditCheck_Ev01E00045, HDAE5000_DelTlxEditCheck + 143
	.set	HDAE5000_DelTlxEditCheck_Ev01E00046, HDAE5000_DelTlxEditCheck + 150

