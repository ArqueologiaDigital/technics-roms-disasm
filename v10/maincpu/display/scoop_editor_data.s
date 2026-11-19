; =============================================================================
; Sound-editor title-function handlers (code; historical file name)
; =============================================================================
;
; CODE, not data: 3,422 TLCS-900 instructions and not one .byte/.ascii/.long
; directive, re-assembled byte-identical to the dump.  Entered at
; SeWrtSndTitleFunc_OnDraw -- named by one `.long` of the pointer table
; SeTonTon1TitleFunc_Methods in kn5000_v*_program.s,
; where 187 more `.long`s point into this file as bare numbers -- and at the
; 15 interior offsets that the title-function stubs of
; audio/sound_editor_routines.s reach by `jp Scoop_SoundEditorData_0x..`
; (e.g. SeAmpAmp1TitleFunc_OnDraw).  The body is almost all calls to
; SeMenu_* (SeMenu_SendEvent, SeMenu_LoadPartParam, SeMenu_LoadObjEntries...).
; Framing: control-flow trace, `scripts/converters/scoop_reframe.py plan`
; (commands in notes/scoop-lane-2026-09-25/README.md).  In v10 it reaches
; 9,162 of the 9,199 bytes from 16 named entries plus 185 it takes from
; pointer/`ld` references and anchored runs; the other 37 B are three short
; tails that decode cleanly and show no data evidence, so they stay code.
;
; CORRECTED 2026-09-25: this header used to say "Sound editor display data,
; performance mode parameter bytecode, Scoop oscilloscope editor configuration
; tables, and display dirty-region data."  No reader treats these bytes as
; data and every byte assembles back to the ROM as an instruction, so the
; claim is withdrawn (the 177 .byte/.long lines of the v10/v9 source and the 9
; romslices of v7 that it may have rested on are re-spelled as instructions).
; The label name SeWrtSndTitleFunc_OnDraw is kept: it is referenced from files
; outside this lane.
; =============================================================================



SeWrtSndTitleFunc_OnDraw:
	jp	SeMenu_CopyWriteUpdate_Step3_Join
SeWrtSndTitleFunc_OnHide:
	jp	SeMenu_CopyWriteUpdate_Step3_Return30
SeWrtSndTitleFunc_OnSwitchIn:
	ld	wa, (xsp+4)
	ld	bc, (xsp+6)
	call	SeWrtSndTitleFunc_DispatchSwitch
SeWrtSndTitleFunc_OnSwitchIn_Join:
	ld	wa, 1:i3
	call	TaskSem_GetCount
	cp	hl, 0:i3
	jr	z, SeWrtSndTitleFunc_OnSwitchIn_Skip
	ld	wa, 3:i3
	call	Kernel_YieldRotate
	jr	SeWrtSndTitleFunc_OnSwitchIn_Join
SeWrtSndTitleFunc_OnSwitchIn_Skip:
	ld	xwa, 0:i3
	ld	xbc, EVT_SW_IN
	jp	DeleteEvent
SeWrtSndTitleFunc_Nop:
	jp	SeMenu_CopyWriteUpdate_Step3_Return31
SeAmpAmp1TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeAmpAmp1TitleFunc_DispatchSwitch_Epilogue
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeAmpAmp1TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeAmpAmp1TitleFunc_DispatchSwitch_Epilogue:
	inc	4, xsp
	ret
SeAmpAmp2TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeAmpAmp2TitleFunc_DispatchSwitch_Epilogue2
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeAmpAmp2TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeAmpAmp2TitleFunc_DispatchSwitch_Epilogue2:
	inc	4, xsp
	ret
SeAmpEnv1TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeAmpEnv1TitleFunc_DispatchSwitch_Epilogue3
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeAmpEnv1TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeAmpEnv1TitleFunc_DispatchSwitch_Epilogue3:
	inc	4, xsp
	ret
SeAmpEnv2TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeAmpEnv2TitleFunc_DispatchSwitch_Epilogue4
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeAmpEnv2TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeAmpEnv2TitleFunc_DispatchSwitch_Epilogue4:
	inc	4, xsp
	ret
SeAmpLfo1TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeAmpLfo1TitleFunc_DispatchSwitch_Epilogue5
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeAmpLfo1TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeAmpLfo1TitleFunc_DispatchSwitch_Epilogue5:
	inc	4, xsp
	ret
SeAmpAmp1_OnColumn3:
	lda	xsp, (xsp-20)
	ld	(xsp+18), a
	lda	xwa, (xsp+14)
	call	SeMenu_LoadObjEntries
	lda	xwa, (xsp+16)
	call	SeMenu_ValidatePartNumber
	ld	a, (xsp+16)
	ld	(xsp), a
	extz	wa
	lda	xbc, (xsp+2)
	call	SeMenu_LoadPartParam
	ld	a, (xsp+18)
	extz	wa
	lda	xbc, (xsp+12)
	call	SeMenu_SwitchToValueStep
	lda	xhl, (xsp+2)
	lda	xwa, (xhl+6)
	lda	xbc, (xhl+7)
	lda	xde, (xhl+8)
	lda	xhl, (xhl+9)
	cp	(xsp+14), 0
	jr	nz, SeAmpAmp1_OnColumn3_Skip2
	ld	(xwa), 127
	ld	(xbc), 0
	ld	(xde), 127
	ld	(xhl), 0
	ld	a, 23:opc
	jr	SeAmpAmp1_OnColumn3_Join2
SeAmpAmp1_OnColumn3_Skip2:
	ld	(xwa), 255
	ld	(xbc), 0
	ld	(xde), 50
	ld	(xhl), 206
	ld	a, (xsp+16)
	dec	1, a
	extz	wa
	muls	wa, 21
	extz	xwa
	lda	xwa, (xwa+16)
	inc	6, xwa
	ld	(xsp+16), 0
SeAmpAmp1_OnColumn3_Join2:
	ld	c, (xsp)
	extz	bc
	ld	e, (xsp+16)
	extz	de
	extz	wa
	pushw	wa
	lda	xwa, (xsp+4)
	push	xwa
	ldw	wa, 43
	call	SeMenu_StepParamFieldAndSend
	cp	(xsp+14), 0
	jr	nz, SeAmpAmp1_OnColumn3_Skip3
	cp	l, 1:i3
	jr	nz, SeAmpAmp1_OnColumn3_Skip3
	ld	a, (xsp+16)
	extz	wa
	ld	c, (xsp+5)
	extz	bc
	call	SeMenu_StoreParamByte
SeAmpAmp1_OnColumn3_Skip3:
	ld	wa, 3:i3
	call	SeMenu_BindDialToColumn
	lda	xsp, (xsp+20)
	ret
SeAmpAmp1_OnColumn4:
	lda	xsp, (xsp-18)
	push	qiz
	ld	(xsp+18), a
	lda	xwa, (xsp+14)
	call	SeMenu_LoadObjEntries
	lda	xwa, (xsp+16)
	call	SeMenu_ValidatePartNumber
	cp	(xsp+14), 0
	jr	nz, SeAmpAmp1_OnColumn4_Skip53
	ld	a, (xsp+16)
	inc	4, a
	ldfr_berp a, 251
	jr	SeAmpAmp1_OnColumn4_Join3
SeAmpAmp1_OnColumn4_Skip53:
	ld	a, (xsp+16)
	inc	2, a
	ldfr_berp a, 251
SeAmpAmp1_OnColumn4_Join3:
	ldto_berp a, 251
	extz	wa
	lda	xbc, (xsp+2)
	call	SeMenu_LoadPartParam
	ld	a, (xsp+18)
	extz	wa
	lda	xbc, (xsp+12)
	call	SeMenu_SwitchToValueStep
	lda	xhl, (xsp+2)
	lda	xwa, (xhl+6)
	lda	xbc, (xhl+7)
	lda	xde, (xhl+8)
	lda	xhl, (xhl+9)
	cp	(xsp+14), 0
	jr	nz, SeAmpAmp1_OnColumn4_Skip4
	ld	(xwa), 255
	ld	(xbc), 0
	ld	(xde), 50
	ld	(xhl), 206
	ld	a, 24:opc
	jr	SeAmpAmp1_OnColumn4_Join4
SeAmpAmp1_OnColumn4_Skip4:
	ld	(xwa), 7
	ld	(xbc), 5
	ld	(xde), 6
	ld	(xhl), 0
	ld	a, (xsp+16)
	dec	1, a
	extz	wa
	muls	wa, 21
	extz	xwa
	lda	xwa, (xwa+16)
	inc	7, xwa
	ld	(xsp+16), 0
SeAmpAmp1_OnColumn4_Join4:
	ldto_berp c, 251
	extz	bc
	ld	e, (xsp+16)
	extz	de
	extz	wa
	pushw	wa
	lda	xwa, (xsp+4)
	push	xwa
	ldw	wa, 43
	call	SeMenu_StepParamFieldAndSend
	ld	wa, 4:i3
	call	SeMenu_BindDialToColumn
	pop qiz
	lda	xsp, (xsp+18)
	ret
SeAmpAmp1_OnColumn5:	.include "includes/generated/cc900/SeAmpAmp1_OnColumn5.s"	; C: cc900/scoop_editor_data_m0_c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpAmp1_OnColumn5_Epilogue36, SeAmpAmp1_OnColumn5 + 107
SeAmpAmp1_OnSideRow1:	.include "includes/generated/cc900/SeAmpAmp1_OnSideRow1.s"	; C: cc900/scoop_editor_data_m0_c.c
SeAmpAmp1_OnSideRow2:	.include "includes/generated/cc900/SeAmpAmp1_OnSideRow2.s"	; C: cc900/scoop_editor_data_m0_c.c
SeAmpAmp1_OnSideRow3:	.include "includes/generated/cc900/SeAmpAmp1_OnSideRow3.s"	; C: cc900/scoop_editor_data_m0_c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpAmp1_OnSideRow3_Skip54, SeAmpAmp1_OnSideRow3 + 33
	.set	SeAmpAmp1_OnSideRow3_Epilogue37, SeAmpAmp1_OnSideRow3 + 44
