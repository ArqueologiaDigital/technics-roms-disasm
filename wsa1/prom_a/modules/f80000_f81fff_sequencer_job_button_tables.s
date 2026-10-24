; ==============================================================================
; 0xF80000-0xF826A8 -- CONVERTED 2026-08-25 (wave 5 round 3).  This banner said
; "not yet converted"; the module banner immediately below it is the live one.
; notes/prom_a_byte_checks.py fails if a "not yet converted" banner has no
; `.incbin` under it, and that is what caught this one.
; ==============================================================================
wsa1_prom_a:
; ==============================================================================
; 0xF80000-0xF826A8 -- THE BOOT BLOCK: the UI blink veneers, and the
; MODULE-INITIALISATION DIRECTORY the whole machine is brought up by
; ==============================================================================
;
; Converted 2026-08-25 (wave 5 round 3).  It is the LAST large span of prom_a
; that had never been decoded at all, and it is where the machine starts: the
; RESET vector lands at 0xFFF081 -> ... -> 0xF826A9, four bytes above the end of
; this block, and the directory this block ends with is what that code walks.
;
; Two things in it are established, and the rest is deliberately `sub_XXXXXX`.
;
; ★★ 1. THE MODULE-INITIALISATION DIRECTORY, 0xF82641-0xF826A8.
;   26 LE32 words: 25 addresses inside prom_b's directory 0xF40000-0xF44018,
;   then 0xFFFFFFFF.  The walker is at 0xF82846-0xF8286F, twelve instructions:
;
;       XHL = 0x00F82641
;   loop: XIX = (XHL+)              ; next directory entry
;       if XIX == 0xFFFFFFFF: done  ; the terminator
;       XIX = (XIX)                 ; the module's PHASE VECTOR base
;       if XIX == 0x0E0E0E0E: skip  ; four RET bytes = module absent
;       XIX = XIX + WA              ; WA = the PHASE, 0x00/04/08/0C/10
;       call (XIX)
;
;   So each directory word points at a prom_b word that holds the module's own
;   phase-vector base, and each module publishes FIVE entry points four bytes
;   apart.  Five callers set WA and fall into the walker -- 0xF82832 (WA=0x00),
;   0xF82836 (0x04), 0xF8283A (0x08), 0xF8283E (0x0C), 0xF82842 (0x10) -- so the
;   boot is FIVE PASSES over the same 25 modules, not one pass over 125 routines.
; Evidence: the walker's own instructions, plus the first entry read straight
;   out of prom_b: (0x00F40000) = 0x00F82010, and 0xF82010 in THIS block is six
;   consecutive `jp` slots (0xF825D4, 0xF8262F, 0xF82628, 0xF8262F x3) -- a phase
;   vector, in the image the directory says it is in.  Re-derived by
;   notes/prom_a_boot_checks.py, which reads all 26 words and all 25 vectors.
; Unknown: what each phase MEANS.  The five are named Phase0..Phase4 by their
;   offset and by nothing else; no routine here says "this one is the RAM clear".
;
; ★ 2. FIVE BLINK-ARGUMENT TABLES, one idiom, 0xF8024D 0xF80754 0xF80AAD
;   0xF80E12 0xF81344.  Each is read by the SAME twelve-byte shape:
;
;       bit 1,(0x2075) / jr Z,out        ; UI enabled?
;       cp (0x2267),0x0F / jr Z,out
;       xor XWA,XWA / ld A,(<var>) / sla 0x02,XWA
;       ld XIY,<table> / ld XIY,(XIY+WA)
;       push XIY / call 0xF42E20        ; -> prom_b Blink_Command
;
;   so the tables hold LE32 pointers into prom_b's display-list region and the
;   index is a one-byte UI variable.  The five variables are (0x0DE5), (0x0DED),
;   (0x0DBC), (0x0DDA) and (0x0C0F) in that order.
; Evidence: the eight sites of `ld XIY,imm32 / ld XIY,(XIY+WA)` in the whole of
;   prom_a are censused by notes/prom_a_boot_checks.py; five are here and their
;   tables are these five.  T_Blink_Command (T_F42E20) -> prom_b 0xF0E9CF is `Blink_Command`
;   (notes/FINDINGS-prom_b-field-blink.md), which takes one pushed pointer.
; ENTRY COUNTS 5, 6, 7, 7 and 3, and how they are established: read LE32 words
;   from the base until one is neither 0 nor an address inside 0xF00000-0xFFFFFF.
;   ★ LAST-ENTRY TEST: in every one of the five the first REJECTED word begins
;   `1D 80 2E F4` or `F1 40 25 00` -- `call 0xF42E80` / `ld (0x2540),0x00` -- i.e.
;   exactly where the linear decode resynchronises on real code.  One entry more
;   or fewer moves that boundary off an instruction.  Asserted in
;   notes/prom_a_boot_checks.py.
; ⚠ NOT ESTABLISHED: what the five variables select between, and why entries
;   0 and 1 of four of the tables are NULL.
;
; The rest of the block is 123 `sub_XXXXXX` routines of the same family -- test a
; UI flag, push a prom_b display-list address, call a T_F417xx/T_F42Exx
; interpreter entry -- and they are `sub_XXXXXX` because nothing here says WHICH
; screen.  Nine labels in the span are semantic, and all nine are data.
; ==============================================================================
; AdvanceDelay_SelectField1 -- the prom_a half of prom_b's LcdKeyRow1_AdvanceDelay_StageZero: select field 1 of the ADVANCE/DELAY screen
; Evidence: that handler's last instructions `bit 7,W / jr Z,0xF80019` (0xF7FFFB-0xF7FFFF) fall through the chip boundary into 0xF80000; nothing calls or names 0xF80000 (24-bit scan of prom_a/b/c).
; Body: if (0x0DE5)!=1, calr 0xF7F245 (Blink_SetEnable(0) + Blink_Stop); or (0x2075),1; T_AdvanceDelay_SelectField1 = prom_b 0xF7CB1E sets (0x0DE5)=(0x12FC)=1; AdvanceDelay_DrawValues; AdvanceDelay_DrawFieldCursor.
; Rows 2-4 (slots 9-11 of ButtonTable_AdvanceDelay_StageZero, 0xF8003A/0xF80059/0xF8009D) select fields 2-4 the same way through T_AdvanceDelay_SelectField2/70/74.
AdvanceDelay_SelectField1:
	cp	(AdvanceDelay_Field:16), 0x01                            ; F80000  c1 e5 0d 3f 01
	jr z, AdvanceDelay_SelectField1_Ret                                       ; F80005  66 12
	calr Blink_DisableThenStop                                          ; F80007  1e 3b f2
	or	(UI_RequestBits:16), 0x01                            ; F8000A  c1 75 20 3e 01
	call T_AdvanceDelay_SelectField1                                        ; F8000F  1d 68 2a f4
	calr AdvanceDelay_DrawValues                                      ; F80013  1e 70 00
	calr AdvanceDelay_DrawFieldCursor                                      ; F80016  1e 01 00
AdvanceDelay_SelectField1_Ret:
	ret                                                  ; F80019  0e
; AdvanceDelay_DrawFieldCursor -- clear LCD layer 1, then fill the box of the ADVANCE/DELAY field (0x12FC) selects
; Evidence: (0x2540)=1; site 0xF8002C runs DL_F39551-0xF39559 (interpreter A), one op-0E record = svc 0x0E LCD_Svc_0E_ClearColumns with IY=0, BC=0x28, HL=0xF0 (40 columns x 240 rows); then T_F4181C (jp DLB_Handler_Array8) on the op-03 record 0xF3B3A7: (0x12FC)&7 indexes DLBoxes_F3B3B2, swi 5 = LCD_Svc_05_FillRect.
; Screen: ADVANCE/DELAY -- callers are AdvanceDelay_SelectField1 and the row-key handlers of ButtonTable_AdvanceDelay_StageZero at 0xF8003A-0xF800BB; (0x12FC) is written with (0x0DE5) by T_AdvanceDelay_SelectField1..T_AdvanceDelay_SelectField4.
; calr 0xF7E2D8 at 0xF8001F is a bare `ret` in prom_b.
AdvanceDelay_DrawFieldCursor:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F8001A  f1 40 25 00 01
	calr ButtonTable_SequencerMedley_Nop                                          ; F8001F  1e b6 e2
	ld XIY,DL_F39551                                     ; F80022  45 51 95 f3 00
	ld XIX,Data_F39559                                   ; F80027  44 59 95 f3 00
	call T_DisplayList_Run                               ; F8002C  1d f0 17 f4
	ld XIY,0x00f3b3a7                                    ; F80030  45 a7 b3 f3 00
	call T_DLB_Handler_Array8                                        ; F80035  1d 1c 18 f4
	ret                                                  ; F80039  0e
; LcdKeyRow2_AdvanceDelay_StageZero: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_AdvanceDelay_StageZero slot 0x09.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow2_AdvanceDelay_StageZero:
	bit 0x07,W                                           ; F8003A  c8 33 07
	jr z, .LF80058                                       ; F8003D  66 19
	cp	(AdvanceDelay_Field:16), 0x02                            ; F8003F  c1 e5 0d 3f 02
	jr z, .LF80058                                       ; F80044  66 12
	calr Blink_EnableThenStop_Copy                                          ; F80046  1e ee f1
	or	(UI_RequestBits:16), 0x01                            ; F80049  c1 75 20 3e 01
	call T_AdvanceDelay_SelectField2                                        ; F8004E  1d 6c 2a f4
	calr AdvanceDelay_DrawValues                                      ; F80052  1e 31 00
	calr AdvanceDelay_DrawFieldCursor                                      ; F80055  1e c2 ff
.LF80058:
	ret                                                  ; F80058  0e
; LcdKeyRow3_AdvanceDelay_StageZero: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_AdvanceDelay_StageZero slot 0x0A.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow3_AdvanceDelay_StageZero:
	bit 0x07,W                                           ; F80059  c8 33 07
	jr z, .LF80079                                       ; F8005C  66 1b
	cp	(AdvanceDelay_Field:16), 0x03                            ; F8005E  c1 e5 0d 3f 03
	jr z, .LF80085                                       ; F80063  66 20
	calr Blink_EnableThenStop_Copy                                          ; F80065  1e cf f1
	or	(UI_RequestBits:16), 0x01                            ; F80068  c1 75 20 3e 01
	call T_AdvanceDelay_SelectField3                                        ; F8006D  1d 70 2a f4
	calr AdvanceDelay_DrawValues                                      ; F80071  1e 12 00
	calr AdvanceDelay_DrawFieldCursor                                      ; F80074  1e a3 ff
	jr .LF80085                                          ; F80077  68 0c
.LF80079:
	calr Blink_DisableThenStop                                          ; F80079  1e c9 f1
	and	(UI_RequestBits:16), 0xf6                            ; F8007C  c1 75 20 3c f6
	call T_AdvanceDelay_LcdKeyRow3                                        ; F80081  1d 80 2a f4
.LF80085:
	ret                                                  ; F80085  0e
; AdvanceDelay_DrawValues -- redraw the live values of the ADVANCE/DELAY screen on layer 0
; Evidence: (0x2540)=0; site 0xF80098 runs interpreter B over DL_F3B379-0xF3B3A7: track (0x12F6) via DLText_0To16All, 3-digit (0x12F7) and (0x12F9), signed 2-digit (0x12FB).
; Paint_AdvanceDelay (prom_b 0xF7FFB6) runs the same list start; BlinkArgPtrs_F8024D[2..4] are its records 0xF3B388/0xF3B392/0xF3B39C, i.e. fields 2-4.
; calr 0xF7E2D8 at 0xF8008B is a bare `ret` in prom_b.
AdvanceDelay_DrawValues:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80086  f1 40 25 00 00
	calr ButtonTable_SequencerMedley_Nop                                          ; F8008B  1e 4a e2
	ld XIY,DL_F3B379                                     ; F8008E  45 79 b3 f3 00
	ld XIX,0x00f3b3a7                                    ; F80093  44 a7 b3 f3 00
	call T_DisplayListB_Run                              ; F80098  1d f4 17 f4
	ret                                                  ; F8009C  0e
; LcdKeyRow4_AdvanceDelay_StageZero: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_AdvanceDelay_StageZero slot 0x0B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow4_AdvanceDelay_StageZero:
	bit 0x07,W                                           ; F8009D  c8 33 07
	jr z, .LF800BD                                       ; F800A0  66 1b
	cp	(AdvanceDelay_Field:16), 0x04                            ; F800A2  c1 e5 0d 3f 04
	jr z, .LF800BD                                       ; F800A7  66 14
	calr Blink_EnableThenStop_Copy                                          ; F800A9  1e 8b f1
	or	(UI_RequestBits:16), 0x01                            ; F800AC  c1 75 20 3e 01
	call T_AdvanceDelay_SelectField4                                        ; F800B1  1d 74 2a f4
	calr AdvanceDelay_DrawValues                                      ; F800B5  1e ce ff
	calr AdvanceDelay_DrawFieldCursor                                      ; F800B8  1e 5f ff
	jr .LF800BD                                          ; F800BB  68 00
.LF800BD:
	ret                                                  ; F800BD  0e
; ButtonTable_AdvanceDelay_StageZero_Nop12: a bare ret -- ButtonTable_AdvanceDelay_StageZero slot 0x0C.
ButtonTable_AdvanceDelay_StageZero_Nop12:
	ret                                                  ; F800BE  0e
; ButtonTable_AdvanceDelay_StageZero_Nop13: a bare ret -- ButtonTable_AdvanceDelay_StageZero slot 0x0D.
ButtonTable_AdvanceDelay_StageZero_Nop13:
	ret                                                  ; F800BF  0e
; ButtonTable_AdvanceDelay_StageZero_Nop14: a bare ret -- ButtonTable_AdvanceDelay_StageZero slot 0x0E.
ButtonTable_AdvanceDelay_StageZero_Nop14:
	ret                                                  ; F800C0  0e
; ExitKey_AdvanceDelay_StageZero: the EXIT key; ButtonTable_AdvanceDelay_StageZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_AdvanceDelay_StageZero:
	bit 0x07,W                                           ; F800C1  c8 33 07
	jr z, .LF800C8                                       ; F800C4  66 02
	jr .LF800CE                                          ; F800C6  68 06
.LF800C8:
	ldw (UI_Request:16), 0x801a                              ; F800C8  f1 70 20 02 1a 80
.LF800CE:
	ret                                                  ; F800CE  0e
; ButtonTable_AdvanceDelay_StageZero_Nop16: a bare ret -- ButtonTable_AdvanceDelay_StageZero slots 0x10, 0x11,
;   0x12, 0x13, 0x14.
ButtonTable_AdvanceDelay_StageZero_Nop16:
	ret                                                  ; F800CF  0e
; AdvanceDelay_StageZero_Button21 -- ButtonTable_AdvanceDelay_StageZero slot 0x15, NOT NAMED: slot 0x15 is only
;   the VARIANT-1 already-held rewrite of base code 0x04; the SX-WSA1R is variant 2, so the slot is never
;   delivered here.
AdvanceDelay_StageZero_Button21:
	bit	1, (UI_RequestBits:16)                               ; F800D0  f1 75 20 c9
	jr z, .LF800DA                                       ; F800D4  66 04
	call T_Blink_Stop                                    ; F800D6  1d 24 2e f4
.LF800DA:
	or	(UI_RequestBits:16), 0x08                            ; F800DA  c1 75 20 3e 08
	ld (0x0e18:16), 0x04                                 ; F800DF  f1 18 0e 00 04
	bit 0x07,W                                           ; F800E4  c8 33 07
	jr z, .LF800EF                                       ; F800E7  66 06
	call T_AdvanceDelay_StepFieldDown                                        ; F800E9  1d 7c 2a f4
	jr .LF800F3                                          ; F800ED  68 04
.LF800EF:
	call T_AdvanceDelay_StepFieldUp                                        ; F800EF  1d 78 2a f4
.LF800F3:
	calr AdvanceDelay_DrawValues                                      ; F800F3  1e 90 ff
	ret                                                  ; F800F6  0e
; ButtonTable_AdvanceDelay_StageZero_Nop22: a bare ret -- ButtonTable_AdvanceDelay_StageZero slots 0x16, 0x17,
;   0x18, 0x19, 0x1A.
ButtonTable_AdvanceDelay_StageZero_Nop22:
	ret                                                  ; F800F7  0e
; NumberPadKey_AdvanceDelay_StageZero: the twelve-key number pad (0-9, +/-, ENTER);
;   ButtonTable_AdvanceDelay_StageZero slot 0x1B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
NumberPadKey_AdvanceDelay_StageZero:
	calr AdvanceDelay_NumberPad                                      ; F800F8  1e 34 00
	ret                                                  ; F800FB  0e
; ButtonTable_AdvanceDelay_StageZero_Nop28: a bare ret -- ButtonTable_AdvanceDelay_StageZero slots 0x1C, 0x1D,
;   0x1E, 0x1F.
ButtonTable_AdvanceDelay_StageZero_Nop28:
	ret                                                  ; F800FC  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop0: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x00.
ButtonTable_AdvanceDelay_StageNonZero_Nop0:
	ret                                                  ; F800FD  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop1: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x01.
ButtonTable_AdvanceDelay_StageNonZero_Nop1:
	ret                                                  ; F800FE  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop2: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x02.
ButtonTable_AdvanceDelay_StageNonZero_Nop2:
	ret                                                  ; F800FF  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop3: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x03.
ButtonTable_AdvanceDelay_StageNonZero_Nop3:
	ret                                                  ; F80100  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop4: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x04.
ButtonTable_AdvanceDelay_StageNonZero_Nop4:
	ret                                                  ; F80101  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop5: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x05.
ButtonTable_AdvanceDelay_StageNonZero_Nop5:
	ret                                                  ; F80102  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop6: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x06.
ButtonTable_AdvanceDelay_StageNonZero_Nop6:
	ret                                                  ; F80103  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop7: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x07.
ButtonTable_AdvanceDelay_StageNonZero_Nop7:
	ret                                                  ; F80104  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop8: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x08.
ButtonTable_AdvanceDelay_StageNonZero_Nop8:
	ret                                                  ; F80105  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop9: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x09.
ButtonTable_AdvanceDelay_StageNonZero_Nop9:
	ret                                                  ; F80106  0e
; LcdKeyRow3_AdvanceDelay_StageNonZero: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks
;   the CP2 side (set) or the CP1 side (clear); ButtonTable_AdvanceDelay_StageNonZero slot 0x0A.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow3_AdvanceDelay_StageNonZero:
	bit 0x07,W                                           ; F80107  c8 33 07
	jr nz, .LF80115                                      ; F8010A  6e 09
	and	(UI_RequestBits:16), 0x6f                            ; F8010C  c1 75 20 3c 6f
	call T_AdvanceDelay_LcdKeyRow3                                        ; F80111  1d 80 2a f4
.LF80115:
	ret                                                  ; F80115  0e
; LcdKeyRow4_AdvanceDelay_StageNonZero: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks
;   the CP2 side (set) or the CP1 side (clear); ButtonTable_AdvanceDelay_StageNonZero slot 0x0B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow4_AdvanceDelay_StageNonZero:
	bit 0x07,W                                           ; F80116  c8 33 07
	jr nz, .LF8011F                                      ; F80119  6e 04
	call T_AdvanceDelay_ReturnToStageZero                                        ; F8011B  1d 84 2a f4
.LF8011F:
	ret                                                  ; F8011F  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop12: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x0C.
ButtonTable_AdvanceDelay_StageNonZero_Nop12:
	ret                                                  ; F80120  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop13: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x0D.
ButtonTable_AdvanceDelay_StageNonZero_Nop13:
	ret                                                  ; F80121  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop14: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slot 0x0E.
ButtonTable_AdvanceDelay_StageNonZero_Nop14:
	ret                                                  ; F80122  0e
; ExitKey_AdvanceDelay_StageNonZero: the EXIT key; ButtonTable_AdvanceDelay_StageNonZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_AdvanceDelay_StageNonZero:
	bit 0x07,W                                           ; F80123  c8 33 07
	jr nz, .LF8012C                                      ; F80126  6e 04
	call T_AdvanceDelay_ReturnToStageZero                                        ; F80128  1d 84 2a f4
.LF8012C:
	ret                                                  ; F8012C  0e
; ButtonTable_AdvanceDelay_StageNonZero_Nop16: a bare ret -- ButtonTable_AdvanceDelay_StageNonZero slots 0x10,
;   0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F.
ButtonTable_AdvanceDelay_StageNonZero_Nop16:
	ret                                                  ; F8012D  0e
	ret                                                  ; F8012E  0e
; AdvanceDelay_NumberPad -- NUMBER PAD key on the ADVANCE/DELAY screen: dispatch on the keypad code (0x2267)
; Evidence: reached only by `calr` at 0xF800F8, slot 27 (NumberPadKey) of ButtonTable_AdvanceDelay_StageZero.  (0x2267)<=9 -> AdvanceDelay_KeypadDigit, 0x0F -> AdvanceDelay_KeypadCommit, 0x80 -> AdvanceDelay_KeypadSign; then always AdvanceDelay_BlinkSelectedField.
; The codes are PanelKeypad_OrdinalToKey_V1's: 0..9 digit (shifted into 0x2821-0x2823), 0x80 sign toggle of (0x2820), 0x0F commit.
AdvanceDelay_NumberPad:
	ld a, (0x2267:16)                                   ; F8012F  c1 67 22 21
	cp A,0x09                                            ; F80133  c9 cf 09
	jr ule, .LF80144                                     ; F80136  63 0c
	cp A,0x0f                                            ; F80138  c9 cf 0f
	jr z, .LF80149                                       ; F8013B  66 0c
	cp A,0x80                                            ; F8013D  c9 cf 80
	jr z, .LF8014E                                       ; F80140  66 0c
	jr .LF80151                                          ; F80142  68 0d
.LF80144:
	calr Blink_SetEnable_1                                      ; F80144  1e 0e 00
	jr .LF80151                                          ; F80147  68 08
.LF80149:
	calr AdvanceDelay_KeypadCommit                                      ; F80149  1e 13 00
	jr .LF80151                                          ; F8014C  68 03
.LF8014E:
	calr AdvanceDelay_KeypadSign                                      ; F8014E  1e bc 00
.LF80151:
	calr AdvanceDelay_BlinkSelectedField                                      ; F80151  1e cc 00
	ret                                                  ; F80154  0e
Blink_SetEnable_1:
	pushw 0x01                                           ; F80155  0b 01 00
	call T_Blink_SetEnable                               ; F80158  1d 28 2e f4
	inc 2,XSP                                            ; F8015C  ef 62
	ret                                                  ; F8015E  0e
; AdvanceDelay_KeypadCommit -- keypad code 0x0F: convert the typed digits and store them into the field (0x0DE5) selects
; Evidence: field 4: (0x2826)=2, T_AsciiField_ToSignedValue, accepts <=+0x60 when (0x2820)='+' else >=-0x60, stores (0x0DEC)/(0x12FB).  Fields 2/3: (0x2826)=3, T_AsciiDigits3_ToValue, 1..999 into (0x0DE8)/(0x12F7) or (0x0DEA)/(0x12F9), keeping (0x0DE8)<=(0x0DEA); (0x0E06)=(0x0DEA)-(0x0DE8)+1.
; Then T_Blink_Stop and AdvanceDelay_DrawValues; out-of-range input returns with nothing stored.
AdvanceDelay_KeypadCommit:
	cp	(AdvanceDelay_Field:16), 0x04                            ; F8015F  c1 e5 0d 3f 04
	jr nz, .LF80176                                      ; F80164  6e 10
	ld (0x2826:16), 0x02                                 ; F80166  f1 26 28 00 02
	ld (0x2824:16), 0x00                                 ; F8016B  f1 24 28 00 00
	call T_AsciiField_ToSignedValue                      ; F80170  1d f4 32 f4
	jr .LF8017F                                          ; F80174  68 09
.LF80176:
	ld (0x2826:16), 0x03                                 ; F80176  f1 26 28 00 03
	call T_AsciiDigits3_ToValue                          ; F8017B  1d f0 32 f4
.LF8017F:
	cp	(AdvanceDelay_Field:16), 0x02                            ; F8017F  c1 e5 0d 3f 02
	jr z, .LF80196                                       ; F80184  66 10
	cp	(AdvanceDelay_Field:16), 0x03                            ; F80186  c1 e5 0d 3f 03
	jr z, .LF801B8                                       ; F8018B  66 2b
	cp	(AdvanceDelay_Field:16), 0x04                            ; F8018D  c1 e5 0d 3f 04
	jr z, .LF801E8                                       ; F80192  66 54
	jr .LF8020C                                          ; F80194  68 76
.LF80196:
	cp wa, 0x01:i3                                         ; F80196  d8 d9
	jr lt, .LF8020C                                      ; F80198  61 72
	cp WA,0x03e7                                         ; F8019A  d8 cf e7 03
	jr gt, .LF8020C                                      ; F8019E  6a 6c
	ld (0x0de8:16), wa                                  ; F801A0  f1 e8 0d 50
	ld (DisplayListB_Stage+1:16), wa                                  ; F801A4  f1 f7 12 50
	cp	wa, (0x0dea:16)                              ; F801A8  d1 ea 0d f0
	jr ule, .LF801B6                                     ; F801AC  63 08
	ld (0x0dea:16), wa                                  ; F801AE  f1 ea 0d 50
	ld (DisplayListB_Stage+3:16), wa                                  ; F801B2  f1 f9 12 50
.LF801B6:
	jr .LF801D8                                          ; F801B6  68 20
.LF801B8:
	cp wa, 0x01:i3                                         ; F801B8  d8 d9
	jr lt, .LF8020C                                      ; F801BA  61 50
	cp WA,0x03e7                                         ; F801BC  d8 cf e7 03
	jr gt, .LF8020C                                      ; F801C0  6a 4a
	ld (0x0dea:16), wa                                  ; F801C2  f1 ea 0d 50
	ld (DisplayListB_Stage+3:16), wa                                  ; F801C6  f1 f9 12 50
	cp	wa, (0x0de8:16)                              ; F801CA  d1 e8 0d f0
	jr nc, .LF801D8                                      ; F801CE  6f 08
	ld (0x0de8:16), wa                                  ; F801D0  f1 e8 0d 50
	ld (DisplayListB_Stage+1:16), wa                                  ; F801D4  f1 f7 12 50
.LF801D8:
	ld wa, (0x0dea:16)                                 ; F801D8  d1 ea 0d 20
	sub	wa, (0x0de8:16)                              ; F801DC  d1 e8 0d a0
	inc 1,WA                                             ; F801E0  d8 61
	ld (0x0e06:16), wa                                  ; F801E2  f1 06 0e 50
	jr .LF80205                                          ; F801E6  68 1d
.LF801E8:
	cp	(0x2820:16), 0x2b                            ; F801E8  c1 20 28 3f 2b
	jr z, .LF801F7                                       ; F801ED  66 08
	cp WA,0xffa0                                         ; F801EF  d8 cf a0 ff
	jr lt, .LF8020C                                      ; F801F3  61 17
	jr .LF801FD                                          ; F801F5  68 06
.LF801F7:
	cp WA,0x0060                                         ; F801F7  d8 cf 60 00
	jr gt, .LF8020C                                      ; F801FB  6a 0f
.LF801FD:
	ld (0x0dec:16), a                                   ; F801FD  f1 ec 0d 41
	ld (DisplayListB_Stage+5:16), a                                   ; F80201  f1 fb 12 41
.LF80205:
	call T_Blink_Stop                                    ; F80205  1d 24 2e f4
	calr AdvanceDelay_DrawValues                                      ; F80209  1e 7a fe
.LF8020C:
	ret                                                  ; F8020C  0e
; AdvanceDelay_KeypadSign -- keypad code 0x80: put '+' back in the sign cell (0x2820) unless field 4 is selected
; Evidence: `bit 1,(0x2075)` (blink enable, FINDINGS-prom_b-field-blink.md) and `cp (0x0DE5),4` gate `ld (0x2820),0x2B`; field 4 is the only one AdvanceDelay_KeypadCommit converts as signed.
AdvanceDelay_KeypadSign:
	bit	1, (UI_RequestBits:16)                               ; F8020D  f1 75 20 c9
	jr z, .LF8021F                                       ; F80211  66 0c
	cp	(AdvanceDelay_Field:16), 0x04                            ; F80213  c1 e5 0d 3f 04
	jr z, .LF8021F                                       ; F80218  66 05
	ld (0x2820:16), 0x2b                                 ; F8021A  f1 20 28 00 2b
.LF8021F:
	ret                                                  ; F8021F  0e
; AdvanceDelay_BlinkSelectedField -- start the field blink on the field (0x0DE5) selects
; Evidence: unless (0x2075) bit 1 is clear or (0x2267)=0x0F: (0x2540)=0, push BlinkArgPtrs_F8024D[(0x0DE5)], call T_Blink_Command.
AdvanceDelay_BlinkSelectedField:
	bit	1, (UI_RequestBits:16)                               ; F80220  f1 75 20 c9
	jr z, .LF8024C                                       ; F80224  66 26
	cp	(0x2267:16), 0x0f                            ; F80226  c1 67 22 3f 0f
	jr z, .LF8024C                                       ; F8022B  66 1f
	xor XWA,XWA                                          ; F8022D  e8 d0
	ld a, (AdvanceDelay_Field:16)                                   ; F8022F  c1 e5 0d 21
	sla xwa, 0x02                                        ; F80233  e8 ec 02
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80236  f1 40 25 00 00
	ld XIY,BlinkArgPtrs_F8024D                           ; F8023B  45 4d 02 f8 00
	ld	xiy, (xiy+wa)                                ; F80240  e3 07 f4 e0 25
	push XIY                                             ; F80245  3d
	call T_Blink_Command                                 ; F80246  1d 20 2e f4
	inc 4,XSP                                            ; F8024A  ef 64
.LF8024C:
	ret                                                  ; F8024C  0e
; ---------------------------------------------------------------------
; BlinkArgPtrs_F8024D -- 5 LE32 pointers into prom_b's display-list region
;
; Read by: ONE site, `ld XIY,0x00F8024D / ld XIY,(XIY+WA)` at 0xF8023B-0xF80244.
; Inputs:  WA = (0x0DE5) * 4  (`ld A,(0x0de5) / sla 0x02,XWA` at 0xF8022F).
; Outputs: the selected pointer is pushed and handed to prom_b's Blink_Command
;          (`call 0xf42e20`, T_Blink_Command (T_F42E20) -> 0xF0E9CF).
; ENTRY COUNT 5: words 0..4 are 0, 0, 0x00F3B388, 0x00F3B392, 0x00F3B39C; word 5
;          is 0xF42E801D, which is the `call 0xF42E80` the code resumes with.
;          ★ LAST-ENTRY TEST: 0xF8024D + 5*4 = 0xF80261 = that instruction.
; Evidence: the reader shape above; the three non-null entries all point inside
;          prom_b 0xF01800-0xF3E15B, the display-list region of
;          notes/FINDINGS-ui-display-list.md, and each opens on a plausible
;          (opcode, length) header.  notes/prom_a_boot_checks.py.
; Unknown:  what (0x0DE5) selects; why entries 0 and 1 are NULL.
; ---------------------------------------------------------------------
BlinkArgPtrs_F8024D:
	.long 0x00000000                                 ; F8024D  [  0]
	.long 0x00000000                                 ; F80251  [  1]
	.long 0x00f3b388                                 ; F80255  [  2]
	.long 0x00f3b392                                 ; F80259  [  3]
	.long 0x00f3b39c                                 ; F8025D  [  4]
; Paint_S0ngC0py -- paints the screen whose own text reads "S0NG C0PY", "FROM", "TO"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 6 time(s); XIY = list start, XIX = list end.  4 of those 6 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF80277  interpreter A  list 0xF3BF80  DL_S0ngC0pyFromToSongSongOk
;        text: "S0NG C0PY"; "FROM"; "TO"; "SONG "; "SONG "; "OK"
;     site 0xF8028C  interpreter A  list 0xF3BFF8  DL_FromToSongNoTrAllSongNoTrAll
;        text: "FROM"; "TO"; "SONG NO   TR/ALL    SONG NO   TR/ALL"; " <    >    <    >    <    >    <    >"
;     site 0xF802B1  interpreter A  list 0xF3C4D5  DL_ACurrentTrackWillBeClearedAutomaticaly
;        text: "A current "; " track will be"; "."; "cleared automaticaly"; "Are You Sure ?"
;     site 0xF802D7  interpreter A  list 0xF3A461  DL_AreYouSure
;        text: "Are You Sure ?"
; Evidence: the list address is the `ld XIY,0x00F3BF80` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_S0ngC0py:
	call T_CallbackQueue_ResetAndRestartTask2            ; F80261  1d 80 2e f4
	call PromB_LCD_ScreenRedraw_Begin                                        ; F80265  1d d9 e2 f7
	call T_S0ngC0py_InitFields                                        ; F80269  1d 08 2a f4
	ld XIY,DL_S0ngC0pyFromToSongSongOk                   ; F8026D  45 80 bf f3 00
	ld XIX,DL_FromToSongNoTrAllSongNoTrAll               ; F80272  44 f8 bf f3 00
	call T_DisplayList_Run                               ; F80277  1d f0 17 f4
	cp	(UI_ScreenStage:16), 0x00                            ; F8027B  c1 7e 20 3f 00
	jr nz, .LF80292                                      ; F80280  6e 10
	ld XIY,DL_FromToSongNoTrAllSongNoTrAll               ; F80282  45 f8 bf f3 00
	ld XIX,DL_TrackTrack                                 ; F80287  44 33 c1 f3 00
	call T_DisplayList_Run                               ; F8028C  1d f0 17 f4
	jr .LF802DB                                          ; F80290  68 49
.LF80292:
	ld XIY,DL_F3AB9C                                     ; F80292  45 9c ab f3 00
	ld XIX,DL_QuantizeTrackStrengthFirstMeasure          ; F80297  44 db ab f3 00
	call T_DisplayList_Run                               ; F8029C  1d f0 17 f4
	cp	(0x0e34:16), 0x00                            ; F802A0  c1 34 0e 3f 00
	jr z, .LF802CD                                       ; F802A5  66 26
	ld XIY,DL_ACurrentTrackWillBeClearedAutomaticaly     ; F802A7  45 d5 c4 f3 00
	ld XIX,Paint_S0ngC0py_DL                                     ; F802AC  44 30 c5 f3 00
	call T_DisplayList_Run                               ; F802B1  1d f0 17 f4
	ld a, (0x0e34:16)                                   ; F802B5  c1 34 0e 21
	ld (DisplayListB_Stage+17:16), a                                   ; F802B9  f1 07 13 41
	ld XIY,Paint_S0ngC0py_DL                                     ; F802BD  45 30 c5 f3 00
	ld XIX,Data_F3C53F                                   ; F802C2  44 3f c5 f3 00
	call T_DisplayListB_Run                              ; F802C7  1d f4 17 f4
	jr .LF802DB                                          ; F802CB  68 0e
.LF802CD:
	ld XIY,DL_AreYouSure                                 ; F802CD  45 61 a4 f3 00
	ld XIX,DL_TrackMergeOkTrackTrackTrack                ; F802D2  44 7f a4 f3 00
	call T_DisplayList_Run                               ; F802D7  1d f0 17 f4
