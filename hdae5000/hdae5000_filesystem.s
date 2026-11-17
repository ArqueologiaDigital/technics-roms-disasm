; ---------------------------------------------------------------------------
; Draw the load-by-number entry into HDAE5000_RAM_LbnEntryText: the typed
; digits, the directory name and the song name, according to the digit
; position (switch HDAE5000_Lbn_ShowEntry_CaseTable, cases NoDigitTyped,
; DirHundredsTyped .. SongUnitsTyped, Reset), and the song's part list
; (HDAE5000_PartList_Build); then the objects are told through
; RootFn_SendEvent / _ApPostEvent.
; In:  WA = directory number, BC = song number, DE = digit position 0..6
; ---------------------------------------------------------------------------
HDAE5000_Lbn_ShowEntry:	.include "includes/generated/cc900/HDAE5000_Lbn_ShowEntry.s"	; C: cc900/hdae5000_lbn_show.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_Lbn_ShowEntry_NoDigitTyped, HDAE5000_Lbn_ShowEntry + 43
	.set	HDAE5000_Lbn_ShowEntry_DirHundredsTyped, HDAE5000_Lbn_ShowEntry + 128
	.set	HDAE5000_Lbn_ShowEntry_DirTensTyped, HDAE5000_Lbn_ShowEntry + 180
	.set	HDAE5000_Lbn_ShowEntry_DirUnitsTyped, HDAE5000_Lbn_ShowEntry + 232
	.set	HDAE5000_Lbn_ShowEntry_DirUnitsTyped_Skip, HDAE5000_Lbn_ShowEntry + 311
	.set	HDAE5000_Lbn_ShowEntry_SongTensTyped, HDAE5000_Lbn_ShowEntry + 319
	.set	HDAE5000_Lbn_ShowEntry_SongUnitsTyped, HDAE5000_Lbn_ShowEntry + 372
	.set	HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip, HDAE5000_Lbn_ShowEntry + 472
	.set	HDAE5000_Lbn_ShowEntry_SongUnitsTyped_Skip2, HDAE5000_Lbn_ShowEntry + 479
	.set	HDAE5000_Lbn_ShowEntry_Reset, HDAE5000_Lbn_ShowEntry + 486
	.set	HDAE5000_Lbn_ShowEntry_Join, HDAE5000_Lbn_ShowEntry + 606
	.set	HDAE5000_Lbn_ShowEntry_Reset_Skip, HDAE5000_Lbn_ShowEntry + 881
	.set	HDAE5000_Lbn_ShowEntry_Reset_Done, HDAE5000_Lbn_ShowEntry + 1145

HDAE5000_FileLBNNameCheck:
	; registered as "FileLBNNameCheck" in HDAE5000_ObjHandler_Table
	dec	4, xsp
	push xiz
	ld (xsp + 0x04), xwa
	ld	xwa, xbc
	cp	xwa, EVT_RAM_DATA_REQ
	jrl	z, HDAE5000_FileLBNNameCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jr	lt, HDAE5000_FileLBNNameCheck_Default
	cp	xwa, 0x00000009
	jr	gt, HDAE5000_FileLBNNameCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_FileLBNNameCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_FileLBNNameCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_FileLBNNameCheck_Ev01E00047:
	ld	xiz, xde
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_FileLBNNameCheck_Ev01E00047_Skip
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
	jr	t, HDAE5000_FileLBNNameCheck_Ev01E00047_Join
HDAE5000_FileLBNNameCheck_Ev01E00047_Skip:
	pushw HDAE5000_Str_Blank26@hi16
	pushw HDAE5000_Str_Blank26@lo16		; low half of HDAE5000_Str_Blank26
	ld xwa, (xiz + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_FileLBNNameCheck_Ev01E00047_Join:
	ld xhl, (xsp + 0x04)
	jr	t, HDAE5000_FileLBNNameCheck_Epilogue
HDAE5000_FileLBNNameCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jr	t, HDAE5000_FileLBNNameCheck_Epilogue
HDAE5000_FileLBNNameCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jr	t, HDAE5000_FileLBNNameCheck_Epilogue
HDAE5000_FileLBNNameCheck_Ev01E00043:
	ld	xhl, 0:i3
	jr	t, HDAE5000_FileLBNNameCheck_Epilogue
HDAE5000_FileLBNNameCheck_Ev01E00044:
	ld	xhl, 0:i3
	jr	t, HDAE5000_FileLBNNameCheck_Epilogue
HDAE5000_FileLBNNameCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+11:24)
	jr	t, HDAE5000_FileLBNNameCheck_Epilogue