SeAmpAmp1_OnSideRow4:	.include "includes/generated/cc900/SeAmpAmp1_OnSideRow4.s"	; C: cc900/scoop_editor_data_m0_c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpAmp1_OnSideRow4_Epilogue38, SeAmpAmp1_OnSideRow4 + 33
SeAmpAmp1_OnSideRow5:	.include "includes/generated/cc900/SeAmpAmp1_OnSideRow5.s"	; C: cc900/scoop_editor_data_m0_c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpAmp1_OnSideRow5_Epilogue39, SeAmpAmp1_OnSideRow5 + 33
SeAmpAmp1_OnSwitch25:	.include "includes/generated/cc900/SeAmpAmp1_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpAmp1_OnSwitch25_Epilogue40, SeAmpAmp1_OnSwitch25 + 31
SeAmpAmp1_OnSwitch15:	.include "includes/generated/cc900/SeAmpAmp1_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpAmp1_OnSwitch15_Skip5, SeAmpAmp1_OnSwitch15 + 35
	.set	SeAmpAmp1_OnSwitch15_Join5, SeAmpAmp1_OnSwitch15 + 40
	.set	SeAmpAmp1_OnSwitch15_Epilogue6, SeAmpAmp1_OnSwitch15 + 44
SeAmpAmp2_OnColumn3:	.include "includes/generated/cc900/SeAmpAmp2_OnColumn3.s"	; C: cc900/scoop_editor_data_m0_c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpAmp2_OnColumn3_Skip6, SeAmpAmp2_OnColumn3 + 105
SeAmpAmp2_OnColumn4:
	dec	8, xsp
	ld	(xsp+6), a
	lda	xbc, (xsp+2)
	ld	wa, 0:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+6)
	extz	wa
	ld	c, (xsp+2)
	dec	1, c
	extz	bc
	pushw	bc
	ld	bc, 1:i3
	ld	de, 0:i3
	call	SeMenu_StepNoteParamInRange
	cp	l, 1:i3
	jr	nz, SeAmpAmp2_OnColumn4_Skip7
	lda	xwa, (xsp+4)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 1:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+4)
	extz	wa
	lda	xde, (xsp)
	pushw	127
	ldw	bc, 27
	call	SeMenu_RegisterElement_Extended
	pushw	1
	pushw	44
	call	SeTitle_DrawField
	inc	4, xsp
	ld	wa, 0:i3
	ld	bc, 0:i3
	call	SeMenu_DrawKeyScaleGraph
SeAmpAmp2_OnColumn4_Skip7:
	ld	wa, 4:i3
	call	SeMenu_BindDialToColumn
	inc	8, xsp
	ret
SeAmpAmp2_OnColumn5:
	lda	xsp, (xsp-10)
	ld	(xsp+8), a
	lda	xbc, (xsp+4)
	ld	wa, 1:i3
	call	SeMenu_LoadPartParam
	lda	xbc, (xsp+2)
	ld	wa, 2:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+8)
	extz	wa
	ld	e, (xsp+4)
	inc	1, e
	extz	de
	ld	c, (xsp+2)
	dec	1, c
	extz	bc
	pushw	bc
	ld	bc, 0:i3
	call	SeMenu_StepNoteParamInRange
	cp	l, 1:i3
	jr	nz, SeAmpAmp2_OnColumn5_Skip8
	lda	xwa, (xsp+6)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 0:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+6)
	extz	wa
	lda	xde, (xsp)
	pushw	127
	ldw	bc, 26
	call	SeMenu_RegisterElement_Extended
	pushw	0
	pushw	44
	call	SeTitle_DrawField
	inc	4, xsp
	ld	wa, 0:i3
	ld	bc, 0:i3
	call	SeMenu_DrawKeyScaleGraph
SeAmpAmp2_OnColumn5_Skip8:
	ld	wa, 5:i3
	call	SeMenu_BindDialToColumn
	lda	xsp, (xsp+10)
	ret
SeAmpAmp2_OnColumn6:
	dec	8, xsp
	ld	(xsp+6), a
	lda	xbc, (xsp+2)
	ld	wa, 0:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+6)
	extz	wa
	ld	e, (xsp+2)
	inc	1, e
	extz	de
	pushw	127
	ld	bc, 2:i3
	call	SeMenu_StepNoteParamInRange
	cp	l, 1:i3
	jr	nz, SeAmpAmp2_OnColumn6_Skip9
	lda	xwa, (xsp+4)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 2:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+4)
	extz	wa
	lda	xde, (xsp)
	pushw	127
	ldw	bc, 28
	call	SeMenu_RegisterElement_Extended
	pushw	2
	pushw	44
	call	SeTitle_DrawField
	inc	4, xsp
	ld	wa, 0:i3
	ld	bc, 0:i3
	call	SeMenu_DrawKeyScaleGraph
SeAmpAmp2_OnColumn6_Skip9:
	ld	wa, 6:i3
	call	SeMenu_BindDialToColumn
	inc	8, xsp
	ret
SeAmpAmp2_OnSideRow1:	.include "includes/generated/cc900/SeAmpAmp2_OnSideRow1.s"	; C: cc900/scoop_editor_data_m0_xr.c
SeAmpAmp2_OnSideRow2:
	cp	a, 0:i3
	ret	z
	ld	wa, 1:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEAMPAMP2
	ld	bc, 1:i3
	call	SeMenu_SendEvent
	ret
SeAmpAmp2_OnSideRow3:
	cp	a, 0:i3
	jr	nz, SeAmpAmp2_OnSideRow3_Skip10
	ldw	wa, TT_SEAMPLFO1
	ld	bc, 0:i3
	jr	SeAmpAmp2_OnSideRow3_Join6
SeAmpAmp2_OnSideRow3_Skip10:
	ld	wa, 2:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEAMPAMP2
	ld	bc, 1:i3
SeAmpAmp2_OnSideRow3_Join6:
	call	SeMenu_SendEvent
	ret
SeAmpAmp2_OnSideRow4:
	cp	a, 0:i3
	ret	z
	ld	wa, 3:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEAMPAMP2
	ld	bc, 1:i3
	call	SeMenu_SendEvent
	ret
SeAmpAmp2_OnSideRow5:	.include "includes/generated/cc900/SeAmpAmp2_OnSideRow5.s"	; C: cc900/scoop_editor_data_m0_xr.c
SeAmpAmp2_OnSwitch25:	.include "includes/generated/cc900/SeAmpAmp2_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_xr.c
SeAmpAmp2_OnSwitch15:	.include "includes/generated/cc900/SeAmpAmp2_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_xr.c
SeAmpEnv1_OnColumn1:
	lda	xsp, (xsp-18)
	push	qiz
	ld	(xsp+18), a
	lda	xwa, (xsp+16)
	call	SeMenu_ValidatePartNumber
	lda	xwa, (xsp+14)
	call	SeMenu_LoadObjEntries
	cp	(xsp+14), 0
	scc8	nz, a
	ldfr_berp a, 251
	extz	wa
	lda	xbc, (xsp+2)
	call	SeMenu_LoadPartParam
	lda	xbc, (xsp+2)
	ld	(xbc+6), 127
	ld	(xbc+7), 0
	ld	(xbc+8), 100
	ld	(xbc+9), 0
	ld	a, (xsp+18)
	extz	wa
	lda	xbc, (xbc+10)
	call	SeMenu_SwitchToValueStep
	cp	(xsp+14), 0
	jr	nz, SeAmpEnv1_OnColumn1_Skip11
	ld	a, 39:opc
	jr	SeAmpEnv1_OnColumn1_Join7
SeAmpEnv1_OnColumn1_Skip11:
	ld	a, (xsp+16)
	dec	1, a
	extz	wa
	muls	wa, 21
	extz	xwa
	lda	xwa, (xwa+16)
	inc	8, xwa
	ld	(xsp+16), 0
SeAmpEnv1_OnColumn1_Join7:
	ldto_berp c, 251
	extz	bc
	ld	e, (xsp+16)
	extz	de
	extz	wa
	pushw	wa
	lda	xwa, (xsp+4)
	push	xwa
	ldw	wa, 45
	call	SeMenu_StepParamFieldAndSend
	call	SeMenu_DrawAmpEnvGraph
	ld	wa, 1:i3
	call	SeMenu_BindDialToColumn
	pop qiz
	lda	xsp, (xsp+18)
	ret
SeAmpEnv1_OnColumn2:
	lda	xsp, (xsp-18)
	push	qiz
	ld	(xsp+18), a
	lda	xwa, (xsp+16)
	call	SeMenu_ValidatePartNumber
	lda	xwa, (xsp+14)
	call	SeMenu_LoadObjEntries
	lda	xhl, (xsp+2)
	lda	xwa, (xhl+6)
	lda	xbc, (xhl+7)
	lda	xde, (xhl+8)
	lda	xhl, (xhl+9)
	ldib_erp	251, 2
	cp	(xsp+14), 0
	jr	nz, SeAmpEnv1_OnColumn2_Skip55
	ldib_erp 251, 1
SeAmpEnv1_OnColumn2_Skip55:
	ld	(xwa), 127
	ld	(xbc), 0
	ld	(xde), 100
	ld	(xhl), 0
	ldto_berp a, 251
	extz	wa
	lda	xbc, (xsp+2)
	call	SeMenu_LoadPartParam
	ld	a, (xsp+18)
	extz	wa
	lda	xbc, (xsp+12)
	call	SeMenu_SwitchToValueStep
	cp	(xsp+14), 0
	jr	nz, SeAmpEnv1_OnColumn2_Skip12
	ld	a, 40:opc
	jr	SeAmpEnv1_OnColumn2_Join8
SeAmpEnv1_OnColumn2_Skip12:
	ld	a, (xsp+16)
	dec	1, a
	extz	wa
	muls	wa, 21
	extz	xwa
	lda	xwa, (xwa+16)
	lda	xwa, (xwa+9)
	ld	(xsp+16), 0
SeAmpEnv1_OnColumn2_Join8:
	ldto_berp c, 251
	extz	bc
	ld	e, (xsp+16)
	extz	de
	extz	wa
	pushw	wa
	lda	xwa, (xsp+4)
	push	xwa
	ldw	wa, 45
	call	SeMenu_StepParamFieldAndSend
	call	SeMenu_DrawAmpEnvGraph
	ld	wa, 2:i3
	call	SeMenu_BindDialToColumn
	pop qiz
	lda	xsp, (xsp+18)
	ret
