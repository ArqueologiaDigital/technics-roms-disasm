; Evidence: one `ret` at the head of a run of `0E 00 00 00` four-byte slots --
;           the fill convention of 0xF55000 and of the thunk table itself.  Named by directory slot T_F42E40, the ONLY reference to 0x00F53000 in either image (1 occurrence in prom_b, 0 in prom_a).  [round7-entrypoints]
RetStub_F53000:
	ret	; F53000  ret
	nop	; F53001  nop
	nop	; F53002  nop
	nop	; F53003  nop
	ret	; F53004  ret
	nop	; F53005  nop
	nop	; F53006  nop
	nop	; F53007  nop
	ret	; F53008  ret
	nop	; F53009  nop
	nop	; F5300A  nop
	nop	; F5300B  nop
	jr	RetStub_F53000_Join	; F5300C  jr T,0xf53016
	ret	; F5300E  ret
	nop	; F5300F  nop
	nop	; F53010  nop
	nop	; F53011  nop
	ret	; F53012  ret
	nop	; F53013  nop
	nop	; F53014  nop
	nop	; F53015  nop
RetStub_F53000_Join:
	calr	RetStub_F53000_Nop	; F53016  calr 0xf541fe
	ret	; F53019  ret

; --------------------------------------------------------------------------
; T_F42E58_Nop
; Called from: thunk slot T_F42E58; thunk slot T_F42E5C
; Evidence: 0xF5301A is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F42E58_Nop after what reaches it
;          (was sub_F5301A; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F42E58_Nop:		; <- T_F42E58, T_F42E5C
	ret	; F5301A  ret
	set	1, (0x2134:16)	; F5301B  set 1,(0x2134)
	ret	; F5301F  ret
	set	1, (0x2134:16)	; F53020  set 1,(0x2134)
	ret	; F53024  ret

; --------------------------------------------------------------------------
; ScreenEnter_DrawbarScreen
; Called from: thunk slot T_ScreenEnter_DrawbarScreen
; Evidence: 0xF53025 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenEnter_DrawbarScreen: the +0 ENTER method of the screen object for screen id 0xA3 -- PanelScreen_VtableTable entry 0xC3
;   (ViewB entry 0xA3) points at the thunk triple starting at T_ScreenEnter_DrawbarScreen, and slot T_ScreenEnter_DrawbarScreen jumps here.
; ScreenEnter_DrawbarScreen: screen 0xA3's +0 ENTER.  Its vtable (ViewB [0xA3] = T_ScreenEnter_DrawbarScreen) is T_ScreenEnter_DrawbarScreen enter, T_F42E48 leave
;   (a ret) and T_F42E4C = T_DrawbarScreen_Dispatch, the button method -- so 0xA3 is the drawbar screen (2026-10-04).
ScreenEnter_DrawbarScreen:		; <- T_ScreenEnter_DrawbarScreen
	calr	ScreenEnterBody_DrawbarScreen	; F53025  calr 0xf53052
	ret	; F53028  ret

; --------------------------------------------------------------------------
; T_F42E48_Nop
; Called from: thunk slot T_F42E48
; Evidence: 0xF53029 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F42E48_Nop after what reaches it
;          (was sub_F53029; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F42E48_Nop:		; <- T_F42E48
	ret	; F53029  ret

; --------------------------------------------------------------------------
; DrawbarScreen_Dispatch -- the module's message entry
; Called from: T_DrawbarScreen_Dispatch
; What it does: `link XIZ,0 / pushw (XIZ+0x0A) / pushw (XIZ+0x08) / call
;               0xf42c74 / mul A,4 / add XWA,0x00f54248 / ld XBC,(XWA) / jp
;               (XBC)` -- the image-wide message-dispatch idiom, here
;               through PanelButtonTable_DrawbarScreen.
; Evidence: the byte-identical idiom appears at ScreenButtonBody_DspEffect, ScreenButton_CreatorSelectController and
;           0xF1233E in this same file, each with its own table; the only
;           thing this file adds is WHICH table.  The name states the
;           mechanism and the table, not a purpose.
; --------------------------------------------------------------------------
DrawbarScreen_Dispatch:		; <- T_DrawbarScreen_Dispatch
	link XIZ,0x0000	; F5302A  link XIZ,0x0000
	pushw	(xiz+10)	; F5302E  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F53031  pushw (XIZ+0x08)
	call	T_PanelCode_ToSlotAndFlags	; F53034  call 0xf42c74
	mul	a, 4	; F53038  mul A,0x04
	extz	xwa	; F5303B  extz XWA
	add	xwa, PanelButtonTable_DrawbarScreen	; F5303D  add XWA,0x00f54248
	ld	xbc, (xwa)	; F53043  ld XBC,(XWA)
	lda	xiy, (DrawbarScreen_Dispatch_Resume:24)	; F53045  lda XIY,0xf5304d
	push	xiy	; F5304A  push XIY
	jp	(xbc)	; F5304B  jp T,XBC
DrawbarScreen_Dispatch_Resume:
	pop	xbc	; F5304D  pop XBC
	unlk XIZ	; F5304E  unlk XIZ
	ret	; F53050  ret

; --------------------------------------------------------------------------
; T_F42E50_Nop
; Called from: thunk slot T_F42E50
; Evidence: 0xF53051 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F42E50_Nop after what reaches it
;          (was sub_F53051; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F42E50_Nop:		; <- T_F42E50
	ret	; F53051  ret

; --------------------------------------------------------------------------
; ScreenEnterBody_DrawbarScreen
; Called from: call from 0xF53025
; Evidence: 0xF53052 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenEnterBody_DrawbarScreen: the body of ScreenEnter_DrawbarScreen -- resets (0x289C..0x28A2) on a new screen (1s when
;   the previous screen was 0x66, DSP EFFECT), the dial buttons from (0x289E), then posts the drawbar painters.
ScreenEnterBody_DrawbarScreen:
	push	xix	; F53052  push XIX
	lda	xix, (10399:16)	; F53053  lda XIX,0x289f
	ld	(10396:16), 0	; F53057  ld (0x289c),0x00
	ld	c, (UI_ScreenLatch:16)	; F5305C  ld C,(0x207a)
	cp	c, (UI_ScreenLatch_Previous:16)	; F53060  cp C,(0x207b)
	jr	z, ScreenEnterBody_DrawbarScreen_Skip2	; F53064  jr Z,0xf5309b
	ld	(10397:16), 0	; F53066  ld (0x289d),0x00
	cp	(UI_ScreenId_Previous:16), 0x66	; F5306B  cp (0x207d),0x66
	jr	z, ScreenEnterBody_DrawbarScreen_Skip	; F53070  jr Z,0xf5307c
	ld	(xix), 0	; F53072  ld (XIX),0x00
	ld	(10398:16), 0	; F53075  ld (0x289e),0x00
	jr	ScreenEnterBody_DrawbarScreen_Join	; F5307A  jr T,0xf53084
ScreenEnterBody_DrawbarScreen_Skip:
	ld	(xix), 1	; F5307C  ld (XIX),0x01
	ld	(10398:16), 1	; F5307F  ld (0x289e),0x01
ScreenEnterBody_DrawbarScreen_Join:
	ld	(10402:16), 0	; F53084  ld (0x28a2),0x00
	ld	(10401:16), 0	; F53089  ld (0x28a1),0x00
	ld	c, (10415:16)	; F5308E  ld C,(0x28af)
	and	c, 1	; F53092  and C,0x01
	jr	z, ScreenEnterBody_DrawbarScreen_Skip2	; F53095  jr Z,0xf5309b
	res	0, (0x28af:16)	; F53097  res 0,(0x28af)
ScreenEnterBody_DrawbarScreen_Skip2:
	ld	c, (UI_ScreenId:16)	; F5309B  ld C,(0x207c)
	cp	c, (UI_ScreenId_Previous:16)	; F5309F  cp C,(0x207d)
	jr	z, ScreenEnterBody_DrawbarScreen_Skip3	; F530A3  jr Z,0xf530ad
	incm8	1, (xix)	; F530A5  inc 1,(XIX)
	incm8	1, (xix)	; F530A7  inc 1,(XIX)
	inc	1, (10402:16)	; F530A9  inc 1,(0x28a2)
ScreenEnterBody_DrawbarScreen_Skip3:
	ld	c, (xix)	; F530AD  ld C,(XIX)
	cp	(10398:16), c	; F530AF  cp (0x289e),C
	jr	z, ScreenEnterBody_DrawbarScreen_Skip4	; F530B3  jr Z,0xf530c9
	cp	(0x289d:16), 0x00	; F530B5  cp (0x289d),0x00
	jr	z, ScreenEnterBody_DrawbarScreen_Skip4	; F530BA  jr Z,0xf530c9
	ld	c, (UI_ScreenFlags:16)	; F530BC  ld C,(0x2095)
	and	c, 16	; F530C0  and C,0x10
	jr	nz, ScreenEnterBody_DrawbarScreen_Skip4	; F530C3  jr NZ,0xf530c9
	call	T_CallbackQueue_ResetAndRestartTask2	; F530C5  call 0xf42e80
ScreenEnterBody_DrawbarScreen_Skip4:
	cp	(0x289e:16), 0x00	; F530C9  cp (0x289e),0x00
	jr	nz, ScreenEnterBody_DrawbarScreen_Skip5	; F530CE  jr NZ,0xf530d6
	res	0, (UI_RequestBits:16)	; F530D0  res 0,(0x2075)
	jr	ScreenEnterBody_DrawbarScreen_Join2	; F530D4  jr T,0xf530e4
ScreenEnterBody_DrawbarScreen_Skip5:
	set	0, (UI_RequestBits:16)	; F530D6  set 0,(0x2075)
	ld	(PanelDial_DownButton:16), 12	; F530DA  ld (0x209b),0x0c  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
	ld	(PanelDial_UpButton:16), 11	; F530DF  ld (0x209c),0x0b  <- arms prom_a PanelButton_Accept's substitution for panel button code 0x0D (0xF86615); see the 0xF7D2D8 banner
ScreenEnterBody_DrawbarScreen_Join2:
	ld	c, (UI_ScreenFlags:16)	; F530E4  ld C,(0x2095)
	and	c, 16	; F530E8  and C,0x10
	jr	nz, ScreenEnterBody_DrawbarScreen_Skip7	; F530EB  jr NZ,0xf53121
	ld	c, (UI_ScreenId:16)	; F530ED  ld C,(0x207c)
	cp	c, (UI_ScreenId_Previous:16)	; F530F1  cp C,(0x207d)
	jr	z, ScreenEnterBody_DrawbarScreen_Skip6	; F530F5  jr Z,0xf5310e
	call	T_CallbackQueue_ResetAndRestartTask2	; F530F7  call 0xf42e80
	lda	xbc, (Paint_DrawbarScreenTitle:24)	; F530FB  lda XBC,0xf536bc
	push	xbc	; F53100  push XBC
	call	T_CallbackQueue_Post	; F53101  call 0xf42e84
	pushw	1	; F53105  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53108  call 0xf42dc0
	inc	6, xsp	; F5310C  inc 6,XSP
ScreenEnterBody_DrawbarScreen_Skip6:
	lda	xbc, (Paint_DrawbarScreenLayout:24)	; F5310E  lda XBC,0xf53722
	push	xbc	; F53113  push XBC
	call	T_CallbackQueue_Post	; F53114  call 0xf42e84
	pushw	1	; F53118  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F5311B  call 0xf42dc0
	inc	6, xsp	; F5311F  inc 6,XSP
ScreenEnterBody_DrawbarScreen_Skip7:
	lda	xbc, (Paint_DrawbarScreenValues:24)	; F53121  lda XBC,0xf53823
	push	xbc	; F53126  push XBC
	call	T_CallbackQueue_Post	; F53127  call 0xf42e84
	pushw	1	; F5312B  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F5312E  call 0xf42dc0
	inc	6, xsp	; F53132  inc 6,XSP
	pop	xix	; F53134  pop XIX
	ret	; F53135  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_DrawbarScreen -- row 1 of the five key pairs flanking the LCD, on
;           the DrawbarScreen
; Reached by: SW25 "LCD RIGHT 1 (top)" (matrix segment 3 bit 0, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A2
;           {class 0xA9, code 0x08} -> delivered code 0x08; SW73 "LCD LEFT 1
;           (top)" (matrix segment 9 bit 0, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B71F
;           {class 0xA9, code 0x08} -> delivered code 0x88. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 8 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x08 IS code 0x08 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW73 LCD LEFT 1
;           (top) (segment 9 bit 0, fitted); SW81 [no legend: matrix position
;           outside every diode list] (segment 10 bit 0, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW25 is row 1 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
LcdKeyRow1_DrawbarScreen:
	push	xix	; F53136  push XIX
	lda	xix, (PanelEvent_Flags:16)	; F53137  lda XIX,0x28b0
	ld	c, (xix)	; F5313B  ld C,(XIX)
	and	c, 1	; F5313D  and C,0x01
	jr	z, LcdKeyRow1_DrawbarScreen_Skip	; F53140  jr Z,0xf53154
	cp	(PanelModeGroup:16), 0x17	; F53142  cp (0x2076),0x17
	jr	nz, LcdKeyRow1_DrawbarScreen_Epilogue	; F53147  jr NZ,0xf53161
	set	7, (UI_Request_Hi:16)	; F53149  set 7,(0x2071)
	ld	(UI_Request:16), 158	; F5314D  ld (0x2070),0x9e
	jr	LcdKeyRow1_DrawbarScreen_Epilogue	; F53152  jr T,0xf53161
LcdKeyRow1_DrawbarScreen_Skip:
	cp	(0x289e:16), 0x00	; F53154  cp (0x289e),0x00
	jr	nz, LcdKeyRow1_DrawbarScreen_Epilogue	; F53159  jr NZ,0xf53161
	and	(xix), 0xfe	; F5315B  and (XIX),0xfe
	calr	DrawbarScreen_ToggleRowFlag	; F5315E  calr 0xf5323e
LcdKeyRow1_DrawbarScreen_Epilogue:
	pop	xix	; F53161  pop XIX
	ret	; F53162  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_DrawbarScreen -- row 2 of the five key pairs flanking the LCD, on
;           the DrawbarScreen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 9 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x09 IS code 0x09 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW74 LCD LEFT 2
;           (segment 9 bit 1, fitted); SW82 [no legend: matrix position
;           outside every diode list] (segment 10 bit 1, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
LcdKeyRow2_DrawbarScreen:
	push	xix	; F53163  push XIX
	lda	xix, (PanelEvent_Flags:16)	; F53164  lda XIX,0x28b0
	ld	c, (xix)	; F53168  ld C,(XIX)
	and	c, 1	; F5316A  and C,0x01
	jr	z, LcdKeyRow2_DrawbarScreen_Skip	; F5316D  jr Z,0xf53174
	calr	DrawbarScreen_LcdKeyRow2	; F5316F  calr 0xf5321f
	jr	LcdKeyRow2_DrawbarScreen_Epilogue	; F53172  jr T,0xf5318c
LcdKeyRow2_DrawbarScreen_Skip:
	cp	(0x289e:16), 0x00	; F53174  cp (0x289e),0x00
	jr	nz, LcdKeyRow2_DrawbarScreen_Skip2	; F53179  jr NZ,0xf53183
	or	(xix), 0x01	; F5317B  or (XIX),0x01
	calr	DrawbarScreen_ToggleRowFlag	; F5317E  calr 0xf5323e
	jr	LcdKeyRow2_DrawbarScreen_Epilogue	; F53181  jr T,0xf5318c
LcdKeyRow2_DrawbarScreen_Skip2:
	set	7, (UI_Request_Hi:16)	; F53183  set 7,(0x2071)
	ld	(UI_Request:16), 102	; F53187  ld (0x2070),0x66
LcdKeyRow2_DrawbarScreen_Epilogue:
	pop	xix	; F5318C  pop XIX
	ret	; F5318D  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_DrawbarScreen -- row 4 of the five key pairs flanking the LCD, on
;           the DrawbarScreen
; Reached by: SW28 "LCD RIGHT 4" (matrix segment 3 bit 3, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6AE
;           {class 0xA9, code 0x0B} -> delivered code 0x0B; SW76 "LCD LEFT 4"
;           (matrix segment 9 bit 3, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72B
;           {class 0xA9, code 0x0B} -> delivered code 0x8B. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 11 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x0B IS code 0x0B here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW76 LCD LEFT 4
;           (segment 9 bit 3, fitted); SW84 [no legend: matrix position
;           outside every diode list] (segment 10 bit 3, NOT fitted on this
;           panel). The model strap is the RAM byte (0x00C4), latched from PB
;           bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2 is the
;           SX-WSA1R (notes/wave7_panel_names_round11.py --variant, three
;           independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE and a ROM
;           anchor: page I-4/I-5 draws a COLUMN OF FIVE keys down each side of
;           the display, and rows 1-4 are graded LOCKED in
;           notes/wave7_panel_button_codes.py --physical because prom_a
;           SineWaveCheck_ServiceSwitches masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW28 is row 4 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
LcdKeyRow4_DrawbarScreen:
	push	xix	; F5318E  push XIX
	lda	xix, (PanelEvent_Flags:16)	; F5318F  lda XIX,0x28b0
	cp	(0x289e:16), 0x01	; F53193  cp (0x289e),0x01
	jr	nz, LcdKeyRow4_DrawbarScreen_Epilogue	; F53198  jr NZ,0xf531b3
	ld	c, (xix)	; F5319A  ld C,(XIX)
	and	c, 1	; F5319C  and C,0x01
	jr	z, LcdKeyRow4_DrawbarScreen_Skip	; F5319F  jr Z,0xf531a9
	and	(xix), 0xfe	; F531A1  and (XIX),0xfe
	calr	DrawbarSettingPage_StepCursorRow	; F531A4  calr 0xf531f5
	jr	LcdKeyRow4_DrawbarScreen_Epilogue	; F531A7  jr T,0xf531b3
LcdKeyRow4_DrawbarScreen_Skip:
	set	0, (UI_RequestBits:16)	; F531A9  set 0,(0x2075)
	and	(xix), 0xfe	; F531AD  and (XIX),0xfe
	calr	DrawbarScreen_StepParamAtCursor	; F531B0  calr 0xf531dc
LcdKeyRow4_DrawbarScreen_Epilogue:
	pop	xix	; F531B3  pop XIX
	ret	; F531B4  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_DrawbarScreen -- row 5 of the five key pairs flanking the LCD, on
;           the DrawbarScreen
; Reached by: SW29 "LCD RIGHT 5 (bottom)" (matrix segment 3 bit 4, wire 0xC3)
;           -> PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record
;           0xF8B6B2 {class 0xA9, code 0x0C} -> delivered code 0x0C; SW77 "LCD
;           LEFT 5 (bottom)" (matrix segment 9 bit 4, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B72F
;           {class 0xA9, code 0x0C} -> delivered code 0x8C. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 12 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x0C IS code 0x0C here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW77 LCD LEFT 5
;           (bottom) (segment 9 bit 4, fitted); SW85 [no legend: matrix
;           position outside every diode list] (segment 10 bit 4, NOT fitted
;           on this panel). The model strap is the RAM byte (0x00C4), latched
;           from PB bit 0 by prom_a Variant_SetFromPB0 at 0xF82882; variant 2
;           is the SX-WSA1R (notes/wave7_panel_names_round11.py --variant,
;           three independent measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: page
;           I-4/I-5 draws a COLUMN OF FIVE keys down each side of the display
;           and SW29 is the bottom one. ⚠ GRADE POSITION in
;           notes/wave7_panel_button_codes.py --physical -- row 5 is the one
;           row of the column the Outsel check does NOT annotate, so unlike
;           rows 1-4 it rests on the silkscreen position alone. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
LcdKeyRow5_DrawbarScreen:
	push	xix	; F531B5  push XIX
	lda	xix, (PanelEvent_Flags:16)	; F531B6  lda XIX,0x28b0
	cp	(0x289e:16), 0x01	; F531BA  cp (0x289e),0x01
	jr	nz, LcdKeyRow5_DrawbarScreen_Epilogue	; F531BF  jr NZ,0xf531da
	ld	c, (xix)	; F531C1  ld C,(XIX)
	and	c, 1	; F531C3  and C,0x01
	jr	z, LcdKeyRow5_DrawbarScreen_Skip	; F531C6  jr Z,0xf531d0
	or	(xix), 0x01	; F531C8  or (XIX),0x01
	calr	DrawbarSettingPage_StepCursorRow	; F531CB  calr 0xf531f5
	jr	LcdKeyRow5_DrawbarScreen_Epilogue	; F531CE  jr T,0xf531da
LcdKeyRow5_DrawbarScreen_Skip:
	set	0, (UI_RequestBits:16)	; F531D0  set 0,(0x2075)
	or	(xix), 0x01	; F531D4  or (XIX),0x01
	calr	DrawbarScreen_StepParamAtCursor	; F531D7  calr 0xf531dc
LcdKeyRow5_DrawbarScreen_Epilogue:
	pop	xix	; F531DA  pop XIX
	ret	; F531DB  ret

; --------------------------------------------------------------------------
; DrawbarScreen_StepParamAtCursor
; Called from: call from 0xF531B0, 0xF531D7
; Evidence: 0xF531DC is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; DrawbarScreen_StepParamAtCursor: Runs DrawbarSettingPage_RowStepHandlers[(0x28A1)], the drawbar parameter page's cursor (0..3,
;   moved by DrawbarSettingPage_StepCursorRow, drawn by DL_ParamCursorBar): each entry steps one signed nibble of (0x2890)/(0x2891) by +-1
;   within -5..+5 per PanelEvent_Flags bit 0 and repaints. LcdKeyRow4/5_DrawbarScreen call it on that page ((0x289E) =
;   1). Basis: callers + body + table. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
DrawbarScreen_StepParamAtCursor:
	ld	c, 4:opc	; F531DC  ld C,0x04
	mul	bc, (0x28a1:16)	; F531DE  mul BC,(0x28a1)
	extz	xbc	; F531E2  extz XBC
	add	xbc, DrawbarSettingPage_RowStepHandlers	; F531E4  add XBC,0x00f542d1
	ld	xbc, (xbc)	; F531EA  ld XBC,(XBC)
	lda	xiy, (DrawbarScreen_StepParamAtCursor_Resume:24)	; F531EC  lda XIY,0xf531f4
	push	xiy	; F531F1  push XIY
	jp	(xbc)	; F531F2  jp T,XBC
DrawbarScreen_StepParamAtCursor_Resume:
	ret	; F531F4  ret

; --------------------------------------------------------------------------
; DrawbarSettingPage_StepCursorRow
; Called from: call from 0xF531A4, 0xF531CB
; Evidence: 0xF531F5 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; DrawbarSettingPage_StepCursorRow: Steps the parameter-row cursor (0x28A1) within 0..3 -- down when PanelEvent_Flags
;   bit 0 is set, up when clear -- and requests a repaint when it moved. LCD rows 5 / 4 of the DRAWBAR screen call it
;   on the setting page ((0x289E) = 1); the painter turns (0x28A1) into the DL_ParamCursorBar band. Basis: callers +
;   body. (notes/naming-pilot-2026-10-06/proposals_wave2_c.json)
DrawbarSettingPage_StepCursorRow:
	push	xix	; F531F5  push XIX
	lda	xix, (10401:16)	; F531F6  lda XIX,0x28a1
	ld	c, (PanelEvent_Flags:16)	; F531FA  ld C,(0x28b0)
	and	c, 1	; F531FE  and C,0x01
	jr	z, DrawbarSettingPage_StepCursorRow_Skip	; F53201  jr Z,0xf5320d
	ld	c, (xix)	; F53203  ld C,(XIX)
	cp	c, 3:i3	; F53205  cp C,3
	jr	nc, DrawbarSettingPage_StepCursorRow_Epilogue	; F53207  jr NC,0xf5321d
	incm8	1, (xix)	; F53209  inc 1,(XIX)
	jr	DrawbarSettingPage_StepCursorRow_Join	; F5320B  jr T,0xf53215
DrawbarSettingPage_StepCursorRow_Skip:
	ld	c, (xix)	; F5320D  ld C,(XIX)
	cp	c, 0:i3	; F5320F  cp C,0
	jr	z, DrawbarSettingPage_StepCursorRow_Epilogue	; F53211  jr Z,0xf5321d
	decm8	1, (xix)	; F53213  dec 1,(XIX)
DrawbarSettingPage_StepCursorRow_Join:
	set	3, (UI_RequestBits:16)	; F53215  set 3,(0x2075)
	set	4, (UI_Request_Hi:16)	; F53219  set 4,(0x2071)
DrawbarSettingPage_StepCursorRow_Epilogue:
	pop	xix	; F5321D  pop XIX
	ret	; F5321E  ret

; --------------------------------------------------------------------------
; DrawbarScreen_LcdKeyRow2
; Called from: call from 0xF5316F
; Evidence: 0xF5321F is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; DrawbarScreen_LcdKeyRow2: the LcdKeyRow2 action of DrawbarScreen -- called only by LcdKeyRow2_DrawbarScreen.
DrawbarScreen_LcdKeyRow2:
	push	xix	; F5321F  push XIX
	lda	xix, (10398:16)	; F53220  lda XIX,0x289e
	ld	c, (xix)	; F53224  ld C,(XIX)
	cp	c, 0:i3	; F53226  cp C,0
	jr	nz, DrawbarScreen_LcdKeyRow2_Skip	; F53228  jr NZ,0xf5322f
	ld	(xix), 1	; F5322A  ld (XIX),0x01
	jr	DrawbarScreen_LcdKeyRow2_Join	; F5322D  jr T,0xf53232
DrawbarScreen_LcdKeyRow2_Skip:
	ld	(xix), 0	; F5322F  ld (XIX),0x00
DrawbarScreen_LcdKeyRow2_Join:
	set	4, (UI_Request_Hi:16)	; F53232  set 4,(0x2071)
	ld	(10399:16), 2	; F53236  ld (0x289f),0x02
	pop	xix	; F5323B  pop XIX
	ret	; F5323C  ret
	ret	; F5323D  ret

; --------------------------------------------------------------------------
; DrawbarScreen_ToggleRowFlag
; Called from: call from 0xF5315E, 0xF5317E
; Evidence: 0xF5323E is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; DrawbarScreen_ToggleRowFlag: DRAWBAR screen: toggles (0x2896) bit 5 (PanelEvent_Flags bit 0 clear, LCD key row 1) or
;   bit 4 (set, row 2), sends the drawbar bytes from 0x2890 with (0x2896) as parameter 8 to CPU 2 (Drawbar_SendSettingBytes, 0x88
;   link messages, arg (0x289C)), and sets UI_ScreenFlags bit 4 to repaint; the painter draws one of two 48x20 icons
;   beside row 1 / row 2 from these bits. Basis: callers + body + painter. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
DrawbarScreen_ToggleRowFlag:
	push	xix	; F5323E  push XIX
	lda	xix, (10390:16)	; F5323F  lda XIX,0x2896
	ld	c, (PanelEvent_Flags:16)	; F53243  ld C,(0x28b0)
	and	c, 1	; F53247  and C,0x01
	jr	z, DrawbarScreen_ToggleRowFlag_Skip	; F5324A  jr Z,0xf53251
	xor	(xix), 0x10	; F5324C  xor (XIX),0x10
	jr	DrawbarScreen_ToggleRowFlag_Join	; F5324F  jr T,0xf53254
DrawbarScreen_ToggleRowFlag_Skip:
	xor	(xix), 0x20	; F53251  xor (XIX),0x20
DrawbarScreen_ToggleRowFlag_Join:
	push	0	; F53254  push 0x00
	push	(0x289c:16)	; F53256  push (0x289c)
	calr	Drawbar_SendSettingBytes	; F5325A  calr 0xf5418e
	set	4, (UI_ScreenFlags:16)	; F5325D  set 4,(0x2095)
	popw	bc	; F53261  pop BC
	pop	xix	; F53262  pop XIX
	ret	; F53263  ret

; --------------------------------------------------------------------------
; DrawbarSettingPage_StepAttackTime
; Called from: DrawbarSettingPage_RowStepHandlers[2]
; Evidence: 0xF53264 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; DrawbarSettingPage_StepAttackTime: DrawbarSettingPage_RowStepHandlers[2] (DRAWBAR ATTACK TIME): steps (0x2891) high
;   nibble by -1/+1 per PanelEvent_Flags bit 0 within -5..+5, then Drawbar_SendSettingBytes and a repaint. Basis:
;   table index + body + the value DL_DrawbarParamValues prints on that row. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
DrawbarSettingPage_StepAttackTime:
	push	xix	; F53264  push XIX
	lda	xix, (10385:16)	; F53265  lda XIX,0x2891
	ld	c, (PanelEvent_Flags:16)	; F53269  ld C,(0x28b0)
	and	c, 1	; F5326D  and C,0x01
	jr	z, DrawbarSettingPage_StepAttackTime_Skip2	; F53270  jr Z,0xf53290
	ld	c, (xix)	; F53272  ld C,(XIX)
	sra	c, 4	; F53274  sra 0x04,C
	cp	c, 251	; F53277  cp C,0xfb
	jr	le, DrawbarSettingPage_StepAttackTime_Epilogue	; F5327A  jr LE,0xf532bd
	ld	c, (xix)	; F5327C  ld C,(XIX)
	sra	c, 4	; F5327E  sra 0x04,C
	dec	1, c	; F53281  dec 1,C
	sll	c, 4	; F53283  sll 0x04,C
	and	c, 240	; F53286  and C,0xf0
	and	(xix), 0x0f	; F53289  and (XIX),0x0f
	or	(xix), c	; F5328C  or (XIX),C
	jr	DrawbarSettingPage_StepAttackTime_Join2	; F5328E  jr T,0xf532ab
DrawbarSettingPage_StepAttackTime_Skip2:
	ld	c, (xix)	; F53290  ld C,(XIX)
	sra	c, 4	; F53292  sra 0x04,C
	cp	c, 5:i3	; F53295  cp C,5
	jr	ge, DrawbarSettingPage_StepAttackTime_Epilogue	; F53297  jr GE,0xf532bd
	ld	c, (xix)	; F53299  ld C,(XIX)
	sra	c, 4	; F5329B  sra 0x04,C
	inc	1, c	; F5329E  inc 1,C
	sll	c, 4	; F532A0  sll 0x04,C
	and	c, 240	; F532A3  and C,0xf0
	and	(xix), 0x0f	; F532A6  and (XIX),0x0f
	or	(xix), c	; F532A9  or (XIX),C
DrawbarSettingPage_StepAttackTime_Join2:
	set	3, (UI_RequestBits:16)	; F532AB  set 3,(0x2075)
	push	0	; F532AF  push 0x00
	push	(0x289c:16)	; F532B1  push (0x289c)
	calr	Drawbar_SendSettingBytes	; F532B5  calr 0xf5418e
	set	4, (UI_ScreenFlags:16)	; F532B8  set 4,(0x2095)
	popw	bc	; F532BC  pop BC
DrawbarSettingPage_StepAttackTime_Epilogue:
	pop	xix	; F532BD  pop XIX
	ret	; F532BE  ret

; --------------------------------------------------------------------------
; DrawbarSettingPage_StepReleaseTime
; Called from: DrawbarSettingPage_RowStepHandlers[3]
; Evidence: 0xF532BF is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; DrawbarSettingPage_StepReleaseTime: DrawbarSettingPage_RowStepHandlers[3] (DRAWBAR RELEASE TIME): steps (0x2891) low
;   nibble by -1/+1 per PanelEvent_Flags bit 0 within -5..+5, then Drawbar_SendSettingBytes and a repaint. Basis:
;   table index + body + the value DL_DrawbarParamValues prints on that row. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
DrawbarSettingPage_StepReleaseTime:
	push	xix	; F532BF  push XIX
	lda	xix, (10385:16)	; F532C0  lda XIX,0x2891
	ld	c, (PanelEvent_Flags:16)	; F532C4  ld C,(0x28b0)
	and	c, 1	; F532C8  and C,0x01
	jr	z, DrawbarSettingPage_StepReleaseTime_Skip3	; F532CB  jr Z,0xf532ee
	ld	c, (xix)	; F532CD  ld C,(XIX)
	sll	c, 4	; F532CF  sll 0x04,C
	sra	c, 4	; F532D2  sra 0x04,C
	cp	c, 251	; F532D5  cp C,0xfb
	jr	le, DrawbarSettingPage_StepReleaseTime_Epilogue2	; F532D8  jr LE,0xf5331e
	ld	c, (xix)	; F532DA  ld C,(XIX)
	sll	c, 4	; F532DC  sll 0x04,C
	sra	c, 4	; F532DF  sra 0x04,C
	dec	1, c	; F532E2  dec 1,C
	and	c, 15	; F532E4  and C,0x0f
	and	(xix), 0xf0	; F532E7  and (XIX),0xf0
	or	(xix), c	; F532EA  or (XIX),C
	jr	DrawbarSettingPage_StepReleaseTime_Join3	; F532EC  jr T,0xf5330c
DrawbarSettingPage_StepReleaseTime_Skip3:
	ld	c, (xix)	; F532EE  ld C,(XIX)
	sll	c, 4	; F532F0  sll 0x04,C
	sra	c, 4	; F532F3  sra 0x04,C
	cp	c, 5:i3	; F532F6  cp C,5
	jr	ge, DrawbarSettingPage_StepReleaseTime_Epilogue2	; F532F8  jr GE,0xf5331e
	ld	c, (xix)	; F532FA  ld C,(XIX)
	sll	c, 4	; F532FC  sll 0x04,C
	sra	c, 4	; F532FF  sra 0x04,C
	inc	1, c	; F53302  inc 1,C
	and	c, 15	; F53304  and C,0x0f
	and	(xix), 0xf0	; F53307  and (XIX),0xf0
	or	(xix), c	; F5330A  or (XIX),C
DrawbarSettingPage_StepReleaseTime_Join3:
	set	3, (UI_RequestBits:16)	; F5330C  set 3,(0x2075)
	push	0	; F53310  push 0x00
	push	(0x289c:16)	; F53312  push (0x289c)
	calr	Drawbar_SendSettingBytes	; F53316  calr 0xf5418e
	set	4, (UI_ScreenFlags:16)	; F53319  set 4,(0x2095)
	popw	bc	; F5331D  pop BC
DrawbarSettingPage_StepReleaseTime_Epilogue2:
	pop	xix	; F5331E  pop XIX
	ret	; F5331F  ret

; --------------------------------------------------------------------------
; DrawbarSettingPage_StepPercussiveToneDecay
; Called from: DrawbarSettingPage_RowStepHandlers[0]
; Evidence: 0xF53320 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; DrawbarSettingPage_StepPercussiveToneDecay: DrawbarSettingPage_RowStepHandlers[0] (PERCUSSIVE TONE DECAY): steps
;   (0x2890) low nibble by -1/+1 per PanelEvent_Flags bit 0 within -5..+5, then Drawbar_SendSettingBytes and a
;   repaint. Basis: table index + body + the value DL_DrawbarParamValues prints on that row. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
DrawbarSettingPage_StepPercussiveToneDecay:
	push	xix	; F53320  push XIX
	lda	xix, (10384:16)	; F53321  lda XIX,0x2890
	ld	c, (PanelEvent_Flags:16)	; F53325  ld C,(0x28b0)
	and	c, 1	; F53329  and C,0x01
	jr	z, DrawbarSettingPage_StepPercussiveToneDecay_Skip4	; F5332C  jr Z,0xf5334f
	ld	c, (xix)	; F5332E  ld C,(XIX)
	sll	c, 4	; F53330  sll 0x04,C
	sra	c, 4	; F53333  sra 0x04,C
	cp	c, 251	; F53336  cp C,0xfb
	jr	le, DrawbarSettingPage_StepPercussiveToneDecay_Epilogue3	; F53339  jr LE,0xf5337f
	ld	c, (xix)	; F5333B  ld C,(XIX)
	sll	c, 4	; F5333D  sll 0x04,C
	sra	c, 4	; F53340  sra 0x04,C
	dec	1, c	; F53343  dec 1,C
	and	c, 15	; F53345  and C,0x0f
	and	(xix), 0xf0	; F53348  and (XIX),0xf0
	or	(xix), c	; F5334B  or (XIX),C
	jr	DrawbarSettingPage_StepPercussiveToneDecay_Join4	; F5334D  jr T,0xf5336d
DrawbarSettingPage_StepPercussiveToneDecay_Skip4:
	ld	c, (xix)	; F5334F  ld C,(XIX)
	sll	c, 4	; F53351  sll 0x04,C
	sra	c, 4	; F53354  sra 0x04,C
	cp	c, 5:i3	; F53357  cp C,5
	jr	ge, DrawbarSettingPage_StepPercussiveToneDecay_Epilogue3	; F53359  jr GE,0xf5337f
	ld	c, (xix)	; F5335B  ld C,(XIX)
	sll	c, 4	; F5335D  sll 0x04,C
	sra	c, 4	; F53360  sra 0x04,C
	inc	1, c	; F53363  inc 1,C
	and	c, 15	; F53365  and C,0x0f
	and	(xix), 0xf0	; F53368  and (XIX),0xf0
	or	(xix), c	; F5336B  or (XIX),C
DrawbarSettingPage_StepPercussiveToneDecay_Join4:
	set	3, (UI_RequestBits:16)	; F5336D  set 3,(0x2075)
	push	0	; F53371  push 0x00
	push	(0x289c:16)	; F53373  push (0x289c)
	calr	Drawbar_SendSettingBytes	; F53377  calr 0xf5418e
	set	4, (UI_ScreenFlags:16)	; F5337A  set 4,(0x2095)
	popw	bc	; F5337E  pop BC
DrawbarSettingPage_StepPercussiveToneDecay_Epilogue3:
	pop	xix	; F5337F  pop XIX
	ret	; F53380  ret

; --------------------------------------------------------------------------
; DrawbarSettingPage_StepPercussiveToneLevel
; Called from: DrawbarSettingPage_RowStepHandlers[1]
; Evidence: 0xF53381 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; DrawbarSettingPage_StepPercussiveToneLevel: DrawbarSettingPage_RowStepHandlers[1] (PERCUSSIVE TONE LEVEL): steps
;   (0x2890) high nibble by -1/+1 per PanelEvent_Flags bit 0 within -5..+5, then Drawbar_SendSettingBytes and a
;   repaint. Basis: table index + body + the value DL_DrawbarParamValues prints on that row. (notes/naming-
;   pilot-2026-10-06/proposals_wave11_t11.json)
DrawbarSettingPage_StepPercussiveToneLevel:
	push	xix	; F53381  push XIX
	lda	xix, (10384:16)	; F53382  lda XIX,0x2890
	ld	c, (PanelEvent_Flags:16)	; F53386  ld C,(0x28b0)
	and	c, 1	; F5338A  and C,0x01
	jr	z, DrawbarSettingPage_StepPercussiveToneLevel_Skip5	; F5338D  jr Z,0xf533ad
	ld	c, (xix)	; F5338F  ld C,(XIX)
	sra	c, 4	; F53391  sra 0x04,C
	cp	c, 251	; F53394  cp C,0xfb
	jr	le, DrawbarSettingPage_StepPercussiveToneLevel_Epilogue4	; F53397  jr LE,0xf533da
	ld	c, (xix)	; F53399  ld C,(XIX)
	sra	c, 4	; F5339B  sra 0x04,C
	dec	1, c	; F5339E  dec 1,C
	sll	c, 4	; F533A0  sll 0x04,C
	and	c, 240	; F533A3  and C,0xf0
	and	(xix), 0x0f	; F533A6  and (XIX),0x0f
	or	(xix), c	; F533A9  or (XIX),C
	jr	DrawbarSettingPage_StepPercussiveToneLevel_Join5	; F533AB  jr T,0xf533c8
DrawbarSettingPage_StepPercussiveToneLevel_Skip5:
	ld	c, (xix)	; F533AD  ld C,(XIX)
	sra	c, 4	; F533AF  sra 0x04,C
	cp	c, 5:i3	; F533B2  cp C,5
	jr	ge, DrawbarSettingPage_StepPercussiveToneLevel_Epilogue4	; F533B4  jr GE,0xf533da
	ld	c, (xix)	; F533B6  ld C,(XIX)
	sra	c, 4	; F533B8  sra 0x04,C
	inc	1, c	; F533BB  inc 1,C
	sll	c, 4	; F533BD  sll 0x04,C
	and	c, 240	; F533C0  and C,0xf0
	and	(xix), 0x0f	; F533C3  and (XIX),0x0f
	or	(xix), c	; F533C6  or (XIX),C
DrawbarSettingPage_StepPercussiveToneLevel_Join5:
	set	3, (UI_RequestBits:16)	; F533C8  set 3,(0x2075)
	push	0	; F533CC  push 0x00
	push	(0x289c:16)	; F533CE  push (0x289c)
	calr	Drawbar_SendSettingBytes	; F533D2  calr 0xf5418e
	set	4, (UI_ScreenFlags:16)	; F533D5  set 4,(0x2095)
	popw	bc	; F533D9  pop BC
DrawbarSettingPage_StepPercussiveToneLevel_Epilogue4:
	pop	xix	; F533DA  pop XIX
	ret	; F533DB  ret

; --------------------------------------------------------------------------
; Drawbar_StepLevel
; Called from: call from 0xF53419, 0xF5345B, 0xF534A0, 0xF534EB, 0xF53533,
;              0xF53578, +3 more
; Evidence: 0xF533DC is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_StepLevel: Returns A = the drawbar level argument (0..8) stepped +1 when PanelEvent_Flags bit 0 is set, else
;   -1, clamped to 0..8, and sets UI_RequestBits bit 3 when it moved; returns it unchanged while (0x289E) != 0. The
;   nine DRAWBAR screen keys pass their drawbar's nibble and write the result back. Basis: callers + body.
;   (wsa1/notes/naming-pilot-2026-10-06/proposals_prom_b.json)
Drawbar_StepLevel:
	link XIZ,0x0000	; F533DC  link XIZ,0x0000
	pushw	hl	; F533E0  push HL
	ld	h, (xiz+8)	; F533E1  ld H,(XIZ+0x08)
	cp	(0x289e:16), 0x00	; F533E4  cp (0x289e),0x00
	jr	nz, Drawbar_StepLevel_Skip2	; F533E9  jr NZ,0xf53407
	ld	c, (PanelEvent_Flags:16)	; F533EB  ld C,(0x28b0)
	and	c, 1	; F533EF  and C,0x01
	jr	z, Drawbar_StepLevel_Skip	; F533F2  jr Z,0xf533fd
	cp	h, 8	; F533F4  cp H,0x08
	jr	nc, Drawbar_StepLevel_Skip2	; F533F7  jr NC,0xf53407
	inc	1, h	; F533F9  inc 1,H
	jr	Drawbar_StepLevel_Join	; F533FB  jr T,0xf53403
Drawbar_StepLevel_Skip:
	cp	h, 0:i3	; F533FD  cp H,0
	jr	z, Drawbar_StepLevel_Skip2	; F533FF  jr Z,0xf53407
	dec	1, h	; F53401  dec 1,H
Drawbar_StepLevel_Join:
	set	3, (UI_RequestBits:16)	; F53403  set 3,(0x2075)
Drawbar_StepLevel_Skip2:
	ld	a, h	; F53407  ld A,H
	popw	hl	; F53409  pop HL
	unlk XIZ	; F5340A  unlk XIZ
	ret	; F5340C  ret

; --------------------------------------------------------------------------
; SoftKeyCol1_DrawbarScreen -- the 1st of the eight SOFT KEYS in the row under
;           the LCD, on the DrawbarScreen
; Reached by: SW33 "SOFT KEY col 1 lower" (matrix segment 4 bit 0, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6C3 {class 0xA9, code 0x00} -> delivered code 0x80; SW34
;           "SOFT KEY col 1 upper" (matrix segment 4 bit 1, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6C7
;           {class 0xA9, code 0x00} -> delivered code 0x00. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 0 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x00 IS code 0x00 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW41 SOFT KEY col
;           5 lower (segment 5 bit 0, fitted); SW42 SOFT KEY col 5 upper
;           (segment 5 bit 1, fitted); SW49 [no legend: matrix position
;           outside every diode list] (segment 6 bit 0, NOT fitted on this
;           panel); SW50 [no legend: matrix position outside every diode list]
;           (segment 6 bit 1, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW33/SW34 are the two switches of its 1st column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW33, so "col 1" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
SoftKeyCol1_DrawbarScreen:
	pushw	hl	; F5340D  push HL
	push	xix	; F5340E  push XIX
	lda	xix, (10386:16)	; F5340F  lda XIX,0x2892
	ld	c, (xix)	; F53413  ld C,(XIX)
	and	c, 15	; F53415  and C,0x0f
	pushw	bc	; F53418  push BC
	calr	Drawbar_StepLevel	; F53419  calr 0xf533dc
	ld	h, a	; F5341C  ld H,A
	ld	c, (xix)	; F5341E  ld C,(XIX)
	and	c, 15	; F53420  and C,0x0f
	popw	iy	; F53423  pop IY
	cp	a, c	; F53424  cp A,C
	jr	z, SoftKeyCol1_DrawbarScreen_Epilogue	; F53426  jr Z,0xf5344c
	and	a, 15	; F53428  and A,0x0f
	and	(xix), 0xf0	; F5342B  and (XIX),0xf0
	or	(xix), a	; F5342E  or (XIX),A
	push	0	; F53430  push 0x00
	push	(0x289c:16)	; F53432  push (0x289c)
	calr	Drawbar_SendPartParams	; F53436  calr 0xf540f3
	lda	xbc, (Drawbar1_16ft_Update:24)	; F53439  lda XBC,0xf5394c
	push	xbc	; F5343E  push XBC
	call	T_CallbackQueue_Post	; F5343F  call 0xf42e84
	pushw	1	; F53443  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53446  call 0xf42dc0
	inc	8, xsp	; F5344A  inc 0,XSP
SoftKeyCol1_DrawbarScreen_Epilogue:
	pop	xix	; F5344C  pop XIX
	popw	hl	; F5344D  pop HL
	ret	; F5344E  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_DrawbarScreen -- the 2nd of the eight SOFT KEYS in the row under
;           the LCD, on the DrawbarScreen
; Reached by: SW35 "SOFT KEY col 2 lower" (matrix segment 4 bit 2, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6CB {class 0xA9, code 0x01} -> delivered code 0x81; SW36
;           "SOFT KEY col 2 upper" (matrix segment 4 bit 3, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6CF
;           {class 0xA9, code 0x01} -> delivered code 0x01. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 1 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x01 IS code 0x01 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW43 SOFT KEY col
;           6 lower (segment 5 bit 2, fitted); SW44 SOFT KEY col 6 upper
;           (segment 5 bit 3, fitted); SW51 [no legend: matrix position
;           outside every diode list] (segment 6 bit 2, NOT fitted on this
;           panel); SW52 [no legend: matrix position outside every diode list]
;           (segment 6 bit 3, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW35/SW36 are the two switches of its 2nd column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW35, so "col 2" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
SoftKeyCol2_DrawbarScreen:
	pushw	hl	; F5344F  push HL
	push	xix	; F53450  push XIX
	lda	xix, (10387:16)	; F53451  lda XIX,0x2893
	ld	c, (xix)	; F53455  ld C,(XIX)
	and	c, 15	; F53457  and C,0x0f
	pushw	bc	; F5345A  push BC
	calr	Drawbar_StepLevel	; F5345B  calr 0xf533dc
	ld	h, a	; F5345E  ld H,A
	ld	c, (xix)	; F53460  ld C,(XIX)
	and	c, 15	; F53462  and C,0x0f
	popw	iy	; F53465  pop IY
	cp	a, c	; F53466  cp A,C
	jr	z, SoftKeyCol2_DrawbarScreen_Epilogue2	; F53468  jr Z,0xf5348e
	and	a, 15	; F5346A  and A,0x0f
	and	(xix), 0xf0	; F5346D  and (XIX),0xf0
	or	(xix), a	; F53470  or (XIX),A
	push	0	; F53472  push 0x00
	push	(0x289c:16)	; F53474  push (0x289c)
	calr	Drawbar_SendPartParams	; F53478  calr 0xf540f3
	lda	xbc, (Drawbar2_5_1_3ft_Update:24)	; F5347B  lda XBC,0xf539c0
	push	xbc	; F53480  push XBC
	call	T_CallbackQueue_Post	; F53481  call 0xf42e84
	pushw	1	; F53485  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53488  call 0xf42dc0
	inc	8, xsp	; F5348C  inc 0,XSP
SoftKeyCol2_DrawbarScreen_Epilogue2:
	pop	xix	; F5348E  pop XIX
	popw	hl	; F5348F  pop HL
	ret	; F53490  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_DrawbarScreen -- the 3rd of the eight SOFT KEYS in the row under
;           the LCD, on the DrawbarScreen
; Reached by: SW37 "SOFT KEY col 3 lower" (matrix segment 4 bit 4, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6D3 {class 0xA9, code 0x02} -> delivered code 0x82; SW38
;           "SOFT KEY col 3 upper" (matrix segment 4 bit 5, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6D7
;           {class 0xA9, code 0x02} -> delivered code 0x02. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 2 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x02 IS code 0x02 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW45 SOFT KEY col
;           7 lower (segment 5 bit 4, fitted); SW46 SOFT KEY col 7 upper
;           (segment 5 bit 5, fitted); SW53 [no legend: matrix position
;           outside every diode list] (segment 6 bit 4, NOT fitted on this
;           panel); SW54 [no legend: matrix position outside every diode list]
;           (segment 6 bit 5, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW37/SW38 are the two switches of its 3rd column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW37, so "col 3" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
SoftKeyCol3_DrawbarScreen:
	pushw	hl	; F53491  push HL
	push	xix	; F53492  push XIX
	lda	xix, (10386:16)	; F53493  lda XIX,0x2892
	ld	c, (xix)	; F53497  ld C,(XIX)
	and	c, 240	; F53499  and C,0xf0
	srl	c, 4	; F5349C  srl 0x04,C
	pushw	bc	; F5349F  push BC
	calr	Drawbar_StepLevel	; F534A0  calr 0xf533dc
	ld	h, a	; F534A3  ld H,A
	ld	c, (xix)	; F534A5  ld C,(XIX)
	and	c, 240	; F534A7  and C,0xf0
	srl	c, 4	; F534AA  srl 0x04,C
	popw	iy	; F534AD  pop IY
	cp	a, c	; F534AE  cp A,C
	jr	z, SoftKeyCol3_DrawbarScreen_Epilogue3	; F534B0  jr Z,0xf534d9
	sll	a, 4	; F534B2  sll 0x04,A
	and	a, 240	; F534B5  and A,0xf0
	and	(xix), 0x0f	; F534B8  and (XIX),0x0f
	or	(xix), a	; F534BB  or (XIX),A
	push	0	; F534BD  push 0x00
	push	(0x289c:16)	; F534BF  push (0x289c)
	calr	Drawbar_SendPartParams	; F534C3  calr 0xf540f3
	lda	xbc, (Drawbar3_8ft_Update:24)	; F534C6  lda XBC,0xf53a34
	push	xbc	; F534CB  push XBC
	call	T_CallbackQueue_Post	; F534CC  call 0xf42e84
	pushw	1	; F534D0  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F534D3  call 0xf42dc0
	inc	8, xsp	; F534D7  inc 0,XSP
SoftKeyCol3_DrawbarScreen_Epilogue3:
	pop	xix	; F534D9  pop XIX
	popw	hl	; F534DA  pop HL
	ret	; F534DB  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_DrawbarScreen -- the 4th of the eight SOFT KEYS in the row under
;           the LCD, on the DrawbarScreen
; Reached by: SW39 "SOFT KEY col 4 lower" (matrix segment 4 bit 6, wire 0xC4)
;           -> PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record
;           0xF8B6DB {class 0xA9, code 0x03} -> delivered code 0x83; SW40
;           "SOFT KEY col 4 upper" (matrix segment 4 bit 7, wire 0xC4) ->
;           PanelWireGroupMap_Variant2[0x64] = group 0x04 -> record 0xF8B6DF
;           {class 0xA9, code 0x03} -> delivered code 0x03. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 3 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x03 IS code 0x03 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW47 SOFT KEY col
;           8 lower (segment 5 bit 6, fitted); SW48 SOFT KEY col 8 upper
;           (segment 5 bit 7, fitted); SW55 [no legend: matrix position
;           outside every diode list] (segment 6 bit 6, NOT fitted on this
;           panel); SW56 [no legend: matrix position outside every diode list]
;           (segment 6 bit 7, NOT fitted on this panel). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW39/SW40 are the two switches of its 4th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW39, so "col 4" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
SoftKeyCol4_DrawbarScreen:
	pushw	hl	; F534DC  push HL
	push	xix	; F534DD  push XIX
	lda	xix, (10387:16)	; F534DE  lda XIX,0x2893
	ld	c, (xix)	; F534E2  ld C,(XIX)
	and	c, 240	; F534E4  and C,0xf0
	srl	c, 4	; F534E7  srl 0x04,C
	pushw	bc	; F534EA  push BC
	calr	Drawbar_StepLevel	; F534EB  calr 0xf533dc
	ld	h, a	; F534EE  ld H,A
	ld	c, (xix)	; F534F0  ld C,(XIX)
	and	c, 240	; F534F2  and C,0xf0
	srl	c, 4	; F534F5  srl 0x04,C
	popw	iy	; F534F8  pop IY
	cp	a, c	; F534F9  cp A,C
	jr	z, SoftKeyCol4_DrawbarScreen_Epilogue4	; F534FB  jr Z,0xf53524
	sll	a, 4	; F534FD  sll 0x04,A
	and	a, 240	; F53500  and A,0xf0
	and	(xix), 0x0f	; F53503  and (XIX),0x0f
	or	(xix), a	; F53506  or (XIX),A
	push	0	; F53508  push 0x00
	push	(0x289c:16)	; F5350A  push (0x289c)
	calr	Drawbar_SendPartParams	; F5350E  calr 0xf540f3
	lda	xbc, (Drawbar4_4ft_Update:24)	; F53511  lda XBC,0xf53ac3
	push	xbc	; F53516  push XBC
	call	T_CallbackQueue_Post	; F53517  call 0xf42e84
	pushw	1	; F5351B  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F5351E  call 0xf42dc0
	inc	8, xsp	; F53522  inc 0,XSP
SoftKeyCol4_DrawbarScreen_Epilogue4:
	pop	xix	; F53524  pop XIX
	popw	hl	; F53525  pop HL
	ret	; F53526  ret

; --------------------------------------------------------------------------
; SoftKeyCol5_DrawbarScreen -- the 5th of the eight SOFT KEYS in the row under
;           the LCD, on the DrawbarScreen
; Reached by: SW41 "SOFT KEY col 5 lower" (matrix segment 5 bit 0, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6E4 {class 0xA9, code 0x04} -> delivered code 0x84; SW42
;           "SOFT KEY col 5 upper" (matrix segment 5 bit 1, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6E8
;           {class 0xA9, code 0x04} -> delivered code 0x04. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 4 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x04 IS code 0x04 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW25 LCD RIGHT 1
;           (top) (segment 3 bit 0, fitted); SW26 LCD RIGHT 2 (segment 3 bit
;           1, fitted); SW33 SOFT KEY col 1 lower (segment 4 bit 0, fitted);
;           SW34 SOFT KEY col 1 upper (segment 4 bit 1, fitted). The model
;           strap is the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW41/SW42 are the two switches of its 5th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW41, so "col 5" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
SoftKeyCol5_DrawbarScreen:
	pushw	hl	; F53527  push HL
	push	xix	; F53528  push XIX
	lda	xix, (10388:16)	; F53529  lda XIX,0x2894
	ld	c, (xix)	; F5352D  ld C,(XIX)
	and	c, 15	; F5352F  and C,0x0f
	pushw	bc	; F53532  push BC
	calr	Drawbar_StepLevel	; F53533  calr 0xf533dc
	ld	h, a	; F53536  ld H,A
	ld	c, (xix)	; F53538  ld C,(XIX)
	and	c, 15	; F5353A  and C,0x0f
	popw	iy	; F5353D  pop IY
	cp	a, c	; F5353E  cp A,C
	jr	z, SoftKeyCol5_DrawbarScreen_Epilogue5	; F53540  jr Z,0xf53566
	and	a, 15	; F53542  and A,0x0f
	and	(xix), 0xf0	; F53545  and (XIX),0xf0
	or	(xix), a	; F53548  or (XIX),A
	push	0	; F5354A  push 0x00
	push	(0x289c:16)	; F5354C  push (0x289c)
	calr	Drawbar_SendPartParams	; F53550  calr 0xf540f3
	lda	xbc, (Drawbar5_2_2_3ft_Update:24)	; F53553  lda XBC,0xf53b52
	push	xbc	; F53558  push XBC
	call	T_CallbackQueue_Post	; F53559  call 0xf42e84
	pushw	1	; F5355D  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53560  call 0xf42dc0
	inc	8, xsp	; F53564  inc 0,XSP
SoftKeyCol5_DrawbarScreen_Epilogue5:
	pop	xix	; F53566  pop XIX
	popw	hl	; F53567  pop HL
	ret	; F53568  ret

; --------------------------------------------------------------------------
; SoftKeyCol6_DrawbarScreen -- the 6th of the eight SOFT KEYS in the row under
;           the LCD, on the DrawbarScreen
; Reached by: SW43 "SOFT KEY col 6 lower" (matrix segment 5 bit 2, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6EC {class 0xA9, code 0x05} -> delivered code 0x85; SW44
;           "SOFT KEY col 6 upper" (matrix segment 5 bit 3, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6F0
;           {class 0xA9, code 0x05} -> delivered code 0x05. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 5 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x05 IS code 0x05 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW27 LCD RIGHT 3
;           (segment 3 bit 2, fitted); SW28 LCD RIGHT 4 (segment 3 bit 3,
;           fitted); SW35 SOFT KEY col 2 lower (segment 4 bit 2, fitted); SW36
;           SOFT KEY col 2 upper (segment 4 bit 3, fitted). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW43/SW44 are the two switches of its 6th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW43, so "col 6" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
SoftKeyCol6_DrawbarScreen:
	pushw	hl	; F53569  push HL
	push	xix	; F5356A  push XIX
	lda	xix, (10388:16)	; F5356B  lda XIX,0x2894
	ld	c, (xix)	; F5356F  ld C,(XIX)
	and	c, 240	; F53571  and C,0xf0
	srl	c, 4	; F53574  srl 0x04,C
	pushw	bc	; F53577  push BC
	calr	Drawbar_StepLevel	; F53578  calr 0xf533dc
	ld	h, a	; F5357B  ld H,A
	ld	c, (xix)	; F5357D  ld C,(XIX)
	and	c, 240	; F5357F  and C,0xf0
	srl	c, 4	; F53582  srl 0x04,C
	popw	iy	; F53585  pop IY
	cp	a, c	; F53586  cp A,C
	jr	z, SoftKeyCol6_DrawbarScreen_Epilogue6	; F53588  jr Z,0xf535b1
	sll	a, 4	; F5358A  sll 0x04,A
	and	a, 240	; F5358D  and A,0xf0
	and	(xix), 0x0f	; F53590  and (XIX),0x0f
	or	(xix), a	; F53593  or (XIX),A
	push	0	; F53595  push 0x00
	push	(0x289c:16)	; F53597  push (0x289c)
	calr	Drawbar_SendPartParams	; F5359B  calr 0xf540f3
	lda	xbc, (Drawbar6_2ft_Update:24)	; F5359E  lda XBC,0xf53bc6
	push	xbc	; F535A3  push XBC
	call	T_CallbackQueue_Post	; F535A4  call 0xf42e84
	pushw	1	; F535A8  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F535AB  call 0xf42dc0
	inc	8, xsp	; F535AF  inc 0,XSP
SoftKeyCol6_DrawbarScreen_Epilogue6:
	pop	xix	; F535B1  pop XIX
	popw	hl	; F535B2  pop HL
	ret	; F535B3  ret

; --------------------------------------------------------------------------
; SoftKeyCol7_DrawbarScreen -- the 7th of the eight SOFT KEYS in the row under
;           the LCD, on the DrawbarScreen
; Reached by: SW45 "SOFT KEY col 7 lower" (matrix segment 5 bit 4, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6F4 {class 0xA9, code 0x06} -> delivered code 0x86; SW46
;           "SOFT KEY col 7 upper" (matrix segment 5 bit 5, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B6F8
;           {class 0xA9, code 0x06} -> delivered code 0x06. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 6 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x06 IS code 0x06 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW29 LCD RIGHT 5
;           (bottom) (segment 3 bit 4, fitted); SW30 -1 (segment 3 bit 5,
;           fitted); SW37 SOFT KEY col 3 lower (segment 4 bit 4, fitted); SW38
;           SOFT KEY col 3 upper (segment 4 bit 5, fitted). The model strap is
;           the RAM byte (0x00C4), latched from PB bit 0 by prom_a
;           Variant_SetFromPB0 at 0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW45/SW46 are the two switches of its 7th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW45, so "col 7" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
SoftKeyCol7_DrawbarScreen:
	pushw	hl	; F535B4  push HL
	push	xix	; F535B5  push XIX
	lda	xix, (10389:16)	; F535B6  lda XIX,0x2895
	ld	c, (xix)	; F535BA  ld C,(XIX)
	and	c, 15	; F535BC  and C,0x0f
	pushw	bc	; F535BF  push BC
	calr	Drawbar_StepLevel	; F535C0  calr 0xf533dc
	ld	h, a	; F535C3  ld H,A
	ld	c, (xix)	; F535C5  ld C,(XIX)
	and	c, 15	; F535C7  and C,0x0f
	popw	iy	; F535CA  pop IY
	cp	a, c	; F535CB  cp A,C
	jr	z, SoftKeyCol7_DrawbarScreen_Epilogue7	; F535CD  jr Z,0xf535f3
	and	a, 15	; F535CF  and A,0x0f
	and	(xix), 0xf0	; F535D2  and (XIX),0xf0
	or	(xix), a	; F535D5  or (XIX),A
	push	0	; F535D7  push 0x00
	push	(0x289c:16)	; F535D9  push (0x289c)
	calr	Drawbar_SendPartParams	; F535DD  calr 0xf540f3
	lda	xbc, (Drawbar7_1_3_5ft_Update:24)	; F535E0  lda XBC,0xf53c55
	push	xbc	; F535E5  push XBC
	call	T_CallbackQueue_Post	; F535E6  call 0xf42e84
	pushw	1	; F535EA  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F535ED  call 0xf42dc0
	inc	8, xsp	; F535F1  inc 0,XSP
SoftKeyCol7_DrawbarScreen_Epilogue7:
	pop	xix	; F535F3  pop XIX
	popw	hl	; F535F4  pop HL
	ret	; F535F5  ret

; --------------------------------------------------------------------------
; SoftKeyCol8_DrawbarScreen -- the 8th of the eight SOFT KEYS in the row under
;           the LCD, on the DrawbarScreen
; Reached by: SW47 "SOFT KEY col 8 lower" (matrix segment 5 bit 6, wire 0xC5)
;           -> PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record
;           0xF8B6FC {class 0xA9, code 0x07} -> delivered code 0x87; SW48
;           "SOFT KEY col 8 upper" (matrix segment 5 bit 7, wire 0xC5) ->
;           PanelWireGroupMap_Variant2[0x65] = group 0x05 -> record 0xF8B700
;           {class 0xA9, code 0x07} -> delivered code 0x07. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_PanelCode_ToSlotAndFlags and then `mul A,0x04 / add
;           XWA,0x00f54248` at 0xF5303D, so the index is the REMAPPED SLOT and
;           this is slot 7 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x07 IS code 0x07 here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks WHICH SWITCH OF THE COLUMN: set
;           = the even matrix bit, clear = the odd one. ⚠ That the even bit is
;           the LOWER key of the pair is round 9's POSITION-grade reading of
;           the silkscreen, corroborated by the item i / item i+8 shape of the
;           eight TRACK CLEAR handlers at 0xF7ECFF-0xF7EDC6 and proved by
;           nothing.
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW31 +1 (segment
;           3 bit 6, fitted); SW32 EXIT (segment 3 bit 7, fitted); SW39 SOFT
;           KEY col 4 lower (segment 4 bit 6, fitted); SW40 SOFT KEY col 4
;           upper (segment 4 bit 7, fitted). The model strap is the RAM byte
;           (0x00C4), latched from PB bit 0 by prom_a Variant_SetFromPB0 at
;           0xF82882; variant 2 is the SX-WSA1R
;           (notes/wave7_panel_names_round11.py --variant, three independent
;           measurements).
; Evidence: the number in this name has a REFERENT OUTSIDE THE CODE: service
;           manual page I-4/I-5 draws a ROW OF EIGHT soft keys under the
;           display; SW47/SW48 are the two switches of its 8th column, matched
;           to the CP1 silkscreen (page II-27/28) by position. ⚠ GRADE
;           POSITION in notes/wave7_panel_button_codes.py --physical -- the
;           manual prints NO legend beside SW47, so "col 8" is a counted place
;           on the panel and not a printed word. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; --------------------------------------------------------------------------
SoftKeyCol8_DrawbarScreen:
	pushw	hl	; F535F6  push HL
	push	xix	; F535F7  push XIX
	lda	xix, (10389:16)	; F535F8  lda XIX,0x2895
	ld	c, (xix)	; F535FC  ld C,(XIX)
	and	c, 240	; F535FE  and C,0xf0
	srl	c, 4	; F53601  srl 0x04,C
	pushw	bc	; F53604  push BC
	calr	Drawbar_StepLevel	; F53605  calr 0xf533dc
	ld	h, a	; F53608  ld H,A
	ld	c, (xix)	; F5360A  ld C,(XIX)
	and	c, 240	; F5360C  and C,0xf0
	srl	c, 4	; F5360F  srl 0x04,C
	popw	iy	; F53612  pop IY
	cp	a, c	; F53613  cp A,C
	jr	z, SoftKeyCol8_DrawbarScreen_Epilogue8	; F53615  jr Z,0xf5363e
	sll	a, 4	; F53617  sll 0x04,A
	and	a, 240	; F5361A  and A,0xf0
	and	(xix), 0x0f	; F5361D  and (XIX),0x0f
	or	(xix), a	; F53620  or (XIX),A
	push	0	; F53622  push 0x00
	push	(0x289c:16)	; F53624  push (0x289c)
	calr	Drawbar_SendPartParams	; F53628  calr 0xf540f3
	lda	xbc, (Drawbar8_1_1_3ft_Update:24)	; F5362B  lda XBC,0xf53cc9
	push	xbc	; F53630  push XBC
	call	T_CallbackQueue_Post	; F53631  call 0xf42e84
	pushw	1	; F53635  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53638  call 0xf42dc0
	inc	8, xsp	; F5363C  inc 0,XSP
SoftKeyCol8_DrawbarScreen_Epilogue8:
	pop	xix	; F5363E  pop XIX
	popw	hl	; F5363F  pop HL
	ret	; F53640  ret

; --------------------------------------------------------------------------
; PageKey_DrawbarScreen
; Called from: PanelButtonTable_DrawbarScreen[16]
; Evidence: it is entry 16 of this screen's button table, and slot 16 is the
;           REMAPPED slot of raw panel code 0x10, whose only fitted producers
;           are SW21 "PAGE v" (pair position 0) and SW22 "PAGE ^" (position 1),
;           segment 2 bits 4 and 5.  Variant 1 sources the same code from
;           SW79/SW80, which no diode list fits, so the pair is the same under
;           both wire maps.  The remap is PanelCode_ToSlotAndFlags, which leaves
;           0x00..0x10 alone.  notes/prom_b_panel_names_round11.py --selftest.
; ⚠ NOT named in the 0xF7D2D8 family.  There the two slot-0x10 handlers are
;           ALSO installed at slot 0x19, the code the action handlers write over
;           a soft-key base, so nothing there names them.  Here slot 16 is not
;           shared.
; Unknown: what (0x2896) holds -- the nibble this routine pages through.
; --------------------------------------------------------------------------
PageKey_DrawbarScreen:
	pushw	hl	; F53641  push HL
	push	xix	; F53642  push XIX
	lda	xix, (10390:16)	; F53643  lda XIX,0x2896
	ld	c, (xix)	; F53647  ld C,(XIX)
	and	c, 15	; F53649  and C,0x0f
	pushw	bc	; F5364C  push BC
	calr	Drawbar_StepLevel	; F5364D  calr 0xf533dc
	ld	h, a	; F53650  ld H,A
	ld	c, (xix)	; F53652  ld C,(XIX)
	and	c, 15	; F53654  and C,0x0f
	popw	iy	; F53657  pop IY
	cp	a, c	; F53658  cp A,C
	jr	z, PageKey_DrawbarScreen_Epilogue9	; F5365A  jr Z,0xf53680
	and	a, 15	; F5365C  and A,0x0f
	and	(xix), 0xf0	; F5365F  and (XIX),0xf0
	or	(xix), a	; F53662  or (XIX),A
	push	0	; F53664  push 0x00
	push	(0x289c:16)	; F53666  push (0x289c)
	calr	Drawbar_SendPartParams	; F5366A  calr 0xf540f3
	lda	xbc, (Drawbar9_1ft_Update:24)	; F5366D  lda XBC,0xf53d58
	push	xbc	; F53672  push XBC
	call	T_CallbackQueue_Post	; F53673  call 0xf42e84
	pushw	1	; F53677  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F5367A  call 0xf42dc0
	inc	8, xsp	; F5367E  inc 0,XSP
PageKey_DrawbarScreen_Epilogue9:
	pop	xix	; F53680  pop XIX
	popw	hl	; F53681  pop HL
	ret	; F53682  ret

; --------------------------------------------------------------------------
; ExitKey_DrawbarScreen
; Called from: PanelButtonTable_DrawbarScreen[15]
; What it does: reads flag bit 0 of (0x28B0) -- the pair position
;          PanelCode_ToSlotAndFlags copied there from bit 7 of the code -- and on
;          the position-1 arm sets (0x2071) and requests screen 1 in (0x2070),
;          the screen-request pair prom_a documents at 0xF86055.
; Evidence: it is entry 15 of this screen's button table, and slot 15 is the
;           REMAPPED slot of raw panel code 0x0F, whose only fitted producer is
;           SW32 EXIT under both wire maps (segment 3 bit 7, service manual page
;           32).  The remap is PanelCode_ToSlotAndFlags, which leaves 0x00..0x10
;           alone; slot 15 is filled in all four of this file's 23-entry
;           dispatch tables and slot 0x0F is filled in all 32 of the 0xF7D2D8
;           button tables, which is what a key every screen must handle looks
;           like.  notes/prom_b_panel_names_round11.py --selftest.
; Unknown: which screen the request lands on -- (0x2070) is set to 1 here and
;          nothing in this file says what screen 1 is.
; --------------------------------------------------------------------------
ExitKey_DrawbarScreen:
	push	xix	; F53683  push XIX
	lda	xix, (UI_Request_Hi:16)	; F53684  lda XIX,0x2071
	ld	c, (PanelEvent_Flags:16)	; F53688  ld C,(0x28b0)
	and	c, 1	; F5368C  and C,0x01
	jr	nz, ExitKey_DrawbarScreen_Epilogue10	; F5368F  jr NZ,0xf536ba
	cp	(0x289e:16), 0x00	; F53691  cp (0x289e),0x00
	jr	nz, ExitKey_DrawbarScreen_Skip4	; F53696  jr NZ,0xf536b2
	ld	c, (UI_ScreenHoldState:16)	; F53698  ld C,(0x2092)
	and	c, 1	; F5369C  and C,0x01
	jr	z, ExitKey_DrawbarScreen_Skip3	; F5369F  jr Z,0xf536a8
	ld	(UI_ScreenHoldPending:16), 1	; F536A1  ld (0x209a),0x01
	jr	ExitKey_DrawbarScreen_Epilogue10	; F536A6  jr T,0xf536ba
ExitKey_DrawbarScreen_Skip3:
	ld	(xix), 2	; F536A8  ld (XIX),0x02
	ld	(UI_Request:16), 1	; F536AB  ld (0x2070),0x01
	jr	ExitKey_DrawbarScreen_Epilogue10	; F536B0  jr T,0xf536ba
ExitKey_DrawbarScreen_Skip4:
	ld	(10398:16), 0	; F536B2  ld (0x289e),0x00
	or	(xix), 0x10	; F536B7  or (XIX),0x10
ExitKey_DrawbarScreen_Epilogue10:
	pop	xix	; F536BA  pop XIX
	ret	; F536BB  ret

; Re-typed 2026-10-04 (was: --- 0xF536BC-0xF536C4  data (9 bytes) ---): these bytes are `call 0xf42e10` /
;   `ld (0x2540),0x00`, the first two instructions of a painter.  ScreenEnterBody_DrawbarScreen posts 0xF536BC to
;   the callback queue.  The painter draws the title DL_DrawbarTitle .. DL_PercussiveToneHeader, then
;   DL_PercussiveToneHeader+0x7D .. DL_SoundEditBar, or DL_DrawbarSettingPage when PanelModeGroup is 0x17.
Paint_DrawbarScreenTitle:
	call	T_LCD_BlankThenSetPanel3Layer_Copy	; F536BC  call 0xf42e10
	ld	(LCD_CurrentLayer:16), 0	; F536C0  ld (0x2540),0x00
	lda	xbc, (DL_PercussiveToneHeader:24)	; F536C5  lda XBC,0xf54416
	push	xbc	; F536CA  push XBC
	lda	xwa, (DL_DrawbarTitle:24)	; F536CB  lda XWA,0xf543d6
	push	xwa	; F536D0  push XWA
	call	T_DisplayList_Run_Stack	; F536D1  call 0xf42e00
	inc	8, xsp	; F536D5  inc 0,XSP
	cp	(PanelModeGroup:16), 0x17	; F536D7  cp (0x2076),0x17
	jr	z, Paint_DrawbarScreenTitle_Skip5	; F536DC  jr Z,0xf536ec
	lda	xbc, (DL_SoundEditBar:24)	; F536DE  lda XBC,0xf544ad
	push	xbc	; F536E3  push XBC
	lda	xwa, (DL_PercussiveToneHeader + 0x7D:24)	; F536E4  lda XWA,0xf54493
	push	xwa	; F536E9  push XWA
	jr	Paint_DrawbarScreenTitle_Join2	; F536EA  jr T,0xf536f8
Paint_DrawbarScreenTitle_Skip5:
	lda	xbc, (DL_DrawbarSettingPage:24)	; F536EC  lda XBC,0xf544eb
	push	xbc	; F536F1  push XBC
	lda	xwa, (DL_SoundEditBar:24)	; F536F2  lda XWA,0xf544ad
	push	xwa	; F536F7  push XWA
Paint_DrawbarScreenTitle_Join2:
	call	T_DisplayList_Run_Stack	; F536F8  call 0xf42e00
	inc	8, xsp	; F536FC  inc 0,XSP
	ret	; F536FE  ret

; --------------------------------------------------------------------------
; PaintAllDrawbars -- step and redraw all nine bars
; Called from: 0xF537A1
; What it does: returns at once if (0x289E) != 0, else `calr` each of the
;               nine Drawbar*_Update routines in footage order.
; Evidence: nine `calr` instructions at 0xF53706, 0xF53709, 0xF5370C,
;           0xF5370F, 0xF53712, 0xF53715, 0xF53718, 0xF5371B and 0xF5371E,
;           whose targets are exactly the nine drawbar entry points and
;           nothing else (--selftest check E4).
; --------------------------------------------------------------------------
PaintAllDrawbars:
	cp	(0x289e:16), 0x00	; F536FF  cp (0x289e),0x00
	jr	nz, PaintAllDrawbars_Return	; F53704  jr NZ,0xf53721
	calr	Drawbar1_16ft_Update	; F53706  calr 0xf5394c
	calr	Drawbar2_5_1_3ft_Update	; F53709  calr 0xf539c0
	calr	Drawbar3_8ft_Update	; F5370C  calr 0xf53a34
	calr	Drawbar4_4ft_Update	; F5370F  calr 0xf53ac3
	calr	Drawbar5_2_2_3ft_Update	; F53712  calr 0xf53b52
	calr	Drawbar6_2ft_Update	; F53715  calr 0xf53bc6
	calr	Drawbar7_1_3_5ft_Update	; F53718  calr 0xf53c55
	calr	Drawbar8_1_1_3ft_Update	; F5371B  calr 0xf53cc9
	calr	Drawbar9_1ft_Update	; F5371E  calr 0xf53d58
PaintAllDrawbars_Return:
	ret	; F53721  ret

; Re-typed 2026-10-04 (was: --- 0xF53722-0xF5373C  data (27 bytes) ---): a painter's prologue.  ScreenEnterBody_
;   DrawbarScreen posts 0xF53722.  It sets (0xC6) bit 0, and redraws the title layers when (0x289E) differs from
;   its copy (0x289F); then the footage scale and the page.
Paint_DrawbarScreenLayout:
	pushw	hl	; F53722  push HL
	push	xix	; F53723  push XIX
	lda	xix, (LCD_CurrentLayer:16)	; F53724  lda XIX,0x2540
	set	0, (0xc6:8)	; F53728  set 0,(0xc6)
	ld	c, (10398:16)	; F5372B  ld C,(0x289e)
	cp	c, (0x289f:16)	; F5372F  cp C,(0x289f)
	jrl	z, Paint_DrawbarScreenLayout_Unchanged	; F53733  jrl Z,0xf537cd
	ld	(10399:16), c	; F53736  ld (0x289f),C
	ld	(xix), 0	; F5373A  ld (XIX),0x00
	lda	xbc, (DL_DrawbarTitle:24)	; F5373D  lda XBC,0xf543d6
	push	xbc	; F53742  push XBC
	lda	xwa, (Paint_DrawbarScreenLayout_DL1:24)	; F53743  lda XWA,0xf543c4
	push	xwa	; F53748  push XWA
	call	T_DisplayList_Run_Stack	; F53749  call 0xf42e00
	ld	(xix), 1	; F5374D  ld (XIX),0x01
	lda	xbc, (DL_DrawbarTitle:24)	; F53750  lda XBC,0xf543d6
	push	xbc	; F53755  push XBC
	lda	xwa, (Paint_DrawbarScreenLayout_DL1:24)	; F53756  lda XWA,0xf543c4
	push	xwa	; F5375B  push XWA
	call	T_DisplayList_Run_Stack	; F5375C  call 0xf42e00
	inc	8, xsp	; F53760  inc 0,XSP
	inc	8, xsp	; F53762  inc 0,XSP
	cp	(0x289e:16), 0x00	; F53764  cp (0x289e),0x00
	jr	nz, PaintAllDrawbars_Skip	; F53769  jr NZ,0xf537b8
	ld	(xix), 0	; F5376B  ld (XIX),0x00
	lda	xbc, (Paint_DrawbarScreenLayout_DL2:24)	; F5376E  lda XBC,0xf543b0
	push	xbc	; F53773  push XBC
	lda	xwa, (DL_DrawbarFootageScale:24)	; F53774  lda XWA,0xf54331
	push	xwa	; F53779  push XWA
	call	T_DisplayList_Run_Stack	; F5377A  call 0xf42e00
	ld	(xix), 1	; F5377E  ld (XIX),0x01
	lda	xbc, (Paint_DrawbarScreenLayout_DL1:24)	; F53781  lda XBC,0xf543c4
	push	xbc	; F53786  push XBC
	lda	xwa, (Paint_DrawbarScreenLayout_DL2:24)	; F53787  lda XWA,0xf543b0
	push	xwa	; F5378C  push XWA
	call	T_DisplayList_Run_Stack	; F5378D  call 0xf42e00
	lda	xbc, (DL_DrawbarFootageScale:24)	; F53791  lda XBC,0xf54331
	push	xbc	; F53796  push XBC
	lda	xwa, (DL_DrawbarScaleStrip:24)	; F53797  lda XWA,0xf54311
	push	xwa	; F5379C  push XWA
	call	T_DisplayList_Run_Stack	; F5379D  call 0xf42e00
	calr	PaintAllDrawbars	; F537A1  calr 0xf536ff
	add	xsp, 24	; F537A4  add XSP,0x00000018
	lda	xbc, (DL_PercussiveToneHeader + 0x7D:24)	; F537AA  lda XBC,0xf54493
	push	xbc	; F537AF  push XBC
	lda	xwa, (DL_PercussiveToneHeader:24)	; F537B0  lda XWA,0xf54416
	push	xwa	; F537B5  push XWA
	jr	PaintAllDrawbars_Join	; F537B6  jr T,0xf537c7
PaintAllDrawbars_Skip:
	ld	(xix), 0	; F537B8  ld (XIX),0x00
	lda	xbc, (DL_DrawbarParamValues:24)	; F537BB  lda XBC,0xf54668
	push	xbc	; F537C0  push XBC
	lda	xwa, (DL_DrawbarSettingPage:24)	; F537C1  lda XWA,0xf544eb
	push	xwa	; F537C6  push XWA
PaintAllDrawbars_Join:
	call	T_DisplayList_Run_Stack	; F537C7  call 0xf42e00
	inc	8, xsp	; F537CB  inc 0,XSP
Paint_DrawbarScreenLayout_Unchanged:
	ld	(xix), 1	; F537CD  ld (XIX),0x01
	cp	(0x289e:16), 0x00	; F537D0  cp (0x289e),0x00
	jr	nz, PaintAllDrawbars_Skip2	; F537D5  jr NZ,0xf537e5
	lda	xbc, (Paint_DrawbarScreenLayout_Unchanged_DL1:24)	; F537D7  lda XBC,0xf54705
	push	xbc	; F537DC  push XBC
	lda	xwa, (Paint_DrawbarScreenLayout_Unchanged_DL2:24)	; F537DD  lda XWA,0xf546fa
	push	xwa	; F537E2  push XWA
	jr	PaintAllDrawbars_Join2	; F537E3  jr T,0xf53817
PaintAllDrawbars_Skip2:
	ld	(UI_DrawScratch), (0x28a1:16)	; F537E5  ld (0x2640),(0x28a1)
	ld	h, (10401:16)	; F537EB  ld H,(0x28a1)
	ld	(UI_DrawScratch+1), (0x28a2:16)	; F537EF  ld (0x2641),(0x28a2)
	ld	(10402:16), h	; F537F5  ld (0x28a2),H
	lda	xbc, (ParamCursorRects:24)	; F537F9  lda XBC,0xf546da
	push	xbc	; F537FE  push XBC
	lda	xwa, (DL_ParamCursorBar:24)	; F537FF  lda XWA,0xf546c4
	push	xwa	; F53804  push XWA
	call	T_DisplayListB_Run_Stack	; F53805  call 0xf42e04
	inc	8, xsp	; F53809  inc 0,XSP
	lda	xbc, (ParamCursorRect_Single:24)	; F5380B  lda XBC,0xf54710
	push	xbc	; F53810  push XBC
	lda	xwa, (Paint_DrawbarScreenLayout_Unchanged_DL1:24)	; F53811  lda XWA,0xf54705
	push	xwa	; F53816  push XWA
PaintAllDrawbars_Join2:
	call	T_DisplayListB_Run_Stack	; F53817  call 0xf42e04
	res	0, (0xc6:8)	; F5381B  res 0,(0xc6)
	inc	8, xsp	; F5381E  inc 0,XSP
	pop	xix	; F53820  pop XIX
	popw	hl	; F53821  pop HL
	ret	; F53822  ret
; Paint_DrawbarScreenValues: Third painter ScreenEnterBody_DrawbarScreen posts (after Paint_DrawbarScreenTitle and
;   Paint_DrawbarScreenLayout). Main page ((0x289E) = 0): on layer 1 draws the (0x2896) bit 5 and bit 4 indicators
;   (DL_Flag2896b5_Set or _Clear, DL_Flag2896b4_Set or _Clear); setting page ((0x289E) != 0): copies (0x2890)/(0x2891)
;   to UI_DrawScratch and prints the four nibbles of DL_DrawbarParamValues (percussive tone decay / level, drawbar
;   attack / release time). Then shows all layers, (0x289D) := 1. Basis: caller + body + display lists. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
Paint_DrawbarScreenValues:
	pushw	hl	; F53823  push HL
	cp	(0x289e:16), 0x00	; F53824  cp (0x289e),0x00
	jr	nz, Paint_DrawbarScreenValues_SettingPage	; F53829  jr NZ,0xf53884
	ld	(LCD_CurrentLayer:16), 1	; F5382B  ld (0x2540),0x01
	ld	h, (10390:16)	; F53830  ld H,(0x2896)
	ld	c, h	; F53834  ld C,H
	and	c, 32	; F53836  and C,0x20
	jr	z, PaintAllDrawbars_Skip3	; F53839  jr Z,0xf53849
	lda	xbc, (DL_Flag2896b5_Clear:24)	; F5383B  lda XBC,0xf542ed
	push	xbc	; F53840  push XBC
	lda	xwa, (DL_Flag2896b5_Set:24)	; F53841  lda XWA,0xf542e1
	push	xwa	; F53846  push XWA
	jr	PaintAllDrawbars_Join3	; F53847  jr T,0xf53855
PaintAllDrawbars_Skip3:
	lda	xbc, (DL_Flag2896b4_Set:24)	; F53849  lda XBC,0xf542f9
	push	xbc	; F5384E  push XBC
	lda	xwa, (DL_Flag2896b5_Clear:24)	; F5384F  lda XWA,0xf542ed
	push	xwa	; F53854  push XWA
PaintAllDrawbars_Join3:
	call	T_DisplayList_Run_Stack	; F53855  call 0xf42e00
	ld	c, h	; F53859  ld C,H
	and	c, 16	; F5385B  and C,0x10
	inc	8, xsp	; F5385E  inc 0,XSP
	jr	z, PaintAllDrawbars_Skip4	; F53860  jr Z,0xf53870
	lda	xbc, (DL_Flag2896b4_Clear:24)	; F53862  lda XBC,0xf54305
	push	xbc	; F53867  push XBC
	lda	xwa, (DL_Flag2896b4_Set:24)	; F53868  lda XWA,0xf542f9
	push	xwa	; F5386D  push XWA
	jr	PaintAllDrawbars_Join4	; F5386E  jr T,0xf5387c
PaintAllDrawbars_Skip4:
	lda	xbc, (DL_DrawbarScaleStrip:24)	; F53870  lda XBC,0xf54311
	push	xbc	; F53875  push XBC
	lda	xwa, (DL_Flag2896b4_Clear:24)	; F53876  lda XWA,0xf54305
	push	xwa	; F5387B  push XWA
PaintAllDrawbars_Join4:
	call	T_DisplayList_Run_Stack	; F5387C  call 0xf42e00
PaintAllDrawbars_Join5:
	inc	8, xsp	; F53880  inc 0,XSP
	jr	PaintAllDrawbars_Join6	; F53882  jr T,0xf538ab

; Re-typed 2026-10-06 (was: --- 0xF53884-0xF53898  data (21 bytes) ---): the setting-page arm of
;   Paint_DrawbarScreenValues, which branches here when (0x289E) != 0.  The bytes are `ld (0x2540),0` and two
;   `ld C,(m) / ld (m'),C` copies of (0x2890)/(0x2891) to UI_DrawScratch, the copy that routine's header
;   describes; the display list that follows prints them.
Paint_DrawbarScreenValues_SettingPage:
	ld	(LCD_CurrentLayer:16), 0	; F53884  ld (0x2540),0x00
	ld	c, (10384:16)	; F53889  ld C,(0x2890)
	ld	(UI_DrawScratch:16), c	; F5388D  ld (0x2640),C
	ld	c, (10385:16)	; F53891  ld C,(0x2891)
	ld	(UI_DrawScratch+1:16), c	; F53895  ld (0x2641),C
	lda	xbc, (DLTableB_SignedNibble:24)	; F53899  lda XBC,0xf546a4
	push	xbc	; F5389E  push XBC
	lda	xwa, (DL_DrawbarParamValues:24)	; F5389F  lda XWA,0xf54668
	push	xwa	; F538A4  push XWA
	call	T_DisplayListB_Run_Stack	; F538A5  call 0xf42e04
	jr	PaintAllDrawbars_Join5	; F538A9  jr T,0xf53880
PaintAllDrawbars_Join6:
	call	T_LCD_ShowAllLayers_StackFrame_Copy	; F538AB  call 0xf42e14
	ld	(10397:16), 1	; F538AF  ld (0x289d),0x01
	popw	hl	; F538B4  pop HL
	ret	; F538B5  ret

; --------------------------------------------------------------------------
; Drawbar_DrawColumn -- blit one drawbar, three 8-pixel slices wide
; Called from: 0xF539B8, 0xF53A2C, 0xF53ABB, 0xF53B4A, 0xF53BBE, 0xF53C4D,
;              0xF53CC1, 0xF53D50, 0xF53DC4
; Inputs:  (XIZ+8) = the bar's 0..15 value, (XIZ+0x0A) = the screen column,
;          (XIZ+0x0C) = the sprite base.
; What it does: builds an 11-byte display-list-shaped record on its own
;               stack frame -- opcode 3, BC = 1 byte per row, HL = 0x7B
;               rows, IX = column + 0x10B8, XIY = base +
;               DrawbarRowOffsets[value] -- and hands it to
;               Blit_FromStackRecord three times, advancing IX by 1 and XIY
;               by 233 each time.
; Evidence: `ld (XIX),0x03`, `ld (XIX+0x01),0x0001`, `ld (XIX+0x03),0x007b`,
;           `add BC,0x10b8`, `add XBC,0x00f542c8` and `ld A,(XBC)` at
;           0xF538D1-0xF538F5; then `ld XBC,0x000000e9` (= 233) added to
;           (XIX+7) twice.  0x7B + 0x6E = 0xE9 = 233, so the window and the
;           largest row offset fill one slice exactly.
; Unknown: nothing bounds the value at 9 -- the callers mask it to 4 bits.
;          Nine is the number of offsets that fit before the pointer table
;          at 0xF542D1 begins.
; --------------------------------------------------------------------------
Drawbar_DrawColumn:
	link XIZ,0xfff4	; F538B6  link XIZ,0xfff4
	push	xix	; F538BA  push XIX
	lda	xix, (xiz-12)	; F538BB  lda XIX,XIZ+0xf4
	ld	(LCD_CurrentLayer:16), 0	; F538BE  ld (0x2540),0x00
	cp	(UI_ScreenId:16), 0xa3	; F538C3  cp (0x207c),0xa3
	jr	nz, Drawbar_DrawColumn_Skip	; F538C8  jr NZ,0xf53927
	cp	(0x289e:16), 0x01	; F538CA  cp (0x289e),0x01
	jr	z, Drawbar_DrawColumn_Skip	; F538CF  jr Z,0xf53927
	ld	(xix), 3	; F538D1  ld (XIX),0x03
	ldw	(xix+1), 0x0001	; F538D4  ld (XIX+0x01),0x0001
	ldw	(xix+3), 0x007b	; F538D9  ld (XIX+0x03),0x007b
	ld	bc, (xiz+10)	; F538DE  ld BC,(XIZ+0x0a)
	add	bc, 4280	; F538E1  add BC,0x10b8
	ld	(xix+5), bc	; F538E5  ld (XIX+0x05),BC
	ld	bc, (xiz+8)	; F538E8  ld BC,(XIZ+0x08)
	extz	bc	; F538EB  extz BC
	extz	xbc	; F538ED  extz XBC
	add	xbc, DrawbarRowOffsets	; F538EF  add XBC,0x00f542c8
	ld	a, (xbc)	; F538F5  ld A,(XBC)
	extz	wa	; F538F7  extz WA
	extz	xwa	; F538F9  extz XWA
	add	xwa, (xiz+12)	; F538FB  add XWA,(XIZ+0x0c)
	ld	(xix+7), xwa	; F538FE  ld (XIX+0x07),XWA
	push	xix	; F53901  push XIX
	calr	Blit_FromStackRecord	; F53902  calr 0xf5392b
	incw	1, (xix+5)	; F53905  incw 1,(XIX+0x05)
	ld	xbc, 233	; F53908  ld XBC,0x000000e9
	add	(xix+7), xbc	; F5390D  add (XIX+0x07),XBC
	push	xix	; F53910  push XIX
	calr	Blit_FromStackRecord	; F53911  calr 0xf5392b
	incw	1, (xix+5)	; F53914  incw 1,(XIX+0x05)
	ld	xbc, 233	; F53917  ld XBC,0x000000e9
	add	(xix+7), xbc	; F5391C  add (XIX+0x07),XBC
	push	xix	; F5391F  push XIX
	calr	Blit_FromStackRecord	; F53920  calr 0xf5392b
	inc	8, xsp	; F53923  inc 0,XSP
	inc	4, xsp	; F53925  inc 4,XSP
Drawbar_DrawColumn_Skip:
	pop	xix	; F53927  pop XIX
	unlk XIZ	; F53928  unlk XIZ
	ret	; F5392A  ret

; --------------------------------------------------------------------------
; Blit_FromStackRecord -- issue one `swi 7` from an 11-byte record
; Called from: 0xF53902, 0xF53911, 0xF53920
; Inputs:  (XSP+0x18) = the record.
; What it does: BC = (rec+1), HL = (rec+3), IX = (rec+5), XIY = (rec+7), A =
;               (rec+0), `swi 7`.  That is the same register set
;               DLHandler_FarPtr (0xF31ABE) loads from an opcode-3 display-
;               list record, taken from RAM instead of from ROM.
; Evidence: the five loads at 0xF53936-0xF53942 and the `swi 7` at 0xF53944,
;           read out of this transcription.
; --------------------------------------------------------------------------
Blit_FromStackRecord:
	link XIZ,0x0000	; F5392B  link XIZ,0x0000
	push	xde	; F5392F  push XDE
	push	xhl	; F53930  push XHL
	push	xix	; F53931  push XIX
	push	xiz	; F53932  push XIZ
	ld	xwa, (xsp+24)	; F53933  ld XWA,(XSP+0x18)
	ld	bc, (xwa+1)	; F53936  ld BC,(XWA+0x01)
	ld	hl, (xwa+3)	; F53939  ld HL,(XWA+0x03)
	ld	ix, (xwa+5)	; F5393C  ld IX,(XWA+0x05)
	ld	xiy, (xwa+7)	; F5393F  ld XIY,(XWA+0x07)
	ld	a, (xwa)	; F53942  ld A,(XWA)
	swi	7	; F53944  swi 7
	pop	xiz	; F53945  pop XIZ
	pop	xix	; F53946  pop XIX
	pop	xhl	; F53947  pop XHL
	pop	xde	; F53948  pop XDE
	unlk XIZ	; F53949  unlk XIZ
	ret	; F5394B  ret

; --------------------------------------------------------------------------
; Drawbar1_16ft_Update -- drawbar 1 of 9, footage 16'
; Called from: 0xF53706; and PaintAllDrawbars (0xF536FF) calls all nine in
;              order.
; What it does: reads the low nibble of (0x2897), compares it with the low
;               nibble of (0x2892), and if they differ writes the value one
;               step nearer, re-arms ITSELF through the timer (`lda
;               XBC,0xF5394C / call 0xf42e84 / push 1 / call 0xf42dc0`) and
;               falls into the redraw.  Then it calls Drawbar_DrawColumn
;               with (index = that nibble, column = 3, sprite =
;               Bitmap_DrawbarA).
; Evidence: every field above is read out of this transcription by
;           drawbars() and re-checked by --selftest: `lda XIX,0x2897`, `ld
;           A,(0x2892)`, `push 0x0003` and `lda XBC,0xf54808` all occur
;           exactly once in 0xF5394C-0xF539BF.  The footage is the op-0x20
;           label of DL_DrawbarFootageScale whose screen position is one
;           cell of column 3 (bijection, --selftest check F).
; Note: the sprite split is exact -- the five INTEGER footages (16', 8', 4',
;       2', 1') use Bitmap_DrawbarA and the four FRACTIONAL ones (5 1/3', 2
;       2/3', 1 3/5', 1 1/3') use Bitmap_DrawbarB, with no exception.  It is
;       close to but not equal to the Hammond white/coloured pattern, which
;       would put 16' in the other group, so the two sprites are recorded as
;       A and B and NOT named by colour.
; --------------------------------------------------------------------------
Drawbar1_16ft_Update:
	pushw	hl	; F5394C  push HL
	push	xix	; F5394D  push XIX
	lda	xix, (10391:16)	; F5394E  lda XIX,0x2897
	ld	c, (xix)	; F53952  ld C,(XIX)
	and	c, 15	; F53954  and C,0x0f
	ld	h, c	; F53957  ld H,C
	ld	a, (10386:16)	; F53959  ld A,(0x2892)
	and	a, 15	; F5395D  and A,0x0f
	cp	a, c	; F53960  cp A,C
	jr	z, Drawbar1_16ft_Update_Skip2	; F53962  jr Z,0xf539a9
	ld	c, (xix)	; F53964  ld C,(XIX)
	and	c, 15	; F53966  and C,0x0f
	ld	h, c	; F53969  ld H,C
	ld	a, (10386:16)	; F5396B  ld A,(0x2892)
	and	a, 15	; F5396F  and A,0x0f
	cp	a, c	; F53972  cp A,C
	jr	ule, Drawbar1_16ft_Update_Skip	; F53974  jr ULE,0xf53987
	ld	c, (xix)	; F53976  ld C,(XIX)
	and	c, 15	; F53978  and C,0x0f
	inc	1, c	; F5397B  inc 1,C
	and	c, 15	; F5397D  and C,0x0f
	and	(xix), 0xf0	; F53980  and (XIX),0xf0
	or	(xix), c	; F53983  or (XIX),C
	jr	Drawbar1_16ft_Update_Join	; F53985  jr T,0xf53996
Drawbar1_16ft_Update_Skip:
	ld	c, (xix)	; F53987  ld C,(XIX)
	and	c, 15	; F53989  and C,0x0f
	dec	1, c	; F5398C  dec 1,C
	and	c, 15	; F5398E  and C,0x0f
	and	(xix), 0xf0	; F53991  and (XIX),0xf0
	or	(xix), c	; F53994  or (XIX),C
Drawbar1_16ft_Update_Join:
	lda	xbc, (Drawbar1_16ft_Update:24)	; F53996  lda XBC,0xf5394c
	push	xbc	; F5399B  push XBC
	call	T_CallbackQueue_Post	; F5399C  call 0xf42e84
	pushw	1	; F539A0  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F539A3  call 0xf42dc0
	inc	6, xsp	; F539A7  inc 6,XSP
Drawbar1_16ft_Update_Skip2:
	lda	xbc, (Bitmap_DrawbarA:24)	; F539A9  lda XBC,0xf54808
	push	xbc	; F539AE  push XBC
	pushw	3	; F539AF  push 0x0003
	ld	a, (xix)	; F539B2  ld A,(XIX)
	and	a, 15	; F539B4  and A,0x0f
	pushw	wa	; F539B7  push WA
	calr	Drawbar_DrawColumn	; F539B8  calr 0xf538b6
	inc	8, xsp	; F539BB  inc 0,XSP
	pop	xix	; F539BD  pop XIX
	popw	hl	; F539BE  pop HL
	ret	; F539BF  ret

; --------------------------------------------------------------------------
; Drawbar2_5_1_3ft_Update -- drawbar 2 of 9, footage 5 1/3'
; Called from: 0xF53709; and PaintAllDrawbars (0xF536FF) calls all nine in
;              order.
; What it does: reads the low nibble of (0x2898), compares it with the low
;               nibble of (0x2893), and if they differ writes the value one
;               step nearer, re-arms ITSELF through the timer (`lda
;               XBC,0xF539C0 / call 0xf42e84 / push 1 / call 0xf42dc0`) and
;               falls into the redraw.  Then it calls Drawbar_DrawColumn
;               with (index = that nibble, column = 7, sprite =
;               Bitmap_DrawbarB).
; Evidence: every field above is read out of this transcription by
;           drawbars() and re-checked by --selftest: `lda XIX,0x2898`, `ld
;           A,(0x2893)`, `push 0x0007` and `lda XBC,0xf54ac3` all occur
;           exactly once in 0xF539C0-0xF53A33.  The footage is the op-0x20
;           label of DL_DrawbarFootageScale whose screen position is one
;           cell of column 7 (bijection, --selftest check F).
; Note: the sprite split is exact -- the five INTEGER footages (16', 8', 4',
;       2', 1') use Bitmap_DrawbarA and the four FRACTIONAL ones (5 1/3', 2
;       2/3', 1 3/5', 1 1/3') use Bitmap_DrawbarB, with no exception.  It is
;       close to but not equal to the Hammond white/coloured pattern, which
;       would put 16' in the other group, so the two sprites are recorded as
;       A and B and NOT named by colour.
; --------------------------------------------------------------------------
Drawbar2_5_1_3ft_Update:
	pushw	hl	; F539C0  push HL
	push	xix	; F539C1  push XIX
	lda	xix, (10392:16)	; F539C2  lda XIX,0x2898
	ld	c, (xix)	; F539C6  ld C,(XIX)
	and	c, 15	; F539C8  and C,0x0f
	ld	h, c	; F539CB  ld H,C
	ld	a, (10387:16)	; F539CD  ld A,(0x2893)
	and	a, 15	; F539D1  and A,0x0f
	cp	a, c	; F539D4  cp A,C
	jr	z, Drawbar2_5_1_3ft_Update_Skip2	; F539D6  jr Z,0xf53a1d
	ld	c, (xix)	; F539D8  ld C,(XIX)
	and	c, 15	; F539DA  and C,0x0f
	ld	h, c	; F539DD  ld H,C
	ld	a, (10387:16)	; F539DF  ld A,(0x2893)
	and	a, 15	; F539E3  and A,0x0f
	cp	a, c	; F539E6  cp A,C
	jr	ule, Drawbar2_5_1_3ft_Update_Skip	; F539E8  jr ULE,0xf539fb
	ld	c, (xix)	; F539EA  ld C,(XIX)
	and	c, 15	; F539EC  and C,0x0f
	inc	1, c	; F539EF  inc 1,C
	and	c, 15	; F539F1  and C,0x0f
	and	(xix), 0xf0	; F539F4  and (XIX),0xf0
	or	(xix), c	; F539F7  or (XIX),C
	jr	Drawbar2_5_1_3ft_Update_Join	; F539F9  jr T,0xf53a0a
Drawbar2_5_1_3ft_Update_Skip:
	ld	c, (xix)	; F539FB  ld C,(XIX)
	and	c, 15	; F539FD  and C,0x0f
	dec	1, c	; F53A00  dec 1,C
	and	c, 15	; F53A02  and C,0x0f
	and	(xix), 0xf0	; F53A05  and (XIX),0xf0
	or	(xix), c	; F53A08  or (XIX),C
Drawbar2_5_1_3ft_Update_Join:
	lda	xbc, (Drawbar2_5_1_3ft_Update:24)	; F53A0A  lda XBC,0xf539c0
	push	xbc	; F53A0F  push XBC
	call	T_CallbackQueue_Post	; F53A10  call 0xf42e84
	pushw	1	; F53A14  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53A17  call 0xf42dc0
	inc	6, xsp	; F53A1B  inc 6,XSP
Drawbar2_5_1_3ft_Update_Skip2:
	lda	xbc, (Bitmap_DrawbarB:24)	; F53A1D  lda XBC,0xf54ac3
	push	xbc	; F53A22  push XBC
	pushw	7	; F53A23  push 0x0007
	ld	a, (xix)	; F53A26  ld A,(XIX)
	and	a, 15	; F53A28  and A,0x0f
	pushw	wa	; F53A2B  push WA
	calr	Drawbar_DrawColumn	; F53A2C  calr 0xf538b6
	inc	8, xsp	; F53A2F  inc 0,XSP
	pop	xix	; F53A31  pop XIX
	popw	hl	; F53A32  pop HL
	ret	; F53A33  ret

; --------------------------------------------------------------------------
; Drawbar3_8ft_Update -- drawbar 3 of 9, footage 8'
; Called from: 0xF5370C; and PaintAllDrawbars (0xF536FF) calls all nine in
;              order.
; What it does: reads the high nibble of (0x2897), compares it with the high
;               nibble of (0x2892), and if they differ writes the value one
;               step nearer, re-arms ITSELF through the timer (`lda
;               XBC,0xF53A34 / call 0xf42e84 / push 1 / call 0xf42dc0`) and
;               falls into the redraw.  Then it calls Drawbar_DrawColumn
;               with (index = that nibble, column = 11, sprite =
;               Bitmap_DrawbarA).
; Evidence: every field above is read out of this transcription by
;           drawbars() and re-checked by --selftest: `lda XIX,0x2897`, `ld
;           A,(0x2892)`, `push 0x000b` and `lda XBC,0xf54808` all occur
;           exactly once in 0xF53A34-0xF53AC2.  The footage is the op-0x20
;           label of DL_DrawbarFootageScale whose screen position is one
;           cell of column 11 (bijection, --selftest check F).
; Note: the sprite split is exact -- the five INTEGER footages (16', 8', 4',
;       2', 1') use Bitmap_DrawbarA and the four FRACTIONAL ones (5 1/3', 2
;       2/3', 1 3/5', 1 1/3') use Bitmap_DrawbarB, with no exception.  It is
;       close to but not equal to the Hammond white/coloured pattern, which
;       would put 16' in the other group, so the two sprites are recorded as
;       A and B and NOT named by colour.
; --------------------------------------------------------------------------
Drawbar3_8ft_Update:
	pushw	hl	; F53A34  push HL
	push	xix	; F53A35  push XIX
	lda	xix, (10391:16)	; F53A36  lda XIX,0x2897
	ld	c, (xix)	; F53A3A  ld C,(XIX)
	and	c, 240	; F53A3C  and C,0xf0
	srl	c, 4	; F53A3F  srl 0x04,C
	ld	h, c	; F53A42  ld H,C
	ld	a, (10386:16)	; F53A44  ld A,(0x2892)
	and	a, 240	; F53A48  and A,0xf0
	srl	a, 4	; F53A4B  srl 0x04,A
	cp	a, c	; F53A4E  cp A,C
	jr	z, Drawbar3_8ft_Update_Skip2	; F53A50  jr Z,0xf53aa9
	ld	c, (xix)	; F53A52  ld C,(XIX)
	and	c, 240	; F53A54  and C,0xf0
	srl	c, 4	; F53A57  srl 0x04,C
	ld	h, c	; F53A5A  ld H,C
	ld	a, (10386:16)	; F53A5C  ld A,(0x2892)
	and	a, 240	; F53A60  and A,0xf0
	srl	a, 4	; F53A63  srl 0x04,A
	cp	a, c	; F53A66  cp A,C
	jr	ule, Drawbar3_8ft_Update_Skip	; F53A68  jr ULE,0xf53a81
	ld	c, (xix)	; F53A6A  ld C,(XIX)
	and	c, 240	; F53A6C  and C,0xf0
	srl	c, 4	; F53A6F  srl 0x04,C
	inc	1, c	; F53A72  inc 1,C
	sll	c, 4	; F53A74  sll 0x04,C
	and	c, 240	; F53A77  and C,0xf0
	and	(xix), 0x0f	; F53A7A  and (XIX),0x0f
	or	(xix), c	; F53A7D  or (XIX),C
	jr	Drawbar3_8ft_Update_Join	; F53A7F  jr T,0xf53a96
Drawbar3_8ft_Update_Skip:
	ld	c, (xix)	; F53A81  ld C,(XIX)
	and	c, 240	; F53A83  and C,0xf0
	srl	c, 4	; F53A86  srl 0x04,C
	dec	1, c	; F53A89  dec 1,C
	sll	c, 4	; F53A8B  sll 0x04,C
	and	c, 240	; F53A8E  and C,0xf0
	and	(xix), 0x0f	; F53A91  and (XIX),0x0f
	or	(xix), c	; F53A94  or (XIX),C
Drawbar3_8ft_Update_Join:
	lda	xbc, (Drawbar3_8ft_Update:24)	; F53A96  lda XBC,0xf53a34
	push	xbc	; F53A9B  push XBC
	call	T_CallbackQueue_Post	; F53A9C  call 0xf42e84
	pushw	1	; F53AA0  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53AA3  call 0xf42dc0
	inc	6, xsp	; F53AA7  inc 6,XSP
Drawbar3_8ft_Update_Skip2:
	lda	xbc, (Bitmap_DrawbarA:24)	; F53AA9  lda XBC,0xf54808
	push	xbc	; F53AAE  push XBC
	pushw	11	; F53AAF  push 0x000b
	ld	a, (xix)	; F53AB2  ld A,(XIX)
	and	a, 240	; F53AB4  and A,0xf0
	srl	a, 4	; F53AB7  srl 0x04,A
	pushw	wa	; F53ABA  push WA
	calr	Drawbar_DrawColumn	; F53ABB  calr 0xf538b6
	inc	8, xsp	; F53ABE  inc 0,XSP
	pop	xix	; F53AC0  pop XIX
	popw	hl	; F53AC1  pop HL
	ret	; F53AC2  ret

; --------------------------------------------------------------------------
; Drawbar4_4ft_Update -- drawbar 4 of 9, footage 4'
; Called from: 0xF5370F; and PaintAllDrawbars (0xF536FF) calls all nine in
;              order.
; What it does: reads the high nibble of (0x2898), compares it with the high
;               nibble of (0x2893), and if they differ writes the value one
;               step nearer, re-arms ITSELF through the timer (`lda
;               XBC,0xF53AC3 / call 0xf42e84 / push 1 / call 0xf42dc0`) and
;               falls into the redraw.  Then it calls Drawbar_DrawColumn
;               with (index = that nibble, column = 15, sprite =
;               Bitmap_DrawbarA).
; Evidence: every field above is read out of this transcription by
;           drawbars() and re-checked by --selftest: `lda XIX,0x2898`, `ld
;           A,(0x2893)`, `push 0x000f` and `lda XBC,0xf54808` all occur
;           exactly once in 0xF53AC3-0xF53B51.  The footage is the op-0x20
;           label of DL_DrawbarFootageScale whose screen position is one
;           cell of column 15 (bijection, --selftest check F).
; Note: the sprite split is exact -- the five INTEGER footages (16', 8', 4',
;       2', 1') use Bitmap_DrawbarA and the four FRACTIONAL ones (5 1/3', 2
;       2/3', 1 3/5', 1 1/3') use Bitmap_DrawbarB, with no exception.  It is
;       close to but not equal to the Hammond white/coloured pattern, which
;       would put 16' in the other group, so the two sprites are recorded as
;       A and B and NOT named by colour.
; --------------------------------------------------------------------------
Drawbar4_4ft_Update:
	pushw	hl	; F53AC3  push HL
	push	xix	; F53AC4  push XIX
	lda	xix, (10392:16)	; F53AC5  lda XIX,0x2898
	ld	c, (xix)	; F53AC9  ld C,(XIX)
	and	c, 240	; F53ACB  and C,0xf0
	srl	c, 4	; F53ACE  srl 0x04,C
	ld	h, c	; F53AD1  ld H,C
	ld	a, (10387:16)	; F53AD3  ld A,(0x2893)
	and	a, 240	; F53AD7  and A,0xf0
	srl	a, 4	; F53ADA  srl 0x04,A
	cp	a, c	; F53ADD  cp A,C
	jr	z, Drawbar4_4ft_Update_Skip2	; F53ADF  jr Z,0xf53b38
	ld	c, (xix)	; F53AE1  ld C,(XIX)
	and	c, 240	; F53AE3  and C,0xf0
	srl	c, 4	; F53AE6  srl 0x04,C
	ld	h, c	; F53AE9  ld H,C
	ld	a, (10387:16)	; F53AEB  ld A,(0x2893)
	and	a, 240	; F53AEF  and A,0xf0
	srl	a, 4	; F53AF2  srl 0x04,A
	cp	a, c	; F53AF5  cp A,C
	jr	ule, Drawbar4_4ft_Update_Skip	; F53AF7  jr ULE,0xf53b10
	ld	c, (xix)	; F53AF9  ld C,(XIX)
	and	c, 240	; F53AFB  and C,0xf0
	srl	c, 4	; F53AFE  srl 0x04,C
	inc	1, c	; F53B01  inc 1,C
	sll	c, 4	; F53B03  sll 0x04,C
	and	c, 240	; F53B06  and C,0xf0
	and	(xix), 0x0f	; F53B09  and (XIX),0x0f
	or	(xix), c	; F53B0C  or (XIX),C
	jr	Drawbar4_4ft_Update_Join	; F53B0E  jr T,0xf53b25
Drawbar4_4ft_Update_Skip:
	ld	c, (xix)	; F53B10  ld C,(XIX)
	and	c, 240	; F53B12  and C,0xf0
	srl	c, 4	; F53B15  srl 0x04,C
	dec	1, c	; F53B18  dec 1,C
	sll	c, 4	; F53B1A  sll 0x04,C
	and	c, 240	; F53B1D  and C,0xf0
	and	(xix), 0x0f	; F53B20  and (XIX),0x0f
	or	(xix), c	; F53B23  or (XIX),C
Drawbar4_4ft_Update_Join:
	lda	xbc, (Drawbar4_4ft_Update:24)	; F53B25  lda XBC,0xf53ac3
	push	xbc	; F53B2A  push XBC
	call	T_CallbackQueue_Post	; F53B2B  call 0xf42e84
	pushw	1	; F53B2F  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53B32  call 0xf42dc0
	inc	6, xsp	; F53B36  inc 6,XSP
Drawbar4_4ft_Update_Skip2:
	lda	xbc, (Bitmap_DrawbarA:24)	; F53B38  lda XBC,0xf54808
	push	xbc	; F53B3D  push XBC
	pushw	15	; F53B3E  push 0x000f
	ld	a, (xix)	; F53B41  ld A,(XIX)
	and	a, 240	; F53B43  and A,0xf0
	srl	a, 4	; F53B46  srl 0x04,A
	pushw	wa	; F53B49  push WA
	calr	Drawbar_DrawColumn	; F53B4A  calr 0xf538b6
	inc	8, xsp	; F53B4D  inc 0,XSP
	pop	xix	; F53B4F  pop XIX
	popw	hl	; F53B50  pop HL
	ret	; F53B51  ret

; --------------------------------------------------------------------------
; Drawbar5_2_2_3ft_Update -- drawbar 5 of 9, footage 2 2/3'
; Called from: 0xF53712; and PaintAllDrawbars (0xF536FF) calls all nine in
;              order.
; What it does: reads the low nibble of (0x2899), compares it with the low
;               nibble of (0x2894), and if they differ writes the value one
;               step nearer, re-arms ITSELF through the timer (`lda
;               XBC,0xF53B52 / call 0xf42e84 / push 1 / call 0xf42dc0`) and
;               falls into the redraw.  Then it calls Drawbar_DrawColumn
;               with (index = that nibble, column = 19, sprite =
;               Bitmap_DrawbarB).
; Evidence: every field above is read out of this transcription by
;           drawbars() and re-checked by --selftest: `lda XIX,0x2899`, `ld
;           A,(0x2894)`, `push 0x0013` and `lda XBC,0xf54ac3` all occur
;           exactly once in 0xF53B52-0xF53BC5.  The footage is the op-0x20
;           label of DL_DrawbarFootageScale whose screen position is one
;           cell of column 19 (bijection, --selftest check F).
; Note: the sprite split is exact -- the five INTEGER footages (16', 8', 4',
;       2', 1') use Bitmap_DrawbarA and the four FRACTIONAL ones (5 1/3', 2
;       2/3', 1 3/5', 1 1/3') use Bitmap_DrawbarB, with no exception.  It is
;       close to but not equal to the Hammond white/coloured pattern, which
;       would put 16' in the other group, so the two sprites are recorded as
;       A and B and NOT named by colour.
; --------------------------------------------------------------------------
Drawbar5_2_2_3ft_Update:
	pushw	hl	; F53B52  push HL
	push	xix	; F53B53  push XIX
	lda	xix, (10393:16)	; F53B54  lda XIX,0x2899
	ld	c, (xix)	; F53B58  ld C,(XIX)
	and	c, 15	; F53B5A  and C,0x0f
	ld	h, c	; F53B5D  ld H,C
	ld	a, (10388:16)	; F53B5F  ld A,(0x2894)
	and	a, 15	; F53B63  and A,0x0f
	cp	a, c	; F53B66  cp A,C
	jr	z, Drawbar5_2_2_3ft_Update_Skip2	; F53B68  jr Z,0xf53baf
	ld	c, (xix)	; F53B6A  ld C,(XIX)
	and	c, 15	; F53B6C  and C,0x0f
	ld	h, c	; F53B6F  ld H,C
	ld	a, (10388:16)	; F53B71  ld A,(0x2894)
	and	a, 15	; F53B75  and A,0x0f
	cp	a, c	; F53B78  cp A,C
	jr	ule, Drawbar5_2_2_3ft_Update_Skip	; F53B7A  jr ULE,0xf53b8d
	ld	c, (xix)	; F53B7C  ld C,(XIX)
	and	c, 15	; F53B7E  and C,0x0f
	inc	1, c	; F53B81  inc 1,C
	and	c, 15	; F53B83  and C,0x0f
	and	(xix), 0xf0	; F53B86  and (XIX),0xf0
	or	(xix), c	; F53B89  or (XIX),C
	jr	Drawbar5_2_2_3ft_Update_Join	; F53B8B  jr T,0xf53b9c
Drawbar5_2_2_3ft_Update_Skip:
	ld	c, (xix)	; F53B8D  ld C,(XIX)
	and	c, 15	; F53B8F  and C,0x0f
	dec	1, c	; F53B92  dec 1,C
	and	c, 15	; F53B94  and C,0x0f
	and	(xix), 0xf0	; F53B97  and (XIX),0xf0
	or	(xix), c	; F53B9A  or (XIX),C
Drawbar5_2_2_3ft_Update_Join:
	lda	xbc, (Drawbar5_2_2_3ft_Update:24)	; F53B9C  lda XBC,0xf53b52
	push	xbc	; F53BA1  push XBC
	call	T_CallbackQueue_Post	; F53BA2  call 0xf42e84
	pushw	1	; F53BA6  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53BA9  call 0xf42dc0
	inc	6, xsp	; F53BAD  inc 6,XSP
Drawbar5_2_2_3ft_Update_Skip2:
	lda	xbc, (Bitmap_DrawbarB:24)	; F53BAF  lda XBC,0xf54ac3
	push	xbc	; F53BB4  push XBC
	pushw	19	; F53BB5  push 0x0013
	ld	a, (xix)	; F53BB8  ld A,(XIX)
	and	a, 15	; F53BBA  and A,0x0f
	pushw	wa	; F53BBD  push WA
	calr	Drawbar_DrawColumn	; F53BBE  calr 0xf538b6
	inc	8, xsp	; F53BC1  inc 0,XSP
	pop	xix	; F53BC3  pop XIX
	popw	hl	; F53BC4  pop HL
	ret	; F53BC5  ret

; --------------------------------------------------------------------------
; Drawbar6_2ft_Update -- drawbar 6 of 9, footage 2'
; Called from: 0xF53715; and PaintAllDrawbars (0xF536FF) calls all nine in
;              order.
; What it does: reads the high nibble of (0x2899), compares it with the high
;               nibble of (0x2894), and if they differ writes the value one
;               step nearer, re-arms ITSELF through the timer (`lda
;               XBC,0xF53BC6 / call 0xf42e84 / push 1 / call 0xf42dc0`) and
;               falls into the redraw.  Then it calls Drawbar_DrawColumn
;               with (index = that nibble, column = 23, sprite =
;               Bitmap_DrawbarA).
; Evidence: every field above is read out of this transcription by
;           drawbars() and re-checked by --selftest: `lda XIX,0x2899`, `ld
;           A,(0x2894)`, `push 0x0017` and `lda XBC,0xf54808` all occur
;           exactly once in 0xF53BC6-0xF53C54.  The footage is the op-0x20
;           label of DL_DrawbarFootageScale whose screen position is one
;           cell of column 23 (bijection, --selftest check F).
; Note: the sprite split is exact -- the five INTEGER footages (16', 8', 4',
;       2', 1') use Bitmap_DrawbarA and the four FRACTIONAL ones (5 1/3', 2
;       2/3', 1 3/5', 1 1/3') use Bitmap_DrawbarB, with no exception.  It is
;       close to but not equal to the Hammond white/coloured pattern, which
;       would put 16' in the other group, so the two sprites are recorded as
;       A and B and NOT named by colour.
; --------------------------------------------------------------------------
Drawbar6_2ft_Update:
	pushw	hl	; F53BC6  push HL
	push	xix	; F53BC7  push XIX
	lda	xix, (10393:16)	; F53BC8  lda XIX,0x2899
	ld	c, (xix)	; F53BCC  ld C,(XIX)
	and	c, 240	; F53BCE  and C,0xf0
	srl	c, 4	; F53BD1  srl 0x04,C
	ld	h, c	; F53BD4  ld H,C
	ld	a, (10388:16)	; F53BD6  ld A,(0x2894)
	and	a, 240	; F53BDA  and A,0xf0
	srl	a, 4	; F53BDD  srl 0x04,A
	cp	a, c	; F53BE0  cp A,C
	jr	z, Drawbar6_2ft_Update_Skip2	; F53BE2  jr Z,0xf53c3b
	ld	c, (xix)	; F53BE4  ld C,(XIX)
	and	c, 240	; F53BE6  and C,0xf0
	srl	c, 4	; F53BE9  srl 0x04,C
	ld	h, c	; F53BEC  ld H,C
	ld	a, (10388:16)	; F53BEE  ld A,(0x2894)
	and	a, 240	; F53BF2  and A,0xf0
	srl	a, 4	; F53BF5  srl 0x04,A
	cp	a, c	; F53BF8  cp A,C
	jr	ule, Drawbar6_2ft_Update_Skip	; F53BFA  jr ULE,0xf53c13
	ld	c, (xix)	; F53BFC  ld C,(XIX)
	and	c, 240	; F53BFE  and C,0xf0
	srl	c, 4	; F53C01  srl 0x04,C
	inc	1, c	; F53C04  inc 1,C
	sll	c, 4	; F53C06  sll 0x04,C
	and	c, 240	; F53C09  and C,0xf0
	and	(xix), 0x0f	; F53C0C  and (XIX),0x0f
	or	(xix), c	; F53C0F  or (XIX),C
	jr	Drawbar6_2ft_Update_Join	; F53C11  jr T,0xf53c28
Drawbar6_2ft_Update_Skip:
	ld	c, (xix)	; F53C13  ld C,(XIX)
	and	c, 240	; F53C15  and C,0xf0
	srl	c, 4	; F53C18  srl 0x04,C
	dec	1, c	; F53C1B  dec 1,C
	sll	c, 4	; F53C1D  sll 0x04,C
	and	c, 240	; F53C20  and C,0xf0
	and	(xix), 0x0f	; F53C23  and (XIX),0x0f
	or	(xix), c	; F53C26  or (XIX),C
Drawbar6_2ft_Update_Join:
	lda	xbc, (Drawbar6_2ft_Update:24)	; F53C28  lda XBC,0xf53bc6
	push	xbc	; F53C2D  push XBC
	call	T_CallbackQueue_Post	; F53C2E  call 0xf42e84
	pushw	1	; F53C32  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53C35  call 0xf42dc0
	inc	6, xsp	; F53C39  inc 6,XSP
Drawbar6_2ft_Update_Skip2:
	lda	xbc, (Bitmap_DrawbarA:24)	; F53C3B  lda XBC,0xf54808
	push	xbc	; F53C40  push XBC
	pushw	23	; F53C41  push 0x0017
	ld	a, (xix)	; F53C44  ld A,(XIX)
	and	a, 240	; F53C46  and A,0xf0
	srl	a, 4	; F53C49  srl 0x04,A
	pushw	wa	; F53C4C  push WA
	calr	Drawbar_DrawColumn	; F53C4D  calr 0xf538b6
	inc	8, xsp	; F53C50  inc 0,XSP
	pop	xix	; F53C52  pop XIX
	popw	hl	; F53C53  pop HL
	ret	; F53C54  ret

; --------------------------------------------------------------------------
; Drawbar7_1_3_5ft_Update -- drawbar 7 of 9, footage 1 3/5'
; Called from: 0xF53718; and PaintAllDrawbars (0xF536FF) calls all nine in
;              order.
; What it does: reads the low nibble of (0x289A), compares it with the low
;               nibble of (0x2895), and if they differ writes the value one
;               step nearer, re-arms ITSELF through the timer (`lda
;               XBC,0xF53C55 / call 0xf42e84 / push 1 / call 0xf42dc0`) and
;               falls into the redraw.  Then it calls Drawbar_DrawColumn
;               with (index = that nibble, column = 27, sprite =
;               Bitmap_DrawbarB).
; Evidence: every field above is read out of this transcription by
;           drawbars() and re-checked by --selftest: `lda XIX,0x289a`, `ld
;           A,(0x2895)`, `push 0x001b` and `lda XBC,0xf54ac3` all occur
;           exactly once in 0xF53C55-0xF53CC8.  The footage is the op-0x20
;           label of DL_DrawbarFootageScale whose screen position is one
;           cell of column 27 (bijection, --selftest check F).
; Note: the sprite split is exact -- the five INTEGER footages (16', 8', 4',
;       2', 1') use Bitmap_DrawbarA and the four FRACTIONAL ones (5 1/3', 2
;       2/3', 1 3/5', 1 1/3') use Bitmap_DrawbarB, with no exception.  It is
;       close to but not equal to the Hammond white/coloured pattern, which
;       would put 16' in the other group, so the two sprites are recorded as
;       A and B and NOT named by colour.
; --------------------------------------------------------------------------
Drawbar7_1_3_5ft_Update:
	pushw	hl	; F53C55  push HL
	push	xix	; F53C56  push XIX
	lda	xix, (10394:16)	; F53C57  lda XIX,0x289a
	ld	c, (xix)	; F53C5B  ld C,(XIX)
	and	c, 15	; F53C5D  and C,0x0f
	ld	h, c	; F53C60  ld H,C
	ld	a, (10389:16)	; F53C62  ld A,(0x2895)
	and	a, 15	; F53C66  and A,0x0f
	cp	a, c	; F53C69  cp A,C
	jr	z, Drawbar7_1_3_5ft_Update_Skip2	; F53C6B  jr Z,0xf53cb2
	ld	c, (xix)	; F53C6D  ld C,(XIX)
	and	c, 15	; F53C6F  and C,0x0f
	ld	h, c	; F53C72  ld H,C
	ld	a, (10389:16)	; F53C74  ld A,(0x2895)
	and	a, 15	; F53C78  and A,0x0f
	cp	a, c	; F53C7B  cp A,C
	jr	ule, Drawbar7_1_3_5ft_Update_Skip	; F53C7D  jr ULE,0xf53c90
	ld	c, (xix)	; F53C7F  ld C,(XIX)
	and	c, 15	; F53C81  and C,0x0f
	inc	1, c	; F53C84  inc 1,C
	and	c, 15	; F53C86  and C,0x0f
	and	(xix), 0xf0	; F53C89  and (XIX),0xf0
	or	(xix), c	; F53C8C  or (XIX),C
	jr	Drawbar7_1_3_5ft_Update_Join	; F53C8E  jr T,0xf53c9f
Drawbar7_1_3_5ft_Update_Skip:
	ld	c, (xix)	; F53C90  ld C,(XIX)
	and	c, 15	; F53C92  and C,0x0f
	dec	1, c	; F53C95  dec 1,C
	and	c, 15	; F53C97  and C,0x0f
	and	(xix), 0xf0	; F53C9A  and (XIX),0xf0
	or	(xix), c	; F53C9D  or (XIX),C
Drawbar7_1_3_5ft_Update_Join:
	lda	xbc, (Drawbar7_1_3_5ft_Update:24)	; F53C9F  lda XBC,0xf53c55
	push	xbc	; F53CA4  push XBC
	call	T_CallbackQueue_Post	; F53CA5  call 0xf42e84
	pushw	1	; F53CA9  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53CAC  call 0xf42dc0
	inc	6, xsp	; F53CB0  inc 6,XSP
Drawbar7_1_3_5ft_Update_Skip2:
	lda	xbc, (Bitmap_DrawbarB:24)	; F53CB2  lda XBC,0xf54ac3
	push	xbc	; F53CB7  push XBC
	pushw	27	; F53CB8  push 0x001b
	ld	a, (xix)	; F53CBB  ld A,(XIX)
	and	a, 15	; F53CBD  and A,0x0f
	pushw	wa	; F53CC0  push WA
	calr	Drawbar_DrawColumn	; F53CC1  calr 0xf538b6
	inc	8, xsp	; F53CC4  inc 0,XSP
	pop	xix	; F53CC6  pop XIX
	popw	hl	; F53CC7  pop HL
	ret	; F53CC8  ret

; --------------------------------------------------------------------------
; Drawbar8_1_1_3ft_Update -- drawbar 8 of 9, footage 1 1/3'
; Called from: 0xF5371B; and PaintAllDrawbars (0xF536FF) calls all nine in
;              order.
; What it does: reads the high nibble of (0x289A), compares it with the high
;               nibble of (0x2895), and if they differ writes the value one
;               step nearer, re-arms ITSELF through the timer (`lda
;               XBC,0xF53CC9 / call 0xf42e84 / push 1 / call 0xf42dc0`) and
;               falls into the redraw.  Then it calls Drawbar_DrawColumn
;               with (index = that nibble, column = 31, sprite =
;               Bitmap_DrawbarB).
; Evidence: every field above is read out of this transcription by
;           drawbars() and re-checked by --selftest: `lda XIX,0x289a`, `ld
;           A,(0x2895)`, `push 0x001f` and `lda XBC,0xf54ac3` all occur
;           exactly once in 0xF53CC9-0xF53D57.  The footage is the op-0x20
;           label of DL_DrawbarFootageScale whose screen position is one
;           cell of column 31 (bijection, --selftest check F).
; Note: the sprite split is exact -- the five INTEGER footages (16', 8', 4',
;       2', 1') use Bitmap_DrawbarA and the four FRACTIONAL ones (5 1/3', 2
;       2/3', 1 3/5', 1 1/3') use Bitmap_DrawbarB, with no exception.  It is
;       close to but not equal to the Hammond white/coloured pattern, which
;       would put 16' in the other group, so the two sprites are recorded as
;       A and B and NOT named by colour.
; --------------------------------------------------------------------------
Drawbar8_1_1_3ft_Update:
	pushw	hl	; F53CC9  push HL
	push	xix	; F53CCA  push XIX
	lda	xix, (10394:16)	; F53CCB  lda XIX,0x289a
	ld	c, (xix)	; F53CCF  ld C,(XIX)
	and	c, 240	; F53CD1  and C,0xf0
	srl	c, 4	; F53CD4  srl 0x04,C
	ld	h, c	; F53CD7  ld H,C
	ld	a, (10389:16)	; F53CD9  ld A,(0x2895)
	and	a, 240	; F53CDD  and A,0xf0
	srl	a, 4	; F53CE0  srl 0x04,A
	cp	a, c	; F53CE3  cp A,C
	jr	z, Drawbar8_1_1_3ft_Update_Skip2	; F53CE5  jr Z,0xf53d3e
	ld	c, (xix)	; F53CE7  ld C,(XIX)
	and	c, 240	; F53CE9  and C,0xf0
	srl	c, 4	; F53CEC  srl 0x04,C
	ld	h, c	; F53CEF  ld H,C
	ld	a, (10389:16)	; F53CF1  ld A,(0x2895)
	and	a, 240	; F53CF5  and A,0xf0
	srl	a, 4	; F53CF8  srl 0x04,A
	cp	a, c	; F53CFB  cp A,C
	jr	ule, Drawbar8_1_1_3ft_Update_Skip	; F53CFD  jr ULE,0xf53d16
	ld	c, (xix)	; F53CFF  ld C,(XIX)
	and	c, 240	; F53D01  and C,0xf0
	srl	c, 4	; F53D04  srl 0x04,C
	inc	1, c	; F53D07  inc 1,C
	sll	c, 4	; F53D09  sll 0x04,C
	and	c, 240	; F53D0C  and C,0xf0
	and	(xix), 0x0f	; F53D0F  and (XIX),0x0f
	or	(xix), c	; F53D12  or (XIX),C
	jr	Drawbar8_1_1_3ft_Update_Join	; F53D14  jr T,0xf53d2b
Drawbar8_1_1_3ft_Update_Skip:
	ld	c, (xix)	; F53D16  ld C,(XIX)
	and	c, 240	; F53D18  and C,0xf0
	srl	c, 4	; F53D1B  srl 0x04,C
	dec	1, c	; F53D1E  dec 1,C
	sll	c, 4	; F53D20  sll 0x04,C
	and	c, 240	; F53D23  and C,0xf0
	and	(xix), 0x0f	; F53D26  and (XIX),0x0f
	or	(xix), c	; F53D29  or (XIX),C
Drawbar8_1_1_3ft_Update_Join:
	lda	xbc, (Drawbar8_1_1_3ft_Update:24)	; F53D2B  lda XBC,0xf53cc9
	push	xbc	; F53D30  push XBC
	call	T_CallbackQueue_Post	; F53D31  call 0xf42e84
	pushw	1	; F53D35  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53D38  call 0xf42dc0
	inc	6, xsp	; F53D3C  inc 6,XSP
Drawbar8_1_1_3ft_Update_Skip2:
	lda	xbc, (Bitmap_DrawbarB:24)	; F53D3E  lda XBC,0xf54ac3
	push	xbc	; F53D43  push XBC
	pushw	31	; F53D44  push 0x001f
	ld	a, (xix)	; F53D47  ld A,(XIX)
	and	a, 240	; F53D49  and A,0xf0
	srl	a, 4	; F53D4C  srl 0x04,A
	pushw	wa	; F53D4F  push WA
	calr	Drawbar_DrawColumn	; F53D50  calr 0xf538b6
	inc	8, xsp	; F53D53  inc 0,XSP
	pop	xix	; F53D55  pop XIX
	popw	hl	; F53D56  pop HL
	ret	; F53D57  ret

; --------------------------------------------------------------------------
; Drawbar9_1ft_Update -- drawbar 9 of 9, footage 1'
; Called from: 0xF5371E; and PaintAllDrawbars (0xF536FF) calls all nine in
;              order.
; What it does: reads the low nibble of (0x289B), compares it with the low
;               nibble of (0x2896), and if they differ writes the value one
;               step nearer, re-arms ITSELF through the timer (`lda
;               XBC,0xF53D58 / call 0xf42e84 / push 1 / call 0xf42dc0`) and
;               falls into the redraw.  Then it calls Drawbar_DrawColumn
;               with (index = that nibble, column = 35, sprite =
;               Bitmap_DrawbarA).
; Evidence: every field above is read out of this transcription by
;           drawbars() and re-checked by --selftest: `lda XIX,0x289b`, `ld
;           A,(0x2896)`, `push 0x0023` and `lda XBC,0xf54808` all occur
;           exactly once in 0xF53D58-0xF53DCB.  The footage is the op-0x20
;           label of DL_DrawbarFootageScale whose screen position is one
;           cell of column 35 (bijection, --selftest check F).
; Note: the sprite split is exact -- the five INTEGER footages (16', 8', 4',
;       2', 1') use Bitmap_DrawbarA and the four FRACTIONAL ones (5 1/3', 2
;       2/3', 1 3/5', 1 1/3') use Bitmap_DrawbarB, with no exception.  It is
;       close to but not equal to the Hammond white/coloured pattern, which
;       would put 16' in the other group, so the two sprites are recorded as
;       A and B and NOT named by colour.
; --------------------------------------------------------------------------
Drawbar9_1ft_Update:
	pushw	hl	; F53D58  push HL
	push	xix	; F53D59  push XIX
	lda	xix, (10395:16)	; F53D5A  lda XIX,0x289b
	ld	c, (xix)	; F53D5E  ld C,(XIX)
	and	c, 15	; F53D60  and C,0x0f
	ld	h, c	; F53D63  ld H,C
	ld	a, (10390:16)	; F53D65  ld A,(0x2896)
	and	a, 15	; F53D69  and A,0x0f
	cp	a, c	; F53D6C  cp A,C
	jr	z, Drawbar9_1ft_Update_Skip2	; F53D6E  jr Z,0xf53db5
	ld	c, (xix)	; F53D70  ld C,(XIX)
	and	c, 15	; F53D72  and C,0x0f
	ld	h, c	; F53D75  ld H,C
	ld	a, (10390:16)	; F53D77  ld A,(0x2896)
	and	a, 15	; F53D7B  and A,0x0f
	cp	a, c	; F53D7E  cp A,C
	jr	ule, Drawbar9_1ft_Update_Skip	; F53D80  jr ULE,0xf53d93
	ld	c, (xix)	; F53D82  ld C,(XIX)
	and	c, 15	; F53D84  and C,0x0f
	inc	1, c	; F53D87  inc 1,C
	and	c, 15	; F53D89  and C,0x0f
	and	(xix), 0xf0	; F53D8C  and (XIX),0xf0
	or	(xix), c	; F53D8F  or (XIX),C
	jr	Drawbar9_1ft_Update_Join	; F53D91  jr T,0xf53da2
Drawbar9_1ft_Update_Skip:
	ld	c, (xix)	; F53D93  ld C,(XIX)
	and	c, 15	; F53D95  and C,0x0f
	dec	1, c	; F53D98  dec 1,C
	and	c, 15	; F53D9A  and C,0x0f
	and	(xix), 0xf0	; F53D9D  and (XIX),0xf0
	or	(xix), c	; F53DA0  or (XIX),C
Drawbar9_1ft_Update_Join:
	lda	xbc, (Drawbar9_1ft_Update:24)	; F53DA2  lda XBC,0xf53d58
	push	xbc	; F53DA7  push XBC
	call	T_CallbackQueue_Post	; F53DA8  call 0xf42e84
	pushw	1	; F53DAC  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53DAF  call 0xf42dc0
	inc	6, xsp	; F53DB3  inc 6,XSP
Drawbar9_1ft_Update_Skip2:
	lda	xbc, (Bitmap_DrawbarA:24)	; F53DB5  lda XBC,0xf54808
	push	xbc	; F53DBA  push XBC
	pushw	35	; F53DBB  push 0x0023
	ld	a, (xix)	; F53DBE  ld A,(XIX)
	and	a, 15	; F53DC0  and A,0x0f
	pushw	wa	; F53DC3  push WA
	calr	Drawbar_DrawColumn	; F53DC4  calr 0xf538b6
	inc	8, xsp	; F53DC7  inc 0,XSP
	pop	xix	; F53DC9  pop XIX
	popw	hl	; F53DCA  pop HL
	ret	; F53DCB  ret

; --------------------------------------------------------------------------
; Drawbar_MarkReloadOnSoundEvent
; Called from: thunk slot T_Drawbar_MarkReloadOnSoundEvent
; Evidence: 0xF53DCC is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_MarkReloadOnSoundEvent: T_Drawbar_MarkReloadOnSoundEvent, UiListB_Class00 / 20 (part 0's records): byte index 0, 1 or 0x9B..0x9D -> (0x28A0) = 15.  The byte
;   after the drawbar values at 0x2890 (Drawbar_SendPartParams); this code follows Drawbar9_1ft_Update.
Drawbar_MarkReloadOnSoundEvent:		; <- T_Drawbar_MarkReloadOnSoundEvent
	ld	bc, (UiEvent_Byte1:16)	; F53DCC  ld BC,(0x20b8)
	extz	bc	; F53DD0  extz BC
	cp	bc, 0:i3	; F53DD2  cp BC,0
	jr	z, Drawbar9_1ft_Update_Skip3	; F53DD4  jr Z,0xf53dee
	cp	bc, 1:i3	; F53DD6  cp BC,1
	jr	z, Drawbar9_1ft_Update_Skip3	; F53DD8  jr Z,0xf53dee
	cp	bc, 155	; F53DDA  cp BC,0x009b
	jr	z, Drawbar9_1ft_Update_Skip3	; F53DDE  jr Z,0xf53dee
	cp	bc, 156	; F53DE0  cp BC,0x009c
	jr	z, Drawbar9_1ft_Update_Skip3	; F53DE4  jr Z,0xf53dee
	cp	bc, 157	; F53DE6  cp BC,0x009d
	jr	z, Drawbar9_1ft_Update_Skip3	; F53DEA  jr Z,0xf53dee
	jr	Drawbar9_1ft_Update_Return	; F53DEC  jr T,0xf53df3
Drawbar9_1ft_Update_Skip3:
	ld	(Drawbar_ReloadMark:16), 15	; F53DEE  ld (0x28a0),0x0f
Drawbar9_1ft_Update_Return:
	ret	; F53DF3  ret

; --------------------------------------------------------------------------
; Drawbar_ReloadIfMarked
; Called from: thunk slot T_Drawbar_ReloadIfMarked
; Evidence: 0xF53DF4 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_ReloadIfMarked: T_Drawbar_ReloadIfMarked, in UiEventPassB_TailList: when (0x28A0) is 15, sets it to 240 and calls Drawbar_QueryPart0Byte10 (sends the 6-byte link
;   message 81 00 10 01 01 A3).
Drawbar_ReloadIfMarked:		; <- T_Drawbar_ReloadIfMarked
	cp	(Drawbar_ReloadMark:16), 0x0f	; F53DF4  cp (0x28a0),0x0f
	jr	nz, Drawbar9_1ft_Update_Return2	; F53DF9  jr NZ,0xf53e03
	ld	(Drawbar_ReloadMark:16), 240	; F53DFB  ld (0x28a0),0xf0
	calr	Drawbar_QueryPart0Byte10	; F53E00  calr 0xf540c3
Drawbar9_1ft_Update_Return2:
	ret	; F53E03  ret

; --------------------------------------------------------------------------
; Drawbar_OnCpu2Reply
; Called from: thunk slot T_Drawbar_OnCpu2Reply
; Evidence: 0xF53E04 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_OnCpu2Reply: T_Drawbar_OnCpu2Reply, called by prom_a's link-reply handler Cpu2Reply_HandleNext when the reply's tag (0x2335) is 0xA3: for a part-0
;   reply tagged 0xA3, server 0x81 offset 0x10 sets Drawbar_ReloadMark from the byte's bits 6-7 (0 -> 0; 0x40 -> 1,
;   Drawbar_QueryElementBlocks(0) and (0x2890) / (0x2891) = 0; 0x80 -> 2); 0x82 / 0x83 replies go to their own arms;
;   on screen 0xA3 a repaint is requested.  Basis: body + caller.
Drawbar_OnCpu2Reply:		; <- T_Drawbar_OnCpu2Reply
	push	xix	; F53E04  push XIX
	lda	xix, (9008:16)	; F53E05  lda XIX,0x2330
	extz	xix	; F53E09  extz XIX
	ld	c, (xix+1)	; F53E0B  ld C,(XIX+0x01)
	cp	c, 0:i3	; F53E0E  cp C,0
	jrl	nz, Drawbar9_1ft_Update_Epilogue	; F53E10  jrl NZ,0xf5404f
	extz	xix	; F53E13  extz XIX
	ld	c, (xix+5)	; F53E15  ld C,(XIX+0x05)
	cp	c, 163	; F53E18  cp C,0xa3
	jrl	nz, Drawbar9_1ft_Update_Epilogue	; F53E1B  jrl NZ,0xf5404f
	ld	c, (xix)	; F53E1E  ld C,(XIX)
	extz	bc	; F53E20  extz BC
	cp	bc, 128	; F53E22  cp BC,0x0080
	jrl	z, Drawbar9_1ft_Update_Epilogue	; F53E26  jrl Z,0xf5404f
	cp	bc, 129	; F53E29  cp BC,0x0081
	jr	z, Drawbar9_1ft_Update_Skip4	; F53E2D  jr Z,0xf53e40
	cp	bc, 130	; F53E2F  cp BC,0x0082
	jrl	z, Drawbar9_1ft_Update_Skip7	; F53E33  jrl Z,0xf53ea9
	cp	bc, 131	; F53E36  cp BC,0x0083
	jrl	z, Drawbar9_1ft_Update_Join6	; F53E3A  jrl Z,0xf53f90
	jrl	Drawbar9_1ft_Update_Epilogue	; F53E3D  jrl T,0xf5404f
Drawbar9_1ft_Update_Skip4:
	extz	xix	; F53E40  extz XIX
	ld	c, (xix+2)	; F53E42  ld C,(XIX+0x02)
	cp	c, 16	; F53E45  cp C,0x10
	jrl	nz, Drawbar9_1ft_Update_Epilogue	; F53E48  jrl NZ,0xf5404f
	extz	xix	; F53E4B  extz XIX
	ld	c, (xix+6)	; F53E4D  ld C,(XIX+0x06)
	and	c, 192	; F53E50  and C,0xc0
	extz	bc	; F53E53  extz BC
	cp	bc, 0:i3	; F53E55  cp BC,0
	jr	z, Drawbar9_1ft_Update_Join2	; F53E57  jr Z,0xf53e86
	cp	bc, 64	; F53E59  cp BC,0x0040
	jr	z, Drawbar9_1ft_Update_Skip5	; F53E5D  jr Z,0xf53e67
	cp	bc, 128	; F53E5F  cp BC,0x0080
	jr	z, Drawbar9_1ft_Update_Skip6	; F53E63  jr Z,0xf53e7f
	jr	Drawbar9_1ft_Update_Join2	; F53E65  jr T,0xf53e86
Drawbar9_1ft_Update_Skip5:
	ld	(Drawbar_ReloadMark:16), 1	; F53E67  ld (0x28a0),0x01
	pushw	0	; F53E6C  push 0x0000
	calr	Drawbar_QueryElementBlocks	; F53E6F  calr 0xf54051
	ld	(10384:16), 0	; F53E72  ld (0x2890),0x00
	ld	(10385:16), 0	; F53E77  ld (0x2891),0x00
	popw	bc	; F53E7C  pop BC
	jr	Drawbar9_1ft_Update_Join3	; F53E7D  jr T,0xf53e8d
Drawbar9_1ft_Update_Skip6:
	ld	(Drawbar_ReloadMark:16), 2	; F53E7F  ld (0x28a0),0x02
	jr	Drawbar9_1ft_Update_Join4	; F53E84  jr T,0xf53e95
Drawbar9_1ft_Update_Join2:
	ld	(Drawbar_ReloadMark:16), 0	; F53E86  ld (0x28a0),0x00
	jr	Drawbar9_1ft_Update_Join4	; F53E8B  jr T,0xf53e95
Drawbar9_1ft_Update_Join3:
	cp	(Drawbar_ReloadMark:16), 0x01	; F53E8D  cp (0x28a0),0x01
	jrl	z, Drawbar9_1ft_Update_Epilogue	; F53E92  jrl Z,0xf5404f
Drawbar9_1ft_Update_Join4:
	cp	(UI_ScreenId:16), 0xa3	; F53E95  cp (0x207c),0xa3
	jrl	nz, Drawbar9_1ft_Update_Epilogue	; F53E9A  jrl NZ,0xf5404f
	set	1, (UI_Request_Hi:16)	; F53E9D  set 1,(0x2071)
	ld	(UI_Request:16), 1	; F53EA1  ld (0x2070),0x01
	jrl	Drawbar9_1ft_Update_Epilogue	; F53EA6  jrl T,0xf5404f
Drawbar9_1ft_Update_Skip7:
	extz	xix	; F53EA9  extz XIX
	ld	c, (xix+2)	; F53EAB  ld C,(XIX+0x02)
	extz	bc	; F53EAE  extz BC
	cp	bc, 2:i3	; F53EB0  cp BC,2
	jr	z, Drawbar9_1ft_Update_Skip8	; F53EB2  jr Z,0xf53ebd
	cp	bc, 130	; F53EB4  cp BC,0x0082
	jr	z, Drawbar9_1ft_Update_Skip9	; F53EB8  jr Z,0xf53f0f
	jrl	Drawbar9_1ft_Update_Join6	; F53EBA  jrl T,0xf53f90
Drawbar9_1ft_Update_Skip8:
	extz	xix	; F53EBD  extz XIX
	ld	c, (xix+7)	; F53EBF  ld C,(XIX+0x07)
	and	c, 15	; F53EC2  and C,0x0f
	and	c, 15	; F53EC5  and C,0x0f
	and	(0x2895:16), 0xf0	; F53EC8  and (0x2895),0xf0
	or	(10389:16), c	; F53ECD  or (0x2895),C
	ld	c, (xix+6)	; F53ED1  ld C,(XIX+0x06)
	ld	(10386:16), c	; F53ED4  ld (0x2892),C
	cp	(UI_ScreenId:16), 0xa3	; F53ED8  cp (0x207c),0xa3
	jrl	nz, Drawbar9_1ft_Update_Join6	; F53EDD  jrl NZ,0xf53f90
	lda	xbc, (Drawbar1_16ft_Update:24)	; F53EE0  lda XBC,0xf5394c
	push	xbc	; F53EE5  push XBC
	call	T_CallbackQueue_Post	; F53EE6  call 0xf42e84
	pushw	1	; F53EEA  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53EED  call 0xf42dc0
	lda	xbc, (Drawbar3_8ft_Update:24)	; F53EF1  lda XBC,0xf53a34
	push	xbc	; F53EF6  push XBC
	call	T_CallbackQueue_Post	; F53EF7  call 0xf42e84
	pushw	1	; F53EFB  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53EFE  call 0xf42dc0
	inc	8, xsp	; F53F02  inc 0,XSP
	inc	4, xsp	; F53F04  inc 4,XSP
	lda	xbc, (Drawbar7_1_3_5ft_Update:24)	; F53F06  lda XBC,0xf53c55
	push	xbc	; F53F0B  push XBC
	jrl	Drawbar9_1ft_Update_Join5	; F53F0C  jrl T,0xf53f83
Drawbar9_1ft_Update_Skip9:
	extz	xix	; F53F0F  extz XIX
	ld	c, (xix+7)	; F53F11  ld C,(XIX+0x07)
	and	c, 15	; F53F14  and C,0x0f
	and	c, 15	; F53F17  and C,0x0f
	and	(0x2896:16), 0xf0	; F53F1A  and (0x2896),0xf0
	or	(10390:16), c	; F53F1F  or (0x2896),C
	ld	c, (xix+6)	; F53F23  ld C,(XIX+0x06)
	srl	c, 4	; F53F26  srl 0x04,C
	and	c, 15	; F53F29  and C,0x0f
	sll	c, 4	; F53F2C  sll 0x04,C
	and	c, 240	; F53F2F  and C,0xf0
	and	(0x2894:16), 0x0f	; F53F32  and (0x2894),0x0f
	or	(10388:16), c	; F53F37  or (0x2894),C
	ld	c, (xix+6)	; F53F3B  ld C,(XIX+0x06)
	and	c, 15	; F53F3E  and C,0x0f
	sll	c, 4	; F53F41  sll 0x04,C
	and	c, 240	; F53F44  and C,0xf0
	and	(0x2893:16), 0x0f	; F53F47  and (0x2893),0x0f
	or	(10387:16), c	; F53F4C  or (0x2893),C
	cp	(UI_ScreenId:16), 0xa3	; F53F50  cp (0x207c),0xa3
	jr	nz, Drawbar9_1ft_Update_Join6	; F53F55  jr NZ,0xf53f90
	lda	xbc, (Drawbar4_4ft_Update:24)	; F53F57  lda XBC,0xf53ac3
	push	xbc	; F53F5C  push XBC
	call	T_CallbackQueue_Post	; F53F5D  call 0xf42e84
	pushw	1	; F53F61  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53F64  call 0xf42dc0
	lda	xbc, (Drawbar6_2ft_Update:24)	; F53F68  lda XBC,0xf53bc6
	push	xbc	; F53F6D  push XBC
	call	T_CallbackQueue_Post	; F53F6E  call 0xf42e84
	pushw	1	; F53F72  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53F75  call 0xf42dc0
	inc	8, xsp	; F53F79  inc 0,XSP
	inc	4, xsp	; F53F7B  inc 4,XSP
	lda	xbc, (Drawbar9_1ft_Update:24)	; F53F7D  lda XBC,0xf53d58
	push	xbc	; F53F82  push XBC
Drawbar9_1ft_Update_Join5:
	call	T_CallbackQueue_Post	; F53F83  call 0xf42e84
	pushw	1	; F53F87  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53F8A  call 0xf42dc0
	inc	6, xsp	; F53F8E  inc 6,XSP
Drawbar9_1ft_Update_Join6:
	extz	xix	; F53F90  extz XIX
	ld	c, (xix+2)	; F53F92  ld C,(XIX+0x02)
	extz	bc	; F53F95  extz BC
	cp	bc, 2:i3	; F53F97  cp BC,2
	jr	z, Drawbar9_1ft_Update_Skip10	; F53F99  jr Z,0xf53fa5
	cp	bc, 130	; F53F9B  cp BC,0x0082
	jrl	z, Drawbar9_1ft_Update_Skip11	; F53F9F  jrl Z,0xf54025
	jrl	Drawbar9_1ft_Update_Epilogue	; F53FA2  jrl T,0xf5404f
Drawbar9_1ft_Update_Skip10:
	extz	xix	; F53FA5  extz XIX
	ld	c, (xix+7)	; F53FA7  ld C,(XIX+0x07)
	and	c, 15	; F53FAA  and C,0x0f
	sll	c, 4	; F53FAD  sll 0x04,C
	and	c, 240	; F53FB0  and C,0xf0
	and	(0x2895:16), 0x0f	; F53FB3  and (0x2895),0x0f
	or	(10389:16), c	; F53FB8  or (0x2895),C
	ld	c, (xix+6)	; F53FBC  ld C,(XIX+0x06)
	srl	c, 4	; F53FBF  srl 0x04,C
	and	c, 15	; F53FC2  and C,0x0f
	and	c, 15	; F53FC5  and C,0x0f
	and	(0x2894:16), 0xf0	; F53FC8  and (0x2894),0xf0
	or	(10388:16), c	; F53FCD  or (0x2894),C
	ld	c, (xix+6)	; F53FD1  ld C,(XIX+0x06)
	and	c, 15	; F53FD4  and C,0x0f
	and	c, 15	; F53FD7  and C,0x0f
	and	(0x2893:16), 0xf0	; F53FDA  and (0x2893),0xf0
	or	(10387:16), c	; F53FDF  or (0x2893),C
	cp	(UI_ScreenId:16), 0xa3	; F53FE3  cp (0x207c),0xa3
	jr	nz, Drawbar9_1ft_Update_Epilogue	; F53FE8  jr NZ,0xf5404f
	lda	xbc, (Drawbar2_5_1_3ft_Update:24)	; F53FEA  lda XBC,0xf539c0
	push	xbc	; F53FEF  push XBC
	call	T_CallbackQueue_Post	; F53FF0  call 0xf42e84
	pushw	1	; F53FF4  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F53FF7  call 0xf42dc0
	lda	xbc, (Drawbar5_2_2_3ft_Update:24)	; F53FFB  lda XBC,0xf53b52
	push	xbc	; F54000  push XBC
	call	T_CallbackQueue_Post	; F54001  call 0xf42e84
	pushw	1	; F54005  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F54008  call 0xf42dc0
	lda	xbc, (Drawbar8_1_1_3ft_Update:24)	; F5400C  lda XBC,0xf53cc9
	push	xbc	; F54011  push XBC
	call	T_CallbackQueue_Post	; F54012  call 0xf42e84
	pushw	1	; F54016  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F54019  call 0xf42dc0
	add	xsp, 18	; F5401D  add XSP,0x00000012
	jr	Drawbar9_1ft_Update_Epilogue	; F54023  jr T,0xf5404f
Drawbar9_1ft_Update_Skip11:
	extz	xix	; F54025  extz XIX
	ld	c, (xix+6)	; F54027  ld C,(XIX+0x06)
	and	c, 1	; F5402A  and C,0x01
	.byte 0xCB, 0x23, 0x00	; F5402D  ldcf 0x00,C   [llvm-mc cannot encode this]
	stcf	4, (0x2896:16)	; F54030  stcf 4,(0x2896)
	ld	c, (xix+6)	; F54034  ld C,(XIX+0x06)
	srl	c, 1	; F54037  srl 0x01,C
	and	c, 1	; F5403A  and C,0x01
	.byte 0xCB, 0x23, 0x00	; F5403D  ldcf 0x00,C   [llvm-mc cannot encode this]
	stcf	5, (0x2896:16)	; F54040  stcf 5,(0x2896)
	cp	(UI_ScreenId:16), 0xa3	; F54044  cp (0x207c),0xa3
	jr	nz, Drawbar9_1ft_Update_Epilogue	; F54049  jr NZ,0xf5404f
	set	4, (UI_ScreenFlags:16)	; F5404B  set 4,(0x2095)
Drawbar9_1ft_Update_Epilogue:
	pop	xix	; F5404F  pop XIX
	ret	; F54050  ret

; --------------------------------------------------------------------------
; Drawbar_QueryElementBlocks
; Called from: call from 0xF53E6F
; Evidence: 0xF54051 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_QueryElementBlocks: (part): four requests tagged 0xA3 on reply channel 1 -- [0x82, part, 2, 2] and [0x82, part, 0x82, 2], then the same
;   with 0x83 -- to LinkQuery_ReplyElementBlockBytes_Elements01 / _Elements23.  Basis: protocol pairing.
Drawbar_QueryElementBlocks:
	link XIZ,0xfffa	; F54051  link XIZ,0xfffa
	push	xix	; F54055  push XIX
	lda	xix, (xiz-6)	; F54056  lda XIX,XIZ+0xfa
	ld	(xix), 130	; F54059  ld (XIX),0x82
	ld	c, (xiz+8)	; F5405C  ld C,(XIZ+0x08)
	ld	(xix+1), c	; F5405F  ld (XIX+0x01),C
	ld	(xix+2), 2	; F54062  ld (XIX+0x02),0x02
	ld	(xix+3), 2	; F54066  ld (XIX+0x03),0x02
	ld	(xix+4), 1	; F5406A  ld (XIX+0x04),0x01
	ld	(xix+5), 163	; F5406E  ld (XIX+0x05),0xa3
	push	xix	; F54072  push XIX
	pushw	6	; F54073  push 0x0006
	pushw	0	; F54076  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F54079  call 0xf40ed4
	ld	(xix+2), 130	; F5407D  ld (XIX+0x02),0x82
	ld	(xix+3), 2	; F54081  ld (XIX+0x03),0x02
	push	xix	; F54085  push XIX
	pushw	6	; F54086  push 0x0006
	pushw	0	; F54089  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F5408C  call 0xf40ed4
	ld	(xix), 131	; F54090  ld (XIX),0x83
	ld	(xix+2), 2	; F54093  ld (XIX+0x02),0x02
	ld	(xix+3), 2	; F54097  ld (XIX+0x03),0x02
	push	xix	; F5409B  push XIX
	pushw	6	; F5409C  push 0x0006
	pushw	0	; F5409F  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F540A2  call 0xf40ed4
	ld	(xix+2), 130	; F540A6  ld (XIX+0x02),0x82
	ld	(xix+3), 2	; F540AA  ld (XIX+0x03),0x02
	push	xix	; F540AE  push XIX
	pushw	6	; F540AF  push 0x0006
	pushw	0	; F540B2  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F540B5  call 0xf40ed4
	add	xsp, 32	; F540B9  add XSP,0x00000020
	pop	xix	; F540BF  pop XIX
	unlk XIZ	; F540C0  unlk XIZ
	ret	; F540C2  ret

; --------------------------------------------------------------------------
; Drawbar_QueryPart0Byte10
; Called from: call from 0xF53E00
; Evidence: 0xF540C3 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_QueryPart0Byte10: [0x81, 0, 0x10, 1, 1, 0xA3]: one byte of part 0's record at offset 0x10 (LinkQuery_ReplyPartRecordBytes), reply
;   channel 1, tagged 0xA3 -- the DRAWBAR screen's id, which Drawbar_OnCpu2Reply checks.  Called by
;   Drawbar_ReloadIfMarked.  Basis: protocol pairing + callers.
Drawbar_QueryPart0Byte10:
	link XIZ,0xfffa	; F540C3  link XIZ,0xfffa
	push	xix	; F540C7  push XIX
	lda	xix, (xiz-6)	; F540C8  lda XIX,XIZ+0xfa
	ld	(xix), 129	; F540CB  ld (XIX),0x81
	ld	(xix+1), 0	; F540CE  ld (XIX+0x01),0x00
	ld	(xix+2), 16	; F540D2  ld (XIX+0x02),0x10
	ld	(xix+3), 1	; F540D6  ld (XIX+0x03),0x01
	ld	(xix+4), 1	; F540DA  ld (XIX+0x04),0x01
	ld	(xix+5), 163	; F540DE  ld (XIX+0x05),0xa3
	push	xix	; F540E2  push XIX
	pushw	6	; F540E3  push 0x0006
	pushw	0	; F540E6  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F540E9  call 0xf40ed4
	inc	8, xsp	; F540ED  inc 0,XSP
	pop	xix	; F540EF  pop XIX
	unlk XIZ	; F540F0  unlk XIZ
	ret	; F540F2  ret

; --------------------------------------------------------------------------
; Drawbar_SendPartParams
; Called from: call from 0xF53436, 0xF53478, 0xF534C3, 0xF5350E, 0xF53550,
;              0xF5359B, +3 more
; Evidence: 0xF540F3 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_SendPartParams: (part), from the DRAWBAR screen's page and soft keys: [0xB0, part, 0x78, 0] over the link, then the seven bytes at
;   0x2890.. as 6-byte messages [0x88, part, p, 0, value, 0] for p = 11, 12, 4, 5, 6, 7, 8, then T_PartNotes_ResoundOnToneGen
;   (PartNotes_ResoundOnToneGen) with source 0xFF so that held notes sound again.
Drawbar_SendPartParams:
	link XIZ,0xfff6	; F540F3  link XIZ,0xfff6
	pushw	hl	; F540F7  push HL
	push	xix	; F540F8  push XIX
	lda	xix, (xiz-10)	; F540F9  lda XIX,XIZ+0xf6
	ld	l, (xiz+8)	; F540FC  ld L,(XIZ+0x08)
	ldw	bc, 10384	; F540FF  ld BC,0x2890
	extz	xbc	; F54102  extz XBC
	ld	(xiz-4), xbc	; F54104  ld (XIZ+0xfc),XBC
	ld	(xix), 176	; F54107  ld (XIX),0xb0
	ld	(xix+1), l	; F5410A  ld (XIX+0x01),L
	ld	(xix+2), 120	; F5410D  ld (XIX+0x02),0x78
	ld	(xix+3), 0	; F54111  ld (XIX+0x03),0x00
	push	xix	; F54115  push XIX
	pushw	4	; F54116  push 0x0004
	pushw	0	; F54119  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F5411C  call 0xf40ed4
	ld	(xix), 136	; F54120  ld (XIX),0x88
	ld	(xix+1), l	; F54123  ld (XIX+0x01),L
	ld	(xix+3), 0	; F54126  ld (XIX+0x03),0x00
	ld	(xix+5), 0	; F5412A  ld (XIX+0x05),0x00
	ld	h, 11:opc	; F5412E  ld H,0x0b
	inc	8, xsp	; F54130  inc 0,XSP
Drawbar_SendPartParams_Loop:
	ld	(xix+2), h	; F54132  ld (XIX+0x02),H
	ld	xbc, (xiz-4)	; F54135  ld XBC,(XIZ+0xfc)
	ld	a, (xbc)	; F54138  ld A,(XBC)
	ld	(xix+4), a	; F5413A  ld (XIX+0x04),A
	push	xix	; F5413D  push XIX
	pushw	6	; F5413E  push 0x0006
	pushw	0	; F54141  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F54144  call 0xf40ed4
	sub	xbc, xbc	; F54148  sub XBC,XBC
	inc	1, xbc	; F5414A  inc 1,XBC
	add	(xiz-4), xbc	; F5414C  add (XIZ+0xfc),XBC
	add	h, c	; F5414F  add H,C
	inc	8, xsp	; F54151  inc 0,XSP
	cp	h, 12	; F54153  cp H,0x0c
	jr	ule, Drawbar_SendPartParams_Loop	; F54156  jr ULE,0xf54132
	ld	h, 4:opc	; F54158  ld H,0x04
Drawbar_SendPartParams_Loop2:
	ld	(xix+2), h	; F5415A  ld (XIX+0x02),H
	ld	xbc, (xiz-4)	; F5415D  ld XBC,(XIZ+0xfc)
	ld	a, (xbc)	; F54160  ld A,(XBC)
	ld	(xix+4), a	; F54162  ld (XIX+0x04),A
	push	xix	; F54165  push XIX
	pushw	6	; F54166  push 0x0006
	pushw	0	; F54169  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F5416C  call 0xf40ed4
	sub	xbc, xbc	; F54170  sub XBC,XBC
	inc	1, xbc	; F54172  inc 1,XBC
	add	(xiz-4), xbc	; F54174  add (XIZ+0xfc),XBC
	add	h, c	; F54177  add H,C
	inc	8, xsp	; F54179  inc 0,XSP
	cp	h, 8	; F5417B  cp H,0x08
	jr	ule, Drawbar_SendPartParams_Loop2	; F5417E  jr ULE,0xf5415a
	pushw	hl	; F54180  push HL
	pushw	255	; F54181  push 0x00ff
	call	T_PartNotes_ResoundOnToneGen	; F54184  call 0xf413d8
	pop	xbc	; F54188  pop XBC
	pop	xix	; F54189  pop XIX
	popw	hl	; F5418A  pop HL
	unlk XIZ	; F5418B  unlk XIZ
	ret	; F5418D  ret

; --------------------------------------------------------------------------
; Drawbar_SendSettingBytes
; Called from: call from 0xF5325A, 0xF532B5, 0xF53316, 0xF53377, 0xF533D2
; Evidence: 0xF5418E is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_SendSettingBytes: Sends three ToneEdit writes to CPU 2 for part arg (0x289C): [0x88, part, 11, 0, (0x2890),
;   0], [.., 12, .., (0x2891), ..] and [.., 8, .., (0x2896), ..] -- the setting-page nibbles and the row-flag byte; a
;   subset of Drawbar_SendPartParams (opcodes 11, 12, 4..8). Called after DrawbarScreen_ToggleRowFlag and the four
;   DrawbarSettingPage_RowStepHandlers nibble steppers change them. Basis: callers + body + full-send twin. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_l.json)
Drawbar_SendSettingBytes:
	link XIZ,0xfff2	; F5418E  link XIZ,0xfff2
	pushw	hl	; F54192  push HL
	push	xix	; F54193  push XIX
	lda	xix, (xiz-10)	; F54194  lda XIX,XIZ+0xf6
	ldw	bc, 10384	; F54197  ld BC,0x2890
	extz	xbc	; F5419A  extz XBC
	ld	(xiz-4), xbc	; F5419C  ld (XIZ+0xfc),XBC
	ld	(xix), 136	; F5419F  ld (XIX),0x88
	ld	c, (xiz+8)	; F541A2  ld C,(XIZ+0x08)
	ld	(xix+1), c	; F541A5  ld (XIX+0x01),C
	ld	(xix+3), 0	; F541A8  ld (XIX+0x03),0x00
	ld	(xix+5), 0	; F541AC  ld (XIX+0x05),0x00
	ld	h, 11:opc	; F541B0  ld H,0x0b
Drawbar_SendSettingBytes_Loop:
	ld	(xix+2), h	; F541B2  ld (XIX+0x02),H
	ld	xbc, (xiz-4)	; F541B5  ld XBC,(XIZ+0xfc)
	ld	a, (xbc)	; F541B8  ld A,(XBC)
	ld	(xix+4), a	; F541BA  ld (XIX+0x04),A
	push	xix	; F541BD  push XIX
	pushw	6	; F541BE  push 0x0006
	pushw	0	; F541C1  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F541C4  call 0xf40ed4
	sub	xbc, xbc	; F541C8  sub XBC,XBC
	inc	1, xbc	; F541CA  inc 1,XBC
	add	(xiz-4), xbc	; F541CC  add (XIZ+0xfc),XBC
	add	h, c	; F541CF  add H,C
	inc	8, xsp	; F541D1  inc 0,XSP
	cp	h, 12	; F541D3  cp H,0x0c
	jr	ule, Drawbar_SendSettingBytes_Loop	; F541D6  jr ULE,0xf541b2
	ld	xwa, (xiz-4)	; F541D8  ld XWA,(XIZ+0xfc)
	inc	4, xwa	; F541DB  inc 4,XWA
	ld	(xiz-14), xwa	; F541DD  ld (XIZ+0xf2),XWA
	ld	(xix+2), 8	; F541E0  ld (XIX+0x02),0x08
	ld	xbc, (xiz-14)	; F541E4  ld XBC,(XIZ+0xf2)
	ld	a, (xbc)	; F541E7  ld A,(XBC)
	ld	(xix+4), a	; F541E9  ld (XIX+0x04),A
	push	xix	; F541EC  push XIX
	pushw	6	; F541ED  push 0x0006
	pushw	0	; F541F0  push 0x0000
	call	T_Link_SendBlockIn32ByteChunks	; F541F3  call 0xf40ed4
	inc	8, xsp	; F541F7  inc 0,XSP
	pop	xix	; F541F9  pop XIX
	popw	hl	; F541FA  pop HL
	unlk XIZ	; F541FB  unlk XIZ
	ret	; F541FD  ret

; --------------------------------------------------------------------------
; RetStub_F53000_Nop
; Called from: call from 0xF53016
; Evidence: 0xF541FE is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Purpose: none -- the entry is a lone `ret`.  Named RetStub_F53000_Nop after what reaches it
;          (was sub_F541FE; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
RetStub_F53000_Nop:
	ret	; F541FE  ret

; --------------------------------------------------------------------------
; Drawbar_EnterScreenIfMarked
; Called from: thunk slot T_Drawbar_EnterScreenIfMarked
; Evidence: 0xF541FF is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_EnterScreenIfMarked: Waits for CPU 2's reply mark (Drawbar_WaitReloadMark); when it is 1 requests screen
;   0xA3, DRAWBAR (UI_Request = 0x80A3). SOUND MODE runs it on install (unless it came back from 0xA3) and on
;   LcdKeyRow1's lower switch. Basis: callers + body. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
Drawbar_EnterScreenIfMarked:		; <- T_Drawbar_EnterScreenIfMarked
	calr	Drawbar_WaitReloadMark	; F541FF  calr 0xf54210
	cp	a, 1:i3	; F54202  cp A,1
	jr	nz, Drawbar_EnterScreenIfMarked_Return	; F54204  jr NZ,0xf5420f
	set	7, (UI_Request_Hi:16)	; F54206  set 7,(0x2071)
	ld	(UI_Request:16), 163	; F5420A  ld (0x2070),0xa3
Drawbar_EnterScreenIfMarked_Return:
	ret	; F5420F  ret

; --------------------------------------------------------------------------
; Drawbar_WaitReloadMark
; Called from: thunk slot T_Drawbar_WaitReloadMark; call from 0xF541FF
; Evidence: 0xF54210 is an instruction boundary of this transcription, re-
;           asserted on every emit, and the reference above names it.  That
;           is ALL the name rests on -- the name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; Drawbar_WaitReloadMark: Polls Drawbar_ReloadMark while it is 0x0F (reload requested) or 0xF0 (query sent), draining
;   Ring608A0A between polls, and returns A = the mark the CPU-2 reply left (0/1/2, Drawbar_OnCpu2Reply), or 0 after
;   10,000 polls. Callers branch on 1 (DRAWBAR, screen 0xA3) and 2. Basis: callers + body. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_b.json)
Drawbar_WaitReloadMark:		; <- T_Drawbar_WaitReloadMark
	pushw	hl	; F54210  push HL
	push	xix	; F54211  push XIX
	lda	xix, (Drawbar_ReloadMark:16)	; F54212  lda XIX,0x28a0
	ldw	hl, 0	; F54216  ld HL,0x0000
Drawbar_WaitReloadMark_Loop:
	ld	c, (xix)	; F54219  ld C,(XIX)
	cp	c, 15	; F5421B  cp C,0x0f
	jr	z, Drawbar_WaitReloadMark_Skip	; F5421E  jr Z,0xf54227
	ld	c, (xix)	; F54220  ld C,(XIX)
	cp	c, 240	; F54222  cp C,0xf0
	jr	nz, Drawbar_WaitReloadMark_Skip3	; F54225  jr NZ,0xf54241
Drawbar_WaitReloadMark_Skip:
	inc	1, hl	; F54227  inc 1,HL
	cp	hl, 10000	; F54229  cp HL,0x2710
	jr	nc, Drawbar_WaitReloadMark_Skip2	; F5422D  jr NC,0xf5423d
	call	T_Ring608A0A_IsEmpty	; F5422F  call 0xf41cdc
	cp	wa, 0:i3	; F54233  cp WA,0
	jr	z, Drawbar_WaitReloadMark_Loop	; F54235  jr Z,0xf54219
	call	T_Ring608A0A_DrainAll	; F54237  call 0xf42380
	jr	Drawbar_WaitReloadMark_Loop	; F5423B  jr T,0xf54219
Drawbar_WaitReloadMark_Skip2:
	sub	a, a	; F5423D  sub A,A
	jr	Drawbar_WaitReloadMark_Epilogue	; F5423F  jr T,0xf54245
Drawbar_WaitReloadMark_Skip3:
	ld	c, (xix)	; F54241  ld C,(XIX)
	ld	a, c	; F54243  ld A,C
Drawbar_WaitReloadMark_Epilogue:
	pop	xix	; F54245  pop XIX
	popw	hl	; F54246  pop HL
	ret	; F54247  ret

; --- 0xF54248-0xF542A3  romtab (92 bytes) ---

; --------------------------------------------------------------------------
; PanelButtonTable_DrawbarScreen -- 23 pointers, the module's message table
; Read by: prom_b 0xF5303D `add XWA,0x00f54248`, after `mul A,4` in
;          DrawbarScreen_Dispatch.
; Entries: 23, 15 distinct.  9 of them are the image-wide default thunk slot
;          0x00F42C70, which this file already records at 0xF55000 as
;          pointing at a bare `ret`; ⚠ only the last 6 are a trailing run --
;          the other 3 sit at indices 10, 13, 14, INSIDE the live entries,
;          so the table is sparse and not merely short.
; Entry count: 23, and ⚠ CORRECTED round 11 -- this paragraph used to end
;              "Nothing in the code bounds the index, so 23 is a READING of
;              the data, not a measurement of the table."  SOMETHING BOUNDS
;              IT.  DrawbarScreen_Dispatch calls PanelCode_ToSlotAndFlags
;              (0xF55019) before `mul A,4`, and that routine rejects a raw
;              index above 0x1F (`cp HL,0x001f` at 0xF55026) and then folds
;              what is left -- 0x11..0x19 lose 0x11, 0x1A..0x1F lose 9 -- so
;              the index space really is 0..22.  ★ And the table agrees: the
;              five slots whose raw codes NOTHING delivers (14, 17, 19, 20,
;              22 <- codes 0x0E, 0x1A, 0x1C, 0x1D, 0x1F) hold the default
;              thunk here and in all four of this file's 23-entry tables --
;              20 of 20 -- while slot 15, raw code 0x0F, the EXIT key, is
;              filled in all four.  notes/prom_b_panel_names_round11.py
;              --selftest.
; Evidence: the reader above; and every one of the 14 in-span entries lands
;           on an instruction boundary of this transcription (--selftest
;           check B), which a mis-framed table would not do.
; --------------------------------------------------------------------------
PanelButtonTable_DrawbarScreen:
	.long SoftKeyCol1_DrawbarScreen                       ; F54248  [0]   -> SoftKeyCol1_DrawbarScreen
	.long SoftKeyCol2_DrawbarScreen                       ; F5424C  [1]   -> SoftKeyCol2_DrawbarScreen
	.long SoftKeyCol3_DrawbarScreen                       ; F54250  [2]   -> SoftKeyCol3_DrawbarScreen
	.long SoftKeyCol4_DrawbarScreen                       ; F54254  [3]   -> SoftKeyCol4_DrawbarScreen
	.long SoftKeyCol5_DrawbarScreen                       ; F54258  [4]   -> SoftKeyCol5_DrawbarScreen
	.long SoftKeyCol6_DrawbarScreen                       ; F5425C  [5]   -> SoftKeyCol6_DrawbarScreen
	.long SoftKeyCol7_DrawbarScreen                       ; F54260  [6]   -> SoftKeyCol7_DrawbarScreen
	.long SoftKeyCol8_DrawbarScreen                       ; F54264  [7]   -> SoftKeyCol8_DrawbarScreen
	.long LcdKeyRow1_DrawbarScreen                       ; F54268  [8]   -> LcdKeyRow1_DrawbarScreen
	.long LcdKeyRow2_DrawbarScreen                       ; F5426C  [9]   -> LcdKeyRow2_DrawbarScreen
	.long T_TableDefault_Ret                       ; F54270  [10]   -> prom_b 0xF42C70
	.long LcdKeyRow4_DrawbarScreen                       ; F54274  [11]   -> LcdKeyRow4_DrawbarScreen
	.long LcdKeyRow5_DrawbarScreen                       ; F54278  [12]   -> LcdKeyRow5_DrawbarScreen
	.long T_TableDefault_Ret                       ; F5427C  [13]   -> prom_b 0xF42C70
	.long T_TableDefault_Ret                       ; F54280  [14]   -> prom_b 0xF42C70
	.long ExitKey_DrawbarScreen                       ; F54284  [15]   -> ExitKey_DrawbarScreen
	.long PageKey_DrawbarScreen                       ; F54288  [16]   -> PageKey_DrawbarScreen
	.long T_TableDefault_Ret                       ; F5428C  [17]   -> prom_b 0xF42C70
	.long T_TableDefault_Ret                       ; F54290  [18]   -> prom_b 0xF42C70
	.long T_TableDefault_Ret                       ; F54294  [19]   -> prom_b 0xF42C70
	.long T_TableDefault_Ret                       ; F54298  [20]   -> prom_b 0xF42C70
	.long T_TableDefault_Ret                       ; F5429C  [21]   -> prom_b 0xF42C70
	.long T_TableDefault_Ret                       ; F542A0  [22]   -> prom_b 0xF42C70

; --- 0xF542A4-0xF542D0  data (45 bytes) ---

; --------------------------------------------------------------------------
; Table_F542A4 -- nine 32-bit words of zero in front of DrawbarRowOffsets
; Evidence: read from the ROM.  If they were empty slots of
;           PanelButtonTable_DrawbarScreen that table would have 32 entries and end at
;           0xF542C8.
; ⚠ CORRECTED, round 11.  This paragraph used to read "nothing in the code
;           bounds the index, so the layout stops the table at 23".  SOMETHING
;           BOUNDS IT: the dispatcher calls PanelCode_ToSlotAndFlags (0xF55019)
;           first, which rejects a raw index above 0x1F (`cp HL,0x001f` at
;           0xF55026) and then REMAPS what is left -- 0x11..0x19 lose 0x11
;           (0xF5506F-0xF55078) and 0x1A..0x1F lose 9 (0xF55081-0xF5508A) --
;           so what reaches `mul A,0x04` is 0..22.  Twenty-three slots is the
;           INDEX SPACE, not a layout accident, and these nine words are below
;           it.  Checked by notes/wave7-verify-probes/
;           wave7_r10_screen_table_entry_count.py and by
;           notes/prom_b_panel_names_round11.py --selftest.
; Unknown: whether they belong to the table before them.
; --------------------------------------------------------------------------
Table_F542A4:
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F542A4  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F542B4  ................
	.byte 0x00, 0x00, 0x00, 0x00   ; F542C4  ....

; --------------------------------------------------------------------------
; DrawbarRowOffsets -- 9 source-row offsets, one per drawbar position
; Read by: prom_b 0xF538EF `add XBC,0x00f542c8`, inside Drawbar_DrawColumn,
;          followed by `ld A,(XBC)`, indexed by the bar's 0..15 nibble.
; Entries: 0x6E 0x62 0x54 0x46 0x38 0x2A 0x1C 0x0E 0x00 -- one step of 12
;          and then eight of 14.
; Entry count: NINE, and nine is measured twice: 0xF542C8 + 9 = 0xF542D1,
;              which is exactly where DrawbarSettingPage_RowStepHandlers starts; and the
;              screen shows nine drawbars.  ⚠ This is CORRECTION C3: the
;              layout's HOLES table describes 44 of this segment's 45 bytes
;              and never mentions the trailing 0x00, which is entry 8.
; Evidence: entry 0 (0x6E) plus the blit window (0x7B rows) is 233, exactly
;           the distance between the three slices of a drawbar sprite -- so
;           the offsets and the sprite pitch are the same measurement taken
;           twice.
; --------------------------------------------------------------------------
DrawbarRowOffsets:
	.byte 0x6e, 0x62, 0x54, 0x46, 0x38, 0x2a, 0x1c, 0x0e, 0x00   ; F542C8  nbTF8*...

; --- 0xF542D1-0xF542E0  ptrtab (16 bytes) ---

; --------------------------------------------------------------------------
; DrawbarSettingPage_RowStepHandlers -- 4 pointers into this module's code
; Read by: prom_b 0xF531E4 `add XBC,0x00f542d1`
; Evidence: four 32-bit words, all four landing on instruction boundaries of
;           this transcription; it starts exactly where DrawbarRowOffsets
;           ends and ends where DL_Flag2896b5_Set begins.
; Unknown: what bounds the index at 4.  The reader above does `ld XBC,(XBC)`
;          and jumps; nothing in the span compares the index with a literal.
; --------------------------------------------------------------------------
; DrawbarSettingPage_RowStepHandlers: DRAWBAR SETTING page: steps the signed nibble of the row under the cursor
;   (0x28A1) by +-1 within -5..+5 -- 0 PERCUSSIVE TONE DECAY, 1 PERCUSSIVE TONE LEVEL, 2 DRAWBAR ATTACK TIME, 3
;   DRAWBAR RELEASE TIME -- then Drawbar_SendSettingBytes. Basis: table index (row cursor) + the page's row text + the
;   nibble each arm edits. (notes/naming-pilot-2026-10-06/proposals_wave11_t11.json)
DrawbarSettingPage_RowStepHandlers:
	.long DrawbarSettingPage_StepPercussiveToneDecay                       ; F542D1  [0]   -> DrawbarSettingPage_StepPercussiveToneDecay
	.long DrawbarSettingPage_StepPercussiveToneLevel                       ; F542D5  [1]   -> DrawbarSettingPage_StepPercussiveToneLevel
	.long DrawbarSettingPage_StepAttackTime                       ; F542D9  [2]   -> DrawbarSettingPage_StepAttackTime
	.long DrawbarSettingPage_StepReleaseTime                       ; F542DD  [3]   -> DrawbarSettingPage_StepReleaseTime

; --- 0xF542E1-0xF542EC  data (12 bytes) ---

; --------------------------------------------------------------------------
; DL_Flag2896b5_Set -- a UI display list, 1 record, 0xF542E1-0xF542EC
; Run by: `lda XWA,0xf542e1` at 0xF53841 with END 0xF542ED pushed just
;         before it, then `call` at 0xF53855 -> interpreter A
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF542E1-0xF542EC exactly -- a miscount anywhere
;           would end somewhere else.
; ⚠ CORRECTION: notes/prom_b_f4f000_layout.py's HOLES table calls this a
;               display list its INTER_MIN = 2 rule refuses.  It is CALL-
;               SITE PROVEN: `lda XWA,0xf542e1` at 0xF53841 and `lda
;               XBC,0xf542ed` at 0xF5383B, two instructions before the `call
;               0xf42e00` at 0xF53855.  The layout's site scanner misses it
;               because a `jr` splits the pair.  No boundary moves.
; --------------------------------------------------------------------------
DL_Flag2896b5_Set:
	.byte 0x03, 0x0c	; F542E1  op 03, 12 bytes -> handler 0xF31ABE
	.long Bitmap_F54790_48x20	; +2  source -> Bitmap_F54790_48x20
	.short 0x04D1		; +6  IX  (screen position)
	.short 0x0006		; +8  BC  (6 bytes per row)
	.short 0x0014		; +10 HL  (20 rows)

; --- 0xF542ED-0xF542F8  dl (12 bytes) ---

; --------------------------------------------------------------------------
; DL_Flag2896b5_Clear -- a UI display list, 1 record, 0xF542ED-0xF542F8
; Run by: `lda XWA,0xf542ed` at 0xF5384F with END 0xF542F9 pushed just
;         before it, then `call` at 0xF53855 -> interpreter A
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF542ED-0xF542F8 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
DL_Flag2896b5_Clear:
	.byte 0x03, 0x0c	; F542ED  op 03, 12 bytes -> handler 0xF31ABE
	.long Bitmap_F54718_48x20	; +2  source -> Bitmap_F54718_48x20
	.short 0x04D1		; +6  IX  (screen position)
	.short 0x0006		; +8  BC  (6 bytes per row)
	.short 0x0014		; +10 HL  (20 rows)

; --- 0xF542F9-0xF54304  data (12 bytes) ---

; --------------------------------------------------------------------------
; DL_Flag2896b4_Set -- a UI display list, 1 record, 0xF542F9-0xF54304
; Run by: `lda XWA,0xf542f9` at 0xF53868 with END 0xF54305 pushed just
;         before it, then `call` at 0xF5387C -> interpreter A
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF542F9-0xF54304 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
DL_Flag2896b4_Set:
	.byte 0x03, 0x0c	; F542F9  op 03, 12 bytes -> handler 0xF31ABE
	.long Bitmap_F54790_48x20	; +2  source -> Bitmap_F54790_48x20
	.short 0x0981		; +6  IX  (screen position)
	.short 0x0006		; +8  BC  (6 bytes per row)
	.short 0x0014		; +10 HL  (20 rows)

; --- 0xF54305-0xF546A3  dl (927 bytes) ---

; --------------------------------------------------------------------------
; DL_Flag2896b4_Clear -- a UI display list, 1 record, 0xF54305-0xF54310
; Run by: `lda XWA,0xf54305` at 0xF53876 with END 0xF54311 pushed just
;         before it, then `call` at 0xF5387C -> interpreter A
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF54305-0xF54310 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
DL_Flag2896b4_Clear:
	.byte 0x03, 0x0c	; F54305  op 03, 12 bytes -> handler 0xF31ABE
	.long Bitmap_F54718_48x20	; +2  source -> Bitmap_F54718_48x20
	.short 0x0981		; +6  IX  (screen position)
	.short 0x0006		; +8  BC  (6 bytes per row)
	.short 0x0014		; +10 HL  (20 rows)

; --------------------------------------------------------------------------
; DL_DrawbarScaleStrip -- a UI display list, 3 records, 0xF54311-0xF54330
; Run by: `lda XWA,0xf54311` at 0xF53797 with END 0xF54331 pushed just
;         before it, then `call` at 0xF5379D -> interpreter A
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF54311-0xF54330 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
DL_DrawbarScaleStrip:
	.byte 0x02, 0x0a	; F54311  op 02, 10 bytes -> handler 0xF31A75
	.byte 0x0d, 0x00, 0x59, 0x00, 0x0d, 0x00, 0x67, 0x00	; +2  '..Y...g.'
	.byte 0x02, 0x0a	; F5431B  op 02, 10 bytes -> handler 0xF31A75
	.byte 0x37, 0x01, 0x59, 0x00, 0x37, 0x01, 0x67, 0x00	; +2  '7.Y.7.g.'
	.byte 0x03, 0x0c	; F54325  op 03, 12 bytes -> handler 0xF31ABE
	.long Bitmap_F54D7E_304x6	; +2  source -> Bitmap_F54D7E_304x6
	.short 0x2493		; +6  IX  (screen position)
	.short 0x0026		; +8  BC  (38 bytes per row)
	.short 0x0006		; +10 HL  (6 rows)

; --------------------------------------------------------------------------
; DL_DrawbarFootageScale -- a UI display list, 22 records, 0xF54331-0xF543AF
; Run by: `lda XWA,0xf54331` at 0xF53774 with END 0xF543B0 pushed just
;         before it, then `call` at 0xF5377A -> interpreter A
; Text it draws: '16'; '1/3'; '2/3'; '3/5'; '1/3'
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF54331-0xF543AF exactly -- a miscount anywhere
;           would end somewhere else.
; ★ Footages: nine whole-number labels reading '16', '5', '8', '4', '2',
;             '2', '1', '1', '1', nine foot marks, and four fraction labels
;             reading '1/3', '2/3', '3/5', '1/3'.  Read together they are
;             the nine Hammond-style drawbar footages 16' 5 1/3' 8' 4' 2
;             2/3' 2' 1 3/5' 1 1/3' 1'.  The numeric labels' screen
;             positions run 0x0E3B..0x0E5C and each falls within one cell of
;             its bar's own column (--selftest check F).
; --------------------------------------------------------------------------
DL_DrawbarFootageScale:
	.byte 0x07, 0x05	; F54331  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0E3D		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x07, 0x05	; F54336  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0E45		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x07, 0x05	; F5433B  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0E49		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x07, 0x05	; F54340  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0E51		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x07, 0x05	; F54345  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0E5D		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x20, 0x05	; F5434A  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0E5A		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x20, 0x06	; F5434F  op 20, 6 bytes -> handler 0xF31A3A
	.short 0x0E3B		; +2  IX (screen position)
	.ascii "16"	; +4
	.byte 0x20, 0x05	; F54355  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0E3F		; +2  IX (screen position)
	.ascii "5"	; +4
	.byte 0x07, 0x05	; F5435A  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0E42		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x20, 0x05	; F5435F  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0E44		; +2  IX (screen position)
	.ascii "8"	; +4
	.byte 0x20, 0x05	; F54364  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0E48		; +2  IX (screen position)
	.ascii "4"	; +4
	.byte 0x20, 0x05	; F54369  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0E4B		; +2  IX (screen position)
	.ascii "2"	; +4
	.byte 0x07, 0x05	; F5436E  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0E4E		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x20, 0x05	; F54373  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0E50		; +2  IX (screen position)
	.ascii "2"	; +4
	.byte 0x20, 0x05	; F54378  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0E53		; +2  IX (screen position)
	.ascii "1"	; +4
	.byte 0x07, 0x05	; F5437D  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x0E56		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x20, 0x05	; F54382  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0E57		; +2  IX (screen position)
	.ascii "1"	; +4
	.byte 0x20, 0x05	; F54387  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0E5C		; +2  IX (screen position)
	.ascii "1"	; +4
	.byte 0x17, 0x09	; F5438C  op 17, 9 bytes -> handler 0xF31A52
	.short 0x0040, 0x005E	; +2  the two words
	.ascii "1/3"	; +6
	.byte 0x17, 0x09	; F54395  op 17, 9 bytes -> handler 0xF31A52
	.short 0x00A0, 0x005E	; +2  the two words
	.ascii "2/3"	; +6
	.byte 0x17, 0x09	; F5439E  op 17, 9 bytes -> handler 0xF31A52
	.short 0x00DF, 0x005E	; +2  the two words
	.ascii "3/5"	; +6
	.byte 0x17, 0x09	; F543A7  op 17, 9 bytes -> handler 0xF31A52
	.short 0x00FF, 0x005E	; +2  the two words
	.ascii "1/3"	; +6

; --------------------------------------------------------------------------
; Paint_DrawbarScreenLayout_DL2 -- a UI display list, 2 records, 0xF543B0-0xF543C3
; Run by: `lda XWA,0xf543b0` at 0xF53787 with END 0xF543C4 pushed just
;         before it, then `call` at 0xF5378D -> interpreter A
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF543B0-0xF543C3 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
Paint_DrawbarScreenLayout_DL2:
; ; drawn (start operand) by Paint_DrawbarScreenLayout -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x05, 0x0a	; F543B0  op 05, 10 bytes -> handler 0xF31A75
	.byte 0x0e, 0x00, 0x58, 0x00, 0x36, 0x01, 0x67, 0x00	; +2  '..X.6.g.'
	.byte 0x05, 0x0a	; F543BA  op 05, 10 bytes -> handler 0xF31A75
	.byte 0x0d, 0x00, 0x6b, 0x00, 0x37, 0x01, 0xe8, 0x00	; +2  '..k.7...'

; --------------------------------------------------------------------------
; Paint_DrawbarScreenLayout_DL1 -- a UI display list, 2 records, 0xF543C4-0xF543D5
; Run by: `lda XWA,0xf543c4` at 0xF53743 with END 0xF543D6 pushed just
;         before it, then `call` at 0xF53749 -> interpreter A; `lda
;         XWA,0xf543c4` at 0xF53756 with END 0xF543D6 pushed just before it,
;         then `call` at 0xF5375C -> interpreter A
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF543C4-0xF543D5 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
Paint_DrawbarScreenLayout_DL1:
; ; drawn (start operand) by Paint_DrawbarScreenLayout -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x1b, 0x0a	; F543C4  op 1B, 10 bytes -> handler 0xF31A75
	.byte 0xa7, 0x00, 0x1b, 0x00, 0x3f, 0x01, 0x53, 0x00	; +2  '....?.S.'
	.byte 0x0e, 0x08	; F543CE  op 0E, 8 bytes -> handler 0xF31A9F
	.byte 0xc0, 0x0d, 0x28, 0x00, 0x98, 0x00	; +2  '..(...'

; --------------------------------------------------------------------------
; DL_DrawbarTitle -- a UI display list, 6 records, 0xF543D6-0xF54415
; Run by: `lda XWA,0xf543d6` at 0xF536CB with END 0xF54416 pushed just
;         before it, then `call` at 0xF536D1 -> interpreter A
; Text it draws: 'DRAWBAR SETTING'; 'DRAWBAR'
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF543D6-0xF54415 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
DL_DrawbarTitle:
	.byte 0x1c, 0x0d	; F543D6  op 1C, 13 bytes -> handler 0xF31A52
	.short 0x007A, 0x0003	; +2  the two words
	.ascii "DRAWBAR"	; +6
	.byte 0x20, 0x13	; F543E3  op 20, 19 bytes -> handler 0xF31A3A
	.short 0x0AF2		; +2  IX (screen position)
	.ascii "DRAWBAR SETTING"	; +4
	.byte 0x17, 0x07	; F543F6  op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000, 0x004C	; +2  the two words
	.byte 0x10	; +6  '.'
	.byte 0x09, 0x0a	; F543FD  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x08, 0x00, 0x42, 0x00, 0x90, 0x00, 0x53, 0x00	; +2  '..B...S.'
	.byte 0x09, 0x0a	; F54407  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x0a, 0x00, 0x44, 0x00, 0x8e, 0x00, 0x51, 0x00	; +2  '..D...Q.'
	.byte 0x23, 0x05	; F54411  op 23, 5 bytes -> handler 0xF31ACE
	.byte 0x6d, 0x0c, 0x00	; +2  'm..'

; --------------------------------------------------------------------------
; DL_PercussiveToneHeader -- a UI display list, 17 records, 0xF54416-0xF544AC
; Run by: `lda XWA,0xf54416` at 0xF537B0 with END 0xF54493 pushed just
;         before it, then `call` at 0xF537C7 -> interpreter A
; Text it draws: 'PERCUSSIVE'; 'T0NE'; '2/3'; 'SOUND MODE'
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF54416-0xF544AC exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
DL_PercussiveToneHeader:
	.byte 0x20, 0x05	; F54416  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x059A		; +2  IX (screen position)
	.ascii "2"	; +4
	.byte 0x07, 0x05	; F5441B  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x059D		; +2  IX (screen position)
	.ascii "'"	; +4
	.byte 0x17, 0x07	; F54420  op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A, 0x0025	; +2  the two words
	.byte 0x11	; +6  '.'
	.byte 0x17, 0x09	; F54427  op 17, 9 bytes -> handler 0xF31A52
	.short 0x0118, 0x0026	; +2  the two words
	.ascii "2/3"	; +6
	.byte 0x20, 0x0e	; F54430  op 20, 14 bytes -> handler 0xF31A3A
	.short 0x06CE		; +2  IX (screen position)
	.ascii "PERCUSSIVE"	; +4
	.byte 0x07, 0x05	; F5443E  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x08BC		; +2  IX (screen position)
	.ascii ","	; +4
	.byte 0x20, 0x08	; F54443  op 20, 8 bytes -> handler 0xF31A3A
	.short 0x0905		; +2  IX (screen position)
	.ascii "T0NE"	; +4
	.byte 0x20, 0x05	; F5444B  op 20, 5 bytes -> handler 0xF31A3A
	.short 0x0A4B		; +2  IX (screen position)
	.ascii "4"	; +4
	.byte 0x17, 0x07	; F54450  op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A, 0x004C	; +2  the two words
	.byte 0x11	; +6  '.'
	.byte 0x01, 0x0a	; F54457  op 01, 10 bytes -> handler 0xF31A75
	.byte 0xa8, 0x00, 0x1b, 0x00, 0x36, 0x01, 0x1b, 0x00	; +2  '....6...'
	.byte 0x01, 0x0a	; F54461  op 01, 10 bytes -> handler 0xF31A75
	.byte 0xa7, 0x00, 0x52, 0x00, 0x37, 0x01, 0x52, 0x00	; +2  '..R.7.R.'
	.byte 0x01, 0x0a	; F5446B  op 01, 10 bytes -> handler 0xF31A75
	.byte 0xa8, 0x00, 0x53, 0x00, 0x36, 0x01, 0x53, 0x00	; +2  '..S.6.S.'
	.byte 0x02, 0x0a	; F54475  op 02, 10 bytes -> handler 0xF31A75
	.byte 0xa7, 0x00, 0x1c, 0x00, 0xa7, 0x00, 0x52, 0x00	; +2  '......R.'
	.byte 0x02, 0x0a	; F5447F  op 02, 10 bytes -> handler 0xF31A75
	.byte 0x36, 0x01, 0x1b, 0x00, 0x36, 0x01, 0x53, 0x00	; +2  '6...6.S.'
	.byte 0x02, 0x0a	; F54489  op 02, 10 bytes -> handler 0xF31A75
	.byte 0x37, 0x01, 0x1c, 0x00, 0x37, 0x01, 0x52, 0x00	; +2  '7...7.R.'
	.byte 0x17, 0x10	; F54493  op 17, 16 bytes -> handler 0xF31A52
	.short 0x0006, 0x0007	; +2  the two words
	.ascii "SOUND MODE"	; +6
	.byte 0x09, 0x0a	; F544A3  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x04, 0x00, 0x04, 0x00, 0x44, 0x00, 0x10, 0x00	; +2  '....D...'

; --------------------------------------------------------------------------
; DL_SoundEditBar -- a UI display list, 6 records, 0xF544AD-0xF544EA
; Run by: `lda XWA,0xf544ad` at 0xF536F2 with END 0xF544EB pushed just
;         before it, then `call` at 0xF536F8 -> interpreter A
; Text it draws: 'WRITE'; 'SOUND EDIT'
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF544AD-0xF544EA exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
DL_SoundEditBar:
	.byte 0x17, 0x10	; F544AD  op 17, 16 bytes -> handler 0xF31A52
	.short 0x0006, 0x0007	; +2  the two words
	.ascii "SOUND EDIT"	; +6
	.byte 0x20, 0x09	; F544BD  op 20, 9 bytes -> handler 0xF31A3A
	.short 0x05A2		; +2  IX (screen position)
	.ascii "WRITE"	; +4
	.byte 0x17, 0x07	; F544C6  op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000, 0x0025	; +2  the two words
	.byte 0x10	; +6  '.'
	.byte 0x09, 0x0a	; F544CD  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x04, 0x00, 0x04, 0x00, 0x44, 0x00, 0x10, 0x00	; +2  '....D...'
	.byte 0x09, 0x0a	; F544D7  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x08, 0x00, 0x20, 0x00, 0x40, 0x00, 0x31, 0x00	; +2  '.. .@.1.'
	.byte 0x09, 0x0a	; F544E1  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x0a, 0x00, 0x22, 0x00, 0x3e, 0x00, 0x2f, 0x00	; +2  '..".>./.'

; --------------------------------------------------------------------------
; DL_DrawbarSettingPage -- a UI display list, 33 records, 0xF544EB-0xF54667
; Run by: `lda XWA,0xf544eb` at 0xF537C1 with END 0xF54668 pushed just
;         before it, then `call` at 0xF537C7 -> interpreter A
; Text it draws: 'DSP EFFECT'; 'DRAWBAR SETTING'; 'PERCUSSIVE T0NE DECAY
;                :'; 'PERCUSSIVE T0NE LEVEL  :'; 'DRAWBAR ATTACK TIME    :';
;                'DRAWBAR RELEASE TIME   :'; 'ITEM'; 'VALUE'
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF544EB-0xF54667 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
DL_DrawbarSettingPage:
	.byte 0x20, 0x0e	; F544EB  op 20, 14 bytes -> handler 0xF31A3A
	.short 0x0B0C		; +2  IX (screen position)
	.ascii "DSP EFFECT"	; +4
	.byte 0x17, 0x07	; F544F9  op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A, 0x004C	; +2  the two words
	.byte 0x11	; +6  '.'
	.byte 0x07, 0x13	; F54500  op 07, 19 bytes -> handler 0xF31A3A
	.short 0x104C		; +2  IX (screen position)
	.ascii "DRAWBAR SETTING"	; +4
	.byte 0x07, 0x1c	; F54513  op 07, 28 bytes -> handler 0xF31A3A
	.short 0x1456		; +2  IX (screen position)
	.ascii "PERCUSSIVE T0NE DECAY  :"	; +4
	.byte 0x07, 0x1c	; F5452F  op 07, 28 bytes -> handler 0xF31A3A
	.short 0x179E		; +2  IX (screen position)
	.ascii "PERCUSSIVE T0NE LEVEL  :"	; +4
	.byte 0x07, 0x05	; F5454B  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17C2		; +2  IX (screen position)
	.byte 0x8d	; +4  '.'
	.byte 0x07, 0x05	; F54550  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x17E5		; +2  IX (screen position)
	.byte 0x8d	; +4  '.'
	.byte 0x17, 0x07	; F54555  op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000, 0x009B	; +2  the two words
	.byte 0x10	; +6  '.'
	.byte 0x17, 0x07	; F5455C  op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A, 0x009B	; +2  the two words
	.byte 0x11	; +6  '.'
	.byte 0x07, 0x1c	; F54563  op 07, 28 bytes -> handler 0xF31A3A
	.short 0x1AE6		; +2  IX (screen position)
	.ascii "DRAWBAR ATTACK TIME    :"	; +4
	.byte 0x17, 0x0a	; F5457F  op 17, 10 bytes -> handler 0xF31A52
	.short 0x0007, 0x00AF	; +2  the two words
	.ascii "ITEM"	; +6
	.byte 0x17, 0x0b	; F54589  op 17, 11 bytes -> handler 0xF31A52
	.short 0x011C, 0x00AF	; +2  the two words
	.ascii "VALUE"	; +6
	.byte 0x07, 0x05	; F54594  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1E02		; +2  IX (screen position)
	.byte 0x8e	; +4  '.'
	.byte 0x07, 0x05	; F54599  op 07, 5 bytes -> handler 0xF31A3A
	.short 0x1E25		; +2  IX (screen position)
	.byte 0x8e	; +4  '.'
	.byte 0x07, 0x1c	; F5459E  op 07, 28 bytes -> handler 0xF31A3A
	.short 0x1E2E		; +2  IX (screen position)
	.ascii "DRAWBAR RELEASE TIME   :"	; +4
	.byte 0x17, 0x07	; F545BA  op 17, 7 bytes -> handler 0xF31A52
	.short 0x0000, 0x00C2	; +2  the two words
	.byte 0x10	; +6  '.'
	.byte 0x17, 0x07	; F545C1  op 17, 7 bytes -> handler 0xF31A52
	.short 0x013A, 0x00C2	; +2  the two words
	.byte 0x11	; +6  '.'
	.byte 0x09, 0x0a	; F545C8  op 09, 10 bytes -> handler 0xF31A75
	.byte 0xd8, 0x00, 0x42, 0x00, 0x38, 0x01, 0x53, 0x00	; +2  '..B.8.S.'
	.byte 0x09, 0x0a	; F545D2  op 09, 10 bytes -> handler 0xF31A75
	.byte 0xda, 0x00, 0x44, 0x00, 0x36, 0x01, 0x51, 0x00	; +2  '..D.6.Q.'
	.byte 0x09, 0x0a	; F545DC  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x08, 0x00, 0x96, 0x00, 0x1f, 0x00, 0xa7, 0x00	; +2  '........'
	.byte 0x09, 0x0a	; F545E6  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x20, 0x01, 0x96, 0x00, 0x37, 0x01, 0xa7, 0x00	; +2  ' ...7...'
	.byte 0x09, 0x0a	; F545F0  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x0a, 0x00, 0x98, 0x00, 0x1d, 0x00, 0xa5, 0x00	; +2  '........'
	.byte 0x09, 0x0a	; F545FA  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x22, 0x01, 0x98, 0x00, 0x35, 0x01, 0xa5, 0x00	; +2  '"...5...'
	.byte 0x09, 0x0a	; F54604  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x08, 0x00, 0xbd, 0x00, 0x1f, 0x00, 0xce, 0x00	; +2  '........'
	.byte 0x09, 0x0a	; F5460E  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x20, 0x01, 0xbd, 0x00, 0x37, 0x01, 0xce, 0x00	; +2  ' ...7...'
	.byte 0x09, 0x0a	; F54618  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x0a, 0x00, 0xbf, 0x00, 0x1d, 0x00, 0xcc, 0x00	; +2  '........'
	.byte 0x09, 0x0a	; F54622  op 09, 10 bytes -> handler 0xF31A75
	.byte 0x22, 0x01, 0xbf, 0x00, 0x35, 0x01, 0xcc, 0x00	; +2  '"...5...'
	.byte 0x01, 0x0a	; F5462C  op 01, 10 bytes -> handler 0xF31A75
	.byte 0x28, 0x00, 0x61, 0x00, 0x12, 0x01, 0x61, 0x00	; +2  '(.a...a.'
	.byte 0x01, 0x0a	; F54636  op 01, 10 bytes -> handler 0xF31A75
	.byte 0x27, 0x00, 0xd8, 0x00, 0x13, 0x01, 0xd8, 0x00	; +2  "'......."
	.byte 0x01, 0x0a	; F54640  op 01, 10 bytes -> handler 0xF31A75
	.byte 0x28, 0x00, 0xd9, 0x00, 0x12, 0x01, 0xd9, 0x00	; +2  '(.......'
	.byte 0x02, 0x0a	; F5464A  op 02, 10 bytes -> handler 0xF31A75
	.byte 0x27, 0x00, 0x62, 0x00, 0x27, 0x00, 0xd8, 0x00	; +2  "'.b.'..."
	.byte 0x02, 0x0a	; F54654  op 02, 10 bytes -> handler 0xF31A75
	.byte 0x12, 0x01, 0x61, 0x00, 0x12, 0x01, 0xd9, 0x00	; +2  '..a.....'
	.byte 0x02, 0x0a	; F5465E  op 02, 10 bytes -> handler 0xF31A75
	.byte 0x13, 0x01, 0x62, 0x00, 0x13, 0x01, 0xd8, 0x00	; +2  '..b.....'

; --------------------------------------------------------------------------
; DL_DrawbarParamValues -- a UI display list, 4 records, 0xF54668-0xF546A3
; Run by: `lda XWA,0xf54668` at 0xF5389F with END 0xF546A4 pushed just
;         before it, then `call` at 0xF538A5 -> interpreter B
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF54668-0xF546A3 exactly -- a miscount anywhere
;           would end somewhere else.
; ★ The pairing: four interpreter-B op-02 records, each printing a nibble of
;                (0x2640)/(0x2641) through DLTableB_SignedNibble.  Each is
;                placed exactly 25 cells after the START of one 24-character
;                caption in DL_DrawbarSettingPage, so the value sits one
;                cell past the colon: 'PERCUSSIVE T0NE DECAY  :' <- (0x2640)
;                & 0x0F >> 0; 'PERCUSSIVE T0NE LEVEL  :' <- (0x2640) & 0xF0
;                >> 4; 'DRAWBAR ATTACK TIME    :' <- (0x2641) & 0xF0 >> 4;
;                'DRAWBAR RELEASE TIME   :' <- (0x2641) & 0x0F >> 0.
; --------------------------------------------------------------------------
DL_DrawbarParamValues:
	.byte 0x02, 0x0f	; F54668  op 02, 15 bytes -> handler 0xF31B21
	.short 0x2640		; +2  RAM variable
	.byte 0x0f, 0x00	; +4  mask, shift
	.byte 0x07		; +6  swi 7 function
	.long DLTableB_SignedNibble	; +7  -> DLTableB_SignedNibble
	.byte 0x02, 0x00	; +11 entry width 2, +12
	.short 0x146F		; +13 IX (screen position)
	.byte 0x02, 0x0f	; F54677  op 02, 15 bytes -> handler 0xF31B21
	.short 0x2640		; +2  RAM variable
	.byte 0xf0, 0x04	; +4  mask, shift
	.byte 0x07		; +6  swi 7 function
	.long DLTableB_SignedNibble	; +7  -> DLTableB_SignedNibble
	.byte 0x02, 0x00	; +11 entry width 2, +12
	.short 0x17B7		; +13 IX (screen position)
	.byte 0x02, 0x0f	; F54686  op 02, 15 bytes -> handler 0xF31B21
	.short 0x2641		; +2  RAM variable
	.byte 0xf0, 0x04	; +4  mask, shift
	.byte 0x07		; +6  swi 7 function
	.long DLTableB_SignedNibble	; +7  -> DLTableB_SignedNibble
	.byte 0x02, 0x00	; +11 entry width 2, +12
	.short 0x1AFF		; +13 IX (screen position)
	.byte 0x02, 0x0f	; F54695  op 02, 15 bytes -> handler 0xF31B21
	.short 0x2641		; +2  RAM variable
	.byte 0x0f, 0x00	; +4  mask, shift
	.byte 0x07		; +6  swi 7 function
	.long DLTableB_SignedNibble	; +7  -> DLTableB_SignedNibble
	.byte 0x02, 0x00	; +11 entry width 2, +12
	.short 0x1E47		; +13 IX (screen position)

; --- 0xF546A4-0xF546C3  ascii (32 bytes) ---

; --------------------------------------------------------------------------
; DLTableB_SignedNibble -- 16 two-character cells, ` 0+1+2+3+4+5+6+7-8-7-6-5-4-3-2-1`
; Read by: the four op-02 records of DL_DrawbarParamValues, at 0xF54668,
;          0xF54677, 0xF54686, 0xF54695.  Each carries 0x00F546A4 at +7 and
;          an entry width of 2 at +0x0B; opcode 02's interpreter-B handler
;          is 0xF31B21 (see FINDINGS-ui-display-list-interpreter-b.md).
; Entries: 16 x 2 = 32 bytes, and 16 is what the records' mask says (0x0F,
;          and 0xF0 with shift 4).  Cell k reads ' 0' for k = 0, '+1'..'+7'
;          for k = 1..7 and '-8'..'-1' for k = 8..15 -- the 4-bit
;          two's-complement value, printed with a sign.
; Evidence: the 32 bytes are read from the ROM and compared, cell by cell,
;           with that formula in --selftest check I, including the LAST
;           cell.
; --------------------------------------------------------------------------
DLTableB_SignedNibble:
	.byte 0x20, 0x30, 0x2b, 0x31, 0x2b, 0x32, 0x2b, 0x33, 0x2b, 0x34, 0x2b, 0x35, 0x2b, 0x36, 0x2b, 0x37   ; F546A4   0+1+2+3+4+5+6+7
	.byte 0x2d, 0x38, 0x2d, 0x37, 0x2d, 0x36, 0x2d, 0x35, 0x2d, 0x34, 0x2d, 0x33, 0x2d, 0x32, 0x2d, 0x31   ; F546B4  -8-7-6-5-4-3-2-1

; --- 0xF546C4-0xF546D9  dl (22 bytes) ---

; --------------------------------------------------------------------------
; DL_ParamCursorBar -- a UI display list, 2 records, 0xF546C4-0xF546D9
; Run by: `lda XWA,0xf546c4` at 0xF537FF with END 0xF546DA pushed just
;         before it, then `call` at 0xF53805 -> interpreter B
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF546C4-0xF546D9 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
DL_ParamCursorBar:
	.byte 0x08, 0x0b	; F546C4  op 08, 11 bytes -> handler 0xF31B57
	.short 0x2641		; +2  RAM variable
	.byte 0x03, 0x00	; +4  mask, shift
	.byte 0x1b		; +6  swi 7 function
	.long ParamCursorRects	; +7  -> ParamCursorRects
	.byte 0x03, 0x0b	; F546CF  op 03, 11 bytes -> handler 0xF31B57
	.short 0x2640		; +2  RAM variable
	.byte 0x03, 0x00	; +4  mask, shift
	.byte 0x05		; +6  swi 7 function
	.long ParamCursorRects	; +7  -> ParamCursorRects

; --- 0xF546DA-0xF54704  data (43 bytes) ---

; --------------------------------------------------------------------------
; ParamCursorRects -- 4 entries of four 16-bit words
; Read by: DL_ParamCursorBar's two records, opcodes 08 and 03, whose handler
;          DLB_Handler_Array8 (0xF31B57) does `sla 3,HL` before indexing --
;          which is what fixes the entry at 8 bytes -- and then four `ld
;          BC,(XIX+n)` at n = 0, 2, 4, 6.
; Entries: 4, and 4 is what the records' mask says (0x03).  The words are
;          (0x0029, y, 0x0110, y+15) for y = 0x80, 0x95, 0xAA, 0xBF -- first
;          and third constant, second and fourth 15 apart, y stepping 21:
;          four horizontal bands, one per parameter row of
;          DL_DrawbarSettingPage.
; Evidence: the two records that name it, at 0xF546C4/0xF546CF, carry mask
;           0x03 -- so the index is 0..3 -- and 4 x 8 = 32 bytes reaches
;           0xF546FA, where the next display list begins.
; Unknown: what `swi 7` functions 0x1B and 0x05 do with the four words. The
;          geometry above is arithmetic, not a decoded service.
; --------------------------------------------------------------------------
ParamCursorRects:
	.byte 0x29, 0x00, 0x80, 0x00, 0x10, 0x01, 0x8f, 0x00   ; F546DA  ).......
	.byte 0x29, 0x00, 0x95, 0x00, 0x10, 0x01, 0xa4, 0x00   ; F546E2  ).......
	.byte 0x29, 0x00, 0xaa, 0x00, 0x10, 0x01, 0xb9, 0x00   ; F546EA  ).......
	.byte 0x29, 0x00, 0xbf, 0x00, 0x10, 0x01, 0xce, 0x00   ; F546F2  ).......

; --------------------------------------------------------------------------
; Paint_DrawbarScreenLayout_Unchanged_DL2 -- a UI display list, 1 record, 0xF546FA-0xF54704
; Run by: `lda XWA,0xf546fa` at 0xF537DD with END 0xF54705 pushed just
;         before it, then `call` at 0xF53805 -> interpreter B
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF546FA-0xF54704 exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
Paint_DrawbarScreenLayout_Unchanged_DL2:
; ; drawn (start operand) by Paint_DrawbarScreenLayout_Unchanged -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x08, 0x0b	; F546FA  op 08, 11 bytes -> handler 0xF31B57
	.short 0x2640		; +2  RAM variable
	.byte 0x00, 0x00	; +4  mask, shift
	.byte 0x1b		; +6  swi 7 function
	.long ParamCursorRect_Single	; +7  -> ParamCursorRect_Single

; --- 0xF54705-0xF5470F  dl (11 bytes) ---

; --------------------------------------------------------------------------
; Paint_DrawbarScreenLayout_Unchanged_DL1 -- a UI display list, 1 record, 0xF54705-0xF5470F
; Run by: `lda XWA,0xf54705` at 0xF53811 with END 0xF54710 pushed just
;         before it, then `call` at 0xF53817 -> interpreter B
; Evidence: the records above are framed by their own length bytes, and the
;           walk consumes 0xF54705-0xF5470F exactly -- a miscount anywhere
;           would end somewhere else.
; --------------------------------------------------------------------------
Paint_DrawbarScreenLayout_Unchanged_DL1:
; ; drawn (start operand) by Paint_DrawbarScreenLayout_Unchanged -- derivative name (notes/wsa1_display_list_drawer_names.py)
	.byte 0x03, 0x0b	; F54705  op 03, 11 bytes -> handler 0xF31B57
	.short 0x2640		; +2  RAM variable
	.byte 0x00, 0x00	; +4  mask, shift
	.byte 0x05		; +6  swi 7 function
	.long ParamCursorRect_Single	; +7  -> ParamCursorRect_Single

; --- 0xF54710-0xF54FBE  data (2223 bytes) ---

; --------------------------------------------------------------------------
; ParamCursorRect_Single -- one 8-byte entry, words 0x000B 0x0045
;           0x008D 0x0050
; Read by: Paint_DrawbarScreenLayout_Unchanged_DL2 and Paint_DrawbarScreenLayout_Unchanged_DL1, both with mask 0x00 -- so the entry
;          index is always 0 and this array has exactly one entry.
; Evidence: the two records carry 0x00F54710 at +7 and 0x00 at +4;
;           0xF54710 + 8 = 0xF54718, where Bitmap_F54718 begins.
; --------------------------------------------------------------------------
ParamCursorRect_Single:
	.byte 0x0b, 0x00, 0x45, 0x00, 0x8d, 0x00, 0x50, 0x00   ; F54710  ..E...P.

; --------------------------------------------------------------------------
; Bitmap_F54718_48x20 -- 120 bytes: 6 bytes per row x 20 rows
; Read by: the opcode-03 interpreter-A records at 0xF542ED, 0xF54305, whose
;          handler DLHandler_FarPtr (0xF31ABE) loads XIY from +2, IX from
;          +6, BC from +8 and HL from +10 -- so BC IS the width in bytes and
;          HL the row count.  Every one of them carries BC = 6 and HL = 20.
; Evidence: 6 x 20 = 120 and 0xF54718 + 120 = 0xF54790, the next object in
; ⚠ "BC IS the width in bytes and HL the row count" is the SIZE right and the
;   LAYOUT transposed: LCD_Svc_03_BlitColumns issues CSRDIR DOWN and steps the
;   destination ONE BYTE between columns, so BC is the COLUMN count and HL is
;   bytes DOWN each column -- 48 x 20, byte c*20+r.  Applies to 0xF54790 and
;   0xF54D7E too.  images/Bitmap_F54718.png; notes/FINDINGS-image-files.md.
;           address order.
; --------------------------------------------------------------------------
Bitmap_F54718_48x20:
	.byte 0x0f, 0x18, 0x14, 0x11, 0x12, 0x10, 0x12, 0x10, 0x12, 0x10, 0x12, 0x10, 0x12, 0x10, 0x12, 0x10   ; F54718  ................
	.byte 0x13, 0x17, 0x1f, 0x0f, 0xff, 0x00, 0x00, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54728  .......U........
	.byte 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x55, 0x00, 0x00, 0x00, 0x00   ; F54738  ...........U....
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x55   ; F54748  ...............U
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff   ; F54758  ................
	.byte 0xff, 0x00, 0x01, 0x57, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x03   ; F54768  ...W............
	.byte 0xfd, 0xfe, 0xff, 0xff, 0x80, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0   ; F54778  ................
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0x40, 0x80   ; F54788  ......@.

; --------------------------------------------------------------------------
; Bitmap_F54790_48x20 -- 120 bytes: 6 bytes per row x 20 rows
; Read by: the opcode-03 interpreter-A records at 0xF542E1, 0xF542F9, whose
;          handler DLHandler_FarPtr (0xF31ABE) loads XIY from +2, IX from
;          +6, BC from +8 and HL from +10 -- so BC IS the width in bytes and
;          HL the row count.  Every one of them carries BC = 6 and HL = 20.
; Evidence: 6 x 20 = 120 and 0xF54790 + 120 = 0xF54808, the next object in
;           address order.
; --------------------------------------------------------------------------
Bitmap_F54790_48x20:
	.byte 0x0f, 0x18, 0x14, 0x13, 0x13, 0x13, 0x13, 0x13, 0x13, 0x13, 0x13, 0x13, 0x13, 0x13, 0x13, 0x13   ; F54790  ................
	.byte 0x13, 0x17, 0x1f, 0x0f, 0xff, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff   ; F547A0  ................
	.byte 0xff, 0xff, 0xff, 0xff, 0x55, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff   ; F547B0  ....U...........
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x55, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0xff   ; F547C0  ........U.......
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x55, 0xff, 0xff, 0xff   ; F547D0  ............U...
	.byte 0xff, 0x00, 0x01, 0xff, 0xfd, 0xff, 0xfd, 0xff, 0xfd, 0xff, 0xfd, 0xff, 0xfd, 0xff, 0xfd, 0xff   ; F547E0  ................
	.byte 0x55, 0xfe, 0xff, 0xff, 0x80, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0   ; F547F0  U...............
	.byte 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0x40, 0x80   ; F54800  ......@.

; --------------------------------------------------------------------------
; Bitmap_DrawbarA -- one drawbar sprite: 3 slices of 233 bytes
; Read by: Drawbar_DrawColumn, as `base + DrawbarRowOffsets[value]`, blitted
;          three times 1 byte x 0x7B rows with the source advanced by 233
;          between slices -- so the drawn image is 24 pixels wide and 123
;          rows tall, taken out of a 233-row slice.
; Used by: the integer footages -- 16', 8', 4', 2', 1'.
; Evidence: 3 x 233 = 699 and 0xF54808 + 699 = 0xF54AC3, the next object in
;           address order.  The 110 zero bytes that end each slice are what
;           the 123-row window leaves unused at offset 0.
; --------------------------------------------------------------------------
Bitmap_DrawbarA:
	.byte 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x07, 0x1f, 0x1f, 0x1f, 0x1f   ; F54808  ................
	.byte 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x07, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f   ; F54818  ................
	.byte 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x07, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f   ; F54828  ................
	.byte 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x07, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f   ; F54838  ................
	.byte 0x1f, 0x1f, 0x1f, 0x07, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f   ; F54848  ................
	.byte 0x1f, 0x03, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x07   ; F54858  ................
	.byte 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x1f, 0x20, 0x20   ; F54868  ..............  
	.byte 0x20, 0x7f, 0x80, 0x80, 0x7f, 0x3f, 0x20, 0x3f, 0x20, 0x3f, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54878   ....? ? ?......
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54888  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54898  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F548A8  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F548B8  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F548C8  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F548D8  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F548E8  .........
	.byte 0x83, 0x01, 0x39, 0x39, 0x83, 0x83, 0x39, 0x39, 0x01, 0x83, 0xff, 0xff, 0xff, 0xff, 0x01, 0x01   ; F548F1  ..99..99........
	.byte 0xf9, 0xf1, 0xe3, 0xe7, 0xc7, 0xcf, 0xcf, 0xcf, 0xff, 0xff, 0xff, 0xff, 0x83, 0x01, 0x39, 0x3f   ; F54901  ..............9?
	.byte 0x03, 0x01, 0x39, 0x39, 0x01, 0x83, 0xff, 0xff, 0xff, 0xff, 0x01, 0x01, 0x3f, 0x3f, 0x03, 0x01   ; F54911  ..99........??..
	.byte 0xf9, 0x39, 0x01, 0x83, 0xff, 0xff, 0xff, 0xff, 0xf3, 0xe3, 0xc3, 0xc3, 0x93, 0x93, 0x01, 0x01   ; F54921  .9..............
	.byte 0xf3, 0xf3, 0xff, 0xff, 0xff, 0xff, 0x83, 0x01, 0x39, 0xf9, 0xe3, 0xe3, 0xf9, 0x39, 0x01, 0x83   ; F54931  ........9....9..
	.byte 0xff, 0xff, 0xff, 0xff, 0x83, 0x01, 0x39, 0xf9, 0xf1, 0xe3, 0xc7, 0x8f, 0x01, 0x01, 0xff, 0xff   ; F54941  ......9.........
	.byte 0xff, 0xff, 0xe7, 0xc7, 0xc7, 0xe7, 0xe7, 0xe7, 0xe7, 0xe7, 0xc3, 0xc3, 0xff, 0xff, 0x00, 0x00   ; F54951  ................
	.byte 0x00, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0xff, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54961  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54971  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54981  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54991  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F549A1  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F549B1  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F549C1  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F549D1  .........
	.byte 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2   ; F549DA  ................
	.byte 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2   ; F549EA  ................
	.byte 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2   ; F549FA  ................
	.byte 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2   ; F54A0A  ................
	.byte 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2   ; F54A1A  ................
	.byte 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2   ; F54A2A  ................
	.byte 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0xf2, 0x0e, 0x0e   ; F54A3A  ................
	.byte 0x0e, 0xfe, 0x3e, 0x3e, 0xfe, 0xfe, 0x0e, 0xfe, 0x0e, 0xfe, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54A4A  ..>>............
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54A5A  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54A6A  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54A7A  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54A8A  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54A9A  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54AAA  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54ABA  .........

; --------------------------------------------------------------------------
; Bitmap_DrawbarB -- one drawbar sprite: 3 slices of 233 bytes
; Read by: Drawbar_DrawColumn, as `base + DrawbarRowOffsets[value]`, blitted
;          three times 1 byte x 0x7B rows with the source advanced by 233
;          between slices -- so the drawn image is 24 pixels wide and 123
;          rows tall, taken out of a 233-row slice.
; Used by: the fractional footages -- 5 1/3', 2 2/3', 1 3/5', 1 1/3'.
; Evidence: 3 x 233 = 699 and 0xF54AC3 + 699 = 0xF54D7E, the next object in
;           address order.  The 110 zero bytes that end each slice are what
;           the 123-row window leaves unused at offset 0.
; --------------------------------------------------------------------------
Bitmap_DrawbarB:
	.byte 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x07, 0x1d, 0x1f, 0x17, 0x1f   ; F54AC3  ................
	.byte 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x07, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f   ; F54AD3  ................
	.byte 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x07, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f   ; F54AE3  ................
	.byte 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x07, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f   ; F54AF3  ................
	.byte 0x1d, 0x1f, 0x17, 0x07, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f   ; F54B03  ................
	.byte 0x1d, 0x03, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x07   ; F54B13  ................
	.byte 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x17, 0x1f, 0x1d, 0x1f, 0x20, 0x20   ; F54B23  ..............  
	.byte 0x20, 0x7f, 0x80, 0x80, 0x7f, 0x3f, 0x20, 0x3f, 0x20, 0x3f, 0x1f, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54B33   ....? ? ?......
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54B43  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54B53  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54B63  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54B73  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54B83  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54B93  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54BA3  .........
	.byte 0x83, 0x01, 0x39, 0x39, 0x83, 0x83, 0x39, 0x39, 0x01, 0x83, 0x77, 0xff, 0xdd, 0xff, 0x01, 0x01   ; F54BAC  ..99..99..w.....
	.byte 0xf9, 0xf1, 0x63, 0xe7, 0xc5, 0xcf, 0x4f, 0xcf, 0xfd, 0xff, 0x77, 0xff, 0x83, 0x01, 0x39, 0x3f   ; F54BBC  ..c...O...w...9?
	.byte 0x03, 0x01, 0x39, 0x39, 0x01, 0x83, 0x77, 0xff, 0xdd, 0xff, 0x01, 0x01, 0x3f, 0x3f, 0x03, 0x01   ; F54BCC  ..99..w.....??..
	.byte 0xf9, 0x39, 0x01, 0x83, 0xdd, 0xff, 0x77, 0xff, 0xd3, 0xe3, 0x43, 0xc3, 0x93, 0x93, 0x01, 0x01   ; F54BDC  .9....w...C.....
	.byte 0xf3, 0xf3, 0x7f, 0xff, 0xdd, 0xff, 0x83, 0x01, 0x39, 0xf9, 0x63, 0xe3, 0xf9, 0x39, 0x01, 0x83   ; F54BEC  ........9.c..9..
	.byte 0xdd, 0xff, 0x77, 0xff, 0x83, 0x01, 0x39, 0xf9, 0xd1, 0xe3, 0x47, 0x8f, 0x01, 0x01, 0x77, 0xff   ; F54BFC  ..w...9...G...w.
	.byte 0xdd, 0xff, 0x67, 0xc7, 0xc5, 0xe7, 0x67, 0xe7, 0xe5, 0xe7, 0x43, 0xc3, 0xfd, 0xff, 0x00, 0x00   ; F54C0C  ..g...g...C.....
	.byte 0x00, 0xff, 0x00, 0x00, 0xff, 0xff, 0x00, 0xff, 0x00, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54C1C  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54C2C  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54C3C  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54C4C  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54C5C  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54C6C  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54C7C  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54C8C  .........
	.byte 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2   ; F54C95  ..r...r...r...r.
	.byte 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2   ; F54CA5  ..r...r...r...r.
	.byte 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2   ; F54CB5  ..r...r...r...r.
	.byte 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2   ; F54CC5  ..r...r...r...r.
	.byte 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2   ; F54CD5  ..r...r...r...r.
	.byte 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2   ; F54CE5  ..r...r...r...r.
	.byte 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x72, 0xf2, 0xd2, 0xf2, 0x0e, 0x0e   ; F54CF5  ..r...r...r.....
	.byte 0x0e, 0xfe, 0x3e, 0x3e, 0xfe, 0xfe, 0x0e, 0xfe, 0x0e, 0xfe, 0xf8, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D05  ..>>............
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D15  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D25  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D35  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D45  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D55  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D65  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D75  .........

; --------------------------------------------------------------------------
; Bitmap_F54D7E_304x6 -- 228 bytes: 38 bytes per row x 6 rows
; Read by: the opcode-03 interpreter-A record at 0xF54325, whose handler
;          DLHandler_FarPtr (0xF31ABE) loads XIY from +2, IX from +6, BC
;          from +8 and HL from +10 -- so BC IS the width in bytes and HL the
;          row count.  Every one of them carries BC = 38 and HL = 6.
; Evidence: 38 x 6 = 228 and 0xF54D7E + 228 = 0xF54E62, the next object in
; ⚠ COLUMN-MAJOR: 38 byte-columns of 6 bytes = 304 x 6, byte c*6+r.  See the
;   correction on Bitmap_F54718_48x20 above.  images/Bitmap_F54D7E.png.
;           address order.
; --------------------------------------------------------------------------
Bitmap_F54D7E_304x6:
	.byte 0x0f, 0x0f, 0x1f, 0x1f, 0x3e, 0x30, 0xfe, 0xfc, 0xf0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D7E  ....>0..........
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x07, 0x03, 0x03, 0x01, 0x01, 0xff, 0xfe   ; F54D8E  ................
	.byte 0xfc, 0xf0, 0xc0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54D9E  ................
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x7f, 0x3e, 0x1c, 0x08, 0xc0, 0x80, 0x00, 0x00   ; F54DAE  .........>......
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x7f   ; F54DBE  ................
	.byte 0x1f, 0x07, 0x01, 0x00, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54DCE  .........@......
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x7f, 0x0f, 0x01, 0x00, 0x00, 0xe0, 0xf0, 0xf8, 0xfc   ; F54DDE  ................
	.byte 0x3e, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7f, 0x1f   ; F54DEE  >...............
	.byte 0x03, 0x00, 0x00, 0x00, 0xf8, 0xfc, 0xff, 0x3f, 0x03, 0x00, 0x00, 0x00, 0x00, 0x80, 0xc0, 0x70   ; F54DFE  .......?.......p
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x7f, 0x03, 0x00, 0x00, 0x00, 0xfc, 0xff, 0xff, 0x1f   ; F54E0E  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0xc0, 0xf0, 0xfc, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x1f   ; F54E1E  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0xfc, 0xff, 0xff, 0x07, 0x00, 0x00, 0x00, 0x80, 0xf0, 0xfe, 0x1f, 0x00   ; F54E2E  ................
	.byte 0x01, 0x00, 0x00, 0x00, 0xc0, 0xf0, 0xff, 0x3f, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x7f, 0x01   ; F54E3E  .......?........
	.byte 0x00, 0x00, 0xc0, 0xf8, 0xff, 0xff, 0x07, 0x00, 0x00, 0x00, 0x00, 0xe0, 0xfc, 0x0f, 0x00, 0x00   ; F54E4E  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0xfc, 0x0f, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xfe, 0xf8, 0x00, 0x00   ; F54E5E  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54E6E  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54E7E  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54E8E  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54E9E  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54EAE  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54EBE  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54ECE  ............

; --------------------------------------------------------------------------
; Bitmap_F54D7E_Duplicate -- 228 bytes byte-identical to Bitmap_F54D7E_304x6
; Evidence: the 228-byte block occurs exactly TWICE in the whole prom_b
;           image, at 0xF54D7E and here; nothing in either image names this
;           copy.
; Unknown: how it got here, and what the 10 bytes and 110 zero bytes in
;          front of it are.  prom_b already carries one dead duplicate of
;          exactly this kind -- Table_F4EF40, 36 bytes identical to 0xF4EF1C
;          with no reference anywhere -- so this is recorded and not
;          explained.
; --------------------------------------------------------------------------
Bitmap_F54D7E_Duplicate:
	.byte 0x0f, 0x0f, 0x1f, 0x1f, 0x3e, 0x30, 0xfe, 0xfc, 0xf0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54EDA  ....>0..........
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x07, 0x07, 0x03, 0x03, 0x01, 0x01, 0xff, 0xfe   ; F54EEA  ................
	.byte 0xfc, 0xf0, 0xc0, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54EFA  ................
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x7f, 0x3e, 0x1c, 0x08, 0xc0, 0x80, 0x00, 0x00   ; F54F0A  .........>......
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x7f   ; F54F1A  ................
	.byte 0x1f, 0x07, 0x01, 0x00, 0xc0, 0xc0, 0xc0, 0xc0, 0xc0, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00   ; F54F2A  .........@......
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x7f, 0x0f, 0x01, 0x00, 0x00, 0xe0, 0xf0, 0xf8, 0xfc   ; F54F3A  ................
	.byte 0x3e, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7f, 0x1f   ; F54F4A  >...............
	.byte 0x03, 0x00, 0x00, 0x00, 0xf8, 0xfc, 0xff, 0x3f, 0x03, 0x00, 0x00, 0x00, 0x00, 0x80, 0xc0, 0x70   ; F54F5A  .......?.......p
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x7f, 0x03, 0x00, 0x00, 0x00, 0xfc, 0xff, 0xff, 0x1f   ; F54F6A  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0xc0, 0xf0, 0xfc, 0x07, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0x1f   ; F54F7A  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0xfc, 0xff, 0xff, 0x07, 0x00, 0x00, 0x00, 0x80, 0xf0, 0xfe, 0x1f, 0x00   ; F54F8A  ................
	.byte 0x01, 0x00, 0x00, 0x00, 0xc0, 0xf0, 0xff, 0x3f, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0x7f, 0x01   ; F54F9A  .......?........
	.byte 0x00, 0x00, 0xc0, 0xf8, 0xff, 0xff, 0x07, 0x00, 0x00, 0x00, 0x00, 0xe0, 0xfc, 0x0f, 0x00, 0x00   ; F54FAA  ................
	.byte 0x00, 0x00, 0x00, 0x00, 0x00   ; F54FBA  .....

; --- 0xF54FBF-0xF54FFF  fill (65 bytes) ---
	.fill	65, 1, 0x0E	; asserted a single value