HDAE5000_FileLBNNameCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_FileLBNNameCheck_Epilogue
HDAE5000_FileLBNNameCheck_OnRamDataReq:
	ld	xhl, 0:i3
	jr	t, HDAE5000_FileLBNNameCheck_Epilogue
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
	jrl	z, HDAE5000_LBNLswBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LBNLswBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_LBNLswBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LBNLswBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNLswBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LBNLswBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNLswBitCheck_Ev01E00047_Skip
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
	jr	t, HDAE5000_LBNLswBitCheck_Ev01E00047_Join
HDAE5000_LBNLswBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_LBNLswBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl	t, HDAE5000_LBNLswBitCheck_Epilogue
HDAE5000_LBNLswBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNLswBitCheck_Epilogue
HDAE5000_LBNLswBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNLswBitCheck_Epilogue
HDAE5000_LBNLswBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNLswBitCheck_Ev01E00043_Skip
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+2:24), 0
	jr	nz, HDAE5000_LBNLswBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNLswBitCheck_Ev01E00043_Join
HDAE5000_LBNLswBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNLswBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_LBNLswBitCheck_Epilogue
HDAE5000_LBNLswBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNLswBitCheck_Ev01E00044_Skip
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+2:24), 0
	jr	nz, HDAE5000_LBNLswBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNLswBitCheck_Ev01E00044_Join
HDAE5000_LBNLswBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNLswBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_LBNLswBitCheck_Epilogue
HDAE5000_LBNLswBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+2:24)
	jr	t, HDAE5000_LBNLswBitCheck_Epilogue
HDAE5000_LBNLswBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LBNLswBitCheck_Epilogue
HDAE5000_LBNLswBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNLswBitCheck_Ev01E00046_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_LBNLswBitCheck_Ev01E00046_Join
HDAE5000_LBNLswBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNLswBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNLswBitCheck_Epilogue
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
	jrl	z, HDAE5000_LBNPmtBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LBNPmtBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_LBNPmtBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LBNPmtBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNPmtBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LBNPmtBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNPmtBitCheck_Ev01E00047_Skip
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
	jr	t, HDAE5000_LBNPmtBitCheck_Ev01E00047_Join
HDAE5000_LBNPmtBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_LBNPmtBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl	t, HDAE5000_LBNPmtBitCheck_Epilogue
HDAE5000_LBNPmtBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNPmtBitCheck_Epilogue
HDAE5000_LBNPmtBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNPmtBitCheck_Epilogue
HDAE5000_LBNPmtBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNPmtBitCheck_Ev01E00043_Skip
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+3:24), 0
	jr	nz, HDAE5000_LBNPmtBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNPmtBitCheck_Ev01E00043_Join
HDAE5000_LBNPmtBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNPmtBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_LBNPmtBitCheck_Epilogue
HDAE5000_LBNPmtBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNPmtBitCheck_Ev01E00044_Skip
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+3:24), 0
	jr	nz, HDAE5000_LBNPmtBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNPmtBitCheck_Ev01E00044_Join
HDAE5000_LBNPmtBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNPmtBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_LBNPmtBitCheck_Epilogue
HDAE5000_LBNPmtBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+3:24)
	jr	t, HDAE5000_LBNPmtBitCheck_Epilogue
HDAE5000_LBNPmtBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LBNPmtBitCheck_Epilogue
HDAE5000_LBNPmtBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNPmtBitCheck_Ev01E00046_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_LBNPmtBitCheck_Ev01E00046_Join
HDAE5000_LBNPmtBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNPmtBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNPmtBitCheck_Epilogue
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
	jrl	z, HDAE5000_LBNSqtBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LBNSqtBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_LBNSqtBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LBNSqtBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNSqtBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LBNSqtBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNSqtBitCheck_Ev01E00047_Skip
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
	jr	t, HDAE5000_LBNSqtBitCheck_Ev01E00047_Join
HDAE5000_LBNSqtBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_LBNSqtBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl	t, HDAE5000_LBNSqtBitCheck_Epilogue
HDAE5000_LBNSqtBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNSqtBitCheck_Epilogue
HDAE5000_LBNSqtBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNSqtBitCheck_Epilogue
HDAE5000_LBNSqtBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNSqtBitCheck_Ev01E00043_Skip
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+4:24), 0
	jr	nz, HDAE5000_LBNSqtBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNSqtBitCheck_Ev01E00043_Join
