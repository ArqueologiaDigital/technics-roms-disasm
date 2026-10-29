

; --------------------------------------------------------------------------
; 0xF4C000-0xF4C38C -- THE "CREATOR SELECT / CONTROLLER" SCREEN: three
;   interpreter-A lists, one interpreter-B list, the four entry arrays that
;   B list reads, and a second B list.  Rendered record by record.
; ⚠ REPLACES `DL_F4C000`, filed as 81 records with "Called from: NOT
;   established" and "Unknown: which interpreter runs it" -- both false:
;   Paint_CreatorSelectController and Paint_CreatorSelectControllerNames in this module name every piece with 24-bit
;   `lda` operands and run it through T_DisplayList_Run_Stack (A) or
;   T_DisplayListB_Run_Stack (B).  The record that framed as "op 0x00 with
;   length 134" at 0xF4C2F8 was the flat walk reading the entry arrays at
;   0xF4C2E3 as a record.  Checked by python3 notes/promb-2026-09-25/
;   dl_f4c000.py (the lda/call bytes, every piece's walk, the arrays' tiling).
; --------------------------------------------------------------------------
; --------------------------------------------------------------------------
; DL_CreatorSelectController -- 0xF4C000-0xF4C044, interpreter A: the title,
;   drawn when (0x2870) == 0: CREATOR SELECT (op 0x1C, the title face),
;   CONTROLLER, a 24x24 glyph and two frames.  Run by Paint_CreatorSelectController: `lda
;   XBC,0xF4C045` (the end) / `lda XWA,0xF4C000` / `call
;   T_DisplayList_Run_Stack` at 0xF4C5F3.
; --------------------------------------------------------------------------
DL_CreatorSelectController:
	dl_value_glyph	glyph=36, x=56, y=1
	dl_text16x16_packed	x=85, y=5, text="CREATOR SELECT"
	dl_text8x16	x=312, y=76, text="\021"
	dl_text8x10	x=224, y=78, text="CONTROLLER"
	dl_value_glyph	glyph=36, x=24, y=132
	dl_box	x0=219, y0=72, x1=309, y1=93
	dl_box	x0=222, y0=75, x1=306, y1=90
; --------------------------------------------------------------------------
; DL_CreatorSelectController_Alt -- 0xF4C045-0xF4C070, interpreter A: the
;   same title drawn when (0x2870) != 0 -- the same run call as the first
;   piece, reached through the other arm of `cp (0x2870),0 / jr nz`.  Run by
;   Paint_CreatorSelectController: `lda XBC,0xF4C071` (the end) / `lda XWA,0xF4C045` / `call
;   T_DisplayList_Run_Stack` at 0xF4C5F3.
; --------------------------------------------------------------------------
DL_CreatorSelectController_Alt:
	dl_value_glyph	glyph=36, x=56, y=1
	dl_text16x16_packed	x=85, y=5, text="CREATOR SELECT"
	dl_text8x10	x=24, y=92, text="CONTROLLER"
	dl_value_glyph	glyph=73, x=24, y=132
; --------------------------------------------------------------------------
; DL_CreatorSelectController_Grid -- 0xF4C071-0xF4C2B6, interpreter A:
;   always drawn after the title: two rows of the digits 1-6 and the frames
;   and lines of a six-slot grid.  Run by Paint_CreatorSelectController: `lda XBC,0xF4C2B7`
;   (the end) / `lda XWA,0xF4C071` / `call T_DisplayList_Run_Stack` at
;   0xF4C603.
; --------------------------------------------------------------------------
DL_CreatorSelectController_Grid:
	dl_text8x8_packed	x=199, y=135, text="1"
	dl_text8x8_packed	x=213, y=135, text="2"
	dl_text8x8_packed	x=227, y=135, text="3"
	dl_text8x8_packed	x=241, y=135, text="4"
	dl_text8x8_packed	x=255, y=135, text="5"
	dl_text8x8_packed	x=269, y=135, text="6"
	dl_text8x10	x=48, y=220, text="1"
	dl_text8x10	x=88, y=220, text="2"
	dl_text8x10	x=128, y=220, text="3"
	dl_text8x10	x=176, y=220, text="4"
	dl_text8x10	x=216, y=220, text="5"
	dl_text8x10	x=256, y=220, text="6"
	dl_box	x0=16, y0=104, x1=299, y1=178
	dl_box	x0=53, y0=117, x1=163, y1=130
	dl_box_shadow1	x0=196, y0=132, x1=208, y1=144
	dl_box_shadow1	x0=210, y0=132, x1=222, y1=144
	dl_box_shadow1	x0=224, y0=132, x1=236, y1=144
	dl_box_shadow1	x0=238, y0=132, x1=250, y1=144
	dl_box_shadow1	x0=252, y0=132, x1=264, y1=144
	dl_box_shadow1	x0=266, y0=132, x1=278, y1=144
	dl_box	x0=53, y0=137, x1=163, y1=150
	dl_hline	x0=35, y0=123, x1=53, y1=123
	dl_hline	x0=35, y0=124, x1=53, y1=124
	dl_hline	x0=48, y0=143, x1=53, y1=143
	dl_hline	x0=48, y0=144, x1=53, y1=144
	dl_hline	x0=39, y0=214, x1=65, y1=214
	dl_hline	x0=79, y0=214, x1=105, y1=214
	dl_hline	x0=119, y0=214, x1=145, y1=214
	dl_hline	x0=167, y0=214, x1=193, y1=214
	dl_hline	x0=207, y0=214, x1=233, y1=214
	dl_hline	x0=247, y0=214, x1=273, y1=214
	dl_hline	x0=38, y0=236, x1=67, y1=236
	dl_hline	x0=78, y0=236, x1=107, y1=236
	dl_hline	x0=118, y0=236, x1=147, y1=236
	dl_hline	x0=166, y0=236, x1=195, y1=236
	dl_hline	x0=206, y0=236, x1=235, y1=236
	dl_hline	x0=246, y0=236, x1=275, y1=236
	dl_hline	x0=39, y0=237, x1=66, y1=237
	dl_hline	x0=79, y0=237, x1=106, y1=237
	dl_hline	x0=119, y0=237, x1=146, y1=237
	dl_hline	x0=167, y0=237, x1=194, y1=237
	dl_hline	x0=207, y0=237, x1=234, y1=237
	dl_hline	x0=247, y0=237, x1=274, y1=237
	dl_vline	x0=35, y0=123, x1=35, y1=130
	dl_vline	x0=36, y0=123, x1=36, y1=130
	dl_vline	x0=38, y0=215, x1=38, y1=236
	dl_vline	x0=66, y0=215, x1=66, y1=237
	dl_vline	x0=67, y0=216, x1=67, y1=236
	dl_vline	x0=78, y0=215, x1=78, y1=236
	dl_vline	x0=106, y0=215, x1=106, y1=237
	dl_vline	x0=107, y0=216, x1=107, y1=236
	dl_vline	x0=118, y0=215, x1=118, y1=236
	dl_vline	x0=146, y0=215, x1=146, y1=237
	dl_vline	x0=147, y0=216, x1=147, y1=236
	dl_vline	x0=166, y0=215, x1=166, y1=236
	dl_vline	x0=194, y0=215, x1=194, y1=237
	dl_vline	x0=195, y0=216, x1=195, y1=236
	dl_vline	x0=206, y0=215, x1=206, y1=236
	dl_vline	x0=234, y0=215, x1=234, y1=237
	dl_vline	x0=235, y0=216, x1=235, y1=236
	dl_vline	x0=246, y0=215, x1=246, y1=236
	dl_vline	x0=274, y0=215, x1=274, y1=237
	dl_vline	x0=275, y0=216, x1=275, y1=236