SeAmpEnv1_OnColumn3:
	lda	xsp, (xsp-18)
	push	qiz
	ld	(xsp+18), a
	lda	xwa, (xsp+16)
	call	SeMenu_ValidatePartNumber
	lda	xwa, (xsp+14)
	call	SeMenu_LoadObjEntries
	lda	xhl, (xsp+2)
	lda	xwa, (xhl+6)
	lda	xbc, (xhl+7)
	lda	xde, (xhl+8)
	lda	xhl, (xhl+9)
	ldib_erp	251, 3
	cp	(xsp+14), 0
	jr	nz, SeAmpEnv1_OnColumn3_Skip56
	ldib_erp 251, 2
SeAmpEnv1_OnColumn3_Skip56:
	ld	(xwa), 127
	ld	(xbc), 0
	ld	(xde), 100
	ld	(xhl), 0
	ldto_berp a, 251
	extz	wa
	lda	xbc, (xsp+2)
	call	SeMenu_LoadPartParam
	ld	a, (xsp+18)
	extz	wa
	lda	xbc, (xsp+12)
	call	SeMenu_SwitchToValueStep
	cp	(xsp+14), 0
	jr	nz, SeAmpEnv1_OnColumn3_Skip13
	ld	a, 41:opc
	jr	SeAmpEnv1_OnColumn3_Join9
SeAmpEnv1_OnColumn3_Skip13:
	ld	a, (xsp+16)
	dec	1, a
	extz	wa
	muls	wa, 21
	extz	xwa
	lda	xwa, (xwa+16)
	lda	xwa, (xwa+10)
	ld	(xsp+16), 0
SeAmpEnv1_OnColumn3_Join9:
	ldto_berp c, 251
	extz	bc
	ld	e, (xsp+16)
	extz	de
	extz	wa
	pushw	wa
	lda	xwa, (xsp+4)
	push	xwa
	ldw	wa, 45
	call	SeMenu_StepParamFieldAndSend
	call	SeMenu_DrawAmpEnvGraph
	ld	wa, 3:i3
	call	SeMenu_BindDialToColumn
	pop qiz
	lda	xsp, (xsp+18)
	ret
SeAmpEnv1_OnColumn4:
	lda	xsp, (xsp-18)
	push	qiz
	ld	(xsp+18), a
	lda	xwa, (xsp+16)
	call	SeMenu_ValidatePartNumber
	lda	xwa, (xsp+14)
	call	SeMenu_LoadObjEntries
	lda	xhl, (xsp+2)
	lda	xwa, (xhl+6)
	lda	xbc, (xhl+7)
	lda	xde, (xhl+8)
	lda	xhl, (xhl+9)
	ldib_erp	251, 4
	cp	(xsp+14), 0
	jr	nz, SeAmpEnv1_OnColumn4_Skip57
	ldib_erp 251, 3
SeAmpEnv1_OnColumn4_Skip57:
	ld	(xwa), 127
	ld	(xbc), 0
	ld	(xde), 100
	ld	(xhl), 0
	ldto_berp a, 251
	extz	wa
	lda	xbc, (xsp+2)
	call	SeMenu_LoadPartParam
	ld	a, (xsp+18)
	extz	wa
	lda	xbc, (xsp+12)
	call	SeMenu_SwitchToValueStep
	cp	(xsp+14), 0
	jr	nz, SeAmpEnv1_OnColumn4_Skip14
	ld	a, 42:opc
	jr	SeAmpEnv1_OnColumn4_Join10
SeAmpEnv1_OnColumn4_Skip14:
	ld	a, (xsp+16)
	dec	1, a
	extz	wa
	muls	wa, 21
	extz	xwa
	lda	xwa, (xwa+16)
	lda	xwa, (xwa+11)
	ld	(xsp+16), 0
SeAmpEnv1_OnColumn4_Join10:
	ldto_berp c, 251
	extz	bc
	ld	e, (xsp+16)
	extz	de
	extz	wa
	pushw	wa
	lda	xwa, (xsp+4)
	push	xwa
	ldw	wa, 45
	call	SeMenu_StepParamFieldAndSend
	call	SeMenu_DrawAmpEnvGraph
	ld	wa, 4:i3
	call	SeMenu_BindDialToColumn
	pop qiz
	lda	xsp, (xsp+18)
	ret
SeAmpEnv1_OnColumn5:
	lda	xsp, (xsp-20)
	push	qiz
	ld	(xsp+20), a
	lda	xwa, (xsp+18)
	call	SeMenu_ValidatePartNumber
	lda	xwa, (xsp+16)
	call	SeMenu_LoadObjEntries
	cp	(xsp+16), 0
	jr	nz, SeAmpEnv1_OnColumn5_Skip58
	ldib_erp 251, 4
	lda	xwa, (xsp+2)
	ld	(xwa+6), 127
	ld	(xwa+7), 0
	ld	(xwa+8), 100
	jr	SeAmpEnv1_OnColumn5_Join11
SeAmpEnv1_OnColumn5_Skip58:
	lda	xbc, (xsp+14)
	ld	wa, 0:i3
	call	SeMenu_LoadPartParam
	bitm	5, (xsp+14)
	jr	z, SeAmpEnv1_OnColumn5_Epilogue41
	ldib_erp	251, 5
	lda	xwa, (xsp+2)
	ld	(xwa+6), 127
	ld	(xwa+7), 0
	ld	(xwa+8), 100
SeAmpEnv1_OnColumn5_Join11:
	ld	(xwa+9), 0
	ldto_berp a, 251
	extz	wa
	lda	xbc, (xsp+2)
	call	SeMenu_LoadPartParam
	ld	a, (xsp+20)
	extz	wa
	lda	xbc, (xsp+12)
	call	SeMenu_SwitchToValueStep
	cp	(xsp+16), 0
	jr	nz, SeAmpEnv1_OnColumn5_Skip15
	ld	a, 43:opc
	jr	SeAmpEnv1_OnColumn5_Join12
SeAmpEnv1_OnColumn5_Skip15:
	ld	a, (xsp+18)
	dec	1, a
	extz	wa
	muls	wa, 21
	extz	xwa
	lda	xwa, (xwa+16)
	lda	xwa, (xwa+12)
	ld	(xsp+18), 0
SeAmpEnv1_OnColumn5_Join12:
	ldto_berp c, 251
	extz	bc
	ld	e, (xsp+18)
	extz	de
	extz	wa
	pushw	wa
	lda	xwa, (xsp+4)
	push	xwa
	ldw	wa, 45
	call	SeMenu_StepParamFieldAndSend
	call	SeMenu_DrawAmpEnvGraph
	ld	wa, 5:i3
	call	SeMenu_BindDialToColumn
SeAmpEnv1_OnColumn5_Epilogue41:
	pop qiz
	lda	xsp, (xsp+20)
	ret
SeAmpEnv1_OnColumn6:
	lda	xsp, (xsp-20)
	push	qiz
	ld	(xsp+20), a
	lda	xwa, (xsp+18)
	call	SeMenu_ValidatePartNumber
	lda	xwa, (xsp+16)
	call	SeMenu_LoadObjEntries
	cp	(xsp+16), 0
	jr	nz, SeAmpEnv1_OnColumn6_Skip59
	ldib_erp 251, 5
	lda	xwa, (xsp+2)
	ld	(xwa+6), 127
	ld	(xwa+7), 0
	ld	(xwa+8), 100
	jr	SeAmpEnv1_OnColumn6_Join13
SeAmpEnv1_OnColumn6_Skip59:
	lda	xbc, (xsp+14)
	ld	wa, 0:i3
	call	SeMenu_LoadPartParam
	bitm	5, (xsp+14)
	jr	z, SeAmpEnv1_OnColumn6_Epilogue42
	ldib_erp	251, 6
	lda	xwa, (xsp+2)
	ld	(xwa+6), 127
	ld	(xwa+7), 0
	ld	(xwa+8), 100
SeAmpEnv1_OnColumn6_Join13:
	ld	(xwa+9), 0
	ldto_berp a, 251
	extz	wa
	lda	xbc, (xsp+2)
	call	SeMenu_LoadPartParam
	ld	a, (xsp+20)
	extz	wa
	lda	xbc, (xsp+12)
	call	SeMenu_SwitchToValueStep
	cp	(xsp+16), 0
	jr	nz, SeAmpEnv1_OnColumn6_Skip16
	ld	a, 44:opc
	jr	SeAmpEnv1_OnColumn6_Join14
SeAmpEnv1_OnColumn6_Skip16:
	ld	a, (xsp+18)
	dec	1, a
	extz	wa
	muls	wa, 21
	extz	xwa
	lda	xwa, (xwa+16)
	lda	xwa, (xwa+13)
	ld	(xsp+18), 0
SeAmpEnv1_OnColumn6_Join14:
	ldto_berp c, 251
	extz	bc
	ld	e, (xsp+18)
	extz	de
	extz	wa
	pushw	wa
	lda	xwa, (xsp+4)
	push	xwa
	ldw	wa, 45
	call	SeMenu_StepParamFieldAndSend
	call	SeMenu_DrawAmpEnvGraph
	ld	wa, 6:i3
	call	SeMenu_BindDialToColumn
SeAmpEnv1_OnColumn6_Epilogue42:
	pop qiz
	lda	xsp, (xsp+20)
	ret
SeAmpEnv1_OnColumn7:	.include "includes/generated/cc900/SeAmpEnv1_OnColumn7.s"	; C: cc900/scoop_editor_data_m0_c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv1_OnColumn7_Epilogue43, SeAmpEnv1_OnColumn7 + 95
SeAmpEnv1_OnColumn8:	.include "includes/generated/cc900/SeAmpEnv1_OnColumn8.s"	; C: cc900/scoop_editor_data_m0_c.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv1_OnColumn8_Epilogue44, SeAmpEnv1_OnColumn8 + 108
SeAmpEnv1_OnSideRow1:	.include "includes/generated/cc900/SeAmpEnv1_OnSideRow1.s"	; C: cc900/scoop_editor_data_m0_xr.c
SeAmpEnv1_OnSideRow2:	.include "includes/generated/cc900/SeAmpEnv1_OnSideRow2.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv1_OnSideRow2_Skip17, SeAmpEnv1_OnSideRow2 + 11
	.set	SeAmpEnv1_OnSideRow2_Join15, SeAmpEnv1_OnSideRow2 + 26