HDAE5000_LBNSqtBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNSqtBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_LBNSqtBitCheck_Epilogue
HDAE5000_LBNSqtBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNSqtBitCheck_Ev01E00044_Skip
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+4:24), 0
	jr	nz, HDAE5000_LBNSqtBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNSqtBitCheck_Ev01E00044_Join
HDAE5000_LBNSqtBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNSqtBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_LBNSqtBitCheck_Epilogue
HDAE5000_LBNSqtBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+4:24)
	jr	t, HDAE5000_LBNSqtBitCheck_Epilogue
HDAE5000_LBNSqtBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LBNSqtBitCheck_Epilogue
HDAE5000_LBNSqtBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNSqtBitCheck_Ev01E00046_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_LBNSqtBitCheck_Ev01E00046_Join
HDAE5000_LBNSqtBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNSqtBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNSqtBitCheck_Epilogue
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
	jrl	z, HDAE5000_LBNCmpBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LBNCmpBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_LBNCmpBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LBNCmpBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNCmpBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LBNCmpBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNCmpBitCheck_Ev01E00047_Skip
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
	jr	t, HDAE5000_LBNCmpBitCheck_Ev01E00047_Join
HDAE5000_LBNCmpBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_LBNCmpBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl	t, HDAE5000_LBNCmpBitCheck_Epilogue
HDAE5000_LBNCmpBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNCmpBitCheck_Epilogue
HDAE5000_LBNCmpBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNCmpBitCheck_Epilogue
HDAE5000_LBNCmpBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNCmpBitCheck_Ev01E00043_Skip
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+5:24), 0
	jr	nz, HDAE5000_LBNCmpBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNCmpBitCheck_Ev01E00043_Join
HDAE5000_LBNCmpBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNCmpBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_LBNCmpBitCheck_Epilogue
HDAE5000_LBNCmpBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNCmpBitCheck_Ev01E00044_Skip
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+5:24), 0
	jr	nz, HDAE5000_LBNCmpBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNCmpBitCheck_Ev01E00044_Join
HDAE5000_LBNCmpBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNCmpBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_LBNCmpBitCheck_Epilogue
HDAE5000_LBNCmpBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+5:24)
	jr	t, HDAE5000_LBNCmpBitCheck_Epilogue
HDAE5000_LBNCmpBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LBNCmpBitCheck_Epilogue
HDAE5000_LBNCmpBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNCmpBitCheck_Ev01E00046_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_LBNCmpBitCheck_Ev01E00046_Join
HDAE5000_LBNCmpBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNCmpBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNCmpBitCheck_Epilogue
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
	jrl	z, HDAE5000_LBNTmBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LBNTmBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_LBNTmBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LBNTmBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNTmBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LBNTmBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNTmBitCheck_Ev01E00047_Skip
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
	jr	t, HDAE5000_LBNTmBitCheck_Ev01E00047_Join
HDAE5000_LBNTmBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_LBNTmBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl	t, HDAE5000_LBNTmBitCheck_Epilogue
HDAE5000_LBNTmBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNTmBitCheck_Epilogue
HDAE5000_LBNTmBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNTmBitCheck_Epilogue
HDAE5000_LBNTmBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNTmBitCheck_Ev01E00043_Skip
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+6:24), 0
	jr	nz, HDAE5000_LBNTmBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNTmBitCheck_Ev01E00043_Join
HDAE5000_LBNTmBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNTmBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_LBNTmBitCheck_Epilogue
HDAE5000_LBNTmBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNTmBitCheck_Ev01E00044_Skip
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+6:24), 0
	jr	nz, HDAE5000_LBNTmBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNTmBitCheck_Ev01E00044_Join
HDAE5000_LBNTmBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNTmBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_LBNTmBitCheck_Epilogue
HDAE5000_LBNTmBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+6:24)
	jr	t, HDAE5000_LBNTmBitCheck_Epilogue