.LF802DB:
	call S0ngC0py_DrawFromSong                                      ; F802DB  1d ec 02 f8
	call S0ngC0py_DrawToSong                                      ; F802DF  1d 38 03 f8
	call S0ngC0py_DrawTracks                                      ; F802E3  1d 84 03 f8
	call PromB_LCD_ScreenRedraw_End                                        ; F802E7  1d e7 e2 f7
	ret                                                  ; F802EB  0e
; S0ngC0py_DrawFromSong -- redraw the FROM song number and its six-character name on the SONG COPY screen
; Evidence: (0x12F6)=(0x0E0C); site 0xF80301 runs B record 0xF3C199 ((0x12F6) at IX 0x0A84, x=12 beside 'SONG ' x=7 under 'FROM' x=8 in DL_S0ngC0pyFromToSongSongOk); ldir 6 bytes from 0x610000+((0x0E0C)-1)*0xC00+0xCA (song bank name, FINDINGS-prom_b-block-store.md) to 0x12F8; site 0xF80333 runs S0ngC0py_DrawFromSong_DL2 (string 0x12F8 at IX 0x0DA0).
; Callers: Paint_S0ngC0py and the SoftKeyCol1/2 slot handlers (0xF803C9/0xF803D2) after T_S0ngC0py_StageZero_SoftKeyCol1/T_S0ngC0py_StageZero_SoftKeyCol2 step (0x0E0C) down/up in 1..10.
S0ngC0py_DrawFromSong:
	xor XWA,XWA                                          ; F802EC  e8 d0
	ld a, (S0ngC0py_FromSong:16)                                   ; F802EE  c1 0c 0e 21
	ld (DisplayListB_Stage:16), a                                   ; F802F2  f1 f6 12 41
	ld XIY,S0ngC0py_DrawFromSong_DL1                                     ; F802F6  45 99 c1 f3 00
	ld XIX,0x00f3c1a3                                    ; F802FB  44 a3 c1 f3 00
.LF80300:
	push XWA                                             ; F80300  38
	call T_DisplayListB_Run                              ; F80301  1d f4 17 f4
	pop XWA                                              ; F80305  58
	ld XIY,0x00610000                                    ; F80306  45 00 00 61 00
	dec 1,A                                              ; F8030B  c9 69
	ld XIX,XWA                                           ; F8030D  e8 8c
	sla xwa, 0x0b                                        ; F8030F  e8 ec 0b
	sla xix, 0x0a                                        ; F80312  ec ec 0a
	add XWA,XIX                                          ; F80315  ec 80
	add XIY,XWA                                          ; F80317  e8 85
	add XIY,0x000000ca                                   ; F80319  ed c8 ca 00 00 00
	ld XIX,DisplayListB_Stage+2                                    ; F8031F  44 f8 12 00 00
	ldw bc, 0x06                                         ; F80324  31 06 00
	ldir85                                               ; F80327  85 11
	ld XIY,S0ngC0py_DrawFromSong_DL2                                     ; F80329  45 5d c1 f3 00
	ld XIX,S0ngC0py_DrawToSong_DL                                     ; F8032E  44 6c c1 f3 00
	call T_DisplayListB_Run                              ; F80333  1d f4 17 f4
	ret                                                  ; F80337  0e
; S0ngC0py_DrawToSong -- redraw the TO song number and name on the SONG COPY screen
; Evidence: (0x12F7)=(0x0E0D); site 0xF8034D runs B record 0xF3C1A3 (IX 0x0A95, x=29 under 'TO' x=26); name of bank (0x0E0D)-1 copied to 0x12FE; site 0xF8037F runs S0ngC0py_DrawToSong_DL (IX 0x0DB1).
; Callers: Paint_S0ngC0py and the SoftKeyCol5/6 slot handlers (0xF803ED/0xF803F6) after T_S0ngC0py_StageZero_SoftKeyCol5/T_S0ngC0py_StageZero_SoftKeyCol6.
S0ngC0py_DrawToSong:
	xor XWA,XWA                                          ; F80338  e8 d0
	ld a, (S0ngC0py_ToSong:16)                                   ; F8033A  c1 0d 0e 21
	ld (DisplayListB_Stage+1:16), a                                   ; F8033E  f1 f7 12 41
	ld XIY,0x00f3c1a3                                    ; F80342  45 a3 c1 f3 00
	ld XIX,DL_S0ngSelectNameKbS0ngName                   ; F80347  44 ad c1 f3 00
	push XWA                                             ; F8034C  38
	call T_DisplayListB_Run                              ; F8034D  1d f4 17 f4
	pop XWA                                              ; F80351  58
	ld XIY,0x00610000                                    ; F80352  45 00 00 61 00
	dec 1,A                                              ; F80357  c9 69
	ld XIX,XWA                                           ; F80359  e8 8c
	sla xwa, 0x0b                                        ; F8035B  e8 ec 0b
	sla xix, 0x0a                                        ; F8035E  ec ec 0a
	add XWA,XIX                                          ; F80361  ec 80
	add XIY,XWA                                          ; F80363  e8 85
	add XIY,0x000000ca                                   ; F80365  ed c8 ca 00 00 00
	ld XIX,DisplayListB_Stage+8                                    ; F8036B  44 fe 12 00 00
	ldw bc, 0x06                                         ; F80370  31 06 00
	ldir85                                               ; F80373  85 11
	ld XIY,S0ngC0py_DrawToSong_DL                                     ; F80375  45 6c c1 f3 00
	ld XIX,S0ngC0py_DrawTracks_DL                                     ; F8037A  44 7b c1 f3 00
	call T_DisplayListB_Run                              ; F8037F  1d f4 17 f4
	ret                                                  ; F80383  0e
; S0ngC0py_DrawTracks -- redraw the FROM and TO track fields of the SONG COPY screen
; Evidence: (0x0E0E)=0x12 draws DL_AllAll ('  ALL   ' at both columns); otherwise (0x1304)=(0x0E0E), (0x1305)=(0x0E0F), DLB S0ngC0py_DrawTracks_DL (two DLText_0To17All readouts at IX 0x1344/0x1355) and DL_TrackTrack.
; Callers: Paint_S0ngC0py and SoftKeyCol3/4/7/8 handlers after T_S0ngC0py_StageZero_SoftKeyCol3/18/2C/28 step (0x0E0E)/(0x0E0F) in 1..0x12.
S0ngC0py_DrawTracks:
	cp	(S0ngC0py_FromTrack:16), 0x12                            ; F80384  c1 0e 0e 3f 12
	jr nz, .LF8039B                                      ; F80389  6e 10
	ld XIY,DL_AllAll                                     ; F8038B  45 45 c1 f3 00
	ld XIX,S0ngC0py_DrawFromSong_DL2                                     ; F80390  44 5d c1 f3 00
	call T_DisplayList_Run                               ; F80395  1d f0 17 f4
	jr .LF803C7                                          ; F80399  68 2c
.LF8039B:
	ld a, (S0ngC0py_FromTrack:16)                                   ; F8039B  c1 0e 0e 21
	ld (DisplayListB_Stage+14:16), a                                   ; F8039F  f1 04 13 41
	ld a, (S0ngC0py_ToTrack:16)                                   ; F803A3  c1 0f 0e 21
	ld (DisplayListB_Stage+15:16), a                                   ; F803A7  f1 05 13 41
	ld XIY,S0ngC0py_DrawTracks_DL                                     ; F803AB  45 7b c1 f3 00
	ld XIX,S0ngC0py_DrawFromSong_DL1                                     ; F803B0  44 99 c1 f3 00
	call T_DisplayListB_Run                              ; F803B5  1d f4 17 f4
	ld XIY,DL_TrackTrack                                 ; F803B9  45 33 c1 f3 00
	ld XIX,DL_AllAll                                     ; F803BE  44 45 c1 f3 00
	call T_DisplayList_Run                               ; F803C3  1d f0 17 f4
.LF803C7:
	ret                                                  ; F803C7  0e
ScreenLeave_S0ngC0py_Nop:
	ret                                                  ; F803C8  0e
; SoftKeyCol1_S0ngC0py_StageZero: the 1st of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_S0ngC0py_StageZero slots 0x00, 0x11.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol1_S0ngC0py_StageZero:
	call T_S0ngC0py_StageZero_SoftKeyCol1                                        ; F803C9  1d 14 2a f4
	call S0ngC0py_DrawFromSong                                      ; F803CD  1d ec 02 f8
	ret                                                  ; F803D1  0e
; SoftKeyCol2_S0ngC0py_StageZero: the 2nd of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_S0ngC0py_StageZero slots 0x01, 0x12.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol2_S0ngC0py_StageZero:
	call T_S0ngC0py_StageZero_SoftKeyCol2                                        ; F803D2  1d 10 2a f4
	call S0ngC0py_DrawFromSong                                      ; F803D6  1d ec 02 f8
	ret                                                  ; F803DA  0e
; SoftKeyCol3_S0ngC0py_StageZero: the 3rd of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_S0ngC0py_StageZero slots 0x02, 0x13.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol3_S0ngC0py_StageZero:
	call T_S0ngC0py_StageZero_SoftKeyCol3                                        ; F803DB  1d 1c 2a f4
	call S0ngC0py_DrawTracks                                      ; F803DF  1d 84 03 f8
	ret                                                  ; F803E3  0e
; SoftKeyCol4_S0ngC0py_StageZero: the 4th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_S0ngC0py_StageZero slots 0x03, 0x14.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol4_S0ngC0py_StageZero:
	call T_S0ngC0py_StageZero_SoftKeyCol4                                        ; F803E4  1d 18 2a f4
	call S0ngC0py_DrawTracks                                      ; F803E8  1d 84 03 f8
	ret                                                  ; F803EC  0e
; SoftKeyCol5_S0ngC0py_StageZero: the 5th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_S0ngC0py_StageZero slots 0x04, 0x15.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol5_S0ngC0py_StageZero:
	call T_S0ngC0py_StageZero_SoftKeyCol5                                        ; F803ED  1d 24 2a f4
	call S0ngC0py_DrawToSong                                      ; F803F1  1d 38 03 f8
	ret                                                  ; F803F5  0e
; SoftKeyCol6_S0ngC0py_StageZero: the 6th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_S0ngC0py_StageZero slots 0x05, 0x16.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol6_S0ngC0py_StageZero:
	call T_S0ngC0py_StageZero_SoftKeyCol6                                        ; F803F6  1d 20 2a f4
	call S0ngC0py_DrawToSong                                      ; F803FA  1d 38 03 f8
	ret                                                  ; F803FE  0e
; SoftKeyCol7_S0ngC0py_StageZero: the 7th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_S0ngC0py_StageZero slots 0x06, 0x17.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol7_S0ngC0py_StageZero:
	call T_S0ngC0py_StageZero_SoftKeyCol7                                        ; F803FF  1d 2c 2a f4
	call S0ngC0py_DrawTracks                                      ; F80403  1d 84 03 f8
	ret                                                  ; F80407  0e
; SoftKeyCol8_S0ngC0py_StageZero: the 8th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_S0ngC0py_StageZero slots 0x07, 0x18.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol8_S0ngC0py_StageZero:
	call T_S0ngC0py_StageZero_SoftKeyCol8                                        ; F80408  1d 28 2a f4
	call S0ngC0py_DrawTracks                                      ; F8040C  1d 84 03 f8
	ret                                                  ; F80410  0e
; ButtonTable_S0ngC0py_StageZero_Nop8: a bare ret -- ButtonTable_S0ngC0py_StageZero slot 0x08.
ButtonTable_S0ngC0py_StageZero_Nop8:
	ret                                                  ; F80411  0e
; LcdKeyRow2_S0ngC0py_StageZero: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2
;   side (set) or the CP1 side (clear); ButtonTable_S0ngC0py_StageZero slot 0x09.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow2_S0ngC0py_StageZero:
	call T_S0ngC0py_LcdKeyRow2                                        ; F80412  1d 30 2a f4
	ret                                                  ; F80416  0e
; ButtonTable_S0ngC0py_StageZero_Nop10: a bare ret -- ButtonTable_S0ngC0py_StageZero slots 0x0A, 0x0B, 0x0C,
;   0x0D, 0x0E.
ButtonTable_S0ngC0py_StageZero_Nop10:
	ret                                                  ; F80417  0e
; ExitKey_S0ngC0py_StageZero: the EXIT key; ButtonTable_S0ngC0py_StageZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_S0ngC0py_StageZero:
	bit 0x07,W                                           ; F80418  c8 33 07
	jr nz, .LF80425                                      ; F8041B  6e 08
	ldw (UI_Request:16), 0x801a                              ; F8041D  f1 70 20 02 1a 80
	jr .LF80425                                          ; F80423  68 00
.LF80425:
	ret                                                  ; F80425  0e
; ButtonTable_S0ngC0py_StageZero_Nop16: a bare ret -- ButtonTable_S0ngC0py_StageZero slots 0x10, 0x19, 0x1A,
;   0x1B, 0x1C, 0x1D, 0x1E, 0x1F.
ButtonTable_S0ngC0py_StageZero_Nop16:
	ret                                                  ; F80426  0e
; ButtonTable_S0ngC0py_StageNonZero_Nop0: a bare ret -- ButtonTable_S0ngC0py_StageNonZero slots 0x00, 0x01,
;   0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08.
ButtonTable_S0ngC0py_StageNonZero_Nop0:
	ret                                                  ; F80427  0e
; LcdKeyRow2_S0ngC0py_StageNonZero: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_S0ngC0py_StageNonZero slot 0x09.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow2_S0ngC0py_StageNonZero:
	call T_S0ngC0py_LcdKeyRow2                                        ; F80428  1d 30 2a f4
	ret                                                  ; F8042C  0e
; LcdKeyRow3_S0ngC0py_StageNonZero: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_S0ngC0py_StageNonZero slot 0x0A.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow3_S0ngC0py_StageNonZero:
	call T_S0ngC0py_ReturnToStageZero                                        ; F8042D  1d 34 2a f4
	ret                                                  ; F80431  0e
; ButtonTable_S0ngC0py_StageNonZero_Nop11: a bare ret -- ButtonTable_S0ngC0py_StageNonZero slots 0x0B, 0x0C,
;   0x0D, 0x0E.
ButtonTable_S0ngC0py_StageNonZero_Nop11:
	ret                                                  ; F80432  0e
; ExitKey_S0ngC0py_StageNonZero: the EXIT key; ButtonTable_S0ngC0py_StageNonZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_S0ngC0py_StageNonZero:
	call T_S0ngC0py_ReturnToStageZero                                        ; F80433  1d 34 2a f4
	ret                                                  ; F80437  0e
; ButtonTable_S0ngC0py_StageNonZero_Nop16: a bare ret -- ButtonTable_S0ngC0py_StageNonZero slots 0x10, 0x11,
;   0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F.
ButtonTable_S0ngC0py_StageNonZero_Nop16:
	ret                                                  ; F80438  0e
; Paint_N0teChange -- paints the screen whose own text reads "N0TE CHANGE", "TARGET NOTE", "TRACK         :"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 6 time(s); XIY = list start, XIX = list end.  3 of those 6 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF8048D  interpreter A  list 0xF3AEAF  DL_N0teChangeTargetNoteTrack
;        text: "N0TE CHANGE"; "TARGET NOTE"; "TRACK         :"; ":"; " ("; ")"
;     site 0xF804C0  interpreter A  list 0xF3A461  DL_AreYouSure
;        text: "Are You Sure ?"
;     site 0xF804CE  interpreter A  list 0xF3A461  DL_AreYouSure
;        text: "Are You Sure ?"
; Evidence: the list address is the `ld XIY,0x00F3AEAF` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_N0teChange:
	call T_CallbackQueue_ResetAndRestartTask2            ; F80439  1d 80 2e f4
	cp	(UI_ScreenStage:16), 0x00                            ; F8043D  c1 7e 20 3f 00
	jr nz, .LF8047B                                      ; F80442  6e 37
	call T_N0teChange_InitFields                                        ; F80444  1d 88 2a f4
	or	(UI_RequestBits:16), 0x01                            ; F80448  c1 75 20 3e 01
	ldw (PanelDial_DownButton:16), 0x0484                              ; F8044D  f1 9b 20 02 84 04
	ldw (0x2666:16), 0xffff                              ; F80453  f1 66 26 02 ff ff
	ldw (0x266a:16), 0xffff                              ; F80459  f1 6a 26 02 ff ff
	ld a, (N0teChange_Field:16)                                   ; F8045F  c1 ed 0d 21
	cp a, 0x02:i3                                          ; F80463  c9 da
	jr z, .LF80478                                       ; F80465  66 11
	cp a, 0x03:i3                                          ; F80467  c9 db
	jr z, .LF80478                                       ; F80469  66 0d
	cp a, 0x04:i3                                          ; F8046B  c9 dc
	jr z, .LF80478                                       ; F8046D  66 09
	cp a, 0x05:i3                                          ; F8046F  c9 dd
	jr z, .LF80478                                       ; F80471  66 05
	calr Blink_DisableThenStop                                          ; F80473  1e cf ed
	jr .LF8047B                                          ; F80476  68 03
.LF80478:
	calr Blink_EnableThenStop_Copy                                          ; F80478  1e bc ed
.LF8047B:
	calr PromB_LCD_ScreenRedraw_Begin                                          ; F8047B  1e 5b de
	ld (LCD_CurrentLayer:16), 0x00                                 ; F8047E  f1 40 25 00 00
	ld XIY,DL_N0teChangeTargetNoteTrack                  ; F80483  45 af ae f3 00
	ld XIX,Paint_N0teChange_DL1                                     ; F80488  44 af af f3 00
	call T_DisplayList_Run                               ; F8048D  1d f0 17 f4
	cp	(UI_ScreenStage:16), 0x00                            ; F80491  c1 7e 20 3f 00
	jr nz, .LF804A8                                      ; F80496  6e 10
	ld XIY,Paint_N0teChange_DL1                                     ; F80498  45 af af f3 00
	ld XIX,DL_F3AFE7                                     ; F8049D  44 e7 af f3 00
	call T_DisplayList_Run                               ; F804A2  1d f0 17 f4
	jr .LF804D2                                          ; F804A6  68 2a
.LF804A8:
	ld XIY,Paint_N0teChange_DL2                                     ; F804A8  45 c3 b0 f3 00
	ld XIX,DL_Transp0seTrackFirstMeasure                 ; F804AD  44 02 b1 f3 00
	call T_DisplayList_Run                               ; F804B2  1d f0 17 f4
	ld XIY,DL_AreYouSure                                 ; F804B6  45 61 a4 f3 00
	ld XIX,DL_TrackMergeOkTrackTrackTrack                ; F804BB  44 7f a4 f3 00
	call T_DisplayList_Run                               ; F804C0  1d f0 17 f4
	ld XIY,DL_AreYouSure                                 ; F804C4  45 61 a4 f3 00
	ld XIX,DL_TrackMergeOkTrackTrackTrack                ; F804C9  44 7f a4 f3 00
	call T_DisplayList_Run                               ; F804CE  1d f0 17 f4
.LF804D2:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F804D2  f1 40 25 00 00
	calr ButtonTable_SequencerMedley_Nop                                          ; F804D7  1e fe dd
	ld XIY,DL_F3AFE7                                     ; F804DA  45 e7 af f3 00
	ld XIX,Data_F3B065                                   ; F804DF  44 65 b0 f3 00
	call T_DisplayListB_Run                              ; F804E4  1d f4 17 f4
	calr PromB_LCD_ScreenRedraw_End                                          ; F804E8  1e fc dd
	ret                                                  ; F804EB  0e
; ScreenLeaveBody_N0teChange -- the whole body of the N0teChange screen's Leave method
; Evidence: prom_b ScreenLeave_N0teChange (0xF7D21C) is `call 0xF804EC / ret` (+4 of screen object 0xF43120); body `call T_N0teChange_OnLeave / ret` -- prom_b 0xF7C8BC: unless (0x207A)=0x2D, call T_Seq_RequestRewind.  Same shape as prom_b ScreenLeaveBody_AdvanceDelay.
ScreenLeaveBody_N0teChange:
	call T_N0teChange_OnLeave                                        ; F804EC  1d 8c 2a f4
	ret                                                  ; F804F0  0e
; ButtonTable_N0teChange_StageZero_Nop0: a bare ret -- ButtonTable_N0teChange_StageZero slot 0x00.
ButtonTable_N0teChange_StageZero_Nop0:
	ret                                                  ; F804F1  0e
; ButtonTable_N0teChange_StageZero_Nop1: a bare ret -- ButtonTable_N0teChange_StageZero slot 0x01.
ButtonTable_N0teChange_StageZero_Nop1:
	ret                                                  ; F804F2  0e
; ButtonTable_N0teChange_StageZero_Nop2: a bare ret -- ButtonTable_N0teChange_StageZero slot 0x02.
ButtonTable_N0teChange_StageZero_Nop2:
	ret                                                  ; F804F3  0e
; ButtonTable_N0teChange_StageZero_Nop3: a bare ret -- ButtonTable_N0teChange_StageZero slot 0x03.
ButtonTable_N0teChange_StageZero_Nop3:
	ret                                                  ; F804F4  0e
; SoftKeyCol5_N0teChange_StageZero: the 5th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_N0teChange_StageZero slot 0x04.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol5_N0teChange_StageZero:
	bit	1, (UI_RequestBits:16)                               ; F804F5  f1 75 20 c9
	jr z, .LF804FF                                       ; F804F9  66 04
	call T_Blink_Stop                                    ; F804FB  1d 24 2e f4
.LF804FF:
	or	(UI_RequestBits:16), 0x08                            ; F804FF  c1 75 20 3e 08
	ld (0x0e18:16), 0x01                                 ; F80504  f1 18 0e 00 01
	bit 0x07,W                                           ; F80509  c8 33 07
	jr z, .LF80514                                       ; F8050C  66 06
	call T_N0teChange_StepFieldDown                                        ; F8050E  1d a8 2a f4
	jr .LF80518                                          ; F80512  68 04
.LF80514:
	call T_N0teChange_StepSelectedFieldUp                                        ; F80514  1d a4 2a f4
.LF80518:
	calr N0teChange_DrawValues                                      ; F80518  1e 9d 00
	ret                                                  ; F8051B  0e
; ButtonTable_N0teChange_StageZero_Nop5: a bare ret -- ButtonTable_N0teChange_StageZero slot 0x05.
ButtonTable_N0teChange_StageZero_Nop5:
	ret                                                  ; F8051C  0e
; ButtonTable_N0teChange_StageZero_Nop6: a bare ret -- ButtonTable_N0teChange_StageZero slot 0x06.
ButtonTable_N0teChange_StageZero_Nop6:
	ret                                                  ; F8051D  0e
ButtonTable_N0teChange_StageZero_Nop7:
	ret                                                  ; F8051E  0e
; LcdKeyRow2_N0teChange_StageZero: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2
;   side (set) or the CP1 side (clear); ButtonTable_N0teChange_StageZero slot 0x09.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow2_N0teChange_StageZero:
	bit 0x07,W                                           ; F8051F  c8 33 07
	jr z, .LF80534                                       ; F80522  66 10
	cp	(N0teChange_Field:16), 0x01                            ; F80524  c1 ed 0d 3f 01
	jr z, .LF80548                                       ; F80529  66 1d
	calr Blink_DisableThenStop                                          ; F8052B  1e 17 ed
	call T_N0teChange_SelectField1                                        ; F8052E  1d 90 2a f4
	jr .LF80542                                          ; F80532  68 0e
.LF80534:
	cp	(N0teChange_Field:16), 0x04                            ; F80534  c1 ed 0d 3f 04
	jr z, .LF80548                                       ; F80539  66 0d
	calr Blink_EnableThenStop_Copy                                          ; F8053B  1e f9 ec
	call T_N0teChange_SelectField4                                        ; F8053E  1d 9c 2a f4
.LF80542:
	calr N0teChange_DrawValues                                      ; F80542  1e 73 00
	calr N0teChange_DrawFieldCursor                                      ; F80545  1e 01 00
.LF80548:
	ret                                                  ; F80548  0e
; N0teChange_DrawFieldCursor -- clear LCD layer 1, then fill the box of the NOTE CHANGE field (0x1301) selects
; Evidence: (0x2540)=1; site 0xF8055B runs DL_F39551-0xF39559 (op 0E ClearColumns, whole layer); then DLB_Handler_Array8 (T_F4181C) on op-03 record 0xF3B05A: (0x1301)&7 indexes the boxes at 0xF3B065, swi 5 FillRect.  (0x1301) is written with (0x0DED) (T_N0teChange_InitFields = prom_b 0xF7C853).
; Callers: the row-key handlers of ButtonTable_N0teChange_StageZero at 0xF8051F-0xF805AB.
N0teChange_DrawFieldCursor:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F80549  f1 40 25 00 01
	calr ButtonTable_SequencerMedley_Nop                                          ; F8054E  1e 87 dd
	ld XIY,DL_F39551                                     ; F80551  45 51 95 f3 00
	ld XIX,Data_F39559                                   ; F80556  44 59 95 f3 00
	call T_DisplayList_Run                               ; F8055B  1d f0 17 f4
	ld XIY,0x00f3b05a                                    ; F8055F  45 5a b0 f3 00
	call T_DLB_Handler_Array8                                        ; F80564  1d 1c 18 f4
	ret                                                  ; F80568  0e
; LcdKeyRow3_N0teChange_StageZero: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2
;   side (set) or the CP1 side (clear); ButtonTable_N0teChange_StageZero slot 0x0A.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow3_N0teChange_StageZero:
	bit 0x07,W                                           ; F80569  c8 33 07
	jr z, .LF8057E                                       ; F8056C  66 10
	cp	(N0teChange_Field:16), 0x02                            ; F8056E  c1 ed 0d 3f 02
	jr z, .LF80594                                       ; F80573  66 1f
	calr Blink_EnableThenStop_Copy                                          ; F80575  1e bf ec
	call T_N0teChange_SelectField2                                        ; F80578  1d 94 2a f4
	jr .LF8058C                                          ; F8057C  68 0e
.LF8057E:
	cp	(N0teChange_Field:16), 0x05                            ; F8057E  c1 ed 0d 3f 05
	jr z, .LF80594                                       ; F80583  66 0f
	calr Blink_EnableThenStop_Copy                                          ; F80585  1e af ec
	call T_N0teChange_SelectField5                                        ; F80588  1d a0 2a f4
.LF8058C:
	calr N0teChange_DrawValues                                      ; F8058C  1e 29 00
	calr N0teChange_DrawFieldCursor                                      ; F8058F  1e b7 ff
	jr .LF80594                                          ; F80592  68 00
.LF80594:
	ret                                                  ; F80594  0e
; LcdKeyRow4_N0teChange_StageZero: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2
;   side (set) or the CP1 side (clear); ButtonTable_N0teChange_StageZero slot 0x0B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow4_N0teChange_StageZero:
	bit 0x07,W                                           ; F80595  c8 33 07
	jr z, .LF805B0                                       ; F80598  66 16
	cp	(N0teChange_Field:16), 0x03                            ; F8059A  c1 ed 0d 3f 03
	jr z, .LF805B7                                       ; F8059F  66 16
	calr Blink_EnableThenStop_Copy                                          ; F805A1  1e 93 ec
	call T_N0teChange_SelectField3                                        ; F805A4  1d 98 2a f4
	calr N0teChange_DrawValues                                      ; F805A8  1e 0d 00
	calr N0teChange_DrawFieldCursor                                      ; F805AB  1e 9b ff
	jr .LF805B7                                          ; F805AE  68 07
.LF805B0:
	calr Blink_DisableThenStop                                          ; F805B0  1e 92 ec
	call T_N0teChange_LcdKeyRow4                                        ; F805B3  1d ac 2a f4
.LF805B7:
	ret                                                  ; F805B7  0e
; N0teChange_DrawValues -- redraw the live values of the NOTE CHANGE screen on layer 0
; Evidence: (0x2540)=0; site 0xF805CA runs interpreter B over DL_F3AFE7-0xF3B05A (readouts of 0x12F6-0x12FA, 0x12FB, 0x12FC, 0x12FE, 0x12FF), the list Paint_N0teChange runs at 0xF804DA; BlinkArgPtrs_F80754[2..5] are its records for fields 2-5.
N0teChange_DrawValues:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F805B8  f1 40 25 00 00
	calr ButtonTable_SequencerMedley_Nop                                          ; F805BD  1e 18 dd
	ld XIY,DL_F3AFE7                                     ; F805C0  45 e7 af f3 00
	ld XIX,0x00f3b05a                                    ; F805C5  44 5a b0 f3 00
	call T_DisplayListB_Run                              ; F805CA  1d f4 17 f4
	ret                                                  ; F805CE  0e
; ButtonTable_N0teChange_StageZero_Nop12: a bare ret -- ButtonTable_N0teChange_StageZero slot 0x0C.
ButtonTable_N0teChange_StageZero_Nop12:
	ret                                                  ; F805CF  0e
; ButtonTable_N0teChange_StageZero_Nop13: a bare ret -- ButtonTable_N0teChange_StageZero slot 0x0D.
ButtonTable_N0teChange_StageZero_Nop13:
	ret                                                  ; F805D0  0e
; ButtonTable_N0teChange_StageZero_Nop14: a bare ret -- ButtonTable_N0teChange_StageZero slot 0x0E.
ButtonTable_N0teChange_StageZero_Nop14:
	ret                                                  ; F805D1  0e
; ExitKey_N0teChange_StageZero: the EXIT key; ButtonTable_N0teChange_StageZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_N0teChange_StageZero:
	bit 0x07,W                                           ; F805D2  c8 33 07
	jr z, .LF805D9                                       ; F805D5  66 02
	jr .LF805DF                                          ; F805D7  68 06
.LF805D9:
	ldw (UI_Request:16), 0x801a                              ; F805D9  f1 70 20 02 1a 80
.LF805DF:
	ret                                                  ; F805DF  0e
; ButtonTable_N0teChange_StageZero_Nop16: a bare ret -- ButtonTable_N0teChange_StageZero slots 0x10, 0x11, 0x12,
;   0x13, 0x14.
ButtonTable_N0teChange_StageZero_Nop16:
	ret                                                  ; F805E0  0e
; N0teChange_StageZero_Button21 -- ButtonTable_N0teChange_StageZero slot 0x15, NOT NAMED: slot 0x15 is only the
;   VARIANT-1 already-held rewrite of base code 0x04; the SX-WSA1R is variant 2, so the slot is never delivered
;   here.
N0teChange_StageZero_Button21:
	bit	1, (UI_RequestBits:16)                               ; F805E1  f1 75 20 c9
	jr z, .LF805EB                                       ; F805E5  66 04
	call T_Blink_Stop                                    ; F805E7  1d 24 2e f4
.LF805EB:
	or	(UI_RequestBits:16), 0x08                            ; F805EB  c1 75 20 3e 08
	ld (0x0e18:16), 0x04                                 ; F805F0  f1 18 0e 00 04
	bit 0x07,W                                           ; F805F5  c8 33 07
	jr z, .LF80600                                       ; F805F8  66 06
	call T_N0teChange_StepFieldDown                                        ; F805FA  1d a8 2a f4
	jr T,.LF80604                                        ; F805FE  68 04
.LF80600:
	call T_N0teChange_StepSelectedFieldUp                                        ; F80600  1d a4 2a f4
.LF80604:
	calr N0teChange_DrawValues                                      ; F80604  1e b1 ff
	ret                                                  ; F80607  0e
; ButtonTable_N0teChange_StageZero_Nop22: a bare ret -- ButtonTable_N0teChange_StageZero slots 0x16, 0x17, 0x18,
;   0x19, 0x1A.
ButtonTable_N0teChange_StageZero_Nop22:
	ret                                                  ; F80608  0e
; NumberPadKey_N0teChange_StageZero: the twelve-key number pad (0-9, +/-, ENTER);
;   ButtonTable_N0teChange_StageZero slot 0x1B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
NumberPadKey_N0teChange_StageZero:
	calr N0teChange_NumberPad                                      ; F80609  1e 1e 00
	ret                                                  ; F8060C  0e
; ButtonTable_N0teChange_StageZero_Nop28: a bare ret -- ButtonTable_N0teChange_StageZero slots 0x1C, 0x1D, 0x1E,
;   0x1F.
ButtonTable_N0teChange_StageZero_Nop28:
	ret                                                  ; F8060D  0e
; ButtonTable_N0teChange_StageNonZero_Nop0: a bare ret -- ButtonTable_N0teChange_StageNonZero slots 0x00, 0x01,
;   0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A.
ButtonTable_N0teChange_StageNonZero_Nop0:
	ret                                                  ; F8060E  0e
; LcdKeyRow4_N0teChange_StageNonZero: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_N0teChange_StageNonZero slot 0x0B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow4_N0teChange_StageNonZero:
	bit 0x07,W                                           ; F8060F  c8 33 07
	jr nz, .LF80618                                      ; F80612  6e 04
	call T_N0teChange_LcdKeyRow4                                        ; F80614  1d ac 2a f4
.LF80618:
	ret                                                  ; F80618  0e
; LcdKeyRow5_N0teChange_StageNonZero: row 5 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_N0teChange_StageNonZero slot 0x0C.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow5_N0teChange_StageNonZero:
	bit 0x07,W                                           ; F80619  c8 33 07
	jr nz, .LF80622                                      ; F8061C  6e 04
	call T_N0teChange_ReturnToStageZero                                        ; F8061E  1d b0 2a f4
.LF80622:
	ret                                                  ; F80622  0e
; ButtonTable_N0teChange_StageNonZero_Nop13: a bare ret -- ButtonTable_N0teChange_StageNonZero slots 0x0D, 0x0E.
ButtonTable_N0teChange_StageNonZero_Nop13:
	ret                                                  ; F80623  0e
; ExitKey_N0teChange_StageNonZero: the EXIT key; ButtonTable_N0teChange_StageNonZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_N0teChange_StageNonZero:
	call T_N0teChange_ReturnToStageZero                                        ; F80624  1d b0 2a f4
	ret                                                  ; F80628  0e
; ButtonTable_N0teChange_StageNonZero_Nop16: a bare ret -- ButtonTable_N0teChange_StageNonZero slots 0x10, 0x11,
;   0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F.
ButtonTable_N0teChange_StageNonZero_Nop16:
	ret                                                  ; F80629  0e
; N0teChange_NumberPad -- NUMBER PAD key on the NOTE CHANGE screen: dispatch on (0x2267)
; Evidence: reached only by `calr` at 0xF80609, slot 27 of ButtonTable_N0teChange_StageZero; <=9 -> N0teChange_KeypadDigit, 0x0F -> N0teChange_KeypadCommit, 0x80 -> N0teChange_KeypadSign, then N0teChange_BlinkSelectedField.
N0teChange_NumberPad:
	ld a, (0x2267:16)                                   ; F8062A  c1 67 22 21
	cp A,0x09                                            ; F8062E  c9 cf 09
	jr ule, .LF8063F                                     ; F80631  63 0c
	cp A,0x0f                                            ; F80633  c9 cf 0f
	jr z, .LF80644                                       ; F80636  66 0c
	cp A,0x80                                            ; F80638  c9 cf 80
	jr z, .LF80649                                       ; F8063B  66 0c
	jr .LF8064C                                          ; F8063D  68 0d
