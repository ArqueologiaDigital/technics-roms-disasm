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

HDAE5000_FileLBNNameCheck:	.include "includes/generated/cc900/HDAE5000_FileLBNNameCheck.s"	; C: cc900/hdae5000_name_checks_filesystem__lbn_del_r71.c
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
HDAE5000_FlsScreen_Refresh:	.include "includes/generated/cc900/HDAE5000_FlsScreen_Refresh.s"	; C: cc900/hdae5000_fls_refresh.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsScreen_Refresh_Join, HDAE5000_FlsScreen_Refresh + 23
	.set	HDAE5000_FlsScreen_Refresh_Join2, HDAE5000_FlsScreen_Refresh + 251
	.set	HDAE5000_FlsScreen_Refresh_Join3, HDAE5000_FlsScreen_Refresh + 264
	.set	HDAE5000_FlsScreen_Refresh_Loop, HDAE5000_FlsScreen_Refresh + 273
	.set	HDAE5000_FlsScreen_Refresh_Join4, HDAE5000_FlsScreen_Refresh + 461
	.set	HDAE5000_FlsScreen_Refresh_Next, HDAE5000_FlsScreen_Refresh + 488
	.set	HDAE5000_FlsScreen_Refresh_Join5, HDAE5000_FlsScreen_Refresh + 497
	.set	HDAE5000_FlsScreen_Refresh_Join6, HDAE5000_FlsScreen_Refresh + 593
	.set	HDAE5000_FlsScreen_Refresh_Skip, HDAE5000_FlsScreen_Refresh + 671
	.set	HDAE5000_FlsScreen_Refresh_Join7, HDAE5000_FlsScreen_Refresh + 687
	.set	HDAE5000_FlsScreen_Refresh_Skip2, HDAE5000_FlsScreen_Refresh + 857
	.set	HDAE5000_FlsScreen_Refresh_Join8, HDAE5000_FlsScreen_Refresh + 887
	.set	HDAE5000_FlsScreen_Refresh_Epilogue, HDAE5000_FlsScreen_Refresh + 977

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

HDAE5000_FlsLoadScreen:	.include "includes/generated/cc900/HDAE5000_FlsLoadScreen.s"	; C: cc900/hdae5000_fs_screens2__flsload_r2_r85.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	HDAE5000_FlsLoadScreen_OnHdaeSeqStop, HDAE5000_FlsLoadScreen + 116
	.set	HDAE5000_FlsLoadScreen_OnHdaeAfterLoad, HDAE5000_FlsLoadScreen + 157
	.set	HDAE5000_FlsLoadScreen_Join, HDAE5000_FlsLoadScreen + 199
	.set	HDAE5000_FlsLoadScreen_Join2, HDAE5000_FlsLoadScreen + 202
	.set	HDAE5000_FlsLoadScreen_Skip, HDAE5000_FlsLoadScreen + 249
	.set	HDAE5000_FlsLoadScreen_Join3, HDAE5000_FlsLoadScreen + 255
	.set	HDAE5000_FlsLoadScreen_Join4, HDAE5000_FlsLoadScreen + 292
	.set	HDAE5000_FlsLoadScreen_Skip2, HDAE5000_FlsLoadScreen + 329
	.set	HDAE5000_FlsLoadScreen_OnHdaeSelectOk, HDAE5000_FlsLoadScreen + 338
	.set	HDAE5000_FlsLoadScreen_Skip3, HDAE5000_FlsLoadScreen + 412
	.set	HDAE5000_FlsLoadScreen_Join5, HDAE5000_FlsLoadScreen + 418
	.set	HDAE5000_FlsLoadScreen_Join6, HDAE5000_FlsLoadScreen + 455
	.set	HDAE5000_FlsLoadScreen_OnHdaeSelectSave, HDAE5000_FlsLoadScreen + 492
	.set	HDAE5000_FlsLoadScreen_Skip4, HDAE5000_FlsLoadScreen + 560
	.set	HDAE5000_FlsLoadScreen_OnHdaeUnderFlow, HDAE5000_FlsLoadScreen + 630
	.set	HDAE5000_FlsLoadScreen_Skip5, HDAE5000_FlsLoadScreen + 708
	.set	HDAE5000_FlsLoadScreen_OnHdaeOverFlow, HDAE5000_FlsLoadScreen + 762
	.set	HDAE5000_FlsLoadScreen_Skip6, HDAE5000_FlsLoadScreen + 839
	.set	HDAE5000_FlsLoadScreen_OnHdaeChangeSelNum, HDAE5000_FlsLoadScreen + 892
	.set	HDAE5000_FlsLoadScreen_Done, HDAE5000_FlsLoadScreen + 913

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
	ld xwa, HDAE5000_OBJ_ATTEN_CPFD_MARK			; 40 6b 02 7f 00
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
HDAE5000_CopyToHd_Execute:	.include "includes/generated/cc900/HDAE5000_CopyToHd_Execute.s"	; C: cc900/hdae5000_fls_refresh__copytohd_exec_r2_r84.c
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
HDAE5000_DelOptNameCheck:	.include "includes/generated/cc900/HDAE5000_DelOptNameCheck.s"	; C: cc900/hdae5000_name_checks_filesystem__lbn_del_r71.c
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

