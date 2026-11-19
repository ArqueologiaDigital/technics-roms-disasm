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
	pushw	HDAE5000_Fmt_s_FileLBNNameCheck@hi16
	pushw	HDAE5000_Fmt_s_FileLBNNameCheck@lo16		; low half of HDAE5000_Fmt_s_FileLBNNameCheck
	ld xwa, (xiz + 0x12)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr	t, HDAE5000_FileLBNNameCheck_Ev01E00047_Join
HDAE5000_FileLBNNameCheck_Ev01E00047_Skip:
	pushw	HDAE5000_Str_Blank26@hi16
	pushw	HDAE5000_Str_Blank26@lo16		; low half of HDAE5000_Str_Blank26
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
	lda xhl, (HDAE5000_RAM_SaveOptions+10:24)
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




; ---------------------------------------------------------------------------
; Build one page of the FLS list in HDAE5000_RAM_FlsListText: 24 rows of 21
; bytes, each "NNN:" (HDAE5000_RAM_FlsPageBase + row + 1, "%3d") and the FLS
; record's 16-byte name (HDAE5000_FlsRecord_Address); then RootFn_ApPostEvent
; posts EVT_HDAE_SET_STR_ADR (the text) and EVT_PARA_DRAW to the list object.
; The FLS counterpart of HDAE5000_DirList_BuildPage.
; In:  XWA = list object
; ---------------------------------------------------------------------------
HDAE5000_FlsList_BuildPage:	.include "includes/generated/cc900/HDAE5000_FlsList_BuildPage.s"	; C: cc900/hdae5000_list_pages_filesystem.c
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
	pushw	HDAE5000_RAM_AtaIdentifyBuffer@hi16
	pushw	HDAE5000_RAM_AtaIdentifyBuffer@lo16		; low half of HDAE5000_RAM_AtaIdentifyBuffer
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
	pushw	HDAE5000_Fmt_2_2d_FlsScreen_Refresh@hi16
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
	ld	xbc, 0x0022afd8
	add	xbc, xwa
	push xbc
	call HDAE5000_MemCopy
	ld	wa, (HDAE5000_RAM_FlsItemPageBase:24)
	add	wa, iz
	inc	1, wa
	pushw wa
	pushw	HDAE5000_Fmt_2_2d_FlsScreen_Refresh_2@hi16
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
	ld	xbc, 0x0022afd8
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
	ld	xbc, 0x0022afd8
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
	ld	xbc, 0x0022afd8
	add	xbc, xwa
	ld	(xbc), 0x2a
HDAE5000_FlsScreen_Refresh_Join4:
	cp	(xsp+7), 0x01
	jr	nz, HDAE5000_FlsScreen_Refresh_Next
	ldw	wa, 0x0025
	mul	xwa, iz
	add	wa, 0x0023
	extz xwa
	ld	xbc, 0x0022afd8
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
	lda xwa, (0x22afd8:24)
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
	pushw	HDAE5000_Fmt_LOC_3_3d_2_2d@hi16
	pushw	HDAE5000_Fmt_LOC_3_3d_2_2d@lo16		; low half of HDAE5000_Fmt_LOC_3_3d_2_2d
	lda	xwa, (xsp+16)
	push xwa
	call HDAE5000_SPrintf
	lda	xsp, (xsp+12)
	jr	t, HDAE5000_FlsScreen_Refresh_Join7
HDAE5000_FlsScreen_Refresh_Skip:
	pushw	HDAE5000_Str_LOC00000@hi16
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