.LF8063F:
	calr Blink_SetEnable_1_2                                      ; F8063F  1e 0e 00
	jr .LF8064C                                          ; F80642  68 08
.LF80644:
	calr N0teChange_KeypadCommit                                      ; F80644  1e 13 00
	jr .LF8064C                                          ; F80647  68 03
.LF80649:
	calr N0teChange_KeypadSign                                      ; F80649  1e c8 00
.LF8064C:
	calr N0teChange_BlinkSelectedField                                      ; F8064C  1e d8 00
	ret                                                  ; F8064F  0e
Blink_SetEnable_1_2:
	pushw 0x01                                           ; F80650  0b 01 00
	call T_Blink_SetEnable                               ; F80653  1d 28 2e f4
	inc 2,XSP                                            ; F80657  ef 62
	ret                                                  ; F80659  0e
; N0teChange_KeypadCommit -- keypad code 0x0F: store the typed number into the NOTE CHANGE field (0x0DED) selects
; Evidence: T_AsciiDigits3_ToValue; fields 2/3 accept 1..999 into (0x0DF0)/(0x12FC) and (0x0DF2)/(0x12FF) keeping first<=last, (0x129E)=last-first+1; fields 4/5 accept 0..127 into (0x0DF4)/(0x12FB) and (0x0DF5)/(0x12FE), and `divs WA,12` splits each into (0x12F7)/(0x12F8) and (0x12F9)/(0x12FA).
; Then T_Blink_Stop and N0teChange_DrawValues.
N0teChange_KeypadCommit:
	ld (0x2826:16), 0x03                                 ; F8065A  f1 26 28 00 03
	call T_AsciiDigits3_ToValue                          ; F8065F  1d f0 32 f4
	cp	(N0teChange_Field:16), 0x02                            ; F80663  c1 ed 0d 3f 02
	jr z, .LF80682                                       ; F80668  66 18
	cp	(N0teChange_Field:16), 0x03                            ; F8066A  c1 ed 0d 3f 03
	jr z, .LF806A6                                       ; F8066F  66 35
	cp	(N0teChange_Field:16), 0x04                            ; F80671  c1 ed 0d 3f 04
	jr z, .LF806D6                                       ; F80676  66 5e
	cp	(N0teChange_Field:16), 0x05                            ; F80678  c1 ed 0d 3f 05
	jr z, .LF806F2                                       ; F8067D  66 73
	jrl .LF80713                                         ; F8067F  78 91 00
.LF80682:
	cp wa, 0x01:i3                                         ; F80682  d8 d9
	jrl lt, .LF80713                                     ; F80684  71 8c 00
	cp WA,0x03e7                                         ; F80687  d8 cf e7 03
	jrl gt, .LF80713                                     ; F8068B  7a 85 00
	ld (N0teChange_FromMeasure:16), wa                                  ; F8068E  f1 f0 0d 50
	ld (DisplayListB_Stage+6:16), wa                                  ; F80692  f1 fc 12 50
	cp	wa, (N0teChange_ToMeasure:16)                              ; F80696  d1 f2 0d f0
	jr ule, .LF806A4                                     ; F8069A  63 08
	ld (N0teChange_ToMeasure:16), wa                                  ; F8069C  f1 f2 0d 50
	ld (DisplayListB_Stage+9:16), wa                                  ; F806A0  f1 ff 12 50
.LF806A4:
	jr .LF806C6                                          ; F806A4  68 20
.LF806A6:
	cp wa, 0x01:i3                                         ; F806A6  d8 d9
	jr lt, .LF80713                                      ; F806A8  61 69
	cp WA,0x03e7                                         ; F806AA  d8 cf e7 03
	jr gt, .LF80713                                      ; F806AE  6a 63
	ld (N0teChange_ToMeasure:16), wa                                  ; F806B0  f1 f2 0d 50
	ld (DisplayListB_Stage+9:16), wa                                  ; F806B4  f1 ff 12 50
	cp	wa, (N0teChange_FromMeasure:16)                              ; F806B8  d1 f0 0d f0
	jr nc, .LF806C6                                      ; F806BC  6f 08
	ld (N0teChange_FromMeasure:16), wa                                  ; F806BE  f1 f0 0d 50
	ld (DisplayListB_Stage+6:16), wa                                  ; F806C2  f1 fc 12 50
.LF806C6:
	ld wa, (N0teChange_ToMeasure:16)                                 ; F806C6  d1 f2 0d 20
	sub	wa, (N0teChange_FromMeasure:16)                              ; F806CA  d1 f0 0d a0
	inc 1,WA                                             ; F806CE  d8 61
	ld (0x129e:16), wa                                  ; F806D0  f1 9e 12 50
	jr .LF8070C                                          ; F806D4  68 36
.LF806D6:
	cp WA,0x007f                                         ; F806D6  d8 cf 7f 00
	jr gt, .LF80713                                      ; F806DA  6a 37
	ld (N0teChange_FromNote:16), a                                   ; F806DC  f1 f4 0d 41
	ld (DisplayListB_Stage+5:16), a                                   ; F806E0  f1 fb 12 41
	ld l, 0x0c:opc                                          ; F806E4  27 0c
	divs wa, l                                         ; F806E6  cf 59
	ld (DisplayListB_Stage+1:16), w                                   ; F806E8  f1 f7 12 40
	ld (DisplayListB_Stage+2:16), a                                   ; F806EC  f1 f8 12 41
	jr .LF8070C                                          ; F806F0  68 1a
.LF806F2:
	cp WA,0x007f                                         ; F806F2  d8 cf 7f 00
	jr gt, .LF80713                                      ; F806F6  6a 1b
	ld (N0teChange_ToNote:16), a                                   ; F806F8  f1 f5 0d 41
	ld (DisplayListB_Stage+8:16), a                                   ; F806FC  f1 fe 12 41
	ld l, 0x0c:opc                                          ; F80700  27 0c
	divs wa, l                                         ; F80702  cf 59
	ld (DisplayListB_Stage+3:16), w                                   ; F80704  f1 f9 12 40
	ld (DisplayListB_Stage+4:16), a                                   ; F80708  f1 fa 12 41
.LF8070C:
	call T_Blink_Stop                                    ; F8070C  1d 24 2e f4
	calr N0teChange_DrawValues                                      ; F80710  1e a5 fe
.LF80713:
	ret                                                  ; F80713  0e
; N0teChange_KeypadSign -- keypad code 0x80: put '+' back in (0x2820)
; Evidence: `bit 1,(0x2075)` and `cp (0x0DB8),4` gate `ld (0x2820),0x2B`.  This screen's field index is (0x0DED); why it tests (0x0DB8) is not established.
N0teChange_KeypadSign:
	bit	1, (UI_RequestBits:16)                               ; F80714  f1 75 20 c9
	jr z, .LF80726                                       ; F80718  66 0c
	cp	(0x0db8:16), 0x04                            ; F8071A  c1 b8 0d 3f 04
	jr z, .LF80726                                       ; F8071F  66 05
	ld (0x2820:16), 0x2b                                 ; F80721  f1 20 28 00 2b
.LF80726:
	ret                                                  ; F80726  0e
; N0teChange_BlinkSelectedField -- start the field blink on the field (0x0DED) selects
; Evidence: unless blink is off or (0x2267)=0x0F: push BlinkArgPtrs_F80754[(0x0DED)], call T_Blink_Command.
N0teChange_BlinkSelectedField:
	bit	1, (UI_RequestBits:16)                               ; F80727  f1 75 20 c9
	jr z, .LF80753                                       ; F8072B  66 26
	cp	(0x2267:16), 0x0f                            ; F8072D  c1 67 22 3f 0f
	jr z, .LF80753                                       ; F80732  66 1f
	xor XWA,XWA                                          ; F80734  e8 d0
	ld a, (N0teChange_Field:16)                                   ; F80736  c1 ed 0d 21
	sla xwa, 0x02                                        ; F8073A  e8 ec 02
	ld (LCD_CurrentLayer:16), 0x00                                 ; F8073D  f1 40 25 00 00
	ld XIY,BlinkArgPtrs_F80754                           ; F80742  45 54 07 f8 00
	ld	xiy, (xiy+wa)                                ; F80747  e3 07 f4 e0 25
	push XIY                                             ; F8074C  3d
	call T_Blink_Command                                 ; F8074D  1d 20 2e f4
	inc 4,XSP                                            ; F80751  ef 64
.LF80753:
	ret                                                  ; F80753  0e
; ---------------------------------------------------------------------
; BlinkArgPtrs_F80754 -- 6 LE32 pointers, same idiom
;
; Read by: `ld XIY,0x00F80754 / ld XIY,(XIY+WA)` at 0xF80742-0xF8074B.
; Inputs:  WA = (0x0DED) * 4.
; ENTRY COUNT 6: 0, 0, 0x00F3B03C, 0x00F3B050, 0x00F3B032, 0x00F3B046; word 6
;          is `call 0xF42E80`.  ★ 0xF80754 + 6*4 = 0xF8076C = that instruction.
; Evidence / Unknown: as BlinkArgPtrs_F8024D.
; ---------------------------------------------------------------------
BlinkArgPtrs_F80754:
	.long 0x00000000                                 ; F80754  [  0]
	.long 0x00000000                                 ; F80758  [  1]
	.long 0x00f3b03c                                 ; F8075C  [  2]
	.long 0x00f3b050                                 ; F80760  [  3]
	.long 0x00f3b032                                 ; F80764  [  4]
	.long 0x00f3b046                                 ; F80768  [  5]
; Paint_MeasureC0py -- paints the screen whose own text reads "MEASURE C0PY", "FROM TRACK", "TO TRACK"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 6 time(s); XIY = list start, XIX = list end.  2 of those 6 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF807B7  interpreter A  list 0xF3BBA5  DL_MeasureC0pyFromTrackToTrack
;        text: "MEASURE C0PY"; "FROM TRACK"; "TO TRACK"; ":"; ":"; "FIRST MEASURE"
;     site 0xF807ED  interpreter A  list 0xF3A461  DL_AreYouSure
;        text: "Are You Sure ?"
; Evidence: the list address is the `ld XIY,0x00F3BBA5` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_MeasureC0py:
	call T_CallbackQueue_ResetAndRestartTask2                                        ; F8076C  1d 80 2e f4
	cp	(UI_ScreenStage:16), 0x00                            ; F80770  c1 7e 20 3f 00
	jr nz, .LF80792                                      ; F80775  6e 1b
	call T_MeasureC0py_InitFields                                        ; F80777  1d d8 29 f4
	or	(UI_RequestBits:16), 0x01                            ; F8077B  c1 75 20 3e 01
	ldw (PanelDial_DownButton:16), 0x0484                              ; F80780  f1 9b 20 02 84 04
	ldw (0x2666:16), 0xffff                              ; F80786  f1 66 26 02 ff ff
	ldw (0x266a:16), 0xffff                              ; F8078C  f1 6a 26 02 ff ff
.LF80792:
	calr PromB_LCD_ScreenRedraw_Begin                                          ; F80792  1e 44 db
	ld (LCD_CurrentLayer:16), 0x02                                 ; F80795  f1 40 25 00 02
	ld XIY,DL_F3BCCB                                     ; F8079A  45 cb bc f3 00
	ld XIX,DL_F3BD07                                     ; F8079F  44 07 bd f3 00
	call T_DisplayList_Run                               ; F807A4  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F807A8  f1 40 25 00 00
	ld XIY,DL_MeasureC0pyFromTrackToTrack                ; F807AD  45 a5 bb f3 00
	ld XIX,Paint_MeasureC0py_DL                                     ; F807B2  44 93 bc f3 00
	call T_DisplayList_Run                               ; F807B7  1d f0 17 f4
	cp	(UI_ScreenStage:16), 0x00                            ; F807BB  c1 7e 20 3f 00
	jr nz, .LF807D5                                      ; F807C0  6e 13
	ld XIY,Paint_MeasureC0py_DL                                     ; F807C2  45 93 bc f3 00
	ld XIX,DL_F3BCCB                                     ; F807C7  44 cb bc f3 00
	call T_DisplayList_Run                               ; F807CC  1d f0 17 f4
	calr Paint_MeasureC0py_Nop                                      ; F807D0  1e 35 00
	jr .LF807F1                                          ; F807D3  68 1c
.LF807D5:
	ld XIY,DL_F3BD90                                     ; F807D5  45 90 bd f3 00
	ld XIX,DL_MeasureInsertFromTrackToTrack              ; F807DA  44 cf bd f3 00
	call T_DisplayList_Run                               ; F807DF  1d f0 17 f4
	ld XIY,DL_AreYouSure                                 ; F807E3  45 61 a4 f3 00
	ld XIX,DL_TrackMergeOkTrackTrackTrack                ; F807E8  44 7f a4 f3 00
	call T_DisplayList_Run                               ; F807ED  1d f0 17 f4
.LF807F1:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F807F1  f1 40 25 00 00
	ld XIY,DL_F3BD07                                     ; F807F6  45 07 bd f3 00
	ld XIX,Data_F3BD58                                   ; F807FB  44 58 bd f3 00
	call T_DisplayListB_Run                              ; F80800  1d f4 17 f4
	calr PromB_LCD_ScreenRedraw_End                                          ; F80804  1e e0 da
	ret                                                  ; F80807  0e
Paint_MeasureC0py_Nop:
	ret                                                  ; F80808  0e
; ScreenLeaveBody_MeasureC0py -- the whole body of the MeasureC0py screen's Leave method
; Evidence: prom_b ScreenLeave_MeasureC0py (0xF7D23D) is `call 0xF80809 / ret` (+4 of screen object 0xF430C0); body `call T_MeasureC0py_OnLeave / ret`.  Bytes after it are ButtonTable_MeasureC0py slot handlers.
ScreenLeaveBody_MeasureC0py:
	call T_MeasureC0py_OnLeave                                        ; F80809  1d dc 29 f4
	ret                                                  ; F8080D  0e
; ButtonTable_MeasureC0py_StageZero_Nop0: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x00.
ButtonTable_MeasureC0py_StageZero_Nop0:
	ret                                                  ; F8080E  0e
; ButtonTable_MeasureC0py_StageZero_Nop1: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x01.
ButtonTable_MeasureC0py_StageZero_Nop1:
	ret                                                  ; F8080F  0e
; ButtonTable_MeasureC0py_StageZero_Nop2: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x02.
ButtonTable_MeasureC0py_StageZero_Nop2:
	ret                                                  ; F80810  0e
; ButtonTable_MeasureC0py_StageZero_Nop3: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x03.
ButtonTable_MeasureC0py_StageZero_Nop3:
	ret                                                  ; F80811  0e
; SoftKeyCol5_MeasureC0py_StageZero: the 5th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_MeasureC0py_StageZero slot 0x04.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol5_MeasureC0py_StageZero:
	bit	1, (UI_RequestBits:16)                               ; F80812  f1 75 20 c9
	jr z, .LF8081C                                       ; F80816  66 04
	call T_Blink_Stop                                    ; F80818  1d 24 2e f4
.LF8081C:
	or	(UI_RequestBits:16), 0x08                            ; F8081C  c1 75 20 3e 08
	ld (0x0e18:16), 0x01                                 ; F80821  f1 18 0e 00 01
	bit 0x07,W                                           ; F80826  c8 33 07
	jr z, .LF80831                                       ; F80829  66 06
	call T_MeasureC0py_StepFieldDown                                        ; F8082B  1d fc 29 f4
	jr .LF80835                                          ; F8082F  68 04
.LF80831:
	call T_MeasureC0py_StepFieldUp                                        ; F80831  1d f8 29 f4
.LF80835:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80835  f1 40 25 00 00
	calr ButtonTable_SequencerMedley_Nop                                          ; F8083A  1e 9b da
	ld XIY,DL_F3BD07                                     ; F8083D  45 07 bd f3 00
	ld XIX,0x00f3bd4d                                    ; F80842  44 4d bd f3 00
	call T_DisplayListB_Run                              ; F80847  1d f4 17 f4
	ret                                                  ; F8084B  0e
; ButtonTable_MeasureC0py_StageZero_Nop5: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x05.
ButtonTable_MeasureC0py_StageZero_Nop5:
	ret                                                  ; F8084C  0e
; ButtonTable_MeasureC0py_StageZero_Nop6: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x06.
ButtonTable_MeasureC0py_StageZero_Nop6:
	ret                                                  ; F8084D  0e
; ButtonTable_MeasureC0py_StageZero_Nop7: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x07.
ButtonTable_MeasureC0py_StageZero_Nop7:
	ret                                                  ; F8084E  0e
; LcdKeyRow1_MeasureC0py_StageZero: row 1 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureC0py_StageZero slot 0x08.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow1_MeasureC0py_StageZero:
	bit 0x07,W                                           ; F8084F  c8 33 07
	jr nz, .LF8085B                                      ; F80852  6e 07
	calr Blink_DisableThenStop                                          ; F80854  1e ee e9
	call T_MeasureC0py_LcdKeyRow1                                        ; F80857  1d 04 2a f4
.LF8085B:
	ret                                                  ; F8085B  0e
; LcdKeyRow2_MeasureC0py_StageZero: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureC0py_StageZero slot 0x09.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow2_MeasureC0py_StageZero:
	bit 0x07,W                                           ; F8085C  c8 33 07
	jr z, .LF80871                                       ; F8085F  66 10
	cp	(MeasureC0py_Field:16), 0x01                            ; F80861  c1 bc 0d 3f 01
	jr z, .LF80890                                       ; F80866  66 28
	calr Blink_DisableThenStop                                          ; F80868  1e da e9
	call T_MeasureC0py_SelectField1                                        ; F8086B  1d e0 29 f4
	jr .LF8087F                                          ; F8086F  68 0e
.LF80871:
	cp	(MeasureC0py_Field:16), 0x04                            ; F80871  c1 bc 0d 3f 04
	jr z, .LF80890                                       ; F80876  66 18
	calr Blink_DisableThenStop                                          ; F80878  1e ca e9
	call T_MeasureC0py_SelectField4                                        ; F8087B  1d ec 29 f4
.LF8087F:
	ld a, (MeasureC0py_Field:16)                                   ; F8087F  c1 bc 0d 21
	ld (DisplayListB_Stage+9:16), a                                   ; F80883  f1 ff 12 41
	calr MeasureC0py_DrawValues                                      ; F80887  1e 13 01
	calr MeasureC0py_DrawFieldCursor                                      ; F8088A  1e 04 00
	calr Paint_MeasureC0py_Nop                                      ; F8088D  1e 78 ff
.LF80890:
	ret                                                  ; F80890  0e
; MeasureC0py_DrawFieldCursor -- clear LCD layer 1, then fill the box of the MEASURE COPY field (0x12FF) selects
; Evidence: (0x2540)=1; site 0xF808A3 runs DL_F39551-0xF39559 (op 0E ClearColumns, whole layer); DLB_Handler_Array8 on op-03 record 0xF3BD4D: (0x12FF)&7 indexes boxes 0xF3BD58, swi 5 FillRect.  Every caller first stores (0x0DBC) into (0x12FF) (0xF8087F, 0xF808D4, 0xF80909).
MeasureC0py_DrawFieldCursor:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F80891  f1 40 25 00 01
	calr ButtonTable_SequencerMedley_Nop                                          ; F80896  1e 3f da
	ld XIY,DL_F39551                                     ; F80899  45 51 95 f3 00
	ld XIX,Data_F39559                                   ; F8089E  44 59 95 f3 00
	call T_DisplayList_Run                               ; F808A3  1d f0 17 f4
	ld XIY,0x00f3bd4d                                    ; F808A7  45 4d bd f3 00
	call T_DLB_Handler_Array8                                        ; F808AC  1d 1c 18 f4
	ret                                                  ; F808B0  0e
; LcdKeyRow3_MeasureC0py_StageZero: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureC0py_StageZero slot 0x0A.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow3_MeasureC0py_StageZero:
	bit 0x07,W                                           ; F808B1  c8 33 07
	jr nz, .LF808C6                                      ; F808B4  6e 10
	cp	(MeasureC0py_Field:16), 0x05                            ; F808B6  c1 bc 0d 3f 05
	jr z, .LF808E5                                       ; F808BB  66 28
	calr Blink_EnableThenStop_Copy                                          ; F808BD  1e 77 e9
	call T_MeasureC0py_SelectField5                                        ; F808C0  1d f0 29 f4
	jr .LF808D4                                          ; F808C4  68 0e
.LF808C6:
	cp	(MeasureC0py_Field:16), 0x02                            ; F808C6  c1 bc 0d 3f 02
	jr z, .LF808E5                                       ; F808CB  66 18
	calr Blink_EnableThenStop_Copy                                          ; F808CD  1e 67 e9
	call T_MeasureC0py_SelectField2                                        ; F808D0  1d e4 29 f4
.LF808D4:
	ld a, (MeasureC0py_Field:16)                                   ; F808D4  c1 bc 0d 21
	ld (DisplayListB_Stage+9:16), a                                   ; F808D8  f1 ff 12 41
	calr MeasureC0py_DrawValues                                      ; F808DC  1e be 00
	calr MeasureC0py_DrawFieldCursor                                      ; F808DF  1e af ff
	calr Paint_MeasureC0py_Nop                                      ; F808E2  1e 23 ff
.LF808E5:
	ret                                                  ; F808E5  0e
; LcdKeyRow4_MeasureC0py_StageZero: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureC0py_StageZero slot 0x0B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow4_MeasureC0py_StageZero:
	bit 0x07,W                                           ; F808E6  c8 33 07
	jr z, .LF808FB                                       ; F808E9  66 10
	cp	(MeasureC0py_Field:16), 0x03                            ; F808EB  c1 bc 0d 3f 03
	jr z, .LF8091A                                       ; F808F0  66 28
	calr Blink_EnableThenStop_Copy                                          ; F808F2  1e 42 e9
	call T_MeasureC0py_SelectField3                                        ; F808F5  1d e8 29 f4
	jr .LF80909                                          ; F808F9  68 0e
.LF808FB:
	cp	(MeasureC0py_Field:16), 0x06                            ; F808FB  c1 bc 0d 3f 06
	jr z, .LF8091A                                       ; F80900  66 18
	calr Blink_DisableThenStop                                          ; F80902  1e 40 e9
	call T_MeasureC0py_SelectField6                                        ; F80905  1d f4 29 f4
.LF80909:
	ld a, (MeasureC0py_Field:16)                                   ; F80909  c1 bc 0d 21
	ld (DisplayListB_Stage+9:16), a                                   ; F8090D  f1 ff 12 41
	calr MeasureC0py_DrawValues                                      ; F80911  1e 89 00
	calr MeasureC0py_DrawFieldCursor                                      ; F80914  1e 7a ff
	calr Paint_MeasureC0py_Nop                                      ; F80917  1e ee fe
.LF8091A:
	ret                                                  ; F8091A  0e
; ButtonTable_MeasureC0py_StageZero_Nop12: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x0C.
ButtonTable_MeasureC0py_StageZero_Nop12:
	ret                                                  ; F8091B  0e
; ButtonTable_MeasureC0py_StageZero_Nop13: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x0D.
ButtonTable_MeasureC0py_StageZero_Nop13:
	ret                                                  ; F8091C  0e
; ButtonTable_MeasureC0py_StageZero_Nop14: a bare ret -- ButtonTable_MeasureC0py_StageZero slot 0x0E.
ButtonTable_MeasureC0py_StageZero_Nop14:
	ret                                                  ; F8091D  0e
; ExitKey_MeasureC0py_StageZero: the EXIT key; ButtonTable_MeasureC0py_StageZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_MeasureC0py_StageZero:
	bit 0x07,W                                           ; F8091E  c8 33 07
	jr z, .LF80925                                       ; F80921  66 02
	jr .LF8092B                                          ; F80923  68 06
.LF80925:
	ldw (UI_Request:16), 0x801a                              ; F80925  f1 70 20 02 1a 80
.LF8092B:
	ret                                                  ; F8092B  0e
; ButtonTable_MeasureC0py_StageZero_Nop16: a bare ret -- ButtonTable_MeasureC0py_StageZero slots 0x10, 0x11,
;   0x12, 0x13, 0x14.
ButtonTable_MeasureC0py_StageZero_Nop16:
	ret                                                  ; F8092C  0e
; MeasureC0py_StageZero_Button21 -- ButtonTable_MeasureC0py_StageZero slot 0x15, NOT NAMED: slot 0x15 is only
;   the VARIANT-1 already-held rewrite of base code 0x04; the SX-WSA1R is variant 2, so the slot is never
;   delivered here.
MeasureC0py_StageZero_Button21:
	bit	1, (UI_RequestBits:16)                               ; F8092D  f1 75 20 c9
	jr z, .LF80937                                       ; F80931  66 04
	call T_Blink_Stop                                    ; F80933  1d 24 2e f4
.LF80937:
	or	(UI_RequestBits:16), 0x08                            ; F80937  c1 75 20 3e 08
	ld (0x0e18:16), 0x04                                 ; F8093C  f1 18 0e 00 04
	bit 0x07,W                                           ; F80941  c8 33 07
	jr z, .LF8094C                                       ; F80944  66 06
	call T_MeasureC0py_StepFieldDown                                        ; F80946  1d fc 29 f4
	jr .LF80950                                          ; F8094A  68 04
.LF8094C:
	call T_MeasureC0py_StepFieldUp                                        ; F8094C  1d f8 29 f4
.LF80950:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80950  f1 40 25 00 00
	calr ButtonTable_SequencerMedley_Nop                                          ; F80955  1e 80 d9
	ld XIY,DL_F3BD07                                     ; F80958  45 07 bd f3 00
	ld XIX,0x00f3bd4d                                    ; F8095D  44 4d bd f3 00
	call T_DisplayListB_Run                              ; F80962  1d f4 17 f4
	ret                                                  ; F80966  0e
; ButtonTable_MeasureC0py_StageZero_Nop22: a bare ret -- ButtonTable_MeasureC0py_StageZero slots 0x16, 0x17,
;   0x18, 0x19, 0x1A.
ButtonTable_MeasureC0py_StageZero_Nop22:
	ret                                                  ; F80967  0e
; NumberPadKey_MeasureC0py_StageZero: the twelve-key number pad (0-9, +/-, ENTER);
;   ButtonTable_MeasureC0py_StageZero slot 0x1B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
NumberPadKey_MeasureC0py_StageZero:
	calr MeasureC0py_NumberPad                                      ; F80968  1e 42 00
	ret                                                  ; F8096B  0e
; ButtonTable_MeasureC0py_StageZero_Nop28: a bare ret -- ButtonTable_MeasureC0py_StageZero slots 0x1C, 0x1D,
;   0x1E, 0x1F.
ButtonTable_MeasureC0py_StageZero_Nop28:
	ret                                                  ; F8096C  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop0: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x00.
ButtonTable_MeasureC0py_StageNonZero_Nop0:
	ret                                                  ; F8096D  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop1: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x01.
ButtonTable_MeasureC0py_StageNonZero_Nop1:
	ret                                                  ; F8096E  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop2: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x02.
ButtonTable_MeasureC0py_StageNonZero_Nop2:
	ret                                                  ; F8096F  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop3: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x03.
ButtonTable_MeasureC0py_StageNonZero_Nop3:
	ret                                                  ; F80970  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop4: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x04.
ButtonTable_MeasureC0py_StageNonZero_Nop4:
	ret                                                  ; F80971  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop5: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x05.
ButtonTable_MeasureC0py_StageNonZero_Nop5:
	ret                                                  ; F80972  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop6: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x06.
ButtonTable_MeasureC0py_StageNonZero_Nop6:
	ret                                                  ; F80973  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop7: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x07.
ButtonTable_MeasureC0py_StageNonZero_Nop7:
	ret                                                  ; F80974  0e
; LcdKeyRow1_MeasureC0py_StageNonZero: row 1 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureC0py_StageNonZero slot 0x08.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow1_MeasureC0py_StageNonZero:
	bit 0x07,W                                           ; F80975  c8 33 07
	jr nz, .LF80983                                      ; F80978  6e 09
	and	(UI_RequestBits:16), 0x6f                            ; F8097A  c1 75 20 3c 6f
	call T_MeasureC0py_LcdKeyRow1                                        ; F8097F  1d 04 2a f4
.LF80983:
	ret                                                  ; F80983  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop9: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x09.
ButtonTable_MeasureC0py_StageNonZero_Nop9:
	ret                                                  ; F80984  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop10: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slots 0x0A,
;   0x0B.
ButtonTable_MeasureC0py_StageNonZero_Nop10:
	ret                                                  ; F80985  0e
; LcdKeyRow5_MeasureC0py_StageNonZero: row 5 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureC0py_StageNonZero slot 0x0C.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow5_MeasureC0py_StageNonZero:
	bit 0x07,W                                           ; F80986  c8 33 07
	jr nz, .LF8098F                                      ; F80989  6e 04
	call T_MeasureC0py_ReturnToStageZero                                        ; F8098B  1d 00 2a f4
.LF8098F:
	ret                                                  ; F8098F  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop13: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x0D.
ButtonTable_MeasureC0py_StageNonZero_Nop13:
	ret                                                  ; F80990  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop14: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slot 0x0E.
ButtonTable_MeasureC0py_StageNonZero_Nop14:
	ret                                                  ; F80991  0e
; ExitKey_MeasureC0py_StageNonZero: the EXIT key; ButtonTable_MeasureC0py_StageNonZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_MeasureC0py_StageNonZero:
	bit 0x07,W                                           ; F80992  c8 33 07
	jr nz, .LF8099B                                      ; F80995  6e 04
	call T_MeasureC0py_ReturnToStageZero                                        ; F80997  1d 00 2a f4
.LF8099B:
	ret                                                  ; F8099B  0e
; ButtonTable_MeasureC0py_StageNonZero_Nop16: a bare ret -- ButtonTable_MeasureC0py_StageNonZero slots 0x10,
;   0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F.
ButtonTable_MeasureC0py_StageNonZero_Nop16:
	ret                                                  ; F8099C  0e
; MeasureC0py_DrawValues -- redraw the live values of the MEASURE COPY screen
; Evidence: site 0xF809A7 runs interpreter B over DL_F3BD07-0xF3BD4D: string readouts (0x12F6) (0x12FB), 3-digit (0x12F7) (0x12F9) (0x12FC), (0x12FE) -- the list Paint_MeasureC0py runs at 0xF807F6.  It does not set (0x2540); callers have.
MeasureC0py_DrawValues:
	ld XIY,DL_F3BD07                                     ; F8099D  45 07 bd f3 00
	ld XIX,0x00f3bd4d                                    ; F809A2  44 4d bd f3 00
	call T_DisplayListB_Run                              ; F809A7  1d f4 17 f4
	ret                                                  ; F809AB  0e
	ret                                                  ; F809AC  0e
; MeasureC0py_NumberPad -- NUMBER PAD key on the MEASURE COPY screen: dispatch on (0x2267)
; Evidence: reached only by `calr` at 0xF80968, slot 27 of ButtonTable_MeasureC0py_StageZero; digit / 0x0F / 0x80 arms then MeasureC0py_BlinkSelectedField.
MeasureC0py_NumberPad:
	ld a, (0x2267:16)                                   ; F809AD  c1 67 22 21
	cp A,0x09                                            ; F809B1  c9 cf 09
	jr le, .LF809C2                                      ; F809B4  62 0c
	cp A,0x0f                                            ; F809B6  c9 cf 0f
	jr z, .LF809C7                                       ; F809B9  66 0c
	cp A,0x80                                            ; F809BB  c9 cf 80
	jr z, .LF809CC                                       ; F809BE  66 0c
	jr .LF809CF                                          ; F809C0  68 0d
.LF809C2:
	calr Blink_SetEnable_1_3                                      ; F809C2  1e 0e 00
	jr .LF809CF                                          ; F809C5  68 08
.LF809C7:
	calr MeasureC0py_KeypadCommit                                      ; F809C7  1e 13 00
	jr .LF809CF                                          ; F809CA  68 03
.LF809CC:
	calr MeasureC0py_KeypadSign                                      ; F809CC  1e ab 00
.LF809CF:
	calr MeasureC0py_BlinkSelectedField                                      ; F809CF  1e ae 00
	ret                                                  ; F809D2  0e
Blink_SetEnable_1_3:
	pushw 0x01                                           ; F809D3  0b 01 00
	call T_Blink_SetEnable                               ; F809D6  1d 28 2e f4
	inc 2,XSP                                            ; F809DA  ef 62
	ret                                                  ; F809DC  0e
; MeasureC0py_KeypadCommit -- keypad code 0x0F: store the typed measure number into the field (0x0DBC) selects
; Evidence: T_AsciiDigits3_ToValue, 1..999; field 2 -> (0x0C18), (0x603470), (0x12F7), (0x0C30) with last (0x0C32) raised to match; field 3 -> (0x0C32)/(0x12F9) with first lowered; (0x603472)=last-first+1; field 5 -> (0x0C1A), (0x603475), (0x12FC).  Then T_Blink_Stop and MeasureC0py_DrawValues.
; It first returns when `cp (0x02),0x20` is equal -- address 0x0002 is not a named SFR and the other screens' commits lack the test; not established.
MeasureC0py_KeypadCommit:
	cp	(0x02:8), 0x20                               ; F809DD  c0 02 3f 20
	jrl z, .LF80A79                                      ; F809E1  76 95 00
	ld (0x2826:16), 0x03                                 ; F809E4  f1 26 28 00 03
	call T_AsciiDigits3_ToValue                          ; F809E9  1d f0 32 f4
	cp wa, 0x01:i3                                         ; F809ED  d8 d9
	jrl lt, .LF80A79                                     ; F809EF  71 87 00
	cp WA,0x03e7                                         ; F809F2  d8 cf e7 03
	jrl gt, .LF80A79                                     ; F809F6  7a 80 00
	cp	(MeasureC0py_Field:16), 0x02                            ; F809F9  c1 bc 0d 3f 02
	jr Z,.LF80A10                                        ; F809FE  66 10
	cp	(MeasureC0py_Field:16), 0x03                            ; F80A00  c1 bc 0d 3f 03
	jr z, .LF80A31                                       ; F80A05  66 2a
	cp	(MeasureC0py_Field:16), 0x05                            ; F80A07  c1 bc 0d 3f 05
	jr z, .LF80A65                                       ; F80A0C  66 57
	jr .LF80A79                                          ; F80A0E  68 69
.LF80A10:
	ld (0x0c18:16), wa                                  ; F80A10  f1 18 0c 50
	ld (0x603470:24), wa                                ; F80A14  f2 70 34 60 50
	ld (DisplayListB_Stage+1:16), wa                                  ; F80A19  f1 f7 12 50
	cp	wa, (0x0c32:16)                              ; F80A1D  d1 32 0c f0
	jr ule, .LF80A2B                                     ; F80A21  63 08
	ld (0x0c32:16), wa                                  ; F80A23  f1 32 0c 50
	ld (DisplayListB_Stage+3:16), wa                                  ; F80A27  f1 f9 12 50
.LF80A2B:
	ld (0x0c30:16), wa                                  ; F80A2B  f1 30 0c 50
	jr .LF80A54                                          ; F80A2F  68 23
