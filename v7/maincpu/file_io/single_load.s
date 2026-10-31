; =============================================================================
; file_io/single_load.asm - Single File Load Operations
; =============================================================================
; Single file load mode with source/destination selection.
;
; Key routines:
;   SingleLoadModeFunc               - Single load mode entry
;   SingleLoadDstBankFunc            - Destination bank selection
;   SingleLoadDstMemFunc             - Destination memory selection
;   SingleLoadSrcBankFunc            - Source bank selection
;   SingleLoadSrcMemFunc             - Source memory selection
;   SingleLoadSrcFunc                - Source file selection
;   SingleLoadDstFunc                - Destination selection
;   CmpSingleLoadSrcFunc             - Composer single load source
;   CmpSingleLoadDstFunc             - Composer single load destination
;   CmpSingleLoadFileFunc            - Composer single load file
;   FmmCmpSingleLoadFunc             - Composer single load handler
; =============================================================================

SingleLoadModeFunc:
	cp	xbc, EVT_PAINT
	jr	z, SingleLoadModeFunc_OnPaint
	cp	xbc, EVT_PS_FILE_NAME_BOX_ID
	jr	nz, SLMode_Return
	ld	(33050:16), xde
	jr	SLMode_Return
SingleLoadModeFunc_OnPaint:
	ld	a, (SINGLE_LOAD_AREA:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (StorageArea_NameTable:24)
	ld	xde, (xbc+wa)
	ld	xwa, (33050:16)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SLMode_Return:
	ld xhl, 0:i3
	ret

SingleLoadDstBankFunc:
	cp	xbc, EVT_PAINT
	jr	z, SingleLoadDstBankFunc_OnPaint
	cp	xbc, EVT_PS_FILE_NAME_BOX_ID
	jr	nz, SLDstBank_Return
	ld	(33054:16), xde
	jr	SLDstBank_Return
SingleLoadDstBankFunc_OnPaint:
	ld	a, (SINGLE_LOAD_AREA:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (SingleLoad_BankCaptionByMode:24)
	ld	xde, (xbc+wa)
	ld	xwa, (33054:16)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SLDstBank_Return:
	ld xhl, 0:i3
	ret

SingleLoadDstMemFunc:
	cp	xbc, EVT_PAINT
	jr	z, SingleLoadDstMemFunc_OnPaint
	cp	xbc, EVT_PS_FILE_NAME_BOX_ID
	jr	nz, SLDstMem_Return
	ld	(33058:16), xde
	jr	SLDstMem_Return
SingleLoadDstMemFunc_OnPaint:
	ld	xwa, (0x8122:16)
	lda	xde, (StorageArea_UnitNames:24)
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SLDstMem_ShowFromBank
	cp	(SINGLE_LOAD_AREA:16), 1
	jr	z, SLDstMem_ShowFromBank
	ld	xde, (xde + 16)
	ld	xbc, EVT_PARA_DRAW
	jr	SLDstMem_DispatchShow
SLDstMem_ShowFromBank:
	ld c, (SINGLE_LOAD_AREA:16)

	extz bc

	sla bc, 2

	ld	xde, (xde+bc)

	ld xbc, EVT_PARA_DRAW



SLDstMem_DispatchShow:
	call ApPostEvent

SLDstMem_Return:
	ld xhl, 0:i3
	ret

SingleLoadSrcBankFunc:
	cp	xbc, EVT_PAINT
	jr	z, SingleLoadSrcBankFunc_OnPaint
	cp	xbc, EVT_PS_FILE_NAME_BOX_ID
	jr	nz, SLSrcBank_Return
	ld	(33062:16), xde
	jr	SLSrcBank_Return
SingleLoadSrcBankFunc_OnPaint:
	ld	xwa, (33062:16)
	lda	xde, (SingleLoad_BankCaptionByMode:24)
	ld	c, (SINGLE_LOAD_AREA:16)
	cp	c, 0:i3
	jr	nz, SLSrcBank_ShowFromIndex
	cp	(35182:16), 0
	jr	z, SLSrcBank_ShowFromIndex
	ld	xde, (xde+16)
	ld	xbc, EVT_PARA_DRAW
	jr	SLSrcBank_DispatchShow
SLSrcBank_ShowFromIndex:
	extz bc
	sla bc, 2
	ld	xde, (xde+bc)
	ld xbc, EVT_PARA_DRAW

SLSrcBank_DispatchShow:
	call ApPostEvent

SLSrcBank_Return:
	ld xhl, 0:i3
	ret

SingleLoadSrcMemFunc:
	cp	xbc, EVT_PAINT
	jr	z, SingleLoadSrcMemFunc_OnPaint
	cp	xbc, EVT_PS_FILE_NAME_BOX_ID
	jr	nz, SLSrcMem_Return
	ld	(33066:16), xde
	jr	SLSrcMem_Return
SingleLoadSrcMemFunc_OnPaint:
	ld	xwa, (33066:16)
	lda	xde, (StorageArea_UnitNames:24)
	ld	c, (SINGLE_LOAD_AREA:16)
	cp	c, 1:i3
	jr	z, SLSrcMem_ShowDirect
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SLSrcMem_ShowFromIndex
SLSrcMem_ShowDirect:
	ld xde, (xde + 16)
	ld xbc, EVT_PARA_DRAW
	jr SLSrcMem_DispatchShow

SLSrcMem_ShowFromIndex:
	extz bc
	sla bc, 2
	ld	xde, (xde+bc)
	ld xbc, EVT_PARA_DRAW

SLSrcMem_DispatchShow:
	call ApPostEvent

SLSrcMem_Return:
	ld xhl, 0:i3
	ret
SLSrcBankList_FuncBody:
	dec	6, xsp
	push	xiz
	ld	(xsp+4), c
	ld	(xsp+6), xwa
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+), 0
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoad_BankCaptionByMode:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+1:16)
	ld	xbc, SLSrcBankList_FuncBody_Str_Colon
	call	FileIO_BuildFilePath
	lda	xiz, (SINGLE_LOAD_SRC_ROWS+1:16)
	ld	a, (SLOAD_SRC_PMEM_POS:16)
	extz	wa
	div	wa, (xsp+0x4)
	inc	1, a
	extz	wa
	ld	bc, 0:i3
	calr	NumToAscii_FormatNumber
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+1:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 34994
	call	ApPostEvent
	pop	xiz
	inc	6, xsp
	ret
SLSrcBankList_FuncBody_Helper8:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xwa
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+21), 1
	lda	xiz, (xwa+22)
	ld	a, (SLOAD_SRC_PMEM_POS:16)
	extz	wa
	div	wa, c
	extz	wa
	call	SingleLoadSrc_ReadPmtBankName
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+22:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	pop	xiz
	inc	4, xsp
	ret
SLSrcBankList_FuncBody_Helper9:
	dec	6, xsp
	push	xiz
	ld	(xsp+4), c
	ld	(xsp+6), xwa
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+42), 2
	lda	xwa, (xwa+43)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (StorageArea_UnitNames:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+43:16)
	ld	xbc, SLSrcBankList_FuncBody_Str_Colon_2
	call	FileIO_BuildFilePath
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, SLSrcBankList_FuncBody_Skip
	lda	xiz, (SINGLE_LOAD_SRC_ROWS+43:16)
	ld	a, (SLOAD_SRC_PMEM_POS:16)
	extz	wa
	div	wa, (xsp+0x4)
	ld	a, w
	inc	1, a
	extz	wa
	ld	bc, 0:i3
	calr	NumToAscii_FormatNumber
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_BuildFilePath
SLSrcBankList_FuncBody_Skip:
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xde, (SINGLE_LOAD_SRC_ROWS+42:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SLSrcBankList_FuncBody_Epilogue
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+63), 3
	lda	xwa, (xwa+64)
	ld	xbc, SLSrcBankList_FuncBody_Str_ALL
	call	FileIO_CopyString
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SLSrcBankList_FuncBody_Epilogue:
	pop	xiz
	inc	6, xsp
	ret
SLSrcBankList_FuncBody_Helper10:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xwa
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, SLSrcBankList_FuncBody_Helper10_Epilogue
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+63), 3
	lda	xiz, (xwa+64)
	ld	a, (SLOAD_SRC_PMEM_POS:16)
	extz	wa
	call	SingleLoadSrc_ReadPmtMemoryName
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+64:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SLSrcBankList_FuncBody_Helper10_Epilogue:
	pop	xiz
	inc	4, xsp
	ret
; SingleLoadSrc_PanelMemListProc: Single-load source list for area 0 PANEL MEMORY: EVT_PAINT draws the bank/name rows
;   (SLSrcBankList_FuncBody, _Helper2, _Helper, _Helper3); event parameter 5 pages by SingleLoadSrc_PanelMemBankSize
;   (8) up to 80 (RAM 0x89FC), parameter 6 steps by 1, 40 redraws the pending rows; entry [0] of
;   SingleLoadSrc_ListProcByMode and CmpSingleLoadSrc_ListProcByMode, called with XWA = file-name box, XBC = event,
;   XDE = parameter
SingleLoadSrc_PanelMemListProc:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xde
	ld	xiz, xwa
	cp	xbc, EVT_INDEXSW_DOWN
	jr	z, SingleLoadSrc_PanelMemListProc_Skip2
	cp	xbc, EVT_INDEXSW_UP
	jr	z, SingleLoadSrc_PanelMemListProc_Skip2
	cp	xbc, EVT_PAINT
	jrl	nz, SLSrcBankList_FuncBody_Join4
	cp	(35182:16), 0
	jr	z, SingleLoadSrc_PanelMemListProc_Skip
	ld	a, (SLOAD_SRC_PMEM_POS:16)
	extz	wa
	div	wa, (SingleLoadSrc_PanelMemBankSize:24)
	ld	(SLOAD_SRC_PMEM_POS:16), w
SingleLoadSrc_PanelMemListProc_Skip:
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper9
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper8
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper10
	ld	xwa, 0:i3
	ld	(33070:16), xwa
	ld	(33074:16), 0
	ld	(33076:16), 0
	jrl	SLSrcBankList_FuncBody_Join4
SingleLoadSrc_PanelMemListProc_Skip2:
	ld	e, (SLOAD_SRC_PMEM_POS:16)
	ld	xwa, (xsp+4)
	cp	xwa, 5
	jrl	nz, SingleLoadSrc_PanelMemListProc_Skip5
	cp	(35182:16), 0
	jr	nz, SingleLoadSrc_PanelMemListProc_Skip4
	ld	xix, xbc
	cp	xbc, EVT_INDEXSW_UP
	jr	nz, SingleLoadSrc_PanelMemListProc_Skip3
	ld	l, (SingleLoadSrc_PanelMemBankSize:24)
	ld	a, l
	ld	c, e
	add	a, e
	cp a, (SingleLoadSrc_PanelMemEntryCount:24)
	jr	nc, SingleLoadSrc_PanelMemListProc_Skip3
	add	c, l
	ld	(SLOAD_SRC_PMEM_POS:16), c
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	jr	SingleLoadSrc_PanelMemListProc_Join
SingleLoadSrc_PanelMemListProc_Skip3:
	cp	xix, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadSrc_PanelMemListProc_Skip4
	ld	a, e
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	cp	e, c
	jr	c, SingleLoadSrc_PanelMemListProc_Skip4
	sub	a, c
	ld	(SLOAD_SRC_PMEM_POS:16), a
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
SingleLoadSrc_PanelMemListProc_Join:
	calr	SLSrcBankList_FuncBody_Helper9
	ld	(33076:16), 1
	ld	(33074:16), 1
SingleLoadSrc_PanelMemListProc_Skip4:
	ld	xwa, (33070:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SLSrcBankList_FuncBody_Join4
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jrl	SingleLoadSrc_PanelMemListProc_Join3
SingleLoadSrc_PanelMemListProc_Skip5:
	ld	xwa, (xsp+4)
	cp	xwa, 6
	jrl	nz, SingleLoadSrc_PanelMemListProc_Skip8
	ld	xhl, xbc
	cp	xbc, EVT_INDEXSW_UP
	jr	nz, SingleLoadSrc_PanelMemListProc_Skip6
	ld	c, e
	ld	a, e
	inc	1, a
	cp a, (SingleLoadSrc_PanelMemEntryCount:24)
	jr	nc, SingleLoadSrc_PanelMemListProc_Skip6
	ld	e, (SingleLoadSrc_PanelMemBankSize:24)
	ld	l, e
	ld	a, c
	extz	wa
	div	wa, l
	ld	a, w
	inc	1, a
	cp	a, e
	jr	nc, SingleLoadSrc_PanelMemListProc_Skip7
	inc	1, c
	ld	(SLOAD_SRC_PMEM_POS:16), c
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	jr	SingleLoadSrc_PanelMemListProc_Join2
SingleLoadSrc_PanelMemListProc_Skip6:
	cp	xhl, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadSrc_PanelMemListProc_Skip7
	ld	c, e
	cp	e, 0:i3
	jr	z, SingleLoadSrc_PanelMemListProc_Skip7
	ld	e, (SingleLoadSrc_PanelMemBankSize:24)
	ld	a, c
	extz	wa
	div	wa, e
	ld	a, w
	cp	a, 0:i3
	jr	z, SingleLoadSrc_PanelMemListProc_Skip7
	dec	1, c
	ld	(SLOAD_SRC_PMEM_POS:16), c
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
SingleLoadSrc_PanelMemListProc_Join2:
	calr	SLSrcBankList_FuncBody_Helper9
	ld	(33074:16), 1
SingleLoadSrc_PanelMemListProc_Skip7:
	ld	xwa, (33070:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SLSrcBankList_FuncBody_Join4
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jr	SingleLoadSrc_PanelMemListProc_Join3
SingleLoadSrc_PanelMemListProc_Skip8:
	ld	xwa, (xsp+4)
	cp	xwa, 7
	jr	z, SingleLoadSrc_PanelMemListProc_Skip9
	cp	xwa, 8
	jr	nz, SingleLoadSrc_PanelMemListProc_Skip10
SingleLoadSrc_PanelMemListProc_Skip9:
	ld	xwa, (33070:16)
	cp	xwa, (xsp+0x4)
	jr	z, SLSrcBankList_FuncBody_Join4
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
SingleLoadSrc_PanelMemListProc_Join3:
	call	ApPostEvent
	ld	xwa, (xsp+4)
	ld	(33070:16), xwa
	jr	SLSrcBankList_FuncBody_Join4
SingleLoadSrc_PanelMemListProc_Skip10:
	ld	xwa, (xsp+4)
	cp	xwa, 40
	jr	nz, SLSrcBankList_FuncBody_Join4
	cp	(33076:16), 0
	jr	z, SingleLoadSrc_PanelMemListProc_Join4
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper8
	ld	(33076:16), 0
SingleLoadSrc_PanelMemListProc_Join4:
	cp	(33074:16), 0
	jr	z, SLSrcBankList_FuncBody_Join4
	ld	c, (SingleLoadSrc_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper10
	ld	(33074:16), 0
SLSrcBankList_FuncBody_Join4:
	ld	xhl, 0:i3
	pop	xiz
	inc	4, xsp
	ret
; SingleLoadSrc_SequencerListProc: Single-load source list for area 1 SEQUENCER: EVT_PAINT only -- blank row 0, row 1
;   '<StorageArea_UnitNames[1] SONG>:', row 2 the file's entry 0 name (SingleLoad_SyncSoundMemCursorGroup(0)), blank row
;   3; no paging (one song); entry [1] of SingleLoadSrc_ListProcByMode and CmpSingleLoadSrc_ListProcByMode, called
;   with XWA = file-name box, XBC = event, XDE = parameter
SingleLoadSrc_SequencerListProc:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xwa
	cp	xbc, EVT_PAINT
	jrl	nz, SingleLoadSrc_SequencerListProc_Skip11
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+), 0
	ld	(xwa), 0
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+21), 1
	lda	xwa, (xwa+22)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (StorageArea_UnitNames:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+22:16)
	ld	xbc, SLSrcBankList_FuncBody_Entry_Str_Colon
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+22:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+42), 2
	lda	xiz, (xwa+43)
	ld	wa, 0:i3
	call	SingleLoadSrc_ReadSqtSongName
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+63), 3
	lda	xwa, (xwa+64)
	ld	(xwa), 0
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 34994
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+42:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SingleLoadSrc_SequencerListProc_Skip11:
	ld	xhl, 0:i3
	pop	xiz
	inc	4, xsp
	ret