HDAE5000_SelectFlsScreen:
	; registered as "SelectFlsScreen" in HDAE5000_ScreenProc_Table
	push xiz
	ld	xiz, xde
	cp	xbc, EVT_HDAE_OVER_FLOW
	jrl	z, HDAE5000_SelectFlsScreen_OnHdaeOverFlow
	cp	xbc, EVT_HDAE_UNDER_FLOW
	jrl	z, HDAE5000_SelectFlsScreen_OnHdaeUnderFlow
	cp	xbc, EVT_HDAE_SELECT_SAVE
	jrl	z, HDAE5000_SelectFlsScreen_OnHdaeSelectSave
	cp	xbc, EVT_HDAE_SELECT_OK2
	jrl	z, HDAE5000_SelectFlsScreen_Skip5
	cp	xbc, EVT_HDAE_SELECT_OK
	jrl	z, HDAE5000_SelectFlsScreen_Skip5
	cp	xbc, EVT_SW_IN
	jrl	nz, HDAE5000_SelectFlsScreen_Done
	ld	xde, xiz
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld_sril	xix, (xwa + RootFn_SendEvent)
	ld	xwa, 0x02600024
	ld	xbc, EVT_MAKE_EDIT_SW_ID
	call	(xix)
	cp	xhl, 0x00000007
	jr	z, HDAE5000_SelectFlsScreen_Skip4
	cp	xhl, 0x00000006
	jr	z, HDAE5000_SelectFlsScreen_Skip3
	cp	xhl, 0x00000005
	jr	z, HDAE5000_SelectFlsScreen_Skip2
	cp	xhl, 0x00000001
	jr	z, HDAE5000_SelectFlsScreen_Skip
	or xhl, xhl
	jrl	nz, HDAE5000_SelectFlsScreen_Done
	ldw	(HDAE5000_RAM_FlsPageBase:24), 0
	calr	HDAE5000_FlsList_BuildPage
	jrl	t, HDAE5000_SelectFlsScreen_Done
HDAE5000_SelectFlsScreen_Skip:
	ldw	(HDAE5000_RAM_FlsPageBase:24), 24
	calr	HDAE5000_FlsList_BuildPage
	jrl	t, HDAE5000_SelectFlsScreen_Done
HDAE5000_SelectFlsScreen_Skip2:
	ldw	(HDAE5000_RAM_FlsPageBase:24), 48
	calr	HDAE5000_FlsList_BuildPage
	jrl	t, HDAE5000_SelectFlsScreen_Done
HDAE5000_SelectFlsScreen_Skip3:
	ldw	(HDAE5000_RAM_FlsPageBase:24), 72
	calr	HDAE5000_FlsList_BuildPage
	jrl	t, HDAE5000_SelectFlsScreen_Done
HDAE5000_SelectFlsScreen_Skip4:
	ldw	(HDAE5000_RAM_FlsPageBase:24), 96
	calr	HDAE5000_FlsList_BuildPage
	jrl	t, HDAE5000_SelectFlsScreen_Done
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
	jrl	t, HDAE5000_SelectFlsScreen_Done
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
	jr	t, HDAE5000_SelectFlsScreen_Done
HDAE5000_SelectFlsScreen_OnHdaeUnderFlow:
	cpw	(HDAE5000_RAM_FlsPageBase:24), 24
	jr	lt, HDAE5000_SelectFlsScreen_Done
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
	jr	t, HDAE5000_SelectFlsScreen_Done