SeAmpEnv1_OnSideRow3:	.include "includes/generated/cc900/SeAmpEnv1_OnSideRow3.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv1_OnSideRow3_Skip18, SeAmpEnv1_OnSideRow3 + 29
	.set	SeAmpEnv1_OnSideRow3_Join16, SeAmpEnv1_OnSideRow3 + 44
	.set	SeAmpEnv1_OnSideRow3_Epilogue7, SeAmpEnv1_OnSideRow3 + 48
SeAmpEnv1_OnSideRow4:	.include "includes/generated/cc900/SeAmpEnv1_OnSideRow4.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv1_OnSideRow4_Epilogue45, SeAmpEnv1_OnSideRow4 + 41
SeAmpEnv1_OnSideRow5:	.include "includes/generated/cc900/SeAmpEnv1_OnSideRow5.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv1_OnSideRow5_Skip19, SeAmpEnv1_OnSideRow5 + 45
	.set	SeAmpEnv1_OnSideRow5_Skip60, SeAmpEnv1_OnSideRow5 + 61
	.set	SeAmpEnv1_OnSideRow5_Join17, SeAmpEnv1_OnSideRow5 + 63
	.set	SeAmpEnv1_OnSideRow5_Epilogue8, SeAmpEnv1_OnSideRow5 + 103
SeAmpEnv1_OnSwitch25:	.include "includes/generated/cc900/SeAmpEnv1_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv1_OnSwitch25_Epilogue46, SeAmpEnv1_OnSwitch25 + 31
SeAmpEnv1_OnSwitch15:	.include "includes/generated/cc900/SeAmpEnv1_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv1_OnSwitch15_Skip20, SeAmpEnv1_OnSwitch15 + 35
	.set	SeAmpEnv1_OnSwitch15_Join18, SeAmpEnv1_OnSwitch15 + 40
	.set	SeAmpEnv1_OnSwitch15_Epilogue9, SeAmpEnv1_OnSwitch15 + 44
SeAmpEnv2_OnColumn1:	.include "includes/generated/cc900/SeAmpEnv2_OnColumn1.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv2_OnColumn1_Skip61, SeAmpEnv2_OnColumn1 + 138
SeAmpEnv2_OnColumn2:	.include "includes/generated/cc900/SeAmpEnv2_OnColumn2.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv2_OnColumn2_Skip62, SeAmpEnv2_OnColumn2 + 138
SeAmpEnv2_OnColumn3:	.include "includes/generated/cc900/SeAmpEnv2_OnColumn3.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeAmpEnv2_OnColumn3_Skip63, SeAmpEnv2_OnColumn3 + 138
SeAmpEnv2_OnColumn4:
	dec	8, xsp
	ld	(xsp+6), a
	lda	xbc, (xsp+2)
	ld	wa, 2:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+6)
	extz	wa
	ld	c, (xsp+2)
	dec	1, c
	extz	bc
	pushw	bc
	ld	bc, 3:i3
	ld	de, 0:i3
	call	SeMenu_StepNoteParamInRange
	cp	l, 1:i3
	jr	nz, SeAmpEnv2_OnColumn4_Skip21
	lda	xwa, (xsp+4)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 3:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+4)
	extz	wa
	lda	xde, (xsp)
	pushw	127
	ldw	bc, 49
	call	SeMenu_RegisterElement_Extended
	pushw	3
	pushw	46
	call	SeTitle_DrawField
	inc	4, xsp
	ld	wa, 2:i3
	ld	bc, 0:i3
	call	SeMenu_DrawKeyScaleGraph
SeAmpEnv2_OnColumn4_Skip21:
	ld	wa, 4:i3
	call	SeMenu_BindDialToColumn
	inc	8, xsp
	ret
SeAmpEnv2_OnColumn5:
	lda	xsp, (xsp-10)
	ld	(xsp+8), a
	lda	xbc, (xsp+2)
	ld	wa, 4:i3
	call	SeMenu_LoadPartParam
	lda	xbc, (xsp+4)
	ld	wa, 3:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+8)
	extz	wa
	ld	e, (xsp+4)
	inc	1, e
	extz	de
	ld	c, (xsp+2)
	dec	1, c
	extz	bc
	pushw	bc
	ld	bc, 2:i3
	call	SeMenu_StepNoteParamInRange
	cp	l, 1:i3
	jr	nz, SeAmpEnv2_OnColumn5_Skip22
	lda	xwa, (xsp+6)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 2:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+6)
	extz	wa
	lda	xde, (xsp)
	pushw	127
	ldw	bc, 48
	call	SeMenu_RegisterElement_Extended
	pushw	2
	pushw	46
	call	SeTitle_DrawField
	inc	4, xsp
	ld	wa, 2:i3
	ld	bc, 0:i3
	call	SeMenu_DrawKeyScaleGraph
SeAmpEnv2_OnColumn5_Skip22:
	ld	wa, 5:i3
	call	SeMenu_BindDialToColumn
	lda	xsp, (xsp+10)
	ret
SeAmpEnv2_OnColumn6:
	dec	8, xsp
	ld	(xsp+6), a
	lda	xbc, (xsp+2)
	ld	wa, 2:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+6)
	extz	wa
	ld	e, (xsp+2)
	inc	1, e
	extz	de
	pushw	127
	ld	bc, 4:i3
	call	SeMenu_StepNoteParamInRange
	cp	l, 1:i3
	jr	nz, SeAmpEnv2_OnColumn6_Skip23
	lda	xwa, (xsp+4)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 4:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+4)
	extz	wa
	lda	xde, (xsp)
	pushw	127
	ldw	bc, 50
	call	SeMenu_RegisterElement_Extended
	pushw	4
	pushw	46
	call	SeTitle_DrawField
	inc	4, xsp
	ld	wa, 2:i3
	ld	bc, 0:i3
	call	SeMenu_DrawKeyScaleGraph
SeAmpEnv2_OnColumn6_Skip23:
	ld	wa, 6:i3
	call	SeMenu_BindDialToColumn
	inc	8, xsp
	ret
SeAmpEnv2_OnColumn7:
	lda	xsp, (xsp-16)
	ld	(xsp+14), a
	lda	xwa, (xsp+12)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 0:i3
	call	SeMenu_LoadPartParam
	lda	xbc, (xsp)
	ld	(xbc+6), 255
	ld	(xbc+7), 0
	ld	(xbc+8), 50
	ld	(xbc+9), 206
	ld	a, (xsp+14)
	extz	wa
	lda	xbc, (xbc+10)
	call	SeMenu_SwitchToValueStep
	ld	e, (xsp+12)
	extz	de
	pushw	46
	lda	xwa, (xsp+2)
	push	xwa
	ldw	wa, 46
	ld	bc, 0:i3
	call	SeMenu_StepParamFieldAndSend
	ld	wa, 7:i3
	call	SeMenu_BindDialToColumn
	lda	xsp, (xsp+16)
	ret
SeAmpEnv2_OnColumn8:
	lda	xsp, (xsp-16)
	ld	(xsp+14), a
	lda	xwa, (xsp+12)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 1:i3
	call	SeMenu_LoadPartParam
	lda	xbc, (xsp)
	ld	(xbc+6), 255
	ld	(xbc+7), 0
	ld	(xbc+8), 50
	ld	(xbc+9), 206
	ld	a, (xsp+14)
	extz	wa
	lda	xbc, (xbc+10)
	call	SeMenu_SwitchToValueStep
	ld	e, (xsp+12)
	extz	de
	pushw	47
	lda	xwa, (xsp+2)
	push	xwa
	ldw	wa, 46
	ld	bc, 1:i3
	call	SeMenu_StepParamFieldAndSend
	ldw	wa, 8
	call	SeMenu_BindDialToColumn
	lda	xsp, (xsp+16)
	ret
SeAmpEnv2_OnSideRow1:
	cp	a, 0:i3
	ret	z
	call	SeMenu_ToggleSolo
	ret
SeAmpEnv2_OnSideRow2:
	cp	a, 0:i3
	jr	nz, SeAmpEnv2_OnSideRow2_Skip24
	ldw	wa, TT_SEAMPAMP1
	ld	bc, 0:i3
	jr	SeAmpEnv2_OnSideRow2_Join19
SeAmpEnv2_OnSideRow2_Skip24:
	ld	wa, 1:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEAMPENV2
	ld	bc, 1:i3
SeAmpEnv2_OnSideRow2_Join19:
	call	SeMenu_SendEvent
	ret
SeAmpEnv2_OnSideRow3:
	cp	a, 0:i3
	jr	nz, SeAmpEnv2_OnSideRow3_Skip25
	ldw	wa, TT_SEAMPLFO1
	ld	bc, 0:i3
	jr	SeAmpEnv2_OnSideRow3_Join20
SeAmpEnv2_OnSideRow3_Skip25:
	ld	wa, 2:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEAMPENV2
	ld	bc, 1:i3
SeAmpEnv2_OnSideRow3_Join20:
	call	SeMenu_SendEvent
	ret
SeAmpEnv2_OnSideRow4:
	cp	a, 0:i3
	ret	z
	ld	wa, 3:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEAMPENV2
	ld	bc, 1:i3
	call	SeMenu_SendEvent
	ret
SeAmpEnv2_OnSideRow5:
	cp	a, 0:i3
	ret	z
	ld	wa, 4:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEAMPENV2
	ld	bc, 1:i3
	call	SeMenu_SendEvent
	ret
SeAmpEnv2_OnSwitch25:
	cp	a, 0:i3
	ret	z
	ldw	wa, TT_SEAMPENV1
	ld	bc, 0:i3
	call	SeMenu_SendEvent
	ret
SeAmpEnv2_OnSwitch15:
	cp	a, 0:i3
	ret	nz
	ld	wa, 0:i3
	call	SeMenu_SetupMenuDisplay
	ldw	wa, TT_SEMENU
	ld	bc, 0:i3
	call	SeMenu_SendEvent
	ret