SLSrcBankList_FuncBody_Helper11:
	dec	2, xsp
	push	xiz
	ld	(xsp+4), c
	ld	xiz, xwa
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+), 0
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoad_BankCaptionByMode:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+1:16)
	ld	xbc, SLSrcBankList_FuncBody_Entry_Str_Colon_2
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+1:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	c, (SLOAD_SRC_CMP_POS:16)
	extz	bc
	div	bc, (xsp+0x4)
	extz	bc
	ld	de, 1:i3
	calr	SingleLoad_GetComposerBankName
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 34994
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	pop	xiz
	inc	2, xsp
	ret
SLSrcBankList_FuncBody_Helper12:
	dec	8, xsp
	push	xiz
	ld	(xsp+6), c
	ld	(xsp+8), xwa
	ld	a, (SLOAD_SRC_CMP_POS:16)
	extz	wa
	div	wa, (xsp+0x6)
	ld	a, w
	extz	wa
	ld	(xsp+4), wa
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+42), 2
	lda	xwa, (xwa+43)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (StorageArea_UnitNames:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+43:16)
	ld	xbc, SLSrcBankList_FuncBody_Entry_Str_Colon_3
	call	FileIO_BuildFilePath
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, SLSrcBankList_FuncBody_Skip14
	lda	xiz, (SINGLE_LOAD_SRC_ROWS+43:16)
	ld	wa, (xsp+4)
	calr	SingleLoad_GetVariationName
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_BuildFilePath
SLSrcBankList_FuncBody_Skip14:
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xde, (SINGLE_LOAD_SRC_ROWS+42:16)
	ld	xwa, (xsp+8)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xbc, (SINGLE_LOAD_SRC_ROWS:16)
	lda	xwa, (xbc+63)
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SingleLoadSrc_SequencerListProc_Skip
	ld	(xwa), 3
	lda	xwa, (xbc+64)
	ld	xbc, SLSrcBankList_FuncBody_Entry_Str_ALL
	call	FileIO_CopyString
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, (xsp+8)
	ld	xbc, EVT_PARA_DRAW
	jr	SLSrcBankList_FuncBody_Join5
SingleLoadSrc_SequencerListProc_Skip:
	cpw	(xsp+0x4), 4
	jr	c, SLSrcBankList_FuncBody_Epilogue3
	ld	c, (SLOAD_SRC_CMP_POS:16)
	extz	bc
	div	bc, (xsp+0x6)
	extz	bc
	pushw 3
	ld	de, (xsp+6)
	calr	SingleLoad_GetComposerSectionName
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, (xsp+8)
	ld	xbc, EVT_PARA_DRAW
SLSrcBankList_FuncBody_Join5:
	call	ApPostEvent
SLSrcBankList_FuncBody_Epilogue3:
	pop	xiz
	inc	8, xsp
	ret
SLSrcBankList_FuncBody_Helper13:
	dec	4, xsp
	push	xiz
	ld	e, c
	ld	(xsp+4), xwa
	ld	a, (SLOAD_SRC_CMP_POS:16)
	extz	wa
	div	wa, e
	ld	c, w
	extz	bc
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, SLSrcBankList_FuncBody_Epilogue4
	cp	bc, 4:i3
	jr	nc, SLSrcBankList_FuncBody_Epilogue4
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+63), 3
	lda	xiz, (xwa+64)
	ld	a, (SLOAD_SRC_CMP_POS:16)
	extz	wa
	div	wa, e
	extz	wa
	call	SingleLoadSrc_ReadCmpPatternName
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+64:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SLSrcBankList_FuncBody_Epilogue4:
	pop	xiz
	inc	4, xsp
	ret
; SingleLoadSrc_ComposerListProc: Single-load source list for area 2 COMPOSER: 30 items laid out in columns of
;   SLSrcComposer_RowsPerColumn (10) -- parameter 5 moves the cursor (RAM 0x89FE) by +-10, parameter 6 by +-1;
;   EVT_PAINT draws via SingleLoadSrc_ReadTmSoundName/_Helper4/_Helper6 (SingleLoad_GetComposerBankName, SingleLoad_GetComposerSectionName); entry
;   [2] of SingleLoadSrc_ListProcByMode and CmpSingleLoadSrc_ListProcByMode, called with XWA = file-name box, XBC =
;   event, XDE = parameter
SingleLoadSrc_ComposerListProc:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xde
	ld	xde, xbc
	ld	xiz, xwa
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	cp	xde, EVT_INDEXSW_DOWN
	jr	z, SingleLoadSrc_ComposerListProc_Skip12
	cp	xde, EVT_INDEXSW_UP
	jr	z, SingleLoadSrc_ComposerListProc_Skip12
	cp	xde, EVT_PAINT
	jrl	nz, SingleLoadSrc_ComposerListProc_Join9
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper12
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper11
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper13
	ld	xwa, 0:i3
	ld	(33078:16), xwa
	jrl	SingleLoadSrc_ComposerListProc_Join8
SingleLoadSrc_ComposerListProc_Skip12:
	ld	l, (SLOAD_SRC_CMP_POS:16)
	ld	xwa, (xsp+4)
	cp	xwa, 5
	jrl	nz, SingleLoadSrc_ComposerListProc_Skip15
	ld	xix, xde
	cp	xde, EVT_INDEXSW_UP
	jr	nz, SingleLoadSrc_ComposerListProc_Skip13
	ld	e, (SLSrcComposer_RowsPerColumn:24)
	ld	a, e
	ld	c, l
	add	a, l
	cp a, (SingleLoadSrc_ComposerEntryCount:24)
	jr	nc, SingleLoadSrc_ComposerListProc_Skip13
	add	c, e
	ld	(SLOAD_SRC_CMP_POS:16), c
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper11
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	ld	xwa, xiz
	jr	SingleLoadSrc_ComposerListProc_Join5
SingleLoadSrc_ComposerListProc_Skip13:
	cp	xix, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadSrc_ComposerListProc_Skip14
	ld	a, l
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	cp	l, c
	jr	c, SingleLoadSrc_ComposerListProc_Skip14
	sub	a, c
	ld	(SLOAD_SRC_CMP_POS:16), a
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper11
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	ld	xwa, xiz
SingleLoadSrc_ComposerListProc_Join5:
	calr	SLSrcBankList_FuncBody_Helper12
	ld	(33082:16), 1
SingleLoadSrc_ComposerListProc_Skip14:
	ld	xwa, (33078:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SingleLoadSrc_ComposerListProc_Join9
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jrl	SingleLoadSrc_ComposerListProc_Join7
SingleLoadSrc_ComposerListProc_Skip15:
	ld	xwa, (xsp+4)
	cp	xwa, 6
	jrl	nz, SingleLoadSrc_ComposerListProc_Skip18
	ld	xix, xde
	cp	xde, EVT_INDEXSW_UP
	jr	nz, SingleLoadSrc_ComposerListProc_Skip16
	ld	c, l
	ld	a, l
	inc	1, a
	cp a, (SingleLoadSrc_ComposerEntryCount:24)
	jr	nc, SingleLoadSrc_ComposerListProc_Skip16
	ld	e, (SLSrcComposer_RowsPerColumn:24)
	ld	l, e
	ld	a, c
	extz	wa
	div	wa, l
	ld	a, w
	inc	1, a
	cp	a, e
	jr	nc, SingleLoadSrc_ComposerListProc_Skip17
	inc	1, c
	ld	(SLOAD_SRC_CMP_POS:16), c
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	ld	xwa, xiz
	jr	SingleLoadSrc_ComposerListProc_Join6
SingleLoadSrc_ComposerListProc_Skip16:
	cp	xix, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadSrc_ComposerListProc_Skip17
	ld	c, l
	cp	l, 0:i3
	jr	z, SingleLoadSrc_ComposerListProc_Skip17
	ld	e, (SLSrcComposer_RowsPerColumn:24)
	ld	a, c
	extz	wa
	div	wa, e
	ld	a, w
	cp	a, 0:i3
	jr	z, SingleLoadSrc_ComposerListProc_Skip17
	dec	1, c
	ld	(SLOAD_SRC_CMP_POS:16), c
	ld	c, (SLSrcComposer_RowsPerColumn:24)
	ld	xwa, xiz
SingleLoadSrc_ComposerListProc_Join6:
	calr	SLSrcBankList_FuncBody_Helper12
	ld	(33082:16), 1
SingleLoadSrc_ComposerListProc_Skip17:
	ld	xwa, (33078:16)
	cp	xwa, (xsp+0x4)
	jr	z, SingleLoadSrc_ComposerListProc_Join9
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jr	SingleLoadSrc_ComposerListProc_Join7
SingleLoadSrc_ComposerListProc_Skip18:
	ld	xwa, (xsp+4)
	cp	xwa, 7
	jr	z, SingleLoadSrc_ComposerListProc_Skip19
	cp	xwa, 8
	jr	nz, SingleLoadSrc_ComposerListProc_Skip20
SingleLoadSrc_ComposerListProc_Skip19:
	ld	xwa, (33078:16)
	cp	xwa, (xsp+0x4)
	jr	z, SingleLoadSrc_ComposerListProc_Join9
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
SingleLoadSrc_ComposerListProc_Join7:
	call	ApPostEvent
	ld	xwa, (xsp+4)
	ld	(33078:16), xwa
	jr	SingleLoadSrc_ComposerListProc_Join9
SingleLoadSrc_ComposerListProc_Skip20:
	ld	xwa, (xsp+4)
	cp	xwa, 40
	jr	nz, SingleLoadSrc_ComposerListProc_Join9
	cp	(33082:16), 0
	jr	z, SingleLoadSrc_ComposerListProc_Join9
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper13
SingleLoadSrc_ComposerListProc_Join8:
	ld	(33082:16), 0
SingleLoadSrc_ComposerListProc_Join9:
	ld	xhl, 0:i3
	pop	xiz
	inc	4, xsp
	ret
; SingleLoad_SyncSoundMemCursorGroup: Keeps the SOUND MEMORY source cursor (XDE = 0x8964) and destination cursor
;   (stack arg = 0x896C) in the same group, below or from 2 x C (C = 20: the 40 sounds vs. the entries from 40 up):
;   when they differ, an XWA = 5/6 move (source list) copies the source index to the destination and redraws
;   SingleLoadDstFunc (EVT_PARA_DRAW), a 7/8 move (destination list) copies the destination index to the source and
;   repaints SingleLoadSrcFunc (EVT_PAINT); retd 4. Basis: callers + body -- SingleLoadSrc_SoundMemListProc
;   (parameters 5/6) and SingleLoadDst_SoundMemListProc (parameters 7/8) call it after every move with XDE = 0x8964,
;   pushed 0x896C and XWA = the parameter.
SingleLoad_SyncSoundMemCursorGroup:
	ld	xix, (xsp+4)
	ld	l, c
	add	l, c
	cp	(xde), l
	jr	nc, SingleLoad_SyncSoundMemCursorGroup_Skip21
	cp	(xix), l
	jr	c, SingleLoad_SyncSoundMemCursorGroup_Return
SingleLoad_SyncSoundMemCursorGroup_Skip21:
	cp	(xde), l
	jr	c, SingleLoad_SyncSoundMemCursorGroup_Skip22
	cp	(xix), l
	jr	nc, SingleLoad_SyncSoundMemCursorGroup_Return
SingleLoad_SyncSoundMemCursorGroup_Skip22:
	cp	xwa, 8
	jr	z, SingleLoad_SyncSoundMemCursorGroup_Skip24
	cp	xwa, 7
	jr	z, SingleLoad_SyncSoundMemCursorGroup_Skip24
	cp	xwa, 6
	jr	z, SingleLoad_SyncSoundMemCursorGroup_Skip23
	cp	xwa, 5
	jr	nz, SingleLoad_SyncSoundMemCursorGroup_Return
SingleLoad_SyncSoundMemCursorGroup_Skip23:
	ld	a, (xde)
	ld	(xix), a
	ld	xwa, 0:i3
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0:i3
	calr	SingleLoadDstFunc
	jr	SingleLoad_SyncSoundMemCursorGroup_Return
SingleLoad_SyncSoundMemCursorGroup_Skip24:
	ld	a, (xix)
	ld	(xde), a
	ld	xwa, 0:i3
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	SingleLoadSrcFunc
SingleLoad_SyncSoundMemCursorGroup_Return:
	retd	0x0004
SLSrcBankList_FuncBody_Helper15:
	dec	6, xsp
	ld	(xsp), c
	ld	(xsp+2), xwa
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+), 0
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoad_BankCaptionByMode:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+1:16)
	ld	xbc, SLSrcBankList_FuncBody_Entry_Str_Colon_4
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+1:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	ld	xwa, (xsp+2)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 34994
	call	ApPostEvent
	ld	a, (xsp)
	add	a, (xsp)
	ld	c, (SLOAD_SRC_SOUND_POS:16)
	cp	c, a
	jr	nc, SLSrcBankList_FuncBody_Epilogue5
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+21:16)
	extz	bc
	div	bc, (xsp)
	extz	bc
	ld	de, 1:i3
	calr	SingleLoad_GetSoundMemBankName
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, (xsp+2)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SLSrcBankList_FuncBody_Epilogue5:
	inc	6, xsp
	ret