; --------------------------------------------------------------------------
; DLB_CreatorSelectController_Cursor -- 0xF4C2B7-0xF4C2E2, interpreter B:
;   four interpreter-B records on (0x2640): two op-0x04 records (swi 7 fn
;   0x0E, LCD_Svc_0E_ClearColumns, one 6-byte IY/BC/HL entry each since
;   their mask is 0) and two op-0x03 records (fn 5, LCD_Svc_05_FillRect,
;   8-byte x0/y0/x1/y1 entries indexed by (0x2640) & 7).  Paint_CreatorSelectControllerNames sets
;   (0x2640) to the index of the lowest set bit among the low six of
;   IndexedTable_GetByte(25 or 26, 32 + (0x2250)) before running it -- the
;   selected slot of the grid.  Run by Paint_CreatorSelectControllerNames: `lda XBC,0xF4C2E3` (the
;   end) / `lda XWA,0xF4C2B7` / `call T_DisplayListB_Run_Stack` at 0xF4C677.
; --------------------------------------------------------------------------
DLB_CreatorSelectController_Cursor:
	dlb_area_entry	var=UI_DrawScratch, mask=0x00, shift=0, svc=LCDSVC_ClearColumns, table=CreatorSelectController_ClearArea
	dlb_area_entry	var=UI_DrawScratch, mask=0x00, shift=0, svc=LCDSVC_ClearColumns, table=CreatorSelectController_ClearArea2
	dlb_rect_entry	var=UI_DrawScratch, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=CreatorSelectController_Boxes
	dlb_rect_entry	var=UI_DrawScratch, mask=0x07, shift=0, svc=LCDSVC_FillRect, table=CreatorSelectController_Boxes2
; The four entry arrays DLB_CreatorSelectController_Cursor's records point
;   at (+0x07): an op-0x04 entry is IY, BC, HL for swi 7 fn 0x0E; an op-0x03
;   entry is four words for (0x2530)..(0x2536), fn 5.
CreatorSelectController_ClearArea:		; 1 entry of 6 bytes, index (0x2640) & 0x00
	.short	0x1508, 0x000b, 0x0009	; F4C2E3  [0] IY, BC, HL
CreatorSelectController_ClearArea2:		; 1 entry of 6 bytes, index (0x2640) & 0x00
	.short	0x21c5, 0x001e, 0x0013	; F4C2E9  [0] IY, BC, HL
CreatorSelectController_Boxes:		; 8 entries of 8 bytes, index (0x2640) & 0x07
	.short	0x00c6, 0x0086, 0x00ce, 0x008e	; F4C2EF  [0] x0, y0, x1, y1
	.short	0x00d4, 0x0086, 0x00dc, 0x008e	; F4C2F7  [1] x0, y0, x1, y1
	.short	0x00e2, 0x0086, 0x00ea, 0x008e	; F4C2FF  [2] x0, y0, x1, y1
	.short	0x00f0, 0x0086, 0x00f8, 0x008e	; F4C307  [3] x0, y0, x1, y1
	.short	0x00fe, 0x0086, 0x0106, 0x008e	; F4C30F  [4] x0, y0, x1, y1
	.short	0x010c, 0x0086, 0x0114, 0x008e	; F4C317  [5] x0, y0, x1, y1
	.short	0x010c, 0x0086, 0x0114, 0x008e	; F4C31F  [6] x0, y0, x1, y1
	.short	0x010c, 0x0086, 0x0114, 0x008e	; F4C327  [7] x0, y0, x1, y1
CreatorSelectController_Boxes2:		; 8 entries of 8 bytes, index (0x2640) & 0x07
	.short	0x0028, 0x00d8, 0x0040, 0x00ea	; F4C32F  [0] x0, y0, x1, y1
	.short	0x0050, 0x00d8, 0x0068, 0x00ea	; F4C337  [1] x0, y0, x1, y1
	.short	0x0078, 0x00d8, 0x0090, 0x00ea	; F4C33F  [2] x0, y0, x1, y1
	.short	0x00a8, 0x00d8, 0x00c0, 0x00ea	; F4C347  [3] x0, y0, x1, y1
	.short	0x00d0, 0x00d8, 0x00e8, 0x00ea	; F4C34F  [4] x0, y0, x1, y1
	.short	0x00f8, 0x00d8, 0x0110, 0x00ea	; F4C357  [5] x0, y0, x1, y1
	.short	0x00f8, 0x00d8, 0x0110, 0x00ea	; F4C35F  [6] x0, y0, x1, y1
	.short	0x00f8, 0x00d8, 0x0110, 0x00ea	; F4C367  [7] x0, y0, x1, y1
; --------------------------------------------------------------------------
; DLB_CreatorSelectController_Names -- 0xF4C36F-0xF4C38C, interpreter B: two
;   op-0x02 string readouts with source (0x0000) and mask 0 -- entry 0 of
;   the 13-byte string tables at RAM 0x2950 and 0x2940, drawn with swi 7 fn
;   0x20.  Run by Paint_CreatorSelectControllerNames: `lda XBC,0xF4C38D` (the end) / `lda
;   XWA,0xF4C36F` / `call T_DisplayListB_Run_Stack` at 0xF4C61F.
; --------------------------------------------------------------------------
DLB_CreatorSelectController_Names:
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x10, table=0x00002950, width=13, x=56, y=119
	dlb_string	var=0x0000, mask=0x00, shift=0, svc=LCDSVC_DrawText8x10, table=0x00002940, width=13, x=56, y=139


