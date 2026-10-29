
; DebugMonitor_PhaseVector: the boot phase vector of module 17 -- ModuleInitDirectory_F82641 reaches it; the walker calls slot k (4 bytes)
;   for boot phase k (notes/prom_a_module_boot_phase_names.py).  2026-10-04.
DebugMonitor_PhaseVector:
	jp DebugMonitor_BootPhase0                                        ; F94C00  1b 18 4c f9
	ret                                                  ; F94C04  0e
	nop                                                  ; F94C05  00
	nop                                                  ; F94C06  00
	nop                                                  ; F94C07  00
	ret                                                  ; F94C08  0e
	nop                                                  ; F94C09  00
	nop                                                  ; F94C0A  00
	nop                                                  ; F94C0B  00
	ret                                                  ; F94C0C  0e
	nop                                                  ; F94C0D  00
	nop                                                  ; F94C0E  00
	nop                                                  ; F94C0F  00
	ret                                                  ; F94C10  0e
	nop                                                  ; F94C11  00
	nop                                                  ; F94C12  00
	nop                                                  ; F94C13  00
	ret                                                  ; F94C14  0e
	nop                                                  ; F94C15  00
	nop                                                  ; F94C16  00
	nop                                                  ; F94C17  00
; DebugMonitor_BootPhase0: module 17's boot phase 0 handler (vector 0xF94C00, the Print_DebugMonitor / DebugMonitor_* block):
;   (0x284F) = 0, (0x2846) = 0x2420.
DebugMonitor_BootPhase0:
	ld XWA,0x00000000                                    ; F94C18  40 00 00 00 00
	ld (0x284f:16), xwa                                 ; F94C1D  f1 4f 28 60
	ld XWA,0x00002420                                    ; F94C21  40 20 24 00 00
	ld (0x2846:16), xwa                                 ; F94C26  f1 46 28 60
	ret                                                  ; F94C2A  0e
; ---------------------------------------------------------------------
; LCD_BlankThenSetPanel2Layer -- blank the panel and re-issue SYSTEM SET for TWO layers
;
; Called from: prom_a Paint_GateArrayCheck (`call`) at 0xF95745
;          prom_a Paint_PanelCpuCheck (`call`) at 0xF95772
;          prom_a Paint_SineWaveCheckMode (`call`) at 0xF957FF
;          prom_a Paint_PanelSwLedCheck (`call`) at 0xF9599A
;          prom_a ScreenEnter_DebugMonitor (`call`) at 0xF959D1
; Issues:  SWI7 service 0x0C at 0xF94C33 -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Issues:  SWI7 service 0x0F at 0xF94C36 -- service 0x0F, not in this file's table
; Evidence: `xor C,C` + service 0x0C blanks; service 0x0F follows.  0x0F is the
;           TWO-layer SYSTEM SET and 0x10 the three-layer one, which is the whole
;           difference between this routine and LCD_ScreenRedraw_Begin -- the pair is
;           why the layer count belongs in both names.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_BlankThenSetPanel2Layer:
	push XIZ                                             ; F94C2B  3e
	push XIX                                             ; F94C2C  3c
	push XHL                                             ; F94C2D  3b
	push XDE                                             ; F94C2E  3a
	xor C,C                                              ; F94C2F  cb d3
	ld a, 0x0c:opc                                          ; F94C31  21 0c
	swi 7                                                ; F94C33  ff
	ld a, 0x0f:opc                                          ; F94C34  21 0f
	swi 7                                                ; F94C36  ff
	pop XDE                                              ; F94C37  5a
	pop XHL                                              ; F94C38  5b
	pop XIX                                              ; F94C39  5c
	pop XIZ                                              ; F94C3A  5e
	ret                                                  ; F94C3B  0e
; ---------------------------------------------------------------------
; LCD_ShowLayers1And2_StackFrame -- service 0x0C with C = 3, from inside a stack frame
;
; Called from: prom_a Paint_GateArrayCheck (`call`) at 0xF9575E
;          prom_a Paint_PanelCpuCheck (`call`) at 0xF9578B
;          prom_a Paint_SineWaveCheckMode (`call`) at 0xF95884
;          prom_a Paint_PanelSwLedCheck (`call`) at 0xF959B3
;          prom_a ScreenEnter_DebugMonitor (`call`) at 0xF959DC
; Issues:  SWI7 service 0x0C at 0xF94C46 -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Evidence: same three instructions as LCD_ShowLayers1And2_SaveRegs (`ld C,0x03`,
;           service 0x0C) but preceded by `push XIZ` + `ld XIZ,XSP`, so it builds a
;           frame the other one does not.  The two are NOT byte-identical and are not
;           named as copies of each other.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_ShowLayers1And2_StackFrame:
	push XIZ                                             ; F94C3C  3e
	ld XIZ,XSP                                           ; F94C3D  ef 8e
	push XIX                                             ; F94C3F  3c
	push XHL                                             ; F94C40  3b
	push XDE                                             ; F94C41  3a
	ld c, 0x03:opc                                          ; F94C42  23 03
	ld a, 0x0c:opc                                          ; F94C44  21 0c
	swi 7                                                ; F94C46  ff
	pop XDE                                              ; F94C47  5a
	pop XHL                                              ; F94C48  5b
	pop XIX                                              ; F94C49  5c
	pop XIZ                                              ; F94C4A  5e
	ret                                                  ; F94C4B  0e
; ---------------------------------------------------------------------
; Print_DebugMonitor -- prints the line ` --- DEBUG MONITOR BY (c)masa,toshi --- `
;
; Called from: prom_a DebugMonitor_PrintDumpPage (`call`) at 0xF95C46
;
;     0xF94C59 loads 0xF94C67, where the ROM reads:
;        " --- DEBUG MONITOR BY (c)masa,toshi --- ><;:D"
; Evidence: the immediate at the cited instruction, and the bytes
;          at that address in original_ROMs/, read as printable
;          ASCII until the first non-printable byte.
;          ★ THE LENGTH IS THE PROOF, not the reader's eye.  The routine first
;            zeroes the row cursor (0x284F) and then calls
;            LCD_PrintLine40_AdvanceRow, whose own header records BC = 0x28 = 40
;            characters per line.  The printable run at 0xF94C67 is 45 bytes, and
;            its first 40 are exactly ` --- DEBUG MONITOR BY (c)masa,toshi --- `;
;            the five that follow (`><;:D`) are the next object, not this line.
;            So this routine draws the FIRST line of a debug screen, and the
;            machine's own firmware names that screen DEBUG MONITOR.
;          ⚠ NOT CLAIMED: how the monitor is entered, what else it prints, or that
;            `masa,toshi` are the authors of anything beyond this string.
;          ⚠ 0xF94C67-0xF94C8E, the 40 bytes the printer draws, is TEXT that
;            this listing still decodes as instructions (`ldb w,0x2d` ...).  The
;            bytes are right and the gate is green either way; the decode is
;            misleading and is left for a round that owns the data/code split.
; Recorded by notes/prom_a_understanding_round7.py --apply-strings.
; ---------------------------------------------------------------------
Print_DebugMonitor:
	push XIZ                                             ; F94C4C  3e
	push XIX                                             ; F94C4D  3c
	push XHL                                             ; F94C4E  3b
	push XDE                                             ; F94C4F  3a
	ld XWA,0x00000000                                    ; F94C50  40 00 00 00 00
	ld (0x284f:16), xwa                                 ; F94C55  f1 4f 28 60
	ld XIY,Str_DebugMonitorTitle                                    ; F94C59  45 67 4c f9 00
	call LCD_PrintLine40_AdvanceRow                                      ; F94C5E  1d 82 4d f9
	pop XDE                                              ; F94C62  5a
	pop XHL                                              ; F94C63  5b
	pop XIX                                              ; F94C64  5c
	pop XIZ                                              ; F94C65  5e
	ret                                                  ; F94C66  0e
Str_DebugMonitorTitle:	.ascii " --- DEBUG MONITOR BY (c)masa,toshi --- "	; F94C67  the DEBUG MONITOR's 40-character title line; masa and toshi are the programmers
; DebugMonitor_PrintBlankLine -- fill the 40-character line buffer at 0x60A000 with spaces (20 x 0x2020) and print it
; with LCD_PrintLine40_AdvanceRow.  Entered three times by DebugMonitor_PrintDumpPage's `jp (xix)`; was
; hidden by the title text above being decoded as instructions (it ran into this routine's first byte).
DebugMonitor_PrintBlankLine:
	push XIZ                                             ; F94C8F  3e
	push XIX                                             ; F94C90  3c
	push XHL                                             ; F94C91  3b
	push XDE                                             ; F94C92  3a
	ld XIX,0x0060a000                                    ; F94C93  44 00 a0 60 00
	ldw bc, 0x14                                         ; F94C98  31 14 00
	ldw wa, 0x2020                                       ; F94C9B  30 20 20
.LF94C9E:
	push C                                               ; F94C9E  cb 04
	sla c, 0x01                                          ; F94CA0  cb ec 01
	ld	(xix+c), wa                                  ; F94CA3  f3 03 f0 e4 50
	pop C                                                ; F94CA8  cb 05
	djnz16 bc, .LF94C9E                                  ; F94CAA  d9 1c f1
	ld XIY,0x0060a000                                    ; F94CAD  45 00 a0 60 00
	call LCD_PrintLine40_AdvanceRow                                      ; F94CB2  1d 82 4d f9
	pop XDE                                              ; F94CB6  5a
	pop XHL                                              ; F94CB7  5b
	pop XIX                                              ; F94CB8  5c
; (sub_F94CB9 removed 2026-10-04: no code names it and the line above falls through into it -- part of DebugMonitor_PrintBlankLine;
;  notes/prom_a_stray_label_removal.py)
	pop XIZ                                              ; F94CB9  5e
	ret                                                  ; F94CBA  0e
; DebugMonitor_PrintHexDump -- print 16 hex-dump lines (128 bytes) starting at (0x2846)
; Evidence: (0x284A) = (0x2846), then DE = 0x10 iterations of DebugMonitor_PrintHexDumpLine and `add (0x284A),8`.  Only caller DebugMonitor_PrintDumpPage (0xF95C52), the
; DEBUG MONITOR screen's painter, which also calls Print_DebugMonitor.
DebugMonitor_PrintHexDump:
	push XIZ                                             ; F94CBB  3e
	push XIX                                             ; F94CBC  3c
	push XHL                                             ; F94CBD  3b
	push XDE                                             ; F94CBE  3a
	ld xwa, (0x2846:16)                                 ; F94CBF  e1 46 28 20
	ld (0x284a:16), xwa                                 ; F94CC3  f1 4a 28 60
	ldw de, 0x10                                         ; F94CC7  32 10 00
.LF94CCA:
	pushw de                                             ; F94CCA  2a
	call DebugMonitor_PrintHexDumpLine                                      ; F94CCB  1d de 4c f9
	popw de                                              ; F94CCF  4a
	addw	(0x284a:16), 0x0008                          ; F94CD0  d1 4a 28 38 08 00
	djnz16 de, -15                                       ; F94CD6  da 1c f1
	pop XDE                                              ; F94CD9  5a
	pop XHL                                              ; F94CDA  5b
	pop XIX                                              ; F94CDB  5c
	pop XIZ                                              ; F94CDC  5e
	ret                                                  ; F94CDD  0e
; DebugMonitor_PrintHexDumpLine -- print one dump line: the 32-bit address (0x284A) in hex and the 8 bytes stored there
; Evidence: builds the line at 0x60A000: four spaces, 8 hex digits of (0x284A) (high word then low, nibble shifts and DebugMonitor_NibbleToHexChar), two spaces,
; 8 x "HH " from the bytes at (0x284A), then LCD_PrintLine40_AdvanceRow.  Only caller DebugMonitor_PrintHexDump.
DebugMonitor_PrintHexDumpLine:
	ld XIX,0x0060a000                                    ; F94CDE  44 00 a0 60 00
.LF94CE3:
	ldw wa, 0x2020                                       ; F94CE3  30 20 20
	ld (XIX),WA                                          ; F94CE6  b4 50
	inc 2,XIX                                            ; F94CE8  ec 62
	ld (XIX),WA                                          ; F94CEA  b4 50
	inc 2,XIX                                            ; F94CEC  ec 62
	ld a, 0x10:opc                                          ; F94CEE  21 10
.LF94CF0:
	sub A,0x04                                           ; F94CF0  c9 ca 04
.LF94CF3:
	ld xhl, (0x284a:16)                                 ; F94CF3  e1 4a 28 23
	srl xhl, 16                                        ; F94CF7  eb ef 00
	cp a, 0x00:i3                                          ; F94CFA  c9 d8
	jr z, .LF94D00                                           ; F94CFC  66 02
	.byte 0xeb, 0xff                                     ; F94CFE  eb ff   srl A,XHL
.LF94D00:
	call DebugMonitor_NibbleToHexChar                                      ; F94D00  1d 73 4d f9
	ld (XIX),L                                           ; F94D04  b4 47
	inc 1,XIX                                            ; F94D06  ec 61
	cp a, 0x00:i3                                          ; F94D08  c9 d8
	jr nz, .LF94CF0                                           ; F94D0A  6e e4
	ld a, 0x10:opc                                          ; F94D0C  21 10
.LF94D0E:
	sub A,0x04                                           ; F94D0E  c9 ca 04
	ld xhl, (0x284a:16)                                 ; F94D11  e1 4a 28 23
	cp a, 0x00:i3                                          ; F94D15  c9 d8
	jr z, .LF94D1B                                           ; F94D17  66 02
	.byte 0xeb, 0xff                                     ; F94D19  eb ff   srl A,XHL
.LF94D1B:
	call DebugMonitor_NibbleToHexChar                                      ; F94D1B  1d 73 4d f9
	ld (XIX),L                                           ; F94D1F  b4 47
	inc 1,XIX                                            ; F94D21  ec 61
	cp a, 0x00:i3                                          ; F94D23  c9 d8
	jr nz, .LF94D0E                                           ; F94D25  6e e7
	ldw wa, 0x2020                                       ; F94D27  30 20 20
	ld (XIX),WA                                          ; F94D2A  b4 50
	inc 2,XIX                                            ; F94D2C  ec 62
	ld XWA,0x0000284a                                    ; F94D2E  40 4a 28 00 00
	ld XIY,XWA                                           ; F94D33  e8 8d
	ld XDE,(XIY)                                         ; F94D35  a5 22
	ldw bc, 0x08                                         ; F94D37  31 08 00
.LF94D3A:
	ld HL,(XDE)                                          ; F94D3A  92 23
	ld H,L                                               ; F94D3C  cf 8e
	srl l, 0x04                                          ; F94D3E  cf ef 04
	call DebugMonitor_NibbleToHexChar                                      ; F94D41  1d 73 4d f9
	ld (XIX),L                                           ; F94D45  b4 47
	inc 1,XIX                                            ; F94D47  ec 61
	ld L,H                                               ; F94D49  ce 8f
	call DebugMonitor_NibbleToHexChar                                      ; F94D4B  1d 73 4d f9
	ld (XIX),L                                           ; F94D4F  b4 47
	inc 1,XIX                                            ; F94D51  ec 61
	ld l, 0x20:opc                                          ; F94D53  27 20
	ld (XIX),L                                           ; F94D55  b4 47
	inc 1,XDE                                            ; F94D57  ea 61
	inc 1,XIX                                            ; F94D59  ec 61
	djnz16 bc, -36                                       ; F94D5B  d9 1c dc
	ldw wa, 0x2020                                       ; F94D5E  30 20 20
	ld (XIX),WA                                          ; F94D61  b4 50
	inc 2,XIX                                            ; F94D63  ec 62
	ld (XIX),A                                           ; F94D65  b4 41
	inc 1,XIX                                            ; F94D67  ec 61
	ld XIY,0x0060a000                                    ; F94D69  45 00 a0 60 00
	call LCD_PrintLine40_AdvanceRow                                      ; F94D6E  1d 82 4d f9
	ret                                                  ; F94D72  0e
; DebugMonitor_NibbleToHexChar -- L := the ASCII hex digit of L's low nibble
; Evidence: `and L,0x0F / add L,0x30 / cp L,0x39 / jr ule / add L,7`.  Called four times by DebugMonitor_PrintHexDumpLine.
DebugMonitor_NibbleToHexChar:
	and L,0x0f                                           ; F94D73  cf cc 0f
	add L,0x30                                           ; F94D76  cf c8 30
	cp L,0x39                                            ; F94D79  cf cf 39
	jr ule, .LF94D81                                         ; F94D7C  63 03
	add L,0x07                                           ; F94D7E  cf c8 07
.LF94D81:
	ret                                                  ; F94D81  0e
; ---------------------------------------------------------------------
; LCD_PrintLine40_AdvanceRow -- draw a 40-character line at the cursor and advance the cursor one row
;
; Called from: prom_a Print_DebugMonitor (`call`) at 0xF94C5E, 0xF94CB2
;          prom_a DebugMonitor_PrintHexDumpLine (`call`) at 0xF94D6E
; Issues:  SWI7 service 0x06 at 0xF94D91 -- LCD_Svc_06_DrawText8x14, draw 8x14 text
; Evidence: `ld HL,0x0000` + `ld BC,0x0028` + `ld IX,(0x284F)` + service 0x06, then
;           `add (0x284F),0x01B8`.  BC = 40 characters; the cursor is the RAM word
;           (0x284F); and 0x01B8 = 440 = 11 x 40, i.e. eleven scan lines at AP = 40,
;           the height of one 8x14 row plus leading.  XIY, the string, is the
;           caller's.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_PrintLine40_AdvanceRow:
	push XIZ                                             ; F94D82  3e
	push XIX                                             ; F94D83  3c
	push XHL                                             ; F94D84  3b
	push XDE                                             ; F94D85  3a
	xor XHL,XHL                                          ; F94D86  eb d3
	ldw bc, 0x28                                         ; F94D88  31 28 00
	ld ix, (0x284f:16)                                 ; F94D8B  d1 4f 28 24
	ld a, 0x06:opc                                          ; F94D8F  21 06
	swi 7                                                ; F94D91  ff
	addw	(0x284f:16), 0x01b8                          ; F94D92  d1 4f 28 38 b8 01
	pop XDE                                              ; F94D98  5a
	pop XHL                                              ; F94D99  5b
	pop XIX                                              ; F94D9A  5c
	pop XIZ                                              ; F94D9B  5e
	ret                                                  ; F94D9C  0e
; DebugMonitor_StepHexDigit -- step the hex digit at 0x60A000 by the encoded delta at 0x60A001, clamped to 0..0x0F
; Evidence: A = (0x60A000), W = (0x60A001), B = 0x0F, C = 0, T_Value_ApplyNibbleDeltaClamped (sub_F8BD73: A + SignedNibbleDelta_Table[...], clamped to C..B), A back to 0x60A000.
; Callers: the six SoftKeyColN_DebugMonitor handlers, which load W = 0x81 (-1) or 0x01 (+1).
DebugMonitor_StepHexDigit:
	push XIZ                                             ; F94D9D  3e
	push XIX                                             ; F94D9E  3c
	push XHL                                             ; F94D9F  3b
	push XDE                                             ; F94DA0  3a
	ld a, (0x60a000:24)                                 ; F94DA1  c2 00 a0 60 21
	ld w, (0x60a001:24)                                 ; F94DA6  c2 01 a0 60 20
	ld b, 0x0f:opc                                          ; F94DAB  22 0f
	ld c, 0x00:opc                                          ; F94DAD  23 00
	call T_Value_ApplyNibbleDeltaClamped                                        ; F94DAF  1d 04 1b f4
	ld (0x60a000:24), a                                 ; F94DB3  f2 00 a0 60 41
	pop XDE                                              ; F94DB8  5a
	pop XHL                                              ; F94DB9  5b
	pop XIX                                              ; F94DBA  5c
	pop XIZ                                              ; F94DBB  5e
	ret                                                  ; F94DBC  0e
; ---------------------------------------------------------------------
; LCD_FlashWholePanel -- blank, fill the whole panel, show it, blank again
;
; Called from: prom_a TestMode_DisplayCycleTick (`call`) at 0xF95603, 0xF95607
; Issues:  SWI7 service 0x0C at 0xF94DC5 -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Issues:  SWI7 service 0x05 at 0xF94DE0 -- LCD_Svc_05_FillRect, fill the rectangle in (0x2530..0x2536)
; Issues:  SWI7 service 0x0C at 0xF94DE5 -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Issues:  SWI7 service 0x0C at 0xF94DEE -- LCD_Svc_0C_SetLayersOn, rebuild DISP ON: C bits 0/1/2 = layers 1/2/3 steady on
; Evidence: the four coordinate words are written as immediates -- (0x2530)=0,
;           (0x2532)=0, (0x2534)=0x013F, (0x2536)=0x00EF -- which is exactly the
;           320x240 panel SYSTEM SET programs, so the service-0x05 fill covers all of
;           it.  It is bracketed by service 0x0C with C = 0, then C = 7, then C = 0,
;           with Delay_SpinNestedLoops called after each of the last two.
; Named by notes/prom_a_understanding_round6.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
LCD_FlashWholePanel:
	push XIZ                                             ; F94DBD  3e
	push XIX                                             ; F94DBE  3c
	push XHL                                             ; F94DBF  3b
	push XDE                                             ; F94DC0  3a
	ld c, 0x00:opc                                          ; F94DC1  23 00
	ld a, 0x0c:opc                                          ; F94DC3  21 0c
	swi 7                                                ; F94DC5  ff
	ldw (LCD_X0:16), 0x00                                ; F94DC6  f1 30 25 02 00 00
	ldw (LCD_Y0:16), 0x00                                ; F94DCC  f1 32 25 02 00 00
	ldw (LCD_X1:16), 0x013f                              ; F94DD2  f1 34 25 02 3f 01
	ldw (LCD_Y1:16), 0xef                                ; F94DD8  f1 36 25 02 ef 00
	ld a, 0x05:opc                                          ; F94DDE  21 05
	swi 7                                                ; F94DE0  ff
	ld c, 0x07:opc                                          ; F94DE1  23 07
	ld a, 0x0c:opc                                          ; F94DE3  21 0c
	swi 7                                                ; F94DE5  ff
	call Delay_SpinNestedLoops                                      ; F94DE6  1d 28 51 f9
	ld c, 0x00:opc                                          ; F94DEA  23 00
	ld a, 0x0c:opc                                          ; F94DEC  21 0c
	swi 7                                                ; F94DEE  ff
	call Delay_SpinNestedLoops                                      ; F94DEF  1d 28 51 f9
	pop XDE                                              ; F94DF3  5a
	pop XHL                                              ; F94DF4  5b
	pop XIX                                              ; F94DF5  5c
	pop XIZ                                              ; F94DF6  5e
	ret                                                  ; F94DF7  0e
; PanelCpuCheck_ReadStatus -- read the panel CPU's status byte over SC1 into 0x60A000
; Evidence: `call T_F40F20` (prom_b SC1_Entry_F40F20 = `calr SC1_Cmd_E0_ReadStatus / ret`), then `ld (0x60A000),A`.  Only caller
; PanelCpuCheck_FlashStatusOnLed.
PanelCpuCheck_ReadStatus:
	push XIZ                                             ; F94DF8  3e
	push XIX                                             ; F94DF9  3c
	push XHL                                             ; F94DFA  3b
	push XDE                                             ; F94DFB  3a
	call T_F40F20                                        ; F94DFC  1d 20 0f f4
	ld (0x60a000:24), a                                 ; F94E00  f2 00 a0 60 41
	pop XDE                                              ; F94E05  5a
	pop XHL                                              ; F94E06  5b
	pop XIX                                              ; F94E07  5c
	pop XIZ                                              ; F94E08  5e
	ret                                                  ; F94E09  0e
; TestMode_SendStagedLed -- send the LED byte staged at 0x60A000 for the LED group staged at 0x60A001 to the panel
; Evidence: `ld WA,(0x60A000)` then T_PanelLed_SendByteUnconditional -> sub_F8C846, which TestMode_PanelSwitchesToLeds's header records as queueing (PanelLedWireMap[W], A)
; to the panel.  Callers: PanelSwLedCheck_AllLedsOn, PanelSwLedCheck_AllLedsOff.
TestMode_SendStagedLed:
	push XIZ                                             ; F94E0A  3e
	push XIX                                             ; F94E0B  3c
	push XHL                                             ; F94E0C  3b
	push XDE                                             ; F94E0D  3a
	ld wa, (0x60a000:24)                                ; F94E0E  d2 00 a0 60 20
	call T_PanelLed_SendByteUnconditional                                        ; F94E13  1d 70 06 f4
	pop XDE                                              ; F94E17  5a
	pop XHL                                              ; F94E18  5b
	pop XIX                                              ; F94E19  5c
	pop XIZ                                              ; F94E1A  5e
	ret                                                  ; F94E1B  0e
; ---------------------------------------------------------------------
; TestMode_PanelSwitchesToLeds -- the service test mode's switch echo: every
; switch packet waiting in the panel queue at RAM 0x2B40 lights one LED.
; Called from: PanelSwLedCheck_Step at 0xF956A6 (when (0x207B) == (0x207A)).
; Per packet (wire byte, then mask byte, read from the ring whose descriptor
; is at XIZ = 0x2B40: index +6 advances to +4, wraps past +2 back to +0, and
; the byte at +8 is incremented per byte taken): W = the wire's group
; through TestMode_PanelWireGroupMap_Variant1/2 (by the strap (0xC4)), skip if
; 0x20; WA = TestMode_SwitchLedCodes_*[W][BitMask_LowestSetBitOrdinal(mask)-1];
; call T_PanelLed_SendByteUnconditional (-> PanelLed_SendByteUnconditional, which queues (PanelLedWireMap[W], A) to the
; panel).  Stops when +6 reaches +4, and stores the index back at +6.
; Evidence: the instructions below, 0xF94E20-0xF94ED7; the table layouts are
; checked by notes/proma-2026-09-25/gen_panel_test_tables.py.
; ---------------------------------------------------------------------
TestMode_PanelSwitchesToLeds:
	push XIZ                                             ; F94E1C  3e
	push XIX                                             ; F94E1D  3c
	push XHL                                             ; F94E1E  3b
	push XDE                                             ; F94E1F  3a
	ld XIZ,SC1_InQueue                                    ; F94E20  46 40 2b 00 00
	ld IX,(XIZ+0x06)                                     ; F94E25  9e 06 24
TestMode_PanelSwitchesToLeds_Loop:
	cp IX,(XIZ+0x04)                                     ; F94E28  9e 04 f4
	jrl z, .LF94ED0                                          ; F94E2B  76 a2 00
	ld	a, (xiz+ix)                                  ; F94E2E  c3 07 f8 f0 21
	ld L,A                                               ; F94E33  c9 8f
	and L,0x1f                                           ; F94E35  cf cc 1f
	and A,0xc0                                           ; F94E38  c9 cc c0
	srl a, 0x01                                          ; F94E3B  c9 ef 01
	or L,A                                               ; F94E3E  c9 e7
	xor H,H                                              ; F94E40  ce d6
	ld XIY,TestMode_PanelWireGroupMap_Variant1           ; F94E42  45 d8 4e f9 00
	cp	(Variant_Flag:8), 0x01                               ; F94E47  c0 c4 3f 01
	jr z, .LF94E52                                           ; F94E4B  66 05
	ld XIY,TestMode_PanelWireGroupMap_Variant2           ; F94E4D  45 08 50 f9 00
.LF94E52:
	ld	w, (xiy+hl)                                  ; F94E52  c3 07 f4 ec 20
	inc 1,IX                                             ; F94E57  dc 61
	incm8 0x01, (xiz+0x08)                               ; F94E59  8e 08 61
	cp IX,(XIZ+0x02)                                     ; F94E5C  9e 02 f4
	jr ule, .LF94E64                                         ; F94E5F  63 03
	ld	ix, (xiz+0:8)                                ; F94E61  9e 00 24
.LF94E64:
	ld	c, (xiz+ix)                                  ; F94E64  c3 07 f8 f0 23
	inc 1,IX                                             ; F94E69  dc 61
	incm8 0x01, (xiz+0x08)                               ; F94E6B  8e 08 61
	cp IX,(XIZ+0x02)                                     ; F94E6E  9e 02 f4
	jr ule, .LF94E76                                         ; F94E71  63 03
	ld	ix, (xiz+0:8)                                ; F94E73  9e 00 24
.LF94E76:
	ld	a, (xiz+ix)                                  ; F94E76  c3 07 f8 f0 21
	inc 1,IX                                             ; F94E7B  dc 61
	incm8 0x01, (xiz+0x08)                               ; F94E7D  8e 08 61
	cp W,0x20                                            ; F94E80  c8 cf 20
	jr z, .LF94EC3                                           ; F94E83  66 3e
	push XIZ                                             ; F94E85  3e
	pushw ix                                             ; F94E86  2c
	pushw wa                                             ; F94E87  28
	ld XIY,TestMode_SwitchLedCodes_Variant1              ; F94E88  45 58 4f f9 00
	cp	(Variant_Flag:8), 0x01                               ; F94E8D  c0 c4 3f 01
	jr z, .LF94E98                                           ; F94E91  66 05
	ld XIY,TestMode_SwitchLedCodes_Variant2              ; F94E93  45 88 50 f9 00
.LF94E98:
	xor XHL,XHL                                          ; F94E98  eb d3
	ld L,W                                               ; F94E9A  c8 8f
	sll xhl, 0x04                                        ; F94E9C  eb ee 04
	add XHL,XIY                                          ; F94E9F  ed 83
	popw wa                                              ; F94EA1  48
	xor W,W                                              ; F94EA2  c8 d0
	pushw bc                                             ; F94EA4  29
	call BitMask_LowestSetBitOrdinal                                      ; F94EA5  1d 18 51 f9
	popw bc                                              ; F94EA9  49
	cp a, 0x00:i3                                          ; F94EAA  c9 d8
	jr z, .LF94EB0                                           ; F94EAC  66 02
	dec 1,A                                              ; F94EAE  c9 69
.LF94EB0:
	sll a, 0x01                                          ; F94EB0  c9 ee 01
	add HL,WA                                            ; F94EB3  d8 83
	ld WA,(XHL)                                          ; F94EB5  93 20
	cp c, 0x00:i3                                          ; F94EB7  cb d8
	jr nz, .LF94EBD                                          ; F94EB9  6e 02
	xor A,A                                              ; F94EBB  c9 d1
.LF94EBD:
	call T_PanelLed_SendByteUnconditional                                        ; F94EBD  1d 70 06 f4
	popw ix                                              ; F94EC1  4c
	pop XIZ                                              ; F94EC2  5e
.LF94EC3:
	cp IX,(XIZ+0x02)                                     ; F94EC3  9e 02 f4
	jrl ule, TestMode_PanelSwitchesToLeds_Loop                                        ; F94EC6  73 5f ff
	ld	ix, (xiz+0:8)                                ; F94EC9  9e 00 24
	jp TestMode_PanelSwitchesToLeds_Loop                                        ; F94ECC  1b 28 4e f9
.LF94ED0:
	ld (XIZ+0x06),IX                                     ; F94ED0  be 06 54
	pop XDE                                              ; F94ED3  5a
	pop XHL                                              ; F94ED4  5b
	pop XIX                                              ; F94ED5  5c
	pop XIZ                                              ; F94ED6  5e
	ret                                                  ; F94ED7  0e
; ---------------------------------------------------------------------
; THE SERVICE TEST MODE'S SWITCH-TO-LED TABLES, 0xF94ED8-0xF95117 (576 B)
;
; Read by TestMode_PanelSwitchesToLeds, which drains the panel queue at RAM 0x2B40 and, for each
; packet (wire, mask), computes L = (wire & 0x1F) | ((wire & 0xC0) >> 1)
; (0xF94E35-0xF94E3E), W = map[L] (0xF94E42 / 0xF94E4D by the strap (0xC4)),
; skips W == 0x20, then reads the word at rows + 16*W + 2*(A-1) with A =
; BitMask_LowestSetBitOrdinal(mask), 1 + the index of the mask's lowest set bit (0xF94E88-
; 0xF94EB5), and passes it in WA to T_PanelLed_SendByteUnconditional -> PanelLed_SendByteUnconditional (0xF94EBD), which
; queues (PanelLedWireMap[W], A) to the panel: the switch pressed lights one
; LED.  The maps use PanelWireGroupMap_Variant1/2's index function and 0x20
; convention, restricted to the button wires 0xC0-0xCA; the row counts are
; 1 + the largest group each map holds (0x0A -> 11, 0x08 -> 9); the four
; tables tile the span, which ends on BitMask_LowestSetBitOrdinal's first instruction.
; Was framed as code (`ld W,0x20` x64, `push SR / reti` pairs, `normal`,
; `max`, `halt` ...) under an orphan label sub_F94FAE that nothing in either
; image references.  notes/proma-2026-09-25/gen_panel_test_tables.py checks
; the readers' bytes, the tiling and the map values.
; ---------------------------------------------------------------------
TestMode_PanelWireGroupMap_Variant1:
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F94ED8  index 0x00
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F94EE8  index 0x10
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F94EF8  index 0x20
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F94F08  index 0x30
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F94F18  index 0x40
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F94F28  index 0x50
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x20, 0x20, 0x20, 0x20, 0x20  ; F94F38  index 0x60
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F94F48  index 0x70

; TestMode_SwitchLedCodes_Variant1 -- 11 groups x 8 LE16 (hi = LED map index W,
; lo = LED bit mask), one per bit of the switch mask; read at 0xF94E88.
TestMode_SwitchLedCodes_Variant1:
	.short 0x0201, 0x0202, 0x0204, 0x0208, 0x0210, 0x0220, 0x0240, 0x0280  ; F94F58  group 0x00
	.short 0x0101, 0x0102, 0x0104, 0x0108, 0x0110, 0x0120, 0x0140, 0x0180  ; F94F68  group 0x01
	.short 0x0001, 0x0002, 0x0004, 0x0008, 0x0010, 0x0020, 0x0040, 0x0080  ; F94F78  group 0x02
	.short 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702  ; F94F88  group 0x03
	.short 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702  ; F94F98  group 0x04
	.short 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702  ; F94FA8  group 0x05
	.short 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702  ; F94FB8  group 0x06
	.short 0x0401, 0x0402, 0x0404, 0x0408, 0x0410, 0x0420, 0x0440, 0x0480  ; F94FC8  group 0x07
	.short 0x0301, 0x0302, 0x0304, 0x0308, 0x0310, 0x0320, 0x03C0, 0x0000  ; F94FD8  group 0x08
	.short 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702  ; F94FE8  group 0x09
	.short 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702, 0x0702  ; F94FF8  group 0x0A

; TestMode_PanelWireGroupMap_Variant2 -- the (0xC4) != 1 map, read at 0xF94E4D;
; 128 entries, 0x20 = no group.
TestMode_PanelWireGroupMap_Variant2:
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F95008  index 0x00
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F95018  index 0x10
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F95028  index 0x20
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F95038  index 0x30
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F95048  index 0x40
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F95058  index 0x50
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x20, 0x06, 0x07, 0x08, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F95068  index 0x60
	.byte 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20  ; F95078  index 0x70

; TestMode_SwitchLedCodes_Variant2 -- 9 groups x 8 LE16, read at 0xF94E93.
; Rows 6-8 end in 0x0000 words: bits those groups do not have.
TestMode_SwitchLedCodes_Variant2:
	.short 0x0101, 0x0102, 0x0104, 0x0108, 0x0001, 0x0002, 0x0004, 0x0008  ; F95088  group 0x00
	.short 0x0608, 0x0608, 0x0608, 0x0608, 0x0608, 0x0608, 0x0608, 0x0608  ; F95098  group 0x01
	.short 0x0608, 0x0608, 0x0608, 0x0608, 0x0604, 0x0604, 0x0604, 0x0000  ; F950A8  group 0x02
	.short 0x0604, 0x0604, 0x0604, 0x0604, 0x0604, 0x0608, 0x0608, 0x0608  ; F950B8  group 0x03
	.short 0x0604, 0x0604, 0x0604, 0x0604, 0x0604, 0x0604, 0x0604, 0x0604  ; F950C8  group 0x04
	.short 0x0604, 0x0604, 0x0604, 0x0604, 0x0604, 0x0604, 0x0604, 0x0604  ; F950D8  group 0x05
	.short 0x0401, 0x0402, 0x0501, 0x0502, 0x0000, 0x0000, 0x0000, 0x0000  ; F950E8  group 0x06
	.short 0x0303, 0x0203, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000  ; F950F8  group 0x07
	.short 0x0604, 0x0604, 0x0604, 0x0604, 0x0604, 0x0000, 0x0000, 0x0000  ; F95108  group 0x08
; BitMask_LowestSetBitOrdinal -- A = 1 + the index of the lowest set bit of A
; (1 for bit 0 .. 8 for bit 7), or 0 when A is 0.  Shifts right until a 1
; falls into carry, counting in C.  Called from TestMode_PanelSwitchesToLeds.
BitMask_LowestSetBitOrdinal:
	cp a, 0x00:i3                                          ; F95118  c9 d8
	jr z, .LF95127                                           ; F9511A  66 0b
	xor C,C                                              ; F9511C  cb d3
.LF9511E:
	inc 1,C                                              ; F9511E  cb 61
	srl a, 0x01                                          ; F95120  c9 ef 01
	jr nc, .LF9511E                                            ; F95123  6f f9
	ld A,C                                               ; F95125  cb 89
.LF95127:
	ret                                                  ; F95127  0e
; ---------------------------------------------------------------------
; Delay_SpinNestedLoops -- a busy-wait: 0x1000 outer passes of 0x600 inner
;                          decrements, touching no memory
;
; Evidence: the whole routine is 0xF95128 `ldw bc,0x1000`, 0xF9512B `ldw
;           wa,0x0600`, 0xF9512E `dec 1,WA`, and the two `djnz16` at
;           0xF95130 and 0xF95133. It reads and writes nothing. Its two
;           callers include LCD_FlashWholePanel, which is a panel test
; Unknown:  how long that is. It depends on the CPU clock, which this
;           file does not measure
; Was `sub_F95128`, named by notes/prom_a_census_round8.py (bucket round 10).
; ---------------------------------------------------------------------
Delay_SpinNestedLoops:
	ldw bc, 0x1000                                       ; F95128  31 00 10
.LF9512B:
	ldw wa, 0x0600                                       ; F9512B  30 00 06
.LF9512E:
	dec 1,WA                                             ; F9512E  d8 69
	djnz16 wa, -5                                        ; F95130  d8 1c fb
	djnz16 bc, -11                                       ; F95133  d9 1c f5
	ret                                                  ; F95136  0e
; CheckingDevice_RunSelfTest -- the service CHECKING DEVICE power-on test: RAM check then ROM check, each reported as four LED flashes
; Evidence: prom_b slot T_CheckingDevice_RunSelfTest, called once from boot at 0xF827D1.  `ld C,(P5) / and C,0x10` -- returns when P5 bit 4 reads 1 (device switch off);
; else CheckingDevice_RamTest, CheckingDevice_FlashLedNibble(result), Delay_SpinNestedLoopsShort, CheckingDevice_RomIdTest, CheckingDevice_FlashLedNibble(result):
; the manual's "first 4 flashes RAM, latter 4 ROM" (notes/WSA1-EMULATION-DISASM-GAPS.md gap L, FINDINGS-prom_a-ui-screen-blocks.md 5).
CheckingDevice_RunSelfTest:
	ld	c, (P5:8)                                      ; F95137  c0 0d 23
	and C,0x10                                           ; F9513A  cb cc 10
	srl c, 0x04                                          ; F9513D  cb ef 04
	and C,0x01                                           ; F95140  cb cc 01
	jr nz, .LF95157                                          ; F95143  6e 12
	calr CheckingDevice_RamTest                                            ; F95145  1e 90 00
	pushw wa                                             ; F95148  28
	calr CheckingDevice_FlashLedNibble                                            ; F95149  1e 0c 00
	calr Delay_SpinNestedLoopsShort                                            ; F9514C  1e 72 00
	calr CheckingDevice_RomIdTest                                          ; F9514F  1e 35 01
	pushw wa                                             ; F95152  28
	calr CheckingDevice_FlashLedNibble                                            ; F95153  1e 02 00
	pop XIY                                              ; F95156  5d
.LF95157:
	ret                                                  ; F95157  0e
; CheckingDevice_FlashLedNibble -- flash the CHECKING DEVICE LED (P5 bit 3) four times, long for each set bit of the argument, LSB first
; Evidence: E = 4 passes of `res 0,C / ldcf 0,C / stcf 3,(P5)` (bit low), HL = 0xC000 if (XIZ+0x08) bit 0 else 0x4000 times a 0x20 inner loop,
; `set 0,C ... stcf 3,(P5)` (bit high), HL = 0x4000, then `srl (XIZ+0x08)`.  In: word argument on the stack (failure bits).
; Callers: CheckingDevice_RunSelfTest (twice), PanelCpuCheck_FlashStatusOnLed.
CheckingDevice_FlashLedNibble:
	link XIZ,0x0000                                      ; F95158  ee 0c 00 00
	pushw hl                                             ; F9515C  2b
	pushw de                                             ; F9515D  2a
	ld e, 0x04:opc                                          ; F9515E  25 04
.LF95160:
	ld	c, (P5:8)                                      ; F95160  c0 0d 23
	and C,0x08                                           ; F95163  cb cc 08
	srl c, 0x03                                          ; F95166  cb ef 03
	res 0x00,C                                           ; F95169  cb 30 00
	.byte 0xcb, 0x23, 0x00                               ; F9516C  cb 23 00   ldcf 0x00,C
	stcf	3, (P5:8)                                  ; F9516F  f0 0d a3
	ldw hl, 0x4000                                       ; F95172  33 00 40
	ld C,(XIZ+0x08)                                      ; F95175  8e 08 23
	and C,0x01                                           ; F95178  cb cc 01
	jr z, .LF9518C                                           ; F9517B  66 0f
	ldw hl, 0xc000                                       ; F9517D  33 00 c0
	jr .LF9518C                                              ; F95180  68 0a
.LF95182:
	ld d, 0x20:opc                                          ; F95182  24 20
.LF95184:
	dec 1,D                                              ; F95184  cc 69
	cp d, 0x00:i3                                          ; F95186  cc d8
	jr nz, .LF95184                                            ; F95188  6e fa
	dec 1,HL                                             ; F9518A  db 69
.LF9518C:
	cp hl, 0x00:i3                                         ; F9518C  db d8
	jr nz, .LF95182                                           ; F9518E  6e f2
	ld	c, (P5:8)                                      ; F95190  c0 0d 23
	and C,0x08                                           ; F95193  cb cc 08
	srl c, 0x03                                          ; F95196  cb ef 03
	set 0x00,C                                           ; F95199  cb 31 00
	.byte 0xcb, 0x23, 0x00                               ; F9519C  cb 23 00   ldcf 0x00,C
	stcf	3, (P5:8)                                  ; F9519F  f0 0d a3
	ldw hl, 0x4000                                       ; F951A2  33 00 40
.LF951A5:
	ld d, 0x20:opc                                          ; F951A5  24 20
.LF951A7:
	dec 1,D                                              ; F951A7  cc 69
	cp d, 0x00:i3                                          ; F951A9  cc d8
	jr nz, .LF951A7                                            ; F951AB  6e fa
	dec 1,HL                                             ; F951AD  db 69
	cp hl, 0x00:i3                                         ; F951AF  db d8
	jr nz, .LF951A5                                           ; F951B1  6e f2
	srl (xiz+0x08)                                       ; F951B3  8e 08 7f   srl (XIZ+0x08)
	dec 1,E                                              ; F951B6  cd 69
	cp e, 0x00:i3                                          ; F951B8  cd d8
	jr nz, .LF95160                                           ; F951BA  6e a4
	popw de                                              ; F951BC  4a
	popw hl                                              ; F951BD  4b
	unlk XIZ                                             ; F951BE  ee 0d
	ret                                                  ; F951C0  0e
; Delay_SpinNestedLoopsShort -- a busy-wait of 0x1000 outer passes of 0x100 inner decrements, touching no memory
; Evidence: `ldw DE,0x1000 / ldw HL,0x0100 / dec HL ... dec DE`, HL and DE pushed and popped -- the shape of Delay_SpinNestedLoops with a 0x100 inner count
; instead of 0x600.  Callers: CheckingDevice_RunSelfTest; PanelSwLedCheck_Step loads its address (0xF9566B) and runs it three times by `push / jp (xix)`.
Delay_SpinNestedLoopsShort:
	pushw hl                                             ; F951C1  2b
	pushw de                                             ; F951C2  2a
	ldw de, 0x1000                                       ; F951C3  32 00 10
.LF951C6:
	ldw hl, 0x0100                                       ; F951C6  33 00 01
.LF951C9:
	dec 1,HL                                             ; F951C9  db 69
	cp hl, 0x00:i3                                         ; F951CB  db d8
	jr nz, .LF951C9                                            ; F951CD  6e fa
	dec 1,DE                                             ; F951CF  da 69
	cp de, 0x00:i3                                         ; F951D1  da d8
	jr nz, .LF951C6                                           ; F951D3  6e f1
	popw de                                              ; F951D5  4a
	popw hl                                              ; F951D6  4b
	ret                                                  ; F951D7  0e
; CheckingDevice_RamTest -- non-destructive RAM test of two regions; WA = OR of the failing regions' bits
; Evidence: two 9-byte records at 0xF95C83 {start LE32, length LE32, bit}: (0x00000100, 0x100, 0x01) and (0x00600000, 0x1000, 0x02); for each byte pair
; it saves the byte, writes 0x5A (then 0xA5 for the next), reads back, ORs the record's bit on mismatch and restores.  Only caller CheckingDevice_RunSelfTest.
CheckingDevice_RamTest:
	link XIZ,0xfff3                                      ; F951D8  ee 0c f3 ff
	pushw hl                                             ; F951DC  2b
	pushw de                                             ; F951DD  2a
	push XIX                                             ; F951DE  3c
	ld (xiz-13), 0x00                                    ; F951DF  be f3 00 00
	ldw de, 0x00                                         ; F951E3  32 00 00
	ld l, 0x02:opc                                          ; F951E6  27 02
.LF951E8:
	ld IX,DE                                             ; F951E8  da 8c
	extz XIX                                             ; F951EA  ec 12
	lda xbc, (CheckingDevice_RamTestRecords:24)                               ; F951EC  f2 83 5c f9 31
	add XBC,XIX                                          ; F951F1  ec 81
	ld XWA,(XBC)                                         ; F951F3  a1 20
	ld (xiz-12), xwa                                     ; F951F5  be f4 60
	ld XBC,XIX                                           ; F951F8  ec 89
	inc 4,XBC                                            ; F951FA  e9 64
	add XBC,CheckingDevice_RamTestRecords                                   ; F951FC  e9 c8 83 5c f9 00
	ld XBC,(XBC)                                         ; F95202  a1 21
	srl xbc, 0x01                                        ; F95204  e9 ef 01
	ld (xiz-8), xbc                                      ; F95207  be f8 61
	jrl z, .LF9526F                                          ; F9520A  76 62 00
	ld XWA,XIX                                           ; F9520D  ec 88
	inc 8,XWA                                            ; F9520F  e8 60
	ld (xiz-4), xwa                                      ; F95211  be fc 60
.LF95214:
	ld xbc, (xiz-12)                                     ; F95214  ae f4 21
	ld H,(XBC)                                           ; F95217  81 26
	ld (XBC),0x5a                                        ; F95219  b1 00 5a
	ld xbc, (xiz-12)                                     ; F9521C  ae f4 21
	ld A,(XBC)                                           ; F9521F  81 21
	cp A,0x5a                                            ; F95221  c9 cf 5a
	jr z, .LF95233                                           ; F95224  66 0d
	lda xwa, (CheckingDevice_RamTestRecords:24)                               ; F95226  f2 83 5c f9 30
	add	xwa, (xiz-4)                                 ; F9522B  ae fc 80
	ld C,(XWA)                                           ; F9522E  80 23
	or (xiz-13), c                                       ; F95230  8e f3 eb
.LF95233:
	ld xbc, (xiz-12)                                     ; F95233  ae f4 21
	ld (XBC),H                                           ; F95236  b1 46
	sub XBC,XBC                                          ; F95238  e9 a1
	inc 1,XBC                                            ; F9523A  e9 61
	add (xiz-12), xbc                                    ; F9523C  ae f4 89
	ld xwa, (xiz-12)                                     ; F9523F  ae f4 20
	ld H,(XWA)                                           ; F95242  80 26
	ld (XWA),0xa5                                        ; F95244  b0 00 a5
	ld xbc, (xiz-12)                                     ; F95247  ae f4 21
	ld A,(XBC)                                           ; F9524A  81 21
	cp A,0xa5                                            ; F9524C  c9 cf a5
	jr z, .LF9525E                                           ; F9524F  66 0d
	lda xwa, (CheckingDevice_RamTestRecords:24)                               ; F95251  f2 83 5c f9 30
	add	xwa, (xiz-4)                                 ; F95256  ae fc 80
	ld C,(XWA)                                           ; F95259  80 23
	or (xiz-13), c                                       ; F9525B  8e f3 eb
.LF9525E:
	ld xbc, (xiz-12)                                     ; F9525E  ae f4 21
	ld (XBC),H                                           ; F95261  b1 46
	sub XBC,XBC                                          ; F95263  e9 a1
	inc 1,XBC                                            ; F95265  e9 61
	add (xiz-12), xbc                                    ; F95267  ae f4 89
	sub (xiz-8), xbc                                     ; F9526A  ae f8 a9
	jr nz, .LF95214                                           ; F9526D  6e a5
.LF9526F:
	add DE,0x0009                                        ; F9526F  da c8 09 00
	dec 1,L                                              ; F95273  cf 69
	cp l, 0x00:i3                                          ; F95275  cf d8
	jrl nz, .LF951E8                                         ; F95277  7e 6e ff
	ld bc, (xiz-13)                                      ; F9527A  9e f3 21
	extz BC                                              ; F9527D  d9 12
	ld WA,BC                                             ; F9527F  d9 88
	pop XIX                                              ; F95281  5c
	popw de                                              ; F95282  4a
	popw hl                                              ; F95283  4b
	unlk XIZ                                             ; F95284  ee 0d
	ret                                                  ; F95286  0e
; CheckingDevice_RomIdTest -- compare the first four bytes of prom_a's ID string with "wsaa"; WA = 0x01 on mismatch
; Evidence: one 9-byte record at 0xF95C7A {pointer 0x00FFFFF0, expected bytes 77 73 61 61 = "wsaa", bit 0x01}; 0xFFFFF0 holds "wsaa_822" (the ROM ID the
; boot block reads).  Each differing byte ORs the bit into the result.  Only caller CheckingDevice_RunSelfTest.
CheckingDevice_RomIdTest:
	link XIZ,0xfff3                                      ; F95287  ee 0c f3 ff
	pushw hl                                             ; F9528B  2b
	pushw de                                             ; F9528C  2a
	push XIX                                             ; F9528D  3c
	ld (xiz-11), 0x00                                    ; F9528E  be f5 00 00
	ldw de, 0x00                                         ; F95292  32 00 00
	ld (xiz-1), 0x01                                     ; F95295  be ff 00 01
.LF95299:
	ld BC,DE                                             ; F95299  da 89
	extz XBC                                             ; F9529B  e9 12
	ld (xiz-10), xbc                                     ; F9529D  be f6 61
	add XBC,CheckingDevice_RomIdRecord                                   ; F952A0  e9 c8 7a 5c f9 00
	ld XBC,(XBC)                                         ; F952A6  a1 21
	ld (xiz-6), xbc                                      ; F952A8  be fa 61
	ld l, 0x00:opc                                          ; F952AB  27 00
	ld xwa, (xiz-10)                                     ; F952AD  ae f6 20
	inc 8,XWA                                            ; F952B0  e8 60
	add XWA,CheckingDevice_RomIdRecord                                   ; F952B2  e8 c8 7a 5c f9 00
	ld H,(XWA)                                           ; F952B8  80 26
	ld xix, (xiz-10)                                     ; F952BA  ae f6 24
	inc 4,XIX                                            ; F952BD  ec 64
.LF952BF:
	lda xbc, (CheckingDevice_RomIdRecord:24)                               ; F952BF  f2 7a 5c f9 31
	add XBC,XIX                                          ; F952C4  ec 81
	ld A,(XBC)                                           ; F952C6  81 21
	ld (xiz-13), a                                       ; F952C8  be f3 41
	ld xbc, (xiz-6)                                      ; F952CB  ae fa 21
	ld W,(XBC)                                           ; F952CE  81 20
	cp W,A                                               ; F952D0  c9 f0
	jr z, .LF952D9                                           ; F952D2  66 05
	ld A,H                                               ; F952D4  ce 89
	or (xiz-11), a                                       ; F952D6  8e f5 e9
.LF952D9:
	sub XBC,XBC                                          ; F952D9  e9 a1
	inc 1,XBC                                            ; F952DB  e9 61
	add (xiz-6), xbc                                     ; F952DD  ae fa 89
	add XIX,XBC                                          ; F952E0  e9 84
	add L,C                                              ; F952E2  cb 87
	cp l, 0x04:i3                                          ; F952E4  cf dc
	jr c, .LF952BF                                            ; F952E6  67 d7
	add DE,0x0009                                        ; F952E8  da c8 09 00
	sub (xiz-1), c                                       ; F952EC  8e ff ab
	jr nz, .LF95299                                           ; F952EF  6e a8
	ld wa, (xiz-11)                                      ; F952F1  9e f5 20
	extz WA                                              ; F952F4  d8 12
	pop XIX                                              ; F952F6  5c
	popw de                                              ; F952F7  4a
	popw hl                                              ; F952F8  4b
	unlk XIZ                                             ; F952F9  ee 0d
	ret                                                  ; F952FB  0e
; TestMode_SelectFromPowerOnKeys -- at boot, pick a service test screen from the keys held at power-on, by panel variant
; Evidence: prom_b slot T_TestMode_SelectFromPowerOnKeys, called once from boot at 0xF827F8 (after ExtBoard_Identify); `cp (0xC4),0x02` -> TestMode_SelectFromPowerOnKeys_Variant2
; (variant 2 = SX-WSA1R, Variant_SetFromPB0 header) else TestMode_SelectFromPowerOnKeys_Variant1.
TestMode_SelectFromPowerOnKeys:
	cp	(Variant_Flag:8), 0x02                               ; F952FC  c0 c4 3f 02
	jr nz, .LF95307                                          ; F95300  6e 05
	calr TestMode_SelectFromPowerOnKeys_Variant2                                            ; F95302  1e c8 00
	jr .LF9530A                                              ; F95305  68 03
.LF95307:
	calr TestMode_SelectFromPowerOnKeys_Variant1                                            ; F95307  1e 01 00
.LF9530A:
	ret                                                  ; F9530A  0e
; TestMode_SelectFromPowerOnKeys_Variant1 -- variant 1: read 8 bytes from CPU 2 and map a two-bit chord to screen 0xD9..0xDC
; Evidence: T_Link_SendCommandE2 (remote 0x0000FFF0, 8 bytes, into a stack buffer) + T_Link_WaitBlockDone; BitMask_PopCountByte over the 8 bytes must total 2;
; byte3 bit2 + byte4 bit6 -> 0xD9, byte3 bit4 + byte5 bit0 -> 0xDA (+ T_ParamImage_LoadFactoryDefaults, T_ParamImage_PostAllAsChangeEvents), byte3 bit5 + byte5 bit1 -> 0xDB, byte3 bit7 + byte5 bit3 -> 0xDC,
; byte3 bit0 + byte4 bit4 -> nothing; (0x2070) = id, (0x2071) = 0x80.  What those bits are on CPU 2 is not established.
TestMode_SelectFromPowerOnKeys_Variant1:
	link XIZ,0xfff8                                      ; F9530B  ee 0c f8 ff
	pushw hl                                             ; F9530F  2b
	push XIX                                             ; F95310  3c
	lda xix, (xiz-8)                                     ; F95311  be f8 34
	push XIX                                             ; F95314  3c
	pushw 0x08                                           ; F95315  0b 08 00
	ld XBC,0x0000fff0                                    ; F95318  41 f0 ff 00 00
	push XBC                                             ; F9531D  39
	call T_Link_SendCommandE2                            ; F9531E  1d f0 0e f4
	call T_Link_WaitBlockDone                            ; F95322  1d 3c 12 f4
	ld l, 0x00:opc                                          ; F95326  27 00
	ld h, 0x00:opc                                          ; F95328  26 00
	inc 8,XSP                                            ; F9532A  ef 60
	inc 2,XSP                                            ; F9532C  ef 62
.LF9532E:
	ld C,H                                               ; F9532E  ce 8b
	extz BC                                              ; F95330  d9 12
	extz XBC                                             ; F95332  e9 12
	add XBC,XIX                                          ; F95334  ec 81
	ld A,(XBC)                                           ; F95336  81 21
	pushw wa                                             ; F95338  28
	calr BitMask_PopCountByte                                            ; F95339  1e de 00
	add L,A                                              ; F9533C  c9 87
	inc 1,H                                              ; F9533E  ce 61
	popw bc                                              ; F95340  49
	cp H,0x08                                            ; F95341  ce cf 08
	jr c, .LF9532E                                            ; F95344  67 e8
	cp l, 0x02:i3                                          ; F95346  cf da
	jrl nz, .LF953C8                                         ; F95348  7e 7d 00
	ld C,(XIX+0x03)                                      ; F9534B  8c 03 23
	and C,0x01                                           ; F9534E  cb cc 01
	jr z, .LF9535C                                           ; F95351  66 09
	ld C,(XIX+0x04)                                      ; F95353  8c 04 23
	and C,0x10                                           ; F95356  cb cc 10
	jrl nz, .LF953C8                                         ; F95359  7e 6c 00
.LF9535C:
	ld C,(XIX+0x03)                                      ; F9535C  8c 03 23
	and C,0x04                                           ; F9535F  cb cc 04
	jr z, .LF95373                                           ; F95362  66 0f
	ld C,(XIX+0x04)                                      ; F95364  8c 04 23
	and C,0x40                                           ; F95367  cb cc 40
	jr z, .LF95373                                           ; F9536A  66 07
	ld (UI_Request:16), 0xd9                                 ; F9536C  f1 70 20 00 d9
	jr .LF953C3                                              ; F95371  68 50
.LF95373:
	ld C,(XIX+0x03)                                      ; F95373  8c 03 23
	and C,0x10                                           ; F95376  cb cc 10
	jr z, .LF95397                                           ; F95379  66 1c
	ld C,(XIX+0x05)                                      ; F9537B  8c 05 23
	and C,0x01                                           ; F9537E  cb cc 01
	jr z, .LF95397                                           ; F95381  66 14
	ld (UI_Request:16), 0xda                                 ; F95383  f1 70 20 00 da
	ld (UI_Request_Hi:16), 0x80                                 ; F95388  f1 71 20 00 80
	call T_ParamImage_LoadFactoryDefaults                                        ; F9538D  1d ac 07 f4
	call T_ParamImage_PostAllAsChangeEvents                                        ; F95391  1d b0 07 f4
	jr .LF953C8                                              ; F95395  68 31
.LF95397:
	ld C,(XIX+0x03)                                      ; F95397  8c 03 23
	and C,0x20                                           ; F9539A  cb cc 20
	jr z, .LF953AE                                           ; F9539D  66 0f
	ld C,(XIX+0x05)                                      ; F9539F  8c 05 23
	and C,0x02                                           ; F953A2  cb cc 02
	jr z, .LF953AE                                           ; F953A5  66 07
	ld (UI_Request:16), 0xdb                                 ; F953A7  f1 70 20 00 db
	jr .LF953C3                                              ; F953AC  68 15
.LF953AE:
	ld C,(XIX+0x03)                                      ; F953AE  8c 03 23
	and C,0x80                                           ; F953B1  cb cc 80
	jr z, .LF953C8                                           ; F953B4  66 12
	ld C,(XIX+0x05)                                      ; F953B6  8c 05 23
	and C,0x08                                           ; F953B9  cb cc 08
	jr z, .LF953C8                                           ; F953BC  66 0a
	ld (UI_Request:16), 0xdc                                 ; F953BE  f1 70 20 00 dc
.LF953C3:
	ld (UI_Request_Hi:16), 0x80                                 ; F953C3  f1 71 20 00 80
.LF953C8:
	pop XIX                                              ; F953C8  5c
	popw hl                                              ; F953C9  4b
	unlk XIZ                                             ; F953CA  ee 0d
	ret                                                  ; F953CC  0e
; TestMode_SelectFromPowerOnKeys_Variant2 -- variant 2 (SX-WSA1R): number-pad key 2/3/4/5 held at power-on -> test screen 0xD9/0xDA/0xDB/0xDC
; Evidence: C = (0x2B31), the segment-1 change shadow; exactly 0x04 -> (0x2070) = 0xD9 (Paint_PanelCpuCheck's screen), 0x08 -> 0xDA (SineWaveCheckMode, plus
; T_ParamImage_LoadFactoryDefaults/T_ParamImage_PostAllAsChangeEvents), 0x10 -> 0xDB (PanelSwLedCheck), 0x20 -> 0xDC; 0x02 -> nothing; (0x2071) = 0x80.  Segment-1 bit b is the number-pad key printed b
; on variant 2 (PanelKeypad_OrdinalToKey_V2: ordinal b+1 -> digit b).  Was flagged in FINDINGS-prom_a-ui-screen-blocks.md 5 as a gap-O datum.
TestMode_SelectFromPowerOnKeys_Variant2:
	push XIX                                             ; F953CD  3c
	lda xix, (UI_Request:16)                                ; F953CE  f1 70 20 34
	ld c, (Panel_SwitchShadow+0x11:16)                                   ; F953D2  c1 31 2b 23
	extz BC                                              ; F953D6  d9 12
	cp bc, 0x02:i3                                         ; F953D8  d9 da
	jr z, .LF95418                                           ; F953DA  66 3c
	cp bc, 0x04:i3                                         ; F953DC  d9 dc
	jr z, .LF953F4                                           ; F953DE  66 14
	cp BC,0x0008                                         ; F953E0  d9 cf 08 00
	jr z, .LF953F9                                           ; F953E4  66 13
	cp BC,0x0010                                         ; F953E6  d9 cf 10 00
	jr z, .LF9540B                                           ; F953EA  66 1f
	cp BC,0x0020                                         ; F953EC  d9 cf 20 00
	jr z, .LF95410                                           ; F953F0  66 1e
	jr .LF95418                                              ; F953F2  68 24
.LF953F4:
	ld (XIX),0xd9                                        ; F953F4  b4 00 d9
	jr .LF95413                                              ; F953F7  68 1a
.LF953F9:
	ld (XIX),0xda                                        ; F953F9  b4 00 da
	ld (UI_Request_Hi:16), 0x80                                 ; F953FC  f1 71 20 00 80
	call T_ParamImage_LoadFactoryDefaults                                        ; F95401  1d ac 07 f4
	call T_ParamImage_PostAllAsChangeEvents                                        ; F95405  1d b0 07 f4
	jr .LF95418                                              ; F95409  68 0d
.LF9540B:
	ld (XIX),0xdb                                        ; F9540B  b4 00 db
	jr .LF95413                                              ; F9540E  68 03
.LF95410:
	ld (XIX),0xdc                                        ; F95410  b4 00 dc
.LF95413:
	ld (UI_Request_Hi:16), 0x80                                 ; F95413  f1 71 20 00 80
.LF95418:
	pop XIX                                              ; F95418  5c
	ret                                                  ; F95419  0e
; BitMask_PopCountByte -- A := the number of set bits in the byte argument
; Evidence: L = (XIZ+0x08), 8 passes of `and C,1 / inc D / srl C,1`, A = D.  Only caller TestMode_SelectFromPowerOnKeys_Variant1.
BitMask_PopCountByte:
	link XIZ,0x0000                                      ; F9541A  ee 0c 00 00
	pushw hl                                             ; F9541E  2b
	pushw de                                             ; F9541F  2a
	ld d, 0x00:opc                                          ; F95420  24 00
	ld L,(XIZ+0x08)                                      ; F95422  8e 08 27
	ld h, 0x08:opc                                          ; F95425  26 08
.LF95427:
	ld C,L                                               ; F95427  cf 8b
	and C,0x01                                           ; F95429  cb cc 01
	jr z, .LF95430                                           ; F9542C  66 02
	inc 1,D                                              ; F9542E  cc 61
.LF95430:
	ld C,L                                               ; F95430  cf 8b
	srl c, 0x01                                          ; F95432  cb ef 01
	ld L,C                                               ; F95435  cb 8f
	dec 1,H                                              ; F95437  ce 69
	cp h, 0x00:i3                                          ; F95439  ce d8
	jr nz, .LF95427                                           ; F9543B  6e ea
	ld A,D                                               ; F9543D  cc 89
	popw de                                              ; F9543F  4a
	popw hl                                              ; F95440  4b
	unlk XIZ                                             ; F95441  ee 0d
	ret                                                  ; F95443  0e
; TestMode_Tick -- the periodic service-mode step: sine-wave switch poll, the DEBUG MONITOR chord, and the per-tick work of screens 0xDD and 0xDC
; Evidence: prom_b slot T_TestMode_Tick, called from the main loop at 0xF8215C after `tset 4,(0x88)`.  Variant 2: SineWaveCheck_PollIfCurrent.  If (0x208C) has bits 0,
; 3 and 7 (codes 0x00/0x03/0x07 = SOFT KEY columns 1, 4, 8, entered into (0x208C) when (0x20B9) == 3, PanelButton_Accept) -> (0x2070) = 0xDD, (0x2071) bit 6.
; On screen 0xDD every 4th tick ((0x284E)) sets (0x2095) bit 4; on 0xDC calls TestMode_DisplayCycleTick.
TestMode_Tick:
	push XIX                                             ; F95444  3c
	cp	(Variant_Flag:8), 0x02                               ; F95445  c0 c4 3f 02
	jr nz, .LF9544E                                          ; F95449  6e 03
	calr SineWaveCheck_PollIfCurrent                                            ; F9544B  1e 51 00
.LF9544E:
	ld xbc, (0x208c:16)                                 ; F9544E  e1 8c 20 21
	and XBC,0x00000080                                   ; F95452  e9 cc 80 00 00 00
	jr z, .LF9547B                                           ; F95458  66 21
	ld xbc, (0x208c:16)                                 ; F9545A  e1 8c 20 21
	and XBC,0x00000008                                   ; F9545E  e9 cc 08 00 00 00
	jr z, .LF9547B                                           ; F95464  66 15
	ld xbc, (0x208c:16)                                 ; F95466  e1 8c 20 21
	and XBC,0x00000001                                   ; F9546A  e9 cc 01 00 00 00
	jr z, .LF9547B                                           ; F95470  66 09
	ld (UI_Request:16), 0xdd                                 ; F95472  f1 70 20 00 dd
	set	6, (UI_Request_Hi:16)                               ; F95477  f1 71 20 be
.LF9547B:
	cp	(UI_ScreenId:16), 0xdd                            ; F9547B  c1 7c 20 3f dd
	jr nz, .LF95493                                          ; F95480  6e 11
	lda xix, (0x284e:16)                                ; F95482  f1 4e 28 34
	incm8 0x01, (xix)                                    ; F95486  84 61
	ld C,(XIX)                                           ; F95488  84 23
	and C,0x03                                           ; F9548A  cb cc 03
	jr nz, .LF95493                                          ; F9548D  6e 04
	set	4, (UI_ScreenFlags:16)                               ; F9548F  f1 95 20 bc
.LF95493:
	cp	(UI_ScreenId:16), 0xdc                            ; F95493  c1 7c 20 3f dc
	jr nz, .LF9549D                                          ; F95498  6e 03
	calr TestMode_DisplayCycleTick                                          ; F9549A  1e 5b 01
.LF9549D:
	pop XIX                                              ; F9549D  5c
	ret                                                  ; F9549E  0e
; SineWaveCheck_PollIfCurrent -- run SineWaveCheck_ServiceSwitches while screen 0xDA is the current one
; Evidence: `cp (0x207A),0xDA / jr nz`; 0xDA's object is T_Paint_SineWaveCheckMode (PanelScreen_VtableTable_ViewB[0xDA]).  Only caller TestMode_Tick (variant 2).
SineWaveCheck_PollIfCurrent:
	cp	(UI_ScreenLatch:16), 0xda                            ; F9549F  c1 7a 20 3f da
	jr nz, .LF954A9                                          ; F954A4  6e 03
	calr SineWaveCheck_ServiceSwitches                                            ; F954A6  1e 01 00
.LF954A9:
	ret                                                  ; F954A9  0e
; SineWaveCheck_ServiceSwitches -- per switch of (0x2B33) bits 0-3: issue T_ToneGen_SendSoundSelNote/T_MidiOut_SendNote with 0x7F while it alone is held, with 0 once released
; Evidence: C = (0x2B33) & 0x0F; exactly bit k (k = 0..3) and (0x2840) bit k+2 clear -> set it, T_ToneGen_SendSoundSelNote(0, 0x3C+k, 0x7F) and T_MidiOut_SendNote(0, 0x3C+k, 0x7F); any
; other value -> for each set bit k+2 of (0x2840): clear it and make the same two calls with 0 in place of 0x7F.
; ⚠ What T_ToneGen_SendSoundSelNote/T_MidiOut_SendNote (ToneGen_SendSoundSelNote/MidiOut_SendNote) do is not established; nor which panel controls segment 3 bits 0-3 are.
; 2026-10-04: now established -- the two directory slots (0xF413FC, 0xF41400) jump to ToneGen_SendSoundSelNote
;   ([0x90, SoundSel_Group | 0xF0, note, velocity] over the tone-generator link) and MidiOut_SendNote (channel 0:
;   MIDI OUT A).  So each switch plays
;   note 0x3C + k on the tone generator and on MIDI OUT while it alone is held.  Which panel controls bits 0-3 are
;   is still open.
SineWaveCheck_ServiceSwitches:
	push XIX                                             ; F954AA  3c
	lda xix, (0x2840:16)                                ; F954AB  f1 40 28 34
	ld c, (Panel_SwitchShadow+0x13:16)                                   ; F954AF  c1 33 2b 23
	and C,0x0f                                           ; F954B3  cb cc 0f
	extz BC                                              ; F954B6  d9 12
	cp bc, 0x01:i3                                         ; F954B8  d9 d9
	jr z, .LF954CD                                           ; F954BA  66 11
	cp bc, 0x02:i3                                         ; F954BC  d9 da
	jr z, .LF954F0                                           ; F954BE  66 30
	cp bc, 0x04:i3                                         ; F954C0  d9 dc
	jr z, .LF95513                                           ; F954C2  66 4f
	cp BC,0x0008                                         ; F954C4  d9 cf 08 00
	jr z, .LF95536                                           ; F954C8  66 6c
	jrl .LF95556                                             ; F954CA  78 89 00
.LF954CD:
	ld C,(XIX)                                           ; F954CD  84 23
	and C,0x04                                           ; F954CF  cb cc 04
	jrl nz, .LF955F6                                       ; F954D2  7e 21 01
	or	(xix), 0x04                                  ; F954D5  84 3e 04
	pushw 0x7f                                           ; F954D8  0b 7f 00
	pushw 0x3c                                           ; F954DB  0b 3c 00
	pushw 0x00                                           ; F954DE  0b 00 00
	call T_ToneGen_SendSoundSelNote                                        ; F954E1  1d fc 13 f4
	inc 6,XSP                                            ; F954E5  ef 66
	pushw 0x7f                                           ; F954E7  0b 7f 00
	pushw 0x3c                                           ; F954EA  0b 3c 00
	jrl .LF955ED                                             ; F954ED  78 fd 00
.LF954F0:
	ld C,(XIX)                                           ; F954F0  84 23
	and C,0x08                                           ; F954F2  cb cc 08
	jrl nz, .LF955F6                                         ; F954F5  7e fe 00
	or	(xix), 0x08                                  ; F954F8  84 3e 08
	pushw 0x7f                                           ; F954FB  0b 7f 00
	pushw 0x3d                                           ; F954FE  0b 3d 00
	pushw 0x00                                           ; F95501  0b 00 00
	call T_ToneGen_SendSoundSelNote                                        ; F95504  1d fc 13 f4
	inc 6,XSP                                            ; F95508  ef 66
	pushw 0x7f                                           ; F9550A  0b 7f 00
	pushw 0x3d                                           ; F9550D  0b 3d 00
	jrl .LF955ED                                             ; F95510  78 da 00
.LF95513:
	ld C,(XIX)                                           ; F95513  84 23
	and C,0x10                                           ; F95515  cb cc 10
	jrl nz, .LF955F6                                         ; F95518  7e db 00
	or	(xix), 0x10                                  ; F9551B  84 3e 10
	pushw 0x7f                                           ; F9551E  0b 7f 00
	pushw 0x3e                                           ; F95521  0b 3e 00
	pushw 0x00                                           ; F95524  0b 00 00
	call T_ToneGen_SendSoundSelNote                                        ; F95527  1d fc 13 f4
	inc 6,XSP                                            ; F9552B  ef 66
	pushw 0x7f                                           ; F9552D  0b 7f 00
	pushw 0x3e                                           ; F95530  0b 3e 00
	jrl .LF955ED                                             ; F95533  78 b7 00
.LF95536:
	ld C,(XIX)                                           ; F95536  84 23
	and C,0x20                                           ; F95538  cb cc 20
	jrl nz, .LF955F6                                         ; F9553B  7e b8 00
	or	(xix), 0x20                                  ; F9553E  84 3e 20
	pushw 0x7f                                           ; F95541  0b 7f 00
	pushw 0x3f                                           ; F95544  0b 3f 00
	pushw 0x00                                           ; F95547  0b 00 00
	call T_ToneGen_SendSoundSelNote                                        ; F9554A  1d fc 13 f4
	inc 6,XSP                                            ; F9554E  ef 66
	pushw 0x7f                                           ; F95550  0b 7f 00
	jrl .LF955EA                                             ; F95553  78 94 00
.LF95556:
	ld C,(XIX)                                           ; F95556  84 23
	and C,0x04                                           ; F95558  cb cc 04
	jr z, .LF9557E                                           ; F9555B  66 21
	and (XIX),0xfb                                       ; F9555D  84 3c fb
	pushw 0x00                                           ; F95560  0b 00 00
	pushw 0x3c                                           ; F95563  0b 3c 00
	pushw 0x00                                           ; F95566  0b 00 00
	call T_ToneGen_SendSoundSelNote                                        ; F95569  1d fc 13 f4
	pushw 0x00                                           ; F9556D  0b 00 00
	pushw 0x3c                                           ; F95570  0b 3c 00
	pushw 0x00                                           ; F95573  0b 00 00
	call T_MidiOut_SendNote                                        ; F95576  1d 00 14 f4
	inc 8,XSP                                            ; F9557A  ef 60
	inc 4,XSP                                            ; F9557C  ef 64
.LF9557E:
	ld C,(XIX)                                           ; F9557E  84 23
	and C,0x08                                           ; F95580  cb cc 08
	jr z, .LF955A6                                           ; F95583  66 21
	and (XIX),0xf7                                       ; F95585  84 3c f7
	pushw 0x00                                           ; F95588  0b 00 00
	pushw 0x3d                                           ; F9558B  0b 3d 00
	pushw 0x00                                           ; F9558E  0b 00 00
	call T_ToneGen_SendSoundSelNote                                        ; F95591  1d fc 13 f4
	pushw 0x00                                           ; F95595  0b 00 00
	pushw 0x3d                                           ; F95598  0b 3d 00
	pushw 0x00                                           ; F9559B  0b 00 00
	call T_MidiOut_SendNote                                        ; F9559E  1d 00 14 f4
	inc 8,XSP                                            ; F955A2  ef 60
	inc 4,XSP                                            ; F955A4  ef 64
.LF955A6:
	ld C,(XIX)                                           ; F955A6  84 23
	and C,0x10                                           ; F955A8  cb cc 10
	jr z, .LF955CE                                           ; F955AB  66 21
	and (XIX),0xef                                       ; F955AD  84 3c ef
	pushw 0x00                                           ; F955B0  0b 00 00
	pushw 0x3e                                           ; F955B3  0b 3e 00
	pushw 0x00                                           ; F955B6  0b 00 00
	call T_ToneGen_SendSoundSelNote                                        ; F955B9  1d fc 13 f4
	pushw 0x00                                           ; F955BD  0b 00 00
	pushw 0x3e                                           ; F955C0  0b 3e 00
	pushw 0x00                                           ; F955C3  0b 00 00
	call T_MidiOut_SendNote                                        ; F955C6  1d 00 14 f4
	inc 8,XSP                                            ; F955CA  ef 60
	inc 4,XSP                                            ; F955CC  ef 64
.LF955CE:
	ld C,(XIX)                                           ; F955CE  84 23
	and C,0x20                                           ; F955D0  cb cc 20
	jr z, .LF955F6                                           ; F955D3  66 21
	and (XIX),0xdf                                       ; F955D5  84 3c df
	pushw 0x00                                           ; F955D8  0b 00 00
	pushw 0x3f                                           ; F955DB  0b 3f 00
	pushw 0x00                                           ; F955DE  0b 00 00
	call T_ToneGen_SendSoundSelNote                                        ; F955E1  1d fc 13 f4
	inc 6,XSP                                            ; F955E5  ef 66
	pushw 0x00                                           ; F955E7  0b 00 00
.LF955EA:
	pushw 0x3f                                           ; F955EA  0b 3f 00
.LF955ED:
	pushw 0x00                                           ; F955ED  0b 00 00
	call T_MidiOut_SendNote                                        ; F955F0  1d 00 14 f4
	inc 6,XSP                                            ; F955F4  ef 66
.LF955F6:
	pop XIX                                              ; F955F6  5c
	ret                                                  ; F955F7  0e
; TestMode_DisplayCycleTick -- screen 0xDC's per-tick work: flash the whole LCD twice, then step through seven screens every 0x1E ticks
; Evidence: XIX = 0x2844 (index): 0 -> LCD_FlashWholePanel twice, index 1.  Else when the (0x2843) countdown is 0: (0x2070) = byte 0xF95C60[index], (0x2071) = 0x40;
; index 8 resets to 1, otherwise (0x2843) = 0x1E and index+1.  Table 0xF95C60 [1..7] = 0x01, 0xA0, 0xA1, 0x41, 0x71, 0x02, 0x06 ([8] = 0xFF); it is framed
; as instructions after DebugMonitor_PrintDumpPage's `ret`.  Only caller TestMode_Tick.
TestMode_DisplayCycleTick:
	push XIX                                             ; F955F8  3c
	lda xix, (0x2844:16)                                ; F955F9  f1 44 28 34
	ld C,(XIX)                                           ; F955FD  84 23
	cp c, 0x00:i3                                          ; F955FF  cb d8
	jr nz, .LF9560D                                          ; F95601  6e 0a
	call LCD_FlashWholePanel                                      ; F95603  1d bd 4d f9
	call LCD_FlashWholePanel                                      ; F95607  1d bd 4d f9
	jr .LF9563C                                              ; F9560B  68 2f
.LF9560D:
	cp	(0x2843:16), 0x00                            ; F9560D  c1 43 28 3f 00
	jr nz, .LF95640                                          ; F95612  6e 2c
	ld C,(XIX)                                           ; F95614  84 23
	extz BC                                              ; F95616  d9 12
	extz XBC                                             ; F95618  e9 12
	add XBC,TestMode_DisplayCycleScreenIds                                   ; F9561A  e9 c8 60 5c f9 00
	ld A,(XBC)                                           ; F95620  81 21
	ld (UI_Request:16), a                                   ; F95622  f1 70 20 41
	ld (UI_Request_Hi:16), 0x40                                 ; F95626  f1 71 20 00 40
	ld B,(XIX)                                           ; F9562B  84 22
	cp B,0x08                                            ; F9562D  ca cf 08
	jr nz, .LF95637                                          ; F95630  6e 05
	ld (XIX),0x01                                        ; F95632  b4 00 01
	jr .LF95644                                              ; F95635  68 0d
.LF95637:
	ld (0x2843:16), 0x1e                                 ; F95637  f1 43 28 00 1e
.LF9563C:
	incm8 0x01, (xix)                                    ; F9563C  84 61
	jr .LF95644                                              ; F9563E  68 04
.LF95640:
	dec 0x01, (0x2843:16)                                ; F95640  c1 43 28 69
.LF95644:
	pop XIX                                              ; F95644  5c
	ret                                                  ; F95645  0e
T_F40150_Nop:
	ret                                                  ; F95646  0e
T_F40154_Nop:
	ret                                                  ; F95647  0e
; PanelCpuCheck_FlashStatusOnLed -- read the panel CPU status and flash its complement's low nibble on the CHECKING DEVICE LED
; Evidence: PanelCpuCheck_ReadStatus, `ld C,(0x60A000) / cpl C`, CheckingDevice_FlashLedNibble(C).  `calr` from Paint_PanelCpuCheck (0xF9578F), whose
; screen reads "PANEL CPU CHECK", "Please check the CPU port", "LED flash."; published as T_F40158.
PanelCpuCheck_FlashStatusOnLed:
	call PanelCpuCheck_ReadStatus                                      ; F95648  1d f8 4d f9
	ld c, (0x60a000:24)                                 ; F9564C  c2 00 a0 60 23
	cpl C                                                ; F95651  cb 06
	pushw bc                                             ; F95653  29
	calr CheckingDevice_FlashLedNibble                                          ; F95654  1e 01 fb
	popw bc                                              ; F95657  49
	ret                                                  ; F95658  0e
T_F4015C_Nop:
	ret                                                  ; F95659  0e
; PartNotes_ReleaseReceivedOnScreenChange: when UI_ScreenLatch differs from UI_ScreenLatch_Previous (the screen just changed): T_PartNotes_ReleaseAllReceivedMidiIn.
;   Called by Paint_SineWaveCheckMode and through its directory slot 0xF40160.
PartNotes_ReleaseReceivedOnScreenChange:
	ld c, (UI_ScreenLatch_Previous:16)                                   ; F9565A  c1 7b 20 23
	cp	c, (UI_ScreenLatch:16)                               ; F9565E  c1 7a 20 f3
	jr z, .LF95668                                           ; F95662  66 04
	call T_PartNotes_ReleaseAllReceivedMidiIn                                        ; F95664  1d c0 13 f4
.LF95668:
	ret                                                  ; F95668  0e
T_F40164_Nop:
	ret                                                  ; F95669  0e
; PanelSwLedCheck_Step -- the PANEL SW&LED CHECK screen's work: lamp test on entry, then switch-to-LED echo, re-run every pass
; Evidence: `calr` from Paint_PanelSwLedCheck (0xF959B9), published as T_F40168.  (0x207B) != (0x207A) (first entry): PanelSwLedCheck_AllLedsOn,
; T_SC1_TxFlush, Delay_SpinNestedLoopsShort three times (`push <ret> / jp (xix)`), PanelSwLedCheck_AllLedsOff; otherwise TestMode_PanelSwitchesToLeds
; (whose header cites this very condition).  Then `set 4,(0x2071)`, a redraw request.
PanelSwLedCheck_Step:
	push XIX                                             ; F9566A  3c
	lda xix, (Delay_SpinNestedLoopsShort:24)                             ; F9566B  f2 c1 51 f9 34
	ld c, (UI_ScreenLatch_Previous:16)                                   ; F95670  c1 7b 20 23
	cp	c, (UI_ScreenLatch:16)                               ; F95674  c1 7a 20 f3
	jr z, .LF956A6                                           ; F95678  66 2c
	calr PanelSwLedCheck_AllLedsOn                                            ; F9567A  1e 33 00
	push XDE                                             ; F9567D  3a
	push XHL                                             ; F9567E  3b
	push XIX                                             ; F9567F  3c
	push XIZ                                             ; F95680  3e
	call T_SC1_TxFlush                                   ; F95681  1d 08 0f f4
	pop XIZ                                              ; F95685  5e
	pop XIX                                              ; F95686  5c
	pop XHL                                              ; F95687  5b
	pop XDE                                              ; F95688  5a
	lda xiy, (.LF95691:24)                               ; F95689  f2 91 56 f9 35
	push XIY                                             ; F9568E  3d
	jp (xix)                                             ; F9568F  b4 d8
.LF95691:
	lda xiy, (.LF95699:24)                               ; F95691  f2 99 56 f9 35
	push XIY                                             ; F95696  3d
	jp (xix)                                             ; F95697  b4 d8
.LF95699:
	lda xiy, (.LF956A1:24)                               ; F95699  f2 a1 56 f9 35
	push XIY                                             ; F9569E  3d
	jp (xix)                                             ; F9569F  b4 d8
.LF956A1:
	calr PanelSwLedCheck_AllLedsOff                                            ; F956A1  1e 55 00
	jr .LF956AA                                              ; F956A4  68 04
.LF956A6:
	call TestMode_PanelSwitchesToLeds                                      ; F956A6  1d 1c 4e f9
.LF956AA:
	set	4, (UI_Request_Hi:16)                               ; F956AA  f1 71 20 bc
	pop XIX                                              ; F956AE  5c
	ret                                                  ; F956AF  0e
; PanelSwLedCheck_AllLedsOn -- light every panel LED group from the table at 0xF95C68
; Evidence: word pairs at 0xF95C68 until 0xFFFF -- (0xFF,0) (0xFF,1) (0xFF,2) (0xFF,3) (0xFF,4) (0x03,5) (0x0F,6) (0x02,7) -- each staged as (0x60A001) = group,
; (0x60A000) = bits, then TestMode_SendStagedLed.  Only caller PanelSwLedCheck_Step.
PanelSwLedCheck_AllLedsOn:
	link XIZ,0xfffe                                      ; F956B0  ee 0c fe ff
	pushw hl                                             ; F956B4  2b
	pushw de                                             ; F956B5  2a
	push XIX                                             ; F956B6  3c
	ldw hl, 0x00                                         ; F956B7  33 00 00
.LF956BA:
	ld IX,HL                                             ; F956BA  db 8c
	extz XIX                                             ; F956BC  ec 12
	lda xbc, (PanelSwLedCheck_LedGroups:24)                               ; F956BE  f2 68 5c f9 31
	add XBC,XIX                                          ; F956C3  ec 81
	ld DE,(XBC)                                          ; F956C5  91 22
	cp DE,0xffff                                         ; F956C7  da cf ff ff
	jr z, .LF956F3                                           ; F956CB  66 26
	ld (xiz-2), hl                                       ; F956CD  be fe 53
	ld BC,DE                                             ; F956D0  da 89
	srl bc, 0x08                                         ; F956D2  d9 ef 08
	ld (0x60a001:24), c                                 ; F956D5  f2 01 a0 60 43
	lda xbc, (PanelSwLedCheck_LedGroups:24)                               ; F956DA  f2 68 5c f9 31
	add XBC,XIX                                          ; F956DF  ec 81
	ld A,(XBC)                                           ; F956E1  81 21
	ld (0x60a000:24), a                                 ; F956E3  f2 00 a0 60 41
	ld hl, (xiz-2)                                       ; F956E8  9e fe 23
	inc 2,HL                                             ; F956EB  db 62
	call TestMode_SendStagedLed                                      ; F956ED  1d 0a 4e f9
	jr .LF956BA                                               ; F956F1  68 c7
.LF956F3:
	pop XIX                                              ; F956F3  5c
	popw de                                              ; F956F4  4a
	popw hl                                              ; F956F5  4b
	unlk XIZ                                             ; F956F6  ee 0d
	ret                                                  ; F956F8  0e
; PanelSwLedCheck_AllLedsOff -- clear every LED group named in the table at 0xF95C68
; Evidence: the same walk as PanelSwLedCheck_AllLedsOn with (0x60A000) = 0 for each group byte.  Only caller PanelSwLedCheck_Step.
PanelSwLedCheck_AllLedsOff:
	pushw hl                                             ; F956F9  2b
	pushw de                                             ; F956FA  2a
	pushw ix                                             ; F956FB  2c
	ldw hl, 0x00                                         ; F956FC  33 00 00
.LF956FF:
	ld BC,HL                                             ; F956FF  db 89
	extz XBC                                             ; F95701  e9 12
	add XBC,PanelSwLedCheck_LedGroups                                   ; F95703  e9 c8 68 5c f9 00
	ld DE,(XBC)                                          ; F95709  91 22
	cp DE,0xffff                                         ; F9570B  da cf ff ff
	jr z, .LF9572D                                           ; F9570F  66 1c
	ld IX,HL                                             ; F95711  db 8c
	ld BC,DE                                             ; F95713  da 89
	srl bc, 0x08                                         ; F95715  d9 ef 08
	ld (0x60a001:24), c                                 ; F95718  f2 01 a0 60 43
	ld (0x60a000:24), 0x00                             ; F9571D  f2 00 a0 60 00 00
	ld HL,IX                                             ; F95723  dc 8b
	inc 2,HL                                             ; F95725  db 62
	call TestMode_SendStagedLed                                      ; F95727  1d 0a 4e f9
	jr .LF956FF                                               ; F9572B  68 d2
.LF9572D:
	popw ix                                              ; F9572D  4c
	popw de                                              ; F9572E  4a
	popw hl                                              ; F9572F  4b
	ret                                                  ; F95730  0e
T_F4016C_Nop:
	ret                                                  ; F95731  0e
T_F40170_Nop:
	ret                                                  ; F95732  0e
T_F40174_Nop:
	ret                                                  ; F95733  0e
; ---------------------------------------------------------------------
; Paint_GateArrayCheck -- paints the service screen whose own text reads "GATE ARRAY CHECK"
;
; Called from: prom_b T_F400D0 (`jp`)
;
; It hands 1 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xF9574E  list 0xF2C800-0xF2C84D (77 B, leaves by call)
;        text: "GATE ARRAY CHECK"; "Please check with osciloscope"; ...
; From the captions: "GATE ARRAY CHECK"; "Please check with osciloscope"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_GateArrayCheck:
	call T_CallbackQueue_ResetAndRestartTask2            ; F95734  1d 80 2e f4
	calr T_F40150_Nop                                          ; F95738  1e 0b ff
	ld c, (UI_ScreenId_Previous:16)                                   ; F9573B  c1 7d 20 23
	cp	c, (UI_ScreenId:16)                               ; F9573F  c1 7c 20 f3
	jr z, .LF95764                                           ; F95743  66 1f
	call LCD_BlankThenSetPanel2Layer                                      ; F95745  1d 2b 4c f9
	ld (LCD_CurrentLayer:16), 0x00                                 ; F95749  f1 40 25 00 00
	lda xbc, (DL_PanelCpuCheckPleaseCheckTheCpuPort:24)  ; F9574E  f2 4d c8 f2 31
	push XBC                                             ; F95753  39
	lda xwa, (DL_GateArrayCheckPleaseCheckWithOsciloscope:24) ; F95754  f2 00 c8 f2 30
	push XWA                                             ; F95759  38
	call T_DisplayList_Run_Stack                         ; F9575A  1d 00 2e f4
	call LCD_ShowLayers1And2_StackFrame                                      ; F9575E  1d 3c 4c f9
	inc 8,XSP                                            ; F95762  ef 60
.LF95764:
	ret                                                  ; F95764  0e
; ---------------------------------------------------------------------
; ScreenLeave_GateArrayCheck -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0xF8, i.e. SCREEN ID 0xD8 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xF8 -> the screen object at
;          0xF400D0, whose +4 slot is `jp 0xF95765`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   GateArrayCheck -- the same object's +0 ENTER method carries the
;          label Paint_GateArrayCheck, a name an earlier round derived from
;          the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_F95765`.
; ---------------------------------------------------------------------
ScreenLeave_GateArrayCheck:
	ret                                                  ; F95765  0e
; ---------------------------------------------------------------------
; ScreenButton_GateArrayCheck -- the BUTTON method of the screen object at
;          PanelScreen_VtableTable entry 0xF8, i.e. SCREEN ID 0xD8 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xF8 -> the screen object at
;          0xF400D0, whose +8 slot is `jp 0xF95766`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   GateArrayCheck -- the same object's +0 ENTER method carries the
;          label Paint_GateArrayCheck, a name an earlier round derived from
;          the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on button, and the slot exists to keep the three-method shape.
; Was `sub_F95766`.
; ---------------------------------------------------------------------
ScreenButton_GateArrayCheck:
	ret                                                  ; F95766  0e
T_F400DC_Nop:
	ret                                                  ; F95767  0e
; ---------------------------------------------------------------------
; Paint_PanelCpuCheck -- paints the service screen whose own text reads "PANEL CPU CHECK"
;
; Called from: prom_b T_F400E0 (`jp`)
;
; It hands 1 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xF9577B  list 0xF2C84D-0xF2C88B (62 B, leaves by call)
;        text: "PANEL CPU CHECK"; "Please check the CPU port"; "LED flash."
; From the captions: "PANEL CPU CHECK"; "Please check the CPU port"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_PanelCpuCheck:
	ld c, (UI_ScreenId_Previous:16)                                   ; F95768  c1 7d 20 23
	cp	c, (UI_ScreenId:16)                               ; F9576C  c1 7c 20 f3
	jr z, .LF95794                                           ; F95770  66 22
	call LCD_BlankThenSetPanel2Layer                                      ; F95772  1d 2b 4c f9
	ld (LCD_CurrentLayer:16), 0x00                                 ; F95776  f1 40 25 00 00
	lda xbc, (DL_SineWaveCheckCheckMode1SineWaveRomCheck:24) ; F9577B  f2 8b c8 f2 31
	push XBC                                             ; F95780  39
	lda xwa, (DL_PanelCpuCheckPleaseCheckTheCpuPort:24)  ; F95781  f2 4d c8 f2 30
	push XWA                                             ; F95786  38
	call T_DisplayList_Run_Stack                         ; F95787  1d 00 2e f4
	call LCD_ShowLayers1And2_StackFrame                                      ; F9578B  1d 3c 4c f9
	calr PanelCpuCheck_FlashStatusOnLed                                          ; F9578F  1e b6 fe
	inc 8,XSP                                            ; F95792  ef 60
.LF95794:
	ret                                                  ; F95794  0e
; ---------------------------------------------------------------------
; ScreenLeave_PanelCpuCheck -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0xF9, i.e. SCREEN ID 0xD9 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xF9 -> the screen object at
;          0xF400E0, whose +4 slot is `jp 0xF95795`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   PanelCpuCheck -- the same object's +0 ENTER method carries the
;          label Paint_PanelCpuCheck, a name an earlier round derived from
;          the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_F95795`.
; ---------------------------------------------------------------------
ScreenLeave_PanelCpuCheck:
	ret                                                  ; F95795  0e
; ---------------------------------------------------------------------
; ScreenButton_PanelCpuCheck -- the BUTTON method of the screen object at
;          PanelScreen_VtableTable entry 0xF9, i.e. SCREEN ID 0xD9 through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xF9 -> the screen object at
;          0xF400E0, whose +8 slot is `jp 0xF95796`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   PanelCpuCheck -- the same object's +0 ENTER method carries the
;          label Paint_PanelCpuCheck, a name an earlier round derived from
;          the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on button, and the slot exists to keep the three-method shape.
; Was `sub_F95796`.
; ---------------------------------------------------------------------
ScreenButton_PanelCpuCheck:
	ret                                                  ; F95796  0e
T_F400EC_Nop:
	ret                                                  ; F95797  0e
; ---------------------------------------------------------------------
; Paint_SineWaveCheckMode -- paints the service screen whose own text reads "SINE WAVE CHECK" / "CHECK MODE"
;
; Called from: prom_b T_F400F0 (`jp`)
;
; It hands 2 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xF95808  list 0xF2C88B-0xF2C9C2 (311 B, leaves by call)
;        text: "SINE WAVE CHECK"; "CHECK MODE"; "(1) SINE WAVE & ROM CHECK"; ...
;     site 0xF9581D  list 0xF2CA0D-0xF2CA15 (8 B, leaves by call)
; From the captions: "SINE WAVE CHECK"; "(1) SINE WAVE & ROM CHECK";
;          "CHECK MODE"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_SineWaveCheckMode:
	push XIX                                             ; F95798  3c
	lda xix, (0x76a2:16)                                ; F95799  f1 a2 76 34
	ld c, (UI_ScreenLatch_Previous:16)                                   ; F9579D  c1 7b 20 23
	cp	c, (UI_ScreenLatch:16)                               ; F957A1  c1 7a 20 f3
	jr z, .LF957FC                                           ; F957A5  66 55
	cp	(Variant_Flag:8), 0x02                               ; F957A7  c0 c4 3f 02
	jr nz, .LF957B1                                          ; F957AB  6e 04
	set	1, (UI_RequestBits:16)                               ; F957AD  f1 75 20 b9
.LF957B1:
	extz XIX                                             ; F957B1  ec 12
	ld (XIX+0x05),0x00                                   ; F957B3  bc 05 00 00
	ld (XIX+0x06),0x00                                   ; F957B7  bc 06 00 00
	ld (XIX+0x07),0x00                                   ; F957BB  bc 07 00 00
	ldw (0x60f004:24), 0x00                             ; F957BF  f2 04 f0 60 02 00 00
	pushw 0x7f                                           ; F957C6  0b 7f 00
	pushw 0x00                                           ; F957C9  0b 00 00
	pushw 0x05                                           ; F957CC  0b 05 00
	pushw 0x00                                           ; F957CF  0b 00 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F957D2  1d 18 1b f4
	pushw 0x7f                                           ; F957D6  0b 7f 00
	pushw 0x00                                           ; F957D9  0b 00 00
	pushw 0x06                                           ; F957DC  0b 06 00
	pushw 0x00                                           ; F957DF  0b 00 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F957E2  1d 18 1b f4
	pushw 0x7f                                           ; F957E6  0b 7f 00
	pushw 0x00                                           ; F957E9  0b 00 00
	pushw 0x07                                           ; F957EC  0b 07 00
	pushw 0x00                                           ; F957EF  0b 00 00
	call T_PendingEventQueue_AppendStackArgs                                        ; F957F2  1d 18 1b f4
	add XSP,0x00000018                                   ; F957F6  ef c8 18 00 00 00
.LF957FC:
	calr PartNotes_ReleaseReceivedOnScreenChange                                          ; F957FC  1e 5b fe
	call LCD_BlankThenSetPanel2Layer                                      ; F957FF  1d 2b 4c f9
	ld (LCD_CurrentLayer:16), 0x00                                 ; F95803  f1 40 25 00 00
	lda xbc, (Paint_SineWaveCheckMode_DL1:24)                           ; F95808  f2 c2 c9 f2 31
	push XBC                                             ; F9580D  39
	lda xwa, (DL_SineWaveCheckCheckMode1SineWaveRomCheck:24) ; F9580E  f2 8b c8 f2 30
	push XWA                                             ; F95813  38
	call T_DisplayList_Run_Stack                         ; F95814  1d 00 2e f4
	ld (LCD_CurrentLayer:16), 0x01                                 ; F95818  f1 40 25 00 01
	lda xbc, (Paint_SineWaveCheckMode_DL2:24)                           ; F9581D  f2 15 ca f2 31
	push XBC                                             ; F95822  39
	lda xwa, (Paint_SineWaveCheckMode_DL3:24)                              ; F95823  f2 0d ca f2 30
	push XWA                                             ; F95828  38
	call T_DisplayList_Run_Stack                         ; F95829  1d 00 2e f4
	ld C,(XIX)                                           ; F9582D  84 23
	and C,0xff                                           ; F9582F  cb cc ff
	ld (SoundConv_Arg0:24), c                                 ; F95832  f2 10 f0 60 43
	ld C,(XIX+0x01)                                      ; F95837  8c 01 23
	res 0x07,C                                           ; F9583A  cb 30 07
	ld (SoundConv_Arg1:24), c                                 ; F9583D  f2 11 f0 60 43
	ld (SoundConv_Arg2:24), 0x00                             ; F95842  f2 12 f0 60 00 00
	push XDE                                             ; F95848  3a
	push XHL                                             ; F95849  3b
	push XIX                                             ; F9584A  3c
	push XIZ                                             ; F9584B  3e
	call T_SoundSel_FromProgramAndBank                                        ; F9584C  1d 00 10 f4
	pop XIZ                                              ; F95850  5e
	pop XIX                                              ; F95851  5c
	pop XHL                                              ; F95852  5b
	pop XDE                                              ; F95853  5a
	ld c, (SoundSel_Group:16)                                   ; F95854  c1 69 21 23
	ld (0x2881:16), c                                   ; F95858  f1 81 28 43
	lda xbc, (Paint_SineWaveCheckMode_DL1:24)                           ; F9585C  f2 c2 c9 f2 31
	push XBC                                             ; F95861  39
	call T_DisplayListB_RunOne_Stack                     ; F95862  1d 0c 2e f4
	lda xbc, (Paint_SineWaveCheckMode_DL2:24)                           ; F95866  f2 15 ca f2 31
	push XBC                                             ; F9586B  39
	call T_DisplayListB_RunOne_Stack                     ; F9586C  1d 0c 2e f4
	lda xbc, (Paint_SineWaveCheckMode_DL4:24)                           ; F95870  f2 26 ca f2 31
	push XBC                                             ; F95875  39
	call T_DisplayListB_RunOne_Stack                     ; F95876  1d 0c 2e f4
	lda xbc, (Paint_SineWaveCheckMode_DL5:24)                           ; F9587A  f2 37 ca f2 31
	push XBC                                             ; F9587F  39
	call T_DisplayListB_RunOne_Stack                     ; F95880  1d 0c 2e f4
	call LCD_ShowLayers1And2_StackFrame                                      ; F95884  1d 3c 4c f9
	add XSP,0x00000020                                   ; F95888  ef c8 20 00 00 00
	pop XIX                                              ; F9588E  5c
	ret                                                  ; F9588F  0e
; ---------------------------------------------------------------------
; ScreenLeave_SineWaveCheckMode -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0xFA, i.e. SCREEN ID 0xDA through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xFA -> the screen object at
;          0xF400F0, whose +4 slot is `jp 0xF95890`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   SineWaveCheckMode -- the same object's +0 ENTER method carries
;          the label Paint_SineWaveCheckMode, a name an earlier round derived
;          from the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_F95890`.
; ---------------------------------------------------------------------
ScreenLeave_SineWaveCheckMode:
	ret                                                  ; F95890  0e
; ---------------------------------------------------------------------
; ScreenButton_SineWaveCheckMode -- the BUTTON method of the screen object at
;          PanelScreen_VtableTable entry 0xFA, i.e. SCREEN ID 0xDA through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xFA -> the screen object at
;          0xF400F0, whose +8 slot is `jp 0xF95891`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   SineWaveCheckMode -- the same object's +0 ENTER method carries
;          the label Paint_SineWaveCheckMode, a name an earlier round derived
;          from the screen's own text.
; Was `sub_F95891`.
; ---------------------------------------------------------------------
ScreenButton_SineWaveCheckMode:
	link XIZ,0x0000                                      ; F95891  ee 0c 00 00
	pushw hl                                             ; F95895  2b
	cpw	(xiz+8), 0x001f                              ; F95896  9e 08 3f 1f 00
	jr ugt, .LF958C5                                         ; F9589B  6b 28
	ld h, 0x01:opc                                          ; F9589D  26 01
	ld BC,(XIZ+0x0a)                                     ; F9589F  9e 0a 21
	and BC,0x0080                                        ; F958A2  d9 cc 80 00
	jr nz, .LF958AA                                          ; F958A6  6e 02
	ld h, 0x00:opc                                          ; F958A8  26 00
.LF958AA:
	push 0x00                                            ; F958AA  09 00
	push H                                               ; F958AC  ce 04
	ldw bc, 0x04                                         ; F958AE  31 04 00
	mul	xbc, (xiz+8)                                 ; F958B1  9e 08 41
	add XBC,ScreenButtonHandlers_SineWaveCheckMode                             ; F958B4  e9 c8 95 5c f9 00
	ld XBC,(XBC)                                         ; F958BA  a1 21
	lda xiy, (.LF958C4:24)                               ; F958BC  f2 c4 58 f9 35
	push XIY                                             ; F958C1  3d
	jp (xbc)                                             ; F958C2  b1 d8
.LF958C4:
	popw bc                                              ; F958C4  49
.LF958C5:
	popw hl                                              ; F958C5  4b
	unlk XIZ                                             ; F958C6  ee 0d
	ret                                                  ; F958C8  0e
; SoftKeyCol4_SineWaveCheckMode -- SOFT KEY column 4 on SINE WAVE CHECK MODE: set part record 0's byte +5 (0x76A7) to 0x7F (upper key) or 0 (lower)
; Evidence: ScreenButtonHandlers_SineWaveCheckMode [0x03] and [0x14]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x03 = SOFT KEY column 4; [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; (XIZ+0x08) != 0 (the lower key, bit 7 set) and (0x76A7) != 0 -> T_FixedEventList_AppendStackArgs(0, 5, 0x00, 0x7F); == 0 and (0x76A7) != 0x7F -> T_FixedEventList_AppendStackArgs(0, 5, 0x7F, 0x7F).
; (0x76A7) = 0x76A2 + 5, part record 0 (PartRecord_GetPtr's array).  What T_FixedEventList_AppendStackArgs (sub_F8BC00) does with it is not established.
SoftKeyCol4_SineWaveCheckMode:   ; entry: screen button-handler table
	link XIZ,0x0000                                      ; F958C9  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F958CD  8e 08 3f 00
	jr nz, .LF958E4                                          ; F958D1  6e 11
	ld c, (0x76a7:16)                                   ; F958D3  c1 a7 76 23
	cp C,0x7f                                            ; F958D7  cb cf 7f
	jr z, .LF958FE                                           ; F958DA  66 22
	pushw 0x7f                                           ; F958DC  0b 7f 00
	pushw 0x7f                                           ; F958DF  0b 7f 00
	jr .LF958F2                                              ; F958E2  68 0e
.LF958E4:
	ld c, (0x76a7:16)                                   ; F958E4  c1 a7 76 23
	cp c, 0x00:i3                                          ; F958E8  cb d8
	jr z, .LF958FE                                           ; F958EA  66 12
	pushw 0x7f                                           ; F958EC  0b 7f 00
	pushw 0x00                                           ; F958EF  0b 00 00
.LF958F2:
	pushw 0x05                                           ; F958F2  0b 05 00
	pushw 0x00                                           ; F958F5  0b 00 00
	call T_FixedEventList_AppendStackArgs                                        ; F958F8  1d 10 1b f4
	inc 8,XSP                                            ; F958FC  ef 60
.LF958FE:
	unlk XIZ                                             ; F958FE  ee 0d
	ret                                                  ; F95900  0e
; SoftKeyCol5_SineWaveCheckMode -- SOFT KEY column 5 on SINE WAVE CHECK MODE: set part record 0's byte +6 (0x76A8) to 0x7F (upper key) or 0 (lower)
; Evidence: ScreenButtonHandlers_SineWaveCheckMode [0x04] and [0x15]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x04 = SOFT KEY column 5; [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; (XIZ+0x08) != 0 (the lower key, bit 7 set) and (0x76A8) != 0 -> T_FixedEventList_AppendStackArgs(0, 6, 0x00, 0x7F); == 0 and (0x76A8) != 0x7F -> T_FixedEventList_AppendStackArgs(0, 6, 0x7F, 0x7F).
; (0x76A8) = 0x76A2 + 6, part record 0 (PartRecord_GetPtr's array).  What T_FixedEventList_AppendStackArgs (sub_F8BC00) does with it is not established.
SoftKeyCol5_SineWaveCheckMode:   ; entry: screen button-handler table
	link XIZ,0x0000                                      ; F95901  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F95905  8e 08 3f 00
	jr nz, .LF9591C                                          ; F95909  6e 11
	ld c, (0x76a8:16)                                   ; F9590B  c1 a8 76 23
	cp C,0x7f                                            ; F9590F  cb cf 7f
	jr z, .LF95936                                           ; F95912  66 22
	pushw 0x7f                                           ; F95914  0b 7f 00
	pushw 0x7f                                           ; F95917  0b 7f 00
	jr .LF9592A                                              ; F9591A  68 0e
.LF9591C:
	ld c, (0x76a8:16)                                   ; F9591C  c1 a8 76 23
	cp c, 0x00:i3                                          ; F95920  cb d8
	jr z, .LF95936                                           ; F95922  66 12
	pushw 0x7f                                           ; F95924  0b 7f 00
	pushw 0x00                                           ; F95927  0b 00 00
.LF9592A:
	pushw 0x06                                           ; F9592A  0b 06 00
	pushw 0x00                                           ; F9592D  0b 00 00
	call T_FixedEventList_AppendStackArgs                                        ; F95930  1d 10 1b f4
	inc 8,XSP                                            ; F95934  ef 60
.LF95936:
	unlk XIZ                                             ; F95936  ee 0d
	ret                                                  ; F95938  0e
; SoftKeyCol6_SineWaveCheckMode -- SOFT KEY column 6 on SINE WAVE CHECK MODE: set part record 0's byte +7 (0x76A9) to 0x7F (upper key) or 0 (lower)
; Evidence: ScreenButtonHandlers_SineWaveCheckMode [0x05] and [0x16]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x05 = SOFT KEY column 6; [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; (XIZ+0x08) != 0 (the lower key, bit 7 set) and (0x76A9) != 0 -> T_FixedEventList_AppendStackArgs(0, 7, 0x00, 0x7F); == 0 and (0x76A9) != 0x7F -> T_FixedEventList_AppendStackArgs(0, 7, 0x7F, 0x7F).
; (0x76A9) = 0x76A2 + 7, part record 0 (PartRecord_GetPtr's array).  What T_FixedEventList_AppendStackArgs (sub_F8BC00) does with it is not established.
SoftKeyCol6_SineWaveCheckMode:   ; entry: screen button-handler table
	link XIZ,0x0000                                      ; F95939  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F9593D  8e 08 3f 00
	jr nz, .LF95954                                          ; F95941  6e 11
	ld c, (0x76a9:16)                                   ; F95943  c1 a9 76 23
	cp C,0x7f                                            ; F95947  cb cf 7f
	jr z, .LF9596E                                           ; F9594A  66 22
	pushw 0x7f                                           ; F9594C  0b 7f 00
	pushw 0x7f                                           ; F9594F  0b 7f 00
	jr .LF95962                                              ; F95952  68 0e
.LF95954:
	ld c, (0x76a9:16)                                   ; F95954  c1 a9 76 23
	cp c, 0x00:i3                                          ; F95958  cb d8
	jr z, .LF9596E                                           ; F9595A  66 12
	pushw 0x7f                                           ; F9595C  0b 7f 00
	pushw 0x00                                           ; F9595F  0b 00 00
.LF95962:
	pushw 0x07                                           ; F95962  0b 07 00
	pushw 0x00                                           ; F95965  0b 00 00
	call T_FixedEventList_AppendStackArgs                                        ; F95968  1d 10 1b f4
	inc 8,XSP                                            ; F9596C  ef 60
.LF9596E:
	unlk XIZ                                             ; F9596E  ee 0d
	ret                                                  ; F95970  0e
; NumberPadKey_SineWaveCheckMode -- number-pad key 1..7 on SINE WAVE CHECK MODE: (0x2169) = key - 1 and redraw
; Evidence: ScreenButtonHandlers_SineWaveCheckMode [0x1B] only; Dispatch_FF3D39's CONTROL LEGEND gives code 0x1B = the number pad.  H = (0x2267) & 0x0F; 1..7 -> (0x2169) = H-1, `set 4,(0x2095)`.
NumberPadKey_SineWaveCheckMode:   ; entry: screen button-handler table
	pushw hl                                             ; F95971  2b
	ld h, (0x2267:16)                                   ; F95972  c1 67 22 26
	and H,0x0f                                           ; F95976  ce cc 0f
	cp h, 0x01:i3                                          ; F95979  ce d9
	jr c, .LF9598D                                           ; F9597B  67 10
	cp h, 0x07:i3                                          ; F9597D  ce df
	jr ugt, .LF9598D                                         ; F9597F  6b 0c
	ld C,H                                               ; F95981  ce 8b
	dec 1,C                                              ; F95983  cb 69
	ld (SoundSel_Group:16), c                                   ; F95985  f1 69 21 43
	set	4, (UI_ScreenFlags:16)                               ; F95989  f1 95 20 bc
.LF9598D:
	popw hl                                              ; F9598D  4b
	ret                                                  ; F9598E  0e
T_F400FC_Nop:
	ret                                                  ; F9598F  0e
; ---------------------------------------------------------------------
; Paint_PanelSwLedCheck -- paints the service screen whose own text reads "PANEL SW&LED CHECK"
;
; Called from: prom_b T_F40100 (`jp`)
;
; It hands 1 display list(s) to the interpreter ON THE STACK --
;          lda XBC,<end> / push XBC / lda XWA,<start> / push XWA,
;          then the stack veneer.  The lists, and the text each draws:
;     site 0xF959A3  list 0xF2CA54-0xF2CAC3 (111 B, leaves by call)
;        text: "PANEL SW&LED CHECK"; "Please push a any button."; ...
; From the captions: "PANEL SW&LED CHECK"; "If LED near the button turn"
; Evidence: the list bounds are the two 24-bit IMMEDIATES of the
;          12-byte push idiom at the cited site, and the record
;          length bytes walked from <start> land EXACTLY on <end>
;          (368 of 368 in both images do -- notes/prom_a_dl_stack_map.py).
;          The quoted text is the `.ascii` the interpreter draws
;          verbatim.  Every morpheme of this name occurs in it;
;          notes/prom_a_understanding_round7.py --morphemes checks that.
;          `Paint_` is a structural verb, not ROM text.
; Unknown: whether this routine also handles input for the screen,
;          and whether another routine paints it too.  Neither was
;          searched.  ⚠ The register-form scan of rounds 5 and 6 does
;          not see this call shape at all, which is why this routine
;          was sub_XXXXXX until round 7.
; Named by notes/prom_a_understanding_round7.py --apply; the byte gate
;          is blind to this name, --verify reads it back.
; ---------------------------------------------------------------------
Paint_PanelSwLedCheck:
	ld c, (UI_ScreenId_Previous:16)                                   ; F95990  c1 7d 20 23
	cp	c, (UI_ScreenId:16)                               ; F95994  c1 7c 20 f3
	jr z, .LF959B9                                           ; F95998  66 1f
	call LCD_BlankThenSetPanel2Layer                                      ; F9599A  1d 2b 4c f9
	ld (LCD_CurrentLayer:16), 0x00                                 ; F9599E  f1 40 25 00 00
	lda xbc, (Bitmap_F2CAC3:24)                          ; F959A3  f2 c3 ca f2 31
	push XBC                                             ; F959A8  39
	lda xwa, (DL_PanelSwLedCheckPleasePushAAnyButton:24) ; F959A9  f2 54 ca f2 30
	push XWA                                             ; F959AE  38
	call T_DisplayList_Run_Stack                         ; F959AF  1d 00 2e f4
	call LCD_ShowLayers1And2_StackFrame                                      ; F959B3  1d 3c 4c f9
	inc 8,XSP                                            ; F959B7  ef 60
.LF959B9:
	calr PanelSwLedCheck_Step                                          ; F959B9  1e ae fc
	ret                                                  ; F959BC  0e
; ---------------------------------------------------------------------
; ScreenLeave_PanelSwLedCheck -- the LEAVE method of the screen object at
;          PanelScreen_VtableTable entry 0xFB, i.e. SCREEN ID 0xDB through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xFB -> the screen object at
;          0xF40100, whose +4 slot is `jp 0xF959BD`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the LEAVE method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   PanelSwLedCheck -- the same object's +0 ENTER method carries the
;          label Paint_PanelSwLedCheck, a name an earlier round derived from
;          the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on leave, and the slot exists to keep the three-method shape.
; Was `sub_F959BD`.
; ---------------------------------------------------------------------
ScreenLeave_PanelSwLedCheck:
	ret                                                  ; F959BD  0e
; ---------------------------------------------------------------------
; ScreenButton_PanelSwLedCheck -- the BUTTON method of the screen object at
;          PanelScreen_VtableTable entry 0xFB, i.e. SCREEN ID 0xDB through
;          PanelScreen_VtableTable_ViewB
;
; Reached from: PanelScreen_VtableTable entry 0xFB -> the screen object at
;          0xF40100, whose +8 slot is `jp 0xF959BE`. It is reached from
;          nowhere else: no other live screen object names this address in
;          either of its two callable slots.
; Evidence: the offset is not a guess about layout, and it is what makes this
;          the BUTTON method. +0 is called by PanelScreen_CallEnter_A/B with
;          the id that has just BECOME current, +4 by
;          PanelScreen_CallLeave_A/B with the id that has just STOPPED being
;          current, and +8 by PanelButton_Route (0xF8621E) with the current
;          id and a button index -- three different call sites, checked as
;          V1-V6 in PanelScreen_VtableTable's own header.
; Screen:   PanelSwLedCheck -- the same object's +0 ENTER method carries the
;          label Paint_PanelSwLedCheck, a name an earlier round derived from
;          the screen's own text.
; Body:     ONE BYTE, 0x0E -- a bare `ret`. This screen does nothing at all
;          on button, and the slot exists to keep the three-method shape.
; Was `sub_F959BE`.
; The DEBUG MONITOR's address editor clears one hex digit of the 24-bit dump address before ORing
; in the stepped digit (SoftKeyCol2..6_DebugMonitor): bits 16-19, 12-15, 8-11, 4-7, 0-3.
	.equ MASK_CLEAR_BITS16_19, 0x00F0FFFF
	.equ MASK_CLEAR_BITS12_15, 0x00FF0FFF
	.equ MASK_CLEAR_BITS8_11, 0x00FFF0FF
	.equ MASK_CLEAR_BITS4_7, 0x00FFFF0F
	.equ MASK_CLEAR_BITS0_3, 0x00FFFFF0	; SoftKeyCol6; was spelled BUILD_TAG, the label that sits at 0xFFFFF0

; ---------------------------------------------------------------------
ScreenButton_PanelSwLedCheck:
	ret                                                  ; F959BE  0e
T_F4010C_Nop:
	ret                                                  ; F959BF  0e
T_F40110_Nop:
	ret                                                  ; F959C0  0e
T_F40114_Nop:
	ret                                                  ; F959C1  0e
T_F40118_Nop:
	ret                                                  ; F959C2  0e
T_F4011C_Nop:
	ret                                                  ; F959C3  0e
T_F40120_Nop:
	ret                                                  ; F959C4  0e
T_F40124_Nop:
	ret                                                  ; F959C5  0e
T_F40128_Nop:
	ret                                                  ; F959C6  0e
T_F4012C_Nop:
	ret                                                  ; F959C7  0e
; ScreenEnter_DebugMonitor -- the +0 ENTER method of screen 0xDD, the DEBUG MONITOR
; Evidence: PanelScreen_VtableTable_ViewB[0xDD] = T_ScreenEnter_DebugMonitor (`jp 0xF959C8`).  Unless (0x2095) bit 4 (redraw): LCD_BlankThenSetPanel2Layer, (0x2075) bit 7;
; then DebugMonitor_PrintDumpPage, which calls Print_DebugMonitor (ROM line " --- DEBUG MONITOR BY (c)masa,toshi --- ") and DebugMonitor_PrintHexDump; then
; LCD_ShowLayers1And2_StackFrame.  TestMode_Tick requests 0xDD on the SOFT KEY 1+4+8 chord.
ScreenEnter_DebugMonitor:
	ld c, (UI_ScreenFlags:16)                                   ; F959C8  c1 95 20 23
	and C,0x10                                           ; F959CC  cb cc 10
	jr nz, .LF959D9                                          ; F959CF  6e 08
	call LCD_BlankThenSetPanel2Layer                                      ; F959D1  1d 2b 4c f9
	set	7, (UI_RequestBits:16)                               ; F959D5  f1 75 20 bf
.LF959D9:
	calr DebugMonitor_PrintDumpPage                                          ; F959D9  1e 51 02
	call LCD_ShowLayers1And2_StackFrame                                      ; F959DC  1d 3c 4c f9
	ret                                                  ; F959E0  0e
T_F40134_Nop:
	ret                                                  ; F959E1  0e
; ScreenButton_DebugMonitor -- the +8 BUTTON method of screen 0xDD: dispatch ScreenObjF40130_ButtonHandlers by button code
; Evidence: T_ScreenButton_DebugMonitor (`jp 0xF959E2`); `cp (XIZ+8),0x001F / jr ugt`, H = 1 when bit 7 of (XIZ+0x0A) is set, then calls ScreenObjF40130_ButtonHandlers[(XIZ+8)]
; with H on the stack -- ScreenButton_SineWaveCheckMode's reader shape, instruction for instruction.
ScreenButton_DebugMonitor:
	link XIZ,0x0000                                      ; F959E2  ee 0c 00 00
	pushw hl                                             ; F959E6  2b
	cpw	(xiz+8), 0x001f                              ; F959E7  9e 08 3f 1f 00
	jr ugt, .LF95A16                                         ; F959EC  6b 28
	ld h, 0x01:opc                                          ; F959EE  26 01
	ld BC,(XIZ+0x0a)                                     ; F959F0  9e 0a 21
	and BC,0x0080                                        ; F959F3  d9 cc 80 00
	jr nz, .LF959FB                                          ; F959F7  6e 02
	ld h, 0x00:opc                                          ; F959F9  26 00
.LF959FB:
	push 0x00                                            ; F959FB  09 00
	push H                                               ; F959FD  ce 04
	ldw bc, 0x04                                         ; F959FF  31 04 00
	mul	xbc, (xiz+8)                                 ; F95A02  9e 08 41
	add XBC,ScreenObjF40130_ButtonHandlers                        ; F95A05  e9 c8 15 5d f9 00
	ld XBC,(XBC)                                         ; F95A0B  a1 21
	lda xiy, (.LF95A15:24)                               ; F95A0D  f2 15 5a f9 35
	push XIY                                             ; F95A12  3d
	jp (xbc)                                             ; F95A13  b1 d8
.LF95A15:
	popw bc                                              ; F95A15  49
.LF95A16:
	popw hl                                              ; F95A16  4b
	unlk XIZ                                             ; F95A17  ee 0d
	ret                                                  ; F95A19  0e
; SoftKeyCol1_DebugMonitor -- SOFT KEY column 1 on the DEBUG MONITOR: step address digit (bits 23-20 of (0x2846)) down (lower key) or up (upper key)
; Evidence: ScreenObjF40130_ButtonHandlers [0x00] and [0x11]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x00 = SOFT KEY column 1; [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; H = 0x81 when (XIZ+0x08) != 0 (lower key) else 0x01; the digit and H go to 0x60A000/1, DebugMonitor_StepHexDigit (-1/+1 via SignedNibbleDelta_Table),
; the digit is merged back into (0x2846), `set 3,(0x2075)`, and DebugMonitor_PrintDumpPage redraws the dump.
SoftKeyCol1_DebugMonitor:   ; entry: screen button-handler table
	link XIZ,0xfff8                                      ; F95A1A  ee 0c f8 ff
	pushw hl                                             ; F95A1E  2b
	push XIX                                             ; F95A1F  3c
	lda xix, (0x60a000:24)                               ; F95A20  f2 00 a0 60 34
	set	3, (UI_RequestBits:16)                               ; F95A25  f1 75 20 bb
	ld h, 0x81:opc                                          ; F95A29  26 81
	cp (XIZ+0x08),0x00                                   ; F95A2B  8e 08 3f 00
	jr nz, .LF95A33                                          ; F95A2F  6e 02
	ld h, 0x01:opc                                          ; F95A31  26 01
.LF95A33:
	ld xiy, (0x2846:16)                                 ; F95A33  e1 46 28 25
	srl xiy, 16                                        ; F95A37  ed ef 00
	and XIY,0x000000f0                                   ; F95A3A  ed cc f0 00 00 00
	srl xiy, 0x04                                        ; F95A40  ed ef 04
	ld_erpb_rr c, 0xf4                                   ; F95A43  c7 f4 8b   ld C,IYL
	ld (XIX),C                                           ; F95A46  b4 43
	ld (XIX+0x01),H                                      ; F95A48  bc 01 46
	call DebugMonitor_StepHexDigit                                      ; F95A4B  1d 9d 4d f9
	ld C,(XIX)                                           ; F95A4F  84 23
	sll c, 0x04                                          ; F95A51  cb ee 04
	extz BC                                              ; F95A54  d9 12
	extz XBC                                             ; F95A56  e9 12
	ld (xiz-4), xbc                                      ; F95A58  be fc 61
	ld xwa, (0x2846:16)                                 ; F95A5B  e1 46 28 20
	and XWA,0x000fffff                                   ; F95A5F  e8 cc ff ff 0f 00
	ld (xiz-8), xwa                                      ; F95A65  be f8 60
	sll xbc, 16                                        ; F95A68  e9 ee 00
	or	xbc, (xiz-8)                                 ; F95A6B  ae f8 e1
	ld (0x2846:16), xbc                                 ; F95A6E  f1 46 28 61
	calr DebugMonitor_PrintDumpPage                                          ; F95A72  1e b8 01
	pop XIX                                              ; F95A75  5c
	popw hl                                              ; F95A76  4b
	unlk XIZ                                             ; F95A77  ee 0d
	ret                                                  ; F95A79  0e
; SoftKeyCol2_DebugMonitor -- SOFT KEY column 2 on the DEBUG MONITOR: step address digit (bits 19-16 of (0x2846)) down (lower key) or up (upper key)
; Evidence: ScreenObjF40130_ButtonHandlers [0x01] and [0x12]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x01 = SOFT KEY column 2; [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; H = 0x81 when (XIZ+0x08) != 0 (lower key) else 0x01; the digit and H go to 0x60A000/1, DebugMonitor_StepHexDigit (-1/+1 via SignedNibbleDelta_Table),
; the digit is merged back into (0x2846), `set 3,(0x2075)`, and DebugMonitor_PrintDumpPage redraws the dump.
SoftKeyCol2_DebugMonitor:   ; entry: screen button-handler table
	link XIZ,0xfff8                                      ; F95A7A  ee 0c f8 ff
	pushw hl                                             ; F95A7E  2b
	push XIX                                             ; F95A7F  3c
	lda xix, (0x60a000:24)                               ; F95A80  f2 00 a0 60 34
	set	3, (UI_RequestBits:16)                               ; F95A85  f1 75 20 bb
	ld h, 0x81:opc                                          ; F95A89  26 81
	cp (XIZ+0x08),0x00                                   ; F95A8B  8e 08 3f 00
	jr nz, .LF95A93                                          ; F95A8F  6e 02
	ld h, 0x01:opc                                          ; F95A91  26 01
.LF95A93:
	ld xiy, (0x2846:16)                                 ; F95A93  e1 46 28 25
	srl xiy, 16                                        ; F95A97  ed ef 00
	ld_erpb_rr c, 0xf4                                   ; F95A9A  c7 f4 8b   ld C,IYL
	and C,0x0f                                           ; F95A9D  cb cc 0f
	ld (XIX),C                                           ; F95AA0  b4 43
	ld (XIX+0x01),H                                      ; F95AA2  bc 01 46
	call DebugMonitor_StepHexDigit                                      ; F95AA5  1d 9d 4d f9
	ld C,(XIX)                                           ; F95AA9  84 23
	extz BC                                              ; F95AAB  d9 12
	extz XBC                                             ; F95AAD  e9 12
	ld (xiz-4), xbc                                      ; F95AAF  be fc 61
	ld xwa, (0x2846:16)                                 ; F95AB2  e1 46 28 20
	and XWA,MASK_CLEAR_BITS16_19                                   ; F95AB6  e8 cc ff ff f0 00
	ld (xiz-8), xwa                                      ; F95ABC  be f8 60
	sll xbc, 16                                        ; F95ABF  e9 ee 00
	or	xbc, (xiz-8)                                 ; F95AC2  ae f8 e1
	ld (0x2846:16), xbc                                 ; F95AC5  f1 46 28 61
	calr DebugMonitor_PrintDumpPage                                          ; F95AC9  1e 61 01
	pop XIX                                              ; F95ACC  5c
	popw hl                                              ; F95ACD  4b
	unlk XIZ                                             ; F95ACE  ee 0d
	ret                                                  ; F95AD0  0e
; SoftKeyCol3_DebugMonitor -- SOFT KEY column 3 on the DEBUG MONITOR: step address digit (bits 15-12 of (0x2846)) down (lower key) or up (upper key)
; Evidence: ScreenObjF40130_ButtonHandlers [0x02] and [0x13]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x02 = SOFT KEY column 3; [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; H = 0x81 when (XIZ+0x08) != 0 (lower key) else 0x01; the digit and H go to 0x60A000/1, DebugMonitor_StepHexDigit (-1/+1 via SignedNibbleDelta_Table),
; the digit is merged back into (0x2846), `set 3,(0x2075)`, and DebugMonitor_PrintDumpPage redraws the dump.
SoftKeyCol3_DebugMonitor:   ; entry: screen button-handler table
	link XIZ,0xfffc                                      ; F95AD1  ee 0c fc ff
	pushw hl                                             ; F95AD5  2b
	push XIX                                             ; F95AD6  3c
	lda xix, (0x60a000:24)                               ; F95AD7  f2 00 a0 60 34
	set	3, (UI_RequestBits:16)                               ; F95ADC  f1 75 20 bb
	ld h, 0x81:opc                                          ; F95AE0  26 81
	cp (XIZ+0x08),0x00                                   ; F95AE2  8e 08 3f 00
	jr nz, .LF95AEA                                          ; F95AE6  6e 02
	ld h, 0x01:opc                                          ; F95AE8  26 01
.LF95AEA:
	ld xbc, (0x2846:16)                                 ; F95AEA  e1 46 28 21
	and XBC,0x0000f000                                   ; F95AEE  e9 cc 00 f0 00 00
	srl xbc, 0x0c                                        ; F95AF4  e9 ef 0c
	ld (XIX),C                                           ; F95AF7  b4 43
	ld (XIX+0x01),H                                      ; F95AF9  bc 01 46
	call DebugMonitor_StepHexDigit                                      ; F95AFC  1d 9d 4d f9
	ld C,(XIX)                                           ; F95B00  84 23
	extz BC                                              ; F95B02  d9 12
	sll bc, 0x0c                                         ; F95B04  d9 ee 0c
	extz XBC                                             ; F95B07  e9 12
	ld (xiz-4), xbc                                      ; F95B09  be fc 61
	ld xwa, (0x2846:16)                                 ; F95B0C  e1 46 28 20
	and XWA,MASK_CLEAR_BITS12_15                                   ; F95B10  e8 cc ff 0f ff 00
	or XBC,XWA                                           ; F95B16  e8 e1
	ld (0x2846:16), xbc                                 ; F95B18  f1 46 28 61
	calr DebugMonitor_PrintDumpPage                                          ; F95B1C  1e 0e 01
	pop XIX                                              ; F95B1F  5c
	popw hl                                              ; F95B20  4b
	unlk XIZ                                             ; F95B21  ee 0d
	ret                                                  ; F95B23  0e
; SoftKeyCol4_DebugMonitor -- SOFT KEY column 4 on the DEBUG MONITOR: step address digit (bits 11-8 of (0x2846)) down (lower key) or up (upper key)
; Evidence: ScreenObjF40130_ButtonHandlers [0x03] and [0x14]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x03 = SOFT KEY column 4; [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; H = 0x81 when (XIZ+0x08) != 0 (lower key) else 0x01; the digit and H go to 0x60A000/1, DebugMonitor_StepHexDigit (-1/+1 via SignedNibbleDelta_Table),
; the digit is merged back into (0x2846), `set 3,(0x2075)`, and DebugMonitor_PrintDumpPage redraws the dump.
SoftKeyCol4_DebugMonitor:   ; entry: screen button-handler table
	link XIZ,0xfffc                                      ; F95B24  ee 0c fc ff
	pushw hl                                             ; F95B28  2b
	push XIX                                             ; F95B29  3c
	lda xix, (0x60a000:24)                               ; F95B2A  f2 00 a0 60 34
	set	3, (UI_RequestBits:16)                               ; F95B2F  f1 75 20 bb
	ld h, 0x81:opc                                          ; F95B33  26 81
	cp (XIZ+0x08),0x00                                   ; F95B35  8e 08 3f 00
	jr nz, .LF95B3D                                          ; F95B39  6e 02
	ld h, 0x01:opc                                          ; F95B3B  26 01
.LF95B3D:
	ld xbc, (0x2846:16)                                 ; F95B3D  e1 46 28 21
	and XBC,0x00000f00                                   ; F95B41  e9 cc 00 0f 00 00
	srl xbc, 0x08                                        ; F95B47  e9 ef 08
	ld (XIX),C                                           ; F95B4A  b4 43
	ld (XIX+0x01),H                                      ; F95B4C  bc 01 46
	call DebugMonitor_StepHexDigit                                      ; F95B4F  1d 9d 4d f9
	ld C,(XIX)                                           ; F95B53  84 23
	extz BC                                              ; F95B55  d9 12
	sll bc, 0x08                                         ; F95B57  d9 ee 08
	extz XBC                                             ; F95B5A  e9 12
	ld (xiz-4), xbc                                      ; F95B5C  be fc 61
	ld xwa, (0x2846:16)                                 ; F95B5F  e1 46 28 20
	and XWA,MASK_CLEAR_BITS8_11                                   ; F95B63  e8 cc ff f0 ff 00
	or XBC,XWA                                           ; F95B69  e8 e1
	ld (0x2846:16), xbc                                 ; F95B6B  f1 46 28 61
	calr DebugMonitor_PrintDumpPage                                            ; F95B6F  1e bb 00
	pop XIX                                              ; F95B72  5c
	popw hl                                              ; F95B73  4b
	unlk XIZ                                             ; F95B74  ee 0d
	ret                                                  ; F95B76  0e
; SoftKeyCol5_DebugMonitor -- SOFT KEY column 5 on the DEBUG MONITOR: step address digit (bits 7-4 of (0x2846)) down (lower key) or up (upper key)
; Evidence: ScreenObjF40130_ButtonHandlers [0x04] and [0x15]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x04 = SOFT KEY column 5; [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; H = 0x81 when (XIZ+0x08) != 0 (lower key) else 0x01; the digit and H go to 0x60A000/1, DebugMonitor_StepHexDigit (-1/+1 via SignedNibbleDelta_Table),
; the digit is merged back into (0x2846), `set 3,(0x2075)`, and DebugMonitor_PrintDumpPage redraws the dump.
SoftKeyCol5_DebugMonitor:   ; entry: screen button-handler table
	link XIZ,0xfffc                                      ; F95B77  ee 0c fc ff
	pushw hl                                             ; F95B7B  2b
	push XIX                                             ; F95B7C  3c
	lda xix, (0x60a000:24)                               ; F95B7D  f2 00 a0 60 34
	set	3, (UI_RequestBits:16)                               ; F95B82  f1 75 20 bb
	ld h, 0x81:opc                                          ; F95B86  26 81
	cp (XIZ+0x08),0x00                                   ; F95B88  8e 08 3f 00
	jr nz, .LF95B90                                          ; F95B8C  6e 02
	ld h, 0x01:opc                                          ; F95B8E  26 01
.LF95B90:
	ld xbc, (0x2846:16)                                 ; F95B90  e1 46 28 21
	and XBC,0x000000f0                                   ; F95B94  e9 cc f0 00 00 00
	srl xbc, 0x04                                        ; F95B9A  e9 ef 04
	ld (XIX),C                                           ; F95B9D  b4 43
	ld (XIX+0x01),H                                      ; F95B9F  bc 01 46
	call DebugMonitor_StepHexDigit                                      ; F95BA2  1d 9d 4d f9
	ld C,(XIX)                                           ; F95BA6  84 23
	sll c, 0x04                                          ; F95BA8  cb ee 04
	extz BC                                              ; F95BAB  d9 12
	extz XBC                                             ; F95BAD  e9 12
	ld (xiz-4), xbc                                      ; F95BAF  be fc 61
	ld xwa, (0x2846:16)                                 ; F95BB2  e1 46 28 20
	and XWA,MASK_CLEAR_BITS4_7                                   ; F95BB6  e8 cc 0f ff ff 00
	or XBC,XWA                                           ; F95BBC  e8 e1
	ld (0x2846:16), xbc                                 ; F95BBE  f1 46 28 61
	calr DebugMonitor_PrintDumpPage                                            ; F95BC2  1e 68 00
	pop XIX                                              ; F95BC5  5c
	popw hl                                              ; F95BC6  4b
	unlk XIZ                                             ; F95BC7  ee 0d
	ret                                                  ; F95BC9  0e
; SoftKeyCol6_DebugMonitor -- SOFT KEY column 6 on the DEBUG MONITOR: step address digit (bits 3-0 of (0x2846)) down (lower key) or up (upper key)
; Evidence: ScreenObjF40130_ButtonHandlers [0x05] and [0x16]; Dispatch_FF3D39's CONTROL LEGEND gives code 0x05 = SOFT KEY column 6; [c+0x11] is the same column's code re-pressed while already held (PanelButton_InterlockMask32 header; notes/proma-2026-09-25/gen_held_sets.py S1-S4).
; H = 0x81 when (XIZ+0x08) != 0 (lower key) else 0x01; the digit and H go to 0x60A000/1, DebugMonitor_StepHexDigit (-1/+1 via SignedNibbleDelta_Table),
; the digit is merged back into (0x2846), `set 3,(0x2075)`, and DebugMonitor_PrintDumpPage redraws the dump.
SoftKeyCol6_DebugMonitor:   ; entry: screen button-handler table
	link XIZ,0xfffc                                      ; F95BCA  ee 0c fc ff
	pushw hl                                             ; F95BCE  2b
	push XIX                                             ; F95BCF  3c
	lda xix, (0x60a000:24)                               ; F95BD0  f2 00 a0 60 34
	set	3, (UI_RequestBits:16)                               ; F95BD5  f1 75 20 bb
	ld h, 0x81:opc                                          ; F95BD9  26 81
	cp (XIZ+0x08),0x00                                   ; F95BDB  8e 08 3f 00
	jr nz, .LF95BE3                                          ; F95BDF  6e 02
	ld h, 0x01:opc                                          ; F95BE1  26 01
.LF95BE3:
	ld c, (0x2846:16)                                   ; F95BE3  c1 46 28 23
	and C,0x0f                                           ; F95BE7  cb cc 0f
	ld (XIX),C                                           ; F95BEA  b4 43
	ld (XIX+0x01),H                                      ; F95BEC  bc 01 46
	call DebugMonitor_StepHexDigit                                      ; F95BEF  1d 9d 4d f9
	ld C,(XIX)                                           ; F95BF3  84 23
	extz BC                                              ; F95BF5  d9 12
	extz XBC                                             ; F95BF7  e9 12
	ld (xiz-4), xbc                                      ; F95BF9  be fc 61
	ld xwa, (0x2846:16)                                 ; F95BFC  e1 46 28 20
	and XWA,MASK_CLEAR_BITS0_3                          ; F95C00  e8 cc f0 ff ff 00
	or XBC,XWA                                           ; F95C06  e8 e1
	ld (0x2846:16), xbc                                 ; F95C08  f1 46 28 61
	calr DebugMonitor_PrintDumpPage                                            ; F95C0C  1e 1e 00
	pop XIX                                              ; F95C0F  5c
	popw hl                                              ; F95C10  4b
	unlk XIZ                                             ; F95C11  ee 0d
	ret                                                  ; F95C13  0e
T_F4013C_Nop:
	ret                                                  ; F95C14  0e
; ExitKey_SineWaveCheckModeAndDebugMonitor -- EXIT on SINE WAVE CHECK MODE and on the DEBUG MONITOR: leave through the auto-return timer
; Evidence: entry [0x0F] of ScreenButtonHandlers_SineWaveCheckMode and of ScreenObjF40130_ButtonHandlers; Dispatch_FF3D39's CONTROL LEGEND gives code 0x0F = EXIT.  Acts when
; (XIZ+0x08) == 0 (bit 7 clear, EXIT's only pair position): `and (0x2075),0x77`, (0x209A) = 1 (PanelState_TakePendingHoldTime preloads the timer).
ExitKey_SineWaveCheckModeAndDebugMonitor:   ; entry: screen button-handler table
	link XIZ,0x0000                                      ; F95C15  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F95C19  8e 08 3f 00
	jr nz, .LF95C29                                          ; F95C1D  6e 0a
	and	(UI_RequestBits:16), 0x77                            ; F95C1F  c1 75 20 3c 77
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F95C24  f1 9a 20 00 01
.LF95C29:
	unlk XIZ                                             ; F95C29  ee 0d
	ret                                                  ; F95C2B  0e
ScreenButtonHandlers_SineWaveCheckMode_Nop0:   ; entry: screen button-handler table
	ret                                                  ; F95C2C  0e
; DebugMonitor_PrintDumpPage -- print the DEBUG MONITOR page: blank line, title, blank line, 16 hex-dump
; rows from (0x2846), blank line
; Evidence: XIX = DebugMonitor_PrintBlankLine (prints 40 spaces via LCD_PrintLine40_AdvanceRow) is entered three
; times by `lda xiy,<ret> / push XIY / jp (xix)`; between them `call Print_DebugMonitor` (0xF95C46) and `call
; sub_F94CBB` (0xF95C52: 16 x sub_F94CDE, address + 8 hex bytes, (0x284A) += 8). Zeroes (0x2540), (0x284F).
; Callers: sub_F959C8 (T_ScreenEnter_DebugMonitor screen ENTER) and the six digit editors sub_F95A1A..sub_F95BCA.
DebugMonitor_PrintDumpPage:
	push XIX                                             ; F95C2D  3c
	lda xix, (DebugMonitor_PrintBlankLine:24)            ; F95C2E  f2 8f 4c f9 34
	ld (LCD_CurrentLayer:16), 0x00                                 ; F95C33  f1 40 25 00 00
	ldw (0x284f:16), 0x00                                ; F95C38  f1 4f 28 02 00 00
	lda xiy, (DebugMonitor_PrintDumpPage__F95C46:24)                               ; F95C3E  f2 46 5c f9 35
	push XIY                                             ; F95C43  3d
	jp (xix)                                             ; F95C44  b4 d8
DebugMonitor_PrintDumpPage__F95C46:
	call Print_DebugMonitor                                      ; F95C46  1d 4c 4c f9
	lda xiy, (DebugMonitor_PrintDumpPage__F95C52:24)                               ; F95C4A  f2 52 5c f9 35
	push XIY                                             ; F95C4F  3d
	jp (xix)                                             ; F95C50  b4 d8
DebugMonitor_PrintDumpPage__F95C52:
	call DebugMonitor_PrintHexDump                                      ; F95C52  1d bb 4c f9
	lda xiy, (DebugMonitor_PrintDumpPage__F95C5E:24)                               ; F95C56  f2 5e 5c f9 35
	push XIY                                             ; F95C5B  3d
	jp (xix)                                             ; F95C5C  b4 d8
DebugMonitor_PrintDumpPage__F95C5E:
	pop XIX                                              ; F95C5E  5c
	ret                                                  ; F95C5F  0e
; Four small tables the test-mode routines index -- data, not code (they were decoded as `normal`,
; `swi 7`, `retd` ...).  Extents are the readers' strides and counts:
; TestMode_DisplayCycleScreenIds -- 8 screen ids; TestMode_DisplayCycleTick (`cp B,8`) posts entry B
;          as UI_Request with UI_Request_Hi = 0x40
TestMode_DisplayCycleScreenIds:	.byte	0x01, 0x01, 0xa0, 0xa1, 0x41, 0x71, 0x02, 0x06	; F95C60
; PanelSwLedCheck_LedGroups -- the LED group bytes PanelSwLedCheck_AllLedsOn / _AllLedsOff walk
PanelSwLedCheck_LedGroups:	.byte	0xff, 0x00, 0xff, 0x01, 0xff, 0x02, 0xff, 0x03, 0xff, 0x04, 0x03, 0x05, 0x0f, 0x06, 0x02, 0x07, 0xff, 0xff	; F95C68
; CheckingDevice_RomIdRecord -- one 9-byte {address, expected LE32, failure bit} record for
;          CheckingDevice_RomIdTest: the build tag must start "wsaa"
CheckingDevice_RomIdRecord:	.long	BUILD_TAG	; F95C7A
	.ascii	"wsaa"	; F95C7E
	.byte	0x01	; F95C82
; CheckingDevice_RamTestRecords -- two 9-byte {start, length, failure bit} records for CheckingDevice_RamTest
CheckingDevice_RamTestRecords:	.long	0x00000100, 0x00000100	; F95C83
	.byte	0x01	; F95C8B
	.long	0x00600000, 0x00001000	; F95C8C
	.byte	0x02	; F95C94
; ---------------------------------------------------------------------
; ScreenButtonHandlers_SineWaveCheckMode -- 32 LE32 handlers, one per panel
;          event code, for the screen object at prom_b 0xF400F0
;          (Paint_SineWaveCheckMode / ScreenLeave_ / ScreenButton_).
; Read by: ScreenButton_SineWaveCheckMode (0xF95891, the object's +8
;          BUTTON slot T_ScreenButton_SineWaveCheckMode): `cp (XIZ+8),0x001F / jr ugt` -- COUNT 32 --
;          then `ldw BC,4 / mul BC,(XIZ+8) / add XBC,<this> / ld XBC,(XBC)`
;          and a call with H = bit 7 of (XIZ+0x0A).  Codes as
;          PanelButton_Route produces them (see Dispatch_FF3D39's legend).
;          24 slots are the default 0xF95C2C, a lone `ret`.
; (notes/proma-2026-09-25/gen_button_tables.py, checks K1-K5)
; ★ 2026-09-25 (lane proma): this span was PtrTables_F95C95; its header,
;          kept verbatim above ScreenButtonHandlers_StaleCopy, left the third
;          table and the stray byte open.  Both are answered there.
; ---------------------------------------------------------------------
ScreenButtonHandlers_SineWaveCheckMode:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x00]
	on_key	KEY_SoftKeyCol2,	ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x01]
	on_key	KEY_SoftKeyCol3,	ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x02]
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_SineWaveCheckMode	; [code 0x03]
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_SineWaveCheckMode	; [code 0x04]
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_SineWaveCheckMode	; [code 0x05]
	on_key	KEY_SoftKeyCol7,	ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x06]
	on_key	KEY_SoftKeyCol8,	ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x07]
	on_key	KEY_LcdRow1,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x08]
	on_key	KEY_LcdRow2,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x09]
	on_key	KEY_LcdRow3,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0A]
	on_key	KEY_LcdRow4,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0B]
	on_key	KEY_LcdRow5,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0C]
	on_key	KEY_MinusPlus,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0D]
	on_key	KEY_Code0E,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0E]
	on_key	KEY_Exit,		ExitKey_SineWaveCheckModeAndDebugMonitor	; [code 0x0F]
	on_key	KEY_Page,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x10]
	on_key	KEY_Code11,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x11]
	on_key	KEY_Code12,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x12]
	on_key	KEY_Code13,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x13]
	on_key	KEY_Code14,		SoftKeyCol4_SineWaveCheckMode	; [code 0x14]
	on_key	KEY_Code15,		SoftKeyCol5_SineWaveCheckMode	; [code 0x15]
	on_key	KEY_Code16,		SoftKeyCol6_SineWaveCheckMode	; [code 0x16]
	on_key	KEY_Code17,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x17]
	on_key	KEY_Code18,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x18]
	on_key	KEY_Code19,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x19]
	on_key	KEY_Code1A,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1A]
	on_key	KEY_NumberPad,		NumberPadKey_SineWaveCheckMode	; [code 0x1B]
	on_key	KEY_Code1C,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1C]
	on_key	KEY_Code1D,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1D]
	on_key	KEY_Compare,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1E]
	on_key	KEY_Code1F,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1F]
	keymap_end

; ---------------------------------------------------------------------
; ScreenObjF40130_ButtonHandlers -- 32 LE32 handlers, one per panel event
;          code, for the screen object at prom_b 0xF40130 (+0 ScreenEnter_DebugMonitor,
;          +4 T_F40134_Nop, +8 ScreenButton_DebugMonitor).
; Read by: ScreenButton_DebugMonitor (0xF959E2, slot T_ScreenButton_DebugMonitor), the same five instructions
;          as ScreenButton_SineWaveCheckMode with this base at 0xF95A05.
;          19 slots are the default 0xF95C2C.
; (checks K1, K2)
; ---------------------------------------------------------------------
ScreenObjF40130_ButtonHandlers:
	keymap_begin
	on_key	KEY_SoftKeyCol1,	SoftKeyCol1_DebugMonitor	; [code 0x00]
	on_key	KEY_SoftKeyCol2,	SoftKeyCol2_DebugMonitor	; [code 0x01]
	on_key	KEY_SoftKeyCol3,	SoftKeyCol3_DebugMonitor	; [code 0x02]
	on_key	KEY_SoftKeyCol4,	SoftKeyCol4_DebugMonitor	; [code 0x03]
	on_key	KEY_SoftKeyCol5,	SoftKeyCol5_DebugMonitor	; [code 0x04]
	on_key	KEY_SoftKeyCol6,	SoftKeyCol6_DebugMonitor	; [code 0x05]
	on_key	KEY_SoftKeyCol7,	ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x06]
	on_key	KEY_SoftKeyCol8,	ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x07]
	on_key	KEY_LcdRow1,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x08]
	on_key	KEY_LcdRow2,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x09]
	on_key	KEY_LcdRow3,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0A]
	on_key	KEY_LcdRow4,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0B]
	on_key	KEY_LcdRow5,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0C]
	on_key	KEY_MinusPlus,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0D]
	on_key	KEY_Code0E,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x0E]
	on_key	KEY_Exit,		ExitKey_SineWaveCheckModeAndDebugMonitor	; [code 0x0F]
	on_key	KEY_Page,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x10]
	on_key	KEY_Code11,		SoftKeyCol1_DebugMonitor	; [code 0x11]
	on_key	KEY_Code12,		SoftKeyCol2_DebugMonitor	; [code 0x12]
	on_key	KEY_Code13,		SoftKeyCol3_DebugMonitor	; [code 0x13]
	on_key	KEY_Code14,		SoftKeyCol4_DebugMonitor	; [code 0x14]
	on_key	KEY_Code15,		SoftKeyCol5_DebugMonitor	; [code 0x15]
	on_key	KEY_Code16,		SoftKeyCol6_DebugMonitor	; [code 0x16]
	on_key	KEY_Code17,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x17]
	on_key	KEY_Code18,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x18]
	on_key	KEY_Code19,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x19]
	on_key	KEY_Code1A,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1A]
	on_key	KEY_NumberPad,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1B]
	on_key	KEY_Code1C,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1C]
	on_key	KEY_Code1D,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1D]
	on_key	KEY_Compare,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1E]
	on_key	KEY_Code1F,		ScreenButtonHandlers_SineWaveCheckMode_Nop0	; [code 0x1F]
	keymap_end

; ---------------------------------------------------------------------
; ScreenButtonHandlers_StaleCopy -- 1 byte + 59 LE32: a copy of BOTH tables
;          above from another build, unreachable here.
;   +0      0x00, the top byte of the copy's word 4 (every pointer here has
;           a 0x00 top byte); its first 19 bytes lie under the live table.
;   words 0..26   = the first table's words 5..31: default exactly where it
;           is default, handlers at the same codes -- except code 27, whose
;           handler (0xF95971) only the live table has (check K4).
;   words 27..58  = the second table, every value + 0xED (check K3).
; Its default, 0xF95D19, lies INSIDE ScreenObjF40130_ButtonHandlers -- data
;          in this image -- and no address in this span is named in either
;          CPU-1 image (check K5): nothing reads it.  They are the other
;          build's addresses, so words 27..58 are written as the LIVE target
;          plus 0xED (`SoftKeyCol1_DebugMonitor + 0xed` ...): all 32 land exactly on a label
;          at value - 0xED (scripts/tools/respell_stale_table.py, 2026-10-03),
;          which also retired four labels an earlier pass had put mid-routine
;          to spell them as this image's addresses (sub_F95AD1__F95B07 ...).
;          Words 0..26 are written the same way, word i against the first table's
;          word i+5: + 0xED for the default and ExitKey; SoftKeyCol4/5/6_SineWaveCheckMode
;          moved by 0x108/0x109/0x10A, consecutive in both builds (0x38 apart here, 0x39
;          there).  Word 22 holds the old default where the live table has
;          NumberPadKey_SineWaveCheckMode.  The two mid-routine labels an earlier pass had
;          put at 0xF95A43 and 0xF959D1 to spell them are retired (2026-10-03).
; ★ This answers the old header's closing question about the third table
;          and the stray byte; that line is replaced, the rest of the old
;          header follows verbatim.
; (checks K3-K5)
; ---------------------------------------------------------------------
; The former span's header (PtrTables_F95C95), verbatim:
; PtrTables_F95C95 -- 493 bytes holding THREE pointer tables and one stray byte
;
; Emitted as `.byte`, not `.long`, and that is the claim: the region is NOT a
; whole number of 32-bit words (493 = 128 + 128 + 1 + 236) and the third table
; is offset by ONE byte from the second.  A `.long` rendering would have to
; invent an alignment the ROM does not have.
;
;   0xF95C95-0xF95D14   32 LE32 pointers.  Read by 0xF958B4
;                       `mul XBC,(XIZ+0x08) / add XBC,0x00F95C95 /
;                       ld XBC,(XBC) / ... / jp T,XBC`, bounded by that
;                       routine's own `cp (XIZ+0x08),0x001F / jr UGT` at
;                       0xF95896 -- 32 entries.
;   0xF95D15-0xF95D94   32 more.  Read by the sibling routine at 0xF958C9,
;                       which names 0xF95D15 at 0xF95A05
;                       (`add XBC,0x00F95D15`, e9 c8 15 5d f9 00).
;                       ⚠ This line said 0xF95A07 until 2026-08-25 -- the third
;                       byte of that instruction, i.e. the first byte of its
;                       32-bit operand, which is where a literal scan lands.
;                       Found by `notes/prom_a_audit_callsites.py --evidence`.
;   0xF95D95            ONE byte, 0x00, that belongs to neither.
;   0xF95D96-0xF95E81   59 LE32 pointers.  NO reader located.
;
; ENTRY COUNTS: 32 and 32 from the two readers' own bounds; 59 from
;          notes/prom_a_ptr_tables.py's shape run, with no bound to check it
;          against -- stated as the weaker of the three.
; ★ LAST-ENTRY TEST for the region as a whole: the word at 0xF95E82 is
;          0x0E0E0E0E, the start of a RET pad, so the run cannot be extended.
; Evidence: the two readers, the two bounds, the shape run and its null control.
; ---------------------------------------------------------------------
ScreenButtonHandlers_StaleCopy:
	.byte 0x00                                       ; F95D95  top byte of copy word 4
	.long SoftKeyCol6_SineWaveCheckMode + 0x10a                                  ; F95D96  [ 0]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95D9A  [ 1]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95D9E  [ 2]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DA2  [ 3]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DA6  [ 4]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DAA  [ 5]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DAE  [ 6]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DB2  [ 7]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DB6  [ 8]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DBA  [ 9]
	.long ExitKey_SineWaveCheckModeAndDebugMonitor + 0xed                        ; F95DBE  [10]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DC2  [11]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DC6  [12]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DCA  [13]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DCE  [14]
	.long SoftKeyCol4_SineWaveCheckMode + 0x108                                  ; F95DD2  [15]
	.long SoftKeyCol5_SineWaveCheckMode + 0x109                                  ; F95DD6  [16]
	.long SoftKeyCol6_SineWaveCheckMode + 0x10a                                  ; F95DDA  [17]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DDE  [18]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DE2  [19]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DE6  [20]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DEA  [21]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DEE  [22]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DF2  [23]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DF6  [24]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DFA  [25]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                     ; F95DFE  [26]
	.long SoftKeyCol1_DebugMonitor + 0xed                                 ; F95E02  [27]
	.long SoftKeyCol2_DebugMonitor + 0xed                                 ; F95E06  [28]
	.long SoftKeyCol3_DebugMonitor + 0xed                                 ; F95E0A  [29]
	.long SoftKeyCol4_DebugMonitor + 0xed                                 ; F95E0E  [30]
	.long SoftKeyCol5_DebugMonitor + 0xed                                 ; F95E12  [31]
	.long SoftKeyCol6_DebugMonitor + 0xed                                 ; F95E16  [32]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E1A  [33]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E1E  [34]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E22  [35]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E26  [36]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E2A  [37]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E2E  [38]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E32  [39]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E36  [40]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E3A  [41]
	.long ExitKey_SineWaveCheckModeAndDebugMonitor + 0xed                                 ; F95E3E  [42]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E42  [43]
	.long SoftKeyCol1_DebugMonitor + 0xed                                 ; F95E46  [44]
	.long SoftKeyCol2_DebugMonitor + 0xed                                 ; F95E4A  [45]
	.long SoftKeyCol3_DebugMonitor + 0xed                                 ; F95E4E  [46]
	.long SoftKeyCol4_DebugMonitor + 0xed                                 ; F95E52  [47]
	.long SoftKeyCol5_DebugMonitor + 0xed                                 ; F95E56  [48]
	.long SoftKeyCol6_DebugMonitor + 0xed                                 ; F95E5A  [49]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E5E  [50]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E62  [51]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E66  [52]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E6A  [53]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E6E  [54]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E72  [55]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E76  [56]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E7A  [57]
	.long ScreenButtonHandlers_SineWaveCheckMode_Nop0 + 0xed                                 ; F95E7E  [58]
	ret                                                  ; F95E82  0e

; 0xF95E83-0xF96000 -- 382 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 382, 1, 0x0E

	nop                                                  ; F96001  00
	nop                                                  ; F96002  00
	nop                                                  ; F96003  00
	ret                                                  ; F96004  0e
	nop                                                  ; F96005  00
	nop                                                  ; F96006  00
	nop                                                  ; F96007  00
	ret                                                  ; F96008  0e
	nop                                                  ; F96009  00
	nop                                                  ; F9600A  00
	nop                                                  ; F9600B  00
	ret                                                  ; F9600C  0e
	nop                                                  ; F9600D  00
	nop                                                  ; F9600E  00
	nop                                                  ; F9600F  00
	ret                                                  ; F96010  0e
	nop                                                  ; F96011  00
	nop                                                  ; F96012  00
	nop                                                  ; F96013  00
	ret                                                  ; F96014  0e
	nop                                                  ; F96015  00
	nop                                                  ; F96016  00
	nop                                                  ; F96017  00
; ==== 0xF96018-0xF99021 -- REACHABLE CODE ONLY, emitted by notes/gen_prom_a_cover_round1.py ====
; 8 reachable run(s), 7095 bytes framed as code.  5202 bytes that nothing reaches stay
; `.incbin` -- this round converts REACHABLE CODE, not territory.
; Boundaries: notes/reachability.py's walk, frozen against this file's own output.
; Labels are sub_XXXXXX by design: this round is COVERAGE, naming is a later goal.
; This text was assembled and byte-compared with the ROM before printing.
T_F401D4_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F96018  0e
; ParamImage_SnapshotAll -- set aside record 0x79 bytes 1-4 and record 0x91 bytes 0 and 2, then copy the
; whole 0x960-byte parameter image at 0x7620 to the snapshot at 0x608000
; Evidence: `calr .LF96024`: (0x78B3) long -> (0x2181), (0x7F4A) -> (0x2189), (0x7F4C) -> (0x218A), then
; `ld XIY,0x7620 / ld XIX,0x608000 / ld XBC,0x4B0 / ldirw` (0xF9603C-0xF9604B) -- 0x960 bytes, exactly the
; 80 records ParamImage_WriteRecordHeaders lays out at 0x7620-0x7F7F. prom_b slot T_ParamImage_SnapshotAll (slot 1 of the
; 0xF96000 group); the 0xFB1800 PatchList module calls it before its PatchList_Apply* edits.
ParamImage_SnapshotAll:   ; entry: prom_b routine directory
	calr .LF96024                                        ; F96019  1e 08 00
	ret                                                  ; F9601C  0e
; ParamImage_QueueDiffAll -- put back the cells ParamImage_SnapshotAll set aside, then queue every byte of
; the parameter image that differs from the snapshot onto the 0x2C00 event list
; Evidence: .LF9604E restores (0x7F4A)/(0x7F4C)/(0x78B3); .LF9606D queues record 0x91 byte 3 (0x7F4D) first
; (Queue2C00_AppendRegs E=0x91 D=3); .LF9608F walks the {tag,len,payload} records to +0x95E appending {tag,
; offset, new, new^old} at 0x2C00+(0x60F000), part tags 0x00-0x1F to ParamImage_QueuePartFieldChange, drain at
; cursor 0x1F1, 0xFF end. prom_b T_ParamImage_QueueDiffAll; callers 0xFB3140, 0xFE00A1 and the 0xFB1800 PatchList module.
ParamImage_QueueDiffAll:   ; entry: prom_b routine directory
	calr .LF9604E                                        ; F9601D  1e 2e 00
	ret                                                  ; F96020  0e
T_F401E8_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F96021  0e
T_F401EC_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F96022  0e
T_F401F0_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F96023  0e
.LF96024:
	ld a, (0x7f4a:16)                                   ; F96024  c1 4a 7f 21
	ld (0x2189:16), a                                   ; F96028  f1 89 21 41
	ld a, (0x7f4c:16)                                   ; F9602C  c1 4c 7f 21
	ld (0x218a:16), a                                   ; F96030  f1 8a 21 41
	ld xwa, (0x78b3:16)                                 ; F96034  e1 b3 78 20
	ld (0x2181:16), xwa                                 ; F96038  f1 81 21 60
	ld XIY,Combination_Current                                    ; F9603C  45 20 76 00 00
	ld XIX,0x00608000                                    ; F96041  44 00 80 60 00
	ld XBC,0x000004b0                                    ; F96046  41 b0 04 00 00
	ldirw                                                ; F9604B  95 11
	ret                                                  ; F9604D  0e
.LF9604E:
	ld a, (0x2189:16)                                   ; F9604E  c1 89 21 21
	ld (0x7f4a:16), a                                   ; F96052  f1 4a 7f 41
	ld a, (0x218a:16)                                   ; F96056  c1 8a 21 21
	ld (0x7f4c:16), a                                   ; F9605A  f1 4c 7f 41
	ld xwa, (0x2181:16)                                 ; F9605E  e1 81 21 20
	ld (0x78b3:16), xwa                                 ; F96062  f1 b3 78 60
	calr .LF9606D                                        ; F96066  1e 04 00
	calr .LF9608F                                        ; F96069  1e 23 00
	ret                                                  ; F9606C  0e
.LF9606D:
	ld XIY,0x00608000                                    ; F9606D  45 00 80 60 00
	ld W,(XIY+0x092d)                                    ; F96072  c3 f5 2d 09 20
	ld a, (0x7f4d:16)                                   ; F96077  c1 4d 7f 21
	cp W,A                                               ; F9607B  c9 f0
	jr z, .LF9608E                                       ; F9607D  66 0f
	ld e, 0x91:opc                                          ; F9607F  25 91
	ld d, 0x03:opc                                          ; F96081  24 03
	xor W,A                                              ; F96083  c9 d0
	call T_Queue2C00_AppendRegs                          ; F96085  1d 38 0f f4
	ld (XIY+0x092d),A                                    ; F96089  f3 f5 2d 09 41
.LF9608E:
	ret                                                  ; F9608E  0e
.LF9608F:
	ld ix, (0x60f000:24)                                ; F9608F  d2 00 f0 60 24
	extz XIX                                             ; F96094  ec 12
	xor XIY,XIY                                          ; F96096  ed d5
.LF96098:
	cp XIY,0x0000095e                                    ; F96098  ed cf 5e 09 00 00
	jrl nc, .LF96145                                     ; F9609E  7f a4 00
	and	(0x2180:16), 0xfc                            ; F960A1  c1 80 21 3c fc
	ld D,(XIY+Combination_Current)                                    ; F960A6  c3 f5 20 76 24
	cp D,0xff                                            ; F960AB  cc cf ff
	jr nz, .LF960B6                                      ; F960AE  6e 06
	inc 1,IY                                             ; F960B0  dd 61
	inc 1,IY                                             ; F960B2  dd 61
	jr .LF96098                                          ; F960B4  68 e2
.LF960B6:
	inc 1,IY                                             ; F960B6  dd 61
	xor E,E                                              ; F960B8  cd d5
	xor B,B                                              ; F960BA  ca d2
	ld C,(XIY+Combination_Current)                                    ; F960BC  c3 f5 20 76 23
	and BC,BC                                            ; F960C1  d9 c1
	jr z, .LF96140                                       ; F960C3  66 7b
.LF960C5:
	inc 1,IY                                             ; F960C5  dd 61
	ld A,(XIY+Combination_Current)                                    ; F960C7  c3 f5 20 76 21
	ld XIZ,0x00608000                                    ; F960CC  46 00 80 60 00
	cp	a, (xiz+iy)                          ; F960D1  c3 07 f8 f4 f1
	jr z, .LF9613B                                       ; F960D6  66 63
	cp IX,0x01f1                                         ; F960D8  dc cf f1 01
	jr c, .LF960F8                                       ; F960DC  67 1a
	ld (XIX+0x2c00),0xff                                 ; F960DE  f3 f1 00 2c 00 ff
	push XWA                                             ; F960E4  38
	push XBC                                             ; F960E5  39
	push XDE                                             ; F960E6  3a
	push XHL                                             ; F960E7  3b
	push XIX                                             ; F960E8  3c
	push XIY                                             ; F960E9  3d
	push XIZ                                             ; F960EA  3e
	call T_Queue2C00_DrainPassB                          ; F960EB  1d 38 00 f4
	pop XIZ                                              ; F960EF  5e
	pop XIY                                              ; F960F0  5d
	pop XIX                                              ; F960F1  5c
	pop XHL                                              ; F960F2  5b
	pop XDE                                              ; F960F3  5a
	pop XBC                                              ; F960F4  59
	pop XWA                                              ; F960F5  58
	xor XIX,XIX                                          ; F960F6  ec d4
.LF960F8:
	or	(0x60f021:24), 0x20                          ; F960F8  c2 21 f0 60 3e 20
	ld XHL,IndexTable_F96151                             ; F960FE  43 51 61 f9 00
.LF96103:
	ld W,(XHL)                                           ; F96103  83 20
	inc 1,XHL                                            ; F96105  eb 61
	cp W,D                                               ; F96107  cc f0
	jr z, .LF96112                                       ; F96109  66 07
	cp W,0xff                                            ; F9610B  c8 cf ff
	jr nz, .LF96103                                      ; F9610E  6e f3
	jr .LF96117                                          ; F96110  68 05
.LF96112:
	calr ParamImage_QueuePartFieldChange                                            ; F96112  1e 5d 00
	jr .LF9613B                                          ; F96115  68 24
.LF96117:
	ld (XIX+0x2c00),D                                    ; F96117  f3 f1 00 2c 44
	ld (XIX+0x2c01),E                                    ; F9611C  f3 f1 01 2c 45
	ld (XIX+0x2c02),A                                    ; F96121  f3 f1 02 2c 41
	ld XIZ,0x00608000                                    ; F96126  46 00 80 60 00
	xor	a, (xiz+iy)                          ; F9612B  c3 07 f8 f4 d1
	ld (XIX+0x2c03),A                                    ; F96130  f3 f1 03 2c 41
	add XIX,0x00000004                                   ; F96135  ec c8 04 00 00 00
.LF9613B:
	inc 1,E                                              ; F9613B  cd 61
	djnz16 bc, .LF960C5                                  ; F9613D  d9 1c 85
.LF96140:
	inc 1,IY                                             ; F96140  dd 61
	jrl .LF96098                                         ; F96142  78 53 ff
.LF96145:
	ld (XIX+0x2c00),0xff                                 ; F96145  f3 f1 00 2c 00 ff
	ld (0x60f000:24), ix                                ; F9614B  f2 00 f0 60 54
	ret                                                  ; F96150  0e
; ---------------------------------------------------------------------
; IndexTable_F96151 -- the byte list 0x00..0x1F, then an 0xFF terminator.
; Read by: the loop at 0xF960FE: `ld XHL,<this>`, then `ld W,(XHL) / inc XHL
;          / cp W,D / jr z` -> ParamImage_QueuePartFieldChange, else `cp W,0xFF / jr nz` -- a
;          membership test of D.  A D not in the list is stored with E and
;          A straight into the 0x2C00 queue (0xF96117-0xF96121), so the list
;          names the 32 values that get ParamImage_QueuePartFieldChange instead -- the part
;          numbers, when D is a parameter number as in that queue.
;          COUNT 33 = 32 values + the terminator the loop stops on.
;          (notes/proma-2026-09-25/gen_small_headers.py, H4)
; ---------------------------------------------------------------------
IndexTable_F96151:   ; 32 sequential bytes + 0xFF terminator, read by sub_F96062's helper (0xF960FE) via a linear scan against D
	.byte 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f, 0xff   ; F96151
; ParamImage_QueuePartFieldChange -- queue one changed byte of a part A-block record (tag D = 0x00-0x1F,
; offset E, new value A) for ParamImage_QueueDiffAll
; Evidence: offset 0 (`cp e,0 / jr z`, 0xF96172) appends TWO records, {D,1,byte 1,0x7F} then {D,0,byte 0,0xFF},
; and sets bit 0 of (0x2180); offset 1 `jr z` to ParamImage_QueueProgramBankPair; any other offset appends
; {D,E,A,A^snapshot}. Offsets 0-2 are the 3-byte PROGRAM CHANGE & BANK field (tbl:partparams, p=00).
; In: D tag, E offset, A new byte, XIY image offset, XIX queue cursor (advanced by 4 per record).
ParamImage_QueuePartFieldChange:   ; entry: reachable-run entry
	cp e, 0x00:i3                                          ; F96172  cd d8
	jr z, .LF9619F                                       ; F96174  66 29
	cp e, 0x01:i3                                          ; F96176  cd d9
	jr z, ParamImage_QueueProgramBankPair                                           ; F96178  66 77
	ld (XIX+0x2c00),D                                    ; F9617A  f3 f1 00 2c 44
	ld (XIX+0x2c01),E                                    ; F9617F  f3 f1 01 2c 45
	ld (XIX+0x2c02),A                                    ; F96184  f3 f1 02 2c 41
	ld XIZ,0x00608000                                    ; F96189  46 00 80 60 00
	xor	a, (xiz+iy)                          ; F9618E  c3 07 f8 f4 d1
	ld (XIX+0x2c03),A                                    ; F96193  f3 f1 03 2c 41
	add IX,0x0004                                        ; F96198  dc c8 04 00
	jrl .LF96256                                             ; F9619C  78 b7 00
.LF9619F:
	or	(0x2180:16), 0x01                            ; F9619F  c1 80 21 3e 01
	ld XIZ,0x00002c00                                    ; F961A4  46 00 2c 00 00
	ld	(xiz+ix), d                                  ; F961A9  f3 07 f8 f0 44
	inc 1,IX                                             ; F961AE  dc 61
	ld	(xiz+ix), 0x01                               ; F961B0  f3 07 f8 f0 00 01
	inc 1,IX                                             ; F961B6  dc 61
	ld W,(XIY+0x7621)                                    ; F961B8  c3 f5 21 76 20
; ==== 0xF961BD-0xF961F1 -- STRONG-REACHABLE CODE ONLY, emitted by notes/gen_prom_a_cover_round2.py ====
; 1 run(s), 52 bytes framed as code.  0 bytes that nothing STRONGLY reaches stay
; `.incbin` -- this round converts REACHABLE CODE, not territory.
; Boundaries: notes/reachability.py's walk over its STRONG seed classes only (CPU
; vectors, prom_b routine-directory slots, branches in decoded code), frozen against
; this file's own output.  A bare 32-bit immediate is NOT a seed here: round 1 proved
; it paints pointer tables as instructions and passes the byte gate doing it.
; Labels are sub_XXXXXX by design: this round is COVERAGE, naming is a later goal.
; This text was assembled and byte-compared with the ROM before printing.
; (sub_F961BD removed 2026-10-04: no code names it and the line above falls through into it -- part of ParamImage_QueuePartFieldChange;
;  notes/prom_a_stray_label_removal.py)  [was: entry: reachable-run entry]
	ld	(xiz+ix), w                                  ; F961BD  f3 07 f8 f0 40
	inc 1,IX                                             ; F961C2  dc 61
	ld	(xiz+ix), 0x7f                               ; F961C4  f3 07 f8 f0 00 7f
	inc 1,IX                                             ; F961CA  dc 61
	ld	(xiz+ix), d                                  ; F961CC  f3 07 f8 f0 44
	inc 1,IX                                             ; F961D1  dc 61
	ld	(xiz+ix), 0x00                               ; F961D3  f3 07 f8 f0 00 00
	inc 1,IX                                             ; F961D9  dc 61
	ld W,(XIY+Combination_Current)                                    ; F961DB  c3 f5 20 76 20
	ld	(xiz+ix), w                                  ; F961E0  f3 07 f8 f0 40
	inc 1,IX                                             ; F961E5  dc 61
	ld	(xiz+ix), 0xff                               ; F961E7  f3 07 f8 f0 00 ff
	inc 1,IX                                             ; F961ED  dc 61
	jr .LF96256                                              ; F961EF  68 65
; ParamImage_QueueProgramBankPair -- the offset-1 arm of ParamImage_QueuePartFieldChange: queue PROGRAM CHANGE &
; BANK bytes 1 and 0 of a part A block as one pair, unless the offset-0 arm already did
; Evidence: reached only by `jr z` at 0xF96178; compares the 7-bit new byte with the snapshot byte at
; 0x608000+IY (`and WA,0x7f7f / cp A,W`), skips when bit 0 of (0x2180) is set, else appends
; {D,1,(XIY+0x7620),0x7F} and {D,0,(XIY+0x761F),0xFF} at 0x2C00+IX.
ParamImage_QueueProgramBankPair:   ; entry: reachable-run entry
	ld XHL,0x00608000                                    ; F961F1  43 00 80 60 00
	ld	w, (xhl+iy)                                  ; F961F6  c3 07 ec f4 20
	and WA,0x7f7f                                        ; F961FB  d8 cc 7f 7f
	cp A,W                                               ; F961FF  c8 f1
	jr z, .LF96256                                       ; F96201  66 53
	bit	0, (0x2180:16)                               ; F96203  f1 80 21 c8
	jr nz, .LF96256                                      ; F96207  6e 4d
	ld XIZ,0x00002c00                                    ; F96209  46 00 2c 00 00
	ld	(xiz+ix), d                                  ; F9620E  f3 07 f8 f0 44
	inc 1,IX                                             ; F96213  dc 61
	ld	(xiz+ix), 0x01                               ; F96215  f3 07 f8 f0 00 01
	inc 1,IX                                             ; F9621B  dc 61
	ld W,(XIY+Combination_Current)                                    ; F9621D  c3 f5 20 76 20
	ld	(xiz+ix), w                                  ; F96222  f3 07 f8 f0 40
	inc 1,IX                                             ; F96227  dc 61
	ld	(xiz+ix), 0x7f                               ; F96229  f3 07 f8 f0 00 7f
	inc 1,IX                                             ; F9622F  dc 61
	ld	(xiz+ix), d                                  ; F96231  f3 07 f8 f0 44
	inc 1,IX                                             ; F96236  dc 61
	ld	(xiz+ix), 0x00                               ; F96238  f3 07 f8 f0 00 00
	inc 1,IX                                             ; F9623E  dc 61
	ld W,(XIY+0x761f)                                    ; F96240  c3 f5 1f 76 20
	ld	(xiz+ix), w                                  ; F96245  f3 07 f8 f0 40
	inc 1,IX                                             ; F9624A  dc 61
	ld	(xiz+ix), 0xff                               ; F9624C  f3 07 f8 f0 00 ff
	inc 1,IX                                             ; F96252  dc 61
	jr .LF96256                                          ; F96254  68 00
.LF96256:
	ret                                                  ; F96256  0e
T_F401E0_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F96257  0e
T_F401E4_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F96258  0e

; 0xF96259-0xF96400 -- 424 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 424, 1, 0x0E

	nop                                                  ; F96401  00
	nop                                                  ; F96402  00
	nop                                                  ; F96403  00
	ret                                                  ; F96404  0e
	nop                                                  ; F96405  00
	nop                                                  ; F96406  00
	nop                                                  ; F96407  00
	ret                                                  ; F96408  0e
	nop                                                  ; F96409  00
	nop                                                  ; F9640A  00
	nop                                                  ; F9640B  00
	ret                                                  ; F9640C  0e
	nop                                                  ; F9640D  00
	nop                                                  ; F9640E  00
	nop                                                  ; F9640F  00
	ret                                                  ; F96410  0e
	nop                                                  ; F96411  00
	nop                                                  ; F96412  00
	nop                                                  ; F96413  00
	ret                                                  ; F96414  0e
	nop                                                  ; F96415  00
	nop                                                  ; F96416  00
	nop                                                  ; F96417  00
; ParamImage_SanitizeAll_Entry -- prom_b directory slot T_ParamImage_SanitizeAll_Entry (slot 0 of the 0xF96400 group):
; `call ParamImage_SanitizeAll / ret`
; Evidence: `call 0xf96432` at 0xF96418; callers 0xFB59B1 and the 0xFB1800 PatchList module.
ParamImage_SanitizeAll_Entry:   ; entry: prom_b routine directory
	call ParamImage_SanitizeAll                                        ; F96418  1d 32 64 f9
	ret                                                  ; F9641C  0e
T_F40218_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F9641D  0e
; ParamImage_SanitizeAllAndHook_Entry -- prom_b directory slot T_ParamImage_SanitizeAllAndHook_Entry (slot 2 of the 0xF96400 group):
; `call ParamImage_SanitizeAllAndHook / ret`
; Evidence: callers 0xFAA89C, 0xFAA8F9, 0xFAAA99, 0xFB3126 (each followed by T_F401D4, with T_ParamImage_WriteRecordHeaders_Entry just
; before or after) and the veneer 0xFE0087.
ParamImage_SanitizeAllAndHook_Entry:   ; entry: prom_b routine directory
	call ParamImage_SanitizeAllAndHook                                        ; F9641E  1d 6a 64 f9
	ret                                                  ; F96422  0e
; ParamImage_ApplyAndMaskTable_Entry -- prom_b directory slot T_ParamImage_ApplyAndMaskTable_Entry (slot 3 of the 0xF96400 group):
; `call ParamImage_ApplyAndMaskTable / ret`
; Evidence: callers 0xFAA898 and 0xFAA8F5, each the first of T_ParamImage_ApplyAndMaskTable_Entry / T_ParamImage_SanitizeAllAndHook_Entry / T_F401D4 / T_F40224.
ParamImage_ApplyAndMaskTable_Entry:   ; entry: prom_b routine directory
	call ParamImage_ApplyAndMaskTable                                        ; F96423  1d 65 6c f9
	ret                                                  ; F96427  0e
; ParamImage_WriteRecordHeaders_Entry -- prom_b directory slot T_ParamImage_WriteRecordHeaders_Entry (slot 4 of the 0xF96400 group):
; `call ParamImage_WriteRecordHeaders / ret`
; Evidence: callers 0xFAA8A4, 0xFAA901, 0xFAAAA1, 0xFB3122, 0xFB5976, 0xFB59AD, 0xFB77BA, 0xFE0064.
ParamImage_WriteRecordHeaders_Entry:   ; entry: prom_b routine directory
	call ParamImage_WriteRecordHeaders                                        ; F96428  1d 8a 6c f9
	ret                                                  ; F9642C  0e
; ParamImageAlt_SanitizeCombination_Entry -- prom_b directory slot T_ParamImageAlt_SanitizeCombination_Entry (slot 5 of the 0xF96400 group):
; `call ParamImageAlt_SanitizeCombination / ret`
; Evidence: callers 0xFB320D and 0xFE0154.
ParamImageAlt_SanitizeCombination_Entry:   ; entry: prom_b routine directory
	call ParamImageAlt_SanitizeCombination                                        ; F9642D  1d 7f 64 f9
	ret                                                  ; F96431  0e
; ==== 0xF96432-0xF97418 -- STRONG-REACHABLE CODE ONLY, emitted by notes/gen_prom_a_cover_round2.py ====
; 3 run(s), 259 bytes framed as code.  3811 bytes that nothing STRONGLY reaches stay
; `.incbin` -- this round converts REACHABLE CODE, not territory.
; ★ UPDATE 2026-09-02: that 3811 is now ZERO.  Later rounds converted the rest, the
;   last 1,889 of them by notes/gen_prom_a_f96504_module.py, which typed
;   0xF96504-0xF96C65 from its already-converted READER rather than from
;   reachability -- exactly the kind of evidence this round's seed classes cannot
;   see.  The sentence above records what THIS round did and is left standing.
; Boundaries: notes/reachability.py's walk over its STRONG seed classes only (CPU
; vectors, prom_b routine-directory slots, branches in decoded code), frozen against
; this file's own output.  A bare 32-bit immediate is NOT a seed here: round 1 proved
; it paints pointer tables as instructions and passes the byte gate doing it.
; Labels are sub_XXXXXX by design: this round is COVERAGE, naming is a later goal.
; This text was assembled and byte-compared with the ROM before printing.
.LF96432:
; ParamImage_SanitizeAll -- validate the whole parameter image at 0x7620: effect records 0x61 and 0x63, then
; every field script of ScriptTableA_F969DD (offsets 0..0x2BE) and ScriptTableB_F96AA1 (0x2C0..0x95E)
; Evidence: T_DspEffect_SanitizeBlock (prom_b DspEffect_SanitizeBlock: looks the block's type byte up in EffectAlgoToPos_Block97/99 and
; rewrites the block) with (0x61, 0x7642) and (0x63, 0x7682), the payloads of records 0x61/0x63; then XIY =
; 0x7620 with table A (0xF96455) and table B (.LF96471), both run by the reader .LF964B9; then T_F407A4 and
; T_F407A0, both bare `ret`s (prom_a 0xFAA7AB, 0xFAB5EA). Record 0x62 is not passed to T_DspEffect_SanitizeBlock here.
ParamImage_SanitizeAll:   ; entry: branch/call in converted code
	ld XWA,0x00007642                                    ; F96432  40 42 76 00 00
	push XWA                                             ; F96437  38
	pushw 0x61                                           ; F96438  0b 61 00
	call T_DspEffect_SanitizeBlock                                        ; F9643B  1d 5c 2f f4
	popw wa                                              ; F9643F  48
	pop XWA                                              ; F96440  58
	ld XWA,0x00007682                                    ; F96441  40 82 76 00 00
	push XWA                                             ; F96446  38
	pushw 0x63                                           ; F96447  0b 63 00
	call T_DspEffect_SanitizeBlock                                        ; F9644A  1d 5c 2f f4
	popw wa                                              ; F9644E  48
	pop XWA                                              ; F9644F  58
	ld XIY,Combination_Current                                    ; F96450  45 20 76 00 00
	ld XIX,ScriptTableA_F969DD                           ; F96455  44 dd 69 f9 00
	calr .LF964B9                                        ; F9645A  1e 5c 00
	calr .LF96471                                        ; F9645D  1e 11 00
	call T_F407A4                                        ; F96460  1d a4 07 f4
	call T_F407A0                                        ; F96464  1d a0 07 f4
	ret                                                  ; F96468  0e
.LF96469:
	ret                                                  ; F96469  0e
; ParamImage_SanitizeAllAndHook -- ParamImage_SanitizeAll followed by the empty hook .LF96469 (a bare `ret`)
; Evidence: `calr .LF96432 / calr .LF96469 / ret` at 0xF9646A; reached only from
; ParamImage_SanitizeAllAndHook_Entry.
ParamImage_SanitizeAllAndHook:   ; entry: branch/call in converted code
	calr .LF96432                                        ; F9646A  1e c5 ff
	calr .LF96469                                        ; F9646D  1e f9 ff
	ret                                                  ; F96470  0e
.LF96471:
	ld XIY,Combination_Current                                    ; F96471  45 20 76 00 00
	ld XIX,ScriptTableB_F96AA1                           ; F96476  44 a1 6a f9 00
	calr .LF964B9                                        ; F9647B  1e 3b 00
	ret                                                  ; F9647E  0e
; ParamImageAlt_SanitizeCombination -- validate the COMBINATION part of the second parameter image at
; 0x603620: effect records 0x61/0x63, then ScriptTableA_F969DD only
; Evidence: XIY = 0x00603620; T_DspEffect_SanitizeBlock with (0x61, 0x603642) and (0x63, 0x603682) -- the same +0x22/+0x62 as
; ParamImage_SanitizeAll uses at 0x7620; table A at 0xF96484 run by .LF964B9; then T_F401E8 (a bare `ret`).
; Same layout: prom_b Seq_ApplyStoredSongTempo reads 0x603620+0x8C2 into (0x7EE2), the same offset in the main image.
ParamImageAlt_SanitizeCombination:   ; entry: branch/call in converted code
	ld XIY,0x00603620                                    ; F9647F  45 20 36 60 00
	ld XIX,ScriptTableA_F969DD                           ; F96484  44 dd 69 f9 00
	push XIX                                             ; F96489  3c
	push XIY                                             ; F9648A  3d
	add XIY,0x00000022                                   ; F9648B  ed c8 22 00 00 00
	push XIY                                             ; F96491  3d
	pushw 0x61                                           ; F96492  0b 61 00
	call T_DspEffect_SanitizeBlock                                        ; F96495  1d 5c 2f f4
	popw wa                                              ; F96499  48
	pop XIY                                              ; F9649A  5d
	pop XIY                                              ; F9649B  5d
	pop XIX                                              ; F9649C  5c
	push XIX                                             ; F9649D  3c
	push XIY                                             ; F9649E  3d
	add XIY,0x00000062                                   ; F9649F  ed c8 62 00 00 00
	push XIY                                             ; F964A5  3d
	pushw 0x63                                           ; F964A6  0b 63 00
	call T_DspEffect_SanitizeBlock                                        ; F964A9  1d 5c 2f f4
	popw wa                                              ; F964AD  48
	pop XIY                                              ; F964AE  5d
	pop XIY                                              ; F964AF  5d
	pop XIX                                              ; F964B0  5c
	calr .LF964B9                                        ; F964B1  1e 05 00
	call T_F401E8                                        ; F964B4  1d e8 01 f4
	ret                                                  ; F964B8  0e
.LF964B9:
	xor BC,BC                                            ; F964B9  d9 d1
.LF964BB:
	ld HL,BC                                             ; F964BB  d9 8b
	ld	xiz, (xix+hl)                                ; F964BD  e3 07 f0 ec 26
	cp XIZ,0xffffffff                                    ; F964C2  ee cf ff ff ff ff
	jr z, .LF96503                                       ; F964C8  66 39
	add XIZ,XIY                                          ; F964CA  ed 86
	inc 4,BC                                             ; F964CC  d9 64
	ld HL,BC                                             ; F964CE  d9 8b
	push XIX                                             ; F964D0  3c
	ld	xix, (xix+hl)                                ; F964D1  e3 07 f0 ec 24
	inc 4,BC                                             ; F964D6  d9 64
.LF964D8:
	xor H,H                                              ; F964D8  ce d6
	ld L,(XIX)                                           ; F964DA  84 27
	cp L,0xff                                            ; F964DC  cf cf ff
	jr z, .LF96500                                       ; F964DF  66 1f
	sla hl, 0x02                                         ; F964E1  db ec 02
	extz XHL                                             ; F964E4  eb 12
	add XHL,ScriptOpHandlers_F969A1                      ; F964E6  eb c8 a1 69 f9 00
	ld XDE,(XHL)                                         ; F964EC  a3 22
	inc 1,XIX                                            ; F964EE  ec 61
	xor XHL,XHL                                          ; F964F0  eb d3
	ld L,(XIX)                                           ; F964F2  84 27
	add XHL,XIZ                                          ; F964F4  ee 83
	ld A,(XHL)                                           ; F964F6  83 21
	inc 1,XIX                                            ; F964F8  ec 61
	pushw bc                                             ; F964FA  29
	call (xde)                                           ; F964FB  b2 e8
	popw bc                                              ; F964FD  49
	jr T,.LF964D8                                        ; F964FE  68 d8
.LF96500:
	pop XIX                                              ; F96500  5c
	jr .LF964BB                                          ; F96501  68 b8
.LF96503:
	ret                                                  ; F96503  0e
; ==============================================================================
; 0xF96504-0xF96C65 -- a bit-field SCRIPT INTERPRETER's handlers and its three tables
; ==============================================================================
;
; Converted 2026-09-02 by notes/gen_prom_a_f96504_module.py, which re-derives
; every boundary below on each run and refuses to emit if one moves.
; Full argument: notes/FINDINGS-prom_a-f96504-script-tables.md.
;
; The reader is `.LF964B9` (0xF964B9, converted earlier, just above): it walks
; an array of (u32 struct offset, u32 script pointer) pairs terminated by
; 0xFFFFFFFF, and for each script executes (opcode, field offset, immediates)
; records until 0xFF.  Its three literal addresses -- `add XHL,0x00f969a1` at
; 0xF964E6, `ld XIX,0x00f969dd` at 0xF96455/0xF96484 and `ld XIX,0x00f96aa1`
; at 0xF96476 -- are what fix the three tables below.  Nothing here rests on
; decode plausibility.
;
; ★ THE CHECK THAT COULD HAVE FAILED: walking every script the two tables name,
;   with record widths read off the handlers, TILES 0xF9667A-0xF969A1 exactly --
;   18 scripts, 259 records, no gap, no byte claimed twice, no overrun, and no
;   opcode outside the 8 the handler table populates (0x01 0x04 0x06 0x07 0x08 are the 5 actually
;   used by these scripts).
;
; What these fields MEAN is not established -- the layout is.  The handlers are
; `sub_XXXXXX`: an address plus its dispatch slot, not a claim.
; ------------------------------------------------------------------------------
; ParamScript_AndImm -- script opcode 0x01: field &= imm (record: op, field, imm)
; Evidence: `and A,(XIX) / ld (XHL),A / inc XIX`, with A = the field's value and XHL = &struct.field as
; the reader .LF964B9 sets them; slot 1 of ScriptOpHandlers_F969A1.
ParamScript_AndImm:   ; script opcode 0x01 handler (slot 1 of ScriptOpHandlers_F969A1)
	and A,(XIX)                                          ; F96504  84 c1
	ld (XHL),A                                           ; F96506  b3 41
	inc 1,XIX                                            ; F96508  ec 61
	ret                                                  ; F9650A  0e
; ParamScript_SetImm -- script opcode 0x08: field = imm (record: op, field, imm)
; Evidence: `ld A,(XIX) / ld (XHL),A / inc XIX`; slot 8 of ScriptOpHandlers_F969A1.
ParamScript_SetImm:   ; script opcode 0x08 handler (slot 8 of ScriptOpHandlers_F969A1)
	ld A,(XIX)                                           ; F9650B  84 21
	ld (XHL),A                                           ; F9650D  b3 41
	inc 1,XIX                                            ; F9650F  ec 61
	ret                                                  ; F96511  0e
; ParamScript_ClearBitsImm -- script opcode 0x02: field &= ~imm (record: op, field, imm)
; Evidence: `ld W,(XIX) / xor W,0xff / and A,W / ld (XHL),A`; slot 2 of ScriptOpHandlers_F969A1.
ParamScript_ClearBitsImm:   ; script opcode 0x02 handler (slot 2 of ScriptOpHandlers_F969A1)
	ld W,(XIX)                                           ; F96512  84 20
	xor W,0xff                                           ; F96514  c8 cd ff
	and A,W                                              ; F96517  c8 c1
	ld (XHL),A                                           ; F96519  b3 41
	inc 1,XIX                                            ; F9651B  ec 61
	ret                                                  ; F9651D  0e
; ParamScript_SetBitsImm -- script opcode 0x03: field |= imm (record: op, field, imm)
; Evidence: `ld W,(XIX) / or A,W / ld (XHL),A`; slot 3 of ScriptOpHandlers_F969A1.
ParamScript_SetBitsImm:   ; script opcode 0x03 handler (slot 3 of ScriptOpHandlers_F969A1)
	ld W,(XIX)                                           ; F9651E  84 20
	or A,W                                               ; F96520  c8 e1
	ld (XHL),A                                           ; F96522  b3 41
	inc 1,XIX                                            ; F96524  ec 61
	ret                                                  ; F96526  0e
; ParamScript_ClampFieldOrDefault -- script opcode 0x04: the bit-field under mask m must lie in [lo, hi],
; otherwise it is replaced by def (record: op, field, m, lo, hi, def)
; Evidence: C = trailing zeros of m, value >> C (`cb ff`); `cp A,(XIX) / jr c` and `cp A,(XIX) / jr ugt`
; both load the byte at +3; then `and (XHL),~m`, value << C (`cb fc`), `or (XHL),A`; slot 4.
ParamScript_ClampFieldOrDefault:   ; script opcode 0x04 handler (slot 4 of ScriptOpHandlers_F969A1)
	ld W,(XIX)                                           ; F96527  84 20
	ld E,W                                               ; F96529  c8 8d
	and A,W                                              ; F9652B  c8 c1
	xor C,C                                              ; F9652D  cb d3
	cp w, 0x00:i3                                          ; F9652F  c8 d8
	jr ule, .LF9653C                                     ; F96531  63 09
.LF96533:
	srl w, 0x01                                          ; F96533  c8 ef 01
	jr c, .LF9653C                                       ; F96536  67 04
	inc 1,C                                              ; F96538  cb 61
	jr .LF96533                                          ; F9653A  68 f7
.LF9653C:
	cp c, 0x00:i3                                          ; F9653C  cb d8
	jr z, .LF96546                                       ; F9653E  66 06
	ex8 a, c                                             ; F96540  cb b9
	.byte 0xcb, 0xff                                     ; F96542  cb ff
	ex8 a, c                                             ; F96544  cb b9
.LF96546:
	inc 1,XIX                                            ; F96546  ec 61
	cp A,(XIX)                                           ; F96548  84 f1
	jr c, .LF96556                                       ; F9654A  67 0a
	inc 1,XIX                                            ; F9654C  ec 61
	cp A,(XIX)                                           ; F9654E  84 f1
	jr ugt, .LF9655C                                     ; F96550  6b 0a
	inc 1,XIX                                            ; F96552  ec 61
	jr .LF96560                                          ; F96554  68 0a
.LF96556:
	inc 2,XIX                                            ; F96556  ec 62
	ld A,(XIX)                                           ; F96558  84 21
	jr .LF96560                                          ; F9655A  68 04
.LF9655C:
	inc 1,XIX                                            ; F9655C  ec 61
	ld A,(XIX)                                           ; F9655E  84 21
.LF96560:
	xor E,0xff                                           ; F96560  cd cd ff
	and (XHL),E                                          ; F96563  83 cd
	cp c, 0x00:i3                                          ; F96565  cb d8
	jr z, .LF9656F                                       ; F96567  66 06
	ex8 a, c                                             ; F96569  cb b9
	.byte 0xcb, 0xfc                                     ; F9656B  cb fc
	ex8 a, c                                             ; F9656D  cb b9
.LF9656F:
	or (XHL),A                                           ; F9656F  83 e9
	inc 1,XIX                                            ; F96571  ec 61
	ret                                                  ; F96573  0e
; ParamScript_ReplaceFieldIfInRange -- script opcode 0x05: when the bit-field under mask m lies IN [lo, hi]
; it is replaced by rep, otherwise kept (record: op, field, m, lo, hi, rep)
; Evidence: same shift/merge as ParamScript_ClampFieldOrDefault, but `jr nc` / `jr ule` (0xF96597-0xF965A9)
; make the in-range arm the only one that executes `ld A,(XIX)`; slot 5.
ParamScript_ReplaceFieldIfInRange:   ; script opcode 0x05 handler (slot 5 of ScriptOpHandlers_F969A1)
	ld W,(XIX)                                           ; F96574  84 20
	ld E,W                                               ; F96576  c8 8d
	and A,W                                              ; F96578  c8 c1
	xor C,C                                              ; F9657A  cb d3
	cp w, 0x00:i3                                          ; F9657C  c8 d8
	jr ule, .LF96589                                     ; F9657E  63 09
.LF96580:
	srl w, 0x01                                          ; F96580  c8 ef 01
	jr c, .LF96589                                       ; F96583  67 04
	inc 1,C                                              ; F96585  cb 61
	jr .LF96580                                          ; F96587  68 f7
.LF96589:
	cp c, 0x00:i3                                          ; F96589  cb d8
	jr z, .LF96593                                       ; F9658B  66 06
	ex8 a, c                                             ; F9658D  cb b9
	.byte 0xcb, 0xff                                     ; F9658F  cb ff
	ex8 a, c                                             ; F96591  cb b9
.LF96593:
	inc 1,XIX                                            ; F96593  ec 61
	cp A,(XIX)                                           ; F96595  84 f1
	jr nc, .LF9659D                                      ; F96597  6f 04
	inc 2,XIX                                            ; F96599  ec 62
	jr .LF965AD                                          ; F9659B  68 10
.LF9659D:
	inc 1,XIX                                            ; F9659D  ec 61
	cp A,(XIX)                                           ; F9659F  84 f1
	jr ule, .LF965A7                                     ; F965A1  63 04
	inc 1,XIX                                            ; F965A3  ec 61
	jr .LF965AD                                          ; F965A5  68 06
.LF965A7:
	inc 1,XIX                                            ; F965A7  ec 61
	ld A,(XIX)                                           ; F965A9  84 21
	jr .LF965AD                                          ; F965AB  68 00
.LF965AD:
	xor E,0xff                                           ; F965AD  cd cd ff
	and (XHL),E                                          ; F965B0  83 cd
	cp c, 0x00:i3                                          ; F965B2  cb d8
	jr z, .LF965BC                                       ; F965B4  66 06
	ex8 a, c                                             ; F965B6  cb b9
	.byte 0xcb, 0xfc                                     ; F965B8  cb fc
	ex8 a, c                                             ; F965BA  cb b9
.LF965BC:
	or (XHL),A                                           ; F965BC  83 e9
	inc 1,XIX                                            ; F965BE  ec 61
	ret                                                  ; F965C0  0e
; ParamScript_FieldInListElseLast -- script opcode 0x06: the bit-field under mask m must equal one of n
; listed values; if none matches it becomes the LAST listed value (record: op, field, m, n, v1..vn)
; Evidence: `dec E / cp A,(XIX) / jr z` loop at 0xF965E4-0xF965F0; on exhaustion `ld A,(XIX)` with XIX on
; the last value; `add XIX,XDE / inc XIX` then skips the unread rest of the list; slot 6.
ParamScript_FieldInListElseLast:   ; script opcode 0x06 handler (slot 6 of ScriptOpHandlers_F969A1)
	ld W,(XIX)                                           ; F965C1  84 20
	and A,W                                              ; F965C3  c8 c1
	ld D,W                                               ; F965C5  c8 8c
	inc 1,XIX                                            ; F965C7  ec 61
	ld E,(XIX)                                           ; F965C9  84 25
	xor C,C                                              ; F965CB  cb d3
	cp w, 0x00:i3                                          ; F965CD  c8 d8
	jr ule, .LF965DA                                     ; F965CF  63 09
.LF965D1:
	srl w, 0x01                                          ; F965D1  c8 ef 01
	jr c, .LF965DA                                       ; F965D4  67 04
	inc 1,C                                              ; F965D6  cb 61
	jr .LF965D1                                          ; F965D8  68 f7
.LF965DA:
	cp c, 0x00:i3                                          ; F965DA  cb d8
	jr z, .LF965E4                                       ; F965DC  66 06
	ex8 a, c                                             ; F965DE  cb b9
	.byte 0xcb, 0xff                                     ; F965E0  cb ff
	ex8 a, c                                             ; F965E2  cb b9
.LF965E4:
	cp e, 0x00:i3                                          ; F965E4  cd d8
	jr ule, .LF965F2                                     ; F965E6  63 0a
	inc 1,XIX                                            ; F965E8  ec 61
	dec 1,E                                              ; F965EA  cd 69
	cp A,(XIX)                                           ; F965EC  84 f1
	jr z, .LF965F4                                       ; F965EE  66 04
	jr .LF965E4                                          ; F965F0  68 f2
.LF965F2:
	ld A,(XIX)                                           ; F965F2  84 21
.LF965F4:
	xor D,0xff                                           ; F965F4  cc cd ff
	and (XHL),D                                          ; F965F7  83 cc
	cp c, 0x00:i3                                          ; F965F9  cb d8
	jr z, .LF96603                                       ; F965FB  66 06
	ex8 a, c                                             ; F965FD  cb b9
	.byte 0xcb, 0xfc                                     ; F965FF  cb fc
	ex8 a, c                                             ; F96601  cb b9
.LF96603:
	or (XHL),A                                           ; F96603  83 e9
	xor D,D                                              ; F96605  cc d4
	extz XDE                                             ; F96607  ea 12
	add XIX,XDE                                          ; F96609  ea 84
	inc 1,XIX                                            ; F9660B  ec 61
	ret                                                  ; F9660D  0e
; ParamScript_MapFieldIfInList -- script opcode 0x07: when the bit-field under mask m equals one of n listed
; values it becomes the byte after the list, otherwise it is kept (record: op, field, m, n, v1..vn, rep)
; Evidence: the match arm (0xF9663F) advances past the list and loads rep; the no-match arm (0xF9665E)
; writes A back unchanged; both finish with one more `inc XIX` past rep; slot 7.
ParamScript_MapFieldIfInList:   ; script opcode 0x07 handler (slot 7 of ScriptOpHandlers_F969A1)
	ld W,(XIX)                                           ; F9660E  84 20
	and A,W                                              ; F96610  c8 c1
	ld D,W                                               ; F96612  c8 8c
	inc 1,XIX                                            ; F96614  ec 61
	ld E,(XIX)                                           ; F96616  84 25
	xor C,C                                              ; F96618  cb d3
	cp w, 0x00:i3                                          ; F9661A  c8 d8
	jr ule, .LF96627                                     ; F9661C  63 09
.LF9661E:
	srl w, 0x01                                          ; F9661E  c8 ef 01
	jr c, .LF96627                                       ; F96621  67 04
	inc 1,C                                              ; F96623  cb 61
	jr .LF9661E                                          ; F96625  68 f7
.LF96627:
	cp c, 0x00:i3                                          ; F96627  cb d8
	jr z, .LF96631                                       ; F96629  66 06
	ex8 a, c                                             ; F9662B  cb b9
	.byte 0xcb, 0xff                                     ; F9662D  cb ff
	ex8 a, c                                             ; F9662F  cb b9
.LF96631:
	cp e, 0x00:i3                                          ; F96631  cd d8
	jr ule, .LF9665E                                     ; F96633  63 29
	inc 1,XIX                                            ; F96635  ec 61
	dec 1,E                                              ; F96637  cd 69
	cp A,(XIX)                                           ; F96639  84 f1
	jr z, .LF9663F                                       ; F9663B  66 02
	jr .LF96631                                          ; F9663D  68 f2
.LF9663F:
	push XDE                                             ; F9663F  3a
	xor D,D                                              ; F96640  cc d4
	extz XDE                                             ; F96642  ea 12
	add XIX,XDE                                          ; F96644  ea 84
	pop XDE                                              ; F96646  5a
	inc 1,XIX                                            ; F96647  ec 61
	ld A,(XIX)                                           ; F96649  84 21
	xor D,0xff                                           ; F9664B  cc cd ff
	and (XHL),D                                          ; F9664E  83 cc
	cp c, 0x00:i3                                          ; F96650  cb d8
	jr z, .LF9665A                                       ; F96652  66 06
	ex8 a, c                                             ; F96654  cb b9
	.byte 0xcb, 0xfc                                     ; F96656  cb fc
	ex8 a, c                                             ; F96658  cb b9
.LF9665A:
	or (XHL),A                                           ; F9665A  83 e9
	jr .LF96677                                          ; F9665C  68 19
.LF9665E:
	xor D,0xff                                           ; F9665E  cc cd ff
	and (XHL),D                                          ; F96661  83 cc
	cp c, 0x00:i3                                          ; F96663  cb d8
	jr z, .LF9666D                                       ; F96665  66 06
	ex8 a, c                                             ; F96667  cb b9
	.byte 0xcb, 0xfc                                     ; F96669  cb fc
	ex8 a, c                                             ; F9666B  cb b9
.LF9666D:
	or (XHL),A                                           ; F9666D  83 e9
	xor D,D                                              ; F9666F  cc d4
	extz XDE                                             ; F96671  ea 12
	add XIX,XDE                                          ; F96673  ea 84
	inc 1,XIX                                            ; F96675  ec 61
.LF96677:
	inc 1,XIX                                            ; F96677  ec 61
	ret                                                  ; F96679  0e
; ------------------------------------------------------------------------------
; 0xF9667A-0xF969A1 -- the SCRIPTS.  DATA: nothing calls or jumps here; the only
; references LOAD these addresses out of the two tables below.  One line per
; record, `op field imm...`, widths from the handlers (0x01/0x02/0x03/0x08 = 3,
; 0x04/0x05 = 6, 0x06 = 4+n, 0x07 = 5+n, 0xFF = end).
; ------------------------------------------------------------------------------
Script_F9667A:   ; 16 record(s), named by A[0]
	.byte 0x01, 0x02, 0x7f                       ; F9667A  op 0x01 field 0x02
	.byte 0x01, 0x03, 0x7f                       ; F9667D  op 0x01 field 0x03
	.byte 0x01, 0x04, 0x7f                       ; F96680  op 0x01 field 0x04
	.byte 0x01, 0x05, 0x7f                       ; F96683  op 0x01 field 0x05
	.byte 0x01, 0x06, 0x7f                       ; F96686  op 0x01 field 0x06
	.byte 0x01, 0x07, 0x7f                       ; F96689  op 0x01 field 0x07
	.byte 0x01, 0x08, 0x7f                       ; F9668C  op 0x01 field 0x08
	.byte 0x01, 0x09, 0x7f                       ; F9668F  op 0x01 field 0x09
	.byte 0x01, 0x0a, 0x7f                       ; F96692  op 0x01 field 0x0a
	.byte 0x01, 0x0b, 0x7f                       ; F96695  op 0x01 field 0x0b
	.byte 0x01, 0x0c, 0x7f                       ; F96698  op 0x01 field 0x0c
	.byte 0x01, 0x0d, 0x7f                       ; F9669B  op 0x01 field 0x0d
	.byte 0x01, 0x0e, 0x7f                       ; F9669E  op 0x01 field 0x0e
	.byte 0x01, 0x0f, 0x7f                       ; F966A1  op 0x01 field 0x0f
	.byte 0x01, 0x10, 0x7f                       ; F966A4  op 0x01 field 0x10
	.byte 0x01, 0x11, 0x7f                       ; F966A7  op 0x01 field 0x11
	.byte 0xff                                   ; F966AA  end
Script_F966AB:   ; 0 record(s), named by A[1]
	.byte 0xff                                   ; F966AB  end
Script_F966AC:   ; 23 record(s), named by A[2]
	.byte 0x01, 0x02, 0xff                       ; F966AC  op 0x01 field 0x02
	.byte 0x01, 0x03, 0xff                       ; F966AF  op 0x01 field 0x03
	.byte 0x01, 0x04, 0xff                       ; F966B2  op 0x01 field 0x04
	.byte 0x01, 0x05, 0xff                       ; F966B5  op 0x01 field 0x05
	.byte 0x01, 0x06, 0xff                       ; F966B8  op 0x01 field 0x06
	.byte 0x01, 0x07, 0xff                       ; F966BB  op 0x01 field 0x07
	.byte 0x01, 0x08, 0xff                       ; F966BE  op 0x01 field 0x08
	.byte 0x01, 0x09, 0xff                       ; F966C1  op 0x01 field 0x09
	.byte 0x01, 0x0a, 0xff                       ; F966C4  op 0x01 field 0x0a
	.byte 0x01, 0x0b, 0xff                       ; F966C7  op 0x01 field 0x0b
	.byte 0x01, 0x0c, 0xff                       ; F966CA  op 0x01 field 0x0c
	.byte 0x01, 0x0d, 0xff                       ; F966CD  op 0x01 field 0x0d
	.byte 0x01, 0x0e, 0xff                       ; F966D0  op 0x01 field 0x0e
	.byte 0x01, 0x0f, 0xff                       ; F966D3  op 0x01 field 0x0f
	.byte 0x01, 0x10, 0xff                       ; F966D6  op 0x01 field 0x10
	.byte 0x01, 0x11, 0xff                       ; F966D9  op 0x01 field 0x11
	.byte 0x01, 0x12, 0xff                       ; F966DC  op 0x01 field 0x12
	.byte 0x01, 0x13, 0xff                       ; F966DF  op 0x01 field 0x13
	.byte 0x01, 0x14, 0xff                       ; F966E2  op 0x01 field 0x14
	.byte 0x01, 0x15, 0xff                       ; F966E5  op 0x01 field 0x15
	.byte 0x01, 0x16, 0xff                       ; F966E8  op 0x01 field 0x16
	.byte 0x01, 0x17, 0xff                       ; F966EB  op 0x01 field 0x17
	.byte 0x01, 0x18, 0xff                       ; F966EE  op 0x01 field 0x18
	.byte 0xff                                   ; F966F1  end
Script_F966F2:   ; 23 record(s), named by A[3]
	.byte 0x01, 0x02, 0xff                       ; F966F2  op 0x01 field 0x02
	.byte 0x01, 0x03, 0xff                       ; F966F5  op 0x01 field 0x03
	.byte 0x01, 0x04, 0xff                       ; F966F8  op 0x01 field 0x04
	.byte 0x01, 0x05, 0xff                       ; F966FB  op 0x01 field 0x05
	.byte 0x01, 0x06, 0xff                       ; F966FE  op 0x01 field 0x06
	.byte 0x01, 0x07, 0xff                       ; F96701  op 0x01 field 0x07
	.byte 0x01, 0x08, 0xff                       ; F96704  op 0x01 field 0x08
	.byte 0x01, 0x09, 0xff                       ; F96707  op 0x01 field 0x09
	.byte 0x01, 0x0a, 0xff                       ; F9670A  op 0x01 field 0x0a
	.byte 0x01, 0x0b, 0xff                       ; F9670D  op 0x01 field 0x0b
	.byte 0x01, 0x0c, 0xff                       ; F96710  op 0x01 field 0x0c
	.byte 0x01, 0x0d, 0xff                       ; F96713  op 0x01 field 0x0d
	.byte 0x01, 0x0e, 0xff                       ; F96716  op 0x01 field 0x0e
	.byte 0x01, 0x0f, 0xff                       ; F96719  op 0x01 field 0x0f
	.byte 0x01, 0x10, 0xff                       ; F9671C  op 0x01 field 0x10
	.byte 0x01, 0x11, 0xff                       ; F9671F  op 0x01 field 0x11
	.byte 0x01, 0x12, 0xff                       ; F96722  op 0x01 field 0x12
	.byte 0x01, 0x13, 0xff                       ; F96725  op 0x01 field 0x13
	.byte 0x01, 0x14, 0xff                       ; F96728  op 0x01 field 0x14
	.byte 0x01, 0x15, 0xff                       ; F9672B  op 0x01 field 0x15
	.byte 0x01, 0x16, 0xff                       ; F9672E  op 0x01 field 0x16
	.byte 0x01, 0x17, 0xff                       ; F96731  op 0x01 field 0x17
	.byte 0x01, 0x18, 0xff                       ; F96734  op 0x01 field 0x18
	.byte 0xff                                   ; F96737  end
Script_F96738:   ; 23 record(s), named by A[4]
	.byte 0x01, 0x02, 0xff                       ; F96738  op 0x01 field 0x02
	.byte 0x01, 0x03, 0xff                       ; F9673B  op 0x01 field 0x03
	.byte 0x01, 0x04, 0xff                       ; F9673E  op 0x01 field 0x04
	.byte 0x01, 0x05, 0xff                       ; F96741  op 0x01 field 0x05
	.byte 0x01, 0x06, 0xff                       ; F96744  op 0x01 field 0x06
	.byte 0x01, 0x07, 0xff                       ; F96747  op 0x01 field 0x07
	.byte 0x01, 0x08, 0xff                       ; F9674A  op 0x01 field 0x08
	.byte 0x01, 0x09, 0xff                       ; F9674D  op 0x01 field 0x09
	.byte 0x01, 0x0a, 0xff                       ; F96750  op 0x01 field 0x0a
	.byte 0x01, 0x0b, 0xff                       ; F96753  op 0x01 field 0x0b
	.byte 0x01, 0x0c, 0xff                       ; F96756  op 0x01 field 0x0c
	.byte 0x01, 0x0d, 0xff                       ; F96759  op 0x01 field 0x0d
	.byte 0x01, 0x0e, 0xff                       ; F9675C  op 0x01 field 0x0e
	.byte 0x01, 0x0f, 0xff                       ; F9675F  op 0x01 field 0x0f
	.byte 0x01, 0x10, 0xff                       ; F96762  op 0x01 field 0x10
	.byte 0x01, 0x11, 0xff                       ; F96765  op 0x01 field 0x11
	.byte 0x01, 0x12, 0xff                       ; F96768  op 0x01 field 0x12
	.byte 0x01, 0x13, 0xff                       ; F9676B  op 0x01 field 0x13
	.byte 0x01, 0x14, 0xff                       ; F9676E  op 0x01 field 0x14
	.byte 0x01, 0x15, 0xff                       ; F96771  op 0x01 field 0x15
	.byte 0x01, 0x16, 0xff                       ; F96774  op 0x01 field 0x16
	.byte 0x01, 0x17, 0xff                       ; F96777  op 0x01 field 0x17
	.byte 0x01, 0x18, 0xff                       ; F9677A  op 0x01 field 0x18
	.byte 0xff                                   ; F9677D  end
Script_F9677E:   ; 22 record(s), named by A[5], A[7], A[9], A[11], A[13], A[15], A[17], A[19], B[0], B[2], B[4], B[6], B[8], B[10], B[12], B[14], B[16], B[18], B[20], B[22], B[24], B[26], B[28], B[30], B[32], B[34], B[36], B[38], B[40], B[42], B[44], B[46]
	.byte 0x01, 0x02, 0xff                       ; F9677E  op 0x01 field 0x02
	.byte 0x01, 0x03, 0x7f                       ; F96781  op 0x01 field 0x03
	.byte 0x01, 0x04, 0x00                       ; F96784  op 0x01 field 0x04
	.byte 0x01, 0x05, 0xff                       ; F96787  op 0x01 field 0x05
	.byte 0x01, 0x06, 0xdf                       ; F9678A  op 0x01 field 0x06
	.byte 0x01, 0x07, 0x7f                       ; F9678D  op 0x01 field 0x07
	.byte 0x01, 0x08, 0x7f                       ; F96790  op 0x01 field 0x08
	.byte 0x01, 0x09, 0x7f                       ; F96793  op 0x01 field 0x09
	.byte 0x01, 0x0a, 0x7f                       ; F96796  op 0x01 field 0x0a
	.byte 0x04, 0x0b, 0x7f, 0x1c, 0x64, 0x40     ; F96799  op 0x04 field 0x0b
	.byte 0x01, 0x0c, 0xff                       ; F9679F  op 0x01 field 0x0c
	.byte 0x01, 0x0d, 0x7f                       ; F967A2  op 0x01 field 0x0d
	.byte 0x01, 0x0e, 0x3f                       ; F967A5  op 0x01 field 0x0e
	.byte 0x01, 0x0f, 0xff                       ; F967A8  op 0x01 field 0x0f
	.byte 0x01, 0x10, 0xff                       ; F967AB  op 0x01 field 0x10
	.byte 0x01, 0x11, 0xff                       ; F967AE  op 0x01 field 0x11
	.byte 0x01, 0x12, 0x7f                       ; F967B1  op 0x01 field 0x12
	.byte 0x01, 0x13, 0xff                       ; F967B4  op 0x01 field 0x13
	.byte 0x01, 0x14, 0xff                       ; F967B7  op 0x01 field 0x14
	.byte 0x01, 0x15, 0xff                       ; F967BA  op 0x01 field 0x15
	.byte 0x01, 0x16, 0xff                       ; F967BD  op 0x01 field 0x16
	.byte 0x01, 0x17, 0x1f                       ; F967C0  op 0x01 field 0x17
	.byte 0xff                                   ; F967C3  end
Script_F967C4:   ; 31 record(s), named by A[6], A[8], A[10], A[12], A[14], A[16], A[18], A[20], B[1], B[3], B[5], B[7], B[9], B[11], B[13], B[15], B[17], B[19], B[21], B[23], B[25], B[27], B[29], B[31], B[33], B[35], B[37], B[39], B[41], B[43], B[45], B[47]
	.byte 0x01, 0x02, 0x00                       ; F967C4  op 0x01 field 0x02
	.byte 0x01, 0x03, 0x00                       ; F967C7  op 0x01 field 0x03
	.byte 0x01, 0x04, 0x00                       ; F967CA  op 0x01 field 0x04
	.byte 0x04, 0x05, 0xff, 0x00, 0x05, 0x01     ; F967CD  op 0x04 field 0x05
	.byte 0x04, 0x06, 0xff, 0x00, 0x05, 0x01     ; F967D3  op 0x04 field 0x06
	.byte 0x01, 0x07, 0xff                       ; F967D9  op 0x01 field 0x07
	.byte 0x01, 0x08, 0xff                       ; F967DC  op 0x01 field 0x08
	.byte 0x04, 0x08, 0x0f, 0x00, 0x01, 0x00     ; F967DF  op 0x04 field 0x08
	.byte 0x01, 0x09, 0x7f                       ; F967E5  op 0x01 field 0x09
	.byte 0x01, 0x0a, 0x7f                       ; F967E8  op 0x01 field 0x0a
	.byte 0x01, 0x0b, 0x7f                       ; F967EB  op 0x01 field 0x0b
	.byte 0x01, 0x0c, 0x7f                       ; F967EE  op 0x01 field 0x0c
	.byte 0x01, 0x0d, 0xff                       ; F967F1  op 0x01 field 0x0d
	.byte 0x01, 0x0e, 0xff                       ; F967F4  op 0x01 field 0x0e
	.byte 0x01, 0x0f, 0xff                       ; F967F7  op 0x01 field 0x0f
	.byte 0x01, 0x10, 0xff                       ; F967FA  op 0x01 field 0x10
	.byte 0x01, 0x11, 0xff                       ; F967FD  op 0x01 field 0x11
	.byte 0x01, 0x12, 0xff                       ; F96800  op 0x01 field 0x12
	.byte 0x01, 0x13, 0xff                       ; F96803  op 0x01 field 0x13
	.byte 0x01, 0x14, 0xff                       ; F96806  op 0x01 field 0x14
	.byte 0x01, 0x15, 0xff                       ; F96809  op 0x01 field 0x15
	.byte 0x01, 0x16, 0xff                       ; F9680C  op 0x01 field 0x16
	.byte 0x01, 0x17, 0xff                       ; F9680F  op 0x01 field 0x17
	.byte 0x01, 0x18, 0xff                       ; F96812  op 0x01 field 0x18
	.byte 0x01, 0x19, 0xff                       ; F96815  op 0x01 field 0x19
	.byte 0x01, 0x1a, 0x01                       ; F96818  op 0x01 field 0x1a
	.byte 0x01, 0x1b, 0x3f                       ; F9681B  op 0x01 field 0x1b
	.byte 0x01, 0x1c, 0x3f                       ; F9681E  op 0x01 field 0x1c
	.byte 0x01, 0x1d, 0xff                       ; F96821  op 0x01 field 0x1d
	.byte 0x01, 0x1e, 0xff                       ; F96824  op 0x01 field 0x1e
	.byte 0x01, 0x1f, 0xff                       ; F96827  op 0x01 field 0x1f
	.byte 0xff                                   ; F9682A  end
Script_F9682B:   ; 15 record(s), named by A[21]
	.byte 0x01, 0x02, 0xff                       ; F9682B  op 0x01 field 0x02
	.byte 0x01, 0x03, 0x8f                       ; F9682E  op 0x01 field 0x03
	.byte 0x04, 0x03, 0x0f, 0x00, 0x0b, 0x00     ; F96831  op 0x04 field 0x03
	.byte 0x01, 0x04, 0xff                       ; F96837  op 0x01 field 0x04
	.byte 0x01, 0x05, 0xff                       ; F9683A  op 0x01 field 0x05
	.byte 0x01, 0x06, 0xff                       ; F9683D  op 0x01 field 0x06
	.byte 0x01, 0x07, 0xff                       ; F96840  op 0x01 field 0x07
	.byte 0x01, 0x08, 0xff                       ; F96843  op 0x01 field 0x08
	.byte 0x01, 0x09, 0xff                       ; F96846  op 0x01 field 0x09
	.byte 0x01, 0x0a, 0xff                       ; F96849  op 0x01 field 0x0a
	.byte 0x01, 0x0b, 0xff                       ; F9684C  op 0x01 field 0x0b
	.byte 0x01, 0x0c, 0xff                       ; F9684F  op 0x01 field 0x0c
	.byte 0x01, 0x0d, 0xff                       ; F96852  op 0x01 field 0x0d
	.byte 0x01, 0x0e, 0xff                       ; F96855  op 0x01 field 0x0e
	.byte 0x01, 0x0f, 0xff                       ; F96858  op 0x01 field 0x0f
	.byte 0xff                                   ; F9685B  end
Script_F9685C:   ; 8 record(s), named by A[22]
	.byte 0x01, 0x02, 0x7f                       ; F9685C  op 0x01 field 0x02
	.byte 0x01, 0x03, 0xff                       ; F9685F  op 0x01 field 0x03
	.byte 0x01, 0x04, 0xff                       ; F96862  op 0x01 field 0x04
	.byte 0x01, 0x05, 0xff                       ; F96865  op 0x01 field 0x05
	.byte 0x01, 0x06, 0xff                       ; F96868  op 0x01 field 0x06
	.byte 0x01, 0x07, 0xff                       ; F9686B  op 0x01 field 0x07
	.byte 0x04, 0x07, 0x0f, 0x00, 0x05, 0x00     ; F9686E  op 0x04 field 0x07
	.byte 0x04, 0x07, 0xf0, 0x00, 0x05, 0x00     ; F96874  op 0x04 field 0x07
	.byte 0xff                                   ; F9687A  end
Script_F9687B:   ; 2 record(s), named by A[23]
	.byte 0x08, 0x00, 0xff                       ; F9687B  op 0x08 field 0x00
	.byte 0x08, 0x01, 0xff                       ; F9687E  op 0x08 field 0x01
	.byte 0xff                                   ; F96881  end
Script_F96882:   ; 5 record(s), named by B[48]
	.byte 0x01, 0x02, 0xff                       ; F96882  op 0x01 field 0x02
	.byte 0x01, 0x03, 0x01                       ; F96885  op 0x01 field 0x03
	.byte 0x01, 0x04, 0xff                       ; F96888  op 0x01 field 0x04
	.byte 0x04, 0x04, 0x0f, 0x00, 0x02, 0x02     ; F9688B  op 0x04 field 0x04
	.byte 0x04, 0x04, 0xf0, 0x00, 0x02, 0x02     ; F96891  op 0x04 field 0x04
	.byte 0xff                                   ; F96897  end
Script_F96898:   ; 2 record(s), named by B[49]
	.byte 0x08, 0x00, 0xff                       ; F96898  op 0x08 field 0x00
	.byte 0x08, 0x01, 0xff                       ; F9689B  op 0x08 field 0x01
	.byte 0xff                                   ; F9689E  end
Script_F9689F:   ; 6 record(s), named by B[50]
	.byte 0x01, 0x02, 0xf0                       ; F9689F  op 0x01 field 0x02
	.byte 0x01, 0x03, 0x7f                       ; F968A2  op 0x01 field 0x03
	.byte 0x01, 0x04, 0x3f                       ; F968A5  op 0x01 field 0x04
	.byte 0x01, 0x05, 0x7f                       ; F968A8  op 0x01 field 0x05
	.byte 0x01, 0x06, 0x00                       ; F968AB  op 0x01 field 0x06
	.byte 0x01, 0x07, 0x1f                       ; F968AE  op 0x01 field 0x07
	.byte 0xff                                   ; F968B1  end
Script_F968B2:   ; 27 record(s), named by B[51]
	.byte 0x01, 0x02, 0xff                       ; F968B2  op 0x01 field 0x02
	.byte 0x01, 0x03, 0x0f                       ; F968B5  op 0x01 field 0x03
	.byte 0x01, 0x04, 0xff                       ; F968B8  op 0x01 field 0x04
	.byte 0x01, 0x05, 0xff                       ; F968BB  op 0x01 field 0x05
	.byte 0x01, 0x06, 0xff                       ; F968BE  op 0x01 field 0x06
	.byte 0x01, 0x07, 0xff                       ; F968C1  op 0x01 field 0x07
	.byte 0x01, 0x08, 0xff                       ; F968C4  op 0x01 field 0x08
	.byte 0x01, 0x09, 0xff                       ; F968C7  op 0x01 field 0x09
	.byte 0x01, 0x0a, 0xff                       ; F968CA  op 0x01 field 0x0a
	.byte 0x01, 0x0b, 0xff                       ; F968CD  op 0x01 field 0x0b
	.byte 0x01, 0x0c, 0xff                       ; F968D0  op 0x01 field 0x0c
	.byte 0x01, 0x0d, 0xff                       ; F968D3  op 0x01 field 0x0d
	.byte 0x01, 0x0e, 0xff                       ; F968D6  op 0x01 field 0x0e
	.byte 0x01, 0x0f, 0xff                       ; F968D9  op 0x01 field 0x0f
	.byte 0x01, 0x10, 0xff                       ; F968DC  op 0x01 field 0x10
	.byte 0x01, 0x11, 0xff                       ; F968DF  op 0x01 field 0x11
	.byte 0x01, 0x12, 0xff                       ; F968E2  op 0x01 field 0x12
	.byte 0x01, 0x13, 0xff                       ; F968E5  op 0x01 field 0x13
	.byte 0x01, 0x14, 0xff                       ; F968E8  op 0x01 field 0x14
	.byte 0x01, 0x15, 0xff                       ; F968EB  op 0x01 field 0x15
	.byte 0x01, 0x16, 0xff                       ; F968EE  op 0x01 field 0x16
	.byte 0x01, 0x17, 0xff                       ; F968F1  op 0x01 field 0x17
	.byte 0x01, 0x18, 0xff                       ; F968F4  op 0x01 field 0x18
	.byte 0x01, 0x19, 0xff                       ; F968F7  op 0x01 field 0x19
	.byte 0x01, 0x1a, 0xff                       ; F968FA  op 0x01 field 0x1a
	.byte 0x01, 0x1b, 0xff                       ; F968FD  op 0x01 field 0x1b
	.byte 0x01, 0x1c, 0xff                       ; F96900  op 0x01 field 0x1c
	.byte 0xff                                   ; F96903  end
Script_F96904:   ; 15 record(s), named by B[52]
	.byte 0x01, 0x02, 0x0f                       ; F96904  op 0x01 field 0x02
	.byte 0x07, 0x02, 0x03, 0x01, 0x02, 0x00     ; F96907  op 0x07 field 0x02
	.byte 0x01, 0x03, 0x08                       ; F9690D  op 0x01 field 0x03
	.byte 0x01, 0x04, 0x1c                       ; F96910  op 0x01 field 0x04
	.byte 0x07, 0x04, 0x18, 0x01, 0x02, 0x00     ; F96913  op 0x07 field 0x04
	.byte 0x01, 0x05, 0xff                       ; F96919  op 0x01 field 0x05
	.byte 0x04, 0x05, 0x0f, 0x00, 0x02, 0x00     ; F9691C  op 0x04 field 0x05
	.byte 0x04, 0x05, 0xf0, 0x00, 0x01, 0x00     ; F96922  op 0x04 field 0x05
	.byte 0x01, 0x06, 0x2f                       ; F96928  op 0x01 field 0x06
	.byte 0x01, 0x07, 0x3f                       ; F9692B  op 0x01 field 0x07
	.byte 0x01, 0x08, 0xff                       ; F9692E  op 0x01 field 0x08
	.byte 0x01, 0x09, 0xff                       ; F96931  op 0x01 field 0x09
	.byte 0x01, 0x0a, 0xbf                       ; F96934  op 0x01 field 0x0a
	.byte 0x01, 0x0b, 0x81                       ; F96937  op 0x01 field 0x0b
	.byte 0x01, 0x0c, 0xbf                       ; F9693A  op 0x01 field 0x0c
	.byte 0xff                                   ; F9693D  end
Script_F9693E:   ; 5 record(s), named by B[53]
	.byte 0x01, 0x02, 0xff                       ; F9693E  op 0x01 field 0x02
	.byte 0x04, 0x03, 0xff, 0x00, 0x0b, 0x05     ; F96941  op 0x04 field 0x03
	.byte 0x06, 0x04, 0xff, 0x02, 0x01, 0x00     ; F96947  op 0x06 field 0x04
	.byte 0x01, 0x05, 0x07                       ; F9694D  op 0x01 field 0x05
	.byte 0x01, 0x06, 0xff                       ; F96950  op 0x01 field 0x06
	.byte 0xff                                   ; F96953  end
Script_F96954:   ; 16 record(s), named by B[54]
	.byte 0x01, 0x02, 0x0f                       ; F96954  op 0x01 field 0x02
	.byte 0x04, 0x02, 0x0f, 0x00, 0x09, 0x08     ; F96957  op 0x04 field 0x02
	.byte 0x08, 0x03, 0x00                       ; F9695D  op 0x08 field 0x03
	.byte 0x01, 0x04, 0x7f                       ; F96960  op 0x01 field 0x04
	.byte 0x04, 0x04, 0x7f, 0x00, 0x7f, 0x7f     ; F96963  op 0x04 field 0x04
	.byte 0x01, 0x05, 0x7f                       ; F96969  op 0x01 field 0x05
	.byte 0x04, 0x05, 0x7f, 0x00, 0x7f, 0x7f     ; F9696C  op 0x04 field 0x05
	.byte 0x08, 0x06, 0x00                       ; F96972  op 0x08 field 0x06
	.byte 0x01, 0x07, 0xff                       ; F96975  op 0x01 field 0x07
	.byte 0x04, 0x07, 0xff, 0x00, 0x0a, 0x05     ; F96978  op 0x04 field 0x07
	.byte 0x01, 0x08, 0x7f                       ; F9697E  op 0x01 field 0x08
	.byte 0x04, 0x08, 0x7f, 0x01, 0x7f, 0x01     ; F96981  op 0x04 field 0x08
	.byte 0x01, 0x09, 0xff                       ; F96987  op 0x01 field 0x09
	.byte 0x04, 0x09, 0xff, 0x00, 0x03, 0x00     ; F9698A  op 0x04 field 0x09
	.byte 0x01, 0x0a, 0x7f                       ; F96990  op 0x01 field 0x0a
	.byte 0x04, 0x0a, 0x7f, 0x01, 0x7f, 0x01     ; F96993  op 0x04 field 0x0a
	.byte 0xff                                   ; F96999  end
Script_F9699A:   ; 2 record(s), named by B[55]
	.byte 0x08, 0x00, 0xff                       ; F9699A  op 0x08 field 0x00
	.byte 0x08, 0x01, 0xff                       ; F9699D  op 0x08 field 0x01
	.byte 0xff                                   ; F969A0  end
; ------------------------------------------------------------------------------
; ScriptOpHandlers_F969A1 -- 15 LE32 slots indexed by the opcode byte
; (`sla hl,0x02 / add XHL,0x00f969a1 / ld XDE,(XHL) / call (xde)`).  Slots 1, 2, 3, 4, 5, 6, 7, 8
; are the routines above; the rest are zero and no script names them.
; ------------------------------------------------------------------------------
ScriptOpHandlers_F969A1:
	.long 0x00000000   ; F969A1  [ 0] unused
	.long ParamScript_AndImm   ; F969A5  [ 1] opcode 0x01
	.long ParamScript_ClearBitsImm   ; F969A9  [ 2] opcode 0x02
	.long ParamScript_SetBitsImm   ; F969AD  [ 3] opcode 0x03
	.long ParamScript_ClampFieldOrDefault   ; F969B1  [ 4] opcode 0x04
	.long ParamScript_ReplaceFieldIfInRange   ; F969B5  [ 5] opcode 0x05
	.long ParamScript_FieldInListElseLast   ; F969B9  [ 6] opcode 0x06
	.long ParamScript_MapFieldIfInList   ; F969BD  [ 7] opcode 0x07
	.long ParamScript_SetImm   ; F969C1  [ 8] opcode 0x08
	.long 0x00000000   ; F969C5  [ 9] unused
	.long 0x00000000   ; F969C9  [10] unused
	.long 0x00000000   ; F969CD  [11] unused
	.long 0x00000000   ; F969D1  [12] unused
	.long 0x00000000   ; F969D5  [13] unused
	.long 0x00000000   ; F969D9  [14] unused
; ------------------------------------------------------------------------------
; ScriptTableA_F969DD -- 24 (u32 struct offset, u32 script) pairs then the
; 0xFFFFFFFF terminator `.LF964B9` stops on.  Named by `ld XIX,0x00f969dd` at 0xF96455 and 0xF96484.
; ------------------------------------------------------------------------------
ScriptTableA_F969DD:
	.long 0x00000000, Script_F9667A   ; F969DD  [ 0] +0x0000 -> Script_F9667A
	.long 0x00000012, Script_F966AB   ; F969E5  [ 1] +0x0012 -> Script_F966AB
	.long 0x00000020, Script_F966AC   ; F969ED  [ 2] +0x0020 -> Script_F966AC
	.long 0x00000040, Script_F966F2   ; F969F5  [ 3] +0x0040 -> Script_F966F2
	.long 0x00000060, Script_F96738   ; F969FD  [ 4] +0x0060 -> Script_F96738
	.long 0x00000080, Script_F9677E   ; F96A05  [ 5] +0x0080 -> Script_F9677E
	.long 0x000000a0, Script_F967C4   ; F96A0D  [ 6] +0x00a0 -> Script_F967C4
	.long 0x000000c0, Script_F9677E   ; F96A15  [ 7] +0x00c0 -> Script_F9677E
	.long 0x000000e0, Script_F967C4   ; F96A1D  [ 8] +0x00e0 -> Script_F967C4
	.long 0x00000100, Script_F9677E   ; F96A25  [ 9] +0x0100 -> Script_F9677E
	.long 0x00000120, Script_F967C4   ; F96A2D  [10] +0x0120 -> Script_F967C4
	.long 0x00000140, Script_F9677E   ; F96A35  [11] +0x0140 -> Script_F9677E
	.long 0x00000160, Script_F967C4   ; F96A3D  [12] +0x0160 -> Script_F967C4
	.long 0x00000180, Script_F9677E   ; F96A45  [13] +0x0180 -> Script_F9677E
	.long 0x000001a0, Script_F967C4   ; F96A4D  [14] +0x01a0 -> Script_F967C4
	.long 0x000001c0, Script_F9677E   ; F96A55  [15] +0x01c0 -> Script_F9677E
	.long 0x000001e0, Script_F967C4   ; F96A5D  [16] +0x01e0 -> Script_F967C4
	.long 0x00000200, Script_F9677E   ; F96A65  [17] +0x0200 -> Script_F9677E
	.long 0x00000220, Script_F967C4   ; F96A6D  [18] +0x0220 -> Script_F967C4
	.long 0x00000240, Script_F9677E   ; F96A75  [19] +0x0240 -> Script_F9677E
	.long 0x00000260, Script_F967C4   ; F96A7D  [20] +0x0260 -> Script_F967C4
	.long 0x00000280, Script_F9682B   ; F96A85  [21] +0x0280 -> Script_F9682B
	.long 0x00000290, Script_F9685C   ; F96A8D  [22] +0x0290 -> Script_F9685C
	.long 0x000002be, Script_F9687B   ; F96A95  [23] +0x02be -> Script_F9687B
	.long 0xffffffff   ; F96A9D  end of table
; ------------------------------------------------------------------------------
; ScriptTableB_F96AA1 -- 56 (u32 struct offset, u32 script) pairs then the
; 0xFFFFFFFF terminator `.LF964B9` stops on.  Named by `ld XIX,0x00f96aa1` at 0xF96476.
; ------------------------------------------------------------------------------
ScriptTableB_F96AA1:
	.long 0x000002c0, Script_F9677E   ; F96AA1  [ 0] +0x02c0 -> Script_F9677E
	.long 0x000002e0, Script_F967C4   ; F96AA9  [ 1] +0x02e0 -> Script_F967C4
	.long 0x00000300, Script_F9677E   ; F96AB1  [ 2] +0x0300 -> Script_F9677E
	.long 0x00000320, Script_F967C4   ; F96AB9  [ 3] +0x0320 -> Script_F967C4
	.long 0x00000340, Script_F9677E   ; F96AC1  [ 4] +0x0340 -> Script_F9677E
	.long 0x00000360, Script_F967C4   ; F96AC9  [ 5] +0x0360 -> Script_F967C4
	.long 0x00000380, Script_F9677E   ; F96AD1  [ 6] +0x0380 -> Script_F9677E
	.long 0x000003a0, Script_F967C4   ; F96AD9  [ 7] +0x03a0 -> Script_F967C4
	.long 0x000003c0, Script_F9677E   ; F96AE1  [ 8] +0x03c0 -> Script_F9677E
	.long 0x000003e0, Script_F967C4   ; F96AE9  [ 9] +0x03e0 -> Script_F967C4
	.long 0x00000400, Script_F9677E   ; F96AF1  [10] +0x0400 -> Script_F9677E
	.long 0x00000420, Script_F967C4   ; F96AF9  [11] +0x0420 -> Script_F967C4
	.long 0x00000440, Script_F9677E   ; F96B01  [12] +0x0440 -> Script_F9677E
	.long 0x00000460, Script_F967C4   ; F96B09  [13] +0x0460 -> Script_F967C4
	.long 0x00000480, Script_F9677E   ; F96B11  [14] +0x0480 -> Script_F9677E
	.long 0x000004a0, Script_F967C4   ; F96B19  [15] +0x04a0 -> Script_F967C4
	.long 0x000004c0, Script_F9677E   ; F96B21  [16] +0x04c0 -> Script_F9677E
	.long 0x000004e0, Script_F967C4   ; F96B29  [17] +0x04e0 -> Script_F967C4
	.long 0x00000500, Script_F9677E   ; F96B31  [18] +0x0500 -> Script_F9677E
	.long 0x00000520, Script_F967C4   ; F96B39  [19] +0x0520 -> Script_F967C4
	.long 0x00000540, Script_F9677E   ; F96B41  [20] +0x0540 -> Script_F9677E
	.long 0x00000560, Script_F967C4   ; F96B49  [21] +0x0560 -> Script_F967C4
	.long 0x00000580, Script_F9677E   ; F96B51  [22] +0x0580 -> Script_F9677E
	.long 0x000005a0, Script_F967C4   ; F96B59  [23] +0x05a0 -> Script_F967C4
	.long 0x000005c0, Script_F9677E   ; F96B61  [24] +0x05c0 -> Script_F9677E
	.long 0x000005e0, Script_F967C4   ; F96B69  [25] +0x05e0 -> Script_F967C4
	.long 0x00000600, Script_F9677E   ; F96B71  [26] +0x0600 -> Script_F9677E
	.long 0x00000620, Script_F967C4   ; F96B79  [27] +0x0620 -> Script_F967C4
	.long 0x00000640, Script_F9677E   ; F96B81  [28] +0x0640 -> Script_F9677E
	.long 0x00000660, Script_F967C4   ; F96B89  [29] +0x0660 -> Script_F967C4
	.long 0x00000680, Script_F9677E   ; F96B91  [30] +0x0680 -> Script_F9677E
	.long 0x000006a0, Script_F967C4   ; F96B99  [31] +0x06a0 -> Script_F967C4
	.long 0x000006c0, Script_F9677E   ; F96BA1  [32] +0x06c0 -> Script_F9677E
	.long 0x000006e0, Script_F967C4   ; F96BA9  [33] +0x06e0 -> Script_F967C4
	.long 0x00000700, Script_F9677E   ; F96BB1  [34] +0x0700 -> Script_F9677E
	.long 0x00000720, Script_F967C4   ; F96BB9  [35] +0x0720 -> Script_F967C4
	.long 0x00000740, Script_F9677E   ; F96BC1  [36] +0x0740 -> Script_F9677E
	.long 0x00000760, Script_F967C4   ; F96BC9  [37] +0x0760 -> Script_F967C4
	.long 0x00000780, Script_F9677E   ; F96BD1  [38] +0x0780 -> Script_F9677E
	.long 0x000007a0, Script_F967C4   ; F96BD9  [39] +0x07a0 -> Script_F967C4
	.long 0x000007c0, Script_F9677E   ; F96BE1  [40] +0x07c0 -> Script_F9677E
	.long 0x000007e0, Script_F967C4   ; F96BE9  [41] +0x07e0 -> Script_F967C4
	.long 0x00000800, Script_F9677E   ; F96BF1  [42] +0x0800 -> Script_F9677E
	.long 0x00000820, Script_F967C4   ; F96BF9  [43] +0x0820 -> Script_F967C4
	.long 0x00000840, Script_F9677E   ; F96C01  [44] +0x0840 -> Script_F9677E
	.long 0x00000860, Script_F967C4   ; F96C09  [45] +0x0860 -> Script_F967C4
	.long 0x00000880, Script_F9677E   ; F96C11  [46] +0x0880 -> Script_F9677E
	.long 0x000008a0, Script_F967C4   ; F96C19  [47] +0x08a0 -> Script_F967C4
	.long 0x000008c0, Script_F96882   ; F96C21  [48] +0x08c0 -> Script_F96882
	.long 0x000008de, Script_F96898   ; F96C29  [49] +0x08de -> Script_F96898
	.long 0x000008e0, Script_F9689F   ; F96C31  [50] +0x08e0 -> Script_F9689F
	.long 0x000008f0, Script_F968B2   ; F96C39  [51] +0x08f0 -> Script_F968B2
	.long 0x00000910, Script_F96904   ; F96C41  [52] +0x0910 -> Script_F96904
	.long 0x00000928, Script_F9693E   ; F96C49  [53] +0x0928 -> Script_F9693E
	.long 0x00000938, Script_F96954   ; F96C51  [54] +0x0938 -> Script_F96954
	.long 0x0000095e, Script_F9699A   ; F96C59  [55] +0x095e -> Script_F9699A
	.long 0xffffffff   ; F96C61  end of table
; ParamImage_ApplyAndMaskTable -- AND each (address, mask) record of ReservedRecordTable_F96C7B into memory;
; with BC = 1 that is (0x7F32) &= 0xFB
; Evidence: `ld XIY,0xF96C7B / ldw bc,1`, then `ld XIX,(XIY) / inc 4,XIY / ld A,(XIY) / and (XIX),A`.
; 0x7F32 is record 0x80's first payload byte (header at 0x7F30 in RamInitTable_F96CA6), and its bit 2 is
; the bit MIDI_RT_Received tests to choose MIDI_RT_ExternalOff.
ParamImage_ApplyAndMaskTable:   ; entry: branch/call in converted code
	ld XIY,ReservedRecordTable_F96C7B                    ; F96C65  45 7b 6c f9 00
	ldw bc, 0x01                                         ; F96C6A  31 01 00
.LF96C6D:
	ld XIX,(XIY)                                         ; F96C6D  a5 24
	inc 4,XIY                                            ; F96C6F  ed 64
	ld A,(XIY)                                           ; F96C71  85 21
	inc 1,XIY                                            ; F96C73  ed 61
	and (XIX),A                                          ; F96C75  84 c9
	djnz16 bc, .LF96C6D                                  ; F96C77  d9 1c f3
	ret                                                  ; F96C7A  0e
ReservedRecordTable_F96C7B:   ; 3 x 5-byte (addr32,mask8) records, read by ParamImage_ApplyAndMaskTable (above) which processes only record 0
	.long 0x00007f32   ; F96C7B  record 0 addr
	.byte 0xfb         ; F96C7F  record 0 mask
	.long 0x00000000, 0x00000000   ; F96C80  records 1-2 addr, unused/reserved
	.byte 0x00, 0x00   ; F96C88  records 1-2 mask, unused/reserved
; ParamImage_WriteRecordHeaders -- write the 80 {record number, length} header words of the parameter image
; at 0x7620 from RamInitTable_F96CA6
; Evidence: `ld (XHL),WA` with WA from _Values and XHL from _Addrs, BC = 0x50 (0xF96C8A-0xF96CA1). Each value
; is record number (low byte: 0x78, 0x60-0x63, 0x00-0x3F, 0x79, 0x7A, 0x80, 0x91-0x93, 0x98, 0x99) plus
; length (high byte); address + 2 + length = the next address for all 77 records, and the three 0xFFFF words
; are 2-byte terminators at +0x2BE, +0x8DE and +0x95E, so the headers tile 0x7620-0x7F7F exactly.
ParamImage_WriteRecordHeaders:   ; entry: branch/call in converted code
	ld XIY,RamInitTable_F96CA6_Values                    ; F96C8A  45 e6 6d f9 00
	ld XIX,RamInitTable_F96CA6_Addrs                     ; F96C8F  44 a6 6c f9 00
	ld XBC,0x00000050                                    ; F96C94  41 50 00 00 00
.LF96C99:
	ld wa, (xiy+)                                     ; F96C99  d5 f5 20
	ld xhl, (xix+)                                    ; F96C9C  e5 f2 23
	ld (XHL),WA                                          ; F96C9F  b3 50
	djnz16 bc, .LF96C99                                  ; F96CA1  d9 1c f5
	ret                                                  ; F96CA4  0e
; 0xF96CA5 -- 1 B of 0x0E (this file's own erased-flash/RET-padding value), between ParamImage_WriteRecordHeaders's ret and RamInitTable_F96CA6_Addrs.
	.fill 1, 1, 0x0E   ; F96CA5
; ---------------------------------------------------------------------
; RamInitTable_F96CA6 -- 80 (address, value) pairs, split as two parallel
; arrays: 80 LE32 RAM addresses here, then 80 LE16 values at 0xF96DE6.
;
; Evidence: ParamImage_WriteRecordHeaders (0xF96C8A) is the ONLY reader.  It sets
;          XIY=0x00F96DE6, XIX=0x00F96CA6, BC=0x0050 (80), then loops
;          `ld_spiw wa, 0xf5` / `ld_spil xhl, 0xf2` / `ld (XHL),WA` --
;          0xF5 and 0xF2 are this file's own established selector bytes
;          for `(XIY+)` and `(XIX+)` (see e.g. 0xFA7FB4's inline comment)
;          -- i.e. WA = *(XIY)++ (a word from THIS array), XHL = *(XIX)++
;          (a 32-bit address from the array below), then *(XHL) = WA.
;          80 iterations consumes exactly 320 + 160 = 480 bytes, landing
;          EXACTLY on 0xF96E86 -- three bytes short of the incbin's own
;          end at 0xF96E89, which is the already-documented 1400-byte
;          0x0E fill run.  So: init-time writer, RAM addresses here,
;          their reset values in the sibling array.  What the fields
;          at these addresses MEAN is not established; the layout is.
; ---------------------------------------------------------------------
RamInitTable_F96CA6_Addrs:
	.long 0x00007620                                 ; F96CA6  [  0]
	.long 0x00007632                                 ; F96CAA  [  1]
	.long 0x00007640                                 ; F96CAE  [  2]
	.long 0x00007660                                 ; F96CB2  [  3]
	.long 0x00007680                                 ; F96CB6  [  4]
	.long 0x000076a0                                 ; F96CBA  [  5]
	.long 0x000076c0                                 ; F96CBE  [  6]
	.long 0x000076e0                                 ; F96CC2  [  7]
	.long 0x00007700                                 ; F96CC6  [  8]
	.long 0x00007720                                 ; F96CCA  [  9]
	.long 0x00007740                                 ; F96CCE  [ 10]
	.long 0x00007760                                 ; F96CD2  [ 11]
	.long 0x00007780                                 ; F96CD6  [ 12]
	.long 0x000077a0                                 ; F96CDA  [ 13]
	.long 0x000077c0                                 ; F96CDE  [ 14]
	.long 0x000077e0                                 ; F96CE2  [ 15]
	.long 0x00007800                                 ; F96CE6  [ 16]
	.long 0x00007820                                 ; F96CEA  [ 17]
	.long 0x00007840                                 ; F96CEE  [ 18]
	.long 0x00007860                                 ; F96CF2  [ 19]
	.long 0x00007880                                 ; F96CF6  [ 20]
	.long 0x000078a0                                 ; F96CFA  [ 21]
	.long 0x000078b0                                 ; F96CFE  [ 22]
	.long 0x000078de                                 ; F96D02  [ 23]
	.long 0x000078e0                                 ; F96D06  [ 24]
	.long 0x00007900                                 ; F96D0A  [ 25]
	.long 0x00007920                                 ; F96D0E  [ 26]
	.long 0x00007940                                 ; F96D12  [ 27]
	.long 0x00007960                                 ; F96D16  [ 28]
	.long 0x00007980                                 ; F96D1A  [ 29]
	.long 0x000079a0                                 ; F96D1E  [ 30]
	.long 0x000079c0                                 ; F96D22  [ 31]
	.long 0x000079e0                                 ; F96D26  [ 32]
	.long 0x00007a00                                 ; F96D2A  [ 33]
	.long 0x00007a20                                 ; F96D2E  [ 34]
	.long 0x00007a40                                 ; F96D32  [ 35]
	.long 0x00007a60                                 ; F96D36  [ 36]
	.long 0x00007a80                                 ; F96D3A  [ 37]
	.long 0x00007aa0                                 ; F96D3E  [ 38]
	.long 0x00007ac0                                 ; F96D42  [ 39]
	.long 0x00007ae0                                 ; F96D46  [ 40]
	.long 0x00007b00                                 ; F96D4A  [ 41]
	.long 0x00007b20                                 ; F96D4E  [ 42]
	.long 0x00007b40                                 ; F96D52  [ 43]
	.long 0x00007b60                                 ; F96D56  [ 44]
	.long 0x00007b80                                 ; F96D5A  [ 45]
	.long 0x00007ba0                                 ; F96D5E  [ 46]
	.long 0x00007bc0                                 ; F96D62  [ 47]
	.long 0x00007be0                                 ; F96D66  [ 48]
	.long 0x00007c00                                 ; F96D6A  [ 49]
	.long 0x00007c20                                 ; F96D6E  [ 50]
	.long 0x00007c40                                 ; F96D72  [ 51]
	.long 0x00007c60                                 ; F96D76  [ 52]
	.long 0x00007c80                                 ; F96D7A  [ 53]
	.long 0x00007ca0                                 ; F96D7E  [ 54]
	.long 0x00007cc0                                 ; F96D82  [ 55]
	.long 0x00007ce0                                 ; F96D86  [ 56]
	.long 0x00007d00                                 ; F96D8A  [ 57]
	.long 0x00007d20                                 ; F96D8E  [ 58]
	.long 0x00007d40                                 ; F96D92  [ 59]
	.long 0x00007d60                                 ; F96D96  [ 60]
	.long 0x00007d80                                 ; F96D9A  [ 61]
	.long 0x00007da0                                 ; F96D9E  [ 62]
	.long 0x00007dc0                                 ; F96DA2  [ 63]
	.long 0x00007de0                                 ; F96DA6  [ 64]
	.long 0x00007e00                                 ; F96DAA  [ 65]
	.long 0x00007e20                                 ; F96DAE  [ 66]
	.long 0x00007e40                                 ; F96DB2  [ 67]
	.long 0x00007e60                                 ; F96DB6  [ 68]
	.long 0x00007e80                                 ; F96DBA  [ 69]
	.long 0x00007ea0                                 ; F96DBE  [ 70]
	.long 0x00007ec0                                 ; F96DC2  [ 71]
	.long 0x00007ee0                                 ; F96DC6  [ 72]
	.long 0x00007efe                                 ; F96DCA  [ 73]
	.long 0x00007f00                                 ; F96DCE  [ 74]
	.long 0x00007f10                                 ; F96DD2  [ 75]
	.long 0x00007f30                                 ; F96DD6  [ 76]
	.long 0x00007f48                                 ; F96DDA  [ 77]
	.long 0x00007f58                                 ; F96DDE  [ 78]
	.long 0x00007f7e                                 ; F96DE2  [ 79]
; RamInitTable_F96CA6_Values -- the 80 LE16 values written to the
; addresses in RamInitTable_F96CA6_Addrs above, same index, same loop.
RamInitTable_F96CA6_Values:
	.short 0x1078                                     ; F96DE6  [  0]
	.short 0x0c60                                     ; F96DE8  [  1]
	.short 0x1e61                                     ; F96DEA  [  2]
	.short 0x1e62                                     ; F96DEC  [  3]
	.short 0x1e63                                     ; F96DEE  [  4]
	.short 0x1e00                                     ; F96DF0  [  5]
	.short 0x1e20                                     ; F96DF2  [  6]
	.short 0x1e01                                     ; F96DF4  [  7]
	.short 0x1e21                                     ; F96DF6  [  8]
	.short 0x1e02                                     ; F96DF8  [  9]
	.short 0x1e22                                     ; F96DFA  [ 10]
	.short 0x1e03                                     ; F96DFC  [ 11]
	.short 0x1e23                                     ; F96DFE  [ 12]
	.short 0x1e04                                     ; F96E00  [ 13]
	.short 0x1e24                                     ; F96E02  [ 14]
	.short 0x1e05                                     ; F96E04  [ 15]
	.short 0x1e25                                     ; F96E06  [ 16]
	.short 0x1e06                                     ; F96E08  [ 17]
	.short 0x1e26                                     ; F96E0A  [ 18]
	.short 0x1e07                                     ; F96E0C  [ 19]
	.short 0x1e27                                     ; F96E0E  [ 20]
	.short 0x0e92                                     ; F96E10  [ 21]
	.short 0x2c79                                     ; F96E12  [ 22]
	.short 0xffff                                     ; F96E14  [ 23]
	.short 0x1e08                                     ; F96E16  [ 24]
	.short 0x1e28                                     ; F96E18  [ 25]
	.short 0x1e09                                     ; F96E1A  [ 26]
	.short 0x1e29                                     ; F96E1C  [ 27]
	.short 0x1e0a                                     ; F96E1E  [ 28]
	.short 0x1e2a                                     ; F96E20  [ 29]
	.short 0x1e0b                                     ; F96E22  [ 30]
	.short 0x1e2b                                     ; F96E24  [ 31]
	.short 0x1e0c                                     ; F96E26  [ 32]
	.short 0x1e2c                                     ; F96E28  [ 33]
	.short 0x1e0d                                     ; F96E2A  [ 34]
	.short 0x1e2d                                     ; F96E2C  [ 35]
	.short 0x1e0e                                     ; F96E2E  [ 36]
	.short 0x1e2e                                     ; F96E30  [ 37]
	.short 0x1e0f                                     ; F96E32  [ 38]
	.short 0x1e2f                                     ; F96E34  [ 39]
	.short 0x1e10                                     ; F96E36  [ 40]
	.short 0x1e30                                     ; F96E38  [ 41]
	.short 0x1e11                                     ; F96E3A  [ 42]
	.short 0x1e31                                     ; F96E3C  [ 43]
	.short 0x1e12                                     ; F96E3E  [ 44]
	.short 0x1e32                                     ; F96E40  [ 45]
	.short 0x1e13                                     ; F96E42  [ 46]
	.short 0x1e33                                     ; F96E44  [ 47]
	.short 0x1e14                                     ; F96E46  [ 48]
	.short 0x1e34                                     ; F96E48  [ 49]
	.short 0x1e15                                     ; F96E4A  [ 50]
	.short 0x1e35                                     ; F96E4C  [ 51]
	.short 0x1e16                                     ; F96E4E  [ 52]
	.short 0x1e36                                     ; F96E50  [ 53]
	.short 0x1e17                                     ; F96E52  [ 54]
	.short 0x1e37                                     ; F96E54  [ 55]
	.short 0x1e18                                     ; F96E56  [ 56]
	.short 0x1e38                                     ; F96E58  [ 57]
	.short 0x1e19                                     ; F96E5A  [ 58]
	.short 0x1e39                                     ; F96E5C  [ 59]
	.short 0x1e1a                                     ; F96E5E  [ 60]
	.short 0x1e3a                                     ; F96E60  [ 61]
	.short 0x1e1b                                     ; F96E62  [ 62]
	.short 0x1e3b                                     ; F96E64  [ 63]
	.short 0x1e1c                                     ; F96E66  [ 64]
	.short 0x1e3c                                     ; F96E68  [ 65]
	.short 0x1e1d                                     ; F96E6A  [ 66]
	.short 0x1e3d                                     ; F96E6C  [ 67]
	.short 0x1e1e                                     ; F96E6E  [ 68]
	.short 0x1e3e                                     ; F96E70  [ 69]
	.short 0x1e1f                                     ; F96E72  [ 70]
	.short 0x1e3f                                     ; F96E74  [ 71]
	.short 0x1c7a                                     ; F96E76  [ 72]
	.short 0xffff                                     ; F96E78  [ 73]
	.short 0x0e98                                     ; F96E7A  [ 74]
	.short 0x1e99                                     ; F96E7C  [ 75]
	.short 0x1680                                     ; F96E7E  [ 76]
	.short 0x0e91                                     ; F96E80  [ 77]
	.short 0x2493                                     ; F96E82  [ 78]
	.short 0xffff                                     ; F96E84  [ 79]
; 0xF96E86-0xF96E89 -- 3 B, unclassified.  RamInitTable_F96CA6's own
; header comment already proves its 480 B end exactly here, so these
; bytes are NOT part of either array.  No reader anywhere in the ROM
; cites this address (checked: 0 raw pointer hits).  Left untyped.
Unclassified_F96E86:
	.byte 0x24, 0xff, 0xff   ; F96E86
; 0xF96E89-0xF97400 -- 1400 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: verified against original_ROMs/wsa1_prom_a.ic12.
	.fill 1400, 1, 0x0E
; 0xF97401-0xF97418 -- 23 B, unclassified.  Bounded by the already-
; verified 1400 B 0x0E fill run (ends exactly here) and Queue2C00_DrainPassB_SaveRegs
; (starts exactly at the far end).  Not a clean tile of the fill
; (mostly zero, one 0x0E every 4th byte, and 23 is not a multiple
; of 4) and no reader anywhere in the ROM cites this address.
Unclassified_F97401:
	.byte 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00, 0x0e, 0x00, 0x00, 0x00   ; F97401
; Queue2C00_DrainPassB_SaveRegs -- T_Queue2C00_DrainPassB with XIZ, XIX, XHL and XDE preserved
; Evidence: four pushes, `call T_Queue2C00_DrainPassB` (0xF9741C), four pops. Called by
; ParamImage_QueueDiffCombination (0xF98A04) and ParamImage_QueueDiffCombinationAndParts (0xF98B76) when
; the 0x2C00 cursor reaches 0x1F4, after they terminate the list with 0xFF.
Queue2C00_DrainPassB_SaveRegs:   ; entry: reachable-run entry
	push XIZ                                             ; F97418  3e
	push XIX                                             ; F97419  3c
	push XHL                                             ; F9741A  3b
	push XDE                                             ; F9741B  3a
	call T_Queue2C00_DrainPassB                          ; F9741C  1d 38 00 f4
	pop XDE                                              ; F97420  5a
	pop XHL                                              ; F97421  5b
	pop XIX                                              ; F97422  5c
	pop XIZ                                              ; F97423  5e
	ret                                                  ; F97424  0e
; ParamImage_SnapshotCombination -- copy the COMBINATION stream of the parameter image (0x7620, 0x2BE bytes)
; to the snapshot at 0x608000
; Evidence: `lda XIX,0x608000 / lda XIY,0x7620 / ldw BC,0x015F / ldirw` = 0x2BE bytes, ending at that
; stream's FF FF terminator (+0x2BE, RamInitTable_F96CA6 entry 23). Callers: Combination_Recall (0xF9759F)
; and ParamImage_SnapshotCombination_Entry (0xF98984).
ParamImage_SnapshotCombination:
	push XIX                                             ; F97425  3c
	lda xix, (0x608000:24)                               ; F97426  f2 00 80 60 34
	lda xiy, (Combination_Current:16)                                ; F9742B  f1 20 76 35
	ldw bc, 0x015f                                       ; F9742F  31 5f 01
	ldirw                                                ; F97432  95 11
	pop XIX                                              ; F97434  5c
	ret                                                  ; F97435  0e
; ParamImage_SnapshotCombinationAndParts -- save record 0x79 bytes 1-4 (0x78B3) to (0x2181), then copy the
; first 0x8DE bytes of the parameter image (0x7620) to the snapshot at 0x608000
; Evidence: `ld xwa,(0x78b3) / ld (0x2181),xwa`; `ldw BC,0x046F / ldirw` = 0x8DE bytes, up to the second FF FF
; terminator (+0x8DE): the COMBINATION stream plus part records 0x08-0x1F/0x28-0x3F and 0x7A.
; Caller: ParamImage_SnapshotCombinationAndParts_Entry (0xF98989).
ParamImage_SnapshotCombinationAndParts:
	push XWA                                             ; F97436  38
	push XIX                                             ; F97437  3c
	ld xwa, (0x78b3:16)                                 ; F97438  e1 b3 78 20
	ld (0x2181:16), xwa                                 ; F9743C  f1 81 21 60
	lda xix, (0x608000:24)                               ; F97440  f2 00 80 60 34
	lda xiy, (Combination_Current:16)                                ; F97445  f1 20 76 35
	ldw bc, 0x046f                                       ; F97449  31 6f 04
	ldirw                                                ; F9744C  95 11
	pop XIX                                              ; F9744E  5c
	pop XWA                                              ; F9744F  58
	ret                                                  ; F97450  0e
; MidiOut_PostPartProgramChange -- post PROGRAM CHANGE (offset 0) of the current part through
; MidiOut_ParamChanged, from the part's own byte or its MIDI MULTIPLE MESSAGES OUTPUT override
; Evidence: XIX = (0x218B) (part A-block payload), C = (0x218F) (its record number), B = 0. Bit 0 of
; (XIX+0x15) set: E = (XIX+0x00), D = 0xFF; clear: E = (XIX+0x0E) & 0x7F, D = 0x7F. +0x0E is MMO: PROGRAM
; CHANGE, +0x15 bit 0 its flag (sec-blocks.tex). Caller: Combination_Recall's .LF98627 if (XIX+0x0E) < 0x80.
MidiOut_PostPartProgramChange:
	push XIZ                                             ; F97451  3e
	push XIX                                             ; F97452  3c
	push XHL                                             ; F97453  3b
	push XDE                                             ; F97454  3a
	ld xix, (0x218b:16)                                 ; F97455  e1 8b 21 24
	bit 0,(XIX+0x15)                                     ; F97459  bc 15 c8
	jr z, .LF9746A                                       ; F9745C  66 0c
	ld b, 0x00:opc                                          ; F9745E  22 00
	ld	e, (xix+0:8)                                 ; F97460  8c 00 25
	and E,0xff                                           ; F97463  cd cc ff
	ld d, 0xff:opc                                          ; F97466  24 ff
	jr .LF97474                                          ; F97468  68 0a
.LF9746A:
	ld b, 0x00:opc                                          ; F9746A  22 00
	ld E,(XIX+0x0e)                                      ; F9746C  8c 0e 25
	and E,0x7f                                           ; F9746F  cd cc 7f
	ld d, 0x7f:opc                                          ; F97472  24 7f
.LF97474:
	ld c, (0x218f:16)                                   ; F97474  c1 8f 21 23
	call T_MidiOut_ParamChanged                          ; F97478  1d 48 07 f4
	pop XDE                                              ; F9747C  5a
	pop XHL                                              ; F9747D  5b
	pop XIX                                              ; F9747E  5c
	pop XIZ                                              ; F9747F  5e
	ret                                                  ; F97480  0e
; MidiOut_PostPartBankSelect -- post the current part's bank: its own (bit 5 of +0x15 set) or the two-byte
; MMO: BANK SELECT override at +0x0F/+0x10 (clear)
; Evidence: XIX = (0x218B). Set: E = (XIX+0x01) & 0x3F, `sll 5,DE / srl 1,E`, B = (0x218F), C = 0x81, call
; T_ParamChange_NotifyClearSource. Clear: T_MidiOut_ParamChanged twice, B = 0x10 with (XIX+0x10) & 0x7F and
; B = 0x0F with (XIX+0x0F) & 0x7F, C = (0x218F). Bit 5 = BANK SELECT in sec-blocks.tex.
; Caller: Combination_Recall's .LF98627, when (XIX+0x0F) < 0x80.
MidiOut_PostPartBankSelect:
	push XIZ                                             ; F97481  3e
	push XIX                                             ; F97482  3c
	push XHL                                             ; F97483  3b
	push XDE                                             ; F97484  3a
	ld xix, (0x218b:16)                                 ; F97485  e1 8b 21 24
	bit 5,(XIX+0x15)                                     ; F97489  bc 15 cd
	jr z, .LF974A8                                       ; F9748C  66 1a
	ld E,(XIX+0x01)                                      ; F9748E  8c 01 25
	extz DE                                              ; F97491  da 12
	and E,0x3f                                           ; F97493  cd cc 3f
	sll de, 0x05                                         ; F97496  da ee 05
	srl e, 0x01                                          ; F97499  cd ef 01
	ld b, (0x218f:16)                                   ; F9749C  c1 8f 21 22
	ld c, 0x81:opc                                          ; F974A0  23 81
	call T_ParamChange_NotifyClearSource                 ; F974A2  1d cc 07 f4
	jr .LF974CE                                          ; F974A6  68 26
.LF974A8:
	ld b, 0x10:opc                                          ; F974A8  22 10
	ld E,(XIX+0x10)                                      ; F974AA  8c 10 25
	and E,0x7f                                           ; F974AD  cd cc 7f
	ld d, 0x7f:opc                                          ; F974B0  24 7f
	ld c, (0x218f:16)                                   ; F974B2  c1 8f 21 23
	push XIX                                             ; F974B6  3c
	call T_MidiOut_ParamChanged                          ; F974B7  1d 48 07 f4
	pop XIX                                              ; F974BB  5c
	ld b, 0x0f:opc                                          ; F974BC  22 0f
	ld E,(XIX+0x0f)                                      ; F974BE  8c 0f 25
	and E,0x7f                                           ; F974C1  cd cc 7f
	ld d, 0x7f:opc                                          ; F974C4  24 7f
	ld c, (0x218f:16)                                   ; F974C6  c1 8f 21 23
	call T_MidiOut_ParamChanged                          ; F974CA  1d 48 07 f4
.LF974CE:
	pop XDE                                              ; F974CE  5a
	pop XHL                                              ; F974CF  5b
	pop XIX                                              ; F974D0  5c
	pop XIZ                                              ; F974D1  5e
	ret                                                  ; F974D2  0e
; MidiOut_PostPartVolume -- post VOLUME (offset 3) of the current part through MidiOut_ParamChanged, from
; the part's own byte or its MMO: VOLUME override
; Evidence: XIX = (0x218B), C = (0x218F), B = 3, D = 0x7F; bit 1 of (XIX+0x15) set: E = (XIX+0x03) & 0x7F,
; clear: E = (XIX+0x11) & 0x7F (MMO: VOLUME is offset 0x11, tbl:partparams). Caller: Combination_Recall's
; .LF98627, when (XIX+0x11) < 0x80.
MidiOut_PostPartVolume:
	push XIZ                                             ; F974D3  3e
	push XIX                                             ; F974D4  3c
	push XHL                                             ; F974D5  3b
	push XDE                                             ; F974D6  3a
	ld xix, (0x218b:16)                                 ; F974D7  e1 8b 21 24
	bit 1,(XIX+0x15)                                     ; F974DB  bc 15 c9
	jr z, .LF974EC                                       ; F974DE  66 0c
	ld b, 0x03:opc                                          ; F974E0  22 03
	ld E,(XIX+0x03)                                      ; F974E2  8c 03 25
	and E,0x7f                                           ; F974E5  cd cc 7f
	ld d, 0x7f:opc                                          ; F974E8  24 7f
	jr .LF974F6                                          ; F974EA  68 0a
.LF974EC:
	ld b, 0x03:opc                                          ; F974EC  22 03
	ld E,(XIX+0x11)                                      ; F974EE  8c 11 25
	and E,0x7f                                           ; F974F1  cd cc 7f
	ld d, 0x7f:opc                                          ; F974F4  24 7f
.LF974F6:
	ld c, (0x218f:16)                                   ; F974F6  c1 8f 21 23
	call T_MidiOut_ParamChanged                          ; F974FA  1d 48 07 f4
	pop XDE                                              ; F974FE  5a
	pop XHL                                              ; F974FF  5b
	pop XIX                                              ; F97500  5c
	pop XIZ                                              ; F97501  5e
	ret                                                  ; F97502  0e
; MidiOut_PostPartPanpot -- post PANPOT (offset 8) of the current part through MidiOut_ParamChanged, from
; the part's own byte or its MMO: PANPOT override
; Evidence: XIX = (0x218B), C = (0x218F), B = 8, D = 0x7F; bit 2 of (XIX+0x15) set: E = (XIX+0x08) & 0x7F,
; clear: E = (XIX+0x12) & 0x7F (MMO: PANPOT, offset 0x12). Reached only by `lda xix,<this>` (0xF98628) and
; `jp (xix)` in Combination_Recall's .LF98627, when (XIX+0x12) < 0x80 -- hence no `call` site.
MidiOut_PostPartPanpot:
	push XIZ                                      ; F97503  3e
	push XIX                                      ; F97504  3c
	push XHL                                      ; F97505  3b
	push XDE                                      ; F97506  3a
	ld xix, (0x218b:16)                          ; F97507  e1 8b 21 24
	bit 2,(XIX+0x15)                              ; F9750B  bc 15 ca
	jr z, .LF9751C                                ; F9750E  66 0c
	ld b, 0x08:opc                                   ; F97510  22 08
	ld E,(XIX+0x08)                               ; F97512  8c 08 25
	and E,0x7f                                    ; F97515  cd cc 7f
	ld d, 0x7f:opc                                   ; F97518  24 7f
	jr .LF97526                                   ; F9751A  68 0a
.LF9751C:
	ld b, 0x08:opc                                   ; F9751C  22 08
	ld E,(XIX+0x12)                               ; F9751E  8c 12 25
	and E,0x7f                                    ; F97521  cd cc 7f
	ld d, 0x7f:opc                                   ; F97524  24 7f
.LF97526:
	ld c, (0x218f:16)                            ; F97526  c1 8f 21 23
	call T_MidiOut_ParamChanged                   ; F9752A  1d 48 07 f4
	pop XDE                                       ; F9752E  5a
	pop XHL                                       ; F9752F  5b
	pop XIX                                       ; F97530  5c
	pop XIZ                                       ; F97531  5e
	ret                                           ; F97532  0e
; MidiOut_PostPartEffect1Send -- post EFFECT1 SEND (offset 5) of the current part through
; MidiOut_ParamChanged, from the part's own byte or its MMO: CHORUS DEPTH override
; Evidence: XIX = (0x218B), C = (0x218F), B = 5, D = 0x7F; bit 3 of (XIX+0x15) set: E = (XIX+0x05) & 0x7F,
; clear: E = (XIX+0x13) & 0x7F. Offset 5 is EFFECT1 SEND and 0x13 MMO: CHORUS DEPTH (tbl:partparams);
; bit 3 is CHORUS DEPTH in sec-blocks.tex. Caller: Combination_Recall's .LF98627 if (XIX+0x13) < 0x80.
MidiOut_PostPartEffect1Send:   ; entry: reachable-run entry
	push XIZ                                             ; F97533  3e
	push XIX                                             ; F97534  3c
	push XHL                                             ; F97535  3b
	push XDE                                             ; F97536  3a
	ld xix, (0x218b:16)                                 ; F97537  e1 8b 21 24
	bit 3,(XIX+0x15)                                     ; F9753B  bc 15 cb
	jr z, .LF9754C                                       ; F9753E  66 0c
	ld b, 0x05:opc                                          ; F97540  22 05
	ld E,(XIX+0x05)                                      ; F97542  8c 05 25
	and E,0x7f                                           ; F97545  cd cc 7f
	ld d, 0x7f:opc                                          ; F97548  24 7f
	jr .LF97556                                          ; F9754A  68 0a
.LF9754C:
	ld b, 0x05:opc                                          ; F9754C  22 05
	ld E,(XIX+0x13)                                      ; F9754E  8c 13 25
	and E,0x7f                                           ; F97551  cd cc 7f
	ld d, 0x7f:opc                                          ; F97554  24 7f
.LF97556:
	ld c, (0x218f:16)                                   ; F97556  c1 8f 21 23
	call T_MidiOut_ParamChanged                          ; F9755A  1d 48 07 f4
	pop XDE                                              ; F9755E  5a
	pop XHL                                              ; F9755F  5b
	pop XIX                                              ; F97560  5c
	pop XIZ                                              ; F97561  5e
	ret                                                  ; F97562  0e
; MidiOut_PostPartReverbSend -- post REVERB SEND (offset 7) of the current part through
; MidiOut_ParamChanged, from the part's own byte or its MMO: REVERB DEPTH override
; Evidence: XIX = (0x218B), C = (0x218F), B = 7, D = 0x7F; bit 4 of (XIX+0x15) set: E = (XIX+0x07) & 0x7F,
; clear: E = (XIX+0x14) & 0x7F (offset 7 REVERB SEND, 0x14 MMO: REVERB DEPTH, tbl:partparams).
; Caller: Combination_Recall's .LF98627, when (XIX+0x14) < 0x80.
MidiOut_PostPartReverbSend:
	push XIZ                                             ; F97563  3e
	push XIX                                             ; F97564  3c
	push XHL                                             ; F97565  3b
	push XDE                                             ; F97566  3a
	ld xix, (0x218b:16)                                 ; F97567  e1 8b 21 24
	bit 4,(XIX+0x15)                                     ; F9756B  bc 15 cc
	jr z, .LF9757C                                       ; F9756E  66 0c
	ld b, 0x07:opc                                          ; F97570  22 07
	ld E,(XIX+0x07)                                      ; F97572  8c 07 25
	and E,0x7f                                           ; F97575  cd cc 7f
	ld d, 0x7f:opc                                          ; F97578  24 7f
	jr .LF97586                                          ; F9757A  68 0a
.LF9757C:
	ld b, 0x07:opc                                          ; F9757C  22 07
	ld E,(XIX+0x14)                                      ; F9757E  8c 14 25
	and E,0x7f                                           ; F97581  cd cc 7f
	ld d, 0x7f:opc                                          ; F97584  24 7f
.LF97586:
	ld c, (0x218f:16)                                   ; F97586  c1 8f 21 23
	call T_MidiOut_ParamChanged                          ; F9758A  1d 48 07 f4
	pop XDE                                              ; F9758E  5a
	pop XHL                                              ; F9758F  5b
	pop XIX                                              ; F97590  5c
	pop XIZ                                              ; F97591  5e
	ret                                                  ; F97592  0e
; Combination_RecallOnSelect -- pass-A event handler for record class 0x98: when the queued change is field
; 1 of record 0x98 -- (0x7F03), the combination number Combination_Recall loads -- run Combination_Recall
; Evidence: UiListA_Class98[0] holds T_Combination_RecallOnSelect = `jp 0xF97593`; `cp (0x20B8),0x01 / jr nz` (0xF97593), and
; UiEventList_Run puts the record's byte +1 (the field offset) in (0x20B8). Record 0x98's header is at
; 0x7F00 (RamInitTable_F96CA6 entry 74), so its field 1 is 0x7F03.
Combination_RecallOnSelect:   ; entry: prom_b routine directory
	cp	(UiEvent_Byte1:16), 0x01                            ; F97593  c1 b8 20 3f 01
	jr nz, .LF9759D                                      ; F97598  6e 03
	calr .LF9759E                                        ; F9759A  1e 01 00
.LF9759D:
	ret                                                  ; F9759D  0e
.LF9759E:
; Combination_Recall -- load combination (0x7F03) from CPU 2 into the parameter image, copy back what the
; hold flags keep, then queue and post the changes (prom_b T_Combination_Recall, caller 0xFB5342)
; Evidence: ParamImage_SnapshotCombination; Combination_ReadFromCpu2(index (0x7F03), source (0x7F04));
; .LF97FC2/.LF982F6 copy effect/part fields back from 0x608000 when the low/high nibble of (0x7EE4) is 0, and
; .LF9766F per bits 0-4 of (0x7F07); .LF975C8 complements the snapshot's PROGRAM CHANGE byte of parts 1-8 so
; .LF9898E (QueueDiffCombination) always queues them; .LF98627 runs the six MidiOut_PostPart* for parts 1-8.
Combination_Recall:   ; entry: prom_b routine directory
	pushw hl                                             ; F9759E  2b
	call ParamImage_SnapshotCombination                                        ; F9759F  1d 25 74 f9
	ld h, (0x7f03:16)                                   ; F975A3  c1 03 7f 26
	ld c, (0x7f04:16)                                   ; F975A7  c1 04 7f 23
	pushw bc                                             ; F975AB  29
	push 0x00                                            ; F975AC  09 00
	push H                                               ; F975AE  ce 04
	calr .LF98927                                        ; F975B0  1e 74 13
	calr .LF97FC2                                        ; F975B3  1e 0c 0a
	calr .LF9766F                                        ; F975B6  1e b6 00
	calr .LF982F6                                        ; F975B9  1e 3a 0d
	calr .LF975C8                                        ; F975BC  1e 09 00
	calr .LF9898E                                        ; F975BF  1e cc 13
	calr .LF98627                                        ; F975C2  1e 62 10
	pop XBC                                              ; F975C5  59
	popw hl                                              ; F975C6  4b
	ret                                                  ; F975C7  0e
.LF975C8:
	pushw hl                                             ; F975C8  2b
	pushw de                                             ; F975C9  2a
	push XIX                                             ; F975CA  3c
	lda xix, (0x608000:24)                               ; F975CB  f2 00 80 60 34
	ld c, (0x76a2:16)                                   ; F975D0  c1 a2 76 23
	cpl C                                                ; F975D4  cb 06
	ld H,C                                               ; F975D6  cb 8e
	ldw de, Combination_Current                                       ; F975D8  32 20 76
	ldw bc, 0x76a2                                       ; F975DB  31 a2 76
	sub BC,DE                                            ; F975DE  da a1
	exts XBC                                             ; F975E0  e9 13
	add XBC,XIX                                          ; F975E2  ec 81
	ld (XBC),H                                           ; F975E4  b1 46
	ld c, (0x76e2:16)                                   ; F975E6  c1 e2 76 23
	cpl C                                                ; F975EA  cb 06
	ld H,C                                               ; F975EC  cb 8e
	ldw bc, 0x76e2                                       ; F975EE  31 e2 76
	sub BC,DE                                            ; F975F1  da a1
	exts XBC                                             ; F975F3  e9 13
	add XBC,XIX                                          ; F975F5  ec 81
	ld (XBC),H                                           ; F975F7  b1 46
	ld c, (0x7722:16)                                   ; F975F9  c1 22 77 23
	cpl C                                                ; F975FD  cb 06
	ld H,C                                               ; F975FF  cb 8e
	ldw bc, 0x7722                                       ; F97601  31 22 77
	sub BC,DE                                            ; F97604  da a1
	exts XBC                                             ; F97606  e9 13
	add XBC,XIX                                          ; F97608  ec 81
	ld (XBC),H                                           ; F9760A  b1 46
	ld c, (0x7762:16)                                   ; F9760C  c1 62 77 23
	cpl C                                                ; F97610  cb 06
	ld H,C                                               ; F97612  cb 8e
	ldw bc, 0x7762                                       ; F97614  31 62 77
	sub BC,DE                                            ; F97617  da a1
	exts XBC                                             ; F97619  e9 13
	add XBC,XIX                                          ; F9761B  ec 81
	ld (XBC),H                                           ; F9761D  b1 46
	ld c, (0x77a2:16)                                   ; F9761F  c1 a2 77 23
	cpl C                                                ; F97623  cb 06
	ld H,C                                               ; F97625  cb 8e
	ldw bc, 0x77a2                                       ; F97627  31 a2 77
	sub BC,DE                                            ; F9762A  da a1
	exts XBC                                             ; F9762C  e9 13
	add XBC,XIX                                          ; F9762E  ec 81
	ld (XBC),H                                           ; F97630  b1 46
	ld c, (0x77e2:16)                                   ; F97632  c1 e2 77 23
	cpl C                                                ; F97636  cb 06
	ld H,C                                               ; F97638  cb 8e
	ldw bc, 0x77e2                                       ; F9763A  31 e2 77
	sub BC,DE                                            ; F9763D  da a1
	exts XBC                                             ; F9763F  e9 13
	add XBC,XIX                                          ; F97641  ec 81
	ld (XBC),H                                           ; F97643  b1 46
	ld c, (0x7822:16)                                   ; F97645  c1 22 78 23
	cpl C                                                ; F97649  cb 06
	ld H,C                                               ; F9764B  cb 8e
	ldw bc, 0x7822                                       ; F9764D  31 22 78
	sub BC,DE                                            ; F97650  da a1
	exts XBC                                             ; F97652  e9 13
	add XBC,XIX                                          ; F97654  ec 81
	ld (XBC),H                                           ; F97656  b1 46
	ld c, (0x7862:16)                                   ; F97658  c1 62 78 23
	cpl C                                                ; F9765C  cb 06
	ld H,C                                               ; F9765E  cb 8e
	ldw bc, 0x7862                                       ; F97660  31 62 78
	sub BC,DE                                            ; F97663  da a1
	exts XBC                                             ; F97665  e9 13
	add XBC,XIX                                          ; F97667  ec 81
	ld (XBC),H                                           ; F97669  b1 46
	pop XIX                                              ; F9766B  5c
	popw de                                              ; F9766C  4a
	popw hl                                              ; F9766D  4b
	ret                                                  ; F9766E  0e
.LF9766F:
	link XIZ,0xfff8                                      ; F9766F  ee 0c f8 ff
	pushw hl                                             ; F97673  2b
	push XDE                                             ; F97674  3a
	push XIX                                             ; F97675  3c
	ld c, (0x7f07:16)                                   ; F97676  c1 07 7f 23
	and C,0x04                                           ; F9767A  cb cc 04
	jr z, .LF97695                                       ; F9767D  66 16
	ldw hl, Combination_Current                                       ; F9767F  33 20 76
	ldw bc, 0x78b2                                       ; F97682  31 b2 78
	sub BC,HL                                            ; F97685  db a1
	exts XBC                                             ; F97687  e9 13
	add XBC,0x00608000                                   ; F97689  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F9768F  81 21
	ld (0x78b2:16), a                                   ; F97691  f1 b2 78 41
.LF97695:
	ld c, (0x7f07:16)                                   ; F97695  c1 07 7f 23
	and C,0x08                                           ; F97699  cb cc 08
	jr z, .LF976F6                                       ; F9769C  66 58
	ldw hl, 0x78b2                                       ; F9769E  33 b2 78
	ld BC,HL                                             ; F976A1  db 89
	inc 1,BC                                             ; F976A3  d9 61
	ld DE,BC                                             ; F976A5  d9 8a
	ldw ix, Combination_Current                                       ; F976A7  34 20 76
	sub BC,IX                                            ; F976AA  dc a1
	exts XBC                                             ; F976AC  e9 13
	add XBC,0x00608000                                   ; F976AE  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F976B4  81 21
	ld (0x78b3:16), a                                   ; F976B6  f1 b3 78 41
	ld BC,HL                                             ; F976BA  db 89
	inc 2,BC                                             ; F976BC  d9 62
	sub BC,IX                                            ; F976BE  dc a1
	exts XBC                                             ; F976C0  e9 13
	add XBC,0x00608000                                   ; F976C2  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F976C8  81 21
	ld (0x78b4:16), a                                   ; F976CA  f1 b4 78 41
	ld BC,HL                                             ; F976CE  db 89
	inc 3,BC                                             ; F976D0  d9 63
	sub BC,IX                                            ; F976D2  dc a1
	exts XBC                                             ; F976D4  e9 13
	add XBC,0x00608000                                   ; F976D6  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F976DC  81 21
	ld (0x78b5:16), a                                   ; F976DE  f1 b5 78 41
	ld BC,HL                                             ; F976E2  db 89
	inc 4,BC                                             ; F976E4  d9 64
	sub BC,IX                                            ; F976E6  dc a1
	exts XBC                                             ; F976E8  e9 13
	add XBC,0x00608000                                   ; F976EA  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F976F0  81 21
	ld (0x78b6:16), a                                   ; F976F2  f1 b6 78 41
.LF976F6:
	ld c, (0x7f07:16)                                   ; F976F6  c1 07 7f 23
	and C,0x10                                           ; F976FA  cb cc 10
	jr z, .LF97734                                       ; F976FD  66 35
	ldw hl, 0x00                                         ; F976FF  33 00 00
	ldw ix, 0x78a2                                       ; F97702  34 a2 78
	ldw bc, 0x78b0                                       ; F97705  31 b0 78
	ld DE,BC                                             ; F97708  d9 8a
	sub DE,IX                                            ; F9770A  dc a2
.LF9770C:
	cp HL,DE                                             ; F9770C  da f3
	jr ugt, .LF97734                                     ; F9770E  6b 24
	ld IX,HL                                             ; F97710  db 8c
	ldw bc, 0x78a2                                       ; F97712  31 a2 78
	add BC,IX                                            ; F97715  dc 81
	ld (xiz-4), bc                                       ; F97717  be fc 51
	ldw wa, Combination_Current                                       ; F9771A  30 20 76
	sub BC,WA                                            ; F9771D  d8 a1
	exts XBC                                             ; F9771F  e9 13
	add XBC,0x00608000                                   ; F97721  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97727  81 21
	extz XIX                                             ; F97729  ec 12
	ld (XIX+0x78a2),A                                    ; F9772B  f3 f1 a2 78 41
	inc 1,HL                                             ; F97730  db 61
	jr .LF9770C                                          ; F97732  68 d8
.LF97734:
	ld c, (0x7f07:16)                                   ; F97734  c1 07 7f 23
	and C,0x01                                           ; F97738  cb cc 01
	jrl z, .LF97A1E                                      ; F9773B  76 e0 02
	ldw hl, 0x76c2                                       ; F9773E  33 c2 76
	ld BC,HL                                             ; F97741  db 89
	inc 7,BC                                             ; F97743  d9 67
	ld DE,BC                                             ; F97745  d9 8a
	ldw ix, Combination_Current                                       ; F97747  34 20 76
	sub BC,IX                                            ; F9774A  dc a1
	exts XBC                                             ; F9774C  e9 13
	add XBC,0x00608000                                   ; F9774E  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97754  81 21
	ld (0x76c9:16), a                                   ; F97756  f1 c9 76 41
	ld BC,HL                                             ; F9775A  db 89
	inc 8,BC                                             ; F9775C  d9 60
	sub BC,IX                                            ; F9775E  dc a1
	exts XBC                                             ; F97760  e9 13
	add XBC,0x00608000                                   ; F97762  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97768  81 21
	ld (0x76ca:16), a                                   ; F9776A  f1 ca 76 41
	ldw de, 0x09                                         ; F9776E  32 09 00
	ld BC,HL                                             ; F97771  db 89
	add BC,DE                                            ; F97773  da 81
	sub BC,IX                                            ; F97775  dc a1
	exts XBC                                             ; F97777  e9 13
	add XBC,0x00608000                                   ; F97779  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F9777F  81 21
	extz XDE                                             ; F97781  ea 12
	ld (XDE+0x76c2),A                                    ; F97783  f3 e9 c2 76 41
	ldw	(xiz-4), 0x000a                              ; F97788  be fc 02 0a 00
	ld BC,HL                                             ; F9778D  db 89
	add	bc, (xiz-4)                                  ; F9778F  9e fc 81
	sub BC,IX                                            ; F97792  dc a1
	exts XBC                                             ; F97794  e9 13
	add XBC,0x00608000                                   ; F97796  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F9779C  81 21
	ld bc, (xiz-4)                                       ; F9779E  9e fc 21
	extz XBC                                             ; F977A1  e9 12
	ld (XBC+0x76c2),A                                    ; F977A3  f3 e5 c2 76 41
	ldw hl, 0x7702                                       ; F977A8  33 02 77
	ld WA,HL                                             ; F977AB  db 88
	inc 7,WA                                             ; F977AD  d8 67
	sub WA,IX                                            ; F977AF  dc a0
	exts XWA                                             ; F977B1  e8 13
	add XWA,0x00608000                                   ; F977B3  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F977B9  80 20
	ld (0x7709:16), w                                   ; F977BB  f1 09 77 40
	ld WA,HL                                             ; F977BF  db 88
	inc 8,WA                                             ; F977C1  d8 60
	sub WA,IX                                            ; F977C3  dc a0
	exts XWA                                             ; F977C5  e8 13
	add XWA,0x00608000                                   ; F977C7  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F977CD  80 20
	ld (0x770a:16), w                                   ; F977CF  f1 0a 77 40
	ld WA,HL                                             ; F977D3  db 88
	add WA,DE                                            ; F977D5  da 80
	sub WA,IX                                            ; F977D7  dc a0
	exts XWA                                             ; F977D9  e8 13
	add XWA,0x00608000                                   ; F977DB  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F977E1  80 20
	extz XDE                                             ; F977E3  ea 12
	ld (XDE+0x7702),W                                    ; F977E5  f3 e9 02 77 40
	add BC,HL                                            ; F977EA  db 81
	sub BC,IX                                            ; F977EC  dc a1
	exts XBC                                             ; F977EE  e9 13
	add XBC,0x00608000                                   ; F977F0  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F977F6  81 21
	ld bc, (xiz-4)                                       ; F977F8  9e fc 21
	extz XBC                                             ; F977FB  e9 12
	ld (XBC+0x7702),A                                    ; F977FD  f3 e5 02 77 41
	ldw hl, 0x7742                                       ; F97802  33 42 77
	ld WA,HL                                             ; F97805  db 88
	inc 7,WA                                             ; F97807  d8 67
	sub WA,IX                                            ; F97809  dc a0
	exts XWA                                             ; F9780B  e8 13
	add XWA,0x00608000                                   ; F9780D  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F97813  80 20
	ld (0x7749:16), w                                   ; F97815  f1 49 77 40
	ld WA,HL                                             ; F97819  db 88
	inc 8,WA                                             ; F9781B  d8 60
	sub WA,IX                                            ; F9781D  dc a0
	exts XWA                                             ; F9781F  e8 13
	add XWA,0x00608000                                   ; F97821  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F97827  80 20
	ld (0x774a:16), w                                   ; F97829  f1 4a 77 40
	ld WA,HL                                             ; F9782D  db 88
	add WA,DE                                            ; F9782F  da 80
	sub WA,IX                                            ; F97831  dc a0
	exts XWA                                             ; F97833  e8 13
	add XWA,0x00608000                                   ; F97835  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F9783B  80 20
	extz XDE                                             ; F9783D  ea 12
	ld (XDE+0x7742),W                                    ; F9783F  f3 e9 42 77 40
	add BC,HL                                            ; F97844  db 81
	sub BC,IX                                            ; F97846  dc a1
	exts XBC                                             ; F97848  e9 13
	add XBC,0x00608000                                   ; F9784A  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97850  81 21
	ld bc, (xiz-4)                                       ; F97852  9e fc 21
	extz XBC                                             ; F97855  e9 12
	ld (XBC+0x7742),A                                    ; F97857  f3 e5 42 77 41
	ldw hl, 0x7782                                       ; F9785C  33 82 77
	ld WA,HL                                             ; F9785F  db 88
	inc 7,WA                                             ; F97861  d8 67
	sub WA,IX                                            ; F97863  dc a0
	exts XWA                                             ; F97865  e8 13
	add XWA,0x00608000                                   ; F97867  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F9786D  80 20
	ld (0x7789:16), w                                   ; F9786F  f1 89 77 40
	ld WA,HL                                             ; F97873  db 88
	inc 8,WA                                             ; F97875  d8 60
	sub WA,IX                                            ; F97877  dc a0
	exts XWA                                             ; F97879  e8 13
	add XWA,0x00608000                                   ; F9787B  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F97881  80 20
	ld (0x778a:16), w                                   ; F97883  f1 8a 77 40
	ld WA,HL                                             ; F97887  db 88
	add WA,DE                                            ; F97889  da 80
	sub WA,IX                                            ; F9788B  dc a0
	exts XWA                                             ; F9788D  e8 13
	add XWA,0x00608000                                   ; F9788F  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F97895  80 20
	extz XDE                                             ; F97897  ea 12
	ld (XDE+0x7782),W                                    ; F97899  f3 e9 82 77 40
	add BC,HL                                            ; F9789E  db 81
	sub BC,IX                                            ; F978A0  dc a1
	exts XBC                                             ; F978A2  e9 13
	add XBC,0x00608000                                   ; F978A4  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F978AA  81 21
	ld bc, (xiz-4)                                       ; F978AC  9e fc 21
	extz XBC                                             ; F978AF  e9 12
	ld (XBC+0x7782),A                                    ; F978B1  f3 e5 82 77 41
	ldw hl, 0x77c2                                       ; F978B6  33 c2 77
	ld WA,HL                                             ; F978B9  db 88
	inc 7,WA                                             ; F978BB  d8 67
	sub WA,IX                                            ; F978BD  dc a0
	exts XWA                                             ; F978BF  e8 13
	add XWA,0x00608000                                   ; F978C1  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F978C7  80 20
	ld (0x77c9:16), w                                   ; F978C9  f1 c9 77 40
	ld WA,HL                                             ; F978CD  db 88
	inc 8,WA                                             ; F978CF  d8 60
	sub WA,IX                                            ; F978D1  dc a0
	exts XWA                                             ; F978D3  e8 13
	add XWA,0x00608000                                   ; F978D5  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F978DB  80 20
	ld (0x77ca:16), w                                   ; F978DD  f1 ca 77 40
	ld WA,HL                                             ; F978E1  db 88
	add WA,DE                                            ; F978E3  da 80
	sub WA,IX                                            ; F978E5  dc a0
	exts XWA                                             ; F978E7  e8 13
	add XWA,0x00608000                                   ; F978E9  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F978EF  80 20
	extz XDE                                             ; F978F1  ea 12
	ld (XDE+0x77c2),W                                    ; F978F3  f3 e9 c2 77 40
	add BC,HL                                            ; F978F8  db 81
	sub BC,IX                                            ; F978FA  dc a1
	exts XBC                                             ; F978FC  e9 13
	add XBC,0x00608000                                   ; F978FE  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97904  81 21
	ld bc, (xiz-4)                                       ; F97906  9e fc 21
	extz XBC                                             ; F97909  e9 12
	ld (XBC+0x77c2),A                                    ; F9790B  f3 e5 c2 77 41
	ldw hl, 0x7802                                       ; F97910  33 02 78
	ld WA,HL                                             ; F97913  db 88
	inc 7,WA                                             ; F97915  d8 67
	sub WA,IX                                            ; F97917  dc a0
	exts XWA                                             ; F97919  e8 13
	add XWA,0x00608000                                   ; F9791B  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F97921  80 20
	ld (0x7809:16), w                                   ; F97923  f1 09 78 40
	ld WA,HL                                             ; F97927  db 88
	inc 8,WA                                             ; F97929  d8 60
	sub WA,IX                                            ; F9792B  dc a0
	exts XWA                                             ; F9792D  e8 13
	add XWA,0x00608000                                   ; F9792F  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F97935  80 20
	ld (0x780a:16), w                                   ; F97937  f1 0a 78 40
	ld WA,HL                                             ; F9793B  db 88
	add WA,DE                                            ; F9793D  da 80
	sub WA,IX                                            ; F9793F  dc a0
	exts XWA                                             ; F97941  e8 13
	add XWA,0x00608000                                   ; F97943  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F97949  80 20
	extz XDE                                             ; F9794B  ea 12
	ld (XDE+0x7802),W                                    ; F9794D  f3 e9 02 78 40
	add BC,HL                                            ; F97952  db 81
	sub BC,IX                                            ; F97954  dc a1
	exts XBC                                             ; F97956  e9 13
	add XBC,0x00608000                                   ; F97958  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F9795E  81 21
	ld bc, (xiz-4)                                       ; F97960  9e fc 21
	extz XBC                                             ; F97963  e9 12
	ld (XBC+0x7802),A                                    ; F97965  f3 e5 02 78 41
	ldw hl, 0x7842                                       ; F9796A  33 42 78
	ld WA,HL                                             ; F9796D  db 88
	inc 7,WA                                             ; F9796F  d8 67
	sub WA,IX                                            ; F97971  dc a0
	exts XWA                                             ; F97973  e8 13
	add XWA,0x00608000                                   ; F97975  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F9797B  80 20
	ld (0x7849:16), w                                   ; F9797D  f1 49 78 40
	ld WA,HL                                             ; F97981  db 88
	inc 8,WA                                             ; F97983  d8 60
	sub WA,IX                                            ; F97985  dc a0
	exts XWA                                             ; F97987  e8 13
	add XWA,0x00608000                                   ; F97989  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F9798F  80 20
	ld (0x784a:16), w                                   ; F97991  f1 4a 78 40
	ld WA,HL                                             ; F97995  db 88
	add WA,DE                                            ; F97997  da 80
	sub WA,IX                                            ; F97999  dc a0
	exts XWA                                             ; F9799B  e8 13
	add XWA,0x00608000                                   ; F9799D  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F979A3  80 20
	extz XDE                                             ; F979A5  ea 12
	ld (XDE+0x7842),W                                    ; F979A7  f3 e9 42 78 40
	add BC,HL                                            ; F979AC  db 81
	sub BC,IX                                            ; F979AE  dc a1
	exts XBC                                             ; F979B0  e9 13
	add XBC,0x00608000                                   ; F979B2  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F979B8  81 21
	ld bc, (xiz-4)                                       ; F979BA  9e fc 21
	extz XBC                                             ; F979BD  e9 12
	ld (XBC+0x7842),A                                    ; F979BF  f3 e5 42 78 41
	ldw hl, 0x7882                                       ; F979C4  33 82 78
	ld WA,HL                                             ; F979C7  db 88
	inc 7,WA                                             ; F979C9  d8 67
	sub WA,IX                                            ; F979CB  dc a0
	exts XWA                                             ; F979CD  e8 13
	add XWA,0x00608000                                   ; F979CF  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F979D5  80 20
	ld (0x7889:16), w                                   ; F979D7  f1 89 78 40
	ld WA,HL                                             ; F979DB  db 88
	inc 8,WA                                             ; F979DD  d8 60
	sub WA,IX                                            ; F979DF  dc a0
	exts XWA                                             ; F979E1  e8 13
	add XWA,0x00608000                                   ; F979E3  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F979E9  80 20
	ld (0x788a:16), w                                   ; F979EB  f1 8a 78 40
	ld WA,HL                                             ; F979EF  db 88
	add WA,DE                                            ; F979F1  da 80
	sub WA,IX                                            ; F979F3  dc a0
	exts XWA                                             ; F979F5  e8 13
	add XWA,0x00608000                                   ; F979F7  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F979FD  80 20
	extz XDE                                             ; F979FF  ea 12
	ld (XDE+0x7882),W                                    ; F97A01  f3 e9 82 78 40
	add BC,HL                                            ; F97A06  db 81
	sub BC,IX                                            ; F97A08  dc a1
	exts XBC                                             ; F97A0A  e9 13
	add XBC,0x00608000                                   ; F97A0C  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97A12  81 21
	ld bc, (xiz-4)                                       ; F97A14  9e fc 21
	extz XBC                                             ; F97A17  e9 12
	ld (XBC+0x7882),A                                    ; F97A19  f3 e5 82 78 41
.LF97A1E:
	ld c, (0x7f07:16)                                   ; F97A1E  c1 07 7f 23
	and C,0x02                                           ; F97A22  cb cc 02
	jrl z, .LF97FBC                                      ; F97A25  76 94 05
	ldw hl, 0x00                                         ; F97A28  33 00 00
	ldw de, 0x76a2                                       ; F97A2B  32 a2 76
	ld BC,DE                                             ; F97A2E  da 89
	add BC,0x000d                                        ; F97A30  d9 c8 0d 00
	ld (xiz-4), bc                                       ; F97A34  be fc 51
	ld WA,DE                                             ; F97A37  da 88
	add WA,0x0015                                        ; F97A39  d8 c8 15 00
	ld (xiz-6), wa                                       ; F97A3D  be fa 50
	ld (xiz-8), bc                                       ; F97A40  be f8 51
	sub WA,BC                                            ; F97A43  d9 a0
	ld (xiz-2), wa                                       ; F97A45  be fe 50
	ldw ix, 0x0d                                         ; F97A48  34 0d 00
.LF97A4B:
	cp	hl, (xiz-2)                                  ; F97A4B  9e fe f3
	jr ugt, .LF97A7C                                     ; F97A4E  6b 2c
	ld (xiz-4), ix                                       ; F97A50  be fc 54
	ld BC,DE                                             ; F97A53  da 89
	add	bc, (xiz-4)                                  ; F97A55  9e fc 81
	ld (xiz-6), bc                                       ; F97A58  be fa 51
	ldw wa, Combination_Current                                       ; F97A5B  30 20 76
	sub BC,WA                                            ; F97A5E  d8 a1
	exts XBC                                             ; F97A60  e9 13
	add XBC,0x00608000                                   ; F97A62  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97A68  81 21
	ld bc, (xiz-4)                                       ; F97A6A  9e fc 21
	extz XBC                                             ; F97A6D  e9 12
	ld (XBC+0x76a2),A                                    ; F97A6F  f3 e5 a2 76 41
	ld IX,BC                                             ; F97A74  d9 8c
	inc 1,IX                                             ; F97A76  dc 61
	inc 1,HL                                             ; F97A78  db 61
	jr .LF97A4B                                          ; F97A7A  68 cf
.LF97A7C:
	ldw hl, 0x00                                         ; F97A7C  33 00 00
	ldw de, 0x76c2                                       ; F97A7F  32 c2 76
	ld BC,DE                                             ; F97A82  da 89
	add BC,0x000f                                        ; F97A84  d9 c8 0f 00
	ld (xiz-4), bc                                       ; F97A88  be fc 51
	ld WA,DE                                             ; F97A8B  da 88
	add WA,0x0018                                        ; F97A8D  d8 c8 18 00
	ld (xiz-6), wa                                       ; F97A91  be fa 50
	ld (xiz-8), bc                                       ; F97A94  be f8 51
	sub WA,BC                                            ; F97A97  d9 a0
	ld (xiz-2), wa                                       ; F97A99  be fe 50
	ldw ix, 0x0f                                         ; F97A9C  34 0f 00
.LF97A9F:
	cp	hl, (xiz-2)                                  ; F97A9F  9e fe f3
	jr ugt, .LF97AD0                                     ; F97AA2  6b 2c
	ld (xiz-4), ix                                       ; F97AA4  be fc 54
	ld BC,DE                                             ; F97AA7  da 89
	add	bc, (xiz-4)                                  ; F97AA9  9e fc 81
	ld (xiz-6), bc                                       ; F97AAC  be fa 51
	ldw wa, Combination_Current                                       ; F97AAF  30 20 76
	sub BC,WA                                            ; F97AB2  d8 a1
	exts XBC                                             ; F97AB4  e9 13
	add XBC,0x00608000                                   ; F97AB6  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97ABC  81 21
	ld bc, (xiz-4)                                       ; F97ABE  9e fc 21
	extz XBC                                             ; F97AC1  e9 12
	ld (XBC+0x76c2),A                                    ; F97AC3  f3 e5 c2 76 41
	ld IX,BC                                             ; F97AC8  d9 8c
	inc 1,IX                                             ; F97ACA  dc 61
	inc 1,HL                                             ; F97ACC  db 61
	jr .LF97A9F                                          ; F97ACE  68 cf
.LF97AD0:
	ldw hl, 0x00                                         ; F97AD0  33 00 00
	ldw de, 0x76e2                                       ; F97AD3  32 e2 76
	ld BC,DE                                             ; F97AD6  da 89
	add BC,0x000d                                        ; F97AD8  d9 c8 0d 00
	ld (xiz-4), bc                                       ; F97ADC  be fc 51
	ld WA,DE                                             ; F97ADF  da 88
	add WA,0x0015                                        ; F97AE1  d8 c8 15 00
	ld (xiz-6), wa                                       ; F97AE5  be fa 50
	ld (xiz-8), bc                                       ; F97AE8  be f8 51
	sub WA,BC                                            ; F97AEB  d9 a0
	ld (xiz-2), wa                                       ; F97AED  be fe 50
	ldw ix, 0x0d                                         ; F97AF0  34 0d 00
.LF97AF3:
	cp	hl, (xiz-2)                                  ; F97AF3  9e fe f3
	jr ugt, .LF97B24                                     ; F97AF6  6b 2c
	ld (xiz-4), ix                                       ; F97AF8  be fc 54
	ld BC,DE                                             ; F97AFB  da 89
	add	bc, (xiz-4)                                  ; F97AFD  9e fc 81
	ld (xiz-6), bc                                       ; F97B00  be fa 51
	ldw wa, Combination_Current                                       ; F97B03  30 20 76
	sub BC,WA                                            ; F97B06  d8 a1
	exts XBC                                             ; F97B08  e9 13
	add XBC,0x00608000                                   ; F97B0A  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97B10  81 21
	ld bc, (xiz-4)                                       ; F97B12  9e fc 21
	extz XBC                                             ; F97B15  e9 12
	ld (XBC+0x76e2),A                                    ; F97B17  f3 e5 e2 76 41
	ld IX,BC                                             ; F97B1C  d9 8c
	inc 1,IX                                             ; F97B1E  dc 61
	inc 1,HL                                             ; F97B20  db 61
	jr .LF97AF3                                          ; F97B22  68 cf
.LF97B24:
	ldw hl, 0x00                                         ; F97B24  33 00 00
	ldw de, 0x7702                                       ; F97B27  32 02 77
	ld BC,DE                                             ; F97B2A  da 89
	add BC,0x000f                                        ; F97B2C  d9 c8 0f 00
	ld (xiz-4), bc                                       ; F97B30  be fc 51
	ld WA,DE                                             ; F97B33  da 88
	add WA,0x0018                                        ; F97B35  d8 c8 18 00
	ld (xiz-6), wa                                       ; F97B39  be fa 50
	ld (xiz-8), bc                                       ; F97B3C  be f8 51
	sub WA,BC                                            ; F97B3F  d9 a0
	ld (xiz-2), wa                                       ; F97B41  be fe 50
	ldw ix, 0x0f                                         ; F97B44  34 0f 00
.LF97B47:
	cp	hl, (xiz-2)                                  ; F97B47  9e fe f3
	jr ugt, .LF97B78                                     ; F97B4A  6b 2c
	ld (xiz-4), ix                                       ; F97B4C  be fc 54
	ld BC,DE                                             ; F97B4F  da 89
	add	bc, (xiz-4)                                  ; F97B51  9e fc 81
	ld (xiz-6), bc                                       ; F97B54  be fa 51
	ldw wa, Combination_Current                                       ; F97B57  30 20 76
	sub BC,WA                                            ; F97B5A  d8 a1
	exts XBC                                             ; F97B5C  e9 13
	add XBC,0x00608000                                   ; F97B5E  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97B64  81 21
	ld bc, (xiz-4)                                       ; F97B66  9e fc 21
	extz XBC                                             ; F97B69  e9 12
	ld (XBC+0x7702),A                                    ; F97B6B  f3 e5 02 77 41
	ld IX,BC                                             ; F97B70  d9 8c
	inc 1,IX                                             ; F97B72  dc 61
	inc 1,HL                                             ; F97B74  db 61
	jr .LF97B47                                          ; F97B76  68 cf
.LF97B78:
	ldw hl, 0x00                                         ; F97B78  33 00 00
	ldw de, 0x7722                                       ; F97B7B  32 22 77
	ld BC,DE                                             ; F97B7E  da 89
	add BC,0x000d                                        ; F97B80  d9 c8 0d 00
	ld (xiz-4), bc                                       ; F97B84  be fc 51
	ld WA,DE                                             ; F97B87  da 88
	add WA,0x0015                                        ; F97B89  d8 c8 15 00
	ld (xiz-6), wa                                       ; F97B8D  be fa 50
	ld (xiz-8), bc                                       ; F97B90  be f8 51
	sub WA,BC                                            ; F97B93  d9 a0
	ld (xiz-2), wa                                       ; F97B95  be fe 50
	ldw ix, 0x0d                                         ; F97B98  34 0d 00
.LF97B9B:
	cp	hl, (xiz-2)                                  ; F97B9B  9e fe f3
	jr ugt, .LF97BCC                                     ; F97B9E  6b 2c
	ld (xiz-4), ix                                       ; F97BA0  be fc 54
	ld BC,DE                                             ; F97BA3  da 89
	add	bc, (xiz-4)                                  ; F97BA5  9e fc 81
	ld (xiz-6), bc                                       ; F97BA8  be fa 51
	ldw wa, Combination_Current                                       ; F97BAB  30 20 76
	sub BC,WA                                            ; F97BAE  d8 a1
	exts XBC                                             ; F97BB0  e9 13
	add XBC,0x00608000                                   ; F97BB2  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97BB8  81 21
	ld bc, (xiz-4)                                       ; F97BBA  9e fc 21
	extz XBC                                             ; F97BBD  e9 12
	ld (XBC+0x7722),A                                    ; F97BBF  f3 e5 22 77 41
	ld IX,BC                                             ; F97BC4  d9 8c
	inc 1,IX                                             ; F97BC6  dc 61
	inc 1,HL                                             ; F97BC8  db 61
	jr .LF97B9B                                          ; F97BCA  68 cf
.LF97BCC:
	ldw hl, 0x00                                         ; F97BCC  33 00 00
	ldw de, 0x7742                                       ; F97BCF  32 42 77
	ld BC,DE                                             ; F97BD2  da 89
	add BC,0x000f                                        ; F97BD4  d9 c8 0f 00
	ld (xiz-4), bc                                       ; F97BD8  be fc 51
	ld WA,DE                                             ; F97BDB  da 88
	add WA,0x0018                                        ; F97BDD  d8 c8 18 00
	ld (xiz-6), wa                                       ; F97BE1  be fa 50
	ld (xiz-8), bc                                       ; F97BE4  be f8 51
	sub WA,BC                                            ; F97BE7  d9 a0
	ld (xiz-2), wa                                       ; F97BE9  be fe 50
	ldw ix, 0x0f                                         ; F97BEC  34 0f 00
.LF97BEF:
	cp	hl, (xiz-2)                                  ; F97BEF  9e fe f3
	jr ugt, .LF97C20                                     ; F97BF2  6b 2c
	ld (xiz-4), ix                                       ; F97BF4  be fc 54
	ld BC,DE                                             ; F97BF7  da 89
	add	bc, (xiz-4)                                  ; F97BF9  9e fc 81
	ld (xiz-6), bc                                       ; F97BFC  be fa 51
	ldw wa, Combination_Current                                       ; F97BFF  30 20 76
	sub BC,WA                                            ; F97C02  d8 a1
	exts XBC                                             ; F97C04  e9 13
	add XBC,0x00608000                                   ; F97C06  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97C0C  81 21
	ld bc, (xiz-4)                                       ; F97C0E  9e fc 21
	extz XBC                                             ; F97C11  e9 12
	ld (XBC+0x7742),A                                    ; F97C13  f3 e5 42 77 41
	ld IX,BC                                             ; F97C18  d9 8c
	inc 1,IX                                             ; F97C1A  dc 61
	inc 1,HL                                             ; F97C1C  db 61
	jr .LF97BEF                                          ; F97C1E  68 cf
.LF97C20:
	ldw hl, 0x00                                         ; F97C20  33 00 00
	ldw de, 0x7762                                       ; F97C23  32 62 77
	ld BC,DE                                             ; F97C26  da 89
	add BC,0x000d                                        ; F97C28  d9 c8 0d 00
	ld (xiz-4), bc                                       ; F97C2C  be fc 51
	ld WA,DE                                             ; F97C2F  da 88
	add WA,0x0015                                        ; F97C31  d8 c8 15 00
	ld (xiz-6), wa                                       ; F97C35  be fa 50
	ld (xiz-8), bc                                       ; F97C38  be f8 51
	sub WA,BC                                            ; F97C3B  d9 a0
	ld (xiz-2), wa                                       ; F97C3D  be fe 50
	ldw ix, 0x0d                                         ; F97C40  34 0d 00
.LF97C43:
	cp	hl, (xiz-2)                                  ; F97C43  9e fe f3
	jr ugt, .LF97C74                                     ; F97C46  6b 2c
	ld (xiz-4), ix                                       ; F97C48  be fc 54
	ld BC,DE                                             ; F97C4B  da 89
	add	bc, (xiz-4)                                  ; F97C4D  9e fc 81
	ld (xiz-6), bc                                       ; F97C50  be fa 51
	ldw wa, Combination_Current                                       ; F97C53  30 20 76
	sub BC,WA                                            ; F97C56  d8 a1
	exts XBC                                             ; F97C58  e9 13
	add XBC,0x00608000                                   ; F97C5A  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97C60  81 21
	ld bc, (xiz-4)                                       ; F97C62  9e fc 21
	extz XBC                                             ; F97C65  e9 12
	ld (XBC+0x7762),A                                    ; F97C67  f3 e5 62 77 41
	ld IX,BC                                             ; F97C6C  d9 8c
	inc 1,IX                                             ; F97C6E  dc 61
	inc 1,HL                                             ; F97C70  db 61
	jr .LF97C43                                          ; F97C72  68 cf
.LF97C74:
	ldw hl, 0x00                                         ; F97C74  33 00 00
	ldw de, 0x7782                                       ; F97C77  32 82 77
	ld BC,DE                                             ; F97C7A  da 89
	add BC,0x000f                                        ; F97C7C  d9 c8 0f 00
	ld (xiz-4), bc                                       ; F97C80  be fc 51
	ld WA,DE                                             ; F97C83  da 88
	add WA,0x0018                                        ; F97C85  d8 c8 18 00
	ld (xiz-6), wa                                       ; F97C89  be fa 50
	ld (xiz-8), bc                                       ; F97C8C  be f8 51
	sub WA,BC                                            ; F97C8F  d9 a0
	ld (xiz-2), wa                                       ; F97C91  be fe 50
	ldw ix, 0x0f                                         ; F97C94  34 0f 00
.LF97C97:
	cp	hl, (xiz-2)                                  ; F97C97  9e fe f3
	jr ugt, .LF97CC8                                     ; F97C9A  6b 2c
	ld (xiz-4), ix                                       ; F97C9C  be fc 54
	ld BC,DE                                             ; F97C9F  da 89
	add	bc, (xiz-4)                                  ; F97CA1  9e fc 81
	ld (xiz-6), bc                                       ; F97CA4  be fa 51
	ldw wa, Combination_Current                                       ; F97CA7  30 20 76
	sub BC,WA                                            ; F97CAA  d8 a1
	exts XBC                                             ; F97CAC  e9 13
	add XBC,0x00608000                                   ; F97CAE  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97CB4  81 21
	ld bc, (xiz-4)                                       ; F97CB6  9e fc 21
	extz XBC                                             ; F97CB9  e9 12
	ld (XBC+0x7782),A                                    ; F97CBB  f3 e5 82 77 41
	ld IX,BC                                             ; F97CC0  d9 8c
	inc 1,IX                                             ; F97CC2  dc 61
	inc 1,HL                                             ; F97CC4  db 61
	jr .LF97C97                                          ; F97CC6  68 cf
.LF97CC8:
	ldw hl, 0x00                                         ; F97CC8  33 00 00
	ldw de, 0x77a2                                       ; F97CCB  32 a2 77
	ld BC,DE                                             ; F97CCE  da 89
	add BC,0x000d                                        ; F97CD0  d9 c8 0d 00
	ld (xiz-4), bc                                       ; F97CD4  be fc 51
	ld WA,DE                                             ; F97CD7  da 88
	add WA,0x0015                                        ; F97CD9  d8 c8 15 00
	ld (xiz-6), wa                                       ; F97CDD  be fa 50
	ld (xiz-8), bc                                       ; F97CE0  be f8 51
	sub WA,BC                                            ; F97CE3  d9 a0
	ld (xiz-2), wa                                       ; F97CE5  be fe 50
	ldw ix, 0x0d                                         ; F97CE8  34 0d 00
.LF97CEB:
	cp	hl, (xiz-2)                                  ; F97CEB  9e fe f3
	jr ugt, .LF97D1C                                     ; F97CEE  6b 2c
	ld (xiz-4), ix                                       ; F97CF0  be fc 54
	ld BC,DE                                             ; F97CF3  da 89
	add	bc, (xiz-4)                                  ; F97CF5  9e fc 81
	ld (xiz-6), bc                                       ; F97CF8  be fa 51
	ldw wa, Combination_Current                                       ; F97CFB  30 20 76
	sub BC,WA                                            ; F97CFE  d8 a1
	exts XBC                                             ; F97D00  e9 13
	add XBC,0x00608000                                   ; F97D02  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97D08  81 21
	ld bc, (xiz-4)                                       ; F97D0A  9e fc 21
	extz XBC                                             ; F97D0D  e9 12
	ld (XBC+0x77a2),A                                    ; F97D0F  f3 e5 a2 77 41
	ld IX,BC                                             ; F97D14  d9 8c
	inc 1,IX                                             ; F97D16  dc 61
	inc 1,HL                                             ; F97D18  db 61
	jr .LF97CEB                                          ; F97D1A  68 cf
.LF97D1C:
	ldw hl, 0x00                                         ; F97D1C  33 00 00
	ldw de, 0x77c2                                       ; F97D1F  32 c2 77
	ld BC,DE                                             ; F97D22  da 89
	add BC,0x000f                                        ; F97D24  d9 c8 0f 00
	ld (xiz-4), bc                                       ; F97D28  be fc 51
	ld WA,DE                                             ; F97D2B  da 88
	add WA,0x0018                                        ; F97D2D  d8 c8 18 00
	ld (xiz-6), wa                                       ; F97D31  be fa 50
	ld (xiz-8), bc                                       ; F97D34  be f8 51
	sub WA,BC                                            ; F97D37  d9 a0
	ld (xiz-2), wa                                       ; F97D39  be fe 50
	ldw ix, 0x0f                                         ; F97D3C  34 0f 00
.LF97D3F:
	cp	hl, (xiz-2)                                  ; F97D3F  9e fe f3
	jr ugt, .LF97D70                                     ; F97D42  6b 2c
	ld (xiz-4), ix                                       ; F97D44  be fc 54
	ld BC,DE                                             ; F97D47  da 89
	add	bc, (xiz-4)                                  ; F97D49  9e fc 81
	ld (xiz-6), bc                                       ; F97D4C  be fa 51
	ldw wa, Combination_Current                                       ; F97D4F  30 20 76
	sub BC,WA                                            ; F97D52  d8 a1
	exts XBC                                             ; F97D54  e9 13
	add XBC,0x00608000                                   ; F97D56  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97D5C  81 21
	ld bc, (xiz-4)                                       ; F97D5E  9e fc 21
	extz XBC                                             ; F97D61  e9 12
	ld (XBC+0x77c2),A                                    ; F97D63  f3 e5 c2 77 41
	ld IX,BC                                             ; F97D68  d9 8c
	inc 1,IX                                             ; F97D6A  dc 61
	inc 1,HL                                             ; F97D6C  db 61
	jr .LF97D3F                                          ; F97D6E  68 cf
.LF97D70:
	ldw hl, 0x00                                         ; F97D70  33 00 00
	ldw de, 0x77e2                                       ; F97D73  32 e2 77
	ld BC,DE                                             ; F97D76  da 89
	add BC,0x000d                                        ; F97D78  d9 c8 0d 00
	ld (xiz-4), bc                                       ; F97D7C  be fc 51
	ld WA,DE                                             ; F97D7F  da 88
	add WA,0x0015                                        ; F97D81  d8 c8 15 00
	ld (xiz-6), wa                                       ; F97D85  be fa 50
	ld (xiz-8), bc                                       ; F97D88  be f8 51
	sub WA,BC                                            ; F97D8B  d9 a0
	ld (xiz-2), wa                                       ; F97D8D  be fe 50
	ldw ix, 0x0d                                         ; F97D90  34 0d 00
.LF97D93:
	cp	hl, (xiz-2)                                  ; F97D93  9e fe f3
	jr ugt, .LF97DC4                                     ; F97D96  6b 2c
	ld (xiz-4), ix                                       ; F97D98  be fc 54
	ld BC,DE                                             ; F97D9B  da 89
	add	bc, (xiz-4)                                  ; F97D9D  9e fc 81
	ld (xiz-6), bc                                       ; F97DA0  be fa 51
	ldw wa, Combination_Current                                       ; F97DA3  30 20 76
	sub BC,WA                                            ; F97DA6  d8 a1
	exts XBC                                             ; F97DA8  e9 13
	add XBC,0x00608000                                   ; F97DAA  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97DB0  81 21
	ld bc, (xiz-4)                                       ; F97DB2  9e fc 21
	extz XBC                                             ; F97DB5  e9 12
	ld (XBC+0x77e2),A                                    ; F97DB7  f3 e5 e2 77 41
	ld IX,BC                                             ; F97DBC  d9 8c
	inc 1,IX                                             ; F97DBE  dc 61
	inc 1,HL                                             ; F97DC0  db 61
	jr .LF97D93                                          ; F97DC2  68 cf
.LF97DC4:
	ldw hl, 0x00                                         ; F97DC4  33 00 00
	ldw de, 0x7802                                       ; F97DC7  32 02 78
	ld BC,DE                                             ; F97DCA  da 89
	add BC,0x000f                                        ; F97DCC  d9 c8 0f 00
	ld (xiz-4), bc                                       ; F97DD0  be fc 51
	ld WA,DE                                             ; F97DD3  da 88
	add WA,0x0018                                        ; F97DD5  d8 c8 18 00
	ld (xiz-6), wa                                       ; F97DD9  be fa 50
	ld (xiz-8), bc                                       ; F97DDC  be f8 51
	sub WA,BC                                            ; F97DDF  d9 a0
	ld (xiz-2), wa                                       ; F97DE1  be fe 50
	ldw ix, 0x0f                                         ; F97DE4  34 0f 00
.LF97DE7:
	cp	hl, (xiz-2)                                  ; F97DE7  9e fe f3
	jr ugt, .LF97E18                                     ; F97DEA  6b 2c
	ld (xiz-4), ix                                       ; F97DEC  be fc 54
	ld BC,DE                                             ; F97DEF  da 89
	add	bc, (xiz-4)                                  ; F97DF1  9e fc 81
	ld (xiz-6), bc                                       ; F97DF4  be fa 51
	ldw wa, Combination_Current                                       ; F97DF7  30 20 76
	sub BC,WA                                            ; F97DFA  d8 a1
	exts XBC                                             ; F97DFC  e9 13
	add XBC,0x00608000                                   ; F97DFE  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97E04  81 21
	ld bc, (xiz-4)                                       ; F97E06  9e fc 21
	extz XBC                                             ; F97E09  e9 12
	ld (XBC+0x7802),A                                    ; F97E0B  f3 e5 02 78 41
	ld IX,BC                                             ; F97E10  d9 8c
	inc 1,IX                                             ; F97E12  dc 61
	inc 1,HL                                             ; F97E14  db 61
	jr .LF97DE7                                          ; F97E16  68 cf
.LF97E18:
	ldw hl, 0x00                                         ; F97E18  33 00 00
	ldw de, 0x7822                                       ; F97E1B  32 22 78
	ld BC,DE                                             ; F97E1E  da 89
	add BC,0x000d                                        ; F97E20  d9 c8 0d 00
	ld (xiz-4), bc                                       ; F97E24  be fc 51
	ld WA,DE                                             ; F97E27  da 88
	add WA,0x0015                                        ; F97E29  d8 c8 15 00
	ld (xiz-6), wa                                       ; F97E2D  be fa 50
	ld (xiz-8), bc                                       ; F97E30  be f8 51
	sub WA,BC                                            ; F97E33  d9 a0
	ld (xiz-2), wa                                       ; F97E35  be fe 50
	ldw ix, 0x0d                                         ; F97E38  34 0d 00
.LF97E3B:
	cp	hl, (xiz-2)                                  ; F97E3B  9e fe f3
	jr ugt, .LF97E6C                                     ; F97E3E  6b 2c
	ld (xiz-4), ix                                       ; F97E40  be fc 54
	ld BC,DE                                             ; F97E43  da 89
	add	bc, (xiz-4)                                  ; F97E45  9e fc 81
	ld (xiz-6), bc                                       ; F97E48  be fa 51
	ldw wa, Combination_Current                                       ; F97E4B  30 20 76
	sub BC,WA                                            ; F97E4E  d8 a1
	exts XBC                                             ; F97E50  e9 13
	add XBC,0x00608000                                   ; F97E52  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97E58  81 21
	ld bc, (xiz-4)                                       ; F97E5A  9e fc 21
	extz XBC                                             ; F97E5D  e9 12
	ld (XBC+0x7822),A                                    ; F97E5F  f3 e5 22 78 41
	ld IX,BC                                             ; F97E64  d9 8c
	inc 1,IX                                             ; F97E66  dc 61
	inc 1,HL                                             ; F97E68  db 61
	jr .LF97E3B                                          ; F97E6A  68 cf
.LF97E6C:
	ldw hl, 0x00                                         ; F97E6C  33 00 00
	ldw de, 0x7842                                       ; F97E6F  32 42 78
	ld BC,DE                                             ; F97E72  da 89
	add BC,0x000f                                        ; F97E74  d9 c8 0f 00
	ld (xiz-4), bc                                       ; F97E78  be fc 51
	ld WA,DE                                             ; F97E7B  da 88
	add WA,0x0018                                        ; F97E7D  d8 c8 18 00
	ld (xiz-6), wa                                       ; F97E81  be fa 50
	ld (xiz-8), bc                                       ; F97E84  be f8 51
	sub WA,BC                                            ; F97E87  d9 a0
	ld (xiz-2), wa                                       ; F97E89  be fe 50
	ldw ix, 0x0f                                         ; F97E8C  34 0f 00
.LF97E8F:
	cp	hl, (xiz-2)                                  ; F97E8F  9e fe f3
	jr ugt, .LF97EC0                                     ; F97E92  6b 2c
	ld (xiz-4), ix                                       ; F97E94  be fc 54
	ld BC,DE                                             ; F97E97  da 89
	add	bc, (xiz-4)                                  ; F97E99  9e fc 81
	ld (xiz-6), bc                                       ; F97E9C  be fa 51
	ldw wa, Combination_Current                                       ; F97E9F  30 20 76
	sub BC,WA                                            ; F97EA2  d8 a1
	exts XBC                                             ; F97EA4  e9 13
	add XBC,0x00608000                                   ; F97EA6  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97EAC  81 21
	ld bc, (xiz-4)                                       ; F97EAE  9e fc 21
	extz XBC                                             ; F97EB1  e9 12
	ld (XBC+0x7842),A                                    ; F97EB3  f3 e5 42 78 41
	ld IX,BC                                             ; F97EB8  d9 8c
	inc 1,IX                                             ; F97EBA  dc 61
	inc 1,HL                                             ; F97EBC  db 61
	jr .LF97E8F                                          ; F97EBE  68 cf
.LF97EC0:
	ldw hl, 0x00                                         ; F97EC0  33 00 00
	ldw de, 0x7862                                       ; F97EC3  32 62 78
	ld BC,DE                                             ; F97EC6  da 89
	add BC,0x000d                                        ; F97EC8  d9 c8 0d 00
	ld (xiz-4), bc                                       ; F97ECC  be fc 51
	ld WA,DE                                             ; F97ECF  da 88
	add WA,0x0015                                        ; F97ED1  d8 c8 15 00
	ld (xiz-6), wa                                       ; F97ED5  be fa 50
	ld (xiz-8), bc                                       ; F97ED8  be f8 51
	sub WA,BC                                            ; F97EDB  d9 a0
	ld (xiz-2), wa                                       ; F97EDD  be fe 50
	ldw ix, 0x0d                                         ; F97EE0  34 0d 00
.LF97EE3:
	cp	hl, (xiz-2)                                  ; F97EE3  9e fe f3
	jr ugt, .LF97F14                                     ; F97EE6  6b 2c
	ld (xiz-4), ix                                       ; F97EE8  be fc 54
	ld BC,DE                                             ; F97EEB  da 89
	add	bc, (xiz-4)                                  ; F97EED  9e fc 81
	ld (xiz-6), bc                                       ; F97EF0  be fa 51
	ldw wa, Combination_Current                                       ; F97EF3  30 20 76
	sub BC,WA                                            ; F97EF6  d8 a1
	exts XBC                                             ; F97EF8  e9 13
	add XBC,0x00608000                                   ; F97EFA  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97F00  81 21
	ld bc, (xiz-4)                                       ; F97F02  9e fc 21
	extz XBC                                             ; F97F05  e9 12
	ld (XBC+0x7862),A                                    ; F97F07  f3 e5 62 78 41
	ld IX,BC                                             ; F97F0C  d9 8c
	inc 1,IX                                             ; F97F0E  dc 61
	inc 1,HL                                             ; F97F10  db 61
	jr .LF97EE3                                          ; F97F12  68 cf
.LF97F14:
	ldw hl, 0x00                                         ; F97F14  33 00 00
	ldw de, 0x7882                                       ; F97F17  32 82 78
	ld BC,DE                                             ; F97F1A  da 89
	add BC,0x000f                                        ; F97F1C  d9 c8 0f 00
	ld (xiz-4), bc                                       ; F97F20  be fc 51
	ld WA,DE                                             ; F97F23  da 88
	add WA,0x0018                                        ; F97F25  d8 c8 18 00
	ld (xiz-6), wa                                       ; F97F29  be fa 50
	ld (xiz-8), bc                                       ; F97F2C  be f8 51
	sub WA,BC                                            ; F97F2F  d9 a0
	ld (xiz-2), wa                                       ; F97F31  be fe 50
	ldw ix, 0x0f                                         ; F97F34  34 0f 00
.LF97F37:
	cp	hl, (xiz-2)                                  ; F97F37  9e fe f3
	jr ugt, .LF97F68                                     ; F97F3A  6b 2c
	ld (xiz-4), ix                                       ; F97F3C  be fc 54
	ld BC,DE                                             ; F97F3F  da 89
	add	bc, (xiz-4)                                  ; F97F41  9e fc 81
	ld (xiz-6), bc                                       ; F97F44  be fa 51
	ldw wa, Combination_Current                                       ; F97F47  30 20 76
	sub BC,WA                                            ; F97F4A  d8 a1
	exts XBC                                             ; F97F4C  e9 13
	add XBC,0x00608000                                   ; F97F4E  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97F54  81 21
	ld bc, (xiz-4)                                       ; F97F56  9e fc 21
	extz XBC                                             ; F97F59  e9 12
	ld (XBC+0x7882),A                                    ; F97F5B  f3 e5 82 78 41
	ld IX,BC                                             ; F97F60  d9 8c
	inc 1,IX                                             ; F97F62  dc 61
	inc 1,HL                                             ; F97F64  db 61
	jr .LF97F37                                          ; F97F66  68 cf
.LF97F68:
	ld h, 0x00:opc                                          ; F97F68  26 00
.LF97F6A:
	ld C,H                                               ; F97F6A  ce 8b
	extz BC                                              ; F97F6C  d9 12
	ld IX,BC                                             ; F97F6E  d9 8c
	ldw wa, MidiCfg_ModeBits                                       ; F97F70  30 32 7f
	add WA,BC                                            ; F97F73  d9 80
	ld (xiz-4), wa                                       ; F97F75  be fc 50
	ld IX,WA                                             ; F97F78  d8 8c
	ldw de, Combination_Current                                       ; F97F7A  32 20 76
	sub WA,DE                                            ; F97F7D  da a0
	exts XWA                                             ; F97F7F  e8 13
	add XWA,0x00608000                                   ; F97F81  e8 c8 00 80 60 00
	ld C,(XWA)                                           ; F97F87  80 23
	ld L,C                                               ; F97F89  cb 8f
	ld bc, (xiz-4)                                       ; F97F8B  9e fc 21
	extz XBC                                             ; F97F8E  e9 12
	ld (XBC),L                                           ; F97F90  b1 47
	inc 1,H                                              ; F97F92  ce 61
	cp H,0x0a                                            ; F97F94  ce cf 0a
	jr ule, .LF97F6A                                     ; F97F97  63 d1
	and	(0x7f4d:16), 0xf8                            ; F97F99  c1 4d 7f 3c f8
	ld h, (0x7f4d:16)                                   ; F97F9E  c1 4d 7f 26
	ldw bc, 0x7f4a                                       ; F97FA2  31 4a 7f
	inc 3,BC                                             ; F97FA5  d9 63
	sub BC,DE                                            ; F97FA7  da a1
	exts XBC                                             ; F97FA9  e9 13
	add XBC,0x00608000                                   ; F97FAB  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F97FB1  81 21
	and A,0x07                                           ; F97FB3  c9 cc 07
	or A,H                                               ; F97FB6  ce e1
	ld (0x7f4d:16), a                                   ; F97FB8  f1 4d 7f 41
.LF97FBC:
	pop XIX                                              ; F97FBC  5c
	pop XDE                                              ; F97FBD  5a
	popw hl                                              ; F97FBE  4b
	unlk XIZ                                             ; F97FBF  ee 0d
	ret                                                  ; F97FC1  0e
.LF97FC2:
	link XIZ,0xfffc                                      ; F97FC2  ee 0c fc ff
	pushw hl                                             ; F97FC6  2b
	pushw de                                             ; F97FC7  2a
	push XIX                                             ; F97FC8  3c
	lda xix, (0x608000:24)                               ; F97FC9  f2 00 80 60 34
	ld c, (0x7ee4:16)                                   ; F97FCE  c1 e4 7e 23
	and C,0x0f                                           ; F97FD2  cb cc 0f
	jrl nz, .LF982F0                                     ; F97FD5  7e 18 03
	ldw hl, 0x00                                         ; F97FD8  33 00 00
	ldw bc, 0x7634                                       ; F97FDB  31 34 76
	ld (xiz-2), bc                                       ; F97FDE  be fe 51
	ldw wa, 0x76a0                                       ; F97FE1  30 a0 76
	ld DE,WA                                             ; F97FE4  d8 8a
	sub DE,BC                                            ; F97FE6  d9 a2
.LF97FE8:
	cp HL,DE                                             ; F97FE8  da f3
	jr ugt, .LF98011                                     ; F97FEA  6b 25
	ld (xiz-2), hl                                       ; F97FEC  be fe 53
	ldw bc, 0x7634                                       ; F97FEF  31 34 76
	add	bc, (xiz-2)                                  ; F97FF2  9e fe 81
	ld (xiz-4), bc                                       ; F97FF5  be fc 51
	ldw wa, Combination_Current                                       ; F97FF8  30 20 76
	sub BC,WA                                            ; F97FFB  d8 a1
	exts XBC                                             ; F97FFD  e9 13
	add XBC,XIX                                          ; F97FFF  ec 81
	ld A,(XBC)                                           ; F98001  81 21
	ld bc, (xiz-2)                                       ; F98003  9e fe 21
	extz XBC                                             ; F98006  e9 12
	ld (XBC+0x7634),A                                    ; F98008  f3 e5 34 76 41
	inc 1,HL                                             ; F9800D  db 61
	jr .LF97FE8                                          ; F9800F  68 d7
.LF98011:
	ldw hl, 0x76c2                                       ; F98011  33 c2 76
	ld BC,HL                                             ; F98014  db 89
	inc 3,BC                                             ; F98016  d9 63
	ld DE,BC                                             ; F98018  d9 8a
	ldw wa, Combination_Current                                       ; F9801A  30 20 76
	ld (xiz-2), wa                                       ; F9801D  be fe 50
	sub BC,WA                                            ; F98020  d8 a1
	exts XBC                                             ; F98022  e9 13
	add XBC,XIX                                          ; F98024  ec 81
	ld A,(XBC)                                           ; F98026  81 21
	ld (0x76c5:16), a                                   ; F98028  f1 c5 76 41
	ld BC,HL                                             ; F9802C  db 89
	inc 4,BC                                             ; F9802E  d9 64
	sub	bc, (xiz-2)                                  ; F98030  9e fe a1
	exts XBC                                             ; F98033  e9 13
	add XBC,XIX                                          ; F98035  ec 81
	ld A,(XBC)                                           ; F98037  81 21
	ld (0x76c6:16), a                                   ; F98039  f1 c6 76 41
	ldw hl, 0x7702                                       ; F9803D  33 02 77
	ld BC,HL                                             ; F98040  db 89
	inc 3,BC                                             ; F98042  d9 63
	sub	bc, (xiz-2)                                  ; F98044  9e fe a1
	exts XBC                                             ; F98047  e9 13
	add XBC,XIX                                          ; F98049  ec 81
	ld A,(XBC)                                           ; F9804B  81 21
	ld (0x7705:16), a                                   ; F9804D  f1 05 77 41
	ld BC,HL                                             ; F98051  db 89
	inc 4,BC                                             ; F98053  d9 64
	sub	bc, (xiz-2)                                  ; F98055  9e fe a1
	exts XBC                                             ; F98058  e9 13
	add XBC,XIX                                          ; F9805A  ec 81
	ld A,(XBC)                                           ; F9805C  81 21
	ld (0x76c6:16), a                                   ; F9805E  f1 c6 76 41
	ldw hl, 0x7742                                       ; F98062  33 42 77
	ld BC,HL                                             ; F98065  db 89
	inc 3,BC                                             ; F98067  d9 63
	sub	bc, (xiz-2)                                  ; F98069  9e fe a1
	exts XBC                                             ; F9806C  e9 13
	add XBC,XIX                                          ; F9806E  ec 81
	ld A,(XBC)                                           ; F98070  81 21
	ld (0x7745:16), a                                   ; F98072  f1 45 77 41
	ld BC,HL                                             ; F98076  db 89
	inc 4,BC                                             ; F98078  d9 64
	sub	bc, (xiz-2)                                  ; F9807A  9e fe a1
	exts XBC                                             ; F9807D  e9 13
	add XBC,XIX                                          ; F9807F  ec 81
	ld A,(XBC)                                           ; F98081  81 21
	ld (0x7746:16), a                                   ; F98083  f1 46 77 41
	ldw hl, 0x7782                                       ; F98087  33 82 77
	ld BC,HL                                             ; F9808A  db 89
	inc 3,BC                                             ; F9808C  d9 63
	sub	bc, (xiz-2)                                  ; F9808E  9e fe a1
	exts XBC                                             ; F98091  e9 13
	add XBC,XIX                                          ; F98093  ec 81
	ld A,(XBC)                                           ; F98095  81 21
	ld (0x7785:16), a                                   ; F98097  f1 85 77 41
	ld BC,HL                                             ; F9809B  db 89
	inc 4,BC                                             ; F9809D  d9 64
	sub	bc, (xiz-2)                                  ; F9809F  9e fe a1
	exts XBC                                             ; F980A2  e9 13
	add XBC,XIX                                          ; F980A4  ec 81
	ld A,(XBC)                                           ; F980A6  81 21
	ld (0x7786:16), a                                   ; F980A8  f1 86 77 41
	ldw hl, 0x77c2                                       ; F980AC  33 c2 77
	ld BC,HL                                             ; F980AF  db 89
	inc 3,BC                                             ; F980B1  d9 63
	sub	bc, (xiz-2)                                  ; F980B3  9e fe a1
	exts XBC                                             ; F980B6  e9 13
	add XBC,XIX                                          ; F980B8  ec 81
	ld A,(XBC)                                           ; F980BA  81 21
	ld (0x77c5:16), a                                   ; F980BC  f1 c5 77 41
	ld BC,HL                                             ; F980C0  db 89
	inc 4,BC                                             ; F980C2  d9 64
	sub	bc, (xiz-2)                                  ; F980C4  9e fe a1
	exts XBC                                             ; F980C7  e9 13
	add XBC,XIX                                          ; F980C9  ec 81
	ld A,(XBC)                                           ; F980CB  81 21
	ld (0x77c6:16), a                                   ; F980CD  f1 c6 77 41
	ldw hl, 0x7802                                       ; F980D1  33 02 78
	ld BC,HL                                             ; F980D4  db 89
	inc 3,BC                                             ; F980D6  d9 63
	sub	bc, (xiz-2)                                  ; F980D8  9e fe a1
	exts XBC                                             ; F980DB  e9 13
	add XBC,XIX                                          ; F980DD  ec 81
	ld A,(XBC)                                           ; F980DF  81 21
	ld (0x7805:16), a                                   ; F980E1  f1 05 78 41
	ld BC,HL                                             ; F980E5  db 89
	inc 4,BC                                             ; F980E7  d9 64
	sub	bc, (xiz-2)                                  ; F980E9  9e fe a1
	exts XBC                                             ; F980EC  e9 13
	add XBC,XIX                                          ; F980EE  ec 81
	ld A,(XBC)                                           ; F980F0  81 21
	ld (0x7806:16), a                                   ; F980F2  f1 06 78 41
	ldw hl, 0x7842                                       ; F980F6  33 42 78
	ld BC,HL                                             ; F980F9  db 89
	inc 3,BC                                             ; F980FB  d9 63
	sub	bc, (xiz-2)                                  ; F980FD  9e fe a1
	exts XBC                                             ; F98100  e9 13
	add XBC,XIX                                          ; F98102  ec 81
	ld A,(XBC)                                           ; F98104  81 21
	ld (0x7845:16), a                                   ; F98106  f1 45 78 41
	ld BC,HL                                             ; F9810A  db 89
	inc 4,BC                                             ; F9810C  d9 64
	sub	bc, (xiz-2)                                  ; F9810E  9e fe a1
	exts XBC                                             ; F98111  e9 13
	add XBC,XIX                                          ; F98113  ec 81
	ld A,(XBC)                                           ; F98115  81 21
	ld (0x7846:16), a                                   ; F98117  f1 46 78 41
	ldw hl, 0x7882                                       ; F9811B  33 82 78
	ld BC,HL                                             ; F9811E  db 89
	inc 3,BC                                             ; F98120  d9 63
	sub	bc, (xiz-2)                                  ; F98122  9e fe a1
	exts XBC                                             ; F98125  e9 13
	add XBC,XIX                                          ; F98127  ec 81
	ld A,(XBC)                                           ; F98129  81 21
	ld (0x7885:16), a                                   ; F9812B  f1 85 78 41
	ld BC,HL                                             ; F9812F  db 89
	inc 4,BC                                             ; F98131  d9 64
	sub	bc, (xiz-2)                                  ; F98133  9e fe a1
	exts XBC                                             ; F98136  e9 13
	add XBC,XIX                                          ; F98138  ec 81
	ld A,(XBC)                                           ; F9813A  81 21
	ld (0x7886:16), a                                   ; F9813C  f1 86 78 41
	ldw hl, 0x76a2                                       ; F98140  33 a2 76
	ld BC,HL                                             ; F98143  db 89
	inc 5,BC                                             ; F98145  d9 65
	sub	bc, (xiz-2)                                  ; F98147  9e fe a1
	exts XBC                                             ; F9814A  e9 13
	add XBC,XIX                                          ; F9814C  ec 81
	ld A,(XBC)                                           ; F9814E  81 21
	ld (0x76a7:16), a                                   ; F98150  f1 a7 76 41
	ld BC,HL                                             ; F98154  db 89
	inc 6,BC                                             ; F98156  d9 66
	sub	bc, (xiz-2)                                  ; F98158  9e fe a1
	exts XBC                                             ; F9815B  e9 13
	add XBC,XIX                                          ; F9815D  ec 81
	ld A,(XBC)                                           ; F9815F  81 21
	ld (0x76a8:16), a                                   ; F98161  f1 a8 76 41
	ld BC,HL                                             ; F98165  db 89
	inc 7,BC                                             ; F98167  d9 67
	sub	bc, (xiz-2)                                  ; F98169  9e fe a1
	exts XBC                                             ; F9816C  e9 13
	add XBC,XIX                                          ; F9816E  ec 81
	ld A,(XBC)                                           ; F98170  81 21
	ld (0x76a9:16), a                                   ; F98172  f1 a9 76 41
	ldw hl, 0x76e2                                       ; F98176  33 e2 76
	ld BC,HL                                             ; F98179  db 89
	inc 5,BC                                             ; F9817B  d9 65
	sub	bc, (xiz-2)                                  ; F9817D  9e fe a1
	exts XBC                                             ; F98180  e9 13
	add XBC,XIX                                          ; F98182  ec 81
	ld A,(XBC)                                           ; F98184  81 21
	ld (0x76e7:16), a                                   ; F98186  f1 e7 76 41
	ld BC,HL                                             ; F9818A  db 89
	inc 6,BC                                             ; F9818C  d9 66
	sub	bc, (xiz-2)                                  ; F9818E  9e fe a1
	exts XBC                                             ; F98191  e9 13
	add XBC,XIX                                          ; F98193  ec 81
	ld A,(XBC)                                           ; F98195  81 21
	ld (0x76e8:16), a                                   ; F98197  f1 e8 76 41
	ld BC,HL                                             ; F9819B  db 89
	inc 7,BC                                             ; F9819D  d9 67
	sub	bc, (xiz-2)                                  ; F9819F  9e fe a1
	exts XBC                                             ; F981A2  e9 13
	add XBC,XIX                                          ; F981A4  ec 81
	ld A,(XBC)                                           ; F981A6  81 21
	ld (0x76e9:16), a                                   ; F981A8  f1 e9 76 41
	ldw hl, 0x7722                                       ; F981AC  33 22 77
	ld BC,HL                                             ; F981AF  db 89
	inc 5,BC                                             ; F981B1  d9 65
	sub	bc, (xiz-2)                                  ; F981B3  9e fe a1
	exts XBC                                             ; F981B6  e9 13
	add XBC,XIX                                          ; F981B8  ec 81
	ld A,(XBC)                                           ; F981BA  81 21
	ld (0x7727:16), a                                   ; F981BC  f1 27 77 41
	ld BC,HL                                             ; F981C0  db 89
	inc 6,BC                                             ; F981C2  d9 66
	sub	bc, (xiz-2)                                  ; F981C4  9e fe a1
	exts XBC                                             ; F981C7  e9 13
	add XBC,XIX                                          ; F981C9  ec 81
	ld A,(XBC)                                           ; F981CB  81 21
	ld (0x7728:16), a                                   ; F981CD  f1 28 77 41
	ld BC,HL                                             ; F981D1  db 89
	inc 7,BC                                             ; F981D3  d9 67
	sub	bc, (xiz-2)                                  ; F981D5  9e fe a1
	exts XBC                                             ; F981D8  e9 13
	add XBC,XIX                                          ; F981DA  ec 81
	ld A,(XBC)                                           ; F981DC  81 21
	ld (0x7729:16), a                                   ; F981DE  f1 29 77 41
	ldw hl, 0x7762                                       ; F981E2  33 62 77
	ld BC,HL                                             ; F981E5  db 89
	inc 5,BC                                             ; F981E7  d9 65
	sub	bc, (xiz-2)                                  ; F981E9  9e fe a1
	exts XBC                                             ; F981EC  e9 13
	add XBC,XIX                                          ; F981EE  ec 81
	ld A,(XBC)                                           ; F981F0  81 21
	ld (0x7767:16), a                                   ; F981F2  f1 67 77 41
	ld BC,HL                                             ; F981F6  db 89
	inc 6,BC                                             ; F981F8  d9 66
	sub	bc, (xiz-2)                                  ; F981FA  9e fe a1
	exts XBC                                             ; F981FD  e9 13
	add XBC,XIX                                          ; F981FF  ec 81
	ld A,(XBC)                                           ; F98201  81 21
	ld (0x7768:16), a                                   ; F98203  f1 68 77 41
	ld BC,HL                                             ; F98207  db 89
	inc 7,BC                                             ; F98209  d9 67
	sub	bc, (xiz-2)                                  ; F9820B  9e fe a1
	exts XBC                                             ; F9820E  e9 13
	add XBC,XIX                                          ; F98210  ec 81
	ld A,(XBC)                                           ; F98212  81 21
	ld (0x7769:16), a                                   ; F98214  f1 69 77 41
	ldw hl, 0x77a2                                       ; F98218  33 a2 77
	ld BC,HL                                             ; F9821B  db 89
	inc 5,BC                                             ; F9821D  d9 65
	sub	bc, (xiz-2)                                  ; F9821F  9e fe a1
	exts XBC                                             ; F98222  e9 13
	add XBC,XIX                                          ; F98224  ec 81
	ld A,(XBC)                                           ; F98226  81 21
	ld (0x77a7:16), a                                   ; F98228  f1 a7 77 41
	ld BC,HL                                             ; F9822C  db 89
	inc 6,BC                                             ; F9822E  d9 66
	sub	bc, (xiz-2)                                  ; F98230  9e fe a1
	exts XBC                                             ; F98233  e9 13
	add XBC,XIX                                          ; F98235  ec 81
	ld A,(XBC)                                           ; F98237  81 21
	ld (0x77a8:16), a                                   ; F98239  f1 a8 77 41
	ld BC,HL                                             ; F9823D  db 89
	inc 7,BC                                             ; F9823F  d9 67
	sub	bc, (xiz-2)                                  ; F98241  9e fe a1
	exts XBC                                             ; F98244  e9 13
	add XBC,XIX                                          ; F98246  ec 81
	ld A,(XBC)                                           ; F98248  81 21
	ld (0x77a9:16), a                                   ; F9824A  f1 a9 77 41
	ldw hl, 0x77e2                                       ; F9824E  33 e2 77
	ld BC,HL                                             ; F98251  db 89
	inc 5,BC                                             ; F98253  d9 65
	sub	bc, (xiz-2)                                  ; F98255  9e fe a1
	exts XBC                                             ; F98258  e9 13
	add XBC,XIX                                          ; F9825A  ec 81
	ld A,(XBC)                                           ; F9825C  81 21
	ld (0x77e7:16), a                                   ; F9825E  f1 e7 77 41
	ld BC,HL                                             ; F98262  db 89
	inc 6,BC                                             ; F98264  d9 66
	sub	bc, (xiz-2)                                  ; F98266  9e fe a1
	exts XBC                                             ; F98269  e9 13
	add XBC,XIX                                          ; F9826B  ec 81
	ld A,(XBC)                                           ; F9826D  81 21
	ld (0x77e8:16), a                                   ; F9826F  f1 e8 77 41
	ld BC,HL                                             ; F98273  db 89
	inc 7,BC                                             ; F98275  d9 67
	sub	bc, (xiz-2)                                  ; F98277  9e fe a1
	exts XBC                                             ; F9827A  e9 13
	add XBC,XIX                                          ; F9827C  ec 81
	ld A,(XBC)                                           ; F9827E  81 21
	ld (0x77e9:16), a                                   ; F98280  f1 e9 77 41
	ldw hl, 0x7822                                       ; F98284  33 22 78
	ld BC,HL                                             ; F98287  db 89
	inc 5,BC                                             ; F98289  d9 65
	sub	bc, (xiz-2)                                  ; F9828B  9e fe a1
	exts XBC                                             ; F9828E  e9 13
	add XBC,XIX                                          ; F98290  ec 81
	ld A,(XBC)                                           ; F98292  81 21
	ld (0x7827:16), a                                   ; F98294  f1 27 78 41
	ld BC,HL                                             ; F98298  db 89
	inc 6,BC                                             ; F9829A  d9 66
	sub	bc, (xiz-2)                                  ; F9829C  9e fe a1
	exts XBC                                             ; F9829F  e9 13
	add XBC,XIX                                          ; F982A1  ec 81
	ld A,(XBC)                                           ; F982A3  81 21
	ld (0x7828:16), a                                   ; F982A5  f1 28 78 41
	ld BC,HL                                             ; F982A9  db 89
	inc 7,BC                                             ; F982AB  d9 67
	sub	bc, (xiz-2)                                  ; F982AD  9e fe a1
	exts XBC                                             ; F982B0  e9 13
	add XBC,XIX                                          ; F982B2  ec 81
	ld A,(XBC)                                           ; F982B4  81 21
	ld (0x7829:16), a                                   ; F982B6  f1 29 78 41
	ldw hl, 0x7862                                       ; F982BA  33 62 78
	ld BC,HL                                             ; F982BD  db 89
	inc 5,BC                                             ; F982BF  d9 65
	sub	bc, (xiz-2)                                  ; F982C1  9e fe a1
	exts XBC                                             ; F982C4  e9 13
	add XBC,XIX                                          ; F982C6  ec 81
	ld A,(XBC)                                           ; F982C8  81 21
	ld (0x7867:16), a                                   ; F982CA  f1 67 78 41
	ld BC,HL                                             ; F982CE  db 89
	inc 6,BC                                             ; F982D0  d9 66
	sub	bc, (xiz-2)                                  ; F982D2  9e fe a1
	exts XBC                                             ; F982D5  e9 13
	add XBC,XIX                                          ; F982D7  ec 81
	ld A,(XBC)                                           ; F982D9  81 21
	ld (0x7868:16), a                                   ; F982DB  f1 68 78 41
	ld BC,HL                                             ; F982DF  db 89
	inc 7,BC                                             ; F982E1  d9 67
	sub	bc, (xiz-2)                                  ; F982E3  9e fe a1
	exts XBC                                             ; F982E6  e9 13
	add XBC,XIX                                          ; F982E8  ec 81
	ld A,(XBC)                                           ; F982EA  81 21
	ld (0x7869:16), a                                   ; F982EC  f1 69 78 41
.LF982F0:
	pop XIX                                              ; F982F0  5c
	popw de                                              ; F982F1  4a
	popw hl                                              ; F982F2  4b
	unlk XIZ                                             ; F982F3  ee 0d
	ret                                                  ; F982F5  0e
.LF982F6:
	link XIZ,0xffe6                                      ; F982F6  ee 0c e6 ff
	push XHL                                             ; F982FA  3b
	pushw de                                             ; F982FB  2a
	push XIX                                             ; F982FC  3c
	lda xix, (0x608000:24)                               ; F982FD  f2 00 80 60 34
	ld c, (0x7ee4:16)                                   ; F98302  c1 e4 7e 23
	and C,0xf0                                           ; F98306  cb cc f0
	jrl nz, .LF98621                                     ; F98309  7e 15 03
	ldw hl, 0x18                                         ; F9830C  33 18 00
	extz XHL                                             ; F9830F  eb 12
	ld D,(XHL+0x76c2)                                    ; F98311  c3 ed c2 76 24
	ld e, 0xfe:opc                                          ; F98316  25 fe
	ld C,E                                               ; F98318  cd 8b
	and C,D                                              ; F9831A  cc c3
	ld (xiz-2), c                                        ; F9831C  be fe 43
	extz XHL                                             ; F9831F  eb 12
	ld (XHL+0x76c2),C                                    ; F98321  f3 ed c2 76 43
	ldw bc, 0x76c2                                       ; F98326  31 c2 76
	ld (xiz-4), bc                                       ; F98329  be fc 51
	add BC,HL                                            ; F9832C  db 81
	ld (xiz-6), bc                                       ; F9832E  be fa 51
	ldw wa, Combination_Current                                       ; F98331  30 20 76
	ld (xiz-8), wa                                       ; F98334  be f8 50
	sub BC,WA                                            ; F98337  d8 a1
	exts XBC                                             ; F98339  e9 13
	add XBC,XIX                                          ; F9833B  ec 81
	ld A,(XBC)                                           ; F9833D  81 21
	and A,0x01                                           ; F9833F  c9 cc 01
	or	a, (xiz-2)                                   ; F98342  8e fe e1
	extz XHL                                             ; F98345  eb 12
	ld (XHL+0x76c2),A                                    ; F98347  f3 ed c2 76 41
	ldw	(xiz-10), 0x0019                             ; F9834C  be f6 02 19 00
	ld bc, (xiz-4)                                       ; F98351  9e fc 21
	add	bc, (xiz-10)                                 ; F98354  9e f6 81
	sub	bc, (xiz-8)                                  ; F98357  9e f8 a1
	exts XBC                                             ; F9835A  e9 13
	add XBC,XIX                                          ; F9835C  ec 81
	ld A,(XBC)                                           ; F9835E  81 21
	ld bc, (xiz-10)                                      ; F98360  9e f6 21
	extz XBC                                             ; F98363  e9 12
	ld (XBC+0x76c2),A                                    ; F98365  f3 e5 c2 76 41
	ldw	(xiz-12), 0x001a                             ; F9836A  be f4 02 1a 00
	ld wa, (xiz-4)                                       ; F9836F  9e fc 20
	add	wa, (xiz-12)                                 ; F98372  9e f4 80
	sub	wa, (xiz-8)                                  ; F98375  9e f8 a0
	exts XWA                                             ; F98378  e8 13
	add XWA,XIX                                          ; F9837A  ec 80
	ld C,(XWA)                                           ; F9837C  80 23
	ld D,C                                               ; F9837E  cb 8c
	ld bc, (xiz-12)                                      ; F98380  9e f4 21
	extz XBC                                             ; F98383  e9 12
	ld (XBC+0x76c2),D                                    ; F98385  f3 e5 c2 76 44
	extz XHL                                             ; F9838A  eb 12
	and (XHL+0x7702),E                                   ; F9838C  c3 ed 02 77 cd
	extz XHL                                             ; F98391  eb 12
	ld D,(XHL+0x7702)                                    ; F98393  c3 ed 02 77 24
	ldw wa, 0x7702                                       ; F98398  30 02 77
	ld (xiz-14), wa                                      ; F9839B  be f2 50
	add WA,HL                                            ; F9839E  db 80
	sub	wa, (xiz-8)                                  ; F983A0  9e f8 a0
	exts XWA                                             ; F983A3  e8 13
	add XWA,XIX                                          ; F983A5  ec 80
	ld C,(XWA)                                           ; F983A7  80 23
	and C,0x01                                           ; F983A9  cb cc 01
	or C,D                                               ; F983AC  cc e3
	extz XHL                                             ; F983AE  eb 12
	ld (XHL+0x7702),C                                    ; F983B0  f3 ed 02 77 43
	ld bc, (xiz-14)                                      ; F983B5  9e f2 21
	add	bc, (xiz-10)                                 ; F983B8  9e f6 81
	sub	bc, (xiz-8)                                  ; F983BB  9e f8 a1
	exts XBC                                             ; F983BE  e9 13
	add XBC,XIX                                          ; F983C0  ec 81
	ld W,(XBC)                                           ; F983C2  81 20
	ld bc, (xiz-10)                                      ; F983C4  9e f6 21
	extz XBC                                             ; F983C7  e9 12
	ld (XBC+0x7702),W                                    ; F983C9  f3 e5 02 77 40
	ld wa, (xiz-14)                                      ; F983CE  9e f2 20
	add	wa, (xiz-12)                                 ; F983D1  9e f4 80
	sub	wa, (xiz-8)                                  ; F983D4  9e f8 a0
	exts XWA                                             ; F983D7  e8 13
	add XWA,XIX                                          ; F983D9  ec 80
	ld C,(XWA)                                           ; F983DB  80 23
	ld D,C                                               ; F983DD  cb 8c
	ld bc, (xiz-12)                                      ; F983DF  9e f4 21
	extz XBC                                             ; F983E2  e9 12
	ld (XBC+0x7702),D                                    ; F983E4  f3 e5 02 77 44
	extz XHL                                             ; F983E9  eb 12
	and (XHL+0x7742),E                                   ; F983EB  c3 ed 42 77 cd
	extz XHL                                             ; F983F0  eb 12
	ld D,(XHL+0x7742)                                    ; F983F2  c3 ed 42 77 24
	ldw wa, 0x7742                                       ; F983F7  30 42 77
	ld (xiz-16), wa                                      ; F983FA  be f0 50
	add WA,HL                                            ; F983FD  db 80
	sub	wa, (xiz-8)                                  ; F983FF  9e f8 a0
	exts XWA                                             ; F98402  e8 13
	add XWA,XIX                                          ; F98404  ec 80
	ld C,(XWA)                                           ; F98406  80 23
	and C,0x01                                           ; F98408  cb cc 01
	or C,D                                               ; F9840B  cc e3
	extz XHL                                             ; F9840D  eb 12
	ld (XHL+0x7742),C                                    ; F9840F  f3 ed 42 77 43
	ld bc, (xiz-16)                                      ; F98414  9e f0 21
	add	bc, (xiz-10)                                 ; F98417  9e f6 81
	sub	bc, (xiz-8)                                  ; F9841A  9e f8 a1
	exts XBC                                             ; F9841D  e9 13
	add XBC,XIX                                          ; F9841F  ec 81
	ld W,(XBC)                                           ; F98421  81 20
	ld bc, (xiz-10)                                      ; F98423  9e f6 21
	extz XBC                                             ; F98426  e9 12
	ld (XBC+0x7742),W                                    ; F98428  f3 e5 42 77 40
	ld wa, (xiz-16)                                      ; F9842D  9e f0 20
	add	wa, (xiz-12)                                 ; F98430  9e f4 80
	sub	wa, (xiz-8)                                  ; F98433  9e f8 a0
	exts XWA                                             ; F98436  e8 13
	add XWA,XIX                                          ; F98438  ec 80
	ld C,(XWA)                                           ; F9843A  80 23
	ld D,C                                               ; F9843C  cb 8c
	ld bc, (xiz-12)                                      ; F9843E  9e f4 21
	extz XBC                                             ; F98441  e9 12
	ld (XBC+0x7742),D                                    ; F98443  f3 e5 42 77 44
	extz XHL                                             ; F98448  eb 12
	and (XHL+0x7782),E                                   ; F9844A  c3 ed 82 77 cd
	extz XHL                                             ; F9844F  eb 12
	ld D,(XHL+0x7782)                                    ; F98451  c3 ed 82 77 24
	ldw wa, 0x7782                                       ; F98456  30 82 77
	ld (xiz-18), wa                                      ; F98459  be ee 50
	add WA,HL                                            ; F9845C  db 80
	sub	wa, (xiz-8)                                  ; F9845E  9e f8 a0
	exts XWA                                             ; F98461  e8 13
	add XWA,XIX                                          ; F98463  ec 80
	ld C,(XWA)                                           ; F98465  80 23
	and C,0x01                                           ; F98467  cb cc 01
	or C,D                                               ; F9846A  cc e3
	extz XHL                                             ; F9846C  eb 12
	ld (XHL+0x7782),C                                    ; F9846E  f3 ed 82 77 43
	ld bc, (xiz-18)                                      ; F98473  9e ee 21
	add	bc, (xiz-10)                                 ; F98476  9e f6 81
	sub	bc, (xiz-8)                                  ; F98479  9e f8 a1
	exts XBC                                             ; F9847C  e9 13
	add XBC,XIX                                          ; F9847E  ec 81
	ld W,(XBC)                                           ; F98480  81 20
	ld bc, (xiz-10)                                      ; F98482  9e f6 21
	extz XBC                                             ; F98485  e9 12
	ld (XBC+0x7782),W                                    ; F98487  f3 e5 82 77 40
	ld wa, (xiz-18)                                      ; F9848C  9e ee 20
	add	wa, (xiz-12)                                 ; F9848F  9e f4 80
	sub	wa, (xiz-8)                                  ; F98492  9e f8 a0
	exts XWA                                             ; F98495  e8 13
	add XWA,XIX                                          ; F98497  ec 80
	ld C,(XWA)                                           ; F98499  80 23
	ld D,C                                               ; F9849B  cb 8c
	ld bc, (xiz-12)                                      ; F9849D  9e f4 21
	extz XBC                                             ; F984A0  e9 12
	ld (XBC+0x7782),D                                    ; F984A2  f3 e5 82 77 44
	extz XHL                                             ; F984A7  eb 12
	and (XHL+0x77c2),E                                   ; F984A9  c3 ed c2 77 cd
	extz XHL                                             ; F984AE  eb 12
	ld D,(XHL+0x77c2)                                    ; F984B0  c3 ed c2 77 24
	ldw wa, 0x77c2                                       ; F984B5  30 c2 77
	ld (xiz-20), wa                                      ; F984B8  be ec 50
	add WA,HL                                            ; F984BB  db 80
	sub	wa, (xiz-8)                                  ; F984BD  9e f8 a0
	exts XWA                                             ; F984C0  e8 13
	add XWA,XIX                                          ; F984C2  ec 80
	ld C,(XWA)                                           ; F984C4  80 23
	and C,0x01                                           ; F984C6  cb cc 01
	or C,D                                               ; F984C9  cc e3
	extz XHL                                             ; F984CB  eb 12
	ld (XHL+0x77c2),C                                    ; F984CD  f3 ed c2 77 43
	ld bc, (xiz-20)                                      ; F984D2  9e ec 21
	add	bc, (xiz-10)                                 ; F984D5  9e f6 81
	sub	bc, (xiz-8)                                  ; F984D8  9e f8 a1
	exts XBC                                             ; F984DB  e9 13
	add XBC,XIX                                          ; F984DD  ec 81
	ld W,(XBC)                                           ; F984DF  81 20
	ld bc, (xiz-10)                                      ; F984E1  9e f6 21
	extz XBC                                             ; F984E4  e9 12
	ld (XBC+0x77c2),W                                    ; F984E6  f3 e5 c2 77 40
	ld wa, (xiz-20)                                      ; F984EB  9e ec 20
	add	wa, (xiz-12)                                 ; F984EE  9e f4 80
	sub	wa, (xiz-8)                                  ; F984F1  9e f8 a0
	exts XWA                                             ; F984F4  e8 13
	add XWA,XIX                                          ; F984F6  ec 80
	ld C,(XWA)                                           ; F984F8  80 23
	ld D,C                                               ; F984FA  cb 8c
	ld bc, (xiz-12)                                      ; F984FC  9e f4 21
	extz XBC                                             ; F984FF  e9 12
	ld (XBC+0x77c2),D                                    ; F98501  f3 e5 c2 77 44
	extz XHL                                             ; F98506  eb 12
	and (XHL+0x7802),E                                   ; F98508  c3 ed 02 78 cd
	extz XHL                                             ; F9850D  eb 12
	ld D,(XHL+0x7802)                                    ; F9850F  c3 ed 02 78 24
	ldw wa, 0x7802                                       ; F98514  30 02 78
	ld (xiz-22), wa                                      ; F98517  be ea 50
	add WA,HL                                            ; F9851A  db 80
	sub	wa, (xiz-8)                                  ; F9851C  9e f8 a0
	exts XWA                                             ; F9851F  e8 13
	add XWA,XIX                                          ; F98521  ec 80
	ld C,(XWA)                                           ; F98523  80 23
	and C,0x01                                           ; F98525  cb cc 01
	or C,D                                               ; F98528  cc e3
	extz XHL                                             ; F9852A  eb 12
	ld (XHL+0x7802),C                                    ; F9852C  f3 ed 02 78 43
	ld bc, (xiz-22)                                      ; F98531  9e ea 21
	add	bc, (xiz-10)                                 ; F98534  9e f6 81
	sub	bc, (xiz-8)                                  ; F98537  9e f8 a1
	exts XBC                                             ; F9853A  e9 13
	add XBC,XIX                                          ; F9853C  ec 81
	ld W,(XBC)                                           ; F9853E  81 20
	ld bc, (xiz-10)                                      ; F98540  9e f6 21
	extz XBC                                             ; F98543  e9 12
	ld (XBC+0x7802),W                                    ; F98545  f3 e5 02 78 40
	ld wa, (xiz-22)                                      ; F9854A  9e ea 20
	add	wa, (xiz-12)                                 ; F9854D  9e f4 80
	sub	wa, (xiz-8)                                  ; F98550  9e f8 a0
	exts XWA                                             ; F98553  e8 13
	add XWA,XIX                                          ; F98555  ec 80
	ld C,(XWA)                                           ; F98557  80 23
	ld D,C                                               ; F98559  cb 8c
	ld bc, (xiz-12)                                      ; F9855B  9e f4 21
	extz XBC                                             ; F9855E  e9 12
	ld (XBC+0x7802),D                                    ; F98560  f3 e5 02 78 44
	extz XHL                                             ; F98565  eb 12
	and (XHL+0x7842),E                                   ; F98567  c3 ed 42 78 cd
	extz XHL                                             ; F9856C  eb 12
	ld D,(XHL+0x7842)                                    ; F9856E  c3 ed 42 78 24
	ldw wa, 0x7842                                       ; F98573  30 42 78
	ld (xiz-24), wa                                      ; F98576  be e8 50
	add WA,HL                                            ; F98579  db 80
	sub	wa, (xiz-8)                                  ; F9857B  9e f8 a0
	exts XWA                                             ; F9857E  e8 13
	add XWA,XIX                                          ; F98580  ec 80
	ld C,(XWA)                                           ; F98582  80 23
	and C,0x01                                           ; F98584  cb cc 01
	or C,D                                               ; F98587  cc e3
	extz XHL                                             ; F98589  eb 12
	ld (XHL+0x7842),C                                    ; F9858B  f3 ed 42 78 43
	ld bc, (xiz-24)                                      ; F98590  9e e8 21
	add	bc, (xiz-10)                                 ; F98593  9e f6 81
	sub	bc, (xiz-8)                                  ; F98596  9e f8 a1
	exts XBC                                             ; F98599  e9 13
	add XBC,XIX                                          ; F9859B  ec 81
	ld W,(XBC)                                           ; F9859D  81 20
	ld bc, (xiz-10)                                      ; F9859F  9e f6 21
	extz XBC                                             ; F985A2  e9 12
	ld (XBC+0x7842),W                                    ; F985A4  f3 e5 42 78 40
	ld wa, (xiz-24)                                      ; F985A9  9e e8 20
	add	wa, (xiz-12)                                 ; F985AC  9e f4 80
	sub	wa, (xiz-8)                                  ; F985AF  9e f8 a0
	exts XWA                                             ; F985B2  e8 13
	add XWA,XIX                                          ; F985B4  ec 80
	ld C,(XWA)                                           ; F985B6  80 23
	ld D,C                                               ; F985B8  cb 8c
	ld bc, (xiz-12)                                      ; F985BA  9e f4 21
	extz XBC                                             ; F985BD  e9 12
	ld (XBC+0x7842),D                                    ; F985BF  f3 e5 42 78 44
	extz XHL                                             ; F985C4  eb 12
	and (XHL+0x7882),E                                   ; F985C6  c3 ed 82 78 cd
	extz XHL                                             ; F985CB  eb 12
	ld D,(XHL+0x7882)                                    ; F985CD  c3 ed 82 78 24
	ldw wa, 0x7882                                       ; F985D2  30 82 78
	ld (xiz-26), wa                                      ; F985D5  be e6 50
	add WA,HL                                            ; F985D8  db 80
	sub	wa, (xiz-8)                                  ; F985DA  9e f8 a0
	exts XWA                                             ; F985DD  e8 13
	add XWA,XIX                                          ; F985DF  ec 80
	ld C,(XWA)                                           ; F985E1  80 23
	and C,0x01                                           ; F985E3  cb cc 01
	or C,D                                               ; F985E6  cc e3
	extz XHL                                             ; F985E8  eb 12
	ld (XHL+0x7882),C                                    ; F985EA  f3 ed 82 78 43
	ld bc, (xiz-26)                                      ; F985EF  9e e6 21
	add	bc, (xiz-10)                                 ; F985F2  9e f6 81
	sub	bc, (xiz-8)                                  ; F985F5  9e f8 a1
	exts XBC                                             ; F985F8  e9 13
	add XBC,XIX                                          ; F985FA  ec 81
	ld W,(XBC)                                           ; F985FC  81 20
	ld bc, (xiz-10)                                      ; F985FE  9e f6 21
	extz XBC                                             ; F98601  e9 12
	ld (XBC+0x7882),W                                    ; F98603  f3 e5 82 78 40
	ld bc, (xiz-26)                                      ; F98608  9e e6 21
	add	bc, (xiz-12)                                 ; F9860B  9e f4 81
	sub	bc, (xiz-8)                                  ; F9860E  9e f8 a1
	exts XBC                                             ; F98611  e9 13
	add XBC,XIX                                          ; F98613  ec 81
	ld A,(XBC)                                           ; F98615  81 21
	ld bc, (xiz-12)                                      ; F98617  9e f4 21
	extz XBC                                             ; F9861A  e9 12
	ld (XBC+0x7882),A                                    ; F9861C  f3 e5 82 78 41
.LF98621:
	pop XIX                                              ; F98621  5c
	popw de                                              ; F98622  4a
	pop XHL                                              ; F98623  5b
	unlk XIZ                                             ; F98624  ee 0d
	ret                                                  ; F98626  0e
.LF98627:
	push XIX                                             ; F98627  3c
	lda xix, (MidiOut_PostPartPanpot:24)                             ; F98628  f2 03 75 f9 34
	lda xbc, (0x76a2:16)                                ; F9862D  f1 a2 76 31
	ld (0x218b:16), xbc                                 ; F98631  f1 8b 21 61
	ld (0x218f:16), 0x00                                 ; F98635  f1 8f 21 00 00
	ld a, (0x76b1:16)                                   ; F9863A  c1 b1 76 21
	and A,0x80                                           ; F9863E  c9 cc 80
	jr nz, .LF98647                                      ; F98641  6e 04
	call MidiOut_PostPartBankSelect                                        ; F98643  1d 81 74 f9
.LF98647:
	ld c, (0x76b0:16)                                   ; F98647  c1 b0 76 23
	and C,0x80                                           ; F9864B  cb cc 80
	jr nz, .LF98654                                      ; F9864E  6e 04
	call MidiOut_PostPartProgramChange                                        ; F98650  1d 51 74 f9
.LF98654:
	ld c, (0x76b3:16)                                   ; F98654  c1 b3 76 23
	and C,0x80                                           ; F98658  cb cc 80
	jr nz, .LF98661                                      ; F9865B  6e 04
	call MidiOut_PostPartVolume                                        ; F9865D  1d d3 74 f9
.LF98661:
	ld c, (0x76b4:16)                                   ; F98661  c1 b4 76 23
	and C,0x80                                           ; F98665  cb cc 80
	jr nz, .LF98672                                      ; F98668  6e 08
	lda xiy, (.LF98672:24)                               ; F9866A  f2 72 86 f9 35
	push XIY                                             ; F9866F  3d
	jp (xix)                                             ; F98670  b4 d8
.LF98672:
	ld c, (0x76b5:16)                                   ; F98672  c1 b5 76 23
	and C,0x80                                           ; F98676  cb cc 80
	jr nz, .LF9867F                                      ; F98679  6e 04
	call MidiOut_PostPartEffect1Send                                        ; F9867B  1d 33 75 f9
.LF9867F:
	ld c, (0x76b6:16)                                   ; F9867F  c1 b6 76 23
	and C,0x80                                           ; F98683  cb cc 80
	jr nz, .LF9868C                                      ; F98686  6e 04
	call MidiOut_PostPartReverbSend                                        ; F98688  1d 63 75 f9
.LF9868C:
	lda xbc, (0x76e2:16)                                ; F9868C  f1 e2 76 31
	ld (0x218b:16), xbc                                 ; F98690  f1 8b 21 61
	ld (0x218f:16), 0x01                                 ; F98694  f1 8f 21 00 01
	ld a, (0x76f1:16)                                   ; F98699  c1 f1 76 21
	and A,0x80                                           ; F9869D  c9 cc 80
	jr nz, .LF986A6                                      ; F986A0  6e 04
	call MidiOut_PostPartBankSelect                                        ; F986A2  1d 81 74 f9
.LF986A6:
	ld c, (0x76f0:16)                                   ; F986A6  c1 f0 76 23
	and C,0x80                                           ; F986AA  cb cc 80
	jr nz, .LF986B3                                      ; F986AD  6e 04
	call MidiOut_PostPartProgramChange                                        ; F986AF  1d 51 74 f9
.LF986B3:
	ld c, (0x76f3:16)                                   ; F986B3  c1 f3 76 23
	and C,0x80                                           ; F986B7  cb cc 80
	jr nz, .LF986C0                                      ; F986BA  6e 04
	call MidiOut_PostPartVolume                                        ; F986BC  1d d3 74 f9
.LF986C0:
	ld c, (0x76f4:16)                                   ; F986C0  c1 f4 76 23
	and C,0x80                                           ; F986C4  cb cc 80
	jr nz, .LF986D1                                      ; F986C7  6e 08
	lda xiy, (.LF986D1:24)                               ; F986C9  f2 d1 86 f9 35
	push XIY                                             ; F986CE  3d
	jp (xix)                                             ; F986CF  b4 d8
.LF986D1:
	ld c, (0x76f5:16)                                   ; F986D1  c1 f5 76 23
	and C,0x80                                           ; F986D5  cb cc 80
	jr nz, .LF986DE                                      ; F986D8  6e 04
	call MidiOut_PostPartEffect1Send                                        ; F986DA  1d 33 75 f9
.LF986DE:
	ld c, (0x76f6:16)                                   ; F986DE  c1 f6 76 23
	and C,0x80                                           ; F986E2  cb cc 80
	jr nz, .LF986EB                                      ; F986E5  6e 04
	call MidiOut_PostPartReverbSend                                        ; F986E7  1d 63 75 f9
.LF986EB:
	lda xbc, (0x7722:16)                                ; F986EB  f1 22 77 31
	ld (0x218b:16), xbc                                 ; F986EF  f1 8b 21 61
	ld (0x218f:16), 0x02                                 ; F986F3  f1 8f 21 00 02
	ld a, (0x7731:16)                                   ; F986F8  c1 31 77 21
	and A,0x80                                           ; F986FC  c9 cc 80
	jr nz, .LF98705                                      ; F986FF  6e 04
	call MidiOut_PostPartBankSelect                                        ; F98701  1d 81 74 f9
.LF98705:
	ld c, (0x7730:16)                                   ; F98705  c1 30 77 23
	and C,0x80                                           ; F98709  cb cc 80
	jr nz, .LF98712                                      ; F9870C  6e 04
	call MidiOut_PostPartProgramChange                                        ; F9870E  1d 51 74 f9
.LF98712:
	ld c, (0x7733:16)                                   ; F98712  c1 33 77 23
	and C,0x80                                           ; F98716  cb cc 80
	jr nz, .LF9871F                                      ; F98719  6e 04
	call MidiOut_PostPartVolume                                        ; F9871B  1d d3 74 f9
.LF9871F:
	ld c, (0x7734:16)                                   ; F9871F  c1 34 77 23
	and C,0x80                                           ; F98723  cb cc 80
	jr nz, .LF98730                                      ; F98726  6e 08
	lda xiy, (.LF98730:24)                               ; F98728  f2 30 87 f9 35
	push XIY                                             ; F9872D  3d
	jp (xix)                                             ; F9872E  b4 d8
.LF98730:
	ld c, (0x7735:16)                                   ; F98730  c1 35 77 23
	and C,0x80                                           ; F98734  cb cc 80
	jr nz, .LF9873D                                      ; F98737  6e 04
	call MidiOut_PostPartEffect1Send                                        ; F98739  1d 33 75 f9
.LF9873D:
	ld c, (0x7736:16)                                   ; F9873D  c1 36 77 23
	and C,0x80                                           ; F98741  cb cc 80
	jr nz, .LF9874A                                      ; F98744  6e 04
	call MidiOut_PostPartReverbSend                                        ; F98746  1d 63 75 f9
.LF9874A:
	lda xbc, (0x7762:16)                                ; F9874A  f1 62 77 31
	ld (0x218b:16), xbc                                 ; F9874E  f1 8b 21 61
	ld (0x218f:16), 0x03                                 ; F98752  f1 8f 21 00 03
	ld a, (0x7771:16)                                   ; F98757  c1 71 77 21
	and A,0x80                                           ; F9875B  c9 cc 80
	jr nz, .LF98764                                      ; F9875E  6e 04
	call MidiOut_PostPartBankSelect                                        ; F98760  1d 81 74 f9
.LF98764:
	ld c, (0x7770:16)                                   ; F98764  c1 70 77 23
	and C,0x80                                           ; F98768  cb cc 80
	jr nz, .LF98771                                      ; F9876B  6e 04
	call MidiOut_PostPartProgramChange                                        ; F9876D  1d 51 74 f9
.LF98771:
	ld c, (0x7773:16)                                   ; F98771  c1 73 77 23
	and C,0x80                                           ; F98775  cb cc 80
	jr nz, .LF9877E                                      ; F98778  6e 04
	call MidiOut_PostPartVolume                                        ; F9877A  1d d3 74 f9
.LF9877E:
	ld c, (0x7774:16)                                   ; F9877E  c1 74 77 23
	and C,0x80                                           ; F98782  cb cc 80
	jr nz, .LF9878F                                      ; F98785  6e 08
	lda xiy, (.LF9878F:24)                               ; F98787  f2 8f 87 f9 35
	push XIY                                             ; F9878C  3d
	jp (xix)                                             ; F9878D  b4 d8
.LF9878F:
	ld c, (0x7775:16)                                   ; F9878F  c1 75 77 23
	and C,0x80                                           ; F98793  cb cc 80
	jr nz, .LF9879C                                      ; F98796  6e 04
	call MidiOut_PostPartEffect1Send                                        ; F98798  1d 33 75 f9
.LF9879C:
	ld c, (0x7776:16)                                   ; F9879C  c1 76 77 23
	and C,0x80                                           ; F987A0  cb cc 80
	jr nz, .LF987A9                                      ; F987A3  6e 04
	call MidiOut_PostPartReverbSend                                        ; F987A5  1d 63 75 f9
.LF987A9:
	lda xbc, (0x77a2:16)                                ; F987A9  f1 a2 77 31
	ld (0x218b:16), xbc                                 ; F987AD  f1 8b 21 61
	ld (0x218f:16), 0x04                                 ; F987B1  f1 8f 21 00 04
	ld a, (0x77b1:16)                                   ; F987B6  c1 b1 77 21
	and A,0x80                                           ; F987BA  c9 cc 80
	jr nz, .LF987C3                                      ; F987BD  6e 04
	call MidiOut_PostPartBankSelect                                        ; F987BF  1d 81 74 f9
.LF987C3:
	ld c, (0x77b0:16)                                   ; F987C3  c1 b0 77 23
	and C,0x80                                           ; F987C7  cb cc 80
	jr nz, .LF987D0                                      ; F987CA  6e 04
	call MidiOut_PostPartProgramChange                                        ; F987CC  1d 51 74 f9
.LF987D0:
	ld c, (0x77b3:16)                                   ; F987D0  c1 b3 77 23
	and C,0x80                                           ; F987D4  cb cc 80
	jr nz, .LF987DD                                      ; F987D7  6e 04
	call MidiOut_PostPartVolume                                        ; F987D9  1d d3 74 f9
.LF987DD:
	ld c, (0x77b4:16)                                   ; F987DD  c1 b4 77 23
	and C,0x80                                           ; F987E1  cb cc 80
	jr nz, .LF987EE                                      ; F987E4  6e 08
	lda xiy, (.LF987EE:24)                               ; F987E6  f2 ee 87 f9 35
	push XIY                                             ; F987EB  3d
	jp (xix)                                             ; F987EC  b4 d8
.LF987EE:
	ld c, (0x77b5:16)                                   ; F987EE  c1 b5 77 23
	and C,0x80                                           ; F987F2  cb cc 80
	jr nz, .LF987FB                                      ; F987F5  6e 04
	call MidiOut_PostPartEffect1Send                                        ; F987F7  1d 33 75 f9
.LF987FB:
	ld c, (0x77b6:16)                                   ; F987FB  c1 b6 77 23
	and C,0x80                                           ; F987FF  cb cc 80
	jr nz, .LF98808                                      ; F98802  6e 04
	call MidiOut_PostPartReverbSend                                        ; F98804  1d 63 75 f9
.LF98808:
	lda xbc, (0x77e2:16)                                ; F98808  f1 e2 77 31
	ld (0x218b:16), xbc                                 ; F9880C  f1 8b 21 61
	ld (0x218f:16), 0x05                                 ; F98810  f1 8f 21 00 05
	ld a, (0x77f1:16)                                   ; F98815  c1 f1 77 21
	and A,0x80                                           ; F98819  c9 cc 80
	jr nz, .LF98822                                      ; F9881C  6e 04
	call MidiOut_PostPartBankSelect                                        ; F9881E  1d 81 74 f9
.LF98822:
	ld c, (0x77f0:16)                                   ; F98822  c1 f0 77 23
	and C,0x80                                           ; F98826  cb cc 80
	jr nz, .LF9882F                                      ; F98829  6e 04
	call MidiOut_PostPartProgramChange                                        ; F9882B  1d 51 74 f9
.LF9882F:
	ld c, (0x77f3:16)                                   ; F9882F  c1 f3 77 23
	and C,0x80                                           ; F98833  cb cc 80
	jr nz, .LF9883C                                      ; F98836  6e 04
	call MidiOut_PostPartVolume                                        ; F98838  1d d3 74 f9
.LF9883C:
	ld c, (0x77f4:16)                                   ; F9883C  c1 f4 77 23
	and C,0x80                                           ; F98840  cb cc 80
	jr nz, .LF9884D                                      ; F98843  6e 08
	lda xiy, (.LF9884D:24)                               ; F98845  f2 4d 88 f9 35
	push XIY                                             ; F9884A  3d
	jp (xix)                                             ; F9884B  b4 d8
.LF9884D:
	ld c, (0x77f5:16)                                   ; F9884D  c1 f5 77 23
	and C,0x80                                           ; F98851  cb cc 80
	jr nz, .LF9885A                                      ; F98854  6e 04
	call MidiOut_PostPartEffect1Send                                        ; F98856  1d 33 75 f9
.LF9885A:
	ld c, (0x77f6:16)                                   ; F9885A  c1 f6 77 23
	and C,0x80                                           ; F9885E  cb cc 80
	jr nz, .LF98867                                      ; F98861  6e 04
	call MidiOut_PostPartReverbSend                                        ; F98863  1d 63 75 f9
.LF98867:
	lda xbc, (0x7822:16)                                ; F98867  f1 22 78 31
	ld (0x218b:16), xbc                                 ; F9886B  f1 8b 21 61
	ld (0x218f:16), 0x06                                 ; F9886F  f1 8f 21 00 06
	ld a, (0x7831:16)                                   ; F98874  c1 31 78 21
	and A,0x80                                           ; F98878  c9 cc 80
	jr nz, .LF98881                                      ; F9887B  6e 04
	call MidiOut_PostPartBankSelect                                        ; F9887D  1d 81 74 f9
.LF98881:
	ld c, (0x7830:16)                                   ; F98881  c1 30 78 23
	and C,0x80                                           ; F98885  cb cc 80
	jr nz, .LF9888E                                      ; F98888  6e 04
	call MidiOut_PostPartProgramChange                                        ; F9888A  1d 51 74 f9
.LF9888E:
	ld c, (0x7833:16)                                   ; F9888E  c1 33 78 23
	and C,0x80                                           ; F98892  cb cc 80
	jr nz, .LF9889B                                      ; F98895  6e 04
	call MidiOut_PostPartVolume                                        ; F98897  1d d3 74 f9
.LF9889B:
	ld c, (0x7834:16)                                   ; F9889B  c1 34 78 23
	and C,0x80                                           ; F9889F  cb cc 80
	jr nz, .LF988AC                                      ; F988A2  6e 08
	lda xiy, (.LF988AC:24)                               ; F988A4  f2 ac 88 f9 35
	push XIY                                             ; F988A9  3d
	jp (xix)                                             ; F988AA  b4 d8
.LF988AC:
	ld c, (0x7835:16)                                   ; F988AC  c1 35 78 23
	and C,0x80                                           ; F988B0  cb cc 80
	jr nz, .LF988B9                                      ; F988B3  6e 04
	call MidiOut_PostPartEffect1Send                                        ; F988B5  1d 33 75 f9
.LF988B9:
	ld c, (0x7836:16)                                   ; F988B9  c1 36 78 23
	and C,0x80                                           ; F988BD  cb cc 80
	jr nz, .LF988C6                                      ; F988C0  6e 04
	call MidiOut_PostPartReverbSend                                        ; F988C2  1d 63 75 f9
.LF988C6:
	lda xbc, (0x7862:16)                                ; F988C6  f1 62 78 31
	ld (0x218b:16), xbc                                 ; F988CA  f1 8b 21 61
	ld (0x218f:16), 0x07                                 ; F988CE  f1 8f 21 00 07
	ld a, (0x7871:16)                                   ; F988D3  c1 71 78 21
	and A,0x80                                           ; F988D7  c9 cc 80
	jr nz, .LF988E0                                      ; F988DA  6e 04
	call MidiOut_PostPartBankSelect                                        ; F988DC  1d 81 74 f9
.LF988E0:
	ld c, (0x7870:16)                                   ; F988E0  c1 70 78 23
	and C,0x80                                           ; F988E4  cb cc 80
	jr nz, .LF988ED                                      ; F988E7  6e 04
	call MidiOut_PostPartProgramChange                                        ; F988E9  1d 51 74 f9
.LF988ED:
	ld c, (0x7873:16)                                   ; F988ED  c1 73 78 23
	and C,0x80                                           ; F988F1  cb cc 80
	jr nz, .LF988FA                                      ; F988F4  6e 04
	call MidiOut_PostPartVolume                                        ; F988F6  1d d3 74 f9
.LF988FA:
	ld c, (0x7874:16)                                   ; F988FA  c1 74 78 23
	and C,0x80                                           ; F988FE  cb cc 80
	jr nz, .LF9890B                                      ; F98901  6e 08
	lda xiy, (.LF9890B:24)                               ; F98903  f2 0b 89 f9 35
	push XIY                                             ; F98908  3d
	jp (xix)                                             ; F98909  b4 d8
.LF9890B:
	ld c, (0x7875:16)                                   ; F9890B  c1 75 78 23
	and C,0x80                                           ; F9890F  cb cc 80
	jr nz, .LF98918                                      ; F98912  6e 04
	call MidiOut_PostPartEffect1Send                                        ; F98914  1d 33 75 f9
.LF98918:
	ld c, (0x7876:16)                                   ; F98918  c1 76 78 23
	and C,0x80                                           ; F9891C  cb cc 80
	jr nz, .LF98925                                      ; F9891F  6e 04
	call MidiOut_PostPartReverbSend                                        ; F98921  1d 63 75 f9
.LF98925:
	pop XIX                                              ; F98925  5c
	ret                                                  ; F98926  0e
.LF98927:
; Combination_ReadFromCpu2 -- remote-read one 0x2C0-byte combination record from CPU 2 into the parameter
; image at 0x7620 (prom_b T_Combination_ReadFromCpu2, no caller found; Combination_Recall calls it at 0xF975B0)
; In: (XIZ+8) word = index; (XIZ+0x0A) = source: 0 or 0x10 -> 0xF80300 + 0x2C0*index (prom_c's factory
; preset bank), 8 -> 0xEC0300 + 0x2C0*index (CPU 2 flash, the user bank); other values read nothing.
; Evidence: `mul WA,0x02C0` and the bases at 0xF98939/0xF98955; (remote, 0x2C0, 0x7620) to
; T_Link_SendCommandE2 (0xF98973), then T_Link_WaitBlockDone; prom_c preset_bank.s lists it as a READER.
Combination_ReadFromCpu2:   ; entry: prom_b routine directory
	link XIZ,0xfffc                                      ; F98927  ee 0c fc ff
	pushw hl                                             ; F9892B  2b
	push XIX                                             ; F9892C  3c
	ld H,(XIZ+0x0a)                                      ; F9892D  8e 0a 26
	cp h, 0x00:i3                                          ; F98930  ce d8
	jr z, .LF98955                                       ; F98932  66 21
	cp H,0x08                                            ; F98934  ce cf 08
	jr nz, .LF98950                                      ; F98937  6e 17
	ld XBC,0x00ec0300                                    ; F98939  41 00 03 ec 00
	ld (xiz-4), xbc                                      ; F9893E  be fc 61
	ld WA,(XIZ+0x08)                                     ; F98941  9e 08 20
	extz WA                                              ; F98944  d8 12
	mul WA,0x02c0                                        ; F98946  d8 08 c0 02
	ld XIX,XBC                                           ; F9894A  e9 8c
	add XIX,XWA                                          ; F9894C  e8 84
	jr .LF9896A                                          ; F9894E  68 1a
.LF98950:
	cp H,0x10                                            ; F98950  ce cf 10
	jr nz, .LF9897F                                      ; F98953  6e 2a
.LF98955:
	ld XBC,PromC_PresetBank_Records                                     ; F98955  41 00 03 f8 00
	ld (xiz-4), xbc                                      ; F9895A  be fc 61
	ld WA,(XIZ+0x08)                                     ; F9895D  9e 08 20
	extz WA                                              ; F98960  d8 12
	mul WA,0x02c0                                        ; F98962  d8 08 c0 02
	ld XIX,XBC                                           ; F98966  e9 8c
	add XIX,XWA                                          ; F98968  e8 84
.LF9896A:
	lda xbc, (Combination_Current:16)                                ; F9896A  f1 20 76 31
	push XBC                                             ; F9896E  39
	pushw 0x02c0                                         ; F9896F  0b c0 02
	push XIX                                             ; F98972  3c
	call T_Link_SendCommandE2                            ; F98973  1d f0 0e f4
	call T_Link_WaitBlockDone                            ; F98977  1d 3c 12 f4
	inc 8,XSP                                            ; F9897B  ef 60
	inc 2,XSP                                            ; F9897D  ef 62
.LF9897F:
	pop XIX                                              ; F9897F  5c
	popw hl                                              ; F98980  4b
	unlk XIZ                                             ; F98981  ee 0d
	ret                                                  ; F98983  0e
; ParamImage_SnapshotCombination_Entry -- prom_b directory slot T_ParamImage_SnapshotCombination_Entry: `call
; ParamImage_SnapshotCombination / ret`
; Evidence: callers 0xF90C54, 0xF90CA4, 0xFBEDE0, 0xFBFC5E, 0xFE6F66; at 0xF90C54 it runs just before a new
; combination is ldirw'd into 0x7620, and T_ParamImage_QueueDiffCombination (ParamImage_QueueDiffCombination) follows at 0xF90C69.
ParamImage_SnapshotCombination_Entry:   ; entry: prom_b routine directory
	call ParamImage_SnapshotCombination                                        ; F98984  1d 25 74 f9
	ret                                                  ; F98988  0e
; ParamImage_SnapshotCombinationAndParts_Entry -- prom_b directory slot T_ParamImage_SnapshotCombinationAndParts_Entry: `call
; ParamImage_SnapshotCombinationAndParts / ret`
; Evidence: one caller, prom_b 0xF38857; the same prom_b routine calls T_ParamImage_QueueDiffCombinationAndParts
; (ParamImage_QueueDiffCombinationAndParts) at 0xF38937.
ParamImage_SnapshotCombinationAndParts_Entry:   ; entry: prom_b routine directory
	call ParamImage_SnapshotCombinationAndParts                                        ; F98989  1d 36 74 f9
	ret                                                  ; F9898D  0e
.LF9898E:
; ParamImage_QueueDiffCombination -- queue every byte of the COMBINATION stream (0x7620, 0x2BE bytes) that
; differs from the snapshot at 0x608000 onto the 0x2C00 event list
; Evidence: walks {tag,len,payload} records while HL < 0x78DE-0x7620 (0xF989A7-0xF989B3); each differing
; byte appends {tag, offset, new, new^old} at 0x2C00+(0x60F000) (0xF98A32-0xF98AAA); tags <= 0x1F go to
; .LF98C44, which queues offsets 0/1 as the {.,1,.,0x7F}/{.,0,.,0xFF} pair; at cursor >= 0x1F4 it drains via
; Queue2C00_DrainPassB_SaveRegs. prom_b T_ParamImage_QueueDiffCombination (0xF90C69, 0xF90CB9, 0xFBEE75, 0xFBFCD5, 0xFE01E4).
ParamImage_QueueDiffCombination:   ; entry: prom_b routine directory
	link XIZ,0xffea                                      ; F9898E  ee 0c ea ff
	push XHL                                             ; F98992  3b
	pushw de                                             ; F98993  2a
	pushw ix                                             ; F98994  2c
	ld bc, (0x60f000:24)                                ; F98995  d2 00 f0 60 21
	ld (xiz-4), bc                                       ; F9899A  be fc 51
	lda xwa, (0x2c00:16)                                ; F9899D  f1 00 2c 30
	ld (xiz-8), xwa                                      ; F989A1  be f8 60
	ldw hl, 0x00                                         ; F989A4  33 00 00
	ldw de, Combination_Current                                       ; F989A7  32 20 76
	ldw bc, 0x78de                                       ; F989AA  31 de 78
	ld IX,BC                                             ; F989AD  d9 8c
	sub IX,DE                                            ; F989AF  da a4
.LF989B1:
	cp HL,IX                                             ; F989B1  dc f3
	jrl nc, .LF98AC5                                     ; F989B3  7f 0f 01
	res	0, (0x2180:16)                               ; F989B6  f1 80 21 b0
	extz XHL                                             ; F989BA  eb 12
	ld E,(XHL+Combination_Current)                                    ; F989BC  c3 ed 20 76 25
	ld d, 0x00:opc                                          ; F989C1  24 00
	inc 1,HL                                             ; F989C3  db 61
	extz XHL                                             ; F989C5  eb 12
	ld C,(XHL+Combination_Current)                                    ; F989C7  c3 ed 20 76 23
	ld (xiz-1), c                                        ; F989CC  be ff 43
	jrl .LF98AB9                                         ; F989CF  78 e7 00
.LF989D2:
	inc 1,HL                                             ; F989D2  db 61
	ld BC,HL                                             ; F989D4  db 89
	extz XBC                                             ; F989D6  e9 12
	add XBC,0x00608000                                   ; F989D8  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F989DE  81 21
	ld (xiz-10), a                                       ; F989E0  be f6 41
	extz XHL                                             ; F989E3  eb 12
	ld B,(XHL+Combination_Current)                                    ; F989E5  c3 ed 20 76 22
	cp B,A                                               ; F989EA  c9 f2
	jrl z, .LF98AB4                                      ; F989EC  76 c5 00
	cpw	(xiz-4), 0x01f4                              ; F989EF  9e fc 3f f4 01
	jr c, .LF98A0D                                       ; F989F4  67 17
	ld bc, (xiz-4)                                       ; F989F6  9e fc 21
	extz XBC                                             ; F989F9  e9 12
	add XBC,0x00002c00                                   ; F989FB  e9 c8 00 2c 00 00
	ld (XBC),0xff                                        ; F98A01  b1 00 ff
	call Queue2C00_DrainPassB_SaveRegs                                        ; F98A04  1d 18 74 f9
	ldw	(xiz-4), 0x0000                              ; F98A08  be fc 02 00 00
.LF98A0D:
	set	5, (0x60f021:24)                             ; F98A0D  f2 21 f0 60 bd
	cp E,0x1f                                            ; F98A12  cd cf 1f
	jr ugt, .LF98A32                                     ; F98A15  6b 1b
	pushw	(xiz-4)                                      ; F98A17  9e fc 04
	lda xbc, (0x2c00:16)                                ; F98A1A  f1 00 2c 31
	push XBC                                             ; F98A1E  39
	pushw hl                                             ; F98A1F  2b
	push 0x00                                            ; F98A20  09 00
	push D                                               ; F98A22  cc 04
	pushw de                                             ; F98A24  2a
	calr .LF98C44                                        ; F98A25  1e 1c 02
	ld (xiz-4), wa                                       ; F98A28  be fc 50
	inc 8,XSP                                            ; F98A2B  ef 60
	inc 4,XSP                                            ; F98A2D  ef 64
	jrl .LF98AB4                                         ; F98A2F  78 82 00
.LF98A32:
	ld bc, (xiz-4)                                       ; F98A32  9e fc 21
	extz XBC                                             ; F98A35  e9 12
	add XBC,0x00002c00                                   ; F98A37  e9 c8 00 2c 00 00
	ld (XBC),E                                           ; F98A3D  b1 45
	ld bc, (xiz-4)                                       ; F98A3F  9e fc 21
	inc 1,BC                                             ; F98A42  d9 61
	ld (xiz-10), bc                                      ; F98A44  be f6 51
	extz XBC                                             ; F98A47  e9 12
	add XBC,0x00002c00                                   ; F98A49  e9 c8 00 2c 00 00
	ld (XBC),D                                           ; F98A4F  b1 44
	ld bc, (xiz-10)                                      ; F98A51  9e f6 21
	inc 1,BC                                             ; F98A54  d9 61
	ld (xiz-12), bc                                      ; F98A56  be f4 51
	ld (xiz-14), hl                                      ; F98A59  be f2 53
	ld wa, (xiz-14)                                      ; F98A5C  9e f2 20
	extz XWA                                             ; F98A5F  e8 12
	ld C,(XWA+Combination_Current)                                    ; F98A61  c3 e1 20 76 23
	ld (xiz-16), c                                       ; F98A66  be f0 43
	ld bc, (xiz-12)                                      ; F98A69  9e f4 21
	extz XBC                                             ; F98A6C  e9 12
	add XBC,0x00002c00                                   ; F98A6E  e9 c8 00 2c 00 00
	ld a, (xiz-16)                                       ; F98A74  8e f0 21
	ld (XBC),A                                           ; F98A77  b1 41
	ld bc, (xiz-10)                                      ; F98A79  9e f6 21
	inc 2,BC                                             ; F98A7C  d9 62
	ld (xiz-18), bc                                      ; F98A7E  be ee 51
	ld WA,HL                                             ; F98A81  db 88
	extz XWA                                             ; F98A83  e8 12
	add XWA,0x00608000                                   ; F98A85  e8 c8 00 80 60 00
	ld W,(XWA)                                           ; F98A8B  80 20
	ld (xiz-20), w                                       ; F98A8D  be ec 40
	ld bc, (xiz-14)                                      ; F98A90  9e f2 21
	extz XBC                                             ; F98A93  e9 12
	ld A,(XBC+Combination_Current)                                    ; F98A95  c3 e5 20 76 21
	xor A,W                                              ; F98A9A  c8 d1
	ld (xiz-22), a                                       ; F98A9C  be ea 41
	ld bc, (xiz-18)                                      ; F98A9F  9e ee 21
	extz XBC                                             ; F98AA2  e9 12
	add XBC,0x00002c00                                   ; F98AA4  e9 c8 00 2c 00 00
	ld (XBC),A                                           ; F98AAA  b1 41
	ld bc, (xiz-10)                                      ; F98AAC  9e f6 21
	inc 3,BC                                             ; F98AAF  d9 63
	ld (xiz-4), bc                                       ; F98AB1  be fc 51
.LF98AB4:
	inc 1,D                                              ; F98AB4  cc 61
	decm8 0x01, (xiz-1)                                  ; F98AB6  8e ff 69
.LF98AB9:
	cp	(xiz-1), 0x00                                ; F98AB9  8e ff 3f 00
	jrl nz, .LF989D2                                     ; F98ABD  7e 12 ff
	inc 1,HL                                             ; F98AC0  db 61
	jrl .LF989B1                                         ; F98AC2  78 ec fe
.LF98AC5:
	ld bc, (xiz-4)                                       ; F98AC5  9e fc 21
	extz XBC                                             ; F98AC8  e9 12
	add	xbc, (xiz-8)                                 ; F98ACA  ae f8 81
	ld (XBC),0xff                                        ; F98ACD  b1 00 ff
	ld bc, (xiz-4)                                       ; F98AD0  9e fc 21
	ld (0x60f000:24), bc                                ; F98AD3  f2 00 f0 60 51
	popw ix                                              ; F98AD8  4c
	popw de                                              ; F98AD9  4a
	pop XHL                                              ; F98ADA  5b
	unlk XIZ                                             ; F98ADB  ee 0d
	ret                                                  ; F98ADD  0e
; ParamImage_QueueDiffCombinationAndParts -- put back record 0x79 bytes 1-4 from (0x2181..0x2184), then queue
; every byte of the image's first 0x8DE bytes that differs from the snapshot onto the 0x2C00 event list
; Evidence: `ld (0x78b3..0x78b6),c` from (0x2181..0x2184) at 0xF98AE5-0xF98B01; loop bound 0x7EFE-0x7620 at
; 0xF98B1A; the same append / .LF98C44 / Queue2C00_DrainPassB_SaveRegs (0xF98B76) / 0xFF-terminate sequence
; as ParamImage_QueueDiffCombination. prom_b T_ParamImage_QueueDiffCombinationAndParts, one caller (prom_b 0xF38937).
ParamImage_QueueDiffCombinationAndParts:   ; entry: prom_b routine directory
	link XIZ,0xfff0                                      ; F98ADE  ee 0c f0 ff
	pushw hl                                             ; F98AE2  2b
	pushw de                                             ; F98AE3  2a
	push XIX                                             ; F98AE4  3c
	ld c, (0x2181:16)                                   ; F98AE5  c1 81 21 23
	ld (0x78b3:16), c                                   ; F98AE9  f1 b3 78 43
	ld c, (0x2182:16)                                   ; F98AED  c1 82 21 23
	ld (0x78b4:16), c                                   ; F98AF1  f1 b4 78 43
	ld c, (0x2183:16)                                   ; F98AF5  c1 83 21 23
	ld (0x78b5:16), c                                   ; F98AF9  f1 b5 78 43
	ld c, (0x2184:16)                                   ; F98AFD  c1 84 21 23
	ld (0x78b6:16), c                                   ; F98B01  f1 b6 78 43
	ld bc, (0x60f000:24)                                ; F98B05  d2 00 f0 60 21
	ld (xiz-2), bc                                       ; F98B0A  be fe 51
	lda xwa, (0x2c00:16)                                ; F98B0D  f1 00 2c 30
	ld (xiz-6), xwa                                      ; F98B11  be fa 60
	ldw ix, 0x00                                         ; F98B14  34 00 00
.LF98B17:
	ldw hl, Combination_Current                                       ; F98B17  33 20 76
	ldw bc, 0x7efe                                       ; F98B1A  31 fe 7e
	sub BC,HL                                            ; F98B1D  db a1
	cp IX,BC                                             ; F98B1F  d9 f4
	jrl nc, .LF98C2B                                     ; F98B21  7f 07 01
	res	0, (0x2180:16)                               ; F98B24  f1 80 21 b0
	extz XIX                                             ; F98B28  ec 12
	ld L,(XIX+Combination_Current)                                    ; F98B2A  c3 f1 20 76 27
	cp L,0xff                                            ; F98B2F  cf cf ff
	jr nz, .LF98B39                                      ; F98B32  6e 05
	inc 1,IX                                             ; F98B34  dc 61
	jrl .LF98C26                                         ; F98B36  78 ed 00
.LF98B39:
	ld h, 0x00:opc                                          ; F98B39  26 00
	inc 1,IX                                             ; F98B3B  dc 61
	extz XIX                                             ; F98B3D  ec 12
	ld D,(XIX+Combination_Current)                                    ; F98B3F  c3 f1 20 76 24
	jrl .LF98C21                                         ; F98B44  78 da 00
.LF98B47:
	inc 1,IX                                             ; F98B47  dc 61
	ld BC,IX                                             ; F98B49  dc 89
	extz XBC                                             ; F98B4B  e9 12
	add XBC,0x00608000                                   ; F98B4D  e9 c8 00 80 60 00
	ld E,(XBC)                                           ; F98B53  81 25
	extz XIX                                             ; F98B55  ec 12
	ld A,(XIX+Combination_Current)                                    ; F98B57  c3 f1 20 76 21
	cp A,E                                               ; F98B5C  cd f1
	jrl z, .LF98C1D                                      ; F98B5E  76 bc 00
	cpw	(xiz-2), 0x01f4                              ; F98B61  9e fe 3f f4 01
	jr c, .LF98B7F                                       ; F98B66  67 17
	ld bc, (xiz-2)                                       ; F98B68  9e fe 21
	extz XBC                                             ; F98B6B  e9 12
	add XBC,0x00002c00                                   ; F98B6D  e9 c8 00 2c 00 00
	ld (XBC),0xff                                        ; F98B73  b1 00 ff
	call Queue2C00_DrainPassB_SaveRegs                                        ; F98B76  1d 18 74 f9
	ldw	(xiz-2), 0x0000                              ; F98B7A  be fe 02 00 00
.LF98B7F:
	set	5, (0x60f021:24)                             ; F98B7F  f2 21 f0 60 bd
	cp L,0x1f                                            ; F98B84  cf cf 1f
	jr ugt, .LF98BA4                                     ; F98B87  6b 1b
	pushw	(xiz-2)                                      ; F98B89  9e fe 04
	lda xbc, (0x2c00:16)                                ; F98B8C  f1 00 2c 31
	push XBC                                             ; F98B90  39
	pushw ix                                             ; F98B91  2c
	push 0x00                                            ; F98B92  09 00
	push H                                               ; F98B94  ce 04
	pushw hl                                             ; F98B96  2b
	calr .LF98C44                                        ; F98B97  1e aa 00
	ld (xiz-2), wa                                       ; F98B9A  be fe 50
	inc 8,XSP                                            ; F98B9D  ef 60
	inc 4,XSP                                            ; F98B9F  ef 64
	jrl .LF98C1D                                         ; F98BA1  78 79 00
.LF98BA4:
	ld bc, (xiz-2)                                       ; F98BA4  9e fe 21
	extz XBC                                             ; F98BA7  e9 12
	add XBC,0x00002c00                                   ; F98BA9  e9 c8 00 2c 00 00
	ld (XBC),L                                           ; F98BAF  b1 47
	ld bc, (xiz-2)                                       ; F98BB1  9e fe 21
	inc 1,BC                                             ; F98BB4  d9 61
	ld (xiz-8), bc                                       ; F98BB6  be f8 51
	extz XBC                                             ; F98BB9  e9 12
	add XBC,0x00002c00                                   ; F98BBB  e9 c8 00 2c 00 00
	ld (XBC),H                                           ; F98BC1  b1 46
	ld bc, (xiz-8)                                       ; F98BC3  9e f8 21
	inc 1,BC                                             ; F98BC6  d9 61
	ld (xiz-10), bc                                      ; F98BC8  be f6 51
	ld (xiz-12), ix                                      ; F98BCB  be f4 54
	ld wa, (xiz-12)                                      ; F98BCE  9e f4 20
	extz XWA                                             ; F98BD1  e8 12
	ld E,(XWA+Combination_Current)                                    ; F98BD3  c3 e1 20 76 25
	extz XBC                                             ; F98BD8  e9 12
	add XBC,0x00002c00                                   ; F98BDA  e9 c8 00 2c 00 00
	ld (XBC),E                                           ; F98BE0  b1 45
	ld bc, (xiz-8)                                       ; F98BE2  9e f8 21
	inc 2,BC                                             ; F98BE5  d9 62
	ld (xiz-14), bc                                      ; F98BE7  be f2 51
	ld WA,IX                                             ; F98BEA  dc 88
	extz XWA                                             ; F98BEC  e8 12
	add XWA,0x00608000                                   ; F98BEE  e8 c8 00 80 60 00
	ld E,(XWA)                                           ; F98BF4  80 25
	ld wa, (xiz-12)                                      ; F98BF6  9e f4 20
	extz XWA                                             ; F98BF9  e8 12
	ld C,(XWA+Combination_Current)                                    ; F98BFB  c3 e1 20 76 23
	xor C,E                                              ; F98C00  cd d3
	ld (xiz-16), c                                       ; F98C02  be f0 43
	ld bc, (xiz-14)                                      ; F98C05  9e f2 21
	extz XBC                                             ; F98C08  e9 12
	add XBC,0x00002c00                                   ; F98C0A  e9 c8 00 2c 00 00
	ld a, (xiz-16)                                       ; F98C10  8e f0 21
	ld (XBC),A                                           ; F98C13  b1 41
	ld bc, (xiz-8)                                       ; F98C15  9e f8 21
	inc 3,BC                                             ; F98C18  d9 63
	ld (xiz-2), bc                                       ; F98C1A  be fe 51
.LF98C1D:
	inc 1,H                                              ; F98C1D  ce 61
	dec 1,D                                              ; F98C1F  cc 69
.LF98C21:
	cp d, 0x00:i3                                          ; F98C21  cc d8
	jrl nz, .LF98B47                                     ; F98C23  7e 21 ff
.LF98C26:
	inc 1,IX                                             ; F98C26  dc 61
	jrl .LF98B17                                         ; F98C28  78 ec fe
.LF98C2B:
	ld bc, (xiz-2)                                       ; F98C2B  9e fe 21
	extz XBC                                             ; F98C2E  e9 12
	add	xbc, (xiz-6)                                 ; F98C30  ae fa 81
	ld (XBC),0xff                                        ; F98C33  b1 00 ff
	ld bc, (xiz-2)                                       ; F98C36  9e fe 21
	ld (0x60f000:24), bc                                ; F98C39  f2 00 f0 60 51
	pop XIX                                              ; F98C3E  5c
	popw de                                              ; F98C3F  4a
	popw hl                                              ; F98C40  4b
	unlk XIZ                                             ; F98C41  ee 0d
	ret                                                  ; F98C43  0e
.LF98C44:
	link XIZ,0xfffc                                      ; F98C44  ee 0c fc ff
	push XHL                                             ; F98C48  3b
	pushw de                                             ; F98C49  2a
	pushw ix                                             ; F98C4A  2c
	ld IX,(XIZ+0x12)                                     ; F98C4B  9e 12 24
	ld E,(XIZ+0x0a)                                      ; F98C4E  8e 0a 25
	ld D,(XIZ+0x08)                                      ; F98C51  8e 08 24
	cp e, 0x00:i3                                          ; F98C54  cd d8
	jrl z, .LF98D57                                      ; F98C56  76 fe 00
	cp e, 0x01:i3                                          ; F98C59  cd d9
	jr z, .LF98CB9                                       ; F98C5B  66 5c
	ld BC,IX                                             ; F98C5D  dc 89
	extz XBC                                             ; F98C5F  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98C61  ae 0e 81
	ld (XBC),D                                           ; F98C64  b1 44
	ld HL,IX                                             ; F98C66  dc 8b
	inc 1,HL                                             ; F98C68  db 61
	ld BC,HL                                             ; F98C6A  db 89
	extz XBC                                             ; F98C6C  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98C6E  ae 0e 81
	ld (XBC),E                                           ; F98C71  b1 45
	ld BC,HL                                             ; F98C73  db 89
	inc 1,BC                                             ; F98C75  d9 61
	ld (xiz-2), bc                                       ; F98C77  be fe 51
	ld WA,(XIZ+0x0c)                                     ; F98C7A  9e 0c 20
	ld (xiz-4), wa                                       ; F98C7D  be fc 50
	extz XWA                                             ; F98C80  e8 12
	ld D,(XWA+Combination_Current)                                    ; F98C82  c3 e1 20 76 24
	extz XBC                                             ; F98C87  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98C89  ae 0e 81
	ld (XBC),D                                           ; F98C8C  b1 44
	ld IX,HL                                             ; F98C8E  db 8c
	inc 2,IX                                             ; F98C90  dc 62
	ld BC,(XIZ+0x0c)                                     ; F98C92  9e 0c 21
	extz XBC                                             ; F98C95  e9 12
	add XBC,0x00608000                                   ; F98C97  e9 c8 00 80 60 00
	ld H,(XBC)                                           ; F98C9D  81 26
	ld bc, (xiz-4)                                       ; F98C9F  9e fc 21
	extz XBC                                             ; F98CA2  e9 12
	ld A,(XBC+Combination_Current)                                    ; F98CA4  c3 e5 20 76 21
	ld L,A                                               ; F98CA9  c9 8f
	xor L,H                                              ; F98CAB  ce d7
	ld BC,IX                                             ; F98CAD  dc 89
	extz XBC                                             ; F98CAF  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98CB1  ae 0e 81
	ld (XBC),L                                           ; F98CB4  b1 47
	jrl .LF98DD5                                         ; F98CB6  78 1c 01
.LF98CB9:
	ld BC,(XIZ+0x0c)                                     ; F98CB9  9e 0c 21
	extz XBC                                             ; F98CBC  e9 12
	add XBC,0x00608000                                   ; F98CBE  e9 c8 00 80 60 00
	ld A,(XBC)                                           ; F98CC4  81 21
	ld E,A                                               ; F98CC6  c9 8d
	res 0x07,E                                           ; F98CC8  cd 30 07
	ld HL,(XIZ+0x0c)                                     ; F98CCB  9e 0c 23
	extz XHL                                             ; F98CCE  eb 12
	ld A,(XHL+Combination_Current)                                    ; F98CD0  c3 ed 20 76 21
	res 0x07,A                                           ; F98CD5  c9 30 07
	cp A,E                                               ; F98CD8  cd f1
	jrl z, .LF98DDD                                      ; F98CDA  76 00 01
	ld a, (0x2180:16)                                   ; F98CDD  c1 80 21 21
	and A,0x01                                           ; F98CE1  c9 cc 01
	jrl nz, .LF98DDD                                     ; F98CE4  7e f6 00
	ld BC,IX                                             ; F98CE7  dc 89
	extz XBC                                             ; F98CE9  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98CEB  ae 0e 81
	ld (XBC),D                                           ; F98CEE  b1 44
	ld BC,IX                                             ; F98CF0  dc 89
	inc 1,BC                                             ; F98CF2  d9 61
	ld (xiz-2), bc                                       ; F98CF4  be fe 51
	extz XBC                                             ; F98CF7  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98CF9  ae 0e 81
	ld (XBC),0x01                                        ; F98CFC  b1 00 01
	ld bc, (xiz-2)                                       ; F98CFF  9e fe 21
	inc 1,BC                                             ; F98D02  d9 61
	ld (xiz-4), bc                                       ; F98D04  be fc 51
	extz XHL                                             ; F98D07  eb 12
	ld E,(XHL+Combination_Current)                                    ; F98D09  c3 ed 20 76 25
	extz XBC                                             ; F98D0E  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98D10  ae 0e 81
	ld (XBC),E                                           ; F98D13  b1 45
	ld bc, (xiz-2)                                       ; F98D15  9e fe 21
	inc 2,BC                                             ; F98D18  d9 62
	extz XBC                                             ; F98D1A  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98D1C  ae 0e 81
	ld (XBC),0x7f                                        ; F98D1F  b1 00 7f
	ld bc, (xiz-2)                                       ; F98D22  9e fe 21
	inc 3,BC                                             ; F98D25  d9 63
	extz XBC                                             ; F98D27  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98D29  ae 0e 81
	ld (XBC),D                                           ; F98D2C  b1 44
	ld bc, (xiz-2)                                       ; F98D2E  9e fe 21
	inc 4,BC                                             ; F98D31  d9 64
	extz XBC                                             ; F98D33  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98D35  ae 0e 81
	ld (XBC),0x00                                        ; F98D38  b1 00 00
	ld ix, (xiz-2)                                       ; F98D3B  9e fe 24
	inc 5,IX                                             ; F98D3E  dc 65
	ld BC,HL                                             ; F98D40  db 89
	dec 1,BC                                             ; F98D42  d9 69
	extz XBC                                             ; F98D44  e9 12
	ld H,(XBC+Combination_Current)                                    ; F98D46  c3 e5 20 76 26
	ld BC,IX                                             ; F98D4B  dc 89
	extz XBC                                             ; F98D4D  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98D4F  ae 0e 81
	ld (XBC),H                                           ; F98D52  b1 46
	jrl .LF98DC9                                         ; F98D54  78 72 00
.LF98D57:
	set	0, (0x2180:16)                               ; F98D57  f1 80 21 b8
	ld BC,IX                                             ; F98D5B  dc 89
	extz XBC                                             ; F98D5D  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98D5F  ae 0e 81
	ld (XBC),D                                           ; F98D62  b1 44
	ld HL,IX                                             ; F98D64  dc 8b
	inc 1,HL                                             ; F98D66  db 61
	ld BC,HL                                             ; F98D68  db 89
	extz XBC                                             ; F98D6A  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98D6C  ae 0e 81
	ld (XBC),0x01                                        ; F98D6F  b1 00 01
	ld BC,HL                                             ; F98D72  db 89
	inc 1,BC                                             ; F98D74  d9 61
	ld (xiz-2), bc                                       ; F98D76  be fe 51
	ld WA,(XIZ+0x0c)                                     ; F98D79  9e 0c 20
	ld (xiz-4), wa                                       ; F98D7C  be fc 50
	inc 1,WA                                             ; F98D7F  d8 61
	extz XWA                                             ; F98D81  e8 12
	ld E,(XWA+Combination_Current)                                    ; F98D83  c3 e1 20 76 25
	extz XBC                                             ; F98D88  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98D8A  ae 0e 81
	ld (XBC),E                                           ; F98D8D  b1 45
	ld BC,HL                                             ; F98D8F  db 89
	inc 2,BC                                             ; F98D91  d9 62
	extz XBC                                             ; F98D93  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98D95  ae 0e 81
	ld (XBC),0x7f                                        ; F98D98  b1 00 7f
	ld BC,HL                                             ; F98D9B  db 89
	inc 3,BC                                             ; F98D9D  d9 63
	extz XBC                                             ; F98D9F  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98DA1  ae 0e 81
	ld (XBC),D                                           ; F98DA4  b1 44
	ld BC,HL                                             ; F98DA6  db 89
	inc 4,BC                                             ; F98DA8  d9 64
	extz XBC                                             ; F98DAA  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98DAC  ae 0e 81
	ld (XBC),0x00                                        ; F98DAF  b1 00 00
	ld IX,HL                                             ; F98DB2  db 8c
	inc 5,IX                                             ; F98DB4  dc 65
	ld bc, (xiz-4)                                       ; F98DB6  9e fc 21
	extz XBC                                             ; F98DB9  e9 12
	ld H,(XBC+Combination_Current)                                    ; F98DBB  c3 e5 20 76 26
	ld BC,IX                                             ; F98DC0  dc 89
	extz XBC                                             ; F98DC2  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98DC4  ae 0e 81
	ld (XBC),H                                           ; F98DC7  b1 46
.LF98DC9:
	inc 1,IX                                             ; F98DC9  dc 61
	ld BC,IX                                             ; F98DCB  dc 89
	extz XBC                                             ; F98DCD  e9 12
	add XBC,(XIZ+0x0e)                                   ; F98DCF  ae 0e 81
	ld (XBC),0xff                                        ; F98DD2  b1 00 ff
.LF98DD5:
	ld BC,IX                                             ; F98DD5  dc 89
	inc 1,BC                                             ; F98DD7  d9 61
	ld WA,BC                                             ; F98DD9  d9 88
	jr .LF98DDF                                          ; F98DDB  68 02
.LF98DDD:
	ld WA,IX                                             ; F98DDD  dc 88
.LF98DDF:
	popw ix                                              ; F98DDF  4c
	popw de                                              ; F98DE0  4a
	pop XHL                                              ; F98DE1  5b
	unlk XIZ                                             ; F98DE2  ee 0d
	ret                                                  ; F98DE4  0e
; ---------------------------------------------------------------------
; MessageScreenStale_ListPairsTail -- 134 LE32 pointers (536 B) and a 135th entry TRUNCATED
; by the module boundary at 0xF99000 (3 B).  Converted 2026-09-02 by
; notes/gen_prom_a_f98de5_table.py; argument in
; notes/FINDINGS-prom_a-f98de5-investigation.md, rewritten this pass.
;
; ★ THIS OVERTURNS THE REFUSAL RECORDED IN THAT FINDINGS FILE.  Its
;   technical reason was "indices 118+ : the alignment breaks".  It does
;   not: all 134 four-byte windows from 0xF98DE5 have a 0x00 top byte and a
;   value in 0x00F00000-0x00FFFFFF, with ZERO exceptions.  What changes at
;   index 118 is the VALUE FAMILY (0x00F30xxx after 0x00F2xxxx), which is a
;   different region of prom_b, not a different stride.
;
; Evidence, all re-derived by --audit:
;   * notes/prom_a_ptr_tables.py -- which shares no code with the emitter --
;     reports exactly ONE run in 0xF98D00-0xF99010: this one, 134 entries.
;     Its published null over 24 KiB of already-converted prom_a CODE finds
;     runs of at most 16 entries and NONE of 17 or more.
;   * 32 of the 57 distinct 0x00F2xxxx/0x00F3xxxx values are RECORD STARTS
;     of prom_b's display lists, walked with the interpreter's own
;     self-checking (opcode, length) framing.
;   * PtrTable_F99121 (already in this file) is the same object for another
;     screen set.  Aligning entry 0 here with its entry 49 (0xF991E5) makes
;     28 of 120 entries byte-identical, including unbroken runs of 10, 12, 4.
;     Both tails have the same shape, and the two local defaults differ by
;     exactly 0x400: 0xF99120-0xF98D20 = 0xF99121-0xF98D21 = 0x400.
;   * Not code: a linear decode has 37 undecodable bytes starting at
;     0xF98DE5 itself, and no branch/call/jp operand in this file lands
;     inside the span.
;   * The span does NOT open mid-object.  Scanned from 0xF98C00 -- 485 bytes
;     earlier, and at every byte offset, not only 4-aligned ones -- the detector
;     still reports the run beginning at 0xF98DE5 and nowhere sooner; the word at
;     0xF98DE1 is 0x0E0DEE5B, the `pop XHL / unlk XIZ / ret` that closes the
;     routine above.  The `.incbin` boundary and the table boundary coincide.
;
; ★ THE 3 LEFTOVER BYTES.  539 = 4*134 + 3.  `49 f9 f2` are the low three bytes
; of 0x00F2F949, which IS a display-list record start like the 32 above.
; Its top byte would sit at 0xF99000, which holds 0x3E -- the `push XIZ`
; that opens LCD_BlankThenSetPanel3Layer.  The last entry is CUT IN HALF by the module
; boundary; the same thing happens at 0xFDFFDF-0xFE0000.  Emitted as
; `.byte`, not as a `.long`: the fourth byte does not exist.
;
; WHAT IT IS -- established 2026-09-25 (lane proma), checks T1-T5 of
;   notes/proma-2026-09-25/gen_message_stale.py: a SECOND COPY of the four
;   MessageScreen_* tables at 0xF99121, 0x400 lower and unreachable -- the
;   shape of the dead copies at 0xF8A44B and 0xFAA000.  Whether it is an
;   older build or a variant's (its extra pairs name the GERMAN lists, see
;   wsa1/notes/sysex-probes/decode-findings.json) is a reading, not shown.
;   Laid against that structure, words 77..82 are its
;   interpreter-B pairs verbatim, words 83..114 its 32 argument handlers
;   and 115..117 its language pointers with every local value 0x400 lower,
;   so the copy's pair table started at 0xF98D21 (63 pairs): its first 49
;   words lie under the routine that ends at 0xF98DE4 and are gone, and
;   words 0..76 here are its words 49..125.  Its own pointers (0xF98D20,
;   0xF98D21, 0xF98C85) are not instruction starts in this image, and no
;   address in the span is named anywhere in either CPU-1 image.
; ★ CORRECTED: this paragraph said "what indexes the table" was open and
;   that the 0xF99121 table (then PtrTable_F99121) had "the same gap".
;   That table's readers are found (MessageScreen_ListPairs); this one has
;   none because it is dead, and its sub-tables are labelled below.
; ---------------------------------------------------------------------
MessageScreenStale_ListPairsTail:
	.long DL_Error23ItIsImpossibleToChangeThe ; F98DE5  [  0] prom_b display list, record start
	.long DL_Error23ItIsImpossibleToChangeThe ; F98DE9  [  1] prom_b display list, record start
	.long DL_Error24ItIsImpossibleToAssignTwo ; F98DED  [  2] prom_b display list, record start
	.long DL_Error24ItIsImpossibleToAssignTwo ; F98DF1  [  3] prom_b display list, record start
	.long DL_F2DE6B    ; F98DF5  [  4] prom_b display list, record start
	.long DL_Error25ItIsOnlyPossibleToChange ; F98DF9  [  5] prom_b display list, record start
	.long DL_Error26ItIsOnlyPossibleToMerge ; F98DFD  [  6] prom_b display list, record start
	.long DL_Error26ItIsOnlyPossibleToMerge ; F98E01  [  7] prom_b display list, record start
	.long DL_Error27ItIsImpossibleToCopyFromOr ; F98E05  [  8] prom_b display list, record start
	.long DL_Error27ItIsImpossibleToCopyFromOr ; F98E09  [  9] prom_b display list, record start
	.long 0x00f2e06a   ; F98E0D  [ 10] prom_b display list
	.long 0x00f2e0ec   ; F98E11  [ 11] prom_b display list
	.long 0x00f2e131   ; F98E15  [ 12] prom_b display list
	.long 0x00f2e131   ; F98E19  [ 13] prom_b display list
	.long 0x00f2e1de   ; F98E1D  [ 14] prom_b display list
	.long 0x00f2e5e3   ; F98E21  [ 15] prom_b display list
	.long 0x00f2e671   ; F98E25  [ 16] prom_b display list
	.long 0x00f2e540   ; F98E29  [ 17] prom_b display list
	.long 0x00f2e5e3   ; F98E2D  [ 18] prom_b display list
	.long 0x00f2e4c3   ; F98E31  [ 19] prom_b display list, record start
	.long 0x00f2e540   ; F98E35  [ 20] prom_b display list
	.long 0x00f2e671   ; F98E39  [ 21] prom_b display list
	.long 0x00f2e67f   ; F98E3D  [ 22] prom_b display list
	.long DL_ReminderTheInternalMemoryIsRetainedFor ; F98E41  [ 23] prom_b display list, record start
	.long DL_Error11ThePasswordThatYouEnteredIs ; F98E45  [ 24] prom_b display list, record start
	.long DL_PleaseWait ; F98E49  [ 25] prom_b display list, record start
	.long DL_DiskFormattingPleaseWait ; F98E4D  [ 26] prom_b display list, record start
	.long DL_LoadingFromDiskPleaseWait ; F98E51  [ 27] prom_b display list, record start
	.long DL_Error00TheDataOnTheDiskThatYouAre ; F98E55  [ 28] prom_b display list, record start
	.long DL_SavingToDiskPleaseWait ; F98E59  [ 29] prom_b display list, record start
	.long DL_LoadingFromDiskPleaseWait ; F98E5D  [ 30] prom_b display list, record start
	.long DL_DiskFormattingPleaseWait ; F98E61  [ 31] prom_b display list, record start
	.long DL_SavingToDiskPleaseWait ; F98E65  [ 32] prom_b display list, record start
	.long DL_PasswordOk ; F98E69  [ 33] prom_b display list, record start
	.long DL_ReminderTheInternalMemoryIsRetainedFor ; F98E6D  [ 34] prom_b display list, record start
	.long 0x00f2e93e   ; F98E71  [ 35] prom_b display list
	.long 0x00f2e96c   ; F98E75  [ 36] prom_b display list
	.long DL_Error00TheDataOnTheDiskThatYouAre ; F98E79  [ 37] prom_b display list, record start
	.long DL_Error01AnErrorHasOccuredWhileTheDisk ; F98E7D  [ 38] prom_b display list, record start
	.long DL_Error44ItIsImpossibleToEditADrumKit ; F98E81  [ 39] prom_b display list, record start
	.long 0x00f2e772   ; F98E85  [ 40] prom_b display list
	.long 0x00f2e772   ; F98E89  [ 41] prom_b display list
	.long 0x00f2e7f8   ; F98E8D  [ 42] prom_b display list, record start
	.long 0x00f2e7f8   ; F98E91  [ 43] prom_b display list, record start
	.long 0x00f2e88d   ; F98E95  [ 44] prom_b display list
	.long 0x00f2e88d   ; F98E99  [ 45] prom_b display list
	.long 0x00f2e8a3   ; F98E9D  [ 46] prom_b display list
	.long 0x00f2e8a3   ; F98EA1  [ 47] prom_b display list
	.long 0x00f2e8ba   ; F98EA5  [ 48] prom_b display list
	.long 0x00f2e8ba   ; F98EA9  [ 49] prom_b display list
	.long 0x00f2e8df   ; F98EAD  [ 50] prom_b display list
	.long 0x00f2e8df   ; F98EB1  [ 51] prom_b display list
	.long 0x00f2e93e   ; F98EB5  [ 52] prom_b display list
	.long 0x00f2e96c   ; F98EB9  [ 53] prom_b display list
	.long 0x00f2e976   ; F98EBD  [ 54] prom_b display list
	.long 0x00f2e96c   ; F98EC1  [ 55] prom_b display list
	.long 0x00f2e976   ; F98EC5  [ 56] prom_b display list
	.long 0x00f2e06a   ; F98EC9  [ 57] prom_b display list
	.long 0x00f2e0ec   ; F98ECD  [ 58] prom_b display list
	.long 0x00f2ea3f   ; F98ED1  [ 59] prom_b display list
	.long DL_PleaseSelectOneOfTheUser ; F98ED5  [ 60] prom_b display list, record start
	.long DL_UsedOnlyTypeInThisMode ; F98ED9  [ 61] prom_b display list, record start
	.long 0x00f2ec30   ; F98EDD  [ 62] prom_b display list
	.long 0x00f2ec30   ; F98EE1  [ 63] prom_b display list
	.long 0x00f2ed18   ; F98EE5  [ 64] prom_b display list
	.long DL_PleaseSelectOneOfTheUser ; F98EE9  [ 65] prom_b display list, record start
	.long DL_UsedOnlyTypeInThisMode ; F98EED  [ 66] prom_b display list, record start
	.long 0x00f2ed18   ; F98EF1  [ 67] prom_b display list
	.long 0x00f2ee30   ; F98EF5  [ 68] prom_b display list
	.long 0x00f2ee30   ; F98EF9  [ 69] prom_b display list
	.long 0x00f2eefb   ; F98EFD  [ 70] prom_b display list
	.long 0x00f2eefb   ; F98F01  [ 71] prom_b display list
	.long 0x00f2f09b   ; F98F05  [ 72] prom_b display list
	.long 0x00f2f09b   ; F98F09  [ 73] prom_b display list
	.long 0x00f2f21a   ; F98F0D  [ 74] prom_b display list
	.long 0x00f2f21a   ; F98F11  [ 75] prom_b display list
	.long 0x00f2f2ce   ; F98F15  [ 76] prom_b display list
; ---------------------------------------------------------------------
; MessageScreenStale_ListPairsB -- 3 (start,end) pairs, the older build's
;          MessageScreen_ListPairsB: the same six words (check T1).
; ---------------------------------------------------------------------
MessageScreenStale_ListPairsB:
	.long DL_F2DE6B    ; F98F19  [ 77] prom_b display list, record start
	.long DLTable_ARhythmTrackAlreadyExists ; F98F1D  [ 78] prom_b display list
	.long DL_F2DE6B    ; F98F21  [ 79] prom_b display list, record start
	.long DLTable_ARhythmTrackAlreadyExists ; F98F25  [ 80] prom_b display list
	.long DL_F2DE6B    ; F98F29  [ 81] prom_b display list, record start
	.long DLTable_ARhythmTrackAlreadyExists ; F98F2D  [ 82] prom_b display list
; ---------------------------------------------------------------------
; MessageScreenStale_ArgHandlers -- 32 LE32, the older build's
;          MessageScreen_ArgHandlers: every value is the live one - 0x400
;          (check T2).  0xF98D20 and 0xF98C85 are not instruction starts in
;          THIS image (check T4), so each entry is written as the LIVE target
;          minus 0x400 -- `MessageScreen_ArgIgnore - 0x400` -- the relation T2
;          establishes, not a reference into this image's code
;          (scripts/tools/respell_stale_table.py, 2026-10-03).
; ---------------------------------------------------------------------
MessageScreenStale_ArgHandlers:
	.long MessageScreen_ArgIgnore - 0x400   ; F98F31  [ 83] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F35  [ 84] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F39  [ 85] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F3D  [ 86] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F41  [ 87] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F45  [ 88] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F49  [ 89] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F4D  [ 90] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F51  [ 91] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F55  [ 92] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F59  [ 93] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F5D  [ 94] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F61  [ 95] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F65  [ 96] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F69  [ 97] prom_a local
	.long ExitKey_MessageScreen - 0x400   ; F98F6D  [ 98] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F71  [ 99] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F75  [100] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F79  [101] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F7D  [102] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F81  [103] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F85  [104] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F89  [105] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F8D  [106] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F91  [107] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F95  [108] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F99  [109] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98F9D  [110] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98FA1  [111] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98FA5  [112] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98FA9  [113] prom_a local
	.long MessageScreen_ArgIgnore - 0x400   ; F98FAD  [114] prom_a local
; ---------------------------------------------------------------------
; MessageScreenStale_PairTableByLanguage -- 3 x 0xF98D21, the older build's
;          pair-table base (live 0xF99121 - 0x400; check T3).  0xF98D21 is
;          mid-instruction here, so the entries read
;          `MessageScreen_ListPairs - 0x400`, the relation T3 establishes.
; ---------------------------------------------------------------------
MessageScreenStale_PairTableByLanguage:
	.long MessageScreen_ListPairs - 0x400   ; F98FB1  [115] prom_a local
	.long MessageScreen_ListPairs - 0x400   ; F98FB5  [116] prom_a local
	.long MessageScreen_ListPairs - 0x400   ; F98FB9  [117] prom_a local
; ---------------------------------------------------------------------
; MessageScreenStale_ExtraListPairs -- (start,end) words the live layout does
;          not have, naming prom_b's German-language lists; the last word
;          is cut by the module boundary at 0xF99000 (see the header above).
; ---------------------------------------------------------------------
MessageScreenStale_ExtraListPairs:
	.long 0x00f30180   ; F98FBD  [118] prom_b display list, record start
	.long DL_CopyCompletedIntroFillInsUndEndingDesVon ; F98FC1  [119] prom_b display list, record start
	.long DL_CopyCompletedDasVonLhnenGew ; F98FC5  [120] prom_b display list, record start
	.long DL_Error31DasGeradeKopiertePatternHatEin ; F98FC9  [121] prom_b display list, record start
	.long DL_Error32SpeicherVoll ; F98FCD  [122] prom_b display list, record start
	.long DL_Error32SpeicherVoll ; F98FD1  [123] prom_b display list, record start
	.long DL_Error40DerIdentifikationsIdCodeDerZu ; F98FD5  [124] prom_b display list, record start
	.long DL_Error22UmDiesenVorgangAbzuschlie ; F98FD9  [125] prom_b display list, record start
	.long DL_Error23EsIstJetztNichtMehrM ; F98FDD  [126] prom_b display list, record start
	.long DL_Error23EsIstJetztNichtMehrM ; F98FE1  [127] prom_b display list, record start
	.long DL_Error24EsIstNichtMGlichZweiSpuren ; F98FE5  [128] prom_b display list, record start
	.long DL_Error24EsIstNichtMGlichZweiSpuren ; F98FE9  [129] prom_b display list, record start
	.long DL_F2F857    ; F98FED  [130] prom_b display list, record start
	.long DL_Error25EsIstNichtMGlichDieVelocity ; F98FF1  [131] prom_b display list, record start
	.long DL_Error26SpurenWieRhythmChordUndControl ; F98FF5  [132] prom_b display list, record start
	.long DL_Error26SpurenWieRhythmChordUndControl ; F98FF9  [133] prom_b display list, record start
	.byte 0x49, 0xf9, 0xf2               ; F98FFD  [134] TRUNCATED: low 3 bytes of 0x00F2F949
; LCD_BlankThenSetPanel3Layer -- blank the panel and re-issue SYSTEM SET for THREE layers, preserving XIZ,
; XIX, XHL and XDE
; Evidence: byte-identical to LCD_BlankThenSetPanel2Layer (0xF94C2B) over both 17-byte extents except ONE
; byte, the service number at +10: 0x10 (LCD_Svc_10_SetPanel3Layer) here, 0x0F there; `xor C,C` + service
; 0x0C (LCD_Svc_0C_SetLayersOn) blanks first. Unlike LCD_ScreenRedraw_Begin it leaves (0x2540) alone.
; Caller: MessageScreen_Paint (0xF990A9).
LCD_BlankThenSetPanel3Layer:   ; entry: branch/call in converted code
	push XIZ                                             ; F99000  3e
	push XIX                                             ; F99001  3c
	push XHL                                             ; F99002  3b
	push XDE                                             ; F99003  3a
	xor C,C                                              ; F99004  cb d3
	ld a, 0x0c:opc                                          ; F99006  21 0c
	swi 7                                                ; F99008  ff
; ---------------------------------------------------------------------
; LCD_BlankThenSetPanel3Layer's tail: a second SWI7 call (service 0x10) and the epilogue
; matching its own entry push order.  reachability.py does not seed past
; `swi 7` (treated as a possible non-returning trap), but this IS
; fall-through: the pop order (XDE, XHL, XIX, XIZ) is exactly the reverse
; of LCD_BlankThenSetPanel3Layer's entry (push XIZ, XIX, XHL, XDE at 0xF99000-0xF99003).
; ---------------------------------------------------------------------
	ld a, 0x10:opc                                          ; F99009  21 10
	swi 7                                                ; F9900B  ff
	pop XDE                                              ; F9900C  5a
	pop XHL                                              ; F9900D  5b
	pop XIX                                              ; F9900E  5c
	pop XIZ                                              ; F9900F  5e
	ret                                                  ; F99010  0e
; LCD_ShowAllLayers_StackFrame -- SWI7 service 0x0C with C = 7 (layers 1, 2 and 3 steady on), from inside a
; stack frame
; Evidence: byte-identical to LCD_ShowLayers1And2_StackFrame (0xF94C3C) over both 16-byte extents except
; ONE byte, the `ld C` immediate at +7: 0x07 here, 0x03 there. Caller: MessageScreen_Paint (0xF99118).
LCD_ShowAllLayers_StackFrame:   ; entry: branch/call in converted code
	push XIZ                                             ; F99011  3e
	ld XIZ,XSP                                           ; F99012  ef 8e
	push XIX                                             ; F99014  3c
	push XHL                                             ; F99015  3b
	push XDE                                             ; F99016  3a
	ld c, 0x07:opc                                          ; F99017  23 07
	ld a, 0x0c:opc                                          ; F99019  21 0c
	swi 7                                                ; F9901B  ff
; LCD_ShowAllLayers_StackFrame's epilogue after its own `swi 7` -- same reasoning as
; LCD_BlankThenSetPanel3Layer's tail just above: reachability.py does not seed past a
; trap instruction, but this is the fall-through matching the entry's
; push order (push XIZ, XIX, XHL, XDE at 0xF99011-0xF99016).
	pop XDE                                              ; F9901C  5a
	pop XHL                                              ; F9901D  5b
	pop XIX                                              ; F9901E  5c
	pop XIZ                                              ; F9901F  5e
	ret                                                  ; F99020  0e
; ==============================================================================
; 0xF99021-0xFA1403 -- ★ THE UI SCREEN BLOCK: 34,787 bytes that draw screens and
; touch no device at all
; ==============================================================================
;
; Converted 2026-08-25 (wave 5 round 3).  The frontier tool
; (notes/prom_a_module_frontier.py) ranked five of its runs in the top twelve --
; T_PanelMode_System_Enter-T_F419C4 (46 slots), T_Screen_Initial_Enter-T_F426BC (20), T_Screen_SoundMute_Enter-T_F434D4 (6),
; T_PanelMode_MidiEnter-T_F41768 (75) and T_SoundName_CopyToBuffer-T_TuneScale_KeyScalingCodeToIndex (9) -- and they all land here.
; 132 prom_b directory slots point into it, and ALL 132 land on an instruction
; boundary of one linear decode from 0xF99021 (which is itself a directory
; target, so the START of the decode is pinned by the directory and not by the
; decode).  0 call/calr from an instruction in the span reaches a non-boundary.
; Re-run: `python3 notes/prom_a_linear_decode_check.py 0xF99021 0xFA1404
; --offenders`.
;
; ★ WHAT IT IS.  Screen-drawing code, and nothing else.  Counting the thunk
; calls in the converted text: T_EditValue_StepBitField x61, T_DisplayListB_Run_Stack (T_F42E04) x43, T_DisplayList_Run_Stack (T_F42E00) x43,
; T_DisplayListB_RunOne_Stack (T_F42E0C) x38, T_CallbackQueue_Post (T_F42E84) x32, T_DisplayList_RunOne_Stack (T_F42E08) x28 -- the display-list draw entries
; (T_DisplayList_Run_Stack (T_F42E00) -> prom_b 0xF31800 and T_DisplayListB_Run_Stack (T_F42E04) -> 0xF31814 are the two
; interpreters of notes/FINDINGS-ui-display-list.md).  ★ AND IT TOUCHES NO
; DEVICE: the only operand anywhere in the span in 0x600000-0x7FFFFF is the RAM
; staging buffer 0x60A000.  So nothing here can answer an emulation gap, and the
; block is taken for coverage and for the frontier, which is stated rather than
; dressed up.
;
; ★ FIFTEEN POINTER TABLES, and how they were found.  A linear decode of this
; span reports 0 offenders -- because nothing CALLS into a pointer table -- and
; would have emitted 1,920 bytes of them as plausible-looking instructions.
; notes/prom_a_ptr_tables.py finds them by shape instead (runs of >= 6
; consecutive `lo mid hi 00` words in 0xF00000-0xFFFFFF), and its NULL CONTROL
; over 24 KiB of prom_a that is already converted CODE is 5 runs / 208 bytes,
; i.e. 0.85%.  Thirteen of the fifteen also have a reader whose own `cp BC,n`
; gives the entry count, and in ALL THIRTEEN the count from the bound and the
; count from the detector agree exactly.  That mutual confirmation is the
; evidence; neither alone would be.
;
; Routines are `sub_XXXXXX`: the strings are in prom_b's display lists, so
; tying a veneer here to a screen needs the other side.
; ==============================================================================
; InstallPainter_MessageScreen -- ENTER method of the message screen (screen id 0xAB): post MessageScreen_Paint
; on the callback queue, then signal semaphore 1
; Evidence: PanelScreen_VtableTable_ViewB [171] (0xF871ED) -> object 0xF41604, whose +0 slot T_InstallPainter_MessageScreen is
; `jp 0xF99021`. Body: T_CallbackQueue_ResetAndRestartTask2; (0x209A) = 0xFF unless message (0x2880) is
; 0x23 or 0x2C; `lda xbc,MessageScreen_Paint` + T_CallbackQueue_Post; then T_Kernel_SemaSignal_StackArg(1).
; (0x209A) is the one-shot hold preload PanelState_TakePendingHoldTime moves into (0x2073).
InstallPainter_MessageScreen:
	call T_CallbackQueue_ResetAndRestartTask2            ; F99021  1d 80 2e f4
	cp	(UI_StatusCode:16), 0x23                            ; F99025  c1 80 28 3f 23
	jr z, .LF99038                                       ; F9902A  66 0c
	cp	(UI_StatusCode:16), 0x2c                            ; F9902C  c1 80 28 3f 2c
	jr z, .LF99038                                       ; F99031  66 05
	ld (UI_ScreenHoldPending:16), 0xff                                 ; F99033  f1 9a 20 00 ff
.LF99038:
	lda xbc, (MessageScreen_Paint:24)                             ; F99038  f2 98 90 f9 31
	push XBC                                             ; F9903D  39
	call T_CallbackQueue_Post                            ; F9903E  1d 84 2e f4
	pushw 0x01                                           ; F99042  0b 01 00
	call T_Kernel_SemaSignal_StackArg                    ; F99045  1d c0 2d f4
	inc 6,XSP                                            ; F99049  ef 66
	ret                                                  ; F9904B  0e
T_F41608_Nop:
	ret                                                  ; F9904C  0e
; ScreenButton_MessageScreen -- BUTTON method of the message screen (screen id 0xAB): dispatch the panel
; code (XIZ+8) <= 0x1F through MessageScreen_ArgHandlers, with H = bit 7 of (XIZ+0x0A)
; Evidence: object 0xF41604's +8 slot T_ScreenButton_MessageScreen = `jp 0xF9904D`; +8 is what PanelButton_Route (0xF8621E)
; calls with the code and its argument. Same shape as ScreenButton_SineWaveCheckMode: `cp (XIZ+8),0x1F /
; jr ugt`, `mul BC,(XIZ+8)`, push-return + `jp (xbc)` -- so MessageScreen_ArgHandlers is indexed by the code.
ScreenButton_MessageScreen:
	link XIZ,0x0000                                      ; F9904D  ee 0c 00 00
	pushw hl                                             ; F99051  2b
	cpw	(xiz+8), 0x001f                              ; F99052  9e 08 3f 1f 00
	jr ugt, .LF99081                                     ; F99057  6b 28
	ld h, 0x01:opc                                          ; F99059  26 01
	ld BC,(XIZ+0x0a)                                     ; F9905B  9e 0a 21
	and BC,0x0080                                        ; F9905E  d9 cc 80 00
	jr nz, .LF99066                                      ; F99062  6e 02
	ld h, 0x00:opc                                          ; F99064  26 00
.LF99066:
	push 0x00                                            ; F99066  09 00
	push H                                               ; F99068  ce 04
	ldw bc, 0x04                                         ; F9906A  31 04 00
	mul	xbc, (xiz+8)                                 ; F9906D  9e 08 41
	add XBC,MessageScreen_ArgHandlers                        ; F99070  e9 c8 39 93 f9 00
	ld XBC,(XBC)                                         ; F99076  a1 21
	lda xiy, (.LF99080:24)                               ; F99078  f2 80 90 f9 35
	push XIY                                             ; F9907D  3d
	jp (xbc)                                             ; F9907E  b1 d8
.LF99080:
	popw bc                                              ; F99080  49
.LF99081:
	popw hl                                              ; F99081  4b
	unlk XIZ                                             ; F99082  ee 0d
	ret                                                  ; F99084  0e
; ExitKey_MessageScreen -- MessageScreen_ArgHandlers[15], panel code 0x0F (EXIT): (0x209A) = 1 when H = 0
; Evidence: `cp (XIZ+8),0 / jr nz / ld (0x209a),0x01`; H = bit 7 of the event argument, clear at pair
; position 1, the only position code 0x0F has (FINDINGS-prom_a-panel-control-map.md). (0x209A) reaches the
; screen-hold counter (0x2073) through PanelState_TakePendingHoldTime; sub_F95C15, slot 0x0F of
; ScreenButtonHandlers_SineWaveCheckMode, makes the same store.
ExitKey_MessageScreen:   ; entry: MessageScreen_ArgHandlers[15]
	link XIZ,0x0000                                      ; F99085  ee 0c 00 00
	cp (XIZ+0x08),0x00                                   ; F99089  8e 08 3f 00
	jr nz, .LF99094                                      ; F9908D  6e 05
	ld (UI_ScreenHoldPending:16), 0x01                                 ; F9908F  f1 9a 20 00 01
.LF99094:
	unlk XIZ                                             ; F99094  ee 0d
	ret                                                  ; F99096  0e
T_F41610_Nop:
	ret                                                  ; F99097  0e
; MessageScreen_Paint -- draw message (0x2880) (< 0x40) from MessageScreen_ListPairs; for message 0x1A also
; copy (0x0C12) to (0x2881) and draw MessageScreen_ListPairsB's list
; Evidence: posted by InstallPainter_MessageScreen and called through prom_b T_MessageScreen_Paint (13 sites);
; `cp C,0x40 / jrl nc` (0xF990A3); pair = MessageScreen_PairTableByLanguage[(0x7FC1)] + id*8 to
; T_DisplayList_Run_Stack; id 0x1A: MessageScreen_ListPairsB + 8*(0x7FC1) to T_DisplayListB_Run_Stack.
; Brackets the drawing with LCD_BlankThenSetPanel3Layer / LCD_ShowAllLayers_StackFrame.
MessageScreen_Paint:
	link XIZ,0xfff4                                      ; F99098  ee 0c f4 ff
	push XIX                                             ; F9909C  3c
	lda xix, (UI_StatusCode:16)                                ; F9909D  f1 80 28 34
	ld C,(XIX)                                           ; F990A1  84 23
	cp C,0x40                                            ; F990A3  cb cf 40
	jrl nc, .LF9911C                                     ; F990A6  7f 73 00
	call LCD_BlankThenSetPanel3Layer                                        ; F990A9  1d 00 90 f9
	ld C,(XIX)                                           ; F990AD  84 23
	mul C,0x08                                           ; F990AF  cb 08 08
	extz XBC                                             ; F990B2  e9 12
	ld (xiz-4), xbc                                      ; F990B4  be fc 61
	ld a, 0x04:opc                                          ; F990B7  21 04
	mul	wa, (0x7fc1:16)                              ; F990B9  c1 c1 7f 41
	extz XWA                                             ; F990BD  e8 12
	add XWA,MessageScreen_PairTableByLanguage                        ; F990BF  e8 c8 b9 93 f9 00
	ld XWA,(XWA)                                         ; F990C5  a0 20
	ld (xiz-8), xwa                                      ; F990C7  be f8 60
	add XWA,XBC                                          ; F990CA  e9 80
	ld XIY,(XWA)                                         ; F990CC  a0 25
	ld (xiz-12), xiy                                     ; F990CE  be f4 65
	inc 4,XBC                                            ; F990D1  e9 64
	add	xbc, (xiz-8)                                 ; F990D3  ae f8 81
	ld XWA,(XBC)                                         ; F990D6  a1 20
	push XWA                                             ; F990D8  38
	push XIY                                             ; F990D9  3d
	call T_DisplayList_Run_Stack                         ; F990DA  1d 00 2e f4
	ld C,(XIX)                                           ; F990DE  84 23
	inc 8,XSP                                            ; F990E0  ef 60
	cp C,0x1a                                            ; F990E2  cb cf 1a
	jr nz, .LF99118                                      ; F990E5  6e 31
	ld c, (0x0c12:16)                                   ; F990E7  c1 12 0c 23
	ld (0x2881:16), c                                   ; F990EB  f1 81 28 43
	ld c, 0x08:opc                                          ; F990EF  23 08
	mul	bc, (0x7fc1:16)                              ; F990F1  c1 c1 7f 43
	extz XBC                                             ; F990F5  e9 12
	ld XIX,XBC                                           ; F990F7  e9 8c
	add XBC,MessageScreen_ListPairsB                        ; F990F9  e9 c8 21 93 f9 00
	ld XBC,(XBC)                                         ; F990FF  a1 21
	ld (xiz-4), xbc                                      ; F99101  be fc 61
	ld XWA,XIX                                           ; F99104  ec 88
	inc 4,XWA                                            ; F99106  e8 64
	add XWA,MessageScreen_ListPairsB                        ; F99108  e8 c8 21 93 f9 00
	ld XWA,(XWA)                                         ; F9910E  a0 20
	push XWA                                             ; F99110  38
	push XBC                                             ; F99111  39
	call T_DisplayListB_Run_Stack                        ; F99112  1d 04 2e f4
	inc 8,XSP                                            ; F99116  ef 60
.LF99118:
	call LCD_ShowAllLayers_StackFrame                                        ; F99118  1d 11 90 f9
.LF9911C:
	pop XIX                                              ; F9911C  5c
	unlk XIZ                                             ; F9911D  ee 0d
	ret                                                  ; F9911F  0e
MessageScreen_ArgIgnore:   ; entry: MessageScreen_ArgHandlers (31 slots)
	ret                                                  ; F99120  0e
; ---------------------------------------------------------------------
; MessageScreen_ListPairs -- 64 (start, end) LE32 pairs, one display list per
;          message id; this span was PtrTable_F99121, whose header (kept
;          below) found only the +0x200 reader.
; Read by: MessageScreen_Paint (0xF99098, posted by InstallPainter_MessageScreen through
;          T_CallbackQueue_Post): id = (0x2880), `cp C,0x40 / jrl nc` -- ids
;          0x40 and up draw nothing, hence COUNT 64 -- then `ld A,4 / mul
;          WA,(0x7FC1) / add XWA,MessageScreen_PairTableByLanguage / ld XWA,
;          (XWA)` for THIS table, `mul C,8`, start = (table + id*8), end =
;          (table + id*8 + 4), and T_DisplayList_Run_Stack(start, end).
; Values: every start and end is a prom_b display list in the message
;          module whose header quotes this reader (prom_b 0xF2BE35-, the
;          `DL_` lists); start < end for all 64 (check Q4).
; (notes/proma-2026-09-25/gen_message_pairs.py, checks Q1-Q4)
; Extent:  0xF99121-0xF993C4.  Both ends are pinned by something other than the
;          run: 0xF99120 is a `ret` that ends the routine above, and the four
;          bytes at 0xF993C5 are 0x0E0E0E0E, the start of a 58-byte RET pad.
;          (The `ret` at 0xF99120 is now labelled MessageScreen_ArgIgnore.)
; ★ CORRECTED 2026-09-25 (lane proma).  This span was PtrTable_F99121: 169
;          LE32 pointers with one located reader (+0x200) and none for
;          entries 0..127, a count taken from the shape detector
;          (notes/prom_a_ptr_tables.py) for want of a reader bound, and the
;          entries' meaning open.  Three readers at +0x000 (via +0x298),
;          +0x200 and +0x218 split it into the four tables below, each with
;          its own count; the detector's 169 = 128 + 6 + 32 + 3, and the old
;          "self-reference" (three entries = the base, asserted by
;          wsa1/notes/prom_a_uiblock_checks.py 1f) is
;          MessageScreen_PairTableByLanguage.
; ---------------------------------------------------------------------
MessageScreen_ListPairs:
	.long DL_Error00TheDataOnTheDiskThatYouAre       ; F99121  [id 0x00] start
	.long DL_Error01AnErrorHasOccuredWhileTheDisk    ; F99125          end
	.long DL_Error01AnErrorHasOccuredWhileTheDisk    ; F99129  [id 0x01] start
	.long DL_Error02ThereIsNoDiskInTheDiskDrive      ; F9912D          end
	.long DL_Error02ThereIsNoDiskInTheDiskDrive      ; F99131  [id 0x02] start
	.long DL_Error03TheFileThatYouTriedToLoad        ; F99135          end
	.long DL_Error03TheFileThatYouTriedToLoad        ; F99139  [id 0x03] start
	.long DL_Error05AnErrorHasOccuredWhileTheDisk    ; F9913D          end
	.long DL_Error                                   ; F99141  [id 0x04] start
	.long DL_F2E91A                                  ; F99145          end
	.long DL_Error05AnErrorHasOccuredWhileTheDisk    ; F99149  [id 0x05] start
	.long DL_Error06TheDiskThatYouAreUsingIsWrite    ; F9914D          end
	.long DL_Error06TheDiskThatYouAreUsingIsWrite    ; F99151  [id 0x06] start
	.long DL_Error07TheDiskThatYouAreUsingIsFull     ; F99155          end
	.long DL_Error07TheDiskThatYouAreUsingIsFull     ; F99159  [id 0x07] start
	.long DL_Error08AnErrorHasOccuredWhileTheDisk    ; F9915D          end
	.long DL_Error08AnErrorHasOccuredWhileTheDisk    ; F99161  [id 0x08] start
	.long DL_Error10TheDataIsAlreadyCopyProtected    ; F99165          end
	.long DL_CopyProtectedTheDataOnTheDiskIsCopy     ; F99169  [id 0x09] start
	.long DL_Error20AProblemHasOccuredWithYour       ; F9916D          end
	.long DL_Error10TheDataIsAlreadyCopyProtected    ; F99171  [id 0x0A] start
	.long DL_PasswordOk                              ; F99175          end
	.long DL_Error11ThePasswordThatYouEnteredIs      ; F99179  [id 0x0B] start
	.long DL_CopyProtectedTheDataOnTheDiskIsCopy     ; F9917D          end
	.long DL_Error                                   ; F99181  [id 0x0C] start
	.long DL_F2E91A                                  ; F99185          end
	.long DL_Error                                   ; F99189  [id 0x0D] start
	.long DL_F2E91A                                  ; F9918D          end
	.long DL_Error20AProblemHasOccuredWithYour       ; F99191  [id 0x0E] start
	.long DL_Error21MemoryFull                       ; F99195          end
	.long DL_Error21MemoryFull                       ; F99199  [id 0x0F] start
	.long DL_Error22ItIsNecessaryToPressPunchOut     ; F9919D          end
	.long DL_Error                                   ; F991A1  [id 0x10] start
	.long DL_F2E91A                                  ; F991A5          end
	.long DL_Error                                   ; F991A9  [id 0x11] start
	.long DL_F2E91A                                  ; F991AD          end
	.long DL_Error                                   ; F991B1  [id 0x12] start
	.long DL_F2E91A                                  ; F991B5          end
	.long DL_Error30ItIsNotPossibleToChangeThe       ; F991B9  [id 0x13] start
	.long DL_Error31TheTimeSignatureOfThePattern     ; F991BD          end
	.long DL_CopyCompletedYourChosenPatternHasBeenCop ; F991C1  [id 0x14] start
	.long DL_Error40TheIdentificationIdCodeOfThe     ; F991C5          end
	.long DL_CopyCompletedTheIntroFillInsAndEndingOfY ; F991C9  [id 0x15] start
	.long DL_CopyCompletedYourChosenPatternHasBeenCop ; F991CD          end
	.long DL_Error31TheTimeSignatureOfThePattern     ; F991D1  [id 0x16] start
	.long DL_Error32MemoryFull                       ; F991D5          end
	.long DL_Error32MemoryFull                       ; F991D9  [id 0x17] start
	.long DL_CopyCompletedTheIntroFillInsAndEndingOfY ; F991DD          end
	.long DL_Error22ItIsNecessaryToPressPunchOut     ; F991E1  [id 0x18] start
	.long DL_Error23ItIsImpossibleToChangeThe        ; F991E5          end
	.long DL_Error23ItIsImpossibleToChangeThe        ; F991E9  [id 0x19] start
	.long DL_Error24ItIsImpossibleToAssignTwo        ; F991ED          end
	.long DL_Error24ItIsImpossibleToAssignTwo        ; F991F1  [id 0x1A] start
	.long DL_F2DE6B                                  ; F991F5          end
	.long DL_Error25ItIsOnlyPossibleToChange         ; F991F9  [id 0x1B] start
	.long DL_Error26ItIsOnlyPossibleToMerge          ; F991FD          end
	.long DL_Error26ItIsOnlyPossibleToMerge          ; F99201  [id 0x1C] start
	.long DL_Error27ItIsImpossibleToCopyFromOr       ; F99205          end
	.long DL_Error27ItIsImpossibleToCopyFromOr       ; F99209  [id 0x1D] start
	.long DL_Error46ItIsImpossibleToInsertFromOr     ; F9920D          end
	.long DL_Error28ThisSongIsTooLongToBeSaved       ; F99211  [id 0x1E] start
	.long DL_Error29TheMidiFileThatYouHaveTried      ; F99215          end
	.long DL_Error29TheMidiFileThatYouHaveTried      ; F99219  [id 0x1F] start
	.long DL_Error30ItIsNotPossibleToChangeThe       ; F9921D          end
	.long DL_Error42AnErrorHasOccuredDuringSystem    ; F99221  [id 0x20] start
	.long DL_Completed                               ; F99225          end
	.long DL_Error41AnErrorHasOccuredDuringSystem    ; F99229  [id 0x21] start
	.long DL_Error42AnErrorHasOccuredDuringSystem    ; F9922D          end
	.long DL_Error40TheIdentificationIdCodeOfThe     ; F99231  [id 0x22] start
	.long DL_Error41AnErrorHasOccuredDuringSystem    ; F99235          end
	.long DL_Completed                               ; F99239  [id 0x23] start
	.long DL_Error43TheFileThatYouAreTryingToLoad    ; F9923D          end
	.long DL_ReminderTheInternalMemoryIsRetainedFor  ; F99241  [id 0x24] start
	.long DL_Error11ThePasswordThatYouEnteredIs      ; F99245          end
	.long DL_PleaseWait                              ; F99249  [id 0x25] start
	.long DL_DiskFormattingPleaseWait                ; F9924D          end
	.long DL_LoadingFromDiskPleaseWait               ; F99251  [id 0x26] start
	.long DL_Error00TheDataOnTheDiskThatYouAre       ; F99255          end
	.long DL_SavingToDiskPleaseWait                  ; F99259  [id 0x27] start
	.long DL_LoadingFromDiskPleaseWait               ; F9925D          end
	.long DL_DiskFormattingPleaseWait                ; F99261  [id 0x28] start
	.long DL_SavingToDiskPleaseWait                  ; F99265          end
	.long DL_PasswordOk                              ; F99269  [id 0x29] start
	.long DL_ReminderTheInternalMemoryIsRetainedFor  ; F9926D          end
	.long DL_PMemSetHasBeenPushFor10Seconds          ; F99271  [id 0x2A] start
	.long DL_Error                                   ; F99275          end
	.long DL_Error00TheDataOnTheDiskThatYouAre       ; F99279  [id 0x2B] start
	.long DL_Error01AnErrorHasOccuredWhileTheDisk    ; F9927D          end
	.long DL_WriteCompletedYourEditedSoundHasBeenStor ; F99281  [id 0x2C] start
	.long DL_Error44ItIsImpossibleToEditADrumKit     ; F99285          end
	.long DL_Error44ItIsImpossibleToEditADrumKit     ; F99289  [id 0x2D] start
	.long DL_AttentionTheChosenParametersDoNot       ; F9928D          end
	.long DL_AttentionTheChosenParametersDoNot       ; F99291  [id 0x2E] start
	.long DL_NoSequencerData                         ; F99295          end
	.long DL_NoSequencerData                         ; F99299  [id 0x2F] start
	.long DL_FileConvertError                        ; F9929D          end
	.long DL_FileConvertError                        ; F992A1  [id 0x30] start
	.long DL_ThisIsNotAStandardMidiFile              ; F992A5          end
	.long DL_ThisIsNotAStandardMidiFile              ; F992A9  [id 0x31] start
	.long DL_TheTimebasePpqResolution                ; F992AD          end
	.long DL_TheTimebasePpqResolution                ; F992B1  [id 0x32] start
	.long DL_PMemSetHasBeenPushFor10Seconds          ; F992B5          end
	.long DL_Error                                   ; F992B9  [id 0x33] start
	.long DL_F2E91A                                  ; F992BD          end
	.long DL_Error                                   ; F992C1  [id 0x34] start
	.long DL_F2E91A                                  ; F992C5          end
	.long DL_Error46ItIsImpossibleToInsertFromOr     ; F992C9  [id 0x35] start
	.long DL_Error28ThisSongIsTooLongToBeSaved       ; F992CD          end
	.long DL_ErrorItIsNotPossibleToUse               ; F992D1  [id 0x36] start
	.long DL_ErrorItIsNotPossibleToRecord            ; F992D5          end
	.long DL_Err0rTheTypeOfInsertedDisk              ; F992D9  [id 0x37] start
	.long DL_Err0rTheQuantityOfThisSong              ; F992DD          end
	.long DL_Err0rTheQuantityOfThisSong              ; F992E1  [id 0x38] start
	.long DL_ErrorSpecialTracksSuchAs                ; F992E5          end
	.long DL_ErrorItIsNotPossibleToRecord            ; F992E9  [id 0x39] start
	.long DL_Err0rTheTypeOfInsertedDisk              ; F992ED          end
	.long DL_ErrorSpecialTracksSuchAs                ; F992F1  [id 0x3A] start
	.long DL_ErrorAut0PunchRecordingHas              ; F992F5          end
	.long DL_ErrorAut0PunchRecordingHas              ; F992F9  [id 0x3B] start
	.long DL_ErrorTheComposerPatternYou              ; F992FD          end
	.long DL_ErrorTheComposerPatternYou              ; F99301  [id 0x3C] start
	.long DL_ErrorTheSongThatYouHaveTried            ; F99305          end
	.long DL_ErrorTheSongThatYouHaveTried            ; F99309  [id 0x3D] start
	.long DL_AttentionItIsImpossibleTo               ; F9930D          end
	.long DL_AttentionItIsImpossibleTo               ; F99311  [id 0x3E] start
	.long DL_ErrorThisIsAFormat1MidiFileDisk         ; F99315          end
	.long DL_ErrorThisIsAFormat1MidiFileDisk         ; F99319  [id 0x3F] start
	.long MsgTail_F2F2AF                             ; F9931D          end

; ---------------------------------------------------------------------
; MessageScreen_ListPairsB -- 3 (start, end) LE32 pairs, interpreter B.
; Read by: MessageScreen_Paint when the message id is 0x1A: (0x2881) = (0x0C12),
;          then `ld C,8 / mul BC,(0x7FC1)`, start = (this + 8*v), `inc 4` /
;          end = (this + 8*v + 4), T_DisplayListB_Run_Stack(start, end).
; COUNT 3: the abutment -- MessageScreen_ArgHandlers starts at +0x18 --
;          and the 3 entries of MessageScreen_PairTableByLanguage, the other
;          table indexed by the same (0x7FC1).  (checks Q2, Q4)
; ---------------------------------------------------------------------
MessageScreen_ListPairsB:
	.long DL_F2DE6B                                  ; F99321  [(0x7FC1) = 0] start
	.long DLTable_ARhythmTrackAlreadyExists          ; F99325          end
	.long DL_F2DE6B                                  ; F99329  [(0x7FC1) = 1] start
	.long DLTable_ARhythmTrackAlreadyExists          ; F9932D          end
	.long DL_F2DE6B                                  ; F99331  [(0x7FC1) = 2] start
	.long DLTable_ARhythmTrackAlreadyExists          ; F99335          end

; ---------------------------------------------------------------------
; MessageScreen_ArgHandlers -- 32 LE32 handler addresses.
; Read by: ScreenButton_MessageScreen (0xF9904D, prom_b directory slot T_ScreenButton_MessageScreen):
;          `cp (XIZ+8),0x001F / jr ugt` -- COUNT 32 -- then `ldw BC,4 /
;          mul BC,(XIZ+8) / add XBC,<this> / ld XBC,(XBC)` and a call with
;          H = bit 7 of the second argument (XIZ+0x0A) pushed.
;          31 slots are MessageScreen_ArgIgnore (one `ret`); slot 15 is
;          ExitKey_MessageScreen, which sets (0x209A) = 1 when H is 0.  (checks Q3, Q4)
; ⚠ What the argument numbers (who calls T_ScreenButton_MessageScreen, with what) is not
;          established here.
; ---------------------------------------------------------------------
MessageScreen_ArgHandlers:
	.long MessageScreen_ArgIgnore                  ; F99339  [ 0]
	.long MessageScreen_ArgIgnore                  ; F9933D  [ 1]
	.long MessageScreen_ArgIgnore                  ; F99341  [ 2]
	.long MessageScreen_ArgIgnore                  ; F99345  [ 3]
	.long MessageScreen_ArgIgnore                  ; F99349  [ 4]
	.long MessageScreen_ArgIgnore                  ; F9934D  [ 5]
	.long MessageScreen_ArgIgnore                  ; F99351  [ 6]
	.long MessageScreen_ArgIgnore                  ; F99355  [ 7]
	.long MessageScreen_ArgIgnore                  ; F99359  [ 8]
	.long MessageScreen_ArgIgnore                  ; F9935D  [ 9]
	.long MessageScreen_ArgIgnore                  ; F99361  [10]
	.long MessageScreen_ArgIgnore                  ; F99365  [11]
	.long MessageScreen_ArgIgnore                  ; F99369  [12]
	.long MessageScreen_ArgIgnore                  ; F9936D  [13]
	.long MessageScreen_ArgIgnore                  ; F99371  [14]
	.long ExitKey_MessageScreen                               ; F99375  [15]
	.long MessageScreen_ArgIgnore                  ; F99379  [16]
	.long MessageScreen_ArgIgnore                  ; F9937D  [17]
	.long MessageScreen_ArgIgnore                  ; F99381  [18]
	.long MessageScreen_ArgIgnore                  ; F99385  [19]
	.long MessageScreen_ArgIgnore                  ; F99389  [20]
	.long MessageScreen_ArgIgnore                  ; F9938D  [21]
	.long MessageScreen_ArgIgnore                  ; F99391  [22]
	.long MessageScreen_ArgIgnore                  ; F99395  [23]
	.long MessageScreen_ArgIgnore                  ; F99399  [24]
	.long MessageScreen_ArgIgnore                  ; F9939D  [25]
	.long MessageScreen_ArgIgnore                  ; F993A1  [26]
	.long MessageScreen_ArgIgnore                  ; F993A5  [27]
	.long MessageScreen_ArgIgnore                  ; F993A9  [28]
	.long MessageScreen_ArgIgnore                  ; F993AD  [29]
	.long MessageScreen_ArgIgnore                  ; F993B1  [30]
	.long MessageScreen_ArgIgnore                  ; F993B5  [31]

; ---------------------------------------------------------------------
; MessageScreen_PairTableByLanguage -- 3 LE32 pointers, each to a
;          64-pair table; all three are MessageScreen_ListPairs, so every
;          value of (0x7FC1) draws the same lists in this ROM.
; Read by: MessageScreen_Paint, `ld A,4 / mul WA,(0x7FC1) / add XWA,<this> /
;          ld XWA,(XWA)` at 0xF990B7-0xF990C5.  COUNT 3: the abutment with
;          the 0x0E pad at 0xF993C5 (check Q4); prom_b's message-module
;          header reads (0x7FC1) as the language.
; ---------------------------------------------------------------------
MessageScreen_PairTableByLanguage:
	.long MessageScreen_ListPairs                    ; F993B9  [0]
	.long MessageScreen_ListPairs                    ; F993BD  [1]
	.long MessageScreen_ListPairs                    ; F993C1  [2]
	ret                                                  ; F993C5  0e

; 0xF993C6-0xF993FF -- 58 bytes of 0x0E (RET), module padding.
; Checked byte by byte, not sampled: notes/gen_prom_a_block.py refuses to
; emit this directive unless set(ROM[lo:hi]) == {0x0E}.
	.fill 58, 1, 0x0E
