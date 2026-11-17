; =============================================================================
; Bitmap Drum Editor
; =============================================================================
;
; Bitmap drum editor: stream positioning, sequence display,
; and voice allocation UI. Provides the graphical drum pattern
; editing interface.
; =============================================================================

BmDrEdit_AdvanceStreamPos:
	ld wa, (0x0210a6:24)
	cp wa, 0xff
	jr nc, BmDrEdit_AdvanceStreamWrap
	inc 1, wa
	ld (0x0210a6:24), wa
	ret

BmDrEdit_AdvanceStreamWrap:
	ld bc, (0x0210a4:24)
	dec 1, bc
	extz xbc
	sll xbc, 8
	lda xwa, (xbc + 4)
	lda xde, (0x0b0000:24)
	ld xhl, xde
	add xhl, xwa
	ld l, (xhl)
	extz hl
	sll hl, 8
	lda xwa, (xbc + 3)
	add xde, xwa
	ld a, (xde)
	extz wa
	add wa, hl
	ld (0x0210a4:24), wa
	ldw (0x0210a6:24), 0x0005
	ret

BmDrEdit_ScanForwardInit:
	pushw iz
	ld wa, (0x27fe:16)
	ld (0x27f6:16), wa
	ld wa, (0x2800:16)
	ld (0x27f8:16), wa
	ld wa, (0x2802:16)
	ld (0x27fa:16), wa
	ld wa, (0x2804:16)
	ld (0x27fc:16), wa
	ldmmw_dd24 0xa0, 0x10, 0x02, 0xfe, 0x27
	ldmmw_dd24 0xa2, 0x10, 0x02, 0x00, 0x28
	ldmmw_dd24 0xa4, 0x10, 0x02, 0x02, 0x28
	ldmmw_dd24 0xa6, 0x10, 0x02, 0x04, 0x28
	ldmmb_dd24 0xa8, 0x10, 0x02, 0x22, 0x28
	ldmmb_dd24 0xaa, 0x10, 0x02, 0x24, 0x28
	ld iz, 0:i3
	ld a, (0x2774:16)
	extz wa
	cp wa, 0:i3
	jrl ule, BmDrEdit_ScanForward_Done

BmDrEdit_ScanForwardLoop:
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld a, (xbc)
	cp a, 0x82
	jrl z, BmDrEdit_ScanForward_Done
	cp a, 0x84
	jrl z, BmDrEdit_ScanForward_Done
	cp a, 0x81
	jr nz, BmDrEdit_ScanForward_CheckNote
	inc 1, iz
	incw 1, (0x0210a0:24)
	jr BmDrEdit_ScanForward_NextByte

BmDrEdit_ScanForward_CheckNote:
	and a, 0xf0
	cp a, 0x90
	jr nz, BmDrEdit_ScanForward_NextByte
	calr BmDrEdit_AdvanceStreamPos
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld a, (xbc)
	extz wa
	ld (0x0210a2:24), wa
	calr BmDrEdit_AdvanceStreamPos
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld a, (xbc)
	ld (0x2806:16), a
	cp a, (0x0210a8:24)
	jr c, BmDrEdit_ScanForward_NextByte
	cp a, (0x0210aa:24)
	call ule, (BmDrEdit_RenderNoteBlock:24)

BmDrEdit_ScanForward_NextByte:
	calr BmDrEdit_AdvanceStreamPos
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld a, (xbc)
	bit 7, a
	jr z, BmDrEdit_ScanForward_NextByte
	ld a, (0x2774:16)
	extz wa
	cp iz, wa
	jrl c, BmDrEdit_ScanForwardLoop

BmDrEdit_ScanForward_Done:
	popw iz
	ret

BmDrEdit_ScanBackwardInit:
	pushw iz
	ldmm16 0x27f6, 0x27fe
	ldmm16 0x27f8, 0x2800
	ldmm16 0x27fa, 0x2802
	ldmm16 0x27fc, 0x2804
	ldmmw_dd24 0xa0, 0x10, 0x02, 0xfe, 0x27
	ldmmw_dd24 0xa2, 0x10, 0x02, 0x00, 0x28
	ldmmw_dd24 0xa4, 0x10, 0x02, 0x02, 0x28
	ldmmw_dd24 0xa6, 0x10, 0x02, 0x04, 0x28
	ldmmb_dd24 0xa8, 0x10, 0x02, 0x22, 0x28
	ldmmb_dd24 0xaa, 0x10, 0x02, 0x24, 0x28
	ld iz, 0:i3
	ld a, (0x2774:16)
	extz wa
	cp wa, 0:i3
	jrl ule, BmDrEdit_ScanBackward_Done

BmDrEdit_ScanBackwardLoop:
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld a, (xbc)
	cp a, 0x82
	jrl z, BmDrEdit_ScanBackward_Done
	cp a, 0x84
	jrl z, BmDrEdit_ScanBackward_Done
	cp a, 0x81
	jr nz, BmDrEdit_ScanBackward_CheckNote
	inc 1, iz
	incw 1, (0x27fe:16)
	jr BmDrEdit_ScanBackward_NextByte

BmDrEdit_ScanBackward_CheckNote:
	and a, 0xf0
	cp a, 0x90
	jr nz, BmDrEdit_ScanBackward_NextByte
	ld wa, (0x2802:16)
	cp wa, (0x2766:16)
	jr nz, BmDrEdit_ScanBackward_ReadNoteParams
	ld wa, (0x2804:16)
	cp wa, (0x2768:16)
	jr z, BmDrEdit_ScanBackward_NextByte

BmDrEdit_ScanBackward_ReadNoteParams:
	calr BmDrEdit_AdvanceStreamPos
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld a, (xbc)
	extz wa
	ld (0x2800:16), wa
	calr BmDrEdit_AdvanceStreamPos
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld a, (xbc)
	ld (0x2806:16), a
	cp a, (0x0210a8:24)
	jr c, BmDrEdit_ScanBackward_NextByte
	cp a, (0x0210aa:24)
	call ule, (BmDrEdit_RenderNoteBlock:24)

BmDrEdit_ScanBackward_NextByte:
	calr BmDrEdit_AdvanceStreamPos
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld a, (xbc)
	bit 7, a
	jr z, BmDrEdit_ScanBackward_NextByte
	ld a, (0x2774:16)
	extz wa
	cp iz, wa
	jrl c, BmDrEdit_ScanBackwardLoop

BmDrEdit_ScanBackward_Done:
	popw iz
	ret

; Draws the outline of the note under the editor cursor: position from BmDrEdit_CalcNotePosition,
; the horizontal layout on the note-edit screen (TITLE_SQNOTEEDT) and the vertical one otherwise,
; then DrawFrame with the rectangle 0x27ba / 0x27be - 0x27bc / 0x27c0.
BmDrEdit_RenderNoteBlock:
	dec 8, xsp
	calr BmDrEdit_CalcNotePosition
	call GetTitleNow
	cp xhl, TITLE_SQNOTEEDT
	jr nz, BmDrEdit_RenderNoteBlock_Vertical
	calr BmDrEdit_RenderHorizontal
	jr BmDrEdit_RenderNoteBlock_StoreCoords

BmDrEdit_RenderNoteBlock_Vertical:
	calr BmDrEdit_RenderVertical

BmDrEdit_RenderNoteBlock_StoreCoords:
	lda xwa, (xsp)
	ldmw2 (xwa), 0x27ba
	ldmw2 (xwa + 4), 0x27bc
	ldmw2 (xwa + 2), 0x27be
	ldmw2 (xwa + 6), 0x27c0
	ld bc, 0:i3
	call DrawFrame
	inc 8, xsp
	ret

BmDrEdit_CalcNotePosition:
	pushw_erp 0xfa
	ld bc, (0x0210a0:24)
	mul bc, 0x60
	add bc, (0x0210a2:24)
	ld wa, (0x27f6:16)
	mul wa, 0x60
	add wa, (0x27f8:16)
	sub bc, wa
	ld (0x2808:16), bc
	ld a, (0x0210a8:24)
	sub (0x2806:16), a
	call GetTitleNow
	cp xhl, TITLE_SQNOTEEDT
	jr nz, BmDrEdit_CalcNotePos_VerticalMode
	cp (NOTEEDIT_BASE_KEY:16), 0
	jr nz, BmDrEdit_CalcNotePos_ReadFields
	inc 3, (0x2806:16)
	jr BmDrEdit_CalcNotePos_ReadFields

BmDrEdit_CalcNotePos_VerticalMode:
	ld a, 0xb:opc
	sub a, (0x2806:16)
	ld (0x2806:16), a

BmDrEdit_CalcNotePos_ReadFields:
	calr BmDrEdit_AdvanceStreamPos
	calr BmDrEdit_AdvanceStreamPos
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld a, (xbc)
	ldfr_berp A, 0xfb
	calr BmDrEdit_AdvanceStreamPos
	ld bc, (0x0210a6:24)
	extz xbc
	ld wa, (0x0210a4:24)
	dec 1, wa
	extz xwa
	sll xwa, 8
	add xwa, xbc
	ld xbc, 0xb0000
	add xbc, xwa
	ld c, (xbc)
	res_erpb 0xfb, 0x07
	res 7, c
	extz bc
	mul bc, 0x60
	ldto_berp A, 0xfb
	extz wa
	add bc, wa
	ld (0x280a:16), bc
	ld l, (0x2774:16)
	mul l, 0x60
	dec 1, hl
	ld wa, (0x2808:16)
	ld de, wa
	add de, bc
	cp de, hl
	jr ule, BmDrEdit_CalcNotePos_ClampSize
	sub hl, wa
	ld (0x280a:16), hl

BmDrEdit_CalcNotePos_ClampSize:
	popw_erp 0xfa
	ret

; Note box for the horizontal editor: x1 0x27ba = (0x2808) / 4 + 0x16, x2 0x27bc = (0x280a) / 4 +
; x1, y1 0x27be = BmDrEdit_RenderHorizontal_Table[(0x2806)], y2 0x27c0 = y1 + 3.
BmDrEdit_RenderHorizontal:	.include "includes/generated/cc900/BmDrEdit_RenderHorizontal.s"	; C: cc900/bmdredit_routines_m232.c

; BmDrEdit_RenderHorizontal with x1 = (0x2808) / 4 + 0x5b and BmDrEdit_RenderVertical_Table.
BmDrEdit_RenderVertical:	.include "includes/generated/cc900/BmDrEdit_RenderVertical.s"	; C: cc900/bmdredit_routines_m232.c

; Copies byte 0x281c to 0x210b0 and word 0x2820 to 0x210b2, places the box
; (BmDrEdit_CalcSecondaryPosition, then BmDrEdit_RenderSecondaryHoriz on TITLE_SQNOTEEDT, else
; BmDrEdit_RenderSecondaryVert) and draws it with DrawDesignBox from an 8-byte stack record (words
; 0x27c2, 0x27c6, 0x27c4, 0x27c8 at +0, +2, +4, +6), BC = DE = 0.
BmDrEdit_RenderSecondaryBlock:
	dec 8, xsp
	ldmmb_dd24 0xb0, 0x10, 0x02, 0x1c, 0x28
	ldmmw_dd24 0xb2, 0x10, 0x02, 0x20, 0x28
	calr BmDrEdit_CalcSecondaryPosition
	call GetTitleNow
	cp xhl, TITLE_SQNOTEEDT
	jr nz, BmDrEdit_RenderSecondary_Vertical
	calr BmDrEdit_RenderSecondaryHoriz
	jr BmDrEdit_RenderSecondary_StoreCoords

BmDrEdit_RenderSecondary_Vertical:
	calr BmDrEdit_RenderSecondaryVert

BmDrEdit_RenderSecondary_StoreCoords:
	lda xwa, (xsp)
	ldmw2 (xwa), 0x27c2
	ldmw2 (xwa + 4), 0x27c4
	ldmw2 (xwa + 2), 0x27c6
	ldmw2 (xwa + 6), 0x27c8
	ld bc, 0:i3
	ld de, 0:i3
	call DrawDesignBox
	inc 8, xsp
	ret

; 0x27c2 = (0x281e) / 4 + 0x16, 0x27c4 = (0x210b2) / 4 + (0x27c2), 0x27c6 =
; BmDrEdit_RenderHorizontal_Table[(0x210b0)], 0x27c8 = (0x27c6) + 3.
BmDrEdit_RenderSecondaryHoriz:
	ld wa, (0x281e:16)
	srl wa, 2
	add wa, 0x16
	ld (0x27c2:16), wa
	ld wa, (0x0210b2:24)
	srl wa, 2
	add wa, (0x27c2:16)
	ld (0x27c4:16), wa
	ld a, (0x0210b0:24)
	extz wa
	add wa, wa
	lda xbc, (BmDrEdit_RenderHorizontal_Table:24)
	ldw	(0x27c6:16), (xbc+wa)
	ld wa, (0x27c6:16)
	inc 3, wa
	ld (0x27c8:16), wa
	ret

; BmDrEdit_RenderSecondaryHoriz with + 0x5b and BmDrEdit_RenderVertical_Table, then 0x27c6 - 2
; and 0x27c8 + 2.
BmDrEdit_RenderSecondaryVert:	.include "includes/generated/cc900/BmDrEdit_RenderSecondaryVert.s"	; C: cc900/bmdredit_routines.c

; 0x281e = ((0x2814) * 96 + (0x2816)) - ((0x280c) * 96 + (0x280e)); byte 0x210b0 - (0x2826), then +
; 3 on TITLE_SQNOTEEDT when 0x2798 is 0, or 11 minus it on the other title.  The length 0x210b2 is
; cut so that (0x281e) + length stays within (0x2774) * 96 - 1.
BmDrEdit_CalcSecondaryPosition:
	ld bc, (0x2814:16)
	mul bc, 0x60
	add bc, (0x2816:16)
	ld wa, (0x280c:16)
	mul wa, 0x60
	add wa, (0x280e:16)
	sub bc, wa
	ld (0x281e:16), bc
	ld a, (0x2826:16)
	sub (0x0210b0:24), a
	call GetTitleNow
	cp xhl, TITLE_SQNOTEEDT
	jr nz, BmDrEdit_CalcSecondaryPos_Vert
	cp (NOTEEDIT_BASE_KEY:16), 0
	jr nz, BmDrEdit_CalcSecondaryPos_ClampSize
	inc 3, (0x0210b0:24)
	jr BmDrEdit_CalcSecondaryPos_ClampSize

BmDrEdit_CalcSecondaryPos_Vert:
	ld a, 0xb:opc
	sub a, (0x0210b0:24)
	ld (0x0210b0:24), a

BmDrEdit_CalcSecondaryPos_ClampSize:
	ld e, (0x2774:16)
	mul e, 0x60
	dec 1, de
	ld wa, (0x281e:16)
	ld bc, wa
	add bc, (0x0210b2:24)
	cp bc, de
	ret ule
	sub de, wa
	ld (0x0210b2:24), de
	ret

; Sets the note-editor display defaults: 0x2794 = 0x2796 = 48, 0x2790 = 38, scroll index 0x2798 =
; 5, top row 0x279e = 40, cursor row 0x27a0 = 5, 0x278a = 100.
BmDrEdit_InitDisplayParams:
	ldw (0x2794:16), 48
	ldw (0x2796:16), 48
	ldw (0x2790:16), 38
	ld (NOTEEDIT_BASE_KEY:16), 5
	ldw (0x279e:16), 40
	ldw (0x27a0:16), 5
	ld (0x278a:16), 100
	ret

BmDrEdit_TempoAnimTimer:
	ld a, (0xe372:16)
	cp a, 0x1e
	jr ule, BmDrEdit_TempoAnimTimer_Reset
	inc 1, a
	ld (0xe372:16), a
	ret

BmDrEdit_TempoAnimTimer_Reset:
	ld (0xe372:16), 0
	calr BmDrEdit_CheckTempoData
	calr BmDrEdit_DecrementDelayA
	calr BmDrEdit_DelayAExpired
	calr BmDrEdit_DecrementDelayB
	calr BmDrEdit_DelayBExpired
	jrl BmDrEdit_DelayReturn

BmDrEdit_CheckTempoData:	.include "includes/generated/cc900/BmDrEdit_CheckTempoData.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_CheckTempoData_ReadyToProcess, BmDrEdit_CheckTempoData + 22
	.set	BmDrEdit_ProcessTempoEvent, BmDrEdit_CheckTempoData + 44
	.set	BmDrEdit_ProcessTempoEvent_NoteOff, BmDrEdit_CheckTempoData + 97
	.set	BmDrEdit_ClearNoteAndRefresh, BmDrEdit_CheckTempoData + 139
	.set	BmDrEdit_ClearSlotAndRedraw, BmDrEdit_CheckTempoData + 146
	.set	BmDrEdit_TempoEventLoop, BmDrEdit_CheckTempoData + 152

; Counts the editor timer 0x295c down while bit 7 is set, stopping at 0x80.
BmDrEdit_DecrementDelayA:
	ld a, (0x295c:16)
	bit 7, a
	ret z
	cp a, 0x80
	ret z
	dec 1, a
	ld (0x295c:16), a
	ret

; When the timer 0x295c has reached 0x80: clears it and tail-jumps by action 0x295d: 5 ->
; BmDrEdit_DelayAction_WalkAndUpdateAlt, 4 -> _UpdateScrollAlt, 3 -> _CheckCountError, 2 ->
; _WalkAndUpdate, 1 -> _SetupAndWalk, others -> BmDrEdit_HandleDelayExpired_Rescan.
BmDrEdit_DelayAExpired:
	cp (0x295c:16), 128
	ret nz
	ld (0x295c:16), 0
	ld a, (0x295d:16)
	cp a, 5:i3
	jrl z, BmDrEdit_DelayAction_WalkAndUpdateAlt
	cp a, 4:i3
	jrl z, BmDrEdit_DelayAction_UpdateScrollAlt
	cp a, 3:i3
	jrl z, BmDrEdit_DelayAction_CheckCountError
	cp a, 2:i3
	jrl z, BmDrEdit_DelayAction_WalkAndUpdate
	cp a, 1:i3
	jrl nz, BmDrEdit_HandleDelayExpired_Rescan
	jrl BmDrEdit_DelayAction_SetupAndWalk

; Counts the timer 0x295e down while bit 7 is set, stopping at 0x80.
BmDrEdit_DecrementDelayB:
	ld a, (0x295e:16)
	bit 7, a
	ret z
	cp a, 0x80
	ret z
	dec 1, a
	ld (0x295e:16), a
	ret

; When the timer 0x295e has reached 0x80: clears it and tail-jumps to
; BmDrEdit_DelayAction_PlayClick.
BmDrEdit_DelayBExpired:
	cp (0x295e:16), 128
	ret nz
	ld (0x295e:16), 0
	jrl BmDrEdit_DelayAction_PlayClick

BmDrEdit_DelayReturn:
	ret

; Takes the first free 3-byte slot at 0x2746 (8 slots, 1 in drum mode, bit 0 of 0x2742): sets bit 7
; of byte 0 and copies bytes 0x2960 / 0x2961 to +1 / +2.  Nothing when all are taken.
BmDrEdit_AllocateNoteSlot:
	ldw ix, 0x8
	bit 0, (0x2742:16)
	jr z, BmDrEdit_AllocateNote_Search
	ld ix, 1:i3

BmDrEdit_AllocateNote_Search:
	ld iy, 0:i3
	cp ix, 0:i3
	ret ule
	lda xde, (0x2746:16)

BmDrEdit_AllocateNote_Loop:
	ld hl, iy
	mul hl, 0x3
	ld bc, hl
	extz xbc
	add xbc, xde
	ld a, (xbc)
	bit 7, a
	jr nz, BmDrEdit_AllocateNote_NextSlot
	set 7, a
	ld (xbc), a
	ld wa, 1:i3
	add wa, hl
	extz xwa
	add xwa, xde
	ldmi16 (xwa), 0x2960
	ld wa, 2:i3
	add wa, hl
	extz xwa
	add xwa, xde
	ldmi16 (xwa), 0x2961
	ret

BmDrEdit_AllocateNote_NextSlot:
	inc 1, iy
	cp iy, ix
	jr c, BmDrEdit_AllocateNote_Loop
	ret