; --------------------------------------------------------------------------
; ScreenButtonHandlers_CreatorSelectController -- 23 32-bit pointers.  15 of them are the DEFAULT
;                         thunk slot 0x00F42C70 (see
;                         notes/prom_b_default_slot_census.py); the other 8
;                         point into this module, at 0xF4C4DD, 0xF4C588,
;                         0xF4C5A2.
; Read by: one site: `add XWA,0x00f4c38d` at 0xF4C4C8.  (The byte scan for
;          the address hits 0xF4C4CA, which is that instruction's OPERAND
;          field, 2 bytes in.)  It is the ONLY site in prom_a or prom_b that
;          spells this address.
; Entry count: 23, and it is not a byte extent divided by four.  The table
;              starts where the display list's framing walk stops (0xF4C38D)
;              and the FIRST byte that is not part of a 4-byte prom_b
;              address is 0xF4C3E9, which is BitMask_F4C3E9 -- and 0xF4C3E9
;              - 0xF4C38D = 92 = 23 x 4 with nothing over.  Entry 22, the
;              last, is 0x00F42C70.
; Evidence: every one of the 23 words is re-read on every emit and asserted
;           to be an address in prom_b's own 0xF00000-0xFFFFFF window; the
;           three non-default targets are additionally asserted to be
;           instruction boundaries of this transcription.
; ⚠ ANSWERED round 11, and the old text -- "nothing decoded here gives its
;          bound" -- is struck.  The PANEL BUTTON CODE indexes it, through
;          PanelCode_ToSlotAndFlags (0xF55019, thunk T_PanelCode_ToSlotAndFlags), which the
;          reader calls before `mul A,4`: it rejects a raw index above 0x1F
;          and folds 0x11..0x19 onto 0..8 and 0x1A..0x1F onto 17..22, so the
;          index space is 0..22.  ★ And the sparseness has a cause: the five
;          slots whose raw codes NOTHING delivers (14, 17, 19, 20, 22 <-
;          codes 0x0E, 0x1A, 0x1C, 0x1D, 0x1F) are the default stub here and
;          in all four of this file's 23-entry tables, 20 of 20, while slot
;          15 -- the EXIT key, raw code 0x0F -- is filled in all four.
;          notes/prom_b_panel_names_round11.py --selftest.
; Unknown: what the handlers do.
; --------------------------------------------------------------------------
; ScreenButtonHandlers_CreatorSelectController: the screen's button table by panel button code -- [9] LcdKeyRow2, [15]
;   ExitKey (2026-10-04).
ScreenButtonHandlers_CreatorSelectController:
	.long	T_TableDefault_Ret	; F4C38D  [0] -> default stub
	.long	SoftKeyCols2to7_CreatorSelectController	; F4C391  [1] -> 0xF4C4DD
	.long	SoftKeyCols2to7_CreatorSelectController	; F4C395  [2] -> 0xF4C4DD
	.long	SoftKeyCols2to7_CreatorSelectController	; F4C399  [3] -> 0xF4C4DD
	.long	SoftKeyCols2to7_CreatorSelectController	; F4C39D  [4] -> 0xF4C4DD
	.long	SoftKeyCols2to7_CreatorSelectController	; F4C3A1  [5] -> 0xF4C4DD
	.long	SoftKeyCols2to7_CreatorSelectController	; F4C3A5  [6] -> 0xF4C4DD
	.long	T_TableDefault_Ret	; F4C3A9  [7] -> default stub
	.long	T_TableDefault_Ret	; F4C3AD  [8] -> default stub
	.long	LcdKeyRow2_CreatorSelectController	; F4C3B1  [9] -> 0xF4C588
	.long	T_TableDefault_Ret	; F4C3B5  [10] -> default stub
	.long	T_TableDefault_Ret	; F4C3B9  [11] -> default stub
	.long	T_TableDefault_Ret	; F4C3BD  [12] -> default stub
	.long	T_TableDefault_Ret	; F4C3C1  [13] -> default stub
	.long	T_TableDefault_Ret	; F4C3C5  [14] -> default stub
	.long	ExitKey_CreatorSelectController	; F4C3C9  [15] -> 0xF4C5A2
	.long	T_TableDefault_Ret	; F4C3CD  [16] -> default stub
	.long	T_TableDefault_Ret	; F4C3D1  [17] -> default stub
	.long	T_TableDefault_Ret	; F4C3D5  [18] -> default stub
	.long	T_TableDefault_Ret	; F4C3D9  [19] -> default stub
	.long	T_TableDefault_Ret	; F4C3DD  [20] -> default stub
	.long	T_TableDefault_Ret	; F4C3E1  [21] -> default stub
	.long	T_TableDefault_Ret	; F4C3E5  [22] -> default stub


; --------------------------------------------------------------------------
; BitMask_F4C3E9 -- 9 bytes: entry 0 is 0x00 and entry k is 1 << (k-1) for k
;                   = 1..8, i.e. 00 01 02 04 08 10 20 40 80.  Content-
;                   descriptive name, asserted byte for byte on every emit.
; Read by: one site: `add XBC,0x00f4c3e9` at 0xF4C6D4.  (The byte scan for
;          the address hits 0xF4C6D6, which is that instruction's OPERAND
;          field, 2 bytes in.)  It is the only site in either ROM that
;          spells the address.
; Entry count: 9, and the END is a thunk target: 0xF4C3F2 is T_ScreenEnter_CreatorSelectController's
;              target, so the byte after this island is an entry point the
;              hardware uses.  The START is where ScreenButtonHandlers_CreatorSelectController's 23
;              pointers stop.
; Evidence: the nine bytes are compared with [0] + [1<<k] on every emit, and
;           0xF4C3F2's thunk slot is re-read from the table.
; Unknown: why index 0 maps to no bit.  A 1-based bit selector with a dead
;          zero entry is the usual shape, but nothing here fixes it.
; --------------------------------------------------------------------------
BitMask_F4C3E9:
	.byte	0x00, 0x01, 0x02, 0x04, 0x08, 0x10, 0x20, 0x40, 0x80	; F4C3E9  [0..8]


; --------------------------------------------------------------------------
; CreatorSelectController_OpenOnEvent
; Called from: T_CreatorSelectController_OpenOnEvent (x0)
; Touches: (0x2070) (0x2075) (0x207C) (0x20B8) (0x20B9) (0x20BA)
; Evidence: thunk slot T_CreatorSelectController_OpenOnEvent holds `jp 0x00F4C3F2`, and 0xF4C3F2 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CreatorSelectController_OpenOnEvent: T_CreatorSelectController_OpenOnEvent, UiListB_ClassA8: byte 5 with bit 2 both changed and set, not on screen 0xAD (CREATOR SELECT
;   CONTROLLER) or 0xAA (the power-on splash), and no request pending (UI_Request_Hi & 0xC2): requests screen 0xAD
;   (UI_Request = 0xAD, UI_Request_Hi |= 0x40, UI_RequestBits bit 7).
CreatorSelectController_OpenOnEvent:		; <- T_CreatorSelectController_OpenOnEvent
	push	xix	; F4C3F2  push XIX
	lda	xix, (UI_Request_Hi:16)	; F4C3F3  lda XIX,0x2071
	cp	(UiEvent_Byte1:16), 0x05	; F4C3F7  cp (0x20b8),0x05
	jr	nz, CreatorSelectController_OpenOnEvent_Epilogue	; F4C3FC  jr NZ,0xf4c42c
	ld	c, (UiEvent_Byte2:16)	; F4C3FE  ld C,(0x20b9)
	and	c, (UiEvent_Byte3:16)	; F4C402  and C,(0x20ba)
	and	c, 4	; F4C406  and C,0x04
	jr	z, CreatorSelectController_OpenOnEvent_Epilogue	; F4C409  jr Z,0xf4c42c
	cp	(UI_ScreenId:16), 0xad	; F4C40B  cp (0x207c),0xad
	jr	z, CreatorSelectController_OpenOnEvent_Epilogue	; F4C410  jr Z,0xf4c42c
	cp	(UI_ScreenId:16), 0xaa	; F4C412  cp (0x207c),0xaa
	jr	z, CreatorSelectController_OpenOnEvent_Epilogue	; F4C417  jr Z,0xf4c42c
	ld	c, (xix)	; F4C419  ld C,(XIX)
	and	c, 194	; F4C41B  and C,0xc2
	jr	nz, CreatorSelectController_OpenOnEvent_Epilogue	; F4C41E  jr NZ,0xf4c42c
	set	7, (UI_RequestBits:16)	; F4C420  set 7,(0x2075)
	or	(xix), 0x40	; F4C424  or (XIX),0x40
	ld	(UI_Request:16), 173	; F4C427  ld (0x2070),0xad