.LF80A31:
	ld (0x0c32:16), wa                                  ; F80A31  f1 32 0c 50
	ld (DisplayListB_Stage+3:16), wa                                  ; F80A35  f1 f9 12 50
	cp	wa, (0x0c30:16)                              ; F80A39  d1 30 0c f0
	jr nc, .LF80A50                                      ; F80A3D  6f 11
	ld (0x0c30:16), wa                                  ; F80A3F  f1 30 0c 50
	ld (0x0c18:16), wa                                  ; F80A43  f1 18 0c 50
	ld (0x603470:24), wa                                ; F80A47  f2 70 34 60 50
	ld (DisplayListB_Stage+1:16), wa                                  ; F80A4C  f1 f7 12 50
.LF80A50:
	ld (0x0c32:16), wa                                  ; F80A50  f1 32 0c 50
.LF80A54:
	ld wa, (0x0c32:16)                                 ; F80A54  d1 32 0c 20
	sub	wa, (0x0c30:16)                              ; F80A58  d1 30 0c a0
	inc 1,WA                                             ; F80A5C  d8 61
	ld (0x603472:24), wa                                ; F80A5E  f2 72 34 60 50
	jr .LF80A72                                          ; F80A63  68 0d
.LF80A65:
	ld (0x0c1a:16), wa                                  ; F80A65  f1 1a 0c 50
	ld (0x603475:24), wa                                ; F80A69  f2 75 34 60 50
	ld (DisplayListB_Stage+6:16), wa                                  ; F80A6E  f1 fc 12 50
.LF80A72:
	call T_Blink_Stop                                    ; F80A72  1d 24 2e f4
	calr MeasureC0py_DrawValues                                      ; F80A76  1e 24 ff
.LF80A79:
	ret                                                  ; F80A79  0e
; MeasureC0py_KeypadSign -- keypad code 0x80: put '+' back in (0x2820)
; Evidence: body is `ld (0x2820),0x2B / ret`; only caller is the 0x80 arm of MeasureC0py_NumberPad (no field here is signed).
MeasureC0py_KeypadSign:
	ld (0x2820:16), 0x2b                                 ; F80A7A  f1 20 28 00 2b
	ret                                                  ; F80A7F  0e
; MeasureC0py_BlinkSelectedField -- start the field blink on the field (0x0DBC) selects
; Evidence: unless blink is off or (0x2267)=0x0F: push BlinkArgPtrs_F80AAD[(0x0DBC)], call T_Blink_Command; the non-null entries 2/3/5 are the records of (0x12F7)/(0x12F9)/(0x12FC), the variables MeasureC0py_KeypadCommit writes.
MeasureC0py_BlinkSelectedField:
	bit	1, (UI_RequestBits:16)                               ; F80A80  f1 75 20 c9
	jr z, .LF80AAC                                       ; F80A84  66 26
	cp	(0x2267:16), 0x0f                            ; F80A86  c1 67 22 3f 0f
	jr z, .LF80AAC                                       ; F80A8B  66 1f
	xor XWA,XWA                                          ; F80A8D  e8 d0
	ld a, (MeasureC0py_Field:16)                                   ; F80A8F  c1 bc 0d 21
	sla xwa, 0x02                                        ; F80A93  e8 ec 02
	ld XIY,BlinkArgPtrs_F80AAD                           ; F80A96  45 ad 0a f8 00
	ld	xiy, (xiy+wa)                                ; F80A9B  e3 07 f4 e0 25
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80AA0  f1 40 25 00 00
	push XIY                                             ; F80AA5  3d
	call T_Blink_Command                                 ; F80AA6  1d 20 2e f4
	inc 4,XSP                                            ; F80AAA  ef 64
.LF80AAC:
	ret                                                  ; F80AAC  0e
; ---------------------------------------------------------------------
; BlinkArgPtrs_F80AAD -- 7 LE32 pointers, same idiom
;
; Read by: `ld XIY,0x00F80AAD / ld XIY,(XIY+WA)` at 0xF80A96-0xF80A9F.
; Inputs:  WA = (0x0DBC) * 4.
; ENTRY COUNT 7: 0, 0, 0x00F3BD25, 0x00F3BD2F, 0, 0x00F3BD39, 0; word 7 is
;          `call 0xF42E80`.  ★ 0xF80AAD + 7*4 = 0xF80AC9 = that instruction.
;          Note this table has THREE null entries, two of them interior, so the
;          count cannot be taken as "until the first null".
; Evidence / Unknown: as BlinkArgPtrs_F8024D.
; ---------------------------------------------------------------------
BlinkArgPtrs_F80AAD:
	.long 0x00000000                                 ; F80AAD  [  0]
	.long 0x00000000                                 ; F80AB1  [  1]
	.long 0x00f3bd25                                 ; F80AB5  [  2]
	.long 0x00f3bd2f                                 ; F80AB9  [  3]
	.long 0x00000000                                 ; F80ABD  [  4]
	.long 0x00f3bd39                                 ; F80AC1  [  5]
	.long 0x00000000                                 ; F80AC5  [  6]
; Paint_MeasureInsert -- paints the screen whose own text reads "MEASURE INSERT", "FROM TRACK", "TO TRACK"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 6 time(s); XIY = list start, XIX = list end.  2 of those 6 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF80B14  interpreter A  list 0xF3BDCF  DL_MeasureInsertFromTrackToTrack
;        text: "MEASURE INSERT"; "FROM TRACK"; "TO TRACK"; ":"; ":"; "FIRST MEASURE"
;     site 0xF80B4A  interpreter A  list 0xF3A461  DL_AreYouSure
;        text: "Are You Sure ?"
; Evidence: the list address is the `ld XIY,0x00F3BDCF` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_MeasureInsert:
	call T_CallbackQueue_ResetAndRestartTask2            ; F80AC9  1d 80 2e f4
	cp	(UI_ScreenStage:16), 0x00                            ; F80ACD  c1 7e 20 3f 00
	jr nz, .LF80AEF                                      ; F80AD2  6e 1b
	call T_MeasureInsert_InitFields                                        ; F80AD4  1d a8 29 f4
	or	(UI_RequestBits:16), 0x01                            ; F80AD8  c1 75 20 3e 01
	ldw (PanelDial_DownButton:16), 0x0484                              ; F80ADD  f1 9b 20 02 84 04
	ldw (0x2666:16), 0xffff                              ; F80AE3  f1 66 26 02 ff ff
	ldw (0x266a:16), 0xffff                              ; F80AE9  f1 6a 26 02 ff ff
.LF80AEF:
	calr PromB_LCD_ScreenRedraw_Begin                                          ; F80AEF  1e e7 d7
	ld (LCD_CurrentLayer:16), 0x02                                 ; F80AF2  f1 40 25 00 02
	ld XIY,DL_F3BCCB                                     ; F80AF7  45 cb bc f3 00
	ld XIX,DL_F3BD07                                     ; F80AFC  44 07 bd f3 00
	call T_DisplayList_Run                               ; F80B01  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80B05  f1 40 25 00 00
	ld XIY,DL_MeasureInsertFromTrackToTrack              ; F80B0A  45 cf bd f3 00
	ld XIX,Paint_MeasureInsert_DL                                     ; F80B0F  44 bf be f3 00
	call T_DisplayList_Run                               ; F80B14  1d f0 17 f4
	cp	(UI_ScreenStage:16), 0x00                            ; F80B18  c1 7e 20 3f 00
	jr nz, .LF80B32                                      ; F80B1D  6e 13
	ld XIY,Paint_MeasureInsert_DL                                     ; F80B1F  45 bf be f3 00
	ld XIX,DL_F3BEF7                                     ; F80B24  44 f7 be f3 00
	call T_DisplayList_Run                               ; F80B29  1d f0 17 f4
	calr Paint_MeasureInsert_Nop                                      ; F80B2D  1e 35 00
	jr .LF80B4E                                          ; F80B30  68 1c
.LF80B32:
	ld XIY,DL_F3BD90                                     ; F80B32  45 90 bd f3 00
	ld XIX,DL_MeasureInsertFromTrackToTrack              ; F80B37  44 cf bd f3 00
	call T_DisplayList_Run                               ; F80B3C  1d f0 17 f4
	ld XIY,DL_AreYouSure                                 ; F80B40  45 61 a4 f3 00
	ld XIX,DL_TrackMergeOkTrackTrackTrack                ; F80B45  44 7f a4 f3 00
	call T_DisplayList_Run                               ; F80B4A  1d f0 17 f4
.LF80B4E:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80B4E  f1 40 25 00 00
	ld XIY,DL_F3BEF7                                     ; F80B53  45 f7 be f3 00
	ld XIX,Data_F3BF48                                   ; F80B58  44 48 bf f3 00
	call T_DisplayListB_Run                              ; F80B5D  1d f4 17 f4
	calr PromB_LCD_ScreenRedraw_End                                          ; F80B61  1e 83 d7
	ret                                                  ; F80B64  0e
Paint_MeasureInsert_Nop:
	ret                                                  ; F80B65  0e
; ScreenLeaveBody_MeasureInsert -- the whole body of the MeasureInsert screen's Leave method
; Evidence: prom_b ScreenLeave_MeasureInsert (0xF7D25E) is `call 0xF80B66 / ret` (+4 of screen object 0xF430D0); body `call T_MeasureInsert_OnLeave / ret`.
ScreenLeaveBody_MeasureInsert:
	call T_MeasureInsert_OnLeave                                        ; F80B66  1d ac 29 f4
	ret                                                  ; F80B6A  0e
; ButtonTable_MeasureInsert_StageZero_Nop0: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x00.
ButtonTable_MeasureInsert_StageZero_Nop0:
	ret                                                  ; F80B6B  0e
; ButtonTable_MeasureInsert_StageZero_Nop1: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x01.
ButtonTable_MeasureInsert_StageZero_Nop1:
	ret                                                  ; F80B6C  0e
; ButtonTable_MeasureInsert_StageZero_Nop2: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x02.
ButtonTable_MeasureInsert_StageZero_Nop2:
	ret                                                  ; F80B6D  0e
; ButtonTable_MeasureInsert_StageZero_Nop3: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x03.
ButtonTable_MeasureInsert_StageZero_Nop3:
	ret                                                  ; F80B6E  0e
; SoftKeyCol5_MeasureInsert_StageZero: the 5th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_MeasureInsert_StageZero slot 0x04.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol5_MeasureInsert_StageZero:
	bit	1, (UI_RequestBits:16)                               ; F80B6F  f1 75 20 c9
	jr z, .LF80B79                                       ; F80B73  66 04
	call T_Blink_Stop                                    ; F80B75  1d 24 2e f4
.LF80B79:
	or	(UI_RequestBits:16), 0x08                            ; F80B79  c1 75 20 3e 08
	ld (0x0e18:16), 0x01                                 ; F80B7E  f1 18 0e 00 01
	bit 0x07,W                                           ; F80B83  c8 33 07
	jr z, .LF80B8E                                       ; F80B86  66 06
	call T_MeasureInsert_StepFieldDown                                        ; F80B88  1d cc 29 f4
	jr .LF80B92                                          ; F80B8C  68 04
.LF80B8E:
	call T_MeasureInsert_StepFieldUp                                        ; F80B8E  1d c8 29 f4
.LF80B92:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80B92  f1 40 25 00 00
	calr ButtonTable_SequencerMedley_Nop                                          ; F80B97  1e 3e d7
	ld XIY,DL_F3BEF7                                     ; F80B9A  45 f7 be f3 00
	ld XIX,0x00f3bf3d                                    ; F80B9F  44 3d bf f3 00
	call T_DisplayListB_Run                              ; F80BA4  1d f4 17 f4
	ret                                                  ; F80BA8  0e
; ButtonTable_MeasureInsert_StageZero_Nop5: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x05.
ButtonTable_MeasureInsert_StageZero_Nop5:
	ret                                                  ; F80BA9  0e
; ButtonTable_MeasureInsert_StageZero_Nop6: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x06.
ButtonTable_MeasureInsert_StageZero_Nop6:
	ret                                                  ; F80BAA  0e
; ButtonTable_MeasureInsert_StageZero_Nop7: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x07.
ButtonTable_MeasureInsert_StageZero_Nop7:
	ret                                                  ; F80BAB  0e
; LcdKeyRow1_MeasureInsert_StageZero: row 1 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureInsert_StageZero slot 0x08.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow1_MeasureInsert_StageZero:
	bit 0x07,W                                           ; F80BAC  c8 33 07
	jr nz, .LF80BB8                                      ; F80BAF  6e 07
	calr Blink_DisableThenStop                                          ; F80BB1  1e 91 e6
	call T_MeasureInsert_LcdKeyRow1                                        ; F80BB4  1d d4 29 f4
.LF80BB8:
	ret                                                  ; F80BB8  0e
; LcdKeyRow2_MeasureInsert_StageZero: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureInsert_StageZero slot 0x09.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow2_MeasureInsert_StageZero:
	bit 0x07,W                                           ; F80BB9  c8 33 07
	jr z, .LF80BCE                                       ; F80BBC  66 10
	cp	(MeasureInsert_Field:16), 0x01                            ; F80BBE  c1 da 0d 3f 01
	jr z, .LF80BED                                       ; F80BC3  66 28
	calr Blink_DisableThenStop                                          ; F80BC5  1e 7d e6
	call T_MeasureInsert_SelectField1                                        ; F80BC8  1d b0 29 f4
	jr .LF80BDC                                          ; F80BCC  68 0e
.LF80BCE:
	cp	(MeasureInsert_Field:16), 0x04                            ; F80BCE  c1 da 0d 3f 04
	jr z, .LF80BED                                       ; F80BD3  66 18
	calr Blink_DisableThenStop                                          ; F80BD5  1e 6d e6
	call T_MeasureInsert_SelectField4                                        ; F80BD8  1d bc 29 f4
.LF80BDC:
	ld a, (MeasureInsert_Field:16)                                   ; F80BDC  c1 da 0d 21
	ld (DisplayListB_Stage+9:16), a                                   ; F80BE0  f1 ff 12 41
	calr MeasureInsert_DrawValues                                      ; F80BE4  1e 14 01
	calr MeasureInsert_DrawFieldCursor                                      ; F80BE7  1e 04 00
	calr Paint_MeasureInsert_Nop                                      ; F80BEA  1e 78 ff
.LF80BED:
	ret                                                  ; F80BED  0e
; MeasureInsert_DrawFieldCursor -- clear LCD layer 1, then fill the box of the MEASURE INSERT field (0x12FF) selects
; Evidence: (0x2540)=1; site 0xF80C00 runs DL_F39551-0xF39559 (op 0E ClearColumns); execution falls through the unreferenced label sub_F80C04 into DLB_Handler_Array8 on op-03 record 0xF3BF3D ((0x12FF)&7, boxes 0xF3BF48, swi 5 FillRect).  Callers first store (0x0DDA) into (0x12FF).
MeasureInsert_DrawFieldCursor:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F80BEE  f1 40 25 00 01
	calr ButtonTable_SequencerMedley_Nop                                          ; F80BF3  1e e2 d6
	ld XIY,DL_F39551                                     ; F80BF6  45 51 95 f3 00
	ld XIX,Data_F39559                                   ; F80BFB  44 59 95 f3 00
	call T_DisplayList_Run                               ; F80C00  1d f0 17 f4
; (sub_F80C04 removed 2026-10-04: no code names it and the line above falls through into it -- part of MeasureInsert_DrawFieldCursor;
;  notes/prom_a_stray_label_removal.py)
	ld XIY,0x00f3bf3d                                    ; F80C04  45 3d bf f3 00
	call T_DLB_Handler_Array8                                        ; F80C09  1d 1c 18 f4
	ret                                                  ; F80C0D  0e
; LcdKeyRow3_MeasureInsert_StageZero: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureInsert_StageZero slot 0x0A.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow3_MeasureInsert_StageZero:
	bit 0x07,W                                           ; F80C0E  c8 33 07
	jr nz, .LF80C23                                      ; F80C11  6e 10
	cp	(MeasureInsert_Field:16), 0x05                            ; F80C13  c1 da 0d 3f 05
	jr z, .LF80C42                                       ; F80C18  66 28
	calr Blink_EnableThenStop_Copy                                          ; F80C1A  1e 1a e6
	call T_MeasureInsert_SelectField5                                        ; F80C1D  1d c0 29 f4
	jr .LF80C31                                          ; F80C21  68 0e
.LF80C23:
	cp	(MeasureInsert_Field:16), 0x02                            ; F80C23  c1 da 0d 3f 02
	jr z, .LF80C42                                       ; F80C28  66 18
	calr Blink_EnableThenStop_Copy                                          ; F80C2A  1e 0a e6
	call T_MeasureInsert_SelectField2                                        ; F80C2D  1d b4 29 f4
.LF80C31:
	ld a, (MeasureInsert_Field:16)                                   ; F80C31  c1 da 0d 21
	ld (DisplayListB_Stage+9:16), a                                   ; F80C35  f1 ff 12 41
	calr MeasureInsert_DrawValues                                      ; F80C39  1e bf 00
	calr MeasureInsert_DrawFieldCursor                                      ; F80C3C  1e af ff
	calr Paint_MeasureInsert_Nop                                      ; F80C3F  1e 23 ff
.LF80C42:
	ret                                                  ; F80C42  0e
; LcdKeyRow4_MeasureInsert_StageZero: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks the
;   CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureInsert_StageZero slot 0x0B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow4_MeasureInsert_StageZero:
	bit 0x07,W                                           ; F80C43  c8 33 07
	jr z, .LF80C58                                       ; F80C46  66 10
	cp	(MeasureInsert_Field:16), 0x03                            ; F80C48  c1 da 0d 3f 03
	jr z, .LF80C77                                       ; F80C4D  66 28
	calr Blink_EnableThenStop_Copy                                          ; F80C4F  1e e5 e5
	call T_MeasureInsert_SelectField3                                        ; F80C52  1d b8 29 f4
	jr .LF80C66                                          ; F80C56  68 0e
.LF80C58:
	cp	(MeasureInsert_Field:16), 0x06                            ; F80C58  c1 da 0d 3f 06
	jr z, .LF80C77                                       ; F80C5D  66 18
	calr Blink_DisableThenStop                                          ; F80C5F  1e e3 e5
	call T_MeasureInsert_SelectField6                                        ; F80C62  1d c4 29 f4
.LF80C66:
	ld a, (MeasureInsert_Field:16)                                   ; F80C66  c1 da 0d 21
	ld (DisplayListB_Stage+9:16), a                                   ; F80C6A  f1 ff 12 41
	calr MeasureInsert_DrawValues                                      ; F80C6E  1e 8a 00
	calr MeasureInsert_DrawFieldCursor                                      ; F80C71  1e 7a ff
	calr Paint_MeasureInsert_Nop                                      ; F80C74  1e ee fe
.LF80C77:
	ret                                                  ; F80C77  0e
; ButtonTable_MeasureInsert_StageZero_Nop12: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x0C.
ButtonTable_MeasureInsert_StageZero_Nop12:
	ret                                                  ; F80C78  0e
; ButtonTable_MeasureInsert_StageZero_Nop13: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x0D.
ButtonTable_MeasureInsert_StageZero_Nop13:
	ret                                                  ; F80C79  0e
; ButtonTable_MeasureInsert_StageZero_Nop14: a bare ret -- ButtonTable_MeasureInsert_StageZero slot 0x0E.
ButtonTable_MeasureInsert_StageZero_Nop14:
	ret                                                  ; F80C7A  0e
; ExitKey_MeasureInsert_StageZero: the EXIT key; ButtonTable_MeasureInsert_StageZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_MeasureInsert_StageZero:
	bit 0x07,W                                           ; F80C7B  c8 33 07
	jr z, .LF80C82                                       ; F80C7E  66 02
	jr .LF80C88                                          ; F80C80  68 06
.LF80C82:
	ldw (UI_Request:16), 0x801a                              ; F80C82  f1 70 20 02 1a 80
.LF80C88:
	ret                                                  ; F80C88  0e
; ButtonTable_MeasureInsert_StageZero_Nop16: a bare ret -- ButtonTable_MeasureInsert_StageZero slots 0x10, 0x11,
;   0x12, 0x13, 0x14.
ButtonTable_MeasureInsert_StageZero_Nop16:
	ret                                                  ; F80C89  0e
; MeasureInsert_StageZero_Button21 -- ButtonTable_MeasureInsert_StageZero slot 0x15, NOT NAMED: slot 0x15 is
;   only the VARIANT-1 already-held rewrite of base code 0x04; the SX-WSA1R is variant 2, so the slot is never
;   delivered here.
MeasureInsert_StageZero_Button21:
	bit	1, (UI_RequestBits:16)                               ; F80C8A  f1 75 20 c9
	jr z, .LF80C94                                       ; F80C8E  66 04
	call T_Blink_Stop                                    ; F80C90  1d 24 2e f4
.LF80C94:
	or	(UI_RequestBits:16), 0x08                            ; F80C94  c1 75 20 3e 08
	ld (0x0e18:16), 0x04                                 ; F80C99  f1 18 0e 00 04
	bit 0x07,W                                           ; F80C9E  c8 33 07
	jr z, .LF80CA9                                       ; F80CA1  66 06
	call T_MeasureInsert_StepFieldDown                                        ; F80CA3  1d cc 29 f4
	jr .LF80CAD                                          ; F80CA7  68 04
.LF80CA9:
	call T_MeasureInsert_StepFieldUp                                        ; F80CA9  1d c8 29 f4
.LF80CAD:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80CAD  f1 40 25 00 00
	calr ButtonTable_SequencerMedley_Nop                                          ; F80CB2  1e 23 d6
	ld XIY,DL_F3BEF7                                     ; F80CB5  45 f7 be f3 00
	ld XIX,0x00f3bf3d                                    ; F80CBA  44 3d bf f3 00
	call T_DisplayListB_Run                              ; F80CBF  1d f4 17 f4
	ret                                                  ; F80CC3  0e
; ButtonTable_MeasureInsert_StageZero_Nop22: a bare ret -- ButtonTable_MeasureInsert_StageZero slots 0x16, 0x17,
;   0x18, 0x19, 0x1A.
ButtonTable_MeasureInsert_StageZero_Nop22:
	ret                                                  ; F80CC4  0e
; NumberPadKey_MeasureInsert_StageZero: the twelve-key number pad (0-9, +/-, ENTER);
;   ButtonTable_MeasureInsert_StageZero slot 0x1B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
NumberPadKey_MeasureInsert_StageZero:
	calr MeasureInsert_NumberPad                                      ; F80CC5  1e 4a 00
	ret                                                  ; F80CC8  0e
; ButtonTable_MeasureInsert_StageZero_Nop28: a bare ret -- ButtonTable_MeasureInsert_StageZero slots 0x1C, 0x1D,
;   0x1E, 0x1F.
ButtonTable_MeasureInsert_StageZero_Nop28:
	ret                                                  ; F80CC9  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop0: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x00.
ButtonTable_MeasureInsert_StageNonZero_Nop0:
	ret                                                  ; F80CCA  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop1: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x01.
ButtonTable_MeasureInsert_StageNonZero_Nop1:
	ret                                                  ; F80CCB  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop2: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x02.
ButtonTable_MeasureInsert_StageNonZero_Nop2:
	ret                                                  ; F80CCC  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop3: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x03.
ButtonTable_MeasureInsert_StageNonZero_Nop3:
	ret                                                  ; F80CCD  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop4: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x04.
ButtonTable_MeasureInsert_StageNonZero_Nop4:
	ret                                                  ; F80CCE  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop5: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x05.
ButtonTable_MeasureInsert_StageNonZero_Nop5:
	ret                                                  ; F80CCF  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop6: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x06.
ButtonTable_MeasureInsert_StageNonZero_Nop6:
	ret                                                  ; F80CD0  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop7: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x07.
ButtonTable_MeasureInsert_StageNonZero_Nop7:
	ret                                                  ; F80CD1  0e
; LcdKeyRow1_MeasureInsert_StageNonZero: row 1 of the five key pairs flanking the LCD; bit 7 of the code picks
;   the CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureInsert_StageNonZero slot 0x08.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow1_MeasureInsert_StageNonZero:
	bit 0x07,W                                           ; F80CD2  c8 33 07
	jr nz, .LF80CE0                                      ; F80CD5  6e 09
	and	(UI_RequestBits:16), 0x6f                            ; F80CD7  c1 75 20 3c 6f
	call T_MeasureInsert_LcdKeyRow1                                        ; F80CDC  1d d4 29 f4
.LF80CE0:
	ret                                                  ; F80CE0  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop9: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x09.
ButtonTable_MeasureInsert_StageNonZero_Nop9:
	ret                                                  ; F80CE1  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop10: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x0A.
ButtonTable_MeasureInsert_StageNonZero_Nop10:
	ret                                                  ; F80CE2  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop11: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x0B.
ButtonTable_MeasureInsert_StageNonZero_Nop11:
	ret                                                  ; F80CE3  0e
; LcdKeyRow5_MeasureInsert_StageNonZero: row 5 of the five key pairs flanking the LCD; bit 7 of the code picks
;   the CP2 side (set) or the CP1 side (clear); ButtonTable_MeasureInsert_StageNonZero slot 0x0C.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow5_MeasureInsert_StageNonZero:
	bit 0x07,W                                           ; F80CE4  c8 33 07
	jr nz, LcdKeyRow5_MeasureInsert_StageNonZero_Return                                    ; F80CE7  6e 04
	call T_MeasureInsert_ReturnToStageZero                                        ; F80CE9  1d d0 29 f4
LcdKeyRow5_MeasureInsert_StageNonZero_Return:
	ret                                                  ; F80CED  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop13: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x0D.
ButtonTable_MeasureInsert_StageNonZero_Nop13:
	ret                                                  ; F80CEE  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop14: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slot 0x0E.
ButtonTable_MeasureInsert_StageNonZero_Nop14:
	ret                                                  ; F80CEF  0e
; ExitKey_MeasureInsert_StageNonZero: the EXIT key; ButtonTable_MeasureInsert_StageNonZero slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_MeasureInsert_StageNonZero:
	bit 0x07,W                                           ; F80CF0  c8 33 07
	jr nz, .LF80CF9                                      ; F80CF3  6e 04
	call T_MeasureInsert_ReturnToStageZero                                        ; F80CF5  1d d0 29 f4
.LF80CF9:
	ret                                                  ; F80CF9  0e
; ButtonTable_MeasureInsert_StageNonZero_Nop16: a bare ret -- ButtonTable_MeasureInsert_StageNonZero slots 0x10,
;   0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F.
ButtonTable_MeasureInsert_StageNonZero_Nop16:
	ret                                                  ; F80CFA  0e
; MeasureInsert_DrawValues -- redraw the live values of the MEASURE INSERT screen on layer 0
; Evidence: (0x2540)=0; site 0xF80D0D runs interpreter B over DL_F3BEF7-0xF3BF3D (same six variables as MeasureC0py_DrawValues), the list Paint_MeasureInsert runs at 0xF80B53.
MeasureInsert_DrawValues:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80CFB  f1 40 25 00 00
	calr ButtonTable_SequencerMedley_Nop                                          ; F80D00  1e d5 d5
	ld XIY,DL_F3BEF7                                     ; F80D03  45 f7 be f3 00
	ld XIX,0x00f3bf3d                                    ; F80D08  44 3d bf f3 00
	call T_DisplayListB_Run                              ; F80D0D  1d f4 17 f4
	ret                                                  ; F80D11  0e
; MeasureInsert_NumberPad -- NUMBER PAD key on the MEASURE INSERT screen: dispatch on (0x2267)
; Evidence: reached only by `calr` at 0xF80CC5, slot 27 of ButtonTable_MeasureInsert_StageZero; digit / 0x0F / 0x80 arms then MeasureInsert_BlinkSelectedField.
MeasureInsert_NumberPad:
	ld a, (0x2267:16)                                   ; F80D12  c1 67 22 21
	cp A,0x09                                            ; F80D16  c9 cf 09
	jr le, .LF80D27                                      ; F80D19  62 0c
	cp A,0x0f                                            ; F80D1B  c9 cf 0f
	jr z, .LF80D2C                                       ; F80D1E  66 0c
	cp A,0x80                                            ; F80D20  c9 cf 80
	jr z, .LF80D31                                       ; F80D23  66 0c
	jr .LF80D34                                          ; F80D25  68 0d
.LF80D27:
	calr Blink_SetEnable_1_4                                      ; F80D27  1e 0e 00
	jr .LF80D34                                          ; F80D2A  68 08
.LF80D2C:
	calr MeasureInsert_KeypadCommit                                      ; F80D2C  1e 13 00
	jr .LF80D34                                          ; F80D2F  68 03
.LF80D31:
	calr MeasureInsert_KeypadSign                                      ; F80D31  1e ab 00
.LF80D34:
	calr MeasureInsert_BlinkSelectedField                                      ; F80D34  1e ae 00
	ret                                                  ; F80D37  0e
Blink_SetEnable_1_4:
	pushw 0x01                                           ; F80D38  0b 01 00
	call T_Blink_SetEnable                               ; F80D3B  1d 28 2e f4
	inc 2,XSP                                            ; F80D3F  ef 62
	ret                                                  ; F80D41  0e
; MeasureInsert_KeypadCommit -- keypad code 0x0F: store the typed measure number into the field (0x0DDA) selects
; Evidence: 1..999; field 2 -> (0x0C18), (0x603468), (0x12F7), (0x0DDC); field 3 -> (0x0DDE)/(0x12F9), keeping first<=last; (0x60346A)=last-first+1; field 5 -> (0x0C1A), (0x60346D), (0x12FC); then T_Blink_Stop and MeasureInsert_DrawValues.
; Same `cp (0x02),0x20` early return as MeasureC0py_KeypadCommit -- not established.
MeasureInsert_KeypadCommit:
	cp	(0x02:8), 0x20                               ; F80D42  c0 02 3f 20
	jrl z, .LF80DDE                                      ; F80D46  76 95 00
	ld (0x2826:16), 0x03                                 ; F80D49  f1 26 28 00 03
	call T_AsciiDigits3_ToValue                          ; F80D4E  1d f0 32 f4
	cp wa, 0x01:i3                                         ; F80D52  d8 d9
	jrl lt, .LF80DDE                                     ; F80D54  71 87 00
	cp WA,0x03e7                                         ; F80D57  d8 cf e7 03
	jrl gt, .LF80DDE                                     ; F80D5B  7a 80 00
	cp	(MeasureInsert_Field:16), 0x02                            ; F80D5E  c1 da 0d 3f 02
	jr z, .LF80D75                                       ; F80D63  66 10
	cp	(MeasureInsert_Field:16), 0x03                            ; F80D65  c1 da 0d 3f 03
	jr z, .LF80D96                                       ; F80D6A  66 2a
	cp	(MeasureInsert_Field:16), 0x05                            ; F80D6C  c1 da 0d 3f 05
	jr z, .LF80DCA                                       ; F80D71  66 57
	jr .LF80DDE                                          ; F80D73  68 69
.LF80D75:
	ld (0x0c18:16), wa                                  ; F80D75  f1 18 0c 50
	ld (0x603468:24), wa                                ; F80D79  f2 68 34 60 50
	ld (DisplayListB_Stage+1:16), wa                                  ; F80D7E  f1 f7 12 50
	cp	wa, (0x0dde:16)                              ; F80D82  d1 de 0d f0
	jr ule, .LF80D90                                     ; F80D86  63 08
	ld (0x0dde:16), wa                                  ; F80D88  f1 de 0d 50
	ld (DisplayListB_Stage+3:16), wa                                  ; F80D8C  f1 f9 12 50
.LF80D90:
	ld (0x0ddc:16), wa                                  ; F80D90  f1 dc 0d 50
	jr .LF80DB9                                          ; F80D94  68 23
.LF80D96:
	ld (0x0dde:16), wa                                  ; F80D96  f1 de 0d 50
	ld (DisplayListB_Stage+3:16), wa                                  ; F80D9A  f1 f9 12 50
	cp	wa, (0x0ddc:16)                              ; F80D9E  d1 dc 0d f0
	jr nc, .LF80DB5                                      ; F80DA2  6f 11
	ld (0x0ddc:16), wa                                  ; F80DA4  f1 dc 0d 50
	ld (DisplayListB_Stage+1:16), wa                                  ; F80DA8  f1 f7 12 50
	ld (0x0c18:16), wa                                  ; F80DAC  f1 18 0c 50
	ld (0x603468:24), wa                                ; F80DB0  f2 68 34 60 50
.LF80DB5:
	ld (0x0dde:16), wa                                  ; F80DB5  f1 de 0d 50
.LF80DB9:
	ld wa, (0x0dde:16)                                 ; F80DB9  d1 de 0d 20
	sub	wa, (0x0ddc:16)                              ; F80DBD  d1 dc 0d a0
	inc 1,WA                                             ; F80DC1  d8 61
	ld (0x60346a:24), wa                                ; F80DC3  f2 6a 34 60 50
	jr .LF80DD7                                          ; F80DC8  68 0d
.LF80DCA:
	ld (0x0c1a:16), wa                                  ; F80DCA  f1 1a 0c 50
	ld (0x60346d:24), wa                                ; F80DCE  f2 6d 34 60 50
	ld (DisplayListB_Stage+6:16), wa                                  ; F80DD3  f1 fc 12 50
.LF80DD7:
	call T_Blink_Stop                                    ; F80DD7  1d 24 2e f4
	calr MeasureInsert_DrawValues                                      ; F80DDB  1e 1d ff
.LF80DDE:
	ret                                                  ; F80DDE  0e
; MeasureInsert_KeypadSign -- keypad code 0x80: put '+' back in (0x2820)
; Evidence: `ld (0x2820),0x2B / ret`; only caller is the 0x80 arm of MeasureInsert_NumberPad.
MeasureInsert_KeypadSign:
	ld (0x2820:16), 0x2b                                 ; F80DDF  f1 20 28 00 2b
	ret                                                  ; F80DE4  0e
; MeasureInsert_BlinkSelectedField -- start the field blink on the field (0x0DDA) selects
; Evidence: push BlinkArgPtrs_F80E12[(0x0DDA)], call T_Blink_Command, unless blink is off or (0x2267)=0x0F.
MeasureInsert_BlinkSelectedField:
	bit	1, (UI_RequestBits:16)                               ; F80DE5  f1 75 20 c9
	jr z, .LF80E11                                       ; F80DE9  66 26
	cp	(0x2267:16), 0x0f                            ; F80DEB  c1 67 22 3f 0f
	jr z, .LF80E11                                       ; F80DF0  66 1f
	xor XWA,XWA                                          ; F80DF2  e8 d0
	ld a, (MeasureInsert_Field:16)                                   ; F80DF4  c1 da 0d 21
	sla xwa, 0x02                                        ; F80DF8  e8 ec 02
	ld XIY,BlinkArgPtrs_F80E12                           ; F80DFB  45 12 0e f8 00
	ld	xiy, (xiy+wa)                                ; F80E00  e3 07 f4 e0 25
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80E05  f1 40 25 00 00
	push XIY                                             ; F80E0A  3d
	call T_Blink_Command                                 ; F80E0B  1d 20 2e f4
	inc 4,XSP                                            ; F80E0F  ef 64
.LF80E11:
	ret                                                  ; F80E11  0e