HDAE5000_LBNTmBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LBNTmBitCheck_Epilogue
HDAE5000_LBNTmBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNTmBitCheck_Ev01E00046_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_LBNTmBitCheck_Ev01E00046_Join
HDAE5000_LBNTmBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNTmBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNTmBitCheck_Epilogue
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
	jrl	z, HDAE5000_LBNMspBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LBNMspBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_LBNMspBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LBNMspBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNMspBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LBNMspBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNMspBitCheck_Ev01E00047_Skip
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
	jr	t, HDAE5000_LBNMspBitCheck_Ev01E00047_Join
HDAE5000_LBNMspBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_LBNMspBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl	t, HDAE5000_LBNMspBitCheck_Epilogue
HDAE5000_LBNMspBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNMspBitCheck_Epilogue
HDAE5000_LBNMspBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNMspBitCheck_Epilogue
HDAE5000_LBNMspBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNMspBitCheck_Ev01E00043_Skip
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+7:24), 0
	jr	nz, HDAE5000_LBNMspBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNMspBitCheck_Ev01E00043_Join
HDAE5000_LBNMspBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNMspBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_LBNMspBitCheck_Epilogue
HDAE5000_LBNMspBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNMspBitCheck_Ev01E00044_Skip
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+7:24), 0
	jr	nz, HDAE5000_LBNMspBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNMspBitCheck_Ev01E00044_Join
HDAE5000_LBNMspBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNMspBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_LBNMspBitCheck_Epilogue
HDAE5000_LBNMspBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+7:24)
	jr	t, HDAE5000_LBNMspBitCheck_Epilogue
HDAE5000_LBNMspBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LBNMspBitCheck_Epilogue
HDAE5000_LBNMspBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNMspBitCheck_Ev01E00046_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_LBNMspBitCheck_Ev01E00046_Join
HDAE5000_LBNMspBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNMspBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNMspBitCheck_Epilogue
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
	jrl	z, HDAE5000_LBNRcmBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LBNRcmBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_LBNRcmBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LBNRcmBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNRcmBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LBNRcmBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNRcmBitCheck_Ev01E00047_Skip
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
	jr	t, HDAE5000_LBNRcmBitCheck_Ev01E00047_Join
HDAE5000_LBNRcmBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_LBNRcmBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl	t, HDAE5000_LBNRcmBitCheck_Epilogue
HDAE5000_LBNRcmBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNRcmBitCheck_Epilogue
HDAE5000_LBNRcmBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNRcmBitCheck_Epilogue
HDAE5000_LBNRcmBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNRcmBitCheck_Ev01E00043_Skip
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+8:24), 0
	jr	nz, HDAE5000_LBNRcmBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNRcmBitCheck_Ev01E00043_Join
HDAE5000_LBNRcmBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNRcmBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_LBNRcmBitCheck_Epilogue
HDAE5000_LBNRcmBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNRcmBitCheck_Ev01E00044_Skip
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+8:24), 0
	jr	nz, HDAE5000_LBNRcmBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNRcmBitCheck_Ev01E00044_Join
HDAE5000_LBNRcmBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNRcmBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_LBNRcmBitCheck_Epilogue
HDAE5000_LBNRcmBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+8:24)
	jr	t, HDAE5000_LBNRcmBitCheck_Epilogue
HDAE5000_LBNRcmBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LBNRcmBitCheck_Epilogue
HDAE5000_LBNRcmBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNRcmBitCheck_Ev01E00046_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_LBNRcmBitCheck_Ev01E00046_Join
HDAE5000_LBNRcmBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNRcmBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNRcmBitCheck_Epilogue
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
	jrl	z, HDAE5000_LBNMdBitCheck_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LBNMdBitCheck_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_LBNMdBitCheck_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LBNMdBitCheck_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNMdBitCheck_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LBNMdBitCheck_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNMdBitCheck_Ev01E00047_Skip
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
	jr	t, HDAE5000_LBNMdBitCheck_Ev01E00047_Join
HDAE5000_LBNMdBitCheck_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_LBNMdBitCheck_Ev01E00047_Join:
	ld	xhl, xiz
	jrl	t, HDAE5000_LBNMdBitCheck_Epilogue
HDAE5000_LBNMdBitCheck_Ev01E0003E:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNMdBitCheck_Epilogue
HDAE5000_LBNMdBitCheck_Ev01E0003F:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNMdBitCheck_Epilogue
HDAE5000_LBNMdBitCheck_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNMdBitCheck_Ev01E00043_Skip
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+9:24), 0
	jr	nz, HDAE5000_LBNMdBitCheck_Ev01E00043_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNMdBitCheck_Ev01E00043_Join