HDAE5000_SelectFlsScreen_OnHdaeOverFlow:
	cpw	(HDAE5000_RAM_FlsPageBase:24), 96
	jr	ge, HDAE5000_SelectFlsScreen_Done
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
	jrl	z, HDAE5000_FlsLoadScreen_OnHdaeChangeSelNum
	cp	xbc, EVT_HDAE_OVER_FLOW
	jrl	z, HDAE5000_FlsLoadScreen_OnHdaeOverFlow
	cp	xbc, EVT_HDAE_UNDER_FLOW
	jrl	z, HDAE5000_FlsLoadScreen_OnHdaeUnderFlow
	cp	xbc, EVT_HDAE_SELECT_SAVE
	jrl	z, HDAE5000_FlsLoadScreen_OnHdaeSelectSave
	cp	xbc, EVT_HDAE_SELECT_OK
	jrl	z, HDAE5000_FlsLoadScreen_OnHdaeSelectOk
	cp	xbc, EVT_SW_IN
	jrl	z, HDAE5000_FlsLoadScreen_Done
	cp	xbc, EVT_HDAE_AFTER_LOAD
	jr	z, HDAE5000_FlsLoadScreen_OnHdaeAfterLoad
	cp	xbc, EVT_HDAE_SEQ_STOP
	jr	z, HDAE5000_FlsLoadScreen_OnHdaeSeqStop
	cp	xbc, EVT_SHOW
	jrl	nz, HDAE5000_FlsLoadScreen_Done
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_FILE_BOX
	ld	xbc, EVT_HDAE_CHANGE_SEL_NUM
	ld	xde, 0:i3
	call	(xhl)
	jrl	t, HDAE5000_FlsLoadScreen_Done
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
	jrl	t, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_OnHdaeAfterLoad:
	cp	(HDAE5000_RAM_FlsAutoLoadPending:24), 1
	jrl	nz, HDAE5000_FlsLoadScreen_Done
	ld	iz, (HDAE5000_RAM_FlsChainFls:24)
	ld	wa, (HDAE5000_RAM_FlsChainItem:24)
	inc	1, wa
	ld	qiz, wa
	cp	wa, 0x0020
	jr	c, HDAE5000_FlsLoadScreen_Join2
	inc	1, iz
	ld	wa, iz
	cp	wa, 0x0078
	jr	c, HDAE5000_FlsLoadScreen_Join
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
	jr	z, HDAE5000_FlsLoadScreen_Skip2
	cp	(xsp+9), 0x01
	jr	nz, HDAE5000_FlsLoadScreen_Skip
	ld	(HDAE5000_RAM_FlsAutoLoadPending:24), 1
	ld	(HDAE5000_RAM_FlsChainFls), iz
	ld	wa, qiz
	ld	(HDAE5000_RAM_FlsChainItem), wa
	jr	t, HDAE5000_FlsLoadScreen_Join3
HDAE5000_FlsLoadScreen_Skip:
	ld	(HDAE5000_RAM_FlsAutoLoadPending:24), 0
HDAE5000_FlsLoadScreen_Join3:
	ld	wa, (xsp+4)
	ld	bc, (xsp+6)
	call HDAE5000_Song_PartMask
	pushw 0x0000
	ld	xwa, HDAE5000_OBJ_FLS_FILE_LOAD
	push xwa
	ld	wa, (xsp+10)
	ld	bc, (xsp+12)
	ld	de, hl
	calr	HDAE5000_LoadSongWithUi
	cp	hl, 0xffff
	jrl	z, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_Join4:
	cp	(xsp+8), 0x01
	jrl	nz, HDAE5000_FlsLoadScreen_Done
	pushw 0x0001
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_SwbtWr)
	ldw	wa, 0x0048
	ld	bc, 5:i3
	ld	de, 1:i3
	call	(xhl)
	jrl	t, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_Skip2:
	ld	(HDAE5000_RAM_FlsAutoLoadPending:24), 0
	jrl	t, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_OnHdaeSelectOk:
	ld	bc, iz
	ld	wa, (HDAE5000_RAM_FlsItemPageBase:24)
	add	wa, bc
	ld	(HDAE5000_RAM_CurFlsItem), wa
	lda	xwa, (xsp+4)
	ld	xde, xwa
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	bc, (HDAE5000_RAM_CurFlsItem:24)
	call HDAE5000_FlsItem_Get
	cp	hl, 0xffff
	jrl	z, HDAE5000_FlsLoadScreen_Done
	cp	(xsp+9), 0x01
	jr	nz, HDAE5000_FlsLoadScreen_Skip3
	ld	(HDAE5000_RAM_FlsAutoLoadPending:24), 1
	ld	wa, (HDAE5000_RAM_CurFls:24)
	ld	(HDAE5000_RAM_FlsChainFls), wa
	ld	wa, (HDAE5000_RAM_CurFlsItem:24)
	ld	(HDAE5000_RAM_FlsChainItem), wa
	jr	t, HDAE5000_FlsLoadScreen_Join5
HDAE5000_FlsLoadScreen_Skip3:
	ld	(HDAE5000_RAM_FlsAutoLoadPending:24), 0