; ---------------------------------------------------------------------
; BlinkArgPtrs_F80E12 -- 7 LE32 pointers, same idiom
;
; Read by: `ld XIY,0x00F80E12 / ld XIY,(XIY+WA)` at 0xF80DFB-0xF80E04.
; Inputs:  WA = (0x0DDA) * 4.
; ENTRY COUNT 7: 0, 0, 0x00F3BF15, 0x00F3BF1F, 0, 0x00F3BF29, 0; word 7 is
;          `call 0xF42E80`.  ★ 0xF80E12 + 7*4 = 0xF80E2E = that instruction.
; Evidence / Unknown: as BlinkArgPtrs_F8024D.  ⚠ This table and
;          BlinkArgPtrs_F80AAD have the SAME null pattern and their targets are
;          0x1F0 apart entry for entry, which is consistent with two screens
;          built from one template -- recorded as an observation, not decoded.
; ---------------------------------------------------------------------
BlinkArgPtrs_F80E12:
	.long 0x00000000                                 ; F80E12  [  0]
	.long 0x00000000                                 ; F80E16  [  1]
	.long 0x00f3bf15                                 ; F80E1A  [  2]
	.long 0x00f3bf1f                                 ; F80E1E  [  3]
	.long 0x00000000                                 ; F80E22  [  4]
	.long 0x00f3bf29                                 ; F80E26  [  5]
	.long 0x00000000                                 ; F80E2A  [  6]
; Paint_S0ngSelectName -- paints the screen whose own text reads "S0NG SELECT & NAME", " KB", "S0NG"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 1 time(s); XIY = list start, XIX = list end.  1 of those 1 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF80E65  interpreter A  list 0xF3C1AD  DL_S0ngSelectNameKbS0ngName
;        text: "S0NG SELECT & NAME"; " KB"; "S0NG"; ":"; "%"; ":"
; Evidence: the list address is the `ld XIY,0x00F3C1AD` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_S0ngSelectName:
	call T_CallbackQueue_ResetAndRestartTask2            ; F80E2E  1d 80 2e f4
	call S0ngSelectName_PrepareValues                                      ; F80E32  1d 8d 17 f8
	or	(UI_RequestBits:16), 0x01                            ; F80E36  c1 75 20 3e 01
	ldw (PanelDial_DownButton:16), 0x0605                              ; F80E3B  f1 9b 20 02 05 06
	ldw (0x2666:16), 0xffff                              ; F80E41  f1 66 26 02 ff ff
	ldw (0x266a:16), 0xffff                              ; F80E47  f1 6a 26 02 ff ff
	bit	4, (UI_ScreenFlags:16)                               ; F80E4D  f1 95 20 cc
	jr nz, .LF80E69                                      ; F80E51  6e 16
	calr PromB_LCD_ScreenRedraw_Begin                                          ; F80E53  1e 83 d4
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80E56  f1 40 25 00 00
	ld XIY,DL_S0ngSelectNameKbS0ngName                   ; F80E5B  45 ad c1 f3 00
	ld XIX,S0ngSelectName_DrawValues_DL                                     ; F80E60  44 1e c3 f3 00
	call T_DisplayList_Run                               ; F80E65  1d f0 17 f4
.LF80E69:
	call S0ngSelectName_UpdateSizeValues                                      ; F80E69  1d 7d 14 f8
	call S0ngSelectName_DrawValues                                      ; F80E6D  1d 9b 0e f8
	call SongName_Draw6Chars                                      ; F80E71  1d 5e 16 f8
	ld (LCD_CurrentLayer:16), 0x01                                 ; F80E75  f1 40 25 00 01
	ld XIY,DL_F3C351                                     ; F80E7A  45 51 c3 f3 00
	ld XIX,0x00f3c35c                                    ; F80E7F  44 5c c3 f3 00
	call T_DLB_Handler_Array8                                        ; F80E84  1d 1c 18 f4
	ld XIY,0x00f3c35c                                    ; F80E88  45 5c c3 f3 00
	ld XIX,DL_F3C367                                     ; F80E8D  44 67 c3 f3 00
	call T_DLB_Handler_Array8                                        ; F80E92  1d 1c 18 f4
	call PromB_LCD_ScreenRedraw_End                                        ; F80E96  1d e7 e2 f7
	ret                                                  ; F80E9A  0e
; S0ngSelectName_DrawValues -- redraw the song name, song number, size in KB and percent on the SONG SELECT & NAME screen
; Evidence: (0x2540)=0; site 0xF80EAA runs interpreter B over S0ngSelectName_DrawValues_DL-DL_F3C351: string 0x12F6 (6 bytes, svc 8 at 0x0998), (0x12FC) 2 digits beside 'S0NG', (0x12FD) 3 digits at (0xF8,0x30) beside ' KB' (0x10A,0x30), (0x12FF) at (0xF0,0x3D) beside '%' (0x111,0x3D).
; Caller: Paint_S0ngSelectName only.
S0ngSelectName_DrawValues:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F80E9B  f1 40 25 00 00
	ld XIY,S0ngSelectName_DrawValues_DL                                     ; F80EA0  45 1e c3 f3 00
	ld XIX,DL_F3C351                                     ; F80EA5  44 51 c3 f3 00
	call T_DisplayListB_Run                              ; F80EAA  1d f4 17 f4
	ret                                                  ; F80EAE  0e
; ScreenLeaveBody_S0ngSelectName -- the Leave method body of the S0ngSelectName screen
; Evidence: prom_b ScreenLeave_S0ngSelectName (0xF7D27F) is `call 0xF80EAF / ret` (+4 of screen object 0xF431A0); body `call S0ngSelectName_Leave / ret`.
ScreenLeaveBody_S0ngSelectName:
	call S0ngSelectName_Leave                                      ; F80EAF  1d f7 17 f8
	ret                                                  ; F80EB3  0e
; ScreenButtonBody_S0ngSelectName -- the Button method body of the S0ngSelectName screen: dispatch on the button slot in HL
; Evidence: prom_b ScreenButton_S0ngSelectName (0xF7D284) is `call 0xF80EB4 / ret`.  Slots 0/0x11 -> S0ngSelectName_PrevSong, 1/0x12 -> NextSong, 3/0x14 -> CursorLeft, 4/0x15 -> CursorRight, 5/0x16 -> CharPrev, 6/0x17 -> CharNext, 7/0x18 -> ClearName; 0x0F (ExitKey) posts (0x2070)=0x8004 when W bit 7 is clear.
; The bottom row of DL_S0ngSelectNameKbS0ngName reads SONG < >, POSITION < >, ABC..789 < >, CLR, which is this pairing.
ScreenButtonBody_S0ngSelectName:
	cp hl, 0x00:i3                                         ; F80EB4  db d8
	jr z, .LF80F11                                       ; F80EB6  66 59
	cp HL,0x0011                                         ; F80EB8  db cf 11 00
	jr z, .LF80F11                                       ; F80EBC  66 53
	cp hl, 0x01:i3                                         ; F80EBE  db d9
	jr z, .LF80F17                                       ; F80EC0  66 55
	cp HL,0x0012                                         ; F80EC2  db cf 12 00
	jr z, .LF80F17                                       ; F80EC6  66 4f
	cp hl, 0x03:i3                                         ; F80EC8  db db
	jr z, .LF80F1D                                       ; F80ECA  66 51
	cp HL,0x0014                                         ; F80ECC  db cf 14 00
	jr z, .LF80F1D                                       ; F80ED0  66 4b
	cp hl, 0x04:i3                                         ; F80ED2  db dc
	jr z, .LF80F23                                       ; F80ED4  66 4d
	cp HL,0x0015                                         ; F80ED6  db cf 15 00
	jr z, .LF80F23                                       ; F80EDA  66 47
	cp hl, 0x05:i3                                         ; F80EDC  db dd
	jr z, .LF80F29                                       ; F80EDE  66 49
	cp HL,0x0016                                         ; F80EE0  db cf 16 00
	jr z, .LF80F29                                       ; F80EE4  66 43
	cp hl, 0x06:i3                                         ; F80EE6  db de
	jr z, .LF80F2F                                       ; F80EE8  66 45
	cp HL,0x0017                                         ; F80EEA  db cf 17 00
	jr z, .LF80F2F                                       ; F80EEE  66 3f
	cp hl, 0x07:i3                                         ; F80EF0  db df
	jr z, .LF80F35                                       ; F80EF2  66 41
	cp HL,0x0018                                         ; F80EF4  db cf 18 00
	jr z, .LF80F35                                       ; F80EF8  66 3b
	cp HL,0x000f                                         ; F80EFA  db cf 0f 00
	jr NZ,.LF80F39                                       ; F80EFE  6e 39
	bit 0x07,W                                           ; F80F00  c8 33 07
	jr nz, .LF80F0E                                      ; F80F03  6e 09
	ldw (UI_Request:16), 0x8004                              ; F80F05  f1 70 20 02 04 80
	jrl .LF80F39                                         ; F80F0B  78 2b 00
.LF80F0E:
	jrl .LF80F39                                         ; F80F0E  78 28 00
.LF80F11:
	call S0ngSelectName_PrevSong                                      ; F80F11  1d 34 14 f8
	jr .LF80F39                                          ; F80F15  68 22
.LF80F17:
	call S0ngSelectName_NextSong                                      ; F80F17  1d c7 14 f8
	jr .LF80F39                                          ; F80F1B  68 1c
.LF80F1D:
	call S0ngSelectName_CursorLeft                                      ; F80F1D  1d 12 15 f8
	jr .LF80F39                                          ; F80F21  68 16
.LF80F23:
	call S0ngSelectName_CursorRight                                      ; F80F23  1d 74 15 f8
	jr .LF80F39                                          ; F80F27  68 10
.LF80F29:
	call S0ngSelectName_CharPrev                                      ; F80F29  1d d6 15 f8
	jr .LF80F39                                          ; F80F2D  68 0a
.LF80F2F:
	call S0ngSelectName_CharNext                                      ; F80F2F  1d 1a 16 f8
	jr .LF80F39                                          ; F80F33  68 04
.LF80F35:
	call S0ngSelectName_ClearName                                      ; F80F35  1d 70 16 f8
.LF80F39:
	ret                                                  ; F80F39  0e
; ModeEnterBody_StepRecord: The whole body of ModeEnter_StepRecord (+0 ENTER of panel mode 6): (0x0C02) := 2 and
;   (0x0C00) := 0 (prom_b sub_F65C51), `or (0x2134),2` (the mode-change bit every mode ENTER sets), (0x2130) |= 0x100
;   and (0x215E) := 0 (sub_F65C00), (0x12A0) := 0. Its LEAVE twin 0xF80F4F (behind sub_F7D025) also saves the
;   0xC00-byte workspace 0x603400 back to the current bank (sub_F65C27). Basis: caller + body. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
ModeEnterBody_StepRecord:
	call T_F42B70                                        ; F80F3A  1d 70 2b f4
	orw	(0x2134:16), 0x0002                  ; F80F3E  d1 34 21 3e 02 00
	call T_F42BB4                                        ; F80F44  1d b4 2b f4
	ldw (0x12a0:16), 0x00                                ; F80F48  f1 a0 12 02 00 00
	ret                                                  ; F80F4E  0e
sub_F80F4F:
	orw	(0x2134:16), 0x0002                  ; F80F4F  d1 34 21 3e 02 00
	call T_F42BB8                                        ; F80F55  1d b8 2b f4
	ret                                                  ; F80F59  0e
; Paint_StepRecordPartSelect -- paints the screen whose own text reads "STEP RECORD", ": PART SELECT", "Press the up/down button under"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 3 time(s); XIY = list start, XIX = list end.  1 of those 3 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF80F75  interpreter A  list 0xF3C8A7  DL_StepRecordPartSelectPressTheUpDownButton
;        text: "STEP RECORD"; ": PART SELECT"; "Press the up/down button under"; "the screen corresponding to the"; "track that you want to"; "STEP RECORD."
; Evidence: the list address is the `ld XIY,0x00F3C8A7` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_StepRecordPartSelect:
	call T_CallbackQueue_ResetAndRestartTask2            ; F80F5A  1d 80 2e f4
	bit	4, (UI_ScreenFlags:16)                               ; F80F5E  f1 95 20 cc
	jr nz, .LF80F8F                                      ; F80F62  6e 2b
	call T_StepRecordPartSelect_ResetOnEntry                                        ; F80F64  1d c4 2b f4
	calr PromB_LCD_ScreenRedraw_Begin                                          ; F80F68  1e 6e d3
	ld XIY,DL_StepRecordPartSelectPressTheUpDownButton   ; F80F6B  45 a7 c8 f3 00
	ld XIX,DL_F3C947                                     ; F80F70  44 47 c9 f3 00
	call T_DisplayList_Run                               ; F80F75  1d f0 17 f4
	ld XIY,DL_F3934C                                     ; F80F79  45 4c 93 f3 00
	ld XIX,DL_F394E3                                     ; F80F7E  44 e3 94 f3 00
	call T_DisplayList_Run                               ; F80F83  1d f0 17 f4
	ld (LCD_CurrentLayer:16), 0x02                                 ; F80F87  f1 40 25 00 02
	calr TrackGrid_DrawPartLabels                                          ; F80F8C  1e c5 d3
.LF80F8F:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F80F8F  f1 40 25 00 01
	calr ButtonTable_SequencerMedley_Nop                                          ; F80F94  1e 41 d3
	ld XIY,DL_F3A0D1                                     ; F80F97  45 d1 a0 f3 00
	ld XIX,Data_F3A0D9                                   ; F80F9C  44 d9 a0 f3 00
	call T_DisplayList_Run                               ; F80FA1  1d f0 17 f4
	ld a, (0x0e5c:16)                                   ; F80FA5  c1 5c 0e 21
	cp a, 0x00:i3                                          ; F80FA9  c9 d8
	jr z, .LF80FBC                                       ; F80FAB  66 0f
	dec 1,A                                              ; F80FAD  c9 69
	ld (DisplayListB_Stage:16), a                                   ; F80FAF  f1 f6 12 41
	ld XIY,Data_F3A0D9                                   ; F80FB3  45 d9 a0 f3 00
	call T_DLB_Handler_Array8                                        ; F80FB8  1d 1c 18 f4
.LF80FBC:
	calr PromB_LCD_ScreenRedraw_End                                          ; F80FBC  1e 28 d3
	ret                                                  ; F80FBF  0e
; ScreenLeaveBody_StepRecordPartSelect -- the Leave method body of the StepRecordPartSelect screen
; Evidence: prom_b ScreenLeave_StepRecordPartSelect (0xF7D28F) is `call 0xF80FC0 / ret` (+4 of screen object 0xF43170); body `call T_StepRecordPartSelect_OnLeave / ret` (prom_b 0xF6650F: (0x60341E)=(0x3010), T_F40CB4, and (0x34BB),0xFB).
ScreenLeaveBody_StepRecordPartSelect:
	call T_StepRecordPartSelect_OnLeave                                        ; F80FC0  1d c8 2b f4
	ret                                                  ; F80FC4  0e
; SoftKeyCol1_StepRecordPartSelect: the 1st of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_StepRecordPartSelect slots 0x00,
;   0x11.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol1_StepRecordPartSelect:
	call SoftKeyCol1_TrackClear_StageZero                 ; F80FC5  1d ff ec f7
	call T_StepRecordPartSelect_OpenStepRecord                                        ; F80FC9  1d bc 2b f4
	ret                                                  ; F80FCD  0e
; SoftKeyCol2_StepRecordPartSelect: the 2nd of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_StepRecordPartSelect slots 0x01,
;   0x12.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol2_StepRecordPartSelect:
	call SoftKeyCol2_TrackClear_StageZero                 ; F80FCE  1d 18 ed f7
	call T_StepRecordPartSelect_OpenStepRecord                                        ; F80FD2  1d bc 2b f4
	ret                                                  ; F80FD6  0e
; SoftKeyCol3_StepRecordPartSelect: the 3rd of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_StepRecordPartSelect slots 0x02,
;   0x13.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol3_StepRecordPartSelect:
	call SoftKeyCol3_TrackClear_StageZero                 ; F80FD7  1d 31 ed f7
	call T_StepRecordPartSelect_OpenStepRecord                                        ; F80FDB  1d bc 2b f4
	ret                                                  ; F80FDF  0e
; SoftKeyCol4_StepRecordPartSelect: the 4th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_StepRecordPartSelect slots 0x03,
;   0x14.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol4_StepRecordPartSelect:
	call SoftKeyCol4_TrackClear_StageZero                 ; F80FE0  1d 4a ed f7
	call T_StepRecordPartSelect_OpenStepRecord                                        ; F80FE4  1d bc 2b f4
	ret                                                  ; F80FE8  0e
; SoftKeyCol5_StepRecordPartSelect: the 5th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_StepRecordPartSelect slots 0x04,
;   0x15.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol5_StepRecordPartSelect:
	call SoftKeyCol5_TrackClear_StageZero                 ; F80FE9  1d 63 ed f7
	call T_StepRecordPartSelect_OpenStepRecord                                        ; F80FED  1d bc 2b f4
	ret                                                  ; F80FF1  0e
; SoftKeyCol6_StepRecordPartSelect: the 6th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_StepRecordPartSelect slots 0x05,
;   0x16.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol6_StepRecordPartSelect:
	call SoftKeyCol6_TrackClear_StageZero                 ; F80FF2  1d 7c ed f7
	call T_StepRecordPartSelect_OpenStepRecord                                        ; F80FF6  1d bc 2b f4
	ret                                                  ; F80FFA  0e
; SoftKeyCol7_StepRecordPartSelect: the 7th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_StepRecordPartSelect slots 0x06,
;   0x17.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol7_StepRecordPartSelect:
	call SoftKeyCol7_TrackClear_StageZero                 ; F80FFB  1d 95 ed f7
	call T_StepRecordPartSelect_OpenStepRecord                                        ; F80FFF  1d bc 2b f4
	ret                                                  ; F81003  0e
; SoftKeyCol8_StepRecordPartSelect: the 8th of the eight soft keys under the LCD; bit 7 of the code picks the
;   LOWER (set) or UPPER (clear) of the column's two switches; ButtonTable_StepRecordPartSelect slots 0x07,
;   0x18.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol8_StepRecordPartSelect:
	call SoftKeyCol8_TrackClear_StageZero                 ; F81004  1d ae ed f7
	call T_StepRecordPartSelect_OpenStepRecord                                        ; F81008  1d bc 2b f4
	ret                                                  ; F8100C  0e
; ButtonTable_StepRecordPartSelect_Nop8: a bare ret -- ButtonTable_StepRecordPartSelect slot 0x08.
ButtonTable_StepRecordPartSelect_Nop8:
	ret                                                  ; F8100D  0e
; ButtonTable_StepRecordPartSelect_Nop9: a bare ret -- ButtonTable_StepRecordPartSelect slots 0x09, 0x0A, 0x0B,
;   0x0C, 0x0D, 0x0E.
ButtonTable_StepRecordPartSelect_Nop9:
	ret                                                  ; F8100E  0e
; ExitKey_StepRecordPartSelect: the EXIT key; ButtonTable_StepRecordPartSelect slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_StepRecordPartSelect:
	bit 0x07,W                                           ; F8100F  c8 33 07
	jr nz, .LF8101C                                      ; F81012  6e 08
	ldw (UI_Request:16), 0x8004                              ; F81014  f1 70 20 02 04 80
	jr .LF8101C                                          ; F8101A  68 00
.LF8101C:
	ret                                                  ; F8101C  0e
; ButtonTable_StepRecordPartSelect_Nop16: a bare ret -- ButtonTable_StepRecordPartSelect slots 0x10, 0x19, 0x1A,
;   0x1B, 0x1C, 0x1D, 0x1E, 0x1F.
ButtonTable_StepRecordPartSelect_Nop16:
	ret                                                  ; F8101D  0e
; ScreenEnterBody_StepRecord: the body of STEP RECORD's +0 ENTER method -- restarts callback task 2,
;   and runs prom_b 0xF6A9CA (T_StepRecord_OnEnter) between LCD_ScreenRedraw_Begin / _End.
;   Screen 0x15's method has the same body; nothing requests screen 0x15 (prom_ab_step_record_screen_names.py).
ScreenEnterBody_StepRecord:
	call T_CallbackQueue_ResetAndRestartTask2            ; F8101E  1d 80 2e f4
	ldw (0x2666:16), 0xffff                              ; F81022  f1 66 26 02 ff ff
	ldw (0x266a:16), 0xffff                              ; F81028  f1 6a 26 02 ff ff
	calr PromB_LCD_ScreenRedraw_Begin                                          ; F8102E  1e a8 d2
	call T_StepRecord_OnEnter                                        ; F81031  1d c0 2e f4
	calr PromB_LCD_ScreenRedraw_End                                          ; F81035  1e af d2
	ret                                                  ; F81038  0e
; ScreenLeaveBody_StepRecord: the body of STEP RECORD's +4 LEAVE method -- runs prom_b 0xF6AE4B (T_StepRecord_OnLeave).
;   Screen 0x15's method has the same body; nothing requests screen 0x15 (prom_ab_step_record_screen_names.py).
ScreenLeaveBody_StepRecord:
	call T_StepRecord_OnLeave                                        ; F81039  1d c4 2e f4
	ld a, (UI_ScreenLatch:16)                                   ; F8103D  c1 7a 20 21
	cp	a, (UI_ScreenLatch_Previous:16)                               ; F81041  c1 7b 20 f1
	jr z, .LF81047                                       ; F81045  66 00
.LF81047:
	ret                                                  ; F81047  0e
; Paint_SequencerMedley -- paints the screen whose own text reads "SEQUENCER MEDLEY", "START", "FIRST S0NG    "
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 3 time(s); XIY = list start, XIX = list end.  2 of those 3 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF81098  interpreter A  list 0xF3C562  DL_SequencerMedleyStartFirstS0ng
;        text: "SEQUENCER MEDLEY"; "START"; "FIRST S0NG    "; "STOP"; "SKIP"; "LAST S0NG     "
;     site 0xF810A6  interpreter A  list 0xF3C721  DL_SelectIntFd
;        text: "SELECT"; "INT"; "FD"
; Evidence: the list address is the `ld XIY,0x00F3C562` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_SequencerMedley:
	call T_CallbackQueue_ResetAndRestartTask2            ; F81048  1d 80 2e f4
	cp	(UI_ScreenLatch_Previous:16), 0x13                            ; F8104C  c1 7b 20 3f 13
	jr z, .LF81073                                       ; F81051  66 20
	call T_Disk_PortA3_Release_Call_Call                                        ; F81053  1d 90 25 f4
	call T_SequencerMedley_SetSourceInternal                                        ; F81057  1d 18 2c f4
	cp	(Medley_Playing:16), 0x01                            ; F8105B  c1 c1 0d 3f 01
	jr z, .LF81065                                       ; F81060  66 03
	calr Blink_EnableThenStop_Copy                                          ; F81062  1e d2 e1
.LF81065:
	or	(0x2094:16), 0x40                            ; F81065  c1 94 20 3e 40
	and	(Medley_Playing:16), 0xfe                            ; F8106A  c1 c1 0d 3c fe
	call T_Medley_SelectField1                                        ; F8106F  1d 7c 2b f4
.LF81073:
	call T_SequencerMedley_InitOnEntry                                        ; F81073  1d cc 2b f4
	bit	4, (UI_ScreenFlags:16)                               ; F81077  f1 95 20 cc
	jr z, .LF81084                                       ; F8107B  66 07
	cp	(Medley_Source:16), 0x01                            ; F8107D  c1 0b 22 3f 01
	jr nz, .LF810AA                                      ; F81082  6e 26
.LF81084:
	cp	(UI_StatusCode:16), 0x04                            ; F81084  c1 80 28 3f 04
	jr ugt, .LF8108B                                     ; F81089  6b 00
.LF8108B:
	calr PromB_LCD_ScreenRedraw_Begin                                          ; F8108B  1e 4b d2
	ld XIY,DL_SequencerMedleyStartFirstS0ng              ; F8108E  45 62 c5 f3 00
	ld XIX,DL_F3C6B3                                     ; F81093  44 b3 c6 f3 00
	call T_DisplayList_Run                               ; F81098  1d f0 17 f4
	ld XIY,DL_SelectIntFd                                ; F8109C  45 21 c7 f3 00
	ld XIX,DL_FirstS0ngLastS0ng                          ; F810A1  44 78 c7 f3 00
	call T_DisplayList_Run                               ; F810A6  1d f0 17 f4
.LF810AA:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F810AA  f1 40 25 00 00
	ld a, (Medley_FirstSong:16)                                   ; F810AF  c1 08 22 21
	inc 1,A                                              ; F810B3  c9 61
	ld (DisplayListB_Stage+8:16), a                                   ; F810B5  f1 fe 12 41
	ld a, (Medley_LastSong:16)                                   ; F810B9  c1 09 22 21
	inc 1,A                                              ; F810BD  c9 61
	ld (DisplayListB_Stage+10:16), a                                   ; F810BF  f1 00 13 41
	ld a, (Medley_FileType:16)                                   ; F810C3  c1 35 0e 21
	ld (DisplayListB_Stage+14:16), a                                   ; F810C7  f1 04 13 41
	ld a, (Medley_Source:16)                                   ; F810CB  c1 0b 22 21
	ld (DisplayListB_Stage+13:16), a                                   ; F810CF  f1 03 13 41
	ld	a, (P1:8)                                      ; F810D3  c0 01 21
	ld (DisplayListB_Stage+15:16), a                                   ; F810D6  f1 05 13 41
	ld XIY,DL_FirstS0ngLastS0ng                          ; F810DA  45 78 c7 f3 00
	ld XIX,SequencerMedley_DrawPlayState_DL4                                     ; F810DF  44 ad c7 f3 00
	call T_DisplayListB_Run                              ; F810E4  1d f4 17 f4
	call SequencerMedley_DrawPlayState                                      ; F810E8  1d 50 13 f8
	calr PromB_LCD_ScreenRedraw_End                                          ; F810EC  1e f8 d1
	ret                                                  ; F810EF  0e
; ScreenLeaveBody_SequencerMedley -- the Leave method body of the SequencerMedley screen
; Evidence: prom_b ScreenLeave_SequencerMedley (0xF7D2A4) is `call 0xF810F0 / ret` (+4 of screen object 0xF43150).  Unless (0x207A)=0x13 it clears (0x2094) bit 6, which Paint_SequencerMedley sets; then call T_SequencerMedley_OnLeave (prom_b 0xF6614E).  Bytes after the `ret` are ButtonTable_SequencerMedley slot handlers.
ScreenLeaveBody_SequencerMedley:
	cp	(UI_ScreenLatch:16), 0x13                            ; F810F0  c1 7a 20 3f 13
	jr z, .LF810FC                                       ; F810F5  66 05
	and	(0x2094:16), 0xbf                            ; F810F7  c1 94 20 3c bf
.LF810FC:
	call T_SequencerMedley_OnLeave                                        ; F810FC  1d d0 2b f4
	ret                                                  ; F81100  0e
; ButtonTable_SequencerMedley_Nop0: a bare ret -- ButtonTable_SequencerMedley slot 0x00.
ButtonTable_SequencerMedley_Nop0:
	ret                                                  ; F81101  0e
; SoftKeyCol2_SequencerMedley: the 2nd of the eight soft keys under the LCD; bit 7 of the code picks the LOWER
;   (set) or UPPER (clear) of the column's two switches; ButtonTable_SequencerMedley slots 0x01, 0x12.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol2_SequencerMedley:
	cp	(Medley_Source:16), 0x00                            ; F81102  c1 0b 22 3f 00
	jr z, .LF8111D                                       ; F81107  66 14
	call T_Blink_Stop                                    ; F81109  1d 24 2e f4
	call T_SequencerMedley_SetSourceInternal                                        ; F8110D  1d 18 2c f4
	call Draw_FirstS0ngLastS0ng                                      ; F81111  1d bf 13 f8
	call SequencerMedley_DrawSourceBox                                      ; F81115  1d ff 13 f8
	call SequencerMedley_DrawFileTypeBox                                      ; F81119  1d 1c 14 f8
.LF8111D:
	ret                                                  ; F8111D  0e
; SoftKeyCol3_SequencerMedley: the 3rd of the eight soft keys under the LCD; bit 7 of the code picks the LOWER
;   (set) or UPPER (clear) of the column's two switches; ButtonTable_SequencerMedley slots 0x02, 0x13.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol3_SequencerMedley:
	cp	(Medley_Source:16), 0x01                            ; F8111E  c1 0b 22 3f 01
	jr z, .LF81135                                       ; F81123  66 10
	call T_Blink_Stop                                    ; F81125  1d 24 2e f4
	call T_SequencerMedley_SoftKeyCol3                                        ; F81129  1d 1c 2c f4
	call Draw_FirstS0ngLastS0ng                                      ; F8112D  1d bf 13 f8
	call SequencerMedley_DrawSourceBox                                      ; F81131  1d ff 13 f8
.LF81135:
	ret                                                  ; F81135  0e
; ButtonTable_SequencerMedley_Nop3: a bare ret -- ButtonTable_SequencerMedley slots 0x03, 0x14.
ButtonTable_SequencerMedley_Nop3:
	ret                                                  ; F81136  0e
; SoftKeyCol5_SequencerMedley: the 5th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER
;   (set) or UPPER (clear) of the column's two switches; ButtonTable_SequencerMedley slots 0x04, 0x15.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol5_SequencerMedley:
	bit	1, (UI_RequestBits:16)                               ; F81137  f1 75 20 c9
	jr z, .LF81141                                       ; F8113B  66 04
	call T_Blink_Stop                                    ; F8113D  1d 24 2e f4
.LF81141:
	bit 0x07,W                                           ; F81141  c8 33 07
	jr nz, .LF8114C                                      ; F81144  6e 06
	call T_SequencerMedley_StepFieldUp                                        ; F81146  1d 84 2b f4
	jr .LF81150                                          ; F8114A  68 04
.LF8114C:
	call T_SequencerMedley_StepFieldDown                                        ; F8114C  1d 88 2b f4
.LF81150:
	ld a, (Medley_FirstSong:16)                                   ; F81150  c1 08 22 21
	ld (DisplayListB_Stage+8:16), a                                   ; F81154  f1 fe 12 41
	ld a, (Medley_LastSong:16)                                   ; F81158  c1 09 22 21
	ld (DisplayListB_Stage+10:16), a                                   ; F8115C  f1 00 13 41
	call Draw_FirstS0ngLastS0ng                                      ; F81160  1d bf 13 f8
	ret                                                  ; F81164  0e
; ButtonTable_SequencerMedley_Nop5: a bare ret -- ButtonTable_SequencerMedley slot 0x05.
ButtonTable_SequencerMedley_Nop5:
	ret                                                  ; F81165  0e
; SoftKeyCol7_SequencerMedley: the 7th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER
;   (set) or UPPER (clear) of the column's two switches; ButtonTable_SequencerMedley slots 0x06, 0x17.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol7_SequencerMedley:
	cp	(Medley_Source:16), 0x01                            ; F81166  c1 0b 22 3f 01
	jr nz, .LF81184                                      ; F8116B  6e 17
	cp	(Medley_FileType:16), 0x01                            ; F8116D  c1 35 0e 3f 01
	jr z, .LF81184                                       ; F81172  66 10
	call T_Blink_Stop                                    ; F81174  1d 24 2e f4
	call T_SequencerMedley_SoftKeyCol7                                        ; F81178  1d 24 2c f4
	call Draw_FirstS0ngLastS0ng                                      ; F8117C  1d bf 13 f8
	call SequencerMedley_DrawFileTypeBox                                      ; F81180  1d 1c 14 f8
.LF81184:
	ret                                                  ; F81184  0e
; SoftKeyCol8_SequencerMedley: the 8th of the eight soft keys under the LCD; bit 7 of the code picks the LOWER
;   (set) or UPPER (clear) of the column's two switches; ButtonTable_SequencerMedley slots 0x07, 0x18.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
SoftKeyCol8_SequencerMedley:
	cp	(Medley_FileType:16), 0x00                            ; F81185  c1 35 0e 3f 00
	jr z, .LF8119C                                       ; F8118A  66 10
	call T_Blink_Stop                                    ; F8118C  1d 24 2e f4
	call T_SequencerMedley_SoftKeyCol8                                        ; F81190  1d 28 2c f4
	call Draw_FirstS0ngLastS0ng                                      ; F81194  1d bf 13 f8
	call SequencerMedley_DrawFileTypeBox                                      ; F81198  1d 1c 14 f8
.LF8119C:
	ret                                                  ; F8119C  0e
; ButtonTable_SequencerMedley_Nop8: a bare ret -- ButtonTable_SequencerMedley slot 0x08.
ButtonTable_SequencerMedley_Nop8:
	ret                                                  ; F8119D  0e
; LcdKeyRow2_SequencerMedley: row 2 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side
;   (set) or the CP1 side (clear); ButtonTable_SequencerMedley slot 0x09.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow2_SequencerMedley:
	bit 0x07,W                                           ; F8119E  c8 33 07
	jr nz, .LF811C8                                      ; F811A1  6e 25
	cp	(Medley_Playing:16), 0x01                            ; F811A3  c1 c1 0d 3f 01
	jr z, .LF811E1                                       ; F811A8  66 37
	calr Blink_DisableThenStop                                          ; F811AA  1e 98 e0
	call T_SequencerMedley_LcdKeyRow2                                        ; F811AD  1d d4 2b f4
	cp	(UI_ScreenId:16), 0x13                            ; F811B1  c1 7c 20 3f 13
	jr nz, .LF811E1                                      ; F811B6  6e 29
	cp	(Medley_Source:16), 0x00                            ; F811B8  c1 0b 22 3f 00
	jr nz, .LF811E1                                      ; F811BD  6e 22
	calr Draw_FirstS0ngLastS0ng                                          ; F811BF  1e fd 01
	call SequencerMedley_DrawPlayState                                      ; F811C2  1d 50 13 f8
	jr .LF811E1                                          ; F811C6  68 19
.LF811C8:
	cp	(Medley_Playing:16), 0x01                            ; F811C8  c1 c1 0d 3f 01
	jr z, .LF811E1                                       ; F811CD  66 12
	cp	(Medley_Field:16), 0x01                            ; F811CF  c1 0f 0c 3f 01
	jr z, .LF811E1                                       ; F811D4  66 0b
	calr Blink_EnableThenStop_Copy                                          ; F811D6  1e 5e e0
	call T_Medley_SelectField1                                        ; F811D9  1d 7c 2b f4
	call SequencerMedley_DrawFieldBox                                      ; F811DD  1d e7 13 f8
.LF811E1:
	ret                                                  ; F811E1  0e
; LcdKeyRow3_SequencerMedley: row 3 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side
;   (set) or the CP1 side (clear); ButtonTable_SequencerMedley slot 0x0A.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow3_SequencerMedley:
	bit 0x07,W                                           ; F811E2  c8 33 07
	jr nz, .LF811FE                                      ; F811E5  6e 17
	cp	(Medley_Playing:16), 0x01                            ; F811E7  c1 c1 0d 3f 01
	jr nz, .LF811FE                                      ; F811EC  6e 10
	bit	2, (TransportC_State:8)                                   ; F811EE  f0 95 ca
	jr z, .LF811FE                                       ; F811F1  66 0b
	calr Blink_EnableThenStop_Copy                                          ; F811F3  1e 41 e0
	call T_SequencerMedley_StopPlayback                                        ; F811F6  1d d8 2b f4
	call SequencerMedley_DrawPlayState                                      ; F811FA  1d 50 13 f8