HDAE5000_LBNMdBitCheck_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNMdBitCheck_Ev01E00043_Join:
	jr	t, HDAE5000_LBNMdBitCheck_Epilogue
HDAE5000_LBNMdBitCheck_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNMdBitCheck_Ev01E00044_Skip
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+9:24), 0
	jr	nz, HDAE5000_LBNMdBitCheck_Ev01E00044_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNMdBitCheck_Ev01E00044_Join
HDAE5000_LBNMdBitCheck_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNMdBitCheck_Ev01E00044_Join:
	jr	t, HDAE5000_LBNMdBitCheck_Epilogue
HDAE5000_LBNMdBitCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+9:24)
	jr	t, HDAE5000_LBNMdBitCheck_Epilogue
HDAE5000_LBNMdBitCheck_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LBNMdBitCheck_Epilogue
HDAE5000_LBNMdBitCheck_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNMdBitCheck_Ev01E00046_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_LBNMdBitCheck_Ev01E00046_Join
HDAE5000_LBNMdBitCheck_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNMdBitCheck_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNMdBitCheck_Epilogue
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
	jrl	z, HDAE5000_LBNTlxBitCheck_Unregistered_OnRamDataReq
	sub	xwa, EVT_GET_LARGE_STEP
	cp	xwa, 0x00000000
	jrl	lt, HDAE5000_LBNTlxBitCheck_Unregistered_Default
	cp	xwa, 0x00000009
	jrl	gt, HDAE5000_LBNTlxBitCheck_Unregistered_Default
	add	xwa, xwa
	add	xwa, HDAE5000_LBNTlxBitCheck_Unregistered_CaseTable
	ld	wa, (xwa)
	lda xix, (HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047:24)
	jp	t, (xix+wa)
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Skip
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
	jr	t, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Join
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Skip:
	ld	xwa, (HDAE5000_TextPtrs_Chr2D2D2D_NO_YES)
	push xwa
	ld xwa, (xde + 0x12)
	push xwa
	call HDAE5000_StrCpy
	inc 8, xsp
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00047_Join:
	ld	xhl, xiz
	jrl	t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E0003E:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E0003F:
	ld	xhl, 1:i3
	jrl	t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Skip
	ld	xhl, 2:i3
	cp	(HDAE5000_RAM_SaveOptions+10:24), 0
	jr	nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Join
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00043_Join:
	jr	t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Skip
	ld	xhl, 1:i3
	cp	(HDAE5000_RAM_SaveOptions+10:24), 0
	jr	nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Join
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Join
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Skip:
	ld	xhl, 0:i3
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00044_Join:
	jr	t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00045:
	lda xhl, (HDAE5000_RAM_SaveOptions+10:24)
	jr	t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046:
	ld	xhl, 1:i3
	jr	t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue
HDAE5000_LBNTlxBitCheck_Unregistered_OnRamDataReq:
	cpw	(HDAE5000_RAM_LbnDigitPos:24), 5
	jr	nz, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Skip
	lda xwa, (HDAE5000_RAM_SaveOptions:24)
	calr	HDAE5000_TypeSel_BuildMask
	ld	bc, (HDAE5000_RAM_CurDir:24)
	ld	de, (HDAE5000_RAM_CurSong:24)
	ld	wa, (HDAE5000_RAM_SaveOptions:24)
	pushw wa
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	calr	HDAE5000_PartList_Build
	jr	t, HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Join
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Skip:
	pushw 0xffff
	ld	xwa, HDAE5000_OBJ_HD_FILE_OPTION
	ldw	bc, 0xffff
	ldw	de, 0xffff
	calr	HDAE5000_PartList_Build
HDAE5000_LBNTlxBitCheck_Unregistered_Ev01E00046_Join:
	ld	xhl, 0:i3
	jr	t, HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue
HDAE5000_LBNTlxBitCheck_Unregistered_Default:
	ld	xhl, 0:i3