HDAE5000_FlsLoadScreen_Join5:
	ld	wa, (xsp+4)
	ld	bc, (xsp+6)
	call HDAE5000_Song_PartMask
	pushw 0x0000
	ld	xwa, HDAE5000_OBJ_FLS_FILE_LOAD
	push xwa
	ld	wa, (xsp+10)
	ld	bc, (xsp+12)
	ld	de, hl
	calr	HDAE5000_LoadSongWithUi
	cp	hl, 0xffff
	jrl	z, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_Join6:
	cp	(xsp+8), 0x01
	jrl	nz, HDAE5000_FlsLoadScreen_Done
	pushw 0x0001
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_HamaFnTable)
	ld	xhl, (xwa + HamaFn_SwbtWr)
	ldw	wa, 0x0048
	ld	bc, 5:i3
	ld	de, 1:i3
	call	(xhl)
	jrl	t, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_OnHdaeSelectSave:
	ld	bc, iz
	ld	wa, (HDAE5000_RAM_FlsItemPageBase:24)
	add	wa, bc
	ld	(HDAE5000_RAM_CurFlsItem), wa
	ld	wa, 1:i3
	ld	bc, 0:i3
	calr	HDAE5000_FlsScreen_Refresh
	ld	wa, (HDAE5000_RAM_CurFls:24)
	call HDAE5000_Fls_IsBlankName
	cp	hl, 0xffff
	jr	z, HDAE5000_FlsLoadScreen_Skip4
	ld	xwa, (HDAE5000_RAM_MainWorkspacePtr)
	ld	xwa, (xwa + WS_RootFnTable)
	ld	xhl, (xwa + RootFn_ApPostEvent)
	ld	xwa, HDAE5000_OBJ_FLS_EDIT
	ld	xbc, EVT_SHOW
	ld	xde, 0:i3
	call	(xhl)
	jrl	t, HDAE5000_FlsLoadScreen_Done
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
	jrl	t, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_OnHdaeUnderFlow:
	cpw	(HDAE5000_RAM_FlsItemPageBase:24), 0
	jr	nz, HDAE5000_FlsLoadScreen_Skip5
	cpw	(HDAE5000_RAM_CurFls:24), 0
	jrl	z, HDAE5000_FlsLoadScreen_Done
	decw	1, (HDAE5000_RAM_CurFls:24)
	ldw	(HDAE5000_RAM_FlsItemPageBase:24), 16
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
	jrl	t, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_Skip5:
	ldw	(HDAE5000_RAM_FlsItemPageBase:24), 0
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
	jrl	t, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_OnHdaeOverFlow:
	cpw	(HDAE5000_RAM_FlsItemPageBase:24), 0
	jr	z, HDAE5000_FlsLoadScreen_Skip6
	cpw	(HDAE5000_RAM_CurFls:24), 119
	jrl	nc, HDAE5000_FlsLoadScreen_Done
	incw	1, (HDAE5000_RAM_CurFls:24)
	ldw	(HDAE5000_RAM_FlsItemPageBase:24), 0
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
	jr	t, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_Skip6:
	ldw	(HDAE5000_RAM_FlsItemPageBase:24), 16
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
	jr	t, HDAE5000_FlsLoadScreen_Done
HDAE5000_FlsLoadScreen_OnHdaeChangeSelNum:
	ld	bc, iz
	ld	wa, (HDAE5000_RAM_FlsItemPageBase:24)
	add	wa, bc
	ld	(HDAE5000_RAM_CurFlsItem), wa
	ld	wa, 0:i3
	ld	bc, 1:i3
	calr	HDAE5000_FlsScreen_Refresh
HDAE5000_FlsLoadScreen_Done:
	ld	xhl, 0:i3
	pop xiz
	inc	6, xsp
	ret

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
	lda xwa, (HDAE5000_RAM_FdList:24); f2 54 aa 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20 — ld xwa, (xwa+0x0e0a)
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23 — ld xhl, (xwa+0x0124)
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL			; 40 db 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR			; 41 09 00 ea 01
	call (xhl)				; b3 e8

	; Deregister event 0x01C0000F
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_VOLLABEL			; 40 db 00 7f 00
	ld xbc, EVT_PARA_DRAW			; 41 0f 00 c0 01
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8

	; --- Initialize 20 buffer entries ---
	ld de, 0:i3				; da a8
	cp de, 0x0014				; da cf 14 00
	jr nc, .Lfbs_after_loop			; 6f xx