SLSrcBankList_FuncBody_Helper16:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xwa
	ld	a, c
	add	a, c
	cp	(SLOAD_SRC_SOUND_POS:16), a
	jr	c, SLSrcBankList_FuncBody_Epilogue6
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+21), 1
	lda	xiz, (xwa+22)
	call	SingleLoadSrc_ReadTmUserKitName
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+22:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SLSrcBankList_FuncBody_Epilogue6:
	pop	xiz
	inc	4, xsp
	ret
SLSrcBankList_FuncBody_Helper17:
	dec	6, xsp
	push	xiz
	ld	(xsp+4), c
	ld	(xsp+6), xwa
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+42), 2
	lda	xwa, (xwa+43)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (StorageArea_UnitNames:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+43:16)
	ld	xbc, SLSrcBankList_FuncBody_Entry_Str_Colon_5
	call	FileIO_BuildFilePath
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, SLSrcBankList_FuncBody_Skip29
	ld	e, (xsp+4)
	add	e, (xsp+0x4)
	ld	c, (SLOAD_SRC_SOUND_POS:16)
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+43:16)
	cp	c, e
	jr	c, SLSrcBankList_FuncBody_Skip28
	ld	xiz, xwa
	sub	c, e
	inc	1, c
	extz	bc
	ld	wa, bc
	ld	bc, 0:i3
	calr	NumToAscii_FormatNumber
	ld	xbc, xhl
	ld	xwa, xiz
	jr	SLSrcBankList_FuncBody_Join11
SLSrcBankList_FuncBody_Skip28:
	ld	xiz, xwa
	extz	bc
	div	bc, (xsp+0x4)
	ld	a, b
	inc	1, a
	extz	wa
	ld	bc, 0:i3
	calr	NumToAscii_FormatNumber
	ld	xbc, xhl
	ld	xwa, xiz
SLSrcBankList_FuncBody_Join11:
	call	FileIO_BuildFilePath
SLSrcBankList_FuncBody_Skip29:
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xde, (SINGLE_LOAD_SRC_ROWS+42:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SLSrcBankList_FuncBody_Epilogue7
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+63), 3
	lda	xwa, (xwa+64)
	ld	xbc, Str_AllOption_EA0980
	call	FileIO_CopyString
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SLSrcBankList_FuncBody_Epilogue7:
	pop	xiz
	inc	6, xsp
	ret
SLSrcBankList_FuncBody_Helper18:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xwa
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, SLSrcBankList_FuncBody_Epilogue8
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	ld	(xwa+63), 3
	ld	e, c
	add	e, c
	lda	xiz, (xwa+64)
	ld	a, (SLOAD_SRC_SOUND_POS:16)
	cp	a, e
	jr	c, SLSrcBankList_FuncBody_Skip30
	sub	a, e
	extz	wa
	call	SingleLoadSrc_ReadTmUserKitEntryName
	ld	xbc, xhl
	ld	xwa, xiz
	jr	SLSrcBankList_FuncBody_Join12
SLSrcBankList_FuncBody_Skip30:
	extz	wa
	call	SingleLoadSrc_ReadTmSoundName
	ld	xbc, xhl
	ld	xwa, xiz
SLSrcBankList_FuncBody_Join12:
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_SRC_ROWS+64:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
SLSrcBankList_FuncBody_Epilogue8:
	pop	xiz
	inc	4, xsp
	ret
; SingleLoadSrc_SoundMemListProc: Single-load source list for area 3 SOUND MEMORY: pages of
;   SingleLoadSrc_SoundMemPageSize (20) over RAM 0x8A00; EVT_PAINT draws via
;   SLSrcBankList_FuncBody_Helper8/_Helper10/_Helper9/_Helper11; entry [3] of SingleLoadSrc_ListProcByMode and
;   CmpSingleLoadSrc_ListProcByMode, called with XWA = file-name box, XBC = event, XDE = parameter
SingleLoadSrc_SoundMemListProc:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xde
	ld	xiz, xwa
	ld	e, (SingleLoadSrc_SoundMemPageSize:24)
	cp	xbc, EVT_INDEXSW_DOWN
	jr	z, SingleLoadSrc_SoundMemListProc_Skip25
	cp	xbc, EVT_INDEXSW_UP
	jr	z, SingleLoadSrc_SoundMemListProc_Skip25
	cp	xbc, EVT_PAINT
	jrl	nz, SLSrcBankList_FuncBody_Join17
	ld	xwa, xiz
	ld	c, e
	calr	SLSrcBankList_FuncBody_Helper15
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper17
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper16
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper18
	ld	xwa, 0:i3
	ld	(33084:16), xwa
	ld	(33088:16), 0
	ld	(33090:16), 0
	jrl	SLSrcBankList_FuncBody_Join17
SingleLoadSrc_SoundMemListProc_Skip25:
	ld	l, (SLOAD_SRC_SOUND_POS:16)
	ld	xwa, (xsp+4)
	cp	xwa, 5
	jrl	nz, SingleLoadSrc_SoundMemListProc_Skip30
	ld	xde, xbc
	cp	xbc, EVT_INDEXSW_UP
	jr	nz, SingleLoadSrc_SoundMemListProc_Skip27
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	w, c
	add	w, c
	ld	a, l
	cp	l, w
	jr	nc, SingleLoadSrc_SoundMemListProc_Skip27
	cp	a, c
	jr	nc, SingleLoadSrc_SoundMemListProc_Skip26
	add	a, c
	ld	(SLOAD_SRC_SOUND_POS:16), a
	jr	SingleLoadSrc_SoundMemListProc_Join12
SingleLoadSrc_SoundMemListProc_Skip26:
	ld	(SLOAD_SRC_SOUND_POS:16), w
SingleLoadSrc_SoundMemListProc_Join12:
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper15
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper17
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
	jr	SingleLoadSrc_SoundMemListProc_Join14
SingleLoadSrc_SoundMemListProc_Skip27:
	cp	xde, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadSrc_SoundMemListProc_Skip29
	ld	c, l
	ld	e, (SingleLoadSrc_SoundMemPageSize:24)
	cp	l, e
	jr	c, SingleLoadSrc_SoundMemListProc_Skip29
	ld	a, e
	add	a, e
	cp	c, a
	jr	nc, SingleLoadSrc_SoundMemListProc_Skip28
	sub	c, e
	ld	(SLOAD_SRC_SOUND_POS:16), c
	jr	SingleLoadSrc_SoundMemListProc_Join13
SingleLoadSrc_SoundMemListProc_Skip28:
	ld	(SLOAD_SRC_SOUND_POS:16), e
SingleLoadSrc_SoundMemListProc_Join13:
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper15
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper17
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
SingleLoadSrc_SoundMemListProc_Join14:
	calr	SingleLoad_SyncSoundMemCursorGroup
	ld	(33090:16), 1
	ld	(33088:16), 1
