; =============================================================================
; file_io/wallpaper.asm - Wallpaper Loading
; =============================================================================
; Wallpaper image loading and display routines.
;
; Key routines:
;   FmmWallpaperLoadFunc             - Wallpaper loading
; =============================================================================

FmmWallpaperLoadFunc:
	dec 6, xsp
	push xiz
	ld (xsp + 6), xde
	ld xiz, xbc
	ld xwa, (0x81b0:16)
	cp xiz, EVT_INDEXSW_DOWN
	jrl z, WPLoad_HandleScroll
	cp xiz, EVT_INDEXSW_UP
	jrl z, WPLoad_HandleScroll
	cp xiz, EVT_PAINT
	jrl z, WPLoad_HandleShow
	cp xiz, EVT_PS_FILE_NAME_BOX_ID
	jrl z, WPLoad_HandleSelection
	cp xiz, EVT_ACTIVATE_STATE
	jrl nz, WPLoad_Return
	ld xwa, (xsp + 6)
	cp xwa, 0x3
	jrl z, WPLoad_HandleAbort
	cp xwa, 0x2
	jrl nz, WPLoad_Return
	ld (MEDLEY_PLAY_FLAG:16), 0
	ld wa, 1:i3
	calr InitializeOperationState
	ld xwa, 0x600026
	ld xbc, EVT_SHOW
	ld xde, 5:i3
	call ApPostEvent
	cpw (DISK_MEDIA_TYPE:16), 0
	jr ge, WPLoad_DispatchState
	call GetDiskSizeInfo
	extz hl
	ld (DISK_MEDIA_TYPE:16), hl
	calr SignalProgressUpdate

WPLoad_DispatchState:
	ld wa, (DISK_MEDIA_TYPE:16)
	cp wa, 1:i3
	jrl z, WPLoad_HandleSuccess
	cp wa, 0:i3
	jr z, WPLoad_HandleError
	cp wa, 5:i3
	jr z, WPLoad_HandleCancel
	cpw (0x850a:16), 0
	jr ge, WPLoad_ContinueWait
	call FileIO_InitWallpaperNav
	ld (0x850a:16), hl
	call FileIO_SearchAndLoadFile
	call GetEncodedFreeSpaceData
	calr SignalProgressUpdate

WPLoad_ContinueWait:
	ld xwa, 0x600026
	ld xbc, EVT_HIDE
	ld xde, 0:i3
	call ApPostEvent
	ld xwa, 0xffffffff
	ld xbc, EVT_ALL_PAINT
	ld xde, 0:i3
	jrl WPLoad_DispatchWidget

WPLoad_HandleCancel:
	ld xwa, 0x600026
	ld xbc, EVT_HIDE
	ld xde, 0:i3
	call ApPostEvent
	ld xwa, 0xffffffff
	ld xbc, EVT_SET_NOT_DRAW_FLAG
	ld xde, 1:i3
	call ApPostEvent
	ldw wa, TT_CTWALLSET
	call UI_ChangeTitleByIndex
	ld xwa, 0xffffffff
	ld xbc, EVT_SET_NOT_DRAW_FLAG
	ld xde, 0:i3
	call ApPostEvent
	ld (GLOBAL_ERROR_CODE:16), 0
	ldw wa, TT_MESAGE
	jr WPLoad_CallStatusDisplay

WPLoad_HandleError:
	ld xwa, 0x600026
	ld xbc, EVT_HIDE
	ld xde, 0:i3
	call ApPostEvent
	ldw wa, TT_DKUTFRMT
	call UI_ChangeTitleByIndex
	jrl WPLoad_Return

WPLoad_HandleSuccess:
	calr ResetProgressIndication
	ld xwa, 0x600026
	ld xbc, EVT_HIDE
	ld xde, 0:i3
	call ApPostEvent
	ld xwa, 0xffffffff
	ld xbc, EVT_SET_NOT_DRAW_FLAG
	ld xde, 1:i3
	call ApPostEvent
	ldw wa, TT_CTWALLSET
	call UI_ChangeTitleByIndex
	ld xwa, 0xffffffff
	ld xbc, EVT_SET_NOT_DRAW_FLAG
	ld xde, 0:i3
	call ApPostEvent
	ld (GLOBAL_ERROR_CODE:16), 2
	ldw wa, TT_MESAGE

