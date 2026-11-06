

; --------------------------------------------------------------------------
; SoundEditController_PaintPage1
; Called from: table 0xF5B8F8[45]
; Touches: (0x2540) (0x27F5)  |  0xF32D2C 0xF32E71 0xF32F43 0xF32FA0 0xF32FC8
;          0xF32FE6
; Calls:   SoundEditController_PaintHeader T_UiPaint_PageLabelBackdrop T_DisplayList_Run T_DisplayListB_Run
; Draws:   4 display-list call sites naming 4 distinct lists; their printable
;          runs: 0xF32D2C-0xF32E71 "PAGE1/2"; 0xF32F43-0xF32FA0;
;          0xF32FC8-0xF32FE6; 0xF32FA0-0xF32FC8
; Evidence: entry [45] of Dispatch_Code80_PaintTable, the BRACKETED selector table.
;           It calls SoundEditController_PaintHeader (which draws the list at
;           0xF32C2A, text 'C0NTR0LLER' and 'SOUND EDIT') and then runs the
;           list at 0xF32D2C, whose own text is 'PAGE1/2'.
; --------------------------------------------------------------------------
SoundEditController_PaintPage1:
	call	SoundEditController_PaintHeader	; F09800  call 0xf098b8
	call	T_UiPaint_PageLabelBackdrop	; F09804  call 0xf42e18
	ld	(LCD_CurrentLayer:16), 0	; F09808  ld (0x2540),0x00
	ld	xiy, SoundEditController_PaintPage1_DL	; F0980D  ld XIY,0x00f32d2c
	ld	xix, DL_Page22AfterTouchCtrlPedal	; F09812  ld XIX,0x00f32e71
	call	T_DisplayList_Run	; F09817  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F0981B  ld (0x2540),0x00
	ld	xiy, DL_F32F43	; F09820  ld XIY,0x00f32f43
	ld	xix, DL_F32FA0	; F09825  ld XIX,0x00f32fa0
	call	T_DisplayListB_Run	; F0982A  call 0xf417f4
	cp	(SoundEdit_SoundKind:16), 0x01	; F0982E  cp (0x27f5),0x01
	jr	z, SoundEditController_PaintPage1_Skip	; F09833  jr Z,0xf09848
	ld	(LCD_CurrentLayer:16), 0	; F09835  ld (0x2540),0x00
	ld	xiy, DL_F32FC8	; F0983A  ld XIY,0x00f32fc8
	ld	xix, SoundEditController_HeaderRecords	; F0983F  ld XIX,0x00f32fe6
	call	T_DisplayListB_Run	; F09844  call 0xf417f4
SoundEditController_PaintPage1_Skip:
	ld	(LCD_CurrentLayer:16), 0	; F09848  ld (0x2540),0x00
	ld	xiy, DL_F32FA0	; F0984D  ld XIY,0x00f32fa0
	ld	xix, DL_F32FC8	; F09852  ld XIX,0x00f32fc8
	call	T_DisplayListB_Run	; F09857  call 0xf417f4
	ret	; F0985B  ret

; --------------------------------------------------------------------------
; SoundEditController_PaintPage2
; Called from: table 0xF5B8F8[27]
; Touches: (0x2540) (0x27F5)  |  0xF32E71 0xF32F43 0xF32FA0 0xF32FC8 0xF32FE6
;          0xF3341C +1 more
; Calls:   SoundEditController_PaintHeader T_UiPaint_PageLabelBackdrop T_DisplayList_Run T_DisplayListB_Run
; Draws:   4 display-list call sites naming 4 distinct lists; their printable
;          runs: 0xF32E71-0xF32F43 "PAGE2/2 / AFTER TOUCH / CTRL PEDAL";
;          0xF3341C-0xF334AE; 0xF32FC8-0xF32FE6; 0xF32FA0-0xF32FC8
; Evidence: entry [27] of Dispatch_Code80_PaintTable.  Same header call, then the
;           list at 0xF32E71, text 'PAGE2/2', 'AFTER TOUCH', 'CTRL PEDAL'.
; --------------------------------------------------------------------------
SoundEditController_PaintPage2:
	call	SoundEditController_PaintHeader	; F0985C  call 0xf098b8
	call	T_UiPaint_PageLabelBackdrop	; F09860  call 0xf42e18
	ld	(LCD_CurrentLayer:16), 0	; F09864  ld (0x2540),0x00
	ld	xiy, DL_Page22AfterTouchCtrlPedal	; F09869  ld XIY,0x00f32e71
	ld	xix, DL_F32F43	; F0986E  ld XIX,0x00f32f43
	call	T_DisplayList_Run	; F09873  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F09877  ld (0x2540),0x00
	ld	xiy, DL_F3341C	; F0987C  ld XIY,0x00f3341c
	ld	xix, DLBoxes_F334AE	; F09881  ld XIX,0x00f334ae
	call	T_DisplayListB_Run	; F09886  call 0xf417f4
	cp	(SoundEdit_SoundKind:16), 0x01	; F0988A  cp (0x27f5),0x01
	jr	z, SoundEditController_PaintPage2_Skip	; F0988F  jr Z,0xf098a4
	ld	(LCD_CurrentLayer:16), 0	; F09891  ld (0x2540),0x00
	ld	xiy, DL_F32FC8	; F09896  ld XIY,0x00f32fc8
	ld	xix, SoundEditController_HeaderRecords	; F0989B  ld XIX,0x00f32fe6
	call	T_DisplayListB_Run	; F098A0  call 0xf417f4
SoundEditController_PaintPage2_Skip:
	ld	(LCD_CurrentLayer:16), 0	; F098A4  ld (0x2540),0x00
	ld	xiy, DL_F32FA0	; F098A9  ld XIY,0x00f32fa0
	ld	xix, DL_F32FC8	; F098AE  ld XIX,0x00f32fc8
	call	T_DisplayListB_Run	; F098B3  call 0xf417f4
	ret	; F098B7  ret

; --------------------------------------------------------------------------
; SoundEditController_PaintHeader
; Called from: in-module: 0xF09800 0xF0985C
; Touches: (0x2540) (0x27F5)  |  0xF32C2A 0xF32CC8 0xF32D03 0xF32D2C
; Calls:   T_DisplayList_Run
; Draws:   3 display-list call sites naming 3 distinct lists; their printable
;          runs: 0xF32C2A-0xF32D03 "C0NTR0LLER / SOUND EDIT / g DEPTH /
;          K!FUNCTION / o 1st 2nd 3"; 0xF32C2A-0xF32CC8 "C0NTR0LLER / SOUND
;          EDIT / g DEPTH / K!FUNCTION"; 0xF32D03-0xF32D2C "o 1st 2nd"
; Evidence: called by both CONTROLLER page painters and by nothing else in the
;           transcription.  It runs the list at 0xF32C2A, whose text is
;           'C0NTR0LLER' and 'SOUND EDIT' -- the page header -- choosing
;           between two end bounds on (0x27F5).
; --------------------------------------------------------------------------
SoundEditController_PaintHeader:
	cp	(SoundEdit_SoundKind:16), 0x01	; F098B8  cp (0x27f5),0x01
	jr	z, SoundEditController_PaintHeader_Skip	; F098BD  jr Z,0xf098d4
	ld	(LCD_CurrentLayer:16), 0	; F098BF  ld (0x2540),0x00
	ld	xiy, DL_ControllerSoundEditDepth	; F098C4  ld XIY,0x00f32c2a
	ld	xix, DL_1st2nd	; F098C9  ld XIX,0x00f32d03
	call	T_DisplayList_Run	; F098CE  call 0xf417f0
	jr	SoundEditController_PaintHeader_Return	; F098D2  jr T,0xf098fa
SoundEditController_PaintHeader_Skip:
	ld	(LCD_CurrentLayer:16), 0	; F098D4  ld (0x2540),0x00
	ld	xiy, DL_ControllerSoundEditDepth	; F098D9  ld XIY,0x00f32c2a
	ld	xix, DL_ControllerSoundEditDepth + 0x9E	; F098DE  ld XIX,0x00f32cc8
	call	T_DisplayList_Run	; F098E3  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F098E7  ld (0x2540),0x00
	ld	xiy, DL_1st2nd	; F098EC  ld XIY,0x00f32d03
	ld	xix, SoundEditController_PaintPage1_DL	; F098F1  ld XIX,0x00f32d2c
	call	T_DisplayList_Run	; F098F6  call 0xf417f0
SoundEditController_PaintHeader_Return:
	ret	; F098FA  ret

; --------------------------------------------------------------------------
; SoundEditController_RepaintFieldPage1
; Called from: table 0xF5B9F8[45]
; Touches: (0x2540)  |  0xF32F43 0xF32FA0 0xF32FE6 0xF33362 0xF3338A 0xF33394
; Calls:   SoundEditController_PaintDepthAndSwitches T_DisplayList_Run T_DisplayListB_Run RunDisplayListBFromPointerArray
; Draws:   3 display-list call sites naming 3 distinct lists; their printable
;          runs: 0xF33362-0xF3338A; 0xF3338A-0xF33394; 0xF32F43-0xF32FA0
; Evidence: entry [45] of Dispatch_Code80_RepaintFieldTable, the table PARALLEL to
;           0xF5B8F8: same index, same screen.  It starts `cp A,0 / cp A,0x0E
;           / cp A,0x0C` and repaints a SUBSET of the page's lists, where the
;           [45] routine of the first table repaints all of them.
; --------------------------------------------------------------------------
SoundEditController_RepaintFieldPage1:
	cp	a, 0:i3	; F098FB  cp A,0
	jr	z, SoundEditController_PaintHeader_Skip2	; F098FD  jr Z,0xf0990f
	cp	a, 14	; F098FF  cp A,0x0e
	jr	nc, SoundEditController_PaintHeader_Skip3	; F09902  jr NC,0xf09926
	cp	a, 12	; F09904  cp A,0x0c
	jr	nz, SoundEditController_PaintHeader_Join	; F09907  jr NZ,0xf09952
	call	SoundEditController_PaintDepthAndSwitches	; F09909  call 0xf099c7
	jr	SoundEditController_PaintHeader_Return2	; F0990D  jr T,0xf09960
SoundEditController_PaintHeader_Skip2:
	ld	(LCD_CurrentLayer:16), 1	; F0990F  ld (0x2540),0x01
	ld	xiy, SoundEditController_RepaintFieldPage1_DL1	; F09914  ld XIY,0x00f33362
	ld	xix, SoundEditController_RepaintFieldPage1_DL2	; F09919  ld XIX,0x00f3338a
	call	T_DisplayList_Run	; F0991E  call 0xf417f0
	ld	a, 0:opc	; F09922  ld A,0x00
	jr	SoundEditController_PaintHeader_Join	; F09924  jr T,0xf09952
SoundEditController_PaintHeader_Skip3:
	ld	(LCD_CurrentLayer:16), 1	; F09926  ld (0x2540),0x01
	ld	xiy, SoundEditController_RepaintFieldPage1_DL2	; F0992B  ld XIY,0x00f3338a
	ld	xix, Data_F33394	; F09930  ld XIX,0x00f33394
	call	T_DisplayList_Run	; F09935  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F09939  ld (0x2540),0x00
	ld	xiy, DL_F32F43	; F0993E  ld XIY,0x00f32f43
	ld	xix, DL_F32FA0	; F09943  ld XIX,0x00f32fa0
	call	T_DisplayListB_Run	; F09948  call 0xf417f4
	call	SoundEditController_PaintDepthAndSwitches	; F0994C  call 0xf099c7
	jr	SoundEditController_PaintHeader_Return2	; F09950  jr T,0xf09960
SoundEditController_PaintHeader_Join:
	ld	(LCD_CurrentLayer:16), 0	; F09952  ld (0x2540),0x00
	ld	xiy, SoundEditController_HeaderRecords	; F09957  ld XIY,0x00f32fe6
	call	RunDisplayListBFromPointerArray	; F0995C  call 0xf09ae1
SoundEditController_PaintHeader_Return2:
	ret	; F09960  ret

; --------------------------------------------------------------------------
; SoundEditController_RepaintFieldPage2
; Called from: table 0xF5B9F8[27]
; Touches: (0x2540)  |  0xF3341C 0xF334AE 0xF334FE 0xF33508
; Calls:   SoundEditController_PaintDepthAndSwitches T_DisplayList_Run T_DisplayListB_Run RunDisplayListBFromPointerArray
; Draws:   3 display-list call sites naming 2 distinct lists; their printable
;          runs: 0xF334FE-0xF33508; 0xF3341C-0xF334AE
; Evidence: entry [27] of Dispatch_Code80_RepaintFieldTable -- the parallel of the PAGE2/2
;           painter -- and it likewise starts `cp A,0 / cp A,0x32 / cp
;           A,0x0C`.
; --------------------------------------------------------------------------
SoundEditController_RepaintFieldPage2:
	cp	a, 0:i3	; F09961  cp A,0
	jr	z, SoundEditController_PaintHeader_Skip4	; F09963  jr Z,0xf09975
	cp	a, 50	; F09965  cp A,0x32
	jr	z, SoundEditController_PaintHeader_Skip5	; F09968  jr Z,0xf0998c
	cp	a, 12	; F0996A  cp A,0x0c
	jr	nz, SoundEditController_PaintHeader_Skip6	; F0996D  jr NZ,0xf099b8
	call	SoundEditController_PaintDepthAndSwitches	; F0996F  call 0xf099c7
	jr	SoundEditController_PaintHeader_Return3	; F09973  jr T,0xf099c6
SoundEditController_PaintHeader_Skip4:
	ld	(LCD_CurrentLayer:16), 1	; F09975  ld (0x2540),0x01
	ld	xiy, SoundEditController_RepaintFieldPage2_DL	; F0997A  ld XIY,0x00f334fe
	ld	xix, DLRecordPtrs_F33508	; F0997F  ld XIX,0x00f33508
	call	T_DisplayList_Run	; F09984  call 0xf417f0
	ld	a, 0:opc	; F09988  ld A,0x00
	jr	SoundEditController_PaintHeader_Return3	; F0998A  jr T,0xf099c6
SoundEditController_PaintHeader_Skip5:
	ld	(LCD_CurrentLayer:16), 1	; F0998C  ld (0x2540),0x01
	ld	xiy, SoundEditController_RepaintFieldPage2_DL	; F09991  ld XIY,0x00f334fe
	ld	xix, DLRecordPtrs_F33508	; F09996  ld XIX,0x00f33508
	call	T_DisplayList_Run	; F0999B  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F0999F  ld (0x2540),0x00
	ld	xiy, DL_F3341C	; F099A4  ld XIY,0x00f3341c
	ld	xix, DLBoxes_F334AE	; F099A9  ld XIX,0x00f334ae
	call	T_DisplayListB_Run	; F099AE  call 0xf417f4
	call	SoundEditController_PaintDepthAndSwitches	; F099B2  call 0xf099c7
	jr	SoundEditController_PaintHeader_Return3	; F099B6  jr T,0xf099c6
SoundEditController_PaintHeader_Skip6:
	ld	(LCD_CurrentLayer:16), 0	; F099B8  ld (0x2540),0x00
	ld	xiy, DLRecordPtrs_F33508	; F099BD  ld XIY,0x00f33508
	call	RunDisplayListBFromPointerArray	; F099C2  call 0xf09ae1
SoundEditController_PaintHeader_Return3:
	ret	; F099C6  ret

; --------------------------------------------------------------------------
; SoundEditController_PaintDepthAndSwitches
; Called from: in-module: 0xF09909 0xF0994C 0xF0996F 0xF099B2
; Touches: (0x2540) (0x27F5)  |  0xF32FA0 0xF32FC8 0xF32FE6
; Calls:   T_DisplayListB_Run
; Draws:   2 display-list call sites naming 2 distinct lists; their printable
;          runs: 0xF32FC8-0xF32FE6; 0xF32FA0-0xF32FC8
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription (the
;           sites are listed above), so 0xF099C7 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditController_PaintDepthAndSwitches: Draws the CONTROLLER page's DEPTH value (ModelingPage_Fields+11, 3 digits
;   at 0x2298) and the 1st..4th switch states (Fields+12 bit pairs, OFF/ON/---/INV); the 3rd/4th pair is skipped when
;   (0x27F5) = 1, where the header shows only '1st 2nd'. Both CONTROLLER field repainters call it. Basis: callers +
;   body + display-list records. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
SoundEditController_PaintDepthAndSwitches:
	cp	(SoundEdit_SoundKind:16), 0x01	; F099C7  cp (0x27f5),0x01
	jr	z, SoundEditController_PaintDepthAndSwitches_Skip	; F099CC  jr Z,0xf099e1
	ld	(LCD_CurrentLayer:16), 0	; F099CE  ld (0x2540),0x00
	ld	xiy, DL_F32FC8	; F099D3  ld XIY,0x00f32fc8
	ld	xix, SoundEditController_HeaderRecords	; F099D8  ld XIX,0x00f32fe6
	call	T_DisplayListB_Run	; F099DD  call 0xf417f4
SoundEditController_PaintDepthAndSwitches_Skip:
	ld	(LCD_CurrentLayer:16), 0	; F099E1  ld (0x2540),0x00
	ld	xiy, DL_F32FA0	; F099E6  ld XIY,0x00f32fa0
	ld	xix, DL_F32FC8	; F099EB  ld XIX,0x00f32fc8
	call	T_DisplayListB_Run	; F099F0  call 0xf417f4
	ret	; F099F4  ret

; --------------------------------------------------------------------------
; SoundEditDigitalEffect_Paint
; Called from: table 0xF5B8F8[26]
; Touches: (0x27A6) (0x27B6)  |  0xFC4000 0xFC40B4 0xFC40D2 0xFC40F0 0xFC410F
;          0xFC420F +5 more
; Calls:   T_DisplayList_Run T_DisplayListB_Run
; Draws:   2 display-list call sites naming 2 distinct lists; their printable
;          runs: 0xFC40F0-0xFC420F "INTENSITY / INTENS.# / DIGITAL EFFECT /
;          SOUND EDIT / TYPE / "; 0xFC40B4-0xFC40F0
; Evidence: entry [26] of Dispatch_Code80_PaintTable.  It runs the prom_a list at
;           0xFC40F0 (or 0xFC410F when (0x27B6) == 0x0A), whose text is
;           'DIGITAL EFFECT', 'SOUND EDIT', 'INTENSITY', 'TYPE', 'REVERB DEPTH
;           :', and then indexes two arrays of list bounds at prom_a 0xFC4532
;           and 0xFC47FF by the same (0x27B6).
; --------------------------------------------------------------------------
SoundEditDigitalEffect_Paint:
	ld	a, (ModelingPage_Fields:16)	; F099F5  ld A,(0x27a6)
	and	a, 15	; F099F9  and A,0x0f
	ld	(ModelingPage_Fields+16:16), a	; F099FC  ld (0x27b6),A
	cp	a, 10	; F09A00  cp A,0x0a
	jr	nz, SoundEditDigitalEffect_Paint_Skip2	; F09A03  jr NZ,0xf09a0c
	ld	xiy, SoundEditDigitalEffect_Paint_DL1	; F09A05  ld XIY,0x00fc410f
	jr	SoundEditDigitalEffect_Paint_Join	; F09A0A  jr T,0xf09a11
SoundEditDigitalEffect_Paint_Skip2:
	ld	xiy, DigitalEffect_Header	; F09A0C  ld XIY,0x00fc40f0
SoundEditDigitalEffect_Paint_Join:
	ld	xix, DigitalEffect_Header_End	; F09A11  ld XIX,0x00fc420f
	call	T_DisplayList_Run	; F09A16  call 0xf417f0
	xor	xwa, xwa	; F09A1A  xor XWA,XWA
	ld	a, (ModelingPage_Fields+16:16)	; F09A1C  ld A,(0x27b6)
	sla	wa, 3	; F09A20  sla 0x03,WA
	ld	xiz, DigitalEffect_ParamLabelLists	; F09A23  ld XIZ,0x00fc4532
	add	xiz, xwa	; F09A28  add XIZ,XWA
	ld	xiy, (xiz)	; F09A2A  ld XIY,(XIZ)
	ld	xix, (xiz+4)	; F09A2C  ld XIX,(XIZ+0x04)
	call	T_DisplayList_Run	; F09A2F  call 0xf417f0
	ld	xiy, DigitalEffect_Frame	; F09A33  ld XIY,0x00fc4000
	xor	xbc, xbc	; F09A38  xor XBC,XBC
	ld	xiz, DigitalEffect_FrameEnds	; F09A3A  ld XIZ,0x00fc47ff
	ld	c, (ModelingPage_Fields+16:16)	; F09A3F  ld C,(0x27b6)
	sla	bc, 2	; F09A43  sla 0x02,BC
	ld	xix, (xiz+bc)	; F09A46  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F09A4B  call 0xf417f0
	ld	a, (ModelingPage_Fields+16:16)	; F09A4F  ld A,(0x27b6)
	cp	a, 10	; F09A53  cp A,0x0a
	jr	nz, SoundEditDigitalEffect_Paint_Skip3	; F09A56  jr NZ,0xf09a5f
	ld	xiy, SoundEditDigitalEffect_Paint_DL2	; F09A58  ld XIY,0x00fc40d2
	jr	SoundEditDigitalEffect_Paint_Join2	; F09A5D  jr T,0xf09a64
SoundEditDigitalEffect_Paint_Skip3:
	ld	xiy, DigitalEffect_Frame_End	; F09A5F  ld XIY,0x00fc40b4
SoundEditDigitalEffect_Paint_Join2:
	ld	xix, DigitalEffect_Header	; F09A64  ld XIX,0x00fc40f0
	call	T_DisplayList_Run	; F09A69  call 0xf417f0
	ld	xiy, DigitalEffect_Values	; F09A6D  ld XIY,0x00fc4592
	ld	a, (ModelingPage_Fields+16:16)	; F09A72  ld A,(0x27b6)
	cp	a, 10	; F09A76  cp A,0x0a
	jr	nz, SoundEditDigitalEffect_Paint_Skip4	; F09A79  jr NZ,0xf09a82
	ld	xix, DLRec_FC45CA	; F09A7B  ld XIX,0x00fc45ca
	jr	SoundEditDigitalEffect_Paint_Join3	; F09A80  jr T,0xf09a87
SoundEditDigitalEffect_Paint_Skip4:
	ld	xix, DigitalEffect_ParamValueLists	; F09A82  ld XIX,0x00fc45d5
SoundEditDigitalEffect_Paint_Join3:
	call	T_DisplayListB_Run	; F09A87  call 0xf417f4
	xor	xwa, xwa	; F09A8B  xor XWA,XWA
	ld	a, (ModelingPage_Fields+16:16)	; F09A8D  ld A,(0x27b6)
	sla	wa, 3	; F09A91  sla 0x03,WA
	ld	xiz, DigitalEffect_ParamValueLists	; F09A94  ld XIZ,0x00fc45d5
	add	xiz, xwa	; F09A99  add XIZ,XWA
	ld	xiy, (xiz)	; F09A9B  ld XIY,(XIZ)
	ld	xix, (xiz+4)	; F09A9D  ld XIX,(XIZ+0x04)
	call	T_DisplayListB_Run	; F09AA0  call 0xf417f4
	ret	; F09AA4  ret

; --------------------------------------------------------------------------
; SoundEditDigitalEffect_RepaintField
; Called from: table 0xF5B9F8[26]
; Touches: (0x2540) (0x27B6)  |  0xFC45A1 0xFC45BF 0xFC46BD 0xFC47CF
; Calls:   T_DisplayListB_Run RunDisplayListBFromPointerArray
; Draws:   1 display-list call site naming 1 distinct list; their printable
;          runs: 0xFC45A1-0xFC45BF
; Evidence: entry [26] of Dispatch_Code80_RepaintFieldTable -- the parallel slot of the
;           DIGITAL EFFECT painter -- and it starts `cp A,0 / cp A,7`, the
;           per-field shape.
; --------------------------------------------------------------------------
SoundEditDigitalEffect_RepaintField:
	cp	a, 0:i3	; F09AA5  cp A,0
	jr	z, SoundEditDigitalEffect_RepaintField_Skip5	; F09AA7  jr Z,0xf09ac2
	cp	a, 7:i3	; F09AA9  cp A,7
	jr	nc, SoundEditDigitalEffect_RepaintField_Skip6	; F09AAB  jr NC,0xf09ad2
	xor	xbc, xbc	; F09AAD  xor XBC,XBC
	ld	xiz, DigitalEffect_FieldRecordArrays	; F09AAF  ld XIZ,0x00fc47cf
	ld	c, (ModelingPage_Fields+16:16)	; F09AB4  ld C,(0x27b6)
	sla	bc, 2	; F09AB8  sla 0x02,BC
	ld	xiy, (xiz+bc)	; F09ABB  ld XIY,(XIZ+BC)
	jr	SoundEditDigitalEffect_RepaintField_Join4	; F09AC0  jr T,0xf09ad7
SoundEditDigitalEffect_RepaintField_Skip5:
	ld	xiy, SoundEditDigitalEffect_RepaintField_DL	; F09AC2  ld XIY,0x00fc45a1
	ld	xix, DLRec_FC45BF	; F09AC7  ld XIX,0x00fc45bf
	call	T_DisplayListB_Run	; F09ACC  call 0xf417f4
	jr	SoundEditDigitalEffect_RepaintField_Return	; F09AD0  jr T,0xf09ae0
SoundEditDigitalEffect_RepaintField_Skip6:
	ld	xiy, DigitalEffect_FieldRecords_FC46BD	; F09AD2  ld XIY,0x00fc46bd
SoundEditDigitalEffect_RepaintField_Join4:
	ld	(LCD_CurrentLayer:16), 0	; F09AD7  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F09ADC  call 0xf09ae1
SoundEditDigitalEffect_RepaintField_Return:
	ret	; F09AE0  ret

; --------------------------------------------------------------------------
; RunDisplayListBFromPointerArray
; Called from: in-module: 0xF0995C 0xF099C2 0xF09ADC 0xF09C5E 0xF09D00
;              0xF09D8C 0xF09E1B
; Touches: (0x2540)
; Calls:   T_DisplayListB_RunOne
; Evidence: `extz XWA / xor W,W / sla 2,WA / add XIY,XWA / ld XIY,(XIY) / call
;           0xF41830`: XIY is an array of 32-bit display-list pointers, A is
;           the index, and 0xF41830 is thunk slot T_DisplayListB_RunOne, which holds `jp
;           DisplayListB_RunOne`.  The name states exactly that.
; --------------------------------------------------------------------------
RunDisplayListBFromPointerArray:
	extz	xwa	; F09AE1  extz XWA
	xor	w, w	; F09AE3  xor W,W
	sla	wa, 2	; F09AE5  sla 0x02,WA
	add	xiy, xwa	; F09AE8  add XIY,XWA
	ld	xiy, (xiy)	; F09AEA  ld XIY,(XIY)
	call	T_DisplayListB_RunOne	; F09AEC  call 0xf41830
	ret	; F09AF0  ret
; ToneEditPage_A0_PaintResonatorIcon: (slot A): blits (SWI7 service 3, 6 x 15 bytes) pictogram
;   IndexMap_F09B3B[ModelingPage_Fields[2+A] & 0x3F] at WordTable_F09B33[A], just above slot A's resonator-type name.
;   Page A0's paint and field repaint call it per slot (4, or 2 when (0x27F5) = 1); the pictograms (bar, cylinder,
;   wedges ...) follow STRING / CYLINDER / CONE. Basis: callers + body + tables. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_c.json)
ToneEditPage_A0_PaintResonatorIcon:
	ld	(LCD_CurrentLayer:16), 0	; F09AF1  ld (0x2540),0x00
	ld	xiy, WordTable_F09B33	; F09AF6  ld XIY,0x00f09b33
	ld	w, a	; F09AFB  ld W,A
	sla	a, 1	; F09AFD  sla 0x01,A
	ld	ix, (xiy+a)	; F09B00  ld IX,(XIY+A)
	ld	xbc, ModelingPage_Fields+2	; F09B05  ld XBC,0x000027a8
	ld	a, (xbc+w)	; F09B0A  ld A,(XBC+W)
	and	a, 63	; F09B0F  and A,0x3f
	ld	xbc, IndexMap_F09B3B	; F09B12  ld XBC,0x00f09b3b
	ld	d, (xbc+a)	; F09B17  ld D,(XBC+A)
	sla	d, 2	; F09B1C  sla 0x02,D
	ld	xbc, PtrTable_F09B7B	; F09B1F  ld XBC,0x00f09b7b
	ld	xiy, (xbc+d)	; F09B24  ld XIY,(XBC+D)
	ld	a, 3:opc	; F09B29  ld A,0x03
	ldw	bc, 6	; F09B2B  ld BC,0x0006
	ldw	hl, 15	; F09B2E  ld HL,0x000f
	swi	7	; F09B31  swi 7
	ret	; F09B32  ret

; --------------------------------------------------------------------------
; WordTable_F09B33 -- four 16-bit words, read at prom_b 0xF09AF6 by `ld
;                     XIY,0x00F09B33 / ld W,A / sla 1,A / ld IX,(XIY+A)`.
; Evidence: the reading instruction named above is in the PROVEN transcription
;           of this block, and the object's extent is closed by the next
;           object: the byte map's largest value is 7, so the table it indexes
;           has 8 entries, so that table ends at 0xF09B9B -- which is where
;           the next code segment starts.
; Unknown: what the three objects select.  FRAMED name kept: kind plus
;          address, and the gap is stated.
; --------------------------------------------------------------------------
WordTable_F09B33:
	.short	0x0A68	; F09B33  [0]
	.short	0x1030	; F09B35  [1]
	.short	0x15F8	; F09B37  [2]
	.short	0x1BC0	; F09B39  [3]


; --------------------------------------------------------------------------
; IndexMap_F09B3B -- 64 bytes whose values run 0..7, read at prom_b 0xF09B12
;                    by `and A,0x3F / ld XBC,0x00F09B3B / ld D,(XBC+A)`.  The
;                    mask 0x3F and the 64-byte extent agree.
; Evidence: the reading instruction named above is in the PROVEN transcription
;           of this block, and the object's extent is closed by the next
;           object: the byte map's largest value is 7, so the table it indexes
;           has 8 entries, so that table ends at 0xF09B9B -- which is where
;           the next code segment starts.
; Unknown: what the three objects select.  FRAMED name kept: kind plus
;          address, and the gap is stated.
; --------------------------------------------------------------------------
IndexMap_F09B3B:
	.byte	0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x04, 0x05, 0x05, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	; F09B3B  |................|
	.byte	0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02	; F09B4B  |................|
	.byte	0x03, 0x03, 0x03, 0x03, 0x03, 0x03, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04	; F09B5B  |................|
	.byte	0x04, 0x04, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x07, 0x07	; F09B6B  |................|


; --------------------------------------------------------------------------
; PtrTable_F09B7B -- eight 32-bit words, 0x00FC48D7..0x00FC4B4D, with a
;                    CONSTANT stride of 0x5A.  A constant stride makes this an
;                    ARRAY DESCRIPTOR, not a handler table, and the layout
;                    walk correctly does not follow it: prom_b 0xF09B24 loads
;                    one into XIY and hands it to `swi 7` with A=3 / BC=6 /
;                    HL=0x0F four instructions later.  ★ LEAD FOR A prom_a
;                    LANE: prom_a 0xFC48D7-0xFC4BA6 is 8 x 90 bytes and is
;                    still `.incbin`.
; Evidence: the reading instruction named above is in the PROVEN transcription
;           of this block, and the object's extent is closed by the next
;           object: the byte map's largest value is 7, so the table it indexes
;           has 8 entries, so that table ends at 0xF09B9B -- which is where
;           the next code segment starts.
; Unknown: what the three objects select.  FRAMED name kept: kind plus
;          address, and the gap is stated.
; --------------------------------------------------------------------------
PtrTable_F09B7B:
	.long	Widget_FC48D7	; F09B7B  [0]  +0x00
	.long	Widget_FC4931	; F09B7F  [1]  +0x5A
	.long	Widget_FC498B	; F09B83  [2]  +0x5A
	.long	Widget_FC49E5	; F09B87  [3]  +0x5A
	.long	Widget_FC4A3F	; F09B8B  [4]  +0x5A
	.long	Widget_FC4A99	; F09B8F  [5]  +0x5A
	.long	Widget_FC4AF3	; F09B93  [6]  +0x5A
	.long	Widget_FC4B4D	; F09B97  [7]  +0x5A


; --------------------------------------------------------------------------
; SoundEditCopy_Paint
; Called from: table 0xF5B8F8[29]
; Touches: (0x2540) (0x27F5)  |  0xFC4BA7 0xFC4D77 0xFC4DEB 0xFC4E54 0xFC4E8C
;          0xFC4EC4
; Calls:   T_DisplayList_Run T_DisplayListB_Run SoundEditCopy_DrawSoundName
; Draws:   5 display-list call sites naming 5 distinct lists; their printable
;          runs: 0xFC4BA7-0xFC4D77 "COPY / SOUND EDIT / FROM / TO  / TONE:  /
;          OPTION / COPY  / F"; 0xFC4D77-0xFC4DEB "BANK:  / 1st TONE  / 2nd
;          TONE  / SOUND:  / 3rd TONE  / 4th T"; 0xFC4E54-0xFC4E8C " rO";
;          0xFC4DEB-0xFC4E54 "DRUM KIT:  / 1st TONE  / 2nd TONE  / DRUM SOUND:
;          / DRUM SOU"; 0xFC4E8C-0xFC4EC4
; Evidence: entry [29] of Dispatch_Code80_PaintTable.  It runs the prom_a lists at
;           0xFC4BA7, 0xFC4D77, 0xFC4DEB and 0xFC4E54, whose text is 'COPY',
;           'SOUND EDIT', 'FROM', 'TO  ', 'TONE:  ', 'BANK:  ', 'DRUM KIT:  '
;           and '1st TONE  '..
; --------------------------------------------------------------------------
SoundEditCopy_Paint:
	ld	(LCD_CurrentLayer:16), 0	; F09B9B  ld (0x2540),0x00
	ld	xiy, SoundEditCopy_Frame	; F09BA0  ld XIY,0x00fc4ba7
	ld	xix, SoundEditCopy_Frame_End	; F09BA5  ld XIX,0x00fc4d77
	call	T_DisplayList_Run	; F09BAA  call 0xf417f0
	cp	(SoundEdit_SoundKind:16), 0x01	; F09BAE  cp (0x27f5),0x01
	jr	z, SoundEditCopy_Paint_Skip	; F09BB3  jr Z,0xf09bdd
	ld	(LCD_CurrentLayer:16), 0	; F09BB5  ld (0x2540),0x00
	ld	xiy, SoundEditCopy_Frame_End	; F09BBA  ld XIY,0x00fc4d77
	ld	xix, SoundEditCopy_DrumLabels	; F09BBF  ld XIX,0x00fc4deb
	call	T_DisplayList_Run	; F09BC4  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F09BC8  ld (0x2540),0x00
	ld	xiy, SoundEditCopy_DrumLabels_End	; F09BCD  ld XIY,0x00fc4e54
	ld	xix, SoundEditCopy_DrumValues	; F09BD2  ld XIX,0x00fc4e8c
	call	T_DisplayListB_Run	; F09BD7  call 0xf417f4
	jr	SoundEditCopy_Paint_Join	; F09BDB  jr T,0xf09c03
SoundEditCopy_Paint_Skip:
	ld	(LCD_CurrentLayer:16), 0	; F09BDD  ld (0x2540),0x00
	ld	xiy, SoundEditCopy_DrumLabels	; F09BE2  ld XIY,0x00fc4deb
	ld	xix, SoundEditCopy_DrumLabels_End	; F09BE7  ld XIX,0x00fc4e54
	call	T_DisplayList_Run	; F09BEC  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F09BF0  ld (0x2540),0x00
	ld	xiy, SoundEditCopy_DrumValues	; F09BF5  ld XIY,0x00fc4e8c
	ld	xix, SoundEditCopy_DrumValues_End	; F09BFA  ld XIX,0x00fc4ec4
	call	T_DisplayListB_Run	; F09BFF  call 0xf417f4
SoundEditCopy_Paint_Join:
	call	SoundEditCopy_DrawSoundName	; F09C03  call 0xf09c63
	ret	; F09C07  ret

; --------------------------------------------------------------------------
; SoundEditCopy_RepaintField
; Called from: table 0xF5B9F8[29]
; Touches: (0x2540) (0x27F5)  |  0xFC4EC4 0xFC4EE2 0xFC4EEC 0xFC4FA6 0xFC4FB6
; Calls:   T_DisplayList_Run SoundEditCopy_DrawSoundName T_DisplayListB_Run RunDisplayListBFromPointerArray
; Draws:   2 display-list call sites naming 2 distinct lists; their printable
;          runs: 0xFC4EE2-0xFC4EEC; 0xFC4EC4-0xFC4EE2
; Evidence: entry [29] of Dispatch_Code80_RepaintFieldTable, the parallel slot of the COPY
;           painter.
; --------------------------------------------------------------------------
SoundEditCopy_RepaintField:
	cp	a, 4:i3	; F09C08  cp A,4
	jr	z, SoundEditCopy_RepaintField_Skip	; F09C0A  jr Z,0xf09c2b
	cp	a, 5:i3	; F09C0C  cp A,5
	jr	z, SoundEditCopy_RepaintField_Skip2	; F09C0E  jr Z,0xf09c31
	cp	a, 2:i3	; F09C10  cp A,2
	jr	nz, SoundEditCopy_RepaintField_Join	; F09C12  jr NZ,0xf09c46
	ld	(LCD_CurrentLayer:16), 1	; F09C14  ld (0x2540),0x01
	ld	xiy, SoundEditCopy_Field2Box	; F09C19  ld XIY,0x00fc4ee2
	ld	xix, SoundEditCopy_Field2Box_End	; F09C1E  ld XIX,0x00fc4eec
	call	T_DisplayList_Run	; F09C23  call 0xf417f0
	ld	a, 2:opc	; F09C27  ld A,0x02
	jr	SoundEditCopy_RepaintField_Join	; F09C29  jr T,0xf09c46
SoundEditCopy_RepaintField_Skip:
	call	SoundEditCopy_DrawSoundName	; F09C2B  call 0xf09c63
	jr	SoundEditCopy_RepaintField_Return	; F09C2F  jr T,0xf09c62
SoundEditCopy_RepaintField_Skip2:
	ld	(LCD_CurrentLayer:16), 0	; F09C31  ld (0x2540),0x00
	ld	xiy, SoundEditCopy_DrumValues_End	; F09C36  ld XIY,0x00fc4ec4
	ld	xix, SoundEditCopy_Field2Box	; F09C3B  ld XIX,0x00fc4ee2
	call	T_DisplayListB_Run	; F09C40  call 0xf417f4
	jr	SoundEditCopy_RepaintField_Return	; F09C44  jr T,0xf09c62
SoundEditCopy_RepaintField_Join:
	cp	(SoundEdit_SoundKind:16), 0x01	; F09C46  cp (0x27f5),0x01
	jr	z, SoundEditCopy_RepaintField_Skip3	; F09C4B  jr Z,0xf09c54
	ld	xiy, SoundEditCopy_ToneFieldRecords	; F09C4D  ld XIY,0x00fc4fa6
	jr	SoundEditCopy_RepaintField_Join2	; F09C52  jr T,0xf09c59
SoundEditCopy_RepaintField_Skip3:
	ld	xiy, SoundEditCopy_DrumFieldRecords	; F09C54  ld XIY,0x00fc4fb6
SoundEditCopy_RepaintField_Join2:
	ld	(LCD_CurrentLayer:16), 0	; F09C59  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F09C5E  call 0xf09ae1
SoundEditCopy_RepaintField_Return:
	ret	; F09C62  ret

; --------------------------------------------------------------------------
; SoundEditCopy_DrawSoundName
; Called from: in-module: 0xF09C03 0xF09C2B
; Touches: (0x2540) (0x27B0) (0x27B1) (0x27B5) (0x27F5)
; Calls:   T_SoundName_Lookup
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription (the
;           sites are listed above), so 0xF09C63 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditCopy_DrawSoundName: SOUND EDIT COPY: looks up the name of sound (bank (0x27B0), number (0x27B1)) through
;   T_SoundName_Lookup; if byte 16 of the reply & 0xC0 is 0x40, (0x27B5) := 1 and nothing is drawn, else (0x27B5) := 0
;   and the 16-character name is printed (svc 0x20) at 0x0EB3, or 0x0AA3 in drum-kit mode. Basis: callers + body --
;   the last step of SoundEditCopy_Paint and SoundEditCopy_RepaintField's field 4. (notes/naming-
;   pilot-2026-10-06/proposals_wave2_d.json)
SoundEditCopy_DrawSoundName:
	ld	l, (ModelingPage_Fields+10:16)	; F09C63  ld L,(0x27b0)
	ld	w, l	; F09C67  ld W,L
	ld	h, (ModelingPage_Fields+11:16)	; F09C69  ld H,(0x27b1)
	ld	a, h	; F09C6D  ld A,H
	ld	b, 0:opc	; F09C6F  ld B,0x00
	call	T_SoundName_Lookup	; F09C71  call 0xf41010
	ld	a, (xiy+16)	; F09C75  ld A,(XIY+0x10)
	and	a, 192	; F09C78  and A,0xc0
	cp	a, 64	; F09C7B  cp A,0x40
	jr	nz, SoundEditCopy_DrawSoundName_Skip	; F09C7E  jr NZ,0xf09c87
	ld	(ModelingPage_Fields+15:16), 1	; F09C80  ld (0x27b5),0x01
	jr	SoundEditCopy_DrawSoundName_Return	; F09C85  jr T,0xf09ca8
SoundEditCopy_DrawSoundName_Skip:
	ld	(ModelingPage_Fields+15:16), 0	; F09C87  ld (0x27b5),0x00
	ldw	bc, 16	; F09C8C  ld BC,0x0010
	ld	(LCD_CurrentLayer:16), 0	; F09C8F  ld (0x2540),0x00
	xor	hl, hl	; F09C94  xor HL,HL
	cp	(SoundEdit_SoundKind:16), 0x01	; F09C96  cp (0x27f5),0x01
	jr	z, SoundEditCopy_DrawSoundName_Skip2	; F09C9B  jr Z,0xf09ca2
	ldw	ix, 3763	; F09C9D  ld IX,0x0eb3
	jr	SoundEditCopy_DrawSoundName_Join	; F09CA0  jr T,0xf09ca5
SoundEditCopy_DrawSoundName_Skip2:
	ldw	ix, 2723	; F09CA2  ld IX,0x0aa3
SoundEditCopy_DrawSoundName_Join:
	ld	a, 32:opc	; F09CA5  ld A,0x20
	swi	7	; F09CA7  swi 7
SoundEditCopy_DrawSoundName_Return:
	ret	; F09CA8  ret

; --------------------------------------------------------------------------
; SoundEditMenu_RepaintField
; Called from: table 0xF5B9F8[0]
; Touches: (0x2540)  |  0xFC517E 0xFC51B1 0xFC51D3 0xFC51F9 0xFC521B 0xFC524D
;          +4 more
; Calls:   T_DisplayListB_Run SoundEditMenu_PaintPanAmounts T_DisplayList_Run RunDisplayListBFromPointerArray
;          0xF5BF8A SoundEditMenu_PaintOrdinals
; Draws:   7 display-list call sites naming 5 distinct lists; their printable
;          runs: 0xFC524D-0xFC526F; 0xFC52AA-0xFC52B4; 0xFC517E-0xFC527A;
;          0xFC51B1-0xFC51D3; 0xFC51F9-0xFC521B
; Evidence: word [0] of the pointer table at 0xF5B9F8 reads 0x00F09CA9, that
;           table's reader TRANSFERS to the word it loads, and 0xF09CA9 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditMenu_RepaintField: Dispatch_Code80_RepaintFieldTable[code 0x80] -- Dispatch_Code80, the partial repaint.
SoundEditMenu_RepaintField:
	cp	a, 0:i3	; F09CA9  cp A,0
	jr	z, SoundEditMenu_RepaintField_Skip3	; F09CAB  jr Z,0xf09ce6
	cp	a, 1:i3	; F09CAD  cp A,1
	jr	z, SoundEditMenu_RepaintField_Skip4	; F09CAF  jr Z,0xf09d07
	cp	a, 2:i3	; F09CB1  cp A,2
	jr	z, SoundEditMenu_RepaintField_Skip5	; F09CB3  jr Z,0xf09d1c
	cp	a, 15	; F09CB5  cp A,0x0f
	jr	z, SoundEditMenu_RepaintField_Skip6	; F09CB8  jr Z,0xf09d23
	cp	a, 16	; F09CBA  cp A,0x10
	jrl	z, SoundEditMenu_RepaintField_Skip7	; F09CBD  jrl Z,0xf09d38
	cp	a, 50	; F09CC0  cp A,0x32
	jrl	z, SoundEditMenu_RepaintField_Skip8	; F09CC3  jrl Z,0xf09d4d
	cp	a, 13	; F09CC6  cp A,0x0d
	jrl	c, SoundEditMenu_RepaintField_Skip9	; F09CC9  jrl C,0xf09d82
	ld	(LCD_CurrentLayer:16), 0	; F09CCC  ld (0x2540),0x00
	ld	xiy, SoundEditMenu_RepaintField_DL1	; F09CD1  ld XIY,0x00fc524d
	ld	xix, DLRec_FC526F	; F09CD6  ld XIX,0x00fc526f
	call	T_DisplayListB_Run	; F09CDB  call 0xf417f4
	call	SoundEditMenu_PaintPanAmounts	; F09CDF  call 0xf09ded
	jrl	SoundEditMenu_RepaintField_Return2	; F09CE3  jrl T,0xf09d90
SoundEditMenu_RepaintField_Skip3:
	ld	(LCD_CurrentLayer:16), 1	; F09CE6  ld (0x2540),0x01
	ld	xiy, SoundEditMenu_RepaintField_DL2	; F09CEB  ld XIY,0x00fc52aa
	ld	xix, DisplayList_FC52AA_End	; F09CF0  ld XIX,0x00fc52b4
	call	T_DisplayList_Run	; F09CF5  call 0xf417f0
	ld	a, 0:opc	; F09CF9  ld A,0x00
	ld	xiy, DisplayList_FC52AA_End	; F09CFB  ld XIY,0x00fc52b4
	call	RunDisplayListBFromPointerArray	; F09D00  call 0xf09ae1
	jrl	SoundEditMenu_RepaintField_Return2	; F09D04  jrl T,0xf09d90
SoundEditMenu_RepaintField_Skip4:
	ld	xiy, DisplayList_FC517E	; F09D07  ld XIY,0x00fc517e
	ld	xix, DisplayList_FC517E_End	; F09D0C  ld XIX,0x00fc527a
	call	T_DisplayListB_Run	; F09D11  call 0xf417f4
	call	ModelingPage_PaintFields11And12	; F09D15  call 0xf5bf8a
	jrl	SoundEditMenu_RepaintField_Return2	; F09D19  jrl T,0xf09d90
SoundEditMenu_RepaintField_Skip5:
	call	SoundEditMenu_PaintOrdinals	; F09D1C  call 0xf09d91
	jrl	SoundEditMenu_RepaintField_Return2	; F09D20  jrl T,0xf09d90
SoundEditMenu_RepaintField_Skip6:
	ld	(LCD_CurrentLayer:16), 0	; F09D23  ld (0x2540),0x00
	ld	xiy, SoundEditMenu_RepaintField_DL3	; F09D28  ld XIY,0x00fc51b1
	ld	xix, DLRec_FC51D3	; F09D2D  ld XIX,0x00fc51d3
	call	T_DisplayListB_Run	; F09D32  call 0xf417f4
	jr	SoundEditMenu_RepaintField_Return2	; F09D36  jr T,0xf09d90
SoundEditMenu_RepaintField_Skip7:
	ld	(LCD_CurrentLayer:16), 0	; F09D38  ld (0x2540),0x00
	ld	xiy, SoundEditMenu_RepaintField_DL4	; F09D3D  ld XIY,0x00fc51f9
	ld	xix, DLRec_FC521B	; F09D42  ld XIX,0x00fc521b
	call	T_DisplayListB_Run	; F09D47  call 0xf417f4
	jr	SoundEditMenu_RepaintField_Return2	; F09D4B  jr T,0xf09d90
SoundEditMenu_RepaintField_Skip8:
	ld	(LCD_CurrentLayer:16), 1	; F09D4D  ld (0x2540),0x01
	ld	xiy, SoundEditMenu_RepaintField_DL2	; F09D52  ld XIY,0x00fc52aa
	ld	xix, DisplayList_FC52AA_End	; F09D57  ld XIX,0x00fc52b4
	call	T_DisplayList_Run	; F09D5C  call 0xf417f0
	ld	(LCD_CurrentLayer:16), 0	; F09D60  ld (0x2540),0x00
	call	SoundEditMenu_PaintOrdinals	; F09D65  call 0xf09d91
	ld	xiy, DisplayList_FC517E	; F09D69  ld XIY,0x00fc517e
	ld	xix, DisplayList_FC517E_End	; F09D6E  ld XIX,0x00fc527a
	call	T_DisplayListB_Run	; F09D73  call 0xf417f4
	ld	(LCD_CurrentLayer:16), 0	; F09D77  ld (0x2540),0x00
	call	SoundEditMenu_PaintPanAmounts	; F09D7C  call 0xf09ded
	jr	SoundEditMenu_RepaintField_Return2	; F09D80  jr T,0xf09d90
SoundEditMenu_RepaintField_Skip9:
	ld	xiy, DisplayList_FC52AA_End	; F09D82  ld XIY,0x00fc52b4
	ld	(LCD_CurrentLayer:16), 0	; F09D87  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F09D8C  call 0xf09ae1
SoundEditMenu_RepaintField_Return2:
	ret	; F09D90  ret

; --------------------------------------------------------------------------
; SoundEditMenu_PaintOrdinals
; Called from: in-module: 0xF09D1C 0xF09D65
; Touches: (0x2540) (0x27A4)  |  0xF03B6F 0xF03BA9
; Calls:   T_DisplayList_Run
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription (the
;           sites are listed above), so 0xF09D91 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditMenu_PaintOrdinals: Paints the '1st' / '2nd' rows of the SOUND EDIT MENU on layer 0, each with a filled
;   radio dot when its slot bit of (0x27A4) (bit 2n-2, Var27A4_SlotEnabled) is set, an empty circle when not. Two-row
;   form of UiPaint_Ordinals; called by SoundEditMenu_Paint and SoundEditMenu_RepaintField (fields 2 and 50). Basis:
;   callers + body + sibling. (notes/naming-pilot-2026-10-06/proposals_wave2_e.json)
SoundEditMenu_PaintOrdinals:
	ld	(LCD_CurrentLayer:16), 0	; F09D91  ld (0x2540),0x00
	ld	c, 2:opc	; F09D96  ld C,0x02
	ld	w, (ToneEdit_LayerOnBits:16)	; F09D98  ld W,(0x27a4)
	ld	a, c	; F09D9C  ld A,C
	sla	a, 1	; F09D9E  sla 0x01,A
	dec	1, a	; F09DA1  dec 1,A
	.byte 0xC8, 0xFF	; F09DA3  srl A,W   [llvm-mc cannot encode this]
	jr	c, SoundEditMenu_PaintOrdinals_Skip	; F09DA5  jr C,0xf09dc9
	push	c	; F09DA7  push C
	xor	b, b	; F09DA9  xor B,B
	sla	bc, 2	; F09DAB  sla 0x02,BC
	ld	xiz, Data_F03B6F + 0x3A	; F09DAE  ld XIZ,0x00f03ba9
	ld	xiy, (xiz+bc)	; F09DB3  ld XIY,(XIZ+BC)
	add	bc, 4	; F09DB8  add BC,0x0004
	ld	xix, (xiz+bc)	; F09DBC  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F09DC1  call 0xf417f0
	pop	c	; F09DC5  pop C
	jr	SoundEditMenu_PaintOrdinals_Join	; F09DC7  jr T,0xf09de9
SoundEditMenu_PaintOrdinals_Skip:
	push	c	; F09DC9  push C
	xor	b, b	; F09DCB  xor B,B
	sla	bc, 2	; F09DCD  sla 0x02,BC
	ld	xiz, Data_F03B6F	; F09DD0  ld XIZ,0x00f03b6f
	ld	xiy, (xiz+bc)	; F09DD5  ld XIY,(XIZ+BC)
	add	bc, 4	; F09DDA  add BC,0x0004
	ld	xix, (xiz+bc)	; F09DDE  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F09DE3  call 0xf417f0
	pop	c	; F09DE7  pop C
SoundEditMenu_PaintOrdinals_Join:
	djnz8	c, -84	; F09DE9  djnz C,0xf09d98
	ret	; F09DEC  ret

; --------------------------------------------------------------------------
; SoundEditMenu_PaintPanAmounts
; Called from: in-module: 0xF09CDF 0xF09D7C
; Touches: (0x2540)
; Calls:   SoundEditMenu_PaintPanAmountField
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription (the
;           sites are listed above), so 0xF09DED is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditMenu_PaintPanAmounts: For fields 13 and 14 (SoundEditMenu_PaintPanAmountField): when ModelingPage_Fields[n] != 0, draws record [n]
;   of DisplayRecordPtrs_FC52B4, a 2-digit readout of Fields+13 / +14 at x 0x109, y 0x7A / 0x98 -- the PAN column of
;   the User Kit SOUND EDIT menu, beside the CTR/L/R/RDM mode of Fields+12. Basis: callers + body + display-list
;   records. (notes/naming-pilot-2026-10-06/proposals_wave2_f.json)
SoundEditMenu_PaintPanAmounts:
	ld	(LCD_CurrentLayer:16), 0	; F09DED  ld (0x2540),0x00
	ld	a, 13:opc	; F09DF2  ld A,0x0d
SoundEditMenu_PaintPanAmounts_Loop:
	push_a	; F09DF4  push A
	call	SoundEditMenu_PaintPanAmountField	; F09DF5  call 0xf09e02
	pop_a	; F09DF9  pop A
	inc	1, a	; F09DFA  inc 1,A
	cp	a, 15	; F09DFC  cp A,0x0f
	jr	c, SoundEditMenu_PaintPanAmounts_Loop	; F09DFF  jr C,0xf09df4
	ret	; F09E01  ret

; --------------------------------------------------------------------------
; SoundEditMenu_PaintPanAmountField
; Called from: in-module: 0xF09DF5
; Touches: (0x2540)  |  0xF03B6F 0xFC52B4
; Calls:   RunDisplayListBFromPointerArray T_DisplayList_Run sub_F09E67
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription (the
;           sites are listed above), so 0xF09E02 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditMenu_PaintPanAmountField: For field A (13 or 14): when ModelingPage_Fields[A] is non-zero, draws record [A]
;   of DisplayRecordPtrs_FC52B4 on layer 0 (RunDisplayListBFromPointerArray) -- one 2-digit PAN amount of the User Kit
;   SOUND EDIT menu. SoundEditMenu_PaintPanAmounts calls it for A = 13 and 14. Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave3_j.json)
SoundEditMenu_PaintPanAmountField:
	xor	xbc, xbc	; F09E02  xor XBC,XBC
	xor	w, w	; F09E04  xor W,W
	ldw	bc, ModelingPage_Fields	; F09E06  ld BC,0x27a6
	add	bc, wa	; F09E09  add BC,WA
	ld	d, (xbc)	; F09E0B  ld D,(XBC)
	cp	d, 0:i3	; F09E0D  cp D,0
	jr	z, SoundEditMenu_PaintPanAmountField_Return	; F09E0F  jr Z,0xf09e1f
	ld	xiy, DisplayList_FC52AA_End	; F09E11  ld XIY,0x00fc52b4
	ld	(LCD_CurrentLayer:16), 0	; F09E16  ld (0x2540),0x00
	call	RunDisplayListBFromPointerArray	; F09E1B  call 0xf09ae1
SoundEditMenu_PaintPanAmountField_Return:
	ret	; F09E1F  ret
	push	xwa	; F09E20  push XWA
	push	xbc	; F09E21  push XBC
	push	xde	; F09E22  push XDE
	push	xhl	; F09E23  push XHL
	push	xix	; F09E24  push XIX
	push	xiy	; F09E25  push XIY
	push	xiz	; F09E26  push XIZ
	pop	xiz	; F09E27  pop XIZ
	pop	xiy	; F09E28  pop XIY
	pop	xix	; F09E29  pop XIX
	pop	xhl	; F09E2A  pop XHL
	pop	xde	; F09E2B  pop XDE
	pop	xbc	; F09E2C  pop XBC
	pop	xwa	; F09E2D  pop XWA
	ret	; F09E2E  ret
	max	; F09E2F  max
	xor	b, b	; F09E30  xor B,B
	sla	bc, 2	; F09E32  sla 0x02,BC
	ld	xiz, Data_F03B6F	; F09E35  ld XIZ,0x00f03b6f
	ld	xiy, (xiz+bc)	; F09E3A  ld XIY,(XIZ+BC)
	add	bc, 4	; F09E3F  add BC,0x0004
	ld	xix, (xiz+bc)	; F09E43  ld XIX,(XIZ+BC)
	call	T_DisplayList_Run	; F09E48  call 0xf417f0
	pop	c	; F09E4C  pop C
	djnz8	c, -84	; F09E4E  djnz C,0xf09dfd
	ret	; F09E51  ret
	ld	(LCD_CurrentLayer:16), 0	; F09E52  ld (0x2540),0x00
	ld	a, 13:opc	; F09E57  ld A,0x0d
SoundEditMenu_PaintPanAmountField_Loop:
	push_a	; F09E59  push A
	call	sub_F09E67	; F09E5A  call 0xf09e67
	pop_a	; F09E5E  pop A
	inc	1, a	; F09E5F  inc 1,A
	cp	a, 15	; F09E61  cp A,0x0f
	jr	c, SoundEditMenu_PaintPanAmountField_Loop	; F09E64  jr C,0xf09e59
	ret	; F09E66  ret

; --------------------------------------------------------------------------
; sub_F09E67
; Called from: in-module: 0xF09E5A
; Touches: (0x2540)  |  0xFC52B4
; Calls:   0xF09AB0
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription (the
;           sites are listed above), so 0xF09E67 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
sub_F09E67:
	xor	xbc, xbc	; F09E67  xor XBC,XBC
	xor	w, w	; F09E69  xor W,W
	ldw	bc, ModelingPage_Fields	; F09E6B  ld BC,0x27a6
	add	bc, wa	; F09E6E  add BC,WA
	ld	d, (xbc)	; F09E70  ld D,(XBC)
	cp	d, 0:i3	; F09E72  cp D,0
	jr	z, sub_F09E67_Return	; F09E74  jr Z,0xf09e84
	ld	xiy, DisplayList_FC52AA_End	; F09E76  ld XIY,0x00fc52b4
	ld	(LCD_CurrentLayer:16), 0	; F09E7B  ld (0x2540),0x00
; stale: sub_F09E67 is reached only from the unlabelled loop at 0xF09E52, an older copy of SoundEditMenu_PaintPanAmounts.  Its live
; twin SoundEditMenu_PaintPanAmountField has the same bytes except this operand, and calls RunDisplayListBFromPointerArray 0x31 higher.
	call	RunDisplayListBFromPointerArray - 0x31	; F09E80  call 0xf09ab0
sub_F09E67_Return:
	ret	; F09E84  ret

; --------------------------------------------------------------------------
; Unclaimed_F09E85 -- 379 bytes that are ALMOST CERTAINLY CODE and are
;                     deliberately NOT claimed as code.  Nothing in either
;                     image references any address inside them, so the layout
;                     has no entry point to start a walk from, and this tree
;                     does not promote a run to code on the strength of a
;                     decode alone.
; Decodes as: a 15-byte `push`x7 / `pop`x7 / `ret` stub at 0xF09E85; one
;             routine at 0xF09E94 whose `link` lies OUTSIDE the region and
;             which ends `unlk XIZ` 0xF09EB0 / `ret` 0xF09EB2; then THIRTEEN
;             `link XIZ,0x0000 / ... / unlk XIZ / ret` routines at 0xF09EB3
;             0xF09ED7 0xF09EEF 0xF09F0F 0xF09F24 0xF09F39 0xF09F4E 0xF09F63
;             0xF09F78 0xF09F8D 0xF09FA2 0xF09FC0 0xF09FE4; then a 4-byte
;             `link XIZ,0x0000` at 0xF09FFC with no body at all.
; Evidence: ⚠ CORRECTION C3.  Round 1 said TWELVE such routines; there are
;           THIRTEEN.  Each is closed by its own `unlk XIZ / ret` and the next
;           `link` starts at the very next byte, so the framing is self-
;           checking; a raw scan for the `link XIZ` opcode pair 0xEE 0x0C over
;           0xF09E85-0xF09FFF finds 14 hits, of which the bodyless 0xF09FFC is
;           the fourteenth.  --selftest re-derives the thirteen addresses from
;           the ROM.
; Unknown: who calls any of them.  ⚠ Round 1's open question 5 stands:
;          0xF09FFC is a `link XIZ,0x0000` with no body, immediately before a
;          thunk target that begins `link XIZ,0xFFFC`.  It is not padding in
;          any shape this tree has seen.  What this region needs is a
;          REFERENCE, not a better decoder.
; --------------------------------------------------------------------------
Unclaimed_F09E85:
	.byte	0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x5E, 0x5D, 0x5C, 0x5B, 0x5A, 0x59, 0x58, 0x0E, 0x08	; F09E85  |89:;<=>^]\[ZYX..|
	.byte	0x3F, 0x00, 0x66, 0x17, 0x0B, 0x03, 0x00, 0x1D, 0xCD, 0x88, 0xFD, 0x49, 0xC9, 0xD8, 0x66, 0x0B	; F09E95  |?.f........I..f.|
	.byte	0x0B, 0x01, 0x00, 0x0B, 0x89, 0x00, 0x1D, 0xF8, 0x76, 0xFD, 0x5D, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C	; F09EA5  |........v.].....|
	.byte	0x00, 0x00, 0x8E, 0x08, 0x3F, 0x00, 0x66, 0x17, 0x0B, 0x04, 0x00, 0x1D, 0xCD, 0x88, 0xFD, 0x49	; F09EB5  |....?.f........I|
	.byte	0xC9, 0xD8, 0x66, 0x0B, 0x0B, 0x01, 0x00, 0x0B, 0x89, 0x00, 0x1D, 0xF8, 0x76, 0xFD, 0x5D, 0xEE	; F09EC5  |..f.........v.].|
	.byte	0x0D, 0x0E, 0xEE, 0x0C, 0x00, 0x00, 0x8E, 0x08, 0x3F, 0x00, 0x66, 0x0B, 0x0B, 0x00, 0x00, 0x0B	; F09ED5  |........?.f.....|
	.byte	0x88, 0x00, 0x1D, 0xF8, 0x76, 0xFD, 0x5D, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C, 0x00, 0x00, 0x8E, 0x08	; F09EE5  |....v.].........|
	.byte	0x3F, 0x00, 0x6E, 0x13, 0x0B, 0x00, 0x00, 0x1D, 0x66, 0x7E, 0xFD, 0x0B, 0x00, 0x00, 0x0B, 0x80	; F09EF5  |?.n.....f~......|
	.byte	0x00, 0x1D, 0xF8, 0x76, 0xFD, 0xEF, 0x66, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C, 0x00, 0x00, 0x0B, 0x01	; F09F05  |...v..f.........|
	.byte	0x00, 0x9E, 0x08, 0x21, 0xD9, 0x12, 0x29, 0x1D, 0xF9, 0x90, 0xFD, 0x59, 0xEE, 0x0D, 0x0E, 0xEE	; F09F15  |...!..)....Y....|
	.byte	0x0C, 0x00, 0x00, 0x0B, 0x01, 0x00, 0x9E, 0x08, 0x21, 0xD9, 0x12, 0x29, 0x1D, 0x45, 0x91, 0xFD	; F09F25  |........!..).E..|
	.byte	0x59, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C, 0x00, 0x00, 0x0B, 0x01, 0x00, 0x9E, 0x08, 0x21, 0xD9, 0x12	; F09F35  |Y............!..|
	.byte	0x29, 0x1D, 0xB8, 0x91, 0xFD, 0x59, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C, 0x00, 0x00, 0x0B, 0x01, 0x00	; F09F45  |)....Y..........|
	.byte	0x9E, 0x08, 0x21, 0xD9, 0x12, 0x29, 0x1D, 0x2B, 0x92, 0xFD, 0x59, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C	; F09F55  |..!..).+..Y.....|
	.byte	0x00, 0x00, 0x0B, 0x01, 0x00, 0x9E, 0x08, 0x21, 0xD9, 0x12, 0x29, 0x1D, 0x9E, 0x92, 0xFD, 0x59	; F09F65  |.......!..)....Y|
	.byte	0xEE, 0x0D, 0x0E, 0xEE, 0x0C, 0x00, 0x00, 0x0B, 0x01, 0x00, 0x9E, 0x08, 0x21, 0xD9, 0x12, 0x29	; F09F75  |............!..)|
	.byte	0x1D, 0x0F, 0x93, 0xFD, 0x59, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C, 0x00, 0x00, 0x0B, 0x01, 0x00, 0x9E	; F09F85  |....Y...........|
	.byte	0x08, 0x21, 0xD9, 0x12, 0x29, 0x1D, 0x82, 0x93, 0xFD, 0x59, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C, 0x00	; F09F95  |.!..)....Y......|
	.byte	0x00, 0x8E, 0x08, 0x3F, 0x00, 0x6E, 0x0D, 0x0B, 0x00, 0x00, 0x0B, 0x88, 0x00, 0x1D, 0xF8, 0x76	; F09FA5  |...?.n.........v|
	.byte	0xFD, 0x5D, 0x68, 0x04, 0x1D, 0x07, 0x83, 0xFD, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C, 0x00, 0x00, 0x8E	; F09FB5  |.]h.............|
	.byte	0x08, 0x3F, 0x00, 0x6E, 0x0C, 0x0B, 0x00, 0x00, 0x0B, 0x87, 0x00, 0x1D, 0xF8, 0x76, 0xFD, 0x68	; F09FC5  |.?.n.........v.h|
	.byte	0x0A, 0x0B, 0x01, 0x00, 0x0B, 0x01, 0x00, 0x1D, 0xFF, 0x88, 0xFD, 0x5D, 0xEE, 0x0D, 0x0E, 0xEE	; F09FD5  |...........]....|
	.byte	0x0C, 0x00, 0x00, 0x8E, 0x08, 0x3F, 0x00, 0x66, 0x0B, 0x0B, 0x02, 0x00, 0x0B, 0x01, 0x00, 0x1D	; F09FE5  |.....?.f........|
	.byte	0xFF, 0x88, 0xFD, 0x5D, 0xEE, 0x0D, 0x0E, 0xEE, 0x0C, 0x00, 0x00	; F09FF5  |...].......|


; --------------------------------------------------------------------------
; ScreenButton_SoundEditPitchTune
; Called from: T_ScreenButton_SoundEditPitchTune (x0)
; Touches:   |  0xFCF383
; Calls:   0xFD7905 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditPitchTune holds `jp 0x00F0A000`, and 0xF0A000 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditPitchTune: the +8 BUTTON method of PanelScreen_VtableTable entry 0x87: that entry points at the thunk triple T_ScreenEnter_SoundEditPitchTune (Enter) / T_ScreenLeave_SoundEditPitchTune (Leave) / T_ScreenButton_SoundEditPitchTune (Button).
ScreenButton_SoundEditPitchTune:		; <- T_ScreenButton_SoundEditPitchTune
	link XIZ,0xfffc	; F0A000  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0A004  lda XBC,XIZ+0xfe
	push	xbc	; F0A007  push XBC
	lda	xwa, (xiz-4)	; F0A008  lda XWA,XIZ+0xfc
	push	xwa	; F0A00B  push XWA
	pushw	(xiz+10)	; F0A00C  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0A00F  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0A012  call 0xfd7905
	inc	8, xsp	; F0A016  inc 0,XSP
	inc	4, xsp	; F0A018  inc 4,XSP
	cp	wa, 65535	; F0A01A  cp WA,0xffff
	jr	z, ScreenButton_SoundEditPitchTune_Skip	; F0A01E  jr Z,0xf0a04e
	ld	bc, (xiz-2)	; F0A020  ld BC,(XIZ+0xfe)
	extz	bc	; F0A023  extz BC
	pushw	bc	; F0A025  push BC
	ld	c, 4:opc	; F0A026  ld C,0x04
	mul	bc, (xiz-4)	; F0A028  mul BC,(XIZ+0xfc)
	extz	xbc	; F0A02B  extz XBC
	add	xbc, PanelOpTable_FCF383	; F0A02D  add XBC,0x00fcf383
	ld	xbc, (xbc)	; F0A033  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditPitchTune_Resume:24)	; F0A035  lda XIY,0xf0a03d
	push	xiy	; F0A03A  push XIY
	jp	(xbc)	; F0A03B  jp T,XBC
ScreenButton_SoundEditPitchTune_Resume:
	call	PanelScreen_RequestPending	; F0A03D  call 0xfd60b9
	popw	bc	; F0A041  pop BC
	cp	a, 0:i3	; F0A042  cp A,0
	jr	nz, ScreenButton_SoundEditPitchTune_Skip	; F0A044  jr NZ,0xf0a04e
	pushw	16	; F0A046  push 0x0010
	call	ToneMsg80_Id00	; F0A049  call 0xfd6447
	popw	bc	; F0A04D  pop BC
ScreenButton_SoundEditPitchTune_Skip:
	unlk XIZ	; F0A04E  unlk XIZ
	ret	; F0A050  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditPitchEnvelope1
; Called from: T_ScreenButton_SoundEditPitchEnvelope1 (x0)
; Touches:   |  0xFCF3CB
; Calls:   0xFD7905 0xFDAC5B 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditPitchEnvelope1 holds `jp 0x00F0A051`, and 0xF0A051 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditPitchEnvelope1: the +8 BUTTON method of PanelScreen_VtableTable entry 0x88: that entry points at the thunk triple T_ScreenEnter_SoundEditPitchEnvelope1 (Enter) / T_ScreenLeave_SoundEditPitchEnvelope1 (Leave) / T_ScreenButton_SoundEditPitchEnvelope1 (Button).
ScreenButton_SoundEditPitchEnvelope1:		; <- T_ScreenButton_SoundEditPitchEnvelope1
	link XIZ,0xfffc	; F0A051  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0A055  lda XBC,XIZ+0xfe
	push	xbc	; F0A058  push XBC
	lda	xwa, (xiz-4)	; F0A059  lda XWA,XIZ+0xfc
	push	xwa	; F0A05C  push XWA
	pushw	(xiz+10)	; F0A05D  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0A060  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0A063  call 0xfd7905
	inc	8, xsp	; F0A067  inc 0,XSP
	inc	4, xsp	; F0A069  inc 4,XSP
	cp	wa, 65535	; F0A06B  cp WA,0xffff
	jr	z, ScreenButton_SoundEditPitchEnvelope1_Skip	; F0A06F  jr Z,0xf0a0ae
	pushw	1	; F0A071  push 0x0001
	call	LCD_SetPanelDarkFlag	; F0A074  call 0xfdac5b
	ld	bc, (xiz-2)	; F0A078  ld BC,(XIZ+0xfe)
	extz	bc	; F0A07B  extz BC
	pushw	bc	; F0A07D  push BC
	ld	c, 4:opc	; F0A07E  ld C,0x04
	mul	bc, (xiz-4)	; F0A080  mul BC,(XIZ+0xfc)
	extz	xbc	; F0A083  extz XBC
	add	xbc, PanelOpTable_FCF3CB	; F0A085  add XBC,0x00fcf3cb
	ld	xbc, (xbc)	; F0A08B  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditPitchEnvelope1_Resume:24)	; F0A08D  lda XIY,0xf0a095
	push	xiy	; F0A092  push XIY
	jp	(xbc)	; F0A093  jp T,XBC
ScreenButton_SoundEditPitchEnvelope1_Resume:
	pushw	0	; F0A095  push 0x0000
	call	LCD_SetPanelDarkFlag	; F0A098  call 0xfdac5b
	call	PanelScreen_RequestPending	; F0A09C  call 0xfd60b9
	inc	6, xsp	; F0A0A0  inc 6,XSP
	cp	a, 0:i3	; F0A0A2  cp A,0
	jr	nz, ScreenButton_SoundEditPitchEnvelope1_Skip	; F0A0A4  jr NZ,0xf0a0ae
	pushw	16	; F0A0A6  push 0x0010
	call	ToneMsg80_Id00	; F0A0A9  call 0xfd6447
	popw	bc	; F0A0AD  pop BC
ScreenButton_SoundEditPitchEnvelope1_Skip:
	unlk XIZ	; F0A0AE  unlk XIZ
	ret	; F0A0B0  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditPitchEnvelope2
; Called from: T_ScreenButton_SoundEditPitchEnvelope2 (x0)
; Touches:   |  0xFCF413
; Calls:   0xFD7905 0xFDAC5B 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditPitchEnvelope2 holds `jp 0x00F0A0B1`, and 0xF0A0B1 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditPitchEnvelope2: the +8 BUTTON method of PanelScreen_VtableTable entry 0x89: that entry points at the thunk triple T_ScreenEnter_SoundEditPitchEnvelope2 (Enter) / T_ScreenLeave_SoundEditPitchEnvelope2 (Leave) / T_ScreenButton_SoundEditPitchEnvelope2 (Button).
ScreenButton_SoundEditPitchEnvelope2:		; <- T_ScreenButton_SoundEditPitchEnvelope2
	link XIZ,0xfffc	; F0A0B1  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0A0B5  lda XBC,XIZ+0xfe
	push	xbc	; F0A0B8  push XBC
	lda	xwa, (xiz-4)	; F0A0B9  lda XWA,XIZ+0xfc
	push	xwa	; F0A0BC  push XWA
	pushw	(xiz+10)	; F0A0BD  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0A0C0  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0A0C3  call 0xfd7905
	inc	8, xsp	; F0A0C7  inc 0,XSP
	inc	4, xsp	; F0A0C9  inc 4,XSP
	cp	wa, 65535	; F0A0CB  cp WA,0xffff
	jr	z, ScreenButton_SoundEditPitchEnvelope2_Skip	; F0A0CF  jr Z,0xf0a10e
	pushw	1	; F0A0D1  push 0x0001
	call	LCD_SetPanelDarkFlag	; F0A0D4  call 0xfdac5b
	ld	bc, (xiz-2)	; F0A0D8  ld BC,(XIZ+0xfe)
	extz	bc	; F0A0DB  extz BC
	pushw	bc	; F0A0DD  push BC
	ld	c, 4:opc	; F0A0DE  ld C,0x04
	mul	bc, (xiz-4)	; F0A0E0  mul BC,(XIZ+0xfc)
	extz	xbc	; F0A0E3  extz XBC
	add	xbc, PanelOpTable_FCF413	; F0A0E5  add XBC,0x00fcf413
	ld	xbc, (xbc)	; F0A0EB  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditPitchEnvelope2_Resume:24)	; F0A0ED  lda XIY,0xf0a0f5
	push	xiy	; F0A0F2  push XIY
	jp	(xbc)	; F0A0F3  jp T,XBC
ScreenButton_SoundEditPitchEnvelope2_Resume:
	pushw	0	; F0A0F5  push 0x0000
	call	LCD_SetPanelDarkFlag	; F0A0F8  call 0xfdac5b
	call	PanelScreen_RequestPending	; F0A0FC  call 0xfd60b9
	inc	6, xsp	; F0A100  inc 6,XSP
	cp	a, 0:i3	; F0A102  cp A,0
	jr	nz, ScreenButton_SoundEditPitchEnvelope2_Skip	; F0A104  jr NZ,0xf0a10e
	pushw	16	; F0A106  push 0x0010
	call	ToneMsg80_Id00	; F0A109  call 0xfd6447
	popw	bc	; F0A10D  pop BC
ScreenButton_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F0A10E  unlk XIZ
	ret	; F0A110  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditPitchLfo
; Called from: T_ScreenButton_SoundEditPitchLfo (x0)
; Touches:   |  0xFCF45B
; Calls:   0xFD7905 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditPitchLfo holds `jp 0x00F0A111`, and 0xF0A111 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditPitchLfo: the +8 BUTTON method of PanelScreen_VtableTable entry 0x8A: that entry points at the thunk triple T_ScreenEnter_SoundEditPitchLfo (Enter) / T_ScreenLeave_SoundEditPitchLfo (Leave) / T_ScreenButton_SoundEditPitchLfo (Button).
ScreenButton_SoundEditPitchLfo:		; <- T_ScreenButton_SoundEditPitchLfo
	link XIZ,0xfffc	; F0A111  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0A115  lda XBC,XIZ+0xfe
	push	xbc	; F0A118  push XBC
	lda	xwa, (xiz-4)	; F0A119  lda XWA,XIZ+0xfc
	push	xwa	; F0A11C  push XWA
	pushw	(xiz+10)	; F0A11D  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0A120  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0A123  call 0xfd7905
	inc	8, xsp	; F0A127  inc 0,XSP
	inc	4, xsp	; F0A129  inc 4,XSP
	cp	wa, 65535	; F0A12B  cp WA,0xffff
	jr	z, ScreenButton_SoundEditPitchLfo_Skip	; F0A12F  jr Z,0xf0a15f
	ld	bc, (xiz-2)	; F0A131  ld BC,(XIZ+0xfe)
	extz	bc	; F0A134  extz BC
	pushw	bc	; F0A136  push BC
	ld	c, 4:opc	; F0A137  ld C,0x04
	mul	bc, (xiz-4)	; F0A139  mul BC,(XIZ+0xfc)
	extz	xbc	; F0A13C  extz XBC
	add	xbc, PanelOpTable_FCF45B	; F0A13E  add XBC,0x00fcf45b
	ld	xbc, (xbc)	; F0A144  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditPitchLfo_Resume:24)	; F0A146  lda XIY,0xf0a14e
	push	xiy	; F0A14B  push XIY
	jp	(xbc)	; F0A14C  jp T,XBC
ScreenButton_SoundEditPitchLfo_Resume:
	call	PanelScreen_RequestPending	; F0A14E  call 0xfd60b9
	popw	bc	; F0A152  pop BC
	cp	a, 0:i3	; F0A153  cp A,0
	jr	nz, ScreenButton_SoundEditPitchLfo_Skip	; F0A155  jr NZ,0xf0a15f
	pushw	16	; F0A157  push 0x0010
	call	ToneMsg80_Id00	; F0A15A  call 0xfd6447
	popw	bc	; F0A15E  pop BC
ScreenButton_SoundEditPitchLfo_Skip:
	unlk XIZ	; F0A15F  unlk XIZ
	ret	; F0A161  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditPitchTune
; Called from: table 0xFCF21B[91]
; Touches: nothing with an absolute address
; Calls:   0xFD6B4D 0xFD6C7B 0xFD7C2D 0xFD7435 0xFD7C01
; Evidence: word [91] of the pointer table at 0xFCF21B reads 0x00F0A162, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A162 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditPitchTune: SOFT KEY column 2 (lower or upper; the flag carries which) on ScreenCode87 -- ScreenCode87 op 1 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol2_SoundEditPitchTune:
	link XIZ,0xfff2	; F0A162  link XIZ,0xfff2
	pushw	hl	; F0A166  push HL
	pushw	de	; F0A167  push DE
	push	xix	; F0A168  push XIX
	lda	xix, (xiz-14)	; F0A169  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0A16C  lda XBC,XIZ+0xfe
	push	xbc	; F0A16F  push XBC
	call	Var27A3_GetValidSlot	; F0A170  call 0xfd6b4d
	ld	c, 3:opc	; F0A174  ld C,0x03
	mul	bc, (xiz-2)	; F0A176  mul BC,(XIZ+0xfe)
	ld	h, c	; F0A179  ld H,C
	dec	2, h	; F0A17B  dec 2,H
	push	xix	; F0A17D  push XIX
	ld	c, h	; F0A17E  ld C,H
	extz	bc	; F0A180  extz BC
	ld	de, bc	; F0A182  ld DE,BC
	pushw	bc	; F0A184  push BC
	call	Arr27A6_Get	; F0A185  call 0xfd6c7b
	ld	(xix+6), 255	; F0A189  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0A18D  ld (XIX+0x07),0x00
	ld	(xix+8), 24	; F0A191  ld (XIX+0x08),0x18
	ld	(xix+9), 232	; F0A195  ld (XIX+0x09),0xe8
	ld	xbc, xix	; F0A199  ld XBC,XIX
	add	xbc, 10	; F0A19B  add XBC,0x0000000a
	push	xbc	; F0A1A1  push XBC
	ld	bc, (xiz+8)	; F0A1A2  ld BC,(XIZ+0x08)
	extz	bc	; F0A1A5  extz BC
	pushw	bc	; F0A1A7  push BC
	call	ToneEdit_StepFromEvent	; F0A1A8  call 0xfd7c2d
	push	xix	; F0A1AC  push XIX
	pushw	4	; F0A1AD  push 0x0004
	ld	bc, (xiz-2)	; F0A1B0  ld BC,(XIZ+0xfe)
	extz	bc	; F0A1B3  extz BC
	pushw	bc	; F0A1B5  push BC
	pushw	de	; F0A1B6  push DE
	pushw	135	; F0A1B7  push 0x0087
	call	ToneEdit_CommitField	; F0A1BA  call 0xfd7435
	pushw	2	; F0A1BE  push 0x0002
	call	PanelDial_ActAsButton	; F0A1C1  call 0xfd7c01
	add	xsp, 30	; F0A1C5  add XSP,0x0000001e
	pop	xix	; F0A1CB  pop XIX
	popw	de	; F0A1CC  pop DE
	popw	hl	; F0A1CD  pop HL
	unlk XIZ	; F0A1CE  unlk XIZ
	ret	; F0A1D0  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditPitchTune
; Called from: table 0xFCF21B[92]
; Touches: nothing with an absolute address
; Calls:   0xFD6B4D 0xFD6C7B 0xFD7C2D 0xFD7435 0xFD7C01
; Evidence: word [92] of the pointer table at 0xFCF21B reads 0x00F0A1D1, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A1D1 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditPitchTune: SOFT KEY column 3 (lower or upper; the flag carries which) on ScreenCode87 -- ScreenCode87 op 2 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol3_SoundEditPitchTune:
	link XIZ,0xfff2	; F0A1D1  link XIZ,0xfff2
	pushw	hl	; F0A1D5  push HL
	pushw	de	; F0A1D6  push DE
	push	xix	; F0A1D7  push XIX
	lda	xix, (xiz-14)	; F0A1D8  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0A1DB  lda XBC,XIZ+0xfe
	push	xbc	; F0A1DE  push XBC
	call	Var27A3_GetValidSlot	; F0A1DF  call 0xfd6b4d
	ld	c, 3:opc	; F0A1E3  ld C,0x03
	mul	bc, (xiz-2)	; F0A1E5  mul BC,(XIZ+0xfe)
	ld	h, c	; F0A1E8  ld H,C
	dec	1, h	; F0A1EA  dec 1,H
	push	xix	; F0A1EC  push XIX
	ld	c, h	; F0A1ED  ld C,H
	extz	bc	; F0A1EF  extz BC
	ld	de, bc	; F0A1F1  ld DE,BC
	pushw	bc	; F0A1F3  push BC
	call	Arr27A6_Get	; F0A1F4  call 0xfd6c7b
	ld	(xix+6), 255	; F0A1F8  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0A1FC  ld (XIX+0x07),0x00
	ld	(xix+8), 127	; F0A200  ld (XIX+0x08),0x7f
	ld	(xix+9), 128	; F0A204  ld (XIX+0x09),0x80
	ld	xbc, xix	; F0A208  ld XBC,XIX
	add	xbc, 10	; F0A20A  add XBC,0x0000000a
	push	xbc	; F0A210  push XBC
	ld	bc, (xiz+8)	; F0A211  ld BC,(XIZ+0x08)
	extz	bc	; F0A214  extz BC
	pushw	bc	; F0A216  push BC
	call	ToneEdit_StepFromEvent	; F0A217  call 0xfd7c2d
	push	xix	; F0A21B  push XIX
	pushw	5	; F0A21C  push 0x0005
	ld	bc, (xiz-2)	; F0A21F  ld BC,(XIZ+0xfe)
	extz	bc	; F0A222  extz BC
	pushw	bc	; F0A224  push BC
	pushw	de	; F0A225  push DE
	pushw	135	; F0A226  push 0x0087
	call	ToneEdit_CommitField	; F0A229  call 0xfd7435
	pushw	3	; F0A22D  push 0x0003
	call	PanelDial_ActAsButton	; F0A230  call 0xfd7c01
	add	xsp, 30	; F0A234  add XSP,0x0000001e
	pop	xix	; F0A23A  pop XIX
	popw	de	; F0A23B  pop DE
	popw	hl	; F0A23C  pop HL
	unlk XIZ	; F0A23D  unlk XIZ
	ret	; F0A23F  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditPitchTune
; Called from: table 0xFCF21B[93]
; Touches: nothing with an absolute address
; Calls:   0xFD6B4D 0xFD6C7B 0xFD7C2D 0xFD7435 0xFD7C01
; Evidence: word [93] of the pointer table at 0xFCF21B reads 0x00F0A240, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A240 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditPitchTune: SOFT KEY column 4 (lower or upper; the flag carries which) on ScreenCode87 -- ScreenCode87 op 3 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol4_SoundEditPitchTune:
	link XIZ,0xfff2	; F0A240  link XIZ,0xfff2
	pushw	hl	; F0A244  push HL
	pushw	de	; F0A245  push DE
	push	xix	; F0A246  push XIX
	lda	xix, (xiz-14)	; F0A247  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0A24A  lda XBC,XIZ+0xfe
	push	xbc	; F0A24D  push XBC
	call	Var27A3_GetValidSlot	; F0A24E  call 0xfd6b4d
	ld	c, 3:opc	; F0A252  ld C,0x03
	mul	bc, (xiz-2)	; F0A254  mul BC,(XIZ+0xfe)
	ld	h, c	; F0A257  ld H,C
	push	xix	; F0A259  push XIX
	extz	bc	; F0A25A  extz BC
	ld	de, bc	; F0A25C  ld DE,BC
	pushw	bc	; F0A25E  push BC
	call	Arr27A6_Get	; F0A25F  call 0xfd6c7b
	ld	(xix+6), 7	; F0A263  ld (XIX+0x06),0x07
	ld	(xix+7), 0	; F0A267  ld (XIX+0x07),0x00
	ld	(xix+8), 7	; F0A26B  ld (XIX+0x08),0x07
	ld	(xix+9), 0	; F0A26F  ld (XIX+0x09),0x00
	ld	xbc, xix	; F0A273  ld XBC,XIX
	add	xbc, 10	; F0A275  add XBC,0x0000000a
	push	xbc	; F0A27B  push XBC
	ld	bc, (xiz+8)	; F0A27C  ld BC,(XIZ+0x08)
	extz	bc	; F0A27F  extz BC
	pushw	bc	; F0A281  push BC
	call	ToneEdit_StepFromEvent	; F0A282  call 0xfd7c2d
	push	xix	; F0A286  push XIX
	pushw	6	; F0A287  push 0x0006
	ld	bc, (xiz-2)	; F0A28A  ld BC,(XIZ+0xfe)
	extz	bc	; F0A28D  extz BC
	pushw	bc	; F0A28F  push BC
	pushw	de	; F0A290  push DE
	pushw	135	; F0A291  push 0x0087
	call	ToneEdit_CommitField	; F0A294  call 0xfd7435
	pushw	4	; F0A298  push 0x0004
	call	PanelDial_ActAsButton	; F0A29B  call 0xfd7c01
	add	xsp, 30	; F0A29F  add XSP,0x0000001e
	pop	xix	; F0A2A5  pop XIX
	popw	de	; F0A2A6  pop DE
	popw	hl	; F0A2A7  pop HL
	unlk XIZ	; F0A2A8  unlk XIZ
	ret	; F0A2AA  ret

; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditPitchTune
; Called from: table 0xFCF21B[95]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7C2D 0xFD6CE1 0xFD6C65 0xFDA777 0xFD616A T_Dispatch_Code80
;          0xFD7435 0xFD7C01
; Evidence: word [95] of the pointer table at 0xFCF21B reads 0x00F0A2AB, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A2AB is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditPitchTune: SOFT KEY column 6 (lower or upper; the flag carries which) on ScreenCode87 -- ScreenCode87 op 5 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol6_SoundEditPitchTune:
	link XIZ,0xffec	; F0A2AB  link XIZ,0xffec
	push	xix	; F0A2AF  push XIX
	lda	xix, (xiz-16)	; F0A2B0  lda XIX,XIZ+0xf0
	lda	xbc, (xiz-2)	; F0A2B3  lda XBC,XIZ+0xfe
	push	xbc	; F0A2B6  push XBC
	pushw	13	; F0A2B7  push 0x000d
	call	Arr27A6_Get	; F0A2BA  call 0xfd6c7b
	inc	6, xsp	; F0A2BE  inc 6,XSP
	cp	(xiz-2), 0x01	; F0A2C0  cp (XIZ+0xfe),0x01
	jrl	nz, SoftKeyCol6_SoundEditPitchTune_Skip	; F0A2C4  jrl NZ,0xf0a353
	push	xix	; F0A2C7  push XIX
	pushw	16	; F0A2C8  push 0x0010
	call	Arr27A6_Get	; F0A2CB  call 0xfd6c7b
	ld	(xix+6), 255	; F0A2CF  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0A2D3  ld (XIX+0x07),0x00
	ld	(xix+8), 13	; F0A2D7  ld (XIX+0x08),0x0d
	ld	(xix+9), 0	; F0A2DB  ld (XIX+0x09),0x00
	ld	xbc, xix	; F0A2DF  ld XBC,XIX
	add	xbc, 10	; F0A2E1  add XBC,0x0000000a
	push	xbc	; F0A2E7  push XBC
	ld	bc, (xiz+8)	; F0A2E8  ld BC,(XIZ+0x08)
	extz	bc	; F0A2EB  extz BC
	pushw	bc	; F0A2ED  push BC
	call	ToneEdit_StepFromEvent	; F0A2EE  call 0xfd7c2d
	push	xix	; F0A2F2  push XIX
	call	ToneEdit_ApplyStep	; F0A2F3  call 0xfd6ce1
	inc	8, xsp	; F0A2F7  inc 0,XSP
	inc	8, xsp	; F0A2F9  inc 0,XSP
	cp	a, 1:i3	; F0A2FB  cp A,1
	jrl	nz, SoftKeyCol6_SoundEditPitchTune_Join	; F0A2FD  jrl NZ,0xf0a395
	ld	xbc, xix	; F0A300  ld XBC,XIX
	inc	3, xbc	; F0A302  inc 3,XBC
	ld	(xiz-20), xbc	; F0A304  ld (XIZ+0xec),XBC
	ld	a, (xbc)	; F0A307  ld A,(XBC)
	extz	wa	; F0A309  extz WA
	pushw	wa	; F0A30B  push WA
	pushw	16	; F0A30C  push 0x0010
	call	Arr27A6_Set	; F0A30F  call 0xfd6c65
	lda	xbc, (xiz-4)	; F0A313  lda XBC,XIZ+0xfc
	push	xbc	; F0A316  push XBC
	ld	xwa, (xiz-20)	; F0A317  ld XWA,(XIZ+0xec)
	ld	c, (xwa)	; F0A31A  ld C,(XWA)
	extz	bc	; F0A31C  extz BC
	pushw	bc	; F0A31E  push BC
	call	SoundEditPitchTune_KeyScalingPosToParam	; F0A31F  call 0xfda777
	ld	bc, (xiz-4)	; F0A323  ld BC,(XIZ+0xfc)
	extz	bc	; F0A326  extz BC
	pushw	bc	; F0A328  push BC
	pushw	14	; F0A329  push 0x000e
	call	Arr27A6_Set	; F0A32C  call 0xfd6c65
	pushw	255	; F0A330  push 0x00ff
	lda	xbc, (xiz-4)	; F0A333  lda XBC,XIZ+0xfc
	push	xbc	; F0A336  push XBC
	pushw	19	; F0A337  push 0x0013
	pushw	0	; F0A33A  push 0x0000
	call	ToneMsg_SendParam	; F0A33D  call 0xfd616a
	pushw	16	; F0A341  push 0x0010
	pushw	135	; F0A344  push 0x0087
	call	T_Dispatch_Code80	; F0A347  call 0xf41ed4
	add	xsp, 28	; F0A34B  add XSP,0x0000001c
	jr	SoftKeyCol6_SoundEditPitchTune_Join	; F0A351  jr T,0xf0a395
SoftKeyCol6_SoundEditPitchTune_Skip:
	push	xix	; F0A353  push XIX
	pushw	15	; F0A354  push 0x000f
	call	Arr27A6_Get	; F0A357  call 0xfd6c7b
	ld	(xix+6), 15	; F0A35B  ld (XIX+0x06),0x0f
	ld	(xix+7), 0	; F0A35F  ld (XIX+0x07),0x00
	ld	(xix+8), 10	; F0A363  ld (XIX+0x08),0x0a
	ld	(xix+9), 6	; F0A367  ld (XIX+0x09),0x06
	ld	xbc, xix	; F0A36B  ld XBC,XIX
	add	xbc, 10	; F0A36D  add XBC,0x0000000a
	push	xbc	; F0A373  push XBC
	ld	bc, (xiz+8)	; F0A374  ld BC,(XIZ+0x08)
	extz	bc	; F0A377  extz BC
	pushw	bc	; F0A379  push BC
	call	ToneEdit_StepFromEvent	; F0A37A  call 0xfd7c2d
	push	xix	; F0A37E  push XIX
	pushw	85	; F0A37F  push 0x0055
	pushw	0	; F0A382  push 0x0000
	pushw	15	; F0A385  push 0x000f
	pushw	135	; F0A388  push 0x0087
	call	ToneEdit_CommitField	; F0A38B  call 0xfd7435
	add	xsp, 24	; F0A38F  add XSP,0x00000018
SoftKeyCol6_SoundEditPitchTune_Join:
	pushw	6	; F0A395  push 0x0006
	call	PanelDial_ActAsButton	; F0A398  call 0xfd7c01
	popw	bc	; F0A39C  pop BC
	pop	xix	; F0A39D  pop XIX
	unlk XIZ	; F0A39E  unlk XIZ
	ret	; F0A3A0  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditPitchTune
; Called from: table 0xFCF21B[98]
; Touches: nothing with an absolute address
; Calls:   0xFD608B 0xFD6E90
; Evidence: word [98] of the pointer table at 0xFCF21B reads 0x00F0A3A1, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A3A1 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditPitchTune: LCD key row 1 (left or right) on ScreenCode87 -- ScreenCode87 op 8 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow1_SoundEditPitchTune:
	link XIZ,0x0000	; F0A3A1  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A3A5  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow1_SoundEditPitchTune_Skip	; F0A3A9  jr NZ,0xf0a3b8
	pushw	0	; F0A3AB  push 0x0000
	pushw	136	; F0A3AE  push 0x0088
	call	PanelScreen_PostRequest	; F0A3B1  call 0xfd608b
	pop	xiy	; F0A3B5  pop XIY
	jr	LcdKeyRow1_SoundEditPitchTune_Join	; F0A3B6  jr T,0xf0a3bc
LcdKeyRow1_SoundEditPitchTune_Skip:
	call	Var27A2_ToggleWithP23	; F0A3B8  call 0xfd6e90
LcdKeyRow1_SoundEditPitchTune_Join:
	unlk XIZ	; F0A3BC  unlk XIZ
	ret	; F0A3BE  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditPitchTune
; Called from: table 0xFCF21B[99]
; Touches: nothing with an absolute address
; Calls:   0xFD9863
; Evidence: word [99] of the pointer table at 0xFCF21B reads 0x00F0A3BF, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A3BF is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditPitchTune: LCD key row 2 (left or right) on ScreenCode87 -- ScreenCode87 op 9 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow2_SoundEditPitchTune:
	link XIZ,0x0000	; F0A3BF  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A3C3  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow2_SoundEditPitchTune_Skip	; F0A3C7  jr Z,0xf0a3d8
	pushw	1	; F0A3C9  push 0x0001
	pushw	1	; F0A3CC  push 0x0001
	pushw	135	; F0A3CF  push 0x0087
	call	Var27A3_SelectSlot	; F0A3D2  call 0xfd9863
	inc	6, xsp	; F0A3D6  inc 6,XSP
LcdKeyRow2_SoundEditPitchTune_Skip:
	unlk XIZ	; F0A3D8  unlk XIZ
	ret	; F0A3DA  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditPitchTune
; Called from: table 0xFCF21B[100]
; Touches: nothing with an absolute address
; Calls:   0xFD608B 0xFD9863
; Evidence: word [100] of the pointer table at 0xFCF21B reads 0x00F0A3DB, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A3DB is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditPitchTune: LCD key row 3 (left or right) on ScreenCode87 -- ScreenCode87 op 10 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow3_SoundEditPitchTune:
	link XIZ,0x0000	; F0A3DB  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A3DF  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow3_SoundEditPitchTune_Skip	; F0A3E3  jr NZ,0xf0a3f2
	pushw	0	; F0A3E5  push 0x0000
	pushw	138	; F0A3E8  push 0x008a
	call	PanelScreen_PostRequest	; F0A3EB  call 0xfd608b
	pop	xiy	; F0A3EF  pop XIY
	jr	LcdKeyRow3_SoundEditPitchTune_Join	; F0A3F0  jr T,0xf0a401
LcdKeyRow3_SoundEditPitchTune_Skip:
	pushw	1	; F0A3F2  push 0x0001
	pushw	2	; F0A3F5  push 0x0002
	pushw	135	; F0A3F8  push 0x0087
	call	Var27A3_SelectSlot	; F0A3FB  call 0xfd9863
	inc	6, xsp	; F0A3FF  inc 6,XSP
LcdKeyRow3_SoundEditPitchTune_Join:
	unlk XIZ	; F0A401  unlk XIZ
	ret	; F0A403  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditPitchTune
; Called from: table 0xFCF21B[101]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD6C65 T_Dispatch_Code80 0xFD9863
; Evidence: word [101] of the pointer table at 0xFCF21B reads 0x00F0A404, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A404 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditPitchTune: LCD key row 4 (left or right) on ScreenCode87 -- ScreenCode87 op 11 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow4_SoundEditPitchTune:
	link XIZ,0xfffe	; F0A404  link XIZ,0xfffe
	cp	(xiz+8), 0x00	; F0A408  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow4_SoundEditPitchTune_Skip	; F0A40C  jr NZ,0xf0a43f
	lda	xbc, (xiz-2)	; F0A40E  lda XBC,XIZ+0xfe
	push	xbc	; F0A411  push XBC
	pushw	13	; F0A412  push 0x000d
	call	Arr27A6_Get	; F0A415  call 0xfd6c7b
	inc	6, xsp	; F0A419  inc 6,XSP
	cp	(xiz-2), 0x01	; F0A41B  cp (XIZ+0xfe),0x01
	jr	ule, LcdKeyRow4_SoundEditPitchTune_Join	; F0A41F  jr ULE,0xf0a44e
	decm8	1, (xiz-2)	; F0A421  dec 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F0A424  ld BC,(XIZ+0xfe)
	extz	bc	; F0A427  extz BC
	pushw	bc	; F0A429  push BC
	pushw	13	; F0A42A  push 0x000d
	call	Arr27A6_Set	; F0A42D  call 0xfd6c65
	pushw	13	; F0A431  push 0x000d
	pushw	135	; F0A434  push 0x0087
	call	T_Dispatch_Code80	; F0A437  call 0xf41ed4
	inc	8, xsp	; F0A43B  inc 0,XSP
	jr	LcdKeyRow4_SoundEditPitchTune_Join	; F0A43D  jr T,0xf0a44e
LcdKeyRow4_SoundEditPitchTune_Skip:
	pushw	1	; F0A43F  push 0x0001
	pushw	3	; F0A442  push 0x0003
	pushw	135	; F0A445  push 0x0087
	call	Var27A3_SelectSlot	; F0A448  call 0xfd9863
	inc	6, xsp	; F0A44C  inc 6,XSP
LcdKeyRow4_SoundEditPitchTune_Join:
	unlk XIZ	; F0A44E  unlk XIZ
	ret	; F0A450  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditPitchTune
; Called from: table 0xFCF21B[102]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD6C65 T_Dispatch_Code80 0xFD9863
; Evidence: word [102] of the pointer table at 0xFCF21B reads 0x00F0A451, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A451 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditPitchTune: LCD key row 5 (left or right) on ScreenCode87 -- ScreenCode87 op 12 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow5_SoundEditPitchTune:
	link XIZ,0xfffe	; F0A451  link XIZ,0xfffe
	cp	(xiz+8), 0x00	; F0A455  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow5_SoundEditPitchTune_Skip	; F0A459  jr NZ,0xf0a48c
	lda	xbc, (xiz-2)	; F0A45B  lda XBC,XIZ+0xfe
	push	xbc	; F0A45E  push XBC
	pushw	13	; F0A45F  push 0x000d
	call	Arr27A6_Get	; F0A462  call 0xfd6c7b
	inc	6, xsp	; F0A466  inc 6,XSP
	cp	(xiz-2), 0x02	; F0A468  cp (XIZ+0xfe),0x02
	jr	nc, LcdKeyRow5_SoundEditPitchTune_Join	; F0A46C  jr NC,0xf0a49b
	incm8	1, (xiz-2)	; F0A46E  inc 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F0A471  ld BC,(XIZ+0xfe)
	extz	bc	; F0A474  extz BC
	pushw	bc	; F0A476  push BC
	pushw	13	; F0A477  push 0x000d
	call	Arr27A6_Set	; F0A47A  call 0xfd6c65
	pushw	13	; F0A47E  push 0x000d
	pushw	135	; F0A481  push 0x0087
	call	T_Dispatch_Code80	; F0A484  call 0xf41ed4
	inc	8, xsp	; F0A488  inc 0,XSP
	jr	LcdKeyRow5_SoundEditPitchTune_Join	; F0A48A  jr T,0xf0a49b
LcdKeyRow5_SoundEditPitchTune_Skip:
	pushw	1	; F0A48C  push 0x0001
	pushw	4	; F0A48F  push 0x0004
	pushw	135	; F0A492  push 0x0087
	call	Var27A3_SelectSlot	; F0A495  call 0xfd9863
	inc	6, xsp	; F0A499  inc 6,XSP
LcdKeyRow5_SoundEditPitchTune_Join:
	unlk XIZ	; F0A49B  unlk XIZ
	ret	; F0A49D  ret

; --------------------------------------------------------------------------
; ExitKey_SoundEditPitchTune
; Called from: table 0xFCF21B[105]
; Touches: nothing with an absolute address
; Calls:   0xFD69E0 0xFD608B
; Evidence: word [105] of the pointer table at 0xFCF21B reads 0x00F0A49E, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A49E is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SoundEditPitchTune: the EXIT key on ScreenCode87 -- ScreenCode87 op 15 (PanelOpTable_FCF383).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
ExitKey_SoundEditPitchTune:
	link XIZ,0x0000	; F0A49E  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A4A2  cp (XIZ+0x08),0x00
	jr	nz, ExitKey_SoundEditPitchTune_Skip	; F0A4A6  jr NZ,0xf0a4bb
	pushw	0	; F0A4A8  push 0x0000
	call	ToneMsg_SendP23FromArr2800	; F0A4AB  call 0xfd69e0
	pushw	0	; F0A4AF  push 0x0000
	pushw	128	; F0A4B2  push 0x0080
	call	PanelScreen_PostRequest	; F0A4B5  call 0xfd608b
	inc	6, xsp	; F0A4B9  inc 6,XSP
ExitKey_SoundEditPitchTune_Skip:
	unlk XIZ	; F0A4BB  unlk XIZ
	ret	; F0A4BD  ret

; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[108]
; Touches: nothing with an absolute address
; Calls:   0xFD8155
; Evidence: word [108] of the pointer table at 0xFCF21B reads 0x00F0A4BE, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A4BE is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditPitchEnvelope1: SOFT KEY column 1 (lower or upper; the flag carries which) on ScreenCode88 -- ScreenCode88 op 0 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol1_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A4BE  link XIZ,0x0000
	pushw	0	; F0A4C2  push 0x0000
	pushw	9	; F0A4C5  push 0x0009
	ld	bc, (xiz+8)	; F0A4C8  ld BC,(XIZ+0x08)
	extz	bc	; F0A4CB  extz BC
	pushw	bc	; F0A4CD  push BC
	call	SoundEditEnvelope1_SoftKeyCol1	; F0A4CE  call 0xfd8155
	inc	6, xsp	; F0A4D2  inc 6,XSP
	unlk XIZ	; F0A4D4  unlk XIZ
	ret	; F0A4D6  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[109]
; Touches: nothing with an absolute address
; Calls:   0xFD81C8
; Evidence: word [109] of the pointer table at 0xFCF21B reads 0x00F0A4D7, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A4D7 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditPitchEnvelope1: SOFT KEY column 2 (lower or upper; the flag carries which) on ScreenCode88 -- ScreenCode88 op 1 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol2_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A4D7  link XIZ,0x0000
	pushw	0	; F0A4DB  push 0x0000
	pushw	10	; F0A4DE  push 0x000a
	ld	bc, (xiz+8)	; F0A4E1  ld BC,(XIZ+0x08)
	extz	bc	; F0A4E4  extz BC
	pushw	bc	; F0A4E6  push BC
	call	SoundEditEnvelope1_SoftKeyCol2	; F0A4E7  call 0xfd81c8
	inc	6, xsp	; F0A4EB  inc 6,XSP
	unlk XIZ	; F0A4ED  unlk XIZ
	ret	; F0A4EF  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[110]
; Touches: nothing with an absolute address
; Calls:   0xFD823B
; Evidence: word [110] of the pointer table at 0xFCF21B reads 0x00F0A4F0, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A4F0 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditPitchEnvelope1: SOFT KEY column 3 (lower or upper; the flag carries which) on ScreenCode88 -- ScreenCode88 op 2 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol3_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A4F0  link XIZ,0x0000
	pushw	11	; F0A4F4  push 0x000b
	pushw	8	; F0A4F7  push 0x0008
	ld	bc, (xiz+8)	; F0A4FA  ld BC,(XIZ+0x08)
	extz	bc	; F0A4FD  extz BC
	pushw	bc	; F0A4FF  push BC
	call	SoundEditEnvelope1_SoftKeyCol3	; F0A500  call 0xfd823b
	inc	6, xsp	; F0A504  inc 6,XSP
	unlk XIZ	; F0A506  unlk XIZ
	ret	; F0A508  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[111]
; Touches: nothing with an absolute address
; Calls:   0xFD82D8
; Evidence: word [111] of the pointer table at 0xFCF21B reads 0x00F0A509, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A509 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditPitchEnvelope1: SOFT KEY column 4 (lower or upper; the flag carries which) on ScreenCode88 -- ScreenCode88 op 3 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol4_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A509  link XIZ,0x0000
	pushw	0	; F0A50D  push 0x0000
	pushw	12	; F0A510  push 0x000c
	ld	bc, (xiz+8)	; F0A513  ld BC,(XIZ+0x08)
	extz	bc	; F0A516  extz BC
	pushw	bc	; F0A518  push BC
	call	SoundEditEnvelope1_SoftKeyCol4	; F0A519  call 0xfd82d8
	inc	6, xsp	; F0A51D  inc 6,XSP
	unlk XIZ	; F0A51F  unlk XIZ
	ret	; F0A521  ret

; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[112]
; Touches: nothing with an absolute address
; Calls:   0xFD834B
; Evidence: word [112] of the pointer table at 0xFCF21B reads 0x00F0A522, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A522 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditPitchEnvelope1: SOFT KEY column 5 (lower or upper; the flag carries which) on ScreenCode88 -- ScreenCode88 op 4 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol5_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A522  link XIZ,0x0000
	pushw	13	; F0A526  push 0x000d
	pushw	16	; F0A529  push 0x0010
	ld	bc, (xiz+8)	; F0A52C  ld BC,(XIZ+0x08)
	extz	bc	; F0A52F  extz BC
	pushw	bc	; F0A531  push BC
	call	SoundEditEnvelope1_SoftKeyCol5	; F0A532  call 0xfd834b
	inc	6, xsp	; F0A536  inc 6,XSP
	unlk XIZ	; F0A538  unlk XIZ
	ret	; F0A53A  ret

; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[113]
; Touches: nothing with an absolute address
; Calls:   0xFD83E8
; Evidence: word [113] of the pointer table at 0xFCF21B reads 0x00F0A53B, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A53B is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditPitchEnvelope1: SOFT KEY column 6 (lower or upper; the flag carries which) on ScreenCode88 -- ScreenCode88 op 5 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol6_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A53B  link XIZ,0x0000
	pushw	0	; F0A53F  push 0x0000
	pushw	14	; F0A542  push 0x000e
	ld	bc, (xiz+8)	; F0A545  ld BC,(XIZ+0x08)
	extz	bc	; F0A548  extz BC
	pushw	bc	; F0A54A  push BC
	call	SoundEditEnvelope1_SoftKeyCol6	; F0A54B  call 0xfd83e8
	inc	6, xsp	; F0A54F  inc 6,XSP
	unlk XIZ	; F0A551  unlk XIZ
	ret	; F0A553  ret

; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[114]
; Touches: nothing with an absolute address
; Calls:   0xFD845B
; Evidence: word [114] of the pointer table at 0xFCF21B reads 0x00F0A554, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A554 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditPitchEnvelope1: SOFT KEY column 7 (lower or upper; the flag carries which) on ScreenCode88 -- ScreenCode88 op 6 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol7_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A554  link XIZ,0x0000
	pushw	15	; F0A558  push 0x000f
	pushw	7	; F0A55B  push 0x0007
	ld	bc, (xiz+8)	; F0A55E  ld BC,(XIZ+0x08)
	extz	bc	; F0A561  extz BC
	pushw	bc	; F0A563  push BC
	call	SoundEditEnvelope1_SoftKeyCol7	; F0A564  call 0xfd845b
	inc	6, xsp	; F0A568  inc 6,XSP
	unlk XIZ	; F0A56A  unlk XIZ
	ret	; F0A56C  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[116]
; Touches: nothing with an absolute address
; Calls:   0xFD6E90
; Evidence: word [116] of the pointer table at 0xFCF21B reads 0x00F0A56D, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A56D is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditPitchEnvelope1: LCD key row 1 (left or right) on ScreenCode88 -- ScreenCode88 op 8 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow1_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A56D  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A571  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow1_SoundEditPitchEnvelope1_Skip	; F0A575  jr Z,0xf0a57b
	call	Var27A2_ToggleWithP23	; F0A577  call 0xfd6e90
LcdKeyRow1_SoundEditPitchEnvelope1_Skip:
	unlk XIZ	; F0A57B  unlk XIZ
	ret	; F0A57D  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[117]
; Touches: nothing with an absolute address
; Calls:   0xFD74AE 0xFD608B
; Evidence: word [117] of the pointer table at 0xFCF21B reads 0x00F0A57E, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A57E is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditPitchEnvelope1: LCD key row 2 (left or right) on ScreenCode88 -- ScreenCode88 op 9 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow2_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A57E  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A582  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow2_SoundEditPitchEnvelope1_Skip	; F0A586  jr NZ,0xf0a590
	pushw	0	; F0A588  push 0x0000
	pushw	135	; F0A58B  push 0x0087
	jr	LcdKeyRow2_SoundEditPitchEnvelope1_Join	; F0A58E  jr T,0xf0a5a2
LcdKeyRow2_SoundEditPitchEnvelope1_Skip:
	pushw	1	; F0A590  push 0x0001
	call	Var27A3_ChangeSlot	; F0A593  call 0xfd74ae
	popw	bc	; F0A597  pop BC
	cp	a, 0:i3	; F0A598  cp A,0
	jr	z, LcdKeyRow2_SoundEditPitchEnvelope1_Skip2	; F0A59A  jr Z,0xf0a5a7
	pushw	1	; F0A59C  push 0x0001
	pushw	136	; F0A59F  push 0x0088
LcdKeyRow2_SoundEditPitchEnvelope1_Join:
	call	PanelScreen_PostRequest	; F0A5A2  call 0xfd608b
	pop	xiy	; F0A5A6  pop XIY
LcdKeyRow2_SoundEditPitchEnvelope1_Skip2:
	unlk XIZ	; F0A5A7  unlk XIZ
	ret	; F0A5A9  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[118]
; Touches: nothing with an absolute address
; Calls:   0xFD74AE 0xFD608B
; Evidence: word [118] of the pointer table at 0xFCF21B reads 0x00F0A5AA, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A5AA is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditPitchEnvelope1: LCD key row 3 (left or right) on ScreenCode88 -- ScreenCode88 op 10 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow3_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A5AA  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A5AE  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow3_SoundEditPitchEnvelope1_Skip	; F0A5B2  jr NZ,0xf0a5bc
	pushw	0	; F0A5B4  push 0x0000
	pushw	138	; F0A5B7  push 0x008a
	jr	LcdKeyRow3_SoundEditPitchEnvelope1_Join	; F0A5BA  jr T,0xf0a5ce
LcdKeyRow3_SoundEditPitchEnvelope1_Skip:
	pushw	2	; F0A5BC  push 0x0002
	call	Var27A3_ChangeSlot	; F0A5BF  call 0xfd74ae
	popw	bc	; F0A5C3  pop BC
	cp	a, 0:i3	; F0A5C4  cp A,0
	jr	z, LcdKeyRow3_SoundEditPitchEnvelope1_Skip2	; F0A5C6  jr Z,0xf0a5d3
	pushw	1	; F0A5C8  push 0x0001
	pushw	136	; F0A5CB  push 0x0088
LcdKeyRow3_SoundEditPitchEnvelope1_Join:
	call	PanelScreen_PostRequest	; F0A5CE  call 0xfd608b
	pop	xiy	; F0A5D2  pop XIY
LcdKeyRow3_SoundEditPitchEnvelope1_Skip2:
	unlk XIZ	; F0A5D3  unlk XIZ
	ret	; F0A5D5  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[119]
; Touches: nothing with an absolute address
; Calls:   0xFD8116 0xFD74AE 0xFD608B
; Evidence: word [119] of the pointer table at 0xFCF21B reads 0x00F0A5D6, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A5D6 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditPitchEnvelope1: LCD key row 4 (left or right) on ScreenCode88 -- ScreenCode88 op 11 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow4_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A5D6  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A5DA  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow4_SoundEditPitchEnvelope1_Skip	; F0A5DE  jr NZ,0xf0a5ea
	pushw	0	; F0A5E0  push 0x0000
	call	SoundEditEnvelope1_SetField0AndRedraw	; F0A5E3  call 0xfd8116
	popw	bc	; F0A5E7  pop BC
	jr	LcdKeyRow4_SoundEditPitchEnvelope1_Join	; F0A5E8  jr T,0xf0a601
LcdKeyRow4_SoundEditPitchEnvelope1_Skip:
	pushw	3	; F0A5EA  push 0x0003
	call	Var27A3_ChangeSlot	; F0A5ED  call 0xfd74ae
	popw	bc	; F0A5F1  pop BC
	cp	a, 0:i3	; F0A5F2  cp A,0
	jr	z, LcdKeyRow4_SoundEditPitchEnvelope1_Join	; F0A5F4  jr Z,0xf0a601
	pushw	1	; F0A5F6  push 0x0001
	pushw	136	; F0A5F9  push 0x0088
	call	PanelScreen_PostRequest	; F0A5FC  call 0xfd608b
	pop	xiy	; F0A600  pop XIY
LcdKeyRow4_SoundEditPitchEnvelope1_Join:
	unlk XIZ	; F0A601  unlk XIZ
	ret	; F0A603  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[120]
; Touches: nothing with an absolute address
; Calls:   0xFD8116 0xFD74AE 0xFD608B
; Evidence: word [120] of the pointer table at 0xFCF21B reads 0x00F0A604, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A604 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditPitchEnvelope1: LCD key row 5 (left or right) on ScreenCode88 -- ScreenCode88 op 12 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow5_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A604  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A608  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow5_SoundEditPitchEnvelope1_Skip	; F0A60C  jr NZ,0xf0a618
	pushw	1	; F0A60E  push 0x0001
	call	SoundEditEnvelope1_SetField0AndRedraw	; F0A611  call 0xfd8116
	popw	bc	; F0A615  pop BC
	jr	LcdKeyRow5_SoundEditPitchEnvelope1_Join	; F0A616  jr T,0xf0a62f
LcdKeyRow5_SoundEditPitchEnvelope1_Skip:
	pushw	4	; F0A618  push 0x0004
	call	Var27A3_ChangeSlot	; F0A61B  call 0xfd74ae
	popw	bc	; F0A61F  pop BC
	cp	a, 0:i3	; F0A620  cp A,0
	jr	z, LcdKeyRow5_SoundEditPitchEnvelope1_Join	; F0A622  jr Z,0xf0a62f
	pushw	1	; F0A624  push 0x0001
	pushw	136	; F0A627  push 0x0088
	call	PanelScreen_PostRequest	; F0A62A  call 0xfd608b
	pop	xiy	; F0A62E  pop XIY
LcdKeyRow5_SoundEditPitchEnvelope1_Join:
	unlk XIZ	; F0A62F  unlk XIZ
	ret	; F0A631  ret

; --------------------------------------------------------------------------
; PageKey_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[124]
; Touches: nothing with an absolute address
; Calls:   0xFD608B
; Evidence: word [124] of the pointer table at 0xFCF21B reads 0x00F0A632, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A632 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; PageKey_SoundEditPitchEnvelope1: the PAGE pair (code 0x10) on ScreenCode88 -- ScreenCode88 op 16 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
PageKey_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A632  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A636  cp (XIZ+0x08),0x00
	jr	nz, PageKey_SoundEditPitchEnvelope1_Skip	; F0A63A  jr NZ,0xf0a647
	pushw	0	; F0A63C  push 0x0000
	pushw	137	; F0A63F  push 0x0089
	call	PanelScreen_PostRequest	; F0A642  call 0xfd608b
	pop	xiy	; F0A646  pop XIY
PageKey_SoundEditPitchEnvelope1_Skip:
	unlk XIZ	; F0A647  unlk XIZ
	ret	; F0A649  ret

; --------------------------------------------------------------------------
; ExitKey_SoundEditPitchEnvelope1
; Called from: table 0xFCF21B[123]
; Touches: nothing with an absolute address
; Calls:   0xFD69E0 0xFD608B
; Evidence: word [123] of the pointer table at 0xFCF21B reads 0x00F0A64A, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A64A is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SoundEditPitchEnvelope1: the EXIT key on ScreenCode88 -- ScreenCode88 op 15 (PanelOpTable_FCF3CB).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
ExitKey_SoundEditPitchEnvelope1:
	link XIZ,0x0000	; F0A64A  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A64E  cp (XIZ+0x08),0x00
	jr	nz, ExitKey_SoundEditPitchEnvelope1_Skip	; F0A652  jr NZ,0xf0a667
	pushw	0	; F0A654  push 0x0000
	call	ToneMsg_SendP23FromArr2800	; F0A657  call 0xfd69e0
	pushw	0	; F0A65B  push 0x0000
	pushw	128	; F0A65E  push 0x0080
	call	PanelScreen_PostRequest	; F0A661  call 0xfd608b
	inc	6, xsp	; F0A665  inc 6,XSP
ExitKey_SoundEditPitchEnvelope1_Skip:
	unlk XIZ	; F0A667  unlk XIZ
	ret	; F0A669  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[127]
; Touches: nothing with an absolute address
; Calls:   0xFD84F8
; Evidence: word [127] of the pointer table at 0xFCF21B reads 0x00F0A66A, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A66A is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditPitchEnvelope2: SOFT KEY column 2 (lower or upper; the flag carries which) on ScreenCode89 -- ScreenCode89 op 1 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol2_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A66A  link XIZ,0x0000
	pushw	20	; F0A66E  push 0x0014
	ld	bc, (xiz+8)	; F0A671  ld BC,(XIZ+0x08)
	extz	bc	; F0A674  extz BC
	pushw	bc	; F0A676  push BC
	call	SoundEditEnvelope2_SoftKeyCol2	; F0A677  call 0xfd84f8
	pop	xbc	; F0A67B  pop XBC
	unlk XIZ	; F0A67C  unlk XIZ
	ret	; F0A67E  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[128]
; Touches: nothing with an absolute address
; Calls:   0xFD859B
; Evidence: word [128] of the pointer table at 0xFCF21B reads 0x00F0A67F, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A67F is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditPitchEnvelope2: SOFT KEY column 3 (lower or upper; the flag carries which) on ScreenCode89 -- ScreenCode89 op 2 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol3_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A67F  link XIZ,0x0000
	pushw	21	; F0A683  push 0x0015
	ld	bc, (xiz+8)	; F0A686  ld BC,(XIZ+0x08)
	extz	bc	; F0A689  extz BC
	pushw	bc	; F0A68B  push BC
	call	SoundEditEnvelope2_SoftKeyCol3	; F0A68C  call 0xfd859b
	pop	xbc	; F0A690  pop XBC
	unlk XIZ	; F0A691  unlk XIZ
	ret	; F0A693  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[129]
; Touches: nothing with an absolute address
; Calls:   0xFD863E
; Evidence: word [129] of the pointer table at 0xFCF21B reads 0x00F0A694, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A694 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditPitchEnvelope2: SOFT KEY column 4 (lower or upper; the flag carries which) on ScreenCode89 -- ScreenCode89 op 3 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol4_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A694  link XIZ,0x0000
	pushw	22	; F0A698  push 0x0016
	ld	bc, (xiz+8)	; F0A69B  ld BC,(XIZ+0x08)
	extz	bc	; F0A69E  extz BC
	pushw	bc	; F0A6A0  push BC
	call	SoundEditEnvelope2_SoftKeyCol4	; F0A6A1  call 0xfd863e
	pop	xbc	; F0A6A5  pop XBC
	unlk XIZ	; F0A6A6  unlk XIZ
	ret	; F0A6A8  ret

; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[130]
; Touches: nothing with an absolute address
; Calls:   0xFD86E1
; Evidence: word [130] of the pointer table at 0xFCF21B reads 0x00F0A6A9, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A6A9 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditPitchEnvelope2: SOFT KEY column 5 (lower or upper; the flag carries which) on ScreenCode89 -- ScreenCode89 op 4 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol5_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A6A9  link XIZ,0x0000
	pushw	19	; F0A6AD  push 0x0013
	ld	bc, (xiz+8)	; F0A6B0  ld BC,(XIZ+0x08)
	extz	bc	; F0A6B3  extz BC
	pushw	bc	; F0A6B5  push BC
	call	SoundEditEnvelope2_SoftKeyCol5	; F0A6B6  call 0xfd86e1
	pop	xbc	; F0A6BA  pop XBC
	unlk XIZ	; F0A6BB  unlk XIZ
	ret	; F0A6BD  ret

; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[132]
; Touches: nothing with an absolute address
; Calls:   0xFD8747
; Evidence: word [132] of the pointer table at 0xFCF21B reads 0x00F0A6BE, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A6BE is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditPitchEnvelope2: SOFT KEY column 7 (lower or upper; the flag carries which) on ScreenCode89 -- ScreenCode89 op 6 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol7_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A6BE  link XIZ,0x0000
	pushw	17	; F0A6C2  push 0x0011
	ld	bc, (xiz+8)	; F0A6C5  ld BC,(XIZ+0x08)
	extz	bc	; F0A6C8  extz BC
	pushw	bc	; F0A6CA  push BC
	call	SoundEditEnvelope2_SoftKeyCol7	; F0A6CB  call 0xfd8747
	pop	xbc	; F0A6CF  pop XBC
	unlk XIZ	; F0A6D0  unlk XIZ
	ret	; F0A6D2  ret

; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[133]
; Touches: nothing with an absolute address
; Calls:   0xFD87A5
; Evidence: word [133] of the pointer table at 0xFCF21B reads 0x00F0A6D3, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A6D3 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditPitchEnvelope2: SOFT KEY column 8 (lower or upper; the flag carries which) on ScreenCode89 -- ScreenCode89 op 7 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol8_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A6D3  link XIZ,0x0000
	pushw	18	; F0A6D7  push 0x0012
	ld	bc, (xiz+8)	; F0A6DA  ld BC,(XIZ+0x08)
	extz	bc	; F0A6DD  extz BC
	pushw	bc	; F0A6DF  push BC
	call	SoundEditEnvelope2_SoftKeyCol8	; F0A6E0  call 0xfd87a5
	pop	xbc	; F0A6E4  pop XBC
	unlk XIZ	; F0A6E5  unlk XIZ
	ret	; F0A6E7  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[134]
; Touches: nothing with an absolute address
; Calls:   0xFD6E90
; Evidence: word [134] of the pointer table at 0xFCF21B reads 0x00F0A6E8, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A6E8 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditPitchEnvelope2: LCD key row 1 (left or right) on ScreenCode89 -- ScreenCode89 op 8 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow1_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A6E8  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A6EC  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow1_SoundEditPitchEnvelope2_Skip	; F0A6F0  jr Z,0xf0a6f6
	call	Var27A2_ToggleWithP23	; F0A6F2  call 0xfd6e90
LcdKeyRow1_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F0A6F6  unlk XIZ
	ret	; F0A6F8  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[135]
; Touches: nothing with an absolute address
; Calls:   0xFD74AE 0xFD608B
; Evidence: word [135] of the pointer table at 0xFCF21B reads 0x00F0A6F9, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A6F9 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditPitchEnvelope2: LCD key row 2 (left or right) on ScreenCode89 -- ScreenCode89 op 9 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow2_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A6F9  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A6FD  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow2_SoundEditPitchEnvelope2_Skip	; F0A701  jr NZ,0xf0a70b
	pushw	0	; F0A703  push 0x0000
	pushw	135	; F0A706  push 0x0087
	jr	LcdKeyRow2_SoundEditPitchEnvelope2_Join	; F0A709  jr T,0xf0a71d
LcdKeyRow2_SoundEditPitchEnvelope2_Skip:
	pushw	1	; F0A70B  push 0x0001
	call	Var27A3_ChangeSlot	; F0A70E  call 0xfd74ae
	popw	bc	; F0A712  pop BC
	cp	a, 0:i3	; F0A713  cp A,0
	jr	z, LcdKeyRow2_SoundEditPitchEnvelope2_Skip2	; F0A715  jr Z,0xf0a722
	pushw	1	; F0A717  push 0x0001
	pushw	137	; F0A71A  push 0x0089
LcdKeyRow2_SoundEditPitchEnvelope2_Join:
	call	PanelScreen_PostRequest	; F0A71D  call 0xfd608b
	pop	xiy	; F0A721  pop XIY
LcdKeyRow2_SoundEditPitchEnvelope2_Skip2:
	unlk XIZ	; F0A722  unlk XIZ
	ret	; F0A724  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[136]
; Touches: nothing with an absolute address
; Calls:   0xFD74AE 0xFD608B
; Evidence: word [136] of the pointer table at 0xFCF21B reads 0x00F0A725, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A725 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditPitchEnvelope2: LCD key row 3 (left or right) on ScreenCode89 -- ScreenCode89 op 10 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow3_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A725  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A729  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow3_SoundEditPitchEnvelope2_Skip	; F0A72D  jr NZ,0xf0a737
	pushw	0	; F0A72F  push 0x0000
	pushw	138	; F0A732  push 0x008a
	jr	LcdKeyRow3_SoundEditPitchEnvelope2_Join	; F0A735  jr T,0xf0a749
LcdKeyRow3_SoundEditPitchEnvelope2_Skip:
	pushw	2	; F0A737  push 0x0002
	call	Var27A3_ChangeSlot	; F0A73A  call 0xfd74ae
	popw	bc	; F0A73E  pop BC
	cp	a, 0:i3	; F0A73F  cp A,0
	jr	z, LcdKeyRow3_SoundEditPitchEnvelope2_Skip2	; F0A741  jr Z,0xf0a74e
	pushw	1	; F0A743  push 0x0001
	pushw	137	; F0A746  push 0x0089
LcdKeyRow3_SoundEditPitchEnvelope2_Join:
	call	PanelScreen_PostRequest	; F0A749  call 0xfd608b
	pop	xiy	; F0A74D  pop XIY
LcdKeyRow3_SoundEditPitchEnvelope2_Skip2:
	unlk XIZ	; F0A74E  unlk XIZ
	ret	; F0A750  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[137]
; Touches: nothing with an absolute address
; Calls:   0xFD74AE 0xFD608B
; Evidence: word [137] of the pointer table at 0xFCF21B reads 0x00F0A751, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A751 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditPitchEnvelope2: LCD key row 4 (left or right) on ScreenCode89 -- ScreenCode89 op 11 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow4_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A751  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A755  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow4_SoundEditPitchEnvelope2_Skip	; F0A759  jr Z,0xf0a772
	pushw	3	; F0A75B  push 0x0003
	call	Var27A3_ChangeSlot	; F0A75E  call 0xfd74ae
	popw	bc	; F0A762  pop BC
	cp	a, 0:i3	; F0A763  cp A,0
	jr	z, LcdKeyRow4_SoundEditPitchEnvelope2_Skip	; F0A765  jr Z,0xf0a772
	pushw	1	; F0A767  push 0x0001
	pushw	137	; F0A76A  push 0x0089
	call	PanelScreen_PostRequest	; F0A76D  call 0xfd608b
	pop	xiy	; F0A771  pop XIY
LcdKeyRow4_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F0A772  unlk XIZ
	ret	; F0A774  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[138]
; Touches: nothing with an absolute address
; Calls:   0xFD74AE 0xFD608B
; Evidence: word [138] of the pointer table at 0xFCF21B reads 0x00F0A775, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A775 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditPitchEnvelope2: LCD key row 5 (left or right) on ScreenCode89 -- ScreenCode89 op 12 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow5_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A775  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A779  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow5_SoundEditPitchEnvelope2_Skip	; F0A77D  jr Z,0xf0a796
	pushw	4	; F0A77F  push 0x0004
	call	Var27A3_ChangeSlot	; F0A782  call 0xfd74ae
	popw	bc	; F0A786  pop BC
	cp	a, 0:i3	; F0A787  cp A,0
	jr	z, LcdKeyRow5_SoundEditPitchEnvelope2_Skip	; F0A789  jr Z,0xf0a796
	pushw	1	; F0A78B  push 0x0001
	pushw	137	; F0A78E  push 0x0089
	call	PanelScreen_PostRequest	; F0A791  call 0xfd608b
	pop	xiy	; F0A795  pop XIY
LcdKeyRow5_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F0A796  unlk XIZ
	ret	; F0A798  ret

; --------------------------------------------------------------------------
; PageKey_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[142]
; Touches: nothing with an absolute address
; Calls:   0xFD608B
; Evidence: word [142] of the pointer table at 0xFCF21B reads 0x00F0A799, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A799 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; PageKey_SoundEditPitchEnvelope2: the PAGE pair (code 0x10) on ScreenCode89 -- ScreenCode89 op 16 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
PageKey_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A799  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A79D  cp (XIZ+0x08),0x00
	jr	z, PageKey_SoundEditPitchEnvelope2_Skip	; F0A7A1  jr Z,0xf0a7ae
	pushw	0	; F0A7A3  push 0x0000
	pushw	136	; F0A7A6  push 0x0088
	call	PanelScreen_PostRequest	; F0A7A9  call 0xfd608b
	pop	xiy	; F0A7AD  pop XIY
PageKey_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F0A7AE  unlk XIZ
	ret	; F0A7B0  ret

; --------------------------------------------------------------------------
; ExitKey_SoundEditPitchEnvelope2
; Called from: table 0xFCF21B[141]
; Touches: nothing with an absolute address
; Calls:   0xFD69E0 0xFD608B
; Evidence: word [141] of the pointer table at 0xFCF21B reads 0x00F0A7B1, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A7B1 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SoundEditPitchEnvelope2: the EXIT key on ScreenCode89 -- ScreenCode89 op 15 (PanelOpTable_FCF413).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
ExitKey_SoundEditPitchEnvelope2:
	link XIZ,0x0000	; F0A7B1  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A7B5  cp (XIZ+0x08),0x00
	jr	nz, ExitKey_SoundEditPitchEnvelope2_Skip	; F0A7B9  jr NZ,0xf0a7ce
	pushw	0	; F0A7BB  push 0x0000
	call	ToneMsg_SendP23FromArr2800	; F0A7BE  call 0xfd69e0
	pushw	0	; F0A7C2  push 0x0000
	pushw	128	; F0A7C5  push 0x0080
	call	PanelScreen_PostRequest	; F0A7C8  call 0xfd608b
	inc	6, xsp	; F0A7CC  inc 6,XSP
ExitKey_SoundEditPitchEnvelope2_Skip:
	unlk XIZ	; F0A7CE  unlk XIZ
	ret	; F0A7D0  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditPitchLfo
; Called from: table 0xFCF21B[145]
; Touches: nothing with an absolute address
; Calls:   0xFD7E1A
; Evidence: word [145] of the pointer table at 0xFCF21B reads 0x00F0A7D1, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A7D1 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditPitchLfo: SOFT KEY column 2 (lower or upper; the flag carries which) on ScreenCode8A -- ScreenCode8A op 1 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol2_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A7D1  link XIZ,0x0000
	pushw	1	; F0A7D5  push 0x0001
	ld	bc, (xiz+8)	; F0A7D8  ld BC,(XIZ+0x08)
	extz	bc	; F0A7DB  extz BC
	pushw	bc	; F0A7DD  push BC
	call	SoundEditLfo_SoftKeyCol2	; F0A7DE  call 0xfd7e1a
	pop	xbc	; F0A7E2  pop XBC
	unlk XIZ	; F0A7E3  unlk XIZ
	ret	; F0A7E5  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditPitchLfo
; Called from: table 0xFCF21B[146]
; Touches: nothing with an absolute address
; Calls:   0xFD7E66
; Evidence: word [146] of the pointer table at 0xFCF21B reads 0x00F0A7E6, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A7E6 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditPitchLfo: SOFT KEY column 3 (lower or upper; the flag carries which) on ScreenCode8A -- ScreenCode8A op 2 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol3_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A7E6  link XIZ,0x0000
	pushw	1	; F0A7EA  push 0x0001
	ld	bc, (xiz+8)	; F0A7ED  ld BC,(XIZ+0x08)
	extz	bc	; F0A7F0  extz BC
	pushw	bc	; F0A7F2  push BC
	call	SoundEditLfo_SoftKeyCol3	; F0A7F3  call 0xfd7e66
	pop	xbc	; F0A7F7  pop XBC
	unlk XIZ	; F0A7F8  unlk XIZ
	ret	; F0A7FA  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditPitchLfo
; Called from: table 0xFCF21B[147]
; Touches: nothing with an absolute address
; Calls:   0xFD7ED9
; Evidence: word [147] of the pointer table at 0xFCF21B reads 0x00F0A7FB, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A7FB is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditPitchLfo: SOFT KEY column 4 (lower or upper; the flag carries which) on ScreenCode8A -- ScreenCode8A op 3 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol4_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A7FB  link XIZ,0x0000
	pushw	1	; F0A7FF  push 0x0001
	ld	bc, (xiz+8)	; F0A802  ld BC,(XIZ+0x08)
	extz	bc	; F0A805  extz BC
	pushw	bc	; F0A807  push BC
	call	SoundEditLfo_SoftKeyCol4	; F0A808  call 0xfd7ed9
	pop	xbc	; F0A80C  pop XBC
	unlk XIZ	; F0A80D  unlk XIZ
	ret	; F0A80F  ret

; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditPitchLfo
; Called from: table 0xFCF21B[148]
; Touches: nothing with an absolute address
; Calls:   0xFD7F4C
; Evidence: word [148] of the pointer table at 0xFCF21B reads 0x00F0A810, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A810 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditPitchLfo: SOFT KEY column 5 (lower or upper; the flag carries which) on ScreenCode8A -- ScreenCode8A op 4 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol5_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A810  link XIZ,0x0000
	pushw	1	; F0A814  push 0x0001
	ld	bc, (xiz+8)	; F0A817  ld BC,(XIZ+0x08)
	extz	bc	; F0A81A  extz BC
	pushw	bc	; F0A81C  push BC
	call	SoundEditLfo_SoftKeyCol5	; F0A81D  call 0xfd7f4c
	pop	xbc	; F0A821  pop XBC
	unlk XIZ	; F0A822  unlk XIZ
	ret	; F0A824  ret

; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditPitchLfo
; Called from: table 0xFCF21B[149]
; Touches: nothing with an absolute address
; Calls:   0xFD7FBF
; Evidence: word [149] of the pointer table at 0xFCF21B reads 0x00F0A825, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A825 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditPitchLfo: SOFT KEY column 6 (lower or upper; the flag carries which) on ScreenCode8A -- ScreenCode8A op 5 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol6_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A825  link XIZ,0x0000
	pushw	1	; F0A829  push 0x0001
	ld	bc, (xiz+8)	; F0A82C  ld BC,(XIZ+0x08)
	extz	bc	; F0A82F  extz BC
	pushw	bc	; F0A831  push BC
	call	SoundEditLfo_SoftKeyCol6	; F0A832  call 0xfd7fbf
	pop	xbc	; F0A836  pop XBC
	unlk XIZ	; F0A837  unlk XIZ
	ret	; F0A839  ret

; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditPitchLfo
; Called from: table 0xFCF21B[150]
; Touches: nothing with an absolute address
; Calls:   0xFD8030
; Evidence: word [150] of the pointer table at 0xFCF21B reads 0x00F0A83A, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A83A is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditPitchLfo: SOFT KEY column 7 (lower or upper; the flag carries which) on ScreenCode8A -- ScreenCode8A op 6 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol7_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A83A  link XIZ,0x0000
	pushw	1	; F0A83E  push 0x0001
	ld	bc, (xiz+8)	; F0A841  ld BC,(XIZ+0x08)
	extz	bc	; F0A844  extz BC
	pushw	bc	; F0A846  push BC
	call	SoundEditLfo_SoftKeyCol7	; F0A847  call 0xfd8030
	pop	xbc	; F0A84B  pop XBC
	unlk XIZ	; F0A84C  unlk XIZ
	ret	; F0A84E  ret

; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditPitchLfo
; Called from: table 0xFCF21B[151]
; Touches: nothing with an absolute address
; Calls:   0xFD80A3
; Evidence: word [151] of the pointer table at 0xFCF21B reads 0x00F0A84F, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A84F is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditPitchLfo: SOFT KEY column 8 (lower or upper; the flag carries which) on ScreenCode8A -- ScreenCode8A op 7 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol8_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A84F  link XIZ,0x0000
	pushw	1	; F0A853  push 0x0001
	ld	bc, (xiz+8)	; F0A856  ld BC,(XIZ+0x08)
	extz	bc	; F0A859  extz BC
	pushw	bc	; F0A85B  push BC
	call	SoundEditLfo_SoftKeyCol8	; F0A85C  call 0xfd80a3
	pop	xbc	; F0A860  pop XBC
	unlk XIZ	; F0A861  unlk XIZ
	ret	; F0A863  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditPitchLfo
; Called from: table 0xFCF21B[152]
; Touches: nothing with an absolute address
; Calls:   0xFD608B 0xFD6E90
; Evidence: word [152] of the pointer table at 0xFCF21B reads 0x00F0A864, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A864 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditPitchLfo: LCD key row 1 (left or right) on ScreenCode8A -- ScreenCode8A op 8 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow1_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A864  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A868  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow1_SoundEditPitchLfo_Skip	; F0A86C  jr NZ,0xf0a87b
	pushw	0	; F0A86E  push 0x0000
	pushw	136	; F0A871  push 0x0088
	call	PanelScreen_PostRequest	; F0A874  call 0xfd608b
	pop	xiy	; F0A878  pop XIY
	jr	LcdKeyRow1_SoundEditPitchLfo_Join	; F0A879  jr T,0xf0a87f
LcdKeyRow1_SoundEditPitchLfo_Skip:
	call	Var27A2_ToggleWithP23	; F0A87B  call 0xfd6e90
LcdKeyRow1_SoundEditPitchLfo_Join:
	unlk XIZ	; F0A87F  unlk XIZ
	ret	; F0A881  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditPitchLfo
; Called from: table 0xFCF21B[153]
; Touches: nothing with an absolute address
; Calls:   0xFD608B 0xFD74E0
; Evidence: word [153] of the pointer table at 0xFCF21B reads 0x00F0A882, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A882 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditPitchLfo: LCD key row 2 (left or right) on ScreenCode8A -- ScreenCode8A op 9 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow2_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A882  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A886  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow2_SoundEditPitchLfo_Skip	; F0A88A  jr NZ,0xf0a898
	pushw	0	; F0A88C  push 0x0000
	pushw	135	; F0A88F  push 0x0087
	call	PanelScreen_PostRequest	; F0A892  call 0xfd608b
	jr	LcdKeyRow2_SoundEditPitchLfo_Join	; F0A896  jr T,0xf0a8a2
LcdKeyRow2_SoundEditPitchLfo_Skip:
	pushw	1	; F0A898  push 0x0001
	pushw	1	; F0A89B  push 0x0001
	call	SoundEditLfo_CycleLfoState	; F0A89E  call 0xfd74e0
LcdKeyRow2_SoundEditPitchLfo_Join:
	pop	xiy	; F0A8A2  pop XIY
	unlk XIZ	; F0A8A3  unlk XIZ
	ret	; F0A8A5  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditPitchLfo
; Called from: table 0xFCF21B[154]
; Touches: nothing with an absolute address
; Calls:   0xFD74E0
; Evidence: word [154] of the pointer table at 0xFCF21B reads 0x00F0A8A6, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A8A6 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditPitchLfo: LCD key row 3 (left or right) on ScreenCode8A -- ScreenCode8A op 10 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow3_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A8A6  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A8AA  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow3_SoundEditPitchLfo_Skip	; F0A8AE  jr Z,0xf0a8bb
	pushw	2	; F0A8B0  push 0x0002
	pushw	1	; F0A8B3  push 0x0001
	call	SoundEditLfo_CycleLfoState	; F0A8B6  call 0xfd74e0
	pop	xiy	; F0A8BA  pop XIY
LcdKeyRow3_SoundEditPitchLfo_Skip:
	unlk XIZ	; F0A8BB  unlk XIZ
	ret	; F0A8BD  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditPitchLfo
; Called from: table 0xFCF21B[155]
; Touches: nothing with an absolute address
; Calls:   0xFD74E0
; Evidence: word [155] of the pointer table at 0xFCF21B reads 0x00F0A8BE, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A8BE is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditPitchLfo: LCD key row 4 (left or right) on ScreenCode8A -- ScreenCode8A op 11 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow4_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A8BE  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A8C2  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow4_SoundEditPitchLfo_Skip	; F0A8C6  jr Z,0xf0a8d3
	pushw	3	; F0A8C8  push 0x0003
	pushw	1	; F0A8CB  push 0x0001
	call	SoundEditLfo_CycleLfoState	; F0A8CE  call 0xfd74e0
	pop	xiy	; F0A8D2  pop XIY
LcdKeyRow4_SoundEditPitchLfo_Skip:
	unlk XIZ	; F0A8D3  unlk XIZ
	ret	; F0A8D5  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditPitchLfo
; Called from: table 0xFCF21B[156]
; Touches: nothing with an absolute address
; Calls:   0xFD74E0
; Evidence: word [156] of the pointer table at 0xFCF21B reads 0x00F0A8D6, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A8D6 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditPitchLfo: LCD key row 5 (left or right) on ScreenCode8A -- ScreenCode8A op 12 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow5_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A8D6  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A8DA  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow5_SoundEditPitchLfo_Skip	; F0A8DE  jr Z,0xf0a8eb
	pushw	4	; F0A8E0  push 0x0004
	pushw	1	; F0A8E3  push 0x0001
	call	SoundEditLfo_CycleLfoState	; F0A8E6  call 0xfd74e0
	pop	xiy	; F0A8EA  pop XIY
LcdKeyRow5_SoundEditPitchLfo_Skip:
	unlk XIZ	; F0A8EB  unlk XIZ
	ret	; F0A8ED  ret

; --------------------------------------------------------------------------
; ExitKey_SoundEditPitchLfo
; Called from: table 0xFCF21B[159]
; Touches: nothing with an absolute address
; Calls:   0xFD69E0 0xFD608B
; Evidence: word [159] of the pointer table at 0xFCF21B reads 0x00F0A8EE, that
;           table's reader TRANSFERS to the word it loads, and 0xF0A8EE is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SoundEditPitchLfo: the EXIT key on ScreenCode8A -- ScreenCode8A op 15 (PanelOpTable_FCF45B).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
ExitKey_SoundEditPitchLfo:
	link XIZ,0x0000	; F0A8EE  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0A8F2  cp (XIZ+0x08),0x00
	jr	nz, ExitKey_SoundEditPitchLfo_Skip	; F0A8F6  jr NZ,0xf0a90b
	pushw	0	; F0A8F8  push 0x0000
	call	ToneMsg_SendP23FromArr2800	; F0A8FB  call 0xfd69e0
	pushw	0	; F0A8FF  push 0x0000
	pushw	128	; F0A902  push 0x0080
	call	PanelScreen_PostRequest	; F0A905  call 0xfd608b
	inc	6, xsp	; F0A909  inc 6,XSP
ExitKey_SoundEditPitchLfo_Skip:
	unlk XIZ	; F0A90B  unlk XIZ
	ret	; F0A90D  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditCopy
; Called from: T_ScreenButton_SoundEditCopy (x0)
; Touches:   |  0xFCFC44
; Calls:   0xFD7905 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditCopy holds `jp 0x00F0A90E`, and 0xF0A90E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditCopy: the +8 BUTTON method of PanelScreen_VtableTable entry 0x9D: that entry points at the thunk triple T_ScreenEnter_SoundEditCopy (Enter) / T_ScreenLeave_SoundEditCopy (Leave) / T_ScreenButton_SoundEditCopy (Button).
ScreenButton_SoundEditCopy:		; <- T_ScreenButton_SoundEditCopy
	link XIZ,0xfffc	; F0A90E  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0A912  lda XBC,XIZ+0xfe
	push	xbc	; F0A915  push XBC
	lda	xwa, (xiz-4)	; F0A916  lda XWA,XIZ+0xfc
	push	xwa	; F0A919  push XWA
	pushw	(xiz+10)	; F0A91A  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0A91D  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0A920  call 0xfd7905
	inc	8, xsp	; F0A924  inc 0,XSP
	inc	4, xsp	; F0A926  inc 4,XSP
	cp	wa, 65535	; F0A928  cp WA,0xffff
	jr	z, ScreenButton_SoundEditCopy_Skip	; F0A92C  jr Z,0xf0a95c
	ld	bc, (xiz-2)	; F0A92E  ld BC,(XIZ+0xfe)
	extz	bc	; F0A931  extz BC
	pushw	bc	; F0A933  push BC
	ld	c, 4:opc	; F0A934  ld C,0x04
	mul	bc, (xiz-4)	; F0A936  mul BC,(XIZ+0xfc)
	extz	xbc	; F0A939  extz XBC
	add	xbc, PanelOpTable_FCFC44	; F0A93B  add XBC,0x00fcfc44
	ld	xbc, (xbc)	; F0A941  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditCopy_Resume:24)	; F0A943  lda XIY,0xf0a94b
	push	xiy	; F0A948  push XIY
	jp	(xbc)	; F0A949  jp T,XBC
ScreenButton_SoundEditCopy_Resume:
	call	PanelScreen_RequestPending	; F0A94B  call 0xfd60b9
	popw	bc	; F0A94F  pop BC
	cp	a, 0:i3	; F0A950  cp A,0
	jr	nz, ScreenButton_SoundEditCopy_Skip	; F0A952  jr NZ,0xf0a95c
	pushw	16	; F0A954  push 0x0010
	call	ToneMsg80_Id00	; F0A957  call 0xfd6447
	popw	bc	; F0A95B  pop BC
ScreenButton_SoundEditCopy_Skip:
	unlk XIZ	; F0A95C  unlk XIZ
	ret	; F0A95E  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditMemoryWrite
; Called from: T_ScreenButton_SoundEditMemoryWrite (x0)
; Touches:   |  0xFCFB6C
; Calls:   0xFD7905 0xFDAC5B 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditMemoryWrite holds `jp 0x00F0A95F`, and 0xF0A95F is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditMemoryWrite: the +8 BUTTON method of PanelScreen_VtableTable entry 0x9E: that entry points at the thunk triple T_ScreenEnter_SoundEditMemoryWrite (Enter) / T_F42364_Nop (Leave) / T_ScreenButton_SoundEditMemoryWrite (Button).
ScreenButton_SoundEditMemoryWrite:		; <- T_ScreenButton_SoundEditMemoryWrite
	link XIZ,0xfffc	; F0A95F  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0A963  lda XBC,XIZ+0xfe
	push	xbc	; F0A966  push XBC
	lda	xwa, (xiz-4)	; F0A967  lda XWA,XIZ+0xfc
	push	xwa	; F0A96A  push XWA
	pushw	(xiz+10)	; F0A96B  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0A96E  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0A971  call 0xfd7905
	inc	8, xsp	; F0A975  inc 0,XSP
	inc	4, xsp	; F0A977  inc 4,XSP
	cp	wa, 65535	; F0A979  cp WA,0xffff
	jr	z, ScreenButton_SoundEditMemoryWrite_Skip	; F0A97D  jr Z,0xf0a9bc
	pushw	1	; F0A97F  push 0x0001
	call	LCD_SetPanelDarkFlag	; F0A982  call 0xfdac5b
	ld	bc, (xiz-2)	; F0A986  ld BC,(XIZ+0xfe)
	extz	bc	; F0A989  extz BC
	pushw	bc	; F0A98B  push BC
	ld	c, 4:opc	; F0A98C  ld C,0x04
	mul	bc, (xiz-4)	; F0A98E  mul BC,(XIZ+0xfc)
	extz	xbc	; F0A991  extz XBC
	add	xbc, PanelOpTable_FCFB6C	; F0A993  add XBC,0x00fcfb6c
	ld	xbc, (xbc)	; F0A999  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditMemoryWrite_Resume:24)	; F0A99B  lda XIY,0xf0a9a3
	push	xiy	; F0A9A0  push XIY
	jp	(xbc)	; F0A9A1  jp T,XBC
ScreenButton_SoundEditMemoryWrite_Resume:
	pushw	0	; F0A9A3  push 0x0000
	call	LCD_SetPanelDarkFlag	; F0A9A6  call 0xfdac5b
	call	PanelScreen_RequestPending	; F0A9AA  call 0xfd60b9
	inc	6, xsp	; F0A9AE  inc 6,XSP
	cp	a, 0:i3	; F0A9B0  cp A,0
	jr	nz, ScreenButton_SoundEditMemoryWrite_Skip	; F0A9B2  jr NZ,0xf0a9bc
	pushw	16	; F0A9B4  push 0x0010
	call	ToneMsg80_Id00	; F0A9B7  call 0xfd6447
	popw	bc	; F0A9BB  pop BC
ScreenButton_SoundEditMemoryWrite_Skip:
	unlk XIZ	; F0A9BC  unlk XIZ
	ret	; F0A9BE  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditNaming
; Called from: T_ScreenButton_SoundEditNaming (x0)
; Touches:   |  0xFCFBB4
; Calls:   0xFD7905 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditNaming holds `jp 0x00F0A9BF`, and 0xF0A9BF is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditNaming: the +8 BUTTON method of PanelScreen_VtableTable entry 0x9F: that entry points at the thunk triple T_ScreenEnter_SoundEditNaming (Enter) / T_F42374_Nop (Leave) / T_ScreenButton_SoundEditNaming (Button).
ScreenButton_SoundEditNaming:		; <- T_ScreenButton_SoundEditNaming
	link XIZ,0xfffc	; F0A9BF  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0A9C3  lda XBC,XIZ+0xfe
	push	xbc	; F0A9C6  push XBC
	lda	xwa, (xiz-4)	; F0A9C7  lda XWA,XIZ+0xfc
	push	xwa	; F0A9CA  push XWA
	pushw	(xiz+10)	; F0A9CB  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0A9CE  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0A9D1  call 0xfd7905
	inc	8, xsp	; F0A9D5  inc 0,XSP
	inc	4, xsp	; F0A9D7  inc 4,XSP
	cp	wa, 65535	; F0A9D9  cp WA,0xffff
	jr	z, ScreenButton_SoundEditNaming_Skip	; F0A9DD  jr Z,0xf0aa0d
	ld	bc, (xiz-2)	; F0A9DF  ld BC,(XIZ+0xfe)
	extz	bc	; F0A9E2  extz BC
	pushw	bc	; F0A9E4  push BC
	ld	c, 4:opc	; F0A9E5  ld C,0x04
	mul	bc, (xiz-4)	; F0A9E7  mul BC,(XIZ+0xfc)
	extz	xbc	; F0A9EA  extz XBC
	add	xbc, PanelOpTable_FCFBB4	; F0A9EC  add XBC,0x00fcfbb4
	ld	xbc, (xbc)	; F0A9F2  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditNaming_Resume:24)	; F0A9F4  lda XIY,0xf0a9fc
	push	xiy	; F0A9F9  push XIY
	jp	(xbc)	; F0A9FA  jp T,XBC
ScreenButton_SoundEditNaming_Resume:
	call	PanelScreen_RequestPending	; F0A9FC  call 0xfd60b9
	popw	bc	; F0AA00  pop BC
	cp	a, 0:i3	; F0AA01  cp A,0
	jr	nz, ScreenButton_SoundEditNaming_Skip	; F0AA03  jr NZ,0xf0aa0d
	pushw	16	; F0AA05  push 0x0010
	call	ToneMsg80_Id00	; F0AA08  call 0xfd6447
	popw	bc	; F0AA0C  pop BC
ScreenButton_SoundEditNaming_Skip:
	unlk XIZ	; F0AA0D  unlk XIZ
	ret	; F0AA0F  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditDigitalEffect
; Called from: T_ScreenButton_SoundEditDigitalEffect (x0)
; Touches:   |  0xFCFBFC
; Calls:   0xFD7905 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditDigitalEffect holds `jp 0x00F0AA10`, and 0xF0AA10 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditDigitalEffect: the +8 BUTTON method of PanelScreen_VtableTable entry 0x9A: that entry points at the thunk triple T_ScreenEnter_SoundEditDigitalEffect (Enter) / T_ScreenLeave_SoundEditDigitalEffect (Leave) / T_ScreenButton_SoundEditDigitalEffect (Button). Screen 0x9A is SOUND EDIT DIGITAL EFFECT (Dispatch_Code80_PaintTable[0x9A]).
ScreenButton_SoundEditDigitalEffect:		; <- T_ScreenButton_SoundEditDigitalEffect
	link XIZ,0xfffc	; F0AA10  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0AA14  lda XBC,XIZ+0xfe
	push	xbc	; F0AA17  push XBC
	lda	xwa, (xiz-4)	; F0AA18  lda XWA,XIZ+0xfc
	push	xwa	; F0AA1B  push XWA
	pushw	(xiz+10)	; F0AA1C  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0AA1F  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0AA22  call 0xfd7905
	inc	8, xsp	; F0AA26  inc 0,XSP
	inc	4, xsp	; F0AA28  inc 4,XSP
	cp	wa, 65535	; F0AA2A  cp WA,0xffff
	jr	z, ScreenButton_SoundEditDigitalEffect_Skip	; F0AA2E  jr Z,0xf0aa5e
	ld	bc, (xiz-2)	; F0AA30  ld BC,(XIZ+0xfe)
	extz	bc	; F0AA33  extz BC
	pushw	bc	; F0AA35  push BC
	ld	c, 4:opc	; F0AA36  ld C,0x04
	mul	bc, (xiz-4)	; F0AA38  mul BC,(XIZ+0xfc)
	extz	xbc	; F0AA3B  extz XBC
	add	xbc, PanelOpTable_FCFBFC	; F0AA3D  add XBC,0x00fcfbfc
	ld	xbc, (xbc)	; F0AA43  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditDigitalEffect_Resume:24)	; F0AA45  lda XIY,0xf0aa4d
	push	xiy	; F0AA4A  push XIY
	jp	(xbc)	; F0AA4B  jp T,XBC
ScreenButton_SoundEditDigitalEffect_Resume:
	call	PanelScreen_RequestPending	; F0AA4D  call 0xfd60b9
	popw	bc	; F0AA51  pop BC
	cp	a, 0:i3	; F0AA52  cp A,0
	jr	nz, ScreenButton_SoundEditDigitalEffect_Skip	; F0AA54  jr NZ,0xf0aa5e
	pushw	16	; F0AA56  push 0x0010
	call	ToneMsg80_Id00	; F0AA59  call 0xfd6447
	popw	bc	; F0AA5D  pop BC
ScreenButton_SoundEditDigitalEffect_Skip:
	unlk XIZ	; F0AA5E  unlk XIZ
	ret	; F0AA60  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditDigitalEffectFromMenu
; Called from: T_ScreenButton_SoundEditDigitalEffectFromMenu (x0)
; Touches:   |  0xFCFBFC
; Calls:   0xFD7905 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditDigitalEffectFromMenu holds `jp 0x00F0AA61`, and 0xF0AA61 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditDigitalEffectFromMenu: the +8 BUTTON method of PanelScreen_VtableTable entry 0x9C: that entry points at the thunk triple T_ScreenEnter_SoundEditDigitalEffectFromMenu (Enter) / T_ScreenLeave_SoundEditDigitalEffectFromMenu (Leave) / T_ScreenButton_SoundEditDigitalEffectFromMenu (Button).
ScreenButton_SoundEditDigitalEffectFromMenu:		; <- T_ScreenButton_SoundEditDigitalEffectFromMenu
	link XIZ,0xfffc	; F0AA61  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0AA65  lda XBC,XIZ+0xfe
	push	xbc	; F0AA68  push XBC
	lda	xwa, (xiz-4)	; F0AA69  lda XWA,XIZ+0xfc
	push	xwa	; F0AA6C  push XWA
	pushw	(xiz+10)	; F0AA6D  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0AA70  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0AA73  call 0xfd7905
	inc	8, xsp	; F0AA77  inc 0,XSP
	inc	4, xsp	; F0AA79  inc 4,XSP
	cp	wa, 65535	; F0AA7B  cp WA,0xffff
	jr	z, ScreenButton_SoundEditDigitalEffectFromMenu_Skip	; F0AA7F  jr Z,0xf0aaaf
	ld	bc, (xiz-2)	; F0AA81  ld BC,(XIZ+0xfe)
	extz	bc	; F0AA84  extz BC
	pushw	bc	; F0AA86  push BC
	ld	c, 4:opc	; F0AA87  ld C,0x04
	mul	bc, (xiz-4)	; F0AA89  mul BC,(XIZ+0xfc)
	extz	xbc	; F0AA8C  extz XBC
	add	xbc, PanelOpTable_FCFBFC	; F0AA8E  add XBC,0x00fcfbfc
	ld	xbc, (xbc)	; F0AA94  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditDigitalEffectFromMenu_Resume:24)	; F0AA96  lda XIY,0xf0aa9e
	push	xiy	; F0AA9B  push XIY
	jp	(xbc)	; F0AA9C  jp T,XBC
ScreenButton_SoundEditDigitalEffectFromMenu_Resume:
	call	PanelScreen_RequestPending	; F0AA9E  call 0xfd60b9
	popw	bc	; F0AAA2  pop BC
	cp	a, 0:i3	; F0AAA3  cp A,0
	jr	nz, ScreenButton_SoundEditDigitalEffectFromMenu_Skip	; F0AAA5  jr NZ,0xf0aaaf
	pushw	16	; F0AAA7  push 0x0010
	call	ToneMsg80_Id00	; F0AAAA  call 0xfd6447
	popw	bc	; F0AAAE  pop BC
ScreenButton_SoundEditDigitalEffectFromMenu_Skip:
	unlk XIZ	; F0AAAF  unlk XIZ
	ret	; F0AAB1  ret

; --------------------------------------------------------------------------
; T_F433E8_Nop
; Called from: T_F433E8 (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F433E8 holds `jp 0x00F0AAB2`, and 0xF0AAB2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Purpose: none -- the entry is a lone `ret`.  Named T_F433E8_Nop after what reaches it
;          (was sub_F0AAB2; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F433E8_Nop:		; <- T_F433E8
	ret	; F0AAB2  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditDspEffect
; Called from: T_ScreenButton_SoundEditDspEffect (x0)
; Touches: nothing with an absolute address
; Calls:   0xFD7905 0xFD6104 T_ScreenButtonBody_DspEffect 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditDspEffect holds `jp 0x00F0AAB3`, and 0xF0AAB3 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditDspEffect: the +8 BUTTON method of the screen object for screen id 0xCA -- PanelScreen_VtableTable entry 0xEA
;   (ViewB entry 0xCA) points at the thunk triple starting at T_ScreenEnter_SoundEditDspEffect, and slot T_ScreenButton_SoundEditDspEffect jumps here.
ScreenButton_SoundEditDspEffect:		; <- T_ScreenButton_SoundEditDspEffect
	link XIZ,0xfffc	; F0AAB3  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0AAB7  lda XBC,XIZ+0xfe
	push	xbc	; F0AABA  push XBC
	lda	xwa, (xiz-4)	; F0AABB  lda XWA,XIZ+0xfc
	push	xwa	; F0AABE  push XWA
	pushw	(xiz+10)	; F0AABF  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0AAC2  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0AAC5  call 0xfd7905
	inc	8, xsp	; F0AAC9  inc 0,XSP
	inc	4, xsp	; F0AACB  inc 4,XSP
	cp	wa, 65535	; F0AACD  cp WA,0xffff
	jr	z, ScreenButton_SoundEditDspEffect_Skip	; F0AAD1  jr Z,0xf0aaf6
	pushw	0	; F0AAD3  push 0x0000
	call	Var27DF_Set	; F0AAD6  call 0xfd6104
	pushw	(xiz+10)	; F0AADA  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0AADD  pushw (XIZ+0x08)
	call	T_ScreenButtonBody_DspEffect	; F0AAE0  call 0xf42f50
	call	PanelScreen_RequestPending	; F0AAE4  call 0xfd60b9
	inc	6, xsp	; F0AAE8  inc 6,XSP
	cp	a, 0:i3	; F0AAEA  cp A,0
	jr	nz, ScreenButton_SoundEditDspEffect_Skip	; F0AAEC  jr NZ,0xf0aaf6
	pushw	16	; F0AAEE  push 0x0010
	call	ToneMsg80_Id00	; F0AAF1  call 0xfd6447
	popw	bc	; F0AAF5  pop BC
ScreenButton_SoundEditDspEffect_Skip:
	unlk XIZ	; F0AAF6  unlk XIZ
	ret	; F0AAF8  ret

; --------------------------------------------------------------------------
; ScreenButton_SoundEditDrumMenu
; Called from: T_ScreenButton_SoundEditDrumMenu (x0)
; Touches:   |  0xFCFC8C
; Calls:   0xFD7905 0xFD60B9 0xFD6447
; Evidence: thunk slot T_ScreenButton_SoundEditDrumMenu holds `jp 0x00F0AAF9`, and 0xF0AAF9 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_SoundEditDrumMenu: the +8 BUTTON method of PanelScreen_VtableTable entry 0xCB: that entry points at the thunk triple T_ScreenEnter_SoundEditDrumMenu (Enter) / T_ScreenLeave_SoundEditDrumMenu (Leave) / T_ScreenButton_SoundEditDrumMenu (Button).
ScreenButton_SoundEditDrumMenu:		; <- T_ScreenButton_SoundEditDrumMenu
	link XIZ,0xfffc	; F0AAF9  link XIZ,0xfffc
	lda	xbc, (xiz-2)	; F0AAFD  lda XBC,XIZ+0xfe
	push	xbc	; F0AB00  push XBC
	lda	xwa, (xiz-4)	; F0AB01  lda XWA,XIZ+0xfc
	push	xwa	; F0AB04  push XWA
	pushw	(xiz+10)	; F0AB05  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F0AB08  pushw (XIZ+0x08)
	call	PanelEvent_ToFieldIndex	; F0AB0B  call 0xfd7905
	inc	8, xsp	; F0AB0F  inc 0,XSP
	inc	4, xsp	; F0AB11  inc 4,XSP
	cp	wa, 65535	; F0AB13  cp WA,0xffff
	jr	z, ScreenButton_SoundEditDrumMenu_Skip	; F0AB17  jr Z,0xf0ab47
	ld	bc, (xiz-2)	; F0AB19  ld BC,(XIZ+0xfe)
	extz	bc	; F0AB1C  extz BC
	pushw	bc	; F0AB1E  push BC
	ld	c, 4:opc	; F0AB1F  ld C,0x04
	mul	bc, (xiz-4)	; F0AB21  mul BC,(XIZ+0xfc)
	extz	xbc	; F0AB24  extz XBC
	add	xbc, PanelOpTable_FCFC8C	; F0AB26  add XBC,0x00fcfc8c
	ld	xbc, (xbc)	; F0AB2C  ld XBC,(XBC)
	lda	xiy, (ScreenButton_SoundEditDrumMenu_Resume:24)	; F0AB2E  lda XIY,0xf0ab36
	push	xiy	; F0AB33  push XIY
	jp	(xbc)	; F0AB34  jp T,XBC
ScreenButton_SoundEditDrumMenu_Resume:
	call	PanelScreen_RequestPending	; F0AB36  call 0xfd60b9
	popw	bc	; F0AB3A  pop BC
	cp	a, 0:i3	; F0AB3B  cp A,0
	jr	nz, ScreenButton_SoundEditDrumMenu_Skip	; F0AB3D  jr NZ,0xf0ab47
	pushw	16	; F0AB3F  push 0x0010
	call	ToneMsg80_Id00	; F0AB42  call 0xfd6447
	popw	bc	; F0AB46  pop BC
ScreenButton_SoundEditDrumMenu_Skip:
	unlk XIZ	; F0AB47  unlk XIZ
	ret	; F0AB49  ret

; --------------------------------------------------------------------------
; T_F42348_Nop
; Called from: T_F42348 (x0)
; Touches: nothing with an absolute address
; Evidence: thunk slot T_F42348 holds `jp 0x00F0AB4A`, and 0xF0AB4A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Purpose: none -- the entry is a lone `ret`.  Named T_F42348_Nop after what reaches it
;          (was sub_F0AB4A; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F42348_Nop:		; <- T_F42348
	ret	; F0AB4A  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDrumMenu
; Called from: table 0xFCF80C[289]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFDA194 0xFDA142 0xFDA152 0xFD608B 0xFDA467
; Evidence: word [289] of the pointer table at 0xFCF80C reads 0x00F0AB4B, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AB4B is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDrumMenu: SOFT KEY column 2 (lower or upper; the flag carries which) on ScreenCodeCB -- ScreenCodeCB op 1 (PanelOpTable_FCFC8C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol2_SoundEditDrumMenu:
	link XIZ,0xfffc	; F0AB4B  link XIZ,0xfffc
	pushw	hl	; F0AB4F  push HL
	lda	xbc, (xiz-2)	; F0AB50  lda XBC,XIZ+0xfe
	push	xbc	; F0AB53  push XBC
	call	Var27F5_Get	; F0AB54  call 0xfda0ca
	pop	xiy	; F0AB58  pop XIY
	cp	(xiz-2), 0x00	; F0AB59  cp (XIZ+0xfe),0x00
	jr	z, SoftKeyCol2_SoundEditDrumMenu_Skip3	; F0AB5D  jr Z,0xf0abb5
	call	PartNotes_GetCurrentPartHeldNote	; F0AB5F  call 0xfda194
	ld	h, a	; F0AB63  ld H,A
	cp	a, 255	; F0AB65  cp A,0xff
	jr	nz, SoftKeyCol2_SoundEditDrumMenu_Skip2	; F0AB68  jr NZ,0xf0ab99
	lda	xbc, (xiz-4)	; F0AB6A  lda XBC,XIZ+0xfc
	push	xbc	; F0AB6D  push XBC
	call	Var27FC_Get	; F0AB6E  call 0xfda142
	ld	c, (xiz+8)	; F0AB72  ld C,(XIZ+0x08)
	res	7, c	; F0AB75  res 0x07,C
	pop	xiy	; F0AB78  pop XIY
	cp	c, 0:i3	; F0AB79  cp C,0
	jr	nz, SoftKeyCol2_SoundEditDrumMenu_Skip	; F0AB7B  jr NZ,0xf0ab88
	cp	(xiz-4), 0x7f	; F0AB7D  cp (XIZ+0xfc),0x7f
	jr	nc, SoftKeyCol2_SoundEditDrumMenu_Skip3	; F0AB81  jr NC,0xf0abb5
	incm8	1, (xiz-4)	; F0AB83  inc 1,(XIZ+0xfc)
	jr	SoftKeyCol2_SoundEditDrumMenu_Join	; F0AB86  jr T,0xf0ab91
SoftKeyCol2_SoundEditDrumMenu_Skip:
	cp	(xiz-4), 0x00	; F0AB88  cp (XIZ+0xfc),0x00
	jr	z, SoftKeyCol2_SoundEditDrumMenu_Skip3	; F0AB8C  jr Z,0xf0abb5
	decm8	1, (xiz-4)	; F0AB8E  dec 1,(XIZ+0xfc)
SoftKeyCol2_SoundEditDrumMenu_Join:
	ld	bc, (xiz-4)	; F0AB91  ld BC,(XIZ+0xfc)
	extz	bc	; F0AB94  extz BC
	pushw	bc	; F0AB96  push BC
	jr	SoftKeyCol2_SoundEditDrumMenu_Join2	; F0AB97  jr T,0xf0ab9e
SoftKeyCol2_SoundEditDrumMenu_Skip2:
	ld	c, h	; F0AB99  ld C,H
	extz	bc	; F0AB9B  extz BC
	pushw	bc	; F0AB9D  push BC
SoftKeyCol2_SoundEditDrumMenu_Join2:
	call	Var27FC_Set	; F0AB9E  call 0xfda152
	pushw	1	; F0ABA2  push 0x0001
	pushw	203	; F0ABA5  push 0x00cb
	call	PanelScreen_PostRequest	; F0ABA8  call 0xfd608b
	pushw	1	; F0ABAC  push 0x0001
	call	UiRequestBits_SetBit3	; F0ABAF  call 0xfda467
	inc	8, xsp	; F0ABB3  inc 0,XSP
SoftKeyCol2_SoundEditDrumMenu_Skip3:
	popw	hl	; F0ABB5  pop HL
	unlk XIZ	; F0ABB6  unlk XIZ
	ret	; F0ABB8  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDrumMenu
; Called from: table 0xFCF80C[290]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFDA05E 0xFD9D5C 0xFDA002 0xFD66A6 0xFD608B 0xFDA467
; Evidence: word [290] of the pointer table at 0xFCF80C reads 0x00F0ABB9, that
;           table's reader TRANSFERS to the word it loads, and 0xF0ABB9 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDrumMenu: SOFT KEY column 3 (lower or upper; the flag carries which) on ScreenCodeCB -- ScreenCodeCB op 2 (PanelOpTable_FCFC8C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol3_SoundEditDrumMenu:
	link XIZ,0xfff8	; F0ABB9  link XIZ,0xfff8
	pushw	hl	; F0ABBD  push HL
	lda	xbc, (xiz-2)	; F0ABBE  lda XBC,XIZ+0xfe
	push	xbc	; F0ABC1  push XBC
	call	Var27F5_Get	; F0ABC2  call 0xfda0ca
	pop	xiy	; F0ABC6  pop XIY
	cp	(xiz-2), 0x00	; F0ABC7  cp (XIZ+0xfe),0x00
	jrl	z, SoftKeyCol3_SoundEditDrumMenu_Skip2	; F0ABCB  jrl Z,0xf0ac3f
	lda	xbc, (xiz-4)	; F0ABCE  lda XBC,XIZ+0xfc
	push	xbc	; F0ABD1  push XBC
	pushw	0	; F0ABD2  push 0x0000
	pushw	2	; F0ABD5  push 0x0002
	call	ModelingPage_GetItemGroup	; F0ABD8  call 0xfda05e
	lda	xbc, (xiz-6)	; F0ABDC  lda XBC,XIZ+0xfa
	push	xbc	; F0ABDF  push XBC
	call	Var27F4_Get	; F0ABE0  call 0xfd9d5c
	ld	c, (xiz+8)	; F0ABE4  ld C,(XIZ+0x08)
	res	7, c	; F0ABE7  res 0x07,C
	inc	8, xsp	; F0ABEA  inc 0,XSP
	inc	4, xsp	; F0ABEC  inc 4,XSP
	cp	c, 0:i3	; F0ABEE  cp C,0
	jr	nz, SoftKeyCol3_SoundEditDrumMenu_Skip	; F0ABF0  jr NZ,0xf0ac09
	ld	bc, (xiz-6)	; F0ABF2  ld BC,(XIZ+0xfa)
	extz	bc	; F0ABF5  extz BC
	ld	hl, bc	; F0ABF7  ld HL,BC
	dec	1, hl	; F0ABF9  dec 1,HL
	ld	bc, (xiz-4)	; F0ABFB  ld BC,(XIZ+0xfc)
	extz	bc	; F0ABFE  extz BC
	cp	bc, hl	; F0AC00  cp BC,HL
	jr	nc, SoftKeyCol3_SoundEditDrumMenu_Skip2	; F0AC02  jr NC,0xf0ac3f
	incm8	1, (xiz-4)	; F0AC04  inc 1,(XIZ+0xfc)
	jr	SoftKeyCol3_SoundEditDrumMenu_Join	; F0AC07  jr T,0xf0ac12
SoftKeyCol3_SoundEditDrumMenu_Skip:
	cp	(xiz-4), 0x00	; F0AC09  cp (XIZ+0xfc),0x00
	jr	z, SoftKeyCol3_SoundEditDrumMenu_Skip2	; F0AC0D  jr Z,0xf0ac3f
	decm8	1, (xiz-4)	; F0AC0F  dec 1,(XIZ+0xfc)
SoftKeyCol3_SoundEditDrumMenu_Join:
	lda	xbc, (xiz-8)	; F0AC12  lda XBC,XIZ+0xf8
	push	xbc	; F0AC15  push XBC
	ld	wa, (xiz-4)	; F0AC16  ld WA,(XIZ+0xfc)
	extz	wa	; F0AC19  extz WA
	pushw	wa	; F0AC1B  push WA
	pushw	2	; F0AC1C  push 0x0002
	call	ModelingPage_GroupStartIndex	; F0AC1F  call 0xfda002
	pushw	(xiz-8)	; F0AC23  pushw (XIZ+0xf8)
	call	ToneMsg88_Id14	; F0AC26  call 0xfd66a6
	pushw	1	; F0AC2A  push 0x0001
	pushw	203	; F0AC2D  push 0x00cb
	call	PanelScreen_PostRequest	; F0AC30  call 0xfd608b
	pushw	1	; F0AC34  push 0x0001
	call	UiRequestBits_SetBit3	; F0AC37  call 0xfda467
	inc	8, xsp	; F0AC3B  inc 0,XSP
	inc	8, xsp	; F0AC3D  inc 0,XSP
SoftKeyCol3_SoundEditDrumMenu_Skip2:
	popw	hl	; F0AC3F  pop HL
	unlk XIZ	; F0AC40  unlk XIZ
	ret	; F0AC42  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDrumMenu
; Called from: table 0xFCF80C[291]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFDA0F6 0xFDA114 0xFD66A6 0xFD608B 0xFDA467
; Evidence: word [291] of the pointer table at 0xFCF80C reads 0x00F0AC43, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AC43 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDrumMenu: SOFT KEY column 4 (lower or upper; the flag carries which) on ScreenCodeCB -- ScreenCodeCB op 3 (PanelOpTable_FCFC8C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol4_SoundEditDrumMenu:
	link XIZ,0xfffa	; F0AC43  link XIZ,0xfffa
	lda	xbc, (xiz-2)	; F0AC47  lda XBC,XIZ+0xfe
	push	xbc	; F0AC4A  push XBC
	call	Var27F5_Get	; F0AC4B  call 0xfda0ca
	pop	xiy	; F0AC4F  pop XIY
	cp	(xiz-2), 0x00	; F0AC50  cp (XIZ+0xfe),0x00
	jr	z, SoftKeyCol4_SoundEditDrumMenu_Skip2	; F0AC54  jr Z,0xf0acae
	ld	c, (xiz+8)	; F0AC56  ld C,(XIZ+0x08)
	res	7, c	; F0AC59  res 0x07,C
	cp	c, 0:i3	; F0AC5C  cp C,0
	jr	nz, SoftKeyCol4_SoundEditDrumMenu_Skip	; F0AC5E  jr NZ,0xf0ac81
	lda	xbc, (xiz-4)	; F0AC60  lda XBC,XIZ+0xfc
	push	xbc	; F0AC63  push XBC
	call	Var27F7_GetW	; F0AC64  call 0xfda0f6
	lda	xbc, (xiz-6)	; F0AC68  lda XBC,XIZ+0xfa
	push	xbc	; F0AC6B  push XBC
	call	Var27F9_GetW	; F0AC6C  call 0xfda114
	ld	bc, (xiz-6)	; F0AC70  ld BC,(XIZ+0xfa)
	dec	1, bc	; F0AC73  dec 1,BC
	inc	8, xsp	; F0AC75  inc 0,XSP
	cp	(xiz-4), bc	; F0AC77  cp (XIZ+0xfc),BC
	jr	nc, SoftKeyCol4_SoundEditDrumMenu_Skip2	; F0AC7A  jr NC,0xf0acae
	incw	1, (xiz-4)	; F0AC7C  incw 1,(XIZ+0xfc)
	jr	SoftKeyCol4_SoundEditDrumMenu_Join	; F0AC7F  jr T,0xf0ac94
SoftKeyCol4_SoundEditDrumMenu_Skip:
	lda	xbc, (xiz-4)	; F0AC81  lda XBC,XIZ+0xfc
	push	xbc	; F0AC84  push XBC
	call	Var27F7_GetW	; F0AC85  call 0xfda0f6
	pop	xiy	; F0AC89  pop XIY
	cpw	(xiz-4), 0x0000	; F0AC8A  cp (XIZ+0xfc),0x0000
	jr	z, SoftKeyCol4_SoundEditDrumMenu_Skip2	; F0AC8F  jr Z,0xf0acae
	decm	1, (xiz-4)	; F0AC91  decw 1,(XIZ+0xfc)
SoftKeyCol4_SoundEditDrumMenu_Join:
	pushw	(xiz-4)	; F0AC94  pushw (XIZ+0xfc)
	call	ToneMsg88_Id14	; F0AC97  call 0xfd66a6
	pushw	1	; F0AC9B  push 0x0001
	pushw	203	; F0AC9E  push 0x00cb
	call	PanelScreen_PostRequest	; F0ACA1  call 0xfd608b
	pushw	1	; F0ACA5  push 0x0001
	call	UiRequestBits_SetBit3	; F0ACA8  call 0xfda467
	inc	8, xsp	; F0ACAC  inc 0,XSP
SoftKeyCol4_SoundEditDrumMenu_Skip2:
	unlk XIZ	; F0ACAE  unlk XIZ
	ret	; F0ACB0  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditDrumMenu
; Called from: table 0xFCF80C[296]
; Touches: nothing with an absolute address
; Calls:   0xFD608B
; Evidence: word [296] of the pointer table at 0xFCF80C reads 0x00F0ACB1, that
;           table's reader TRANSFERS to the word it loads, and 0xF0ACB1 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditDrumMenu: LCD key row 1 (left or right) on ScreenCodeCB -- ScreenCodeCB op 8 (PanelOpTable_FCFC8C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow1_SoundEditDrumMenu:
	link XIZ,0x0000	; F0ACB1  link XIZ,0x0000
	pushw	0	; F0ACB5  push 0x0000
	cp	(xiz+8), 0x00	; F0ACB8  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow1_SoundEditDrumMenu_Skip	; F0ACBC  jr Z,0xf0acc3
	pushw	158	; F0ACBE  push 0x009e
	jr	LcdKeyRow1_SoundEditDrumMenu_Join	; F0ACC1  jr T,0xf0acc6
LcdKeyRow1_SoundEditDrumMenu_Skip:
	pushw	157	; F0ACC3  push 0x009d
LcdKeyRow1_SoundEditDrumMenu_Join:
	call	PanelScreen_PostRequest	; F0ACC6  call 0xfd608b
	pop	xbc	; F0ACCA  pop XBC
	unlk XIZ	; F0ACCB  unlk XIZ
	ret	; F0ACCD  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditDrumMenu
; Called from: table 0xFCF80C[297]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD608B
; Evidence: word [297] of the pointer table at 0xFCF80C reads 0x00F0ACCE, that
;           table's reader TRANSFERS to the word it loads, and 0xF0ACCE is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditDrumMenu: LCD key row 2 (left or right) on ScreenCodeCB -- ScreenCodeCB op 9 (PanelOpTable_FCFC8C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow2_SoundEditDrumMenu:
	link XIZ,0xfffe	; F0ACCE  link XIZ,0xfffe
	cp	(xiz+8), 0x00	; F0ACD2  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow2_SoundEditDrumMenu_Skip	; F0ACD6  jr Z,0xf0ace0
	pushw	0	; F0ACD8  push 0x0000
	pushw	192	; F0ACDB  push 0x00c0
	jr	LcdKeyRow2_SoundEditDrumMenu_Join	; F0ACDE  jr T,0xf0acfa
LcdKeyRow2_SoundEditDrumMenu_Skip:
	lda	xbc, (xiz-2)	; F0ACE0  lda XBC,XIZ+0xfe
	push	xbc	; F0ACE3  push XBC
	call	Var27F5_Get	; F0ACE4  call 0xfda0ca
	pop	xiy	; F0ACE8  pop XIY
	pushw	0	; F0ACE9  push 0x0000
	cp	(xiz-2), 0x00	; F0ACEC  cp (XIZ+0xfe),0x00
	jr	nz, LcdKeyRow2_SoundEditDrumMenu_Skip2	; F0ACF0  jr NZ,0xf0acf7
	pushw	132	; F0ACF2  push 0x0084
	jr	LcdKeyRow2_SoundEditDrumMenu_Join	; F0ACF5  jr T,0xf0acfa
LcdKeyRow2_SoundEditDrumMenu_Skip2:
	pushw	200	; F0ACF7  push 0x00c8
LcdKeyRow2_SoundEditDrumMenu_Join:
	call	PanelScreen_PostRequest	; F0ACFA  call 0xfd608b
	pop	xbc	; F0ACFE  pop XBC
	unlk XIZ	; F0ACFF  unlk XIZ
	ret	; F0AD01  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditDrumMenu
; Called from: table 0xFCF80C[298]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD608B
; Evidence: word [298] of the pointer table at 0xFCF80C reads 0x00F0AD02, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AD02 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditDrumMenu: LCD key row 3 (left or right) on ScreenCodeCB -- ScreenCodeCB op 10 (PanelOpTable_FCFC8C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow3_SoundEditDrumMenu:
	link XIZ,0xfffe	; F0AD02  link XIZ,0xfffe
	lda	xbc, (xiz-2)	; F0AD06  lda XBC,XIZ+0xfe
	push	xbc	; F0AD09  push XBC
	call	Var27F5_Get	; F0AD0A  call 0xfda0ca
	pop	xiy	; F0AD0E  pop XIY
	cp	(xiz+8), 0x00	; F0AD0F  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow3_SoundEditDrumMenu_Skip2	; F0AD13  jr NZ,0xf0ad28
	pushw	0	; F0AD15  push 0x0000
	cp	(xiz-2), 0x00	; F0AD18  cp (XIZ+0xfe),0x00
	jr	nz, LcdKeyRow3_SoundEditDrumMenu_Skip	; F0AD1C  jr NZ,0xf0ad23
	pushw	156	; F0AD1E  push 0x009c
	jr	LcdKeyRow3_SoundEditDrumMenu_Join	; F0AD21  jr T,0xf0ad2e
LcdKeyRow3_SoundEditDrumMenu_Skip:
	pushw	202	; F0AD23  push 0x00ca
	jr	LcdKeyRow3_SoundEditDrumMenu_Join	; F0AD26  jr T,0xf0ad2e
LcdKeyRow3_SoundEditDrumMenu_Skip2:
	pushw	0	; F0AD28  push 0x0000
	pushw	139	; F0AD2B  push 0x008b
LcdKeyRow3_SoundEditDrumMenu_Join:
	call	PanelScreen_PostRequest	; F0AD2E  call 0xfd608b
	pop	xbc	; F0AD32  pop XBC
	unlk XIZ	; F0AD33  unlk XIZ
	ret	; F0AD35  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditDrumMenu
; Called from: table 0xFCF80C[299]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD608B
; Evidence: word [299] of the pointer table at 0xFCF80C reads 0x00F0AD36, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AD36 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditDrumMenu: LCD key row 4 (left or right) on ScreenCodeCB -- ScreenCodeCB op 11 (PanelOpTable_FCFC8C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow4_SoundEditDrumMenu:
	link XIZ,0xfffe	; F0AD36  link XIZ,0xfffe
	lda	xbc, (xiz-2)	; F0AD3A  lda XBC,XIZ+0xfe
	push	xbc	; F0AD3D  push XBC
	call	Var27F5_Get	; F0AD3E  call 0xfda0ca
	pop	xiy	; F0AD42  pop XIY
	cp	(xiz-2), 0x00	; F0AD43  cp (XIZ+0xfe),0x00
	jr	nz, LcdKeyRow4_SoundEditDrumMenu_Skip2	; F0AD47  jr NZ,0xf0ad5c
	pushw	0	; F0AD49  push 0x0000
	cp	(xiz+8), 0x00	; F0AD4C  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow4_SoundEditDrumMenu_Skip	; F0AD50  jr NZ,0xf0ad57
	pushw	202	; F0AD52  push 0x00ca
	jr	LcdKeyRow4_SoundEditDrumMenu_Join	; F0AD55  jr T,0xf0ad6d
LcdKeyRow4_SoundEditDrumMenu_Skip:
	pushw	135	; F0AD57  push 0x0087
	jr	LcdKeyRow4_SoundEditDrumMenu_Join	; F0AD5A  jr T,0xf0ad6d
LcdKeyRow4_SoundEditDrumMenu_Skip2:
	pushw	0	; F0AD5C  push 0x0000
	cp	(xiz+8), 0x00	; F0AD5F  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow4_SoundEditDrumMenu_Skip3	; F0AD63  jr NZ,0xf0ad6a
	pushw	205	; F0AD65  push 0x00cd
	jr	LcdKeyRow4_SoundEditDrumMenu_Join	; F0AD68  jr T,0xf0ad6d
LcdKeyRow4_SoundEditDrumMenu_Skip3:
	pushw	144	; F0AD6A  push 0x0090
LcdKeyRow4_SoundEditDrumMenu_Join:
	call	PanelScreen_PostRequest	; F0AD6D  call 0xfd608b
	pop	xbc	; F0AD71  pop XBC
	unlk XIZ	; F0AD72  unlk XIZ
	ret	; F0AD74  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditDrumMenu
; Called from: table 0xFCF80C[300]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD608B 0xFDA0AC
; Evidence: word [300] of the pointer table at 0xFCF80C reads 0x00F0AD75, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AD75 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditDrumMenu: LCD key row 5 (left or right) on ScreenCodeCB -- ScreenCodeCB op 12 (PanelOpTable_FCFC8C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow5_SoundEditDrumMenu:
	link XIZ,0xfffe	; F0AD75  link XIZ,0xfffe
	lda	xbc, (xiz-2)	; F0AD79  lda XBC,XIZ+0xfe
	push	xbc	; F0AD7C  push XBC
	call	Var27F5_Get	; F0AD7D  call 0xfda0ca
	pop	xiy	; F0AD81  pop XIY
	cp	(xiz+8), 0x00	; F0AD82  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow5_SoundEditDrumMenu_Skip2	; F0AD86  jr NZ,0xf0ada8
	pushw	0	; F0AD88  push 0x0000
	cp	(xiz-2), 0x00	; F0AD8B  cp (XIZ+0xfe),0x00
	jr	nz, LcdKeyRow5_SoundEditDrumMenu_Skip	; F0AD8F  jr NZ,0xf0ad96
	pushw	205	; F0AD91  push 0x00cd
	jr	LcdKeyRow5_SoundEditDrumMenu_Join	; F0AD94  jr T,0xf0adb4
LcdKeyRow5_SoundEditDrumMenu_Skip:
	pushw	159	; F0AD96  push 0x009f
	call	PanelScreen_PostRequest	; F0AD99  call 0xfd608b
	pushw	2	; F0AD9D  push 0x0002
	call	Var27F6_Set	; F0ADA0  call 0xfda0ac
	inc	6, xsp	; F0ADA4  inc 6,XSP
	jr	LcdKeyRow5_SoundEditDrumMenu_Join2	; F0ADA6  jr T,0xf0adb9
LcdKeyRow5_SoundEditDrumMenu_Skip2:
	cp	(xiz-2), 0x00	; F0ADA8  cp (XIZ+0xfe),0x00
	jr	nz, LcdKeyRow5_SoundEditDrumMenu_Join2	; F0ADAC  jr NZ,0xf0adb9
	pushw	0	; F0ADAE  push 0x0000
	pushw	144	; F0ADB1  push 0x0090
LcdKeyRow5_SoundEditDrumMenu_Join:
	call	PanelScreen_PostRequest	; F0ADB4  call 0xfd608b
	pop	xiy	; F0ADB8  pop XIY
LcdKeyRow5_SoundEditDrumMenu_Join2:
	unlk XIZ	; F0ADB9  unlk XIZ
	ret	; F0ADBB  ret

; --------------------------------------------------------------------------
; ExitKey_SoundEditDrumMenu
; Called from: table 0xFCF80C[303]
; Touches: nothing with an absolute address
; Calls:   0xFD608B
; Evidence: word [303] of the pointer table at 0xFCF80C reads 0x00F0ADBC, that
;           table's reader TRANSFERS to the word it loads, and 0xF0ADBC is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SoundEditDrumMenu: the EXIT key on ScreenCodeCB -- ScreenCodeCB op 15 (PanelOpTable_FCFC8C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
ExitKey_SoundEditDrumMenu:
	link XIZ,0x0000	; F0ADBC  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0ADC0  cp (XIZ+0x08),0x00
	jr	nz, ExitKey_SoundEditDrumMenu_Skip	; F0ADC4  jr NZ,0xf0add1
	pushw	0	; F0ADC6  push 0x0000
	pushw	128	; F0ADC9  push 0x0080
	call	PanelScreen_PostRequest	; F0ADCC  call 0xfd608b
	pop	xiy	; F0ADD0  pop XIY
ExitKey_SoundEditDrumMenu_Skip:
	unlk XIZ	; F0ADD1  unlk XIZ
	ret	; F0ADD3  ret

; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect
; Called from: table 0xFCF80C[252]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7C2D
; Evidence: word [252] of the pointer table at 0xFCF80C reads 0x00F0ADD4, that
;           table's reader TRANSFERS to the word it loads, and 0xF0ADD4 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect: SOFT KEY column 1 (lower or upper; the flag carries which) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 0 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol1_SoundEditDigitalEffect:
	link XIZ,0xfff2	; F0ADD4  link XIZ,0xfff2
	push	xix	; F0ADD8  push XIX
	lda	xix, (xiz-14)	; F0ADD9  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0ADDC  lda XBC,XIZ+0xfe
	push	xbc	; F0ADDF  push XBC
	pushw	0	; F0ADE0  push 0x0000
	call	Arr27A6_Get	; F0ADE3  call 0xfd6c7b
	and	(xiz-2), 0x0f	; F0ADE7  and (XIZ+0xfe),0x0f
	push	xix	; F0ADEB  push XIX
	pushw	1	; F0ADEC  push 0x0001
	call	Arr27A6_Get	; F0ADEF  call 0xfd6c7b
	ld	(xix+6), 255	; F0ADF3  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0ADF7  ld (XIX+0x07),0x00
	ld	xbc, xix	; F0ADFB  ld XBC,XIX
	add	xbc, 10	; F0ADFD  add XBC,0x0000000a
	push	xbc	; F0AE03  push XBC
	ld	bc, (xiz+8)	; F0AE04  ld BC,(XIZ+0x08)
	extz	bc	; F0AE07  extz BC
	pushw	bc	; F0AE09  push BC
	call	ToneEdit_StepFromEvent	; F0AE0A  call 0xfd7c2d
	ld	bc, (xiz-2)	; F0AE0E  ld BC,(XIZ+0xfe)
	extz	bc	; F0AE11  extz BC
	add	xsp, 18	; F0AE13  add XSP,0x00000012
	extz	xbc	; F0AE19  extz XBC
	cp	bc, 11	; F0AE1B  cp BC,0x000b
	jrl	ugt, SoftKeyCol1_SoundEditDigitalEffect_Range0To1_Skip	; F0AE1F  jrl UGT,0xf0ae97
	sll	bc, 2	; F0AE22  sll 0x02,BC
	add	xbc, SoftKeyCol1_SoundEditDigitalEffect_RangeByType	; F0AE25  add XBC,0x00f0ae2f
	ld	xbc, (xbc)	; F0AE2B  ld XBC,(XBC)
	jp	(xbc)	; F0AE2D  jp T,XBC

; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect_RangeByType -- 12 32-bit entries, all inside this block
;                    (0xF0AE5F-0xF0AE6B), naming 3 distinct targets.  A jump
;                    table, not a call table: the reader ends `ld XBC,(XBC) /
;                    jp (XBC)`.
; Read by: prom_b 0xF0AE25, `add XBC,0x00F0AE2F / ld XBC,(XBC) / jp (XBC)`,
;          with the index bounded by the `cp BC,0x000B / jrl UGT` immediately
;          above it.
; Evidence: every word is re-read on every emit and asserted to land inside
;           0xF067A6-0xF0C735, and the entry count 12 is the extent divided by
;           four -- the extent itself coming from the code segment that starts
;           at 0xF0AE5F.
; Unknown: what the index enumerates.  FRAMED name kept.
; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect_RangeByType: SoftKeyCol1_SoundEditDigitalEffect's switch on the DIGITAL EFFECT type (Arr27A6[0] & 0x0F), 12 entries; each arm
;   sets the edit descriptor's MIN / MAX for that type (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol1_SoundEditDigitalEffect_RangeByType:
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To50	; F0AE2F  [0] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To50	; F0AE33  [1] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To50	; F0AE37  [2] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To50	; F0AE3B  [3] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To50	; F0AE3F  [4] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To50	; F0AE43  [5] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To50	; F0AE47  [6] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To50	; F0AE4B  [7] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To50	; F0AE4F  [8] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To30	; F0AE53  [9] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To30
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To1	; F0AE57  [10] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To1
	.long	SoftKeyCol1_SoundEditDigitalEffect_Range0To1	; F0AE5B  [11] -> SoftKeyCol1_SoundEditDigitalEffect_Range0To1


; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect_Range0To50
; Called from: table 0xF0AE2F[0], 0xF0AE2F[1], 0xF0AE2F[2], 0xF0AE2F[3],
;              0xF0AE2F[4], 0xF0AE2F[5] +3 more
; Touches: nothing with an absolute address
; Evidence: word [0] of the pointer table at 0xF0AE2F reads 0x00F0AE5F, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AE5F is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect_Range0To50: an arm of SoftKeyCol1_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 50 for type(s) 0,1,2,3,4,5,6,7,8
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol1_SoundEditDigitalEffect_Range0To50:
	ld	(xix+8), 50	; F0AE5F  ld (XIX+0x08),0x32
	jr	SoftKeyCol1_SoundEditDigitalEffect_Range0To1_Join	; F0AE63  jr T,0xf0ae6f

; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect_Range0To30
; Called from: table 0xF0AE2F[9]
; Touches: nothing with an absolute address
; Evidence: word [9] of the pointer table at 0xF0AE2F reads 0x00F0AE65, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AE65 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect_Range0To30: an arm of SoftKeyCol1_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 30 for type(s) 9
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol1_SoundEditDigitalEffect_Range0To30:
	ld	(xix+8), 30	; F0AE65  ld (XIX+0x08),0x1e
	jr	SoftKeyCol1_SoundEditDigitalEffect_Range0To1_Join	; F0AE69  jr T,0xf0ae6f

; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect_Range0To1
; Called from: table 0xF0AE2F[10], 0xF0AE2F[11]
; Touches: nothing with an absolute address
; Calls:   0xFD7435 0xFD7C01
; Evidence: word [10] of the pointer table at 0xF0AE2F reads 0x00F0AE6B, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AE6B is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditDigitalEffect_Range0To1: an arm of SoftKeyCol1_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 1 for type(s) 10,11
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol1_SoundEditDigitalEffect_Range0To1:
	ld	(xix+8), 1	; F0AE6B  ld (XIX+0x08),0x01
SoftKeyCol1_SoundEditDigitalEffect_Range0To1_Join:
	ld	(xix+9), 0	; F0AE6F  ld (XIX+0x09),0x00
	push	xix	; F0AE73  push XIX
	sub	xbc, xbc	; F0AE74  sub XBC,XBC
	add	xbc, 209	; F0AE76  add XBC,0x000000d1
	extz	bc	; F0AE7C  extz BC
	pushw	bc	; F0AE7E  push BC
	pushw	0	; F0AE7F  push 0x0000
	pushw	1	; F0AE82  push 0x0001
	pushw	154	; F0AE85  push 0x009a
	call	ToneEdit_CommitField	; F0AE88  call 0xfd7435
	pushw	1	; F0AE8C  push 0x0001
	call	PanelDial_ActAsButton	; F0AE8F  call 0xfd7c01
	inc	8, xsp	; F0AE93  inc 0,XSP
	inc	6, xsp	; F0AE95  inc 6,XSP
SoftKeyCol1_SoundEditDigitalEffect_Range0To1_Skip:
	pop	xix	; F0AE97  pop XIX
	unlk XIZ	; F0AE98  unlk XIZ
	ret	; F0AE9A  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect
; Called from: table 0xFCF80C[253]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7C2D
; Evidence: word [253] of the pointer table at 0xFCF80C reads 0x00F0AE9B, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AE9B is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect: SOFT KEY column 2 (lower or upper; the flag carries which) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 1 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol2_SoundEditDigitalEffect:
	link XIZ,0xfff2	; F0AE9B  link XIZ,0xfff2
	push	xix	; F0AE9F  push XIX
	lda	xix, (xiz-14)	; F0AEA0  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0AEA3  lda XBC,XIZ+0xfe
	push	xbc	; F0AEA6  push XBC
	pushw	0	; F0AEA7  push 0x0000
	call	Arr27A6_Get	; F0AEAA  call 0xfd6c7b
	and	(xiz-2), 0x0f	; F0AEAE  and (XIZ+0xfe),0x0f
	push	xix	; F0AEB2  push XIX
	pushw	2	; F0AEB3  push 0x0002
	call	Arr27A6_Get	; F0AEB6  call 0xfd6c7b
	ld	(xix+6), 255	; F0AEBA  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0AEBE  ld (XIX+0x07),0x00
	ld	xbc, xix	; F0AEC2  ld XBC,XIX
	add	xbc, 10	; F0AEC4  add XBC,0x0000000a
	push	xbc	; F0AECA  push XBC
	ld	bc, (xiz+8)	; F0AECB  ld BC,(XIZ+0x08)
	extz	bc	; F0AECE  extz BC
	pushw	bc	; F0AED0  push BC
	call	ToneEdit_StepFromEvent	; F0AED1  call 0xfd7c2d
	ld	bc, (xiz-2)	; F0AED5  ld BC,(XIZ+0xfe)
	extz	bc	; F0AED8  extz BC
	add	xsp, 18	; F0AEDA  add XSP,0x00000012
	extz	xbc	; F0AEE0  extz XBC
	cp	bc, 11	; F0AEE2  cp BC,0x000b
	jrl	ugt, SoftKeyCol2_SoundEditDigitalEffect_Range0To30_Skip2	; F0AEE6  jrl UGT,0xf0af62
	sll	bc, 2	; F0AEE9  sll 0x02,BC
	add	xbc, SoftKeyCol2_SoundEditDigitalEffect_RangeByType	; F0AEEC  add XBC,0x00f0aef6
	ld	xbc, (xbc)	; F0AEF2  ld XBC,(XBC)
	jp	(xbc)	; F0AEF4  jp T,XBC

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect_RangeByType -- 12 32-bit entries, all inside this block
;                    (0xF0AF26-0xF0AF36), naming 3 distinct targets.  A jump
;                    table, not a call table: the reader ends `ld XBC,(XBC) /
;                    jp (XBC)`.
; Read by: prom_b 0xF0AEEC, `add XBC,0x00F0AEF6 / ld XBC,(XBC) / jp (XBC)`,
;          with the index bounded by the `cp BC,0x000B / jrl UGT` immediately
;          above it.
; Evidence: every word is re-read on every emit and asserted to land inside
;           0xF067A6-0xF0C735, and the entry count 12 is the extent divided by
;           four -- the extent itself coming from the code segment that starts
;           at 0xF0AF26.
; Unknown: what the index enumerates.  FRAMED name kept.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect_RangeByType: SoftKeyCol2_SoundEditDigitalEffect's switch on the DIGITAL EFFECT type (Arr27A6[0] & 0x0F), 12 entries; each arm
;   sets the edit descriptor's MIN / MAX for that type (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol2_SoundEditDigitalEffect_RangeByType:
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AEF6  [0] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AEFA  [1] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AEFE  [2] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AF02  [3] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AF06  [4] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AF0A  [5] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AF0E  [6] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AF12  [7] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_RangeM50To50	; F0AF16  [8] -> SoftKeyCol2_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To30	; F0AF1A  [9] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To30
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AF1E  [10] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol2_SoundEditDigitalEffect_Range0To50	; F0AF22  [11] -> SoftKeyCol2_SoundEditDigitalEffect_Range0To50


; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect_Range0To50
; Called from: table 0xF0AEF6[0], 0xF0AEF6[1], 0xF0AEF6[2], 0xF0AEF6[3],
;              0xF0AEF6[4], 0xF0AEF6[5] +4 more
; Touches: nothing with an absolute address
; Evidence: word [0] of the pointer table at 0xF0AEF6 reads 0x00F0AF26, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AF26 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect_Range0To50: an arm of SoftKeyCol2_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 50 for type(s) 0,1,2,3,4,5,6,7,10,11
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol2_SoundEditDigitalEffect_Range0To50:
	ld	(xix+8), 50	; F0AF26  ld (XIX+0x08),0x32
	jr	SoftKeyCol2_SoundEditDigitalEffect_Range0To30_Skip	; F0AF2A  jr T,0xf0af3a

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect_RangeM50To50
; Called from: table 0xF0AEF6[8]
; Touches: nothing with an absolute address
; Evidence: word [8] of the pointer table at 0xF0AEF6 reads 0x00F0AF2C, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AF2C is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect_RangeM50To50: an arm of SoftKeyCol2_SoundEditDigitalEffect_RangeByType -- MIN -50, MAX 50 for type(s) 8
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol2_SoundEditDigitalEffect_RangeM50To50:
	ld	(xix+8), 50	; F0AF2C  ld (XIX+0x08),0x32
	ld	(xix+9), 206	; F0AF30  ld (XIX+0x09),0xce
	jr	SoftKeyCol2_SoundEditDigitalEffect_Range0To30_Join	; F0AF34  jr T,0xf0af3e

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect_Range0To30
; Called from: table 0xF0AEF6[9]
; Touches: nothing with an absolute address
; Calls:   0xFD7435 0xFD7C01
; Evidence: word [9] of the pointer table at 0xF0AEF6 reads 0x00F0AF36, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AF36 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditDigitalEffect_Range0To30: an arm of SoftKeyCol2_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 30 for type(s) 9
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol2_SoundEditDigitalEffect_Range0To30:
	ld	(xix+8), 30	; F0AF36  ld (XIX+0x08),0x1e
SoftKeyCol2_SoundEditDigitalEffect_Range0To30_Skip:
	ld	(xix+9), 0	; F0AF3A  ld (XIX+0x09),0x00
SoftKeyCol2_SoundEditDigitalEffect_Range0To30_Join:
	push	xix	; F0AF3E  push XIX
	sub	xbc, xbc	; F0AF3F  sub XBC,XBC
	add	xbc, 210	; F0AF41  add XBC,0x000000d2
	extz	bc	; F0AF47  extz BC
	pushw	bc	; F0AF49  push BC
	pushw	0	; F0AF4A  push 0x0000
	pushw	2	; F0AF4D  push 0x0002
	pushw	154	; F0AF50  push 0x009a
	call	ToneEdit_CommitField	; F0AF53  call 0xfd7435
	pushw	2	; F0AF57  push 0x0002
	call	PanelDial_ActAsButton	; F0AF5A  call 0xfd7c01
	inc	8, xsp	; F0AF5E  inc 0,XSP
	inc	6, xsp	; F0AF60  inc 6,XSP
SoftKeyCol2_SoundEditDigitalEffect_Range0To30_Skip2:
	pop	xix	; F0AF62  pop XIX
	unlk XIZ	; F0AF63  unlk XIZ
	ret	; F0AF65  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect
; Called from: table 0xFCF80C[254]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7C2D
; Evidence: word [254] of the pointer table at 0xFCF80C reads 0x00F0AF66, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AF66 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect: SOFT KEY column 3 (lower or upper; the flag carries which) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 2 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol3_SoundEditDigitalEffect:
	link XIZ,0xfff2	; F0AF66  link XIZ,0xfff2
	push	xix	; F0AF6A  push XIX
	lda	xix, (xiz-14)	; F0AF6B  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0AF6E  lda XBC,XIZ+0xfe
	push	xbc	; F0AF71  push XBC
	pushw	0	; F0AF72  push 0x0000
	call	Arr27A6_Get	; F0AF75  call 0xfd6c7b
	and	(xiz-2), 0x0f	; F0AF79  and (XIZ+0xfe),0x0f
	push	xix	; F0AF7D  push XIX
	pushw	3	; F0AF7E  push 0x0003
	call	Arr27A6_Get	; F0AF81  call 0xfd6c7b
	ld	(xix+6), 255	; F0AF85  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0AF89  ld (XIX+0x07),0x00
	ld	xbc, xix	; F0AF8D  ld XBC,XIX
	add	xbc, 10	; F0AF8F  add XBC,0x0000000a
	push	xbc	; F0AF95  push XBC
	ld	bc, (xiz+8)	; F0AF96  ld BC,(XIZ+0x08)
	extz	bc	; F0AF99  extz BC
	pushw	bc	; F0AF9B  push BC
	call	ToneEdit_StepFromEvent	; F0AF9C  call 0xfd7c2d
	ld	bc, (xiz-2)	; F0AFA0  ld BC,(XIZ+0xfe)
	extz	bc	; F0AFA3  extz BC
	add	xsp, 18	; F0AFA5  add XSP,0x00000012
	extz	xbc	; F0AFAB  extz XBC
	cp	bc, 11	; F0AFAD  cp BC,0x000b
	jrl	ugt, SoftKeyCol3_SoundEditDigitalEffect_Range0To30_Skip	; F0AFB1  jrl UGT,0xf0b03d
	sll	bc, 2	; F0AFB4  sll 0x02,BC
	add	xbc, SoftKeyCol3_SoundEditDigitalEffect_RangeByType	; F0AFB7  add XBC,0x00f0afc1
	ld	xbc, (xbc)	; F0AFBD  ld XBC,(XBC)
	jp	(xbc)	; F0AFBF  jp T,XBC

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_RangeByType -- 12 32-bit entries, all inside this block
;                    (0xF0AFF1-0xF0B011), naming 5 distinct targets.  A jump
;                    table, not a call table: the reader ends `ld XBC,(XBC) /
;                    jp (XBC)`.
; Read by: prom_b 0xF0AFB7, `add XBC,0x00F0AFC1 / ld XBC,(XBC) / jp (XBC)`,
;          with the index bounded by the `cp BC,0x000B / jrl UGT` immediately
;          above it.
; Evidence: every word is re-read on every emit and asserted to land inside
;           0xF067A6-0xF0C735, and the entry count 12 is the extent divided by
;           four -- the extent itself coming from the code segment that starts
;           at 0xF0AFF1.
; Unknown: what the index enumerates.  FRAMED name kept.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_RangeByType: SoftKeyCol3_SoundEditDigitalEffect's switch on the DIGITAL EFFECT type (Arr27A6[0] & 0x0F), 12 entries; each arm
;   sets the edit descriptor's MIN / MAX for that type (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol3_SoundEditDigitalEffect_RangeByType:
	.long	SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50	; F0AFC1  [0] -> SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50	; F0AFC5  [1] -> SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50	; F0AFC9  [2] -> SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50	; F0AFCD  [3] -> SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol3_SoundEditDigitalEffect_Range0To50	; F0AFD1  [4] -> SoftKeyCol3_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol3_SoundEditDigitalEffect_Range0To50	; F0AFD5  [5] -> SoftKeyCol3_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol3_SoundEditDigitalEffect_Range0To3	; F0AFD9  [6] -> SoftKeyCol3_SoundEditDigitalEffect_Range0To3
	.long	SoftKeyCol3_SoundEditDigitalEffect_Range0To50	; F0AFDD  [7] -> SoftKeyCol3_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol3_SoundEditDigitalEffect_RangeM24To24	; F0AFE1  [8] -> SoftKeyCol3_SoundEditDigitalEffect_RangeM24To24
	.long	SoftKeyCol3_SoundEditDigitalEffect_Range0To30	; F0AFE5  [9] -> SoftKeyCol3_SoundEditDigitalEffect_Range0To30
	.long	SoftKeyCol3_SoundEditDigitalEffect_Range0To50	; F0AFE9  [10] -> SoftKeyCol3_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol3_SoundEditDigitalEffect_Range0To50	; F0AFED  [11] -> SoftKeyCol3_SoundEditDigitalEffect_Range0To50


; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50
; Called from: table 0xF0AFC1[0], 0xF0AFC1[1], 0xF0AFC1[2], 0xF0AFC1[3]
; Touches: nothing with an absolute address
; Evidence: word [0] of the pointer table at 0xF0AFC1 reads 0x00F0AFF1, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AFF1 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50: an arm of SoftKeyCol3_SoundEditDigitalEffect_RangeByType -- MIN -50, MAX 50 for type(s) 0,1,2,3
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol3_SoundEditDigitalEffect_RangeM50To50:
	ld	(xix+8), 50	; F0AFF1  ld (XIX+0x08),0x32
	ld	(xix+9), 206	; F0AFF5  ld (XIX+0x09),0xce
	jr	SoftKeyCol3_SoundEditDigitalEffect_Range0To30_Join2	; F0AFF9  jr T,0xf0b019

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_Range0To50
; Called from: table 0xF0AFC1[4], 0xF0AFC1[5], 0xF0AFC1[7], 0xF0AFC1[10],
;              0xF0AFC1[11]
; Touches: nothing with an absolute address
; Evidence: word [4] of the pointer table at 0xF0AFC1 reads 0x00F0AFFB, that
;           table's reader TRANSFERS to the word it loads, and 0xF0AFFB is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_Range0To50: an arm of SoftKeyCol3_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 50 for type(s) 4,5,7,10,11
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol3_SoundEditDigitalEffect_Range0To50:
	ld	(xix+8), 50	; F0AFFB  ld (XIX+0x08),0x32
	jr	SoftKeyCol3_SoundEditDigitalEffect_Range0To30_Join	; F0AFFF  jr T,0xf0b015

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_Range0To3
; Called from: table 0xF0AFC1[6]
; Touches: nothing with an absolute address
; Evidence: word [6] of the pointer table at 0xF0AFC1 reads 0x00F0B001, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B001 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_Range0To3: an arm of SoftKeyCol3_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 3 for type(s) 6
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol3_SoundEditDigitalEffect_Range0To3:
	ld	(xix+8), 3	; F0B001  ld (XIX+0x08),0x03
	jr	SoftKeyCol3_SoundEditDigitalEffect_Range0To30_Join	; F0B005  jr T,0xf0b015

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_RangeM24To24
; Called from: table 0xF0AFC1[8]
; Touches: nothing with an absolute address
; Evidence: word [8] of the pointer table at 0xF0AFC1 reads 0x00F0B007, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B007 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_RangeM24To24: an arm of SoftKeyCol3_SoundEditDigitalEffect_RangeByType -- MIN -24, MAX 24 for type(s) 8
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol3_SoundEditDigitalEffect_RangeM24To24:
	ld	(xix+8), 24	; F0B007  ld (XIX+0x08),0x18
	ld	(xix+9), 232	; F0B00B  ld (XIX+0x09),0xe8
	jr	SoftKeyCol3_SoundEditDigitalEffect_Range0To30_Join2	; F0B00F  jr T,0xf0b019

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_Range0To30
; Called from: table 0xF0AFC1[9]
; Touches: nothing with an absolute address
; Calls:   0xFD7435 0xFD7C01
; Evidence: word [9] of the pointer table at 0xF0AFC1 reads 0x00F0B011, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B011 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditDigitalEffect_Range0To30: an arm of SoftKeyCol3_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 30 for type(s) 9
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol3_SoundEditDigitalEffect_Range0To30:
	ld	(xix+8), 30	; F0B011  ld (XIX+0x08),0x1e
SoftKeyCol3_SoundEditDigitalEffect_Range0To30_Join:
	ld	(xix+9), 0	; F0B015  ld (XIX+0x09),0x00
SoftKeyCol3_SoundEditDigitalEffect_Range0To30_Join2:
	push	xix	; F0B019  push XIX
	sub	xbc, xbc	; F0B01A  sub XBC,XBC
	add	xbc, 211	; F0B01C  add XBC,0x000000d3
	extz	bc	; F0B022  extz BC
	pushw	bc	; F0B024  push BC
	pushw	0	; F0B025  push 0x0000
	pushw	3	; F0B028  push 0x0003
	pushw	154	; F0B02B  push 0x009a
	call	ToneEdit_CommitField	; F0B02E  call 0xfd7435
	pushw	3	; F0B032  push 0x0003
	call	PanelDial_ActAsButton	; F0B035  call 0xfd7c01
	inc	8, xsp	; F0B039  inc 0,XSP
	inc	6, xsp	; F0B03B  inc 6,XSP
SoftKeyCol3_SoundEditDigitalEffect_Range0To30_Skip:
	pop	xix	; F0B03D  pop XIX
	unlk XIZ	; F0B03E  unlk XIZ
	ret	; F0B040  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect
; Called from: table 0xFCF80C[255]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7C2D
; Evidence: word [255] of the pointer table at 0xFCF80C reads 0x00F0B041, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B041 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect: SOFT KEY column 4 (lower or upper; the flag carries which) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 3 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol4_SoundEditDigitalEffect:
	link XIZ,0xfff2	; F0B041  link XIZ,0xfff2
	push	xix	; F0B045  push XIX
	lda	xix, (xiz-14)	; F0B046  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0B049  lda XBC,XIZ+0xfe
	push	xbc	; F0B04C  push XBC
	pushw	0	; F0B04D  push 0x0000
	call	Arr27A6_Get	; F0B050  call 0xfd6c7b
	and	(xiz-2), 0x0f	; F0B054  and (XIZ+0xfe),0x0f
	push	xix	; F0B058  push XIX
	pushw	4	; F0B059  push 0x0004
	call	Arr27A6_Get	; F0B05C  call 0xfd6c7b
	ld	(xix+6), 255	; F0B060  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0B064  ld (XIX+0x07),0x00
	ld	xbc, xix	; F0B068  ld XBC,XIX
	add	xbc, 10	; F0B06A  add XBC,0x0000000a
	push	xbc	; F0B070  push XBC
	ld	bc, (xiz+8)	; F0B071  ld BC,(XIZ+0x08)
	extz	bc	; F0B074  extz BC
	pushw	bc	; F0B076  push BC
	call	ToneEdit_StepFromEvent	; F0B077  call 0xfd7c2d
	ld	bc, (xiz-2)	; F0B07B  ld BC,(XIZ+0xfe)
	extz	bc	; F0B07E  extz BC
	add	xsp, 18	; F0B080  add XSP,0x00000012
	extz	xbc	; F0B086  extz XBC
	cp	bc, 9	; F0B088  cp BC,0x0009
	jr	ugt, SoftKeyCol4_SoundEditDigitalEffect_Range0To30_Skip	; F0B08C  jr UGT,0xf0b0fb
	sll	bc, 2	; F0B08E  sll 0x02,BC
	add	xbc, SoftKeyCol4_SoundEditDigitalEffect_RangeByType	; F0B091  add XBC,0x00f0b09b
	ld	xbc, (xbc)	; F0B097  ld XBC,(XBC)
	jp	(xbc)	; F0B099  jp T,XBC

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect_RangeByType -- 10 32-bit entries, all inside this block
;                    (0xF0B0C3-0xF0B0CF), naming 3 distinct targets.  A jump
;                    table, not a call table: the reader ends `ld XBC,(XBC) /
;                    jp (XBC)`.
; Read by: prom_b 0xF0B091, `add XBC,0x00F0B09B / ld XBC,(XBC) / jp (XBC)`,
;          with the index bounded by the `cp BC,0x0009 / jrl UGT` immediately
;          above it.
; Evidence: every word is re-read on every emit and asserted to land inside
;           0xF067A6-0xF0C735, and the entry count 10 is the extent divided by
;           four -- the extent itself coming from the code segment that starts
;           at 0xF0B0C3.
; Unknown: what the index enumerates.  FRAMED name kept.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect_RangeByType: SoftKeyCol4_SoundEditDigitalEffect's switch on the DIGITAL EFFECT type (Arr27A6[0] & 0x0F), 10 entries; each arm
;   sets the edit descriptor's MIN / MAX for that type (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol4_SoundEditDigitalEffect_RangeByType:
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To50	; F0B09B  [0] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To50	; F0B09F  [1] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To50	; F0B0A3  [2] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To50	; F0B0A7  [3] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To50	; F0B0AB  [4] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To50	; F0B0AF  [5] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To100	; F0B0B3  [6] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To100
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To50	; F0B0B7  [7] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To50
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To100	; F0B0BB  [8] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To100
	.long	SoftKeyCol4_SoundEditDigitalEffect_Range0To30	; F0B0BF  [9] -> SoftKeyCol4_SoundEditDigitalEffect_Range0To30


; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect_Range0To50
; Called from: table 0xF0B09B[0], 0xF0B09B[1], 0xF0B09B[2], 0xF0B09B[3],
;              0xF0B09B[4], 0xF0B09B[5] +1 more
; Touches: nothing with an absolute address
; Evidence: word [0] of the pointer table at 0xF0B09B reads 0x00F0B0C3, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B0C3 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect_Range0To50: an arm of SoftKeyCol4_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 50 for type(s) 0,1,2,3,4,5,7
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol4_SoundEditDigitalEffect_Range0To50:
	ld	(xix+8), 50	; F0B0C3  ld (XIX+0x08),0x32
	jr	SoftKeyCol4_SoundEditDigitalEffect_Range0To30_Join	; F0B0C7  jr T,0xf0b0d3

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect_Range0To100
; Called from: table 0xF0B09B[6], 0xF0B09B[8]
; Touches: nothing with an absolute address
; Evidence: word [6] of the pointer table at 0xF0B09B reads 0x00F0B0C9, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B0C9 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect_Range0To100: an arm of SoftKeyCol4_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 100 for type(s) 6,8
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol4_SoundEditDigitalEffect_Range0To100:
	ld	(xix+8), 100	; F0B0C9  ld (XIX+0x08),0x64
	jr	SoftKeyCol4_SoundEditDigitalEffect_Range0To30_Join	; F0B0CD  jr T,0xf0b0d3

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect_Range0To30
; Called from: table 0xF0B09B[9]
; Touches: nothing with an absolute address
; Calls:   0xFD7435 0xFD7C01
; Evidence: word [9] of the pointer table at 0xF0B09B reads 0x00F0B0CF, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B0CF is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditDigitalEffect_Range0To30: an arm of SoftKeyCol4_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 30 for type(s) 9
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol4_SoundEditDigitalEffect_Range0To30:
	ld	(xix+8), 30	; F0B0CF  ld (XIX+0x08),0x1e
SoftKeyCol4_SoundEditDigitalEffect_Range0To30_Join:
	ld	(xix+9), 0	; F0B0D3  ld (XIX+0x09),0x00
	push	xix	; F0B0D7  push XIX
	sub	xbc, xbc	; F0B0D8  sub XBC,XBC
	add	xbc, 212	; F0B0DA  add XBC,0x000000d4
	extz	bc	; F0B0E0  extz BC
	pushw	bc	; F0B0E2  push BC
	pushw	0	; F0B0E3  push 0x0000
	pushw	4	; F0B0E6  push 0x0004
	pushw	154	; F0B0E9  push 0x009a
	call	ToneEdit_CommitField	; F0B0EC  call 0xfd7435
	pushw	4	; F0B0F0  push 0x0004
	call	PanelDial_ActAsButton	; F0B0F3  call 0xfd7c01
	inc	8, xsp	; F0B0F7  inc 0,XSP
	inc	6, xsp	; F0B0F9  inc 6,XSP
SoftKeyCol4_SoundEditDigitalEffect_Range0To30_Skip:
	pop	xix	; F0B0FB  pop XIX
	unlk XIZ	; F0B0FC  unlk XIZ
	ret	; F0B0FE  ret

; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditDigitalEffect
; Called from: table 0xFCF80C[256]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7C2D
; Evidence: word [256] of the pointer table at 0xFCF80C reads 0x00F0B0FF, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B0FF is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditDigitalEffect: SOFT KEY column 5 (lower or upper; the flag carries which) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 4 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol5_SoundEditDigitalEffect:
	link XIZ,0xfff2	; F0B0FF  link XIZ,0xfff2
	push	xix	; F0B103  push XIX
	lda	xix, (xiz-14)	; F0B104  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0B107  lda XBC,XIZ+0xfe
	push	xbc	; F0B10A  push XBC
	pushw	0	; F0B10B  push 0x0000
	call	Arr27A6_Get	; F0B10E  call 0xfd6c7b
	and	(xiz-2), 0x0f	; F0B112  and (XIZ+0xfe),0x0f
	push	xix	; F0B116  push XIX
	pushw	5	; F0B117  push 0x0005
	call	Arr27A6_Get	; F0B11A  call 0xfd6c7b
	ld	(xix+6), 255	; F0B11E  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0B122  ld (XIX+0x07),0x00
	ld	xbc, xix	; F0B126  ld XBC,XIX
	add	xbc, 10	; F0B128  add XBC,0x0000000a
	push	xbc	; F0B12E  push XBC
	ld	bc, (xiz+8)	; F0B12F  ld BC,(XIZ+0x08)
	extz	bc	; F0B132  extz BC
	pushw	bc	; F0B134  push BC
	call	ToneEdit_StepFromEvent	; F0B135  call 0xfd7c2d
	ld	bc, (xiz-2)	; F0B139  ld BC,(XIZ+0xfe)
	extz	bc	; F0B13C  extz BC
	add	xsp, 18	; F0B13E  add XSP,0x00000012
	extz	xbc	; F0B144  extz XBC
	cp	bc, 5:i3	; F0B146  cp BC,5
	jr	ugt, SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50_Skip	; F0B148  jr UGT,0xf0b1a5
	sll	bc, 2	; F0B14A  sll 0x02,BC
	add	xbc, SoftKeyCol5_SoundEditDigitalEffect_RangeByType	; F0B14D  add XBC,0x00f0b157
	ld	xbc, (xbc)	; F0B153  ld XBC,(XBC)
	jp	(xbc)	; F0B155  jp T,XBC

; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditDigitalEffect_RangeByType -- 6 32-bit entries, all inside this block
;                    (0xF0B16F-0xF0B179), naming 2 distinct targets.  A jump
;                    table, not a call table: the reader ends `ld XBC,(XBC) /
;                    jp (XBC)`.
; Read by: prom_b 0xF0B14D, `add XBC,0x00F0B157 / ld XBC,(XBC) / jp (XBC)`,
;          with the index bounded by the `cp BC,0x0005 / jrl UGT` immediately
;          above it.
; Evidence: every word is re-read on every emit and asserted to land inside
;           0xF067A6-0xF0C735, and the entry count 6 is the extent divided by
;           four -- the extent itself coming from the code segment that starts
;           at 0xF0B16F.
; Unknown: what the index enumerates.  FRAMED name kept.
; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditDigitalEffect_RangeByType: SoftKeyCol5_SoundEditDigitalEffect's switch on the DIGITAL EFFECT type (Arr27A6[0] & 0x0F), 6 entries; each arm
;   sets the edit descriptor's MIN / MAX for that type (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol5_SoundEditDigitalEffect_RangeByType:
	.long	SoftKeyCol5_SoundEditDigitalEffect_Range0To100	; F0B157  [0] -> SoftKeyCol5_SoundEditDigitalEffect_Range0To100
	.long	SoftKeyCol5_SoundEditDigitalEffect_Range0To100	; F0B15B  [1] -> SoftKeyCol5_SoundEditDigitalEffect_Range0To100
	.long	SoftKeyCol5_SoundEditDigitalEffect_Range0To100	; F0B15F  [2] -> SoftKeyCol5_SoundEditDigitalEffect_Range0To100
	.long	SoftKeyCol5_SoundEditDigitalEffect_Range0To100	; F0B163  [3] -> SoftKeyCol5_SoundEditDigitalEffect_Range0To100
	.long	SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50	; F0B167  [4] -> SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50	; F0B16B  [5] -> SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50


; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditDigitalEffect_Range0To100
; Called from: table 0xF0B157[0], 0xF0B157[1], 0xF0B157[2], 0xF0B157[3]
; Touches: nothing with an absolute address
; Evidence: word [0] of the pointer table at 0xF0B157 reads 0x00F0B16F, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B16F is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditDigitalEffect_Range0To100: an arm of SoftKeyCol5_SoundEditDigitalEffect_RangeByType -- MIN 0, MAX 100 for type(s) 0,1,2,3
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol5_SoundEditDigitalEffect_Range0To100:
	ld	(xix+8), 100	; F0B16F  ld (XIX+0x08),0x64
	ld	(xix+9), 0	; F0B173  ld (XIX+0x09),0x00
	jr	SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50_Join	; F0B177  jr T,0xf0b181

; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50
; Called from: table 0xF0B157[4], 0xF0B157[5]
; Touches: nothing with an absolute address
; Calls:   0xFD7435 0xFD7C01
; Evidence: word [4] of the pointer table at 0xF0B157 reads 0x00F0B179, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B179 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50: an arm of SoftKeyCol5_SoundEditDigitalEffect_RangeByType -- MIN -50, MAX 50 for type(s) 4,5
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50:
	ld	(xix+8), 50	; F0B179  ld (XIX+0x08),0x32
	ld	(xix+9), 206	; F0B17D  ld (XIX+0x09),0xce
SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50_Join:
	push	xix	; F0B181  push XIX
	sub	xbc, xbc	; F0B182  sub XBC,XBC
	add	xbc, 213	; F0B184  add XBC,0x000000d5
	extz	bc	; F0B18A  extz BC
	pushw	bc	; F0B18C  push BC
	pushw	0	; F0B18D  push 0x0000
	pushw	5	; F0B190  push 0x0005
	pushw	154	; F0B193  push 0x009a
	call	ToneEdit_CommitField	; F0B196  call 0xfd7435
	pushw	5	; F0B19A  push 0x0005
	call	PanelDial_ActAsButton	; F0B19D  call 0xfd7c01
	inc	8, xsp	; F0B1A1  inc 0,XSP
	inc	6, xsp	; F0B1A3  inc 6,XSP
SoftKeyCol5_SoundEditDigitalEffect_RangeM50To50_Skip:
	pop	xix	; F0B1A5  pop XIX
	unlk XIZ	; F0B1A6  unlk XIZ
	ret	; F0B1A8  ret

; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditDigitalEffect
; Called from: table 0xFCF80C[257]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7C2D 0xFD7435 0xFD7C01
; Evidence: word [257] of the pointer table at 0xFCF80C reads 0x00F0B1A9, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B1A9 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditDigitalEffect: SOFT KEY column 6 (lower or upper; the flag carries which) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 5 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol6_SoundEditDigitalEffect:
	link XIZ,0xfff2	; F0B1A9  link XIZ,0xfff2
	push	xix	; F0B1AD  push XIX
	lda	xix, (xiz-14)	; F0B1AE  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0B1B1  lda XBC,XIZ+0xfe
	push	xbc	; F0B1B4  push XBC
	pushw	0	; F0B1B5  push 0x0000
	call	Arr27A6_Get	; F0B1B8  call 0xfd6c7b
	and	(xiz-2), 0x0f	; F0B1BC  and (XIZ+0xfe),0x0f
	push	xix	; F0B1C0  push XIX
	pushw	6	; F0B1C1  push 0x0006
	call	Arr27A6_Get	; F0B1C4  call 0xfd6c7b
	ld	(xix+6), 255	; F0B1C8  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0B1CC  ld (XIX+0x07),0x00
	ld	xbc, xix	; F0B1D0  ld XBC,XIX
	add	xbc, 10	; F0B1D2  add XBC,0x0000000a
	push	xbc	; F0B1D8  push XBC
	ld	bc, (xiz+8)	; F0B1D9  ld BC,(XIZ+0x08)
	extz	bc	; F0B1DC  extz BC
	pushw	bc	; F0B1DE  push BC
	call	ToneEdit_StepFromEvent	; F0B1DF  call 0xfd7c2d
	ld	bc, (xiz-2)	; F0B1E3  ld BC,(XIZ+0xfe)
	extz	bc	; F0B1E6  extz BC
	add	xsp, 18	; F0B1E8  add XSP,0x00000012
	cp	bc, 4:i3	; F0B1EE  cp BC,4
	jr	z, SoftKeyCol6_SoundEditDigitalEffect_Skip	; F0B1F0  jr Z,0xf0b1f8
	cp	bc, 5:i3	; F0B1F2  cp BC,5
	jr	z, SoftKeyCol6_SoundEditDigitalEffect_Skip	; F0B1F4  jr Z,0xf0b1f8
	jr	SoftKeyCol6_SoundEditDigitalEffect_Join	; F0B1F6  jr T,0xf0b224
SoftKeyCol6_SoundEditDigitalEffect_Skip:
	ld	(xix+8), 50	; F0B1F8  ld (XIX+0x08),0x32
	ld	(xix+9), 0	; F0B1FC  ld (XIX+0x09),0x00
	push	xix	; F0B200  push XIX
	sub	xbc, xbc	; F0B201  sub XBC,XBC
	add	xbc, 214	; F0B203  add XBC,0x000000d6
	extz	bc	; F0B209  extz BC
	pushw	bc	; F0B20B  push BC
	pushw	0	; F0B20C  push 0x0000
	pushw	6	; F0B20F  push 0x0006
	pushw	154	; F0B212  push 0x009a
	call	ToneEdit_CommitField	; F0B215  call 0xfd7435
	pushw	6	; F0B219  push 0x0006
	call	PanelDial_ActAsButton	; F0B21C  call 0xfd7c01
	inc	8, xsp	; F0B220  inc 0,XSP
	inc	6, xsp	; F0B222  inc 6,XSP
SoftKeyCol6_SoundEditDigitalEffect_Join:
	pop	xix	; F0B224  pop XIX
	unlk XIZ	; F0B225  unlk XIZ
	ret	; F0B227  ret

; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditDigitalEffect
; Called from: table 0xFCF80C[258]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7C2D
; Evidence: word [258] of the pointer table at 0xFCF80C reads 0x00F0B228, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B228 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditDigitalEffect: SOFT KEY column 7 (lower or upper; the flag carries which) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 6 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol7_SoundEditDigitalEffect:
	link XIZ,0xfff2	; F0B228  link XIZ,0xfff2
	push	xix	; F0B22C  push XIX
	lda	xix, (xiz-14)	; F0B22D  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0B230  lda XBC,XIZ+0xfe
	push	xbc	; F0B233  push XBC
	pushw	0	; F0B234  push 0x0000
	call	Arr27A6_Get	; F0B237  call 0xfd6c7b
	and	(xiz-2), 0x0f	; F0B23B  and (XIZ+0xfe),0x0f
	push	xix	; F0B23F  push XIX
	pushw	7	; F0B240  push 0x0007
	call	Arr27A6_Get	; F0B243  call 0xfd6c7b
	ld	(xix+6), 255	; F0B247  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0B24B  ld (XIX+0x07),0x00
	ld	xbc, xix	; F0B24F  ld XBC,XIX
	add	xbc, 10	; F0B251  add XBC,0x0000000a
	push	xbc	; F0B257  push XBC
	ld	bc, (xiz+8)	; F0B258  ld BC,(XIZ+0x08)
	extz	bc	; F0B25B  extz BC
	pushw	bc	; F0B25D  push BC
	call	ToneEdit_StepFromEvent	; F0B25E  call 0xfd7c2d
	ld	bc, (xiz-2)	; F0B262  ld BC,(XIZ+0xfe)
	extz	bc	; F0B265  extz BC
	add	xsp, 18	; F0B267  add XSP,0x00000012
	extz	xbc	; F0B26D  extz XBC
	cp	bc, 11	; F0B26F  cp BC,0x000b
	jr	ugt, SoftKeyCol7_SoundEditDigitalEffect_NoFieldForType	; F0B273  jr UGT,0xf0b2de
	sll	bc, 2	; F0B275  sll 0x02,BC
	add	xbc, SoftKeyCol7_SoundEditDigitalEffect_RangeByType	; F0B278  add XBC,0x00f0b282
	ld	xbc, (xbc)	; F0B27E  ld XBC,(XBC)
	jp	(xbc)	; F0B280  jp T,XBC

; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditDigitalEffect_RangeByType -- 12 32-bit entries, all inside this block
;                    (0xF0B2B2-0xF0B2DE), naming 2 distinct targets.  A jump
;                    table, not a call table: the reader ends `ld XBC,(XBC) /
;                    jp (XBC)`.
; Read by: prom_b 0xF0B278, `add XBC,0x00F0B282 / ld XBC,(XBC) / jp (XBC)`,
;          with the index bounded by the `cp BC,0x000B / jrl UGT` immediately
;          above it.
; Evidence: every word is re-read on every emit and asserted to land inside
;           0xF067A6-0xF0C735, and the entry count 12 is the extent divided by
;           four -- the extent itself coming from the code segment that starts
;           at 0xF0B2B2.
; Unknown: what the index enumerates.  FRAMED name kept.
; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditDigitalEffect_RangeByType: SoftKeyCol7_SoundEditDigitalEffect's switch on the DIGITAL EFFECT type (Arr27A6[0] & 0x0F), 12 entries; each arm
;   sets the edit descriptor's MIN / MAX for that type (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol7_SoundEditDigitalEffect_RangeByType:
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B282  [0] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B286  [1] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B28A  [2] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B28E  [3] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B292  [4] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B296  [5] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B29A  [6] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B29E  [7] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B2A2  [8] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B2A6  [9] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol7_SoundEditDigitalEffect_NoFieldForType	; F0B2AA  [10] -> SoftKeyCol7_SoundEditDigitalEffect_NoFieldForType
	.long	SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50	; F0B2AE  [11] -> SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50


; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50
; Called from: table 0xF0B282[0], 0xF0B282[1], 0xF0B282[2], 0xF0B282[3],
;              0xF0B282[4], 0xF0B282[5] +5 more
; Touches: nothing with an absolute address
; Calls:   0xFD7435 0xFD7C01
; Evidence: word [0] of the pointer table at 0xF0B282 reads 0x00F0B2B2, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B2B2 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50: an arm of SoftKeyCol7_SoundEditDigitalEffect_RangeByType -- MIN -50, MAX 50 for type(s) 0,1,2,3,4,5,6,7,8,9,11
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol7_SoundEditDigitalEffect_RangeM50To50:
	ld	(xix+8), 50	; F0B2B2  ld (XIX+0x08),0x32
	ld	(xix+9), 206	; F0B2B6  ld (XIX+0x09),0xce
	push	xix	; F0B2BA  push XIX
	sub	xbc, xbc	; F0B2BB  sub XBC,XBC
	add	xbc, 215	; F0B2BD  add XBC,0x000000d7
	extz	bc	; F0B2C3  extz BC
	pushw	bc	; F0B2C5  push BC
	pushw	0	; F0B2C6  push 0x0000
	pushw	7	; F0B2C9  push 0x0007
	pushw	154	; F0B2CC  push 0x009a
	call	ToneEdit_CommitField	; F0B2CF  call 0xfd7435
	pushw	7	; F0B2D3  push 0x0007
	call	PanelDial_ActAsButton	; F0B2D6  call 0xfd7c01
	inc	8, xsp	; F0B2DA  inc 0,XSP
	inc	6, xsp	; F0B2DC  inc 6,XSP

; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditDigitalEffect_NoFieldForType
; Called from: table 0xF0B282[10]
; Touches: nothing with an absolute address
; Evidence: word [10] of the pointer table at 0xF0B282 reads 0x00F0B2DE, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B2DE is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditDigitalEffect_NoFieldForType: an arm of SoftKeyCol7_SoundEditDigitalEffect_RangeByType -- goes straight to the epilogue: type(s) 10 have no field on this key
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol7_SoundEditDigitalEffect_NoFieldForType:
	pop	xix	; F0B2DE  pop XIX
	unlk XIZ	; F0B2DF  unlk XIZ
	ret	; F0B2E1  ret

; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditDigitalEffect
; Called from: table 0xFCF80C[259]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7C2D
; Evidence: word [259] of the pointer table at 0xFCF80C reads 0x00F0B2E2, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B2E2 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditDigitalEffect: SOFT KEY column 8 (lower or upper; the flag carries which) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 7 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol8_SoundEditDigitalEffect:
	link XIZ,0xfff2	; F0B2E2  link XIZ,0xfff2
	push	xix	; F0B2E6  push XIX
	lda	xix, (xiz-14)	; F0B2E7  lda XIX,XIZ+0xf2
	lda	xbc, (xiz-2)	; F0B2EA  lda XBC,XIZ+0xfe
	push	xbc	; F0B2ED  push XBC
	pushw	0	; F0B2EE  push 0x0000
	call	Arr27A6_Get	; F0B2F1  call 0xfd6c7b
	and	(xiz-2), 0x0f	; F0B2F5  and (XIZ+0xfe),0x0f
	push	xix	; F0B2F9  push XIX
	pushw	8	; F0B2FA  push 0x0008
	call	Arr27A6_Get	; F0B2FD  call 0xfd6c7b
	ld	(xix+6), 255	; F0B301  ld (XIX+0x06),0xff
	ld	(xix+7), 0	; F0B305  ld (XIX+0x07),0x00
	ld	xbc, xix	; F0B309  ld XBC,XIX
	add	xbc, 10	; F0B30B  add XBC,0x0000000a
	push	xbc	; F0B311  push XBC
	ld	bc, (xiz+8)	; F0B312  ld BC,(XIZ+0x08)
	extz	bc	; F0B315  extz BC
	pushw	bc	; F0B317  push BC
	call	ToneEdit_StepFromEvent	; F0B318  call 0xfd7c2d
	ld	bc, (xiz-2)	; F0B31C  ld BC,(XIZ+0xfe)
	extz	bc	; F0B31F  extz BC
	add	xsp, 18	; F0B321  add XSP,0x00000012
	extz	xbc	; F0B327  extz XBC
	cp	bc, 11	; F0B329  cp BC,0x000b
	jr	ugt, SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50_Skip	; F0B32D  jr UGT,0xf0b398
	sll	bc, 2	; F0B32F  sll 0x02,BC
	add	xbc, SoftKeyCol8_SoundEditDigitalEffect_RangeByType	; F0B332  add XBC,0x00f0b33c
	ld	xbc, (xbc)	; F0B338  ld XBC,(XBC)
	jp	(xbc)	; F0B33A  jp T,XBC

; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditDigitalEffect_RangeByType -- 12 32-bit entries, all inside this block
;                    (0xF0B36C-0xF0B36C), naming 1 distinct target.  A jump
;                    table, not a call table: the reader ends `ld XBC,(XBC) /
;                    jp (XBC)`.
; Read by: prom_b 0xF0B332, `add XBC,0x00F0B33C / ld XBC,(XBC) / jp (XBC)`,
;          with the index bounded by the `cp BC,0x000B / jrl UGT` immediately
;          above it.
; Evidence: every word is re-read on every emit and asserted to land inside
;           0xF067A6-0xF0C735, and the entry count 12 is the extent divided by
;           four -- the extent itself coming from the code segment that starts
;           at 0xF0B36C.
; Unknown: what the index enumerates.  FRAMED name kept.
; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditDigitalEffect_RangeByType: SoftKeyCol8_SoundEditDigitalEffect's switch on the DIGITAL EFFECT type (Arr27A6[0] & 0x0F), 12 entries; each arm
;   sets the edit descriptor's MIN / MAX for that type (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol8_SoundEditDigitalEffect_RangeByType:
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B33C  [0] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B340  [1] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B344  [2] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B348  [3] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B34C  [4] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B350  [5] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B354  [6] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B358  [7] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B35C  [8] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B360  [9] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B364  [10] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
	.long	SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50	; F0B368  [11] -> SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50


; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50
; Called from: table 0xF0B33C[0], 0xF0B33C[1], 0xF0B33C[2], 0xF0B33C[3],
;              0xF0B33C[4], 0xF0B33C[5] +6 more
; Touches: nothing with an absolute address
; Calls:   0xFD7435 0xFD7C01
; Evidence: word [0] of the pointer table at 0xF0B33C reads 0x00F0B36C, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B36C is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50: an arm of SoftKeyCol8_SoundEditDigitalEffect_RangeByType -- MIN -50, MAX 50 for type(s) 0,1,2,3,4,5,6,7,8,9,10,11
;   (notes/prom_b_digital_effect_key_ranges.py).
SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50:
	ld	(xix+8), 50	; F0B36C  ld (XIX+0x08),0x32
	ld	(xix+9), 206	; F0B370  ld (XIX+0x09),0xce
	push	xix	; F0B374  push XIX
	sub	xbc, xbc	; F0B375  sub XBC,XBC
	add	xbc, 216	; F0B377  add XBC,0x000000d8
	extz	bc	; F0B37D  extz BC
	pushw	bc	; F0B37F  push BC
	pushw	0	; F0B380  push 0x0000
	pushw	8	; F0B383  push 0x0008
	pushw	154	; F0B386  push 0x009a
	call	ToneEdit_CommitField	; F0B389  call 0xfd7435
	pushw	8	; F0B38D  push 0x0008
	call	PanelDial_ActAsButton	; F0B390  call 0xfd7c01
	inc	8, xsp	; F0B394  inc 0,XSP
	inc	6, xsp	; F0B396  inc 6,XSP
SoftKeyCol8_SoundEditDigitalEffect_RangeM50To50_Skip:
	pop	xix	; F0B398  pop XIX
	unlk XIZ	; F0B399  unlk XIZ
	ret	; F0B39B  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditDigitalEffect
; Called from: table 0xFCF80C[261]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD6C65 0xFD616A 0xFD608B 0xFD6122 T_Dispatch_Code80 0xFDA467
; Evidence: word [261] of the pointer table at 0xFCF80C reads 0x00F0B39C, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B39C is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditDigitalEffect: LCD key row 2 (left or right) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 9 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow2_SoundEditDigitalEffect:
	link XIZ,0xfffe	; F0B39C  link XIZ,0xfffe
	pushw	hl	; F0B3A0  push HL
	push	xix	; F0B3A1  push XIX
	lda	xix, (xiz-1)	; F0B3A2  lda XIX,XIZ+0xff
	cp	(xiz+8), 0x00	; F0B3A5  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow2_SoundEditDigitalEffect_Skip	; F0B3A9  jr NZ,0xf0b406
	push	xix	; F0B3AB  push XIX
	pushw	0	; F0B3AC  push 0x0000
	call	Arr27A6_Get	; F0B3AF  call 0xfd6c7b
	ld	h, (xiz-1)	; F0B3B3  ld H,(XIZ+0xff)
	and	h, 15	; F0B3B6  and H,0x0f
	inc	6, xsp	; F0B3B9  inc 6,XSP
	cp	h, 11	; F0B3BB  cp H,0x0b
	jrl	z, LcdKeyRow2_SoundEditDigitalEffect_Skip3	; F0B3BE  jrl Z,0xf0b45d
	cp	h, 11	; F0B3C1  cp H,0x0b
	jrl	ugt, LcdKeyRow2_SoundEditDigitalEffect_Skip3	; F0B3C4  jrl UGT,0xf0b45d
	ld	l, h	; F0B3C7  ld L,H
	inc	1, l	; F0B3C9  inc 1,L
	and	(xiz-1), 0xf0	; F0B3CB  and (XIZ+0xff),0xf0
	ld	h, l	; F0B3CF  ld H,L
	or	h, (xiz-1)	; F0B3D1  or H,(XIZ+0xff)
	ld	(xiz-1), h	; F0B3D4  ld (XIZ+0xff),H
	ld	c, h	; F0B3D7  ld C,H
	extz	bc	; F0B3D9  extz BC
	pushw	bc	; F0B3DB  push BC
	pushw	0	; F0B3DC  push 0x0000
	call	Arr27A6_Set	; F0B3DF  call 0xfd6c65
	pushw	15	; F0B3E3  push 0x000f
	push	xix	; F0B3E6  push XIX
	pushw	208	; F0B3E7  push 0x00d0
	pushw	0	; F0B3EA  push 0x0000
	call	ToneMsg_SendParam	; F0B3ED  call 0xfd616a
	pushw	1	; F0B3F1  push 0x0001
	pushw	156	; F0B3F4  push 0x009c
	call	PanelScreen_PostRequest	; F0B3F7  call 0xfd608b
	add	xsp, 18	; F0B3FB  add XSP,0x00000012
	pushw	1	; F0B401  push 0x0001
	jr	LcdKeyRow2_SoundEditDigitalEffect_Join2	; F0B404  jr T,0xf0b458
LcdKeyRow2_SoundEditDigitalEffect_Skip:
	push	xix	; F0B406  push XIX
	pushw	0	; F0B407  push 0x0000
	call	Arr27A6_Get	; F0B40A  call 0xfd6c7b
	lda	xbc, (xiz-2)	; F0B40E  lda XBC,XIZ+0xfe
	push	xbc	; F0B411  push XBC
	call	Var2250_Get	; F0B412  call 0xfd6122
	ld	c, (xiz-1)	; F0B416  ld C,(XIZ+0xff)
	and	c, 128	; F0B419  and C,0x80
	inc	8, xsp	; F0B41C  inc 0,XSP
	inc	2, xsp	; F0B41E  inc 2,XSP
	jr	z, LcdKeyRow2_SoundEditDigitalEffect_Skip2	; F0B420  jr Z,0xf0b427
	res	7, (xiz-1)	; F0B422  res 7,(XIZ+0xff)
	jr	LcdKeyRow2_SoundEditDigitalEffect_Join	; F0B425  jr T,0xf0b42a
LcdKeyRow2_SoundEditDigitalEffect_Skip2:
	set	7, (xiz-1)	; F0B427  set 7,(XIZ+0xff)
LcdKeyRow2_SoundEditDigitalEffect_Join:
	ld	bc, (xiz-1)	; F0B42A  ld BC,(XIZ+0xff)
	extz	bc	; F0B42D  extz BC
	pushw	bc	; F0B42F  push BC
	pushw	0	; F0B430  push 0x0000
	call	Arr27A6_Set	; F0B433  call 0xfd6c65
	pushw	128	; F0B437  push 0x0080
	push	xix	; F0B43A  push XIX
	pushw	208	; F0B43B  push 0x00d0
	pushw	0	; F0B43E  push 0x0000
	call	ToneMsg_SendParam	; F0B441  call 0xfd616a
	pushw	0	; F0B445  push 0x0000
	pushw	154	; F0B448  push 0x009a
	call	T_Dispatch_Code80	; F0B44B  call 0xf41ed4
	add	xsp, 18	; F0B44F  add XSP,0x00000012
	pushw	0	; F0B455  push 0x0000
LcdKeyRow2_SoundEditDigitalEffect_Join2:
	call	UiRequestBits_SetBit3	; F0B458  call 0xfda467
	popw	bc	; F0B45C  pop BC
LcdKeyRow2_SoundEditDigitalEffect_Skip3:
	pop	xix	; F0B45D  pop XIX
	popw	hl	; F0B45E  pop HL
	unlk XIZ	; F0B45F  unlk XIZ
	ret	; F0B461  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditDigitalEffect
; Called from: table 0xFCF80C[262]
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD6C65 0xFD616A 0xFD608B T_Dispatch_Code80 0xFDA467
; Evidence: word [262] of the pointer table at 0xFCF80C reads 0x00F0B462, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B462 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditDigitalEffect: LCD key row 3 (left or right) on SoundEditDigitalEffect -- SoundEditDigitalEffect op 10 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow3_SoundEditDigitalEffect:
	link XIZ,0xffff	; F0B462  link XIZ,0xffff
	pushw	hl	; F0B466  push HL
	push	xix	; F0B467  push XIX
	lda	xix, (xiz-1)	; F0B468  lda XIX,XIZ+0xff
	cp	(xiz+8), 0x00	; F0B46B  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow3_SoundEditDigitalEffect_Skip	; F0B46F  jr NZ,0xf0b4c9
	push	xix	; F0B471  push XIX
	pushw	0	; F0B472  push 0x0000
	call	Arr27A6_Get	; F0B475  call 0xfd6c7b
	ld	h, (xiz-1)	; F0B479  ld H,(XIZ+0xff)
	and	h, 15	; F0B47C  and H,0x0f
	inc	6, xsp	; F0B47F  inc 6,XSP
	jrl	z, LcdKeyRow3_SoundEditDigitalEffect_Skip3	; F0B481  jrl Z,0xf0b516
	cp	h, 11	; F0B484  cp H,0x0b
	jrl	ugt, LcdKeyRow3_SoundEditDigitalEffect_Skip3	; F0B487  jrl UGT,0xf0b516
	ld	l, h	; F0B48A  ld L,H
	dec	1, l	; F0B48C  dec 1,L
	and	(xiz-1), 0xf0	; F0B48E  and (XIZ+0xff),0xf0
	ld	h, l	; F0B492  ld H,L
	or	h, (xiz-1)	; F0B494  or H,(XIZ+0xff)
	ld	(xiz-1), h	; F0B497  ld (XIZ+0xff),H
	ld	c, h	; F0B49A  ld C,H
	extz	bc	; F0B49C  extz BC
	pushw	bc	; F0B49E  push BC
	pushw	0	; F0B49F  push 0x0000
	call	Arr27A6_Set	; F0B4A2  call 0xfd6c65
	pushw	15	; F0B4A6  push 0x000f
	push	xix	; F0B4A9  push XIX
	pushw	208	; F0B4AA  push 0x00d0
	pushw	0	; F0B4AD  push 0x0000
	call	ToneMsg_SendParam	; F0B4B0  call 0xfd616a
	pushw	1	; F0B4B4  push 0x0001
	pushw	156	; F0B4B7  push 0x009c
	call	PanelScreen_PostRequest	; F0B4BA  call 0xfd608b
	add	xsp, 18	; F0B4BE  add XSP,0x00000012
	pushw	1	; F0B4C4  push 0x0001
	jr	LcdKeyRow3_SoundEditDigitalEffect_Join2	; F0B4C7  jr T,0xf0b511
LcdKeyRow3_SoundEditDigitalEffect_Skip:
	push	xix	; F0B4C9  push XIX
	pushw	0	; F0B4CA  push 0x0000
	call	Arr27A6_Get	; F0B4CD  call 0xfd6c7b
	ld	c, (xiz-1)	; F0B4D1  ld C,(XIZ+0xff)
	and	c, 64	; F0B4D4  and C,0x40
	inc	6, xsp	; F0B4D7  inc 6,XSP
	jr	z, LcdKeyRow3_SoundEditDigitalEffect_Skip2	; F0B4D9  jr Z,0xf0b4e0
	res	6, (xiz-1)	; F0B4DB  res 6,(XIZ+0xff)
	jr	LcdKeyRow3_SoundEditDigitalEffect_Join	; F0B4DE  jr T,0xf0b4e3
LcdKeyRow3_SoundEditDigitalEffect_Skip2:
	set	6, (xiz-1)	; F0B4E0  set 6,(XIZ+0xff)
LcdKeyRow3_SoundEditDigitalEffect_Join:
	ld	bc, (xiz-1)	; F0B4E3  ld BC,(XIZ+0xff)
	extz	bc	; F0B4E6  extz BC
	pushw	bc	; F0B4E8  push BC
	pushw	0	; F0B4E9  push 0x0000
	call	Arr27A6_Set	; F0B4EC  call 0xfd6c65
	pushw	64	; F0B4F0  push 0x0040
	push	xix	; F0B4F3  push XIX
	pushw	208	; F0B4F4  push 0x00d0
	pushw	0	; F0B4F7  push 0x0000
	call	ToneMsg_SendParam	; F0B4FA  call 0xfd616a
	pushw	0	; F0B4FE  push 0x0000
	pushw	154	; F0B501  push 0x009a
	call	T_Dispatch_Code80	; F0B504  call 0xf41ed4
	add	xsp, 18	; F0B508  add XSP,0x00000012
	pushw	0	; F0B50E  push 0x0000
LcdKeyRow3_SoundEditDigitalEffect_Join2:
	call	UiRequestBits_SetBit3	; F0B511  call 0xfda467
	popw	bc	; F0B515  pop BC
LcdKeyRow3_SoundEditDigitalEffect_Skip3:
	pop	xix	; F0B516  pop XIX
	popw	hl	; F0B517  pop HL
	unlk XIZ	; F0B518  unlk XIZ
	ret	; F0B51A  ret

; --------------------------------------------------------------------------
; ExitKey_SoundEditDigitalEffect
; Called from: table 0xFCF80C[267]
; Touches: nothing with an absolute address
; Calls:   0xFD608B
; Evidence: word [267] of the pointer table at 0xFCF80C reads 0x00F0B51B, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B51B is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SoundEditDigitalEffect: the EXIT key on SoundEditDigitalEffect -- SoundEditDigitalEffect op 15 (PanelOpTable_FCFBFC).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
ExitKey_SoundEditDigitalEffect:
	link XIZ,0x0000	; F0B51B  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0B51F  cp (XIZ+0x08),0x00
	jr	nz, ExitKey_SoundEditDigitalEffect_Skip2	; F0B523  jr NZ,0xf0b530
	pushw	0	; F0B525  push 0x0000
	pushw	128	; F0B528  push 0x0080
	call	PanelScreen_PostRequest	; F0B52B  call 0xfd608b
	pop	xiy	; F0B52F  pop XIY
ExitKey_SoundEditDigitalEffect_Skip2:
	unlk XIZ	; F0B530  unlk XIZ
	ret	; F0B532  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditMemoryWrite
; Called from: table 0xFCF80C[224]
; Touches: nothing with an absolute address
; Calls:   0xFDA901 0xFD60D9 0xFDA911 T_NoteList_ReleaseAllSource0 T_PartNotes_ReleaseAllReceivedMidiIn T_PartNotes_ReleaseAllTrackNotes 0xFDA341
;          0xFD608B
; Evidence: word [224] of the pointer table at 0xFCF80C reads 0x00F0B533, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B533 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditMemoryWrite: LCD key row 1 (left or right) on ScreenCode9E -- ScreenCode9E op 8 (PanelOpTable_FCFB6C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow1_SoundEditMemoryWrite:
	link XIZ,0x0000	; F0B533  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0B537  cp (XIZ+0x08),0x00
	jr	z, LcdKeyRow1_SoundEditMemoryWrite_Join	; F0B53B  jr Z,0xf0b575
	call	MemoryProtect_IsSoundOn	; F0B53D  call 0xfda901
	cp	a, 0:i3	; F0B541  cp A,0
	jr	z, LcdKeyRow1_SoundEditMemoryWrite_Skip3	; F0B543  jr Z,0xf0b552
	pushw	0	; F0B545  push 0x0000
	pushw	179	; F0B548  push 0x00b3
	call	PanelScreen_PostRequestBit6	; F0B54B  call 0xfd60d9
	pop	xiy	; F0B54F  pop XIY
	jr	LcdKeyRow1_SoundEditMemoryWrite_Join	; F0B550  jr T,0xf0b575
LcdKeyRow1_SoundEditMemoryWrite_Skip3:
	call	DspEffect_SendAllToCpu2	; F0B552  call 0xfda911
	call	T_NoteList_ReleaseAllSource0	; F0B556  call 0xf413c4
	call	T_PartNotes_ReleaseAllReceivedMidiIn	; F0B55A  call 0xf413c0
	call	T_PartNotes_ReleaseAllTrackNotes	; F0B55E  call 0xf413c8
	pushw	1	; F0B562  push 0x0001
	call	Var27FE_Set	; F0B565  call 0xfda341
	pushw	1	; F0B569  push 0x0001
	pushw	158	; F0B56C  push 0x009e
	call	PanelScreen_PostRequest	; F0B56F  call 0xfd608b
	inc	6, xsp	; F0B573  inc 6,XSP
LcdKeyRow1_SoundEditMemoryWrite_Join:
	unlk XIZ	; F0B575  unlk XIZ
	ret	; F0B577  ret

; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditMemoryWrite
; Called from: table 0xFCF80C[226]
; Touches: nothing with an absolute address
; Calls:   0xFD7B6B 0xFDA0CA 0xFD7B7B 0xFD6C65 T_Dispatch_Code80
; Evidence: word [226] of the pointer table at 0xFCF80C reads 0x00F0B578, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B578 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow3_SoundEditMemoryWrite: LCD key row 3 (left or right) on ScreenCode9E -- ScreenCode9E op 10 (PanelOpTable_FCFB6C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow3_SoundEditMemoryWrite:
	link XIZ,0xfff8	; F0B578  link XIZ,0xfff8
	pushw	hl	; F0B57C  push HL
	push	xix	; F0B57D  push XIX
	lda	xix, (xiz-8)	; F0B57E  lda XIX,XIZ+0xf8
	cp	(xiz+8), 0x00	; F0B581  cp (XIZ+0x08),0x00
	jrl	nz, LcdKeyRow3_SoundEditMemoryWrite_Join2	; F0B585  jrl NZ,0xf0b62a
	lda	xbc, (xiz-2)	; F0B588  lda XBC,XIZ+0xfe
	push	xbc	; F0B58B  push XBC
	call	Var27E9_Get	; F0B58C  call 0xfd7b6b
	lda	xbc, (xiz-4)	; F0B590  lda XBC,XIZ+0xfc
	push	xbc	; F0B593  push XBC
	call	Var27F5_Get	; F0B594  call 0xfda0ca
	inc	8, xsp	; F0B598  inc 0,XSP
	cp	(xiz-4), 0x01	; F0B59A  cp (XIZ+0xfc),0x01
	jr	nz, LcdKeyRow3_SoundEditMemoryWrite_Skip	; F0B59E  jr NZ,0xf0b5a9
	cp	(xiz-2), 0x03	; F0B5A0  cp (XIZ+0xfe),0x03
	jr	c, LcdKeyRow3_SoundEditMemoryWrite_Skip2	; F0B5A4  jr C,0xf0b5b0
	jrl	LcdKeyRow3_SoundEditMemoryWrite_Join2	; F0B5A6  jrl T,0xf0b62a
LcdKeyRow3_SoundEditMemoryWrite_Skip:
	cp	(xiz-2), 0xff	; F0B5A9  cp (XIZ+0xfe),0xff
	jrl	nc, LcdKeyRow3_SoundEditMemoryWrite_Join2	; F0B5AD  jrl NC,0xf0b62a
LcdKeyRow3_SoundEditMemoryWrite_Skip2:
	incm8	1, (xiz-2)	; F0B5B0  inc 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F0B5B3  ld BC,(XIZ+0xfe)
	extz	bc	; F0B5B6  extz BC
	pushw	bc	; F0B5B8  push BC
	call	Var27E9_Set	; F0B5B9  call 0xfd7b7b
	popw	bc	; F0B5BD  pop BC
	cp	(xiz-4), 0x01	; F0B5BE  cp (XIZ+0xfc),0x01
	jr	nz, LcdKeyRow3_SoundEditMemoryWrite_Skip3	; F0B5C2  jr NZ,0xf0b5d6
	ld	bc, (xiz-2)	; F0B5C4  ld BC,(XIZ+0xfe)
	extz	bc	; F0B5C7  extz BC
	inc	1, bc	; F0B5C9  inc 1,BC
	pushw	bc	; F0B5CB  push BC
	pushw	1	; F0B5CC  push 0x0001
	call	Arr27A6_Set	; F0B5CF  call 0xfd6c65
	pop	xiy	; F0B5D3  pop XIY
	jr	LcdKeyRow3_SoundEditMemoryWrite_Join	; F0B5D4  jr T,0xf0b61f
LcdKeyRow3_SoundEditMemoryWrite_Skip3:
	ld	hl, (xiz-2)	; F0B5D6  ld HL,(XIZ+0xfe)
	extz	hl	; F0B5D9  extz HL
	ld	bc, hl	; F0B5DB  ld BC,HL
	extz	xbc	; F0B5DD  extz XBC
	div	bc, 128	; F0B5DF  div BC,0x0080
	ld	(xix), c	; F0B5E3  ld (XIX),C
	ld	bc, hl	; F0B5E5  ld BC,HL
	extz	xbc	; F0B5E7  extz XBC
	div	bc, 128	; F0B5E9  div BC,0x0080
	.byte 0xD7, 0xE6, 0xB9	; F0B5ED  ex BC,QBC   [llvm-mc cannot encode this]
	ld	(xix+1), c	; F0B5F0  ld (XIX+0x01),C
	incm8	1, (xix)	; F0B5F3  inc 1,(XIX)
	incm8	1, (xix+1)	; F0B5F5  inc 1,(XIX+0x01)
	ld	c, (xix)	; F0B5F8  ld C,(XIX)
	extz	bc	; F0B5FA  extz BC
	pushw	bc	; F0B5FC  push BC
	pushw	0	; F0B5FD  push 0x0000
	call	Arr27A6_Set	; F0B600  call 0xfd6c65
	ld	c, (xix+1)	; F0B604  ld C,(XIX+0x01)
	extz	bc	; F0B607  extz BC
	pushw	bc	; F0B609  push BC
	pushw	1	; F0B60A  push 0x0001
	call	Arr27A6_Set	; F0B60D  call 0xfd6c65
	pushw	0	; F0B611  push 0x0000
	pushw	158	; F0B614  push 0x009e
	call	T_Dispatch_Code80	; F0B617  call 0xf41ed4
	inc	8, xsp	; F0B61B  inc 0,XSP
	inc	4, xsp	; F0B61D  inc 4,XSP
LcdKeyRow3_SoundEditMemoryWrite_Join:
	pushw	1	; F0B61F  push 0x0001
	pushw	158	; F0B622  push 0x009e
	call	T_Dispatch_Code80	; F0B625  call 0xf41ed4
	pop	xiy	; F0B629  pop XIY
LcdKeyRow3_SoundEditMemoryWrite_Join2:
	pop	xix	; F0B62A  pop XIX
	popw	hl	; F0B62B  pop HL
	unlk XIZ	; F0B62C  unlk XIZ
	ret	; F0B62E  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditMemoryWrite
; Called from: table 0xFCF80C[227]
; Touches: nothing with an absolute address
; Calls:   0xFD7B6B 0xFD7B7B 0xFDA0CA 0xFD6C65 T_Dispatch_Code80
; Evidence: word [227] of the pointer table at 0xFCF80C reads 0x00F0B62F, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B62F is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditMemoryWrite: LCD key row 4 (left or right) on ScreenCode9E -- ScreenCode9E op 11 (PanelOpTable_FCFB6C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow4_SoundEditMemoryWrite:
	link XIZ,0xfff8	; F0B62F  link XIZ,0xfff8
	pushw	hl	; F0B633  push HL
	push	xix	; F0B634  push XIX
	lda	xix, (xiz-8)	; F0B635  lda XIX,XIZ+0xf8
	cp	(xiz+8), 0x00	; F0B638  cp (XIZ+0x08),0x00
	jrl	nz, LcdKeyRow4_SoundEditMemoryWrite_Skip2	; F0B63C  jrl NZ,0xf0b6d2
	lda	xbc, (xiz-2)	; F0B63F  lda XBC,XIZ+0xfe
	push	xbc	; F0B642  push XBC
	call	Var27E9_Get	; F0B643  call 0xfd7b6b
	pop	xiy	; F0B647  pop XIY
	cp	(xiz-2), 0x00	; F0B648  cp (XIZ+0xfe),0x00
	jrl	z, LcdKeyRow4_SoundEditMemoryWrite_Skip2	; F0B64C  jrl Z,0xf0b6d2
	decm8	1, (xiz-2)	; F0B64F  dec 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F0B652  ld BC,(XIZ+0xfe)
	extz	bc	; F0B655  extz BC
	pushw	bc	; F0B657  push BC
	call	Var27E9_Set	; F0B658  call 0xfd7b7b
	lda	xbc, (xiz-4)	; F0B65C  lda XBC,XIZ+0xfc
	push	xbc	; F0B65F  push XBC
	call	Var27F5_Get	; F0B660  call 0xfda0ca
	inc	6, xsp	; F0B664  inc 6,XSP
	cp	(xiz-4), 0x01	; F0B666  cp (XIZ+0xfc),0x01
	jr	nz, LcdKeyRow4_SoundEditMemoryWrite_Skip	; F0B66A  jr NZ,0xf0b67e
	ld	bc, (xiz-2)	; F0B66C  ld BC,(XIZ+0xfe)
	extz	bc	; F0B66F  extz BC
	inc	1, bc	; F0B671  inc 1,BC
	pushw	bc	; F0B673  push BC
	pushw	1	; F0B674  push 0x0001
	call	Arr27A6_Set	; F0B677  call 0xfd6c65
	pop	xiy	; F0B67B  pop XIY
	jr	LcdKeyRow4_SoundEditMemoryWrite_Join	; F0B67C  jr T,0xf0b6c7
LcdKeyRow4_SoundEditMemoryWrite_Skip:
	ld	hl, (xiz-2)	; F0B67E  ld HL,(XIZ+0xfe)
	extz	hl	; F0B681  extz HL
	ld	bc, hl	; F0B683  ld BC,HL
	extz	xbc	; F0B685  extz XBC
	div	bc, 128	; F0B687  div BC,0x0080
	ld	(xix), c	; F0B68B  ld (XIX),C
	ld	bc, hl	; F0B68D  ld BC,HL
	extz	xbc	; F0B68F  extz XBC
	div	bc, 128	; F0B691  div BC,0x0080
	.byte 0xD7, 0xE6, 0xB9	; F0B695  ex BC,QBC   [llvm-mc cannot encode this]
	ld	(xix+1), c	; F0B698  ld (XIX+0x01),C
	incm8	1, (xix)	; F0B69B  inc 1,(XIX)
	incm8	1, (xix+1)	; F0B69D  inc 1,(XIX+0x01)
	ld	c, (xix)	; F0B6A0  ld C,(XIX)
	extz	bc	; F0B6A2  extz BC
	pushw	bc	; F0B6A4  push BC
	pushw	0	; F0B6A5  push 0x0000
	call	Arr27A6_Set	; F0B6A8  call 0xfd6c65
	ld	c, (xix+1)	; F0B6AC  ld C,(XIX+0x01)
	extz	bc	; F0B6AF  extz BC
	pushw	bc	; F0B6B1  push BC
	pushw	1	; F0B6B2  push 0x0001
	call	Arr27A6_Set	; F0B6B5  call 0xfd6c65
	pushw	0	; F0B6B9  push 0x0000
	pushw	158	; F0B6BC  push 0x009e
	call	T_Dispatch_Code80	; F0B6BF  call 0xf41ed4
	inc	8, xsp	; F0B6C3  inc 0,XSP
	inc	4, xsp	; F0B6C5  inc 4,XSP
LcdKeyRow4_SoundEditMemoryWrite_Join:
	pushw	1	; F0B6C7  push 0x0001
	pushw	158	; F0B6CA  push 0x009e
	call	T_Dispatch_Code80	; F0B6CD  call 0xf41ed4
	pop	xiy	; F0B6D1  pop XIY
LcdKeyRow4_SoundEditMemoryWrite_Skip2:
	pop	xix	; F0B6D2  pop XIX
	popw	hl	; F0B6D3  pop HL
	unlk XIZ	; F0B6D4  unlk XIZ
	ret	; F0B6D6  ret

; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditMemoryWrite
; Called from: table 0xFCF80C[228]
; Touches: nothing with an absolute address
; Calls:   0xFD608B
; Evidence: word [228] of the pointer table at 0xFCF80C reads 0x00F0B6D7, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B6D7 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow5_SoundEditMemoryWrite: LCD key row 5 (left or right) on ScreenCode9E -- ScreenCode9E op 12 (PanelOpTable_FCFB6C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow5_SoundEditMemoryWrite:
	link XIZ,0x0000	; F0B6D7  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0B6DB  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow5_SoundEditMemoryWrite_Skip4	; F0B6DF  jr NZ,0xf0b6ec
	pushw	0	; F0B6E1  push 0x0000
	pushw	159	; F0B6E4  push 0x009f
	call	PanelScreen_PostRequest	; F0B6E7  call 0xfd608b
	pop	xiy	; F0B6EB  pop XIY
LcdKeyRow5_SoundEditMemoryWrite_Skip4:
	unlk XIZ	; F0B6EC  unlk XIZ
	ret	; F0B6EE  ret

; --------------------------------------------------------------------------
; ExitKey_SoundEditMemoryWrite
; Called from: table 0xFCF80C[231]
; Touches: nothing with an absolute address
; Calls:   0xFDA0AC 0xFD608B
; Evidence: word [231] of the pointer table at 0xFCF80C reads 0x00F0B6EF, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B6EF is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SoundEditMemoryWrite: the EXIT key on ScreenCode9E -- ScreenCode9E op 15 (PanelOpTable_FCFB6C).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
ExitKey_SoundEditMemoryWrite:
	link XIZ,0x0000	; F0B6EF  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0B6F3  cp (XIZ+0x08),0x00
	jr	nz, ExitKey_SoundEditMemoryWrite_Skip5	; F0B6F7  jr NZ,0xf0b70c
	pushw	0	; F0B6F9  push 0x0000
	call	Var27F6_Set	; F0B6FC  call 0xfda0ac
	pushw	0	; F0B700  push 0x0000
	pushw	128	; F0B703  push 0x0080
	call	PanelScreen_PostRequest	; F0B706  call 0xfd608b
	inc	6, xsp	; F0B70A  inc 6,XSP
ExitKey_SoundEditMemoryWrite_Skip5:
	unlk XIZ	; F0B70C  unlk XIZ
	ret	; F0B70E  ret

; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditNaming
; Called from: table 0xFCF80C[234]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_SoftKeyCol1
; Evidence: word [234] of the pointer table at 0xFCF80C reads 0x00F0B70F, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B70F is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditNaming: SOFT KEY column 1 (lower or upper; the flag carries which) on ScreenCode9F -- ScreenCode9F op 0 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol1_SoundEditNaming:
	calr	SoundEditNaming_SoftKeyCol1	; F0B70F  calr 0xf0b9b3
	ret	; F0B712  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditNaming
; Called from: table 0xFCF80C[235]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_SoftKeyCol2
; Evidence: word [235] of the pointer table at 0xFCF80C reads 0x00F0B713, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B713 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditNaming: SOFT KEY column 2 (lower or upper; the flag carries which) on ScreenCode9F -- ScreenCode9F op 1 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol2_SoundEditNaming:
	calr	SoundEditNaming_SoftKeyCol2	; F0B713  calr 0xf0ba20
	ret	; F0B716  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditNaming
; Called from: table 0xFCF80C[236]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_SoftKeyCol3
; Evidence: word [236] of the pointer table at 0xFCF80C reads 0x00F0B717, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B717 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditNaming: SOFT KEY column 3 (lower or upper; the flag carries which) on ScreenCode9F -- ScreenCode9F op 2 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol3_SoundEditNaming:
	calr	SoundEditNaming_SoftKeyCol3	; F0B717  calr 0xf0baa8
	ret	; F0B71A  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditNaming
; Called from: table 0xFCF80C[237]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_SoftKeyCol4
; Evidence: word [237] of the pointer table at 0xFCF80C reads 0x00F0B71B, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B71B is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditNaming: SOFT KEY column 4 (lower or upper; the flag carries which) on ScreenCode9F -- ScreenCode9F op 3 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol4_SoundEditNaming:
	calr	SoundEditNaming_SoftKeyCol4	; F0B71B  calr 0xf0bbb4
	ret	; F0B71E  ret

; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditNaming
; Called from: table 0xFCF80C[238]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_SoftKeyCol5
; Evidence: word [238] of the pointer table at 0xFCF80C reads 0x00F0B71F, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B71F is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol5_SoundEditNaming: SOFT KEY column 5 (lower or upper; the flag carries which) on ScreenCode9F -- ScreenCode9F op 4 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol5_SoundEditNaming:
	calr	SoundEditNaming_SoftKeyCol5	; F0B71F  calr 0xf0bc98
	ret	; F0B722  ret

; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditNaming
; Called from: table 0xFCF80C[239]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_SoftKeyCol6
; Evidence: word [239] of the pointer table at 0xFCF80C reads 0x00F0B723, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B723 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditNaming: SOFT KEY column 6 (lower or upper; the flag carries which) on ScreenCode9F -- ScreenCode9F op 5 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol6_SoundEditNaming:
	calr	SoundEditNaming_SoftKeyCol6	; F0B723  calr 0xf0bd31
	ret	; F0B726  ret

; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditNaming
; Called from: table 0xFCF80C[240]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_SoftKeyCol7
; Evidence: word [240] of the pointer table at 0xFCF80C reads 0x00F0B727, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B727 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol7_SoundEditNaming: SOFT KEY column 7 (lower or upper; the flag carries which) on ScreenCode9F -- ScreenCode9F op 6 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol7_SoundEditNaming:
	link XIZ,0x0000	; F0B727  link XIZ,0x0000
	pushw	hl	; F0B72B  push HL
	ld	c, (xiz+8)	; F0B72C  ld C,(XIZ+0x08)
	res	7, c	; F0B72F  res 0x07,C
	cp	c, 0:i3	; F0B732  cp C,0
	jr	nz, SoftKeyCol7_SoundEditNaming_Skip	; F0B734  jr NZ,0xf0b73b
	ldw	hl, 0	; F0B736  ld HL,0x0000
	jr	SoftKeyCol7_SoundEditNaming_Join	; F0B739  jr T,0xf0b73e
SoftKeyCol7_SoundEditNaming_Skip:
	ldw	hl, 32768	; F0B73B  ld HL,0x8000
SoftKeyCol7_SoundEditNaming_Join:
	pushw	hl	; F0B73E  push HL
	calr	SoundEditNaming_SoftKeyCol7	; F0B73F  calr 0xf0bdac
	popw	bc	; F0B742  pop BC
	popw	hl	; F0B743  pop HL
	unlk XIZ	; F0B744  unlk XIZ
	ret	; F0B746  ret

; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditNaming
; Called from: table 0xFCF80C[241]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_SoftKeyCol8
; Evidence: word [241] of the pointer table at 0xFCF80C reads 0x00F0B747, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B747 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol8_SoundEditNaming: SOFT KEY column 8 (lower or upper; the flag carries which) on ScreenCode9F -- ScreenCode9F op 7 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol8_SoundEditNaming:
	calr	SoundEditNaming_SoftKeyCol8	; F0B747  calr 0xf0be44
	ret	; F0B74A  ret

; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditNaming
; Called from: table 0xFCF80C[242]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_LcdKeyRow1 0xFDA0CA 0xFDA0BA 0xFD785C 0xFD6704 0xFD7BA5 0xFD616A
;          0xFDA341 0xFD608B
; Evidence: word [242] of the pointer table at 0xFCF80C reads 0x00F0B74B, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B74B is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow1_SoundEditNaming: LCD key row 1 (left or right) on ScreenCode9F -- ScreenCode9F op 8 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow1_SoundEditNaming:
	link XIZ,0xffe8	; F0B74B  link XIZ,0xffe8
	pushw	hl	; F0B74F  push HL
	push	xix	; F0B750  push XIX
	cp	(xiz+8), 0x00	; F0B751  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow1_SoundEditNaming_Skip	; F0B755  jr NZ,0xf0b75d
	calr	SoundEditNaming_LcdKeyRow1	; F0B757  calr 0xf0bebf
	jrl	LcdKeyRow1_SoundEditNaming_Join2	; F0B75A  jrl T,0xf0b808
LcdKeyRow1_SoundEditNaming_Skip:
	lda	xbc, (xiz-2)	; F0B75D  lda XBC,XIZ+0xfe
	push	xbc	; F0B760  push XBC
	call	Var27F5_Get	; F0B761  call 0xfda0ca
	pop	xiy	; F0B765  pop XIY
	cp	(xiz-2), 0x01	; F0B766  cp (XIZ+0xfe),0x01
	jr	nz, LcdKeyRow1_SoundEditNaming_Skip2	; F0B76A  jr NZ,0xf0b7bd
	lda	xbc, (xiz-4)	; F0B76C  lda XBC,XIZ+0xfc
	push	xbc	; F0B76F  push XBC
	call	Var27F6_Get	; F0B770  call 0xfda0ba
	pop	xiy	; F0B774  pop XIY
	cp	(xiz-4), 0x02	; F0B775  cp (XIZ+0xfc),0x02
	jrl	z, LcdKeyRow1_SoundEditNaming_Join2	; F0B779  jrl Z,0xf0b808
	pushw	16	; F0B77C  push 0x0010
	lda	xbc, (xiz-24)	; F0B77F  lda XBC,XIZ+0xe8
	push	xbc	; F0B782  push XBC
	pushw	1	; F0B783  push 0x0001
	call	SoundEditText_GetSlot	; F0B786  call 0xfd785c
	ld	h, 0:opc	; F0B78A  ld H,0x00
	inc	8, xsp	; F0B78C  inc 0,XSP
LcdKeyRow1_SoundEditNaming_Loop:
	pushw	127	; F0B78E  push 0x007f
	ld	c, h	; F0B791  ld C,H
	extz	bc	; F0B793  extz BC
	extz	xbc	; F0B795  extz XBC
	ld	xix, xbc	; F0B797  ld XIX,XBC
	add	xbc, xiz	; F0B799  add XBC,XIZ
	add	xbc, 4294967272	; F0B79B  add XBC,0xffffffe8
	push	xbc	; F0B7A1  push XBC
	sub	xbc, xbc	; F0B7A2  sub XBC,XBC
	add	xbc, xix	; F0B7A4  add XBC,XIX
	extz	bc	; F0B7A6  extz BC
	pushw	bc	; F0B7A8  push BC
	pushw	3	; F0B7A9  push 0x0003
	call	ToneMsg8D_SendParam	; F0B7AC  call 0xfd6704
	inc	1, h	; F0B7B0  inc 1,H
	inc	8, xsp	; F0B7B2  inc 0,XSP
	inc	2, xsp	; F0B7B4  inc 2,XSP
	cp	h, 16	; F0B7B6  cp H,0x10
	jr	c, LcdKeyRow1_SoundEditNaming_Loop	; F0B7B9  jr C,0xf0b78e
	jr	LcdKeyRow1_SoundEditNaming_Join	; F0B7BB  jr T,0xf0b7fd
LcdKeyRow1_SoundEditNaming_Skip2:
	ld	h, 0:opc	; F0B7BD  ld H,0x00
LcdKeyRow1_SoundEditNaming_Loop2:
	lda	xbc, (xiz-6)	; F0B7BF  lda XBC,XIZ+0xfa
	push	xbc	; F0B7C2  push XBC
	ld	a, h	; F0B7C3  ld A,H
	extz	wa	; F0B7C5  extz WA
	pushw	wa	; F0B7C7  push WA
	call	Arr22F0_Get	; F0B7C8  call 0xfd7ba5
	pushw	127	; F0B7CC  push 0x007f
	lda	xbc, (xiz-6)	; F0B7CF  lda XBC,XIZ+0xfa
	push	xbc	; F0B7D2  push XBC
	ld	xix, 0	; F0B7D3  ld XIX,0x00000000
	ld	a, h	; F0B7D8  ld A,H
	extz	wa	; F0B7DA  extz WA
	extz	xwa	; F0B7DC  extz XWA
	add	xwa, xix	; F0B7DE  add XWA,XIX
	extz	wa	; F0B7E0  extz WA
	pushw	wa	; F0B7E2  push WA
	pushw	0	; F0B7E3  push 0x0000
	call	ToneMsg_SendParam	; F0B7E6  call 0xfd616a
	inc	1, h	; F0B7EA  inc 1,H
	inc	8, xsp	; F0B7EC  inc 0,XSP
	inc	8, xsp	; F0B7EE  inc 0,XSP
	cp	h, 16	; F0B7F0  cp H,0x10
	jr	c, LcdKeyRow1_SoundEditNaming_Loop2	; F0B7F3  jr C,0xf0b7bf
	pushw	0	; F0B7F5  push 0x0000
	call	Var27FE_Set	; F0B7F8  call 0xfda341
	popw	bc	; F0B7FC  pop BC
LcdKeyRow1_SoundEditNaming_Join:
	pushw	0	; F0B7FD  push 0x0000
	pushw	158	; F0B800  push 0x009e
	call	PanelScreen_PostRequest	; F0B803  call 0xfd608b
	pop	xiy	; F0B807  pop XIY
LcdKeyRow1_SoundEditNaming_Join2:
	pop	xix	; F0B808  pop XIX
	popw	hl	; F0B809  pop HL
	unlk XIZ	; F0B80A  unlk XIZ
	ret	; F0B80C  ret

; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditNaming
; Called from: table 0xFCF80C[243]
; Touches: nothing with an absolute address
; Calls:   SoundEditNaming_LcdKeyRow2
; Evidence: word [243] of the pointer table at 0xFCF80C reads 0x00F0B80D, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B80D is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow2_SoundEditNaming: LCD key row 2 (left or right) on ScreenCode9F -- ScreenCode9F op 9 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow2_SoundEditNaming:
	link XIZ,0x0000	; F0B80D  link XIZ,0x0000
	cp	(xiz+8), 0x00	; F0B811  cp (XIZ+0x08),0x00
	jr	nz, LcdKeyRow2_SoundEditNaming_Skip	; F0B815  jr NZ,0xf0b81a
	calr	SoundEditNaming_LcdKeyRow2	; F0B817  calr 0xf0bf04
LcdKeyRow2_SoundEditNaming_Skip:
	unlk XIZ	; F0B81A  unlk XIZ
	ret	; F0B81C  ret

; --------------------------------------------------------------------------
; ExitKey_SoundEditNaming
; Called from: table 0xFCF80C[249]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFDA0BA 0xFD785C 0xFD6704 0xFD608B 0xFDA0AC 0xFD7BA5
;          0xFD616A 0xFDA341
; Evidence: word [249] of the pointer table at 0xFCF80C reads 0x00F0B81D, that
;           table's reader TRANSFERS to the word it loads, and 0xF0B81D is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SoundEditNaming: the EXIT key on ScreenCode9F -- ScreenCode9F op 15 (PanelOpTable_FCFBB4).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
ExitKey_SoundEditNaming:
	link XIZ,0xffe4	; F0B81D  link XIZ,0xffe4
	pushw	hl	; F0B821  push HL
	push	xix	; F0B822  push XIX
	lda	xix, (xiz-24)	; F0B823  lda XIX,XIZ+0xe8
	cp	(xiz+8), 0x00	; F0B826  cp (XIZ+0x08),0x00
	jrl	nz, ExitKey_SoundEditNaming_Join2	; F0B82A  jrl NZ,0xf0b917
	lda	xbc, (xiz-2)	; F0B82D  lda XBC,XIZ+0xfe
	push	xbc	; F0B830  push XBC
	call	Var27F5_Get	; F0B831  call 0xfda0ca
	pop	xiy	; F0B835  pop XIY
	cp	(xiz-2), 0x01	; F0B836  cp (XIZ+0xfe),0x01
	jrl	nz, ExitKey_SoundEditNaming_Skip	; F0B83A  jrl NZ,0xf0b8cb
	lda	xbc, (xiz-4)	; F0B83D  lda XBC,XIZ+0xfc
	push	xbc	; F0B840  push XBC
	call	Var27F6_Get	; F0B841  call 0xfda0ba
	pushw	16	; F0B845  push 0x0010
	push	xix	; F0B848  push XIX
	pushw	1	; F0B849  push 0x0001
	call	SoundEditText_GetSlot	; F0B84C  call 0xfd785c
	ld	h, 0:opc	; F0B850  ld H,0x00
	inc	8, xsp	; F0B852  inc 0,XSP
	inc	4, xsp	; F0B854  inc 4,XSP
	cp	(xiz-4), 0x02	; F0B856  cp (XIZ+0xfc),0x02
	jr	nz, ExitKey_SoundEditNaming_Loop2	; F0B85A  jr NZ,0xf0b887
ExitKey_SoundEditNaming_Loop:
	pushw	127	; F0B85C  push 0x007f
	ld	c, h	; F0B85F  ld C,H
	extz	bc	; F0B861  extz BC
	extz	xbc	; F0B863  extz XBC
	ld	(xiz-28), xbc	; F0B865  ld (XIZ+0xe4),XBC
	add	xbc, xix	; F0B868  add XBC,XIX
	push	xbc	; F0B86A  push XBC
	sub	xbc, xbc	; F0B86B  sub XBC,XBC
	add	xbc, (xiz-28)	; F0B86D  add XBC,(XIZ+0xe4)
	extz	bc	; F0B870  extz BC
	pushw	bc	; F0B872  push BC
	pushw	0	; F0B873  push 0x0000
	call	ToneMsg8D_SendParam	; F0B876  call 0xfd6704
	inc	1, h	; F0B87A  inc 1,H
	inc	8, xsp	; F0B87C  inc 0,XSP
	inc	2, xsp	; F0B87E  inc 2,XSP
	cp	h, 13	; F0B880  cp H,0x0d
	jr	c, ExitKey_SoundEditNaming_Loop	; F0B883  jr C,0xf0b85c
	jr	ExitKey_SoundEditNaming_Join	; F0B885  jr T,0xf0b8b0
ExitKey_SoundEditNaming_Loop2:
	pushw	127	; F0B887  push 0x007f
	ld	c, h	; F0B88A  ld C,H
	extz	bc	; F0B88C  extz BC
	extz	xbc	; F0B88E  extz XBC
	ld	(xiz-28), xbc	; F0B890  ld (XIZ+0xe4),XBC
	add	xbc, xix	; F0B893  add XBC,XIX
	push	xbc	; F0B895  push XBC
	sub	xbc, xbc	; F0B896  sub XBC,XBC
	add	xbc, (xiz-28)	; F0B898  add XBC,(XIZ+0xe4)
	extz	bc	; F0B89B  extz BC
	pushw	bc	; F0B89D  push BC
	pushw	3	; F0B89E  push 0x0003
	call	ToneMsg8D_SendParam	; F0B8A1  call 0xfd6704
	inc	1, h	; F0B8A5  inc 1,H
	inc	8, xsp	; F0B8A7  inc 0,XSP
	inc	2, xsp	; F0B8A9  inc 2,XSP
	cp	h, 16	; F0B8AB  cp H,0x10
	jr	c, ExitKey_SoundEditNaming_Loop2	; F0B8AE  jr C,0xf0b887
ExitKey_SoundEditNaming_Join:
	cp	(xiz-4), 0x02	; F0B8B0  cp (XIZ+0xfc),0x02
	jr	nz, ExitKey_SoundEditNaming_Skip2	; F0B8B4  jr NZ,0xf0b90c
	pushw	0	; F0B8B6  push 0x0000
	pushw	203	; F0B8B9  push 0x00cb
	call	PanelScreen_PostRequest	; F0B8BC  call 0xfd608b
	pushw	0	; F0B8C0  push 0x0000
	call	Var27F6_Set	; F0B8C3  call 0xfda0ac
	inc	6, xsp	; F0B8C7  inc 6,XSP
	jr	ExitKey_SoundEditNaming_Join2	; F0B8C9  jr T,0xf0b917
ExitKey_SoundEditNaming_Skip:
	ld	h, 0:opc	; F0B8CB  ld H,0x00
ExitKey_SoundEditNaming_Loop3:
	lda	xbc, (xiz-6)	; F0B8CD  lda XBC,XIZ+0xfa
	push	xbc	; F0B8D0  push XBC
	ld	a, h	; F0B8D1  ld A,H
	extz	wa	; F0B8D3  extz WA
	pushw	wa	; F0B8D5  push WA
	call	Arr22F0_Get	; F0B8D6  call 0xfd7ba5
	pushw	127	; F0B8DA  push 0x007f
	lda	xbc, (xiz-6)	; F0B8DD  lda XBC,XIZ+0xfa
	push	xbc	; F0B8E0  push XBC
	sub	xwa, xwa	; F0B8E1  sub XWA,XWA
	ld	(xiz-28), xwa	; F0B8E3  ld (XIZ+0xe4),XWA
	ldfr_berp	h, 0xf4	; F0B8E6  ld IYL,H
	extz	iy	; F0B8E9  extz IY
	extz	xiy	; F0B8EB  extz XIY
	add	xwa, xiy	; F0B8ED  add XWA,XIY
	extz	wa	; F0B8EF  extz WA
	pushw	wa	; F0B8F1  push WA
	pushw	0	; F0B8F2  push 0x0000
	call	ToneMsg_SendParam	; F0B8F5  call 0xfd616a
	inc	1, h	; F0B8F9  inc 1,H
	inc	8, xsp	; F0B8FB  inc 0,XSP
	inc	8, xsp	; F0B8FD  inc 0,XSP
	cp	h, 16	; F0B8FF  cp H,0x10
	jr	c, ExitKey_SoundEditNaming_Loop3	; F0B902  jr C,0xf0b8cd
	pushw	0	; F0B904  push 0x0000
	call	Var27FE_Set	; F0B907  call 0xfda341
	popw	bc	; F0B90B  pop BC
ExitKey_SoundEditNaming_Skip2:
	pushw	0	; F0B90C  push 0x0000
	pushw	158	; F0B90F  push 0x009e
	call	PanelScreen_PostRequest	; F0B912  call 0xfd608b
	pop	xiy	; F0B916  pop XIY
ExitKey_SoundEditNaming_Join2:
	pop	xix	; F0B917  pop XIX
	popw	hl	; F0B918  pop HL
	unlk XIZ	; F0B919  unlk XIZ
	ret	; F0B91B  ret

; --------------------------------------------------------------------------
; NameEntry_Begin
; Called from: T_NameEntry_Begin (x6)
; Touches: nothing with an absolute address
; Calls:   T_CallbackQueue_ResetAndRestartTask2 0xFD7BA5 0xFD7C83 T_Dispatch_Code80_Bracketed 0xFD7BC3 0xFD7BDE
; Evidence: thunk slot T_NameEntry_Begin holds `jp 0x00F0B91C`, and 0xF0B91C is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; NameEntry_Begin: Starts the shared name-entry editor: (0x27A6)[2] = field length (argument & 0x1F, at most 16), [1]
;   = NameChar index of the entry buffer's (0x22F0) first character, [0] = cursor 0; then
;   Dispatch_Code80_Bracketed(0x9F) and the dial as buttons 7/5. Called by the naming screens' ENTER (length 16, or
;   13) and the DISK SAVE password pages (2). Basis: callers + body + sibling key handlers. (wsa1/notes/naming-
;   pilot-2026-10-06/proposals_prom_b.json)
NameEntry_Begin:		; <- T_NameEntry_Begin
	link XIZ,0xfffc	; F0B91C  link XIZ,0xfffc
	pushw	hl	; F0B920  push HL
	push	xix	; F0B921  push XIX
	lda	xix, (Arr27A6_Set:24)	; F0B922  lda XIX,0xfd6c65
	call	T_CallbackQueue_ResetAndRestartTask2	; F0B927  call 0xf42e80
	ld	h, (xiz+8)	; F0B92B  ld H,(XIZ+0x08)
	and	h, 31	; F0B92E  and H,0x1f
	cp	h, 16	; F0B931  cp H,0x10
	jr	ule, NameEntry_Begin_Skip	; F0B934  jr ULE,0xf0b938
	ld	h, 16:opc	; F0B936  ld H,0x10
NameEntry_Begin_Skip:
	ld	c, h	; F0B938  ld C,H
	extz	bc	; F0B93A  extz BC
	pushw	bc	; F0B93C  push BC
	pushw	2	; F0B93D  push 0x0002
	lda	xiy, (NameEntry_Begin_Resume:24)	; F0B940  lda XIY,0xf0b948
	push	xiy	; F0B945  push XIY
	jp	(xix)	; F0B946  jp T,XIX
NameEntry_Begin_Resume:
	lda	xbc, (xiz-2)	; F0B948  lda XBC,XIZ+0xfe
	push	xbc	; F0B94B  push XBC
	pushw	0	; F0B94C  push 0x0000
	call	Arr22F0_Get	; F0B94F  call 0xfd7ba5
	lda	xbc, (xiz-4)	; F0B953  lda XBC,XIZ+0xfc
	push	xbc	; F0B956  push XBC
	ld	wa, (xiz-2)	; F0B957  ld WA,(XIZ+0xfe)
	extz	wa	; F0B95A  extz WA
	pushw	wa	; F0B95C  push WA
	call	NameChar_AsciiToIndexClamped	; F0B95D  call 0xfd7c83
	ld	bc, (xiz-4)	; F0B961  ld BC,(XIZ+0xfc)
	extz	bc	; F0B964  extz BC
	pushw	bc	; F0B966  push BC
	pushw	1	; F0B967  push 0x0001
	lda	xiy, (NameEntry_Begin_Resume2:24)	; F0B96A  lda XIY,0xf0b972
	push	xiy	; F0B96F  push XIY
	jp	(xix)	; F0B970  jp T,XIX
NameEntry_Begin_Resume2:
	pushw	0	; F0B972  push 0x0000
	pushw	0	; F0B975  push 0x0000
	lda	xiy, (NameEntry_Begin_Resume3:24)	; F0B978  lda XIY,0xf0b980
	push	xiy	; F0B97D  push XIY
	jp	(xix)	; F0B97E  jp T,XIX
NameEntry_Begin_Resume3:
	pushw	159	; F0B980  push 0x009f
	call	T_Dispatch_Code80_Bracketed	; F0B983  call 0xf41ed0
	pushw	1	; F0B987  push 0x0001
	call	PanelDial_SetButtonMode	; F0B98A  call 0xfd7bc3
	pushw	0	; F0B98E  push 0x0000
	pushw	8	; F0B991  push 0x0008
	pushw	0	; F0B994  push 0x0000
	call	PanelDial_SetDirectionButton	; F0B997  call 0xfd7bde
	pushw	0	; F0B99B  push 0x0000
	pushw	6	; F0B99E  push 0x0006
	pushw	1	; F0B9A1  push 0x0001
	call	PanelDial_SetDirectionButton	; F0B9A4  call 0xfd7bde
	add	xsp, 40	; F0B9A8  add XSP,0x00000028
	pop	xix	; F0B9AE  pop XIX
	popw	hl	; F0B9AF  pop HL
	unlk XIZ	; F0B9B0  unlk XIZ
	ret	; F0B9B2  ret

; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol1
; Called from: T_SoundEditNaming_SoftKeyCol1 (x3); in-module: 0xF0B70F
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD6C65 0xFD7BA5 0xFD7C83 T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_SoftKeyCol1 holds `jp 0x00F0B9B3`, and 0xF0B9B3 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol1: the SoftKeyCol1 action of SoundEditNaming -- called only by SoftKeyCol1_SoundEditNaming.
SoundEditNaming_SoftKeyCol1:		; <- T_SoundEditNaming_SoftKeyCol1
	link XIZ,0xfffa	; F0B9B3  link XIZ,0xfffa
	lda	xbc, (xiz-2)	; F0B9B7  lda XBC,XIZ+0xfe
	push	xbc	; F0B9BA  push XBC
	pushw	0	; F0B9BB  push 0x0000
	call	Arr27A6_Get	; F0B9BE  call 0xfd6c7b
	inc	6, xsp	; F0B9C2  inc 6,XSP
	cp	(xiz-2), 0x00	; F0B9C4  cp (XIZ+0xfe),0x00
	jr	z, SoundEditNaming_SoftKeyCol1_Skip	; F0B9C8  jr Z,0xf0ba1d
	decm8	1, (xiz-2)	; F0B9CA  dec 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F0B9CD  ld BC,(XIZ+0xfe)
	extz	bc	; F0B9D0  extz BC
	pushw	bc	; F0B9D2  push BC
	pushw	0	; F0B9D3  push 0x0000
	call	Arr27A6_Set	; F0B9D6  call 0xfd6c65
	lda	xbc, (xiz-4)	; F0B9DA  lda XBC,XIZ+0xfc
	push	xbc	; F0B9DD  push XBC
	ld	wa, (xiz-2)	; F0B9DE  ld WA,(XIZ+0xfe)
	extz	wa	; F0B9E1  extz WA
	pushw	wa	; F0B9E3  push WA
	call	Arr22F0_Get	; F0B9E4  call 0xfd7ba5
	lda	xbc, (xiz-6)	; F0B9E8  lda XBC,XIZ+0xfa
	push	xbc	; F0B9EB  push XBC
	ld	a, (xiz-4)	; F0B9EC  ld A,(XIZ+0xfc)
	extz	wa	; F0B9EF  extz WA
	pushw	wa	; F0B9F1  push WA
	call	NameChar_AsciiToIndexClamped	; F0B9F2  call 0xfd7c83
	ld	bc, (xiz-6)	; F0B9F6  ld BC,(XIZ+0xfa)
	extz	bc	; F0B9F9  extz BC
	pushw	bc	; F0B9FB  push BC
	pushw	1	; F0B9FC  push 0x0001
	call	Arr27A6_Set	; F0B9FF  call 0xfd6c65
	pushw	0	; F0BA03  push 0x0000
	pushw	159	; F0BA06  push 0x009f
	call	T_Dispatch_Code80	; F0BA09  call 0xf41ed4
	pushw	1	; F0BA0D  push 0x0001
	pushw	159	; F0BA10  push 0x009f
	call	T_Dispatch_Code80	; F0BA13  call 0xf41ed4
	add	xsp, 28	; F0BA17  add XSP,0x0000001c
SoundEditNaming_SoftKeyCol1_Skip:
	unlk XIZ	; F0BA1D  unlk XIZ
	ret	; F0BA1F  ret

; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol2
; Called from: T_SoundEditNaming_SoftKeyCol2 (x3); in-module: 0xF0B713
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD6C65 0xFD7BA5 0xFD7C83 T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_SoftKeyCol2 holds `jp 0x00F0BA20`, and 0xF0BA20 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol2: the SoftKeyCol2 action of SoundEditNaming -- called only by SoftKeyCol2_SoundEditNaming.
SoundEditNaming_SoftKeyCol2:		; <- T_SoundEditNaming_SoftKeyCol2
	link XIZ,0xfff8	; F0BA20  link XIZ,0xfff8
	pushw	hl	; F0BA24  push HL
	lda	xbc, (xiz-2)	; F0BA25  lda XBC,XIZ+0xfe
	push	xbc	; F0BA28  push XBC
	pushw	0	; F0BA29  push 0x0000
	call	Arr27A6_Get	; F0BA2C  call 0xfd6c7b
	lda	xbc, (xiz-4)	; F0BA30  lda XBC,XIZ+0xfc
	push	xbc	; F0BA33  push XBC
	pushw	2	; F0BA34  push 0x0002
	call	Arr27A6_Get	; F0BA37  call 0xfd6c7b
	ld	bc, (xiz-4)	; F0BA3B  ld BC,(XIZ+0xfc)
	extz	bc	; F0BA3E  extz BC
	ld	hl, bc	; F0BA40  ld HL,BC
	dec	1, hl	; F0BA42  dec 1,HL
	ld	bc, (xiz-2)	; F0BA44  ld BC,(XIZ+0xfe)
	extz	bc	; F0BA47  extz BC
	inc	8, xsp	; F0BA49  inc 0,XSP
	inc	4, xsp	; F0BA4B  inc 4,XSP
	cp	bc, hl	; F0BA4D  cp BC,HL
	jr	nc, SoundEditNaming_SoftKeyCol2_Skip	; F0BA4F  jr NC,0xf0baa4
	incm8	1, (xiz-2)	; F0BA51  inc 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F0BA54  ld BC,(XIZ+0xfe)
	extz	bc	; F0BA57  extz BC
	pushw	bc	; F0BA59  push BC
	pushw	0	; F0BA5A  push 0x0000
	call	Arr27A6_Set	; F0BA5D  call 0xfd6c65
	lda	xbc, (xiz-6)	; F0BA61  lda XBC,XIZ+0xfa
	push	xbc	; F0BA64  push XBC
	ld	wa, (xiz-2)	; F0BA65  ld WA,(XIZ+0xfe)
	extz	wa	; F0BA68  extz WA
	pushw	wa	; F0BA6A  push WA
	call	Arr22F0_Get	; F0BA6B  call 0xfd7ba5
	lda	xbc, (xiz-8)	; F0BA6F  lda XBC,XIZ+0xf8
	push	xbc	; F0BA72  push XBC
	ld	a, (xiz-6)	; F0BA73  ld A,(XIZ+0xfa)
	extz	wa	; F0BA76  extz WA
	pushw	wa	; F0BA78  push WA
	call	NameChar_AsciiToIndexClamped	; F0BA79  call 0xfd7c83
	ld	bc, (xiz-8)	; F0BA7D  ld BC,(XIZ+0xf8)
	extz	bc	; F0BA80  extz BC
	pushw	bc	; F0BA82  push BC
	pushw	1	; F0BA83  push 0x0001
	call	Arr27A6_Set	; F0BA86  call 0xfd6c65
	pushw	0	; F0BA8A  push 0x0000
	pushw	159	; F0BA8D  push 0x009f
	call	T_Dispatch_Code80	; F0BA90  call 0xf41ed4
	pushw	1	; F0BA94  push 0x0001
	pushw	159	; F0BA97  push 0x009f
	call	T_Dispatch_Code80	; F0BA9A  call 0xf41ed4
	add	xsp, 28	; F0BA9E  add XSP,0x0000001c
SoundEditNaming_SoftKeyCol2_Skip:
	popw	hl	; F0BAA4  pop HL
	unlk XIZ	; F0BAA5  unlk XIZ
	ret	; F0BAA7  ret

; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol3
; Called from: T_SoundEditNaming_SoftKeyCol3 (x3); in-module: 0xF0B717
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7BA5 0xFD77B3 0xFD7C83 0xFD6C65 T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_SoftKeyCol3 holds `jp 0x00F0BAA8`, and 0xF0BAA8 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol3: the SoftKeyCol3 action of SoundEditNaming -- called only by SoftKeyCol3_SoundEditNaming.
SoundEditNaming_SoftKeyCol3:		; <- T_SoundEditNaming_SoftKeyCol3
	link XIZ,0xffde	; F0BAA8  link XIZ,0xffde
	pushw	hl	; F0BAAC  push HL
	pushw	de	; F0BAAD  push DE
	push	xix	; F0BAAE  push XIX
	lda	xbc, (xiz-2)	; F0BAAF  lda XBC,XIZ+0xfe
	push	xbc	; F0BAB2  push XBC
	pushw	2	; F0BAB3  push 0x0002
	call	Arr27A6_Get	; F0BAB6  call 0xfd6c7b
	ld	d, 0:opc	; F0BABA  ld D,0x00
	inc	6, xsp	; F0BABC  inc 6,XSP
SoundEditNaming_SoftKeyCol3_Loop:
	ld	c, d	; F0BABE  ld C,D
	extz	bc	; F0BAC0  extz BC
	extz	xbc	; F0BAC2  extz XBC
	add	xbc, xiz	; F0BAC4  add XBC,XIZ
	add	xbc, 4294967272	; F0BAC6  add XBC,0xffffffe8
	push	xbc	; F0BACC  push XBC
	ld	c, d	; F0BACD  ld C,D
	extz	bc	; F0BACF  extz BC
	pushw	bc	; F0BAD1  push BC
	call	Arr22F0_Get	; F0BAD2  call 0xfd7ba5
	inc	1, d	; F0BAD6  inc 1,D
	inc	6, xsp	; F0BAD8  inc 6,XSP
	cp	d, 15	; F0BADA  cp D,0x0f
	jr	ule, SoundEditNaming_SoftKeyCol3_Loop	; F0BADD  jr ULE,0xf0babe
	ld	bc, (xiz-2)	; F0BADF  ld BC,(XIZ+0xfe)
	extz	bc	; F0BAE2  extz BC
	extz	xbc	; F0BAE4  extz XBC
	dec	1, xbc	; F0BAE6  dec 1,XBC
	add	xbc, xiz	; F0BAE8  add XBC,XIZ
	ld	a, (xbc-24)	; F0BAEA  ld A,(XBC+0xe8)
	cp	a, 32	; F0BAED  cp A,0x20
	jrl	nz, SoundEditNaming_SoftKeyCol3_Skip2	; F0BAF0  jrl NZ,0xf0bbae
	lda	xbc, (xiz-4)	; F0BAF3  lda XBC,XIZ+0xfc
	push	xbc	; F0BAF6  push XBC
	pushw	0	; F0BAF7  push 0x0000
	call	Arr27A6_Get	; F0BAFA  call 0xfd6c7b
	ld	d, 0:opc	; F0BAFE  ld D,0x00
	ld	bc, (xiz-4)	; F0BB00  ld BC,(XIZ+0xfc)
	extz	bc	; F0BB03  extz BC
	ld	(xiz-26), bc	; F0BB05  ld (XIZ+0xe6),BC
	ld	wa, (xiz-2)	; F0BB08  ld WA,(XIZ+0xfe)
	extz	wa	; F0BB0B  extz WA
	ld	(xiz-28), wa	; F0BB0D  ld (XIZ+0xe4),WA
	ld	iy, (xiz-2)	; F0BB10  ld IY,(XIZ+0xfe)
	extz	iy	; F0BB13  extz IY
	extz	xiy	; F0BB15  extz XIY
	ld	(xiz-32), xiy	; F0BB17  ld (XIZ+0xe0),XIY
	sub	wa, bc	; F0BB1A  sub WA,BC
	ld	(xiz-34), wa	; F0BB1C  ld (XIZ+0xde),WA
	ld	xix, xiy	; F0BB1F  ld XIX,XIY
	dec	1, xix	; F0BB21  dec 1,XIX
	ld	hl, wa	; F0BB23  ld HL,WA
	dec	1, hl	; F0BB25  dec 1,HL
	inc	6, xsp	; F0BB27  inc 6,XSP
SoundEditNaming_SoftKeyCol3_Join:
	ld	c, d	; F0BB29  ld C,D
	extz	bc	; F0BB2B  extz BC
	cp	bc, hl	; F0BB2D  cp BC,HL
	jr	nc, SoundEditNaming_SoftKeyCol3_Skip	; F0BB2F  jr NC,0xf0bb53
	ld	c, d	; F0BB31  ld C,D
	extz	bc	; F0BB33  extz BC
	extz	xbc	; F0BB35  extz XBC
	ld	xwa, xix	; F0BB37  ld XWA,XIX
	sub	xwa, xbc	; F0BB39  sub XWA,XBC
	ld	(xiz-28), xwa	; F0BB3B  ld (XIZ+0xe4),XWA
	dec	1, xwa	; F0BB3E  dec 1,XWA
	add	xwa, xiz	; F0BB40  add XWA,XIZ
	ld	c, (xwa-24)	; F0BB42  ld C,(XWA+0xe8)
	ld	e, c	; F0BB45  ld E,C
	ld	xbc, (xiz-28)	; F0BB47  ld XBC,(XIZ+0xe4)
	add	xbc, xiz	; F0BB4A  add XBC,XIZ
	ld	(xbc-24), e	; F0BB4C  ld (XBC+0xe8),E
	inc	1, d	; F0BB4F  inc 1,D
	jr	SoundEditNaming_SoftKeyCol3_Join	; F0BB51  jr T,0xf0bb29
SoundEditNaming_SoftKeyCol3_Skip:
	ld	bc, (xiz-4)	; F0BB53  ld BC,(XIZ+0xfc)
	extz	bc	; F0BB56  extz BC
	extz	xbc	; F0BB58  extz XBC
	add	xbc, xiz	; F0BB5A  add XBC,XIZ
	ld	(xbc-24), 32	; F0BB5C  ld (XBC+0xe8),0x20
	pushw	16	; F0BB60  push 0x0010
	lda	xbc, (xiz-24)	; F0BB63  lda XBC,XIZ+0xe8
	push	xbc	; F0BB66  push XBC
	pushw	1	; F0BB67  push 0x0001
	call	SoundEditText_SetSlot	; F0BB6A  call 0xfd77b3
	lda	xbc, (xiz-6)	; F0BB6E  lda XBC,XIZ+0xfa
	push	xbc	; F0BB71  push XBC
	ld	wa, (xiz-4)	; F0BB72  ld WA,(XIZ+0xfc)
	extz	wa	; F0BB75  extz WA
	extz	xwa	; F0BB77  extz XWA
	add	xwa, xiz	; F0BB79  add XWA,XIZ
	ld	w, (xwa-24)	; F0BB7B  ld W,(XWA+0xe8)
	ld	a, w	; F0BB7E  ld A,W
	extz	wa	; F0BB80  extz WA
	pushw	wa	; F0BB82  push WA
	call	NameChar_AsciiToIndexClamped	; F0BB83  call 0xfd7c83
	ld	bc, (xiz-6)	; F0BB87  ld BC,(XIZ+0xfa)
	extz	bc	; F0BB8A  extz BC
	pushw	bc	; F0BB8C  push BC
	pushw	1	; F0BB8D  push 0x0001
	call	Arr27A6_Set	; F0BB90  call 0xfd6c65
	pushw	0	; F0BB94  push 0x0000
	pushw	159	; F0BB97  push 0x009f
	call	T_Dispatch_Code80	; F0BB9A  call 0xf41ed4
	pushw	1	; F0BB9E  push 0x0001
	pushw	159	; F0BBA1  push 0x009f
	call	T_Dispatch_Code80	; F0BBA4  call 0xf41ed4
	add	xsp, 26	; F0BBA8  add XSP,0x0000001a
SoundEditNaming_SoftKeyCol3_Skip2:
	pop	xix	; F0BBAE  pop XIX
	popw	de	; F0BBAF  pop DE
	popw	hl	; F0BBB0  pop HL
	unlk XIZ	; F0BBB1  unlk XIZ
	ret	; F0BBB3  ret

; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol4
; Called from: T_SoundEditNaming_SoftKeyCol4 (x3); in-module: 0xF0B71B
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7BA5 0xFD77B3 0xFD7C83 0xFD6C65 T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_SoftKeyCol4 holds `jp 0x00F0BBB4`, and 0xF0BBB4 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol4: the SoftKeyCol4 action of SoundEditNaming -- called only by SoftKeyCol4_SoundEditNaming.
SoundEditNaming_SoftKeyCol4:		; <- T_SoundEditNaming_SoftKeyCol4
	link XIZ,0xffe4	; F0BBB4  link XIZ,0xffe4
	pushw	hl	; F0BBB8  push HL
	pushw	de	; F0BBB9  push DE
	push	xix	; F0BBBA  push XIX
	lda	xbc, (xiz-2)	; F0BBBB  lda XBC,XIZ+0xfe
	push	xbc	; F0BBBE  push XBC
	pushw	2	; F0BBBF  push 0x0002
	call	Arr27A6_Get	; F0BBC2  call 0xfd6c7b
	ld	d, 0:opc	; F0BBC6  ld D,0x00
	inc	6, xsp	; F0BBC8  inc 6,XSP
SoundEditNaming_SoftKeyCol4_Loop:
	ld	c, d	; F0BBCA  ld C,D
	extz	bc	; F0BBCC  extz BC
	extz	xbc	; F0BBCE  extz XBC
	add	xbc, xiz	; F0BBD0  add XBC,XIZ
	add	xbc, 4294967272	; F0BBD2  add XBC,0xffffffe8
	push	xbc	; F0BBD8  push XBC
	ld	c, d	; F0BBD9  ld C,D
	extz	bc	; F0BBDB  extz BC
	pushw	bc	; F0BBDD  push BC
	call	Arr22F0_Get	; F0BBDE  call 0xfd7ba5
	inc	1, d	; F0BBE2  inc 1,D
	inc	6, xsp	; F0BBE4  inc 6,XSP
	cp	d, 15	; F0BBE6  cp D,0x0f
	jr	ule, SoundEditNaming_SoftKeyCol4_Loop	; F0BBE9  jr ULE,0xf0bbca
	lda	xbc, (xiz-4)	; F0BBEB  lda XBC,XIZ+0xfc
	push	xbc	; F0BBEE  push XBC
	pushw	0	; F0BBEF  push 0x0000
	call	Arr27A6_Get	; F0BBF2  call 0xfd6c7b
	ld	d, (xiz-4)	; F0BBF6  ld D,(XIZ+0xfc)
	ld	hl, (xiz-2)	; F0BBF9  ld HL,(XIZ+0xfe)
	extz	hl	; F0BBFC  extz HL
	dec	1, hl	; F0BBFE  dec 1,HL
	ld	c, d	; F0BC00  ld C,D
	extz	bc	; F0BC02  extz BC
	extz	xbc	; F0BC04  extz XBC
	ld	xix, xbc	; F0BC06  ld XIX,XBC
	inc	1, xbc	; F0BC08  inc 1,XBC
	ld	xix, xbc	; F0BC0A  ld XIX,XBC
	inc	6, xsp	; F0BC0C  inc 6,XSP
SoundEditNaming_SoftKeyCol4_Join:
	ld	c, d	; F0BC0E  ld C,D
	extz	bc	; F0BC10  extz BC
	cp	bc, hl	; F0BC12  cp BC,HL
	jr	nc, SoundEditNaming_SoftKeyCol4_Skip	; F0BC14  jr NC,0xf0bc35
	ld	(xiz-28), xix	; F0BC16  ld (XIZ+0xe4),XIX
	ld	xbc, (xiz-28)	; F0BC19  ld XBC,(XIZ+0xe4)
	add	xbc, xiz	; F0BC1C  add XBC,XIZ
	ld	e, (xbc-24)	; F0BC1E  ld E,(XBC+0xe8)
	ld	c, d	; F0BC21  ld C,D
	extz	bc	; F0BC23  extz BC
	extz	xbc	; F0BC25  extz XBC
	add	xbc, xiz	; F0BC27  add XBC,XIZ
	ld	(xbc-24), e	; F0BC29  ld (XBC+0xe8),E
	ld	xix, (xiz-28)	; F0BC2C  ld XIX,(XIZ+0xe4)
	inc	1, xix	; F0BC2F  inc 1,XIX
	inc	1, d	; F0BC31  inc 1,D
	jr	SoundEditNaming_SoftKeyCol4_Join	; F0BC33  jr T,0xf0bc0e
SoundEditNaming_SoftKeyCol4_Skip:
	ld	bc, (xiz-2)	; F0BC35  ld BC,(XIZ+0xfe)
	extz	bc	; F0BC38  extz BC
	extz	xbc	; F0BC3A  extz XBC
	dec	1, xbc	; F0BC3C  dec 1,XBC
	add	xbc, xiz	; F0BC3E  add XBC,XIZ
	ld	(xbc-24), 32	; F0BC40  ld (XBC+0xe8),0x20
	pushw	16	; F0BC44  push 0x0010
	lda	xbc, (xiz-24)	; F0BC47  lda XBC,XIZ+0xe8
	push	xbc	; F0BC4A  push XBC
	pushw	1	; F0BC4B  push 0x0001
	call	SoundEditText_SetSlot	; F0BC4E  call 0xfd77b3
	lda	xbc, (xiz-6)	; F0BC52  lda XBC,XIZ+0xfa
	push	xbc	; F0BC55  push XBC
	ld	wa, (xiz-4)	; F0BC56  ld WA,(XIZ+0xfc)
	extz	wa	; F0BC59  extz WA
	extz	xwa	; F0BC5B  extz XWA
	add	xwa, xiz	; F0BC5D  add XWA,XIZ
	ld	w, (xwa-24)	; F0BC5F  ld W,(XWA+0xe8)
	ld	a, w	; F0BC62  ld A,W
	extz	wa	; F0BC64  extz WA
	pushw	wa	; F0BC66  push WA
	call	NameChar_AsciiToIndexClamped	; F0BC67  call 0xfd7c83
	ld	bc, (xiz-6)	; F0BC6B  ld BC,(XIZ+0xfa)
	extz	bc	; F0BC6E  extz BC
	pushw	bc	; F0BC70  push BC
	pushw	1	; F0BC71  push 0x0001
	call	Arr27A6_Set	; F0BC74  call 0xfd6c65
	pushw	0	; F0BC78  push 0x0000
	pushw	159	; F0BC7B  push 0x009f
	call	T_Dispatch_Code80	; F0BC7E  call 0xf41ed4
	pushw	1	; F0BC82  push 0x0001
	pushw	159	; F0BC85  push 0x009f
	call	T_Dispatch_Code80	; F0BC88  call 0xf41ed4
	add	xsp, 26	; F0BC8C  add XSP,0x0000001a
	pop	xix	; F0BC92  pop XIX
	popw	de	; F0BC93  pop DE
	popw	hl	; F0BC94  pop HL
	unlk XIZ	; F0BC95  unlk XIZ
	ret	; F0BC97  ret

; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol5
; Called from: T_SoundEditNaming_SoftKeyCol5 (x3); in-module: 0xF0B71F
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7BA5 0xFD7B89 0xFD7C83 0xFD6C65 T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_SoftKeyCol5 holds `jp 0x00F0BC98`, and 0xF0BC98 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol5: the SoftKeyCol5 action of SoundEditNaming -- called only by SoftKeyCol5_SoundEditNaming.
SoundEditNaming_SoftKeyCol5:		; <- T_SoundEditNaming_SoftKeyCol5
	link XIZ,0xfffa	; F0BC98  link XIZ,0xfffa
	pushw	hl	; F0BC9C  push HL
	push	xix	; F0BC9D  push XIX
	lda	xix, (xiz-6)	; F0BC9E  lda XIX,XIZ+0xfa
	lda	xbc, (xiz-2)	; F0BCA1  lda XBC,XIZ+0xfe
	push	xbc	; F0BCA4  push XBC
	pushw	0	; F0BCA5  push 0x0000
	call	Arr27A6_Get	; F0BCA8  call 0xfd6c7b
	push	xix	; F0BCAC  push XIX
	ld	bc, (xiz-2)	; F0BCAD  ld BC,(XIZ+0xfe)
	extz	bc	; F0BCB0  extz BC
	pushw	bc	; F0BCB2  push BC
	call	Arr22F0_Get	; F0BCB3  call 0xfd7ba5
	ld	h, (xix)	; F0BCB7  ld H,(XIX)
	inc	8, xsp	; F0BCB9  inc 0,XSP
	inc	4, xsp	; F0BCBB  inc 4,XSP
	cp	h, 65	; F0BCBD  cp H,0x41
	jr	c, SoundEditNaming_SoftKeyCol5_Skip	; F0BCC0  jr C,0xf0bcd3
	cp	h, 90	; F0BCC2  cp H,0x5a
	jr	ugt, SoundEditNaming_SoftKeyCol5_Skip	; F0BCC5  jr UGT,0xf0bcd3
	ld	c, h	; F0BCC7  ld C,H
	sub	c, 65	; F0BCC9  sub C,0x41
	add	c, 97	; F0BCCC  add C,0x61
	ld	(xix), c	; F0BCCF  ld (XIX),C
	jr	SoundEditNaming_SoftKeyCol5_Join	; F0BCD1  jr T,0xf0bce9
SoundEditNaming_SoftKeyCol5_Skip:
	ld	h, (xix)	; F0BCD3  ld H,(XIX)
	cp	h, 97	; F0BCD5  cp H,0x61
	jr	c, SoundEditNaming_SoftKeyCol5_Skip2	; F0BCD8  jr C,0xf0bd2c
	cp	h, 122	; F0BCDA  cp H,0x7a
	jr	ugt, SoundEditNaming_SoftKeyCol5_Skip2	; F0BCDD  jr UGT,0xf0bd2c
	ld	c, h	; F0BCDF  ld C,H
	sub	c, 97	; F0BCE1  sub C,0x61
	add	c, 65	; F0BCE4  add C,0x41
	ld	(xix), c	; F0BCE7  ld (XIX),C
SoundEditNaming_SoftKeyCol5_Join:
	ld	c, (xix)	; F0BCE9  ld C,(XIX)
	extz	bc	; F0BCEB  extz BC
	pushw	bc	; F0BCED  push BC
	ld	bc, (xiz-2)	; F0BCEE  ld BC,(XIZ+0xfe)
	extz	bc	; F0BCF1  extz BC
	pushw	bc	; F0BCF3  push BC
	call	Arr22F0_Set	; F0BCF4  call 0xfd7b89
	lda	xbc, (xiz-4)	; F0BCF8  lda XBC,XIZ+0xfc
	push	xbc	; F0BCFB  push XBC
	ld	a, (xix)	; F0BCFC  ld A,(XIX)
	extz	wa	; F0BCFE  extz WA
	pushw	wa	; F0BD00  push WA
	call	NameChar_AsciiToIndexClamped	; F0BD01  call 0xfd7c83
	ld	bc, (xiz-4)	; F0BD05  ld BC,(XIZ+0xfc)
	extz	bc	; F0BD08  extz BC
	pushw	bc	; F0BD0A  push BC
	pushw	1	; F0BD0B  push 0x0001
	call	Arr27A6_Set	; F0BD0E  call 0xfd6c65
	pushw	0	; F0BD12  push 0x0000
	pushw	159	; F0BD15  push 0x009f
	call	T_Dispatch_Code80	; F0BD18  call 0xf41ed4
	pushw	1	; F0BD1C  push 0x0001
	pushw	159	; F0BD1F  push 0x009f
	call	T_Dispatch_Code80	; F0BD22  call 0xf41ed4
	add	xsp, 22	; F0BD26  add XSP,0x00000016
SoundEditNaming_SoftKeyCol5_Skip2:
	pop	xix	; F0BD2C  pop XIX
	popw	hl	; F0BD2D  pop HL
	unlk XIZ	; F0BD2E  unlk XIZ
	ret	; F0BD30  ret

; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol6
; Called from: T_SoundEditNaming_SoftKeyCol6 (x3); in-module: 0xF0B723
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD6C65 0xFD7C5A 0xFD7B89 0xFDAC5B T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_SoftKeyCol6 holds `jp 0x00F0BD31`, and 0xF0BD31 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol6: the SoftKeyCol6 action of SoundEditNaming -- called only by SoftKeyCol6_SoundEditNaming.
SoundEditNaming_SoftKeyCol6:		; <- T_SoundEditNaming_SoftKeyCol6
	link XIZ,0xfffa	; F0BD31  link XIZ,0xfffa
	lda	xbc, (xiz-2)	; F0BD35  lda XBC,XIZ+0xfe
	push	xbc	; F0BD38  push XBC
	pushw	1	; F0BD39  push 0x0001
	call	Arr27A6_Get	; F0BD3C  call 0xfd6c7b
	inc	6, xsp	; F0BD40  inc 6,XSP
	cp	(xiz-2), 0x00	; F0BD42  cp (XIZ+0xfe),0x00
	jr	z, SoundEditNaming_SoftKeyCol6_Skip	; F0BD46  jr Z,0xf0bda9
	decm8	1, (xiz-2)	; F0BD48  dec 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F0BD4B  ld BC,(XIZ+0xfe)
	extz	bc	; F0BD4E  extz BC
	pushw	bc	; F0BD50  push BC
	pushw	1	; F0BD51  push 0x0001
	call	Arr27A6_Set	; F0BD54  call 0xfd6c65
	lda	xbc, (xiz-4)	; F0BD58  lda XBC,XIZ+0xfc
	push	xbc	; F0BD5B  push XBC
	ld	wa, (xiz-2)	; F0BD5C  ld WA,(XIZ+0xfe)
	extz	wa	; F0BD5F  extz WA
	pushw	wa	; F0BD61  push WA
	call	NameChar_IndexToAsciiOrSpace	; F0BD62  call 0xfd7c5a
	lda	xbc, (xiz-6)	; F0BD66  lda XBC,XIZ+0xfa
	push	xbc	; F0BD69  push XBC
	pushw	0	; F0BD6A  push 0x0000
	call	Arr27A6_Get	; F0BD6D  call 0xfd6c7b
	ld	c, (xiz-4)	; F0BD71  ld C,(XIZ+0xfc)
	extz	bc	; F0BD74  extz BC
	pushw	bc	; F0BD76  push BC
	ld	bc, (xiz-6)	; F0BD77  ld BC,(XIZ+0xfa)
	extz	bc	; F0BD7A  extz BC
	pushw	bc	; F0BD7C  push BC
	call	Arr22F0_Set	; F0BD7D  call 0xfd7b89
	pushw	1	; F0BD81  push 0x0001
	call	LCD_SetPanelDarkFlag	; F0BD84  call 0xfdac5b
	pushw	0	; F0BD88  push 0x0000
	pushw	159	; F0BD8B  push 0x009f
	call	T_Dispatch_Code80	; F0BD8E  call 0xf41ed4
	pushw	1	; F0BD92  push 0x0001
	pushw	159	; F0BD95  push 0x009f
	call	T_Dispatch_Code80	; F0BD98  call 0xf41ed4
	pushw	0	; F0BD9C  push 0x0000
	call	LCD_SetPanelDarkFlag	; F0BD9F  call 0xfdac5b
	add	xsp, 32	; F0BDA3  add XSP,0x00000020
SoundEditNaming_SoftKeyCol6_Skip:
	unlk XIZ	; F0BDA9  unlk XIZ
	ret	; F0BDAB  ret

; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol7
; Called from: T_SoundEditNaming_SoftKeyCol7 (x3); in-module: 0xF0B73F
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD6C65 0xFD7C5A 0xFD7B89 T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_SoftKeyCol7 holds `jp 0x00F0BDAC`, and 0xF0BDAC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol7: the routine directory slot between T_SoundEditNaming_SoftKeyCol6 and _SoftKeyCol8
;   (T_SoundEditNaming_SoftKeyCol7), and slot 6 of ScreenButtons_CombinationNamingWrite -- SOFT KEY 7.  Steps the character Arr27A6[1] by 16, one row of
;   the 16-wide table: down to >= 0, or up (argument bit 15) to <= 95; then NameChar_IndexToAsciiOrSpace, Arr22F0_Set and two
;   T_Dispatch_Code80(159) posts, as SoundEditNaming_SoftKeyCol6 does after its step of 1.  Also called by SoftKeyCol7_SoundEditNaming.
SoundEditNaming_SoftKeyCol7:		; <- T_SoundEditNaming_SoftKeyCol7
	link XIZ,0xfffa	; F0BDAC  link XIZ,0xfffa
	pushw	hl	; F0BDB0  push HL
	ld	h, 0:opc	; F0BDB1  ld H,0x00
	ld	bc, (xiz+8)	; F0BDB3  ld BC,(XIZ+0x08)
	and	bc, 32768	; F0BDB6  and BC,0x8000
	jr	z, SoundEditNaming_SoftKeyCol7_Skip	; F0BDBA  jr Z,0xf0bdbe
	ld	h, 1:opc	; F0BDBC  ld H,0x01
SoundEditNaming_SoftKeyCol7_Skip:
	lda	xbc, (xiz-2)	; F0BDBE  lda XBC,XIZ+0xfe
	push	xbc	; F0BDC1  push XBC
	pushw	1	; F0BDC2  push 0x0001
	call	Arr27A6_Get	; F0BDC5  call 0xfd6c7b
	inc	6, xsp	; F0BDC9  inc 6,XSP
	cp	h, 0:i3	; F0BDCB  cp H,0
	jr	nz, SoundEditNaming_SoftKeyCol7_Skip2	; F0BDCD  jr NZ,0xf0bddd
	cp	(xiz-2), 0x10	; F0BDCF  cp (XIZ+0xfe),0x10
	jrl	c, SoundEditNaming_SoftKeyCol7_Skip3	; F0BDD3  jrl C,0xf0be40
	ld	c, 16:opc	; F0BDD6  ld C,0x10
	sub	(xiz-2), c	; F0BDD8  sub (XIZ+0xfe),C
	jr	SoundEditNaming_SoftKeyCol7_Join	; F0BDDB  jr T,0xf0bdf0
SoundEditNaming_SoftKeyCol7_Skip2:
	ld	bc, (xiz-2)	; F0BDDD  ld BC,(XIZ+0xfe)
	extz	bc	; F0BDE0  extz BC
	add	bc, 16	; F0BDE2  add BC,0x0010
	cp	bc, 95	; F0BDE6  cp BC,0x005f
	jr	ugt, SoundEditNaming_SoftKeyCol7_Skip3	; F0BDEA  jr UGT,0xf0be40
	add	(xiz-2), 0x10	; F0BDEC  add (XIZ+0xfe),0x10
SoundEditNaming_SoftKeyCol7_Join:
	ld	bc, (xiz-2)	; F0BDF0  ld BC,(XIZ+0xfe)
	extz	bc	; F0BDF3  extz BC
	pushw	bc	; F0BDF5  push BC
	pushw	1	; F0BDF6  push 0x0001
	call	Arr27A6_Set	; F0BDF9  call 0xfd6c65
	lda	xbc, (xiz-4)	; F0BDFD  lda XBC,XIZ+0xfc
	push	xbc	; F0BE00  push XBC
	ld	wa, (xiz-2)	; F0BE01  ld WA,(XIZ+0xfe)
	extz	wa	; F0BE04  extz WA
	pushw	wa	; F0BE06  push WA
	call	NameChar_IndexToAsciiOrSpace	; F0BE07  call 0xfd7c5a
	lda	xbc, (xiz-6)	; F0BE0B  lda XBC,XIZ+0xfa
	push	xbc	; F0BE0E  push XBC
	pushw	0	; F0BE0F  push 0x0000
	call	Arr27A6_Get	; F0BE12  call 0xfd6c7b
	ld	bc, (xiz-4)	; F0BE16  ld BC,(XIZ+0xfc)
	extz	bc	; F0BE19  extz BC
	pushw	bc	; F0BE1B  push BC
	ld	bc, (xiz-6)	; F0BE1C  ld BC,(XIZ+0xfa)
	extz	bc	; F0BE1F  extz BC
	pushw	bc	; F0BE21  push BC
	call	Arr22F0_Set	; F0BE22  call 0xfd7b89
	pushw	0	; F0BE26  push 0x0000
	pushw	159	; F0BE29  push 0x009f
	call	T_Dispatch_Code80	; F0BE2C  call 0xf41ed4
	pushw	1	; F0BE30  push 0x0001
	pushw	159	; F0BE33  push 0x009f
	call	T_Dispatch_Code80	; F0BE36  call 0xf41ed4
	add	xsp, 28	; F0BE3A  add XSP,0x0000001c
SoundEditNaming_SoftKeyCol7_Skip3:
	popw	hl	; F0BE40  pop HL
	unlk XIZ	; F0BE41  unlk XIZ
	ret	; F0BE43  ret

; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol8
; Called from: T_SoundEditNaming_SoftKeyCol8 (x3); in-module: 0xF0B747
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD6C65 0xFD7C5A 0xFD7B89 0xFDAC5B T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_SoftKeyCol8 holds `jp 0x00F0BE44`, and 0xF0BE44 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_SoftKeyCol8: the SoftKeyCol8 action of SoundEditNaming -- called only by SoftKeyCol8_SoundEditNaming.
SoundEditNaming_SoftKeyCol8:		; <- T_SoundEditNaming_SoftKeyCol8
	link XIZ,0xfffa	; F0BE44  link XIZ,0xfffa
	lda	xbc, (xiz-2)	; F0BE48  lda XBC,XIZ+0xfe
	push	xbc	; F0BE4B  push XBC
	pushw	1	; F0BE4C  push 0x0001
	call	Arr27A6_Get	; F0BE4F  call 0xfd6c7b
	inc	6, xsp	; F0BE53  inc 6,XSP
	cp	(xiz-2), 0x5f	; F0BE55  cp (XIZ+0xfe),0x5f
	jr	nc, SoundEditNaming_SoftKeyCol8_Skip	; F0BE59  jr NC,0xf0bebc
	incm8	1, (xiz-2)	; F0BE5B  inc 1,(XIZ+0xfe)
	ld	bc, (xiz-2)	; F0BE5E  ld BC,(XIZ+0xfe)
	extz	bc	; F0BE61  extz BC
	pushw	bc	; F0BE63  push BC
	pushw	1	; F0BE64  push 0x0001
	call	Arr27A6_Set	; F0BE67  call 0xfd6c65
	lda	xbc, (xiz-4)	; F0BE6B  lda XBC,XIZ+0xfc
	push	xbc	; F0BE6E  push XBC
	ld	wa, (xiz-2)	; F0BE6F  ld WA,(XIZ+0xfe)
	extz	wa	; F0BE72  extz WA
	pushw	wa	; F0BE74  push WA
	call	NameChar_IndexToAsciiOrSpace	; F0BE75  call 0xfd7c5a
	lda	xbc, (xiz-6)	; F0BE79  lda XBC,XIZ+0xfa
	push	xbc	; F0BE7C  push XBC
	pushw	0	; F0BE7D  push 0x0000
	call	Arr27A6_Get	; F0BE80  call 0xfd6c7b
	ld	bc, (xiz-4)	; F0BE84  ld BC,(XIZ+0xfc)
	extz	bc	; F0BE87  extz BC
	pushw	bc	; F0BE89  push BC
	ld	bc, (xiz-6)	; F0BE8A  ld BC,(XIZ+0xfa)
	extz	bc	; F0BE8D  extz BC
	pushw	bc	; F0BE8F  push BC
	call	Arr22F0_Set	; F0BE90  call 0xfd7b89
	pushw	1	; F0BE94  push 0x0001
	call	LCD_SetPanelDarkFlag	; F0BE97  call 0xfdac5b
	pushw	0	; F0BE9B  push 0x0000
	pushw	159	; F0BE9E  push 0x009f
	call	T_Dispatch_Code80	; F0BEA1  call 0xf41ed4
	pushw	1	; F0BEA5  push 0x0001
	pushw	159	; F0BEA8  push 0x009f
	call	T_Dispatch_Code80	; F0BEAB  call 0xf41ed4
	pushw	0	; F0BEAF  push 0x0000
	call	LCD_SetPanelDarkFlag	; F0BEB2  call 0xfdac5b
	add	xsp, 32	; F0BEB6  add XSP,0x00000020
SoundEditNaming_SoftKeyCol8_Skip:
	unlk XIZ	; F0BEBC  unlk XIZ
	ret	; F0BEBE  ret

; --------------------------------------------------------------------------
; SoundEditNaming_LcdKeyRow1
; Called from: T_SoundEditNaming_LcdKeyRow1 (x6); in-module: 0xF0B757
; Touches: nothing with an absolute address
; Calls:   0xFD7B89 0xFD6C65 T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_LcdKeyRow1 holds `jp 0x00F0BEBF`, and 0xF0BEBF is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_LcdKeyRow1: the LcdKeyRow1 action of SoundEditNaming -- called only by LcdKeyRow1_SoundEditNaming.
SoundEditNaming_LcdKeyRow1:		; <- T_SoundEditNaming_LcdKeyRow1
	pushw	hl	; F0BEBF  push HL
	ld	h, 0:opc	; F0BEC0  ld H,0x00
SoundEditNaming_LcdKeyRow1_Loop:
	pushw	32	; F0BEC2  push 0x0020
	ld	c, h	; F0BEC5  ld C,H
	extz	bc	; F0BEC7  extz BC
	pushw	bc	; F0BEC9  push BC
	call	Arr22F0_Set	; F0BECA  call 0xfd7b89
	inc	1, h	; F0BECE  inc 1,H
	pop	xiy	; F0BED0  pop XIY
	cp	h, 15	; F0BED1  cp H,0x0f
	jr	ule, SoundEditNaming_LcdKeyRow1_Loop	; F0BED4  jr ULE,0xf0bec2
	pushw	0	; F0BED6  push 0x0000
	pushw	0	; F0BED9  push 0x0000
	call	Arr27A6_Set	; F0BEDC  call 0xfd6c65
	pushw	0	; F0BEE0  push 0x0000
	pushw	1	; F0BEE3  push 0x0001
	call	Arr27A6_Set	; F0BEE6  call 0xfd6c65
	pushw	0	; F0BEEA  push 0x0000
	pushw	159	; F0BEED  push 0x009f
	call	T_Dispatch_Code80	; F0BEF0  call 0xf41ed4
	pushw	1	; F0BEF4  push 0x0001
	pushw	159	; F0BEF7  push 0x009f
	call	T_Dispatch_Code80	; F0BEFA  call 0xf41ed4
	inc	8, xsp	; F0BEFE  inc 0,XSP
	inc	8, xsp	; F0BF00  inc 0,XSP
	popw	hl	; F0BF02  pop HL
	ret	; F0BF03  ret

; --------------------------------------------------------------------------
; SoundEditNaming_LcdKeyRow2
; Called from: T_SoundEditNaming_LcdKeyRow2 (x4); in-module: 0xF0B817
; Touches: nothing with an absolute address
; Calls:   0xFD6C7B 0xFD7BA5 0xFD79DC 0xFD77B3 0xFD7C83 0xFD6C65 T_Dispatch_Code80
; Evidence: thunk slot T_SoundEditNaming_LcdKeyRow2 holds `jp 0x00F0BF04`, and 0xF0BF04 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditNaming_LcdKeyRow2: the LcdKeyRow2 action of SoundEditNaming -- called only by LcdKeyRow2_SoundEditNaming.
SoundEditNaming_LcdKeyRow2:		; <- T_SoundEditNaming_LcdKeyRow2
	link XIZ,0xffd4	; F0BF04  link XIZ,0xffd4
	pushw	hl	; F0BF08  push HL
	pushw	de	; F0BF09  push DE
	push	xix	; F0BF0A  push XIX
	ld	h, 0:opc	; F0BF0B  ld H,0x00
	ld	(xiz-5), 0	; F0BF0D  ld (XIZ+0xfb),0x00
	lda	xbc, (xiz-2)	; F0BF11  lda XBC,XIZ+0xfe
	push	xbc	; F0BF14  push XBC
	pushw	2	; F0BF15  push 0x0002
	call	Arr27A6_Get	; F0BF18  call 0xfd6c7b
	lda	xbc, (xiz-4)	; F0BF1C  lda XBC,XIZ+0xfc
	push	xbc	; F0BF1F  push XBC
	pushw	0	; F0BF20  push 0x0000
	call	Arr27A6_Get	; F0BF23  call 0xfd6c7b
	inc	8, xsp	; F0BF27  inc 0,XSP
	inc	4, xsp	; F0BF29  inc 4,XSP
SoundEditNaming_LcdKeyRow2_Loop:
	ld	bc, (xiz-5)	; F0BF2B  ld BC,(XIZ+0xfb)
	extz	bc	; F0BF2E  extz BC
	extz	xbc	; F0BF30  extz XBC
	add	xbc, xiz	; F0BF32  add XBC,XIZ
	add	xbc, 4294967270	; F0BF34  add XBC,0xffffffe6
	push	xbc	; F0BF3A  push XBC
	ld	bc, (xiz-5)	; F0BF3B  ld BC,(XIZ+0xfb)
	extz	bc	; F0BF3E  extz BC
	pushw	bc	; F0BF40  push BC
	call	Arr22F0_Get	; F0BF41  call 0xfd7ba5
	incm8	1, (xiz-5)	; F0BF45  inc 1,(XIZ+0xfb)
	inc	6, xsp	; F0BF48  inc 6,XSP
	cp	(xiz-5), 0x0f	; F0BF4A  cp (XIZ+0xfb),0x0f
	jr	ule, SoundEditNaming_LcdKeyRow2_Loop	; F0BF4E  jr ULE,0xf0bf2b
	ld	(xiz-5), 0	; F0BF50  ld (XIZ+0xfb),0x00
	ld	de, (xiz-2)	; F0BF54  ld DE,(XIZ+0xfe)
	extz	de	; F0BF57  extz DE
	dec	1, de	; F0BF59  dec 1,DE
SoundEditNaming_LcdKeyRow2_Join:
	ld	bc, (xiz-5)	; F0BF5B  ld BC,(XIZ+0xfb)
	extz	bc	; F0BF5E  extz BC
	cp	bc, de	; F0BF60  cp BC,DE
	jr	ugt, SoundEditNaming_LcdKeyRow2_Join3	; F0BF62  jr UGT,0xf0bf86
	ld	bc, (xiz-5)	; F0BF64  ld BC,(XIZ+0xfb)
	extz	bc	; F0BF67  extz BC
	extz	xbc	; F0BF69  extz XBC
	add	xbc, xiz	; F0BF6B  add XBC,XIZ
	ld	a, (xbc-26)	; F0BF6D  ld A,(XBC+0xe6)
	cp	a, 32	; F0BF70  cp A,0x20
	jr	nz, SoundEditNaming_LcdKeyRow2_Skip	; F0BF73  jr NZ,0xf0bf79
	inc	1, h	; F0BF75  inc 1,H
	jr	SoundEditNaming_LcdKeyRow2_Join2	; F0BF77  jr T,0xf0bf81
SoundEditNaming_LcdKeyRow2_Skip:
	ld	c, (xiz-5)	; F0BF79  ld C,(XIZ+0xfb)
	ld	(xiz-6), c	; F0BF7C  ld (XIZ+0xfa),C
	jr	SoundEditNaming_LcdKeyRow2_Join3	; F0BF7F  jr T,0xf0bf86
SoundEditNaming_LcdKeyRow2_Join2:
	incm8	1, (xiz-5)	; F0BF81  inc 1,(XIZ+0xfb)
	jr	SoundEditNaming_LcdKeyRow2_Join	; F0BF84  jr T,0xf0bf5b
SoundEditNaming_LcdKeyRow2_Join3:
	ld	de, (xiz-2)	; F0BF86  ld DE,(XIZ+0xfe)
	extz	de	; F0BF89  extz DE
	dec	1, de	; F0BF8B  dec 1,DE
	ld	c, h	; F0BF8D  ld C,H
	extz	bc	; F0BF8F  extz BC
	cp	bc, de	; F0BF91  cp BC,DE
	jrl	ugt, SoundEditNaming_LcdKeyRow2_Skip4	; F0BF93  jrl UGT,0xf0c0b5
	ld	(xiz-5), 0	; F0BF96  ld (XIZ+0xfb),0x00
	ld	ix, (xiz-2)	; F0BF9A  ld IX,(XIZ+0xfe)
	extz	ix	; F0BF9D  extz IX
	extz	xix	; F0BF9F  extz XIX
	sub	xbc, xbc	; F0BFA1  sub XBC,XBC
	inc	1, xbc	; F0BFA3  inc 1,XBC
	sub	xix, xbc	; F0BFA5  sub XIX,XBC
SoundEditNaming_LcdKeyRow2_Join4:
	ld	bc, (xiz-5)	; F0BFA7  ld BC,(XIZ+0xfb)
	extz	bc	; F0BFAA  extz BC
	cp	bc, de	; F0BFAC  cp BC,DE
	jr	ugt, SoundEditNaming_LcdKeyRow2_Skip2	; F0BFAE  jr UGT,0xf0bfcc
	ld	bc, (xiz-5)	; F0BFB0  ld BC,(XIZ+0xfb)
	extz	bc	; F0BFB3  extz BC
	extz	xbc	; F0BFB5  extz XBC
	ld	xwa, xix	; F0BFB7  ld XWA,XIX
	sub	xwa, xbc	; F0BFB9  sub XWA,XBC
	add	xwa, xiz	; F0BFBB  add XWA,XIZ
	ld	c, (xwa-26)	; F0BFBD  ld C,(XWA+0xe6)
	cp	c, 32	; F0BFC0  cp C,0x20
	jr	nz, SoundEditNaming_LcdKeyRow2_Skip2	; F0BFC3  jr NZ,0xf0bfcc
	inc	1, h	; F0BFC5  inc 1,H
	incm8	1, (xiz-5)	; F0BFC7  inc 1,(XIZ+0xfb)
	jr	SoundEditNaming_LcdKeyRow2_Join4	; F0BFCA  jr T,0xf0bfa7
SoundEditNaming_LcdKeyRow2_Skip2:
	ld	de, (xiz-2)	; F0BFCC  ld DE,(XIZ+0xfe)
	extz	de	; F0BFCF  extz DE
	ld	c, h	; F0BFD1  ld C,H
	extz	bc	; F0BFD3  extz BC
	ld	wa, de	; F0BFD5  ld WA,DE
	sub	wa, bc	; F0BFD7  sub WA,BC
	ld	l, a	; F0BFD9  ld L,A
	ld	c, h	; F0BFDB  ld C,H
	srl	c, 1	; F0BFDD  srl 0x01,C
	ld	h, c	; F0BFE0  ld H,C
	pushw	16	; F0BFE2  push 0x0010
	lda	xbc, (xiz-26)	; F0BFE5  lda XBC,XIZ+0xe6
	push	xbc	; F0BFE8  push XBC
	lda	xwa, (xiz-44)	; F0BFE9  lda XWA,XIZ+0xd4
	push	xwa	; F0BFEC  push XWA
	call	Mem_CopyBytes	; F0BFED  call 0xfd79dc
	ld	(xiz-5), 0	; F0BFF1  ld (XIZ+0xfb),0x00
	inc	8, xsp	; F0BFF5  inc 0,XSP
	inc	2, xsp	; F0BFF7  inc 2,XSP
	jr	SoundEditNaming_LcdKeyRow2_Join5	; F0BFF9  jr T,0xf0c00b
SoundEditNaming_LcdKeyRow2_Loop2:
	ld	bc, (xiz-5)	; F0BFFB  ld BC,(XIZ+0xfb)
	extz	bc	; F0BFFE  extz BC
	extz	xbc	; F0C000  extz XBC
	add	xbc, xiz	; F0C002  add XBC,XIZ
	ld	(xbc-44), 32	; F0C004  ld (XBC+0xd4),0x20
	incm8	1, (xiz-5)	; F0C008  inc 1,(XIZ+0xfb)
SoundEditNaming_LcdKeyRow2_Join5:
	ld	c, (xiz-5)	; F0C00B  ld C,(XIZ+0xfb)
	cp	c, h	; F0C00E  cp C,H
	jr	c, SoundEditNaming_LcdKeyRow2_Loop2	; F0C010  jr C,0xf0bffb
	ld	c, l	; F0C012  ld C,L
	extz	bc	; F0C014  extz BC
	pushw	bc	; F0C016  push BC
	ld	bc, (xiz-6)	; F0C017  ld BC,(XIZ+0xfa)
	extz	bc	; F0C01A  extz BC
	extz	xbc	; F0C01C  extz XBC
	add	xbc, xiz	; F0C01E  add XBC,XIZ
	add	xbc, 4294967270	; F0C020  add XBC,0xffffffe6
	push	xbc	; F0C026  push XBC
	ld	c, h	; F0C027  ld C,H
	extz	bc	; F0C029  extz BC
	extz	xbc	; F0C02B  extz XBC
	add	xbc, xiz	; F0C02D  add XBC,XIZ
	add	xbc, 4294967252	; F0C02F  add XBC,0xffffffd4
	push	xbc	; F0C035  push XBC
	call	Mem_CopyBytes	; F0C036  call 0xfd79dc
	ld	c, h	; F0C03A  ld C,H
	add	c, l	; F0C03C  add C,L
	ld	(xiz-5), c	; F0C03E  ld (XIZ+0xfb),C
	ld	hl, (xiz-2)	; F0C041  ld HL,(XIZ+0xfe)
	extz	hl	; F0C044  extz HL
	dec	1, hl	; F0C046  dec 1,HL
	inc	8, xsp	; F0C048  inc 0,XSP
	inc	2, xsp	; F0C04A  inc 2,XSP
SoundEditNaming_LcdKeyRow2_Join6:
	ld	bc, (xiz-5)	; F0C04C  ld BC,(XIZ+0xfb)
	extz	bc	; F0C04F  extz BC
	cp	bc, hl	; F0C051  cp BC,HL
	jr	ugt, SoundEditNaming_LcdKeyRow2_Skip3	; F0C053  jr UGT,0xf0c067
	ld	bc, (xiz-5)	; F0C055  ld BC,(XIZ+0xfb)
	extz	bc	; F0C058  extz BC
	extz	xbc	; F0C05A  extz XBC
	add	xbc, xiz	; F0C05C  add XBC,XIZ
	ld	(xbc-44), 32	; F0C05E  ld (XBC+0xd4),0x20
	incm8	1, (xiz-5)	; F0C062  inc 1,(XIZ+0xfb)
	jr	SoundEditNaming_LcdKeyRow2_Join6	; F0C065  jr T,0xf0c04c
SoundEditNaming_LcdKeyRow2_Skip3:
	pushw	16	; F0C067  push 0x0010
	lda	xbc, (xiz-44)	; F0C06A  lda XBC,XIZ+0xd4
	push	xbc	; F0C06D  push XBC
	pushw	1	; F0C06E  push 0x0001
	call	SoundEditText_SetSlot	; F0C071  call 0xfd77b3
	lda	xbc, (xiz-8)	; F0C075  lda XBC,XIZ+0xf8
	push	xbc	; F0C078  push XBC
	ld	wa, (xiz-4)	; F0C079  ld WA,(XIZ+0xfc)
	extz	wa	; F0C07C  extz WA
	extz	xwa	; F0C07E  extz XWA
	add	xwa, xiz	; F0C080  add XWA,XIZ
	ld	w, (xwa-44)	; F0C082  ld W,(XWA+0xd4)
	ld	a, w	; F0C085  ld A,W
	extz	wa	; F0C087  extz WA
	pushw	wa	; F0C089  push WA
	call	NameChar_AsciiToIndexClamped	; F0C08A  call 0xfd7c83
	ld	bc, (xiz-8)	; F0C08E  ld BC,(XIZ+0xf8)
	extz	bc	; F0C091  extz BC
	pushw	bc	; F0C093  push BC
	pushw	1	; F0C094  push 0x0001
	call	Arr27A6_Set	; F0C097  call 0xfd6c65
	pushw	0	; F0C09B  push 0x0000
	pushw	159	; F0C09E  push 0x009f
	call	T_Dispatch_Code80	; F0C0A1  call 0xf41ed4
	pushw	1	; F0C0A5  push 0x0001
	pushw	159	; F0C0A8  push 0x009f
	call	T_Dispatch_Code80	; F0C0AB  call 0xf41ed4
	add	xsp, 26	; F0C0AF  add XSP,0x0000001a
SoundEditNaming_LcdKeyRow2_Skip4:
	pop	xix	; F0C0B5  pop XIX
	popw	de	; F0C0B6  pop DE
	popw	hl	; F0C0B7  pop HL
	unlk XIZ	; F0C0B8  unlk XIZ
	ret	; F0C0BA  ret

; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditCopy
; Called from: table 0xFCF80C[270]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD6C7B T_Dispatch_Code80 SoundEditCopy_ResolveSelectedSound 0xFD7ADD T_SoundSel_ToProgramAndBank 0xFD7B00
;          0xFD648D 0xFD7C01
; Evidence: word [270] of the pointer table at 0xFCF80C reads 0x00F0C0BB, that
;           table's reader TRANSFERS to the word it loads, and 0xF0C0BB is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol1_SoundEditCopy: SOFT KEY column 1 (lower or upper; the flag carries which) on ScreenCode9D -- ScreenCode9D op 0 (PanelOpTable_FCFC44).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol1_SoundEditCopy:
	link XIZ,0xfff0	; F0C0BB  link XIZ,0xfff0
	pushw	hl	; F0C0BF  push HL
	pushw	de	; F0C0C0  push DE
	push	xix	; F0C0C1  push XIX
	lda	xix, (Arr27A6_Set:24)	; F0C0C2  lda XIX,0xfd6c65
	lda	xbc, (xiz-2)	; F0C0C7  lda XBC,XIZ+0xfe
	push	xbc	; F0C0CA  push XBC
	call	Var27F5_Get	; F0C0CB  call 0xfda0ca
	ld	h, (xiz+8)	; F0C0CF  ld H,(XIZ+0x08)
	res	7, h	; F0C0D2  res 0x07,H
	pop	xiy	; F0C0D5  pop XIY
	cp	(xiz-2), 0x00	; F0C0D6  cp (XIZ+0xfe),0x00
	jrl	nz, SoftKeyCol1_SoundEditCopy_Skip6	; F0C0DA  jrl NZ,0xf0c173
	lda	xbc, (xiz-4)	; F0C0DD  lda XBC,XIZ+0xfc
	push	xbc	; F0C0E0  push XBC
	pushw	3	; F0C0E1  push 0x0003
	call	Arr27A6_Get	; F0C0E4  call 0xfd6c7b
	inc	6, xsp	; F0C0E8  inc 6,XSP
	cp	h, 0:i3	; F0C0EA  cp H,0
	jr	nz, SoftKeyCol1_SoundEditCopy_Skip5	; F0C0EC  jr NZ,0xf0c0fa
	cp	(xiz-4), 0x03	; F0C0EE  cp (XIZ+0xfc),0x03
	jrl	nc, SoftKeyCol1_SoundEditCopy_Skip11	; F0C0F2  jrl NC,0xf0c28b
	incm8	1, (xiz-4)	; F0C0F5  inc 1,(XIZ+0xfc)
	jr	SoftKeyCol1_SoundEditCopy_Join7	; F0C0F8  jr T,0xf0c104
SoftKeyCol1_SoundEditCopy_Skip5:
	cp	(xiz-4), 0x00	; F0C0FA  cp (XIZ+0xfc),0x00
	jrl	z, SoftKeyCol1_SoundEditCopy_Skip11	; F0C0FE  jrl Z,0xf0c28b
	decm8	1, (xiz-4)	; F0C101  dec 1,(XIZ+0xfc)
SoftKeyCol1_SoundEditCopy_Join7:
	ld	bc, (xiz-4)	; F0C104  ld BC,(XIZ+0xfc)
	extz	bc	; F0C107  extz BC
	pushw	bc	; F0C109  push BC
	pushw	3	; F0C10A  push 0x0003
	lda	xiy, (SoftKeyCol1_SoundEditCopy_Resume:24)	; F0C10D  lda XIY,0xf0c115
	push	xiy	; F0C112  push XIY
	jp	(xix)	; F0C113  jp T,XIX
SoftKeyCol1_SoundEditCopy_Resume:
	pushw	3	; F0C115  push 0x0003
	pushw	157	; F0C118  push 0x009d
	call	T_Dispatch_Code80	; F0C11B  call 0xf41ed4
	pushw	0	; F0C11F  push 0x0000
	pushw	4	; F0C122  push 0x0004
	lda	xiy, (SoftKeyCol1_SoundEditCopy_Resume2:24)	; F0C125  lda XIY,0xf0c12d
	push	xiy	; F0C12A  push XIY
	jp	(xix)	; F0C12B  jp T,XIX
SoftKeyCol1_SoundEditCopy_Resume2:
	inc	8, xsp	; F0C12D  inc 0,XSP
	inc	4, xsp	; F0C12F  inc 4,XSP
SoftKeyCol1_SoundEditCopy_Join8:
	calr	SoundEditCopy_ResolveSelectedSound	; F0C131  calr 0xf0c291
	lda	xbc, (xiz-6)	; F0C134  lda XBC,XIZ+0xfa
	push	xbc	; F0C137  push XBC
	pushw	15	; F0C138  push 0x000f
	call	Arr27A6_Get	; F0C13B  call 0xfd6c7b
	inc	6, xsp	; F0C13F  inc 6,XSP
	cp	(xiz-6), 0x00	; F0C141  cp (XIZ+0xfa),0x00
	jrl	z, SoftKeyCol1_SoundEditCopy_Skip10	; F0C145  jrl Z,0xf0c283
	lda	xbc, (xiz-8)	; F0C148  lda XBC,XIZ+0xf8
	push	xbc	; F0C14B  push XBC
	pushw	4	; F0C14C  push 0x0004
	call	Arr27A6_Get	; F0C14F  call 0xfd6c7b
	inc	6, xsp	; F0C153  inc 6,XSP
	cp	(xiz-8), 0x7f	; F0C155  cp (XIZ+0xf8),0x7f
	jrl	nc, SoftKeyCol1_SoundEditCopy_Skip11	; F0C159  jrl NC,0xf0c28b
	incm8	1, (xiz-8)	; F0C15C  inc 1,(XIZ+0xf8)
	ld	bc, (xiz-8)	; F0C15F  ld BC,(XIZ+0xf8)
	extz	bc	; F0C162  extz BC
	pushw	bc	; F0C164  push BC
	pushw	4	; F0C165  push 0x0004
	lda	xiy, (SoftKeyCol1_SoundEditCopy_Resume3:24)	; F0C168  lda XIY,0xf0c170
	push	xiy	; F0C16D  push XIY
	jp	(xix)	; F0C16E  jp T,XIX
SoftKeyCol1_SoundEditCopy_Resume3:
	pop	xiy	; F0C170  pop XIY
	jr	SoftKeyCol1_SoundEditCopy_Join8	; F0C171  jr T,0xf0c131
SoftKeyCol1_SoundEditCopy_Skip6:
	lda	xbc, (xiz-10)	; F0C173  lda XBC,XIZ+0xf6
	push	xbc	; F0C176  push XBC
	pushw	4	; F0C177  push 0x0004
	call	Arr27A6_Get	; F0C17A  call 0xfd6c7b
	inc	6, xsp	; F0C17E  inc 6,XSP
	cp	h, 0:i3	; F0C180  cp H,0
	jr	nz, SoftKeyCol1_SoundEditCopy_Skip7	; F0C182  jr NZ,0xf0c190
	cp	(xiz-10), 0x33	; F0C184  cp (XIZ+0xf6),0x33
	jrl	nc, SoftKeyCol1_SoundEditCopy_Skip11	; F0C188  jrl NC,0xf0c28b
	incm8	1, (xiz-10)	; F0C18B  inc 1,(XIZ+0xf6)
	jr	SoftKeyCol1_SoundEditCopy_Join9	; F0C18E  jr T,0xf0c19a
SoftKeyCol1_SoundEditCopy_Skip7:
	cp	(xiz-10), 0x20	; F0C190  cp (XIZ+0xf6),0x20
	jrl	ule, SoftKeyCol1_SoundEditCopy_Skip11	; F0C194  jrl ULE,0xf0c28b
	decm8	1, (xiz-10)	; F0C197  dec 1,(XIZ+0xf6)
SoftKeyCol1_SoundEditCopy_Join9:
	ld	bc, (xiz-10)	; F0C19A  ld BC,(XIZ+0xf6)
	extz	bc	; F0C19D  extz BC
	pushw	bc	; F0C19F  push BC
	pushw	4	; F0C1A0  push 0x0004
	lda	xiy, (SoftKeyCol1_SoundEditCopy_Resume4:24)	; F0C1A3  lda XIY,0xf0c1ab
	push	xiy	; F0C1A8  push XIY
	jp	(xix)	; F0C1A9  jp T,XIX
SoftKeyCol1_SoundEditCopy_Resume4:
	pushw	36	; F0C1AB  push 0x0024
	pushw	5	; F0C1AE  push 0x0005
	lda	xiy, (SoftKeyCol1_SoundEditCopy_Resume5:24)	; F0C1B1  lda XIY,0xf0c1b9
	push	xiy	; F0C1B6  push XIY
	jp	(xix)	; F0C1B7  jp T,XIX
SoftKeyCol1_SoundEditCopy_Resume5:
	inc	8, xsp	; F0C1B9  inc 0,XSP
	cp	(xiz-10), 0x30	; F0C1BB  cp (XIZ+0xf6),0x30
	jr	nc, SoftKeyCol1_SoundEditCopy_Skip8	; F0C1BF  jr NC,0xf0c1df
	ld	e, 0:opc	; F0C1C1  ld E,0x00
	ld	d, 32:opc	; F0C1C3  ld D,0x20
	ld	c, (xiz-10)	; F0C1C5  ld C,(XIZ+0xf6)
	sub	c, 32	; F0C1C8  sub C,0x20
	ld	(xiz-16), c	; F0C1CB  ld (XIZ+0xf0),C
	ld	(xiz-4), c	; F0C1CE  ld (XIZ+0xfc),C
	ld	h, (xiz-16)	; F0C1D1  ld H,(XIZ+0xf0)
	srl	h, 3	; F0C1D4  srl 0x03,H
	ld	l, (xiz-16)	; F0C1D7  ld L,(XIZ+0xf0)
	and	l, 7	; F0C1DA  and L,0x07
	jr	SoftKeyCol1_SoundEditCopy_Join10	; F0C1DD  jr T,0xf0c201
SoftKeyCol1_SoundEditCopy_Skip8:
	cp	(xiz-10), 0x32	; F0C1DF  cp (XIZ+0xf6),0x32
	jr	nc, SoftKeyCol1_SoundEditCopy_Skip9	; F0C1E3  jr NC,0xf0c1f4
	ld	e, 1:opc	; F0C1E5  ld E,0x01
	ld	d, 40:opc	; F0C1E7  ld D,0x28
	ld	h, 0:opc	; F0C1E9  ld H,0x00
	ld	l, (xiz-10)	; F0C1EB  ld L,(XIZ+0xf6)
	ld	c, 48:opc	; F0C1EE  ld C,0x30
	sub	l, c	; F0C1F0  sub L,C
	jr	SoftKeyCol1_SoundEditCopy_Join10	; F0C1F2  jr T,0xf0c201
SoftKeyCol1_SoundEditCopy_Skip9:
	ld	e, 2:opc	; F0C1F4  ld E,0x02
	ld	d, 41:opc	; F0C1F6  ld D,0x29
	ld	h, 0:opc	; F0C1F8  ld H,0x00
	ld	l, (xiz-10)	; F0C1FA  ld L,(XIZ+0xf6)
	ld	c, 50:opc	; F0C1FD  ld C,0x32
	sub	l, c	; F0C1FF  sub L,C
SoftKeyCol1_SoundEditCopy_Join10:
	ld	c, e	; F0C201  ld C,E
	extz	bc	; F0C203  extz BC
	pushw	bc	; F0C205  push BC
	pushw	3	; F0C206  push 0x0003
	lda	xiy, (SoftKeyCol1_SoundEditCopy_Resume6:24)	; F0C209  lda XIY,0xf0c211
	push	xiy	; F0C20E  push XIY
	jp	(xix)	; F0C20F  jp T,XIX
SoftKeyCol1_SoundEditCopy_Resume6:
	ld	c, l	; F0C211  ld C,L
	extz	bc	; F0C213  extz BC
	pushw	bc	; F0C215  push BC
	ld	c, h	; F0C216  ld C,H
	extz	bc	; F0C218  extz BC
	pushw	bc	; F0C21A  push BC
	ld	c, d	; F0C21B  ld C,D
	extz	bc	; F0C21D  extz BC
	pushw	bc	; F0C21F  push BC
	call	SoundConv_SetArgs4	; F0C220  call 0xfd7add
	call	T_SoundSel_ToProgramAndBank	; F0C224  call 0xf40ffc
	lda	xbc, (xiz-12)	; F0C228  lda XBC,XIZ+0xf4
	push	xbc	; F0C22B  push XBC
	lda	xwa, (xiz-14)	; F0C22C  lda XWA,XIZ+0xf2
	push	xwa	; F0C22F  push XWA
	call	SoundConv_GetResults	; F0C230  call 0xfd7b00
	ld	bc, (xiz-12)	; F0C234  ld BC,(XIZ+0xf4)
	extz	bc	; F0C237  extz BC
	pushw	bc	; F0C239  push BC
	pushw	10	; F0C23A  push 0x000a
	lda	xiy, (SoftKeyCol1_SoundEditCopy_Resume7:24)	; F0C23D  lda XIY,0xf0c245
	push	xiy	; F0C242  push XIY
	jp	(xix)	; F0C243  jp T,XIX
SoftKeyCol1_SoundEditCopy_Resume7:
	ld	bc, (xiz-14)	; F0C245  ld BC,(XIZ+0xf2)
	extz	bc	; F0C248  extz BC
	pushw	bc	; F0C24A  push BC
	pushw	11	; F0C24B  push 0x000b
	lda	xiy, (SoftKeyCol1_SoundEditCopy_Resume8:24)	; F0C24E  lda XIY,0xf0c256
	push	xiy	; F0C253  push XIY
	jp	(xix)	; F0C254  jp T,XIX
SoftKeyCol1_SoundEditCopy_Resume8:
	pushw	4	; F0C256  push 0x0004
	pushw	157	; F0C259  push 0x009d
	call	T_Dispatch_Code80	; F0C25C  call 0xf41ed4
	pushw	3	; F0C260  push 0x0003
	pushw	157	; F0C263  push 0x009d
	call	T_Dispatch_Code80	; F0C266  call 0xf41ed4
	pushw	157	; F0C26A  push 0x009d
	ld	bc, (xiz-14)	; F0C26D  ld BC,(XIZ+0xf2)
	extz	bc	; F0C270  extz BC
	pushw	bc	; F0C272  push BC
	ld	bc, (xiz-12)	; F0C273  ld BC,(XIZ+0xf4)
	extz	bc	; F0C276  extz BC
	pushw	bc	; F0C278  push BC
	call	ToneMsg80_Id04	; F0C279  call 0xfd648d
	add	xsp, 40	; F0C27D  add XSP,0x00000028
SoftKeyCol1_SoundEditCopy_Skip10:
	pushw	1	; F0C283  push 0x0001
	call	PanelDial_ActAsButton	; F0C286  call 0xfd7c01
	popw	bc	; F0C28A  pop BC
SoftKeyCol1_SoundEditCopy_Skip11:
	pop	xix	; F0C28B  pop XIX
	popw	de	; F0C28C  pop DE
	popw	hl	; F0C28D  pop HL
	unlk XIZ	; F0C28E  unlk XIZ
	ret	; F0C290  ret

; --------------------------------------------------------------------------
; SoundEditCopy_ResolveSelectedSound
; Called from: in-module: 0xF0C131 0xF0C3B8
; Touches:   |  0xFCFCD4
; Calls:   0xFD6C7B 0xFD7ADD T_SoundSel_ToProgramAndBank 0xFD7B00 T_Dispatch_Code80
; Evidence: reached by a `call`/`calr`/`jp` decoded in this transcription (the
;           sites are listed above), so 0xF0C291 is an instruction boundary.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoundEditCopy_ResolveSelectedSound: Bank code IndexMap_FCFCD4[field 3] (R1/R2/U1/U2), group field4 >> 3, member
;   field4 & 7 -> fields 7, 8, 9; SoundSel_ToProgramAndBank -> program and bank into fields 10, 11; repaint code 0x9D.
;   Both SOUND EDIT COPY soft keys call it after changing the selection. Basis: callers + body + named converters.
;   (notes/naming-pilot-2026-10-06/proposals_wave2_c.json)
SoundEditCopy_ResolveSelectedSound:
	link XIZ,0xfff6	; F0C291  link XIZ,0xfff6
	pushw	hl	; F0C295  push HL
	pushw	de	; F0C296  push DE
	push	xix	; F0C297  push XIX
	lda	xix, (Arr27A6_Set:24)	; F0C298  lda XIX,0xfd6c65
	lda	xbc, (xiz-2)	; F0C29D  lda XBC,XIZ+0xfe
	push	xbc	; F0C2A0  push XBC
	pushw	3	; F0C2A1  push 0x0003
	call	Arr27A6_Get	; F0C2A4  call 0xfd6c7b
	ld	bc, (xiz-2)	; F0C2A8  ld BC,(XIZ+0xfe)
	extz	bc	; F0C2AB  extz BC
	extz	xbc	; F0C2AD  extz XBC
	add	xbc, IndexMap_FCFCD4	; F0C2AF  add XBC,0x00fcfcd4
	ld	a, (xbc)	; F0C2B5  ld A,(XBC)
	ld	(xiz-2), a	; F0C2B7  ld (XIZ+0xfe),A
	lda	xbc, (xiz-4)	; F0C2BA  lda XBC,XIZ+0xfc
	push	xbc	; F0C2BD  push XBC
	pushw	4	; F0C2BE  push 0x0004
	call	Arr27A6_Get	; F0C2C1  call 0xfd6c7b
	ld	h, (xiz-4)	; F0C2C5  ld H,(XIZ+0xfc)
	srl	h, 3	; F0C2C8  srl 0x03,H
	ld	l, (xiz-4)	; F0C2CB  ld L,(XIZ+0xfc)
	and	l, 7	; F0C2CE  and L,0x07
	ld	bc, (xiz-2)	; F0C2D1  ld BC,(XIZ+0xfe)
	extz	bc	; F0C2D4  extz BC
	pushw	bc	; F0C2D6  push BC
	pushw	7	; F0C2D7  push 0x0007
	lda	xiy, (SoundEditCopy_ResolveSelectedSound_Resume:24)	; F0C2DA  lda XIY,0xf0c2e2
	push	xiy	; F0C2DF  push XIY
	jp	(xix)	; F0C2E0  jp T,XIX
SoundEditCopy_ResolveSelectedSound_Resume:
	ld	c, h	; F0C2E2  ld C,H
	extz	bc	; F0C2E4  extz BC
	ld	de, bc	; F0C2E6  ld DE,BC
	pushw	bc	; F0C2E8  push BC
	pushw	8	; F0C2E9  push 0x0008
	lda	xiy, (SoundEditCopy_ResolveSelectedSound_Resume2:24)	; F0C2EC  lda XIY,0xf0c2f4
	push	xiy	; F0C2F1  push XIY
	jp	(xix)	; F0C2F2  jp T,XIX
SoundEditCopy_ResolveSelectedSound_Resume2:
	ld	c, l	; F0C2F4  ld C,L
	extz	bc	; F0C2F6  extz BC
	ld	(xiz-10), bc	; F0C2F8  ld (XIZ+0xf6),BC
	pushw	bc	; F0C2FB  push BC
	pushw	9	; F0C2FC  push 0x0009
	lda	xiy, (SoundEditCopy_ResolveSelectedSound_Resume3:24)	; F0C2FF  lda XIY,0xf0c307
	push	xiy	; F0C304  push XIY
	jp	(xix)	; F0C305  jp T,XIX
SoundEditCopy_ResolveSelectedSound_Resume3:
	pushw	(xiz-10)	; F0C307  pushw (XIZ+0xf6)
	pushw	de	; F0C30A  push DE
	ld	bc, (xiz-2)	; F0C30B  ld BC,(XIZ+0xfe)
	extz	bc	; F0C30E  extz BC
	pushw	bc	; F0C310  push BC
	call	SoundConv_SetArgs4	; F0C311  call 0xfd7add
	call	T_SoundSel_ToProgramAndBank	; F0C315  call 0xf40ffc
	lda	xbc, (xiz-6)	; F0C319  lda XBC,XIZ+0xfa
	push	xbc	; F0C31C  push XBC
	lda	xwa, (xiz-8)	; F0C31D  lda XWA,XIZ+0xf8
	push	xwa	; F0C320  push XWA
	call	SoundConv_GetResults	; F0C321  call 0xfd7b00
	ld	bc, (xiz-6)	; F0C325  ld BC,(XIZ+0xfa)
	extz	bc	; F0C328  extz BC
	pushw	bc	; F0C32A  push BC
	pushw	10	; F0C32B  push 0x000a
	lda	xiy, (SoundEditCopy_ResolveSelectedSound_Resume4:24)	; F0C32E  lda XIY,0xf0c336
	push	xiy	; F0C333  push XIY
	jp	(xix)	; F0C334  jp T,XIX
SoundEditCopy_ResolveSelectedSound_Resume4:
	ld	bc, (xiz-8)	; F0C336  ld BC,(XIZ+0xf8)
	extz	bc	; F0C339  extz BC
	pushw	bc	; F0C33B  push BC
	pushw	11	; F0C33C  push 0x000b
	lda	xiy, (SoundEditCopy_ResolveSelectedSound_Resume5:24)	; F0C33F  lda XIY,0xf0c347
	push	xiy	; F0C344  push XIY
	jp	(xix)	; F0C345  jp T,XIX
SoundEditCopy_ResolveSelectedSound_Resume5:
	pushw	4	; F0C347  push 0x0004
	pushw	157	; F0C34A  push 0x009d
	call	T_Dispatch_Code80	; F0C34D  call 0xf41ed4
	add	xsp, 50	; F0C351  add XSP,0x00000032
	pop	xix	; F0C357  pop XIX
	popw	de	; F0C358  pop DE
	popw	hl	; F0C359  pop HL
	unlk XIZ	; F0C35A  unlk XIZ
	ret	; F0C35C  ret

; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditCopy
; Called from: table 0xFCF80C[271]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD6C7B 0xFD6C65 SoundEditCopy_ResolveSelectedSound 0xFD64D1 0xFD7C01
; Evidence: word [271] of the pointer table at 0xFCF80C reads 0x00F0C35D, that
;           table's reader TRANSFERS to the word it loads, and 0xF0C35D is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol2_SoundEditCopy: SOFT KEY column 2 (lower or upper; the flag carries which) on ScreenCode9D -- ScreenCode9D op 1 (PanelOpTable_FCFC44).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol2_SoundEditCopy:
	link XIZ,0xfffa	; F0C35D  link XIZ,0xfffa
	ld	c, (xiz+8)	; F0C361  ld C,(XIZ+0x08)
	res	7, c	; F0C364  res 0x07,C
	ld	(xiz-1), c	; F0C367  ld (XIZ+0xff),C
	lda	xbc, (xiz-2)	; F0C36A  lda XBC,XIZ+0xfe
	push	xbc	; F0C36D  push XBC
	call	Var27F5_Get	; F0C36E  call 0xfda0ca
	pop	xiy	; F0C372  pop XIY
SoftKeyCol2_SoundEditCopy_Loop:
	lda	xbc, (xiz-4)	; F0C373  lda XBC,XIZ+0xfc
	push	xbc	; F0C376  push XBC
	cp	(xiz-2), 0x00	; F0C377  cp (XIZ+0xfe),0x00
	jr	nz, SoftKeyCol2_SoundEditCopy_Skip	; F0C37B  jr NZ,0xf0c382
	pushw	4	; F0C37D  push 0x0004
	jr	SoftKeyCol2_SoundEditCopy_Join	; F0C380  jr T,0xf0c385
SoftKeyCol2_SoundEditCopy_Skip:
	pushw	5	; F0C382  push 0x0005
SoftKeyCol2_SoundEditCopy_Join:
	call	Arr27A6_Get	; F0C385  call 0xfd6c7b
	inc	6, xsp	; F0C389  inc 6,XSP
	cp	(xiz-1), 0x00	; F0C38B  cp (XIZ+0xff),0x00
	jr	nz, SoftKeyCol2_SoundEditCopy_Skip2	; F0C38F  jr NZ,0xf0c39c
	cp	(xiz-4), 0x7f	; F0C391  cp (XIZ+0xfc),0x7f
	jr	nc, SoftKeyCol2_SoundEditCopy_Skip4	; F0C395  jr NC,0xf0c3f6
	incm8	1, (xiz-4)	; F0C397  inc 1,(XIZ+0xfc)
	jr	SoftKeyCol2_SoundEditCopy_Join2	; F0C39A  jr T,0xf0c3a5
SoftKeyCol2_SoundEditCopy_Skip2:
	cp	(xiz-4), 0x00	; F0C39C  cp (XIZ+0xfc),0x00
	jr	z, SoftKeyCol2_SoundEditCopy_Skip4	; F0C3A0  jr Z,0xf0c3f6
	decm8	1, (xiz-4)	; F0C3A2  dec 1,(XIZ+0xfc)
SoftKeyCol2_SoundEditCopy_Join2:
	cp	(xiz-2), 0x00	; F0C3A5  cp (XIZ+0xfe),0x00
	jr	nz, SoftKeyCol2_SoundEditCopy_Skip3	; F0C3A9  jr NZ,0xf0c3d2
	ld	bc, (xiz-4)	; F0C3AB  ld BC,(XIZ+0xfc)
	extz	bc	; F0C3AE  extz BC
	pushw	bc	; F0C3B0  push BC
	pushw	4	; F0C3B1  push 0x0004
	call	Arr27A6_Set	; F0C3B4  call 0xfd6c65
	calr	SoundEditCopy_ResolveSelectedSound	; F0C3B8  calr 0xf0c291
	lda	xbc, (xiz-6)	; F0C3BB  lda XBC,XIZ+0xfa
	push	xbc	; F0C3BE  push XBC
	pushw	15	; F0C3BF  push 0x000f
	call	Arr27A6_Get	; F0C3C2  call 0xfd6c7b
	inc	8, xsp	; F0C3C6  inc 0,XSP
	inc	2, xsp	; F0C3C8  inc 2,XSP
	cp	(xiz-6), 0x00	; F0C3CA  cp (XIZ+0xfa),0x00
	jr	nz, SoftKeyCol2_SoundEditCopy_Loop	; F0C3CE  jr NZ,0xf0c373
	jr	SoftKeyCol2_SoundEditCopy_Join3	; F0C3D0  jr T,0xf0c3ee
SoftKeyCol2_SoundEditCopy_Skip3:
	ld	bc, (xiz-4)	; F0C3D2  ld BC,(XIZ+0xfc)
	extz	bc	; F0C3D5  extz BC
	pushw	bc	; F0C3D7  push BC
	pushw	5	; F0C3D8  push 0x0005
	call	Arr27A6_Set	; F0C3DB  call 0xfd6c65
	pushw	157	; F0C3DF  push 0x009d
	ld	bc, (xiz-4)	; F0C3E2  ld BC,(XIZ+0xfc)
	extz	bc	; F0C3E5  extz BC
	pushw	bc	; F0C3E7  push BC
	call	ToneMsg80_Id15_Part0	; F0C3E8  call 0xfd64d1
	inc	8, xsp	; F0C3EC  inc 0,XSP
SoftKeyCol2_SoundEditCopy_Join3:
	pushw	2	; F0C3EE  push 0x0002
	call	PanelDial_ActAsButton	; F0C3F1  call 0xfd7c01
	popw	bc	; F0C3F5  pop BC
SoftKeyCol2_SoundEditCopy_Skip4:
	unlk XIZ	; F0C3F6  unlk XIZ
	ret	; F0C3F8  ret

; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditCopy
; Called from: table 0xFCF80C[272]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD6C7B 0xFD6C65 T_Dispatch_Code80
; Evidence: word [272] of the pointer table at 0xFCF80C reads 0x00F0C3F9, that
;           table's reader TRANSFERS to the word it loads, and 0xF0C3F9 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol3_SoundEditCopy: SOFT KEY column 3 (lower or upper; the flag carries which) on ScreenCode9D -- ScreenCode9D op 2 (PanelOpTable_FCFC44).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol3_SoundEditCopy:
	link XIZ,0xfffa	; F0C3F9  link XIZ,0xfffa
	pushw	hl	; F0C3FD  push HL
	lda	xbc, (xiz-2)	; F0C3FE  lda XBC,XIZ+0xfe
	push	xbc	; F0C401  push XBC
	call	Var27F5_Get	; F0C402  call 0xfda0ca
	lda	xbc, (xiz-4)	; F0C406  lda XBC,XIZ+0xfc
	push	xbc	; F0C409  push XBC
	pushw	2	; F0C40A  push 0x0002
	call	Arr27A6_Get	; F0C40D  call 0xfd6c7b
	ld	h, 2:opc	; F0C411  ld H,0x02
	inc	8, xsp	; F0C413  inc 0,XSP
	inc	2, xsp	; F0C415  inc 2,XSP
	cp	(xiz-2), 0x00	; F0C417  cp (XIZ+0xfe),0x00
	jr	nz, SoftKeyCol3_SoundEditCopy_Skip5	; F0C41B  jr NZ,0xf0c41f
	ld	h, 4:opc	; F0C41D  ld H,0x04
SoftKeyCol3_SoundEditCopy_Skip5:
	ld	c, (xiz-4)	; F0C41F  ld C,(XIZ+0xfc)
	cp	c, h	; F0C422  cp C,H
	jr	z, SoftKeyCol3_SoundEditCopy_Skip8	; F0C424  jr Z,0xf0c477
	ld	l, (xiz+8)	; F0C426  ld L,(XIZ+0x08)
	res	7, l	; F0C429  res 0x07,L
	ld	h, 1:opc	; F0C42C  ld H,0x01
	cp	(xiz-2), 0x00	; F0C42E  cp (XIZ+0xfe),0x00
	jr	nz, SoftKeyCol3_SoundEditCopy_Skip6	; F0C432  jr NZ,0xf0c436
	ld	h, 3:opc	; F0C434  ld H,0x03
SoftKeyCol3_SoundEditCopy_Skip6:
	lda	xbc, (xiz-6)	; F0C436  lda XBC,XIZ+0xfa
	push	xbc	; F0C439  push XBC
	pushw	1	; F0C43A  push 0x0001
	call	Arr27A6_Get	; F0C43D  call 0xfd6c7b
	inc	6, xsp	; F0C441  inc 6,XSP
	cp	l, 0:i3	; F0C443  cp L,0
	jr	nz, SoftKeyCol3_SoundEditCopy_Skip7	; F0C445  jr NZ,0xf0c455
	ld	c, (xiz-6)	; F0C447  ld C,(XIZ+0xfa)
	cp	c, h	; F0C44A  cp C,H
	jr	nc, SoftKeyCol3_SoundEditCopy_Skip8	; F0C44C  jr NC,0xf0c477
	inc	1, c	; F0C44E  inc 1,C
	ld	(xiz-6), c	; F0C450  ld (XIZ+0xfa),C
	jr	SoftKeyCol3_SoundEditCopy_Join4	; F0C453  jr T,0xf0c45e
SoftKeyCol3_SoundEditCopy_Skip7:
	cp	(xiz-6), 0x00	; F0C455  cp (XIZ+0xfa),0x00
	jr	z, SoftKeyCol3_SoundEditCopy_Skip8	; F0C459  jr Z,0xf0c477
	decm8	1, (xiz-6)	; F0C45B  dec 1,(XIZ+0xfa)
SoftKeyCol3_SoundEditCopy_Join4:
	ld	bc, (xiz-6)	; F0C45E  ld BC,(XIZ+0xfa)
	extz	bc	; F0C461  extz BC
	pushw	bc	; F0C463  push BC
	pushw	1	; F0C464  push 0x0001
	call	Arr27A6_Set	; F0C467  call 0xfd6c65
	pushw	1	; F0C46B  push 0x0001
	pushw	157	; F0C46E  push 0x009d
	call	T_Dispatch_Code80	; F0C471  call 0xf41ed4
	inc	8, xsp	; F0C475  inc 0,XSP
SoftKeyCol3_SoundEditCopy_Skip8:
	popw	hl	; F0C477  pop HL
	unlk XIZ	; F0C478  unlk XIZ
	ret	; F0C47A  ret

; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditCopy
; Called from: table 0xFCF80C[273]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD6C7B 0xFD6C65 T_Dispatch_Code80
; Evidence: word [273] of the pointer table at 0xFCF80C reads 0x00F0C47B, that
;           table's reader TRANSFERS to the word it loads, and 0xF0C47B is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol4_SoundEditCopy: SOFT KEY column 4 (lower or upper; the flag carries which) on ScreenCode9D -- ScreenCode9D op 3 (PanelOpTable_FCFC44).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol4_SoundEditCopy:
	link XIZ,0xfffa	; F0C47B  link XIZ,0xfffa
	pushw	hl	; F0C47F  push HL
	pushw	de	; F0C480  push DE
	push	xix	; F0C481  push XIX
	lda	xbc, (xiz-2)	; F0C482  lda XBC,XIZ+0xfe
	push	xbc	; F0C485  push XBC
	call	Var27F5_Get	; F0C486  call 0xfda0ca
	lda	xbc, (xiz-4)	; F0C48A  lda XBC,XIZ+0xfc
	push	xbc	; F0C48D  push XBC
	pushw	2	; F0C48E  push 0x0002
	call	Arr27A6_Get	; F0C491  call 0xfd6c7b
	inc	8, xsp	; F0C495  inc 0,XSP
	inc	2, xsp	; F0C497  inc 2,XSP
	cp	(xiz-2), 0x00	; F0C499  cp (XIZ+0xfe),0x00
	jr	nz, SoftKeyCol4_SoundEditCopy_Skip9	; F0C49D  jr NZ,0xf0c4ae
	cp	(xiz-4), 0x04	; F0C49F  cp (XIZ+0xfc),0x04
	jr	z, SoftKeyCol4_SoundEditCopy_Skip10	; F0C4A3  jr Z,0xf0c4b4
	ld	l, 6:opc	; F0C4A5  ld L,0x06
	lda	xix, (StepValues_FCFCD8:24)	; F0C4A7  lda XIX,0xfcfcd8
	jr	SoftKeyCol4_SoundEditCopy_Join5	; F0C4AC  jr T,0xf0c4c4
SoftKeyCol4_SoundEditCopy_Skip9:
	cp	(xiz-4), 0x02	; F0C4AE  cp (XIZ+0xfc),0x02
	jr	nz, SoftKeyCol4_SoundEditCopy_Skip11	; F0C4B2  jr NZ,0xf0c4bd
SoftKeyCol4_SoundEditCopy_Skip10:
	ld	l, 1:opc	; F0C4B4  ld L,0x01
	lda	xix, (StepValues_FCFCDF:24)	; F0C4B6  lda XIX,0xfcfcdf
	jr	SoftKeyCol4_SoundEditCopy_Join5	; F0C4BB  jr T,0xf0c4c4
SoftKeyCol4_SoundEditCopy_Skip11:
	ld	l, 5:opc	; F0C4BD  ld L,0x05
	lda	xix, (StepValues_FCFCE1:24)	; F0C4BF  lda XIX,0xfcfce1
SoftKeyCol4_SoundEditCopy_Join5:
	ld	d, (xiz+8)	; F0C4C4  ld D,(XIZ+0x08)
	res	7, d	; F0C4C7  res 0x07,D
	lda	xbc, (xiz-6)	; F0C4CA  lda XBC,XIZ+0xfa
	push	xbc	; F0C4CD  push XBC
	pushw	0	; F0C4CE  push 0x0000
	call	Arr27A6_Get	; F0C4D1  call 0xfd6c7b
	ld	h, 0:opc	; F0C4D5  ld H,0x00
	inc	6, xsp	; F0C4D7  inc 6,XSP
	jr	SoftKeyCol4_SoundEditCopy_Join6	; F0C4D9  jr T,0xf0c4ec
SoftKeyCol4_SoundEditCopy_Loop2:
	ld	c, h	; F0C4DB  ld C,H
	extz	bc	; F0C4DD  extz BC
	extz	xbc	; F0C4DF  extz XBC
	add	xbc, xix	; F0C4E1  add XBC,XIX
	ld	a, (xbc)	; F0C4E3  ld A,(XBC)
	cp	(xiz-6), a	; F0C4E5  cp (XIZ+0xfa),A
	jr	z, SoftKeyCol4_SoundEditCopy_Skip12	; F0C4E8  jr Z,0xf0c4f0
	inc	1, h	; F0C4EA  inc 1,H
SoftKeyCol4_SoundEditCopy_Join6:
	cp	h, l	; F0C4EC  cp H,L
	jr	ule, SoftKeyCol4_SoundEditCopy_Loop2	; F0C4EE  jr ULE,0xf0c4db
SoftKeyCol4_SoundEditCopy_Skip12:
	cp	d, 0:i3	; F0C4F0  cp D,0
	jr	nz, SoftKeyCol4_SoundEditCopy_Skip13	; F0C4F2  jr NZ,0xf0c4fc
	cp	h, l	; F0C4F4  cp H,L
	jr	nc, SoftKeyCol4_SoundEditCopy_Skip14	; F0C4F6  jr NC,0xf0c522
	inc	1, h	; F0C4F8  inc 1,H
	jr	SoftKeyCol4_SoundEditCopy_Join7	; F0C4FA  jr T,0xf0c502
SoftKeyCol4_SoundEditCopy_Skip13:
	cp	h, 0:i3	; F0C4FC  cp H,0
	jr	z, SoftKeyCol4_SoundEditCopy_Skip14	; F0C4FE  jr Z,0xf0c522
	dec	1, h	; F0C500  dec 1,H
SoftKeyCol4_SoundEditCopy_Join7:
	ld	c, h	; F0C502  ld C,H
	extz	bc	; F0C504  extz BC
	extz	xbc	; F0C506  extz XBC
	add	xbc, xix	; F0C508  add XBC,XIX
	ld	a, (xbc)	; F0C50A  ld A,(XBC)
	extz	wa	; F0C50C  extz WA
	pushw	wa	; F0C50E  push WA
	pushw	0	; F0C50F  push 0x0000
	call	Arr27A6_Set	; F0C512  call 0xfd6c65
	pushw	0	; F0C516  push 0x0000
	pushw	157	; F0C519  push 0x009d
	call	T_Dispatch_Code80	; F0C51C  call 0xf41ed4
	inc	8, xsp	; F0C520  inc 0,XSP
SoftKeyCol4_SoundEditCopy_Skip14:
	pop	xix	; F0C522  pop XIX
	popw	de	; F0C523  pop DE
	popw	hl	; F0C524  pop HL
	unlk XIZ	; F0C525  unlk XIZ
	ret	; F0C527  ret

; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditCopy
; Called from: table 0xFCF80C[275]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD6C7B T_Dispatch_Code80
; Evidence: word [275] of the pointer table at 0xFCF80C reads 0x00F0C528, that
;           table's reader TRANSFERS to the word it loads, and 0xF0C528 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; SoftKeyCol6_SoundEditCopy: SOFT KEY column 6 (lower or upper; the flag carries which) on ScreenCode9D -- ScreenCode9D op 5 (PanelOpTable_FCFC44).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
SoftKeyCol6_SoundEditCopy:
	link XIZ,0xfffc	; F0C528  link XIZ,0xfffc
	pushw	hl	; F0C52C  push HL
	push	xix	; F0C52D  push XIX
	lda	xix, (Arr27A6_Set:24)	; F0C52E  lda XIX,0xfd6c65
	lda	xbc, (xiz-2)	; F0C533  lda XBC,XIZ+0xfe
	push	xbc	; F0C536  push XBC
	call	Var27F5_Get	; F0C537  call 0xfda0ca
	ld	h, (xiz+8)	; F0C53B  ld H,(XIZ+0x08)
	res	7, h	; F0C53E  res 0x07,H
	ld	(xiz-3), 2	; F0C541  ld (XIZ+0xfd),0x02
	pop	xiy	; F0C545  pop XIY
	cp	(xiz-2), 0x00	; F0C546  cp (XIZ+0xfe),0x00
	jr	nz, SoftKeyCol6_SoundEditCopy_Skip15	; F0C54A  jr NZ,0xf0c550
	ld	(xiz-3), 4	; F0C54C  ld (XIZ+0xfd),0x04
SoftKeyCol6_SoundEditCopy_Skip15:
	lda	xbc, (xiz-4)	; F0C550  lda XBC,XIZ+0xfc
	push	xbc	; F0C553  push XBC
	pushw	2	; F0C554  push 0x0002
	call	Arr27A6_Get	; F0C557  call 0xfd6c7b
	inc	6, xsp	; F0C55B  inc 6,XSP
	cp	h, 0:i3	; F0C55D  cp H,0
	jr	z, SoftKeyCol6_SoundEditCopy_Skip16	; F0C55F  jr Z,0xf0c571
	ld	c, (xiz-4)	; F0C561  ld C,(XIZ+0xfc)
	cp	c, (xiz-3)	; F0C564  cp C,(XIZ+0xfd)
	jrl	nc, SoftKeyCol6_SoundEditCopy_Join11	; F0C567  jrl NC,0xf0c611
	inc	1, c	; F0C56A  inc 1,C
	ld	(xiz-4), c	; F0C56C  ld (XIZ+0xfc),C
	jr	SoftKeyCol6_SoundEditCopy_Join8	; F0C56F  jr T,0xf0c57b
SoftKeyCol6_SoundEditCopy_Skip16:
	cp	(xiz-4), 0x00	; F0C571  cp (XIZ+0xfc),0x00
	jrl	z, SoftKeyCol6_SoundEditCopy_Join11	; F0C575  jrl Z,0xf0c611
	decm8	1, (xiz-4)	; F0C578  dec 1,(XIZ+0xfc)
SoftKeyCol6_SoundEditCopy_Join8:
	ld	bc, (xiz-4)	; F0C57B  ld BC,(XIZ+0xfc)
	extz	bc	; F0C57E  extz BC
	pushw	bc	; F0C580  push BC
	pushw	2	; F0C581  push 0x0002
	lda	xiy, (SoftKeyCol6_SoundEditCopy_Resume:24)	; F0C584  lda XIY,0xf0c58c
	push	xiy	; F0C589  push XIY
	jp	(xix)	; F0C58A  jp T,XIX
SoftKeyCol6_SoundEditCopy_Resume:
	pushw	2	; F0C58C  push 0x0002
	pushw	157	; F0C58F  push 0x009d
	call	T_Dispatch_Code80	; F0C592  call 0xf41ed4
	inc	8, xsp	; F0C596  inc 0,XSP
	ld	c, (xiz-4)	; F0C598  ld C,(XIZ+0xfc)
	cp	c, (xiz-3)	; F0C59B  cp C,(XIZ+0xfd)
	jr	nz, SoftKeyCol6_SoundEditCopy_Skip18	; F0C59E  jr NZ,0xf0c5d6
	pushw	0	; F0C5A0  push 0x0000
	pushw	0	; F0C5A3  push 0x0000
	lda	xiy, (SoftKeyCol6_SoundEditCopy_Resume2:24)	; F0C5A6  lda XIY,0xf0c5ae
	push	xiy	; F0C5AB  push XIY
	jp	(xix)	; F0C5AC  jp T,XIX
SoftKeyCol6_SoundEditCopy_Resume2:
	pop	xbc	; F0C5AE  pop XBC
	cp	(xiz-2), 0x00	; F0C5AF  cp (XIZ+0xfe),0x00
	jr	nz, SoftKeyCol6_SoundEditCopy_Skip17	; F0C5B3  jr NZ,0xf0c5ba
	pushw	4	; F0C5B5  push 0x0004
	jr	SoftKeyCol6_SoundEditCopy_Join9	; F0C5B8  jr T,0xf0c5bd
SoftKeyCol6_SoundEditCopy_Skip17:
	pushw	2	; F0C5BA  push 0x0002
SoftKeyCol6_SoundEditCopy_Join9:
	pushw	1	; F0C5BD  push 0x0001
	lda	xiy, (SoftKeyCol6_SoundEditCopy_Resume3:24)	; F0C5C0  lda XIY,0xf0c5c8
	push	xiy	; F0C5C5  push XIY
	jp	(xix)	; F0C5C6  jp T,XIX
SoftKeyCol6_SoundEditCopy_Resume3:
	pushw	0	; F0C5C8  push 0x0000
	pushw	157	; F0C5CB  push 0x009d
	call	T_Dispatch_Code80	; F0C5CE  call 0xf41ed4
	inc	8, xsp	; F0C5D2  inc 0,XSP
	jr	SoftKeyCol6_SoundEditCopy_Join10	; F0C5D4  jr T,0xf0c606
SoftKeyCol6_SoundEditCopy_Skip18:
	lda	xbc, (xiz-3)	; F0C5D6  lda XBC,XIZ+0xfd
	push	xbc	; F0C5D9  push XBC
	pushw	1	; F0C5DA  push 0x0001
	call	Arr27A6_Get	; F0C5DD  call 0xfd6c7b
	inc	6, xsp	; F0C5E1  inc 6,XSP
	cp	(xiz-2), 0x00	; F0C5E3  cp (XIZ+0xfe),0x00
	jr	nz, SoftKeyCol6_SoundEditCopy_Skip19	; F0C5E7  jr NZ,0xf0c5f1
	cp	(xiz-3), 0x04	; F0C5E9  cp (XIZ+0xfd),0x04
	jr	nc, SoftKeyCol6_SoundEditCopy_Skip20	; F0C5ED  jr NC,0xf0c5f7
	jr	SoftKeyCol6_SoundEditCopy_Join11	; F0C5EF  jr T,0xf0c611
SoftKeyCol6_SoundEditCopy_Skip19:
	cp	(xiz-3), 0x02	; F0C5F1  cp (XIZ+0xfd),0x02
	jr	c, SoftKeyCol6_SoundEditCopy_Join11	; F0C5F5  jr C,0xf0c611
SoftKeyCol6_SoundEditCopy_Skip20:
	pushw	0	; F0C5F7  push 0x0000
	pushw	1	; F0C5FA  push 0x0001
	lda	xiy, (SoftKeyCol6_SoundEditCopy_Resume4:24)	; F0C5FD  lda XIY,0xf0c605
	push	xiy	; F0C602  push XIY
	jp	(xix)	; F0C603  jp T,XIX
SoftKeyCol6_SoundEditCopy_Resume4:
	pop	xiy	; F0C605  pop XIY
SoftKeyCol6_SoundEditCopy_Join10:
	pushw	1	; F0C606  push 0x0001
	pushw	157	; F0C609  push 0x009d
	call	T_Dispatch_Code80	; F0C60C  call 0xf41ed4
	pop	xiy	; F0C610  pop XIY
SoftKeyCol6_SoundEditCopy_Join11:
	pop	xix	; F0C611  pop XIX
	popw	hl	; F0C612  pop HL
	unlk XIZ	; F0C613  unlk XIZ
	ret	; F0C615  ret

; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditCopy
; Called from: table 0xFCF80C[281]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD6C94 0xFD6811 0xFD60D9 0xFDA341
; Evidence: word [281] of the pointer table at 0xFCF80C reads 0x00F0C616, that
;           table's reader TRANSFERS to the word it loads, and 0xF0C616 is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; LcdKeyRow4_SoundEditCopy: LCD key row 4 (left or right) on ScreenCode9D -- ScreenCode9D op 11 (PanelOpTable_FCFC44).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
LcdKeyRow4_SoundEditCopy:
	link XIZ,0xfff2	; F0C616  link XIZ,0xfff2
	pushw	hl	; F0C61A  push HL
	push	xix	; F0C61B  push XIX
	lda	xix, (Arr27A6_Get:24)	; F0C61C  lda XIX,0xfd6c7b
	cp	(xiz+8), 0x00	; F0C621  cp (XIZ+0x08),0x00
	jrl	nz, LcdKeyRow4_SoundEditCopy_Skip23	; F0C625  jrl NZ,0xf0c705
	lda	xbc, (xiz-2)	; F0C628  lda XBC,XIZ+0xfe
	push	xbc	; F0C62B  push XBC
	call	Var27F5_Get	; F0C62C  call 0xfda0ca
	lda	xbc, (xiz-4)	; F0C630  lda XBC,XIZ+0xfc
	push	xbc	; F0C633  push XBC
	pushw	10	; F0C634  push 0x000a
	lda	xiy, (LcdKeyRow4_SoundEditCopy_Resume:24)	; F0C637  lda XIY,0xf0c63f
	push	xiy	; F0C63C  push XIY
	jp	(xix)	; F0C63D  jp T,XIX
LcdKeyRow4_SoundEditCopy_Resume:
	lda	xbc, (xiz-6)	; F0C63F  lda XBC,XIZ+0xfa
	push	xbc	; F0C642  push XBC
	pushw	11	; F0C643  push 0x000b
	lda	xiy, (LcdKeyRow4_SoundEditCopy_Resume2:24)	; F0C646  lda XIY,0xf0c64e
	push	xiy	; F0C64B  push XIY
	jp	(xix)	; F0C64C  jp T,XIX
LcdKeyRow4_SoundEditCopy_Resume2:
	lda	xbc, (xiz-8)	; F0C64E  lda XBC,XIZ+0xf8
	push	xbc	; F0C651  push XBC
	pushw	0	; F0C652  push 0x0000
	lda	xiy, (LcdKeyRow4_SoundEditCopy_Resume3:24)	; F0C655  lda XIY,0xf0c65d
	push	xiy	; F0C65A  push XIY
	jp	(xix)	; F0C65B  jp T,XIX
LcdKeyRow4_SoundEditCopy_Resume3:
	lda	xbc, (xiz-10)	; F0C65D  lda XBC,XIZ+0xf6
	push	xbc	; F0C660  push XBC
	pushw	1	; F0C661  push 0x0001
	lda	xiy, (LcdKeyRow4_SoundEditCopy_Resume4:24)	; F0C664  lda XIY,0xf0c66c
	push	xiy	; F0C669  push XIY
	jp	(xix)	; F0C66A  jp T,XIX
LcdKeyRow4_SoundEditCopy_Resume4:
	lda	xbc, (xiz-12)	; F0C66C  lda XBC,XIZ+0xf4
	push	xbc	; F0C66F  push XBC
	pushw	2	; F0C670  push 0x0002
	lda	xiy, (LcdKeyRow4_SoundEditCopy_Resume5:24)	; F0C673  lda XIY,0xf0c67b
	push	xiy	; F0C678  push XIY
	jp	(xix)	; F0C679  jp T,XIX
LcdKeyRow4_SoundEditCopy_Resume5:
	add	xsp, 34	; F0C67B  add XSP,0x00000022
	cp	(xiz-2), 0x00	; F0C681  cp (XIZ+0xfe),0x00
	jr	nz, LcdKeyRow4_SoundEditCopy_Skip21	; F0C685  jr NZ,0xf0c693
	cp	(xiz-12), 0x04	; F0C687  cp (XIZ+0xf4),0x04
	jr	nz, LcdKeyRow4_SoundEditCopy_Join12	; F0C68B  jr NZ,0xf0c6b2
	ld	(xiz-10), 0	; F0C68D  ld (XIZ+0xf6),0x00
	jr	LcdKeyRow4_SoundEditCopy_Join12	; F0C691  jr T,0xf0c6b2
LcdKeyRow4_SoundEditCopy_Skip21:
	cp	(xiz-12), 0x02	; F0C693  cp (XIZ+0xf4),0x02
	jr	nz, LcdKeyRow4_SoundEditCopy_Skip22	; F0C697  jr NZ,0xf0c6a1
	ld	(xiz-12), 4	; F0C699  ld (XIZ+0xf4),0x04
	ld	(xiz-10), 0	; F0C69D  ld (XIZ+0xf6),0x00
LcdKeyRow4_SoundEditCopy_Skip22:
	lda	xbc, (xiz-14)	; F0C6A1  lda XBC,XIZ+0xf2
	push	xbc	; F0C6A4  push XBC
	pushw	5	; F0C6A5  push 0x0005
	lda	xiy, (LcdKeyRow4_SoundEditCopy_Resume6:24)	; F0C6A8  lda XIY,0xf0c6b0
	push	xiy	; F0C6AD  push XIY
	jp	(xix)	; F0C6AE  jp T,XIX
LcdKeyRow4_SoundEditCopy_Resume6:
	inc	6, xsp	; F0C6B0  inc 6,XSP
LcdKeyRow4_SoundEditCopy_Join12:
	ld	h, (xiz-10)	; F0C6B2  ld H,(XIZ+0xf6)
	pushw	2	; F0C6B5  push 0x0002
	ld	bc, (xiz-8)	; F0C6B8  ld BC,(XIZ+0xf8)
	extz	bc	; F0C6BB  extz BC
	pushw	bc	; F0C6BD  push BC
	call	U8_ShiftLeft	; F0C6BE  call 0xfd6c94
	ld	l, a	; F0C6C2  ld L,A
	or	l, h	; F0C6C4  or L,H
	pushw	5	; F0C6C6  push 0x0005
	ld	bc, (xiz-12)	; F0C6C9  ld BC,(XIZ+0xf4)
	extz	bc	; F0C6CC  extz BC
	pushw	bc	; F0C6CE  push BC
	call	U8_ShiftLeft	; F0C6CF  call 0xfd6c94
	or	a, l	; F0C6D3  or A,L
	extz	wa	; F0C6D5  extz WA
	pushw	wa	; F0C6D7  push WA
	ld	bc, (xiz-14)	; F0C6D8  ld BC,(XIZ+0xf2)
	extz	bc	; F0C6DB  extz BC
	pushw	bc	; F0C6DD  push BC
	ld	bc, (xiz-6)	; F0C6DE  ld BC,(XIZ+0xfa)
	extz	bc	; F0C6E1  extz BC
	pushw	bc	; F0C6E3  push BC
	ld	bc, (xiz-4)	; F0C6E4  ld BC,(XIZ+0xfc)
	extz	bc	; F0C6E7  extz BC
	pushw	bc	; F0C6E9  push BC
	call	ToneMsg88_Id1A	; F0C6EA  call 0xfd6811
	pushw	35	; F0C6EE  push 0x0023
	pushw	171	; F0C6F1  push 0x00ab
	call	PanelScreen_PostRequestBit6	; F0C6F4  call 0xfd60d9
	pushw	1	; F0C6F8  push 0x0001
	call	Var27FE_Set	; F0C6FB  call 0xfda341
	add	xsp, 22	; F0C6FF  add XSP,0x00000016
LcdKeyRow4_SoundEditCopy_Skip23:
	pop	xix	; F0C705  pop XIX
	popw	hl	; F0C706  pop HL
	unlk XIZ	; F0C707  unlk XIZ
	ret	; F0C709  ret

; --------------------------------------------------------------------------
; ExitKey_SoundEditCopy
; Called from: table 0xFCF80C[285]
; Touches: nothing with an absolute address
; Calls:   0xFDA0CA 0xFD608B
; Evidence: word [285] of the pointer table at 0xFCF80C reads 0x00F0C70A, that
;           table's reader TRANSFERS to the word it loads, and 0xF0C70A is an
;           instruction boundary of this transcription.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ExitKey_SoundEditCopy: the EXIT key on ScreenCode9D -- ScreenCode9D op 15 (PanelOpTable_FCFC44).
;   op k of a PanelOpTable is panel event code k (PanelEvent_ToFieldIndex); the code -> control map is
;   notes/prom_a_panel_control_map.py --map.
ExitKey_SoundEditCopy:
	link XIZ,0xfffe	; F0C70A  link XIZ,0xfffe
	cp	(xiz+8), 0x00	; F0C70E  cp (XIZ+0x08),0x00
	jr	nz, ExitKey_SoundEditCopy_Skip25	; F0C712  jr NZ,0xf0c733
	lda	xbc, (xiz-2)	; F0C714  lda XBC,XIZ+0xfe
	push	xbc	; F0C717  push XBC
	call	Var27F5_Get	; F0C718  call 0xfda0ca
	pop	xiy	; F0C71C  pop XIY
	pushw	0	; F0C71D  push 0x0000
	cp	(xiz-2), 0x00	; F0C720  cp (XIZ+0xfe),0x00
	jr	nz, ExitKey_SoundEditCopy_Skip24	; F0C724  jr NZ,0xf0c72b
	pushw	128	; F0C726  push 0x0080
	jr	ExitKey_SoundEditCopy_Join13	; F0C729  jr T,0xf0c72e
ExitKey_SoundEditCopy_Skip24:
	pushw	203	; F0C72B  push 0x00cb
ExitKey_SoundEditCopy_Join13:
	call	PanelScreen_PostRequest	; F0C72E  call 0xfd608b
	pop	xiy	; F0C732  pop XIY
ExitKey_SoundEditCopy_Skip25:
	unlk XIZ	; F0C733  unlk XIZ

; 0xF0C735-0xF0C7FF -- 203 bytes of 0x0E `ret` padding, which is what bounds the
; module below on this side
	.fill 203, 1, 0x0E