SingleLoadSrc_SoundMemListProc_Skip29:
	ld	xwa, (33084:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SLSrcBankList_FuncBody_Join17
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jrl	SingleLoadSrc_SoundMemListProc_Join16
SingleLoadSrc_SoundMemListProc_Skip30:
	ld	xwa, (xsp+4)
	cp	xwa, 6
	jrl	nz, SingleLoadSrc_SoundMemListProc_Skip35
	ld	xde, xbc
	cp	xbc, EVT_INDEXSW_UP
	jr	nz, SingleLoadSrc_SoundMemListProc_Skip32
	ld	c, l
	ld	a, l
	inc	1, a
	cp a, (SingleLoadSrc_SoundMemEntryCount:24)
	jr	nc, SingleLoadSrc_SoundMemListProc_Skip32
	ld	e, (SingleLoadSrc_SoundMemPageSize:24)
	ld	a, e
	add	a, e
	cp	c, a
	jr	nc, SingleLoadSrc_SoundMemListProc_Skip31
	ld	l, e
	ld	a, c
	extz	wa
	div	wa, l
	ld	a, w
	inc	1, a
	cp	a, e
	jrl	nc, SingleLoadSrc_SoundMemListProc_Skip34
	inc	1, c
	ld	(SLOAD_SRC_SOUND_POS:16), c
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper17
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
	jrl	SingleLoadSrc_SoundMemListProc_Join15
SingleLoadSrc_SoundMemListProc_Skip31:
	inc	1, c
	ld	(SLOAD_SRC_SOUND_POS:16), c
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper17
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
	jr	SingleLoadSrc_SoundMemListProc_Join15
SingleLoadSrc_SoundMemListProc_Skip32:
	cp	xde, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadSrc_SoundMemListProc_Skip34
	ld	c, l
	cp	l, 0:i3
	jr	z, SingleLoadSrc_SoundMemListProc_Skip34
	ld	e, (SingleLoadSrc_SoundMemPageSize:24)
	ld	a, e
	add	a, e
	cp	c, a
	jr	nc, SingleLoadSrc_SoundMemListProc_Skip33
	ld	a, c
	extz	wa
	div	wa, e
	ld	a, w
	cp	a, 0:i3
	jr	z, SingleLoadSrc_SoundMemListProc_Skip34
	dec	1, c
	ld	(SLOAD_SRC_SOUND_POS:16), c
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper17
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
	jr	SingleLoadSrc_SoundMemListProc_Join15
SingleLoadSrc_SoundMemListProc_Skip33:
	cp	c, a
	jr	ule, SingleLoadSrc_SoundMemListProc_Skip34
	dec	1, c
	ld	(SLOAD_SRC_SOUND_POS:16), c
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper17
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
SingleLoadSrc_SoundMemListProc_Join15:
	calr	SingleLoad_SyncSoundMemCursorGroup
	ld	(33088:16), 1
SingleLoadSrc_SoundMemListProc_Skip34:
	ld	xwa, (33084:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SLSrcBankList_FuncBody_Join17
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jr	SingleLoadSrc_SoundMemListProc_Join16
SingleLoadSrc_SoundMemListProc_Skip35:
	ld	xwa, (xsp+4)
	cp	xwa, 7
	jr	z, SingleLoadSrc_SoundMemListProc_Skip36
	cp	xwa, 8
	jr	nz, SingleLoadSrc_SoundMemListProc_Skip37
SingleLoadSrc_SoundMemListProc_Skip36:
	ld	xwa, (33084:16)
	cp	xwa, (xsp+0x4)
	jr	z, SLSrcBankList_FuncBody_Join17
	lda	xde, (SINGLE_LOAD_SRC_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_SRC_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
SingleLoadSrc_SoundMemListProc_Join16:
	call	ApPostEvent
	ld	xwa, (xsp+4)
	ld	(33084:16), xwa
	jr	SLSrcBankList_FuncBody_Join17
SingleLoadSrc_SoundMemListProc_Skip37:
	ld	xwa, (xsp+4)
	cp	xwa, 40
	jr	nz, SLSrcBankList_FuncBody_Join17
	cp	(33090:16), 0
	jr	z, SingleLoadSrc_SoundMemListProc_Join
	ld	xwa, xiz
	ld	c, e
	calr	SLSrcBankList_FuncBody_Helper16
	ld	(33090:16), 0
SingleLoadSrc_SoundMemListProc_Join:
	cp	(33088:16), 0
	jr	z, SLSrcBankList_FuncBody_Join17
	ld	c, (SingleLoadSrc_SoundMemPageSize:24)
	ld	xwa, xiz
	calr	SLSrcBankList_FuncBody_Helper18
	ld	(33088:16), 0
SLSrcBankList_FuncBody_Join17:
	ld	xhl, 0:i3
	pop	xiz
	inc	4, xsp
	ret
; SingleLoadSrc_BlankListProc: Single-load source list for area 4 (none): on EVT_PAINT writes cell index + empty text
;   into the four 21-byte rows at RAM 0x894E, pads each (TrimAndPadSmfFilename) and posts EVT_PARA_DRAW -- four blank
;   rows; ignores every other event; entry [4] of SingleLoadSrc_ListProcByMode and CmpSingleLoadSrc_ListProcByMode,
;   called with XWA = file-name box, XBC = event, XDE = parameter
SingleLoadSrc_BlankListProc:
	dec	4, xsp
	pushw	iz
	ld	(xsp+2), xwa
	cp	xbc, EVT_PAINT
	jr	nz, SingleLoadSrc_BlankListProc_Skip38
	ld	iz, 0:i3
SingleLoadSrc_BlankListProc_Loop:
	ld	de, iz
	mul	de, 21
	lda	xbc, (SINGLE_LOAD_SRC_ROWS:16)
	ld	hl, de
	extz	xhl
	add	xhl, xbc
	ldto_berp	a, 248
	ld	(xhl), a
	ld	wa, 1:i3
	add	wa, de
	extz	xwa
	add	xwa, xbc
	ld	(xwa), 0
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	ld	de, iz
	mul	de, 21
	lda	xwa, (SINGLE_LOAD_SRC_ROWS:16)
	extz	xde
	add	xde, xwa
	ld	xwa, (xsp+2)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	inc	1, iz
	cp	iz, 4:i3
	jr	c, SingleLoadSrc_BlankListProc_Loop
SingleLoadSrc_BlankListProc_Skip38:
	ld	xhl, 0:i3
	popw	iz
	inc	4, xsp
	ret
SingleLoadSrcFunc:
	dec	4, xsp
	push	xiz
	ld	xiz, xde
	ld	(xsp+4), xbc
	ld	xwa, (xsp+4)
	cp	xwa, EVT_GET_SELECTED_FILE_NUMBER
	jrl	z, SLSrc_ReturnCapture
	cp	xwa, EVT_INDEXSW_DOWN
	jr	z, SLSrc_HandleScroll
	cp	xwa, EVT_INDEXSW_UP
	jr	z, SLSrc_HandleScroll
	cp	xwa, EVT_PAINT
	jr	z, SingleLoadSrcFunc_OnPaint
	cp	xwa, EVT_PS_FILE_NAME_BOX_ID
	jrl	nz, SLSrc_Return
	ld	xwa, xiz
	ld	(33092:16), xwa
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	jrl	SLSrc_Return
SingleLoadSrcFunc_OnPaint:
	ld	xwa, (33092:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33092:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+4)
	ld	xde, xiz
	ld	xhl, (xhl)
	call (xhl)
	calr	SignalProgressUpdate
	jrl	SLSrc_Return
SLSrc_HandleScroll:
	cp	xiz, 5
	jr	nz, SLSrc_ScrollMode6
	cp	(SINGLE_LOAD_AREA:16), 1
	jr	z, SLSrc_ScrollMode5_Prev
	ld	xwa, (33092:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 1:i3
	jr	SLSrc_ScrollMode5_Dispatch
SLSrc_ScrollMode5_Prev:
	ld	xwa, (33092:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
SLSrc_ScrollMode5_Dispatch:
	call	ApPostEvent
	ld	xwa, (33092:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+4)
	ld	xde, xiz
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLSrc_Return
SLSrc_ScrollMode6:
	cp	xiz, 6
	jr	nz, SLSrc_ScrollMode7
	cp	(SINGLE_LOAD_AREA:16), 1
	jr	z, SLSrc_ScrollMode6_NoStep
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, SLSrc_ScrollMode6_NoStep
	ld	xwa, (33092:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 3:i3
	jr	SLSrc_ScrollMode6_Dispatch
SLSrc_ScrollMode6_NoStep:
	ld	xwa, (33092:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
SLSrc_ScrollMode6_Dispatch:
	call	ApPostEvent
	ld	xwa, (33092:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+4)
	ld	xde, xiz
	ld	xhl, (xhl)
	call	(xhl)
	jrl	SLSrc_Return	; -> 0xF8FC5B
SLSrc_ScrollMode7:
	ld	xwa, (33092:16)
	cp	xiz, 7
	jr	nz, SLSrc_ScrollMode8	; -> 0xF8FBFF
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33092:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+4)
	ld	xde, xiz
	ld	xhl, (xhl)
	call	(xhl)
	jr	SLSrc_Return	; -> 0xF8FC5B
SLSrc_ScrollMode8:
	cp	xiz, 8
	jr	nz, SLSrc_ScrollMode40	; -> 0xF8FC37
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33092:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+4)
	ld	xde, xiz
	ld	xhl, (xhl)
	call	(xhl)
	jr	SLSrc_Return	; -> 0xF8FC5B
SLSrc_ScrollMode40:
	cp	xiz, 40
	jr	nz, SLSrc_Return	; -> 0xF8FC5B
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+4)
	ld	xde, xiz
	ld	xhl, (xhl)
	call	(xhl)
SLSrc_Return:
	ld xhl, 0:i3
	jr SLSrc_Epilogue

SLSrc_ReturnCapture:
	ld xhl, 0xffffffff

SLSrc_Epilogue:
	pop xiz
	inc 4, xsp
	ret
SLDstBankList_FuncBody:
	dec	6, xsp
	push	xiz
	ld	(xsp+4), c
	ld	(xsp+6), xwa
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xwa+), 0
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoad_BankCaptionByMode:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+1:16)
	ld	xbc, SLDstBankList_FuncBody_Str_Colon
	call	FileIO_BuildFilePath
	lda	xiz, (SINGLE_LOAD_DST_ROWS+1:16)
	ld	a, (SLOAD_DST_PMEM_POS:16)
	extz	wa
	div	wa, (xsp+0x4)
	inc	1, a
	extz	wa
	ld	bc, 0:i3
	calr	NumToAscii_FormatNumber
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_DST_ROWS+1:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	c, (SLOAD_DST_PMEM_POS:16)
	extz	bc
	div	bc, (xsp+0x4)
	extz	bc
	ld	de, 1:i3
	calr	SingleLoad_GetFileBankName
	lda	xwa, (SINGLE_LOAD_DST_ROWS+22:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 35078
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	pop	xiz
	inc	6, xsp
	ret
SLDstBankList_FuncBody_Helper6:
	dec	6, xsp
	push	xiz
	ld	(xsp+4), c
	ld	(xsp+6), xwa
	lda	xde, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xde+42), 2
	ld	(xde+63), 3
	ld	a, (SINGLE_LOAD_AREA:16)
	extz	wa
	lda	xhl, (StorageArea_UnitNames:24)
	ld	bc, wa
	sla	bc, 2
	lda	xwa, (xde+43)
	ld	xbc, (xhl+bc)
	inc	1, xbc
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SLDstBankList_FuncBody_Skip
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	xbc, SLDstBankList_FuncBody_Str_Colon_2
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_DST_ROWS+64:16)
	ld	xbc, Str_AllOption_EA09B2
	call	FileIO_CopyString
	jr	SLDstBankList_FuncBody_Join
SLDstBankList_FuncBody_Skip:
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	xbc, SLDstBankList_FuncBody_Str_Colon_3
	call	FileIO_BuildFilePath
	lda	xiz, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	a, (SLOAD_DST_PMEM_POS:16)
	extz	wa
	div	wa, (xsp+0x4)
	ld	a, w
	inc	1, a
	extz	wa
	ld	bc, 0:i3
	calr	NumToAscii_FormatNumber
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	c, (SLOAD_DST_PMEM_POS:16)
	extz	bc
	ld	de, 3:i3
	calr	SingleLoad_GetFileMemoryName
SLDstBankList_FuncBody_Join:
	lda	xde, (SINGLE_LOAD_DST_ROWS+42:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	pop	xiz
	inc	6, xsp
	ret
; SingleLoadDst_PanelMemListProc: Single-load destination list for area 0 PANEL MEMORY: banks of
;   SingleLoadDst_PanelMemBankSize (8) up to 80 over RAM 0x8A02 (parameter 7 pages); EVT_PAINT draws
;   SLDstBankList_FuncBody (bank caption + SingleLoad_GetFileBankName) and SLDstBankList_FuncBody_Helper; entry [0] of
;   SingleLoadDst_AreaListProcs and CmpSingleLoadDst_AreaListProcs, called with XWA = file-name box, XBC = event, XDE
;   = parameter
SingleLoadDst_PanelMemListProc:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xde
	ld	xde, xbc
	ld	xiz, xwa
	ld	c, (SingleLoadDst_PanelMemBankSize:24)
	cp	xde, EVT_INDEXSW_DOWN
	jr	z, SingleLoadDst_PanelMemListProc_Skip
	cp	xde, EVT_INDEXSW_UP
	jr	z, SingleLoadDst_PanelMemListProc_Skip
	cp	xde, EVT_PAINT
	jrl	nz, SingleLoadDst_PanelMemListProc_Loop
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody
	ld	c, (SingleLoadDst_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody_Helper6
	ld	xwa, 0:i3
	ld	(33096:16), xwa
	jrl	SingleLoadDst_PanelMemListProc_Loop
SingleLoadDst_PanelMemListProc_Skip:
	ld	l, (SLOAD_DST_PMEM_POS:16)
	ld	xwa, (xsp+4)
	cp	xwa, 7
	jrl	nz, SingleLoadDst_PanelMemListProc_Skip5
	ld	xix, xde
	cp	xde, EVT_INDEXSW_UP
	jr	nz, SingleLoadDst_PanelMemListProc_Skip3
	ld	e, (SingleLoadDst_PanelMemBankSize:24)
	ld	a, e
	ld	c, l
	add	a, l
	cp a, (SLDstBankList_FuncBody_Data_3:24)
	jr	nc, SingleLoadDst_PanelMemListProc_Skip3
	add	c, e
	ld	(SLOAD_DST_PMEM_POS:16), c
	ld	c, (SingleLoadDst_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody
	ld	c, (SingleLoadDst_PanelMemBankSize:24)
	ld	xwa, xiz
	jr	SingleLoadDst_PanelMemListProc_Join2
SingleLoadDst_PanelMemListProc_Skip3:
	cp	xix, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadDst_PanelMemListProc_Skip4
	ld	a, l
	ld	c, (SingleLoadDst_PanelMemBankSize:24)
	cp	l, c
	jr	c, SingleLoadDst_PanelMemListProc_Skip4
	sub	a, c
	ld	(SLOAD_DST_PMEM_POS:16), a
	ld	c, (SingleLoadDst_PanelMemBankSize:24)
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody
	ld	c, (SingleLoadDst_PanelMemBankSize:24)
	ld	xwa, xiz
SingleLoadDst_PanelMemListProc_Join2:
	calr	SLDstBankList_FuncBody_Helper6
SingleLoadDst_PanelMemListProc_Skip4:
	ld	xwa, (33096:16)
	cp	xwa, (xsp+0x4)
	jr	z, SingleLoadDst_PanelMemListProc_Loop
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
SingleLoadDst_PanelMemListProc_Join3:
	call	ApPostEvent
	ld	xwa, (xsp+4)
	ld	(33096:16), xwa
SingleLoadDst_PanelMemListProc_Loop:
	ld	xhl, 0:i3
	jrl	SingleLoadDst_PanelMemListProc_Epilogue
SingleLoadDst_PanelMemListProc_Skip5:
	ld	xwa, (xsp+4)
	cp	xwa, 8
	jrl	nz, SingleLoadDst_PanelMemListProc_Skip8
	ld	xix, xde
	cp	xde, EVT_INDEXSW_UP
	jr	nz, SingleLoadDst_PanelMemListProc_Skip6
	ld	c, l
	ld	a, l
	inc	1, a
	cp a, (SLDstBankList_FuncBody_Data_3:24)
	jr	nc, SingleLoadDst_PanelMemListProc_Skip6
	ld	e, (SingleLoadDst_PanelMemBankSize:24)
	ld	l, e
	ld	a, c
	extz	wa
	div	wa, l
	ld	a, w
	inc	1, a
	cp	a, e
	jr	nc, SingleLoadDst_PanelMemListProc_Skip7
	inc	1, c
	ld	(SLOAD_DST_PMEM_POS:16), c
	ld	c, (SingleLoadDst_PanelMemBankSize:24)
	ld	xwa, xiz
	jr	SingleLoadDst_PanelMemListProc_Join4
SingleLoadDst_PanelMemListProc_Skip6:
	cp	xix, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadDst_PanelMemListProc_Skip7
	ld	c, l
	cp	l, 0:i3
	jr	z, SingleLoadDst_PanelMemListProc_Skip7
	ld	e, (SingleLoadDst_PanelMemBankSize:24)
	ld	a, c
	extz	wa
	div	wa, e
	ld	a, w
	cp	a, 0:i3
	jr	z, SingleLoadDst_PanelMemListProc_Skip7
	dec	1, c
	ld	(SLOAD_DST_PMEM_POS:16), c
	ld	c, (SingleLoadDst_PanelMemBankSize:24)
	ld	xwa, xiz
SingleLoadDst_PanelMemListProc_Join4:
	calr	SLDstBankList_FuncBody_Helper6
SingleLoadDst_PanelMemListProc_Skip7:
	ld	xwa, (33096:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SingleLoadDst_PanelMemListProc_Loop
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jrl	SingleLoadDst_PanelMemListProc_Join3
SingleLoadDst_PanelMemListProc_Skip8:
	ld	xwa, (xsp+4)
	cp	xwa, 5
	jr	z, SingleLoadDst_PanelMemListProc_Skip9
	cp	xwa, 6
	jr	nz, SingleLoadDst_PanelMemListProc_Skip10
SingleLoadDst_PanelMemListProc_Skip9:
	ld	xwa, (33096:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SingleLoadDst_PanelMemListProc_Loop
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jrl	SingleLoadDst_PanelMemListProc_Join3
SingleLoadDst_PanelMemListProc_Skip10:
	ld	xwa, (xsp+4)
	cp	xwa, 10
	jrl	nz, SingleLoadDst_PanelMemListProc_Loop
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SingleLoadDst_PanelMemListProc_Skip2
	ld	a, (SLOAD_SRC_PMEM_POS:16)
	extz	wa
	div	wa, c
	extz	wa
	ld	e, (SLOAD_DST_PMEM_POS:16)
	extz	de
	div	de, c
	extz	de
	ld	bc, de
	call	SingleLoad_LoadPanelMemBank
	exts	xhl
	jr	SingleLoadDst_PanelMemListProc_Epilogue
SingleLoadDst_PanelMemListProc_Skip2:
	ld	a, (SLOAD_SRC_PMEM_POS:16)
	extz	wa
	ld	c, (SLOAD_DST_PMEM_POS:16)
	extz	bc
	call	SingleLoad_LoadPanelMemory
	exts	xhl
SingleLoadDst_PanelMemListProc_Epilogue:
	pop	xiz
	inc	4, xsp
	ret
SLDstBankList_FuncBody_Helper7:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xwa
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xwa+21), 1
	lda	xwa, (xwa+22)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (StorageArea_UnitNames:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+22:16)
	ld	xbc, SLDstMemLabel_ColonSep
	call	FileIO_BuildFilePath
	lda	xiz, (SINGLE_LOAD_DST_ROWS+22:16)
	ld	a, (SLOAD_DST_SONG:16)
	inc	1, a
	extz	wa
	ld	bc, 0:i3
	calr	NumToAscii_FormatNumber
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_DST_ROWS+22:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xiz, (SINGLE_LOAD_DST_ROWS+42:16)
	ld	a, (SLOAD_DST_SONG:16)
	extz	wa
	ld	bc, 2:i3
	ld	de, 0:i3
	calr	BuildSlotLabel
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_CopyString
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+42:16)
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	pop	xiz
	inc	4, xsp
	ret
; SingleLoadDst_SequencerListProc: Single-load destination list for area 1 SEQUENCER: EVT_PAINT blanks rows 0/3 and
;   draws 'SONG: n' + slot label (SLDstBankList_FuncBody_Helper2, BuildSlotLabel); parameter 8 steps the song number
;   RAM 0x8A04 up to SLDstBankList_FuncBody_Data_6; parameter 10 returns SLDstBankList_FuncBody_Helper8(song); entry
;   [1] of SingleLoadDst_AreaListProcs and CmpSingleLoadDst_AreaListProcs, called with XWA = file-name box, XBC =
;   event, XDE = parameter
SingleLoadDst_SequencerListProc:
	push	xiz
	ld	xiz, xwa
	cp	xbc, EVT_INDEXSW_DOWN
	jr	z, SingleLoadDst_SequencerListProc_Skip10
	cp	xbc, EVT_INDEXSW_UP
	jr	z, SingleLoadDst_SequencerListProc_Skip10
	cp	xbc, EVT_PAINT
	jr	nz, SingleLoadDst_SequencerListProc_Loop2
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xwa+), 0
	ld	(xwa), 0
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xwa+63), 3
	lda	xwa, (xwa+64)
	ld	(xwa), 0
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 35078
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	ld	xwa, xiz
	jr	SingleLoadDst_SequencerListProc_Join5
SingleLoadDst_SequencerListProc_Skip10:
	ld	w, (SLOAD_DST_SONG:16)
	lda	xhl, (SINGLE_LOAD_DST_ROWS+42:16)
	cp	xde, 8
	jr	nz, SingleLoadDst_SequencerListProc_Skip13
	ld	xde, xbc
	cp	xde, EVT_INDEXSW_UP
	jr	nz, SingleLoadDst_SequencerListProc_Skip11
	ld	c, w
	ld	a, w
	inc	1, a
	cp a, (SLDstBankList_FuncBody_Data_5:24)
	jr	nc, SingleLoadDst_SequencerListProc_Skip11
	inc	1, c
	ld	(SLOAD_DST_SONG:16), c
	ld	xwa, xiz
SingleLoadDst_SequencerListProc_Join5:
	calr	SLDstBankList_FuncBody_Helper7
SingleLoadDst_SequencerListProc_Loop2:
	ld	xhl, 0:i3
	jr	SingleLoadDst_SequencerListProc_Epilogue2
SingleLoadDst_SequencerListProc_Skip11:
	cp	xde, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadDst_SequencerListProc_Skip12
	ld	a, w
	cp	w, 0:i3
	jr	z, SingleLoadDst_SequencerListProc_Skip12
	dec	1, a
	ld	(SLOAD_DST_SONG:16), a
	ld	xwa, xiz
	jr	SingleLoadDst_SequencerListProc_Join5
SingleLoadDst_SequencerListProc_Skip12:
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	ld	xde, xhl
	jr	SingleLoadDst_SequencerListProc_Join6
SingleLoadDst_SequencerListProc_Skip13:
	cp	xde, 5
	jr	c, SingleLoadDst_SequencerListProc_Skip14
	cp	xde, 7
	jr	ugt, SingleLoadDst_SequencerListProc_Skip14
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	ld	xde, xhl
SingleLoadDst_SequencerListProc_Join6:
	call	ApPostEvent
	jr	SingleLoadDst_SequencerListProc_Loop2
SingleLoadDst_SequencerListProc_Skip14:
	cp	xde, 10
	jr	nz, SingleLoadDst_SequencerListProc_Loop2
	ld	a, (SLOAD_DST_SONG:16)
	extz	wa
	call	SingleLoad_LoadSong
	exts	xhl
SingleLoadDst_SequencerListProc_Epilogue2:
	pop	xiz
	ret
SLDstBankList_FuncBody_Helper8:
	dec	2, xsp
	push	xiz
	ld	(xsp+4), c
	ld	xiz, xwa
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xwa+), 0
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoad_BankCaptionByMode:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+1:16)
	ld	xbc, SLDstBankList_FuncBody_Str_Colon_5
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_DST_ROWS+1:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	c, (SLOAD_DST_CMP_POS:16)
	extz	bc
	div	bc, (xsp+0x4)
	extz	bc
	ld	de, 1:i3
	calr	SingleLoad_GetComposerBankName
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 35078
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	pop	xiz
	inc	2, xsp
	ret