.Lfbs_loop:
	ld wa, de				; da 88
	mul wa, 0x000c				; d8 08 0c 00
	add wa, 0x000a				; d8 c8 0a 00
	extz xwa				; e8 12
	add xwa, 0x0000000e			; e8 c8 0e 00 00 00
	ld xbc, HDAE5000_RAM_FdList			; 41 54 aa 22 00
	add xbc, xwa				; e8 81
	ld	(xbc), 0x20

	; Check status flag at +0x0114
	ld wa, de				; da 88
	extz xwa				; e8 12
	add xwa, 0x00000114			; e8 c8 14 01 00 00
	ld xbc, HDAE5000_RAM_FdList			; 41 54 aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_loop_next			; 6e xx

	; Entry is active: set flag to 0x2A (asterisk)
	ld wa, de				; da 88
	mul wa, 0x000c				; d8 08 0c 00
	add wa, 0x000a				; d8 c8 0a 00
	extz xwa				; e8 12
	add xwa, 0x0000000e			; e8 c8 0e 00 00 00
	ld xbc, HDAE5000_RAM_FdList			; 41 54 aa 22 00
	add xbc, xwa				; e8 81
	ld	(xbc), 0x2a

.Lfbs_loop_next:
	inc 1, de				; da 61
	cp de, 0x0014				; da cf 14 00
	jr c, .Lfbs_loop			; 67 xx

.Lfbs_after_loop:
	; --- Register events for second buffer at 0x22AAAA ---
	lda xwa, (HDAE5000_RAM_FdList+14:24); f2 62 aa 22 30
	ld xde, xwa				; e8 8a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LIST			; 40 d5 00 7f 00
	ld xbc, EVT_HDAE_SET_STR_ADR			; 41 09 00 ea 01
	call (xhl)				; b3 e8

	; Deregister event 0x01C0000F
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LIST			; 40 d5 00 7f 00
	ld xbc, EVT_PARA_DRAW			; 41 0f 00 c0 01
	ld xde, 0xffffffff			; 42 ff ff ff ff
	call (xhl)				; b3 e8

	; Register event 0x01C0000D (handler 1)
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LINE1			; 40 d6 00 7f 00
	ld xbc, EVT_DRAW			; 41 0d 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8

	; Register event 0x01C0000D (handler 2) — tail call via jp
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_LINE2			; 40 d7 00 7f 00
	ld xbc, EVT_DRAW			; 41 0d 00 c0 01
	ld xde, 0:i3				; ea a8
	jp (xhl)				; b3 d8 — tail call

; --- Event handler sub-function ---
HDAE5000_CopyToHDScreen:
	; registered as "CopyToHDScreen" in HDAE5000_ScreenProc_Table
	cp xbc, EVT_HDAE_CHANGE_SEL_NUM			; e9 cf 02 00 ea 01
	jrl	z, .Lfbs_evt_0002
	cp xbc, EVT_HDAE_SELECT_SAVE			; e9 cf 08 00 ea 01
	jr	z, .Lfbs_evt_0008
	cp xbc, EVT_HDAE_SELECT_OK			; e9 cf 06 00 ea 01
	jrl nz, .Lfbs_evt_done

	; MT_SelectOK (0x01EA0006): rebuild the directory page and count the active files
.Lfbs_evt_0006:
	ld xwa, HDAE5000_OBJ_CP_FD_DIRBOX			; 40 e0 00 7f 00
	calr HDAE5000_DirList_BuildPage		; 1e xx xx
	calr HDAE5000_Count_Active_Files	; 1e xx xx
	cp hl, 0:i3				; db d8
	jr z, .Lfbs_evt_0006_empty		; 66 xx
	; Has active files: register status 0x007f00e2
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_CP_FD_DIRSEL			; 40 dc 00 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	jr t, .Lfbs_evt_done			; 68 xx