WPLoad_CallStatusDisplay:
	call UI_InterruptTitleByIndex
	jrl WPLoad_Return

WPLoad_HandleAbort:
	calr CancelOperationCleanup
	jrl WPLoad_Return

WPLoad_HandleSelection:
	ld xwa, (xsp + 6)
	ld (0x81b0:16), xwa
	call FileIO_GetCurrentWallpaperIndex
	ld (0x81b4:16), hl
	cp hl, 0:i3
	jr ge, WPLoad_Selection_Positive
	ldw (0x81b4:16), 0

WPLoad_Selection_Positive:
	ld wa, (0x81b4:16)
	exts xwa
	divs wa, 0xa
	ldto_werp DE, 0xe2
	exts xde
	ld xwa, (0x81b0:16)
	ld xbc, EVT_SET_SELECTED_FILE_NUMBER
	jrl WPLoad_DispatchWidget

WPLoad_HandleShow:
	ld bc, (0x81b4:16)
	exts xbc
	divs bc, 0xa
	muls bc, 0xa
	calr DisplaySmfSequenceList
	jrl WPLoad_Return

WPLoad_HandleScroll:
	ld xbc, EVT_NOT_POST_AIC
	ld xde, 1:i3
	call ApPostEvent
	ld hl, (0x81b4:16)
	ld (xsp + 4), hl
	ld xwa, (xsp + 6)
	or xwa, xwa
	jr nz, WPLoad_PageScroll
	ld xwa, xiz
	cp xwa, EVT_INDEXSW_DOWN
	jr nz, WPLoad_ScrollUp
	ld wa, hl
	inc 1, wa
	cp wa, (0x850a:16)
	jrl ge, WPLoad_GetSelection
	inc 1, hl
	jr WPLoad_StorePosition

WPLoad_ScrollUp:
	cp xwa, EVT_INDEXSW_UP
	jrl nz, WPLoad_GetSelection
	cp hl, 0:i3
	jrl le, WPLoad_GetSelection
	dec 1, hl
	jr WPLoad_StorePosition

WPLoad_PageScroll:
	ld xwa, (xsp + 6)
	cp xwa, 0x1
	jr nz, WPLoad_PageDown
	cp hl, 0xa
	jrl lt, WPLoad_GetSelection
	sub hl, 0xa
	jr WPLoad_StorePosition

WPLoad_PageDown:
	ld xwa, (xsp + 6)
	cp xwa, 0x2
	jr nz, WPLoad_OpLoad
	ld wa, hl
	add wa, 0xa
	ld de, (0x850a:16)
	cp wa, de
	jr ge, WPLoad_PageDown_Boundary
	add hl, 0xa

WPLoad_StorePosition:
	ld (0x81b4:16), hl
	ld bc, hl
	jrl WPLoad_UpdateDisplay

WPLoad_PageDown_Boundary:
	ld bc, de
	dec 1, bc
	ld ix, bc
	exts xix
	divs ix, 0xa
	exts xhl
	divs hl, 0xa
	cp hl, ix
	jrl ge, WPLoad_GetSelection
	exts xde
	divs de, 0xa
	ldto_werp WA, 0xea
	cp wa, 0:i3
	jr z, WPLoad_GetSelection
	ld (0x81b4:16), bc
	jr WPLoad_UpdateDisplay

WPLoad_OpLoad:
	ld xwa, (xsp + 6)
	cp xwa, 0x3
	jr nz, WPLoad_GetSelection
	ld xwa, 0x600026
	ld xbc, EVT_SHOW
	ld xde, 5:i3
	call ApPostEvent
	ld wa, 0:i3
	calr InitializeOperationState
	call LoadFromSecondaryPage
	ld wa, hl
	ld bc, 1:i3
	calr FileIO_ValidateSignedValue
	ld (GLOBAL_ERROR_CODE:16), l
	calr SignalProgressUpdate
	ld xwa, 0x600026
	ld xbc, EVT_HIDE
	ld xde, 0:i3
	call ApPostEvent
	ld xwa, 0xffffffff
	ld xbc, EVT_SET_NOT_DRAW_FLAG
	ld xde, 1:i3
	call ApPostEvent
	ldw wa, TT_CTWALLSET
	call UI_ChangeTitleByIndex
	ld xwa, 0xffffffff
	ld xbc, EVT_SET_NOT_DRAW_FLAG
	ld xde, 0:i3
	call ApPostEvent
	ldw wa, TT_MESAGE
	call UI_InterruptTitleByIndex