CreatorSelectController_OpenOnEvent_Epilogue:
	pop	xix	; F4C42C  pop XIX
	ret	; F4C42D  ret

; --------------------------------------------------------------------------
; CreatorSelectController_OnPartEvent
; Called from: T_CreatorSelectController_OnPartEvent (x0)
; Touches: (0x207C) (0x2095) (0x20B8) (0x20BB) (0x2250) (0x2870)
; Evidence: thunk slot T_CreatorSelectController_OnPartEvent holds `jp 0x00F4C42E`, and 0xF4C42E is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CreatorSelectController_OnPartEvent: T_CreatorSelectController_OnPartEvent, UiListB_Class20..3F: on screen 0xAD (CREATOR SELECT CONTROLLER), for class 0x20 or a nonzero
;   UI_PartIndex, byte index 0x1A -- 0x19 while (0x2870) is nonzero -- repaints (UI_ScreenFlags bit 4).
CreatorSelectController_OnPartEvent:		; <- T_CreatorSelectController_OnPartEvent
	pushw	hl	; F4C42E  push HL
	cp	(UI_ScreenId:16), 0xad	; F4C42F  cp (0x207c),0xad
	jr	nz, CreatorSelectController_OnPartEvent_Epilogue	; F4C434  jr NZ,0xf4c468
	ldw	hl, 0	; F4C436  ld HL,0x0000
	cp	(UiEvent_Class:16), 0x20	; F4C439  cp (0x20bb),0x20
	jr	nz, CreatorSelectController_OnPartEvent_Skip	; F4C43E  jr NZ,0xf4c443
	ldw	hl, 1	; F4C440  ld HL,0x0001
CreatorSelectController_OnPartEvent_Skip:
	ld	c, (UI_PartIndex:16)	; F4C443  ld C,(0x2250)
	extz	bc	; F4C447  extz BC
	or	bc, hl	; F4C449  or BC,HL
	jr	z, CreatorSelectController_OnPartEvent_Epilogue	; F4C44B  jr Z,0xf4c468
	cp	(0x2870:16), 0x00	; F4C44D  cp (0x2870),0x00
	jr	nz, CreatorSelectController_OnPartEvent_Skip2	; F4C452  jr NZ,0xf4c45d
	cp	(UiEvent_Byte1:16), 0x1a	; F4C454  cp (0x20b8),0x1a
	jr	nz, CreatorSelectController_OnPartEvent_Epilogue	; F4C459  jr NZ,0xf4c468
	jr	CreatorSelectController_OnPartEvent_Join	; F4C45B  jr T,0xf4c464
CreatorSelectController_OnPartEvent_Skip2:
	cp	(UiEvent_Byte1:16), 0x19	; F4C45D  cp (0x20b8),0x19
	jr	nz, CreatorSelectController_OnPartEvent_Epilogue	; F4C462  jr NZ,0xf4c468
CreatorSelectController_OnPartEvent_Join:
	set	4, (UI_ScreenFlags:16)	; F4C464  set 4,(0x2095)
CreatorSelectController_OnPartEvent_Epilogue:
	popw	hl	; F4C468  pop HL
	ret	; F4C469  ret

; --------------------------------------------------------------------------
; ScreenEnter_CreatorSelectController
; Called from: T_ScreenEnter_CreatorSelectController (x0)
; Touches: (0x207C) (0x207D) (0x2095) (0x2870)
; Calls:   T_CallbackQueue_ResetAndRestartTask2 T_CallbackQueue_Post T_Kernel_SemaSignal_StackArg CreatorSelectController_LoadNames
; Evidence: thunk slot T_ScreenEnter_CreatorSelectController holds `jp 0x00F4C46A`, and 0xF4C46A is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenEnter_CreatorSelectController: the +0 ENTER method of the screen object for screen id 0xAD -- PanelScreen_VtableTable entry 0xCD
;   (ViewB entry 0xAD) points at the thunk triple starting at T_ScreenEnter_CreatorSelectController, and slot T_ScreenEnter_CreatorSelectController jumps here.
; ScreenEnter_CreatorSelectController: screen 0xAD's +0 ENTER method.  0xAD is CREATOR SELECT CONTROLLER: the painter
;   it posts, Paint_CreatorSelectController, runs DL_CreatorSelectController (title "CREATOR SELECT", "CONTROLLER").
ScreenEnter_CreatorSelectController:		; <- T_ScreenEnter_CreatorSelectController
	ld	c, (UI_ScreenId:16)	; F4C46A  ld C,(0x207c)
	cp	c, (UI_ScreenId_Previous:16)	; F4C46E  cp C,(0x207d)
	jr	z, ScreenEnter_CreatorSelectController_Skip	; F4C472  jr Z,0xf4c479
	ld	(10352:16), 0	; F4C474  ld (0x2870),0x00
ScreenEnter_CreatorSelectController_Skip:
	ld	c, (UI_ScreenFlags:16)	; F4C479  ld C,(0x2095)
	and	c, 16	; F4C47D  and C,0x10
	jr	nz, ScreenEnter_CreatorSelectController_Skip2	; F4C480  jr NZ,0xf4c499
	call	T_CallbackQueue_ResetAndRestartTask2	; F4C482  call 0xf42e80
	lda	xbc, (Paint_CreatorSelectController:24)	; F4C486  lda XBC,0xf4c5c9
	push	xbc	; F4C48B  push XBC
	call	T_CallbackQueue_Post	; F4C48C  call 0xf42e84
	pushw	1	; F4C490  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F4C493  call 0xf42dc0
	inc	6, xsp	; F4C497  inc 6,XSP
ScreenEnter_CreatorSelectController_Skip2:
	calr	CreatorSelectController_LoadNames	; F4C499  calr 0xf4c684
	lda	xbc, (Paint_CreatorSelectControllerNames:24)	; F4C49C  lda XBC,0xf4c60c
	push	xbc	; F4C4A1  push XBC
	call	T_CallbackQueue_Post	; F4C4A2  call 0xf42e84
	pushw	1	; F4C4A6  push 0x0001
	call	T_Kernel_SemaSignal_StackArg	; F4C4A9  call 0xf42dc0
	inc	6, xsp	; F4C4AD  inc 6,XSP
	ret	; F4C4AF  ret