; Leaves the editor with an error: clears bit 0 of 0x8d88, sends sound command 0xee with
; GLOBAL_ERROR_CODE = 0x0f (SoundCtrl_SaveAndSendCmd_EE) and sets bit 4 of DEMO_CONTROL_FLAGS.
BmDrEdit_RefreshDisplayState:
	res 0, (0x8d88:16)
	ldw wa, 0xf
	call SoundCtrl_SaveAndSendCmd_EE
	set 4, (DEMO_CONTROL_FLAGS:16)
	ret

; HL = 0xffff when entry A of the song slot's type table (Part_ReadVoiceByte, WA = 0) is 0x0d, 0x0f
; or 0x10, else 0.
BmDrEdit_CheckNoteType:
	ld c, a
	extz bc
	ld wa, 0:i3
	call Part_ReadVoiceByte
	cp l, 0xd
	jr z, BmDrEdit_CheckNoteType_IsDrum
	cp l, 0xf
	jr z, BmDrEdit_CheckNoteType_IsDrum
	cp l, 0x10
	jr nz, BmDrEdit_CheckNoteType_NotDrum

BmDrEdit_CheckNoteType_IsDrum:
	ldw hl, 0xffff
	ret

BmDrEdit_CheckNoteType_NotDrum:
	ld hl, 0:i3
	ret

; UI_ChangeTitleByIndex with WA = 0x98 in drum mode (bit 0 of 0x2742), else 0x95; then word 0xd4f
; -> 0x2963, SeqVoice_FindSingleActive, and PART_SELECT -> 0x1d58.
BmDrEdit_SaveSequencerState:	.include "includes/generated/cc900/BmDrEdit_SaveSequencerState.s"	; C: cc900/bmdredit_routines_m232_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_SaveSeqState_SetMode95, BmDrEdit_SaveSequencerState + 11
	.set	BmDrEdit_SaveSeqState_Apply, BmDrEdit_SaveSequencerState + 14

; HL = 0xffff while the editor timer runs (bit 7 of 0x295c) with action 0x295d non-zero.  Otherwise
; moves the measure 0x2744 one on (at most 999) with BmDrEdit_ScrollReset, HL = 0.
BmDrEdit_CheckScrollBusy:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_ScrollRight
	cp (0x295d:16), 0
	jr z, BmDrEdit_ScrollRight
	ldw hl, 0xffff
	ret

BmDrEdit_ScrollRight:
	ld wa, (0x2744:16)
	cp wa, 0x3e7
	jr nc, BmDrEdit_ScrollRight_Done
	inc 1, wa
	ld (0x2744:16), wa
	calr BmDrEdit_ScrollReset

BmDrEdit_ScrollRight_Done:
	ld hl, 0:i3
	ret

; HL = 0xffff while the editor timer runs (bit 7 of 0x295c) with action 0x295d non-zero.  Otherwise
; moves the measure 0x2744 one back (at least 1) with BmDrEdit_ScrollReset, HL = 0.
BmDrEdit_CheckScrollBusyAlt:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_ScrollLeft
	cp (0x295d:16), 0
	jr z, BmDrEdit_ScrollLeft
	ldw hl, 0xffff
	ret

BmDrEdit_ScrollLeft:
	ld wa, (0x2744:16)
	cp wa, 1:i3
	jr ule, BmDrEdit_ScrollLeft_Done
	dec 1, wa
	ld (0x2744:16), wa
	calr BmDrEdit_ScrollReset

BmDrEdit_ScrollLeft_Done:
	ld hl, 0:i3
	ret

; Moves the editor cursor to the start: redraws parameter 0 (NoteEditSy_SendScrollCmd0), clears
; the cursor tick 0x279a and the count / tick pair 0x2782 / 0x2784, 0x295c = 130, 0x295d = 0.
BmDrEdit_ScrollReset:
	call NoteEditSy_SendScrollCmd0
	ldw (0x279a:16), 0
	ldw (0x2782:16), 0
	ld (0x2784:16), 0
	ld (0x295c:16), 130
	ld (0x295d:16), 0
	ret

; Unless the timer runs with an action other than 1: the cursor tick 0x2784 + 1 (at 0x5f
; BmDrEdit_PitchScrollOverflow instead), NoteEditSy_SendScrollCmd2, NoteEditSy_CallFarRoutine,
; BmDrEdit_BuildVoice_NullReturn and BmDrEdit_SetFeedbackTimer.
BmDrEdit_PitchScrollUp_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_PitchScrollUp
	cp (0x295d:16), 1
	ret nz

BmDrEdit_PitchScrollUp:
	ld a, (0x2784:16)
	cp a, 0x5f
	jrl nc, BmDrEdit_PitchScrollOverflow
	inc 1, a
	ld (0x2784:16), a
	call NoteEditSy_SendScrollCmd2
	calr NoteEditSy_CallFarRoutine
	calr BmDrEdit_BuildVoice_NullReturn
	jrl BmDrEdit_SetFeedbackTimer

; Unless the timer runs with an action other than 1: the cursor tick 0x2784 - 1 (at 0
; BmDrEdit_PitchWrapToEnd instead), NoteEditSy_SendScrollCmd2, NoteEditSy_CallFarRoutine,
; BmDrEdit_BuildVoice_NullReturn and BmDrEdit_SetFeedbackTimer.
BmDrEdit_PitchScrollDown_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_PitchScrollDown
	cp (0x295d:16), 1
	ret nz

BmDrEdit_PitchScrollDown:
	ld a, (0x2784:16)
	cp a, 0:i3
	jrl z, BmDrEdit_PitchWrapToEnd
	dec 1, a
	ld (0x2784:16), a
	call NoteEditSy_SendScrollCmd2
	calr NoteEditSy_CallFarRoutine
	calr BmDrEdit_BuildVoice_NullReturn
	jrl BmDrEdit_SetFeedbackTimer

; Unless the timer runs with an action other than 2, and only with bit 0 of 0x295f set: moves the
; note 0x2786 down in drum mode (bit 0 of 0x2742), up otherwise (BmDrEdit_DecrementVelocity /
; BmDrEdit_IncrementVelocity, in BmDrEdit_VelocityDown_Check).
BmDrEdit_VelocityUp_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_VelocityUp_Dispatch
	cp (0x295d:16), 2
	ret nz

BmDrEdit_VelocityUp_Dispatch:
	bit 0, (0x295f:16)
	ret z
	bit 0, (0x2742:16)
	jr nz, BmDrEdit_DecrementVelocity
	jr BmDrEdit_IncrementVelocity

; The reverse of BmDrEdit_VelocityUp_Check.  The two bodies after it step the note 0x2786 within
; 1..0x7f (in drum mode through BmDrEdit_DrumVoiceUp / _DrumVoiceDown), write and play it
; (BmDrEdit_UpdateVelocityDisplay), redraw (NoteEditSy_SendScrollCmd3) and set the timer 0x295c =
; 131, 0x295d = 2.
BmDrEdit_VelocityDown_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_VelocityDown_Dispatch
	cp (0x295d:16), 2
	ret nz

BmDrEdit_VelocityDown_Dispatch:
	bit 0, (0x295f:16)
	ret z
	bit 0, (0x2742:16)
	jr nz, BmDrEdit_IncrementVelocity
	jr BmDrEdit_DecrementVelocity

BmDrEdit_IncrementVelocity:
	ld a, (0x2786:16)
	cp a, 0x7f
	ret nc
	inc 1, a
	ld (0x2786:16), a
	bit 0, (0x2742:16)
	call nz, (BmDrEdit_DrumVoiceUp:24)
	calr BmDrEdit_UpdateVelocityDisplay
	call NoteEditSy_SendScrollCmd3
	calr BmDrEdit_NullReturn
	ld (0x295c:16), 131
	ld (0x295d:16), 2
	ret

BmDrEdit_DecrementVelocity:
	ld a, (0x2786:16)
	cp a, 1:i3
	ret z
	dec 1, a
	ld (0x2786:16), a
	bit 0, (0x2742:16)
	call nz, (BmDrEdit_DrumVoiceDown:24)
	calr BmDrEdit_UpdateVelocityDisplay
	call NoteEditSy_SendScrollCmd3
	calr BmDrEdit_NullReturn
	ld (0x295c:16), 131
	ld (0x295d:16), 2
	ret

; Only while the timer is idle: with bit 0 of 0x295f the gate 0x2788 + 1 (BmDrEdit_IncrementGateTime,
; in BmDrEdit_GateOrVelocityDown); otherwise, in drum mode, BmDrEdit_IncrementVelocityValue.
BmDrEdit_GateOrVelocityUp:
	bit 7, (0x295c:16)
	ret nz
	bit 0, (0x295f:16)
	jr nz, BmDrEdit_IncrementGateTime
	bit 0, (0x2742:16)
	ret z
	calr BmDrEdit_IncrementVelocityValue
	ret

; The reverse of BmDrEdit_GateOrVelocityUp.  The two bodies after it step the gate 0x2788 within
; 1..0x7f, then NoteEditSy_SendGateCmd and BmDrEdit_UpdateGateDisplay.
BmDrEdit_GateOrVelocityDown:
	bit 7, (0x295c:16)
	ret nz
	bit 0, (0x295f:16)
	jr nz, BmDrEdit_DecrementGateTime
	bit 0, (0x2742:16)
	ret z
	calr BmDrEdit_DecrementVelocityValue
	ret

BmDrEdit_IncrementGateTime:
	ld a, (0x2788:16)
	cp a, 0x7f
	ret nc
	inc 1, a
	ld (0x2788:16), a
	call NoteEditSy_SendGateCmd
	jrl BmDrEdit_UpdateGateDisplay

BmDrEdit_DecrementGateTime:
	ld a, (0x2788:16)
	cp a, 1:i3
	ret z
	dec 1, a
	ld (0x2788:16), a
	call NoteEditSy_SendGateCmd
	jrl BmDrEdit_UpdateGateDisplay

; Velocity 0x278a + 1, at most 0x7f, then NoteEditSy_SendVelocityCmd (tail jump).
BmDrEdit_IncrementVelocityValue:
	ld a, (0x278a:16)
	cp a, 0x7f
	ret nc
	inc 1, a
	ld (0x278a:16), a
	jp NoteEditSy_SendVelocityCmd

; Velocity 0x278a - 1, at least 1, then NoteEditSy_SendVelocityCmd (tail jump).
BmDrEdit_DecrementVelocityValue:
	ld a, (0x278a:16)
	cp a, 1:i3
	ret z
	dec 1, a
	ld (0x278a:16), a
	jp NoteEditSy_SendVelocityCmd

; Unless the timer runs with an action other than 3: BmDrEdit_IncrementDuration.
BmDrEdit_DurationUp_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_DurationUp_Dispatch
	cp (0x295d:16), 3
	ret nz

BmDrEdit_DurationUp_Dispatch:
	jr BmDrEdit_IncrementDuration

BmDrEdit_DurationDown_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_DurationDown_Dispatch
	cp (0x295d:16), 3
	ret nz

BmDrEdit_DurationDown_Dispatch:
	jr BmDrEdit_DecrementDuration

BmDrEdit_IncrementDuration:
	bit 0, (0x295f:16)
	jr z, BmDrEdit_IncrementDuration_Global
	ld wa, (0x278c:16)
	cp wa, 0x2fff
	ret nc
	inc 1, wa
	ld (0x278c:16), wa
	calr BmDrEdit_CalcDurationPosition
	call NoteEditSy_SendScrollCmd5
	calr BmDrEdit_NullReturn
	ld (0x295c:16), 131
	ld (0x295d:16), 3
	ret

BmDrEdit_IncrementDuration_Global:
	ld wa, (0x278e:16)
	cp wa, 0x2fff
	ret nc
	inc 1, wa
	ld (0x278e:16), wa
	jp NoteEditSy_SendScrollCmd8

BmDrEdit_DecrementDuration:
	bit 0, (0x295f:16)
	jr z, BmDrEdit_DecrementDuration_Global
	ld wa, (0x278c:16)
	cp wa, 0:i3
	jr nz, BmDrEdit_DecrementDuration_Clamp
	ldw (0x278c:16), 1
	jr BmDrEdit_DecrementDuration_Update

BmDrEdit_DecrementDuration_Clamp:
	cp wa, 1:i3
	ret ule
	dec 1, wa
	ld (0x278c:16), wa

BmDrEdit_DecrementDuration_Update:
	calr BmDrEdit_CalcDurationPosition
	call NoteEditSy_SendScrollCmd5
	calr BmDrEdit_NullReturn
	ld (0x295c:16), 131
	ld (0x295d:16), 3
	ret

BmDrEdit_DecrementDuration_Global:
	ld wa, (0x278e:16)
	cp wa, 0:i3
	jr nz, BmDrEdit_DecrementDuration_GlobalClamp
	ldw (0x278e:16), 1
	jr BmDrEdit_DecrementDuration_Send

BmDrEdit_DecrementDuration_GlobalClamp:
	cp wa, 1:i3
	ret z
	dec 1, wa
	ld (0x278e:16), wa

BmDrEdit_DecrementDuration_Send:
	jp NoteEditSy_SendScrollCmd8

; Only while the timer is idle: 0x2792 + 1, at most 0x60, then NoteEditSy_SendModeScrollCmd.
BmDrEdit_ModeScrollUp:
	bit 7, (0x295c:16)
	ret nz
	ld wa, (0x2792:16)
	cp wa, 0x60
	ret nc
	inc 1, wa
	ld (0x2792:16), wa
	jp NoteEditSy_SendModeScrollCmd

; Only while the timer is idle: 0x2792 - 1, at least 1, or 48 when it was 0; then
; NoteEditSy_SendModeScrollCmd.
BmDrEdit_ModeScrollDown:
	bit 7, (0x295c:16)
	ret nz
	ld wa, (0x2792:16)
	cp wa, 0:i3
	jr nz, BmDrEdit_ModeScrollDown_Clamp
	ldw (0x2792:16), 48
	jr BmDrEdit_ModeScrollDown_Send

BmDrEdit_ModeScrollDown_Clamp:
	cp wa, 1:i3
	ret ule
	dec 1, wa
	ld (0x2792:16), wa

BmDrEdit_ModeScrollDown_Send:
	jp NoteEditSy_SendModeScrollCmd

BmDrEdit_SetFeedbackTimer:
	ld (0x295c:16), 133
	ld (0x295d:16), 1
	ret

; Saves the drum/bass editor cursor: 0x275e -> 0x2762 (count), byte 0x2760 -> 0x2764
; (ticks), 0x28af -> 0x2766 (data block), 0x2666 -> 0x2768 (offset).
BmDrEdit_SaveEditState:
	ldmm16 0x2762, 0x275e
	ldmm8 0x2764, 0x2760
	ldmm16 0x2766, SEQ_DATA_BLOCK
	ldmm16 0x2768, SEQ_DATA_OFFSET
	ret

; Restores the editor cursor saved by BmDrEdit_SaveEditState: 0x2762 -> 0x275e, byte 0x2764 ->
; 0x2760, 0x2766 -> 0x28af (block), 0x2768 -> 0x2666 (offset).
BmDrEdit_RestoreEditState:
	ldmm16 0x275e, 0x2762
	ldmm8 0x2760, 0x2764
	ldmm16 SEQ_DATA_BLOCK, 0x2766
	ldmm16 SEQ_DATA_OFFSET, 0x2768
	ret

; Moves the playback position backwards to the previous status byte, following backward block
; links (offset restarts at 0xff); reaching the first block sets SEQ_ERROR_CODE = 0xff.
BmDrEdit_ClearAndScanToEnd:	.include "includes/generated/cc900/BmDrEdit_ClearAndScanToEnd.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_ScanToEnd_Loop, BmDrEdit_ClearAndScanToEnd + 5
	.set	BmDrEdit_ScanToEnd_CheckNextSong, BmDrEdit_ClearAndScanToEnd + 21
	.set	BmDrEdit_ScanToEnd_AdvanceSong, BmDrEdit_ClearAndScanToEnd + 39
	.set	BmDrEdit_ScanToEnd_CheckEndMark, BmDrEdit_ClearAndScanToEnd + 49

; Restores the drum/bass editor's saved cursor: 0x276a -> 0x275e (count), byte 0x276c ->
; 0x2760 (ticks), 0x276e -> 0x28af (data block) and byte 0x2770 -> 0x2666 (offset).
; BmDrEdit_SaveEditState keeps a second copy at 0x2762..0x2768.
BmDrEdit_LoadAlternateState:	.include "includes/generated/cc900/BmDrEdit_LoadAlternateState.s"	; C: cc900/bmdredit_routines_m232.c

; Restores the saved cursor (BmDrEdit_LoadAlternateState) and counts beat markers 0x81 in 0x2772
; while reading events (SeqData_ReadNextByte, SeqData_SkipToNextEvent), until 0x82 or 0x84 or the
; count passes (0x2774).
BmDrEdit_LoadAlternateAndCountNotes:
	calr BmDrEdit_LoadAlternateState
	ldw (0x2772:16), 0

BmDrEdit_CountNotesLoop:
	call SeqData_ReadNextByte
	cp l, 0x82
	ret z
	cp l, 0x84
	ret z
	cp l, 0x81
	jr nz, BmDrEdit_CountNotesLoop_Retry
	ld bc, (0x2772:16)
	inc 1, bc
	ld (0x2772:16), bc
	ld a, (0x2774:16)
	extz wa
	cp bc, wa
	ret ugt

BmDrEdit_CountNotesLoop_Retry:
	call SeqData_SkipToNextEvent
	jr BmDrEdit_CountNotesLoop

BmDrEdit_CheckChannelActive:
	ld e, 0x0:opc
	lda xbc, (SEQ_TRACK_ASSIGN:16)

BmDrEdit_CheckChannelActive_Loop:
	ld a, e
	extz wa
	extz xwa
	add xwa, xbc
	cp (xwa), 0x10
	jr nz, BmDrEdit_CheckChannelActive_Next
	ld bc, 1:i3
	ld a, e
	and a, 0xf
	jr z, BmDrEdit_CheckChannelActive_TestBit
	slaa bc

BmDrEdit_CheckChannelActive_TestBit:
	and bc, (SEQ_TRACK_MASK_COPY:24)
	jr z, BmDrEdit_CheckChannelActive_None
	ld (0x2776:16), 1
	ret

BmDrEdit_CheckChannelActive_Next:
	inc 1, e
	cp e, 0x10
	jr c, BmDrEdit_CheckChannelActive_Loop

BmDrEdit_CheckChannelActive_None:
	ld (0x2776:16), 0
	ret

BmDrEdit_SelectActiveChannel:
	pushw_erp 0xfa
	ldib_erp 0xfb, 0
	lda xbc, (SEQ_TRACK_ASSIGN:16)

BmDrEdit_SelectChannel_Loop:
	ldto_berp A, 0xfb
	extz wa
	extz xwa
	add xwa, xbc
	cp (xwa), 0x10
	jr nz, BmDrEdit_SelectChannel_NextCh
	ld bc, 1:i3
	ldto_berp A, 0xfb
	and a, 0xf
	jr z, BmDrEdit_SelectChannel_TestBit
	slaa bc

BmDrEdit_SelectChannel_TestBit:
	and bc, (SEQ_TRACK_MASK_COPY:24)
	jr z, BmDrEdit_SelectChannel_NotFound
	bit 0, (0x2776:16)
	jr z, BmDrEdit_SelectChannel_NotFound
	ldto_berp C, 0xfb
	inc 1, c
	extz bc
	ld wa, 0:i3
	call Part_ReadVoiceBit7
	cp l, 0:i3
	jr z, BmDrEdit_SelectChannel_NotFound
	ldto_berp A, 0xfb
	inc 1, a
	ld (3414:16), a
	set 0, (3412:16)
	set 2, (SEQ_EDIT_FLAGS:16)
	ldto_berp L, 0xfb
	inc 1, l
	jr BmDrEdit_SelectChannel_Done

BmDrEdit_SelectChannel_NextCh:
	inc1b_erp 0xfb
	cp_erpb 0xfb, 0x10
	jr c, BmDrEdit_SelectChannel_Loop

BmDrEdit_SelectChannel_NotFound:
	res 0, (3412:16)
	res 2, (SEQ_EDIT_FLAGS:16)
	ld l, 0x0:opc

BmDrEdit_SelectChannel_Done:
	popw_erp 0xfa
	ret

; Rounds the cursor tick 0x279a up to the next multiple of the grid step 0x2792 (strictly above
; it).
BmDrEdit_AlignDisplayGrid:
	ld de, 0:i3
	ld wa, (0x279a:16)
	cp wa, 0:i3
	jr c, BmDrEdit_AlignGrid_Store
	ld bc, (0x2792:16)