WPLoad_GetSelection:
	ld bc, (0x81b4:16)

WPLoad_UpdateDisplay:
	cp (xsp + 4), bc
	jrl z, WPLoad_SendState
	ld wa, bc
	call FileIO_SelectWallpaperByIndex
	ld wa, (0x81b4:16)
	exts xwa
	divs wa, 0xa
	ldto_werp DE, 0xe2
	exts xde
	ld xwa, (0x81b0:16)
	ld xbc, EVT_SET_SELECTED_FILE_NUMBER
	call ApPostEvent
	ld bc, (0x81b4:16)
	exts xbc
	divs bc, 0xa
	ld de, (xsp + 4)
	exts xde
	divs de, 0xa
	ld xwa, (0x81b0:16)
	cp de, bc
	jr nz, WPLoad_RedrawPage
	ld bc, (xsp + 4)
	exts xbc
	divs bc, 0xa
	ldto_werp BC, 0xe6
	sll bc, 5
	lda xhl, (0x850c:16)
	ld de, bc
	extz xde
	add xde, xhl
	ld xbc, EVT_PARA_DRAW
	call ApPostEvent
	ld wa, (0x81b4:16)
	exts xwa
	divs wa, 0xa
	ldto_werp WA, 0xe2
	sll wa, 5
	lda xbc, (0x850c:16)
	ld de, wa
	extz xde
	add xde, xbc
	ld xwa, (0x81b0:16)
	ld xbc, EVT_PARA_DRAW
	call ApPostEvent
	jr WPLoad_SendState

WPLoad_RedrawPage:
	muls bc, 0xa
	calr DisplaySmfSequenceList

WPLoad_SendState:
	ld xwa, (0x81b0:16)
	ld xbc, EVT_NOT_POST_AIC
	ld xde, 0:i3

WPLoad_DispatchWidget:
	call ApPostEvent

WPLoad_Return:
	ld xhl, 0:i3
	pop xiz
	inc 6, xsp
	ret

; SingleLoad_ScanAreas: Sets bit SingleLoad_AreaFlagBits[n] of RAM 0x89F6 for each single-load area n = 0..3
;   that is present: considered when CheckFileSystemStatus's flag word has that bit; checked with
;   FileIO_ValidateAndOpenFile (value 3), signature + region (2) or the signature (other); when the current
;   area SINGLE_LOAD_AREA is 4 or more it is set to the area just found. Basis: callers + body -- the
;   SINGLE LOAD entry in file_io/single_load.s calls it before SingleLoad_FindNextArea.
SingleLoad_ScanAreas:
	push xiz
	call CheckFileSystemStatus
	ldfr_werp HL, 0xfa
	ldw (0x89f6:16), 0
	ld iz, 0:i3

SingleLoad_ScanAreas_LoopBody:
	ld bc, iz
	extz xbc
	ld xwa, SingleLoad_AreaFlagBits
	add xwa, xbc
	ld c, (xwa)
	ld de, 1:i3
	ld a, c
	and a, 0xf
	jr z, SingleLoad_ScanAreas_CheckAvail
	slla de

SingleLoad_ScanAreas_CheckAvail:
	andw_erp DE, 0xfa
	jrl z, SingleLoad_ScanAreas_LoopContinue
	cp c, 3:i3
	jr nz, SingleLoad_ScanAreas_TypeNotThree
	call FileIO_ValidateAndOpenFile
	cp hl, 0:i3
	jrl z, SingleLoad_ScanAreas_LoopContinue
	ld wa, iz
	extz xwa
	ld xbc, SingleLoad_AreaFlagBits
	add xbc, xwa
	ld de, 1:i3
	ld a, (xbc)
	and a, 0xf
	jr z, SingleLoad_ScanAreas_MarkAvailable
	slla de

SingleLoad_ScanAreas_MarkAvailable:
	or (0x89f6:16), de
	cp (SINGLE_LOAD_AREA:16), 4
	jr nc, SingleLoad_ScanAreas_LimitReached
	jr SingleLoad_ScanAreas_LoopContinue