; --------------------------------------------------------------------------
; UI_RequestBits_ClearBit7
; Called from: T_UI_RequestBits_ClearBit7 (x0)
; Touches: (0x2075)
; Evidence: thunk slot T_UI_RequestBits_ClearBit7 holds `jp 0x00F4C4B0`, and 0xF4C4B0 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; UI_RequestBits_ClearBit7: m_res 7, MD16, UI_RequestBits (single-cell template; the cell's meaning is not established unless it is named)
UI_RequestBits_ClearBit7:		; <- T_UI_RequestBits_ClearBit7
	res	7, (UI_RequestBits:16)	; F4C4B0  res 7,(0x2075)
	ret	; F4C4B4  ret

; --------------------------------------------------------------------------
; ScreenButton_CreatorSelectController
; Called from: T_ScreenButton_CreatorSelectController (x0)
; Touches: nothing with an absolute address
; Calls:   T_PanelCode_ToSlotAndFlags
; Evidence: thunk slot T_ScreenButton_CreatorSelectController holds `jp 0x00F4C4B5`, and 0xF4C4B5 is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; ScreenButton_CreatorSelectController: the +8 BUTTON method of the screen object for screen id 0xAD -- PanelScreen_VtableTable entry 0xCD
;   (ViewB entry 0xAD) points at the thunk triple starting at T_ScreenEnter_CreatorSelectController, and slot T_ScreenButton_CreatorSelectController jumps here.
ScreenButton_CreatorSelectController:		; <- T_ScreenButton_CreatorSelectController
	link XIZ,0x0000	; F4C4B5  link XIZ,0x0000
	pushw	(xiz+10)	; F4C4B9  pushw (XIZ+0x0a)
	pushw	(xiz+8)	; F4C4BC  pushw (XIZ+0x08)
	call	T_PanelCode_ToSlotAndFlags	; F4C4BF  call 0xf42c74
	mul	a, 4	; F4C4C3  mul A,0x04
	extz	xwa	; F4C4C6  extz XWA
	add	xwa, ScreenButtonHandlers_CreatorSelectController	; F4C4C8  add XWA,0x00f4c38d
	ld	xbc, (xwa)	; F4C4CE  ld XBC,(XWA)
	lda	xiy, (ScreenButton_CreatorSelectController_Resume:24)	; F4C4D0  lda XIY,0xf4c4d8
	push	xiy	; F4C4D5  push XIY
	jp	(xbc)	; F4C4D6  jp T,XBC
ScreenButton_CreatorSelectController_Resume:
	pop	xbc	; F4C4D8  pop XBC
	unlk XIZ	; F4C4D9  unlk XIZ
	ret	; F4C4DB  ret

; --------------------------------------------------------------------------
; T_F434EC_Nop
; Called from: T_F434EC (x0)
; Touches: (0x2070) (0x2071) (0x2075) (0x2092) (0x209A) (0x2250) (0x2540)
;          (0x2640) (0x2870) (0x28B0) +1 more
; Calls:   T_IndexedTable_GetPtr T_IndexedTable_GetByte T_List2030_Append4 T_LCD_BlankThenSetPanel3Layer_Copy T_DisplayList_Run_Stack T_DisplayListB_Run_Stack T_LCD_ShowAllLayers_StackFrame_Copy
; Evidence: thunk slot T_F434EC holds `jp 0x00F4C4DC`, and 0xF4C4DC is an
;           instruction boundary of this transcription (re-asserted on every
;           emit).  That is ALL the name rests on -- the name IS the
;           address.
; Purpose: none -- the entry is a lone `ret`.  Named T_F434EC_Nop after what reaches it
;          (was sub_F4C4DC; scripts/renaming/rename_wsa1_nop_routines.py, 2026-10-03).
; --------------------------------------------------------------------------
T_F434EC_Nop:		; <- T_F434EC
	ret	; F4C4DC  ret
; SoftKeyCols2to7_CreatorSelectController: ScreenButtonHandlers_CreatorSelectController slots 1..6 (soft keys 2..7, button codes 1..6): v =
;   CreatorSelect_ButtonCodeToBit(PanelEvent_ButtonCode); when (0x2870) is 0 / 1 and the part's IndexedTable entry
;   0x20 + UI_PartIndex byte 26 / 25 & 0x3F differs from v, T_List2030_Append4(entry, 26 / 25, v, 0x3F) -- one key, one bit
;   of the six.
SoftKeyCols2to7_CreatorSelectController:
	pushw	hl	; F4C4DD  push HL
	push	xix	; F4C4DE  push XIX
	lda	xix, (CreatorSelect_ButtonCodeToBit:24)	; F4C4DF  lda XIX,0xf4c6bf
	ld	h, (UI_PartIndex:16)	; F4C4E4  ld H,(0x2250)
	set	5, h	; F4C4E8  set 0x05,H
	push	0	; F4C4EB  push 0x00
	push	h	; F4C4ED  push H
	call	T_IndexedTable_GetPtr	; F4C4EF  call 0xf42c8c
	ld	bc, (10352:16)	; F4C4F3  ld BC,(0x2870)
	extz	bc	; F4C4F7  extz BC
	popw	wa	; F4C4F9  pop WA
	cp	bc, 0:i3	; F4C4FA  cp BC,0
	jr	z, SoftKeyCols2to7_CreatorSelectController_Skip	; F4C4FC  jr Z,0xf4c505
	cp	bc, 1:i3	; F4C4FE  cp BC,1
	jr	z, SoftKeyCols2to7_CreatorSelectController_Skip2	; F4C500  jr Z,0xf4c541
	jrl	SoftKeyCols2to7_CreatorSelectController_Epilogue	; F4C502  jrl T,0xf4c585
SoftKeyCols2to7_CreatorSelectController_Skip:
	push	0	; F4C505  push 0x00
	push	(PanelEvent_ButtonCode:16)	; F4C507  push (0x28b1)
	lda	xiy, (SoftKeyCols2to7_CreatorSelectController_Resume:24)	; F4C50B  lda XIY,0xf4c513
	push	xiy	; F4C510  push XIY
	jp	(xix)	; F4C511  jp T,XIX
SoftKeyCols2to7_CreatorSelectController_Resume:
	ld	l, a	; F4C513  ld L,A
	pushw	26	; F4C515  push 0x001a
	push	0	; F4C518  push 0x00
	push	h	; F4C51A  push H
	call	T_IndexedTable_GetByte	; F4C51C  call 0xf42c90
	and	a, 63	; F4C520  and A,0x3f
	inc	6, xsp	; F4C523  inc 6,XSP
	cp	a, l	; F4C525  cp A,L
	jr	z, SoftKeyCols2to7_CreatorSelectController_Epilogue	; F4C527  jr Z,0xf4c585
	pushw	63	; F4C529  push 0x003f
	push	0	; F4C52C  push 0x00
	push	(PanelEvent_ButtonCode:16)	; F4C52E  push (0x28b1)
	lda	xiy, (SoftKeyCols2to7_CreatorSelectController_Resume2:24)	; F4C532  lda XIY,0xf4c53a
	push	xiy	; F4C537  push XIY
	jp	(xix)	; F4C538  jp T,XIX
SoftKeyCols2to7_CreatorSelectController_Resume2:
	popw	bc	; F4C53A  pop BC
	pushw	wa	; F4C53B  push WA
	pushw	26	; F4C53C  push 0x001a
	jr	SoftKeyCols2to7_CreatorSelectController_Join	; F4C53F  jr T,0xf4c57b
SoftKeyCols2to7_CreatorSelectController_Skip2:
	push	0	; F4C541  push 0x00
	push	(PanelEvent_ButtonCode:16)	; F4C543  push (0x28b1)
	lda	xiy, (SoftKeyCols2to7_CreatorSelectController_Resume3:24)	; F4C547  lda XIY,0xf4c54f
	push	xiy	; F4C54C  push XIY
	jp	(xix)	; F4C54D  jp T,XIX
SoftKeyCols2to7_CreatorSelectController_Resume3:
	ld	l, a	; F4C54F  ld L,A
	pushw	25	; F4C551  push 0x0019
	push	0	; F4C554  push 0x00
	push	h	; F4C556  push H
	call	T_IndexedTable_GetByte	; F4C558  call 0xf42c90
	and	a, 63	; F4C55C  and A,0x3f
	inc	6, xsp	; F4C55F  inc 6,XSP
	cp	a, l	; F4C561  cp A,L
	jr	z, SoftKeyCols2to7_CreatorSelectController_Epilogue	; F4C563  jr Z,0xf4c585
	pushw	63	; F4C565  push 0x003f
	push	0	; F4C568  push 0x00
	push	(PanelEvent_ButtonCode:16)	; F4C56A  push (0x28b1)
	lda	xiy, (SoftKeyCols2to7_CreatorSelectController_Resume4:24)	; F4C56E  lda XIY,0xf4c576
	push	xiy	; F4C573  push XIY
	jp	(xix)	; F4C574  jp T,XIX
SoftKeyCols2to7_CreatorSelectController_Resume4:
	popw	bc	; F4C576  pop BC
	pushw	wa	; F4C577  push WA
	pushw	25	; F4C578  push 0x0019
SoftKeyCols2to7_CreatorSelectController_Join:
	push	0	; F4C57B  push 0x00
	push	h	; F4C57D  push H
	call	T_List2030_Append4	; F4C57F  call 0xf42c88
	inc	8, xsp	; F4C583  inc 0,XSP
SoftKeyCols2to7_CreatorSelectController_Epilogue:
	pop	xix	; F4C585  pop XIX
	popw	hl	; F4C586  pop HL
	ret	; F4C587  ret
; ---------------------------------------------------------------------
; LcdKeyRow2_CreatorSelectController -- row 2 of the five key pairs flanking the LCD, on
;           the ScreenCodeAD screen
; Reached by: SW26 "LCD RIGHT 2" (matrix segment 3 bit 1, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6A6
;           {class 0xA9, code 0x09} -> delivered code 0x09; SW74 "LCD LEFT 2"
;           (matrix segment 9 bit 1, wire 0xC9) ->
;           PanelWireGroupMap_Variant2[0x69] = group 0x08 -> record 0xF8B723
;           {class 0xA9, code 0x09} -> delivered code 0x89. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           ScreenButton_CreatorSelectController calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_F42C74 and then `mul A,0x04 / add
;           XWA,0x00f4c38d` at 0xF4C4C8, so the index is the REMAPPED SLOT and
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
;           sub_F954AA masks segment 3 with 0x0F and dispatches bits 0..3 four
;           separate ways -- the four boxes page I-12 annotates (1)..(4) MAIN
;           OUT / SUB OUT 1 / SUB OUT 2 / SUB OUT 3 for the Generator IC
;           Outsel check. SW26 is row 2 of that column. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
LcdKeyRow2_CreatorSelectController:
	ld	c, (PanelEvent_Flags:16)	; F4C588  ld C,(0x28b0)
	and	c, 1	; F4C58C  and C,0x01
	jr	nz, LcdKeyRow2_CreatorSelectController_Return	; F4C58F  jr NZ,0xf4c5a1
	cp	(0x2870:16), 0x00	; F4C591  cp (0x2870),0x00
	jr	nz, LcdKeyRow2_CreatorSelectController_Return	; F4C596  jr NZ,0xf4c5a1
	ld	(10352:16), 1	; F4C598  ld (0x2870),0x01
	set	4, (UI_Request_Hi:16)	; F4C59D  set 4,(0x2071)
LcdKeyRow2_CreatorSelectController_Return:
	ret	; F4C5A1  ret
; ---------------------------------------------------------------------
; ExitKey_CreatorSelectController -- the EXIT key, on the ScreenCodeAD screen
; Reached by: SW32 "EXIT" (matrix segment 3 bit 7, wire 0xC3) ->
;           PanelWireGroupMap_Variant2[0x63] = group 0x03 -> record 0xF8B6BE
;           {class 0xA9, code 0x0F} -> delivered code 0x0F. prom_a
;           PanelButton_Route masks the code `and L,0x1f` at 0xF861AE as
;           always, but THIS screen is dispatched by the OTHER family:
;           ScreenButton_CreatorSelectController calls PanelCode_ToSlotAndFlags (prom_b
;           0xF55019) through thunk T_F42C74 and then `mul A,0x04 / add
;           XWA,0x00f4c38d` at 0xF4C4C8, so the index is the REMAPPED SLOT and
;           this is slot 15 of the 23.
; Note:     ⚠ TWO TABLE FAMILIES, TWO INDEX RULES, and this is the 23-entry
;           one. The remap is the IDENTITY below 0x11: `cp (0x28B1),0x11 / jr
;           C` at 0xF5505E skips the -0x11 arm and `cp (0x28B1),0x1a / jr C`
;           at 0xF5507A skips the -9 arm, leaving HL as loaded at 0xF55023, so
;           slot 0x0F IS code 0x0F here. Two names already in this table
;           corroborate that independently: slot 15 is ExitKey_DrawbarScreen
;           (code 0x0F) and slot 16 is PageKey_DrawbarScreen (code 0x10), both
;           applied in round 11 from the consumer side alone.
; Note:     bit 7 of the delivered code picks THE SIDE OF THE DISPLAY: set =
;           the CP2 column (SW73-77), clear = the CP1 column (SW25-29).
; Variant:  ⚠ VARIANT 2 = the SX-WSA1R, and the chain above is variant 2's;
;           the SX-WSA1 (variant 1) feeds the same slot from SW88 [no legend:
;           matrix position outside every diode list] (segment 10 bit 7, NOT
;           fitted on this panel). The model strap is the RAM byte (0x00C4),
;           latched from PB bit 0 by prom_a Variant_SetFromPB0 at 0xF82882;
;           variant 2 is the SX-WSA1R (notes/wave7_panel_names_round11.py
;           --variant, three independent measurements).
; Evidence: GRADE POSITION in notes/wave7_panel_button_codes.py --physical,
;           with a consumer-side anchor: slot 0x0F is the ONLY one of the 32
;           slots that holds a real routine in ALL 32 screen tables. The
;           wire->group->record->code->slot chain above is re-derived from the
;           ROM bytes by notes/prom_b_panel_names_round12.py --plan, which
;           reads notes/wave7_panel_button_codes.py (layer 1) and
;           notes/wave7_panel_event_index.py (layer 2).
; ---------------------------------------------------------------------
ExitKey_CreatorSelectController:
	ld	c, (PanelEvent_Flags:16)	; F4C5A2  ld C,(0x28b0)
	and	c, 1	; F4C5A6  and C,0x01
	jr	nz, ExitKey_CreatorSelectController_Return	; F4C5A9  jr NZ,0xf4c5c8
	ld	c, (UI_ScreenHoldState:16)	; F4C5AB  ld C,(0x2092)
	and	c, 1	; F4C5AF  and C,0x01
	jr	z, ExitKey_CreatorSelectController_Skip	; F4C5B2  jr Z,0xf4c5bf
	res	7, (UI_RequestBits:16)	; F4C5B4  res 7,(0x2075)
	ld	(UI_ScreenHoldPending:16), 1	; F4C5B8  ld (0x209a),0x01
	jr	ExitKey_CreatorSelectController_Return	; F4C5BD  jr T,0xf4c5c8
ExitKey_CreatorSelectController_Skip:
	set	1, (UI_Request_Hi:16)	; F4C5BF  set 1,(0x2071)
	ld	(UI_Request:16), 1	; F4C5C3  ld (0x2070),0x01
ExitKey_CreatorSelectController_Return:
	ret	; F4C5C8  ret
; Paint_CreatorSelectController: layer 0; DL_CreatorSelectController (the title) .. _Alt when (0x2870) = 0, else
;   DL_CreatorSelectController_Alt .. _Grid; then _Grid .. DLB_CreatorSelectController_Cursor.  Posted by ScreenEnter_CreatorSelectController.
Paint_CreatorSelectController:
	call	T_LCD_BlankThenSetPanel3Layer_Copy	; F4C5C9  call 0xf42e10
	ld	(LCD_CurrentLayer:16), 0	; F4C5CD  ld (0x2540),0x00
	cp	(0x2870:16), 0x00	; F4C5D2  cp (0x2870),0x00
	jr	nz, Paint_CreatorSelectController_Skip2	; F4C5D7  jr NZ,0xf4c5e7
	lda	xbc, (DL_CreatorSelectController_Alt:24)	; F4C5D9  lda XBC,0xf4c045
	push	xbc	; F4C5DE  push XBC
	lda	xwa, (DL_CreatorSelectController:24)	; F4C5DF  lda XWA,0xf4c000
	push	xwa	; F4C5E4  push XWA
	jr	Paint_CreatorSelectController_Join	; F4C5E5  jr T,0xf4c5f3
Paint_CreatorSelectController_Skip2:
	lda	xbc, (DL_CreatorSelectController_Grid:24)	; F4C5E7  lda XBC,0xf4c071
	push	xbc	; F4C5EC  push XBC
	lda	xwa, (DL_CreatorSelectController_Alt:24)	; F4C5ED  lda XWA,0xf4c045
	push	xwa	; F4C5F2  push XWA
Paint_CreatorSelectController_Join:
	call	T_DisplayList_Run_Stack	; F4C5F3  call 0xf42e00
	lda	xbc, (DLB_CreatorSelectController_Cursor:24)	; F4C5F7  lda XBC,0xf4c2b7
	push	xbc	; F4C5FC  push XBC
	lda	xwa, (DL_CreatorSelectController_Grid:24)	; F4C5FD  lda XWA,0xf4c071
	push	xwa	; F4C602  push XWA
	call	T_DisplayList_Run_Stack	; F4C603  call 0xf42e00
	inc	8, xsp	; F4C607  inc 0,XSP
	inc	8, xsp	; F4C609  inc 0,XSP
	ret	; F4C60B  ret
; Paint_CreatorSelectControllerNames: layer 0; the interpreter-B list DLB_CreatorSelectController_Names, then the
;   current part's byte 26 (25 when (0x2870) is not 0) of IndexedTable as a bit map.  Posted by ScreenEnter_CreatorSelectController.
Paint_CreatorSelectControllerNames:
	pushw	hl	; F4C60C  push HL
	push	xix	; F4C60D  push XIX
	ld	(LCD_CurrentLayer:16), 0	; F4C60E  ld (0x2540),0x00
	lda	xbc, (ScreenButtonHandlers_CreatorSelectController:24)	; F4C613  lda XBC,0xf4c38d
	push	xbc	; F4C618  push XBC
	lda	xwa, (DLB_CreatorSelectController_Names:24)	; F4C619  lda XWA,0xf4c36f
	push	xwa	; F4C61E  push XWA
	call	T_DisplayListB_Run_Stack	; F4C61F  call 0xf42e04
	lda	xix, (UI_DrawScratch:16)	; F4C623  lda XIX,0x2640
	inc	8, xsp	; F4C627  inc 0,XSP
	cp	(0x2870:16), 0x00	; F4C629  cp (0x2870),0x00
	jr	nz, Paint_CreatorSelectControllerNames_Skip3	; F4C62E  jr NZ,0xf4c635
	pushw	26	; F4C630  push 0x001a
	jr	Paint_CreatorSelectControllerNames_Join2	; F4C633  jr T,0xf4c638
Paint_CreatorSelectControllerNames_Skip3:
	pushw	25	; F4C635  push 0x0019
Paint_CreatorSelectControllerNames_Join2:
	ld	c, (UI_PartIndex:16)	; F4C638  ld C,(0x2250)
	extz	bc	; F4C63C  extz BC
	add	bc, 32	; F4C63E  add BC,0x0020
	pushw	bc	; F4C642  push BC
	call	T_IndexedTable_GetByte	; F4C643  call 0xf42c90
	ld	(xix), a	; F4C647  ld (XIX),A
	ld	l, 1:opc	; F4C649  ld L,0x01
	ld	h, 0:opc	; F4C64B  ld H,0x00
	pop	xiy	; F4C64D  pop XIY
Paint_CreatorSelectControllerNames_Loop:
	ld	c, (UI_DrawScratch:16)	; F4C64E  ld C,(0x2640)
	and	c, l	; F4C652  and C,L
	jr	z, Paint_CreatorSelectControllerNames_Skip4	; F4C654  jr Z,0xf4c65a
	ld	(xix), h	; F4C656  ld (XIX),H
	jr	Paint_CreatorSelectControllerNames_Join3	; F4C658  jr T,0xf4c666
Paint_CreatorSelectControllerNames_Skip4:
	ld	c, l	; F4C65A  ld C,L
	add	c, l	; F4C65C  add C,L
	ld	l, c	; F4C65E  ld L,C
	inc	1, h	; F4C660  inc 1,H
	cp	h, 6:i3	; F4C662  cp H,6
	jr	c, Paint_CreatorSelectControllerNames_Loop	; F4C664  jr C,0xf4c64e
Paint_CreatorSelectControllerNames_Join3:
	ld	(LCD_CurrentLayer:16), 1	; F4C666  ld (0x2540),0x01
	lda	xbc, (CreatorSelectController_ClearArea:24)	; F4C66B  lda XBC,0xf4c2e3
	push	xbc	; F4C670  push XBC
	lda	xwa, (DLB_CreatorSelectController_Cursor:24)	; F4C671  lda XWA,0xf4c2b7
	push	xwa	; F4C676  push XWA
	call	T_DisplayListB_Run_Stack	; F4C677  call 0xf42e04
	call	T_LCD_ShowAllLayers_StackFrame_Copy	; F4C67B  call 0xf42e14
	inc	8, xsp	; F4C67F  inc 0,XSP
	pop	xix	; F4C681  pop XIX
	popw	hl	; F4C682  pop HL
	ret	; F4C683  ret

; --------------------------------------------------------------------------
; CreatorSelectController_LoadNames
; Called from: in-module: 0xF4C499
; Touches: (0x2250) (0x2870)
; Calls:   T_IndexedTable_GetPtr CreatorSelectController_CopyNameLabels
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C684 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CreatorSelectController_LoadNames: With (0x2870) = 0 / 1 takes the current part's IndexedTable entry 0x20 +
;   UI_PartIndex byte 26 / 25, & 0x3F (the bits SoftKeyCols2to7_CreatorSelectController toggle), and has CreatorSelectController_CopyNameLabels
;   look (part, bits) up through T_CreatorSelect_ReadSlotLabelIds and copy two 13-character labels to 0x2940 and 0x2950 -- the strings
;   DLB_CreatorSelectController_Names draws. ScreenEnter_CreatorSelectController runs it before posting
;   Paint_CreatorSelectControllerNames. Basis: caller + body + display list. (notes/naming-
;   pilot-2026-10-06/proposals_wave4_k.json)
CreatorSelectController_LoadNames:
	push	xix	; F4C684  push XIX
	ld	c, (UI_PartIndex:16)	; F4C685  ld C,(0x2250)
	set	5, c	; F4C689  set 0x05,C
	pushw	bc	; F4C68C  push BC
	call	T_IndexedTable_GetPtr	; F4C68D  call 0xf42c8c
	ld	xix, xiy	; F4C691  ld XIX,XIY
	ld	bc, (10352:16)	; F4C693  ld BC,(0x2870)
	extz	bc	; F4C697  extz BC
	popw	wa	; F4C699  pop WA
	cp	bc, 0:i3	; F4C69A  cp BC,0
	jr	z, CreatorSelectController_LoadNames_Skip	; F4C69C  jr Z,0xf4c6a4
	cp	bc, 1:i3	; F4C69E  cp BC,1
	jr	z, CreatorSelectController_LoadNames_Skip2	; F4C6A0  jr Z,0xf4c6ad
	jr	CreatorSelectController_LoadNames_Epilogue	; F4C6A2  jr T,0xf4c6bd
CreatorSelectController_LoadNames_Skip:
	ld	c, (xix+26)	; F4C6A4  ld C,(XIX+0x1a)
	and	c, 63	; F4C6A7  and C,0x3f
	pushw	bc	; F4C6AA  push BC
	jr	CreatorSelectController_LoadNames_Join	; F4C6AB  jr T,0xf4c6b4
CreatorSelectController_LoadNames_Skip2:
	ld	c, (xix+25)	; F4C6AD  ld C,(XIX+0x19)
	and	c, 63	; F4C6B0  and C,0x3f
	pushw	bc	; F4C6B3  push BC
CreatorSelectController_LoadNames_Join:
	ld	c, (UI_PartIndex:16)	; F4C6B4  ld C,(0x2250)
	pushw	bc	; F4C6B8  push BC
	calr	CreatorSelectController_CopyNameLabels	; F4C6B9  calr 0xf4c6e0
	pop	xiy	; F4C6BC  pop XIY
CreatorSelectController_LoadNames_Epilogue:
	pop	xix	; F4C6BD  pop XIX
	ret	; F4C6BE  ret
; CreatorSelect_ButtonCodeToBit: (code): BitMask_F4C3E9[code], 0 for code above 8 -- 0, 1, 2, 4 ... 0x80.
CreatorSelect_ButtonCodeToBit:
	link XIZ,0x0000	; F4C6BF  link XIZ,0x0000
	pushw	hl	; F4C6C3  push HL
	ld	h, (xiz+8)	; F4C6C4  ld H,(XIZ+0x08)
	cp	h, 8	; F4C6C7  cp H,0x08
	jr	ule, CreatorSelect_ButtonCodeToBit_Skip3	; F4C6CA  jr ULE,0xf4c6ce
	ld	h, 0:opc	; F4C6CC  ld H,0x00
CreatorSelect_ButtonCodeToBit_Skip3:
	ld	c, h	; F4C6CE  ld C,H
	extz	bc	; F4C6D0  extz BC
	extz	xbc	; F4C6D2  extz XBC
	add	xbc, BitMask_F4C3E9	; F4C6D4  add XBC,0x00f4c3e9
	ld	a, (xbc)	; F4C6DA  ld A,(XBC)
	popw	hl	; F4C6DC  pop HL
	unlk XIZ	; F4C6DD  unlk XIZ
	ret	; F4C6DF  ret

; --------------------------------------------------------------------------
; CreatorSelectController_CopyNameLabels
; Called from: in-module: 0xF4C6B9
; Touches: (0x2641) (0x2642)  |  0x0022F0 0x002940 0x002950
; Calls:   T_CreatorSelect_ReadSlotLabelIds T_UiText_CopyLabel13_To_22F0
; Evidence: reached by a `call`/`calr` decoded in this transcription (the
;           sites are listed above), so 0xF4C6E0 is an instruction boundary.
;           The name IS the address.
; Unknown: what the routine is FOR.  Left as sub_XXXXXX with the gap stated,
;          per this tree's rule that a stated gap beats a plausible guess.
; --------------------------------------------------------------------------
; CreatorSelectController_CopyNameLabels: (part, bits): looks the pair up through T_CreatorSelect_ReadSlotLabelIds and copies the two
;   13-character labels it names (T_UiText_CopyLabel13_To_22F0) to 0x2940 and 0x2950 -- the strings
;   DLB_CreatorSelectController_Names draws. CreatorSelectController_LoadNames' worker. Basis: caller header + body.
;   (notes/naming-pilot-2026-10-06/proposals_wave5_p.json)
CreatorSelectController_CopyNameLabels:
	link XIZ,0x0000	; F4C6E0  link XIZ,0x0000
	ld	c, (xiz+8)	; F4C6E4  ld C,(XIZ+0x08)
	ld	(UI_DrawScratch+1:16), c	; F4C6E7  ld (0x2641),C
	ld	a, (xiz+10)	; F4C6EB  ld A,(XIZ+0x0a)
	ld	(UI_DrawScratch+2:16), a	; F4C6EE  ld (0x2642),A
	push	xde	; F4C6F2  push XDE
	push	xhl	; F4C6F3  push XHL
	push	xix	; F4C6F4  push XIX
	push	xiz	; F4C6F5  push XIZ
	ld	w, (UI_DrawScratch+1:16)	; F4C6F6  ld W,(0x2641)
	ld	a, (UI_DrawScratch+2:16)	; F4C6FA  ld A,(0x2642)
	call	T_CreatorSelect_ReadSlotLabelIds	; F4C6FE  call 0xf41038
	ld	a, (xiy)	; F4C702  ld A,(XIY)
	push	xiy	; F4C704  push XIY
	call	T_UiText_CopyLabel13_To_22F0	; F4C705  call 0xf43330
	ld	xiy, DiskSave_PasswordEntry	; F4C709  ld XIY,0x000022f0
	ld	xix, 10560	; F4C70E  ld XIX,0x00002940
	ldw	bc, 7	; F4C713  ld BC,0x0007
	ldirw	; F4C716  ldirw
	pop	xiy	; F4C718  pop XIY
	ld	a, (xiy+1)	; F4C719  ld A,(XIY+0x01)
	call	T_UiText_CopyLabel13_To_22F0	; F4C71C  call 0xf43330
	ld	xiy, DiskSave_PasswordEntry	; F4C720  ld XIY,0x000022f0
	ld	xix, 10576	; F4C725  ld XIX,0x00002950
	ldw	bc, 7	; F4C72A  ld BC,0x0007
	ldirw	; F4C72D  ldirw
	pop	xiz	; F4C72F  pop XIZ
	pop	xix	; F4C730  pop XIX
	pop	xhl	; F4C731  pop XHL
	pop	xde	; F4C732  pop XDE
	unlk XIZ	; F4C733  unlk XIZ
	ret	; F4C735  ret
	.fill	202, 1, 0x0E	; F4C736-F4C7FF  `ret` padding (asserted pure 0x0E)