BmDrEdit_AlignGrid_AccumLoop:
	add de, bc
	cp de, wa
	jr ule, BmDrEdit_AlignGrid_AccumLoop

BmDrEdit_AlignGrid_Store:
	ld (0x279a:16), de
	ret

; In drum mode (bit 0 of 0x2742) compares the note number two bytes after the playback position
; with the editor's note in 0x2786, leaving the position unchanged.
;   Out: L = 0 when they match or the editor is not in drum mode, 0xff otherwise.  Preserves XIZ.
BmDrEdit_CompareVelocity:
	push xiz
	bit 0, (0x2742:16)
	jr z, BmDrEdit_CompareVelocity_Equal
	ld iz, (SEQ_DATA_BLOCK:16)
	ld wa, (SEQ_DATA_OFFSET:16)
	ldfr_werp WA, 0xfa
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	call SeqData_ReadNextByte
	ld (SEQ_DATA_BLOCK:16), iz
	ldto_werp WA, 0xfa
	ld (SEQ_DATA_OFFSET:16), wa
	cp l, (0x2786:16)
	jr z, BmDrEdit_CompareVelocity_Equal
	ld l, 0xff:opc
	jr BmDrEdit_CompareVelocity_Return

BmDrEdit_CompareVelocity_Equal:
	ld l, 0x0:opc

BmDrEdit_CompareVelocity_Return:
	pop xiz
	ret

; Saves the playback position (block 0x28af, offset 0x2666) as the write position of the edited
; part (BMDREDIT_CHANNEL) + 1: entry (BMDREDIT_CHANNEL) of the 4-byte table at 0x23e0.
BmDrEdit_SaveSongPosition:
	ld a, (BMDREDIT_CHANNEL:16)
	inc 1, a
	extz wa
	ld hl, (SEQ_DATA_BLOCK:16)
	ld de, (SEQ_DATA_OFFSET:16)
	dec 1, a
	extz wa
	sla wa, 2
	lda xbc, (9184:16)
	exts xwa
	add xwa, xbc
	ld (xwa), hl
	ld (xwa + 2), de
	ret

; Reads the byte after the playback position into 0x2760 (the tick byte of the note there),
; leaving the position unchanged.  Preserves XIZ.
BmDrEdit_ReadEventAtPosition:
	push xiz
	ld iz, (SEQ_DATA_BLOCK:16)
	ld wa, (SEQ_DATA_OFFSET:16)
	ldfr_werp WA, 0xfa
	call SeqData_AdvancePosition
	call SeqData_ReadNextByte
	ld (0x2760:16), l
	ld (SEQ_DATA_BLOCK:16), iz
	ldto_werp WA, 0xfa
	ld (SEQ_DATA_OFFSET:16), wa
	pop xiz
	ret

; When the event at the playback position is a note-on that BmDrEdit_CompareVelocity accepts,
; continues in BmDrEdit_ReadEventAtPosition; returns otherwise.
BmDrEdit_CheckNoteAtPosition:
	call SeqData_ReadNextByte
	and l, 0xf0
	cp l, 0x90
	ret nz
	calr BmDrEdit_CompareVelocity
	cp l, 0:i3
	ret nz
	jr BmDrEdit_ReadEventAtPosition

BmDrEdit_WalkTrackForward:
	ld a, (0x295f:16)
	res 1, a
	res 4, a
	ld (0x295f:16), a
	call SeqData_ReadNextByte
	cp l, 0x82
	jr z, BmDrEdit_WalkTrack_EndOfTrack
	cp l, 0x84
	jr z, BmDrEdit_WalkTrack_EndOfTrack
	cp l, 0x81
	jr nz, BmDrEdit_WalkTrack_ProcessEvent
	ld bc, (0x275e:16)
	inc 1, bc
	ld (0x275e:16), bc
	ld a, (0x2774:16)
	extz wa
	sub bc, (0x276a:16)
	cp bc, wa
	jr nc, BmDrEdit_WalkTrack_CountExceeded

BmDrEdit_WalkTrack_ProcessEvent:
	call SeqData_SkipToNextEvent
	call SeqData_ReadNextByte
	cp l, 0x82
	jr z, BmDrEdit_WalkTrack_EndOfTrack
	cp l, 0x84
	jr nz, BmDrEdit_WalkTrack_CheckNoteCount

BmDrEdit_WalkTrack_EndOfTrack:
	set 1, (0x295f:16)
	ld (0x2760:16), 0
	ret

BmDrEdit_WalkTrack_CheckNoteCount:
	cp l, 0x81
	jr nz, BmDrEdit_WalkTrack_CheckNoteOn
	ld bc, (0x275e:16)
	inc 1, bc
	ld (0x275e:16), bc
	ld a, (0x2774:16)
	extz wa
	sub bc, (0x276a:16)
	cp bc, wa
	jr c, BmDrEdit_WalkTrack_CheckNoteOn

BmDrEdit_WalkTrack_CountExceeded:
	set 4, (0x295f:16)
	ret

BmDrEdit_WalkTrack_CheckNoteOn:
	and l, 0xf0
	cp l, 0x90
	jr nz, BmDrEdit_WalkTrack_ProcessEvent
	calr BmDrEdit_CompareVelocity
	cp l, 0:i3
	jr nz, BmDrEdit_WalkTrack_ProcessEvent
	jrl BmDrEdit_ReadEventAtPosition

; Converts two (count, ticks) positions into tick counts at 96 ticks per count.
;   In:  XWA -> word that receives (0x275e) * 96 + byte (0x2760);
;        XBC -> word that receives (0x276a) * 96 + byte (0x276c).
BmDrEdit_SetupCoordinates:
	ld xde, xwa
	ldmw2 (xde), 0x275e
	ld xhl, xde
	ld wa, (xhl)
	mul wa, 0x60
	ld (xhl), wa
	ld a, (0x2760:16)
	extz wa
	add (xde), wa
	ldmw2 (xbc), 0x276a
	ld xde, xbc
	ld wa, (xde)
	mul wa, 0x60
	ld (xde), wa
	ld a, (0x276c:16)
	extz wa
	add (xbc), wa
	ret

; Checks whether a note event starts exactly at the editor cursor and, if so, loads it.
;   The cursor positions (BmDrEdit_SetupCoordinates) are compared with 0x279a; the event at the
;   playback position must be a note-on (0x9n) whose velocity BmDrEdit_CompareVelocity
;   accepts.  Then bit 0 of 0x295f is set, the note bytes go to 0x2786 / 0x2788, its length
;   (count * 96 + ticks) to 0x278c, BmDrEdit_ClearAndScanToEnd runs, 0x2786 is copied to 0x2962
;   and the view is scrolled (BmDrEdit_AdjustScrollToView).  Otherwise bit 0 of 0x295f stays
;   clear.
BmDrEdit_SetupAndWalkToNote:	.include "includes/generated/cc900/BmDrEdit_SetupAndWalkToNote.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_SetupAndWalkDone, BmDrEdit_SetupAndWalkToNote + 143

; Searches forward from the playback position for the note under the editor cursor (note-on
; accepted by BmDrEdit_CompareVelocity) up to the next bar / end / track marker.  A match whose
; next byte is 0 leaves the position on it (BmDrEdit_ClearAndScanToEnd); otherwise the saved
; editor state is restored (BmDrEdit_SaveEditState / BmDrEdit_RestoreEditState).
BmDrEdit_SaveAndFindNote:
	calr BmDrEdit_SaveEditState

BmDrEdit_FindNote_Loop:
	call SeqData_ReadNextByte
	cp l, 0x81
	jr z, BmDrEdit_FindNote_EndOfTrack
	cp l, 0x82
	jr z, BmDrEdit_FindNote_EndOfTrack
	cp l, 0x84
	jr z, BmDrEdit_FindNote_EndOfTrack
	and l, 0xf0
	cp l, 0x90
	jr nz, BmDrEdit_FindNote_SkipNonNote
	calr BmDrEdit_CompareVelocity
	cp l, 0:i3
	jr nz, BmDrEdit_FindNote_SkipNonNote
	call SeqData_AdvancePosition
	call SeqData_ReadNextByte
	cp l, 0:i3
	jrl z, BmDrEdit_ClearAndScanToEnd

BmDrEdit_FindNote_EndOfTrack:
	jrl BmDrEdit_RestoreEditState

BmDrEdit_FindNote_SkipNonNote:
	call SeqData_SkipToNextEvent
	jr BmDrEdit_FindNote_Loop

; Clears byte 0 of the eight 3-byte slots at 0x2746.  BmDrEdit_CleanupMelodicMode also jumps here.
BmDrEdit_ClearAllSlots:
	lda xbc, (0x2746:16)
	ld xwa, xbc
	lda xbc, (xbc + 24)

BmDrEdit_ClearSlots_Loop:
	ld (xwa), 0x0
	inc 3, xwa
	cp xwa, xbc
	jr c, BmDrEdit_ClearSlots_Loop
	ret

; BmDrEdit_CheckChannelActive, then tail-jumps to BmDrEdit_SelectActiveChannel.
BmDrEdit_CheckAndSelectChannel:
	calr BmDrEdit_CheckChannelActive
	jrl BmDrEdit_SelectActiveChannel

BmDrEdit_FindNoteInSlots:
	pushw iz
	ldw iy, 0x8
	bit 0, (0x2742:16)
	jr z, BmDrEdit_FindNote_SetupLoop
	ld iy, 1:i3

BmDrEdit_FindNote_SetupLoop:
	ld iz, 0:i3
	cp iy, 0:i3
	jr ule, BmDrEdit_FindNote_NotFound
	lda xix, (0x2746:16)

BmDrEdit_FindNote_SlotLoop:
	ld bc, iz
	mul bc, 0x3
	ld hl, bc
	extz xhl
	add xhl, xix
	ld a, (xhl)
	bit 7, a
	jr z, BmDrEdit_FindNote_NextSlot
	ld de, 1:i3
	add de, bc
	extz xde
	add xde, xix
	ld c, (xde)
	cp c, (0x2960:16)
	jr nz, BmDrEdit_FindNote_NextSlot
	res 7, a
	ld (xhl), a
	ld l, (xde)
	extz hl
	jr BmDrEdit_FindNote_Return

BmDrEdit_FindNote_NextSlot:
	inc 1, iz
	cp iz, iy
	jr c, BmDrEdit_FindNote_SlotLoop

BmDrEdit_FindNote_NotFound:
	ldw hl, 0xff

BmDrEdit_FindNote_Return:
	popw iz
	ret

; Clears byte 0 of each 3-byte entry from 0x2747 to 0x2747 + 24 (eight entries).
BmDrEdit_ClearAllSlotsAlt:
	lda xbc, (0x2747:16)
	ld xwa, xbc
	lda xbc, (xbc + 24)

BmDrEdit_ClearSlotsAlt_Loop:
	ld (xwa), 0x0
	inc 3, xwa
	cp xwa, xbc
	jr c, BmDrEdit_ClearSlotsAlt_Loop
	ret

; HL = 0xff when any of the eight 3-byte slots at 0x2746 is in use (bit 7 of byte 0), else 0.
BmDrEdit_CheckSlotsAvailable:
	ld de, 0:i3
	lda xbc, (0x2746:16)

BmDrEdit_CheckSlots_Loop:
	ld wa, de
	mul wa, 0x3
	extz xwa
	add xwa, xbc
	bitm 7, (xwa)
	jr z, BmDrEdit_CheckSlots_Next
	ldw hl, 0xff
	ret

BmDrEdit_CheckSlots_Next:
	inc 1, de
	cp de, 0x8
	jr c, BmDrEdit_CheckSlots_Loop
	ld hl, 0:i3
	ret

; From the grid tick 0x279a: 0x2760 = tick mod 96 and 0x275e = tick / 96 + (0x276a).
; BmDrEdit_WalkEventsOrSetError also jumps here.
BmDrEdit_CalcBeatFromGridPos:
	ld wa, (0x279a:16)
	extz xwa
	div wa, 0x60
	ldto_werp WA, 0xe2
	ld (0x2760:16), a
	ld wa, (0x279a:16)
	extz xwa
	div wa, 0x60
	ld (0x275e:16), wa
	ld wa, (0x276a:16)
	add (0x275e:16), wa
	ret

; -----------------------------------------------------------------------------
; Four unreferenced routines, `.byte` until 2026-09-25 (both decoders agree:
; notes/sequi-2026-09-25/reframe-v10-bmdredit_routines.log).  NO CALLER FOUND
; for any of the four entry points: scripts/analysis/sequi_find_refs.py v10
; 0xF36C93 0xF36CAC 0xF36CC5 0xF36CDF -> no hit at an instruction start.
;
; BmDrEdit_SavePositionVars / BmDrEdit_RestorePositionVars: copy the four
; variables 0x275e, 0x2760 (byte), 0x28af, 0x2666
; to 0x2778, 0x277a, 0x277c, 0x277e and back.  (The first two are the
; beat position BmDrEdit_CalcBeatFromGridPos writes.)
; -----------------------------------------------------------------------------
BmDrEdit_SavePositionVars:
	ldmm16 0x2778, 0x275e
	ldmm8 0x277a, 0x2760
	ldmm16 0x277c, SEQ_DATA_BLOCK
	ldmm16 0x277e, SEQ_DATA_OFFSET
	ret
BmDrEdit_RestorePositionVars:
	ldmm16 0x275e, 0x2778
	ldmm8 0x2760, 0x277a
	ldmm16 SEQ_DATA_BLOCK, 0x277c
	ldmm16 SEQ_DATA_OFFSET, 0x277e
	ret

; Unreferenced near-duplicate of BmDrEdit_ModeScrollUp (same test of bit 7 of
; RAM 0x295C, same 0x60 ceiling, same tail jump).
BmDrEdit_ModeScrollUp_Dup:
	bit 7, (0x295c:16)
	ret	nz
	ld	wa, (10130:16)
	cp	wa, 96
	ret	nc
	inc	1, wa
	ld	(10130:16), wa
	jp	NoteEditSy_SendModeScrollCmd

; Unreferenced near-duplicate of BmDrEdit_ModeScrollDown (0 -> 48, else
; decrement down to 1); ends in `call ...; ret` where the live one has `jp`.
BmDrEdit_ModeScrollDown_Dup:
	bit 7, (0x295c:16)
	ret	nz
	ld	wa, (10130:16)
	cp	wa, 0:i3
	jr	nz, BmDrEdit_ModeScrollDown_Dup_Clamp
	ldw	(10130:16), 48
	jr	BmDrEdit_ModeScrollDown_Dup_Send
BmDrEdit_ModeScrollDown_Dup_Clamp:
	cp	wa, 1:i3
	ret	ule
	dec	1, wa
	ld	(10130:16), wa
BmDrEdit_ModeScrollDown_Dup_Send:
	call	NoteEditSy_SendModeScrollCmd
	ret

; Unless the timer runs with an action other than 4: 0x2798 + 1, at most 9,
; NoteEditSy_UpdateChordDisplay, and the timer 0x295c = 129, 0x295d = 4.
BmDrEdit_ChordScrollUp_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_ChordScrollUp
	cp (0x295d:16), 4
	ret nz

BmDrEdit_ChordScrollUp:
	ld a, (NOTEEDIT_BASE_KEY:16)
	cp a, 0x9
	ret nc
	inc 1, a
	ld (NOTEEDIT_BASE_KEY:16), a
	call NoteEditSy_UpdateChordDisplay
	ld (0x295c:16), 129
	ld (0x295d:16), 4
	ret

; Unless the timer runs with an action other than 4: 0x2798 - 1, at least 0,
; NoteEditSy_UpdateChordDisplay, and the timer 0x295c = 129, 0x295d = 4.
BmDrEdit_ChordScrollDown_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_ChordScrollDown
	cp (0x295d:16), 4
	ret nz

BmDrEdit_ChordScrollDown:
	ld a, (NOTEEDIT_BASE_KEY:16)
	cp a, 0:i3
	ret z
	dec 1, a
	ld (NOTEEDIT_BASE_KEY:16), a
	call NoteEditSy_UpdateChordDisplay
	ld (0x295c:16), 129
	ld (0x295d:16), 4
	ret

; Returns at once (the no-op case of the velocity and duration down checks).
BmDrEdit_NullReturn:
	ret

BmDrEdit_PitchWrapToEnd:
	ld wa, (0x2782:16)
	cp wa, 0:i3
	jr z, BmDrEdit_PitchWrapPrevPage
	ld (0x2784:16), 95
	ld wa, (0x2782:16)
	dec 1, wa
	ld (0x2782:16), wa
	jr BmDrEdit_PitchWrap_UpdateDisplay

BmDrEdit_PitchWrapPrevPage:
	ld wa, (0x2744:16)
	cp wa, (0x27b2:16)
	jr z, BmDrEdit_PitchWrap_CheckEnd
	calr BmDrEdit_CalcEventPosition
	decw 1, (0x2744:16)
	ld (0x2784:16), 95
	call NoteEditSy_SendScrollCmd0

BmDrEdit_PitchWrap_UpdateDisplay:
	call NoteEditSy_SendScrollCmd2
	call NoteEditSy_SendScrollCmd1
	calr NoteEditSy_CallFarRoutine
	jrl BmDrEdit_SetFeedbackTimer

BmDrEdit_PitchWrap_CheckEnd:
	bit 0, (0x295f:16)
	jrl z, BmDrEdit_NavigatePrevPage
	cp wa, 1:i3
	ret z
	ld (0x295c:16), 0
	calr ReadSeqData_StoreParams
	jrl BmDrEdit_NavigateToPrevAndDisplay

; Writes the editor note length 0x278c into the note at the playback position (a 0x9n event,
; status = byte 0): byte 4 = length mod 96, byte 5 = length / 96 (both with bit 7 cleared), then
; restores the cursor (BmDrEdit_RestoreEditState).
BmDrEdit_CalcDurationPosition:
	calr BmDrEdit_SaveEditState
	call SeqData_ReadNextByte
	and l, 0xf0
	cp l, 0x90
	ret nz
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	ld wa, (0x278c:16)
	extz xwa
	div wa, 0x60
	ldto_werp WA, 0xe2
	and wa, 0x7f
	extz wa
	call PartCtrl_WriteByte_Indexed
	call SeqData_AdvancePosition
	ld wa, (0x278c:16)
	extz xwa
	div wa, 0x60
	and wa, 0x7f
	extz wa
	call PartCtrl_WriteByte_Indexed
	jrl BmDrEdit_RestoreEditState

BmDrEdit_UpdateGateDisplay:
	calr BmDrEdit_SaveEditState
	call SeqData_ReadNextByte
	and l, 0xf0
	cp l, 0x90
	ret nz
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	ld l, (0x2788:16)
	extz hl
	ld wa, hl
	call PartCtrl_WriteByte_Indexed
	calr BmDrEdit_RestoreEditState
	jrl BmDrEdit_SendMetronomeNoteOn

; Writes the editor note number 0x2786 into byte 2 (status = byte 0) of the note at the playback
; position (a 0x9n event), restores the cursor and plays the note (BmDrEdit_SendMetronomeNoteOn).
BmDrEdit_UpdateVelocityDisplay:
	calr BmDrEdit_SaveEditState
	call SeqData_ReadNextByte
	and l, 0xf0
	cp l, 0x90
	ret nz
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	ld l, (0x2786:16)
	extz hl
	ld wa, hl
	call PartCtrl_WriteByte_Indexed
	calr BmDrEdit_RestoreEditState
	jrl BmDrEdit_SendMetronomeNoteOn

; Clears bit 0 of 0x295f, sets the note from the cursor row (BmDrEdit_CalcTrackPosition), copies
; note 0x2786 to 0x2960, byte 0x278a to 0x2961 and to 0x2788, plays the note
; (BmDrEdit_PlayNoteAndSetDelay), inserts it (BmDrEdit_WalkEventsOrSetError) and goes on to
; BmDrEdit_RefreshAfterInsert.
BmDrEdit_InsertNoteEvent:
	res 0, (0x295f:16)
	calr BmDrEdit_CalcTrackPosition
	ldmm8 0x2960, 0x2786
	ld a, (0x278a:16)
	ld (0x2961:16), a
	ldmm8 0x2788, 0x278a
	calr BmDrEdit_PlayNoteAndSetDelay
	calr BmDrEdit_WalkEventsOrSetError
	jr BmDrEdit_RefreshAfterInsert