SLDstBankList_FuncBody_Helper9:
	dec	6, xsp
	push	xiz
	ld	(xsp+4), c
	ld	(xsp+6), xwa
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xwa+42), 2
	lda	xwa, (xwa+43)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (StorageArea_UnitNames:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	xbc, SLDstBankList_FuncBody_Str_Colon_6
	call	FileIO_BuildFilePath
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, SLDstBankList_FuncBody_Skip17
	lda	xiz, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	a, (SLOAD_DST_CMP_POS:16)
	extz	wa
	div	wa, (xsp+0x4)
	ld	a, w
	extz	wa
	calr	SingleLoad_GetVariationName
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_BuildFilePath
SLDstBankList_FuncBody_Skip17:
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xbc, (SINGLE_LOAD_DST_ROWS:16)
	lda	xwa, (xbc+63)
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SLDstBankList_FuncBody_Skip18
	ld	(xwa), 3
	lda	xwa, (xbc+64)
	ld	xbc, SLDstBankList_FuncBody_Str_ALL
	call	FileIO_CopyString
	jr	SLDstBankList_FuncBody_Join7
SLDstBankList_FuncBody_Skip18:
	ld	e, (SLOAD_DST_CMP_POS:16)
	ld	c, e
	extz	bc
	div	bc, (xsp+0x4)
	extz	bc
	extz	de
	div	de, (xsp+0x4)
	ld	e, d
	extz	de
	pushw 3
	calr	SingleLoad_GetComposerSectionName
SLDstBankList_FuncBody_Join7:
	lda	xde, (SINGLE_LOAD_DST_ROWS+42:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	pop	xiz
	inc	6, xsp
	ret
; SingleLoadDst_ComposerListProc: Single-load destination list for area 2 COMPOSER: banks of
;   SingleLoadDst_ComposerBankSize (10) up to 30 over RAM 0x8A06; EVT_PAINT draws SLDstBankList_FuncBody_Helper3 and
;   _Helper4; entry [2] of SingleLoadDst_AreaListProcs and CmpSingleLoadDst_AreaListProcs, called with XWA = file-name
;   box, XBC = event, XDE = parameter
SingleLoadDst_ComposerListProc:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xde
	ld	xde, xbc
	ld	xiz, xwa
	ld	c, (SingleLoadDst_ComposerBankSize:24)
	cp	xde, EVT_INDEXSW_DOWN
	jr	z, SingleLoadDst_ComposerListProc_Skip15
	cp	xde, EVT_INDEXSW_UP
	jr	z, SingleLoadDst_ComposerListProc_Skip15
	cp	xde, EVT_PAINT
	jrl	nz, SingleLoadDst_ComposerListProc_Loop3
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody_Helper8
	ld	c, (SingleLoadDst_ComposerBankSize:24)
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody_Helper9
	ld	xwa, 0:i3
	ld	(33100:16), xwa
	jrl	SingleLoadDst_ComposerListProc_Loop3
SingleLoadDst_ComposerListProc_Skip15:
	ld	l, (SLOAD_DST_CMP_POS:16)
	ld	xwa, (xsp+4)
	cp	xwa, 7
	jrl	nz, SingleLoadDst_ComposerListProc_Skip18
	ld	xix, xde
	cp	xde, EVT_INDEXSW_UP
	jr	nz, SingleLoadDst_ComposerListProc_Skip16
	ld	e, (SingleLoadDst_ComposerBankSize:24)
	ld	a, e
	ld	c, l
	add	a, l
	cp a, (SLDstBankList_FuncBody_Data_6:24)
	jr	nc, SingleLoadDst_ComposerListProc_Skip16
	add	c, e
	ld	(SLOAD_DST_CMP_POS:16), c
	ld	c, (SingleLoadDst_ComposerBankSize:24)
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody_Helper8
	ld	c, (SingleLoadDst_ComposerBankSize:24)
	ld	xwa, xiz
	jr	SingleLoadDst_ComposerListProc_Join7
SingleLoadDst_ComposerListProc_Skip16:
	cp	xix, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadDst_ComposerListProc_Skip17
	ld	a, l
	ld	c, (SingleLoadDst_ComposerBankSize:24)
	cp	l, c
	jr	c, SingleLoadDst_ComposerListProc_Skip17
	sub	a, c
	ld	(SLOAD_DST_CMP_POS:16), a
	ld	c, (SingleLoadDst_ComposerBankSize:24)
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody_Helper8
	ld	c, (SingleLoadDst_ComposerBankSize:24)
	ld	xwa, xiz
SingleLoadDst_ComposerListProc_Join7:
	calr	SLDstBankList_FuncBody_Helper9
SingleLoadDst_ComposerListProc_Skip17:
	ld	xwa, (33100:16)
	cp	xwa, (xsp+0x4)
	jr	z, SingleLoadDst_ComposerListProc_Loop3
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
SingleLoadDst_ComposerListProc_Join8:
	call	ApPostEvent
	ld	xwa, (xsp+4)
	ld	(33100:16), xwa
SingleLoadDst_ComposerListProc_Loop3:
	ld	xhl, 0:i3
	jrl	SingleLoadDst_ComposerListProc_Epilogue3
SingleLoadDst_ComposerListProc_Skip18:
	ld	xwa, (xsp+4)
	cp	xwa, 8
	jrl	nz, SingleLoadDst_ComposerListProc_Skip21
	ld	xix, xde
	cp	xde, EVT_INDEXSW_UP
	jr	nz, SingleLoadDst_ComposerListProc_Skip19
	ld	c, l
	ld	a, l
	inc	1, a
	cp a, (SLDstBankList_FuncBody_Data_6:24)
	jr	nc, SingleLoadDst_ComposerListProc_Skip19
	ld	e, (SingleLoadDst_ComposerBankSize:24)
	ld	l, e
	ld	a, c
	extz	wa
	div	wa, l
	ld	a, w
	inc	1, a
	cp	a, e
	jr	nc, SingleLoadDst_ComposerListProc_Skip20
	inc	1, c
	ld	(SLOAD_DST_CMP_POS:16), c
	ld	c, (SingleLoadDst_ComposerBankSize:24)
	ld	xwa, xiz
	jr	SingleLoadDst_ComposerListProc_Join9
SingleLoadDst_ComposerListProc_Skip19:
	cp	xix, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadDst_ComposerListProc_Skip20
	ld	c, l
	cp	l, 0:i3
	jr	z, SingleLoadDst_ComposerListProc_Skip20
	ld	e, (SingleLoadDst_ComposerBankSize:24)
	ld	a, c
	extz	wa
	div	wa, e
	ld	a, w
	cp	a, 0:i3
	jr	z, SingleLoadDst_ComposerListProc_Skip20
	dec	1, c
	ld	(SLOAD_DST_CMP_POS:16), c
	ld	c, (SingleLoadDst_ComposerBankSize:24)
	ld	xwa, xiz
SingleLoadDst_ComposerListProc_Join9:
	calr	SLDstBankList_FuncBody_Helper9
SingleLoadDst_ComposerListProc_Skip20:
	ld	xwa, (33100:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SingleLoadDst_ComposerListProc_Loop3
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jrl	SingleLoadDst_ComposerListProc_Join8
SingleLoadDst_ComposerListProc_Skip21:
	ld	xwa, (xsp+4)
	cp	xwa, 5
	jr	z, SingleLoadDst_ComposerListProc_Skip22
	cp	xwa, 6
	jr	nz, SingleLoadDst_ComposerListProc_Skip23
SingleLoadDst_ComposerListProc_Skip22:
	ld	xwa, (33100:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SingleLoadDst_ComposerListProc_Loop3
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jrl	SingleLoadDst_ComposerListProc_Join8
SingleLoadDst_ComposerListProc_Skip23:
	ld	xwa, (xsp+4)
	cp	xwa, 10
	jrl	nz, SingleLoadDst_ComposerListProc_Loop3
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SingleLoadDst_ComposerListProc_Skip3
	ld	a, (SLOAD_SRC_CMP_POS:16)
	extz	wa
	div	wa, c
	add	a, 30
	extz	wa
	ld	e, (SLOAD_DST_CMP_POS:16)
	extz	de
	div	de, c
	add	e, 30
	extz	de
	ld	bc, de
	jr	SingleLoadDst_ComposerListProc_Join10
SingleLoadDst_ComposerListProc_Skip3:
	ld	a, (SLOAD_SRC_CMP_POS:16)
	extz	wa
	ld	c, (SLOAD_DST_CMP_POS:16)
	extz	bc
SingleLoadDst_ComposerListProc_Join10:
	call	SingleLoad_LoadComposerPattern
	exts	xhl
SingleLoadDst_ComposerListProc_Epilogue3:
	pop	xiz
	inc	4, xsp
	ret
SLDstBankList_FuncBody_Helper10:
	dec	6, xsp
	ld	(xsp), c
	ld	(xsp+2), xwa
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xwa+), 0
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoad_BankCaptionByMode:24)
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+1:16)
	ld	xbc, Data_SaveLoadMenuTable
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_DST_ROWS+1:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	ld	e, (xsp)
	add	e, (xsp)
	ld	c, (SLOAD_DST_SOUND_POS:16)
	lda	xwa, (SINGLE_LOAD_DST_ROWS+21:16)
	cp	c, e
	jr	nc, SLDstBankList_FuncBody_Skip29
	extz	bc
	div	bc, (xsp)
	extz	bc
	ld	de, 1:i3
	calr	SingleLoad_GetSoundMemBankName
	jr	SLDstBankList_FuncBody_Join12
SLDstBankList_FuncBody_Skip29:
	ld	bc, 1:i3
	calr	SingleLoad_GetUserKitName
SLDstBankList_FuncBody_Join12:
	ld	xwa, (xsp+2)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 35078
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, (xsp+2)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	inc	6, xsp
	ret
SingleLoadDst_DrawSoundMemItemRows:
	dec	6, xsp
	push	xiz
	ld	(xsp+4), c
	ld	(xsp+6), xwa
	lda	xde, (StorageArea_UnitNames:24)
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SingleLoadDst_DrawSoundMemItemRows_Skip
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xwa+42), 2
	lda	xwa, (xwa+43)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	xbc, SLDstBankList_FuncBody_Str_Colon_7
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	ld	(xwa+63), 3
	lda	xwa, (xwa+64)
	ld	xbc, SLDstBankList_FuncBody_Str_ALL_2
	call	FileIO_CopyString
	jrl	SingleLoadDst_DrawSoundMemItemRows_Join