HDAE5000_LBNTlxBitCheck_Unregistered_Epilogue:
	pop xiz
	ret



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
	pushw HDAE5000_Fmt_3_3d_FlsList_BuildPage@lo16
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
	pushw HDAE5000_Str_FLSNAME@hi16
	pushw HDAE5000_Str_FLSNAME@lo16		; low half of HDAE5000_Str_FLSNAME
	pushw 0x0022
	pushw 0xa058
	call HDAE5000_StrCat
	ld	wa, (HDAE5000_RAM_CurFls:24)
	inc	1, wa
	pushw wa
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
	pushw HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2@lo16		; low half of HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2
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
	pushw HDAE5000_Fmt_LOC_3_3d_2_2d@lo16		; low half of HDAE5000_Fmt_LOC_3_3d_2_2d
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr	t, HDAE5000_FlsScreen_Refresh_Join7
HDAE5000_FlsScreen_Refresh_Skip:
	pushw HDAE5000_Str_LOC00000@hi16
	pushw HDAE5000_Str_LOC00000@lo16		; low half of HDAE5000_Str_LOC00000
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
HDAE5000_FdList_Redisplay:
	lda xwa, (HDAE5000_RAM_FdList:24); f2 9c aa 22 30
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
	ld xbc, HDAE5000_RAM_FdList			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	ld	(xbc), 0x20

	; Check status flag at +0x0114
	ld wa, de				; da 88
	extz xwa				; e8 12
	add xwa, 0x00000114			; e8 c8 14 01 00 00
	ld xbc, HDAE5000_RAM_FdList			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_loop_next			; 6e xx

	; Entry is active: set flag to 0x2A (asterisk)
	ld wa, de				; da 88
	mul wa, 0x000c				; d8 08 0c 00
	add wa, 0x000a				; d8 c8 0a 00
	extz xwa				; e8 12
	add xwa, 0x0000000e			; e8 c8 0e 00 00 00
	ld xbc, HDAE5000_RAM_FdList			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	ld	(xbc), 0x2a

.Lfbs_loop_next:				; 0x2896FD
	inc 1, de				; da 61
	cp de, 0x0014				; da cf 14 00
	jr c, .Lfbs_loop			; 67 xx

.Lfbs_after_loop:				; 0x289705
	; --- Register events for second buffer at 0x22AAAA ---
	lda xwa, (HDAE5000_RAM_FdList+14:24); f2 aa aa 22 30
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
	ld xbc, HDAE5000_RAM_FdList			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_evt_0009_next		; 6e xx
	; Entry is active: mark status flag
	ld wa, iz				; de 88
	extz xwa				; e8 12
	add xwa, 0x00000114			; e8 c8 14 01 00 00
	ld xbc, HDAE5000_RAM_FdList			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	ld	(xbc), 0x01
	calr HDAE5000_FdList_Redisplay		; 1e xx xx — self-call

.Lfbs_evt_0009_next:				; 0x2897DB
	inc 1, iz				; de 61
	cp iz, 0x0014				; de cf 14 00
	jr c, .Lfbs_evt_0009_loop		; 67 xx
	jrl t, .Lfbs_evt_done			; 78 xx xx

	; MT_SelectOK (0x01EA0006): rebuild the directory page and count the active files
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
	ld xbc, HDAE5000_RAM_FdList			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_evt_done			; 6e xx
	; First flag is set: check second flag at +0x0114
	ld xwa, xde				; ea 88
	add xwa, 0x00000114			; e8 c8 14 01 00 00
	ld xbc, HDAE5000_RAM_FdList			; 41 9c aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_evt_0008_set1		; 6e xx
	; Second flag is set: clear it to 0
	add xde, 0x00000114			; ea c8 14 01 00 00
	ld xwa, HDAE5000_RAM_FdList			; 40 9c aa 22 00
	add xwa, xde				; ea 80
	ld	(xwa), 0x00
	jr t, .Lfbs_evt_0008_done		; 68 xx

.Lfbs_evt_0008_set1:				; 0x28986D
	; Second flag not set: set it to 1
	add xde, 0x00000114			; ea c8 14 01 00 00
	ld xwa, HDAE5000_RAM_FdList			; 40 9c aa 22 00
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
	pushw HDAE5000_Fmt_2_2d_CopyToHd_Execute@lo16		; low half of HDAE5000_Fmt_2_2d_CopyToHd_Execute
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
	pushw HDAE5000_Str_LSW@lo16		; low half of HDAE5000_Str_LSW
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
	pushw HDAE5000_Str_PMT@lo16		; low half of HDAE5000_Str_PMT
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
HDAE5000_WrConfirmEventCatch:	.include "includes/generated/cc900/HDAE5000_WrConfirmEventCatch.s"	; C: cc900/hdae5000_fs_screens.c

