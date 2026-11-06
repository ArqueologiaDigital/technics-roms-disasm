; =============================================================================
; Accompaniment Engine (32K lines)
; =============================================================================
;
; Rhythm note dispatch, accompaniment voice selection, timing,
; patch management, drum configuration, and style conversion.
; One of the largest files in the ROM.
; =============================================================================

Rhythm_DispatchNote:
	ld l, a
	ld h, d
	call VoiceParam_ClampAndValidate
	ld a, l
	ld d, h
	cp a, 0x80
	jr c, Rhythm_DispatchNote_Lookup
	cp a, 0xf0
	jr c, Rhythm_DispatchNote_SetParam
	call AccTone_LookupByProgramWrapped
	jr Rhythm_DispatchNote_Return

Rhythm_DispatchNote_SetParam:
	and a, 0x7f
	call AccPatch_SetVoiceParam
	jr Rhythm_DispatchNote_Return

Rhythm_DispatchNote_Lookup:
	ld h, d
	call AccVoice_LookupWithOffset
	call AccStyle_ReadVoiceParam

Rhythm_DispatchNote_Return:
	ret

AccStyle_TempoLookupData:
	push	xiz
	calr	Rhythm_DispatchNote_Helper
	pop	xiz
	ret
Rhythm_DispatchNote_Helper:
	call	AccStyle_TempoLookupData_Helper
	ret

AccStyle_LookupTempoAndVelocity:
	push	xhl
	push	xwa
	xor	xhl, xhl
	ld	l, (36906:16)
	cp	l, 15
	jr	ule, AccStyle_LookupTempo_ClampL
	xor	l, l
AccStyle_LookupTempo_ClampL:
	sla	l, 1
	ld	xwa, AccStyle_TempoMultiplierTable
	ld	hl, (xwa+l)
	xor	xwa, xwa
	ld	a, (36907:16)
	cp	a, 79
	jr	ule, AccStyle_LookupTempo_AddAndStore
	xor	a, a
AccStyle_LookupTempo_AddAndStore:
	add	xhl, xwa
	sla	xhl, 1
	add	xhl, AccStyle_TempoWordTable
	ld	wa, (xhl)
	ld	(36910:16), a
	ld	(36911:16), w
	pop	xwa
	pop	xhl
	ret
AccStyle_TempoMultiplierTable:
	.byte 0x00, 0x00, 0x14, 0x00, 0x28, 0x00, 0x3c, 0x00
	.byte 0x50, 0x00, 0x64, 0x00, 0x78, 0x00, 0x8c, 0x00
	.byte 0xa0, 0x00, 0xb4, 0x00, 0xc8, 0x00, 0xdc, 0x00
	.byte 0xf0, 0x00, 0x04, 0x01, 0x18, 0x01, 0x68, 0x01

; AccStyle_LookupPanelRhythm: the panel's (rhythm group, number) of the selected style.
;   In:  RAM 0x90ea = program, 0x90eb = bank (low 3 bits).
;   Out: 0x90ee = rhythm group, 0x90ef = number (the low / high byte of the table word), which
;        RhythmROM_PatternDisp_Handle90 and SndParam_ResolveVoiceEntry pass to AccVoice_DispatchEntry.
;   Programs 0..127 read AccStyle_PanelRhythmTable[program][bank], 128..239
;   AccStyle_PanelRhythmTable_Ext[program & 0x7f, 0 above 11][bank], 240.. AccStyle_PanelRhythmTable_High
;   [program & 0x0f, 0 above 4].
AccStyle_LookupPanelRhythm:
	push XHL
	push XWA
	cp	(0x902a:16), 0x80
	jr nc, .Lc_f55875
	xor XHL,XHL
	ld	l, (0x902a:16)
	sla XHL, 0x03
	xor XWA,XWA
	ld	a, (0x902b:16)
	and A,0x07
	add XHL,XWA
	sla XHL, 0x01
	add XHL,AccStyle_PanelRhythmTable
	ld WA,(XHL)
	jr t, AccStyle_LookupPanelRhythm_Store
AccStyle_LookupPanelRhythm_Ext:
.Lc_f55875:
	cp	(0x902a:16), 0xf0
	jr nc, AccStyle_LookupPanelRhythm_High
	xor XHL,XHL
	ld	l, (0x902a:16)
	and L,0x7f
	cp L,0x0b
	jr ule, AccStyle_LookupPanelRhythm_ExtClamp
	xor L,L
AccStyle_LookupPanelRhythm_ExtClamp:
	sla	xhl, 3
	xor	xwa, xwa
	ld	a, (36907:16)
	and	a, 7
	add	xhl, xwa
	sla	xhl, 1
	add	xhl, AccStyle_PanelRhythmTable_Ext
	ld	wa, (xhl)
	jr	AccStyle_LookupPanelRhythm_Store
AccStyle_LookupPanelRhythm_High:
	xor	xhl, xhl
	ld	l, (36906:16)
	and	l, 15
	cp	l, 4:i3
	jr	ule, AccStyle_LookupPanelRhythm_HighClamp
	xor	l, l
AccStyle_LookupPanelRhythm_HighClamp:
	sla xhl, 1
	add xhl, AccStyle_PanelRhythmTable_High
	ld wa, (xhl)

AccStyle_LookupPanelRhythm_Store:
	ld	(36910:16), a
	ld	(36911:16), w
	pop	xwa
	pop	xhl
	ret
AccStyle_CheckRecordMode:
	ld	a, (0x3239:16)
	cp A,0x0e
	jr nz, AccStyle_CheckRecordReturn
	ld a, (CURRENT_MODE:16)
	cp A,0x0e
	jr z, AccStyle_CheckRecordReturn
	or	(0x3415:16), 0x80
AccStyle_CheckRecordReturn:
	ret

AccStyle_DetectChanges:
	and	(0x3283:16), 0xfe
	bit	0, (ACC_RUN_FLAGS:16)
	jrl nz, AccStyle_DetectChanges_CompareParams
	bit	1, (ACC_RUN_FLAGS:16)
	jrl z, AccStyle_DetectChanges_CompareParams
	bit 4, (SEQ_TRANSPORT_STATE:16)
	jr z, .Lc_f55901
	call NoteMap_SendAllNotesOff
AccStyle_DetectChanges_Init:
.Lc_f55901:
	ld	(0x322a:16), 0x00
	call Rhythm_SendNoteOnMax
	call AccNotes_ForgetAllSounding
	call Rhythm_SendChanPressure
	calr Rhythm_SendResetMsg
	and	(ACC_LANES_ENDING1:16), 0xc0
	and	(ACC_LANES_ENDING2:16), 0xc0
	and	(ACC_LANES_FILLIN1:16), 0xc0
	and	(ACC_LANES_FILLIN2:16), 0xc0
	and	(ACC_LANES_INTRO1:16), 0xc0
	and	(ACC_LANES_COUNTIN:16), 0xc0
	and	(ACC_LANES_INTRO2:16), 0xc0
	and	(0x32a5:16), 0xc0
	and	(ACC_DEFER_ENDING_LANES:16), 0xc0
	and	(ACC_DEFER_SECTION_LANES:16), 0xc0
	and	(0x31cc:16), 0xe7
	xor A,A
	ld	(ACC_PENDING_FILLIN:16), a
	ld	(ACC_PENDING_INTRO:16), a
	ld	(ACC_PENDING_ENDING:16), a
	ld	(0x3254:16), a
	ld	(ACC_VARIATION_CHANGE_PENDING:16), a
	ld	(0x3256:16), a
	ld	(0x3257:16), a
	ld	(0x3273:16), 0x00
	and	(ACC_SECTION_BUTTONS_HELD:16), 0x02
	and	(0x3271:16), 0xc0
	ld a, (PANEL_STYLE+5:16)
	and A,0xfc
	jr z, AccStyle_DetectChanges_QueueDone
	and (PANEL_STYLE+5:16), 0x03
	ld A, 0x00:opc
	ld W, 0x00:opc
	ld D, 0x05:opc
	ld E, 0x48:opc
	call Rhythm_QueuePartChangeEvent
AccStyle_DetectChanges_QueueDone:
	bit 2, (PANEL_STYLE+6:16)
	jr z, AccStyle_DetectChanges_MarkDirty
	and (PANEL_STYLE+6:16), 251
	ld a, 0x0:opc
	ld w, 0x0:opc
	ld d, 0x6:opc
	ld e, 0x48:opc
	call Rhythm_QueuePartChangeEvent

AccStyle_DetectChanges_MarkDirty:
	; ordi8 0x333b, 1 (v7 patched)
	or	(0x3283:16), 1
AccStyle_DetectChanges_CompareParams:
	bit	0, (0x323b:16)
	jr nz, .Lc_f559c1
	call Rhythm_SendChanPressure
	or	(0x3283:16), 0x01
	jrl t, AccStyle_DetectChanges_Epilogue
AccStyle_Compare_StyleNumber:
.Lc_f559c1:
	ld	a, (ACC_PENDING_STYLE:16)
	cp	a, (0x323e:16)
	jr	z, AccStyle_Compare_StyleNumDone
	or	(0x3283:16), 1
AccStyle_Compare_StyleNumDone:
	ld	a, (ACC_PENDING_GROUP:16)
	cp	a, (0x3240:16)
	jr	z, AccStyle_Compare_Variation
	or	(0x3283:16), 1
AccStyle_Compare_Variation:
	ld	a, (0x3241:16)
	and	a, 7
	cp	a, (0x3242:16)
	jr	z, AccStyle_Compare_VariationDone
	or	(0x3283:16), 1
AccStyle_Compare_VariationDone:
	bit	7, (0x3415:16)
	jr	z, AccStyle_Compare_RegistrationFlag
	and	(0x3415:16), 127
	or	(0x3283:16), 1
AccStyle_Compare_RegistrationFlag:
	ld	a, (0x327d:16)
	xor	a, (0x323a:16)
	and	a, 2
	cp	a, 0:i3
	jr	z, AccStyle_Compare_SplitA
	or	(0x3283:16), 1
	jr	AccStyle_DetectChanges_Epilogue
AccStyle_Compare_SplitA:
	ld	a, (ACC_REQ_INTRO:16)
	cp	a, (ACC_REQ_INTRO_PREV:16)
	jr	z, AccStyle_Compare_SplitADone
	or	(0x3283:16), 1
AccStyle_Compare_SplitADone:
	ld	a, (ACC_STYLE_ARRANGER_ON:16)
	cp	a, (0x324a:16)
	jr	z, AccStyle_Compare_LayerA
	or	(0x3283:16), 1
AccStyle_Compare_LayerA:
	ld	a, (ACC_VARIATION_REQUEST:16)
	cp	a, (0x324e:16)
	jr	z, AccStyle_Compare_LayerADone
	or	(0x3283:16), 1
AccStyle_Compare_LayerADone:
	ld	a, (0x324f:16)
	cp	a, (0x3250:16)
	jr	z, AccStyle_Compare_TuningState
	or	(0x3283:16), 1
AccStyle_Compare_TuningState:
	ld	a, (0x3330:16)
	xor	a, (0x3331:16)
	bit	0, a
	jr	z, AccStyle_Compare_TuningDone
	or	(0x3283:16), 1
AccStyle_Compare_TuningDone:
	call AccTuning_Toggle

AccStyle_DetectChanges_Epilogue:
	bit	0, (0x3283:16)
	jr z, .Lc_f55a72
	calr AccStyle_ApplyChanges
AccStyle_DetectChanges_ClearFlags:
.Lc_f55a72:
	ld	(0x329c:16), 0x00
	ld	(0x329d:16), 0x00
	ld	(0x32a7:16), 0x00
	and	(0x329f:16), 0xfc
	and	(0x32a9:16), 0x78

	ret



AccStyle_ApplyChanges:
	calr AccStyle_ResetAllVoiceState
	and	(ACC_RUN_FLAGS:16), 0xfb
	ld (0x0462:16), 0x00
	calr AccBuf_ResetAllPositions
	call AccNotes_ForgetAllSounding
	ld	a, (ACC_PENDING_GROUP:16)
	and A,0x7f
	and A,0x07
	ld	(ACC_STYLE_GROUP:16), a
	ld	(0x3230:16), a
	ld	a, (ACC_PENDING_STYLE:16)
	ld	(ACC_STYLE_NUMBER:16), a
	ld	(0x322f:16), a
	ld	(0x32b8:16), a
	call AccTuning_Init
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccStyle_ApplyChanges_Extended
	calr AccStyle_ApplyStandardStyle
	jr t, AccStyle_ApplyChanges_Finalize
AccStyle_ApplyChanges_Extended:
	calr AccStyle_ApplyExtendedStyle
	jr AccStyle_ApplyChanges_Finalize

AccStyle_ApplyChanges_Finalize:
	calr	AccBuf_InitKbd1WithMarkers
	ld	a, (ACC_BEATS_PER_BAR:16)
	ld	(1112:16), a
	ld	(12852:16), 1
	call	Rhythm_ProcessAllPartsAndLoad
	ret
AccStyle_ResetAllVoiceState:
	xor	wa, wa
	ld	(ACC_CLOCK:16), a
	ld	(ACC_BEAT:16), a
	ld	(12743:16), a
	ld	(12744:16), a
	ld	(12741:16), wa
	ld	(ACC_LANES_ENDED:16), a
	ld	(ACC_LANE_BEAT_POS:16), a
	ld	(12788:16), a
	ld	(12793:16), a
	ld	(12789:16), a
	ld	(12790:16), a
	ld	(12791:16), a
	ld	(12792:16), a
	ld	(ACC_BAR_COUNT:16), a
	ld	(ACC_SECTION_BAR:16), a
	ld	(12796:16), a
	ld	(ACC_LANE_BAR:16), a
	ld	(12798:16), a
	ld	(12803:16), a
	ld	(12799:16), a
	ld	(12800:16), a
	ld	(12801:16), a
	ld	(12802:16), a
	ld	(12949:16), a
	ld	(12805:16), a
	ld	(12806:16), a
	ld	(12807:16), a
	ld	(12808:16), a
	ld	(12809:16), a
	ld	(12810:16), a
	ld	(13005:16), a
	ld	(13006:16), a
	ld	(13007:16), a
	ld	(13008:16), a
	ld	(13009:16), a
	ld	(13010:16), a
	call	AccTone_CallWithSaveAll
	ret
AccStyle_ApplyStandardStyle:
	ld	a, (ACC_VARIATION_REQUEST:16)
	and	a, 3
	ld	(12928:16), a
	ld	(ACC_VARIATION_NEXT:16), a
	ld	a, (ACC_STYLE_NUMBER:16)
	ld	h, (ACC_STYLE_GROUP:16)
	call	AccVoice_LookupWithOffset
	ld	(ACC_STYLE_RECORD:16), xiy
	call	AccVoice_SelectAndApplyPatch
	call	AccVoice_ReadBankAssign
	ld	xiy, (ACC_STYLE_RECORD:16)
	call	Rhythm_UpdateTuningConfig
	ld	xiy, (ACC_STYLE_RECORD:16)
	ld	a, (ACC_REQ_INTRO:16)
	and	a, 7
	jr	z, AccStyle_ApplyStd_LoadTuning
	calr	AccVoice_SelectPartOffset
	jr	AccStyle_ApplyStd_Return
AccStyle_ApplyStd_LoadTuning:
	calr AccStyle_SetupPartAddresses

	ld	a, (ACC_LANE_SECTION:16)

	ld w, 0x0:opc

	; calr AccPart_GetVoiceParamOffsetTable (v7 displacement)
	calr	AccPart_GetVoiceParamOffsetTable
	; call AccVoice_LoadTuningBlock (v7 addr)
	call	AccVoice_LoadTuningBlock
	; ordi8 0x332c, 63 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 63
AccStyle_ApplyStd_Return:
	ret

AccStyle_SetupPartAddresses:
	ld	a, (xiy+977)
	ld	(ACC_STYLE_BANK:16), a
	ld	(ACC_PART_BIT:16), 1
	ld	a, (ACC_LANE_SECTION:16)
	calr	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(ACC_LANE_READ_POS:16), wa
	ld	(ACC_PART_BIT:16), 2
	ld	a, (0x31ec:16)
	calr	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d1:16), wa
	ld	(ACC_PART_BIT:16), 4
	ld	a, (0x31ed:16)
	calr	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d3:16), wa
	ld	(ACC_PART_BIT:16), 8
	ld	a, (0x31ee:16)
	calr	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d5:16), wa
	ld	(ACC_PART_BIT:16), 16
	ld	a, (0x31ef:16)
	calr	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d7:16), wa
	ld	(ACC_PART_BIT:16), 32
	ld	a, (0x31f0:16)
	calr	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d9:16), wa
	ld	xwa, AccStyle_DefaultStream
	add	xwa, 6
	ld	(0x31db:16), xwa
	and	(ACC_LANES_INTRO1:16), 192
	and	(ACC_LANES_COUNTIN:16), 192
	and	(ACC_LANES_INTRO2:16), 192
	ret
AccStyle_ApplyExtendedStyle:
	ld	xiy, AccStyle_ExtStyleMap
	ld	a, (ACC_STYLE_NUMBER:16)
	and	a, 127
	cp	a, 29
	jr	ule, AccStyle_ApplyExt_ClampIndex
	xor	a, a
AccStyle_ApplyExt_ClampIndex:
	ld	a, (xiy+a)
	ld	(12928:16), a
	ld	a, (ACC_STYLE_NUMBER:16)
	and	a, 127
	call	AccVoice_ResolveParamAddr
	ld	(ACC_STYLE_RECORD:16), xiy
	ld	l, (xiy+16)
	ld	h, (xiy+17)
	and	h, 15
	and	h, 7
	cp	hl, 520
	jr	z, AccStyle_ApplyExt_SkipClamp
	cp	hl, 792
	jr	z, AccStyle_ApplyExt_SkipClamp
	call	VoiceParam_ClampAndValidate
AccStyle_ApplyExt_SkipClamp:
	ld	a, l
	call	AccVoice_LookupWithOffset
	ld	(12827:16), xiy
	call	AccVoice_SelectAndApplyPatch
	ld	w, (ACC_STYLE_NUMBER:16)
	call	AccPatch_SetByChordIndex
	bit	0, (0x32ab:16)
	jr	nz, AccStyle_ApplyExt_CheckSplit
	call	AccPedal_ProcessAllChanges
AccStyle_ApplyExt_CheckSplit:
	ld	a, (ACC_REQ_INTRO:16)
	and	a, 7
	jrl	z, Seq_ProcessAndContinue
	bit	0, (0x32ab:16)
	jrl	z, AccStyle_ApplyExt_SelectPart
	bit	1, (ACC_REQ_INTRO:16)
	jr	z, AccStyle_ApplyExt_CheckBit0
	ld	a, (ACC_BEATS_PER_BAR:16)
	ld	xhl, AccStyle_ApplyExt_SkipClamp_Table
	bit_dri	0, 0x03, 0xec, 0xe0
	jr	z, AccStyle_ApplyExt_SelectPart
	and	(ACC_REQ_INTRO:16), 253
	and	(PANEL_STYLE+5:16), 247
	ld	e, 72:opc
	ld	d, 5:opc
	ld	a, 0:opc
	ld	w, 0:opc
	call	Rhythm_QueuePartChangeEvent
	jr	Seq_ProcessAndContinue
AccStyle_ApplyExt_CheckBit0:
	bit	0, (ACC_REQ_INTRO:16)
	jr	z, AccStyle_ApplyExt_CheckBit1
	ld	a, (12972:16)
	cp	a, (ACC_BEATS_PER_BAR:16)
	jr	z, AccStyle_ApplyExt_UseSecondary
	and	(ACC_REQ_INTRO:16), 254
	and	(PANEL_STYLE+5:16), 251
	ld	e, 72:opc
	ld	d, 5:opc
	ld	a, 0:opc
	ld	w, 0:opc
	call	Rhythm_QueuePartChangeEvent
	jr	Seq_ProcessAndContinue
AccStyle_ApplyExt_CheckBit1:
	ld	a, (12974:16)
	cp	a, (ACC_BEATS_PER_BAR:16)
	jr	z, AccStyle_ApplyExt_UseSecondary
	and	(ACC_REQ_INTRO:16), 251
	and	(PANEL_STYLE+6:16), 251
	ld	e, 72:opc
	ld	d, 5:opc
	ld	a, 0:opc
	ld	w, 0:opc
	call	Rhythm_QueuePartChangeEvent
	jr	Seq_ProcessAndContinue
AccStyle_ApplyExt_UseSecondary:
	calr AccStyle_UseSecondarySource
	jr AccStyle_ApplyExt_UpdateTuning


; -----------------------------------------------------------------------------
; Section: Sequence Processing & Voice Selection
; -----------------------------------------------------------------------------
; Sequence continuation and accompaniment voice
; part offset selection.
; -----------------------------------------------------------------------------

Seq_ProcessAndContinue:
	calr AccPart_ResetAndCopyTuning
	jr AccStyle_ApplyExt_UpdateTuning

AccStyle_ApplyExt_SelectPart:
	ld	xiy, (12827:16)
	calr	AccVoice_SelectPartOffset
AccStyle_ApplyExt_UpdateTuning:
	ld	xiy, (12827:16)
	calr	Rhythm_UpdateTuningConfig
	ret
AccVoice_SelectPartOffset:
	ldw HL, 0x0020
	bit	0, (ACC_REQ_INTRO:16)
	jr nz, .Lc_f55d98
	ldw HL, 0x0022
	bit	1, (ACC_REQ_INTRO:16)
	jr nz, .Lc_f55d98
	ldw HL, 0x0420
AccVoice_SelectPartOffset_Resolved:
.Lc_f55d98:
	calr AccStyle_SetupPartAddressesByHL
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, .Lc_f55dac
	ld	xiy, (ACC_STYLE_RECORD:16)
	call AccTuning_CopyAllPartsFromStyle
	jr t, AccVoice_SelectPartOffset_Apply63
AccVoice_SelectPartOffset_Bound:
.Lc_f55dac:
	ld	a, (ACC_LANE_SECTION:16)
	ld W, 0x03:opc
	bit	2, (ACC_REQ_INTRO:16)
	jr z, AccVoice_SelectPartOffset_SetModeW
	ld W, 0x04:opc
AccVoice_SelectPartOffset_SetModeW:
	calr AccPart_GetVoiceParamOffsetTable
	call AccVoice_LoadTuningBlock

AccVoice_SelectPartOffset_Apply63:
	or	(ACC_LANES_RESYNC:16), 63
	bit	0, (ACC_REQ_INTRO:16)
	jr	z, AccVoice_SelectPartOffset_Bit1
	or	(ACC_LANES_INTRO1:16), 63
	and	(ACC_LANES_COUNTIN:16), 192
	and	(ACC_LANES_INTRO2:16), 192
	jr	AccVoice_SelectPartOffset_Return
AccVoice_SelectPartOffset_Bit1:
	bit	1, (ACC_REQ_INTRO:16)
	jr	z, AccVoice_SelectPartOffset_Mode3
	and	(ACC_LANES_INTRO1:16), 192
	or	(ACC_LANES_COUNTIN:16), 63
	and	(ACC_LANES_INTRO2:16), 192
	jr	AccVoice_SelectPartOffset_Return
AccVoice_SelectPartOffset_Mode3:
	; anddi8 (0x3316), 192 (v7 patched)
	and	(ACC_LANES_INTRO1:16), 192
	; anddi8 (0x3317), 192 (v7 patched)
	and	(ACC_LANES_COUNTIN:16), 192
	; ordi8 0x3318, 63 (v7 patched)
	or	(ACC_LANES_INTRO2:16), 63
AccVoice_SelectPartOffset_Return:
	ret

AccStyle_SetupPartAddressesByHL:
	.byte	0xc3, 0xf5, 0xd1, 0x03, 0x21, 0xf1, 0xcd, 0x31
	.byte	0x41, 0xd7, 0x3c, 0x9b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x01, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xcf, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x02, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd1, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x04, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd3, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x08, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd5, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x10, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd7, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x20, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd9, 0x31
	.byte	0x50, 0x40, 0x99, 0x6b, 0xe4, 0x00, 0xe8, 0xc8
	.byte	0x06, 0x00, 0x00, 0x00, 0xf1, 0xdb, 0x31, 0x60
	.byte 0x0e
AccStyle_UseSecondarySource:
	ld	a, (0x32ad:16)
	bit	0, (ACC_REQ_INTRO:16)
	jr nz, .Lc_f55e8b
	ld	a, (0x32af:16)
AccStyle_UseSecondary_Resolve:
.Lc_f55e8b:
	call AccVoice_ResolveParamAddr
	calr AccPart_InitPositionsAndBase
	call AccTuning_CopyAllPartsFromStyle
	or	(ACC_LANES_RESYNC:16), 0x3f
	bit	0, (ACC_REQ_INTRO:16)
	jr z, .Lc_f55eb2
	or	(ACC_LANES_INTRO1:16), 0x3f
	and	(ACC_LANES_COUNTIN:16), 0xc0
	and	(ACC_LANES_INTRO2:16), 0xc0
	jr t, AccStyle_UseSecondary_Return
AccStyle_UseSecondary_Mode3:
.Lc_f55eb2:
	and	(ACC_LANES_INTRO1:16), 0xc0
	and	(ACC_LANES_COUNTIN:16), 0xc0
	or	(ACC_LANES_INTRO2:16), 0x3f



AccStyle_UseSecondary_Return:
	ret


; -----------------------------------------------------------------------------
; Section: Accompaniment Part Management
; -----------------------------------------------------------------------------
; Part position initialization, buffer reset, tuning
; configuration, and style index lookup.
; -----------------------------------------------------------------------------

AccPart_InitPositionsAndBase:
	call	AccInit_AllPartPositions
	ld	xwa, AccStyle_DefaultStream
	add	xwa, 6
	ld	(12763:16), xwa
	ret
AccPart_ResetAndCopyTuning:
	ld	xiy, (ACC_STYLE_RECORD:16)
	calr AccPart_InitPositionsAndBase
	call AccTuning_CopyAllPartsFromStyle
	or	(ACC_LANES_RESYNC:16), 0x3f
	and	(ACC_LANES_INTRO1:16), 0xc0
	and	(ACC_LANES_COUNTIN:16), 0xc0
	and	(ACC_LANES_INTRO2:16), 0xc0
	ret
AccBuf_ResetAllPositions:
	ld	xhl, 10716
	call	AccBuf_ResetOnePosition
	ld	xhl, 10972
	call	AccBuf_ResetOnePosition
	ld	xhl, 11228
	call	AccBuf_ResetOnePosition
	ld	xhl, 11484
	call	AccBuf_ResetOnePosition
	ld	xhl, 11740
	call	AccBuf_ResetOnePosition
	ld	xhl, 11996
	call	AccBuf_ResetOnePosition
	ret
AccBuf_InitKbd1WithMarkers:
	ld	XHL,0x000029dc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	ld	(xhl+iy), 0xd0
	call	RingBuf_AdvanceIndex
	ld	(xhl+iy), 0x01
	call	RingBuf_AdvanceIndex
	ld	(xhl+iy), 0x10
	call	RingBuf_AdvanceIndex
	ld	(xhl+iy), 0x01
	call	RingBuf_AdvanceIndex
	ld	(xhl+4), iy
	ret
Rhythm_SendResetMsg:
	ld a, 0xd8:opc
	ld w, 0x10:opc
	ld e, 0x0:opc
	call Rhythm_Send3ByteMsg
	ret

Rhythm_UpdateTuningConfig:
	ld	w, (ACC_CHORD_TYPE:16)
	ld	a, (12928:16)
	calr	Rhythm_LookupTuningByStyle
	ld	(ACC_LANE_SECTION:16), a
	ld	(12780:16), a
	ld	(12781:16), a
	ld	(12782:16), a
	ld	(12783:16), a
	ld	(12784:16), a
	ld	w, (ACC_CHORD_TYPE:16)
	ld	a, (12928:16)
	calr	Rhythm_LookupTuningRange
	ret
Rhythm_LookupTuningByStyle:
	calr Rhythm_LookupStyleIndex
	calr AccVoice_LookupParamIndex
	ld xhl, Rhythm_LookupTuningByStyle_Data
	ld	a, (xhl+a)
	ret

Rhythm_LookupTuningRange:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, Rhythm_LookupTuning_DefaultRange
	calr Rhythm_LookupStyleIndex
	calr AccVoice_LookupParamIndex
	ld XHL,Rhythm_LookupTuningRange_Data
	sla A, 0x01
	ld	hl, (xhl+a)
	ld	wa, (xiy+hl)
	jr	Rhythm_StoreTuningRange
Rhythm_LookupTuning_DefaultRange:
	ld a, 0x39:opc
	ld w, 0x39:opc

Rhythm_StoreTuningRange:
	ld	(12935:16), a
	ld	(12936:16), w
	ret
Rhythm_LookupStyleIndex:
	ld xhl, Rhythm_LookupStyleIndex_Data
	cp w, 0x30
	jr c, Rhythm_LookupStyleIndex_Compute
	xor w, w

Rhythm_LookupStyleIndex_Compute:
	ld	w, (xhl+w)
	and w, 0x3
	ld xhl, Rhythm_LookupStyleIndex_Compute_Data
	ld	l, (xhl+w)
	xor h, h
	ret

AccVoice_LookupParamIndex:
	push xhl
	ld xhl, AccVoice_ParamIndexData
	and wa, 0x3
	ld	a, (xhl+wa)
	pop xhl
	ret

AccVoice_ParamIndexData:
; ** v7: typed as in v10 (the 115 bytes are identical in both ROMs) -- lane accomp
;    2026-09-25, scripts/converters/lane_accomp_port_typed_v10_to_v7.py.
; (this lane's third re-frame pass had read four bank-register instructions
;  into +0x04..+0x25 here; that reading is withdrawn with this typing.)
; RE-FRAMED 2026-09-02 (lane v10seq). Was 60 lines of mnemonics
; (nop / pop sr / reti / add hl 994 / ldio / halt) with 18 undecodable
; bytes wedged between them as .byte. It is DATA: all five references to
; this block -- AccVoice_ParamIndexData and the positional labels +0x26
; +0x57 +0x5B +0x63 -- are `ld xhl, <label>`, an address taken; nothing
; in v10/maincpu calls or jumps to any of them.
; The layout below is the readers own indexing, and the bytes corroborate
; it: the +0x26 segment is exactly 48 entries long, matching its reader
; `cp w,0x30` bound, and holds nothing but 0/1/2; +0x5B is the ramp
; 0,5,10,...,35; and +0x63 reads as 8 LE16 words (0x03D2..0x03D8 then
; 0x07D2..0x07D8), matching its reader `sla a,1`.
; +0x00 (4 B). AccVoice_LookupParamIndex: ld xhl <here> / and wa 0x3 / ldb_sri -> byte[wa&3]
	.byte 0x00, 0x03, 0x04, 0x07	; |....|
; +0x04 (34 B). No reader found: nothing in the tree names this offset
	.byte 0xdb, 0xc8, 0xe2, 0x03, 0xd8, 0x12, 0xd7, 0x30, 0x98, 0xd8, 0x83, 0xc3, 0x07, 0xf4, 0xec, 0x21	; |.......0.......!|
	.byte 0xc9, 0xcf, 0xff, 0x6e, 0x0c, 0xd7, 0x30, 0x88, 0xd8, 0xc8, 0xe2, 0x03, 0xc3, 0x07, 0xf4, 0xe0	; |...n..0.........|
	.byte 0x21, 0x0e	; |!.|
; +0x26 (48 B). Rhythm_LookupStyleIndex: cp w 0x30 else xor w w / ldb_sri -> byte[w] with w < 48. Every value is 0 1 or 2
Rhythm_LookupStyleIndex_Data:
	.byte 0x00, 0x00, 0x01, 0x01, 0x00, 0x02, 0x01, 0x01, 0x02, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x01	; |................|
	.byte 0x01, 0x01, 0x01, 0x01, 0x02, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x01	; |................|
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; |................|
; +0x56 (1 B). Gap between the 48-entry table and the next
	.byte 0x00	; |.|
; +0x57 (4 B). Rhythm_LookupStyleIndex: and w 0x3 / ldb_sri -> byte[w&3]
Rhythm_LookupStyleIndex_Compute_Data:
	.byte 0x00, 0x08, 0x04, 0x0c	; |....|
; +0x5B (8 B). Rhythm_LookupTuningByStyle: ldb_sri -> byte[a]. Ramp 0 5 10 ... 35
Rhythm_LookupTuningByStyle_Data:
	.byte 0x00, 0x05, 0x0a, 0x0f, 0x14, 0x19, 0x1e, 0x23	; |.......#|
; +0x63 (8 x LE16). Rhythm_LookupTuningRange: sla a 1 / ldw_sri -> word[a]
Rhythm_LookupTuningRange_Data:
	.short 0x03d2, 0x03d4, 0x03d6, 0x03d8, 0x07d2, 0x07d4, 0x07d6, 0x07d8

AccPart_GetVoiceParamOffsetTable:
	ld xhl, AccPart_VoiceParamDispatchTable
	ldfr_berp W, 0x31
	extz wa
	sla wa, 2
	ld	xhl, (xhl+wa)
	ldto_berp W, 0x31
	sla w, 1
	ld	hl, (xhl+w)
	extz xhl
	ret

AccPart_VoiceParamDispatchTable:
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseA
	.long AccPart_VoiceParamOffsets_BaseB
	.long AccPart_VoiceParamOffsets_BaseB
	.long AccPart_VoiceParamOffsets_BaseB
	.long AccPart_VoiceParamOffsets_BaseB
	.long AccPart_VoiceParamOffsets_BaseB
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordA
	.long AccPart_VoiceParamOffsets_ChordB
	.long AccPart_VoiceParamOffsets_ChordB
	.long AccPart_VoiceParamOffsets_ChordB
	.long AccPart_VoiceParamOffsets_ChordB
	.long AccPart_VoiceParamOffsets_ChordB
AccPart_VoiceParamOffsets_BaseA:
	; data, not code: AccPart_VoiceParamOffsets_BaseA is reached only as data (15 data), and its instruction decode held halt, normal (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x00, 0x00, 0x62, 0x00, 0xc4, 0x00, 0x26, 0x01, 0x26, 0x05, 0x57, 0x01, 0x57, 0x05
AccPart_VoiceParamOffsets_BaseB:
	; data, not code: AccPart_VoiceParamOffsets_BaseB is reached only as data (5 data), and its instruction decode held halt (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x31, 0x00, 0x93, 0x00, 0xf5, 0x00, 0x26, 0x01, 0x26, 0x05, 0x57, 0x01, 0x57, 0x05
AccPart_VoiceParamOffsets_ChordA:
	; data, not code: AccPart_VoiceParamOffsets_ChordA is reached only as data (15 data), and its instruction decode held halt, max (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x00, 0x04, 0x62, 0x04, 0xc4, 0x04, 0x26, 0x01, 0x26, 0x05, 0x57, 0x01, 0x57, 0x05
AccPart_VoiceParamOffsets_ChordB:
	; data, not code: AccPart_VoiceParamOffsets_ChordB is reached only as data (5 data), and its instruction decode held halt (scripts/converters/data_as_code_to_bytes.py).
	.byte	0x31, 0x04, 0x93, 0x04, 0xf5, 0x04, 0x26, 0x01, 0x26, 0x05, 0x57, 0x01, 0x57, 0x05

AccPart_LookupBoundVoiceParam:
	ld w, a
	calr AccStyle_ReadParamOffset
	ld xhl, AccPart_LookupBoundVoiceParam_Data
	cp a, 0x14
	jr c, AccPart_LookupBound_ComputeIdx
	ld xhl, AccPart_LookupBoundVoiceParam_Data_2

AccPart_LookupBound_ComputeIdx:
	sla w, 1
	ld	hl, (xhl+w)
	ret

AccStyle_ReadParamOffset:
	ld	xhl, AccStyle_ReadParamOffset_Data
	sla	w, 1
	ld	hl, (xhl+w)
	extz	xhl
	add	xhl, xiy
	cp	(ACC_PART_BIT:16), 1
	jr	nz, AccStyle_ReadParamOff_Part2
	ld	w, (xhl+0:8)
	jr	AccStyle_ReadParamRet
AccStyle_ReadParamOff_Part2:
	cp	(ACC_PART_BIT:16), 2
	jr	nz, AccStyle_ReadParamOff_Part4
	ld	w, (xhl+0:8)
	jr	AccStyle_ReadParamRet
AccStyle_ReadParamOff_Part4:
	cp	(ACC_PART_BIT:16), 4
	jr	nz, AccStyle_ReadParamOff_Part8
	ld	w, (xhl+40)
	jr	AccStyle_ReadParamRet
AccStyle_ReadParamOff_Part8:
	cp	(ACC_PART_BIT:16), 8
	jr	nz, AccStyle_ReadParamOff_Part16
	ld	w, (xhl+80)
	jr	AccStyle_ReadParamRet
AccStyle_ReadParamOff_Part16:
	cp	(ACC_PART_BIT:16), 16
	jr	nz, AccStyle_ReadParamOff_Part32
	ld	w, (xhl+120)
	jr	AccStyle_ReadParamRet
AccStyle_ReadParamOff_Part32:
	ld	w, (xhl+160)

AccStyle_ReadParamRet:
	ret

AccStyle_ByteDataBlock:
	; framing ported from v10's source for the same label (same span length, statement for statement); 114 of 138 slots byte-identical
	ld	xhl, AccStyle_ReadParamOffset_Data
	sla	a, 1
	ld	hl, (xhl+a)
	extz	xhl
	add	xhl, xiy
	; v10 does not spell this byte either
	cp	(ACC_PART_BIT:16), 1
	; v10 does not spell this byte either
	jr	nz, AccStyle_ByteDataBlock_Skip
	ld	a, (xhl+20)
	jr	AccStyle_ReadParamOffset_Return
AccStyle_ByteDataBlock_Skip:
	; v10 does not spell this byte either
	cp	(ACC_PART_BIT:16), 2
	; v10 does not spell this byte either
	jr	nz, AccStyle_ByteDataBlock_Skip2
	ld	a, (xhl+20)
	jr	AccStyle_ReadParamOffset_Return
AccStyle_ByteDataBlock_Skip2:
	; v10 does not spell this byte either
	cp	(ACC_PART_BIT:16), 4
	; v10 does not spell this byte either
	jr	nz, AccStyle_ReadParamOffset_Skip
	; v10 does not spell this byte either
	ld	a, (xhl+60)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	jr	AccStyle_ReadParamOffset_Return
	; v10 does not spell this byte either
	; v10 does not spell this byte either
AccStyle_ReadParamOffset_Skip:
	cp	(ACC_PART_BIT:16), 8
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	jr	nz, AccStyle_ReadParamOffset_Skip2
	ld	a, (xhl+100)
	jr	AccStyle_ReadParamOffset_Return
	; v10 does not spell this byte either
AccStyle_ReadParamOffset_Skip2:
	cp	(ACC_PART_BIT:16), 16
	; v10 does not spell this byte either
	jr	nz, AccStyle_ReadParamOffset_Skip3
	ld	a, (xhl+140)
	jr	AccStyle_ReadParamOffset_Return
	; v10 does not spell this byte either
AccStyle_ReadParamOffset_Skip3:
	cp	(ACC_PART_BIT:16), 32
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	jr	nz, AccStyle_ReadParamOffset_Return
	ld	a, (xhl+180)
AccStyle_ReadParamOffset_Return:
	ret
; (v7: the routine's final `ret` carries the label AccStyle_ReadParamOffset_Return.)
; AccStyle_ByteDataBlock +0x5C..+0xCB -- three tables of LE16 byte offsets into
; a style record (the offsets below are relative to AccStyle_ByteDataBlock,
; whose first 0x5C bytes are the routine above).
; ** RE-TYPED 2026-09-25 (lane accomp): was nop/max/normal/`retd 4096`...
; mnemonics (data-as-code).  Readers:
;   AccStyle_ReadParamOffset: ld xhl, AccStyle_ReadParamOffset_Data / sla w,1 /
;       ldw_sri hl,(xhl+w) / extz xhl / add xhl,xiy -- entry W, a 16-bit
;       offset added to the style pointer XIY (the routine at
;       AccStyle_ByteDataBlock does the same with A).
;   AccPart_LookupBoundVoiceParam: xhl = AccPart_LookupBoundVoiceParam_Data when
;       A < 0x14, else AccPart_LookupBoundVoiceParam_Data_2; sla w,1 / ldw_sri hl,(xhl+w).
; The +0x5C table holds 0..19 and then 0x400..0x413 (a second bank 1 KB
; further on); +0xAC and +0xBC are the same two banks at stride 2.  Sizes:
; the reader offsets pin +0x5C at 40 entries and +0xAC at 8; +0xBC is the 16
; bytes up to AccVoice_ComputeParamAddr.
; readers in v7 (address from the linked ELF): AccStyle_ReadParamOffset 0xF56197,
;     AccPart_LookupBoundVoiceParam 0xF5617A
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; -- comments that sat inside this range before the re-type, in order:
	; v10 does not spell this byte either
; +0x5C  40 x LE16: 0..19, then 0x400..0x413
AccStyle_ReadParamOffset_Data:
	.short 0x0000, 0x0001, 0x0002, 0x0003, 0x0004, 0x0005, 0x0006, 0x0007, 0x0008, 0x0009
	.short 0x000a, 0x000b, 0x000c, 0x000d, 0x000e, 0x000f, 0x0010, 0x0011, 0x0012, 0x0013
	.short 0x0400, 0x0401, 0x0402, 0x0403, 0x0404, 0x0405, 0x0406, 0x0407, 0x0408, 0x0409
	.short 0x040a, 0x040b, 0x040c, 0x040d, 0x040e, 0x040f, 0x0410, 0x0411, 0x0412, 0x0413
; +0xAC  8 x LE16: 0, 2, 4 ... 14
AccPart_LookupBoundVoiceParam_Data:
	.short 0x0000, 0x0002, 0x0004, 0x0006, 0x0008, 0x000a, 0x000c, 0x000e
; +0xBC  8 x LE16: 0x400, 0x402 ... 0x40E
AccPart_LookupBoundVoiceParam_Data_2:
	.short 0x0400, 0x0402, 0x0404, 0x0406, 0x0408, 0x040a, 0x040c, 0x040e
AccVoice_ComputeParamAddr:
	cp A,0x0f
	jr nc, .Lc_f562c9
	ldw HL, 0x0018
	bit	0, (ACC_PENDING_FILLIN:16)
	jr nz, AccVoice_ReturnExtHL
	ldw HL, 0x001a
	jr t, AccVoice_ReturnExtHL
AccVoice_ParamAddr_Range0F_14:
.Lc_f562c9:
	cp A,0x14
	jr nc, .Lc_f562dc
	ldw HL, 0x001c
	bit	0, (ACC_PENDING_FILLIN:16)
	jr nz, AccVoice_ReturnExtHL
	ldw HL, 0x001e
	jr t, AccVoice_ReturnExtHL
AccVoice_ParamAddr_Range14_23:
.Lc_f562dc:
	cp A,0x23
	jr nc, .Lc_f562ef
	ldw HL, 0x0418
	bit	0, (ACC_PENDING_FILLIN:16)
	jr nz, AccVoice_ReturnExtHL
	ldw HL, 0x041a
	jr t, AccVoice_ReturnExtHL
AccVoice_ParamAddr_Range23Plus:
.Lc_f562ef:
	ldw HL, 0x041c
	bit	0, (ACC_PENDING_FILLIN:16)
	jr nz, AccVoice_ReturnExtHL
	ldw HL, 0x041e
AccVoice_ReturnExtHL:
	extz xhl
	ret

AccTuning_SetAllFromLookup:
	calr	AccTuning_FetchValue
	ld	(ACC_LANE_SECTION:16), a
	ld	(12780:16), a
	ld	(12781:16), a
	ld	(12782:16), a
	ld	(12783:16), a
	ld	(12784:16), a
	ret
AccTuning_FetchValue:
	ld xhl, AccTuning_ValueTable
	ld	a, (xhl+a)
	ret

AccTuning_ValueTable:
; AccTuning_ValueTable -- 40 x u8, value = 5 * (index / 5): five 0s, five 5s, ...
; five 35s.  ** RE-TYPED 2026-09-25 (lane accomp): was nop/halt/`ldw (10:8)`...
; mnemonics (data-as-code).  Read by AccTuning_FetchValue:
;     ld xhl, AccTuning_ValueTable / ld_rr8b a, xhl, a (= ld a,(xhl+a)) / ret
; i.e. entry A, returned in A.  Callers: AccTuning_SetAllFromLookup (stores it
; to the six bytes 0x32a3..0x32a8) and two more `call AccTuning_FetchValue`.
; 40 entries: the table ends where AccVoice_ProcessAllSixParts begins (its
; first byte, 0x1E, is a `calr`), and the step-of-5 pattern is complete at 40.
; readers in v7 (address from the linked ELF): AccTuning_FetchValue 0xF5631A
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
	.byte 0, 0, 0, 0, 0, 5, 5, 5, 5, 5
	.byte 10, 10, 10, 10, 10, 15, 15, 15, 15, 15
	.byte 20, 20, 20, 20, 20, 25, 25, 25, 25, 25
	.byte 30, 30, 30, 30, 30, 35, 35, 35, 35, 35

AccVoice_ProcessAllSixParts:
	calr AccVoice_SavePartState1
	calr AccVoice_ProcessEventLoop
	calr AccVoice_RestorePartState1
	ret

AccVoice_SavePartState1:
	and	(ACC_PART_FLAGS:16), 0xfc
	ld	(ACC_BAD_EVENT_COUNT:16), 0x00
	ld A, 0x01:opc
	ld	(ACC_PART_BIT:16), a
	ld	wa, (ACC_LANE_BLOCK:16)
	ld	(ACC_CUR_BLOCK:16), wa
	ld	wa, (ACC_LANE_READ_POS:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (ACC_LANE_BAR:16)
	ld	(ACC_CUR_BAR:16), a
	ld	a, (ACC_LANE_BEAT_POS:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	a, (ACC_LANE_SECTION:16)
	ld	(ACC_CUR_SECTION:16), a
	ld	a, (ACC_LANE_MEASURE:16)
	ld	(ACC_CUR_MEASURE:16), a
	ret
AccVoice_RestorePartState1:
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(ACC_LANE_BLOCK:16), wa
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(ACC_LANE_READ_POS:16), wa
	ld	a, (ACC_CUR_BAR:16)
	ld	(ACC_LANE_BAR:16), a
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(ACC_LANE_BEAT_POS:16), a
	ld	a, (ACC_CUR_SECTION:16)
	ld	(ACC_LANE_SECTION:16), a
	ld	a, (ACC_CUR_MEASURE:16)
	ld	(ACC_LANE_MEASURE:16), a
	ret
AccVoice_ProcessEventLoop:
	bit	0, (ACC_PART_FLAGS:16)
	jr z, .Lc_f563d1
	jr t, AccVoice_EventLoop_Idle
AccVoice_EventLoop_Active:
.Lc_f563d1:
	calr AccVoice_DispatchByChannel
	bit	0, (ACC_PART_FLAGS:16)
	jr z, .Lc_f563dc
	jr t, AccVoice_EventProcessingReturn
AccVoice_EventLoop_Dispatch:
.Lc_f563dc:
	ld	w, (ACC_PART_BIT:16)
	ld	iz, (ACC_CUR_BLOCK:16)
	call AccVoice_SelectByMask
	ld	iy, (ACC_CUR_READ_POS:16)
	ld	a, (xhl+iy)
	cp	a, 131
	jr	nz, AccVoice_EventLoop_Check81
	calr	AccVoice_HandleMarker83
	jr	AccVoice_EventProcessingReturn
AccVoice_EventLoop_Check81:
	cp a, 0x81
	jr nz, AccVoice_EventLoop_CheckNoteOn
	calr AccVoice_HandleBarEndEvent
	jr AccVoice_EventProcessingReturn

AccVoice_EventLoop_CheckNoteOn:
	cp a, 0x90
	jr z, AccVoice_HandleEvent_D5
	cp a, 0x91
	jr z, AccVoice_HandleEvent_D5
	cp a, 0xd1
	jr z, AccVoice_HandleEvent_D5
	cp a, 0xd2
	jr z, AccVoice_HandleEvent_D5
	cp a, 0xd3
	jr z, AccVoice_HandleEvent_D5
	cp a, 0xd4
	jr z, AccVoice_HandleEvent_D5
	cp a, 0xd5
	jr nz, AccVoice_EventLoop_Unknown

AccVoice_HandleEvent_D5:
	calr AccVoice_HandleNoteOnEvent
	jr AccVoice_EventProcessingReturn

AccVoice_EventLoop_Unknown:
	calr AccVoice_AdvanceAndCheckEnd

AccVoice_EventProcessingReturn:
	jr AccVoice_ProcessEventLoop

AccVoice_EventLoop_Idle:
	ret

AccVoice_DispatchByChannel:
	cp	(ACC_PART_BIT:16), 0x01
	jr nz, .Lc_f56445
	bit	0, (ACC_LANES_RESYNC:16)
	jr z, SoundPatch_NullRet
	calr AccKbd1_ProcessNotes
	jr t, SoundPatch_NullRet
AccVoice_DispatchCh_Kbd2:
.Lc_f56445:
	cp	(ACC_PART_BIT:16), 0x02
	jr nz, .Lc_f56457
	bit	1, (ACC_LANES_RESYNC:16)
	jr z, SoundPatch_NullRet
	calr AccKbd2_ProcessNotes
	jr t, SoundPatch_NullRet
AccVoice_DispatchCh_Acc1:
.Lc_f56457:
	cp	(ACC_PART_BIT:16), 0x04
	jr nz, .Lc_f5646a
	bit	2, (ACC_LANES_RESYNC:16)
	jr z, SoundPatch_NullRet
	call AccCh1_ProcessNotes
	jr t, SoundPatch_NullRet
AccVoice_DispatchCh_Acc2:
.Lc_f5646a:
	cp	(ACC_PART_BIT:16), 0x08
	jr nz, .Lc_f5647d
	bit	3, (ACC_LANES_RESYNC:16)
	jr z, SoundPatch_NullRet
	call AccCh2_ProcessNotes
	jr t, SoundPatch_NullRet
AccVoice_DispatchCh_Acc3:
.Lc_f5647d:
	cp	(ACC_PART_BIT:16), 0x10
	jr nz, .Lc_f56490
	bit	4, (ACC_LANES_RESYNC:16)
	jr z, SoundPatch_NullRet
	call AccCh3_ProcessNotes
	jr t, SoundPatch_NullRet
AccVoice_DispatchCh_Acc4:
.Lc_f56490:
	cp	(ACC_PART_BIT:16), 0x20
	jr nz, SoundPatch_NullRet
	bit	5, (ACC_LANES_RESYNC:16)
	jr z, SoundPatch_NullRet
	call AccCh4_ProcessNotes
	jr t, SoundPatch_NullRet
SoundPatch_NullRet:
	ret

AccVoice_AdvanceAndCheckEnd:
	calr AccBuf_AdvanceNoPage
	inc	1, (ACC_BAD_EVENT_COUNT:16)
	cp	(ACC_BAD_EVENT_COUNT:16), 0x20
	jr nz, AccVoice_AdvanceAndCheck_Return
	call AccWrap_PlayModeDispatch
	call Composer_ResetStyleImage
	ld	(ACC_PENDING_STYLE:16), 0xff
	or	(ACC_PART_FLAGS:16), 0x21
AccVoice_AdvanceAndCheck_Return:
	ret

AccVoice_HandleNoteOnEvent:
	calr AccVoice_AdvanceWithSave
	ld	w, (ACC_CUR_BEAT_POS:16)
	calr AccVoice_LookupTableAddress
	ld	bc, (0x31c5:16)
	ld	w, (ACC_CUR_BAR:16)
	calr AccTempo_PositionCompare
	cp A,0x18
	jr ule, AccVoice_NoteOn_InRange
	or	(ACC_PART_FLAGS:16), 0x01
	jr t, AccVoice_NoteOn_Return
AccVoice_NoteOn_InRange:
	calr AccMidi_Dispatch

AccVoice_NoteOn_Return:
	ret

AccVoice_HandleBarEndEvent:
	bit	1, (ACC_PART_FLAGS:16)
	jr z, .Lc_f564f8
	or	(ACC_PART_FLAGS:16), 0x01
	jrl t, AccVoice_NullRet
AccVoice_BarEnd_Process:
.Lc_f564f8:
	ld	w, (ACC_CUR_BEAT_POS:16)
	calr AccVoice_LookupExtParamAddr
	ld	bc, (0x31c5:16)
	ld	w, (ACC_CUR_BAR:16)
	calr AccTempo_PositionCompare
	cp A,0x18
	jr ule, .Lc_f56517
	or	(ACC_PART_FLAGS:16), 0x01
	jrl t, AccVoice_NullRet
AccVoice_BarEnd_InRange:
.Lc_f56517:
	or	(ACC_PART_FLAGS:16), 0x02
	ld	a, (ACC_CUR_BEAT_POS:16)
	inc 1,A
	ld W,A
	and A,0x0f
	cp	a, (ACC_BEATS_PER_BAR:16)
	jr	z, AccVoice_BarEnd_NextPage
	ld	(ACC_CUR_BEAT_POS:16), w
	calr	AccBuf_AdvanceNoPage
	jrl	AccVoice_NullRet
AccVoice_BarEnd_NextPage:
	and	w, 240
	add	w, 16
	ld	(ACC_CUR_BEAT_POS:16), w
	inc	1, (ACC_CUR_BAR:16)
	calr	AccBuf_AdvanceNoPage
	call	AccVoice_IncrementBarWithSave
	calr	AccPart_Reactivate
	and	(0x32a9:16), 251
	bit	0, (0x3254:16)
	jr	nz, AccVoice_BarEnd_CheckChord94
	ld	a, (ACC_PENDING_ENDING:16)
	and	a, 3
	jr	z, AccVoice_BarEnd_CheckChord65
AccVoice_BarEnd_CheckChord94:
	ld	a, (ACC_PART_BIT:16)
	and	a, (ACC_DEFER_ENDING_LANES:16)
	jr	nz, AccVoice_SetChordChangeFlags
AccVoice_BarEnd_CheckChord65:
	ld	a, (ACC_PENDING_FILLIN:16)
	and	a, 3
	jr	nz, AccVoice_BarEnd_CheckChord95
	ld	a, (ACC_PENDING_INTRO:16)
	and	a, 13
	jr	z, AccVoice_BarEnd_CheckSync69
AccVoice_BarEnd_CheckChord95:
	ld	a, (ACC_PART_BIT:16)
	and	a, (ACC_DEFER_SECTION_LANES:16)
	jr	nz, AccVoice_SetChordChangeFlags
AccVoice_BarEnd_CheckSync69:
	bit	0, (ACC_VARIATION_CHANGE_PENDING:16)
	jr	nz, AccVoice_SetChordChangeFlags
	ld	a, (0x32a4:16)
	and	a, 63
	jr	z, AccVoice_NullRet
	bit	7, (0x32a9:16)
	jr	nz, AccVoice_SetChordChangeFlags
	jr	AccVoice_NullRet
AccVoice_SetChordChangeFlags:
	or	(0x323b:16), 128
	or	(ACC_PART_FLAGS:16), 1
	ld	a, (ACC_LANES_FILLIN1:16)
	or	a, (ACC_LANES_FILLIN2:16)
	and	a, 63
	jr	z, AccVoice_NullRet
	bit	0, (ACC_STYLE_ARRANGER_ON:16)
	jr	z, AccVoice_NullRet
	and	(0x3256:16), 252
	or	(0x3256:16), 1
	ld	a, (ACC_PART_BIT:16)
	and	a, (ACC_LANES_FILLIN1:16)
	jr	z, AccVoice_NullRet
	or	(0x3256:16), 2
AccVoice_NullRet:
	ret

AccVoice_LookupTableAddress:
	ld xde, AccVoice_LookupTableAddress_Table
	and w, 0x7
	sla w, 1
	ld	de, (xde+w)
	xor w, w
	add de, wa
	ret

AccVoice_LookupExtParamAddr:
	ld xde, AccVoice_LookupTableAddress_Table
	and w, 0x7
	inc 1, w
	sla w, 1
	ld	de, (xde+w)
	ret

AccVoice_AdvanceWithSave:
	ld	iy, (ACC_CUR_READ_POS:16)
	ld	iz, (ACC_CUR_BLOCK:16)
	call	AccBuf_AdvanceWithPageTurn
	ret
AccBuf_AdvanceNoPage:
	ld	iy, (ACC_CUR_READ_POS:16)
	ld	iz, (ACC_CUR_BLOCK:16)
	call	AccBuf_Advance
	ld	(ACC_CUR_BLOCK:16), iz
	ld	(ACC_CUR_READ_POS:16), iy
	ret
AccVoice_HandleMarker83:
	ld	w, (ACC_PART_BIT:16)
	ld	a, (ACC_LANES_ENDING1:16)
	or	a, (ACC_LANES_ENDING2:16)
	and	w, a
	jr	nz, AccVoice_Marker83_Activate
	ld	a, (ACC_PART_BIT:16)
	and	a, (ACC_LANES_ENDED:16)
	jr	z, AccVoice_Marker83_CheckDeact
AccVoice_Marker83_Activate:
	calr AccVoice_ParkLaneAtEnd
	jr AccVoice_Marker83_Return

AccVoice_Marker83_CheckDeact:
	calr	AccPart_CheckAnyActive
	and	a, (ACC_PART_BIT:16)
	jr	z, AccVoice_Marker83_NextPart
	calr	AccPart_Deactivate
	jr	AccVoice_Marker83_Return
AccVoice_Marker83_NextPart:
	calr AccPart_AdvanceAndResolve

AccVoice_Marker83_Return:
	ret

AccVoice_ParkLaneAtEnd:
	ld	a, (ACC_PART_BIT:16)
	or	(ACC_LANES_PARKED:16), a
	or	(ACC_LANES_ENDED:16), a
	or	(ACC_PART_FLAGS:16), 0x01
	ld	a, (ACC_LANES_PARKED:16)
	and A,0x3f
	cp A,0x3f
	jr nz, AccVoice_ParkLaneAtEnd_Return
	or	(ACC_RUN_FLAGS:16), 0x04
	and	(ACC_LANES_PARKED:16), 0xc0
AccVoice_ParkLaneAtEnd_Return:
	ret

AccVoice_ActivateByteData:
	ld	a, (ACC_SECTION_BUTTONS_HELD:16)
	and	a, 192
	jr	nz, AccVoice_ActivatePart_Skip
	ld	a, (ACC_PART_BIT:16)
	and	a, (0x3271:16)
	jr	z, AccVoice_ActivatePart_Skip2
AccVoice_ActivatePart_Skip:
	calr	AccPart_ResolveWithPedal
	ld	a, (ACC_PART_BIT:16)
	xor	a, 255
	and	(0x3271:16), a
	jr	AccVoice_ActivatePart_Return2
AccVoice_ActivatePart_Skip2:
	ld	a, (ACC_LANES_INTRO1:16)
	or	a, (ACC_LANES_COUNTIN:16)
	or	a, (ACC_LANES_INTRO2:16)
	and	a, (ACC_PART_BIT:16)
	jr	nz, AccVoice_ActivatePart_Skip4
	bit	0, (ACC_STYLE_ARRANGER_ON:16)
	jr	z, AccVoice_ActivatePart_Skip4
	and	(0x3256:16), 252
	or	(0x3256:16), 1
	ld	a, (ACC_PART_BIT:16)
	and	a, (ACC_LANES_FILLIN1:16)
	jr	z, AccVoice_ActivatePart_Skip3
	or	(0x3256:16), 2
AccVoice_ActivatePart_Skip3:
	or	(0x323b:16), 128
	or	(ACC_PART_FLAGS:16), 1
	jr	AccVoice_ActivatePart_Join
AccVoice_ActivatePart_Skip4:
	calr	AccPart_SelectSourceOrParam
	calr	AccPart_ResolveStyleAddr
AccVoice_ActivatePart_Join:
	ld	a, (ACC_PART_BIT:16)
	xor	a, 255
	and	(ACC_LANES_FILLIN1:16), a
	and	(ACC_LANES_FILLIN2:16), a
	and	(ACC_LANES_INTRO1:16), a
	and	(ACC_LANES_COUNTIN:16), a
	and	(ACC_LANES_INTRO2:16), a
	ld	(ACC_CUR_BEAT_POS:16), 0
	ld	(ACC_CUR_MEASURE:16), 0
AccVoice_ActivatePart_Return2:
	ret
	or	(ACC_PART_FLAGS:16), 1
AccPart_SelectSourceOrParam:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, AccPart_SelectSource_Param
	calr AccPart_SelectSource
	jr t, AccPart_SelectSource_Done
AccPart_SelectSource_Param:
	calr AccPart_LoadParamOffsetTable

AccPart_SelectSource_Done:
	ld	w, (ACC_PART_BIT:16)
	ret
AccPart_AdvanceAndResolve:
	calr	AccPart_IncrementIndex
	ld	a, (ACC_PART_BIT:16)
	and	a, (12965:16)
	jr	z, AccPart_AdvanceResolve_Done
	call	AccVoice_InitPerChannel
	calr	AccPart_LoadParamOffsetTable
	ld	a, (ACC_PART_BIT:16)
	xor	a, 255
	and	(12965:16), a
	call	AccVoice_AssignPerPart
AccPart_AdvanceResolve_Done:
	calr AccPart_ResolveStyleAddr
	ret

AccPart_ResolveStyleAddr:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, AccPart_ResolveStyle_Bound
	ld	a, (ACC_STYLE_NUMBER:16)
	and A,0x7f
	call AccVoice_ResolveParamAddr
	calr AccPart_GetFreeVoiceAddr
	ld	(ACC_CUR_BLOCK:16), wa
	ldw	(ACC_CUR_READ_POS:16), 0x0006
	jr t, AccPart_ResolveStyle_Return
AccPart_ResolveStyle_Bound:
	ld	xiy, (ACC_STYLE_RECORD:16)
	ld	a, (ACC_CUR_SECTION:16)
	call	AccPart_LookupBoundVoiceParam
	calr	AccPart_GetParamAddr
	ld	(ACC_CUR_READ_POS:16), wa
AccPart_ResolveStyle_Return:
	ret

AccPart_IncrementIndex:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccPart_IncrementIndex_Return
	ld	xiy, (ACC_STYLE_RECORD:16)
	inc	1, (ACC_CUR_SECTION:16)
	xor	xhl, xhl
	ld	w, (ACC_CUR_SECTION:16)
	call	AccStyle_ReadParamOffset
	cp	w, 131
	jr	nz, AccPart_IncrementIndex_Return
	ld	a, (ACC_CUR_SECTION:16)
	call	AccTuning_FetchValue
	ld	(ACC_CUR_SECTION:16), a
AccPart_IncrementIndex_Return:
	ret

AccPart_ResolveWithPedal:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, AccPart_ResolveWithPedal_Bound
	bit	0, (0x32ab:16)
	jr nz, AccPart_ResolveWithPedal_DirB
	calr AccPedal_DirectionA
	ld	xiy, (0x321b:16)
	calr AccPart_GetParamAddr
	ld	(ACC_CUR_READ_POS:16), wa
	jr t, AccPart_ResolveWithPedal_Return
AccPart_ResolveWithPedal_DirB:
	ld	w, (ACC_PART_BIT:16)
	calr	AccPedal_DirectionB
	call	AccVoice_ResolveParamAddr
	calr	AccPart_GetFreeVoiceAddr
	ld	(ACC_CUR_BLOCK:16), wa
	ldw	(ACC_CUR_READ_POS:16), 6
	jr	AccPart_ResolveWithPedal_Return
AccPart_ResolveWithPedal_Bound:
	calr	AccPedal_DirectionA
	ld	xiy, (ACC_STYLE_RECORD:16)
	calr	AccPart_GetParamAddr
	ld	(ACC_CUR_READ_POS:16), wa
AccPart_ResolveWithPedal_Return:
	ret

AccPart_LoadParamOffsetTable:
	ld	xiy, (ACC_STYLE_RECORD:16)
	ld	a, (ACC_CUR_SECTION:16)
	ld	w, 0:opc
	call	AccPart_GetVoiceParamOffsetTable
	calr	AccPart_LoadTuningByChannel
	ret
AccPart_LoadTuningByChannel:
	cp	(ACC_PART_BIT:16), 0x01
	jr nz, .Lc_f56810
	call AccTuning_LoadAndApplyMaster
	or	(ACC_LANES_RESYNC:16), 0x01
	jr t, AccPart_NullRet
AccPart_LoadTuning_Kbd2:
.Lc_f56810:
	cp	(ACC_PART_BIT:16), 0x02
	jr nz, .Lc_f56822
	call AccTuning_LoadAndApplyMaster
	or	(ACC_LANES_RESYNC:16), 0x02
	jr t, AccPart_NullRet
AccPart_LoadTuning_Acc1:
.Lc_f56822:
	cp	(ACC_PART_BIT:16), 0x04
	jr nz, .Lc_f56834
	call AccTuning_LoadCoarseFromStyle
	or	(ACC_LANES_RESYNC:16), 0x04
	jr t, AccPart_NullRet
AccPart_LoadTuning_Acc2:
.Lc_f56834:
	cp	(ACC_PART_BIT:16), 0x08
	jr nz, .Lc_f56846
	call AccTuning_LoadFineFromStyle
	or	(ACC_LANES_RESYNC:16), 0x08
	jr t, AccPart_NullRet
AccPart_LoadTuning_Acc3:
.Lc_f56846:
	cp	(ACC_PART_BIT:16), 0x10
	jr nz, .Lc_f56858
	call AccTuning_LoadOctaveFromStyle
	or	(ACC_LANES_RESYNC:16), 0x10
	jr t, AccPart_NullRet
AccPart_LoadTuning_Acc4:
.Lc_f56858:
	cp	(ACC_PART_BIT:16), 0x20
	jr nz, AccPart_NullRet
	call AccTuning_LoadTransposeFromStyle
	or	(ACC_LANES_RESYNC:16), 0x20
AccPart_NullRet:
	ret

AccPart_GetFreeVoiceAddr:
	ld	a, (ACC_PART_BIT:16)
	xor A,0xff
	and	(0x3328:16), a
	cp	(ACC_PART_BIT:16), 0x01
	jr nz, .Lc_f56880
	ld16_src_rid8 xiy, 0x00, wa
	jr t, AccPart_CheckEndOfDataMarker
AccPart_FreeAddr_Kbd2:
.Lc_f56880:
	cp	(ACC_PART_BIT:16), 0x02
	jr nz, .Lc_f5688c
	ldw WA, 0xfffe
	jr t, AccPart_CheckEndOfDataMarker
AccPart_FreeAddr_Acc1:
.Lc_f5688c:
	cp	(ACC_PART_BIT:16), 0x04
	jr nz, .Lc_f56898
	ld WA,(XIY+0x04)
	jr t, AccPart_CheckEndOfDataMarker
AccPart_FreeAddr_Acc2:
.Lc_f56898:
	cp	(ACC_PART_BIT:16), 0x08
	jr nz, .Lc_f568a4
	ld WA,(XIY+0x06)
	jr t, AccPart_CheckEndOfDataMarker
AccPart_FreeAddr_Acc3:
.Lc_f568a4:
	cp	(ACC_PART_BIT:16), 0x10
	jr nz, .Lc_f568b0
	ld WA,(XIY+0x08)
	jr t, AccPart_CheckEndOfDataMarker
AccPart_FreeAddr_Acc4:
.Lc_f568b0:
	cp	(ACC_PART_BIT:16), 0x20
	jr nz, AccPart_CheckEndOfDataMarker
	ld WA,(XIY+0x0a)
AccPart_CheckEndOfDataMarker:
	cp	wa, 65534
	jr	nz, AccPart_FreeAddr_Return
	ld	a, (ACC_PART_BIT:16)
	or	(13096:16), a
	ldw	wa, 65534
AccPart_FreeAddr_Return:
	ret

; ============================================================================
; AccPart_GetParamAddr - Get parameter address for accompaniment part
; ============================================================================
; Input:  HL = base pointer, channel selector bitmask at 13268
; Output: WA = parameter address for the selected part
; Adds per-part offset (0x118-0x1d6) based on channel (kbd/acc1-5).
; ============================================================================
AccPart_GetParamAddr:
	ld	a, (ACC_PART_BIT:16)
	xor A,0xff
	and	(0x3328:16), a
	cp	(ACC_PART_BIT:16), 0x01
	jr nz, .Lc_f568e9
	add HL,0x0118
	ld	wa, (xiy+hl)
	jr t, AccPart_SubtractBaseAddr
AccPart_ParamAddr_Kbd2:
.Lc_f568e9:
	cp	(ACC_PART_BIT:16), 0x02
	jr nz, .Lc_f568fb
	add HL,0x013e
	ld	wa, (xiy+hl)
	jr t, AccPart_SubtractBaseAddr
AccPart_ParamAddr_Acc1:
.Lc_f568fb:
	cp	(ACC_PART_BIT:16), 0x04
	jr nz, .Lc_f5690d
	add HL,0x0164
	ld	wa, (xiy+hl)
	jr t, AccPart_SubtractBaseAddr
AccPart_ParamAddr_Acc2:
.Lc_f5690d:
	cp	(ACC_PART_BIT:16), 0x08
	jr nz, .Lc_f5691f
	add HL,0x018a
	ld	wa, (xiy+hl)
	jr t, AccPart_SubtractBaseAddr
AccPart_ParamAddr_Acc3:
.Lc_f5691f:
	cp	(ACC_PART_BIT:16), 0x10
	jr nz, .Lc_f56931
	add HL,0x01b0
	ld	wa, (xiy+hl)
	jr t, AccPart_SubtractBaseAddr
AccPart_ParamAddr_Acc4:
.Lc_f56931:
	cp	(ACC_PART_BIT:16), 0x20
	jr nz, AccPart_SubtractBaseAddr
	add HL,0x01d6
	ld	wa, (xiy+hl)
	jr t, AccPart_SubtractBaseAddr
AccPart_SubtractBaseAddr:
	sub wa, 0x8000
	add wa, 0x6
	ret

AccPart_SelectSource:
	ld	xiy, (ACC_STYLE_RECORD:16)
	cp	(ACC_PART_BIT:16), 0x01
	jr z, AccPart_SelectKbd
	cp	(ACC_PART_BIT:16), 0x02
	jr nz, AccPart_CheckAcc1
AccPart_SelectKbd:
	add	xiy, 24
	ld	xix, 12686
	jr	AccPart_CopyData
AccPart_CheckAcc1:
	cp	(ACC_PART_BIT:16), 4
	jr	nz, AccPart_CheckAcc2
	add	xiy, 32
	ld	xix, 12693
	jr	AccPart_CopyData
AccPart_CheckAcc2:
	cp	(ACC_PART_BIT:16), 8
	jr	nz, AccPart_CheckAcc3
	add	xiy, 40
	ld	xix, 12700
	jr	AccPart_CopyData
AccPart_CheckAcc3:
	cp	(ACC_PART_BIT:16), 16
	jr	nz, AccPart_CheckAcc4
	add	xiy, 48
	ld	xix, 12707
	jr	AccPart_CopyData
AccPart_CheckAcc4:
	cp	(ACC_PART_BIT:16), 32
	jr	nz, AccPart_CheckAcc4
	add	xiy, 56
	ld	xix, 12714
AccPart_CopyData:
	ld bc, 7:i3

	ldir85

	ld	a, (ACC_PART_BIT:16)

	or	(ACC_LANES_RESYNC:16), a

	ret



AccPart_CheckAnyActive:
	ld	a, (ACC_LANES_INTRO1:16)
	or	a, (ACC_LANES_COUNTIN:16)
	or	a, (ACC_LANES_INTRO2:16)
	or	a, (ACC_LANES_FILLIN1:16)
	or	a, (ACC_LANES_FILLIN2:16)
	ret
AccPedal_DirectionA:
	ld	a, (ACC_SECTION_BUTTONS_HELD:16)
	and A,0xc0
	jr z, .Lc_f569f0
	bit	7, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, .Lc_f569f6
	bit	6, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, .Lc_f569fd
AccPedal_DirA_CheckBit1:
.Lc_f569f0:
	bit	1, (ACC_REQ_FILLIN:16)
	jr nz, .Lc_f569fd
AccPedal_DirA_SetForward:
.Lc_f569f6:
	or	(ACC_PENDING_FILLIN:16), 0x01
	jr t, .Lc_f56a02
AccPedal_DirA_SetReverse:
.Lc_f569fd:
	or	(ACC_PENDING_FILLIN:16), 0x02
AccPedal_DirA_Apply:
.Lc_f56a02:
	ld	a, (ACC_CUR_SECTION:16)
	call AccVoice_ComputeParamAddr
	and	(ACC_PENDING_FILLIN:16), 0xfc

	ret



AccPedal_DirectionB:
	ld	a, (ACC_SECTION_BUTTONS_HELD:16)
	and A,0xc0
	jr z, .Lc_f56a25
	bit	7, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, .Lc_f56a48
	bit	6, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, .Lc_f56a2b
AccPedal_DirB_CheckBit0:
.Lc_f56a25:
	bit	0, (ACC_REQ_FILLIN:16)
	jr nz, .Lc_f56a48
AccPedal_DirB_InvertAndStore:
.Lc_f56a2b:
	ld A,W
	xor W,0xff
	and	(ACC_LANES_FILLIN1:16), w
	ld w, (ACC_BEATS_PER_BAR:16)
	cp	w, (0x32b2:16)
	jr nz, AccPedal_DirB_DefaultStyle
	or	(ACC_LANES_FILLIN2:16), a
	ld	a, (0x32b3:16)
	jr t, AccPedal_DirB_Return
AccPedal_DirB_Alternate:
.Lc_f56a48:
	ld A,W
	xor W,0xff
	and	(ACC_LANES_FILLIN2:16), w
	ld w, (ACC_BEATS_PER_BAR:16)
	cp	w, (0x32b0:16)
	jr nz, AccPedal_DirB_DefaultStyle
	or	(ACC_LANES_FILLIN1:16), a
	ld	a, (0x32b1:16)
	jr t, AccPedal_DirB_Return
AccPedal_DirB_DefaultStyle:
	ld	a, (ACC_STYLE_NUMBER:16)
	and	a, 127
AccPedal_DirB_Return:
	ret

AccMidi_Dispatch:
	calr AccMidi_NormalizeVelocity
	cp a, 0x90
	jr z, AccMidi_NoteEvent
	cp a, 0x91
	jr z, AccMidi_NoteEvent
	cp a, 0xd1
	jr z, AccMidi_ControlEvent
	cp a, 0xd2
	jr z, AccMidi_ControlEvent
	cp a, 0xd3
	jr z, AccMidi_ControlEvent
	cp a, 0xd4
	jr z, AccMidi_ControlEvent
	cp a, 0xd5
	jr z, AccMidi_ControlEvent

AccMidi_NoteEvent:
	calr AccMidi_ParseNoteOn
	calr AccMidi_SelectVelocitySource
	calr AccMidi_DispatchPerPart
	jr AccMidi_DispatchReturn

AccMidi_ControlEvent:
	call AccMidi_ParseDType
	calr AccMidi_SelectVelocitySource
	call AccMidi_DispatchDType

AccMidi_DispatchReturn:
	ret

AccMidi_NormalizeVelocity:
	cp a, 0:i3
	jr nz, AccMidi_VelNonZero
	ld a, 0x1:opc

AccMidi_VelNonZero:
	ld	e, a
	ld	(13082:16), a
	ld	a, (xhl+iy)
	ret
AccMidi_ParseNoteOn:
	calr AccMidi_ParseCommon
	cp	(ACC_EVENT:16), 0x91
	jr nz, AccMidi_ParseNoteOn_StorePos
	ld	a, (xhl+iy)
	ld	(ACC_EVENT_EXT1:16), a
	call AccBuf_Advance
	ld	a, (xhl+iy)
	ld	(ACC_EVENT_EXT2:16), a
	call AccBuf_Advance
AccMidi_ParseNoteOn_StorePos:
	ld	(ACC_CUR_READ_POS:16), iy
	ld	(ACC_CUR_BLOCK:16), iz
	ret
AccMidi_ParseCommon:
	ld	(ACC_EVENT:16), a
	call AccBuf_Advance
	ld	(0x3376:16), e
	call AccBuf_Advance
	ld	a, (xhl+iy)
	ld	(0x3377:16), a
	cp	(ACC_PART_BIT:16), 0x01
	jr z, .Lc_f56b14
	cp	(ACC_PART_BIT:16), 0x02
	jr z, .Lc_f56b14
	call Rhythm_CheckFixedNote
AccMidi_ParseCommon_ExtraFields:
.Lc_f56b14:
	call AccBuf_Advance
	ld	a, (xhl+iy)
	ld	(0x3378:16), a
	call AccBuf_Advance
	ld	a, (xhl+iy)
	ld	(0x3379:16), a
	call AccBuf_Advance
	ld	a, (xhl+iy)
	ld	(0x337a:16), a
	call AccBuf_Advance
	ret
AccMidi_SelectVelocitySource:
	ld	a, (ACC_PART_BIT:16)
	ld	w, (12935:16)
	and	a, (ACC_LANES_INTRO1:16)
	jr	nz, AccMidi_VelSource_Active
	and	a, (ACC_LANES_COUNTIN:16)
	jr	nz, AccMidi_VelSource_Active
	and	a, (ACC_LANES_INTRO2:16)
	jr	nz, AccMidi_VelSource_Active
	and	a, (ACC_LANES_ENDING1:16)
	jr	nz, AccMidi_VelSource_Active
	and	a, (ACC_LANES_ENDING2:16)
	jr	z, AccMidi_VelSource_Store
AccMidi_VelSource_Active:
	ld	w, (12936:16)
AccMidi_VelSource_Store:
	ld	(13094:16), w
	ret
AccMidi_DispatchPerPart:
	cp	(ACC_PART_BIT:16), 0x01
	jr nz, .Lc_f56b7b
	calr AccKbd1_RingBufEntry
	jr t, AccMidi_DispatchAcc4Return
AccMidi_DispatchKbd2:
.Lc_f56b7b:
	cp	(ACC_PART_BIT:16), 0x02
	jr nz, .Lc_f56b87
	calr AccKbd2_RingBufEntry
	jr t, AccMidi_DispatchAcc4Return
AccMidi_DispatchAcc1:
.Lc_f56b87:
	cp	(ACC_PART_BIT:16), 0x04
	jr nz, .Lc_f56b94
	call AccCh1_NoteOnEntry
	jr t, AccMidi_DispatchAcc4Return
AccMidi_DispatchAcc2:
.Lc_f56b94:
	cp	(ACC_PART_BIT:16), 0x08
	jr nz, .Lc_f56ba1
	call AccCh2_NoteOnEntry
	jr t, AccMidi_DispatchAcc4Return
AccMidi_DispatchAcc3:
.Lc_f56ba1:
	cp	(ACC_PART_BIT:16), 0x10
	jr nz, .Lc_f56bae
	call AccCh3_NoteOnEntry
	jr t, AccMidi_DispatchAcc4Return
AccMidi_DispatchAcc4:
.Lc_f56bae:
	cp	(ACC_PART_BIT:16), 0x20
	jr nz, AccMidi_DispatchAcc4Return
	call AccCh4_NoteOnEntry
AccMidi_DispatchAcc4Return:
	ret

AccKbd1_RingBufEntry:
	calr AccKbd1_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccKbd1_RingBufReturn
	ld	XHL,0x000029dc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_WriteNoteEvent
AccKbd1_RingBufReturn:
	ret

AccKbd1_CheckEligible:
	and	(0x3329:16), 0xfe
	bit	0, (0x3326:16)
	jr z, AccKbd1_CheckReturn
	bit	0, (0x32aa:16)
	jr nz, AccKbd1_CheckReturn
	bit	0, (0x324f:16)
	jr z, AccKbd1_CheckReturn
	bit	4, (CMP_RECORD_PART:16)
	jr z, .Lc_f56c14
	bit	2, (0x3417:16)
	jr nz, AccKbd1_CheckReturn
	bit	7, (0x34a0:16)
	jr z, .Lc_f56c14
	ld	a, (0x34a0:16)
	and A,0x7f
	cp	a, (0x3377:16)
	jr z, AccKbd1_CheckReturn
	cp A,0x30
	jr nz, .Lc_f56c14
	cp	(0x3377:16), 0x5d
	jr z, AccKbd1_CheckReturn
AccKbd1_CheckRecording:
.Lc_f56c14:
	bit	1, (0x327d:16)
	jr nz, AccKbd1_CheckReturn
	bit	0, (0x33c2:16)
	jr nz, AccKbd1_CheckReturn
	bit	0, (0x3330:16)
	jr nz, AccKbd1_CheckReturn
	ld	XHL,0x000029dc
	calr AccBuf_ComputeFillLevel
	cpw	(0x326c:16), 0x0010
	jr ule, AccKbd1_CheckReturn
	or	(0x3329:16), 0x01
AccKbd1_CheckReturn:
	ret

AccBuf_WriteNoteEvent:
	ld	a, (ACC_EVENT:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	call RhythmAccent_UpdateRingBufPosition
	ld	a, (0x3377:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld	a, (0x3378:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld	a, (0x3379:16)
	cp a, 0:i3
	jr nz, AccBuf_WriteNote_VelNonZero
	ld A, 0x01:opc
AccBuf_WriteNote_VelNonZero:
	ld	(xhl+iy), a

	; call RingBuf_AdvanceIndex (v7 addr)
	call	RingBuf_AdvanceIndex
	; ldb_d8 a, (0x3432) (v7 patched)
	ld	a, (0x337a:16)
	ld	(xhl+iy), a

	; call RingBuf_AdvanceIndex (v7 addr)
	call	RingBuf_AdvanceIndex
	ld (xhl + 4), iy

	ret



AccBuf_ComputeFillLevel:
	ld wa, (xhl + 6)
	cp wa, (xhl + 4)
	jr c, AccBuf_FillLevel_Wrapped
	jr ugt, AccBuf_FillLevel_Simple
	ld wa, (xhl + 2)
	sub wa, (xhl + 0:8)
	inc 1, wa
	jr AccBuf_FillLevel_Store

AccBuf_FillLevel_Wrapped:
	ld wa, (xhl + 2)
	sub wa, (xhl + 0:8)
	inc 1, wa
	sub wa, (xhl + 4)
	add wa, (xhl + 6)
	jr AccBuf_FillLevel_Store

AccBuf_FillLevel_Simple:
	sub wa, (xhl + 4)

AccBuf_FillLevel_Store:
	ld	(12908:16), wa
	ret
AccTempo_PositionCompare:
	cp	w, (0x31fc:16)
	jr nz, AccTempo_DiffBar
	cp BC,DE
	jr c, AccTempo_SameBar
	ld A, 0x00:opc
	jr t, AccTempo_Return
AccTempo_SameBar:
	sub de, bc
	ld a, e
	cp d, 0:i3
	jr z, AccTempo_Return
	ld a, 0x60:opc
	jr AccTempo_Return

AccTempo_DiffBar:
	cp	w, (0x31fc:16)
	jr	c, AccTempo_BarZero
	cp	w, 255
	jr	nz, AccTempo_ComputeDelta
	cp	(0x31fc:16), 0
	jr	z, AccTempo_TooFar
	jr	AccTempo_ComputeDelta
AccTempo_BarZero:
	cp	w, 0:i3
	jr	nz, AccTempo_TooFar
	cp	(0x31fc:16), 255
	jr	z, AccTempo_ComputeDelta
AccTempo_TooFar:
	ld a, 0x0:opc
	jr AccTempo_Return

AccTempo_ComputeDelta:
	xor xwa, xwa
	ld a, (1112:16)
	sla a, 1
	add xwa, AccVoice_LookupTableAddress_Table
	add de, (xwa)
	sub de, bc
	ld a, e
	cp d, 0:i3
	jr z, AccTempo_Return
	ld a, 0x60:opc

AccTempo_Return:
	ret

AccKbd1_ProcessNotes:
	calr AccKbd1_TimingCheck
	bit	0, (ACC_PART_FLAGS:16)
	jr nz, AccKbd1_ProcessReturn
	calr AccKbd1_ScanSlots
	calr AccKbd1_DrainRingBuf
	ld	XIY,0x0000315c
	ld	XIX,0x00003175
	ld bc, 5:i3
	ldir85
	ld	a, (0x3384:16)
	ld	(0x3234:16), a
	call RhythmPart1_ProcessAccentData
	and	(ACC_LANES_RESYNC:16), 0xfe
AccKbd1_ProcessReturn:
	ret

AccKbd1_TimingCheck:
	ld A, 0x00:opc
	ld	w, (ACC_CUR_BEAT_POS:16)
	calr AccVoice_LookupTableAddress
	ld	bc, (0x31c5:16)
	ld	w, (ACC_CUR_BAR:16)
	calr AccTempo_PositionCompare
	cp A,0x18
	jr ule, AccKbd1_TimingOK
	or	(ACC_PART_FLAGS:16), 0x01
	jr t, AccKbd1_TimingReturn
AccKbd1_TimingOK:
	ld	(13188:16), a
	ld	a, 95:opc
	ld	w, (1112:16)
	dec	1, w
	calr	AccVoice_LookupTableAddress
	ld	bc, (12741:16)
	ld	w, (ACC_CUR_BAR:16)
	dec	1, w
	calr	AccTempo_PositionCompare
	ld	(13187:16), a
AccKbd1_TimingReturn:
	ret

AccKbd1_ScanSlots:
	ld	xhl, ACC_DRUM1_NOTES
AccKbd1_ScanSlots_Loop:
	calr	AccSlot_CheckAndUpdate
	add	xhl, 6
	cp	xhl, 12300
	jr	c, AccKbd1_ScanSlots_Loop
	ret
AccSlot_CheckAndUpdate:
	bit 7,(XHL)
	jr z, AccSlot_Return
	ld DE,(XHL+0x04)
	ld	a, (0x3383:16)
	xor W,W
	ei 0x06
	add	wa, (0x460:16)
	sub	a, (0x464:16)
	jr	pl, AccSlot_CompareAndUpdate
	cp	w, 0:i3
	jr	z, AccSlot_TimingZero
	dec	1, w
	add	a, 96
	jr	AccSlot_CompareAndUpdate
AccSlot_TimingZero:
	xor wa, wa

AccSlot_CompareAndUpdate:
	cp	de, wa
	jr	ule, AccSlot_RestoreInterrupts	; -> 0xF56DCE
	ld	(xhl+4), wa
	cp	(ACC_NEXT_NOTE_OFF:16), wa
	jr	ule, AccSlot_RestoreInterrupts	; -> 0xF56DCE
	ld	(ACC_NEXT_NOTE_OFF:16), wa
AccSlot_RestoreInterrupts:
	ei 0

AccSlot_Return:
	ret

AccKbd1_DrainRingBuf:
	ld	xhl, 10716
	ld	iy, (xhl+6)
	ld	bc, (xhl+2)
AccKbd1_DrainLoop:
	cp (xhl + 4), iy
	jr z, AccKbd1_DrainDone
	ld	a, (xhl+iy)
	cp a, 0x90
	jr nz, AccKbd1_DrainSkip
	calr AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	jr AccKbd1_DrainLoop

AccKbd1_DrainSkip:
	call RingBuf_AdvanceIndex
	jr AccKbd1_DrainLoop

AccKbd1_DrainDone:
	ret

AccBuf_ProcessNoteEvent:
	call RingBuf_AdvanceIndex
	ld	w, (xhl+iy)
	call Rhythm_AdvancePosition
	ld	e, (xhl+iy)
	pushw iy
	inc 1, iy
	cp iy, bc
	jr ule, AccBuf_NoteEvent_WrapPos
	ld iy, (xhl + 0:8)

AccBuf_NoteEvent_WrapPos:
	ld	d, (xhl+iy)
	popw	iy
	ld	a, (13187:16)
	ei	0x06
	add	a, (1122:16)
	add	w, (1124:16)
	sub	a, w
	jr	pl, AccBuf_NoteEvent_StoreTiming
	ld	a, 0:opc
AccBuf_NoteEvent_StoreTiming:
	xor w, w
	cp de, wa
	jr ule, AccBuf_NoteEvent_SkipTiming
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld	(xhl+iy), w
	jr AccBuf_NoteEvent_Return

AccBuf_NoteEvent_SkipTiming:
	call RingBuf_AdvanceIndex

AccBuf_NoteEvent_Return:
	ei 0
	ret

AccKbd2_CheckActive:
	ld	a, (ACC_PART_BIT:16)
	and	a, (13096:16)
	jr	z, AccBuf_ProcessNoteEvent_Return
	ld	a, (ACC_PART_BIT:16)
	ld	w, (ACC_LANES_ENDING1:16)
	or	w, (ACC_LANES_ENDING2:16)
	and	w, a
	jr	z, AccBuf_ProcessNoteEvent_Skip
	or	(ACC_LANES_PARKED:16), a
	or	(ACC_LANES_ENDED:16), a
	jr	AccBuf_ProcessNoteEvent_Return
AccBuf_ProcessNoteEvent_Skip:
	ld	a, (ACC_PART_BIT:16)
	xor	a, 255
	and	(ACC_LANES_FILLIN1:16), a
	and	(ACC_LANES_FILLIN2:16), a
	and	(ACC_LANES_INTRO1:16), a
	and	(ACC_LANES_COUNTIN:16), a
	and	(ACC_LANES_INTRO2:16), a
	and	(12965:16), a
	and	(12913:16), a
	ld	(ACC_CUR_MEASURE:16), 0
	ld	(ACC_CUR_BLOCK:16), 254
	ld	(ACC_CUR_READ_POS:16), 6
AccBuf_ProcessNoteEvent_Return:
	ret
AccKbd2_ProcessEntry:
	calr AccKbd2_SaveState
	calr AccVoice_ProcessEventLoop
	calr AccKbd2_RestoreState

AccKbd2_SaveState:
	and	(ACC_PART_FLAGS:16), 0xfc
	ld	(ACC_BAD_EVENT_COUNT:16), 0x00
	ld A, 0x02:opc
	ld	(ACC_PART_BIT:16), a
	ld	wa, (0x31e1:16)
	ld	(ACC_CUR_BLOCK:16), wa
	ld	wa, (0x31d1:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x31fe:16)
	ld	(ACC_CUR_BAR:16), a
	ld	a, (0x31f4:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	a, (0x31ec:16)
	ld	(ACC_CUR_SECTION:16), a
	ld	a, (0x3334:16)
	ld	(ACC_CUR_MEASURE:16), a
	ret
AccKbd2_RestoreState:
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(12769:16), wa
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(12753:16), wa
	ld	a, (ACC_CUR_BAR:16)
	ld	(12798:16), a
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(12788:16), a
	ld	a, (ACC_CUR_SECTION:16)
	ld	(12780:16), a
	ld	a, (ACC_CUR_MEASURE:16)
	ld	(13108:16), a
	ret
AccKbd2_RingBufEntry:
	calr AccKbd2_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccKbd2_RingBufReturn
	ld	XHL,0x00002adc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_WriteNoteEvent
AccKbd2_RingBufReturn:
	ret

AccKbd2_CheckEligible:
	and	(0x3329:16), 0xfe
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccKbd2_CheckReturn
	bit	1, (0x3326:16)
	jr z, AccKbd2_CheckReturn
	bit	0, (0x324f:16)
	jr z, AccKbd2_CheckReturn
	bit	1, (0x327d:16)
	jr nz, AccKbd2_CheckReturn
	bit	0, (0x33c2:16)
	jr nz, AccKbd2_CheckReturn
	bit	0, (0x3330:16)
	jr nz, AccKbd2_CheckReturn
	ld	XHL,0x00002adc
	calr AccBuf_ComputeFillLevel
	cpw	(0x326c:16), 0x0010
	jr ule, AccKbd2_CheckReturn
	or	(0x3329:16), 0x01
AccKbd2_CheckReturn:
	ret

AccKbd2_ProcessNotes:
	calr AccKbd1_TimingCheck
	bit	0, (ACC_PART_FLAGS:16)
	jr nz, AccKbd2_ProcessReturn
	calr AccKbd2_ScanSlots
	calr AccKbd2_DrainRingBuf
	and	(ACC_LANES_RESYNC:16), 0xfd
AccKbd2_ProcessReturn:
	ret

AccKbd2_ScanSlots:
	ld	xhl, ACC_DRUM2_NOTES
AccKbd2_ScanSlots_Loop:
	calr	AccSlot_CheckAndUpdate
	add	xhl, 6
	cp	xhl, 12348
	jr	c, AccKbd2_ScanSlots_Loop
	ret
AccKbd2_DrainRingBuf:
	ld	xhl, 10972
	ld	iy, (xhl+6)
	ld	bc, (xhl+2)
AccKbd2_DrainLoop:
	cp (xhl + 4), iy
	jr z, AccKbd2_DrainDone
	ld	a, (xhl+iy)
	cp a, 0x90
	jr nz, AccKbd2_DrainSkip
	calr AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	jr AccKbd2_DrainLoop

AccKbd2_DrainSkip:
	call RingBuf_AdvanceIndex
	jr AccKbd2_DrainLoop

AccKbd2_DrainDone:
	ret

AccSeq_ScanPattern:
	; anddi8 (0x32f4), 252 (v7 patched)
	and	(ACC_PART_FLAGS:16), 252
AccSeq_ScanLoop:
	bit	0, (ACC_PART_FLAGS:16)
	jrl nz, AccSeq_ScanDone
	ld	xhl, (0x31db:16)
	ld A,(XHL)
	cp A,0x83
	jr nz, AccSeq_CheckMarker81
	calr AccSeq_ResetToStart
AccSeq_CheckMarker81:
	cp a, 0x81
	jr z, AccSeq_EndOfBar
	cp a, 0x90
	jr z, AccSeq_NoteOn90
	calr AccSeq_AdvancePointer
	jr AccSeq_ScanLoop

AccSeq_NoteOn90:
	calr	AccSeq_ReadNextByte
	ld	w, (12793:16)
	calr	AccVoice_LookupTableAddress
	ld	bc, (12741:16)
	ld	w, (12803:16)
	calr	AccTempo_PositionCompare
	cp	a, 24
	jr	ugt, AccSeq_NoteOn_TooFar
	calr	AccSeq_ParseNoteEvent
	jr	AccSeq_NoteOn_Continue
AccSeq_NoteOn_TooFar:
	; ordi8 0x32f4, 1 (v7 patched)
	or	(ACC_PART_FLAGS:16), 1
AccSeq_NoteOn_Continue:
	jr AccSeq_ScanLoop

AccSeq_EndOfBar:
	bit	1, (ACC_PART_FLAGS:16)
	jr	z, AccSeq_EndOfBar_Process
	or	(ACC_PART_FLAGS:16), 1
	jr	AccSeq_ScanLoop
AccSeq_EndOfBar_Process:
	ld	w, (0x31f9:16)
	calr	AccVoice_LookupExtParamAddr
	ld	bc, (0x31c5:16)
	ld	w, (0x3203:16)
	calr	AccTempo_PositionCompare
	cp	a, 24
	jr	ugt, AccSeq_EndOfBar_TooFar
	or	(ACC_PART_FLAGS:16), 2
	ld	a, (0x31f9:16)
	inc	1, a
	ld	w, a
	and	a, 15
	cp	a, (ACC_BEATS_PER_BAR:16)
	jr	z, AccSeq_NextBarPage
	ld	(0x31f9:16), w
	calr	AccSeq_AdvancePointer
	jrl	AccSeq_ScanLoop
AccSeq_NextBarPage:
	and	w, 240
	add	w, 16
	ld	(12793:16), w
	inc	1, (12803:16)
	ld	xhl, AccStyle_DefaultStream
	add	xhl, 6
	ld	(12763:16), xhl
	jrl	AccSeq_ScanLoop
AccSeq_EndOfBar_TooFar:
	; ordi8 0x32f4, 1 (v7 patched)
	or	(ACC_PART_FLAGS:16), 1
	; jrl AccSeq_ScanLoop (v7 displacement)
	jrl	AccSeq_ScanLoop
AccSeq_ScanDone:
	ret

AccSeq_ReadNextByte:
	ld	xhl, (12763:16)
	inc	1, xhl
	ld	a, (xhl)
	ret
AccSeq_AdvancePointer:
	ld	xhl, (12763:16)
	inc	1, xhl
	ld	(12763:16), xhl
	ret
AccSeq_ResetToStart:
	ld	xhl, AccStyle_DefaultStream
	add	xhl, 6
	ld	(12763:16), xhl
	ld	a, (xhl)
	ret
AccSeq_ParseNoteEvent:
	cp a, 0:i3
	jr nz, AccSeq_ParseNote_VelNonZero
	ld a, 0x1:opc

AccSeq_ParseNote_VelNonZero:
	ld	e, a
	ld	xhl, (0x31db:16)
	ld	a, (xhl)
	ld	(ACC_EVENT:16), a
	calr	AccSeq_AdvancePointer
	ld	(0x3376:16), e
	calr	AccSeq_AdvancePointer
	ld	a, (xhl)
	ld	(0x3377:16), a
	calr	AccSeq_AdvancePointer
	ld	a, (xhl)
	ld	(0x3378:16), a
	calr	AccSeq_AdvancePointer
	ld	a, 1:opc
	ld	(0x3379:16), a
	calr	AccSeq_AdvancePointer
	ld	a, 0:opc
	ld	(0x337a:16), a
	calr	AccSeq_AdvancePointer
	ld	a, (CMP_RECORD_PART:16)
	and	a, 63
	jr	z, AccSeq_ParseNote_CheckMode
	cp	(CURRENT_TITLE:16), 181
	jr	z, AccSeq_ParseNote_WriteToKbd2
	jr	AccSeq_ParseNote_Return
AccSeq_ParseNote_CheckMode:
	ld	a, (0x327d:16)
	cp	a, 3:i3
	jr	nz, AccSeq_ParseNote_CheckRec
	bit	0, (0x33c2:16)
	jr	z, AccSeq_ParseNote_WriteToKbd2
AccSeq_ParseNote_CheckRec:
	bit	0, (0x3330:16)
	jr	z, AccSeq_ParseNote_Return
AccSeq_ParseNote_WriteToKbd2:
	ld	xhl, 10972
	ld	iy, (xhl+4)
	ld	bc, (xhl+2)
	calr	AccBuf_WriteNoteEvent
AccSeq_ParseNote_Return:
	ret

AccCh1_ProcessEntry:
	calr AccCh1_SaveState
	call AccVoice_ProcessEventLoop
	calr AccCh1_RestoreState
	ret

AccCh1_SaveState:
	and	(ACC_PART_FLAGS:16), 0xfc
	ld	(ACC_BAD_EVENT_COUNT:16), 0x00
	ld A, 0x04:opc
	ld	(ACC_PART_BIT:16), a
	ld	wa, (0x31e3:16)
	ld	(ACC_CUR_BLOCK:16), wa
	ld	wa, (0x31d3:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x31ff:16)
	ld	(ACC_CUR_BAR:16), a
	ld	a, (0x31f5:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	a, (0x31ed:16)
	ld	(ACC_CUR_SECTION:16), a
	ld	a, (0x3335:16)
	ld	(ACC_CUR_MEASURE:16), a
	ret
AccCh1_RestoreState:
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(12771:16), wa
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(12755:16), wa
	ld	a, (ACC_CUR_BAR:16)
	ld	(12799:16), a
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(12789:16), a
	ld	a, (ACC_CUR_SECTION:16)
	ld	(12781:16), a
	ld	a, (ACC_CUR_MEASURE:16)
	ld	(13109:16), a
	ret
AccVoice_AssignPerPart:
	cp	(ACC_PART_BIT:16), 0x01
	jr z, AccVoice_AssignReturn
	cp	(ACC_PART_BIT:16), 0x02
	jr z, AccVoice_AssignReturn
	ld	a, (ACC_CUR_SECTION:16)
	call AccTuning_FetchValue
	ld	(0x3291:16), a
	calr AccVoice_ScanInstruments
	calr AccVoice_SendProgChange
AccVoice_AssignReturn:
	ret

AccVoice_ScanInstruments:
	ld	e, (12945:16)
	ld	(ACC_CUR_CC3:16), 0
AccVoice_ScanLoop:
	cp	e, (ACC_CUR_SECTION:16)
	jr	z, AccVoice_ScanDone	; -> 0xF571F2
	ld	xiy, (ACC_STYLE_RECORD:16)
	ld	a, e
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	iy, wa
	ld	a, (ACC_STYLE_BANK:16)
	call	AccVoice_TableLookup
	call	AccVoice_ScanForD3
	inc	1, e
	jr	AccVoice_ScanLoop	; -> 0xF571CC
AccVoice_ScanDone:
	ret

AccVoice_SendProgChange:
	cp	(ACC_PART_BIT:16), 0x04
	jr nz, .Lc_f5720c
	ld A, 0xd7:opc
	ld W, 0x03:opc
	ld	e, (ACC_CUR_CC3:16)
	ld	(ACC_CH_CC3:16), e
	call Rhythm_Send3ByteMsg
	jr t, AccCh_ReturnStub
AccVoice_SendD4:
.Lc_f5720c:
	cp	(ACC_PART_BIT:16), 0x08
	jr nz, .Lc_f57225
	ld A, 0xd4:opc
	ld W, 0x03:opc
	ld	e, (ACC_CUR_CC3:16)
	ld	(0x3278:16), e
	call Rhythm_Send3ByteMsg
	jr t, AccCh_ReturnStub
AccVoice_SendD5:
.Lc_f57225:
	cp	(ACC_PART_BIT:16), 0x10
	jr nz, AccVoice_SendD6
	ld A, 0xd5:opc
	ld W, 0x03:opc
	ld	e, (ACC_CUR_CC3:16)
	ld	(0x3279:16), e
	call Rhythm_Send3ByteMsg
	jr t, AccCh_ReturnStub
AccVoice_SendD6:
	ld	a, 214:opc
	ld	w, 3:opc
	ld	e, (ACC_CUR_CC3:16)
	ld	(12922:16), e
	call	Rhythm_Send3ByteMsg
	jr	AccCh_ReturnStub
AccCh_ReturnStub:
	ret

AccBuf_Write3ByteEvent:
	ld	a, (ACC_EVENT:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	call RhythmAccent_UpdateRingBufPosition
	ld	a, (0x3377:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld	a, (0x3378:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld (XHL+0x04),IY
	ret
AccCh1_Padding:
	nop
	nop

AccCh1_NoteOnEntry:
	calr AccCh1_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccCh1_NoteOnReturn
	ld	a, (ACC_CH_TURNOVER:16)
	ld	(ACC_CUR_TURNOVER:16), a
	ld	a, (ACC_CH_CEILING:16)
	ld	(ACC_CUR_CEILING:16), a
	and	(ACC_PART_FLAGS:16), 0xfb
	or	(ACC_PART_FLAGS:16), 0x08
	ld	XHL,0x00002bdc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_WriteExtendedEvent
AccCh1_NoteOnReturn:
	ret

AccCh1_CheckEligible:
	and	(0x3329:16), 0xfe
	bit	2, (0x32aa:16)
	jr nz, AccCh1_CheckReturn
	bit	1, (0x324f:16)
	jr z, AccCh1_CheckReturn
	bit	3, (0xc4e0:16)
	jr z, AccCh1_CheckReturn
	calr AccCh_CheckOverlap
	cp a, 0:i3
	jr nz, AccCh1_CheckReturn
	bit	1, (0x327d:16)
	jr nz, AccCh1_CheckReturn
	bit	0, (0x33c2:16)
	jr nz, AccCh1_CheckReturn
	bit	0, (0x3330:16)
	jr nz, AccCh1_CheckReturn
	ld	XHL,0x00002bdc
	call AccBuf_ComputeFillLevel
	cpw	(0x326c:16), 0x0010
	jr ugt, .Lc_f572fa
	calr AccBuf_InitWithDefaults
	jr t, AccCh1_CheckReturn
AccCh1_SetReady:
.Lc_f572fa:
	or	(0x3329:16), 0x01



AccCh1_CheckReturn:
	ret

AccBuf_WriteExtendedEvent:
	ld	a, (ACC_EVENT_EXT1:16)
	ld	(0x327e:16), a
	ld	a, (ACC_EVENT_EXT2:16)
	ld	(0x327f:16), a
	ld	a, (ACC_EVENT:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	call RhythmAccent_UpdateRingBufPosition
	ld	a, (0x3377:16)
	ld	(ACC_EVENT_PATTERN_NOTE:16), a
	calr AccVoice_CheckStyle
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld	a, (0x3378:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld	a, (0x3379:16)
	cp a, 0:i3
	jr nz, .Lc_f5734c
	ld A, 0x01:opc
AccBuf_ExtEvt_VelNonZero:
.Lc_f5734c:
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld	a, (0x337a:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	calr AccBuf_ExtEvt_WriteExtra
	ld	a, (ACC_EVENT_PATTERN_NOTE:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld (XHL+0x04),IY
	ret
AccBuf_ExtEvt_WriteExtra:
	cp	(ACC_EVENT:16), 0x90
	jr z, AccBuf_ExtEvt_ExtraReturn
	ld	a, (0x327e:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld	a, (0x327f:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
AccBuf_ExtEvt_ExtraReturn:
	ret

AccVoice_CheckStyle:
	.byte	0xc1, 0x2d, 0x32, 0x3f, 0xf0, 0x67, 0x00
AccVoice_CallCorrection:
	call AccVoice_ConvertNoteForChord
	ret

AccVoice_CorrectionData:
	push	xhl
	pushw	iy
	ld	a, (0x3377:16)
	bit	4, (ACC_PART_FLAGS:16)
	jr	nz, AccVoice_CorrectionData_Skip2
	bit	3, (ACC_PART_FLAGS:16)
	jr	z, AccVoice_CorrectionData_Skip
	call	Rhythm_BassToRoot
AccVoice_CorrectionData_Skip:
	call	Rhythm_RootOnlyNote
AccVoice_CorrectionData_Skip2:
	call	Rhythm_ChordConvertNoteFast
	popw	iy
	pop	xhl
	ret
AccVoice_ConvertNoteForChord:
	push	xhl
	pushw	iy
	ld	a, (0x3377:16)
	bit	4, (ACC_PART_FLAGS:16)
	jr	nz, AccVoice_VelocityLookup
	bit	3, (ACC_PART_FLAGS:16)
	jr	z, AccVoice_NoteRangeCheck
	call	Rhythm_BassToRoot
AccVoice_NoteRangeCheck:
	call Rhythm_RootOnlyNote

AccVoice_VelocityLookup:
	cp	(ACC_EVENT:16), 145
	jr	z, AccVoice_UseVoiceMap
	call	Rhythm_ChordConvertNote90
	jr	AccVoice_CorrectReturn
AccVoice_UseVoiceMap:
	call Rhythm_ChordConvertNote91

AccVoice_CorrectReturn:
	popw iy
	pop xhl
	ret

AccMidi_ParseDType:
	ld D,A
	and A,0xf0
	ld	(ACC_EVENT:16), a
	call AccBuf_Advance
	ld	(0x3376:16), e
	call AccBuf_Advance
	ld A,D
	and A,0x0f
	ld	(0x3377:16), a
	ld	a, (xhl+iy)
	ld	(13176:16), a
	call	AccBuf_Advance
	ld	(ACC_CUR_READ_POS:16), iy
	ld	(ACC_CUR_BLOCK:16), iz
	ret
AccMidi_DispatchDType:
	cp	(ACC_PART_BIT:16), 0x01
	jr nz, .Lc_f57430
	jr t, AccMidi_DType_Return
AccMidi_DType_CheckKbd2:
.Lc_f57430:
	cp	(ACC_PART_BIT:16), 0x02
	jr nz, .Lc_f57439
	jr t, AccMidi_DType_Return
AccMidi_DType_CheckAcc1:
.Lc_f57439:
	cp	(ACC_PART_BIT:16), 0x04
	jr nz, .Lc_f57445
	calr AccCh1_DTypeEntry
	jr t, AccMidi_DType_Return
AccMidi_DType_CheckAcc2:
.Lc_f57445:
	cp	(ACC_PART_BIT:16), 0x08
	jr nz, .Lc_f57451
	calr AccCh2_DTypeEntry
	jr t, AccMidi_DType_Return
AccMidi_DType_CheckAcc3:
.Lc_f57451:
	cp	(ACC_PART_BIT:16), 0x10
	jr nz, .Lc_f5745d
	calr AccCh3_DTypeEntry
	jr t, AccMidi_DType_Return
AccMidi_DType_CheckAcc4:
.Lc_f5745d:
	cp	(ACC_PART_BIT:16), 0x20
	jr nz, .Lc_f5745d
	calr AccCh4_DTypeEntry
AccMidi_DType_Return:
	ret

AccCh1_DTypeEntry:
	calr AccCh1_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccCh1_DTypeReturn
	ld	XHL,0x00002bdc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_Write3ByteEvent
AccCh1_DTypeReturn:
	ret

AccCh_CheckOverlap:
	ld A, 0x00:opc
	bit	2, (0x3417:16)
	jr z, AccCh_OverlapReturn
	bit	3, (CMP_RECORD_PART:16)
	jr z, AccCh_OverlapReturn
	ld A, 0x01:opc
AccCh_OverlapReturn:
	ret

AccBuf_InitWithDefaults:
	ldw (xhl+0:8), 0x000a
	ldw (XHL+0x02), 0x00ff
	ldw (XHL+0x04), 0x000a
	ldw (XHL+0x06), 0x000a
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	ld	(ACC_EVENT:16), 0xd0
	ld	a, (0x331a:16)
	ld	(0x3376:16), a
	ld	(0x3377:16), 0x02
	ld	(0x3378:16), 0x40
	calr AccBuf_Write3ByteEvent
	ld	a, (0x331a:16)
	ld	(0x3376:16), a
	ld	(0x3377:16), 0x01
	ld	(0x3378:16), 0x00
	calr AccBuf_Write3ByteEvent
	ld	a, (0x331a:16)
	ld	(0x3376:16), a
	ld	(0x3377:16), 0x03
	ld	(0x3378:16), 0x00
	calr AccBuf_Write3ByteEvent
	ld	a, (0x331a:16)
	ld	(0x3376:16), a
	ld	(0x3377:16), 0x05
	ld	(0x3378:16), 0x7f
	calr AccBuf_Write3ByteEvent
	ret
AccCh1_ProcessNotes:
	call AccKbd1_TimingCheck
	bit	0, (ACC_PART_FLAGS:16)
	jr nz, AccCh1_ProcessReturn
	calr AccCh1_ScanSlots
	calr AccCh1_DrainRingBuf
	calr AccCh1_InitProgChange
	ld	XIY,0x00003161
	ld	XIX,0x0000317a
	ld bc, 5:i3
	ldir85
	ld	a, (0x3384:16)
	ld	(0x3234:16), a
	call RhythmPart2_ProcessAccentData
	and	(ACC_LANES_RESYNC:16), 0xfb
AccCh1_ProcessReturn:
	ret

AccCh1_ScanSlots:
	ld	xhl, ACC_BASS_NOTES
AccCh1_ScanSlots_Loop:
	call	AccSlot_CheckAndUpdate
	add	xhl, 9
	cp	xhl, 12420
	jr	c, AccCh1_ScanSlots_Loop
	ret
AccCh1_DrainRingBuf:
	ld	xhl, 11228
	ld	iy, (xhl+6)
	ld	bc, (xhl+2)
AccCh1_DrainLoop:
	cp (xhl + 4), iy
	jr z, AccCh1_DrainDone
	ld	a, (xhl+iy)
	cp a, 0x90
	jr nz, AccCh1_DrainType91
	call AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	call RingBuf_AdvanceIndex
	jr AccCh1_DrainLoop

AccCh1_DrainType91:
	cp a, 0x91
	jr nz, AccCh1_DrainOther
	call AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	call Rhythm_AdvancePosition
	jr AccCh1_DrainLoop

AccCh1_DrainOther:
	call RingBuf_AdvanceIndex
	jr AccCh1_DrainLoop

AccCh1_DrainDone:
	ret

AccCh2_ProcessEntry:
	calr AccCh2_SaveState
	call AccVoice_ProcessEventLoop
	calr AccCh2_RestoreState
	ret

AccCh2_SaveState:
	and	(ACC_PART_FLAGS:16), 0xfc
	ld	(ACC_BAD_EVENT_COUNT:16), 0x00
	ld A, 0x08:opc
	ld	(ACC_PART_BIT:16), a
	ld	wa, (0x31e5:16)
	ld	(ACC_CUR_BLOCK:16), wa
	ld	wa, (0x31d5:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x3200:16)
	ld	(ACC_CUR_BAR:16), a
	ld	a, (0x31f6:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	a, (0x31ee:16)
	ld	(ACC_CUR_SECTION:16), a
	ld	a, (0x3336:16)
	ld	(ACC_CUR_MEASURE:16), a
	ret
AccCh2_RestoreState:
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(12773:16), wa
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(12757:16), wa
	ld	a, (ACC_CUR_BAR:16)
	ld	(12800:16), a
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(12790:16), a
	ld	a, (ACC_CUR_SECTION:16)
	ld	(12782:16), a
	ld	a, (ACC_CUR_MEASURE:16)
	ld	(13110:16), a
	ret
AccCh2_NoteOnEntry:
	calr AccCh2_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccCh2_NoteOnReturn
	ld	a, (0x320c:16)
	ld	(ACC_CUR_TURNOVER:16), a
	ld	a, (0x3210:16)
	ld	(ACC_CUR_CEILING:16), a
	or	(ACC_PART_FLAGS:16), 0x04
	and	(ACC_PART_FLAGS:16), 0xf7
	ld	XHL,0x00002cdc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_WriteExtendedEvent
AccCh2_NoteOnReturn:
	ret

AccCh2_CheckEligible:
	and	(0x3329:16), 0xfe
	bit	3, (0x3326:16)
	jr z, AccCh2_CheckReturn
	bit	3, (0x32aa:16)
	jr nz, AccCh2_CheckReturn
	bit	2, (0x324f:16)
	jr z, AccCh2_CheckReturn
	bit	0, (0x3258:16)
	jr z, AccCh2_CheckReturn
	bit	0, (0xc4e0:16)
	jr z, AccCh2_CheckReturn
	calr AccCh2_CheckOverlap
	cp a, 0:i3
	jr nz, AccCh2_CheckReturn
	bit	1, (0x327d:16)
	jr nz, AccCh2_CheckReturn
	bit	0, (0x33c2:16)
	jr nz, AccCh2_CheckReturn
	bit	0, (0x3330:16)
	jr nz, AccCh2_CheckReturn
	ld	XHL,0x00002cdc
	call AccBuf_ComputeFillLevel
	cpw	(0x326c:16), 0x0010
	jr ugt, .Lc_f57693
	calr AccBuf_InitWithDefaults
	jr t, AccCh2_CheckReturn
AccCh2_SetReady:
.Lc_f57693:
	or	(0x3329:16), 0x01



AccCh2_CheckReturn:
	ret

AccCh2_DTypeEntry:
	calr AccCh2_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccCh2_DTypeReturn
	ld	XHL,0x00002cdc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_Write3ByteEvent
AccCh2_DTypeReturn:
	ret

AccCh2_CheckOverlap:
	ld A, 0x00:opc
	bit	2, (0x3417:16)
	jr z, AccCh2_OverlapReturn
	bit	0, (CMP_RECORD_PART:16)
	jr z, AccCh2_OverlapReturn
	ld A, 0x01:opc
AccCh2_OverlapReturn:
	ret

AccCh2_ProcessNotes:
	call AccKbd1_TimingCheck
	bit	0, (ACC_PART_FLAGS:16)
	jr nz, AccCh2_ProcessReturn
	calr AccCh2_ScanSlots
	calr AccCh2_DrainRingBuf
	calr AccCh2_InitProgChange
	ld	XIY,0x00003166
	ld	XIX,0x0000317f
	ld bc, 5:i3
	ldir85
	ld	a, (0x3384:16)
	ld	(0x3234:16), a
	call AccVoice_LoadRhythmParams_Part3
	and	(ACC_LANES_RESYNC:16), 0xf7
AccCh2_ProcessReturn:
	ret

AccCh2_ScanSlots:
	ld	xhl, ACC_ACCOMP1_NOTES
AccCh2_ScanSlots_Loop:
	call	AccSlot_CheckAndUpdate
	add	xhl, 9
	cp	xhl, 12492
	jr	c, AccCh2_ScanSlots_Loop
	ret
AccCh2_DrainRingBuf:
	ld	xhl, 11484
	ld	iy, (xhl+6)
	ld	bc, (xhl+2)
AccCh2_DrainLoop:
	cp (xhl + 4), iy
	jr z, AccCh2_DrainDone
	ld	a, (xhl+iy)
	cp a, 0x90
	jr nz, AccCh2_DrainType91
	call AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	call RingBuf_AdvanceIndex
	jr AccCh2_DrainLoop

AccCh2_DrainType91:
	cp a, 0x91
	jr nz, AccCh2_DrainOther
	call AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	call Rhythm_AdvancePosition
	jr AccCh2_DrainLoop

AccCh2_DrainOther:
	call RingBuf_AdvanceIndex
	jr AccCh2_DrainLoop

AccCh2_DrainDone:
	ret

AccCh3_ProcessEntry:
	calr AccCh3_SaveState
	call AccVoice_ProcessEventLoop
	calr AccCh3_RestoreState
	ret

AccCh3_SaveState:
	and	(ACC_PART_FLAGS:16), 0xfc
	ld	(ACC_BAD_EVENT_COUNT:16), 0x00
	ld A, 0x10:opc
	ld	(ACC_PART_BIT:16), a
	ld	wa, (0x31e7:16)
	ld	(ACC_CUR_BLOCK:16), wa
	ld	wa, (0x31d7:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x3201:16)
	ld	(ACC_CUR_BAR:16), a
	ld	a, (0x31f7:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	a, (0x31ef:16)
	ld	(ACC_CUR_SECTION:16), a
	ld	a, (0x3337:16)
	ld	(ACC_CUR_MEASURE:16), a
	ret
AccCh3_RestoreState:
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(12775:16), wa
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(12759:16), wa
	ld	a, (ACC_CUR_BAR:16)
	ld	(12801:16), a
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(12791:16), a
	ld	a, (ACC_CUR_SECTION:16)
	ld	(12783:16), a
	ld	a, (ACC_CUR_MEASURE:16)
	ld	(13111:16), a
	ret
AccCh3_NoteOnEntry:
	calr AccCh3_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccCh3_NoteOnReturn
	ld	a, (0x320d:16)
	ld	(ACC_CUR_TURNOVER:16), a
	ld	a, (0x3211:16)
	ld	(ACC_CUR_CEILING:16), a
	and	(ACC_PART_FLAGS:16), 0xfb
	and	(ACC_PART_FLAGS:16), 0xf7
	ld	XHL,0x00002ddc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_WriteExtendedEvent
AccCh3_NoteOnReturn:
	ret

AccCh3_CheckEligible:
	and	(0x3329:16), 0xfe
	bit	4, (0x3326:16)
	jr z, AccCh3_CheckReturn
	bit	4, (0x32aa:16)
	jr nz, AccCh3_CheckReturn
	bit	3, (0x324f:16)
	jr z, AccCh3_CheckReturn
	bit	1, (0x3258:16)
	jr z, AccCh3_CheckReturn
	bit	1, (0xc4e0:16)
	jr z, AccCh3_CheckReturn
	calr AccCh3_CheckOverlap
	cp a, 0:i3
	jr nz, AccCh3_CheckReturn
	bit	1, (0x327d:16)
	jr nz, AccCh3_CheckReturn
	bit	0, (0x33c2:16)
	jr nz, AccCh3_CheckReturn
	bit	0, (0x3330:16)
	jr nz, AccCh3_CheckReturn
	ld	XHL,0x00002ddc
	call AccBuf_ComputeFillLevel
	cpw	(0x326c:16), 0x0010
	jr ugt, .Lc_f57850
	calr AccBuf_InitWithDefaults
	jr t, AccCh3_CheckReturn
AccCh3_SetReady:
.Lc_f57850:
	or	(0x3329:16), 0x01



AccCh3_CheckReturn:
	ret

AccCh3_DTypeEntry:
	calr AccCh3_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccCh3_DTypeReturn
	ld	XHL,0x00002ddc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_Write3ByteEvent
AccCh3_DTypeReturn:
	ret

AccCh3_CheckOverlap:
	ld A, 0x00:opc
	bit	2, (0x3417:16)
	jr z, AccCh3_OverlapReturn
	bit	1, (CMP_RECORD_PART:16)
	jr z, AccCh3_OverlapReturn
	ld A, 0x01:opc
AccCh3_OverlapReturn:
	ret

AccCh3_ProcessNotes:
	call AccKbd1_TimingCheck
	bit	0, (ACC_PART_FLAGS:16)
	jr nz, AccCh3_ProcessReturn
	calr AccCh3_ScanSlots
	calr AccCh3_DrainRingBuf
	calr AccCh3_InitProgChange
	ld	XIY,0x0000316b
	ld	XIX,0x00003184
	ld bc, 5:i3
	ldir85
	ld	a, (0x3384:16)
	ld	(0x3234:16), a
	call AccVoice_LoadRhythmParams_Part4
	and	(ACC_LANES_RESYNC:16), 0xef
AccCh3_ProcessReturn:
	ret

AccCh3_ScanSlots:
	ld	xhl, ACC_ACCOMP2_NOTES
AccCh3_ScanSlots_Loop:
	call	AccSlot_CheckAndUpdate
	add	xhl, 9
	cp	xhl, 12564
	jr	c, AccCh3_ScanSlots_Loop
	ret
AccCh3_DrainRingBuf:
	ld	xhl, 11740
	ld	iy, (xhl+6)
	ld	bc, (xhl+2)
AccCh3_DrainLoop:
	cp (xhl + 4), iy
	jr z, AccCh3_DrainDone
	ld	a, (xhl+iy)
	cp a, 0x90
	jr nz, AccCh3_DrainType91
	call AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	call RingBuf_AdvanceIndex
	jr AccCh3_DrainLoop

AccCh3_DrainType91:
	cp a, 0x91
	jr nz, AccCh3_DrainOther
	call AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	call Rhythm_AdvancePosition
	jr AccCh3_DrainLoop

AccCh3_DrainOther:
	call RingBuf_AdvanceIndex
	jr AccCh3_DrainLoop

AccCh3_DrainDone:
	ret

AccCh4_ProcessEntry:
	calr AccCh4_SaveState
	call AccVoice_ProcessEventLoop
	calr AccCh4_RestoreState
	ret

AccCh4_SaveState:
	and	(ACC_PART_FLAGS:16), 0xfc
	ld	(ACC_BAD_EVENT_COUNT:16), 0x00
	ld A, 0x20:opc
	ld	(ACC_PART_BIT:16), a
	ld	wa, (0x31e9:16)
	ld	(ACC_CUR_BLOCK:16), wa
	ld	wa, (0x31d9:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x3202:16)
	ld	(ACC_CUR_BAR:16), a
	ld	a, (0x31f8:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	a, (0x31f0:16)
	ld	(ACC_CUR_SECTION:16), a
	ld	a, (0x3338:16)
	ld	(ACC_CUR_MEASURE:16), a
	ret
AccCh4_RestoreState:
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(12777:16), wa
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(12761:16), wa
	ld	a, (ACC_CUR_BAR:16)
	ld	(12802:16), a
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(12792:16), a
	ld	a, (ACC_CUR_SECTION:16)
	ld	(12784:16), a
	ld	a, (ACC_CUR_MEASURE:16)
	ld	(13112:16), a
	ret
AccCh4_NoteOnEntry:
	calr AccCh4_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccCh4_NoteOnReturn
	ld	a, (0x320e:16)
	ld	(ACC_CUR_TURNOVER:16), a
	ld	a, (0x3212:16)
	ld	(ACC_CUR_CEILING:16), a
	and	(ACC_PART_FLAGS:16), 0xfb
	and	(ACC_PART_FLAGS:16), 0xf7
	ld	XHL,0x00002edc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_WriteExtendedEvent
AccCh4_NoteOnReturn:
	ret

AccCh4_CheckEligible:
	and	(0x3329:16), 0xfe
	bit	5, (0x3326:16)
	jr z, AccCh4_CheckReturn
	bit	5, (0x32aa:16)
	jr nz, AccCh4_CheckReturn
	bit	4, (0x324f:16)
	jr z, AccCh4_CheckReturn
	bit	2, (0x3258:16)
	jr z, AccCh4_CheckReturn
	bit	2, (0xc4e0:16)
	jr z, AccCh4_CheckReturn
	calr AccCh4_CheckOverlap
	cp a, 0:i3
	jr nz, AccCh4_CheckReturn
	bit	1, (0x327d:16)
	jr nz, AccCh4_CheckReturn
	bit	0, (0x33c2:16)
	jr nz, AccCh4_CheckReturn
	bit	0, (0x3330:16)
	jr nz, AccCh4_CheckReturn
	ld	XHL,0x00002edc
	call AccBuf_ComputeFillLevel
	cpw	(0x326c:16), 0x0010
	jr ugt, .Lc_f57a0d
	calr AccBuf_InitWithDefaults
	jr t, AccCh4_CheckReturn
AccCh4_SetReady:
.Lc_f57a0d:
	or	(0x3329:16), 0x01



AccCh4_CheckReturn:
	ret

AccCh4_DTypeEntry:
	calr AccCh4_CheckEligible
	bit	0, (0x3329:16)
	jr z, AccCh4_DTypeReturn
	ld	XHL,0x00002edc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	calr AccBuf_Write3ByteEvent
AccCh4_DTypeReturn:
	ret

AccCh4_CheckOverlap:
	ld A, 0x00:opc
	bit	2, (0x3417:16)
	jr z, AccCh4_OverlapReturn
	bit	2, (CMP_RECORD_PART:16)
	jr z, AccCh4_OverlapReturn
	ld A, 0x01:opc
AccCh4_OverlapReturn:
	ret

AccCh4_ProcessNotes:
	call AccKbd1_TimingCheck
	bit	0, (ACC_PART_FLAGS:16)
	jr nz, AccCh4_ProcessReturn
	calr AccCh4_ScanSlots
	calr AccCh4_DrainRingBuf
	calr AccCh4_InitProgChange
	ld	XIY,0x00003170
	ld	XIX,0x00003189
	ld bc, 5:i3
	ldir85
	ld	a, (0x3384:16)
	ld	(0x3234:16), a
	call AccVoice_LoadRhythmParams_Part5
	and	(ACC_LANES_RESYNC:16), 0xdf
AccCh4_ProcessReturn:
	ret

AccCh4_ScanSlots:
	ld	xhl, ACC_ACCOMP3_NOTES
AccCh4_ScanSlots_Loop:
	call	AccSlot_CheckAndUpdate
	add	xhl, 9
	cp	xhl, 12636
	jr	c, AccCh4_ScanSlots_Loop
	ret
AccCh4_DrainRingBuf:
	ld	xhl, 11996
	ld	iy, (xhl+6)
	ld	bc, (xhl+2)
AccCh4_DrainLoop:
	cp (xhl + 4), iy
	jr z, AccCh4_DrainDone
	ld	a, (xhl+iy)
	cp a, 0x90
	jr nz, AccCh4_DrainType91
	call AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	call RingBuf_AdvanceIndex
	jr AccCh4_DrainLoop

AccCh4_DrainType91:
	cp a, 0x91
	jr nz, AccCh4_DrainOther
	call AccBuf_ProcessNoteEvent
	call RingBuf_AdvanceIndex
	call Rhythm_AdvancePosition
	jr AccCh4_DrainLoop

AccCh4_DrainOther:
	call RingBuf_AdvanceIndex
	jr AccCh4_DrainLoop

AccCh4_DrainDone:
	ret

AccCh1_InitProgChange:
	ld	xhl, 11228
	calr	AccBuf_WriteD0Defaults
	ret
AccCh2_InitProgChange:
	ld	xhl, 11484
	calr	AccBuf_WriteD0Defaults
	ret
AccCh3_InitProgChange:
	ld	xhl, 11740
	calr	AccBuf_WriteD0Defaults
	ret
AccCh4_InitProgChange:
	ld	xhl, 11996
	calr	AccBuf_WriteD0Defaults
	ret
AccBuf_WriteD0Defaults:
	ld	iy, (xhl+4)
	ld	bc, (xhl+2)
	ld	(ACC_EVENT:16), 208
	ld	a, (13188:16)
	ld	(13174:16), a
	ld	(13175:16), 2
	ld	(13176:16), 64
	calr	AccBuf_Write3ByteEvent
	ld	a, (13188:16)
	ld	(13174:16), a
	ld	(13175:16), 1
	ld	(13176:16), 0
	calr	AccBuf_Write3ByteEvent
	ld	a, (13188:16)
	ld	(13174:16), a
	ld	(13175:16), 3
	ld	(13176:16), 0
	calr	AccBuf_Write3ByteEvent
	ld	a, (13188:16)
	ld	(13174:16), a
	ld	(13175:16), 5
	ld	(13176:16), 127
	calr	AccBuf_Write3ByteEvent
	ret
AccPart_Deactivate:
	ld	a, (ACC_SECTION_BUTTONS_HELD:16)
	and	a, 192
	jr	nz, AccPart_Deactivate_WithPedal
	ld	a, (ACC_PART_BIT:16)
	and	a, (12913:16)
	jr	z, AccPart_Deactivate_NoPedal
AccPart_Deactivate_WithPedal:
	calr	AccPart_ResolveWithPedal
	ld	a, (ACC_PART_BIT:16)
	xor	a, 255
	and	(12913:16), a
	jrl	AccPart_DeactivateReturn
AccPart_Deactivate_NoPedal:
	ld	a, (ACC_LANES_INTRO1:16)
	or	a, (ACC_LANES_COUNTIN:16)
	or	a, (ACC_LANES_INTRO2:16)
	and	a, (ACC_PART_BIT:16)
	jr	nz, AccPart_Deactivate_ActiveNote
	bit	0, (ACC_STYLE_ARRANGER_ON:16)
	jr	nz, AccPart_Deactivate_WithSync
	bit	0, (0x3257:16)
	jr	nz, AccPart_Deactivate_SetDone
	jr	AccPart_Deactivate_SendOff
AccPart_Deactivate_WithSync:
	and	(0x3256:16), 252
	or	(0x3256:16), 1
	ld	a, (ACC_PART_BIT:16)
	and	a, (ACC_LANES_FILLIN1:16)
	jr	z, AccPart_Deactivate_SetDone
	or	(0x3256:16), 2
	jr	AccPart_Deactivate_SetDone
AccPart_Deactivate_ActiveNote:
	bit	0, (0x3257:16)
	jr	z, AccPart_Deactivate_SendOff
AccPart_Deactivate_SetDone:
	or	(0x323b:16), 128
	or	(ACC_PART_FLAGS:16), 1
	jr	AccPart_Deactivate_ClearMasks
AccPart_Deactivate_SendOff:
	calr AccPart_SelectSourceOrParam
	calr AccPart_ResolveStyleAddr

AccPart_Deactivate_ClearMasks:
	ld	a, (ACC_PART_BIT:16)
	xor	a, 255
	and	(ACC_LANES_FILLIN1:16), a
	and	(ACC_LANES_FILLIN2:16), a
	and	(ACC_LANES_INTRO1:16), a
	and	(ACC_LANES_COUNTIN:16), a
	and	(ACC_LANES_INTRO2:16), a
	ld	(ACC_CUR_BEAT_POS:16), 0
	ld	(ACC_CUR_MEASURE:16), 0
AccPart_DeactivateReturn:
	ret

AccPart_Reactivate:
	ld	a, (ACC_PART_BIT:16)
	and	a, (13096:16)
	jr	z, AccPart_ReactivateReturn
	ld	a, (ACC_PART_BIT:16)
	ld	w, (ACC_LANES_ENDING1:16)
	or	w, (ACC_LANES_ENDING2:16)
	and	w, a
	jr	z, AccPart_Reactivate_Inactive
	or	(ACC_LANES_PARKED:16), a
	or	(ACC_LANES_ENDED:16), a
	ld	(ACC_CUR_BLOCK:16), 254
	ld	(ACC_CUR_READ_POS:16), 6
	jr	AccPart_ReactivateReturn
AccPart_Reactivate_Inactive:
	ld	a, (ACC_PART_BIT:16)
	xor	a, 255
	and	(ACC_LANES_FILLIN1:16), a
	and	(ACC_LANES_FILLIN2:16), a
	and	(ACC_LANES_INTRO1:16), a
	and	(ACC_LANES_COUNTIN:16), a
	and	(ACC_LANES_INTRO2:16), a
	and	(12965:16), a
	and	(12913:16), a
	ld	(ACC_CUR_MEASURE:16), 0
	ld	(ACC_CUR_BLOCK:16), 254
	ld	(ACC_CUR_READ_POS:16), 6
AccPart_ReactivateReturn:
	ret

AccTick_Main:
	bit	2, (ACC_RUN_FLAGS:16)
	jrl nz, AccTick_CheckCollect
	calr AccTempo_BarCompare
	bit	6, (ACC_PART_FLAGS:16)
	jrl nz, AccTick_Return
	calr AccSection_SwitchNowUnlessDeferred
	bit	6, (ACC_PART_FLAGS:16)
	jrl nz, AccTick_Return
	call AccTuning_ApplyChange
	bit	7, (ACC_LANES_RESYNC:16)
	jr z, .Lc_f57c79
	call Rhythm_ProcessAllPartsAndLoad
	and	(ACC_LANES_RESYNC:16), 0x7f
AccTick_AfterSync:
.Lc_f57c79:
	call AccVoice_ProcessAllSixParts
	bit	5, (ACC_PART_FLAGS:16)
	jrl nz, AccTick_Return
	call AccKbd2_ProcessEntry
	call AccSeq_ScanPattern
	bit	0, (0x33c2:16)
	jr nz, AccTick_ProcessAccChannels
	bit	0, (ACC_RUN_FLAGS:16)
	jr z, AccTick_CheckNoteOn
	ld	wa, (AUDIO_CONFIG_FLAGS:16)
	and WA,0x0200
	jr z, AccTick_CheckNoteOn
AccTick_ProcessAccChannels:
	call AccCh1_ProcessEntry
	call AccCh2_ProcessEntry
	call AccCh3_ProcessEntry
	call AccCh4_ProcessEntry

AccTick_CheckNoteOn:
	bit	7, (0x323b:16)
	jr	z, AccTick_CheckCollect
	and	(0x323b:16), 127
	call	AccTempo_CalcPosition
	bit	0, (0x3256:16)
	jr	nz, AccTick_DispatchNoteOn
	bit	0, (0x3257:16)
	jr	nz, AccTick_DispatchNoteOn
	bit	0, (ACC_VARIATION_CHANGE_PENDING:16)
	jr	nz, AccTick_DispatchNoteOn
	bit	0, (0x3254:16)
	jr	nz, AccTick_DispatchNoteOn
	ld	a, (ACC_PENDING_FILLIN:16)
	and	a, 3
	jr	nz, AccTick_DispatchNoteOn
	ld	a, (ACC_PENDING_INTRO:16)
	and	a, 13
	jr	nz, AccTick_DispatchNoteOn
	ld	a, (ACC_PENDING_ENDING:16)
	and	a, 3
	jr	z, AccTick_FlushAndRepeat
AccTick_DispatchNoteOn:
	call AccSection_SwitchAtBarLine

AccTick_FlushAndRepeat:
	call AccNote_FlushAll
	jrl AccTick_AfterSync

AccTick_CheckCollect:
	bit	2, (ACC_RUN_FLAGS:16)
	jr z, AccTick_Return
	call AccEnding_StopWhenSilent
AccTick_Return:
	ret

AccVelocity_CurveTable:
	.byte 0x0d, 0x1a, 0x33, 0x4d, 0x66, 0x80, 0x9a, 0xb3
	.byte 0xcc, 0xe6, 0xff

AccVoice_InitPerChannel:
	cp	(ACC_PART_BIT:16), 0x04
	jr nz, .Lc_f57d21
	calr AccVoice_InitCh1_D7
	jr t, AccVoice_InitReturn
AccVoice_InitCh2:
.Lc_f57d21:
	cp	(ACC_PART_BIT:16), 0x08
	jr nz, .Lc_f57d2d
	calr AccVoice_InitCh2_D4
	jr t, AccVoice_InitReturn
AccVoice_InitCh3:
.Lc_f57d2d:
	cp	(ACC_PART_BIT:16), 0x10
	jr nz, .Lc_f57d39
	calr AccVoice_InitCh3_D5
	jr t, AccVoice_InitReturn
AccVoice_InitCh4:
.Lc_f57d39:
	cp	(ACC_PART_BIT:16), 0x20
	jr nz, AccVoice_InitReturn
	calr AccVoice_InitCh4_D6
AccVoice_InitReturn:
	ret

AccVoice_InitCh1_D7:
	pushw	hl
	push	xiy
	ld	xhl, 11228
	calr	AccBuf_DrainAndReset
	ld	a, 215:opc
	ld	w, 2:opc
	ld	e, 64:opc
	call	Rhythm_Send3ByteMsg
	ld	a, 215:opc
	ld	w, 1:opc
	ld	e, 0:opc
	call	Rhythm_Send3ByteMsg
	ld	a, 215:opc
	ld	w, 3:opc
	ld	e, 0:opc
	call	Rhythm_Send3ByteMsg
	ld	(ACC_CH_CC3:16), 0
	ld	a, 215:opc
	ld	w, 5:opc
	ld	e, 127:opc
	call	Rhythm_Send3ByteMsg
	pop	xiy
	popw	hl
	ret
AccBuf_WriteD0WithVoice:
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	ld	(xhl+iy), 0xd0
	call RingBuf_AdvanceIndex
	ld	a, (0x3232:16)
	ld	(0x3376:16), a
	call RhythmAccent_UpdateRingBufPosition
	ld	(xhl+iy), 0x03
	call RingBuf_AdvanceIndex
	ld	a, (ACC_CUR_CC3:16)
	ld	(xhl+iy), a
	call RingBuf_AdvanceIndex
	ld (XHL+0x04),IY
	ret
AccVoice_InitCh2_D4:
	pushw	hl
	push	xiy
	ld	xhl, 11484
	calr	AccBuf_DrainAndReset
	ld	a, 212:opc
	ld	w, 2:opc
	ld	e, 64:opc
	call	Rhythm_Send3ByteMsg
	ld	a, 212:opc
	ld	w, 1:opc
	ld	e, 0:opc
	call	Rhythm_Send3ByteMsg
	ld	a, 212:opc
	ld	w, 3:opc
	ld	e, 0:opc
	call	Rhythm_Send3ByteMsg
	ld	(12920:16), 0
	ld	a, 212:opc
	ld	w, 5:opc
	ld	e, 127:opc
	call	Rhythm_Send3ByteMsg
	pop	xiy
	popw	hl
	ret
AccVoice_InitCh3_D5:
	pushw	hl
	push	xiy
	ld	xhl, 11740
	calr	AccBuf_DrainAndReset
	ld	a, 213:opc
	ld	w, 2:opc
	ld	e, 64:opc
	call	Rhythm_Send3ByteMsg
	ld	a, 213:opc
	ld	w, 1:opc
	ld	e, 0:opc
	call	Rhythm_Send3ByteMsg
	ld	a, 213:opc
	ld	w, 3:opc
	ld	e, 0:opc
	call	Rhythm_Send3ByteMsg
	ld	(12921:16), 0
	ld	a, 213:opc
	ld	w, 5:opc
	ld	e, 127:opc
	call	Rhythm_Send3ByteMsg
	pop	xiy
	popw	hl
	ret
AccVoice_InitCh4_D6:
	pushw	hl
	push	xiy
	ld	xhl, 11996
	calr	AccBuf_DrainAndReset
	ld	a, 214:opc
	ld	w, 2:opc
	ld	e, 64:opc
	call	Rhythm_Send3ByteMsg
	ld	a, 214:opc
	ld	w, 1:opc
	ld	e, 0:opc
	call	Rhythm_Send3ByteMsg
	ld	a, 214:opc
	ld	w, 3:opc
	ld	e, 0:opc
	call	Rhythm_Send3ByteMsg
	ld	(12922:16), 0
	ld	a, 214:opc
	ld	w, 5:opc
	ld	e, 127:opc
	call	Rhythm_Send3ByteMsg
	pop	xiy
	popw	hl
	ret
AccSection_SwitchNowUnlessDeferred:
	bit	0, (0x3254:16)
	jr nz, AccSection_SwitchNowUnlessDeferred_CheckEndingDefer
	ld	a, (ACC_PENDING_ENDING:16)
	and A,0x03
	jr z, AccSection_SwitchNowUnlessDeferred_CheckIntroFill
AccSection_SwitchNowUnlessDeferred_CheckEndingDefer:
	ld	a, (ACC_DEFER_ENDING_LANES:16)
	and	a, 63
	jr	z, AccSection_SwitchNowUnlessDeferred_Switch
AccSection_SwitchNowUnlessDeferred_CheckIntroFill:
	ld	a, (ACC_PENDING_INTRO:16)
	and	a, 13
	jr	nz, AccSection_SwitchNowUnlessDeferred_CheckDefer
	ld	a, (ACC_PENDING_FILLIN:16)
	and	a, 3
	jr	z, AccSection_SwitchNowUnlessDeferred_Return
AccSection_SwitchNowUnlessDeferred_CheckDefer:
	ld	a, (ACC_DEFER_SECTION_LANES:16)
	and	a, 63
	jr	nz, AccSection_SwitchNowUnlessDeferred_Return
AccSection_SwitchNowUnlessDeferred_Switch:
	calr AccSection_SwitchNow

AccSection_SwitchNowUnlessDeferred_Return:
	ret
AccTick_ByteData:
	call	Rhythm_SendNoteOnMax
	call	AccNotes_ForgetAllSounding
	calr	AccBuf_WriteAllNotesOff
	call	Rhythm_SendChanPressure
	calr	AccBuf_ResetAll4
	ld	a, (ACC_LANES_FILLIN1:16)
	or	a, (ACC_LANES_FILLIN2:16)
	and	a, 63
	jr	z, AccTick_ByteData_Join
	bit	0, (ACC_STYLE_ARRANGER_ON:16)
	jr	z, AccTick_ByteData_Join
	or	(0x3254:16), 1
	ld	a, (ACC_LANES_FILLIN1:16)
	and	a, 63
	jr	z, AccPedal_CheckCombined_Skip
	cp	(ACC_VARIATION_NEXT:16), 0
	jr	z, AccTick_ByteData_Join
	dec	1, (ACC_VARIATION_NEXT:16)
	jr	AccTick_ByteData_Join
AccPedal_CheckCombined_Skip:
	cp	(ACC_VARIATION_NEXT:16), 3
	jr	z, AccTick_ByteData_Join
	inc	1, (ACC_VARIATION_NEXT:16)
AccTick_ByteData_Join:
	bit	0, (0x3257:16)
	jr	nz, AccPedal_CheckCombined_Skip2
	bit	0, (0x3254:16)
	jr	z, AccPedal_CheckCombined_Skip3
	ld	a, (ACC_DEFER_ENDING_LANES:16)
	and	a, 63
	jr	nz, AccPedal_CheckCombined_Skip3
AccPedal_CheckCombined_Skip2:
	calr	AccStyle_Init
	calr	AccVoice_SetupAllParts
	ld	a, (ACC_BEATS_PER_BAR:16)
	ld	(1112:16), a
AccPedal_CheckCombined_Skip3:
	ld	a, (ACC_PENDING_INTRO:16)
	and	a, 13
	jr	z, AccPedal_CheckCombined_Skip5
	calr	AccSection_StartIntro
AccPedal_CheckCombined_Skip5:
	ld	a, (ACC_PENDING_FILLIN:16)
	and	a, 3
	jr	nz, AccPedal_CheckCombined_Join
	bit	6, (ACC_SECTION_BUTTONS_HELD:16)
	jr	z, AccTick_ByteData_Skip
	or	(ACC_PENDING_FILLIN:16), 1
	jr	AccPedal_CheckCombined_Join
AccTick_ByteData_Skip:
	bit	7, (ACC_SECTION_BUTTONS_HELD:16)
	jr	z, AccPedal_CheckCombined_Skip6
	or	(ACC_PENDING_FILLIN:16), 2
AccPedal_CheckCombined_Join:
	calr	AccSection_StartFillIn
AccPedal_CheckCombined_Skip6:
	ld	a, (ACC_PENDING_ENDING:16)
	and	a, 3
	jr	z, AccTick_ByteData_Join2
	calr	AccTiming_CallHelper
	call	AccInit_ResetSongCounter
	calr	AccSection_StartEnding
AccTick_ByteData_Join2:
	and	(ACC_LANE_BEAT_POS:16), 240
	and	(0x31f4:16), 240
	and	(0x31f5:16), 240
	and	(0x31f6:16), 240
	and	(0x31f7:16), 240
	and	(0x31f8:16), 240
	calr	AccSeq_DualPartScan
	bit	6, (ACC_PART_FLAGS:16)
	jr	nz, AccTick_ByteData_Join3
	calr	AccSeq_FourChannelScan
AccTick_ByteData_Join3:
	or	(ACC_LANES_RESYNC:16), 128
	ret
AccTempo_BarCompare:
	ld	w, (ACC_LANE_BAR:16)
	cp	w, (0x31fc:16)
	jr c, .Lc_f57f89
	jr z, AccTempo_BarEqual
	jr ugt, AccTempo_BarGreater
AccTempo_BarLess:
.Lc_f57f89:
	cp w, 0:i3
	jr nz, AccTempo_BarChanged
	cp	(0x31fc:16), 0xff
	jr nz, AccTempo_BarChanged
	jr t, AccTempo_ComputeSubDelta
AccTempo_BarEqual:
	ld	wa, (12843:16)
	cp	(12744:16), w
	jr	c, AccTempo_ComputeSubDelta
	jr	ugt, AccTempo_BarChanged
	cp	(12743:16), a
	jr	ule, AccTempo_ComputeSubDelta
	jr	AccTempo_BarChanged
AccTempo_BarGreater:
	cp	w, 255
	jr	nz, AccTempo_ComputeSubDelta
	cp	(12796:16), 0
	jr	nz, AccTempo_ComputeSubDelta
AccTempo_BarChanged:
	ld a, 0x1:opc
	jr AccTempo_StoreDelta

AccTempo_ComputeSubDelta:
	ld	wa, (12843:16)
	sub	a, (12743:16)
	jr	nc, AccTempo_StoreDelta
	add	a, 96
AccTempo_StoreDelta:
	ld	(12850:16), a
	ld	(12852:16), a
	ret
AccSeq_DualPartScan:
	ld	de, (0x322b:16)
	ld	(ACC_SCAN_BAD_EVENT_COUNT:16), 0x00
	ld	(ACC_CUR_CC3:16), 0x00
	ld	wa, (ACC_LANE_READ_POS:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (ACC_LANE_BEAT_POS:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	iz, (ACC_LANE_BLOCK:16)
	ld	(ACC_CUR_BLOCK:16), iz
	ld W, 0x01:opc
	calr AccVoice_SelectByMask
	calr AccSeq_PatternScanner
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(ACC_LANE_BLOCK:16), wa
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(ACC_LANE_BEAT_POS:16), a
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(ACC_LANE_READ_POS:16), wa
	bit	6, (ACC_PART_FLAGS:16)
	jr nz, AccSeq_DualPartReturn
	ld	de, (0x322b:16)
	ld	(ACC_SCAN_BAD_EVENT_COUNT:16), 0x00
	ld	(ACC_CUR_CC3:16), 0x00
	ld	wa, (0x31d1:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x31f4:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	iz, (0x31e1:16)
	ld	(ACC_CUR_BLOCK:16), iz
	ld W, 0x02:opc
	calr AccVoice_SelectByMask
	calr AccSeq_PatternScanner
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(0x31e1:16), wa
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(0x31f4:16), a
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(0x31d1:16), wa
AccSeq_DualPartReturn:
	ret

AccSeq_PatternScanner:
	ld	iy, (ACC_CUR_READ_POS:16)
	ld	iz, (ACC_CUR_BLOCK:16)
	and	(ACC_PART_FLAGS:16), 0xfe

	xor bc, bc



AccSeq_ScannerLoop:
.Lc_f58072:
	bit	0, (ACC_PART_FLAGS:16)
	jrl nz, AccSeq_Scanner_Done
	ld	a, (xhl+iy)
	cp A,0x81
	jr nz, AccSeq_Scanner_EventType
	add B,0x01
	xor C,C
	cp DE,BC
	jr nc, .Lc_f58093
	or	(ACC_PART_FLAGS:16), 0x01
	jr t, .Lc_f58072
AccSeq_Scanner_BarEnd:
.Lc_f58093:
	ld	a, (ACC_CUR_BEAT_POS:16)
	inc 1,A
	ld W,A
	and A,0x0f
	cp	a, (ACC_BEATS_PER_BAR:16)
	jr	nz, AccSeq_Scanner_StorePos
	and	w, 240
	add	w, 16
AccSeq_Scanner_StorePos:
	ld	(ACC_CUR_BEAT_POS:16), w
	calr	AccBuf_Advance
	jr	AccSeq_ScannerLoop
AccSeq_Scanner_EventType:
	cp a, 0x90
	jr z, AccSeq_Scanner_EventMatch
	cp a, 0x91
	jr z, AccSeq_Scanner_EventMatch
	cp a, 0xd1
	jr z, AccSeq_Scanner_EventMatch
	cp a, 0xd2
	jr z, AccSeq_Scanner_EventMatch
	cp a, 0xd3
	jr z, AccSeq_Scanner_EventMatch
	cp a, 0xd4
	jr z, AccSeq_Scanner_EventMatch
	cp a, 0xd5
	jr z, AccSeq_Scanner_EventMatch
	jr nz, AccSeq_Scanner_Unknown

AccSeq_Scanner_EventMatch:
	calr	AccBuf_AdvanceWithPageTurn
	ld	c, a
	cp	de, bc
	jr	nc, AccSeq_Scanner_SkipFields
	or	(ACC_PART_FLAGS:16), 1
	jr	AccSeq_ScannerLoop
AccSeq_Scanner_SkipFields:
	ld	a, (xhl+iy)
	cp a, 0xd3
	jr z, AccSeq_Scanner_D3Voice
	cp a, 0x90
	jr nz, AccSeq_Scanner_Skip91
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	jrl AccSeq_ScannerLoop

AccSeq_Scanner_Skip91:
	cp a, 0x91
	jr nz, AccSeq_Scanner_SkipOther
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	jrl AccSeq_ScannerLoop

AccSeq_Scanner_SkipOther:
	calr AccBuf_Advance
	calr AccBuf_Advance
	calr AccBuf_Advance
	jrl AccSeq_ScannerLoop

AccSeq_Scanner_D3Voice:
	calr	AccBuf_Advance
	calr	AccBuf_Advance
	ld	a, (xhl+iy)
	ld	(ACC_CUR_CC3:16), a
	calr	AccBuf_Advance
	jrl	AccSeq_ScannerLoop	; -> 0xF58072
AccSeq_Scanner_Unknown:
	inc	1, (ACC_SCAN_BAD_EVENT_COUNT:16)
	cp	(ACC_SCAN_BAD_EVENT_COUNT:16), 32
	jr	c, AccSeq_Scanner_Skip1
	call	AccWrap_PlayModeDispatch
	call	Composer_ResetStyleImage
	ld	(ACC_PENDING_STYLE:16), 255
	or	(ACC_PART_FLAGS:16), 65
AccSeq_Scanner_Skip1:
	calr AccBuf_Advance
	jrl AccSeq_ScannerLoop

AccSeq_Scanner_Done:
	ld	(ACC_CUR_BLOCK:16), iz
	ld	(ACC_CUR_READ_POS:16), iy
	ret
AccSeq_ScannerPadding:
	nop
	nop

AccBuf_AdvanceWithPageTurn:
	pushw iy
	inc 1, iy
	ld	a, (xhl+iy)
	cp a, 0x87
	jr nz, AccBuf_AdvanceReturn
	push xhl
	pushw iz
	ld iz, (xhl + 3)
	calr AccWave_BankResolve
	ld a, (xhl + 6)
	popw iz
	pop xhl

AccBuf_AdvanceReturn:
	popw iy
	ret

AccBuf_Advance:
	inc 1, iy
	ld	a, (xhl+iy)
	cp a, 0x87
	jr nz, AccBuf_AdvanceSimpleReturn
	ld hl, (xhl + 3)
	ld iz, hl
	calr AccWave_BankResolve
	ld iy, 6:i3

AccBuf_AdvanceSimpleReturn:
	ret

AccSeq_FourChannelScan:
	ld	de, (0x322b:16)
	ld	(ACC_SCAN_BAD_EVENT_COUNT:16), 0x00
	ld	(ACC_CUR_CC3:16), 0x00
	ld	wa, (0x31d3:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x31f5:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	iz, (0x31e3:16)
	ld	(ACC_CUR_BLOCK:16), iz
	ld W, 0x04:opc
	calr AccVoice_SelectByMask
	calr AccSeq_PatternScanner
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(0x31e3:16), wa
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(0x31f5:16), a
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(0x31d3:16), wa
	ld	XHL,0x00002bdc
	calr AccBuf_WriteD0WithVoice
	bit	6, (ACC_PART_FLAGS:16)
	jrl nz, AccSeq_FourChannelReturn
	ld	de, (0x322b:16)
	ld	(ACC_SCAN_BAD_EVENT_COUNT:16), 0x00
	ld	(ACC_CUR_CC3:16), 0x00
	ld	wa, (0x31d5:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x31f6:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	iz, (0x31e5:16)
	ld	(ACC_CUR_BLOCK:16), iz
	ld W, 0x08:opc
	calr AccVoice_SelectByMask
	calr AccSeq_PatternScanner
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(0x31e5:16), wa
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(0x31f6:16), a
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(0x31d5:16), wa
	ld	XHL,0x00002cdc
	calr AccBuf_WriteD0WithVoice
	bit	6, (ACC_PART_FLAGS:16)
	jrl nz, AccSeq_FourChannelReturn
	ld	de, (0x322b:16)
	ld	(ACC_SCAN_BAD_EVENT_COUNT:16), 0x00
	ld	(ACC_CUR_CC3:16), 0x00
	ld	wa, (0x31d7:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x31f7:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	iz, (0x31e7:16)
	ld	(ACC_CUR_BLOCK:16), iz
	ld W, 0x10:opc
	calr AccVoice_SelectByMask
	calr AccSeq_PatternScanner
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(0x31e7:16), wa
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(0x31f7:16), a
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(0x31d7:16), wa
	ld	XHL,0x00002ddc
	calr AccBuf_WriteD0WithVoice
	bit	6, (ACC_PART_FLAGS:16)
	jr nz, AccSeq_FourChannelReturn
	ld	de, (0x322b:16)
	ld	(ACC_SCAN_BAD_EVENT_COUNT:16), 0x00
	ld	(ACC_CUR_CC3:16), 0x00
	ld	wa, (0x31d9:16)
	ld	(ACC_CUR_READ_POS:16), wa
	ld	a, (0x31f8:16)
	ld	(ACC_CUR_BEAT_POS:16), a
	ld	iz, (0x31e9:16)
	ld	(ACC_CUR_BLOCK:16), iz
	ld W, 0x20:opc
	calr AccVoice_SelectByMask
	calr AccSeq_PatternScanner
	ld	wa, (ACC_CUR_BLOCK:16)
	ld	(0x31e9:16), wa
	ld	a, (ACC_CUR_BEAT_POS:16)
	ld	(0x31f8:16), a
	ld	wa, (ACC_CUR_READ_POS:16)
	ld	(0x31d9:16), wa
	ld	XHL,0x00002edc
	calr AccBuf_WriteD0WithVoice
AccSeq_FourChannelReturn:
	ret

AccStyle_Init:
	ld	a, (0x3230:16)
	and A,0x7f
	and A,0x07
	ld	(ACC_STYLE_GROUP:16), a
	ld	a, (0x322f:16)
	ld	(ACC_STYLE_NUMBER:16), a
	call AccTuning_Init
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccStyle_ExtendedInit
	ld	a, (ACC_VARIATION_NEXT:16)
	and A,0x03
	ld	(0x3280:16), a
	ld	a, (ACC_STYLE_NUMBER:16)
	ld	h, (ACC_STYLE_GROUP:16)
	call AccVoice_LookupWithOffset
	ld	(ACC_STYLE_RECORD:16), xiy
	call Rhythm_UpdateTuningConfig
	ld	a, (ACC_LANE_SECTION:16)
	ld W, 0x00:opc
	call AccPart_GetVoiceParamOffsetTable
	call AccVoice_LoadTuningBlock
	or	(ACC_LANES_RESYNC:16), 0x3f
	jr t, AccStyle_Finalize
AccStyle_ExtendedInit:
	ld	xiy, AccStyle_ExtStyleMap
	ld	a, (ACC_STYLE_NUMBER:16)
	and	a, 127
	cp	a, 29
	jr	ule, AccStyle_LookupTable
	xor	a, a
AccStyle_LookupTable:
	ld	a, (xiy+a)
	ld	(12928:16), a
	ld	a, (ACC_STYLE_NUMBER:16)
	and	a, 127
	call	AccVoice_ResolveParamAddr
	ld	(ACC_STYLE_RECORD:16), xiy
	ld	l, (xiy+16)
	ld	h, (xiy+17)
	and	h, 15
	and	a, 7
	cp	hl, 520
	jr	z, AccStyle_LoadAndApply
	cp	hl, 792
	jr	z, AccStyle_LoadAndApply
	call	VoiceParam_ClampAndValidate
AccStyle_LoadAndApply:
	ld	a, l
	call	AccVoice_LookupWithOffset
	ld	(12827:16), xiy
	call	Rhythm_UpdateTuningConfig
	ld	xiy, (ACC_STYLE_RECORD:16)
	call	AccTuning_CopyAllPartsFromStyle
	or	(ACC_LANES_RESYNC:16), 63
	ld	w, (ACC_STYLE_NUMBER:16)
	call	AccPatch_SetByChordIndex
AccStyle_Finalize:
	call AccVoice_SelectAndApplyPatch
	jr AccInit_ClearAllFlags

AccInit_ClearAllFlags:
	and	(0x3254:16), 254
	and	(ACC_VARIATION_CHANGE_PENDING:16), 254
	and	(0x3256:16), 252
	xor	a, a
	ld	(ACC_LANES_INTRO1:16), a
	ld	(ACC_LANES_COUNTIN:16), a
	ld	(ACC_LANES_INTRO2:16), a
	ld	(ACC_LANES_FILLIN1:16), a
	ld	(ACC_LANES_FILLIN2:16), a
	ld	(ACC_LANES_ENDING1:16), a
	ld	(ACC_LANES_ENDING2:16), a
	ld	(0x32a5:16), a
	ld	(0x3295:16), a
	ld	(0x3205:16), a
	ld	(0x3206:16), a
	ld	(0x3207:16), a
	ld	(0x3208:16), a
	ld	(0x3209:16), a
	ld	(0x320a:16), a
	call	AccTone_CallWithSaveAll
	ret
AccVoice_SetupAllParts:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, AccVoice_SetupAll_Extended
	ld	xiy, (ACC_STYLE_RECORD:16)
	jr t, AccVoice_SetupAll_Dispatch
AccVoice_SetupAll_Extended:
	ld	xiy, (ACC_STYLE_RECORD:16)
	ld	a, (xiy+977)
	ld	(ACC_STYLE_BANK:16), a
AccVoice_SetupAll_Dispatch:
	calr AccVoice_SetupKbd1
	calr AccVoice_SetupKbd2
	calr AccVoice_SetupAcc1
	calr AccVoice_SetupAcc2
	calr AccVoice_SetupAcc3
	calr AccVoice_SetupAcc4
	ret

AccVoice_SetupKbd1:
	and	(ACC_LANE_BEAT_POS:16), 0x0f
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccVoice_SetupKbd1_Free
	ld	(ACC_PART_BIT:16), 0x01
	ld	a, (ACC_LANE_SECTION:16)
	call AccPart_LookupBoundVoiceParam
	call AccPart_GetParamAddr
	ld	(ACC_LANE_READ_POS:16), wa
	jr t, AccVoice_SetupKbd1_Return
AccVoice_SetupKbd1_Free:
	ld	(ACC_PART_BIT:16), 1
	call	AccPart_GetFreeVoiceAddr
	ld	(ACC_LANE_BLOCK:16), wa
	ldw	(ACC_LANE_READ_POS:16), 6
AccVoice_SetupKbd1_Return:
	ret

AccVoice_SetupKbd2:
	and	(0x31f4:16), 0x0f
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccVoice_SetupKbd2_Free
	ld	(ACC_PART_BIT:16), 0x02
	ld	a, (0x31ec:16)
	call AccPart_LookupBoundVoiceParam
	call AccPart_GetParamAddr
	ld	(0x31d1:16), wa
	jr t, AccVoice_SetupKbd2_Return
AccVoice_SetupKbd2_Free:
	ld	(ACC_PART_BIT:16), 2
	call	AccPart_GetFreeVoiceAddr
	ld	(12769:16), wa
	ldw	(12753:16), 6
AccVoice_SetupKbd2_Return:
	ret

AccVoice_SetupAcc1:
	and	(0x31f5:16), 0x0f
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccVoice_SetupAcc1_Free
	ld	(ACC_PART_BIT:16), 0x04
	ld	a, (0x31ed:16)
	call AccPart_LookupBoundVoiceParam
	call AccPart_GetParamAddr
	ld	(0x31d3:16), wa
	jr t, AccVoice_SetupAcc1_Return
AccVoice_SetupAcc1_Free:
	ld	(ACC_PART_BIT:16), 4
	call	AccPart_GetFreeVoiceAddr
	ld	(12771:16), wa
	ldw	(12755:16), 6
AccVoice_SetupAcc1_Return:
	ret

AccVoice_SetupAcc2:
	and	(0x31f6:16), 0x0f
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccVoice_SetupAcc2_Free
	ld	(ACC_PART_BIT:16), 0x08
	ld	a, (0x31ee:16)
	call AccPart_LookupBoundVoiceParam
	call AccPart_GetParamAddr
	ld	(0x31d5:16), wa
	jr t, AccVoice_SetupAcc2_Return
AccVoice_SetupAcc2_Free:
	ld	(ACC_PART_BIT:16), 8
	call	AccPart_GetFreeVoiceAddr
	ld	(12773:16), wa
	ldw	(12757:16), 6
AccVoice_SetupAcc2_Return:
	ret

AccVoice_SetupAcc3:
	and	(0x31f7:16), 0x0f
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccVoice_SetupAcc3_Free
	ld	(ACC_PART_BIT:16), 0x10
	ld	a, (0x31ef:16)
	call AccPart_LookupBoundVoiceParam
	call AccPart_GetParamAddr
	ld	(0x31d7:16), wa
	jr t, AccVoice_SetupAcc3_Return
AccVoice_SetupAcc3_Free:
	ld	(ACC_PART_BIT:16), 16
	call	AccPart_GetFreeVoiceAddr
	ld	(12775:16), wa
	ldw	(12759:16), 6
AccVoice_SetupAcc3_Return:
	ret

AccVoice_SetupAcc4:
	and	(0x31f8:16), 0x0f
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccVoice_SetupAcc4_Free
	ld	(ACC_PART_BIT:16), 0x20
	ld	a, (0x31f0:16)
	call AccPart_LookupBoundVoiceParam
	call AccPart_GetParamAddr
	ld	(0x31d9:16), wa
	jrl t, AccVoice_SetupAcc4_Return
AccVoice_SetupAcc4_Free:
	ld	(ACC_PART_BIT:16), 32
	call	AccPart_GetFreeVoiceAddr
	ld	(12777:16), wa
	ldw	(12761:16), 6
AccVoice_SetupAcc4_Return:
	ret

AccSection_StartIntro:
	and	(ACC_LANE_BEAT_POS:16), 0x0f
	and	(0x31f4:16), 0x0f
	and	(0x31f5:16), 0x0f
	and	(0x31f6:16), 0x0f
	and	(0x31f7:16), 0x0f
	and	(0x31f8:16), 0x0f
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, AccSection_StartIntro_UseStyle
	bit	0, (0x32ab:16)
	jr z, AccSection_StartIntro_UseSecondary
	calr AccSection_StartComposerIntro
	jr t, AccSection_StartIntro_SetMasks
AccSection_StartIntro_UseSecondary:
	ld	xiy, (12827:16)
	jr	AccSection_StartIntro_SelectMode
AccSection_StartIntro_UseStyle:
	ld	xiy, (ACC_STYLE_RECORD:16)
AccSection_StartIntro_SelectMode:
	ldw	hl, 32
	bit	0, (ACC_PENDING_INTRO:16)
	jr	nz, AccSection_StartIntro_LoadParams
	ldw	hl, 34
	bit	2, (ACC_PENDING_INTRO:16)
	jr	nz, AccSection_StartIntro_LoadParams
	ldw	hl, 1056
AccSection_StartIntro_LoadParams:
	calr	AccVoice_LoadAllParts
	cp	(ACC_STYLE_NUMBER:16), 128
	jr	c, AccSection_StartIntro_Extended
	ld	xiy, (ACC_STYLE_RECORD:16)
	call	AccTuning_CopyAllPartsFromStyle
	jr	AccSection_StartIntro_ApplyAll
AccSection_StartIntro_Extended:
	ld	a, (ACC_LANE_SECTION:16)
	ld	w, 3:opc
	bit	3, (ACC_PENDING_INTRO:16)
	jr	z, AccSection_StartIntro_SetMode
	ld	w, 4:opc
AccSection_StartIntro_SetMode:
	call AccPart_GetVoiceParamOffsetTable
	call AccVoice_LoadTuningBlock

AccSection_StartIntro_ApplyAll:
	; ordi8 0x332c, 63 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 63
AccSection_StartIntro_SetMasks:
	bit	3, (ACC_PENDING_INTRO:16)
	jrl	nz, AccSection_StartIntro_Mode3
	bit	2, (ACC_PENDING_INTRO:16)
	jr	nz, AccSection_StartIntro_Mode2
	and	(ACC_PENDING_INTRO:16), 254
	or	(ACC_LANES_INTRO1:16), 63
	xor	a, a
	ld	(ACC_LANES_FILLIN1:16), a
	ld	(ACC_LANES_FILLIN2:16), a
	ld	(ACC_LANES_COUNTIN:16), a
	ld	(ACC_LANES_INTRO2:16), a
	ld	(ACC_LANES_ENDING1:16), a
	ld	(ACC_LANES_ENDING2:16), a
	ld	(0x32a5:16), a
	ld	(ACC_LANES_ENDED:16), a
	ld	(ACC_LANES_PARKED:16), a
	and	(ACC_RUN_FLAGS:16), 251
	jrl	AccSection_StartIntro_Return
AccSection_StartIntro_Mode2:
	and	(ACC_PENDING_INTRO:16), 251
	or	(ACC_LANES_COUNTIN:16), 63
	xor	a, a
	ld	(ACC_LANES_FILLIN1:16), a
	ld	(ACC_LANES_FILLIN2:16), a
	ld	(ACC_LANES_INTRO1:16), a
	ld	(ACC_LANES_INTRO2:16), a
	ld	(ACC_LANES_ENDING1:16), a
	ld	(ACC_LANES_ENDING2:16), a
	ld	(0x32a5:16), a
	ld	(ACC_LANES_ENDED:16), a
	ld	(ACC_LANES_PARKED:16), a
	and	(ACC_RUN_FLAGS:16), 251
	jr	AccSection_StartIntro_Return
AccSection_StartIntro_Mode3:
	and	(ACC_PENDING_INTRO:16), 247
	or	(ACC_LANES_INTRO2:16), 63
	xor	a, a
	ld	(ACC_LANES_FILLIN1:16), a
	ld	(ACC_LANES_FILLIN2:16), a
	ld	(ACC_LANES_INTRO1:16), a
	ld	(ACC_LANES_COUNTIN:16), a
	ld	(ACC_LANES_ENDING1:16), a
	ld	(ACC_LANES_ENDING2:16), a
	ld	(0x32a5:16), a
	ld	(ACC_LANES_ENDED:16), a
	ld	(ACC_LANES_PARKED:16), a
	and	(ACC_RUN_FLAGS:16), 251
AccSection_StartIntro_Return:
	ret

AccSection_StartComposerIntro:
	bit	3, (ACC_PENDING_INTRO:16)
	jrl nz, AccSection_StartComposerIntro_Mode3
	bit	2, (ACC_PENDING_INTRO:16)
	jr nz, AccSection_StartComposerIntro_Mode2
	ld	a, (ACC_STYLE_NUMBER:16)
	and A,0x7f
	call AccPatch_SetVoiceParam
	cp	a, (0x32ac:16)
	jr z, AccSection_StartComposerIntro_MatchA
	and (0xfc5f:16), 0xfb
	ld E, 0x48:opc
	ld D, 0x05:opc
	ld W, 0x00:opc
	ld A, 0x00:opc
	call Rhythm_QueuePartChangeEvent
	ld	xiy, (ACC_STYLE_RECORD:16)
	jr t, AccSection_StartComposerIntro_Apply
AccSection_StartComposerIntro_MatchA:
	ld	a, (12973:16)
	call	AccVoice_ResolveParamAddr
	jr	AccSection_StartComposerIntro_Apply
AccSection_StartComposerIntro_Mode2:
	ld	a, (ACC_STYLE_NUMBER:16)
	and	a, 127
	call	AccPatch_SetVoiceParam
	ld	xhl, AccStyle_ApplyExt_SkipClamp_Table
	bit_dri	1, 0x03, 0xec, 0xe0
	jr	z, AccSection_StartComposerIntro_Fallback
	and	(0xfc5f:16), 247
	ld	e, 72:opc
	ld	d, 5:opc
	ld	w, 0:opc
	ld	a, 0:opc
	call	Rhythm_QueuePartChangeEvent
	ld	xiy, (ACC_STYLE_RECORD:16)
	jr	AccSection_StartComposerIntro_Apply
AccSection_StartComposerIntro_Mode3:
	ld	a, (ACC_STYLE_NUMBER:16)
	and A,0x7f
	call AccPatch_SetVoiceParam
	cp	a, (0x32ae:16)
	jr z, AccSection_StartComposerIntro_MatchB
	and (0xfc60:16), 0xfb
	ld E, 0x48:opc
	ld D, 0x06:opc
	ld W, 0x00:opc
	ld A, 0x00:opc
	call Rhythm_QueuePartChangeEvent
	ld	xiy, (ACC_STYLE_RECORD:16)
	jr t, AccSection_StartComposerIntro_Apply
AccSection_StartComposerIntro_MatchB:
	ld	a, (12975:16)
	call	AccVoice_ResolveParamAddr
AccSection_StartComposerIntro_Apply:
	calr	AccInit_AllPartPositions
	call	AccTuning_CopyAllPartsFromStyle
	or	(ACC_LANES_RESYNC:16), 63
	jr	AccSection_StartComposerIntro_Return
AccSection_StartComposerIntro_Fallback:
	ld	xiy, (12827:16)

	ldw hl, 0x22

	; calr AccVoice_LoadAllParts (v7 displacement)
	calr	AccVoice_LoadAllParts
	xor xhl, xhl

	ldw hl, 0x126

	; call AccVoice_LoadTuningBlock (v7 addr)
	call	AccVoice_LoadTuningBlock
	; ordi8 0x332c, 63 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 63
AccSection_StartComposerIntro_Return:
	ret

AccSection_StartFillIn:
	and	(ACC_LANE_BEAT_POS:16), 0x0f
	and	(0x31f4:16), 0x0f
	and	(0x31f5:16), 0x0f
	and	(0x31f6:16), 0x0f
	and	(0x31f7:16), 0x0f
	and	(0x31f8:16), 0x0f
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, AccSection_StartFillIn_UseStyle
	bit	0, (0x32ab:16)
	jr z, AccSection_StartFillIn_UseSecondary
	calr AccSection_StartComposerFillIn
	jr t, AccSection_StartFillIn_SetForward
AccSection_StartFillIn_UseSecondary:
	ld	xiy, (12827:16)
	jr	AccSection_StartFillIn_LoadAndApply
AccSection_StartFillIn_UseStyle:
	ld	xiy, (ACC_STYLE_RECORD:16)
AccSection_StartFillIn_LoadAndApply:
	ld	a, (ACC_LANE_SECTION:16)
	call	AccVoice_ComputeParamAddr
	calr	AccVoice_LoadAllParts
	ld	a, (ACC_LANE_SECTION:16)
	call	AccTuning_SetAllFromLookup
	cp	(ACC_STYLE_NUMBER:16), 128
	jr	c, AccSection_StartFillIn_StyleMode
	ld	xiy, (ACC_STYLE_RECORD:16)
	call	AccTuning_CopyAllPartsFromStyle
	jr	AccSection_StartFillIn_Apply63
AccSection_StartFillIn_StyleMode:
	ld	a, (ACC_LANE_SECTION:16)
	ld	w, 2:opc
	call	AccPart_GetVoiceParamOffsetTable
	call	AccVoice_LoadTuningBlock
AccSection_StartFillIn_Apply63:
	; ordi8 0x332c, 63 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 63
AccSection_StartFillIn_SetForward:
	bit	0, (ACC_PENDING_FILLIN:16)
	jr	z, AccSection_StartFillIn_SetReverse
	and	(ACC_PENDING_FILLIN:16), 254
	or	(ACC_LANES_FILLIN1:16), 63
	xor	a, a
	ld	(ACC_LANES_INTRO1:16), a
	ld	(ACC_LANES_COUNTIN:16), a
	ld	(ACC_LANES_INTRO2:16), a
	ld	(ACC_LANES_FILLIN2:16), a
	ld	(ACC_LANES_ENDING1:16), a
	ld	(ACC_LANES_ENDING2:16), a
	ld	(0x32a5:16), a
	ld	(ACC_LANES_ENDED:16), a
	ld	(ACC_LANES_PARKED:16), a
	and	(ACC_RUN_FLAGS:16), 251
	jr	AccSection_StartFillIn_Return
AccSection_StartFillIn_SetReverse:
	and	(ACC_PENDING_FILLIN:16), 253
	or	(ACC_LANES_FILLIN2:16), 63
	xor	a, a
	ld	(ACC_LANES_INTRO1:16), a
	ld	(ACC_LANES_COUNTIN:16), a
	ld	(ACC_LANES_INTRO2:16), a
	ld	(ACC_LANES_FILLIN1:16), a
	ld	(ACC_LANES_ENDING1:16), a
	ld	(ACC_LANES_ENDING2:16), a
	ld	(0x32a5:16), a
	ld	(ACC_LANES_ENDED:16), a
	ld	(ACC_LANES_PARKED:16), a
	and	(ACC_RUN_FLAGS:16), 251
AccSection_StartFillIn_Return:
	ret

AccSection_StartComposerFillIn:
	bit	0, (ACC_PENDING_FILLIN:16)
	jr z, AccSection_StartComposerFillIn_Reverse
	ld	a, (ACC_STYLE_NUMBER:16)
	and A,0x7f
	call AccPatch_SetVoiceParam
	cp	a, (0x32b0:16)
	jr z, AccSection_StartComposerFillIn_MatchFwd
	and (0xfc5f:16), 0xbf
	ld E, 0x48:opc
	ld D, 0x05:opc
	ld W, 0x00:opc
	ld A, 0x00:opc
	call Rhythm_QueuePartChangeEvent
	ld	xiy, (ACC_STYLE_RECORD:16)
	jr t, AccSection_StartComposerFillIn_Apply
AccSection_StartComposerFillIn_MatchFwd:
	ld	a, (12977:16)
	call	AccVoice_ResolveParamAddr
	jr	AccSection_StartComposerFillIn_Apply
AccSection_StartComposerFillIn_Reverse:
	ld	a, (ACC_STYLE_NUMBER:16)
	and	a, 127
	call	AccPatch_SetVoiceParam
	cp	a, (0x32b2:16)
	jr	z, AccSection_StartComposerFillIn_MatchRev
	and	(0xfc5f:16), 127
	ld	e, 72:opc
	ld	d, 5:opc
	ld	w, 0:opc
	ld	a, 0:opc
	call	Rhythm_QueuePartChangeEvent
	ld	xiy, (ACC_STYLE_RECORD:16)
	jr	AccSection_StartComposerFillIn_Apply
AccSection_StartComposerFillIn_MatchRev:
	ld	a, (12979:16)
	call	AccVoice_ResolveParamAddr
AccSection_StartComposerFillIn_Apply:
	; calr AccInit_AllPartPositions (v7 displacement)
	calr	AccInit_AllPartPositions
	; call AccTuning_CopyAllPartsFromStyle (v7 addr)
	call	AccTuning_CopyAllPartsFromStyle
	; ordi8 0x332c, 63 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 63
	ret



AccVoice_LoadAllParts:
	.byte	0xc3, 0xf5, 0xd1, 0x03, 0x21, 0xf1, 0xcd, 0x31
	.byte	0x41, 0xd7, 0x3c, 0x9b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x01, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xcf, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x02, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd1, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x04, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd3, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x08, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd5, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x10, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd7, 0x31
	.byte	0x50, 0xd7, 0x3c, 0x8b, 0xf1, 0x1c, 0x33, 0x00
	.byte	0x20, 0x1d, 0xed, 0x60, 0xf5, 0xf1, 0xd9, 0x31
	.byte 0x50, 0x0e
AccInit_AllPartPositions:
	ld	(ACC_PART_BIT:16), 1
	call	AccPart_GetFreeVoiceAddr
	ld	(ACC_LANE_BLOCK:16), wa
	ldw	(ACC_LANE_READ_POS:16), 6
	ld	(ACC_PART_BIT:16), 4
	call	AccPart_GetFreeVoiceAddr
	ld	(12771:16), wa
	ldw	(12755:16), 6
	ld	(ACC_PART_BIT:16), 8
	call	AccPart_GetFreeVoiceAddr
	ld	(12773:16), wa
	ldw	(12757:16), 6
	ld	(ACC_PART_BIT:16), 16
	call	AccPart_GetFreeVoiceAddr
	ld	(12775:16), wa
	ldw	(12759:16), 6
	ld	(ACC_PART_BIT:16), 32
	call	AccPart_GetFreeVoiceAddr
	ld	(12777:16), wa
	ldw	(12761:16), 6
	ld	(ACC_PART_BIT:16), 2
	call	AccPart_GetFreeVoiceAddr
	ld	(12769:16), wa
	ldw	(12753:16), 6
	ret
AccSection_StartEnding:
	and	(ACC_LANE_BEAT_POS:16), 0x0f
	and	(0x31f4:16), 0x0f
	and	(0x31f5:16), 0x0f
	and	(0x31f6:16), 0x0f
	and	(0x31f7:16), 0x0f
	and	(0x31f8:16), 0x0f
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, AccSection_StartEnding_Style
	bit	0, (0x32ab:16)
	jr z, AccSection_StartEnding_Secondary
	calr AccSection_StartComposerEnding
	jr t, AccSection_StartEnding_SetMasks
AccSection_StartEnding_Secondary:
	ld	xiy, (12827:16)
	jr	AccSection_StartEnding_SelectMode
AccSection_StartEnding_Style:
	ld	xiy, (ACC_STYLE_RECORD:16)
AccSection_StartEnding_SelectMode:
	ldw	hl, 36
	bit	0, (ACC_PENDING_ENDING:16)
	jr	nz, AccSection_StartEnding_LoadParams
	ldw	hl, 1060
AccSection_StartEnding_LoadParams:
	calr	AccVoice_LoadAllParts
	ld	a, (ACC_LANE_SECTION:16)
	call	AccTuning_SetAllFromLookup
	cp	(ACC_STYLE_NUMBER:16), 128
	jr	c, AccSection_StartEnding_StyleMode
	ld	xiy, (ACC_STYLE_RECORD:16)
	call	AccTuning_CopyAllPartsFromStyle
	jr	AccSection_StartEnding_Apply
AccSection_StartEnding_StyleMode:
	ld	a, (ACC_LANE_SECTION:16)
	ld	w, 5:opc
	bit	1, (ACC_PENDING_ENDING:16)
	jr	z, AccSection_StartEnding_SetModeW
	ld	w, 6:opc
AccSection_StartEnding_SetModeW:
	call AccPart_GetVoiceParamOffsetTable
	call AccVoice_LoadTuningBlock

AccSection_StartEnding_Apply:
	; ordi8 0x332c, 63 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 63
AccSection_StartEnding_SetMasks:
	bit	0, (ACC_PENDING_ENDING:16)
	jr	z, AccSection_StartEnding_Reverse
	and	(ACC_PENDING_ENDING:16), 254
	or	(ACC_LANES_ENDING1:16), 63
	xor	a, a
	ld	(ACC_LANES_INTRO1:16), a
	ld	(ACC_LANES_COUNTIN:16), a
	ld	(ACC_LANES_INTRO2:16), a
	ld	(ACC_LANES_FILLIN1:16), a
	ld	(ACC_LANES_FILLIN2:16), a
	ld	(ACC_LANES_ENDING2:16), a
	ld	(0x32a5:16), a
	jr	AccSection_StartEnding_Return
AccSection_StartEnding_Reverse:
	and	(ACC_PENDING_ENDING:16), 253
	or	(ACC_LANES_ENDING2:16), 63
	xor	a, a
	ld	(ACC_LANES_INTRO1:16), a
	ld	(ACC_LANES_COUNTIN:16), a
	ld	(ACC_LANES_INTRO2:16), a
	ld	(ACC_LANES_FILLIN1:16), a
	ld	(ACC_LANES_FILLIN2:16), a
	ld	(ACC_LANES_ENDING1:16), a
	ld	(0x32a5:16), a
AccSection_StartEnding_Return:
	ret

AccSection_StartComposerEnding:
	bit	0, (ACC_PENDING_ENDING:16)
	jr z, AccSection_StartComposerEnding_Reverse
	ld	a, (ACC_STYLE_NUMBER:16)
	and A,0x7f
	call AccPatch_SetVoiceParam
	cp	a, (0x32b4:16)
	jr z, AccSection_StartComposerEnding_MatchFwd
	and (0xfc5f:16), 0xef
	ld E, 0x48:opc
	ld D, 0x05:opc
	ld W, 0x00:opc
	ld A, 0x00:opc
	call Rhythm_QueuePartChangeEvent
	ld	xiy, (ACC_STYLE_RECORD:16)
	jr t, AccSection_StartComposerEnding_Apply
AccSection_StartComposerEnding_MatchFwd:
	ld	a, (12981:16)
	call	AccVoice_ResolveParamAddr
	jr	AccSection_StartComposerEnding_Apply
AccSection_StartComposerEnding_Reverse:
	ld	a, (ACC_STYLE_NUMBER:16)
	and	a, 127
	call	AccPatch_SetVoiceParam
	cp	a, (0x32b6:16)
	jr	z, AccSection_StartComposerEnding_MatchRev
	and	(0xfc5f:16), 223
	ld	e, 72:opc
	ld	d, 5:opc
	ld	w, 0:opc
	ld	a, 0:opc
	call	Rhythm_QueuePartChangeEvent
	ld	xiy, (ACC_STYLE_RECORD:16)
	jr	AccSection_StartComposerEnding_Apply
AccSection_StartComposerEnding_MatchRev:
	ld	a, (12983:16)
	call	AccVoice_ResolveParamAddr
AccSection_StartComposerEnding_Apply:
	; calr AccInit_AllPartPositions (v7 displacement)
	calr	AccInit_AllPartPositions
	; call AccTuning_CopyAllPartsFromStyle (v7 addr)
	call	AccTuning_CopyAllPartsFromStyle
	; ordi8 0x332c, 63 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 63
	ret



AccBuf_WriteAllNotesOff:
	ld	XHL,0x000029dc
	ld IY,(XHL+0x04)
	ld BC,(XHL+0x02)
	ld	(xhl+iy), 0x9f	; (unidasm; no llvm-mc spelling)
call	RingBuf_AdvanceIndex
	ld	a, (0x3232:16)
	ld	(0x3376:16), a
call	RhythmAccent_UpdateRingBufPosition
	ld	a, 127:opc
	ld	(xhl+iy), a
call	RingBuf_AdvanceIndex
	ld	(xhl+iy), a
call	RingBuf_AdvanceIndex
	ld	(xhl+4), iy
	ret
AccBuf_AllNotesOffPadding:
	nop
	nop

AccBuf_ResetAll4:
	ld	xhl, 11228
	calr	AccBuf_DrainAndReset
	ld	xhl, 11484
	calr	AccBuf_DrainAndReset
	ld	xhl, 11740
	calr	AccBuf_DrainAndReset
	ld	xhl, 11996
	calr	AccBuf_DrainAndReset
	ret
AccBuf_DrainAndReset:
	ld iy, (xhl + 6)
	ld bc, (xhl + 2)

AccBuf_DrainReset_Loop:
	cp iy, (xhl + 4)
	jr z, AccBuf_DrainReset_Done
	ld	a, (xhl+iy)
	cp a, 0xd0
	jr z, AccBuf_DrainReset_D0Found
	call RingBuf_AdvanceIndex
	jr AccBuf_DrainReset_Loop

AccBuf_DrainReset_D0Found:
	call RingBuf_AdvanceIndex
	call RingBuf_AdvanceIndex
	ld	a, (xhl+iy)
	cp a, 2:i3
	jr nz, AccBuf_DrainReset_Sub1
	call RingBuf_AdvanceIndex
	ld	(xhl+iy), 0x40
	call RingBuf_AdvanceIndex
	jr AccBuf_DrainReset_Loop

AccBuf_DrainReset_Sub1:
	cp a, 1:i3
	jr nz, AccBuf_DrainReset_Sub3
	call RingBuf_AdvanceIndex
	ld	(xhl+iy), 0x00
	call RingBuf_AdvanceIndex
	jr AccBuf_DrainReset_Loop

AccBuf_DrainReset_Sub3:
	cp a, 3:i3
	jr nz, AccBuf_DrainReset_Sub5
	call RingBuf_AdvanceIndex
	ld	(xhl+iy), 0x00
	call RingBuf_AdvanceIndex
	jr AccBuf_DrainReset_Loop

AccBuf_DrainReset_Sub5:
	cp a, 5:i3
	jr nz, AccBuf_DrainReset_Other
	call RingBuf_AdvanceIndex
	ld	(xhl+iy), 0x7f
	call RingBuf_AdvanceIndex
	jr AccBuf_DrainReset_Loop

AccBuf_DrainReset_Other:
	call RingBuf_AdvanceIndex
	jr AccBuf_DrainReset_Loop

AccBuf_DrainReset_Done:
	ret

AccTiming_CallHelper:
	bit	1, (0x31cc:16)
	jr z, AccTiming_HelperReturn
	call SeqEvt_CallTimingHelper
	call Voice_UpdatePlayModeState
	call AccChord_ReadAndStoreKeys
	call AccChord_CompareAndSetDirty
	call Rhythm_CompareAndTrigger
AccTiming_HelperReturn:
	ret

AccVoice_SelectByMask:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, AccVoice_SelectByMask_Default
	ldfr_berp w, 0x31
	and	w, (ACC_LANES_COUNTIN:16)
	jr nz, AccVoice_SelectByMask_Default
	bit	0, (0x32ab:16)
	jr nz, AccVoice_SelectByMask_Direct
	ld	a, (ACC_LANES_INTRO1:16)
	or	a, (ACC_LANES_INTRO2:16)
	or	a, (ACC_LANES_FILLIN1:16)
	or	a, (ACC_LANES_FILLIN2:16)
	or	a, (ACC_LANES_ENDING1:16)
	or	a, (ACC_LANES_ENDING2:16)
	or	a, (ACC_LANES_ENDED:16)
	andb_erp	a, 49
	jr	nz, AccVoice_SelectByMask_Default
AccVoice_SelectByMask_Direct:
	calr AccWave_BankResolve
	jr AccVoice_SelectReturn

AccVoice_SelectByMask_Default:
	ld	a, (ACC_STYLE_BANK:16)
	call	AccVoice_TableLookup
AccVoice_SelectReturn:
	ret

AccWave_BankResolve_Short:
	cp	iz, 0xfffe
	jr	nz, AccWave_BankResolve_Short_Skip
	ld	xhl, 0x095bc0
	jr	AccWave_BankResolve_Short_Return
AccWave_BankResolve_Short_Skip:
	extz	xiz
	ld	xhl, xiz
	sla	xhl, 8
	add	xhl, RHYTHM_PATTERN_BUF_B
AccWave_BankResolve_Short_Return:
	ret

AccWave_BankResolve:
	push xwa
	push xix
	push xiz
	cp iz, 0xfffe
	jr nz, AccWave_BankResolve_Normal
	ld xhl, 0x95bc0
	jr AccWave_BankResolve_Epilogue

AccWave_BankResolve_Normal:
	ld wa, iz
	and iz, 0xfff
	extz xiz
	ld xhl, xiz
	sla xhl, 8
	srl wa, 10
	ld xix, AccWave_BankTable
	ld	xix, (xix+wa)
	add xhl, xix

AccWave_BankResolve_Epilogue:
	pop xiz
	pop xix
	pop xwa
	ret

AccWave_BankTable:
	.byte 0x00, 0x5c, 0x09, 0x00, 0x00, 0x14, 0x30, 0x00
	.byte 0x00, 0xac, 0x31, 0x00, 0x00, 0x14, 0x33, 0x00
	.byte 0x00, 0xac, 0x34, 0x00, 0x00, 0x14, 0x36, 0x00
	.byte 0x00, 0xac, 0x37, 0x00, 0x00, 0x14, 0x39, 0x00

AccVoice_TableLookup:
	call AccVoice_TableLookup_Inner
	add xhl, 0x8000
	ret

AccVoice_TableLookup_Inner:
	cp a, 0x3f
	jr ule, AccVoice_TableLookup_Compute
	xor a, a

AccVoice_TableLookup_Compute:
	xor	xhl, xhl
	xor	w, w
	ld	hl, wa
	sll	xhl, 2
	add	xhl, AccVoice_OffsetTable
	ld	xhl, (xhl)
	add	xhl, (RHYTHM_ROM_BASE:16)
	ret
AccVoice_OffsetTable:
	.byte 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x41, 0x00
	.byte 0x00, 0x00, 0x42, 0x00, 0x00, 0x00, 0x43, 0x00
	.byte 0x00, 0x00, 0x44, 0x00, 0x00, 0x00, 0x45, 0x00
	.byte 0x00, 0x00, 0x46, 0x00, 0x00, 0x00, 0x47, 0x00
	.byte 0x00, 0x00, 0x48, 0x00, 0x00, 0x00, 0x49, 0x00
	.byte 0x00, 0x00, 0x4a, 0x00, 0x00, 0x00, 0x4b, 0x00
	.byte 0x00, 0x00, 0x4c, 0x00, 0x00, 0x00, 0x4d, 0x00
	.byte 0x00, 0x00, 0x4e, 0x00, 0x00, 0x00, 0x4f, 0x00
	.byte 0x00, 0x00, 0x50, 0x00, 0x00, 0x00, 0x51, 0x00
	.byte 0x00, 0x00, 0x52, 0x00, 0x00, 0x00, 0x53, 0x00
	.byte 0x00, 0x00, 0x54, 0x00, 0x00, 0x00, 0x55, 0x00
	.byte 0x00, 0x00, 0x56, 0x00, 0x00, 0x00, 0x57, 0x00
	.byte 0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x59, 0x00
	.byte 0x00, 0x00, 0x5a, 0x00, 0x00, 0x00, 0x5b, 0x00
	.byte 0x00, 0x00, 0x5c, 0x00, 0x00, 0x00, 0x5d, 0x00
	.byte 0x00, 0x00, 0x5e, 0x00, 0x00, 0x00, 0x5f, 0x00
	.byte 0x00, 0x00, 0x60, 0x00, 0x00, 0x00, 0x61, 0x00
	.byte 0x00, 0x00, 0x62, 0x00, 0x00, 0x00, 0x63, 0x00
	.byte 0x00, 0x00, 0x64, 0x00, 0x00, 0x00, 0x65, 0x00
	.byte 0x00, 0x00, 0x66, 0x00, 0x00, 0x00, 0x67, 0x00
	.byte 0x00, 0x00, 0x68, 0x00, 0x00, 0x00, 0x69, 0x00
	.byte 0x00, 0x00, 0x6a, 0x00, 0x00, 0x00, 0x6b, 0x00
	.byte 0x00, 0x00, 0x6c, 0x00, 0x00, 0x00, 0x6d, 0x00
	.byte 0x00, 0x00, 0x6e, 0x00, 0x00, 0x00, 0x6f, 0x00
	.byte 0x00, 0x00, 0x70, 0x00, 0x00, 0x00, 0x71, 0x00
	.byte 0x00, 0x00, 0x72, 0x00, 0x00, 0x00, 0x73, 0x00
	.byte 0x00, 0x00, 0x74, 0x00, 0x00, 0x00, 0x75, 0x00
	.byte 0x00, 0x00, 0x76, 0x00, 0x00, 0x00, 0x77, 0x00
	.byte 0x00, 0x00, 0x78, 0x00, 0x00, 0x00, 0x79, 0x00
	.byte 0x00, 0x00, 0x7a, 0x00, 0x00, 0x00, 0x7b, 0x00
	.byte 0x00, 0x00, 0x7c, 0x00, 0x00, 0x00, 0x7d, 0x00
	.byte 0x00, 0x00, 0x7e, 0x00, 0x00, 0x00, 0x7f, 0x00

AccEnding_StopWhenSilent:
	bit 3, (ACC_TRANSPORT_STATE:16)

	jrl nz, AccState_CollectReturn

	bit 2, (ACC_TRANSPORT_STATE:16)

	jrl z, AccState_CollectReturn

	ld	xhl, ACC_DRUM1_NOTES

	xor iy, iy

	ld	a, (xhl+iy)



AccState_CollectKbd1_Loop:
	or	a, (xhl+iy)
	add	iy, 6
	cp	iy, 48
	jr	c, AccState_CollectKbd1_Loop
	ld	xhl, ACC_DRUM2_NOTES
	xor	iy, iy
AccState_CollectKbd2_Loop:
	or	a, (xhl+iy)
	add	iy, 6
	cp	iy, 48
	jr	c, AccState_CollectKbd2_Loop
	ld	xhl, ACC_BASS_NOTES
	xor	iy, iy
AccState_CollectAcc1_Loop:
	or	a, (xhl+iy)
	add	iy, 9
	cp	iy, 72
	jr	c, AccState_CollectAcc1_Loop
	ld	xhl, ACC_ACCOMP1_NOTES
	xor	iy, iy
AccState_CollectAcc2_Loop:
	or	a, (xhl+iy)
	add	iy, 9
	cp	iy, 72
	jr	c, AccState_CollectAcc2_Loop
	ld	xhl, ACC_ACCOMP2_NOTES
	xor	iy, iy
AccState_CollectAcc3_Loop:
	or	a, (xhl+iy)
	add	iy, 9
	cp	iy, 72
	jr	c, AccState_CollectAcc3_Loop
	ld	xhl, ACC_ACCOMP3_NOTES
	xor	iy, iy
AccState_CollectAcc4_Loop:
	or	a, (xhl+iy)
	add iy, 0x9
	cp iy, 0x48
	jr c, AccState_CollectAcc4_Loop
	bit 7, a
	jr nz, AccState_CollectReturn
	cpw (SEQ_ACTIVE_PARTS:16), 0
	jr nz, AccState_CollectAcc4_Active
	cpw	(SEQ_REC_TRACKS:16), 0
	jr nz, AccState_CollectAcc4_Active
	call AccWrap_PlayModeStopPlayAndAcc
	jr AccState_Apply

AccState_CollectAcc4_Active:
	call AccWrap_PlayModeStopAcc

AccState_Apply:
	call	AccInit_SendNoteOffAndFlush
	ld	a, (CHORD_TYPE:16)
	ld	(DISPLAY_CHORD_TYPE:16), a
	ld	a, (CHORD_ROOT:16)
	ld	(DISPLAY_CHORD_ROOT:16), a
	call	AccDisplay_RefreshIfDiskActive
	and	(PANEL_STYLE+5:16), 207
	and	(ACC_RUN_FLAGS:16), 251
	xor	a, a
	ld	(ACC_LANES_ENDING1:16), a
	ld	(ACC_LANES_ENDING2:16), a
	ld	(ACC_LANES_FILLIN1:16), a
	ld	(ACC_LANES_FILLIN2:16), a
	ld	(ACC_LANES_INTRO1:16), a
	ld	(ACC_LANES_COUNTIN:16), a
	ld	(ACC_LANES_INTRO2:16), a
	or	(0x33e7:16), 2
AccState_CollectReturn:
	ret

AccState_ScanLookupTable:
	nop
	normal
	push sr
	pop sr
	max
	nop
	normal
	push sr
	pop sr
	max
	nop
	normal
	push sr
	pop sr
	max
	nop
	normal
	push sr
	pop sr
	max
	nop
	nop
	nop
	nop
	.zero 10

AccVoice_ScanForD3:
	ld	a, (xhl+iy)
	cp	a, 131
	jr	z, AccVoice_ScanDone2	; -> 0xF58F11
	cp	a, 211
	jr	nz, AccVoice_ScanSkip	; -> 0xF58F0B
	call	AccBuf_Advance
	call	AccBuf_Advance
	ld	a, (xhl+iy)
	ld	(ACC_CUR_CC3:16), a
AccVoice_ScanSkip:
	call AccBuf_Advance
	jr AccVoice_ScanForD3

AccVoice_ScanDone2:
	ret

AccVoice_SetupByteData:
	ld	(ACC_PART_BIT:16), 4
	ld	e, (0x3291:16)
	ld	(ACC_CUR_CC3:16), 0
AccVoice_ScanForD3_Join:
	ld	xiy, (ACC_STYLE_RECORD:16)
	cp	e, (0x31ed:16)
	jr	z, AccVoice_ScanForD3_Return
	ld	a, e
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	iy, wa
	ld	a, (ACC_STYLE_BANK:16)
	call	AccVoice_TableLookup
	call	AccVoice_ScanForD3
	inc	1, e
	jr	AccVoice_ScanForD3_Join
AccVoice_ScanForD3_Return:
	ret
	ld	(ACC_PART_BIT:16), 8
	ld	e, (0x3291:16)
	ld	(ACC_CUR_CC3:16), 0
AccVoice_ScanForD3_Join2:
	ld	xiy, (ACC_STYLE_RECORD:16)
	cp	e, (0x31ee:16)
	jr	z, AccVoice_ScanForD3_Return2
	ld	a, e
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	iy, wa
	ld	a, (ACC_STYLE_BANK:16)
	call	AccVoice_TableLookup
	call	AccVoice_ScanForD3
	inc	1, e
	jr	AccVoice_ScanForD3_Join2
AccVoice_ScanForD3_Return2:
	ret
	ld	(ACC_PART_BIT:16), 8
	ld	e, (0x3291:16)
	ld	(ACC_CUR_CC3:16), 0
AccVoice_ScanForD3_Join3:
	ld	xiy, (ACC_STYLE_RECORD:16)
	cp	e, (0x31ef:16)
	jr	z, AccVoice_ScanForD3_Return3
	ld	a, e
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	iy, wa
	ld	a, (ACC_STYLE_BANK:16)
	call	AccVoice_TableLookup
	call	AccVoice_ScanForD3
	inc	1, e
	jr	AccVoice_ScanForD3_Join3
AccVoice_ScanForD3_Return3:
	ret
	ld	(ACC_PART_BIT:16), 8
	ld	e, (0x3291:16)
	ld	(ACC_CUR_CC3:16), 0
AccVoice_ScanForD3_Join4:
	ld	xiy, (ACC_STYLE_RECORD:16)
	cp	e, (0x31f0:16)
	jr	z, AccVoice_ScanForD3_Return4
	ld	a, e
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	iy, wa
	ld	a, (ACC_STYLE_BANK:16)
	call	AccVoice_TableLookup
	call	AccVoice_ScanForD3
	inc	1, e
	jr	AccVoice_ScanForD3_Join4
AccVoice_ScanForD3_Return4:
	ret
	ld	a, (xiy+977)
	ld	(ACC_STYLE_BANK:16), a
	ld	(ACC_PART_BIT:16), 1
	ld	a, (ACC_LANE_SECTION:16)
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(ACC_LANE_READ_POS:16), wa
	ld	(ACC_PART_BIT:16), 2
	ld	a, (0x31ec:16)
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d1:16), wa
	ld	(ACC_PART_BIT:16), 4
	ld	a, (0x31ed:16)
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d3:16), wa
	ld	(ACC_PART_BIT:16), 8
	ld	a, (0x31ee:16)
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d5:16), wa
	ld	(ACC_PART_BIT:16), 16
	ld	a, (0x31ef:16)
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d7:16), wa
	ld	(ACC_PART_BIT:16), 32
	ld	l, (0x31f0:16)
	call	AccPart_LookupBoundVoiceParam
	call	AccPart_GetParamAddr
	ld	(0x31d9:16), wa
	ret
AccSection_SwitchAtBarLine:
	and	(ACC_DEFER_ENDING_LANES:16), 0xc0
	and	(ACC_DEFER_SECTION_LANES:16), 0xc0
	calr AccBuf_ResetAll4Positions
	bit	0, (0x3256:16)
	jr z, AccSection_SwitchAtBarLine_BuildIndex
	or	(ACC_VARIATION_CHANGE_PENDING:16), 0x01
	bit	1, (0x3256:16)
	jr z, .Lc_f59099
	cp	(ACC_VARIATION_NEXT:16), 0x00
	jr z, AccSection_SwitchAtBarLine_BuildIndex
	dec	1, (ACC_VARIATION_NEXT:16)
	jr t, AccSection_SwitchAtBarLine_BuildIndex
AccSection_SwitchAtBarLine_VariationUp:
.Lc_f59099:
	cp	(ACC_VARIATION_NEXT:16), 0x03
	jr z, AccSection_SwitchAtBarLine_BuildIndex
	inc	1, (ACC_VARIATION_NEXT:16)
AccSection_SwitchAtBarLine_BuildIndex:
	xor	w, w
	ld	a, (ACC_PENDING_INTRO:16)
	and	a, 13
	jr	z, AccSection_SwitchAtBarLine_CheckFillIn
	or	w, 1
AccSection_SwitchAtBarLine_CheckFillIn:
	ld	a, (ACC_PENDING_FILLIN:16)
	and	a, 3
	jr	z, AccSection_SwitchAtBarLine_CheckEnding
	or	w, 2
AccSection_SwitchAtBarLine_CheckEnding:
	ld	a, (ACC_PENDING_ENDING:16)
	and	a, 3
	jr	z, AccSection_SwitchAtBarLine_CheckArrangerStep
	or	w, 4
AccSection_SwitchAtBarLine_CheckArrangerStep:
	bit	0, (0x3254:16)
	jr	z, AccSection_SwitchAtBarLine_CheckVariation
	or	w, 8
	bit	6, (ACC_SECTION_BUTTONS_HELD:16)
	jr	z, AccSection_SwitchAtBarLine_CheckFillIn2Held
	or	w, 2
	or	(ACC_PENDING_FILLIN:16), 1
AccSection_SwitchAtBarLine_CheckFillIn2Held:
	bit	7, (ACC_SECTION_BUTTONS_HELD:16)
	jr	z, AccSection_SwitchAtBarLine_CheckVariation
	or	w, 2
	or	(ACC_PENDING_FILLIN:16), 2
AccSection_SwitchAtBarLine_CheckVariation:
	bit	0, (ACC_VARIATION_CHANGE_PENDING:16)
	jr	z, AccSection_SwitchAtBarLine_CheckRestart
	or	w, 8
AccSection_SwitchAtBarLine_CheckRestart:
	bit	0, (0x3257:16)
	jr	z, AccSection_SwitchAtBarLine_Dispatch
	or	w, 8
AccSection_SwitchAtBarLine_Dispatch:
	and w, 0xf
	sla w, 2
	ld xhl, AccSection_BarLineSwitchTable
	ld	xwa, (xhl+w)
	jp (xwa)


AccSection_BarLineSwitchTable:
	.long AccSection_ToVariation
	.long AccSection_ToIntro
	.long AccSection_ToFillIn
	.long AccSection_ToFillIn
	.long AccSection_ToEnding
	.long AccSection_ToEnding
	.long AccSection_ToEnding
	.long AccSection_ToEnding
	.long AccSection_ToVariation
	.long AccSection_ToNewVariationIntro
	.long AccSection_ToNewVariationFillIn
	.long AccSection_ToNewVariationFillIn
	.long AccSection_ToNewVariationEnding
	.long AccSection_ToNewVariationEnding
	.long AccSection_ToNewVariationEnding
	.long AccSection_ToNewVariationEnding
AccSection_ToVariation:
call	AccStyle_Init
	call	AccVoice_SetupAllParts
	and	(ACC_LANES_INTRO1:16), 192
	and	(ACC_LANES_COUNTIN:16), 192
	and	(ACC_LANES_INTRO2:16), 192
	and	(ACC_LANES_FILLIN1:16), 192
	and	(ACC_LANES_FILLIN2:16), 192
	jr	AccSection_Switch_Common
AccSection_ToEnding:
	call	AccTiming_CallHelper
	call	AccInit_ResetSongCounter
	call	AccSection_StartEnding
	jr	AccSection_Switch_Common
AccSection_ToNewVariationEnding:
	call	AccStyle_Init
	call	AccTiming_CallHelper
	call	AccInit_ResetSongCounter
	call	AccSection_StartEnding
	jr	t, AccSection_Switch_Common
AccSection_ToFillIn:
	call	AccSection_StartFillIn
	jr	AccSection_Switch_Common
AccSection_ToNewVariationFillIn:
	call	AccStyle_Init
	call	AccSection_StartFillIn
	jr	t, AccSection_Switch_Common
AccSection_ToIntro:
	call	AccSection_StartIntro
	jr	AccSection_Switch_Common
AccSection_ToNewVariationIntro:
	call	AccStyle_Init
	call	AccSection_StartIntro
AccSection_Switch_Common:
	call	Rhythm_Send_Ch90_7F_7E
	call	Rhythm_SendChanPressure
	calr	AccBuf_ResetByteData
	ret

AccBuf_ResetAll4Positions:
	ld	xhl, 11228
	calr	AccBuf_ResetOnePosition
	ld	xhl, 11484
	calr	AccBuf_ResetOnePosition
	ld	xhl, 11740
	calr	AccBuf_ResetOnePosition
	ld	xhl, 11996
	calr	AccBuf_ResetOnePosition
	ret
AccBuf_ResetOnePosition:
	ld (xhl + 0:8), 0xa
	ld (xhl + 2), 0xff
	ldw wa, 0xa
	ldw bc, 0xa
	ei 6
	ld (xhl + 4), wa
	ld (xhl + 6), bc
	ei 0
	ret

AccBuf_ResetByteData:
	ld A, 0x00:opc
	ld	XHL,ACC_BASS_NOTES
	xor IY,IY
AccBuf_ResetByteData_Loop:
	ld	(xhl+iy), a
	add	iy, 9
	cp	iy, 72
	jr	c, AccBuf_ResetByteData_Loop
	ld	xhl, ACC_ACCOMP1_NOTES
	xor	iy, iy
AccBuf_ResetByteData_Loop2:
	ld	(xhl+iy), a
	add	iy, 9
	cp	iy, 72
	jr	c, AccBuf_ResetByteData_Loop2
	ld	xhl, ACC_ACCOMP2_NOTES
	xor	iy, iy
AccBuf_ResetByteData_Loop3:
	ld	(xhl+iy), a
	add	iy, 9
	cp	iy, 72
	jr	c, AccBuf_ResetByteData_Loop3
	ld	xhl, ACC_ACCOMP3_NOTES
	xor	iy, iy
AccBuf_ResetByteData_Loop4:
	ld	(xhl+iy), a
	add	iy, 9
	cp	iy, 72
	jr	c, AccBuf_ResetByteData_Loop4
	ret
AccNote_FlushAll:
	ld	a, (ACC_LANES_RESYNC:16)
	and A,0x3f
	jr z, AccNote_FlushReturn
	call RhythmPart_CopyData
	call RhythmPart1_ProcessAccentData
	ld A, 0x01:opc
	ld	(0x3234:16), a
	call RhythmPart2_ProcessAccentData
	call AccVoice_LoadRhythmParams_Part3
	call AccVoice_LoadRhythmParams_Part4
	call AccVoice_LoadRhythmParams_Part5
	and	(ACC_LANES_RESYNC:16), 0xc0
AccNote_FlushReturn:
	ret

AccTempo_CalcPosition:
	ld	a, 95:opc
	ld	w, (1112:16)
	dec	1, w
	call	AccVoice_LookupTableAddress
	ld	bc, (12741:16)
	ld	w, (ACC_LANE_BAR:16)
	dec	1, w
	call	AccTempo_PositionCompare
	ld	(12852:16), a
	ld	(12850:16), a
	ret
AccSection_SwitchNow:
	call Rhythm_SendNoteOnMax
	call AccNotes_ForgetAllSounding
	calr AccBuf_WriteAllNotesOff
	call Rhythm_SendChanPressure
	calr AccBuf_ResetAll4
	ld	a, (ACC_LANES_FILLIN1:16)
	or	a, (ACC_LANES_FILLIN2:16)
	and A,0x3f
	jr z, .Lc_f592f0
	bit	0, (ACC_STYLE_ARRANGER_ON:16)
	jr z, .Lc_f592f0
	or	(0x3254:16), 0x01
	ld	a, (ACC_LANES_FILLIN1:16)
	and A,0x3f
	jr z, .Lc_f592e5
	cp	(ACC_VARIATION_NEXT:16), 0x00
	jr z, .Lc_f592f0
	dec	1, (ACC_VARIATION_NEXT:16)
	jr t, .Lc_f592f0
AccSection_SwitchNow_AdjustDecay:
.Lc_f592e5:
	cp	(ACC_VARIATION_NEXT:16), 0x03
	jr z, .Lc_f592f0
	inc	1, (ACC_VARIATION_NEXT:16)
AccSection_SwitchNow_CheckNoteOn:
.Lc_f592f0:
	bit	0, (0x3254:16)
	jr z, AccSection_SwitchNow_CheckModes
	ld	a, (ACC_DEFER_ENDING_LANES:16)
	and A,0x3f
	jr nz, AccSection_SwitchNow_CheckModes
	calr AccStyle_Init
	calr AccVoice_SetupAllParts
	ld a, (ACC_BEATS_PER_BAR:16)
	ld (0x0458:16), a
AccSection_SwitchNow_CheckModes:
	ld	a, (ACC_PENDING_INTRO:16)
	and	a, 13
	jr	z, AccSection_SwitchNow_CheckSplit
	calr	AccSection_StartIntro
AccSection_SwitchNow_CheckSplit:
	ld	a, (ACC_PENDING_FILLIN:16)
	and	a, 3
	jr	nz, AccSection_SwitchNow_ApplySplit
	bit	6, (ACC_SECTION_BUTTONS_HELD:16)
	jr	z, AccSection_SwitchNow_CheckPedalBit7
	or	(ACC_PENDING_FILLIN:16), 1
	jr	AccSection_SwitchNow_ApplySplit
AccSection_SwitchNow_CheckPedalBit7:
	bit	7, (ACC_SECTION_BUTTONS_HELD:16)
	jr	z, AccSection_SwitchNow_CheckThird
	or	(ACC_PENDING_FILLIN:16), 2
AccSection_SwitchNow_ApplySplit:
	calr AccSection_StartFillIn

AccSection_SwitchNow_CheckThird:
	ld	a, (ACC_PENDING_ENDING:16)
	and	a, 3
	jr	z, AccSection_SwitchNow_ClearHighBits
	calr	AccTiming_CallHelper
	call	AccInit_ResetSongCounter
	calr	AccSection_StartEnding
AccSection_SwitchNow_ClearHighBits:
	and	(ACC_LANE_BEAT_POS:16), 240
	and	(0x31f4:16), 240
	and	(0x31f5:16), 240
	and	(0x31f6:16), 240
	and	(0x31f7:16), 240
	and	(0x31f8:16), 240
	calr	AccSeq_DualPartScan
	bit	6, (ACC_PART_FLAGS:16)
	jr	nz, AccSection_SwitchNow_SetDirty
	calr	AccSeq_FourChannelScan
AccSection_SwitchNow_SetDirty:
	; ordi8 0x332c, 128 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 128
	ret



AccInit_ResetSongCounter:
	cp	(0x322a:16), 0x00
	jr nz, AccInit_ResetSong_Store
	call SeqVoice_SendNoteOffAndFlush
AccInit_ResetSong_Store:
	ld	(12842:16), 0
	ret
AccInit_SendNoteOffAndFlush:
	call SeqVoice_SendNoteOffAndFlush
	ret

AccTuning_CheckChange:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccTuning_ChangeReturn
	ld	a, (0x32d9:16)
	xor	a, (0x32da:16)
	bit 0x00,A
	jr z, AccTuning_ChangeReturn
	or	(0x32db:16), 0x01
AccTuning_ChangeReturn:
	ret

AccTuning_LoadFromROM:
	push	xwa
	push	xhl
	call	AccHelper_ComputeVoiceOffset
	add	xhl, 1996816
	bit	7, (xhl+1)
	jrl	z, AccTuning_LoadReturn
	ld	a, (xhl+4)
	ld	(0x319c:16), a
	ld	a, (xhl+5)
	ld	w, a
	and	w, 127
	ld	(0x319d:16), w
	and	a, 128
	srl	a, 7
	ld	(0x319f:16), a
	ld	a, (xhl+6)
	ld	(0x31a3:16), a
	ld	a, (xhl+7)
	ld	w, a
	and	w, 127
	ld	(0x31a4:16), w
	and	a, 128
	srl	a, 7
	ld	(0x31a6:16), a
	ld	a, (xhl+8)
	ld	(0x31aa:16), a
	ld	a, (xhl+9)
	ld	w, a
	and	w, 127
	ld	(0x31ab:16), w
	and	a, 128
	srl	a, 7
	ld	(0x31ad:16), a
	ld	a, (xhl+2)
	ld	(0x3195:16), a
	ld	a, (xhl+3)
	ld	w, a
	and	w, 127
	ld	(0x3196:16), w
	and	a, 128
	srl	a, 7
	ld	(0x3198:16), a
	ld	a, (xhl+0:8)
	ld	(0x318e:16), a
	ld	a, (xhl+1)
	and	a, 127
	ld	(0x318f:16), a
AccTuning_LoadReturn:
	pop xhl
	pop xwa
	ret

AccTuning_LoadMaster:
	call	AccHelper_ComputeVoiceOffset
	add	xhl, 1996816
	bit	7, (xhl+1)
	jr	z, AccTuning_LoadMasterReturn
	ld	a, (xhl+0:8)
	ld	(0x318e:16), a
	ld	a, (xhl+1)
	and	a, 127
	ld	(0x318f:16), a
AccTuning_LoadMasterReturn:
	ret

AccTuning_LoadCoarse:
	call	AccHelper_ComputeVoiceOffset
	add	xhl, 1996816
	bit	7, (xhl+1)
	jr	z, AccTuning_LoadCoarseReturn
	ld	a, (xhl+2)
	ld	(0x3195:16), a
	ld	a, (xhl+3)
	ld	w, a
	and	w, 127
	ld	(0x3196:16), w
	and	a, 128
	srl	a, 7
	ld	(0x3198:16), a
AccTuning_LoadCoarseReturn:
	ret

AccTuning_LoadFine:
	call	AccHelper_ComputeVoiceOffset
	add	xhl, 1996816
	bit	7, (xhl+1)
	jr	z, AccTuning_LoadFineReturn
	ld	a, (xhl+4)
	ld	(0x319c:16), a
	ld	a, (xhl+5)
	ld	w, a
	and	w, 127
	ld	(0x319d:16), w
	and	a, 128
	srl	a, 7
	ld	(0x319f:16), a
AccTuning_LoadFineReturn:
	ret

AccTuning_LoadOctave:
	call	AccHelper_ComputeVoiceOffset
	add	xhl, 1996816
	bit	7, (xhl+1)
	jr	z, AccTuning_LoadOctaveReturn
	ld	a, (xhl+6)
	ld	(0x31a3:16), a
	ld	a, (xhl+7)
	ld	w, a
	and	w, 127
	ld	(0x31a4:16), w
	and	a, 128
	srl	a, 7
	ld	(0x31a6:16), a
AccTuning_LoadOctaveReturn:
	ret

AccTuning_LoadTranspose:
	call	AccHelper_ComputeVoiceOffset
	add	xhl, 1996816
	bit	7, (xhl+1)
	jr	z, AccTuning_LoadTransposeReturn
	ld	a, (xhl+8)
	ld	(0x31aa:16), a
	ld	a, (xhl+9)
	ld	w, a
	and	w, 127
	ld	(0x31ab:16), w
	and	a, 128
	srl	a, 7
	ld	(0x31ad:16), a
AccTuning_LoadTransposeReturn:
	ret

AccTuning_ApplyChange:
	bit	0, (0x32db:16)
	jrl z, AccTuning_ApplyReturn
	call AccHelper_ComputeVoiceOffset
	add XHL,0x001e7810
	bit	0, (0x32d9:16)
	jr z, AccTuning_ApplyChange_ClearBit
	or	(xhl+1), 128
	jr	AccTuning_ApplyChange_SelectMode
AccTuning_ApplyChange_ClearBit:
	andmi8 (xhl + 1), 0x7f

AccTuning_ApplyChange_SelectMode:
	ld	a, (ACC_LANES_INTRO1:16)
	or	a, (ACC_LANES_COUNTIN:16)
	and	a, 63
	jrl	nz, AccTuning_Mode_078
	ld	a, (ACC_LANES_INTRO2:16)
	and	a, 63
	jr	nz, AccTuning_Mode_080
	ld	a, (ACC_LANES_ENDING1:16)
	and	a, 63
	jr	nz, AccTuning_Mode_076
	or	a, (ACC_LANES_ENDING2:16)
	and	a, 63
	jr	nz, AccTuning_Mode_077
	ld	a, (ACC_LANES_FILLIN1:16)
	or	a, (ACC_LANES_FILLIN2:16)
	and	a, 63
	jr	nz, AccTuning_Mode_074
	ld	a, (12965:16)
	and	a, 63
	jr	nz, AccTuning_Mode_149
	jr	AccTuning_Mode_None
AccTuning_Mode_078:
	ld w, 0x3:opc
	jr AccTuning_ApplyVoice

AccTuning_Mode_080:
	ld w, 0x4:opc
	jr AccTuning_ApplyVoice

AccTuning_Mode_076:
	ld w, 0x5:opc
	jr AccTuning_ApplyVoice

AccTuning_Mode_077:
	ld w, 0x6:opc
	jr AccTuning_ApplyVoice

AccTuning_Mode_074:
	ld w, 0x2:opc
	jr AccTuning_ApplyVoice

AccTuning_Mode_149:
	ld w, 0x1:opc
	jr AccTuning_ApplyVoice

AccTuning_Mode_None:
	ld w, 0x0:opc

AccTuning_ApplyVoice:
	; ldb_d8 a, (0x32a3) (v7 patched)
	ld	a, (ACC_LANE_SECTION:16)
	; ldda32 xiy, (0x32ce) (v7 patched)
	ld	xiy, (ACC_STYLE_RECORD:16)
	; call AccPart_GetVoiceParamOffsetTable (v7 addr)
	call	AccPart_GetVoiceParamOffsetTable
	; call AccVoice_LoadTuningBlock (v7 addr)
	call	AccVoice_LoadTuningBlock
	; ordi8 0x332c, 63 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 63
	; ordi8 0x332c, 128 (v7 patched)
	or	(ACC_LANES_RESYNC:16), 128
AccTuning_ApplyReturn:
	; anddi8 (0x3393), 254 (v7 patched)
	and	(0x32db:16), 254
	ret



AccTuning_Toggle:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, AccTuning_Toggle_NoStyle
	ld	a, (0x32d9:16)
	xor	a, (0x32da:16)
	bit 0x00,A
	jr z, AccTuning_Toggle_CheckDirty
	call AccHelper_ComputeVoiceOffset
	add XHL,0x001e7810
	bit	0, (0x32d9:16)
	jr z, AccTuning_Toggle_ClearBit
	or	(xhl+1), 128
	jr	AccTuning_Toggle_SetFlag
AccTuning_Toggle_ClearBit:
	andmi8 (xhl + 1), 0x7f

AccTuning_Toggle_SetFlag:
	or	(0x3283:16), 1
	jr	AccTuning_Toggle_Return
AccTuning_Toggle_CheckDirty:
	bit	0, (0x32db:16)
	jr	z, AccTuning_Toggle_Return
	and	(0x32db:16), 254
	or	(0x3283:16), 1
	jr	AccTuning_Toggle_Return
AccTuning_Toggle_NoStyle:
	; anddi8 (0x3391), 254 (v7 patched)
	and	(0x32d9:16), 254
	; call AccTuning_LEDOff (v7 addr)
	call	AccTuning_LEDOff
AccTuning_Toggle_Return:
	ret

AccTuning_SaveState:
	ld	a, (13017:16)
	ld	(13018:16), a
	ret
AccTuning_Init:
	push XWA
	push XHL
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr nc, .Lc_f59640
	call AccHelper_ComputeVoiceOffset
	add XHL,0x001e7810
	bit 7,(XHL+0x01)
	jr z, .Lc_f59640
	or	(0x32d9:16), 0x01
	call AccTuning_LEDOn
	ld	a, (0x32d9:16)
	ld	(0x32da:16), a
	jr t, AccTuning_Init_Epilogue
AccTuning_Init_NoTuning:
.Lc_f59640:
	and	(0x32d9:16), 0xfe
	call AccTuning_LEDOff
	ld	a, (0x32d9:16)
	ld	(0x32da:16), a
AccTuning_Init_Epilogue:
	pop xhl
	pop xwa
	ret

AccTuning_DisableIfNoStyle:
	cp	(ACC_STYLE_NUMBER:16), 0x80
	jr c, AccTuning_DisableReturn
	and	(0x32d9:16), 0xfe
	call AccTuning_LEDOff
AccTuning_DisableReturn:
	ret

AccTuning_LEDOn:
	ld	(13016:16), 1
	ld	a, 74:opc
	call	CtrlPanel_SetIndicatorBit
	ret
AccTuning_LEDOff:
	ld	(13016:16), 0
	ld	a, 74:opc
	call	CtrlPanel_SetIndicatorBit
	ret
AccWrap_JumpTable:
	jp	AccWrap_JumpTable_Return2
	jp	AccWrap_JumpTable_Return
	jp	AccWrap_JumpTable_Return
	jp	AccWrap_JumpTable_Return
	jp	AccWrap_JumpTable_Return
AccWrap_JumpTable_Return:
	ret
AccWrap_JumpTable_Return2:
	ret
AccWrap_ReplayStop:
	jp	AccStyleCtl_OnSwitchEvent
AccWrap_ReplayStopAlt:
	jp	AccPedal_RawHandler_Join

AccWrap_AutoPlayCheck:
	push xiz
	call AccAutoPlay_NoteDispatch
	pop xiz
	ret

AccWrap_PlayModeByteData:
	jp	AccReplay_FullRestart
	jp	AccAutoPlay_ActionDispatch

AccWrap_DeferredAction:
	jp AccAutoPlay_DeferredAction

AccWrap_AutoPlayStateMachine:
	push xiz
	call AccAutoPlay_StateMachine
	pop xiz
	ret

AccWrap_PlayModeDispatch:
	push xiz
	call AccPlayMode_Dispatch
	pop xiz
	ret

AccWrap_PlayModeStart:
	push xiz
	call AccPlayMode_StartPlayFull
	pop xiz
	ret

AccWrap_PlayModeStopData:
	jp	AccPlayMode_StopExprC

AccWrap_PlayModeStartAccPlay:
	jp AccPlayMode_StartAccPlayFull

AccWrap_PlayModeStopPlayAndAcc:
	jp AccPlayMode_StopPlayAndAcc

AccWrap_PlayModeStopExpr:
	push xiz
	call AccPlayMode_StopExprD
	pop xiz
	ret

AccWrap_PlayModeStopAcc:
	push xiz
	call AccPlayMode_StopAcc
	pop xiz
	ret

AccWrap_ReplaySavedPedal:
	push xiz
	call AccReplay_SavedPedal
	pop xiz
	ret

AccWrap_ReplaySavedExpr:
	jp AccReplay_SavedExpression

AccWrap_FullStop:
	push xiz
	call AccReplay_FullStop
	pop xiz
	ret

AccWrap_PositionClear:
	push xiz
	call AccPos_ClearOnStart
	pop xiz
	ret

AccWrap_PositionSaveData:
	push	xiz
	call	AccReplay_HandlePendingStop
	pop	xiz
	ret

AccWrap_FlagSync:
	jp AccFlags_SyncTo64607
AccWrap_PlayModeStopData2:
	jp	AccTempo_WriteMarker_Padding_Return

AccWrap_AutoPlayZoneTrack:
	push xiz
	call AccAutoPlay_ZoneTrack
	pop xiz
	ret

AccWrap_AutoPlayByteData:
	jp	AccSynchro_PeriodicCheck
	push	xiz
	calr	AccPlayMode_StopPlayAndAcc
	pop	xiz
	ret
	push	xiz
	calr	AccPlayMode_StopExprC
	pop	xiz
	ret

AccStyleCtl_OnSwitchEvent:
	ld	a, (SWBTWR_PAYLOAD_1:16)
	ld	(ACC_CTL_EVENT_FIELD:16), a
	cp	a, 5:i3
	jr	z, AccStyleCtl_OnSwitchEvent_Field5or6
	cp	a, 6:i3
	jr	z, AccStyleCtl_OnSwitchEvent_Field5or6
	jr	AccStyleCtl_OnSwitchEvent_CheckField0
AccStyleCtl_OnSwitchEvent_Field5or6:
	ld	a, (SWBTWR_PAYLOAD_2:16)
	ld	(ACC_CTL_EVENT_VALUE:16), a
	ld	a, (SWBTWR_PAYLOAD_3:16)
	cp	a, 255
	jr	nz, AccStyleCtl_OnSwitchEvent_StoreMask
	xor	a, a
AccStyleCtl_OnSwitchEvent_StoreMask:
	ld	(ACC_CTL_EVENT_MASK:16), a
	calr	AccStyleCtl_StartStopButton
	calr	AccStyleCtl_SynchroButton
	calr	AccStyleCtl_SectionButtons
AccStyleCtl_OnSwitchEvent_CheckField0:
	ld	a, (SWBTWR_PAYLOAD_1:16)
	cp	a, 0:i3
	jr	z, AccStyleCtl_OnSwitchEvent_SavePos
	cp	a, 7:i3
	jr	nz, AccStyleCtl_OnSwitchEvent_Return
	ld	a, (SWBTWR_PAYLOAD_3:16)
	and	a, 48
	cp	a, 0:i3
	jr	z, AccStyleCtl_OnSwitchEvent_Return
AccStyleCtl_OnSwitchEvent_SavePos:
	calr AccPos_SaveOnStop

AccStyleCtl_OnSwitchEvent_Return:
	ret

AccPedal_RawHandler:
	nop
	nop
AccPedal_RawHandler_Join:
	ld	a, (SWBTWR_PAYLOAD_1:16)
	cp	a, 3:i3
	jr	nz, AccPedal_RawHandler_Return
	ld	a, (SWBTWR_PAYLOAD_2:16)
	and	a, 7
	ld	(ACC_CTL_EVENT_VALUE:16), a
	ld	a, (SWBTWR_PAYLOAD_3:16)
	ld	(ACC_CTL_EVENT_MASK:16), a
	ld	a, (SWBTWR_PAYLOAD_1:16)
	ld	(ACC_CTL_EVENT_FIELD:16), a
AccPedal_RawHandler_Return:
	ret
	nop
	nop
AccStyleCtl_StartStopButton:
	cp	(ACC_CTL_EVENT_FIELD:16), 0x05
	jrl nz, AccStyleCtl_StartStop_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit 0x00,A
	jr nz, .Lc_f597aa
	jp AccStyleCtl_StartStop_Return
AccStyleCtl_StartStop_CallReset:
.Lc_f597aa:
	push XWA
	push XHL
	push XBC
	push XDE
	push XIX
	push XIY
	push XIZ
	call Fade_StartArmedFadeIn
	pop XIZ
	pop XIY
	pop XIX
	pop XDE
	pop XBC
	pop XHL
	pop XWA
	cp	(0x7e53:16), 0x00
	jr z, .Lc_f597ca
	call AccPlay_ToggleEntry
	jrl t, AccStyleCtl_StartStop_Return
AccStyleCtl_StartStop_CheckStyle:
.Lc_f597ca:
	cp (CURRENT_TITLE:16), 0x6f
	jr z, AccStyleCtl_StartStop_SpecialStyle
	cp (CURRENT_TITLE:16), 0x70
	jr z, AccStyleCtl_StartStop_SpecialStyle
	cp (CURRENT_TITLE:16), 0x71
	jr z, AccStyleCtl_StartStop_SpecialStyle
	cp (CURRENT_TITLE:16), 0x72
	jr nz, AccStyleCtl_StartStop_CheckPlay
AccStyleCtl_StartStop_SpecialStyle:
	or (3381:16), 1
	jrl AccStyleCtl_StartStop_Return

AccStyleCtl_StartStop_CheckPlay:
	bit	2, (SEQ_RTMCFG:16)
	jr z, AccStyleCtl_StartStop_CheckMultiStyle
	calr AccPlayMode_Dispatch
	bit 3, (3411:16)
	jr z, AccStyleCtl_StartStop_PlayJump
	cp (SQSTEP_DISPLAY_MODE:16), 0
	jr z, AccStyleCtl_StartStop_PlayJump
	call AccPedal_ScanVoiceSlots
	ld a, 0x86:opc
	bit 1, (3411:16)
	jr nz, AccStyleCtl_StartStop_WriteTempo
	ld a, 0x85:opc

AccStyleCtl_StartStop_WriteTempo:
	calr AccTempo_WriteStopMarker

AccStyleCtl_StartStop_PlayJump:
	jrl AccStyleCtl_StartStop_Return

AccStyleCtl_StartStop_CheckMultiStyle:
	cp	(CURRENT_TITLE:16), 120
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 122
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 115
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 116
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 117
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 118
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 119
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 121
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 108
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 109
	jr	z, AccStyleCtl_StartStop_MultiMatch
	cp	(CURRENT_TITLE:16), 110
	jr	nz, AccStyleCtl_StartStop_Normal
AccStyleCtl_StartStop_MultiMatch:
	or (3381:16), 1
	jr AccStyleCtl_StartStop_Return

AccStyleCtl_StartStop_Normal:
	bit	2, (0x2896:16)
	jr nz, AccStyleCtl_StartStop_Return
	pushw wa
	calr AccStyleCtl_IsStartStopBlocked
	cp a, 1:i3
	popw wa
	jr z, AccStyleCtl_StartStop_Return
	ei 6
	ld a, (PLAY_TRANSPORT_STATE:16)
	bit 2, a
	jr nz, AccStyleCtl_StartStop_CallPlayMode
	bit 0, a
	jr z, AccStyleCtl_StartStop_CallPlayMode
	xor a, a
	ld (PLAY_TRANSPORT_STATE:16), a
	ld (ACC_TRANSPORT_STATE:16), a
	ld (SEQ_TRANSPORT_STATE:16), a
	ei 0
	jr AccStyleCtl_StartStop_Return

AccStyleCtl_StartStop_CallPlayMode:
	ei 0
	calr AccPlayMode_TransitionRouter

AccStyleCtl_StartStop_Return:
	ret

AccStyleCtl_StartStop_Padding:
	nop
	nop

AccStyleCtl_IsStartStopBlocked:
	cp (CURRENT_TITLE:16), 0x6f
	jr z, AccStyleCtl_IsStartStopBlocked_Ineligible
	cp (CURRENT_TITLE:16), 0x6c
	jr c, .Lc_f598bc
	cp (CURRENT_TITLE:16), 0x7a
	jr ugt, .Lc_f598bc
	jr t, AccStyleCtl_IsStartStopBlocked_Ineligible
AccStyleCtl_IsStartStopBlocked_Extended:
.Lc_f598bc:
	cp (CURRENT_MODE:16), 0x13
	jr z, AccStyleCtl_IsStartStopBlocked_Ineligible
	cp (CURRENT_TITLE:16), 0x78
	jr z, AccStyleCtl_IsStartStopBlocked_Match120
	jr t, AccStyleCtl_IsStartStopBlocked_Eligible
AccStyleCtl_IsStartStopBlocked_Match120:
	jr AccStyleCtl_IsStartStopBlocked_Ineligible

AccStyleCtl_IsStartStopBlocked_Eligible:
	ld a, 0x0:opc
	jr AccStyleCtl_IsStartStopBlocked_Return

AccStyleCtl_IsStartStopBlocked_Ineligible:
	ld a, 0x1:opc

AccStyleCtl_IsStartStopBlocked_Return:
	ret

AccStyleCtl_SynchroButton:
	cp	(ACC_CTL_EVENT_FIELD:16), 0x05
	jr nz, AccStyleCtl_SynchroButton_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit 0x01,A
	jr z, AccStyleCtl_SynchroButton_Return
	ld A, 0x02:opc
	xor	(PANEL_STYLE+5:16), a
	cp	(PANEL_EVENT_SOURCE:16), 255
	jr	z, AccStyleCtl_SynchroButton_Return
	bit	3, (0xfd56:16)
	jr	z, AccStyleCtl_SynchroButton_Return
	ld	e, (0xfc5f:16)
	and	e, 2
	ld	xix, 14384
	ld	(xix+0:8), 72
	ld	(xix+1), 5
	ld	(xix+2), e
	ld	(xix+3), 2
	push	xix
call	MidiPkt_DispatchViaTable_4DCE
	inc	4, xsp
AccStyleCtl_SynchroButton_Return:
	ret

AccStyleCtl_SynchroButton_Padding:
	nop
	nop

AccStyleCtl_SectionButtons:
	cp (CURRENT_MODE:16), 0x0e
	jr z, AccStyleCtl_SectionButtons_JumpMain
	bit	0, (0x288a:16)
	jr z, AccStyleCtl_SectionButtons_ClearAll
AccStyleCtl_SectionButtons_JumpMain:
	jp AccStyleCtl_SectionButtons_Return

AccStyleCtl_SectionButtons_ClearAll:
	xor	wa, wa
	ld	(0x33c8:16), a
	ld	(0x33c9:16), a
	ld	(0x33ca:16), a
	ld	(0x33cb:16), a
	ld	(0x33cc:16), a
	ld	(0x33cd:16), a
	ld	(0x33ce:16), a
	ld	(0x33cf:16), a
	calr	AccStyleCtl_DispatchSectionButtons
	bit	3, (0xd53:16)
	jr	z, AccStyleCtl_SectionButtons_CheckRecord
	and	(0xfc5f:16), 15
	ld	(0x33c9:16), 0
	ld	(0x33cb:16), 0
	ld	(0x33cd:16), 0
	ld	(0x33cf:16), 0
AccStyleCtl_SectionButtons_CheckRecord:
	calr	AccStyleCtl_SyncSectionEvents
	bit	3, (0xd53:16)
	jr	z, AccStyleCtl_SectionButtons_Return
	cp	(SQSTEP_DISPLAY_MODE:16), 0
	jr	z, AccStyleCtl_SectionButtons_Return
	xor	wa, wa
	ld	(0x33c8:16), a
	ld	(0x33c9:16), a
	ld	(0x33cc:16), a
	ld	(0x33cd:16), a
	calr	AccPedal_MapToAcc
	calr	AccStyleCtl_SendSectionEvents
AccStyleCtl_SectionButtons_Return:
	ret

AccStyleCtl_SectionButtons_Padding:
	nop
	nop

AccStyleCtl_SendSectionEvents:
	ld	a, (13256:16)
	xor	a, 255
	and	a, (13257:16)
	cp	a, 0:i3
	jr	z, AccStyleCtl_SendSectionEvents_Pass2
	ld	b, 5:opc
	ld	c, 72:opc
	ld	d, a
	ld	e, (13256:16)
call	MIDI_TransmitTempoCC
AccStyleCtl_SendSectionEvents_Pass2:
	ld	a, (13260:16)
	xor	a, 255
	and	a, (13261:16)
	cp	a, 0:i3
	jr	z, AccStyleCtl_SendSectionEvents_Pass3
	ld	b, 6:opc
	ld	c, 72:opc
	ld	d, a
	ld	e, (13260:16)
	call	MIDI_TransmitTempoCC
AccStyleCtl_SendSectionEvents_Pass3:
	ld	a, (13256:16)
	and	a, (13257:16)
	cp	a, 0:i3
	jr	z, AccStyleCtl_SendSectionEvents_Pass4
	ld	b, 5:opc
	ld	c, 72:opc
	ld	d, a
	ld	e, (13256:16)
	call	MIDI_TransmitTempoCC
AccStyleCtl_SendSectionEvents_Pass4:
	ld	a, (13260:16)
	and	a, (13261:16)
	cp	a, 0:i3
	jr	z, AccStyleCtl_SendSectionEvents_Return
	ld	b, 6:opc
	ld	c, 72:opc
	ld	d, a
	ld	e, (13260:16)
call	MIDI_TransmitTempoCC
AccStyleCtl_SendSectionEvents_Return:
	ret

AccStyleCtl_DispatchSectionButtons:
	calr AccStyleCtl_IntroEnding1Button
	calr AccStyleCtl_IntroEnding2Button
	calr AccStyleCtl_FillIn2Button
	calr AccStyleCtl_FillIn1Button
	calr AccStyleCtl_Ending1Bit
	calr AccStyleCtl_Ending2Bit
	calr AccStyleCtl_CountInBit
	ret

AccStyleCtl_DispatchSectionButtons_Padding:
	nop
	nop

AccStyleCtl_IntroEnding1Button:
	cp	(ACC_CTL_EVENT_FIELD:16), 0x05
	jr nz, AccStyleCtl_IntroEnding1_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit 0x02,A
	jr z, AccStyleCtl_IntroEnding1_Release
	orw (0x1108:16), 0x0004
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr z, AccStyleCtl_IntroEnding1_CheckRunning
	calr AccSection_RequestIntro1
	jr t, AccStyleCtl_IntroEnding1_Release
AccStyleCtl_IntroEnding1_CheckRunning:
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, AccStyleCtl_IntroEnding1_Ending
	calr AccSection_RequestIntro1
	jr AccStyleCtl_IntroEnding1_Release

AccStyleCtl_IntroEnding1_Ending:
	calr AccSection_RequestEnding1

AccStyleCtl_IntroEnding1_Release:
	bit	2, (ACC_CTL_EVENT_MASK:16)
	jr	z, AccStyleCtl_IntroEnding1_Return
	bit	2, (ACC_CTL_EVENT_VALUE:16)
	jr	nz, AccStyleCtl_IntroEnding1_Return
	cp	(PANEL_EVENT_SOURCE:16), 127
	jr	z, AccStyleCtl_IntroEnding1_ReleaseCheckRunning
	calr	AccSection_ReleaseIntro1
	jr	AccStyleCtl_IntroEnding1_Return
AccStyleCtl_IntroEnding1_ReleaseCheckRunning:
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, AccStyleCtl_IntroEnding1_ReleaseEnding
	calr AccSection_ReleaseIntro1
	jr AccStyleCtl_IntroEnding1_Return

AccStyleCtl_IntroEnding1_ReleaseEnding:
	calr AccSection_ReleaseEnding1

AccStyleCtl_IntroEnding1_Return:
	ret

AccStyleCtl_IntroEnding2Button:
	cp	(ACC_CTL_EVENT_FIELD:16), 0x06
	jr nz, AccStyleCtl_IntroEnding2_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit 0x02,A
	jr z, AccStyleCtl_IntroEnding2_Release
	ld de, 4:i3
	sla DE, 0x08
	or	(0x1108:16), de
	cp	(PANEL_EVENT_SOURCE:16), 127
	jr	z, AccStyleCtl_IntroEnding2_CheckRunning
	calr	AccSection_RequestIntro2
	jr	AccStyleCtl_IntroEnding2_Release
AccStyleCtl_IntroEnding2_CheckRunning:
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, AccStyleCtl_IntroEnding2_Ending
	calr AccSection_RequestIntro2
	jr AccStyleCtl_IntroEnding2_Release

AccStyleCtl_IntroEnding2_Ending:
	calr AccSection_RequestEnding2

AccStyleCtl_IntroEnding2_Release:
	bit	2, (ACC_CTL_EVENT_MASK:16)
	jr	z, AccStyleCtl_IntroEnding2_Return
	bit	2, (ACC_CTL_EVENT_VALUE:16)
	jr	nz, AccStyleCtl_IntroEnding2_Return
	cp	(PANEL_EVENT_SOURCE:16), 127
	jr	z, AccStyleCtl_IntroEnding2_ReleaseCheckRunning
	calr	AccSection_ReleaseIntro2
	jr	AccStyleCtl_IntroEnding2_Return
AccStyleCtl_IntroEnding2_ReleaseCheckRunning:
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, AccStyleCtl_IntroEnding2_ReleaseEnding
	calr AccSection_ReleaseIntro2
	jr AccStyleCtl_IntroEnding2_Return

AccStyleCtl_IntroEnding2_ReleaseEnding:
	calr AccSection_ReleaseEnding2

AccStyleCtl_IntroEnding2_Return:
	ret

AccStyleCtl_FillIn2Button:
	cp	(ACC_CTL_EVENT_FIELD:16), 0x05
	jr nz, AccStyleCtl_FillIn2_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit 0x07,A
	jr z, AccStyleCtl_FillIn2_Release
	orw (0x1108:16), 0x0080
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, AccStyleCtl_FillIn2_CountIn
	calr AccSection_RequestFillIn2
	jr t, AccStyleCtl_FillIn2_Release
AccStyleCtl_FillIn2_CountIn:
	calr AccSection_RequestCountIn

AccStyleCtl_FillIn2_Release:
	bit	7, (ACC_CTL_EVENT_MASK:16)
	jr	z, AccStyleCtl_FillIn2_Return
	bit	7, (ACC_CTL_EVENT_VALUE:16)
	jr	nz, AccStyleCtl_FillIn2_Return
	bit	2, (ACC_TRANSPORT_STATE:16)
	jr	z, AccStyleCtl_FillIn2_ReleaseCountIn
	calr	AccSection_ReleaseFillIn2
	jr	AccStyleCtl_FillIn2_Return
AccStyleCtl_FillIn2_ReleaseCountIn:
	calr AccSection_ReleaseCountIn

AccStyleCtl_FillIn2_Return:
	ret

AccStyleCtl_FillIn1Button:
	cp	(ACC_CTL_EVENT_FIELD:16), 0x05
	jr nz, AccStyleCtl_FillIn1_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit 0x06,A
	jr z, .Lc_f59b49
	orw (0x1108:16), 0x0040
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, .Lc_f59b49
	calr AccSection_RequestFillIn1
	jr t, .Lc_f59b49
AccStyleCtl_FillIn1_Release:
.Lc_f59b49:
	bit	6, (ACC_CTL_EVENT_MASK:16)
	jr z, AccStyleCtl_FillIn1_Return
	bit	6, (ACC_CTL_EVENT_VALUE:16)
	jr nz, AccStyleCtl_FillIn1_Return
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, AccStyleCtl_FillIn1_Return
	calr AccSection_ReleaseFillIn1
	jr t, AccStyleCtl_FillIn1_Return
AccStyleCtl_FillIn1_Return:
	ret

AccStyleCtl_Ending1Bit:
	cp	(ACC_CTL_EVENT_FIELD:16), 0x05
	jr nz, AccStyleCtl_Ending1Bit_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit 0x04,A
	jr z, .Lc_f59b7e
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, .Lc_f59b7e
	calr AccSection_RequestEnding1
AccStyleCtl_Ending1Bit_Release:
.Lc_f59b7e:
	bit	4, (ACC_CTL_EVENT_MASK:16)
	jr z, AccStyleCtl_Ending1Bit_Return
	bit	4, (ACC_CTL_EVENT_VALUE:16)
	jr nz, AccStyleCtl_Ending1Bit_Return
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, AccStyleCtl_Ending1Bit_Return
	calr AccSection_ReleaseEnding1
AccStyleCtl_Ending1Bit_Return:
	ret

AccStyleCtl_Ending2Bit:
	cp	(ACC_CTL_EVENT_FIELD:16), 0x05
	jr nz, AccStyleCtl_Ending2Bit_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit 0x05,A
	jr z, .Lc_f59bb1
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, .Lc_f59bb1
	calr AccSection_RequestEnding2
AccStyleCtl_Ending2Bit_Release:
.Lc_f59bb1:
	bit	5, (ACC_CTL_EVENT_MASK:16)
	jr z, AccStyleCtl_Ending2Bit_Return
	bit	5, (ACC_CTL_EVENT_VALUE:16)
	jr nz, AccStyleCtl_Ending2Bit_Return
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, AccStyleCtl_Ending2Bit_Return
	calr AccSection_ReleaseEnding2
AccStyleCtl_Ending2Bit_Return:
	ret

AccStyleCtl_CountInBit:
	cp	(ACC_CTL_EVENT_FIELD:16), 0x05
	jr nz, AccStyleCtl_CountInBit_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit 0x03,A
	jr z, .Lc_f59bde
	calr AccSection_RequestCountIn
AccStyleCtl_CountInBit_Release:
.Lc_f59bde:
	bit	3, (ACC_CTL_EVENT_MASK:16)
	jr z, AccStyleCtl_CountInBit_Return
	bit	3, (ACC_CTL_EVENT_VALUE:16)
	jr nz, AccStyleCtl_CountInBit_Return
	calr AccSection_ReleaseCountIn
AccStyleCtl_CountInBit_Return:
	ret

AccStyleCtl_SyncSectionEvents:
	cp	(PANEL_EVENT_SOURCE:16), 127
	jr	z, AccStyleCtl_SyncSectionEvents_SendEvents
	cp	(PANEL_EVENT_SOURCE:16), 255
	jr	nz, AccStyleCtl_SyncSectionEvents_DispatchAll
AccStyleCtl_SyncSectionEvents_SendEvents:
	calr AccStyleCtl_SendSectionEvents

AccStyleCtl_SyncSectionEvents_DispatchAll:
	cp	(PANEL_EVENT_SOURCE:16), 255
	jr	z, AccStyleCtl_SyncSectionEvents_Return
	call	AccPedal_SendCtrl1
	call	AccPedal_SendCtrl2
	call	AccPedal_SendCtrl3
	call	AccPedal_SendCtrl4
AccStyleCtl_SyncSectionEvents_Return:
	ret

AccPedal_SendCtrl1:
	ld	a, (0x33ca:16)
	xor	a, 255
	and	a, (0x33cb:16)
	cp	a, 0:i3
	jr	z, AccPedal_SendCtrl1_Return
	bit	3, (PANEL_MIDI+6:16)
	jr	z, AccPedal_SendCtrl1_CheckPort
	ld	b, 5:opc
	ld	d, a
	ld	e, (0x33ca:16)
	ld	xix, 14384
	ld	(xix+0:8), 72
	ld	(xix+1), b
	ld	(xix+2), e
	ld	(xix+3), d
	push	xix
	call	MidiPkt_DispatchViaTable_4DCE
	inc	4, xsp
AccPedal_SendCtrl1_CheckPort:
	bit	4, (PANEL_MIDI:16)
	jr	nz, AccPedal_SendCtrl1_Return
	ld	a, (0x9024:16)
	and	a, 143
	ld	(0x9025:16), a
	cp	(PANEL_EVENT_SOURCE:16), 127
	jr	nz, AccPedal_SendCtrl1_UpdateMask
	and	(0x9025:16), 127
AccPedal_SendCtrl1_UpdateMask:
	ld	a, (13258:16)
	xor	a, 255
	and	a, (13259:16)
	ld	b, 5:opc
	ld	c, 72:opc
	ld	d, a
	ld	e, (13258:16)
	call	MIDI_DispatchCC
AccPedal_SendCtrl1_Return:
	ret

AccPedal_SendCtrl2:
	ld	a, (0x33ce:16)
	xor	a, 255
	and	a, (0x33cf:16)
	cp	a, 0:i3
	jr	z, AccPedal_SendCtrl2_Return
	bit	3, (PANEL_MIDI+6:16)
	jr	z, AccPedal_SendCtrl2_CheckPort
	ld	b, 6:opc
	ld	d, a
	ld	e, (0x33ce:16)
	ld	xix, 14384
	ld	(xix+0:8), 72
	ld	(xix+1), b
	ld	(xix+2), e
	ld	(xix+3), d
	push	xix
	call	MidiPkt_DispatchViaTable_4DCE
	inc	4, xsp
AccPedal_SendCtrl2_CheckPort:
	bit	4, (PANEL_MIDI:16)
	jr	nz, AccPedal_SendCtrl2_Return
	ld	a, (0x9024:16)
	and	a, 143
	ld	(0x9025:16), a
	cp	(PANEL_EVENT_SOURCE:16), 127
	jr	nz, AccPedal_SendCtrl2_UpdateMask
	and	(0x9025:16), 127
AccPedal_SendCtrl2_UpdateMask:
	ld	a, (13262:16)
	xor	a, 255
	and	a, (13263:16)
	ld	b, 6:opc
	ld	c, 72:opc
	ld	d, a
	ld	e, (13262:16)
	call	MIDI_DispatchCC
AccPedal_SendCtrl2_Return:
	ret

AccPedal_SendCtrl3:
	ld	a, (0x33ca:16)
	and	a, (0x33cb:16)
	cp	a, 0:i3
	jr	z, AccPedal_SendCtrl3_Return
	bit	3, (PANEL_MIDI+6:16)
	jr	z, AccPedal_SendCtrl3_CheckPort
	ld	b, 5:opc
	ld	d, a
	ld	e, (0x33ca:16)
	ld	xix, 14384
	ld	(xix+0:8), 72
	ld	(xix+1), b
	ld	(xix+2), e
	ld	(xix+3), d
	push	xix
	call	MidiPkt_DispatchViaTable_4DCE
	inc	4, xsp
AccPedal_SendCtrl3_CheckPort:
	bit	4, (PANEL_MIDI:16)
	jr	nz, AccPedal_SendCtrl3_Return
	ld	a, (0x9024:16)
	and	a, 143
	ld	(0x9025:16), a
	cp	(PANEL_EVENT_SOURCE:16), 127
	jr	nz, AccPedal_SendCtrl3_UpdateMask
	and	(0x9025:16), 127
AccPedal_SendCtrl3_UpdateMask:
	ld	a, (13258:16)
	and	a, (13259:16)
	ld	b, 5:opc
	ld	c, 72:opc
	ld	d, a
	ld	e, (13258:16)
	call	MIDI_DispatchCC
AccPedal_SendCtrl3_Return:
	ret

AccPedal_SendCtrl4:
	ld	a, (0x33ce:16)
	and	a, (0x33cf:16)
	cp	a, 0:i3
	jr	z, AccPedal_SendCtrl4_Return
	bit	3, (PANEL_MIDI+6:16)
	jr	z, AccPedal_SendCtrl4_CheckPort
	ld	b, 6:opc
	ld	d, a
	ld	e, (0x33ce:16)
	ld	xix, 14384
	ld	(xix+0:8), 72
	ld	(xix+1), b
	ld	(xix+2), e
	ld	(xix+3), d
	push	xix
	call	MidiPkt_DispatchViaTable_4DCE
	inc	4, xsp
AccPedal_SendCtrl4_CheckPort:
	bit	4, (PANEL_MIDI:16)
	jr	nz, AccPedal_SendCtrl4_Return
	ld	a, (0x9024:16)
	and	a, 143
	ld	(0x9025:16), a
	cp	(PANEL_EVENT_SOURCE:16), 127
	jr	nz, AccPedal_SendCtrl4_UpdateMask
	and	(0x9025:16), 127
AccPedal_SendCtrl4_UpdateMask:
	ld	a, (13262:16)
	and	a, (13263:16)
	ld	b, 6:opc
	ld	c, 72:opc
	ld	d, a
	ld	e, (13262:16)
	call	MIDI_DispatchCC
AccPedal_SendCtrl4_Return:
	ret

AccPedal_MapToAcc:
	cp	(ACC_CTL_EVENT_FIELD:16), 5
	jr	nz, AccPedal_MapToAcc_Send
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit	6, a
	jr	z, AccPedal_MapToAcc_Send
	call	AccPedal_ScanVoiceSlots
	bit	1, (0xd53:16)
	jr	z, AccPedal_MapToAcc_Send
	or	(0x33c9:16), 64
	or	(0x33c8:16), 64
AccPedal_MapToAcc_Send:
	cp	(ACC_CTL_EVENT_FIELD:16), 5
	jr	nz, AccPedal_MapToAcc_UpdateMask
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit	7, a
	jr	z, AccPedal_MapToAcc_UpdateMask
	call	AccPedal_ScanVoiceSlots
	bit	1, (0xd53:16)
	jr	z, AccPedal_MapToAcc_CheckDir
	or	(0x33c9:16), 128
	or	(0x33c8:16), 128
	jr	AccPedal_MapToAcc_UpdateMask
AccPedal_MapToAcc_CheckDir:
	; ordi8 0x3481, 8 (v7 patched)
	or	(0x33c9:16), 8
	; ordi8 0x3480, 8 (v7 patched)
	or	(0x33c8:16), 8
AccPedal_MapToAcc_UpdateMask:
	cp	(ACC_CTL_EVENT_FIELD:16), 5
	jr	nz, AccPedal_MapToAcc_SetMask
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit	2, a
	jr	z, AccPedal_MapToAcc_SetMask
	call	AccPedal_ScanVoiceSlots
	bit	1, (0xd53:16)
	jr	z, AccPedal_MapToAcc_ClearMask
	or	(0x33c9:16), 16
	or	(0x33c8:16), 16
	jr	AccPedal_MapToAcc_SetMask
AccPedal_MapToAcc_ClearMask:
	; ordi8 0x3481, 4 (v7 patched)
	or	(0x33c9:16), 4
	; ordi8 0x3480, 4 (v7 patched)
	or	(0x33c8:16), 4
AccPedal_MapToAcc_SetMask:
	cp	(ACC_CTL_EVENT_FIELD:16), 6
	jr	nz, AccPedal_MapToAcc_Return
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit	2, a
	jr	z, AccPedal_MapToAcc_Return
	call	AccPedal_ScanVoiceSlots
	bit	1, (0xd53:16)
	jr	z, AccPedal_MapToAcc_Apply
	or	(0x33c9:16), 32
	or	(0x33c8:16), 32
	jr	AccPedal_MapToAcc_Return
AccPedal_MapToAcc_Apply:
	; ordi8 0x3485, 4 (v7 patched)
	or	(0x33cd:16), 4
	; ordi8 0x3484, 4 (v7 patched)
	or	(0x33cc:16), 4
AccPedal_MapToAcc_Return:
	cp	(ACC_CTL_EVENT_FIELD:16), 5
	jr	nz, AccPedal_MapPadding
	ld	a, (ACC_CTL_EVENT_VALUE:16)
	and	a, (ACC_CTL_EVENT_MASK:16)
	bit	5, a
	jr	z, AccPedal_MapPadding
call	AccPedal_ScanVoiceSlots
	bit	1, (0xd53:16)
	jr	z, AccPedal_MapPadding
	or	(0x33c9:16), 32
	or	(0x33c8:16), 32
	jr	AccPedal_MapPadding
AccPedal_MapPadding:
	ret

AccPedal_MapPadding2:
	nop
	nop

AccSection_RequestIntro1:
	bit	2, (ACC_SECTION_BUTTONS_HELD:16)
	jrl nz, AccSection_RequestIntro1_AltRoute
	or	(ACC_SECTION_BUTTONS_HELD:16), 0x04
	bit 2, (PANEL_STYLE+5:16)
	jr nz, .Lc_f59ed3
	or (PANEL_STYLE+5:16), 0x04
	or	(0x33ca:16), 0x04
	or	(0x33c8:16), 0x04
	jr t, .Lc_f59ee9
AccSection_RequestIntro1_SetMask:
.Lc_f59ed3:
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr nz, .Lc_f59ee9
	and (PANEL_STYLE+5:16), 0xfb
	and	(0x33ca:16), 0xfb
	and	(0x33c8:16), 0xfb
AccSection_RequestIntro1_Update64607:
.Lc_f59ee9:
	or	(0x33c9:16), 0x04
	or	(0x33cb:16), 0x04
	bit 3, (PANEL_STYLE+5:16)
	jr z, .Lc_f59f12
	and (PANEL_STYLE+5:16), 0xf7
	and	(0x33c8:16), 0xf7
	or	(0x33c9:16), 0x08
	and	(0x33ca:16), 0xf7
	or	(0x33cb:16), 0x08
AccSection_RequestIntro1_Post:
.Lc_f59f12:
	bit 2, (0xfc60:16)
	jr z, AccSection_RequestIntro1_Finalize
	and (0xfc60:16), 0xfb
	and	(0x33cc:16), 0xfb
	or	(0x33cd:16), 0x04
	and	(0x33ce:16), 0xfb
	or	(0x33cf:16), 0x04
AccSection_RequestIntro1_Finalize:
	bit 6, (0xfc5f:16)
	jr z, AccSection_RequestIntro1_CheckAlt
	and (0xfc5f:16), 191

AccSection_RequestIntro1_CheckAlt:
	bit 7, (0xfc5f:16)
	jr z, AccSection_RequestIntro1_AltRoute
	and (0xfc5f:16), 127

AccSection_RequestIntro1_AltRoute:
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr z, AccSection_RequestIntro1_Return
	and	(ACC_SECTION_BUTTONS_HELD:16), 0xfb
AccSection_RequestIntro1_Return:
	ret

AccSection_ReleaseIntro1_Padding:
	nop
	nop

AccSection_ReleaseIntro1:
	bit	2, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, .Lc_f59f61
	and	(ACC_SECTION_BUTTONS_HELD:16), 0xfb
AccSection_ReleaseIntro1_Clear:
.Lc_f59f61:
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr z, AccSection_ReleaseIntro1_Return
	and (0xfc5f:16), 0xfb
AccSection_ReleaseIntro1_Return:
	ret

AccSection_RequestIntro2_Padding:
	nop
	nop

AccSection_RequestIntro2:
	bit	0, (ACC_SECTION_BUTTONS_HELD:16)
	jrl nz, AccSection_RequestIntro2_AltRoute
	or	(ACC_SECTION_BUTTONS_HELD:16), 0x01
	bit 2, (PANEL_STYLE+6:16)
	jr nz, .Lc_f59f93
	or (PANEL_STYLE+6:16), 0x04
	or	(0x33ce:16), 0x04
	or	(0x33cc:16), 0x04
	jr t, .Lc_f59fa9
AccSection_RequestIntro2_SetMask:
.Lc_f59f93:
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr nz, .Lc_f59fa9
	and (PANEL_STYLE+6:16), 0xfb
	and	(0x33ce:16), 0xfb
	and	(0x33cc:16), 0xfb
AccSection_RequestIntro2_Update64607:
.Lc_f59fa9:
	or	(0x33cd:16), 0x04
	or	(0x33cf:16), 0x04
	bit 3, (PANEL_STYLE+5:16)
	jr z, .Lc_f59fd2
	and (PANEL_STYLE+5:16), 0xf7
	and	(0x33c8:16), 0xf7
	or	(0x33c9:16), 0x08
	and	(0x33ca:16), 0xf7
	or	(0x33cb:16), 0x08
AccSection_RequestIntro2_Post:
.Lc_f59fd2:
	bit 2, (0xfc5f:16)
	jr z, AccSection_RequestIntro2_Finalize
	and (0xfc5f:16), 0xfb
	and	(0x33c8:16), 0xfb
	or	(0x33c9:16), 0x04
	and	(0x33ca:16), 0xfb
	or	(0x33cb:16), 0x04
AccSection_RequestIntro2_Finalize:
	bit 6, (0xfc5f:16)
	jr z, AccSection_RequestIntro2_CheckAlt
	and (0xfc5f:16), 191

AccSection_RequestIntro2_CheckAlt:
	bit 7, (0xfc5f:16)
	jr z, AccSection_RequestIntro2_AltRoute
	and (0xfc5f:16), 127

AccSection_RequestIntro2_AltRoute:
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr z, AccSection_RequestIntro2_Return
	and	(ACC_SECTION_BUTTONS_HELD:16), 0xfe
AccSection_RequestIntro2_Return:
	ret

AccSection_ReleaseIntro2_Padding:
	nop
	nop

AccSection_ReleaseIntro2:
	bit	0, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, .Lc_f5a021
	and	(ACC_SECTION_BUTTONS_HELD:16), 0xfe
AccSection_ReleaseIntro2_Clear:
.Lc_f5a021:
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr z, AccSection_ReleaseIntro2_Return
	and (0xfc60:16), 0xfb
AccSection_ReleaseIntro2_Return:
	ret

AccSection_RequestEnding1_Padding:
	nop
	nop

AccSection_RequestEnding1:
	bit	4, (ACC_SECTION_BUTTONS_HELD:16)
	jrl nz, AccSection_RequestEnding1_Return
	or	(ACC_SECTION_BUTTONS_HELD:16), 0x10
	or (PANEL_STYLE+5:16), 0x10
	or	(0x33c9:16), 0x10
	or	(0x33c8:16), 0x10
	or	(0x33cb:16), 0x10
	or	(0x33ca:16), 0x10
	bit 5, (0xfc5f:16)
	jr z, AccSection_RequestEnding1_SetMask
	and (0xfc5f:16), 0xdf
AccSection_RequestEnding1_SetMask:
	bit 6, (0xfc5f:16)
	jr z, AccSection_RequestEnding1_Update
	and (0xfc5f:16), 191

AccSection_RequestEnding1_Update:
	bit 7, (0xfc5f:16)
	jr z, AccSection_RequestEnding1_Post
	and (0xfc5f:16), 127

AccSection_RequestEnding1_Post:
	bit	2, (0xfc5f:16)
	jr	z, AccSection_RequestEnding1_Finalize
	and	(0xfc5f:16), 251
	or	(0x33cb:16), 4
	and	(0x33ca:16), 251
	or	(0x33c9:16), 4
	and	(0x33c8:16), 251
AccSection_RequestEnding1_Finalize:
	bit	3, (0xfc5f:16)
	jr	z, AccSection_RequestEnding1_CheckAlt
	and	(0xfc5f:16), 247
	or	(0x33cb:16), 8
	and	(0x33ca:16), 247
	or	(0x33c9:16), 8
	and	(0x33c8:16), 247
AccSection_RequestEnding1_CheckAlt:
	bit	2, (0xfc60:16)
	jr	z, AccSection_RequestEnding1_Return
	and	(0xfc60:16), 251
	or	(0x33cf:16), 4
	and	(0x33ce:16), 251
	or	(0x33cd:16), 4
	and	(0x33cc:16), 251
AccSection_RequestEnding1_Return:
	ret

AccSection_ReleaseEnding1_Padding:
	nop
	nop

AccSection_ReleaseEnding1:
	bit	4, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, AccSection_ReleaseEnding1_Return
	and	(ACC_SECTION_BUTTONS_HELD:16), 0xef
	or	(0x33c9:16), 0x10
	and	(0x33c8:16), 0xef
	or	(0x33cb:16), 0x10
	and	(0x33ca:16), 0xef
AccSection_ReleaseEnding1_Return:
	ret

AccSection_ReleaseEnding1_Padding2:
	nop
	nop

AccSection_RequestEnding2:
	bit	5, (ACC_SECTION_BUTTONS_HELD:16)
	jrl nz, AccSection_RequestEnding2_Return
	or	(ACC_SECTION_BUTTONS_HELD:16), 0x20
	or (PANEL_STYLE+5:16), 0x20
	or	(0x33c9:16), 0x20
	or	(0x33c8:16), 0x20
	or	(0x33cb:16), 0x20
	or	(0x33ca:16), 0x20
	bit 4, (0xfc5f:16)
	jr z, AccSection_RequestEnding2_SetMask
	and (0xfc5f:16), 0xef
AccSection_RequestEnding2_SetMask:
	bit 6, (0xfc5f:16)
	jr z, AccSection_RequestEnding2_Update
	and (0xfc5f:16), 191

AccSection_RequestEnding2_Update:
	bit 7, (0xfc5f:16)
	jr z, AccSection_RequestEnding2_Post
	and (0xfc5f:16), 127

AccSection_RequestEnding2_Post:
	bit	2, (0xfc5f:16)
	jr	z, AccSection_RequestEnding2_Finalize
	and	(0xfc5f:16), 251
	or	(0x33cb:16), 4
	and	(0x33ca:16), 251
	or	(0x33c9:16), 4
	and	(0x33c8:16), 251
AccSection_RequestEnding2_Finalize:
	bit	3, (0xfc5f:16)
	jr	z, AccSection_RequestEnding2_CheckAlt
	and	(0xfc5f:16), 247
	or	(0x33cb:16), 8
	and	(0x33ca:16), 247
	or	(0x33c9:16), 8
	and	(0x33c8:16), 247
AccSection_RequestEnding2_CheckAlt:
	bit	2, (0xfc60:16)
	jr	z, AccSection_RequestEnding2_Return
	and	(0xfc60:16), 251
	or	(0x33cf:16), 4
	and	(0x33ce:16), 251
	or	(0x33cd:16), 4
	and	(0x33cc:16), 251
AccSection_RequestEnding2_Return:
	ret

AccSection_ReleaseEnding2_Padding:
	nop
	nop

AccSection_ReleaseEnding2:
	bit	5, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, AccSection_ReleaseEnding2_Return
	and	(ACC_SECTION_BUTTONS_HELD:16), 0xdf
	or	(0x33c9:16), 0x20
	and	(0x33c8:16), 0xdf
	or	(0x33cb:16), 0x20
	and	(0x33ca:16), 0xdf
AccSection_ReleaseEnding2_Return:
	ret

AccSection_RequestFillIn1_Padding:
	nop
	nop

AccSection_RequestFillIn1:
	bit	6, (ACC_SECTION_BUTTONS_HELD:16)
	jrl nz, AccSection_RequestFillIn1_Return
	or	(ACC_SECTION_BUTTONS_HELD:16), 0x40
	or (PANEL_STYLE+5:16), 0x40
	or	(0x33c9:16), 0x40
	or	(0x33c8:16), 0x40
	or	(0x33cb:16), 0x40
	or	(0x33ca:16), 0x40
	bit 4, (0xfc5f:16)
	jr z, AccSection_RequestFillIn1_SetMask
	and (0xfc5f:16), 0xef
AccSection_RequestFillIn1_SetMask:
	bit 5, (0xfc5f:16)
	jr z, AccSection_RequestFillIn1_Update
	and (0xfc5f:16), 223

AccSection_RequestFillIn1_Update:
	bit	2, (0xfc5f:16)
	jr	z, AccSection_RequestFillIn1_Post
	and	(0xfc5f:16), 251
	or	(0x33cb:16), 4
	and	(0x33ca:16), 251
	or	(0x33c9:16), 4
	and	(0x33c8:16), 251
AccSection_RequestFillIn1_Post:
	bit	3, (0xfc5f:16)
	jr	z, AccSection_RequestFillIn1_Finalize
	and	(0xfc5f:16), 247
	or	(0x33cb:16), 8
	and	(0x33ca:16), 247
	or	(0x33c9:16), 8
	and	(0x33c8:16), 247
AccSection_RequestFillIn1_Finalize:
	bit	2, (0xfc60:16)
	jr	z, AccSection_RequestFillIn1_CheckAlt
	and	(0xfc60:16), 251
	or	(0x33cf:16), 4
	and	(0x33ce:16), 251
	or	(0x33cd:16), 4
	and	(0x33cc:16), 251
AccSection_RequestFillIn1_CheckAlt:
	bit 7, (0xfc5f:16)
	jr z, AccSection_RequestFillIn1_Return
	and (0xfc5f:16), 127

AccSection_RequestFillIn1_Return:
	ret

AccSection_ReleaseFillIn1_Padding:
	nop
	nop

AccSection_ReleaseFillIn1:
	bit	6, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, AccSection_ReleaseFillIn1_Return
	and	(ACC_SECTION_BUTTONS_HELD:16), 0xbf
	or	(0x33c9:16), 0x40
	and	(0x33c8:16), 0xbf
	or	(0x33cb:16), 0x40
	and	(0x33ca:16), 0xbf
AccSection_ReleaseFillIn1_Return:
	ret

AccSection_ReleaseFillIn1_Padding2:
	nop
	nop

AccSection_RequestCountIn:
	bit	3, (ACC_SECTION_BUTTONS_HELD:16)
	jrl nz, AccSection_RequestCountIn_FinalCheck
	or	(ACC_SECTION_BUTTONS_HELD:16), 0x08
	bit 3, (PANEL_STYLE+5:16)
	jr nz, .Lc_f5a2ab
	or (PANEL_STYLE+5:16), 0x08
	or	(0x33ca:16), 0x08
	or	(0x33c8:16), 0x08
	jr t, .Lc_f5a2c1
AccSection_RequestCountIn_SetMask:
.Lc_f5a2ab:
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr nz, .Lc_f5a2c1
	and (PANEL_STYLE+5:16), 0xf7
	and	(0x33ca:16), 0xf7
	and	(0x33c8:16), 0xf7
AccSection_RequestCountIn_Update:
.Lc_f5a2c1:
	or	(0x33c9:16), 0x08
	or	(0x33cb:16), 0x08
	bit 2, (PANEL_STYLE+5:16)
	jr z, .Lc_f5a2ea
	and (PANEL_STYLE+5:16), 0xfb
	and	(0x33c8:16), 0xfb
	or	(0x33c9:16), 0x04
	and	(0x33ca:16), 0xfb
	or	(0x33cb:16), 0x04
AccSection_RequestCountIn_Post:
.Lc_f5a2ea:
	bit 2, (0xfc60:16)
	jr z, AccSection_RequestCountIn_Finalize
	and (0xfc60:16), 0xfb
	and	(0x33cc:16), 0xfb
	or	(0x33cd:16), 0x04
	and	(0x33ce:16), 0xfb
	or	(0x33cf:16), 0x04
AccSection_RequestCountIn_Finalize:
	bit 6, (0xfc5f:16)
	jr z, AccSection_RequestCountIn_CheckAlt
	and (0xfc5f:16), 191

AccSection_RequestCountIn_CheckAlt:
	bit 7, (0xfc5f:16)
	jr z, AccSection_RequestCountIn_AltRoute
	and (0xfc5f:16), 127

AccSection_RequestCountIn_AltRoute:
	bit 4, (0xfc5f:16)
	jr z, AccSection_RequestCountIn_Apply
	and (0xfc5f:16), 239

AccSection_RequestCountIn_Apply:
	bit 5, (0xfc5f:16)
	jr z, AccSection_RequestCountIn_FinalCheck
	and (0xfc5f:16), 223

AccSection_RequestCountIn_FinalCheck:
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr z, AccSection_RequestCountIn_Return
	and	(ACC_SECTION_BUTTONS_HELD:16), 0xf7
AccSection_RequestCountIn_Return:
	ret

AccSection_ReleaseCountIn_Padding:
	nop
	nop

AccSection_ReleaseCountIn:
	bit	3, (ACC_SECTION_BUTTONS_HELD:16)
	jr z, .Lc_f5a34f
	and	(ACC_SECTION_BUTTONS_HELD:16), 0xf7
AccSection_ReleaseCountIn_Clear:
.Lc_f5a34f:
	cp	(PANEL_EVENT_SOURCE:16), 0x7f
	jr z, AccSection_ReleaseCountIn_Return
	and (0xfc5f:16), 0xf7
AccSection_ReleaseCountIn_Return:
	ret

AccSection_ReleaseCountIn_Padding2:
	nop
	nop

AccSection_RequestFillIn2:
	bit	7, (ACC_SECTION_BUTTONS_HELD:16)
	jrl nz, AccSection_RequestFillIn2_Return
	or	(ACC_SECTION_BUTTONS_HELD:16), 0x80
	or (PANEL_STYLE+5:16), 0x80
	or	(0x33c9:16), 0x80
	or	(0x33c8:16), 0x80
	or	(0x33cb:16), 0x80
	or	(0x33ca:16), 0x80
	bit 4, (0xfc5f:16)
	jr z, AccSection_RequestFillIn2_SetMask
	and (0xfc5f:16), 0xef
AccSection_RequestFillIn2_SetMask:
	bit 5, (0xfc5f:16)
	jr z, AccSection_RequestFillIn2_Update
	and (0xfc5f:16), 223

AccSection_RequestFillIn2_Update:
	bit	2, (0xfc5f:16)
	jr	z, AccSection_RequestFillIn2_Post
	and	(0xfc5f:16), 251
	or	(0x33cb:16), 4
	and	(0x33ca:16), 251
	or	(0x33c9:16), 4
	and	(0x33c8:16), 251
AccSection_RequestFillIn2_Post:
	bit	3, (0xfc5f:16)
	jr	z, AccSection_RequestFillIn2_Finalize
	and	(0xfc5f:16), 247
	or	(0x33cb:16), 8
	and	(0x33ca:16), 247
	or	(0x33c9:16), 8
	and	(0x33c8:16), 247
AccSection_RequestFillIn2_Finalize:
	bit	2, (0xfc60:16)
	jr	z, AccSection_RequestFillIn2_CheckAlt
	and	(0xfc60:16), 251
	or	(0x33cf:16), 4
	and	(0x33ce:16), 251
	or	(0x33cd:16), 4
	and	(0x33cc:16), 251
AccSection_RequestFillIn2_CheckAlt:
	bit 6, (0xfc5f:16)
	jr z, AccSection_RequestFillIn2_Return
	and (0xfc5f:16), 191

AccSection_RequestFillIn2_Return:
	ret

AccSection_ReleaseFillIn2_Padding:
	nop
	nop

AccSection_ReleaseFillIn2:
	bit	7, (ACC_SECTION_BUTTONS_HELD:16)
	jr	z, AccSection_ReleaseFillIn2_Return
	and	(ACC_SECTION_BUTTONS_HELD:16), 127
	or	(0x33c9:16), 128
	and	(0x33c8:16), 127
	or	(0x33cb:16), 128
	and	(0x33ca:16), 127
AccSection_ReleaseFillIn2_Return:
	ret

AccSection_ReleaseFillIn2_Padding2:
	nop
	nop

AccAutoPlay_NoteDispatch:
	ld W,A
	ld A,C
	cp	(0x7e53:16), 0x00
	jr nz, .Lc_f5a463
	pushw wa
	calr AccStyleCtl_IsStartStopBlocked
	cp a, 1:i3
	popw wa
	jr z, .Lc_f5a463
	bit	2, (SEQ_RTMCFG:16)
	jr nz, .Lc_f5a463
	push XWA
	push XHL
	push XBC
	push XDE
	push XIX
	push XIY
	push XIZ
	call Fade_StartArmedFadeIn
	pop XIZ
	pop XIY
	pop XIX
	pop XDE
	pop XBC
	pop XHL
	pop XWA
	calr AccAutoPlay_SplitDetect
	cp c, 0:i3
	jr z, .Lc_f5a45e
	or	(ACC_SYNCHRO_KEY_EVENT:16), 0x01
AccAutoPlay_NoteDispatch_Check:
.Lc_f5a45e:
	or	(ACC_SYNCHRO_KEY_EVENT:16), 0x80
AccAutoPlay_NoteDispatch_Process:
.Lc_f5a463:
	cpw	(SEQ_REC_TRACKS:16), 0x0000
	jr z, AccAutoPlay_NoteDispatch_Return
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, AccAutoPlay_NoteDispatch_Return
	bit 1, (PANEL_STYLE+5:16)
	jr z, AccAutoPlay_NoteDispatch_Return
	bit	3, (0x2897:16)
	jr z, AccAutoPlay_NoteDispatch_Return
	bit	0, (0x2896:16)
	jr nz, AccAutoPlay_NoteDispatch_Return
	bit	2, (SEQ_CYCLE_FLAGS:16)
	jr nz, AccAutoPlay_NoteDispatch_Return
	bit	0, (ACC_SYNCHRO_KEY_EVENT:16)
	jr z, AccAutoPlay_NoteDispatch_Return
	and	(0x2897:16), 0xf7
	call Audio_CheckSubsystemReady
AccAutoPlay_NoteDispatch_Return:
	ret

AccAutoPlay_SplitDetect:
	ld c, 0x0:opc
	cpw	(SEQ_REC_TRACKS:16), 0
	jr z, AccAutoPlay_SplitDetect_Check
	bit	3, (0x2897:16)
	jr z, AccAutoPlay_SplitDetect_Check
	bit	0, (0x2896:16)
	jr nz, AccAutoPlay_SplitDetect_Return
	bit	2, (SEQ_CYCLE_FLAGS:16)
	jr nz, AccAutoPlay_SplitDetect_Return

AccAutoPlay_SplitDetect_Check:
	bit 7, w
	jr z, AccAutoPlay_SplitDetect_Process
	push_a
	calr AccAutoPlay_ModeAvail
	pop_a
	cp l, a
	jr c, AccAutoPlay_SplitDetect_Upper
	ld c, 0x1:opc
	jr AccAutoPlay_SplitDetect_Return

AccAutoPlay_SplitDetect_Upper:
	ld c, 0x0:opc
	jr AccAutoPlay_SplitDetect_Return

AccAutoPlay_SplitDetect_Process:
	bit 0, (PANEL_MIDI+3:16)
	jr nz, AccAutoPlay_SplitDetect_NoSplit
	and w, 0xf
	ld l, (PANEL_PART_RT1+13:16)
	and l, 0xf
	cp l, w
	jr nz, AccAutoPlay_SplitDetect_Apply

AccAutoPlay_SplitDetect_Lower:
	push_a
	calr AccAutoPlay_ModeAvail
	pop_a
	cp l, a
	jr c, AccAutoPlay_SplitDetect_Apply
	ld c, 0x1:opc
	jr AccAutoPlay_SplitDetect_Return

AccAutoPlay_SplitDetect_Apply:
	ld c, 0x0:opc
	jr AccAutoPlay_SplitDetect_Return

AccAutoPlay_SplitDetect_NoSplit:
	and w, 0xf
	ld l, (PANEL_PART_LEFT+13:16)
	bit 7, l
	jr nz, AccAutoPlay_SplitDetect_Store
	and l, 0xf
	cp l, w
	jr nz, AccAutoPlay_SplitDetect_Store
	ld c, 0x1:opc
	jr AccAutoPlay_SplitDetect_Return

AccAutoPlay_SplitDetect_Store:
	ld l, (PANEL_PART_CHRD+13:16)
	bit 7, l
	jr nz, AccAutoPlay_SplitDetect_Return
	and l, 0xf
	cp l, w
	jr nz, AccAutoPlay_SplitDetect_Return
	ld c, 0x1:opc

AccAutoPlay_SplitDetect_Return:
	ret

AccAutoPlay_ZoneTrack:
	cp	(0x7e53:16), 0x00
	jr nz, AccAutoPlay_ZoneTrack_Update
	pushw wa
	calr AccStyleCtl_IsStartStopBlocked
	cp a, 1:i3
	popw wa
	jr z, AccAutoPlay_ZoneTrack_Update
	bit	2, (SEQ_RTMCFG:16)
	jr nz, AccAutoPlay_ZoneTrack_Update
	calr AccAutoPlay_ZoneTrack_Apply
	ld	hl, (ACC_CHORD_KEYS_NOW:16)
	ld	(ACC_CHORD_KEYS_PREV:16), hl
	ld	(ACC_CHORD_KEYS_NOW:16), wa
AccAutoPlay_ZoneTrack_Update:
	ret

AccAutoPlay_ZoneTrack_Apply:
	ld	xix, CHORD_HELD_KEY_COUNT
	ld	wa, (xix+2)
	cp	wa, 0:i3
	jr	nz, AccAutoPlay_ZoneTrack_Check
	ld	l, 128:opc
	jr	AccAutoPlay_ZoneTrack_Store
AccAutoPlay_ZoneTrack_Check:
	cp wa, 1:i3
	jr nz, AccAutoPlay_ZoneTrack_Upper
	ld l, 0x0:opc
	jr AccAutoPlay_ZoneTrack_Store

AccAutoPlay_ZoneTrack_Upper:
	ld l, 0xf0:opc

AccAutoPlay_ZoneTrack_Store:
	ld w, l

	calr AccAutoPlay_ZoneTrack_SetFlag

	ldw	(14384:16), 0

	ld bc, (xix + 0:8)

	ld e, 0x5:opc



AccAutoPlay_ZoneTrack_Clear:
	cp	bc, 0:i3
	jr	z, AccAutoPlay_ZoneTrack_Default
	ld	a, (xix+e)
	cp	l, a
	jr	c, AccAutoPlay_ZoneTrack_Finalize
	incw	1, (14384:16)
AccAutoPlay_ZoneTrack_Finalize:
	inc 2, e
	dec 1, bc
	jr AccAutoPlay_ZoneTrack_Clear

AccAutoPlay_ZoneTrack_Default:
	ld	wa, (14384:16)
	ret
AccAutoPlay_ZoneTrack_SetFlag:
	ld c, 0x0:opc
	bit 7, w
	jr z, AccAutoPlay_ZoneTrack_Done
	calr AccAutoPlay_ModeAvail
	jr AccAutoPlay_ZoneTrack_Return2

AccAutoPlay_ZoneTrack_Done:
	bit 0, (PANEL_MIDI+3:16)
	jr nz, AccAutoPlay_ZoneTrack_Final
	calr AccAutoPlay_ModeAvail
	jr AccAutoPlay_ZoneTrack_Return2

AccAutoPlay_ZoneTrack_Final:
	ld l, 0x7f:opc

AccAutoPlay_ZoneTrack_Return2:
	ret

AccAutoPlay_ZoneTrack_Return:
	ret

AccAutoPlay_StateMachine:
	calr AccSynchro_OnChordKeyEvent
	bit	6, (ACC_SYNCHRO_ACTION:16)
	jr z, .Lc_f5a5da
	cpw (SEQ_TRACK_MASK:16), 0x0000
	jr z, .Lc_f5a5da
	cpw	(SEQ_REC_TRACKS:16), 0x0000
	jr nz, .Lc_f5a5da
	calr AccSynchro_UpdateArmed
	bit	7, (ACC_SYNCHRO_STATE:16)
	jr nz, .Lc_f5a5da
	calr AccSynchro_Disarm
AccAutoPlay_SM_CheckEligible:
.Lc_f5a5da:
	ld	(0x33bc:16), 0x00
	calr AccAutoPlay_ActionDispatch
	bit	0, (0x33bc:16)
	jr z, AccAutoPlay_SM_Return
	ld	(0x33bc:16), 0x00
	or	(ACC_SYNCHRO_ACTION:16), 0x04
	calr AccReplay_FullRestart
AccAutoPlay_SM_Return:
	ret

AccAutoPlay_SM_Padding:
	nop
	nop

AccSynchro_OnChordKeyEvent:
	bit	2, (SEQ_RTMCFG:16)
	jrl nz, AccAutoPlay_ModeAvail_Padding2
	calr AccSynchro_UpdateArmed
	bit	0, (ACC_SYNCHRO_KEY_EVENT:16)
	jrl z, AccAutoPlay_ModeAvail_Padding2
	bit	0, (ACC_SYNCHRO_TRIGGERED:16)
	jrl nz, AccAutoPlay_Trigger_Activate
	bit	7, (ACC_SYNCHRO_STATE:16)
	jr nz, AccAutoPlay_Trigger_Evaluate
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, AccAutoPlay_Trigger_Process
	bit 1, (PANEL_STYLE+5:16)
	jr z, AccAutoPlay_Trigger_Process
AccAutoPlay_Trigger_Evaluate:
	calr AccAutoPlay_Configure

AccAutoPlay_Trigger_Process:
	or	(ACC_SYNCHRO_KEY_EVENT:16), 1
	or	(ACC_SYNCHRO_TRIGGERED:16), 1
	jr	AccAutoPlay_ModeAvail_Padding
AccAutoPlay_Trigger_Activate:
	bit	7, (ACC_SYNCHRO_KEY_EVENT:16)
	jr nz, AccAutoPlay_ModeAvail_Padding
	bit	7, (ACC_SYNCHRO_STATE:16)
	jr z, AccAutoPlay_Trigger_Return
	cpw	(ACC_CHORD_KEYS_NOW:16), 0x0000
	jr nz, .Lc_f5a662
	cpw	(ACC_CHORD_KEYS_PREV:16), 0x0000
	jr z, .Lc_f5a662
	calr AccSynchro_StopOnChordRelease
	and	(ACC_SYNCHRO_KEY_EVENT:16), 0xfe
	and	(ACC_SYNCHRO_TRIGGERED:16), 0xfe
	ldw	(ACC_CHORD_KEYS_PREV:16), 0x0000
	jr t, AccAutoPlay_ModeAvail_Padding
AccAutoPlay_Trigger_Configure:
.Lc_f5a662:
	cpw	(ACC_CHORD_KEYS_NOW:16), 0x0000
	jr nz, AccAutoPlay_Trigger_Finalize
	cpw	(ACC_CHORD_KEYS_PREV:16), 0x0000
	jr nz, AccAutoPlay_Trigger_Finalize
	ld	(ACC_SYNCHRO_KEY_EVENT:16), 0x00
	ld	(ACC_SYNCHRO_TRIGGERED:16), 0x00
AccAutoPlay_Trigger_Finalize:
	jr AccAutoPlay_ModeAvail_Padding

AccAutoPlay_Trigger_Return:
	and	(ACC_SYNCHRO_KEY_EVENT:16), 254
	and	(ACC_SYNCHRO_TRIGGERED:16), 254
	jr	AccAutoPlay_ModeAvail_Padding
AccAutoPlay_ModeAvail_Padding:
	; anddi8 (0x3498), 127 (v7 patched)
	and	(ACC_SYNCHRO_KEY_EVENT:16), 127
AccAutoPlay_ModeAvail_Padding2:
	ret

AccAutoPlay_ModeAvail_Padding3:
	nop
	nop

AccAutoPlay_ModeAvail:
	ld l, (PANEL_PLAY_SETTINGS:16)
	and l, 0x3
	cp l, 0:i3
	jr nz, AccAutoPlay_ModeAvail_Process
	ld l, (PANEL_PLAY_SETTINGS+1:16)
	and l, 0x7f
	dec 1, l
	cp l, 0xff
	jr nz, AccAutoPlay_ModeAvail_Check
	ld l, 0x0:opc

AccAutoPlay_ModeAvail_Check:
	jr AccAutoPlay_ModeAvail_SetMode

AccAutoPlay_ModeAvail_Process:
	push l
	ld xhl, 0:i3
	pop l
	add xhl, AccAutoPlay_ModeAvail_Values
	ld l, (xhl)

AccAutoPlay_ModeAvail_SetMode:
	cp	(CURRENT_MODE:16), 14
	jr	nz, AccAutoPlay_ModeAvail_Return
	ld	l, 127:opc
AccAutoPlay_ModeAvail_Return:
	ret

	.byte	0x00, 0x00	; padding
AccAutoPlay_ModeAvail_Values:
	; AccAutoPlay_ModeAvail_Process: L := this[(0xFD02) & 3] for (0xFD02) & 3 = 1..3; the fifth
	; byte pads the code below to an even address.
	.byte	0x3b, 0x36, 0x3b, 0x42, 0x47
	; No reference found.  Returns unless bit 2 of (0x041E) is clear, bit 1 of (0x33D2) set, bit 0
	; of (0x33FC) set and bit 0 of (0x33FD) clear; then calls AccAutoPlay_Configure, copies (0x33FC)
	; to (0x33FD) and sets bit 0 of (0x33FC).  Was a `.byte` run until 2026-10-03.
AccAutoPlay_ConfigureIfPending:
	bit	2, (ACC_TRANSPORT_STATE:16)
	jr	nz, AccAutoPlay_ConfigureIfPending_Return
	bit	1, (ACC_SYNCHRO_ACTION:16)
	jr	z, AccAutoPlay_ConfigureIfPending_Return
	bit	0, (ACC_SYNCHRO_KEY_EVENT:16)
	jr	z, AccAutoPlay_ConfigureIfPending_Return
	bit	0, (ACC_SYNCHRO_TRIGGERED:16)
	jr	nz, AccAutoPlay_ConfigureIfPending_Return
	calr	AccAutoPlay_Configure
	ld	a, (ACC_SYNCHRO_KEY_EVENT:16)
	ld	(ACC_SYNCHRO_TRIGGERED:16), a
	or	(ACC_SYNCHRO_KEY_EVENT:16), 1
AccAutoPlay_ConfigureIfPending_Return:
	ret
AccSynchro_UpdateArmed:
	cpw	(SEQ_REC_TRACKS:16), 0x0000
	jr nz, AccSynchro_UpdateArmed_Off
	cpw (SEQ_TRACK_MASK:16), 0x0000
	jr nz, AccSynchro_UpdateArmed_Off
	cp	(CMP_RECORD_PART:16), 0x00
	jr nz, AccSynchro_UpdateArmed_Off
	ld a, (PANEL_STYLE+3:16)
	bit 0x03,A
	jr nz, AccSynchro_UpdateArmed_Off
	and A,0x07
	cp a, 0:i3
	jr z, AccSynchro_UpdateArmed_Off
	bit 1, (PANEL_STYLE+5:16)
	jr z, AccSynchro_UpdateArmed_Off
	or	(ACC_SYNCHRO_STATE:16), 0x80
	jr t, AccSynchro_UpdateArmed_Return
AccSynchro_UpdateArmed_Off:
	ld	(ACC_SYNCHRO_STATE:16), 0
AccSynchro_UpdateArmed_Return:
	ret

AccAutoPlay_Configure:
	and	(ACC_SYNCHRO_ACTION:16), 0x1f
	cp	(CMP_RECORD_PART:16), 0x00
	jr nz, .Lc_f5a74f
	cpw	(SEQ_REC_TRACKS:16), 0x0000
	jr nz, .Lc_f5a759
	cpw (SEQ_TRACK_MASK:16), 0x0000
	jr z, .Lc_f5a74f
	jr t, AccAutoPlay_Configure_Store
AccAutoPlay_Configure_Mode1:
.Lc_f5a74f:
	or	(ACC_SYNCHRO_ACTION:16), 0xa0
	calr AccSynchro_StartOrCancelStop
	jr t, AccAutoPlay_Configure_Return
AccAutoPlay_Configure_Mode2:
.Lc_f5a759:
	cpw (SEQ_TRACK_MASK:16), 0x0000
	jr nz, AccAutoPlay_Configure_Store
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr z, .Lc_f5a76e
	or	(ACC_SYNCHRO_ACTION:16), 0x80
	jr t, AccAutoPlay_Configure_Check
AccAutoPlay_Configure_Apply:
.Lc_f5a76e:
	or	(ACC_SYNCHRO_ACTION:16), 0xe0



AccAutoPlay_Configure_Check:
	jr AccAutoPlay_Configure_Return

AccAutoPlay_Configure_Store:
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccAutoPlay_Configure_Return
	calr AccAutoPlay_ModeDecode
	calr AccSynchro_StartOrCancelStopSong

AccAutoPlay_Configure_Return:
	ret

AccAutoPlay_Configure_Extended:
	nop
	nop
	bit	1, (ACC_SYNCHRO_ACTION:16)
	jr	nz, AccAutoPlay_Configure_Final
	and	(ACC_SYNCHRO_TRIGGERED:16), 0xfe
	and	(ACC_SYNCHRO_KEY_EVENT:16), 0xfe
	jr	AccAutoPlay_Configure_Return2
AccAutoPlay_Configure_Final:
	bit	0, (ACC_SYNCHRO_KEY_EVENT:16)
	jr	nz, AccAutoPlay_Configure_Return2
	bit	0, (ACC_SYNCHRO_TRIGGERED:16)
	jr	z, AccAutoPlay_Configure_Return2
	bit	7, (ACC_SYNCHRO_STATE:16)
	jr	z, AccAutoPlay_Configure_Done
	calr	AccSynchro_StopOnChordRelease
AccAutoPlay_Configure_Done:
	and	(ACC_SYNCHRO_TRIGGERED:16), 0xfe
	and	(ACC_SYNCHRO_KEY_EVENT:16), 0xfe
AccAutoPlay_Configure_Return2:
	ret
	nop
	nop


AccSynchro_PeriodicCheck:
	bit 1, (PANEL_STYLE+5:16)
	jr nz, AccAutoPlay_Periodic_Evaluate
	jr AccAutoPlay_Periodic_Return

AccAutoPlay_Periodic_Evaluate:
	bit	2, (ACC_SYNCHRO_ACTION:16)
	jr	z, AccAutoPlay_Periodic_Process
	calr	AccSynchro_UpdateArmed
	bit	7, (ACC_SYNCHRO_STATE:16)
	jr	nz, AccAutoPlay_Periodic_Padding
	calr	AccSynchro_Disarm
	jr	AccAutoPlay_Periodic_Padding
AccAutoPlay_Periodic_Padding:
	and	(ACC_SYNCHRO_ACTION:16), 251
	jr	AccAutoPlay_Periodic_Return
AccAutoPlay_Periodic_Process:
	cpw (SEQ_TRACK_MASK:16), 0
	jr nz, AccAutoPlay_Periodic_Toggle
	cpw	(SEQ_REC_TRACKS:16), 0
	jr z, AccAutoPlay_Periodic_Return

AccAutoPlay_Periodic_Toggle:
	calr AccSynchro_Disarm

AccAutoPlay_Periodic_Return:
	ret

AccSynchro_Disarm:
	and (PANEL_STYLE+5:16), 253

	ld w, 0x2:opc

	ld a, 0x0:opc

	ld d, 0x5:opc

	ld e, 0x48:opc

call	SwbtWr_QueuePostEvent

	ret



AccSynchro_Disarm_Padding:
	nop
	nop

AccSynchro_StartOrCancelStop:
	bit	7, (ACC_SYNCHRO_STATE:16)
	jr z, AccSynchro_StartOrCancelStop_Return
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, .Lc_f5a833
	bit	0, (ACC_RUN_FLAGS:16)
	jr z, .Lc_f5a827
	bit	1, (ACC_RUN_FLAGS:16)
	jr z, .Lc_f5a827
	and	(ACC_SYNCHRO_STATE:16), 0xef
	or	(ACC_SYNCHRO_STATE:16), 0x01
	jr t, AccSynchro_StartOrCancelStop_Return
AccSynchro_StartOrCancelStop_Now:
.Lc_f5a827:
	and	(ACC_SYNCHRO_STATE:16), 0xef
	or	(ACC_SYNCHRO_STATE:16), 0x04
	jr t, AccSynchro_StartOrCancelStop_Return
AccSynchro_StartOrCancelStop_Running:
.Lc_f5a833:
	ld a, (PLAY_TRANSPORT_STATE:16)
	bit 0x02,A
	jr z, AccSynchro_StartOrCancelStop_Return
	bit 0x03,A
	jr z, AccSynchro_StartOrCancelStop_Return
	and (PLAY_TRANSPORT_STATE:16), 0xf7
	and (ACC_TRANSPORT_STATE:16), 0xf7
	and	(ACC_SYNCHRO_STATE:16), 0xef
	or	(ACC_SYNCHRO_STATE:16), 0x08
AccSynchro_StartOrCancelStop_Return:
	ret

AccSynchro_StartOrCancelStop_Padding:
	nop
	nop

AccSynchro_StartOrCancelStopSong:
	bit	7, (ACC_SYNCHRO_STATE:16)
	jr z, AccSynchro_StartOrCancelStopSong_Return
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, .Lc_f5a888
	bit	0, (ACC_RUN_FLAGS:16)
	jr z, .Lc_f5a87c
	bit	1, (ACC_RUN_FLAGS:16)
	jr z, .Lc_f5a87c
	and	(ACC_SYNCHRO_STATE:16), 0xef
	or	(ACC_SYNCHRO_STATE:16), 0x02
	jr t, AccSynchro_StartOrCancelStopSong_Return
AccSynchro_StartOrCancelStopSong_Now:
.Lc_f5a87c:
	and	(ACC_SYNCHRO_STATE:16), 0xef
	or	(ACC_SYNCHRO_STATE:16), 0x04
	jr t, AccSynchro_StartOrCancelStopSong_Return
AccSynchro_StartOrCancelStopSong_Running:
.Lc_f5a888:
	ld a, (PLAY_TRANSPORT_STATE:16)
	bit 0x02,A
	jr z, AccSynchro_StartOrCancelStopSong_Return
	bit 0x03,A
	jr z, AccSynchro_StartOrCancelStopSong_Return
	and (PLAY_TRANSPORT_STATE:16), 0xf7
	and (ACC_TRANSPORT_STATE:16), 0xf7
	and (SEQ_TRANSPORT_STATE:16), 0xf7
	and	(ACC_SYNCHRO_STATE:16), 0xef
	or	(ACC_SYNCHRO_STATE:16), 0x08
AccSynchro_StartOrCancelStopSong_Return:
	ret

AccSynchro_StartOrCancelStopSong_Padding:
	nop
	nop

AccSynchro_StopOnChordRelease:
	cp	(CMP_RECORD_PART:16), 0x00
	jr nz, AccSynchro_StopOnChordRelease_Return
	cpw	(SEQ_RECORDING_TRACKS:16), 0x0000
	jr nz, AccSynchro_StopOnChordRelease_Return
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, AccSynchro_StopOnChordRelease_Return
	and	(ACC_SYNCHRO_STATE:16), 0xf7
	or	(ACC_SYNCHRO_STATE:16), 0x10
	cpw (SEQ_TRACK_MASK:16), 0x0000
	jr nz, AccSynchro_StopOnChordRelease_Song
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr z, AccSynchro_StopOnChordRelease_Return
	ei 0x06
	calr AccPlayMode_StopPlayAndAcc
	ei 0x00
	jr t, AccSynchro_StopOnChordRelease_Return
AccSynchro_StopOnChordRelease_Song:
	bit 2, (SEQ_TRANSPORT_STATE:16)
	jr z, AccSynchro_StopOnChordRelease_Return
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, AccSynchro_StopOnChordRelease_SongStopped
	ei 6
	calr AccPlayMode_StopExprFull
	ei 0
	jr AccSynchro_StopOnChordRelease_Return

AccSynchro_StopOnChordRelease_SongStopped:
	ei 6
	calr AccPlayMode_StopExprC
	ei 0

AccSynchro_StopOnChordRelease_Return:
	ret

AccSynchro_StopOnChordRelease_Padding:
	nop
	nop

AccAutoPlay_ModeDecode:
	ld	a, (SEQ_RTMCFG:16)
	and A,0x03
	cp a, 2:i3
	jr nz, .Lc_f5a919
	or	(ACC_SYNCHRO_ACTION:16), 0xa0
	jr t, AccAutoPlay_ModeDecode_Return
AccAutoPlay_ModeDecode_Process:
.Lc_f5a919:
	cp a, 1:i3
	jr nz, .Lc_f5a924
	or	(ACC_SYNCHRO_ACTION:16), 0x60
	jr t, AccAutoPlay_ModeDecode_Return
AccAutoPlay_ModeDecode_Apply:
.Lc_f5a924:
	cp a, 3:i3
	jr nz, AccAutoPlay_ModeDecode_Return
	or	(ACC_SYNCHRO_ACTION:16), 0xe0
AccAutoPlay_ModeDecode_Return:
	ret

AccAutoPlay_ModeDecode_Padding:
	nop
	nop

AccAutoPlay_ActionDispatch:
	ld	a, (ACC_SYNCHRO_STATE:16)
	bit 0x07,A
	jr z, AccAutoPlay_Action_Check
	bit	2, (ACC_SYNCHRO_STATE:16)
	jr z, AccAutoPlay_Action_Finalize
	and A,0xfb
	or A,0x08
	ld	(ACC_SYNCHRO_STATE:16), a
AccAutoPlay_Action_Check:
	ld	a, (ACC_SYNCHRO_ACTION:16)
	ld	b, a
	and	a, 224
	cp	a, 0:i3
	ld	a, b
	jr	z, AccAutoPlay_Action_Return
	bit	7, a
	jr	z, AccAutoPlay_Action_Activate
	bit	5, a
	jr	nz, AccAutoPlay_Action_Process
	calr	AccPlayMode_StartAccPlay
	jr	AccAutoPlay_Action_Apply
AccAutoPlay_Action_Process:
	bit 6, a
	jr z, AccAutoPlay_Action_Deactivate
	calr AccPlayMode_StopExprB
	jr AccAutoPlay_Action_Apply

AccAutoPlay_Action_Activate:
	calr AccPlayMode_StartPlayFull
	jr AccAutoPlay_Action_Apply

AccAutoPlay_Action_Deactivate:
	calr AccPlayMode_StartAccPlayFull

AccAutoPlay_Action_Apply:
	.byte	0xf1, 0xb5, 0x33, 0xcb, 0x6e, 0x00
AccAutoPlay_Action_Finalize:
	.byte	0xc1, 0xb6, 0x33, 0x3c, 0x1f	; anddi8 (0x346e), 31 (v7 patched)



AccAutoPlay_Action_Return:
	ret

AccAutoPlay_Action_Padding:
	nop
	nop

AccAutoPlay_DeferredAction:
	bit	7, (ACC_SYNCHRO_STATE:16)
	jr z, AccAutoPlay_Deferred_Return
	bit	0, (ACC_SYNCHRO_STATE:16)
	jr z, .Lc_f5a9a9
	and	(ACC_SYNCHRO_STATE:16), 0xee
	or	(ACC_SYNCHRO_STATE:16), 0x08
	ei 0x06
	calr AccPlayMode_StartAccPlayFull
	ei 0x00
	calr AccReplay_FullRestart
	jr t, AccAutoPlay_Deferred_Return
AccAutoPlay_Deferred_Process:
.Lc_f5a9a9:
	bit	1, (ACC_SYNCHRO_STATE:16)
	jr z, AccAutoPlay_Deferred_Return
	and	(ACC_SYNCHRO_STATE:16), 0xed
	or	(ACC_SYNCHRO_STATE:16), 0x08
	ei 0x06
	calr AccPlayMode_StartPlay
	ei 0x00
	calr AccReplay_FullRestart
AccAutoPlay_Deferred_Return:
	ret

AccAutoPlay_Deferred_Padding:
	nop
	nop

AccPlayMode_Dispatch:
	xor xhl, xhl
	ei 6
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr z, AccPlayMode_Dispatch_Check
	or l, 0x4

AccPlayMode_Dispatch_Check:
	bit 2, (SEQ_TRANSPORT_STATE:16)
	jr z, AccPlayMode_Dispatch_Select
	or l, 0x8

AccPlayMode_Dispatch_Select:
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr z, AccPlayMode_Dispatch_Execute
	or l, 0x10

AccPlayMode_Dispatch_Execute:
	ld xwa, AccPlayMode_Dispatch_Execute_Data
	add xhl, xwa
	ld xwa, (xhl)
	call (xwa)
	ei 0
	ret

AccPlayMode_Dispatch_Table:
	.byte	0x00, 0x00
AccPlayMode_Dispatch_Execute_Data:
	.long	AccPlayMode_OnMask0_Nop
	.long	AccPlayMode_StopAcc
	.long	AccPlayMode_StopExprD
	.long	AccPlayMode_OnMask3
	.long	AccPlayMode_OnMask4
	.long	AccPlayMode_StopPlayAndAcc
	.long	AccPlayMode_StopExprC
	.long	AccPlayMode_StopExprFull
AccPlayMode_OnMask0_Nop:
	ret
	nop
	nop
AccPlayMode_TransitionRouter:
	cpw	(SEQ_REC_TRACKS:16), 0
	jr z, AccPlayMode_Router_Process
	cpw (SEQ_TRACK_MASK:16), 0
	jr z, AccPlayMode_Router_Check
	calr AccPlayMode_Router_Alt
	jr AccPlayMode_Router_Return

AccPlayMode_Router_Check:
	calr AccPlayMode_StartRecording
	jr AccPlayMode_Router_Return

AccPlayMode_Router_Process:
	cpw (SEQ_TRACK_MASK:16), 0
	jr z, AccPlayMode_Router_Apply
	calr AccPlayMode_StartAcc
	jr AccPlayMode_Router_Return

AccPlayMode_Router_Apply:
	calr AccPlayMode_StopToSync

AccPlayMode_Router_Return:
	ret

AccPlayMode_Router_Padding:
	nop
	nop

AccPlayMode_Router_Alt:
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_Router_AltPadding
	calr AccPlayMode_StartPlay
	jr AccPlayMode_Router_AltPadding

AccPlayMode_Router_AltPadding:
	ret

AccPlayMode_StartRecording_Padding:
	nop
	nop

AccPlayMode_StartRecording:
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StartRec_Apply
	bit	1, (SEQ_RTMCFG:16)
	jr z, AccPlayMode_StartRec_Process
	ei 6
	calr AccPlayMode_StopExprB
	ei 0
	jr AccPlayMode_StartRec_Return

AccPlayMode_StartRec_Process:
	calr AccPlayMode_Dispatch
	jr AccPlayMode_StartRec_Return

AccPlayMode_StartRec_Apply:
	calr AccPlayMode_StopExprA

AccPlayMode_StartRec_Return:
	ret

AccPlayMode_StartRec_Padding:
	nop
	nop

AccPlayMode_StartAcc:
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StartAcc_Apply
	bit	1, (SEQ_RTMCFG:16)
	jr z, AccPlayMode_StartAcc_Process
	ei 6
	calr AccPlayMode_StopExprB
	ei 0
	jr AccPlayMode_StartAcc_Return

AccPlayMode_StartAcc_Process:
	ei 6
	calr AccPlayMode_StartPlayFull
	ei 0
	jr AccPlayMode_StartAcc_Return

AccPlayMode_StartAcc_Apply:
	calr AccPlayMode_Dispatch

AccPlayMode_StartAcc_Return:
	ret

AccPlayMode_StartAcc_Padding:
	nop
	nop

AccPlayMode_StopToSync:
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StopToSync_Process
	ei 6
	calr AccPlayMode_StartAccPlayFull
	ei 0
	jr AccPlayMode_StopToSync_Return

AccPlayMode_StopToSync_Process:
	ei 6
	calr AccPlayMode_StopPlayAndAcc
	ei 0

AccPlayMode_StopToSync_Return:
	ret

AccPlayMode_StopToSync_Padding:
	nop
	nop

AccPlayMode_StartPlay:
	bit	2, (SEQ_RTMCFG:16)
	jr nz, AccPlayMode_StartPlay_Return
	bit	1, (SEQ_RTMCFG:16)
	jr nz, AccPlayMode_StartPlay_Process
	ei 6
	calr AccPlayMode_StartPlayFull
	ei 0
	jr AccPlayMode_StartPlay_Return

AccPlayMode_StartPlay_Process:
	ei 6
	calr AccPlayMode_StopExprB
	ei 0

AccPlayMode_StartPlay_Return:
	ret

AccPlayMode_StartPlay_Padding:
	nop
	nop

AccPlayMode_StopExprA:
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StopExprA_Process
	ei 6
	calr AccPlayMode_StartAccPlay
	ei 0
	jr AccPlayMode_StopExprA_Return

AccPlayMode_StopExprA_Process:
	ei 6
	calr AccPlayMode_StopAcc
	ei 0

AccPlayMode_StopExprA_Return:
	ret

AccPlayMode_StopExprA_Padding:
	nop
	nop

AccPlayMode_StopExprB:
	bit 0, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StopExprB_Return
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StopExprB_Return
	bit	2, (0x2896:16)
	jr nz, AccPlayMode_StopExprB_Process
	bit	1, (0x2896:16)
	jr z, AccPlayMode_StopExprB_Process
	call SeqPlay_SetBarAndResetScroll
	ld (ACC_TRANSPORT_STATE:16), 128
	or	(0x2896:16), 4
	jr AccPlayMode_StartAccPlay_Return

AccPlayMode_StopExprB_Process:
	ld (PLAY_TRANSPORT_STATE:16), 1
	calr AccTempo_ClearCounters
	calr AccSync_MidiClock

AccPlayMode_StopExprB_Return:
	ld (SEQ_TRANSPORT_STATE:16), 1
	calr AccTempo_ClearSubPos

AccPlayMode_StartAccPlay:
	ld (ACC_TRANSPORT_STATE:16), 1

	; ordi8 0x3474, 1 (v7 patched)
	or	(0x33bc:16), 1
	; calr AccTempo_ClearPositions (v7 displacement)
	calr	AccTempo_ClearPositions
	ld a, 0x85:opc

	; calr AccTempo_WriteStartMarker (v7 displacement)
	calr	AccTempo_WriteStartMarker
AccPlayMode_StartAccPlay_Return:
	ret

AccPlayMode_StartAccPlay_Padding:
	nop
	nop

AccPlayMode_StopPlayAndAcc:
	bit 3, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StopAcc
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr z, AccPlayMode_StopAcc
	ld (PLAY_TRANSPORT_STATE:16), 12

AccPlayMode_StopAcc:
	ld	(ACC_TRANSPORT_STATE:16), 12
	ld	(ACC_SECTION_BUTTONS_HELD:16), 0
	ld	a, 134:opc
	calr	AccTempo_WriteStartMarker
	ret
AccPlayMode_StopAcc_Padding:
	nop
	nop

AccPlayMode_StartPlayFull:
	bit	2, (0x2896:16)
	jr nz, AccPlayMode_StartPlayFull_Process
	bit	1, (0x2896:16)
	jr z, AccPlayMode_StartPlayFull_Process
	call SeqPlay_SetBarAndResetScroll
	ld (ACC_TRANSPORT_STATE:16), 128
	or	(0x2896:16), 4
	jr AccPlayMode_StartPlayFull_Return

AccPlayMode_StartPlayFull_Process:
	ld (SEQ_TRANSPORT_STATE:16), 1
	calr AccTempo_ClearSubPos
	bit 0, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StartPlayFull_Return
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StartPlayFull_Return
	ld (PLAY_TRANSPORT_STATE:16), 1
	calr AccTempo_ClearCounters
	calr AccSync_MidiClock

AccPlayMode_StartPlayFull_Return:
	ret

AccPlayMode_StartPlayFull_Padding:
	nop
	nop

AccPlayMode_StopExprFull:
	ld (ACC_TRANSPORT_STATE:16), 0x0c
	bit	0, (0x2896:16)
	jr nz, AccPlayMode_StopExprFull_Process
	or	(0x33c2:16), 0x04
AccPlayMode_StopExprFull_Process:
	ld a, 0x86:opc
	calr AccTempo_WriteStartMarker

AccPlayMode_StopExprC:
	ld (SEQ_TRANSPORT_STATE:16), 12
AccPlayMode_OnMask4:
	bit 3, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StopExprC_Process
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr z, AccPlayMode_StopExprC_Process
	ld (PLAY_TRANSPORT_STATE:16), 12

AccPlayMode_StopExprC_Process:
	ld	(ACC_SECTION_BUTTONS_HELD:16), 0
	ret
AccPlayMode_StopExprC_Return:
	nop
	nop

AccPlayMode_StopExprD:
	ld (SEQ_TRANSPORT_STATE:16), 12
	ret

AccPlayMode_StopExprD_Return:
	nop
	nop

AccPlayMode_StartAccPlayFull:
	ld (ACC_TRANSPORT_STATE:16), 0x01
	or	(0x33bc:16), 0x01
	calr AccTempo_ClearPositions
	ld A, 0x85:opc
	calr AccTempo_WriteStartMarker
	bit 0, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StartAccPlayFull_Return
	bit 2, (PLAY_TRANSPORT_STATE:16)
	jr nz, AccPlayMode_StartAccPlayFull_Return
	ld (PLAY_TRANSPORT_STATE:16), 0x01
	calr AccTempo_ClearCounters
	calr AccSync_MidiClock
AccPlayMode_StartAccPlayFull_Return:
	ret

AccPlayMode_StartAccPlayFull_Padding:
	nop
	nop
AccPlayMode_OnMask3:
	ld	(SEQ_TRANSPORT_STATE:16), 12
	ld	(ACC_TRANSPORT_STATE:16), 12
	and	(ACC_SECTION_BUTTONS_HELD:16), 15
	ld	a, 134:opc
	calr	AccTempo_WriteStartMarker
	ret
	nop
	nop
AccTempo_ClearCounters:
	xor wa, wa
	ei 6
	ld (PLAY_CLOCK:16), a
	ld (PLAY_BEAT_COUNT:16), wa
	ei 0
	ret

AccTempo_ClearPositions:
	xor wa, wa
	ei 6
	bit	0, (0x288a:16)
	jr nz, AccTempo_ClearPositions_Loop
	ld (ACC_CLOCK:16), a
	ld (ACC_BEAT:16), a

AccTempo_ClearPositions_Loop:
	ld (ACC_BAR_COUNT:16), a
	ld (ACC_SECTION_BAR:16), a
	ei 0
	and	(0x288a:16), 254
	ret

AccTempo_ClearSubPos:
	xor wa, wa
	ei 6
	bit	3, (SEQ_RTMCFG:16)
	jr nz, AccTempo_ClearSubPos_Loop
	ld (SEQ_BEAT_COUNT:16), wa
	ld (SEQ_BEAT_TICK:16), a

AccTempo_ClearSubPos_Loop:
	ei 0
	ret

AccSync_MidiClock:
	bit 2, (PANEL_MIDI+2:16)
	jr z, AccSync_MidiClock_Return
	ei 6
	bit	3, (SEQ_RTMCFG:16)
	jr z, AccSync_MidiClock_Update
	or (1065:16), 4
	jr AccSync_MidiClock_Apply

AccSync_MidiClock_Update:
	or (1065:16), 2

AccSync_MidiClock_Apply:
call	MIDI_SC0_TX_DISPATCH
	ei	0
AccSync_MidiClock_Return:
	ret

AccSync_MidiClock_Padding:
	nop
	nop

AccTempo_WriteStartMarker:
	cpw	(SEQ_RECORDING_TRACKS:16), 0
	jr z, AccTempo_WriteMarker_Return

AccTempo_WriteStopMarker:
	ei 6
	pushw wa
	call TempoRingBuf_WriteByte_Ext
	inc 2, xsp
	ld a, (SEQ_BEAT_TICK:16)
	pushw wa
	call TempoRingBuf_WriteByte_Ext
	inc 2, xsp
	ei 0

AccTempo_WriteMarker_Return:
	ret

AccTempo_WriteMarker_Padding:
	nop
	nop
AccTempo_WriteMarker_Padding_Return:
	ret

AccReplay_FullRestart:
	ld	(0x33bc:16), 0x00
	or	(0x33d9:16), 0x01
	calr AccPlayMode_WaitIdle

	xor bc, bc



AccReplay_Restart_WaitIdle:
	pushw bc
	call SeqTiming_Snapshot
	popw bc
	xor wa, wa
	pushw bc
	call RhythmBuf_CheckEmpty
	popw bc
	cp wa, 0:i3
	jr nz, AccReplay_Restart_Snapshot
	inc 1, bc
	cp bc, 0x200
	jr c, AccReplay_Restart_WaitIdle
	jr AccReplay_Restart_ReInit

AccReplay_Restart_Snapshot:
	call RhythmBuf_DispatchWrap
	xor wa, wa
	call RhythmBuf_CheckEmpty
	cp wa, 0:i3
	jr z, AccReplay_Restart_ReInit
	call RhythmBuf_DispatchWrap
	calr AccTiming_AlignTo8Tick
	calr AccTempo_CheckSource
	call SeqTiming_Snapshot

AccReplay_Restart_Drain:
	xor wa, wa
	call RhythmBuf_CheckEmpty
	cp wa, 0:i3
	jr z, AccReplay_Restart_ReInit
	call RhythmBuf_DispatchWrap
	jr AccReplay_Restart_Drain

AccReplay_Restart_ReInit:
	; anddi8 (0x3491), 254 (v7 patched)
	and	(0x33d9:16), 254
	ret



AccReplay_Restart_Return:
	nop
	nop

AccTiming_AlignTo8Tick:
	pushw hl
	ldw bc, 0x8
	ld wa, (SYSTEM_TIMESTAMP:16)
	add wa, bc

AccTiming_Align_Compute:
	ld hl, wa
	sub hl, (SYSTEM_TIMESTAMP:16)
	cp hl, 0:i3
	jr le, AccTiming_Align_Return
	jr AccTiming_Align_Compute

AccTiming_Align_Return:
	popw hl
	ret

AccPlayMode_WaitIdle:
	xor bc, bc

AccPlayMode_WaitIdle_Check:
	bit 0, (ACC_TRANSPORT_STATE:16)
	jr z, AccPlayMode_WaitIdle_Loop
	inc 1, bc
	cp bc, 0x500
	jr nz, AccPlayMode_WaitIdle_Check

AccPlayMode_WaitIdle_Loop:
	ret

AccPlayMode_WaitIdle_Return:
	nop
	nop

AccTempo_CheckSource:
	cp (0x045b:16), 0x01
	jr nz, AccTempo_CheckSource_Process
	cp	(CHORD_TYPE:16), 0x00
	jr z, AccTempo_CheckSource_Process
	ld (0x045b:16), 0x00
AccTempo_CheckSource_Process:
	bit 0, (1115:16)
	jr z, AccTempo_CheckSource_Clear
	bit 2, (ACC_TRANSPORT_STATE:16)
	jr nz, AccTempo_CheckSource_Return

AccTempo_CheckSource_Clear:
	call Seq_DispatcherEntry
	ld (1124:16), 0

AccTempo_CheckSource_Return:
	ret

AccTempo_CheckSource_Padding:
	nop
	nop

AccReplay_SavedPedal:
	ld	a, (SWBTWR_PAYLOAD_1:16)
	pushw	wa
	ld	w, (SWBTWR_PAYLOAD_2:16)
	ld	a, (SWBTWR_PAYLOAD_3:16)
	pushw	wa
	ld	a, (13264:16)
	ld	(SWBTWR_PAYLOAD_1:16), a
	ld	a, (13245:16)
	ld	(SWBTWR_PAYLOAD_2:16), a
	ld	a, (RHYTHM_VARIATION_INDEX:16)
	ld	(SWBTWR_PAYLOAD_3:16), a
	ld	a, (PANEL_EVENT_SOURCE:16)
	pushw	wa
	ld	(PANEL_EVENT_SOURCE:16), 0
	calr	AccStyleCtl_OnSwitchEvent
	popw	wa
	ld	(PANEL_EVENT_SOURCE:16), a
	popw	wa
	ld	(SWBTWR_PAYLOAD_2:16), w
	ld	(SWBTWR_PAYLOAD_3:16), a
	popw	wa
	ld	(SWBTWR_PAYLOAD_1:16), a
	xor	a, a
	ld	(13245:16), a
	ld	(RHYTHM_VARIATION_INDEX:16), a
	ld	(13264:16), a
	ld	wa, 0:i3
	ld	d, 5:opc
	ld	e, 72:opc
call	SwbtWr_QueuePostEvent
	ld	wa, 0:i3
	ld	d, 6:opc
	ld	e, 72:opc
call	SwbtWr_QueuePostEvent
call	AudioMode_SetStereoFlags
	ret
AccReplay_SavedPedal_Return:
	nop
	nop

AccReplay_SendPedalType5:
	push xiz
	calr AccReplay_SendPedalType6
	pop xiz
	ret

AccReplay_SendPedalType6:
	ld	hl, wa
	ld	a, (SWBTWR_PAYLOAD_1:16)
	pushw	wa
	ld	w, (SWBTWR_PAYLOAD_2:16)
	ld	a, (SWBTWR_PAYLOAD_3:16)
	pushw	wa
	cp	l, 0:i3
	jr	nz, AccReplay_SendPedal_Process
	ld	(SWBTWR_PAYLOAD_1:16), 5
	ld	(SWBTWR_PAYLOAD_2:16), 4
	ld	(SWBTWR_PAYLOAD_3:16), 4
	jr	AccReplay_SendPedal_Dispatch
AccReplay_SendPedal_Process:
	ld	(SWBTWR_PAYLOAD_1:16), 6
	ld	(SWBTWR_PAYLOAD_2:16), 4
	ld	(SWBTWR_PAYLOAD_3:16), 4
AccReplay_SendPedal_Dispatch:
	ld	a, (PANEL_EVENT_SOURCE:16)
	pushw	wa
	ld	(PANEL_EVENT_SOURCE:16), 0
	calr	AccStyleCtl_OnSwitchEvent
	popw	wa
	ld	(PANEL_EVENT_SOURCE:16), a
	popw	wa
	ld	(SWBTWR_PAYLOAD_2:16), w
	ld	(SWBTWR_PAYLOAD_3:16), a
	popw	wa
	ld	(SWBTWR_PAYLOAD_1:16), a
	ld	wa, 0:i3
	ld	d, 5:opc
	ld	e, 72:opc
call	SwbtWr_QueuePostEvent
	ld	wa, 0:i3
	ld	d, 6:opc
	ld	e, 72:opc
call	SwbtWr_QueuePostEvent
call	AudioMode_SetStereoFlags
	ret
AccReplay_SendPedal_Return:
	nop
	nop

AccReplay_SavedExpression:
	ld	a, (SWBTWR_PAYLOAD_1:16)
	pushw	wa
	ld	w, (SWBTWR_PAYLOAD_2:16)
	ld	a, (SWBTWR_PAYLOAD_3:16)
	pushw	wa
	ld	a, (13265:16)
	ld	(SWBTWR_PAYLOAD_1:16), a
	ld	a, (13252:16)
	ld	(SWBTWR_PAYLOAD_2:16), a
	ld	a, (13253:16)
	ld	(SWBTWR_PAYLOAD_3:16), a
	ld	a, (PANEL_EVENT_SOURCE:16)
	pushw	wa
	ld	(PANEL_EVENT_SOURCE:16), 255
	calr	AccStyleCtl_OnSwitchEvent
	popw	wa
	ld	(PANEL_EVENT_SOURCE:16), a
	popw	wa
	ld	(SWBTWR_PAYLOAD_2:16), w
	ld	(SWBTWR_PAYLOAD_3:16), a
	popw	wa
	ld	(SWBTWR_PAYLOAD_1:16), a
	xor	a, a
	ld	(13252:16), a
	ld	(13253:16), a
	ld	(13265:16), a
	ld	wa, 0:i3
	ld	d, 5:opc
	ld	e, 72:opc
call	SwbtWr_QueuePostEvent
	ld	wa, 0:i3
	ld	d, 6:opc
	ld	e, 72:opc
call	SwbtWr_QueuePostEvent
call	AudioMode_SetStereoFlags
	ret
AccReplay_SavedExpr_Return:
	nop
	nop
	ld	xwa, RHYTHM_PATTERN_BUF_A
	add	xwa, 14
	ld	wa, (xwa)
	cp	wa, 0:i3
	jr	z, AccReplay_SavedExpression_Return
	call	Composer_ResetStyleImage
AccReplay_SavedExpression_Return:
	ret
	nop
	nop

AccReplay_FullStop:
	ld a, (PANEL_STYLE+5:16)
	and A,0x0c
	ld c, (PANEL_STYLE+6:16)
	and C,0x04
	or A,C
	cp a, 0:i3
	jr z, .Lc_f5aef4
	and (PANEL_STYLE+5:16), 0xf3
	ld wa, 0:i3
	ld D, 0x05:opc
	ld E, 0x48:opc
	call SwbtWr_QueuePostEvent
	and (PANEL_STYLE+6:16), 0xfb
	ld wa, 0:i3
	ld D, 0x06:opc
	ld E, 0x48:opc
	call SwbtWr_QueuePostEvent
AccReplay_Stop_ClearPedals:
.Lc_f5aef4:
	call Seq_DispatcherEntry
	cp	(0x33c1:16), 0x00
	jr z, .Lc_f5af0c
	ld	a, (0x33c1:16)
	add (0x0437:16), a
	ld	(0x33c1:16), 0x00
AccReplay_Stop_ResetPosition:
.Lc_f5af0c:
	and (0x0437:16), 0x07
	ld a, (0x0437:16)
	cp a, (ACC_BEATS_PER_BAR:16)
	jr c, .Lc_f5af2b
	sub a, (ACC_BEATS_PER_BAR:16)
	ld (0x0437:16), a
	ld a, (ACC_BEATS_PER_BAR:16)
	ld	(0x33c1:16), a
AccReplay_Stop_Rebuild:
.Lc_f5af2b:
	xor WA,WA
	ld (ACC_CLOCK:16), a
	ld (ACC_BEAT:16), a
	or	(0x3415:16), 0x80
	or	(0x33c2:16), 0x01
	ld e, (0x0436:16)
	ld d, (0x0437:16)
	cp de, 0:i3
	jr z, AccReplay_Stop_Finalize
	sub E,0x18
	jr nc, AccReplay_Stop_CheckMode
	add E,0x60
	dec 1,D
	cp D,0xff
	jr nz, AccReplay_Stop_CheckMode
	ld de, 0:i3
AccReplay_Stop_CheckMode:
	xor bc, bc

	; anddi8 (0x347a), 127 (v7 patched)
	and	(0x33c2:16), 127
AccReplay_Stop_Process:
	ld (ACC_CLOCK:16), c
	ld (ACC_BEAT:16), b
	pushw bc
	pushw de
	call Seq_DispatcherEntry
	popw de
	popw bc
	add c, 0x18
	cp c, 0x60
	jr nz, AccReplay_Stop_UpdateFlags
	inc 1, b
	xor c, c

AccReplay_Stop_UpdateFlags:
	bit	7, (0x33c2:16)
	jr	nz, AccReplay_Stop_Finalize
	cp	bc, de
	jr	c, AccReplay_Stop_Process
	or	(0x33c2:16), 128
	cp	bc, de
	jr	z, AccReplay_Stop_Process
	ld	bc, de
	jr	AccReplay_Stop_Process
AccReplay_Stop_Finalize:
	ld a, (1078:16)

	ld (ACC_CLOCK:16), a

	ld a, (1079:16)

	ld (ACC_BEAT:16), a

	; anddi8 (0x347a), 254 (v7 patched)
	and	(0x33c2:16), 254
	; call Seq_DispatcherEntry (v7 addr)
call	Seq_DispatcherEntry
	ret



AccReplay_Stop_Return:
	nop
	nop

AccPos_SaveOnStop:
	ld a, (SWBTWR_PAYLOAD_3:16)
	cp a, 0:i3
	jr z, AccPos_SaveOnStop_Return
	bit	0, (0x288a:16)
	jr z, AccPos_SaveOnStop_Return
	ei 0x06
	ld a, (ACC_CLOCK:16)
	ld (0x0436:16), a
	ld a, (ACC_BEAT:16)
	ld (0x0437:16), a
	xor WA,WA
	ld (ACC_CLOCK:16), a
	ld (ACC_BEAT:16), a
	ei 0x00
	calr AccReplay_FullStop
AccPos_SaveOnStop_Return:
	ret

AccPos_SaveOnStop_Padding:
	nop
	nop

AccPos_ClearOnStart:
	bit	0, (ACC_RUN_FLAGS:16)
	jr nz, AccPos_ClearOnStart_Return
	xor WA,WA
	ei 0x06
	ld (ACC_CLOCK:16), a
	ld (ACC_BEAT:16), a
	ei 0x00
	ld (0x0436:16), a
	ld (0x0437:16), a
	ld	(0x33c1:16), a
	or	(0x3415:16), 0x80
	call Seq_DispatcherEntry
AccPos_ClearOnStart_Return:
	ret

AccPos_ClearOnStart_Padding:
	nop
	nop
AccReplay_HandlePendingStop:
	cp (CURRENT_MODE:16), 0x13
	jr nz, .Lc_f5b023
	and	(0x33c2:16), 0xfd
	and	(0x288a:16), 0xfe
	jr t, .Lc_f5b041
.Lc_f5b023:
	bit	1, (0x33c2:16)
	jr z, .Lc_f5b041
	ld	a, (ACC_RUN_FLAGS:16)
	and A,0x03
	cp a, 0:i3
	jr nz, .Lc_f5b041
	ld	(0x33c1:16), 0x00
	calr AccReplay_FullStop
	and	(0x33c2:16), 0xfd
.Lc_f5b041:
AccReplay_HandlePendingStop_Return:
	ret
	.byte 0x00, 0x00
AccFlags_SyncTo64607:
	ld e, (PLAY_TRANSPORT_STATE:16)
	and (PANEL_STYLE+5:16), 254
	bit 2, e
	jr z, AccFlags_Sync_Process
	or (PANEL_STYLE+5:16), 1

AccFlags_Sync_Process:
	ld	a, e
	xor	a, (13251:16)
	bit	2, a
	jr	z, AccFlags_Sync_UpdateLED
	ld	a, 34:opc
call	CtrlPanel_SetIndicatorBit
AccFlags_Sync_UpdateLED:
	ld	(0x33c3:16), e
	bit	0, (0x33e6:16)
	jr	z, AccFlags_Sync_Return
	and	(0x33e6:16), 254
AccFlags_Sync_Return:
	ret

AccFlags_Sync_Padding:
	nop
	nop

AccTiming_InitAllParts:
	ldw	(ACC_NOTES_MIN_SCAN:16), 65375
	ldw	(ACC_SLOT_STRIDE:16), 6
	ldw	(ACC_SLOT_TABLE_SIZE:16), 48
	ld	xbc, 12252
	calr	AccKbdTiming_TableScan
	ld	xbc, 12300
	calr	AccKbdTiming_TableScan
	ldw	(ACC_SLOT_STRIDE:16), 9
	ldw	(ACC_SLOT_TABLE_SIZE:16), 72
	ld	(ACC_SLOT_CHANNEL:16), 7
	ld	xbc, 12348
	calr	AccAccTiming_TableScan
	ld	(ACC_SLOT_CHANNEL:16), 4
	ld	xbc, 12420
	calr	AccAccTiming_TableScan
	ld	(ACC_SLOT_CHANNEL:16), 5
	ld	xbc, 12492
	calr	AccAccTiming_TableScan
	ld	(ACC_SLOT_CHANNEL:16), 6
	ld	xbc, 12564
	calr	AccAccTiming_TableScan
	ld	wa, (ACC_NOTES_MIN_SCAN:16)
	ld	(ACC_NEXT_NOTE_OFF:16), wa
	jr	AccTiming_InitAllParts_Return
AccTiming_InitAllParts_Return:
	ret

AccTiming_MasterTick:
	ld	(0x32bf:16), 95
	ldw	(ACC_SLOT_STRIDE:16), 6
	ldw	(ACC_SLOT_TABLE_SIZE:16), 48
	ld	a, (0x32cd:16)
	ld	(ACC_SLOT_STEAL_INDEX:16), a
	ld	xhl, 10716
	ld	xbc, 12252
	calr	AccKbdTiming_ScanRingBuf
	ld	a, (ACC_SLOT_STEAL_INDEX:16)
	ld	(0x32cd:16), a
	ld	a, (0x32ce:16)
	ld	(ACC_SLOT_STEAL_INDEX:16), a
	ld	xhl, 10972
	ld	xbc, 12300
	calr	AccKbdTiming_ScanRingBuf
	ld	a, (ACC_SLOT_STEAL_INDEX:16)
	ld	(0x32ce:16), a
	ldw	(ACC_SLOT_STRIDE:16), 9
	and	(0x32d5:16), 254
	ldw	(ACC_SLOT_TABLE_SIZE:16), 72
	ld	(ACC_SLOT_CHANNEL:16), 7
	ld	a, (0x32cf:16)
	ld	(ACC_SLOT_STEAL_INDEX:16), a
	ld	a, (ACC_CH_CC3:16)
	ld	(ACC_CUR_CC3:16), a
	ld	xhl, 11228
	ld	xbc, 12348
	calr	AccAccTiming_ScanRingBuf
	ld	a, (ACC_SLOT_STEAL_INDEX:16)
	ld	(0x32cf:16), a
	ld	a, (ACC_CUR_CC3:16)
	ld	(ACC_CH_CC3:16), a
	ld	(ACC_SLOT_CHANNEL:16), 4
	ld	a, (0x32d0:16)
	ld	(ACC_SLOT_STEAL_INDEX:16), a
	ld	a, (0x3278:16)
	ld	(ACC_CUR_CC3:16), a
	ld	xhl, 11484
	ld	xbc, 12420
	calr	AccAccTiming_ScanRingBuf
	ld	a, (ACC_SLOT_STEAL_INDEX:16)
	ld	(0x32d0:16), a
	ld	a, (ACC_CUR_CC3:16)
	ld	(0x3278:16), a
	ld	(ACC_SLOT_CHANNEL:16), 5
	ld	a, (0x32d1:16)
	ld	(ACC_SLOT_STEAL_INDEX:16), a
	ld	a, (0x3279:16)
	ld	(ACC_CUR_CC3:16), a
	ld	xhl, 11740
	ld	xbc, 12492
	calr	AccAccTiming_ScanRingBuf
	ld	a, (ACC_SLOT_STEAL_INDEX:16)
	ld	(0x32d1:16), a
	ld	a, (ACC_CUR_CC3:16)
	ld	(0x3279:16), a
	ld	(ACC_SLOT_CHANNEL:16), 6
	ld	a, (0x32d2:16)
	ld	(ACC_SLOT_STEAL_INDEX:16), a
	ld	a, (0x327a:16)
	ld	(ACC_CUR_CC3:16), a
	ld	xhl, 11996
	ld	xbc, 12564
	calr	AccAccTiming_ScanRingBuf
	ld	a, (ACC_SLOT_STEAL_INDEX:16)
	ld	(0x32d2:16), a
	ld	a, (ACC_CUR_CC3:16)
	ld	(0x327a:16), a
	ld	a, (0x32bf:16)
	ld	(0x32be:16), a
	jr	AccKbdTiming_Ret
AccKbdTiming_Ret:
	ret

AccKbdTiming_ScanRingBuf:
	ld	(14784:16), 255
	ld	ix, (xhl+6)
AccKbdTiming_EventLoop:
	cp (xhl + 4), ix
	jrl z, AccKbdTiming_ScanDone
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_ClassifyEvent
	ld ix, (xhl + 0:8)

AccKbdTiming_ClassifyEvent:
	ld w, a
	cp a, 0xdf
	jr z, AccKbdTiming_SpecialEvent
	cp a, 0x9f
	jr nz, AccKbdTiming_CheckNoteOn

AccKbdTiming_SpecialEvent:
	ld	(13000:16), 2
	jr	AccKbdTiming_StoreEventData
AccKbdTiming_CheckNoteOn:
	cp	a, 144
	jr	nz, AccKbdTiming_CheckProgramChg
	ld	(13000:16), 4
	jr	AccKbdTiming_StoreEventData
AccKbdTiming_CheckProgramChg:
	and	a, 240
	cp	a, 192
	jr	nz, AccKbdTiming_CheckControl
	ld	(13000:16), 5
	jr	AccKbdTiming_StoreEventData
AccKbdTiming_CheckControl:
	cp	a, 208
	jrl	nz, AccKbdTiming_SkipEvent
	ld	(13000:16), 2
AccKbdTiming_StoreEventData:
	ld	(0x39c1:16), a
	ld	a, (xhl+ix)
	ld	(0x32c0:16), ix
	inc	1, ix
	cp	ix, (xhl+2)
	jr	ule, AccKbdTiming_CheckTimestamp
	ld	ix, (xhl+0:8)
AccKbdTiming_CheckTimestamp:
	cp	a, (0x45d:16)
	jrl	ugt, AccKbdTiming_TimestampOverflow
	ld	a, w
	and	a, 240
	cp	w, 159
	jrl	z, AccKbdTiming_WriteNonNote
	cp	w, 223
	jrl	z, AccKbdTiming_WriteNonNote
	cp	a, 144
	jrl	nz, AccKbdTiming_WriteNonNote_Prep
	cp	(0x39c0:16), 0
	jr	nz, AccKbdTiming_NoteSlotScan
	pushw	wa
	ld	a, 8:opc
	ld	(0x39c4:16), a
	popw	wa
	calr	AccKbdTiming_CatchupReplay
	ld	(0x39c0:16), 255
AccKbdTiming_NoteSlotScan:
	xor iz, iz

AccKbdTiming_SlotLoop:
	cp	iz, (ACC_SLOT_TABLE_SIZE:16)
	jr	nc, AccKbdTiming_SlotOverflow
	bit	7, (xbc+iz)
	jr	z, AccKbdTiming_WriteNoteEvent
	add	iz, (ACC_SLOT_STRIDE:16)
	jr	AccKbdTiming_SlotLoop
AccKbdTiming_SlotOverflow:
	pushw	wa
	xor	xwa, xwa
	ld	a, (ACC_SLOT_STEAL_INDEX:16)
	sla	xwa, 2
	add	xwa, AccTiming_SlotOffsetTables
	ld	iz, (xwa)
	ld	a, (xbc+iz)
	and	(xbc+iz), 0x7f
	pushw	iz
	inc	2, iz
	ld	w, (xbc+iz)
	and	a, 240
	or	a, 8
	calr	AccSeq_WriteByte
	ld	a, w
	calr	AccSeq_WriteByte
	ld	a, 0:opc
	calr	AccSeq_WriteByte
	popw	iz
	popw	wa
	inc	1, (ACC_SLOT_STEAL_INDEX:16)
	cp	(ACC_SLOT_STEAL_INDEX:16), 8
	jr	c, AccKbdTiming_SlotOverflow_Done
	ld	(ACC_SLOT_STEAL_INDEX:16), 0
AccKbdTiming_SlotOverflow_Done:
	jr AccKbdTiming_WriteNoteEvent

AccKbdTiming_SkipEvent:
	ld ix, (xhl + 4)
	ld (xhl + 6), ix
	jrl AccKbdTiming_EventLoop

AccKbdTiming_WriteNoteEvent:
	or a, 0x8
	calr AccSeq_WriteByte
	ld a, w
	ld	(xbc+iz), a
	inc 1, iz
	ld a, 0x0:opc
	ld	(xbc+iz), a
	inc 1, iz
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_WriteNote_Byte2
	ld ix, (xhl + 0:8)

AccKbdTiming_WriteNote_Byte2:
	calr AccSeq_WriteByte
	ld	(xbc+iz), a
	inc 1, iz
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_WriteNote_Byte3
	ld ix, (xhl + 0:8)

AccKbdTiming_WriteNote_Byte3:
	calr AccSeq_WriteByte
	ld	(xbc+iz), a
	inc 1, iz
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_WriteNote_ReadTiming
	ld ix, (xhl + 0:8)

AccKbdTiming_WriteNote_ReadTiming:
	ld	w, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_WriteNote_ClampTiming
	ld ix, (xhl + 0:8)

AccKbdTiming_WriteNote_ClampTiming:
	cp wa, 0xa
	jr ugt, AccKbdTiming_WriteNote_AddBase
	ldw wa, 0xa

AccKbdTiming_WriteNote_AddBase:
	add wa, (1118:16)
	cp a, 0x60
	jr c, AccKbdTiming_WriteNote_StoreTiming
	inc 1, w
	sub a, 0x60

AccKbdTiming_WriteNote_StoreTiming:
	ld	(xbc+iz), wa
	cp	wa, (ACC_NEXT_NOTE_OFF:16)
	jr	nc, AccKbdTiming_WriteNote_UpdateReadPos
	ld	(ACC_NEXT_NOTE_OFF:16), wa
AccKbdTiming_WriteNote_UpdateReadPos:
	ld (xhl + 6), ix
	jrl AccKbdTiming_EventLoop

AccKbdTiming_WriteNonNote_Prep:
	ld w, a
	or a, 0x8

AccKbdTiming_WriteNonNote:
	calr AccSeq_WriteByte
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_WriteNonNote_Byte2
	ld ix, (xhl + 0:8)

AccKbdTiming_WriteNonNote_Byte2:
	calr AccSeq_WriteByte
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_WriteNonNote_Byte3
	ld ix, (xhl + 0:8)

AccKbdTiming_WriteNonNote_Byte3:
	calr	AccSeq_WriteByte
	cp	w, 223
	jr	nz, AccKbdTiming_WriteNonNote_CheckType
	ld	a, 0:opc
	ld	(ACC_CH_CC3:16), a
	ld	(12920:16), a
	ld	(12921:16), a
	ld	(12922:16), a
	jr	AccKbdTiming_WriteNonNote_Done
AccKbdTiming_WriteNonNote_CheckType:
	cp w, 0x9f
	jr z, AccKbdTiming_WriteNonNote_Done
	cp w, 0xd0
	jr z, AccKbdTiming_WriteNonNote_Done
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_WriteNonNote_Byte4
	ld ix, (xhl + 0:8)

AccKbdTiming_WriteNonNote_Byte4:
	calr AccSeq_WriteByte
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_WriteNonNote_Byte5
	ld ix, (xhl + 0:8)

AccKbdTiming_WriteNonNote_Byte5:
	calr AccSeq_WriteByte
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_WriteNonNote_Byte6
	ld ix, (xhl + 0:8)

AccKbdTiming_WriteNonNote_Byte6:
	calr AccSeq_WriteByte

AccKbdTiming_WriteNonNote_Done:
	ld (xhl + 6), ix
	jrl AccKbdTiming_EventLoop

AccKbdTiming_TimestampOverflow:
	cp	(0x39c1:16), 192
	jr	nz, AccKbdTiming_Overflow_SubBase
	ld	(0x39c0:16), 0
AccKbdTiming_Overflow_SubBase:
	sub	a, (0x45d:16)
	cp	a, (0x32bf:16)
	jr	nc, AccKbdTiming_Overflow_CalcSkip
	ld	(0x32bf:16), a
AccKbdTiming_Overflow_CalcSkip:
	ld	ix, (0x32c0:16)
	ld	(xhl+ix), a
	inc	1, ix
	cp	ix, (xhl+2)
	jr	ule, AccKbdTiming_Overflow_AdvancePos
	ld	ix, (xhl+0:8)
AccKbdTiming_Overflow_AdvancePos:
	xor wa, wa

	ld	a, (13000:16)

	add ix, wa

	cp ix, (xhl + 2)

	jrl ule, AccKbdTiming_EventLoop

	sub ix, (xhl + 2)

	dec 1, ix

	add ix, (xhl + 0:8)

	; jrl AccKbdTiming_EventLoop (v7 displacement)
	jrl	AccKbdTiming_EventLoop
AccKbdTiming_ScanDone:
	ret

AccKbdTiming_CatchupReplay:
	push xwa
	push xhl
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	ld iy, ix
	ld ix, (xhl + 6)

AccKbdTiming_Catchup_Loop:
	cp	ix, iy
	jr	z, AccKbdTiming_Catchup_Done	; -> 0xF5B4F4
	ld	a, (xhl+ix)
	ld	w, a
	and	w, 240
	cp	w, 192
	jr	nz, AccKbdTiming_Catchup_SkipNonC0	; -> 0xF5B4EF
	ld	a, w
	or	a, (14788:16)
	calr	AccSeq_WriteByte
	calr	AccKbdTiming_AdvancePos
	calr	AccKbdTiming_AdvancePos
	ld	a, (xhl+ix)
	calr	AccSeq_WriteByte
	calr	AccKbdTiming_AdvancePos
	ld	a, (xhl+ix)
	calr	AccSeq_WriteByte
	calr	AccKbdTiming_AdvancePos
	ld	a, (xhl+ix)
	calr	AccSeq_WriteByte
	calr	AccKbdTiming_AdvancePos
	ld	a, (xhl+ix)
	calr	AccSeq_WriteByte
	calr	AccKbdTiming_AdvancePos
	ld	a, (xhl+ix)
	calr	AccSeq_WriteByte
	calr	AccKbdTiming_AdvancePos
	jr	AccKbdTiming_Catchup_Loop	; -> 0xF5B494
AccKbdTiming_Catchup_SkipNonC0:
	calr AccKbdTiming_AdvancePos
	jr AccKbdTiming_Catchup_Loop

AccKbdTiming_Catchup_Done:
	pop xiz
	pop xiy
	pop xix
	pop xde
	pop xbc
	pop xhl
	pop xwa
	ret

AccKbdTiming_AdvancePos:
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccKbdTiming_AdvancePos_Ret
	ld ix, (xhl + 0:8)

AccKbdTiming_AdvancePos_Ret:
	ret

AccKbdTiming_TableScan:
	xor iz, iz

AccKbdTiming_TableScan_Loop:
	cp	iz, (ACC_SLOT_TABLE_SIZE:16)
	jp	nc, (0xf5ad96:24)
	bit	7, (xbc+iz)
	jr	z, AccKbdTiming_TableScan_NextSlot
	ld	ix, iz
	ld	a, (xbc+ix)
	ld	(0x32c9:16), a
	inc	2, ix
	ld	a, (xbc+ix)
	ld	(0x32ca:16), a
	inc	1, ix
	ld	a, (xbc+ix)
	ld	(0x32cb:16), a
	inc	1, ix
	ld	wa, (xbc+ix)
	cp	wa, (0x45e:16)
	jr	gt, AccKbdTiming_TableScan_Decrement
	ld	a, 240:opc
	and	a, (0x32c9:16)
	or	a, 8
	calr	AccSeq_WriteByte
	ld	a, (0x32ca:16)
	calr	AccSeq_WriteByte
	ld	a, 0:opc
	calr	AccSeq_WriteByte
	and	(xbc+iz), 0x7f
	jr	AccKbdTiming_TableScan_NextSlot
AccKbdTiming_TableScan_Decrement:
	sub wa, (1118:16)
	bit 7, a
	jr z, AccKbdTiming_TableScan_StoreTiming
	add a, 0x60

AccKbdTiming_TableScan_StoreTiming:
	ld	(xbc+ix), wa
	cp	wa, (ACC_NOTES_MIN_SCAN:16)
	jr	nc, AccKbdTiming_TableScan_NextSlot
	ld	(ACC_NOTES_MIN_SCAN:16), wa
AccKbdTiming_TableScan_NextSlot:
	; addda16 xiz, 0x337c (v7 patched)
	add	iz, (ACC_SLOT_STRIDE:16)
	; jrl AccKbdTiming_TableScan_Loop (v7 displacement)
	jrl	AccKbdTiming_TableScan_Loop
AccKbdTiming_TableScan_Done:
	ret

AccSeq_WriteByte:
	push xhl
	push xbc
	push xde
	push xix
	push xiy
	pushw wa
	pushw wa
	call RhythmBuf_WriteByte
	inc 2, xsp
	popw wa
	pop xiy
	pop xix
	pop xde
	pop xbc
	pop xhl
	ret

AccAccTiming_ScanRingBuf:
	ld	(14786:16), 255
	ld	ix, (xhl+6)
AccAccTiming_EventLoop:
	cp (xhl + 4), ix
	jrl z, AccAccTiming_ScanDone
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_ClassifyEvent
	ld ix, (xhl + 0:8)

AccAccTiming_ClassifyEvent:
	ld	w, a
	cp	a, 144
	jr	nz, AccAccTiming_Check0x91
	ld	(13000:16), 5
	jr	AccAccTiming_StoreEventData
AccAccTiming_Check0x91:
	cp	a, 145
	jr	nz, AccAccTiming_Check0x92
	ld	(13000:16), 7
	jr	AccAccTiming_StoreEventData
AccAccTiming_Check0x92:
	cp	a, 146
	jr	nz, AccAccTiming_CheckProgramChg
	ld	(13000:16), 6
	jr	AccAccTiming_StoreEventData
AccAccTiming_CheckProgramChg:
	and	a, 240
	cp	a, 192
	jr	nz, AccAccTiming_CheckControl
	ld	(13000:16), 5
	jr	AccAccTiming_StoreEventData
AccAccTiming_CheckControl:
	cp	a, 208
	jrl	nz, AccAccTiming_SkipEvent
	ld	(13000:16), 2
AccAccTiming_StoreEventData:
	ld	(0x39c3:16), a
	ld	a, (xhl+ix)
	ld	(0x32c2:16), ix
	inc	1, ix
	cp	ix, (xhl+2)
	jr	ule, AccAccTiming_CheckTimestamp
	ld	ix, (xhl+0:8)
AccAccTiming_CheckTimestamp:
	cp	a, (0x45d:16)
	jrl	ugt, AccAccTiming_TimestampOverflow
	ld	a, w
	and	a, 240
	cp	a, 144
	jrl	nz, AccAccTiming_WriteNonNote
	cp	(0x39c2:16), 0
	jr	nz, AccAccTiming_NoteSlotScan
	pushw	wa
	ld	a, (ACC_SLOT_CHANNEL:16)
	ld	(0x39c4:16), a
	popw	wa
	calr	AccKbdTiming_CatchupReplay
	ld	(0x39c2:16), 255
AccAccTiming_NoteSlotScan:
	pushw wa
	ld	w, (xhl+ix)
	xor iz, iz

AccAccTiming_NoteSlot_Loop:
	cp	iz, (ACC_SLOT_TABLE_SIZE:16)
	jr	nc, AccAccTiming_NoteSlot_FindFree
	bit	7, (xbc+iz)
	jr	z, AccAccTiming_NoteSlot_NextSlot
	ld	qiz, iz
	add	iz, 2
	cp	(xbc+iz), w
	ld	iz, qiz
	jr	z, AccAccTiming_NoteSlot_SendNoteOff
AccAccTiming_NoteSlot_NextSlot:
	add	iz, (ACC_SLOT_STRIDE:16)
	jr	AccAccTiming_NoteSlot_Loop
AccAccTiming_NoteSlot_SendNoteOff:
	ld	a, (xbc+iz)
	and	(xbc+iz), 0x7f
	and	a, 240
	or	a, (ACC_SLOT_CHANNEL:16)
	calr	AccSeq_WriteByte
	ld	a, w
	calr	AccSeq_WriteByte
	ld	a, 0:opc
	calr	AccSeq_WriteByte
	bit	0, (0x32d5:16)
	jr	nz, AccAccTiming_NoteSlot_FindFree
	or	(0x32d5:16), 1
	ld	a, 144:opc
	calr	AccSeq_WriteByte
	ld	a, 0:opc
	calr	AccSeq_WriteByte
	calr	AccSeq_WriteByte
AccAccTiming_NoteSlot_FindFree:
	popw wa
	xor iz, iz

AccAccTiming_NoteSlot_FreeLoop:
	cp	iz, (ACC_SLOT_TABLE_SIZE:16)
	jr	nc, AccAccTiming_SlotOverflow
	bit	7, (xbc+iz)
	jr	z, AccAccTiming_WriteNoteEvent
	add	iz, (ACC_SLOT_STRIDE:16)
	jr	AccAccTiming_NoteSlot_FreeLoop
AccAccTiming_SlotOverflow:
	pushw	wa
	xor	xwa, xwa
	ld	a, (ACC_SLOT_STEAL_INDEX:16)
	sla	xwa, 2
	add	xwa, AccAccTiming_SlotOverflow_Data
	ld	iz, (xwa)
	ld	a, (xbc+iz)
	and	(xbc+iz), 0x7f
	pushw	iz
	inc	2, iz
	ld	w, (xbc+iz)
	and	a, 240
	or	a, (ACC_SLOT_CHANNEL:16)
	calr	AccSeq_WriteByte
	ld	a, w
	calr	AccSeq_WriteByte
	ld	a, 0:opc
	calr	AccSeq_WriteByte
	popw	iz
	popw	wa
	inc	1, (ACC_SLOT_STEAL_INDEX:16)
	cp	(ACC_SLOT_STEAL_INDEX:16), 8
	jr	c, AccAccTiming_SlotOverflow_Done
	ld	(ACC_SLOT_STEAL_INDEX:16), 0
AccAccTiming_SlotOverflow_Done:
	jr AccAccTiming_WriteNoteEvent

AccAccTiming_SkipEvent:
	ld ix, (xhl + 4)
	ld (xhl + 6), ix
	jrl AccAccTiming_EventLoop

AccAccTiming_WriteNoteEvent:
	or	a, (ACC_SLOT_CHANNEL:16)
	calr	AccSeq_WriteByte
	ld	a, w
	ld	(xbc+iz), a
	inc	1, iz
	ld	a, 0:opc
	ld	(xbc+iz), a
	inc	1, iz
	ld	a, (xhl+ix)
	inc	1, ix
	cp	ix, (xhl+2)
	jr	ule, AccAccTiming_WriteNote_Byte2
	ld	ix, (xhl+0:8)
AccAccTiming_WriteNote_Byte2:
	calr AccSeq_WriteByte
	ld	(xbc+iz), a
	inc 1, iz
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_WriteNote_Byte3
	ld ix, (xhl + 0:8)

AccAccTiming_WriteNote_Byte3:
	calr AccSeq_WriteByte
	ld	(xbc+iz), a
	inc 1, iz
	pushw wa
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_WriteNote_ReadTimingLo
	ld ix, (xhl + 0:8)

AccAccTiming_WriteNote_ReadTimingLo:
	ld	w, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_WriteNote_ReadTimingHi
	ld ix, (xhl + 0:8)

AccAccTiming_WriteNote_ReadTimingHi:
	add wa, (1118:16)
	cp a, 0x60
	jr c, AccAccTiming_WriteNote_StoreTiming
	inc 1, w
	sub a, 0x60

AccAccTiming_WriteNote_StoreTiming:
	ld	(xbc+iz), wa
	inc	2, iz
	cp	wa, (ACC_NEXT_NOTE_OFF:16)
	jr	nc, AccAccTiming_WriteNote_ExtraBytes	; -> 0xF5B795
	ld	(ACC_NEXT_NOTE_OFF:16), wa
AccAccTiming_WriteNote_ExtraBytes:
	popw wa
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_WriteNote_StoreExtra1
	ld ix, (xhl + 0:8)

AccAccTiming_WriteNote_StoreExtra1:
	ld	(xbc+iz), a
	inc 1, iz
	cp w, 0x90
	jr z, AccAccTiming_WriteNote_Done
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_WriteNote_StoreExtra2
	ld ix, (xhl + 0:8)

AccAccTiming_WriteNote_StoreExtra2:
	ld	(xbc+iz), a
	inc 1, iz
	cp w, 0x92
	jr z, AccAccTiming_WriteNote_Done
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_WriteNote_StoreExtra3
	ld ix, (xhl + 0:8)

AccAccTiming_WriteNote_StoreExtra3:
	ld	(xbc+iz), a
	inc 1, iz

AccAccTiming_WriteNote_Done:
	ld (xhl + 6), ix
	jrl AccAccTiming_EventLoop

AccAccTiming_WriteNonNote:
	ld	w, a
	or	a, (ACC_SLOT_CHANNEL:16)
	calr	AccSeq_WriteByte
	ld	a, (xhl+ix)
	inc	1, ix
	cp	ix, (xhl+2)
	jr	ule, AccAccTiming_WriteNonNote_Byte2
	ld	ix, (xhl+0:8)
AccAccTiming_WriteNonNote_Byte2:
	calr	AccSeq_WriteByte
	ld	(0x327c:16), a
	ld	a, (xhl+ix)
	inc	1, ix
	cp	ix, (xhl+2)
	jr	ule, AccAccTiming_WriteNonNote_Byte3
	ld	ix, (xhl+0:8)
AccAccTiming_WriteNonNote_Byte3:
	calr	AccSeq_WriteByte
	cp	w, 208
	jr	nz, AccAccTiming_WriteNonNote_ExtBytes
	cp	(0x327c:16), 3
	jr	nz, AccAccTiming_WriteNonNote_Done
	ld	(ACC_CUR_CC3:16), a
	jr	AccAccTiming_WriteNonNote_Done
AccAccTiming_WriteNonNote_ExtBytes:
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_WriteNonNote_Byte5
	ld ix, (xhl + 0:8)

AccAccTiming_WriteNonNote_Byte5:
	calr AccSeq_WriteByte
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_WriteNonNote_Byte6
	ld ix, (xhl + 0:8)

AccAccTiming_WriteNonNote_Byte6:
	calr AccSeq_WriteByte
	ld	a, (xhl+ix)
	inc 1, ix
	cp ix, (xhl + 2)
	jr ule, AccAccTiming_WriteNonNote_Byte7
	ld ix, (xhl + 0:8)

AccAccTiming_WriteNonNote_Byte7:
	calr AccSeq_WriteByte

AccAccTiming_WriteNonNote_Done:
	ld (xhl + 6), ix
	jrl AccAccTiming_EventLoop

AccAccTiming_TimestampOverflow:
	cp	(0x39c3:16), 192
	jr	nz, AccAccTiming_Overflow_SubBase
	ld	(0x39c2:16), 0
AccAccTiming_Overflow_SubBase:
	sub	a, (0x45d:16)
	cp	a, (0x32bf:16)
	jr	nc, AccAccTiming_Overflow_CalcSkip
	ld	(0x32bf:16), a
AccAccTiming_Overflow_CalcSkip:
	ld	ix, (0x32c2:16)
	ld	(xhl+ix), a
	inc	1, ix
	cp	ix, (xhl+2)
	jr	ule, AccAccTiming_Overflow_AdvancePos
	ld	ix, (xhl+0:8)
AccAccTiming_Overflow_AdvancePos:
	xor wa, wa

	ld	a, (13000:16)

	add ix, wa

	cp ix, (xhl + 2)

	; jrl ule, AccAccTiming_EventLoop (v7 displacement)
	jrl	ule, AccAccTiming_EventLoop
	sub ix, (xhl + 2)

	dec 1, ix

	add ix, (xhl + 0:8)

	; jrl AccAccTiming_EventLoop (v7 displacement)
	jrl	AccAccTiming_EventLoop
AccAccTiming_ScanDone:
	ret

AccAccTiming_TableScan:
	xor iz, iz

AccAccTiming_TableScan_Loop:
	cp	iz, (ACC_SLOT_TABLE_SIZE:16)
	jp	nc, (0xf5b13e:24)
	bit	7, (xbc+iz)
	jr	z, AccAccTiming_TableScan_NextSlot
	ld	ix, iz
	ld	a, (xbc+ix)
	ld	(0x32c9:16), a
	inc	2, ix
	ld	a, (xbc+ix)
	ld	(0x32ca:16), a
	inc	1, ix
	ld	a, (xbc+ix)
	ld	(0x32cb:16), a
	inc	1, ix
	ld	wa, (xbc+ix)
	cp	wa, (0x45e:16)
	jr	gt, AccAccTiming_TableScan_Decrement
	ld	a, 240:opc
	and	a, (0x32c9:16)
	or	a, (ACC_SLOT_CHANNEL:16)
	calr	AccSeq_WriteByte
	ld	a, (0x32ca:16)
	calr	AccSeq_WriteByte
	ld	a, 0:opc
	calr	AccSeq_WriteByte
	and	(xbc+iz), 0x7f
	jr	AccAccTiming_TableScan_NextSlot
AccAccTiming_TableScan_Decrement:
	sub wa, (1118:16)
	bit 7, a
	jr z, AccAccTiming_TableScan_StoreTiming
	add a, 0x60

AccAccTiming_TableScan_StoreTiming:
	ld	(xbc+ix), wa
	cp	wa, (ACC_NOTES_MIN_SCAN:16)
	jr	nc, AccAccTiming_TableScan_NextSlot
	ld	(ACC_NOTES_MIN_SCAN:16), wa
AccAccTiming_TableScan_NextSlot:
	; addda16 xiz, 0x337c (v7 patched)
	add	iz, (ACC_SLOT_STRIDE:16)
	; jrl AccAccTiming_TableScan_Loop (v7 displacement)
	jrl	AccAccTiming_TableScan_Loop
AccAccTiming_TableScan_Done:
	ret

AccTiming_SlotOffsetTables:
; AccTiming_SlotOffsetTables -- two tables of 8 x LE32 slot offsets.
; ** RE-TYPED 2026-09-25 (lane accomp): was nop/`ei 0`/incf/`calr 0`/`jp 0`
; mnemonics plus a 16-byte .byte tail (data-as-code).  Readers:
;   AccKbdTiming_SlotOverflow:  xor xwa,xwa / ld a,(0x3384) / sla xwa,2 /
;       add xwa, AccTiming_SlotOffsetTables / ld iz,(xwa)
;   AccAccTiming_SlotOverflow:  the same, from AccAccTiming_SlotOverflow_Data
; so entry (0x3384) (stride 4, low 16 bits used) becomes IZ, the byte offset
; of a note slot that the code then reads and writes through the SRI (xix+iz)
; forms.  The first table steps by 6 and the second by 9 -- consistent with
; the per-slot stride the two free-slot scans add (`add iz, (0x337c:16)`).
; Size: the +0x20 reader pins the first table at 8 entries; the second is
; the 32 bytes up to AccDir_TickVector.
; readers in v7 (address from the linked ELF): AccKbdTiming_SlotOverflow 0xF5B2CD,
;     AccAccTiming_SlotOverflow 0xF5B6B6
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; +0x00  8 x LE32 = 0, 6, 12 ... 42 (stride 6) -- keyboard-timing slots
	.long 0x00000000, 0x00000006, 0x0000000c, 0x00000012
	.long 0x00000018, 0x0000001e, 0x00000024, 0x0000002a
; +0x20  8 x LE32 = 0, 9, 18 ... 63 (stride 9) -- accompaniment-timing slots
AccAccTiming_SlotOverflow_Data:
	.long 0x00000000, 0x00000009, 0x00000012, 0x0000001b
	.long 0x00000024, 0x0000002d, 0x00000036, 0x0000003f

; AccDir_TickVector: Slot 0 of the AccDir jump-vector block (`jp AccDir_Main`; AccDir_PeriodicEntry's `jp
;   AccDir_PeriodicCheck` follows): Seq_DispatcherTick calls it on every sequencer tick, before the Sound Arranger and
;   tap-tempo vectors. AccDir_Main steps the VARIATION field (record 0x48 +7 bits 4-5, RAM 0xFC61) down or up when the
;   low 6 bits of RAM 0x3276 / 0x3277 drop to 0 (only while 0xFD99 bit 0 is set and the style number is below 128) and
;   posts it as panel event 0x48/7. Basis: callers + body -- same shape as AccPlay_TickVector.
AccDir_TickVector:
	jp AccDir_Main

AccDir_PeriodicEntry:
	jp AccDir_PeriodicCheck

AccDir_Main:
	calr AccDir_ReadState
	cp	(0x33ef:16), 0x00
	jr nz, .Lc_f5b990
	cp	(0x33f0:16), 0x00
	jr z, .Lc_f5b990
	or	(0x33e7:16), 0x01
AccDir_CheckLeftNote:
.Lc_f5b990:
	cp	(0x33f1:16), 0x00
	jr nz, .Lc_f5b9a3
	cp	(0x33f2:16), 0x00
	jr z, .Lc_f5b9a3
	or	(0x33e7:16), 0x08
AccDir_CheckRightHandState:
.Lc_f5b9a3:
	ld	a, (0x33ed:16)
	bit 0x00,A
	jr nz, AccDir_Finalize
	bit 0x01,A
	jr z, AccDir_Finalize
	and	(0x33e7:16), 0xf6
	ld	(0x33ee:16), 0x00
AccDir_Finalize:
	calr AccDir_AdjustDirection
	calr AccDir_SavePrevState
	ret

AccDir_Padding1:
	nop
	nop

AccDir_ReadState:
	ld a, (PANEL_STYLE:16)
	ld	(0x33ec:16), a
	ld	a, (ACC_LANES_FILLIN1:16)
	and A,0x3f
	ld	(0x33ef:16), a
	ld	a, (ACC_LANES_FILLIN2:16)
	and A,0x3f
	ld	(0x33f1:16), a
	ld a, (ACC_CLOCK:16)
	ld	(0x33e8:16), a
	ld	a, (0x33ed:16)
	and A,0xfe
	bit	0, (ACC_RUN_FLAGS:16)
	jr z, .Lc_f5b9fa
	or A,0x01
AccDir_ReadState_StoreFlags:
.Lc_f5b9fa:
	ld	(0x33ed:16), a
	ld a, (PANEL_PMEM_SETTINGS+3:16)
	bit 0x00,A
	jr nz, AccDir_ReadState_Ret
	and	(0x33e7:16), 0xf6
AccDir_ReadState_Ret:
	ret

AccDir_Padding2:
	nop
	nop

AccDir_SavePrevState:
	ld	a, (13295:16)
	ld	(13296:16), a
	ld	a, (13297:16)
	ld	(13298:16), a
	ld	a, (13293:16)
	and	a, 253
	bit	0, a
	jr	z, AccDir_SavePrevState_StoreFlags
	or	a, 2
AccDir_SavePrevState_StoreFlags:
	ld	(13293:16), a
	ret
AccDir_Padding3:
	nop
	nop

AccDir_AdjustDirection:
	ld	a, (0x33e7:16)
	and A,0x09
	cp a, 0:i3
	jp z, (AccDir_Adjust_Ret:24)
	bit	0, (0x33e7:16)
	jr z, AccDir_Adjust_LeftHand
	and	(0x33e7:16), 0xfe
	cp	(0x33ec:16), 0x80
	jr nc, AccDir_Adjust_LeftHand
	ld w, (PANEL_PMEM_SETTINGS+3:16)
	and W,0x01
	ld a, (PANEL_STYLE+7:16)
	and A,0x30
	srl A, 0x04
	cp w, 0:i3
	jr z, AccDir_Adjust_LeftHand
	dec 1,A
	cp A,0xff
	jr nz, AccDir_Adjust_RightDec
	ld A, 0x00:opc
AccDir_Adjust_RightDec:
	sll a, 4
	and (PANEL_STYLE+7:16), 207
	or (PANEL_STYLE+7:16), a
	calr AccDir_DispatchEvent

AccDir_Adjust_LeftHand:
	bit	3, (0x33e7:16)
	jr	z, AccDir_Adjust_SetChanged
	and	(0x33e7:16), 247
	cp	(0x33ec:16), 128
	jr	nc, AccDir_Adjust_SetChanged
	ld	w, (PANEL_PMEM_SETTINGS+3:16)
	and	w, 1
	ld	a, (PANEL_STYLE+7:16)
	and	a, 48
	srl	a, 4
	cp	w, 0:i3
	jr	z, AccDir_Adjust_SetChanged
	inc	1, a
	cp	a, 4:i3
	jr	c, AccDir_Adjust_LeftInc
	ld	a, 3:opc
AccDir_Adjust_LeftInc:
	sll a, 4
	and (PANEL_STYLE+7:16), 207
	or (PANEL_STYLE+7:16), a
	calr AccDir_DispatchEvent

AccDir_Adjust_SetChanged:
	ld	(13294:16), 1
AccDir_Adjust_Ret:
	ret

AccDir_Padding4:
	nop
	nop

AccDir_DispatchEvent:
	ld w, (PANEL_PMEM_SETTINGS+3:16)
	and W,0x01
	cp w, 0:i3
	jr z, AccDir_DispatchEvent_Ret
	cp	(0x33ec:16), 0x80
	jr nc, AccDir_DispatchEvent_Ret
	ld E, 0x48:opc
	ld D, 0x07:opc
	ld a, (PANEL_STYLE+7:16)
	ld W, 0x30:opc
	call SwbtWr_QueuePostEvent
	ld a, (PANEL_PMEM_SETTINGS+3:16)
	and A,0x70
	cp A,0x10
	jr z, AccDir_DispatchEvent_Ret
	ld a, (PANEL_STYLE+7:16)
	and A,0x30
	srl A, 0x04
	ld	(0x8c9c:16), a
	call EffectMode_ReinitWithFlag
AccDir_DispatchEvent_Ret:
	ret

AccDir_Padding5:
	nop
	nop

AccDir_PeriodicCheck:
	bit	4, (0x31cc:16)
	jr z, AccDir_Periodic_Ret
	cp	(0x33ee:16), 0x00
	jr z, .Lc_f5bb1a
	dec	1, (0x33ee:16)
AccDir_Periodic_CheckCountdown:
.Lc_f5bb1a:
	cp	(0x33ee:16), 0x00
	jr nz, AccDir_Periodic_Ret
	ld a, (ACC_CLOCK:16)
	cp A,0x5d
	jr nc, .Lc_f5bb2f
	cp A,0x30
	jr ugt, AccDir_Periodic_Ret
AccDir_Periodic_DisableAndReset:
.Lc_f5bb2f:
	and	(0x31cc:16), 0xef
	and	(0x31cc:16), 0xfb
call AudioMode_SetStereoFlags



AccDir_Periodic_Ret:
	ret

AccDir_JumpTable:
	nop
	nop
SwbtB3_CodeA8_Listener0:
	call	AccProcess_InlinedCode
	ret
AccProcess_TapTempoTick:
	call AccProcess_TimerCompare
	ret

AccProcess_InlinedCode:
	; framing ported from v10's source for the same label (same span length, statement for statement); 45 of 74 slots byte-identical
	ld	a, (SWBTWR_PAYLOAD_1:16)
	cp	a, 18
	; v10 does not spell this byte either
	jp	nz, (0xf5b3ea:24)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	ld	a, (SWBTWR_PAYLOAD_2:16)
	; differs from v10 here and llvm-objdump cannot read it
	and	a, (SWBTWR_PAYLOAD_3:16)
	and	a, 1
	cp	a, 1:i3
	; v10 does not spell this byte either
	jp	nz, (0xf5b3ea:24)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	bit	0, (0x33d8:16)
	; v10 does not spell this byte either
	jr	nz, AccProcess_Entry_Skip5
	ld	wa, (SYSTEM_TIMESTAMP:16)
	ld	(TAP_TEMPO_LAST_TAP_TIME:16), wa
	; v10 does not spell this byte either
	or	(0x33d8:16), 1
	; v10 does not spell this byte either
	jr	AccProcess_Entry_Return
AccProcess_Entry_Skip5:
	ld	wa, (SYSTEM_TIMESTAMP:16)
	ld	bc, (TAP_TEMPO_LAST_TAP_TIME:16)
	cp	wa, bc
	jr	c, AccProcess_InlinedCode_Skip6
	sub	wa, bc
	jr	AccProcess_InlinedCode_Join2
AccProcess_InlinedCode_Skip6:
	and	xwa, 65535
	and	xbc, 65535
	add	xwa, 65536
	sub	xwa, xbc
AccProcess_InlinedCode_Join2:
	cp	wa, 750
	jr	c, AccProcess_InlinedCode_Skip
	ldw	wa, 750
AccProcess_InlinedCode_Skip:
	cp	wa, 100
	jr	ugt, AccProcess_InlinedCode_Skip2
	ldw	wa, 100
AccProcess_InlinedCode_Skip2:
	ld	bc, wa
	ld	xwa, 30000
	div	xwa, bc
	pushw	wa
	calr	AccProcess_Entry_Helper
	popw	wa
	ld	hl, (13276:16)
	ld	(13278:16), hl
	ld	hl, (13274:16)
	ld	(13276:16), hl
	ld	(13274:16), wa
	ld	wa, (SYSTEM_TIMESTAMP:16)
	ld	(TAP_TEMPO_LAST_TAP_TIME:16), wa
AccProcess_Entry_Return:
	ret
AccProcess_Entry_Helper:
	ld	de, (13274:16)
	ld	bc, (13276:16)
	cp	de, 0:i3
	jr	nz, AccProcess_Entry_Skip3
	jp	AccProcess_Entry_Join
AccProcess_Entry_Skip3:
	cp	bc, 0:i3
	jr	nz, AccProcess_Entry_Skip4
	add	wa, de
	srl	wa, 1
	jp	AccProcess_Entry_Join
AccProcess_Entry_Skip4:
	add	wa, de
	add	wa, bc
	and	xwa, 65535
	div	wa, 3
AccProcess_Entry_Join:
	ld	e, 72:opc
	ld	d, 8:opc
	call	SwbtWr_TrailingBytecode
	ret
AccProcess_TimerCompare:
	bit	0, (0x33d8:16)
	jr	z, AccProcess_Timer_Ret
	ld	wa, (SYSTEM_TIMESTAMP:16)
	ld	bc, (TAP_TEMPO_LAST_TAP_TIME:16)
	cp	wa, bc
	jr	c, AccProcess_Timer_WrapCase
	sub	wa, bc
	cp	wa, 1024
	jr	c, AccProcess_Timer_Skip
	and	(0x33d8:16), 254
	xor	wa, wa
	ld	(0x33da:16), wa
	ld	(0x33dc:16), wa
	ld	(0x33de:16), wa
AccProcess_Timer_Skip:
	jr AccProcess_Timer_Ret

AccProcess_Timer_WrapCase:
	and	xwa, 65535
	and	xbc, 65535
	add	xwa, 65536
	sub	xwa, xbc
	cp	wa, 1024
	jr	c, AccProcess_Timer_Ret
	and	(0x33d8:16), 254
	xor	wa, wa
	ld	(0x33da:16), wa
	ld	(0x33dc:16), wa
	ld	(0x33de:16), wa
AccProcess_Timer_Ret:
	ret

AccVoice_DispatchEntry:
	jp AccVoice_Dispatch

AccVoice_DispatchWithChannel:
	push xiz
	ld l, a
	ld h, c
	call AccVoice_Dispatch
	ld xhl, xiy
	pop xiz
	ret

AccVoice_GetChannelCount_Wrap:
	push xiz
	ld l, a
	call AccVoice_GetChannelCount
	pop xiz
	ret

AccVoice_GetChannelCount_Direct:
	call AccVoice_GetChannelCount
	ret

AccVoice_CopyFromROM_Wrap:
	push xiz
	ld l, a
	call AccVoice_CopyFromROM
	ld xhl, xiy
	pop xiz
	ret

AccVoice_Dispatch:
	push xwa
	push xbc
	push xde
	push xhl
	push xiy
	cp l, 0x10
	jr c, AccVoice_Dispatch_ClampH
	xor l, l

AccVoice_Dispatch_ClampH:
	cp h, 0x50
	jr c, AccVoice_Dispatch_CheckType
	xor h, h

AccVoice_Dispatch_CheckType:
	cp l, 0xf
	jr nz, AccVoice_Dispatch_Type0E
	calr AccVoice_ROMLookup
	jr AccVoice_Dispatch_Epilogue

AccVoice_Dispatch_Type0E:
	cp l, 0xe
	jr nz, AccVoice_Dispatch_TypeDefault
	calr AccVoice_IndexedTableLookup
	jr AccVoice_Dispatch_Epilogue

AccVoice_Dispatch_TypeDefault:
	calr AccVoice_ComputedCopy

AccVoice_Dispatch_Epilogue:
	pop	xiy
	pop	xhl
	pop	xde
	pop	xbc
	pop	xwa
	ld	xiy, 13299
	ret
AccVoice_Dispatch_Padding:
	nop
	nop

AccVoice_ComputedCopy:
	ld a, l

	xor w, w

	muls wa, 0x14

	ld l, h

	xor h, h

	add wa, hl

	muls wa, 0xd

	; add xwa, AccVoice_RomRecords13 (v7 patched)
	add	xwa, AccVoice_RomRecords13
	ld xiy, xwa

	ld	xix, 13299

	ldw bc, 0xd

	ldir85

	ret



AccVoice_ComputedCopy_Padding:
	nop
	nop

AccVoice_ROMLookup:
	ld L,H
	and HL,0x000f
	sla HL, 0x02
	ld XIX,AccVoice_ROMLookup_Data
	ld XIY,RHYTHM_PATTERN_BUF_A
	.byte	0xe3, 0x07, 0xf0, 0xec, 0x85, 0x44, 0xf3, 0x33
	.byte 0x00, 0x00, 0x31, 0x0d, 0x00, 0x85, 0x11, 0x0e
AccVoice_ROMLookup_OffsetTable:
	.byte	0x00, 0x00
AccVoice_ROMLookup_Data:	.byte	0xa0, 0x00, 0x00, 0x00, 0x00, 0x01


	naka_header NAKA_TYPE_Object
	.byte 0x00, 0x00, 0xc0, 0x01
	.byte 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x80, 0x02
	.byte 0x00, 0x00, 0xe0, 0x02, 0x00, 0x00, 0x40, 0x03
	.byte 0x00, 0x00, 0xa0, 0x03, 0x00, 0x00, 0x00, 0x04
	.byte 0x00, 0x00, 0x60, 0x04, 0x00, 0x00, 0xc0, 0x04
	.byte 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0xa0, 0x00
	.byte 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0xa0, 0x00
	.byte 0x00, 0x00

AccVoice_IndexedTableLookup:
	ld L,H
	xor H,H
	sla HL, 0x02
	ld XIX,AccVoice_IndexedTableLookup_Data
	.byte	0xe3, 0x07, 0xf0, 0xec, 0x25, 0x44, 0xe1, 0xb6
	.byte 0xf5, 0x00, 0xe3, 0x07, 0xf0, 0xec, 0x85, 0x44
	.byte	0xf3, 0x33, 0x00, 0x00, 0x31, 0x0d, 0x00, 0x85
	.byte 0x11, 0x0e
AccVoice_IndexedTableLookup_BaseOffsets:
	.byte	0x00, 0x00	; |..|
AccVoice_IndexedTableLookup_Data:	.byte	0x00, 0x00, 0x30, 0x00, 0x00, 0x00
	.byte 0x30, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00
	.byte 0x30, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00
	.byte 0x30, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00
	.byte 0x30, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00
	.byte 0x30, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x00
	.byte 0x30, 0x00, 0x00, 0x98, 0x31, 0x00, 0x00, 0x98
	.byte 0x31, 0x00, 0x00, 0x98, 0x31, 0x00, 0x00, 0x98
	.byte 0x31, 0x00, 0x00, 0x98, 0x31, 0x00, 0x00, 0x98
	.byte 0x31, 0x00, 0x00, 0x98, 0x31, 0x00, 0x00, 0x98
	.byte 0x31, 0x00, 0x00, 0x98, 0x31, 0x00, 0x00, 0x98
	.byte 0x31, 0x00, 0x00, 0x98, 0x31, 0x00, 0x00, 0x98
	.byte 0x31, 0x00, 0x00, 0x00, 0x33, 0x00, 0x00, 0x00
	.byte 0x33, 0x00, 0x00, 0x00, 0x33, 0x00, 0x00, 0x00
	.byte 0x33, 0x00, 0x00, 0x00, 0x33, 0x00, 0x00, 0x00
	.byte 0x33, 0x00, 0x00, 0x00, 0x33, 0x00, 0x00, 0x00
	.byte 0x33, 0x00, 0x00, 0x00, 0x33, 0x00, 0x00, 0x00
	.byte 0x33, 0x00, 0x00, 0x00, 0x33, 0x00, 0x00, 0x00
	.byte 0x33, 0x00, 0x00, 0x98, 0x34, 0x00, 0x00, 0x98
	.byte 0x34, 0x00, 0x00, 0x98, 0x34, 0x00, 0x00, 0x98
	.byte 0x34, 0x00, 0x00, 0x98, 0x34, 0x00, 0x00, 0x98
	.byte 0x34, 0x00, 0x00, 0x98, 0x34, 0x00, 0x00, 0x98
	.byte 0x34, 0x00, 0x00, 0x98, 0x34, 0x00, 0x00, 0x98
	.byte 0x34, 0x00, 0x00, 0x98, 0x34, 0x00, 0x00, 0x98
	.byte 0x34, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00
	.byte 0x36, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00
	.byte 0x36, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00
	.byte 0x36, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00
	.byte 0x36, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00
	.byte 0x36, 0x00, 0x00, 0x00, 0x36, 0x00, 0x00, 0x00
	.byte 0x36, 0x00, 0x00, 0x98, 0x37, 0x00, 0x00, 0x98
	.byte 0x37, 0x00, 0x00, 0x98, 0x37, 0x00, 0x00, 0x98
	.byte 0x37, 0x00, 0x00, 0x98, 0x37, 0x00, 0x00, 0x98
	.byte 0x37, 0x00, 0x00, 0x98, 0x37, 0x00, 0x00, 0x98
	.byte 0x37, 0x00, 0x00, 0x98, 0x37, 0x00, 0x00, 0x98
	.byte 0x37, 0x00, 0x00, 0x98, 0x37, 0x00, 0x00, 0x98
	.byte 0x37, 0x00, 0x00, 0x00, 0x39, 0x00, 0x00, 0x00
	.byte 0x39, 0x00, 0x00, 0x00, 0x39, 0x00, 0x00, 0x00
	.byte 0x39, 0x00, 0x00, 0x00, 0x39, 0x00, 0x00, 0x00
	.byte 0x39, 0x00, 0x00, 0x00, 0x39, 0x00, 0x00, 0x00
	.byte 0x39, 0x00, 0x00, 0x00, 0x39, 0x00, 0x00, 0x00
	.byte 0x39, 0x00, 0x00, 0x00, 0x39, 0x00, 0x00, 0x00
	.byte 0x39, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x01
	.byte 0x00, 0x00, 0x60, 0x01, 0x00, 0x00, 0xc0, 0x01
	.byte 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x80, 0x02
	.byte 0x00, 0x00, 0xe0, 0x02, 0x00, 0x00, 0x40, 0x03
	.byte 0x00, 0x00, 0xa0, 0x03, 0x00, 0x00, 0x00, 0x04
	.byte 0x00, 0x00, 0x60, 0x04, 0x00, 0x00, 0xc0, 0x04
	.byte 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x01
	.byte 0x00, 0x00, 0x60, 0x01, 0x00, 0x00, 0xc0, 0x01
	.byte 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x80, 0x02
	.byte 0x00, 0x00, 0xe0, 0x02, 0x00, 0x00, 0x40, 0x03
	.byte 0x00, 0x00, 0xa0, 0x03, 0x00, 0x00, 0x00, 0x04
	.byte 0x00, 0x00, 0x60, 0x04, 0x00, 0x00, 0xc0, 0x04
	.byte 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x01
	.byte 0x00, 0x00, 0x60, 0x01, 0x00, 0x00, 0xc0, 0x01
	.byte 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x80, 0x02
	.byte 0x00, 0x00, 0xe0, 0x02, 0x00, 0x00, 0x40, 0x03
	.byte 0x00, 0x00, 0xa0, 0x03, 0x00, 0x00, 0x00, 0x04
	.byte 0x00, 0x00, 0x60, 0x04, 0x00, 0x00, 0xc0, 0x04
	.byte 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x01
	.byte 0x00, 0x00, 0x60, 0x01, 0x00, 0x00, 0xc0, 0x01
	.byte 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x80, 0x02
	.byte 0x00, 0x00, 0xe0, 0x02, 0x00, 0x00, 0x40, 0x03
	.byte 0x00, 0x00, 0xa0, 0x03, 0x00, 0x00, 0x00, 0x04
	.byte 0x00, 0x00, 0x60, 0x04, 0x00, 0x00, 0xc0, 0x04
	.byte 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x01
	.byte 0x00, 0x00, 0x60, 0x01, 0x00, 0x00, 0xc0, 0x01
	.byte 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x80, 0x02
	.byte 0x00, 0x00, 0xe0, 0x02, 0x00, 0x00, 0x40, 0x03
	.byte 0x00, 0x00, 0xa0, 0x03, 0x00, 0x00, 0x00, 0x04
	.byte 0x00, 0x00, 0x60, 0x04, 0x00, 0x00, 0xc0, 0x04
	.byte 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x01
	.byte 0x00, 0x00, 0x60, 0x01, 0x00, 0x00, 0xc0, 0x01
	.byte 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x80, 0x02
	.byte 0x00, 0x00, 0xe0, 0x02, 0x00, 0x00, 0x40, 0x03
	.byte 0x00, 0x00, 0xa0, 0x03, 0x00, 0x00, 0x00, 0x04
	.byte 0x00, 0x00, 0x60, 0x04, 0x00, 0x00, 0xc0, 0x04
	.byte 0x00, 0x00, 0xa0, 0x00, 0x00, 0x00, 0x00, 0x01
	.byte 0x00, 0x00, 0x60, 0x01, 0x00, 0x00, 0xc0, 0x01
	.byte 0x00, 0x00, 0x20, 0x02, 0x00, 0x00, 0x80, 0x02
	.byte 0x00, 0x00, 0xe0, 0x02, 0x00, 0x00, 0x40, 0x03
	.byte 0x00, 0x00, 0xa0, 0x03, 0x00, 0x00, 0x00, 0x04
	.byte 0x00, 0x00, 0x60, 0x04, 0x00, 0x00, 0xc0, 0x04
	.byte 0x00, 0x00, 0xcf, 0xca, 0x8c, 0xdb, 0xcc, 0x07
	.byte	0x00, 0xdb, 0xec, 0x02, 0x44, 0x57, 0xb8, 0xf5
	.byte 0x00, 0x45, 0x00, 0x48, 0x09, 0x00, 0xe3, 0x07
	.byte	0xf0, 0xec, 0x85, 0x44, 0xf3, 0x33, 0x00, 0x00
	.byte 0x31, 0x0d, 0x00, 0x85, 0x11, 0x0e, 0x00, 0x00
AccVoice_IndexedTableLookup_BaseOffsets_Data:
	.byte 0xb0, 0x0b, 0x00, 0x00, 0xd0, 0x0b, 0x00, 0x00
	.byte 0xf0, 0x0b, 0x00, 0x00, 0x10, 0x0c, 0x00, 0x00
	.byte 0x30, 0x0c, 0x00, 0x00, 0xb0, 0x0b, 0x00, 0x00
	.byte 0xb0, 0x0b, 0x00, 0x00, 0xb0, 0x0b, 0x00, 0x00
AccVoice_GetChannelCount:
	push xix
	cp l, 0x10
	jr c, AccVoice_GetChannelCount_Lookup
	xor l, l

AccVoice_GetChannelCount_Lookup:
	and hl, 0x1f
	ld xix, AccVoice_GetChannelCount_Lookup_Data
	ld	l, (xix+hl)
	pop xix
	ret

AccVoice_ChannelCountTable:
	.byte	0x00, 0x00
AccVoice_GetChannelCount_Lookup_Data:	.byte	0x0f, 0x0c, 0x10, 0x09, 0x12, 0x0d
	.byte 0x0c, 0x0e, 0x0c, 0x12, 0x0b, 0x0b, 0x0c, 0x0d
	.byte 0x13, 0x0b

AccVoice_CopyFromROM:
	push xwa
	push xbc
	push xhl
	push xiy
	cp l, 0x10
	jr c, AccVoice_CopyFromROM_Do
	xor l, l

AccVoice_CopyFromROM_Do:
	ld a, l

	xor w, w

	muls wa, 0x10

	; add xwa, AccVoice_RomRecords16 (v7 patched)
	add	xwa, AccVoice_RomRecords16
	ld xiy, xwa

	ld	xix, 13299

	ldw bc, 0x10

	ldir85

	pop xiy

	pop xhl

	pop xbc

	pop xwa

	ld	xiy, 13299

	ret



AccVoice_CopyFromROM_DataBlock:
	nop
	nop
	pushw	hl
	calr	AccVoice_Dispatch
	popw	hl
	ld	xix, 0:i3
	ldw	bc, 8
	ldirw
	ld	xiy, AccVoice_CopyFromROM_DataBlock_Data
	jr	c, AccVoice_CopyFromROM_Join
	ld	xiy, AccVoice_CopyFromROM_DataBlock_Data_2
AccVoice_CopyFromROM_Join:
	ld	wa, (xiy)
	ld	c, (xiy+2)
	cp	wa, 0xffff
	jr	z, AccVoice_CopyFromROM_Skip2
	cp	wa, hl
	jr	z, AccVoice_CopyFromROM_Skip
	add	iy, 3
	jr	AccVoice_CopyFromROM_Join
AccVoice_CopyFromROM_Skip:
	cp	c, 0:i3
	jr	nz, AccVoice_CopyFromROM_Skip3
	ld	(P0:8), 0:io
	ld	(1:8), 1:io
	jr	AccVoice_CopyFromROM_Skip2
AccVoice_CopyFromROM_Skip3:
	ld	(P2FC:8), 0:io
	ld	(P3:8), 1:io
AccVoice_CopyFromROM_Skip2:
	ld	xiy, 0:i3
	ret
; AccVoice_CopyFromROM_DataBlock +0x46.. -- two key/value tables searched by
; the routine above (AccVoice_CopyFromROM_DataBlock):
;     ld xiy, AccVoice_CopyFromROM_DataBlock_Data  (or _0x6D, chosen by carry)
;  l: ld wa,(xiy) / ld c,(xiy+2) / cp wa,0xffff / jr z,<none> / cp wa,hl /
;     jr z,<found> / add iy,3 / jr l
; so each record is {LE16 key, u8 value}, the key compared with HL and the
; value (C) tested for zero on a match; a key of 0xFFFF ends a table.
; ** RE-TYPED 2026-09-25 (lane accomp): was nop/`pop sr`/max/`push sr`
; mnemonics (data-as-code).  Each table ends with two key-0xFFFF records
; (the reader stops at the first); the second table then starts at +0x6D,
; exactly the reader's other base.
; readers in v7 (address from the linked ELF): AccVoice_CopyFromROM_DataBlock 0xF5C0C3
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; +0x44  2 B between the routine's `ret` and the first table
	.byte 0x00, 0x00
; +0x46  table 0: 13 records {LE16 key, u8 value} ending in key-0xFFFF records
AccVoice_CopyFromROM_DataBlock_Data:
	.byte 0x03, 0x02, 0x00	; key 0x0203 -> 0
	.byte 0x04, 0x03, 0x00	; key 0x0304 -> 0
	.byte 0x04, 0x04, 0x00	; key 0x0404 -> 0
	.byte 0x05, 0x02, 0x00	; key 0x0205 -> 0
	.byte 0x06, 0x04, 0x00	; key 0x0406 -> 0
	.byte 0x06, 0x06, 0x01	; key 0x0606 -> 1
	.byte 0x0b, 0x03, 0x00	; key 0x030b -> 0
	.byte 0x0b, 0x04, 0x00	; key 0x040b -> 0
	.byte 0x0d, 0x02, 0x00	; key 0x020d -> 0
	.byte 0x0d, 0x07, 0x01	; key 0x070d -> 1
	.byte 0x0e, 0x01, 0x00	; key 0x010e -> 0
	.byte 0xff, 0xff, 0x00	; key 0xffff -> 0
	.byte 0xff, 0xff, 0x00	; key 0xffff -> 0
; +0x6d  table 1: 12 records {LE16 key, u8 value} ending in key-0xFFFF records
AccVoice_CopyFromROM_DataBlock_Data_2:
	.byte 0x03, 0x02, 0x00	; key 0x0203 -> 0
	.byte 0x04, 0x02, 0x00	; key 0x0204 -> 0
	.byte 0x04, 0x06, 0x00	; key 0x0604 -> 0
	.byte 0x05, 0x02, 0x00	; key 0x0205 -> 0
	.byte 0x0b, 0x02, 0x00	; key 0x020b -> 0
	.byte 0x0b, 0x05, 0x01	; key 0x050b -> 1
	.byte 0x0d, 0x02, 0x00	; key 0x020d -> 0
	.byte 0x0e, 0x07, 0x00	; key 0x070e -> 0
	.byte 0x0e, 0x09, 0x01	; key 0x090e -> 1
	.byte 0x0e, 0x0a, 0x01	; key 0x0a0e -> 1
	.byte 0xff, 0xff, 0x00	; key 0xffff -> 0
	.byte 0xff, 0xff, 0x00	; key 0xffff -> 0

; SndArg_TickVector: Slot 0 of the Sound Arranger engine's jump-vector block (`jp AccStyle_Process`;
;   AccStyle_JumpTable's ToggleBit0 / ModeEnter / ModeExit / InlinedBlock_Helper slots follow): Seq_DispatcherTick
;   calls it on every sequencer tick. While a Sound Arranger part is selected ((0x32F2) & 0x1F != 0) AccStyle_Process
;   copies changed accompaniment-part sounds into the current style's 10-byte arrangement record at 0x1E7810 + 10 *
;   index. Basis: callers + body -- 0x32F2 is cleared on entering / leaving mode 17 (MD_SND_ARG) and set from the
;   Sound Arranger grid (AcSndArgGridBoxProc).
SndArg_TickVector:
	jp AccStyle_Process
AccStyle_JumpTable:
	jp	AccStyle_ToggleBit0
	jp	AccStyle_ModeEnter
	jp	AccStyle_ModeExit
	jp	AccStyle_InlinedBlock_Helper

AccStyle_InitVRAM_Wrap:
	push xiz
	call AccStyle_InitVRAM
	pop xiz
	ret

AccStyle_JumpTable2:
	jp	AccStyle_IndexedLookup
	jp	AccStyle_SC0ByteSelect
	jp	AccStyle_SC0ByteSelect_Join
	jp	AccStyle_SC0ByteSelect_Join2
	jp	AccStyle_SC0ByteSelect_Join3
	jp	AccStyle_SC0ByteSelect_Join4
	ret
	nop
	nop
	nop
	ret
	nop
	nop
	nop
	ret
	nop
	nop
	nop
	ret
	nop
	nop
	nop
	ret
	nop
	nop
	nop

AccStyle_Process:
	ld	a, (SNDARG_PART_SELECT:16)
	and	a, 31
	jr	z, AccStyle_Process_SaveState
	ld	a, (13015:16)
	and	a, 31
	jr	nz, AccStyle_Process_DoChain
	calr	AccVoiceState_Snapshot
AccStyle_Process_DoChain:
	calr AccHelper_ComputeVoiceOffset
	ld xiy, xhl
	add xiy, 0x1e7810
	calr SndArg_StoreDrumSound
	calr SndArg_StoreBassSound
	calr SndArg_StoreAccomp1Sound
	calr SndArg_StoreAccomp2Sound
	calr SndArg_StoreAccomp3Sound

AccStyle_Process_SaveState:
	ld	a, (SNDARG_PART_SELECT:16)
	ld	(13015:16), a
	ret
AccStyle_ToggleBit0:
	cp (CURRENT_MODE:16), 0x11
	jr nz, .Lc_f5c1dc
	jr t, AccStyle_ToggleBit0_Ret
AccStyle_ToggleBit0_CheckC07D:
.Lc_f5c1dc:
	cp (SWBTWR_PAYLOAD_1:16), 0x06
	jr nz, AccStyle_ToggleBit0_Ret
	ld a, (SWBTWR_PAYLOAD_2:16)
	and	a, (SWBTWR_PAYLOAD_3:16)
	bit	0, a
	jr	z, AccStyle_ToggleBit0_Ret
	xor	(0x32d9:16), 1
	bit	0, (0x32d9:16)
	jr	nz, AccStyle_ToggleBit0_CallOn
	call	AccTuning_LEDOff
	jr	AccStyle_ToggleBit0_Ret
AccStyle_ToggleBit0_CallOn:
	call AccTuning_LEDOn
AccStyle_ToggleBit0_Ret:
	ret
AccStyle_IndexedLookup:
	cp (CURRENT_MODE:16), 0x11
	jr nz, AccStyle_IndexedLookup_Ret
	cp (SWBTWR_PAYLOAD_1:16), 0x10
	jr nz, AccStyle_IndexedLookup_Ret
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr z, AccStyle_IndexedLookup_Ret
	ld	l, (SNDARG_PART_SELECT:16)
	and L,0x1f
	extz HL
	ld XWA,AccStyle_IndexedLookup_Data
	ld	a, (xwa+hl)
	cp	(PART_SELECT:16), a
	jr	z, AccStyle_IndexedLookup_Ret
	ld	(PART_SELECT:16), a
	ld	e, 144:opc
	ld	d, 16:opc
	ld	w, 255:opc
	call	SwbtWr_QueuePostEvent
AccStyle_IndexedLookup_Ret:
	ret


AccStyle_ModeEnter_Wrap:
	push xiz
	calr AccStyle_ModeEnter
	pop xiz
	ret

AccStyle_ModeEnter:
	cp (PREVIOUS_MODE:16), 0x11
	jr z, AccStyle_ModeEnter_Ret
	ld	(SNDARG_PART_SELECT:16), 0x00
	ld	(0x32d7:16), 0x00
	ld	(0x32e7:16), 0x00
	and	(0x3319:16), 0xfe
	cpw (SEQ_TRACK_MASK:16), 0x0000
	jr z, .Lc_f5c281
	call SeqAcc_SetIndicator_PB
	ldw (SEQ_TRACK_MASK:16), 0x0000
	call Audio_CheckSubsystemReady
	or	(0x3319:16), 0x01
AccStyle_ModeEnter_SetFlags:
.Lc_f5c281:
	or	(0x3415:16), 0x08
	or	(0x331b:16), 0x01

	ld a, 0x4b:opc

	call	CtrlPanel_SetIndicatorBit



AccStyle_ModeEnter_Ret:
	ret

AccStyle_ModeExit_Wrap:
	push xiz
	calr AccStyle_ModeExit
	pop xiz
	ret

AccStyle_ModeExit:
	cp (CURRENT_MODE:16), 0x11
	jr z, AccStyle_ModeExit_Ret
	ld	(SNDARG_PART_SELECT:16), 0x00
	ld	(0x32d7:16), 0x00
	ld	(0x32e7:16), 0x00
	and	(0x3415:16), 0xf7
	bit	0, (0x3319:16)
	jr z, .Lc_f5c2c6
	and	(0x3319:16), 0xfe
	call AccWrap_PlayModeDispatch
	call SeqAcc_RestorePlaybackState
AccStyle_ModeExit_ClearFlags:
.Lc_f5c2c6:
	and	(0x331b:16), 0xfc
	call PartSelect_UpdateDisplayState



AccStyle_ModeExit_Ret:
	ret

AccStyle_InlinedBlock:
	push	xiz
	calr	AccStyle_InlinedBlock_Helper
	pop	xiz
	ret
AccStyle_InlinedBlock_Helper:
	cp	(PREVIOUS_TITLE:16), 220
	jrl	z, AccStyle_InlinedBlock_Skip3
	cp	(PANEL_STYLE:16), 128
	jr	c, AccStyle_InlinedBlock_Skip2
	ld	(0x32e7:16), 1
	ld	a, 8:opc
	call	MIDI_SendSysExCmd
	ld	(GLOBAL_ERROR_CODE:16), 54
	call	DrumVoice_NotifyEE
	jrl	AccStyle_InlinedBlock_Return
AccStyle_InlinedBlock_Skip2:
	ld	(SNDARG_PART_SELECT:16), 32
	call	AccHelper_ComputeVoiceOffset
	add	xhl, 0x1e7810
	or	(xhl+1), 128
	calr	AccVoiceState_Snapshot
	call	AccTuning_LoadFromROM
	ld	e, (0x318e:16)
	ld	d, (0x318f:16)
	ld	xhl, 0x315c
	ld	(xhl), e
	ld	(xhl+1), d
	ld	e, (0x3195:16)
	ld	d, (0x3196:16)
	ld	a, (0x3197:16)
	ld	(0x3377:16), a
	ld	a, (0x3198:16)
	ld	(0x3378:16), a
	ld	a, (0x3199:16)
	ld	(0x3379:16), a
	ld	a, (0x319a:16)
	ld	(ACC_CH_TURNOVER:16), a
	ld	a, (0x319b:16)
	ld	(ACC_CH_CEILING:16), a
	call	Rhythm_PackVelocityHighBit
	ld	xhl, 0x3161
	call	AccVoiceReg_StoreParamRecord
	ld	e, (0x319c:16)
	ld	d, (0x319d:16)
	ld	a, (0x319e:16)
	ld	(0x3377:16), a
	ld	a, (0x319f:16)
	ld	(0x3378:16), a
	ld	a, (0x31a0:16)
	ld	(0x3379:16), a
	ld	a, (0x31a1:16)
	ld	(ACC_CH_TURNOVER:16), a
	ld	a, (0x31a2:16)
	ld	(ACC_CH_CEILING:16), a
	call	Rhythm_PackVelocityHighBit
	ld	xhl, 0x3166
	call	AccVoiceReg_StoreParamRecord
	ld	e, (0x31a3:16)
	ld	d, (0x31a4:16)
	ld	a, (0x31a5:16)
	ld	(0x3377:16), a
	ld	a, (0x31a6:16)
	ld	(0x3378:16), a
	ld	a, (0x31a7:16)
	ld	(0x3379:16), a
	ld	a, (0x31a8:16)
	ld	(ACC_CH_TURNOVER:16), a
	ld	a, (0x31a9:16)
	ld	(ACC_CH_CEILING:16), a
	call	Rhythm_PackVelocityHighBit
	ld	xhl, 0x316b
	call	AccVoiceReg_StoreParamRecord
	ld	e, (0x31aa:16)
	ld	d, (0x31ab:16)
	ld	a, (0x31ac:16)
	ld	(0x3377:16), a
	ld	a, (0x31ad:16)
	ld	(0x3378:16), a
	ld	a, (0x31ae:16)
	ld	(0x3379:16), a
	ld	a, (0x31af:16)
	ld	(ACC_CH_TURNOVER:16), a
	ld	a, (0x31b0:16)
	ld	(ACC_CH_CEILING:16), a
	call	Rhythm_PackVelocityHighBit
	ld	xhl, 0x3170
	call	AccVoiceReg_StoreParamRecord
	calr	AccVoiceReg_WritePart1
	calr	AccVoiceReg_WritePart2
	calr	AccVoiceReg_WritePart3
	calr	AccVoiceReg_WritePart4
	calr	AccVoiceReg_WritePart5
	ld	(SNDARG_PART_SELECT:16), 1
	ld	a, 20:opc
	ld	(PART_SELECT:16), a
	ld	e, 144:opc
	ld	d, 16:opc
	ld	w, 255:opc
	call	SwbtWr_QueuePostEvent
AccStyle_InlinedBlock_Skip3:
	cp	(0x32e7:16), 1
	jr	nz, AccStyle_InlinedBlock_Skip
	xor	wa, wa
	ld	a, MD_NORMAL:opc
	call	UI_ChangeModeByIndex
	jr	AccStyle_InlinedBlock_Return
AccStyle_InlinedBlock_Skip:
	ld	a, (SNDARG_PART_SELECT:16)
	and	a, 31
	jr	z, AccStyle_InlinedBlock_Helper_Skip
	and	(0x331b:16), 253
	or	(0x32d9:16), 1
	call	AccTuning_LEDOn
	jr	AccStyle_InlinedBlock_Return
AccStyle_InlinedBlock_Helper_Skip:
	or	(0x331b:16), 2
AccStyle_InlinedBlock_Return:
	ret
; AccStyle_InlinedBlock +0x1A0..+0x1FF -- two u8 tables; the 0x1A0 bytes above
; them are the block's code, still spelled as .byte in v7 (they were one
; island with these tables, which the re-framer refuses as a whole).
; ** RE-TYPED 2026-09-25 (lane accomp), as in v9/v10, where the readers are
; cited: AccStyle_IndexedLookup and AccVoiceState_DispatchChange read the
; +0x1E0 table with the one-hot index (0x338e) & 0x1f.
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; +0x1A0  64 x u8 -- nonzero only at indices 2, 4, 8, 16, 32 (-> 1, 0x10, 8, 4, 2).
;          No reader found: no instruction holds this address (3-byte search
;          over the ROM), and no positional label names it.
	.byte	0x00, 0x00, 0x01, 0x00, 0x10, 0x00, 0x00, 0x00
	.byte	0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
; +0x1E0  32 x u8 -- AccStyle_IndexedLookup_Data: one-hot index -> part code;
;          1 -> 0x14, 2 -> 0x13, 4 -> 0x10, 8 -> 0x11, 16 -> 0x12, else 0
AccStyle_IndexedLookup_Data:
	.byte	0x00, 0x14, 0x13, 0x00, 0x10, 0x00, 0x00, 0x00
	.byte	0x11, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x12, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
AccVoiceReg_WritePart3:
	cp (CURRENT_MODE:16), 0x11
	jr nz, AccVoiceReg_WritePart3_Ret
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, AccVoiceReg_WritePart3_Ret
	ld	a, (0x3166:16)
	ld	w, (0x3167:16)
	bit 0x04,W
	jr z, AccVoiceReg_WritePart3_StoreBit4
	or A,0x80
	and W,0xef
AccVoiceReg_WritePart3_StoreBit4:
	ld (PANEL_PART_ACP1:16), a

	and w, 0x7f

	and (PANEL_PART_ACP1+1:16), 128

	or (PANEL_PART_ACP1+1:16), w

	ld	a, (12649:16)

	sla a, 6

	and a, 0x40

	and (PANEL_PART_ACP1+4:16), 191

	or (PANEL_PART_ACP1+4:16), a

	ld l, 0x4:opc

	; calr AccVoiceState_DispatchChange (v7 displacement)
	calr	AccVoiceState_DispatchChange
AccVoiceReg_WritePart3_Ret:
	ret

AccVoiceReg_WritePart4:
	cp (CURRENT_MODE:16), 0x11
	jr nz, AccVoiceReg_WritePart4_Ret
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, AccVoiceReg_WritePart4_Ret
	ld	a, (0x316b:16)
	ld	w, (0x316c:16)
	bit 0x04,W
	jr z, AccVoiceReg_WritePart4_StoreBit4
	or A,0x80
	and W,0xef
AccVoiceReg_WritePart4_StoreBit4:
	ld (PANEL_PART_ACP2:16), a

	and w, 0x7f

	and (PANEL_PART_ACP2+1:16), 128

	or (PANEL_PART_ACP2+1:16), w

	ld	a, (12654:16)

	sla a, 6

	and a, 0x40

	and (PANEL_PART_ACP2+4:16), 191

	or (PANEL_PART_ACP2+4:16), a

	ld l, 0x8:opc

	; calr AccVoiceState_DispatchChange (v7 displacement)
	calr	AccVoiceState_DispatchChange
AccVoiceReg_WritePart4_Ret:
	ret

AccVoiceReg_WritePart5:
	cp (CURRENT_MODE:16), 0x11
	jr nz, AccVoiceReg_WritePart5_Ret
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, AccVoiceReg_WritePart5_Ret
	ld	a, (0x3170:16)
	ld	w, (0x3171:16)
	bit 0x04,W
	jr z, AccVoiceReg_WritePart5_StoreBit4
	or A,0x80
	and W,0xef
AccVoiceReg_WritePart5_StoreBit4:
	ld (PANEL_PART_ACP3:16), a

	and w, 0x7f

	and (PANEL_PART_ACP3+1:16), 128

	or (PANEL_PART_ACP3+1:16), w

	ld	a, (12659:16)

	sla a, 6

	and a, 0x40

	and (PANEL_PART_ACP3+4:16), 191

	or (PANEL_PART_ACP3+4:16), a

	ld l, 0x10:opc

	; calr AccVoiceState_DispatchChange (v7 displacement)
	calr	AccVoiceState_DispatchChange
AccVoiceReg_WritePart5_Ret:
	ret

AccVoiceReg_WritePart2:
	cp (CURRENT_MODE:16), 0x11
	jr nz, AccVoiceReg_WritePart2_Ret
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, AccVoiceReg_WritePart2_Ret
	ld	a, (0x3161:16)
	ld	w, (0x3162:16)
	bit 0x04,W
	jr z, AccVoiceReg_WritePart2_StoreBit4
	or A,0x80
	and W,0xef
AccVoiceReg_WritePart2_StoreBit4:
	ld (PANEL_PART_BASS:16), a

	and w, 0x7f

	and (PANEL_PART_BASS+1:16), 128

	or (PANEL_PART_BASS+1:16), w

	ld	a, (12644:16)

	sla a, 6

	and a, 0x40

	and (PANEL_PART_BASS+4:16), 191

	or (PANEL_PART_BASS+4:16), a

	ld l, 0x2:opc

	calr	AccVoiceState_DispatchChange



AccVoiceReg_WritePart2_Ret:
	ret

AccVoiceReg_WritePart1:
	cp (CURRENT_MODE:16), 0x11
	jr nz, AccVoiceReg_WritePart1_Ret
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, AccVoiceReg_WritePart1_Ret
	ld	a, (0x315c:16)
	or A,0xf0
	ld	w, (0x315d:16)
	and W,0x7f
	ld (PANEL_PART_DRUM:16), a
	and (PANEL_PART_DRUM+1:16), 0x80
	or (PANEL_PART_DRUM+1:16), w
	ld L, 0x01:opc
	calr AccVoiceState_DispatchChange
AccVoiceReg_WritePart1_Ret:
	ret

AccVoiceState_Snapshot:
	calr AccHelper_ComputeVoiceOffset
	ld XIY,XHL
	add XIY,0x001e7810
	ld a, (PANEL_PART_DRUM:16)
	ld w, (PANEL_PART_DRUM+1:16)
	and W,0x7f
	ld	(SNDARG_LAST_SOUNDS:16), wa
	and A,0x0f
	ld	(xiy+0:8), a
	and	(xiy+1), 128
	or	(xiy+1), w
	ld	a, (PANEL_PART_BASS:16)
	ld	w, (PANEL_PART_BASS+1:16)
	and	w, 127
	ld	l, (PANEL_PART_BASS+4:16)
	and	l, 64
	sla	l, 1
	or	w, l
	ld	(0x32df:16), wa
	ld	(xiy+2), a
	and	(xiy+3), 0
	or	(xiy+3), w
	ld	a, (PANEL_PART_ACP1:16)
	ld	w, (PANEL_PART_ACP1+1:16)
	and	w, 127
	ld	l, (PANEL_PART_ACP1+4:16)
	and	l, 64
	sla	l, 1
	or	w, l
	ld	(0x32e1:16), wa
	ld	(xiy+4), a
	and	(xiy+5), 0
	or	(xiy+5), w
	ld	a, (PANEL_PART_ACP2:16)
	ld	w, (PANEL_PART_ACP2+1:16)
	and	w, 127
	ld	l, (PANEL_PART_ACP2+4:16)
	and	l, 64
	sla	l, 1
	or	w, l
	ld	(0x32e3:16), wa
	ld	(xiy+6), a
	and	(xiy+7), 0
	or	(xiy+7), w
	ld	a, (PANEL_PART_ACP3:16)
	ld	w, (PANEL_PART_ACP3+1:16)
	and	w, 127
	ld	l, (PANEL_PART_ACP3+4:16)
	and	l, 64
	sla	l, 1
	or	w, l
	ld	(0x32e5:16), wa
	ld	(xiy+8), a
	and	(xiy+9), 0
	or	(xiy+9), w
	or	(0x32db:16), 1
	ret
AccVoiceState_DispatchChange:
	push XIY
	ld XWA,AccStyle_IndexedLookup_Data
	ld	e, (xwa+l)
	extz HL
	sla hl, 2
	ld XWA,AccVoiceState_DispatchChange_Data
	ld	xwa, (xwa+hl)
	ld XIY,AccVoiceState_PartLookupTable
	ld	xiy, (xiy+hl)
	ld	(PROGRAM_CHANGE_PART:16), e
	ld8_src_rid8 xiy, 0x00, l
	and L,0xff
	ld H,(XIY+0x01)
	and H,0x7f
	pushw de
	push XWA
	push XIY
	call PartCtrl_WriteProgramChange
	pop XIY
	pop XWA
	popw de
	.byte 0xf3, 0x03, 0xe0, 0xec, 0x46, 0x8d, 0x01, 0x21
	.byte 0xc9, 0xcc, 0x7f, 0x20, 0x7f, 0x24, 0x01, 0x28
	.byte	0x2a, 0x3b, 0x1d, 0x89, 0xa7, 0xfd, 0x5b, 0x4a
	.byte 0x48, 0x8d, 0x00, 0x21, 0xc9, 0xcc, 0xff, 0x20
	.byte	0xff, 0x24, 0x00, 0x28, 0x2a, 0x3b, 0x1d, 0x89
	.byte	0xa7, 0xfd, 0x5b, 0x4a, 0x48, 0x5d, 0x0e
AccVoiceState_PartLookupTable:
	.byte 0x00, 0x00, 0x00, 0x00, 0xbe, 0xfb, 0x00, 0x00
	.byte 0xa4, 0xfb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x56, 0xfb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 8
	.byte 0x70, 0xfb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 24
	.byte 0x8a, 0xfb, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 56
AccVoiceState_DispatchChange_Data:
	.byte 0x00, 0x00, 0x00, 0x00, 0x6a, 0xff, 0x00, 0x00
	.byte 0x56, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x1a, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 8
	.byte 0x2e, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 24
	.byte 0x42, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.zero 56

; SndArg_StoreDrumSound: Sound Arranger: compares the DRUM part's sound (part record 20 at RAM 0xFBBE: program, bank &
;   0x7F) with its last value (word 0x32F9); when it changed, writes it into the current style's arrangement record at
;   XIY -- +0 = program & 0x0F, +1 = bank (bit 7 kept) -- and sets 0x32F7 bit 0; then saves the new value. Basis:
;   callers + body -- AccStyle_Process (the per-tick Sound Arranger step) calls the five AccVoiceDelta_PartN with XIY
;   = 0x1E7810 + 10 * index; one-hot selector 1 = part 0x14, the DRUM entry of the part-name table.
SndArg_StoreDrumSound:
	ld a, (PANEL_PART_DRUM:16)
	ld w, (PANEL_PART_DRUM+1:16)
	and W,0x7f
	cp	(SNDARG_LAST_SOUNDS:16), wa
	jr	z, AccVoiceDelta_Part1_Store
	and	a, 15
	ld	(xiy+0:8), a
	and	(xiy+1), 128
	or	(xiy+1), w
	or	a, 240
	or	(0x32db:16), 1
AccVoiceDelta_Part1_Store:
	ld	(SNDARG_LAST_SOUNDS:16), wa
	ret
; SndArg_StoreBassSound: Sound Arranger: compares the BASS part's sound (part record 19 at RAM 0xFBA4: program, bank &
;   0x7F with bit 6 of record +4 as bit 7) with its last value (word 0x32FB); when it changed, writes program / bank
;   into +2 / +3 of the current style's arrangement record at XIY and sets 0x32F7 bit 0; then saves the new value.
;   Basis: callers + body -- second of AccStyle_Process's five per-part steps; selector code 2 = part 0x13, the BASS
;   entry of the part-name table.
SndArg_StoreBassSound:
	ld a, (PANEL_PART_BASS:16)
	ld w, (PANEL_PART_BASS+1:16)
	and W,0x7f
	ld l, (PANEL_PART_BASS+4:16)
	and L,0x40
	sla L, 0x01
	or W,L
	cp	(0x32df:16), wa
	jr	z, AccVoiceDelta_Part2_Store
	ld	(xiy+2), a
	and	(xiy+3), 0
	or	(xiy+3), w
	or	(0x32db:16), 1
AccVoiceDelta_Part2_Store:
	ld	(13023:16), wa
	ret
; SndArg_StoreAccomp1Sound: Sound Arranger: compares the ACCOMP1 part's sound (part record 16 at RAM 0xFB56: program,
;   bank & 0x7F with bit 6 of record +4 as bit 7) with its last value (word 0x32FD); when it changed, writes program /
;   bank into +4 / +5 of the current style's arrangement record at XIY and sets 0x32F7 bit 0; then saves the new
;   value. Basis: callers + body -- third of AccStyle_Process's five per-part steps; selector code 4 = part 0x10, the
;   ACCOMP1 entry of the part-name table.
SndArg_StoreAccomp1Sound:
	ld a, (PANEL_PART_ACP1:16)
	ld w, (PANEL_PART_ACP1+1:16)
	and W,0x7f
	ld l, (PANEL_PART_ACP1+4:16)
	and L,0x40
	sla L, 0x01
	or W,L
	cp	(0x32e1:16), wa
	jr	z, AccVoiceDelta_Part3_Store
	ld	(xiy+4), a
	and	(xiy+5), 0
	or	(xiy+5), w
	or	(0x32db:16), 1
AccVoiceDelta_Part3_Store:
	ld	(13025:16), wa
	ret
; SndArg_StoreAccomp2Sound: Sound Arranger: compares the ACCOMP2 part's sound (part record 17 at RAM 0xFB70: program,
;   bank & 0x7F with bit 6 of record +4 as bit 7) with its last value (word 0x32FF); when it changed, writes program /
;   bank into +6 / +7 of the current style's arrangement record at XIY and sets 0x32F7 bit 0; then saves the new
;   value. Basis: callers + body -- fourth of AccStyle_Process's five per-part steps; selector code 8 = part 0x11, the
;   ACCOMP2 entry of the part-name table.
SndArg_StoreAccomp2Sound:
	ld a, (PANEL_PART_ACP2:16)
	ld w, (PANEL_PART_ACP2+1:16)
	and W,0x7f
	ld l, (PANEL_PART_ACP2+4:16)
	and L,0x40
	sla L, 0x01
	or W,L
	cp	(0x32e3:16), wa
	jr	z, AccVoiceDelta_Part4_Store
	ld	(xiy+6), a
	and	(xiy+7), 0
	or	(xiy+7), w
	or	(0x32db:16), 1
AccVoiceDelta_Part4_Store:
	ld	(13027:16), wa
	ret
; SndArg_StoreAccomp3Sound: Sound Arranger: compares the ACCOMP3 part's sound (part record 18 at RAM 0xFB8A: program,
;   bank & 0x7F with bit 6 of record +4 as bit 7) with its last value (word 0x3301); when it changed, writes program /
;   bank into +8 / +9 of the current style's arrangement record at XIY and sets 0x32F7 bit 0; then saves the new
;   value. Basis: callers + body -- last of AccStyle_Process's five per-part steps; selector code 16 = part 0x12, the
;   ACCOMP3 entry of the part-name table.
SndArg_StoreAccomp3Sound:
	ld a, (PANEL_PART_ACP3:16)
	ld w, (PANEL_PART_ACP3+1:16)
	and W,0x7f
	ld l, (PANEL_PART_ACP3+4:16)
	and L,0x40
	sla L, 0x01
	or W,L
	cp	(0x32e5:16), wa
	jr	z, AccVoiceDelta_Part5_Store
	ld	(xiy+8), a
	and	(xiy+9), 0
	or	(xiy+9), w
	or	(0x32db:16), 1
AccVoiceDelta_Part5_Store:
	ld	(13029:16), wa
	ret
AccStyle_InitVRAM:
	xor a, a
	ld xiy, AccStyle_RamImage_1E7800
	ld xix, 0x1e7800
	ldw bc, 0x7e0
	ldir85
	ret

AccStyle_SC0ByteSelect:
	ld	(0xe2f6:16), 0x10
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, .Lc_f5c973
	ld	(0xe2f4:16), 0x10
.Lc_f5c973:
	ld	(SNDARG_PART_SELECT:16), 0x01
	ret
AccStyle_SC0ByteSelect_Join:
	ld	(0xe2f6:16), 0x10
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, .Lc_f5c98c
	ld	(0xe2f4:16), 0x10
.Lc_f5c98c:
	ld	(SNDARG_PART_SELECT:16), 0x10
	ret
AccStyle_SC0ByteSelect_Join2:
	ld	(0xe2f6:16), 0x10
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, .Lc_f5c9a5
	ld	(0xe2f4:16), 0x10
.Lc_f5c9a5:
	ld	(SNDARG_PART_SELECT:16), 0x08
	ret
AccStyle_SC0ByteSelect_Join3:
	ld	(0xe2f6:16), 0x10
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, .Lc_f5c9be
	ld	(0xe2f4:16), 0x10
.Lc_f5c9be:
	ld	(SNDARG_PART_SELECT:16), 0x04
	ret
AccStyle_SC0ByteSelect_Join4:
	ld	(0xe2f6:16), 0x10
	ld	a, (SNDARG_PART_SELECT:16)
	and A,0x1f
	jr nz, .Lc_f5c9d7
	ld	(0xe2f4:16), 0x10
.Lc_f5c9d7:
	ld	(SNDARG_PART_SELECT:16), 0x02
	ret
AccHelper_ComputeVoiceOffset:
	xor	xwa, xwa
	ld	l, (PANEL_STYLE:16)
	ld	h, (PANEL_STYLE+1:16)
	and	h, 7
	ld	(PROGRAM_CHANGE_PART:16), 72
	call	PartCtrl_WriteProgramChange
	xor	xwa, xwa
	xor	xwa, xwa
	ld	a, h
	ld	h, l
	xor	l, l
AccHelper_VoiceOffset_Loop:
	cp h, l
	jr z, AccHelper_VoiceOffset_Done
	pushw hl
	push xwa
	call AccVoice_GetChannelCount_Direct
	pop xwa
	inc 1, l
	add a, l
	popw hl
	inc 1, l
	jr AccHelper_VoiceOffset_Loop

AccHelper_VoiceOffset_Done:
	ld xhl, xwa
	sla xwa, 3
	sla xhl, 1
	add xhl, xwa
	ret

AccDemo_Init_Wrap:
	calr AccDemo_Init
	ret

AccDemo_Init:
	xor XBC,XBC
	calr AccDemo_LoadRhythm
	calr AccDemo_LoadVariation
	calr AccDemo_LoadFillIn
	calr AccDemo_LoadVariationData
	calr Demo_LoadVariationC_Data
	ldw	(STYLE_FREE_BLOCKS:16), 0x00be
	and	(0x323b:16), 0xfe
	bit	7, (0x3419:16)
	jr nz, .Lc_f5ca46
	call AccWidget_DispatchTable
AccDemo_Init_ConfigTimers:
.Lc_f5ca46:
	and	(0x3419:16), 0x7f
	ld	(CSTMCP_FROM_SLOT:16), 0x00
	ld	(CSTMCP_TO_SLOT:16), 0x0a

	ret



AccDemo_Init_DataBlock:
	nop
	nop
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(xix+2976), 0
	ld	(xix+2977), 1
	ld	(xix+2978), 2
	ld	(xix+2979), 3
	ret

AccDemo_LoadRhythm:
	ld xiy, Demo_StyleRhythmData
	ld xix, RHYTHM_PATTERN_BUF_A
	add xix, 0x0
	ldw bc, 0x60
	ldir85
	ret

AccDemo_LoadVariation:
	ld a, 0x0:opc
	ld xix, RHYTHM_PATTERN_BUF_A
	add xix, 0x60
	ld hl, 0:i3

AccDemo_LoadVariation_EntryLoop:
	ld (xix), hl
	inc 2, xix
	ldw (xix), 0x0
	inc 2, xix
	inc 1, hl
	ld (xix), hl
	inc 2, xix
	inc 1, hl
	ld (xix), hl
	inc 2, xix
	inc 1, hl
	ld (xix), hl
	inc 2, xix
	inc 1, hl
	ld (xix), hl
	inc 1, hl
	inc 2, xix
	ld xiy, AccDemo_LoadVariation_EntryLoop_Data_2
	ldw bc, 0x34
	ldir85
	ld xiy, AccDemo_LoadVariation_EntryLoop_Data
	xor xde, xde
	ld e, a
	mul e, 0x10
	add xiy, xde
	ldw bc, 0x10
	ldir85
	ld xiy, AccDemo_SectionRecordTail
	ldw bc, 0x10
	ldir85
	add a, 0x1
	cp a, 0x1e
	jr lt, AccDemo_LoadVariation_EntryLoop
	ret

AccDemo_LoadVariation_DataBlock:
	ld	xiy, AccDemo_LoadVariation_DataBlock_Data
	ld	xix, RHYTHM_PATTERN_BUF_A
	add	xix, 2976
	ldw	bc, 160
	ldir85
	ret
	ld	xwa, 0:i3
	ld	xix, RHYTHM_PATTERN_BUF_A
	add	xix, 3136
	ld	xde, 0:i3
AccDemo_LoadVariation_Loop:
	ld qde, 6
	ld	de, wa
	ld	(xix), xde
	add	xix, 4
	ld	(xix), xde
	add	xix, 4
	ld	(xix), xde
	add	xix, 4
	ld	(xix), xde
	add	xix, 4
	ld	(xix), xde
	add	xix, 4
	ld	(xix), xde
	add	xix, 4
	ld	(xix), xde
	add	xix, 4
	ld	(xix), xde
	add	xix, 4
	add	wa, 1
	cp	wa, 60
	jr	lt, AccDemo_LoadVariation_Loop
	ret

AccDemo_LoadFillIn:
	ldw bc, 0x40
	ld xix, RHYTHM_PATTERN_BUF_A
	add xix, 0x13c0
	ld xiy, AccDemo_LoadFillIn_Data
	ldir85
	ret

AccDemo_LoadVariationData:
	ld xix, RHYTHM_PATTERN_BUF_A
	add xix, 0x1400
	ld a, 0x1e:opc

Demo_LoadVariationData:
	ld xiy, Demo_LoadVariationData_Data
	ldw bc, 0x100
	ldir85
	ld l, 0x4:opc

Demo_LoadVariationData_Inner:
	ld xiy, Demo_LoadVariationData_Inner_Data
	ldw bc, 0x100
	ldir85
	dec 1, l
	cp l, 0:i3
	jr gt, Demo_LoadVariationData_Inner
	dec 1, a
	cp a, 0:i3
	jr nz, Demo_LoadVariationData
	ret

Demo_LoadVariationC_Data:
	ld xix, RHYTHM_PATTERN_BUF_A
	add xix, 0xaa00
	ld a, 0xbe:opc

Demo_LoadVariationC_Loop:
	ld xiy, Demo_LoadVariationData_Inner_Data_2
	ldw bc, 0x100
	ldir85
	dec 1, a
	cp a, 0:i3
	jr nz, Demo_LoadVariationC_Loop
	ret

Demo_StyleRhythmData:
; Demo_StyleRhythmData -- the built-in DEMO/DEFAULT STYLE image, 0x674 (1,652) bytes.
; ** RE-TYPED 2026-09-25 (lane accomp): was disassembled as instructions
; (popw/nop/pop xde/push sr/swi 7/`jr f,0`/cpd ... -- 69 data-as-code markers in
; v10 alone).  It is DATA: nothing branches into it, and six copy loops read it
; with fixed offsets and lengths, which pin every segment below:
;   AccDemo_LoadRhythm           +0x000, 0x60 B      -> 0x94800+0x0000
;   AccDemo_LoadVariation        +0x060 + a*16, 16 B -> section record a (a=0..29)
;                                +0x240, 0x34 B      -> every section record
;                                +0x57C, 16 B        -> every section record
;   AccDemo_LoadVariation_DataBlock +0x274, 160 B    -> 0x94800+2976
;   AccDemo_LoadFillIn           +0x334, 0x40 B      -> 0x94800+0x13C0
;   Demo_LoadVariationData       +0x374, 0x100 B x30 and +0x474, 0x100 B x4 x30
;                                                    -> 0x94800+0x1400..
;   Demo_LoadVariationC_Data     +0x574, 0x100 B x190 -> 0x94800+0xAA00
; 0x94800 is also the base AccPatch_InitSlotChain_WithAddr stores to (0x39ae), so
; this is the style image the AccDemo_* loaders build in that RAM area.  The one
; interior offset a reader names by itself, +0x57C, is AccDemo_SectionRecordTail.
; 30 section names: AccDemo_LoadVariation's loop bound is `cp a, 0x1e`, and the
; order (A/B/C variation 1-4, then intro/fill-in/ending 1-2 per variation) is the
; order of the 30 seven-byte section-name cells in AccScreen_UIDataBlock.
; readers in v7 (address from the linked ELF): AccDemo_LoadRhythm 0xF5CA76,
;     AccDemo_LoadVariation 0xF5CA8C, AccDemo_LoadVariation_DataBlock 0xF5CAEF,
;     AccDemo_LoadFillIn 0xF5CB64, Demo_LoadVariationData 0xF5CB87,
;     Demo_LoadVariationC_Data 0xF5CBAA
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; +0x000  0x60 B  -- AccDemo_LoadRhythm copies all 0x60 bytes to 0x94800+0x0000.
	.byte 0x48, 0x00, 0x4b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x5a, 0x5a, 0x5a, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x00, 0x80, 0x16
	.byte 0x60, 0x00, 0x60, 0x00, 0x1e, 0x00, 0x00, 0x01, 0x54, 0x01, 0x40, 0x00, 0x00, 0x00, 0x80, 0x16
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
; +0x060  30 x 16 B  section names, one per accompaniment section in the
;                 order of AccScreen's section-name table (A/B/C variation 1-4,
;                 then intro/fill/ending per variation).  AccDemo_LoadVariation
;                 copies entry a*16 (a = 0..29) into each section record.
AccDemo_LoadVariation_EntryLoop_Data:
	.ascii "a-variation1    "
	.ascii "a-variation2    "
	.ascii "a-variation3    "
	.ascii "a-variation4    "
	.ascii "b-variation1    "
	.ascii "b-variation2    "
	.ascii "b-variation3    "
	.ascii "b-variation4    "
	.ascii "c-variation1    "
	.ascii "c-variation2    "
	.ascii "c-variation3    "
	.ascii "c-variation4    "
	.ascii " a-intro 1      "
	.ascii " a-intro 2      "
	.ascii " a-fill in 1    "
	.ascii " a-fill in 2    "
	.ascii " a-ending 1     "
	.ascii " a-ending 2     "
	.ascii " b-intro 1      "
	.ascii " b-intro 2      "
	.ascii " b-fill in 1    "
	.ascii " b-fill in 2    "
	.ascii " b-ending 1     "
	.ascii " b-ending 2     "
	.ascii " c-intro 1      "
	.ascii " c-intro 2      "
	.ascii " c-fill in 1    "
	.ascii " c-fill in 2    "
	.ascii " c-ending 1     "
	.ascii " c-ending 2     "
; +0x240  0x34 B  per-section record body -- AccDemo_LoadVariation copies these
;                 52 bytes into every one of the 30 section records.
AccDemo_LoadVariation_EntryLoop_Data_2:
	.byte 0x07, 0x03, 0x20, 0x00, 0x58, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x40, 0x00, 0x50, 0x00, 0x7f, 0x00, 0x28, 0x00, 0x40, 0x00, 0x50, 0x06
	.byte 0x7f, 0x00, 0x00, 0x00, 0x40, 0x00, 0x50, 0x06, 0x7f, 0x00, 0x1c, 0x00, 0x40
	.byte 0x00, 0x50, 0x06, 0x7f, 0x00, 0x1d, 0x00, 0x40, 0x00, 0x50, 0x06, 0x7f, 0x00
; +0x274  5 x 32 B  chord-map records -- AccDemo_LoadVariation_DataBlock copies
;                 these 160 bytes to 0x94800+2976.  Each record: index byte (0..4),
;                 three 0xFF, twelve zero bytes, a 16-character name.
AccDemo_LoadVariation_DataBlock_Data:
	.byte 0x00, 0xff, 0xff, 0xff
	.zero 12
	.ascii "chord map 1     "
	.byte 0x01, 0xff, 0xff, 0xff
	.zero 12
	.ascii "chord map 2     "
	.byte 0x02, 0xff, 0xff, 0xff
	.zero 12
	.ascii "chord map 3     "
	.byte 0x03, 0xff, 0xff, 0xff
	.zero 12
	.ascii "chord map 4     "
	.byte 0x04, 0xff, 0xff, 0xff
	.zero 12
	.ascii "chord map 5     "
; +0x314  32 B    eight 4-byte groups 00 00 06 00.  None of the six copy loops
;                 covers these bytes: reader not established.
	.byte 0x00, 0x00, 0x06, 0x00
	.byte 0x00, 0x00, 0x06, 0x00
	.byte 0x00, 0x00, 0x06, 0x00
	.byte 0x00, 0x00, 0x06, 0x00
	.byte 0x00, 0x00, 0x06, 0x00
	.byte 0x00, 0x00, 0x06, 0x00
	.byte 0x00, 0x00, 0x06, 0x00
	.byte 0x00, 0x00, 0x06, 0x00
; +0x334  0x40 B  -- AccDemo_LoadFillIn copies all 64 bytes to 0x94800+0x13C0.
AccDemo_LoadFillIn_Data:
	.byte 0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x83, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x87
; +0x374  0x100 B -- Demo_LoadVariationData copies it once per section (30x),
;                 the first of five 0x100-byte copies per section from 0x94800+0x1400.
Demo_LoadVariationData_Data:
	.byte 0x80, 0xff, 0xff, 0xff, 0xff, 0x87, 0x90, 0x00, 0x43, 0x58, 0x03, 0x00, 0x81, 0x90, 0x00, 0x43
	.byte 0x40, 0x03, 0x00, 0x81, 0x90, 0x00, 0x43, 0x40, 0x03, 0x00, 0x81, 0x90, 0x00, 0x43, 0x40, 0x03
	.byte 0x00, 0x81, 0x90, 0x00, 0x43, 0x58, 0x03, 0x00, 0x81, 0x90, 0x00, 0x43, 0x40, 0x03, 0x00, 0x81
	.byte 0x90, 0x00, 0x43, 0x40, 0x03, 0x00, 0x81, 0x90, 0x00, 0x43, 0x40, 0x03, 0x00, 0x81, 0x90, 0x00
	.byte 0x43, 0x58, 0x03, 0x00, 0x81, 0x90, 0x00, 0x43, 0x40, 0x03, 0x00, 0x81, 0x90, 0x00, 0x43, 0x40
	.byte 0x03, 0x00, 0x81, 0x90, 0x00, 0x43, 0x40, 0x03, 0x00, 0x81, 0x90, 0x00, 0x43, 0x58, 0x03, 0x00
	.byte 0x81, 0x90, 0x00, 0x43, 0x40, 0x03, 0x00, 0x81, 0x90, 0x00, 0x43, 0x40, 0x03, 0x00, 0x81, 0x90
	.byte 0x00, 0x43, 0x40, 0x03, 0x00, 0x81, 0x83
	.zero 136
	.byte 0x87
; +0x474  0x100 B -- Demo_LoadVariationData_Inner copies it 4x after each copy of
;                 the block above (1 + 4 = 5 x 0x100 per section).
Demo_LoadVariationData_Inner_Data:
	.byte 0x80, 0xff, 0xff, 0xff, 0xff, 0x87
	.fill 16, 1, 0x81
	.byte 0x83
	.zero 232
	.byte 0x87
; +0x574  0x100 B -- Demo_LoadVariationC_Loop copies it 0xBE (190) times to
;                 0x94800+0xAA00.  AccDemo_LoadVariation also reads 16 bytes of it
;                 at +0x57C (AccDemo_SectionRecordTail) into every section record.
Demo_LoadVariationData_Inner_Data_2:
	.byte 0x00, 0xff, 0xff, 0xff, 0xff, 0x87
	.zero 2
; the 16 bytes AccDemo_LoadVariation copies into every section record (+0x57C of the image; all zero)
AccDemo_SectionRecordTail:
	.zero 247
	.byte 0x87

AccTone_LookupByProgram:
	sub a, 0xf0
	extz wa
	sla wa, 2
	lda xbc, (AccTone_LookupByProgram_Table_2:24)
	ld	xde, (xbc+wa)
	ld	xwa, xde
	ld	a, (xwa)
	extz wa
	sla wa, 2
	lda xbc, (RhythmTiming_OffsetTable:24)
	ld xde, 0x94860
	add	xde, (xbc+wa)
	ld	xwa, xde
	ld	a, (xwa+12)
	extz wa
	lda xbc, (AccTone_LookupByProgram_Table:24)
	ld	l, (xbc+wa)
	ret

AccTone_ReadAndProcess:
	dec 4, xsp
	ld	a, (PANEL_STYLE:16)
	and	a, 0xff
	ld	(xsp+2), a
	ld	a, (PANEL_STYLE+1:16)
	res	7, a
	ld	(xsp+3), a
	lda xwa, (xsp + 2)
	call AccTone_ValidateAndClamp
	lda xwa, (xsp)
	ld	xde, xwa
	lda	xwa, (xsp+2)
	ld	xbc, xwa
	ld	xwa, xde
	call AccTone_WriteProgramChange
	cp	(xsp+2), 128
	jr nc, AccTone_Process_Under80
	ld	a, (xsp+0:8)
	ld	e, a
	extz	de
	ld	a, (xsp+1)
	ld	c, a
	extz	bc
	ld	wa, de
	calr	AccTone_Process_Cleanup_Loop
	jr	AccTone_Process_Cleanup
AccTone_Process_Under80:
	cp	(xsp+2), 240
	jr	nc, AccTone_Process_Under80_Skip
	ld	a, (xsp+2)
	res	7, a
	ld	c, (xsp+3)
	extz wa
	extz bc
	calr	AccTone_ExtendAndDispatch
	jr AccTone_Process_Cleanup


AccTone_Process_Under80_Skip:
	ld	a, (xsp+2)
; port: v7's label AccTone_Process_UnderF0 is not in v6 -- no v6 bytes correspond to what it named
	sub a, 0xf0
	extz wa
	sla wa, 2
	lda xbc, (AccTone_LookupByProgram_Table_2:24)
	ld	xwa, (xbc+wa)
	ld	a, (xwa)
	extz	wa
	ld bc, 0:i3

AccTone_Process_CalcResult:
	calr AccTone_ExtendAndDispatch

AccTone_Process_Cleanup:
	inc 4, xsp
	ret

; port: v7's label AccTone_NoteLookup is not in v6 -- no v6 bytes correspond to what it named
AccTone_Process_Cleanup_Loop:
	ld	e, a
	extz	de
	ld	wa, (0x1108:16)
	and	wa, 0x4
	cp	wa, 4:i3
	jr	nz, AccTone_NoteLookup_ReadTable_Skip
	ld	l, 0:opc
	ld a, c
	add a, c
	ld c, a
	extz bc

	ld	wa, de
	mul	wa, 40
	ld	de, wa
	add	de, bc
	ld	a, l
	extz	wa
	add	wa, de
AccTone_NoteLookup_ReadTable:
	extz xwa
	ld	xbc, AccTone_NoteLookup_Table
	add	xbc, xwa
	ld	l, (xbc)
	jr AccTone_NoteLookup_Ret

; port: v7's label AccTone_NoteLookup_CheckBit3 is not in v6 -- no v6 bytes correspond to what it named



; port: v7's label AccTone_ExtendAndDispatch_Body is not in v6 -- no v6 bytes correspond to what it named
AccTone_NoteLookup_ReadTable_Skip:
	ld wa, (4360:16)



; port: v7's label AccTone_CheckBit10Flag is not in v6 -- no v6 bytes correspond to what it named

; port: v7's label AccTone_FoundMatch_IncRet is not in v6 -- no v6 bytes correspond to what it named

AccTone_CheckBit3Flag:
	and	wa, 0x400
	cp	wa, 0x400
	jr nz, AccTone_SetupExit
	ld	l, 1:opc
	ld	a, c
	add	a, c
	ld	c, a
	extz	bc
	ld	wa, de
	mul	wa, 40
	ld	de, wa
	add	de, bc
	ld	a, l
	extz	wa
	add	wa, de
	extz	xwa
	ld	xbc, AccTone_NoteLookup_Table
	add	xbc, xwa
	ld	l, (xbc)
	jr	AccTone_NoteLookup_Ret
AccTone_SetupExit:
	ld	wa, (0x1108:16)
	and	wa, 0x8
	cp	wa, 8
	jr	nz, AccTone_SetupExit_Skip
	ld	l, 1:opc
	jr	AccTone_NoteLookup_Ret
AccTone_SetupExit_Skip:
	ld	l, 0:opc
AccTone_NoteLookup_Ret:
	ret
AccTone_ExtendAndDispatch:
	ld	e, c
	extz	de
	sla	de, 2
	lda	xhl, (AccTone_ExtendAndDispatch_Body_Table:24)
	ld	xde, (xhl+de)
	extz	wa
	extz	bc
	jr	AccTone_ExtendAndDispatch_Skip3
AccTone_ExtendAndDispatch_Skip3:
	ld	e, c
	extz	de
	sla	de, 2
	lda	xhl, (AccTone_ExtendAndDispatch_Body_Table_2:24)
	ld	xhl, (xhl+de)
	ld	e, a
	extz	de
	sla	de, 2
	lda	xix, (RhythmTiming_OffsetTable:24)
	ld	xiy, xhl
	add	xiy, (xix+de)
	ld	xix, xiy
	ld	e, (xix+12)
	extz	de
	lda	xix, (AccTone_LookupByProgram_Table:24)
	ld	e, (xix+de)
	extz	bc
	sla	bc, 2
	lda	xix, (AccTone_ExtendAndDispatch_Body_Table:24)
	ld	xbc, (xix+bc)
	extz	wa
	add	wa, 17
	ld	c, (xbc+wa)
	ld	wa, (0x1108:16)
	and	wa, 0x4
	cp	wa, 4:i3
	jr	nz, AccTone_ExtendAndDispatch_Skip4
	ld	a, c
	extz	wa
	lda	xbc, (AccTone_ExtendAndDispatch_Body_Table_3:24)
	ld	a, (xbc+wa)
	extz	wa
	sla	wa, 2
	lda	xbc, (RhythmTiming_OffsetTable:24)
	ld	xiy, xhl
	add	xiy, (xbc+wa)
	ld	xix, xiy
	ld	a, (xix+12)
	extz	wa
	lda	xbc, (AccTone_LookupByProgram_Table:24)
	cp	e, (xbc+wa)
	jr	nz, AccTone_ExtendAndDispatch_Skip5
	ld	l, (xix+13)
	inc	1, l
	jr	AccTone_ExtendAndDispatch_PopRet
AccTone_ExtendAndDispatch_Skip5:
	ld	l, 0:opc
	jr	AccTone_ExtendAndDispatch_PopRet
AccTone_ExtendAndDispatch_Skip4:
	ld	wa, (0x1108:16)
	and	wa, 0x400
	cp	wa, 0x400
	jr	nz, AccTone_ExtendAndDispatch_Skip6
	ld	a, c
	extz	wa
	lda	xbc, (AccTone_ExtendAndDispatch_PopRet_Table:24)
	ld	a, (xbc+wa)
	extz	wa
	sla	wa, 2
	lda	xbc, (RhythmTiming_OffsetTable:24)
	ld	xiy, xhl
	add	xiy, (xbc+wa)
	ld	xix, xiy
	ld	a, (xix+12)
	extz	wa
	lda	xbc, (AccTone_LookupByProgram_Table:24)
	cp	e, (xbc+wa)
	jr	nz, AccTone_ExtendAndDispatch_Skip7
	ld	l, (xix+13)
	inc	1, l
	jr	AccTone_ExtendAndDispatch_PopRet
AccTone_ExtendAndDispatch_Skip7:
	ld	l, 0:opc
	jr	AccTone_ExtendAndDispatch_PopRet
AccTone_ExtendAndDispatch_Skip6:
	ld	wa, (0x1108:16)
	and	wa, 0x8
	cp	wa, 8
	jr	nz, AccTone_ExtendAndDispatch_Skip8
	ld	a, e
	extz wa
	lda xbc, (AccStyle_ApplyExt_SkipClamp_Table:24)
	bit	0, (xbc+wa)
	jr	z, AccTone_ExtendAndDispatch_Skip9
	ld	l, 0x0:opc
	jr AccTone_ExtendAndDispatch_PopRet
AccTone_ExtendAndDispatch_Skip9:
	ld	l, 1:opc
	jr	AccTone_ExtendAndDispatch_PopRet
AccTone_ExtendAndDispatch_Skip8:
	ld	l, 0:opc
AccTone_ExtendAndDispatch_PopRet:
	ret
	dec 4, xsp
	ld de, (4360:16)
	and de, 0x40c
	jrl z, AccTone_LookupFailed
	extz bc
	sla bc, 2
	lda xde, (AccTone_ExtendAndDispatch_Body_Table_2:24)
	ld	xde, (xde+bc)
	extz wa
	sla wa, 2
	lda xbc, (RhythmTiming_OffsetTable:24)
	add	xde, (xbc+wa)
	ld a, (xde + 12)
	extz wa
	lda xbc, (AccTone_LookupByProgram_Table:24)
	ld	a, (xbc+wa)
	extz wa
	lda xbc, (AccStyle_ApplyExt_SkipClamp_Table:24)
	bit	0, (xbc+wa)
	jr	z, AccTone_ExtendAndDispatch_PopRet_Skip
	ld	l, 0:opc
	jrl	AccTone_LookupDone
AccTone_ExtendAndDispatch_PopRet_Skip:
	ld	a, (xde+16)
	ld	(xsp+0:8), a
	ld	a, (xde+17)
	ld	(xsp+1), a
	ld	a, (xsp+0:8)
	ld	c, a
	extz bc
	ld	a, (xsp+1)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x208
	jr	z, AccTone_CheckDirectAddr
	ld	a, (xsp+0:8)
	ld	c, a
	extz	bc
	ld	a, (xsp+1)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x318
	jr nz, AccTone_ValidateAndWrite

AccTone_CheckDirectAddr:
	ld	a, (ACC_REQ_INTRO:16)
	cp	a, 1:i3
	jr	z, AccTone_DirectAddr_Mode2_Skip
	cp	a, 2:i3
	jr	z, AccTone_DirectAddr_Mode2
	cp	a, 4:i3
	jr	nz, AccTone_DirectAddr_Mode2_Skip
AccTone_DirectAddr_Mode1:
	ld l, 0x2:opc
	jr AccTone_LookupDone

AccTone_DirectAddr_Mode2:
	ld l, 0x1:opc
	jr AccTone_LookupDone

AccTone_DirectAddr_Mode2_Skip:
	ld	l, 2:opc
	jr	AccTone_LookupDone
AccTone_ValidateAndWrite:
	lda	xwa, (xsp)
	call AccTone_ValidateAndClamp
	lda xwa, (xsp + 2)
	ld	xde, xwa
	lda	xwa, (xsp)
	ld	xbc, xwa
	ld	xwa, xde
	call AccTone_WriteProgramChange
	ld	a, (xsp+2)
	ld	e, a
	extz	de
	ld	a, (xsp+3)
	ld	c, a
	extz bc
	ld	wa, de
	calr	AccTone_Process_Cleanup_Loop
	jr AccTone_LookupDone

AccTone_LookupFailed:
	ld l, 0x0:opc

AccTone_LookupDone:
	inc 4, xsp
	ret

AccTone_InlineBytecodeData:
	res	0, (0x3367:16)
	cp	(ACC_LANES_COUNTIN:16), 0
	scc	z, wa
	ld	bc, wa
	cp	(ACC_LANES_INTRO1:16), 0
	scc	z, wa
	ld	de, wa
	and	de, bc
	cp	(ACC_LANES_INTRO2:16), 0
	scc	z, wa
	ld	bc, wa
	and	bc, de
	cp	(ACC_LANES_FILLIN1:16), 0
	scc	z, wa
	ld	de, wa
	and	de, bc
	cp	(ACC_LANES_FILLIN2:16), 0
	scc	z, wa
	ld	bc, wa
	and	bc, de
	cp	(ACC_LANES_ENDING1:16), 0
	scc	z, wa
	ld	de, wa
	and	de, bc
	cp	(ACC_LANES_ENDING2:16), 0
	scc	z, wa
	and	wa, de
	ret	z
	cp	(ACC_STYLE_NUMBER:16), 240
	ret	c
	ld	a, (0x31c8:16)
	cp	a, (0x336d:16)
	jr	z, AccTone_ExtendAndDispatch_Skip
	res	0, (0x3366:16)
AccTone_ExtendAndDispatch_Skip:
	bit	0, (0x3366:16)
	ret	nz
	calr	AccTone_ExtendAndDispatch_Helper
	ld	a, (0x3369:16)
	cp	a, (0x3372:16)
	jr	z, AccTone_ExtendAndDispatch_Skip2
	set	0, (0x3367:16)
	set	0, (0x3366:16)
AccTone_ExtendAndDispatch_Skip2:
	ldmm8	13161, 13170
	ldmm8	13160, 13171
	ret
AccTone_ExtendAndDispatch_Helper:
	ld	a, (ACC_CHORD_TYPE:16)
	extz	wa
	lda	xbc, (Chord_TypeFamilyTable:24)
	ld	(0x3373), (xbc+wa)
	ld	xbc, (ACC_STYLE_RECORD:16)
	ld	a, (0x3373:16)
	extz	wa
	ld	(0x3372), (xbc+wa)
	cp	(0x3372:16), 255
	ret	nz
	ld	(13170), (xbc)
	ld	(0x3373:16), 0
	ret
AccSection_ApplyPendingChange:
	bit	0, (0x3367:16)
	ret	z
	call	Rhythm_SendChanPressure_Wrap
	call	AccBuf_ResetAll4_Wrap
	ld	a, (0x3369:16)
	extz	wa
	sla	wa, 2
	lda	xde, (RhythmTiming_OffsetTable:24)
	ld	xbc, 608352
	add	xbc, (xde+wa)
	ld	(0x336e:16), xbc
	ld	xwa, xbc
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 63
	set	7, (ACC_LANES_RESYNC:16)
	calr	AccTone_ExtendAndDispatch_Helper2
	ldmm8	ACC_CHORD_VOICED_TYPE, ACC_CHORD_TYPE
	ldmm8	ACC_CHORD_VOICED_ROOT, ACC_CHORD_ROOT
	ldmm8	ACC_CHORD_VOICED_BASS, ACC_CHORD_BASS
	res	0, (0x3367:16)
	ret
AccTone_ExtendAndDispatch_Helper2:
	calr	AccVoice_BarCounterBytecodeData
	and	(ACC_LANE_BEAT_POS:16), 240
	and	(0x31f4:16), 240
	and	(0x31f5:16), 240
	and	(0x31f6:16), 240
	and	(0x31f7:16), 240
	and	(0x31f8:16), 240
	call	AccSeq_DualPartScan_Wrap
	bit	6, (ACC_PART_FLAGS:16)
	ret	nz
	call	AccSeq_FourChannelScan_Wrap
	ret
AccVoice_GetMeasureStartBlock:
	ld	xix, 0x95440
	extz DE
	sla de, 2
	extz BC
	sla bc, 5
	ld HL,BC
	add HL,DE
	ld W, 0x00:opc
	extz XWA
	ld XBC,XWA
	sll xbc, 2
	add XBC,XWA
	sll xbc, 5
	add	xbc, xix
	ld	hl, (xbc+hl)
	ret
AccVoice_BarCounterBytecodeData_Helper2:
	ld	xix, 0x95440
	extz DE
	sla de, 2
	extz BC
	sla bc, 5
	ld HL,BC
	add HL,DE
	ld W, 0x00:opc
	extz XWA
	ld XBC,XWA
	sll xbc, 2
	add XBC,XWA
	sll xbc, 5
	add	xbc, xix
	lda	xwa, (xbc+hl)
	ld HL,(XWA+0x02)
	ret
AccTone_JumpTableData_Helper:
	dec	2, xsp
	push	xiz
	ld	a, (ACC_STYLE_NUMBER:16)
	sub	a, 240
	extz	wa
	sla	wa, 2
	lda	xbc, (AccTone_LookupByProgram_Table_2:24)
	ld	xwa, (xbc+wa)
	ld	(ACC_STYLE_RECORD:16), xwa
	ld	(0x3339), (xwa)
	ld	a, (0x3339:16)
	extz	wa
	lda	xbc, (AccStyle_ExtStyleMap:24)
	ld	(0x3280), (xbc+wa)
	ld	a, (0x3339:16)
	extz	wa
	ld	bc, wa
	sla	bc, 2
	lda	xde, (RhythmTiming_OffsetTable:24)
	ld	xwa, 0x94860
	add	xwa, (xde+bc)
	ld	(0x333a:16), xwa
	ld	xiz, xwa
	ld	a, (xiz+16)
	ld	(xsp+4), a
	ld	a, (xiz+17)
	ld	(xsp+5), a
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x208
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x318
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip
	lda	xwa, (xsp+4)
	call	AccTone_ValidateAndClamp
AccVoice_BarCounterBytecodeData_Helper2_Skip:
	ld	a, (xsp+4)
	ld	e, a
	extz	de
	ld	a, (xsp+5)
	ld	c, a
	extz	bc
	ld	wa, de
	call	AccTone_LookupByProgram_Dispatch
	ld	xwa, xhl
	call	Rhythm_UpdateTuningConfig_Wrap
	ld	a, (xiz+12)
	extz	wa
	lda	xbc, (AccTone_LookupByProgram_Table:24)
	ld	(ACC_BEATS_PER_BAR), (xbc+wa)
	ld	a, (ACC_BEATS_PER_BAR:16)
	extz	wa
	add	wa, wa
	lda	xbc, (AccVoice_LookupTableAddress_Table:24)
	ldw	(0x31c3), (xbc+wa)
	ld	a, (0x3339:16)
	add	a, 128
	ld	(0x3374:16), a
	extz	wa
	call	AccPatch_SetByChordIndex_Wrap
	calr	AccTone_ExtendAndDispatch_Helper
	ld	(0x3369), (0x3372:16)
	ld	(0x3368), (0x3373:16)
	ld	a, (0x3372:16)
	extz	wa
	sla	wa, 2
	lda	xde, (RhythmTiming_OffsetTable:24)
	ld	xbc, 0x94860
	add	xbc, (xde+wa)
	ld	(0x336e:16), xbc
	ld	xwa, xbc
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	pop	xiz
	inc	2, xsp
	ret
AccTone_JumpTableData_Helper2:
	cp	(ACC_STYLE_NUMBER:16), 240
	ret	c
	calr	AccTone_ExtendAndDispatch_Helper
	ld	a, (0x3372:16)
	cp	a, (0x3369:16)
	ret	z
	set	0, (0x3283:16)
	ret
AccTone_JumpTableData_Helper3:
	dec	2, xsp
	push	xiz
	ld	a, (ACC_STYLE_NUMBER:16)
	sub	a, 240
	extz	wa
	sla	wa, 2
	lda	xbc, (AccTone_LookupByProgram_Table_2:24)
	ld	xwa, (xbc+wa)
	ld	(ACC_STYLE_RECORD:16), xwa
	ld	(0x3339), (xwa)
	ld	a, (0x3339:16)
	extz	wa
	lda	xbc, (AccStyle_ExtStyleMap:24)
	ld	(0x3280), (xbc+wa)
	ld	a, (0x3339:16)
	extz	wa
	ld	bc, wa
	sla	bc, 2
	lda	xde, (RhythmTiming_OffsetTable:24)
	ld	xwa, 0x94860
	add	xwa, (xde+bc)
	ld	(0x333a:16), xwa
	ld	xiz, xwa
	ld	a, (xiz+16)
	ld	(xsp+4), a
	ld	a, (xiz+17)
	ld	(xsp+5), a
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x208
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip2
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x318
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip2
	lda	xwa, (xsp+4)
	call	AccTone_ValidateAndClamp
AccVoice_BarCounterBytecodeData_Helper2_Skip2:
	ld	a, (xsp+4)
	ld	e, a
	extz	de
	ld	a, (xsp+5)
	ld	c, a
	extz	bc
	ld	wa, de
	call	AccTone_LookupByProgram_Dispatch
	ld	xwa, xhl
	call	Rhythm_UpdateTuningConfig_Wrap
	ld	a, (xiz+12)
	extz	wa
	lda	xbc, (AccTone_LookupByProgram_Table:24)
	ld	(ACC_BEATS_PER_BAR), (xbc+wa)
	ld	a, (ACC_BEATS_PER_BAR:16)
	extz	wa
	add	wa, wa
	lda	xbc, (AccVoice_LookupTableAddress_Table:24)
	ldw	(0x31c3), (xbc+wa)
	ld	a, (0x3339:16)
	add	a, 128
	ld	(0x3374:16), a
	extz	wa
	call	AccPatch_SetByChordIndex_Wrap
	calr	AccTone_ExtendAndDispatch_Helper
	ld	(0x3369), (0x3372:16)
	ld	(0x3368), (0x3373:16)
	bit	0, (0x32ab:16)
	call	z, (16113305)
	ld	a, (0x3369:16)
	extz	wa
	ld	bc, wa
	sla	bc, 2
	lda	xde, (RhythmTiming_OffsetTable:24)
	ld	xwa, 0x94860
	add	xwa, (xde+bc)
	ld	(0x336e:16), xwa
	calr	AccVoice_BarCounterBytecodeData_Helper2_Skip3
	pop	xiz
	inc	2, xsp
	ret
AccVoice_BarCounterBytecodeData_Helper2_Skip3:
	ld	a, (ACC_REQ_INTRO:16)
	and	a, 0x7
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip4
	bit	0, (0x32ab:16)
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip5
	ld	a, (ACC_REQ_INTRO:16)
	cp	a, 1:i3
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip6
	cp	a, 4:i3
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip7
	cp	a, 2:i3
	jr	nz, AccVoice_BarCounterBytecodeData_Helper2_Skip6
	ld	a, (ACC_BEATS_PER_BAR:16)
	extz	wa
	lda	xbc, (AccStyle_ApplyExt_SkipClamp_Table:24)
	cp	(xbc+wa), 0x01
	jr	nz, AccVoice_BarCounterBytecodeData_Helper2_Skip5
	calr	AccVoice_BarCounterBytecodeData_Helper3
	calr	AccVoice_BarCounterBytecodeData_Helper2_Skip8
	jr	AccVoice_BarCounterBytecodeData_Helper2_Skip9
AccVoice_BarCounterBytecodeData_Helper2_Skip7:
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32ae:16)
	jr	nz, AccVoice_BarCounterBytecodeData_Helper2_Skip10
	call	AccTone_LookupByProgramWrapped_Join
	jr	AccVoice_BarCounterBytecodeData_Helper2_Skip9
AccVoice_BarCounterBytecodeData_Helper2_Skip10:
	calr	AccVoice_BarCounterBytecodeData_Helper5
	jr	AccVoice_BarCounterBytecodeData_Helper2_Skip8
AccVoice_BarCounterBytecodeData_Helper2_Skip6:
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32ac:16)
	jr	nz, AccVoice_BarCounterBytecodeData_Helper2_Skip11
	call	AccTone_LookupByProgramWrapped_Join
	jr	AccVoice_BarCounterBytecodeData_Helper2_Skip9
AccVoice_BarCounterBytecodeData_Helper2_Skip11:
	calr	AccVoice_BarCounterBytecodeData_Helper4
	jr	AccVoice_BarCounterBytecodeData_Helper2_Skip8
AccVoice_BarCounterBytecodeData_Helper2_Skip4:
	calr	AccVoice_BarCounterBytecodeData_Helper2_Skip8
AccVoice_BarCounterBytecodeData_Helper2_Skip9:
	ret
AccVoice_BarCounterBytecodeData_Helper2_Skip8:
	ld	xwa, (0x336e:16)
	call	AccPart_InitPositionsAndBase_Wrap
	ld	xwa, (0x336e:16)
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	and	(ACC_LANES_INTRO1:16), 0xc0
	and	(ACC_LANES_COUNTIN:16), 0xc0
	and	(ACC_LANES_INTRO2:16), 0xc0
	ret
AccVoice_BarCounterBytecodeData_Helper2_Skip5:
	dec	2, xsp
	pushw	iz
	ld	a, (ACC_REQ_INTRO:16)
	cp	a, 4:i3
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip12
	cp	a, 2:i3
	jr	nz, AccVoice_BarCounterBytecodeData_Helper2_Skip13
	ldw	iz, 34
	jr	AccVoice_BarCounterBytecodeData_Helper2_Skip14
AccVoice_BarCounterBytecodeData_Helper2_Skip12:
	ldw	iz, 0x420
	jr	AccVoice_BarCounterBytecodeData_Helper2_Skip14
AccVoice_BarCounterBytecodeData_Helper2_Skip13:
	ldw	iz, 32
AccVoice_BarCounterBytecodeData_Helper2_Skip14:
	ld	xbc, (0x333a:16)
	ld	a, (xbc+16)
	ld	(xsp+2), a
	ld	a, (xbc+17)
	ld	(xsp+3), a
	ld	a, (xsp+2)
	ld	c, a
	extz	bc
	ld	a, (xsp+3)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x208
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip15
	ld	a, (xsp+2)
	ld	c, a
	extz	bc
	ld	a, (xsp+3)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x318
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip15
	lda	xwa, (xsp+2)
	call	AccTone_ValidateAndClamp
AccVoice_BarCounterBytecodeData_Helper2_Skip15:
	ld	a, (xsp+2)
	ld	e, a
	extz	de
	ld	a, (xsp+3)
	ld	c, a
	extz	bc
	ld	wa, de
	call	AccTone_LookupByProgram_Dispatch
	ld	xwa, xhl
	ld	bc, iz
	call	AccStyle_SetupPartAddressesByHL_Wrap
	ld	xwa, (0x333a:16)
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	ld	a, (ACC_REQ_INTRO:16)
	cp	a, 4:i3
	jr	z, AccVoice_BarCounterBytecodeData_Helper2_Skip16
	cp	a, 2:i3
	jr	nz, AccVoice_BarCounterBytecodeData_Helper2_Skip17
	and	(ACC_LANES_INTRO1:16), 0xc0
	or	(ACC_LANES_COUNTIN:16), 0x3f
	and	(ACC_LANES_INTRO2:16), 0xc0
	jr	AccVoice_BarCounterBytecodeData_Helper2_Skip18
AccVoice_BarCounterBytecodeData_Helper2_Skip16:
	and	(ACC_LANES_INTRO1:16), 0xc0
	and	(ACC_LANES_COUNTIN:16), 0xc0
	or	(ACC_LANES_INTRO2:16), 0x3f
	jr	AccVoice_BarCounterBytecodeData_Helper2_Skip18
AccVoice_BarCounterBytecodeData_Helper2_Skip17:
	or	(ACC_LANES_INTRO1:16), 0x3f
	and	(ACC_LANES_COUNTIN:16), 0xc0
	and	(ACC_LANES_INTRO2:16), 0xc0
AccVoice_BarCounterBytecodeData_Helper2_Skip18:
	popw	iz
	inc	2, xsp
	ret
AccVoice_BarCounterBytecodeData_Helper3:
	res	1, (ACC_REQ_INTRO:16)
	res 3, (PANEL_STYLE+5:16)
	pushw 0x0000
	ldw WA, 0x0048
	ld bc, 5:i3
	ld de, 0:i3
	call AddswbWr
	ret
AccVoice_BarCounterBytecodeData_Helper4:
	res	0, (ACC_REQ_INTRO:16)
	res 2, (PANEL_STYLE+5:16)
	pushw 0x0000
	ldw WA, 0x0048
	ld bc, 5:i3
	ld de, 0:i3
	call AddswbWr
	ret
AccVoice_BarCounterBytecodeData_Helper5:
	res	2, (ACC_REQ_INTRO:16)
	res 2, (PANEL_STYLE+6:16)
	pushw 0x0000
	ldw WA, 0x0048
	ld bc, 6:i3
	ld de, 0:i3
	call AddswbWr
	ret
AccVoice_BarCounterBytecodeData_Helper6:
	res	0, (ACC_REQ_ENDING:16)
	res 4, (PANEL_STYLE+5:16)
	pushw 0x0000
	ldw WA, 0x0048
	ld bc, 5:i3
	ld de, 0:i3
	call AddswbWr
	ret
AccVoice_BarCounterBytecodeData_Helper7:
	res	1, (ACC_REQ_ENDING:16)
	res 5, (PANEL_STYLE+5:16)
	pushw 0x0000
	ldw WA, 0x0048
	ld bc, 5:i3
	ld de, 0:i3
	call AddswbWr
	ret
AccVoice_BarCounterBytecodeData_Helper8:
	res	0, (ACC_REQ_FILLIN:16)
	res 6, (PANEL_STYLE+5:16)
	pushw 0x0000
	ldw WA, 0x0048
	ld bc, 5:i3
	ld de, 0:i3
	call AddswbWr
	ret
AccVoice_BarCounterBytecodeData_Helper9:
	res	1, (ACC_REQ_FILLIN:16)
	res 7, (PANEL_STYLE+5:16)
	pushw 0x0000
	ldw WA, 0x0048
	ld bc, 5:i3
	ld de, 0:i3
	call AddswbWr
	ret
AccTone_ValidateAndClamp_Helper:
	cp	a, 2:i3
	jr	nz, AccTone_ValidateAndClamp_Helper_Skip
	ldw	(ACC_CUR_BLOCK:16), 65534
	jr	AccTone_ValidateAndClamp_Helper_Join
AccTone_ValidateAndClamp_Helper_Skip:
	extz	wa
	lda	xbc, (AccPart_BitToIndexTable:24)
	ld	a, (xbc+wa)
	ld	xbc, (0x336e:16)
	extz	wa
	add	wa, wa
	ldw	(ACC_CUR_BLOCK), (xbc+wa)
AccTone_ValidateAndClamp_Helper_Join:
	ldw	(ACC_CUR_READ_POS:16), 6
	ret
AccTone_ValidateAndClamp_Helper2:
	ld	xde, (0x336e:16)
	ld C,A
	extz BC
	lda	xhl, (AccTone_InlineBytecodeData_Data_2:24)
	ld	l, (xhl+bc)
	ld	c, l
	extz	bc
	muls BC,0x0007
	ld	ix, bc
	lda	xiy, (0x318e:16)
	ld	c, l
	extz	bc
	sla	bc, 3
	add	bc, 24
	ld	c, (xde+bc)
	st_rrb	c, xiy, ix
	ld	c, l
	extz	bc
	muls	bc, 7
	ld	ix, bc
	lda	xiy, (0x318f:16)
	ld	c, l
	extz	bc
	sla	bc, 3
	add	bc, 24
	exts	xbc
	add	xbc, xde
	ld	c, (xbc+1)
	st_rrb	c, xiy, ix
	ld	c, l
	extz	bc
	muls	bc, 7
	ld	ix, bc
	lda	xiy, (0x3190:16)
	ld	c, l
	extz	bc
	sla	bc, 3
	add	bc, 24
	exts	xbc
	add	xbc, xde
	ld	c, (xbc+2)
	st_rrb	c, xiy, ix
	ld	c, l
	extz	bc
	muls	bc, 7
	ld	ix, bc
	lda	xiy, (0x3191:16)
	ld	c, l
	extz	bc
	sla	bc, 3
	add	bc, 24
	exts	xbc
	add	xbc, xde
	ld	c, (xbc+3)
	st_rrb	c, xiy, ix
	ld	c, l
	extz	bc
	muls	bc, 7
	ld	ix, bc
	lda	xiy, (0x3192:16)
	ld	c, l
	extz	bc
	sla	bc, 3
	add	bc, 24
	exts	xbc
	add	xbc, xde
	ld	c, (xbc+4)
	st_rrb	c, xiy, ix
	ld	c, l
	extz	bc
	muls	bc, 7
	ld	ix, bc
	lda	xiy, (0x3193:16)
	ld	c, l
	extz	bc
	sla	bc, 3
	add	bc, 24
	exts	xbc
	add	xbc, xde
	ld	c, (xbc+5)
	st_rrb	c, xiy, ix
	ld	c, l
	extz	bc
	muls	bc, 7
	ld	ix, bc
	lda	xiy, (0x3194:16)
	ld	c, l
	extz	bc
	sla	bc, 3
	add	bc, 24
	exts	xbc
	add	xbc, xde
	ld	c, (xbc+6)
	st_rrb	c, xiy, ix
	or	(ACC_LANES_RESYNC:16), a
	ret
AccVoice_ClearChannelStates:
	ld	(ACC_LANE_MEASURE:16), 0
	ld	(13108:16), 0
	ld	(13109:16), 0
	ld	(13110:16), 0
	ld	(13111:16), 0
	ld	(13112:16), 0
	ret
AccVoice_IncrementBarCounter:
	inc	1, (ACC_CUR_MEASURE:16)
	ld	xbc, (0x336e:16)
	ld	a, (ACC_CUR_MEASURE:16)
	cp	a, (xbc+13)
	ret	ule
	ld	(ACC_CUR_MEASURE:16), 0
	ret
AccVoice_BarCounterBytecodeData:
	ld	(0x3328:16), 0
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (ACC_LANE_MEASURE:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	calr	AccVoice_GetMeasureStartBlock
	ld	(ACC_LANE_BLOCK:16), hl
	cpw	(ACC_LANE_BLOCK:16), 0xfffe
	jr	nz, AccVoice_BarCounterBytecodeData_Skip
	set	0, (0x3328:16)
AccVoice_BarCounterBytecodeData_Skip:
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (ACC_LANE_MEASURE:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 0:i3
	calr	AccVoice_BarCounterBytecodeData_Helper2
	ld	(ACC_LANE_READ_POS:16), hl
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (0x3335:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	calr	AccVoice_GetMeasureStartBlock
	ld	(0x31e3:16), hl
	cpw	(0x31e3:16), 0xfffe
	jr	nz, AccVoice_BarCounterBytecodeData_Skip2
	set	2, (0x3328:16)
AccVoice_BarCounterBytecodeData_Skip2:
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (0x3335:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 1:i3
	calr	AccVoice_BarCounterBytecodeData_Helper2
	ld	(0x31d3:16), hl
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (0x3336:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	calr	AccVoice_GetMeasureStartBlock
	ld	(0x31e5:16), hl
	cpw	(0x31e5:16), 0xfffe
	jr	nz, AccVoice_BarCounterBytecodeData_Skip3
	set	3, (0x3328:16)
AccVoice_BarCounterBytecodeData_Skip3:
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (0x3336:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 2:i3
	calr	AccVoice_BarCounterBytecodeData_Helper2
	ld	(0x31d5:16), hl
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (0x3337:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 3:i3
	calr	AccVoice_GetMeasureStartBlock
	ld	(0x31e7:16), hl
	cpw	(0x31e7:16), 0xfffe
	jr	nz, AccVoice_BarCounterBytecodeData_Skip4
	set	4, (0x3328:16)
AccVoice_BarCounterBytecodeData_Skip4:
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (0x3337:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 3:i3
	calr	AccVoice_BarCounterBytecodeData_Helper2
	ld	(0x31d7:16), hl
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (0x3338:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 4:i3
	calr	AccVoice_GetMeasureStartBlock
	ld	(0x31e9:16), hl
	cpw	(0x31e9:16), 0xfffe
	jr	nz, AccVoice_BarCounterBytecodeData_Skip5
	set	5, (0x3328:16)
AccVoice_BarCounterBytecodeData_Skip5:
	ld	a, (0x3369:16)
	ld	e, a
	extz	de
	ld	a, (0x3338:16)
	ld	c, a
	extz	bc
	ld	wa, de
	ld	de, bc
	ld	bc, 4:i3
	calr	AccVoice_BarCounterBytecodeData_Helper2
	ld	(0x31d9:16), hl
	ldw	(0x31e1:16), 65534
	ldw	(0x31d1:16), 6
	set	1, (0x3328:16)
	ret
AccVoice_IncrementBarWithSave_Helper:
	dec	2, xsp
	push	xiz
	bit	0, (0x32ab:16)
	jrl	z, AccVoice_BarCounterBytecodeData_Skip10
	ld	a, (ACC_PENDING_ENDING:16)
	cp	a, 1:i3
	jr	z, AccVoice_BarCounterBytecodeData_Skip7
	cp	a, 2:i3
	jr	nz, AccVoice_BarCounterBytecodeData_Skip7
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32b6:16)
	jr	nz, AccVoice_BarCounterBytecodeData_Skip6
	ld	a, (0x32b7:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (RhythmTiming_OffsetTable:24)
	ld	xiz, 608352
	add	xiz, (xbc+wa)
	ld	xwa, xiz
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, xiz
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join2_Skip
AccVoice_BarCounterBytecodeData_Skip6:
	calr	AccVoice_BarCounterBytecodeData_Helper7
	ld	xwa, (0x336e:16)
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, (0x336e:16)
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join2_Skip
AccVoice_BarCounterBytecodeData_Skip7:
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32b4:16)
	jr	nz, AccVoice_BarCounterBytecodeData_Skip8
	ld	a, (0x32b5:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (RhythmTiming_OffsetTable:24)
	ld	xiz, 608352
	add	xiz, (xbc+wa)
	ld	xwa, xiz
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, xiz
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join2_Skip
AccVoice_BarCounterBytecodeData_Skip8:
	calr	AccVoice_BarCounterBytecodeData_Helper6
	ld	xwa, (0x336e:16)
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, (0x336e:16)
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join2_Skip
AccVoice_BarCounterBytecodeData_Skip10:
	ld	xbc, (0x333a:16)
	ld	a, (xbc+16)
	ld	(xsp+4), a
	ld	a, (xbc+17)
	ld	(xsp+5), a
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x208
	jr	z, AccVoice_BarCounterBytecodeData_Skip9
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x318
	jr	z, AccVoice_BarCounterBytecodeData_Skip9
	lda	xwa, (xsp+4)
	call	AccTone_ValidateAndClamp
AccVoice_BarCounterBytecodeData_Skip9:
	ld	a, (xsp+4)
	ld	e, a
	extz	de
	ld	a, (xsp+5)
	ld	c, a
	extz	bc
	ld	wa, de
	call	AccTone_LookupByProgram_Dispatch
	ld	a, (ACC_PENDING_ENDING:16)
	cp	a, 1:i3
	jr	z, AccVoice_BarCounterBytecodeData_Skip11
	cp	a, 2:i3
	jr	nz, AccVoice_BarCounterBytecodeData_Skip11
	ldw	bc, 1060
	jr	AccVoice_BarCounterBytecodeData_Join
AccVoice_BarCounterBytecodeData_Skip11:
	ldw	bc, 36
AccVoice_BarCounterBytecodeData_Join:
	ld	xwa, xhl
	call	AccVoice_LoadAllParts_Wrap
	ld	xwa, (0x333a:16)
AccVoice_BarCounterBytecodeData_Join2:
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 63
AccVoice_BarCounterBytecodeData_Join2_Skip:
	pop	xiz
	inc	2, xsp
	ret
AccVoice_IncrementBarWithSave_Helper2:
	dec	2, xsp
	push	xiz
	bit	0, (0x32ab:16)
	jrl	z, AccVoice_BarCounterBytecodeData_Skip27
	ld	a, (ACC_PENDING_FILLIN:16)
	cp	a, 1:i3
	jr	z, AccVoice_BarCounterBytecodeData_Skip13
	cp	a, 2:i3
	jr	nz, AccVoice_BarCounterBytecodeData_Skip13
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32b2:16)
	jr	nz, AccVoice_BarCounterBytecodeData_Skip12
	ld	a, (0x32b3:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (RhythmTiming_OffsetTable:24)
	ld	xiz, 608352
	add	xiz, (xbc+wa)
	ld	xwa, xiz
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, xiz
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join3_Skip
AccVoice_BarCounterBytecodeData_Skip12:
	calr	AccVoice_BarCounterBytecodeData_Helper9
	ld	xwa, (0x336e:16)
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, (0x336e:16)
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join3_Skip
AccVoice_BarCounterBytecodeData_Skip13:
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32b0:16)
	jr	nz, AccVoice_BarCounterBytecodeData_Skip14
	ld	a, (0x32b1:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (RhythmTiming_OffsetTable:24)
	ld	xiz, 608352
	add	xiz, (xbc+wa)
	ld	xwa, xiz
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, xiz
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join3_Skip
AccVoice_BarCounterBytecodeData_Skip14:
	calr	AccVoice_BarCounterBytecodeData_Helper8
	ld	xwa, (0x336e:16)
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, (0x336e:16)
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jr	AccVoice_BarCounterBytecodeData_Join3_Skip
; port: v7's label AccVoice_BarCounterBytecodeData_Skip15 is not in v6 -- no v6 bytes correspond to what it named
AccVoice_BarCounterBytecodeData_Skip27:
	ld	xbc, (0x333a:16)
	ld	a, (xbc+16)
	ld	(xsp+4), a
	ld	a, (xbc+17)
	ld	(xsp+5), a
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x208
	jr	z, AccVoice_BarCounterBytecodeData_Skip28
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x318
	jr	z, AccVoice_BarCounterBytecodeData_Skip28
	lda	xwa, (xsp+4)
	call	AccTone_ValidateAndClamp
AccVoice_BarCounterBytecodeData_Skip28:
	ld	a, (xsp+4)
	ld	e, a
	extz	de
	ld	a, (xsp+5)
	ld	c, a
	extz	bc
	ld	wa, de
; port: v7's label AccVoice_BarCounterBytecodeData_Skip16 is not in v6 -- no v6 bytes correspond to what it named
	call	AccTone_LookupByProgram_Dispatch
	ld	xiz, xhl
	ld	a, (ACC_LANE_SECTION:16)
	extz	wa
	call	AccVoice_ComputeParamAddr_Wrap
	ld	xwa, xiz
	ld	bc, hl
	call	AccVoice_LoadAllParts_Wrap
	ld	xwa, (0x333a:16)
AccVoice_BarCounterBytecodeData_Join3:
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 63
AccVoice_BarCounterBytecodeData_Join3_Skip:
	pop	xiz
	inc	2, xsp
	ret
AccVoice_IncrementBarWithSave_Helper3:
	dec	2, xsp
	push	xiz
	bit	0, (0x32ab:16)
	jrl	z, AccVoice_BarCounterBytecodeData_Skip23
	ld	a, (ACC_PENDING_INTRO:16)
	cp	a, 1:i3
	jrl	z, AccVoice_BarCounterBytecodeData_Skip21
	cp	a, 4:i3
	jr	z, AccVoice_BarCounterBytecodeData_Skip18
	cp	a, 8
	jrl	nz, AccVoice_BarCounterBytecodeData_Skip21
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32ae:16)
	jr	nz, AccVoice_BarCounterBytecodeData_Skip17
	ld	a, (0x32af:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (RhythmTiming_OffsetTable:24)
	ld	xiz, 608352
	add	xiz, (xbc+wa)
	ld	xwa, xiz
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, xiz
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join6_Skip
AccVoice_BarCounterBytecodeData_Skip17:
	calr	AccVoice_BarCounterBytecodeData_Helper5
	ld	xwa, (0x336e:16)
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, (0x336e:16)
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join6_Skip
AccVoice_BarCounterBytecodeData_Skip18:
	ld	a, (ACC_BEATS_PER_BAR:16)
	extz	wa
	lda	xbc, (AccStyle_ApplyExt_SkipClamp_Table:24)
	cp	(xbc+wa), 0x01
	jr	nz, AccVoice_BarCounterBytecodeData_Skip19
	calr	AccVoice_BarCounterBytecodeData_Helper3
	ld	xwa, (0x336e:16)
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, (0x336e:16)
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join6_Skip
AccVoice_BarCounterBytecodeData_Skip19:
	ld	xbc, (0x333a:16)
	ld	a, (xbc+16)
	ld	(xsp+4), a
	ld	a, (xbc+17)
	ld	(xsp+5), a
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x208
	jr	z, AccVoice_BarCounterBytecodeData_Skip29
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x318
	jr	z, AccVoice_BarCounterBytecodeData_Skip29
	lda	xwa, (xsp+4)
	call	AccTone_ValidateAndClamp
AccVoice_BarCounterBytecodeData_Skip29:
	ld	a, (xsp+4)
	ld	e, a
	extz	de
	ld	a, (xsp+5)
	ld	c, a
	extz	bc
	ld	wa, de
; port: v7's label AccVoice_BarCounterBytecodeData_Skip20 is not in v6 -- no v6 bytes correspond to what it named
	call	AccTone_LookupByProgram_Dispatch
	ld	xiz, xhl
	ld	xwa, xiz
	ldw	bc, 34
	call	AccVoice_LoadAllParts_Wrap
	ld	xwa, xiz
	ld	xbc, 294
	call	AccVoice_LoadTuningBlock_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join6_Skip
AccVoice_BarCounterBytecodeData_Skip21:
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32ac:16)
	jr	nz, AccVoice_BarCounterBytecodeData_Skip22
	ld	a, (0x32ad:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (RhythmTiming_OffsetTable:24)
	ld	xiz, 608352
	add	xiz, (xbc+wa)
	ld	xwa, xiz
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, xiz
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join6_Skip
AccVoice_BarCounterBytecodeData_Skip22:
	calr	AccVoice_BarCounterBytecodeData_Helper4
	ld	xwa, (0x336e:16)
	call	AccInit_AllPartPositions_Wrap
	ld	xwa, (0x336e:16)
	call	AccTuning_CopyAllPartsFromStyle_Wrap
	or	(ACC_LANES_RESYNC:16), 0x3f
	jrl	AccVoice_BarCounterBytecodeData_Join6_Skip
AccVoice_BarCounterBytecodeData_Skip23:
	ld	xbc, (0x333a:16)
	ld	a, (xbc+16)
	ld	(xsp+4), a
	ld	a, (xbc+17)
	ld	(xsp+5), a
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x208
	jr	z, AccVoice_BarCounterBytecodeData_Skip30
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x318
	jr	z, AccVoice_BarCounterBytecodeData_Skip30
	lda	xwa, (xsp+4)
	call	AccTone_ValidateAndClamp
AccVoice_BarCounterBytecodeData_Skip30:
	ld	a, (xsp+4)
	ld	e, a
	extz	de
	ld	a, (xsp+5)
	ld	c, a
	extz	bc
	ld	wa, de
; port: v7's label AccVoice_BarCounterBytecodeData_Skip24 is not in v6 -- no v6 bytes correspond to what it named
	call	AccTone_LookupByProgram_Dispatch
	ld	xiz, xhl
	ld	a, (ACC_PENDING_INTRO:16)
	cp	a, 1:i3
	jr	z, AccVoice_BarCounterBytecodeData_Skip26
	cp	a, 4:i3
	jr	z, AccVoice_BarCounterBytecodeData_Skip25
	cp	a, 8
	jr	nz, AccVoice_BarCounterBytecodeData_Skip26
	ldw	bc, 1056
	jr	AccVoice_BarCounterBytecodeData_Join4
AccVoice_BarCounterBytecodeData_Skip25:
	ldw	bc, 34
	jr	AccVoice_BarCounterBytecodeData_Join4
AccVoice_BarCounterBytecodeData_Skip26:
	ldw	bc, 32
AccVoice_BarCounterBytecodeData_Join4:
	ld	xwa, xiz
	call	AccVoice_LoadAllParts_Wrap
	ld	xwa, (0x333a:16)
AccVoice_BarCounterBytecodeData_Join5:
	call	AccTuning_CopyAllPartsFromStyle_Wrap
AccVoice_BarCounterBytecodeData_Join6:
	or	(ACC_LANES_RESYNC:16), 63
AccVoice_BarCounterBytecodeData_Join6_Skip:
	pop	xiz
	inc	2, xsp
	ret
Chord_LookupTypeFamily:
	ld	a, (0x336b:16)
	extz WA
	lda xbc, (Chord_TypeFamilyTable:24)
	ld	(13162), (xbc+wa)
	ret
AccTuning_ComplexBytecodeData:
	dec	2, xsp
	push	xiz
	bit	0, (0x32ab:16)
	jrl	z, AccTuning_ComplexBytecodeData_Skip5
	ld	a, (ACC_SECTION_BUTTONS_HELD:16)
	and	a, 0x80
	cp	a, 128
	jr	z, AccTuning_ComplexBytecodeData_Skip
	ld	a, (ACC_REQ_FILLIN:16)
	and	a, 2
	cp	a, 2:i3
	jr	nz, AccTuning_ComplexBytecodeData_Loop2
AccTuning_ComplexBytecodeData_Skip:
	ld	a, (ACC_PART_BIT:16)
	cpl	a
	and	(ACC_LANES_FILLIN1:16), a
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32b2:16)
	jr	nz, AccTuning_ComplexBytecodeData_Loop
	ld	a, (ACC_PART_BIT:16)
	or	(ACC_LANES_FILLIN2:16), a
	ld	e, (0x32b3:16)
	jr	AccTuning_ComplexBytecodeData_Skip4
AccTuning_ComplexBytecodeData_Loop:
	ld	e, (0x3369:16)
	jr	AccTuning_ComplexBytecodeData_Skip4
AccTuning_ComplexBytecodeData_Loop2:
	ld	a, (ACC_SECTION_BUTTONS_HELD:16)
	and	a, 0x40
	cp	a, 64
	jr	z, AccTuning_ComplexBytecodeData_Join
	ld	a, (ACC_REQ_FILLIN:16)
	and	a, 0x1
	cp	a, 1:i3
	jr	nz, AccTuning_ComplexBytecodeData_Skip4
AccTuning_ComplexBytecodeData_Join:
; port: v7's label AccTuning_ComplexBytecodeData_Skip2 is not in v6 -- no v6 bytes correspond to what it named
	ld	a, (ACC_PART_BIT:16)
	cpl	a
	and	(ACC_LANES_FILLIN2:16), a
; port: v7's label AccTuning_ComplexBytecodeData_Skip3 is not in v6 -- no v6 bytes correspond to what it named
	ld	a, (ACC_BEATS_PER_BAR:16)
	cp	a, (0x32b0:16)
	jr	nz, AccTuning_ComplexBytecodeData_Skip6
	ld	a, (ACC_PART_BIT:16)
	or	(ACC_LANES_FILLIN1:16), a
	ld	e, (0x32b1:16)
	jr	AccTuning_ComplexBytecodeData_Skip4
AccTuning_ComplexBytecodeData_Skip6:
	ld	e, (0x3369:16)
AccTuning_ComplexBytecodeData_Skip4:
	cp	(ACC_PART_BIT:16), 2
	jr	nz, AccTuning_ComplexBytecodeData_Skip13
	ldw	(ACC_CUR_BLOCK:16), 0xfffe
	jr	AccTuning_ComplexBytecodeData_Join2
AccTuning_ComplexBytecodeData_Skip13:
	ld	a, (ACC_PART_BIT:16)
	extz	wa
	lda	xbc, (AccPart_BitToIndexTable:24)
	ld	l, (xbc+wa)
	ld	a, e
	extz	wa
	sla	wa, 2
	lda	xbc, (RhythmTiming_OffsetTable:24)
	ld	xde, 608352
	add	xde, (xbc+wa)
	ld	xbc, xde
	ld	a, l
	extz	wa
	add	wa, wa
	ldw	(ACC_CUR_BLOCK), (xbc+wa)
AccTuning_ComplexBytecodeData_Join2:
	ldw	(ACC_CUR_READ_POS:16), 6
	jr	AccTuning_ComplexBytecodeData_Epilogue
AccTuning_ComplexBytecodeData_Skip5:
	ld	xbc, (0x333a:16)
	ld	a, (xbc+16)
	ld	(xsp+4), a
	ld	a, (xbc+17)
	ld	(xsp+5), a
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x208
	jr	z, AccTuning_ComplexBytecodeData_Skip14
	ld	a, (xsp+4)
	ld	c, a
	extz	bc
	ld	a, (xsp+5)
	extz	wa
	sll	wa, 8
	or	wa, bc
	cp	wa, 0x318
	jr	z, AccTuning_ComplexBytecodeData_Skip14
	lda	xwa, (xsp+4)
	call	AccTone_ValidateAndClamp
AccTuning_ComplexBytecodeData_Skip14:
	ld	a, (xsp+4)
	ld	e, a
	extz	de
	ld	a, (xsp+5)
	ld	c, a
	extz	bc
	ld	wa, de
; port: v7's label AccTuning_ComplexBytecodeData_Code_Skip is not in v6 -- no v6 bytes correspond to what it named
	call	AccTone_LookupByProgram_Dispatch
	ld	xiz, xhl
	call	AccPedal_DirectionA_Wrap
	ld	xwa, xiz
	ld	bc, hl
	call	AccPart_GetParamAddr_Wrap
	ld	(ACC_CUR_READ_POS:16), hl
AccTuning_ComplexBytecodeData_Epilogue:
	pop	xiz
	inc	2, xsp
	ret
	ld	xbc, 0x95440
	ld	(0x3328:16), 0
	ld	a, (ACC_LANE_MEASURE:16)
	extz	wa
	ld	hl, wa
	sla	hl, 2
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	ldw	(ACC_LANE_BLOCK), (xde+hl)
	cpw	(ACC_LANE_BLOCK:16), 65534
	jr	nz, AccTuning_ComplexBytecodeData_Skip7
	set	0, (0x3328:16)
AccTuning_ComplexBytecodeData_Skip7:
	ld	a, (ACC_LANE_MEASURE:16)
	extz	wa
	ld	hl, wa
	sla	hl, 2
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	lda_rr	xwa, xde, hl
	ldw	(ACC_LANE_READ_POS), (xwa+2)
	ld	a, (0x3335:16)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 32
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	ldw	(0x31e3), (xde+hl)
	cpw	(0x31e3:16), 65534
	jr	nz, AccTuning_ComplexBytecodeData_Skip8
	set	2, (0x3328:16)
AccTuning_ComplexBytecodeData_Skip8:
	ld	a, (0x3335:16)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 32
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	lda_rr	xwa, xde, hl
	ldw	(12755), (xwa+2)
	ld	a, (0x3336:16)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 64
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	ldw	(0x31e5), (xde+hl)
	cpw	(0x31e5:16), 65534
	jr	nz, AccTuning_ComplexBytecodeData_Skip9
	set	3, (0x3328:16)
AccTuning_ComplexBytecodeData_Skip9:
	ld	a, (0x3336:16)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 64
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	lda_rr	xwa, xde, hl
	ldw	(12757), (xwa+2)
	ld	a, (0x3337:16)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 96
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	ldw	(0x31e7), (xde+hl)
	cpw	(0x31e7:16), 65534
	jr	nz, AccTuning_ComplexBytecodeData_Skip10
	set	4, (0x3328:16)
AccTuning_ComplexBytecodeData_Skip10:
	ld	a, (0x3337:16)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 96
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	lda_rr	xwa, xde, hl
	ldw	(12759), (xwa+2)
	ld	a, (0x3338:16)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 128
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	ldw	(0x31e9), (xde+hl)
	cpw	(0x31e9:16), 65534
	jr	nz, AccTuning_ComplexBytecodeData_Skip11
	set	5, (0x3328:16)
AccTuning_ComplexBytecodeData_Skip11:
	ld	a, (0x3338:16)
	extz	wa
	sla	wa, 2
	ld	hl, wa
	add	hl, 128
	ld	xwa, 0:i3
	ld	a, (0x3369:16)
	ld	xde, xwa
	sll	xde, 2
	add	xde, xwa
	sll	xde, 5
	add	xde, xbc
	lda_rr	xwa, xde, hl
	ldw	(12761), (xwa+2)
	ldw	(0x31e1:16), 65534
	ldw	(0x31d1:16), 6
	set	1, (0x3328:16)
	ret
	calr	AccTuning_ComplexBytecodeData_Helper
	ret
AccTuning_ComplexBytecodeData_Helper:
	ret
AccTone_WriteProgramChange:
	push	xiz
	ld	xix, xwa
	ld	l, (xbc)
	ld	h, (xbc+1)
	ld	(PROGRAM_CHANGE_PART:16), 72
	push	xix
	call	PartCtrl_WriteProgramChange
	pop	xix
	ld	xbc, xix
	ld	(xbc), l
	ld	(xbc+1), h
	pop	xiz
	ret
AccTone_ValidateAndClamp:
	push xiz
	ld xbc, xwa
	ld l, (xbc)
	ld h, (xbc + 1)
	push xbc
	call VoiceParam_ClampAndValidate
	pop xbc
	ld (xbc), l
	ld (xbc + 1), h
	pop xiz
	ret

AccTone_LookupByProgram_Dispatch:
	push	xiz
	and	xwa, 255
	and	xbc, 255
	ld	h, c
	call	AccVoice_LookupWithOffset
	ld	xhl, xiy
	pop	xiz
	ret
Rhythm_UpdateTuningConfig_Wrap:
	push	xiz
	ld	xiy, xwa
	call	Rhythm_UpdateTuningConfig
	pop	xiz
	ret
AccPatch_SetByChordIndex_Wrap:
	push	xiz
	ld	w, a
	call	AccPatch_SetByChordIndex
	pop	xiz
	ret
AccTuning_CopyAllPartsFromStyle_Wrap:
	push	xiz
	ld	xiy, xwa
	call	AccTuning_CopyAllPartsFromStyle
	pop	xiz
	ret
AccVoice_LoadTuningBlock_Wrap:
	push	xiz
	ld	xiy, xwa
	ld	xhl, xbc
	and	xhl, 65535
	call	AccVoice_LoadTuningBlock
	pop	xiz
	ret
AccVoice_ComputeParamAddr_Wrap:
	push	xiz
	and	xwa, 255
	call	AccVoice_ComputeParamAddr
	and	xhl, 65535
	pop	xiz
	ret
AccPart_InitPositionsAndBase_Wrap:
	push	xiz
	ld	xiy, xwa
	call	AccPart_InitPositionsAndBase
	pop	xiz
	ret
AccInit_AllPartPositions_Wrap:
	push	xiz
	ld	xiy, xwa
	call	AccInit_AllPartPositions
	pop	xiz
	ret
AccPedal_ProcessAllChanges_Wrap:
	push	xiz
	call	AccPedal_ProcessAllChanges
	pop	xiz
	ret
AccStyle_SetupPartAddressesByHL_Wrap:
	push	xiz
	ld	xiy, xwa
	ld	xhl, xbc
	and	xhl, 65535
	call	AccStyle_SetupPartAddressesByHL
	pop	xiz
	ret
AccVoice_LoadAllParts_Wrap:
	push	xiz
	ld	xiy, xwa
	ld	xhl, xbc
	and	xhl, 65535
	call	AccVoice_LoadAllParts
	pop	xiz
	ret
	push	xiz
	call	AccStyle_ApplyChanges
	pop	xiz
	ret
	push	xiz
	call	Rhythm_SendNoteOnMax
	pop	xiz
	ret
	push	xiz
	call	AccNotes_ForgetAllSounding
	pop	xiz
	ret
	push	xiz
	call	AccBuf_WriteAllNotesOff
	pop	xiz
	ret
Rhythm_SendChanPressure_Wrap:
	push	xiz
	call	Rhythm_SendChanPressure
	pop	xiz
	ret
AccBuf_ResetAll4_Wrap:
	push	xiz
	call	AccBuf_ResetAll4
	pop	xiz
	ret
AccSeq_DualPartScan_Wrap:
	push	xiz
	call	AccSeq_DualPartScan
	pop	xiz
	ret
AccSeq_FourChannelScan_Wrap:
	push	xiz
	call	AccSeq_FourChannelScan
	pop	xiz
	ret
AccPedal_DirectionA_Wrap:
	push	xiz
	call	AccPedal_DirectionA
	and	xhl, 65535
	pop	xiz
	ret
; AccPart_GetParamAddr_Wrap: Register-convention wrapper of AccPart_GetParamAddr: XIY = XWA (the record), HL = BC
;   zero-extended (the offset); returns its result in HL (XWA high half cleared), preserving XIZ. Basis: callers +
;   body -- AccTuning_ComplexBytecodeData passes XWA = the record from AccTone_LookupByProgram_Dispatch and BC = the
;   offset from AccPedal_DirectionA_Wrap, then stores HL at 13116.
AccPart_GetParamAddr_Wrap:
	push	xiz
	ld	xiy, xwa
	ld	xhl, xbc
	and	xhl, 65535
	call	AccPart_GetParamAddr
	and	xwa, 65535
	ld	xhl, xwa
	pop	xiz
	ret
	push	xix
	push	xiy
	push	xiz
	push	xwa
	push	xbc
	push	xde
	push	xhl
	xor	xwa, xwa
	ld	a, (ACC_PART_BIT:16)
	call	AccTone_ValidateAndClamp_Helper
	pop	xhl
	pop	xde
	pop	xbc
	pop	xwa
	pop	xiz
	pop	xiy
	pop	xix
	ret
	push	xix
	push	xiy
	push	xiz
	push	xwa
	push	xbc
	push	xde
	push	xhl
	xor	xwa, xwa
	ld	a, (ACC_PART_BIT:16)
	call	AccTone_ValidateAndClamp_Helper2
	pop	xhl
	pop	xde
	pop	xbc
	pop	xwa
	pop	xiz
	pop	xiy
	pop	xix
	ret
AccTone_CallWithSaveAll:
	push xix
	push xiy
	push xiz
	push xwa
	push xbc
	push xde
	push xhl
	call AccVoice_ClearChannelStates
	pop xhl
	pop xde
	pop xbc
	pop xwa
	pop xiz
	pop xiy
	pop xix
	ret

AccVoice_IncrementBarWithSave:
	push xix
	push xiy
	push xiz
	push xwa
	push xbc
	push xde
	push xhl
	call AccVoice_IncrementBarCounter
	pop xhl
	pop xde
	pop xbc
	pop xwa
	pop xiz
	pop xiy
	pop xix
	ret

AccTuning_DispatchDataBlock_A:
	push	xix	; was .ascii "<=>89:;"
	push	xiy
	push	xiz
	push	xwa
	push	xbc
	push	xde
	push	xhl
	call	AccVoice_BarCounterBytecodeData
	pop	xhl
	pop	xde
	pop	xbc
	pop	xwa
	pop	xiz
	pop	xiy
	pop	xix
	ret
	push	xix
	push	xiy
	push	xiz
	push	xwa
	push	xbc
	push	xde
	push	xhl
	call	AccVoice_IncrementBarWithSave_Helper
	pop	xhl
	pop	xde
	pop	xbc
	pop	xwa
	pop	xiz
	pop	xiy
	pop	xix
	ret
	push	xix
	push	xiy
	push	xiz
	push	xwa
	push	xbc
	push	xde
	push	xhl
	call	AccVoice_IncrementBarWithSave_Helper2
	pop	xhl	; was .ascii "[ZYX^]\\"
	pop	xde
	pop	xbc
	pop	xwa
	pop	xiz
	pop	xiy
	pop	xix
	ret
	push	xix	; was .ascii "<=>89:;"
	push	xiy
	push	xiz
	push	xwa
	push	xbc
	push	xde
	push	xhl
	call	AccVoice_IncrementBarWithSave_Helper3
	pop	xhl
	pop	xde
	pop	xbc
	pop	xwa
	pop	xiz
	pop	xiy
	pop	xix
	ret
AccStyle_TempoLookupData_Helper:
	push	xix
	push	xiy
	push	xiz
	push	xwa
	push	xbc
	push	xde
	push	xhl
	call	AccTone_ReadAndProcess
	ld	a, l
	pop	xhl
	pop	xde
	ld	e, a
	pop	xbc
	pop	xwa
	pop	xiz
	pop	xiy
	pop	xix
	ret

Chord_LookupTypeFamily_Saved:
	push xix
	push xiy
	push xiz
	push xwa
	push xbc
	push xde
	push xhl
	call Chord_LookupTypeFamily
	pop xhl
	pop xde
	pop xbc
	pop xwa
	pop xiz
	pop xiy
	pop xix
	ret

AccTuning_DispatchDataBlock_B:
	push	xix	; was .ascii "<=>9;"
	push	xiy
	push	xiz
	push	xbc
	push	xhl
	call	AccTuning_ComplexBytecodeData
	pop	xhl
	pop	xbc
	pop	xiz
	pop	xiy
	pop	xix
	ret

AccTone_LookupByProgramWrapped:
	push xix
	push xiy
	push xiz
	push xbc
	push xhl
	and xwa, 0xff
	xor xbc, xbc
	ld c, d
	call AccTone_LookupByProgram
	ld a, l
	pop xhl
	pop xbc
	pop xiz
	pop xiy
	pop xix
	ret

AccTone_JumpTableData:
	call	AccTone_InlineBytecodeData
	ret
	call	AccTone_JumpTableData_Helper3
	ret
	call	AccTone_JumpTableData_Helper2
	ret
	call	AccTone_JumpTableData_Helper
	ret
	call	AccSection_ApplyPendingChange
	ret
AccTone_LookupByProgramWrapped_Join:
	push	xiz
	call	AccStyle_UseSecondarySource
	pop	xiz
	ret
AccPatch_InitFuncTable:
	.long	AccTone_StubReturn_B
	.long	AccTone_StubReturn_A
	.long	Composer_ResetStyleImage
	.long	AccPatch_InitAndCountSlots
AccTone_StubReturn_A:
	ret

AccTone_StubReturn_B:
	ret

AccPatch_RecountFreeSlots:
	calr AccPatch_CountAvailableSlots
	ret

AccPatch_CountSlotsAlt:
	calr AccPatch_CountSlotsAlt_Body
	ret

AccPatch_InitAndCountSlots:
	calr	AccPatch_CheckAndInitDemo
	calr	AccPatch_CountAvailableSlots
	call	VoiceSlot_Dispatch_Type81
	ld	(CSTMCP_TO_SLOT:16), 10
	ret
; Composer_ResetStyleImage: Resets the Composer's style image (RHYTHM_PATTERN_BUF_A, 0x94800) to the built-in empty style (AccDemo_Init)
;   and recounts its free blocks (AccPatch_CountAvailableSlots); XIZ preserved.  Basis: callers + body --
;   MainSysControl's INITIAL SETTING case 5 COMPOSER (MainSysCtrl_OnInitComposer), the MIDI transfer recovery
;   of the style-image groups (MidiSysEx_RecoverAbortedXferGroup) and the style-image checks of the
;   accompaniment engine and the floppy loader call it; entry 2 of AccPatch_InitFuncTable.
Composer_ResetStyleImage:
	push xiz
	call AccDemo_Init_Wrap
	calr AccPatch_CountAvailableSlots
	pop xiz
	ret

AccPatch_InitByteData:
	push	xiz
	call	AccPatch_InitSlotChain_WithAddr
	pop	xiz
	ret
	call	AccPatch_VoiceAssignDataBlock
	ret
	call	AccDemo_Init_Wrap
	ret
	push	xiz
	calr	AccDemo_InitDone_Helper
	calr	AccPatch_CountAvailableSlots
	or	(0x3415:16), 128
	pop	xiz
	ret
AccDemo_InitWithFlag:
	push xiz

	; ordi8 0x34d1, 128 (v7 patched)
	or	(0x3419:16), 128
	; call AccDemo_Init_Wrap (v7 addr)
	call	AccDemo_Init_Wrap
	pop xiz

	ret



AccPatch_MultiCallWrapper:
	push	xiz
	calr	AccPatch_EnsureStyleImageHeader
	calr	AccPatch_ClearModeFlag
	pop	xiz
	ret
; AccPatch_ClearModeAndInitSlotChain_Wrap: XIZ-preserving: clears the mode flag 0x3539 (AccPatch_ClearModeFlag) and
;   re-packs the style image's slot chain at RHYTHM_PATTERN_BUF_A (AccPatch_InitSlotChain_WithAddr, which also stores
;   the used size). Basis: callers + body -- MidiPkt_GetUsedSize_StyleImage calls it before reading the used size
;   (0x9482E) * 16; its header names these two calls.
AccPatch_ClearModeAndInitSlotChain_Wrap:
	push	xiz
	calr	AccPatch_ClearModeFlag
	call	AccPatch_InitSlotChain_WithAddr
	pop	xiz
	ret
; AccPatch_ClearModeFlag_Wrap: XIZ-preserving call of AccPatch_ClearModeFlag (0x35D5 = 0). Basis: callers + body --
;   SingleLoad_CopyComposerPatternFromFile calls it as its last step when the copy did not fail (0x3950 != 131); the
;   body is `push xiz / calr AccPatch_ClearModeFlag / pop xiz`; X_Wrap convention (Voice_RefreshBankData_Wrap,
;   AccPatch_ClearModeAndInitSlotChain_Wrap). What the flag 0x35D5 means is not established, so the name stays
;   literal.
AccPatch_ClearModeFlag_Wrap:
	push	xiz
	calr	AccPatch_ClearModeFlag
	pop	xiz
	ret

AccPatch_ClearModeFlag:
	ld	(13597:16), 0
	ret
Not_sure_maybe_SOFT_VERSION_related:
	and	(0x355e:16), 0xfe
	ld	(0x351d:16), 0
	ld	xwa, RHYTHM_PATTERN_BUF_A
	cp	hl, 0:i3
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip
	ld	(0x351d:16), 1
	call	Get_Firmware_Version
	cp	l, 255
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip
	ld	(0x351d:16), 0
Not_sure_maybe_SOFT_VERSION_related_Skip:
	ret
	push	(CMP_RECORD_PART:16)
	and	(0x355e:16), 0xfe
	ld	(0x351d:16), 0
	push	(STYLE_SECTION:16)
	ld	(STYLE_SECTION:16), 0
Not_sure_maybe_SOFT_VERSION_related_Loop:
	cp	(STYLE_SECTION:16), 30
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip2
	ld	(CMP_RECORD_PART:16), 16
	calr	Not_sure_maybe_SOFT_VERSION_related_Skip3
	ld	(CMP_RECORD_PART:16), 8
	calr	Not_sure_maybe_SOFT_VERSION_related_Skip3
	ld	(CMP_RECORD_PART:16), 1
	calr	Not_sure_maybe_SOFT_VERSION_related_Skip3
	ld	(CMP_RECORD_PART:16), 2
	calr	Not_sure_maybe_SOFT_VERSION_related_Skip3
	ld	(CMP_RECORD_PART:16), 4
	calr	Not_sure_maybe_SOFT_VERSION_related_Skip3
	inc	1, (STYLE_SECTION:16)
	jr	Not_sure_maybe_SOFT_VERSION_related_Loop
Not_sure_maybe_SOFT_VERSION_related_Skip2:
	pop	(STYLE_SECTION:16)
	pop	(CMP_RECORD_PART:16)
	and	(0x355e:16), 0xfe
	cp	(0x351d:16), 0
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip4
	calr	Composer_ResetStyleImage
Not_sure_maybe_SOFT_VERSION_related_Skip4:
	ret
Not_sure_maybe_SOFT_VERSION_related_Skip3:
	calr	AccPatch_InitCurrentSlotPointer
	calr	AccPatch_GetSlotBeatsAndMeasures
	ld	w, 0:opc
	mul	wa, c
	calr	Not_sure_maybe_SOFT_VERSION_related_Skip5
	cpw	(ACC_PATCH_CURSOR_BLOCK:16), 0xffff
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip6
	calr	Not_sure_maybe_SOFT_VERSION_related_Skip7
	jr	Not_sure_maybe_SOFT_VERSION_related_Skip8
Not_sure_maybe_SOFT_VERSION_related_Skip6:
	calr	Composer_ResetStyleImage
	or	(0x355e:16), 0x1
Not_sure_maybe_SOFT_VERSION_related_Skip8:
	bit	0, (0x355e:16)
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip9
	ld	(0x351d:16), 1
Not_sure_maybe_SOFT_VERSION_related_Skip9:
	and	(0x355e:16), 0xfe
	ret
Not_sure_maybe_SOFT_VERSION_related_Skip5:
	ld	w, 0:opc
	ld	c, 0:opc
Not_sure_maybe_SOFT_VERSION_related_Loop2:
	cp	c, a
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip10
	push	c
	pushw	wa
	calr	AccPatch_SlotScanByteData_Helper
	cp	a, 131
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip11
	popw	wa
	pop	c
	inc	1, c
	jr	Not_sure_maybe_SOFT_VERSION_related_Loop2
Not_sure_maybe_SOFT_VERSION_related_Skip11:
	popw	wa
	pop	c
	calr	Not_sure_maybe_SOFT_VERSION_related_Skip12
	ld	w, b
Not_sure_maybe_SOFT_VERSION_related_Skip10:
	ret
Not_sure_maybe_SOFT_VERSION_related_Skip12:
	cp	c, a
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip13
	push	c
	push_a
	calr	Not_sure_maybe_SOFT_VERSION_related_Skip14
	cp	b, 1:i3
	jr	z, Not_sure_maybe_SOFT_VERSION_related_Skip15
	pop_a
	pop	c
	inc	1, c
	jr	Not_sure_maybe_SOFT_VERSION_related_Skip12
Not_sure_maybe_SOFT_VERSION_related_Skip13:
	jr	Not_sure_maybe_SOFT_VERSION_related_Skip16
Not_sure_maybe_SOFT_VERSION_related_Skip15:
	pop_a
	pop	c
Not_sure_maybe_SOFT_VERSION_related_Skip16:
	ret
Not_sure_maybe_SOFT_VERSION_related_Skip14:
	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)
	calr	AccPatch_GetEntryAddr
	ld	hl, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(xix+hl), 0x81
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	cp	wa, 254
	jr	nz, Not_sure_maybe_SOFT_VERSION_related_Skip17
	cpw	(STYLE_FREE_BLOCKS:16), 0
	jr	nz, Not_sure_maybe_SOFT_VERSION_related_Skip18
	ld	b, 1:opc
	jr	Not_sure_maybe_SOFT_VERSION_related_Skip19
Not_sure_maybe_SOFT_VERSION_related_Skip18:
	call	AccPatch_SeqAdvStep_WrapToNext
	ld	b, 0:opc
	jr	Not_sure_maybe_SOFT_VERSION_related_Skip19
Not_sure_maybe_SOFT_VERSION_related_Skip17:
	inc	1, wa
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
	ld	b, 0:opc
Not_sure_maybe_SOFT_VERSION_related_Skip19:
	ret
Not_sure_maybe_SOFT_VERSION_related_Skip7:
	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)
	calr	AccPatch_GetEntryAddr
	ld	hl, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(xix+hl), 0x83
	ld	hl, (xix+3)
	ldw	(xix+3), 0xffff
Not_sure_maybe_SOFT_VERSION_related_Loop3:
	cp	hl, 0x154
	jr	nc, Not_sure_maybe_SOFT_VERSION_related_Skip20
	calr	AccPatch_GetEntryAddr
	and	(xix), 0x7f
	ld	hl, (xix+3)
	ldw	(xix+1), 0xffff
	ldw	(xix+3), 0xffff
	jr	Not_sure_maybe_SOFT_VERSION_related_Loop3
Not_sure_maybe_SOFT_VERSION_related_Skip20:
	ret
AccPatch_CheckAndInitDemo:
	ld xiy, RHYTHM_PATTERN_BUF_A
	add xiy, 0xe
	ld wa, (xiy)
	cp wa, 0:i3
	jr z, AccPatch_CheckAndInitDemo_Ret
	call AccDemo_Init_Wrap

AccPatch_CheckAndInitDemo_Ret:
	ret

AccPatch_SlotConfigByteData:
	ret
	ret
	push	(CMP_RECORD_PART:16)
	push	(STYLE_SECTION:16)
	ld	(STYLE_SECTION:16), 0
AccPatch_SlotConfigByteData_Loop:
	; v10 does not spell this byte either
	cp	(STYLE_SECTION:16), 12
	; v10 does not spell this byte either
	jr	z, AccPatch_SlotConfigByteData_Skip
	ld	(CMP_RECORD_PART:16), 16
	calr	AccPatch_CheckAndInitDemo_Helper
	ld	(CMP_RECORD_PART:16), 8
	calr	AccPatch_CheckAndInitDemo_Helper
	ld	(CMP_RECORD_PART:16), 1
	calr	AccPatch_CheckAndInitDemo_Helper
	ld	(CMP_RECORD_PART:16), 2
	calr	AccPatch_CheckAndInitDemo_Helper
	ld	(CMP_RECORD_PART:16), 4
	calr	AccPatch_CheckAndInitDemo_Helper
	inc	1, (STYLE_SECTION:16)
	jr	AccPatch_SlotConfigByteData_Loop
AccPatch_SlotConfigByteData_Skip:
	; v10 does not spell this byte either
	pop	(STYLE_SECTION:16)
	; v10 does not spell this byte either
	pop	(CMP_RECORD_PART:16)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	ret
AccPatch_CheckAndInitDemo_Helper:
	; v10 does not spell this byte either
	cp	(STYLE_SECTION:16), 12
	; v10 does not spell this byte either
	jr	nc, AccPatch_CheckAndInitDemo_Return
	calr	AccPatch_InitCurrentSlotPointer
	calr	AccPatch_SlotScanByteData
	calr	AccPatch_GetSlotBeatsAndMeasures
	ld	e, c
	ld	c, 1:opc
AccPatch_CheckAndInitDemo_Join:
	cp	c, e
	jr	z, AccPatch_CheckAndInitDemo_Return
	push	e
	push_a
	push	c
	calr	AccPatch_CheckAndInitDemo_Helper3
	pop	c
	push	c
	calr	AccPatch_CheckAndInitDemo_Helper4
	pop	c
	pop_a
	pop	e
	inc	1, c
	jr	AccPatch_CheckAndInitDemo_Join
AccPatch_CheckAndInitDemo_Return:
	ret
AccPatch_InitCurrentSlotPointer:
	calr AccPatch_GetCurrentSlotAddr
	ld	a, (CMP_RECORD_PART:16)
	calr MapBitFlagsToChannelOffset

	ld	hl, (xiy+w)

	ld	(ACC_PATCH_CURSOR_BLOCK:16), hl

	ldw	(ACC_PATCH_CURSOR_OFFSET:16), 6

	ret
AccPatch_SlotScanByteData:
	ld	c, 0:opc
AccPatch_SlotScanByteData_Join:
	cp	c, 8
	jr	z, AccPatch_SlotScanByteData_Return
	push	c
	calr	AccPatch_CheckAndInitDemo_Helper4
	pop c
	inc	1, c
	jr	AccPatch_SlotScanByteData_Join
AccPatch_SlotScanByteData_Return:
	ret
AccPatch_SlotScanByteData_Helper:
	call	AccPatch_SeqReadByte
	cp	a, 129
	jr	z, AccPatch_SlotScanByteData_Skip
	cp	a, 131
	jr	z, AccPatch_SlotScanByteData_Return2
	push_a
	call	AccPatch_AdvanceSeqIndex
	pop_a
	bit	0, (0x355e:16)
	jr	nz, AccPatch_SlotScanByteData_Skip
	jr	AccPatch_SlotScanByteData_Helper
AccPatch_SlotScanByteData_Skip:
	push_a
	call	AccPatch_AdvanceSeqIndex
	pop_a
	jr	AccPatch_SlotScanByteData_Return2
AccPatch_SlotScanByteData_Return2:
	ret
AccPatch_GetSlotBeatsAndMeasures:
	calr	AccPatch_GetCurrentSlotAddr
	ld	xwa, 0:i3
	ld	a, (xiy+12)
	add	xwa, AccTone_LookupByProgram_Table
	ld	a, (xwa)
	ld	c, (xiy+13)
	inc	1, c
	ret
AccPatch_CheckAndInitDemo_Helper3:
	ld	c, 0:opc
AccPatch_SlotScanByteData_Join2:
	cp	c, a
	jr	z, AccPatch_SlotScanByteData_Return3
	push	c
	push_a
	calr	AccPatch_SlotScanByteData_Helper
	pop_a
	pop c
	inc	1, c
	jr	AccPatch_SlotScanByteData_Join2
AccPatch_SlotScanByteData_Return3:
	ret
AccPatch_CheckAndInitDemo_Helper4:
	push	c
	ld	xwa, 0:i3
	ld	a, 160:opc
	ld	c, (STYLE_SECTION:16)
	mul	wa, c
	ld	xbc, 0:i3
	ld	c, (CMP_RECORD_PART:16)
	and	c, 31
	srl	c, 1
	add	xbc, AccPatch_ChannelBitToIndex
	ld	xde, 0:i3
	ld	e, (xbc)
	mul	de, 32
	add	xwa, xde
	add	xwa, 3136
	add	xwa, RHYTHM_PATTERN_BUF_A
	ld	xix, xwa
	pop c
	sll	c, 2
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(xix+c), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	inc	2, c
	ld	(xix+c), wa
	ret
; AccPatch_ChannelBitToIndex: channel index by (one-hot channel 0x379B & 31) >> 1, read by
;   AccPatch_StoreMeasureCursor: bits 0, 1, 2, 3, 4 (indices 0, 1, 2, 4, 8) -> 2, 3, 4, 1, 0.
AccPatch_ChannelBitToIndex:	.byte 2, 3, 4, 0, 1, 0, 0, 0, 0
AccPatch_RefreshSlotOffset_Wrap:
	push xiz
	call AccPatch_RefreshSlotOffset
	pop xiz
	ret

AccPatch_RefreshSlotOffset:
	calr AccPatch_GetCurrentSlotAddr
	ld xhl, 0:i3
	ld l, (xiy + 12)
	sll l, 1
	add xhl, AccPatch_DefaultStyleByTimeSig
	ld wa, (xhl)
	ld (xiy + 16), wa
	ret

Seq_RhythmProcessor:
	calr RhythmProc_CheckStyleChange
	calr RhythmProc_CheckPlayMode
	calr RhythmProc_CallDispatch
	calr RhythmProc_NullStub
	calr RhythmProc_CheckRhythmEdit
	calr RhythmProc_CheckStyleSwitch
	calr RhythmProc_CheckRepeatFlag
	calr AccPatch_ProcessPartChanges
	calr RhythmProc_SavePrevState
	ret

RhythmProc_CheckStyleChange:
	cp (CURRENT_TITLE:16), 0xb2
	jr z, .Lc_f5e896
	jr t, RhythmProc_StyleChange_Ret
RhythmProc_StyleChange_Init:
.Lc_f5e896:
	bit	2, (0x3415:16)
	jr z, RhythmProc_StyleChange_Ret
	and	(0x3415:16), 0xfb
	calr AccPatch_InitCurrentSlot
	calr AccPatch_UpdateAllChains
	call RhythmPatInit_LoadParams
RhythmProc_StyleChange_Ret:
	ret

RhythmProc_CheckPlayMode:
	cp (CURRENT_TITLE:16), 0xb5
	jr z, .Lc_f5e8c0
	ld	a, (0x3417:16)
	and A,0xf3
	ld	(0x3417:16), a
	jr t, AccPatch_CopySlotsExit
RhythmProc_PlayMode_Compare:
.Lc_f5e8c0:
	cp	(0x346d:16), 0xb5
	jr z, .Lc_f5e8d7
	ld	(0x3546:16), 0x00
	ld	a, (0x31fb:16)
	and A,0x07
	ld	(0x3424:16), a
RhythmProc_PlayMode_SendTempo:
.Lc_f5e8d7:
	bit	1, (0x3417:16)
	jr z, .Lc_f5e90d
	and	(0x3417:16), 0xfd
	ld	a, (0x3417:16)
	and A,0x0c
	cp a, 0:i3
	jr nz, .Lc_f5e90d
	ld	a, (0x3544:16)
	and A,0x0c
	cp a, 0:i3
	jr nz, .Lc_f5e90d
	calr AccPatch_RebuildChannelSlot
	push XWA
	push XHL
	push XBC
	push XDE
	push XIX
	push XIY
	push XIZ
	call SoundCtrl_SendTempoScaled
	pop XIZ
	pop XIY
	pop XIX
	pop XDE
	pop XBC
	pop XHL
	pop XWA
AccPatch_DetectModeChange:
.Lc_f5e90d:
	call AccPatch_CmpRealTick
	ld	a, (0x31fb:16)
	and A,0x07
	cp	a, (13348:16)
	jr	z, AccPatch_CopySlotsExit
	ld	(13348:16), a
	cp	(ACTIVE_TITLE:16), 181
	jr	nz, AccPatch_CopySlotsExit
	push	xwa
	push	xhl
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	call	SoundCtrl_SendAccTempo
	call	SoundCtrl_SendTempoScaled
	pop	xiz
	pop	xiy
	pop	xix
	pop	xde
	pop	xbc
	pop	xhl
	pop	xwa
AccPatch_CopySlotsExit:
	ret

RhythmProc_CallDispatch:
	call AccPlayback_InitOrUpdate
	ret

RhythmProc_NullStub:
	ret

RhythmProc_CopySlotData_Wrap:
	push xiz
	call RhythmProc_CopySlotData
	pop xiz
	ret

RhythmProc_CopySlotData:
	calr	AccPatch_GetCurrentSlotAddr

	ld xbc, 0x40

	add xiy, xbc

	ld	xix, 13316

	push xix

	push xiy

	pop xix

	pop xiy

	ld xbc, 0x10

	ldir85

	ret



; StyleSection_GroupBaseTable: 30 x u8, one per style section (STYLE_SECTION 0..29, in the record order of
;   scripts/build/style_bank_layout.py SECTION_ROLE): the section index of the first VARIATION of the
;   section's group -- 0 for group A, 4 for B, 8 for C.  No reader found: no 24- or 32-bit value and no
;   LDAR in v5..v10 points into it (notes/open6-kn5000-d/naming/probes/table_reader_scan.py).  Until
;   2026-11-02 the bytes were spelled as nop / max / ld (P2:8) instructions (RhythmProc_ChannelMapTable).
StyleSection_GroupBaseTable:
	.byte	0, 0, 0, 0		; A-VARIATION 1..4
	.byte	4, 4, 4, 4		; B-VARIATION 1..4
	.byte	8, 8, 8, 8		; C-VARIATION 1..4
	.byte	0, 0, 0, 0, 0, 0	; A-INTRO 1, 2, A-FILL IN 1, 2, A-ENDING 1, 2
	.byte	4, 4, 4, 4, 4, 4	; B-INTRO 1, 2 .. B-ENDING 1, 2
	.byte	8, 8, 8, 8, 8, 8	; C-INTRO 1, 2 .. C-ENDING 1, 2

; ============================================================================
; AccPatch_GetCurrentSlotAddr - Get address of current accompaniment patch slot
; ============================================================================
; Input:  None (reads current slot index from 13526)
; Output: XIY = pointer to patch slot data (at 0x94800 + slot*96 + 96)
; Reads the current patch slot index (0-29, capped), multiplies by 96-byte
; stride, and returns a pointer into the accompaniment patch table at 0x94800.
; ============================================================================
AccPatch_GetCurrentSlotAddr:
	ld	xhl, 0:i3
	ld	l, (STYLE_SECTION:16)
	cp	l, 30
	jr	c, AccPatch_GetSlotAddr_Valid
	ld	l, 0:opc
AccPatch_GetSlotAddr_Valid:
	mul hl, 0x60
	add xhl, 0x60
	ld xiy, RHYTHM_PATTERN_BUF_A
	add xiy, xhl
	ret

AccPatch_GetSlotAddr_Preserve:
	push	xwa
	push	xix
	xor	xhl, xhl
	ld	l, (STYLE_SECTION:16)
	cp	l, 30
	jr	c, AccPatch_GetSlotAddr_Preserve_Skip
	xor	l, l
AccPatch_GetSlotAddr_Preserve_Skip:
	mul	hl, 96
	add	xhl, 96
	ld	xiy, RHYTHM_PATTERN_BUF_A
	add	xiy, xhl
	pop	xix
	pop	xwa
	ret
AccPatch_GetEntryAddr:
	cp hl, 0xffff
	jr z, AccPatch_GetEntryAddr_Ret
	pushw hl
	pushw hl
	ld xhl, 0:i3
	popw hl
	sll xhl, 8
	ld xix, RHYTHM_PATTERN_BUF_B
	add xix, xhl
	popw hl

AccPatch_GetEntryAddr_Ret:
	ret

AccPatch_InitCurrentSlot:
	calr AccPatch_GetCurrentSlotAddr
	calr AccPatch_FreeAllChains
	calr AccPatch_CopyDefaultsForInit
	calr AccPatch_FillAllVoiceData
	or	(0x3415:16), 0x80
	calr AccPatch_ScanToSequenceStart

	ret



AccPatch_InitFromSlotIndex:
	push xiz
	calr AccPatch_InitFromIndex
	pop xiz
	ret

AccPatch_InitFromIndex:
	xor	xhl, xhl
	ld	l, (STYLE_COPY_SRC_SECTION:16)
	cp	l, 30
	jr	c, AccPatch_InitFromIndex_Valid
	xor	l, l
AccPatch_InitFromIndex_Valid:
	mul hl, 0x60

	add xhl, 0x60

	ld	xiy, (STYLE_SRC_IMAGE_PTR:16)

	add xiy, xhl

	; calr AccPatch_FreeAllChains_Alt (v7 displacement)
	calr	AccPatch_FreeAllChains_Alt
	; calr AccPatch_CopyDefaultsToSlot (v7 displacement)
	calr	AccPatch_CopyDefaultsToSlot
	; calr AccPatch_FillAllSlots_Alt (v7 displacement)
	calr	AccPatch_FillAllSlots_Alt
	; ordi8 0x34cd, 128 (v7 patched)
	or	(0x3415:16), 128
	; calr AccPatch_ScanSequenceToEnd (v7 displacement)
	calr	AccPatch_ScanSequenceToEnd
	ret



AccPatch_InitByteStub:
	push	xiz
	calr	AccPat_InitWorkAreaFromSlot
	pop	xiz
	ret

AccPat_InitWorkAreaFromSlot:
	push	xwa
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	xwa, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xwa
	pop	xwa
	calr	AccPatch_InitFromIndex
	ret
AccPatch_CopyDefaultsToSlot:
	push xiy
	push xwa
	push xbc
	ld a, (xiy + 12)
	pushw wa
	ld wa, (xiy + 16)
	pushw wa
	push xiy
	add xiy, 0xc
	ld xix, AccPatch_DefaultSlotData
	ld xbc, 0x54
	push xiy
	push xix
	pop xiy
	pop xix
	ldir85
	pop xiy
	popw wa
	ld bc, wa
	popw wa
	cp a, 7:i3
	jr nz, AccPatch_CopyDefaults_Done
	ld (xiy + 16), bc

AccPatch_CopyDefaults_Done:
	pop xbc
	pop xwa
	pop xiy
	calr AccPatch_ClearSlot13ByIndex
	ret

AccPatch_ClearSlot13ByIndex:
	push	xwa
	ld	a, 0:opc
	ld	w, (STYLE_COPY_SRC_SECTION:16)
	cp	w, 14
	jr	nz, AccPatch_ClearSlot13_Check0F
	ld	(xiy+13), a
AccPatch_ClearSlot13_Check0F:
	cp w, 0xf
	jr nz, AccPatch_ClearSlot13_Check14
	ld (xiy + 13), a

AccPatch_ClearSlot13_Check14:
	cp w, 0x14
	jr nz, AccPatch_ClearSlot13_Check15
	ld (xiy + 13), a

AccPatch_ClearSlot13_Check15:
	cp w, 0x15
	jr nz, AccPatch_ClearSlot13_Check1A
	ld (xiy + 13), a

AccPatch_ClearSlot13_Check1A:
	cp w, 0x1a
	jr nz, AccPatch_ClearSlot13_Check1B
	ld (xiy + 13), a

AccPatch_ClearSlot13_Check1B:
	cp w, 0x1b
	jr nz, AccPatch_ClearSlot13_Done
	ld (xiy + 13), a

AccPatch_ClearSlot13_Done:
	pop xwa
	ret

AccPatch_MiscByteData:
	calr	AccPatch_GetSlotAddr_Preserve
	calr	AccPatch_FreeAllChains
	calr	AccPatch_CopyDefaultsForInit
	calr	AccPatch_FillAllVoiceData
	or	(0x3415:16), 128
	calr	AccPatch_ScanToSequenceStart
	ret
AccPatch_FreeAllChains:
	ld hl, (xiy + 0:8)
	calr AccPatch_FreeChainEntries
	ld hl, (xiy + 4)
	calr AccPatch_FreeChainEntries
	ld hl, (xiy + 6)
	calr AccPatch_FreeChainEntries
	ld hl, (xiy + 8)
	calr AccPatch_FreeChainEntries
	ld hl, (xiy + 10)
	calr AccPatch_FreeChainEntries
	ret

AccPatch_FreeChainEntries:
	push xiy
	calr AccPatch_GetEntryAddr
	ld wa, (xix + 3)
	cp wa, 0xffff
	jr z, AccPatch_FreeChain_Done

AccPatch_FreeChainLoop:
	ld	hl, wa
	ldw	(xix+3), 65535
	calr	AccPatch_GetEntryAddr
	ldw	(xix+1), 65535
	and	(xix), 127
	incw	1, (STYLE_FREE_BLOCKS:16)
	ld	wa, (xix+3)
	cp	wa, 65535
	jr	z, AccPatch_FreeChain_Done
	jr	AccPatch_FreeChainLoop
AccPatch_FreeChain_Done:
	pop xiy
	ret

AccPatch_FillAllVoiceData:
	ld hl, (xiy + 0:8)
	calr AccPatch_FillEntryWithVoiceData
	ld hl, (xiy + 4)
	calr AccPatch_FillEntryWithVoiceData
	ld hl, (xiy + 6)
	calr AccPatch_FillEntryWithVoiceData
	ld hl, (xiy + 8)
	calr AccPatch_FillEntryWithVoiceData
	ld hl, (xiy + 10)
	calr AccPatch_FillEntryWithVoiceData
	ret

AccPatch_FillEntryWithVoiceData:
	push xiy
	pushw hl
	ld l, (xiy + 12)
	xor h, h
	ld xwa, 0:i3
	ld xbc, AccTone_LookupByProgram_Table
	ld	a, (xbc+hl)
	ld xbc, 0:i3
	ld b, (xiy + 13)
	inc 1, b
	mul wa, b
	popw hl
	calr AccPatch_GetEntryAddr
	add xix, 0x6
	ld l, 0x81:opc

AccPatch_FillVoice_Loop:
	ld (xix), l
	dec 1, wa
	inc 1, xix
	cp wa, 0:i3
	jr nz, AccPatch_FillVoice_Loop
	ld (xix), 0x83
	pop xiy
	ret

AccPatch_CopyDefaultsForInit:
	push xiy
	push xwa
	push xbc
	ld a, (xiy + 12)
	pushw wa
	ld wa, (xiy + 16)
	pushw wa
	push xiy
	add xiy, 0xc
	ld xix, AccPatch_DefaultSlotData
	ld xbc, 0x54
	push xiy
	push xix
	pop xiy
	pop xix
	ldir85
	pop xiy
	popw wa
	ld bc, wa
	popw wa
	cp a, 7:i3
	jr nz, AccPatch_CopyDefaults_InitDone
	ld (xiy + 16), bc

AccPatch_CopyDefaults_InitDone:
	pop xbc
	pop xwa
	pop xiy
	calr AccPatch_ClearSlot13BySlotIdx
	ret

AccPatch_DefaultSlotData:
	; The 84 bytes (0x54) AccPatch_CopyDefaultsForInit copies over slot + 12 with ldir; it then puts the
	; slot's old word +16 back when the slot's old byte +12 was 7.  Was decoded as `reti / normal / ld w, 128`
	; ... `jrl ov, 20480` ...  Field meanings are not established.
	.byte	0x07, 0x01, 0x20, 0x80, 0x58, 0x02
	.zero	14
	.byte	0x28, 0x00, 0x40, 0x00, 0x50, 0x06, 0x7f, 0x00	; +20..+51: four 8-byte entries of one shape
	.byte	0x00, 0x00, 0x0c, 0x00, 0x50, 0x06, 0x7f, 0x00
	.byte	0x38, 0x00, 0x74, 0x00, 0x50, 0x06, 0x7f, 0x00
	.byte	0x41, 0x00, 0x40, 0x00, 0x50, 0x06, 0x7f, 0x00
	.asciz	"    clear       "	; +52: the slot name
	.zero	15

AccPatch_ClearSlot13BySlotIdx:
	ld A, 0x00:opc
	cp	(STYLE_SECTION:16), 0x0e
	jr nz, .Lc_f5ec03
	ld (XIY+0x0d),A
AccPatch_ClearSlot13_Idx0F:
.Lc_f5ec03:
	cp	(STYLE_SECTION:16), 0x0f
	jr nz, .Lc_f5ec0d
	ld (XIY+0x0d),A
AccPatch_ClearSlot13_Idx14:
.Lc_f5ec0d:
	cp	(STYLE_SECTION:16), 0x14
	jr nz, .Lc_f5ec17
	ld (XIY+0x0d),A
AccPatch_ClearSlot13_Idx15:
.Lc_f5ec17:
	cp	(STYLE_SECTION:16), 0x15
	jr nz, .Lc_f5ec21
	ld (XIY+0x0d),A
AccPatch_ClearSlot13_Idx1A:
.Lc_f5ec21:
	cp	(STYLE_SECTION:16), 0x1a
	jr nz, .Lc_f5ec2b
	ld (XIY+0x0d),A
AccPatch_ClearSlot13_Idx1B:
.Lc_f5ec2b:
	cp	(STYLE_SECTION:16), 0x1b
	jr nz, AccPatch_ClearSlot13_IdxDone
	ld (XIY+0x0d),A
AccPatch_ClearSlot13_IdxDone:
	ret

AccPatch_SetVoiceAndInit:
	calr AccPatch_GetCurrentSlotAddr

	ld	a, (STYLE_SECTION_TIME_SIG:16)

	ld (xiy + 12), a

	push xiy

	calr AccPatch_InitAllSentinels

	pop xiy

	ld xhl, 0:i3

	ld	l, (STYLE_SECTION_TIME_SIG:16)

	sll l, 1

	xor h, h

	; add xhl, AccPatch_DefaultStyleByTimeSig (v7 patched)
	add	xhl, AccPatch_DefaultStyleByTimeSig
	ld wa, (xhl)

	ld (xiy + 16), wa

	; calr AccPatch_CheckConfigType (v7 displacement)
	calr	AccPatch_CheckConfigType
	; ordi8 0x34cd, 128 (v7 patched)
	or	(0x3415:16), 128
	ret



; AccPatch_DefaultStyleByTimeSig: The PANEL_STYLE pair {style number, style group} a section record gets at
;   +0x10 / +0x11 when it is set up for TIME SIGNATURE n (AccPatch_SetVoiceAndInit reads the word at
;   2 * STYLE_SECTION_TIME_SIG; time signatures in the order of RamInit_TimeSigPtrs); {0, 0} = none.  The last
;   four entries are beyond index 15.  Basis: readers + bytes (notes/kn5000-style-2026-10-31/README.md, rec +0x10).
AccPatch_DefaultStyleByTimeSig:
	.byte	0x00, 0x00	; 1/2
	.byte	0x58, 0x02	; 2/2
	.byte	0x08, 0x02	; 3/2
	.byte	0x18, 0x03	; 4/2
	.byte	0x00, 0x00	; 1/4
	.byte	0x00, 0x00	; 2/4
	.byte	0x09, 0x01	; 3/4
	.byte	0x58, 0x02	; 4/4
	.byte	0x00, 0x00	; 5/4
	.byte	0x08, 0x02	; 6/4
	.byte	0x00, 0x00	; 7/4
	.byte	0x18, 0x03	; 8/4
	.byte	0x00, 0x00	; 1/8
	.byte	0x00, 0x00	; 2/8
	.byte	0x09, 0x01	; 3/8
	.byte	0x58, 0x02	; 4/8
	.byte	0x00, 0x00	; (no time signature reaches it)
	.byte	0x08, 0x02	; (no time signature reaches it)
	.byte	0x00, 0x00	; (no time signature reaches it)
	.byte	0x18, 0x03	; (no time signature reaches it)

AccPatch_CheckConfigType:
	cp	(STYLE_SECTION_BEATS:16), 6
	jr	z, RhythmConfig_CheckAndSkip
	cp	(STYLE_SECTION_BEATS:16), 8
	jr	z, RhythmConfig_CheckAndSkip
	cp	(STYLE_SECTION_BEATS:16), 4
	jr	z, RhythmConfig_CheckAndSkip
	cp	(STYLE_SECTION_BEATS:16), 3
	jr	z, RhythmConfig_CheckAndSkip
	jr	AccPatch_CheckConfig_Done
RhythmConfig_CheckAndSkip:
	call RhythmConfig_ReturnStub

AccPatch_CheckConfig_Done:
	ret

AccPatch_InitAllSentinels:
	calr	AccPatch_ReadVoiceStride

	ld xwa, 0:i3

	ld	a, (STYLE_SECTION_BEATS:16)

	ld	b, (STYLE_SECTION_LAST_MEASURE:16)

	and b, 0x7

	inc 1, b

	mul wa, b

	ld c, a

	ld hl, (xiy + 0:8)

	calr	AccPatch_InitSlotSentinels

	ld hl, (xiy + 4)

	calr	AccPatch_InitSlotSentinels

	ld hl, (xiy + 6)

	calr	AccPatch_InitSlotSentinels

	ld hl, (xiy + 8)

	calr	AccPatch_InitSlotSentinels

	ld hl, (xiy + 10)

	calr	AccPatch_InitSlotSentinels

	ret



AccPatch_InitSlotSentinels:
	push xiy
	push c
	calr AccPatch_GetEntryAddr
	add xix, 0x6
	pop c
	ld b, c

AccPatch_WriteSentinel_Loop:
	ld (xix), 0x81
	inc 1, xix
	dec 1, b
	cp b, 0:i3
	jr nz, AccPatch_WriteSentinel_Loop
	ld (xix), 0x83
	pop xiy
	ret

AccPatch_ReadVoiceStride:
	ld	xhl, 0:i3
	ld	l, (STYLE_SECTION_TIME_SIG:16)
	ld	xbc, AccTone_LookupByProgram_Table
	add	xbc, xhl
	ld	a, (xbc)
	ld	(STYLE_SECTION_BEATS:16), a
	ret
RhythmProc_CheckRhythmEdit:
	cp (CURRENT_TITLE:16), 0xb4
	jr nz, RhythmProc_RhythmEdit_Ret
	calr RhythmProc_CheckVoiceChange
	calr RhythmProc_CheckConfigBits
RhythmProc_RhythmEdit_Ret:
	ret

RhythmProc_CheckVoiceChange:
	bit	1, (0x3416:16)
	jr z, .Lc_f5ed34
	and	(0x3416:16), 0xfd
	calr AccPatch_SetVoiceAndInit
RhythmProc_CheckVoiceUpdate:
.Lc_f5ed34:
	bit	0, (0x3416:16)
	jr z, RhythmProc_VoiceUpdate_Ret
	and	(0x3416:16), 0xfe
	calr RhythmProc_UpdateVoiceSentinels
RhythmProc_VoiceUpdate_Ret:
	ret

RhythmProc_UpdateVoiceSentinels:
	calr	AccPatch_GetCurrentSlotAddr
	ld	a, (STYLE_SECTION_LAST_MEASURE:16)
	and	a, 7
	ld	(xiy+13), a
	calr	AccPatch_InitAllSentinels
	ret
RhythmProc_CheckConfigBits:
	bit	0, (0x341a:16)
	jr	z, RhythmProc_ConfigBit1
	and	(0x341a:16), 254
	calr	AccPatch_GetCurrentSlotAddr
	and	(xiy+14), 240
	ld	a, (0x3431:16)
	and	a, 15
	or	(xiy+14), a
RhythmProc_ConfigBit1:
	bit	1, (0x341a:16)
	jr	z, RhythmProc_ConfigBit2
	and	(0x341a:16), 253
	calr	AccPatch_GetCurrentSlotAddr
	and	(xiy+14), 239
	bit	4, (0x3432:16)
	jr	z, RhythmProc_ConfigBit2
	or	(xiy+14), 16
RhythmProc_ConfigBit2:
	bit	2, (0x341a:16)
	jr	z, RhythmProc_ConfigBits_Done
	and	(0x341a:16), 251
	calr	AccPatch_GetCurrentSlotAddr
	and	(xiy+14), 159
	bit	5, (0x3432:16)
	jr	z, RhythmProc_ConfigBit2_SetBit6
	or	(xiy+14), 32
RhythmProc_ConfigBit2_SetBit6:
	bit	6, (0x3432:16)
	jr	z, RhythmProc_ConfigBits_Done
	or	(xiy+14), 64
RhythmProc_ConfigBits_Done:
	ret

AccPatch_RebuildChannelSlot:
	ld	a, (CMP_RECORD_PART:16)
	and A,0x1f
	cp a, 0:i3
	jr z, AccPatch_RebuildChannel_Done
	calr MapBitFlagsToChannelOffset
	ld	(0x3376:16), w
	ld C,W
	push C
	calr AccPatch_GetCurrentSlotAddr
	pop C
	ld	hl, (xiy+c)
	ld	(0x3385:16), hl
	calr	AccPatch_FreeChainEntries
	ld	xhl, 0:i3
	ld	l, (STYLE_SECTION_TIME_SIG:16)
	add	xhl, AccTone_LookupByProgram_Table
	ld	a, (xhl)
	ld	xhl, 0:i3
	ld	l, (STYLE_SECTION_LAST_MEASURE:16)
	and	l, 7
	inc	1, l
	mul	hl, a
	and	hl, 127
	ld	c, l
	ld	hl, (0x3385:16)
	calr	AccPatch_InitSlotSentinels
	calr	AccPatch_ComputeSeqPosition
	ld	(0x3546:16), 0
	calr	AccPatch_WriteRhythmInit
	bit	0, (ACC_RUN_FLAGS:16)
	jr	nz, AccPatch_RebuildChannel_Done
	or	(0x3415:16), 128
AccPatch_RebuildChannel_Done:
	ret

MapBitFlagsToChannelOffset:
	ld w, 0x0:opc
	bit 4, a
	jr nz, MapBitFlags_NullRet
	ld w, 0x4:opc
	bit 3, a
	jr nz, MapBitFlags_NullRet
	ld w, 0x6:opc
	bit 0, a
	jr nz, MapBitFlags_NullRet
	ld w, 0x8:opc
	bit 1, a
	jr nz, MapBitFlags_NullRet
	ld w, 0xa:opc

MapBitFlags_NullRet:
	ret

AccPatch_ComputeSeqPosition:
	ld	xwa, 0:i3
	ld	a, (12795:16)
	ld	c, (STYLE_SECTION_BEATS:16)
	mul	wa, c
	add	a, (12744:16)
	ld	l, a
	ld	a, (12743:16)
	add	a, 24
	cp	a, 96
	jr	lt, AccPatch_SeqPosition_Store
	inc	1, l
	ld	xwa, 0:i3
	ld	a, (STYLE_SECTION_BEATS:16)
	ld	c, (STYLE_SECTION_LAST_MEASURE:16)
	inc	1, c
	mul	wa, c
	cp	a, l
	jr	nz, AccPatch_SeqPosition_Store
	ld	l, 0:opc
AccPatch_SeqPosition_Store:
	ld	xbc, 0:i3
	ld	c, l
	ld	hl, (13189:16)
	ld	wa, 6:i3
	add	wa, bc
	ld	xhl, 0:i3
	ld	l, (13174:16)
	sll	l, 1
	add	xhl, AccPatch_SeqBaseAddrTable
	ld	xhl, (xhl)
	ld	(xhl), wa
	ld	xhl, 0:i3
	ld	l, (13174:16)
	sll	l, 1
	add	xhl, AccPatch_SeqPosition_Store_Data
	ld	xhl, (xhl)
	ld	wa, (13189:16)
	ld	(xhl), wa
	ret
AccPatch_SeqBaseAddrTable:
	.byte	0xcf, 0x31, 0x00, 0x00, 0xd1, 0x31, 0x00, 0x00
	.byte	0xd3, 0x31, 0x00, 0x00, 0xd5, 0x31, 0x00, 0x00
	.byte	0xd7, 0x31, 0x00, 0x00, 0xd9, 0x31, 0x00, 0x00
AccPatch_SeqPosition_Store_Data:
	.byte	0xdf, 0x31, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte	0xe3, 0x31, 0x00, 0x00, 0xe5, 0x31, 0x00, 0x00
	.byte	0xe7, 0x31, 0x00, 0x00, 0xe9, 0x31, 0x00, 0x00
AccPatch_WriteRhythmInit:
	.byte	0xc1, 0x76, 0x33, 0x27, 0xcf, 0xd8, 0x66, 0x30
	.byte	0xeb, 0xa8, 0xc1, 0x76, 0x33, 0x27, 0xeb, 0xc8
	.byte	0x41, 0xea, 0xf5, 0x00, 0x83, 0x21, 0xc1, 0x76
	.byte	0x33, 0x04, 0x1e, 0x44, 0x00, 0xf1, 0x76, 0x33
	.byte	0x04, 0xeb, 0xa8, 0xc1, 0x76, 0x33, 0x27, 0xdb
	.byte	0xee, 0x01, 0xeb, 0xc8, 0x51, 0xea, 0xf5, 0x00
	.byte 0xa3, 0x23, 0x9b, 0x04, 0x25, 0xbb, 0x06, 0x55
AccPatch_WriteRhythm_Done:
	ret

AccPatch_ChannelToParamTable:	.byte	0, 0, 0, 0, 0xd7, 0, 0xd4, 0, 0xd5, 0, 0xd6, 0, 0, 0, 0, 0
AccPatch_ChannelToRecordPtr:	.long	0, 0, 0x2bdc, 0x2cdc, 0x2ddc, 0x2edc	; v7: 0x2bf8 ...
AccPatch_WriteRhythmParams:
	calr AccPatch_FetchVolumeForChannel
	push_a
	ld xwa, 0:i3
	pop_a
	ld c, 0x0:opc

AccPatch_WriteRhythmParam_Loop:
	cp	c, 6:i3
	jr	z, AccPatch_WriteRhythmParam_Done	; -> 0xF5EF89
	push	c
	push	xwa
	push	c
	pushw	wa
	call	RhythmBuf_WriteByte
	inc	2, xsp
	pop	c
	sll	c, 1
	ld	xwa, AccPatch_RhythmParamDefaults
	ld	a, (xwa+c)
	push	c
	pushw	wa
	call	RhythmBuf_WriteByte
	inc	2, xsp
	pop	c
	inc	1, c
	ld	xwa, AccPatch_RhythmParamDefaults
	ld	a, (xwa+c)
	cp	c, 7:i3
	jr	nz, AccPatch_WriteRhythmParam_Push	; -> 0xF5EF7B
	ld	a, (13205:16)
AccPatch_WriteRhythmParam_Push:
	pushw wa
	call RhythmBuf_WriteByte
	inc 2, xsp
	pop xwa
	pop c
	inc 1, c
	jr AccPatch_WriteRhythmParam_Loop

AccPatch_WriteRhythmParam_Done:
	ret

AccPatch_RhythmParamDefaults:
	; (number, value) pairs the loop above reads and writes with RhythmBuf_WriteByte.  Was decoded
	; as `normal / nop / push sr / ld xwa, 0x40040003 / halt / jrl nc, 6`.
	.byte	1, 0, 2, 64, 3, 0, 4, 64, 5, 127, 6, 0

AccPatch_FetchVolumeForChannel:
	push xwa
	push xhl
	push xix
	push xiy
	calr AccPatch_GetCurrentSlotAddr
	ld xix, 0x22
	cp a, 0xd7
	jr z, ToneGen_FetchSelectRestore
	ld xix, 0x2a
	cp a, 0xd4
	jr z, ToneGen_FetchSelectRestore
	ld xix, 0x32
	cp a, 0xd5
	jr z, ToneGen_FetchSelectRestore
	ld xix, 0x3a
	cp a, 0xd6
	jr z, ToneGen_FetchSelectRestore
	ld a, 0x40:opc
	jr AccPatch_FetchVolume_Default

ToneGen_FetchSelectRestore:
	add xix, xiy
	ld a, (xix)

AccPatch_FetchVolume_Default:
	ld	(13205:16), a
	pop	xiy
	pop	xix
	pop	xhl
	pop	xwa
	ret
RhythmProc_CheckStyleSwitch:
	cp (CURRENT_TITLE:16), 0xb8
	jr z, RhythmProc_StyleSwitch_Call
	jr t, RhythmProc_StyleSwitch_Ret
RhythmProc_StyleSwitch_Call:
	call AccPat_DispatchNoteChange

RhythmProc_StyleSwitch_Ret:
	ret

RhythmProc_CheckRepeatFlag:
	cp (CURRENT_TITLE:16), 0xbd
	jr nz, RhythmProc_RepeatFlag_Ret
	bit	1, (0x341b:16)
	jr z, RhythmProc_RepeatFlag_Ret
	and	(0x341b:16), 0xfd
	ld XIY,RHYTHM_PATTERN_BUF_A
	add XIY,0x00000000
	add XIY,0x00000010
	ld A,(XIY)
	and A,0xfe
	bit	0, (0x341b:16)
	jr z, RhythmProc_RepeatFlag_Store
	or A,0x01
RhythmProc_RepeatFlag_Store:
	ld (xiy), a

RhythmProc_RepeatFlag_Ret:
	ret

RhythmProc_SavePrevState:
	ld a, (CURRENT_TITLE:16)
	ld	(0x346d:16), a
	ld	a, (CMP_RECORD_PART:16)
	and A,0x7f
	ld	(0x3458:16), a
	ld	a, (ACC_RUN_FLAGS:16)
	ld	(0x3549:16), a
	cp (CURRENT_MODE:16), 0x0e
	jr z, RhythmProc_SavePrevState_Done
	ld	(CMP_RECORD_PART:16), 0x00
RhythmProc_SavePrevState_Done:
	ret

AccPatch_CountAvailableSlots:
	ldw wa, 0xbe
	ldw de, 0x153
	xor iy, iy

AccPatch_CountSlots_Loop:
	ld hl, de
	calr AccPatch_GetEntryAddr
	bitm 7, (xix)
	jr z, AccPatch_CountSlots_Dec
	dec 1, wa

AccPatch_CountSlots_Dec:
	dec 1, de
	cp de, 0x95
	jr z, AccPatch_CountSlots_Store
	jr AccPatch_CountSlots_Loop

AccPatch_CountSlots_Store:
	ld	(STYLE_FREE_BLOCKS:16), wa
	ret
AccPatch_CountSlotsAlt_Body:
	ld	xix, (STYLE_SRC_IMAGE_PTR:16)
	push	xix
	ld	xix, 432128
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ldw	wa, 190
	ldw	de, 339
	xor	iy, iy
AccPatch_CountSlotsAlt_Loop:
	ld hl, de
	calr AccPatch_ResolveSlotAddr
	bitm 7, (xix)
	jr z, AccPatch_CountSlotsAlt_Dec
	dec 1, wa

AccPatch_CountSlotsAlt_Dec:
	dec 1, de
	cp de, 0x95
	jr z, AccPatch_CountSlotsAlt_Store
	jr AccPatch_CountSlotsAlt_Loop

AccPatch_CountSlotsAlt_Store:
	ld	(STYLE_FREE_BLOCKS:16), wa
	pop	xix
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ret
AccPatch_MiscDataBlock:
	ld	xwa, 100
	mul	xwa, (STYLE_FREE_BLOCKS:16)	; XWA, (0x3438) (unidasm; no llvm-mc spelling)
	ldw	hl, 190
	div	xwa, hl
	cp	a, 100
	jr	c, AccPatch_CountSlotsAlt_Body_Skip
	ld	a, 99:opc
AccPatch_CountSlotsAlt_Body_Skip:
	ld	(0x38f3:16), a
	ret
AccPatch_ProcessPartChanges:
	ld	a, (CMP_RECORD_PART:16)
	and	a, 31
	cp	a, 0:i3
	jr	nz, AccPatch_PartChanges_MapLookup
	ld	w, (13400:16)
	and	w, 31
	cp	w, 0:i3
	jr	z, AccPatch_PartChanges_NoNew
	push	xwa
	push	xhl
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	call	PartSelect_UpdateDisplayState
	pop	xiz
	pop	xiy
	pop	xix
	pop	xde
	pop	xbc
	pop	xhl
	pop	xwa
AccPatch_PartChanges_NoNew:
	jr AccPatch_PartChanges_CheckFlag

AccPatch_PartChanges_MapLookup:
	ld	a, (CMP_RECORD_PART:16)
	and	a, 31
	ld	xhl, 0:i3
	ld	l, a
	add	xhl, AccPatch_PartNumberTable
	ld	a, (xhl)
	ld	(PART_SELECT:16), a
	ld	e, a
	ld	a, (CMP_RECORD_PART:16)
	ld	w, (13400:16)
	and	a, 31
	and	w, 31
	cp	w, a
	jr	z, AccPatch_PartChanges_Update
	ld	a, e
	ld	e, 144:opc
	ld	d, 16:opc
	ld	w, 255:opc
	call	SwbtWr_QueuePostEvent
AccPatch_PartChanges_Update:
	calr AccPatch_SyncAllVoiceParams

AccPatch_PartChanges_CheckFlag:
	ld	a, (13400:16)
	bit	6, a
	jr	z, AccPatch_PartChanges_Done
	ld	w, (CMP_RECORD_PART:16)
	bit	5, w
	jr	z, AccPatch_PartChanges_Done
	call	AccPatch_ReadRepeatBit
	calr	AccPatch_UpdateAllChains
AccPatch_PartChanges_Done:
	ret

AccPatch_ReadRepeatBit:
	ld XIX,RHYTHM_PATTERN_BUF_A
	add XIX,0x00000000
	add XIX,0x00000010
	ld A,(XIX)
	bit 0x00,A
	jr nz, .Lc_f5f14e
	and	(0x341b:16), 0xfe
	jr t, AccPatch_SetRepeatBit_Done
AccPatch_SetRepeatBitOn:
.Lc_f5f14e:
	or	(0x341b:16), 0x01



AccPatch_SetRepeatBit_Done:
	ret

AccPatch_PartNumberTable:
; AccPatch_PartNumberTable -- 32 x u8, indexed by the one-hot selector
; (0x379b) & 0x1F.  ** RE-TYPED 2026-09-25 (lane accomp): was
; nop/rcf/scf/ccf/zcf/push_a mnemonics (data-as-code).  Read by
; AccPatch_PartChanges_MapLookup:
;     ld a,(0x379b) / and a,0x1f / ld l,a / add xhl, <this> / ld a,(xhl) /
;     ld (0x8d3a),a
; Only the five one-hot indices are non-zero: 1->0x10, 2->0x11, 4->0x12,
; 8->0x13, 16->0x14, i.e. it turns the selected bit into 0x10+bit.  32
; entries: pinned by `and a, 0x1f`, and the table ends exactly where
; AccPatch_UpdateAllChains begins.
; readers in v7 (address from the linked ELF): AccPatch_PartChanges_MapLookup 0xF5F0DB
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
	.byte 0x00, 0x10, 0x11, 0x00, 0x12, 0x00, 0x00, 0x00, 0x13, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

AccPatch_UpdateAllChains:
	calr AccPatch_GetCurrentSlotAddr
	calr AccPatch_UpdateChain_Rhythm
	calr AccPatch_UpdateChain_Bass
	calr AccPatch_UpdateChain_Acc1
	calr AccPatch_UpdateChain_Acc2
	calr AccPatch_UpdateChain_Acc3
	ret

; Curious thing I've just observed:
; The routines below are almost identical to each other...

AccPatch_UpdateChain_Rhythm:
	push XIY
	add XIY,0x00000020
	ld XIX,PANEL_PART_BASS
	ld A,(XIY+0x03)
	and A,0x01
	sll A, 0x06
	and (XIX+0x04),0xbf
	and (XIX+0x04),0xf7
	or (XIX+0x04),A
	ld B,A
	ld A,(XIY+0x01)
	and A,0x7f
	and (XIX+0x01),0x80
	or (XIX+0x01),A
	ld D,A
	ld	a, (xiy+0:8)
	and	(xix+0:8), 0
	or	(xix+0:8), a
	ld	e, a
	sll	b, 1
	ld	(13353:16), e
	ld	(13354:16), d
	or	(0x342a:16), b
	push	d
	push	e
	ld	a, d
	ld	d, 1:opc
	ld	w, 127:opc
	ld	e, 19:opc
	call	SwbtWr_QueuePostEvent
	pop	e
	push	e
	ld	a, e
	ld	d, 0:opc
	ld	w, 255:opc
	ld	e, 19:opc
	call	SwbtWr_QueuePostEvent
	pop e
	pop d
	ld	h, d
	ld	l, e
	ld	(PROGRAM_CHANGE_PART:16), 19
	call	PartCtrl_WriteProgramChange
	ld	xbc, 65366
	ld	(xbc+l), h
	ld	a, (xiy+3)
	sla	a, 6
	ld	d, 4:opc
	ld	w, 64:opc
	ld	e, 19:opc
	call	SwbtWr_QueuePostEvent
	pop	xiy
	ret
AccPatch_UpdateChain_Bass:
	push XIY
	add XIY,0x00000018
	ld XIX,PANEL_PART_DRUM
	ld A,(XIY+0x03)
	and A,0x01
	sll A, 0x06
	and (XIX+0x04),0xbf
	and (XIX+0x04),0xf7
	or (XIX+0x04),A
	ld B,A
	ld A,(XIY+0x01)
	and A,0x7f
	and (XIX+0x01),0x80
	or (XIX+0x01),A
	ld D,A
	ld	a, (xiy+0:8)
	or	a, 240
	and	(xix+0:8), 0
	or	(xix+0:8), a
	ld	e, a
	sll	b, 1
	ld	(13351:16), e
	ld	(13352:16), d
	or	(0x3428:16), b
	push	d
	push	e
	ld	a, d
	ld	d, 1:opc
	ld	w, 127:opc
	ld	e, 20:opc
	call	SwbtWr_QueuePostEvent
	pop	e
	push	e
	ld	a, e
	ld	d, 0:opc
	ld	w, 255:opc
	ld	e, 20:opc
	call	SwbtWr_QueuePostEvent
	pop e
	pop d
	ld	h, d
	ld	l, e
	ld	(PROGRAM_CHANGE_PART:16), 20
	call	PartCtrl_WriteProgramChange
	ld	xbc, 65386
	ld	(xbc+l), h
	ld	a, (xiy+3)
	sla	a, 6
	ld	d, 4:opc
	ld	w, 64:opc
	ld	e, 20:opc
	call	SwbtWr_QueuePostEvent
	pop	xiy
	ret
AccPatch_UpdateChain_Acc1:
	push XIY
	add XIY,0x00000028
	ld XIX,PANEL_PART_ACP1
	ld A,(XIY+0x03)
	and A,0x01
	sll A, 0x06
	and (XIX+0x04),0xbf
	and (XIX+0x04),0xf7
	or (XIX+0x04),A
	ld B,A
	ld A,(XIY+0x01)
	and A,0x7f
	and (XIX+0x01),0x80
	or (XIX+0x01),A
	ld D,A
	ld	a, (xiy+0:8)
	and	(xix+0:8), 0
	or	(xix+0:8), a
	ld	e, a
	sll	b, 1
	ld	(13355:16), e
	ld	(13356:16), d
	or	(0x342c:16), b
	push	d
	push	e
	ld	a, d
	ld	d, 1:opc
	ld	w, 127:opc
	ld	e, 16:opc
	call	SwbtWr_QueuePostEvent
	pop	e
	push	e
	ld	a, e
	ld	d, 0:opc
	ld	w, 255:opc
	ld	e, 16:opc
	call	SwbtWr_QueuePostEvent
	pop e
	pop d
	ld	h, d
	ld	l, e
	ld	(PROGRAM_CHANGE_PART:16), 16
	call	PartCtrl_WriteProgramChange
	ld	xbc, 65306
	ld	(xbc+l), h
	ld	a, (xiy+3)
	sla	a, 6
	ld	d, 4:opc
	ld	w, 64:opc
	ld	e, 16:opc
	call	SwbtWr_QueuePostEvent
	pop	xiy
	ret
AccPatch_UpdateChain_Acc2:
	push XIY
	add XIY,0x00000030
	ld XIX,PANEL_PART_ACP2
	ld A,(XIY+0x03)
	and A,0x01
	sll A, 0x06
	and (XIX+0x04),0xbf
	and (XIX+0x04),0xf7
	or (XIX+0x04),A
	ld B,A
	ld A,(XIY+0x01)
	and A,0x7f
	and (XIX+0x01),0x80
	or (XIX+0x01),A
	ld D,A
	ld	a, (xiy+0:8)
	and	(xix+0:8), 0
	or	(xix+0:8), a
	ld	e, a
	sll	b, 1
	ld	(13357:16), e
	ld	(13358:16), d
	or	(0x342e:16), b
	push	d
	push	e
	ld	a, d
	ld	d, 1:opc
	ld	w, 127:opc
	ld	e, 17:opc
	call	SwbtWr_QueuePostEvent
	pop	e
	push	e
	ld	a, e
	ld	d, 0:opc
	ld	w, 255:opc
	ld	e, 17:opc
	call	SwbtWr_QueuePostEvent
	pop e
	pop d
	ld	h, d
	ld	l, e
	ld	(PROGRAM_CHANGE_PART:16), 17
	call	PartCtrl_WriteProgramChange
	ld	xbc, 65326
	ld	(xbc+l), h
	ld	a, (xiy+3)
	sla	a, 6
	ld	d, 4:opc
	ld	w, 64:opc
	ld	e, 17:opc
	call	SwbtWr_QueuePostEvent
	pop	xiy
	ret
AccPatch_UpdateChain_Acc3:
	push XIY
	add XIY,0x00000038
	ld XIX,PANEL_PART_ACP3
	ld A,(XIY+0x03)
	and A,0x01
	sll A, 0x06
	and (XIX+0x04),0xbf
	and (XIX+0x04),0xf7
	or (XIX+0x04),A
	ld B,A
	ld A,(XIY+0x01)
	and A,0x7f
	and (XIX+0x01),0x80
	or (XIX+0x01),A
	ld D,A
	ld	a, (xiy+0:8)
	and	(xix+0:8), 0
	or	(xix+0:8), a
	ld	e, a
	sll	b, 1
	ld	(13359:16), e
	ld	(13360:16), d
	or	(0x3430:16), b
	push	d
	push	e
	ld	a, d
	ld	d, 1:opc
	ld	w, 127:opc
	ld	e, 18:opc
	push	xiy
	call	SwbtWr_QueuePostEvent
	pop	xiy
	pop	e
	push	e
	ld	a, e
	ld	d, 0:opc
	ld	w, 255:opc
	ld	e, 18:opc
	push	xiy
	call	SwbtWr_QueuePostEvent
	pop	xiy
	pop e
	pop d
	ld	h, d
	ld	l, e
	ld	(PROGRAM_CHANGE_PART:16), 18
	push	xiy
	call	PartCtrl_WriteProgramChange
	pop	xiy
	ld	xbc, 65346
	ld	(xbc+l), h
	ld	a, (xiy+3)
	sla	a, 6
	ld	d, 4:opc
	ld	w, 64:opc
	ld	e, 18:opc
	call	SwbtWr_QueuePostEvent
	pop	xiy
	ret
AccPatch_SyncAllVoiceParams:
	calr AccPatch_GetCurrentSlotAddr
	calr AccPatch_SyncVoice_Bass
	calr AccPatch_SyncVoice_Acc1
	calr AccPatch_SyncVoice_Acc2
	calr AccPatch_SyncVoice_Acc3
	calr AccPatch_SyncVoice_Drum
	ret

AccPatch_SyncVoice_Bass:
	push xiy
	add xiy, 0x20
	ld xix, PANEL_PART_BASS
	ld w, (xix + 0:8)
	and w, 0xff
	ld a, (xix + 1)
	and a, 0x7f
	bitm 6, (xix + 4)
	jr z, AccPatch_SyncBass_HasBank
	ld h, 0x40:opc
	sll h, 1
	or a, h

AccPatch_SyncBass_HasBank:
	ld	h, (13353:16)
	ld	l, (13354:16)
	cp	hl, wa
	jr	z, AccPatch_SyncBass_Done
	pushw	wa
	ld	(xiy+0:8), w
	ld	c, a
	and	c, 127
	ld	(xiy+1), c
	and	a, 128
	srl	a, 7
	ld	(xiy+3), a
	popw	wa
	ld	(13353:16), w
	ld	(13354:16), a
	ld	xix, 12641
	calr	AccPatch_LoadVoiceParams
AccPatch_SyncBass_Done:
	pop xiy
	ret

AccPatch_SyncVoice_Drum:
	push xiy
	add xiy, 0x18
	ld xix, PANEL_PART_DRUM
	ld w, (xix + 0:8)
	and w, 0xff
	and w, 0xf
	ld a, (xix + 1)
	and a, 0x7f
	bitm 6, (xix + 4)
	jr z, AccPatch_SyncDrum_HasBank
	ld h, 0x40:opc
	sll h, 1
	or a, h

AccPatch_SyncDrum_HasBank:
	ld	h, (13351:16)
	ld	l, (13352:16)
	cp	hl, wa
	jr	z, AccPatch_SyncDrum_Done
	pushw	wa
	ld	(xiy+0:8), w
	ld	c, a
	and	c, 127
	ld	(xiy+1), c
	and	a, 128
	srl	a, 7
	ld	(xiy+3), a
	popw	wa
	ld	(13351:16), w
	ld	(13352:16), a
	ld	xix, 12636
	calr	AccPatch_LoadVoiceParams
AccPatch_SyncDrum_Done:
	pop xiy
	ret

AccPatch_SyncVoice_Acc1:
	push xiy
	add xiy, 0x28
	ld xix, PANEL_PART_ACP1
	ld w, (xix + 0:8)
	and w, 0xff
	ld a, (xix + 1)
	and a, 0x7f
	bitm 6, (xix + 4)
	jr z, AccPatch_SyncAcc1_HasBank
	ld h, 0x40:opc
	sll h, 1
	or a, h

AccPatch_SyncAcc1_HasBank:
	ld	h, (13355:16)
	ld	l, (13356:16)
	cp	hl, wa
	jr	z, AccPatch_SyncAcc1_Done	; -> 0xF5F5A9
	pushw	wa
	ld	(xiy+0:8), w
	ld	c, a
	and	c, 127
	ld	(xiy+1), c
	and	a, 128
	srl	a, 7
	ld	(xiy+3), a
	popw	wa
	ld	(13355:16), w
	ld	(13356:16), a
	ld	xix, 12646
	calr	AccPatch_LoadVoiceParams
AccPatch_SyncAcc1_Done:
	pop xiy
	ret

AccPatch_SyncVoice_Acc2:
	push xiy
	add xiy, 0x30
	ld xix, PANEL_PART_ACP2
	ld w, (xix + 0:8)
	and w, 0xff
	ld a, (xix + 1)
	and a, 0x7f
	bitm 6, (xix + 4)
	jr z, AccPatch_SyncAcc2_HasBank
	ld h, 0x40:opc
	sll h, 1
	or a, h

AccPatch_SyncAcc2_HasBank:
	ld	h, (13357:16)
	ld	l, (13358:16)
	cp	hl, wa
	jr	z, AccPatch_SyncAcc2_Done
	pushw	wa
	ld	(xiy+0:8), w
	ld	c, a
	and	c, 127
	ld	(xiy+1), c
	and	a, 128
	srl	a, 7
	ld	(xiy+3), a
	popw	wa
	ld	(13357:16), w
	ld	(13358:16), a
	ld	xix, 12651
	calr	AccPatch_LoadVoiceParams
AccPatch_SyncAcc2_Done:
	pop xiy
	ret

AccPatch_SyncVoice_Acc3:
	push xiy
	add xiy, 0x38
	ld xix, PANEL_PART_ACP3
	ld w, (xix + 0:8)
	and w, 0xff
	ld a, (xix + 1)
	and a, 0x7f
	bitm 6, (xix + 4)
	jr z, AccPatch_SyncAcc3_HasBank
	ld h, 0x40:opc
	sll h, 1
	or a, h

AccPatch_SyncAcc3_HasBank:
	ld	h, (13359:16)
	ld	l, (13360:16)
	cp	hl, wa
	jr	z, AccPatch_SyncAcc3_Done
	pushw	wa
	ld	(xiy+0:8), w
	ld	c, a
	and	c, 127
	ld	(xiy+1), c
	and	a, 128
	srl	a, 7
	ld	(xiy+3), a
	popw	wa
	ld	(13359:16), w
	ld	(13360:16), a
	ld	xix, 12656
	calr	AccPatch_LoadVoiceParams
AccPatch_SyncAcc3_Done:
	pop xiy
	ret
AccPatch_LoadVoiceParams:
	ld	e, (xiy+0:8)
	ld	d, (xiy+1)
	ld	a, (xiy+2)
	ld	(13175:16), a
	ld	a, (xiy+3)
	ld	(13176:16), a
	ld	a, (xiy+4)
	ld	(13177:16), a
	calr	AccPatch_CallParamLookup
	ret
AccPatch_CallParamLookup:
	push	xix
	pushw	de
	pushdi_b	(13175)
	pushdi_b	(13176)
	pushdi_b	(13177)
	call	RhythmPart_CopyData_Tramp
	pop	(0x3379:16)
	pop	(0x3378:16)
	pop	(0x3377:16)
	popw	de
	pop	xix
	bit	7, e
	jr	z, AccPatch_StoreVoiceParams
	or	d, 16
	and	e, 127
AccPatch_StoreVoiceParams:
	ld	(xix), e
	ld	(xix+1), d
	ld	a, (13175:16)
	ld	(xix+2), a
	ld	a, (13176:16)
	ld	(xix+3), a
	ld	a, (13177:16)
	ld	(xix+4), a
	call	AccVoice_LoadAllChannelParams
	ret
AccPatch_ComplexDataBlock:
	ld	a, (CURRENT_MODE:16)
	cp	a, 14
	jr	nz, AccPatch_ComplexDataBlock_Return
	calr	AccPatch_CallParamLookup_Helper
AccPatch_ComplexDataBlock_Return:
	ret
AccPatch_CallParamLookup_Helper:
	ld	a, (SWBTWR_PAYLOAD_1:16)
	cp	a, 0:i3
	jr	nz, AccPatch_CallParamLookup_Skip
	cp	(SWBTWR_PAYLOAD_2:16), 128
	jr	nc, AccPatch_CallParamLookup_Skip
	cp	(SWBTWR_PAYLOAD_3:16), 0
	jr	z, AccPatch_CallParamLookup_Skip
	ld	a, (CURRENT_TITLE:16)
	cp	a, 180
	jr	nz, AccPatch_CallParamLookup_Skip
	ld	xiy, RHYTHM_PATTERN_BUF_A
	add	xiy, 0
	ld	a, (xiy+16)
	bit	0, a
	jr	nz, AccPatch_CallParamLookup_Skip
	call	Rhythm_LoadCurrentTimeSig
	ld	(13448:16), 7
AccPatch_CallParamLookup_Skip:
	ld	a, (SWBTWR_PAYLOAD_1:16)
	cp	a, 0:i3
	jr	nz, AccPatch_CallParamLookup_Return2
	cp	(SWBTWR_PAYLOAD_3:16), 0
	jr	z, AccPatch_CallParamLookup_Return2
	ld	a, (CURRENT_TITLE:16)
	cp	a, 184
	jr	nz, AccPatch_CallParamLookup_Return2
	call	CmpNcp_LatchPanelRhythmAsSource
	call	AccPatch_CallParamLookup_Helper7
	call	Rhythm_LoadCurrentTimeSig
AccPatch_CallParamLookup_Return2:
	ret
AccDemo_InitDone_Helper:
	calr	AccPatch_CallParamLookup_Helper2
	ret
AccPatch_EnsureStyleImageHeader:
	ld XIY,RHYTHM_PATTERN_BUF_A
	add XIY,0x00000000
	add XIY,0x00000000
	ld	a, (xiy+0:8)
	cp	a, 72
	jr	nz, AccPatch_EnsureStyleImageHeader_Skip2
	ld	a, (xiy+1)
	cp	a, 0:i3
	jr	nz, AccPatch_EnsureStyleImageHeader_Skip2
	ld	a, (xiy+2)
	cp	a, 75
	jr	nz, AccPatch_EnsureStyleImageHeader_Skip2
	jr	AccPatch_EnsureStyleImageHeader_Return3
AccPatch_EnsureStyleImageHeader_Skip2:
	call	AccDemo_Init_Wrap
AccPatch_EnsureStyleImageHeader_Return3:
	ret
AccPatch_CallParamLookup_Helper2:
	add	xiy, 0
	add	xiy, 0
	ld	a, (xiy+0:8)
	cp	a, 72
	jr	nz, AccPatch_EnsureStyleImageHeader_Skip
	ld	a, (xiy+1)
	cp	a, 0:i3
	jr	nz, AccPatch_EnsureStyleImageHeader_Skip
	ld	a, (xiy+2)
	cp	a, 75
	jr	nz, AccPatch_EnsureStyleImageHeader_Skip
	call	AccPatch_CallParamLookup_Helper3
	jrl	AccPatch_CallParamLookup_Return4
AccPatch_EnsureStyleImageHeader_Skip:
	cp	(xiy), 76
	jr	nz, AccPatch_CallParamLookup_Skip3
	cp	(xiy+1), 75
	jr	nz, AccPatch_CallParamLookup_Skip3
	cp	(xiy+2), 69
	jr	nz, AccPatch_CallParamLookup_Skip3
	call	AccPatch_CallParamLookup_Helper3
	call	AccPatch_CallParamLookup_Helper4
	jr	AccPatch_CallParamLookup_Return4
AccPatch_CallParamLookup_Skip3:
	ld	a, (xiy+0:8)
	cp	a, 71
	jr	nz, AccPatch_CallParamLookup_Skip4
	ld	a, (xiy+1)
	cp	a, 0:i3
	jr	nz, AccPatch_CallParamLookup_Skip4
	ld	a, (xiy+2)
	cp	a, 75
	jr	nz, AccPatch_CallParamLookup_Skip4
	call	AccPatch_CallParamLookup_Helper3
	call	AccPatch_CallParamLookup_Helper4
	jr	AccPatch_CallParamLookup_Return4
AccPatch_CallParamLookup_Skip4:
	ld	a, (xiy+0:8)
	cp	a, 70
	jr	nz, AccPatch_CallParamLookup_Skip5
	ld	a, (xiy+1)
	cp	a, 0:i3
	jr	nz, AccPatch_CallParamLookup_Skip5
	ld	a, (xiy+2)
	cp	a, 75
	jr	nz, AccPatch_CallParamLookup_Skip5
	jr	AccPatch_CallParamLookup_Join
AccPatch_CallParamLookup_Skip5:
	ld	a, (xiy+0:8)
	cp	a, 77
	jr	nz, AccPatch_CallParamLookup_Skip7
	ld	a, (xiy+1)
	cp	a, 75
	jr	nz, AccPatch_CallParamLookup_Skip7
	ld	a, (xiy+2)
	cp	a, 66
	jr	nz, AccPatch_CallParamLookup_Skip6
	jr	AccPatch_CallParamLookup_Join
AccPatch_CallParamLookup_Skip6:
	cp	a, 65
	jr	nz, AccPatch_CallParamLookup_Skip7
	jr	AccPatch_CallParamLookup_Join
AccPatch_CallParamLookup_Skip7:
	call	AccDemo_Init_Wrap
	jr	AccPatch_CallParamLookup_Return4
AccPatch_CallParamLookup_Join:
	call	AccPatch_VoiceAssignDataBlock
	jr	AccPatch_CallParamLookup_Return4
AccPatch_CallParamLookup_Return4:
	ret
AccPatch_CallParamLookup_Helper3:
	ret
AccPatch_CallParamLookup_Helper4:
	ld	xiy, RHYTHM_PATTERN_BUF_A
	add	xiy, 0
	add	xiy, 0
	ld	a, 72:opc
	ld	(xiy+0:8), a
	ld	a, 0:opc
	ld	(xiy+1), a
	ld	a, 75:opc
	ld	(xiy+2), a
	ret
	calr	AccPatch_GetCurrentSlotAddr
	calr	AccPatch_CopyDefaultsForInit
	calr	AccPatch_CallParamLookup_Helper5
	ret
AccPatch_CallParamLookup_Helper5:
	ld	hl, (xiy+0:8)
	calr	AccPatch_CallParamLookup_Helper6
	ld	hl, (xiy+4)
	calr	AccPatch_CallParamLookup_Helper6
	ld	hl, (xiy+6)
	calr	AccPatch_CallParamLookup_Helper6
	ld	hl, (xiy+8)
	calr	AccPatch_CallParamLookup_Helper6
	ld	hl, (xiy+10)
	calr	AccPatch_CallParamLookup_Helper6
	ret
AccPatch_CallParamLookup_Helper6:
	push	xiy
	calr	AccPatch_GetEntryAddr
	ldw	(xix+3), 65535
	pushw	hl
	ld	l, (xiy+12)
	xor	h, h
	ld	xwa, 0:i3
	ld	xbc, AccTone_LookupByProgram_Table
	ld	a, (xbc+hl)
	ld	xbc, 0:i3
	ld	b, (xiy+13)
	inc	1, b
	mul	wa, b
	popw	hl
	calr	AccPatch_GetEntryAddr
	add	xix, 6
	ld	l, 129:opc
AccPatch_CallParamLookup_Loop:
	ld	(xix), l
	dec	1, wa
	inc	1, xix
	cp	wa, 0:i3
	jr	nz, AccPatch_CallParamLookup_Loop
	ld	(xix), 131
	pop	xiy
	ret
AccPatch_FreeAllChains_Alt:
	ld hl, (xiy + 0:8)
	calr AccPatch_ClearLinkedListEntries
	ld hl, (xiy + 4)
	calr AccPatch_ClearLinkedListEntries
	ld hl, (xiy + 6)
	calr AccPatch_ClearLinkedListEntries
	ld hl, (xiy + 8)
	calr AccPatch_ClearLinkedListEntries
	ld hl, (xiy + 10)
	calr AccPatch_ClearLinkedListEntries
	ret

AccPatch_ClearLinkedListEntries:
	push xiy
	calr AccPatch_ResolveSlotAddr
	ld wa, (xix + 3)
	cp wa, 0xffff
	jr z, AccPatch_FreeChain_Alt_Done

AccPatch_FreeChainLoop_Alt:
	ld	hl, wa
	ldw	(xix+3), 65535
	calr	AccPatch_ResolveSlotAddr
	ldw	(xix+1), 65535
	and	(xix), 127
	incw	1, (STYLE_FREE_BLOCKS:16)
	ld	wa, (xix+3)
	cp	wa, 65535
	jr	z, AccPatch_FreeChain_Alt_Done
	jr	AccPatch_FreeChainLoop_Alt
AccPatch_FreeChain_Alt_Done:
	pop xiy
	ret

AccPatch_ResolveSlotAddr:
	cp	hl, 65535
	jr	z, AccPatch_ResolveSlotAddr_Ret
	pushw	hl
	pushw	hl
	ld	xhl, 0:i3
	popw	hl
	sll	xhl, 8
	ld	xix, (STYLE_SRC_IMAGE_PTR:16)
	add	xix, 5120
	add	xix, xhl
	popw	hl
AccPatch_ResolveSlotAddr_Ret:
	ret

AccPatch_FillAllSlots_Alt:
	ld hl, (xiy + 0:8)
	calr AccPatch_FillSlotWithVoiceData
	ld hl, (xiy + 4)
	calr AccPatch_FillSlotWithVoiceData
	ld hl, (xiy + 6)
	calr AccPatch_FillSlotWithVoiceData
	ld hl, (xiy + 8)
	calr AccPatch_FillSlotWithVoiceData
	ld hl, (xiy + 10)
	calr AccPatch_FillSlotWithVoiceData
	ret

AccPatch_FillSlotWithVoiceData:
	push xiy
	pushw hl
	ld l, (xiy + 12)
	xor h, h
	ld xwa, 0:i3
	ld xbc, AccTone_LookupByProgram_Table
	ld	a, (xbc+hl)
	ld xbc, 0:i3
	ld b, (xiy + 13)
	inc 1, b
	mul wa, b
	popw hl
	calr AccPatch_ResolveSlotAddr
	add xix, 0x6
	ld l, 0x81:opc

AccPatch_FillSlot_Alt_Loop:
	ld (xix), l
	dec 1, wa
	inc 1, xix
	cp wa, 0:i3
	jr nz, AccPatch_FillSlot_Alt_Loop
	ld (xix), 0x83
	pop xiy
	ret

AccPatch_ScanSequenceToEnd:
	calr AccPatch_InitSlotPointer_Alt

AccPatch_ScanSeq_Loop:
	calr	AccPatch_SeqReadByte_Alt
	cp	a, 131
	jr	z, AccPatch_ScanSeq_StorePosAndRet
	calr	AccPatch_SeqAdvance_Alt
	bit	0, (0x355e:16)
	jr	nz, AccPatch_ScanSeq_StorePosAndRet
	jr	AccPatch_ScanSeq_Loop
AccPatch_ScanSeq_StorePosAndRet:
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13646:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13648:16), wa
	ret
AccPatch_SeqReadByte_Alt:
	push xix

	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)

	calr AccPatch_ResolveSlotAddr

	ld	hl, (ACC_PATCH_CURSOR_OFFSET:16)

	ld	a, (xix+hl)

	pop xix

	ret



AccPatch_SeqAdvance_Alt:
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	cp	wa, 254
	jr	nz, AccPatch_SeqAdvance_Inc
	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)
	calr	AccPatch_ResolveSlotAddr
	ld	wa, (xix+3)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), wa
	cp	wa, 65535
	jr	nz, AccPatch_SeqAdvance_CheckLimit
	or	(0x355e:16), 1
AccPatch_SeqAdvance_CheckLimit:
	cp	wa, 340
	jr	lt, AccPatch_SeqAdvance_ResetBase
	or	(0x355e:16), 1
AccPatch_SeqAdvance_ResetBase:
	ld wa, 6:i3
	jr AccPatch_SeqAdvance_Store

AccPatch_SeqAdvance_Inc:
	inc 1, wa

AccPatch_SeqAdvance_Store:
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
	ret
AccPatch_InitSlotPointer_Alt:
	xor	xhl, xhl
	ld	l, (STYLE_COPY_SRC_SECTION:16)
	cp	l, 30
	jr	c, AccPatch_InitSlotAlt_Valid
	xor	l, l
AccPatch_InitSlotAlt_Valid:
	mul hl, 0x60

	add xhl, 0x60

	ld	xiy, (STYLE_SRC_IMAGE_PTR:16)

	add xiy, xhl

	ld	a, (CMP_RECORD_PART:16)

	calr MapBitFlagsToChannelOffset

	ld	hl, (xiy+w)

	ld	(ACC_PATCH_CURSOR_BLOCK:16), hl

	ldw	(ACC_PATCH_CURSOR_OFFSET:16), 6

	ret



; AccPatch_CmpRealTick: Per-tick entry of the Composer REALTIME RECORDING engine: a jump vector (`jr
;   AccPatch_SeqDispatch_Main`, 12 filler bytes, `jrl AccPatch_SeqAdvanceStep`) whose slot 0 runs the part-cursor
;   step: rescans when the record part 0x36FF changed, re-inits the tempo ring when stopped, runs and queues the
;   part's notes, then saves 0x36FF in 0x3562. Basis: callers + body -- its only caller is AccPatch_DetectModeChange
;   inside RhythmProc_CheckPlayMode, which runs only when CURRENT_TITLE = 181 (TT_CMREAL), from Seq_RhythmProcessor on
;   every sequencer tick.
AccPatch_CmpRealTick:
	jr AccPatch_SeqDispatch_Main
	.fill	12, 1, 0x90	; filler between the vector's two jumps
	jrl AccPatch_SeqAdvanceStep

AccPatch_SeqReadByte:
	push xix

	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)

	calr AccPatch_GetEntryAddr

	ld	hl, (ACC_PATCH_CURSOR_OFFSET:16)

	ld	a, (xix+hl)

	pop xix

	ret



AccPatch_SeqDispatch_Padding:
	nop
	nop

AccPatch_AdvanceSeqIndex:
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	cp WA,0x00fe
	jr nz, AccPatch_AdvSeq_Inc
	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)
	calr AccPatch_GetEntryAddr
	ld WA,(XIX+0x03)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), wa
	cp WA,0xffff
	jr nz, .Lc_f5fa4c
	or	(0x355e:16), 0x01
AccPatch_AdvSeq_CheckLimit:
.Lc_f5fa4c:
	cp WA,0x0154
	jr lt, AccPatch_AdvSeq_ResetBase
	or	(0x355e:16), 0x01
AccPatch_AdvSeq_ResetBase:
	ld wa, 6:i3
	jr AccPatch_AdvSeq_Store

AccPatch_AdvSeq_Inc:
	inc 1, wa

AccPatch_AdvSeq_Store:
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
	ret
AccPatch_AdvSeq_Padding:
	nop
	nop

AccPatch_SeqDispatch_Main:
	ld	a, (CMP_RECORD_PART:16)
	cp	a, (13638:16)
	jr	z, AccPatch_SeqDispatch_CheckEmpty
	calr	AccPatch_ScanToSequenceStart
	calr	AccPatch_InitAndLoadSequence
AccPatch_SeqDispatch_CheckEmpty:
	ld	a, (CMP_RECORD_PART:16)
	and	a, 31
	cp	a, 0:i3
	jr	nz, AccPatch_SeqDispatch_CheckPlaying
	jrl	AccPatch_SyncStateAndReturn
AccPatch_SeqDispatch_CheckPlaying:
	bit	0, (ACC_RUN_FLAGS:16)
	jr	nz, AccPatch_SeqDispatch_CheckStarted
	call	TempoRingBuf_ReInitAndRet
	jrl	AccPatch_SyncStateAndReturn
AccPatch_SeqDispatch_CheckStarted:
	bit	0, (0x3549:16)
	jr	nz, AccPatch_SeqDispatch_ProcessFlags
	calr	AccPatch_ResetSeqCounters
	calr	AccPatch_InitCurrentSlotPointer
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(0x354a:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(0x354c:16), wa
AccPatch_SeqDispatch_ProcessFlags:
	calr	AccPatch_ReadModeFlags
	ld	a, (13335:16)
	and	a, 12
	cp	a, 0:i3
	jr	nz, AccPatch_SeqDispatch_ModeChange
	ld	a, (13636:16)
	and	a, 12
	cp	a, 0:i3
	jr	z, AccPatch_SeqDispatch_RunNotes
AccPatch_SeqDispatch_ModeChange:
	calr AccPatch_UpdateSequenceState
	jr AccPatch_SyncStateAndReturn
AccPatch_SeqDispatch_RunNotes:
	call	AccPatch_CheckEmpty
	cp	wa, 0:i3
	jr	z, AccPatch_SyncStateAndReturn
	ldw	(13650:16), 0
	ldw	(13654:16), 0
	ld	(13639:16), 0
	calr	AccPatch_EventDispatch_Nop
	cpw	(13650:16), 0
	jr	z, AccPatch_SeqDispatch_CheckQueued
	ld	wa, (13642:16)
	ld	(13894:16), wa
	ld	wa, (13644:16)
	ld	(13896:16), wa
	calr	AccPatch_InitSlotAndCopyData
	calr	AccPatch_AdvancePlayPos
	calr	AccPatch_AdvanceAllSteps
	ldw	(13650:16), 0
AccPatch_SeqDispatch_CheckQueued:
	cpw	(13654:16), 0
	jr	z, AccPatch_SyncStateAndReturn
	calr	AccPatch_DispatchQueuedNotes
AccPatch_SyncStateAndReturn:
	ld	a, (CMP_RECORD_PART:16)
	ld	(13638:16), a
	ret
AccPatch_SeqDispatch_MiscData:
	.byte	0x00, 0x00, 0xc1, 0x17, 0x34, 0x3e, 0x08, 0x0e
	.byte	0xc1, 0x17, 0x34, 0x3c, 0xf7, 0x1d, 0x1b, 0xf7
	.byte 0xf5, 0x0e
AccPatch_ReadModeFlags:
	ld	a, (0x3417:16)
	and A,0xf3
	ld	(0x3417:16), a
	cp (ACTIVE_TITLE:16), 0xb5
	jr z, .Lc_f5fb46
	jr t, AccPatch_SetFlagExit
AccPatch_ReadModeFlags_Active:
.Lc_f5fb46:
	ld xwa, (PANEL_SW_HELD_UP:24)
	or	xwa, (PANEL_SW_HELD_DOWN:24)
	ld	(0x11d0:16), xwa
	ld	xwa, (PANEL_SW_HELD_DOWN:24)
	ld	(0x3928:16), xwa
	ld	xwa, (0x11d0:16)
	and	xwa, 512
	cp	xwa, 0
	jr	z, AccPatch_ReadModeFlags_Check400
	ld	xwa, (0x3928:16)
	and	xwa, 512
	cp	xwa, 0
	jr	nz, AccPatch_ReadModeFlags_Check400
	ld	a, (0x3417:16)
	or	a, 4
	ld	(0x3417:16), a
AccPatch_ReadModeFlags_Check400:
	ld	xwa, (4560:16)
	and	xwa, 1024
	cp	xwa, 0
	jr	z, AccPatch_SetFlagExit
	ld	xwa, (14632:16)
	and	xwa, 1024
	cp	xwa, 0
	jr	nz, AccPatch_SetFlagExit
	ld	a, (13335:16)
	or	a, 8
	ld	(13335:16), a
AccPatch_SetFlagExit:
	ret

AccPatch_ScanSeq_PaddingByte:
	ret

AccPatch_ScanToSequenceStart:
	calr AccPatch_InitCurrentSlotPointer

AccPatch_ScanSeq_ReadLoop:
	calr	AccPatch_SeqReadByte
	cp	a, 131
	jr	z, AccPatch_ScanSeq_StorePosition
	calr	AccPatch_AdvanceSeqIndex
	bit	0, (0x355e:16)
	jr	nz, AccPatch_ScanSeq_StorePosition
	jr	AccPatch_ScanSeq_ReadLoop
AccPatch_ScanSeq_StorePosition:
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13646:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13648:16), wa
	ret
AccPatch_ScanSeq_PaddingWord:
	nop
	nop

AccPatch_InitAndLoadSequence:
	ld	xhl, 13666
	ldw	bc, 8
AccPatch_InitSeq_ClearLoop:
	ldw	(xhl), 0
	add	hl, 6
	djnz16	bc, AccPatch_InitSeq_ClearLoop
	ei	6
	bit	0, (0x3592:16)
	jr	nz, AccPatch_InitSeq_LoadTempo
	call	TempoRingBuf_ReInitAndRet
AccPatch_InitSeq_LoadTempo:
	ld	a, (ACC_SECTION_BAR:16)
	ld	c, (ACC_BEAT:16)
	ei	0
	and	(0x3592:16), 254
	ld	b, (STYLE_SECTION_BEATS:16)
	mul	wa, b
	add	c, a
	xor	b, b
	pushw	bc
	calr	AccPatch_InitCurrentSlotPointer
	popw	bc
	cp	bc, 0:i3
	jr	z, AccPatch_InitSeq_AdvDone
AccPatch_InitSeq_AdvLoop:
	pushw bc
	calr AccPatch_ScanToSequenceEnd
	popw bc
	djnz16 bc, AccPatch_InitSeq_AdvLoop

AccPatch_InitSeq_AdvDone:
	ret

AccPatch_InitSeq_Padding:
	nop
	nop

AccPatch_ResetSeqCounters:
	ld	xhl, 13666
	ldw	bc, 8
AccPatch_ResetSeqCounters_Loop:
	ldw	(xhl), 0
	add	hl, 6
	djnz16	bc, AccPatch_ResetSeqCounters_Loop
	ei	6
	ld	a, (ACC_SECTION_BAR:16)
	ld	c, (ACC_BEAT:16)
	ei	0
	and	(0x3592:16), 254
	ld	b, (STYLE_SECTION_BEATS:16)
	mul	wa, b
	add	c, a
	xor	b, b
	pushw	bc
	call	AccPatch_InitCurrentSlotPointer
	popw	bc
	cp	bc, 0:i3
	jr	z, AccPatch_ResetSeqCounters_Done
AccPatch_ResetSeqCounters_AdvLoop:
	pushw bc
	calr AccPatch_ScanToSequenceEnd
	popw bc
	djnz16 bc, AccPatch_ResetSeqCounters_AdvLoop

AccPatch_ResetSeqCounters_Done:
	ret

AccPatch_ResetSeqCounters_AdvLoop_Pad:
	nop
	nop

AccPatch_ScanToSequenceEnd:
.Lc_f5fc75:
	calr AccPatch_SeqReadByte
	cp A,0x81
	jr z, .Lc_f5fc88
	calr AccPatch_AdvanceSeqIndex
	bit	0, (0x355e:16)
	jr nz, AccPatch_ScanDone
	jr t, .Lc_f5fc75
AccPatch_ScanSeqEnd_HandleMarker:
.Lc_f5fc88:
	calr AccPatch_AdvanceSeqIndex
	bit	0, (0x355e:16)
	jr nz, AccPatch_ScanDone
	calr AccPatch_SeqReadByte
	cp A,0x83
	jr nz, AccPatch_ScanDone
	calr AccPatch_MarkAllSlotsActive
AccPatch_ScanDone:
	ret

AccPatch_ScanDone_Pad:
	nop
	nop

AccPatch_MarkAllSlotsActive:
	ld	xhl, 13666
AccPatch_MarkSlots_Loop:
	bitm 7, (xhl)
	jr z, AccPatch_MarkSlots_Next
	ormi8 (xhl + 1), 0x80

AccPatch_MarkSlots_Next:
	add	xhl, 6
	cp	xhl, 13714
	jr	c, AccPatch_MarkSlots_Loop
	calr	AccPatch_InitCurrentSlotPointer
	ret
AccPatch_UpdateSequenceState:
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13602:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13604:16), wa
	ei	6
	ld	a, (ACC_SECTION_BAR:16)
	ld	(13633:16), a
	ld	wa, (ACC_CLOCK:16)
	ld	(13902:16), wa
	ei	0
	ld	a, (13335:16)
	ld	w, (13636:16)
	bit	2, a
	jr	nz, AccPatch_UpdateSeqState_CheckXor
	bit	2, w
	jr	nz, AccPatch_UpdateSeqState_CheckXor
	jr	AccPatch_UpdateSeqState_CheckBit4
AccPatch_UpdateSeqState_CheckXor:
	ld	c, a
	xor	c, w
	and	a, c
	cp	a, 0:i3
	jr	z, AccPatch_UpdateSeqState_AndCheck
	calr	AccPatch_SeekToPosition
	or	(0x3545:16), 1
	jr	AccPatch_LoadNextSequencePointers
AccPatch_UpdateSeqState_AndCheck:
	and w, c
	cp w, 0:i3
	jr z, AccPatch_UpdateSeqState_ResumeSeq
	calr AccPatch_InitAndLoadSequence
	jr AccPatch_UpdateSeqState_CheckBit3

AccPatch_UpdateSeqState_ResumeSeq:
	calr AccPatch_ResumeSequencePlayback
	jr AccPatch_LoadNextSequencePointers

AccPatch_UpdateSeqState_CheckBit4:
	bit	4, (CMP_RECORD_PART:16)
	jr	z, AccPatch_LoadNextSequencePointers
	ld	a, (0x34a0:16)
	ld	(0x3543:16), a
	bit	3, (0x3417:16)
	jr	z, AccPatch_UpdateSeqState_ClearBit7
	bit	7, (0x34a0:16)
	jr	nz, AccPatch_UpdateSeqState_ScanNoteOff
	calr	AccPatch_ClearAndScanForNote
	jr	AccPatch_UpdateSeqState_AfterScan
AccPatch_UpdateSeqState_ScanNoteOff:
	calr AccPatch_ScanForNoteOff

AccPatch_UpdateSeqState_AfterScan:
	jr AccPatch_UpdateSeqState_CompareBits

AccPatch_UpdateSeqState_ClearBit7:
	; anddi8 (0x3558), 127 (v7 patched)
	and	(0x34a0:16), 127
AccPatch_UpdateSeqState_CompareBits:
	ld	a, (13472:16)
	ld	c, (13635:16)
	bit	7, a
	jr	z, AccPatch_UpdateSeqState_CheckC7
	bit	7, c
	jr	nz, AccPatch_UpdateSeqState_BothSet
	calr	AccPatch_SeekToPosition
	jr	AccPatch_LoadNextSequencePointers
AccPatch_UpdateSeqState_CheckC7:
	bit 7, c
	jr z, AccPatch_LoadNextSequencePointers
	calr AccPatch_InitAndLoadSequence
	jr AccPatch_UpdateSeqState_CheckBit3

AccPatch_UpdateSeqState_BothSet:
	calr AccPatch_PrepareAndProcessEvents

AccPatch_LoadNextSequencePointers:
	ld	wa, (13602:16)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), wa
	ld	wa, (13604:16)
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
AccPatch_UpdateSeqState_CheckBit3:
	bit	3, (0x3417:16)
	jr	nz, AccPatch_UpdateSeqState_StoreFlags
	bit	3, (0x3544:16)
	jr	z, AccPatch_UpdateSeqState_StoreFlags
	calr	AccPatch_InitAndLoadSequence
AccPatch_UpdateSeqState_StoreFlags:
	ld	a, (0x3417:16)
	ld	(0x3544:16), a
	and	(0x3543:16), 253
	bit	0, (0x3543:16)
	jr	z, AccPatch_UpdateSeqState_Return
	or	(0x3543:16), 2
AccPatch_UpdateSeqState_Return:
	ret

AccPatch_UpdateSeqState_StoreFlags_Pad:
	nop
	nop

AccPatch_ClearAndScanForNote:
	; anddi8 (0x3558), 127 (v7 patched)
	and	(0x34a0:16), 127
AccPatch_ScanForActiveNote:
	call	AccPatch_CheckEmpty
	cp	wa, 0:i3
	jr	z, AccPatch_ScanNote_Done
	ld	bc, 1:i3
	calr	TempoRingBuf_SkipBytes
	ld	w, a
	and	w, 240
	cp	w, 144
	jr	nz, AccPatch_ScanNote_Continue
	ld	bc, 2:i3
	calr	TempoRingBuf_SkipBytes
	ld	l, a
	push	l
	ld	bc, 1:i3
	calr	TempoRingBuf_SkipBytes
	pop	l
	cp	a, 0:i3
	jr	z, AccPatch_ScanNote_Continue
	or	l, 128
	ld	(13472:16), l
	call	TempoRingBuf_ReInitAndRet
AccPatch_ScanNote_Continue:
	jr AccPatch_ScanForActiveNote

AccPatch_ScanNote_Done:
	ret

TempoRingBuf_SkipBytes:
	cp bc, 0:i3
	jr z, TempoRingBuf_SkipBytes_Done
	pushw bc
	call TempoRingBuf_ReadByteToA
	popw bc
	dec 1, bc
	jr TempoRingBuf_SkipBytes

TempoRingBuf_SkipBytes_Done:
	ret

AccPatch_ScanForNoteOff:
	call	AccPatch_CheckEmpty
	cp	wa, 0:i3
	jr	z, AccPatch_ScanForNoteOff_Done
	ld	bc, 1:i3
	calr	TempoRingBuf_SkipBytes
	ld	w, a
	and	w, 240
	cp	w, 144
	jr	nz, AccPatch_ErrorExit
	ld	bc, 2:i3
	calr	TempoRingBuf_SkipBytes
	ld	l, a
	ld	h, (0x34a0:16)
	and	h, 127
	cp	h, l
	jr	nz, AccPatch_ErrorExit
	ld	bc, 1:i3
	calr	TempoRingBuf_SkipBytes
	cp	a, 0:i3
	jr	nz, AccPatch_ErrorExit
	and	(0x34a0:16), 127
	call	TempoRingBuf_ReInitAndRet
AccPatch_ErrorExit:
	jr AccPatch_ScanForNoteOff

AccPatch_ScanForNoteOff_Done:
	ret

AccPatch_SeekToPosition:
	calr	AccPatch_SeekForwardSteps
	ld	a, (13902:16)
	ld	(13888:16), a
	calr	AccPatch_ParseSequenceHeader
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13606:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13608:16), wa
	ret
AccPatch_SeekForwardSteps:
	ld	a, (13633:16)
	ld	c, (13903:16)
	ld	b, (STYLE_SECTION_BEATS:16)
	mul	wa, b
	add	c, a
	xor	b, b
	pushw	bc
	calr	AccPatch_InitCurrentSlotPointer
	popw	bc
	cp	bc, 0:i3
	jr	z, AccPatch_SeekFwd_Done
AccPatch_SeekFwd_AdvLoop:
	pushw bc
	calr AccPatch_ScanToSequenceEnd
	popw bc
	djnz16 bc, AccPatch_SeekFwd_AdvLoop

AccPatch_SeekFwd_Done:
	ret

AccPatch_SeekFwd_AdvLoop_Pad:
	nop
	nop

AccPatch_ParseSequenceHeader:
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(0x3642:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(0x3644:16), wa
	calr AccPatch_SeqReadByte
	cp A,0x81
	jr z, AccPatch_ParseHdr_RestorePos
	cp A,0x83
	jr nz, .Lc_f5fe95
	or	(0x355e:16), 0x02
	jr t, AccPatch_ParseHdr_Return
AccPatch_ParseHdr_AdvanceAndCompare:
.Lc_f5fe95:
	calr AccPatch_AdvanceSeqIndex
	calr AccPatch_SeqReadByte
	cp	a, (0x3640:16)
	jr	ugt, AccPatch_ParseHdr_RestorePos
AccPatch_ParseHdr_AdvanceAndRead:
	calr	AccPatch_AdvanceSeqIndex
	calr	AccPatch_SeqReadByte
	bit	0, (0x355e:16)
	jr	z, AccPatch_ParseHdr_CheckBit7
	jr	AccPatch_ParseHdr_Return
AccPatch_ParseHdr_CheckBit7:
	bit 7, a
	jr z, AccPatch_ParseHdr_AdvanceAndRead
	jr AccPatch_ParseSequenceHeader

AccPatch_ParseHdr_RestorePos:
	ld	wa, (13890:16)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), wa
	ld	wa, (13892:16)
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
AccPatch_ParseHdr_Return:
	ret

AccPatch_ParseHdr_RestorePos_Pad:
	nop
	nop

AccPatch_ResumeSequencePlayback:
	and	(0x3545:16), 0xfe
	calr AccPatch_PrepareSequencePlayback
	ld	wa, (0x3526:16)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), wa
	ld	wa, (0x3528:16)
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
	ldw	(0x3552:16), 0x0000
AccPatch_ResumeSeq_ComparePos:
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	cp	wa, (0x352a:16)
	jr	nz, AccPatch_ResumeSeq_ReadByte
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	cp	wa, (0x352c:16)
	jr	nz, AccPatch_ResumeSeq_ReadByte
	calr	AccPatch_CheckSequenceChanged
	jrl	AccPatch_ResumeSeq_Return
AccPatch_ResumeSeq_ReadByte:
	calr AccPatch_SeqReadByte
	cp a, 0x90
	jr z, AccPatch_ResumeSeq_Skip6
	cp a, 0x91
	jr z, AccPatch_ResumeSeq_Skip8
	cp a, 0x92
	jr z, AccPatch_ResumeSeq_Skip6
	cp a, 0x81
	jr z, AccPatch_ResumeSeq_HandleMarker
	and a, 0xf0
	cp a, 0xd0
	jr z, AccPatch_ResumeSeq_Skip3
	calr AccPatch_ProcessSeqEvt_RetNop
	jr AccPatch_ResumeSeq_Return

AccPatch_ResumeSeq_Skip6:
	ld bc, 6:i3
	jr AccPatch_ResumeSeq_AddAndAdvance

AccPatch_ResumeSeq_Skip8:
	ldw bc, 0x8
	jr AccPatch_ResumeSeq_AddAndAdvance

AccPatch_ResumeSeq_Skip3:
	ld bc, 3:i3

AccPatch_ResumeSeq_AddAndAdvance:
	; adddm16 0x360a, xbc (v7 patched)
	add	(0x3552:16), bc
AccPatch_ResumeSeq_AdvLoop:
	calr AccPatch_AdvanceSeqIndex
	djnz16 bc, AccPatch_ResumeSeq_AdvLoop
	jr AccPatch_ResumeSeq_ComparePos

AccPatch_ResumeSeq_HandleMarker:
	calr	AccPatch_CheckSequenceChanged
	calr	AccPatch_AdvanceSeqIndex
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13606:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13608:16), wa
	calr	AccPatch_SeqReadByte
	cp	a, 131
	jr	z, AccPatch_ResumeSeq_InitSlot
	cpw	(13650:16), 0
	jr	z, AccPatch_ResumeSeq_LoopBack
	calr	AccPatch_PrepareSequencePlayback
	ldw	(13650:16), 0
AccPatch_ResumeSeq_LoopBack:
	jrl AccPatch_ResumeSeq_ComparePos

AccPatch_ResumeSeq_InitSlot:
	calr	AccPatch_InitCurrentSlotPointer
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13606:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13608:16), wa
AccPatch_ResumeSeq_Return:
	ret

AccPatch_ResumeSeq_InitSlot_Pad:
	nop
	nop

AccPatch_PrepareSequencePlayback:
	calr	AccPatch_SeekForwardSteps
	ld	a, (13902:16)
	ld	(13888:16), a
	calr	AccPatch_ParseSequenceHeader
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13610:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13612:16), wa
	ret
AccPatch_CheckSequenceChanged:
	cpw	(0x3552:16), 0x0000
	jr z, AccPatch_CheckChanged_Return
	ld	wa, (0x3526:16)
	ld	(0x35a2:16), wa
	ld	wa, (0x3528:16)
	ld	(0x35a8:16), wa
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(0x35a0:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(0x35a6:16), wa
	ld	wa, (0x35a2:16)
	cp	wa, (0x35a0:16)
	jr	nz, AccPatch_CheckChanged_DoCopy
	ld	wa, (0x35a8:16)
	cp	wa, (0x35a6:16)
	jr	nz, AccPatch_CheckChanged_DoCopy
	jr	AccPatch_CheckChanged_Return
AccPatch_CheckChanged_DoCopy:
	calr	AccPatch_CopySequenceEntry
	calr	AccPatch_UpdateEntryFromTable
	ld	wa, (13606:16)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), wa
	ld	wa, (13608:16)
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
AccPatch_CheckChanged_Return:
	ret

AccPatch_CheckChanged_DoCopy_Pad:
	nop
	nop

AccPatch_CopySequenceEntry:
	ld	de, (0x354e:16)
	ld	wa, (0x3550:16)
	ld	(0x35aa:16), wa
	ld	hl, (0x35a0:16)
	calr AccPatch_GetEntryAddr
	ld	(0x3598:16), xix
	ld	hl, (0x35a2:16)
	calr AccPatch_GetEntryAddr
	ld	(0x3594:16), xix
	calr AccPatch_SetupBlockCopyDispatch
	dec 1,IX
	ld	(0x364c:16), ix
	ld	wa, (0x35a2:16)
	cp	wa, (0x354e:16)
	jr	z, AccPatch_CopyEntry_Store
	incw	1, (STYLE_FREE_BLOCKS:16)
	ld	hl, (0x35a2:16)
	calr	AccPatch_GetEntryAddr
	ld	wa, (xix+3)
	ldw	(xix+3), 65535
	ld	hl, wa
	calr	AccPatch_GetEntryAddr
	and	(xix), 127
	ldw	(xix+1), 65535
AccPatch_CopyEntry_Store:
	ld	wa, (13730:16)
	ld	(13646:16), wa
	ld	wa, (13900:16)
	ld	(13648:16), wa
	ret
AccPatch_CopyEntry_Store_Pad:
	nop
	nop

AccPatch_UpdateEntryFromTable:
	calr AccPatch_LoadTablePointers
	ld DE,(XIX)
	ld HL,(XIY)
	pushw de
	pushw hl
	calr AccPatch_GetEntryAddr
	popw hl
	popw de
	cp	hl, (0x3526:16)
	jr	z, AccPatch_UpdateEntry_CheckDE
	cpw	(xix+1), 65535
	jr	z, AccPatch_NullRet
	calr	AccPatch_AdjustTableEntryPos
	jr	AccPatch_NullRet
AccPatch_UpdateEntry_CheckDE:
	cp	de, (0x3528:16)
	jr	nc, AccPatch_UpdateEntry_AdjustOffset
	jr	AccPatch_NullRet
AccPatch_UpdateEntry_AdjustOffset:
	sub	de, (13650:16)
	cp	de, 6:i3
	jr	z, AccPatch_UpdateEntry_StoreDirect	; -> 0xF600AF
	jr	ugt, AccPatch_UpdateEntry_StoreDirect	; -> 0xF600AF
	ld	hl, 6:i3
	sub	hl, de
	ld	de, hl
	pushw	de
	ld	wa, (xix+1)
	pushw	wa
	calr	AccPatch_LoadTablePointers
	popw	wa
	ld	(xiy), wa
	popw	de
	ldw	hl, 255
	sub	hl, de
	ld	(xix), hl
	jr	AccPatch_NullRet	; -> 0xF600B6
AccPatch_UpdateEntry_StoreDirect:
	pushw de
	calr AccPatch_LoadTablePointers
	popw de
	ld (xix), de

AccPatch_NullRet:
	ret

AccPatch_NullRet_Pad:
	nop
	nop

AccPatch_LoadTablePointers:
	push	xbc
	ld	xbc, 0:i3
	ld	c, (CMP_RECORD_PART:16)
	sll	bc, 2
	push	xbc
	add	xbc, AccPatch_LoadTablePointers_Data_2
	ld	xix, xbc
	ld	xix, (xix)
	pop	xbc
	ld	xiy, AccPatch_LoadTablePointers_Data
	add	xiy, xbc
	ld	xiy, (xiy)
	pop	xbc
	ret
AccPatch_AdjustTableEntryPos:
	calr	AccPatch_LoadTablePointers
	ld	de, (xix)
	ld	wa, (xiy)
	sub	de, 6
	cp	de, (13650:16)
	jr	c, AccPatch_AdjustEntry_Overflow	; -> 0xF600F7
	sub	de, (13650:16)
	add	de, 6
	ld	(xix), de
	jr	AccPatch_AdjustEntry_Return	; -> 0xF60110
AccPatch_AdjustEntry_Overflow:
	ld	hl, (13650:16)
	sub	hl, de
	ldw	de, 255
	sub	de, hl
	ld	(xix), de
	ld	hl, wa
	push	xiy
	calr	AccPatch_GetEntryAddr
	pop	xiy
	ld	hl, (xix+1)
	ld	(xiy), hl
AccPatch_AdjustEntry_Return:
	ret

AccPatch_PrepareAndProcessEvents:
	calr	AccPatch_PrepareSequencePlayback
	ld	wa, (13606:16)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), wa
	ld	wa, (13608:16)
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
AccPatch_ProcessSequenceEvents:
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	cp	wa, (0x352a:16)
	jr nz, AccPatch_ProcessSeqEvt_SavePos
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	cp	wa, (0x352c:16)
	jr nz, AccPatch_ProcessSeqEvt_SavePos
	jrl t, AccPatch_ProcessSeqEvt_StorePos
AccPatch_ProcessSeqEvt_SavePos:
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13890:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13892:16), wa
	calr	AccPatch_SeqReadByte
	ld	(13889:16), a
	cp	a, 144
	jr	z, AccPatch_SkipNoteOff
	cp	a, 145
	jr	z, AccPatch_SkipNoteOff
	cp	a, 146
	jr	z, AccPatch_SkipNoteOff
	cp	a, 129
	jr	z, AccPatch_ProcessSeqEvt_HandleEnd
	and	a, 240
	cp	a, 208
	jr	z, AccPatch_ProcessSeqEvt_SkipD
	jrl	AccPatch_ProcessSeqEvt_RetNop
AccPatch_SkipNoteOff:
	calr	AccPatch_AdvanceSeqIndex
	calr	AccPatch_AdvanceSeqIndex
	calr	AccPatch_SeqReadByte
	ld	(13634:16), a
	ld	bc, 6:i3
	cp	(13889:16), 145
	jr	z, AccPatch_ProcessSeqEvt_AdvLoop
	ld	bc, 4:i3
AccPatch_ProcessSeqEvt_AdvLoop:
	calr	AccPatch_AdvanceSeqIndex
	djnz16	bc, AccPatch_ProcessSeqEvt_AdvLoop
	ld	a, (13634:16)
	ld	b, (13472:16)
	and	b, 127
	cp	a, b
	jr	z, AccPatch_ProcessSeqEvt_SetSize
	cp	a, 93
	jr	nz, AccPatch_ProcessSeqEvt_LoopBack
	cp	b, 48
	jr	nz, AccPatch_ProcessSeqEvt_LoopBack
	jr	AccPatch_ProcessSeqEvt_SetSize
AccPatch_ProcessSeqEvt_LoopBack:
	jrl AccPatch_ProcessSequenceEvents

AccPatch_ProcessSeqEvt_HandleEnd:
	calr AccPatch_AdvanceSeqIndex
	calr AccPatch_SeqReadByte
	cp a, 0x83
	jr z, AccPatch_ProcessSeqEvt_InitSlot
	jrl AccPatch_ProcessSequenceEvents

AccPatch_ProcessSeqEvt_SkipD:
	ld bc, 3:i3

AccPatch_ProcessSeqEvt_SkipDLoop:
	calr AccPatch_AdvanceSeqIndex
	djnz16 bc, AccPatch_ProcessSeqEvt_SkipDLoop
	jrl AccPatch_ProcessSequenceEvents

AccPatch_ProcessSeqEvt_SetSize:
	ldw	(13650:16), 8
	cp	(13889:16), 145
	jr	z, AccPatch_ProcessSeqEvt_StoreAndPrep
	ldw	(13650:16), 6
AccPatch_ProcessSeqEvt_StoreAndPrep:
	ld	wa, (13890:16)
	ld	(13606:16), wa
	ld	wa, (13892:16)
	ld	(13608:16), wa
	calr	AccPatch_CheckSequenceChanged
	ldw	(13650:16), 0
	calr	AccPatch_PrepareSequencePlayback
	jrl	AccPatch_ProcessSequenceEvents
AccPatch_ProcessSeqEvt_InitSlot:
	calr AccPatch_InitCurrentSlotPointer

AccPatch_ProcessSeqEvt_StorePos:
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13606:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13608:16), wa
	ret
AccPatch_ProcessSeqEvt_RetNop:
	ret

AccPatch_EventDispatch_Nop:
	nop

AccPatch_EventDispatchLoop:
	call AccPatch_CheckEmpty
	cp wa, 0:i3
	jr nz, AccPatch_EventDispatch_ReadCmd
	jrl AccPatch_EventDispatch_Done

AccPatch_EventDispatch_ReadCmd:
	call TempoRingBuf_PeekByte
	cp a, 0x81
	jr z, AccPatch_EventDispatch_EndMarker
	ld w, 0xf0:opc
	and w, a
	cp w, 0x90
	jr z, AccPatch_EventDispatch_NoteOn
	cp a, 0xd1
	jr nz, AccPatch_EventDispatch_CheckD2
	jr AccPatch_ProcessMarkerCommand

AccPatch_EventDispatch_CheckD2:
	cp a, 0xd2
	jr nz, AccPatch_EventDispatch_CheckD4
	jr AccPatch_ProcessMarkerCommand

AccPatch_EventDispatch_CheckD4:
	cp a, 0xd4
	jr nz, AccPatch_EventDispatch_CheckD3
	jr AccPatch_ProcessMarkerCommand

AccPatch_EventDispatch_CheckD3:
	cp a, 0xd3
	jr nz, AccPatch_EventDispatch_CheckD5
	jr AccPatch_ProcessMarkerCommand

AccPatch_EventDispatch_CheckD5:
	cp a, 0xd5
	jr z, AccPatch_ProcessMarkerCommand
	calr AccPatch_SkipToMarker
	jr AccPatch_ContinueProcessing

AccPatch_EventDispatch_NoteOn:
	ld	bc, 5:i3
	calr	AccPatch_ReadRingBufBytes
	cp	(13877:16), 0
	jr	nz, AccPatch_EventDispatch_NoteResolve
	calr	AccPatch_TransposeAndCopyNote
	jr	AccPatch_ContinueProcessing
AccPatch_EventDispatch_NoteResolve:
	calr AccPatch_ParseAndResolve
	calr AccPatch_CopyNoteStepsToSlots
	jr AccPatch_ContinueProcessing

AccPatch_EventDispatch_EndMarker:
	call	TempoRingBuf_ReadByteToA
	calr	AccPatch_UpdatePlayback
	bit	1, (0x3592:16)
	jr	nz, AccPatch_EventDispatch_AdvSlots
	calr	AccPatch_ScanToSequenceEnd
AccPatch_EventDispatch_AdvSlots:
	calr	AccPatch_AdvanceSlotCounters
	and	(0x3592:16), 253
	jr	AccPatch_ContinueProcessing
AccPatch_ProcessMarkerCommand:
	ld bc, 3:i3
	calr AccPatch_ReadRingBufBytes
	calr AccPatch_ParseAndResolve
	calr AccPatch_ProcessMarkerEvent
	jr AccPatch_ContinueProcessing

AccPatch_ContinueProcessing:
	jrl AccPatch_EventDispatchLoop

AccPatch_EventDispatch_Done:
	ret

AccPatch_ContinueProcessing_Pad:
	nop
	nop

AccPatch_UpdatePlayback:
	cpw	(0x3552:16), 0x0000
	jr z, .Lc_f602be
	ld	wa, (0x354a:16)
	ld	(0x3646:16), wa
	ld	wa, (0x354c:16)
	ld	(0x3648:16), wa
	calr AccPatch_InitSlotAndCopyData
	calr AccPatch_AdvancePlayPos
	calr AccPatch_AdvanceAllSteps
	ldw	(0x3552:16), 0x0000
AccPatch_UpdatePlayback_CheckQueue:
.Lc_f602be:
	cpw	(0x3556:16), 0x0000
	jr z, AccPatch_UpdatePlayback_ClearStep
	calr AccPatch_DispatchQueuedNotes
AccPatch_UpdatePlayback_ClearStep:
	ld	(13639:16), 0
	ret
AccPatch_UpdatePlayback_ClearStep_Pad:
	nop
	nop

AccPatch_AdvanceSlotCounters:
	ld	xhl, 13666
AccPatch_AdvSlotCtr_Loop:
	bitm 7, (xhl)
	jr z, AccPatch_AdvSlotCtr_Next
	ld a, (xhl + 1)
	cp a, 0xff
	jr z, AccPatch_AdvSlotCtr_Store
	inc 1, a

AccPatch_AdvSlotCtr_Store:
	ld (xhl + 1), a

AccPatch_AdvSlotCtr_Next:
	add	xhl, 6
	cp	xhl, 13714
	jr	nz, AccPatch_AdvSlotCtr_Loop
	ret
AccPatch_AdvSlotCtr_Store_Pad:
	nop
	nop

AccPatch_ReadRingBufBytes:
	ld xhl, 0:i3

AccPatch_ReadBuf_Loop:
	cp hl, bc
	jr z, AccPatch_ReadBuf_Done
	pushw bc
	pushw hl
	call TempoRingBuf_ReadByteToA
	cp a, 0xff
	jr nz, AccPatch_ReadBuf_StoreAndNext
	nop

AccPatch_ReadBuf_StoreAndNext:
	popw	hl
	popw	bc
	ld	xiz, 13874
	ld	(xiz+hl), a
	inc	1, hl
	jr	AccPatch_ReadBuf_Loop
AccPatch_ReadBuf_Done:
	ret

AccPatch_ReadBuf_StoreAndNext_Pad:
	nop
	nop

AccPatch_ParseAndResolve:
	ld	a, (0x3633:16)
	ld	(0x363f:16), a
	ld	(0x3640:16), a
	calr AccPatch_LookupStepByDrumParam
	cp	(0x3547:16), 0x00
	jr z, AccPatch_ParseResolve_ParseHdr
	ld	a, (0x3548:16)
	cp	a, (0x3640:16)
	jr z, AccPatch_ParseResolve_IncStep
	calr AccPatch_UpdatePlayback
AccPatch_ParseResolve_ParseHdr:
	calr	AccPatch_ParseSequenceHeader
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(13642:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(13644:16), wa
AccPatch_ParseResolve_IncStep:
	inc	1, (13639:16)
	ld	a, (13888:16)
	ld	(13640:16), a
	ret
AccPatch_ParseResolve_IncStep_Pad:
	nop
	nop

AccPatch_LookupStepByDrumParam:
	xor W,W
	ld IY,WA
	ld	a, (CMP_QUANTIZE:16)
	cp a, 0:i3
	jr z, AccPatch_SetStepDone
	ld WA,IY
	ld	w, (CMP_QUANTIZE:16)
	and W,0x07
	call AccPatch_QuantizeTick
	cp A,0x7f
	jr nz, AccPatch_LookupStep_StoreResult
	ld A, 0x00:opc
	ld	(0x3640:16), a
	ld	(0x3633:16), a
	bit	1, (0x3592:16)
	jr nz, AccPatch_SetStepDone
	or	(0x3592:16), 0x02
	calr AccPatch_UpdatePlayback
	calr AccPatch_ScanToSequenceEnd
	jr t, AccPatch_SetStepDone
AccPatch_LookupStep_StoreResult:
	ld	(13888:16), a
	ld	(13875:16), a
AccPatch_SetStepDone:
	ret

AccPatch_SetStepDone_Pad:
	nop
	nop

AccPatch_CopyNoteStepsToSlots:
	ld	xhl, 13666
	xor	iy, iy
AccPatch_CopySteps_FindFreeSlot:
	bit	7, (xhl+iy)
	jr z, AccPatch_CopySteps_ProcessEntry
	add iy, 0x6
	cp iy, 0x30
	jr z, AccPatch_CopyStepsDone
	jr AccPatch_CopySteps_FindFreeSlot

AccPatch_CopySteps_ProcessEntry:
	ld	de, iy
	cpw	(STYLE_FREE_BLOCKS:16), 0
	jr	z, AccPatch_CopySteps_Overflow
	ld	(0x3379:16), 0
	ld	(0x3632:16), 144
	bit	4, (CMP_RECORD_PART:16)
	jr	nz, AccPatch_CopySteps_StartFetch
	calr	AccPatch_TransposeNote
AccPatch_CopySteps_StartFetch:
	ld	a, (0x3632:16)
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
	ld	a, (0x3633:16)
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
	ld	a, (0x3634:16)
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_UpdateSlotVoiceData
	calr	AccPatch_SeqAdvanceStep
	ld	a, (0x3635:16)
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
	ld	a, 16:opc
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
	ld	a, 0:opc
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
	bit	0, (0x3379:16)
	jr	z, AccPatch_CopyStepsDone
	ld	a, (0x3638:16)
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
	ld	a, (0x3639:16)
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
AccPatch_CopyStepsDone:
	ret

AccPatch_CopySteps_Overflow:
	ld	(GLOBAL_ERROR_CODE:16), 15
	call	DrumVoice_NotifyEE
	ld	a, 8:opc
	call	MIDI_SendSysExCmd
	jr	AccPatch_CopyStepsDone
AccPatch_TransposeNote:
	ld	a, (13361:16)
	and	a, 15
	cp	a, 0:i3
	jr	z, AccPatch_Transpose_LookupTable
	calr	AccPatch_ReadTransposeAmount
	cp	a, (14742:16)
	jr	ugt, AccPatch_Transpose_AddBack
	sub	(13876:16), a
	jr	nc, AccPatch_Transpose_Done
	ld	a, 12:opc
	add	(13876:16), a
AccPatch_Transpose_Done:
	jr AccPatch_Transpose_LookupTable

AccPatch_Transpose_AddBack:
	ld	w, 12:opc
	sub	w, a
	add	(13876:16), w
AccPatch_Transpose_LookupTable:
	ld	xhl, 0:i3
	ld	l, (0x3634:16)
	add	xhl, Note_PitchClassTable
	ld	a, (xhl)
	bit	4, (0x3432:16)
	jr	z, AccPatch_Transpose_CheckBit6
	ld	w, a
	ld	xhl, 0:i3
	ld	l, a
	add	xhl, AccPatch_Transpose_LookupTable_Data_2
	ld	l, (xhl)
	bit	0, l
	jr	z, AccPatch_Transpose_CheckBit6
	inc	1, w
	ld	a, (0x3634:16)
	inc	1, a
	ld	(0x3634:16), a
	ld	a, w
AccPatch_Transpose_CheckBit6:
	bit	6, (0x3432:16)
	jr	z, AccPatch_Transpose_CheckBit5
	bit	3, (CMP_RECORD_PART:16)
	jr	z, AccPatch_Transpose_CheckBit5
	jr	AccPatch_Transpose_SetDrumSplit
AccPatch_Transpose_CheckBit5:
	bit	5, (0x3432:16)
	jr	z, AccPatch_StoreDrumParams
	bit	3, (CMP_RECORD_PART:16)
	jr	nz, AccPatch_StoreDrumParams
AccPatch_Transpose_SetDrumSplit:
	cp	a, 7:i3
	jr	nz, AccPatch_StoreDrumParams
	ld	(13177:16), 1
	ld	(13880:16), 3
	ld	(13881:16), 0
	jr	AccPatch_StoreDrumParams_CheckSplit
AccPatch_StoreDrumParams:
	ld	xhl, 0:i3
	ld	l, a
	sll	a, 1
	add	l, a
	add	xhl, AccPatch_StoreDrumParams_Data
	ld	a, (xhl)
	ld	(13177:16), a
	ld	a, (xhl+1)
	ld	(13880:16), a
	ld	a, (xhl+2)
	ld	(13881:16), a
AccPatch_StoreDrumParams_CheckSplit:
	bit	0, (0x3379:16)
	jr	z, AccPatch_StoreDrumParams_Return
	ld	(0x3632:16), 145
AccPatch_StoreDrumParams_Return:
	ret

AccPatch_TransposeNoteTable:
; AccPatch_TransposeNoteTable -- two small tables read by the transpose path.
; ** RE-TYPED 2026-09-25 (lane accomp): was nop/normal/scf mnemonics plus
; .zero/.byte fragments (data-as-code).  Readers:
;   AccPatch_Transpose_LookupTable: A = byte (0x36ec) of
;       Note_PitchClassTable, then ld l,a / add xhl,
;       AccPatch_Transpose_LookupTable_Data_2 / ld l,(xhl) / bit 0,l -- when set, A
;       and (0x36ec) are incremented by one.
;   AccPatch_StoreDrumParams: ld l,a / sll a,1 / add l,a (l = 3a) / add xhl,
;       AccPatch_StoreDrumParams_Data, then (xhl), (xhl+1), (xhl+2) are
;       stored to (0x3431), (0x36f0), (0x36f1); bit 0 of (0x3431) then selects
;       `ld (0x36ea), 145`.
; Sizes: the +0x0E records are 3 bytes (the `3a` index) and 12 of them end
; exactly at AccPatch_ReadTransposeAmount; the flag table is the 12 bytes
; between the two reader offsets.  Only index 3 of the flag table and
; records 3, 4 and 11 are non-zero.
; readers in v7 (address from the linked ELF): AccPatch_Transpose_LookupTable 0xF60470,
;     AccPatch_StoreDrumParams 0xF604D4
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; +0x00  2 B, not addressed by either reader
	.byte 0x00, 0x00
; +0x02  12 x u8, flag byte per index (bit 0 tested)
AccPatch_Transpose_LookupTable_Data_2:
	.byte 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
; +0x0E  12 x 3-byte records {(0x3431), (0x36f0), (0x36f1)}
AccPatch_StoreDrumParams_Data:
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x01, 0x00, 0x11
	.byte 0x01, 0x00, 0x11
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x01, 0x11, 0x11

AccPatch_ReadTransposeAmount:
	push	xwa
	push	xhl
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	call	AccPatch_GetCurrentSlotAddr
	ld	a, (CMP_RECORD_PART:16)
	ld	xix, 37
	bit	3, a
	jr	nz, AccPatch_SelectTranspose
	ld	xix, 45
	bit	0, a
	jr	nz, AccPatch_SelectTranspose
	ld	xix, 53
	bit	1, a
	jr	nz, AccPatch_SelectTranspose
	ld	xix, 61
AccPatch_SelectTranspose:
	add	xix, xiy
	ld	a, (xix)
	ld	(14742:16), a
	pop	xiz
	pop	xiy
	pop	xix
	pop	xde
	pop	xbc
	pop	xhl
	pop	xwa
	ret
AccPatch_FetchStepEntry:
	ld	xiy, 13746

	ld	hl, (13650:16)

	ld	(xiy+hl), a

	inc 1, hl

	ld	(13650:16), hl

	ret



AccPatch_FetchStepData:
	ld	xiy, 13810
	ld	hl, (0x3556:16)
	ld	(xiy+hl), a
	inc	1, hl
	ld	(0x3556:16), hl
	ret
AccPatch_SeqAdvanceStep:
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	cp WA,0x00fe
	jr nz, AccPatch_SeqAdvStep_Increment
	cpw	(STYLE_FREE_BLOCKS:16), 0x0000
	jr z, AccPatch_SeqAdvStep_Return
	calr AccPatch_SeqAdvStep_WrapToNext
	jr t, AccPatch_SeqAdvStep_Return
AccPatch_SeqAdvStep_Increment:
	inc	1, wa
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
AccPatch_SeqAdvStep_Return:
	ret

AccPatch_SeqAdvStep_WrapToNext:
	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)
	calr	AccPatch_GetEntryAddr
	ld	hl, (xix+3)
	cp	hl, 65535
	jr	z, AccPatch_SeqAdvStep_ScanFromStart
	jr	AccPatch_SeqAdvStep_StorePos
AccPatch_SeqAdvStep_ScanFromStart:
	ldw hl, 0x95

AccPatch_SeqAdvStep_ScanLoop:
	inc 1, hl
	calr AccPatch_GetEntryAddr
	bitm 7, (xix)
	jr z, AccPatch_SeqAdvStep_StorePos
	jr AccPatch_SeqAdvStep_ScanLoop

AccPatch_SeqAdvStep_StorePos:
	ld	(ACC_PATCH_CURSOR_BLOCK:16), hl
	ldw	(ACC_PATCH_CURSOR_OFFSET:16), 6
	ret
AccPatch_SeqAdvStep_StorePos_Pad:
	nop
	nop

AccPatch_UpdateSlotVoiceData:
	ld	xhl, 13666

	ld iy, de

	or a, 0x80

	ld	(xhl+iy), a

	pushw iy

	inc 1, iy

	ld	(xhl+iy), 0x00

	ld	a, (13887:16)

	inc 1, iy

	ld	(xhl+iy), a

	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)

	inc 1, iy

	ld	(xhl+iy), wa

	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)

	inc 2, iy

	ld	(xhl+iy), a

	popw iy

	ret



AccPatch_TransposeAndCopyNote:
	bit	4, (CMP_RECORD_PART:16)
	jr	nz, AccPatch_TransposeCopy_DoCopy
	calr	AccPatch_TransposeNote
AccPatch_TransposeCopy_DoCopy:
	ld	xiy, 13874

	ld	xix, 13810

	ld xbc, 0:i3

	ld	bc, (13654:16)

	add xix, xbc

	ld bc, 6:i3

	ldir85

	; adddi16 0x360e, 6 (v7 patched)
	addw	(0x3556:16), 6
	ret



AccPatch_TransposeCopy_DoCopy_Pad:
	nop
	nop

AccPatch_ProcessMarkerEvent:
	cpw	(STYLE_FREE_BLOCKS:16), 0x0000
	jr z, AccPatch_ProcessMarker_Return
	ld	a, (0x3632:16)
	cp A,0xd4
	jr nz, AccPatch_ProcessMarker_CheckD3
	ld A, 0xd3:opc
	jr t, AccPatch_FetchSequence
AccPatch_ProcessMarker_CheckD3:
	cp a, 0xd3
	jr nz, AccPatch_ProcessMarker_CheckD5
	ld a, 0xd5:opc
	jr AccPatch_FetchSequence

AccPatch_ProcessMarker_CheckD5:
	cp a, 0xd5
	jr nz, AccPatch_FetchSequence
	ld a, 0xd4:opc
	jr AccPatch_FetchSequence

AccPatch_FetchSequence:
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
	ld	a, (13875:16)
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
	ld	a, (13876:16)
	calr	AccPatch_FetchStepEntry
	calr	AccPatch_SeqAdvanceStep
AccPatch_ProcessMarker_Return:
	ret

AccPatch_FetchSequence_Pad:
	nop
	nop

AccPatch_SkipToMarker:
	call TempoRingBuf_ReadByteToA
	bit 7, a
	jr z, AccPatch_SkipToMarker
	ret

AccPatch_SlotCopyDataBlock:
	nop
	nop
AccPatch_SlotCopyDataBlock_Loop2:
	pushw	bc
	call	TempoRingBuf_ReadByteToA
	popw	bc
	dec	1, bc
	cp	bc, 0:i3
	jr	nz, AccPatch_SlotCopyDataBlock_Loop2	; -> 0xF6069F
	ret
	ldw	(13656:16), 0
AccPatch_SkipToMarker_Loop:
	ld	xix, 13810
	add	ix, (13656:16)
	calr	AccPatch_DispatchNoteToVoice
	ld	wa, (13656:16)
	add	wa, 6
	ld	(13656:16), wa
	cp	wa, (13654:16)
	jr	c, AccPatch_SkipToMarker_Loop	; -> 0xF606B2
	ldw	(13654:16), 0
	ret
AccPatch_InitSlotAndCopyData:
	ld xhl, 0:i3
	ld	l, (STYLE_SECTION:16)
	call AccPatch_GetCurrentSlotAddr
	and (XIY+0x0f),0x7f
	ld	de, (0x354a:16)
	ld	hl, (0x354e:16)
	ld	(0x35a0:16), hl
	calr AccPatch_GetEntryAddr
	ld	(0x3598:16), xix
	ld	wa, (0x3550:16)
	ld	(0x35a6:16), wa
	ldw BC, 0x00fe
	sub BC,WA
	ld	(0x364a:16), bc
	cp	bc, (0x3552:16)
	jr	nc, AccPatch_InitSlot_SameBlock
	jr	AccPatch_InitSlot_CrossBlock
AccPatch_InitSlot_SameBlock:
	ld	hl, (13646:16)
	ld	(13730:16), hl
	calr	AccPatch_GetEntryAddr
	ld	(13716:16), xix
	ld	wa, (13648:16)
	add	wa, (13650:16)
	ld	(13736:16), wa
	jr	AccPatch_InitSlot_StoreAddrs	; -> 0xF6074E
AccPatch_InitSlot_CrossBlock:
	calr	AccPatch_FindFreeEntrySlot
	ld	(13730:16), wa
	ld	hl, wa
	calr	AccPatch_GetEntryAddr
	ld	(13716:16), xix
	ld	wa, (13650:16)
	sub	wa, (13898:16)
	add	wa, 5
	ld	(13736:16), wa
AccPatch_InitSlot_StoreAddrs:
	ld	wa, (0x35a2:16)
	ld	(0x354e:16), wa
	ld	wa, (0x35a8:16)
	ld	(0x3550:16), wa
	calr	AccPatch_CalcBlockCopySetup
	inc	1, ix
	ld	(0x364c:16), ix
	ld	hl, (0x354a:16)
	calr	AccPatch_GetEntryAddr
	ld	xwa, 0:i3
	ld	wa, (0x354c:16)
	add	xix, xwa
	ld	xiy, 13746
	ld	xbc, 0:i3
	ldw	bc, 254
	sub	bc, (0x354c:16)
	inc	1, bc
	cp	bc, (0x3552:16)
	jr	c, AccPatch_InitSlot_SplitCopy
	ld	xbc, 0:i3
	ld	bc, (0x3552:16)
	ldir85
	jr	AccPatch_InitSlot_Finalize
AccPatch_InitSlot_SplitCopy:
	ld	wa, bc
	ldir85
	ld	xbc, 0:i3
	ld	bc, (0x3552:16)
	sub	bc, wa
	ld	hl, (0x354a:16)
	calr	AccPatch_GetEntryAddr
	ld	hl, (xix+3)
	calr	AccPatch_GetEntryAddr
	add	xix, 6
	cp	bc, 0:i3
	jr	z, AccPatch_InitSlot_Finalize
	ldir85
AccPatch_InitSlot_Finalize:
	ld	wa, (13730:16)
	ld	(13642:16), wa
	ld	wa, (13900:16)
	ld	(13644:16), wa
	ret
AccPatch_InitSlot_Finalize_Pad:
	nop
	nop

AccPatch_FindFreeEntrySlot:
	ldw hl, 0x95

AccPatch_FindFreeSlot_Loop:
	inc 1, hl
	calr AccPatch_GetEntryAddr
	bitm 7, (xix)
	jr z, AccPatch_FindFreeSlot_Found
	jr AccPatch_FindFreeSlot_Loop

AccPatch_FindFreeSlot_Found:
	ld wa, hl

	push xix

	ld	hl, (13646:16)

	pushw wa

	calr AccPatch_GetEntryAddr

	popw wa

	ld (xix + 3), wa

	pop xix

	ormi8 (xix), 0x80

	ld	bc, (13646:16)

	ld (xix + 1), bc

	ldw (xix + 3), 0xffff

	decw	1, (STYLE_FREE_BLOCKS:16)

	ret



AccPatch_FindFreeSlot_Found_Pad:
	nop
	nop

AccPatch_AdvancePlayPos:
	calr AccPatch_LoadTablePointers
	ld DE,(XIX)
	ld HL,(XIY)
	pushw de
	pushw hl
	calr AccPatch_GetEntryAddr
	popw hl
	popw de
	cp	hl, (0x3646:16)
	jr	z, AccPatch_AdvPlayPos_CheckDE
	cpw	(xix+1), 65535
	jr	nz, AccPatch_AdvPlayPos_AddAndCheck
	jr	AccPatch_StoreEntryPtr
AccPatch_AdvPlayPos_CheckDE:
	cp	de, (0x3648:16)
	jr	nc, AccPatch_AdvPlayPos_AddAndCheck
	jr	AccPatch_StoreEntryPtr
AccPatch_AdvPlayPos_AddAndCheck:
	add	de, (13650:16)
	cp	de, 254
	jr	z, AccPatch_AdvPlayPos_StoreDirect	; -> 0xF6084E
	jr	c, AccPatch_AdvPlayPos_StoreDirect	; -> 0xF6084E
	sub	de, 254
	pushw	de
	calr	AccPatch_GetEntryAddr
	ld	wa, (xix+3)
	pushw	wa
	calr	AccPatch_LoadTablePointers
	popw	wa
	popw	de
	ld	(xiy), wa
	add	de, 5
	ld	(xix), de
	jr	AccPatch_StoreEntryPtr	; -> 0xF60855
AccPatch_AdvPlayPos_StoreDirect:
	pushw de
	calr AccPatch_LoadTablePointers
	popw de
	ld (xix), de

AccPatch_StoreEntryPtr:
	ret

AccPatch_AdvPlayPos_DataBlock:
; AccPatch_AdvPlayPos_DataBlock -- two parallel 17-entry tables of RAM
; pointers, indexed by the one-hot selector (0x379b).
; ** RE-TYPED 2026-09-25 (lane accomp): was `.byte 0x9d` / `ldw de, 0` / nop
; runs (data-as-code).  Read by AccPatch_LoadTablePointers:
;     ld c,(0x379b) / sll bc,2 / add xbc, AccPatch_LoadTablePointers_Data_2 /
;     ld xix,(xbc) ... ld xiy, AccPatch_LoadTablePointers_Data / add xiy,xbc /
;     ld xiy,(xiy)
; so entry (0x379b) of each table is a 32-bit pointer.  Only the one-hot
; entries 1, 2, 4, 8 and 16 are non-zero (v9/v10: +0x07 gives 0x329D, 0x329F,
; 0x32A1, 0x329B, 0x3297 and +0x4B gives 0x328D, 0x328F, 0x3291, 0x328B,
; 0x3287) -- word variables two bytes apart, which AccPatch_AdjustTableEntryPos and its
; siblings then read and update through (xix)/(xiy).  17 entries each: the
; +0x4B reader offset minus +0x07 is 68 = 17*4, and 17*4 more bytes end
; exactly at AccPatch_AdvanceAllSteps.
; readers in v7 (address from the linked ELF): AccPatch_LoadTablePointers 0xF600B9
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; +0x00  7 zero bytes, not addressed by the reader
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
; +0x07  17 x LE32 -> XIY (RAM addresses)
AccPatch_LoadTablePointers_Data:
	.long	0x00000000, 0x000031e5, 0x000031e7, 0x00000000
	.long	0x000031e9, 0x00000000, 0x00000000, 0x00000000
	.long	0x000031e3, 0x00000000, 0x00000000, 0x00000000
	.long 0x00000000, 0x00000000, 0x00000000, 0x00000000
	.long	0x000031df
; +0x4B  17 x LE32 -> XIX (RAM addresses)
AccPatch_LoadTablePointers_Data_2:
	.long	0x00000000, 0x000031d5, 0x000031d7, 0x00000000
	.long	0x000031d9, 0x00000000, 0x00000000, 0x00000000
	.long	0x000031d3, 0x00000000, 0x00000000, 0x00000000
	.long 0x00000000, 0x00000000, 0x00000000, 0x00000000
	.long	0x000031cf
AccPatch_AdvanceAllSteps:
	ld	xix, 13666
AccPatch_AdvAllSteps_Loop:
	bit	7, (xix+1)
	jr	z, AccPatch_AdvAllSteps_Next
	ld	bc, (0x3552:16)
AccPatch_AdvAllSteps_InnerLoop:
	calr AccPatch_AdvanceSingleStep
	djnz16 bc, AccPatch_AdvAllSteps_InnerLoop

AccPatch_AdvAllSteps_Next:
	add	xix, 6
	cp	xix, 13714
	jr	c, AccPatch_AdvAllSteps_Loop
	ret
AccPatch_AdvAllSteps_InnerLoop_Pad:
	nop
	nop

AccPatch_AdvanceSingleStep:
	xor w, w
	ld a, (xix + 5)
	cp wa, 0xfe
	jr nz, AccPatch_AdvSingleStep_Inc
	ld hl, (xix + 3)
	push xix
	calr AccPatch_GetEntryAddr
	ld xiy, xix
	pop xix
	ld wa, (xiy + 3)
	ld (xix + 3), wa
	ld wa, 6:i3
	jr AccPatch_AdvSingleStep_Store

AccPatch_AdvSingleStep_Inc:
	inc 1, wa

AccPatch_AdvSingleStep_Store:
	ld (xix + 5), a
	ret

AccPatch_AdvSingleStep_Store_Pad:
	nop
	nop

AccPatch_DispatchQueuedNotes:
	ld	xix, 13810
AccPatch_DispatchQueued_Loop:
	calr	AccPatch_DispatchNoteToVoice
	add	xix, 6
	ld	xwa, xix
	sub	xwa, 13810
	cp	wa, (13654:16)
	jr	c, AccPatch_DispatchQueued_Loop	; -> 0xF60936
	ldw	(13654:16), 0
	ret
AccPatch_DispatchQueuedNotes_Pad:
	nop
	nop

AccPatch_DispatchNoteToVoice:
	ld	xhl, 13666
	ldw	iy, 42
AccPatch_DispatchNote_Loop:
	bit	7, (xhl+iy)
	jr z, AccPatch_DispatchNote_NextSlot
	ld	a, (xhl+iy)
	and a, 0x7f
	cp a, (xix + 2)
	jr nz, AccPatch_DispatchNote_NextSlot
	and	(xhl+iy), 0x7f
	inc 1, iy
	and	(xhl+iy), 0x7f
	ld	d, (xhl+iy)
	inc 1, iy
	ld	a, (xhl+iy)
	ld c, (xix + 1)
	cp c, a
	jr nc, AccPatch_DispatchNote_CalcVelocity
	add c, 0x60
	cp d, 0:i3
	jr z, AccPatch_DispatchNote_CalcVelocity
	dec 1, d

AccPatch_DispatchNote_CalcVelocity:
	sub c, a
	ld a, c
	calr AccPatch_WriteVelocityToSeq
	jr AccPatch_DispatchNote_Return

AccPatch_DispatchNote_NextSlot:
	sub iy, 0x6
	cp iy, 0:i3
	jr lt, AccPatch_DispatchNote_Return
	jr AccPatch_DispatchNote_Loop

AccPatch_DispatchNote_Return:
	ret

AccPatch_DispatchNote_NextSlot_Pad:
	nop
	nop

AccPatch_WriteVelocityToSeq:
	pushw DE
	pushw WA
	ld	wa, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(0x3642:16), wa
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	ld	(0x3644:16), wa
	inc 1,IY
	ld	wa, (xhl+iy)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), wa
	pushw	iy
	inc	2, iy
	xor	wa, wa
	ld	a, (xhl+iy)
	popw	iy
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
	calr	AccPatch_SeqReadByte
	cp	a, (xix+2)
	jr	z, AccPatch_WriteVel_MatchFound
	popw	wa
	popw	de
	jr	AccPatch_WriteVel_RestorePos
AccPatch_WriteVel_MatchFound:
	calr AccPatch_AdvanceSeqIndex
	calr AccPatch_AdvanceSeqIndex
	popw wa
	calr AccPatch_WriteSeqByte
	calr AccPatch_AdvanceSeqIndex
	popw de
	ld a, d
	calr AccPatch_WriteSeqByte

AccPatch_WriteVel_RestorePos:
	ld	wa, (13890:16)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), wa
	ld	wa, (13892:16)
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
	ret
AccPatch_WriteVel_RestorePos_Pad:
	nop
	nop

AccPatch_WriteSeqByte:
	push	xix
	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)
	calr	AccPatch_GetEntryAddr
	push	xwa
	ld	xwa, 0:i3
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	add	xix, xwa
	pop	xwa
	ld	(xix), a
	pop	xix
	ret
AccPatch_WriteSeqByte_Pad:
	nop
	nop

AccPatch_CalcBlockCopySetup:
	ld	(GLOBAL_ERROR_CODE:16), 0
	cp	de, (13728:16)
	jr	nz, AccPatch_CalcBlockCopy_DiffEntry	; -> 0xF60A5C
	ld	iy, (13734:16)
	sub	iy, 6
	inc	1, iy
	ld	(13740:16), iy
	ld	iy, (13734:16)
	ld	ix, (13736:16)
	sub	ix, 6
	inc	1, ix
	ld	(13742:16), ix
	ld	ix, (13736:16)
	calr	AccPatch_CalcBlockCopyBounds
	jr	AccPatch_CalcBlockCopy_Done	; -> 0xF60A81
AccPatch_CalcBlockCopy_DiffEntry:
	ld	wa, (0x35a8:16)
	cp	wa, (0x35a6:16)
	jr	ugt, AccPatch_CalcBlockCopy_Clamp
	jr	z, AccPatch_CalcBlockCopy_StoreIY
	jr	AccPatch_CalcBlockCopy_CheckIX
AccPatch_CalcBlockCopy_Clamp:
	calr AccPatch_CalcBlockCopy_Clamp_Helper
	jr AccPatch_CalcBlockCopy_StoreIX

AccPatch_CalcBlockCopy_StoreIY:
	calr BlockCopy_SameEntry_Reverse
	jr AccPatch_CalcBlockCopy_StoreIX

AccPatch_CalcBlockCopy_CheckIX:
	calr BlockCopy_IXFirst_Reverse

AccPatch_CalcBlockCopy_StoreIX:
	cp	(GLOBAL_ERROR_CODE:16), 0
	jr	nz, AccPatch_CalcBlockCopy_Done
	calr	AccPatch_CalcBlockCopyBounds
AccPatch_CalcBlockCopy_Done:
	ret

AccPatch_CalcBlockCopy_Clamp_Helper:
	ld	wa, (0x35a8:16)
	sub	wa, (0x35a6:16)
	ld	(0x359c:16), wa
	ldw BC, 0x00ff
	sub BC,0x0006
	sub BC,WA
	ld	(0x359e:16), bc
	ld xix, 0:i3
	ld xiy, 0:i3
	ld	iy, (0x35a6:16)
	ld	ix, (0x35a8:16)
	ld	bc, (0x35a6:16)
	sub BC,0x0006
	inc 1,BC
	calr DSP_BlockCopyReverse
	calr AccPatch_AdvanceNextEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60ac0
	jr t, DSP_SetupDone
BlockCopy_Rev_CheckSameEntry:
.Lc_f60ac0:
	cp	de, (0x35a0:16)
	jr nz, .Lc_f60ac8
	jr t, BlockCopy_Rev_StoreBounds
BlockCopy_Rev_CopyDiffEntry:
.Lc_f60ac8:
	ld	bc, (0x359c:16)
	calr DSP_BlockCopyReverse
	calr AccPatch_AdvanceNextEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60adb
	jr t, DSP_SetupDone
BlockCopy_Rev_CopyRemainder:
.Lc_f60adb:
	ld	bc, (0x359e:16)
	calr DSP_BlockCopyReverse
	calr AccPatch_AdvanceNextEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60ac0
	jr t, DSP_SetupDone
BlockCopy_Rev_StoreBounds:
	ld	wa, (13724:16)
	ld	(13742:16), wa
	ldw	bc, 255
	sub	bc, 6
	ld	(13740:16), bc
DSP_SetupDone:
	ret

DSP_BlockCopyReverse:
	push xwa

	push xhl

	and xiy, 0xff

	and xix, 0xff

	ld	xwa, (13716:16)

	ld	xhl, (13720:16)

	push xwa

	push xhl

	add xwa, xix

	ld xix, xwa

	add xhl, xiy

	ld xiy, xhl

	lddr85

	pop xhl

	pop xwa

	ld	(13720:16), xhl

	ld	(13716:16), xwa

	and xiy, 0xff

	and xix, 0xff

	pop xhl

	pop xwa

	ret



DSP_BlockCopyForward:
	push xwa

	push xhl

	and xiy, 0xff

	and xix, 0xff

	ld	xwa, (13716:16)

	ld	xhl, (13720:16)

	push xwa

	push xhl

	add xwa, xix

	ld xix, xwa

	add xhl, xiy

	ld xiy, xhl

	ldir85

	pop xhl

	pop xwa

	ld	(13720:16), xhl

	ld	(13716:16), xwa

	and xiy, 0xff

	and xix, 0xff

	pop xhl

	pop xwa

	ret



BlockCopy_SameEntry_Reverse:
	ld	bc, (0x35a6:16)
	sub BC,0x0006
	inc 1,BC
	ld	iy, (0x35a6:16)
	ld	ix, (0x35a8:16)
	calr DSP_BlockCopyReverse
	calr AccPatch_AdvanceNextEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60b99
	jr t, DSP_NullRet
BlockCopy_SameEntry_AdvIY:
.Lc_f60b99:
	calr AccPatch_AdvanceNextEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60ba5
	jr t, DSP_NullRet
BlockCopy_SameEntry_CheckDE:
.Lc_f60ba5:
	cp	de, (0x35a0:16)
	jr nz, .Lc_f60bad
	jr t, BlockCopy_SameEntry_StoreBounds
BlockCopy_SameEntry_FullCopy:
.Lc_f60bad:
	ldw BC, 0x00ff
	sub BC,0x0006
	calr DSP_BlockCopyReverse
	calr AccPatch_AdvanceNextEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60bc3
	jr t, DSP_NullRet
BlockCopy_SameEntry_AdvIYLoop:
.Lc_f60bc3:
	calr AccPatch_AdvanceNextEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60ba5
	jr t, DSP_NullRet
BlockCopy_SameEntry_StoreBounds:
	ldw	bc, 255
	sub	bc, 6
	ld	(13742:16), bc
	ld	(13740:16), bc
DSP_NullRet:
	ret

BlockCopy_IXFirst_Reverse:
	ld	wa, (0x35a6:16)
	sub	wa, (0x35a8:16)
	ld	(0x359c:16), wa
	ldw BC, 0x00ff
	sub BC,0x0006
	sub BC,WA
	ld	(0x359e:16), bc
	ld xix, 0:i3
	ld xiy, 0:i3
	ld	iy, (0x35a6:16)
	ld	ix, (0x35a8:16)
	ld	bc, (0x35a8:16)
	sub BC,0x0006
	inc 1,BC
	calr DSP_BlockCopyReverse
	calr AccPatch_AdvanceNextEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60c1d
	jr t, DSP_NullRet2
BlockCopy_IXFirst_CopyOffset:
.Lc_f60c1d:
	ld	bc, (0x359c:16)
	calr DSP_BlockCopyReverse
	calr AccPatch_AdvanceNextEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60c30
	jr t, DSP_NullRet2
BlockCopy_IXFirst_CheckDE:
.Lc_f60c30:
	cp	de, (0x35a0:16)
	jr nz, .Lc_f60c38
	jr t, BlockCopy_IXFirst_StoreBounds
BlockCopy_IXFirst_CopyRemainder:
.Lc_f60c38:
	ld	bc, (0x359e:16)
	calr DSP_BlockCopyReverse
	calr AccPatch_AdvanceNextEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60c4b
	jr t, DSP_NullRet2
BlockCopy_IXFirst_CopyOffset2:
.Lc_f60c4b:
	ld	bc, (0x359c:16)
	calr DSP_BlockCopyReverse
	calr AccPatch_AdvanceNextEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60c30
	jr t, DSP_NullRet2
BlockCopy_IXFirst_StoreBounds:
	ld	wa, (13726:16)
	ld	(13742:16), wa
	ldw	wa, 255
	sub	wa, 6
	ld	(13740:16), wa
DSP_NullRet2:
	ret

AccPatch_CalcBlockCopyBounds:
	ld	wa, (13644:16)
	sub	wa, 6
	ld	bc, (13740:16)
	sub	bc, wa
	ld	(13744:16), bc
	cp	(13742:16), bc
	jr	nc, BlockCopyBounds_UseBC	; -> 0xF60C8C
	jr	BlockCopyBounds_UseSmaller	; -> 0xF60C91
BlockCopyBounds_UseBC:
	calr DSP_BlockCopyReverse
	jr BlockCopyBounds_Return

BlockCopyBounds_UseSmaller:
	ld	bc, (0x35ae:16)
	calr	DSP_BlockCopyReverse
	calr	AccPatch_AdvanceNextEntry_IX
	cp	(GLOBAL_ERROR_CODE:16), 0
	jr	z, BlockCopyBounds_CopyRemainder
	jr	BlockCopyBounds_Return
BlockCopyBounds_CopyRemainder:
	; ldw_d16 xbc, (0x3668) (v7 patched)
	ld	bc, (0x35b0:16)
	; subda16 xbc, 0x3666 (v7 patched)
	sub	bc, (0x35ae:16)
	; calr DSP_BlockCopyReverse (v7 displacement)
	calr	DSP_BlockCopyReverse
BlockCopyBounds_Return:
	ret

AccPatch_AdvanceNextEntry_IY:
	push XIX
	ld	xiy, (0x3598:16)
	ld HL,(XIY+0x01)
	ld	(0x35a0:16), hl
	calr AccPatch_GetEntryAddr
	bit	7, (xix+0:8)
	jr	nz, AdvNextEntry_IY_StoreAndReset
	ld	(GLOBAL_ERROR_CODE:16), 11
	jr	AdvNextEntry_IY_Return
AdvNextEntry_IY_StoreAndReset:
	ld	(13720:16), xix
	ld	xiy, 0:i3
	ldw	iy, 254
AdvNextEntry_IY_Return:
	pop xix
	ret

AccPatch_AdvanceNextEntry_IX:
	ld	xix, (0x3594:16)
	ld HL,(XIX+0x01)
	ld	(0x35a2:16), hl
	calr AccPatch_GetEntryAddr
	bit	7, (xix+0:8)
	jr	nz, AdvNextEntry_IX_StoreAndReset
	ld	(GLOBAL_ERROR_CODE:16), 11
	jr	AdvNextEntry_IX_Return
AdvNextEntry_IX_StoreAndReset:
	ld	(13716:16), xix
	ld	xix, 0:i3
	ldw	ix, 254
AdvNextEntry_IX_Return:
	ret

AccPatch_SetupBlockCopyDispatch:
	ld (GLOBAL_ERROR_CODE:16), 0x00
	ld	hl, (0x35a0:16)
	calr AccPatch_GetEntryAddr
	ld	(0x3598:16), xix
	cp	de, (0x35a0:16)
	jr	nz, BlockCopyDisp_CompareOffsets
	ld	xiy, 0:i3
	ldw	iy, 255
	sub	iy, (0x35a6:16)
	ld	(0x35ac:16), iy
	ld	iy, (0x35a6:16)
	ld	xix, 0:i3
	ldw	ix, 255
	sub	ix, (0x35a8:16)
	ld	(0x35ae:16), ix
	ld	ix, (0x35a8:16)
	calr	AccPatch_ForwardBlockCopy
	jr	BlockCopyDisp_Return
BlockCopyDisp_CompareOffsets:
	ld	wa, (0x35a8:16)
	cp	wa, (0x35a6:16)
	jr	c, BlockCopyDisp_IXSmaller
	jr	z, BlockCopyDisp_Equal
	jr	ugt, BlockCopyDisp_IXLarger
BlockCopyDisp_IXSmaller:
	calr BlockCopy_FwdIYSmaller
	jr BlockCopyDisp_CheckAndForward

BlockCopyDisp_Equal:
	calr BlockCopy_FwdEqual
	jr BlockCopyDisp_CheckAndForward

BlockCopyDisp_IXLarger:
	calr BlockCopy_FwdIXSmaller
	jr BlockCopyDisp_CheckAndForward

BlockCopyDisp_CheckAndForward:
	cp	(GLOBAL_ERROR_CODE:16), 0
	jr	nz, BlockCopyDisp_Return
	calr	AccPatch_ForwardBlockCopy
BlockCopyDisp_Return:
	ret

BlockCopy_FwdIYSmaller:
	ldw WA, 0x00ff
	sub	wa, (0x35a8:16)
	ldw BC, 0x00ff
	sub	bc, (0x35a6:16)
	sub WA,BC
	ld	(0x359c:16), wa
	ldw BC, 0x00ff
	sub BC,0x0006
	sub BC,WA
	ld	(0x359e:16), bc
	ld xiy, 0:i3
	ld	iy, (0x35a6:16)
	ld xix, 0:i3
	ld	ix, (0x35a8:16)
	ldw BC, 0x00ff
	sub	bc, (0x35a6:16)
	calr DSP_BlockCopyForward
	calr AccPatch_AdvancePrevEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60da2
	jr t, DSP_CopyDone
BlockCopy_FwdIYSmall_CheckDE:
.Lc_f60da2:
	cp	de, (0x35a0:16)
	jr nz, .Lc_f60daa
	jr t, BlockCopy_FwdIYSmall_StoreBounds
BlockCopy_FwdIYSmall_CopyOffset:
.Lc_f60daa:
	ld	bc, (0x359c:16)
	calr DSP_BlockCopyForward
	calr AccPatch_AdvancePrevEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60dbd
	jr t, DSP_CopyDone
BlockCopy_FwdIYSmall_CopyRem:
.Lc_f60dbd:
	ld	bc, (0x359e:16)
	calr DSP_BlockCopyForward
	calr AccPatch_AdvancePrevEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60da2
	jr t, DSP_CopyDone
BlockCopy_FwdIYSmall_StoreBounds:
	ld	wa, (13724:16)
	ld	(13742:16), wa
	ldw	bc, 255
	sub	bc, 6
	ld	(13740:16), bc
DSP_CopyDone:
	ret

BlockCopy_FwdEqual:
	ldw BC, 0x00ff
	sub	bc, (0x35a6:16)
	ld xiy, 0:i3
	ld	iy, (0x35a6:16)
	ld xix, 0:i3
	ld	ix, (0x35a8:16)
	calr DSP_BlockCopyForward
	calr AccPatch_AdvancePrevEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60e06
	jr t, AccPatch_NullRet2
BlockCopy_FwdEqual_AdvIX:
.Lc_f60e06:
	calr AccPatch_AdvancePrevEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60e12
	jr t, AccPatch_NullRet2
BlockCopy_FwdEqual_CheckDE:
.Lc_f60e12:
	cp	de, (0x35a0:16)
	jr nz, .Lc_f60e1a
	jr t, BlockCopy_FwdEqual_StoreBounds
BlockCopy_FwdEqual_FullCopy:
.Lc_f60e1a:
	ldw BC, 0x00ff
	sub BC,0x0006
	calr DSP_BlockCopyForward
	calr AccPatch_AdvancePrevEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60e30
	jr t, AccPatch_NullRet2
BlockCopy_FwdEqual_AdvIXLoop:
.Lc_f60e30:
	calr AccPatch_AdvancePrevEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60e12
	jr t, AccPatch_NullRet2
BlockCopy_FwdEqual_StoreBounds:
	ldw	bc, 255
	sub	bc, 6
	ld	(13742:16), bc
	ld	(13740:16), bc
AccPatch_NullRet2:
	ret

BlockCopy_FwdIXSmaller:
	ldw WA, 0x00ff
	sub	wa, (0x35a6:16)
	ldw BC, 0x00ff
	sub	bc, (0x35a8:16)
	sub WA,BC
	ld	(0x359c:16), wa
	ldw BC, 0x00ff
	sub BC,0x0006
	sub BC,WA
	ld	(0x359e:16), bc
	ld xiy, 0:i3
	ld	iy, (0x35a6:16)
	ld xix, 0:i3
	ld	ix, (0x35a8:16)
	ldw BC, 0x00ff
	sub	bc, (0x35a8:16)
	calr DSP_BlockCopyForward
	calr AccPatch_AdvancePrevEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60e8f
	jr t, AccPatch_NullRet3
BlockCopy_FwdIXSmall_CopyOff:
.Lc_f60e8f:
	ld	bc, (0x359c:16)
	calr DSP_BlockCopyForward
	calr AccPatch_AdvancePrevEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60ea2
	jr t, AccPatch_NullRet3
BlockCopy_FwdIXSmall_CheckDE:
.Lc_f60ea2:
	cp	de, (0x35a0:16)
	jr nz, .Lc_f60eaa
	jr t, BlockCopy_FwdIXSmall_StoreBounds
BlockCopy_FwdIXSmall_CopyRem:
.Lc_f60eaa:
	ld	bc, (0x359e:16)
	calr DSP_BlockCopyForward
	calr AccPatch_AdvancePrevEntry_IX
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60ebd
	jr t, AccPatch_NullRet3
BlockCopy_FwdIXSmall_CopyOff2:
.Lc_f60ebd:
	ld	bc, (0x359c:16)
	calr DSP_BlockCopyForward
	calr AccPatch_AdvancePrevEntry_IY
	cp (GLOBAL_ERROR_CODE:16), 0x00
	jr z, .Lc_f60ea2
	jr t, AccPatch_NullRet3
BlockCopy_FwdIXSmall_StoreBounds:
	ld	wa, (13726:16)
	ld	(13742:16), wa
	ldw	wa, 255
	sub	wa, 6
	ld	(13740:16), wa
AccPatch_NullRet3:
	ret

AccPatch_ForwardBlockCopy:
	cp	(GLOBAL_ERROR_CODE:16), 0
	jr	nz, AccPatch_DoneBlockCopy
	ldw	wa, 254
	sub	wa, (0x35aa:16)
	ld	bc, (0x35ac:16)
	sub	bc, wa
	ld	(0x35b0:16), bc
	cp	(0x35ae:16), bc
	jr	nc, FwdBlockCopy_UseFull
	jr	FwdBlockCopy_UseSmaller
FwdBlockCopy_UseFull:
	calr DSP_BlockCopyForward
	jr AccPatch_DoneBlockCopy

FwdBlockCopy_UseSmaller:
	ld	bc, (0x35ae:16)
	calr	DSP_BlockCopyForward
	calr	AccPatch_AdvancePrevEntry_IX
	cp	(GLOBAL_ERROR_CODE:16), 0
	jr	z, FwdBlockCopy_CopyRemainder
	jr	AccPatch_DoneBlockCopy
FwdBlockCopy_CopyRemainder:
	; ldw_d16 xbc, (0x3668) (v7 patched)
	ld	bc, (0x35b0:16)
	; subda16 xbc, 0x3666 (v7 patched)
	sub	bc, (0x35ae:16)
	; calr DSP_BlockCopyForward (v7 displacement)
	calr	DSP_BlockCopyForward
AccPatch_DoneBlockCopy:
	ret

AccPatch_AdvancePrevEntry_IX:
	ld	xix, (0x3594:16)
	ld HL,(XIX+0x03)
	ld	(0x35a2:16), hl
	calr AccPatch_GetEntryAddr
	bit 7,(XIX)
	jr nz, AdvPrevEntry_IX_StoreAndReset
	ld (GLOBAL_ERROR_CODE:16), 0x0b
	jr t, AdvPrevEntry_IX_Return
AdvPrevEntry_IX_StoreAndReset:
	ld	(13716:16), xix
	ld	xix, 0:i3
	ld	ix, 6:i3
AdvPrevEntry_IX_Return:
	ret

AccPatch_AdvancePrevEntry_IY:
	push XIX
	ld	xix, (0x3598:16)
	ld HL,(XIX+0x03)
	ld	(0x35a0:16), hl
	calr AccPatch_GetEntryAddr
	bit 7,(XIX)
	jr nz, AdvPrevEntry_IY_StoreAndReset
	ld (GLOBAL_ERROR_CODE:16), 0x0b
	jr t, AdvPrevEntry_IY_Return
AdvPrevEntry_IY_StoreAndReset:
	ld	(13720:16), xix
	ld	xiy, 0:i3
	ld	iy, 6:i3
AdvPrevEntry_IY_Return:
	pop xix
	ret

AccPatch_CheckEmpty:
	call TempoRingBuf_CheckEmpty
	ld wa, hl
	ret

TempoRingBuf_ReadByteToA:
	call TempoRingBuf_ReadByte
	ld a, l
	ret

TempoRingBuf_ReInitAndRet:
	call TempoRingBuf_Init
	ret

TempoRingBuf_PeekByte:
	call TempoRingBuf_SaveReadPos
	call TempoRingBuf_ReadAlternate
	ld a, l
	ret

AccPlayback_InitOrUpdate:
	and	(0x3418:16), 0xef
	ld	a, (CMP_RECORD_PART:16)
	and A,0x7f
	cp	a, (0x3458:16)
	jr	z, AccPlayback_CheckStyleMatch
	and	a, 31
	cp	a, 0:i3
	jr	z, AccPlayback_CheckStyleMatch
	or	(0x3418:16), 16
AccPlayback_CheckStyleMatch:
	ld	a, (CURRENT_TITLE:16)
	cp	a, 182
	jr	z, AccPlayback_CheckActiveStyle
	jrl	AccPlayback_Finalize
AccPlayback_CheckActiveStyle:
	cp	a, (0x346d:16)
	jr	z, AccPlayback_CheckBit4
	ld	(0x3445:16), 0
	call	TempoRingBuf_Init
	bit	0, (ACC_RUN_FLAGS:16)
	jr	nz, AccPlayback_GetSlotAddr
	or	(0x3415:16), 128
AccPlayback_GetSlotAddr:
	call AccPatch_GetCurrentSlotAddr
	call AccPatch_ReadVoiceStride
AccPlayback_CheckBit4:
	bit	4, (0x3418:16)
	jr	nz, AccPlayback_InitTimingVars
	ld	a, (13421:16)
	cp	a, 182
	jr	z, AccPlayback_InitOrUpdate_Skip
AccPlayback_InitTimingVars:
	ld	a, 0:opc
	ld	(13378:16), a
	ld	(13380:16), a
	ld	(13379:16), a
	ld	(ACC_VIEW_FIRST_MEASURE:16), a
	ldw	(13967:16), 1
	calr	AccPlayback_CalcTimingPosition
	call	AccPatch_GetCurrentSlotAddr
	call	AccPatch_ScanToSequenceStart
	ld	(CMP_STEP_MODE:16), 4
	ld	(STEP_VELOCITY:16), 255
	ld	(13418:16), 0
AccPlayback_CheckStateFlags:
	and	(0x3417:16), 127
AccPlayback_InitOrUpdate_Skip:
	and	(0x3418:16), 254
	ld	a, (13915:16)
	and	a, 192
	cp	a, 0:i3
	jr	z, AccPlayback_InitOrUpdate_Skip2
	or	(0x3418:16), 1
	calr	AccPlayback_AdjustBeatPosition
	calr	AccPlayback_CalcTimingPosition
	call	AccPatch_GetCurrentSlotAddr
	calr	AccVoice_InitPatternBuffer
AccPlayback_CheckSkipInit:
	or	(0xe2f6:16), 16
AccPlayback_InitOrUpdate_Skip2:
	bit	4, (0x3418:16)
	jr	nz, AccPlayback_ApplyChanges
	bit	0, (0x3418:16)
	jr	nz, AccPlayback_ApplyChanges
	ld	a, (13421:16)
	cp	a, 182
	jr	z, AccPlayback_CheckBit0_3
AccPlayback_ApplyChanges:
	; anddi8 (0x34d0), 223 (v7 patched)
	and	(0x3418:16), 223
	; calr AccPlayback_ProcessStyleChanges (v7 displacement)
	calr	AccPlayback_ProcessStyleChanges
	; anddi8 (0x34d0), 254 (v7 patched)
	and	(0x3418:16), 254
	; anddi8 (0x3713), 63 (v7 patched)
	and	(0x365b:16), 63
AccPlayback_CheckBit0_3:
	ld	a, (0x365b:16)
	and	a, 3
	cp	a, 0:i3
	jr	z, AccPlayback_ProcessMiscFlags
	calr	AccPlayback_ProcessPartChanges
	and	(0x365b:16), 252
AccPlayback_ProcessMiscFlags:
	ld	a, (0x3675:16)
	and	a, 63
	cp	a, 0:i3
	jr	z, AccPlayback_RunPeriodicTasks
	calr	AccPlayback_ProcessVoiceType5
	and	(0x3675:16), 192
AccPlayback_RunPeriodicTasks:
	calr AccPlayback_ReadEventLoop
	calr AccPlayback_ProcessBit5Change
	calr AccPlayback_ProcessTempoAdvance

AccPlayback_Finalize:
	calr AccPlayback_UpdateRhythmSustain
	ret

AccPlayback_Finalize_Code:
	nop
	nop
	pushw	hl
	and	hl, 4095
	sla	hl, 4
	popw	hl
	ret
	nop
	nop

; ============================================================================
; ToneGen_CalcBufferAddr - Compute tone generator buffer address
; ============================================================================
; Input:  HL = buffer index
; Output: XHL = 0x95c00 + (HL & 0xffff) * 256
; Calculates address into tone generator hardware buffer memory.
; Called from MIDI voice processing code (handles status bytes 0x81-0x91).
; ============================================================================
ToneGen_CalcBufferAddr:
	and xhl, 0xffff
	sla xhl, 8
	add xhl, RHYTHM_PATTERN_BUF_B
	ret

ToneGen_CalcBufferAddr_Pad:
	nop
	nop

AccPlayback_CalcTimingPosition:
	ld	a, (0x3442:16)
	inc 1,A
	xor W,W
	ld	(SQSTEP_MEASURE:16), wa
	calr ToneGen_StepFwd_Alternate
	jr t, AccTiming_ComputeOffset
	ld A, 0x20:opc
	cp	(0x3443:16), 0x04
	jr c, AccTiming_StorePartA
AccTiming_StorePartA:
	ld	(13924:16), a
AccTiming_ComputeOffset:
	ld	w, (13379:16)
	ld	a, 8:opc
	muls	wa, w
	ld	h, a
	ld	a, (13380:16)
	xor	w, w
	ld	l, 12:opc
	div	wa, l
	add	h, a
	inc	1, h
	ld	a, (13378:16)
	sub	a, (ACC_VIEW_FIRST_MEASURE:16)
	ld	w, 32:opc
	cp	(STYLE_SECTION_BEATS:16), 5
	jr	c, AccTiming_UseFullBar
	ld	w, 64:opc
AccTiming_UseFullBar:
	muls	wa, w
	add	h, a
	ld	(SQSTEP_CURSOR_STEP:16), h
	jr	AccTiming_CompareStyles
	cp	h, 32
jr	ule, AccTiming_StoreResult
	sub	h, 32
AccTiming_StoreResult:
	ld	(SQSTEP_CURSOR_STEP:16), h
AccTiming_CompareStyles:
	ld	a, (CURRENT_TITLE:16)
	cp	a, (ACTIVE_TITLE:16)
	jr	nz, AccTiming_Return
AccTiming_Return:
	ret

AccTiming_CompareStyles_Pad:
	nop
	nop

AccPlayback_AdjustBeatPosition:
	ld	wa, (SQSTEP_MEASURE:16)
	dec	1, a
	bit	7, (0x365b:16)
	jr	z, AccBeatAdj_CheckBit6
	inc	1, a
	cp	a, (STYLE_SECTION_LAST_MEASURE:16)
	jr	ule, AccBeatAdj_CheckBit6
	ld	a, 0:opc
AccBeatAdj_CheckBit6:
	bit	6, (0x365b:16)
	jr	z, AccBeatAdj_StoreAndClear
	dec	1, a
	cp	a, 255
	jr	nz, AccBeatAdj_StoreAndClear
	ld	a, (STYLE_SECTION_LAST_MEASURE:16)
AccBeatAdj_StoreAndClear:
	ld	(13378:16), a
	ld	(13380:16), 0
	ld	(13379:16), 0
	ret
AccBeatAdj_StoreAndClear_Pad:
	nop
	nop

AccVoice_InitPatternBuffer:
	ld	XHL,0x00003676
	ld wa, 0:i3
	push XWA
	push XHL
	push XBC
	push XDE
	push XIX
	push XIY
	push XIZ
	call AccAudio_LockAcquire
	pop XIZ
	pop XIY
	pop XIX
	pop XDE
	pop XBC
	pop XHL
	pop XWA
	ld (XHL),WA
	ld (XHL+0x02),WA
	ld (XHL+0x04),WA
	ld (XHL+0x06),WA
	ld (XHL+0x08),WA
	ld (XHL+0x0a),WA
	ld (XHL+0x0c),WA
	ld (XHL+0x0e),WA
	calr AccPlayback_InitPartAssignment
	ld	a, (ACC_VIEW_FIRST_MEASURE:16)
	ld	w, (STYLE_SECTION_BEATS:16)
	muls	wa, w
	ld	c, a
	jr	ToneGen_SkipToNoteEntry
	ld	a, (13378:16)
	ld	w, (STYLE_SECTION_BEATS:16)
	muls	wa, w
	ld	c, a
	cp	(STYLE_SECTION_BEATS:16), 5
	jr	c, ToneGen_SkipToNoteEntry
	cp	(13379:16), 4
	jr	c, ToneGen_SkipToNoteEntry
	add	c, 4
ToneGen_SkipToNoteEntry:
	pushw bc
	calr ToneGen_GetSlotIndex
	ld de, hl
	calr ToneGen_CalcBufferAddr
	ld xix, 6:i3
	add xix, xhl
	popw bc

ToneGen_SkipLoop:
	cp c, 0:i3
	jr z, ToneGen_ParseAllEvents
	ld a, (xix)
	cp a, 0x81
	jr nz, ToneGen_SkipLoop_ReadNext
	dec 1, c

ToneGen_SkipLoop_ReadNext:
	calr ToneGen_ReadBufferWithIndirection
	jr ToneGen_SkipLoop

ToneGen_ParseAllEvents:
	ld	(13398:16), 0
	ld	c, (13958:16)
	calr	ToneGen_ParseEventBuffer
	inc	1, (13398:16)
	ld	c, (13959:16)
	calr	ToneGen_ParseEventBuffer
	inc	1, (13398:16)
	ld	c, (13960:16)
	calr	ToneGen_ParseEventBuffer
	inc	1, (13398:16)
	ld	c, (13961:16)
	calr	ToneGen_ParseEventBuffer
	ld	a, (CURRENT_TITLE:16)
	cp	a, (ACTIVE_TITLE:16)
	jr	nz, ToneGen_SaveRegsAndCall
	ld	(58102:16), 16
ToneGen_SaveRegsAndCall:
	push xwa
	push xhl
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	call AccAudio_LockRelease
	pop xiz
	pop xiy
	pop xix
	pop xde
	pop xbc
	pop xhl
	pop xwa
	ret

ToneGen_SaveRegsAndCall_Pad:
	nop
	nop

ToneGen_ParseEventBuffer:
	ld	(13399:16), 0
EventBuffer_ParseLoop:
	cp c, 0:i3
	jr nz, EventBuffer_ReadByte
	jrl ToneGen_ParseEvent_Done

EventBuffer_ReadByte:
	ld	a, (xix)
	cp	a, 129
	jr	nz, EventBuffer_CheckNoteType
	dec	1, c
	inc	1, (13399:16)
	calr	ToneGen_ReadBufferWithIndirection
	jr	EventBuffer_ParseLoop
EventBuffer_CheckNoteType:
	cp a, 0x90
	jr z, ToneGen_MapNoteToOctaveBitmask
	cp a, 0x91
	jr z, ToneGen_MapNoteToOctaveBitmask
	cp a, 0xd1
	jr z, ToneGen_MapNoteToOctaveBitmask
	cp a, 0xd2
	jr z, ToneGen_MapNoteToOctaveBitmask
	cp a, 0xd3
	jr z, ToneGen_MapNoteToOctaveBitmask
	cp a, 0xd4
	jr z, ToneGen_MapNoteToOctaveBitmask
	cp a, 0xd5
	jr z, ToneGen_MapNoteToOctaveBitmask
	cp a, 0xd6
	jr z, ToneGen_MapNoteToOctaveBitmask
	calr ToneGen_ReadBufferWithIndirection
	jr EventBuffer_ParseLoop

ToneGen_MapNoteToOctaveBitmask:
	calr ToneGen_ReadBufferWithIndirection
	ld a, (xix)
	xor w, w
	ld l, 0xc:opc
	div wa, l
	pushw bc
	push xix
	and a, 0x7
	ld c, a
	xor b, b
	ld xix, ToneGen_MapNoteToOctaveBitmask_Code
	ld	c, (xix+bc)
	jr ToneGen_MapNote_OrMask
	; Bit mask lookup table (powers of 2):
ToneGen_MapNoteToOctaveBitmask_Code:
	normal
	push	sr
	max
	ld	(P4:8), 32:io
	.byte 0x40, 0x80

ToneGen_MapNote_OrMask:
	ld	l, (13399:16)

	xor h, h

	ld	a, (13398:16)

	and a, 0x3

	sla a, 2

	add l, a

	ld	xix, 13942

	ld	a, (xix+hl)

	or a, c

	ld	(xix+hl), a

	pop xix

	popw bc

	; calr ToneGen_ReadBufferWithIndirection (v7 displacement)
	calr	ToneGen_ReadBufferWithIndirection
	; jrl EventBuffer_ParseLoop (v7 displacement)
	jrl	EventBuffer_ParseLoop
ToneGen_ParseEvent_Done:
	ret

ToneGen_MapNote_OrMask_Pad:
	nop
	nop

AccPlayback_ProcessStyleChanges:
	ld	(SQSTEP_CURSOR_STEP:16), 1
	ld	(CMP_STEP_MODE:16), 4
	ld	(STEP_VELOCITY:16), 255
	push	xwa
	push	xhl
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
call	UI_PostTimerResetEvent
	pop	xiz
	pop	xiy
	pop	xix
	pop	xde
	pop	xbc
	pop	xhl
	pop	xwa
	ld	a, 0:opc
	ld	(13375:16), a
	ld	(13379:16), a
	ld	(13380:16), a
	ld	wa, (SQSTEP_MEASURE:16)
	dec	1, a
	ld	(13378:16), a
	call	AccPatch_GetCurrentSlotAddr
	calr	AccPlayback_CalcTimingPosition
	calr	AccVoice_InitPatternBuffer
	ret
AccStyleChange_CheckPartCount:
	nop
	nop

AccPlayback_ProcessPartChanges:
	and	(0x346a:16), 115
	cp	(0x3444:16), 0
	jr	nz, AccPartChange_Bit1
	or	(0x346a:16), 4
AccPartChange_Bit1:
	bit	0, (0x365b:16)
	jr	nz, AccPartChange_CheckBit2
	calr	ToneGen_ProcessWithRestore
	jrl	ToneGen_UpdateAndInitPattern
AccPartChange_CheckBit2:
	bit	5, (0x3418:16)
	jr	z, AccPartChange_Done
	calr	ToneGen_ScanRestoredVoiceEvents
	jr	AccPartChange_ProcessBit2
AccPartChange_Done:
	call AccPatch_GetCurrentSlotAddr
	calr ToneGen_ProcessVoiceSlots

AccPartChange_ProcessBit2:
	calr ToneGen_CalcNoteWithWrap
	cp bc, wa
	jr ugt, AccPartChange_StoreResult
	jr ToneGen_CalcAndRestart_Join

AccPartChange_StoreResult:
	; anddi8 (0x34d0), 223 (v7 patched)
	and	(0x3418:16), 223
ToneGen_CalcAndRestart:
	calr ToneGen_RecalcAndRestart
	jrl ToneGen_UpdateAndInitPattern

ToneGen_CalcAndRestart_Join:
	ld	wa, (ACC_READ_BLOCK:16)
	ld	(PATTERN_CURSOR_BLOCK:16), wa
	ld	wa, (ACC_READ_OFFSET:16)
	ld	(PATTERN_CURSOR_OFFSET:16), wa
	or	(0x3418:16), 32
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	cp	a, 129
	jr	nz, ToneGen_PushAndReadType
	calr	ToneGen_StepToNextVoiceSlot
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	cp	a, 144
	jr	z, ToneGen_ProcessVoiceEvent
	cp	a, 145
	jr	z, ToneGen_ProcessVoiceEvent
	cp	a, 209
	jr	z, ToneGen_ProcessVoiceEvent
	cp	a, 210
	jr	z, ToneGen_ProcessVoiceEvent
	cp	a, 211
	jr	z, ToneGen_ProcessVoiceEvent
	cp	a, 212
	jr	z, ToneGen_ProcessVoiceEvent
	cp	a, 213
	jr	z, ToneGen_ProcessVoiceEvent
	cp	a, 214
	jr	z, ToneGen_ProcessVoiceEvent
	jr	ToneGen_CalcAndRestart
ToneGen_ProcessVoiceEvent:
	calr	AccVoice_ReadCurrentToneType
	cp	a, 0:i3
	jr	nz, ToneGen_CalcAndRestart	; -> 0xF61356
	ld	wa, (ACC_READ_BLOCK:16)
	ld	(PATTERN_CURSOR_BLOCK:16), wa
	ld	wa, (ACC_READ_OFFSET:16)
	ld	(PATTERN_CURSOR_OFFSET:16), wa
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	pushw	wa
	push	xhl
	calr	ToneGen_AdvancePeriodWrap
	pop	xhl
	popw	wa
ToneGen_PushAndReadType:
	pushw	wa
	calr	AccVoice_ReadCurrentToneType
	ld	w, a
	ld	(13380:16), w
	popw	wa
	calr	ToneGen_ClassifyAndDispatch
ToneGen_UpdateAndInitPattern:
	; anddi8 (0x34cf), 127 (v7 patched)
	and	(0x3417:16), 127
	; calr AccPlayback_CalcTimingPosition (v7 displacement)
	calr	AccPlayback_CalcTimingPosition
	; call AccPatch_GetCurrentSlotAddr (v7 addr)
	call	AccPatch_GetCurrentSlotAddr
	; calr AccVoice_InitPatternBuffer (v7 displacement)
	calr	AccVoice_InitPatternBuffer
	; ordi8 0xe3e0, 16 (v7 patched)
	or	(0xe2f6:16), 16
	ret



ToneGen_VoiceSlotLookupTable:
	.byte	0x00, 0x00
; ToneGen_PartBitToNoteOnStatus: 17-byte table indexed by the one-hot record part 0x36FF & 31: the MIDI note-on status
;   byte written to the rhythm buffer for that part -- AC1 (1) 0x94, AC2 (2) 0x95, AC3 (4) 0x96, BAS (8) 0x97, DRM
;   (16) 0x98; other slots 0. Basis: readers + bytes -- ToneGen_ClassifyMonoEvent defaults the part to 16 and
;   ToneGen_ClassifyMono_MapChannel writes (status, note E, velocity D) with RhythmBuf_WriteByte, after closing the
;   previous note as (status, note, 0).
ToneGen_PartBitToNoteOnStatus:	.byte	0x00, 0x94, 0x95, 0x00, 0x96, 0x00
	.byte 0x00, 0x00, 0x97, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x98

ToneGen_ProcessWithRestore:
	bit	5, (13336:16)
	jr	z, ToneGen_ProcessRestore_Direct
	calr	ToneGen_RestoreFromSavedPos
	jr	ToneGen_ProcessRestore_CalcPos
ToneGen_ProcessRestore_Direct:
	.byte	0x1d, 0xbb, 0xe4, 0xf5	; call AccPatch_GetCurrentSlotAddr (v7 addr)

	.byte 0x1e, 0x53, 0x08	; calr ToneGen_ProcessVoiceSlots (v7 displacement)

	.byte	0xc1, 0x6a, 0x34, 0x3c, 0xfe	; anddi8 (0x3522), 254 (v7 patched)



ToneGen_ProcessRestore_CalcPos:
	calr	ToneGen_CalcNotePosition
	ld	bc, (13416:16)
	cp	bc, wa
	jr	c, ToneGen_ProcessRestore_CheckDelta
	sub	bc, wa
	cp	bc, 512
	jr	ugt, ToneGen_ProcessRestore_CheckDelta
	jr	ToneGen_ProcessRestore_UseSaved
ToneGen_ProcessRestore_CheckDelta:
	cp	bc, 0:i3
	jr	nz, ToneGen_ProcessRestore_ClearBit5
	bit	3, (0x346a:16)
	jr	z, ToneGen_ProcessRestore_ClearBit5
	jr	ToneGen_ProcessRestore_UseSaved
ToneGen_ProcessRestore_ClearBit5:
	; anddi8 (0x34d0), 223 (v7 patched)
	and	(0x3418:16), 223
ToneGen_ProcessRestore_CalcNote:
	ld	a, (13380:16)
	ld	e, a
	xor	w, w
	ld	l, 12:opc
	div	wa, l
	cp	w, 0:i3
	jr	nz, ToneGen_ProcessRestore_AdjNote
	ld	w, 12:opc
ToneGen_ProcessRestore_AdjNote:
	calr	ToneGen_AdjustNoteWrap
	ld	a, 4:opc
	ld	(CMP_STEP_MODE:16), a
	ld	w, 255:opc
	ld	(STEP_VELOCITY:16), 255
	jr	ToneGen_ProcessRestore_Return
ToneGen_ProcessRestore_UseSaved:
	bit	0, (0x346a:16)
	jr	nz, ToneGen_ProcessRestore_UseActive
	ld	wa, (0x3462:16)
	ld	(PATTERN_CURSOR_BLOCK:16), wa
	ld	(ACC_READ_BLOCK:16), wa
	ld	wa, (0x3466:16)
	ld	(PATTERN_CURSOR_OFFSET:16), wa
	ld	(ACC_READ_OFFSET:16), wa
	jr	ToneGen_ProcessRestore_SetBit5
ToneGen_ProcessRestore_UseActive:
	ld	wa, (ACC_READ_BLOCK:16)
	ld	(PATTERN_CURSOR_BLOCK:16), wa
	ld	wa, (ACC_READ_OFFSET:16)
	ld	(PATTERN_CURSOR_OFFSET:16), wa
ToneGen_ProcessRestore_SetBit5:
	or	(0x3418:16), 32
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	a, (xhl+wa)
	cp	a, 129
	jr	nz, ToneGen_ProcessRestore_ReadType
	bit	7, (0x3417:16)
	jr	z, ToneGen_ProcessRestore_JumpCalc
	and	(0x3418:16), 223
	and	(0x3417:16), 127
ToneGen_ProcessRestore_JumpCalc:
	jr ToneGen_ProcessRestore_CalcNote

ToneGen_ProcessRestore_ReadType:
	pushw	wa
	calr	AccVoice_ReadCurrentToneType
	ld	w, (13380:16)
	sub	w, a
	jr	nc, ToneGen_ProcessRestore_WrapOctave
	add	w, 96
ToneGen_ProcessRestore_WrapOctave:
	ld	e, (13380:16)
	calr	ToneGen_AdjustNoteWrap
	popw	wa
	calr	ToneGen_ClassifyAndDispatch
ToneGen_ProcessRestore_Return:
	ret

ToneGen_ProcessRestore_WrapOctave_Pad:
	nop
	nop

ToneGen_RestoreFromSavedPos:
	ld	iy, (PATTERN_CURSOR_OFFSET:16)
	ld	(ACC_READ_OFFSET:16), iy
	ld	wa, (PATTERN_CURSOR_BLOCK:16)
	ld	(ACC_READ_BLOCK:16), wa
	ld	a, 0:opc
	ld	(ACC_EVENT_PATTERN_NOTE:16), a
	and	(0x346a:16), 253
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	cp	a, 129
	jr	nz, ToneGen_EventDispatchLoop
	or	(0x346a:16), 2
	and	(0x346a:16), 251
ToneGen_EventDispatchLoop:
	calr	ToneGen_StepVoiceForward
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	bit	7, a
	jr	z, ToneGen_EventDispatchLoop	; -> 0xF61537
	cp	a, 129
	jrl	z, ToneGen_Velocity_HandleEnd	; -> 0xF615D6
	cp	a, 131
	jr	z, ToneGen_EventDisp_EndOfBlock	; -> 0xF61584
	cp	a, 144
	jr	z, ToneGen_CalcEventVelocity_WithFlags	; -> 0xF6159F
	cp	a, 145
	jr	z, ToneGen_CalcEventVelocity_WithFlags	; -> 0xF6159F
	cp	a, 209
	jr	z, ToneGen_CalcEventVelocity_WithFlags	; -> 0xF6159F
	cp	a, 210
	jr	z, ToneGen_CalcEventVelocity_WithFlags	; -> 0xF6159F
	cp	a, 211
	jr	z, ToneGen_CalcEventVelocity_WithFlags	; -> 0xF6159F
	cp	a, 212
	jr	z, ToneGen_CalcEventVelocity_WithFlags	; -> 0xF6159F
	cp	a, 213
	jr	z, ToneGen_CalcEventVelocity_WithFlags	; -> 0xF6159F
	cp	a, 214
	jr	z, ToneGen_CalcEventVelocity_WithFlags	; -> 0xF6159F
	jr	ToneGen_EventDispatchLoop	; -> 0xF61537
ToneGen_EventDisp_EndOfBlock:
	call	AccPatch_GetCurrentSlotAddr
	calr	ToneGen_GetSlotIndex
	ld	(ACC_READ_BLOCK:16), hl
	calr	ToneGen_CalcBufferAddr
	ld	ix, 6:i3
	ld	(ACC_READ_OFFSET:16), ix
	ld	(ACC_EVENT_PATTERN_NOTE:16), 6
	jr	ToneGen_EventDispatchLoop
ToneGen_CalcEventVelocity_WithFlags:
	calr	AccVoice_ReadCurrentToneType
	ld	c, a
	ld	b, (0x3443:16)
	bit	1, (0x346a:16)
	jr	z, ToneGen_Velocity_SkipDec
	dec	1, b
	cp	b, 255
	jr	nz, ToneGen_Velocity_SkipDec
	ld	b, (STYLE_SECTION_BEATS:16)
	dec	1, b
	ld	a, (STYLE_SECTION_BEATS:16)
	ld	w, (0x3442:16)
	dec	1, w
	cp	w, 255
	jr	nz, ToneGen_Velocity_Multiply
	ld	w, (STYLE_SECTION_LAST_MEASURE:16)
ToneGen_Velocity_Multiply:
	muls wa, w
	add b, a
	jr ToneGen_Velocity_Store

ToneGen_Velocity_SkipDec:
	jr VoiceVelocity_CalcDone

ToneGen_Velocity_HandleEnd:
	bit	7, (0x346a:16)
	jr	nz, VoiceVelocity_CalcDone
	bit	2, (0x346a:16)
	jr	z, ToneGen_Velocity_DefaultCalc
	or	(0x346a:16), 2
	or	(0x346a:16), 128
	jrl	ToneGen_EventDispatchLoop
ToneGen_Velocity_DefaultCalc:
	ld	c, 0:opc
	ld	b, (13379:16)
	dec	1, b
	cp	b, 255
	jr	nz, VoiceVelocity_CalcDone
	ld	b, (STYLE_SECTION_BEATS:16)
	dec	1, b
VoiceVelocity_CalcDone:
	ld	a, (STYLE_SECTION_BEATS:16)
	ld	w, (13378:16)
	muls	wa, w
	add	b, a
ToneGen_Velocity_Store:
	; stda16 (0x3520), xbc (v7 patched)
	ld	(0x3468:16), bc
	; ordi8 0x3522, 1 (v7 patched)
	or	(0x346a:16), 1
	ret



ToneGen_Velocity_Store_Pad:
	nop
	nop

ToneGen_CalcNotePosition:
	ld	a, (13380:16)
	ld	e, a
	xor	w, w
	ld	l, 12:opc
	div	wa, l
	ld	d, (13379:16)
	ld	bc, wa
	ld	a, (STYLE_SECTION_BEATS:16)
	ld	w, (13378:16)
	muls	wa, w
	add	d, a
	ld	wa, bc
	cp	w, 0:i3
	jr	nz, ToneGen_CalcPos_SubOctave
	ld	w, 12:opc
ToneGen_CalcPos_SubOctave:
	ld	a, e
	sub	a, w
	jr	nc, ToneGen_CalcPos_Return
	add	a, 96
	dec	1, d
	cp	d, 255
	jr	nz, ToneGen_CalcPos_Return
	ld	d, (STYLE_SECTION_BEATS:16)
	dec	1, d
	or	(0x346a:16), 8
ToneGen_CalcPos_Return:
	ld w, d
	ret

ToneGen_CalcPos_SubOctave_Pad:
	nop
	nop

ToneGen_AdjustNoteWrap:
	ld	a, e
	sub	a, w
	jr	c, ToneGen_AdjWrap_AddOctave
	ld	(13380:16), a
	jr	SustainLevel_SetExit
ToneGen_AdjWrap_AddOctave:
	add	a, 96
	ld	(13380:16), a
	ld	a, (13379:16)
	dec	1, a
	cp	a, 255
	jr	z, ToneGen_AdjWrap_WrapBar
	ld	(13379:16), a
	jr	SustainLevel_SetExit
ToneGen_AdjWrap_WrapBar:
	ld	a, (STYLE_SECTION_BEATS:16)
	dec	1, a
	ld	(13379:16), a
	ld	a, (13378:16)
	dec	1, a
	cp	a, 255
	jr	z, ToneGen_AdjWrap_WrapMeasure
	ld	(13378:16), a
	jr	SustainLevel_SetExit
ToneGen_AdjWrap_WrapMeasure:
	ld	a, (STYLE_SECTION_LAST_MEASURE:16)
	and	a, 7
	ld	(13378:16), a
SustainLevel_SetExit:
	ret

SustainLevel_SetExit_Pad:
	nop
	nop

ToneGen_ScanRestoredVoiceEvents:
	ld	iy, (PATTERN_CURSOR_OFFSET:16)
	ld	(ACC_READ_OFFSET:16), iy
	ld	wa, (PATTERN_CURSOR_BLOCK:16)
	ld	(ACC_READ_BLOCK:16), wa
	ld	a, 0:opc
	ld	(ACC_EVENT_PATTERN_NOTE:16), a
ToneGen_ScanRestored_Loop:
	calr	ToneGen_StepToNextVoiceSlot
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	cp	a, 129
	jrl	z, ToneGen_ScanRestored_EndMarker	; -> 0xF6173D
	cp	a, 131
	jr	z, ToneGen_ScanRestored_EndBlock	; -> 0xF6170B
	cp	a, 144
	jr	z, ToneGen_CalcEventVelocity_Restored	; -> 0xF61726
	cp	a, 145
	jr	z, ToneGen_CalcEventVelocity_Restored	; -> 0xF61726
	cp	a, 209
	jr	z, ToneGen_CalcEventVelocity_Restored	; -> 0xF61726
	cp	a, 210
	jr	z, ToneGen_CalcEventVelocity_Restored	; -> 0xF61726
	cp	a, 211
	jr	z, ToneGen_CalcEventVelocity_Restored	; -> 0xF61726
	cp	a, 212
	jr	z, ToneGen_CalcEventVelocity_Restored	; -> 0xF61726
	cp	a, 213
	jr	z, ToneGen_CalcEventVelocity_Restored	; -> 0xF61726
	cp	a, 214
	jr	z, ToneGen_CalcEventVelocity_Restored	; -> 0xF61726
	jr	ToneGen_ScanRestored_Loop	; -> 0xF616C3
ToneGen_ScanRestored_EndBlock:
	call	AccPatch_GetCurrentSlotAddr
	calr	ToneGen_GetSlotIndex
	ld	(ACC_READ_BLOCK:16), hl
	calr	ToneGen_CalcBufferAddr
	ld	ix, 6:i3
	ld	(ACC_READ_OFFSET:16), ix
	ld	(ACC_EVENT_PATTERN_NOTE:16), 6
	jr	ToneGen_ScanRestored_Loop
ToneGen_CalcEventVelocity_Restored:
	calr	AccVoice_ReadCurrentToneType
	ld	c, a
	ld	b, (13379:16)
	ld	a, (STYLE_SECTION_BEATS:16)
	ld	w, (13378:16)
	muls	wa, w
	add	b, a
	jr	ToneGen_ScanRestored_Return
ToneGen_ScanRestored_EndMarker:
	ld	c, 0:opc
	ld	b, (13379:16)
	inc	1, b
	ld	a, (STYLE_SECTION_BEATS:16)
	ld	w, (13378:16)
	muls	wa, w
	add	b, a
ToneGen_ScanRestored_Return:
	ret

ToneGen_ScanRestored_EndMarker_Pad:
	nop
	nop

ToneGen_GetSlotIndex:
	ld	a, (CMP_RECORD_PART:16)
	and	a, 31
	cp	a, 0:i3
	jr	nz, ToneGen_GetSlot_Lookup
	or	a, 16
	ld	(CMP_RECORD_PART:16), a
ToneGen_GetSlot_Lookup:
	call MapBitFlagsToChannelOffset
	ld l, w
	xor h, h
	ld	hl, (xiy+hl)
	ret

ToneGen_GetSlot_Lookup_Pad:
	nop
	nop

ToneGen_CalcNoteWithWrap:
	ld	a, (13380:16)
	ld	e, a
	xor	w, w
	ld	l, 12:opc
	div	wa, l
	ld	a, e
	sub	a, w
	add	a, 12
	ld	w, (13379:16)
	cp	a, 96
	jr	nz, ToneGen_CalcWrap_Store
	ld	a, 0:opc
	inc	1, w
ToneGen_CalcWrap_Store:
	ld	hl, wa
	ld	a, (STYLE_SECTION_BEATS:16)
	ld	w, (13378:16)
	muls	wa, w
	add	h, a
	ld	wa, hl
	ret
ToneGen_CalcWrap_Store_Pad:
	nop
	nop

ToneGen_RecalcAndRestart:
	ld	a, (13380:16)
	ld	e, a
	xor	w, w
	ld	l, 12:opc
	div	wa, l
	ld	a, e
	sub	a, w
	add	a, 12
	calr	ToneGen_StoreNoteOrWrap
	ld	(CMP_STEP_MODE:16), 4
	ld	(STEP_VELOCITY:16), 255
	ret
ToneGen_RecalcAndRestart_Pad:
	nop
	nop

ToneGen_StoreNoteOrWrap:
	cp	a, 96
	jr	z, ToneGen_AdvancePeriodWrap
	ld	(13380:16), a
	jr	PitchValidate_Exit
ToneGen_AdvancePeriodWrap:
	ld	(13380:16), 0
	ld	a, (13379:16)
	inc	1, a
	cp	a, (STYLE_SECTION_BEATS:16)
	jr	z, ToneGen_PeriodWrap_NextBar
	ld	(13379:16), a
	jr	PitchValidate_Exit
ToneGen_PeriodWrap_NextBar:
	ld	(13379:16), 0
	ld	a, (13378:16)
	inc	1, a
	ld	w, (STYLE_SECTION_LAST_MEASURE:16)
	and	w, 7
	inc	1, w
	cp	a, w
	jr	z, ToneGen_PeriodWrap_ResetBar
	ld	(13378:16), a
	jr	PitchValidate_Exit
ToneGen_PeriodWrap_ResetBar:
	ld	(13378:16), 0
PitchValidate_Exit:
	ret

ToneGen_PeriodWrap_ResetBar_Pad:
	nop
	nop

ToneGen_ClassifyAndDispatch:
	cp a, 0xd1
	jr z, ToneGen_ClassifyStereoType
	cp a, 0xd2
	jr z, ToneGen_ClassifyStereoType
	cp a, 0xd3
	jr z, ToneGen_ClassifyStereoType
	cp a, 0xd4
	jr z, ToneGen_ClassifyStereoType
	cp a, 0xd5
	jr z, ToneGen_ClassifyStereoType
	cp a, 0xd6
	jr z, ToneGen_ClassifyStereoType
	calr ToneGen_ClassifyMonoEvent
	jr ToneGen_Classify_Return

ToneGen_ClassifyStereoType:
	calr ToneGen_ClassifyStereoEvent

ToneGen_Classify_Return:
	ret

ToneGen_ClassifyStereoType_Pad:
	nop
	nop

ToneGen_ClassifyStereoEvent:
	ld A, 0x05:opc
	ld	(CMP_STEP_MODE:16), a
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	ld E, 0x01:opc
	cp A,0xd2
	jr z, .Lc_f61878
	ld E, 0x02:opc
	cp A,0xd1
	jr z, .Lc_f61878
	ld E, 0x03:opc
	cp A,0xd3
	jr z, .Lc_f61878
	ld E, 0x04:opc
	cp A,0xd4
	jr z, .Lc_f61878
	ld E, 0x05:opc
	cp A,0xd5
	jr z, .Lc_f61878
	ld E, 0x06:opc
ToneGen_ClassifyStereoSlot_Common:
.Lc_f61878:
	ld	(CONTROL_LINE_KIND:16), e
	calr ToneGen_StepToNextStereoSlot
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	ld	(CONTROL_LINE_VALUE:16), a
	ret
ToneGen_ClassifyStereoSlot_Common_Pad:
	nop
	nop

ToneGen_ClassifyMonoEvent:
	ld A, 0x04:opc
	ld	(CMP_STEP_MODE:16), a
	calr ToneGen_StepToNextStereoSlot
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	ld	(STEP_NOTE:16), a
	calr ToneGen_StepToNextVoiceSlot
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	w, (xhl+wa)
	ld	(STEP_VELOCITY:16), w
	ld	a, (STEP_NOTE:16)
	ld DE,WA
	ld	a, (CMP_RECORD_PART:16)
	and A,0x1f
	cp a, 0:i3
	jr nz, .Lc_f618e2
	or A,0x10
	ld	(CMP_RECORD_PART:16), a
ToneGen_ClassifyMono_MapChannel:
.Lc_f618e2:
	ld L,A
	xor H,H
	ld XIY,ToneGen_PartBitToNoteOnStatus
	ld	a, (xiy+hl)
	cp	(0x3460:16), 0x00
	jr z, .Lc_f6191a
	pushw de
	pushw wa
	ld	a, (0x345e:16)
	pushw wa
	call RhythmBuf_WriteByte
	inc 2,XSP
	ld	a, (0x345f:16)
	pushw wa
	call RhythmBuf_WriteByte
	inc 2,XSP
	ld A, 0x00:opc
	pushw wa
	call RhythmBuf_WriteByte
	inc 2,XSP
	popw wa
	popw de
ToneGen_ClassifyMono_WriteNew:
.Lc_f6191a:
	pushw de
	pushw wa
	pushw wa
	call RhythmBuf_WriteByte
	inc 2,XSP
	ld A,E
	pushw wa
	call RhythmBuf_WriteByte
	inc 2,XSP
	ld A,D
	pushw wa
	call RhythmBuf_WriteByte
	inc 2,XSP
	popw wa
	popw de
	ld	(0x345e:16), a
	ld	(0x345f:16), e
	ld A, 0x10:opc
	ld	(0x3460:16), a
	bit	4, (CMP_RECORD_PART:16)
	jr z, ToneGen_ClassifyMono_Return
	ld	a, (STEP_NOTE:16)
	ld w, (PANEL_PART_DRUM:16)
	push XWA
	push XBC
	push XDE
	push XIX
	push XIY
	ld E,A
	xor D,D
	ld C,W
	xor B,B
	ld wa, 1:i3
call SndParam_ValueMapLookup
	pop XIY
	pop XIX
	pop XDE
	pop XBC
	pop XWA
	ld A,L
	ld	(STEP_NOTE:16), a
ToneGen_ClassifyMono_Return:
	ret

ToneGen_ClassifyMono_WriteNew_Pad:
	nop
	nop

AccPlayback_ReadEventLoop:
	and	(0x3418:16), 0x7f
AccPlayback_ReadEvt_CheckEmpty:
	call AccPatch_CheckEmpty
	cp wa, 0:i3
	jr z, AccPlayback_ReadEvt_CheckBit7
	bit	7, (0x3418:16)
	jr nz, AccPlayback_ReadEvt_CheckBit7
	call TempoRingBuf_ReadByteToA
	cp A,0x90
	jr nz, AccPlayback_ReadEvt_Continue
	calr AccPlayback_ProcessNoteOnEvent
AccPlayback_ReadEvt_Continue:
	jr AccPlayback_ReadEvt_CheckEmpty

AccPlayback_ReadEvt_CheckBit7:
	bit	7, (0x3418:16)
	jr	z, ToneGenSetup_Done
	cpw	(STYLE_FREE_BLOCKS:16), 0
	jr	nz, AccPlayback_ReadEvt_HasEntries
	ld	(GLOBAL_ERROR_CODE:16), 15
	ld	(0xe2f2:16), 238
	ld	(0xe2f4:16), 64
	and	(0x3418:16), 127
	ld	a, 8:opc
	call	MIDI_SendSysExCmd
	jr	ToneGenSetup_Done
AccPlayback_ReadEvt_HasEntries:
	and	(0x3418:16), 223
	calr	ToneGen_CalcTempo
	bit	4, (CMP_RECORD_PART:16)
	jr	z, AccPlayback_ReadEvt_Overflow
	calr	AccPlayback_NoteOn_Check91
	jr	AccPlayback_ReadEvt_OverflowOK
AccPlayback_ReadEvt_Overflow:
	calr AccPlayback_AdvPattern_Loop

AccPlayback_ReadEvt_OverflowOK:
	call	AccPatch_GetCurrentSlotAddr
	calr	AccPlayback_ProcessOngoingEvents
	calr	ToneGen_AdvanceByTempo
	calr	AccPlayback_CalcTimingPosition
	call	AccPatch_GetCurrentSlotAddr
	calr	AccVoice_InitPatternBuffer
	ld	(CMP_STEP_MODE:16), 4
	ld	(STEP_VELOCITY:16), 255
	ld	a, (CURRENT_TITLE:16)
	cp	a, (ACTIVE_TITLE:16)
	jr	nz, ToneGenSetup_Done
	ld	(58102:16), 16
ToneGenSetup_Done:
	ret

AccPlayback_ReadEvt_Return:
	nop
	nop

AccPlayback_ProcessNoteOnEvent:
	call TempoRingBuf_ReadByteToA
	call TempoRingBuf_ReadByteToA
	ld	(ACC_EVENT:16), a
	call TempoRingBuf_ReadByteToA
	ld	(0x3376:16), a
	call TempoRingBuf_ReadByteToA
	cp	(0x3376:16), 0x00
	jr nz, .Lc_f61a26
	jr t, AccPlayback_NoteOn_WriteVoice
AccPlayback_NoteOn_ReadParams:
.Lc_f61a26:
	ld	l, (0x3445:16)
	cp l, 5:i3
	jr ugt, AccPlayback_NoteOn_Store
	xor H,H
	ld	XIY,0x00003448
	ld	a, (ACC_EVENT:16)
	ld	(xiy+hl), a
	ld	a, (0x3376:16)
	pushw hl
	add HL,0x0006
	ld	(xiy+hl), a
	popw hl
	inc 1,L
	ld	(0x3445:16), l
	cp	l, (0x3446:16)
	jr ule, AccPlayback_NoteOn_Store
	ld	(0x3446:16), l
AccPlayback_NoteOn_Store:
	jr TimeoutCounter_CheckExit

AccPlayback_NoteOn_WriteVoice:
	ld	a, (0x3445:16)
	dec	1, a
	cp	a, 255
	jr	z, TimeoutCounter_CheckExit
	ld	(0x3445:16), a
	cp	a, 0:i3
	jr	nz, TimeoutCounter_CheckExit
	or	(0x3418:16), 128
TimeoutCounter_CheckExit:
	ret

AccPlayback_NoteOn_SetBit:
	nop
	nop

AccPlayback_NoteOn_Check91:
	ld	wa, 0:i3
	ld	(13650:16), wa
	ld	e, (13382:16)
	xor	h, h
	ld	xix, 13384
	ld	xiy, 13746
AccPlayback_NoteOn_WritePan:
	cp	e, 0:i3
	jr	z, AccPlayback_NoteOn_Return
	ld	l, e
	dec	1, l
	addw	(0x3552:16), 6
	ld	(xiy), 144
	inc	1, xiy
	calr	ToneGen_WriteVoiceEventEntry
	dec	1, e
	jr	AccPlayback_NoteOn_WritePan
AccPlayback_NoteOn_Return:
	ret

AccPlayback_NoteOn_WritePan_Pad:
	nop
	nop

ToneGen_WriteVoiceEventEntry:
	ld	a, (13380:16)

	ld (xiy), a

	inc 1, xiy

	ld	a, (xix+hl)

	ld (xiy), a

	inc 1, xiy

	pushw hl

	add hl, 0x6

	ld	a, (xix+hl)

	ld (xiy), a

	popw hl

	inc 1, xiy

	ld	a, (ACC_EVENT:16)

	ld (xiy), a

	inc 1, xiy

	ld	a, (13174:16)

	ld (xiy), a

	inc 1, xiy

	ret



AccPlayback_AdvancePattern:
	nop
	nop

AccPlayback_AdvPattern_Loop:
	ld	wa, 0:i3
	ld	(13650:16), wa
	ld	e, (13382:16)
	xor	h, h
	ld	xix, 13384
	ld	xiy, 13746
AccPlayback_AdvPattern_Check81:
	cp	e, 0:i3
	jr	z, AccPlayback_AdvPattern_Nop
	ld	l, e
	dec	1, l
	calr	AccPlayback_AdvanceRingBuffer
	bit	0, (0x3379:16)
	jr	nz, AccPlayback_AdvPattern_Check90
	addw	(0x3552:16), 6
	ld	(xiy), 144
	inc	1, xiy
	calr	ToneGen_WriteVoiceEventEntry
	jr	AccPlayback_AdvPattern_Done
AccPlayback_AdvPattern_Check90:
	; adddi16 0x360a, 8 (v7 patched)
	addw	(0x3552:16), 8
	ld (xiy), 0x91

	inc 1, xiy

	; calr ToneGen_WriteVoiceEventEntry (v7 displacement)
	calr	ToneGen_WriteVoiceEventEntry
	; ldb_d8 a, (0x3432) (v7 patched)
	ld	a, (0x337a:16)
	ld (xiy), a

	inc 1, xiy

	ld	a, (ACC_EVENT_EXT1:16)

	ld (xiy), a

	inc 1, xiy



AccPlayback_AdvPattern_Done:
	dec 1, e
	jr AccPlayback_AdvPattern_Check81

AccPlayback_AdvPattern_Nop:
	ret

AccPlayback_AdvPattern_Nop_Pad:
	nop
	nop

AccPlayback_AdvanceRingBuffer:
	ld	a, (0x3431:16)
	and	a, 15
	cp	a, 0:i3
	jr	z, AccPlayback_TrackPosition
	call	AccPatch_ReadTransposeAmount
	cp	a, (0x3996:16)
	jr	ugt, AccPlayback_AdvanceRingBuffer_Join
	sub	(xix+hl), a
	jr	nc, AccPlayback_AdvRingBuf_Return
	ld	a, 12:opc
	add	(xix+hl), a
AccPlayback_AdvRingBuf_Return:
	jr AccPlayback_TrackPosition

AccPlayback_AdvanceRingBuffer_Join:
	ld w, 0xc:opc
	sub w, a
	add	(xix+hl), w

AccPlayback_TrackPosition:
	ld	a, (xix+hl)
	push	xix
	xor	w, w
	ld	xix, Note_PitchClassTable
	ld	a, (xix+wa)
	pop	xix
	bit	4, (0x3432:16)
	jr	z, AccPlayback_TrackPosition_Join
	ld	c, a
	push	xix
	xor	w, w
	ld	xix, AccPlayback_TrackPosition_Data
	ld	a, (xix+wa)
	pop	xix
	bit	0, a
	jr	z, AccPlayback_TrackPos_Return
	inc	1, c
	ld	a, (xix+hl)
	inc	1, a
	ld	(xix+hl), a
AccPlayback_TrackPos_Return:
	ld a, c

AccPlayback_TrackPosition_Join:
	bit	6, (0x3432:16)
	jr	z, AccPlayback_TrackPos_WrapCheck
	bit	3, (CMP_RECORD_PART:16)
	jr	z, AccPlayback_TrackPos_WrapCheck
	jr	AccPlayback_TrackPos_WrapDone
AccPlayback_TrackPos_WrapCheck:
	bit	5, (0x3432:16)
	jr	z, ToneGen_LoadRhythmPatternParams
	bit	3, (CMP_RECORD_PART:16)
	jr	nz, ToneGen_LoadRhythmPatternParams
AccPlayback_TrackPos_WrapDone:
	cp	a, 7:i3
	jr	nz, ToneGen_LoadRhythmPatternParams
	ld	(13177:16), 1
	ld	(13178:16), 3
	ld	(ACC_EVENT_EXT1:16), 0
	jr	AccPlayback_StyleRecalc_Return
ToneGen_LoadRhythmPatternParams:
	xor	xbc, xbc
	ld	c, a
	sla	a, 1
	add	c, a
	push	xix
	ld	xix, ToneGen_PitchClassNoteFormTable
	add	xix, xbc
	ld	a, (xix)
	ld	(13177:16), a
	ld	a, (xix+1)
	ld	(13178:16), a
	ld	a, (xix+2)
	ld	(ACC_EVENT_EXT1:16), a
	pop	xix
AccPlayback_StyleRecalc_Return:
	ret

ToneGen_LoadRhythmPatternParams_Pad:
; ToneGen_LoadRhythmPatternParams_Pad -- NOT padding; the name is historical (it is also the base of
; the __pad_F62002_0x* symbols in shared/positional_labels.s, so it is kept).
; ** RE-TYPED 2026-09-25 (lane accomp): was nop/normal/scf mnemonics
; (data-as-code).  The same two tables as AccPatch_TransposeNoteTable, read
; by the playback path instead of the patch path:
;   AccPlayback_TrackPosition: ld xix, AccPlayback_TrackPosition_Data / ldb_sri a,(xix+wa)
;       with A = a byte of Note_PitchClassTable; bit 0 set ->
;       the note index is incremented.
;   ToneGen_LoadRhythmPatternParams: c = a, then sla a,1 / add c,a (3a) /
;       ld xix, ToneGen_PitchClassNoteFormTable / add xix,xbc; (xix), (xix+1), (xix+2) are
;       stored to (0x3431), (0x3432), (0x3433).
; Sizes as in AccPatch_TransposeNoteTable: 12 flag bytes between the two
; reader offsets, then 12 three-byte records ending at
; AccPlayback_ProcessOngoingEvents.
; readers in v7 (address from the linked ELF): AccPlayback_TrackPosition 0xF61B6A,
;     ToneGen_LoadRhythmPatternParams 0xF61BD7
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; +0x00  2 B, not addressed by either reader
	.byte 0x00, 0x00
; +0x02  12 x u8, flag byte per index (bit 0 tested)
AccPlayback_TrackPosition_Data:
	.byte 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
; +0x0E  12 x 3-byte records {(0x3431), (0x3432), (0x3433)}
; ToneGen_PitchClassNoteFormTable: 12 x 3-byte records indexed by pitch class (note mod 12 via
;   Note_PitchClassTable): {flag, byte +6, byte +7}; flag 0 = plain 6-byte 0x90 note event, flag 1 =
;   8-byte 0x91 form with the two extra bytes. Non-zero: D#, E = (1, 0x00, 0x11), B = (1, 0x11, 0x11). Basis: readers
;   + bytes -- ToneGen_LoadRhythmPatternParams copies the record to 0x3395..0x3397; AccVoice_ResolveNoteOnOffType and
;   AccVoice_WriteNoteEventToBuffer pick 0x90 / 0x91 from it; the 4-byte twin AccPlay_NoteParamTable
;   (seq_event_playback.s) is read the same way.
ToneGen_PitchClassNoteFormTable:
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x01, 0x00, 0x11
	.byte 0x01, 0x00, 0x11
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00
	.byte 0x01, 0x11, 0x11
AccPlayback_ProcessOngoingEvents:
	and	(xiy+15), 127
	calr	ToneGen_ProcessVoiceSlots
	ld	wa, (ACC_READ_BLOCK:16)
	ld	(13642:16), wa
	xor	w, w
	ld	a, (ACC_EVENT_PATTERN_NOTE:16)
	ld	(13644:16), wa
	ld	(13197:16), wa
	ld	wa, (13642:16)
	ld	(13199:16), wa
	ld	wa, (13650:16)
	ld	(13203:16), wa
	call	AccPatch_InitSlotAndCopyData
	calr	ToneGen_AdvanceSeqList
	ld	(13382:16), 0
	bit	0, (ACC_RUN_FLAGS:16)
	jr	nz, ToneGen_NullRet
	cp	(13378:16), 0
	jr	nz, ToneGen_NullRet
	cp	(13379:16), 0
	jr	nz, ToneGen_NullRet
	cp	(13380:16), 48
	jr	ugt, ToneGen_NullRet
	or	(0x3415:16), 128
ToneGen_NullRet:
	ret

AccPlayback_Ongoing_HandleType:
	nop
	nop

ToneGen_ProcessVoiceSlots:
	calr AccPlayback_Ongoing_AdvSlot
	calr ToneGen_GetSlotIndex
	ld	(ACC_READ_BLOCK:16), hl
	calr ToneGen_CalcBufferAddr
	ldw	(ACC_READ_OFFSET:16), 0x0006
	ld	a, (0x3442:16)
	ld	w, (STYLE_SECTION_BEATS:16)
	muls	wa, w
	ld	d, a
	ld	a, (0x3443:16)
	add	d, a
	ld	e, (0x3444:16)
	and	(ACC_PART_FLAGS:16), 254
	xor	bc, bc
	ld	(ACC_EVENT_PATTERN_NOTE:16), 6
AccPlayback_Ongoing_NoteOff:
	bit	0, (ACC_PART_FLAGS:16)
	jr z, .Lc_f61cca
	jrl t, AccPlayback_Ongoing_Return
AccPlayback_Ongoing_NoteOffDone:
.Lc_f61cca:
	ld	iy, (ACC_READ_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	cp A,0x81
	jr nz, AccPlayback_Ongoing_D2Type
	add B,0x01
	xor C,C
	cp DE,BC
	jr c, .Lc_f61ced
	calr ToneGen_StepToNextVoiceSlot
	jr t, AccPlayback_Ongoing_D1_Return
AccPlayback_Ongoing_D1Type:
.Lc_f61ced:
	or	(ACC_PART_FLAGS:16), 0x01



AccPlayback_Ongoing_D1_Return:
	jr AccPlayback_Ongoing_NoteOff

AccPlayback_Ongoing_D2Type:
	calr	AccVoice_ReadCurrentToneType
	ld	c, a
	cp	de, bc
	jr	ule, AccPlayback_Ongoing_StoreDone
	calr	AccPlayback_Ongoing_D2Type_Helper
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	cp	a, 144
	jr	nz, AccPlayback_Ongoing_D2_Return
	calr	ToneGen_StepToNextStereoSlot
	calr	ToneGen_StepToNextStereoSlot
	calr	ToneGen_StepToNextStereoSlot
	jr	ToneGen_StepVoiceReturn
AccPlayback_Ongoing_D2_Return:
	cp a, 0x91
	jr nz, AccPlayback_Ongoing_WriteChan
	calr ToneGen_StepToNextStereoSlot
	calr ToneGen_StepToNextStereoSlot
	calr ToneGen_StepToNextStereoSlot
	calr ToneGen_StepToNextStereoSlot
	jr ToneGen_StepVoiceReturn

AccPlayback_Ongoing_WriteChan:
	cp a, 0xd1
	jr z, ToneGen_StepToNextStereoVoicePair
	cp a, 0xd2
	jr z, ToneGen_StepToNextStereoVoicePair
	cp a, 0xd3
	jr z, ToneGen_StepToNextStereoVoicePair
	cp a, 0xd4
	jr z, ToneGen_StepToNextStereoVoicePair
	cp a, 0xd5
	jr z, ToneGen_StepToNextStereoVoicePair
	cp a, 0xd6
	jr z, ToneGen_StepToNextStereoVoicePair
	jr AccPlayback_Ongoing_StorePan

ToneGen_StepToNextStereoVoicePair:
	calr ToneGen_StepToNextStereoSlot
	calr ToneGen_StepToNextVoiceSlot
	jr ToneGen_StepVoiceReturn

AccPlayback_Ongoing_StorePan:
	calr ToneGen_StepToNextVoiceSlot
	jr ToneGen_StepVoiceReturn

AccPlayback_Ongoing_StoreDone:
	; ordi8 0x32f4, 1 (v7 patched)
	or	(ACC_PART_FLAGS:16), 1
ToneGen_StepVoiceReturn:
	jrl AccPlayback_Ongoing_NoteOff

AccPlayback_Ongoing_Return:
	ret

ToneGen_StepVoiceReturn_Pad:
	nop
	nop

AccPlayback_Ongoing_AdvSlot:
	ld	wa, (13648:16)
	dec	1, a
	ld	(13412:16), a
	ld	e, a
	ld	wa, (13646:16)
	ld	(13410:16), wa
	ld	hl, wa
	calr	ToneGen_CalcBufferAddr
	ld	a, (13412:16)
	xor	w, w
	ld	(13414:16), wa
	ld	a, (STYLE_SECTION_LAST_MEASURE:16)
	inc	1, a
	ld	w, (STYLE_SECTION_BEATS:16)
	muls	wa, w
	dec	1, a
	ld	b, a
	xor	c, c
	ld	(13416:16), bc
	ret
AccPlayback_Ongoing_AdvDone:
	nop
	nop

AccPlayback_Ongoing_D2Type_Helper:
	ld	wa, (ACC_READ_BLOCK:16)
	ld	(13410:16), wa
	ld	a, (ACC_EVENT_PATTERN_NOTE:16)
	ld	(13412:16), a
	ld	wa, (ACC_READ_OFFSET:16)
	ld	(13414:16), wa
	ld	(13416:16), bc
	ret
AccPlayback_UpdateVoiceState:
	nop
	nop

ToneGen_AdvanceSeqList:
	calr ToneGen_InitPlaybackState
	ld	xhl, (0x3490:16)
	ld WA,(XHL)
	cp	wa, (0x338f:16)
	jr	z, AccPlayback_VoiceState_NoChange
	ld	de, (0x3389:16)
	calr	ToneGen_SearchVoiceBuffer
	jr	AccPlayback_VoiceState_Changed
AccPlayback_VoiceState_NoChange:
	ld	de, (0x3389:16)
	cp	de, (0x338d:16)
	jr	c, AccPlayback_VoiceState_Changed
	or	(0x3418:16), 64
AccPlayback_VoiceState_Changed:
	bit	6, (0x3418:16)
	jr	z, AccPlayback_VoiceState_Return
	ld	wa, (0x3393:16)
	add	de, wa
	cp	de, 255
	jr	nc, AccPlayback_VoiceState_CalcOff
	ld	ix, (0x3389:16)
	ld	wa, (0x3393:16)
	add	ix, wa
	ld	xhl, (0x3494:16)
	ld	(xhl), ix
	jr	AccPlayback_VoiceState_Return
AccPlayback_VoiceState_CalcOff:
	ld	hl, (13436:16)
	calr	ToneGen_CalcBufferAddr
	ld	hl, (xhl+3)
	ld	xix, (13456:16)
	ld	(xix), hl
	ld	ix, 6:i3
	sub	de, 255
	add	ix, de
	ld	xhl, (13460:16)
	ld	(xhl), ix
AccPlayback_VoiceState_Return:
	ret

AccPlayback_VoiceState_CalcOff_Pad:
; AccPlayback_VoiceState_CalcOff_Pad -- NOT padding; the name is historical (base of the
; __pad_F62230_0x* symbols in shared/positional_labels.s, so it is kept).
; ** RE-TYPED 2026-09-25 (lane accomp): was `.byte 0x9d` / `ldw de,0` / nop
; runs (data-as-code).  Two parallel 17-entry tables of RAM pointers, indexed
; by the one-hot selector (0x379b) & 0x1F -- the playback-side twin of
; AccPatch_AdvPlayPos_DataBlock.  Read by ToneGen_InitPlaybackState:
;     ld a,(0x379b) / and a,0x1f (0 becomes 0x10) / sla a,2 / ld l,a /
;     ld xix, ToneGen_InitPlay_SetupTables_Data / ld_sril3 xix,(xix+hl) / ld (0x3548),xix
;     ld xix, ToneGen_InitPlay_SetupTables_Data_2 / ld_sril3 xix,(xix+hl) / ld (0x354c),xix
; and the two pointers are then dereferenced as words into (0x3441) and
; (0x3534).  Only the one-hot entries 1, 2, 4, 8 and 16 are non-zero, and they
; are the same ten pointers as AccPatch_AdvPlayPos_DataBlock's (checked on the
; v10 bytes).
; 17 entries each: 0x46 - 0x02 = 68 = 17*4, and 17*4 more bytes end exactly
; at ToneGen_SearchVoiceBuffer.
; readers in v7 (address from the linked ELF): ToneGen_InitPlaybackState 0xF62096
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; +0x00  2 B, not addressed by the reader
	.byte 0x00, 0x00
; +0x02  17 x LE32 -> (0x3548)
ToneGen_InitPlay_SetupTables_Data:
	.long	0x00000000, 0x000031e5, 0x000031e7, 0x00000000
	.long	0x000031e9, 0x00000000, 0x00000000, 0x00000000
	.long	0x000031e3, 0x00000000, 0x00000000, 0x00000000
	.long 0x00000000, 0x00000000, 0x00000000, 0x00000000
	.long	0x000031df
; +0x46  17 x LE32 -> (0x354c)
ToneGen_InitPlay_SetupTables_Data_2:
	.long	0x00000000, 0x000031d5, 0x000031d7, 0x00000000
	.long	0x000031d9, 0x00000000, 0x00000000, 0x00000000
	.long	0x000031d3, 0x00000000, 0x00000000, 0x00000000
	.long 0x00000000, 0x00000000, 0x00000000, 0x00000000
	.long	0x000031cf
ToneGen_SearchVoiceBuffer:
	call	AccPatch_GetCurrentSlotAddr
	ld	a, (CMP_RECORD_PART:16)
	and	a, 31
	cp	a, 0:i3
	jr	nz, ToneGen_SearchBuf_MapChannel
	or	a, 16
	ld	(CMP_RECORD_PART:16), a
ToneGen_SearchBuf_MapChannel:
	call MapBitFlagsToChannelOffset
	ld l, w
	xor h, h
	ld	wa, (xiy+hl)

ToneGen_SearchBuf_CompareLoop:
	cp	wa, (0x338f:16)
	jr	nz, ToneGen_SearchBuf_CheckEnd
	or	(0x3418:16), 64
	jr	ToneGen_SearchBuf_Return
ToneGen_SearchBuf_CheckEnd:
	cp	wa, (0x347c:16)
	jr	nz, ToneGen_SearchBuf_FollowChain
	jr	ToneGen_SearchBuf_Return
ToneGen_SearchBuf_FollowChain:
	ld hl, wa
	calr ToneGen_CalcBufferAddr
	ld wa, (xhl + 3)
	jr ToneGen_SearchBuf_CompareLoop

ToneGen_SearchBuf_Return:
	ret

ToneGen_SearchBuf_FollowChain_Pad:
	nop
	nop

AccPlayback_ProcessBit5Change:
	bit	5, (0x365b:16)
	jr nz, .Lc_f61f04
	jrl t, AccBit5_Return
AccBit5_CheckBit5Active:
.Lc_f61f04:
	bit	5, (0x3418:16)
	jr nz, .Lc_f61f0d
	jrl t, FlagClear_Exit
AccBit5_InitAndScan:
.Lc_f61f0d:
	and	(0x3418:16), 0xdf
	and	(0x3417:16), 0x7f
	ld	wa, (PATTERN_CURSOR_BLOCK:16)
	ld	(ACC_READ_BLOCK:16), wa
	ld	(0x35a2:16), wa
	ld	(0x3478:16), wa
	ld	iy, (PATTERN_CURSOR_OFFSET:16)
	ld	(0x3393:16), iy
	ld	(ACC_READ_OFFSET:16), iy
	ld	(0x35a8:16), iy
	ld WA,IY
	ld	(ACC_EVENT_PATTERN_NOTE:16), a
	ld	iy, (PATTERN_CURSOR_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	cp	a, 129
	jrl	z, FlagClear_Exit
	ld	(0x3395:16), 6
	cp	a, 144
	jr	z, AccBit5_StepTwice
	ld	(0x3395:16), 8
	cp	a, 145
	jr	z, AccBit5_StepOnce
	ld	(0x3395:16), 3
	cp	a, 209
	jr	z, AccVoice_InitPlaybackState
	cp	a, 210
	jr	z, AccVoice_InitPlaybackState
	cp	a, 211
	jr	z, AccVoice_InitPlaybackState
	cp	a, 212
	jr	z, AccVoice_InitPlaybackState
	cp	a, 213
	jr	z, AccVoice_InitPlaybackState
	cp	a, 214
	jr	z, AccVoice_InitPlaybackState
	jr	FlagClear_Exit
AccBit5_StepOnce:
	calr ToneGen_StepToNextStereoSlot

AccBit5_StepTwice:
	calr ToneGen_StepToNextStereoSlot
	calr ToneGen_StepToNextVoiceSlot

AccVoice_InitPlaybackState:
	calr	ToneGen_StepToNextStereoSlot
	calr	ToneGen_StepToNextVoiceSlot
	ld	wa, (ACC_READ_BLOCK:16)
	ld	(13728:16), wa
	ld	(13434:16), wa
	xor	w, w
	ld	a, (ACC_EVENT_PATTERN_NOTE:16)
	ld	(13734:16), wa
	calr	ToneGen_ScanVoicePosition
	call	AccPatch_CopySequenceEntry
	call	AccPatch_GetCurrentSlotAddr
	calr	AccVoice_InitPatternBuffer
	ld	(CMP_STEP_MODE:16), 4
	ld	(STEP_VELOCITY:16), 255
	ld	(58102:16), 16
FlagClear_Exit:
	; anddi8 (0x3713), 223 (v7 patched)
	and	(0x365b:16), 223
AccBit5_Return:
	ret

AccVoice_InitPlaybackState_Pad:
	nop
	nop

ToneGen_ScanVoicePosition:
	calr	ToneGen_InitPlaybackState
	call	AccPatch_GetCurrentSlotAddr
	calr	ToneGen_GetSlotIndex
	ld	de, hl
	calr	ToneGen_CalcBufferAddr
	ld	c, 3:opc
	ld	iy, 3:i3
	ld	(13419:16), 0
ToneGen_ScanPos_CompareLoop:
	cp	iy, (0x3393:16)
	jr	nz, ToneGen_ScanPos_CheckEnd
	cp	de, (0x3478:16)
	jr	nz, ToneGen_ScanPos_CheckEnd
	or	(0x346b:16), 1
	jr	VoiceState_CheckExit
ToneGen_ScanPos_CheckEnd:
	cp	iy, (ACC_READ_OFFSET:16)
	jr	nz, VoiceState_CheckExit
	cp	de, (0x347a:16)
	jr	nz, VoiceState_CheckExit
	or	(0x346b:16), 2
VoiceState_CheckExit:
	cp	iy, (0x3389:16)
	jr	nz, ToneGen_ScanPos_AdvanceStep
	cp	de, (0x347c:16)
	jr	nz, ToneGen_ScanPos_AdvanceStep
	jr	ToneGen_ScanPos_ProcessFlags
ToneGen_ScanPos_AdvanceStep:
	calr ToneGen_AdvanceVoiceStep
	jr ToneGen_ScanPos_CompareLoop

ToneGen_ScanPos_ProcessFlags:
	ld	a, (0x346b:16)
	and	a, 3
	cp	a, 0:i3
	jr	z, PlaybackState_InitDone
	bit	1, (0x346b:16)
	jr	nz, ToneGen_ScanPos_AdjustBit1
	ld	iy, (0x3393:16)
	ld	xix, (0x3494:16)
	ld	(xix), iy
	ld	xix, (0x3490:16)
	ld	(xix), de
	ld	(ACC_EVENT_PATTERN_NOTE:16), c
	jr	PlaybackState_InitDone
ToneGen_ScanPos_AdjustBit1:
	ld	iy, (13205:16)
	and	iy, 255
	ld	wa, iy
	sub	c, a
	jr	c, ToneGen_ScanPos_WrapBlock
	cp	c, 6:i3
	jr	c, ToneGen_ScanPos_WrapBlock
	ld	(ACC_EVENT_PATTERN_NOTE:16), c
	ld	xix, (13460:16)
	ld	wa, (xix)
	sub	wa, iy
	ld	(xix), wa
	ld	xix, (13456:16)
	ld	(xix), de
	jr	PlaybackState_InitDone
ToneGen_ScanPos_WrapBlock:
	sub	c, 7
	ld	(ACC_EVENT_PATTERN_NOTE:16), c
	ld	hl, de
	calr	ToneGen_CalcBufferAddr
	ld	wa, (xhl+1)
	ld	xix, (13456:16)
	ld	(xix), wa
	xor	w, w
	ld	a, c
	ld	xix, (13460:16)
	ld	(xix), iy
PlaybackState_InitDone:
	ret

PlaybackState_InitDone_Pad:
	nop
	nop

ToneGen_InitPlaybackState:
	and	(0x3418:16), 0xbf
	ld	a, (CMP_RECORD_PART:16)
	and A,0x1f
	cp a, 0:i3
	jr nz, .Lc_f620ad
	or A,0x10
	ld	(CMP_RECORD_PART:16), a
ToneGen_InitPlay_SetupTables:
.Lc_f620ad:
	sla A, 0x02
	ld L,A
	xor H,H
	ld XIX,ToneGen_InitPlay_SetupTables_Data
	ld	xix, (xix+hl)
	ld	(13456:16), xix
	ld	xix, ToneGen_InitPlay_SetupTables_Data_2
	ld	xix, (xix+hl)
	ld	(13460:16), xix
	ld	hl, (xix)
	ld	(13193:16), hl
	ld	xix, (13456:16)
	ld	hl, (xix)
	ld	(13436:16), hl
	ret
ToneGen_InitPlay_SetupTables_Pad:
	nop
	nop

ToneGen_AdvanceVoiceStep:
	inc 1, iy
	inc 1, c
	cp c, 0xff
	jr nz, ToneGen_AdvVoiceStep_Return
	ld hl, de
	calr ToneGen_CalcBufferAddr
	ld hl, (xhl + 3)
	ld de, hl
	calr ToneGen_CalcBufferAddr
	ld iy, 6:i3
	ld c, 0x6:opc

ToneGen_AdvVoiceStep_Return:
	ret

ToneGen_AdvanceVoiceStep_Pad:
	nop
	nop

AccPlayback_ProcessTempoAdvance:
	bit	2, (0x365b:16)
	jr z, AccPlayback_TempoAdv_Return
	and	(0x3418:16), 0xdf
	calr ToneGen_CalcTempo
	calr ToneGen_AdvanceByTempo
	calr AccPlayback_CalcTimingPosition
	call AccPatch_GetCurrentSlotAddr
	calr AccVoice_InitPatternBuffer
	ld	(CMP_STEP_MODE:16), 0x04
	ld	(STEP_VELOCITY:16), 0xff
	ld	(0xe2f6:16), 0x10
	and	(0x365b:16), 0xfb
AccPlayback_TempoAdv_Return:
	ret

AccPlayback_ProcessTempoAdvance_Pad:
	nop
	nop

ToneGen_CalcTempo:
	ld	l, (STEP_NOTE_VALUE:16)
	cp	l, 0:i3
	jr	nz, ToneGen_CalcTempo_Lookup
	ld	l, 6:opc
ToneGen_CalcTempo_Lookup:
	sla	l, 1
	xor	h, h
	push	xix
	ld	xix, ToneGen_CalcTempo_Lookup_Data
	ld	de, (xix+hl)
	ld	l, (STEP_PLUS_NOTE_VALUE:16)
	sla	l, 1
	ld	bc, (xix+hl)
	add	de, bc
	pop	xix
	ld	wa, de
	ld	l, 96:opc
	div	wa, l
	ld	(13175:16), w
	ld	(13176:16), a
	ld	a, (STEP_ARTICULATION:16)
	cp	a, 1:i3
	jr	nz, ToneGen_CalcTempo_Mode0	; -> 0xF62181
	sla	de, 2
	ld	wa, de
	xor	de, de
	ld	hl, 5:i3
	ld	qwa, de
	div	xwa, hl
	jr	ToneGen_CalcTempoBeatsAndTicks	; -> 0xF621AC
ToneGen_CalcTempo_Mode0:
	cp a, 0:i3
	jr nz, ToneGen_CalcTempo_Mode2
	ld wa, de
	sla wa, 4
	add wa, de
	add wa, de
	add wa, de
	xor de, de
	ldw hl, 0x14
	ldfr_werp DE, 0xe2
	div xwa, hl
	jr ToneGen_CalcTempoBeatsAndTicks

ToneGen_CalcTempo_Mode2:
	cp a, 2:i3
	jr nz, ToneGen_CalcTempo_Mode3
	srl de, 1
	ld wa, de
	jr ToneGen_CalcTempoBeatsAndTicks

ToneGen_CalcTempo_Mode3:
	srl de, 2
	ld wa, de

ToneGen_CalcTempoBeatsAndTicks:
	.byte	0x27, 0x60, 0xcf, 0x51, 0xf1, 0x75, 0x33, 0x40
	.byte	0xf1, 0x76, 0x33, 0x41, 0xc1, 0x17, 0x34, 0x3e
	.byte 0x80, 0x0e
ToneGen_CalcTempo_DataTable:
	.byte	0x00, 0x00
ToneGen_CalcTempo_Lookup_Data:	.byte	0x00, 0x00, 0x08, 0x00, 0x0c, 0x00
	.byte 0x10, 0x00, 0x18, 0x00, 0x20, 0x00, 0x30, 0x00
	.byte 0x40, 0x00, 0x60, 0x00, 0xc0, 0x00, 0x80, 0x01
	.byte 0x00, 0x03, 0x80, 0x04, 0x00, 0x06

ToneGen_AdvanceByTempo:
	ld	a, (13175:16)
	ld	w, (13176:16)
	add	a, (13380:16)
	cp	a, 96
	jr	c, ToneGen_AdvTempo_StoreNote
	sub	a, 96
	inc	1, w
ToneGen_AdvTempo_StoreNote:
	ld	(13380:16), a
	add	w, (13379:16)
	ld	l, (STYLE_SECTION_BEATS:16)
	ld	h, (STYLE_SECTION_LAST_MEASURE:16)
	and	h, 7
	inc	1, h
ToneGen_AdvTempo_WrapLoop:
	cp	w, l
	jr	c, ToneGen_AdvTempo_StoreBeat	; -> 0xF6221E
	sub	w, l
	inc	1, (13378:16)
	cp	h, (13378:16)
	jr	nz, ToneGen_AdvTempo_Continue	; -> 0xF6221C
	ld	(13378:16), 0
ToneGen_AdvTempo_Continue:
	jr ToneGen_AdvTempo_WrapLoop

ToneGen_AdvTempo_StoreBeat:
	ld	(13379:16), w
	ret
ToneGen_AdvTempo_StoreBeat_Pad:
	nop
	nop

AccPlayback_UpdateRhythmSustain:
	ld	a, (13408:16)
	cp	a, 0:i3
	jr	z, AccPlayback_RhythmSust_Return
	dec	1, a
	ld	(13408:16), a
	cp	a, 0:i3
	jr	nz, AccPlayback_RhythmSust_Return
	ld	a, (13406:16)
	ld	e, (13407:16)
	ld	d, 0:opc
	pushw	wa
call	RhythmBuf_WriteByte
	inc	2, xsp
	ld	a, e
	pushw	wa
call	RhythmBuf_WriteByte
	inc	2, xsp
	ld	a, d
	pushw	wa
call	RhythmBuf_WriteByte
	inc	2, xsp
AccPlayback_RhythmSust_Return:
	ret

AccPlayback_UpdateRhythmSustain_Pad:
	nop
	nop

AccPlayback_ProcessVoiceType5:
	bit	5, (0x3418:16)
	jr	z, AccVoice_DispatchType5Handler
	cp	(CMP_STEP_MODE:16), 4
	jr	nz, AccVoice_DispatchType5Handler
	ld	a, (0x3675:16)
	and	a, 12
	cp	a, 0:i3
	jr	z, AccVoiceType5_CheckBit01
	calr	ToneGen_AdjustVoiceVelocity
AccVoiceType5_CheckBit01:
	ld	a, (13941:16)
	and	a, 3
	cp	a, 0:i3
	jr	z, AccVoice_DispatchType5Handler
	calr	ToneGen_AdjustVolumePan
AccVoice_DispatchType5Handler:
	bit	5, (0x3418:16)
	jr	z, TempoCheck_Exit
	cp	(CMP_STEP_MODE:16), 5
	jr	nz, TempoCheck_Exit
	ld	a, (0x3675:16)
	and	a, 48
	cp	a, 0:i3
	jr	z, TempoCheck_Exit
	calr	ToneGen_ProcessStereoType
TempoCheck_Exit:
	ret

AccVoice_DispatchType5Handler_Pad:
	nop
	nop

ToneGen_AdjustVoiceVelocity:
	ld	wa, (PATTERN_CURSOR_OFFSET:16)
	ld	(ACC_READ_OFFSET:16), wa
	ld	wa, (PATTERN_CURSOR_BLOCK:16)
	ld	(ACC_READ_BLOCK:16), wa
	ld	(ACC_EVENT_PATTERN_NOTE:16), 0
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	cp	a, 129
	jrl	z, ToneGen_AdjVel_Return
	calr	ToneGen_StepToNextVoiceSlot
	calr	ToneGen_StepToNextVoiceSlot
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	bit	4, (CMP_RECORD_PART:16)
	jr	z, ToneGen_AdjVel_CheckBit2
	ld	w, (PANEL_PART_DRUM:16)
	push	xwa
	push	xbc
	push	xde
	push	xix
	push	xiy
	xor	d, d
	ld	e, a
	ld	c, w
	xor	b, b
	ld	wa, 1:i3
	call	SndParam_ValueMapLookup
	pop	xiy
	pop	xix
	pop	xde
	pop	xbc
	pop	xwa
	ld	a, l
ToneGen_AdjVel_CheckBit2:
	bit	2, (0x3675:16)
	jr	z, ToneGen_AdjVel_Decrement
	inc	1, a
	cp	a, 128
	jr	c, ToneGen_AdjVel_ClampHigh
	ld	a, 127:opc
ToneGen_AdjVel_ClampHigh:
	jr ToneGen_AdjVel_StoreAndParam

ToneGen_AdjVel_Decrement:
	dec 1, a
	cp a, 0xff
	jr nz, ToneGen_AdjVel_StoreAndParam
	ld a, 0x0:opc

ToneGen_AdjVel_StoreAndParam:
	ld	e, a
	bit	4, (CMP_RECORD_PART:16)
	jr	z, ToneGen_AdjVel_WriteToBuffer
	ld	w, (PANEL_PART_DRUM:16)
	push	xwa
	push	xbc
	push	xde
	push	xix
	push	xiy
	xor	bc, bc
	ld	c, w
	ld	wa, 2:i3
	xor	d, d
	call	SndParam_ValueMapLookup
	pop	xiy
	pop	xix
	pop	xde
	pop	xbc
	pop	xwa
	ld	a, l
ToneGen_AdjVel_WriteToBuffer:
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	pushw	ix
	ld	ix, (ACC_READ_OFFSET:16)
	ld	(xhl+ix), a
	ld	(STEP_NOTE:16), e
	popw	ix
	call	AccScreen_DrawInit_StackWrap
	ld	a, (CMP_RECORD_PART:16)
	and	a, 15
	cp	a, 0:i3
	jr	z, ToneGen_AdjVel_Return	; -> 0xF62371
	calr	ToneGen_WriteMultiChanParam
ToneGen_AdjVel_Return:
	ret

ToneGen_AdjVel_WriteToBuffer_Pad:
	nop
	nop

ToneGen_AdjustVolumePan:
	ld	wa, (PATTERN_CURSOR_OFFSET:16)
	ld	(ACC_READ_OFFSET:16), wa
	ld	wa, (PATTERN_CURSOR_BLOCK:16)
	ld	(ACC_READ_BLOCK:16), wa
	ld	(ACC_EVENT_PATTERN_NOTE:16), 0x00
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	cp A,0x81
	jr z, ToneGen_AdjVol_Return
	calr ToneGen_StepToNextVoiceSlot
	calr ToneGen_StepToNextVoiceSlot
	calr ToneGen_StepToNextVoiceSlot
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	bit	0, (0x3675:16)
	jr z, ToneGen_AdjVol_Decrement
	inc 1,A
	cp A,0x80
	jr c, ToneGen_AdjVol_ClampHigh
	ld A, 0x7f:opc
ToneGen_AdjVol_ClampHigh:
	jr ToneGen_AdjVol_WriteToBuffer

ToneGen_AdjVol_Decrement:
	dec 1, a
	cp a, 0:i3
	jr z, ToneGen_AdjVol_ClampLow
	cp a, 0xff
	jr nz, ToneGen_AdjVol_WriteToBuffer

ToneGen_AdjVol_ClampLow:
	ld a, 0x1:opc

ToneGen_AdjVol_WriteToBuffer:
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	pushw	ix
	ld	ix, (ACC_READ_OFFSET:16)
	ld	(xhl+ix), a
	ld	(STEP_VELOCITY:16), a
	popw	ix
	call	AccScreen_UpdateBeat_StackWrap
ToneGen_AdjVol_Return:
	ret

ToneGen_AdjVol_WriteToBuffer_Pad:
	nop
	nop

ToneGen_ProcessStereoType:
	ld	wa, (PATTERN_CURSOR_OFFSET:16)
	ld	(ACC_READ_OFFSET:16), wa
	ld	wa, (PATTERN_CURSOR_BLOCK:16)
	ld	(ACC_READ_BLOCK:16), wa
	ld	(ACC_EVENT_PATTERN_NOTE:16), 0
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	cp	a, 129
	jr	z, ToneGen_Stereo_Return
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	c, (xhl+wa)
	calr	ToneGen_StepToNextVoiceSlot
	calr	ToneGen_StepToNextVoiceSlot
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	wa, (ACC_READ_OFFSET:16)
	ld	a, (xhl+wa)
	cp	c, 211
	jr	z, ToneGen_Stereo_ClampLow
	bit	4, (0x3675:16)
	jr	z, ToneGen_Stereo_Increment
	inc	1, a
	cp	a, 128
	jr	c, ToneGen_Stereo_CheckInc
	ld	a, 127:opc
ToneGen_Stereo_CheckInc:
	jr ToneGen_Stereo_Decrement

ToneGen_Stereo_Increment:
	dec 1, a
	cp a, 0xff
	jr nz, ToneGen_Stereo_Decrement
	ld a, 0x0:opc

ToneGen_Stereo_Decrement:
	jr ToneGen_Stereo_WriteParam

ToneGen_Stereo_ClampLow:
	bit	4, (0x3675:16)
	jr	z, ToneGen_Stereo_Store
	ld	a, 127:opc
	jr	ToneGen_Stereo_WriteParam
ToneGen_Stereo_Store:
	ld a, 0x0:opc

ToneGen_Stereo_WriteParam:
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	pushw	ix
	ld	ix, (ACC_READ_OFFSET:16)
	ld	(xhl+ix), a
	ld	(CONTROL_LINE_VALUE:16), a
	popw	ix
	call	AccScreen_DrawMeasure_StackWrap
ToneGen_Stereo_Return:
	ret

	; Two tables of 120 distinct codes each, all in 0x01..0x7F (each set misses eight values), each after
	; the bytes 0e 00 00.  No reader found: no label reference, and no absolute pointer to them in the
	; ROM.  Were decoded as code and text (`push sr / .ascii "UVWX_`aR"` ..., `jp 0x1e1d1c`).
	.byte	0x00, 0x00, 0x0e, 0x00, 0x00
	.byte	0x02, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x5f, 0x60, 0x61, 0x52, 0x03
	.byte	0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x50, 0x69, 0x51, 0x6a, 0x27
	.byte	0x28, 0x2a, 0x2c, 0x2e, 0x24, 0x25, 0x26, 0x20, 0x1f, 0x29, 0x21, 0x2b
	.byte	0x22, 0x2d, 0x23, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37
	.byte	0x38, 0x39, 0x3a, 0x3d, 0x3e, 0x1b, 0x1c, 0x1d, 0x1e, 0x41, 0x42, 0x43
	.byte	0x44, 0x45, 0x6b, 0x6c, 0x19, 0x1a, 0x46, 0x18, 0x4c, 0x4b, 0x11, 0x12
	.byte	0x13, 0x14, 0x15, 0x16, 0x17, 0x4d, 0x4e, 0x4f, 0x0c, 0x0d, 0x0e, 0x0f
	.byte	0x10, 0x0a, 0x0b, 0x09, 0x47, 0x07, 0x08, 0x3b, 0x3c, 0x40, 0x3f, 0x05
	.byte	0x06, 0x49, 0x04, 0x4a, 0x48, 0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73
	.byte	0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f
	.byte	0x0e, 0x00, 0x00
	.byte	0x62, 0x5f, 0x5d, 0x5e, 0x58, 0x59, 0x5a, 0x5b, 0x5c, 0x4e, 0x4f, 0x50
	.byte	0x51, 0x52, 0x53, 0x54, 0x4b, 0x48, 0x49, 0x3d, 0x3e, 0x3f, 0x40, 0x28
	.byte	0x27, 0x2a, 0x2c, 0x2e, 0x24, 0x25, 0x26, 0x1f, 0x20, 0x29, 0x21, 0x2b
	.byte	0x22, 0x2d, 0x23, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37
	.byte	0x38, 0x39, 0x3a, 0x63, 0x64, 0x3b, 0x3c, 0x66, 0x65, 0x41, 0x42, 0x43
	.byte	0x44, 0x45, 0x4a, 0x60, 0x6c, 0x69, 0x6b, 0x4d, 0x4c, 0x55, 0x56, 0x57
	.byte	0x1b, 0x1d, 0x12, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x01, 0x02, 0x03
	.byte	0x04, 0x05, 0x07, 0x0f, 0x10, 0x11, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19
	.byte	0x1a, 0x1c, 0x1e, 0x46, 0x47, 0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72, 0x73
	.byte	0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x7e, 0x7f

ToneGen_WriteMultiChanParam:
	ld	hl, (ACC_READ_BLOCK:16)
calr	ToneGen_CalcBufferAddr
	ld	iy, (PATTERN_CURSOR_OFFSET:16)
	ld	d, (xhl+iy)
	xor	h, h
	ld	l, e
	push	xix
	ld	xix, Note_PitchClassTable
	ld	a, (xix+hl)
	pop	xix
	ld	e, 144:opc
	bit	6, (13362:16)
	jr	z, ToneGen_MultiChan_Compare
	bit	3, (CMP_RECORD_PART:16)
	jr	z, ToneGen_MultiChan_Compare
	jr	ToneGen_MultiChan_AdjustVel
ToneGen_MultiChan_Compare:
	bit	5, (13362:16)
	jr	z, AccVoice_ResolveNoteOnOffType
	bit	3, (CMP_RECORD_PART:16)
	jr	nz, AccVoice_ResolveNoteOnOffType
ToneGen_MultiChan_AdjustVel:
	cp a, 7:i3
	jr nz, AccVoice_ResolveNoteOnOffType
	ld e, 0x91:opc
	jr ToneGen_MultiChan_CheckBit4

AccVoice_ResolveNoteOnOffType:
	xor xhl, xhl
	ld l, a
	sla a, 1
	add l, a
	push xix
	ld xix, ToneGen_PitchClassNoteFormTable
	add xix, xhl
	ld a, (xix)
	pop xix
	cp a, 0:i3
	jr z, ToneGen_MultiChan_CheckBit4
	ld e, 0x91:opc

ToneGen_MultiChan_CheckBit4:
	cp d, 0x90
	jr nz, ToneGen_MultiChan_WriteNoteOff
	cp e, 0x90
	jr z, ToneGen_MultiChan_Done
	calr ToneGen_ReplaceCursorNoteEvent
	jr ToneGen_MultiChan_Done

ToneGen_MultiChan_WriteNoteOff:
	cp e, 0x90
	jr nz, ToneGen_MultiChan_Done
	calr ToneGen_ReplaceCursorNoteEvent

ToneGen_MultiChan_Done:
	ret

ToneGen_MultiChan_WriteFinalNote:
	nop
	nop

; ToneGen_ReplaceCursorNoteEvent: replaces the note event at the pattern cursor by its converted form:
;   saves its bytes (ToneGen_SaveCursorEventBytes), deletes it (ToneGen_DeleteEventAtCursor), builds the
;   0x90 / 0x91 event (ToneGen_BuildConvertedNoteEvent) and inserts it (ToneGen_StepWithBoundsCheck).
;   Basis: callers + body -- ToneGen_WriteMultiChanParam calls it when the stored status differs from the
;   one it computes.
ToneGen_ReplaceCursorNoteEvent:
	calr ToneGen_CompareVoiceBlocks_Helper
	calr ToneGen_CompareVoiceBlocks_Helper2
	calr ToneGen_CompareVoiceBlocks_Helper3
	calr ToneGen_StepWithBoundsCheck
	ret

ToneGen_MultiChan_Return:
	nop
	nop

ToneGen_CompareVoiceBlocks_Helper:
	ld	wa, (PATTERN_CURSOR_OFFSET:16)
	ld	(ACC_READ_OFFSET:16), wa
	ld	wa, (PATTERN_CURSOR_BLOCK:16)
	ld	(ACC_READ_BLOCK:16), wa
	ld	(ACC_EVENT_PATTERN_NOTE:16), 0x00
	ld	iy, (ACC_READ_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	ld	(0x337e:16), a
	calr ToneGen_StepToNextVoiceSlot
	ld	iy, (ACC_READ_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	ld	(0x337f:16), a
	calr ToneGen_StepToNextVoiceSlot
	ld	iy, (ACC_READ_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	ld	(0x3380:16), a
	calr ToneGen_StepToNextVoiceSlot
	ld	iy, (ACC_READ_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	ld	(0x3381:16), a
	calr ToneGen_StepToNextVoiceSlot
	ld	iy, (ACC_READ_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	ld	(0x3382:16), a
	calr ToneGen_StepToNextVoiceSlot
	ld	iy, (ACC_READ_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	ld	(0x3383:16), a
	ret
ToneGen_VoiceParamDisp_Return:
	nop
	nop

ToneGen_CompareVoiceBlocks_Helper2:
	ld	wa, (PATTERN_CURSOR_BLOCK:16)
	ld	(ACC_READ_BLOCK:16), wa
	ld	(0x35a2:16), wa
	ld	(0x3478:16), wa
	ld	iy, (PATTERN_CURSOR_OFFSET:16)
	ld	(0x3393:16), iy
	ld	(ACC_READ_OFFSET:16), iy
	ld	(0x35a8:16), iy
	ld WA,IY
	ld	(ACC_EVENT_PATTERN_NOTE:16), a
	ld	(0x3395:16), 0x06
	ld	iy, (PATTERN_CURSOR_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	cp A,0x90
	jr z, ToneGen_CalcBeatSubdivision
	ld	(0x3395:16), 0x08
	calr ToneGen_StepToNextVoiceSlot
	calr ToneGen_StepToNextVoiceSlot
ToneGen_CalcBeatSubdivision:
	calr	ToneGen_StepToNextVoiceSlot
	calr	ToneGen_StepToNextVoiceSlot
	calr	ToneGen_StepToNextVoiceSlot
	calr	ToneGen_StepToNextVoiceSlot
	calr	ToneGen_StepToNextVoiceSlot
	calr	ToneGen_StepToNextVoiceSlot
	ld	wa, (ACC_READ_BLOCK:16)
	ld	(13728:16), wa
	ld	(13434:16), wa
	xor	w, w
	ld	a, (ACC_EVENT_PATTERN_NOTE:16)
	ld	(13734:16), wa
	calr	ToneGen_ScanVoicePosition
	call	AccPatch_CopySequenceEntry
	ret
ToneGen_CalcBeat_Return:
	nop
	nop

ToneGen_CompareVoiceBlocks_Helper3:
	ld	XIY,0x000035b2
	ld	a, (0x337e:16)
	ld (XIY),A
	ld	a, (0x337f:16)
	ld (XIY+0x01),A
	ld	a, (0x3380:16)
	ld (XIY+0x02),A
	ld	a, (0x3381:16)
	ld (XIY+0x03),A
	ld	a, (0x3382:16)
	ld (XIY+0x04),A
	ld	a, (0x3383:16)
	ld (XIY+0x05),A
	ld	a, (0x3380:16)
	xor H,H
	ld L,A
	push XIX
	ld XIX,Note_PitchClassTable
	ld	a, (xix+hl)
	pop	xix
	bit	6, (0x3432:16)
	jr	z, ToneGen_ReadBufferUtility
	bit	3, (CMP_RECORD_PART:16)
	jr	z, ToneGen_ReadBufferUtility
	jr	ToneGen_ReadBufUtil_Loop
ToneGen_ReadBufferUtility:
	bit	5, (0x3432:16)
	jr	z, AccVoice_WriteNoteEventToBuffer
	bit	3, (CMP_RECORD_PART:16)
	jr	nz, AccVoice_WriteNoteEventToBuffer
ToneGen_ReadBufUtil_Loop:
	cp a, 7:i3
	jr nz, AccVoice_WriteNoteEventToBuffer
	ld (xiy), 0x91
	ld (xiy + 6), 0x3
	ld (xiy + 7), 0x0
	jr AccVoice_WriteNoteEventToBuffer_Join

AccVoice_WriteNoteEventToBuffer:
	xor xhl, xhl
	ld l, a
	sla a, 1
	add l, a
	push xix
	ld xix, ToneGen_PitchClassNoteFormTable
	add xix, xhl
	ld a, (xix)
	ld (xiy), 0x90
	cp a, 0:i3
	jr z, ToneGen_ReadBufUtil_Return
	ld (xiy), 0x91
	ld a, (xix + 1)
	ld (xiy + 6), a
	ld a, (xix + 2)
	ld (xiy + 7), a

ToneGen_ReadBufUtil_Return:
	pop xix

AccVoice_WriteNoteEventToBuffer_Join:
	ret

AccVoice_WriteNoteEventToBuffer_Pad:
	nop
	nop

ToneGen_StepWithBoundsCheck:
	cpw	(STYLE_FREE_BLOCKS:16), 0x0000
	jr z, ToneGen_SeqAdvanceMain
	ld	XIY,0x000035b2
	ld A,(XIY)
	ldw	(0x3552:16), 0x0006
	cp A,0x90
	jr z, ToneGen_StepBounds_Return
	ldw	(0x3552:16), 0x0008
ToneGen_StepBounds_Return:
	ld	wa, (PATTERN_CURSOR_BLOCK:16)
	ld	(ACC_READ_BLOCK:16), wa
	ld	iy, (PATTERN_CURSOR_OFFSET:16)
	ld	wa, iy
	ld	(ACC_EVENT_PATTERN_NOTE:16), a
	ld	wa, (ACC_READ_BLOCK:16)
	ld	(13642:16), wa
	xor	w, w
	ld	a, (ACC_EVENT_PATTERN_NOTE:16)
	ld	(13644:16), wa
	ld	wa, (13644:16)
	ld	(13197:16), wa
	ld	wa, (13642:16)
	ld	(13199:16), wa
	ld	wa, (13650:16)
	ld	(13203:16), wa
	call	AccPatch_InitSlotAndCopyData
	calr	ToneGen_AdvanceSeqList
	jr	ToneGen_SeqAdv_Return
ToneGen_SeqAdvanceMain:
	ld	(GLOBAL_ERROR_CODE:16), 15
	ld	(58098:16), 238
	ld	(58100:16), 64
	ld	a, 8:opc
call	MIDI_SendSysExCmd
ToneGen_SeqAdv_Return:
	ret

ToneGen_SeqAdvanceMain_Pad:
	nop
	nop

AccVoice_ReadCurrentToneType:
	push	xiy
	push	xhl
	xor	xiy, xiy
	ld	iy, (ACC_READ_OFFSET:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	add	xhl, xiy
	ld	a, (xhl+1)
	cp	a, 135
	jr	nz, ToneGen_InterpolateParam
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	hl, (xhl+3)
	calr	ToneGen_CalcBufferAddr
	ld	a, (xhl+6)
ToneGen_InterpolateParam:
	pop xhl
	pop xiy
	ret

ToneGen_Interp_Loop:
	nop
	nop

ToneGen_StepToNextVoiceSlot:
	push XIY
	push XHL
	ld	iy, (ACC_READ_OFFSET:16)
	inc 1,IY
	inc	1, (ACC_EVENT_PATTERN_NOTE:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	cp	a, 135
	jr	z, ToneGen_Interp_StoreResult
	cp	a, 131
	jr	nz, ToneGen_Interp_WrapPoint
	jr	ToneGen_Interp_CheckExit
ToneGen_Interp_StoreResult:
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	hl, (xhl+3)
	ld	(ACC_READ_BLOCK:16), hl
	calr	ToneGen_CalcBufferAddr
	ld	iy, 6:i3
	ld	(ACC_EVENT_PATTERN_NOTE:16), 6
	jr	ToneGen_Interp_WrapPoint
ToneGen_Interp_CheckExit:
	call	AccPatch_GetCurrentSlotAddr
	calr	ToneGen_GetSlotIndex
	ld	(ACC_READ_BLOCK:16), hl
	calr	ToneGen_CalcBufferAddr
	ld	iy, 6:i3
	ld	(ACC_EVENT_PATTERN_NOTE:16), 6
ToneGen_Interp_WrapPoint:
	ld	(ACC_READ_OFFSET:16), iy
	pop	xhl
	pop	xiy
	ret
ToneGen_Interp_Done:
	nop
	nop

ToneGen_StepToNextStereoSlot:
	push XIY
	push XHL
	ld	iy, (ACC_READ_OFFSET:16)
	inc 1,IY
	inc	1, (ACC_EVENT_PATTERN_NOTE:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	cp	a, 135
	jr	nz, ToneGen_Interp_Return
	calr	ToneGen_StepToNextBuffer
ToneGen_Interp_Return:
	inc	1, iy
	inc	1, (ACC_EVENT_PATTERN_NOTE:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	cp	a, 135
	jr	nz, ToneGen_Interp_OverflowCheck	; -> 0xF62900
	calr	ToneGen_StepToNextBuffer
ToneGen_Interp_OverflowCheck:
	ld	(ACC_READ_OFFSET:16), iy
	pop	xhl
	pop	xiy
	ret
ToneGen_Interp_OverflowDone:
	nop
	nop

ToneGen_StepToNextBuffer:
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	xor	iy, iy
	ld	hl, (xhl+3)
	ld	(ACC_READ_BLOCK:16), hl
	calr	ToneGen_CalcBufferAddr
	ld	iy, 6:i3
	ld	(ACC_EVENT_PATTERN_NOTE:16), 6
	ret
ToneGen_AdvanceBeatCounter:
	nop
	nop
	inc	1, iy
	cp	iy, bc
	jr	ule, ToneGen_AdvanceBeatCounter_Return
	ld iy, (xhl+0:8)
ToneGen_AdvanceBeatCounter_Return:
	ret
	nop
	nop

ToneGen_ReadBufferWithIndirection:
	push xhl
	inc 1, xix
	ld hl, de
	calr ToneGen_CalcBufferAddr
	ld a, (xix)
	cp a, 0x87
	jr nz, ToneGen_AdvBeat_Return
	ld hl, (xhl + 3)
	ld de, hl
	calr ToneGen_CalcBufferAddr
	ld xix, xhl
	add xix, 0x6

ToneGen_AdvBeat_Return:
	pop xhl
	ret

ToneGen_ReadBufferWithIndirection_Pad:
	nop
	nop

ToneGen_StepVoiceForward:
	push	xiy
	push	xhl
	ld	iy, (ACC_READ_OFFSET:16)
	dec	1, iy
	dec	1, (ACC_EVENT_PATTERN_NOTE:16)
	ld	hl, (ACC_READ_BLOCK:16)
	calr	ToneGen_CalcBufferAddr
	ld	a, (xhl+iy)
	cp	a, 135
	jr	nz, ToneGen_StepFwd_WrapDone
	ld	hl, (xhl+1)
	cp	hl, 65535
	jr	z, ToneGen_StepFwd_CheckWrap
	ld	(ACC_READ_BLOCK:16), hl
	calr	ToneGen_CalcBufferAddr
	ldw	iy, 254
	ld	(ACC_EVENT_PATTERN_NOTE:16), 254
	jr	ToneGen_StepFwd_WrapDone
ToneGen_StepFwd_CheckWrap:
	ld	hl, (13646:16)
	ld	(ACC_READ_BLOCK:16), hl
	calr	ToneGen_CalcBufferAddr
	ld	hl, (13648:16)
	dec	1, hl
	ld	iy, hl
	ld	(ACC_EVENT_PATTERN_NOTE:16), l
ToneGen_StepFwd_WrapDone:
	ld	(ACC_READ_OFFSET:16), iy
	pop	xhl
	pop	xiy
	ret
ToneGen_StepFwd_Exit:
	nop
	nop

ToneGen_StepFwd_Alternate:
	ld	e, (SQSTEP_MEASURE:16)
	ld	d, (0x368f:16)
	ld	c, (ACC_VIEW_FIRST_MEASURE:16)
	ld	b, (STYLE_SECTION_LAST_MEASURE:16)
	cp	(STYLE_SECTION_BEATS:16), 0x04
	jr ugt, ToneGen_StepAlt_Overflow
	cp b, 3:i3
	jr ugt, ToneGen_StepAlt_CheckBeat
	ld C, 0x00:opc
	jr t, ToneGen_StepAlt_Return
ToneGen_StepAlt_CheckBeat:
	calr AccTiming_ScrollFourBarViewForward
	calr AccTiming_ScrollFourBarViewBack
	calr AccTiming_WrapFourBarViewToEnd
	calr AccTiming_WrapFourBarViewToStart

ToneGen_StepAlt_Return:
	jr ToneGen_StepAlt_StoreResult

ToneGen_StepAlt_Overflow:
	cp b, 1:i3
	jr ugt, ToneGen_StepAlt_OverflowDone
	ld c, 0x0:opc
	jr ToneGen_StepAlt_StoreResult

ToneGen_StepAlt_OverflowDone:
	calr AccTiming_ScrollTwoBarViewForward
	calr AccTiming_ScrollTwoBarViewBack
	calr AccTiming_WrapTwoBarViewToEnd
	calr AccTiming_WrapTwoBarViewToStart

ToneGen_StepAlt_StoreResult:
	ld	(ACC_VIEW_FIRST_MEASURE:16), c
	xor	d, d
	ld	(13967:16), de
	calr	AccPlayback_DetectMeasurePos
	ret
ToneGen_StepAlt_Done:
	nop
	nop

; AccTiming_ScrollFourBarViewForward: Scrolls the four-measure view one measure forward: when more measures follow (B
;   = (0x343B) > C + 3), the previous measure D (0x36AB) was the view's last (C + 4) and the current one E (0x367E) is
;   D + 1, increments the view's first measure C (0x36AA). Basis: callers + body -- ToneGen_StepAlt_CheckBeat runs it
;   first among the four view checks used when (0x343D) <= 4 (the 0x20-pixel-per-measure layout of
;   AccTiming_ComputeOffset, x = (measure - (0x36AA)) * width); AccTiming_ScrollTwoBarViewForward is the same test for the
;   two-measure (0x40) layout (D == C + 2).
AccTiming_ScrollFourBarViewForward:
	ld a, c
	add a, 0x3
	cp b, a
	jr ule, AccTiming_ScrollFourBarViewForward_Ret
	inc 1, a
	cp a, d
	jr nz, AccTiming_ScrollFourBarViewForward_Ret
	ld a, d
	inc 1, a
	cp a, e
	jr nz, AccTiming_ScrollFourBarViewForward_Ret
	inc 1, c

AccTiming_ScrollFourBarViewForward_Ret:
	ret

AccTiming_ScrollFourBarViewForward_Pad:
	nop
	nop

; AccTiming_ScrollFourBarViewBack: four-measure view: when C > 0, B > C + 2 and the play moved back from
;   measure C + 1 (D) to C (E), scrolls the view one measure back, C = C - 1.
;   Called by ToneGen_StepFwd_Alternate with C = the first measure of the composer's measure view,
;   B = the section's last measure, D = the previous and E = the current play measure; returns C.
AccTiming_ScrollFourBarViewBack:
	cp c, 0:i3
	jr z, AccTiming_ScrollFourBarViewBack_Ret
	ld a, c
	add a, 0x2
	cp b, a
	jr ule, AccTiming_ScrollFourBarViewBack_Ret
	ld a, c
	inc 1, a
	cp a, d
	jr nz, AccTiming_ScrollFourBarViewBack_Ret
	ld a, d
	dec 1, a
	cp a, e
	jr nz, AccTiming_ScrollFourBarViewBack_Ret
	dec 1, c

AccTiming_ScrollFourBarViewBack_Ret:
	ret

AccTiming_ScrollFourBarViewBack_Pad:
	nop
	nop

; AccTiming_WrapFourBarViewToEnd: four-measure view: when C = 0 and the play wrapped from measure 1 (D)
;   to B + 1 (E), shows the last four measures, C = B - 3.
;   Called by ToneGen_StepFwd_Alternate with C = the first measure of the composer's measure view,
;   B = the section's last measure, D = the previous and E = the current play measure; returns C.
AccTiming_WrapFourBarViewToEnd:
	cp c, 0:i3
	jr nz, AccTiming_WrapFourBarViewToEnd_Ret
	cp d, 1:i3
	jr nz, AccTiming_WrapFourBarViewToEnd_Ret
	ld a, b
	inc 1, a
	cp e, a
	jr nz, AccTiming_WrapFourBarViewToEnd_Ret
	ld a, b
	sub a, 0x3
	ld c, a

AccTiming_WrapFourBarViewToEnd_Ret:
	ret

AccTiming_WrapFourBarViewToEnd_Pad:
	nop
	nop

; AccTiming_WrapFourBarViewToStart: four-measure view: when C = B - 3 and the play wrapped from measure
;   B + 1 (D) to 1 (E), shows the first four measures, C = 0.
;   Called by ToneGen_StepFwd_Alternate with C = the first measure of the composer's measure view,
;   B = the section's last measure, D = the previous and E = the current play measure; returns C.
AccTiming_WrapFourBarViewToStart:
	ld a, b
	sub a, 0x3
	cp c, a
	jr nz, AccTiming_WrapFourBarViewToStart_Ret
	ld a, b
	inc 1, a
	cp d, a
	jr nz, AccTiming_WrapFourBarViewToStart_Ret
	cp e, 1:i3
	jr nz, AccTiming_WrapFourBarViewToStart_Ret
	ld c, 0x0:opc

AccTiming_WrapFourBarViewToStart_Ret:
	ret

AccTiming_WrapFourBarViewToStart_Pad:
	nop
	nop

; AccTiming_ScrollTwoBarViewForward: two-measure view: when B > C + 1 and the play moved from measure
;   C + 2 (D) to C + 3 (E), scrolls the view one measure on, C = C + 1.
;   Called by ToneGen_StepFwd_Alternate with C = the first measure of the composer's measure view,
;   B = the section's last measure, D = the previous and E = the current play measure; returns C.
AccTiming_ScrollTwoBarViewForward:
	ld a, c
	add a, 0x1
	cp b, a
	jr ule, AccTiming_ScrollTwoBarViewForward_Ret
	inc 1, a
	cp a, d
	jr nz, AccTiming_ScrollTwoBarViewForward_Ret
	ld a, d
	inc 1, a
	cp a, e
	jr nz, AccTiming_ScrollTwoBarViewForward_Ret
	inc 1, c

AccTiming_ScrollTwoBarViewForward_Ret:
	ret

AccTiming_ScrollTwoBarViewForward_Pad:
	nop
	nop

; AccTiming_ScrollTwoBarViewBack: two-measure view: when C > 0, B > C and the play moved back from
;   measure C + 1 (D) to C (E), C = C - 1.
;   Called by ToneGen_StepFwd_Alternate with C = the first measure of the composer's measure view,
;   B = the section's last measure, D = the previous and E = the current play measure; returns C.
AccTiming_ScrollTwoBarViewBack:
	cp c, 0:i3
	jr z, AccTiming_ScrollTwoBarViewBack_Ret
	ld a, c
	cp b, a
	jr ule, AccTiming_ScrollTwoBarViewBack_Ret
	ld a, c
	inc 1, a
	cp a, d
	jr nz, AccTiming_ScrollTwoBarViewBack_Ret
	ld a, d
	dec 1, a
	cp a, e
	jr nz, AccTiming_ScrollTwoBarViewBack_Ret
	dec 1, c

AccTiming_ScrollTwoBarViewBack_Ret:
	ret

AccTiming_ScrollTwoBarViewBack_Pad:
	nop
	nop

; AccTiming_WrapTwoBarViewToEnd: two-measure view: when C = 0 and the play wrapped from measure 1 (D)
;   to B + 1 (E), shows the last two measures, C = B - 1.
;   Called by ToneGen_StepFwd_Alternate with C = the first measure of the composer's measure view,
;   B = the section's last measure, D = the previous and E = the current play measure; returns C.
AccTiming_WrapTwoBarViewToEnd:
	cp c, 0:i3
	jr nz, AccTiming_WrapTwoBarViewToEnd_Ret
	cp d, 1:i3
	jr nz, AccTiming_WrapTwoBarViewToEnd_Ret
	ld a, b
	inc 1, a
	cp e, a
	jr nz, AccTiming_WrapTwoBarViewToEnd_Ret
	ld a, b
	dec 1, a
	ld c, a

AccTiming_WrapTwoBarViewToEnd_Ret:
	ret

AccTiming_WrapTwoBarViewToEnd_Pad:
	nop
	nop

; AccTiming_WrapTwoBarViewToStart: two-measure view: when C = B - 1 and the play wrapped from measure
;   B + 1 (D) to 1 (E), shows the first two measures, C = 0.
;   Called by ToneGen_StepFwd_Alternate with C = the first measure of the composer's measure view,
;   B = the section's last measure, D = the previous and E = the current play measure; returns C.
AccTiming_WrapTwoBarViewToStart:
	ld a, b
	dec 1, a
	cp c, a
	jr nz, AccTiming_WrapTwoBarViewToStart_Ret
	ld a, b
	inc 1, a
	cp d, a
	jr nz, AccTiming_WrapTwoBarViewToStart_Ret
	cp e, 1:i3
	jr nz, AccTiming_WrapTwoBarViewToStart_Ret
	ld c, 0x0:opc

AccTiming_WrapTwoBarViewToStart_Ret:
	ret

AccTiming_WrapTwoBarViewToStart_Pad:
	nop
	nop

AccPlayback_DetectMeasurePos:
	ld A,C
	inc 1,A
	cp	(STYLE_SECTION_BEATS:16), 0x04
	jr ugt, AccPlayback_MeasPos_SmallBeat
	cp E,A
	jr c, AccPlayback_MeasPos_SetLower
	add A,0x03
	cp E,A
	jr ugt, AccPlayback_MeasPos_SetUpper
	jr t, RhythmChannel_NullRet
AccPlayback_MeasPos_SetLower:
	ld	c, e
	dec	1, c
	ld	(ACC_VIEW_FIRST_MEASURE:16), c
	jr	RhythmChannel_NullRet
AccPlayback_MeasPos_SetUpper:
	ld	c, e
	sub	c, 3
	dec	1, c
	ld	(ACC_VIEW_FIRST_MEASURE:16), c
	jr	RhythmChannel_NullRet
AccPlayback_MeasPos_SmallBeat:
	cp e, a
	jr c, AccPlayback_MeasPos_SmallLower
	add a, 0x1
	cp e, a
	jr ugt, AccPlayback_MeasPos_SmallUpper
	jr RhythmChannel_NullRet

AccPlayback_MeasPos_SmallLower:
	ld	c, e
	dec	1, c
	ld	(ACC_VIEW_FIRST_MEASURE:16), c
	jr	RhythmChannel_NullRet
AccPlayback_MeasPos_SmallUpper:
	ld	c, e
	sub	c, 1
	dec	1, c
	ld	(ACC_VIEW_FIRST_MEASURE:16), c
RhythmChannel_NullRet:
	ret

RhythmChannel_NullRet_Pad:
	nop
	nop

AccPlayback_InitPartAssignment:
	xor WA,WA
	ld	(0x3686:16), wa
	ld	(0x3688:16), wa
	ld	(0x368a:16), wa
	ld	(0x368c:16), wa
	jr t, AccPlayback_PartAssign_Check4
	ld	a, (STYLE_SECTION_BEATS:16)
	cp a, 4:i3
	jr ule, AccPlayback_PartAssign_Store
	cp	(0x3443:16), 0x04
	jr nc, AccPlayback_InitPartAssignment_Skip
	ld A, 0x04:opc
	jr t, AccPlayback_PartAssign_Store
AccPlayback_InitPartAssignment_Skip:
	sub a, 0x4

AccPlayback_PartAssign_Store:
	ld	(13958:16), a
	jrl	RhythmFunc_NullRet
AccPlayback_PartAssign_Check4:
	cp	(STYLE_SECTION_BEATS:16), 4
	jrl	ugt, AccPlayback_PartAssign_LargeBeat
	cp	(STYLE_SECTION_LAST_MEASURE:16), 2
	jr	ugt, AccPlayback_PartAssign_LargeMeasure
	cp	(ACC_VIEW_FIRST_MEASURE:16), 0
	jr	z, AccPlayback_PartAssign_SmallPart
	jrl	RhythmFunc_NullRet
AccPlayback_PartAssign_SmallPart:
	ld	a, (STYLE_SECTION_BEATS:16)
	ld	(0x3686:16), a
	ld	(0x368a:16), 1
	cp	(STYLE_SECTION_LAST_MEASURE:16), 1
	jr	c, AccPlayback_PartAssign_Check2
	ld	(0x3687:16), a
	ld	(0x368b:16), 2
AccPlayback_PartAssign_Check2:
	cp	(STYLE_SECTION_LAST_MEASURE:16), 2
	jr	c, AccPlayback_PartAssign_Check3
	ld	(0x3688:16), a
	ld	(0x368c:16), 3
AccPlayback_PartAssign_Check3:
	jrl RhythmFunc_NullRet

AccPlayback_PartAssign_LargeMeasure:
	ld	a, (STYLE_SECTION_LAST_MEASURE:16)
	sub	a, (ACC_VIEW_FIRST_MEASURE:16)
	cp	a, 2:i3
	jr	gt, AccPlayback_PartAssign_FullSetup
	jrl	RhythmFunc_NullRet
AccPlayback_PartAssign_FullSetup:
	ld	a, (STYLE_SECTION_BEATS:16)
	ld	(13958:16), a
	ld	(13959:16), a
	ld	(13960:16), a
	ld	(13961:16), a
	ld	a, (ACC_VIEW_FIRST_MEASURE:16)
	inc	1, a
	ld	(13962:16), a
	inc	1, a
	ld	(13963:16), a
	inc	1, a
	ld	(13964:16), a
	inc	1, a
	ld	(13965:16), a
	jr	RhythmFunc_NullRet
AccPlayback_PartAssign_LargeBeat:
	cp	(STYLE_SECTION_LAST_MEASURE:16), 0
	jr	nz, AccPlayback_PartAssign_LargeBeat2
	cp	(ACC_VIEW_FIRST_MEASURE:16), 0
	jr	nz, RhythmFunc_NullRet
	ld	(0x3686:16), 4
	ld	a, (STYLE_SECTION_BEATS:16)
	sub	a, 4
	ld	(0x3687:16), a
	ld	(0x368a:16), 1
	jr	RhythmFunc_NullRet
AccPlayback_PartAssign_LargeBeat2:
	ld	a, (STYLE_SECTION_LAST_MEASURE:16)
	sub	a, (ACC_VIEW_FIRST_MEASURE:16)
	cp	a, 0:i3
	jr	le, RhythmFunc_NullRet
	ld	(13958:16), 4
	ld	a, (STYLE_SECTION_BEATS:16)
	sub	a, 4
	ld	(13959:16), a
	ld	(13960:16), 4
	ld	(13961:16), a
	ld	a, (ACC_VIEW_FIRST_MEASURE:16)
	inc	1, a
	ld	(13962:16), a
	inc	1, a
	ld	(13964:16), a
RhythmFunc_NullRet:
	ret

; CmStep_DebugShowHexBytes -- on title 0xB6 (TITLE_CMSTEP) only, print six RAM bytes (in v7 0x3673, 0x367E, 0x367C,
;          0x367B, 0x3678, 0x3679) as two hex digits each at fixed screen positions (IX 480, 6962, 6967 ...).
;          A debug readout: CmStep_DebugPrintHexByte splits the byte with CmStep_DebugSplitHexDigits and passes
;          each digit to CmStep_DebugPutCharStub, which is a bare `ret` -- nothing is drawn.  No call, jump or
;          pointer reaches the block; its branches are symbolic because a trace seeded at its first byte
;          reaches each of them and its target (notes/r3-trace-2026-10-02, --seed).  Was named as data
;          (AccPlayback_PartAssign_DataBlock).
CmStep_DebugShowHexBytes:
	; framing ported from v10's source for the same label (same span length, statement for statement); 45 of 68 slots byte-identical
	nop
	nop
	; differs from v10 here and llvm-objdump cannot read it
	cp	(ACTIVE_TITLE:16), 182
	jr	z, CmStep_DebugShowHexBytes_OnCmStep
	jr	CmStep_DebugShowHexBytes_Return
CmStep_DebugShowHexBytes_OnCmStep:
	ld	a, (SQSTEP_CURSOR_STEP:16)
	ldw	ix, 480
	calr	CmStep_DebugPrintHexByte
	ld	a, (SQSTEP_MEASURE:16)
	ldw	ix, 6962
	calr	CmStep_DebugPrintHexByte
	ld	a, (STEP_NOTE:16)
	ldw	ix, 6967
	calr	CmStep_DebugPrintHexByte
	ld	a, (STEP_VELOCITY:16)
	ldw	ix, 6972
	calr	CmStep_DebugPrintHexByte
	ld	a, (STEP_NOTE_VALUE:16)
	ldw	ix, 6977
	calr	CmStep_DebugPrintHexByte
	ld	a, (STEP_PLUS_NOTE_VALUE:16)
	ldw	ix, 6982
	calr	CmStep_DebugPrintHexByte
CmStep_DebugShowHexBytes_Return:
	ret
	nop
	nop
CmStep_DebugPrintHexByte:
	calr	CmStep_DebugSplitHexDigits
	pushw	ix
	ld	a, d
	calr	CmStep_DebugPutCharStub
	popw	ix
	inc	1, ix
	ld	a, e
	calr	CmStep_DebugPutCharStub
	ret
	nop
	nop
CmStep_DebugPutCharStub:
	ret
	nop
	nop
CmStep_DebugSplitHexDigits:
	ld	e, a
	and	wa, 240
	srl	wa, 4
	ld	hl, wa
	ld	d, a
	ld	a, e
	and	wa, 15
	ld	hl, wa
	ret
	nop
	nop
	.byte 0x30	; v10 does not spell this byte either
	.byte 0x31	; v10 does not spell this byte either
	.byte 0x32	; v10 does not spell this byte either
	.byte 0x33	; v10 does not spell this byte either
	.byte 0x34	; v10 does not spell this byte either
	.byte 0x35	; v10 does not spell this byte either
	.byte 0x36	; v10 does not spell this byte either
	.byte 0x37	; v10 does not spell this byte either
	.byte 0x38	; v10 does not spell this byte either
	.byte 0x39	; v10 does not spell this byte either
	.byte 0x41	; v10 does not spell this byte either
	.byte 0x42	; v10 does not spell this byte either
	.byte 0x43	; v10 does not spell this byte either
	.byte 0x44	; v10 does not spell this byte either
	.byte 0x45	; v10 does not spell this byte either
	.byte 0x46	; v10 does not spell this byte either
	ret
AccPat_ShiftAndMask:
	pushw hl
	and hl, 0xfff
	sla hl, 4
	popw hl
	ret

AccPat_ShiftAndMask_Pad:
	nop
	nop

AccPat_IndexToAddress:
	and xhl, 0xffff
	sla xhl, 8
	add xhl, RHYTHM_PATTERN_BUF_B
	ret

AccPat_InlineFunctions_DataBlock:
	nop
	nop
AccPat_IndexToAddress_Sub2:
	and	xhl, 0xffff
	sla	xhl, 8
	add	xhl, RHYTHM_PATTERN_BUF_B
	ret
	push	xwa
	push	xix
	ld	wa, hl
	and	xhl, 4095
	sla	xhl, 8
	and	wa, 0xf000
	srl	wa, 10
	ld	xix, AccPat_InlineFunctions_DataBlock_Code
	ld	xix, (xix+wa)
	add	xhl, xix
	pop	xix
	pop	xwa
	ret
AccPat_InlineFunctions_DataBlock_Code:
	nop
	pop	xix
	push	0
	nop
	pop	xix
	push	0
	nop
	pop	xix
	push	0
	nop
	pop	xix
	push	0
	nop
	pop	xix
	push	0
	nop
	pop	xix
	push	0
	nop
	pop	xix
	push	0
	nop
	pop	xix
	push	0
	nop
	pop	xix
	push	0
AccPat_IndexToAddress_Sub:
	push	xiz
	calr	AccPat_DispatchNoteChange
	pop	xiz
	ret

AccPat_DispatchNoteChange:
	bit	0, (0x3419:16)
	jr nz, .Lc_f62d55
	jp AccPat_Dispatch_Return
AccPat_Dispatch_AllocAndProcess:
.Lc_f62d55:
	ld XWA,0x00000800
	push XWA
	call Malloc
	add XSP,0x00000004
	ld	(RHYTHM_PATTERN_ALLOC:16), xhl
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	ld	w, (RHYTHM_LOAD_BANK:16)
	pushw	wa
	and	(0x3419:16), 254
	and	(0x34f8:16), 254
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	cp	a, 128
	jr	c, AccPat_Dispatch_LowRange
	cp	a, 160
	jrl	nc, AccPat_CleanupAndFree
	cp	(RHYTHM_LOAD_PART:16), 26
	jr	nz, AccPat_Dispatch_CalcAccent
	calr	AccWidget_ProcessSpecialCmd
	jrl	AccPat_CleanupAndFree
AccPat_Dispatch_CalcAccent:
	calr	AccPat_CalcAccentVelocity
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	cp	a, (STYLE_SECTION:16)
	jr	z, AccPat_CleanupAndFree
	cp	a, 30
	jr	nc, AccPat_CleanupAndFree
	or	(0x3415:16), 128
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	jr	AccPat_Dispatch_CheckBit0
AccPat_Dispatch_LowRange:
	or	(0x3415:16), 128
	cp	(RHYTHM_LOAD_PART:16), 26
	jr	nz, AccPat_Dispatch_InitWorkArea
	calr	RhythmROM_LoadDrumKit
	jr	AccPat_CleanupAndFree
AccPat_Dispatch_InitWorkArea:
	call AccPat_InitWorkAreaFromSlot
	calr RhythmROM_PatternDispatcher

AccPat_Dispatch_CheckBit0:
	bit	0, (0x34f8:16)
	jr	nz, AccPat_Dispatch_InitSlot
	cp	(CURRENT_TITLE:16), 184
	jr	nz, AccPat_CleanupAndFree
	ld	(GLOBAL_ERROR_CODE:16), 20
	call	DrumVoice_NotifyEE
	jr	AccPat_CleanupAndFree
AccPat_Dispatch_InitSlot:
	call	AccPatch_InitCurrentSlot
	ld	(GLOBAL_ERROR_CODE:16), 23
	call	DrumVoice_NotifyEE
	ld	a, 8:opc
call	MIDI_SendSysExCmd
AccPat_CleanupAndFree:
	popw	wa
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	ld	(RHYTHM_LOAD_BANK:16), w
	ld	xwa, (RHYTHM_PATTERN_ALLOC:16)
	push	xwa
call	Free
	add	xsp, 4
AccPat_Dispatch_Return:
	ret

AccPat_CleanupAndFree_Pad:
	nop
	nop

DualVoice_ParamLoadDone:
	push xiz
	calr AccPatch_LoadDualVoiceParams
	pop xiz
	ret

AccPatch_LoadDualVoiceParams:
	ld	l, (STYLE_COPY_SRC_SECTION:16)
	cp	l, 30
	jr	c, AccPat_DualVoice_ClampIndex
	xor	l, l
AccPat_DualVoice_ClampIndex:
	sla	l, 2
	xor	h, h
	ld	xix, RhythmTiming_OffsetTable
	ld	xiy, (xix+hl)
	add	xiy, (STYLE_SRC_IMAGE_PTR:16)
	add	xiy, 96
	ld	(13476:16), xiy
	ld	l, (STYLE_COPY_DST_SECTION:16)
	cp	l, 30
	jr	c, AccPat_DualVoice_ClampIndex2	; -> 0xF62E74
	xor	l, l
AccPat_DualVoice_ClampIndex2:
	sla	l, 2
	xor	h, h
	ld	xix, RhythmTiming_OffsetTable
	ld	xiy, (xix+hl)
	add	xiy, (STYLE_DST_IMAGE_PTR:16)
	add	xiy, 96
	ld	(RHYTHM_SECTION_PTR:16), xiy
	ld	xiy, (0x34a4:16)
	add	xiy, 12
	ld	xix, (RHYTHM_SECTION_PTR:16)
	add	xix, 12
	ldw	bc, 84
	ldir85
	calr	AccPat_DualVoice_ReadParamsA
	calr	AccPatch_LoadDualVoiceParamsB
	calr	AccPat_DualVoice_CopyAllBanks
	ret
AccPat_DualVoice_DataBlock:
	; framing ported from v10's source for the same label (same span length, statement for statement); 24 of 38 slots byte-identical
	nop
	nop
	ld	l, (RHYTHM_LOAD_PROGRAM:16)
	and	l, 127
	cp	l, 30
	jr	c, AccPatch_LoadDualVoiceParams_Skip2
	xor	l, l
AccPatch_LoadDualVoiceParams_Skip2:
	sla	l, 2
	xor	h, h
	ld	xix, RhythmTiming_OffsetTable
	ld	xiy, (xix+hl)
	add	xiy, RHYTHM_PATTERN_BUF_A
	add	xiy, 96
	ld	(13476:16), xiy
	ld	l, (STYLE_SECTION:16)
	cp	l, 30
	jr	c, AccPatch_LoadDualVoiceParams_Skip
	xor	l, l
AccPatch_LoadDualVoiceParams_Skip:
	sla	l, 2
	xor	h, h
	; v10 does not spell this byte either
	ld	xix, RhythmTiming_OffsetTable
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	ld	xiy, (xix+hl)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	add	xiy, RHYTHM_PATTERN_BUF_A
	; v10 does not spell this byte either
	add	xiy, 96
	; v10 does not spell this byte either
	ld	(RHYTHM_SECTION_PTR:16), xiy
	; differs from v10 here and llvm-objdump cannot read it
	ret
AccPat_DualVoice_ReadParamsA:
	ld	xiy, (13476:16)

	ld hl, (xiy + 0:8)

	ld	(13548:16), hl

	ld hl, (xiy + 4)

	ld	(13550:16), hl

	ld hl, (xiy + 6)

	ld	(13552:16), hl

	ld hl, (xiy + 8)

	ld	(13554:16), hl

	ld hl, (xiy + 10)

	ld	(13556:16), hl

	ret



AccPat_DualVoice_ReadParamsA_Pad:
	nop
	nop

AccPatch_LoadDualVoiceParamsB:
	ld	xiy, (RHYTHM_SECTION_PTR:16)

	ld hl, (xiy + 0:8)

	ld	(13536:16), hl

	ld hl, (xiy + 4)

	ld	(13538:16), hl

	ld hl, (xiy + 6)

	ld	(13540:16), hl

	ld hl, (xiy + 8)

	ld	(13542:16), hl

	ld hl, (xiy + 10)

	; stda16 (0x35a0), xhl (v7 patched)
	ld	(0x34e8:16), hl
	ret



AccPatch_LoadDualVoiceParamsB_Pad:
	nop
	nop

AccPat_DualVoice_CopyAllBanks:
	ld	iy, (13548:16)
	ld	ix, (13536:16)
	calr	ToneBank_CopyEntry
	ld	iy, (13550:16)
	ld	ix, (13538:16)
	calr	ToneBank_CopyEntry
	ld	iy, (13552:16)
	ld	ix, (13540:16)
	calr	ToneBank_CopyEntry
	ld	iy, (13554:16)
	ld	ix, (13542:16)
	calr	ToneBank_CopyEntry
	ld	iy, (13556:16)
	ld	ix, (13544:16)
	calr	ToneBank_CopyEntry
	ret
AccPat_DualVoice_CopyAllBanks_Pad:
	nop
	nop

ToneBank_CopyEntry:
	ld	(0x34de:16), ix
	ld	(0x34ea:16), iy
	ld HL,IY
	ld	xwa, (STYLE_SRC_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	ld	wa, (xhl+3)
	ld	(0x34f6:16), wa
	ld	hl, (0x34de:16)
	ld	xwa, (STYLE_DST_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	ld	xix, xhl
	ld	hl, (0x34ea:16)
	ld	xwa, (STYLE_SRC_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	ld	xiy, xhl
	add	xiy, 6
	add	xix, 6
	ldw	bc, 249
	ldir85
ToneBank_CopyEntry_Join:
	cpw	(0x34f6:16), 65535
	jrl	z, ToneBank_CopyComplete_Return
	calr	ToneBank_CopyChunk_Return
	bit	0, (0x34f8:16)
	jr	nz, ToneBank_CopyComplete_Return
	decw	1, (STYLE_FREE_BLOCKS:16)
	ld	hl, de
	ld	xwa, (STYLE_DST_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	or	(xhl), 128
	ld	hl, (0x34de:16)
	ld	xwa, (STYLE_DST_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	ld	(xhl+3), de
	ld	hl, de
	ld	xwa, (STYLE_DST_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	ld	wa, (0x34de:16)
	ld	(xhl+1), wa
	ld	(0x34de:16), de
	ld	wa, (0x34f6:16)
	ld	(0x34ea:16), wa
	ld	hl, wa
	ld	xwa, (STYLE_SRC_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	ld	wa, (xhl+3)
	ld	(0x34f6:16), wa
	calr	AccPat_ShiftAndMask
	ld	hl, (0x34de:16)
	ld	xwa, (STYLE_DST_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	ld	xix, xhl
	ld	hl, (0x34ea:16)
	ld	xwa, (STYLE_SRC_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	ld	xiy, xhl
	add	xiy, 6
	add	xix, 6
	ldw	bc, 249
	ldir85
	jrl	ToneBank_CopyEntry_Join
ToneBank_CopyComplete_Return:
	ld	hl, (13534:16)
	ld	xwa, (STYLE_DST_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	ldw	wa, 65535
	ld	(xhl+3), wa
	ret
ToneBank_CopyChunk:
	nop

ToneBank_ComputeEntryAddress:
	and xhl, 0xfff
	sla xhl, 8
	add xhl, xwa
	add xhl, 0x1400
	ret

ToneBank_CopyChunk_Return:
	ldw de, 0x96

ToneBank_ComputeEntryAddress_Join:
	cp	de, 340
	jr	nc, ToneBank_ComputeAddr_CheckRange
	ld	hl, de
	ld	xwa, (STYLE_DST_IMAGE_PTR:16)
	calr	ToneBank_ComputeEntryAddress
	bit	7, (xhl)
	jr	z, ToneBank_ComputeAddr_Return
	inc	1, de
	jr	ToneBank_ComputeEntryAddress_Join
ToneBank_ComputeAddr_CheckRange:
	; ordi8 0x35b0, 1 (v7 patched)
	or	(0x34f8:16), 1
ToneBank_ComputeAddr_Return:
	ret

; RhythmBuf_FindFreeBlock: Returns DE = the first 256-byte block of RHYTHM_PATTERN_BUF_B with index 150..339 whose
;   header byte bit 7 (in use) is clear; when none is free it sets bit 0 of 0x3514 (DE = 340). Basis: callers + body
;   -- RhythmBuf_LoadPattern calls it when the current block fills (offset > 0xFE), then links the new block (+3 /
;   +1), marks it used (bit 7) and decrements the free-block count 0x3438.
RhythmBuf_FindFreeBlock:
	ldw de, 0x96

ToneBank_CopyChunkWithSwap:
	cp de, 0x154
	jr nc, ToneBank_SwapCopy_Return
	ld hl, de
	calr AccPat_IndexToAddress
	bitm 7, (xhl)
	jr z, ToneBank_SwapCopy_Pad
	inc 1, de
	jr ToneBank_CopyChunkWithSwap

ToneBank_SwapCopy_Return:
	; ordi8 0x35b0, 1 (v7 patched)
	or	(0x34f8:16), 1
ToneBank_SwapCopy_Pad:
	ret
ToneBank_SwapCopy_Pad_Code:
	nop
	nop
	ldw	de, 150
ToneBank_SwapCopy_Pad_Code_Join:
	cp	de, 340
	jr	nc, ToneBank_SwapCopy_Pad_Code_Skip
	ld	hl, de
	calr	AccPat_IndexToAddress_Sub2
	bit	7, (xhl)
	jr	z, ToneBank_SwapCopy_Pad_Code_Skip2
	inc	1, de
	jr	ToneBank_SwapCopy_Pad_Code_Join
ToneBank_SwapCopy_Pad_Code_Skip:
	or	(0x34f8:16), 1
ToneBank_SwapCopy_Pad_Code_Skip2:
	or	de, 32768
	ret
RhythmROM_PatternDispatcher:
	and	(0x34f8:16), 249
	ld	l, (RHYTHM_LOAD_PROGRAM:16)
	ld	h, (RHYTHM_LOAD_BANK:16)
	call	VoiceParam_ClampAndValidate_Tramp
	ld	(RHYTHM_LOAD_PROGRAM:16), l
	ld	(RHYTHM_LOAD_BANK:16), h
	sla	l, 1
	sla	hl, 1
	ld	xiy, RhythmROM_BankProgramLocators
	ld	wa, (xiy+hl)
	ld	(13474:16), wa
	add	hl, 2
	ld	wa, (xiy+hl)
	ld	(13476:16), wa
	ld	l, (STYLE_SECTION:16)
	cp	l, 30
	jr	c, RhythmROM_PatternDispatcher_Join
	xor	l, l
RhythmROM_PatternDispatcher_Join:
	sla	l, 2
	xor	h, h
	ld	xix, RhythmTiming_OffsetTable
	ld	xiy, (xix+hl)
	add	xiy, RHYTHM_PATTERN_BUF_A
	add	xiy, 96
	ld	(RHYTHM_SECTION_PTR:16), xiy
	calr	RhythmROM_LoadPattern
	cp	(RHYTHM_LOAD_PART:16), 0
	jr	z, RhythmROM_LoadAndInit
	cp	(RHYTHM_LOAD_PART:16), 1
	jr	z, RhythmROM_LoadAndInit
	cp	(RHYTHM_LOAD_PART:16), 2
	jr	z, RhythmROM_LoadAndInit
	cp	(RHYTHM_LOAD_PART:16), 3
	jr	z, RhythmROM_LoadAndInit
	calr	ToneData_LookupEffectParam_Code
	calr	AccPatch_LoadDualVoiceParamsB
	calr	VoiceSlot_Resolve_Loop
	jr	AccPat_CalcAccent_Return
RhythmROM_LoadAndInit:
	calr DrumKit_DataTable_Entry0
	calr AccPatch_LoadDualVoiceParamsB
	calr AccSection_ProcessEntry

AccPat_CalcAccent_Return:
	ret

RhythmROM_LoadAndInit_Pad:
	nop
	nop

RhythmROM_LoadPattern:
	ld	wa, (0x34a2:16)
	ld	w, a
	calr	RhythmROM_CalcPatternAddr
	xor	xiy, xiy
	ld	iy, (0x34a4:16)
	add	xiy, xix
	ld	xix, (RHYTHM_PATTERN_ALLOC:16)
	ldw	bc, 1024
	ldirw
	ld	l, (RHYTHM_LOAD_PART:16)
	and	l, 15
	xor	h, h
	sla	hl, 1
	ld	xix, RhythmROM_LoadPattern_Data
	xor	xwa, xwa
	ld	wa, (xix+hl)
	jr	RhythmROM_PatternDisp_ReadByte
; RhythmROM_LoadPattern +0x34 -- 16 x LE16 byte offsets into the rhythm pattern
; buffer, read by the routine above: ld l,(<var>) / and l,0xf / sla hl,1 /
; ld xix, RhythmROM_LoadPattern_Data / ld_rrw wa,(xix+hl), then
; RhythmROM_PatternDisp_ReadByte adds WA to the pattern pointer.  Typed as in
; v9/v10 (lane accomp 2026-09-25, scripts/converters/lane_accomp_v7_rhythmrom.py);
; before, the routine and this table were one .byte run with phantom
; instructions (neg wa / pop sr / reti) in the table.
RhythmROM_LoadPattern_Data:
	.short 0x03d2, 0x03d8, 0x07d2, 0x07d8, 0x03d3, 0x07d3, 0x03d3, 0x07d3
	.short 0x03d2, 0x03d2, 0x03d8, 0x03d8, 0x07d2, 0x07d2, 0x07d8, 0x07d8
RhythmROM_PatternDisp_ReadByte:
	ld	xiy, (RHYTHM_PATTERN_ALLOC:16)
	add	xiy, xwa
	ld	a, (xiy)
	ld	(13561:16), a
	ld	xiy, (RHYTHM_PATTERN_ALLOC:16)
	ld	xix, (RHYTHM_SECTION_PTR:16)
	add	xix, 12
	ld	a, (xiy+976)
	ld	(xix), a
	inc	1, xix
	push	xix
	calr	RhythmROM_PatternDisp_ReadByte_Helper
	pop	xix
	ld	(xix), a
	inc	1, xix
	ld	a, 32:opc
	ld	(xix), a
	inc	1, xix
	ld	a, 0:opc
	ld	(xix), a
	inc	1, xix
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	ld	(xix), a
	inc	1, xix
	ld	a, (RHYTHM_LOAD_BANK:16)
	ld	(xix), a
	inc	1, xix
	ld	l, (RHYTHM_LOAD_PART:16)
	and	l, 15
	xor	h, h
	sla	hl, 1
	ld	xix, RhythmROM_PatternDisp_BufOffsets
	xor	xwa, xwa
	ld	wa, (xix+hl)
	jr	RhythmROM_PatternDisp_Handle90
RhythmROM_PatternDisp_BufOffsets:
	; Indexed by (0x3453) & 0xF; the word is added to the pointer in (0x34C8) (RhythmROM_PatternDisp_Handle90).
	; Was decoded as `popw wa / push sr / jrl ge, 18434 ...` and a data-as-code note.
	.short	0x0248, 0x0279, 0x0648, 0x0679, 0x036e, 0x076e, 0x039f, 0x079f
	.short	0x030c, 0x030c, 0x033d, 0x033d, 0x070c, 0x070c, 0x073d, 0x073d

RhythmROM_PatternDisp_Handle90:
	ld	xiy, (RHYTHM_PATTERN_ALLOC:16)
	add	xiy, xwa
	ld	xix, (RHYTHM_SECTION_PTR:16)
	add	xix, 24
	ld	a, 5:opc
RhythmROM_PatternDisp_Check91:
	ld	bc, 7:i3
	ldir85
	inc	1, xix
	dec	1, a
	cp	a, 0:i3
	jr	nz, RhythmROM_PatternDisp_Check91
	ld	xix, (RHYTHM_SECTION_PTR:16)
	ld	xiy, 34
	add	xiy, xix
	ld	(xiy), 64
	ld	xiy, 42
	add	xiy, xix
	ld	(xiy), 12
	ld	xiy, 50
	add	xiy, xix
	ld	(xiy), 116
	ld	xiy, 58
	add	xiy, xix
	ld	(xiy), 64
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	ld	(0x902a:16), a
	ld	a, (RHYTHM_LOAD_BANK:16)
	ld	(0x902b:16), a
call	Rhythm_DispatchNote_Finalize
	ld	h, (0x902f:16)
	ld	l, (0x902e:16)
	call	AccVoice_DispatchEntry
	ld	xiy, 13299
	ld	xix, (RHYTHM_SECTION_PTR:16)
	add	xix, 64
	ldw	bc, 16
	ldir85
	ret
RhythmROM_PatternDisp_Handle91:
	nop
	nop

RhythmROM_CalcPatternAddr:
	and	xwa, 65280
	sla	xwa, 8
	ld	xix, 4194304
	add	xix, (RHYTHM_ROM_BASE:16)
	add	xix, xwa
	ret
RhythmROM_PatternDisp_Return:
	nop
	nop

RhythmROM_PatternDisp_ReadByte_Helper:
	ld	xhl, (RHYTHM_PATTERN_ALLOC:16)
	add	xhl, 280
	calr	RhythmROM_CountEntries
	ld	(13563:16), e
	ld	a, (RHYTHM_LOAD_PART:16)
	cp	a, 0:i3
	jr	z, RhythmROM_InitPattern
	cp	a, 1:i3
	jr	z, RhythmROM_InitPattern
	cp	a, 2:i3
	jr	z, RhythmROM_InitPattern
	cp	a, 3:i3
	jr	z, RhythmROM_InitPattern
	jr	RhythmROM_InitPattern_Join
RhythmROM_InitPattern:
	ld	xhl, (RHYTHM_SECTION_PTR:16)
	xor	wa, wa
	ld	a, (xhl+12)
	ld	xhl, RhythmBuf_BarQuartersByTimeSig
	ld	l, (xhl+wa)
	ld	a, 7:opc
	cp	l, (0x34fb:16)
	jr	nz, RhythmVoice_WriteParam_Return
	or	(0x34f8:16), 2
	ld	a, 3:opc
RhythmVoice_WriteParam_Return:
	jp RhythmROM_NullRet

RhythmROM_InitPattern_Join:
	ld	xhl, (RHYTHM_PATTERN_ALLOC:16)
	add	xhl, 312
	cp	a, 4:i3
	jr	z, RhythmROM_ProcessPattern
	ld	xhl, (RHYTHM_PATTERN_ALLOC:16)
	add	xhl, 316
	cp	a, 6:i3
	jr	z, RhythmROM_ProcessPattern
	ld	xhl, (RHYTHM_PATTERN_ALLOC:16)
	add	xhl, 1336
	cp	a, 5:i3
	jr	z, RhythmROM_ProcessPattern
	ld	xhl, (RHYTHM_PATTERN_ALLOC:16)
	add	xhl, 1340
	cp	a, 7:i3
	jr	z, RhythmROM_ProcessPattern
	jr	RhythmVoice_SetupChannels
RhythmROM_ProcessPattern:
	calr	RhythmROM_CountEntries
	ld	xhl, (RHYTHM_SECTION_PTR:16)
	xor	wa, wa
	ld	a, (xhl+12)
	ld	xhl, RhythmBuf_BarQuartersByTimeSig
	ld	a, (xhl+wa)
	ex8	a, e
	xor	w, w
	div	wa, e
	dec	1, a
	cp	w, 0:i3
	jr	z, RhythmROM_NullRet	; -> 0xF633D4
	ld	a, 8:opc
	call	MIDI_SendSysExCmd
	jr	RhythmROM_NullRet	; -> 0xF633D4
RhythmVoice_SetupChannels:
	cp a, 0x8
	jr z, RhythmROM_ReturnZero
	cp a, 0x9
	jr z, RhythmROM_ReturnZero
	cp a, 0xa
	jr z, RhythmROM_ReturnZero
	cp a, 0xb
	jr z, RhythmROM_ReturnZero
	cp a, 0xc
	jr z, RhythmROM_ReturnZero
	cp a, 0xd
	jr z, RhythmROM_ReturnZero
	cp a, 0xe
	jr z, RhythmROM_ReturnZero
	cp a, 0xf
	jr z, RhythmROM_ReturnZero
	jr RhythmROM_NullRet

RhythmROM_ReturnZero:
	xor a, a

RhythmROM_NullRet:
	ret

RhythmVoice_SetupChan_Finalize:
	nop
	nop

RhythmROM_CountEntries:
	push	xhl
	ld	xhl, (RHYTHM_PATTERN_ALLOC:16)
	add	xhl, 977
	ld	w, (xhl)
	pop	xhl
	calr	RhythmROM_CalcPatternAddr
	ld	hl, (xhl)
	and	xhl, 65535
	add	hl, 6
	add	xhl, xix
	xor	e, e
	ld	a, (xhl)
	inc	1, xhl
RhythmVoice_WriteToBuffer:
	cp a, 0x83
	jr z, RhythmVoice_WriteBuf_Done
	cp a, 0x81
	jr nz, RhythmVoice_WriteBuf_Clamp
	inc 1, e

RhythmVoice_WriteBuf_Clamp:
	ld a, (xhl)
	inc 1, xhl
	jr RhythmVoice_WriteToBuffer

RhythmVoice_WriteBuf_Done:
	ret

	.byte	0x00, 0x00	; padding
; No reference found.  Writes 0x20 (a space) to (XIY) and steps XIY while BC counts down to 0,
; with C := 16 and B as the caller left it.  Both `jr nz` test flags that nothing here sets (LD sets
; none), so whether a byte is written depends on the caller's flags.
RhythmVoice_SpaceFill:
	ld	c, 16:opc
RhythmVoice_SpaceFill_Loop:
	ld	a, (xiy)
	jr	nz, RhythmVoice_SpaceFill_Second
	ld	(xiy), 32
RhythmVoice_SpaceFill_Second:
	jr	nz, RhythmVoice_SpaceFill_Next
	ld	(xiy), 32
RhythmVoice_SpaceFill_Next:
	dec	1, bc
	inc	1, iy
	cp	bc, 0:i3
	jr	nz, RhythmVoice_SpaceFill_Loop
	ret
	nop
	nop

DrumKit_DataTable_Entry0:
	ld	xix, (RHYTHM_PATTERN_ALLOC:16)
	ld	xiy, (RHYTHM_PATTERN_ALLOC:16)
	cp	(RHYTHM_LOAD_PART:16), 0x00
	jr nz, .Lc_f63445
	add XIX,0x00000000
	add XIY,0x00000118
DrumKit_DataTable_Entry1:
.Lc_f63445:
	cp	(RHYTHM_LOAD_PART:16), 0x01
	jr nz, .Lc_f63458
	add XIX,0x0000000f
	add XIY,0x00000118
DrumKit_DataTable_Entry2:
.Lc_f63458:
	cp	(RHYTHM_LOAD_PART:16), 0x02
	jr nz, .Lc_f6346b
	add XIX,0x00000400
	add XIY,0x00000518
DrumKit_DataTable_Entry3:
.Lc_f6346b:
	cp	(RHYTHM_LOAD_PART:16), 0x03
	jr nz, .Lc_f6347e
	add XIX,0x0000040f
	add XIY,0x00000518
DrumKit_DataTable_Entry4:
.Lc_f6347e:
	ld xhl, 0:i3
	bit	0, (0x34f9:16)
	jr nz, .Lc_f6348b
	ld XHL,0x00000026
DrumKit_DataTable_Entry5:
.Lc_f6348b:
	add XHL,XIY
	ld	a, (xix+0:8)
	calr	ToneData_LookupEffectParam
	ld	(0x34d4:16), a
	ld	(0x34b2:16), hl
	ld	xhl, 76
	add	xhl, xiy
	ld	a, (xix+40)
	calr	ToneData_LookupEffectParam
	ld	(0x34d5:16), a
	ld	(0x34b4:16), hl
	ld	xhl, 114
	add	xhl, xiy
	ld	a, (xix+80)
	calr	ToneData_LookupEffectParam
	ld	(0x34d6:16), a
	ld	(0x34b6:16), hl
	ld	xhl, 152
	add	xhl, xiy
	ld	a, (xix+120)
	calr	ToneData_LookupEffectParam
	ld	(0x34d7:16), a
	ld	(0x34b8:16), hl
	ld	xhl, 190
	add	xhl, xiy
	ld	a, (xix+160)
	calr	ToneData_LookupEffectParam
	ld	(0x34d8:16), a
	ld	(0x34ba:16), hl
	ld	xhl, 0:i3
	bit	0, (0x34f9:16)
	jr	nz, RhythmVoice_SpaceFill_Second_Join
	ld	xhl, 38
RhythmVoice_SpaceFill_Second_Join:
	add	xhl, xiy
	ld	a, (xix+1)
	calr	ToneData_LookupEffectParam
	ld	(0x34d9:16), a
	ld	(0x34bc:16), hl
	ld	xhl, 76
	add	xhl, xiy
	ld	a, (xix+41)
	calr	ToneData_LookupEffectParam
	ld	(0x34da:16), a
	ld	(0x34be:16), hl
	ld	xhl, 114
	add	xhl, xiy
	ld	a, (xix+81)
	calr	ToneData_LookupEffectParam
	ld	(0x34db:16), a
	ld	(0x34c0:16), hl
	ld	xhl, 152
	add	xhl, xiy
	ld	a, (xix+121)
	calr	ToneData_LookupEffectParam
	ld	(0x34dc:16), a
	ld	(0x34c2:16), hl
	ld	xhl, 190
	add	xhl, xiy
	ld	a, (xix+161)
	calr	ToneData_LookupEffectParam
	ld	(0x34dd:16), a
	ld	(0x34c4:16), hl
	ld	xhl, 0:i3
	bit	0, (0x34f9:16)
	jr	nz, RhythmVoice_SpaceFill_Second_Join2
	ld	xhl, 38
RhythmVoice_SpaceFill_Second_Join2:
	add	xhl, xiy
	ld	a, (xix+2)
	calr	ToneData_LookupEffectParam
	ld	(0x3508:16), a
	ld	(0x34fe:16), hl
	ld	xhl, 76
	add	xhl, xiy
	ld	a, (xix+42)
	calr	ToneData_LookupEffectParam
	ld	(0x3509:16), a
	ld	(0x3500:16), hl
	ld	xhl, 114
	add	xhl, xiy
	ld	a, (xix+82)
	calr	ToneData_LookupEffectParam
	ld	(0x350a:16), a
	ld	(0x3502:16), hl
	ld	xhl, 152
	add	xhl, xiy
	ld	a, (xix+122)
	calr	ToneData_LookupEffectParam
	ld	(0x350b:16), a
	ld	(0x3504:16), hl
	ld	xhl, 190
	add	xhl, xiy
	ld	a, (xix+162)
	calr	ToneData_LookupEffectParam
	ld	(0x350c:16), a
	ld	(0x3506:16), hl
	ld	xhl, 0:i3
	bit	0, (0x34f9:16)
	jr	nz, RhythmVoice_SpaceFill_Second_Join3
	ld	xhl, 38
RhythmVoice_SpaceFill_Second_Join3:
	add	xhl, xiy
	ld	a, (xix+3)
	calr	ToneData_LookupEffectParam
	ld	(13592:16), a
	ld	(13582:16), hl
	ld	xhl, 76
	add	xhl, xiy
	ld	a, (xix+43)
	calr	ToneData_LookupEffectParam
	ld	(13593:16), a
	ld	(13584:16), hl
	ld	xhl, 114
	add	xhl, xiy
	ld	a, (xix+83)
	calr	ToneData_LookupEffectParam
	ld	(13594:16), a
	ld	(13586:16), hl
	ld	xhl, 152
	add	xhl, xiy
	ld	a, (xix+123)
	calr	ToneData_LookupEffectParam
	ld	(13595:16), a
	ld	(13588:16), hl
	ld	xhl, 190
	add	xhl, xiy
	ld	a, (xix+163)
	calr	ToneData_LookupEffectParam
	ld	(13596:16), a
	ld	(13590:16), hl
	ret
RhythmROM_LoadKit_InitLDA:
	nop
	nop

ToneData_LookupEffectParam:
	sla a, 1

	xor w, w

	ld	hl, (xhl+wa)

	push xix

	ld	xix, (RHYTHM_PATTERN_ALLOC:16)

	add xix, 0x3d1

	ld a, (xix)

	pop xix

	ret



RhythmROM_LoadKit_Return:
	nop
	nop

ToneData_LookupEffectParam_Code:
	ld	xix, (RHYTHM_PATTERN_ALLOC:16)
	add	xix, 977
	ld	a, (xix)
	ld	(0x34d4:16), a
	ld	(0x34d5:16), a
	ld	(0x34d6:16), a
	ld	(0x34d7:16), a
	ld	(0x34d8:16), a
	calr	RhythmROM_LoadKit_CopyReturn_Code
	ld	xiy, (RHYTHM_PATTERN_ALLOC:16)
	xor	xhl, xhl
	ld	hl, (0x34fc:16)
	add	xiy, xhl
	ld	xhl, 0:i3
	bit	0, (0x34f9:16)
	jr	nz, RhythmROM_LoadKit_CopyLoop
	ld	xhl, 38
RhythmROM_LoadKit_CopyLoop:
	add	xhl, xiy
	ld	hl, (xhl)
	ld	(13490:16), hl
	ld	xhl, 76
	add	xhl, xiy
	ld	hl, (xhl)
	ld	(13492:16), hl
	ld	xhl, 114
	add	xhl, xiy
	ld	hl, (xhl)
	ld	(13494:16), hl
	ld	xhl, 152
	add	xhl, xiy
	ld	hl, (xhl)
	ld	(13496:16), hl
	ld	xhl, 190
	add	xhl, xiy
	ld	hl, (xhl)
	ld	(13498:16), hl
	ret
RhythmROM_LoadKit_CopyReturn:
	nop
	nop

RhythmROM_LoadKit_CopyReturn_Code:
	ld	l, (RHYTHM_LOAD_PART:16)

	and l, 0xf

	xor h, h

	sla hl, 1

	ld	xix, ToneData_EffectParamWords
	ld	wa, (xix+hl)

	ld	(13564:16), wa

	ret



	nop
	nop
; ToneData_EffectParamWords -- 16 words: the reader above (v10's ToneData_LookupEffectParam_Helper) stores entry
;          [(0x3453) & 15] to (0x3518) (v10 and v9: 0x34EF and 0x35B4).  Was named VoiceSlot_ResolveIndex and decoded as `.zero 8 / nop / nop / push xwa /
;          normal ...`; its reader used the positional alias VoiceSlot_ResolveIndex_0x2.
ToneData_EffectParamWords:
	.short	0, 0, 0, 0, 0x0138, 0x0538, 0x013c, 0x053c
	.short	0x0130, 0x0132, 0x0134, 0x0136, 0x0530, 0x0532, 0x0534, 0x0536
	ret
	nop
	nop

VoiceSlot_Resolve_Loop:
	ld	w, (0x34d4:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34b2:16)
	ld	de, (0x34e0:16)
	bit	0, (0x34f9:16)
	jr	nz, VoiceSlot_Resolve_CheckA
	bit	1, (0x34f9:16)
	jr	nz, VoiceSlot_Resolve_CheckA
	jr	VoiceSlot_Resolve_CheckB
VoiceSlot_Resolve_CheckA:
	calr RhythmBuf_LoadPattern
	jr VoiceSlot_Resolve_StoreA

VoiceSlot_Resolve_CheckB:
	calr RhythmBuf_FillEmptyPattern

VoiceSlot_Resolve_StoreA:
	and	(0x34f8:16), 251
	ld	w, (0x34d5:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34b4:16)
	ld	de, (0x34e2:16)
	bit	2, (0x34f9:16)
	jr	z, VoiceSlot_Resolve_CheckC
	calr	RhythmBuf_LoadPattern
	jr	VoiceSlot_Resolve_StoreB
VoiceSlot_Resolve_CheckC:
	calr RhythmBuf_FillEmptyPattern

VoiceSlot_Resolve_StoreB:
	and	(0x34f8:16), 251
	ld	w, (0x34d6:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34b6:16)
	ld	de, (0x34e4:16)
	bit	3, (0x34f9:16)
	jr	z, VoiceSlot_Resolve_CheckD
	calr	RhythmBuf_LoadPattern
	jr	VoiceSlot_Resolve_StoreC
VoiceSlot_Resolve_CheckD:
	calr RhythmBuf_FillEmptyPattern

VoiceSlot_Resolve_StoreC:
	and	(0x34f8:16), 251
	ld	w, (0x34d7:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34b8:16)
	ld	de, (0x34e6:16)
	bit	4, (0x34f9:16)
	jr	z, VoiceSlot_Resolve_CheckE
	calr	RhythmBuf_LoadPattern
	jr	VoiceSlot_Resolve_StoreD
VoiceSlot_Resolve_CheckE:
	calr RhythmBuf_FillEmptyPattern

VoiceSlot_Resolve_StoreD:
	and	(0x34f8:16), 251
	ld	w, (0x34d8:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34ba:16)
	ld	de, (0x34e8:16)
	bit	5, (0x34f9:16)
	jr	z, VoiceSlot_Resolve_StoreE
	calr	RhythmBuf_LoadPattern
	jr	VoiceSlot_Resolve_Done
VoiceSlot_Resolve_StoreE:
	calr RhythmBuf_FillEmptyPattern

VoiceSlot_Resolve_Done:
	; anddi8 (0x35b0), 251 (v7 patched)
	and	(0x34f8:16), 251
	ret



VoiceSlot_Resolve_StoreE_Code:
	.byte	0x00, 0x00, 0xc1, 0xd4, 0x34, 0x20, 0x1e, 0x01
	.byte	0xfb, 0xd1, 0xb2, 0x34, 0x25, 0xd1, 0xc8, 0x34
	.byte	0x24, 0xd1, 0xe0, 0x34, 0x22, 0x1e, 0x41, 0x02
	.byte	0xc1, 0xd9, 0x34, 0x20, 0x1e, 0xeb, 0xfa, 0xd1
	.byte	0xbc, 0x34, 0x25, 0x1e, 0x33, 0x02, 0xc1, 0xf8
	.byte	0x34, 0x3c, 0xfb, 0xc1, 0xd5, 0x34, 0x20, 0x1e
	.byte	0xd8, 0xfa, 0xd1, 0xb4, 0x34, 0x25, 0xd1, 0xca
	.byte	0x34, 0x24, 0xd1, 0xe2, 0x34, 0x22, 0x1e, 0x18
	.byte	0x02, 0xc1, 0xda, 0x34, 0x20, 0x1e, 0xc2, 0xfa
	.byte	0xd1, 0xbe, 0x34, 0x25, 0x1e, 0x0a, 0x02, 0xc1
	.byte	0xf8, 0x34, 0x3c, 0xfb, 0xc1, 0xd6, 0x34, 0x20
	.byte	0x1e, 0xaf, 0xfa, 0xd1, 0xb6, 0x34, 0x25, 0xd1
	.byte	0xcc, 0x34, 0x24, 0xd1, 0xe4, 0x34, 0x22, 0x1e
	.byte	0xef, 0x01, 0xc1, 0xdb, 0x34, 0x20, 0x1e, 0x99
	.byte	0xfa, 0xd1, 0xc0, 0x34, 0x25, 0x1e, 0xe1, 0x01
	.byte	0xc1, 0xf8, 0x34, 0x3c, 0xfb, 0xc1, 0xd7, 0x34
	.byte	0x20, 0x1e, 0x86, 0xfa, 0xd1, 0xb8, 0x34, 0x25
	.byte	0xd1, 0xce, 0x34, 0x24, 0xd1, 0xe6, 0x34, 0x22
	.byte	0x1e, 0xc6, 0x01, 0xc1, 0xdc, 0x34, 0x20, 0x1e
	.byte	0x70, 0xfa, 0xd1, 0xc2, 0x34, 0x25, 0x1e, 0xb8
	.byte	0x01, 0xc1, 0xf8, 0x34, 0x3c, 0xfb, 0xc1, 0xd8
	.byte	0x34, 0x20, 0x1e, 0x5d, 0xfa, 0xd1, 0xba, 0x34
	.byte	0x25, 0xd1, 0xd0, 0x34, 0x24, 0xd1, 0xe8, 0x34
	.byte	0x22, 0x1e, 0x9d, 0x01, 0xc1, 0xdd, 0x34, 0x20
	.byte	0x1e, 0x47, 0xfa, 0xd1, 0xc4, 0x34, 0x25, 0x1e
	.byte	0x8f, 0x01, 0xc1, 0xf8, 0x34, 0x3c, 0xfb, 0x0e
	.byte 0x00, 0x00
AccSection_ProcessEntry:
	ld	w, (0x34d4:16)
	calr RhythmROM_CalcPatternAddr
	ld	iy, (0x34b2:16)
	ld	de, (0x34e0:16)
	bit	0, (0x34f9:16)
	jr nz, AccSection_Process_Loop
	bit	1, (0x34f9:16)
	jr nz, AccSection_Process_Loop
	jr t, AccSection_Process_Return
AccSection_Process_Loop:
	calr	RhythmBuf_LoadPattern
	ld	w, (13529:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (13500:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (13576:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (13566:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (13592:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (13582:16)
	calr	RhythmBuf_LoadPattern
	jr	AccSection_ProcessEntry_Join
AccSection_Process_Return:
	calr RhythmBuf_FillEmptyPattern

AccSection_ProcessEntry_Join:
	and	(0x34f8:16), 251
	ld	w, (0x34d5:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34b4:16)
	ld	de, (0x34e2:16)
	bit	2, (0x34f9:16)
	jr	z, AccSection_Process2_Return
	calr	RhythmBuf_LoadPattern
	ld	w, (0x34da:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34be:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (0x3509:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x3500:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (0x3519:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x3510:16)
	calr	RhythmBuf_LoadPattern
	jr	AccSection_ProcessEntry_Join2
AccSection_Process2_Return:
	calr RhythmBuf_FillEmptyPattern

AccSection_ProcessEntry_Join2:
	and	(0x34f8:16), 251
	ld	w, (0x34d6:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34b6:16)
	ld	de, (0x34e4:16)
	bit	3, (0x34f9:16)
	jr	z, AccSection_Process3_Return
	calr	RhythmBuf_LoadPattern
	ld	w, (0x34db:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34c0:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (0x350a:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x3502:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (0x351a:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x3512:16)
	calr	RhythmBuf_LoadPattern
	jr	AccSection_ProcessEntry_Join3
AccSection_Process3_Return:
	calr RhythmBuf_FillEmptyPattern

AccSection_ProcessEntry_Join3:
	and	(0x34f8:16), 251
	ld	w, (0x34d7:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34b8:16)
	ld	de, (0x34e6:16)
	bit	4, (0x34f9:16)
	jr	z, AccSection_Process4_Return
	calr	RhythmBuf_LoadPattern
	ld	w, (0x34dc:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34c2:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (0x350b:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x3504:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (0x351b:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x3514:16)
	calr	RhythmBuf_LoadPattern
	jr	AccSection_ProcessEntry_Join4
AccSection_Process4_Return:
	calr RhythmBuf_FillEmptyPattern

AccSection_ProcessEntry_Join4:
	and	(0x34f8:16), 251
	ld	w, (0x34d8:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34ba:16)
	ld	de, (0x34e8:16)
	bit	5, (0x34f9:16)
	jr	z, AccSection_Process5_Return
	calr	RhythmBuf_LoadPattern
	ld	w, (0x34dd:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x34c4:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (0x350c:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x3506:16)
	calr	RhythmBuf_LoadPattern
	ld	w, (0x351c:16)
	calr	RhythmROM_CalcPatternAddr
	ld	iy, (0x3516:16)
	calr	RhythmBuf_LoadPattern
	jr	AccSection_ProcessEntry_Join5
AccSection_Process5_Return:
	calr RhythmBuf_FillEmptyPattern

AccSection_ProcessEntry_Join5:
	; anddi8 (0x35b0), 251 (v7 patched)
	and	(0x34f8:16), 251
	ret



AccSection_Finalize:
	nop
	nop

; ============================================================================
; RhythmBuf_LoadPattern - Load rhythm pattern from ROM to DRAM buffer
; ============================================================================
; Input:  XIY = source ROM pointer, XIZ = write offset, XDE = dest base
; Output: Pattern data at 0x95c00 + index*256
; Copies bytes until end marker (0x83) or buffer full (0xfe). Chains buffers.
; ============================================================================
RhythmBuf_LoadPattern:
	bit	0, (0x34f8:16)
	jr z, .Lc_f63a39
	jp AccFill_AdvCheck_Done
AccFill_CheckPattern:
.Lc_f63a39:
	add IY,0x0006
	and XIY,0x0000ffff
	add XIY,XIX
	bit	2, (0x34f8:16)
	jr z, .Lc_f63a4d
	jr t, AccFill_ProcessDone
AccFill_ProcessEntry:
.Lc_f63a4d:
	or	(0x34f8:16), 0x04
	ld	(0x34de:16), de

	ld xiz, 6:i3



AccFill_ProcessDone:
	ld	a, (xiy)
	ld	hl, (13534:16)
	calr	AccPat_IndexToAddress
	add	xhl, xiz
	ld	(xhl), a
AccFill_ProcessDone_Join:
	cp	a, 131
	jr	z, AccFill_AdvCheck_Return
	inc	1, xiy
	inc	1, xiz
	cp	xiz, 254
	jr	ule, AccFill_AdvanceAndCheck
	calr	RhythmBuf_FindFreeBlock
	bit	0, (0x34f8:16)
	jr	nz, AccFill_AdvCheck_Return
	push	xiy
	ld	hl, (0x34de:16)
	calr	AccPat_IndexToAddress
	ld	xiy, 3:i3
	add	xiy, xhl
	ld	(xiy), de
	ld	hl, de
	calr	AccPat_IndexToAddress
	ld	xiy, 1:i3
	add	xiy, xhl
	ld	wa, (0x34de:16)
	ld	(xiy), wa
	ld	(0x34de:16), de
	or	(xhl), 128
	decw	1, (STYLE_FREE_BLOCKS:16)
	ld	xiz, 6:i3
	pop	xiy
AccFill_AdvanceAndCheck:
	ld a, (xiy)
	ld hl, de
	calr AccPat_IndexToAddress
	add xhl, xiz
	ld (xhl), a
	jr AccFill_ProcessDone_Join

AccFill_AdvCheck_Return:
	ldw wa, 0xffff
	ld hl, de
	calr AccPat_IndexToAddress
	ld xiy, 3:i3

AccFill_AdvCheck_Done:
	ret

AccFill_AdvanceAndCheck_Pad:
	nop
	nop
; RhythmBuf_BarQuartersByTimeSig: 20-byte table: bar length in quarter notes for each time-signature index 0..19
;   (1/2..4/2 = 2,4,6,8; 1/4..8/4 = 1..8; 2/8..16/8 = 1..8), indexed by byte +12 of the rhythm header at (0x34C4).
;   Basis: readers + bytes -- the values equal the length bytes of the 20 TimeSig_DisplayStrings records;
;   RhythmBuf_FillEmptyPattern multiplies it by the measure count to fill an empty pattern with 0x81 beat codes,
;   RhythmROM_ProcessPattern divides by it.
RhythmBuf_BarQuartersByTimeSig:
	.byte	2, 4, 6, 8	; 1/2 .. 4/2
	.byte	1, 2, 3, 4, 5, 6, 7, 8	; 1/4 .. 8/4
	.byte	1, 2, 3, 4, 5, 6, 7, 8	; 2/8 .. 16/8

RhythmBuf_FillEmptyPattern:
	ld	xiy, (RHYTHM_SECTION_PTR:16)
	ld L,(XIY+0x0c)
	xor H,H
	ld XIX,RhythmBuf_BarQuartersByTimeSig
	ld	w, (xix+hl)
	ld A,(XIY+0x0d)
	and A,0x07
	inc 1,A
	mul	wa, w
	push	xwa
	ld	hl, de
	calr	AccPat_IndexToAddress
	pop	xwa
	add	xhl, 6
	ld	e, a
	ld	a, 129:opc
StyleConvert_ReloadParams:
	ld (xhl), a
	inc 1, xhl
	dec 1, e
	cp e, 0:i3
	jr nz, StyleConvert_ReloadParams
	ld (xhl), 0x83
	ret

StyleConvert_Reload_Loop:
	.byte	0x00, 0x00, 0xc1, 0x37, 0x34, 0x3f, 0x10, 0x63
	.byte	0x1e, 0x21, 0x7b, 0xc1, 0x35, 0x34, 0x3f, 0x84
	.byte	0x67, 0x0d, 0xc9, 0xc8, 0x06, 0xc1, 0x35, 0x34
	.byte 0x3f, 0x88, 0x67, 0x03, 0xc9, 0xc8, 0x06, 0xc1
	.byte	0x37, 0x34, 0x81, 0xf1, 0x35, 0x34, 0x41, 0x0e
	.byte 0x00, 0x00
AccPat_CalcAccentVelocity:
	cp	(RHYTHM_LOAD_PART:16), 19
	jr	ule, StyleConvert_Reload_Return
	ld	a, 120:opc
	cp	(RHYTHM_LOAD_PROGRAM:16), 132
	jr	c, StyleConvert_Reload_CheckEnd
	add	a, 6
	cp	(RHYTHM_LOAD_PROGRAM:16), 136
	jr	c, StyleConvert_Reload_CheckEnd
	add	a, 6
StyleConvert_Reload_CheckEnd:
	add	a, (RHYTHM_LOAD_PART:16)
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	jr	StyleConvert_Reload_Done
StyleConvert_Reload_Return:
	cp	(RHYTHM_LOAD_PART:16), 16
	jr	c, StyleConvert_Reload_Done
	ld	a, 112:opc
	cp	(RHYTHM_LOAD_PROGRAM:16), 132
	jr	c, StyleConvert_Reload_Fallback
	add	a, 4
	cp	(RHYTHM_LOAD_PROGRAM:16), 136
	jr	c, StyleConvert_Reload_Fallback
	add	a, 4
StyleConvert_Reload_Fallback:
	add	a, (RHYTHM_LOAD_PART:16)
	ld	(RHYTHM_LOAD_PROGRAM:16), a
StyleConvert_Reload_Done:
	ret

StyleConvert_Reload_Fallback_Code:
	.byte	0xc1, 0x35, 0x34, 0x27, 0xc1, 0x36, 0x34, 0x26
	.byte	0x1d, 0x02, 0x27, 0xf5, 0xdb, 0x8a, 0x45, 0xf1
	.byte	0x36, 0xf6, 0x00, 0xdb, 0xd3, 0xd3, 0x07, 0xf4
	.byte 0xec, 0x20, 0xd8, 0xcf, 0xff, 0xff, 0x66, 0x0e
	.byte 0xda, 0xf0, 0x66, 0x06, 0xdb, 0xc8, 0x02, 0x00
	.byte 0x68, 0xeb, 0x21, 0x01, 0x68, 0x02, 0x21, 0x00
	.byte 0x0e, 0x00, 0x00, 0x06, 0x00, 0x06, 0x01, 0x06
	.byte 0x02, 0x06, 0x03, 0x07, 0x00, 0x07, 0x01, 0x07
	.byte	0x02, 0xff, 0xff, 0xff, 0xff, 0xc1, 0x35, 0x34
	.byte	0x27, 0xc1, 0x1e, 0x34, 0x26, 0xcf, 0xcf, 0x80
	.byte 0x6f, 0x2a, 0xce, 0xcf, 0x0c, 0x6f, 0x0c, 0x21
	.byte 0x00, 0xc1, 0x61, 0xfc, 0x20, 0x66, 0x02, 0x21
	.byte	0x01, 0x68, 0x30, 0xc1, 0x1e, 0x34, 0x21, 0xc9
	.byte 0xca, 0x0c, 0xc9, 0xcc, 0x03, 0xc1, 0x61, 0xfc
	.byte 0x20, 0x66, 0x03, 0xc9, 0xce, 0x04, 0xdb, 0xd3
	.byte 0xc9, 0x8f, 0x68, 0x17, 0xce, 0xcf, 0x0c, 0x6f
	.byte	0x04, 0x21, 0x00, 0x68, 0x0e, 0xc1, 0x1e, 0x34
	.byte 0x21, 0xc9, 0xca, 0x0c, 0xc9, 0xcc, 0x03, 0xdb
	.byte	0xd3, 0xc9, 0x8f, 0xf1, 0x37, 0x34, 0x41, 0x0e
	.byte 0x00, 0x00, 0x04, 0x08, 0x09, 0x06, 0x04, 0x08
	.byte	0x09, 0x06, 0x0e, 0xf1, 0x19, 0x34, 0xc8, 0x6e
	.byte	0x04, 0x1b, 0x66, 0x38, 0xf6, 0xc1, 0x1e, 0x34
	.byte	0x27, 0xc1, 0x35, 0x34, 0x21, 0xc1, 0x36, 0x34
	.byte	0x20, 0x2b, 0x28, 0xc1, 0x35, 0x34, 0x3f, 0x80
	.byte	0x67, 0x04, 0x1b, 0x4b, 0x38, 0xf6, 0xc1, 0x1e
	.byte	0x34, 0x3f, 0x00, 0x66, 0x04, 0x1b, 0x4b, 0x38
	.byte	0xf6, 0xf1, 0x1e, 0x34, 0x00, 0x00, 0xf1, 0x1e
	.byte	0x34, 0x00, 0x06, 0xf1, 0x1e, 0x34, 0x00, 0x07
	.byte	0xf1, 0x1e, 0x34, 0x00, 0x08, 0xf1, 0x1e, 0x34
	.byte	0x00, 0x09, 0xc1, 0xf8, 0x34, 0x3c, 0xf7, 0xf1
	.byte	0x37, 0x34, 0x00, 0x00, 0xf1, 0x1e, 0x34, 0x00
	.byte	0x00, 0xc1, 0x19, 0x34, 0x3e, 0x01, 0x1e, 0xbf
	.byte	0xf0, 0xf1, 0xf8, 0x34, 0xc8, 0x66, 0x05, 0xc1
	.byte	0xf8, 0x34, 0x3e, 0x08, 0xf1, 0x37, 0x34, 0x00
	.byte	0x04, 0xf1, 0x1e, 0x34, 0x00, 0x06, 0xc1, 0x19
	.byte	0x34, 0x3e, 0x01, 0x1e, 0xa2, 0xf0, 0xf1, 0xf8
	.byte	0x34, 0xc8, 0x66, 0x05, 0xc1, 0xf8, 0x34, 0x3e
	.byte	0x08, 0xf1, 0x37, 0x34, 0x00, 0x08, 0xf1, 0x1e
	.byte	0x34, 0x00, 0x07, 0xc1, 0x19, 0x34, 0x3e, 0x01
	.byte	0x1e, 0x85, 0xf0, 0xf1, 0xf8, 0x34, 0xc8, 0x66
	.byte	0x05, 0xc1, 0xf8, 0x34, 0x3e, 0x08, 0xf1, 0x37
	.byte	0x34, 0x00, 0x09, 0xf1, 0x1e, 0x34, 0x00, 0x08
	.byte	0xc1, 0x19, 0x34, 0x3e, 0x01, 0x1e, 0x68, 0xf0
	.byte	0xf1, 0xf8, 0x34, 0xc8, 0x66, 0x05, 0xc1, 0xf8
	.byte	0x34, 0x3e, 0x08, 0xf1, 0x37, 0x34, 0x00, 0x06
	.byte	0xf1, 0x1e, 0x34, 0x00, 0x09, 0xc1, 0x19, 0x34
	.byte	0x3e, 0x01, 0x1e, 0x4b, 0xf0, 0xf1, 0xf8, 0x34
	.byte	0xc8, 0x66, 0x05, 0xc1, 0xf8, 0x34, 0x3e, 0x08
	.byte	0xf1, 0xf8, 0x34, 0xcb, 0x66, 0x05, 0xc1, 0xf8
	.byte	0x34, 0x3e, 0x01, 0x68, 0x0d, 0xf1, 0x37, 0x34
	.byte	0x00, 0x00, 0xc1, 0x19, 0x34, 0x3e, 0x01, 0x1e
	.byte	0x26, 0xf0, 0x48, 0x4b, 0xf1, 0x36, 0x34, 0x40
	.byte	0xf1, 0x35, 0x34, 0x41, 0xf1, 0x1e, 0x34, 0x47
StyleConvert_Reload_Fallback_Code2:
	.byte 0x0e, 0x00, 0x00
AccWidget_DispatchTable:
	ld xiy, 0x9b4000
	ld xix, RHYTHM_PATTERN_BUF_A
	ldw bc, 0x8000
	ldirw
	jp AccWidget_Dispatch_Return

AccWidget_Dispatch_Return:
	ret

AccWidget_DispatchTable_Pad:
	nop
	nop
AccWidget_ProcessSpecialCmd:
	cp	(RHYTHM_LOAD_BANK:16), 0
	jr	nz, AccWidget_ProcessSpecialCmd_Join
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	xix, DrumKit_GroupAssignTable
	ld	a, (xix+a)
	ld	w, (STYLE_SECTION:16)
	sub	w, 30
	cp	a, w
	jrl	z, DrumKit_Return
AccWidget_ProcessSpecialCmd_Join:
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	ld	w, (RHYTHM_LOAD_BANK:16)
	ld	l, (RHYTHM_LOAD_PART:16)
	ld	h, (STYLE_SECTION:16)
	pushw	wa
	pushw	hl
	or	(0x3415:16), 128
	ld	(RHYTHM_LOAD_PART:16), 16
	ld	l, (STYLE_SECTION:16)
	sub	l, 30
	ld	(14573:16), l
	ld	xix, AccWidget_ProcessSpecialCmd_Data
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	ld	(14574:16), l
	calr	AccPat_CalcAccentVelocity
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_ErrorFallbackLoop
	ld	(RHYTHM_LOAD_PART:16), 17
	ld	l, (14574:16)
	inc	1, l
	ld	(STYLE_SECTION:16), l
	calr	AccPat_CalcAccentVelocity
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_ErrorFallbackLoop
	ld	(RHYTHM_LOAD_PART:16), 18
	ld	l, (14574:16)
	add	l, 2
	ld	(STYLE_SECTION:16), l
	calr	AccPat_CalcAccentVelocity
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_ErrorFallbackLoop
	ld	(RHYTHM_LOAD_PART:16), 19
	ld	l, (14574:16)
	add	l, 3
	ld	(STYLE_SECTION:16), l
	calr	AccPat_CalcAccentVelocity
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_ErrorFallbackLoop
	ld	(RHYTHM_LOAD_PART:16), 20
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	pushw	wa
	calr	AccPat_CalcAccentVelocity
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_2
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	popw	wa
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_ErrorFallbackLoop
	ld	(RHYTHM_LOAD_PART:16), 21
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	pushw	wa
	calr	AccPat_CalcAccentVelocity
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_3
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	popw	wa
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_ErrorFallbackLoop
	ld	(RHYTHM_LOAD_PART:16), 22
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	pushw	wa
	calr	AccPat_CalcAccentVelocity
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_4
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	popw	wa
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_ErrorFallbackLoop
	ld	(RHYTHM_LOAD_PART:16), 23
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	pushw	wa
	calr	AccPat_CalcAccentVelocity
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_5
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	popw	wa
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_ErrorFallbackLoop
	ld	(RHYTHM_LOAD_PART:16), 24
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	pushw	wa
	calr	AccPat_CalcAccentVelocity
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_6
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	popw	wa
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_ErrorFallbackLoop
	ld	(RHYTHM_LOAD_PART:16), 25
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	pushw	wa
	calr	AccPat_CalcAccentVelocity
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_7
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	and	a, 127
	ld	(STYLE_COPY_SRC_SECTION:16), a
	ld	a, (STYLE_SECTION:16)
	ld	(STYLE_COPY_DST_SECTION:16), a
	push	xix
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xix
	ld	(STYLE_DST_IMAGE_PTR:16), xix
	pop	xix
	calr	AccPatch_LoadDualVoiceParams
	popw	wa
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	bit	0, (0x34f8:16)
	jr	z, DrumKit_SetErrorCode20
DrumKit_ErrorFallbackLoop:
	xor c, c
	ld xix, DrumKit_FallbackSlotTable

DrumKit_ErrorFallbackSlotIter:
	ld	a, (14573:16)
	ld	w, a
	sll	a, 3
	sll	w, 1
	add	a, w
	extz	wa
	extz	xwa
	add	xwa, xix
	ld	a, (xwa+c)
	ld	(STYLE_SECTION:16), a
	push	xbc
	push	xix
	call	AccPat_InitWorkAreaFromSlot
	pop	xix
	pop	xbc
	inc	1, c
	cp	c, 10
	jr	c, DrumKit_ErrorFallbackSlotIter
	ld	(GLOBAL_ERROR_CODE:16), 23
	call	DrumVoice_NotifyEE
	ld	a, 8:opc
	call	MIDI_SendSysExCmd
	jr	DrumKit_RestoreRegisters
DrumKit_SetErrorCode20:
	ld	(GLOBAL_ERROR_CODE:16), 20
	call	DrumVoice_NotifyEE
DrumKit_RestoreRegisters:
	popw	hl
	popw	wa
	ld	(RHYTHM_LOAD_PART:16), l
	ld	(STYLE_SECTION:16), h
	ld	(RHYTHM_LOAD_BANK:16), w
	ld	(RHYTHM_LOAD_PROGRAM:16), a
DrumKit_Return:
	ret

DrumKit_GroupAssignTable:
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01
	.byte 0x02, 0x02, 0x02, 0x02, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte	0x02, 0x02, 0x02, 0x02, 0x02, 0x02
RhythmROM_LoadDrumKit_Data:	.byte	0x00, 0x00
	.byte 0x00, 0x00, 0x04, 0x04, 0x04, 0x04, 0x08, 0x08
	.byte 0x08, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x08, 0x08
	.byte	0x08, 0x08, 0x08, 0x08
AccWidget_ProcessSpecialCmd_Data:	.byte	0x00, 0x04, 0x08
AccWidget_ProcessSpecialCmd_Data_2:	.byte	0x0c
	.byte	0x12, 0x18
AccWidget_ProcessSpecialCmd_Data_3:	.byte	0x0d, 0x13, 0x19
AccWidget_ProcessSpecialCmd_Data_4:	.byte	0x0e, 0x14, 0x1a
AccWidget_ProcessSpecialCmd_Data_5:
	.byte	0x0f, 0x15, 0x1b
AccWidget_ProcessSpecialCmd_Data_6:	.byte	0x10, 0x16, 0x1c
AccWidget_ProcessSpecialCmd_Data_7:	.byte	0x11, 0x17
	.byte 0x1d

RhythmROM_LoadDrumKit:
	ld	a, (RHYTHM_LOAD_PROGRAM:16)
	ld	w, (RHYTHM_LOAD_BANK:16)
	ld	l, (RHYTHM_LOAD_PART:16)
	ld	h, (STYLE_SECTION:16)
	pushw	wa
	pushw	hl
	ld	(RHYTHM_LOAD_PART:16), 0
	ld	l, (STYLE_SECTION:16)
	sub	l, 30
	ld	(14573:16), l
	sll	l, 2
	ld	xix, RhythmROM_LoadDrumKit_Data
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	ld	(14574:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_PatternLoadFailed
	ld	(RHYTHM_LOAD_PART:16), 1
	ld	l, (14574:16)
	inc	1, l
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_PatternLoadFailed
	ld	(RHYTHM_LOAD_PART:16), 2
	ld	l, (14574:16)
	add	l, 2
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_PatternLoadFailed
	ld	(RHYTHM_LOAD_PART:16), 3
	ld	l, (14574:16)
	add	l, 3
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_PatternLoadFailed
	ld	(RHYTHM_LOAD_PART:16), 4
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_2
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_PatternLoadFailed
	ld	(RHYTHM_LOAD_PART:16), 5
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_3
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_PatternLoadFailed
	ld	(RHYTHM_LOAD_PART:16), 10
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_4
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_PatternLoadFailed
	ld	(RHYTHM_LOAD_PART:16), 11
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_5
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jrl	nz, DrumKit_PatternLoadFailed
	ld	(RHYTHM_LOAD_PART:16), 6
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_6
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jr	nz, DrumKit_PatternLoadFailed
	ld	(RHYTHM_LOAD_PART:16), 7
	ld	l, (14573:16)
	ld	xix, AccWidget_ProcessSpecialCmd_Data_7
	ld	l, (xix+l)
	ld	(STYLE_SECTION:16), l
	call	AccPat_InitWorkAreaFromSlot
	calr	RhythmROM_PatternDispatcher
	bit	0, (0x34f8:16)
	jr	z, DrumKit_AllPatternsOK
DrumKit_PatternLoadFailed:
	xor c, c
	ld xix, DrumKit_FallbackSlotTable

DrumKit_FallbackSlotLoop:
	ld	a, (14573:16)
	ld	w, a
	sll	a, 3
	sll	w, 1
	add	a, w
	extz	wa
	extz	xwa
	add	xwa, xix
	ld	a, (xwa+c)
	ld	(STYLE_SECTION:16), a
	push	xbc
	push	xix
	call	AccPat_InitWorkAreaFromSlot
	pop	xix
	pop	xbc
	inc	1, c
	cp	c, 10
	jr	c, DrumKit_FallbackSlotLoop
	ld	(GLOBAL_ERROR_CODE:16), 23
	call	DrumVoice_NotifyEE
	ld	a, 8:opc
	call	MIDI_SendSysExCmd
	jr	DrumKit_Epilogue
DrumKit_AllPatternsOK:
	ld	(GLOBAL_ERROR_CODE:16), 20
	call	DrumVoice_NotifyEE
DrumKit_Epilogue:
	popw	hl
	popw	wa
	ld	(STYLE_SECTION:16), h
	ld	(RHYTHM_LOAD_PART:16), l
	ld	(RHYTHM_LOAD_BANK:16), w
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	ret
DrumKit_FallbackSlotTable:
	.byte 0x00, 0x01, 0x02, 0x03, 0x0c, 0x0d, 0x0e, 0x0f
	.byte 0x10, 0x11, 0x04, 0x05, 0x06, 0x07, 0x12, 0x13
	.byte 0x14, 0x15, 0x16, 0x17, 0x08, 0x09, 0x0a, 0x0b
	.byte 0x18, 0x19, 0x1a, 0x1b, 0x1d, 0x1d

; AccPatch_QuantizeTick: Thunk to DrumParam_Lookup: rounds the event tick A (0..95 within a beat) to the composer
;   QUANTIZE grid W = (0x343F) & 7 -- settings 1..7 = 8, 12, 16, 24, 32, 48, 96 ticks; the result 0x7F means 'rounds
;   up into the next beat'. Basis: callers + body -- AccPatch_LookupStepByDrumParam calls it with W = (0x343F) unless
;   that is 0 (off) and on 0x7F moves to the next beat; 0x343F is the value PsCmpQtzBoxProc prints and
;   CmpRealTtl_CycleQuantize steps; the eight 96-byte arrays of DrumParam_Lookup_Data are nearest-grid-point maps.
AccPatch_QuantizeTick:
	calr DrumParam_Lookup
	ret

DrumParam_Lookup:
	push xhl
	ld xhl, 0:i3
	and w, 0x7
	sll w, 2
	ld l, w
	add xhl, DrumParam_Lookup_Data
	ld xhl, (xhl)
	push_a
	ld xwa, 0:i3
	pop_a
	add xhl, xwa
	ld a, (xhl)
	pop xhl
	ret

DrumParam_PointerTableAndData:
; DrumParam_PointerTableAndData -- eight per-parameter byte arrays and the
; table of their addresses.  ** RE-TYPED 2026-09-25 (lane accomp): was
; `ld xsp, 0x49db00f6` / `jrl nc, 32639` / swi ... (data-as-code) plus .fill
; runs.  Read by DrumParam_Lookup:
;     and w,7 / sll w,2 / ld l,w / add xhl, DrumParam_Lookup_Data /
;     ld xhl,(xhl) / ... / add xhl,xwa (xwa = A zero-extended) / ld a,(xhl)
; i.e. array W&7, element A.  Every pointer lands inside this block, so the
; eight addresses below are written relative to the label and the arrays are
; emitted at the offsets they point to.  Array lengths are the distances
; between consecutive targets (the last runs to the block's end); the
; element meaning per array is not established here.
; readers in v7 (address from the linked ELF): DrumParam_Lookup 0xF64348
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
; +0x00  2 B, not addressed by the reader
	.byte 0x00, 0x00
; +0x02  8 x LE32 -- the address of array k, k = W & 7
DrumParam_Lookup_Data:
	.long DrumParam_PointerTableAndData + 0x32	; array 0
	.long DrumParam_PointerTableAndData + 0x272	; array 1
	.long DrumParam_PointerTableAndData + 0x152	; array 2
	.long DrumParam_PointerTableAndData + 0x212	; array 3
	.long DrumParam_PointerTableAndData + 0xf2	; array 4
	.long DrumParam_PointerTableAndData + 0x1b2	; array 5
	.long DrumParam_PointerTableAndData + 0x92	; array 6
	.long DrumParam_PointerTableAndData + 0x32	; array 7
; +0x022  16 B -- not pointed at by the table
	.fill 16, 1, 0xf4
; +0x032  96 B -- array 0, 7
	.zero 48
	.fill 48, 1, 0x7f
; +0x092  96 B -- array 6
	.zero 24
	.fill 48, 1, 0x30
	.fill 24, 1, 0x7f
; +0x0f2  96 B -- array 4
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.fill 24, 1, 0x18
	.fill 24, 1, 0x30
	.fill 24, 1, 0x48
	.byte 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f
; +0x152  96 B -- array 2
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c, 0x0c
	.byte 0x0c, 0x0c, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x24, 0x24
	.byte 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30
	.byte 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x3c, 0x3c, 0x3c, 0x3c, 0x3c, 0x3c, 0x3c, 0x3c, 0x3c, 0x3c
	.byte 0x3c, 0x3c, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x49, 0x54, 0x54
	.byte 0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x54, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f
; +0x1b2  96 B -- array 5
	.zero 16
	.fill 32, 1, 0x20
	.fill 32, 1, 0x40
	.fill 16, 1, 0x7f
; +0x212  96 B -- array 3
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.fill 16, 1, 0x10
	.fill 16, 1, 0x20
	.fill 16, 1, 0x30
	.fill 16, 1, 0x40
	.fill 16, 1, 0x50
	.byte 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f, 0x7f
; +0x272  96 B -- array 1
	.byte 0x00, 0x00, 0x00, 0x00, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x10, 0x10, 0x10, 0x10
	.byte 0x10, 0x10, 0x10, 0x10, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x20, 0x20, 0x20, 0x20
	.byte 0x20, 0x20, 0x20, 0x20, 0x28, 0x28, 0x28, 0x28, 0x28, 0x28, 0x28, 0x28, 0x30, 0x30, 0x30, 0x30
	.byte 0x30, 0x30, 0x30, 0x30, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x38, 0x40, 0x40, 0x40, 0x40
	.byte 0x40, 0x40, 0x40, 0x40, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x48, 0x50, 0x50, 0x50, 0x50
	.byte 0x50, 0x50, 0x50, 0x50, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x58, 0x7f, 0x7f, 0x7f, 0x7f
CmpMode_Activate:
	push xiz
	call DrumKitInit_Entry
	pop xiz
	ret
DrumKitInit_Entry:
	ld	a, 72:opc
	call	CtrlPanel_SetIndicatorBit
	cp	(PREVIOUS_MODE:16), 14
	jr	nz, DrumKitInit_Setup
	jrl	DrumKitInit_Return
DrumKitInit_Setup:
	ld	(CMP_SOLO:16), 0
	ld	(CMP_QUANTIZE:16), 0
	ld	(STEP_NOTE_VALUE:16), 4
	ld	(STEP_PLUS_NOTE_VALUE:16), 0
	ld	(STEP_ARTICULATION:16), 1
	call	AccWrap_PlayModeDispatch
	or	(SEQ_RTMCFG:16), 4
	ld	(CMP_RECORD_PART:16), 64
	ld	a, (PANEL_STYLE:16)
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	ld	a, (PANEL_STYLE+1:16)
	ld	(RHYTHM_LOAD_BANK:16), a
	ld	a, (PANEL_STYLE:16)
	ld	(13427:16), a
	ld	a, (PANEL_STYLE+1:16)
	ld	(13428:16), a
	calr	DrumKit_SendProgramChange
	bit	2, (PANEL_STYLE+5:16)
	jr	nz, DrumKitInit_ClearAssignFlags
	bit	3, (PANEL_STYLE+5:16)
	jr	z, DrumKitInit_CheckExtAssign
DrumKitInit_ClearAssignFlags:
	and (PANEL_STYLE+5:16), 243

	ld d, 0x5:opc

	ld e, 0x48:opc

	xor wa, wa

	; call SwbtWr_QueuePostEvent (v7 addr)
	call	SwbtWr_QueuePostEvent
DrumKitInit_CheckExtAssign:
	bit	2, (PANEL_STYLE+6:16)
	jr	z, DrumKitInit_FinalSetup
	and	(PANEL_STYLE+6:16), 251
	ld	d, 6:opc
	ld	e, 72:opc
	xor	wa, wa
	call	SwbtWr_QueuePostEvent
DrumKitInit_FinalSetup:
	call	AccPatch_RecountFreeSlots
	ld	(0x3454:16), 0
	call	SeqAcc_SetIndicator_PB
	ldw	(SEQ_TRACK_MASK:16), 0
	call	Audio_CheckSubsystemReady
	and	(0xe2f8:16), 158
	or	(0x3415:16), 64
DrumKitInit_Return:
	ret

DrumKit_SendProgramChange:
	ld	xhl, 0:i3
	ld	l, (STYLE_SECTION:16)
	cp	l, 30
	jr	c, DrumKit_SendPC_MaskAndSend
	sub	l, 30
	sll	l, 2
DrumKit_SendPC_MaskAndSend:
	and l, 0x1f
	add l, 0x80
	ld xbc, 0xfc5a
	ld a, 0x0:opc
	ld	(xbc+a), l
	ld a, 0x1:opc
	ld	h, (xbc+a)
	and h, 0x80
	ld	(xbc+a), h
	calr DrumKit_PostMidiEvents
	ret

CmpMode_Deactivate:
	push xiz
	call DrumKitExit_Entry
	pop xiz
	ret

DrumKitExit_Entry:
	ld A, 0x48:opc
	call CtrlPanel_SetIndicatorBit
	cp (CURRENT_MODE:16), 0x0e
	jr nz, .Lc_f64737
	jrl t, DrumKitExit_Return
DrumKitExit_CheckState1:
.Lc_f64737:
	cp (CURRENT_MODE:16), 0x01
	jr z, .Lc_f64743
	and	(0x8cc8:16), 0xfe
DrumKitExit_ClearFlags:
.Lc_f64743:
	and	(SEQ_RTMCFG:16), 0xfb
	and	(0xe2f8:16), 0xfe
	and	(0xe2f8:16), 0xf7
	and	(0xe2f8:16), 0xdf
	ld	(CMP_SOLO:16), 0x00
	ld	(CMP_RECORD_PART:16), 0x00
	push XWA
	push XHL
	push XBC
	push XDE
	push XIX
	push XIY
	push XIZ
	call PartSelect_UpdateDisplayState
	pop XIZ
	pop XIY
	pop XIX
	pop XDE
	pop XBC
	pop XHL
	pop XWA
	bit	6, (0x3415:16)
	jr z, DrumKitExit_PostRestore
	and	(0x3415:16), 0xbf
	ld	a, (0x3473:16)
	ld (PANEL_STYLE:16), a
	ld	a, (0x3474:16)
	and A,0x7f
	and (PANEL_STYLE+1:16), 0x80
	or	(PANEL_STYLE+1:16), a
	calr	DrumKit_PostMidiEvents
DrumKitExit_PostRestore:
	call AccWrap_PlayModeDispatch
	calr DrumKit_ValidateBank
	call SeqAcc_RestorePlaybackState
	cpw	(SEQ_REC_TRACKS:16), 0
	jr nz, DrumKitExit_ExtraInit
	cpw (SEQ_TRACK_MASK:16), 0
	jr nz, DrumKitExit_ExtraInit
	jr DrumKitExit_CheckAutoPlay

DrumKitExit_ExtraInit:
	call AccWrap_PlayModeDispatch

DrumKitExit_CheckAutoPlay:
	bit	0, (ACC_RUN_FLAGS:16)
	jr	nz, DrumKitExit_Return
	or	(0x3415:16), 128
DrumKitExit_Return:
	ret

DrumKitExit_DataPad:
	ret
DrumKit_ValidateBank_Wrap:
	push	xiz
	call	DrumKit_ValidateBank
	pop	xiz
	ret

DrumKit_ValidateBank:
	ld a, (PANEL_STYLE:16)
	cp a, 0x80
	jr c, DrumKit_ValidateBank_Return
	cp a, 0x8b
	jr ule, DrumKit_ValidateBank_Return
	cp a, 0x91
	jr ugt, DrumKit_ValidateBank_Mid
	ld l, 0x80:opc
	jr DrumKit_ValidateBank_Apply

DrumKit_ValidateBank_Mid:
	cp a, 0x97
	jr ugt, DrumKit_ValidateBank_High
	ld l, 0x84:opc
	jr DrumKit_ValidateBank_Apply

DrumKit_ValidateBank_High:
	ld l, 0x88:opc

DrumKit_ValidateBank_Apply:
	push	l
	calr	DrumKit_StoreAndSendBank
	pop	l
	and	l, 31
	ld	(STYLE_SECTION:16), l
	calr	DrumKit_SendProgramChange
DrumKit_ValidateBank_Return:
	ret

DrumKit_StoreAndSendBank:
	ld (PANEL_STYLE:16), l
	and (PANEL_STYLE+1:16), 128
	ld h, 0x0:opc
	call PartCtrl_WriteProgramChange
	ld xix, PANEL_VARI_STYLE
	ld	(xix+l), h
	call DrumKit_PostMidiEvents
	ret

DrumKit_PostMidiEvents:
	ld	e, 72:opc
	ld	a, (PANEL_STYLE+1:16)
	and	a, 127
	ld	d, 1:opc
	ld	w, 0:opc
	push_a
	call	SwbtWr_QueuePostEvent
	pop_a
	ld	h, a
	ld	e, 72:opc
	ld	a, (PANEL_STYLE:16)
	and	a, 255
	ld	d, 0:opc
	ld	w, 0:opc
	push	h
	push_a
	call	SwbtWr_QueuePostEvent
	pop_a
	pop	h
	ld	l, a
	ld	(PROGRAM_CHANGE_PART:16), 72
	call	PartCtrl_WriteProgramChange
	ld	c, 72:opc
	call	MIDI_SetupChannelParams
	ret
DrumKit_UpdateStatusFlags:
	ld	w, (CMP_SOLO:16)
	and	w, 194
	bit	7, w
	jr	z, DrumKit_StoreStatus
	ld	a, (CMP_RECORD_PART:16)
	bit	4, a
	jr	z, DrumKit_StatusBit3
	or	w, 60
DrumKit_StatusBit3:
	bit 3, a
	jr z, DrumKit_StatusBit0
	or w, 0x39

DrumKit_StatusBit0:
	bit 0, a
	jr z, DrumKit_StatusBit1
	or w, 0x35

DrumKit_StatusBit1:
	bit 1, a
	jr z, DrumKit_StatusBit2
	or w, 0x2d

DrumKit_StatusBit2:
	bit 2, a
	jr z, DrumKit_StoreStatus
	or w, 0x1d

DrumKit_StoreStatus:
	ld	(CMP_SOLO:16), w
	ret
DrumKit_InlineCode1:
	push	xiz
	call	DrumKit_UpdateStatusFlags_Helper
	pop	xiz
	ret
DrumKit_UpdateStatusFlags_Helper:
	ret
CmpBkslTtl_Dispatch_Helper:
	push XIZ
	call DrumKit_InlineCode1_Helper
	pop XIZ
	ret
DrumKit_InlineCode1_Helper:
	cp	(PREVIOUS_TITLE:16), 177
	jr	z, DrumKit_InlineCode1_Join
	calr	DrumKit_UpdateStatusFlags_Helper3
	ld	(CMP_RECORD_PART:16), 64
	and	(0x3415:16), 191
	calr	DrumKit_UpdateStatusFlags_Helper2
DrumKit_InlineCode1_Join:
	and	(0xe2f8:16), 158
	ret
DrumKit_UpdateStatusFlags_Helper2:
	ld	e, (13333:16)
	and	e, 48
	ld	xhl, 0:i3
	ld	l, (STYLE_SECTION:16)
	ld	xwa, DrumKit_SlotClassBits
	add	xwa, xhl
	ld	a, (xwa)
	cp	a, e
	jr	z, DrumKit_UpdateStatusFlags_Return
	cp	e, 0:i3
	jr	nz, DrumKit_UpdateStatusFlags_Helper2_Skip
	ld	l, 0:opc
	jr	DrumKit_UpdateStatusFlags_Helper2_Join
DrumKit_UpdateStatusFlags_Helper2_Skip:
	cp	e, 32
	jr	nz, DrumKit_UpdateStatusFlags_Helper2_Skip2
	ld	l, 4:opc
	jr	DrumKit_UpdateStatusFlags_Helper2_Join
DrumKit_UpdateStatusFlags_Helper2_Skip2:
	ld	l, 8:opc
DrumKit_UpdateStatusFlags_Helper2_Join:
	ld	(STYLE_SECTION:16), l
	calr	DrumKit_SendProgramChange
DrumKit_UpdateStatusFlags_Return:
	ret
; DrumKit_SlotClassBits: for each slot (0x34D6) 0..29, the (0x34CD) bits 4-5 its class has: slots 0-3 and
;   12-17 -> 0, 4-7 and 18-23 -> 0x20, 8-11 and 24-29 -> 0x10.  DrumKit_UpdateStatusFlags_Helper compares it
;   with (0x34CD) & 0x30 and, when they differ, moves the slot to 0, 4 or 8 and sends the program change.
;   Spelled as nop / ld w / rcf / .ascii until 2026-10-06.
DrumKit_SlotClassBits:	.byte 0x00, 0x00, 0x00, 0x00, 0x20, 0x20, 0x20, 0x20, 0x10, 0x10, 0x10, 0x10
			.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
			.byte 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
DrumKit_UpdateStatusFlags_Sub:
	push	xiz
	call	DrumKit_UpdateStatusFlags_Helper3
	pop	xiz
	ret
DrumKit_UpdateStatusFlags_Helper3:
	xor	xwa, xwa
	xor	xde, xde
	ld	a, (PANEL_STYLE+3:16)
	and	a, 7
	cp	a, 0:i3
	jr	nz, DrumKit_UpdateStatusFlags_Return2
	ld	a, 2:opc
	ld	w, 7:opc
	ld	e, 72:opc
	ld	d, 3:opc
	call	SwbtWr_TrailingBytecode
	ld	a, 8:opc
	or (PANEL_STYLE+3:16), a
	ld	w, 8:opc
	ld	e, 72:opc
	ld	d, 3:opc
	call	SwbtWr_QueuePostEvent
DrumKit_UpdateStatusFlags_Return2:
	ret
DrumSlot_DispatchWrapper:
	push xiz
	call DrumSlot_Dispatch
	pop xiz
	ret

DrumSlot_Dispatch:
	cp hl, 0xa
	jr c, DrumSlot_ClampAndLookup
	ld hl, 0:i3

DrumSlot_ClampAndLookup:
	ld xiy, DrumSlot_HandlerTable
	pushw hl
	sll hl, 2
	ld	xwa, (xiy+hl)
	popw hl
	call (xwa)
	calr DrumKit_SendProgramChange
	ret

DrumSlot_HandlerTable:
	.long DrumSlot_Handler_Type0
	.long DrumSlot_Handler_Type0
	.long DrumSlot_Handler_Type0
	.long DrumSlot_Handler_Type0
	.long DrumSlot_Handler_Type1
	.long DrumSlot_Handler_Type1
	.long DrumSlot_Handler_Type1
	.long DrumSlot_Handler_Type1
	.long DrumSlot_Handler_Type1
	.long DrumSlot_Handler_Type1
DrumSlot_Handler_Type0:
	calr	DrumSlot_OffsetCalc_Simple
	ret
DrumSlot_Handler_Type1:
	; --- Wrapper: calr to F64DC4, ret (4 bytes) ---
	calr DrumSlot_OffsetCalc_Extended
	ret
DrumSlot_OffsetCalc_Simple:
	ld	e, (13333:16)
	and	e, 48
	cp	e, 0:i3
	jr	nz, DrumSlot_OffsetCalc_Check20
	jr	DrumSlot_OffsetCalc_StoreAndRet
DrumSlot_OffsetCalc_Check20:
	cp e, 0x20
	jr nz, DrumSlot_OffsetCalc_AddHigh
	add l, 0x04
	jr t, DrumSlot_OffsetCalc_StoreAndRet
DrumSlot_OffsetCalc_AddHigh:
	add l, 0x08
DrumSlot_OffsetCalc_StoreAndRet:
	ld	(STYLE_SECTION:16), l
	ret
DrumSlot_OffsetCalc_Extended:
	ld	e, (13333:16)
	and	e, 48
	cp	e, 0:i3
	jr	nz, DrumSlot_ExtOffset_Check20
	add	l, 8
	jr	DrumSlot_ExtOffset_StoreAndRet
DrumSlot_ExtOffset_Check20:
	cp e, 0x20
	jr nz, DrumSlot_ExtOffset_AddHigh
	add l, 0x0e
	jr t, DrumSlot_ExtOffset_StoreAndRet
DrumSlot_ExtOffset_AddHigh:
	add l, 0x14
DrumSlot_ExtOffset_StoreAndRet:
	ld	(STYLE_SECTION:16), l
	ret
CmpBkslSTtl_EnterTitle:
	; --- Push XIZ wrapper for inner routine (7 bytes) ---
	push xiz
	call RhythmPatInit_Entry
	pop xiz
	ret
RhythmPatInit_Entry:
	cp (PREVIOUS_TITLE:16), 0xb2
	jr z, .Lc_f64a0a
	calr RhythmPatInit_LoadParams
	ld	(CMP_RECORD_PART:16), 0x20
	cp (PREVIOUS_TITLE:16), 0xb5
	jr nz, .Lc_f64a0a
	call AccWrap_PlayModeDispatch
	or	(SEQ_RTMCFG:16), 0x04
	jr t, .Lc_f64a0a
RhythmPatInit_Cleanup:
.Lc_f64a0a:
	and	(0xe2f8:16), 0x9e

	ret





RhythmPatInit_LoadParams:
	call AccPatch_GetCurrentSlotAddr
	ld A,(XIY+0x0c)
	ld	(STYLE_SECTION_TIME_SIG:16), a
	ld L,A
	ld XWA,RhythmPatInit_KitIndexTable
	ld	a, (xwa+l)
	ld	(STYLE_SECTION_BEATS:16), a
	ld	a, (xiy+13)
	ld	(STYLE_SECTION_LAST_MEASURE:16), a
	and	(0x3416:16), 127
	ld	a, (xiy+15)
	bit	7, a
	jr	z, RhythmPatInit_FlagBit7
	or	(0x3416:16), 128
RhythmPatInit_FlagBit7:
	ld	a, (xiy+14)
	ld	w, a
	and	a, 15
	ld	(0x3431:16), a
	and	(0x3432:16), 143
	bit	4, w
	jr	z, RhythmPatInit_Tempo4
	or	(0x3432:16), 16
RhythmPatInit_Tempo4:
	bit	5, w
	jr	z, RhythmPatInit_Tempo5
	or	(0x3432:16), 32
RhythmPatInit_Tempo5:
	bit	6, w
	jr	z, RhythmPatInit_CopyChannels
	or	(0x3432:16), 64
RhythmPatInit_CopyChannels:
	add xiy, 0x40

	ld	xix, 13316

	ld xbc, 0xd

	ldir85

	ld (xix+), 0x00

	ld (xix+), 0x00

	ld (xix), 0x0

	ret



RhythmPatInit_KitIndexTable:
	.byte 0x02, 0x04, 0x06, 0x08, 0x01, 0x02, 0x03, 0x04
	.byte 0x05, 0x06, 0x07, 0x08, 0x01, 0x02, 0x03, 0x04
	.byte	0x05, 0x06, 0x07, 0x08, 0x3e, 0x1d, 0xdf, 0x45
	.byte 0xf6, 0x5e, 0x0e, 0x2b, 0xeb, 0xa8, 0x4b, 0x44
	.byte	0xf7, 0x45, 0xf6, 0x00, 0xdb, 0xcc, 0x03, 0x00
	.byte 0xdb, 0xee, 0x02, 0xe3, 0x07, 0xf0, 0xec, 0x23
	.byte	0xb3, 0xe8, 0x0e, 0x08, 0x46, 0xf6, 0x00, 0x2e
	.byte	0x46, 0xf6, 0x00, 0x44, 0x46, 0xf6, 0x00, 0x07
	.byte	0x46, 0xf6, 0x00, 0x0e, 0xc1, 0x54, 0x34, 0x3f
	.byte	0x01, 0x66, 0x07, 0xf1, 0x54, 0x34, 0x00, 0x01
	.byte	0x68, 0x17, 0xc1, 0x15, 0x34, 0x3e, 0x04, 0xf1
	.byte	0x54, 0x34, 0x00, 0x00, 0xf1, 0x8a, 0x7e, 0x00
	.byte	0x23, 0x1e, 0xf9, 0x09, 0xc1, 0xc8, 0x8c, 0x3e
	.byte	0x01, 0x0e, 0xc1, 0x54, 0x34, 0x3f, 0x01, 0x66
	.byte	0x09, 0xc1, 0x1e, 0x34, 0x3f, 0x0b, 0x6b, 0x00
	.byte	0x68, 0x05, 0xf1, 0x54, 0x34, 0x00, 0x00, 0x0e
	.byte	0xc1, 0x54, 0x34, 0x3f, 0x01, 0x66, 0x02, 0x68
	.byte 0x00, 0x0e
; CmpBkslSTtl_SelectRecPart: XIZ-preserving part select of the Composer RECORDING title (TT_CMBKSL_S): through
;   RhythmFillIn_Select it sets the record part 0x36FF = RhythmFillIn_PatternTable[HL - 4] (HL 4..8 -> DRM 0x10, AC3
;   0x04, AC2 0x02, AC1 0x01, BAS 0x08), updates the status flags and re-dispatches the audio state; the caller then
;   switches to TT_CMREAL. Basis: callers + body -- the five switch handlers (labels CmpBkslSTtl_FillIn4..8, switches
;   0..4) pass HL = 4..8 and then post title 0xB5; the screen's five VwEditSwBox buttons read DRM, AC3, AC2, AC1, BAS.
CmpBkslSTtl_SelectRecPart:
	push xiz
	call RhythmFillIn_Select
	pop xiz
	ret

RhythmFillIn_Select:
	and	(0xe2f8:16), 247
	ld	xwa, RhythmFillIn_PatternTable
	cp	hl, 4:i3
	jr	c, RhythmFillIn_LookupAndApply
	sub	hl, 4
RhythmFillIn_LookupAndApply:
	ld	a, (xwa+hl)
	ld	(CMP_RECORD_PART:16), a
	calr	DrumKit_UpdateStatusFlags
	call	AudioInit_SelectAndDispatch
	call	AudioMode_ResetVoiceState
	ret
RhythmFillIn_PatternTable:	.byte	0x10, 0x04, 0x02, 0x01, 0x08, 0x10, 0x10, 0x10
; CmpRealTtl_EnterTitle: XIZ-preserving set-up run when the Composer REALTIME RECORDING title (TT_CMREAL, 0xB5) is
;   entered or re-activated: clears 0x28A7 bit 2 and 0xE31C bit 0; unless it comes from TT_CMREAL itself it sets
;   0x8CEC bit 0 and, when not playing, sets 0x3431 bit 7, runs Seq_DispatcherEntry and, coming from TT_CMBKSL_S,
;   starts the accompaniment play (AccWrap_PlayModeStartAccPlay). Basis: callers + body -- CmpRealTtl_Dispatch
;   (EVT_ACTIVATE_STATE phase 2) and CmpRealTtlFunc_OnTitleActivate (phase 5) call it.
CmpRealTtl_EnterTitle:
	push XIZ
	call RhythmFillIn_PatternTable_Code_Helper
	pop XIZ
	ret
RhythmFillIn_PatternTable_Code_Helper:
	and	(SEQ_RTMCFG:16), 251
	and	(0xe2f8:16), 254
	cp	(PREVIOUS_TITLE:16), 181
	jr	z, RhythmFillIn_PatternTable_Code_Helper_Return
	or	(0x8cc8:16), 1
	bit	0, (ACC_RUN_FLAGS:16)
	jr	nz, RhythmFillIn_PatternTable_Code_Helper_Return
	or	(0x3415:16), 128
	call	Seq_DispatcherEntry
	cp	(PREVIOUS_TITLE:16), 178
	jr	nz, RhythmFillIn_PatternTable_Code_Helper_Return
	call	AccWrap_PlayModeStartAccPlay
RhythmFillIn_PatternTable_Code_Helper_Return:
	ret
; CmpRealTtl_CycleQuantize: XIZ-preserving action of the TT_CMREAL QUANTIZE switch: through RhythmMute_Toggle /
;   RhythmMute_StateMachine it sets 0xE31C bit 3 and steps the composer quantize setting 0x343F through 0 (off) -> 4
;   -> 5 -> 6 -> 7 -> 1 -> 2 -> 3 -> 0, i.e. 1/16, 8th triplet, 8th, quarter, 32nd triplet, 32nd, 16th triplet (grids
;   24, 32, 48, 96, 8, 12, 16 ticks). Basis: callers + body -- right-side switch row 4 of TT_CMREAL (menu text
;   "QUANTIZE") calls it and repaints 0xB5001D (the PsCmpQtzBox, which prints PtrTbl_NotePositionStrs[(0x343F)]);
;   nothing in it mutes.
CmpRealTtl_CycleQuantize:
	push xiz
	call RhythmMute_Toggle
	pop xiz
	ret

RhythmMute_Toggle:
	calr RhythmMute_StateMachine
	ret

RhythmMute_StateMachine:
	or	(0xe2f8:16), 0x08
	inc	1, (CMP_QUANTIZE:16)
	cp	(CMP_QUANTIZE:16), 0x04
	jr nz, .Lc_f64bab
	ld	(CMP_QUANTIZE:16), 0x00
	jr t, RhythmMute_StateDone
RhythmMute_State1:
.Lc_f64bab:
	cp	(CMP_QUANTIZE:16), 0x01
	jr nz, .Lc_f64bb9
	ld	(CMP_QUANTIZE:16), 0x04
	jr t, RhythmMute_StateDone
RhythmMute_State8:
.Lc_f64bb9:
	cp	(CMP_QUANTIZE:16), 0x08
	jr nz, RhythmMute_StateDone
	ld	(CMP_QUANTIZE:16), 0x01
RhythmMute_StateDone:
	ret

RhythmMute_InlineCode:
	or	(0xe2f8:16), 8
	bit	7, w
	jr	nz, RhythmMute_StateMachine_Skip3
	cp	(CMP_QUANTIZE:16), 0
	jr	nz, RhythmMute_StateMachine_Skip
	ld	(CMP_QUANTIZE:16), 4
	jr	RhythmMute_StateMachine_Join
RhythmMute_StateMachine_Skip:
	cp	(CMP_QUANTIZE:16), 3
	jr	nz, RhythmMute_StateMachine_Skip2
	ld	(CMP_QUANTIZE:16), 0
	jr	RhythmMute_StateMachine_Join
RhythmMute_StateMachine_Skip2:
	cp	(CMP_QUANTIZE:16), 7
	jr	z, RhythmMute_StateMachine_Join
	inc	1, (CMP_QUANTIZE:16)
RhythmMute_StateMachine_Join:
	jr	RhythmMute_StateMachine_Return
RhythmMute_StateMachine_Skip3:
	cp	(CMP_QUANTIZE:16), 0
	jr	nz, RhythmMute_StateMachine_Skip4
	ld	(CMP_QUANTIZE:16), 3
	jr	RhythmMute_StateMachine_Return
RhythmMute_StateMachine_Skip4:
	cp	(CMP_QUANTIZE:16), 4
	jr	nz, RhythmMute_StateMachine_Skip5
	ld	(CMP_QUANTIZE:16), 0
	jr	RhythmMute_StateMachine_Return
RhythmMute_StateMachine_Skip5:
	cp	(CMP_QUANTIZE:16), 1
	jr	z, RhythmMute_StateMachine_Return
	dec	1, (CMP_QUANTIZE:16)
RhythmMute_StateMachine_Return:
	ret
CmpRealTtl_ToggleSolo:
	push xiz
	calr RhythmSolo_Toggle
	pop xiz
	ret

RhythmSolo_Toggle:
	bit	7, (CMP_SOLO:16)
	jr	nz, RhythmSolo_Disable
	ld	(CMP_SOLO:16), 128
	jr	RhythmSolo_UpdateStatus
RhythmSolo_Disable:
	ld	(CMP_SOLO:16), 0
RhythmSolo_UpdateStatus:
	calr	DrumKit_UpdateStatusFlags
	bit	0, (ACC_RUN_FLAGS:16)
	jr	nz, RhythmSolo_Return
	or	(0x3415:16), 128
RhythmSolo_Return:
	ret

CmpRealTtl_SelectRecPart:
	push xiz
	calr RhythmVariation_Select
	pop xiz
	ret

RhythmVariation_Select:
	ld	a, (0x3417:16)
	and	a, 12
	cp	a, 0:i3
	jr	nz, RhythmVariation_Return
	ld	a, (0x3544:16)
	and	a, 12
	cp	a, 0:i3
	jr	nz, RhythmVariation_Return
	and	hl, 15
	ld	xwa, RhythmFillIn_PatternTable
	ld	a, (xwa+hl)
	ld	(CMP_RECORD_PART:16), a
	calr	DrumKit_UpdateStatusFlags
	bit	0, (ACC_RUN_FLAGS:16)
	jr	nz, RhythmVariation_PostDispatch
	or	(0x3415:16), 128
RhythmVariation_PostDispatch:
	call	AudioInit_SelectAndDispatch
	call	AudioMode_ResetVoiceState
RhythmVariation_Return:
	ret
RhythmVariation_InlineCode:
	calr	DrumKit_UpdateStatusFlags
	ret
AccDraw_Secondary_Helper:
	push	xiz
	calr	RhythmVariation_Select_Code_Helper
	pop	xiz
	ret
RhythmVariation_Select_Code_Helper:
	cp	(PREVIOUS_TITLE:16), 182
	jr	z, RhythmVariation_Select_Code_Helper_Skip
	ld	(CMP_STEP_MODE:16), 4
	or	(0x8cc8:16), 1
RhythmVariation_Select_Code_Helper_Skip:
	and	(0xe2f8:16), 254
	or	(0x3415:16), 8
	ret
CmpStep_ClearSustainBlockFlag:
	push	xiz
	calr	RhythmVariation_Select_Code_Helper2
	pop	xiz
	ret
RhythmVariation_Select_Code_Helper2:
	and	(0x3415:16), 247
	ret
; CmpStep_MoveRecPartTowardBass: XIZ-preserving call of CmpStep_MoveRecPartTowardBass_Impl (record part one
;   step toward BAS). Basis: callers + body -- AccDraw_SecondarySub_Handler08 (TT_CMSTEP switch 8) calls it.
CmpStep_MoveRecPartTowardBass:
	push	xiz
	calr	CmpStep_MoveRecPartTowardBass_Impl
	pop	xiz
	ret
; CmpStep_MoveRecPartTowardBass_Impl: replaces the composer STEP title's record part (CMP_RECORD_PART) by
;   its predecessor through the 32-byte map CmpStep_RecPartTowardBass_Map (DRM 16 -> AC3 4 -> AC2 2 ->
;   AC1 1 -> BAS 8, BAS stays), then AudioInit_SelectAndDispatch, AudioMode_ResetVoiceState and
;   DrumKit_UpdateStatusFlags. Basis: callers + body -- the opposite step of
;   CmpStep_MoveRecPartTowardDrums_Impl; its XIZ wrapper is CmpStep_MoveRecPartTowardBass.
CmpStep_MoveRecPartTowardBass_Impl:
	ld	xhl, 0:i3
	ld	l, (CMP_RECORD_PART:16)
	and	l, 31
	add	xhl, CmpStep_RecPartTowardBass_Map
	ld	a, (xhl)
	ld	(CMP_RECORD_PART:16), a
	call	AudioInit_SelectAndDispatch
	call	AudioMode_ResetVoiceState
	calr	DrumKit_UpdateStatusFlags
	ret
; Indexed by CMP_RECORD_PART & 31 (CmpStep_MoveRecPartTowardBass_Impl); only the part codes
; 1 AC1, 2 AC2, 4 AC3, 8 BAS and 16 DRM are ever read.
CmpStep_RecPartTowardBass_Map:
	.byte	0x00, 0x08, 0x01, 0x00, 0x02, 0x00, 0x00, 0x00	; AC1 -> BAS, AC2 -> AC1, AC3 -> AC2
	.byte	0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; BAS stays
	.byte	0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; DRM -> AC3
	.zero	8
CmpStep_MoveRecPartTowardDrums:
	push	xiz
	calr	RhythmVariation_Select_Code_Sub_Helper
	pop	xiz
	ret
RhythmVariation_Select_Code_Sub_Helper:
	ld	xhl, 0:i3
	ld	l, (CMP_RECORD_PART:16)
	and	l, 31
	add	xhl, CmpStep_RecPartTowardDrums_Map
	ld	a, (xhl)
	ld	(CMP_RECORD_PART:16), a
call	AudioInit_SelectAndDispatch
call	AudioMode_ResetVoiceState
	calr	DrumKit_UpdateStatusFlags
	ret
; Indexed by CMP_RECORD_PART & 31 (CmpStep_MoveRecPartTowardDrums_Impl); only the part codes
; 1 AC1, 2 AC2, 4 AC3, 8 BAS and 16 DRM are ever read.
CmpStep_RecPartTowardDrums_Map:
	.byte	0x00, 0x02, 0x04, 0x00, 0x10, 0x00, 0x00, 0x00	; AC1 -> AC2, AC2 -> AC3, AC3 -> DRM
	.byte	0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; BAS -> AC1
	.byte	0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; DRM stays
	.zero	8
	ret
AccDraw_StepNoteValue_Wrap:
	push	xiz
	calr	AccDraw_Secondary_Helper3_Helper
	pop	xiz
	ret
AccDraw_Secondary_Helper3_Helper:
	cp	(CMP_STEP_MODE:16), 4
	jr	z, AccDraw_Secondary_Helper3_Skip
	jr	RhythmVariation_Select_Code_Return
AccDraw_Secondary_Helper3_Skip:
	bit	7, w
	jr	nz, AccDraw_Secondary_Helper3_Skip2
	inc	1, (STEP_NOTE_VALUE:16)
	cp	(STEP_NOTE_VALUE:16), 13
	jr	ule, RhythmVariation_Select_Code_Join
	ld	(STEP_NOTE_VALUE:16), 13
	jr	RhythmVariation_Select_Code_Join
AccDraw_Secondary_Helper3_Skip2:
	dec	1, (STEP_NOTE_VALUE:16)
	cp	(STEP_NOTE_VALUE:16), 1
	jr	ge, RhythmVariation_Select_Code_Join
	ld	(STEP_NOTE_VALUE:16), 1
RhythmVariation_Select_Code_Join:
	jr	RhythmVariation_Select_Code_Return
RhythmVariation_Select_Code_Return:
	ret
AccDraw_AdjustPlusNoteValue:
	push	xiz
	calr	RhythmVariation_Select_Code_Helper4
	pop	xiz
	ret
RhythmVariation_Select_Code_Helper4:
	cp	(CMP_STEP_MODE:16), 4
	jr	nz, RhythmVariation_Select_Code_Return2
	bit	7, w
	jr	nz, RhythmVariation_Select_Code_Skip
	inc	1, (STEP_PLUS_NOTE_VALUE:16)
	cp	(STEP_PLUS_NOTE_VALUE:16), 13
	jr	ule, RhythmVariation_Select_Code_Join2
	ld	(STEP_PLUS_NOTE_VALUE:16), 13
	jr	RhythmVariation_Select_Code_Join2
RhythmVariation_Select_Code_Skip:
	dec	1, (STEP_PLUS_NOTE_VALUE:16)
	cp	(STEP_PLUS_NOTE_VALUE:16), 255
	jr	nz, RhythmVariation_Select_Code_Join2
	ld	(STEP_PLUS_NOTE_VALUE:16), 0
RhythmVariation_Select_Code_Join2:
	jr	RhythmVariation_Select_Code_Return2
RhythmVariation_Select_Code_Return2:
	ret
AccDraw_StepArticulation_Wrap:
	push	xiz
	calr	RhythmVariation_Select_Code_Helper5
	pop	xiz
	ret
RhythmVariation_Select_Code_Helper5:
	cp	(CMP_STEP_MODE:16), 4
	jr	z, RhythmVariation_Select_Code_Skip2
	jr	RhythmVariation_Select_Code_Join4
RhythmVariation_Select_Code_Skip2:
	bit	7, w
	jr	nz, RhythmVariation_Select_Code_Skip3
	inc	1, (STEP_ARTICULATION:16)
	cp	(STEP_ARTICULATION:16), 3
	jr	ule, RhythmVariation_Select_Code_Join3
	ld	(STEP_ARTICULATION:16), 3
	jr	RhythmVariation_Select_Code_Join3
RhythmVariation_Select_Code_Skip3:
	dec	1, (STEP_ARTICULATION:16)
	cp	(STEP_ARTICULATION:16), 255
	jr	nz, RhythmVariation_Select_Code_Join3
	ld	(STEP_ARTICULATION:16), 0
RhythmVariation_Select_Code_Join3:
	jr	RhythmVariation_Select_Code_Return3
RhythmVariation_Select_Code_Join4:
	bit	7, w
	jr	nz, RhythmVariation_InlineCode_Skip
	or	(0x3675:16), 16
	jr	RhythmVariation_Select_Code_Return3
RhythmVariation_InlineCode_Skip:
	or	(0x3675:16), 32
RhythmVariation_Select_Code_Return3:
	ret
CmpSetTtlFunc_Helper:
	push	xiz
	call	RhythmVariation_Select_Code_Helper6
	pop	xiz
	ret
RhythmVariation_Select_Code_Helper6:
	cp	(PREVIOUS_TITLE:16), 180
	jr	z, RhythmVariation_Select_Code_Skip4
	ld	(13448:16), 1
	call	AccPatch_GetCurrentSlotAddr
	ld	l, (xiy+16)
	and	l, 255
	ld	h, (xiy+17)
	and	h, 127
	calr	TimeSig_DisplayStrings_Code_Sub2
	calr	DrumKit_PostMidiEvents
RhythmVariation_Select_Code_Skip4:
	calr	Rhythm_LoadCurrentTimeSig
	ret
RhythmConfig_ReturnStub:
	ret

RhythmConfig_InlineCode2:
	push	xiz
	call	RhythmConfig_ReturnStub_Helper
	pop	xiz
	ret
RhythmConfig_ReturnStub_Helper:
	cp	(CURRENT_TITLE:16), 180
	jr	z, RhythmConfig_ReturnStub_Return
	calr	DrumKit_SendProgramChange
RhythmConfig_ReturnStub_Return:
	ret
DrumTempo_Adjust:
	push XIZ
	push XIX
	ld	a, (0x3488:16)
	bit 0x07,W
	jr nz, DrumTempo_Decrement
	ld L, 0x06:opc
	ld XIX,RHYTHM_PATTERN_BUF_A
	add XIX,0x00000010
	bit 0,(XIX)
	jr nz, DrumTempo_CheckMax
	cp	(STYLE_SECTION:16), 0x0b
	jr ugt, DrumTempo_CheckMax
	ld L, 0x08:opc
DrumTempo_CheckMax:
	cp a, l
	jr z, DrumTempo_Done
	inc 1, a
	jr DrumTempo_Store

DrumTempo_Decrement:
	cp a, 1:i3
	jr z, DrumTempo_Done
	dec 1, a

DrumTempo_Store:
	ld	(13448:16), a
DrumTempo_Done:
	pop xix
	pop xiz
	ret

CmpRecSet_DispatchCursorRow:
	push	xiz
	xor	hl, hl
	ld	l, (13448:16)
	cp	l, 1:i3
	jr	nc, CmpRecSet_DispatchCursorRow_Clamp
	ld	l, 1:opc
CmpRecSet_DispatchCursorRow_Clamp:
	dec 1, l
	calr CmpRecSet_DispatchRow
	pop xiz
	ret

CmpRecSet_DispatchRow_Wrap:
	push	xiz
	call	CmpRecSet_DispatchRow
	pop	xiz
	ret

CmpRecSet_DispatchRow:
	; ordi8 0x8d88, 1 (v7 patched)
	or	(0x8cc8:16), 1
	pushw hl

	ld xhl, 0:i3

	popw hl

	and l, 0xf

	sll xhl, 2

	; add xhl, CmpRecSet_RowHandlers (v7 patched)
	add	xhl, CmpRecSet_RowHandlers
	ld xhl, (xhl)

	call (xhl)

	ret





; CmpRecSet_RowHandlers: 15 x u32: the RECORD SETTING page's row handlers, entry = cursor row - 1 (CmpRecSet_DispatchRow): MEASURE,
;   TIME SIGNATURE, KEY, CHORD (minor bit), BASS TYPE (7th bit 6), ACCOMP TYPE (7th bit 5), the rhythm program and
;   the rhythm bank; the rest CmpRecSet_NopRow.  Handlers 0-5 step their field up, or down when bit 7 of W is set.
;   Basis: readers + bodies (record +0x0E/+0x0F fields, notes/kn5000-style-2026-10-31/README.md).
CmpRecSet_RowHandlers:
	.long CmpRecSet_OnMeasure
	.long CmpRecSet_OnTimeSig
	.long CmpRecSet_OnKey
	.long CmpRecSet_OnChord
	.long CmpRecSet_OnBassType
	.long CmpRecSet_OnAccompType
	.long CmpRecSet_OnRhythmProgram
	.long CmpRecSet_OnRhythmBank
	.long CmpRecSet_NopRow
	.long CmpRecSet_NopRow
	.long CmpRecSet_NopRow
	.long CmpRecSet_NopRow
	.long CmpRecSet_NopRow
	.long CmpRecSet_NopRow
	.long CmpRecSet_NopRow
CmpRecSet_NopRow:
	ret
CmpRecSet_OnMeasure:
	bit	7, (0x3416:16)
	jr	z, CmpRecSet_OnMeasure_Skip2
	bit	7, w
	jr	nz, CmpRecSet_OnMeasure_Skip
	inc	1, (STYLE_SECTION_LAST_MEASURE:16)
	cp	(STYLE_SECTION_LAST_MEASURE:16), 7
	jr	ule, CmpRecSet_OnMeasure_Join
	ld	(STYLE_SECTION_LAST_MEASURE:16), 7
	jr	CmpRecSet_OnMeasure_Join
CmpRecSet_OnMeasure_Skip:
	dec	1, (STYLE_SECTION_LAST_MEASURE:16)
	cp	(STYLE_SECTION_LAST_MEASURE:16), 0
	jr	ge, CmpRecSet_OnMeasure_Join
	ld	(STYLE_SECTION_LAST_MEASURE:16), 0
CmpRecSet_OnMeasure_Join:
	or	(0x3416:16), 1
	jr	CmpRecSet_OnMeasure_Code_Return
CmpRecSet_OnMeasure_Skip2:
	ld	(GLOBAL_ERROR_CODE:16), 19
	calr	DrumVoice_NotifyEE
CmpRecSet_OnMeasure_Code_Return:
	ret
CmpRecSet_OnTimeSig:
	bit	7, (0x3416:16)
	jr	z, CmpRecSet_OnTimeSig_Skip2
	bit	7, w
	jr	nz, CmpRecSet_OnTimeSig_Skip
	inc	1, (STYLE_SECTION_TIME_SIG:16)
	cp	(STYLE_SECTION_TIME_SIG:16), 11
	jr	ule, CmpRecSet_OnTimeSig_Join
	ld	(STYLE_SECTION_TIME_SIG:16), 11
	jr	CmpRecSet_OnTimeSig_Join
CmpRecSet_OnTimeSig_Skip:
	dec	1, (STYLE_SECTION_TIME_SIG:16)
	cp	(STYLE_SECTION_TIME_SIG:16), 4
	jr	ge, CmpRecSet_OnTimeSig_Join
	ld	(STYLE_SECTION_TIME_SIG:16), 4
CmpRecSet_OnTimeSig_Join:
	or	(0x3416:16), 2
	jr	CmpRecSet_OnTimeSig_Return
CmpRecSet_OnTimeSig_Skip2:
	ld	(GLOBAL_ERROR_CODE:16), 19
	calr	DrumVoice_NotifyEE
CmpRecSet_OnTimeSig_Return:
	ret
CmpRecSet_OnKey:
	or	(0xe2f8:16), 8
	bit	7, w
	jr	nz, CmpRecSet_OnKey_Skip
	inc	1, (0x3431:16)
	cp	(0x3431:16), 11
	jr	ule, CmpRecSet_OnKey_Join
	ld	(0x3431:16), 11
	jr	CmpRecSet_OnKey_Join
CmpRecSet_OnKey_Skip:
	dec	1, (0x3431:16)
	cp	(0x3431:16), 0
	jr	ge, CmpRecSet_OnKey_Join
	ld	(0x3431:16), 0
CmpRecSet_OnKey_Join:
	or	(0x341a:16), 1
	ret
CmpRecSet_OnChord:
	or	(0xe2f8:16), 8
	bit	7, w
	jr	nz, CmpRecSet_OnChord_Skip
	or	(0x3432:16), 16
	jr	CmpRecSet_OnChord_Join
CmpRecSet_OnChord_Skip:
	and	(0x3432:16), 239
CmpRecSet_OnChord_Join:
	or	(0x341a:16), 2
	ret	
CmpRecSet_OnAccompType:
	and	(0xe2f8:16), 247
	bit	7, w
	jr	nz, CmpRecSet_OnAccompType_Skip
	bit	5, (0x3432:16)
	jr	nz, CmpRecSet_OnAccompType_Return
	or	(0x3432:16), 32
	or	(0x341a:16), 4
	jr	CmpRecSet_OnAccompType_Return
CmpRecSet_OnAccompType_Skip:
	bit	5, (0x3432:16)
	jr	z, CmpRecSet_OnAccompType_Return
	and	(0x3432:16), 223
	or	(0x341a:16), 4
CmpRecSet_OnAccompType_Return:
	ret
CmpRecSet_OnBassType:
	and	(0xe2f8:16), 247
	bit	7, w
	jr	nz, CmpRecSet_OnBassType_Skip
	bit	6, (0x3432:16)
	jr	nz, CmpRecSet_OnBassType_Return
	or	(0x3432:16), 64
	or	(0x341a:16), 4
	jr	CmpRecSet_OnBassType_Return
CmpRecSet_OnBassType_Skip:
	bit	6, (0x3432:16)
	jr	z, CmpRecSet_OnBassType_Return
	and	(0x3432:16), 191
	or	(0x341a:16), 4
CmpRecSet_OnBassType_Return:
	ret
	or	(0xe2f8:16), 8
	ld	a, (0x3432:16)
	and	a, 96
	bit	7, w
	jr	nz, CmpRecSet_OnBassType_Code_Skip4
	cp	a, 0:i3
	jr	nz, CmpRecSet_OnBassType_Code_Skip
	ld	a, 64:opc
	jr	CmpRecSet_OnBassType_Code_Join
CmpRecSet_OnBassType_Code_Skip:
	cp	a, 64
	jr	nz, CmpRecSet_OnBassType_Code_Skip2
	ld	a, 32:opc
	jr	CmpRecSet_OnBassType_Code_Join
CmpRecSet_OnBassType_Code_Skip2:
	cp	a, 32
	jr	nz, CmpRecSet_OnBassType_Code_Skip3
	ld	a, 96:opc
	jr	CmpRecSet_OnBassType_Code_Join
CmpRecSet_OnBassType_Code_Skip3:
	cp	a, 96
	jr	nz, CmpRecSet_OnBassType_Code_Join
	ld	a, 96:opc
CmpRecSet_OnBassType_Code_Join:
	jr	CmpRecSet_OnBassType_Join2
CmpRecSet_OnBassType_Code_Skip4:
	cp	a, 0:i3
	jr	nz, CmpRecSet_OnBassType_Code_Skip5
	ld	a, 0:opc
	jr	CmpRecSet_OnBassType_Join2
CmpRecSet_OnBassType_Code_Skip5:
	cp	a, 64
	jr	nz, CmpRecSet_OnBassType_Code_Skip6
	ld	a, 0:opc
	jr	CmpRecSet_OnBassType_Join2
CmpRecSet_OnBassType_Code_Skip6:
	cp	a, 32
	jr	nz, CmpRecSet_OnBassType_Skip8
	ld	a, 64:opc
	jr	CmpRecSet_OnBassType_Join2
CmpRecSet_OnBassType_Skip8:
	cp	a, 96
	jr	nz, CmpRecSet_OnBassType_Join2
	ld	a, 32:opc
CmpRecSet_OnBassType_Join2:
	and	(0x3432:16), 159
	or	(0x3432:16), a
	or	(0x341a:16), 4
	ret
CmpRecSet_OnRhythmProgram:
	or	(0xe2f8:16), 8
	or	(0xe2f8:16), 1
CmpRecSet_OnRhythmProgram_Code:
	ldw	(58106:16), 1927
	ldw	(58106:16), 1670
	ld	xiy, RHYTHM_PATTERN_BUF_A
	add	xiy, 16
	ld	a, (xiy)
	bit	0, a
	jr	nz, CmpRecSet_OnRhythmProgram_Return
	calr	Rhythm_StepProgram
	calr	DrumKit_PostMidiEvents
	calr	Rhythm_LoadCurrentTimeSig
CmpRecSet_OnRhythmProgram_Return:
	ret	
CmpRecSet_OnRhythmBank:
; (was .incbin "includes/romslices/v7_transplant_DrumVoice_Handler7.bin")
	or	(0xe2f8:16), 8
	or	(0xe2f8:16), 1
	ldw	(0xe2fa:16), 1927
	ld	xiy, RHYTHM_PATTERN_BUF_A
	add	xiy, 16
	ld	a, (xiy)
	bit	0, a
	jr	nz, CmpRecSet_OnRhythmBank_Return
	calr	CmpSet_StepRhythmBank
	calr	DrumKit_PostMidiEvents
	calr	Rhythm_LoadCurrentTimeSig
CmpRecSet_OnRhythmBank_Return:
	ret
	push	xiz
	bit	0, (0x341b:16)
	jr	nz, CmpRecSet_OnRhythmBank_Epilogue
	cp	(STYLE_SECTION:16), 12
	jr	nc, CmpRecSet_OnRhythmBank_Epilogue
	calr	CmpRecSet_OnRhythmBank_Helper
CmpRecSet_OnRhythmBank_Epilogue:
	pop	xiz
	ret
CmpRecSet_OnRhythmBank_Helper:
	or	(0x8cc8:16), 1
	and	(0xe2f8:16), 247
	ld	xiy, RHYTHM_PATTERN_BUF_A
	add	xiy, 16
	ld	a, (xiy)
	bit	0, a
	jr	nz, CmpRecSet_OnRhythmBank_Code_Return
	cp	(STYLE_SECTION:16), 12
	jr	nc, CmpRecSet_OnRhythmBank_Code_Return
	calr	CmpRecSet_OnRhythmBank_Helper_Helper
CmpRecSet_OnRhythmBank_Code_Return:
	ret
	ret
	ret
	ret
	ret
	ret
	ret
	ret
	ret
	ret
	and	(0xe2f8:16), 254
	ret
CmpNcpTtl_Dispatch_Helper:
	push	xiz
	call	CmpRecSet_OnRhythmBank_Data
	pop	xiz
	ret
CmpRecSet_OnRhythmBank_Data:
	cp	(PREVIOUS_TITLE:16), 184	; TT_CMPNCP
	jr	z, CmpRecSet_OnRhythmBank_Data_Code_Skip
	calr	CmpRecSet_OnRhythmBank_Code_Helper2
	ld	l, (RHYTHM_LOAD_PROGRAM:16)
	ld	h, (RHYTHM_LOAD_BANK:16)
	calr	CmpRecSet_OnRhythmBank_Data_Code_Helper
	calr	DrumKit_PostMidiEvents
	and	(0x3415:16), 191
CmpRecSet_OnRhythmBank_Data_Code_Skip:
	calr	CmpNcp_LatchPanelRhythmAsSource
	calr	CmpRecSet_OnRhythmBank_Code_Helper
	calr	CmpRecSet_OnRhythmBank_Code_Helper2
	ret
CmpRecSet_OnRhythmBank_Code_Helper:
	ld	a, (PANEL_STYLE:16)
	and	a, 255
	cp	a, 128
	jr	c, CmpRecSet_OnRhythmBank_Code_Return2
	cp	a, 128
	jr	z, CmpRecSet_OnRhythmBank_Code_Return2
	cp	a, 132
	jr	z, CmpRecSet_OnRhythmBank_Code_Return2
	cp	a, 136
	jr	z, CmpRecSet_OnRhythmBank_Code_Return2
	and	a, 127
	ld	xix, CmpNcp_ProgramGroupBase
	ld	a, (xix+a)
	ld	(PANEL_STYLE:16), a
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	and	a, 127
	ld	(PANEL_VARI_STYLE+15:16), a
	ld	(0xffbf:16), a
	calr	DrumKit_PostMidiEvents
CmpRecSet_OnRhythmBank_Code_Return2:
	ret
CmpNcp_ProgramGroupBase:
	; (0xFC5A) & 0x7F -> the first program of its group of four: 0x81..0x83 -> 0x80, 0x85..0x87 ->
	; 0x84, 0x89..0x8B -> 0x88.  CmpRecSet_OnRhythmBank_Code_Helper returns before the lookup for
	; values below 0x80 and for 0x80, 0x84 and 0x88 themselves.
	.byte	0x80, 0x80, 0x80, 0x80, 0x84, 0x84, 0x84, 0x84, 0x88, 0x88, 0x88, 0x88
CmpNcp_SendProgramChangeOnLeave:
	push	xiz
	call	CmpRecSet_OnRhythmBank_Data_3
	pop	xiz
	ret
CmpRecSet_OnRhythmBank_Data_3:
	cp	(CURRENT_TITLE:16), 184	; TT_CMPNCP
	jr	z, CmpRecSet_OnRhythmBank_Code_Return3
	calr	DrumKit_SendProgramChange
CmpRecSet_OnRhythmBank_Code_Return3:
	ret
CmpNcpTtl_Dispatch2_Helper:
	push	xiz
	call	CmpRecSet_OnRhythmBank_Data_3_Helper
	pop	xiz
	ret
CmpRecSet_OnRhythmBank_Data_3_Helper:
	ld	a, (CMPNCP_FROM_ITEM:16)
	bit	7, w
	jr	z, CmpRecSet_OnRhythmBank_Code_Skip
	cp	a, 2:i3
	jr	z, CmpRecSet_OnRhythmBank_Code_Return4
	inc	1, a
	jr	CmpRecSet_OnRhythmBank_Code_Join
CmpRecSet_OnRhythmBank_Code_Skip:
	cp	a, 0:i3
	jr	z, CmpRecSet_OnRhythmBank_Code_Return4
	dec	1, a
CmpRecSet_OnRhythmBank_Code_Join:
	ld	(CMPNCP_FROM_ITEM:16), a
CmpRecSet_OnRhythmBank_Code_Return4:
	ret
CmpNcpTtl_Dispatch2_Helper2:
	push	xiz
	call	CmpRecSet_OnRhythmBank_Data_3_Helper2
	pop	xiz
	ret
CmpRecSet_OnRhythmBank_Data_3_Helper2:
	ld	a, (CMPNCP_FROM_ITEM:16)
	sll	a, 1
	ld	xix, CmpNcp_ItemA_HandlerIndex
	ld	hl, (xix+a)
	call	CmpNcp_CallItemHandler
	ret
CmpNcp_ItemA_HandlerIndex:
	; (0x390B), stepped between 0 and 2 by CmpRecSet_OnRhythmBank_Data_3_Helper -> the
	; CmpNcp_ItemHandlerTable index that CmpRecSet_OnRhythmBank_Data_3_Helper2 dispatches.
	; Reached through CmpNcpTtl_Dispatch2_Helper / _Helper2.
	.short	0, 1, 2
CmpRecSet_OnRhythmBank_Data_3_Sub:
	push	xiz
	call	CmpRecSet_OnRhythmBank_Data_3_Helper3
	pop	xiz
	ret
CmpRecSet_OnRhythmBank_Data_3_Helper3:
	ld	a, (CMPNCP_TO_ITEM:16)
	bit	7, w
	jr	z, CmpRecSet_OnRhythmBank_Data_3_Helper3_Skip
	cp	a, 1:i3
	jr	z, CmpRecSet_OnRhythmBank_Code_Return5
	inc	1, a
	jr	CmpRecSet_OnRhythmBank_Code_Join2
CmpRecSet_OnRhythmBank_Data_3_Helper3_Skip:
	cp	a, 0:i3
	jr	z, CmpRecSet_OnRhythmBank_Code_Return5
	dec	1, a
CmpRecSet_OnRhythmBank_Code_Join2:
	ld	(CMPNCP_TO_ITEM:16), a
CmpRecSet_OnRhythmBank_Code_Return5:
	ret
CmpNcpTtl_Dispatch2_Helper3:
	push	xiz
	call	CmpRecSet_OnRhythmBank_Data_3_Helper4
	pop	xiz
	ret
CmpRecSet_OnRhythmBank_Data_3_Helper4:
	ld	a, (CMPNCP_TO_ITEM:16)
	sll	a, 1
	ld	xix, CmpNcp_ItemB_HandlerIndex
	ld	hl, (xix+a)
	call	CmpNcp_CallItemHandler
	ret
CmpNcp_ItemB_HandlerIndex:
	; (0x390C), stepped between 0 and 1 by CmpRecSet_OnRhythmBank_Data_3_Helper3 -> the
	; CmpNcp_ItemHandlerTable index that CmpRecSet_OnRhythmBank_Data_3_Helper4 dispatches.
	; Reached through CmpNcpTtl_Dispatch2_Helper3.
	.short	3, 4
	push	xiz
	call	CmpNcp_CallItemHandler
	pop	xiz
	ret
CmpNcp_CallItemHandler:
	pushw	hl
	ld	xhl, 0:i3
	popw	hl
	and	hl, 7
	sll	hl, 2
	add	xhl, CmpNcp_ItemHandlerTable
	ld	xhl, (xhl)
	call	(xhl)
	ret
CmpNcp_ItemHandlerTable:
	; CmpNcp_CallItemHandler calls entry (HL & 7).  CmpRecSet_OnRhythmBank_Data_3_Helper2
	; and _Helper4 pass 0..4 from the two tables above; the wrapper just before
	; CmpNcp_CallItemHandler passes its caller's HL.  5 and 6 are CmpRecSet_NopRow;
	; an index of 7 would read the first four bytes of CmpNcp_ItemHandler0.  Each handler sets bits
	; of (0xE31C) and stores its own word in (0xE31E): 0x0080, 0x0181, 0x0282, 0x8505, 0x0686.
	.long	CmpNcp_ItemHandler0
	.long	CmpNcp_ItemHandler1
	.long	CmpNcp_ItemHandler2
	.long	CmpNcp_ItemHandler3
	.long	CmpNcp_ItemHandler4
	.long	CmpRecSet_NopRow
	.long	CmpRecSet_NopRow
CmpNcp_ItemHandler0:
	or	(0xe2f8:16), 8
	or	(0xe2f8:16), 1
	ldw	(0xe2fa:16), 0x0080
	calr	CmpNcp_ItemStep0
	calr	DrumKit_PostMidiEvents
	calr	CmpNcp_LatchPanelRhythmAsSource
	calr	AccPatch_CallParamLookup_Helper7
	ret
CmpNcp_ItemHandler1:
	or	(0xe2f8:16), 8
	or	(0xe2f8:16), 1
	ldw	(0xe2fa:16), 0x0181
	calr	CmpNcp_ItemStep1
	calr	DrumKit_PostMidiEvents
	calr	CmpNcp_LatchPanelRhythmAsSource
	ret
CmpNcp_ItemHandler2:
	or	(0xe2f8:16), 8
	or	(0xe2f8:16), 1
	ldw	(0xe2fa:16), 0x0282
	calr	CmpNcp_ItemStep2
	ret
CmpNcp_ItemHandler3:
	or	(0xe2f8:16), 1
	ldw	(0xe2fa:16), 0x8505
	calr	CmpNcp_ItemStep3
	ret
CmpNcp_ItemHandler4:
	or	(0xe2f8:16), 8
	or	(0xe2f8:16), 1
	ldw	(0xe2fa:16), 0x0686
	calr	CmpNcp_ItemStep4
	ret
	push	xiz
	call	CmpRecSet_OnRhythmBank_Data_4
	pop	xiz
	ret
CmpRecSet_OnRhythmBank_Data_4:
	cp	(PREVIOUS_TITLE:16), 189	; TT_CMMODE
	jr	z, CmpNcp_ItemHandler4_Join
	and	(0x3415:16), 191
	ld	xix, RHYTHM_PATTERN_BUF_A
	add	xix, 16
	ld	a, (xix)
	and	(0x341b:16), 254
	bit	0, a
	jr	z, CmpNcp_ItemHandler4_Join
	or	(0x341b:16), 1
CmpNcp_ItemHandler4_Join:
	and	(0xe2f8:16), 222
	ret
	ret
	ret
	push	xiz
	call	CmpRecSet_OnRhythmBank_Code_Entry_Data
	pop	xiz
	ret
CmpRecSet_OnRhythmBank_Code_Entry_Data:
	cp	(PREVIOUS_TITLE:16), 187	; TT_CMBEND
	jr	z, CmpNcp_ItemHandler4_Join2
	and	(0x3415:16), 191
CmpNcp_ItemHandler4_Join2:
	cp	(ACTIVE_TITLE_PREVIOUS:16), 187	; TT_CMBEND
	jr	z, CmpRecSet_OnRhythmBank_Code_Entry_Data_Join
CmpRecSet_OnRhythmBank_Code_Entry_Data_Join:
	and	(0xe2f8:16), 254
	ret
	or	(0xe2f8:16), 8
	ld	a, (PANEL_TOUCH+4:16)
	and	a, 15
	ld	w, a
	cp	hl, 0:i3
	jr	nz, CmpRecSet_OnRhythmBank_Code_Entry_Data_Code_Entry_Code_Skip
	inc	1, a
	cp	a, 13
	jr	c, CmpRecSet_OnRhythmBank_Code_Entry_Data_Code_Entry_Code_Join
	ld	a, 12:opc
	jr	CmpRecSet_OnRhythmBank_Code_Entry_Data_Code_Entry_Code_Join
CmpRecSet_OnRhythmBank_Code_Entry_Data_Code_Entry_Code_Skip:
	dec	1, a
	cp	a, 255
	jr	nz, CmpRecSet_OnRhythmBank_Code_Entry_Data_Code_Entry_Code_Join
	ld	a, 0:opc
CmpRecSet_OnRhythmBank_Code_Entry_Data_Code_Entry_Code_Join:
	ld	(PANEL_TOUCH+4:16), a
	cp	a, w
	jr	z, CmpRecSet_OnRhythmBank_Code_Return6
	ld	w, 15:opc
	ld	e, 145:opc
	ld	d, 4:opc
	call	SwbtWr_QueuePostEvent
CmpRecSet_OnRhythmBank_Code_Return6:
	ret
	ret
	ld	(STYLE_SECTION:16), 0
	calr	DrumKit_SendProgramChange
	ret
; Rhythm_StepProgram: Steps the selected rhythm's program (0xFC5A) up to 13 (W bit 7 clear) or down to 0 (W bit 7 set)
;   and takes the bank for the new program from the style part's companion bytes 0xFF92[program]: first
;   PartCtrl_WriteProgramChange with the current program / bank and (0x905B) = 72 (part 0x48), then
;   SndParam_ApplyProgramChange_Safe with the new pair and (0x905A) = 72, storing the resolved program and bank (&
;   0x7F) back to 0xFC5A / 0xFC5B. Basis: callers + body -- CmpRecSet_OnRhythmProgram (entry 6 of CmpRecSet_RowHandlers,
;   chosen by CmpRecSet_DispatchCursorRow from (0x34A4)) calls it before DrumKit_PostMidiEvents and Rhythm_LoadCurrentTimeSig,
;   whose header names 0xFC5A / 0xFC5B the rhythm program / bank.
Rhythm_StepProgram:
	push	w
	ld	l, (PANEL_STYLE:16)
	and	l, 255
	ld	h, (PANEL_STYLE+1:16)
	and	h, 127
	ld	a, 72:opc
	ld	(PROGRAM_CHANGE_PART:16), a
	call	PartCtrl_WriteProgramChange
	pop	w
	bit	7, w
	jr	nz, CmpRecSet_OnRhythmBank_Code_Skip2
	inc	1, l
	cp	l, 14
	jr	c, CmpRecSet_OnRhythmBank_Code_Join3
	ld	l, 13:opc
	jr	CmpRecSet_OnRhythmBank_Code_Join3
CmpRecSet_OnRhythmBank_Code_Skip2:
	dec	1, l
	cp	l, 255
	jr	nz, CmpRecSet_OnRhythmBank_Code_Join3
	ld	l, 0:opc
CmpRecSet_OnRhythmBank_Code_Join3:
	ld	xix, PANEL_VARI_STYLE
	ld	h, (xix+l)
	ld	a, 72:opc
	ld	(0x9036:16), a
	call	SndParam_ApplyProgramChange_Safe
	and	l, 255
	ld	(PANEL_STYLE:16), l
	and	h, 127
	ld	(PANEL_STYLE+1:16), h
	ret
Rhythm_LoadCurrentTimeSig:
	ld	l, (PANEL_STYLE:16)
	and	l, 255
	ld	h, (PANEL_STYLE+1:16)
	and	h, 127
	sll	l, 1
	sll	hl, 1
	ld	xiy, RhythmROM_BankProgramLocators
	ld	wa, (xiy+hl)
	add	hl, 2
	ld	xde, 0:i3
	ld	de, (xiy+hl)
	ld	w, a
	and	xwa, 65280
	sll	xwa, 8
	ld	xix, 0x400000
	add	xix, xwa
	add	xix, xde
	jr	CmpRecSet_OnRhythmBank_Code_Join4
CmpRecSet_OnRhythmBank_Code_Join4:
	ld	a, (xix+976)
	ld	(0x3438:16), a
	ret
; CmpSet_StepRhythmBank: Steps the rhythm bank 0xFC5B of the current rhythm program 0xFC5A (vocabulary of
;   Rhythm_LoadCurrentTimeSig) up (W bit 7 clear) or down (set), clamped to 0..AccVoice_GetChannelCount(program) (kept
;   in 0x3391); remembers it as that program's bank in 0xFF92[program] (tag 0x49's payload), applies the pair with
;   SndParam_ApplyProgramChange_Safe and stores 0xFC5A/0xFC5B. It first passes the old pair to
;   PartCtrl_WriteProgramChange (0x905B = 72). Basis: callers + body -- CmpRecSet_OnRhythmBank, entry 7 of
;   CmpRecSet_RowHandlers (CmpRecSet_DispatchCursorRow from the composer-set page-1 Up/Dn events, W = 0 / 0x80), calls it
;   before DrumKit_PostMidiEvents and Rhythm_LoadCurrentTimeSig; Rhythm_StepProgram steps the program and
;   recalls its bank from 0xFF92[program].
CmpSet_StepRhythmBank:
	push	w
	ld	l, (PANEL_STYLE:16)
	and	l, 255
	ld	h, (PANEL_STYLE+1:16)
	and	h, 127
	ld	a, 72:opc
	ld	(PROGRAM_CHANGE_PART:16), a
	call	PartCtrl_WriteProgramChange
	ld	a, h
	pushw	hl
	call	AccVoice_GetChannelCount_Direct
	ld	(ACC_EVENT:16), l
	popw	hl
	pop	w
	bit	7, w
	jr	nz, CmpRecSet_OnRhythmBank_Code_Skip3
	inc	1, a
	cp	a, (ACC_EVENT:16)
	jr	ule, CmpRecSet_OnRhythmBank_Code_Join5
	ld	a, (ACC_EVENT:16)
	jr	CmpRecSet_OnRhythmBank_Code_Join5
CmpRecSet_OnRhythmBank_Code_Skip3:
	dec	1, a
	cp	a, 255
	jr	nz, CmpRecSet_OnRhythmBank_Code_Join5
	ld	a, 0:opc
CmpRecSet_OnRhythmBank_Code_Join5:
	ld	h, a
	ld	xwa, 0xff92
	ld	(xwa+l), h
	ld	a, 72:opc
	ld	(0x9036:16), a
	call	SndParam_ApplyProgramChange_Safe
	and	l, 255
	ld	(PANEL_STYLE:16), l
	and	h, 127
	ld	(PANEL_STYLE+1:16), h
	ret
CmpRecSet_OnRhythmBank_Helper_Helper:
	ld	l, (0x3438:16)
	and	l, 31
	xor	h, h
	sll	hl, 3
	ld	xbc, TimeSig_DisplayStrings
	add	xbc, 7
	ld	w, (xbc+hl)
	ld	l, (STYLE_SECTION_TIME_SIG:16)
	and	l, 31
	xor	h, h
	sll	hl, 3
	ld	xbc, TimeSig_DisplayStrings
	add	xbc, 7
	ld	a, (xbc+hl)
	cp	a, w
	jr	nz, CmpRecSet_OnRhythmBank_Code_Skip4
	call	AccPatch_GetCurrentSlotAddr
	ld	a, (PANEL_STYLE:16)
	and	a, 255
	ld	(xiy+16), a
	ld	a, (PANEL_STYLE+1:16)
	and	a, 127
	ld	(xiy+17), a
	ld	(GLOBAL_ERROR_CODE:16), 21
	calr	DrumVoice_NotifyEE
	jr	CmpRecSet_OnRhythmBank_Code_Return7
CmpRecSet_OnRhythmBank_Code_Skip4:
	ld	(GLOBAL_ERROR_CODE:16), 22
	calr	DrumVoice_NotifyEE
	ld	a, 8:opc
	call	MIDI_SendSysExCmd
CmpRecSet_OnRhythmBank_Code_Return7:
	ret
DrumVoice_NotifyEE:
	push xwa
	push xhl
	push xbc
	push xde
	push xix
	push xiy
	push xiz
	xor wa, wa
	ld a, TT_MESAGE:opc
	call UI_InterruptTitleByIndex
	pop xiz
	pop xiy
	pop xix
	pop xde
	pop xbc
	pop xhl
	pop xwa
	ret
TimeSig_DisplayStrings:
; TimeSig_DisplayStrings +0x00..+0xC7 -- 20 time-signature records of 10 bytes:
; a 9-character display name "(n/d)+0 " and one byte that is the bar length in
; quarter notes (2/2 -> 4, 3/4 -> 3, 6/8 -> 3, 14/8 -> 7, 16/8 -> 8 ...).
; ** RE-TYPED 2026-09-25 (lane accomp): the names were .ascii already but the
; length bytes and "(4/2)" "(8/4)" "(8/8)" "(16/8)" names were spelled as
; push sr / max / reti / `pushw wa`.. (data-as-code).  The 10-byte stride and
; the 20-record count are read off the bytes: 20 records end exactly where
; the code at +0xC8 (call ...) begins.  READER NOT ESTABLISHED for this
; stride: the only direct readers found (`ld xbc, TimeSig_DisplayStrings /
; add xbc,7` after `sll hl,3`, in the code that follows CmpRecSet_OnRhythmBank)
; index it with stride 8 at +7, which does not fit 10-byte records; the
; positional labels TimeSig_DisplayStrings_Code.. point far past this table
; into the code and data that follow.
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
	.ascii "(1/2)+0  "
	.byte 2
	.ascii "(2/2)+0  "
	.byte 4
	.ascii "(3/2)+0  "
	.byte 6
	.ascii "(4/2)+0  "
	.byte 8
	.ascii "(1/4)+0  "
	.byte 1
	.ascii "(2/4)+0  "
	.byte 2
	.ascii "(3/4)+0  "
	.byte 3
	.ascii "(4/4)+0  "
	.byte 4
	.ascii "(5/4)+0  "
	.byte 5
	.ascii "(6/4)+0  "
	.byte 6
	.ascii "(7/4)+0  "
	.byte 7
	.ascii "(8/4)+0  "
	.byte 8
	.ascii "(2/8)+0  "
	.byte 1
	.ascii "(4/8)+0  "
	.byte 2
	.ascii "(6/8)+0  "
	.byte 3
	.ascii "(8/8)+0  "
	.byte 4
	.ascii "(10/8)+0 "
	.byte 5
	.ascii "(12/8)+0 "
	.byte 6
	.ascii "(14/8)+0 "
	.byte 7
	.ascii "(16/8)+0 "
	.byte 8
CmpRecSet_OnRhythmBank_Data_Code_Helper:
	call	VoiceParam_ClampAndValidate_Tramp
TimeSig_DisplayStrings_Code_Sub2:
	ld	(PANEL_STYLE:16), l
	and	h, 127
	and	(PANEL_STYLE+1:16), 128
	or	(PANEL_STYLE+1:16), h
	ld	(PROGRAM_CHANGE_PART:16), 72
	call	PartCtrl_WriteProgramChange
	ld	w, h
	extz	hl
	extz	xhl
	add	xhl, 0xff92
	jr	TimeSig_DisplayStrings_Code_Join10
TimeSig_DisplayStrings_Code_Join10:
	ld	(xhl), w
	ret
; Called by CmpNcp_ItemHandler0.  Bit 7 of W set = step down, clear = step up.
CmpNcp_ItemStep0:
	push	w
	ld	l, (PANEL_STYLE:16)
	and	l, 255
	ld	h, (PANEL_STYLE+1:16)
	and	h, 127
	ld	a, 72:opc
	ld	(PROGRAM_CHANGE_PART:16), a
	call	PartCtrl_WriteProgramChange
	pop	w
	bit	7, w
	jr	nz, TimeSig_DisplayStrings_Code_Skip2
	inc	1, l
	cp	l, 14
	jr	nz, TimeSig_DisplayStrings_Code_Skip
	ld	l, 15:opc
	jr	TimeSig_DisplayStrings_Code_Join
TimeSig_DisplayStrings_Code_Skip:
	cp	l, 16
	jr	c, TimeSig_DisplayStrings_Code_Join
	ld	l, 15:opc
	jr	TimeSig_DisplayStrings_Code_Join
TimeSig_DisplayStrings_Code_Skip2:
	dec	1, l
	cp	l, 14
	jr	nz, TimeSig_DisplayStrings_Code_Skip3
	ld	l, 13:opc
	jr	TimeSig_DisplayStrings_Code_Join
TimeSig_DisplayStrings_Code_Skip3:
	cp	l, 255
	jr	nz, TimeSig_DisplayStrings_Code_Join
	ld	l, 0:opc
TimeSig_DisplayStrings_Code_Join:
	ld	a, l
	ld	xix, PANEL_VARI_STYLE
	ld	h, (xix+l)
	ld	l, a
	ld	a, 72:opc
	ld	(0x9036:16), a
	call	SndParam_ApplyProgramChange_Safe
	and	l, 255
	ld	(PANEL_STYLE:16), l
	and	h, 127
	ld	(PANEL_STYLE+1:16), h
	cp	(RHYTHM_LOAD_PART:16), 26
	jr	z, TimeSig_DisplayStrings_Code_Return12
	cp	(PANEL_STYLE:16), 128
	jr	c, DrumVoice_NotifyEE_Skip4
	cp	(RHYTHM_LOAD_PART:16), 16
	jr	nc, TimeSig_DisplayStrings_Code_Return12
	ld	(RHYTHM_LOAD_PART:16), 16
	jr	TimeSig_DisplayStrings_Code_Return12
DrumVoice_NotifyEE_Skip4:
	cp	(RHYTHM_LOAD_PART:16), 16
	jr	c, TimeSig_DisplayStrings_Code_Return12
	ld	(RHYTHM_LOAD_PART:16), 0
TimeSig_DisplayStrings_Code_Return12:
	ret
; Called by CmpNcp_ItemHandler1.  Bit 7 of W set = step down, clear = step up.
CmpNcp_ItemStep1:
	push	w
	ld	l, (PANEL_STYLE:16)
	and	l, 255
	ld	h, (PANEL_STYLE+1:16)
	and	h, 127
	ld	a, 72:opc
	ld	(PROGRAM_CHANGE_PART:16), a
	call	PartCtrl_WriteProgramChange
	ld	a, h
	pushw	hl
	call	AccVoice_GetChannelCount_Direct
	ld	(ACC_EVENT:16), l
	popw	hl
	pop	w
	bit	7, w
	jr	nz, TimeSig_DisplayStrings_Code_Skip4
	cp	l, 15
	jr	nz, DrumVoice_NotifyEE_Skip5
	push	xix
	ld	xix, TimeSig_StepUpTable15
	ld	a, (xix+a)
	pop	xix
	jr	TimeSig_DisplayStrings_Code_Join2
DrumVoice_NotifyEE_Skip5:
	inc	1, a
	cp	a, (ACC_EVENT:16)
	jr	ule, TimeSig_DisplayStrings_Code_Join2
	ld	a, (ACC_EVENT:16)
	jr	TimeSig_DisplayStrings_Code_Join2
TimeSig_DisplayStrings_Code_Skip4:
	cp	l, 15
	jr	nz, TimeSig_DisplayStrings_Code_Skip5
	push	xix
	ld	xix, TimeSig_StepDownTable15
	ld	a, (xix+a)
	pop	xix
	jr	TimeSig_DisplayStrings_Code_Join2
TimeSig_DisplayStrings_Code_Skip5:
	dec	1, a
	cp	a, 255
	jr	nz, TimeSig_DisplayStrings_Code_Join2
	ld	a, 0:opc
TimeSig_DisplayStrings_Code_Join2:
	ld	h, a
	ld	xwa, 0xff92
	ld	(xwa+l), h
	ld	a, 72:opc
	ld	(0x9036:16), a
	call	SndParam_ApplyProgramChange_Safe
	and	l, 255
	ld	(PANEL_STYLE:16), l
	and	h, 127
	ld	(PANEL_STYLE+1:16), h
	ret
; Two 12-entry step tables for (0x3391) when AccVoice_GetChannelCount_Direct returns 15: the routine above
; takes A := TimeSig_StepUpTable15[A] on an up step and A := TimeSig_StepDownTable15[A] on a down step
; (bit 7 of W).  Were decoded as `max ... / ld (P2:8),8 ...` code; the second was the positional alias
; TimeSig_DisplayStrings + 0x227.
TimeSig_StepUpTable15:
	.byte	4, 4, 4, 4, 8, 8, 8, 8, 8, 8, 8, 8
TimeSig_StepDownTable15:
	.byte	0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 4, 4
; CmpNcp_LatchPanelRhythmAsSource: Copies the panel rhythm selection -- record 0x48 fields 0/1, program 0xFC5A and
;   bank 0xFC5B & 0x7F -- into 0x3451 / 0x3452, the rhythm the Composer copies from (< 0x80 a preset rhythm of that
;   bank, 0x80 + n composer memory n). Basis: callers + body -- every caller is on the Composer copy title TT_CMPNCP:
;   its FROM item handlers 0 and 1, its title-activate set-up, and AccPatch_CallParamLookup after a panel rhythm press
;   while CURRENT_TITLE = 184; AccPat_DispatchNoteChange copies from (0x3451) into the current pattern 0x343A.
CmpNcp_LatchPanelRhythmAsSource:
	ld	a, (PANEL_STYLE:16)
	and	a, 255
	ld	w, (PANEL_STYLE+1:16)
	and	w, 127
	ld	(RHYTHM_LOAD_PROGRAM:16), a
	ld	(RHYTHM_LOAD_BANK:16), w
	ret
CmpRecSet_OnRhythmBank_Code_Helper2:
	ld	l, (RHYTHM_LOAD_PROGRAM:16)
	and	l, 255
	cp	l, 240
	jr	c, CmpRecSet_OnRhythmBank_Code_Helper2_Skip5
	ld	l, 128:opc
	ld	(RHYTHM_LOAD_PROGRAM:16), l
	ld	(RHYTHM_LOAD_BANK:16), 0
CmpRecSet_OnRhythmBank_Code_Helper2_Skip5:
	cp	l, 128
	jr	c, DrumVoice_NotifyEE_Skip8
	ld	a, (RHYTHM_LOAD_BANK:16)
	and	a, 127
	cp	a, 0:i3
	jr	z, DrumVoice_NotifyEE_Skip8
	ld	(RHYTHM_LOAD_BANK:16), 0
DrumVoice_NotifyEE_Skip8:
	cp	l, 128
	jr	c, DrumVoice_NotifyEE_Skip14
	cp	(RHYTHM_LOAD_PART:16), 16
	jr	nc, DrumVoice_NotifyEE_Join4
	ld	(RHYTHM_LOAD_PART:16), 26
DrumVoice_NotifyEE_Join4:
	cp	(RHYTHM_LOAD_PART:16), 26
	jr	nz, DrumVoice_NotifyEE_Skip11
	ld	a, (0x3415:16)
	and	a, 48
	cp	a, 0:i3
	jr	z, DrumVoice_NotifyEE_Skip9
	cp	a, 32
	jr	z, DrumVoice_NotifyEE_Skip10
	ld	(STYLE_SECTION:16), 32
	jr	DrumVoice_NotifyEE_Return2
DrumVoice_NotifyEE_Skip9:
	ld	(STYLE_SECTION:16), 30
	jr	DrumVoice_NotifyEE_Return2
DrumVoice_NotifyEE_Skip10:
	ld	(STYLE_SECTION:16), 31
	jr	DrumVoice_NotifyEE_Return2
DrumVoice_NotifyEE_Skip11:
	cp	(STYLE_SECTION:16), 30
	jr	c, DrumVoice_NotifyEE_Return2
	ld	a, (0x3415:16)
	and	a, 48
	cp	a, 0:i3
	jr	z, DrumVoice_NotifyEE_Skip13
	cp	a, 32
	jr	z, DrumVoice_NotifyEE_Skip12
	ld	(STYLE_SECTION:16), 8
	jr	DrumVoice_NotifyEE_Return2
DrumVoice_NotifyEE_Skip12:
	ld	(STYLE_SECTION:16), 4
	jr	DrumVoice_NotifyEE_Return2
DrumVoice_NotifyEE_Skip13:
	ld	(STYLE_SECTION:16), 0
	jr	DrumVoice_NotifyEE_Return2
DrumVoice_NotifyEE_Skip14:
	cp	(RHYTHM_LOAD_PART:16), 16
	jr	c, DrumVoice_NotifyEE_Skip15
	ld	(RHYTHM_LOAD_PART:16), 26
DrumVoice_NotifyEE_Skip15:
	jr	DrumVoice_NotifyEE_Join4
DrumVoice_NotifyEE_Return2:
	ret
AccPatch_CallParamLookup_Helper7:
	ret
	cp	(RHYTHM_LOAD_PROGRAM:16), 128
	jr	c, TimeSig_DisplayStrings_Code_Return2
	cp	(RHYTHM_LOAD_PART:16), 10
	jr	c, TimeSig_DisplayStrings_Code_Return2
	ld	(RHYTHM_LOAD_PART:16), 0
TimeSig_DisplayStrings_Code_Return2:
	ret
; Called by CmpNcp_ItemHandler2.  Bit 7 of W set = step down, clear = step up.
CmpNcp_ItemStep2:
	push	w
	ld	l, (PANEL_STYLE:16)
	and	l, 255
	ld	h, (PANEL_STYLE+1:16)
	and	h, 127
	ld	a, 72:opc
	ld	(PROGRAM_CHANGE_PART:16), a
	call	PartCtrl_WriteProgramChange
	pushw	hl
	call	AccVoice_GetChannelCount_Direct
	ld	(ACC_EVENT:16), h
	popw	hl
	ld	a, l
	cp	a, 15
	jr	lt, DrumVoice_NotifyEE_Skip16
	ld	(0x3376:16), 25
	ld	(0x3377:16), 16
	jr	DrumVoice_NotifyEE_Join5
DrumVoice_NotifyEE_Skip16:
	ld	(0x3376:16), 15
	ld	(0x3377:16), 0
DrumVoice_NotifyEE_Join5:
	ld	a, (RHYTHM_LOAD_PART:16)
	pop	w
	bit	7, w
	jr	nz, TimeSig_DisplayStrings_Code_Skip14
	cp	a, 26
	jr	nz, DrumVoice_NotifyEE_Skip17
	push	xix
	ld	a, (STYLE_SECTION:16)
	ld	xix, TimeSig_StepUpTable26
	ld	a, (xix+a)
	ld	(STYLE_SECTION:16), a
	pop	xix
	ld	a, (0x3377:16)
	jr	DrumVoice_NotifyEE_Join6
DrumVoice_NotifyEE_Skip17:
	inc	1, a
	cp	a, (0x3376:16)
	jr	ule, DrumVoice_NotifyEE_Join6
	ld	a, (0x3376:16)
	jr	DrumVoice_NotifyEE_Join6
TimeSig_DisplayStrings_Code_Skip14:
	cp	a, 26
	jr	z, DrumVoice_NotifyEE_Join6
	dec	1, a
	cp	a, (0x3377:16)
	jr	ge, DrumVoice_NotifyEE_Join6
	push	xix
	ld	a, (STYLE_SECTION:16)
	ld	xix, TimeSig_StepDownTable26
	ld	a, (xix+a)
	ld	(STYLE_SECTION:16), a
	pop	xix
	ld	a, 26:opc
	jr	DrumVoice_NotifyEE_Join6
DrumVoice_NotifyEE_Join6:
	ld	(RHYTHM_LOAD_PART:16), a
	ret
TimeSig_StepDownTable26:
	; The two 33-entry remaps of (0x343A) used by CmpNcp_ItemStep2 when the position in (0x3453)
	; crosses 26: a down step below (0x3393) sets 26 and (0x343A) := TimeSig_StepDownTable26[(0x343A)];
	; an up step from 26 sets (0x3393) and (0x343A) := TimeSig_StepUpTable26[(0x343A)].  Were decoded
	; as `calr` / `max` / `ld (P2:8), 8` code.
	.byte	30, 30, 30, 30, 31, 31, 31, 31, 32, 32, 32, 32
	.byte	30, 30, 30, 30, 30, 30, 31, 31, 31, 31, 31, 31
	.byte	32, 32, 32, 32, 32, 32, 30, 31, 32
TimeSig_StepUpTable26:
	.byte	0, 0, 0, 0, 4, 4, 4, 4, 8, 8, 8, 8
	.byte	0, 0, 0, 0, 0, 0, 4, 4, 4, 4, 4, 4
	.byte	8, 8, 8, 8, 8, 8, 0, 4, 8
; Called by CmpNcp_ItemHandler3.  Bit 7 of W set = step down, clear = step up.
CmpNcp_ItemStep3:
	bit	7, w
	jr	nz, CmpNcp_ItemStep3_Down
	bit	5, (0x3415:16)
	jr	z, CmpNcp_ItemStep3_UpTestBit4
	and	(0x3415:16), 207
	or	(0x3415:16), 16
	ld	(STYLE_SECTION:16), 32
	ld	(RHYTHM_LOAD_PART:16), 26
	jr	TimeSig_DisplayStrings_Code_Return3
CmpNcp_ItemStep3_UpTestBit4:
	bit	4, (0x3415:16)
	jr	z, CmpNcp_ItemStep3_UpBit4Set
	jr	TimeSig_DisplayStrings_Code_Return3
CmpNcp_ItemStep3_UpBit4Set:
	and	(0x3415:16), 207
	or	(0x3415:16), 32
	ld	(STYLE_SECTION:16), 31
	ld	(RHYTHM_LOAD_PART:16), 26
	jr	TimeSig_DisplayStrings_Code_Return3
CmpNcp_ItemStep3_Down:
	bit	5, (0x3415:16)
	jr	z, CmpNcp_ItemStep3_Down_Skip
	and	(0x3415:16), 207
	ld	(STYLE_SECTION:16), 30
	ld	(RHYTHM_LOAD_PART:16), 26
	jr	TimeSig_DisplayStrings_Code_Return3
CmpNcp_ItemStep3_Down_Skip:
	bit	4, (0x3415:16)
	jr	z, TimeSig_DisplayStrings_Code_Return3
	and	(0x3415:16), 207
	or	(0x3415:16), 32
	ld	(STYLE_SECTION:16), 31
	ld	(RHYTHM_LOAD_PART:16), 26
	jr	TimeSig_DisplayStrings_Code_Return3
TimeSig_DisplayStrings_Code_Return3:
	ret
; Called by CmpNcp_ItemHandler4.  Steps (0x343A) through one of three helpers chosen by bits 4/5 of (0x3431).
CmpNcp_ItemStep4:
	ld	a, (STYLE_SECTION:16)
	bit	4, (0x3415:16)
	jr	z, CmpNcp_ItemStep4_Skip
	calr	CmpNcp_StepSlotInGroup2
	jr	DrumVoice_NotifyEE_Join7
CmpNcp_ItemStep4_Skip:
	bit	5, (0x3415:16)
	jr	z, DrumVoice_NotifyEE_Skip19
	calr	CmpNcp_StepSlotInGroup1
	jr	DrumVoice_NotifyEE_Join7
DrumVoice_NotifyEE_Skip19:
	calr	DrumVoice_NotifyEE_Helper
DrumVoice_NotifyEE_Join7:
	ld	(STYLE_SECTION:16), a
	ret
DrumVoice_NotifyEE_Helper:
	bit	7, w
	jr	nz, DrumVoice_NotifyEE_Skip22
	inc	1, a
	cp	a, 31
	jr	nz, DrumVoice_NotifyEE_Skip20
	calr	CmpNcp_ResetPatternToVari1
	ld	a, 0:opc
	jr	TimeSig_DisplayStrings_Code_Join4
DrumVoice_NotifyEE_Skip20:
	cp	a, 4:i3
	jr	nz, TimeSig_DisplayStrings_Code_Skip16
	ld	a, 12:opc
	jr	TimeSig_DisplayStrings_Code_Join4
TimeSig_DisplayStrings_Code_Skip16:
	cp	a, 18
	jr	lt, TimeSig_DisplayStrings_Code_Join4
	ld	a, 17:opc
	jr	TimeSig_DisplayStrings_Code_Join4
TimeSig_DisplayStrings_Code_Join4:
	jr	TimeSig_DisplayStrings_Code_Return4
DrumVoice_NotifyEE_Skip22:
	dec	1, a
	cp	a, 29
	jr	nz, DrumVoice_NotifyEE_Skip23
	ld	a, 30:opc
	jr	TimeSig_DisplayStrings_Code_Return4
DrumVoice_NotifyEE_Skip23:
	cp	a, 255
	jr	nz, TimeSig_DisplayStrings_Code_Skip18
	ld	a, 30:opc
	ld	(RHYTHM_LOAD_PART:16), 26
	jr	TimeSig_DisplayStrings_Code_Return4
TimeSig_DisplayStrings_Code_Skip18:
	cp	a, 11
	jr	nz, TimeSig_DisplayStrings_Code_Skip19
	ld	a, 3:opc
	jr	TimeSig_DisplayStrings_Code_Return4
TimeSig_DisplayStrings_Code_Skip19:
	cp	a, 18
	jr	lt, TimeSig_DisplayStrings_Code_Return4
	ld	a, 17:opc
TimeSig_DisplayStrings_Code_Return4:
	ret
; CmpNcp_ResetPatternToVari1: Sets the composer's style-pattern index (0x3453) to Vari1 of the current rhythm's
;   pattern-name set: 16 (StrStylePatt_Vari1) when the rhythm program (0xFC5A) is >= 128, else 0
;   (StrStylePatt_Vari1b). Basis: callers + body -- CmpNcp_StepSlotInGroup1/2 call it when the slot steps up out of
;   the special slot (31 -> 4, 32 -> 8), the reverse of their step down, which sets 0x3453 = 26 (ALL);
;   PsCmpCpFPtnBoxProc_OnPaintOrRepaint prints 0x3453 through the name table where 0 and 16 are 'Vari1' and 26 is
;   'ALL'.
CmpNcp_ResetPatternToVari1:
	ld	a, (PANEL_STYLE:16)
	and	a, 255
	cp	a, 128
	jr	c, DrumVoice_NotifyEE_Skip26
	ld	(RHYTHM_LOAD_PART:16), 16
	jr	TimeSig_DisplayStrings_Code_Return5
DrumVoice_NotifyEE_Skip26:
	ld	(RHYTHM_LOAD_PART:16), 0
TimeSig_DisplayStrings_Code_Return5:
	ret
; CmpNcp_StepSlotInGroup1: Steps the composer pattern slot in A (0x343A) within group 1 (0x3431 bit 5) in the order
;   31, 4..7, 18..23: W bit 7 clear = up (stops at 23; 31 -> 4 also resets 0x3453 through
;   CmpNcp_ResetPatternToVari1), set = down (stops at 31; 4 -> 31 also sets 0x3453 = 26). Returns the new slot
;   in A. Basis: callers + body -- CmpNcp_ItemStep4 calls it when (0x3431) bit 5 is set and stores A to 0x343A;
;   DrumSlot_OffsetCalc_Simple/_Extended put group 1 at slots 4..7 and 18..23, CmpNcp_ItemStep3 gives it slot 31.
CmpNcp_StepSlotInGroup1:
	bit	7, w
	jr	nz, TimeSig_DisplayStrings_Code_Skip23
	inc	1, a
	cp	a, 32
	jr	nz, TimeSig_DisplayStrings_Code_Skip21
	calr	CmpNcp_ResetPatternToVari1
	ld	a, 4:opc
	jr	TimeSig_DisplayStrings_Code_Loop
TimeSig_DisplayStrings_Code_Skip21:
	cp	a, 8
	jr	nz, TimeSig_DisplayStrings_Code_Skip22
	ld	a, 18:opc
	jr	TimeSig_DisplayStrings_Code_Loop
TimeSig_DisplayStrings_Code_Skip22:
	cp	a, 24
	jr	lt, TimeSig_DisplayStrings_Code_Loop
	ld	a, 23:opc
TimeSig_DisplayStrings_Code_Loop:
	jr	TimeSig_DisplayStrings_Code_Return6
TimeSig_DisplayStrings_Code_Skip23:
	dec	1, a
	cp	a, 30
	jr	nz, DrumVoice_NotifyEE_Skip30
	ld	a, 31:opc
	jr	TimeSig_DisplayStrings_Code_Return6
DrumVoice_NotifyEE_Skip30:
	cp	a, 3:i3
	jr	nz, TimeSig_DisplayStrings_Code_Skip25
	ld	a, 31:opc
	ld	(RHYTHM_LOAD_PART:16), 26
	jr	TimeSig_DisplayStrings_Code_Return6
TimeSig_DisplayStrings_Code_Skip25:
	cp	a, 17
	jr	nz, TimeSig_DisplayStrings_Code_Skip26
	ld	a, 7:opc
	jr	TimeSig_DisplayStrings_Code_Return6
TimeSig_DisplayStrings_Code_Skip26:
	cp	a, 24
	jr	lt, TimeSig_DisplayStrings_Code_Loop
	ld	a, 23:opc
TimeSig_DisplayStrings_Code_Return6:
	ret
; CmpNcp_StepSlotInGroup2: Steps the composer pattern slot in A (0x343A) within group 2 (0x3431 bit 4) in the order
;   32, 8..11, 24..29: W bit 7 clear = up (stops at 29; 32 -> 8 also resets 0x3453 through
;   CmpNcp_ResetPatternToVari1), set = down (stops at 32; 8 -> 32 also sets 0x3453 = 26). Returns the new slot
;   in A. Basis: callers + body -- CmpNcp_ItemStep4 calls it when (0x3431) bit 4 is set and stores A to 0x343A;
;   DrumSlot_OffsetCalc_Simple/_Extended put group 2 at slots 8..11 and 24..29, CmpNcp_ItemStep3 gives it slot 32.
CmpNcp_StepSlotInGroup2:
	bit	7, w
	jr	nz, TimeSig_DisplayStrings_Code_Skip29
	inc	1, a
	cp	a, 33
	jr	nz, TimeSig_DisplayStrings_Code_Skip27
	calr	CmpNcp_ResetPatternToVari1
	ld	a, 8:opc
	jr	TimeSig_DisplayStrings_Code_Join5
TimeSig_DisplayStrings_Code_Skip27:
	cp	a, 12
	jr	nz, TimeSig_DisplayStrings_Code_Skip28
	ld	a, 24:opc
	jr	TimeSig_DisplayStrings_Code_Join5
TimeSig_DisplayStrings_Code_Skip28:
	cp	a, 30
	jr	lt, TimeSig_DisplayStrings_Code_Join5
	ld	a, 29:opc
	jr	TimeSig_DisplayStrings_Code_Join5
TimeSig_DisplayStrings_Code_Join5:
	jr	TimeSig_DisplayStrings_Code_Return7
TimeSig_DisplayStrings_Code_Skip29:
	dec	1, a
	cp	a, 31
	jr	nz, DrumVoice_NotifyEE_Skip36
	ld	a, 32:opc
	jr	TimeSig_DisplayStrings_Code_Return7
DrumVoice_NotifyEE_Skip36:
	cp	a, 7:i3
	jr	nz, TimeSig_DisplayStrings_Code_Skip31
	ld	a, 32:opc
	ld	(RHYTHM_LOAD_PART:16), 26
	jr	TimeSig_DisplayStrings_Code_Return7
TimeSig_DisplayStrings_Code_Skip31:
	cp	a, 23
	jr	nz, CmpNcp_StepSlotInGroup2_Skip
	ld	a, 11:opc
	jr	TimeSig_DisplayStrings_Code_Return7
CmpNcp_StepSlotInGroup2_Skip:
	cp	a, 30
	jr	lt, TimeSig_DisplayStrings_Code_Join5
	ld	a, 29:opc
	jr	TimeSig_DisplayStrings_Code_Return7
TimeSig_DisplayStrings_Code_Return7:
	ret
	call	AccWrap_PlayModeDispatch
	or	(SEQ_RTMCFG:16), 4
	ld	a, (PANEL_STYLE:16)
	and	a, 15
	ld	(14418:16), a
	call	ComposerChordMap_GetRecord
	ld	(14438:16), xiy
	add	xiy, 16
	ld	(14442:16), xiy
	bit	0, (0x386e:16)
	jr	nz, CmpNcp_StepSlotInGroup2_Join
	ld	xbc, 4:i3
	ld	xiy, (14438:16)
	ld	xix, 14422
	ldir85
	ld	(14421:16), 0
CmpNcp_StepSlotInGroup2_Join:
	and	(0x386e:16), 254
	ret
	ret
	ret
; ComposerChordMap_GetRecord: XIY = RHYTHM_PATTERN_BUF_A + 0xBA0 + 32 * (0x3852; v10 0x390A): the 32-byte COMPOSER CHORD MAP record it selects
;   (style image +0xBA0, chord_map[5]).  Basis: callers + body -- the chord-map step code stores PANEL_STYLE & 15
;   in 0x3852, calls it and copies four bytes of the record to 0x3856.
ComposerChordMap_GetRecord:
	ld	xwa, 0:i3
	ld	xbc, 0:i3
	ld	a, 32:opc
	ld	c, (14418:16)
	mul	wa, c
	add	xwa, RHYTHM_PATTERN_BUF_A
	add	xwa, 2976
	ld	xiy, xwa
	ret
	ld	a, (14420:16)
	ld	xiy, 14422
	ld	c, (xiy+a)
	ld	(14417:16), c
	ret
DrumVoice_NotifyEE_Helper6:
	ld	a, (14419:16)
	ld	xiy, 14422
	ld	c, (xiy+a)
	ld	(14416:16), c
	ret
	.byte	0xc1, 0x8b, 0x28, 0x3c, 0xfb, 0xc1, 0x6e, 0x38, 0x3c, 0xfe
	ret
	ld	a, (14418:16)
	bit	7, w
	jr	nz, TimeSig_DisplayStrings_Code_Helper_Helper2_Skip2
	cp	a, 4:i3
	jr	nc, TimeSig_DisplayStrings_Code_Helper_Helper2_Skip
	inc	1, a
	jr	TimeSig_DisplayStrings_Code_Helper_Helper2_Join
TimeSig_DisplayStrings_Code_Helper_Helper2_Skip:
	ld	a, 4:opc
TimeSig_DisplayStrings_Code_Helper_Helper2_Join:
	jr	DrumVoice_NotifyEE_Join10
TimeSig_DisplayStrings_Code_Helper_Helper2_Skip2:
	cp	a, 0:i3
	jr	ule, DrumVoice_NotifyEE_Skip41
	dec	1, a
	jr	DrumVoice_NotifyEE_Join10
DrumVoice_NotifyEE_Skip41:
	ld	a, 0:opc
DrumVoice_NotifyEE_Join10:
	ld	(14418:16), a
	or	a, 240
	ld	(PANEL_STYLE:16), a
	ld	a, 0:opc
	ld	(PANEL_STYLE+1:16), a
	calr	DrumKit_PostMidiEvents
	ld	(14421:16), 0
	ret
	.byte 0xc8, 0x04
	calr	DrumVoice_NotifyEE_Helper6
	pop w
	bit	7, w
	jr	nz, DrumVoice_NotifyEE_Skip44
	cp	(14416:16), 11
	jr	nc, DrumVoice_NotifyEE_Skip42
	inc	1, (14416:16)
	jr	DrumVoice_NotifyEE_Join11
DrumVoice_NotifyEE_Skip42:
	cp	(14416:16), 255
	jr	nz, DrumVoice_NotifyEE_Skip43
	ld	(14416:16), 0
	jr	DrumVoice_NotifyEE_Join11
DrumVoice_NotifyEE_Skip43:
	ld	(14416:16), 11
DrumVoice_NotifyEE_Join11:
	jr	DrumVoice_NotifyEE_Join12
DrumVoice_NotifyEE_Skip44:
	cp	(14416:16), 0
	jr	le, DrumVoice_NotifyEE_Skip45
	dec	1, (14416:16)
	jr	DrumVoice_NotifyEE_Join12
DrumVoice_NotifyEE_Skip45:
	cp	(14419:16), 0
	jr	nz, DrumVoice_NotifyEE_Skip46
	ld	(14416:16), 0
	jr	DrumVoice_NotifyEE_Join12
DrumVoice_NotifyEE_Skip46:
	ld	(14416:16), 255
DrumVoice_NotifyEE_Join12:
	ld	a, (14416:16)
	ld	(14417:16), a
	ld	xix, 14422
	ld	c, (14419:16)
	ld	(xix+c), a
	ld	xix, 14422
	calr	DrumVoice_NotifyEE_Helper7
	or	(0x386e:16), 1
	ret
DrumVoice_NotifyEE_Helper7:
	ld	(14421:16), 0
	ld	h, 0:opc
	calr	DrumVoice_NotifyEE_Helper8
	ld	wa, bc
	pushw	wa
	ld	h, 1:opc
	calr	DrumVoice_NotifyEE_Helper8
	popw	wa
	cp	bc, 65535
	jr	z, TimeSig_DisplayStrings_Code_Skip33
	cp	bc, wa
	jr	z, TimeSig_DisplayStrings_Code_Skip33
	calr	TimeSig_DisplayStrings_Code_Helper3
TimeSig_DisplayStrings_Code_Skip33:
	pushw	wa
	ld	h, 2:opc
	calr	DrumVoice_NotifyEE_Helper8
	popw	wa
	cp	bc, 65535
	jr	z, TimeSig_DisplayStrings_Code_Skip34
	cp	bc, wa
	jr	z, TimeSig_DisplayStrings_Code_Skip34
	calr	TimeSig_DisplayStrings_Code_Helper3
TimeSig_DisplayStrings_Code_Skip34:
	pushw	wa
	ld	h, 3:opc
	calr	DrumVoice_NotifyEE_Helper8
	popw	wa
	cp	bc, 65535
	jr	z, DrumVoice_NotifyEE_Helper7_Return
	cp	bc, wa
	jr	z, DrumVoice_NotifyEE_Helper7_Return
	calr	TimeSig_DisplayStrings_Code_Helper3
DrumVoice_NotifyEE_Helper7_Return:
	ret
DrumVoice_NotifyEE_Helper8:
	ld	l, (xix+h)
	cp	l, 255
	jr	z, DrumVoice_NotifyEE_Helper8_Skip
	pushdi_b	(STYLE_SECTION)
	ld	(STYLE_SECTION:16), l
	push	h
	push	xix
	call	AccPatch_GetSlotBeatsAndMeasures
	pop	xix
	pop	h
	pop	(STYLE_SECTION:16)
	ld	b, a
	jr	DrumVoice_NotifyEE_Helper8_Return
DrumVoice_NotifyEE_Helper8_Skip:
	ldw	bc, 65535
DrumVoice_NotifyEE_Helper8_Return:
	ret
TimeSig_DisplayStrings_Code_Helper3:
	push	xwa
	ld	xwa, TimeSig_SlotBitMask
	ld	a, (xwa+h)
	or	(14421:16), a
	pop	xwa
	ret
TimeSig_SlotBitMask:
	; H -> the bit TimeSig_DisplayStrings_Code_Helper3 ORs into (0x3871); 3..7 share bit 3.
	; Was decoded as `normal / push sr / max / ld (P2:8), 8 ...`.
	.byte	0x01, 0x02, 0x04, 0x08, 0x08, 0x08, 0x08, 0x08
	push	xiz
	call	TimeSig_DisplayStrings_Helper2
	pop	xiz
	ret
TimeSig_DisplayStrings_Helper2:
	ret
	; No reference found.  Saves (0x386E)/(0x386F), runs (0x386E) = 0..4 through
	; ComposerChordMap_GetRecord, DrumVoice_NotifyEE_Helper7 (XIX = XIY) and DrumVoice_NotifyEE_Helper10,
	; restores both and clears (0x3871).  (v10/v9 name the helpers ComposerChordMap_GetRecord,
	; TimeSig_DisplayStrings_Code_Helper_Helper and TimeSig_DisplayStrings_Code_Helper3_Helper.)
TimeSig_RunSlots0to4:
	push	(0x3852:16)
	push	(0x3853:16)
	ld	(0x3852:16), 0
DrumVoice_NotifyEE_Join13:
	cp	(0x3852:16), 5
	jr	z, TimeSig_RunSlots0to4_Done
	calr	ComposerChordMap_GetRecord
	ld	xix, xiy
	push	xix
	calr	DrumVoice_NotifyEE_Helper7
	pop	xix
	calr	DrumVoice_NotifyEE_Helper10
	inc	1, (0x3852:16)
	jr	DrumVoice_NotifyEE_Join13
TimeSig_RunSlots0to4_Done:
	pop	(0x3853:16)
	pop	(0x3852:16)
	ld	(0x3855:16), 0
	ret
DrumVoice_NotifyEE_Helper10:
	bit	1, (0x3855:16)
	jr	z, TimeSig_RunSlots0to4_Join
	ld	b, 255:opc
	ld	a, 1:opc
	ld	(xix+a), b
TimeSig_RunSlots0to4_Join:
	bit	2, (0x3855:16)
	jr	z, TimeSig_RunSlots0to4_Join2
	ld	b, 255:opc
	ld	a, 2:opc
	ld	(xix+a), b
TimeSig_RunSlots0to4_Join2:
	bit	3, (0x3855:16)
	jr	z, DrumVoice_NotifyEE_Return10
	ld	b, 255:opc
	ld	a, 3:opc
	ld	(xix+a), b
DrumVoice_NotifyEE_Return10:
	ret
	ld	xbc, 4:i3
	ld	xix, (14438:16)
	ld	xiy, 14422
	ldir85
	ret
CmpEsy_PrepareRealtimeRecording:
	push XIZ
	call CmpEsy_PrepareRealtimeRecording_Impl
	pop XIZ
	ret
; CmpEsy_PrepareRealtimeRecording_Impl: Body of CmpEsy_PrepareRealtimeRecording: sets the record part 0x379B from the
;   EASY part mask 0x37C9 (TimeSig_DisplayStrings_Code_Helper4: bits 4/5/6/3 -> 1/2/4/8, else 16), then
;   DrumKit_UpdateStatusFlags, AudioInit_SelectAndDispatch, AudioMode_ResetVoiceState and RhythmPatInit_LoadParams.
;   Basis: callers + body -- its only caller is the XIZ-preserving wrapper CmpEsy_PrepareRealtimeRecording, whose
;   header describes exactly these steps; X_Impl convention (CmpSetTtl_StepEntryIndex_Impl).
CmpEsy_PrepareRealtimeRecording_Impl:
	calr	TimeSig_DisplayStrings_Code_Helper4
	calr	DrumKit_UpdateStatusFlags
	call	AudioInit_SelectAndDispatch
	call	AudioMode_ResetVoiceState
	calr	RhythmPatInit_LoadParams
	ret
TimeSig_DisplayStrings_Code_Helper4:
	ld	(CMP_RECORD_PART:16), 1
	bit	4, (0x3711:16)
	jr	nz, TimeSig_DisplayStrings_Code_Helper4_Return
	ld	(CMP_RECORD_PART:16), 2
	bit	5, (0x3711:16)
	jr	nz, TimeSig_DisplayStrings_Code_Helper4_Return
	ld	(CMP_RECORD_PART:16), 4
	bit	6, (0x3711:16)
	jr	nz, TimeSig_DisplayStrings_Code_Helper4_Return
	ld	(CMP_RECORD_PART:16), 8
	bit	3, (0x3711:16)
	jr	nz, TimeSig_DisplayStrings_Code_Helper4_Return
	ld	(CMP_RECORD_PART:16), 16
TimeSig_DisplayStrings_Code_Helper4_Return:
	ret
	ld	(0x3711:16), 16
	bit	0, (CMP_RECORD_PART:16)
	jr	nz, TimeSig_DisplayStrings_Code_Return8
	ld	(0x3711:16), 32
	bit	1, (CMP_RECORD_PART:16)
	jr	nz, TimeSig_DisplayStrings_Code_Return8
	ld	(0x3711:16), 64
	bit	2, (CMP_RECORD_PART:16)
	jr	nz, TimeSig_DisplayStrings_Code_Return8
	ld	(0x3711:16), 8
	bit	3, (CMP_RECORD_PART:16)
	jr	nz, TimeSig_DisplayStrings_Code_Return8
	ld	(0x3711:16), 1
TimeSig_DisplayStrings_Code_Return8:
	ret
CmpSetTtl_Dispatch2_Helper:
	push	xiz
	call	TimeSig_DisplayStrings_Helper4
	pop	xiz
	ret
TimeSig_DisplayStrings_Helper4:
	ld	a, (0x38f2:16)
	bit	7, w
	jr	nz, TimeSig_DisplayStrings_Code_Skip35
	cp	a, 3:i3
	jr	z, TimeSig_DisplayStrings_Code_Return9
	inc	1, a
	jr	TimeSig_DisplayStrings_Code_Join7
TimeSig_DisplayStrings_Code_Skip35:
	cp	a, 0:i3
	jr	z, TimeSig_DisplayStrings_Code_Return9
	dec	1, a
TimeSig_DisplayStrings_Code_Join7:
	ld	(0x38f2:16), a
TimeSig_DisplayStrings_Code_Return9:
	ret
; CmpSetTtl_StepEntryByte2: Steps byte +2 of the current slot entry (index (0x390E)) up or down within 0..127 (W bit 7
;   = down), preserving XIZ around CmpSetTtl_StepEntryByte2_Impl. Basis: callers + body -- the only callers are the
;   CmpSetTtl_Case_EntryByte2Up/Down switch cases.
CmpSetTtl_StepEntryByte2:
	push	xiz
	call	CmpSetTtl_StepEntryByte2_Impl
	pop	xiz
	ret
; CmpSetTtl_StepEntryByte2_Impl: Body of CmpSetTtl_StepEntryByte2: steps byte +2 of entry (0x390E) of the current slot
;   record (AccPatch_GetCurrentSlotAddr; offset from TimeSig_SlotEntryByte2Offsets) within 0..127, up when W bit 7 is
;   clear, down when set. Basis: callers + body -- its only caller is the XIZ wrapper CmpSetTtl_StepEntryByte2, whose
;   header describes exactly this.
CmpSetTtl_StepEntryByte2_Impl:
	pushw	wa
	call	AccPatch_GetCurrentSlotAddr
	popw	wa
	ld	xix, TimeSig_SlotEntryByte2Offsets
	ld	a, (0x38f2:16)
	ld	a, (xix+a)
	ld	l, (xiy+a)
	bit	7, w
	jr	nz, TimeSig_DisplayStrings_Code_Skip36
	cp	l, 127
	jr	z, TimeSig_DisplayStrings_Code_Return10
	inc	1, l
	jr	TimeSig_DisplayStrings_Code_Join8
TimeSig_DisplayStrings_Code_Skip36:
	cp	l, 0:i3
	jr	z, TimeSig_DisplayStrings_Code_Return10
	dec	1, l
TimeSig_DisplayStrings_Code_Join8:
	ld	(xiy+a), l
TimeSig_DisplayStrings_Code_Return10:
	ret
TimeSig_SlotEntryByte2Offsets:
	; Offsets in the current slot record (AccPatch_GetCurrentSlotAddr) of byte +2 of its four 8-byte
	; entries, indexed by (0x390E); TimeSig_SlotFieldOffsets are the same entries' byte +5.
	; CmpSetTtl_StepEntryByte2_Impl steps the byte within 0..127.
	.byte	34, 42, 50, 58
; CmpSetTtl_StepEntryByte5: XIZ-preserving wrapper of CmpSetTtl_StepEntryByte5_Impl: steps byte +5 of the selected
;   entry (0x390E) of the current slot record within 0..11, up, or down when W bit 7 is set. Basis: callers + body --
;   called only by CmpSetTtl_Case_EntryByte5Up (W = 0) and CmpSetTtl_Case_EntryByte5Down (W = 0x80); the field's
;   meaning is not established, so the name keeps the callers' 'EntryByte5'.
CmpSetTtl_StepEntryByte5:
	push	xiz
	call	CmpSetTtl_StepEntryByte5_Impl
	pop	xiz
	ret
; CmpSetTtl_StepEntryByte5_Impl: Body of CmpSetTtl_StepEntryByte5: steps byte +5 of entry (0x390E) of the current slot
;   record (AccPatch_GetCurrentSlotAddr; offset from TimeSig_SlotFieldOffsets) within 0..11, up when W bit 7 is clear,
;   down when set. Basis: callers + body -- its only caller is the XIZ wrapper CmpSetTtl_StepEntryByte5, whose header
;   describes exactly this (and keeps 'EntryByte5' because the field's meaning is not established).
CmpSetTtl_StepEntryByte5_Impl:
	pushw	wa
	call	AccPatch_GetCurrentSlotAddr
	popw	wa
	ld	xix, TimeSig_SlotFieldOffsets
	ld	a, (0x38f2:16)
	ld	a, (xix+a)
	ld	l, (xiy+a)
	bit	7, w
	jr	nz, TimeSig_DisplayStrings_Code_Skip37
	cp	l, 11
	jr	z, TimeSig_DisplayStrings_Code_Return11
	inc	1, l
	jr	TimeSig_DisplayStrings_Code_Join9
TimeSig_DisplayStrings_Code_Skip37:
	cp	l, 0:i3
	jr	z, TimeSig_DisplayStrings_Code_Return11
	dec	1, l
TimeSig_DisplayStrings_Code_Join9:
	ld	(xiy+a), l
TimeSig_DisplayStrings_Code_Return11:
	ret
; TimeSig_SlotFieldOffsets -- offsets into the current slot record (AccPatch_GetCurrentSlotAddr), indexed by (0x390E)
TimeSig_SlotFieldOffsets:	.byte	37, 45, 53, 61
; S2cTtl_InitOnTitleChange -- when CURRENT_TITLE differs from PREVIOUS_TITLE: (0x38ED) := (0xFFE3) + 1, and if (0x38EE)
;          is 0, seed 0x38EE-0x38F9.  Called from S2cTtl_Dispatch.  Was part of a `.byte` run until 2026-10-03.
S2cTtl_InitOnTitleChange:
	ld	a, (CURRENT_TITLE:16)
	cp	a, (PREVIOUS_TITLE:16)
	ret	z
	ld	a, (SEQ_CURRENT_SONG:24)
	inc	1, a
	ld	(0x38d1:16), a
	cpw	(0x38d2:16), 0
	ret	nz
	ldw	(0x38d2:16), 1
	ldw	(0x38d4:16), 1
	ld	(0x38d6:16), 25
	ld	(0x38d7:16), 0
	ld	(0x38d8:16), 0
	ld	(0x38d9:16), 0
	ld	(0x38da:16), 0
	ld	(0x38db:16), 0
	ld	(0x38dc:16), 0
	ld	(0x38dd:16), 0
	ret
	ret
; TimeSig_CallProc -- WA = index 0..23 (`cp de, 23 / ret ugt`), BC bit 7 = a flag
; passed on in A; calls TimeSig_ProcTable[index] (`ld xde, TimeSig_ProcTable / add
; xde, xbc / ld xhl, (xde) / call (xhl)`).
TimeSig_CallProc:
	cp	wa, 23
	ret UGT
	bit	7, bc
	jr	nz, TimeSig_CallProc_Skip
	ld	c, 0:opc
	jr	TimeSig_CallProc_Skip2
TimeSig_CallProc_Skip:
	ld	c, 1:opc
TimeSig_CallProc_Skip2:
	extz	bc
	extz	xwa
	sll	xwa, 2
	ld	xde, TimeSig_ProcTable
	add	xde, xwa
	ld	wa, bc
	ld	xhl, (xde)
	call	(xhl)
	ret
Tempo_AdjustStartMeasure:
	dec 2,XSP
	ld (XSP),A
	ldw WA, 0x0080
	ld bc, 0:i3
	calr Tempo_DisplayParamCommon
	cp (XSP),0x00
	jr nz, Tempo_StartMeasureDec
	cpw	(0x38d2:16), 0x3e7
	jr nc, Tempo_StartMeasureReturn
	incw	1, (0x38d2:16)
	jr t, Tempo_StartMeasureSync
Tempo_StartMeasureDec:
	cpw	(0x38d2:16), 1
	jr	ule, Tempo_StartMeasureReturn
	decw	1, (0x38d2:16)
Tempo_StartMeasureSync:
	ld	wa, (14546:16)
	cp	wa, (0x38d4:16)
	jr	ule, Tempo_StartMeasureSyncFar
	ldw	(0x38d4), (0x38d2:16)
	jr	Tempo_StartMeasureSetDirty
Tempo_StartMeasureSyncFar:
	ld	wa, (0x38d2:16)
	inc	7, wa
	cp	wa, (0x38d4:16)
	jr	nc, Tempo_StartMeasureSetDirty
	ld	wa, (0x38d2:16)
	inc	7, wa
	ld	(14548:16), wa
Tempo_StartMeasureSetDirty:
	; setda 4, 0xe3e0 (v7 patched)
	set	4, (0xe2f6:16)
Tempo_StartMeasureReturn:
	inc 2, xsp
	ret

Tempo_AdjustEndMeasure:
	dec 2,XSP
	ld (XSP),A
	ldw WA, 0x0081
	ld bc, 1:i3
	calr Tempo_DisplayParamCommon
	cp (XSP),0x00
	jr nz, Tempo_EndMeasureDec
	cpw	(0x38d4:16), 0x3e7
	jr nc, Tempo_EndMeasureReturn
	incw	1, (0x38d4:16)
	jr t, Tempo_EndMeasureSyncStart
Tempo_EndMeasureDec:
	cpw	(0x38d4:16), 1
	jr	ule, Tempo_EndMeasureReturn
	decw	1, (0x38d4:16)
Tempo_EndMeasureSyncStart:
	ld	wa, (14546:16)
	cp	wa, (0x38d4:16)
	jr	ule, Tempo_EndMeasureSyncFar
	ldw	(0x38d2), (0x38d4:16)
	jr	Tempo_EndMeasureSetDirty
Tempo_EndMeasureSyncFar:
	ld	wa, (0x38d2:16)
	inc	7, wa
	cp	wa, (0x38d4:16)
	jr	nc, Tempo_EndMeasureSetDirty
	ld	wa, (0x38d4:16)
	dec	7, wa
	ld	(14546:16), wa
Tempo_EndMeasureSetDirty:
	; setda 4, 0xe3e0 (v7 patched)
	set	4, (0xe2f6:16)
Tempo_EndMeasureReturn:
	inc 2, xsp
	ret

; SeqToComposer_StepTranspose: TRANSPOSE parameter (0x82) of the sequencer-to-composer page: steps RAM 0x398E
;   up (A = 0, at most 49) or down (at least 1) and sets bit 4 of 0xE3E0. 0x398E is 25 for no transpose
;   (-24..+24 semitones). Basis: callers + readers -- PsS2cTrans paints PtrTbl_TransposeStrs[(0x398E)], the
;   0x90 note path adds (0x398E) - 25 to the key, the page's init writes 25.
SeqToComposer_StepTranspose:
	dec 2,XSP
	ld (XSP),A
	ldw WA, 0x0082
	ld bc, 2:i3
	calr Tempo_DisplayParamCommon
	cp (XSP),0x00
	jr nz, SeqToComposer_StepTranspose_Dec
	cp	(0x38d6:16), 49
	jr nc, SeqToComposer_StepTranspose_Return
	inc	1, (0x38d6:16)
	set	4, (0xe2f6:16)
	jr	t, SeqToComposer_StepTranspose_Return
SeqToComposer_StepTranspose_Dec:
	cp	(0x38d6:16), 1
	jr	ule, SeqToComposer_StepTranspose_Return
	dec	1, (0x38d6:16)
SeqToComposer_StepTranspose_SetDirty:
	; setda 4, 0xe3e0 (v7 patched)
	set	4, (0xe2f6:16)
SeqToComposer_StepTranspose_Return:
	inc 2, xsp
	ret

Tempo_AdjustEffect:
	dec	2, xsp
	ld	(xsp), a
	ldw	wa, 134
	ld	bc, 6:i3
	calr	Tempo_DisplayParamCommon
	ld	a, (0x38d8:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (Tempo_AdjustEffect_Table:24)
	ld	xbc, (xbc+wa)
	ld	a, (xbc)
	cp	(xsp), 0
	jr	nz, Tempo_EffectDec
	cp	a, 16
	jr	nc, Tempo_EffectReturn
	inc	1, a
	ld	(xbc), a
	set	4, (0xe2f6:16)
	jr	Tempo_EffectReturn
Tempo_EffectDec:
	cp a, 0:i3
	jr z, Tempo_EffectReturn
	dec 1, a

Tempo_EffectStore:
	ld (xbc), a

	; setda 4, 0xe3e0 (v7 patched)
	set	4, (0xe2f6:16)
Tempo_EffectReturn:
	inc 2, xsp
	ret

; SeqToComposer_IncMemoryNo: Only for A = 0: records the change for the display (Tempo_DisplayParamCommon, A
;   = 9, C = 8) and steps the destination composer memory number 0x398F up, at most to 29, setting bit 4 of
;   0xE3E0. Basis: callers + readers -- S2cMemNoBox paints (0x398F), SeqRec_ValidateDone and the voice-slot
;   init read the composer record at 0x94860 + 96 * (0x398F).
SeqToComposer_IncMemoryNo:
	cp a, 0:i3
	ret NZ
	ldw WA, 0x0009
	ldw BC, 0x0008
	calr Tempo_DisplayParamCommon
	cp	(0x38d7:16), 29
	ret NC
	inc	1, (0x38d7:16)
	set	4, (0xe2f6:16)
	ret
; SeqToComposer_DecMemoryNo: Only for A = 0: as SeqToComposer_IncMemoryNo, stepping 0x398F down to 0.
SeqToComposer_DecMemoryNo:
	cp a, 0:i3
	ret NZ
	ldw WA, 0x0009
	ldw BC, 0x0008
	calr Tempo_DisplayParamCommon
	cp	(0x38d7:16), 0
	ret Z
	dec	1, (0x38d7:16)
	set	4, (0xe2f6:16)
	ret
Tempo_TimeSigCodeBlock:
	; framing ported from v10's source for the same label (same span length, statement for statement); 28 of 41 slots byte-identical
	cp	a, 0:i3
	ret	nz
	ldw	wa, 10
	ldw	bc, 11
	calr	Tempo_DisplayParamCommon
	cp	(0x38d8:16), 0
	ret	z
	; v10 does not spell this byte either
	dec	1, (0x38d8:16)
	set	4, (0xe2f6:16)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	ret
Tempo_EditParam84:
	dec	2, xsp
	ld	(xsp), a
	ldw	wa, 132
	ld	bc, 4:i3
	calr	Tempo_DisplayParamCommon
	; v10 does not spell this byte either
	cp	(xsp), 0
	jr	nz, SeqToComposer_DecMemoryNo_Skip
	cp	(0x38d8:16), 4
	jr	nc, SeqToComposer_DecMemoryNo_Epilogue
	inc	1, (0x38d8:16)
	set	4, (0xe2f6:16)
	jr	SeqToComposer_DecMemoryNo_Epilogue
SeqToComposer_DecMemoryNo_Skip:
	cp	(0x38d8:16), 0
	jr	z, SeqToComposer_DecMemoryNo_Epilogue
	dec	1, (0x38d8:16)
Tempo_EditParam84_Join:
	; v10 does not spell this byte either
	set	4, (0xe2f6:16)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
SeqToComposer_DecMemoryNo_Epilogue:
	inc	2, xsp
	ret
Tempo_EditBPM:
	cp a, 0:i3
	ret NZ
	set	0, (0x8cc8:16)
	calr Tempo_DisplayParamReturn
	ld	(0x38d0:16), l
	ld	a, (0x38d0:16)
	cp	a, 1:i3
	jr z, Tempo_EditBPMDec
	cp	a, 0:i3
	jr nz, Tempo_EditBPMClamp
	ldw WA, 0x0023
	calr Tempo_DisplayParamSkipClear
	jr t, Tempo_EditBPMClamp
Tempo_EditBPMDec:
	ldw	wa, 15
	calr	Tempo_DisplayParamSkipClear
	ldw	wa, 8
	call	MIDI_SendSysExCmd
Tempo_EditBPMClamp:
	; setda 7, 0x34cd (v7 patched)
	set	7, (0x3415:16)
	; setda 7, 0x34cd (v7 patched)
	set	7, (0x3415:16)
	ret
Tempo_EditBPMApply:
	cp	a, 0:i3
	ret	nz
	ldw	wa, TT_CMMENU
	call	UI_ChangeTitleByIndex
	ret
Tempo_EditParam92:
	dec	2, xsp
	ld	(xsp), a
	ldw	wa, 146
	ldw	bc, 18
	calr	Tempo_DisplayParamCommon
	cp	(xsp), 0
	jr	nz, Tempo_EditParam92_Skip2
	cpw	(0x38d2:16), 0x3e7
	jr	nc, Tempo_EditBPMClamp_Code_Epilogue
	cpw	(0x38d2:16), 0x3dd
	jr	c, Tempo_EditBPMClamp_Code_Skip
	ldw	(14546:16), 999
	jr	Tempo_EditBPMClamp_Code_Join
Tempo_EditBPMClamp_Code_Skip:
	addw	(0x38d2:16), 10
	jr	Tempo_EditBPMClamp_Code_Join
Tempo_EditParam92_Skip2:
	cpw	(0x38d2:16), 1
	jr	ule, Tempo_EditBPMClamp_Code_Epilogue
	cpw	(0x38d2:16), 10
	jr	ugt, Tempo_EditBPMClamp_Code_Skip3
	ldw	(14546:16), 1
	jr	Tempo_EditBPMClamp_Code_Join
Tempo_EditBPMClamp_Code_Skip3:
	subw	(0x38d2:16), 10
Tempo_EditBPMClamp_Code_Join:
	ld	wa, (14546:16)
	cp	wa, (0x38d4:16)
	jr	ule, Tempo_EditBPMClamp_Code_Skip4
	ldw	(0x38d4), (0x38d2:16)
	jr	Tempo_EditParam92_Join2
Tempo_EditBPMClamp_Code_Skip4:
	ld	wa, (0x38d2:16)
	inc	7, wa
	cp	wa, (0x38d4:16)
	jr	nc, Tempo_EditParam92_Join2
	ld	wa, (0x38d2:16)
	inc	7, wa
	ld	(14548:16), wa
Tempo_EditParam92_Join2:
	set	4, (0xe2f6:16)
Tempo_EditBPMClamp_Code_Epilogue:
	inc	2, xsp
	ret
Tempo_EditParam93:
	dec	2, xsp
	ld	(xsp), a
	ldw	wa, 147
	ldw	bc, 19
	calr	Tempo_DisplayParamCommon
	cp	(xsp), 0
	jr	nz, Tempo_EditParam93_Skip6
	cpw	(0x38d4:16), 0x3e7
	jr	nc, Tempo_EditBPMClamp_Code_Epilogue2
	cpw	(0x38d4:16), 0x3dd
	jr	c, Tempo_EditBPMClamp_Code_Skip5
	ldw	(14548:16), 999
	jr	Tempo_EditBPMClamp_Code_Join2
Tempo_EditBPMClamp_Code_Skip5:
	addw	(0x38d4:16), 10
	jr	Tempo_EditBPMClamp_Code_Join2
Tempo_EditParam93_Skip6:
	cpw	(0x38d4:16), 1
	jr	ule, Tempo_EditBPMClamp_Code_Epilogue2
	cpw	(0x38d4:16), 10
	jr	ugt, Tempo_EditBPMClamp_Code_Skip7
	ldw	(14548:16), 1
	jr	Tempo_EditBPMClamp_Code_Join2
Tempo_EditBPMClamp_Code_Skip7:
	subw	(0x38d4:16), 10
Tempo_EditBPMClamp_Code_Join2:
	ld	wa, (14546:16)
	cp	wa, (0x38d4:16)
	jr	ule, Tempo_EditBPMClamp_Code_Skip8
	ldw	(0x38d2), (0x38d4:16)
	jr	Tempo_EditParam93_Join
Tempo_EditBPMClamp_Code_Skip8:
	ld	wa, (0x38d2:16)
	inc	7, wa
	cp	wa, (0x38d4:16)
	jr	nc, Tempo_EditParam93_Join
	ld	wa, (0x38d4:16)
	dec	7, wa
	ld	(14546:16), wa
Tempo_EditParam93_Join:
	set	4, (0xe2f6:16)
Tempo_EditBPMClamp_Code_Epilogue2:
	inc	2, xsp
	ret
SeqToComposer_StepTranspose_WideArg:
	extz	wa
	jrl	SeqToComposer_StepTranspose
Tempo_AdjustEffect_WideArg:
	extz	wa
	jrl	Tempo_AdjustEffect
Tempo_DisplayParamCommon:
	or	(0xe2f8:16), 0x09
	ld	(0xe2fa:16), a
	ld	(0xe2fc:16), c
	ret
Tempo_DisplayParamSkipClear:
	ld	(GLOBAL_ERROR_CODE:16), a
	ldw	wa, TT_MESAGE
	jp	UI_InterruptTitleByIndex
Tempo_DisplayParamFormat:
	ld	(0xe2f4:16), 0x80
	ld	(0xe2f2:16), a
	ret
TimeSig_ProcNop:
	ret
Tempo_DisplayParamReturn:
	push QIZ
	lds_erpb 0xfb, 0
	calr MIDIChan_ScanForFree
	calr VoiceSlot_UpdateState
	calr Tempo_DisplayBPMReturn
	ld wa, 0:i3
	calr SeqRec_ValidateDone
	cp	(0x38d9:16), 0
	jr	z, Tempo_DisplayEffectLookup
	ld	a, (0x38d9:16)
	extz WA
	calr Part_IsPercussionType
	cp l, 0:i3
	jr	nz, Tempo_DisplayEffectLookup
; port: v7's label Tempo_DisplayStartMeasure is not in v6 -- no v6 bytes correspond to what it named
; port: v7's label .Lc_f661c5 is not in v6 -- no v6 bytes correspond to what it named
	ld	a, (0x38d9:16)
	ld	c, a
; port: v7's label Tempo_DisplayEndMeasure is not in v6 -- no v6 bytes correspond to what it named
; port: v7's label .Lc_f66202 is not in v6 -- no v6 bytes correspond to what it named
; port: v7's label Tempo_DisplayQuantize is not in v6 -- no v6 bytes correspond to what it named
; port: v7's label .Lc_f6623e is not in v6 -- no v6 bytes correspond to what it named
; port: v7's label Tempo_DisplayTimeSigNum is not in v6 -- no v6 bytes correspond to what it named
; port: v7's label .Lc_f6627a is not in v6 -- no v6 bytes correspond to what it named
	extz BC
	ld	wa, (0x38d2:16)
	calr SetWall_StoreAndResolve
	cp (SEQ_ERROR_CODE:16), 0x00
	jr nz, Tempo_DisplayEffectLookup
	ld	wa, 0:i3
	calr Part_StoreVoiceTableIndex
	ld	wa, 0:i3
	calr Tempo_FormatBPM
	ldfr_berp l, 0xfb
	cps_erpb 0xfb, 1
	jr nz, Tempo_DisplayEffectLookup
Tempo_DisplayEffect:
	calr Tempo_DisplayEffectRender

	jrl	Tempo_DisplayEffectLookup_Skip
Tempo_DisplayEffectLookup:
	ld	wa, 1:i3
	calr	SeqRec_ValidateDone
	cp	(0x38da:16), 0
	jr	z, Tempo_DisplayEffectLookup_Skip2
	ld	a, (0x38da:16)
	extz	wa
	calr	Part_IsPercussionType
	cp	l, 0:i3
	jr	nz, Tempo_DisplayEffectLookup_Skip2
	ld	a, (0x38da:16)
	ld	c, a
	extz	bc
	ld	wa, (0x38d2:16)
	calr	SetWall_StoreAndResolve
	cp	(SEQ_ERROR_CODE:16), 0
	jr	nz, Tempo_DisplayEffectLookup_Skip2
	ld	wa, 1:i3
	calr	Part_StoreVoiceTableIndex
	ld	wa, 1:i3
	calr	Tempo_FormatBPM
	ldfr_berp	l, 251
	cpib_erp	251, 1
	jr	nz, Tempo_DisplayEffectLookup_Skip2
	calr	Tempo_DisplayEffectRender
	jrl	Tempo_DisplayEffectLookup_Skip
Tempo_DisplayEffectLookup_Skip2:
	ld	wa, 2:i3
	calr	SeqRec_ValidateDone
	cp	(0x38db:16), 0
	jr	z, Tempo_DisplayEffectLookup_Skip3
	ld	a, (0x38db:16)
	extz	wa
	calr	Part_IsPercussionType
	cp	l, 0:i3
	jr	nz, Tempo_DisplayEffectLookup_Skip3
	ld	a, (0x38db:16)
	ld	c, a
	extz	bc
	ld	wa, (0x38d2:16)
	calr	SetWall_StoreAndResolve
	cp	(SEQ_ERROR_CODE:16), 0
	jr	nz, Tempo_DisplayEffectLookup_Skip3
	ld	wa, 2:i3
	calr	Part_StoreVoiceTableIndex
	ld	wa, 2:i3
	calr	Tempo_FormatBPM
	ldfr_berp	l, 251
	cpib_erp	251, 1
	jr	nz, Tempo_DisplayEffectLookup_Skip3
	calr	Tempo_DisplayEffectRender
	jrl	Tempo_DisplayEffectLookup_Skip
Tempo_DisplayEffectLookup_Skip3:
	ld	wa, 3:i3
	calr	SeqRec_ValidateDone
	cp	(0x38dc:16), 0
	jr	z, Tempo_DisplayEffectLookup_Skip4
	ld	a, (0x38dc:16)
	extz	wa
	calr	Part_IsPercussionType
	cp	l, 0:i3
	jr	nz, Tempo_DisplayEffectLookup_Skip4
	ld	a, (0x38dc:16)
	ld	c, a
	extz	bc
	ld	wa, (0x38d2:16)
	calr	SetWall_StoreAndResolve
	cp	(SEQ_ERROR_CODE:16), 0
	jr	nz, Tempo_DisplayEffectLookup_Skip4
	ld	wa, 3:i3
	calr	Part_StoreVoiceTableIndex
	ld	wa, 3:i3
	calr	Tempo_FormatBPM
	ldfr_berp	l, 251
	cpib_erp	251, 1
	jr	nz, Tempo_DisplayEffectLookup_Skip4
	calr	Tempo_DisplayEffectRender
	jr	Tempo_DisplayEffectLookup_Skip
Tempo_DisplayEffectLookup_Skip4:
	ld	wa, 4:i3
	calr	SeqRec_ValidateDone
	cp	(0x38dd:16), 0
	jr	z, Tempo_DisplayEffectLookup_Skip
	ld	a, (0x38dd:16)
	extz	wa
	calr	Part_IsPercussionType
	cp	l, 0:i3
	jr	nz, Tempo_DisplayEffectLookup_Skip
	ld	a, (0x38dd:16)
	ld	c, a
	extz	bc
	ld	wa, (0x38d2:16)
	calr	SetWall_StoreAndResolve
	cp	(SEQ_ERROR_CODE:16), 0
	jr	nz, Tempo_DisplayEffectLookup_Skip
	ld	wa, 4:i3
	calr	Part_StoreVoiceTableIndex
	ld	wa, 4:i3
	calr	Tempo_FormatBPM
	ldfr_berp	l, 251
	cpib_erp	251, 1
	call	z, (16145968)
Tempo_DisplayEffectLookup_Skip:
	ldto_berp L, 0xfb
	popw_erp 0xfa
	ret

Tempo_DisplayEffectRender:
	ld wa, 0:i3
	calr SeqRec_ValidateDone
	ld wa, 1:i3
	calr SeqRec_ValidateDone
	ld wa, 2:i3
	calr SeqRec_ValidateDone
	ld wa, 3:i3
	calr SeqRec_ValidateDone
	ld wa, 4:i3
	jrl SeqRec_ValidateDone

Tempo_FormatBPM:
	push	qiz
	ld	hl, 0:i3
	cp	hl, 10
	jr	nc, Tempo_FormatBPMDigit_Skip
Tempo_FormatBPMDigit:
	lda	xbc, (0x38e0:16)
	ld	de, hl
	extz	xde
	add	xde, xbc
	ld	(xde), 0
	inc	1, hl
	cp	hl, 10
	jr	c, Tempo_FormatBPMDigit
Tempo_FormatBPMDigit_Skip:
	cp	a, 0:i3
	jr	nz, Tempo_FormatBPMDone
	set	0, (0x38df:16)
	jr	Tempo_FormatBPMOutput
Tempo_FormatBPMDone:
	; resda 0, 0x3997 (v7 patched)
	res	0, (0x38df:16)
Tempo_FormatBPMOutput:
	cp	a, 1:i3
	jr	nz, Tempo_FormatBPMPad
	set	1, (0x38df:16)
	jr	Tempo_DisplayBPMValue
Tempo_FormatBPMPad:
	; resda 1, 0x3997 (v7 patched)
	res	1, (0x38df:16)
Tempo_DisplayBPMValue:
	ld	wa, (14548:16)

	sub	wa, (14546:16)

	inc 1, a

	ldfr_berp	A, 0xfb

	; mul wa, (0x3986:16) (v7 patched)
	mul	wa, (0x38ce:16)
	ldfr_berp	A, 0xfb



Tempo_DisplayBPMFraction:
	cpib_erp	251, 0
	jr	z, Tempo_DisplayBPMWithDec
	calr	Voice_ReadEventBytes
	calr	RhythmParam_TypeCheck
	cp	(0x38e0:16), 129
	jr	nz, Tempo_DisplayBPMNoFrac
	dec1b_erp	251
	jr	Tempo_DisplayBPMDecimal
Tempo_DisplayBPMNoFrac:
	cp	(0x38e0:16), 131
	jr z, Tempo_DisplayBPMWithDec

Tempo_DisplayBPMDecimal:
	calr Voice_ScanTableByType
	cp l, 1:i3
	jr nz, Tempo_DisplayBPMFraction
	jr Tempo_DisplayBPMExit

Tempo_DisplayBPMWithDec:
	cpib_erp	0xfb, 0
	jr z, Tempo_DisplayBPMClean
	ldib_erp	0xfa, 0

Tempo_DisplayBPMFinal:
	ld	(14560:16), 129
	calr	Voice_ScanTableByType
	cp	l, 1:i3
	jr	z, Tempo_DisplayBPMExit
	inc1b_erp	250
	ldto_berp	a, 250
	cpb_erp	a, 251
	jr	nz, Tempo_DisplayBPMFinal
Tempo_DisplayBPMClean:
	ld	(14560:16), 131
	calr	Voice_ScanTableByType
	cp	l, 1:i3
	jr	z, Tempo_DisplayBPMExit
	ld	l, 0:opc
Tempo_DisplayBPMExit:
	popw_erp 0xfa
	ret
Tempo_DisplayBPMReturn:
	lda	xsp, (xsp-20)
	push	qiz
	ld	xiy, Tempo_DisplayBPMReturn_LocalInit
	lda	xix, (xsp+6)
	ldw	bc, 8
	ldirw
	ld	xwa, 0:i3
	ld	a, (0x38d7:16)
	ld	xbc, xwa
	add	xbc, xbc
	add	xbc, xwa
	sll	xbc, 5
	add	xbc, 0x94860
	ld	(xsp+2), xbc
	ld	a, (14542:16)
	inc	3, a
	ld	c, a
	ld	xwa, (xsp+2)
	cp	c, (xwa+12)
	jr	z, Tempo_DisplayMeasureRange
	ld	a, (STYLE_SECTION:16)
	ldfr_berp	a, 251
	ld	(STYLE_SECTION), (0x38d7:16)
	ld	a, (14542:16)
	inc	3, a
	ld	c, a
	ld	xwa, (xsp+2)
	ld	(xwa+12), c
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	AccPatch_RefreshSlotOffset_Wrap
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ldto_berp	a, 251
	ld	(STYLE_SECTION:16), a
Tempo_DisplayMeasureRange:
	ld	wa, (14548:16)

	sub	wa, (14546:16)









	ld	c, a
	ld	xwa, (xsp+2)
	ld	(xwa+13), c
	ld	xwa, (xsp+2)
	res	7, (xwa+15)
	ld	hl, 0:i3
	cp	hl, 16
	jr	nc, Tempo_DisplayMeasureStart_Skip
Tempo_DisplayMeasureStart:
	ld	wa, hl
	extz	xwa
	lda	xbc, (xsp+6)
	add	xbc, xwa
	ld	wa, hl
	extz	xwa
	lda	xwa, (xwa+64)
	ld	xde, xwa
	add	xde, (xsp+2)
	ld	a, (xbc)
	ld	(xde), a
	inc	1, hl
	cp	hl, 16
	jr	c, Tempo_DisplayMeasureStart
Tempo_DisplayMeasureStart_Skip:
	cp	(0x38d9:16), 0
	jr	z, Tempo_DisplayMeasureSep
	ld	wa, 0:i3
	calr	Tempo_DisplayEffectValLookup
Tempo_DisplayMeasureSep:
	cp	(0x38da:16), 0
	jr	z, Tempo_DisplayMeasureEnd
	ld	wa, 1:i3
	calr	Tempo_DisplayEffectValLookup
Tempo_DisplayMeasureEnd:
	cp	(0x38db:16), 0
	jr	z, Tempo_DisplayQuantizeVal
	ld	wa, 2:i3
	calr	Tempo_DisplayEffectValLookup
Tempo_DisplayQuantizeVal:
	cp	(0x38dc:16), 0
	jr	z, Tempo_DisplayTimeSig
	ld	wa, 3:i3
	calr	Tempo_DisplayEffectValLookup
Tempo_DisplayTimeSig:
	cp	(0x38dd:16), 0
	jr	z, Tempo_DisplayEffectVal
	ld	wa, 4:i3
	calr	Tempo_DisplayEffectValLookup
Tempo_DisplayEffectVal:
	pop	qiz
	lda	xsp, (xsp + 20)
	ret

Tempo_DisplayEffectValLookup:
	dec	8, xsp
	push	xiz
	ld	(xsp+10), a
	ld	a, (xsp+10)
	cp	a, 4:i3
	jr	z, Tempo_RefreshDisplay4
	cp	a, 3:i3
	jr	z, Tempo_RefreshDisplay3
	cp	a, 2:i3
	jr	z, Tempo_RefreshDisplay2
	cp	a, 1:i3
	jr	z, Tempo_RefreshDisplay1
	cp	a, 0:i3
	jr	nz, Tempo_RefreshDisplay5
	ld	a, (0x38d9:16)
	ldfr_berp	a, 250
	ldi_erpb	251, 24
	jr	Tempo_RefreshDisplay5
Tempo_RefreshDisplay1:
	ld	a, (0x38da:16)
	ldfr_berp	a, 250
	ldi_erpb	251, 32
	jr	Tempo_RefreshDisplay5
Tempo_RefreshDisplay2:
	ld	a, (0x38db:16)
	ldfr_berp	a, 250
	ldi_erpb	251, 40
	jr	Tempo_RefreshDisplay5
Tempo_RefreshDisplay3:
	ld	a, (0x38dc:16)
	ldfr_berp	a, 250
	ldi_erpb	251, 48
	jr	Tempo_RefreshDisplay5
Tempo_RefreshDisplay4:
	ld	a, (14557:16)

	ldfr_berp	A, 0xfa




	ldi_erpb	251, 56
Tempo_RefreshDisplay5:
	cpib_erp	250, 0
	jrl	z, SeqRec_UpdateFlags
	ld	xwa, 0:i3
	ld	a, (0x38d7:16)
	ld	xbc, xwa
	add	xbc, xbc
	add	xbc, xwa
	sll	xbc, 5
	add	xbc, 0x94860
	ld	(xsp+4), xbc
	ldto_berp	a, 250
	dec	1, a
	extz	wa
	lda	xbc, (SEQ_TRACK_ASSIGN:16)
	extz	xwa
	add	xwa, xbc
	ld	a, (xwa)
	extz	wa
	sla	wa, 2
	lda	xbc, (Tempo_RefreshDisplay5_Table:24)
	ld	xde, (xbc+wa)
	cp	(xsp+10), 0
	jr	nz, SeqRec_InitState
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	xwa, (xsp+4)
	lda_rr	xhl, xwa, bc
	ld	a, (xde)
	ld	c, a
	extz	bc
	ld	a, (xde+1)
	ld	e, a
	extz	de
	ld	xwa, xhl
	calr	SeqRec_CheckOverflow
	jr	SeqRec_InitChannels
SeqRec_InitState:
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld xwa, (xsp + 4)
	lda_rr	xhl, xwa, bc
	ld	a, (xde)
	ld	c, a
	extz bc
	ld	a, (xde+1)
	ld	e, a
	extz	de
	ld	xwa, xhl
	calr SeqRec_OverflowCleanup

SeqRec_InitChannels:


	ldto_berp	a, 250
	extz	wa
	ld	bc, wa
	ld wa, 1:i3

	; calr SetWall_StoreAndResolve (v7 displacement)
	calr	SetWall_StoreAndResolve
	; ldw_d16 xbc, (0x398a) (v7 patched)
	ld	wa, (0x38d2:16)
	ld	bc, wa
	dec 1, bc

	ld	a, (14542:16)



	ldfr_berp	a, 248
	extz	iz
	ld	wa, iz
	mul xwa, bc





	ld	iz, wa
	ldw	(xsp+8), 0
SeqRec_StartRecord:

	cp	(xsp+8), iz
	jrl	nc, SeqRec_UpdateFlags
SeqRec_StartRecordImpl:
	calr	Voice_ReadEventBytes
	ld	a, (0x38e0:16)
	and	a, 240
	cp	a, 192
	jr	z, SeqRec_StopRecordImpl
	cp	a, 128
	jr	nz, SeqRec_StartRecord
	cp	(0x38e0:16), 129
	jr	nz, SeqRec_StopRecord
	incw	1, (xsp+8)
	jr	SeqRec_StartRecord
SeqRec_StopRecord:
	cp	(0x38e0:16), 130
	jrl	z, SeqRec_UpdateFlags
	cp	(0x38e0:16), 132
	jr nz, SeqRec_StartRecord
	jr SeqRec_UpdateFlags

SeqRec_StopRecordImpl:
	cp (xsp + 10), 0x0
	jr nz, SeqRec_UpdateState
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	xwa, (xsp+4)
	lda_rr	xhl, xwa, bc
	ld	c, (0x38e4:16)
	res	7, c
	ld	a, (0x38e0:16)
	and	a, 0x1
	sll	a, 7
	or	a, c
	ld	c, a
	extz	bc
	ld	a, (0x38e5:16)
	res	7, a
	ld	e, a
	extz	de
	ld	xwa, xhl
	calr SeqRec_CheckOverflow
	jr SeqRec_StartRecord

SeqRec_UpdateState:
	ldto_berp	a, 251
	ld	c, a
	extz	bc
	ld	xwa, (xsp+4)
	lda_rr	xhl, xwa, bc
	ld	c, (0x38e4:16)
	res	7, c
	ld	a, (0x38e0:16)
	and	a, 0x1
	sll	a, 7
	or	a, c
	ld	c, a
	extz	bc
	ld	a, (0x38e5:16)
	res	7, a
	ld	e, a
	extz	de
	ld	xwa, xhl
	calr SeqRec_OverflowCleanup

	jrl	SeqRec_StartRecord
SeqRec_UpdateFlags:
	pop xiz
	inc 8, xsp
	ret

SeqRec_CheckOverflow:
	cp c, 0xf0
	jr c, SeqRec_HandleOverflow
	and c, 0xf
	ld (xwa), c
	ld	(xwa+1), e
	ret

SeqRec_HandleOverflow:
	ld (xwa), 0x0
	ld	(xwa+1), 0
	ret

SeqRec_OverflowCleanup:
	cp c, 0xf0
	jr nc, SeqRec_CommitData
	cp c, 0x80
	jr c, SeqRec_CommitData
	cp e, 7:i3
	jr nz, SeqRec_CommitData

	ld	(xwa), 88
	ld	(xwa+1), 0
	ret
SeqRec_CommitData:
	cp c, 0xf0
	jr c, SeqRec_Validate

	; port: v7's label SeqRec_CommitFinalize is not in v6 -- no v6 bytes correspond to what it named
	ld	(xwa), 0
	ld	(xwa+1), 0
	ret

SeqRec_Validate:
	ld (xwa), c
	res 7, e
	ld	(xwa+1), e
	ret

SeqRec_ValidateDone:
	push QIZ
	ld	c, (STYLE_SECTION:16)
	st_erpb_rr	c, 0xfb
	ld	c, (CMP_RECORD_PART:16)
	st_erpb_rr	c, 0xfa
	cp a, 4:i3
	jr z, Part_SetVoiceType4
	cp a, 3:i3
	jr z, Part_SetVoiceType2
	cp a, 2:i3
	jr z, Part_SetVoiceType1
	cp a, 1:i3
	jr z, SeqRec_Cleanup
	cp a, 0:i3
	jr nz, Part_LoadAndIndexVoiceTable
	ld	(CMP_RECORD_PART:16), 0x10
	jr t, Part_LoadAndIndexVoiceTable
SeqRec_Cleanup:
	ld	(CMP_RECORD_PART:16), 8
	jr	Part_LoadAndIndexVoiceTable
Part_SetVoiceType1:
	ld	(CMP_RECORD_PART:16), 1
	jr	Part_LoadAndIndexVoiceTable
Part_SetVoiceType2:
	ld	(CMP_RECORD_PART:16), 2
	jr	Part_LoadAndIndexVoiceTable
Part_SetVoiceType4:
	ld	(CMP_RECORD_PART:16), 4
Part_LoadAndIndexVoiceTable:
	ld	(STYLE_SECTION), (0x38d7:16)
	ld	xwa, 0:i3
	ld	a, (14551:16)
	ld	xbc, xwa
	add	xbc, xbc
	add	xbc, xwa
	sll	xbc, 5
	add	xbc, 608352
	ld	a, (xbc+12)
	dec	3, a
	ld	(STYLE_SECTION_BEATS:16), a
	ld	a, (xbc+13)
	ld	(STYLE_SECTION_LAST_MEASURE:16), a
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	VoiceSlot_InitFromTable
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ldto_berp	a, 251
	ld	(STYLE_SECTION:16), a
	ldto_berp	a, 250
	ld	(CMP_RECORD_PART:16), a
	pop qiz
	ret
Part_StoreVoiceTableIndex:
	ld	c, a
	extz	bc
	ld	a, (14551:16)
	extz	wa
	mul	wa, 5
	add	wa, bc
	ld	(14536:16), wa
	ldw	(14540:16), 6
	ret
SetWall_StoreAndResolve:
	ld	(0x2863:16), wa
	ld	a, c
	extz	wa
	jp Voice_ResolveSlotAddr

MIDIChan_ScanForFree:
	ld xbc, 0xf1a0
	ld a, 0x1:opc

	cp	a, 17
	jr	ugt, MIDIChan_Found
MIDIChan_ScanLoop:
	cp (xbc), 0x10
	jr z, MIDIChan_Found
	inc 1, xbc
	inc 1, a
	cp a, 0x11
	jr ule, MIDIChan_ScanLoop

MIDIChan_Found:
	cp	a, 16
	jr	ule, MIDIChan_StoreResult
	ld	(14558:16), 0
	ret
MIDIChan_StoreResult:
	ld	(14558:16), a
	ret
VoiceSlot_UpdateState:
	ld	(0x2871), (0x38de:16)
	cp	(0x38de:16), 0x00
	jr nz, VoiceSlot_SetBit2
	res	2, (SEQ_EDIT_FLAGS:16)
	jr t, VoiceSlot_ValidateAndResolve
VoiceSlot_SetBit2:
	set	2, (SEQ_EDIT_FLAGS:16)

VoiceSlot_ValidateAndResolve:
	call SeqVoice_ValidateAndProcessState
	ldmm16	0x2863, 0x38d2
	cp	(0x38db:16), 0
	jr	z, VoiceSlot_ValidateAndResolve_Skip
	ld	a, (0x38db:16)
	extz	wa
	call	Voice_ResolveSlotAddr
	jr	VoiceSlot_StoreAndReturn
VoiceSlot_ValidateAndResolve_Skip:
	cp	(0x38dc:16), 0
	jr z, VoiceSlot_CheckSlot2
	ld	a, (0x38dc:16)
	extz WA
	call	Voice_ResolveSlotAddr
	jr	t, VoiceSlot_StoreAndReturn
VoiceSlot_CheckSlot2:
	cp	(0x38dd:16), 0
	jr	z, VoiceSlot_CheckSlot2_Skip
	ld	a, (14557:16)
	extz	wa
	call	Voice_ResolveSlotAddr
	jr	VoiceSlot_StoreAndReturn
VoiceSlot_CheckSlot2_Skip:
	cp	(0x38da:16), 0
	jr	z, VoiceSlot_CheckSlot3
	ld	a, (0x38da:16)
	extz	wa
	call	Voice_ResolveSlotAddr
	jr	VoiceSlot_StoreAndReturn
VoiceSlot_CheckSlot3:
	cp	(0x38d9:16), 0
	jr	z, VoiceSlot_StoreAndReturn
	ld	a, (14553:16)
; port: v7's label VoiceSlot_CheckSlot4 is not in v6 -- no v6 bytes correspond to what it named
; port: v7's label VoiceSlot_CheckSlot5 is not in v6 -- no v6 bytes correspond to what it named
	extz	wa
VoiceSlot_ResolveAddr:
	call Voice_ResolveSlotAddr

VoiceSlot_StoreAndReturn:
	; ldmm8 0x3986, 0x288e (v7 displacement)
	ldmm8	14542, 10354
	ret



Part_IsPercussionType:
	ld	xbc, 0xf1a0
	dec 1, a
	extz wa
	ld	a, (xbc+wa)
	cp a, 0xd
	jr z, EventCode_CheckExit
	cp a, 0xe
	jr z, EventCode_CheckExit
	cp a, 0xf
	jr z, EventCode_CheckExit
	cp a, 0x10
	jr nz, PartType_NotPercussion

EventCode_CheckExit:
	ld l, 0x1:opc
	jr PartType_Return

PartType_NotPercussion:
	ld l, 0x0:opc

PartType_Return:
	ret

Voice_ReadEventBytes:
	push xiz
	calr VoiceTable_ResolveReadAddr
	ld	a, (xhl)
	and	a, 0xf0
	cp	a, 128
	jr	z, VoiceEvt_Size3_Skip
	cp	a, 208
	jr z, VoiceEvt_CheckD2
	cp	a, 192
	jr z, VoiceEvt_Size6
	cp	a, 176
	jr z, VoiceEvt_Size6
	cp	a, 144
	jr nz, VoiceEvt_Size1

VoiceEvt_Size6:
	ldiw_erp 0xfa, 6
	jr VoiceBuffer_CopyLoop

VoiceEvt_CheckD2:
	cp	(xhl), 210
	jr nz, VoiceEvt_Size3
	ldiw_erp 0xfa, 4
	jr VoiceBuffer_CopyLoop

VoiceEvt_Size3:
	ldiw_erp 0xfa, 3
	jr VoiceBuffer_CopyLoop

VoiceEvt_Size3_Skip:
	ld	a, (xhl)
	and	a, 0xf
	extz	wa
	cp	wa, 0:i3
	jr	mi, VoiceEvt_Size3_Skip2
	cp	wa, 6:i3
	jr	gt, VoiceEvt_Size3_Skip2
	add	wa, wa
	lda	xix, (VoiceSlot_Dispatch_CaseTable:24)
	ld	wa, (xix+wa)
	lda	xix, (VoiceSlot_Dispatch_Case0:24)
	jp_rr	8, xix, wa
VoiceSlot_Dispatch_Case0:
	ld	qiz, 4
	jr	VoiceEvt_Size1
VoiceSlot_Dispatch_Case1:
	ld	qiz, 1
	jr	VoiceEvt_Size1
VoiceSlot_Dispatch_Case5:
	ld	qiz, 2
	jr	VoiceEvt_Size1
VoiceEvt_Size3_Skip2:
	ld	qiz, 1
VoiceEvt_Size1:
	ldiw_erp 0xfa, 1

VoiceBuffer_CopyLoop:
	ld iz, 0:i3

	cp	iz, qiz
	jr	nc, VoiceBuf_CopyDone
VoiceBuf_CopyLoop:
	lda	xwa, (0x38e0:16)
	ld	bc, iz
	extz	xbc
	add	xbc, xwa
	ld	a, (xhl)
	ld	(xbc), a
	ld	xwa, xhl
	calr	VoiceTable_AdvanceReadPos
	inc	1, iz
	cp	iz, qiz
	jr	c, VoiceBuf_CopyLoop
VoiceBuf_CopyDone:
	pop xiz
	ret

Voice_ScanTableByType:
	push	xiz
	calr	Voice_ResolveTableAddr
	ld	a, (0x38e0:16)
	cp	a, 131
	jr	z, VoiceScan_Size1
	cp	a, 129
	jr	z, VoiceScan_Size1
	cp	a, 213
	jr	z, Voice_SetScanType3
	cp	a, 212
	jr	z, Voice_SetScanType3
	cp	a, 211
	jr	z, Voice_SetScanType3
	cp	a, 210
	jr	z, Voice_SetScanType3
	cp	a, 209
	jr	z, Voice_SetScanType3
	cp	a, 145
	jr	z, VoiceScan_Size8
	cp	a, 144
	jr	nz, VoiceScan_Size0
	ld	qiz, 6
	jr	Voice_ScanTableEntries
VoiceScan_Size8:
	ldi_erpw 0xfa, 0x08, 0x00
	jr Voice_ScanTableEntries

Voice_SetScanType3:
	ldiw_erp 0xfa, 3
	jr Voice_ScanTableEntries

VoiceScan_Size1:
	ldiw_erp 0xfa, 1
	jr Voice_ScanTableEntries

VoiceScan_Size0:
	ldiw_erp 0xfa, 0

Voice_ScanTableEntries:
	ld iz, 0:i3

	cp	iz, qiz
	jr	nc, VoiceScan_NotFound
VoiceScan_WriteLoop:
	lda	xwa, (0x38e0:16)
	ld	bc, iz
	extz	xbc
	add	xbc, xwa
	ld	a, (xbc)
	ld	(xhl), a
	ld	xwa, xhl
	calr	VoiceTable_AdvanceWritePos
	cp	xhl, 0xffffffff
	jr	nz, VoiceScan_NextEntry
	ld	l, 1:opc
	jr	VoiceScan_Return
VoiceScan_NextEntry:
	inc 1, iz
	cpw_erp IZ, 0xfa
	jr c, VoiceScan_WriteLoop

VoiceScan_NotFound:
	ld l, 0x0:opc

VoiceScan_Return:
	pop xiz
	ret

VoiceTable_AdvanceReadPos:
	incw	1, (0x38ca:16)
	cpw	(0x38ca:16), 0x100
	jr	c, VoiceTable_AdvRead_Done
	ld	wa, (14534:16)
	dec	1, wa
	extz	xwa
	sll	xwa, 8
	add	xwa, 0xb0000
	ld	c, (xwa+4)
	extz	bc
	sll	bc, 8
	ld	a, (xwa+3)
	extz	wa
	add	wa, bc
	ld	(14534:16), wa
	ldw	(14538:16), 5
VoiceTable_AdvRead_Done:

	calr	VoiceTable_ResolveReadAddr
	ld	xwa, xhl
	ret
VoiceTable_ResolveReadAddr:
	ld	bc, (14538:16)
	extz	xbc
	ld	wa, (14534:16)
	dec	1, wa
	extz	xwa
	sll	xwa, 8
	add	xwa, 720896
	add	xwa, xbc
	ld	xhl, xwa
	ret
VoiceTable_AdvanceWritePos:
	incw	1, (0x38cc:16)
	cpw	(0x38cc:16), 255
	jr	c, RhythmParam_Setup
	cpw	(STYLE_FREE_BLOCKS:16), 0
	jr	nz, VoiceTable_AdvWrite_AllocSlot
	ld	xwa, 0xffffffff
	jr	RhythmParam_Entry
VoiceTable_AdvWrite_AllocSlot:
	decw	1, (STYLE_FREE_BLOCKS:16)
	ldw	bc, 150
	ld	xde, 651776
	cp	bc, 0x153
	jr	ugt, VoiceTable_AdvWrite_LinkEntry
VoiceTable_AdvWrite_ScanLoop:
	bitm 7, (xde)
	jr z, VoiceTable_AdvWrite_LinkEntry
	inc 1, bc
	lda xde, (xde+256)
	cp bc, 0x153
	jr ule, VoiceTable_AdvWrite_ScanLoop

VoiceTable_AdvWrite_LinkEntry:
	ld	wa, (14536:16)

	extz xwa

	sll xwa, 8

	add	xwa, RHYTHM_PATTERN_BUF_B
	ld xhl, xwa


	ld a, c

	ld (xhl + 3), a

	ld wa, bc

	srl wa, 8

	ld (xhl + 4), a

	ld	wa, (14536:16)

	ld (xde + 1), a

	ld	wa, (14536:16)

	srl wa, 8

	ld (xde + 2), a

	ld	(14536:16), bc

	ldw	(14540:16), 6

	setm 7, (xde)



; Rhythm parameter dispatch setup

RhythmParam_Setup:
	calr Voice_ResolveTableAddr

; Rhythm parameter entry
	ld	xwa, xhl
RhythmParam_Entry:
	ld	xhl, xwa
	ret

Voice_ResolveTableAddr:
	ld	bc, (14540:16)
	extz	xbc
	ld	wa, (14536:16)
	extz	xwa
	sll	xwa, 8
	add	xwa, RHYTHM_PATTERN_BUF_B
	add	xwa, xbc
	ld	xhl, xwa
	ret
RhythmParam_TypeCheck:
	bit	0, (0x38df:16)
	jr	z, RhythmParam_Process
	ld	a, (0x38e0:16)
	and	a, 240
	cp	a, 128
	jr	z, RhythmParam_Dispatch
	cp	a, 144
	jr	nz, RhythmParam_DispatchTableData_Skip2
	ld	(0x38e0:16), 144
	ret
; Rhythm parameter dispatch (voice type classification)
RhythmParam_Dispatch:
	ld	a, (0x38e0:16)
	extz	wa
	sub	wa, 128
	cp	wa, 0:i3
	jr	lt, RhythmParam_DispatchTableData_Skip
	cp	wa, 6:i3
	jr	gt, RhythmParam_DispatchTableData_Skip
	add	wa, wa
	lda xix, (RhythmParam_Dispatch_CaseTable:24)
	ld	wa, (xix+wa)
	lda xix, (RhythmParam_CheckExit:24)

	jp_rr	8, xix, wa
RhythmParam_CheckExit:
	ld	(0x38e0:16), 0
	ret

RhythmParam_DispatchTableData:
	ld	(0x38e0:16), 131
	ret

; Rhythm parameter processing
RhythmParam_DispatchTableData_Skip:
	ld	(0x38e0:16), 0
	ret
RhythmParam_DispatchTableData_Skip2:
	ld	(0x38e0:16), 0
	ret
RhythmParam_Process:
	ld	a, (0x38e0:16)
	and	a, 0xf0
	cp	a, 128
	jrl	z, VoiceSlot_Dispatch
	cp	a, 208
	jrl	z, VoiceParam_D0Handler
	cp	a, 176
	jrl	z, VoiceParam_B0_Handler
	cp	a, 144
	jrl	nz, RhythmParam_Dispatch_KeepBeatAdvance_Skip2
	cp	(0x38d6:16), 25
	jr	ule, VoiceNote_SubtractOffset
	ld	a, (0x38d6:16)
	sub	a, 25
	add	(0x38e2:16), a
	cp	(0x38e2:16), 127
	jr	ule, VoiceNote_SubtractOffset_Skip
	ld	(0x38e2:16), 127
	jr	VoiceNote_SubtractOffset_Skip
VoiceNote_SubtractOffset:
	cp	(0x38d6:16), 25
	jr	nc, VoiceNote_SubtractOffset_Skip
	ld	a, 25:opc
	sub	a, (0x38d6:16)
	sub	(0x38e2:16), a
	ld	a, (0x38e2:16)
	cp	a, 0:i3
	jr	ge, VoiceNote_SubtractOffset_Skip
	ld	(0x38e2:16), 0
VoiceNote_SubtractOffset_Skip:
	bit	1, (0x38df:16)
	jr	z, VoiceNote_SubtractOffset_Skip2
	cp	(0x38e2:16), 12
	jr	c, VoiceNote_SubtractOffset_Skip2
	sub	(0x38e2:16), 12
VoiceNote_SubtractOffset_Skip2:
	ld	a, (0x38e2:16)
	extz	wa
	div	a, 12
	ld	a, w
	cp	a, 11
	jr	z, VoiceNote_SubtractOffset_Skip3
	cp	a, 7:i3
	jr	z, VoiceNote_SubtractOffset_Skip4
	cp	a, 4:i3
	jr	z, VoiceNote_SubtractOffset_Skip5
	cp	a, 3:i3
	jr	nz, VoiceNote_SubtractOffset_Skip6
VoiceNote_SubtractOffset_Skip5:
	ld	(0x38e0:16), 145
	ld	(0x38e6:16), 0
	ld	(0x38e7:16), 17
	ret
VoiceNote_SubtractOffset_Skip4:
	ld	(0x38e0:16), 145
	ld	(0x38e6:16), 3
	ld	(0x38e7:16), 0
	ret
VoiceNote_SubtractOffset_Skip3:
	ld	(0x38e0:16), 145
	ld	(0x38e6:16), 17
	ld	(0x38e7:16), 17
	ret
VoiceNote_SubtractOffset_Skip6:
	ld	(0x38e0:16), 144
	ret
VoiceParam_B0_Handler:
	ld	a, (0x38e2:16)
	res	7, a
	cp	a, 22
	jr	ule, VoiceParam_B0_Handler_Skip
	ld	a, (0x38e2:16)
	res	7, a
	cp	a, 25
	jr	nz, VoiceParam_B0_Process_Join_Skip2
VoiceParam_B0_Handler_Skip:

	ld	a, (0x38e3:16)
	and	a, 0x1f
	cp	a, 4:i3
	jr	nz, VoiceBound_CalcOctave
Voice_BoundaryCheck:
	bit	3, (0x38e5:16)
	jr	z, VoiceBound_CalcOctave
	ld	(0x38e0:16), 211
	bit	3, (0x38e4:16)
	jr nz, VoiceParam_D0_StoreD5

; port: v7's label VoiceParam_D0_Process is not in v6 -- no v6 bytes correspond to what it named

	ld	(0x38e2:16), 0
	jrl	RhythmParam_Dispatch_KeepBeatAdvance_Skip3
; port: v7's label VoiceParam_D0_Skip is not in v6 -- no v6 bytes correspond to what it named
VoiceParam_D0_StoreD5:
	ld	(0x38e2:16), 127
	ret

; port: v7's label VoiceParam_D0_CheckD4 is not in v6 -- no v6 bytes correspond to what it named

VoiceBound_CalcOctave:
	ld	a, (0x38e3:16)
; port: v7's label VoiceParam_D0_CheckD5 is not in v6 -- no v6 bytes correspond to what it named



; port: v7's label VoiceParam_B0_CheckType is not in v6 -- no v6 bytes correspond to what it named
	and a, 0x1f

; port: v7's label VoiceParam_B0_Process is not in v6 -- no v6 bytes correspond to what it named

VoiceParam_B0_Process_Join:
	cp a, 0x8
	jr	nz, VoiceParam_B0_Process_Join_Skip
	ld	a, (0x38e5:16)
	res 7, a
	cp a, 0:i3
	jr	z, VoiceParam_B0_Process_Join_Skip
	ld	(0x38e0:16), 212
	ld	a, (0x38e4:16)
	res 7, a
	ld	(0x38e2:16), a
	ret

; Voice parameter D0 type (fine tuning)
VoiceParam_B0_Process_Join_Skip:
	ld	(0x38e0:16), 0
	ret
VoiceParam_B0_Process_Join_Skip2:
	ld	(0x38e0:16), 0
	ret
VoiceParam_D0Handler:
	cp	(0x38e0:16), 210
	jr nz, VoiceParam_D3Special
	cp	(0x38e3:16), 64
	jr c, VoiceParam_DownscaleBelow40
	ld	a, (0x38e3:16)
	sub	a, 64
	extz	wa
	div	a, 6
	add	a, 64
	ld	(0x38e2:16), a
	ret

; Voice param downscale below 0x40
VoiceParam_DownscaleBelow40:
	ld a, 0x40:opc
	sub	a, (0x38e3:16)
	extz wa
	div a, 0x6
	ld	c, a
	ld a, 0x40:opc
	sub	a, c
	ld	(0x38e2:16), a
	ret

; Voice parameter D3 special case (transition to D5)
VoiceParam_D3Special:
	cp	(0x38e0:16), 211
	ret nz
	ld	(0x38e0:16), 213
	ret

; Voice slot dispatch
VoiceSlot_Dispatch:
	ld	a, (0x38e0:16)
	extz	wa
	sub	wa, 128
	cp	wa, 0:i3
	jr	lt, RhythmParam_Dispatch_KeepBeatAdvance_Skip
	cp	wa, 6:i3
	jr	gt, RhythmParam_Dispatch_KeepBeatAdvance_Skip
	add	wa, wa
	lda	xix, (VoiceSlot_Dispatch_CaseTable_Data:24)
	ld	wa, (xix+wa)
	lda xix, (Voice_ClearSlotAndRet:24)

	jp_rr	8, xix, wa
Voice_ClearSlotAndRet:
; RhythmParam_Dispatch_KeepBeatAdvance: Status 0x81 (advance one beat): kept unchanged; 0x82/0x84 become 0x83 (end of
;   track) and the rest are cleared.
	ld	(0x38e0:16), 0
RhythmParam_Dispatch_KeepBeatAdvance:
	ret

; port: v7's label VoiceSlot_DispatchByType is not in v6 -- no v6 bytes correspond to what it named
VoiceSlot_Dispatch_Data_Case2:
	ld	(0x38e0:16), 131
	ret
RhythmParam_Dispatch_KeepBeatAdvance_Skip:
	ld	(0x38e0:16), 0
	ret
VoiceSlot_Dispatch_Data_Case1:
	ret
RhythmParam_Dispatch_KeepBeatAdvance_Skip2:
	ld	(0x38e0:16), 0
	ret
RhythmParam_Dispatch_KeepBeatAdvance_Skip3:
	ret
	ret
	nop
	nop
	nop
	ret
	nop
	nop
	nop
	ret
	nop
	nop
	nop
	ret
	nop
	nop
	nop
	ret
	nop
	nop
	nop
	ret
	nop
	nop
	nop
	pushw	wa
	pushw	hl
	call	TimeSig_CallProc
	inc	4, xsp
	ret

Voice_ResolveSlotAddr:
	push	xiz
	ld	w, (14558:16)
call	SetWall_SlotResolve
	ld	(14538:16), iy
	ld	iy, (SEQ_DATA_BLOCK:16)
	ld	(14534:16), iy
	pop	xiz
	ret
VoiceSlot_Dispatch_Type81:
	ld	a, 127:opc
	ld	(14096:16), a
	ld	a, 255:opc
	ld	(14095:16), a
	ld	c, 0:opc
VoiceSlot_Dispatch_Type90:
	cp	c, 7:i3
	jr	z, VoiceSlot_Dispatch_D0Type	; -> 0xF66B3F
	ld	xwa, 14067
	ld	e, 0:opc
	ld	(xwa+c), e
	ld	xwa, 14074
	ld	e, 1:opc
	ld	(xwa+c), e
	ld	xwa, 14081
	ld	e, 255:opc
	ld	(xwa+c), e
	ld	xwa, 14088
	ld	e, 255:opc
	ld	(xwa+c), e
	inc	1, c
	jr	VoiceSlot_Dispatch_Type90	; -> 0xF66B07
VoiceSlot_Dispatch_D0Type:
	ld	(14097:16), 64
	calr	RhythmDrum_LoadVoiceParams
	ld	(14097:16), 32
	calr	RhythmDrum_LoadVoiceParams
	ld	(14097:16), 16
	calr	RhythmDrum_LoadVoiceParams
	ld	(14097:16), 8
	calr	RhythmDrum_LoadVoiceParams
	ld	(14097:16), 4
	calr	RhythmDrum_LoadVoiceParams
	ld	(14097:16), 2
	calr	RhythmDrum_LoadVoiceParams
	ld	(14097:16), 1
	calr	RhythmDrum_LoadVoiceParams
	ret
VoiceSlot_Dispatch_Return:
	push XIZ
	call VoiceSlot_Dispatch_D0Type_Helper
	pop XIZ
	ret
VoiceSlot_Dispatch_D0Type_Helper:
	bit	7, a
	jr	nz, VoiceSlot_Dispatch_Return_Skip2
	cp	(STYLE_SECTION:16), 11
	jr	ge, VoiceSlot_Dispatch_Return_Skip
	inc	1, (STYLE_SECTION:16)
	jr	VoiceSlot_Dispatch_Return_Join
VoiceSlot_Dispatch_Return_Skip:
	ld	(STYLE_SECTION:16), 11
VoiceSlot_Dispatch_Return_Join:
	jr	VoiceSlot_Dispatch_Return_Join2
VoiceSlot_Dispatch_Return_Skip2:
	cp	(STYLE_SECTION:16), 0
	jr	gt, VoiceSlot_Dispatch_Return_Skip3
	ld	(STYLE_SECTION:16), 0
	jr	VoiceSlot_Dispatch_Return_Join2
VoiceSlot_Dispatch_Return_Skip3:
	dec	1, (STYLE_SECTION:16)
VoiceSlot_Dispatch_Return_Join2:
	calr	CmpEsy_SetStyleNumberFromPattern
	calr	DrumParam_BuildActiveMask
	ret
; CmpEsy_SetStyleNumberFromPattern: Makes the selected composer pattern (0x34D6) the panel's current style: record
;   0x48 +0 (style number, 0xFC5A) = 0x80 + (index & 31), +1 (0xFC5B) reduced to its bit 7, then queues the
;   record-0x48 offset-0 change (SwbtWr_QueuePostEvent, E = 0x48, D = 0, W = 0, A = (0xFC5A)). Basis: callers + body
;   -- CmpEsy_StepVariPattern's header describes exactly this step after moving the pattern index (0-11, the A/B/C
;   vari 1-4 patterns); record 0x48 +0/+1 are SndParam_Style_Number / SndParam_Style_Bank.
CmpEsy_SetStyleNumberFromPattern:
	ld	xhl, 0:i3
	ld	l, (STYLE_SECTION:16)
	and	l, 31
	add	l, 128
	ld	xbc, 64602
	ld	a, 0:opc
	ld	(xbc+a), l
	ld	a, 1:opc
	ld	h, (xbc+a)
	and	h, 128
	ld	(xbc+a), h
	ld	a, (PANEL_STYLE:16)
	ld	w, 0:opc
	ld	e, 72:opc
	ld	d, 0:opc
	call	SwbtWr_QueuePostEvent
	ret
DrumParam_ProcessChannel:
	push xiz
	calr DrumParam_LookupChannelBit
	call DrumParam_StepChannelStyle
	pop xiz
	ret

DrumParam_LookupChannelBit:
	push XWA
	push XIX
	ld	a, (0x3900:16)
	ld XIX,DrumParam_ChannelBitTable
	ld	a, (xix+a)
	ld	(0x3711:16), a
	pop	xix
	pop	xwa
	ret
DrumParam_ChannelBitTable:
	normal
	push	sr
	max
	ld	(P4:8), 32:io
	.byte 0x40

DrumParam_StepChannelStyle:
	push_a
	calr DrumParam_ReadVoiceCount
	ld L,A
	pop_a
	push	l
	push_a
	calr	Rhythm_MapChannelToDrumIndex
	pop_a
	ld	xiy, 14067
	add	xiy, xbc
	bit	7, a
	jr	nz, VoiceTable_InitEntry_Loop
	cp	(xiy), 9
	jr	ge, VoiceTable_InitEntry
	inc	1, (xiy)
	jr	RhythmVoice_LoadParams
VoiceTable_InitEntry:
	ld (xiy), 0x9
	jr RhythmVoice_LoadParams

VoiceTable_InitEntry_Loop:
	cp (xiy), 0x0
	jr z, RhythmVoice_LoadParams
	decm8 1, (xiy)

RhythmVoice_LoadParams:
	pop l
	push l
	calr DrumParam_ReadMaxCount
	pop l
	cp l, w
	jr ule, RhythmVoice_LoadParams_Done
	push w
	calr DrumParam_ReadVoiceCount
	pop w
	ld (xix), w

RhythmVoice_LoadParams_Done:
	calr RhythmDrum_LoadVoiceParams
	calr RhythmVoice_LoadParams_Helper
	calr DrumParam_BuildActiveMask
	ret

DrumParam_BuildActiveMask:
	ld	w, 0:opc
	ld	(14096:16), w
	xor	bc, bc
	ld	w, 1:opc
	ld	xix, 14067
	ld	xiy, 14081
VoiceTable_InitEntry_Store:
	ld	a, (xix+)
	cp	a, (xiy+)
	jr	z, VoiceTable_InitEntry_Return
	or	(14096:16), w
VoiceTable_InitEntry_Return:
	sll	w, 1
	inc	1, bc
	cp	bc, 7:i3
	jr	lt, VoiceTable_InitEntry_Store
	xor	bc, bc
	ld	w, 1:opc
	ld	xix, 14074
	ld	xiy, 14088
MultiVoice_SetupChannel:
	ld	a, (xix+)
	cp	a, (xiy+)
	jr	z, MultiVoice_Setup_Loop
	or	(14096:16), w
MultiVoice_Setup_Loop:
	sll	w, 1
	inc	1, bc
	cp	bc, 7:i3
	jr	lt, MultiVoice_SetupChannel
	ld	a, (STYLE_SECTION:16)
	cp	a, (14095:16)
	jr	z, MultiVoice_Setup_WriteParam
	ld	b, 127:opc
	ld	(14096:16), b
MultiVoice_Setup_WriteParam:
	ret

Rhythm_MapChannelToDrumIndex:
	ld	xbc, 0:i3
	ld	c, (14097:16)
	srl	c, 1
	add	xbc, MultiVoice_Setup_Done
	ld	c, (xbc)
	cp	c, 6:i3
	jr	le, MultiVoice_Setup_NextChan
	ld	c, 0:opc
MultiVoice_Setup_NextChan:
	push c
	ld xbc, 0:i3
	pop c
	ret

MultiVoice_Setup_Done:
; MultiVoice_Setup_Done -- NOT a code label: a 33-entry u8 table that turns a
; one-hot bit into its position.  ** RE-TYPED 2026-09-25 (lane accomp): was
; nop/normal/`push sr`/max/halt mnemonics (data-as-code).  Read by
; Rhythm_MapChannelToDrumIndex:
;     ld c,(0x37c9) / srl c,1 / add xbc, MultiVoice_Setup_Done / ld c,(xbc) /
;     cp c,6 / jr le,... / ld c,0
; so the index is (0x37c9) >> 1.  Only indices 1, 2, 4, 8, 16 and 32 are
; non-zero and they hold 1..6 (bit position + 1); every other byte is 0.
; 33 entries (0..32): the table ends where DrumParam_ReadVoiceCount begins.
; readers in v7 (address from the linked ELF): Rhythm_MapChannelToDrumIndex 0xF66CBB
; (v7 copy: the RAM addresses and ROM values quoted above are the v9/v10
; ones; v7's RAM layout differs -- read them off the reader named above.)
	.byte 0x00, 0x01, 0x02, 0x00, 0x03, 0x00, 0x00, 0x00, 0x04, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06

DrumParam_ReadVoiceCount:
calr	Rhythm_MapChannelToDrumIndex
	ld	xix, 14074
	add	xix, xbc
	ld	a, (xix)
	ret
RhythmDrum_LoadVoiceParams:
	calr	Rhythm_MapChannelToDrumIndex
	ld	xix, 14067
	add	xix, xbc
	ld	xwa, 0:i3
	ld	a, (xix)
	mul	bc, 10
	add	xbc, xwa
	ld	xde, 0:i3
	ld	xhl, 0:i3
	ld	xwa, RhythmDrum_EntryCounts
VoiceAssign_ProcessRequest:
	cp hl, bc
	jr z, VoiceAssign_Process_Loop
	push xbc
	ld	c, (xwa+hl)
	and xbc, 0xff
	add xde, xbc
	pop xbc
	inc 1, hl
	jr VoiceAssign_ProcessRequest

VoiceAssign_Process_Loop:
	push	xde
	calr	Rhythm_MapChannelToDrumIndex
	ld	xix, 14074
	add	xix, xbc
	ld	xwa, 0:i3
	ld	a, (xix)
	pop	xde
	add	xde, xwa
	sll	xde, 2
	ld	xwa, RhythmDrum_Entries
	add	xwa, xde
	ld	xhl, (xwa)
	push	xhl
	calr	Rhythm_MapChannelToDrumIndex
	pop	xhl
	ld	xde, xhl
	srl	xde, 8
	srl	xde, 8
	srl	xde, 8
	ld	xwa, 14281
	add	xwa, xbc
	ld	(xwa), e
	push	xhl
	calr	VoiceAssign_Process_Return
	pop	xhl
	srl	xhl, 8
	srl	xhl, 8
	push	l
	ld	xhl, 0:i3
	pop	l
	calr	VoiceAssign_ProcessRequest_Helper
	ret
VoiceAssign_Process_Return:
	ld	(0x9036:16), 0x48
	call SndParam_ApplyProgramChange_Safe
	call VoiceParam_ClampAndValidate_Tramp
	pushw hl
	calr Rhythm_MapChannelToDrumIndex
	popw hl
	ld	XIX,0x0000381a
	ld	(xix+c), l
	ld	xix, 14369
	ld	(xix+c), h
	sll	l, 1
	sll	hl, 1
	ld	xiy, RhythmROM_BankProgramLocators
	ld	wa, (xiy+hl)
	add	hl, 2
	ld	xde, 0:i3
	ld	de, (xiy+hl)
	ld	w, a
	and	xwa, 65280
	sll	xwa, 8
	ld	xix, 4194304
	add	xix, (RHYTHM_ROM_BASE:16)
	add	xix, xwa
	add	xix, xde
	jr	VoiceAssign_StoreFinal
VoiceAssign_StoreFinal:
	ret

VoiceAssign_ProcessRequest_Helper:
	pushw hl
	push xix
	calr Rhythm_MapChannelToDrumIndex
	pop xix
	popw hl
	ld xwa, VoiceAssign_PresetSelToCase
	ld	a, (xwa+hl)
	and xwa, 0x7
	push xwa
	ld xbc, xwa
	sll xbc, 1
	add xbc, VoiceAssign_LoadLoopArgs
	ld xde, 0:i3
	ld de, (xbc)
	push xix
	calr RegPreset_Load_Loop
	pop xix
	pop xwa
	push xwa
	ld xbc, xwa
	sll xbc, 1
	add xbc, VoiceAssign_DispatchArgs
	ld xde, 0:i3
	ld de, (xbc)
	push xix
	calr MIDIChan_DispatchDone
	pop xix
	pop xwa
	push xwa
	ld xbc, xwa
	sll xbc, 1
	add xbc, VoiceAssign_ResolveArgs
	ld de, (xbc)
	push xix
	calr VoiceResolve_CheckAndStore
	pop xix
	pop xwa
	push xix
	calr VoiceAssign_StoreFinal_Helper
	pop xix
	ret

; VoiceAssign_ProcessRequest_Helper's tables (were one label, RegPreset_LoadVoiceData, decoded as code).  It maps
; the index in HL -- byte +2 of a RhythmDrum_Entries entry, kept across its Rhythm_MapChannelToDrumIndex call --
; through VoiceAssign_PresetSelToCase, keeps the low 3 bits as k, and passes
; word k of each table in DE: VoiceAssign_LoadLoopArgs to RegPreset_Load_Loop, VoiceAssign_DispatchArgs to
; MIDIChan_DispatchDone, VoiceAssign_ResolveArgs to VoiceResolve_CheckAndStore.
VoiceAssign_PresetSelToCase:		.byte	0, 3, 4, 7
VoiceAssign_LoadLoopArgs:	.short	0x0000, 0x040f, 0x040f, 0x000f, 0x0400, 0x040f, 0x040f, 0x040f
VoiceAssign_DispatchArgs:	.short	0x0000, 0x0431, 0x0431, 0x0031, 0x0400, 0x0431, 0x0431, 0x0431
VoiceAssign_ResolveArgs:	.short	0x0000, 0x0406, 0x0406, 0x0006, 0x0400, 0x0406, 0x0406, 0x0406
RegPreset_Load_Loop:
	push xix
	push xde
	calr DrumChannel_MapToIndexA
	pop xde
	pop xix
	ld wa, bc
	sll wa, 1
	mul a, 0x14
	add wa, de
	push xwa
	call MIDIChan_DispatchTable
	pop xwa
	ld hl, 1:i3
	cp wa, 0x400
	jr nc, RegPreset_Load_Return
	ld hl, 0:i3

RegPreset_Load_Return:
	ld xbc, 0:i3

ChanAssign_FourSlotLoop:
	cp c, 4:i3
	jr z, ChanAssign_StoreResult
	push xbc
	pushw wa
	push xbc
	calr ChanAssign_LookupEntry
	pop xbc
	calr ChanAssign_Lookup_Found
	popw wa
	pop xbc
	inc 1, wa
	inc 1, c
	jr ChanAssign_FourSlotLoop

ChanAssign_StoreResult:
	ret

ChanAssign_LookupEntry:
	ld xde, 0:i3
	ld	e, (xix+wa)
	sll e, 1
	push xix
	pushw de
	pushw hl
	calr DrumChannel_MapToIndexB
	popw hl
	popw de
	pop xix
	mul c, 0x26
	add bc, de
	cp hl, 0:i3
	jr nz, ChanAssign_Lookup
	add bc, 0x118
	jr ChanAssign_Lookup_Loop

ChanAssign_Lookup:
	add bc, 0x518

ChanAssign_Lookup_Loop:
	ld xwa, 0:i3
	ld	wa, (xix+bc)
	ld xde, xiy
	add xde, xwa
	ret

ChanAssign_Lookup_Found:
	push	xde
	push	xbc
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 4
	ld	xwa, xbc
	pop	xbc
	sll	bc, 2
	add	xwa, xbc
	add	xwa, 14162
	pop	xde
	add	xde, 6
	ld	(xwa), xde
	ret
MIDIChan_DispatchTable:
	ldw bc, 0x3d1

	ld xwa, 0:i3

	ld	w, (xix+bc)

	and xwa, 0xff00

	sll xwa, 8

	ld xiy, 0x400000

	add xix, (RHYTHM_ROM_BASE:16)

	add xiy, xwa

	ret



DrumChannel_MapToIndexA:
	cp	(0x3711:16), 0x01
	jr nz, .Lc_f66f2a
	ld xbc, 0:i3
	jr t, DrumChannel_MapA_NullRet
MIDIChan_Dispatch_Ch1:
.Lc_f66f2a:
	cp	(0x3711:16), 0x02
	jr nz, .Lc_f66f35
	ld xbc, 0:i3
	jr t, DrumChannel_MapA_NullRet
MIDIChan_Dispatch_Ch2:
.Lc_f66f35:
	cp	(0x3711:16), 0x04
	jr nz, .Lc_f66f40
	ld xbc, 0:i3
	jr t, DrumChannel_MapA_NullRet
MIDIChan_Dispatch_Ch3:
.Lc_f66f40:
	cp	(0x3711:16), 0x08
	jr nz, .Lc_f66f4b
	ld xbc, 1:i3
	jr t, DrumChannel_MapA_NullRet
MIDIChan_Dispatch_Ch4:
.Lc_f66f4b:
	cp	(0x3711:16), 0x10
	jr nz, .Lc_f66f56
	ld xbc, 2:i3
	jr t, DrumChannel_MapA_NullRet
MIDIChan_Dispatch_Ch5:
.Lc_f66f56:
	cp	(0x3711:16), 0x20
	jr nz, MIDIChan_Dispatch_Ch6
	ld xbc, 3:i3
	jr t, DrumChannel_MapA_NullRet
MIDIChan_Dispatch_Ch6:
	ld xbc, 4:i3

DrumChannel_MapA_NullRet:
	ret

DrumChannel_MapToIndexB:
	cp	(0x3711:16), 0x01
	jr nz, .Lc_f66f6f
	ld xbc, 0:i3
	jr t, DrumChannel_MapB_NullRet
MIDIChan_Dispatch_Ch7:
.Lc_f66f6f:
	cp	(0x3711:16), 0x02
	jr nz, .Lc_f66f7a
	ld xbc, 0:i3
	jr t, DrumChannel_MapB_NullRet
MIDIChan_Dispatch_Ch8:
.Lc_f66f7a:
	cp	(0x3711:16), 0x04
	jr nz, .Lc_f66f85
	ld xbc, 0:i3
	jr t, DrumChannel_MapB_NullRet
MIDIChan_Dispatch_Ch9:
.Lc_f66f85:
	cp	(0x3711:16), 0x08
	jr nz, .Lc_f66f90
	ld xbc, 2:i3
	jr t, DrumChannel_MapB_NullRet
MIDIChan_Dispatch_Ch10:
.Lc_f66f90:
	cp	(0x3711:16), 0x10
	jr nz, .Lc_f66f9b
	ld xbc, 3:i3
	jr t, DrumChannel_MapB_NullRet
MIDIChan_Dispatch_Ch11:
.Lc_f66f9b:
	cp	(0x3711:16), 0x20
	jr nz, MIDIChan_Dispatch_Ch12
	ld xbc, 4:i3
	jr t, DrumChannel_MapB_NullRet
MIDIChan_Dispatch_Ch12:
	ld xbc, 5:i3

DrumChannel_MapB_NullRet:
	ret

MIDIChan_DispatchDone:
	push xix

	push xde

	calr DrumChannel_MapToIndexA

	pop xde

	pop xix

	mul bc, 0x7

	add xbc, xde

	add xbc, 0x248

	add xix, xbc

	calr Rhythm_MapChannelToDrumIndex

	mul bc, 0x8

	add	xbc, 14105

	ld xiy, xbc

	ld xbc, 7:i3

	push xiy

	push xix

	pop xiy

	pop xix

	ldir85

	ret



VoiceResolve_CheckAndStore:
	bit	0, (0x3711:16)
	jr nz, Rhythm_ClearChannelDrumIndex
	bit	1, (0x3711:16)
	jr nz, Rhythm_ClearChannelDrumIndex
	bit	2, (0x3711:16)
	jr nz, Rhythm_ClearChannelDrumIndex
	bit	3, (0x3711:16)
	jr nz, Rhythm_ClearChannelDrumIndex
	add DE,0x03d2
	ld	a, (xix+de)
	calr Rhythm_MapChannelToDrumIndex
	add XBC,VoiceResolve_SearchDone
	ld C,(XBC)
	and A,C
	cp A,C
	jr nz, VoiceResolve_Return
	ld A, 0x00:opc
	jr t, VoiceResolve_CheckAndStore_Join
VoiceResolve_Return:
	ld a, 0x1:opc

VoiceResolve_CheckAndStore_Join:
	jr VoiceResolve_InitSearch

Rhythm_ClearChannelDrumIndex:
	ld a, 0x0:opc

VoiceResolve_InitSearch:
	push_a
	calr	Rhythm_MapChannelToDrumIndex
	pop_a
	add	xbc, 14274
	ld	(xbc), a
	ret
VoiceResolve_SearchDone:
	ld	(P2:8), 8:io
	ld	(P2:8), 16:io
	.byte 0x20

VoiceAssign_StoreFinal_Helper:
	ldw bc, 0x3d0

	ld	a, (xix+bc)

	push xix

	calr VoiceResolve_FindSlot

	pop xix

	push_a

	push xix

	calr Rhythm_MapChannelToDrumIndex

	pop xix

	pop_a

	add	xbc, 14098

	ld (xbc), a

	ret



VoiceResolve_FindSlot:
	push xbc
	ld xbc, AccTone_LookupByProgram_Table
	ld	a, (xbc+a)
	pop xbc
	ret

VoiceResolve_FindSlot_Return:
	add	a, 3
	ret

RhythmVoice_LoadParams_Helper:
	calr Rhythm_MapChannelToDrumIndex
	add	XBC,0x000036f3
	ld xwa, 0:i3
	ld A,(XBC)
	sll XWA, 0x04
	ld XIY,AccRhythm_Ram3888_Records
	add XIY,XWA
	ld	XIX,0x000037d0
	ld XBC,0x00000010
	push XIX
	ldir85
	pop XIX
	calr RhythmDrum_LoadVoiceParams
	ret
DrumParam_ProcessChannelAlt:
	push xiz
	calr DrumParam_LookupChannelBit
	call PartVoice_UpdateParams
	pop xiz
	ret

PartVoice_UpdateParams:
	push_a
	calr	DrumParam_ReadMaxCount
	pop_a
	calr	Rhythm_MapChannelToDrumIndex
	ld	xix, 14074
	add	xix, xbc
	ld	c, (xix)
	cp	a, 0:i3
	jr	nz, PartVoice_Update_Loop
	cp	c, w
	jr	ge, DrumParam_ClampVoiceCount
	inc	1, c
	jr	DrumParam_ClampVoiceCount
PartVoice_Update_Loop:
	cp	c, 0:i3
	jr	z, DrumParam_ClampVoiceCount
	dec	1, c
	bit	0, (0x3711:16)
	jr	z, DrumParam_ClampVoiceCount
	cp	c, 1:i3
	jr	ge, DrumParam_ClampVoiceCount
	ld	c, 1:opc
DrumParam_ClampVoiceCount:
	cp c, w
	jr gt, PartVoice_Update_Return
	cp c, 0:i3
	jr lt, PartVoice_Update_Done
	jr DrumParam_ClampVoiceCount_Join

PartVoice_Update_Return:
	ld c, w
	jr DrumParam_ClampVoiceCount_Join

PartVoice_Update_Done:
	ld c, 0x0:opc

DrumParam_ClampVoiceCount_Join:
	ld (xix), c
	calr RhythmDrum_LoadVoiceParams
	calr DrumParam_BuildActiveMask
	ret

DrumParam_ReadMaxCount:
	calr Rhythm_MapChannelToDrumIndex
	ld XHL,XBC
	add	XHL,0x000036f3
	ld L,(XHL)
	mul BC,0x000a
	ld XWA,RhythmDrum_EntryCounts
	add XWA,XBC
	ld	w, (xwa+l)
	dec	1, w
	ret
ExtVoice_ProcessList:
	ret
CmEsyTtl_Dispatch2_Helper2:
	push XIZ
	call ExtVoice_ProcessList_Data
	pop XIZ
	ret
ExtVoice_ProcessList_Data:
	bit	2, (ACC_TRANSPORT_STATE:16)
	jr	nz, DrumParam_ReadMaxCount_Return
	or	(0x3415:16), 128
	call	Seq_DispatcherEntry
	call	AccWrap_PlayModeStartAccPlay
DrumParam_ReadMaxCount_Return:
	ret
CmpEsy_ApplyEdit:
	push	xiz
	call	CmpEsy_ApplyEdit_Impl
	pop	xiz
	ret
; CmpEsy_ApplyEdit_Impl: Body of CmpEsy_ApplyEdit (EASY COMPOSER SET): stops the accompaniment, rebuilds the pattern
;   data of every part whose bit is set in 0x37C8 (DrumParam_ReadMaxCount_Helper5), clears 0x37C8 on success or re-
;   initialises the slot and sets 0x37C8 |= 127 on failure (GLOBAL_ERROR_CODE != 0), then restarts the accompaniment
;   (AccWrap_PlayModeStartAccPlay) or reports the error (DrumVoice_NotifyEE). Basis: callers + body -- its only caller
;   is the XIZ-preserving wrapper CmpEsy_ApplyEdit, whose header describes exactly these steps; X_Impl convention.
CmpEsy_ApplyEdit_Impl:
	call	AccWrap_PlayModeDispatch
	calr	DrumParam_ReadMaxCount_Helper2
	call	Seq_DispatcherEntry
	pushdi_b	(14097)
	calr	DrumParam_ReadMaxCount_Helper4
	calr	DrumParam_ReadMaxCount_Helper5
	ld	(GLOBAL_ERROR_CODE:16), 0
	calr	DrumParam_ReadMaxCount_Helper6
	cp	(GLOBAL_ERROR_CODE:16), 0
	jr	z, DrumParam_ReadMaxCount_Skip
	call	AccPatch_InitCurrentSlot
	or	(0x3710:16), 127
	jr	ExtVoice_ProcessList_Join
DrumParam_ReadMaxCount_Skip:
	ld	(14096:16), 0
ExtVoice_ProcessList_Join:
	pop	(0x3711:16)
	or	(0x3415:16), 128
	call	Seq_DispatcherEntry
	cp	(GLOBAL_ERROR_CODE:16), 0
	jr	nz, DrumParam_ReadMaxCount_Skip2
	call	AccWrap_PlayModeStartAccPlay
	jr	DrumParam_ReadMaxCount_Return2
DrumParam_ReadMaxCount_Skip2:
	calr	DrumParam_ReadMaxCount_Helper
DrumParam_ReadMaxCount_Return2:
	ret
DrumParam_ReadMaxCount_Helper:
	call	DrumVoice_NotifyEE
	ret
DrumParam_ReadMaxCount_Helper2:
	bit	2, (ACC_TRANSPORT_STATE:16)
	jr	z, DrumParam_ReadMaxCount_Return3
	jr	DrumParam_ReadMaxCount_Helper2
DrumParam_ReadMaxCount_Return3:
	ret
DrumParam_ReadMaxCount_Helper4:
	ld	(14097:16), 1
	calr	Rhythm_MapChannelToDrumIndex
	ld	xwa, 14098
	add	xwa, xbc
	ld	a, (xwa)
	cp	a, (STYLE_SECTION_BEATS:16)
	jr	z, DrumParam_ReadMaxCount_Return4
	ld	(14096:16), 127
	ld	(STYLE_SECTION_BEATS:16), a
	calr	VoiceResolve_FindSlot_Return
	ld	(STYLE_SECTION_TIME_SIG:16), a
DrumParam_ReadMaxCount_Return4:
	ret
DrumParam_ReadMaxCount_Helper5:
	ld	(STYLE_SECTION_LAST_MEASURE:16), 3
	ret
DrumParam_ReadMaxCount_Helper6:
	bit	3, (0x3710:16)
	jr	z, ExtVoice_ProcessList_Join2
	ld	(14097:16), 8
	calr	AccVoice_SetupStyleSlots
	calr	Rhythm_MapChannelToDrumIndex
	ld	xix, 14274
	cp	(xix+bc), 0x00
	jr	nz, ExtVoice_ProcessList_Join2
	calr	AccVoice_SetupSlots_DataBlock
ExtVoice_ProcessList_Join2:
	bit	4, (0x3710:16)
	jr	z, ExtVoice_ProcessList_Join3
	ld	(14097:16), 16
	calr	AccVoice_SetupStyleSlots
	calr	Rhythm_MapChannelToDrumIndex
	ld	xix, 14274
	cp	(xix+bc), 0x00
	jr	nz, ExtVoice_ProcessList_Join3
	calr	AccVoice_SetupSlots_DataBlock
ExtVoice_ProcessList_Join3:
	bit	5, (0x3710:16)
	jr	z, ExtVoice_ProcessList_Join4
	ld	(14097:16), 32
	calr	AccVoice_SetupStyleSlots
	calr	Rhythm_MapChannelToDrumIndex
	ld	xix, 14274
	cp	(xix+bc), 0x00
	jr	nz, ExtVoice_ProcessList_Join4
	calr	AccVoice_SetupSlots_DataBlock
ExtVoice_ProcessList_Join4:
	bit	6, (0x3710:16)
	jr	z, ExtVoice_ProcessList_Join5
	ld	(14097:16), 64
	calr	AccVoice_SetupStyleSlots
	calr	Rhythm_MapChannelToDrumIndex
	ld	xix, 14274
	cp	(xix+bc), 0x00
	jr	nz, ExtVoice_ProcessList_Join5
	calr	AccVoice_SetupSlots_DataBlock
ExtVoice_ProcessList_Join5:
	bit	0, (0x3710:16)
	jr	nz, DrumParam_ReadMaxCount_Skip3
	bit	1, (0x3710:16)
	jr	nz, DrumParam_ReadMaxCount_Skip3
	bit	2, (0x3710:16)
	jr	nz, DrumParam_ReadMaxCount_Skip3
	jr	DrumParam_ReadMaxCount_Return5
DrumParam_ReadMaxCount_Skip3:
	ld	(14097:16), 1
	calr	AccVoice_SetupStyleSlots
	calr	AccVoice_SetupSlots_Apply
DrumParam_ReadMaxCount_Return5:
	ret
AccVoice_SetupStyleSlots:
	calr AccVoice_SetupStyleSlots_Helper2
	calr DrumChannel_MapToIndexB
	sll xbc, 1
	add xix, xbc
	ld hl, (xix)
	pushw hl
	calr AccPatch_ResolveEntryAddr
	push xwa
	add xwa, 0x3
	ld hl, (xwa)
	ldw (xwa), 0xffff
	pop xwa
	pushw hl
	calr Voice_ClearSlotBuffer
	calr AccVoice_SetupStyleSlots_Helper
	popw hl

AccVoice_SetupSlots_Loop:
	cp	hl, 65535
	jr	z, AccVoice_SetupSlots_InitEntry
	calr	AccPatch_ResolveEntryAddr
	push	xwa
	add	xwa, 3
	ld	hl, (xwa)
	ldw	(xwa), 65535
	pop	xwa
	push	xwa
	add	xwa, 1
	ldw	(xwa), 65535
	pop	xwa
	push	xwa
	and	(xwa), 127
	pop	xwa
	pushw	hl
	calr	Voice_ClearSlotBuffer
	popw	hl
	incw	1, (STYLE_FREE_BLOCKS:16)
	jr	AccVoice_SetupSlots_Loop
AccVoice_SetupSlots_InitEntry:
	popw hl
	ret

Voice_ClearSlotBuffer:
	add xwa, 0x6
	ld xix, xwa
	ld xbc, 0xf9

AccVoice_SetupSlots_StoreEntry:
	cp bc, 0:i3
	jr z, AccVoice_SetupSlots_Return
	ld a, 0x0:opc
	ld (xix), a
	inc 1, xix
	dec 1, bc
	jr AccVoice_SetupSlots_StoreEntry

AccVoice_SetupSlots_Return:
	ret

AccVoice_SetupStyleSlots_Helper:
	add xwa, 0x6

	ld xbc, 0:i3

	ld	c, (STYLE_SECTION_LAST_MEASURE:16)

	inc 1, c

	; mul bc, (0x34d9:16) (v7 patched)
	mul	bc, (STYLE_SECTION_BEATS:16)
AccVoice_SetupSlots_CheckType:
	cp bc, 0:i3
	jr z, AccVoice_SetupSlots_Done
	ld e, 0x81:opc
	ld (xwa), e
	inc 1, xwa
	dec 1, bc
	jr AccVoice_SetupSlots_CheckType

AccVoice_SetupSlots_Done:
	ld c, 0x83:opc
	ld (xwa), c
	ret

AccVoice_SetupStyleSlots_Helper2:
	ld	xhl, 0:i3
	ld	l, (STYLE_SECTION:16)
	cp	l, 30
	jr	lt, AccVoice_SetupSlots_Write
	ld	l, 0:opc
AccVoice_SetupSlots_Write:
	mul l, 0x60
	add hl, 0x60
	ld xix, RHYTHM_PATTERN_BUF_A
	add xix, xhl
	ret

AccVoice_SetupSlots_WriteDone:
	nop
	nop

AccPatch_ResolveEntryAddr:
	push xix
	pushw hl
	pushw hl
	ld xhl, 0:i3
	popw hl
	sll xhl, 8
	ld xwa, RHYTHM_PATTERN_BUF_B
	add xwa, xhl
	popw hl
	pop xix
	ret

AccVoice_SetupSlots_DataBlock:
	; framing ported from v10's source for the same label (same span length, statement for statement); 437 of 592 slots byte-identical
	calr	Rhythm_MapChannelToDrumIndex
	add	xbc, 14074
	ld	a, (xbc)
	cp	a, 0:i3
	jr	z, AccVoice_SetupSlots_DataBlock_Return
	calr	AccVoice_SetupSlots_DataBlock_Helper
	calr	AccPatch_SetCursorToChannelStart
	calr	AccVoice_SetupSlots_DataBlock_Helper3
AccVoice_SetupSlots_DataBlock_Return:
	ret
AccVoice_SetupSlots_DataBlock_Helper:
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 3
	add	xbc, 14105
	ld	xiy, xbc
	calr	AccVoice_SetupStyleSlots_Helper2
	push	xix
	calr	DrumChannel_MapToIndexA
	pop	xix
	sll	bc, 3
	add	bc, 24
	add	xix, xbc
	ld	xbc, 8
	; v10 does not spell this byte either
	ldir85
	ret
; AccPatch_SetCursorToChannelStart: Points the pattern-data write cursor at the start of the selected accompaniment
;   channel's data in the current pattern: (0x3576) = that channel's first block number (word from the pattern's
;   RHYTHM_PATTERN_BUF_A entry, indexed by DrumChannel_MapToIndexB of the one-hot (0x372D)), (0x3578) = 6, the first
;   data byte after the block header. Basis: callers + body -- AccVoice_SetupSlots_* call it before the routines that
;   write 0x81/0x83 at that cursor.
AccPatch_SetCursorToChannelStart:
	calr	AccVoice_SetupStyleSlots_Helper2
	calr	DrumChannel_MapToIndexB
	sll	bc, 1
	ld	hl, (xix+bc)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), hl
	ldw	(ACC_PATCH_CURSOR_OFFSET:16), 6
	ret
AccVoice_SetupSlots_DataBlock_Helper3:
	ld	c, 0:opc
	ld	(14361:16), c
	ld	c, (STYLE_SECTION_LAST_MEASURE:16)
	inc	1, c
AccVoice_SetupSlots_DataBlock_Join:
	cp	c, (14361:16)
	jr	le, AccVoice_SetupSlots_DataBlock_Skip
	push	c
	calr	AccVoice_SetupSlots_DataBlock_Helper4
	pop	c
	ld	a, (14361:16)
	inc	1, a
	ld	(14361:16), a
	jr	AccVoice_SetupSlots_DataBlock_Join
AccVoice_SetupSlots_DataBlock_Skip:
	calr	AccVoice_SetupSlots_DataBlock_Helper10
	ret
AccVoice_SetupSlots_DataBlock_Helper4:
	calr	AccVoice_SetupSlots_DataBlock_Helper5
	push	xwa
	calr	Rhythm_MapChannelToDrumIndex
	pop	xwa
	sll	xbc, 2
	add	xbc, 14304
	ld	(xbc), xwa
	ld	a, 0:opc
	ld	(14360:16), a
	ld	c, (STYLE_SECTION_BEATS:16)
AccVoice_SetupSlots_DataBlock_Join2:
	cp	(14360:16), c
	jr	ge, AccVoice_SetupSlots_DataBlock_Return2
	push	c
	calr	AccVoice_SetupSlots_DataBlock_Helper6
	ld	a, (14360:16)
	inc	1, a
	ld	(14360:16), a
	pop	c
	jr	AccVoice_SetupSlots_DataBlock_Join2
AccVoice_SetupSlots_DataBlock_Return2:
	ret
AccVoice_SetupSlots_DataBlock_Helper5:
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 4
	add	xbc, 14162
	ld	xwa, 0:i3
	ld	a, (14361:16)
	sll	xwa, 2
	add	xbc, xwa
	ld	xwa, (xbc)
	ret
AccVoice_SetupSlots_DataBlock_Helper6:
	calr	AccVoice_SetupSlots_DataBlock_Sub
	cp	a, 131
	jr	nz, AccVoice_SetupSlots_DataBlock_Skip2
	calr	Rhythm_MapChannelToDrumIndex
	sll	bc, 2
	add	xbc, 14304
	ld	xwa, Rhythm_EmptyPattern
	ld	(xbc), xwa
	push	xbc
	ld	xbc, 1:i3
	calr	AccVoice_SetupSlots_DataBlock_Helper8
	pop	xbc
	ld	a, 129:opc
	jr	AccVoice_SetupSlots_DataBlock_Helper6_Join
AccVoice_SetupSlots_DataBlock_Skip2:
	push_a
	calr	AccVoice_SetupSlots_DataBlock_Helper8
	pop_a
AccVoice_SetupSlots_DataBlock_Helper6_Join:
	cp	a, 129
	jr	z, AccVoice_SetupSlots_DataBlock_Helper6_Return
	jr	AccVoice_SetupSlots_DataBlock_Helper6
AccVoice_SetupSlots_DataBlock_Helper6_Return:
	ret
; Rhythm_EmptyPattern -- an empty pattern stream (0x81, then 0xFF x4): the default every rhythm slot pointer
;          at 0x37FC + 4*drum (v10/v9: 0x3898) is set to and compared with; a pointer one byte past it is put back on it.
;          Was Rhythm_EmptyPattern, decoded as `cp (xbc),l / swi 7 x3`.
Rhythm_EmptyPattern:
	.byte	0x81, 0xff, 0xff, 0xff, 0xff
AccVoice_SetupSlots_DataBlock_Sub:
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 2
	add	xbc, 14304
	ld	xwa, (xbc)
	cp	xwa, Rhythm_EmptyPattern
	jr	z, AccVoice_SetupSlots_DataBlock_Sub_Skip
	ld	a, (xwa)
	jr	AccVoice_SetupSlots_DataBlock_Sub_Return
AccVoice_SetupSlots_DataBlock_Sub_Skip:
	ld	a, 131:opc
AccVoice_SetupSlots_DataBlock_Sub_Return:
	ret
AccPatch_GetEventLength:
	ld	c, 0:opc
	cp	a, 144
	jr	nz, AccPatch_GetEventLength_Skip3
	ld	c, 6:opc
	jr	AccPatch_GetEventLength_Return3
AccPatch_GetEventLength_Skip3:
	cp	a, 145
	jr	nz, AccPatch_GetEventLength_Skip4
	ld	c, 8:opc
	jr	AccPatch_GetEventLength_Return3
AccPatch_GetEventLength_Skip4:
	cp	a, 129
	jr	nz, AccPatch_GetEventLength_Skip5
	ld	c, 1:opc
	jr	AccPatch_GetEventLength_Return3
AccPatch_GetEventLength_Skip5:
	cp	a, 131
	jr	nz, AccPatch_GetEventLength_Skip6
	ld	c, 1:opc
	jr	AccPatch_GetEventLength_Return3
AccPatch_GetEventLength_Skip6:
	ld	w, a
	and	w, 208
	cp	w, 208
	jr	nz, AccPatch_GetEventLength_Skip7
	ld	c, 3:opc
	jr	AccPatch_GetEventLength_Return3
AccPatch_GetEventLength_Skip7:
	cp	c, 0:i3
	jr	nz, AccPatch_GetEventLength_Return3
	nop
AccPatch_GetEventLength_Return3:
	ret
AccVoice_SetupSlots_DataBlock_Helper8:
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 2
	add	xbc, 14304
	ld	xiy, (xbc)
	ld	a, (xiy)
	ld	xbc, 0:i3
	calr	AccPatch_GetEventLength
	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)
	pushw	bc
	calr	AccPatch_ResolveEntryAddr
	popw	bc
	ld	xix, xwa
	ld	xwa, 0:i3
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	add	xix, xwa
	ldw	de, 255
	sub	de, (ACC_PATCH_CURSOR_OFFSET:16)
	cp	bc, de
	jr	gt, AccVoice_SetupSlots_DataBlock_Skip8
	; v10 does not spell this byte either
	add	(ACC_PATCH_CURSOR_OFFSET:16), bc
	; differs from v10 here and llvm-objdump cannot read it
	cp	bc, 0:i3
	jr	z, AccVoice_SetupSlots_DataBlock_Helper8_Skip
	; v10 does not spell this byte either
	ldir85
AccVoice_SetupSlots_DataBlock_Helper8_Skip:
	jr	AccVoice_SetupSlots_DataBlock_Join3
AccVoice_SetupSlots_DataBlock_Skip8:
	pushw	bc
	ld	bc, de
	; v10 does not spell this byte either
	add	(ACC_PATCH_CURSOR_OFFSET:16), bc
	; differs from v10 here and llvm-objdump cannot read it
	cp	bc, 0:i3
	jr	z, AccVoice_SetupSlots_DataBlock_Helper8_Skip2
	; v10 does not spell this byte either
	ldir85
AccVoice_SetupSlots_DataBlock_Helper8_Skip2:
	popw	bc
	push	xiy
	sub	bc, de
	ld	(13189:16), bc
	ld	(13191:16), de
	calr	AccVoice_SetupSlots_DataBlock_Helper9
	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)
	calr	AccPatch_ResolveEntryAddr
	ld	xix, xwa
	ld	xwa, 0:i3
	ld	wa, (ACC_PATCH_CURSOR_OFFSET:16)
	add	xix, xwa
	pop	xiy
	ld	bc, (13189:16)
	; v10 does not spell this byte either
	add	(ACC_PATCH_CURSOR_OFFSET:16), bc
	; differs from v10 here and llvm-objdump cannot read it
	cp	bc, 0:i3
	jr	z, AccVoice_SetupSlots_DataBlock_Join3
	; v10 does not spell this byte either
	ldir85
AccVoice_SetupSlots_DataBlock_Join3:
	push	xiy
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 2
	add	xbc, 14304
	pop	xiy
	ld	(xbc), xiy
	cp	xiy, Rhythm_EmptyPattern + 1
	jr	nz, AccVoice_SetupSlots_DataBlock_Return4
	ld	xiy, Rhythm_EmptyPattern
	ld	(xbc), xiy
AccVoice_SetupSlots_DataBlock_Return4:
	ret
AccVoice_SetupSlots_DataBlock_Helper9:
	; v10 does not spell this byte either
	cpw	(STYLE_FREE_BLOCKS:16), 0
	; v10 does not spell this byte either
	jr	z, AccVoice_SetupSlots_DataBlock_Skip9
	ldw	hl, 150
AccVoice_SetupSlots_DataBlock_Join4:
	pushw	hl
	calr	AccPatch_ResolveEntryAddr
	popw	hl
	; v10 does not spell this byte either
	bit	7, (xwa)
	jr	z, AccVoice_SetupSlots_DataBlock_Helper9_Skip
	; v10 does not spell this byte either
	inc	1, hl
	jr	AccVoice_SetupSlots_DataBlock_Join4
AccVoice_SetupSlots_DataBlock_Helper9_Skip:
	ld	c, (xwa)
	or	c, 128
	ld	(xwa), c
	ld	de, 1:i3
	ld	bc, (ACC_PATCH_CURSOR_BLOCK:16)
	ld	(xwa+de), bc
	pushw	hl
	ld	hl, (ACC_PATCH_CURSOR_BLOCK:16)
	calr	AccPatch_ResolveEntryAddr
	ld	de, 3:i3
	popw	hl
	ld	(xwa+de), hl
	decw	1, (STYLE_FREE_BLOCKS:16)
	ld	(ACC_PATCH_CURSOR_BLOCK:16), hl
	ld	wa, 6:i3
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
	jr	AccVoice_SetupSlots_DataBlock_Return5
AccVoice_SetupSlots_DataBlock_Skip9:
	ld	wa, 6:i3
	ld	(ACC_PATCH_CURSOR_OFFSET:16), wa
	ld	(GLOBAL_ERROR_CODE:16), 15
AccVoice_SetupSlots_DataBlock_Return5:
	ret
AccVoice_SetupSlots_DataBlock_Helper10:
	calr	Rhythm_MapChannelToDrumIndex
	sll	bc, 2
	add	xbc, 14304
	ld	xwa, Rhythm_EndPattern
	ld	(xbc), xwa
	ld	c, 1:opc
	calr	AccVoice_SetupSlots_DataBlock_Helper8
	ret
Rhythm_EndPattern:
	; A pattern stream that is only its end code 0x83 (RhythmVoice_WriteToBuffer stops at 0x83);
	; AccVoice_SetupSlots_DataBlock_Helper10 stores its address in a slot of 0x37FC.  Was `ld a, (xhl)`.
	.byte	0x83
AccVoice_SetupSlots_Apply:
	; (0x372D) := 1, then AccVoice_SetupSlots_DataBlock_Helper, _Helper10_Helper, _Helper2 and
	; AccVoice_SetupSlots_DataBlock_Helper10_Helper2 (v10/v9: AccVoice_SetupSlots_ForEachSlot).
	ld	a, 1:opc
	ld	(0x3711:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper
	calr	AccVoice_SetupSlots_DataBlock_Helper10_Helper
	calr	AccPatch_SetCursorToChannelStart
	calr	AccVoice_SetupSlots_DataBlock_Helper10_Helper2
	ret
AccVoice_SetupSlots_DataBlock_Helper10_Helper:
	calr	AccVoice_SetupStyleSlots_Helper2
	ld	w, (STYLE_SECTION_TIME_SIG:16)
	ld	a, 12:opc
	ld	(xix+a), w
	ld	w, (STYLE_SECTION_LAST_MEASURE:16)
	ld	a, 13:opc
	; v10 does not spell this byte either
	ld	(xix+a), w
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	ld	w, 32:opc
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	ld	a, 14:opc
	; v10 does not spell this byte either
	ld	(xix+a), w
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	ld	w, 0:opc
	ld	a, 15:opc
	; v10 does not spell this byte either
	ld	(xix+a), w
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	ld	a, 1:opc
	ld	(0x3711:16), a
	; v10 does not spell this byte either
	push	xix
	calr	Rhythm_MapChannelToDrumIndex
	pop	xix
	ld	xiy, 14362
	ld	w, (xiy+c)
	ld	a, 16:opc
	ld	(xix+a), w
	ld	xiy, 14369
	ld	w, (xiy+c)
	ld	a, 17:opc
	ld	(xix+a), w
	ld	xiy, AccVoice_SlotName_Easy
	add	xix, 64
	ld	xbc, 0:i3
	ldw	bc, 16
	; v10 does not spell this byte either
	ldir85
	ret
; v10 does not spell this byte either
AccVoice_SlotName_Easy:
	; The slot name the routine above copies (ldir85, BC = 16) to the slot at +64.  Was one
	; `.byte` per character, with the next instruction's 23 00 among them.
	.ascii	"Easy            "
AccVoice_SetupSlots_DataBlock_Helper10_Helper2:
	; (0x3835) := 0, then while (0x3835) < (0x343B) + 1: ...
	ld	c, 0:opc
	ld	(14361:16), c
	ld	c, (STYLE_SECTION_LAST_MEASURE:16)
	add	c, 1
AccVoice_SetupSlots_DataBlock_Join5:
	cp	c, (14361:16)
	jr	le, AccVoice_SetupSlots_DataBlock_Skip10
	push	c
	calr	AccVoice_SetupSlots_DataBlock_Helper11
	pop	c
	ld	a, (14361:16)
	inc	1, a
	ld	(14361:16), a
	jr	AccVoice_SetupSlots_DataBlock_Join5
AccVoice_SetupSlots_DataBlock_Skip10:
	calr	AccVoice_SetupSlots_DataBlock_Helper10
	ret
AccVoice_SetupSlots_DataBlock_Helper11:
	ld	a, 1:opc
	ld	(14097:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper5
	push	xwa
	calr	Rhythm_MapChannelToDrumIndex
	pop	xwa
	sll	xbc, 2
	add	xbc, 14304
	ld	(xbc), xwa
	ld	a, 2:opc
	ld	(14097:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper5
	push	xwa
	calr	Rhythm_MapChannelToDrumIndex
	pop	xwa
	sll	xbc, 2
	add	xbc, 14304
	ld	(xbc), xwa
	ld	a, 4:opc
	ld	(14097:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper5
	push	xwa
	calr	Rhythm_MapChannelToDrumIndex
	pop	xwa
	sll	xbc, 2
	add	xbc, 14304
	ld	(xbc), xwa
	ld	a, 0:opc
	ld	(14360:16), a
	ld	c, (STYLE_SECTION_BEATS:16)
AccVoice_SetupSlots_DataBlock_Join6:
	cp	(14360:16), c
	jr	ge, AccVoice_SetupSlots_DataBlock_Return6
	push	c
	calr	AccVoice_SetupSlots_DataBlock_Helper12
	ld	a, (14360:16)
	inc	1, a
	ld	(14360:16), a
	pop	c
	jr	AccVoice_SetupSlots_DataBlock_Join6
AccVoice_SetupSlots_DataBlock_Return6:
	ret
AccVoice_SetupSlots_DataBlock_Helper12:
	ld	a, 1:opc
	ld	(14097:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper13
	ld	a, 2:opc
	ld	(14097:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper13
	ld	a, 4:opc
	ld	(14097:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper13
	calr	AccVoice_SetupSlots_DataBlock_Helper17
	push	l
	calr	AccVoice_SetupSlots_DataBlock_Helper14
	pop	l
	cp	w, 0:i3
	jr	z, AccVoice_SetupSlots_DataBlock_Skip11
	calr	AccVoice_SetupSlots_DataBlock_Helper16
	ld	(14097:16), l
	calr	AccVoice_SetupSlots_DataBlock_Helper8
	jrl	AccVoice_SetupSlots_DataBlock_Helper12
AccVoice_SetupSlots_DataBlock_Skip11:
	ld	a, 1:opc
	ld	(14097:16), a
	ld	xbc, 0:i3
	ld	c, 1:opc
	calr	AccVoice_SetupSlots_DataBlock_Helper8
	ld	a, 2:opc
	ld	(14097:16), a
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 2
	add	xbc, 14304
	ld	xwa, (xbc)
	cp	xwa, Rhythm_EmptyPattern
	jr	z, AccVoice_SetupSlots_DataBlock_Skip12
	inc	1, xwa
	ld	(xbc), xwa
AccVoice_SetupSlots_DataBlock_Skip12:
	ld	a, 4:opc
	ld	(14097:16), a
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 2
	add	xbc, 14304
	ld	xwa, (xbc)
	cp	xwa, Rhythm_EmptyPattern
	jr	z, AccVoice_SetupSlots_DataBlock_Return7
	inc	1, xwa
	ld	(xbc), xwa
AccVoice_SetupSlots_DataBlock_Return7:
	ret
AccVoice_SetupSlots_DataBlock_Helper13:
	calr	Rhythm_MapChannelToDrumIndex
	add	xbc, 14074
	ld	a, (xbc)
	cp	a, 0:i3
	jr	z, AccVoice_SetupSlots_DataBlock_Skip14
	calr	AccVoice_SetupSlots_DataBlock_Helper18
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 2
	add	xbc, 14304
	ld	xwa, (xbc)
	ld	l, (xwa)
	cp	l, 131
	jr	nz, AccVoice_SetupSlots_DataBlock_Skip13
	ld	xwa, Rhythm_EmptyPattern
	ld	(xbc), xwa
AccVoice_SetupSlots_DataBlock_Skip13:
	jr	AccVoice_SetupSlots_DataBlock_Join7
AccVoice_SetupSlots_DataBlock_Skip14:
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 2
	add	xbc, 14304
	ld	xwa, Rhythm_EmptyPattern
	ld	(xbc), xwa
AccVoice_SetupSlots_DataBlock_Join7:
	calr	AccVoice_SetupSlots_CheckStream
	ret
AccVoice_SetupSlots_DataBlock_Helper14:
	ld	a, 1:opc
	ld	(14097:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper15
	cp	a, 129
	jr	nz, AccVoice_SetupSlots_DataBlock_Skip15
	ld	a, 2:opc
	ld	(14097:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper15
	cp	a, 129
	jr	nz, AccVoice_SetupSlots_DataBlock_Skip15
	ld	a, 4:opc
	ld	(14097:16), a
	calr	AccVoice_SetupSlots_DataBlock_Helper15
	cp	a, 129
	jr	nz, AccVoice_SetupSlots_DataBlock_Skip15
	ld	w, 0:opc
	jr	AccVoice_SetupSlots_DataBlock_Return8
AccVoice_SetupSlots_DataBlock_Skip15:
	ld	w, 1:opc
AccVoice_SetupSlots_DataBlock_Return8:
	ret
AccVoice_SetupSlots_DataBlock_Helper15:
	ld	xix, ACC_EVENT
	push	xix
	calr	Rhythm_MapChannelToDrumIndex
	pop	xix
	ld	a, (xix+c)
	ret
AccVoice_SetupSlots_DataBlock_Helper16:
	push	l
	ld	xhl, 0:i3
	pop	l
	and	l, 7
	add	xhl, AccPatch_IndexBitMask8
	ld	l, (xhl)
	ret
AccPatch_IndexBitMask8:
	; L & 7 -> the bit AccVoice_SetupSlots_DataBlock_Helper16 returns; 6 and 7 share bit 6.  Was
	; `normal / push sr / max / ld (P4:8), 32 / ld xwa, 4109049408`.
	.byte	0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x40
	; Reads the slot's stream pointer (0x37FC + 4 * index) and compares its first byte with 0x90 / 0x91.
AccVoice_SetupSlots_CheckStream:
	; Reads the slot's stream pointer (0x37FC + 4 * index) and compares its first byte with 0x90 / 0x91.
	calr	Rhythm_MapChannelToDrumIndex
	push	xbc
	add	xbc, 13173
	ld	xix, xbc
	pop	xbc
	sll	xbc, 2
	add	xbc, 14304
	ld	xwa, (xbc)
	ld	a, (xwa)
	cp	a, 144
	jr	z, AccVoice_SetupSlots_CheckStream_Skip17
	cp	a, 145
	jr	z, AccVoice_SetupSlots_CheckStream_Skip17
	ld	w, a
	and	w, 240
	cp	w, 208
	jr	z, AccVoice_SetupSlots_CheckStream_Skip17
	ld	(xix), a
	cp	a, 135
	jr	nz, AccVoice_SetupSlots_CheckStream_Skip16
	nop
AccVoice_SetupSlots_CheckStream_Skip16:
	jr	AccVoice_SetupSlots_CheckStream_Return9
AccVoice_SetupSlots_CheckStream_Skip17:
	ld	xwa, (xbc)
	inc	1, xwa
	ld	a, (xwa)
	ld	(xix), a
AccVoice_SetupSlots_CheckStream_Return9:
	ret
AccVoice_SetupSlots_DataBlock_Helper17:
	ld	l, 0:opc
	ld	a, 0:opc
	ld	xix, ACC_EVENT
AccPatch_ResolveEntryAddr_Join8:
	cp	l, 2:i3
	jr	gt, AccPatch_ResolveEntryAddr_Skip19
	cp	a, 2:i3
	jr	gt, AccPatch_ResolveEntryAddr_Skip19
	; v10 does not spell this byte either
	ld	h, (xix+l)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	bit	7, h
	jr	z, AccVoice_SetupSlots_CheckStream_Skip
	; v10 does not spell this byte either
	inc	1, l
	jr	AccPatch_ResolveEntryAddr_Join9
AccVoice_SetupSlots_CheckStream_Skip:
	; v10 does not spell this byte either
	ld	w, (xix+a)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	bit	7, w
	jr	z, AccPatch_ResolveEntryAddr_Helper17_Skip
	; v10 does not spell this byte either
	inc	1, a
	jr	AccPatch_ResolveEntryAddr_Join9
AccPatch_ResolveEntryAddr_Helper17_Skip:
	cp	h, w
	jr	gt, AccPatch_ResolveEntryAddr_Skip18
	inc	1, a
	jr	AccPatch_ResolveEntryAddr_Join9
AccPatch_ResolveEntryAddr_Skip18:
	inc	1, l
	jr	AccPatch_ResolveEntryAddr_Join9
AccPatch_ResolveEntryAddr_Join9:
	jr	AccPatch_ResolveEntryAddr_Join8
AccPatch_ResolveEntryAddr_Skip19:
	cp	l, 2:i3
	jr	le, AccPatch_ResolveEntryAddr_Return10
	ld	l, 0:opc
AccPatch_ResolveEntryAddr_Return10:
	ret
AccVoice_SetupSlots_DataBlock_Helper18:
	calr	Rhythm_MapChannelToDrumIndex
	ld	ix, bc
	sll	xbc, 2
	add	xbc, 14304
AccVoice_SetupSlots_DataBlock_Helper18_Join:
	ld	xwa, (xbc)
	ld	a, (xwa)
	cp	a, 144
	jr	z, AccVoice_SetupSlots_DataBlock_Skip20
	cp	a, 145
	jr	z, AccVoice_SetupSlots_DataBlock_Skip20
	ld	e, a
	and	a, 240
	cp	a, 208
	jr	z, AccVoice_SetupSlots_DataBlock_Skip20
	jr	AccVoice_SetupSlots_DataBlock_Return11
AccVoice_SetupSlots_DataBlock_Skip20:
	ld	xwa, (xbc)
	inc	2, xwa
	ld	a, (xwa)
	calr	AccVoice_SetupSlots_DataBlock_Helper19
	cp	c, (14097:16)
	jr	z, AccVoice_SetupSlots_DataBlock_Return11
	calr	Rhythm_MapChannelToDrumIndex
	sll	xbc, 2
	add	xbc, 14304
	ld	xix, (xbc)
	push	xbc
	calr	AccVoice_SetupSlots_DataBlock_Helper18_Helper
	pop	xbc
	ld	(xbc), xix
	jr	AccVoice_SetupSlots_DataBlock_Helper18_Join
AccVoice_SetupSlots_DataBlock_Return11:
	ret
AccVoice_SetupSlots_DataBlock_Helper19:
	push_a
	calr	Rhythm_MapChannelToDrumIndex
	ld	xwa, 14281
	; v10 does not spell this byte either
	ld	e, (xwa+bc)
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	push	e
	; v10 does not spell this byte either
	ld	xde, 0:i3
	pop	e
	sll	de, 7
	add	xde, AccVoice_SlotRows
	pop_a
	ld	c, (xde+a)
	ret
AccVoice_SetupSlots_DataBlock_Helper18_Helper:
	ld	a, (xix)
	calr	AccPatch_GetEventLength
	push	c
	ld	xbc, 0:i3
	pop	c
	add	xix, xbc
	ret
VoiceSlot_InitFromTable:
	push xiz
	call VoiceSlot_Init_CheckType
	pop xiz
	ret

VoiceSlot_Init_CheckType:
	calr VoiceSlot_Init_Process
	calr AccVoice_SetupStyleSlots
	ret

VoiceSlot_Init_Process:
	ld	(0x3711:16), 0x10
	bit	0, (CMP_RECORD_PART:16)
	jr nz, CmpMode_NullRet
	ld	(0x3711:16), 0x20
	bit	1, (CMP_RECORD_PART:16)
	jr nz, CmpMode_NullRet
	ld	(0x3711:16), 0x40
	bit	2, (CMP_RECORD_PART:16)
	jr nz, CmpMode_NullRet
	ld	(0x3711:16), 0x08
	bit	3, (CMP_RECORD_PART:16)
	jr nz, CmpMode_NullRet
	ld	(0x3711:16), 0x01
CmpMode_NullRet:
	ret

CmpMode_NullRet_Code:
	push	xiz
	call	VoiceSlot_Init_Process_Helper
	pop	xiz
	ret
VoiceSlot_Init_Process_Helper:
	ld	e, (14097:16)
	and	e, 1
	cp	e, 1:i3
	jr	z, VoiceSlot_Init_Process_Skip
	ld	e, (14097:16)
	and	e, 2
	cp	e, 2:i3
	jr	z, VoiceSlot_Init_Process_Skip2
	ld	e, (14097:16)
	and	e, 4
	cp	e, 4:i3
	jr	z, VoiceSlot_Init_Process_Skip
	ld	e, (14097:16)
	and	e, 8
	cp	e, 8
	jr	z, VoiceSlot_Init_Process_Skip3
	ld	e, (14097:16)
	and	e, 16
	cp	e, 16
	jr	z, VoiceSlot_Init_Process_Skip4
	ld	e, (14097:16)
	and	e, 32
	cp	e, 32
	jr	z, VoiceSlot_Init_Process_Skip5
	ld	e, (14097:16)
	and	e, 64
	cp	e, 64
	jr	z, VoiceSlot_Init_Process_Skip6
VoiceSlot_Init_Process_Skip:
	ld	(14592:16), 0
	jr	VoiceSlot_Init_Process_Return
VoiceSlot_Init_Process_Skip2:
	ld	(14592:16), 1
	jr	VoiceSlot_Init_Process_Return
	ld	(14592:16), 2
	jr	VoiceSlot_Init_Process_Return
VoiceSlot_Init_Process_Skip3:
	ld	(14592:16), 3
	jr	VoiceSlot_Init_Process_Return
VoiceSlot_Init_Process_Skip4:
	ld	(14592:16), 4
	jr	VoiceSlot_Init_Process_Return
VoiceSlot_Init_Process_Skip5:
	ld	(14592:16), 5
	jr	VoiceSlot_Init_Process_Return
VoiceSlot_Init_Process_Skip6:
	ld	(14592:16), 6
	jr	VoiceSlot_Init_Process_Return
VoiceSlot_Init_Process_Return:
	ret
; CmpMenuTtlFunc setup
CmpMenuTtl_Setup:
CmpModeFunc:
	cp xbc, EVT_ACTIVATE_STATE
	jr nz, DrumKitExit_ReturnZero
	cp xde, 0x1
	jr z, CmpMenuTtl_InitTitle
	or xde, xde
	jr nz, DrumKitExit_ReturnZero
	push xde
	push xhl
	push xix
	push xiz
	call CmpMode_Activate
	pop xiz
	pop xix
	pop xhl
	pop xde
	jr DrumKitExit_ReturnZero

; CmpMenuTtlFunc init title
CmpMenuTtl_InitTitle:
	push xde
	push xhl
	push xix
	push xiz
	call CmpMode_Deactivate
	pop xiz
	pop xix
	pop xhl
	pop xde

DrumKitExit_ReturnZero:
	ld xhl, 0:i3
	ret
; CmpMenuTtlFunc main handler
CmpMenuTtl_MainHandler:
CmpMenuTtlFunc:
	cp xbc, EVT_SW_IN
	jr z, CmpMenuTtl_SpecialKeys
	cp xbc, EVT_ACTIVATE_STATE
	jr nz, CmpMenuTtl_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jr c, CmpMenuTtl_ReturnZero
	cp xde, 0x6
	jr ugt, CmpMenuTtl_ReturnZero
	add xde, xde
	add xde, CmpMenuTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (CmpMenuTtl_Dispatch:24)
	jp	t, (xix+de)
; CmpMenuTtlFunc title dispatch
CmpMenuTtl_Dispatch:
	set	2, (SEQ_RTMCFG:16)
	call	AccWrap_PlayModeDispatch
	jr	t, CmpMenuTtl_ReturnZero

; CmpMenuTtl special key handler (0x88-0x8a)
CmpMenuTtl_SpecialKeys:
	ld	a, (0x3415:16)
	cp	xde, 138
	jr	z, CmpMenuTtl_SetBit4
	cp	xde, 137
	jr	z, CmpMenuTtl_SetBit5
	cp	xde, 136
	jr	nz, CmpMenuTtl_ReturnZero
	and	(0x3415:16), 207
	ldw	wa, TT_CMBKSL
	jr	CmpMenuTtl_PostModeEvent
; CmpMenuTtl set mode bit 5
CmpMenuTtl_SetBit5:
	and	a, 207
	set	5, a
	ld	(13333:16), a
	ldw	wa, TT_CMBKSL
	jr	CmpMenuTtl_PostModeEvent
; CmpMenuTtl set mode bit 4
CmpMenuTtl_SetBit4:
	and	a, 207
	set	4, a
	ld	(13333:16), a
	ldw	wa, TT_CMBKSL
; CmpMenuTtl post mode change event
CmpMenuTtl_PostModeEvent:
	call UI_ChangeTitleByIndex

CmpMenuTtl_ReturnZero:
	ld xhl, 0:i3
	ret
; CmpSetTtlFunc main handler
CmpSetTtl_MainHandler:
CmpSetTtlFunc:
	cp xbc, EVT_SW_IN
	jr z, CmpSetTtl_ModeSwitch
	cp xbc, EVT_ACTIVATE_STATE
	jrl nz, CmpReal_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jrl c, CmpReal_ReturnZero
	cp xde, 0x6
	jrl ugt, CmpReal_ReturnZero
	add xde, xde
	add xde, CmpSetTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (CmpSetTtl_Dispatch:24)
	jp	t, (xix+de)
; CmpSetTtlFunc title dispatch
CmpSetTtl_Dispatch:
	cp	(PREVIOUS_TITLE:16), 180
	jrl	z, CmpReal_ReturnZero
	call	CmpSetTtlFunc_Helper
	ld	xwa, 11796487
	ld	xbc, EVT_SET_SELECTED_CEL
	ld	xde, 4294901761
	call	ApDeliveryEvent
	jrl	CmpReal_ReturnZero
CmpSetTtlFunc_Case3:
	cp	(CURRENT_TITLE:16), 180
	jrl	z, CmpReal_ReturnZero
	call	RhythmConfig_InlineCode2
	jrl	CmpReal_ReturnZero
; CmpSetTtl mode switch (5-way branch)
CmpSetTtl_ModeSwitch:
	cp	(0x3454:16), 0
	jrl	nz, CmpSetTtl_SecondaryDispatch
	cp	xde, 133
	jr	z, CmpSetTtl_DrumVoice1
	cp	xde, 132
	jr	z, CmpSetTtl_DrumVoice1
	cp	xde, 5
	jr	z, CmpSetTtl_DrumVoice0
	cp	xde, 4
	jr	z, CmpSetTtl_DrumVoice0
	cp	xde, 130
	jr	z, VoiceSlot_Resolve_StoreMap
	cp	xde, 129
	jr	z, VoiceSlot_Resolve_StoreMap
	cp	xde, 2
	jr	z, VoiceSlot_ResolveFromMap
	cp	xde, 1
	jrl	nz, CmpReal_ReturnZero
VoiceSlot_ResolveFromMap:
	push xde
	push xhl
	push xix
	push xiz
	ld w, 0x0:opc
	call DrumTempo_Adjust
	pop xiz
	pop xix
	pop xhl
	pop xde
	jrl CmpReal_ReturnZero

VoiceSlot_Resolve_StoreMap:
	push xde
	push xhl
	push xix
	push xiz
	ld w, 0x80:opc
	call DrumTempo_Adjust
	pop xiz
	pop xix
	pop xhl
	pop xde
	jrl CmpReal_ReturnZero

; CmpSetTtl drum voice select (w=0)
CmpSetTtl_DrumVoice0:
	push xde
	push xhl
	push xix
	push xiz
	ld w, 0x0:opc
	call CmpRecSet_DispatchCursorRow
	pop xiz
	pop xix
	pop xhl
	pop xde
	jrl CmpReal_ReturnZero

; CmpSetTtl drum voice select (w=0x80)
CmpSetTtl_DrumVoice1:
	push xde
	push xhl
	push xix
	push xiz
	ld w, 0x80:opc
	call CmpRecSet_DispatchCursorRow
	pop xiz
	pop xix
	pop xhl
	pop xde
	jrl CmpReal_ReturnZero

; CmpSetTtl secondary dispatch
CmpSetTtl_SecondaryDispatch:
	dec 1, xde
	cp xde, 0x0
	jrl c, CmpReal_ReturnZero
	cp xde, 0x5
	jr ule, CmpSetTtl_DynamicLookup
	sub xde, 0x7a
	cp xde, 0x6
	jr c, CmpReal_ReturnZero
	cp xde, 0xb
	jr ugt, CmpReal_ReturnZero

; CmpSetTtl dynamic table lookup
CmpSetTtl_DynamicLookup:
	add xde, xde
	add xde, CmpSetTtl_DynamicLookup_CaseTable
	ld de, (xde)
	lda xix, (CmpSetTtl_Dispatch2:24)
	jp	t, (xix+de)
; CmpSetTtlFunc title dispatch 2
CmpSetTtl_Dispatch2:
	; Six 16-byte case bodies, CmpSetTtl_Dispatch2 + CmpSetTtl_DynamicLookup_CaseTable[k]: save XDE/XHL/
	; XIX/XIZ, W := 0x00 (up) or 0x80 (down), call the stepper of the entry index (0x390E), of
	; entry byte +2 or of entry byte +5, restore, return 0 (CmpReal_ReturnZero).  The first body
	; is entry-index-up.  Were spelled partly as text (":;<> ") and with numeric calls.
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 0:opc
	call	CmpSetTtl_Dispatch2_Helper
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	jr	CmpReal_ReturnZero
CmpSetTtl_Case_EntryIndexDown:
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 128:opc
	call	CmpSetTtl_Dispatch2_Helper
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	jr	CmpReal_ReturnZero
CmpSetTtl_Case_EntryByte2Up:
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 0:opc
	call	CmpSetTtl_StepEntryByte2
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	jr	CmpReal_ReturnZero
CmpSetTtl_Case_EntryByte2Down:
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 128:opc
	call	CmpSetTtl_StepEntryByte2
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	jr	CmpReal_ReturnZero
CmpSetTtl_Case_EntryByte5Up:
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 0:opc
	call	CmpSetTtl_StepEntryByte5
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	jr	CmpReal_ReturnZero
CmpSetTtl_Case_EntryByte5Down:
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 128:opc
	call	CmpSetTtl_StepEntryByte5
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
CmpReal_ReturnZero:
	ld xhl, 0:i3
	ret
; CmpRealTtlFunc entry
CmpRealTtlFunc:
	cp xbc, EVT_SW_IN
	jr z, CmpRealTtl_MajorDispatch
	cp xbc, EVT_ACTIVATE_STATE
	jrl nz, CmpBk_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jrl c, CmpBk_ReturnZero
	cp xde, 0x6
	jrl ugt, CmpBk_ReturnZero
	add xde, xde
	add xde, CmpRealTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (CmpRealTtl_Dispatch:24)
	jp	t, (xix+de)
; CmpRealTtlFunc title dispatch
CmpRealTtl_Dispatch:
	push	xde	; was .ascii ":;<>"
	push	xhl
	push	xix
	push	xiz
	call	CmpRealTtl_EnterTitle
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	calr	SoundCtrl_SendTempoScaled
	jrl	CmpBk_ReturnZero
; CmpRealTtlFunc_OnTitleActivate: Phase 5 (title activate): calls CmpRealTtl_EnterTitle (its pop/jrl tail is
;   still spelled .ascii).
CmpRealTtlFunc_OnTitleActivate:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpRealTtl_EnterTitle
	.ascii "^\\[Zx—"
	push	sr

; CmpRealTtl major dispatch (5-way)
CmpRealTtl_MajorDispatch:
	ld xwa, xde
	cp xde, 0x84
	jrl z, CmpRealTtl_RhythmVar4
	cp xde, 0x83
	jrl z, CmpRealTtl_RhythmVar3
	cp xde, 0x82
	jrl z, CmpRealTtl_RhythmVar2
	cp xde, 0x81
	jrl z, CmpRealTtl_RhythmVar1
	cp xde, 0x80
	jr z, CmpRealTtl_RhythmVar0
	cp xwa, 0xc
	jrl ugt, CmpBk_ReturnZero
	add xwa, xwa
	add xwa, CmpRealTtl_MajorDispatch_CaseTable
	ld wa, (xwa)
	lda xix, (CmpRealTtl_RhythmVar0:24)
	jp	t, (xix+wa)

; CmpRealTtl rhythm variation 0
CmpRealTtl_RhythmVar0:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 0:i3
	call CmpRealTtl_SelectRecPart
	pop xiz
	pop xix
	pop xhl
	pop xde
	ld xwa, 0xb50019
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001b
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001a
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb50018
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001c
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	jrl CmpBk_DeliverEvent

; CmpRealTtl rhythm variation 1
CmpRealTtl_RhythmVar1:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 1:i3
	call CmpRealTtl_SelectRecPart
	pop xiz
	pop xix
	pop xhl
	pop xde
	ld xwa, 0xb50019
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001b
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001a
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb50018
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001c
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	jrl CmpBk_DeliverEvent

; CmpRealTtl rhythm variation 2
CmpRealTtl_RhythmVar2:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 2:i3
	call CmpRealTtl_SelectRecPart
	pop xiz
	pop xix
	pop xhl
	pop xde
	ld xwa, 0xb50019
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001b
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001a
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb50018
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001c
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	jrl CmpBk_DeliverEvent

; CmpRealTtl rhythm variation 3
CmpRealTtl_RhythmVar3:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 3:i3
	call CmpRealTtl_SelectRecPart
	pop xiz
	pop xix
	pop xhl
	pop xde
	ld xwa, 0xb50019
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001b
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001a
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb50018
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld xwa, 0xb5001c
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	jrl CmpBk_DeliverEvent

; CmpRealTtl rhythm variation 4
CmpRealTtl_RhythmVar4:
	push XDE
	push XHL
	push XIX
	push XIZ
	ld hl, 4:i3
	call CmpRealTtl_SelectRecPart
	pop XIZ
	pop XIX
	pop XHL
	pop XDE
	ld XWA,0x00b50019
	ld XBC,EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 11862043
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 11862042
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 11862040
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 11862044
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	jr	CmpBk_DeliverEvent
CmpRealTtl_MajorDispatch_Case8:
	set	1, (0x3417:16)
	jr	CmpBk_ReturnZero
; CmpRealTtl_MajorDispatch_OnRightRow4Mute: Switch 11 (right side row 4): CmpRealTtl_CycleQuantize, then repaints 0xB5001D.
CmpRealTtl_MajorDispatch_OnRightRow4Mute:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpRealTtl_CycleQuantize
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	xwa, 11862045
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	jr	CmpBk_DeliverEvent
; CmpRealTtl_MajorDispatch_OnRightRow5Solo: Switch 12 (right side row 5): CmpRealTtl_ToggleSolo, then repaints
;   0xB50018..0xB5001C.
CmpRealTtl_MajorDispatch_OnRightRow5Solo:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpRealTtl_ToggleSolo
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	xwa, 11862041
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 11862043
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 11862042
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 11862040
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 11862044
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
CmpBk_DeliverEvent:
	call ApDeliveryEvent

CmpBk_ReturnZero:
	ld xhl, 0:i3
	ret
; CmpOffsetFunc dispatch
CmpOffset_Dispatch:
CmpBkslTtlFunc:
	cp xbc, EVT_SW_IN
	jr z, CmpBkslTtl_Mode1
	cp xbc, EVT_ACTIVATE_STATE
	jrl nz, CmpBksl_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jrl c, CmpBksl_ReturnZero
	cp xde, 0x6
	jrl ugt, CmpBksl_ReturnZero
	add xde, xde
	add xde, CmpBkslTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (CmpBkslTtl_Dispatch:24)
	jp	t, (xix+de)
; CmpBkslTtlFunc title dispatch
CmpBkslTtl_Dispatch:
	push	xde	; was .ascii ":;<>"
	push	xhl
	push	xix
	push	xiz
	call	CmpBkslTtl_Dispatch_Helper
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	jrl	CmpBksl_ReturnZero
CmpBkslTtlFunc_OnTitleActivate:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpBkslTtl_Dispatch_Helper
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	jrl	CmpBksl_ReturnZero
; CmpBkslTtl mode 1
CmpBkslTtl_Mode1:
	cp xde, 0x8c
	jrl z, CmpBkslTtl_ModeDefault
	cp xde, 0xc
	jrl z, CmpBkslTtl_ModeSelect
	cp xde, 0x8b
	jrl z, DrumSlot_Dispatch_Slot6
	cp xde, 0xb
	jrl z, DrumSlot_Dispatch_Slot7
	cp xde, 0x8a
	jrl z, DrumSlot_Dispatch_Slot4
	cp xde, 0xa
	jr z, DrumSlot_Dispatch_Slot5
	cp xde, 0x89
	jr z, DrumSlot_Dispatch_Slot2
	cp xde, 0x9
	jr z, DrumSlot_Dispatch_Slot3_WithMode
	cp xde, 0x88
	jr z, DrumSlot_Dispatch_Slot0
	cp xde, 0x8
	jrl nz, CmpBksl_ReturnZero
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 1:i3
	call DrumSlot_DispatchWrapper
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMBKSL_S
	jrl CmpBksl_ApplyAndReturnZero

DrumSlot_Dispatch_Slot0:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 0:i3
	call DrumSlot_DispatchWrapper
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMBKSL_S
	jrl CmpBksl_ApplyAndReturnZero

DrumSlot_Dispatch_Slot3_WithMode:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 3:i3
	call DrumSlot_DispatchWrapper
	ldw wa, TT_CMBKSL_S
	call UI_ChangeTitleByIndex
	pop xiz
	pop xix
	pop xhl
	pop xde
	jrl CmpBksl_ReturnZero

DrumSlot_Dispatch_Slot2:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 2:i3
	call DrumSlot_DispatchWrapper
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMBKSL_S
	jr CmpBksl_ApplyAndReturnZero

DrumSlot_Dispatch_Slot5:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 5:i3
	call DrumSlot_DispatchWrapper
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMBKSL_S
	jr CmpBksl_ApplyAndReturnZero

DrumSlot_Dispatch_Slot4:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 4:i3
	call DrumSlot_DispatchWrapper
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMBKSL_S
	jr CmpBksl_ApplyAndReturnZero

DrumSlot_Dispatch_Slot7:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 7:i3
	call DrumSlot_DispatchWrapper
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMBKSL_S
	jr CmpBksl_ApplyAndReturnZero

DrumSlot_Dispatch_Slot6:
	push xde
	push xhl
	push xix
	push xiz
	ld hl, 6:i3
	call DrumSlot_DispatchWrapper
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMBKSL_S
	jr CmpBksl_ApplyAndReturnZero

; CmpBkslTtl mode select
CmpBkslTtl_ModeSelect:
	push xde
	push xhl
	push xix
	push xiz
	ldw hl, 0x9
	call DrumSlot_DispatchWrapper
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMBKSL_S
	jr CmpBksl_ApplyAndReturnZero

; CmpBkslTtl mode default
CmpBkslTtl_ModeDefault:
	push xde
	push xhl
	push xix
	push xiz
	ldw hl, 0x8
	call DrumSlot_DispatchWrapper
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMBKSL_S

CmpBksl_ApplyAndReturnZero:
	call UI_ChangeTitleByIndex

CmpBksl_ReturnZero:
	ld xhl, 0:i3
	ret
; CmpBksl_STtlFunc main handler
CmpBkslSTtl_MainHandler:
CmpBksl_STtlFunc:
	cp xbc, EVT_SW_IN
	jr z, CmpBkslSTtl_DirectMode
	cp xbc, EVT_ACTIVATE_STATE
	jrl nz, DisplayFunc_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jrl c, DisplayFunc_ReturnZero
	cp xde, 0x6
	jrl ugt, DisplayFunc_ReturnZero
	add xde, xde
	add xde, CmpBksl_STtlFunc_CaseTable
	ld de, (xde)
	lda xix, (CmpBkslSTtl_Dispatch:24)
	jp	t, (xix+de)
; CmpBksl_STtlFunc title dispatch
CmpBkslSTtl_Dispatch:
	push	xde	; was .ascii ":;<>"
	push	xhl
	push	xix
	push	xiz
CmpBkslSTtl_Dispatch_Code:
	call	CmpBkslSTtl_EnterTitle
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	(GLOBAL_ERROR_CODE:16), 0
	jrl	DisplayFunc_ReturnZero
CmpBksl_STtlFunc_Case3:
	ld	(13396:16), 0
	jrl	DisplayFunc_ReturnZero
CmpBksl_STtlFunc_OnTitleActivate:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpBkslSTtl_EnterTitle
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	jrl	DisplayFunc_ReturnZero
; CmpBkslSTtl direct mode handler (0x80+)
CmpBkslSTtl_DirectMode:
	ld xwa, xde
	cp xde, 0x4
	jrl z, CmpBkslSTtl_FillIn8
	cp xde, 0x3
	jrl z, CmpBkslSTtl_FillIn7
	cp xde, 0x2
	jr z, CmpBkslSTtl_FillIn6
	cp xde, 0x1
	jr z, CmpBkslSTtl_FillIn5
	or xde, xde
	jr z, CmpBkslSTtl_FillIn4
	sub xwa, 0x80
	cp xwa, 0x0
	jrl c, DisplayFunc_ReturnZero
	cp xwa, 0xa
	jrl ugt, DisplayFunc_ReturnZero
	add xwa, xwa
	add xwa, CmpBkslSTtl_DirectMode_CaseTable
	ld wa, (xwa)
	lda xix, (CmpBkslSTtl_FillIn4:24)
	jp	t, (xix+wa)

; CmpBkslSTtl fill-in level 4
CmpBkslSTtl_FillIn4:
	; cpdi8 (0x350c), 0 (v7 patched)
	cp	(0x3454:16), 0
	; jrl nz, DisplayFunc_ReturnZero (v7 displacement)
	jrl	nz, DisplayFunc_ReturnZero
	push xde

	push xhl

	push xix

	push xiz

	ld hl, 4:i3

	call	CmpBkslSTtl_SelectRecPart

	pop xiz

	pop xix

	pop xhl

	pop xde

	ldw wa, TT_CMREAL

	; jrl CmpBk_PostModeChange (v7 displacement)
	jrl	CmpBk_PostModeChange
; CmpBkslSTtl fill-in level 5
CmpBkslSTtl_FillIn5:
	; cpdi8 (0x350c), 0 (v7 patched)
	cp	(0x3454:16), 0
	; jrl nz, DisplayFunc_ReturnZero (v7 displacement)
	jrl	nz, DisplayFunc_ReturnZero
	push xde

	push xhl

	push xix

	push xiz

	ld hl, 5:i3

	; call CmpBkslSTtl_SelectRecPart (v7 addr)
	call	CmpBkslSTtl_SelectRecPart
	pop xiz

	pop xix

	pop xhl

	pop xde

	ldw wa, TT_CMREAL

	; jrl CmpBk_PostModeChange (v7 displacement)
	jrl	CmpBk_PostModeChange
; CmpBkslSTtl fill-in level 6
CmpBkslSTtl_FillIn6:
	; cpdi8 (0x350c), 0 (v7 patched)
	cp	(0x3454:16), 0
	; jrl nz, DisplayFunc_ReturnZero (v7 displacement)
	jrl	nz, DisplayFunc_ReturnZero
	push xde

	push xhl

	push xix

	push xiz

	ld hl, 6:i3

	; call CmpBkslSTtl_SelectRecPart (v7 addr)
	call	CmpBkslSTtl_SelectRecPart
	pop xiz

	pop xix

	pop xhl

	pop xde

	ldw wa, TT_CMREAL

	; jrl CmpBk_PostModeChange (v7 displacement)
	jrl	CmpBk_PostModeChange
; CmpBkslSTtl fill-in level 7
CmpBkslSTtl_FillIn7:
	cp	(0x3454:16), 0x00
	jrl nz, DisplayFunc_ReturnZero
	push XDE
	push XHL
	push XIX
	push XIZ
	ld hl, 7:i3
	call CmpBkslSTtl_SelectRecPart
	pop XIZ
	pop XIX
	pop XHL
	pop XDE
	ldw WA, TT_CMREAL
	jr t, CmpBk_PostModeChange
; CmpBkslSTtl fill-in level 8
CmpBkslSTtl_FillIn8:
	cp	(0x3454:16), 0x00
	jr nz, DisplayFunc_ReturnZero
	push XDE
	push XHL
	push XIX
	push XIZ
	ldw HL, 0x0008
	call CmpBkslSTtl_SelectRecPart
	pop XIZ
	pop XIX
	pop XHL
	pop XDE
	ldw WA, TT_CMREAL
	jr t, CmpBk_PostModeChange
CmpBkslSTtl_DirectMode_Case136:
	cp	(0x3454:16), 0x00
	jr nz, DisplayFunc_ReturnZero
	cp	(SURE_CONFIRM:24), 0
	jr	nz, CmpBkslSTtl_EventPost
	set	2, (0x3415:16)
	ld	(GLOBAL_ERROR_CODE:16), 35
	ldw	wa, TT_MESAGE
	call	UI_InterruptTitleByIndex
	jr	DisplayFunc_ReturnZero
; CmpBkslSTtl post accompaniment event
CmpBkslSTtl_EventPost:
	ld	(13396:16), 1
	ld	xwa, 11665426
	ld	xbc, EVT_SHOW
	ld	xde, 5:i3
	call	ApPostEvent
	jr	DisplayFunc_ReturnZero
CmpBkslSTtl_DirectMode_Case137:
	cp	(13396:16), 0
	jr	nz, DisplayFunc_ReturnZero
	cp	(STYLE_SECTION:16), 12
	jr	nc, DisplayFunc_ReturnZero
	ldw	wa, TT_CMNAME
	jr	CmpBk_PostModeChange
CmpBkslSTtl_DirectMode_Case138:
	cp	(13396:16), 0
	jr	nz, DisplayFunc_ReturnZero
	ldw	wa, TT_CMSET
CmpBk_PostModeChange:
	call UI_ChangeTitleByIndex

DisplayFunc_ReturnZero:
	ld xhl, 0:i3
	ret
; CmpNcpTtlFunc main handler
CmpNcpTtl_MainHandler:
CmpNcpTtlFunc:
	cp xbc, EVT_SW_IN
	jrl z, CmpNcpTtl_SpecialMode7
	cp xbc, EVT_ACTIVATE_STATE
	jrl nz, CmEsy_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jrl c, CmEsy_ReturnZero
	cp xde, 0x6
	jrl ugt, CmEsy_ReturnZero
	add xde, xde
	add xde, CmpNcpTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (CmpNcpTtl_Dispatch:24)
	jp	t, (xix+de)
; CmpNcpTtlFunc title dispatch
CmpNcpTtl_Dispatch:
	push	xde	; was .ascii ":;<>"
	push	xhl
	push	xix
	push	xiz
CmpNcpTtl_Dispatch_Code:
	call	CmpNcpTtl_Dispatch_Helper
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	a, (14792:16)
	cp	a, 1:i3
	jr	z, CmpNcpTtl_Dispatch_Code_Skip
	cp	a, 0:i3
	jrl	nz, CmEsy_ReturnZero
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 2:i3
	call	UI_PostDialValueEvent
	ldw	wa, 130
	jr	CmpNcpTtl_Dispatch_Code_Join
CmpNcpTtl_Dispatch_Code_Skip:
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 6:i3
	call	UI_PostDialValueEvent
	ldw	wa, 134
	jr	CmpNcpTtl_Dispatch_Code_Join
CmpNcpTtlFunc_Case3:
	ld	wa, 0:i3
	call	UI_PostDialEnable
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpNcp_SendProgramChangeOnLeave
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	jrl	CmEsy_ReturnZero
CmpNcpTtlFunc_OnTitleActivate:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpNcpTtl_Dispatch_Helper
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	a, (14792:16)
	cp	a, 1:i3
	jr	z, CmpNcpTtl_Dispatch_Code_Skip2
	cp	a, 0:i3
	jrl	nz, CmEsy_ReturnZero
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 2:i3
	call	UI_PostDialValueEvent
	ldw	wa, 130
	jr	CmpNcpTtl_Dispatch_Code_Join
CmpNcpTtl_Dispatch_Code_Skip2:
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 6:i3
	call	UI_PostDialValueEvent
	ldw	wa, 134
CmpNcpTtl_Dispatch_Code_Join:
	call	UI_PostDialRangeEvent
	jrl	CmEsy_ReturnZero
CmpNcpTtl_SpecialMode7:
	cp xde, 0xb
	jr ule, CmpNcpTtl_TableDispatch
	sub xde, 0x74
	cp xde, 0xc
	jrl c, CmEsy_ReturnZero
	cp xde, 0x13
	jrl ugt, CmEsy_ReturnZero

; CmpNcpTtl table-driven dispatch
CmpNcpTtl_TableDispatch:
	add xde, xde
	add xde, CmpNcpTtl_TableDispatch_CaseTable
	ld de, (xde)
	lda xix, (CmpNcpTtl_Dispatch2:24)
	jp	t, (xix+de)
; CmpNcpTtlFunc title dispatch 2
CmpNcpTtl_Dispatch2:
	; framing ported from v10's source for the same label (same span length, statement for statement); 297 of 450 slots byte-identical
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 0:opc
	call	CmpNcpTtl_Dispatch2_Helper
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	; v10 does not spell this byte either
	cp	(0x39c8:16), 0
	; v10 does not spell this byte either
	jr	z, CmpNcpTtl_Dispatch_Code_Skip3
	ld	(14792:16), 0
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058650
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 2:i3
	call	UI_PostDialValueEvent
	ldw	wa, 130
	call	UI_PostDialRangeEvent
CmpNcpTtl_Dispatch_Code_Skip3:
	ld	xwa, 12058654
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_TableDispatch_Case128:	; cases 128, 129
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	; v10 does not spell this byte either
	push	xde
	; v10 does not spell this byte either
	push	xhl
	; v10 does not spell this byte either
	push	xix
	; v10 does not spell this byte either
	push	xiz
	; v10 does not spell this byte either
	ld	w, 128:opc
	; v10 does not spell this byte either
	call	CmpNcpTtl_Dispatch2_Helper
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	; v10 does not spell this byte either
	cp	(0x39c8:16), 0
	; v10 does not spell this byte either
	jr	z, CmpNcpTtl_Dispatch_Code_Skip4
	ld	(14792:16), 0
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058650
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 2:i3
	call	UI_PostDialValueEvent
	ldw	wa, 130
	call	UI_PostDialRangeEvent
CmpNcpTtl_Dispatch_Code_Skip4:
	ld	xwa, 12058654
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_TableDispatch_Case118:	; cases 118, 119
	ld	wa, 1:i3
	; v10 does not spell this byte either
	call	UI_PostEvent_0x6E
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	push	xde
	; v10 does not spell this byte either
	push	xhl
	; v10 does not spell this byte either
	push	xix
	; v10 does not spell this byte either
	push	xiz
	; v10 does not spell this byte either
	ld	w, 0:opc
	; v10 does not spell this byte either
	call	CmpNcpTtl_Dispatch2_Helper2
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	; v10 does not spell this byte either
	cp	(0x39c8:16), 0
	; v10 does not spell this byte either
	jr	z, CmpNcpTtl_Dispatch_Code_Skip5
	ld	(14792:16), 0
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058650
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 2:i3
	call	UI_PostDialValueEvent
	ldw	wa, 130
	call	UI_PostDialRangeEvent
CmpNcpTtl_Dispatch_Code_Skip5:
	ld	a, (CMPNCP_FROM_ITEM:16)
	cp	a, 2:i3
	jr	z, CmpNcpTtl_Dispatch_Code_Skip7
	cp	a, 1:i3
	jr	z, CmpNcpTtl_Dispatch_Code_Skip6
	cp	a, 0:i3
	jrl	nz, CmEsy_ReturnZero
	ld	xwa, 12058654
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_Dispatch_Code_Skip6:
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_Dispatch_Code_Skip7:
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_TableDispatch_Case130:	; cases 130, 131
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	; v10 does not spell this byte either
	push	xde
	; v10 does not spell this byte either
	push	xhl
	; v10 does not spell this byte either
	push	xix
	; v10 does not spell this byte either
	push	xiz
	; v10 does not spell this byte either
	ld	w, 128:opc
	; v10 does not spell this byte either
	call	CmpNcpTtl_Dispatch2_Helper2
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	; v10 does not spell this byte either
	cp	(0x39c8:16), 0
	; v10 does not spell this byte either
	jr	z, CmpNcpTtl_Dispatch_Code_Skip8
	ld	(14792:16), 0
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058650
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 2:i3
	call	UI_PostDialValueEvent
	ldw	wa, 130
	call	UI_PostDialRangeEvent
CmpNcpTtl_Dispatch_Code_Skip8:
	ld	a, (CMPNCP_FROM_ITEM:16)
	cp	a, 2:i3
	jr	z, CmpNcpTtl_Dispatch_Code_Skip10
	cp	a, 1:i3
	jr	z, CmpNcpTtl_Dispatch_Code_Skip9
	cp	a, 0:i3
	jrl	nz, CmEsy_ReturnZero
	ld	xwa, 12058654
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_Dispatch_Code_Skip9:
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_Dispatch_Code_Skip10:
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_TableDispatch_Case120:	; cases 120, 121
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 0:opc
	call	CmpRecSet_OnRhythmBank_Data_3_Sub
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	; v10 does not spell this byte either
	cp	(0x39c8:16), 1
	; v10 does not spell this byte either
	jr	z, CmpNcpTtl_Dispatch_Code_Skip13
	ld	(14792:16), 1
	ld	xwa, 12058654
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 6:i3
	call	UI_PostDialValueEvent
	ldw	wa, 134
	call	UI_PostDialRangeEvent
CmpNcpTtl_Dispatch_Code_Skip13:
	ld	xwa, 12058650
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_TableDispatch_OnToItemNext:	; cases 132, 133
	push	xde	; four pushes and `ld w, 0x80`, spelled as six .byte lines until 2026-10-06
	push	xhl
	push	xix
	push	xiz
	ld	w, 0x80:opc
	call	CmpRecSet_OnRhythmBank_Data_3_Sub
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	; v10 does not spell this byte either
	cp	(0x39c8:16), 1
	; v10 does not spell this byte either
	jr	z, CmpNcpTtl_Dispatch_Code_Skip14
	ld	(14792:16), 1
	ld	xwa, 12058654
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 6:i3
	call	UI_PostDialValueEvent
	ldw	wa, 134
	call	UI_PostDialRangeEvent
CmpNcpTtl_Dispatch_Code_Skip14:
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058650
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_TableDispatch_OnToValueUp:	; cases 122, 123
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 0:opc
	call	CmpNcpTtl_Dispatch2_Helper3
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	; v10 does not spell this byte either
	cp	(0x39c8:16), 1
	; v10 does not spell this byte either
	jr	z, CmpNcpTtl_Dispatch_Code_Skip15
	ld	(14792:16), 1
	ld	xwa, 12058654
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 6:i3
	call	UI_PostDialValueEvent
	ldw	wa, 134
	call	UI_PostDialRangeEvent
CmpNcpTtl_Dispatch_Code_Skip15:
	ld	a, (CMPNCP_TO_ITEM:16)
	cp	a, 1:i3
	jr	z, CmpNcpTtl_Dispatch_Code_Skip11
	cp	a, 0:i3
	jrl	nz, CmEsy_ReturnZero
	ld	xwa, 12058650
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_Dispatch_Code_Skip11:
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_TableDispatch_OnToValueDown:	; cases 134, 135
	ld	wa, 1:i3
	; v10 does not spell this byte either
	call	UI_PostEvent_0x6E
	; v10 does not spell this byte either
	; v10 does not spell this byte either
	push	xde
	; v10 does not spell this byte either
	push	xhl
	; v10 does not spell this byte either
	push	xix
	; v10 does not spell this byte either
	push	xiz
	; v10 does not spell this byte either
	ld	w, 128:opc
	; v10 does not spell this byte either
	call	CmpNcpTtl_Dispatch2_Helper3
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	; v10 does not spell this byte either
	cp	(0x39c8:16), 1
	; v10 does not spell this byte either
	jr	z, CmpNcpTtl_Dispatch_Code_Skip16
	ld	(14792:16), 1
	ld	xwa, 12058654
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058655
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 6:i3
	call	UI_PostDialValueEvent
	ldw	wa, 134
	call	UI_PostDialRangeEvent
CmpNcpTtl_Dispatch_Code_Skip16:
	ld	a, (CMPNCP_TO_ITEM:16)
	cp	a, 1:i3
	jr	z, CmpNcpTtl_Dispatch_Code_Skip12
	cp	a, 0:i3
	jr	nz, CmEsy_ReturnZero
	ld	xwa, 12058650
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jr	CmpNcpTtl_Dispatch_Code_Join2
CmpNcpTtl_Dispatch_Code_Skip12:
	ld	xwa, 12058651
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12058642
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
CmpNcpTtl_Dispatch_Code_Join2:
	call	ApDeliveryEvent
	jr	CmEsy_ReturnZero
CmpNcpTtl_TableDispatch_Case127:
	set	0, (0x3419:16)	; was four .byte lines
CmEsy_ReturnZero:
	ld xhl, 0:i3
	ret
; CmEsyTtlFunc main handler
CmpEsyTtl_MainHandler:
CmEsyTtlFunc:
	cp xbc, EVT_SW_IN
	jrl z, CmpEsyTtl_Mode1
	cp xbc, EVT_ACTIVATE_STATE
	jrl nz, S2cTtl_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jrl c, S2cTtl_ReturnZero
	cp xde, 0x6
	jrl ugt, S2cTtl_ReturnZero
	add xde, xde
	add xde, CmEsyTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (CmEsyTtl_Dispatch:24)
	jp	t, (xix+de)
; CmEsyTtlFunc title dispatch
CmEsyTtl_Dispatch:
	cp	(PREVIOUS_TITLE:16), 186
	jrl	z, S2cTtl_ReturnZero
	ld	a, (STYLE_SECTION:16)
	cp	a, 29
	jr	ule, CmEsyTtl_Dispatch_Join
	sub	a, 30
	sll	a, 2
	ld	(STYLE_SECTION:16), a
CmEsyTtl_Dispatch_Join:
	or	(0x3710:16), 127
	res	2, (SEQ_RTMCFG:16)
	res	6, (0x3415:16)
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	DrumKit_UpdateStatusFlags_Sub
	call	DrumKit_ValidateBank_Wrap
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	(CMP_SOLO:16), 0
	ld	xwa, 12189706
	ld	xbc, EVT_SET_SELECTED_CEL
	ld	xde, 4294901762
	jrl	CmpEsy_DeliverEventAndCheck
CmEsyTtlFunc_Case3:
	cp	(14081:16), 255
	jrl	z, S2cTtl_ReturnZero
	lda	xiy, (14081:16)
	lda	xix, (14067:16)
	lda	xhl, (14088:16)
	lda	xde, (14074:16)
	ld	xbc, 0:i3
CmEsyTtlFunc_Loop:
	ld	a, (xiy+)
	ld	(xix+), a
	ld	a, (xhl+)
	ld	(xde+), a
	inc	1, xbc
	cp	xbc, 7
	jr	c, CmEsyTtlFunc_Loop
	ldmm8	STYLE_SECTION, 14095
	jrl	S2cTtl_ReturnZero
CmpEsyTtl_Mode1:
	cp xde, 0xb
	jr ule, CmpEsyTtl_Mode2
	sub xde, 0x74
	cp xde, 0xc
	jrl c, S2cTtl_ReturnZero
	cp xde, 0x13
	jrl ugt, S2cTtl_ReturnZero

; CmpEsyTtl mode 2
CmpEsyTtl_Mode2:
	add xde, CmpEsyTtl_Mode2_Table
	ld de, (xde)
	extz de
	sll de, 1
	ld xix, CmpEsyTtl_Mode2_CaseTable
	ld	de, (xix+de)
	lda xix, (CmEsyTtl_Dispatch2:24)
	jp	t, (xix+de)
; CmEsyTtlFunc title dispatch 2
CmEsyTtl_Dispatch2:
	; --- Multi-branch dispatch subroutine (195 bytes) ---
	ld	wa, 0:i3
	jrl t, CmpEsyTtl_SubModeD_Cont
CmpEsyTtl_Mode2_OnEdit:
	push xde
	push xhl
	push xix
	push xiz
	call CmEsyTtl_Dispatch2_Helper2
	call CmpEsy_PrepareRealtimeRecording
	pop xiz
	pop xix
	pop xhl
	pop xde
	ldw wa, TT_CMREAL
	call UI_ChangeTitleByIndex
	jrl t, S2cTtl_ReturnZero
CmpEsyTtl_Mode2_OnMemoryNumberInc:
	ld	wa, 1:i3
	call UI_PostEvent_0x6E
	push xde
	push xhl
	push xix
	push xiz
	ld a, 0x00:opc
	call VoiceSlot_Dispatch_Return
	pop xiz
	pop xix
	pop xhl
	pop xde
	ld xwa, 0x00ba0009
	ld xbc, EVT_PAINT
	ld	xde, 0:i3
	jr t, CmpEsy_DeliverEventAndCheck
CmpEsyTtl_Mode2_OnMemoryNumberDec:
	ld	wa, 1:i3
	call UI_PostEvent_0x6E
	push xde
	push xhl
	push xix
	push xiz
	ld a, 0x80:opc
	call VoiceSlot_Dispatch_Return
	pop xiz
	pop xix
	pop xhl
	pop xde
	ld xwa, 0x00ba0009
	ld xbc, EVT_PAINT
	ld	xde, 0:i3
CmpEsy_DeliverEventAndCheck:
	call	ApDeliveryEvent
	jr	S2cTtl_ReturnZero
CmpEsyTtl_Mode2_Case5:
	cp	(14096:16), 0
	jr	z, CmpEsyTtl_SubModeC
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpEsy_ApplyEdit
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	cp	(GLOBAL_ERROR_CODE:16), 0
	jr	nz, CmpEsyTtl_SubModeD
	lda	xiy, (14067:16)
	lda	xix, (14081:16)
	lda	xhl, (14074:16)
	lda	xde, (14088:16)
	ld	xbc, 0:i3
CmpEsyTtl_SubModeB:
	ld	a, (xiy+)
	ld	(xix+), a
	ld	a, (xhl+)
	ld	(xde+), a
	inc	1, xbc
	cp	xbc, 7
	jr	c, CmpEsyTtl_SubModeB
	ldmm8	14095, STYLE_SECTION
	jr	CmpEsyTtl_SubModeD
CmpEsyTtl_SubModeC:
	push xde
	push xhl
	push xix
	push xiz
	call CmEsyTtl_Dispatch2_Helper2
	pop xiz
	pop xix
	pop xhl
	pop xde
; CmpEsyTtl sub-mode D entry
CmpEsyTtl_SubModeD:
	ld	wa, 0:i3
; CmpEsyTtl sub-mode D continuation
CmpEsyTtl_SubModeD_Cont:
	call UI_PostDialEnable


S2cTtl_ReturnZero:
	ld xhl, 0:i3
	ret
; CmpEsyTtl sub-mode E dispatch
CmpEsyTtl_SubModeE:
S2cTtlFunc:
	cp xbc, EVT_SW_IN
	jrl z, CmpEsyTtl_E_Var1
	cp xbc, EVT_ACTIVATE_STATE
	jrl nz, CstmCp_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jrl c, CstmCp_ReturnZero
	cp xde, 0x6
	jrl ugt, CstmCp_ReturnZero
	add xde, xde
	add xde, S2cTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (S2cTtl_Dispatch:24)
	jp	t, (xix+de)
; S2cTtlFunc title dispatch
S2cTtl_Dispatch:
	; framing ported from v10's source for the same label (same span length, statement for statement); 23 of 34 slots byte-identical
	; differs from v10 here and llvm-objdump cannot read it
	cp	(PREVIOUS_TITLE:16), 185
	jr	z, S2cTtl_Dispatch_Skip
	ld	xwa, 12124193
	ld	xbc, EVT_SET_SELECTED_CEL
	ld	xde, 4294901762
	call	ApDeliveryEvent
S2cTtl_Dispatch_Skip:
	call	S2cTtl_InitOnTitleChange
	jrl	CstmCp_ReturnZero
S2cTtlFunc_Case5:
	ld	a, (14783:16)
	cp	a, 2:i3
	jr	z, S2cTtl_Dispatch_Code_Skip3
	cp	a, 1:i3
	jr	z, S2cTtl_Dispatch_Code_Skip2
	cp	a, 0:i3
	jrl	nz, CstmCp_ReturnZero
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 0:i3
	call	UI_PostDialValueEvent
	ldw	wa, 128
	jr	S2cTtl_Dispatch_Code_Join
S2cTtl_Dispatch_Code_Skip2:
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 1:i3
	call	UI_PostDialValueEvent
	ldw	wa, 129
	jr	S2cTtl_Dispatch_Code_Join
S2cTtl_Dispatch_Code_Skip3:
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 2:i3
	call	UI_PostDialValueEvent
	ldw	wa, 130
S2cTtl_Dispatch_Code_Join:
	call	UI_PostDialRangeEvent
	jrl	CstmCp_ReturnZero
CmpEsyTtl_E_Var1:
	ld xwa, xde
	cp xde, 0x86
	jrl z, CstmCp_ReturnZero
	cp xde, 0x84
	jrl z, CstmCp_ReturnZero
	cp xde, 0x82
	jrl z, S2cTtl_SecondaryHandler
	cp xde, 0x81
	jrl z, S2cTtl_MainHandler
	cp xde, 0x80
	jrl z, CmpEsyTtl_E_Var2
	cp xwa, 0xb
	jrl ugt, CstmCp_ReturnZero
	add xwa, xwa
	add xwa, CmpEsyTtl_E_Var1_CaseTable
	ld wa, (xwa)
	lda xix, (CmpEsy_E_DispatchDataBlock:24)
	jp	t, (xix+wa)

CmpEsy_E_DispatchDataBlock:
	; framing ported from v10's source for the same label (same span length, statement for statement); 26 of 37 slots byte-identical
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	wa, 1:i3
	call	UI_PostDialEnable
	ld	wa, 0:i3
	call	UI_PostDialValueEvent
	ldw	wa, 128
	call	UI_PostDialRangeEvent
	ld	wa, 0:i3
	call	Tempo_AdjustStartMeasure
	; differs from v10 here and llvm-objdump cannot read it
	cp	(0x39bf:16), 0
	jr	nz, S2cTtl_Dispatch_Code_Skip4
	ld	xwa, 12124188
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124191
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jrl	TtlFunc_SendEventAndReturn
S2cTtl_Dispatch_Code_Skip4:
	ld	(14783:16), 0
	ld	xwa, 12124188
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124191
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124184
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124193
	ld	xbc, EVT_CLR_GRID_HANTEN
	ld	xde, 0:i3
	jrl	TtlFunc_SendEventAndReturn
CmpEsyTtl_E_Var2:
	ld wa, 1:i3
	call UI_PostEvent_0x6E
	ld wa, 1:i3
	call UI_PostDialEnable
	ld wa, 0:i3
	call UI_PostDialValueEvent
	ldw WA, 0x0080
	call UI_PostDialRangeEvent
	ld wa, 1:i3
	call Tempo_AdjustStartMeasure
	cp	(0x39bf:16), 0x00
	jr nz, .Lc_f68b9c
	ld XWA,0x00b9001c
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld XWA,0x00b9001f
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	jrl t, TtlFunc_SendEventAndReturn
CmpEsy_E_Var2_StoreMeasure:
.Lc_f68b9c:
	ld	(0x39bf:16), 0x00
	ld XWA,0x00b9001c
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld XWA,0x00b9001f
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld XWA,0x00b90018
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld XWA,0x00b90021
	ld XBC,EVT_CLR_GRID_HANTEN
	ld xde, 0:i3
	jrl t, TtlFunc_SendEventAndReturn
CmpEsyTtl_E_Var1_OnLastMeasureInc:
	ld wa, 1:i3
	call UI_PostEvent_0x6E
	ld wa, 1:i3
	call UI_PostDialEnable
	ld wa, 1:i3
	call UI_PostDialValueEvent
	ldw WA, 0x0081
	call UI_PostDialRangeEvent
	ld wa, 0:i3
	call Tempo_AdjustEndMeasure
	cp	(0x39bf:16), 0x01
	jr nz, CmpEsy_E_EndMeasure_Store
	ld XWA,0x00b9001f
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld XWA,0x00b9001c
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	jrl t, TtlFunc_SendEventAndReturn
CmpEsy_E_EndMeasure_Store:
	ld	(14783:16), 1
	ld	xwa, 12124191
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124188
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124184
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124193
	ld	xbc, EVT_CLR_GRID_HANTEN
	ld	xde, 0:i3
	jrl	TtlFunc_SendEventAndReturn
; S2cTtlFunc main handler
S2cTtl_MainHandler:
	ld wa, 1:i3
	call UI_PostEvent_0x6E
	ld wa, 1:i3
	call UI_PostDialEnable
	ld wa, 1:i3
	call UI_PostDialValueEvent
	ldw WA, 0x0081
	call UI_PostDialRangeEvent
	ld wa, 1:i3
	call Tempo_AdjustEndMeasure
	cp	(0x39bf:16), 0x01
	jr nz, .Lc_f68cae
	ld XWA,0x00b9001f
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld XWA,0x00b9001c
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	jrl t, TtlFunc_SendEventAndReturn
CmpEsy_Main_EndMeasure_Store:
.Lc_f68cae:
	ld	(0x39bf:16), 0x01
	ld XWA,0x00b9001f
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld XWA,0x00b9001c
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld XWA,0x00b90018
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	ld XWA,0x00b90021
	ld XBC,EVT_CLR_GRID_HANTEN
	ld xde, 0:i3
	jrl t, TtlFunc_SendEventAndReturn
CmpEsyTtl_E_Var1_OnTransposeInc:
	ld wa, 1:i3
	call UI_PostEvent_0x6E
	ld wa, 1:i3
	call UI_PostDialEnable
	ld wa, 2:i3
	call UI_PostDialValueEvent
	ldw WA, 0x0082
	call UI_PostDialRangeEvent
	ld wa, 0:i3
	call SeqToComposer_StepTranspose
	cp	(0x39bf:16), 0x02
	jr nz, CmpEsy_Quantize_Store
	ld XWA,0x00b90018
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	jrl t, TtlFunc_SendEventAndReturn
CmpEsy_Quantize_Store:
	ld	(14783:16), 2
	ld	xwa, 12124184
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124191
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124188
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124193
	ld	xbc, EVT_CLR_GRID_HANTEN
	ld	xde, 0:i3
	jrl	TtlFunc_SendEventAndReturn
; S2cTtlFunc secondary handler
S2cTtl_SecondaryHandler:
	ld wa, 1:i3
	call UI_PostEvent_0x6E
	ld wa, 1:i3
	call UI_PostDialEnable
	ld wa, 2:i3
	call UI_PostDialValueEvent
	ldw WA, 0x0082
	call UI_PostDialRangeEvent
	ld wa, 1:i3
	call SeqToComposer_StepTranspose
	cp	(0x39bf:16), 0x02
	jr nz, CmpEsy_SecQuantize_Store
	ld XWA,0x00b90018
	ld XBC,EVT_REPAINT
	ld xde, 0:i3
	jr t, TtlFunc_SendEventAndReturn
CmpEsy_SecQuantize_Store:
	ld	(14783:16), 2
	ld	xwa, 12124184
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124191
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124188
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124193
	ld	xbc, EVT_CLR_GRID_HANTEN
	ld	xde, 0:i3
	jr	TtlFunc_SendEventAndReturn
CmpEsyTtl_E_Var1_OnMemoryNumberInc:
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	wa, 0:i3
	call	SeqToComposer_IncMemoryNo
	ld	xwa, 12124190
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jr	TtlFunc_SendEventAndReturn
CmpEsyTtl_E_Var1_OnMemoryNumberDec:
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	wa, 0:i3
	call	SeqToComposer_DecMemoryNo
	ld	xwa, 12124190
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
TtlFunc_SendEventAndReturn:
	call ApDeliveryEvent
	jr CstmCp_ReturnZero
; CmpEsyTtl_E_Var1_OnOk: Switch 11 is the OK box (ES_Right4, SS_OK) of SEQ TO COMPOSER COPY; it calls
;   Tempo_EditBPM(0), a misnomer.
CmpEsyTtl_E_Var1_OnOk:
	ld wa, 0:i3
	call Tempo_EditBPM

CstmCp_ReturnZero:
	ld xhl, 0:i3
	ret
; CstmCpTtl record dispatch
CstmCpTtl_RecDispatch:
CstmCpTtlFunc:
	cp xbc, EVT_SW_IN
	jrl z, CstmCpTtl_RecMode1
	cp xbc, EVT_ACTIVATE_STATE
	jrl nz, CstmCp_ReturnZero2
	dec 2, xde
	cp xde, 0x0
	jrl c, CstmCp_ReturnZero2
	cp xde, 0x6
	jrl ugt, CstmCp_ReturnZero2
	add xde, xde
	add xde, CstmCpTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (CstmCpTtl_Dispatch:24)
	jp	t, (xix+de)
; CstmCpTtlFunc title dispatch
CstmCpTtl_Dispatch:
	; cpdi8	(0x8d37), 190 (v7 patched)
	cp	(PREVIOUS_TITLE:16), 190
	jr	z, CstmCpTtl_Dispatch_Skip

	; stdi8	(0x3a7e), 0 (v7 patched)
	ld	(CSTMCP_WINDOW:16), 0
	jrl	CstmCp_ReturnZero2

CstmCpTtl_Dispatch_Skip:
	; cpdi8	(0x8d39), 238 (v7 patched)
	cp	(ACTIVE_TITLE_PREVIOUS:16), 238
	jrl	nz, CstmCp_ReturnZero2

	ld	a, (CSTMCP_WINDOW:16)

	cp	a, 2:i3

	jr	z, CstmCpTtl_Dispatch_Join

	cp	a, 1:i3

	jrl	nz, CstmCp_ReturnZero2

CstmCpTtl_Dispatch_Join:
	; cpdi8	(0x39b6), 3 (v7 patched)
	cp	(CSTMCP_FROM_SLOT:16), 3
	jr	nc, CstmCpTtl_Dispatch_Code_Skip

	ld	xwa, 0xbe0011

	ld	xbc, EVT_SHOW

	ld	xde, 5:i3

	jrl	CstmCpTtl_Dispatch2_Code_Join

CstmCpTtl_Dispatch_Code_Skip:
	ld	xwa, 0xbe0019

	ld	xbc, EVT_SHOW

	ld	xde, 5:i3

	jrl	CstmCpTtl_Dispatch2_Code_Join

CstmCpTtlFunc_Case5:
	ld	a, (CSTMCP_WINDOW:16)

	cp	a, 2:i3

	jr	z, CstmCpTtl_Dispatch_Join2

	cp	a, 1:i3

	jrl	nz, CstmCp_ReturnZero2

CstmCpTtl_Dispatch_Join2:
	; cpdi8	(0x39b6), 3 (v7 patched)
	cp	(CSTMCP_FROM_SLOT:16), 3
	jr	nc, CstmCpTtl_Dispatch_Code_Skip2

	ld	xwa, 0xbe0011

	ld	xbc, EVT_SHOW

	ld	xde, 5:i3

	jrl	CstmCpTtl_Dispatch2_Code_Join

CstmCpTtl_Dispatch_Code_Skip2:
	ld	xwa, 0xbe0019

	ld	xbc, EVT_SHOW

	ld	xde, 5:i3

	jrl	t, CstmCpTtl_Dispatch2_Code_Join



; CstmCpTtl record mode 1

CstmCpTtl_RecMode1:
	cp xde, 0xb
	jr ule, CstmCpTtl_RecMode2
	sub xde, 0x74
	cp xde, 0xc
	jrl c, CstmCp_ReturnZero2
	cp xde, 0x13
	jrl ugt, CstmCp_ReturnZero2

; CstmCpTtl record mode 2
CstmCpTtl_RecMode2:
	add xde, xde
	add xde, CstmCpTtl_RecMode2_CaseTable
	ld de, (xde)
	lda xix, (CstmCpTtl_Dispatch2:24)
	jp	t, (xix+de)
; CstmCpTtlFunc title dispatch 2
CstmCpTtl_Dispatch2:
	cp	(CSTMCP_WINDOW:16), 0
	jrl	nz, CstmCp_ReturnZero2
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	c, 29:opc
	ld	a, (CSTMCP_FROM_SLOT:16)
	cp	a, 10
	jr	nc, CstmCpTtlFunc_Skip
	ld	c, 2:opc
CstmCpTtlFunc_Skip:
	cp	a, c
	jrl	nc, CstmCp_ReturnZero2
	inc	1, a
	ld	(CSTMCP_FROM_SLOT:16), a
	ld	xwa, 12451843
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12451844
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	jrl	CstmCpTtlFunc_Join
CstmCpTtl_RecMode2_Case128:	; cases 128, 129
	cp	(CSTMCP_WINDOW:16), 0
	jrl	nz, CstmCp_ReturnZero2
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	c, 10:opc
	ld	a, (CSTMCP_FROM_SLOT:16)
	cp	a, 10
	jr	nc, CstmCpTtlFunc_Skip2
	ld	c, 0:opc
CstmCpTtlFunc_Skip2:
	cp	a, c
	jrl	ule, CstmCp_ReturnZero2
	dec	1, a
	ld	(CSTMCP_FROM_SLOT:16), a
	ld	xwa, 12451843
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12451844
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	jrl	CstmCpTtlFunc_Join
CstmCpTtl_RecMode2_Case119:	; cases 119, 120, 131, 132
	cp	(CSTMCP_WINDOW:16), 0
	jrl	nz, CstmCp_ReturnZero2
	ld	a, (CSTMCP_FROM_SLOT:16)
	ld	c, (CSTMCP_TO_SLOT:16)
	ld	(CSTMCP_FROM_SLOT:16), c
	ld	(CSTMCP_TO_SLOT:16), a
	ld	xwa, 12451843
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12451851
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12451853
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12451854
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12451844
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12451855
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	jrl	CstmCpTtlFunc_Join
CstmCpTtl_RecMode2_Case122:	; cases 122, 123
	cp	(CSTMCP_WINDOW:16), 0
	jrl	nz, CstmCp_ReturnZero2
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	c, 29:opc
	ld	a, (CSTMCP_TO_SLOT:16)
	cp	a, 10
	jr	nc, CstmCpTtlFunc_Skip3
	ld	c, 2:opc
CstmCpTtlFunc_Skip3:
	cp	a, c
	jrl	nc, CstmCp_ReturnZero2
	inc	1, a
	ld	(CSTMCP_TO_SLOT:16), a
	ld	xwa, 12451851
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12451855
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
	jr	CstmCpTtlFunc_Join
CstmCpTtl_RecMode2_Case134:	; cases 134, 135
	cp	(CSTMCP_WINDOW:16), 0
	jrl	nz, CstmCp_ReturnZero2
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	c, 10:opc
	ld	a, (CSTMCP_TO_SLOT:16)
	cp	a, 10
	jr	nc, CstmCpTtlFunc_Skip4
	ld	c, 0:opc
CstmCpTtlFunc_Skip4:
	cp	a, c
	jrl	ule, CstmCp_ReturnZero2
	dec	1, a
	ld	(CSTMCP_TO_SLOT:16), a
	ld	xwa, 12451851
	ld	xbc, EVT_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12451855
	ld	xbc, EVT_DRAW
	ld	xde, 0:i3
CstmCpTtlFunc_Join:
	call	ApDeliveryEvent
	jrl	CstmCp_ReturnZero2
CstmCpTtl_RecMode2_Case125:
	ld	a, (CSTMCP_WINDOW:16)
	cp	a, 2:i3
	jr	z, CstmCpTtlFunc_Skip5
	cp	a, 1:i3
	jrl	nz, CstmCp_ReturnZero2
CstmCpTtlFunc_Skip5:
	ld	wa, 0:i3
	call	CstmCpTtl_ResolvePendingCopy
	cp	l, 1:i3
	jrl	z, CstmCp_ReturnZero2
	cp	l, 0:i3
	jrl	nz, CstmCp_ReturnZero2
	ld	(CSTMCP_WINDOW:16), 0
	ld	xwa, 4294967295
	ld	xbc, EVT_HIDE
	ld	xde, 0:i3
	call	ApPostEvent
	ld	(GLOBAL_ERROR_CODE:16), 35
	ldw	wa, TT_MESAGE
	jrl	CstmCpTtlFunc_Join2
CstmCpTtl_RecMode2_Case127:
	ld	a, (CSTMCP_WINDOW:16)
	cp	a, 2:i3
	jrl	z, CstmCpTtlFunc_Skip10
	cp	a, 1:i3
	jr	z, CstmCpTtlFunc_Skip10
	cp	a, 0:i3
	jrl	nz, CstmCp_ReturnZero2
	cp	(CSTMCP_FROM_SLOT:16), 3
	jr	nc, CstmCpTtlFunc_Skip6
	ld	(GLOBAL_ERROR_CODE:16), 37
	ldw	wa, TT_MESAGE
	call	UI_InterruptTitleByIndex
CstmCpTtlFunc_Skip6:
	ld	a, (CSTMCP_FROM_SLOT:16)
	extz	wa
	ld	c, (CSTMCP_TO_SLOT:16)
	extz	bc
	call	Flash_InitBytecodeBlock
	cp	l, 2:i3
	jr	z, CstmCpTtlFunc_Skip8
	cp	l, 1:i3
	jr	z, CstmCpTtlFunc_Skip7
	cp	l, 0:i3
	jr	nz, CstmCp_ReturnZero2
	ld	(GLOBAL_ERROR_CODE:16), 35
	ldw	wa, TT_MESAGE
	jr	CstmCpTtlFunc_Join2
CstmCpTtlFunc_Skip7:
	ld	(GLOBAL_ERROR_CODE:16), 15
	ldw	wa, TT_MESAGE
	jr	CstmCpTtlFunc_Join2
CstmCpTtlFunc_Skip8:
	ld	xwa, 4294967295
	ld	xbc, EVT_INTERRUPT_EXIT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	cp	(CSTMCP_FROM_SLOT:16), 3
	jr	nc, CstmCpTtlFunc_Skip9
	ld	(CSTMCP_WINDOW:16), 1
	jr	CstmCp_ReturnZero2
CstmCpTtlFunc_Skip9:
	ld	(CSTMCP_WINDOW:16), 2
	ld	xwa, 12451865
	ld	xbc, EVT_SHOW
	ld	xde, 5:i3
CstmCpTtl_Dispatch2_Code_Join:
	call ApPostEvent
	jr t, CstmCp_ReturnZero2
CstmCpTtlFunc_Skip10:
	ld wa, 2:i3
	call CstmCpTtl_ResolvePendingCopy
	cp l, 1:i3
	jr z, CstmCp_ReturnZero2
	cp l, 0:i3
	jr nz, CstmCp_ReturnZero2
	ld	(CSTMCP_WINDOW:16), 0x00
	ld XWA,0xffffffff
	ld XBC,EVT_HIDE
	ld xde, 0:i3
	call ApPostEvent
	ld (GLOBAL_ERROR_CODE:16), 0x23
	ldw WA, TT_MESAGE
CstmCpTtlFunc_Join2:
	call UI_InterruptTitleByIndex
CstmCp_ReturnZero2:
	ld xhl, 0:i3
	ret

CstmCp_StyleDataBlock:
	cp	xbc, EVT_CSTM_CP_OK
	jr	nz, CstmCp_StyleDataBlock_Skip16
	ld	a, (CSTMCP_FROM_SLOT:16)
	extz	wa
	ld	c, (CSTMCP_TO_SLOT:16)
	extz	bc
	call	Flash_InitBytecodeBlock
	cp	l, 2:i3
	jr	z, CstmCp_StyleDataBlock_Skip16
	cp	l, 1:i3
	jr	z, CstmCp_StyleDataBlock_Skip16
	cp	l, 0:i3
	jr	nz, CstmCp_StyleDataBlock_Skip16
	ld	(GLOBAL_ERROR_CODE:16), 35
	ldw	wa, TT_MESAGE
	call	UI_InterruptTitleByIndex
CstmCp_StyleDataBlock_Skip16:
	ld	xhl, 0:i3
	ret

MainCstmNameFunc:
	lda	xsp, (xsp-120)
	push	xiz
	ld	xde, xbc
	ld	xiy, MainCstmNameFunc_LocalInit
	lda	xix, (xsp+4)
	ldw	bc, 60
	ldirw
	cp	xde, EVT_CSTM_T_NM_GET
	jr	z, MainCstmNameFunc_OnCstmTNmGet
	cp	xde, EVT_CSTM_F_NM_GET
	jrl	nz, CstmName_ReturnZero
	pushw	17
	call	Malloc
	ld	xiz, xhl
	ld	a, (CSTMCP_FROM_SLOT:16)
	extz	wa
	sla	wa, 2
	lda	xbc, (xsp+6)
	ld	xwa, (xbc+wa)
	add	xwa, 64
	pushw	13
	push	xwa
	push	xiz
	call	Mem_Copy
	lda	xsp, (xsp+12)
	ld	(xiz+13), 0
	ld	(xiz+14), 0
	ld	(xiz+15), 0
	ld	(xiz+16), 0
	ld	xwa, 12451844
	ld	xbc, EVT_CSTM_F_NM_DISP
	ld	xde, xiz
	call	ApDeliveryEvent
	ld	xwa, 4294967295
	ld	xbc, EVT_AUTO_FREE
	ld	xde, xiz
	jr	CstmName_PostEventAndReturn
MainCstmNameFunc_OnCstmTNmGet:
	pushw 0x11

	call	Malloc

	ld xiz, xhl

	ld	a, (CSTMCP_TO_SLOT:16)

	extz wa

	sla wa, 2

	lda xbc, (xsp + 6)

	ld	xwa, (xbc+wa)

	add xwa, 0x40

	pushw 0xd

	push xwa

	push xiz

	call	Mem_Copy

	lda xsp, (xsp + 12)

	ld (xiz + 13), 0x0

	ld (xiz + 14), 0x0

	ld (xiz + 15), 0x0

	ld (xiz + 16), 0x0

	ld xwa, 0xbe000f

	ld xbc, EVT_CSTM_T_NM_DISP

	ld xde, xiz

	; call ApDeliveryEvent (v7 addr)
	call	ApDeliveryEvent
	ld xwa, 0xffffffff

	ld xbc, EVT_AUTO_FREE

	ld xde, xiz



CstmName_PostEventAndReturn:
	call ApPostEvent

CstmName_ReturnZero:
	ld xhl, 0:i3
	pop xiz
	lda xsp, (xsp + 120)
	ret

MainS2cFunc:
	dec	4, xsp
	ld	(xsp), xde
	ld	xwa, (xsp)
	dec	2, a
	cp	xbc, EVT_S2C_TR_DN
	jr	z, MainS2cFunc_OnS2cTrDn
	cp	xbc, EVT_S2C_TR_UP
	jrl	nz, EventDelivery_ReturnZero
	ld	(0x38d8:16), a
	ld	wa, 0:i3
	call	Tempo_AdjustEffect
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 65536
	ld	xwa, 12124193
	ld	xbc, EVT_REQUEST_GRID_DRAW
	call	ApDeliveryEvent
	cp	(0x39bf:16), 3
	jrl	z, EventDelivery_ReturnZero
	ld	(0x39bf:16), 3
	ld	xwa, 12124188
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124191
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124184
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	jr	S2cFunc_DeliverAndReturn
MainS2cFunc_OnS2cTrDn:
	ld	(0x38d8:16), a
	ld	wa, 1:i3
	call	Tempo_AdjustEffect
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 65536
	ld	xwa, 12124193
	ld	xbc, EVT_REQUEST_GRID_DRAW
	call	ApDeliveryEvent
	cp	(0x39bf:16), 3
	jr	z, EventDelivery_ReturnZero
	ld	(0x39bf:16), 3
	ld	xwa, 12124188
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124191
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ld	xwa, 12124184
	ld	xbc, EVT_REPAINT
	ld	xde, 0:i3
S2cFunc_DeliverAndReturn:
	call ApDeliveryEvent

EventDelivery_ReturnZero:
	ld xhl, 0:i3
	inc 4, xsp
	ret

MiddleNameFunc:
	lda	xwa, (13316:16)
	cp	xbc, EVT_MSP_NAME_SET
	jr	z, MiddleNameFunc_OnMspNameSet
	cp	xbc, EVT_CMP_NAME_SET
	jr	nz, MiddleName_ReturnZero
	push	xde
	push	xwa
	call	Strcpy
	inc	8, xsp
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	RhythmProc_CopySlotData_Wrap
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ldw	wa, TT_CMBKSL_S
	jr	MiddleName_PostModeChange
MiddleNameFunc_OnMspNameSet:
	push	xde
	push	xwa
	call	Strcpy
	inc	8, xsp
	ld	c, (32390:16)
	ld	a, c
	sll	a, 4
	cp	c, 2:i3
	jr	nc, MiddleName_CalcROMAddr_High
	ld	w, 0:opc
	extz	xwa
	add	xwa, 2001536
	jr	MiddleName_CopyAndPost
MiddleName_CalcROMAddr_High:
	sub a, 0x20
	ld w, 0x0:opc
	extz xwa
	add xwa, 0x1e8a40

MiddleName_CopyAndPost:
	pushw	16
	pushw	0
	pushw	13316
	push	xwa
	call	Strncpy
	lda	xsp, (xsp+10)
	ldw	wa, TT_MSPMENU
MiddleName_PostModeChange:
	call UI_ChangeTitleByIndex

MiddleName_ReturnZero:
	ld xhl, 0:i3
	ret

MiddleCmpClrFunc:
	cp	xbc, EVT_CMP_CLR_NO
	jr	z, MiddleCmpClrFunc_OnCmpClrNo
	cp	xbc, EVT_CMP_CLR_YES
	jr	nz, MiddleCmpClr_ReturnZero
	set	2, (0x3415:16)
	ld	(0x3454:16), 0
	ld	xwa, 11665426
	ld	xbc, EVT_HIDE
	ld	xde, 0:i3
	call	ApPostEvent
	ld	(GLOBAL_ERROR_CODE:16), 35
	ldw	wa, TT_MESAGE
	call	UI_InterruptTitleByIndex
	jr	MiddleCmpClr_ReturnZero
MiddleCmpClrFunc_OnCmpClrNo:
	ld	(13396:16), 0
	ld	xwa, 11665426
	ld	xbc, EVT_HIDE
	ld	xde, 0:i3
	call	ApPostEvent
	ld	xwa, 11665408
	ld	xbc, EVT_ALL_PAINT
	ld	xde, 0:i3
	call	ApDeliveryEvent
MiddleCmpClr_ReturnZero:
	ld xhl, 0:i3
	ret
MainCmpCpFunc:
	lda	xsp, (xsp-18)
	push	xiz
	ld	xde, xbc
	ld	xiy, MainCmpCpFunc_LocalInit
	lda	xix, (xsp+10)
	ld	bc, 6:i3
	ldirw
	cp	xde, EVT_RHY_VARI_NM_GET
	jr	z, MainCmpCpFunc_OnRhyVariNmGet
	cp	xde, EVT_RHY_GRP_NM_GET
	jrl	nz, MainCmpSet_Case4
	pushw 17
	call	Malloc
	inc	2, xsp
	ld	xiz, xhl
	ld	xwa, 163840
	call	SndParam_LookupReadOnly
	ld	(xsp+7), l
	ld	xwa, 163841
	call	SndParam_LookupReadOnly
	lda	xwa, (xsp+4)
	ld	(xwa+4), l
	ld	(xwa+2), 72
	call	SndParam_ResolveVoiceEntry
	ld	a, (xsp+4)
	extz	wa
	call	AccVoice_CopyFromROM_Wrap
	extz	xhl
	pushw 16
	push	xhl
	push	xiz
	call	Mem_Copy
	lda	xsp, (xsp+10)
	ld	(xiz+16), 0
	ld	xwa, 12058654
	ld	xbc, EVT_AP_RHY_GRP_NM
	ld	xde, xiz
	call	ApDeliveryEvent
	ld	xwa, 4294967295
	ld	xbc, EVT_AUTO_FREE
	ld	xde, xiz
	jrl	MainCmpSet_Case3
MainCmpCpFunc_OnRhyVariNmGet:
	pushw 15
	call	Malloc
	inc	2, xsp
	ld	xiz, xhl
	ld	xwa, 163840
	call	SndParam_LookupReadOnly
	ld	(xsp+7), l
	ld	xwa, 163841
	call	SndParam_LookupReadOnly
	lda	xwa, (xsp+4)
	ld	(xwa+4), l
	ld	(xwa+2), 72
	call	SndParam_ResolveVoiceEntry
	lda	xbc, (xsp+4)
	ld	a, (xbc)
	extz	wa
	ld	c, (xbc+1)
	extz	bc
	call	AccVoice_DispatchWithChannel
	extz	xhl
	cp	(ACTIVE_TITLE:16), 184
	jr	nz, MemCopy_SetupParams
	lda	xbc, (xsp+4)
	ld	a, (xbc+3)
	cp	a, 128
	jr	c, MemCopy_SetupParams
	cp	(xbc+4), 0
	jr	nz, MemCopy_SetupParams
	res	7, a
	cp	a, 4:i3
	jr	nc, MainCmpCp_ClampRange4
	ld	a, 0:opc
	jr	MainCmpCp_StoreClampResult
MainCmpCp_ClampRange4:
	cp a, 0x8
	jr nc, MainCmpCp_ClampRange8
	ld a, 0x1:opc
	jr MainCmpCp_StoreClampResult

MainCmpCp_ClampRange8:
	ld a, 0x2:opc

MainCmpCp_StoreClampResult:
	pushw 0xd
	extz wa
	sla wa, 2
	lda xbc, (xsp + 12)
	ld	xwa, (xbc+wa)
	push xwa
	jr MainCmpCp_MemCopyAndFinalize

MemCopy_SetupParams:
	pushw 0xd
	push xhl

MainCmpCp_MemCopyAndFinalize:
	push	xiz
	call	Mem_Copy
	lda	xsp, (xsp+10)
	ld	(xiz+13), 0
	ld	a, (ACTIVE_TITLE:16)
	cp	a, 184
	jr	nz, MainCmpSet_Init
	ld	xwa, 12058655
	ld	xbc, EVT_AP_RHY_VARI_NM
	ld	xde, xiz
	jr	MainCmpSet_Case1
; MainCmpSetFunc init
MainCmpSet_Init:
	cp a, 0xdc
	jr nz, MainCmpSet_Init_Join
	ld xwa, 0xdc0002
	ld xbc, EVT_AP_RHY_VARI_NM
	ld xde, xiz

; MainCmpSetFunc case 1
MainCmpSet_Case1:
	call ApDeliveryEvent

; MainCmpSetFunc case 2
MainCmpSet_Init_Join:
	ld xwa, 0xffffffff
	ld xbc, EVT_AUTO_FREE
	ld xde, xiz

; MainCmpSetFunc case 3
MainCmpSet_Case3:
	call ApPostEvent

; MainCmpSetFunc case 4
MainCmpSet_Case4:
	ld xhl, 0:i3
	pop xiz
	lda xsp, (xsp + 18)
	ret
; CmpSongTtlFunc main handler
CmpSong_MainHandler:
MainCmpSetFunc:
	dec	4, xsp
	ld	(xsp), xde
	ld	a, (STYLE_SECTION:16)
	extz	wa
	sla	wa, 2
	lda	xde, (RhythmTiming_OffsetTable:24)
	ld	xhl, 608352
	add	xhl, (xde+wa)
	ld	xde, xhl
	ld	xhl, xbc
	ld	xwa, (xsp)
	ld	c, a
	sub	xhl, EVT_PAN_UP
	cp	xhl, 0
	jrl	lt, CmpSong_VariantA
	cp	xhl, 7
	jrl	gt, CmpSong_VariantA
	add	xhl, xhl
	add	xhl, MainCmpSetFunc_CaseTable
	ld	hl, (xhl)
	lda	xix, (MainCmpSet_Dispatch:24)
	jp	t, (xix+hl)
; MainCmpSetFunc dispatch
MainCmpSet_Dispatch:
	ld	xwa, (xsp)
	sll	xwa, 3
	add	xwa, 16
	add	xwa, xde
	inc	2, xwa
	ld	c, (xwa)
	cp	c, 127
	jrl	nc, CmpSong_VariantA
	inc	1, c
	ld	(xwa), c
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 65536
	ld	xwa, 11796494
	ld	xbc, EVT_REQUEST_GRID_DRAW
	jrl	MainCmpSetFunc_Join
MainCmpSetFunc_OnPanDn:
	ld	xwa, (xsp)
	sll	xwa, 3
	add	xwa, 16
	add	xwa, xde
	inc	2, xwa
	ld	c, (xwa)
	cp	c, 0:i3
	jrl	z, CmpSong_VariantA
	dec	1, c
	ld	(xwa), c
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 65536
	ld	xwa, 11796494
	ld	xbc, EVT_REQUEST_GRID_DRAW
	jrl	MainCmpSetFunc_Join
MainCmpSetFunc_OnRlmtUp:
	ld	xwa, (xsp)
	sll	xwa, 3
	add	xwa, 16
	add	xwa, xde
	inc	5, xwa
	ld	c, (xwa)
	cp	c, 11
	jrl	nc, CmpSong_VariantA
	inc	1, c
	ld	(xwa), c
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 131072
	ld	xwa, 11796494
	ld	xbc, EVT_REQUEST_GRID_DRAW
	jrl	MainCmpSetFunc_Join
MainCmpSetFunc_OnRlmtDn:
	ld	xwa, (xsp)
	sll	xwa, 3
	add	xwa, 16
	add	xwa, xde
	inc	5, xwa
	ld	c, (xwa)
	cp	c, 0:i3
	jrl	z, CmpSong_VariantA
	dec	1, c
	ld	(xwa), c
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 131072
	ld	xwa, 11796494
	ld	xbc, EVT_REQUEST_GRID_DRAW
	jr	MainCmpSetFunc_Join
MainCmpSetFunc_OnCmpSetP1Up:
	ld	a, c
	ld	(13448:16), c
	cp	c, 2:i3
	jr	ule, MainCmpSetFunc_Skip
	dec	2, a
	ld	(13448:16), a
MainCmpSetFunc_Skip:
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 0:opc
	call	CmpRecSet_DispatchCursorRow
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 65536
	ld	xwa, 11796487
	ld	xbc, EVT_REQUEST_GRID_DRAW
	jr	MainCmpSetFunc_Join
MainCmpSetFunc_OnCmpSetP1Dn:
	ld	a, c
	ld	(13448:16), c
	cp	c, 2:i3
	jr	ule, MainCmpSetFunc_Skip2
	dec	2, a
	ld	(13448:16), a
MainCmpSetFunc_Skip2:
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	w, 128:opc
	call	CmpRecSet_DispatchCursorRow
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 65536
	ld	xwa, 11796487
	ld	xbc, EVT_REQUEST_GRID_DRAW
MainCmpSetFunc_Join:
	call	ApDeliveryEvent
CmpSong_VariantA:
	ld xhl, 0:i3
	inc 4, xsp
	ret

MainEsCmpFunc:
	dec	4, xsp
	ld	(xsp), xde
	ld	xde, (xsp)
	ld	a, e
	dec	2, a
	cp	xbc, EVT_ES_CMP_VARI_DN
	jrl	z, MainEsCmpFunc_OnEsCmpVariDn
	cp	xbc, EVT_ES_CMP_VARI_UP
	jrl	z, MainEsCmpFunc_OnEsCmpVariUp
	cp	xbc, EVT_ES_CMP_STYL_DN
	jr	z, MainEsCmpFunc_OnEsCmpStylDn
	cp	xbc, EVT_ES_CMP_STYL_UP
	jrl	nz, EsCmp_ReturnZero
	ld	(14592:16), a
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	a, 0:opc
	call	DrumParam_ProcessChannel
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	wa, de
	extz	xde
	add	xde, 65536
	ld	xwa, 12189706
	ld	xbc, EVT_REQUEST_GRID_DRAW
	call	ApDeliveryEvent
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 131072
	ld	xwa, 12189706
	ld	xbc, EVT_REQUEST_GRID_DRAW
	jrl	MspBksl_EventDeliver
MainEsCmpFunc_OnEsCmpStylDn:
	ld	(14592:16), a
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	a, 128:opc
	call	DrumParam_ProcessChannel
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 65536
	ld	xwa, 12189706
	ld	xbc, EVT_REQUEST_GRID_DRAW
	call	ApDeliveryEvent
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 131072
	ld	xwa, 12189706
	ld	xbc, EVT_REQUEST_GRID_DRAW
	jr	MspBksl_EventDeliver
MainEsCmpFunc_OnEsCmpVariUp:
	ld	(14592:16), a
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	a, 0:opc
	call	DrumParam_ProcessChannelAlt
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 131072
	ld	xwa, 12189706
	ld	xbc, EVT_REQUEST_GRID_DRAW
	jr	MspBksl_EventDeliver
MainEsCmpFunc_OnEsCmpVariDn:
	ld	(14592:16), a
	push	xde
	push	xhl
	push	xix
	push	xiz
	ld	a, 128:opc
	call	DrumParam_ProcessChannelAlt
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ld	xwa, (xsp)
	ld	de, wa
	extz	xde
	add	xde, 131072
	ld	xwa, 12189706
	ld	xbc, EVT_REQUEST_GRID_DRAW
MspBksl_EventDeliver:
	call ApDeliveryEvent

EsCmp_ReturnZero:
	ld xhl, 0:i3
	inc 4, xsp
	ret

MspBkslTtlFunc:
	ld xhl, 0:i3
	ret

MainMspBnkNameFunc:
	ld xhl, 0:i3
	ret

SoundCtrl_SendAccTempo:
	; cpdi8 (0x8d38), 181 (v7 patched)
	cp	(ACTIVE_TITLE:16), 181
	ret nz

	ld xwa, 0xb5001e

	ld xbc, EVT_PAINT

	ld xde, 0:i3

	; call ApDeliveryEvent (v7 addr)
	call	ApDeliveryEvent
	ret



SoundCtrl_SendTempoScaled:
	; cpdi8 (0x8d38), 181 (v7 patched)
	cp	(ACTIVE_TITLE:16), 181
	ret nz

	calr SoundCtrl_CalcScaledTempo

	ld xwa, 0xb50002

	ld xbc, EVT_PAINT

	ld xde, 0:i3

	; call ApDeliveryEvent (v7 addr)
	call	ApDeliveryEvent
	ret



SoundCtrl_CalcScaledTempo:
	ld	xhl, 100
	ld	bc, (STYLE_FREE_BLOCKS:16)
	extz	xbc
	ld	xwa, xhl
	call	Math_Multiply32
	ld	xwa, xhl
	ld	xbc, 190
	call	Math_DivideU32
	cp	xhl, 99
	jr	ule, SoundCtrl_CalcTempo_Clamp
	ld	xhl, 99
SoundCtrl_CalcTempo_Clamp:
	ld	(14579:16), l
	ret
AccGuard_ProgramChangeCheck:
	ld	c, (SWBTWR_PAYLOAD_2:16)
	ld	a, (SWBTWR_PAYLOAD_1:16)
	cp	a, 5:i3
	jr	nz, AccGuard_CheckMode09
	cp	(SWBTWR_PAYLOAD_3:16), 0
	jr	z, AccGuard_CheckMode09
	cp	c, 2:i3
	ret	nz
	jr	AccGuard_SendProgramChange
AccGuard_CheckMode09:
	cp a, 0x09

	ret nz

	.byte	0xc1, 0xbf, 0xbf, 0x3f, 0x00	; cpdi8	(0xc07f), 0 (v7 patched)

	ret z

	cp c, 0x40

	ret nz

	ld a, (CURRENT_TITLE:16)

	cp a, 0xcb

	ret z

	cp a, 0xcc

	ret z

	ldw wa, TT_MSPBKSL

	call	UI_InterruptTitleByIndex

	ret

AccGuard_SendProgramChange:
	ld	xwa, 163968
	call	SndParam_LookupReadOnly
	cp	hl, 0:i3
	ret	z
	ldw	wa, TT_APCSEL
	call	UI_InterruptTitleByIndex
	ret
AccSeq_DeliverC9_0009:
	; cpdi8 (0x8d38), 201 (v7 patched)
	cp	(ACTIVE_TITLE:16), 201
	ret nz

	ld xwa, 0xc90009

	ld xbc, EVT_PAINT

	ld xde, 0:i3

	; call ApDeliveryEvent (v7 addr)
	call	ApDeliveryEvent
	ret



AccSeq_DeliverC9_000A:
	; cpdi8 (0x8d38), 201 (v7 patched)
	cp	(ACTIVE_TITLE:16), 201
	ret nz

	ld xwa, 0xc9000a

	ld xbc, EVT_PAINT

	ld xde, 0:i3

	; call ApDeliveryEvent (v7 addr)
	call	ApDeliveryEvent
	ret


MainMspRgpSetFunc:
	ld	a, (0x7e85:16)
	sll	a, 4
	ld	w, 0:opc
	extz	xwa
	add	xwa, 2001408
	ld	xiy, xwa
	ld	ix, de
	extz	xix
	ld	xhl, xix
	add	xhl, 65536
	ld	xwa, xde
	add	xwa, xwa
	ld	xde, xix
	add	xde, 131072
	dec	4, xwa
	ld	xix, xwa
	add	xix, xiy
	lda	xwa, (xix+1)
	cp	xbc, EVT_RGP_PAD_DN
	jr	z, MainMspRgpSetFunc_OnRgpPadDn
	cp	xbc, EVT_RGP_PAD_UP
	jr	z, MspMenuTtl_Init
	cp	xbc, EVT_RGP_BNK_DN
	jr	z, MainMspRgpSetFunc_OnRgpBnkDn
	cp	xbc, EVT_RGP_BNK_UP
	jrl	nz, AccBass_ReturnZero
	cp	(0x7e53:16), 0
	jr	nz, AccBass_ReturnZero
	ld	xbc, xix
	ld	a, (xix)
	cp	a, 14
	jr	nc, AccBass_ReturnZero
	inc	1, a
	ld	(xbc), a
	ld	xwa, 13369347
	ld	xbc, EVT_REQUEST_GRID_DRAW
	ld	xde, xhl
	jr	AccBass_EventDeliver
MainMspRgpSetFunc_OnRgpBnkDn:
	cp	(0x7e53:16), 0
	jr	nz, AccBass_ReturnZero
	ld	xbc, xix
	ld	a, (xix)
	cp	a, 0:i3
	jr	z, AccBass_ReturnZero
	dec	1, a
	ld	(xbc), a
	ld	xwa, 13369347
	ld	xbc, EVT_REQUEST_GRID_DRAW
	ld	xde, xhl
	jr	AccBass_EventDeliver
; MspMenuTtlFunc init
MspMenuTtl_Init:
	cp	(0x7e53:16), 0
	jr	nz, AccBass_ReturnZero
	ld	xbc, xwa
	ld	a, (xwa)
	cp	a, 5:i3
	jr	nc, AccBass_ReturnZero
	inc	1, a
	ld	(xbc), a
	ld	xwa, 13369347
	ld	xbc, EVT_REQUEST_GRID_DRAW
	jr	AccBass_EventDeliver
; MspMenuTtlFunc case 1
MainMspRgpSetFunc_OnRgpPadDn:
	cp	(0x7e53:16), 0
	jr	nz, AccBass_ReturnZero
	ld	xbc, xwa
	ld	a, (xwa)
	cp	a, 0:i3
	jr	z, AccBass_ReturnZero
	dec	1, a
	ld	(xbc), a
	ld	xwa, 13369347
	ld	xbc, EVT_REQUEST_GRID_DRAW
AccBass_EventDeliver:
	call ApDeliveryEvent

AccBass_ReturnZero:
	ld xhl, 0:i3
	ret
MspMenuTtlFunc:
	cp xbc, EVT_ACTIVATE_STATE
	jr nz, MspNameTtl_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jr c, MspNameTtl_ReturnZero
	cp xde, 0x6
	jr ugt, MspNameTtl_ReturnZero
	add xde, xde
	add xde, MspMenuTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (MspMenuTtl_Dispatch:24)
	jp	t, (xix+de)
; MspMenuTtlFunc title dispatch
MspMenuTtl_Dispatch:
	ld	xwa, 165888
	call	SndParam_LookupReadOnly
	cp	l, 13
	jr	c, MspMenuTtl_Dispatch_Skip
	cp	l, 16
	jr	ule, MspMenuTtl_Dispatch_Skip2
MspMenuTtl_Dispatch_Skip:
	ld	l, 0:opc
	jr	MspMenuTtlFunc_Join
MspMenuTtl_Dispatch_Skip2:
	sub	l, 13
MspMenuTtlFunc_Join:
	ld	(32390:16), l
	ld	a, l
	sll	a, 4
	cp	l, 2:i3
	jr	nc, MspMenuTtl_Dispatch_Skip3
	ld	w, 0:opc
	extz	xwa
	add	xwa, 2001536
	jr	MspMenuTtlFunc_Join2
MspMenuTtl_Dispatch_Skip3:
	sub	a, 32
	ld	w, 0:opc
	extz	xwa
	add	xwa, 2001472
MspMenuTtlFunc_Join2:
	pushw	16
	push	xwa
	pushw	0
	pushw	13316
	call	Strncpy
	lda	xsp, (xsp+10)
	ld	(13332:16), 0
MspNameTtl_ReturnZero:
	ld xhl, 0:i3
	ret
; MspNameTtlFunc mode 1
MspNameTtl_Mode1:
MspNameTtlFunc:
	cp xbc, EVT_ACTIVATE_STATE
	jr nz, MspRecMode_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jr c, MspRecMode_ReturnZero
	cp xde, 0x6
	jr ugt, MspRecMode_ReturnZero
	add xde, xde
	add xde, MspNameTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (MspNameTtl_Dispatch:24)
	jp	t, (xix+de)
; MspNameTtlFunc title dispatch
MspNameTtl_Dispatch:
	; cpdi8	(0x8d37), 203 (v7 patched)
	cp	(PREVIOUS_TITLE:16), 203
	jr	z, MspNameTtl_Dispatch_Join

	ld	c, (32390:16)

	add	c, 13

	extz	bc

	ld	xwa, 0x028800

	ld	de, 0:i3

	; call	SoundParam_NotifyChange (v7 addr)
	call	SoundParam_NotifyChange
MspNameTtl_Dispatch_Join:
	; cpdi8	(0x8d37), 204 (v7 patched)
	cp	(PREVIOUS_TITLE:16), 204
	jr	z, MspRecMode_ReturnZero

	ld	xwa, 0xcc0003

	ld	xbc, EVT_SET_SELECTED_CEL

	ld	xde, 0xffff0002

	; call	ApDeliveryEvent (v7 addr)
	call	ApDeliveryEvent
MspRecMode_ReturnZero:
	ld xhl, 0:i3
	ret
; MspNameTtlFunc mode 2
MspNameTtl_Mode2:
MspRecModeFunc:
	cp xbc, EVT_ACTIVATE_STATE
	jr nz, MspNameTtl_Mode4
	cp xde, 0x1
	jr z, MspNameTtl_Mode3
	or xde, xde
	jr nz, MspNameTtl_Mode4

; MspNameTtlFunc mode 3
MspNameTtl_Mode3:
	ld	(32339:16), 0
; MspNameTtlFunc mode 4
MspNameTtl_Mode4:
	ld xhl, 0:i3
	ret
; MspNameTtlFunc mode 5
MspNameTtl_Mode5:
MspRecTtlFunc:
	cp xbc, EVT_MSP_PLY_MD_SET
	jrl z, MspRecTtl_SubA
	cp xbc, EVT_ACTIVATE_STATE
	jrl nz, MspRecTtl_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jrl c, MspRecTtl_ReturnZero
	cp xde, 0x6
	jrl ugt, MspRecTtl_ReturnZero
	add xde, xde
	add xde, MspRecTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (MspRecTtl_Dispatch:24)
	jp	t, (xix+de)
; MspRecTtlFunc title dispatch
MspRecTtl_Dispatch:
	; framing ported from v10's source for the same label (same span length, statement for statement); 21 of 30 slots byte-identical
	; differs from v10 here and llvm-objdump cannot read it
	cp	(PREVIOUS_TITLE:16), 201
	jr	z, MspRecTtl_Dispatch_Code_Skip2
	ld	xwa, 164099
	ld	bc, 0:i3
	ld	de, 3:i3
	call	SoundParam_NotifyChange
	ld	xwa, 165888
	call	SndParam_LookupReadOnly
	cp	l, 13
	jr	z, MspRecTtl_Dispatch_Code_Skip
	cp	l, 14
	jr	nz, MspRecTtl_Dispatch_Code_Skip2
MspRecTtl_Dispatch_Code_Skip:
	ld	a, (32348:16)
	sll	a, 4
	ld	w, 0:opc
	extz	xwa
	add	xwa, 2000928
	ld	a, (xwa)
	and	a, 16
	srl	a, 4
	ld	(32391:16), a
MspRecTtl_Dispatch_Code_Skip2:
	ld	wa, 0:i3
	call	UI_PostDialEnable
	jr	MspRecTtl_ReturnZero
MspRecTtlFunc_Case3:
	cp	(CURRENT_TITLE:16), 201
	jr	z, MspRecTtl_ReturnZero
	; differs from v10 here and llvm-objdump cannot read it
	cp	(0x7e53:16), 0
	jr	z, MspRecTtl_ReturnZero
	ld	(32339:16), 0
	jr	MspRecTtl_ReturnZero
; MspRecTtlFunc sub-handler A
MspRecTtl_SubA:
	ld	xwa, 165888
	call	SndParam_LookupReadOnly
	cp	l, 13
	jr	z, MspRecTtl_SubA_CheckRange
	cp	l, 14
	jr	nz, MspRecTtl_ReturnZero
MspRecTtl_SubA_CheckRange:
	ld	a, (32348:16)

	sll a, 4

	ld w, 0x0:opc

	extz xwa

	add xwa, 0x1e8820

	ld	c, (32391:16)

	and c, 0x1

	sll c, 4

	resm 4, (xwa)

	or (xwa), c



MspRecTtl_ReturnZero:
	ld xhl, 0:i3
	ret

AccSeq_PostEvent9E_Enable:
	ld xwa, 0xffffffff
	ld xbc, EVT_SET_NOT_DRAW_FLAG
	ld xde, 1:i3
	jp ApPostEvent

AccSeq_PostEvent9E_Disable:
	ld xwa, 0xffffffff
	ld xbc, EVT_SET_NOT_DRAW_FLAG
	ld xde, 0:i3
	jp ApPostEvent
AccSeq_DcModeDataBlock:
	.byte	0xc1, 0x80
AccSeq_DcModeDataBlock_Code:
	xor	(xix+63), d
	ret	nz
	ld	xwa, 14417925
	ld	xbc, EVT_PARA_DRAW
	ld	xde, 0:i3
	call	ApDeliveryEvent
	ret	
; SndArgTtlFunc sub-handler A
SndArgTtl_SubA:
SndArgModeFunc:
	cp xbc, EVT_ACTIVATE_STATE
	jr nz, AccStyle_ExitReturn
	cp xde, 0x1
	jr z, SndArgTtl_SubB
	or xde, xde
	jr nz, AccStyle_ExitReturn
	push xde
	push xhl
	push xix
	push xiz
	call AccStyle_ModeEnter_Wrap
	pop xiz
	pop xix
	pop xhl
	pop xde
	jr AccStyle_ExitReturn

; SndArgTtlFunc sub-handler B
SndArgTtl_SubB:
	push xde
	push xhl
	push xix
	push xiz
	call AccStyle_ModeExit_Wrap
	pop xiz
	pop xix
	pop xhl
	pop xde

AccStyle_ExitReturn:
	ld xhl, 0:i3
	ret
; SndArgTtlFunc sub-handler C
SndArgTtl_SubC:
SndArgTtlFunc:
	cp xbc, EVT_ACTIVATE_STATE
	jr nz, SndArgTtl_ReturnZero
	dec 2, xde
	cp xde, 0x0
	jr c, SndArgTtl_ReturnZero
	cp xde, 0x6
	jr ugt, SndArgTtl_ReturnZero
	add xde, xde
	add xde, SndArgTtlFunc_CaseTable
	ld de, (xde)
	lda xix, (SndArgTtl_Dispatch:24)
	jp	t, (xix+de)
; SndArgTtlFunc title dispatch
SndArgTtl_Dispatch:
	; cpdi8	(0x8d37), 220 (v7 patched)
	cp	(PREVIOUS_TITLE:16), 220
	jr	z, SndArgTtl_Dispatch_Skip

	ld	xwa, 0xdc0005

	ld	xbc, EVT_SET_SELECTED_CEL

	ld	xde, 0xffff0002

	; call	ApDeliveryEvent (v7 addr)
	call	ApDeliveryEvent
SndArgTtl_Dispatch_Skip:
	push	xde

	push	xhl

	push	xix

	push	xiz

	; call	AccStyle_InlinedBlock (v7 addr)
	call	AccStyle_InlinedBlock
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
SndArgTtl_ReturnZero:
	ld xhl, 0:i3
	ret

SndArgNmGet:
	lda	xsp, (xsp-76)
	push	qiz
	ld	(xsp+70), xde
	ld	(xsp+74), xbc
	ld	xiy, SndArgNmGet_PtrTable
	lda	xix, (xsp+66)
	ldiw
	ldiw
	ld	xiy, SndArgNmGet_PtrTable_2
	lda	xix, (xsp+58)
	ld	bc, 4:i3
	ldirw
	ld	xiy, SndArgNmGet_Bytes5
	lda	xix, (xsp+52)
	ld	bc, 2:i3
	ldirw
	ldi85
	ld	xiy, SndArgNmGet_RamPtrsA
	lda	xix, (xsp+32)
	ldw	bc, 10
	ldirw
	ld	xiy, SndArgNmGet_RamPtrsB
	lda	xix, (xsp+12)
	ldw	bc, 10
	ldirw
	ld	xwa, 163840
	call	SndParam_LookupReadOnly
	ld	(xsp+9), l
	ld	xwa, 163841
	call	SndParam_LookupReadOnly
	lda	xwa, (xsp+6)
	ld	(xwa+4), l
	ld	(xwa+2), 72
	call	SndParam_ResolveVoiceEntry
	ldw	(xsp+2), 0
	ld	(xsp+4), 0
	jr	SndArgNm_CheckChannelDone
SndArgNm_ChannelLoop:
	ld a, (xsp + 4)
	call AccVoice_GetChannelCount_Wrap
	ldfr_berp L, 0xfb
	inc1b_erp 0xfb
	ldto_berp A, 0xfb
	extz wa
	add (xsp + 2), wa
	incm8 1, (xsp + 4)

SndArgNm_CheckChannelDone:
	lda xbc, (xsp + 6)
	ld xde, (xsp + 70)
	dec 2, xde
	ld xhl, (xsp + 70)
	add xhl, xhl
	ld a, (xsp + 4)
	cp a, (xbc)
	jr c, SndArgNm_ChannelLoop
	ld a, (xbc + 1)
	extz wa
	add (xsp + 2), wa
	ld wa, (xsp + 2)
	mul wa, 0xa
	extz xwa
	add xwa, 0x1e7810
	ld xix, xwa
	lda xwa, (xsp + 52)
	ld (xsp + 2), xwa
	dec 4, xhl
	ld xwa, (xsp + 74)
	cp xwa, EVT_SET_PT_SEL
	jrl z, SndArgNm_CheckChannelDone_OnSetPtSel
	add xhl, xix
	cp xwa, EVT_ARG_CHO_GET
	jrl z, SndArgNm_CheckChannelDone_OnArgChoGet
	cp xwa, EVT_ARG_TONE_NM_GET
	jrl nz, SndArgNm_ReturnZero
	ld xix, xhl
	ld a, (xhl)
	ldfr_berp A, 0xfb
	ld xiy, xde
	or xde, xde
	jr nz, SndArgNm_ProcessEntry
	or_erpb 0xfb, 0xf0

SndArgNm_ProcessEntry:
	lda xde, (xbc + 3)

	ldto_berp A, 0xfb

	ld (xde), a

	ld a, (xix + 1)

	res 7, a

	ldfr_berp A, 0xfb

	lda xhl, (xbc + 4)

	ldto_berp A, 0xfb

	ld (xhl), a

	ld xwa, (xsp + 2)

	add xwa, xiy

	ld a, (xwa)

	ldfr_berp A, 0xfb

	ld (xbc + 2), a

	ld xwa, (xsp + 70)

	dec 2, a

	ldfr_berp A, 0xfb

	ld a, (xde)

	extz wa

	ld c, (xhl)

	extz bc

	ldto_berp E, 0xfb

	extz de

	sla de, 2

	lda xhl, (xsp + 32)

	ld	xde, (xhl+de)

	call	SndParam_ApplyProgramChangeAsync

	ldto_berp A, 0xfb

	extz wa

	sla wa, 2

	lda xbc, (xsp + 32)

	ld	xwa, (xbc+wa)

	ld (xwa + 16), 0x0

	ld xwa, (xsp + 70)

	ld de, wa

	extz xde

	add xde, 0x10000

	ld xwa, 0xdc0005

	ld xbc, EVT_ARG_TONE_NM_DISP

	; jrl SndArgNm_DeliverAndReturn (v7 displacement)
	jrl	SndArgNm_DeliverAndReturn
SndArgNm_CheckChannelDone_OnArgChoGet:
	or	xde, xde
	jr	nz, SndArgNm_HandleEvent21_Copy
	pushw	3
	ld	xwa, (xsp+68)
	push	xwa
	pushw	0
	pushw	14636
	call	Mem_Copy
	lda	xsp, (xsp+10)
	ld	(14639:16), 0
	jr	SndArgNm_DeliverEvent
SndArgNm_HandleEvent21_Copy:
	ld a, (xhl + 1)

	and a, 0x80

	srl a, 7

	ldfr_berp A, 0xfb

	ld xwa, (xsp + 70)

	ld e, a

	dec 2, e

	pushw 0x3

	ldto_berp A, 0xfb

	extz wa

	sla wa, 2

	lda xbc, (xsp + 60)

	ld	xwa, (xbc+wa)

	push xwa

	extz de

	sla de, 2

	lda xbc, (xsp + 18)

	ld	xwa, (xbc+de)

	push xwa

	call	Mem_Copy

	lda xsp, (xsp + 10)

	ldto_berp A, 0xfb

	extz wa

	sla wa, 2

	lda xbc, (xsp + 12)

	ld	xwa, (xbc+wa)

	ld (xwa + 3), 0x0



SndArgNm_DeliverEvent:
	ld xwa, (xsp + 70)
	ld de, wa
	extz xde
	add xde, 0x20000
	ld xwa, 0xdc0005
	ld xbc, EVT_ARG_CHO_DISP

SndArgNm_DeliverAndReturn:
	call ApDeliveryEvent
	jr SndArgNm_ReturnZero

SndArgNm_CheckChannelDone_OnSetPtSel:
	ld	xwa, (xsp+2)
	add	xwa, xde
	ld	(PART_SELECT), (xwa)
	ld	e, (PART_SELECT:16)
	extz	de
	pushw	255
	ldw	wa, 144
	ldw	bc, 16
	call	AddswbWr
	ldmm8	13015, SNDARG_PART_SELECT
SndArgNm_ReturnZero:
	ld xhl, 0:i3
	popw_erp 0xfa
	lda xsp, (xsp + 76)
	ret

CmpStepTitleFunc:
	lda xsp, (xsp - 16)
	ld xhl, xbc
	ld xiy, CmpStepTitleFunc_ProcTable
	ld xix, xsp
	ldw bc, 0x8
	ldirw
	lda xwa, (xsp)
	ld xbc, xhl
	call DirmdEmulator
	lda xsp, (xsp + 16)
	ret

CmpStepTitle_OnPaint:
	cp	(PREVIOUS_TITLE:16), 182
	jr	z, CmpStepTitle_OnPaint_Draw
	ldw	wa, 255
	call	GraphicsRender_ByteData
	ldw	wa, 245
	call	Display_SetBackgroundColor
	call	Display_LoadFixedPaletteBands
	ldw	wa, 255
	call	Display_FillPaletteBandFromEntry
CmpStepTitle_OnPaint_Draw:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpStep_DrawScreen
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ret
; CmpStepTitle_OnHide: CmpStepTitleFunc_ProcTable[1], which DirmdEmulator calls on EVT_HIDE: CmpStep_OnHide with
;   XDE/XHL/XIX/XIZ preserved.
CmpStepTitle_OnHide:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpStep_OnHide
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ret
; CmpStepTitle_OnSwitchIn: CmpStepTitleFunc_ProcTable[2], which DirmdEmulator calls on EVT_SW_IN: CmpStep_DispatchSwitch
;   with XDE/XHL/XIX/XIZ preserved.
CmpStepTitle_OnSwitchIn:
	push	xde
	push	xhl
	push	xix
	push	xiz
	call	CmpStep_DispatchSwitch
	pop	xiz
	pop	xix
	pop	xhl
	pop	xde
	ret
; CmpStepTitle_Method3Nop: CmpStepTitleFunc_ProcTable[3], a lone `ret`; DirmdEmulator calls only methods 0-2.
CmpStepTitle_Method3Nop:
	ret
AccAudio_LockAcquire:
	ldw wa, 0x8
	jp Kernel_SemaWait

AccAudio_LockRelease:
	ldw wa, 0x8
	jp Kernel_SemaSignal
AccAudio_DataBlock1:
	ld	xwa, xiy
	ld	xbc, xix
	call	GraphicsRender_ProcessEntries
	ret

AccGraphics_RenderStart:
	push xwa
	push xbc
	ld xwa, xiy
	ld xbc, xix
	call GraphicsRender_Start
	pop xbc
	pop xwa
	ret

AccGraphics_DataBlock2:
	push	xwa
	ld	xwa, xiy
	call	ColorBlit_WithPaletteSave
	pop	xwa
	ret

AccDraw_Init:
	push xwa
	ld xwa, xiy
	call DrawFunc_Init
	pop xwa
	ret

AccDraw_Secondary:
	push xwa
	ld xwa, xiy
	call DrawText_ExtendedLayout
	pop xwa
	ret
AccScreen_DataBlock:
	push	xwa
	ld	xwa, xiy
	pop	xwa
	ret
	push	xwa
	ld	xwa, xiy
	call	SeGfx_BoundOp06_PrintWord
	pop	xwa
	ret
; AccGraphics_BoundOp04: Draws one bound display record of op 04 at XIY: ColorBlit_Variant_ByteData colour-blits the
;   {text cell, width, height} entry of the record's rectangle list that the masked and shifted RAM byte selects (in
;   the current COLORBLIT_MODE); XWA preserved. The Composer screens' copy of the SeGfx_BoundOp0N single-record
;   wrappers, beside AccDraw_Init (op 00), AccDraw_Secondary (op 02) and AccGraphics_DataBlock2 (op 03). Basis:
;   callers + body -- the TT_CMSTEP draw functions pass it a single op-04 record: AccScreen_DataBlock_Data_6 (RAM
;   0x391D) in AccScreen_DataBlock_Code2 and CmpStep_NoteEntryAreaBand in AccDraw_StepArticulation_Wrap.
AccGraphics_BoundOp04:
	push	xwa
	ld	xwa, xiy
	call	ColorBlit_Variant_ByteData
	pop	xwa
	ret
CmpStep_DrawScreen:
	push	xiz
	calr	AccDraw_Secondary_Helper7
	pop	xiz
	ret
AccDraw_Secondary_Helper7:
	cp	(PREVIOUS_TITLE:16), 182
	jr	z, AccDraw_Secondary_Skip9
	call	AccPlayback_InitOrUpdate
	ld	(13421:16), 182
	and	(0xe2f6:16), 239
	and	(0xe2f4:16), 239
AccDraw_Secondary_Skip9:
	call	AccDraw_Secondary_Helper
	bit	4, (0xe2f6:16)
	jr	nz, CmpStep_SetupAndQueueDraw_Skip2
	ld	xwa, AccScreen_DataBlock_Code
	push	xwa
	call	DrawFunc_StackEntry
	inc	4, xsp
CmpStep_SetupAndQueueDraw_Skip2:
	ld	xwa, AccScreen_DataBlock_Code2
	push	xwa
	call	DrawFunc_StackEntry
	inc	4, xsp
	ret
AccScreen_DataBlock_Code:
	calr	AccScreen_DrawWall
	ld	(COLORBLIT_MODE:24), 2
	ld	xiy, AccScreen_DataBlock_Data_2
	ld	xix, CmpStep_NoteEntryFrameRecords
	calr	AccAudio_DataBlock1
	calr	AccDraw_Secondary_Helper11
	calr	AccDraw_Secondary_Helper12
	calr	AccDraw_Secondary_Helper17
	ret
AccScreen_DataBlock_Code2:
	calr	AccDraw_Secondary_Helper10
	ld	(COLORBLIT_MODE:24), 1
	ld	xiy, AccScreen_DataBlock_Data_6
	calr	AccGraphics_BoundOp04
	calr	AccDraw_Secondary_Helper17
	ld	(COLORBLIT_MODE:24), 0
	calr	AccScreen_SelectorToWidgetIndex
	ldmm8	14595, STYLE_SECTION
	ldmm8	14596, 13962
	ldmm8	14597, 13963
	ldmm8	14598, 13964
	ldmm8	14599, 13965
	ldmm8	14600, SQSTEP_MEASURE
	ld	xiy, CmpStep_ValueFieldRecords
	ld	xix, CmpStep_NoteEntryAreaBand
	calr	AccGraphics_RenderStart
	ld	(COLORBLIT_MODE:24), 0
	ldmm8	14595, CMP_STEP_MODE
	ld	xiy, AccScreen_DataBlock_Data_7
	calr	AccDraw_Secondary
	calr	AccDraw_Secondary_Helper14
	calr	AccDraw_Secondary_Helper18
	calr	AccDraw_Secondary_Helper16
	calr	AccScreen_RefreshScreen
	ret
CmpStep_OnHide:
	push	xiz
	calr	CmpStep_UnblockSustainInput
	pop	xiz
	ret
CmpStep_UnblockSustainInput:
	call	CmpStep_ClearSustainBlockFlag
	ret
; CmpStep_DispatchSwitch: Body of the CmpStep title's switch-in method: dispatches switch number HL (0..15; W carries
;   the switch's bit 7) to its handler in AccDraw_SecondarySub_Handlers through AccDraw_Secondary_Sub, preserving XIZ.
;   Basis: callers + body -- its only caller is entry 2 (EVT_SW_IN) of CmpStepTitleFunc_ProcTable, the stub at
;   0xF69F35.
CmpStep_DispatchSwitch:
	push	xiz
	calr	CmpStep_CallSwitchHandler
	pop	xiz
	ret
; CmpStep_CallSwitchHandler: Calls the TT_CMSTEP switch handler for switch HL: XIX = AccDraw_SecondarySub_Handlers,
;   then AccDraw_Secondary_Sub (only HL <= 15; XDE = AccDraw_IndexBitMask[HL + 1], clears (0xE31C) bit 0, calls entry
;   HL & 31). Basis: callers + body -- its only caller is CmpStep_DispatchSwitch, the XIZ-preserving body of method 2
;   (EVT_SW_IN) of CmpStepTitleFunc_ProcTable.
CmpStep_CallSwitchHandler:
	ld	xix, AccDraw_SecondarySub_Handlers
	calr	AccDraw_Secondary_Sub
	ret
AccDraw_SecondarySub_Handlers:
	; AccDraw_Secondary_Sub calls entry (L & 31) with XBC = the index and XDE = its
	; AccDraw_IndexBitMask word; it returns first for an HL above 15, so entries 16..19
	; (four one-byte `ret`s) are not reached that way.  Was decoded as `.byte` / `nop` /
	; `jr z, -90` / `jrl z, -2394` ... fragments.
	.long	AccDraw_SecondarySub_Handler00
	.long	AccDraw_SecondarySub_Handler01
	.long	AccDraw_SecondarySub_Handler02
	.long	AccDraw_SecondarySub_Handler03
	.long	AccDraw_SecondarySub_Handler04
	.long	AccDraw_SecondarySub_Handler05
	.long	AccDraw_SecondarySub_Handler06
	.long	AccDraw_SecondarySub_Handler07
	.long	AccDraw_SecondarySub_Handler08
	.long	AccDraw_SecondarySub_Handler09
	.long	AccDraw_SecondarySub_Handler10
	.long	AccDraw_SecondarySub_Handler11
	.long	AccDraw_SecondarySub_Handler12
	.long	AccDraw_SecondarySub_Handler13
	.long	AccDraw_SecondarySub_Handler14
	.long	AccDraw_SecondarySub_Handler15
	.long	AccDraw_SecondarySub_Handler16
	.long	AccDraw_SecondarySub_Handler17
	.long	AccDraw_SecondarySub_Handler18
	.long	AccDraw_SecondarySub_Handler19
AccDraw_Secondary_Sub:
	cp	hl, 15
	jr	ugt, AccDraw_Secondary_Return
	ld	e, l
	inc	1, e
	calr	AccDraw_Secondary_Helper9
	and	(0xe2f8:16), 254
	ld	xbc, xhl
	and	l, 31
	sla	l, 2
	ld	xix, (xix+l)
	call	(xix)
AccDraw_Secondary_Return:
	ret
AccDraw_Secondary_Helper9:
	push	xix
	cp	e, 32
	jr	ule, AccDraw_Secondary_Helper9_Skip
	xor	e, e
AccDraw_Secondary_Helper9_Skip:
	sla	e, 2
	ld	xix, AccDraw_IndexBitMask
	ld	xde, (xix+e)
	pop	xix
	ret
AccDraw_IndexBitMask:
	; Word n = 0 for n = 0, else 1 << (n - 1): 33 words.  AccDraw_Secondary_Sub_Helper reads
	; word (index + 1), or word 0 for an index above 31.
	.long	0x00000000, 0x00000001, 0x00000002, 0x00000004
	.long	0x00000008, 0x00000010, 0x00000020, 0x00000040
	.long	0x00000080, 0x00000100, 0x00000200, 0x00000400
	.long	0x00000800, 0x00001000, 0x00002000, 0x00004000
	.long	0x00008000, 0x00010000, 0x00020000, 0x00040000
	.long	0x00080000, 0x00100000, 0x00200000, 0x00400000
	.long	0x00800000, 0x01000000, 0x02000000, 0x04000000
	.long	0x08000000, 0x10000000, 0x20000000, 0x40000000
	.long	0x80000000
AccDraw_SecondarySub_Handler00:
	bit	7, w
	jr	nz, AccDraw_SecondarySub_Handler00_Skip
	or	(0x365b:16), 64
	jr	AccDraw_SecondarySub_Handler00_Return
AccDraw_SecondarySub_Handler00_Skip:
	or	(0x365b:16), 128
AccDraw_SecondarySub_Handler00_Return:
	ret
AccDraw_SecondarySub_Handler01:
	cp	(CMP_STEP_MODE:16), 4
	jr	nz, AccDraw_Secondary_Sub_Return2
	or	(0xe2f8:16), 8
	bit	7, w
	jr	nz, AccDraw_SecondarySub_Handler01_Skip
	or	(0x3675:16), 4
	jr	AccDraw_Secondary_Sub_Return2
AccDraw_SecondarySub_Handler01_Skip:
	or	(0x3675:16), 8
AccDraw_Secondary_Sub_Return2:
	ret
AccDraw_SecondarySub_Handler02:
	cp	(CMP_STEP_MODE:16), 4
	jr	nz, AccDraw_Secondary_Sub_Return3
	or	(0xe2f8:16), 8
	bit	7, w
	jr	nz, AccDraw_SecondarySub_Handler02_Skip
	or	(0x3675:16), 1
	jr	AccDraw_Secondary_Sub_Return3
AccDraw_SecondarySub_Handler02_Skip:
	or	(0x3675:16), 2
AccDraw_Secondary_Sub_Return3:
	ret
AccDraw_SecondarySub_Handler03:
	or	(0xe2f8:16), 8
	call	AccDraw_StepNoteValue_Wrap
	ld	xwa, AccScreen_DataBlock_Code4
	push	xwa
	call	DrawFunc_StackEntry
	inc	4, xsp
	ret
AccScreen_DataBlock_Code4:
	ld	(COLORBLIT_MODE:24), 0
	calr	AccScreen_BeatDataBlock
	ret
AccDraw_SecondarySub_Handler04:
	or	(0xe2f8:16), 8
	call	AccDraw_AdjustPlusNoteValue
	ld	xwa, AccScreen_DataBlock_Code5
	push	xwa
	call	DrawFunc_StackEntry
	inc	4, xsp
	ret
AccScreen_DataBlock_Code5:
	ld	(COLORBLIT_MODE:24), 0
	calr	AccScreen_BeatDataBlock
	ret
AccDraw_SecondarySub_Handler05:
	or	(0xe2f8:16), 8
	call	AccDraw_StepArticulation_Wrap
	cp	(CMP_STEP_MODE:16), 4
	jr	nz, AccDraw_SecondarySub_Handler05_Return
	ld	xwa, AccScreen_DataBlock_Code6
	push	xwa
	call	DrawFunc_StackEntry
	inc	4, xsp
AccDraw_SecondarySub_Handler05_Return:
	ret
AccScreen_DataBlock_Code6:
	ld	(COLORBLIT_MODE:24), 0
	ldmm8	0x3903, STEP_ARTICULATION
	ld	xiy, AccDraw_Secondary_Entry_Data
	calr	AccDraw_Secondary
	ret
AccDraw_SecondarySub_Handler06:
	or	(0xe2f8:16), 8
	or	(0x365b:16), 2
	and	(0x365b:16), 254
	ret
AccDraw_SecondarySub_Handler07:
	or	(0xe2f8:16), 8
	or	(0x365b:16), 1
	and	(0x365b:16), 253
	ret
AccDraw_SecondarySub_Handler08:
	or	(0xe2f8:16), 8
	bit	7, w
	jr	nz, AccDraw_SecondarySub_Handler08_Return
	bit	3, (CMP_RECORD_PART:16)
	jr	nz, AccDraw_SecondarySub_Handler08_Return
	call	CmpStep_MoveRecPartTowardBass
	or	(0xe2f6:16), 16
AccDraw_SecondarySub_Handler08_Return:
	ret
AccDraw_SecondarySub_Handler09:
	or	(0xe2f8:16), 8
	bit	7, w
	jr	nz, AccDraw_SecondarySub_Handler09_Return
	bit	4, (CMP_RECORD_PART:16)
	jr	nz, AccDraw_SecondarySub_Handler09_Return
	call	CmpStep_MoveRecPartTowardDrums
	or	(0xe2f6:16), 16
AccDraw_SecondarySub_Handler09_Return:
	ret
AccDraw_SecondarySub_Handler10:
	bit	7, w
	jr	nz, AccDraw_SecondarySub_Handler10_Return
	or	(0x365b:16), 32
AccDraw_SecondarySub_Handler10_Return:
	ret
AccDraw_SecondarySub_Handler11:
	bit	7, w
	jr	nz, AccDraw_SecondarySub_Handler11_Return2
	or	(0x365b:16), 4
AccDraw_SecondarySub_Handler11_Return2:
	ret
AccDraw_SecondarySub_Handler12:
	ret
AccDraw_SecondarySub_Handler13:
	ret
AccDraw_SecondarySub_Handler14:
	ret
AccDraw_SecondarySub_Handler15:
	bit	7, w
	jr	nz, AccDraw_SecondarySub_Handler15_Return3
	ld	(0xe2f2:16), 181
	ld	(0xe2f4:16), 128
	jr	AccDraw_SecondarySub_Handler15_Return3
AccDraw_SecondarySub_Handler15_Return3:
	ret
AccDraw_SecondarySub_Handler16:
	ret
AccDraw_SecondarySub_Handler17:
	ret
AccDraw_SecondarySub_Handler18:
	ret
AccDraw_SecondarySub_Handler19:
	ret
AccDraw_Secondary_Helper10:
	ld	(COLORBLIT_MODE:24), 2
	cp	(CMP_STEP_MODE:16), 4
	jr	nz, AccDraw_Secondary_Skip
	ld	xiy, CmpStep_NoteEntryFrameRecords
	ld	xix, CmpStep_ValueFieldRecords
	calr	AccAudio_DataBlock1
	jr	AccDraw_Secondary_Return9
AccDraw_Secondary_Skip:
	ld	xiy, CmpStep_NoteEntryAreaBand
	calr	AccGraphics_BoundOp04
AccDraw_Secondary_Return9:
	ret
AccDraw_Secondary_Helper11:
	xor	wa, wa
	ld	xiy, AccDraw_Secondary_Sub_Entry2_Data_2
	ld	xix, xiy
	ld	a, 35:opc
	ld	c, (13958:16)
	mul	wa, c
	extz	xwa
	add	xix, xwa
	calr	AccAudio_DataBlock1
	ret
AccDraw_Secondary_Helper12:
	ld	xiy, AccDraw_Secondary_Sub_Entry2_Data_3
	ld	c, (13958:16)
	calr	AccDraw_Secondary_Helper13
	ld	xiy, AccDraw_Secondary_Sub_Entry2_Data_4
	ld	c, (13959:16)
	calr	AccDraw_Secondary_Helper13
	ld	xiy, AccDraw_Secondary_Sub_Entry2_Data_5
	ld	c, (13960:16)
	calr	AccDraw_Secondary_Helper13
	ld	xiy, AccDraw_Secondary_Sub_Entry2_Data_6
	ld	c, (13961:16)
	calr	AccDraw_Secondary_Helper13
	ret
AccDraw_Secondary_Helper13:
	xor	wa, wa
	ld	xix, xiy
	add	xix, 10
	ld	a, 20:opc
	mul	wa, c
	cp	a, 0:i3
	jr	z, AccDraw_Secondary_Return10
	extz	xwa
	add	xix, xwa
	calr	AccAudio_DataBlock1
AccDraw_Secondary_Return10:
	ret
AccDraw_Secondary_Helper14:
	ld	xiy, 13942
	ld	xix, 2601
	xor	de, de
AccDraw_Secondary_Join:
	xor	bc, bc
	ld	xiz, 13958
	xor	wa, wa
	ld	a, e
	extz	xwa
	add	xiz, xwa
	ld	d, (xiz)
	cp	d, 0:i3
	jr	z, AccDraw_Secondary_Skip4
	push	xwa
	push	xhl
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	call	AccAudio_LockAcquire
	pop	xiz
	pop	xiy
	pop	xix
	pop	xde
	pop	xbc
	pop	xhl
	pop	xwa
AccDraw_Secondary_Loop:
	xor	hl, hl
	ld	l, c
	ld	l, (xiy+hl)
	and	l, 15
	calr	AccDraw_Secondary_Helper15
	add	xix, 4
	xor	hl, hl
	ld	l, c
	ld	l, (xiy+hl)
	and	l, 240
	srl	l, 4
	calr	AccDraw_Secondary_Helper15
	add	xix, 4
	inc	1, c
	cp	c, d
	jr	c, AccDraw_Secondary_Loop
	push	xwa
	push	xhl
	push	xbc
	push	xde
	push	xix
	push	xiy
	push	xiz
	call	AccAudio_LockRelease
	pop	xiz
	pop	xiy
	pop	xix
	pop	xde
	pop	xbc
	pop	xhl
	pop	xwa
AccDraw_Secondary_Skip4:
	inc	1, e
	cp	e, 4:i3
	jr	ge, AccDraw_Secondary_Return6
	add	xiy, 4
	ld	a, 8:opc
	mul	wa, c
	extz	xwa
	sub	xix, xwa
	add	xix, 1200
	jrl	AccDraw_Secondary_Join
AccDraw_Secondary_Return6:
	ret
AccDraw_Secondary_Helper15:
	push	xiy
	push	xix
	pushw	de
	pushw	bc
	ld	xiy, AccDraw_Secondary_Sub_Entry2_Data
	ld	bc, 4:i3
	ld	a, 6:opc
	ld	xwa, 14612
	ld	(xwa), 6
	ld	(xwa+1), 8
	ld	(xwa+2), ix
	extz	hl
	extz	xhl
	sll	xhl, 2
	add	xiy, xhl
	ld	l, (xiy+)
	ld	(xwa+4), l
	ld	l, (xiy+)
	ld	(xwa+5), l
	ld	l, (xiy+)
	ld	(xwa+6), l
	ld	l, (xiy)
	ld	(xwa+7), l
	call	SeGfx_StaticOp06_CellTextFont0
	popw	bc
	popw	de
	pop	xix
	pop	xiy
	ret
AccDraw_Secondary_Helper16:
	xor	wa, wa
	ld	a, (SQSTEP_CURSOR_STEP:16)
	cp	a, 0:i3
	jr	z, AccDraw_Secondary_Skip5
	dec	1, a
AccDraw_Secondary_Skip5:
	and	a, 127
	ld	c, 32:opc
	div	wa, c
	ld	(14593:16), a
	sla	wa, 1
	xor	xhl, xhl
	ld	l, w
	ld	xiy, AccDraw_Secondary_Sub_Entry2_Data_7
	add	xiy, xhl
	ld	bc, (xiy)
	ld	(14604:16), bc
	add	bc, 6
	ld	(14608:16), bc
	xor	xhl, xhl
	ld	l, a
	ld	xiy, AccDraw_Secondary_Sub_Entry2_Data_8
	add	xiy, xhl
	ld	bc, (xiy)
	ld	(14606:16), bc
	add	bc, 8
	ld	(14610:16), bc
	ld	a, 5:opc
	push	xwa
	ld	xwa, 14602
	call	SeGfx_StaticOp05_FillBoxMode1
	pop	xwa
	ret
AccDraw_Secondary_Helper17:
	xor	wa, wa
	ld	a, (SQSTEP_CURSOR_STEP:16)
	cp	a, 0:i3
	jr	z, AccDraw_Secondary_Skip6
	dec	1, a
AccDraw_Secondary_Skip6:
	and	a, 127
	ld	c, 32:opc
	div	wa, c
	ld	(14593:16), a
	ret
AccDraw_Secondary_Helper18:
	ld	(COLORBLIT_MODE:24), 0
	cp	(CMP_STEP_MODE:16), 4
	jr	z, AccDraw_Secondary_Skip7
	calr	AccScreen_DrawMeasureDetail
	jr	AccDraw_Secondary_Return12
AccDraw_Secondary_Skip7:
	ld	a, (STEP_VELOCITY:16)
	cp	a, 255
	jr	z, AccDraw_Secondary_Skip8
	calr	AccScreen_DrawTempoDisplay
	calr	AccScreen_UpdateBeatDisplay
AccDraw_Secondary_Skip8:
	calr	AccScreen_BeatDataBlock
	ldmm8	14595, STEP_ARTICULATION
	ld	xiy, AccDraw_Secondary_Entry_Data
	calr	AccDraw_Secondary
AccDraw_Secondary_Return12:
	ret
AccScreen_DrawTempoDisplay:
	calr AccScreen_CalcTempoParams
	ld xiy, AccScreen_DrawTempoDisplay_Data
	ld xix, AccScreen_DrawTempoDisplay_Data_2
	calr AccGraphics_RenderStart
	ret

AccScreen_CalcTempoParams:
	xor	wa, wa
	ld	a, (STEP_NOTE:16)
	ld	l, 12:opc
	divs	wa, l
	ld	(14592:16), w
	ld	(14594:16), a
	ret
AccScreen_UpdateBeatDisplay:
	ldmm8	0x3903, STEP_VELOCITY
	ld XIY,AccScreen_DrawTempoDisplay_Data_2
	push XWA
	ld XWA,XIY
	call SeGfx_StaticOp06_CellTextFont0
	pop XWA
	cp	(STEP_VELOCITY:16), 0x63
	jr ugt, AccScreen_BeatDisplay_Large
	ld XIY,AccScreen_UpdateBeatDisplay_Data
	jr t, AccScreen_BeatDisplay_Draw
AccScreen_BeatDisplay_Large:
	ld xiy, AccScreen_BeatDisplay_Large_Data

AccScreen_BeatDisplay_Draw:
	calr AccDraw_Init
	ret

AccScreen_BeatDataBlock:
	cp	(CMP_STEP_MODE:16), 4
	jr	nz, AccScreen_BeatDataBlock_Code_Return
	ldmm8	14595, STEP_NOTE_VALUE
	ldmm8	14596, STEP_PLUS_NOTE_VALUE
	ld	xiy, AccScreen_BeatDataBlock_DisplayList
	ld	xix, AccDraw_Secondary_Entry_Data
	calr	AccGraphics_RenderStart
AccScreen_BeatDataBlock_Code_Return:
	ret	
AccScreen_DrawInit_StackWrap:
	ld xwa, AccScreen_DrawInit_Body
	push xwa
	call DrawFunc_StackEntry
	inc 4, xsp
	ret

AccScreen_DrawInit_Body:
	ld (COLORBLIT_MODE:24), 0x00
	calr AccScreen_DrawTempoDisplay
	ret

AccScreen_UpdateBeat_StackWrap:
	ld xwa, AccScreen_UpdateBeat_Body
	push xwa
	call DrawFunc_StackEntry
	inc 4, xsp
	ret

AccScreen_UpdateBeat_Body:
	ld (COLORBLIT_MODE:24), 0x00
	calr AccScreen_UpdateBeatDisplay
	ret

AccScreen_DrawMeasure_StackWrap:
	ld xwa, AccScreen_DrawMeasure_Body
	push xwa
	call DrawFunc_StackEntry
	inc 4, xsp
	ret

AccScreen_DrawMeasure_Body:
	ld (COLORBLIT_MODE:24), 0x00
	calr AccScreen_DrawMeasureDetail
	ret

AccScreen_DrawMeasureDetail:
	ld	a, (CONTROL_LINE_KIND:16)
	dec 1,A
	ld	(0x3902:16), a
	ld XIY,AccScreen_DrawMeasureDetail_Data
	calr AccDraw_Secondary
	ld	a, (CONTROL_LINE_VALUE:16)
	ld	(0x3902:16), a
	cp	(CONTROL_LINE_KIND:16), 0x03
	jr nz, AccScreen_DrawMeas_Other
	ld	a, (CONTROL_LINE_VALUE:16)
	cp a, 0:i3
	jr z, AccScreen_DrawMeas_Variant3
	ld	(0x3902:16), 0x01
AccScreen_DrawMeas_Variant3:
	ld xiy, AccScreen_DrawMeas_Variant3_Data
	calr AccDraw_Secondary
	jr AccScreen_DrawMeas_Return

AccScreen_DrawMeas_Other:
	ld xiy, AccScreen_DrawMeas_Other_Data
	calr AccDraw_Init

AccScreen_DrawMeas_Return:
	ret

AccScreen_UIDataBlock:
; ** v7 PORT 2026-09-25 (lane accomp) of the v10 typing below.  Was one verbatim
; ROM slice (includes/romslices/v7_block_accscreen_uidatablock.bin).  v7's block is
; the SAME 2,096-byte object as v10's: 66 bytes differ and every one is a RAM
; variable id (v7 = v10 - 0x9C), a ROM pointer (v7 = v10 - 0x404) or a call
; target (v7 = v10 - 0x40D) -- scripts/converters/lane_accomp_v7_uidatablock.py
; --diff lists them, and the same script generated this text by walking v10's
; statements over v7's bytes.  ADDRESSES QUOTED IN THE COMMENTS BELOW ARE v9/v10
; ADDRESSES (subtract 0x404 for v7); the byte values in the directives are v7's.
; Accompaniment engine screen data block
; Total: 2096 bytes (698 + 15 + 120 + 15 + 6 + 287 + 955)
; Screen data blocks compiled from C source, included as .incbin

; Accompaniment step recording UI data: 698 bytes
; ** RE-FRAMED 2026-08-30 (lane B4). Was CODE territory. It is the first 698
; bytes of AccScreen_UIDataBlock, which the header above already documents as a
; 2096-byte screen data block; 23 positional labels point into it and EVERY one
; is used as `ld xiy/xix, <label>` -- an address taken, never a branch target.
; The records have a 2-byte head whose second byte is the record length, and
; several carry the descriptor shape (tag, LE32 pointer, LE16 cell width) that
; the three .incbin records below use.
; ** CORRECTED 2026-09-25 (lane accomp): bytes +0x00..+0x32 of this block are
; NOT data.  They are three routines (51 B) and AccDraw_Secondary CALLS the
; second and third (calr AccScreen_RefreshScreen / AccScreen_SelectorToWidgetIndex,
; which the symboliser had named AccDraw_Secondary_Helper13 / _Helper14), so the
; "never a branch target" reading above holds for the 23 positional labels
; only.  The records begin at +0x33 = AccScreen_DataBlock_Data_2, the first
; positional label.  Evidence: clean llvm-mc/unidasm decode ending on `ret` at
; +0x32; the calls land on Display_DeferOrDrawWall / Display_DeferOrUpdateScreen;
; and v7's copy of this block differs from v10's here in exactly those two call
; operands (by -0x40D, v7's code-relocation delta for that range) and in two
; RAM operands, (0x379b) and (0x39b8), each 0x9C lower in v7 --
; scripts/converters/lane_accomp_v7_uidatablock.py --diff.
; The four 16-byte .byte rows these 51 bytes were spelled as carried these
; ascii renderings:
; |......#.!.!..6..|
; |.#.!.._.......7!|
; |...f....g..ah...|
; |9@.#.4-.....STEP|
	ld	(COLORBLIT_MODE:24), 0
AccScreen_DrawWall:
	ld	c, 0:opc
	ld	a, 12:opc
	ld	a, 16:opc
	call	Display_DeferOrDrawWall
	ret
AccScreen_RefreshScreen:
	ld	c, 7:opc
	ld	a, 12:opc
	call	Display_DeferOrUpdateScreen
	ret
; W = index of the lowest set bit of ((0x379b) & 31), 0 when none is set;
; stored to (0x39b8).
AccScreen_SelectorToWidgetIndex:
	xor	wa, wa
	ld	a, (CMP_RECORD_PART:16)
	and	a, 31
	jr	z, AccScreen_SelectorToWidgetIndex_Store
AccScreen_SelectorToWidgetIndex_Loop:
	srl	a, 1
	jr	c, AccScreen_SelectorToWidgetIndex_Store
	inc	1, w
	jr	AccScreen_SelectorToWidgetIndex_Loop
AccScreen_SelectorToWidgetIndex_Store:
	ld	(0x3900:16), w
	ret
; +0x33: the records
AccScreen_DataBlock_Data_2:
	.byte 0x23, 0x05, 0x34, 0x2d, 0x00, 0x07, 0x12, 0x84, 0x00, 0x53, 0x54, 0x45, 0x50	; |#.4-.....STEP|
	.byte 0x20, 0x52, 0x45, 0x43, 0x4f, 0x52, 0x44, 0x49, 0x4e, 0x47, 0x20, 0x0c, 0x3a, 0x04, 0x50, 0x41	; | RECORDING .:.PA|
	.byte 0x54, 0x54, 0x45, 0x52, 0x4e, 0x3a, 0x20, 0x09, 0x23, 0x04, 0x50, 0x41, 0x52, 0x54, 0x3a, 0x06	; |TTERN: .#.PART:.|
	.byte 0x05, 0xc4, 0x05, 0x8d, 0x06, 0x08, 0xe3, 0x08, 0x50, 0x41, 0x52, 0x54, 0x06, 0x05, 0x8c, 0x0b	; |........PART....|
	.byte 0x8e, 0x06, 0x07, 0xcb, 0x11, 0x45, 0x52, 0x53, 0x06, 0x08, 0x0a, 0x18, 0x52, 0x45, 0x53, 0x54	; |.....ERS....REST|
	.byte 0x07, 0x05, 0xef, 0x05, 0x11, 0x07, 0x05, 0x8f, 0x0b, 0x11, 0x07, 0x05, 0xa7, 0x11, 0x11, 0x07	; |................|
	.byte 0x05, 0xe7, 0x17, 0x11, 0x06, 0x08, 0x19, 0x1f, 0x4d, 0x45, 0x41, 0x53, 0x06, 0x0a, 0x38, 0x1f	; |........MEAS..8.|
	.byte 0x43, 0x55, 0x52, 0x53, 0x4f, 0x52, 0x06, 0x05, 0x22, 0x21, 0x8d, 0x06, 0x05, 0x2a, 0x23, 0x8e	; |CURSOR.."!...*#.|
	.byte 0x06, 0x05, 0x3b, 0x21, 0x8d, 0x06, 0x05, 0x43, 0x23, 0x8e, 0x06, 0x05, 0x30, 0x22, 0x3c, 0x06	; |..;!...C#...0"<.|
	.byte 0x05, 0x35, 0x22, 0x3e, 0x09, 0x0a, 0x15, 0x01, 0x23, 0x00, 0x33, 0x01, 0x32, 0x00, 0x09, 0x0a	; |.5">....#.3.2...|
	.byte 0x13, 0x01, 0x21, 0x00, 0x35, 0x01, 0x34, 0x00, 0x09, 0x0a, 0x15, 0x01, 0x47, 0x00, 0x33, 0x01	; |..!.5.4.....G.3.|
	.byte 0x56, 0x00, 0x09, 0x0a, 0x13, 0x01, 0x45, 0x00, 0x35, 0x01, 0x58, 0x00, 0x09, 0x0a, 0x15, 0x01	; |V.....E.5.X.....|
	.byte 0x6e, 0x00, 0x33, 0x01, 0x7d, 0x00, 0x09, 0x0a, 0x13, 0x01, 0x6c, 0x00, 0x35, 0x01, 0x7f, 0x00	; |n.3.}.....l.5...|
	.byte 0x09, 0x0a, 0x0d, 0x01, 0x96, 0x00, 0x33, 0x01, 0xa5, 0x00, 0x09, 0x0a, 0x0b, 0x01, 0x94, 0x00	; |......3.........|
	.byte 0x35, 0x01, 0xa7, 0x00, 0x0a, 0x0a, 0x0c, 0x00, 0xaa, 0x00, 0xfa, 0x00, 0xc0, 0x00, 0x0a, 0x0a	; |5...............|
	.byte 0x05, 0x00, 0xd2, 0x00, 0x23, 0x00, 0xec, 0x00, 0x0a, 0x0a, 0xcd, 0x00, 0xd2, 0x00, 0xeb, 0x00	; |....#...........|
	.byte 0xec, 0x00, 0x0a, 0x0a, 0xf5, 0x00, 0xd2, 0x00, 0x13, 0x01, 0xec, 0x00, 0x0a, 0x0a, 0x1d, 0x01	; |................|
	.byte 0xd2, 0x00, 0x3b, 0x01, 0xec, 0x00, 0x01, 0x0a, 0x05, 0x00, 0xdf, 0x00, 0x23, 0x00, 0xdf, 0x00	; |..;.........#...|
	.byte	0x01, 0x0a, 0xcd, 0x00, 0xdf, 0x00, 0xeb, 0x00, 0xdf, 0x00	; |..............NO|
; CmpStep_NoteEntryFrameRecords: Static display records of the Composer STEP screen's note-entry row (list up to
;   CmpStep_ValueFieldRecords): cell text "NOTE VEL LENGTH" at cell 0x1F1E, two rows of 0x8D / 0x8E glyphs (marks the
;   main frame also places above and below its PART and MEAS / CURSOR fields) at cells 0x2127 / 0x232F, four op-0A
;   boxes x = 45..75, 85..115, 125..155, 165..195 (y 210..236) and their op-01 dividers at y = 223.
;   AccDraw_StepArticulation_Wrap draws it when the step mode (0x3676) is 4; the label is also the end of the screen's
;   main frame list (AccScreen_DataBlock_Data_2: "STEP RECORDING", PATTERN:, PART: ...). Basis: readers + bytes.
CmpStep_NoteEntryFrameRecords:	.byte	0x06, 0x15, 0x1e, 0x1f, 0x4e, 0x4f
	.byte 0x54, 0x45, 0x20, 0x56, 0x45, 0x4c, 0x20, 0x20, 0x20, 0x4c, 0x45, 0x4e, 0x47, 0x54, 0x48, 0x06	; |TE VEL   LENGTH.|
	.byte 0x14, 0x27, 0x21, 0x8d, 0x20, 0x20, 0x20, 0x20, 0x8d, 0x20, 0x20, 0x20, 0x20, 0x8d, 0x20, 0x20	; |.'!.    .    .  |
	.byte 0x20, 0x20, 0x8d, 0x06, 0x14, 0x2f, 0x23, 0x8e, 0x20, 0x20, 0x20, 0x20, 0x8e, 0x20, 0x20, 0x20	; |  .../#.    .   |
	.byte 0x20, 0x8e, 0x20, 0x20, 0x20, 0x20, 0x8e, 0x0a, 0x0a, 0x2d, 0x00, 0xd2, 0x00, 0x4b, 0x00, 0xec	; | .    ...-...K..|
	.byte 0x00, 0x0a, 0x0a, 0x55, 0x00, 0xd2, 0x00, 0x73, 0x00, 0xec, 0x00, 0x0a, 0x0a, 0x7d, 0x00, 0xd2	; |...U...s.....}..|
	.byte 0x00, 0x9b, 0x00, 0xec, 0x00, 0x0a, 0x0a, 0xa5, 0x00, 0xd2, 0x00, 0xc3, 0x00, 0xec, 0x00, 0x01	; |................|
	.byte 0x0a, 0x2d, 0x00, 0xdf, 0x00, 0x4b, 0x00, 0xdf, 0x00, 0x01, 0x0a, 0x55, 0x00, 0xdf, 0x00, 0x73	; |.-...K.....U...s|
	.byte 0x00, 0xdf, 0x00, 0x01, 0x0a, 0x7d, 0x00, 0xdf, 0x00, 0x9b, 0x00, 0xdf, 0x00, 0x01, 0x0a, 0xa5	; |.....}..........|
	.byte	0x00, 0xdf, 0x00, 0xc3, 0x00, 0xdf, 0x00	; |..........9.. ..|
; CmpStep_ValueFieldRecords: Bound display records of the Composer STEP screen's values (list up to
;   CmpStep_NoteEntryAreaBand): op-02 text fields for the pattern (RAM 0x391F through the 7-character table "A-vari1"
;   "A-vari2" ...), the part (0x391C, 8-character "ACCOMP 1" .. "ACCOMP 3" "BASS" "DRUM") and four 1-digit values
;   (0x3920..0x3923, mask 0x0F, table " 12345678"), then an op-04 and an op-00 record (0x3924).
;   AccScreen_DataBlock_Code2 draws them with AccGraphics_RenderStart; the label is also the end of
;   CmpStep_NoteEntryFrameRecords. Basis: readers + bytes.
CmpStep_ValueFieldRecords:	.byte	0x02, 0x0f, 0x03, 0x39, 0xff, 0x00, 0x20, 0xce, 0xa9
	.byte	0xf6, 0x00, 0x07, 0x00, 0x1a, 0x04, 0x02, 0x0f, 0x00, 0x39, 0x07, 0x00, 0x20, 0x21, 0xa7, 0xf6	; |.........9.. X..|
	.byte	0x00, 0x08, 0x00, 0x28, 0x04, 0x02, 0x0f, 0x04, 0x39, 0x0f, 0x00, 0x06, 0x49, 0xa7, 0xf6, 0x00	; |...(... 9.......|
	.byte	0x01, 0x00, 0x21, 0x08, 0x02, 0x0f, 0x05, 0x39, 0x0f, 0x00, 0x06, 0x49, 0xa7, 0xf6, 0x00, 0x01	; |..!...!9........|
	.byte	0x00, 0xd1, 0x0c, 0x02, 0x0f, 0x06, 0x39, 0x0f, 0x00, 0x06, 0x49, 0xa7, 0xf6, 0x00, 0x01, 0x00	; |....."9.........|
	.byte	0x81, 0x11, 0x02, 0x0f, 0x07, 0x39, 0x0f, 0x00, 0x06, 0x49, 0xa7, 0xf6, 0x00, 0x01, 0x00, 0x31	; |....#9.........1|
	.byte	0x16, 0x04, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x0e, 0x50, 0xa5, 0xf6, 0x00, 0x00, 0x0a, 0x08, 0x39	; |..............$9|
	.byte	0x0f, 0x00, 0x06, 0x83, 0x1b, 0x01	; |.............4..|
; CmpStep_NoteEntryAreaBand: One bound op-04 display record of the Composer STEP screen with RAM word 0, mask 0 and
;   shift 0, so it always takes entry 0 of its rectangle list at 0xF6A834: text cell 0x1F1D, 20 characters by 40
;   pixels -- the note-entry row's area (its caption starts at cell 0x1F1E). AccDraw_StepArticulation_Wrap colour-blits it
;   (COLORBLIT_MODE 2, AccGraphics_BoundOp04) instead of drawing CmpStep_NoteEntryFrameRecords when the step mode
;   (0x3676) is not 4. It is also the end of CmpStep_ValueFieldRecords. Basis: readers + bytes.
CmpStep_NoteEntryAreaBand:	.byte	0x04, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x0e, 0xfd, 0xa4, 0xf6
	.byte	0x00, 0x1d, 0x1f, 0x14, 0x00, 0x28, 0x00	; |.....(....9...I.|
AccScreen_DataBlock_Data_7:	.byte	0x02, 0x0f, 0x03, 0x39, 0x01, 0x00, 0x06, 0x12, 0xa5
	.byte 0xf6, 0x00, 0x05, 0x00, 0x31, 0x1f, 0x20, 0x50, 0x48, 0x52, 0x53, 0x56, 0x41, 0x4c, 0x55, 0x45	; |....1. PHRSVALUE|
	.byte	0x04, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x0e, 0x27, 0xa5, 0xf6, 0x00, 0xf0, 0x05, 0x22, 0x00, 0x88	; |.......^....."..|
	.byte	0x00	; |....9...o...Q.!.|
AccScreen_DataBlock_Data_6:	.byte	0x04, 0x0b, 0x01, 0x39, 0x03, 0x00, 0x0e, 0x38, 0xa5, 0xf6, 0x00, 0x51, 0x0a, 0x21, 0x00
	.byte 0x09, 0x00, 0x01, 0x0f, 0x21, 0x00, 0x09, 0x00, 0xb1, 0x13, 0x21, 0x00, 0x09, 0x00, 0x61, 0x18	; |....!.....!...a.|
	.byte 0x21, 0x00, 0x09, 0x00, 0xb9, 0x1a, 0x1f, 0x00, 0x16, 0x00	; |!.........|

; accomp_section_widget: 15 bytes (compiled from C)
AccScreen_DrawMeasureDetail_Data:	.incbin "includes/generated/accomp_section_widget.bin"

; Accompaniment variation/section data: 120 bytes
; ** RE-FRAMED 2026-08-30 (lane B4). Was `ld xhl,0x52544e4f` and friends -- the
; immediate is the ASCII "ONTR". The descriptor above (already .incbin) carries
; ptr 0x00F6ACA0 and stride 0x0014 = 20, and the six 20-byte cells end exactly
; where the next descriptor begins at 0xF6AD18.
	.ascii "CONTROL PITCH BEND ="
	.ascii "CONTROL MODULATION ="
	.ascii "CONTROL SUSTAIN    ="
	.ascii "CONTROL PANPOT     ="
	.ascii "CONTROL EXPRESSION ="
	.ascii "CONTROL AFTER TOUCH="

; accomp_part_widget: 15 bytes (compiled from C)
AccScreen_DrawMeas_Variant3_Data:	.incbin "includes/generated/accomp_part_widget.bin"

; Gap: 6 bytes
; ** RE-FRAMED 2026-08-30 (lane B4). The descriptor above (already .incbin)
; carries ptr 0x00F6AD27 and stride 3; these are its two 3-byte cells.
	.ascii "OFF"
	.ascii " ON"

; accomp_display_full: 287 bytes (compiled from C)
AccScreen_DrawMeas_Other_Data:		.incbin "includes/generated/accomp_display_full.bin", 0x0, 0xA
AccScreen_DrawTempoDisplay_Data:	.incbin "includes/generated/accomp_display_full.bin", 0xA, 0x1E
AccScreen_DrawTempoDisplay_Data_2:	.incbin "includes/generated/accomp_display_full.bin", 0x28, 0x8
AccScreen_UpdateBeatDisplay_Data:	.incbin "includes/generated/accomp_display_full.bin", 0x30, 0xA
AccScreen_BeatDisplay_Large_Data:	.incbin "includes/generated/accomp_display_full.bin", 0x3A, 0xA
AccScreen_BeatDataBlock_DisplayList:	.incbin "includes/generated/accomp_display_full.bin", 0x44, 0x1E
AccDraw_Secondary_Entry_Data:		.incbin "includes/generated/accomp_display_full.bin", 0x62, 0xBD

; Accompaniment part names and ordering: 955 bytes
; ** RE-FRAMED 2026-08-30 (lane B4) -- and the "955 bytes" above is NOT all
; data. 941 of them are; the other 14 are two real 7-byte subroutines, and the
; falsification test found them: positional_labels.s names offsets 0x804 and
; 0x829 of this block and accompaniment_engine.s reaches BOTH with `call`, not
; `ld`. The tail of the data is 30 seven-byte section-name cells at 0xF6B109
; (0xF6B109 + 30*7 = 0xF6B1DB, the first routine) named by the stride-7
; descriptor at 0xF6ABBE, and a matching 30-entry ordering table at 0xF6B1E2.
; The head is named by the stride-4 descriptor at 0xF6AD8F (ptr 0x00F6AE4C).
	.byte 0x54, 0x45, 0x4e, 0x55, 0x4e, 0x4f, 0x52, 0x4d, 0x53, 0x54, 0x41, 0x43, 0x43, 0x55, 0x54, 0x54	; |TENUNORMSTACCUTT|
	.byte 0x41, 0x43, 0x43, 0x4f, 0x4d, 0x50, 0x20, 0x31, 0x41, 0x43, 0x43, 0x4f, 0x4d, 0x50, 0x20, 0x32	; |ACCOMP 1ACCOMP 2|
	.byte 0x41, 0x43, 0x43, 0x4f, 0x4d, 0x50, 0x20, 0x33, 0x42, 0x41, 0x53, 0x53, 0x20, 0x20, 0x20, 0x20	; |ACCOMP 3BASS    |
	.byte 0x44, 0x52, 0x55, 0x4d, 0x20, 0x20, 0x20, 0x20, 0x20, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37	; |DRUM     1234567|
	.byte	0x38	; |8....*....*..**.|
AccDraw_Secondary_Sub_Entry2_Data:	.byte	0x91, 0x91, 0x91, 0x91, 0x2a, 0x91, 0x91, 0x91, 0x91, 0x2a, 0x91, 0x91, 0x2a, 0x2a, 0x91
	.byte 0x91, 0x91, 0x91, 0x2a, 0x91, 0x2a, 0x91, 0x2a, 0x91, 0x91, 0x2a, 0x2a, 0x91, 0x2a, 0x2a, 0x2a	; |...*.*.*..**.***|
	.byte 0x91, 0x91, 0x91, 0x91, 0x2a, 0x2a, 0x91, 0x91, 0x2a, 0x91, 0x2a, 0x91, 0x2a, 0x2a, 0x2a, 0x91	; |....**..*.*.***.|
	.byte 0x2a, 0x91, 0x91, 0x2a, 0x2a, 0x2a, 0x91, 0x2a, 0x2a, 0x91, 0x2a, 0x2a, 0x2a, 0x2a, 0x2a, 0x2a	; |*..***.**.******|
	.byte	0x2a	; |*....0.F.0.....0|
AccDraw_Secondary_Sub_Entry2_Data_2:	.byte	0x01, 0x0a, 0x07, 0x00, 0x30, 0x00, 0x46, 0x00, 0x30, 0x00, 0x02, 0x0a, 0x07, 0x00, 0x30
	.byte 0x00, 0x07, 0x00, 0x35, 0x00, 0x02, 0x0a, 0x46, 0x00, 0x30, 0x00, 0x46, 0x00, 0x35, 0x00, 0x06	; |...5...F.0.F.5..|
	.byte 0x05, 0xbd, 0x06, 0x15, 0x01, 0x0a, 0x4a, 0x00, 0x30, 0x00, 0x86, 0x00, 0x30, 0x00, 0x02, 0x0a	; |......J.0...0...|
	.byte 0x4a, 0x00, 0x30, 0x00, 0x4a, 0x00, 0x35, 0x00, 0x02, 0x0a, 0x86, 0x00, 0x30, 0x00, 0x86, 0x00	; |J.0.J.5.....0...|
	.byte 0x35, 0x00, 0x06, 0x05, 0xc5, 0x06, 0x15, 0x01, 0x0a, 0x8a, 0x00, 0x30, 0x00, 0xc6, 0x00, 0x30	; |5..........0...0|
	.byte 0x00, 0x02, 0x0a, 0x8a, 0x00, 0x30, 0x00, 0x8a, 0x00, 0x35, 0x00, 0x02, 0x0a, 0xc6, 0x00, 0x30	; |.....0...5.....0|
	.byte 0x00, 0xc6, 0x00, 0x35, 0x00, 0x06, 0x05, 0xcd, 0x06, 0x15, 0x01, 0x0a, 0xca, 0x00, 0x30, 0x00	; |...5..........0.|
	.byte 0x09, 0x01, 0x30, 0x00, 0x02, 0x0a, 0xca, 0x00, 0x30, 0x00, 0xca, 0x00, 0x35, 0x00, 0x02, 0x0a	; |..0.....0...5...|
	.byte	0x09, 0x01, 0x30, 0x00, 0x09, 0x01, 0x35, 0x00, 0x06, 0x05, 0xd5, 0x06, 0x15	; |..0...5.........|
AccDraw_Secondary_Sub_Entry2_Data_3:	.byte	0x02, 0x0a, 0x07
	.byte 0x00, 0x45, 0x00, 0x07, 0x00, 0x4c, 0x00, 0x01, 0x0a, 0x07, 0x00, 0x4c, 0x00, 0x48, 0x00, 0x4c	; |.E...L.....L.H.L|
	.byte 0x00, 0x02, 0x0a, 0x48, 0x00, 0x45, 0x00, 0x48, 0x00, 0x4c, 0x00, 0x01, 0x0a, 0x49, 0x00, 0x4c	; |...H.E.H.L...I.L|
	.byte 0x00, 0x88, 0x00, 0x4c, 0x00, 0x02, 0x0a, 0x88, 0x00, 0x45, 0x00, 0x88, 0x00, 0x4c, 0x00, 0x01	; |...L.....E...L..|
	.byte 0x0a, 0x89, 0x00, 0x4c, 0x00, 0xc8, 0x00, 0x4c, 0x00, 0x02, 0x0a, 0xc8, 0x00, 0x45, 0x00, 0xc8	; |...L...L.....E..|
	.byte 0x00, 0x4c, 0x00, 0x01, 0x0a, 0xc9, 0x00, 0x4c, 0x00, 0x09, 0x01, 0x4c, 0x00, 0x02, 0x0a, 0x09	; |.L.....L...L....|
	.byte	0x01, 0x45, 0x00, 0x09, 0x01, 0x4c, 0x00	; |.E...L.....c...j|
AccDraw_Secondary_Sub_Entry2_Data_4:	.byte	0x02, 0x0a, 0x07, 0x00, 0x63, 0x00, 0x07, 0x00, 0x6a
	.byte 0x00, 0x01, 0x0a, 0x07, 0x00, 0x6a, 0x00, 0x48, 0x00, 0x6a, 0x00, 0x02, 0x0a, 0x48, 0x00, 0x63	; |.....j.H.j...H.c|
	.byte 0x00, 0x48, 0x00, 0x6a, 0x00, 0x01, 0x0a, 0x49, 0x00, 0x6a, 0x00, 0x88, 0x00, 0x6a, 0x00, 0x02	; |.H.j...I.j...j..|
	.byte 0x0a, 0x88, 0x00, 0x63, 0x00, 0x88, 0x00, 0x6a, 0x00, 0x01, 0x0a, 0x89, 0x00, 0x6a, 0x00, 0xc8	; |...c...j.....j..|
	.byte 0x00, 0x6a, 0x00, 0x02, 0x0a, 0xc8, 0x00, 0x63, 0x00, 0xc8, 0x00, 0x6a, 0x00, 0x01, 0x0a, 0xc9	; |.j.....c...j....|
	.byte 0x00, 0x6a, 0x00, 0x09, 0x01, 0x6a, 0x00, 0x02, 0x0a, 0x09, 0x01, 0x63, 0x00, 0x09, 0x01, 0x6a	; |.j...j.....c...j|
	.byte	0x00	; |................|
AccDraw_Secondary_Sub_Entry2_Data_5:	.byte	0x02, 0x0a, 0x07, 0x00, 0x81, 0x00, 0x07, 0x00, 0x88, 0x00, 0x01, 0x0a, 0x07, 0x00, 0x88
	.byte 0x00, 0x48, 0x00, 0x88, 0x00, 0x02, 0x0a, 0x48, 0x00, 0x81, 0x00, 0x48, 0x00, 0x88, 0x00, 0x01	; |.H.....H...H....|
	.byte 0x0a, 0x49, 0x00, 0x88, 0x00, 0x88, 0x00, 0x88, 0x00, 0x02, 0x0a, 0x88, 0x00, 0x81, 0x00, 0x88	; |.I..............|
	.byte 0x00, 0x88, 0x00, 0x01, 0x0a, 0x89, 0x00, 0x88, 0x00, 0xc8, 0x00, 0x88, 0x00, 0x02, 0x0a, 0xc8	; |................|
	.byte 0x00, 0x81, 0x00, 0xc8, 0x00, 0x88, 0x00, 0x01, 0x0a, 0xc9, 0x00, 0x88, 0x00, 0x09, 0x01, 0x88	; |................|
	.byte	0x00, 0x02, 0x0a, 0x09, 0x01, 0x81, 0x00, 0x09, 0x01, 0x88, 0x00	; |................|
AccDraw_Secondary_Sub_Entry2_Data_6:	.byte	0x02, 0x0a, 0x07, 0x00, 0x9f
	.byte 0x00, 0x07, 0x00, 0xa6, 0x00, 0x01, 0x0a, 0x07, 0x00, 0xa6, 0x00, 0x48, 0x00, 0xa6, 0x00, 0x02	; |...........H....|
	.byte 0x0a, 0x48, 0x00, 0x9f, 0x00, 0x48, 0x00, 0xa6, 0x00, 0x01, 0x0a, 0x49, 0x00, 0xa6, 0x00, 0x88	; |.H...H.....I....|
	.byte 0x00, 0xa6, 0x00, 0x02, 0x0a, 0x88, 0x00, 0x9f, 0x00, 0x88, 0x00, 0xa6, 0x00, 0x01, 0x0a, 0x89	; |................|
	.byte 0x00, 0xa6, 0x00, 0xc8, 0x00, 0xa6, 0x00, 0x02, 0x0a, 0xc8, 0x00, 0x9f, 0x00, 0xc8, 0x00, 0xa6	; |................|
	.byte 0x00, 0x01, 0x0a, 0xc9, 0x00, 0xa6, 0x00, 0x09, 0x01, 0xa6, 0x00, 0x02, 0x0a, 0x09, 0x01, 0x9f	; |................|
	.byte	0x00, 0x09, 0x01, 0xa6, 0x00	; |...........!.).1|
AccDraw_Secondary_Sub_Entry2_Data_7:	.byte	0x09, 0x00, 0x11, 0x00, 0x19, 0x00, 0x21, 0x00, 0x29, 0x00, 0x31
	.byte 0x00, 0x39, 0x00, 0x41, 0x00, 0x49, 0x00, 0x51, 0x00, 0x59, 0x00, 0x61, 0x00, 0x69, 0x00, 0x71	; |.9.A.I.Q.Y.a.i.q|
	.byte 0x00, 0x79, 0x00, 0x81, 0x00, 0x89, 0x00, 0x91, 0x00, 0x99, 0x00, 0xa1, 0x00, 0xa9, 0x00, 0xb1	; |.y..............|
	.byte 0x00, 0xb9, 0x00, 0xc1, 0x00, 0xc9, 0x00, 0xd1, 0x00, 0xd9, 0x00, 0xe1, 0x00, 0xe9, 0x00, 0xf1	; |................|
	.byte	0x00, 0xf9, 0x00, 0x01, 0x01	; |.....B.`.~...A-v|
AccDraw_Secondary_Sub_Entry2_Data_8:	.byte	0x42, 0x00, 0x60, 0x00, 0x7e, 0x00, 0x9c, 0x00, 0x41, 0x2d, 0x76
	.byte 0x61, 0x72, 0x69, 0x31, 0x41, 0x2d, 0x76, 0x61, 0x72, 0x69, 0x32, 0x41, 0x2d, 0x76, 0x61, 0x72	; |ari1A-vari2A-var|
	.byte 0x69, 0x33, 0x41, 0x2d, 0x76, 0x61, 0x72, 0x69, 0x34, 0x42, 0x2d, 0x76, 0x61, 0x72, 0x69, 0x31	; |i3A-vari4B-vari1|
	.byte 0x42, 0x2d, 0x76, 0x61, 0x72, 0x69, 0x32, 0x42, 0x2d, 0x76, 0x61, 0x72, 0x69, 0x33, 0x42, 0x2d	; |B-vari2B-vari3B-|
	.byte 0x76, 0x61, 0x72, 0x69, 0x34, 0x43, 0x2d, 0x76, 0x61, 0x72, 0x69, 0x31, 0x43, 0x2d, 0x76, 0x61	; |vari4C-vari1C-va|
	.byte 0x72, 0x69, 0x32, 0x43, 0x2d, 0x76, 0x61, 0x72, 0x69, 0x33, 0x43, 0x2d, 0x76, 0x61, 0x72, 0x69	; |ri2C-vari3C-vari|
	.byte 0x34, 0x41, 0x2d, 0x49, 0x4e, 0x54, 0x20, 0x31, 0x41, 0x2d, 0x49, 0x4e, 0x54, 0x20, 0x32, 0x41	; |4A-INT 1A-INT 2A|
	.byte 0x2d, 0x46, 0x49, 0x4c, 0x4c, 0x31, 0x41, 0x2d, 0x46, 0x49, 0x4c, 0x4c, 0x32, 0x41, 0x2d, 0x45	; |-FILL1A-FILL2A-E|
	.byte 0x4e, 0x44, 0x20, 0x31, 0x41, 0x2d, 0x45, 0x4e, 0x44, 0x20, 0x32, 0x42, 0x2d, 0x49, 0x4e, 0x54	; |ND 1A-END 2B-INT|
	.byte 0x20, 0x31, 0x42, 0x2d, 0x49, 0x4e, 0x54, 0x20, 0x32, 0x42, 0x2d, 0x46, 0x49, 0x4c, 0x4c, 0x31	; | 1B-INT 2B-FILL1|
	.byte 0x42, 0x2d, 0x46, 0x49, 0x4c, 0x4c, 0x32, 0x42, 0x2d, 0x45, 0x4e, 0x44, 0x20, 0x31, 0x42, 0x2d	; |B-FILL2B-END 1B-|
	.byte 0x45, 0x4e, 0x44, 0x20, 0x32, 0x43, 0x2d, 0x49, 0x4e, 0x54, 0x20, 0x31, 0x43, 0x2d, 0x49, 0x4e	; |END 2C-INT 1C-IN|
	.byte 0x54, 0x20, 0x32, 0x43, 0x2d, 0x46, 0x49, 0x4c, 0x4c, 0x31, 0x43, 0x2d, 0x46, 0x49, 0x4c, 0x4c	; |T 2C-FILL1C-FILL|
	.byte 0x32, 0x43, 0x2d, 0x45, 0x4e, 0x44, 0x20, 0x31, 0x43, 0x2d, 0x45, 0x4e, 0x44, 0x20, 0x32	; |2C-END 1C-END 2|
; 0xF6B1DB = AccScreen_GetByte_0x353E: reads a byte variable into A and
; preserves XHL. Callers do `xor xwa,xwa` / `call` / `ld l,a` / `mul8rr a,l`.
AccScreen_GetByte_0x353E:
	push	xhl
	ld	a, (0x3486:16)
	pop	xhl
	ret
; 0xF6B1E2: 30 entries, one per section-name cell above -- a display ordering
; permutation of 0..29.
	.byte 0x00, 0x01, 0x02, 0x03, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11	; |..........|
	.byte 0x04, 0x05, 0x06, 0x07, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17	; |..........|
	.byte 0x08, 0x09, 0x0a, 0x0b, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d	; |..........|
; 0xF6B200 = AccScreen_GetByte_0x353C: the same shape for (0x353c). The tree
; had lost its entry point inside a phantom `jp 0x3b1d1c` at 0xF6B1FD.
AccScreen_GetByte_0x353C:
	push	xhl
	ld	a, (0x3484:16)
	pop	xhl
	ret
AccPatch_InitSlotChain_Wrap:
	push xiz
	calr AccPatch_InitSlotChain
	pop xiz
	ret

AccPatch_InitSlotChain_WithAddr:
	push	xiz
	ld	xiz, RHYTHM_PATTERN_BUF_A
	ld	(STYLE_SRC_IMAGE_PTR:16), xiz
	calr	AccPatch_InitSlotChain
	pop	xiz
	ret
AccPatch_InitSlotChain:
	xor	xwa, xwa
	xor	xbc, xbc
	ld	xhl, (STYLE_SRC_IMAGE_PTR:16)
	add	xhl, 5120
	ld	(14006:16), xhl
	ld	wa, (xhl+3)
	ld	(14022:16), wa
	ldw	bc, 150
	ld	(14038:16), bc
	ld	xhl, (STYLE_SRC_IMAGE_PTR:16)
	add	xhl, 43520
	ld	(14002:16), xhl
	ldw	bc, 150
	xor	xhl, xhl
AccPatch_IterateSlotChain:
	cpw	(0x36c6:16), 65535
	jr	z, AccPatch_IterateSlot_NextBlock
	ld	hl, (0x36c6:16)
	calr	AccPatch_CalcSlotBufferAddr
	ld	(0x36a2:16), xiz
	cp	hl, (0x36d6:16)
	jr	z, AccPatch_IterateSlot_Advance
	calr	AccPatch_UpdateLinkPointers
	calr	AccPatch_SwapSlotBuffers
AccPatch_IterateSlot_Advance:
	ld	xiz, (14002:16)
	ld	wa, (xiz+3)
	ld	(14022:16), wa
	incw	1, (14038:16)
	ld	hl, (14038:16)
	calr	AccPatch_CalcSlotBufferAddr
	ld	(14002:16), xiz
	jr	AccPatch_IterateSlotChain
AccPatch_IterateSlot_NextBlock:
	ld	xiz, 256
	add	(14006:16), xiz
	ld	xiz, (14006:16)
	ld	wa, (xiz+3)
	ld	(14022:16), wa
	djnz16	bc, AccPatch_IterateSlotChain
	xor	xwa, xwa
	xor	xhl, xhl
	ld	wa, (14038:16)
	ldw	hl, 256
	mul	xwa, hl
	add	xwa, 5120
	add	xwa, 1023
	and	xwa, 4294966272
	srl	xwa, 4
	ld	xiy, (STYLE_SRC_IMAGE_PTR:16)
	ld	(xiy+46), wa
	ret
AccPatch_SwapSlotBuffers:
	push	xbc
	ld	xwa, 1024
	push	xwa
	call	Malloc
	add	xsp, 4
	ld	(RHYTHM_PATTERN_ALLOC:16), xhl
	ldw	bc, 256
	ld	xix, (RHYTHM_PATTERN_ALLOC:16)
	ld	xiy, (0x36b2:16)
	ldir85
	ldw	bc, 256
	ld	xix, (0x36b2:16)
	ld	xiy, (0x36a2:16)
	ldir85
	ldw	bc, 256
	ld	xiy, (RHYTHM_PATTERN_ALLOC:16)
	ld	xix, (0x36a2:16)
	ldir85
	ld	xwa, (RHYTHM_PATTERN_ALLOC:16)
	push	xwa
	call	Free
	add	xsp, 4
	pop	xbc
	ret
AccPatch_UpdateLinkPointers:
	xor	xwa, xwa
	xor	xhl, xhl
	ld	xiy, (13986:16)
	ld	wa, (xiy+3)
	ld	(14447:16), wa
	ld	wa, (xiy+1)
	ld	(14449:16), wa
	ld	xix, (14002:16)
	ld	wa, (xix+3)
	ld	(14451:16), wa
	ld	wa, (xix+1)
	ld	(14453:16), wa
	ld	hl, (14447:16)
	cp	hl, 65535
	jr	z, AccPatch_UpdateLink_Back
	calr	AccPatch_CalcSlotBufferAddr
	ld	wa, (14038:16)
	ld	(xiz+1), wa
AccPatch_UpdateLink_Back:
	ld	hl, (14449:16)
	cp	hl, 65535
	jr	z, AccPatch_UpdateLink_Fwd1
	calr	AccPatch_CalcSlotBufferAddr
	ld	wa, (14038:16)
	ld	(xiz+3), wa
AccPatch_UpdateLink_Fwd1:
	ld	hl, (14451:16)
	cp	hl, 65535
	jr	z, AccPatch_UpdateLink_Fwd2
	calr	AccPatch_CalcSlotBufferAddr
	ld	wa, (14022:16)
	ld	(xiz+1), wa
AccPatch_UpdateLink_Fwd2:
	ld	hl, (14453:16)
	cp	hl, 65535
	jr	z, AccPatch_UpdateLink_Return
	calr	AccPatch_CalcSlotBufferAddr
	ld	wa, (14022:16)
	ld	(xiz+3), wa
AccPatch_UpdateLink_Return:
	ret

AccPatch_CalcSlotBufferAddr:
	xor	xiz, xiz
	ld	xiz, 256
	mul	xiz, hl
	add	xiz, (STYLE_SRC_IMAGE_PTR:16)
	add	xiz, 5120
	ret
AccPatch_VoiceAssignDataBlock:
	ret
	ret
	ld	xiy, (13974:16)
	ld	a, (xiy+0:8)
	cp	a, 109
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip
	ld	a, (xiy+1)
	cp	a, 107
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip2
	ld	a, (xiy+2)
	cp	a, 97
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip2
	ld	(14050:16), 0
	jr	AccPatch_VoiceAssignDataBlock_Return
AccPatch_VoiceAssignDataBlock_Skip:
	ld	a, (xiy+0:8)
	cp	a, 102
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip2
	ld	a, (xiy+1)
	cp	a, 0:i3
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip2
	ld	a, (xiy+2)
	cp	a, 107
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip2
	ld	(14050:16), 0
	jr	AccPatch_VoiceAssignDataBlock_Return
AccPatch_VoiceAssignDataBlock_Skip2:
	ld	a, (xiy+0:8)
	cp	a, 109
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip3
	ld	a, (xiy+1)
	cp	a, 107
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip3
	ld	a, (xiy+2)
	cp	a, 98
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip3
	ld	(14050:16), 0
	jr	AccPatch_VoiceAssignDataBlock_Return
AccPatch_VoiceAssignDataBlock_Skip3:
	ld	(14050:16), 255
	ld	(14488:16), 130
AccPatch_VoiceAssignDataBlock_Return:
	ret
AccPatch_VoiceAssignDataBlock_Return_Loop:
	xor	xbc, xbc
	ldw	bc, 42
	add	xiy, 12
	add	xix, 12
	ldirw
	djnz8	e, AccPatch_VoiceAssignDataBlock_Return_Loop
	ret
	cp xix, xiy
	jr	ugt, AccPatch_VoiceAssignDataBlock_Skip29
AccPatch_VoiceAssignDataBlock_Loop:
	xor	xbc, xbc
	ldw	bc, 128
	ldirw
	dec	1, e
	cp	e, 0:i3
	jr	ugt, AccPatch_VoiceAssignDataBlock_Loop
	jr	AccPatch_VoiceAssignDataBlock_Return2
AccPatch_VoiceAssignDataBlock_Skip29:
	push	d
	ld	d, 0:opc
	ld	xbc, 0:i3
	ldw	bc, 256
	mul	xbc, de
	pop d
	add	xix, xbc
	add	xiy, xbc
	push	xix
	push	xiy
	dec	1, xix
	dec	1, xiy
AccPatch_VoiceAssignDataBlock_Loop2:
	ld	xbc, 0:i3
	ldw	bc, 256
	lddr85
	dec	1, e
	cp	e, 0:i3
	jr	ugt, AccPatch_VoiceAssignDataBlock_Loop2
	pop	xiy
	pop	xix
AccPatch_VoiceAssignDataBlock_Return2:
	ret
	xor	xbc, xbc
AccPatch_VoiceAssignDataBlock_Loop3:
	ld	(xiy), 0
	ldw	(xiy+1), 65535
	ldw	(xiy+3), 65535
	ld	c, 249:opc
	add	xiy, 6
AccPatch_VoiceAssignDataBlock_Loop4:
	ld	(xiy+), 0
	dec	1, c
	cp	c, 0:i3
	jr	ugt, AccPatch_VoiceAssignDataBlock_Loop4
	inc	1, xiy
	dec	1, e
	cp	e, 0:i3
	jr	ugt, AccPatch_VoiceAssignDataBlock_Loop3
	ret
	xor	xbc, xbc
AccPatch_VoiceAssignDataBlock_Loop5:
	ld	xiy, 651776
	ld	c, (14470:16)
AccPatch_VoiceAssignDataBlock_Loop6:
	cp	(xiy+1), wa
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip5
AccPatch_VoiceAssignDataBlock_Loop8:
	cpw	(xiy+3), 65535
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip4
	inc	1, (14469:16)
	jr	AccPatch_VoiceAssignDataBlock_Join
AccPatch_VoiceAssignDataBlock_Skip4:
	inc	1, (14469:16)
	add	xiy, 256
	dec	1, c
	cp	c, 0:i3
	jr	ugt, AccPatch_VoiceAssignDataBlock_Loop8
	jr	AccPatch_VoiceAssignDataBlock_Join
AccPatch_VoiceAssignDataBlock_Skip5:
	add	xiy, 256
	dec	1, c
	cp	c, 0:i3
	jr	ugt, AccPatch_VoiceAssignDataBlock_Loop6
AccPatch_VoiceAssignDataBlock_Join:
	inc	1, wa
	cp	wa, qwa
	jr	ule, AccPatch_VoiceAssignDataBlock_Loop5
	ret
	ld	xiy, 651776
	xor	xbc, xbc
	ld	c, 190:opc
AccPatch_VoiceAssignDataBlock_Join_Loop:
	cp	(xiy), 128
	jr	nz, AccPatch_VoiceAssignDataBlock_Return3
	inc	1, (14474:16)
	add	xiy, 256
	djnz8	c, AccPatch_VoiceAssignDataBlock_Join_Loop
AccPatch_VoiceAssignDataBlock_Return3:
	ret
	xor	xde, xde
AccPatch_VoiceAssignDataBlock_Loop7:
	ld	de, (xiy+3)
	cp	de, 65535
	jr	z, AccPatch_VoiceAssignDataBlock_Skip9
	ld	de, (14478:16)
	ld	(xiy+3), de
	ld	de, (14476:16)
	ld	(xix+1), de
	ldw	(14484:16), 0
AccPatch_VoiceAssignDataBlock_Loop9:
	cpw	(xix+3), 65535
	jr	z, AccPatch_VoiceAssignDataBlock_Skip7
	ld	de, (14484:16)
	cp	de, 0:i3
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip6
	incw	1, (14478:16)
	ld	de, (14478:16)
	ld	(xix+3), de
	add	xix, 256
	ldw	(14484:16), 255
	jr	AccPatch_VoiceAssignDataBlock_Loop9
AccPatch_VoiceAssignDataBlock_Skip6:
	ld	de, (14478:16)
	dec	1, de
	ld	(xix+1), de
	incw	1, (14478:16)
	ld	de, (14478:16)
	ld	(xix+3), de
	add	xix, 256
	jr	AccPatch_VoiceAssignDataBlock_Loop9
AccPatch_VoiceAssignDataBlock_Skip7:
	ld	de, (14484:16)
	cp	de, 0:i3
	jr	z, AccPatch_VoiceAssignDataBlock_Skip8
	ld	de, (14478:16)
	dec	1, de
	ld	(xix+1), de
AccPatch_VoiceAssignDataBlock_Skip8:
	incw	1, (14478:16)
	add	xix, 256
AccPatch_VoiceAssignDataBlock_Skip9:
	incw	1, (14476:16)
	add	xiy, 256
	dec	1, c
	cp	c, 0:i3
	jrl	ugt, AccPatch_VoiceAssignDataBlock_Loop7
	ret
AccPatch_VoiceAssignDataBlock_Helper:
	xor	xiz, xiz
	ld	xiz, 256
	mul	xiz, hl
	add	xiz, RHYTHM_PATTERN_BUF_B
	ret
	push	xiz
	call	AccPatch_VoiceAssignDataBlock_Helper2
	pop	xiz
	ret
AccPatch_VoiceAssignDataBlock_Helper2:
	ld	(14488:16), 0
	ldw	(14520:16), 0
	ldw	(14522:16), 150
	calr	AccPatch_VoiceAssignDataBlock_Helper27
	calr	AccPatch_VoiceAssignDataBlock_Helper28
	cp	(14488:16), 132
	jr	z, AccPatch_VoiceAssignDataBlock_Join2
	calr	AccPatch_VoiceAssignDataBlock_Helper4
	cp	w, 255
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip10
	ld	(14488:16), 130
	jr	AccPatch_VoiceAssignDataBlock_Join2
AccPatch_VoiceAssignDataBlock_Skip10:
	calr	AccPatch_VoiceAssignDataBlock_Helper3
	call	AccScreen_GetByte_0x353E
	calr	AccPatch_VoiceAssignDataBlock_Helper5
	calr	AccPatch_VoiceAssignDataBlock_Helper6
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Join2
	calr	AccPatch_VoiceAssignDataBlock_Helper11
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Join2
	calr	AccPatch_VoiceAssignDataBlock_Helper24
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Join2
	jr	AccPatch_VoiceAssignDataBlock_Join3
AccPatch_VoiceAssignDataBlock_Join2:
	call	AccScreen_GetByte_0x353E
	calr	AccPatch_VoiceAssignDataBlock_Helper5
AccPatch_VoiceAssignDataBlock_Join3:
	calr	AccPatch_VoiceAssignDataBlock_Helper31
	call	AccPatch_ClearModeFlag
	ret
AccPatch_VoiceAssignDataBlock_Helper3:
	xor	xwa, xwa
	ld	xiy, 432128
	ld	wa, (xiy+14)
	ld	xiy, RHYTHM_PATTERN_BUF_A
	ld	(xiy+14), wa
	ret
AccPatch_VoiceAssignDataBlock_Helper4:
	ld	xhl, 432128
	cp	(xhl+1), 72
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip11
	cp	(xhl+2), 0
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip11
	cp	(xhl+2), 75
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip11
	ld	w, 5:opc
	jr	AccPatch_VoiceAssignDataBlock_Return4
AccPatch_VoiceAssignDataBlock_Skip11:
	ld	a, (xhl+0:8)
	cp	a, 103
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip12
	ld	a, (xhl+1)
	cp	a, 0:i3
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip12
	ld	a, (xhl+2)
	cp	a, 107
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip12
	ld	w, 5:opc
	jr	AccPatch_VoiceAssignDataBlock_Return4
AccPatch_VoiceAssignDataBlock_Skip12:
	ld	a, (xhl+0:8)
	cp	a, 76
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip13
	ld	a, (xhl+1)
	cp	a, 75
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip13
	ld	a, (xhl+2)
	cp	a, 69
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip13
	ld	w, 5:opc
	jr	AccPatch_VoiceAssignDataBlock_Return4
AccPatch_VoiceAssignDataBlock_Skip13:
	ld	w, 255:opc
AccPatch_VoiceAssignDataBlock_Return4:
	ret
AccPatch_VoiceAssignDataBlock_Helper5:
	ld	w, (STYLE_SECTION:16)
	ld	(STYLE_SECTION:16), a
	pushw	wa
	call	AccPatch_InitCurrentSlot
	popw	wa
	ld	(STYLE_SECTION:16), w
	ret
AccPatch_VoiceAssignDataBlock_Helper6:
	xor	xhl, xhl
	xor	xwa, xwa
	call	AccScreen_GetByte_0x353C
	ld	l, a
	ld	a, 96:opc
	mul	wa, l
	add	wa, 96
	ld	(14530:16), wa
	xor	xwa, xwa
	call	AccScreen_GetByte_0x353E
	ld	l, a
	ld	a, 96:opc
	mul	wa, l
	add	wa, 96
	ld	(14532:16), wa
	cpw	(14530:16), 960
	jr	c, AccPatch_VoiceAssignDataBlock_Skip14
	cpw	(14530:16), 960
	jr	z, AccPatch_VoiceAssignDataBlock_Skip15
	cpw	(14530:16), 2016
	jr	c, AccPatch_VoiceAssignDataBlock_Skip16
	cpw	(14530:16), 2016
	jr	z, AccPatch_VoiceAssignDataBlock_Skip17
	jr	AccPatch_VoiceAssignDataBlock_Join4
AccPatch_VoiceAssignDataBlock_Skip14:
	calr	AccPatch_VoiceAssignDataBlock_Helper7
	jr	AccPatch_VoiceAssignDataBlock_Return5
AccPatch_VoiceAssignDataBlock_Skip15:
	calr	AccPatch_VoiceAssignDataBlock_Helper8
	jr	AccPatch_VoiceAssignDataBlock_Return5
AccPatch_VoiceAssignDataBlock_Skip16:
	calr	AccPatch_VoiceAssignDataBlock_Helper30
	cp	(14488:16), 129
	jr	z, AccPatch_VoiceAssignDataBlock_Return5
	subw	(0x38c2:16), 1024
	calr	AccPatch_VoiceAssignDataBlock_Helper7
	jr	AccPatch_VoiceAssignDataBlock_Return5
AccPatch_VoiceAssignDataBlock_Skip17:
	calr	AccPatch_VoiceAssignDataBlock_Helper30
	cp	(14488:16), 129
	jr	z, AccPatch_VoiceAssignDataBlock_Return5
	subw	(0x38c2:16), 1024
	calr	AccPatch_VoiceAssignDataBlock_Helper8
	jr	AccPatch_VoiceAssignDataBlock_Return5
AccPatch_VoiceAssignDataBlock_Join4:
	calr	AccPatch_VoiceAssignDataBlock_Helper30
	cp	(14488:16), 129
	jr	z, AccPatch_VoiceAssignDataBlock_Return5
	calr	AccPatch_VoiceAssignDataBlock_Helper30
	cp	(14488:16), 129
	jr	z, AccPatch_VoiceAssignDataBlock_Return5
	subw	(0x38c2:16), 2048
	calr	AccPatch_VoiceAssignDataBlock_Helper9
AccPatch_VoiceAssignDataBlock_Return5:
	ret
AccPatch_VoiceAssignDataBlock_Helper7:
	xor	xiz, xiz
	ld	xiy, 432128
	ld	iz, (14530:16)
	add	xiy, xiz
	add	xiy, 12
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	iz, (14532:16)
	add	xix, xiz
	add	xix, 12
	xor	xbc, xbc
	ldw	bc, 84
	ldir85
	calr	AccPatch_VoiceAssignDataBlock_Helper10
	ret
AccPatch_VoiceAssignDataBlock_Helper8:
	xor	xwa, xwa
	xor	xbc, xbc
	xor	xiz, xiz
	ldw	wa, 1024
	sub	wa, (14530:16)
	ld	bc, wa
	sub	bc, 12
	ld	xiy, 432128
	ld	xix, RHYTHM_PATTERN_BUF_A
	ld	iz, (14530:16)
	add	xiy, xiz
	add	xiy, 12
	ld	iz, (14532:16)
	add	xix, xiz
	add	xix, 12
	push	xbc
	ldir85
	push	xiy
	push	xix
	calr	AccPatch_VoiceAssignDataBlock_Helper10
	calr	AccPatch_VoiceAssignDataBlock_Helper30
	pop	xix
	pop	xiy
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Return6
	pop	xbc
	ld	xiy, 432128
	ldw	wa, 96
	sub	wa, bc
	ld	bc, wa
	sub	bc, 12
	ldir85
AccPatch_VoiceAssignDataBlock_Return6:
	ret
AccPatch_VoiceAssignDataBlock_Helper9:
	xor	xiy, xiy
	xor	xix, xix
	ld	iy, (14530:16)
	add	xiy, 432128
	add	xiy, 12
	ld	ix, (14532:16)
	add	xix, RHYTHM_PATTERN_BUF_A
	add	xix, 12
	ldw	bc, 96
	sub	bc, 12
	ldir85
	calr	AccPatch_VoiceAssignDataBlock_Helper10
	ret
AccPatch_VoiceAssignDataBlock_Helper10:
	xor	xiy, xiy
	xor	xix, xix
	xor	xwa, xwa
	ld	iy, (14530:16)
	ld	xhl, 432128
	add	xhl, 0
	ld	wa, (xhl+iy)
	ld	(14490:16), wa
	ld	xhl, 432128
	add	xhl, 4
	ld	wa, (xhl+iy)
	ld	(14492:16), wa
	ld	xhl, 432128
	add	xhl, 6
	ld	wa, (xhl+iy)
	ld	(14494:16), wa
	ld	xhl, 432128
	add	xhl, 8
	ld	wa, (xhl+iy)
	ld	(14496:16), wa
	ld	xhl, 432128
	add	xhl, 10
	ld	wa, (xhl+iy)
	ld	(14498:16), wa
	ld	ix, (14532:16)
	add	xix, RHYTHM_PATTERN_BUF_A
	ld	wa, (xix+0:8)
	ld	(14500:16), wa
	ld	wa, (xix+4)
	ld	(14502:16), wa
	ld	wa, (xix+6)
	ld	(14504:16), wa
	ld	wa, (xix+8)
	ld	(14506:16), wa
	ld	wa, (xix+10)
	ld	(14508:16), wa
	ret
AccPatch_VoiceAssignDataBlock_Helper11:
	calr	AccPatch_VoiceAssignDataBlock_Helper29
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Return7
	ld	xwa, 5:i3
AccPatch_VoiceAssignDataBlock_Helper11_Loop:
	push	xwa
	calr	AccPatch_VoiceAssignDataBlock_Helper30
	pop	xwa
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Return7
	djnz8	a, AccPatch_VoiceAssignDataBlock_Helper11_Loop
	calr	AccPatch_VoiceAssignDataBlock_Helper12
	calr	AccPatch_VoiceAssignDataBlock_Helper13
	calr	AccPatch_VoiceAssignDataBlock_Helper14
	calr	AccPatch_VoiceAssignDataBlock_Helper15
	calr	AccPatch_VoiceAssignDataBlock_Helper16
AccPatch_VoiceAssignDataBlock_Return7:
	ret
AccPatch_VoiceAssignDataBlock_Helper12:
	ld	wa, (14490:16)
	ld	(14524:16), wa
	ld	wa, (14500:16)
	ld	(14526:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper17
	ld	wa, (14524:16)
	ld	(14490:16), wa
	ld	wa, (14528:16)
	ld	(14510:16), wa
	ld	wa, (14526:16)
	ld	(14500:16), wa
	ret
AccPatch_VoiceAssignDataBlock_Helper13:
	ld	wa, (14492:16)
	ld	(14524:16), wa
	ld	wa, (14502:16)
	ld	(14526:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper17
	ld	wa, (14524:16)
	ld	(14492:16), wa
	ld	wa, (14528:16)
	ld	(14512:16), wa
	ld	wa, (14526:16)
	ld	(14502:16), wa
	ret
AccPatch_VoiceAssignDataBlock_Helper14:
	ld	wa, (14494:16)
	ld	(14524:16), wa
	ld	wa, (14504:16)
	ld	(14526:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper17
	ld	wa, (14524:16)
	ld	(14494:16), wa
	ld	wa, (14528:16)
	ld	(14514:16), wa
	ld	wa, (14526:16)
	ld	(14504:16), wa
	ret
AccPatch_VoiceAssignDataBlock_Helper15:
	ld	wa, (14496:16)
	ld	(14524:16), wa
	ld	wa, (14506:16)
	ld	(14526:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper17
	ld	wa, (14524:16)
	ld	(14496:16), wa
	ld	wa, (14528:16)
	ld	(14516:16), wa
	ld	wa, (14526:16)
	ld	(14506:16), wa
	ret
AccPatch_VoiceAssignDataBlock_Helper16:
	ld	wa, (14498:16)
	ld	(14524:16), wa
	ld	wa, (14508:16)
	ld	(14526:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper17
	ld	wa, (14524:16)
	ld	(14498:16), wa
	ld	wa, (14528:16)
	ld	(14518:16), wa
	ld	wa, (14526:16)
	ld	(14508:16), wa
	ret
AccPatch_VoiceAssignDataBlock_Helper17:
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Return8
	calr	AccPatch_VoiceAssignDataBlock_Helper18
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Return8
	calr	AccPatch_VoiceAssignDataBlock_Helper22
	calr	AccPatch_VoiceAssignDataBlock_Helper23
AccPatch_VoiceAssignDataBlock_Return8:
	ret
AccPatch_VoiceAssignDataBlock_Helper18:
	calr	AccPatch_VoiceAssignDataBlock_Helper19
	cp	de, 0:i3
	jr	z, AccPatch_VoiceAssignDataBlock_Return9
	ld	wa, (14524:16)
	cp	wa, (14520:16)
	jr	c, AccPatch_VoiceAssignDataBlock_Skip19
	xor	xhl, xhl
	xor	xbc, xbc
	ld	bc, (14524:16)
	srl	bc, 2
	ld	hl, (14520:16)
	srl	hl, 2
	sub	bc, hl
AccPatch_VoiceAssignDataBlock_Join5:
	cp	bc, 0:i3
	jr	ule, AccPatch_VoiceAssignDataBlock_Skip18
	push	xbc
	calr	AccPatch_VoiceAssignDataBlock_Helper30
	pop	xbc
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip18
	addw	(0x38b8:16), 4
	dec	1, bc
	jr	AccPatch_VoiceAssignDataBlock_Join5
AccPatch_VoiceAssignDataBlock_Skip18:
	jr	AccPatch_VoiceAssignDataBlock_Return9
AccPatch_VoiceAssignDataBlock_Skip19:
	calr	AccPatch_VoiceAssignDataBlock_Helper20
AccPatch_VoiceAssignDataBlock_Return9:
	ret
AccPatch_VoiceAssignDataBlock_Helper19:
	xor	xwa, xwa
	xor	xhl, xhl
	xor	xde, xde
	ld	wa, (14524:16)
	ld	hl, (14520:16)
	cp	wa, hl
	jr	c, AccPatch_VoiceAssignDataBlock_Skip20
	add	hl, 3
	cp	wa, hl
	jr	ugt, AccPatch_VoiceAssignDataBlock_Skip20
	ld	de, 0:i3
	jr	AccPatch_VoiceAssignDataBlock_Return10
AccPatch_VoiceAssignDataBlock_Skip20:
	ldw	de, 255
AccPatch_VoiceAssignDataBlock_Return10:
	ret
AccPatch_VoiceAssignDataBlock_Helper20:
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Return11
	cpw	(14524:16), 340
	jr	nc, AccPatch_VoiceAssignDataBlock_Skip22
	calr	AccPatch_VoiceAssignDataBlock_Helper29
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Return11
	ld	xwa, 4:i3
AccPatch_VoiceAssignDataBlock_Helper20_Loop:
	push	xwa
	calr	AccPatch_VoiceAssignDataBlock_Helper30
	pop	xwa
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Return11
	djnz8	a, AccPatch_VoiceAssignDataBlock_Helper20_Loop
	ldw	(14520:16), 0
	xor	xbc, xbc
	ld	bc, (14524:16)
	srl	bc, 2
	inc	1, bc
AccPatch_VoiceAssignDataBlock_Join6:
	cp	bc, 0:i3
	jr	ule, AccPatch_VoiceAssignDataBlock_Skip21
	push	xbc
	calr	AccPatch_VoiceAssignDataBlock_Helper30
	pop	xbc
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Return11
	addw	(0x38b8:16), 4
	dec	1, bc
	jr	AccPatch_VoiceAssignDataBlock_Join6
AccPatch_VoiceAssignDataBlock_Skip21:
	jr	AccPatch_VoiceAssignDataBlock_Return11
AccPatch_VoiceAssignDataBlock_Skip22:
	ld	(14488:16), 128
AccPatch_VoiceAssignDataBlock_Return11:
	ret
AccPatch_VoiceAssignDataBlock_Helper21:
	xor	xwa, xwa
	xor	xhl, xhl
	ld	wa, (14524:16)
	ld	hl, (14520:16)
	sub	wa, hl
	ldw	hl, 256
	mul	xwa, hl
	ld	(14530:16), wa
	ret
AccPatch_VoiceAssignDataBlock_Helper22:
	calr	AccPatch_VoiceAssignDataBlock_Helper21
	xor	xiy, xiy
	ld	iy, (14530:16)
	add	xiy, 6
	add	xiy, 432128
	xor	xhl, xhl
	ld	hl, (14526:16)
	calr	AccPatch_VoiceAssignDataBlock_Helper
	ld	xix, xiz
	add	xix, 6
	xor	xbc, xbc
	ldw	bc, 249
	ldir85
	ret
AccPatch_VoiceAssignDataBlock_Helper23:
	xor	xiy, xiy
	xor	xwa, xwa
	calr	AccPatch_VoiceAssignDataBlock_Helper21
	ld	iy, (14530:16)
	ld	xhl, 432128
	add	xhl, 3
	ld	wa, (xhl+iy)
	ld	(14524:16), wa
	xor	xhl, xhl
	ld	hl, (14526:16)
	ld	(14528:16), hl
	calr	AccPatch_VoiceAssignDataBlock_Helper
	ld	wa, (xiz+3)
	ld	(14526:16), wa
	ret
AccPatch_VoiceAssignDataBlock_Helper24:
	ld	wa, (14490:16)
	ld	(14524:16), wa
	ld	wa, (14510:16)
	ld	(14528:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper25
	ld	wa, (14492:16)
	ld	(14524:16), wa
	ld	wa, (14512:16)
	ld	(14528:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper25
	ld	wa, (14494:16)
	ld	(14524:16), wa
	ld	wa, (14514:16)
	ld	(14528:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper25
	ld	wa, (14496:16)
	ld	(14524:16), wa
	ld	wa, (14516:16)
	ld	(14528:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper25
	ld	wa, (14498:16)
	ld	(14524:16), wa
	ld	wa, (14518:16)
	ld	(14528:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper25
	ret
AccPatch_VoiceAssignDataBlock_Helper25:
	xor	xwa, xwa
	bit	7, (0x3898:16)
	jrl	nz, AccPatch_VoiceAssignDataBlock_Epilogue2
AccPatch_VoiceAssignDataBlock_Helper25_Join:
	cpw	(14524:16), 65535
	jr	z, AccPatch_VoiceAssignDataBlock_Epilogue
	calr	AccPatch_VoiceAssignDataBlock_Helper26
	cpw	(14522:16), 340
	jr	nc, AccPatch_VoiceAssignDataBlock_Skip23
	ld	wa, (14522:16)
	ld	(14526:16), wa
	calr	AccPatch_VoiceAssignDataBlock_Helper18
	bit	7, (0x3898:16)
	jr	nz, AccPatch_VoiceAssignDataBlock_Skip23
	calr	AccPatch_VoiceAssignDataBlock_Helper22
	xor	xhl, xhl
	ld	hl, (14528:16)
	calr	AccPatch_VoiceAssignDataBlock_Helper
	ld	wa, (14526:16)
	ld	(xiz+3), wa
	ld	hl, wa
	calr	AccPatch_VoiceAssignDataBlock_Helper
	or	(xiz), 128
	decw	1, (STYLE_FREE_BLOCKS:16)
	ld	wa, (14528:16)
	ld	(xiz+1), wa
	xor	xiy, xiy
	ld	iy, (14530:16)
	add	xiy, 432128
	ld	wa, (xiy+3)
	cp	wa, 65535
	jr	z, AccPatch_VoiceAssignDataBlock_Helper25_Skip
	ld	(xiz+3), wa
	jr	AccPatch_VoiceAssignDataBlock_Helper25_Join2
AccPatch_VoiceAssignDataBlock_Helper25_Skip:
	ldw	(xiz+3), 65535
AccPatch_VoiceAssignDataBlock_Helper25_Join2:
	ld	(14524:16), wa
	ld	wa, (14526:16)
	ld	(14528:16), wa
	jr	AccPatch_VoiceAssignDataBlock_Helper25_Join
AccPatch_VoiceAssignDataBlock_Skip23:
	ld	hl, (14526:16)
	calr	AccPatch_VoiceAssignDataBlock_Helper
	ldw	(xiz+3), 65535
AccPatch_VoiceAssignDataBlock_Epilogue:
	nop
AccPatch_VoiceAssignDataBlock_Epilogue2:
	nop
	ret
AccPatch_VoiceAssignDataBlock_Helper26:
	xor	xhl, xhl
	ld	hl, (14522:16)
	cp	hl, 340
	jr	nc, AccPatch_VoiceAssignDataBlock_Helper26_Skip2
AccPatch_VoiceAssignDataBlock_Join7:
	calr	AccPatch_VoiceAssignDataBlock_Helper
	ld	a, (xiz)
	bit	7, a
	jr	z, AccPatch_VoiceAssignDataBlock_Helper26_Skip2
	inc	1, hl
	cp	hl, 340
	jr	nc, AccPatch_VoiceAssignDataBlock_Helper26_Skip
	jr	AccPatch_VoiceAssignDataBlock_Join7
AccPatch_VoiceAssignDataBlock_Helper26_Skip:
	ld	(14488:16), 131
AccPatch_VoiceAssignDataBlock_Helper26_Skip2:
	ld	(14522:16), hl
	ret
AccPatch_VoiceAssignDataBlock_Helper27:
	ret
AccPatch_VoiceAssignDataBlock_Helper28:
	ret
AccPatch_VoiceAssignDataBlock_Helper29:
	ret
AccPatch_VoiceAssignDataBlock_Helper30:
	ret
AccPatch_VoiceAssignDataBlock_Helper31:
	cp	(14488:16), 0
	jr	z, AccPatch_VoiceAssignDataBlock_Skip28
	cp	(14488:16), 132
	jr	z, AccPatch_VoiceAssignDataBlock_Skip24
	cp	(14488:16), 130
	jr	z, AccPatch_VoiceAssignDataBlock_Skip27
	cp	(14488:16), 131
	jr	z, AccPatch_VoiceAssignDataBlock_Skip25
	cp	(14488:16), 129
	jr	z, AccPatch_VoiceAssignDataBlock_Skip26
	ld	(GLOBAL_ERROR_CODE:16), 1
	jr	AccPatch_VoiceAssignDataBlock_Return12
AccPatch_VoiceAssignDataBlock_Skip24:
	ld	(GLOBAL_ERROR_CODE:16), 3
	jr	AccPatch_VoiceAssignDataBlock_Return12
AccPatch_VoiceAssignDataBlock_Skip25:
	ld	(GLOBAL_ERROR_CODE:16), 23
	jr	AccPatch_VoiceAssignDataBlock_Return12
AccPatch_VoiceAssignDataBlock_Skip26:
	ld	(GLOBAL_ERROR_CODE:16), 1
	jr	AccPatch_VoiceAssignDataBlock_Return12
AccPatch_VoiceAssignDataBlock_Skip27:
	ld	(GLOBAL_ERROR_CODE:16), 0
	jr	AccPatch_VoiceAssignDataBlock_Return12
AccPatch_VoiceAssignDataBlock_Skip28:
	ld	(GLOBAL_ERROR_CODE:16), 35
AccPatch_VoiceAssignDataBlock_Return12:
	ret
cmp_ld_mae:
	push xiz
	calr CmpLoad_InitWithFlag
	pop xiz
	ret

CmpLoad_InitWithFlag:
	call AccDemo_InitWithFlag
	ret

cmp_ld_ato:
	push xiz
	calr CmpLoadAuto_CheckAndInit
	pop xiz
	ret

CmpLoadAuto_CheckAndInit:
	cp wa, 0:i3
	jr lt, CmpLoadAuto_DemoInit
	call AccPatch_ClearModeFlag
	jr CmpLoadAuto_CountSlots

CmpLoadAuto_DemoInit:
	call AccDemo_Init_Wrap

CmpLoadAuto_CountSlots:
	call AccPatch_CountAvailableSlots
	ret

cmp_sv_mae:
	push xiz
	calr CmpSave_InitSlotAndCalcSize
	pop xiz
	ret

CmpSave_InitSlotAndCalcSize:
	call AccPatch_InitSlotChain_WithAddr
	ld hl, wa
	extz xhl
	sll xhl, 4
	ret

cmp_sv_ato:
	push xiz
	calr CmpSaveAuto_ClearFlag
	pop xiz
	ret

CmpSaveAuto_ClearFlag:
	; anddi8 (0x8d88), 254 (v7 patched)
	and	(0x8cc8:16), 254
	ret



msp_ld_mae:
	push xiz
	calr MspLoad_InitVoice
	pop xiz
	ret

MspLoad_InitVoice:
	call AccompSeq_InitBankTables
	ret

msp_ld_ato:
	push xiz
	calr MspLoadAuto_CheckAndInit
	pop xiz
	ret

MspLoadAuto_CheckAndInit:
	cp wa, 0:i3
	jr lt, MspLoadAuto_NegativeCase
	jr MspLoadAuto_Return

MspLoadAuto_NegativeCase:
	call MspUser_ResetToFactory

MspLoadAuto_Return:
	ret

msp_sv_mae:
	push xiz
	calr MspSave_InitAndCalcSize
	pop xiz
	ret

MspSave_InitAndCalcSize:
	call Voice_RefreshBankData
	ld xhl, 0x1e881c
	ld hl, (xhl)
	extz xhl
	sll xhl, 4
	ret

msp_sv_ato:
	push xiz
	calr MspSaveAuto_Return
	pop xiz
	ret

MspSaveAuto_Return:
	ret

AccDisplay_FullInit:
	call	SeqBuf_Init
	call	NoteMap_SendAllNotesOff
	call	Part_ReinitAllActive
	call	AccompSeq_StopSequence
	call	AccWrap_PlayModeDispatch
	set	2, (SEQ_RTMCFG:16)
	call	AudioInit_RefreshToneBank
	call	NoteMap_ProcessAndMerge
	call	Voice_InitializeAll
	call	Voice_InitTablePair
	call	Voice_InitTableGroup
	call	MIDI_SendAllSoundOff
	call	Vga_SetupMultiPlaneDisplay
	jr	AccDisplay_CopyToBackBuffer
Display_RestoreEntry:
	res	2, (SEQ_RTMCFG:16)
	call Vga_RestoreMultiPlaneDisplay
	jr AccDisplay_CopyToFrontBuffer

AccDisplay_CopyToBackBuffer:
	lda xbc, (RHYTHM_PATTERN_BUF_A:24)

	ld	(21796:16), xbc

	lda xwa, (0x069800:24)

	ld	(21800:16), xwa

	ld xiy, xbc

	ld xix, xwa

	ldw bc, 0xb400

	ldirw

	ret



AccDisplay_CopyToFrontBuffer:
	lda xde, (RHYTHM_PATTERN_BUF_A:24)

	ld	(21796:16), xde

	lda xwa, (0x069800:24)

	ld	(21800:16), xwa

	ld xiy, xwa

	ld xix, xde

	ldw bc, 0xb400

	ldirw

	ret



AccBankData_InitAllSlots:
	pushw_erp 0xfa

	ld	xwa, (15524:16)

	ld	(21796:16), xwa

	ldib_erp 0xfb, 0

	ld wa, 0:i3



AccBankData_InitSlot_OuterLoop:
	ld xde, 0:i3

AccBankData_InitSlot_InnerLoop:
	lda	xbc, (xde+wa)
	add	xbc, (0x5524:16)
	lda	xbc, (xbc+160)
	cp	(xbc), 0
	jr	nz, AccBankData_InitSlot_NonZero
	ld	(xbc), 32
	jr	AccBankData_InitSlot_PadSpaces
AccBankData_InitSlot_NonZero:
	inc 1, xde
	cp xde, 0x10
	jr c, AccBankData_InitSlot_InnerLoop

AccBankData_InitSlot_PadSpaces:
	cp xde, 0x10
	jr nc, AccBankData_PadSpaces_Done
	cp xde, 0x10
	jr nc, AccBankData_PadSpaces_Done
AccBankData_PadSpaces_Loop:
	lda	xbc, (xde+wa)
	add	xbc, (21796:16)
	ld	(xbc+160), 32
	inc	1, xde
	cp	xde, 16
	jr	c, AccBankData_PadSpaces_Loop
AccBankData_PadSpaces_Done:
	inc1b_erp	251
	add	wa, 96
	cp_erpb	251, 12
	jr	c, AccBankData_InitSlot_OuterLoop
	ld	(18462:16), 0
	res	0, (0x34f8:16)
	ldib_erp	251, 0
AccBankData_ProcessSlot:
	lda	xwa, (432128:24)
	ld	(STYLE_SRC_IMAGE_PTR:16), xwa
	ldto_berp	a, 251
	ld	(STYLE_COPY_SRC_SECTION:16), a
	call	AccPatch_InitFromSlotIndex
	ld	xwa, (15524:16)
	ld	(STYLE_SRC_IMAGE_PTR:16), xwa
	lda	xwa, (432128:24)
	ld	(STYLE_DST_IMAGE_PTR:16), xwa
	ldto_berp	a, 251
	ld	(STYLE_COPY_DST_SECTION:16), a
	ldto_berp	a, 251
	ld	(STYLE_COPY_SRC_SECTION:16), a
	call	DualVoice_ParamLoadDone
	ld	a, (13560:16)
	extz	wa
	bit	0, wa
	jr	z, AccBankData_SlotFound
	ld	(18462:16), 1
	jr	AccBankData_ReInitAllSlots
AccBankData_SlotFound:
	inc1b_erp	251
	cp_erpb	251, 30
	jr	c, AccBankData_ProcessSlot
	cp	(18462:16), 0
	jr	z, AccBankData_FinalizeCheck
AccBankData_ReInitAllSlots:
	lda xwa, (0x069800:24)

	ld	(STYLE_SRC_IMAGE_PTR:16), xwa

	ldib_erp 0xfb, 0



AccBankData_ReInit_Loop:
	ldto_berp	a, 251
	ld	(STYLE_COPY_SRC_SECTION:16), a
	call	AccPatch_InitFromSlotIndex
	inc1b_erp	251
	cp_erpb	251, 30
	jr	c, AccBankData_ReInit_Loop	; -> 0xF6B9EF
AccBankData_FinalizeCheck:
	cp	(0x481e:16), 0
	jr	nz, AccBankData_Return
	ld	xwa, (0x3ca4:16)
	add	xwa, 92160
	ld	bc, (xwa)
	ld	xwa, 4:i3
	ld	de, 3:i3
	call	SoundParam_NotifyChange
	call	SeqTimer_UpdateTempoReg
	ld	xbc, (0x3ca4:16)
	add	xbc, 93184
	ld	xix, xbc
	ldib_erp	251, 0
	lda	xde, (0xe2d0:16)
AccBankData_CompareLoop:
	ldto_berp A, 0xfb
	extz wa
	ld hl, wa
	extz xhl
	add xhl, xde
	ld A, (xix+)
	cp a, (xhl)
	jr nz, AccBankData_Return
	inc1b_erp 0xfb
	cp_erpb 0xfb, 0x10
	jr c, AccBankData_CompareLoop
	ld xix, xbc
	lda xbc, (0x1e0000:24)
	ld xde, 0:i3

AccBankData_CopyToExtRAM:
	ld	a, (xix+)
	ld	(xbc+), a
	inc	1, xde
	cp	xde, 29350
	jr	c, AccBankData_CopyToExtRAM
	ld	wa, 0:i3
	call	PostTmSave_Success
AccBankData_Return:
	popw_erp 0xfa
	ret

AccBankData_ProcessWithCopy:
	dec 2, xsp

	pushw_erp 0xfa

	ld (xsp + 2), a

	ld	xbc, (15524:16)

	ld	(21796:16), xbc

	pushw 0xd

	ld	xwa, (15524:16)

	add xwa, 0x16802

	push xwa

	lda xwa, (xbc+160:16)

	push xwa

	call Mem_Copy

	lda xsp, (xsp + 10)

	ldib_erp 0xfb, 0

	ld bc, 0:i3
AccBankData_CopyLoop:
	ld	de, bc
	add	de, 160
	ld	xwa, (21796:16)
	lda	xwa, (xwa+de)
	ld	e, (xwa)
	cp	e, 0:i3
	jr	nz, AccBankData_CopyLoop_NonZero
	ld	e, 32:opc
AccBankData_CopyLoop_NonZero:
	ld	(xwa), e
	inc1b_erp	251
	inc	1, bc
	cp_erpb	251, 16
	jr	c, AccBankData_CopyLoop
	cp	(xsp+2), 2
	jr	ule, AccBankData_InitSlotScan
	call	Vga_BackupPlane3ToBuffer
	ld	c, (xsp+2)
	inc	7, c
	extz	bc
	ld	xde, (15524:16)
	ld	wa, 0:i3
	call	DualVoice_LoadAndScan
	call	Vga_RestorePlane3FromBuffer
	call	AccPatch_CountSlotsAlt
	jrl	AccBankData_PostModeChange
AccBankData_InitSlotScan:
	; stdi8 (0x48d6), 0 (v7 patched)
	ld	(0x481e:16), 0
	; resda 0, 0x35b0 (v7 patched)
	res	0, (0x34f8:16)
	ldib_erp 0xfb, 0
AccBankData_SlotScan_Loop:
	lda	xwa, (432128:24)
	ld	(STYLE_SRC_IMAGE_PTR:16), xwa
	ld	c, (xsp+2)
	extz	bc
	ldto_berp	a, 251
	extz	wa
	muls	wa, 3
	ld	de, wa
	add	de, bc
	lda	xwa, (AccBankData_SlotOrder:24)
	ld	(STYLE_COPY_SRC_SECTION), (xwa+de)
	call	AccPatch_InitFromSlotIndex
	ld	xwa, (15524:16)
	ld	(STYLE_SRC_IMAGE_PTR:16), xwa
	lda	xwa, (432128:24)
	ld	(STYLE_DST_IMAGE_PTR:16), xwa
	ldto_berp	a, 251
	extz	wa
	muls	wa, 3
	ld	bc, wa
	lda	xde, (AccBankData_SlotOrder:24)
	ld	(STYLE_COPY_SRC_SECTION), (xde+bc)
	ld	a, (xsp+2)
	extz	wa
	add	bc, wa
	ld	(STYLE_COPY_DST_SECTION), (xde+bc)
	call	DualVoice_ParamLoadDone
	ld	a, (13560:16)
	extz	wa
	bit	0, wa
	jr	z, AccBankData_SlotScan_Next
	ld	(18462:16), 1
	jr	AccBankData_SlotScan_ReInit
AccBankData_SlotScan_Next:
	inc1b_erp	251
	cp_erpb	251, 10
	jr	c, AccBankData_SlotScan_Loop
	cp	(18462:16), 0
	jr	z, AccBankData_NotifyAndUpdateTempo
AccBankData_SlotScan_ReInit:
	lda xwa, (0x069800:24)

	ld	(STYLE_SRC_IMAGE_PTR:16), xwa

	ldib_erp 0xfb, 0



AccBankData_ReInit_ScanLoop:
	ld	c, (xsp+2)
	extz	bc
	ldto_berp	a, 251
	extz	wa
	muls	wa, 3
	ld	de, wa
	add	de, bc
	lda	xwa, (AccBankData_SlotOrder:24)
	ld	(STYLE_COPY_SRC_SECTION), (xwa+de)
	call	AccPatch_InitFromSlotIndex
	inc1b_erp	251
	cp_erpb	251, 10
	jr	c, AccBankData_ReInit_ScanLoop
	jr	AccBankData_PostModeChange
AccBankData_NotifyAndUpdateTempo:
	ld	xwa, (15524:16)
	add	xwa, 92160
	ld	bc, (xwa)
	ld	xwa, 4:i3
	ld	de, 3:i3
	call	SoundParam_NotifyChange
	call	SeqTimer_UpdateTempoReg
AccBankData_PostModeChange:
	ldw wa, TT_STYLCNVCONT
	call UI_ChangeTitleByIndex
	popw_erp 0xfa
	inc 2, xsp
	ret

AccBankData_CopyDataBlock:
	lda	xbc, (18430:16)
	ld	xwa, xbc
	lda	xbc, (xbc+32)
AccBankData_ReInit_ScanLoop_Code_Loop:
	ld	(xwa+), 0
	cp	xwa, xbc
	jr	c, AccBankData_ReInit_ScanLoop_Code_Loop
	ret
StyleBuf_ClearAllEntries:
	lda	xbc, (16080:16)
	ld	xwa, xbc
	lda	xbc, (xbc+2048)
StyleBuf_ClearEntry_Outer:
	ld xde, xwa
	lda xhl, (xwa + 32)

StyleBuf_ClearEntry_Inner:
	ld (xde+), 0x00
	cp xde, xhl
	jr c, StyleBuf_ClearEntry_Inner
	lda xwa, (xwa + 32)
	cp xwa, xbc
	jr c, StyleBuf_ClearEntry_Outer
	ret

StyleConv_ClearWorkBuffer:
	lda	xbc, (18388:16)
	ld	xwa, xbc
	lda	xbc, (xbc+32)
StyleConv_ClearWorkBuf_Loop:
	ld (xwa+), 0x00
	cp xwa, xbc
	jr c, StyleConv_ClearWorkBuf_Loop
	ret

StyleConv_ClearEntryTables:
	lda	xwa, (18128:16)
	ld	xbc, xwa
	lda	xde, (16080:16)
	lda	xhl, (xwa+256)
StyleConv_ClearEntry_Outer:
	ld xwa, xde
	lda xix, (xde + 32)

StyleConv_ClearEntry_Inner:
	ld (xwa+), 0x00
	cp xwa, xix
	jr c, StyleConv_ClearEntry_Inner
	ld xwa, 0:i3
	ld (xbc+), XWA
	lda xde, (xde + 32)
	cp xbc, xhl
	jr c, StyleConv_ClearEntry_Outer
	ret

StyleConv_InitEntryTable:
	pushw iz
	ld ix, 0:i3

StyleConvInit_OuterLoop:
	ld	hl, ix
	mul	hl, 37
	lda	xde, (21804:16)
	ld	bc, hl
	extz	xbc
	add	xbc, xde
	ld	wa, ix
	extz	xwa
	div	wa, 20
	ld	wa, qwa
	ld	(xbc), a
	ld	iz, 0:i3
StyleConvInit_InnerLoop:
	ldib_erp 0xe2, 0
	cp iz, 0xc
	jr nc, StyleConvInit_StoreChar
	ldi_erpb 0xe2, 0x20

StyleConvInit_StoreChar:
	ld wa, hl
	add wa, iz
	ld iy, wa
	extz xiy
	add xiy, xde
	ldto_berp A, 0xe2
	ld (xiy + 1), a
	inc 1, iz
	cp iz, 0x20
	jr c, StyleConvInit_InnerLoop
	ld xwa, 0:i3
	ld (xbc + 33), xwa
	inc 1, ix
	cp ix, 0x100
	jr c, StyleConvInit_OuterLoop
	popw iz
	ret

SoundMem_ClearRegion:
	ld xwa, 0xffc00

SoundMem_ClearLoop:
	ld (xwa+), 0x00
	cp xwa, 0x100000
	jr c, SoundMem_ClearLoop
	ret

StyleFile_ClearAllTables:
	lda	xwa, (21668:16)
	ld	xbc, xwa
	lda	xde, (18468:16)
	lda	xhl, (xwa+128)
StyleFile_ClearTable_Outer:
	ld xwa, xde
	lda xix, (xde + 100)

StyleFile_ClearTable_Inner:
	ld (xwa+), 0x00
	cp xwa, xix
	jr c, StyleFile_ClearTable_Inner
	ld xwa, 0:i3
	ld (xbc+), XWA
	lda xde, (xde + 100)
	cp xbc, xhl
	jr c, StyleFile_ClearTable_Outer
	ret

DialUI_PostInitEvents:
	ld wa, 1:i3
	call UI_PostDialEnable
	ldw wa, 0x82
	call UI_PostDialValueEvent
	ld wa, 2:i3
	jp UI_PostDialRangeEvent

DialUI_CalcProlog:
	dec 2, xsp
	push xiz
	ld iz, wa
	extz xde
	div xde, iz
	mul xde, iz
	ld (xsp + 4), de
	ldiw_erp 0xfa, 0
	cp iz, 0:i3
	jr ule, DialCalc_Return

DialCalc_EventLoop:
	ld	xbc, 1114114
	ld	a, (CURRENT_TITLE:16)
	cp	a, 21
	jr	z, DialCalc_SetMode15
	cp	a, 18
	jr	z, DialCalc_SetMode12
	cp	a, 17
	jr	nz, PostEventSetup_Send
	ld	xbc, 1114114
	jr	PostEventSetup_Send
DialCalc_SetMode12:
	ld xbc, 0x120002
	jr PostEventSetup_Send

DialCalc_SetMode15:
	ld xbc, 0x150002

PostEventSetup_Send:
	ld	xwa, xbc
	ld	bc, (xsp+4)
	add	bc, qiz
	mul	bc, 37
	lda	xhl, (21804:16)
	ld	de, bc
	extz	xde
	add	xde, xhl
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	inc	1, qiz
	ld	wa, qiz
	cp	wa, iz
	jr	c, DialCalc_EventLoop
DialCalc_Return:
	pop xiz
	inc 2, xsp
	ret

StylCnvWaitTtlFunc:
	cp	xbc, EVT_SW_IN
	jr	z, AccChord_ReturnZero
	cp	xbc, EVT_ACTIVATE_STATE
	jr	nz, AccChord_ReturnZero
	cp	xde, 3
	jr	z, StylCnvWait_HandleClose
	cp	xde, 8
	jr	z, AccChord_ReturnZero
	cp	xde, 2
	jr	nz, AccChord_ReturnZero
	cp	(PREVIOUS_TITLE:16), 96
	jr	nz, StylCnvWait_CheckPending
	calr	StyleConv_InitEntryTable
	ld	(0x3c4e:16), 0
	calr	AccDisplay_FullInit
	call	FileIO_CheckMediaIsWritable
	cp	hl, 0:i3
	jr	nz, StylCnvWait_SetStatus
	ldw	wa, TT_STYLCNVMODL
	call	UI_ChangeTitleByIndex
StylCnvWait_SetStatus:
	ld	(18466:16), 0
	jr	AccChord_ReturnZero
StylCnvWait_CheckPending:
	cp	(0x4822:16), 0
	jr	z, AccChord_ReturnZero
	ld	(GLOBAL_ERROR_CODE:16), 74
	ldw	wa, TT_MESAGE
	call	UI_InterruptTitleByIndex
	ld	(0x4822:16), 0
	jr	AccChord_ReturnZero
StylCnvWait_HandleClose:
	cp	(CURRENT_TITLE:16), 96
	jr	z, StylCnvWait_RestoreDisplay
	cp	(CURRENT_MODE:16), 6
	jr	z, AccChord_ReturnZero
StylCnvWait_RestoreDisplay:
	calr Display_RestoreEntry

AccChord_ReturnZero:
	ld xhl, 0:i3
	ret

StylCnvTxtTtlFunc:
	cp xbc, EVT_SW_IN
	jr z, StylCnvTxt_ReturnZero
	cp xbc, EVT_ACTIVATE_STATE
	jr nz, StylCnvTxt_ReturnZero
	cp xde, 0x3
	jr z, StylCnvTxt_HandleClose
	cp xde, 0x8
	jr z, StylCnvTxt_ReturnZero
	cp xde, 0x2
	jr nz, StylCnvTxt_ReturnZero
	cp (0x0ffc00:24), 0x05
	jr nz, StylCnvTxt_ReturnZero
	ld (0x0ffc00:24), 0xff
	calr TableData_JumpToEntry
	calr FloppyState_Dispatch
	jr StylCnvTxt_ReturnZero

StylCnvTxt_HandleClose:
	cp	(CURRENT_MODE:16), 6
	call	nz, (Display_RestoreEntry:24)
StylCnvTxt_ReturnZero:
	ld xhl, 0:i3
	ret

StylCnvModlTtlFunc:
	lda	xsp, (xsp-36)
	push	xiz
	ld	xhl, xde
	ld	de, (STYLCNV_LIST_POS:16)
	ld	iz, de
	ld	wa, (14794:16)
	cp	xbc, EVT_SW_IN
	jrl	z, StylCnvModl_HandleOK
	cp	xbc, EVT_ACTIVATE_STATE
	jrl	nz, StylCnvModl_Return
	cp	xhl, 4
	jrl	z, StylCnvModl_HandleOpenItem
	cp	xhl, 5
	jrl	z, StylCnvModl_HandleClose
	cp	xhl, 3
	jrl	z, StylCnvModl_HandleRedraw
	cp	xhl, 8
	jrl	z, StylCnvModl_HandleScroll
	cp	xhl, 2
	jrl	nz, StylCnvModl_Return
	calr	DialUI_PostInitEvents
	ld	(18466:16), 0
	ld	xwa, StylCnvModl_CnvFilter
	call	ControlState_ProcessCommand
	ldw	(14794:16), 0
	ld	iz, 0:i3
StylCnvModl_ScanMatchingModels:
	ld	bc, iz
	mul	bc, 37
	lda	xwa, (21804:16)
	extz	xbc
	add	xbc, xwa
	lda	xwa, (xbc+1)
	lda	xbc, (xbc+33)
	call	FileIO_SearchStringMatch
	cp	hl, 0:i3
	jr	nz, StylCnvModl_ScanDone
	incw	1, (14794:16)
	inc	1, iz
	cp	iz, 256
	jr	c, StylCnvModl_ScanMatchingModels
StylCnvModl_ScanDone:
	cpw	(0x39ca:16), 0
	jr	nz, StylCnvModl_PadModelNames
	ldw	wa, TT_STYLCNVWAIT
	jrl	StylCnvModl_OK_Select_ShowError
StylCnvModl_PadModelNames:
	cp	iz, 256
	jr	nc, StylCnvModl_InitListDisplay
	lda	xhl, (21804:16)
	ld	bc, iz
	mul	bc, 37
StylCnvModl_PadOuterLoop:
	ld iy, 0:i3
	ld de, bc

StylCnvModl_PadInnerLoop:
	ld a, 0x0:opc
	cp iy, 0xc
	jr nc, StylCnvModl_PadStoreChar
	ld a, 0x20:opc

StylCnvModl_PadStoreChar:
	ld ix, de
	extz xix
	add xix, xhl
	ld (xix + 1), a
	inc 1, iy
	inc 1, de
	cp iy, 0x14
	jr c, StylCnvModl_PadInnerLoop
	inc 1, iz
	add bc, 0x25
	cp iz, 0x100
	jr c, StylCnvModl_PadOuterLoop

StylCnvModl_InitListDisplay:
	ldw	(STYLCNV_LIST_POS:16), 0
	ld	xwa, 1114114
	ld	xbc, EVT_SET_SELECTED_LINE
	ld	xde, 0:i3
	call	ApPostEvent
	lda	xbc, (16048:16)
	ld	xwa, xbc
	lda	xbc, (xbc+32)
StylCnvModl_ClearDisplayBuf:
	ld	(xwa+), 0
	cp	xwa, xbc
	jr	c, StylCnvModl_ClearDisplayBuf
	ld	xwa, StylCnvModl_VerFilter
	call	ControlState_ProcessCommand
	lda	xbc, (xsp+36)
	ld	xwa, 16048
	call	FileIO_SearchStringMatch
	lda	xwa, (16048:16)
	cp	hl, 0:i3
	jr	nz, StylCnvModl_CopyDefaultName
	pushw	46
	push	xwa
	call	Sprintf_StringLength
	inc	6, xsp
	or	xhl, xhl
	jr	z, StylCnvModl_FormatFilename
	ld	(xhl), 0
StylCnvModl_FormatFilename:
	ld	iy, 0:i3
	lda	xde, (16048:16)
StylCnvModl_FormatLoop:
	ld bc, iy
	extz xbc
	add xbc, xde
	ld a, (xbc)
	cp a, 0:i3
	jr z, StylCnvModl_DrawListUI
	cp a, 0x5f
	jr nz, StylCnvModl_CheckPercent
	ld (xbc), 0x20
	jr StylCnvModl_FormatNext

StylCnvModl_CheckPercent:
	cp a, 0x25
	jr nz, StylCnvModl_FormatNext
	ld (xbc), 0x2e

StylCnvModl_FormatNext:
	inc 1, iy
	cp iy, 0x20
	jr c, StylCnvModl_FormatLoop
	jr StylCnvModl_DrawListUI

StylCnvModl_CopyDefaultName:
	pushw	0
	pushw	58088
	push	xwa
	call	Strcpy
	inc	8, xsp
StylCnvModl_DrawListUI:
	ld xwa, 0x110007
	ld xbc, EVT_PAINT
	ld xde, 0:i3
	call ApDeliveryEvent
	lda xwa, (xsp + 4)
	lda xbc, (xsp + 36)
	call FileIO_SearchStringMatch
	cp hl, 0:i3
	jrl nz, StylCnvModl_Return

StylCnvModl_WaitForAck:
	lda xwa, (xsp + 4)
	lda xbc, (xsp + 36)
	call FileIO_SearchStringMatch
	cp hl, 0:i3
	jr z, StylCnvModl_WaitForAck
	jrl StylCnvModl_Return

StylCnvModl_HandleScroll:
	ld bc, wa
	cp wa, 0:i3
	jrl z, StylCnvModl_Return
	ldw wa, 0x14
	jrl StylCnvModl_OK_CallRedraw

StylCnvModl_HandleRedraw:
	cp (CURRENT_TITLE:16), 0x60
	jr z, StylCnvModl_RedrawDone
	cp (CURRENT_MODE:16), 0x06
	jr z, StylCnvModl_RedrawReturnZero
StylCnvModl_RedrawDone:
	calr Display_RestoreEntry

StylCnvModl_RedrawReturnZero:
	ld wa, 0:i3
	jr StylCnvModl_CallReturnAction

StylCnvModl_HandleClose:
	calr DialUI_PostInitEvents
	jrl StylCnvModl_Return

StylCnvModl_HandleOpenItem:
	ld wa, 0:i3

StylCnvModl_CallReturnAction:
	call UI_PostDialEnable
	jrl StylCnvModl_Return

StylCnvModl_HandleOK:
	cp xhl, 0xb
	jrl z, StylCnvModl_OK_SelectItem
	cp xhl, 0x84
	jrl z, StylCnvModl_OK_PageDown
	cp xhl, 0x4
	jrl z, StylCnvModl_OK_PageDown
	cp xhl, 0x83
	jrl z, StylCnvModl_OK_ScrollDown
	cp xhl, 0x82
	jrl z, StylCnvModl_OK_ScrollDown
	cp xhl, 0x3
	jrl z, StylCnvModl_OK_ScrollUp
	cp xhl, 0x2
	jrl z, StylCnvModl_OK_ScrollUp
	cp xhl, 0x81
	jr z, StylCnvModl_OK_PageUp
	cp xhl, 0x1
	jr nz, StylCnvModl_OK_LoadSelection

StylCnvModl_OK_PageUp:
	cp de, 0x14
	jr c, StylCnvModl_OK_LoadSelection
	sub de, 0x14

StylCnvModl_OK_StoreSelection:
	ld	(STYLCNV_LIST_POS:16), de
StylCnvModl_OK_LoadSelection:
	ld	bc, (STYLCNV_LIST_POS:16)
StylCnvModl_OK_UpdateDisplay:
	cp	iz, bc
	jrl	z, StylCnvModl_Return
	extz	xbc
	div	bc, 20
	ld	de, qbc
	extz	xde
	ld	xwa, 1114114
	ld	xbc, EVT_SET_SELECTED_LINE
	call	ApPostEvent
	ld	de, (STYLCNV_LIST_POS:16)
	ld	bc, de
	extz	xbc
	div	bc, 20
	ld	wa, iz
	extz	xwa
	div	wa, 20
	cp	wa, bc
	jrl	nz, StylCnvModl_OK_PageRedraw
	mul	iz, 37
	lda	xwa, (21804:16)
	ld	de, iz
	extz	xde
	add	xde, xwa
	ld	xwa, 1114114
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	ld	de, (STYLCNV_LIST_POS:16)
	mul	de, 37
	lda	xwa, (21804:16)
	extz	xde
	add	xde, xwa
	ld	xwa, 1114114
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	jrl	StylCnvModl_Return
StylCnvModl_OK_ScrollUp:
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	wa, (STYLCNV_LIST_POS:16)
	cp	wa, 0:i3
	jrl	z, StylCnvModl_OK_LoadSelection
	dec	1, wa
	ld	(STYLCNV_LIST_POS:16), wa
	ld	bc, wa
	jrl	StylCnvModl_OK_UpdateDisplay
StylCnvModl_OK_ScrollDown:
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	bc, (14794:16)
	dec	1, bc
	ld	wa, (STYLCNV_LIST_POS:16)
	cp	wa, bc
	jrl	nc, StylCnvModl_OK_LoadSelection
	inc	1, wa
	ld	(STYLCNV_LIST_POS:16), wa
	ld	bc, wa
	jrl	StylCnvModl_OK_UpdateDisplay
StylCnvModl_OK_PageDown:
	ld bc, de
	add bc, 0x14
	ld hl, wa
	cp bc, wa
	jr nc, StylCnvModl_OK_PageDown_Clamp
	add de, 0x14
	jrl StylCnvModl_OK_StoreSelection

StylCnvModl_OK_PageDown_Clamp:
	ld	bc, hl
	dec	1, bc
	ld	ix, bc
	extz	xix
	div	ix, 20
	extz	xde
	div	de, 20
	cp	de, ix
	jrl	nc, StylCnvModl_OK_LoadSelection
	extz	xhl
	div	hl, 20
	ld	wa, qhl
	cp	wa, 0:i3
	jrl	z, StylCnvModl_OK_LoadSelection
	ld	(STYLCNV_LIST_POS:16), bc
	jrl	StylCnvModl_OK_UpdateDisplay
StylCnvModl_OK_SelectItem:
	mul	de, 37
	lda	xwa, (21805:16)
	extz	xde
	add	xde, xwa
	ld	xwa, xde
	ld	xbc, StylCnv_ModeRb_Select
	call	FileIO_OpenWithBuiltPath
	cp	hl, 0:i3
	jr	ge, StylCnvModl_OK_Select_ClearMem
	ldw	wa, TT_STYLCNVWAIT
	jr	StylCnvModl_OK_Select_ShowError
StylCnvModl_OK_Select_ClearMem:
	ld xbc, 0x80000
	ld xwa, 0:i3

StylCnvModl_OK_Select_FillLoop:
	ld	(xbc+), 0
	inc	1, xwa
	cp	xwa, 196608
	jr	c, StylCnvModl_OK_Select_FillLoop
	ld	bc, (STYLCNV_LIST_POS:16)
	mul	bc, 37
	lda	xwa, (21837:16)
	extz	xbc
	add	xbc, xwa
	ld	xbc, (xbc)
	ld	xwa, 524288
	call	FileIO_ReadBlock
	cp	xhl, 0
	jr	ge, StylCnvModl_OK_Select_LoadOK
	call	FileIO_CloseHandle
	ldw	wa, TT_STYLCNVWAIT
StylCnvModl_OK_Select_ShowError:
	call UI_ChangeTitleByIndex
	jrl StylCnvModl_Return

StylCnvModl_OK_Select_LoadOK:
	ld	bc, (STYLCNV_LIST_POS:16)
	mul	bc, 37
	lda	xwa, (21837:16)
	extz	xbc
	add	xbc, xwa
	ld	xbc, (xbc)
	ld	xwa, xbc
	and	xwa, 255
	jr	z, StylCnvModl_OK_Select_AlignSize
	and	xbc, 4294967040
	add	xbc, 256
StylCnvModl_OK_Select_AlignSize:
	add	xbc, 524288
	ld	(15524:16), xbc
	call	FileIO_CloseHandle
	ld	(1047550:24), 0
	ld	wa, (STYLCNV_LIST_POS:16)
	ld	(18420:16), wa
	ld	iz, 0:i3
	lda	xhl, (58080:16)
	ld	wa, (STYLCNV_LIST_POS:16)
	mul	wa, 37
	lda	xbc, (21804:16)
StylCnvModl_OK_Select_CompareNames:
	ld ix, iz
	extz xix
	add xix, xhl
	ld de, wa
	add de, iz
	extz xde
	add xde, xbc
	ld e, (xde + 1)
	cp e, (xix)
	jr nz, StylCnvModl_OK_Select_StoreResult
	inc 1, iz
	cp iz, 0x8
	jr c, StylCnvModl_OK_Select_CompareNames

StylCnvModl_OK_Select_StoreResult:
	cp	iz, 8
	scc16	z, wa
	ld	(18420:16), wa
	ld	(1047552:24), 255
	ld	(1047553:24), 0
	pushw	4
	ld	wa, (STYLCNV_LIST_POS:16)
	mul	wa, 37
	extz	xwa
	add	xwa, xbc
	lda	xwa, (xwa+33)
	push	xwa
	ld	xwa, 1047554
	push	xwa
	call	Mem_Copy
	lda	xsp, (xsp+10)
	ld	bc, (STYLCNV_LIST_POS:16)
	mul	bc, 37
	lda	xwa, (21837:16)
	extz	xbc
	add	xbc, xwa
	ld	xwa, (xbc)
	ld	(15520:16), xwa
	calr	TableData_JumpToEntry
	calr	FloppyState_Dispatch
	jr	StylCnvModl_Return
StylCnvModl_OK_PageRedraw:
	ld	bc, (14794:16)
	ldw	wa, 20
StylCnvModl_OK_CallRedraw:
	calr DialUI_CalcProlog

StylCnvModl_Return:
	ld xhl, 0:i3
	pop xiz
	lda xsp, (xsp + 36)
	ret
StylCnvModl_End:

StylCnvCnvtTtlFunc:
	push	xiz
	ld	hl, (STYLCNV_LIST_POS:16)
	ld	iz, hl
	ld	ix, (14794:16)
	cp	xbc, EVT_SW_IN
	jrl	z, StylCnvCnvt_HandleOK
	cp	xbc, EVT_ACTIVATE_STATE
	jrl	nz, StylCnvCnvt_Return
	cp	xde, 4
	jrl	z, StylCnvCnvt_HandleOpenItem
	cp	xde, 5
	jrl	z, StylCnvCnvt_HandleClose
	cp	xde, 3
	jrl	z, StylCnvCnvt_HandleRedraw
	cp	xde, 8
	jrl	z, StylCnvCnvt_HandleScroll
	cp	xde, 2
	jrl	nz, StylCnvCnvt_Return
	ld	(18466:16), 0
	calr	DialUI_PostInitEvents
	ldw	(14794:16), 0
	ld	iz, 0:i3
StylCnvCnvt_ScanMatchingStyles:
	ld	bc, iz
	mul	bc, 37
	lda	xwa, (21804:16)
	extz	xbc
	add	xbc, xwa
	lda	xwa, (xbc+1)
	lda	xbc, (xbc+33)
	call	FileIO_SearchStringMatch
	cp	hl, 0:i3
	jr	nz, StylCnvCnvt_PadStyleNames
	incw	1, (14794:16)
	inc	1, iz
	cp	iz, 256
	jr	c, StylCnvCnvt_ScanMatchingStyles
StylCnvCnvt_PadStyleNames:
	cp	iz, 256
	jr	nc, StylCnvCnvt_InitListDisplay
	lda	xhl, (21804:16)
	ld	bc, iz
	mul	bc, 37
StylCnvCnvt_PadOuterLoop:
	ld iy, 0:i3
	ld de, bc

StylCnvCnvt_PadInnerLoop:
	ld a, 0x0:opc
	cp iy, 0xc
	jr nc, StylCnvCnvt_PadStoreChar
	ld a, 0x20:opc

StylCnvCnvt_PadStoreChar:
	ld ix, de
	extz xix
	add xix, xhl
	ld (xix + 1), a
	inc 1, iy
	inc 1, de
	cp iy, 0x20
	jr c, StylCnvCnvt_PadInnerLoop
	inc 1, iz
	add bc, 0x25
	cp iz, 0x100
	jr c, StylCnvCnvt_PadOuterLoop

StylCnvCnvt_InitListDisplay:
	ldw	(STYLCNV_LIST_POS:16), 0
	ld	xwa, 1179650
	ld	xbc, EVT_SET_SELECTED_LINE
	ld	xde, 0:i3
	call	ApPostEvent
	jrl	StylCnvCnvt_Return
StylCnvCnvt_HandleScroll:
	ldw wa, 0x14
	ld bc, ix
	ld de, hl
	jrl StylCnvCnvt_OK_CallRedraw

StylCnvCnvt_HandleRedraw:
	cp (CURRENT_MODE:16), 0x06
	call nz, (Display_RestoreEntry:24)
	ld wa, 0:i3
	jr t, StylCnvCnvt_CallReturnAction
StylCnvCnvt_HandleClose:
	calr DialUI_PostInitEvents
	jrl StylCnvCnvt_Return

StylCnvCnvt_HandleOpenItem:
	ld wa, 0:i3

StylCnvCnvt_CallReturnAction:
	call UI_PostDialEnable
	jrl StylCnvCnvt_Return

StylCnvCnvt_HandleOK:
	cp xde, 0xb
	jrl z, StylCnvCnvt_OK_SelectItem
	cp xde, 0x84
	jrl z, StylCnvCnvt_OK_PageDown
	cp xde, 0x4
	jrl z, StylCnvCnvt_OK_PageDown
	cp xde, 0x83
	jrl z, StylCnvCnvt_OK_ScrollDown
	cp xde, 0x82
	jrl z, StylCnvCnvt_OK_ScrollDown
	cp xde, 0x3
	jrl z, StylCnvCnvt_OK_ScrollUp
	cp xde, 0x2
	jrl z, StylCnvCnvt_OK_ScrollUp
	cp xde, 0x81
	jr z, StylCnvCnvt_OK_PageUp
	cp xde, 0x1
	jr nz, StylCnvCnvt_OK_LoadSelection

StylCnvCnvt_OK_PageUp:
	cp hl, 0x14
	jr c, StylCnvCnvt_OK_LoadSelection
	sub hl, 0x14

StylCnvCnvt_OK_StoreSelection:
	ld	(STYLCNV_LIST_POS:16), hl
StylCnvCnvt_OK_LoadSelection:
	ld	bc, (STYLCNV_LIST_POS:16)
StylCnvCnvt_OK_UpdateDisplay:
	cp	iz, bc
	jrl	z, StylCnvCnvt_Return
	extz	xbc
	div	bc, 20
	ld	de, qbc
	extz	xde
	ld	xwa, 1179650
	ld	xbc, EVT_SET_SELECTED_LINE
	call	ApPostEvent
	ld	de, (STYLCNV_LIST_POS:16)
	ld	bc, de
	extz	xbc
	div	bc, 20
	ld	wa, iz
	extz	xwa
	div	wa, 20
	cp	wa, bc
	jrl	nz, StylCnvCnvt_OK_PageRedraw
	mul	iz, 37
	lda	xwa, (21804:16)
	ld	de, iz
	extz	xde
	add	xde, xwa
	ld	xwa, 1179650
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	ld	de, (STYLCNV_LIST_POS:16)
	mul	de, 37
	lda	xwa, (21804:16)
	extz	xde
	add	xde, xwa
	ld	xwa, 1179650
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	jrl	StylCnvCnvt_Return
StylCnvCnvt_OK_ScrollUp:
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	wa, (STYLCNV_LIST_POS:16)
	cp	wa, 0:i3
	jrl	z, StylCnvCnvt_OK_LoadSelection
	dec	1, wa
	ld	(STYLCNV_LIST_POS:16), wa
	ld	bc, wa
	jrl	StylCnvCnvt_OK_UpdateDisplay
StylCnvCnvt_OK_ScrollDown:
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	bc, (14794:16)
	dec	1, bc
	ld	wa, (STYLCNV_LIST_POS:16)
	cp	wa, bc
	jrl	nc, StylCnvCnvt_OK_LoadSelection
	inc	1, wa
	ld	(STYLCNV_LIST_POS:16), wa
	ld	bc, wa
	jrl	StylCnvCnvt_OK_UpdateDisplay
StylCnvCnvt_OK_PageDown:
	ld wa, hl
	add wa, 0x14
	ld de, ix
	cp wa, ix
	jr nc, StylCnvCnvt_OK_PageDown_Clamp
	add hl, 0x14
	jrl StylCnvCnvt_OK_StoreSelection

StylCnvCnvt_OK_PageDown_Clamp:
	ld	bc, de
	dec	1, bc
	ld	ix, bc
	extz	xix
	div	ix, 20
	extz	xhl
	div	hl, 20
	cp	hl, ix
	jrl	nc, StylCnvCnvt_OK_LoadSelection
	extz	xde
	div	de, 20
	ld	wa, qde
	cp	wa, 0:i3
	jrl	z, StylCnvCnvt_OK_LoadSelection
	ld	(STYLCNV_LIST_POS:16), bc
	jrl	StylCnvCnvt_OK_UpdateDisplay
StylCnvCnvt_OK_SelectItem:
	ld	a, (15438:16)
	cp	a, 2:i3
	jr	z, StylCnvCnvt_OK_Select_WriteStyle
	cp	a, 1:i3
	jr	nz, StylCnvCnvt_Return
	ld	wa, (18420:16)
	cp	wa, 1:i3
	jr	z, StylCnvCnvt_OK_Select_Finalize
	cp	wa, 0:i3
	jr	z, StylCnvCnvt_OK_Select_Finalize
	jr	StylCnvCnvt_Return
StylCnvCnvt_OK_Select_WriteStyle:
	ld	xwa, (15524:16)
	ld	(15528:16), xwa
	call	FileIO_CheckMediaIsWritable
	ld	bc, (STYLCNV_LIST_POS:16)
	mul	bc, 37
	lda	xwa, (21805:16)
	extz	xbc
	add	xbc, xwa
	ld	xwa, xbc
	call	FileIO_NormalizePath
StylCnvCnvt_OK_Select_Finalize:
	ld (0x0ffc00:24), 0xff
	calr TableData_JumpToEntry
	calr FloppyState_Dispatch
	jr StylCnvCnvt_Return

StylCnvCnvt_OK_PageRedraw:
	ld	bc, (14794:16)
	ldw	wa, 20
StylCnvCnvt_OK_CallRedraw:
	calr DialUI_CalcProlog

StylCnvCnvt_Return:
	ld xhl, 0:i3
	pop xiz
	ret
StylCnvCnvt_End:

StylCnvSelTtlFunc:
	push	xiz
	ld	xhl, xbc
	ld	ix, (STYLCNV_LIST_POS:16)
	ld	iz, ix
	ld	bc, (14794:16)
	cp	xhl, EVT_SW_IN
	jr	z, StylCnvSel_HandleOK
	cp	xhl, EVT_ACTIVATE_STATE
	jrl	nz, StylCnvSel_Return
	cp	xde, 4
	jr	z, StylCnvSel_HandleOpenItem
	cp	xde, 5
	jr	z, StylCnvSel_HandleClose
	cp	xde, 3
	jr	z, StylCnvSel_HandleRedraw
	cp	xde, 8
	jr	z, StylCnvSel_HandleScroll
	cp	xde, 2
	jrl	nz, StylCnvSel_Return
	calr	DialUI_PostInitEvents
	ldw	(STYLCNV_LIST_POS:16), 0
	ld	xwa, 1376258
	ld	xbc, EVT_SET_SELECTED_LINE
	ld	xde, 0:i3
	call	ApPostEvent
	jrl	StylCnvSel_Return
StylCnvSel_HandleScroll:
	ldw wa, 0x14
	ld de, ix
	jrl StylCnvSel_OK_CallRedraw

StylCnvSel_HandleRedraw:
	cp	(CURRENT_MODE:16), 6
	call	nz, (Display_RestoreEntry:24)
	ld	wa, 0:i3
	jr	StylCnvSel_CallReturnAction
StylCnvSel_HandleClose:
	calr DialUI_PostInitEvents
	jrl StylCnvSel_Return

StylCnvSel_HandleOpenItem:
	ld wa, 0:i3

StylCnvSel_CallReturnAction:
	call UI_PostDialEnable
	jrl StylCnvSel_Return

StylCnvSel_HandleOK:
	cp xde, 0xb
	jrl z, StylCnvSel_OK_SelectItem
	cp xde, 0x84
	jrl z, StylCnvSel_OK_PageDown
	cp xde, 0x4
	jrl z, StylCnvSel_OK_PageDown
	cp xde, 0x83
	jrl z, StylCnvSel_OK_ScrollDown
	cp xde, 0x82
	jrl z, StylCnvSel_OK_ScrollDown
	cp xde, 0x3
	jrl z, StylCnvSel_OK_ScrollUp
	cp xde, 0x2
	jrl z, StylCnvSel_OK_ScrollUp
	cp xde, 0x81
	jr z, StylCnvSel_OK_PageUp
	cp xde, 0x1
	jr nz, StylCnvSel_OK_LoadSelection

StylCnvSel_OK_PageUp:
	cp ix, 0x14
	jr c, StylCnvSel_OK_LoadSelection
	sub ix, 0x14

StylCnvSel_OK_StoreSelection:
	ld	(STYLCNV_LIST_POS:16), ix
StylCnvSel_OK_LoadSelection:
	ld	bc, (STYLCNV_LIST_POS:16)
StylCnvSel_OK_UpdateDisplay:
	cp	iz, bc
	jrl	z, StylCnvSel_Return
	extz	xbc
	div	bc, 20
	ld	de, qbc
	extz	xde
	ld	xwa, 1376258
	ld	xbc, EVT_SET_SELECTED_LINE
	call	ApPostEvent
	ld	de, (STYLCNV_LIST_POS:16)
	ld	bc, de
	extz	xbc
	div	bc, 20
	ld	wa, iz
	extz	xwa
	div	wa, 20
	cp	wa, bc
	jrl	nz, StylCnvSel_OK_PageRedraw
	mul	iz, 37
	lda	xbc, (21804:16)
	ld	de, iz
	extz	xde
	add	xde, xbc
	ld	xwa, 1376258
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	ld	wa, (STYLCNV_LIST_POS:16)
	mul	wa, 37
	lda	xbc, (21804:16)
	ld	de, wa
	extz	xde
	add	xde, xbc
	ld	xwa, 1376258
	ld	xbc, EVT_PARA_DRAW
	call	ApPostEvent
	jrl	StylCnvSel_Return
StylCnvSel_OK_ScrollUp:
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	wa, (STYLCNV_LIST_POS:16)
	cp	wa, 0:i3
	jrl	z, StylCnvSel_OK_LoadSelection
	dec	1, wa
	ld	(STYLCNV_LIST_POS:16), wa
	ld	bc, wa
	jrl	StylCnvSel_OK_UpdateDisplay
StylCnvSel_OK_ScrollDown:
	ld	wa, 1:i3
	call	UI_PostEvent_0x6E
	ld	bc, (14794:16)
	dec	1, bc
	ld	wa, (STYLCNV_LIST_POS:16)
	cp	wa, bc
	jrl	nc, StylCnvSel_OK_LoadSelection
	inc	1, wa
	ld	(STYLCNV_LIST_POS:16), wa
	ld	bc, wa
	jrl	StylCnvSel_OK_UpdateDisplay
StylCnvSel_OK_PageDown:
	ld wa, ix
	add wa, 0x14
	ld de, bc
	cp wa, bc
	jr nc, StylCnvSel_OK_PageDown_Clamp
	add ix, 0x14
	jrl StylCnvSel_OK_StoreSelection

StylCnvSel_OK_PageDown_Clamp:
	ld	bc, de
	dec	1, bc
	ld	hl, bc
	extz	xhl
	div	hl, 20
	ld	wa, ix
	extz	xwa
	div	wa, 20
	cp	wa, hl
	jrl	nc, StylCnvSel_OK_LoadSelection
	extz	xde
	div	de, 20
	ld	wa, qde
	cp	wa, 0:i3
	jrl	z, StylCnvSel_OK_LoadSelection
	ld	(STYLCNV_LIST_POS:16), bc
	jrl	StylCnvSel_OK_UpdateDisplay
StylCnvSel_OK_SelectItem:
	calr	SoundMem_ClearRegion
	ld	(1047552:24), 255
	ld	wa, (STYLCNV_LIST_POS:16)
	inc	1, a
	ld	(1047553:24), a
	calr	TableData_JumpToEntry
	calr	FloppyState_Dispatch
	jr	StylCnvSel_Return
StylCnvSel_OK_PageRedraw:
	ld	bc, (14794:16)
	ldw	wa, 20
StylCnvSel_OK_CallRedraw:
	calr DialUI_CalcProlog

StylCnvSel_Return:
	ld xhl, 0:i3
	pop xiz
	ret
StylCnvSel_End:

StylCnvContTtlFunc:
	cp	xbc, EVT_SW_IN
	jr	z, StylCnvCont_HandleOK
	cp	xbc, EVT_ACTIVATE_STATE
	jrl	nz, AccRhythm_ReturnZero
	cp	xde, 3
	jr	z, StylCnvCont_HandleClose
	cp	xde, 8
	jrl	z, AccRhythm_ReturnZero
	cp	xde, 2
	jrl	nz, AccRhythm_ReturnZero
	cp	(0x481e:16), 0
	jr	z, StylCnvCont_CheckPending
	ld	(GLOBAL_ERROR_CODE:16), 15
	ldw	wa, TT_MESAGE
	call	UI_InterruptTitleByIndex
	ld	(0x481e:16), 0
StylCnvCont_CheckPending:
	cp	(0x4822:16), 0
	jr	z, AccRhythm_ReturnZero
	ld	(GLOBAL_ERROR_CODE:16), 74
	ldw	wa, TT_MESAGE
	call	UI_InterruptTitleByIndex
	ld	(0x4822:16), 0
	jr	AccRhythm_ReturnZero
StylCnvCont_HandleClose:
	cp	(CURRENT_MODE:16), 6
	jr	z, AccRhythm_ReturnZero
	calr	Display_RestoreEntry
	jr	AccRhythm_ReturnZero
StylCnvCont_HandleOK:
	cp	xde, 11
	jr	z, StylCnvCont_NotifyPart
	cp	xde, 10
	jr	nz, AccRhythm_ReturnZero
	ld	(15438:16), 0
	calr	SoundMem_ClearRegion
	ld	(1047552:24), 255
	ld	(1047553:24), 0
	pushw	4
	pushw	0
	pushw	15520
	ld	xwa, 1047554
	push	xwa
	call	Mem_Copy
	lda	xsp, (xsp+10)
	calr	TableData_JumpToEntry
	calr	FloppyState_Dispatch
	jr	AccRhythm_ReturnZero
StylCnvCont_NotifyPart:
	ld wa, MD_NORMAL:i3
	call UI_ChangeModeByIndex

AccRhythm_ReturnZero:
	ld xhl, 0:i3
	ret

StylCnvStorTtlFunc:
	cp xbc, EVT_ACTIVATE_STATE
	jr nz, StylCnvStor_ReturnZero
	cp xde, 0x3
	jr z, StylCnvStor_HandleClose
	ld xhl, 0:i3
	ret

StylCnvStor_HandleClose:
	cp	(CURRENT_MODE:16), 6
	call	nz, (Display_RestoreEntry:24)
StylCnvStor_ReturnZero:
	ld xhl, 0:i3
	ret

MainStylCnvFunc:
	extz de
	ld wa, de
	calr AccBankData_ProcessWithCopy
	ld xhl, 0:i3
	ret

StylCnv_ReportErrorAndReturn:
	ld	(18466:16), 255
	ldw	wa, TT_STYLCNVWAIT
	jp	UI_ChangeTitleByIndex
FloppyState_Dispatch:
	lda xsp, (xsp - 114)
	push xiz

StyleConv_DispatchSoundMemState:
	ld a, (0x0ffc00:24)
	cp a, 0:i3
	jr nz, StylCnvDisp_CheckFE
	cpw	(0x47f4:16), 0x0001
	jr nz, StylCnvDisp_PostMode13
	calr AccBankData_InitAllSlots
	ld wa, MD_NORMAL:i3
	call UI_ChangeModeByIndex
	jrl t, StylCnv_Epilogue114
StylCnvDisp_PostMode13:
	ldw wa, TT_STYLCNVSTOR
	jrl StylCnv_PostModeChange

StylCnvDisp_CheckFE:
	cp	a, 254
	jr	nz, StylCnvDisp_CheckType
	ld	(18466:16), 255
	ldw	wa, TT_STYLCNVCONT
	jrl	StylCnv_PostModeChange
StylCnvDisp_CheckType:
	cp	a, 3:i3
	jrl	z, StylCnv_Multi_InitAndClear
	cp	a, 4:i3
	jrl	z, StylCnv_DispatchByType
	cp	a, 2:i3
	jr	z, StylCnvDisp_Type2_CheckSubtype
	lda	xbc, (15536:16)
	cp	a, 1:i3
	jr	z, StylCnvDisp_Type1_CopyPath
	cp	a, 5:i3
	jrl	nz, StylCnv_AbortWithError
	ld	xwa, 1047553
	push	xwa
	push	xbc
	call	Strcpy
	inc	8, xsp
	ld	(15438:16), 5
	ldw	wa, TT_STYLCNVTXT
	jrl	StylCnv_PostModeChange
StylCnvDisp_Type1_CopyPath:
	ld xwa, 0xffc01
	push xwa
	push xbc
	jr StylCnvDisp_CopyAndFinalize

StylCnvDisp_Type2_CheckSubtype:
	ld	a, (1047553:24)
	cp	a, 64
	jrl	z, StylCnv_Type4_Init
	cp	a, 128
	jr	z, StylCnvDisp_Subtype80_Process
	cp	a, 16
	jr	z, StylCnvDisp_Subtype10_Process
	cp	a, 0:i3
	jrl	nz, StyleConv_DispatchSoundMemState
	ld	(15438:16), 1
	ld	xwa, 1047552
	call	ControlState_ProcessCommand
	lda	xbc, (15440:16)
	ld	(xbc), 2
	ld	(xbc+1), 0
	ld	xwa, 1047554
	push	xwa
	lda	xwa, (xbc+2)
	push	xwa
	jr	StylCnvDisp_CopyAndFinalize
StylCnvDisp_Subtype10_Process:
	ld	(15438:16), 2
	ld	xwa, 1047552
	call	ControlState_ProcessCommand
	ld	xwa, 1047552
	push	xwa
	lda	xwa, (15440:16)
	push	xwa
StylCnvDisp_CopyAndFinalize:
	call	Strcpy
	inc	8, xsp
	jrl	StylCnv_ClearAndFinalize
StylCnvDisp_Subtype80_Process:
	cp (0x0ffc02:24), 0x2e

	jrl nz, ControlState_Type3

	ld	(15438:16), 6

	calr StyleBuf_ClearAllEntries

	calr StyleConv_ClearWorkBuffer

	ldw (xsp + 4), 0x0

	; stdi16 (0x48d8), 0 (v7 patched)
	ldw	(0x4820:16), 0
StylCnvDisp_ScanFileLoop:
	pushw 0x0003
	pushw StylCnv_Str_Stars@hi16
	pushw StylCnv_Str_Stars@lo16
	ld WA,(XSP+0x0a)
	inc 2,WA
	extz XWA
	add XWA,0x000ffc00
	push XWA
	call String_Compare
	add XSP,0x0000000a
	cp hl, 0:i3
	jr z, StylCnv_ParseEntry_Done
	ld WA,(XSP+0x04)
	inc 2,WA
	extz XWA
	add XWA,0x000ffc00
	ld A,(XWA)
	cp A,0x2a
	jrl z, ControlState_Type3
	cp A,0x3f
	jrl z, ControlState_Type3
	ldw (XSP+0x06), 0x0000
StylCnv_ParseEntry_ScanChar:
	ld	wa, (xsp+4)
	inc	2, wa
	extz	xwa
	add	xwa, 1047552
	ld	a, (xwa)
	cp	a, 44
	jr	nz, StylCnv_ParseEntry_StoreChar
	incw	1, (18464:16)
	jr	StylCnv_ParseEntry_NextField
StylCnv_ParseEntry_StoreChar:
	ld	bc, (0x4820:16)
	sll	bc, 5
	ld	de, (xsp+6)
	add	de, bc
	lda	xbc, (0x3ed0:16)
	extz	xde
	add	xde, xbc
	ld	(xde), a
	incm	1, (xsp+6)
	incm	1, (xsp+4)
	cpw	(xsp+6), 32
	jr	lt, StylCnv_ParseEntry_ScanChar
StylCnv_ParseEntry_NextField:
	incw 1, (xsp + 4)
	cpw (xsp + 4), 0x80
	jrl lt, StylCnvDisp_ScanFileLoop

StylCnv_ParseEntry_Done:
	ldw	(xsp+4), 0
	ld	ix, (STYLCNV_LIST_POS:16)
	mul	ix, 37
	lda	xhl, (21804:16)
StylCnv_CopyNameLoop:
	ld	wa, (xsp+4)
	add	wa, ix
	extz	xwa
	add	xwa, xhl
	ld	c, (xwa+1)
	cp	c, 46
	jr	z, StylCnv_CopyName_Finalize
	lda	xde, (0x47d4:16)
	ld	wa, (xsp+4)
	ld	(xde+wa), c
	incm	1, (xsp+4)
	cpw	(xsp+4), 32
	jr	lt, StylCnv_CopyNameLoop
StylCnv_CopyName_Finalize:
	pushw	0
	pushw	16080
	pushw	0
	pushw	18388
	jrl	StylCnv_AppendAndClear
ControlState_Type3:
	ld	(15438:16), 3
	ld	xwa, 1047552
	call	ControlState_ProcessCommand
	jrl	StylCnv_ClearAndFinalize
StylCnv_Type4_Init:
	ld	(15438:16), 4
	lda	xde, (18430:16)
	ld	xwa, xde
	lda	xbc, (xde+32)
StylCnv_Type4_ClearLoop:
	ld (xwa+), 0x00
	cp xwa, xbc
	jr c, StylCnv_Type4_ClearLoop
	ldw (xsp + 4), 0x0
	ld iz, 0:i3

StylCnv_Type4_MainLoop:
	cpw (xsp + 4), 0x0
	jr nz, LoopIndex_Reset
	ldw (xsp + 6), 0x0
	cpw (xsp + 4), 0x28
	jr ge, LoopIndex_Reset

StylCnv_Type4_CopyChars:
	ld wa, (xsp + 4)
	inc 2, wa
	extz xwa
	add xwa, 0xffc00
	ld c, (xwa)
	cp c, 0:i3
	jr z, LoopIndex_Reset
	ld wa, (xsp + 6)
	ld	(xde+wa), c
	incw 1, (xsp + 4)
	incw 1, (xsp + 6)
	cpw (xsp + 4), 0x28
	jr lt, StylCnv_Type4_CopyChars

LoopIndex_Reset:
	ldw (xsp + 6), 0x0

StylCnv_Type4_FindDot:
	ld wa, (xsp + 6)
	cp	(xde+wa), 0x2e
	jr z, StylCnv_Type4_CalcExtLen
	incw 1, (xsp + 6)
	cpw (xsp + 6), 0x20
	jr lt, StylCnv_Type4_FindDot

StylCnv_Type4_CalcExtLen:
	ldw (xsp + 16), 0x0

StylCnv_Type4_CountExt:
	ld wa, (xsp + 6)
	cp	(xde+wa), 0x00
	jr z, StylCnv_Type4_CalcCenter
	incw 1, (xsp + 16)
	incw 1, (xsp + 6)
	cpw (xsp + 16), 0x20
	jr lt, StylCnv_Type4_CountExt

StylCnv_Type4_CalcCenter:
	ld wa, (xsp + 16)
	exts xwa
	divs wa, 0x2
	ldto_werp WA, 0xe2
	ldiw_erp 0xfa, 1
	cp wa, 0:i3
	jr nz, StylCnv_Type4_CheckNull
	ldiw_erp 0xfa, 2

StylCnv_Type4_CheckNull:
	ld	wa, (xsp+4)
	inc	2, wa
	extz	xwa
	add	xwa, 1047552
	cp	(xwa), 0
	jr	nz, StylCnv_Type4_Advance
	inc	1, iz
	cp	iz, qiz
	jr	nz, StylCnv_Type4_Advance
	incm	1, (xsp+4)
	pushw	4
	ld	wa, (xsp+6)
	inc	2, wa
	extz	xwa
	add	xwa, 1047552
	push	xwa
	pushw	0
	pushw	18422
	call	Mem_Copy
	incm	4, (xsp+14)
	pushw	4
	ld	wa, (xsp+16)
	inc	2, wa
	extz	xwa
	add	xwa, 1047552
	push	xwa
	pushw	0
	pushw	18426
	call	Mem_Copy
	lda	xsp, (xsp+20)
	jr	StylCnv_Type4_BuildOutput
StylCnv_Type4_Advance:
	incw 1, (xsp + 4)
	cpw (xsp + 4), 0x20
	jrl lt, StylCnv_Type4_MainLoop

StylCnv_Type4_BuildOutput:
	calr	StyleConv_ClearWorkBuffer
	ldw	(xsp+4), 0
	ld	ix, (STYLCNV_LIST_POS:16)
	mul	ix, 37
	lda	xhl, (21804:16)
StylCnv_Type4_CopyNameLoop2:
	ld	wa, (xsp+4)
	add	wa, ix
	extz	xwa
	add	xwa, xhl
	ld	e, (xwa+1)
	lda	xbc, (0x47d4:16)
	cp	e, 46
	jr	z, StylCnv_Type4_AppendExt
	ld	wa, (xsp+4)
	ld	(xbc+wa), e
	incm	1, (xsp+4)
	cpw	(xsp+4), 32
	jr	lt, StylCnv_Type4_CopyNameLoop2
StylCnv_Type4_AppendExt:
	pushw	0
	pushw	18430
	push	xbc
StylCnv_AppendAndClear:
	call	Strcat
	inc	8, xsp
StylCnv_ClearAndFinalize:
	ld (0x0ffc00:24), 0xff
	jrl StylCnv_FinalizeAndCheckStatus

StylCnv_DispatchByType:
	ld	a, (0x3c4e:16)
	cp a, 6:i3
	jrl z, StylCnv_Type6_Dispatch
	cp a, 4:i3
	jrl z, StylCnv_Type4_OpenFile
	cp a, 3:i3
	jr z, StylCnv_Type3_ProcessFiles
	cp a, 2:i3
	jr z, .Lc_f6cb6c
	cp a, 1:i3
	jrl nz, StyleConv_DispatchSoundMemState
	cp (CURRENT_TITLE:16), 0x16
	jrl nz, StylCnv_Epilogue114
	ldw WA, TT_STYLCNVCNVT
	jrl t, StylCnv_PostModeChange
StylCnv_Type2_CheckSoundMem:
.Lc_f6cb6c:
	cp (CURRENT_TITLE:16), 0x16
	jrl nz, StylCnv_Epilogue114

	ldw wa, TT_STYLCNVCNVT

	; jrl StylCnv_PostModeChange (v7 displacement)
	jrl	StylCnv_PostModeChange
StylCnv_Type3_ProcessFiles:
	ld	xwa, (15524:16)
	ld	(xsp+10), xwa
	ldw	(xsp+4), 0
	calr	StyleConv_ClearEntryTables
	calr	StyleFile_ClearAllTables
	ld	xwa, 18388
	ld	xbc, 18384
	call	FileIO_SearchStringMatch
	cp	hl, 0:i3
	jr	lt, StylCnv_Type3_CheckCount	; -> 0xF6CC10
StylCnv_Type3_SearchLoop:
	cpw	(xsp+4), 32
	jr	ge, StylCnv_Type3_SearchNext
	ld	xwa, (0x47d0:16)
	cp	xwa, 0
	jr	lt, StylCnv_Type3_SearchNext
	call	FileIO_ExtractBasename
	push	xhl
	lda	xwa, (xsp+22)
	push	xwa
	call	Strcpy
	pushw	0
	pushw	18388
	lda	xwa, (xsp+30)
	push	xwa
	call	Strcat
	lda	xwa, (xsp+34)
	push	xwa
	ld	wa, (xsp+24)
	mul	wa, 100
	lda	xbc, (0x4824:16)
	extz	xwa
	add	xwa, xbc
	push	xwa
	call	Strcpy
	lda	xsp, (xsp+24)
	ld	de, (xsp+4)
	sll	de, 2
	lda	xbc, (0x54a4:16)
	extz	xde
	add	xde, xbc
	ld	xwa, (0x47d0:16)
	ld	(xde), xwa
	incm	1, (xsp+4)
StylCnv_Type3_SearchNext:
	ld	xwa, 18388
	ld	xbc, 18384
	call	FileIO_SearchStringMatch
	cp	hl, 0:i3
	jr	ge, StylCnv_Type3_SearchLoop
StylCnv_Type3_CheckCount:
	cpw (xsp + 4), 0x0
	jrl z, StylCnv_AbortWithError
	ldw (xsp + 8), 0x0
	cpw (xsp + 4), 0x0
	jrl le, StylCnv_Type3_BuildFfcBuffer

StylCnv_Type3_LoadFileLoop:
	ld	wa, (xsp+8)
	mul	wa, 100
	lda	xbc, (18468:16)
	extz	xwa
	add	xwa, xbc
	push	xwa
	lda	xwa, (xsp+22)
	push	xwa
	call	Strcpy
	inc	8, xsp
	lda	xwa, (xsp+18)
	ld	xbc, StylCnv_ModeRb_Type3
	call	FileIO_OpenWithBuiltPath
	cp	hl, 0:i3
	jrl	lt, StylCnv_AbortWithError
	ld	wa, (xsp+8)
	sll	wa, 2
	lda	xbc, (21668:16)
	extz	xwa
	add	xwa, xbc
	ld	xbc, (xwa)
	ld	(18384:16), xbc
	ld	xwa, (xsp+10)
	call	FileIO_ReadBlock
	cp	xhl, 0
	jrl	lt, FileIO_ErrorExit
	ld	bc, (xsp+8)
	sll	bc, 2
	lda	xwa, (18128:16)
	extz	xbc
	add	xbc, xwa
	ld	xwa, (xsp+10)
	ld	(xbc), xwa
	ld	xwa, (18384:16)
	add	(xsp+10), xwa
	ld	xwa, (xsp+10)
	ld	(15528:16), xwa
	pushw	46
	lda	xwa, (xsp+20)
	push	xwa
	call	Sprintf_StringLength
	inc	6, xsp
	ld	wa, (xsp+8)
	lda	xbc, (16080:16)
	sll	wa, 5
	extz	xwa
	add	xwa, xbc
	or	xhl, xhl
	jr	z, StylCnv_Type3_EmptyName
	push	xhl
	push	xwa
	call	Strcpy
	inc	8, xsp
	jr	StylCnv_Type3_CloseFile
StylCnv_Type3_EmptyName:
	ld (xwa), 0x0

StylCnv_Type3_CloseFile:
	call FileIO_CloseHandle
	incw 1, (xsp + 8)
	ld wa, (xsp + 8)
	cp wa, (xsp + 4)
	jrl lt, StylCnv_Type3_LoadFileLoop

StylCnv_Type3_BuildFfcBuffer:
	calr SoundMem_ClearRegion
	ld (0x0ffc00:24), 0xff
	ld (0x0ffc01:24), 0x00
	ldw (xsp + 16), 0x0
	ldiw_erp 0xfa, 0
	cpw (xsp + 4), 0x0
	jrl le, StylCnv_FinalizeAndCheckStatus

StylCnv_Type3_CopyBlockLoop:
	pushw	4
	ld	bc, (xsp+18)
	sll	bc, 2
	lda	xwa, (18128:16)
	extz	xbc
	add	xbc, xwa
	push	xbc
	ld	wa, qiz
	inc	2, wa
	extz	xwa
	add	xwa, 1047552
	push	xwa
	call	Mem_Copy
	lda	xsp, (xsp+10)
	inc	4, qiz
	ld	iz, 0:i3
	ld	bc, (xsp+16)
	sll	bc, 5
	lda	xde, (16080:16)
StylCnv_Type3_CopyNameChars:
	ld wa, iz
	inc 1, wa
	add wa, bc
	extz xwa
	add xwa, xde
	ld a, (xwa)
	cp a, 0:i3
	jr z, StylCnv_Type3_TerminateName
	ldto_werp HL, 0xfa
	inc 2, hl
	extz xhl
	add xhl, 0xffc00
	ld (xhl), a
	inc1w_erp 0xfa
	inc 1, iz
	cp iz, 0x20
	jr lt, StylCnv_Type3_CopyNameChars

StylCnv_Type3_TerminateName:
	ldto_werp WA, 0xfa
	inc 2, wa
	extz xwa
	add xwa, 0xffc00
	ld (xwa), 0x0
	inc1w_erp 0xfa
	ld wa, iz
	exts xwa
	divs wa, 0x2
	ldto_werp WA, 0xe2
	cp wa, 0:i3
	jr nz, StylCnv_Type3_NextBlock
	ldto_werp WA, 0xfa
	inc 2, wa
	extz xwa
	add xwa, 0xffc00
	ld (xwa), 0x0
	inc1w_erp 0xfa

StylCnv_Type3_NextBlock:
	incw 1, (xsp + 16)
	ld wa, (xsp + 16)
	cp wa, (xsp + 4)
	jrl lt, StylCnv_Type3_CopyBlockLoop
	jrl StylCnv_FinalizeAndCheckStatus

StylCnv_Type4_OpenFile:
	ld	xwa, 18388
	ld	xbc, StylCnv_ModeRb_Type4
	call	FileIO_OpenWithMode
	cp	hl, 0:i3
	jr	lt, StylCnv_AbortWithError
	ld	xwa, 0:i3
	ld	bc, 2:i3
	call	FileIO_SeekAndReadBlock
	cp	hl, 0:i3
	jr	lt, FileIO_ErrorExit
	call	FileIO_SeekWriteBlock_Impl
	ld	(15532:16), xhl
	call	FileIO_SeekRead_ExtReturn
	ld	xwa, (18422:16)
	ld	bc, 0:i3
	call	FileIO_SeekAndReadBlock
	cp	hl, 0:i3
	jr	lt, FileIO_ErrorExit
	ld	xwa, (15524:16)
	ld	xbc, (18426:16)
	call	FileIO_ReadBlock
	cp	xhl, 0
	jr	ge, StylCnv_Type4_ClearAndBuild
FileIO_ErrorExit:
	call FileIO_CloseHandle

StylCnv_AbortWithError:
	calr StylCnv_ReportErrorAndReturn
	jrl StylCnv_Epilogue114

StylCnv_Type4_ClearAndBuild:
	calr	SoundMem_ClearRegion
	ld	(1047552:24), 255
	ld	(1047553:24), 0
	pushw	4
	pushw	0
	pushw	15524
	ld	xwa, 1047554
	push	xwa
	call	Mem_Copy
	lda	xsp, (xsp+10)
	ldw	(xsp+4), 0
	lda	xde, (18430:16)
StylCnv_Type4_CopyFieldLoop:
	ld bc, (xsp + 4)
	inc 6, bc
	extz xbc
	add xbc, 0xffc00
	ld wa, (xsp + 4)
	inc 1, wa
	ld	a, (xde+wa)
	ld (xbc), a
	cp a, 0:i3
	jrl z, StylCnv_FinalizeAndCheckStatus
	incw 1, (xsp + 4)
	cpw (xsp + 4), 0x20
	jr lt, StylCnv_Type4_CopyFieldLoop
	jrl StylCnv_FinalizeAndCheckStatus

StylCnv_Type6_Dispatch:
	ld	wa, (0x47f4:16)
	cp wa, 1:i3
	jrl z, StylCnv_Type6_Case1_CopyName
	cp wa, 0:i3
	jrl nz, StyleConv_DispatchSoundMemState
	lda	xwa, (0x46d0:16)
	ld XBC,XWA
	lda xde, (xwa+256)
StylCnv_Type6_ClearRegion:
	ld	xwa, 0:i3
	ld	(xbc+), xwa
	cp	xbc, xde
	jr	c, StylCnv_Type6_ClearRegion
	ld	xwa, (15524:16)
	ld	(15528:16), xwa
	ldw	(xsp+4), 0
	cpw	(18464:16), 0
	jrl	ule, StylCnv_Type6_BuildFfcBuffer
StylCnv_Type6_MainLoop:
	ld	iz, 0:i3
	lda	xbc, (18388:16)
StylCnv_Type6_FindDot:
	cp	(xbc+iz), 0x2e
	jr z, StylCnv_Type6_ClearRemainder
	inc 1, iz
	cp iz, 0x20
	jr lt, StylCnv_Type6_FindDot

StylCnv_Type6_ClearRemainder:
	cp iz, 0x20
	jr ge, StylCnv_Type6_AppendName

StylCnv_Type6_ClearLoop:
	ld	(xbc+iz), 0x00
	inc 1, iz
	cp iz, 0x20
	jr lt, StylCnv_Type6_ClearLoop

StylCnv_Type6_AppendName:
	ld	de, (xsp+4)
	sll	de, 5
	lda	xwa, (16080:16)
	extz	xde
	add	xde, xwa
	push	xde
	push	xbc
	call	Strcat
	inc	8, xsp
	ld	xwa, 18388
	ld	xbc, StylCnv_ModeRb_Type6
	call	FileIO_OpenWithMode
	cp	hl, 0:i3
	jrl	lt, StylCnv_Type6_FileOpenError
	ld	xwa, 0:i3
	ld	bc, 2:i3
	call	FileIO_SeekAndReadBlock
	cp	hl, 0:i3
	jrl	lt, StylCnv_Type6_FileReadError
	call	FileIO_SeekWriteBlock_Impl
	ld	(15532:16), xhl
	call	FileIO_SeekRead_ExtReturn
	ld	xwa, (15528:16)
	ld	xbc, (15532:16)
	call	FileIO_ReadBlock
	call	FileIO_CloseHandle
	cp	xhl, 0
	jrl	lt, StylCnv_AbortWithError
	ld	bc, (xsp+4)
	sll	bc, 2
	lda	xwa, (18128:16)
	extz	xbc
	add	xbc, xwa
	ld	xwa, (15528:16)
	ld	(xbc), xwa
	ld	xwa, (15532:16)
	add	(15528:16), xwa
StylCnv_Type6_AdvanceEntry:
	incw 1, (xsp + 4)

	ld wa, (xsp + 4)

	; cpda16 xwa, 0x48d8 (v7 patched)
	cp	wa, (0x4820:16)
	; jrl c, StylCnv_Type6_MainLoop (v7 displacement)
	jrl	c, StylCnv_Type6_MainLoop
StylCnv_Type6_BuildFfcBuffer:
	calr SoundMem_ClearRegion

	ld (0x0ffc00:24), 0xff

	ld (0x0ffc01:24), 0x00

	ldw (xsp + 4), 0x0

	ld iz, 0:i3

	; cpdi16 0x48d8, 0 (v7 patched)
	cpw	(0x4820:16), 0
	; jrl ule, StylCnv_FinalizeAndCheckStatus (v7 displacement)
	jrl	ule, StylCnv_FinalizeAndCheckStatus
StylCnv_Type6_CopyBlockLoop:
	ld	bc, (xsp+4)
	sll	bc, 2
	lda	xde, (18128:16)
	extz	xbc
	add	xbc, xde
	ld	xwa, (xbc)
	or	xwa, xwa
	jrl	z, StylCnv_Type6_NextBlock	; -> 0xF6CFE3
	pushw	4
	push	xbc
	ld	wa, iz
	inc	2, wa
	extz	xwa
	add	xwa, 1047552
	push	xwa
	call	Mem_Copy
	lda	xsp, (xsp+10)
	inc	4, iz
	ldw	(xsp+6), 0
	ld	bc, (xsp+4)
	sll	bc, 5
	lda	xde, (16080:16)
StylCnv_Type6_CopyNameChars:
	ld wa, (xsp + 6)
	inc 1, wa
	add wa, bc
	extz xwa
	add xwa, xde
	ld a, (xwa)
	cp a, 0:i3
	jr z, StylCnv_Type6_TerminateName
	ld hl, iz
	inc 2, hl
	extz xhl
	add xhl, 0xffc00
	ld (xhl), a
	inc 1, iz
	incw 1, (xsp + 6)
	cpw (xsp + 6), 0x20
	jr lt, StylCnv_Type6_CopyNameChars

StylCnv_Type6_TerminateName:
	ld wa, iz
	inc 2, wa
	extz xwa
	add xwa, 0xffc00
	ld (xwa), 0x0
	inc 1, iz
	ld wa, (xsp + 6)
	exts xwa
	divs wa, 0x2
	ldto_werp WA, 0xe2
	cp wa, 0:i3
	jr nz, StylCnv_Type6_NextBlock
	ld wa, iz
	inc 2, wa
	extz xwa
	add xwa, 0xffc00
	ld (xwa), 0x0
	inc 1, iz

StylCnv_Type6_NextBlock:
	incw 1, (xsp + 4)

	ld wa, (xsp + 4)

	; cpda16 xwa, 0x48d8 (v7 patched)
	cp	wa, (0x4820:16)
	; jrl c, StylCnv_Type6_CopyBlockLoop (v7 displacement)
	jrl	c, StylCnv_Type6_CopyBlockLoop
	; jrl StylCnv_FinalizeAndCheckStatus (v7 displacement)
	jrl	StylCnv_FinalizeAndCheckStatus
StylCnv_Type6_FileReadError:
	ld BC,(XSP+0x04)
	sll BC, 0x05
	lda	xwa, (0x3ed0:16)
	extz XBC
	add XBC,XWA
	ld (XBC),0x00
	cpw	(0x4820:16), 0x0002
	jrl nc, StylCnv_Type6_AdvanceEntry
	jrl t, StylCnv_AbortWithError
StylCnv_Type6_FileOpenError:
	ld BC,(XSP+0x04)
	sll BC, 0x05
	lda	xwa, (0x3ed0:16)
	extz XBC
	add XBC,XWA
	ld (XBC),0x00
	cpw	(0x4820:16), 0x0002
	jrl nc, StylCnv_Type6_AdvanceEntry
	jrl t, StylCnv_AbortWithError
StylCnv_Type6_Case1_CopyName:
	ld	bc, (STYLCNV_LIST_POS:16)
	mul BC,0x0025
	lda	xwa, (0x552d:16)
	extz XBC
	add XBC,XWA
	push XBC
	lda xwa, (xsp + 0x16)
	push XWA
	call Strcpy
	inc 8,XSP
	ld	xwa, (0x3ca4:16)
	ld (XSP+0x0a),XWA
	ldw (XSP+0x08), 0x0000
	lda xwa, (xsp + 0x12)
	ld XBC,StylCnv_ModeRb_Type6b
	call FileIO_OpenWithMode
	cp hl, 0:i3
	jrl lt, StylCnv_AbortWithError
	ld xwa, 0:i3
	ld bc, 2:i3
	call FileIO_SeekAndReadBlock
	cp hl, 0:i3
	jrl lt, StylCnv_Epilogue114
	call FileIO_SeekWriteBlock_Impl
	ld (XSP+0x0e),XHL
	call FileIO_SeekRead_ExtReturn
	ld XWA,(XSP+0x0a)
	ld XBC,(XSP+0x0e)
	call FileIO_ReadBlock
	call FileIO_CloseHandle
	cp XHL,0x00000000
	jrl lt, StylCnv_AbortWithError
	ld XWA,(XSP+0x0a)
	ld	(0x46d0:16), xwa
	ld XWA,(XSP+0x0e)
	add (XSP+0x0a),XWA
	ldw (XSP+0x04), 0x0000
	lda xwa, (xsp + 0x12)
StylCnv_Single_FindDot:
	ld bc, (xsp + 4)
	cp	(xwa+bc), 0x2e
	jr z, StylCnv_Single_CopyExtension
	incw 1, (xsp + 4)
	cpw (xsp + 4), 0x20
	jr lt, StylCnv_Single_FindDot

StylCnv_Single_CopyExtension:
	ld iz, 0:i3
	cpw (xsp + 4), 0x20
	jr ge, StylCnv_Single_RenameTM

StylCnv_Single_CopyExt_Loop:
	ld	de, iz
	lda	xbc, (0x3ed0:16)
	extz	xde
	add	xde, xbc
	ld	bc, (xsp+4)
	ld	c, (xwa+bc)
	ld	(xde), c
	cp	c, 0:i3
	jr	z, StylCnv_Single_RenameTM
	incm	1, (xsp+4)
	inc	1, iz
	cpw	(xsp+4), 32
	jr	lt, StylCnv_Single_CopyExt_Loop
StylCnv_Single_RenameTM:
	ldw (xsp + 4), 0x0

StylCnv_Single_FindDot2:
	ld bc, (xsp + 4)
	exts xbc
	add xbc, xwa
	incw 1, (xsp + 4)
	cp (xbc), 0x2e
	jr z, StylCnv_Single_WriteTMExtension
	cpw (xsp + 4), 0x20
	jr lt, StylCnv_Single_FindDot2
StylCnv_Single_WriteTMExtension:
	ld	bc, (xsp+4)
	ld	(xwa+bc), 0x54	; (unidasm; no llvm-mc spelling)
	ld	bc, (xsp+4)
	inc	1, bc
	ld	(xwa+bc), 0x4d	; (unidasm; no llvm-mc spelling)
	ld	bc, (xsp+4)
	inc	2, bc
	.byte	0xf3, 0x07, 0xe0, 0xe4, 0x00, 0x00	; ld (XWA+BC), 0x00 (unidasm; no llvm-mc spelling)
	ld	xbc, StylCnv_ModeRb_Single
	call	FileIO_OpenWithMode
	cp	hl, 0:i3
	jrl	lt, DRI_ParseFieldsAndOpenFile
	ld	xwa, 0:i3
	ld	bc, 2:i3
	call	FileIO_SeekAndReadBlock
	cp	hl, 0:i3
	jrl	lt, DRI_ParseFieldsAndOpenFile
	ldw	(xsp+8), 1
	call	FileIO_SeekWriteBlock_Impl
	ld	(xsp+14), xhl
	call	FileIO_SeekRead_ExtReturn
	ld	xwa, (xsp+10)
	ld	xbc, (xsp+14)
	call	FileIO_ReadBlock
	call	FileIO_CloseHandle
	cp	xhl, 0
	jrl	lt, StylCnv_AbortWithError
	ld	xwa, (xsp+10)
	ld	(18132:16), xwa
	ld	xwa, (xsp+14)
	add	(xsp+10), xwa
	ldw	(xsp+4), 0
	lda	xbc, (xsp+18)
StylCnv_LSW_FindDot:
	ld wa, (xsp + 4)
	cp	(xbc+wa), 0x2e
	jr z, StylCnv_LSW_CopyExtension
	incw 1, (xsp + 4)
	cpw (xsp + 4), 0x20
	jr lt, StylCnv_LSW_FindDot

StylCnv_LSW_CopyExtension:
	ld iz, 0:i3
	cpw (xsp + 4), 0x20
	jr ge, DRI_ParseFieldsAndOpenFile

StylCnv_LSW_CopyExt_Loop:
	ld	de, iz
	add	de, 32
	lda	xwa, (0x3ed0:16)
	extz	xde
	add	xde, xwa
	ld	wa, (xsp+4)
	ld	a, (xbc+wa)
	ld	(xde), a
	cp	a, 0:i3
	jr	z, DRI_ParseFieldsAndOpenFile
	incm	1, (xsp+4)
	inc	1, iz
	cpw	(xsp+4), 32
	jr	lt, StylCnv_LSW_CopyExt_Loop
DRI_ParseFieldsAndOpenFile:
	ldw (xsp + 4), 0x0
	lda xwa, (xsp + 18)

StylCnv_LSW_FindDot2:
	ld bc, (xsp + 4)
	exts xbc
	add xbc, xwa
	incw 1, (xsp + 4)
	cp (xbc), 0x2e
	jr z, StylCnv_LSW_WriteExtension
	cpw (xsp + 4), 0x20
	jr lt, StylCnv_LSW_FindDot2
StylCnv_LSW_WriteExtension:
	ld	bc, (xsp+4)
	ld	(xwa+bc), 0x4c	; (unidasm; no llvm-mc spelling)
	ld	bc, (xsp+4)
	inc	1, bc
	ld	(xwa+bc), 0x53	; (unidasm; no llvm-mc spelling)
	ld	bc, (xsp+4)
	inc	2, bc
	ld	(xwa+bc), 0x57	; (unidasm; no llvm-mc spelling)
	ld	bc, (xsp+4)
	inc	3, bc
	.byte	0xf3, 0x07, 0xe0, 0xe4, 0x00, 0x00	; ld (XWA+BC), 0x00 (unidasm; no llvm-mc spelling)
	ld	xbc, StylCnv_ModeRb_LSW
	call	FileIO_OpenWithMode
	cp	hl, 0:i3
	jrl	lt, FileLoad_ResetAndStartProcessing
	ld	xwa, 0:i3
	ld	bc, 2:i3
	call	FileIO_SeekAndReadBlock
	cp	hl, 0:i3
	jrl	lt, FileLoad_ResetAndStartProcessing
	incw	1, (xsp+8)
	call	FileIO_SeekWriteBlock_Impl
	ld	(xsp+14), xhl
	call	FileIO_SeekRead_ExtReturn
	ld	xwa, (xsp+10)
	ld	xbc, (xsp+14)
	call	FileIO_ReadBlock
	call	FileIO_CloseHandle
	cp	xhl, 0
	jrl	lt, StylCnv_AbortWithError
	ld	bc, (xsp+8)
	ld	(xsp+16), bc
	sla	bc, 2
	lda	xwa, (18128:16)
	extz	xbc
	add	xbc, xwa
	ld	xwa, (xsp+10)
	ld	(xbc), xwa
	ldw	(xsp+4), 0
	lda	xbc, (xsp+18)
StylCnv_LSW_FindDot3:
	ld wa, (xsp + 4)
	cp	(xbc+wa), 0x2e
	jr z, StylCnv_LSW_CopyExt3
	incw 1, (xsp + 4)
	cpw (xsp + 4), 0x20
	jr lt, StylCnv_LSW_FindDot3

StylCnv_LSW_CopyExt3:
	ld iz, 0:i3
	cpw (xsp + 4), 0x20
	jr ge, FileLoad_ResetAndStartProcessing

StylCnv_LSW_CopyExt3_Loop:
	ld	wa, (xsp+16)
	sll	wa, 5
	ld	de, iz
	add	de, wa
	lda	xwa, (0x3ed0:16)
	extz	xde
	add	xde, xwa
	ld	wa, (xsp+4)
	ld	a, (xbc+wa)
	ld	(xde), a
	cp	a, 0:i3
	jr	z, FileLoad_ResetAndStartProcessing
	incm	1, (xsp+4)
	inc	1, iz
	cpw	(xsp+4), 32
	jr	lt, StylCnv_LSW_CopyExt3_Loop
FileLoad_ResetAndStartProcessing:
	calr SoundMem_ClearRegion
	ld (0x0ffc00:24), 0xff
	ld (0x0ffc01:24), 0x00
	ldw (xsp + 4), 0x0
	ld iz, 0:i3
	ld wa, (xsp + 8)
	add wa, 0x1
	jrl le, StylCnv_FinalizeAndCheckStatus

StylCnv_Final_CopyBlockLoop:
	pushw 0x0004
	ld BC,(XSP+0x06)
	sll BC, 0x02
	lda	xwa, (0x46d0:16)
	extz XBC
	add XBC,XWA
	push XBC
	ld WA,IZ
	inc 2,WA
	extz XWA
	add XWA,0x000ffc00
	push XWA
	call Mem_Copy
	lda xsp, (xsp + 0x0a)
	inc 4,IZ
	ldw (XSP+0x06), 0x0000
	ld BC,(XSP+0x04)
	sll BC, 0x05
	lda	xde, (0x3ed0:16)
StylCnv_Final_CopyNameChars:
	ld wa, (xsp + 6)
	inc 1, wa
	add wa, bc
	extz xwa
	add xwa, xde
	ld a, (xwa)
	cp a, 0:i3
	jr z, StylCnv_Final_TerminateName
	ld hl, iz
	inc 2, hl
	extz xhl
	add xhl, 0xffc00
	ld (xhl), a
	inc 1, iz
	incw 1, (xsp + 6)
	cpw (xsp + 6), 0x20
	jr lt, StylCnv_Final_CopyNameChars

StylCnv_Final_TerminateName:
	ld wa, iz
	inc 2, wa
	extz xwa
	add xwa, 0xffc00
	ld (xwa), 0x0
	inc 1, iz
	ld wa, (xsp + 6)
	exts xwa
	divs wa, 0x2
	ldto_werp WA, 0xe2
	cp wa, 0:i3
	jr nz, StylCnv_Final_NextBlock
	ld wa, iz
	inc 2, wa
	extz xwa
	add xwa, 0xffc00
	ld (xwa), 0x0
	inc 1, iz

StylCnv_Final_NextBlock:
	incw 1, (xsp + 4)
	ld wa, (xsp + 8)
	inc 1, wa
	cp (xsp + 4), wa
	jrl lt, StylCnv_Final_CopyBlockLoop

StylCnv_FinalizeAndCheckStatus:
	calr TableData_JumpToEntry
	jrl StyleConv_DispatchSoundMemState

StylCnv_Multi_InitAndClear:
	calr	StyleConv_InitEntryTable
	ldw	(14794:16), 0
	lda	xbc, (xsp+18)
	ld	xwa, xbc
	lda	xbc, (xbc+100)
StylCnv_Multi_ClearLoop:
	ld (xwa+), 0x00
	cp xwa, xbc
	jr c, StylCnv_Multi_ClearLoop
	ldw (xsp + 4), 0x0
	ld iz, 0:i3

StylCnv_Multi_ParseLoop:
	lda	xbc, (0x3cb0:16)
	ld WA,(XSP+0x04)
	lda	xhl, (xbc+wa)
	ld E,(XHL)
	lda xbc, (xsp + 0x12)
	lda	xwa, (0x552c:16)
	ld (XSP+0x0e),XWA
	cp e, 0:i3
	jr nz, .Lc_f6d3d7
	cp iz, 0:i3
	jr le, StylCnv_Multi_Finalize
	push XBC
	ld WA,IZ
	dec 1,WA
	mul WA,0x0025
	extz XWA
	add XWA,(XSP+0x12)
	inc 1,XWA
	push XWA
	call Strcpy
	inc 8,XSP
	incw	1, (0x39ca:16)
	jr t, StylCnv_Multi_Finalize
StylCnv_Multi_HandleSeparator:
.Lc_f6d3d7:
	cp E,0x7c
	jr nz, StylCnv_Multi_CopyChar
	ld (XHL),0x00
	ldw (XSP+0x06), 0x0000
	inc 1,IZ
	cp iz, 1:i3
	jr le, LoopCounter_Increment
	push XBC
	ld WA,IZ
	dec 2,WA
	mul WA,0x0025
	extz XWA
	add XWA,(XSP+0x12)
	inc 1,XWA
	push XWA
	call Strcpy
	inc 8,XSP
	lda xbc, (xsp + 0x12)
	ld XWA,XBC
	lda xbc, (xbc + 0x64)
StylCnv_Multi_ClearSubLoop:
	ld	(xwa+), 0
	cp	xwa, xbc
	jr	c, StylCnv_Multi_ClearSubLoop
	incw	1, (14794:16)
	jr	LoopCounter_Increment
StylCnv_Multi_CopyChar:
	cp iz, 0:i3
	jr le, LoopCounter_Increment
	ld wa, (xsp + 6)
	ld	(xbc+wa), e
	ld (xhl), 0x0
	incw 1, (xsp + 6)

LoopCounter_Increment:
	incw 1, (xsp + 4)
	ld wa, (xsp + 4)
	cp wa, 0x200
	jrl c, StylCnv_Multi_ParseLoop

StylCnv_Multi_Finalize:
	ldw wa, TT_STYLCNVSEL

StylCnv_PostModeChange:
	call UI_ChangeTitleByIndex

StylCnv_Epilogue114:
	pop xiz
	lda xsp, (xsp + 114)
	ret

TableData_JumpToEntry:
	ld xhl, 0x80000
	jp (xhl)
AccStyle_TableDataEntry:
	call	Boot_CheckConfigFlag7
	cp	hl, 0:i3
	ret	z
	cp	(SWBTWR_PAYLOAD_1:16), 65
	ret	nz
	bit	0, (SWBTWR_PAYLOAD_3:16)
	ret	z
	ld	c, (CURRENT_TITLE:16)
	bit	0, (SWBTWR_PAYLOAD_2:16)
	jr	z, AccStyle_TableDataEntry_Skip
	cp	c, 17
	ret	nz
	ldw	wa, TT_STYLCNVWAIT
	jr	AccStyle_TableDataEntry_Join
AccStyle_TableDataEntry_Skip:
	ld	a, (0x3c4e:16)
	cp	c, 18
	jr	z, AccStyle_TableDataEntry_Skip5
	cp	c, 20
	jr	z, AccStyle_TableDataEntry_Skip2
	cp	c, 16
	ret	nz
	call	FileIO_CheckMediaIsWritable
	cp	hl, 0:i3
	ret	nz
	ldw	wa, TT_STYLCNVMODL
	jr	AccStyle_TableDataEntry_Join
AccStyle_TableDataEntry_Skip2:
	cp	a, 2:i3
	jr	z, AccStyle_TableDataEntry_Skip4
	cp	a, 5:i3
	jr	z, AccStyle_TableDataEntry_Skip3
	cp	a, 1:i3
	ret	nz
AccStyle_TableDataEntry_Skip3:
	call	FileIO_CheckMediaIsWritable
	cp	hl, 0:i3
	ret	nz
	ldw	wa, TT_STYLCNVCNVT
	jr	AccStyle_TableDataEntry_Join
AccStyle_TableDataEntry_Skip4:
	call	FileIO_CheckMediaIsWritable
	cp	hl, 0:i3
	ret	nz
	ldw	wa, TT_STYLCNVCNVT
	jr	AccStyle_TableDataEntry_Join
AccStyle_TableDataEntry_Skip5:
	cp	a, 2:i3
	jr	z, AccStyle_TableDataEntry_Skip6
	cp	a, 1:i3
	ret	nz
AccStyle_TableDataEntry_Skip6:
	call	FileIO_CheckMediaIsWritable
	cp	hl, 0:i3
	ret	nz
	ld	xwa, 15440
	call	ControlState_ProcessCommand
	ldw	wa, TT_STYLCNVCNVT
AccStyle_TableDataEntry_Join:
	call	UI_ChangeTitleByIndex
	ret
; SingleLoad_CopyComposerPatternFromFile: Composer single-load body: reads the open .CMP file's style image into the
;   work buffer 0x69800, accepts the headers 'H',0,'K' / 'G',0,'K' / 'L','K','E' (rewriting an older one to 'H',0,'K'
;   and resetting byte 2 of the copied sections' part entries), then copies source A into destination C with
;   DualVoice_ParamLoadDone -- one composer pattern, or the ten of a memory bank when both are 30 + bank
;   (AccPatch_ClearModeFlag_Wrap); HL = 0xFF95 when a copy fails (0x38B4 = 131), else 0 (0x38B4 = 130 for an
;   unknown header or a pattern / bank mix). Basis: callers + body -- SingleLoad_LoadComposerPattern hands it source
;   WA and destination BC after FileIO_ReadAndValidateHeader; its header describes this copy.
SingleLoad_CopyComposerPatternFromFile:
	lda	xsp, (xsp-34)
	push	xiz
	ld	(xsp+34), c
	ld	(xsp+36), a
	ld	xiy, AccStyle_SlotOrderB
	lda	xix, (xsp+4)
	ldw	bc, 15
	ldirw
	lda	xde, (RHYTHM_PATTERN_BUF_A:24)
	lda	xbc, (SEQ_SONG_SLOTS:24)
	sub	xbc, xde
	ld	xwa, 432128
	call	FileIO_ReadBlock
	cp	xhl, 0
	jrl	lt, AccStyle_TableDataEntry_Epilogue
	lda	xbc, (0x69800:24)
	ld	(0x7a2c:16), xbc
	lda	xwa, (RHYTHM_PATTERN_BUF_A:24)
	ld	(0x7a30:16), xwa
	ld	(0x3898:16), 0
	ld	a, (xbc)
	ldfr_berp	a, 249
	ld	a, (xbc+1)
	ldfr_berp	a, 250
	ld	a, (xbc+2)
	ldfr_berp	a, 251
	cp_erpb	249, 72
	jr	nz, AccStyle_TableDataEntry_Skip7
	cpib_erp	250, 0
	jr	nz, AccStyle_TableDataEntry_Skip7
	cp_erpb	251, 75
	jr	z, AccStyle_TableDataEntry_Skip9
AccStyle_TableDataEntry_Skip7:
	cp_erpb	249, 71
	jr	nz, AccStyle_TableDataEntry_Skip8
	cpib_erp	250, 0
	jr	nz, AccStyle_TableDataEntry_Skip8
	cp_erpb	251, 75
	jr	z, AccStyle_TableDataEntry_Skip9
AccStyle_TableDataEntry_Skip8:
	cp_erpb	249, 76
	jrl	nz, AccStyle_TableDataEntry_Skip16
	cp_erpb	250, 75
	jrl	nz, AccStyle_TableDataEntry_Skip16
	cp_erpb	251, 69
	jrl	nz, AccStyle_TableDataEntry_Skip16
AccStyle_TableDataEntry_Skip9:
	ld	xwa, (0x7a2c:16)
	ld	(xwa), 72
	ld	xwa, (0x7a2c:16)
	ld	(xwa+1), 0
	ld	xwa, (0x7a2c:16)
	ld	(xwa+2), 75
	ld	xbc, (0x7a30:16)
	cp	(xsp+36), 29
	jrl	ule, AccStyle_TableDataEntry_Skip14
	cp	(xsp+34), 29
	jrl	ule, AccStyle_TableDataEntry_Skip14
	ld	xwa, (0x7a2c:16)
	ld	e, (xwa+14)
	cp	e, 0:i3
	jr	nz, AccStyle_TableDataEntry_Skip10
	cp	(xwa+15), 0
	jr	z, AccStyle_TableDataEntry_Skip11
AccStyle_TableDataEntry_Skip10:
	ld	(xbc+14), e
	ld	xwa, (0x7a2c:16)
	ld	a, (xwa+15)
	ld	(xbc+15), a
AccStyle_TableDataEntry_Skip11:
	cp_erpb	249, 72
	jr	nz, AccStyle_TableDataEntry_Skip12
	cpib_erp	250, 0
	jr	nz, AccStyle_TableDataEntry_Skip12
	cp_erpb	251, 75
	jrl	z, AccStyle_TableDataEntry_Skip13
AccStyle_TableDataEntry_Skip12:
	ld	a, (xsp+36)
	sub	a, 30
	extz	wa
	extz	xwa
	add	xwa, AccStyle_SlotOrderA
	ld	xbc, xwa
	ld	xde, xwa
	ld	xhl, xwa
	ld	xix, xwa
	lda	xiy, (xwa+30)
AccStyle_TableDataEntry_Loop:
	ld	a, (xix)
	extz	wa
	muls	wa, 96
	ld	iz, wa
	add	iz, 96
	ld	xwa, (0x7a2c:16)
	lda	xwa, (xwa+iz)
	ld	(xwa+34), 64
	ld	a, (xhl)
	extz	wa
	muls	wa, 96
	ld	iz, wa
	add	iz, 96
	ld	xwa, (0x7a2c:16)
	lda	xwa, (xwa+iz)
	ld	(xwa+42), 12
	ld	a, (xde)
	extz	wa
	muls	wa, 96
	ld	iz, wa
	add	iz, 96
	ld	xwa, (0x7a2c:16)
	lda	xwa, (xwa+iz)
	ld	(xwa+50), 116
	ld	a, (xbc)
	extz	wa
	muls	wa, 96
	ld	iz, wa
	add	iz, 96
	ld	xwa, (0x7a2c:16)
	lda	xwa, (xwa+iz)
	ld	(xwa+58), 64
	inc	3, xix
	inc	3, xhl
	inc	3, xde
	inc	3, xbc
	cp	xbc, xiy
	jr	c, AccStyle_TableDataEntry_Loop
AccStyle_TableDataEntry_Skip13:
	ld	a, (xsp+36)
	extz	wa
	ld	c, (xsp+34)
	extz	bc
	calr	SingleLoad_CopyComposerBankFromFile
AccStyle_TableDataEntry_Join2:
	ld	a, (0x3898:16)
	extz	wa
	bit	0, wa
	jrl	z, AccStyle_TableDataEntry_Join3
	ld	xwa, (0x7a30:16)
	ld	(STYLE_SRC_IMAGE_PTR:16), xwa
	cp	(xsp+34), 30
	jrl	nc, AccStyle_TableDataEntry_Skip21
	ld	c, (xsp+34)
	extz	bc
	lda	xwa, (xsp+4)
	ld	(STYLE_COPY_SRC_SECTION), (xwa+bc)
	call	AccPatch_InitFromSlotIndex
	jrl	AccStyle_TableDataEntry_Join3
AccStyle_TableDataEntry_Skip14:
	cp	(xsp+36), 29
	jr	ule, AccStyle_TableDataEntry_Skip15
	cp	(xsp+34), 30
	jr	c, AccStyle_TableDataEntry_Skip16
AccStyle_TableDataEntry_Skip15:
	cp	(xsp+36), 30
	jr	nc, AccStyle_TableDataEntry_Skip24
	cp	(xsp+34), 29
	jr	ule, AccStyle_TableDataEntry_Skip24
AccStyle_TableDataEntry_Skip16:
	ld	(0x3898:16), 130
	jrl	AccStyle_TableDataEntry_Skip17
AccStyle_TableDataEntry_Skip24:
	ld	(STYLE_SRC_IMAGE_PTR:16), xbc
	ld	c, (xsp+34)
	extz	bc
	lda	xwa, (xsp+4)
	ld	(STYLE_COPY_SRC_SECTION), (xwa+bc)
	call	AccPatch_InitFromSlotIndex
	cp_erpb	249, 72
	jr	nz, AccStyle_TableDataEntry_Skip18
	cpib_erp	250, 0
	jr	nz, AccStyle_TableDataEntry_Skip18
	cp_erpb	251, 75
	jr	z, AccStyle_TableDataEntry_Skip19
AccStyle_TableDataEntry_Skip18:
	ld	a, (xsp+36)
	extz	wa
	lda	xbc, (xsp+4)
	lda	xbc, (xbc+wa)
	ld	a, (xbc)
	extz	wa
	muls	wa, 96
	ld	de, wa
	add	de, 96
	ld	xwa, (0x7a2c:16)
	lda	xwa, (xwa+de)
	ld	(xwa+34), 64
	ld	a, (xbc)
	extz	wa
	muls	wa, 96
	ld	de, wa
	add	de, 96
	ld	xwa, (0x7a2c:16)
	lda	xwa, (xwa+de)
	ld	(xwa+42), 12
	ld	a, (xbc)
	extz	wa
	muls	wa, 96
	ld	de, wa
	add	de, 96
	ld	xwa, (0x7a2c:16)
	lda	xwa, (xwa+de)
	ld	(xwa+50), 116
	ld	a, (xbc)
	extz	wa
	muls	wa, 96
	ld	bc, wa
	add	bc, 96
	ld	xwa, (0x7a2c:16)
	lda	xwa, (xwa+bc)
	ld	(xwa+58), 64
AccStyle_TableDataEntry_Skip19:
	ld	xwa, (0x7a2c:16)
	ld	(STYLE_SRC_IMAGE_PTR:16), xwa
	ld	xwa, (0x7a30:16)
	ld	(STYLE_DST_IMAGE_PTR:16), xwa
	ld	a, (xsp+36)
	extz	wa
	lda	xbc, (xsp+4)
	ld	(STYLE_COPY_SRC_SECTION), (xbc+wa)
	ld	a, (xsp+34)
	extz	wa
	ld	(STYLE_COPY_DST_SECTION), (xbc+wa)
	res	0, (0x34f8:16)
	call	DualVoice_ParamLoadDone
	ld	a, (0x34f8:16)
	extz	wa
	bit	0, wa
	jr	z, AccStyle_TableDataEntry_Skip20
	ld	(0x3898:16), 131
	jrl	AccStyle_TableDataEntry_Join2
AccStyle_TableDataEntry_Skip20:
	ld	(0x3898:16), 0
	jrl	AccStyle_TableDataEntry_Join2
AccStyle_TableDataEntry_Skip21:
	ldib_erp	251, 0
AccStyle_TableDataEntry_Loop5:
	ld	c, (xsp+34)
	sub	c, 30
	extz	bc
	ldto_berp	a, 251
	extz	wa
	muls	wa, 3
	ld	de, wa
	add	de, bc
	lda	xwa, (AccStyle_SlotOrderA:24)
	ld	(STYLE_COPY_SRC_SECTION), (xwa+de)
	call	AccPatch_InitFromSlotIndex
	inc1b_erp	251
	cp_erpb	251, 10
	jr	c, AccStyle_TableDataEntry_Loop5
AccStyle_TableDataEntry_Join3:
	cp	(0x3898:16), 131
	jr	nz, AccStyle_TableDataEntry_Skip22
	ldw	hl, 65429
	jr	AccStyle_TableDataEntry_Epilogue
AccStyle_TableDataEntry_Skip22:
	call	AccPatch_ClearModeFlag_Wrap
AccStyle_TableDataEntry_Skip17:
	ld	hl, 0:i3
AccStyle_TableDataEntry_Epilogue:
	pop	xiz
	lda	xsp, (xsp+34)
	ret
; SingleLoad_CopyComposerBankFromFile: Copies the ten composer patterns of memory bank A - 30 of the loaded .CMP image
;   (read to 0x69800, pointer 0x7AE4) into bank C - 30 of the live style image (pointer 0x7AE8): re-initialises each
;   destination slot first (AccPatch_InitFromSlotIndex), then copies pattern by pattern with DualVoice_ParamLoadDone
;   (slots AccStyle_SlotOrderA[3 * i + bank]), stopping with 0x3950 = 131 when a copy fails (0x35B0 bit 0), else
;   0x3950 = 0. Basis: callers + body -- SingleLoad_CopyComposerPatternFromFile calls it when source and destination
;   are both above 29 and its header calls it the copy of 'the ten of a memory bank when both are 30 + bank'.
SingleLoad_CopyComposerBankFromFile:
	dec	4, xsp
	push	qiz
	ld	(xsp+2), c
	ld	(xsp+4), a
	ld	xwa, (0x7a30:16)
	ld	(STYLE_SRC_IMAGE_PTR:16), xwa
	ldib_erp	251, 0
AccStyle_TableDataEntry_Loop3:
	ld	c, (xsp+2)
	sub	c, 30
	extz	bc
	ldto_berp	a, 251
	extz	wa
	muls	wa, 3
	ld	de, wa
	add	de, bc
	lda	xwa, (AccStyle_SlotOrderA:24)
	ld	(STYLE_COPY_SRC_SECTION), (xwa+de)
	call	AccPatch_InitFromSlotIndex
	inc1b_erp	251
	cp_erpb	251, 10
	jr	c, AccStyle_TableDataEntry_Loop3
	ld	xwa, (0x7a2c:16)
	ld	(STYLE_SRC_IMAGE_PTR:16), xwa
	ld	xwa, (0x7a30:16)
	ld	(STYLE_DST_IMAGE_PTR:16), xwa
	ld	(0x3898:16), 0
	res	0, (0x34f8:16)
	ldib_erp	251, 0
AccStyle_TableDataEntry_Loop2:
	ld	e, (xsp+4)
	sub	e, 30
	extz	de
	ldto_berp	a, 251
	extz	wa
	muls	wa, 3
	ld	bc, wa
	add	wa, de
	lda	xde, (AccStyle_SlotOrderA:24)
	ld	(STYLE_COPY_SRC_SECTION), (xde+wa)
	ld	a, (xsp+2)
	sub	a, 30
	extz	wa
	add	bc, wa
	ld	(STYLE_COPY_DST_SECTION), (xde+bc)
	call	DualVoice_ParamLoadDone
	ld	a, (0x34f8:16)
	extz	wa
	bit	0, wa
	jr	z, AccStyle_TableDataEntry_Skip23
	ld	(0x3898:16), 131
	jr	AccStyle_TableDataEntry_Epilogue2
AccStyle_TableDataEntry_Skip23:
	inc1b_erp	251
	cp_erpb	251, 10
	jr	c, AccStyle_TableDataEntry_Loop2
AccStyle_TableDataEntry_Epilogue2:
	pop	qiz
	inc	4, xsp
	ret
	.include "sequencer/accompseq_routines.s"