.LF811FE:
	ret                                                  ; F811FE  0e
; LcdKeyRow4_SequencerMedley: row 4 of the five key pairs flanking the LCD; bit 7 of the code picks the CP2 side
;   (set) or the CP1 side (clear); ButtonTable_SequencerMedley slot 0x0B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
LcdKeyRow4_SequencerMedley:
	bit 0x07,W                                           ; F811FF  c8 33 07
	jr nz, .LF8120A                                      ; F81202  6e 06
	call T_SequencerMedley_LcdKeyRow4                                        ; F81204  1d 2c 2c f4
	jr .LF81223                                          ; F81208  68 19
.LF8120A:
	cp	(Medley_Playing:16), 0x01                            ; F8120A  c1 c1 0d 3f 01
	jr z, .LF81223                                       ; F8120F  66 12
	cp	(Medley_Field:16), 0x02                            ; F81211  c1 0f 0c 3f 02
	jr z, .LF81223                                       ; F81216  66 0b
	calr Blink_EnableThenStop_Copy                                          ; F81218  1e 1c e0
	call T_Medley_SelectField2                                        ; F8121B  1d 80 2b f4
	call SequencerMedley_DrawFieldBox                                      ; F8121F  1d e7 13 f8
.LF81223:
	ret                                                  ; F81223  0e
; ExitKey_SequencerMedley: the EXIT key; ButtonTable_SequencerMedley slot 0x0F.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
ExitKey_SequencerMedley:
	bit 0x07,W                                           ; F81224  c8 33 07
	jr nz, .LF8122F                                      ; F81227  6e 06
	ldw (UI_Request:16), 0x8004                              ; F81229  f1 70 20 02 04 80
.LF8122F:
	ret                                                  ; F8122F  0e
; ButtonTable_SequencerMedley_Nop12: a bare ret -- ButtonTable_SequencerMedley slots 0x0C, 0x0D, 0x0E, 0x10,
;   0x11, 0x16, 0x19, 0x1A.
ButtonTable_SequencerMedley_Nop12:
	ret                                                  ; F81230  0e
; NumberPadKey_SequencerMedley: the twelve-key number pad (0-9, +/-, ENTER); ButtonTable_SequencerMedley slot
;   0x1B.
; The slot -> control map is notes/wave7_panel_names_round11.py's CONTROL (variant 2).
NumberPadKey_SequencerMedley:
	calr SequencerMedley_NumberPad                                      ; F81231  1e 02 00
	ret                                                  ; F81234  0e
; ButtonTable_SequencerMedley_Nop28: a bare ret -- ButtonTable_SequencerMedley slots 0x1C, 0x1D, 0x1E, 0x1F.
ButtonTable_SequencerMedley_Nop28:
	ret                                                  ; F81235  0e
; SequencerMedley_NumberPad -- NUMBER PAD key on the SEQUENCER MEDLEY screen: dispatch on (0x2267)
; Evidence: reached only by `calr` at 0xF81231, slot 27 of ButtonTable_SequencerMedley; returns at once while (0x0DC1)=1 (set by the START arm through T_SequencerMedley_LcdKeyRow2); digit / 0x0F / 0x80 arms then SequencerMedley_BlinkSelectedField.
SequencerMedley_NumberPad:
	cp	(Medley_Playing:16), 0x01                            ; F81236  c1 c1 0d 3f 01
	jr z, .LF8125F                                       ; F8123B  66 22
	ld a, (0x2267:16)                                   ; F8123D  c1 67 22 21
	cp A,0x0f                                            ; F81241  c9 cf 0f
	jr z, .LF81257                                       ; F81244  66 11
	cp A,0x80                                            ; F81246  c9 cf 80
	jr z, .LF8125C                                       ; F81249  66 11
	cp A,0x09                                            ; F8124B  c9 cf 09
	jr ule, .LF81252                                     ; F8124E  63 02
	jr .LF8125F                                          ; F81250  68 0d
.LF81252:
	calr Blink_SetEnable_1_5                                      ; F81252  1e 0e 00
	jr .LF8125F                                          ; F81255  68 08
.LF81257:
	calr SequencerMedley_KeypadCommit                                      ; F81257  1e 13 00
	jr .LF8125F                                          ; F8125A  68 03
.LF8125C:
	calr SequencerMedley_KeypadSign                                      ; F8125C  1e ab 00
.LF8125F:
	calr SequencerMedley_BlinkSelectedField                                      ; F8125F  1e ae 00
	ret                                                  ; F81262  0e
Blink_SetEnable_1_5:
	pushw 0x01                                           ; F81263  0b 01 00
	call T_Blink_SetEnable                               ; F81266  1d 28 2e f4
	inc 2,XSP                                            ; F8126A  ef 62
	ret                                                  ; F8126C  0e
; SequencerMedley_KeypadCommit -- keypad code 0x0F: store the typed song number as FIRST or LAST medley song
; Evidence: T_AsciiDigits3_ToValue; upper bound 10 when (0x220B)=0, 20 when (0x0E35)=0, else 100; value-1 goes to (0x2208) for field (0x0C0F)=1 (raising (0x2209) to match) or (0x2209) for field 2 (lowering (0x2208)); when (0x2208) changed, T_F42580 with W=1 (moved down) or 0 (up).
; Then T_Blink_Stop and SequencerMedley_DrawFirstLastSong.
SequencerMedley_KeypadCommit:
	ld (0x2826:16), 0x03                                 ; F8126D  f1 26 28 00 03
	call T_AsciiDigits3_ToValue                          ; F81272  1d f0 32 f4
	cp wa, 0x01:i3                                         ; F81276  d8 d9
	jrl c, .LF81309                                      ; F81278  77 8e 00
	ldw hl, 0x0a                                         ; F8127B  33 0a 00
	cp	(Medley_Source:16), 0x00                            ; F8127E  c1 0b 22 3f 00
	jr z, .LF81292                                       ; F81283  66 0d
	ldw hl, 0x14                                         ; F81285  33 14 00
	cp	(Medley_FileType:16), 0x00                            ; F81288  c1 35 0e 3f 00
	jr z, .LF81292                                       ; F8128D  66 03
	ldw hl, 0x64                                         ; F8128F  33 64 00
.LF81292:
	cp WA,HL                                             ; F81292  db f0
	jr ugt, .LF81309                                     ; F81294  6b 73
	dec 1,WA                                             ; F81296  d8 69
	cp	(Medley_Field:16), 0x01                            ; F81298  c1 0f 0c 3f 01
	jr z, .LF812A8                                       ; F8129D  66 09
	cp	(Medley_Field:16), 0x02                            ; F8129F  c1 0f 0c 3f 02
	jr z, .LF812D8                                       ; F812A4  66 32
	jr .LF81309                                          ; F812A6  68 61
.LF812A8:
	ld c, (Medley_FirstSong:16)                                   ; F812A8  c1 08 22 23
	ld (Medley_FirstSong:16), a                                   ; F812AC  f1 08 22 41
	ld w, (Medley_LastSong:16)                                   ; F812B0  c1 09 22 20
	cp A,W                                               ; F812B4  c8 f1
	jr ule, .LF812BC                                     ; F812B6  63 04
	ld (Medley_LastSong:16), a                                   ; F812B8  f1 09 22 41
.LF812BC:
	cp	c, (Medley_FirstSong:16)                               ; F812BC  c1 08 22 f3
	jr z, .LF81302                                       ; F812C0  66 40
	cp (Medley_FirstSong:16), c                                    ; F812C2  c1 08 22 fb
	jr ugt, .LF812D0                                     ; F812C6  6b 08
	ld w, 0x01:opc                                          ; F812C8  20 01
	call T_F42580                                        ; F812CA  1d 80 25 f4
	jr .LF81302                                          ; F812CE  68 32
.LF812D0:
	ld w, 0x00:opc                                          ; F812D0  20 00
	call T_F42580                                        ; F812D2  1d 80 25 f4
	jr .LF81302                                          ; F812D6  68 2a
.LF812D8:
	ld c, (Medley_FirstSong:16)                                   ; F812D8  c1 08 22 23
	ld (Medley_LastSong:16), a                                   ; F812DC  f1 09 22 41
	cp C,A                                               ; F812E0  c9 f3
	jr ule, .LF81302                                     ; F812E2  63 1e
	ld (Medley_FirstSong:16), a                                   ; F812E4  f1 08 22 41
	cp	c, (Medley_FirstSong:16)                               ; F812E8  c1 08 22 f3
	jr z, .LF81302                                       ; F812EC  66 14
	cp (Medley_FirstSong:16), c                                    ; F812EE  c1 08 22 fb
	jr ugt, .LF812FC                                     ; F812F2  6b 08
	ld w, 0x01:opc                                          ; F812F4  20 01
	call T_F42580                                        ; F812F6  1d 80 25 f4
	jr .LF81302                                          ; F812FA  68 06
.LF812FC:
	ld w, 0x00:opc                                          ; F812FC  20 00
	call T_F42580                                        ; F812FE  1d 80 25 f4
.LF81302:
	call T_Blink_Stop                                    ; F81302  1d 24 2e f4
	calr Draw_FirstS0ngLastS0ng                                            ; F81306  1e b6 00
.LF81309:
	ret                                                  ; F81309  0e
; SequencerMedley_KeypadSign -- keypad code 0x80: put '+' back in (0x2820)
; Evidence: `ld (0x2820),0x2B / ret`; only caller is the 0x80 arm of SequencerMedley_NumberPad.
SequencerMedley_KeypadSign:
	ld (0x2820:16), 0x2b                                 ; F8130A  f1 20 28 00 2b
	ret                                                  ; F8130F  0e
; SequencerMedley_BlinkSelectedField -- start the field blink on the FIRST or LAST song field
; Evidence: unless (0x0DC1)=1, blink off or (0x2267)=0x0F: push BlinkArgPtrs_F81344[(0x0C0F)] (entry 1 = DL_FirstS0ngLastS0ng, the (0x12FE) record), call T_Blink_Command.
SequencerMedley_BlinkSelectedField:
	cp	(Medley_Playing:16), 0x01                            ; F81310  c1 c1 0d 3f 01
	jr z, .LF81343                                       ; F81315  66 2c
	bit	1, (UI_RequestBits:16)                               ; F81317  f1 75 20 c9
	jr z, .LF81343                                       ; F8131B  66 26
	cp	(0x2267:16), 0x0f                            ; F8131D  c1 67 22 3f 0f
	jr z, .LF81343                                       ; F81322  66 1f
	xor XWA,XWA                                          ; F81324  e8 d0
	ld a, (Medley_Field:16)                                   ; F81326  c1 0f 0c 21
	sla xwa, 0x02                                        ; F8132A  e8 ec 02
	ld (LCD_CurrentLayer:16), 0x00                                 ; F8132D  f1 40 25 00 00
	ld XIY,BlinkArgPtrs_F81344                           ; F81332  45 44 13 f8 00
	ld	xiy, (xiy+wa)                                ; F81337  e3 07 f4 e0 25
	push XIY                                             ; F8133C  3d
	call T_Blink_Command                                 ; F8133D  1d 20 2e f4
	inc 4,XSP                                            ; F81341  ef 64
.LF81343:
	ret                                                  ; F81343  0e
; ---------------------------------------------------------------------
; BlinkArgPtrs_F81344 -- 3 LE32 pointers, same idiom
;
; Read by: `ld XIY,0x00F81344 / ld XIY,(XIY+WA)` at 0xF81332-0xF8133B.
; Inputs:  WA = (0x0C0F) * 4.
; ENTRY COUNT 3: 0, 0x00F3C778, 0x00F3C782; word 3 is `ld (0x2540),0x00`.
;          ★ TWO INDEPENDENT LAST-ENTRY TESTS here, which the other four tables
;          do not have: 0xF81344 + 3*4 = 0xF81350, and 0xF81350 is separately a
;          `call` target from THREE converted sites -- 0xF810E8, 0xF811C2 and
;          0xF811FA.  A four-entry reading would put those calls two bytes inside
;          an instruction; that is exactly the offender row
;          notes/prom_a_linear_decode_check.py reported for this span.
; Evidence / Unknown: as BlinkArgPtrs_F8024D.
; ---------------------------------------------------------------------
BlinkArgPtrs_F81344:
	.long 0x00000000                                 ; F81344  [  0]
	.long DL_FirstS0ngLastS0ng                       ; F81348  [  1]
	.long 0x00f3c782                                 ; F8134C  [  2]
; SequencerMedley_DrawPlayState -- draw or erase the NOW PLAYING line and move the START/STOP box
; Evidence: (0x0DC1)!=1: site 0xF81366 runs SequencerMedley_DrawPlayState_DL1 (op 0E ClearColumns at 0x05CC, 0x21 x 0x10); (0x0DC1)=1: T_DLHandler_IX_Text on 0xF3C873 ('N0W PLAYING S0NG ') and 0xF3C888 (' :'), (0x12F6)=(0x220A)+1 drawn by site 0xF81392 (SequencerMedley_DrawPlayState_DL3, 3 digits), string record 0xF3C88E.
; Then layer 1: EraseRect record 0xF3C7D8 and FillRect record 0xF3C7AD on (0x1305)=(0x0DC1); box 1 (0x106,0x46)-(0x132,0x55) encloses 'START', box 0 (0x106,0x70)-(0x132,0x7F) 'STOP'.  (0x0DC1)=1 is set by T_SequencerMedley_LcdKeyRow2 (prom_b 0xF66191) and cleared by T_SequencerMedley_StopPlayback (0xF66201).
SequencerMedley_DrawPlayState:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F81350  f1 40 25 00 00
	cp	(Medley_Playing:16), 0x01                            ; F81355  c1 c1 0d 3f 01
	jr z, .LF8136C                                       ; F8135A  66 10
	ld XIY,SequencerMedley_DrawPlayState_DL1                                     ; F8135C  45 6b c8 f3 00
	ld XIX,SequencerMedley_DrawPlayState_DL2                                     ; F81361  44 73 c8 f3 00
	call T_DisplayList_Run                               ; F81366  1d f0 17 f4
	jr .LF8139F                                          ; F8136A  68 33
.LF8136C:
	ld XIY,SequencerMedley_DrawPlayState_DL2                                     ; F8136C  45 73 c8 f3 00
	call T_DLHandler_IX_Text                             ; F81371  1d 2c 18 f4
	ld XIY,0x00f3c888                                    ; F81375  45 88 c8 f3 00
	call T_DLHandler_IX_Text                             ; F8137A  1d 2c 18 f4
	ld a, (Medley_PlayingSong:16)                                   ; F8137E  c1 0a 22 21
	inc 1,A                                              ; F81382  c9 61
	ld (DisplayListB_Stage:16), a                                   ; F81384  f1 f6 12 41
	ld XIY,SequencerMedley_DrawPlayState_DL3                                     ; F81388  45 9d c8 f3 00
	ld XIX,DL_StepRecordPartSelectPressTheUpDownButton   ; F8138D  44 a7 c8 f3 00
	call T_DisplayListB_Run                              ; F81392  1d f4 17 f4
	ld XIY,0x00f3c88e                                    ; F81396  45 8e c8 f3 00
	call T_DLB_Handler_StringTable                       ; F8139B  1d f8 17 f4
.LF8139F:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F8139F  f1 40 25 00 01
	ld a, (Medley_Playing:16)                                   ; F813A4  c1 c1 0d 21
	ld (DisplayListB_Stage+15:16), a                                   ; F813A8  f1 05 13 41
	ld XIY,0x00f3c7d8                                    ; F813AC  45 d8 c7 f3 00
	call T_DLB_Handler_Array8_2                                        ; F813B1  1d 20 18 f4
	ld XIY,SequencerMedley_DrawPlayState_DL4                                     ; F813B5  45 ad c7 f3 00
	call T_DLB_Handler_Array8                                        ; F813BA  1d 1c 18 f4
	ret                                                  ; F813BE  0e
Draw_FirstS0ngLastS0ng:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F813BF  f1 40 25 00 00
	ld a, (Medley_FirstSong:16)                                   ; F813C4  c1 08 22 21
	inc 1,A                                              ; F813C8  c9 61
	ld (DisplayListB_Stage+8:16), a                                   ; F813CA  f1 fe 12 41
	ld a, (Medley_LastSong:16)                                   ; F813CE  c1 09 22 21
	inc 1,A                                              ; F813D2  c9 61
	ld (DisplayListB_Stage+10:16), a                                   ; F813D4  f1 00 13 41
	ld XIY,DL_FirstS0ngLastS0ng                          ; F813D8  45 78 c7 f3 00
	ld XIX,0x00f3c78c                                    ; F813DD  44 8c c7 f3 00
	call T_DisplayListB_Run                              ; F813E2  1d f4 17 f4
	ret                                                  ; F813E6  0e
; SequencerMedley_DrawFieldBox -- move the layer-1 highlight to the FIRST or LAST song field
; Evidence: (0x2540)=1; T_F41820 on record 0xF3C7B8 (swi 0x1B LCD_Svc_1B_EraseRect, array 0xF3C833) then T_F4181C on 0xF3C78C (swi 5 FillRect, Data_F3C7E3), both indexed by (0x1302); entries 1/2 are the FIRST S0NG box (0x0B,0x43)-(0xC2,0x62) and the LAST S0NG box (0x0B,0x8F)-(0xC2,0xAE), in opposite order in the two arrays.
; (0x1302)=(0x0C0F) is written by T_Medley_SelectField1 / T_Medley_SelectField2 (prom_b 0xF66246 / 0xF66251) just before both calls.
SequencerMedley_DrawFieldBox:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F813E7  f1 40 25 00 01
	ld XIY,0x00f3c7b8                                    ; F813EC  45 b8 c7 f3 00
	call T_DLB_Handler_Array8_2                                        ; F813F1  1d 20 18 f4
	ld XIY,0x00f3c78c                                    ; F813F5  45 8c c7 f3 00
	call T_DLB_Handler_Array8                                        ; F813FA  1d 1c 18 f4
	ret                                                  ; F813FE  0e
; SequencerMedley_DrawSourceBox -- highlight the selected medley source, INT / FD / HD
; Evidence: (0x2540)=1; site 0xF8140E runs SequencerMedley_DrawSourceBox_DL, one op-1B record = svc 0x1B EraseRect over (0x24,0xD4)-(0x98,0xE4), the span of the three SELECT boxes of DL_F3C6B3 / DL_SelectIntFd; then T_F4181C on 0xF3C797: FillRect of entry (0x1303) of Data_F3C7E3+0x18 = (0x24..0x44) INT, (0x4D..0x6D) FD, (0x78..0x98) HD.
; (0x1303) is loaded from (0x220B) (Paint_SequencerMedley 0xF810CB).
SequencerMedley_DrawSourceBox:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F813FF  f1 40 25 00 01
	ld XIY,SequencerMedley_DrawSourceBox_DL                                     ; F81404  45 c3 c7 f3 00
	ld XIX,SequencerMedley_DrawFileTypeBox_DL                                     ; F81409  44 cd c7 f3 00
	call T_DisplayList_Run                               ; F8140E  1d f0 17 f4
	ld XIY,0x00f3c797                                    ; F81412  45 97 c7 f3 00
	call T_DLB_Handler_Array8                                        ; F81417  1d 1c 18 f4
	ret                                                  ; F8141B  0e
; SequencerMedley_DrawFileTypeBox -- highlight NORM FILE or MIDI FILE
; Evidence: (0x2540)=1; EraseRect record 0xF3C7CD (array 0xF3C84B) then FillRect record 0xF3C7A2 (array 0xF3C813), both on (0x1304); value 0 fills (0x11C,0xCE)-(0x13D,0xE7) around 'NORM'/'FILE', value 1 fills (0xF3,0xCE)-(0x113,0xE7) around 'MIDI'/'FILE' (DL_SequencerMedleyStartFirstS0ng).  (0x1304) is loaded from (0x0E35).
SequencerMedley_DrawFileTypeBox:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F8141C  f1 40 25 00 01
	ld XIY,SequencerMedley_DrawFileTypeBox_DL                                     ; F81421  45 cd c7 f3 00
	call T_DLB_Handler_Array8_2                                        ; F81426  1d 20 18 f4
	ld XIY,0x00f3c7a2                                    ; F8142A  45 a2 c7 f3 00
	call T_DLB_Handler_Array8                                        ; F8142F  1d 1c 18 f4
	ret                                                  ; F81433  0e
; S0ngSelectName_PrevSong -- SONG '<': save the current song, step (0x360A) down and load that song
; Evidence: SoftKeyCol1 arm of ScreenButtonBody_S0ngSelectName.  Unless (0x0E45)!=0 or (0x360A)=0: site 0xF81453 erases both boxes (DL_F3C367-DLTable_F3C37D, svc 0x1B), S0ngSelectName_SaveWorkspaceToBank, dec (0x360A), (0x12FC)=song+1, S0ngSelectName_LoadSongFromBank, (0x0E45)=4, S0ngSelectName_UpdateSizeValues, (0x2095),0x10.
; The 0 bound at 0xF8143F is the one FINDINGS-memory-map.md cites for the ten song banks.
S0ngSelectName_PrevSong:
	cp	(0x0e45:16), 0x00                            ; F81434  c1 45 0e 3f 00
	jr nz, .LF8147C                                      ; F81439  6e 41
	ld a, (BStore_CurrentBank:16)                                   ; F8143B  c1 0a 36 21
	cp a, 0x00:i3                                          ; F8143F  c9 d8
	jr z, .LF8147C                                       ; F81441  66 39
	pushw wa                                             ; F81443  28
	ld (LCD_CurrentLayer:16), 0x01                                 ; F81444  f1 40 25 00 01
	ld XIY,DL_F3C367                                     ; F81449  45 67 c3 f3 00
	ld XIX,DLTable_F3C37D                                ; F8144E  44 7d c3 f3 00
	call T_DisplayListB_Run                              ; F81453  1d f4 17 f4
	popw wa                                              ; F81457  48
	push XWA                                             ; F81458  38
	call S0ngSelectName_SaveWorkspaceToBank                                      ; F81459  1d 9a 14 f8
	pop XWA                                              ; F8145D  58
	dec 1,A                                              ; F8145E  c9 69
	ld (BStore_CurrentBank:16), a                                   ; F81460  f1 0a 36 41
	inc 1,A                                              ; F81464  c9 61
	ld (DisplayListB_Stage+6:16), a                                   ; F81466  f1 fc 12 41
	call S0ngSelectName_LoadSongFromBank                                      ; F8146A  1d 0d 18 f8
	ld (0x0e45:16), 0x04                                 ; F8146E  f1 45 0e 00 04
	call S0ngSelectName_UpdateSizeValues                                      ; F81473  1d 7d 14 f8
	or	(UI_ScreenFlags:16), 0x10                            ; F81477  c1 95 20 3e 10
.LF8147C:
	ret                                                  ; F8147C  0e
; S0ngSelectName_UpdateSizeValues -- compute the selected song's size and copy it to the display variables
; Evidence: (0x0E32)=(0x360A); SongStore_MeasureSongSize; (0x12FD)=(0x0E2F) and (0x12FF)=(0x0E31), the variables S0ngSelectName_DrawValues shows beside ' KB' and '%'.
S0ngSelectName_UpdateSizeValues:
	ld a, (BStore_CurrentBank:16)                                   ; F8147D  c1 0a 36 21
	ld (0x0e32:16), a                                   ; F81481  f1 32 0e 41
	call SongStore_MeasureSongSize                                      ; F81485  1d e9 19 f8
	ld wa, (0x0e2f:16)                                 ; F81489  d1 2f 0e 20
	ld (DisplayListB_Stage+7:16), wa                                  ; F8148D  f1 fd 12 50
	ld a, (0x0e31:16)                                   ; F81491  c1 31 0e 21
	ld (DisplayListB_Stage+9:16), a                                   ; F81495  f1 ff 12 41
	ret                                                  ; F81499  0e
; S0ngSelectName_SaveWorkspaceToBank -- copy the 3 KiB song workspace back into its bank (0x360A)
; Evidence: (0x60341E)=(0x360C); `ld XIX,0x610000+n*0xC00 / ld XIY,0x603400 / ld BC,0x0C00 / ldir` (ldir writes (XIX+) from (XIY+)).  Same effect as prom_b BStore_Workspace_SaveToBank (0xF64BE3), written independently (instruction order differs).
S0ngSelectName_SaveWorkspaceToBank:
	ld xwa, (0x360c:16)                                 ; F8149A  e1 0c 36 20
	ld (0x60341e:24), xwa                               ; F8149E  f2 1e 34 60 60
	xor XWA,XWA                                          ; F814A3  e8 d0
	ld XIX,0x00610000                                    ; F814A5  44 00 00 61 00
	xor XHL,XHL                                          ; F814AA  eb d3
	ld l, (BStore_CurrentBank:16)                                   ; F814AC  c1 0a 36 27
	ld A,L                                               ; F814B0  cf 89
	sla xhl, 0x0b                                        ; F814B2  eb ec 0b
	sla xwa, 0x0a                                        ; F814B5  e8 ec 0a
	add XHL,XWA                                          ; F814B8  e8 83
	add XIX,XHL                                          ; F814BA  eb 84
	ld XIY,0x00603400                                    ; F814BC  45 00 34 60 00
	ldw bc, 0x0c00                                       ; F814C1  31 00 0c
	ldir85                                               ; F814C4  85 11
	ret                                                  ; F814C6  0e
; S0ngSelectName_NextSong -- SONG '>': save the current song, step (0x360A) up and load that song
; Evidence: SoftKeyCol2 arm of ScreenButtonBody_S0ngSelectName; identical to S0ngSelectName_PrevSong except `cp A,0x09` (0xF814D2) and `inc` -- site 0xF814E7 erases both boxes on layer 1 first.
S0ngSelectName_NextSong:
	cp	(0x0e45:16), 0x00                            ; F814C7  c1 45 0e 3f 00
	jr nz, .LF81510                                      ; F814CC  6e 42
	ld a, (BStore_CurrentBank:16)                                   ; F814CE  c1 0a 36 21
	cp A,0x09                                            ; F814D2  c9 cf 09
	jr z, .LF81510                                       ; F814D5  66 39
	pushw wa                                             ; F814D7  28
	ld (LCD_CurrentLayer:16), 0x01                                 ; F814D8  f1 40 25 00 01
	ld XIY,DL_F3C367                                     ; F814DD  45 67 c3 f3 00
	ld XIX,DLTable_F3C37D                                ; F814E2  44 7d c3 f3 00
	call T_DisplayListB_Run                              ; F814E7  1d f4 17 f4
	popw wa                                              ; F814EB  48
	pushw wa                                             ; F814EC  28
	call S0ngSelectName_SaveWorkspaceToBank                                      ; F814ED  1d 9a 14 f8
	popw wa                                              ; F814F1  48
	inc 1,A                                              ; F814F2  c9 61
	ld (BStore_CurrentBank:16), a                                   ; F814F4  f1 0a 36 41
	inc 1,A                                              ; F814F8  c9 61
	ld (DisplayListB_Stage+6:16), a                                   ; F814FA  f1 fc 12 41
	call S0ngSelectName_LoadSongFromBank                                      ; F814FE  1d 0d 18 f8
	ld (0x0e45:16), 0x04                                 ; F81502  f1 45 0e 00 04
	call S0ngSelectName_UpdateSizeValues                                      ; F81507  1d 7d 14 f8
	or	(UI_ScreenFlags:16), 0x10                            ; F8150B  c1 95 20 3e 10
.LF81510:
	ret                                                  ; F81510  0e
	ret                                                  ; F81511  0e
; S0ngSelectName_CursorLeft -- POSITION '<': move the name-edit cursor one character left
; Evidence: SoftKeyCol4 arm.  (0x2075),9; site 0xF8152C erases the position and character boxes (DL_F3C367-DLTable_F3C37D, svc 0x1B); (0x222D)-1 if >=0 into (0x222D)/(0x2721)/(0x1301); SongName_CharIndexAtCursor; (0x1302)=(0x21F9); fills both boxes again (records DL_F3C351/0xF3C35C, svc 5).
S0ngSelectName_CursorLeft:
	or	(UI_RequestBits:16), 0x09                            ; F81512  c1 75 20 3e 09
	ldw (PanelDial_DownButton:16), 0x0605                              ; F81517  f1 9b 20 02 05 06
	ld (LCD_CurrentLayer:16), 0x01                                 ; F8151D  f1 40 25 00 01
	ld XIY,DL_F3C367                                     ; F81522  45 67 c3 f3 00
	ld XIX,DLTable_F3C37D                                ; F81527  44 7d c3 f3 00
	call T_DisplayListB_Run                              ; F8152C  1d f4 17 f4
	ld a, (NameEdit_CursorPos:16)                                   ; F81530  c1 2d 22 21
	dec 1,A                                              ; F81534  c9 69
	cp a, 0x00:i3                                          ; F81536  c9 d8
	jr lt, .LF81552                                      ; F81538  61 18
	ld (NameEdit_CursorPos:16), a                                   ; F8153A  f1 2d 22 41
	ld (0x2721:16), a                                   ; F8153E  f1 21 27 41
	ld (DisplayListB_Stage+11:16), a                                   ; F81542  f1 01 13 41
	call SongName_CharIndexAtCursor                                      ; F81546  1d 88 16 f8
	ld a, (NameEdit_CharIndex:16)                                   ; F8154A  c1 f9 21 21
	ld (DisplayListB_Stage+12:16), a                                   ; F8154E  f1 02 13 41
.LF81552:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F81552  f1 40 25 00 01
	ld XIY,DL_F3C351                                     ; F81557  45 51 c3 f3 00
	ld XIX,0x00f3c35c                                    ; F8155C  44 5c c3 f3 00
	call T_DLB_Handler_Array8                                        ; F81561  1d 1c 18 f4
	ld XIY,0x00f3c35c                                    ; F81565  45 5c c3 f3 00
	ld XIX,DL_F3C367                                     ; F8156A  44 67 c3 f3 00
	call T_DLB_Handler_Array8                                        ; F8156F  1d 1c 18 f4
	ret                                                  ; F81573  0e
; S0ngSelectName_CursorRight -- POSITION '>': move the name-edit cursor one character right
; Evidence: SoftKeyCol5 arm; as S0ngSelectName_CursorLeft with `inc` and `cp A,5 / jr gt` (six positions); site 0xF8158E is the erase.
S0ngSelectName_CursorRight:
	or	(UI_RequestBits:16), 0x09                            ; F81574  c1 75 20 3e 09
	ldw (PanelDial_DownButton:16), 0x0605                              ; F81579  f1 9b 20 02 05 06
	ld (LCD_CurrentLayer:16), 0x01                                 ; F8157F  f1 40 25 00 01
	ld XIY,DL_F3C367                                     ; F81584  45 67 c3 f3 00
	ld XIX,DLTable_F3C37D                                ; F81589  44 7d c3 f3 00
	call T_DisplayListB_Run                              ; F8158E  1d f4 17 f4
	ld a, (NameEdit_CursorPos:16)                                   ; F81592  c1 2d 22 21
	inc 1,A                                              ; F81596  c9 61
	cp a, 0x05:i3                                          ; F81598  c9 dd
	jr gt, .LF815B4                                      ; F8159A  6a 18
	ld (NameEdit_CursorPos:16), a                                   ; F8159C  f1 2d 22 41
	ld (0x2721:16), a                                   ; F815A0  f1 21 27 41
	ld (DisplayListB_Stage+11:16), a                                   ; F815A4  f1 01 13 41
	call SongName_CharIndexAtCursor                                      ; F815A8  1d 88 16 f8
	ld a, (NameEdit_CharIndex:16)                                   ; F815AC  c1 f9 21 21
	ld (DisplayListB_Stage+12:16), a                                   ; F815B0  f1 02 13 41
.LF815B4:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F815B4  f1 40 25 00 01
	ld XIY,DL_F3C351                                     ; F815B9  45 51 c3 f3 00
	ld XIX,0x00f3c35c                                    ; F815BE  44 5c c3 f3 00
	call T_DLB_Handler_Array8                                        ; F815C3  1d 1c 18 f4
	ld XIY,0x00f3c35c                                    ; F815C7  45 5c c3 f3 00
	ld XIX,DL_F3C367                                     ; F815CC  44 67 c3 f3 00
	call T_DLB_Handler_Array8                                        ; F815D1  1d 1c 18 f4
	ret                                                  ; F815D5  0e
; S0ngSelectName_CharPrev -- character '<': replace the character under the cursor with the previous one of CharSet_F81768
; Evidence: SoftKeyCol6 arm; erases the character box (record 0xF3C372), SongName_StepCharAtCursor with W=0x81, (0x1302)=(0x21F9), SongName_Draw6Chars on layer 0, fills the box (0xF3C35C).
S0ngSelectName_CharPrev:
	or	(UI_RequestBits:16), 0x09                            ; F815D6  c1 75 20 3e 09
	ldw (PanelDial_DownButton:16), 0x0605                              ; F815DB  f1 9b 20 02 05 06
	ld (LCD_CurrentLayer:16), 0x01                                 ; F815E1  f1 40 25 00 01
	ld XIY,0x00f3c372                                    ; F815E6  45 72 c3 f3 00
	call T_DLB_Handler_Array8_2                                        ; F815EB  1d 20 18 f4
	ld w, 0x81:opc                                          ; F815EF  20 81
	call SongName_StepCharAtCursor                                      ; F815F1  1d da 16 f8
	ld a, (NameEdit_CharIndex:16)                                   ; F815F5  c1 f9 21 21
	ld (DisplayListB_Stage+12:16), a                                   ; F815F9  f1 02 13 41
	ld (LCD_CurrentLayer:16), 0x00                                 ; F815FD  f1 40 25 00 00
	call SongName_Draw6Chars                                      ; F81602  1d 5e 16 f8
	ld (LCD_CurrentLayer:16), 0x01                                 ; F81606  f1 40 25 00 01
	ld XIY,0x00f3c35c                                    ; F8160B  45 5c c3 f3 00
	ld XIX,DL_F3C367                                     ; F81610  44 67 c3 f3 00
	call T_DLB_Handler_Array8                                        ; F81615  1d 1c 18 f4
	ret                                                  ; F81619  0e
; S0ngSelectName_CharNext -- character '>': replace the character under the cursor with the next one of CharSet_F81768
; Evidence: SoftKeyCol7 arm; as S0ngSelectName_CharPrev with W=0x01.
S0ngSelectName_CharNext:
	or	(UI_RequestBits:16), 0x09                            ; F8161A  c1 75 20 3e 09
	ldw (PanelDial_DownButton:16), 0x0605                              ; F8161F  f1 9b 20 02 05 06
	ld (LCD_CurrentLayer:16), 0x01                                 ; F81625  f1 40 25 00 01
	ld XIY,0x00f3c372                                    ; F8162A  45 72 c3 f3 00
	call T_DLB_Handler_Array8_2                                        ; F8162F  1d 20 18 f4
	ld w, 0x01:opc                                          ; F81633  20 01
	call SongName_StepCharAtCursor                                      ; F81635  1d da 16 f8
	ld a, (NameEdit_CharIndex:16)                                   ; F81639  c1 f9 21 21
	ld (DisplayListB_Stage+12:16), a                                   ; F8163D  f1 02 13 41
	ld (LCD_CurrentLayer:16), 0x00                                 ; F81641  f1 40 25 00 00
	call SongName_Draw6Chars                                      ; F81646  1d 5e 16 f8
	ld (LCD_CurrentLayer:16), 0x01                                 ; F8164A  f1 40 25 00 01
	ld XIY,0x00f3c35c                                    ; F8164F  45 5c c3 f3 00
	ld XIX,DL_F3C367                                     ; F81654  44 67 c3 f3 00
	call T_DLB_Handler_Array8                                        ; F81659  1d 1c 18 f4
	ret                                                  ; F8165D  0e