; ---------------------------------------------------------------------------
; Show the nine delete-option flags (HDAE5000_RAM_DeleteOptions+2..+10) as the
; texts of the pointer table HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL ("---",
; "OFF", "DEL") in objects HDAE5000_OBJ_DEL_EDIT_LSW.. (RootFn_PostEvent,
; EVT_PARA_DRAW).
; ---------------------------------------------------------------------------
HDAE5000_DelOpt_ShowFlags:
	ld a, (HDAE5000_RAM_DeleteOptions+2:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_LSW
	ld xbc, EVT_PARA_DRAW
	call (xhl)
	ld a, (HDAE5000_RAM_DeleteOptions+3:24)
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
	ld a, (HDAE5000_RAM_DeleteOptions+4:24)
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
	ld a, (HDAE5000_RAM_DeleteOptions+5:24)
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
	ld a, (HDAE5000_RAM_DeleteOptions+6:24)
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
	ld a, (HDAE5000_RAM_DeleteOptions+7:24)
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
	ld a, (HDAE5000_RAM_DeleteOptions+8:24)
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
	ld a, (HDAE5000_RAM_DeleteOptions+9:24)
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
	ld a, (HDAE5000_RAM_DeleteOptions+10:24)
	extz wa
	sla wa, 2
	lda xbc, (HDAE5000_TextPtrs_Chr2D2D2D_OFF_DEL:24)
	ld	xde, (xbc+wa)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24)
	ld xwa, (xwa + WS_RootFnTable)
	ld xhl, (xwa + RootFn_PostEvent)
	ld xwa, HDAE5000_OBJ_DEL_EDIT_TLX
	ld xbc, EVT_PARA_DRAW
	jp (xhl)
	;
	; Part 2: Event handler (0x28A497) — dispatches on event codes
HDAE5000_DelOptSwEventCatch:	.include "includes/generated/cc900/HDAE5000_DelOptSwEventCatch.s"	; C: cc900/hdae5000_fs_screens.c

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
	jp	t, (xix+wa)
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
	lda xhl, (HDAE5000_RAM_SaveOptions+11:24)
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
	jp	t, (xix+wa)
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
	cp (HDAE5000_RAM_DeleteOptions+2:24), 0x00
	jr nz, .LDUO__hB_c3_nz
	ld xhl, 0:i3
.LDUO__hB_c3_nz:
	jr t, .LDUO__hB_exit
	; Case 4: conditional on (0x22abe8)
HDAE5000_DelLswEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (HDAE5000_RAM_DeleteOptions+2:24), 0x00
	jr nz, .LDUO__hB_c4_nz
	ld xhl, 0:i3
.LDUO__hB_c4_nz:
	jr t, .LDUO__hB_exit
	; Case 5
HDAE5000_DelLswEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_DeleteOptions+2:24)
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
	jp	t, (xix+wa)
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
	cp (HDAE5000_RAM_DeleteOptions+3:24), 0x00
	jr nz, .LDUO__hC_c3_nz
	ld xhl, 0:i3
.LDUO__hC_c3_nz:
	jr t, .LDUO__hC_exit
	; Case 4
HDAE5000_DelPmtEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (HDAE5000_RAM_DeleteOptions+3:24), 0x00
	jr nz, .LDUO__hC_c4_nz
	ld xhl, 0:i3
.LDUO__hC_c4_nz:
	jr t, .LDUO__hC_exit
	; Case 5
HDAE5000_DelPmtEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_DeleteOptions+3:24)
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
	jp	t, (xix+wa)
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
	cp (HDAE5000_RAM_DeleteOptions+4:24), 0x00
	jr nz, .LDUO__hD_c3_nz
	ld xhl, 0:i3
.LDUO__hD_c3_nz:
	jr t, .LDUO__hD_exit
	; Case 4
HDAE5000_DelSqtEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (HDAE5000_RAM_DeleteOptions+4:24), 0x00
	jr nz, .LDUO__hD_c4_nz
	ld xhl, 0:i3
.LDUO__hD_c4_nz:
	jr t, .LDUO__hD_exit
	; Case 5
HDAE5000_DelSqtEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_DeleteOptions+4:24)
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
	jp	t, (xix+wa)
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
	cp (HDAE5000_RAM_DeleteOptions+5:24), 0x00
	jr nz, .LDUO__hE_c3_nz
	ld xhl, 0:i3