SingleLoad_ScanAreas_TypeNotThree:
	ld a, c
	cp c, 2:i3
	jr nz, SingleLoad_ScanAreas_TypeGeneric
	call FileIO_ValidateFileSignature
	cp hl, 0:i3
	jr z, SingleLoad_ScanAreas_LoopContinue
	call FileIO_ValidateFileWithRegion
	cp hl, 0:i3
	jr nz, SingleLoad_ScanAreas_LoopContinue
	ld wa, iz
	extz xwa
	ld xbc, SingleLoad_AreaFlagBits
	add xbc, xwa
	ld de, 1:i3
	ld a, (xbc)
	and a, 0xf
	jr z, SingleLoad_ScanAreas_TypeTwo_Mark
	slla de

SingleLoad_ScanAreas_TypeTwo_Mark:
	or (0x89f6:16), de
	cp (SINGLE_LOAD_AREA:16), 4
	jr nc, SingleLoad_ScanAreas_LimitReached
	jr SingleLoad_ScanAreas_LoopContinue

SingleLoad_ScanAreas_TypeGeneric:
	call FileIO_ValidateFileSignature
	cp hl, 0:i3
	jr z, SingleLoad_ScanAreas_LoopContinue
	ld wa, iz
	extz xwa
	ld xbc, SingleLoad_AreaFlagBits
	add xbc, xwa
	ld de, 1:i3
	ld a, (xbc)
	and a, 0xf
	jr z, SingleLoad_ScanAreas_Generic_Mark
	slla de

SingleLoad_ScanAreas_Generic_Mark:
	or (0x89f6:16), de
	cp (SINGLE_LOAD_AREA:16), 4
	jr c, SingleLoad_ScanAreas_LoopContinue

SingleLoad_ScanAreas_LimitReached:
	ldto_berp A, 0xf8
	ld (SINGLE_LOAD_AREA:16), a

SingleLoad_ScanAreas_LoopContinue:
	inc 1, iz
	cp iz, 4:i3
	jrl c, SingleLoad_ScanAreas_LoopBody
	pop xiz
	ret

; SingleLoad_FindNextArea: Steps SINGLE_LOAD_AREA round-robin to the next area whose bit is set in RAM 0x89F6
;   (SingleLoad_ScanAreas); L = 1 when one was found, 0 when none is present or the area is 4 or more. Basis:
;   callers + body.
SingleLoad_FindNextArea:
	pushw iz
	ld a, (SINGLE_LOAD_AREA:16)
	cp a, 4:i3
	jr nc, SingleLoad_FindNextArea_NotFound
	ld bc, (0x89f6:16)
	cp bc, 0:i3
	jr z, SingleLoad_FindNextArea_NotFound
	ld iz, 1:i3
	extz wa
	ldfr_werp WA, 0xe6
	lda xde, (SingleLoad_AreaFlagBits:24)

SingleLoad_FindNextArea_SearchLoop:
	ldto_werp HL, 0xe6
	add hl, iz
	and hl, 0x3
	ld wa, hl
	extz xwa
	ld xix, xde
	add xix, xwa
	ld iy, 1:i3
	ld a, (xix)
	and a, 0xf
	jr z, SingleLoad_FindNextArea_CheckSlot
	slla iy

SingleLoad_FindNextArea_CheckSlot:
	and iy, bc
	jr z, SingleLoad_FindNextArea_NextSlot
	ld (SINGLE_LOAD_AREA:16), l
	ld l, 0x1:opc
	jr SingleLoad_FindNextArea_Return

SingleLoad_FindNextArea_NextSlot:
	inc 1, iz
	cp iz, 4:i3
	jr c, SingleLoad_FindNextArea_SearchLoop

SingleLoad_FindNextArea_NotFound:
	ld l, 0x0:opc

SingleLoad_FindNextArea_Return:
	popw iz
	ret

; -----------------------------------------------------------------------------
; Single-load helpers.  Only FmmWallpaperLoadFunc above is wallpaper code; the routines below scan
; the single-load areas and fetch the names the SINGLE LOAD source and destination lists show (file
; buffer 0x1ED350, sound RAM 0x1E0000, the composer records 0x948A0, ROM name tables).  Callers:
; file_io/single_load.s.  XWA = destination buffer, E = the marker byte stored first.
; -----------------------------------------------------------------------------
; These routines retrieve wallpaper display names from various sources:
; - User RAM structures (0x1ed350, 0x1e0000, 0x1e4980, 0x1e4aa7)
; - ROM lookup tables (0xea07ae, 0xea07ea, 0xea083e, 0xea08da)
;
; Common calling convention:
;   XWA = destination buffer pointer
;   BC = index or selection parameter
;   E = type marker byte
; -----------------------------------------------------------------------------