.Lfbs_evt_0006_empty:
	; No active files: register status 0x007f027a
	ld xwa, (HDAE5000_RAM_MainWorkspacePtr:24); e2 de d2 23 20
	ld xwa, (xwa + WS_RootFnTable)             ; e3 e1 0a 0e 20
	ld xhl, (xwa + RootFn_ApPostEvent)             ; e3 e1 24 01 23
	ld xwa, HDAE5000_OBJ_ATTEN_CPFD_MARK			; 40 6e 02 7f 00
	ld xbc, EVT_SHOW			; 41 01 00 c0 01
	ld xde, 0:i3				; ea a8
	call (xhl)				; b3 e8
	jr t, .Lfbs_evt_done			; 68 xx

	; Event 0x01EA0008: check entry, toggle flag
.Lfbs_evt_0008:
	ld xwa, xde				; ea 88
	add xwa, 0x00000100			; e8 c8 00 01 00 00
	ld xbc, HDAE5000_RAM_FdList			; 41 54 aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_evt_done			; 6e xx
	; First flag is set: check second flag at +0x0114
	ld xwa, xde				; ea 88
	add xwa, 0x00000114			; e8 c8 14 01 00 00
	ld xbc, HDAE5000_RAM_FdList			; 41 54 aa 22 00
	add xbc, xwa				; e8 81
	cp	(xbc), 0x01
	jr nz, .Lfbs_evt_0008_set1		; 6e xx
	; Second flag is set: clear it to 0
	add xde, 0x00000114			; ea c8 14 01 00 00
	ld xwa, HDAE5000_RAM_FdList			; 40 54 aa 22 00
	add xwa, xde				; ea 80
	ld	(xwa), 0x00
	jr t, .Lfbs_evt_0008_done		; 68 xx

.Lfbs_evt_0008_set1:
	; Second flag not set: set it to 1
	add xde, 0x00000114			; ea c8 14 01 00 00
	ld xwa, HDAE5000_RAM_FdList			; 40 54 aa 22 00
	add xwa, xde				; ea 80
	ld	(xwa), 0x01

.Lfbs_evt_0008_done:
	calr HDAE5000_FdList_Redisplay		; 1e xx xx — self-call
	jr t, .Lfbs_evt_done			; 68 xx

.Lfbs_evt_0002:
	calr HDAE5000_FdList_Redisplay		; 1e xx xx — self-call

.Lfbs_evt_done:
	ld xhl, 0:i3				; eb a8
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
	pushw	HDAE5000_Fmt_2_2d_CopyToHd_Execute@hi16
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
	pushw	HDAE5000_Str_LSW@hi16
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
	pushw	HDAE5000_Str_PMT@hi16
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
	pushw	HDAE5000_Str_SQT@hi16
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
	pushw	HDAE5000_Str_CMP@hi16
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
	pushw	HDAE5000_Str_TM@hi16
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
	pushw	HDAE5000_Str_MSP@hi16
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
	pushw	HDAE5000_Str_RCM@hi16
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
	pushw	HDAE5000_Str_MD@hi16
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
	jr z, .LFSD__post_search
	set	0x07, qiz
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
.LFSD__hA_cyl_calc:			; MT_SelectOK (0x01EA0006): the selected directory
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
	lda xwa, (HDAE5000_RAM_FdList+276:24)
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
.LFSD__hA_sector_info:			; MT_SelectSAVE (0x01EA0008): the selected directory
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
	lda	xwa, (0x23d286:24)
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
	pushw 0xd286
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
; Show the eight delete-option flags (HDAE5000_RAM_DeleteOptions+2..+9) as the
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
	jp (xhl)
	;
	; Part 2: Event handler (0x28A497) — dispatches on event codes
HDAE5000_DelOptSwEventCatch:	.include "includes/generated/cc900/HDAE5000_DelOptSwEventCatch.s"	; C: cc900/hdae5000_fs_screens.c

; --- Display, Menu, and Utility Routines ---
HDAE5000_DelOpt_InitFromSong:	.include "includes/generated/cc900/HDAE5000_DelOpt_InitFromSong.s"	; C: cc900/hdae5000_small2_filesystem.c
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
	pushw	HDAE5000_Fmt_s_DelOptNameCheck@hi16
	pushw	HDAE5000_Fmt_s_DelOptNameCheck@lo16		; low half of HDAE5000_Fmt_s_DelOptNameCheck
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
	lda xhl, (HDAE5000_RAM_SaveOptions+10:24)
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