.LDUO__hE_c3_nz:
	jr t, .LDUO__hE_exit
	; Case 4
HDAE5000_DelCmpEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (HDAE5000_RAM_DeleteOptions+5:24), 0x00
	jr nz, .LDUO__hE_c4_nz
	ld xhl, 0:i3
.LDUO__hE_c4_nz:
	jr t, .LDUO__hE_exit
	; Case 5
HDAE5000_DelCmpEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_DeleteOptions+5:24)
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
	jp	t, (xix+wa)
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
	cp (HDAE5000_RAM_DeleteOptions+6:24), 0x00
	jr nz, .LDUO__hF_c3_nz
	ld xhl, 0:i3
.LDUO__hF_c3_nz:
	jr t, .LDUO__hF_exit
	; Case 4
HDAE5000_DelTmEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (HDAE5000_RAM_DeleteOptions+6:24), 0x00
	jr nz, .LDUO__hF_c4_nz
	ld xhl, 0:i3
.LDUO__hF_c4_nz:
	jr t, .LDUO__hF_exit
	; Case 5
HDAE5000_DelTmEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_DeleteOptions+6:24)
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
	jp	t, (xix+wa)
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
	cp (HDAE5000_RAM_DeleteOptions+7:24), 0x00
	jr nz, .LDUO__hG_c3_nz
	ld xhl, 0:i3
.LDUO__hG_c3_nz:
	jr t, .LDUO__hG_exit
	; Case 4
HDAE5000_DelMspEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (HDAE5000_RAM_DeleteOptions+7:24), 0x00
	jr nz, .LDUO__hG_c4_nz
	ld xhl, 0:i3
.LDUO__hG_c4_nz:
	jr t, .LDUO__hG_exit
	; Case 5
HDAE5000_DelMspEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_DeleteOptions+7:24)
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
	jp	t, (xix+wa)
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
	cp (HDAE5000_RAM_DeleteOptions+8:24), 0x00
	jr nz, .LDUO__hH_c3_nz
	ld xhl, 0:i3
.LDUO__hH_c3_nz:
	jr t, .LDUO__hH_exit
	; Case 4
HDAE5000_DelRcmEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (HDAE5000_RAM_DeleteOptions+8:24), 0x00
	jr nz, .LDUO__hH_c4_nz
	ld xhl, 0:i3
.LDUO__hH_c4_nz:
	jr t, .LDUO__hH_exit
	; Case 5
HDAE5000_DelRcmEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_DeleteOptions+8:24)
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
	jp	t, (xix+wa)
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
	cp (HDAE5000_RAM_DeleteOptions+9:24), 0x00
	jr nz, .LDUO__hI_c3_nz
	ld xhl, 0:i3
.LDUO__hI_c3_nz:
	jr t, .LDUO__hI_exit
	; Case 4
HDAE5000_DelMdEditCheck_Ev01E00044:
	ld xhl, 1:i3
	cp (HDAE5000_RAM_DeleteOptions+9:24), 0x00
	jr nz, .LDUO__hI_c4_nz
	ld xhl, 0:i3
.LDUO__hI_c4_nz:
	jr t, .LDUO__hI_exit
	; Case 5
HDAE5000_DelMdEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_DeleteOptions+9:24)
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
	jp	t, (xix+wa)
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
	cp (HDAE5000_RAM_DeleteOptions+10:24), 0x00
	jr nz, .LDUO__hJ_c3_nz
	ld xhl, 0:i3
.LDUO__hJ_c3_nz:
	jr t, .LDUO__hJ_exit
	; Case 4: extra comparison vs 0x01
HDAE5000_DelTlxEditCheck_Ev01E00044:
	cp (HDAE5000_RAM_DeleteOptions+10:24), 0x01
	jr nz, .LDUO__hJ_c4_ne1
	ld xhl, 2:i3
	jr t, .LDUO__hJ_c4_chk
.LDUO__hJ_c4_ne1:
	ld xhl, 1:i3
.LDUO__hJ_c4_chk:
	cp (HDAE5000_RAM_DeleteOptions+10:24), 0x00
	jr nz, .LDUO__hJ_c4_nz
	ld xhl, 0:i3
.LDUO__hJ_c4_nz:
	jr t, .LDUO__hJ_exit
	; Case 5
HDAE5000_DelTlxEditCheck_Ev01E00045:
	lda xhl, (HDAE5000_RAM_DeleteOptions+10:24)
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