SeAmpLfo1_OnColumn2:
	extz	wa
	ld	bc, 0:i3
	jp	SeLfo1_StepSelectorAndReload
SeAmpLfo1_OnColumn3:
	extz	wa
	ld	bc, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join
SeAmpLfo1_OnColumn4:
	extz	wa
	ld	bc, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join2
SeAmpLfo1_OnColumn5:
	extz	wa
	ld	bc, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join3
SeAmpLfo1_OnColumn6:
	extz	wa
	ld	bc, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join4
SeAmpLfo1_OnColumn7:
	extz	wa
	ld	bc, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join5
SeAmpLfo1_OnColumn8:
	extz	wa
	ld	bc, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join6
SeAmpLfo1_OnSideRow1:
	cp	a, 0:i3
	jp	nz, (SeMenu_ToggleSolo:24)
	ldw	wa, TT_SEAMPENV1
	ld	bc, 0:i3
	jp	SeMenu_SendEvent
SeAmpLfo1_OnSideRow2:
	cp	a, 0:i3
	jr	nz, SeAmpLfo1_OnSideRow2_Skip26
	ldw	wa, TT_SEAMPAMP1
	ld	bc, 0:i3
	jp	SeMenu_SendEvent
SeAmpLfo1_OnSideRow2_Skip26:
	ld	wa, 0:i3
	ld	bc, 1:i3
	jp	SeMenu_CyclePartLfoState
SeAmpLfo1_OnSideRow3:
	cp	a, 0:i3
	ret	z
	ld	wa, 0:i3
	ld	bc, 2:i3
	call	SeMenu_CyclePartLfoState
	ret
SeAmpLfo1_OnSideRow4:
	cp	a, 0:i3
	ret	z
	ld	wa, 0:i3
	ld	bc, 3:i3
	call	SeMenu_CyclePartLfoState
	ret
SeAmpLfo1_OnSideRow5:
	cp	a, 0:i3
	ret	z
	ld	wa, 0:i3
	ld	bc, 4:i3
	call	SeMenu_CyclePartLfoState
	ret
SeAmpLfo1_OnSwitch15:
	cp	a, 0:i3
	ret	nz
	ld	wa, 0:i3
	call	SeMenu_SetupMenuDisplay
	ldw	wa, TT_SEMENU
	ld	bc, 0:i3
	call	SeMenu_SendEvent
	ret
SeFilLpq1TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilLpq1TitleFunc_DispatchSwitch_Epilogue10
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilLpq1TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilLpq1TitleFunc_DispatchSwitch_Epilogue10:
	inc	4, xsp
	ret
SeFilHpq1TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilHpq1TitleFunc_DispatchSwitch_Epilogue11
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilHpq1TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilHpq1TitleFunc_DispatchSwitch_Epilogue11:
	inc	4, xsp
	ret
SeFilL241TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilL241TitleFunc_DispatchSwitch_Epilogue12
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilL241TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilL241TitleFunc_DispatchSwitch_Epilogue12:
	inc	4, xsp
	ret
SeFilH241TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilH241TitleFunc_DispatchSwitch_Epilogue13
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilH241TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilH241TitleFunc_DispatchSwitch_Epilogue13:
	inc	4, xsp
	ret
SeFilBpf1TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilBpf1TitleFunc_DispatchSwitch_Epilogue14
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilBpf1TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilBpf1TitleFunc_DispatchSwitch_Epilogue14:
	inc	4, xsp
	ret
SeFilBcf1TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilBcf1TitleFunc_DispatchSwitch_Epilogue15
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilBcf1TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilBcf1TitleFunc_DispatchSwitch_Epilogue15:
	inc	4, xsp
	ret
SeFilFil2TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilFil2TitleFunc_DispatchSwitch_Epilogue16
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilFil2TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilFil2TitleFunc_DispatchSwitch_Epilogue16:
	inc	4, xsp
	ret
SeFilEnv1TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilEnv1TitleFunc_DispatchSwitch_Epilogue17
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilEnv1TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilEnv1TitleFunc_DispatchSwitch_Epilogue17:
	inc	4, xsp
	ret
SeFilEnv2TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilEnv2TitleFunc_DispatchSwitch_Epilogue18
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilEnv2TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilEnv2TitleFunc_DispatchSwitch_Epilogue18:
	inc	4, xsp
	ret
SeFilLfo1TitleFunc_DispatchSwitch:
	dec	4, xsp
	lda	xde, (xsp+2)
	lda	xhl, (xsp)
	push	xhl
	call	SeTitle_DecodeSwitch
	cp	hl, 0xffff
	jr	z, SeFilLfo1TitleFunc_DispatchSwitch_Epilogue19
	ld	a, (xsp)
	extz	wa
	ld	c, (xsp+2)
	extz	bc
	sla	bc, 2
	lda	xde, (SeFilLfo1TitleFunc_SwitchHandlers:24)
	exts	xbc
	add	xbc, xde
	ld	xhl, (xbc)
	call	(xhl)
SeFilLfo1TitleFunc_DispatchSwitch_Epilogue19:
	inc	4, xsp
	ret
SeFilLpq1_OnColumn1:
	extz	wa
	ld	bc, 1:i3
	ldw	de, 48
	calr	SeMenu_EditFilterCutoff
	ld	wa, 0:i3
	ld	bc, 0:i3
	jp	SeMenu_DrawFilterGraph
; SeMenu_EditFilterCutoff: Steps the current part's filter cutoff (part param 2, range 0..127) by the column switch in
;   A and applies it via SeMenu_StepParamFieldAndSend (popup id E), then posts the column's dial events
;   (SeMenu_BindDialToColumn(C)). Basis: callers + body -- filter-page column handlers (Lpq1/Hpq1 col 1,
;   L241/H241 col 3) call it, then redraw with SeMenu_DrawFilterGraph, which places the corner at x = 86 + param 2.
SeMenu_EditFilterCutoff:	.include "includes/generated/cc900/SeMenu_EditFilterCutoff.s"	; C: cc900/scoop_editor_data_m128.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeMenu_EditFilterCutoff_Skip, SeMenu_EditFilterCutoff + 74
	.set	SeMenu_EditFilterCutoff_Join, SeMenu_EditFilterCutoff + 99
SeFilLpq1_OnColumn2:	.include "includes/generated/cc900/SeFilLpq1_OnColumn2.s"	; C: cc900/scoop_editor_data_m0_xr.c
; SeMenu_EditFilterResonance: Steps the current part's filter resonance (part param 3, range 0..5) by the column
;   switch in A and applies it via SeMenu_StepParamFieldAndSend (popup id E), then posts the column's dial events
;   (SeMenu_BindDialToColumn(C)). Basis: callers + body -- filter-page column handlers (Lpq1/Hpq1 col 2,
;   L241/H241 col 4, Bpf1 col 3) call it, then redraw with SeMenu_DrawFilterGraph, which plots param 3 as the peak
;   height.
SeMenu_EditFilterResonance:	.include "includes/generated/cc900/SeMenu_EditFilterResonance.s"	; C: cc900/scoop_editor_data_m128.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeMenu_EditFilterResonance_Skip, SeMenu_EditFilterResonance + 74
	.set	SeMenu_EditFilterResonance_Join, SeMenu_EditFilterResonance + 99
SeFilLpq1_OnColumn3:	.include "includes/generated/cc900/SeFilLpq1_OnColumn3.s"	; C: cc900/scoop_editor_data_m0_xr.c
SeFilLpq1_OnColumn3_Join21:	.include "includes/generated/cc900/SeFilLpq1_OnColumn3_Join21.s"	; C: cc900/scoop_editor_data_m0.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnColumn3_Skip2, SeFilLpq1_OnColumn3_Join21 + 74
	.set	SeFilLpq1_OnColumn3_Join2, SeFilLpq1_OnColumn3_Join21 + 99
SeFilLpq1_OnColumn4:	.include "includes/generated/cc900/SeFilLpq1_OnColumn4.s"	; C: cc900/scoop_editor_data_m0_xr.c
SeFilLpq1_OnColumn4_Join22:	.include "includes/generated/cc900/SeFilLpq1_OnColumn4_Join22.s"	; C: cc900/scoop_editor_data_m0.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnColumn4_Skip3, SeFilLpq1_OnColumn4_Join22 + 74
	.set	SeFilLpq1_OnColumn4_Join3, SeFilLpq1_OnColumn4_Join22 + 99
SeFilLpq1_OnColumn4_Join23:
	lda	xsp, (xsp-18)
	ld	(xsp+16), a
	lda	xwa, (xsp+14)
	call	SeMenu_ValidatePartNumber
	lda	xwa, (xsp+12)
	call	SeMenu_LoadObjEntries
	lda	xbc, (xsp)
	ld	wa, 5:i3
	call	SeMenu_LoadPartParam
	lda	xbc, (xsp)
	ld	(xbc+6), 1
	ld	(xbc+7), 7
	ld	(xbc+8), 1
	ld	(xbc+9), 0
	ld	e, (xsp+16)
	res	7, e
	lda	xwa, (xbc+10)
	cp	e, 0:i3
	jr	nz, SeFilLpq1_OnColumn4_Skip4
	ld	(xwa), 1
	jr	SeFilLpq1_OnColumn4_Join4
SeFilLpq1_OnColumn4_Skip4:
	ld	(xwa), 255
SeFilLpq1_OnColumn4_Join4:
	cp	(xsp+12), 0
	jr	nz, SeFilLpq1_OnColumn4_Skip5
	ld	a, 80:opc
	jr	SeFilLpq1_OnColumn4_Join5
SeFilLpq1_OnColumn4_Skip5:
	ld	a, (xsp+14)
	dec	1, a
	extz	wa
	muls	wa, 21
	extz	xwa
	lda	xwa, (xwa+16)
	lda	xwa, (xwa+20)
	ld	(xsp+14), 0