SingleLoadDst_DrawSoundMemItemRows_Skip:
	ld	l, (xsp+4)
	add	l, (xsp+0x4)
	lda	xbc, (SINGLE_LOAD_DST_ROWS:16)
	lda	xwa, (xbc+43)
	ld	(xbc+42), 2
	cp	(SLOAD_DST_SOUND_POS:16), l
	jr	c, SingleLoadDst_DrawSoundMemItemRows_Skip2
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	xbc, SLDstBankList_FuncBody_Str_Colon_8
	call	FileIO_BuildFilePath
	lda	xiz, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	c, (xsp+4)
	add	c, (xsp+0x4)
	ld	a, (SLOAD_DST_SOUND_POS:16)
	sub	a, c
	inc	1, a
	extz	wa
	ld	bc, 0:i3
	calr	NumToAscii_FormatNumber
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	e, (xsp+4)
	add	e, (xsp+0x4)
	ld	c, (SLOAD_DST_SOUND_POS:16)
	sub	c, e
	extz	bc
	ld	de, 3:i3
	calr	SingleLoad_GetUserKitEntryName
	jr	SingleLoadDst_DrawSoundMemItemRows_Join
SingleLoadDst_DrawSoundMemItemRows_Skip2:
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	ld	xbc, (xde+bc)
	inc	1, xbc
	call	FileIO_CopyString
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	xbc, SLDstBankList_FuncBody_Str_Colon_9
	call	FileIO_BuildFilePath
	lda	xiz, (SINGLE_LOAD_DST_ROWS+43:16)
	ld	a, (SLOAD_DST_SOUND_POS:16)
	extz	wa
	div	wa, (xsp+0x4)
	ld	a, w
	inc	1, a
	extz	wa
	ld	bc, 0:i3
	calr	NumToAscii_FormatNumber
	ld	xbc, xhl
	ld	xwa, xiz
	call	FileIO_BuildFilePath
	lda	xwa, (SINGLE_LOAD_DST_ROWS+43:16)
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	lda	xwa, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	c, (SLOAD_DST_SOUND_POS:16)
	extz	bc
	ld	de, 3:i3
	calr	SingleLoad_GetSoundRamName