; ---------------------------------------------------------------------
; SongName_Draw6Chars -- draw the six-character name buffer at 0x6034CA
;
; Called from: prom_a Paint_S0ngSelectName (`call`) at 0xF80E71
;          prom_a S0ngSelectName_CharPrev (`call`) at 0xF81602
;          prom_a S0ngSelectName_CharNext (`call`) at 0xF81646
; Issues:  SWI7 service 0x08 at 0xF8166E -- LCD_Svc_08_DrawText16x16, draw 16x16 text
; Evidence: `ld HL,0x0000` + `ld BC,0x0006` + `ld XIY,0x006034CA` + `ld IX,0x0998` +
;           service 0x08, the 16x16 text service, so it draws six characters from that
;           buffer at screen offset 0x998.  The buffer is six bytes wide because
;           SongName_ResetToUnderscores fills it with the six ROM bytes at 0xF81948,
;           which are `5F 5F 5F 5F 5F 5F` = `______`, and the 37 characters that can
;           stand in it are CharSet_F81768 = `_` + `A`-`Z` + `0`-`9`.  `Song` is the
;           ROM's own word: this routine's caller at 0xF80E71 is Paint_S0ngSelectName.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
SongName_Draw6Chars:
	ldw hl, 0x00                                         ; F8165E  33 00 00
	ldw bc, 0x06                                         ; F81661  31 06 00
	ld XIY,BStore_SongName                                    ; F81664  45 ca 34 60 00
	ldw ix, 0x0998                                       ; F81669  34 98 09
	ld a, 0x08:opc                                          ; F8166C  21 08
	swi 7                                                ; F8166E  ff
	ret                                                  ; F8166F  0e
; S0ngSelectName_ClearName -- CLR: blank the song name to '______'
; Evidence: SoftKeyCol8 arm ('CLR' in DL_S0ngSelectNameKbS0ngName); (0x2540)=1, site 0xF8167F erases the position box (DL_F3C367-0xF3C372, svc 0x1B), then SongName_ResetToUnderscores (which zeroes cursor and character index and sets (0x2071) bit 4).
S0ngSelectName_ClearName:
	ld (LCD_CurrentLayer:16), 0x01                                 ; F81670  f1 40 25 00 01
	ld XIY,DL_F3C367                                     ; F81675  45 67 c3 f3 00
	ld XIX,0x00f3c372                                    ; F8167A  44 72 c3 f3 00
	call T_DisplayListB_Run                              ; F8167F  1d f4 17 f4
	call SongName_ResetToUnderscores                                      ; F81683  1d ea 18 f8
	ret                                                  ; F81687  0e
; SongName_CharIndexAtCursor -- (0x21F9) = index in CharSet_F81768 of the name character under the cursor (0 if absent)
; Evidence: reads the byte at 0x610000+(0x360A)*0xC00+0xCA+(0x222D) (the bank copy of the name), then compares it with each of the 37 bytes of CharSet_F81768 (`ld BC,0x25` / djnz; 0xF816C0 loads 0xF81768, '_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'); returns at once when (0x222D) is negative.
; Called from: S0ngSelectName_CursorLeft/Right, S0ngSelectName_PrepareValues, S0ngSelectName_LoadSongFromBank.
SongName_CharIndexAtCursor:
	ld l, (NameEdit_CursorPos:16)                                   ; F81688  c1 2d 22 27
	cp l, 0x00:i3                                          ; F8168C  cf d8
	jr lt, .LF816D9                                      ; F8168E  61 49
	xor H,H                                              ; F81690  ce d6
	sub L,0x00                                           ; F81692  cf ca 00
	ld XIX,0x00610000                                    ; F81695  44 00 00 61 00
	push XBC                                             ; F8169A  39
	xor XBC,XBC                                          ; F8169B  e9 d1
	xor XDE,XDE                                          ; F8169D  ea d2
	ld e, (BStore_CurrentBank:16)                                   ; F8169F  c1 0a 36 25
	ld C,E                                               ; F816A3  cd 8b
	sla xde, 0x0b                                        ; F816A5  ea ec 0b
	sla xbc, 0x0a                                        ; F816A8  e9 ec 0a
	add XDE,XBC                                          ; F816AB  e9 82
	pop XBC                                              ; F816AD  59
	add XIX,XDE                                          ; F816AE  ea 84
	add XIX,0x000000ca                                   ; F816B0  ec c8 ca 00 00 00
	ld	w, (xix+hl)                                  ; F816B6  c3 07 f0 ec 20
	xor HL,HL                                            ; F816BB  db d3
	ldw bc, 0x25                                         ; F816BD  31 25 00
	ld XIX,CharSet_F81768                                ; F816C0  44 68 17 f8 00
.LF816C5:
	ld	a, (xix+hl)                                  ; F816C5  c3 07 f0 ec 21
	cp W,A                                               ; F816CA  c9 f0
	jr z, .LF816D5                                       ; F816CC  66 07
	inc 1,HL                                             ; F816CE  db 61
	djnz16 bc, .LF816C5                                  ; F816D0  d9 1c f2
	ld l, 0x00:opc                                          ; F816D3  27 00
.LF816D5:
	ld (NameEdit_CharIndex:16), l                                   ; F816D5  f1 f9 21 47
.LF816D9:
	ret                                                  ; F816D9  0e
; SongName_StepCharAtCursor -- step the character under the name cursor: W bit 7 clear = next, set = previous
; Evidence: `bit 7,W` chooses SongName_NextCharAtCursor or SongName_PrevCharAtCursor; callers pass W=0x01 (S0ngSelectName_CharNext) and 0x81 (S0ngSelectName_CharPrev).
SongName_StepCharAtCursor:
	bit 0x07,W                                           ; F816DA  c8 33 07
	jr nz, .LF816E5                                      ; F816DD  6e 06
	call SongName_NextCharAtCursor                                      ; F816DF  1d ea 16 f8
	jr .LF816E9                                          ; F816E3  68 04
.LF816E5:
	call SongName_PrevCharAtCursor                                      ; F816E5  1d 00 17 f8
.LF816E9:
	ret                                                  ; F816E9  0e
; SongName_NextCharAtCursor -- (0x21F9)+1, clamped to 0x24 (the last of 37), then store it
; Evidence: `inc 1,A / cp A,0x25 / jr lt / ld A,0x24`, then SongName_StoreCharAtCursor.
SongName_NextCharAtCursor:
	ld a, (NameEdit_CharIndex:16)                                   ; F816EA  c1 f9 21 21
	inc 1,A                                              ; F816EE  c9 61
	cp A,0x25                                            ; F816F0  c9 cf 25
	jr lt, .LF816F7                                      ; F816F3  61 02
	ld a, 0x24:opc                                          ; F816F5  21 24
.LF816F7:
	ld (NameEdit_CharIndex:16), a                                   ; F816F7  f1 f9 21 41
	call SongName_StoreCharAtCursor                                      ; F816FB  1d 16 17 f8
	ret                                                  ; F816FF  0e
; SongName_PrevCharAtCursor -- (0x21F9)-1, clamped at 0, then store it
; Evidence: `dec 1,A / cp A,0xFF / jr nz / ld A,0`, then SongName_StoreCharAtCursor.
SongName_PrevCharAtCursor:
	ld a, (NameEdit_CharIndex:16)                                   ; F81700  c1 f9 21 21
	dec 1,A                                              ; F81704  c9 69
	cp A,0xff                                            ; F81706  c9 cf ff
	jr nz, .LF8170D                                      ; F81709  6e 02
	ld a, 0x00:opc                                          ; F8170B  21 00
.LF8170D:
	ld (NameEdit_CharIndex:16), a                                   ; F8170D  f1 f9 21 41
	call SongName_StoreCharAtCursor                                      ; F81711  1d 16 17 f8
	ret                                                  ; F81715  0e
; SongName_StoreCharAtCursor -- write CharSet_F81768[(0x21F9)] at position (0x222D) of all three copies of the song name
; Evidence: 0xF8171C loads CharSet_F81768 ('_ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789') and reads entry (0x21F9); the byte is stored at (XIX+HL), HL=(0x222D), for XIX = 0x610000+(0x360A)*0xC00+0xCA (bank), 0x6034CA (workspace) and 0x12F6 (display) -- the same three copies SongName_ResetToUnderscores writes.
; Called from: SongName_NextCharAtCursor, SongName_PrevCharAtCursor.
SongName_StoreCharAtCursor:
	ld l, (NameEdit_CharIndex:16)                                   ; F81716  c1 f9 21 27
	xor H,H                                              ; F8171A  ce d6
	ld XIX,CharSet_F81768                                ; F8171C  44 68 17 f8 00
	ld	a, (xix+hl)                                  ; F81721  c3 07 f0 ec 21
	ld l, (NameEdit_CursorPos:16)                                   ; F81726  c1 2d 22 27
	sub L,0x00                                           ; F8172A  cf ca 00
	ld XIX,0x00610000                                    ; F8172D  44 00 00 61 00
	push XBC                                             ; F81732  39
	xor XBC,XBC                                          ; F81733  e9 d1
	xor XDE,XDE                                          ; F81735  ea d2
	ld e, (BStore_CurrentBank:16)                                   ; F81737  c1 0a 36 25
	ld C,E                                               ; F8173B  cd 8b
	sla xde, 0x0b                                        ; F8173D  ea ec 0b
	sla xbc, 0x0a                                        ; F81740  e9 ec 0a
	add XDE,XBC                                          ; F81743  e9 82
	pop XBC                                              ; F81745  59
	add XIX,XDE                                          ; F81746  ea 84
	add XIX,0x000000ca                                   ; F81748  ec c8 ca 00 00 00
	ld	(xix+hl), a                                  ; F8174E  f3 07 f0 ec 41
	ld XIX,BStore_SongName                                    ; F81753  44 ca 34 60 00
	ld	(xix+hl), a                                  ; F81758  f3 07 f0 ec 41
	ld XIX,DisplayListB_Stage                                    ; F8175D  44 f6 12 00 00
	ld	(xix+hl), a                                  ; F81762  f3 07 f0 ec 41
	ret                                                  ; F81767  0e
; ---------------------------------------------------------------------
; CharSet_F81768 -- 37 ASCII bytes: '_', 'A'..'Z', '0'..'9'
;
; Contents: 5F 41 42 ... 5A 30 31 ... 39, in that order, no terminator.
; Read by:  NOT ESTABLISHED.  No converted site names 0xF81768, and the routine
;          that uses it is presumably one of the still-`.incbin` neighbours; the
;          bytes are declared as data because a linear decode eats them (eight
;          `db` at 0xF81778-0xF8177F) and because the sequence is unambiguous.
; Evidence: the byte values themselves, checked one by one in
;          notes/prom_a_boot_checks.py (it asserts the exact 37-byte string and
;          that 0xF81767 and 0xF8178D are both instruction boundaries).
; Unknown:  what selects a character from it.  37 = 1 + 26 + 10 is the alphabet
;          a file-name or label entry field would offer, but nothing here says so.
; ---------------------------------------------------------------------
CharSet_F81768:
	.byte 0x5f, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a, 0x4b, 0x4c, 0x4d, 0x4e, 0x4f  ; F81768
	.byte 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x30, 0x31, 0x32, 0x33, 0x34  ; F81778
	.byte 0x35, 0x36, 0x37, 0x38, 0x39                                        ; F81788
; S0ngSelectName_PrepareValues -- set up the SONG SELECT & NAME display variables on entry
; Evidence: first call of Paint_S0ngSelectName (0xF80E32).  Unless (0x207B)=0x0D: (0x0E45)=0, T_Transport_StopAllRunning, (0x34BB),4, cursor (0x222D)=(0x1301)=0, (0x60341E)=(0x360C).  Always: 6 bytes 0x6034CA -> 0x12F6, (0x12FC)=(0x360A)+1, SongName_CharIndexAtCursor -> (0x1302), and the KB/percent pair as S0ngSelectName_UpdateSizeValues does.
S0ngSelectName_PrepareValues:
	cp	(UI_ScreenLatch_Previous:16), 0x0d                            ; F8178D  c1 7b 20 3f 0d
	jr z, .LF817B5                                       ; F81792  66 21
	ld (0x0e45:16), 0x00                                 ; F81794  f1 45 0e 00 00
	call T_Transport_StopAllRunning                                        ; F81799  1d ac 09 f4
	or	(0x34bb:16), 0x04                            ; F8179D  c1 bb 34 3e 04
	xor A,A                                              ; F817A2  c9 d1
	ld (NameEdit_CursorPos:16), a                                   ; F817A4  f1 2d 22 41
	ld (DisplayListB_Stage+11:16), a                                   ; F817A8  f1 01 13 41
	ld xwa, (0x360c:16)                                 ; F817AC  e1 0c 36 20
	ld (0x60341e:24), xwa                               ; F817B0  f2 1e 34 60 60
.LF817B5:
	ld XIY,BStore_SongName                                    ; F817B5  45 ca 34 60 00
	ld XIX,DisplayListB_Stage                                    ; F817BA  44 f6 12 00 00
	ldw bc, 0x06                                         ; F817BF  31 06 00
	ldir85                                               ; F817C2  85 11
	ld a, (BStore_CurrentBank:16)                                   ; F817C4  c1 0a 36 21
	inc 1,A                                              ; F817C8  c9 61
	ld (DisplayListB_Stage+6:16), a                                   ; F817CA  f1 fc 12 41
	call SongName_CharIndexAtCursor                                      ; F817CE  1d 88 16 f8
	ld a, (NameEdit_CharIndex:16)                                   ; F817D2  c1 f9 21 21
	ld (DisplayListB_Stage+12:16), a                                   ; F817D6  f1 02 13 41
	ld a, (BStore_CurrentBank:16)                                   ; F817DA  c1 0a 36 21
	ld (0x0e32:16), a                                   ; F817DE  f1 32 0e 41
	call SongStore_MeasureSongSize                                      ; F817E2  1d e9 19 f8
	ld wa, (0x0e2f:16)                                 ; F817E6  d1 2f 0e 20
	ld (DisplayListB_Stage+7:16), wa                                  ; F817EA  f1 fd 12 50
	ld a, (0x0e31:16)                                   ; F817EE  c1 31 0e 21
	ld (DisplayListB_Stage+9:16), a                                   ; F817F2  f1 ff 12 41
	ret                                                  ; F817F6  0e