BmDrEdit_SendWidgetCmd:
	bit 0, (0x2742:16)
	ret z
	jp NoteEditSy_SendWidgetCmdE

; When the measure 0x2744 is above 1: rescans from the measure before (BmDrEdit_SelectChannelAndLoadPos,
; BmDrEdit_LoadAlternateState, BmDrEdit_ScanChannelEvents), puts the measure back, clears the
; cursor 0x2782 / 0x2784, reloads the position, row list and note under the cursor and redraws the
; editor widgets.  BmDrEdit_NullReturn also jumps here.
BmDrEdit_NavigatePrevPage:
	ld wa, (0x2744:16)
	cp wa, 1:i3
	ret ule
	dec 1, wa
	ld (0x2744:16), wa
	calr BmDrEdit_SelectChannelAndLoadPos
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_ScanChannelEvents
	incw 1, (0x2744:16)
	ldw (0x2782:16), 0
	ld (0x2784:16), 0
	calr BmDrEdit_LoadAlternatePosition
	calr BmDrEdit_BuildVoiceList
	calr BmDrEdit_SetupAndWalkToNote
	calr NoteEditSy_SendCompoundWidgetUpdate
	calr NoteEdit_UpdateScrollAndDisplay
	call NoteEditSy_SendWidgetCmd0
	jrl NoteEdit_SendScrollCmds

; BmDrEdit_AlignDisplayGrid and BmDrEdit_InsertNoteSequence; an insert error (bit 2 of 0x295f)
; records 0xd0 (SeqData_SetErrorCode) and leaves through BmDrEdit_RefreshDisplayState.  When the
; cursor tick 0x279a has reached the page end ((0x2774) * 96), BmDrEdit_NavigateAndLoadPosition;
; otherwise BmDrEdit_CalcBeatMeasure and the widget redraws.
BmDrEdit_RefreshAfterInsert:
	calr BmDrEdit_AlignDisplayGrid
	calr BmDrEdit_InsertNoteSequence
	bit 2, (0x295f:16)
	jr z, BmDrEdit_RefreshAfterInsert_CheckFull
	ldw wa, 0xd0
	call SeqData_SetErrorCode
	jrl BmDrEdit_RefreshDisplayState

BmDrEdit_RefreshAfterInsert_CheckFull:
	ld a, (0x2774:16)
	mul a, 0x60
	cp (0x279a:16), wa
	jrl nc, BmDrEdit_NavigateAndLoadPosition
	calr BmDrEdit_CalcBeatMeasure
	call NoteEditSy_SendWidgetCmd0
	calr NoteEdit_SendScrollCmds
	jrl NoteEdit_UpdateScrollAndDisplay

; Returns the visible row range of the note editor.
;   In:  XWA -> first row byte, XBC -> second row byte.  Drum mode (bit 0 of 0x2742): (0x279e)
;   and (0x279e) + 11.  Melodic mode: the two bytes of WidgetData_DrawbarPositionTable for the
;   scroll index 0x2798.
BmDrEdit_SetupScrollRegion:	.include "includes/generated/cc900/BmDrEdit_SetupScrollRegion.s"	; C: cc900/bmdredit_routines.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_SetupScrollRegion_MelodicMode, BmDrEdit_SetupScrollRegion + 24