SeFilLpq1_OnColumn4_Join5:
	ld	e, (xsp+14)
	extz	de
	extz	wa
	pushw	wa
	push	xbc
	ldw	wa, 48
	ld	bc, 5:i3
	call	SeMenu_StepParamFieldAndSend
	cp	l, 1:i3
	call	z, (SeMenu_DrawFilterEqGraph:24)
	ld	wa, 6:i3
	call	SeMenu_BindDialToColumn
	lda	xsp, (xsp+18)
	ret
SeFilLpq1_OnColumn4_Join24:	.include "includes/generated/cc900/SeFilLpq1_OnColumn4_Join24.s"	; C: cc900/scoop_editor_data_m0_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnColumn4_Skip6, SeFilLpq1_OnColumn4_Join24 + 68
	.set	SeFilLpq1_OnColumn4_Join6, SeFilLpq1_OnColumn4_Join24 + 91
SeFilLpq1_OnColumn4_Join25:	.include "includes/generated/cc900/SeFilLpq1_OnColumn4_Join25.s"	; C: cc900/scoop_editor_data_m0_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnColumn4_Skip7, SeFilLpq1_OnColumn4_Join25 + 68
	.set	SeFilLpq1_OnColumn4_Join7, SeFilLpq1_OnColumn4_Join25 + 91
SeFilLpq1_OnColumn4_Join26:	.include "includes/generated/cc900/SeFilLpq1_OnColumn4_Join26.s"	; C: cc900/scoop_editor_data_m0_xr.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnColumn4_Skip27, SeFilLpq1_OnColumn4_Join26 + 33
	.set	SeFilLpq1_OnColumn4_Epilogue20, SeFilLpq1_OnColumn4_Join26 + 37
SeFilLpq1_OnColumn4_Join27:	.include "includes/generated/cc900/SeFilLpq1_OnColumn4_Join27.s"	; C: cc900/scoop_editor_data_m0_xr.c
SeFilLpq1_OnColumn4_Join28:	.include "includes/generated/cc900/SeFilLpq1_OnColumn4_Join28.s"	; C: cc900/scoop_editor_data_m0.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnColumn4_Skip28, SeFilLpq1_OnColumn4_Join28 + 29
	.set	SeFilLpq1_OnColumn4_Join29, SeFilLpq1_OnColumn4_Join28 + 44
	.set	SeFilLpq1_OnColumn4_Epilogue21, SeFilLpq1_OnColumn4_Join28 + 48
SeFilLpq1_OnSideRow4:	.include "includes/generated/cc900/SeFilLpq1_OnSideRow4.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnSideRow4_Skip8, SeFilLpq1_OnSideRow4 + 49
	.set	SeFilLpq1_OnSideRow4_Join8, SeFilLpq1_OnSideRow4 + 69
	.set	SeFilLpq1_OnSideRow4_Epilogue, SeFilLpq1_OnSideRow4 + 73
SeFilLpq1_OnSideRow4_Join30:	.include "includes/generated/cc900/SeFilLpq1_OnSideRow4_Join30.s"	; C: cc900/scoop_editor_data_m0_xr_b_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnSideRow4_Epilogue2, SeFilLpq1_OnSideRow4_Join30 + 41
SeFilLpq1_OnSwitch25:	.include "includes/generated/cc900/SeFilLpq1_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnSwitch25_Epilogue3, SeFilLpq1_OnSwitch25 + 31
SeFilLpq1_OnSwitch15:	.include "includes/generated/cc900/SeFilLpq1_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilLpq1_OnSwitch15_Skip29, SeFilLpq1_OnSwitch15 + 35
	.set	SeFilLpq1_OnSwitch15_Join31, SeFilLpq1_OnSwitch15 + 40
	.set	SeFilLpq1_OnSwitch15_Epilogue22, SeFilLpq1_OnSwitch15 + 44
SeFilHpq1_OnColumn1:	.include "includes/generated/cc900/SeFilHpq1_OnColumn1.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnColumn2:	.include "includes/generated/cc900/SeFilHpq1_OnColumn2.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnColumn3:	.include "includes/generated/cc900/SeFilHpq1_OnColumn3.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnColumn4:	.include "includes/generated/cc900/SeFilHpq1_OnColumn4.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnColumn6:	.include "includes/generated/cc900/SeFilHpq1_OnColumn6.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnColumn7:	.include "includes/generated/cc900/SeFilHpq1_OnColumn7.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnColumn8:	.include "includes/generated/cc900/SeFilHpq1_OnColumn8.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnSideRow1:	.include "includes/generated/cc900/SeFilHpq1_OnSideRow1.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnSideRow2:	.include "includes/generated/cc900/SeFilHpq1_OnSideRow2.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnSideRow3:	.include "includes/generated/cc900/SeFilHpq1_OnSideRow3.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnSideRow4:	.include "includes/generated/cc900/SeFilHpq1_OnSideRow4.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilHpq1_OnSideRow4_Skip9, SeFilHpq1_OnSideRow4 + 50
	.set	SeFilHpq1_OnSideRow4_Join9, SeFilHpq1_OnSideRow4 + 70
	.set	SeFilHpq1_OnSideRow4_Epilogue23, SeFilHpq1_OnSideRow4 + 74
SeFilHpq1_OnSideRow5:	.include "includes/generated/cc900/SeFilHpq1_OnSideRow5.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilHpq1_OnSwitch25:	.include "includes/generated/cc900/SeFilHpq1_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilHpq1_OnSwitch25_Epilogue24, SeFilHpq1_OnSwitch25 + 31
SeFilHpq1_OnSwitch15:	.include "includes/generated/cc900/SeFilHpq1_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilHpq1_OnSwitch15_Skip30, SeFilHpq1_OnSwitch15 + 35
	.set	SeFilHpq1_OnSwitch15_Join32, SeFilHpq1_OnSwitch15 + 40
	.set	SeFilHpq1_OnSwitch15_Epilogue25, SeFilHpq1_OnSwitch15 + 44
SeFilL241_OnColumn3:	.include "includes/generated/cc900/SeFilL241_OnColumn3.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilL241_OnColumn4:	.include "includes/generated/cc900/SeFilL241_OnColumn4.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilL241_OnColumn5:	.include "includes/generated/cc900/SeFilL241_OnColumn5.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilL241_OnColumn6:	.include "includes/generated/cc900/SeFilL241_OnColumn6.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilL241_OnColumn6_Join33:	.include "includes/generated/cc900/SeFilL241_OnColumn6_Join33.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilL241_OnColumn6_Skip31, SeFilL241_OnColumn6_Join33 + 33
	.set	SeFilL241_OnColumn6_Epilogue26, SeFilL241_OnColumn6_Join33 + 37
SeFilL241_OnColumn6_Join34:	.include "includes/generated/cc900/SeFilL241_OnColumn6_Join34.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilL241_OnColumn6_Join35:	.include "includes/generated/cc900/SeFilL241_OnColumn6_Join35.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilL241_OnColumn6_Skip32, SeFilL241_OnColumn6_Join35 + 29
	.set	SeFilL241_OnColumn6_Join36, SeFilL241_OnColumn6_Join35 + 44
	.set	SeFilL241_OnColumn6_Epilogue27, SeFilL241_OnColumn6_Join35 + 48
SeFilL241_OnSideRow4:	.include "includes/generated/cc900/SeFilL241_OnSideRow4.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilL241_OnSideRow4_Skip10, SeFilL241_OnSideRow4 + 49
	.set	SeFilL241_OnSideRow4_Join10, SeFilL241_OnSideRow4 + 69
	.set	SeFilL241_OnSideRow4_Epilogue4, SeFilL241_OnSideRow4 + 73
SeFilL241_OnSideRow4_Join11:	.include "includes/generated/cc900/SeFilL241_OnSideRow4_Join11.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilL241_OnSideRow4_Epilogue5, SeFilL241_OnSideRow4_Join11 + 41
SeFilL241_OnSwitch25:	.include "includes/generated/cc900/SeFilL241_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilL241_OnSwitch25_Epilogue6, SeFilL241_OnSwitch25 + 31
SeFilL241_OnSwitch15:	.include "includes/generated/cc900/SeFilL241_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilL241_OnSwitch15_Skip33, SeFilL241_OnSwitch15 + 35
	.set	SeFilL241_OnSwitch15_Join37, SeFilL241_OnSwitch15 + 40
	.set	SeFilL241_OnSwitch15_Epilogue28, SeFilL241_OnSwitch15 + 44
SeFilH241_OnColumn3:	.include "includes/generated/cc900/SeFilH241_OnColumn3.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilH241_OnColumn4:	.include "includes/generated/cc900/SeFilH241_OnColumn4.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilH241_OnColumn5:	.include "includes/generated/cc900/SeFilH241_OnColumn5.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilH241_OnColumn6:	.include "includes/generated/cc900/SeFilH241_OnColumn6.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilH241_OnSideRow1:	.include "includes/generated/cc900/SeFilH241_OnSideRow1.s"	; C: cc900/scoop_editor_data_m0_xr_b_b.c
SeFilH241_OnSideRow2:	.include "includes/generated/cc900/SeFilH241_OnSideRow2.s"	; C: cc900/scoop_editor_data_m0_xr_b_b.c
SeFilH241_OnSideRow3:	.include "includes/generated/cc900/SeFilH241_OnSideRow3.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilH241_OnSideRow4:	.include "includes/generated/cc900/SeFilH241_OnSideRow4.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilH241_OnSideRow4_Skip11, SeFilH241_OnSideRow4 + 50
	.set	SeFilH241_OnSideRow4_Join12, SeFilH241_OnSideRow4 + 70
	.set	SeFilH241_OnSideRow4_Epilogue7, SeFilH241_OnSideRow4 + 74
SeFilH241_OnSideRow5:	.include "includes/generated/cc900/SeFilH241_OnSideRow5.s"	; C: cc900/scoop_editor_data_m0_xr_b_b.c
SeFilH241_OnSwitch25:	.include "includes/generated/cc900/SeFilH241_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilH241_OnSwitch25_Epilogue8, SeFilH241_OnSwitch25 + 31
SeFilH241_OnSwitch15:	.include "includes/generated/cc900/SeFilH241_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilH241_OnSwitch15_Skip34, SeFilH241_OnSwitch15 + 35
	.set	SeFilH241_OnSwitch15_Join38, SeFilH241_OnSwitch15 + 40
	.set	SeFilH241_OnSwitch15_Epilogue29, SeFilH241_OnSwitch15 + 44