; SingleLoad_GetFileBankName: Writes E, then the 16-byte name of panel-memory bank BC of the loaded .PMT file
;   (0x1ED350 + 16 + 16 * BC) to XWA, trimmed and padded to 16 (TrimAndPadSmfFilename). Basis: callers --
;   the panel-memory bank lists of file_io/single_load.s.
SingleLoad_GetFileBankName:
	push xiz
	ld xiz, xwa
	lda xhl, (0x1ed350:24); Wallpaper config base address
	extz xbc
	sll xbc, 4	; index * 16
	add xhl, xbc
	lda xhl, (xhl + 16)	; Offset to name field
	ld (xiz+), e	; Store type marker
	ld xwa, xiz
	ld xbc, xhl
	ldw de, 0x10	; Copy 16 bytes
	call FileIO_CopyString_WriteNull
	ld (xiz + 16), 0x0	; Null terminate
	ld xwa, xiz
	ldw bc, 0x10
	calr TrimAndPadSmfFilename
	pop xiz
	ret

; SingleLoad_GetFileMemoryName: Writes E, then the name of panel memory BC of the loaded .PMT file
;   (0x1ED350 + entry size (+13) * BC + 178) to XWA, padded to 16. Basis: callers -- the panel-memory item
;   rows of the single-load destination list.
SingleLoad_GetFileMemoryName:
	push xiz
	ld xiz, xwa
	lda xwa, (0x1ed350:24)
	ld hl, (xwa + 13)	; Get entry size from config
	ld xix, xwa
	mul xhl, bc	; Calculate offset
	add xix, xhl
	lda xbc, (xix+178:16)	; Offset to name field
	ld (xiz+), e
	ld xwa, xiz
	ldw de, 0x10
	call FileIO_CopyString_WriteNull
	ld (xiz + 16), 0x0
	ld xwa, xiz
	ldw bc, 0x10
	calr TrimAndPadSmfFilename
	pop xiz
	ret

; SingleLoad_GetComposerBankName: Writes E, then SingleLoad_MemoryBankNames[BC] ("MEMORY-A" / "-B" / "-C")
;   to XWA, padded to 16. Basis: callers -- the COMPOSER source and destination lists (BC = position / 10).
SingleLoad_GetComposerBankName:
	push xiz
	ld xiz, xwa
	ld (xiz+), e
	ld wa, bc
	extz xwa
	sll xwa, 2	; index * 4 (pointer size)
	ld xbc, SingleLoad_MemoryBankNames	; ROM table address
	add xbc, xwa
	ld xbc, (xbc)	; Get string pointer
	ld xwa, xiz
	call FileIO_CopyString
	ld xwa, xiz
	ldw bc, 0x10
	calr TrimAndPadSmfFilename
	pop xiz
	ret

; SingleLoad_GetVariationName: Returns XHL = PtrTbl_VariationNames[WA] ("VARI 1".."VARI 4", then empty).
;   Basis: callers -- the COMPOSER single-load lists (WA = item mod items per bank).
SingleLoad_GetVariationName:
	extz xwa
	sll xwa, 2	; index * 4
	ld xbc, PtrTbl_VariationNames
	add xbc, xwa
	ld xhl, (xbc)
	ret

; SingleLoad_GetComposerSectionName: Writes the marker (stack word), then the name of section DE of composer
;   bank BC to XWA: sections 0-3 (VARI 1-4) from the 96-byte composer records at RAM 0x948A0 + 96 * (4 * BC +
;   DE) (13 bytes), sections 4-9 from SingleLoad_StyleSectionNames (INTRO 1 .. ENDING 2); padded to 16; pops
;   the marker word (retd 2). Basis: callers -- SingleLoadSrc_ComposerDrawPatternSlot and
;   SingleLoadDst_DrawComposerItemRows.
SingleLoad_GetComposerSectionName:
	push xiz
	ld hl, bc
	ld xiz, xwa
	lda xbc, (xiz+:1)	; LDA XBC, XIZ+
	ld wa, (xsp + 8)
	ld (xbc), a	; Store type marker
	cp de, 4:i3
	jr nc, SingleLoad_GetComposerSectionName_FromROM
	; From RAM at 0x0948a0
	lda xbc, (0x0948a0:24)
	sll hl, 2
	add hl, de
	mul hl, 0x60	; Entry size = 96 bytes
	add xbc, xhl
	ld xwa, xiz
	ldw de, 0xd	; Copy 13 bytes
	call FileIO_CopyString_WriteNull
	ld (xiz + 13), 0x0
	jr SingleLoad_GetComposerSectionName_Format