SingleLoadDst_DrawSoundMemItemRows_Join:
	lda	xde, (SINGLE_LOAD_DST_ROWS+42:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, (xsp+6)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	pop	xiz
	inc	6, xsp
	ret
; SingleLoadDst_SoundMemListProc: Single-load destination list for area 3 SOUND MEMORY: columns of
;   SLDstSoundMem_RowsPerColumn (20) over RAM 0x8A08 (parameter 7 moves +-20); EVT_PAINT draws
;   SLDstBankList_FuncBody_Helper5 and _Helper6; entry [3] of SingleLoadDst_AreaListProcs and
;   CmpSingleLoadDst_AreaListProcs, called with XWA = file-name box, XBC = event, XDE = parameter
SingleLoadDst_SoundMemListProc:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xde
	ld	xiz, xwa
	ld	e, (SLDstSoundMem_RowsPerColumn:24)
	cp	xbc, EVT_INDEXSW_DOWN
	jr	z, SingleLoadDst_SoundMemListProc_Skip24
	cp	xbc, EVT_INDEXSW_UP
	jr	z, SingleLoadDst_SoundMemListProc_Skip24
	cp	xbc, EVT_PAINT
	jrl	nz, SingleLoadDst_SoundMemListProc_Loop4
	ld	xwa, xiz
	ld	c, e
	calr	SLDstBankList_FuncBody_Helper10
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SingleLoadDst_DrawSoundMemItemRows
	ld	xwa, 0:i3
	ld	(33104:16), xwa
	jrl	SingleLoadDst_SoundMemListProc_Loop4
SingleLoadDst_SoundMemListProc_Skip24:
	ld	l, (SLOAD_DST_SOUND_POS:16)
	ld	xwa, (xsp+4)
	cp	xwa, 7
	jrl	nz, SingleLoadDst_SoundMemListProc_Skip29
	ld	xde, xbc
	cp	xbc, EVT_INDEXSW_UP
	jr	nz, SingleLoadDst_SoundMemListProc_Skip26
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	w, c
	add	w, c
	ld	a, l
	cp	l, w
	jr	nc, SingleLoadDst_SoundMemListProc_Skip26
	cp	a, c
	jr	nc, SingleLoadDst_SoundMemListProc_Skip25
	add	a, c
	ld	(SLOAD_DST_SOUND_POS:16), a
	jr	SingleLoadDst_SoundMemListProc_Join12
SingleLoadDst_SoundMemListProc_Skip25:
	ld	(SLOAD_DST_SOUND_POS:16), w
SingleLoadDst_SoundMemListProc_Join12:
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody_Helper10
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SingleLoadDst_DrawSoundMemItemRows
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
	jr	SingleLoadDst_SoundMemListProc_Join14
SingleLoadDst_SoundMemListProc_Skip26:
	cp	xde, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadDst_SoundMemListProc_Skip28
	ld	c, l
	ld	e, (SLDstSoundMem_RowsPerColumn:24)
	cp	l, e
	jr	c, SingleLoadDst_SoundMemListProc_Skip28
	ld	a, e
	add	a, e
	cp	c, a
	jr	nc, SingleLoadDst_SoundMemListProc_Skip27
	sub	c, e
	ld	(SLOAD_DST_SOUND_POS:16), c
	jr	SingleLoadDst_SoundMemListProc_Join13
SingleLoadDst_SoundMemListProc_Skip27:
	cp	c, a
	jr	c, SingleLoadDst_SoundMemListProc_Join13
	ld	(SLOAD_DST_SOUND_POS:16), e
SingleLoadDst_SoundMemListProc_Join13:
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SLDstBankList_FuncBody_Helper10
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SingleLoadDst_DrawSoundMemItemRows
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
SingleLoadDst_SoundMemListProc_Join14:
	calr	SingleLoad_SyncSoundMemCursorGroup
SingleLoadDst_SoundMemListProc_Skip28:
	ld	xwa, (33104:16)
	cp	xwa, (xsp+0x4)
	jr	z, SingleLoadDst_SoundMemListProc_Loop4
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
SingleLoadDst_SoundMemListProc_Join15:
	call	ApPostEvent
	ld	xwa, (xsp+4)
	ld	(33104:16), xwa
SingleLoadDst_SoundMemListProc_Loop4:
	ld	xhl, 0:i3
	jrl	SingleLoadDst_SoundMemListProc_Epilogue4
SingleLoadDst_SoundMemListProc_Skip29:
	ld	xwa, (xsp+4)
	cp	xwa, 8
	jrl	nz, SingleLoadDst_SoundMemListProc_Skip34
	ld	xde, xbc
	cp	xbc, EVT_INDEXSW_UP
	jr	nz, SingleLoadDst_SoundMemListProc_Skip31
	ld	c, l
	ld	a, l
	inc	1, a
	cp a, (SLDstBankList_FuncBody_Data_7:24)
	jr	nc, SingleLoadDst_SoundMemListProc_Skip31
	ld	e, (SLDstSoundMem_RowsPerColumn:24)
	ld	a, e
	add	a, e
	cp	c, a
	jr	nc, SingleLoadDst_SoundMemListProc_Skip30
	ld	l, e
	ld	a, c
	extz	wa
	div	wa, l
	ld	a, w
	inc	1, a
	cp	a, e
	jrl	nc, SingleLoadDst_SoundMemListProc_Skip33
	inc	1, c
	ld	(SLOAD_DST_SOUND_POS:16), c
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SingleLoadDst_DrawSoundMemItemRows
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
	jrl	SingleLoadDst_SoundMemListProc_Join16
SingleLoadDst_SoundMemListProc_Skip30:
	inc	1, c
	ld	(SLOAD_DST_SOUND_POS:16), c
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SingleLoadDst_DrawSoundMemItemRows
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
	jr	SingleLoadDst_SoundMemListProc_Join16
SingleLoadDst_SoundMemListProc_Skip31:
	cp	xde, EVT_INDEXSW_DOWN
	jr	nz, SingleLoadDst_SoundMemListProc_Skip33
	ld	c, l
	cp	l, 0:i3
	jr	z, SingleLoadDst_SoundMemListProc_Skip33
	ld	e, (SLDstSoundMem_RowsPerColumn:24)
	ld	a, e
	add	a, e
	cp	c, a
	jr	nc, SingleLoadDst_SoundMemListProc_Skip32
	ld	a, c
	extz	wa
	div	wa, e
	ld	a, w
	cp	a, 0:i3
	jr	z, SingleLoadDst_SoundMemListProc_Skip33
	dec	1, c
	ld	(SLOAD_DST_SOUND_POS:16), c
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SingleLoadDst_DrawSoundMemItemRows
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
	jr	SingleLoadDst_SoundMemListProc_Join16
SingleLoadDst_SoundMemListProc_Skip32:
	cp	c, a
	jr	ule, SingleLoadDst_SoundMemListProc_Skip33
	dec	1, c
	ld	(SLOAD_DST_SOUND_POS:16), c
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	ld	xwa, xiz
	calr	SingleLoadDst_DrawSoundMemItemRows
	ld	c, (SLDstSoundMem_RowsPerColumn:24)
	pushw 0
	pushw 35180
	ld	xwa, (xsp+8)
	ld	xde, 35172
SingleLoadDst_SoundMemListProc_Join16:
	calr	SingleLoad_SyncSoundMemCursorGroup
SingleLoadDst_SoundMemListProc_Skip33:
	ld	xwa, (33104:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SingleLoadDst_SoundMemListProc_Loop4
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jrl	SingleLoadDst_SoundMemListProc_Join15
SingleLoadDst_SoundMemListProc_Skip34:
	ld	xwa, (xsp+4)
	cp	xwa, 5
	jr	z, SingleLoadDst_SoundMemListProc_Skip35
	cp	xwa, 6
	jr	nz, SingleLoadDst_SoundMemListProc_Skip36
SingleLoadDst_SoundMemListProc_Skip35:
	ld	xwa, (33104:16)
	cp	xwa, (xsp+0x4)
	jrl	z, SingleLoadDst_SoundMemListProc_Loop4
	lda	xde, (SINGLE_LOAD_DST_ROWS+21:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	lda	xde, (SINGLE_LOAD_DST_ROWS+63:16)
	ld	xwa, xiz
	ld	xbc, EVT_PARA_DRAW
	jrl	SingleLoadDst_SoundMemListProc_Join15
SingleLoadDst_SoundMemListProc_Skip36:
	ld	xwa, (xsp+4)
	cp	xwa, 10
	jrl	nz, SingleLoadDst_SoundMemListProc_Loop4
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	z, SingleLoadDst_SoundMemListProc_Skip3
	ld	a, (SLOAD_SRC_SOUND_POS:16)
	extz	wa
	div	wa, e
	extz	wa
	ld	c, (SLOAD_DST_SOUND_POS:16)
	extz	bc
	div	bc, e
	extz	bc
	call	SingleLoad_LoadSoundMemBank
	exts	xhl
	jr	SingleLoadDst_SoundMemListProc_Epilogue4
SingleLoadDst_SoundMemListProc_Skip3:
	ld	a, (SLOAD_SRC_SOUND_POS:16)
	extz	wa
	ld	c, (SLOAD_DST_SOUND_POS:16)
	extz	bc
	call	SingleLoad_LoadSoundMemEntry
	exts	xhl
SingleLoadDst_SoundMemListProc_Epilogue4:
	pop	xiz
	inc	4, xsp
	ret
SingleLoadDst_BlankListProc:
	dec	4, xsp
	pushw	iz
	ld	(xsp+2), xwa
	cp	xbc, EVT_PAINT
	jr	nz, SingleLoadDst_BlankListProc_Skip37
	ld	iz, 0:i3
SingleLoadDst_BlankListProc_Loop5:
	ld	de, iz
	mul	de, 21
	lda	xbc, (SINGLE_LOAD_DST_ROWS:16)
	ld	hl, de
	extz	xhl
	add	xhl, xbc
	ldto_berp	a, 248
	ld	(xhl), a
	ld	wa, 1:i3
	add	wa, de
	extz	xwa
	add	xwa, xbc
	ld	(xwa), 0
	ldw	bc, 16
	calr	TrimAndPadSmfFilename
	ld	de, iz
	mul	de, 21
	lda	xwa, (SINGLE_LOAD_DST_ROWS:16)
	extz	xde
	add	xde, xwa
	ld	xwa, (xsp+2)
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	inc	1, iz
	cp	iz, 4:i3
	jr	c, SingleLoadDst_BlankListProc_Loop5
SingleLoadDst_BlankListProc_Skip37:
	ld	xhl, 0:i3
	popw	iz
	inc	4, xsp
	ret
SingleLoadDstFunc:
	dec	8, xsp
	push	xiz
	ld	(xsp+4), xde
	ld	(xsp+8), xbc
	ld	xiz, xwa
	ld	xwa, (xsp+8)
	cp	xwa, EVT_GET_SELECTED_FILE_NUMBER
	jrl	z, SLDst_ReturnCapture
	cp	xwa, EVT_INDEXSW_DOWN
	jrl	z, SLDst_HandleScroll
	cp	xwa, EVT_INDEXSW_UP
	jrl	z, SLDst_HandleScroll
	cp	xwa, EVT_PARA_DRAW
	jrl	z, SLDst_HandleConfirm
	cp	xwa, EVT_PAINT
	jr	z, SingleLoadDstFunc_OnPaint
	cp	xwa, EVT_PS_FILE_NAME_BOX_ID
	jr	nz, SLDst_Return
	ld	xwa, (xsp+4)
	ld	(33108:16), xwa
	ld	wa, 0:i3
	calr	InitializeOperationState
	calr	SignalProgressUpdate
	calr	SingleLoad_ScanAreas
	calr	SignalProgressUpdate
	cp	(SINGLE_LOAD_AREA:16), 1
	jr	z, SLDst_ShowHide_Internal
	ld	xwa, 6357066
	ld	xbc, EVT_SET_VISIBLE
	ld	xde, 1:i3
	jr	SLDst_ShowHide_Dispatch
SLDst_ShowHide_Internal:
	ld xwa, 0x61004a
	ld xbc, EVT_SET_VISIBLE
	ld xde, 0:i3

SLDst_ShowHide_Dispatch:
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	cp	(SINGLE_LOAD_AREA:16), 0
	jr	nz, SLDst_ClearFloppyFlag
	call	FileIO_ValidateWithExtHeader
	cp	hl, 0:i3
	jr	z, SLDst_ClearFloppyFlag
	ld	(35182:16), 1
	jr	SLDst_Return
SLDst_ClearFloppyFlag:
	ld	(35182:16), 0
SLDst_Return:
	ld xhl, 0:i3
	jrl SLDst_Epilogue
SingleLoadDstFunc_OnPaint:
	ld	xwa, xiz
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	calr	SingleLoadModeFunc
	ld	xwa, xiz
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	calr	SingleLoadSrcBankFunc
	ld	xwa, xiz
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	calr	SingleLoadSrcMemFunc
	ld	xwa, xiz
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	calr	SingleLoadDstBankFunc
	ld	xwa, xiz
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	calr	SingleLoadDstMemFunc
	ld	xwa, (33108:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, 6357046
	ld	xbc, EVT_SET_PARAM
	ld	xde, 0:i3
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLDst_Return
SLDst_HandleConfirm:
	ld	xwa, (33108:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLDst_Return
SLDst_HandleScroll:
	ld	xwa, (xsp+4)
	cp	xwa, 3
	jr	nz, SLDst_ScrollMode4
	cp	(SINGLE_LOAD_AREA:16), 1
	jr	z, SLDst_ScrollMode4
	ld	xwa, (xsp+8)
	cp	xwa, EVT_INDEXSW_UP
	scc	z, a
	ld	(SINGLE_LOAD_ALL:16), a
	ld	xwa, xiz
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	SingleLoadSrcMemFunc
	ld	xwa, xiz
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	SingleLoadDstMemFunc
	ld	xwa, (33108:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, 6357046
	ld	xbc, EVT_SET_PARAM
	ld	xde, 0:i3
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	ld	xhl, (xhl)
	call (xhl)
	ld	xwa, xiz
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	jrl	SLDst_ScrollMode3_CallSrcMem
SLDst_ScrollMode4:
	ld	xwa, (xsp+4)
	cp	xwa, 4
	jrl	nz, SLDst_ScrollDispatch
	calr	SingleLoad_FindNextArea
	cp	l, 0:i3
	jrl	z, SLDst_Return
	cp	(SINGLE_LOAD_AREA:16), 1
	jr	z, SLDst_ScrollMode4_Internal
	ld	xwa, 6357066
	ld	xbc, EVT_SET_VISIBLE
	ld	xde, 1:i3
	jr	SLDst_ScrollMode4_Dispatch
SLDst_ScrollMode4_Internal:
	ld xwa, 0x61004a
	ld xbc, EVT_SET_VISIBLE
	ld xde, 0:i3

SLDst_ScrollMode4_Dispatch:
	call	ApPostEvent
	ld	xwa, xiz
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	SingleLoadModeFunc
	ld	xwa, xiz
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	SingleLoadSrcBankFunc
	ld	xwa, xiz
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	SingleLoadSrcMemFunc
	ld	xwa, xiz
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	SingleLoadDstBankFunc
	ld	xwa, xiz
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	SingleLoadDstMemFunc
	ld	xwa, (33108:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, 6357046
	ld	xbc, EVT_SET_PARAM
	ld	xde, 0:i3
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	ld	xhl, (xhl)
	call	(xhl)
	ld	xwa, xiz
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
SLDst_ScrollMode3_CallSrcMem:
	calr SingleLoadSrcFunc
	jrl SLDst_Return
SLDst_ScrollDispatch:
	ld	xwa, (xsp+4)
	cp	xwa, 10
	jr	nz, SLDst_Scroll_ChildReturn
	cp	(SINGLE_LOAD_AREA:16), 4
	jr	z, SLDst_Scroll_ChildReturn
	ld	xwa, 6291494
	ld	xbc, EVT_SHOW
	ld	xde, 5:i3
	call	ApPostEvent
	ld	wa, 0:i3
	calr	InitializeOperationState
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xix, (xhl)
	call (xix)
	ld	wa, hl
	ld	bc, 1:i3
	calr	FileIO_ValidateSignedValue
	ld	(GLOBAL_ERROR_CODE:16), l
	ld	xwa, 6291494
	ld	xbc, EVT_HIDE
	ld	xde, 0:i3
	call	ApPostEvent
	ldw	wa, TT_MESAGE
	call	UI_InterruptTitleByIndex
	jrl	SLDst_Return
SLDst_Scroll_ChildReturn:
	ld	xwa, (xsp+4)
	cp	xwa, 7
	jr	nz, SLDst_Scroll_SubMode2
	cp	(SINGLE_LOAD_AREA:16), 1
	jr	z, SLDst_Scroll_SubMode
	ld	xwa, (33108:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 1:i3
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLDst_Return
SLDst_Scroll_SubMode:
	ld	xwa, (33108:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLDst_Return
SLDst_Scroll_SubMode2:
	ld	xwa, (33108:16)
	ld	xbc, (xsp+4)
	cp	xbc, 8
	jrl	nz, SLDst_Scroll_SubMode5
	cp	(SINGLE_LOAD_AREA:16), 1
	jr	nz, SLDst_Scroll_SubMode3
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 2:i3
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLDst_Return
SLDst_Scroll_SubMode3:
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, SLDst_Scroll_SubMode4
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 3:i3
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLDst_Return
SLDst_Scroll_SubMode4:
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLDst_Return
SLDst_Scroll_SubMode5:
	ld	xbc, (xsp+4)
	cp	xbc, 5
	jr	nz, SLDst_Scroll_SubMode6
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLDst_Return
SLDst_Scroll_SubMode6:
	ld	xbc, (xsp+4)
	cp	xbc, 6
	jrl	nz, SLDst_Return
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33108:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (SingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call (xhl)
	jrl	SLDst_Return
SLDst_ReturnCapture:
	ld xhl, 0xffffffff

SLDst_Epilogue:
	pop xiz
	inc 8, xsp
	ret

CmpSingleLoadSrcFunc:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xde
	ld	xiz, xbc
	cp	xiz, EVT_GET_SELECTED_FILE_NUMBER
	jrl	z, CmpSrc_ReturnCapture
	cp	xiz, EVT_INDEXSW_DOWN
	jr	z, CmpSrc_HandleScroll
	cp	xiz, EVT_INDEXSW_UP
	jr	z, CmpSrc_HandleScroll
	cp	xiz, EVT_PAINT
	jr	z, CmpSrc_HandleShow
	cp	xiz, EVT_PS_FILE_NAME_BOX_ID
	jrl	nz, CmpSrc_Return
	ld	xwa, (xsp+4)
	ld	(33112:16), xwa
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	jrl	CmpSrc_Return
CmpSrc_HandleShow:
	ld	xwa, (33112:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33112:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (CmpSingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, xiz
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call	(xhl)
	jrl	CmpSrc_Return	; -> 0xF9105C
CmpSrc_HandleScroll:
	ld	xwa, (xsp+4)
	cp	xwa, 5
	jr	nz, CmpSrc_ScrollMode6	; -> 0xF90F3B
	ld	xwa, (33112:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 1:i3
	call	ApPostEvent
	ld	xwa, (33112:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (CmpSingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, xiz
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call	(xhl)
	jrl	CmpSrc_Return	; -> 0xF9105C
CmpSrc_ScrollMode6:
	ld	xwa, (xsp + 4)
	cp	xwa, 0x6
	jr	nz, CmpSrc_ScrollMode7
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, CmpSrc_ScrollMode6_NoStep
	ld	xwa, (0x8158:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 3:i3
	call	ApPostEvent
	ld	xwa, (0x8158:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (CmpSingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, xiz
	ld	xde, (xsp + 4)
	ld	xhl, (xhl)
	call	(xhl)
	jrl	CmpSrc_Return
CmpSrc_ScrollMode6_NoStep:
	ld	xwa, (33112:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33112:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (CmpSingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, xiz
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call	(xhl)
	jrl	CmpSrc_Return	; -> 0xF9105C
CmpSrc_ScrollMode7:
	ld	xwa, (33112:16)
	ld	xbc, (xsp+4)
	cp	xbc, 7
	jr	nz, CmpSrc_ScrollMode8	; -> 0xF90FF3
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, (33112:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (CmpSingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, xiz
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call	(xhl)
	jr	CmpSrc_Return	; -> 0xF9105C
CmpSrc_ScrollMode8:
	ld	xbc, (xsp + 4)
	cp	xbc, 0x8
	jr	nz, CmpSrc_ScrollMode40
	cp	(SINGLE_LOAD_ALL:16), 0
	jr	nz, CmpSrc_ScrollMode40
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 0xffffffff
	call	ApPostEvent
	ld	xwa, (0x8158:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (CmpSingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, xiz
	ld	xde, (xsp + 4)
	ld	xhl, (xhl)
	call	(xhl)
	jr	CmpSrc_Return
CmpSrc_ScrollMode40:
	ld	xbc, (xsp+4)
	cp	xbc, 40
	jr	nz, CmpSrc_Return	; -> 0xF9105C
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (CmpSingleLoadSrc_ListProcByMode:24)
	lda	xhl, (xde+bc)
	ld	xbc, xiz
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call	(xhl)
CmpSrc_Return:
	ld xhl, 0:i3
	jr CmpSrc_Epilogue

CmpSrc_ReturnCapture:
	ld xhl, 0xffffffff

CmpSrc_Epilogue:
	pop xiz
	inc 4, xsp
	ret

CmpSingleLoadDstFunc:
	dec	8, xsp
	push	xiz
	ld	(xsp+4), xde
	ld	(xsp+8), xbc
	ld	xiz, xwa
	ld	xwa, (xsp+8)
	cp	xwa, EVT_GET_SELECTED_FILE_NUMBER
	jrl	z, CmpDst_ReturnCapture
	cp	xwa, EVT_INDEXSW_DOWN
	jrl	z, CmpDst_HandleScroll
	cp	xwa, EVT_INDEXSW_UP
	jrl	z, CmpDst_HandleScroll
	cp	xwa, EVT_PAINT
	jr	z, CmpSingleLoadDstFunc_OnPaint
	cp	xwa, EVT_PS_FILE_NAME_BOX_ID
	jrl	nz, CmpDst_Return
	ld	xwa, (xsp+4)
	ld	(33116:16), xwa
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	jrl	CmpDst_Return
CmpSingleLoadDstFunc_OnPaint:
	ld	xwa, xiz
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	calr	SingleLoadSrcMemFunc
	ld	xwa, xiz
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	calr	SingleLoadSrcBankFunc
	ld	xwa, xiz
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	calr	SingleLoadDstMemFunc
	ld	xwa, xiz
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	calr	SingleLoadDstBankFunc
	ld	xwa, (33116:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	call	ApPostEvent
	ld	xwa, 6357118
	ld	xbc, EVT_SET_PARAM
	ld	xde, 0:i3
	call	ApPostEvent
	ld	xwa, (33116:16)
	ld	c, (SINGLE_LOAD_AREA:16)
	extz	bc
	sla	bc, 2
	lda	xde, (CmpSingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld	xbc, (xsp+8)
	ld	xde, (xsp+4)
	ld	xhl, (xhl)
	call	(xhl)
	jrl	CmpDst_Return	; -> 0xF91350
CmpDst_HandleScroll:
	ld XWA,(XSP+0x04)
	cp XWA,0x00000003
	jr nz, .Lc_f911b2
	ld XWA,(XSP+0x08)
	cp XWA,EVT_INDEXSW_UP
	scc Z,A
	ld (SINGLE_LOAD_ALL:16), a
	ld XWA,XIZ
	ld XBC,EVT_PAINT
	ld xde, 0:i3
	calr SingleLoadSrcMemFunc
	ld XWA,XIZ
	ld XBC,EVT_PAINT
	ld xde, 0:i3
	calr SingleLoadDstMemFunc
	ld xwa, (0x815c:16)
	ld XBC,EVT_SET_SELECTED_FILE_NUMBER
	ld XDE,0xffffffff
	call ApPostEvent
	ld XWA,0x0061007e
	ld XBC,EVT_SET_PARAM
	ld xde, 0:i3
	call ApPostEvent
	ld xwa, (0x815c:16)
	ld c, (SINGLE_LOAD_AREA:16)
	extz BC
	sla BC, 0x02
	lda xde, (CmpSingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld XBC,EVT_PAINT
	ld xde, 0:i3
	ld XHL,(XHL)
	call (XHL)
	ld XWA,XIZ
	ld XBC,EVT_PAINT
	ld xde, 0:i3
	calr CmpSingleLoadSrcFunc
	jrl t, CmpDst_Return
CmpDst_ScrollModeA:
.Lc_f911b2:
	ld XWA,(XSP+0x04)
	cp XWA,0x0000000a
	jr nz, .Lc_f9121f
	cp (SINGLE_LOAD_AREA:16), 0x04
	jr z, .Lc_f9121f
	ld XWA,0x00600026
	ld XBC,EVT_SHOW
	ld xde, 5:i3
	call ApPostEvent
	ld wa, 0:i3
	calr InitializeOperationState
	ld xwa, (0x815c:16)
	ld c, (SINGLE_LOAD_AREA:16)
	extz BC
	sla BC, 0x02
	lda xde, (CmpSingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld XBC,(XSP+0x08)
	ld XDE,(XSP+0x04)
	ld XIX,(XHL)
	call (XIX)
	ld WA,HL
	ld bc, 1:i3
	calr FileIO_ValidateSignedValue
	ld (GLOBAL_ERROR_CODE:16), l
	ld XWA,0x00600026
	ld XBC,EVT_HIDE
	ld xde, 0:i3
	call ApPostEvent
	ldw WA, TT_MESAGE
	call UI_InterruptTitleByIndex
	jrl t, CmpDst_Return
CmpDst_ScrollMode7:
.Lc_f9121f:
	ld XWA,(XSP+0x04)
	cp XWA,0x00000007
	jr nz, .Lc_f9125d
	ld xwa, (0x815c:16)
	ld XBC,EVT_SET_SELECTED_FILE_NUMBER
	ld xde, 1:i3
	call ApPostEvent
	ld xwa, (0x815c:16)
	ld c, (SINGLE_LOAD_AREA:16)
	extz BC
	sla BC, 0x02
	lda xde, (CmpSingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld XBC,(XSP+0x08)
	ld XDE,(XSP+0x04)
	ld XHL,(XHL)
	call (XHL)
	jrl t, CmpDst_Return
CmpDst_ScrollMode8:
.Lc_f9125d:
	ld xwa, (0x815c:16)
	ld XBC,(XSP+0x04)
	cp XBC,0x00000008
	jr nz, .Lc_f912d3
	cp (SINGLE_LOAD_ALL:16), 0x00
	jr nz, .Lc_f912a2
	ld XBC,EVT_SET_SELECTED_FILE_NUMBER
	ld xde, 3:i3
	call ApPostEvent
	ld xwa, (0x815c:16)
	ld c, (SINGLE_LOAD_AREA:16)
	extz BC
	sla BC, 0x02
	lda xde, (CmpSingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld XBC,(XSP+0x08)
	ld XDE,(XSP+0x04)
	ld XHL,(XHL)
	call (XHL)
	jrl t, CmpDst_Return
CmpDst_ScrollMode8_NoStep:
.Lc_f912a2:
	ld XBC,EVT_SET_SELECTED_FILE_NUMBER
	ld XDE,0xffffffff
	call ApPostEvent
	ld xwa, (0x815c:16)
	ld c, (SINGLE_LOAD_AREA:16)
	extz BC
	sla BC, 0x02
	lda xde, (CmpSingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld XBC,(XSP+0x08)
	ld XDE,(XSP+0x04)
	ld XHL,(XHL)
	call (XHL)
	jr t, CmpDst_Return
CmpDst_ScrollMode5:
.Lc_f912d3:
	ld XBC,(XSP+0x04)
	cp XBC,0x00000005
	jr nz, .Lc_f9130f
	ld XBC,EVT_SET_SELECTED_FILE_NUMBER
	ld XDE,0xffffffff
	call ApPostEvent
	ld xwa, (0x815c:16)
	ld c, (SINGLE_LOAD_AREA:16)
	extz BC
	sla BC, 0x02
	lda xde, (CmpSingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld XBC,(XSP+0x08)
	ld XDE,(XSP+0x04)
	ld XHL,(XHL)
	call (XHL)
	jr t, CmpDst_Return
CmpDst_ScrollMode6:
.Lc_f9130f:
	ld XBC,(XSP+0x04)
	cp XBC,0x00000006
	jr nz, CmpDst_Return
	cp (SINGLE_LOAD_ALL:16), 0x00
	jr nz, CmpDst_Return
	ld XBC,EVT_SET_SELECTED_FILE_NUMBER
	ld XDE,0xffffffff
	call ApPostEvent
	ld xwa, (0x815c:16)
	ld c, (SINGLE_LOAD_AREA:16)
	extz BC
	sla BC, 0x02
	lda xde, (CmpSingleLoadDst_AreaListProcs:24)
	lda	xhl, (xde+bc)
	ld XBC,(XSP+0x08)
	ld XDE,(XSP+0x04)
	ld XHL,(XHL)
	call (XHL)
CmpDst_Return:
	ld xhl, 0:i3
	jr CmpDst_Epilogue

CmpDst_ReturnCapture:
	ld xhl, 0xffffffff

CmpDst_Epilogue:
	pop xiz
	inc 8, xsp
	ret

CmpSingleLoadFileFunc:
	dec	4, xsp
	push	xiz
	ld	(xsp+4), xwa
	cp	xbc, EVT_INDEXSW_DOWN
	jrl	z, CmpFile_HandleScroll
	cp	xbc, EVT_INDEXSW_UP
	jr	z, CmpFile_HandleScroll
	cp	xbc, EVT_PAINT
	jr	z, CmpSingleLoadFileFunc_OnPaint
	cp	xbc, EVT_PS_FILE_NAME_BOX_ID
	jrl	nz, CmpFile_Return
	ld	(33120:16), xde
	call	GetCurrentFileIndex
	ld	(33124:16), hl
	cp	hl, 0:i3
	jr	ge, CmpFile_Selection_Clamp
	ldw	(33124:16), 0
CmpFile_Selection_Clamp:
	ld	xwa, (33120:16)
	ld	xbc, EVT_SET_SELECTED_FILE_NUMBER
	ld	xde, 4294967295
	jr	CmpFile_ShowDispatch
CmpSingleLoadFileFunc_OnPaint:
	ld	(34772:16), 0
	cp	(SINGLE_LOAD_AREA:16), 2
	jr	nz, CmpFile_ShowDefault
	ld	wa, (33124:16)
	call	GetFileEntryPtr
	ld	xiz, xhl
	jr	CmpFile_ShowDraw
CmpFile_ShowDefault:
	lda xiz, (Str_EmptyFileName_Cmp:24)

CmpFile_ShowDraw:
	lda	xwa, (34773:16)
	ld	de, (33124:16)
	inc	1, de
	pushw	6
	pushw	0
	ld	xbc, xiz
	call	FileIO_ReadHeader_ParseLoop
	ld	xwa, (33120:16)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 34772
CmpFile_ShowDispatch:
	call ApPostEvent
	jrl CmpFile_Return

CmpFile_HandleScroll:
	ld	wa, (33124:16)
	ld	hl, wa
	or	xde, xde
	jr	nz, CmpFile_ScrollDown
	ld	bc, wa
	inc	1, bc
	cp	bc, 20
	jr	ge, CmpFile_ScrollRedraw
	inc	1, wa
	jr	CmpFile_ScrollStore
CmpFile_ScrollDown:
	cp xde, 0x1
	jr nz, CmpFile_ScrollRedraw
	cp wa, 0:i3
	jr le, CmpFile_ScrollRedraw
	dec 1, wa

CmpFile_ScrollStore:
	ld	(33124:16), wa
CmpFile_ScrollRedraw:
	ld	wa, (33124:16)
	cp	wa, hl
	jr	z, CmpFile_Return
	call	NotifyUIOfSelectionChange
	ld	(34772:16), 0
	lda	xiz, (Str_EmptyFileName_Cmp:24)
	ld	(SINGLE_LOAD_AREA:16), 4
	ld	wa, 3:i3
	call	FileIO_CheckRecordValid
	cp	l, 0:i3
	jr	z, CmpFile_RedrawDispatch
	call	FileIO_ValidateAndOpenFile
	cp	hl, 0:i3
	jr	z, CmpFile_RedrawDispatch
	ld	(SINGLE_LOAD_AREA:16), 2
	ld	wa, (33124:16)
	call	GetFileEntryPtr
	ld	xiz, xhl
CmpFile_RedrawDispatch:
	lda	xwa, (34773:16)
	ld	de, (33124:16)
	inc	1, de
	pushw	6
	pushw	0
	ld	xbc, xiz
	call	FileIO_ReadHeader_ParseLoop
	ld	xwa, (33120:16)
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 34772
	call	ApPostEvent
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	CmpSingleLoadSrcFunc
	ld	xwa, (xsp+4)
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	calr	CmpSingleLoadDstFunc
CmpFile_Return:
	ld xhl, 0:i3
	pop xiz
	inc 4, xsp
	ret
FmmCmpSingleLoadFunc:
	cp	xbc, EVT_ACTIVATE_STATE
	jrl	nz, FmmCmpLoad_Return
	cp	xde, 3
	jrl	z, FmmCmpLoad_HandleAbort
	cp	xde, 2
	jrl	nz, FmmCmpLoad_Return
	ld	wa, 1:i3
	calr	InitializeOperationState
	ld	xwa, 6357066
	ld	xbc, EVT_SET_VISIBLE
	ld	xde, 1:i3
	call	ApPostEvent
	ld	xwa, 6291494
	ld	xbc, EVT_SHOW
	ld	xde, 5:i3
	call	ApPostEvent
	cpw	(DISK_MEDIA_TYPE:16), 0
	jr	ge, FmmCmpLoad_DispatchState
	call	GetDiskSizeInfo
	extz	hl
	ld	(DISK_MEDIA_TYPE:16), hl
	calr	SignalProgressUpdate
FmmCmpLoad_DispatchState:
	ld	wa, (DISK_MEDIA_TYPE:16)
	cp	wa, 1:i3
	jrl	z, FmmCmpLoad_HandleSuccess
	cp	wa, 0:i3
	jrl	z, FmmCmpLoad_HandleError
	cp	wa, 5:i3
	jr	z, FmmCmpLoad_HandleCancel
	cpw	(33894:16), 0
	jr	ge, FmmCmpLoad_ContinueLoad
	call	GetEncodedFileSizeData
	ld	(33894:16), hl
	call	FileIO_SearchAndLoadFile
	call	GetEncodedFreeSpaceData
	calr	SignalProgressUpdate
FmmCmpLoad_ContinueLoad:
	ld	(SINGLE_LOAD_AREA:16), 4
	ld	wa, 3:i3
	call	FileIO_CheckRecordValid
	cp	l, 0:i3
	jr	z, FmmCmpLoad_CloseProgress
	call	FileIO_ValidateAndOpenFile
	cp	hl, 0:i3
	jr	z, FmmCmpLoad_SignalProgress
	ld	(SINGLE_LOAD_AREA:16), 2
FmmCmpLoad_SignalProgress:
	calr SignalProgressUpdate

FmmCmpLoad_CloseProgress:
	ld	xwa, 6291494
	ld	xbc, EVT_HIDE
	ld	xde, 0:i3
	call	ApPostEvent
	ld	xwa, 4294967295
	ld	xbc, EVT_ALL_PAINT
	ld	xde, 0:i3
	call	ApPostEvent
	ld	(SLOAD_SRC_CMP_POS:16), 0
	ld	(SLOAD_DST_CMP_POS:16), 0
	jr	FmmCmpLoad_Return
FmmCmpLoad_HandleCancel:
	ld	xwa, 6291494
	ld	xbc, EVT_HIDE
	ld	xde, 0:i3
	call	ApPostEvent
	ldw	wa, TT_CMMENU
	call	UI_ChangeTitleByIndex
	ld	(GLOBAL_ERROR_CODE:16), 0
	ldw	wa, TT_MESAGE
	jr	FmmCmpLoad_CallStatusDisplay
FmmCmpLoad_HandleError:
	ld xwa, 0x600026
	ld xbc, EVT_HIDE
	ld xde, 0:i3
	call ApPostEvent
	ldw wa, TT_DKUTFRMT
	call UI_ChangeTitleByIndex
	jr FmmCmpLoad_Return

FmmCmpLoad_HandleSuccess:
	calr	ResetProgressIndication
	ld	xwa, 6291494
	ld	xbc, EVT_HIDE
	ld	xde, 0:i3
	call	ApPostEvent
	ldw	wa, TT_CMMENU
	call	UI_ChangeTitleByIndex
	ld	(GLOBAL_ERROR_CODE:16), 2
	ldw	wa, TT_MESAGE
FmmCmpLoad_CallStatusDisplay:
	call UI_InterruptTitleByIndex
	jr FmmCmpLoad_Return

FmmCmpLoad_HandleAbort:
	calr CancelOperationCleanup

FmmCmpLoad_Return:
	ld xhl, 0:i3
	ret

BuildSlotLabel:
	dec 2,XSP
	push XIZ
	ld HL,BC
	ld (XSP+0x04),WA
	lda xbc, (SEQ_SONG_SLOTS:24)
	ld WA,(XSP+0x04)
	extz XWA
	sll XWA, 0x0b
	add XBC,XWA
	lda	xbc, (xbc+256)
	ld	wa, (xsp + 4)
	mul	wa, 0x15
	lda	xix, (0x8166:16)
	ld	iz, wa
	extz	xiz
	add	xiz, xix
	ld	(xiz+), l
	cp	e, 0:i3
	jr	z, BuildSlotLabel_WriteContent
	cpw	(xsp + 4), 0x9
	jr	nz, BuildSlotLabel_WriteLetter
	ld	(xiz+), 0x31
	ld	(xiz), 0x30
	jr	BuildSlotLabel_WriteColon
BuildSlotLabel_WriteLetter:
	ld (xiz+), 0x20
	ld wa, (xsp + 4)
	add a, 0x31
	ld (xiz), a

BuildSlotLabel_WriteColon:
	inc 1, xiz
	ld (xiz+), 0x3a

BuildSlotLabel_WriteContent:
	; Disassembled from the committed romslice (no source of any kind existed):
	; llvm-mc round-trips these 34 B byte-exact. v9/v10's BuildSlotLabel_WriteContent
	; is line-for-line identical in shape (ld xwa,xiz / ldw de,0x10 /
	; call FileIO_CopyString_WriteNull / ld (xiz+16),0x0 / ...); the call target
	; and table-base address are left numeric because this v7 link doesn't name them.
	ld	xwa, xiz
	ldw	de, 16
	call	FileIO_CopyString_WriteNull
	ld	(xiz+16), 0
	ld	wa, (xsp+4)
	mul	wa, 21
	lda	xbc, (33126:16)
	extz	xwa
	add	xwa, xbc
	ld	xhl, xwa
	pop	xiz
	inc	2, xsp
	ret