SeFilBpf1_OnColumn2:	.include "includes/generated/cc900/SeFilBpf1_OnColumn2.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBpf1_OnColumn2_Skip12, SeFilBpf1_OnColumn2 + 81
	.set	SeFilBpf1_OnColumn2_Join13, SeFilBpf1_OnColumn2 + 104
SeFilBpf1_OnColumn3:	.include "includes/generated/cc900/SeFilBpf1_OnColumn3.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilBpf1_OnColumn4:	.include "includes/generated/cc900/SeFilBpf1_OnColumn4.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBpf1_OnColumn4_Skip13, SeFilBpf1_OnColumn4 + 95
	.set	SeFilBpf1_OnColumn4_Join14, SeFilBpf1_OnColumn4 + 125
SeFilBpf1_OnColumn5:	.include "includes/generated/cc900/SeFilBpf1_OnColumn5.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBpf1_OnColumn5_Skip14, SeFilBpf1_OnColumn5 + 82
	.set	SeFilBpf1_OnColumn5_Join15, SeFilBpf1_OnColumn5 + 112
SeFilBpf1_OnColumn6:	.include "includes/generated/cc900/SeFilBpf1_OnColumn6.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilBpf1_OnColumn7:	.include "includes/generated/cc900/SeFilBpf1_OnColumn7.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilBpf1_OnSideRow1:	.include "includes/generated/cc900/SeFilBpf1_OnSideRow1.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBpf1_OnSideRow1_Skip35, SeFilBpf1_OnSideRow1 + 33
	.set	SeFilBpf1_OnSideRow1_Epilogue30, SeFilBpf1_OnSideRow1 + 37
SeFilBpf1_OnSideRow2:	.include "includes/generated/cc900/SeFilBpf1_OnSideRow2.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilBpf1_OnSideRow3:	.include "includes/generated/cc900/SeFilBpf1_OnSideRow3.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBpf1_OnSideRow3_Skip36, SeFilBpf1_OnSideRow3 + 29
	.set	SeFilBpf1_OnSideRow3_Join39, SeFilBpf1_OnSideRow3 + 44
	.set	SeFilBpf1_OnSideRow3_Epilogue31, SeFilBpf1_OnSideRow3 + 48
SeFilBpf1_OnSideRow4:	.include "includes/generated/cc900/SeFilBpf1_OnSideRow4.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBpf1_OnSideRow4_Skip15, SeFilBpf1_OnSideRow4 + 46
	.set	SeFilBpf1_OnSideRow4_Join16, SeFilBpf1_OnSideRow4 + 66
	.set	SeFilBpf1_OnSideRow4_Epilogue9, SeFilBpf1_OnSideRow4 + 70
SeFilBpf1_OnSideRow5:	.include "includes/generated/cc900/SeFilBpf1_OnSideRow5.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBpf1_OnSideRow5_Epilogue10, SeFilBpf1_OnSideRow5 + 41
SeFilBpf1_OnSwitch25:	.include "includes/generated/cc900/SeFilBpf1_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBpf1_OnSwitch25_Epilogue11, SeFilBpf1_OnSwitch25 + 31
SeFilBpf1_OnSwitch15:	.include "includes/generated/cc900/SeFilBpf1_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBpf1_OnSwitch15_Skip37, SeFilBpf1_OnSwitch15 + 35
	.set	SeFilBpf1_OnSwitch15_Join40, SeFilBpf1_OnSwitch15 + 40
	.set	SeFilBpf1_OnSwitch15_Epilogue32, SeFilBpf1_OnSwitch15 + 44
SeFilBcf1_OnSideRow1:	.include "includes/generated/cc900/SeFilBcf1_OnSideRow1.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBcf1_OnSideRow1_Skip38, SeFilBcf1_OnSideRow1 + 33
	.set	SeFilBcf1_OnSideRow1_Epilogue33, SeFilBcf1_OnSideRow1 + 37
SeFilBcf1_OnSideRow2:	.include "includes/generated/cc900/SeFilBcf1_OnSideRow2.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilBcf1_OnSideRow3:	.include "includes/generated/cc900/SeFilBcf1_OnSideRow3.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBcf1_OnSideRow3_Skip39, SeFilBcf1_OnSideRow3 + 29
	.set	SeFilBcf1_OnSideRow3_Join41, SeFilBcf1_OnSideRow3 + 44
	.set	SeFilBcf1_OnSideRow3_Epilogue34, SeFilBcf1_OnSideRow3 + 48
SeFilBcf1_OnSideRow4:	.include "includes/generated/cc900/SeFilBcf1_OnSideRow4.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBcf1_OnSideRow4_Skip16, SeFilBcf1_OnSideRow4 + 49
	.set	SeFilBcf1_OnSideRow4_Join17, SeFilBcf1_OnSideRow4 + 69
	.set	SeFilBcf1_OnSideRow4_Epilogue12, SeFilBcf1_OnSideRow4 + 73
SeFilBcf1_OnSideRow5:	.include "includes/generated/cc900/SeFilBcf1_OnSideRow5.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBcf1_OnSideRow5_Epilogue13, SeFilBcf1_OnSideRow5 + 41
SeFilBcf1_OnSwitch25:	.include "includes/generated/cc900/SeFilBcf1_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBcf1_OnSwitch25_Epilogue14, SeFilBcf1_OnSwitch25 + 31
SeFilBcf1_OnSwitch15:	.include "includes/generated/cc900/SeFilBcf1_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilBcf1_OnSwitch15_Skip40, SeFilBcf1_OnSwitch15 + 35
	.set	SeFilBcf1_OnSwitch15_Join42, SeFilBcf1_OnSwitch15 + 40
	.set	SeFilBcf1_OnSwitch15_Epilogue35, SeFilBcf1_OnSwitch15 + 44
SeFilFil2_OnColumn3:	.include "includes/generated/cc900/SeFilFil2_OnColumn3.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilFil2_OnColumn3_Skip41, SeFilFil2_OnColumn3 + 105
SeFilFil2_OnColumn4:
	dec	8, xsp
	ld	(xsp+6), a
	lda	xbc, (xsp+2)
	ld	wa, 0:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+6)
	extz	wa
	ld	c, (xsp+2)
	dec	1, c
	extz	bc
	pushw	bc
	ld	bc, 1:i3
	ld	de, 0:i3
	call	SeMenu_StepNoteParamInRange
	cp	l, 1:i3
	jr	nz, SeFilFil2_OnColumn4_Skip42
	lda	xwa, (xsp+4)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 1:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+4)
	extz	wa
	lda	xde, (xsp)
	pushw	127
	ldw	bc, 58
	call	SeMenu_RegisterElement_Extended
	pushw	1
	pushw	54
	call	SeTitle_DrawField
	inc	4, xsp
	ld	wa, 0:i3
	ld	bc, 0:i3
	call	SeMenu_DrawKeyScaleGraph
SeFilFil2_OnColumn4_Skip42:
	ld	wa, 4:i3
	call	SeMenu_BindDialToColumn
	inc	8, xsp
	ret
SeFilFil2_OnColumn5:
	lda	xsp, (xsp-10)
	ld	(xsp+8), a
	lda	xbc, (xsp+4)
	ld	wa, 1:i3
	call	SeMenu_LoadPartParam
	lda	xbc, (xsp+2)
	ld	wa, 2:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+8)
	extz	wa
	ld	e, (xsp+4)
	inc	1, e
	extz	de
	ld	c, (xsp+2)
	dec	1, c
	extz	bc
	pushw	bc
	ld	bc, 0:i3
	call	SeMenu_StepNoteParamInRange
	cp	l, 1:i3
	jr	nz, SeFilFil2_OnColumn5_Skip43
	lda	xwa, (xsp+6)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 0:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+6)
	extz	wa
	lda	xde, (xsp)
	pushw	127
	ldw	bc, 57
	call	SeMenu_RegisterElement_Extended
	pushw	0
	pushw	54
	call	SeTitle_DrawField
	inc	4, xsp
	ld	wa, 0:i3
	ld	bc, 0:i3
	call	SeMenu_DrawKeyScaleGraph
SeFilFil2_OnColumn5_Skip43:
	ld	wa, 5:i3
	call	SeMenu_BindDialToColumn
	lda	xsp, (xsp+10)
	ret
SeFilFil2_OnColumn6:
	dec	8, xsp
	ld	(xsp+6), a
	lda	xbc, (xsp+2)
	ld	wa, 0:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+6)
	extz	wa
	ld	e, (xsp+2)
	inc	1, e
	extz	de
	pushw	127
	ld	bc, 2:i3
	call	SeMenu_StepNoteParamInRange
	cp	l, 1:i3
	jr	nz, SeFilFil2_OnColumn6_Skip44
	lda	xwa, (xsp+4)
	call	SeMenu_ValidatePartNumber
	lda	xbc, (xsp)
	ld	wa, 2:i3
	call	SeMenu_LoadPartParam
	ld	a, (xsp+4)
	extz	wa
	lda	xde, (xsp)
	pushw	127
	ldw	bc, 59
	call	SeMenu_RegisterElement_Extended
	pushw	2
	pushw	54
	call	SeTitle_DrawField
	inc	4, xsp
	ld	wa, 0:i3
	ld	bc, 0:i3
	call	SeMenu_DrawKeyScaleGraph
SeFilFil2_OnColumn6_Skip44:
	ld	wa, 6:i3
	call	SeMenu_BindDialToColumn
	inc	8, xsp
	ret
SeFilFil2_OnSideRow1:	.include "includes/generated/cc900/SeFilFil2_OnSideRow1.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilFil2_OnSideRow2:	.include "includes/generated/cc900/SeFilFil2_OnSideRow2.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilFil2_OnSideRow3:	.include "includes/generated/cc900/SeFilFil2_OnSideRow3.s"	; C: cc900/scoop_editor_data_m0_d.c
; the hand assembly's labels inside the compiled body, by their offsets
	.set	SeFilFil2_OnSideRow3_Skip45, SeFilFil2_OnSideRow3 + 11
	.set	SeFilFil2_OnSideRow3_Join43, SeFilFil2_OnSideRow3 + 26