; -----------------------------------------------------------------------------
; BmDrEdit_TestPartTableEntry -- A := RAM 0x2965 (a MIDI channel), code :=
; RAM 0xF1A0[A] (the channel's part-type code, cf. SMF_HeaderConstants),
; XWA := the 32-bit pointer at 0xE4448E + code*4; returns HL = 0 when the byte
; that pointer addresses is >= 0xF0, else HL = 0xFFFF.
; NO CALLER FOUND: scripts/analysis/sequi_find_refs.py v10 0xF36F30 -> none.
; Was `.byte` (named ByteData_ScrollParams) until 2026-09-25.  What the
; pointer table at 0xE4448E is, is not established here.
; -----------------------------------------------------------------------------
BmDrEdit_TestPartTableEntry:
	ld a, (BMDREDIT_CHANNEL:16)
	extz wa
	lda_d16 xbc, (SEQ_TRACK_ASSIGN)
	extz xwa
	add xwa, xbc
	ld a, (xwa)
	extz wa
	sla wa, 2
	lda xbc, (Seq_TrackAssignPartRecordPtrs:24)
	ld	xwa, (xbc+wa)
	cp (xwa), 240
	jr c, BmDrEdit_TestPartTableEntry_Below
	ld hl, 0:i3
	ret
BmDrEdit_TestPartTableEntry_Below:
	ldw hl, 0xffff
	ret

; Enters the drum editor: Malloc(0x6a4) into 0x1d50 and 0x1d54, NoteEditSy_ScanAndSortEntries,
; 0x278e = 10, grid step 0x2792 = (0x2796), drum mode (bit 0 of 0x2742) set, 0x2774 = 7, 0x27a2 = 8;
; then BmDrEdit_InitCommon.
BmDrEdit_InitDrumMode:	.include "includes/generated/cc900/BmDrEdit_InitDrumMode.s"	; C: cc900/bmdredit_routines_m232.c

BmDrEdit_InitMelodicMode:	.include "includes/generated/cc900/BmDrEdit_InitMelodicMode.s"	; C: cc900/bmdredit_routines_m232.c

BmDrEdit_InitCommon:
	pushw iz
	cpw (0x2792:16), 0
	jr nz, BmDrEdit_InitCommon_CheckSongActive
	ldw (0x2792:16), 48

BmDrEdit_InitCommon_CheckSongActive:
	ld a, (CURRENT_TITLE:16)
	cp a, (PREVIOUS_TITLE:16)
	jr nz, BmDrEdit_InitCommon_SetupDisplay
	ld a, (ACTIVE_TITLE:16)
	cp a, (ACTIVE_TITLE_PREVIOUS:16)
	jr z, BmDrEdit_InitCommon_SetupDisplay
	bit 4, (DEMO_CONTROL_FLAGS:16)
	jr z, BmDrEdit_InitCommon_SetupDisplay
	ld wa, MD_NORMAL:i3
	call UI_ChangeModeByIndex
	res 4, (DEMO_CONTROL_FLAGS:16)
	res 0, (9834:16)
	jrl BmDrEdit_PopIzAndReturn

BmDrEdit_InitCommon_SetupDisplay:
	set 0, (9834:16)
	set 0, (9954:16)
	call AccWrap_PlayModeDispatch
	set 2, (SEQ_RTMCFG:16)
	ld (0x295c:16), 0
	ld wa, (0x2963:16)
	ld (3407:16), wa
	ldmm16 3409, 0x2963
	ld a, (ACTIVE_TITLE_PREVIOUS:16)
	cp a, 0x96
	jr z, BmDrEdit_CopyStepCount
	cp a, 0x99
	jr z, BmDrEdit_CopyStepCount
	cp a, 0x94
	jr z, BmDrEdit_SetRecordingFlag
	cp a, 0x97
	jr nz, BmDrEdit_CheckDrumModeEntry

BmDrEdit_SetRecordingFlag:
	set 0, (0x8d88:16)
	jr BmDrEdit_ReadVoiceBitAndCopy

BmDrEdit_CheckDrumModeEntry:
	bit 0, (0x2742:16)
	jrl z, BmDrEdit_FlagDisplayUpdate
	ld a, (0x295b:16)
	bit 0, a
	jrl z, BmDrEdit_FlagDisplayUpdate
	res 0, a
	ld (0x295b:16), a

BmDrEdit_ReadVoiceBitAndCopy:
	ld c, (BMDREDIT_CHANNEL:16)
	inc 1, c
	extz bc
	ld wa, 0:i3
	call Part_ReadVoiceBit7
	cp l, 0:i3
	jr z, BmDrEdit_InitFirstStep

BmDrEdit_CopyStepCount:
	ldmm16 0x2744, SEQ_START_MEASURE
	jrl BmDrEdit_InitPlayback

BmDrEdit_InitFirstStep:
	ldw (0x2744:16), 1
	cpw (SEQ_FREE_BLOCKS:16), 0
	jrl z, BmDrEdit_RefreshAndReturn
	call Part_ProcessAndDecrementVoice
	ld iz, hl
	ld wa, iz
	ld bc, 1:i3
	call PartCtrl_SetClearBit7
	ld wa, iz
	ld bc, 0:i3
	call PartCtrl_WriteWord_Off1
	ld wa, iz
	ldw bc, 0xffff
	call PartCtrl_WriteWord
	ld c, (BMDREDIT_CHANNEL:16)
	inc 1, c
	extz bc
	ld wa, 0:i3
	ld de, 1:i3
	call Part_SetClearVoiceBit7
	ld c, (BMDREDIT_CHANNEL:16)
	inc 1, c
	extz bc
	ld wa, 0:i3
	ld de, iz
	call Part_WriteVoiceWord
	ld c, (BMDREDIT_CHANNEL:16)
	inc 1, c
	extz bc
	ld wa, 0:i3
	ld de, iz
	call Part_WriteWord_Indexed
	ld c, (BMDREDIT_CHANNEL:16)
	inc 1, c
	extz bc
	ld wa, 0:i3
	ld de, 5:i3
	call Part_WriteByte_Indexed
	ld (SEQ_DATA_BLOCK:16), iz
	ldw (SEQ_DATA_OFFSET:16), 5
	calr BmDrEdit_InsertStepEntry
	incw 1, (SEQ_DATA_OFFSET:16)
	calr BmDrEdit_InsertStepEntry

BmDrEdit_InitPlayback:
	calr Metronome_PlayClick
	call TempoRingBuf_Init
	call SeqBuf_Init
	calr BmDrEdit_ClearAllSlotsAlt
	calr BmDrEdit_ClearAllSlots
	calr BmDrEdit_SelectChannelAndLoadPos
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_ResetAndScanNotes
	ldw (0x2744:16), 1
	calr BmDrEdit_SelectChannelAndLoadPos
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_ResetAndScanNotes

BmDrEdit_RefreshAndReturn:
	calr BmDrEdit_RefreshDisplayState
	jr BmDrEdit_PopIzAndReturn

BmDrEdit_ResetAndScanNotes:
	ldw (0x279a:16), 0
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_CalcTrackPosition
	calr BmDrEdit_SaveAndFindNote
	calr BmDrEdit_CheckNoteAtPosition
	calr BmDrEdit_SetupAndWalkToNote
	ldw (0x2782:16), 0
	ld (0x2784:16), 0
	calr BmDrEdit_ScanChannelEvents

BmDrEdit_FlagDisplayUpdate:
	call Audio_CheckSubsystemReady
	set 0, (0x27b0:16)

BmDrEdit_PopIzAndReturn:
	popw iz
	ret

; Leaves the drum editor: saves the grid step 0x2792 in 0x2796, frees (0x1d50) and, unless
; CURRENT_TITLE is 152, clears bit 0 of 0x26e2 with PartSelect_UpdateDisplayState; then
; BmDrEdit_CleanupCommon.
BmDrEdit_CleanupDrumMode:
	ldmm16 0x2796, 0x2792
	ld xwa, (7504:16)
	push xwa
	call Free
	inc 4, xsp
	cp (CURRENT_TITLE:16), 152
	jr z, BmDrEdit_SkipPartSelect
	res 0, (9954:16)
	call PartSelect_UpdateDisplayState

BmDrEdit_SkipPartSelect:
	jr BmDrEdit_CleanupCommon

; Leaves the note editor: unless CURRENT_TITLE is 149, clears bit 0 of 0x26e2 with
; PartSelect_UpdateDisplayState; saves 0x2792 in 0x2794 and 0x278e in 0x2790.  The common tail
; after it clears bit 2 of 0x28a7 and the timer 0x295c, ORs word 0xd4f into 0xffec and clears 0xd4f
; / 0xd51, copies the measure 0x2744 to 0x2668, runs Audio_CheckSubsystemReady, clears bit 0 of
; 0x27b0 and empties both slot lists (BmDrEdit_ClearAllSlotsAlt, BmDrEdit_ClearAllSlots).
BmDrEdit_CleanupMelodicMode:
	cp (CURRENT_TITLE:16), 149
	jr z, BmDrEdit_SkipMelodicPartSelect
	res 0, (9954:16)
	call PartSelect_UpdateDisplayState

BmDrEdit_SkipMelodicPartSelect:
	ldmm16 0x2794, 0x2792
	ldmm16 0x2790, 0x278e
	jr BmDrEdit_CleanupCommon

BmDrEdit_CleanupCommon:
	res 2, (SEQ_RTMCFG:16)
	ld (0x295c:16), 0
	ld wa, (3407:16)
	or (SEQ_TRACK_MASK_COPY:24), wa
	ldw (3407:16), 0
	ldw (3409:16), 0
	ldmm16 SEQ_START_MEASURE, 0x2744
	call Audio_CheckSubsystemReady
	res 0, (0x27b0:16)
	calr BmDrEdit_ClearAllSlotsAlt
	jrl BmDrEdit_ClearAllSlots

BmDrEdit_InsertNotesFromSlots:	.include "includes/generated/cc900/BmDrEdit_InsertNotesFromSlots.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_InsertNotesFromSlots_MelodicInit, BmDrEdit_InsertNotesFromSlots + 24
	.set	BmDrEdit_InsertNotesFromSlots_Loop, BmDrEdit_InsertNotesFromSlots + 26
	.set	BmDrEdit_InsertNotesFromSlots_CalcBeat, BmDrEdit_InsertNotesFromSlots + 81
	.set	BmDrEdit_InsertNotesFromSlots_Next, BmDrEdit_InsertNotesFromSlots + 84
	.set	BmDrEdit_InsertNotesFromSlots_Done, BmDrEdit_InsertNotesFromSlots + 92

; Inserts the note being edited (BmDrEdit_PrepareAndInsertNote); on success continues in
; BmDrEdit_CalcBeatFromGridPos, on failure records 0xcf and leaves through
; BmDrEdit_RefreshDisplayState.
BmDrEdit_WalkEventsOrSetError:
	calr BmDrEdit_PrepareAndInsertNote
	cp (SEQ_ERROR_CODE:16), 0
	jrl z, BmDrEdit_CalcBeatFromGridPos
	ldw wa, 0xcf
	call SeqData_SetErrorCode
	jrl BmDrEdit_RefreshDisplayState

BmDrEdit_WalkToGridPosition:
	dec 4, xsp
	calr BmDrEdit_LoadAlternateState
	cpw (0x279a:16), 0
	jr nz, BmDrEdit_WalkToGrid_ReadNext
	jr BmDrEdit_CleanupReturn

BmDrEdit_WalkToGrid_CheckEvent:
	cp l, 0x82
	jr z, BmDrEdit_CleanupReturn
	calr BmDrEdit_ReadEventAtPosition
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	sub wa, (xsp)
	cp wa, (0x279a:16)
	jr ugt, BmDrEdit_CleanupReturn

BmDrEdit_WalkToGrid_SkipEvent:
	call SeqData_SkipToNextEvent

BmDrEdit_WalkToGrid_ReadNext:
	call SeqData_ReadNextByte
	cp l, 0x81
	jr nz, BmDrEdit_WalkToGrid_CheckEvent
	ld (0x2760:16), 0
	incw 1, (0x275e:16)
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	sub wa, (xsp)
	cp wa, (0x279a:16)
	jr ule, BmDrEdit_WalkToGrid_SkipEvent

BmDrEdit_CleanupReturn:
	inc 4, xsp
	ret

BmDrEdit_HandleDelayExpired_Rescan:
	calr Metronome_PlayClick
	calr BmDrEdit_SelectChannelAndLoadPos
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_Rescan_LoadAlternate
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr nz, BmDrEdit_Rescan_RefreshDisplay
	calr BmDrEdit_SelectChannelAndLoadPos

BmDrEdit_Rescan_LoadAlternate:
	calr BmDrEdit_ScanChannelEvents
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_ValidateAndInsertSteps
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_Rescan_CalcAndWalk

BmDrEdit_Rescan_RefreshDisplay:
	jrl BmDrEdit_RefreshDisplayState

BmDrEdit_Rescan_CalcAndWalk:
	calr BmDrEdit_CalcTrackPosition
	calr BmDrEdit_SaveAndFindNote
	calr BmDrEdit_CheckNoteAtPosition
	calr BmDrEdit_SetupAndWalkToNote
	call NoteEditSy_SendWidgetCmd0
	calr NoteEdit_SendScrollCmds
	calr NoteEditSy_SendCompoundWidgetUpdate
	jrl NoteEdit_UpdateScrollAndDisplay

; SEQ_ERROR_CODE = 0; saves the cursor (an error records 0xb6) and counts the measures
; (BmDrEdit_CountMeasuresAndValidate).  When the count 0x2772 is 0 it inserts two bar markers
; (EditChannel_LoadVoiceParams, BmDrEdit_InsertStepEntry, stopping on an error); then restores the
; cursor (BmDrEdit_RestoreEditState).
BmDrEdit_ValidateAndInsertSteps:
	ld (SEQ_ERROR_CODE:16), 0
	calr BmDrEdit_SaveEditState
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_ValidateSteps_CheckCount
	ldw wa, 0xb6
	call SeqData_SetErrorCode

BmDrEdit_ValidateSteps_CheckCount:
	calr BmDrEdit_CountMeasuresAndValidate
	cpw (0x2772:16), 0
	ret nz
	ldw (0x2772:16), 2

BmDrEdit_ValidateSteps_InsertLoop:
	calr EditChannel_LoadVoiceParams
	calr BmDrEdit_InsertStepEntry
	cp (SEQ_ERROR_CODE:16), 0
	jr nz, BmDrEdit_ValidateSteps_RestoreState
	ld wa, (0x2772:16)
	dec 1, wa
	ld (0x2772:16), wa
	cp wa, 0:i3
	jr nz, BmDrEdit_ValidateSteps_InsertLoop

BmDrEdit_ValidateSteps_RestoreState:
	jrl BmDrEdit_RestoreEditState

; Points the editor at the start of the part being edited and re-inserts its step entries.
;   The part is (BMDREDIT_CHANNEL) + 1; its first data block comes from the voice table of song slot 0
;   (Part_ReadVoiceWord), returning at once when it is 0xffff.  Sets 0x28af / 0x2666 = block / 5
;   (error 0xb7 if an error was pending), counts the measures (BmDrEdit_CountMeasuresAndValidate),
;   then repeats EditChannel_LoadVoiceParams + BmDrEdit_InsertStepEntry (0x2782) + 2 times,
;   counting down in 0x2772.  Any error goes to BmDrEdit_RefreshDisplayState.
BmDrEdit_SeekToPartVoice:
	ld c, (BMDREDIT_CHANNEL:16)
	inc 1, c
	extz bc
	ld wa, 0:i3
	call Part_ReadVoiceWord
	cp hl, 0xffff
	ret z
	ld (SEQ_DATA_BLOCK:16), hl
	ldw (SEQ_DATA_OFFSET:16), 5
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_SeekVoice_CountAndInsert
	ldw wa, 0xb7
	call SeqData_SetErrorCode

BmDrEdit_SeekVoice_CountAndInsert:
	calr BmDrEdit_CountMeasuresAndValidate
	calr BmDrEdit_InsertMultiSongSteps
	cp (SEQ_ERROR_CODE:16), 0
	jr nz, BmDrEdit_SeekVoice_RefreshDisplay
	ld wa, (0x2782:16)
	inc 2, wa
	ld (0x2772:16), wa
	cp wa, 0:i3
	ret z

BmDrEdit_SeekVoice_InsertLoop:
	calr EditChannel_LoadVoiceParams
	calr BmDrEdit_InsertStepEntry
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_SeekVoice_DecrementLoop

BmDrEdit_SeekVoice_RefreshDisplay:
	jrl BmDrEdit_RefreshDisplayState

BmDrEdit_SeekVoice_DecrementLoop:
	ld wa, (0x2772:16)
	dec 1, wa
	ld (0x2772:16), wa
	cp wa, 0:i3
	jr nz, BmDrEdit_SeekVoice_InsertLoop
	ret

; Advances the page if needed (BmDrEdit_CheckAndAdvancePage) and sets the cursor tick 0x279a =
; (0x2782) * 96 + (0x2784).
BmDrEdit_CalcTickPosition:
	calr BmDrEdit_CheckAndAdvancePage
	ld bc, (0x2782:16)
	mul bc, 0x60
	ld a, (0x2784:16)
	extz wa
	add bc, wa
	ld (0x279a:16), bc
	ret

BmDrEdit_ReloadChannelAndDisplay:
	calr BmDrEdit_SelectChannelAndLoadPos
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_ReloadChannel_LoadAndSkip
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr nz, BmDrEdit_ReloadChannel_RefreshDisplay
	calr BmDrEdit_SelectChannelAndLoadPos

BmDrEdit_ReloadChannel_LoadAndSkip:
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_SkipToEventByCount
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_LoadAndDisplayNotes
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_LoadAndDisplayNotes

BmDrEdit_ReloadChannel_RefreshDisplay:
	jrl BmDrEdit_RefreshDisplayState

BmDrEdit_LoadAndDisplayNotes:
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_ScanChannelEvents
	calr BmDrEdit_SyncSeekCheck
	calr BmDrEdit_SetupAndWalkToNote
	calr NoteEditSy_SendCompoundWidgetUpdate
	calr NoteEdit_UpdateScrollAndDisplay
	call NoteEditSy_SendWidgetCmd0
	calr NoteEdit_SendScrollCmds
	bit 0, (0x295f:16)
	ret z
	calr BmDrEdit_SendMetronomeNoteOn
	ret

; Moves the editor to the cursor tick (BmDrEdit_CalcTickPosition), selects the channel and seeks the
; position (BmDrEdit_LoadAlternateState, BmDrEdit_SkipToEventByCount), re-seeking the part
; (BmDrEdit_SeekToPartVoice) after an error and leaving through BmDrEdit_RefreshDisplayState if
; that fails too.  Then finds the note under the cursor, redraws the widgets and, with bit 0 of
; 0x295f set, plays it (BmDrEdit_SendMetronomeNoteOn).  Three other routines jump here.
BmDrEdit_NavigateAndLoadPosition:
	calr BmDrEdit_CalcTickPosition
	calr BmDrEdit_SelectChannelAndLoadPos
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_NavLoad_LoadAndSkip
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr nz, BmDrEdit_NavLoad_RefreshDisplay
	calr BmDrEdit_SelectChannelAndLoadPos

BmDrEdit_NavLoad_LoadAndSkip:
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_SkipToEventByCount
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_NavigateAndDisplayNotes
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_NavigateAndDisplayNotes

BmDrEdit_NavLoad_RefreshDisplay:
	jrl BmDrEdit_RefreshDisplayState

BmDrEdit_NavigateAndDisplayNotes:
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_ScanChannelEvents
	calr BmDrEdit_SyncSeekCheck
	calr BmDrEdit_SaveAndFindNote
	calr BmDrEdit_CheckNoteAtPosition
	calr BmDrEdit_SetupAndWalkToNote
	calr NoteEditSy_SendCompoundWidgetUpdate
	calr NoteEdit_UpdateScrollAndDisplay
	call NoteEditSy_SendWidgetCmd0
	calr NoteEdit_SendScrollCmds
	bit 0, (0x295f:16)
	ret z
	calr BmDrEdit_SendMetronomeNoteOn
	ret

BmDrEdit_SkipToEventByCount:
	ld (SEQ_ERROR_CODE:16), 0
	ld wa, (0x2782:16)
	cp wa, 0:i3
	ret z
	ld (0x2772:16), wa
	cp wa, 0:i3
	ret z

BmDrEdit_SkipToEvent_ReadLoop:
	call SeqData_ReadNextByte
	cp l, 0x81
	jr nz, BmDrEdit_SkipToEvent_EndOfTrack
	decw 1, (0x2772:16)

BmDrEdit_SkipToEvent_SkipAndCheck:
	call SeqData_SkipToNextEvent
	cpw (0x2772:16), 0
	jr nz, BmDrEdit_SkipToEvent_ReadLoop
	ret

BmDrEdit_SkipToEvent_EndOfTrack:
	cp l, 0x82
	jr nz, BmDrEdit_SkipToEvent_SkipAndCheck
	ld (SEQ_ERROR_CODE:16), 255
	ret

BmDrEdit_NavigateToPrevAndDisplay:
	ld wa, (0x2744:16)
	cp wa, 1:i3
	ret ule
	dec 1, wa
	ld (0x2744:16), wa
	calr BmDrEdit_SelectChannelAndLoadPos
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_ScanChannelEvents
	incw 1, (0x2744:16)
	ldw (0x2782:16), 0
	ld (0x2784:16), 0
	calr BmDrEdit_LoadAlternatePosition
	calr BmDrEdit_BuildVoiceList
	calr BmDrEdit_SyncSeekCheck
	calr BmDrEdit_SetupAndWalkToNote
	calr NoteEditSy_SendCompoundWidgetUpdate
	calr NoteEdit_UpdateScrollAndDisplay
	call NoteEditSy_SendWidgetCmd0
	jrl NoteEdit_SendScrollCmds

EditChannel_LoadVoiceParams:
	ld c, (BMDREDIT_CHANNEL:16)
	inc 1, c
	extz bc
	ld wa, 0:i3
	call Part_ReadWord_Indexed
	ld (SEQ_DATA_BLOCK:16), hl
	ld c, (BMDREDIT_CHANNEL:16)
	inc 1, c
	extz bc
	ld wa, 0:i3
	call Part_ReadByte_Indexed
	ld (SEQ_DATA_OFFSET:16), hl
	ret

BmDrEdit_DelayAction_SetupAndWalk:
	dec 4, xsp
	bit 0, (0x295f:16)
	jr z, BmDrEdit_DelayAction_UpdateDisplay
	calr ReadSeqData_StoreParams
	calr BmDrEdit_SetupAndWalkToNote
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	sub wa, (xsp)
	ld (0x279a:16), wa

BmDrEdit_DelayAction_UpdateDisplay:
	calr NoteEdit_UpdateScrollAndDisplay
	inc 4, xsp
	ret

BmDrEdit_DelayAction_WalkAndUpdate:
	calr BmDrEdit_SetupAndWalkToNote
	jrl NoteEdit_UpdateScrollAndDisplay

BmDrEdit_DelayAction_PlayClick:
	jrl Metronome_PlayClick

BmDrEdit_DelayAction_CheckCountError:
	bit 0, (0x295f:16)
	jr z, BmDrEdit_DelayAction_UpdateScroll
	calr BmDrEdit_CountMeasuresInit
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_DelayAction_UpdateScroll
	ldw wa, 0xcc
	call SeqData_SetErrorCode
	jrl BmDrEdit_RefreshDisplayState

BmDrEdit_DelayAction_UpdateScroll:
	jrl NoteEdit_UpdateScrollAndDisplay

BmDrEdit_DelayAction_UpdateScrollAlt:
	jrl NoteEdit_UpdateScrollAndDisplay

BmDrEdit_ReadNoteDataFields:
	pushw_erp 0xfa
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_ReadNoteData_Advance
	ldw wa, 0xb9
	call SeqData_SetErrorCode

BmDrEdit_ReadNoteData_Advance:
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	call SeqData_AdvancePosition
	call SeqData_ReadNextByte
	ldfr_berp L, 0xfb
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_ReadNoteData_StoreDuration
	ldw wa, 0xba
	call SeqData_SetErrorCode

BmDrEdit_ReadNoteData_StoreDuration:
	ldto_berp L, 0xfb
	popw_erp 0xfa
	ret

BmDrEdit_PitchScrollOverflow:
	ld c, (0x2774:16)
	ld a, c
	extz wa
	mul wa, 0x60
	dec 1, wa
	cp (0x279a:16), wa
	jr c, BmDrEdit_PitchOverflow_CheckNextPage
	mul c, 0x60
	ld (0x279a:16), bc
	bit 0, (0x295f:16)
	jrl z, BmDrEdit_NavigateAndLoadPosition
	calr BmDrEdit_CalcTickPosition
	ld (0x295c:16), 0
	calr ReadSeqData_StoreParams
	jrl BmDrEdit_ReloadChannelAndDisplay

BmDrEdit_PitchOverflow_CheckNextPage:
	calr BmDrEdit_FindNextPageEntry
	cp l, 0xff
	jr z, BmDrEdit_PitchOverflow_IncrementBeat
	extz hl
	ld wa, (0x2782:16)
	cp wa, hl
	jr nc, BmDrEdit_PitchOverflow_NextPage

BmDrEdit_PitchOverflow_IncrementBeat:
	ld (0x2784:16), 0
	incw 1, (0x2782:16)
	jr BmDrEdit_PitchOverflow_UpdateDisplay

BmDrEdit_PitchOverflow_NextPage:
	ldw (0x2782:16), 0
	incw 1, (0x2744:16)
	ld (0x2784:16), 0
	call NoteEditSy_SendScrollCmd0

BmDrEdit_PitchOverflow_UpdateDisplay:
	call NoteEditSy_SendScrollCmd2
	call NoteEditSy_SendScrollCmd1
	calr NoteEditSy_CallFarRoutine
	calr BmDrEdit_SaveEditState
	calr BmDrEdit_SeekForwardToEvent
	calr BmDrEdit_RestoreEditState
	cp (SEQ_ERROR_CODE:16), 0
	jrl nz, BmDrEdit_RefreshDisplayState
	jrl BmDrEdit_SetFeedbackTimer

; Alias entry: jumps to BmDrEdit_BuildVoiceList.
NoteEditSy_CallFarRoutine:
	jrl BmDrEdit_BuildVoiceList

BmDrEdit_AdjustViewAndInsert:	.include "includes/generated/cc900/BmDrEdit_AdjustViewAndInsert.s"	; C: cc900/bmdredit_routines_m232_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_WalkTrackLoop, BmDrEdit_AdjustViewAndInsert + 101
	.set	BmDrEdit_AdjustView_RefreshDisplay, BmDrEdit_AdjustViewAndInsert + 127
	.set	BmDrEdit_AdjustView_CheckCoords, BmDrEdit_AdjustViewAndInsert + 132
	.set	BmDrEdit_AdjustViewPath, BmDrEdit_AdjustViewAndInsert + 153
	.set	BmDrEdit_AdjustView_InitAndNavigate, BmDrEdit_AdjustViewAndInsert + 158
	.set	BmDrEdit_AdjustViewReturn, BmDrEdit_AdjustViewAndInsert + 161

; From the restored cursor (BmDrEdit_LoadAlternateState, BmDrEdit_CheckNoteAtPosition), walks the
; track forward (BmDrEdit_WalkTrackForward) until its end flag (bit 1 of 0x295f) or until the
; tick distance between the two positions in its 4-byte stack frame (BmDrEdit_SetupCoordinates)
; passes (0x279c).
BmDrEdit_LoadAndCheckNote:
	dec 4, xsp
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_CheckNoteAtPosition
	call SeqData_ReadNextByte
	and l, 0xf0
	cp l, 0x90
	jr nz, BmDrEdit_LoadNote_WalkTrack
	calr BmDrEdit_CompareVelocity
	cp l, 0:i3
	jr z, BmDrEdit_AdvanceToVisibleNote
	calr BmDrEdit_WalkTrackForward
	bit 1, (0x295f:16)
	jr z, BmDrEdit_AdvanceToVisibleNote
	jr BmDrEdit_WalkReturn

BmDrEdit_LoadNote_WalkTrack:
	calr BmDrEdit_WalkTrackForward
	bit 1, (0x295f:16)
	jr nz, BmDrEdit_WalkReturn

BmDrEdit_AdvanceToVisibleNote:
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	sub wa, (xsp)
	cp wa, (0x279c:16)
	jr ugt, BmDrEdit_WalkReturn
	calr BmDrEdit_WalkTrackForward
	bit 1, (0x295f:16)
	jr z, BmDrEdit_AdvanceToVisibleNote

BmDrEdit_WalkReturn:
	inc 4, xsp
	ret

; Sets the cursor tick 0x279a from the two editor positions (BmDrEdit_SetupCoordinates, their
; difference); past the visible range ((0x2774) * 96) it reloads the page
; (BmDrEdit_NavigateAndLoadPosition), otherwise it walks to the note there and refreshes the
; widgets, playing the note.
BmDrEdit_InitViewAndNavigate:
	dec 4, xsp
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	sub wa, (xsp)
	ld (0x279a:16), wa
	ld a, (0x2774:16)
	mul a, 0x60
	cp (0x279a:16), wa
	jr c, BmDrEdit_InitView_CalcAndWalk
	calr BmDrEdit_NavigateAndLoadPosition
	jr BmDrEdit_InitView_Return

BmDrEdit_InitView_CalcAndWalk:
	calr BmDrEdit_CalcBeatMeasure
	calr BmDrEdit_SetupAndWalkToNote
	call NoteEditSy_SendWidgetCmd0
	calr NoteEdit_SendScrollCmds
	calr NoteEdit_UpdateScrollAndDisplay
	calr BmDrEdit_SendMetronomeNoteOn

BmDrEdit_InitView_Return:
	inc 4, xsp
	ret

; When the cursor tick 0x279a is past the visible range ((0x2774) * 96) reloads the page
; (BmDrEdit_NavigateAndLoadPosition); otherwise clears bit 0 of 0x295f, restores the cursor,
; recomputes beat / measure and refreshes the widgets.
BmDrEdit_AdjustViewToPosition:
	ld a, (0x2774:16)
	mul a, 0x60
	cp (0x279a:16), wa
	jrl nc, BmDrEdit_NavigateAndLoadPosition
	res 0, (0x295f:16)
	calr BmDrEdit_RestoreEditState
	calr BmDrEdit_CalcBeatMeasure
	call NoteEditSy_SendWidgetCmd0
	calr NoteEdit_SendScrollCmds
	jrl NoteEdit_UpdateScrollAndDisplay

; Plays the note under the editor cursor: Metronome_PlayClick, BmDrEdit_BuildNoteOnEvent, and
; 0x295e = 134.
BmDrEdit_SendMetronomeNoteOn:
	calr Metronome_PlayClick
	calr BmDrEdit_BuildNoteOnEvent
	ld (0x295e:16), 134
	ret

; Plays the note under the editor cursor with its velocity: Metronome_PlayClick,
; BmDrEdit_BuildNoteOnEvent_WithVelocity, and 0x295e = 134.
BmDrEdit_SendMetronomeNoteOn_Alt:
	calr Metronome_PlayClick
	calr BmDrEdit_BuildNoteOnEvent_WithVelocity
	ld (0x295e:16), 134
	ret

; Alias entry: jumps to BmDrEdit_WriteNoteOffEntry.
Metronome_PlayClick:
	jr BmDrEdit_WriteNoteOffEntry

; Sends the 5-byte sequencer event 0x90 0x7e (0x2786) (0x2788) (BMDREDIT_CHANNEL) from a stack buffer
; (SeqBuf_WriteMidiEvent, BC = 5), then SeqBuf_FlushAndReinit_NoteEvents.
BmDrEdit_BuildNoteOnEvent:
	dec 8, xsp
	lda xwa, (xsp)
	ld (xwa), 0x90
	ld (xwa + 1), 0x7e
	ldmi16 (xwa + 2), 0x2786
	ldmi16 (xwa + 3), 0x2788
	ldmi16 (xwa + 4), 0x2965
	ld (xwa + 5), 0x0
	ld bc, 5:i3
	call SeqBuf_WriteMidiEvent
	call SeqBuf_FlushAndReinit_NoteEvents
	inc 8, xsp
	ret

; BmDrEdit_BuildNoteOnEvent with the fixed byte 0x50 in place of (0x2788).
BmDrEdit_BuildNoteOnEvent_WithVelocity:
	dec 8, xsp
	lda xwa, (xsp)
	ld (xwa), 0x90
	ld (xwa + 1), 0x7e
	ldmi16 (xwa + 2), 0x2786
	ld (xwa + 3), 0x50
	ldmi16 (xwa + 4), 0x2965
	ld (xwa + 5), 0x0
	ld bc, 5:i3
	call SeqBuf_WriteMidiEvent
	call SeqBuf_FlushAndReinit_NoteEvents
	inc 8, xsp
	ret

BmDrEdit_WriteNoteOffEntry:
	ld a, (BMDREDIT_CHANNEL:16)
	inc 1, a
	extz wa
	jp SeqBuf_WriteNoteOffEntry

; Pads the edited part with empty bars up to the cursor: with the cursor bar (0x279a / 96) + 1
; at or past the bar count 0x2772, inserts (difference + 1) bar markers (BmDrEdit_InsertStepEntry,
; after EditChannel_LoadVoiceParams); an error sets bit 2 of 0x295f.  The playback position is
; restored afterwards.  Preserves XIZ.
BmDrEdit_InsertNoteSequence:
	push xiz
	ld wa, (SEQ_DATA_BLOCK:16)
	ldfr_werp WA, 0xfa
	ld iz, (SEQ_DATA_OFFSET:16)
	res 2, (0x295f:16)
	calr BmDrEdit_LoadAlternateAndValidate
	ld bc, (0x279a:16)
	extz xbc
	div bc, 0x60
	inc 1, bc
	ld wa, (0x2772:16)
	cp bc, wa
	jr c, BmDrEdit_InsertSeq_PopIzRet
	inc 1, bc
	sub bc, wa
	ld (0x2772:16), bc
	calr EditChannel_LoadVoiceParams
	cpw (0x2772:16), 0
	jr z, BmDrEdit_SavePositionAndReturn

BmDrEdit_InsertSeq_StepLoop:
	calr BmDrEdit_InsertStepEntry
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_InsertSeq_DecrementCount
	set 2, (0x295f:16)
	jr BmDrEdit_SavePositionAndReturn

BmDrEdit_InsertSeq_DecrementCount:
	ld wa, (0x2772:16)
	dec 1, wa
	ld (0x2772:16), wa
	cp wa, 0:i3
	jr nz, BmDrEdit_InsertSeq_StepLoop

BmDrEdit_SavePositionAndReturn:
	ldto_werp WA, 0xfa
	ld (SEQ_DATA_BLOCK:16), wa
	ld (SEQ_DATA_OFFSET:16), iz

BmDrEdit_InsertSeq_PopIzRet:
	pop xiz
	ret

; Clears bit 3 of 0x295f.  With 0x279c = 0: a beat marker 0x81 at the position, a 0x9n note that
; BmDrEdit_CompareVelocity rejects, or tick 0x2760 non-zero sets bit 3 of 0x295f; another event
; goes to BmDrEdit_WalkAndScanAfterEdit.  Otherwise walks forward from the restored cursor
; (BmDrEdit_WalkTrackForward) while the tick distance stays below (0x279c), then restores the
; cursor.
BmDrEdit_ScanAfterModify:
	dec 4, xsp
	res 3, (0x295f:16)
	cpw (0x279c:16), 0
	jr nz, BmDrEdit_ScanAfterModify_LoadAndWalk
	call SeqData_ReadNextByte
	cp l, 0x81
	jr z, BmDrEdit_SetFlagReturn
	and l, 0xf0
	cp l, 0x90
	jr z, BmDrEdit_ScanAfterModify_CheckVelocity
	calr BmDrEdit_WalkAndScanAfterEdit
	jr BmDrEdit_ScanAfterModify_Return

BmDrEdit_ScanAfterModify_CheckVelocity:
	calr BmDrEdit_CompareVelocity
	cp l, 0:i3
	jr nz, BmDrEdit_SetFlagReturn
	cp (0x2760:16), 0
	jr nz, BmDrEdit_SetFlagReturn

BmDrEdit_ScanAfterModify_LoadAndWalk:
	calr BmDrEdit_LoadAlternateState
	calr BmDrEdit_CheckNoteAtPosition

BmDrEdit_ScanAfterModify_WalkLoop:
	calr BmDrEdit_SaveEditState
	calr BmDrEdit_WalkTrackForward
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	sub wa, (xsp)
	cp wa, (0x279c:16)
	jr c, BmDrEdit_ScanAfterModify_WalkLoop
	calr BmDrEdit_RestoreEditState
	jr BmDrEdit_ScanAfterModify_Return

BmDrEdit_SetFlagReturn:
	set 3, (0x295f:16)

BmDrEdit_ScanAfterModify_Return:
	inc 4, xsp
	ret

; Moves the cursor tick 0x279a back to the previous multiple of the grid step 0x2792 (strictly
; below it); nothing at 0.
BmDrEdit_AlignGridBackward:
	ld wa, (0x279a:16)
	cp wa, 0:i3
	ret z
	ld de, 0:i3
	cp wa, 0:i3
	jr ule, BmDrEdit_AlignGridBackward_Store
	ld bc, (0x2792:16)

BmDrEdit_AlignGridBackward_AccumLoop:
	add de, bc
	cp de, wa
	jr c, BmDrEdit_AlignGridBackward_AccumLoop

BmDrEdit_AlignGridBackward_Store:
	sub de, (0x2792:16)
	ld (0x279a:16), de
	ret

; Restores the saved cursor (BmDrEdit_LoadAlternateState; a pending error records 0xb8), then goes
; on to BmDrEdit_CountMeasuresAndValidate.
BmDrEdit_LoadAlternateAndValidate:
	calr BmDrEdit_LoadAlternateState
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_LoadAlternateAndValidate_Done
	ldw wa, 0xb8
	call SeqData_SetErrorCode

BmDrEdit_LoadAlternateAndValidate_Done:
	jr BmDrEdit_CountMeasuresAndValidate

; Counts the bar markers (0x81) from the playback position to the next end (0x82) or bar-start
; (0x84) marker into 0x2772.  A pending error records 0xd1 before and 0xce after the scan.
BmDrEdit_CountMeasuresAndValidate:	.include "includes/generated/cc900/BmDrEdit_CountMeasuresAndValidate.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_CountMeasures_Init, BmDrEdit_CountMeasuresAndValidate + 14
	.set	BmDrEdit_CountMeasures_Loop, BmDrEdit_CountMeasuresAndValidate + 20
	.set	BmDrEdit_CountMeasures_SkipEvent, BmDrEdit_CountMeasuresAndValidate + 43
	.set	BmDrEdit_CheckAndReportScanError, BmDrEdit_CountMeasuresAndValidate + 49

BmDrEdit_NavigateBackwardWithEdit:
	dec 4, xsp
	bit 7, (0x295c:16)
	jrl nz, BmDrEdit_NavigateReturn
	calr BmDrEdit_SaveEditState
	ldmm16 0x279c, 0x279a
	calr BmDrEdit_AlignGridBackward
	calr BmDrEdit_CalcBeatMeasure
	bit 0, (0x295f:16)
	jr nz, BmDrEdit_NavigateAfterEdit
	calr BmDrEdit_ScanAfterModify
	bit 3, (0x295f:16)
	jr z, BmDrEdit_NavEdit_CheckPosition
	cpw (0x2744:16), 1
	jr z, BmDrEdit_ResetToFirstEvent
	cpw (0x279c:16), 0
	jr z, BmDrEdit_GoToPrevPage

BmDrEdit_ResetToFirstEvent:
	calr BmDrEdit_AdjustViewToPosition
	jrl BmDrEdit_NavigateReturn

BmDrEdit_GoToPrevPage:
	calr BmDrEdit_NavigatePrevPage
	jrl BmDrEdit_NavigateReturn

BmDrEdit_NavEdit_CheckPosition:
	ld wa, (0x276e:16)
	cp wa, (SEQ_DATA_BLOCK:16)
	jr nz, BmDrEdit_CheckCurrentNoteMatch
	ld a, (0x2770:16)
	extz wa
	cp wa, (SEQ_DATA_OFFSET:16)
	jr nz, BmDrEdit_CheckCurrentNoteMatch
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	sub wa, (xsp)
	cp (0x279c:16), wa
	jr ule, BmDrEdit_ResetToFirstEvent

BmDrEdit_CheckCurrentNoteMatch:
	call SeqData_ReadNextByte
	and l, 0xf0
	cp l, 0x90
	jr nz, BmDrEdit_NavigateAfterEdit
	calr BmDrEdit_CompareVelocity
	cp l, 0:i3
	jr nz, BmDrEdit_NavigateAfterEdit
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	sub wa, (xsp)
	cp wa, (0x279a:16)
	jr nc, BmDrEdit_NavEdit_InitView

BmDrEdit_NavigateAfterEdit:
	calr BmDrEdit_WalkAndScanAfterEdit
	bit 3, (0x295f:16)
	jr z, BmDrEdit_NavEdit_CalcCoords
	cpw (0x2744:16), 1
	jr z, BmDrEdit_ResetToFirstEvent
	cpw (0x279c:16), 0
	jr z, BmDrEdit_GoToPrevPage
	jr BmDrEdit_ResetToFirstEvent

BmDrEdit_NavEdit_CalcCoords:
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	cp wa, (xsp)
	jrl c, BmDrEdit_ResetToFirstEvent
	ld wa, (0x279a:16)
	add (xsp), wa
	ld wa, (xsp + 2)
	cp wa, (xsp)
	jrl c, BmDrEdit_ResetToFirstEvent

BmDrEdit_NavEdit_InitView:
	calr BmDrEdit_InitViewAndNavigate

BmDrEdit_NavigateReturn:
	inc 4, xsp
	ret

BmDrEdit_WalkAndScanAfterEdit:
	dec 4, xsp
	res 3, (0x295f:16)
	call SeqData_ReadNextByte
	cp l, 0x81
	jr nz, BmDrEdit_ScanSequenceEnd
	ld wa, (0x275e:16)
	cp wa, 0:i3
	jr z, BmDrEdit_CheckVelocityMatch
	dec 1, wa
	ld (0x275e:16), wa
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	cp wa, (xsp)
	jr c, BmDrEdit_CheckVelocityMatch

BmDrEdit_ScanSequenceEnd:
	calr BmDrEdit_ClearAndScanToEnd
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_WalkScan_ReadNext
	set 3, (0x295f:16)
	ld (SEQ_ERROR_CODE:16), 0
	jr BmDrEdit_WalkScan_Return

BmDrEdit_WalkScan_ReadNext:
	call SeqData_ReadNextByte
	cp l, 0x81
	jr nz, BmDrEdit_WalkScan_CheckNoteOn
	ld wa, (0x275e:16)
	cp wa, 0:i3
	jr z, BmDrEdit_CheckVelocityMatch
	dec 1, wa
	ld (0x275e:16), wa
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	cp wa, (xsp)
	jr nc, BmDrEdit_ScanSequenceEnd
	jr BmDrEdit_CheckVelocityMatch

BmDrEdit_WalkScan_CheckNoteOn:
	and l, 0xf0
	cp l, 0x90
	jr nz, BmDrEdit_ScanSequenceEnd
	calr BmDrEdit_CompareVelocity
	cp l, 0:i3
	jr nz, BmDrEdit_ScanSequenceEnd
	calr BmDrEdit_ReadEventAtPosition
	lda xwa, (xsp + 2)
	lda xbc, (xsp)
	calr BmDrEdit_SetupCoordinates
	ld wa, (xsp + 2)
	cp wa, (xsp)
	jr nc, BmDrEdit_WalkScan_Return

BmDrEdit_CheckVelocityMatch:
	set 3, (0x295f:16)

BmDrEdit_WalkScan_Return:
	inc 4, xsp
	ret

; Unless slot 0 at 0x2746 is in use or the timer runs: UI_ChangeTitleByIndex with WA = 0x96
; (tail jump).
BmDrEdit_PostModeChange96:
	bit 7, (0x2746:16)
	ret nz
	bit 7, (0x295c:16)
	ret nz
	ldw wa, TT_SQNOTECYCP
	jp UI_ChangeTitleByIndex

; Unless the timer runs with an action other than 5: clears bit 0 of 0x295f and goes on to
; BmDrEdit_DrumVoiceUp.
BmDrEdit_DrumVoiceUp_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_DrumVoiceUp_ClearFlag
	cp (0x295d:16), 5
	ret nz

BmDrEdit_DrumVoiceUp_ClearFlag:
	res 0, (0x295f:16)
	jr BmDrEdit_DrumVoiceUp

; Unless slot 0 at 0x2746 is in use: steps the cursor row 0x27a0 up, to at most 11, or once it is
; 11 the top row 0x279e (at most 0x74); then redraws, plays the note
; (BmDrEdit_SendMetronomeNoteOn_Alt), sets the timer 0x295c = 131, 0x295d = 5 and tail-jumps to
; Audio_CheckSubsystemReady.
BmDrEdit_DrumVoiceUp:
	bit 7, (0x2746:16)
	ret nz
	ld wa, (0x27a0:16)
	cp wa, 0xb
	jr c, BmDrEdit_DrumVoiceUp_IncrementOctave
	ld wa, (0x279e:16)
	cp wa, 0x74
	ret nc
	inc 1, wa
	ld (0x279e:16), wa
	jr BmDrEdit_DrumVoiceUp_UpdateDisplay

BmDrEdit_DrumVoiceUp_IncrementOctave:
	inc 1, wa
	ld (0x27a0:16), wa

BmDrEdit_DrumVoiceUp_UpdateDisplay:
	call NoteEditSy_SendWidgetCmd0
	calr NoteEdit_SendScrollCmds
	call NoteEditSy_UpdateChordDisplay
	calr BmDrEdit_SendMetronomeNoteOn_Alt
	ld (0x295c:16), 131
	ld (0x295d:16), 5
	jp Audio_CheckSubsystemReady

; Unless the timer runs with an action other than 5: clears bit 0 of 0x295f and goes on to
; BmDrEdit_DrumVoiceDown.
BmDrEdit_DrumVoiceDown_Check:
	bit 7, (0x295c:16)
	jr z, BmDrEdit_DrumVoiceDown_ClearFlag
	cp (0x295d:16), 5
	ret nz

BmDrEdit_DrumVoiceDown_ClearFlag:
	res 0, (0x295f:16)
	jr BmDrEdit_DrumVoiceDown

; Unless slot 0 at 0x2746 is in use: steps the cursor row 0x27a0 down, to at least 0, or once it
; is 0 the top row 0x279e (at least 1); then redraws, plays the note, sets the timer 0x295c = 131,
; 0x295d = 5 and tail-jumps to Audio_CheckSubsystemReady.
BmDrEdit_DrumVoiceDown:
	bit 7, (0x2746:16)
	ret nz
	ld wa, (0x27a0:16)
	cp wa, 0:i3
	jr nz, BmDrEdit_DrumVoiceDown_DecrementOctave
	ld wa, (0x279e:16)
	cp wa, 1:i3
	ret z
	dec 1, wa
	ld (0x279e:16), wa
	jr BmDrEdit_DrumVoiceDown_UpdateDisplay

BmDrEdit_DrumVoiceDown_DecrementOctave:
	dec 1, wa
	ld (0x27a0:16), wa

BmDrEdit_DrumVoiceDown_UpdateDisplay:
	call NoteEditSy_SendWidgetCmd0
	calr NoteEdit_SendScrollCmds
	call NoteEditSy_UpdateChordDisplay
	calr BmDrEdit_SendMetronomeNoteOn_Alt
	ld (0x295c:16), 131
	ld (0x295d:16), 5
	jp Audio_CheckSubsystemReady

; In drum mode (bit 0 of 0x2742) sets the editor note 0x2786 to the visible top row (0x279e)
; plus the cursor row (0x27a0); does nothing in melodic mode.
BmDrEdit_CalcTrackPosition:
	bit 0, (0x2742:16)
	ret z
	ld wa, (0x279e:16)
	add wa, (0x27a0:16)
	ld (0x2786:16), a
	ret

; Unless slot 0 at 0x2746 is in use or the timer runs: UI_ChangeTitleByIndex with WA = 0x99
; (tail jump).
BmDrEdit_PostModeChange99:
	bit 7, (0x2746:16)
	ret nz
	bit 7, (0x295c:16)
	ret nz
	ldw wa, TT_SQDRMCYCP
	jp UI_ChangeTitleByIndex

BmDrEdit_DelayAction_WalkAndUpdateAlt:
	calr BmDrEdit_SetupAndWalkToNote
	jrl NoteEdit_UpdateScrollAndDisplay

; Plays the note under the cursor (BmDrEdit_SendMetronomeNoteOn) and starts the timer 0x295e =
; 134.
BmDrEdit_PlayNoteAndSetDelay:
	calr BmDrEdit_SendMetronomeNoteOn
	ld (0x295e:16), 134
	ret

BmDrEdit_ApplyVelocityChange:
	lda xsp, (xsp - 20)
	pushw iz
	ld (xsp + 14), de
	ld (xsp + 16), xbc
	ld (xsp + 20), a
	cpw (xsp + 14), 0x0
	jrl z, BmDrEdit_VelChange_ReturnZero
	cpw (xsp + 14), 0xff
	jr ugt, BmDrEdit_VelChange_Error
	ldmw2 (xsp + 2), 0x28af
	ldmw2 (xsp + 4), 0x2666
	ld c, (xsp + 20)
	extz bc
	ld wa, 0:i3
	call Part_ReadWord_Indexed
	ld (xsp + 12), hl
	ld c, (xsp + 20)
	extz bc
	ld wa, 0:i3
	call Part_ReadByte_Indexed
	ld (xsp + 10), hl
	ld wa, (xsp + 12)
	ld (xsp + 8), wa
	ld wa, (xsp + 10)
	add wa, (xsp + 14)
	ld (xsp + 6), wa
	cpw (xsp + 6), 0xff
	jr ule, BmDrEdit_VelChange_WriteParams
	ld wa, (xsp + 12)
	call PartCtrl_ReadWord
	ld (xsp + 8), hl
	cpw (xsp + 8), 0xffff
	jr nz, BmDrEdit_VelChange_LinkVoice
	ld wa, (xsp + 12)
	call Part_LinkVoiceToChain
	ld (xsp + 8), hl
	cp hl, 0:i3
	jr ge, BmDrEdit_VelChange_LinkVoice
	ldw wa, 0xbb
	call SeqData_SetErrorCode

BmDrEdit_VelChange_Error:
	ldw hl, 0xffff
	jrl BmDrEdit_VelChange_Epilog

BmDrEdit_VelChange_LinkVoice:
	submi16 (xsp + 6), 0xff
	incw 4, (xsp + 6)

BmDrEdit_VelChange_WriteParams:
	ld c, (xsp + 20)
	extz bc
	ld de, (xsp + 8)
	ld wa, 0:i3
	call Part_WriteWord_Indexed
	ld c, (xsp + 20)
	extz bc
	ld wa, (xsp + 6)
	ld e, a
	extz de
	ld wa, 0:i3
	call Part_WriteByte_Indexed

BmDrEdit_VelChange_CopyLoop:
	ld wa, (xsp + 12)
	ld bc, (xsp + 10)
	calr PartCtrl_ReadByteExtended
	extz hl
	ld wa, (xsp + 8)
	ld bc, (xsp + 6)
	ld de, hl
	calr PartCtrl_WriteByte_ZeroExtended
	ld wa, (SEQ_DATA_BLOCK:16)
	cp wa, (xsp + 12)
	jr nz, BmDrEdit_VelChange_DecrementCounters
	ld wa, (SEQ_DATA_OFFSET:16)
	cp wa, (xsp + 10)
	jr z, BmDrEdit_VelChange_WriteEventBytes

BmDrEdit_VelChange_DecrementCounters:
	lda xwa, (xsp + 12)
	lda xbc, (xsp + 10)
	calr BmDrEdit_DecrementAndValidateCounter
	lda xwa, (xsp + 8)
	lda xbc, (xsp + 6)
	calr BmDrEdit_DecrementAndValidateCounter
	jr BmDrEdit_VelChange_CopyLoop

BmDrEdit_VelChange_WriteEventBytes:
	ld iz, 0:i3
	cpw (xsp + 14), 0x0
	jr ule, BmDrEdit_VelChange_Finalize

BmDrEdit_VelChange_WriteByteLoop:
	ld wa, iz
	extz xwa
	add xwa, (xsp + 16)
	ld a, (xwa)
	extz wa
	call PartCtrl_WriteByte_Indexed
	call SeqData_AdvancePosition
	inc 1, iz
	cp iz, (xsp + 14)
	jr c, BmDrEdit_VelChange_WriteByteLoop

BmDrEdit_VelChange_Finalize:
	mrdw5 0x9f, 0x02, 0x19, 0xaf, 0x28
	mrdw5 0x9f, 0x04, 0x19, 0x66, 0x26

BmDrEdit_VelChange_ReturnZero:
	ld hl, 0:i3

BmDrEdit_VelChange_Epilog:
	popw iz
	lda xsp, (xsp + 20)
	ret

; Steps a (block, offset) cursor one byte backward through the song-data block chain.
;   In:  XWA -> block word, XBC -> offset word.  Below offset 5 the block becomes its backward
;   link (PartCtrl_ReadWord_Off1) and the offset 0xff.
;   Out: HL = 0, or 0xffff with error 0xa0 (SeqData_SetErrorCode) when that block number is above
;   0x4d8.  Counterpart of PartCtrl_ReadWordWithBoundsCheck.
BmDrEdit_DecrementAndValidateCounter:	.include "includes/generated/cc900/BmDrEdit_DecrementAndValidateCounter.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_DecrValidate_LinkNext, BmDrEdit_DecrementAndValidateCounter + 45
	.set	BmDrEdit_DecrValidate_ReturnZero, BmDrEdit_DecrementAndValidateCounter + 52
	.set	BmDrEdit_DecrValidate_Epilog, BmDrEdit_DecrementAndValidateCounter + 54

; Steps a (block, offset) cursor one byte forward through the song-data block chain.
;   In:  XWA -> block word, XBC -> offset word.  Past offset 0xff the block becomes its forward
;   link (PartCtrl_ReadWord) and the offset 5.
;   Out: HL = 0, or 0xffff with error 0xa1 (SeqData_SetErrorCode) when the next block number is
;   above 0x4d8.
PartCtrl_ReadWordWithBoundsCheck:	.include "includes/generated/cc900/PartCtrl_ReadWordWithBoundsCheck.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_BoundsCheck_ResetCounter, PartCtrl_ReadWordWithBoundsCheck + 45
	.set	BmDrEdit_BoundsCheck_ReturnZero, PartCtrl_ReadWordWithBoundsCheck + 52
	.set	BmDrEdit_BoundsCheck_Epilog, PartCtrl_ReadWordWithBoundsCheck + 54

; Zero-extends BC and jumps to PartCtrl_ReadByte.
PartCtrl_ReadByteExtended:
	extz bc
	jp PartCtrl_ReadByte

; Zero-extends BC and DE and jumps to PartCtrl_WriteByteToBuf.
PartCtrl_WriteByte_ZeroExtended:
	extz bc
	extz de
	jp PartCtrl_WriteByteToBuf

; Inserts one bar marker (0x81) at the editor position of part (BMDREDIT_CHANNEL) + 1:
; BmDrEdit_SaveSongPosition, then BmDrEdit_ApplyVelocityChange with a one-byte event.
; SEQ_ERROR_CODE is cleared first.
BmDrEdit_InsertStepEntry:
	dec 2, xsp
	calr BmDrEdit_SaveSongPosition
	ld (SEQ_ERROR_CODE:16), 0
	ld (xsp), 0x81
	ld a, (BMDREDIT_CHANNEL:16)
	inc 1, a
	extz wa
	lda xbc, (xsp)
	ld de, 1:i3
	calr BmDrEdit_ApplyVelocityChange
	inc 2, xsp
	ret

; Builds a 6-byte note-on at 0x2967 for the cursor position and inserts it into part (BMDREDIT_CHANNEL) + 1
; (BmDrEdit_ApplyVelocityChange): 0x90, cursor tick mod 96, the bytes 0x2960 / 0x2961, and the
; length 0x278e as (mod 96, / 96).  BmDrEdit_WalkToGridPosition positions first.
BmDrEdit_PrepareAndInsertNote:	.include "includes/generated/cc900/BmDrEdit_PrepareAndInsertNote.s"	; C: cc900/bmdredit_routines_m232.c

BmDrEdit_ValidateAndProcessVoice:
	dec 8, xsp
	push xiz
	ld (xsp + 6), xde
	ld (xsp + 10), a
	ld (SEQ_ERROR_CODE:16), 0
	ld (0x288d:16), c
	call SeqVoice_SetDefaultParams
	ld a, (xsp + 10)
	extz wa
	call Part_ValidateVoiceChannel
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_ValidateVoice_ProcessState
	ld l, 0xff:opc
	jr BmDrEdit_ValidateVoice_Epilog

BmDrEdit_ValidateVoice_ProcessState:
	ld iz, (SEQ_DATA_BLOCK:16)
	ld wa, (SEQ_DATA_OFFSET:16)
	ldfr_werp WA, 0xfa
	call SeqVoice_ValidateAndProcessState
	ld (SEQ_DATA_BLOCK:16), iz
	ldto_werp WA, 0xfa
	ld (SEQ_DATA_OFFSET:16), wa
	ldw (xsp + 4), 0x1
	ld xwa, (xsp + 6)
	ldw (xwa), 0x0
	cpw (0x287f:16), 1
	jr z, BmDrEdit_TrackValidateRet

BmDrEdit_ValidateVoice_SkipSections:
	ld a, (0x288e:16)
	extz wa
	ld xbc, (xsp + 6)
	ld bc, (xbc)
	call SeqData_SkipSections
	ld xwa, (xsp + 6)
	ld (xwa), hl
	cp (SEQ_ERROR_CODE:16), 0
	jr nz, BmDrEdit_TrackValidateRet
	incw 1, (xsp + 4)
	call SeqTrack_ProcessControlBytes
	cp (SEQ_ERROR_CODE:16), 0
	jr nz, BmDrEdit_TrackValidateRet
	ld wa, (xsp + 4)
	cp wa, (0x287f:16)
	jr nz, BmDrEdit_ValidateVoice_SkipSections

BmDrEdit_TrackValidateRet:
	ld l, (0x288e:16)

BmDrEdit_ValidateVoice_Epilog:
	pop xiz
	inc 8, xsp
	ret

; Copies the editor's target bar (0x2744) to 0x287f, selects the editor channel
; (BmDrEdit_CheckAndSelectChannel) and seeks part (BMDREDIT_CHANNEL) + 1 to it
; (BmDrEdit_ValidateAndProcessVoice).  Out: HL = the word that routine returns through its
; DE pointer.
BmDrEdit_SyncChannelAndGetPos:	.include "includes/generated/cc900/BmDrEdit_SyncChannelAndGetPos.s"	; C: cc900/bmdredit_routines_m232.c

; Synchronises the editor channel (BmDrEdit_SyncChannelAndGetPos) and stores its position as
; the alternate cursor: 0x276a = HL, 0x276c = 0, 0x276e = block (SEQ_DATA_BLOCK), 0x2770 = offset.
; Nothing is stored when SEQ_ERROR_CODE is set.
BmDrEdit_SelectChannelAndLoadPos:	.include "includes/generated/cc900/BmDrEdit_SelectChannelAndLoadPos.s"	; C: cc900/bmdredit_routines_m232.c

; Synchronises the editor channel (BmDrEdit_SyncChannelAndGetPos) and stores the result as the
; editor position: 0x275e = HL, 0x2760 = 0.  Nothing is stored when SEQ_ERROR_CODE is set.
BmDrEdit_LoadAlternatePosition:
	ld (SEQ_ERROR_CODE:16), 0
	calr BmDrEdit_SyncChannelAndGetPos
	cp (SEQ_ERROR_CODE:16), 0
	ret nz
	ld (0x275e:16), hl
	ld (0x2760:16), 0
	ret

BmDrEdit_CopyEventDataBetweenParts:
	lda xsp, (xsp - 10)
	pushw_erp 0xfa
	ld (xsp + 10), a
	calr BmDrEdit_SaveSongPosition
	ld wa, (SEQ_DATA_BLOCK:16)
	ld bc, (SEQ_DATA_OFFSET:16)
	ld (xsp + 8), wa
	ld (xsp + 6), bc
	call SeqData_SkipToNextEvent
	ldmw2 (xsp + 4), 0x28af
	ldmw2 (xsp + 2), 0x2666

BmDrEdit_CopyEventLoop:
	ld wa, (xsp + 4)
	ld bc, (xsp + 2)
	calr PartCtrl_ReadByteExtended
	ldfr_berp L, 0xfb
	ldto_berp E, 0xfb
	extz de
	ld wa, (xsp + 8)
	ld bc, (xsp + 6)
	calr PartCtrl_WriteByte_ZeroExtended
	cp_erpb 0xfb, 0x82
	jr z, BmDrEdit_FinalizePartTransfer
	cp_erpb 0xfb, 0x84
	jr z, BmDrEdit_FinalizePartTransfer
	lda xwa, (xsp + 8)
	lda xbc, (xsp + 6)
	calr PartCtrl_ReadWordWithBoundsCheck
	lda xwa, (xsp + 4)
	lda xbc, (xsp + 2)
	calr PartCtrl_ReadWordWithBoundsCheck
	jr BmDrEdit_CopyEventLoop

BmDrEdit_FinalizePartTransfer:
	ld c, (xsp + 10)
	extz bc
	ld de, (xsp + 8)
	ld wa, 0:i3
	call Part_WriteWord_Indexed
	ld c, (xsp + 10)
	extz bc
	ld wa, (xsp + 6)
	ld e, a
	extz de
	ld wa, 0:i3
	call Part_WriteByte_Indexed
	ld wa, (xsp + 8)
	call PartCtrl_ReadWord
	ld wa, hl
	call Part_StealAndReallocVoices
	ld wa, (xsp + 8)
	ldw bc, 0xffff
	call PartCtrl_WriteWord
	ld hl, 0:i3
	popw_erp 0xfa
	lda xsp, (xsp + 10)
	ret

BmDrEdit_DeleteNoteAtCursor:
	push xiz
	bit 7, (0x295c:16)
	jr nz, BmDrEdit_DeleteNote_PopIzRet
	bit 0, (0x295f:16)
	jr z, BmDrEdit_DeleteNote_PopIzRet
	ld a, (BMDREDIT_CHANNEL:16)
	inc 1, a
	extz wa
	calr BmDrEdit_CopyEventDataBetweenParts
	call SeqData_ReadNextByte
	cp l, 0x82
	jr z, BmDrEdit_DeleteNote_EndOfTrack
	cp l, 0x84
	jr nz, BmDrEdit_DeleteNote_CheckStep

BmDrEdit_DeleteNote_EndOfTrack:
	ld (0x2760:16), 0
	jr NoteEdit_FinalizeAndRefreshDisplay

BmDrEdit_DeleteNote_CheckStep:
	cp l, 0x81
	jr nz, BmDrEdit_DeleteNote_ReadNextEvent
	incw 1, (0x275e:16)
	jr NoteEdit_FinalizeAndRefreshDisplay

BmDrEdit_DeleteNote_ReadNextEvent:
	ld wa, (SEQ_DATA_BLOCK:16)
	ldfr_werp WA, 0xfa
	ld iz, (SEQ_DATA_OFFSET:16)
	call SeqData_AdvancePosition
	call SeqData_ReadNextByte
	ld (0x2760:16), l
	ldto_werp WA, 0xfa
	ld (SEQ_DATA_BLOCK:16), wa
	ld (SEQ_DATA_OFFSET:16), iz

NoteEdit_FinalizeAndRefreshDisplay:
	res 0, (0x295f:16)
	call NoteEditSy_SendWidgetCmd0
	calr NoteEdit_SendScrollCmds
	calr NoteEdit_UpdateScrollAndDisplay

BmDrEdit_DeleteNote_PopIzRet:
	pop xiz
	ret

BmDrEdit_ScanChannelEvents:
	dec 4, xsp
	pushw iz
	calr BmDrEdit_SaveEditState
	ld wa, (0x2744:16)
	ld (0x27b2:16), wa
	ldmm16 0x287f, 0x2744
	ld iz, 0:i3
	ldw (xsp + 2), 0x0

BmDrEdit_ScanChannel_SelectLoop:
	calr BmDrEdit_CheckAndSelectChannel
	ld a, (BMDREDIT_CHANNEL:16)
	inc 1, a
	bit 2, (SEQ_EDIT_FLAGS:16)
	jr z, BmDrEdit_ScanChannel_UseChannel
	ld a, l

BmDrEdit_ScanChannel_UseChannel:
	extz wa
	extz hl
	lda xde, (xsp + 4)
	ld bc, hl
	calr BmDrEdit_ValidateAndProcessVoice
	lda xwa, (0x27a4:16)
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_ScanChannel_StoreAndContinue
	ld xbc, xwa
	ld a, (0x27a2:16)
	ldfr_berp A, 0xf0
	extz ix
	ld wa, (xsp + 2)

BmDrEdit_ScanChannel_StoreEntry:
	ld l, (0x288e:16)
	incw 1, (xsp + 2)
	inc 1, a
	ld iy, iz
	extz xiy
	add xiy, xbc
	ld (xiy), a

BmDrEdit_ScanChannel_NextSlot:
	inc 1, iz
	cp iz, ix
	jr nc, BmDrEdit_ScanChannel_RestoreAndReturn
	cp l, 1:i3
	jr z, BmDrEdit_ScanChannel_StoreEntry
	ld de, iz
	extz xde
	add xde, xbc
	ld (xde), 0x0
	dec 1, l
	jr BmDrEdit_ScanChannel_NextSlot

BmDrEdit_ScanChannel_StoreAndContinue:
	incw 1, (xsp + 2)
	ld xbc, xwa
	ld de, iz
	extz xde
	add xde, xwa
	ld wa, (xsp + 2)
	ld (xde), a
	ld e, (0x27a2:16)
	extz de

BmDrEdit_ScanChannel_FillRemaining:
	inc 1, iz
	cp iz, de
	jr c, BmDrEdit_ScanChannel_AdvanceSong

BmDrEdit_ScanChannel_RestoreAndReturn:
	calr BmDrEdit_RestoreEditState
	ld (SEQ_ERROR_CODE:16), 0
	popw iz
	inc 4, xsp
	ret

BmDrEdit_ScanChannel_AdvanceSong:
	cp l, 1:i3
	jr nz, BmDrEdit_ScanChannel_ClearSlot
	incw 1, (0x287f:16)
	jrl BmDrEdit_ScanChannel_SelectLoop

BmDrEdit_ScanChannel_ClearSlot:
	ld wa, iz
	extz xwa
	add xwa, xbc
	ld (xwa), 0x0
	dec 1, l
	jr BmDrEdit_ScanChannel_FillRemaining

; Finds the row of the bar (0x2744) - (0x27b2) + 1 in the list at 0x27a4 and sets the cursor tick
; 0x279a = ((0x2782) + row) * 96 + (0x2784).
BmDrEdit_BuildVoiceList:
	ld bc, (0x2744:16)
	sub bc, (0x27b2:16)
	inc 1, bc
	ld h, c
	ld ix, 0:i3
	ld l, 0x0:opc
	lda xde, (0x27a4:16)
	ld wa, 0:i3
	jr BmDrEdit_BuildVoice_SearchLoop

BmDrEdit_BuildVoice_IncrementAndSearch:
	inc 1, ix
	inc 1, l
	inc 1, wa

BmDrEdit_BuildVoice_SearchLoop:
	ld bc, wa
	extz xbc
	add xbc, xde
	cp (xbc), h
	jr nz, BmDrEdit_BuildVoice_IncrementAndSearch
	ld bc, (0x2782:16)
	add bc, ix
	mul bc, 0x60
	ld a, (0x2784:16)
	extz wa
	add bc, wa
	ld (0x279a:16), bc
	ret

; Empty routine: returns at once.
BmDrEdit_BuildVoice_NullReturn:
	ret

BmDrEdit_FindNextPageEntry:
	ld hl, (0x2744:16)
	sub hl, (0x27b2:16)
	inc 1, l
	ld e, 0x0:opc
	lda xbc, (0x27a4:16)

BmDrEdit_FindNextPage_ScanLoop:
	ld a, e
	extz wa
	extz xwa
	add xwa, xbc
	inc 1, e
	cp (xwa), l
	jr nz, BmDrEdit_FindNextPage_CheckBound
	ld l, 0x0:opc
	ld a, e
	extz wa
	extz xwa
	add xwa, xbc
	cp (xwa), 0x0
	jr z, BmDrEdit_FindNextNonZeroEntry
	ld l, 0x0:opc
	ret

BmDrEdit_FindNextPage_CheckBound:
	cp e, (0x27a2:16)
	jr c, BmDrEdit_FindNextPage_ScanLoop
	ld l, 0xff:opc
	ret

BmDrEdit_FindNextPage_SkipZero:
	inc 1, e
	inc 1, l
	cp e, (0x27a2:16)
	jr c, BmDrEdit_FindNextNonZeroEntry
	ld l, 0xff:opc
	jr BmDrEdit_FindNextPage_Return

BmDrEdit_FindNextNonZeroEntry:
	ld a, e
	extz wa
	extz xwa
	add xwa, xbc
	cp (xwa), 0x0
	jr z, BmDrEdit_FindNextPage_SkipZero

BmDrEdit_FindNextPage_Return:
	ret

; In melodic mode, scrolls the note editor (index 0x2798, 0..9) until the note 0x2962 lies in the
; visible row range (BmDrEdit_SetupScrollRegion), then redraws when the index changed
; (NoteEditSy_UpdateChordDisplay).  Nothing in drum mode.
BmDrEdit_AdjustScrollToView:	.include "includes/generated/cc900/BmDrEdit_AdjustScrollToView.s"	; C: cc900/bmdredit_routines_m232_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_ScrollAdjustLoop, BmDrEdit_AdjustScrollToView + 14
	.set	BmDrEdit_ScrollAdjust_CheckUpper, BmDrEdit_AdjustScrollToView + 49
	.set	BmDrEdit_ScrollAdjust_CompareAndUpdate, BmDrEdit_AdjustScrollToView + 68
	.set	NoteEditSy_ScrollComplete_Return, BmDrEdit_AdjustScrollToView + 82

BmDrEdit_CountMeasuresInit:
	pushw_erp 0xfa
	ld (SEQ_ERROR_CODE:16), 0
	calr BmDrEdit_SaveEditState
	calr BmDrEdit_ReadNoteDataFields
	ldfr_berp L, 0xfb
	inc1b_erp 0xfb
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_CountInit_ValidateAndInsert
	ldw wa, 0xb5
	call SeqData_SetErrorCode

BmDrEdit_CountInit_ValidateAndInsert:
	calr BmDrEdit_CountMeasuresAndValidate
	inc1b_erp 0xfb
	ldto_berp A, 0xfb
	extz wa
	ld bc, (0x2772:16)
	cp wa, bc
	jr c, BmDrEdit_RestoreEditRet
	ldto_berp A, 0xfb
	sub a, c
	inc 1, a
	ldfr_berp A, 0xfb
	extz wa
	ld (0x2772:16), wa
	cp wa, 0:i3
	jr z, BmDrEdit_RestoreEditRet

BmDrEdit_CountInit_InsertLoop:
	calr EditChannel_LoadVoiceParams
	calr BmDrEdit_InsertStepEntry
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_CountInit_DecrementLoop
	ldw wa, 0xcd
	call SeqData_SetErrorCode
	ld (SEQ_ERROR_CODE:16), 255
	jr BmDrEdit_RestoreEditRet

BmDrEdit_CountInit_DecrementLoop:
	ld wa, (0x2772:16)
	dec 1, wa
	ld (0x2772:16), wa
	cp wa, 0:i3
	jr nz, BmDrEdit_CountInit_InsertLoop

BmDrEdit_RestoreEditRet:
	calr BmDrEdit_RestoreEditState
	popw_erp 0xfa
	ret

; When the last entry of the row list at 0x27a4 ((0x27a2) entries) is non-zero, the measure 0x2744
; + 1 and the count 0x2782 = 0; otherwise the count 0x2782 + 1.  Then the tick 0x2784 = low byte of
; (0x279a) - (0x2774) * 96.
BmDrEdit_CheckAndAdvancePage:
	ld a, (0x27a2:16)
	dec 1, a
	extz wa
	lda xbc, (0x27a4:16)
	extz xwa
	add xwa, xbc
	cp (xwa), 0x0
	jr z, BmDrEdit_AdvancePage_IncrementBeat
	incw 1, (0x2744:16)
	ldw (0x2782:16), 0
	jr BmDrEdit_AdvancePage_CalcOffset

BmDrEdit_AdvancePage_IncrementBeat:
	incw 1, (0x2782:16)

BmDrEdit_AdvancePage_CalcOffset:
	ld bc, (0x279a:16)
	ld a, (0x2774:16)
	mul a, 0x60
	sub bc, wa
	ld (0x2784:16), c
	ret

BmDrEdit_ProcessVoiceSection:
	lda xsp, (xsp - 10)
	ld (xsp), xde
	ld (xsp + 4), xbc
	ld (xsp + 8), a
	call SeqVoice_SetDefaultParams
	ld (SEQ_ERROR_CODE:16), 0
	bit 2, (SEQ_EDIT_FLAGS:16)
	jr nz, BmDrEdit_ProcessVoice_WithState
	ld c, (ACC_BEATS_PER_BAR:16)
	extz bc
	ld wa, (3299:16)
	extz xwa
	div xwa, bc
	ld bc, wa
	ld xde, (xsp + 4)
	ld (xde), bc
	ld c, (ACC_BEATS_PER_BAR:16)
	extz bc
	ld wa, (3299:16)
	extz xwa
	div xwa, bc
	ldto_werp BC, 0xe2
	ld xwa, (xsp)
	ld (xwa), bc
	incw 1, (xde)
	ld l, (ACC_BEATS_PER_BAR:16)
	jr BmDrEdit_ProcessVoice_Epilog

BmDrEdit_ProcessVoice_WithState:
	mrdb5 0x8f, 0x08, 0x19, 0x8d, 0x28
	call SeqVoice_ValidateAndProcessState
	ld l, (0x288e:16)
	ld xwa, (xsp)
	ldmw2 (xwa), 0xce3
	ld xwa, (xsp + 4)
	ldw (xwa), 0x1
	jr BmDrEdit_ProcessVoice_CompareAndLoop

BmDrEdit_ProcessVoice_SubtractAndContinue:
	ld xwa, (xsp)
	sub (xwa), bc
	ld xwa, (xsp + 4)
	incw 1, (xwa)
	call SeqTrack_ProcessControlBytes
	ld l, (0x288e:16)

BmDrEdit_ProcessVoice_CompareAndLoop:
	ld c, l
	extz bc
	ld xwa, (xsp)
	cp (xwa), bc
	jr nc, BmDrEdit_ProcessVoice_SubtractAndContinue

BmDrEdit_ProcessVoice_Epilog:
	lda xsp, (xsp + 10)
	ret

; Copies the count 0x2772 to 0xce3 and 0x275e, selects the channel (BmDrEdit_CheckAndSelectChannel)
; and runs BmDrEdit_ProcessVoiceSection on a 4-byte stack frame.  Unless the measure 0x2744 equals
; frame word +2, inserts L (less frame word +0 when that is non-zero) bar markers
; (EditChannel_LoadVoiceParams, BmDrEdit_InsertStepEntry), counting 0x275e up and stopping on an
; error, and copies 0x275e to 0xce3.
BmDrEdit_InsertMultiSongSteps:	.include "includes/generated/cc900/BmDrEdit_InsertMultiSongSteps.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_MultiSong_SelectAndProcess, BmDrEdit_InsertMultiSongSteps + 14
	.set	BmDrEdit_MultiSong_CalcRemaining, BmDrEdit_InsertMultiSongSteps + 48
	.set	BmDrEdit_MultiSong_InsertLoop, BmDrEdit_InsertMultiSongSteps + 54
	.set	BmDrEdit_MultiSong_Return, BmDrEdit_InsertMultiSongSteps + 93

; Sends the note editor's widget updates after a cursor move.  Drum mode (bit 0 of 0x2742)
; and melodic mode each send a shorter set when no note is under the cursor (bit 0 of
; 0x295f clear), then scroll commands 0, 1, 2 and NoteEditSy_SendModeScrollCmd.
NoteEdit_SendScrollCmds:
	bit 0, (0x2742:16)
	jr nz, BmDrEdit_SendScrollCmds_DrumMode
	jr BmDrEdit_SendScrollCmds_MelodicNoteOff

BmDrEdit_SendScrollCmds_MelodicNoteOff:
	bit 0, (0x295f:16)
	jr nz, BmDrEdit_SendScrollCmds_MelodicNoteOn
	call NoteEditSy_SendScrollCmd8
	jr BmDrEdit_SendScrollCmds_CommonMelodicEnd

BmDrEdit_SendScrollCmds_MelodicNoteOn:
	call NoteEditSy_SendScrollCmd3
	call NoteEditSy_SendGateCmd
	call NoteEditSy_SendScrollCmd5

BmDrEdit_SendScrollCmds_CommonMelodicEnd:
	call NoteEditSy_SendScrollCmd0
	call NoteEditSy_SendScrollCmd1
	call NoteEditSy_SendScrollCmd2
	jp NoteEditSy_SendModeScrollCmd

BmDrEdit_SendScrollCmds_DrumMode:
	bit 0, (0x295f:16)
	jr nz, BmDrEdit_SendScrollCmds_DrumNoteOn
	call NoteEditSy_SendVelocityCmd
	jr BmDrEdit_SendScrollCmds_CommonDrumEnd

BmDrEdit_SendScrollCmds_DrumNoteOn:
	call NoteEditSy_SendScrollCmd3
	call NoteEditSy_SendGateCmd

BmDrEdit_SendScrollCmds_CommonDrumEnd:
	call NoteEditSy_SendScrollCmd0
	call NoteEditSy_SendScrollCmd1
	call NoteEditSy_SendScrollCmd2
	jp NoteEditSy_SendModeScrollCmd

; Redraws all note-editor widgets (NoteEditSy_UpdateAllWidgets) unless the cursor tick 0x279a
; is at or past (0x2774) * 96, the end of the visible range.
NoteEdit_UpdateScrollAndDisplay:
	ld a, (0x2774:16)
	mul a, 0x60
	cp (0x279a:16), wa
	ret nc
	jrl NoteEditSy_UpdateAllWidgets
; BmDrEdit_SetRowOffsetFromDelta (was NoteEdit_UpdateScrollAndDisplay_Helper)
; -- A := A - C; in drum mode (bit 0 of RAM 0x2742, set by
; BmDrEdit_InitDrumMode) RAM 0x27CC := 11 - A, otherwise 0x27CC := A, plus 3
; when RAM 0x2798 is 0 (the same rule BmDrEdit_ChordScrollUp applies).
; Called only from BmDrEdit_CompoundWidgetUpdate.
BmDrEdit_SetRowOffsetFromDelta:	.include "includes/generated/cc900/BmDrEdit_SetRowOffsetFromDelta.s"	; C: cc900/bmdredit_routines_m232_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_UpdateDisplay_MelodicOffset, BmDrEdit_SetRowOffsetFromDelta + 17

; -----------------------------------------------------------------------------
; BmDrEdit_CompoundWidgetUpdate (inherited name, formerly
; BmDrEdit_ByteData_CompoundWidgetUpdate: it is code, not data) -- sets up
; coordinates and the scroll region, reads three event bytes through
; SeqData_ReadNextByte / SeqData_AdvancePosition, stores
; (third byte & 0x7F) * 96 + (second byte & 0x7F) in RAM 0x27D0 and clamps
; it in BmDrEdit_ClampScrollPos.
; NO CALLER FOUND: scripts/analysis/sequi_find_refs.py v10 0xF38309 -> none.
; -----------------------------------------------------------------------------
BmDrEdit_CompoundWidgetUpdate:
	dec	8, xsp
	push	qiz
	lda	xwa, (xsp+8)
	lda	xbc, (xsp+6)
	calr	BmDrEdit_SetupCoordinates
	ld	wa, (xsp+6)
	sub	(xsp+8), wa
	ldw (0x27ce), (xsp+8)
	call	SeqData_ReadNextByte
	ldfr_berp	l, 250
	lda	xwa, (xsp+4)
	lda	xbc, (xsp+2)
	calr	BmDrEdit_SetupScrollRegion
	ldto_berp	a, 250
	extz	wa
	ld	c, (xsp+4)
	extz	bc
	calr	BmDrEdit_SetRowOffsetFromDelta
	call	SeqData_AdvancePosition
	call	SeqData_AdvancePosition
	call	SeqData_ReadNextByte
	ldfr_berp	l, 250
	ldto_berp	a, 250
	ldfr_berp	a, 251
	call	SeqData_AdvancePosition
	call	SeqData_ReadNextByte
	ldfr_berp	l, 250
	res_erpb	251, 7
	res_erpb	250, 7
	ldto_berp	c, 250
	extz	bc
	mul	bc, 96
	ldto_berp	a, 251
	extz	wa
	add	bc, wa
	ld	(10192:16), bc
	calr	BmDrEdit_ClampScrollPos
	pop	qiz
	inc	8, xsp
	ret
; BmDrEdit_ClampScrollPos (was NoteEdit_UpdateScrollAndDisplay_Helper2) --
; with limit = RAM 0x2774 * 96 - 1: if word 0x27CE + word 0x27D0 exceeds it,
; 0x27D0 := limit - 0x27CE.  Called only from BmDrEdit_CompoundWidgetUpdate.
BmDrEdit_ClampScrollPos:
	ld	e, (10100:16)
	mul	e, 96
	dec	1, de
	ld	wa, (10190:16)
	ld	bc, wa
	add	bc, (10192:16)
	cp	bc, de
	ret	ule
	sub	de, wa
	ld	(10192:16), de
	ret
	ld	wa, (10190:16)
	srl	wa, 2
	add	wa, 22
	ld	(10170:16), wa
	ld	wa, (10192:16)
	srl	wa, 2
	add	wa, (10170:16)
	ld	(10172:16), wa
	ld	wa, (10174:16)
	inc	3, wa
	ld	(10176:16), wa
	ret

; Re-enters the note under the cursor: reads its four parameter bytes into 0x2969..0x296c,
; steps back to its status byte, removes it from the part (BmDrEdit_CopyEventDataBetweenParts)
; and re-inserts a 6-byte note-on (0x90, 0x2784 note, then those bytes) at the right position
; (BmDrEdit_SeekForwardToEvent, BmDrEdit_ApplyVelocityChange), then recounts
; (BmDrEdit_CountMeasuresInit).  Errors go to BmDrEdit_RefreshDisplayState.
ReadSeqData_StoreParams:	.include "includes/generated/cc900/ReadSeqData_StoreParams.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_ReadSeqStoreParams_Error, ReadSeqData_StoreParams + 118

BmDrEdit_CalcBeatMeasure:	.include "includes/generated/cc900/BmDrEdit_CalcBeatMeasure.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_CalcBeatMeasure_ScanLoop, BmDrEdit_CalcBeatMeasure + 34
	.set	BmDrEdit_CalcBeatMeasure_IncrementCount, BmDrEdit_CalcBeatMeasure + 50
	.set	BmDrEdit_ComputeMeasureAndBeat, BmDrEdit_CalcBeatMeasure + 72

BmDrEdit_CalcSongPosition:
	ld bc, (0x279a:16)
	extz xbc
	div bc, 0x60
	ld (9688:16), 0
	ld (0x2772:16), bc
	cp bc, 0:i3
	jr z, BmDrEdit_CalcSongPos_Store
	ld de, 1:i3
	ld (9688:16), 0
	lda xbc, (0x27a4:16)

BmDrEdit_CalcSongPos_ScanLoop:
	ld wa, de
	extz xwa
	add xwa, xbc
	cp (xwa), 0x0
	jr z, BmDrEdit_CalcSongPos_IncrementCount
	inc 1, (9688:16)

BmDrEdit_CalcSongPos_IncrementCount:
	inc 1, de
	ld wa, (0x2772:16)
	dec 1, wa
	ld (0x2772:16), wa
	cp wa, 0:i3
	jr nz, BmDrEdit_CalcSongPos_ScanLoop

BmDrEdit_CalcSongPos_Store:
	ld bc, (0x27b2:16)
	ld a, (9688:16)
	extz wa
	add bc, wa
	ld (0x2744:16), bc
	ret

; Finds the entry equal to bar (0x2744) - (0x27b2) + 1 in the row list at 0x27a4 ((0x27a2)
; entries) and stores in 0x2782 the number of zero entries just before it.
BmDrEdit_CalcEventPosition:
	ld de, (0x2744:16)
	sub de, (0x27b2:16)
	inc 1, de
	ld hl, 0:i3
	lda xbc, (0x27a4:16)
	ld a, (0x27a2:16)
	extz wa
	jr BmDrEdit_CalcEventPos_CompareLoop

BmDrEdit_CalcEventPos_IncrementSearch:
	inc 1, hl
	cp hl, wa
	jr ge, BmDrEdit_CalcEventPos_InitBackward

BmDrEdit_CalcEventPos_CompareLoop:
	cp	e, (xbc+hl)
	jr nz, BmDrEdit_CalcEventPos_IncrementSearch

BmDrEdit_CalcEventPos_InitBackward:
	ld de, 0:i3
	dec 1, hl
	cp	(xbc+hl), 0x00
	jr z, BmDrEdit_CalcEventPos_CheckZero
	jr BmDrEdit_StoreEventPositionAndReturn

BmDrEdit_CalcEventPos_BackwardLoop:
	inc 1, de
	sub hl, 0x1
	jr lt, BmDrEdit_StoreEventPositionAndReturn

BmDrEdit_CalcEventPos_CheckZero:
	cp	(xbc+hl), 0x00
	jr z, BmDrEdit_CalcEventPos_BackwardLoop

BmDrEdit_StoreEventPositionAndReturn:
	ld (0x2782:16), de
	ret

BmDrEdit_SyncSeekCheck:
	push xiz
	calr BmDrEdit_SyncChannelAndGetPos
	ld iz, hl
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_InitScanEventPositions
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jrl nz, BmDrEdit_SyncSeek_PopIzRet
	calr BmDrEdit_SyncChannelAndGetPos
	ld iz, hl

BmDrEdit_InitScanEventPositions:
	ldib_erp 0xfb, 0
	ld (0x275e:16), iz
	ld (0x2760:16), 0
	cpw (0x2782:16), 0
	jr z, BmDrEdit_SyncSeek_ReadNext
	ldw (0x2772:16), 0

BmDrEdit_SyncSeek_ReadLoop:
	call SeqData_ReadNextByte
	cp l, 0x82
	jr z, BmDrEdit_SyncSeek_EndOfTrack
	cp l, 0x84
	jr nz, BmDrEdit_SyncSeek_CheckStep

BmDrEdit_SyncSeek_EndOfTrack:
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr nz, BmDrEdit_SyncSeek_PopIzRet
	calr BmDrEdit_SyncChannelAndGetPos
	ld iz, hl
	ldib_erp 0xfb, 1
	jr BmDrEdit_InitScanEventPositions

BmDrEdit_SyncSeek_CheckRetry:
	cpib_erp 0xfb, 1
	jr z, BmDrEdit_InitScanEventPositions

BmDrEdit_SyncSeek_SkipAndRead:
	call SeqData_SkipToNextEvent

BmDrEdit_SyncSeek_ReadNext:
	call SeqData_ReadNextByte
	cp l, 0x82
	jr z, BmDrEdit_SyncSeek_EndOfTrackAlt
	cp l, 0x84
	jr nz, BmDrEdit_SyncSeek_CheckStepMark

BmDrEdit_SyncSeek_EndOfTrackAlt:
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_SyncSeek_ResyncChannel
	jr BmDrEdit_SyncSeek_PopIzRet

BmDrEdit_SyncSeek_CheckStep:
	cp l, 0x81
	jr nz, BmDrEdit_SyncSeek_SkipEvent
	ld wa, (0x2772:16)
	inc 1, wa
	ld (0x2772:16), wa
	cp wa, (0x2782:16)
	jr nc, BmDrEdit_SyncSeek_CheckRetry

BmDrEdit_SyncSeek_SkipEvent:
	call SeqData_SkipToNextEvent
	jr BmDrEdit_SyncSeek_ReadLoop

BmDrEdit_SyncSeek_ResyncChannel:
	calr BmDrEdit_SyncChannelAndGetPos
	ld iz, hl
	ldib_erp 0xfb, 1
	jrl BmDrEdit_InitScanEventPositions

BmDrEdit_SyncSeek_CheckFlagAndClear:
	cpib_erp 0xfb, 0
	jrl nz, BmDrEdit_InitScanEventPositions
	calr BmDrEdit_ClearAndScanToEnd
	jr BmDrEdit_SyncSeek_StorePosition

BmDrEdit_SyncSeek_CheckStepMark:
	cp l, 0x81
	jr nz, BmDrEdit_SyncSeek_AdvanceAndCompare

BmDrEdit_SyncSeek_StorePosition:
	ld wa, (0x2782:16)
	add (0x275e:16), wa
	ldmm8 0x2760, 0x2784

BmDrEdit_SyncSeek_PopIzRet:
	pop xiz
	ret

BmDrEdit_SyncSeek_AdvanceAndCompare:
	call SeqData_AdvancePosition
	call SeqData_ReadNextByte
	cp l, (0x2784:16)
	jr nc, BmDrEdit_SyncSeek_CheckFlagAndClear
	jr BmDrEdit_SyncSeek_SkipAndRead

BmDrEdit_SeekForwardToEvent:
	push xiz
	calr BmDrEdit_SyncChannelAndGetPos
	ld iz, hl
	cp (SEQ_ERROR_CODE:16), 0
	jrl z, BmDrEdit_StoreStreamPos
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jrl z, BmDrEdit_SyncStorePos
	jrl BmDrEdit_PopIzRet

BmDrEdit_SeekFwd_CheckStep:
	cp l, 0x81
	jr nz, BmDrEdit_AdvanceAndCheckBeat
	jrl BmDrEdit_CalcStorePos

BmDrEdit_SeekFwd_InitCountLoop:
	ldw (0x2772:16), 0
	ldib_erp 0xfb, 0

BmDrEdit_SeekFwd_ReadLoop:
	call SeqData_ReadNextByte
	cp l, 0x82
	jr z, BmDrEdit_SeekFwd_EndOfTrack
	cp l, 0x84
	jr nz, BmDrEdit_SeekFwd_CheckStepMark

BmDrEdit_SeekFwd_EndOfTrack:
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_SeekFwd_ResyncChannel
	jrl BmDrEdit_PopIzRet

BmDrEdit_SeekFwd_CheckRetryFlag:
	cpib_erp 0xfb, 1
	jr z, BmDrEdit_StoreStreamPos

BmDrEdit_AdvanceAndCheckBeat:
	call SeqData_AdvancePosition
	call SeqData_ReadNextByte
	cp l, (0x2784:16)
	jrl ugt, BmDrEdit_SeekFwd_ClearAndCalcStore
	call SeqData_SkipToNextEvent
	call SeqData_ReadNextByte
	cp l, 0x82
	jr z, BmDrEdit_SeekFwd_EndOfTrackAlt
	cp l, 0x84
	jrl nz, BmDrEdit_SeekFwd_CheckStepAdvance

BmDrEdit_SeekFwd_EndOfTrackAlt:
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_SyncStorePos
	jrl BmDrEdit_PopIzRet

BmDrEdit_SeekFwd_CheckStepMark:
	cp l, 0x81
	jr nz, BmDrEdit_SkipEventAndContinue
	ld wa, (0x2772:16)
	inc 1, wa
	ld (0x2772:16), wa
	cp wa, (0x2782:16)
	jr c, BmDrEdit_SkipEventAndContinue
	call SeqData_SkipToNextEvent
	call SeqData_ReadNextByte
	cp l, 0x82
	jr z, BmDrEdit_SeekFwd_EndOfTrackResync
	cp l, 0x84
	jr nz, BmDrEdit_SeekFwd_CheckStepJump

BmDrEdit_SeekFwd_EndOfTrackResync:
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr nz, BmDrEdit_PopIzRet

BmDrEdit_SeekFwd_ResyncChannel:
	calr BmDrEdit_SyncChannelAndGetPos
	ld iz, hl
	ldib_erp 0xfb, 1
	jr BmDrEdit_StoreStreamPos

BmDrEdit_SeekFwd_CheckStepJump:
	cp l, 0x81
	jr nz, BmDrEdit_SeekFwd_CheckRetryFlag
	jr BmDrEdit_CalcStorePos

BmDrEdit_SkipEventAndContinue:
	call SeqData_SkipToNextEvent
	jrl BmDrEdit_SeekFwd_ReadLoop

BmDrEdit_SyncStorePos:
	calr BmDrEdit_SyncChannelAndGetPos
	ld iz, hl

BmDrEdit_StoreStreamPos:
	ld (0x275e:16), iz
	ld (0x2760:16), 0
	cpw (0x2782:16), 0
	jrl nz, BmDrEdit_SeekFwd_InitCountLoop
	call SeqData_ReadNextByte
	cp l, 0x82
	jr z, BmDrEdit_SeekFwd_EndOfTrackResyncAlt
	cp l, 0x84
	jrl nz, BmDrEdit_SeekFwd_CheckStep

BmDrEdit_SeekFwd_EndOfTrackResyncAlt:
	calr BmDrEdit_SeekToPartVoice
	cp (SEQ_ERROR_CODE:16), 0
	jr z, BmDrEdit_SyncStorePos
	jr BmDrEdit_PopIzRet

BmDrEdit_SeekFwd_CheckStepAdvance:
	cp l, 0x81
	jrl nz, BmDrEdit_AdvanceAndCheckBeat
	jr BmDrEdit_CalcStorePos

BmDrEdit_SeekFwd_ClearAndCalcStore:
	calr BmDrEdit_ClearAndScanToEnd

BmDrEdit_CalcStorePos:
	ld wa, (0x2782:16)
	add (0x275e:16), wa
	ldmm8 0x2760, 0x2784

BmDrEdit_PopIzRet:
	pop xiz
	ret

BmDrEdit_PrepareSecondaryNoteDisplay:	.include "includes/generated/cc900/BmDrEdit_PrepareSecondaryNoteDisplay.s"	; C: cc900/bmdredit_routines_m232.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	BmDrEdit_RestoreReturn, BmDrEdit_PrepareSecondaryNoteDisplay + 197
	.set	BmDrEdit_SecondaryNote_PopIzReturn, BmDrEdit_PrepareSecondaryNoteDisplay + 200

; Only when CURRENT_TITLE differs from PREVIOUS_TITLE: saves 0x28b1 in 0x283c and sets its bit 0;
; the active-part mask 0xf19e = word 0xffec (when 0x283a = 0) or (0x2963);
; Audio_CheckSubsystemReady; 0x251c = measure 0x2744 (0x251e raised to it when lower), 0x2668 =
; (0x251c), and bit 3 of 0x28a7 set unless that is 1.  Then SeqPlay_AllocBuffersAndInit (tail
; jump).
BmDrEdit_EnterPlayMode:
	ld a, (CURRENT_TITLE:16)
	cp a, (PREVIOUS_TITLE:16)
	ret z
	ld a, (SEQ_CYCLE_FLAGS:16)
	ld (0x283c:16), a
	set 0, (SEQ_CYCLE_FLAGS:16)
	cp (0x283a:16), 0
	jr nz, BmDrEdit_EnterPlay_RestoreSettings
	ldmm_sd24w 0xec, 0xff, 0x00, 0x9e, 0xf1
	jr BmDrEdit_EnterPlay_CheckAudio

BmDrEdit_EnterPlay_RestoreSettings:
	ldmm16 SEQ_TRACK_MASK, 0x2963

BmDrEdit_EnterPlay_CheckAudio:
	call Audio_CheckSubsystemReady
	ld wa, (0x2744:16)
	ld (9500:16), wa
	cp wa, (9502:16)
	jr ule, BmDrEdit_EnterPlay_UpdateProgress
	ld (9502:16), wa

BmDrEdit_EnterPlay_UpdateProgress:
	ldmm16 SEQ_START_MEASURE, 9500
	cpw (SEQ_START_MEASURE:16), 1
	jr z, BmDrEdit_EnterPlay_AllocAndInit
	set 3, (SEQ_RTMCFG:16)

BmDrEdit_EnterPlay_AllocAndInit:
	jp SeqPlay_AllocBuffersAndInit

; On leaving the note/drum copy screens (CURRENT_TITLE differs from PREVIOUS_TITLE): restores
; 0x28b1 from 0x283c, clears the active-part mask 0xf19e, re-runs the play-mode dispatcher and, when
; the active title is 0x95 or 0x98, restores 0xd4f from 0x2963 and SeqVoice_FindSingleActive.
BmDrEdit_ExitPlayMode:
	ld a, (CURRENT_TITLE:16)
	cp a, (PREVIOUS_TITLE:16)
	ret z
	ldmm8 SEQ_CYCLE_FLAGS, 0x283c
	ldw (SEQ_TRACK_MASK:16), 0
	call Audio_CheckSubsystemReady
	call AccWrap_PlayModeDispatch
	ld a, (ACTIVE_TITLE:16)
	cp a, 0x95
	jr z, BmDrEdit_ExitPlay_RestoreSequencer
	cp a, 0x98
	ret nz

BmDrEdit_ExitPlay_RestoreSequencer:
	ldmm16 3407, 0x2963
	call SeqVoice_FindSingleActive
	ret