; S0ngSelectName_Leave -- the work of the S0ngSelectName Leave method
; Evidence: only caller is ScreenLeaveBody_S0ngSelectName.  Unless (0x207A)=0x0D: and (0x34BB),0xFB (undoing S0ngSelectName_PrepareValues' or), call T_NoteRouting_RebuildForSong, (0x0E45)=0.
S0ngSelectName_Leave:
	cp	(UI_ScreenLatch:16), 0x0d                            ; F817F7  c1 7a 20 3f 0d
	jr z, .LF8180C                                       ; F817FC  66 0e
	and	(0x34bb:16), 0xfb                            ; F817FE  c1 bb 34 3c fb
	call T_NoteRouting_RebuildForSong                                        ; F81803  1d b8 11 f4
	ld (0x0e45:16), 0x00                                 ; F81807  f1 45 0e 00 00
.LF8180C:
	ret                                                  ; F8180C  0e
; S0ngSelectName_LoadSongFromBank -- load song (0x360A) from its bank into the workspace and refresh the name-edit state
; Evidence: saves workspace words +0xB8/+0xBA in (0x0E2B)/(0x0E2D), ldir 0xC00 bytes 0x610000+(0x360A)*0xC00 -> 0x603400 and restores the two words (as prom_b BStore_Workspace_LoadFromBank does), (0x360C)=(0x60341E), (0x3752)=bit 0 of (0x603420), cursor 0, name -> 0x12F6, SongName_CharIndexAtCursor; then the (0x6034C6)/(0x7F4D) queue post, T_F42578, T_Seq_RequestRewind, T_Seq_ApplySongBeatsPerBar, (0x360B) bit 0 cleared.
; The label sub_F81812 one instruction in is unreferenced and part of this routine.
S0ngSelectName_LoadSongFromBank:
	ld wa, (BStore_FreeHead:24)                                ; F8180D  d2 b8 34 60 20
; (sub_F81812 removed 2026-10-04: no code names it and the line above falls through into it -- part of S0ngSelectName_LoadSongFromBank;
;  notes/prom_a_stray_label_removal.py)
	ld (0x0e2b:16), wa                                  ; F81812  f1 2b 0e 50
	ld wa, (BStore_FreeCount:24)                                ; F81816  d2 ba 34 60 20
	ld (0x0e2d:16), wa                                  ; F8181B  f1 2d 0e 50
	xor XWA,XWA                                          ; F8181F  e8 d0
	ld a, (BStore_CurrentBank:16)                                   ; F81821  c1 0a 36 21
	ld XIX,XWA                                           ; F81825  e8 8c
	sla xwa, 0x0b                                        ; F81827  e8 ec 0b
	sla xix, 0x0a                                        ; F8182A  ec ec 0a
	add XWA,XIX                                          ; F8182D  ec 80
	ld XIY,0x00610000                                    ; F8182F  45 00 00 61 00
	add XIY,XWA                                          ; F81834  e8 85
	ld XIX,0x00603400                                    ; F81836  44 00 34 60 00
	ldw bc, 0x0c00                                       ; F8183B  31 00 0c
	ldir85                                               ; F8183E  85 11
	ld wa, (0x0e2b:16)                                 ; F81840  d1 2b 0e 20
	ld (BStore_FreeHead:24), wa                                ; F81844  f2 b8 34 60 50
	ld wa, (0x0e2d:16)                                 ; F81849  d1 2d 0e 20
	ld (BStore_FreeCount:24), wa                                ; F8184D  f2 ba 34 60 50
	ld xwa, (0x60341e:24)                               ; F81852  e2 1e 34 60 20
	ld (0x360c:16), xwa                                 ; F81857  f1 0c 36 60
	bit	0, (0x603420:24)                             ; F8185B  f2 20 34 60 c8
	jr z, .LF81869                                       ; F81860  66 07
	ld (0x3752:16), 0x01                                 ; F81862  f1 52 37 00 01
	jr .LF8186E                                          ; F81867  68 05
.LF81869:
	ld (0x3752:16), 0x00                                 ; F81869  f1 52 37 00 00
.LF8186E:
	and	(0x34bb:16), 0xf7                            ; F8186E  c1 bb 34 3c f7
	call T_Seq_RequestRewind                                        ; F81873  1d e0 09 f4
	xor A,A                                              ; F81877  c9 d1
	ld (NameEdit_CursorPos:16), a                                   ; F81879  f1 2d 22 41
	ld (DisplayListB_Stage+11:16), a                                   ; F8187D  f1 01 13 41
	ld XIX,DisplayListB_Stage                                    ; F81881  44 f6 12 00 00
	ld XIY,BStore_SongName                                    ; F81886  45 ca 34 60 00
	ldw bc, 0x06                                         ; F8188B  31 06 00
	ldir85                                               ; F8188E  85 11
	call SongName_CharIndexAtCursor                                      ; F81890  1d 88 16 f8
	ld a, (NameEdit_CharIndex:16)                                   ; F81894  c1 f9 21 21
	ld (DisplayListB_Stage+12:16), a                                   ; F81898  f1 02 13 41
	cp	(0x6034c6:24), 0xff                          ; F8189C  c2 c6 34 60 3f ff
	jr z, .LF818B3                                       ; F818A2  66 0f
	bit	2, (0x7f4d:16)                               ; F818A4  f1 4d 7f ca
	jr z, .LF818D3                                       ; F818A8  66 29
	and	(0x7f4d:16), 0xfb                            ; F818AA  c1 4d 7f 3c fb
	xor A,A                                              ; F818AF  c9 d1
	jr .LF818C0                                          ; F818B1  68 0d
.LF818B3:
	bit	2, (0x7f4d:16)                               ; F818B3  f1 4d 7f ca
	jr nz, .LF818D3                                      ; F818B7  6e 1a
	or	(0x7f4d:16), 0x04                            ; F818B9  c1 4d 7f 3e 04
	ld a, 0x04:opc                                          ; F818BE  21 04
.LF818C0:
	ld (0x124c:16), 0x01                                 ; F818C0  f1 4c 12 00 01
	ld e, 0x91:opc                                          ; F818C5  25 91
	ld d, 0x03:opc                                          ; F818C7  24 03
	ld w, 0x04:opc                                          ; F818C9  20 04
	call T_Queue2C00_AppendRegs                          ; F818CB  1d 38 0f f4
	call T_Queue2C00_DrainPassAB                         ; F818CF  1d 18 00 f4
.LF818D3:
	call T_F42578                                        ; F818D3  1d 78 25 f4
	and	(0x34bb:16), 0xf7                            ; F818D7  c1 bb 34 3c f7
	call T_Seq_RequestRewind                                        ; F818DC  1d e0 09 f4
	call T_Seq_ApplySongBeatsPerBar                                        ; F818E0  1d c8 0a f4
	and	(0x360b:16), 0xfe                            ; F818E4  c1 0b 36 3c fe
	ret                                                  ; F818E9  0e
; ---------------------------------------------------------------------
; SongName_ResetToUnderscores -- blank all three copies of the six-character name buffer
;
; Called from: prom_a S0ngSelectName_ClearName (`call`) at 0xF81683
; Evidence: three `ldir` runs of BC = 6 from the same source 0xF81948 (`______`) to
;           0x006034CA, to 0x00610000 + ((0x360A) << 11) + ((0x360A) << 10) + 0xCA, and
;           to 0x0012F6.  The destinations are read straight off the three `ld XIX`
;           sequences; that the second is indexed by (0x360A) is why this routine, and
;           not the drawer, is where the buffer's aliases are visible.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
SongName_ResetToUnderscores:
	ld XIX,BStore_SongName                                    ; F818EA  44 ca 34 60 00
	ld XIY,Str_SongNameBlank                                    ; F818EF  45 48 19 f8 00
	ldw bc, 0x06                                         ; F818F4  31 06 00
	ldir85                                               ; F818F7  85 11
	xor XWA,XWA                                          ; F818F9  e8 d0
	ld a, (BStore_CurrentBank:16)                                   ; F818FB  c1 0a 36 21
	ld XIY,XWA                                           ; F818FF  e8 8d
	sla xwa, 0x0b                                        ; F81901  e8 ec 0b
	sla xiy, 0x0a                                        ; F81904  ed ec 0a
	add XWA,XIY                                          ; F81907  ed 80
	ld XIX,0x00610000                                    ; F81909  44 00 00 61 00
	add XIX,XWA                                          ; F8190E  e8 84
	ld XWA,0x000000ca                                    ; F81910  40 ca 00 00 00
	add XIX,XWA                                          ; F81915  e8 84
	ld XIY,Str_SongNameBlank                                    ; F81917  45 48 19 f8 00
	ldw bc, 0x06                                         ; F8191C  31 06 00
	ldir85                                               ; F8191F  85 11
	ld XIX,DisplayListB_Stage                                    ; F81921  44 f6 12 00 00
	ld XIY,Str_SongNameBlank                                    ; F81926  45 48 19 f8 00
	ldw bc, 0x06                                         ; F8192B  31 06 00
	ldir85                                               ; F8192E  85 11
	xor A,A                                              ; F81930  c9 d1
	ld (NameEdit_CursorPos:16), a                                   ; F81932  f1 2d 22 41
	ld (DisplayListB_Stage+11:16), a                                   ; F81936  f1 01 13 41
	ld (NameEdit_CharIndex:16), a                                   ; F8193A  f1 f9 21 41
	ld (DisplayListB_Stage+12:16), a                                   ; F8193E  f1 02 13 41
	or	(UI_Request_Hi:16), 0x10                            ; F81942  c1 71 20 3e 10
	ret                                                  ; F81947  0e
; Str_SongNameBlank: DATA, not code: six bytes 0x5F = '______', the blank song name. SongName_ResetToUnderscores
;   copies them (ldir, BC = 6) into all three copies of the name (BStore_SongName, the bank copy +0xCA,
;   DisplayListB_Stage); today they are decoded as six `pop XSP`, and the code from 0xF8194E on is a separate,
;   unlabelled routine. Basis: the three `ld XIY` operand references + ROM bytes. (notes/naming-
;   pilot-2026-10-06/proposals_wave8_b8.json)
; (2026-10-06) Respelled as `.ascii "______"`; the code from 0xF8194E now carries the label sub_F8194E.
Str_SongNameBlank:   ; entry: named by 3 `ld` operands, first at 0xF818EF
	.ascii "______"                                     ; F81948  5f 5f 5f 5f 5f 5f
; sub_F8194E: no reference found -- no 24-bit address of 0xF8194E in prom_a/b/c (ROM byte search for 4e 19 f8,
;   2026-10-06) and no branch label there.  It sets 0x0E03 = (0x0C03) - (DisplayListB_Stage), fills UI_DrawScratch, then
;   copies the track's BStore_TrackToPart and 0x603433 rows into UI_DrawScratch+8 / +24 around sub_F819A2.
sub_F8194E:
	ld a, (0x0c03:16)                                   ; F8194E  c1 03 0c 21
	sub a, (DisplayListB_Stage:16)                                   ; F81952  c1 f6 12 a1
	ld (0x0e03:16), a                                   ; F81956  f1 03 0e 41
	inc 1,A                                              ; F8195A  c9 61
	ld c, 0x08:opc                                          ; F8195C  23 08
	ld XIX,UI_DrawScratch                                    ; F8195E  44 40 26 00 00
.LF81963:
	ld (xix+), a                                    ; F81963  f5 f0 41
	djnz8 c, .LF81963                                    ; F81966  cb 1c fa
	ldw bc, 0x08                                         ; F81969  31 08 00
	xor WA,WA                                            ; F8196C  d8 d0
	ld a, (0x0e03:16)                                   ; F8196E  c1 03 0e 21
	ld XIY,BStore_TrackToPart                                    ; F81972  45 22 34 60 00
	lda	xiy, (xiy+wa)                                ; F81977  f3 07 f4 e0 35
	ld XIX,UI_DrawScratch+8                                    ; F8197C  44 48 26 00 00
	ldir85                                               ; F81981  85 11
	call sub_F819A2                                      ; F81983  1d a2 19 f8
	xor WA,WA                                            ; F81987  d8 d0
	ld a, (0x0e03:16)                                   ; F81989  c1 03 0e 21
	ldw bc, 0x08                                         ; F8198D  31 08 00
	ld XIY,0x00603433                                    ; F81990  45 33 34 60 00
	lda	xiy, (xiy+wa)                                ; F81995  f3 07 f4 e0 35
	ld XIX,UI_DrawScratch+24                                    ; F8199A  44 58 26 00 00
	ldir85                                               ; F8199F  85 11
	ret                                                  ; F819A1  0e
sub_F819A2:
	ld l, 0x08:opc                                          ; F819A2  27 08
	ld c, (0x0e03:16)                                   ; F819A4  c1 03 0e 23
	ld XIX,UI_DrawScratch+16                                    ; F819A8  44 50 26 00 00
.LF819AD:
	ld A,C                                               ; F819AD  cb 89
	pushw hl                                             ; F819AF  2b
	pushw bc                                             ; F819B0  29
	push XIX                                             ; F819B1  3c
	call T_TrackAssign_IsLocalControlDashed                                        ; F819B2  1d 9c 2b f4
	pop XIX                                              ; F819B6  5c
	popw bc                                              ; F819B7  49
	popw hl                                              ; F819B8  4b
	cp A,0x55                                            ; F819B9  c9 cf 55
	jr nz, .LF819C2                                      ; F819BC  6e 04
	ld a, 0x02:opc                                          ; F819BE  21 02
	jr .LF819E0                                          ; F819C0  68 1e
.LF819C2:
	ldfr_berp a, 0x3c                                      ; F819C2  c7 3c 99   ld RL3,A
	.byte 0xd7, 0x3e, 0x9a                               ; F819C5  d7 3e 9a   ld QHL3,DE
	ld de, (0x603454:24)                                ; F819C8  d2 54 34 60 22
	ld A,C                                               ; F819CD  cb 89
	scf                                                  ; F819CF  11
	.byte 0xda, 0x2a                                     ; F819D0  da 2a   xorcf A,DE
	.byte 0xd7, 0x3e, 0x8a                               ; F819D2  d7 3e 8a   ld DE,QHL3
	ld_erpb_rr a, 0x3c                                   ; F819D5  c7 3c 89   ld A,RL3
	jr nc, .LF819DE                                      ; F819D8  6f 04
	xor A,A                                              ; F819DA  c9 d1
	jr .LF819E0                                          ; F819DC  68 02
.LF819DE:
	ld a, 0x01:opc                                          ; F819DE  21 01
.LF819E0:
	ld (xix+), a                                    ; F819E0  f5 f0 41
	inc 1,C                                              ; F819E3  cb 61
	djnz8 l, .LF819AD                                    ; F819E5  cf 1c c5
	ret                                                  ; F819E8  0e
; SongStore_MeasureSongSize -- size of song (0x0E32): (0x0E2F) = KB, (0x0E31) = percent of the block heap
; Evidence: directory = 0x603500 when (0x0E32)=(0x360A) (the song in the workspace), else 0x610000+n*0xC00+0x100 (the bank's copy); for each 3-byte entry 0..0x30 with bit 7 set, SongStore_CountChainBlocks; (0x0E31) = blocks*100/(0x3608)+1, max 99 ((0x3608) = heap block count, BStore_FreeList_Init); (0x0E2F) = blocks/4, at least 1 (256-byte blocks).
; Callers display them beside ' KB' and '%': S0ngSelectName and prom_b Paint_SongClear (0xF7EB23) / SongClear soft keys.  (0x126E) is preserved.
SongStore_MeasureSongSize:
	ld xwa, (BStore_CursorBlockAddr:16)                                 ; F819E9  e1 6e 12 20
	push XWA                                             ; F819ED  38
	xor XWA,XWA                                          ; F819EE  e8 d0
	ld a, (0x0e32:16)                                   ; F819F0  c1 32 0e 21
	cp	a, (BStore_CurrentBank:16)                               ; F819F4  c1 0a 36 f1
	jr nz, .LF81A01                                      ; F819F8  6e 07
	ld XIX,0x00603500                                    ; F819FA  44 00 35 60 00
	jr .LF81A1C                                          ; F819FF  68 1b
.LF81A01:
	ld XIX,0x00610000                                    ; F81A01  44 00 00 61 00
	push XBC                                             ; F81A06  39
	xor XBC,XBC                                          ; F81A07  e9 d1
	ld C,A                                               ; F81A09  c9 8b
	sla xwa, 0x0b                                        ; F81A0B  e8 ec 0b
	sla xbc, 0x0a                                        ; F81A0E  e9 ec 0a
	add XWA,XBC                                          ; F81A11  e9 80
	pop XBC                                              ; F81A13  59
	add XIX,XWA                                          ; F81A14  e8 84
	add XIX,0x00000100                                   ; F81A16  ec c8 00 01 00 00
.LF81A1C:
	xor XBC,XBC                                          ; F81A1C  e9 d1
	xor DE,DE                                            ; F81A1E  da d2
.LF81A20:
	ld	a, (xix+de)                                  ; F81A20  c3 07 f0 e8 21
	bit 0x07,A                                           ; F81A25  c9 33 07
	jr z, .LF81A37                                       ; F81A28  66 0d
	push XBC                                             ; F81A2A  39
	push XDE                                             ; F81A2B  3a
	push XIX                                             ; F81A2C  3c
	call SongStore_CountChainBlocks                                      ; F81A2D  1d 83 1a f8
	pop XIX                                              ; F81A31  5c
	pop XDE                                              ; F81A32  5a
	pop XBC                                              ; F81A33  59
	.byte 0xe7, 0x34, 0x81                               ; F81A34  e7 34 81   add XBC,XBC3
.LF81A37:
	add DE,0x0003                                        ; F81A37  da c8 03 00
	cp DE,0x0033                                         ; F81A3B  da cf 33 00
	jr c, .LF81A20                                       ; F81A3F  67 df
	ld XDE,XBC                                           ; F81A41  e9 8a
	cp XBC,0x00000000                                    ; F81A43  e9 cf 00 00 00 00
	jr z, .LF81A62                                       ; F81A49  66 17
	ld XDE,XBC                                           ; F81A4B  e9 8a
	mul BC,0x0064                                        ; F81A4D  d9 08 64 00
	ld hl, (BStore_BlockCount:16)                                 ; F81A51  d1 08 36 23
	div xbc, hl                                         ; F81A55  db 51
	inc 1,BC                                             ; F81A57  d9 61
	cp BC,0x0064                                         ; F81A59  d9 cf 64 00
	jr c, .LF81A62                                       ; F81A5D  67 03
	ldw bc, 0x63                                         ; F81A5F  31 63 00
.LF81A62:
	ld (0x0e31:16), c                                   ; F81A62  f1 31 0e 43
	cp XDE,0x00000000                                    ; F81A66  ea cf 00 00 00 00
	jr z, .LF81A79                                       ; F81A6C  66 0b
	ldw wa, 0x04                                         ; F81A6E  30 04 00
	div xde, wa                                         ; F81A71  d8 52
	cp de, 0x00:i3                                         ; F81A73  da d8
	jr nz, .LF81A79                                      ; F81A75  6e 02
	inc 1,DE                                             ; F81A77  da 61
.LF81A79:
	ld (0x0e2f:16), de                                  ; F81A79  f1 2f 0e 52
	pop XWA                                              ; F81A7D  58
	ld (BStore_CursorBlockAddr:16), xwa                                 ; F81A7E  f1 6e 12 60
	ret                                                  ; F81A82  0e
; SongStore_CountChainBlocks -- XBC3 = number of heap blocks in one directory entry's chain
; Evidence: HL = word at (XIX+DE+1) (directory entry head block, FINDINGS-prom_b-block-store.md); 0xFFFF -> 0; else count 1 and follow each block's +3 next word via SongStore_SeekBlock until 0xFFFF.  The caller adds XBC3 into XBC.
SongStore_CountChainBlocks:
	.byte 0xe7, 0x34, 0xa8                               ; F81A83  e7 34 a8   ld XBC3,0
	ld WA,DE                                             ; F81A86  da 88
	inc 1,WA                                             ; F81A88  d8 61
	ld	hl, (xix+wa)                                 ; F81A8A  d3 07 f0 e0 23
	cp HL,0xffff                                         ; F81A8F  db cf ff ff
	jr z, .LF81AB4                                       ; F81A93  66 1f
	.byte 0xe7, 0x34, 0x61                               ; F81A95  e7 34 61   inc 1,XBC3
.LF81A98:
	.byte 0xe7, 0x34, 0x04                               ; F81A98  e7 34 04   push XBC3
	call SongStore_SeekBlock                                      ; F81A9B  1d b5 1a f8
	.byte 0xe7, 0x34, 0x05                               ; F81A9F  e7 34 05   pop XBC3
	ld xhl, (BStore_CursorBlockAddr:16)                                 ; F81AA2  e1 6e 12 23
	ld HL,(XHL+0x03)                                     ; F81AA6  9b 03 23
	cp HL,0xffff                                         ; F81AA9  db cf ff ff
	jr z, .LF81AB4                                       ; F81AAD  66 05
	.byte 0xe7, 0x34, 0x61                               ; F81AAF  e7 34 61   inc 1,XBC3
	jr .LF81A98                                          ; F81AB2  68 e4
.LF81AB4:
	ret                                                  ; F81AB4  0e
; SongStore_SeekBlock -- (0x126E) = address of heap block HL (1-based)
; Evidence: `ld XIY,(0x3604) / extz XHL / dec 1,XHL / sla 8,XHL / add XIY,XHL / ld (0x126E),XIY / xor XHL,XHL`, XIY saved and restored -- the value prom_b BStore_SeekBlock computes; called only by SongStore_CountChainBlocks.
; Retraction kept from round 5: the 'MASTER TRACK CLEAR' text once credited to this label is drawn by the UNLABELLED function at 0xF81ACB (ld XIY,DL_MasterTrackClearAttention / call T_DisplayList_Run at 0xF81B21), which this routine never calls and nothing references.
SongStore_SeekBlock:
	push XIY                                             ; F81AB5  3d
	ld xiy, (BStore_HeapBase:16)                                 ; F81AB6  e1 04 36 25
	extz XHL                                             ; F81ABA  eb 12
	dec 1,XHL                                            ; F81ABC  eb 69
	sla xhl, 0x08                                        ; F81ABE  eb ec 08
	add XIY,XHL                                          ; F81AC1  eb 85
	ld (BStore_CursorBlockAddr:16), xiy                                 ; F81AC3  f1 6e 12 65
	xor XHL,XHL                                          ; F81AC7  eb d3
	pop XIY                                              ; F81AC9  5d
	ret                                                  ; F81ACA  0e
; Paint_StepRecord: returns unless (UI_ScreenId) = 0x0E; draws "STEP RECORD:" / "TRACK:" (or
;   "MASTER STEP RECORD" when (0x0E63) = 2) and the page list StepSelectAddrTable_F3D089 gives for
;   UI_StepRecord_SubScreen (sub-screen 18: the MASTER TRACK CLEAR / TRACK CLR confirmation).
Paint_StepRecord:
	bit	0, (0x1071:16)                               ; F81ACB  f1 71 10 c8
	jrl nz, .LF81BCF                                     ; F81ACF  7e fd 00
	cp	(UI_ScreenId:16), 0x0e                            ; F81AD2  c1 7c 20 3f 0e
	jrl nz, .LF81BCF                                     ; F81AD7  7e f5 00
	or	(0xc6:8), 0x01                               ; F81ADA  c0 c6 3e 01
	ld (LCD_CurrentLayer:16), 0x00                                 ; F81ADE  f1 40 25 00 00
	calr LCD_ClearCurrentLayer                                          ; F81AE3  1e 07 c8
	ld l, (UI_StepRecord_SubScreen:16)                                   ; F81AE6  c1 f5 0e 27
	xor H,H                                              ; F81AEA  ce d6
	cp L,0x12                                            ; F81AEC  cf cf 12
	jr nz, .LF81B28                                      ; F81AEF  6e 37
	ld (LCD_CurrentLayer:16), 0x01                                 ; F81AF1  f1 40 25 00 01
	calr LCD_ClearCurrentLayer                                          ; F81AF6  1e f4 c7
	ld (LCD_CurrentLayer:16), 0x02                                 ; F81AF9  f1 40 25 00 02
	calr LCD_ClearCurrentLayer                                          ; F81AFE  1e ec c7
	ld (LCD_CurrentLayer:16), 0x00                                 ; F81B01  f1 40 25 00 00
	ld XIY,Paint_StepRecord_DL1                                     ; F81B06  45 c6 cf f3 00
	ld XIX,DL_StepRecordTrackTrackClrMeas                ; F81B0B  44 16 d0 f3 00
	cp	(0x0e63:16), 0x02                            ; F81B10  c1 63 0e 3f 02
	jr nz, .LF81B21                                      ; F81B15  6e 0a
	ld XIY,DL_MasterTrackClearAttention                  ; F81B17  45 6e e0 f3 00
	ld XIX,DL_F3E15C                                     ; F81B1C  44 5c e1 f3 00
.LF81B21:
	call T_DisplayList_Run                               ; F81B21  1d f0 17 f4
	jrl .LF81BCF                                         ; F81B25  78 a7 00
.LF81B28:
	ld XIY,Paint_StepRecord_DL2                                     ; F81B28  45 09 cf f3 00
	ld XIX,0x00f3cf32                                    ; F81B2D  44 32 cf f3 00
	cp	(0x0e63:16), 0x02                            ; F81B32  c1 63 0e 3f 02
	jr nz, .LF81B43                                      ; F81B37  6e 0a
	ld XIY,0x00f3cf32                                    ; F81B39  45 32 cf f3 00
	ld XIX,DL_F3CF57                                     ; F81B3E  44 57 cf f3 00
.LF81B43:
	push XHL                                             ; F81B43  3b
	call T_DisplayList_Run                               ; F81B44  1d f0 17 f4
	pop XHL                                              ; F81B48  5b
	cp	(0x0e63:16), 0x00                            ; F81B49  c1 63 0e 3f 00
	jr nz, .LF81B56                                      ; F81B4E  6e 06
	call Paint_StepRecordTrackClrMeas                                      ; F81B50  1d d4 1b f8
	jr .LF81BCF                                          ; F81B54  68 79
.LF81B56:
	cp	(0x0e63:16), 0x02                            ; F81B56  c1 63 0e 3f 02
	jr z, .LF81B70                                       ; F81B5B  66 13
	ld a, (0x0e5c:16)                                   ; F81B5D  c1 5c 0e 21
	ld (DisplayListB_Stage+7:16), a                                   ; F81B61  f1 fd 12 41
	ld XIY,0x00f3d380                                    ; F81B65  45 80 d3 f3 00
	push XHL                                             ; F81B6A  3b
	call T_DLB_Handler_Decimal                                        ; F81B6B  1d 00 18 f4
	pop XHL                                              ; F81B6F  5b
.LF81B70:
	push XHL                                             ; F81B70  3b
	sla hl, 0x02                                         ; F81B71  db ec 02
	ld XIY,StepSelectAddrTable_F3D089                    ; F81B74  45 89 d0 f3 00
	cp	(0x0e63:16), 0x02                            ; F81B79  c1 63 0e 3f 02
	jr nz, .LF81B85                                      ; F81B7E  6e 05
	ld XIY,0x00f3d121                                    ; F81B80  45 21 d1 f3 00
.LF81B85:
	ld	xiy, (xiy+hl)                                ; F81B85  e3 07 f4 ec 25
	ld XIX,0x00f3d0d5                                    ; F81B8A  44 d5 d0 f3 00
	cp	(0x0e63:16), 0x02                            ; F81B8F  c1 63 0e 3f 02
	jr nz, .LF81B9B                                      ; F81B94  6e 05
	ld XIX,0x00f3d16d                                    ; F81B96  44 6d d1 f3 00
.LF81B9B:
	ld	xix, (xix+hl)                                ; F81B9B  e3 07 f0 ec 24
	call T_DisplayList_Run                               ; F81BA0  1d f0 17 f4
	pop XHL                                              ; F81BA4  5b
	cp l, 0x00:i3                                          ; F81BA5  cf d8
	jr nz, .LF81BB7                                      ; F81BA7  6e 0e
	ld XIY,Paint_StepRecord_DL3                                     ; F81BA9  45 26 de f3 00
	ld XIX,DL_F3DEB2                                     ; F81BAE  44 b2 de f3 00
	call T_DisplayList_Run                               ; F81BB3  1d f0 17 f4
.LF81BB7:
	cp	(0x0e63:16), 0x02                            ; F81BB7  c1 63 0e 3f 02
	jr z, .LF81BCF                                       ; F81BBC  66 11
	ld a, (0x0e63:16)                                   ; F81BBE  c1 63 0e 21
	ld (DisplayListB_Stage+6:16), a                                   ; F81BC2  f1 fc 12 41
	ld XIY,0x00f3c967                                    ; F81BC6  45 67 c9 f3 00
	call T_DLB_Handler_StringTable                       ; F81BCB  1d f8 17 f4
.LF81BCF:
	and	(0xc6:8), 0xfe                               ; F81BCF  c0 c6 3c fe
	ret                                                  ; F81BD3  0e
; Paint_StepRecordTrackClrMeas -- paints the screen whose own text reads "STEP RECORD:", "TRACK:", "TRACK"
;
; It reaches the display-list interpreters at 0xF417F0 (A) and 0xF417F4 (B)
; 3 time(s); XIY = list start, XIX = list end.  1 of those 3 list(s)
; carry text, and those are the ones that name this routine:
;     site 0xF81BEA  interpreter A  list 0xF3D016  DL_StepRecordTrackTrackClrMeas
;        text: "STEP RECORD:"; "TRACK:"; "TRACK"; "CLR"; "MEAS"
; Evidence: the list address is the `ld XIY,0x00F3D016` IMMEDIATE at the
;          instruction two before the cited `call`, and the text quoted
;          above is the `.ascii` the interpreter draws verbatim.  Every
;          alphabetic morpheme of this name occurs in that text; the
;          check is notes/prom_a_understanding_round5.py --morphemes.
;          `Paint_` is a structural verb, not ROM text.
;          ⚠ ROUND 5: where the label reads `InstallPainter_`, the body contains
;          ZERO display-list calls -- it INSTALLS the callback that paints this
;          screen, through `call 0xF42E84`. The screen association is real one hop
;          away; the earlier `Paint_` verb claimed the body did the drawing and it
;          does not. Any display-list COUNT in a header above such a label is the
;          installed callback's, not this routine's.
; Unknown: whether this routine also handles input for the screen, and
;          whether any other routine paints it.  Neither was searched.
; ---------------------------------------------------------------------
Paint_StepRecordTrackClrMeas:
	or	(0xc6:8), 0x01                               ; F81BD4  c0 c6 3e 01
	ld (LCD_CurrentLayer:16), 0x00                                 ; F81BD8  f1 40 25 00 00
	calr LCD_ClearCurrentLayer                                          ; F81BDD  1e 0d c7
	ld XIY,DL_StepRecordTrackTrackClrMeas                ; F81BE0  45 16 d0 f3 00
	ld XIX,StepSelectAddrTable_F3D089                    ; F81BE5  44 89 d0 f3 00
	call T_DisplayList_Run                               ; F81BEA  1d f0 17 f4
	ld a, (0x0e5c:16)                                   ; F81BEE  c1 5c 0e 21
	ld (DisplayListB_Stage+7:16), a                                   ; F81BF2  f1 fd 12 41
	ld XIY,0x00f3d380                                    ; F81BF6  45 80 d3 f3 00
	call T_DLB_Handler_Decimal                                        ; F81BFB  1d 00 18 f4
	ld a, (0x0e63:16)                                   ; F81BFF  c1 63 0e 21
	ld (DisplayListB_Stage+6:16), a                                   ; F81C03  f1 fc 12 41
	ld XIY,0x00f3c967                                    ; F81C07  45 67 c9 f3 00
	call T_DLB_Handler_StringTable                       ; F81C0C  1d f8 17 f4
	and	(0xc6:8), 0xfe                               ; F81C10  c0 c6 3c fe
	ret                                                  ; F81C14  0e
sub_F81C15:
	cp	(UI_ScreenId:16), 0x0e                            ; F81C15  c1 7c 20 3f 0e
	jr nz, .LF81C2E                                      ; F81C1A  6e 12
	or	(0xc6:8), 0x01                               ; F81C1C  c0 c6 3e 01
	ld (LCD_CurrentLayer:16), 0x00                                 ; F81C20  f1 40 25 00 00
	ld XIY,0x00f3d38a                                    ; F81C25  45 8a d3 f3 00
	call T_DLB_Handler_StringTable                       ; F81C2A  1d f8 17 f4
.LF81C2E:
	and	(0xc6:8), 0xfe                               ; F81C2E  c0 c6 3c fe
	ret                                                  ; F81C32  0e
sub_F81C33:
	cp	(UI_ScreenId:16), 0x0e                            ; F81C33  c1 7c 20 3f 0e
	jr nz, .LF81C8F                                      ; F81C38  6e 55
	or	(0xc6:8), 0x01                               ; F81C3A  c0 c6 3e 01
	ld (LCD_CurrentLayer:16), 0x00                                 ; F81C3E  f1 40 25 00 00
	cpw	(0x0f5e:16), 0x0000                          ; F81C43  d1 5e 0f 3f 00 00
	jr nz, .LF81C5A                                      ; F81C49  6e 0f
	ld a, (0x106c:16)                                   ; F81C4B  c1 6c 10 21
	ld (DisplayListB_Stage+11:16), a                                   ; F81C4F  f1 01 13 41
	ld XIY,0x00f3d3cb                                    ; F81C53  45 cb d3 f3 00
	jr .LF81C6B                                          ; F81C58  68 11
.LF81C5A:
	ld a, (0x106c:16)                                   ; F81C5A  c1 6c 10 21
	ld (DisplayListB_Stage+10:16), a                                   ; F81C5E  f1 00 13 41
	ld (DisplayListB_Stage+11:16), a                                   ; F81C62  f1 01 13 41
	ld XIY,0x00f3d3ad                                    ; F81C66  45 ad d3 f3 00
.LF81C6B:
	cpw	(0x0f62:16), 0x0000                          ; F81C6B  d1 62 0f 3f 00 00
	jr nz, .LF81C7A                                      ; F81C71  6e 07
	ld XIX,0x00f3d3e9                                    ; F81C73  44 e9 d3 f3 00
	jr .LF81C87                                          ; F81C78  68 0d
.LF81C7A:
	ld a, (0x106c:16)                                   ; F81C7A  c1 6c 10 21
	ld (DisplayListB_Stage+12:16), a                                   ; F81C7E  f1 02 13 41
	ld XIX,0x00f3d407                                    ; F81C82  44 07 d4 f3 00
.LF81C87:
	call T_DisplayListB_Run                              ; F81C87  1d f4 17 f4
	and	(0xc6:8), 0xfe                               ; F81C8B  c0 c6 3c fe
.LF81C8F:
	ret                                                  ; F81C8F  0e
sub_F81C90:
	cp	(UI_ScreenId:16), 0x0e                            ; F81C90  c1 7c 20 3f 0e
	jrl nz, .LF81D3C                                     ; F81C95  7e a4 00
	or	(0xc6:8), 0x01                               ; F81C98  c0 c6 3e 01
	ld (LCD_CurrentLayer:16), 0x02                                 ; F81C9C  f1 40 25 00 02
	calr LCD_ClearCurrentLayer                                          ; F81CA1  1e 49 c6
	calr sub_F81EF3                                      ; F81CA4  1e 4c 02
	cpw	(0x0f5e:16), 0x0000                          ; F81CA7  d1 5e 0f 3f 00 00
	jr z, .LF81CD8                                       ; F81CAD  66 29
	xor BC,BC                                            ; F81CAF  d9 d1
	calr sub_F81F1A                                      ; F81CB1  1e 66 02
	cpw	(0x0f5e:16), 0x03e8                          ; F81CB4  d1 5e 0f 3f e8 03
	jr c, .LF81CC7                                       ; F81CBA  67 0b
	ld XIY,0x00f3d371                                    ; F81CBC  45 71 d3 f3 00
	call T_DLHandler_IX_Text                             ; F81CC1  1d 2c 18 f4
	jr .LF81CD8                                          ; F81CC5  68 11
.LF81CC7:
	ld wa, (0x0f5e:16)                                 ; F81CC7  d1 5e 0f 20
	ld (DisplayListB_Stage:16), wa                                  ; F81CCB  f1 f6 12 50
	ld XIY,0x00f3d353                                    ; F81CCF  45 53 d3 f3 00
	call T_DLB_Handler_Decimal_2                                        ; F81CD4  1d 04 18 f4
.LF81CD8:
	cpw	(0x0f60:16), 0x0000                          ; F81CD8  d1 60 0f 3f 00 00
	jr z, .LF81D0A                                       ; F81CDE  66 2a
	ldw bc, 0x01                                         ; F81CE0  31 01 00
	calr sub_F81F1A                                      ; F81CE3  1e 34 02
	cpw	(0x0f60:16), 0x03e8                          ; F81CE6  d1 60 0f 3f e8 03
	jr c, .LF81CF9                                       ; F81CEC  67 0b
	ld XIY,0x00f3d376                                    ; F81CEE  45 76 d3 f3 00
	call T_DLHandler_IX_Text                             ; F81CF3  1d 2c 18 f4
	jr .LF81D0A                                          ; F81CF7  68 11
.LF81CF9:
	ld wa, (0x0f60:16)                                 ; F81CF9  d1 60 0f 20
	ld (DisplayListB_Stage+2:16), wa                                  ; F81CFD  f1 f8 12 50
	ld XIY,0x00f3d35d                                    ; F81D01  45 5d d3 f3 00
	call T_DLB_Handler_Decimal_2                                        ; F81D06  1d 04 18 f4
.LF81D0A:
	cpw	(0x0f62:16), 0x0000                          ; F81D0A  d1 62 0f 3f 00 00
	jr z, .LF81D3C                                       ; F81D10  66 2a
	ldw bc, 0x02                                         ; F81D12  31 02 00
	calr sub_F81F1A                                      ; F81D15  1e 02 02
	cpw	(0x0f62:16), 0x03e8                          ; F81D18  d1 62 0f 3f e8 03
	jr c, .LF81D2B                                       ; F81D1E  67 0b
	ld XIY,0x00f3d37b                                    ; F81D20  45 7b d3 f3 00
	call T_DLHandler_IX_Text                             ; F81D25  1d 2c 18 f4
	jr .LF81D3C                                          ; F81D29  68 11
.LF81D2B:
	ld wa, (0x0f62:16)                                 ; F81D2B  d1 62 0f 20
	ld (DisplayListB_Stage+4:16), wa                                  ; F81D2F  f1 fa 12 50
	ld XIY,0x00f3d367                                    ; F81D33  45 67 d3 f3 00
	call T_DLB_Handler_Decimal_2                                        ; F81D38  1d 04 18 f4
.LF81D3C:
	and	(0xc6:8), 0xfe                               ; F81D3C  c0 c6 3c fe
	ret                                                  ; F81D40  0e
sub_F81D41:
	bit	0, (0x1071:16)                               ; F81D41  f1 71 10 c8
	jrl nz, .LF81DF9                                     ; F81D45  7e b1 00
	cp	(UI_ScreenId:16), 0x0e                            ; F81D48  c1 7c 20 3f 0e
	jrl nz, .LF81DF9                                     ; F81D4D  7e a9 00
	or	(0xc6:8), 0x01                               ; F81D50  c0 c6 3e 01
	ld XIY,0x000012c6                                    ; F81D54  45 c6 12 00 00
	ld XIX,0x00000a51                                    ; F81D59  44 51 0a 00 00
	xor DE,DE                                            ; F81D5E  da d2
.LF81D60:
	xor BC,BC                                            ; F81D60  d9 d1
	ld XIZ,0x00000f64                                    ; F81D62  46 64 0f 00 00
	xor XWA,XWA                                          ; F81D67  e8 d0
	ld A,E                                               ; F81D69  cd 89
	add XIZ,XWA                                          ; F81D6B  e8 86
	ld D,(XIZ)                                           ; F81D6D  86 24
	cp d, 0x00:i3                                          ; F81D6F  cc d8
	jr z, .LF81DA6                                       ; F81D71  66 33
.LF81D73:
	xor HL,HL                                            ; F81D73  db d3
	ld L,C                                               ; F81D75  cb 8f
	ld	l, (xiy+hl)                                  ; F81D77  c3 07 f4 ec 27
	and L,0x0f                                           ; F81D7C  cf cc 0f
	calr StepRecord_DrawNibbleAsStars                                      ; F81D7F  1e 7c 00
	add XIX,0x00000004                                   ; F81D82  ec c8 04 00 00 00
	xor HL,HL                                            ; F81D88  db d3
	ld L,C                                               ; F81D8A  cb 8f
	ld	l, (xiy+hl)                                  ; F81D8C  c3 07 f4 ec 27
	and L,0xf0                                           ; F81D91  cf cc f0
	srl l, 0x04                                          ; F81D94  cf ef 04
	calr StepRecord_DrawNibbleAsStars                                      ; F81D97  1e 64 00
	add XIX,0x00000004                                   ; F81D9A  ec c8 04 00 00 00
	inc 1,C                                              ; F81DA0  cb 61
	cp C,D                                               ; F81DA2  cc f3
	jr c, .LF81D73                                       ; F81DA4  67 cd
.LF81DA6:
	inc 1,E                                              ; F81DA6  cd 61
	cp e, 0x03:i3                                          ; F81DA8  cd db
	jr ge, .LF81DC2                                      ; F81DAA  69 16
	add XIY,0x00000004                                   ; F81DAC  ed c8 04 00 00 00
	ld a, 0x08:opc                                          ; F81DB2  21 08
	mul wa, c                                          ; F81DB4  cb 41
	extz XWA                                             ; F81DB6  e8 12
	sub XIX,XWA                                          ; F81DB8  e8 a4
	add XIX,0x00000708                                   ; F81DBA  ec c8 08 07 00 00
	jr .LF81D60                                          ; F81DC0  68 9e
.LF81DC2:
	ld (LCD_CurrentLayer:16), 0x00                                 ; F81DC2  f1 40 25 00 00
	ld a, (0x0f64:16)                                   ; F81DC7  c1 64 0f 21
	cp	(0x0f5e:16), 0x00                            ; F81DCB  c1 5e 0f 3f 00
	jr nz, .LF81DD4                                      ; F81DD0  6e 02
	ld a, 0x00:opc                                          ; F81DD2  21 00
.LF81DD4:
	ld (UI_DrawScratch:16), a                                   ; F81DD4  f1 40 26 41
	ld a, (0x0f65:16)                                   ; F81DD8  c1 65 0f 21
	ld (UI_DrawScratch+1:16), a                                   ; F81DDC  f1 41 26 41
	ld a, (0x0f66:16)                                   ; F81DE0  c1 66 0f 21
	ld (UI_DrawScratch+2:16), a                                   ; F81DE4  f1 42 26 41
	ld XIY,DL_F3DC00                                     ; F81DE8  45 00 dc f3 00
	ld XIX,Data_F3DC21                                   ; F81DED  44 21 dc f3 00
	call T_DisplayListB_Run                              ; F81DF2  1d f4 17 f4
	calr LCD_DrawEndOrClear                                      ; F81DF6  1e 1e 00
.LF81DF9:
	and	(0xc6:8), 0xfe                               ; F81DF9  c0 c6 3c fe
	ret                                                  ; F81DFD  0e
; StepRecord_DrawNibbleAsStars -- draw the low nibble of L as four 8x14 cells: '*' for a set bit, glyph 0x91 for a clear one
; Evidence: (0x2540)=0, XIY=0xF3DC7B, BC=4, svc 6 (LCD_Svc_06_DrawText8x14) with HL=L; the 64 bytes at 0xF3DC7B are 16 entries of 4 where cell k of entry n is 0x2A iff bit k of n is set (all 16 checked against the ROM).
; Caller: the unlabelled STEP RECORD painter at 0xF81D41 (gated on (0x207C)=0x0E), two nibbles per byte of 0x12C6..
StepRecord_DrawNibbleAsStars:
	push XIY                                             ; F81DFE  3d
	push XIX                                             ; F81DFF  3c
	pushw de                                             ; F81E00  2a
	pushw bc                                             ; F81E01  29
	ld XIY,0x00f3dc7b                                    ; F81E02  45 7b dc f3 00
	ldw bc, 0x04                                         ; F81E07  31 04 00
	ld a, 0x06:opc                                          ; F81E0A  21 06
	ld (LCD_CurrentLayer:16), 0x00                                 ; F81E0C  f1 40 25 00 00
	swi 7                                                ; F81E11  ff
	popw bc                                              ; F81E12  49
	popw de                                              ; F81E13  4a
	pop XIX                                              ; F81E14  5c
	pop XIY                                              ; F81E15  5d
	ret                                                  ; F81E16  0e
; ---------------------------------------------------------------------
; LCD_DrawEndOrClear -- draw END on layer 2, or clear the three blocks it would stand in
;
; Called from: prom_a Paint_StepRecordTrackClrMeas (`calr`) at 0xF81DF6
; Issues:  SWI7 service 0x06 at 0xF81E4E -- LCD_Svc_06_DrawText8x14, draw 8x14 text
; Evidence: the arm at 0xF81E4E is `ld (0x2540),0x02` + `ld XIY,0x00F81E79` +
;           `ld BC,0x0003` + service 0x06, and the three ROM bytes at 0xF81E79 are
;           `45 4E 44` = `END` (checked by --selftest).  The other arm calls
;           LCD_ClearLayer2_32Cols10Rows three times, with IY = 0x0821, 0x0F29 and
;           0x1631.  Which arm runs is decided by (0x1075) and (0x1076) both being
;           non-zero; what those two counters COUNT is not established.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_DrawEndOrClear:
	cp	(0x1075:16), 0x00                            ; F81E17  c1 75 10 3f 00
	jr z, .LF81E51                                       ; F81E1C  66 33
	ld XIX,0x00000820                                    ; F81E1E  44 20 08 00 00
	xor WA,WA                                            ; F81E23  d8 d0
	ld a, (0x1075:16)                                   ; F81E25  c1 75 10 21
	dec 1,WA                                             ; F81E29  d8 69
	muls WA,0x0708                                       ; F81E2B  d8 09 08 07
	add XIX,XWA                                          ; F81E2F  e8 84
	xor XWA,XWA                                          ; F81E31  e8 d0
	ld a, (0x1076:16)                                   ; F81E33  c1 76 10 21
	cp a, 0x00:i3                                          ; F81E37  c9 d8
	jr z, .LF81E51                                       ; F81E39  66 16
	add XIX,XWA                                          ; F81E3B  e8 84
	ld (LCD_CurrentLayer:16), 0x02                                 ; F81E3D  f1 40 25 00 02
	ld XIY,Str_End                                       ; F81E42  45 79 1e f8 00
	ldw bc, 0x03                                         ; F81E47  31 03 00
	xor HL,HL                                            ; F81E4A  db d3
	ld a, 0x06:opc                                          ; F81E4C  21 06
	swi 7                                                ; F81E4E  ff
	jr .LF81E69                                          ; F81E4F  68 18
.LF81E51:
	ld XIY,0x00000821                                    ; F81E51  45 21 08 00 00
	calr LCD_ClearLayer2_32Cols10Rows                                      ; F81E56  1e 11 00
	ld XIY,0x00000f29                                    ; F81E59  45 29 0f 00 00
	calr LCD_ClearLayer2_32Cols10Rows                                      ; F81E5E  1e 09 00
	ld XIY,0x00001631                                    ; F81E61  45 31 16 00 00
	calr LCD_ClearLayer2_32Cols10Rows                                      ; F81E66  1e 01 00
.LF81E69:
	ret                                                  ; F81E69  0e
; ---------------------------------------------------------------------
; LCD_ClearLayer2_32Cols10Rows -- zero a 32-column by 10-row block of layer 2 at the caller's IY
;
; Called from: prom_a LCD_DrawEndOrClear (`calr`) at 0xF81E56, 0xF81E5E, 0xF81E66
; Issues:  SWI7 service 0x0E at 0xF81E77 -- LCD_Svc_0E_ClearColumns, zero BC columns x HL bytes at IY in the current layer
; Evidence: `ld (0x2540),0x02`, `ld BC,0x0020`, `ld HL,0x000A`, service 0x0E.  IY is NOT
;           loaded anywhere in the body, so the block's position is the caller's and
;           only its SIZE is fixed here: 32 byte-columns = 256 pixels wide, 10 rows.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_ClearLayer2_32Cols10Rows:
	ld (LCD_CurrentLayer:16), 0x02                                 ; F81E6A  f1 40 25 00 02
	ldw bc, 0x20                                         ; F81E6F  31 20 00
	ldw hl, 0x0a                                         ; F81E72  33 0a 00
	ld a, 0x0e:opc                                          ; F81E75  21 0e
	swi 7                                                ; F81E77  ff
	ret                                                  ; F81E78  0e
; Str_End -- three characters for LCD service 6: the reader at 0xF81E42 loads it into XIY with BC = 3 and
;          `swi 7`.  Was decoded as `ld XIY,0x0e0e444e`, swallowing the two `ret`s after it.
Str_End:	.ascii	"END"	; F81E79
; LCD_ClearLayer2_32Cols10Rows_Nop -- a bare `ret`, the target of prom_b's veneer at 0xF7D009
LCD_ClearLayer2_32Cols10Rows_Nop:
	ret                                                  ; F81E7C  0e
	ret                                                  ; F81E7D  0e
sub_F81E7E:
	cp	(UI_ScreenId:16), 0x0e                            ; F81E7E  c1 7c 20 3f 0e
	jr nz, .LF81EEE                                      ; F81E83  6e 69
	or	(0xc6:8), 0x01                               ; F81E85  c0 c6 3e 01
	ld (LCD_CurrentLayer:16), 0x01                                 ; F81E89  f1 40 25 00 01
	ld XIY,DL_F3DA6F                                     ; F81E8E  45 6f da f3 00
	ld XIX,Data_F3DA77                                   ; F81E93  44 77 da f3 00
	call T_DisplayList_Run                               ; F81E98  1d f0 17 f4
	ld a, (0x0e63:16)                                   ; F81E9C  c1 63 0e 21
	cp a, 0x00:i3                                          ; F81EA0  c9 d8
	jr nz, .LF81EB9                                      ; F81EA2  6e 15
	pushw wa                                             ; F81EA4  28
	ld a, (0x1009:16)                                   ; F81EA5  c1 09 10 21
	ld (DisplayListB_Stage+10:16), a                                   ; F81EA9  f1 00 13 41
	popw wa                                              ; F81EAD  48
	ld XIY,Data_F3DAA2                                   ; F81EAE  45 a2 da f3 00
	call T_DLB_Handler_Array8                                        ; F81EB3  1d 1c 18 f4
	jr .LF81EEE                                          ; F81EB7  68 35
.LF81EB9:
	cp a, 0x01:i3                                          ; F81EB9  c9 d9
	jr nz, .LF81ED7                                      ; F81EBB  6e 1a
.LF81EBD:
	cp	(0x12a7:16), 0x00                            ; F81EBD  c1 a7 12 3f 00
	jr z, .LF81EEE                                       ; F81EC2  66 2a
	ld a, (0x12a7:16)                                   ; F81EC4  c1 a7 12 21
	ld (DisplayListB_Stage+8:16), a                                   ; F81EC8  f1 fe 12 41
	ld XIY,Data_F3DAED                                   ; F81ECC  45 ed da f3 00
	call T_DLB_Handler_Array8                                        ; F81ED1  1d 1c 18 f4
	jr .LF81EEE                                          ; F81ED5  68 17
.LF81ED7:
	cp a, 0x02:i3                                          ; F81ED7  c9 da
	jr z, .LF81EBD                                       ; F81ED9  66 e2
	pushw wa                                             ; F81EDB  28
	ld a, (0x106c:16)                                   ; F81EDC  c1 6c 10 21
	ld (DisplayListB_Stage+13:16), a                                   ; F81EE0  f1 03 13 41
	popw wa                                              ; F81EE4  48
	ld XIY,Data_F3DA77                                   ; F81EE5  45 77 da f3 00
	call T_DLB_Handler_Array8                                        ; F81EEA  1d 1c 18 f4
.LF81EEE:
	and	(0xc6:8), 0xfe                               ; F81EEE  c0 c6 3c fe
	ret                                                  ; F81EF2  0e
sub_F81EF3:
	ld c, (0x0f65:16)                                   ; F81EF3  c1 65 0f 23
	cp	c, (0x0f66:16)                               ; F81EF7  c1 66 0f f3
	jr nc, .LF81F01                                      ; F81EFB  6f 04
	ld c, (0x0f66:16)                                   ; F81EFD  c1 66 0f 23
.LF81F01:
	cp c, 0x04:i3                                          ; F81F01  cb dc
	jr ule, .LF81F08                                     ; F81F03  63 03
	ldw bc, 0x04                                         ; F81F05  31 04 00
.LF81F08:
	ld XIY,DL_F3D1B9                                     ; F81F08  45 b9 d1 f3 00
	ld XIX,XIY                                           ; F81F0D  ed 8c
	muls BC,0x0023                                       ; F81F0F  d9 09 23 00
	add XIX,XBC                                          ; F81F13  e9 84
	call T_DisplayList_Run                               ; F81F15  1d f0 17 f4
	ret                                                  ; F81F19  0e
sub_F81F1A:
	ld XIY,0x00f3d245                                    ; F81F1A  45 45 d2 f3 00
	cp bc, 0x01:i3                                         ; F81F1F  d9 d9
	jr ge, .LF81F2D                                      ; F81F21  69 0a
	ld a, (0x0f64:16)                                   ; F81F23  c1 64 0f 21
	cp a, 0x00:i3                                          ; F81F27  c9 d8
	jr nz, .LF81F51                                      ; F81F29  6e 26
	jr .LF81F65                                          ; F81F2B  68 38
.LF81F2D:
	cp bc, 0x02:i3                                         ; F81F2D  d9 da
	jr ge, .LF81F41                                      ; F81F2F  69 10
	add XIY,0x0000005a                                   ; F81F31  ed c8 5a 00 00 00
	ld a, (0x0f65:16)                                   ; F81F37  c1 65 0f 21
	cp a, 0x00:i3                                          ; F81F3B  c9 d8
	jr nz, .LF81F51                                      ; F81F3D  6e 12
; (sub_F81F3F removed 2026-10-04: no code names it and the line above falls through into it -- part of sub_F81F1A;
;  notes/prom_a_stray_label_removal.py)
	jr .LF81F65                                          ; F81F3F  68 24
.LF81F41:
	add XIY,0x000000b4                                   ; F81F41  ed c8 b4 00 00 00
	ld a, (0x0f66:16)                                   ; F81F47  c1 66 0f 21
	cp a, 0x00:i3                                          ; F81F4B  c9 d8
	jr nz, .LF81F51                                      ; F81F4D  6e 02
	jr .LF81F65                                          ; F81F4F  68 14
.LF81F51:
	ld XIX,XIY                                           ; F81F51  ed 8c
	add XIX,0x0000000a                                   ; F81F53  ec c8 0a 00 00 00
	xor W,W                                              ; F81F59  c8 d0
	muls WA,0x0014                                       ; F81F5B  d8 09 14 00
	add XIX,XWA                                          ; F81F5F  e8 84
	call T_DisplayList_Run                               ; F81F61  1d f0 17 f4
.LF81F65:
	ret                                                  ; F81F65  0e

; 0xF81F66-0xF81FFF -- 154 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 154, 1, 0x0E