SingleLoad_GetComposerSectionName_FromROM:
	extz xde
	sll xde, 2
	ld xbc, SingleLoad_StyleSectionNames	; ROM table address
	add xbc, xde
	ld xbc, (xbc)
	ld xwa, xiz
	call FileIO_CopyString
SingleLoad_GetComposerSectionName_Format:
	ld xwa, xiz
	ldw bc, 0x10
	calr TrimAndPadSmfFilename
	pop xiz
	retd 0x2

; SingleLoad_GetSoundMemBankName: Writes E, then SingleLoad_SoundMemBankNames[BC] ("MEMORY A", "MEMORY B",
;   "USER KIT") to XWA, padded to 16. Basis: callers -- the SOUND MEMORY source and destination lists (BC =
;   position / 20).
SingleLoad_GetSoundMemBankName:
	push xiz
	ld xiz, xwa
	ld (xiz+), e
	ld wa, bc
	extz xwa
	sll xwa, 2
	ld xbc, SingleLoad_SoundMemBankNames
	add xbc, xwa
	ld xbc, (xbc)
	ld xwa, xiz
	call FileIO_CopyString
	ld xwa, xiz
	ldw bc, 0x10
	calr TrimAndPadSmfFilename
	pop xiz
	ret

; SingleLoad_GetSoundRamName: Writes E, then the 16-byte name of sound-RAM sound BC (0x1E0000 + 16 + 470 * BC)
;   to XWA, padded to 16. Basis: callers -- the SOUND MEMORY destination list.
SingleLoad_GetSoundRamName:
	push xiz
	ld xiz, xwa
	lda xhl, (0x1e0000:24)
	lda xhl, (xhl + 16)
	mul bc, 0x1d6	; Entry stride
	add xhl, xbc
	ld (xiz+), e
	ld xwa, xiz
	ld xbc, xhl
	ldw de, 0x10
	call FileIO_CopyString_WriteNull
	ld (xiz + 16), 0x0
	ld xwa, xiz
	ldw bc, 0x10
	calr TrimAndPadSmfFilename
	pop xiz
	ret

; SingleLoad_GetUserKitName: Writes E, then the 16-byte USER KIT name in sound RAM (0x1E4980) to XWA, padded to
;   16; BC is not used. Basis: callers -- the SOUND MEMORY destination list's USER KIT row.
SingleLoad_GetUserKitName:
	push xiz
	ld de, bc
	ld xiz, xwa
	lda xbc, (0x1e4980:24)
	ld (xiz+), e
	ld xwa, xiz
	ldw de, 0x10
	call FileIO_CopyString_WriteNull
	ld (xiz + 16), 0x0
	ld xwa, xiz
	ldw bc, 0x10
	calr TrimAndPadSmfFilename
	pop xiz
	ret

; SingleLoad_GetUserKitEntryName: Writes E and a space, then the 13-byte name of USER KIT entry BC (0x1E4AA7 +
;   80 * BC) to XWA, padded to 15. Basis: callers -- the SOUND MEMORY destination list past the 2 x 20 sounds.
SingleLoad_GetUserKitEntryName:
	push xiz
	ld xiz, xwa
	lda xhl, (0x1e4aa7:24)
	mul bc, 0x50	; Entry stride
	add xhl, xbc
	ld (xiz+), e
	ld (xiz+), 0x20	; Space character
	ld xwa, xiz
	ld xbc, xhl
	ldw de, 0xd	; Copy 13 bytes
	call FileIO_CopyString_WriteNull
	ld (xiz + 13), 0x0
	ld xwa, xiz
	ldw bc, 0xf
	calr TrimAndPadSmfFilename
	pop xiz
	ret