SeFilFil2_OnSideRow4:	.include "includes/generated/cc900/SeFilFil2_OnSideRow4.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilFil2_OnSideRow5:	.include "includes/generated/cc900/SeFilFil2_OnSideRow5.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilFil2_OnSwitch25:	.include "includes/generated/cc900/SeFilFil2_OnSwitch25.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilFil2_OnSwitch15:	.include "includes/generated/cc900/SeFilFil2_OnSwitch15.s"	; C: cc900/scoop_editor_data_m0_xr_b.c
SeFilEnv1_OnColumn1:
	extz	wa
	ldw	bc, 63
	ld	de, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join8
SeFilEnv1_OnColumn2:
	extz	wa
	ldw	bc, 64
	ld	de, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join9
SeFilEnv1_OnColumn3:
	extz	wa
	ldw	bc, 62
	ldw	de, 65
	jp	SeMenu_ApplyPartEdit_AltStore_Join10
SeFilEnv1_OnColumn4:
	extz	wa
	ldw	bc, 66
	ld	de, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join11
SeFilEnv1_OnColumn5:
	extz	wa
	ldw	bc, 70
	ldw	de, 67
	jp	SeMenu_ApplyPartEdit_AltStore_Join12
SeFilEnv1_OnColumn6:
	extz	wa
	ldw	bc, 68
	ld	de, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join13
SeFilEnv1_OnColumn7:
	extz	wa
	ldw	bc, 61
	ldw	de, 69
	jp	SeMenu_ApplyPartEdit_AltStore_Join14
SeFilEnv1_OnSideRow1:
	cp	a, 0:i3
	ret	z
	call	SeMenu_ToggleSolo
	ret
SeFilEnv1_OnSideRow2:
	cp	a, 0:i3
	jr	nz, SeFilEnv1_OnSideRow2_Skip46
	ldw	wa, TT_SEFILLPQ1
	ld	bc, 0:i3
	jr	SeFilEnv1_OnSideRow2_Join44
SeFilEnv1_OnSideRow2_Skip46:
	ld	wa, 1:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEFILENV1
	ld	bc, 1:i3
SeFilEnv1_OnSideRow2_Join44:
	call	SeMenu_SendEvent
	ret
SeFilEnv1_OnSideRow3:
	cp	a, 0:i3
	jr	nz, SeFilEnv1_OnSideRow3_Skip47
	ldw	wa, TT_SEFILLFO1
	ld	bc, 0:i3
	jr	SeFilEnv1_OnSideRow3_Join45
SeFilEnv1_OnSideRow3_Skip47:
	ld	wa, 2:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEFILENV1
	ld	bc, 1:i3
SeFilEnv1_OnSideRow3_Join45:
	call	SeMenu_SendEvent
	ret
SeFilEnv1_OnSideRow4:
	cp	a, 0:i3
	jr	nz, SeFilEnv1_OnSideRow4_Skip48
	ld	wa, 0:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join7
SeFilEnv1_OnSideRow4_Skip48:
	ld	wa, 3:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEFILENV1
	ld	bc, 1:i3
	call	SeMenu_SendEvent
	ret
SeFilEnv1_OnSideRow5:
	cp	a, 0:i3
	jr	nz, SeFilEnv1_OnSideRow5_Skip49
	ld	wa, 1:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join7
SeFilEnv1_OnSideRow5_Skip49:
	ld	wa, 4:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEFILENV1
	ld	bc, 1:i3
	call	SeMenu_SendEvent
	ret
SeFilEnv1_OnSwitch25:
	cp	a, 0:i3
	ret	nz
	ldw	wa, TT_SEFILENV2
	ld	bc, 0:i3
	call	SeMenu_SendEvent
	ret
SeFilEnv1_OnSwitch15:
	cp	a, 0:i3
	ret	nz
	ld	wa, 0:i3
	call	SeMenu_SetupMenuDisplay
	ldw	wa, TT_SEMENU
	ld	bc, 0:i3
	call	SeMenu_SendEvent
	ret
SeFilEnv2_OnColumn2:
	extz	wa
	ldw	bc, 74
	jp	SeMenu_ApplyPartEdit_AltStore_Join15
SeFilEnv2_OnColumn3:
	extz	wa
	ldw	bc, 75
	jp	SeMenu_ApplyPartEdit_AltStore_Join16
SeFilEnv2_OnColumn4:
	extz	wa
	ldw	bc, 76
	jp	SeMenu_ApplyPartEdit_AltStore_Join17
SeFilEnv2_OnColumn5:
	extz	wa
	ldw	bc, 73
	jp	SeMenu_ApplyPartEdit_AltStore_Join18
SeFilEnv2_OnColumn7:
	extz	wa
	ldw	bc, 71
	jp	SeMenu_ApplyPartEdit_AltStore_Join19
SeFilEnv2_OnColumn8:
	extz	wa
	ldw	bc, 72
	jp	SeMenu_ApplyPartEdit_AltStore_Join20
SeFilEnv2_OnSideRow1:
	cp	a, 0:i3
	ret	z
	call	SeMenu_ToggleSolo
	ret
SeFilEnv2_OnSideRow2:
	cp	a, 0:i3
	jr	nz, SeFilEnv2_OnSideRow2_Skip50
	ldw	wa, TT_SEFILLPQ1
	ld	bc, 0:i3
	jr	SeFilEnv2_OnSideRow2_Join46
SeFilEnv2_OnSideRow2_Skip50:
	ld	wa, 1:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEFILENV2
	ld	bc, 1:i3
SeFilEnv2_OnSideRow2_Join46:
	call	SeMenu_SendEvent
	ret
SeFilEnv2_OnSideRow3:
	cp	a, 0:i3
	jr	nz, SeFilEnv2_OnSideRow3_Skip51
	ldw	wa, TT_SEFILLFO1
	ld	bc, 0:i3
	jr	SeFilEnv2_OnSideRow3_Join47
SeFilEnv2_OnSideRow3_Skip51:
	ld	wa, 2:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEFILENV2
	ld	bc, 1:i3
SeFilEnv2_OnSideRow3_Join47:
	call	SeMenu_SendEvent
	ret
SeFilEnv2_OnSideRow4:
	cp	a, 0:i3
	ret	z
	ld	wa, 3:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEFILENV2
	ld	bc, 1:i3
	call	SeMenu_SendEvent
	ret
SeFilEnv2_OnSideRow5:
	cp	a, 0:i3
	ret	z
	ld	wa, 4:i3
	call	SeMenu_SelectPartIfEnabled
	cp	l, 0:i3
	ret	z
	ldw	wa, TT_SEFILENV2
	ld	bc, 1:i3
	call	SeMenu_SendEvent
	ret
SeFilEnv2_OnSwitch25:
	cp	a, 0:i3
	ret	z
	ldw	wa, TT_SEFILENV1
	ld	bc, 0:i3
	call	SeMenu_SendEvent
	ret
SeFilEnv2_OnSwitch15:
	cp	a, 0:i3
	ret	nz
	ld	wa, 0:i3
	call	SeMenu_SetupMenuDisplay
	ldw	wa, TT_SEMENU
	ld	bc, 0:i3
	call	SeMenu_SendEvent
	ret
SeFilLfo1_OnColumn2:
	extz	wa
	ld	bc, 2:i3
	jp	SeLfo1_StepSelectorAndReload
SeFilLfo1_OnColumn3:
	extz	wa
	ld	bc, 2:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join
SeFilLfo1_OnColumn4:
	extz	wa
	ld	bc, 2:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join2
SeFilLfo1_OnColumn5:
	extz	wa
	ld	bc, 2:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join3
SeFilLfo1_OnColumn6:
	extz	wa
	ld	bc, 2:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join4
SeFilLfo1_OnColumn7:
	extz	wa
	ld	bc, 2:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join5
SeFilLfo1_OnColumn8:
	extz	wa
	ld	bc, 2:i3
	jp	SeMenu_ApplyPartEdit_AltStore_Join6
SeFilLfo1_OnSideRow1:
	cp	a, 0:i3
	jp	nz, (SeMenu_ToggleSolo:24)
	ldw	wa, TT_SEFILENV1
	ld	bc, 0:i3
	jp	SeMenu_SendEvent
SeFilLfo1_OnSideRow2:
	cp	a, 0:i3
	jr	nz, SeFilLfo1_OnSideRow2_Skip52
	ldw	wa, TT_SEFILLPQ1
	ld	bc, 0:i3
	jp	SeMenu_SendEvent
SeFilLfo1_OnSideRow2_Skip52:
	ld	wa, 2:i3
	ld	bc, 1:i3
	jp	SeMenu_CyclePartLfoState
SeFilLfo1_OnSideRow3:
	cp	a, 0:i3
	ret	z
	ld	wa, 2:i3
	ld	bc, 2:i3
	call	SeMenu_CyclePartLfoState
	ret
SeFilLfo1_OnSideRow4:
	cp	a, 0:i3
	ret	z
	ld	wa, 2:i3
	ld	bc, 3:i3
	call	SeMenu_CyclePartLfoState
	ret
SeFilLfo1_OnSideRow5:
	cp	a, 0:i3
	ret	z
	ld	wa, 2:i3
	ld	bc, 4:i3
	call	SeMenu_CyclePartLfoState
	ret
; SeFilLfo1_OnSwitch15: LFO 1 (filter) page, switch 15 (SeFilLfo1TitleFunc_SwitchHandlers[15]): when A == 0,
;   SeMenu_SetupMenuDisplay(0) then SeMenu_SendEvent(WA = 32, C = 0), a mode change to screen 32; same body as
;   SeFilEnv1_OnSwitch15 / SeFilEnv2_OnSwitch15 / SeFilFil2_OnSwitch15
SeFilLfo1_OnSwitch15:
	cp	a, 0:i3
	ret	nz
	ld	wa, 0:i3
	call	SeMenu_SetupMenuDisplay
	ldw	wa, TT_SEMENU
	ld	bc, 0:i3
	call	SeMenu_SendEvent
	ret


; --- Sound Editor ---
