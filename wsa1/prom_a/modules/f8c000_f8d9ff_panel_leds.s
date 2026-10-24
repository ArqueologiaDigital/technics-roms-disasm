; ==== 0xF8C000-0xF8DA00 -- REACHABLE CODE ONLY, emitted by notes/gen_prom_a_cover_round1.py ====
; 10 reachable run(s), 1244 bytes framed as code.  5412 bytes that nothing reaches stay
; `.incbin` -- this round converts REACHABLE CODE, not territory.
; Boundaries: notes/reachability.py's walk, frozen against this file's own output.
; Labels are sub_XXXXXX by design: this round is COVERAGE, naming is a later goal.
; This text was assembled and byte-compared with the ROM before printing.
; PanelLed_PhaseVector -- the LED module's boot phase vector: phase 0 initialises, phases 1-5 are bare ret
; Evidence: ModuleInitDirectory_F82641[5] = T_PanelLed_PhaseVector, whose word is `.long PanelLed_PhaseVector`; the walker calls vector +
;   phase (0,4,8,0xC,0x10).  Slot 0 `jp 0xF8C018` stores 5 into (0x2143)-(0x2147) (no other reader found in
;   prom_a/prom_b); slots 1-5 are `ret`.  The module's other directory slots T_PanelLed_ProcessRequests-T_PanelLed_ToggleActivityLed are the PanelLed_*
;   routines below.
PanelLed_PhaseVector:
	jp .LF8C018                                   ; F8C000  1b 18 c0 f8
	ret                                           ; F8C004  0e
	nop                                           ; F8C005  00
	nop                                           ; F8C006  00
	nop                                           ; F8C007  00
	ret                                           ; F8C008  0e
	nop                                           ; F8C009  00
	nop                                           ; F8C00A  00
	nop                                           ; F8C00B  00
	ret                                           ; F8C00C  0e
	nop                                           ; F8C00D  00
	nop                                           ; F8C00E  00
	nop                                           ; F8C00F  00
	ret                                           ; F8C010  0e
	nop                                           ; F8C011  00
	nop                                           ; F8C012  00
	nop                                           ; F8C013  00
	ret                                           ; F8C014  0e
	nop                                           ; F8C015  00
	nop                                           ; F8C016  00
	nop                                           ; F8C017  00
.LF8C018:
	ld (0x2143:16), 0x05                          ; F8C018  f1 43 21 00 05
	ld (0x2144:16), 0x05                          ; F8C01D  f1 44 21 00 05
	ld (0x2146:16), 0x05                          ; F8C022  f1 46 21 00 05
	ld (0x2147:16), 0x05                          ; F8C027  f1 47 21 00 05
	ld (0x2145:16), 0x05                          ; F8C02C  f1 45 21 00 05
	ret                                           ; F8C031  0e
; PanelLed_OnPartEvent -- pass-B event handler (classes 0x00-0x1F, 0x40): refresh the LEDs a part's sound change affects
; Evidence: T_PanelLed_OnPartEvent (`jp 0xF8C032`) sits in UiListB_Class00..1F and UiListB_Class40.  Code (0x20B8) == 0 ->
;   PanelLed_ClearCtrlOffsetLeds; CmdList_F8C046 then ORs 0x0044 into (0x2116) for code 0 (.LF8C16D record walk), i.e.
;   requests PanelLed_ShowSoundSelect (id 0x0004) and PanelLed_ShowBank (id 0x0040).  [part][0] is the record
;   MidiIn_ProgramChange_ParamTable posts.
PanelLed_OnPartEvent:   ; entry: prom_b routine directory
	ld a, (UiEvent_Byte1:16)                                   ; F8C032  c1 b8 20 21
	cp a, 0x00:i3                                          ; F8C036  c9 d8
	jr nz, .LF8C03D                                      ; F8C038  6e 03
	calr PanelLed_ClearCtrlOffsetLeds                                          ; F8C03A  1e f3 05
.LF8C03D:
	ld XIY,CmdList_F8C046                                ; F8C03D  45 46 c0 f8 00
	calr .LF8C16D                                          ; F8C042  1e 28 01
	ret                                                  ; F8C045  0e
; ---------------------------------------------------------------------
; CmdList_F8C046 -- 8 bytes, 1 x 7-byte record(s) + 0xFF terminator.
; Reader: 0xF8C03D `ld XIY,0x00f8c046` (already-converted),
; whose `calr` resolves to 0xF8C16D (`.LF8C16D: cp (XIY),0xff`, also
; already-converted) -- the exact terminator byte below.  See
; notes/gen_prom_a_f8c000_cluster.py --check and
; notes/FINDINGS-prom_a-f8c000-cluster.md.
; ---------------------------------------------------------------------
CmdList_F8C046:
	.byte 0x00, 0x16, 0x21, 0x00, 0x00, 0x44, 0x00  ; F8C046  record 0
	.byte 0xff  ; F8C04D  terminator
; PanelLed_OnClass20Event -- pass-B handler (classes 0x20-0x3F): request the six-way-select LEDs on codes 0x18-0x1A
; Evidence: T_PanelLed_OnClass20Event is in UiListB_Class20..3F; CmdList_F8C05B holds keys 0x18/0x19/0x1A -> (0x213A) |= 0x0080, the id
;   DispatchTable_F8C2B2 maps to PanelLed_ShowSixWaySelect.  Codes 0x19/0x1A come from v1 group 0x08's [0x20,0x19]
;   events (sub_F8AA24 may make it 0x1A; PanelEvent_StampPartIntoClass20 adds the part), 0x18 from LcdKeyRow4_SoundModeOrC0mbinati0nM0de.
PanelLed_OnClass20Event:   ; entry: prom_b routine directory
	ld a, (UiEvent_Byte1:16)                                   ; F8C04E  c1 b8 20 21
	ld XIY,CmdList_F8C05B                                ; F8C052  45 5b c0 f8 00
	calr .LF8C16D                                          ; F8C057  1e 13 01
	ret                                                  ; F8C05A  0e
; ---------------------------------------------------------------------
; CmdList_F8C05B -- 22 bytes, 3 x 7-byte record(s) + 0xFF terminator.
; Reader: 0xF8C052 `ld XIY,0x00f8c05b` (already-converted),
; whose `calr` resolves to 0xF8C16D (`.LF8C16D: cp (XIY),0xff`, also
; already-converted) -- the exact terminator byte below.  See
; notes/gen_prom_a_f8c000_cluster.py --check and
; notes/FINDINGS-prom_a-f8c000-cluster.md.
; ---------------------------------------------------------------------
CmdList_F8C05B:
	.byte 0x18, 0x3a, 0x21, 0x00, 0x00, 0x80, 0x00  ; F8C05B  record 0
	.byte 0x19, 0x3a, 0x21, 0x00, 0x00, 0x80, 0x00  ; F8C062  record 1
	.byte 0x1a, 0x3a, 0x21, 0x00, 0x00, 0x80, 0x00  ; F8C069  record 2
	.byte 0xff  ; F8C070  terminator
; PanelLed_OnClass90Event -- pass-B handler (class 0x90): code 0x10 resets and re-requests the part LEDs
; Evidence: T_PanelLed_OnClass90Event is in UiListB_Class90; code (0x20B8) == 0x10 -> PanelLed_ClearCtrlOffsetLeds (0xF8C07A), then
;   CmdList_F8C086 ORs 0x0080 into (0x213A) and 0x0044 into (0x2116) for code 0x10.
; Unknown: what class 0x90 code 0x10 announces.
PanelLed_OnClass90Event:   ; entry: prom_b routine directory
	ld a, (UiEvent_Byte1:16)                                   ; F8C071  c1 b8 20 21
	cp A,0x10                                            ; F8C075  c9 cf 10
	jr nz, .LF8C07D                                      ; F8C078  6e 03
	calr PanelLed_ClearCtrlOffsetLeds                                          ; F8C07A  1e b3 05
.LF8C07D:
	ld XIY,CmdList_F8C086                                ; F8C07D  45 86 c0 f8 00
	calr .LF8C16D                                            ; F8C082  1e e8 00
	ret                                                  ; F8C085  0e
; ---------------------------------------------------------------------
; CmdList_F8C086 -- 15 bytes, 2 x 7-byte record(s) + 0xFF terminator.
; Reader: 0xF8C07D `ld XIY,0x00f8c086` (already-converted),
; whose `calr` resolves to 0xF8C16D (`.LF8C16D: cp (XIY),0xff`, also
; already-converted) -- the exact terminator byte below.  See
; notes/gen_prom_a_f8c000_cluster.py --check and
; notes/FINDINGS-prom_a-f8c000-cluster.md.
; ---------------------------------------------------------------------
CmdList_F8C086:
	.byte 0x10, 0x3a, 0x21, 0x00, 0x00, 0x80, 0x00  ; F8C086  record 0
	.byte 0x10, 0x16, 0x21, 0x00, 0x00, 0x44, 0x00  ; F8C08D  record 1
	.byte 0xff  ; F8C094  terminator
T_F40684_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F8C095  0e
T_F40688_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F8C096  0e
; PanelLed_OnClassA8Event -- pass-B handler (class 0xA8): BANK and sound-select events request the sound/bank LEDs
; Evidence: T_PanelLed_OnClassA8Event is in UiListB_ClassA8; CmdList_F8C0A4 keys 0x08 and 0x07 -> (0x2116) |= 0x0044.  A8/07 is the
;   BANK event (PanelAction_BankButton/_BankRemap), A8/08 the v1 sound-select event
;   (PanelAction_SoundSelectOrKeypad_V1).
PanelLed_OnClassA8Event:   ; entry: prom_b routine directory
	ld a, (UiEvent_Byte1:16)                                   ; F8C097  c1 b8 20 21
	ld XIY,CmdList_F8C0A4                                ; F8C09B  45 a4 c0 f8 00
	calr .LF8C16D                                            ; F8C0A0  1e ca 00
	ret                                                  ; F8C0A3  0e
; ---------------------------------------------------------------------
; CmdList_F8C0A4 -- 15 bytes, 2 x 7-byte record(s) + 0xFF terminator.
; Reader: 0xF8C09B `ld XIY,0x00f8c0a4` (already-converted),
; whose `calr` resolves to 0xF8C16D (`.LF8C16D: cp (XIY),0xff`, also
; already-converted) -- the exact terminator byte below.  See
; notes/gen_prom_a_f8c000_cluster.py --check and
; notes/FINDINGS-prom_a-f8c000-cluster.md.
; ---------------------------------------------------------------------
CmdList_F8C0A4:
	.byte 0x08, 0x16, 0x21, 0x00, 0x00, 0x44, 0x00  ; F8C0A4  record 0
	.byte 0x07, 0x16, 0x21, 0x00, 0x00, 0x44, 0x00  ; F8C0AB  record 1
	.byte 0xff  ; F8C0B2  terminator
T_F40690_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F8C0B3  0e
; PanelLed_OnClass98Event -- pass-B handler (class 0x98): mode-switch events request the sound/bank LEDs
; Evidence: T_PanelLed_OnClass98Event is in UiListB_Class98; CmdList_F8C0C1 keys 0x00 and 0x01 -> (0x2116) |= 0x0044.  Event 98/00 is
;   posted by Mode_SwitchToSound/Mode_SwitchToCombination with the new (0x7F02) mode nibble; 98/01 by the
;   combination-mode path of PanelAction_SelectNextSound/_SelectPrevSound.
PanelLed_OnClass98Event:   ; entry: prom_b routine directory
	ld a, (UiEvent_Byte1:16)                                   ; F8C0B4  c1 b8 20 21
	ld XIY,CmdList_F8C0C1                                ; F8C0B8  45 c1 c0 f8 00
	calr .LF8C16D                                            ; F8C0BD  1e ad 00
	ret                                                  ; F8C0C0  0e
; ---------------------------------------------------------------------
; CmdList_F8C0C1 -- 15 bytes, 2 x 7-byte record(s) + 0xFF terminator.
; Reader: 0xF8C0B8 `ld XIY,0x00f8c0c1` (already-converted),
; whose `calr` resolves to 0xF8C16D (`.LF8C16D: cp (XIY),0xff`, also
; already-converted) -- the exact terminator byte below.  See
; notes/gen_prom_a_f8c000_cluster.py --check and
; notes/FINDINGS-prom_a-f8c000-cluster.md.
; ---------------------------------------------------------------------
CmdList_F8C0C1:
	.byte 0x00, 0x16, 0x21, 0x00, 0x00, 0x44, 0x00  ; F8C0C1  record 0
	.byte 0x01, 0x16, 0x21, 0x00, 0x00, 0x44, 0x00  ; F8C0C8  record 1
	.byte 0xff  ; F8C0CF  terminator
; PanelLed_OnCtrlParamEvent -- pass-B handler (controller classes): track the two assignable controllers' values
; Evidence: T_PanelLed_OnCtrlParamEvent is in UiListB_ClassB2-B5 and B8-BD.  With (0x20BA) != 0, the class (0x20BB) is compared with the
;   parameter number of the assignment byte at (0x7F27) and (0x7F28) (.LF8C111 = the PanelCtrl_AssignToParamNumber
;   map); a match stores the value (0x20B9) to (0x216C)/(0x216D) and ORs 0x0100/0x0800 into (0x213A), the ids of
;   PanelLed_ShowCtrl1Offset/_ShowCtrl2Offset.
PanelLed_OnCtrlParamEvent:   ; entry: prom_b routine directory
	ld a, (UiEvent_Byte3:16)                                   ; F8C0D0  c1 ba 20 21
	and A,A                                              ; F8C0D4  c9 c1
	jr z, .LF8C110                                       ; F8C0D6  66 38
	ld w, (UiEvent_Class:16)                                   ; F8C0D8  c1 bb 20 20
	ld XIX,0x00007f27                                    ; F8C0DC  44 27 7f 00 00
	calr .LF8C111                                        ; F8C0E1  1e 2d 00
	cp A,W                                               ; F8C0E4  c8 f1
	jr nz, .LF8C0F6                                      ; F8C0E6  6e 0e
	ld a, (UiEvent_Byte2:16)                                   ; F8C0E8  c1 b9 20 21
	ld (0x216c:16), a                                   ; F8C0EC  f1 6c 21 41
	orw	(0x213a:16), 0x0100                  ; F8C0F0  d1 3a 21 3e 00 01
.LF8C0F6:
	ld XIX,0x00007f28                                    ; F8C0F6  44 28 7f 00 00
	calr .LF8C111                                        ; F8C0FB  1e 13 00
	cp A,W                                               ; F8C0FE  c8 f1
	jr nz, .LF8C110                                      ; F8C100  6e 0e
	ld a, (UiEvent_Byte2:16)                                   ; F8C102  c1 b9 20 21
	ld (0x216d:16), a                                   ; F8C106  f1 6d 21 41
	orw	(0x213a:16), 0x0800                  ; F8C10A  d1 3a 21 3e 00 08
.LF8C110:
	ret                                                  ; F8C110  0e
.LF8C111:
	ld A,(XIX)                                           ; F8C111  84 21
	cp A,0x10                                            ; F8C113  c9 cf 10
	jr nz, .LF8C11C                                      ; F8C116  6e 04
	ld a, 0xb8:opc                                          ; F8C118  21 b8
	jr .LF8C16C                                          ; F8C11A  68 50
.LF8C11C:
	cp A,0x11                                            ; F8C11C  c9 cf 11
	jr nz, .LF8C125                                      ; F8C11F  6e 04
	ld a, 0xb9:opc                                          ; F8C121  21 b9
	jr .LF8C16C                                          ; F8C123  68 47
.LF8C125:
	cp a, 0x02:i3                                          ; F8C125  c9 da
	jr nz, .LF8C12D                                      ; F8C127  6e 04
	ld a, 0xbc:opc                                          ; F8C129  21 bc
	jr .LF8C16C                                          ; F8C12B  68 3f
.LF8C12D:
	cp a, 0x04:i3                                          ; F8C12D  c9 dc
	jr nz, .LF8C135                                      ; F8C12F  6e 04
	ld a, 0xbd:opc                                          ; F8C131  21 bd
	jr .LF8C16C                                          ; F8C133  68 37
.LF8C135:
	cp A,0x0b                                            ; F8C135  c9 cf 0b
	jr nz, .LF8C13E                                      ; F8C138  6e 04
	ld a, 0xb3:opc                                          ; F8C13A  21 b3
	jr .LF8C16C                                          ; F8C13C  68 2e
.LF8C13E:
	cp a, 0x01:i3                                          ; F8C13E  c9 d9
	jr nz, .LF8C146                                      ; F8C140  6e 04
	ld a, 0xb2:opc                                          ; F8C142  21 b2
	jr .LF8C16C                                          ; F8C144  68 26
.LF8C146:
	cp A,0x12                                            ; F8C146  c9 cf 12
	jr nz, .LF8C14F                                      ; F8C149  6e 04
	ld a, 0xba:opc                                          ; F8C14B  21 ba
	jr .LF8C16C                                          ; F8C14D  68 1d
.LF8C14F:
	cp A,0x13                                            ; F8C14F  c9 cf 13
	jr nz, .LF8C158                                      ; F8C152  6e 04
	ld a, 0xbb:opc                                          ; F8C154  21 bb
	jr .LF8C16C                                          ; F8C156  68 14
.LF8C158:
	cp A,0x40                                            ; F8C158  c9 cf 40
	jr nz, .LF8C161                                      ; F8C15B  6e 04
	ld a, 0xb5:opc                                          ; F8C15D  21 b5
	jr .LF8C16C                                          ; F8C15F  68 0b
.LF8C161:
	cp A,0x81                                            ; F8C161  c9 cf 81
	jr nz, .LF8C16A                                      ; F8C164  6e 04
	ld a, 0xb4:opc                                          ; F8C166  21 b4
	jr .LF8C16C                                          ; F8C168  68 02
.LF8C16A:
	ld a, 0xfe:opc                                          ; F8C16A  21 fe
.LF8C16C:
	ret                                                  ; F8C16C  0e
.LF8C16D:
	cp (XIY),0xff                                        ; F8C16D  85 3f ff
	jr z, .LF8C18A                                       ; F8C170  66 18
	cp A,(XIY)                                           ; F8C172  85 f1
	jr z, .LF8C17C                                       ; F8C174  66 06
	add IY,0x0007                                        ; F8C176  dd c8 07 00
	jr .LF8C16D                                          ; F8C17A  68 f1
.LF8C17C:
	ld XIX,(XIY+0x01)                                    ; F8C17C  ad 01 24
	ld HL,(XIY+0x05)                                     ; F8C17F  9d 05 23
	or (XIX),HL                                          ; F8C182  94 eb
	add IY,0x0007                                        ; F8C184  dd c8 07 00
	jr .LF8C16D                                          ; F8C188  68 e3
.LF8C18A:
	ret                                                  ; F8C18A  0e
; PanelLed_ProcessRequests -- run the LED update routines whose request bits are pending
; Evidence: for each of the six words (0x2116),(0x2122),(0x2128),(0x212E),(0x2134),(0x213A): `and` a fixed mask, `and`
;   ~((w+2)|(w+4)), and if non-zero `calr PanelLed_DispatchRequestBits` with its DispatchTable_F8C2B2 sub-list, then
;   clear it.  Called through T_PanelLed_ProcessRequests from the main loop (0xF82154, 0xF8217A), each followed by T_SC1_TxFlush.
PanelLed_ProcessRequests:   ; entry: prom_b routine directory
	andw	(0x2116:16), 0x0e7f                  ; F8C18B  d1 16 21 3c 7f 0e
	ld wa, (0x2118:16)                                 ; F8C191  d1 18 21 20
	or	wa, (0x211a:16)                              ; F8C195  d1 1a 21 e0
	xor WA,0xffff                                        ; F8C199  d8 cd ff ff
	and	(0x2116:16), wa                      ; F8C19D  d1 16 21 c8
	cpw	(0x2116:16), 0x0000                          ; F8C1A1  d1 16 21 3f 00 00
	jr z, .LF8C1BC                                       ; F8C1A7  66 13
	ld XIY,0x00002116                                    ; F8C1A9  45 16 21 00 00
	ld XIX,DispatchTable_F8C2B2                          ; F8C1AE  44 b2 c2 f8 00
	calr PanelLed_DispatchRequestBits                                          ; F8C1B3  1e 74 02
	ldw (0x2116:16), 0x00                                ; F8C1B6  f1 16 21 02 00 00
.LF8C1BC:
	andw	(0x2122:16), 0x0505                  ; F8C1BC  d1 22 21 3c 05 05
	ld wa, (0x2124:16)                                 ; F8C1C2  d1 24 21 20
	or	wa, (0x2126:16)                              ; F8C1C6  d1 26 21 e0
	xor WA,0xffff                                        ; F8C1CA  d8 cd ff ff
	and	(0x2122:16), wa                      ; F8C1CE  d1 22 21 c8
	cpw	(0x2122:16), 0x0000                          ; F8C1D2  d1 22 21 3f 00 00
	jr z, .LF8C1ED                                       ; F8C1D8  66 13
	ld XIY,0x00002122                                    ; F8C1DA  45 22 21 00 00
	ld XIX,DispatchTable_F8C2B2+0x10                     ; F8C1DF  44 c2 c2 f8 00
	calr PanelLed_DispatchRequestBits                                          ; F8C1E4  1e 43 02
	ldw (0x2122:16), 0x00                                ; F8C1E7  f1 22 21 02 00 00
.LF8C1ED:
	andw	(0x2128:16), 0x011f                  ; F8C1ED  d1 28 21 3c 1f 01
	ld wa, (0x212a:16)                                 ; F8C1F3  d1 2a 21 20
	or	wa, (0x212c:16)                              ; F8C1F7  d1 2c 21 e0
	xor WA,0xffff                                        ; F8C1FB  d8 cd ff ff
	and	(0x2128:16), wa                      ; F8C1FF  d1 28 21 c8
	cpw	(0x2128:16), 0x0000                          ; F8C203  d1 28 21 3f 00 00
	jr z, .LF8C21E                                       ; F8C209  66 13
	ld XIY,0x00002128                                    ; F8C20B  45 28 21 00 00
	ld XIX,DispatchTable_F8C2B2+0xE                      ; F8C210  44 c0 c2 f8 00
	calr PanelLed_DispatchRequestBits                                          ; F8C215  1e 12 02
	ldw (0x2128:16), 0x00                                ; F8C218  f1 28 21 02 00 00
.LF8C21E:
	andw	(0x212e:16), 0x0101                  ; F8C21E  d1 2e 21 3c 01 01
	ld wa, (0x2130:16)                                 ; F8C224  d1 30 21 20
	or	wa, (0x2132:16)                              ; F8C228  d1 32 21 e0
	xor WA,0xffff                                        ; F8C22C  d8 cd ff ff
	and	(0x212e:16), wa                      ; F8C230  d1 2e 21 c8
	cpw	(0x212e:16), 0x0000                          ; F8C234  d1 2e 21 3f 00 00
	jr z, .LF8C24F                                       ; F8C23A  66 13
	ld XIY,0x0000212e                                    ; F8C23C  45 2e 21 00 00
	ld XIX,DispatchTable_F8C2B2+0x10                     ; F8C241  44 c2 c2 f8 00
	calr PanelLed_DispatchRequestBits                                          ; F8C246  1e e1 01
	ldw (0x212e:16), 0x00                                ; F8C249  f1 2e 21 02 00 00
.LF8C24F:
	andw	(0x2134:16), 0xedfe                  ; F8C24F  d1 34 21 3c fe ed
	ld wa, (0x2136:16)                                 ; F8C255  d1 36 21 20
	or	wa, (0x2138:16)                              ; F8C259  d1 38 21 e0
	xor WA,0xffff                                        ; F8C25D  d8 cd ff ff
	and	(0x2134:16), wa                      ; F8C261  d1 34 21 c8
	cpw	(0x2134:16), 0x0000                          ; F8C265  d1 34 21 3f 00 00
	jr z, .LF8C280                                       ; F8C26B  66 13
	ld XIY,0x00002134                                    ; F8C26D  45 34 21 00 00
	ld XIX,DispatchTable_F8C2B2+0x12                     ; F8C272  44 c4 c2 f8 00
	calr PanelLed_DispatchRequestBits                                          ; F8C277  1e b0 01
	ldw (0x2134:16), 0x00                                ; F8C27A  f1 34 21 02 00 00
.LF8C280:
	andw	(0x213a:16), 0x0fbf                  ; F8C280  d1 3a 21 3c bf 0f
	ld wa, (0x213c:16)                                 ; F8C286  d1 3c 21 20
	or	wa, (0x213e:16)                              ; F8C28A  d1 3e 21 e0
	xor WA,0xffff                                        ; F8C28E  d8 cd ff ff
	and	(0x213a:16), wa                      ; F8C292  d1 3a 21 c8
	cpw	(0x213a:16), 0x0000                          ; F8C296  d1 3a 21 3f 00 00
	jr z, .LF8C2B1                                       ; F8C29C  66 13
	ld XIY,0x0000213a                                    ; F8C29E  45 3a 21 00 00
	ld XIX,DispatchTable_F8C2B2+0x1A                     ; F8C2A3  44 cc c2 f8 00
	calr PanelLed_DispatchRequestBits                                          ; F8C2A8  1e 7f 01
	ldw (0x213a:16), 0x00                                ; F8C2AB  f1 3a 21 02 00 00
.LF8C2B1:
	ret                                                  ; F8C2B1  0e
; ---------------------------------------------------------------------
; DispatchTable_F8C2B2 -- 58 bytes.  Variable-length: a 2-byte id, then either
; a 2-byte placeholder (id == 0xFFFF) or a 4-byte little-endian pointer.
; 8 non-placeholder pointers, ALL landing inside the two neighbouring
; still-.incbin spans 0xF8C485-0xF8C630 and 0xF8C652-0xF8C842 (two of
; them are those spans' own START addresses) -- neither neighbour is
; converted this pass, see notes/FINDINGS-prom_a-f8c000-cluster.md.
; ---------------------------------------------------------------------
DispatchTable_F8C2B2:
	.byte 0x04, 0x00, 0x85, 0xc4, 0xf8, 0x00  ; F8C2B2  id=0x0004 ptr=0x00f8c485
	.byte 0x40, 0x00, 0xd8, 0xc4, 0xf8, 0x00  ; F8C2B8  id=0x0040 ptr=0x00f8c4d8
	.byte 0xff, 0xff  ; F8C2BE  placeholder
	.byte 0xff, 0xff  ; F8C2C0  placeholder
	.byte 0xff, 0xff  ; F8C2C2  placeholder
	.byte 0x02, 0x00, 0x07, 0xc7, 0xf8, 0x00  ; F8C2C4  id=0x0002 ptr=0x00f8c707
	.byte 0xff, 0xff  ; F8C2CA  placeholder
	.byte 0x00, 0x01, 0x96, 0xc5, 0xf8, 0x00  ; F8C2CC  id=0x0100 ptr=0x00f8c596
	.byte 0x00, 0x08, 0xe3, 0xc5, 0xf8, 0x00  ; F8C2D2  id=0x0800 ptr=0x00f8c5e3
	.byte 0x80, 0x00, 0x52, 0xc6, 0xf8, 0x00  ; F8C2D8  id=0x0080 ptr=0x00f8c652
	.byte 0x00, 0x02, 0x7d, 0xc7, 0xf8, 0x00  ; F8C2DE  id=0x0200 ptr=0x00f8c77d
	.byte 0x00, 0x04, 0xac, 0xc7, 0xf8, 0x00  ; F8C2E4  id=0x0400 ptr=0x00f8c7ac
	.byte 0xff, 0xff  ; F8C2EA  placeholder
.LF8C2EC:
; PanelLed_RequestIfBlinkEnableChanged -- request PanelLed_ShowBlinkEnable when its LED disagrees with (0x2075) bit 1
; Evidence: v1: (0x2075)&2 xor (0x20D5) bit 1 differs -> or (0x213A),0x0200 and (0x2116),0x0004; v2: unless (0x216F)
;   bit 0, ((0x2075)&2)<<2 xor (0x20D6) bit 3 differs -> or (0x213A),0x0200.  Bit 1 of (0x2075) is the field-blink
;   enable (FINDINGS-prom_b-field-blink.md).  Called by PanelLed_Refresh.
PanelLed_RequestIfBlinkEnableChanged:   ; entry: reachable-run entry
	cp	(Variant_Flag:8), 0x02                               ; F8C2EC  c0 c4 3f 02
	jr z, .LF8C314                                       ; F8C2F0  66 22
	ld XIX,PanelLed_Shadow                                    ; F8C2F2  44 d0 20 00 00
	ld a, (UI_RequestBits:16)                                   ; F8C2F7  c1 75 20 21
	and A,0x02                                           ; F8C2FB  c9 cc 02
	xor A,(XIX+0x05)                                     ; F8C2FE  8c 05 d1
	bit 0x01,A                                           ; F8C301  c9 33 01
	jr z, .LF8C337                                       ; F8C304  66 31
	orw	(0x213a:16), 0x0200                  ; F8C306  d1 3a 21 3e 00 02
	orw	(0x2116:16), 0x0004                  ; F8C30C  d1 16 21 3e 04 00
	jr .LF8C337                                          ; F8C312  68 23
.LF8C314:
	bit	0, (MIDI_ActivityFlags:16)                               ; F8C314  f1 6f 21 c8
	jr nz, .LF8C337                                      ; F8C318  6e 1d
	ld XIX,PanelLed_Shadow                                    ; F8C31A  44 d0 20 00 00
	ld a, (UI_RequestBits:16)                                   ; F8C31F  c1 75 20 21
	and A,0x02                                           ; F8C323  c9 cc 02
	sla a, 0x02                                          ; F8C326  c9 ec 02
	xor A,(XIX+0x06)                                     ; F8C329  8c 06 d1
	bit 0x03,A                                           ; F8C32C  c9 33 03
	jr z, .LF8C337                                       ; F8C32F  66 06
	orw	(0x213a:16), 0x0200                  ; F8C331  d1 3a 21 3e 00 02
.LF8C337:
	ret                                                  ; F8C337  0e
; PanelLed_Refresh -- periodic LED pass: check the blink LED, then send every LED byte that changed
; Evidence: called via T_PanelLed_Refresh from the main loop (0xF820A5, tick bit 1 of (0x88)).  calr
;   PanelLed_RequestIfBlinkEnableChanged; ands the six second words (0x2118..0x213C) with the same masks as
;   PanelLed_ProcessRequests (the dispatch it then runs uses 0xF8C428, which is an immediate 0xFFFF terminator);
;   .LF8C3E4 toggles (0x20D6) bit 3 when (0x216F) bit 0 is set (not on v1); finally calr PanelLed_SendChangedBytes.
PanelLed_Refresh:   ; entry: prom_b routine directory
	calr .LF8C2EC                                        ; F8C338  1e b1 ff
	andw	(0x2118:16), 0x0e7f                  ; F8C33B  d1 18 21 3c 7f 0e
	cpw	(0x2118:16), 0x0000                          ; F8C341  d1 18 21 3f 00 00
	jr z, .LF8C356                                       ; F8C347  66 0d
	ld XIY,0x00002118                                    ; F8C349  45 18 21 00 00
	ld XIX,PanelLed_ToggleActivityLed_Data_F8C428                                    ; F8C34E  44 28 c4 f8 00
	calr PanelLed_DispatchRequestBits                                            ; F8C353  1e d4 00
.LF8C356:
	andw	(0x2124:16), 0x0505                  ; F8C356  d1 24 21 3c 05 05
	cpw	(0x2124:16), 0x0000                          ; F8C35C  d1 24 21 3f 00 00
	jr z, .LF8C371                                       ; F8C362  66 0d
	ld XIY,0x00002124                                    ; F8C364  45 24 21 00 00
	ld XIX,PanelLed_ToggleActivityLed_Data_F8C428                                    ; F8C369  44 28 c4 f8 00
	calr PanelLed_DispatchRequestBits                                            ; F8C36E  1e b9 00
.LF8C371:
	andw	(0x212a:16), 0x011f                  ; F8C371  d1 2a 21 3c 1f 01
	cpw	(0x212a:16), 0x0000                          ; F8C377  d1 2a 21 3f 00 00
	jr z, .LF8C38C                                       ; F8C37D  66 0d
	ld XIY,0x0000212a                                    ; F8C37F  45 2a 21 00 00
	ld XIX,PanelLed_ToggleActivityLed_Data_F8C428                                    ; F8C384  44 28 c4 f8 00
	calr PanelLed_DispatchRequestBits                                            ; F8C389  1e 9e 00
.LF8C38C:
	andw	(0x2130:16), 0x0101                  ; F8C38C  d1 30 21 3c 01 01
	cpw	(0x2130:16), 0x0000                          ; F8C392  d1 30 21 3f 00 00
	jr z, .LF8C3A7                                       ; F8C398  66 0d
	ld XIY,0x00002130                                    ; F8C39A  45 30 21 00 00
	ld XIX,PanelLed_ToggleActivityLed_Data_F8C428                                    ; F8C39F  44 28 c4 f8 00
	calr PanelLed_DispatchRequestBits                                            ; F8C3A4  1e 83 00
.LF8C3A7:
	andw	(0x2136:16), 0xedfe                  ; F8C3A7  d1 36 21 3c fe ed
	cpw	(0x2136:16), 0x0000                          ; F8C3AD  d1 36 21 3f 00 00
	jr z, .LF8C3C2                                       ; F8C3B3  66 0d
	ld XIY,0x00002136                                    ; F8C3B5  45 36 21 00 00
	ld XIX,PanelLed_ToggleActivityLed_Data_F8C428                                    ; F8C3BA  44 28 c4 f8 00
	calr PanelLed_DispatchRequestBits                                            ; F8C3BF  1e 68 00
.LF8C3C2:
	andw	(0x213c:16), 0x0fbf                  ; F8C3C2  d1 3c 21 3c bf 0f
	cpw	(0x213c:16), 0x0000                          ; F8C3C8  d1 3c 21 3f 00 00
	jr z, .LF8C3DD                                       ; F8C3CE  66 0d
	ld XIY,0x0000213c                                    ; F8C3D0  45 3c 21 00 00
	ld XIX,PanelLed_ToggleActivityLed_Data_F8C428                                    ; F8C3D5  44 28 c4 f8 00
	calr PanelLed_DispatchRequestBits                                            ; F8C3DA  1e 4d 00
.LF8C3DD:
	calr .LF8C3E4                                        ; F8C3DD  1e 04 00
	calr PanelLed_SendChangedBytes                                            ; F8C3E0  1e 73 00
	ret                                                  ; F8C3E3  0e
.LF8C3E4:
	cp	(Variant_Flag:8), 0x01                               ; F8C3E4  c0 c4 3f 01
	jr z, .LF8C3FA                                       ; F8C3E8  66 10
	ld XIX,MIDI_ActivityFlags                                    ; F8C3EA  44 6f 21 00 00
	bit 0,(XIX)                                          ; F8C3EF  b4 c8
	jr z, .LF8C3FA                                       ; F8C3F1  66 07
	xor	(PanelLed_Shadow+6:16), 0x08                            ; F8C3F3  c1 d6 20 3d 08
	res 0,(XIX)                                          ; F8C3F8  b4 b0
.LF8C3FA:
	ret                                                  ; F8C3FA  0e
; PanelLed_ToggleActivityLed -- flip LED byte 6 bit 3 and send it immediately (not on variant 1)
; Evidence: `cp (0xC4),0x01 / jr z,ret`; (0x2170) counter; `xor (0x20D6),0x08`, (0x20F6) = (0x20D6) so
;   PanelLed_SendChangedBytes will not resend it, W = 6 and `calr .LF8C84A`, then T_SC1_TxFlush.  Published as
;   T_PanelLed_ToggleActivityLed; callers PanelLed_ToggleActivityLed_SaveRegs (called inside the foreground MIDI consumer 0xFA5942-0xFA5AEA before a MIDI message
;   is built) and PanelLed_ToggleActivityLed_SaveRegs2.  ⚠ PanelLed_ToggleActivityLed_SaveRegs's header guesses "buffer initialiser"; this is what it really calls.
PanelLed_ToggleActivityLed:   ; entry: prom_b routine directory
	cp	(Variant_Flag:8), 0x01                               ; F8C3FB  c0 c4 3f 01
	jr z, .LF8C427                                       ; F8C3FF  66 26
	ld XIX,0x00002170                                    ; F8C401  44 70 21 00 00
	incm8 0x01, (xix)                                    ; F8C406  84 61
	cp (XIX),0x01                                        ; F8C408  84 3f 01
	jr c, .LF8C427                                       ; F8C40B  67 1a
	ld XIY,PanelLed_Shadow+6                                    ; F8C40D  45 d6 20 00 00
	ld w, 0x06:opc                                          ; F8C412  20 06
	xor	(xiy), 0x08                                  ; F8C414  85 3d 08
	ld A,(XIY)                                           ; F8C417  85 21
	ld (PanelLed_Sent+6:16), a                                   ; F8C419  f1 f6 20 41
	ld (XIX),0x00                                        ; F8C41D  b4 00 00
	calr .LF8C84A                                          ; F8C420  1e 27 04
	call T_SC1_TxFlush                                   ; F8C423  1d 08 0f f4
.LF8C427:
	ret                                                  ; F8C427  0e
; 0xF8C428-0xF8C429 -- 2 bytes of 0xFF (erased-flash pad) between PanelLed_ToggleActivityLed's
; `ret` and PanelLed_DispatchRequestBits.  Too short for gen_prom_a_block.py's pad_runs() (MIN_PAD
; 32) to catch, and it is not a uniform-0x0E run either, so it is typed by hand.
PanelLed_ToggleActivityLed_Data_F8C428:
	.byte 0xff, 0xff                                     ; F8C428  ff ff
; PanelLed_DispatchRequestBits -- call the handler of every request bit set in the word at (XIY)
; Evidence: WA = (XIY); per 6-byte record `cp (XIX+HL),0xffff` ends, `ld BC,(XIX+HL) / and BC,WA`, non-zero -> `ld
;   XIX,(XIX+HL+2) / call (xix)` (0xF8C42A-0xF8C44A).  Fed DispatchTable_F8C2B2 sub-lists by PanelLed_ProcessRequests
;   and the empty list 0xF8C428 by PanelLed_Refresh.
PanelLed_DispatchRequestBits:   ; entry: reachable-run entry
	xor HL,HL                                            ; F8C42A  db d3
	ld WA,(XIY)                                          ; F8C42C  95 20
.LF8C42E:
	cpw	(xix+hl), 0xffff                     ; F8C42E  d3 07 f0 ec 3f ff ff
	jr z, .LF8C455                                       ; F8C435  66 1e
	ld	bc, (xix+hl)                                 ; F8C437  d3 07 f0 ec 21
	and BC,WA                                            ; F8C43C  d8 c1
	jr z, .LF8C44F                                       ; F8C43E  66 0f
	push XIX                                             ; F8C440  3c
	push XHL                                             ; F8C441  3b
	pushw wa                                             ; F8C442  28
	inc 2,XIX                                            ; F8C443  ec 62
	ld	xix, (xix+hl)                                ; F8C445  e3 07 f0 ec 24
	call (xix)                                           ; F8C44A  b4 e8
	popw wa                                              ; F8C44C  48
	pop XHL                                              ; F8C44D  5b
	pop XIX                                              ; F8C44E  5c
.LF8C44F:
	add HL,0x0006                                        ; F8C44F  db c8 06 00
	jr .LF8C42E                                          ; F8C453  68 d9
.LF8C455:
	ret                                                  ; F8C455  0e
; PanelLed_SendChangedBytes -- send each LED shadow byte that differs from the copy last sent
; Evidence: B = 8, XIY = 0x20D0, XIX = 0x20F0; on a mismatch `ld (XIX),A`, W = 8 - B (the byte index 0..7) and `calr
;   .LF8C84A`, which maps W through PanelLedWireMap_Variant1/2 and queues [wire][A] in the SC1 ring at 0x2BA0. Called
;   by PanelLed_Refresh.
PanelLed_SendChangedBytes:
	ld b, 0x08:opc                                          ; F8C456  22 08
	ld XIY,PanelLed_Shadow                                    ; F8C458  45 d0 20 00 00
	ld XIX,PanelLed_Sent                                    ; F8C45D  44 f0 20 00 00
.LF8C462:
	ld A,(XIY)                                           ; F8C462  85 21
	cp A,(XIX)                                           ; F8C464  84 f1
	jr nz, .LF8C471                                      ; F8C466  6e 09
	inc 1,XIY                                            ; F8C468  ed 61
	inc 1,XIX                                            ; F8C46A  ec 61
	djnz8 b, .LF8C462                                    ; F8C46C  ca 1c f3
	jr .LF8C484                                          ; F8C46F  68 13
.LF8C471:
	ld (XIX),A                                           ; F8C471  b4 41
	ld w, 0x08:opc                                          ; F8C473  20 08
	sub W,B                                              ; F8C475  ca a0
	push B                                               ; F8C477  ca 04
	push XIY                                             ; F8C479  3d
	push XIX                                             ; F8C47A  3c
	calr .LF8C84A                                          ; F8C47B  1e cc 03
	pop XIX                                              ; F8C47E  5c
	pop XIY                                              ; F8C47F  5d
	pop B                                                ; F8C480  ca 05
	jr .LF8C462                                          ; F8C482  68 de
.LF8C484:
	ret                                                  ; F8C484  0e
; ---------------------------------------------------------------------
; 0xF8C485-0xF8C630 (427 B) -- CONVERTED, see
; notes/FINDINGS-prom_a-f8c485-boundary.md.  Five short bit-set/clear
; routines reached by DispatchTable_F8C2B2 (already committed, above),
; three small data tables pinned by their own readers' index ranges.
; ---------------------------------------------------------------------
; PanelLed_ShowSoundSelect -- light the LED of the current sound-select button (variant 1 only)
; Evidence: DispatchTable_F8C2B2 id 0x0004.  `cp (0xC4),2 / jr z,ret`; (0x20D1) = (0x20D0) = 0; with (0x2075) bit 1
;   clear, WA = BitmaskTable_F8C4B8[(0x2169) & 0x0F] and `or (XIX+A),W` -- byte 1 bit n for 0-7, byte 0 bit n-8 for
;   8-15.  (0x2169) is the 0..15 sound-select index PanelAction_SoundSelectOrKeypad_V1 stores.
PanelLed_ShowSoundSelect:   ; entry: DispatchTable_F8C2B2 id=0x0004
	cp	(Variant_Flag:8), 0x02                       ; F8C485  c0 c4 3f 02
	jr z, .LF8C4B7                                ; F8C489  66 2c
	ld XIX,PanelLed_Shadow                             ; F8C48B  44 d0 20 00 00
	and (XIX+0x01),0x00                           ; F8C490  8c 01 3c 00
	and8_imm_rid8 xix, 0x00, 0x00                 ; F8C494  8c 00 3c 00   and (XIX+0x00),0x00
	bit	1, (UI_RequestBits:16)                       ; F8C498  f1 75 20 c9
	jr nz, .LF8C4B7                               ; F8C49C  6e 19
	ld a, (SoundSel_Group:16)                            ; F8C49E  c1 69 21 21
	and A,0x0f                                    ; F8C4A2  c9 cc 0f
	sla a, 0x01                                   ; F8C4A5  c9 ec 01
	ld XIY,BitmaskTable_F8C4B8                    ; F8C4A8  45 b8 c4 f8 00
	ld	wa, (xiy+a)                            ; F8C4AD  d3 03 f4 e0 20
	.byte 0xc3, 0x03, 0xf0, 0xe0, 0xe8            ; F8C4B2  c3 03 f0 e0 e8
.LF8C4B7:
	ret                                           ; F8C4B7  0e
BitmaskTable_F8C4B8:   ; 32 B, 16 words, read via (nibble<<1) index
	.short 0x0101, 0x0201, 0x0401, 0x0801, 0x1001, 0x2001, 0x4001, 0x8001  ; F8C4B8
	.short 0x0100, 0x0200, 0x0400, 0x0800, 0x1000, 0x2000, 0x4000, 0x8000  ; F8C4C8
; PanelLed_ShowBank -- light the BANK LEDs (USER 1 / USER 2 / ROM-EXT, RE-MAP) for the bank in (0x216A)
; Evidence: DispatchTable_F8C2B2 id 0x0040.  v1: (0x20D2) &= 0x0F then 0x08/0x28 -> 0x10, 0x09/0x29 -> 0x20, other ->
;   0x40, 0x18-0x1A -> BucketTable_F8C536 | 0x80; v2 (.LF8C53A): (0x20D0) &= 0xF0 with 0x01/0x02/0x04 and | 0x08.  The
;   buckets are PanelAction_BankButton's bank values, and RE-MAP's 0x18-0x1A.
PanelLed_ShowBank:   ; entry: DispatchTable_F8C2B2 id=0x0040
	.byte 0xc0, 0xc4, 0x3f, 0x02                  ; F8C4D8  c0 c4 3f 02
	jr z, .LF8C53A                                    ; F8C4DC  66 5c
	ld XIX,PanelLed_Shadow                             ; F8C4DE  44 d0 20 00 00
	and (XIX+0x02),0x0f                           ; F8C4E3  8c 02 3c 0f
	ld a, (SoundSel_Bank:16)                            ; F8C4E7  c1 6a 21 21
	and A,0x3f                                    ; F8C4EB  c9 cc 3f
	cp A,0x18                                     ; F8C4EE  c9 cf 18
	jr c, .LF8C50C                                ; F8C4F1  67 19
	cp A,0x1a                                     ; F8C4F3  c9 cf 1a
	jr ugt, .LF8C50C                              ; F8C4F6  6b 14
	sub A,0x18                                    ; F8C4F8  c9 ca 18
	extz WA                                       ; F8C4FB  d8 12
	extz XWA                                      ; F8C4FD  e8 12
	add XWA,BucketTable_F8C536                    ; F8C4FF  e8 c8 36 c5 f8 00
	ld A,(XWA)                                    ; F8C505  80 21
	or A,0x80                                     ; F8C507  c9 ce 80
	jr .LF8C532                                   ; F8C50A  68 26
.LF8C50C:
	cp A,0x08                                     ; F8C50C  c9 cf 08
	jr nz, .LF8C515                               ; F8C50F  6e 04
	ld a, 0x10:opc                                   ; F8C511  21 10
	jr .LF8C532                                   ; F8C513  68 1d
.LF8C515:
	cp A,0x28                                     ; F8C515  c9 cf 28
	jr nz, .LF8C51E                               ; F8C518  6e 04
	ld a, 0x10:opc                                   ; F8C51A  21 10
	jr .LF8C532                                   ; F8C51C  68 14
.LF8C51E:
	cp A,0x09                                     ; F8C51E  c9 cf 09
	jr nz, .LF8C527                               ; F8C521  6e 04
	ld a, 0x20:opc                                   ; F8C523  21 20
	jr .LF8C532                                   ; F8C525  68 0b
.LF8C527:
	cp A,0x29                                     ; F8C527  c9 cf 29
	jr nz, .LF8C530                               ; F8C52A  6e 04
	ld a, 0x20:opc                                   ; F8C52C  21 20
	jr .LF8C532                                   ; F8C52E  68 02
.LF8C530:
	ld a, 0x40:opc                                   ; F8C530  21 40
.LF8C532:
	or (XIX+0x02),A                               ; F8C532  8c 02 e9
	ret                                           ; F8C535  0e
BucketTable_F8C536:   ; 3 entries (index 0-2) + 1 pad byte duplicating the last entry
	.byte 0x10, 0x20, 0x40, 0x40   ; F8C536
.LF8C53A:   ; internal only -- reached by PanelLed_ShowBank's own jr z
	ld XIX,PanelLed_Shadow                             ; F8C53A  44 d0 20 00 00
	and8_imm_rid8 xix, 0x00, 0xf0                 ; F8C53F  8c 00 3c f0   and (XIX+0x00),0xf0
	ld a, (SoundSel_Bank:16)                            ; F8C543  c1 6a 21 21
	and A,0x3f                                    ; F8C547  c9 cc 3f
	cp A,0x18                                     ; F8C54A  c9 cf 18
	jr c, .LF8C568                                ; F8C54D  67 19
	cp A,0x1a                                     ; F8C54F  c9 cf 1a
	jr ugt, .LF8C568                              ; F8C552  6b 14
	sub A,0x18                                    ; F8C554  c9 ca 18
	extz WA                                       ; F8C557  d8 12
	extz XWA                                      ; F8C559  e8 12
	add XWA,BucketTable_F8C592                    ; F8C55B  e8 c8 92 c5 f8 00
	ld A,(XWA)                                    ; F8C561  80 21
	or A,0x08                                     ; F8C563  c9 ce 08
	jr .LF8C58E                                   ; F8C566  68 26
.LF8C568:
	cp A,0x08                                     ; F8C568  c9 cf 08
	jr nz, .LF8C571                               ; F8C56B  6e 04
	ld a, 0x01:opc                                   ; F8C56D  21 01
	jr .LF8C58E                                   ; F8C56F  68 1d
.LF8C571:
	cp A,0x28                                     ; F8C571  c9 cf 28
	jr nz, .LF8C57A                               ; F8C574  6e 04
	ld a, 0x01:opc                                   ; F8C576  21 01
	jr .LF8C58E                                   ; F8C578  68 14
.LF8C57A:
	cp A,0x09                                     ; F8C57A  c9 cf 09
	jr nz, .LF8C583                               ; F8C57D  6e 04
	ld a, 0x02:opc                                   ; F8C57F  21 02
	jr .LF8C58E                                   ; F8C581  68 0b
.LF8C583:
	cp A,0x29                                     ; F8C583  c9 cf 29
	jr nz, .LF8C58C                               ; F8C586  6e 04
	ld a, 0x02:opc                                   ; F8C588  21 02
	jr .LF8C58E                                   ; F8C58A  68 02
.LF8C58C:
	ld a, 0x04:opc                                   ; F8C58C  21 04
.LF8C58E:
	or (xix+0:8), a                            ; F8C58E  8c 00 e9
	ret                                           ; F8C591  0e
BucketTable_F8C592:   ; 3 entries (index 0-2) + 1 pad byte duplicating the last entry
	.byte 0x01, 0x02, 0x04, 0x04   ; F8C592
; PanelLed_ShowCtrl1Offset -- show which side of centre (0x40) assignable controller 1 sits
; Evidence: DispatchTable_F8C2B2 id 0x0100.  A = (0x216C) & 0x7F (stored by PanelLed_OnCtrlParamEvent for the (0x7F27)
;   assignment); A > 0x40 lights v1 (0x20D3) bit 6 / v2 (0x20D2) bit 0, A < 0x40 lights v1 (0x20D6) bit 0 / v2
;   (0x20D3) bit 0, 0x40 leaves both off.
PanelLed_ShowCtrl1Offset:   ; entry: DispatchTable_F8C2B2 id=0x0100
	ld XIX,PanelLed_Shadow                             ; F8C596  44 d0 20 00 00
	cp	(Variant_Flag:8), 0x02                       ; F8C59B  c0 c4 3f 02
	jr z, .LF8C5C2                                ; F8C59F  66 21
	and (XIX+0x03),0xbf                           ; F8C5A1  8c 03 3c bf
	and (XIX+0x06),0xfe                           ; F8C5A5  8c 06 3c fe
	ld a, (0x216c:16)                            ; F8C5A9  c1 6c 21 21
	and A,0x7f                                    ; F8C5AD  c9 cc 7f
	cp A,0x40                                     ; F8C5B0  c9 cf 40
	jr z, .LF8C5C1                                ; F8C5B3  66 0c
	jr c, .LF8C5BD                                ; F8C5B5  67 06
	or (XIX+0x03),0x40                            ; F8C5B7  8c 03 3e 40
	jr .LF8C5C1                                   ; F8C5BB  68 04
.LF8C5BD:
	or (XIX+0x06),0x01                            ; F8C5BD  8c 06 3e 01
.LF8C5C1:
	ret                                           ; F8C5C1  0e
.LF8C5C2:
	and (XIX+0x02),0xfe                           ; F8C5C2  8c 02 3c fe
	and (XIX+0x03),0xfe                           ; F8C5C6  8c 03 3c fe
	ld a, (0x216c:16)                            ; F8C5CA  c1 6c 21 21
	and A,0x7f                                    ; F8C5CE  c9 cc 7f
	cp A,0x40                                     ; F8C5D1  c9 cf 40
	jr z, .LF8C5E2                                ; F8C5D4  66 0c
	jr c, .LF8C5DE                                ; F8C5D6  67 06
	or (XIX+0x02),0x01                            ; F8C5D8  8c 02 3e 01
	jr .LF8C5E2                                   ; F8C5DC  68 04
.LF8C5DE:
	or (XIX+0x03),0x01                            ; F8C5DE  8c 03 3e 01
.LF8C5E2:
	ret                                           ; F8C5E2  0e
; PanelLed_ShowCtrl2Offset -- show which side of centre (0x40) assignable controller 2 sits
; Evidence: DispatchTable_F8C2B2 id 0x0800.  Same shape as PanelLed_ShowCtrl1Offset on (0x216D) (the (0x7F28)
;   assignment): above -> v1 (0x20D3) bit 7 / v2 (0x20D2) bit 1, below -> v1 (0x20D6) bit 1 / v2 (0x20D3) bit 1.
PanelLed_ShowCtrl2Offset:   ; entry: DispatchTable_F8C2B2 id=0x0800
	ld XIX,PanelLed_Shadow                             ; F8C5E3  44 d0 20 00 00
	cp	(Variant_Flag:8), 0x02                       ; F8C5E8  c0 c4 3f 02
	jr z, .LF8C60F                                ; F8C5EC  66 21
	and (XIX+0x03),0x7f                           ; F8C5EE  8c 03 3c 7f
	and (XIX+0x06),0xfd                           ; F8C5F2  8c 06 3c fd
	ld a, (0x216d:16)                            ; F8C5F6  c1 6d 21 21
	and A,0x7f                                    ; F8C5FA  c9 cc 7f
	cp A,0x40                                     ; F8C5FD  c9 cf 40
	jr z, .LF8C60E                                ; F8C600  66 0c
	jr c, .LF8C60A                                ; F8C602  67 06
	or (XIX+0x03),0x80                            ; F8C604  8c 03 3e 80
	jr .LF8C60E                                   ; F8C608  68 04
.LF8C60A:
	or (XIX+0x06),0x02                            ; F8C60A  8c 06 3e 02
.LF8C60E:
	ret                                           ; F8C60E  0e
.LF8C60F:
	and (XIX+0x02),0xfd                           ; F8C60F  8c 02 3c fd
	and (XIX+0x03),0xfd                           ; F8C613  8c 03 3c fd
	ld a, (0x216d:16)                            ; F8C617  c1 6d 21 21
	and A,0x7f                                    ; F8C61B  c9 cc 7f
	cp A,0x40                                     ; F8C61E  c9 cf 40
	jr z, .LF8C62F                                ; F8C621  66 0c
	jr c, .LF8C62B                                ; F8C623  67 06
	or (XIX+0x02),0x02                            ; F8C625  8c 02 3e 02
	jr .LF8C62F                                   ; F8C629  68 04
.LF8C62B:
	or (XIX+0x03),0x02                            ; F8C62B  8c 03 3e 02
.LF8C62F:
	ret                                           ; F8C62F  0e
; PanelLed_ClearCtrlOffsetLeds -- turn off both assignable controllers' offset LEDs
; Evidence: v1 `and (0x20D3),0x3f / and (0x20D6),0xfc`, v2 `and (0x20D2),0xfc / and (0x20D3),0xfc` -- exactly the bits
;   PanelLed_ShowCtrl1Offset/_ShowCtrl2Offset set.  Called by PanelLed_OnPartEvent and PanelLed_OnClass90Event.
PanelLed_ClearCtrlOffsetLeds:   ; entry: reachable-run entry
	cp	(Variant_Flag:8), 0x02                               ; F8C630  c0 c4 3f 02
	jr z, .LF8C644                                       ; F8C634  66 0e
	ld XIX,PanelLed_Shadow                                    ; F8C636  44 d0 20 00 00
	and (XIX+0x03),0x3f                                  ; F8C63B  8c 03 3c 3f
	and (XIX+0x06),0xfc                                  ; F8C63F  8c 06 3c fc
	ret                                                  ; F8C643  0e
.LF8C644:
	ld XIX,PanelLed_Shadow                                    ; F8C644  44 d0 20 00 00
	and (XIX+0x02),0xfc                                  ; F8C649  8c 02 3c fc
	and (XIX+0x03),0xfc                                  ; F8C64D  8c 03 3c fc
	ret                                                  ; F8C651  0e
; ---------------------------------------------------------------------
; 0xF8C652-0xF8C842 (496 B) -- CONVERTED, see
; notes/FINDINGS-prom_a-f8c652-boundary.md.  Four short routines reached
; by DispatchTable_F8C2B2 and a shared record-parser, three data tables
; pinned by their own readers -- the naive decode's 8-undecodable-byte
; count only caught the first of these three.
; ---------------------------------------------------------------------
; PanelLed_ShowSixWaySelect -- show the current part's six-way selection on LED byte 3 bits 0-5 (variant 1 only)
; Evidence: DispatchTable_F8C2B2 id 0x0080.  (0x20D3) &= 0xC0, then the part record via PointerTable_F8C687[(0x2250)]:
;   W = (+0x19) & 0x3F, or (+0x1A) when bit 0 of (+0x18) -- record+0x38..0x3A, the bytes and mode bit the action
;   handler sub_F8AA24 uses to pick event code 0x19/0x1A for v1 group 0x08's six switches.
; Unknown: what the two six-way settings are.
PanelLed_ShowSixWaySelect:   ; entry: DispatchTable_F8C2B2 id=0x0080
	cp	(Variant_Flag:8), 0x02                       ; F8C652  c0 c4 3f 02
	jr z, .LF8C686                                ; F8C656  66 2e
	ld XIX,PanelLed_Shadow                             ; F8C658  44 d0 20 00 00
	and (XIX+0x03),0xc0                           ; F8C65D  8c 03 3c c0
	ld XIY,PointerTable_F8C687                    ; F8C661  45 87 c6 f8 00
	ld a, (UI_PartIndex:16)                            ; F8C666  c1 50 22 21
	sla a, 0x02                                   ; F8C66A  c9 ec 02
	ld	xiy, (xiy+a)                           ; F8C66D  e3 03 f4 e0 25
	ld W,(XIY+0x19)                               ; F8C672  8d 19 20
	and W,0x3f                                    ; F8C675  c8 cc 3f
	bit 0,(XIY+0x18)                              ; F8C678  bd 18 c8
	jr z, .LF8C683                                ; F8C67B  66 06
	ld W,(XIY+0x1a)                               ; F8C67D  8d 1a 20
	and W,0x3f                                    ; F8C680  c8 cc 3f
.LF8C683:
	or (XIX+0x03),W                               ; F8C683  8c 03 e8
.LF8C686:
	ret                                           ; F8C686  0e
PointerTable_F8C687:   ; 128 B, 32 longs, +0x40 arithmetic progression, read via (5-bit index)*4
	.long 0x000076c2, 0x00007702, 0x00007742, 0x00007782   ; F8C687
	.long 0x000077c2, 0x00007802, 0x00007842, 0x00007882   ; F8C697
	.long 0x00007902, 0x00007942, 0x00007982, 0x000079c2   ; F8C6A7
	.long 0x00007a02, 0x00007a42, 0x00007a82, 0x00007ac2   ; F8C6B7
	.long 0x00007b02, 0x00007b42, 0x00007b82, 0x00007bc2   ; F8C6C7
	.long 0x00007c02, 0x00007c42, 0x00007c82, 0x00007cc2   ; F8C6D7
	.long 0x00007d02, 0x00007d42, 0x00007d82, 0x00007dc2   ; F8C6E7
	.long 0x00007e02, 0x00007e42, 0x00007e82, 0x00007ec2   ; F8C6F7
; PanelLed_ShowModeMenu -- light the PLAY/EDIT MODE or MENU button LED for the current mode (0x2076)
; Evidence: DispatchTable_F8C2B2 id 0x0002.  Clears the mode LED bits, then the shared scan .LF8C7F9 finds (0x2076) in
;   RecordTable_F8C727 (v1) / _F8C764 (v2) and ORs [byte][bit] into 0x20D0+.  v2 keys 0x01 0x02 0x17 0x16 (byte 1 bits
;   0-3) are PanelOrdinalToEventValue_B[1..4] = seg 0 bits 0-3 PLAY SOUND/COMBI, EDIT SOUND/COMBI; 0x09 0x0A 0x12 0x15
;   (bytes 4,5) are _A[1..4] = seg 7 MENU PART/SYSTEM/MIDI/DISK (wave7_panel_button_codes.py).
PanelLed_ShowModeMenu:   ; entry: DispatchTable_F8C2B2 id=0x0002
	.byte 0xc0, 0xc4, 0x3f, 0x02                  ; F8C707  c0 c4 3f 02
	jr z, RecordTable_F8C727_Code_Skip                                    ; F8C70B  66 39
	ld XIX,PanelLed_Shadow                             ; F8C70D  44 d0 20 00 00
	and (XIX+0x02),0xf0                           ; F8C712  8c 02 3c f0
	and (XIX+0x04),0xc0                           ; F8C716  8c 04 3c c0
	ld a, (PanelModeGroup:16)                            ; F8C71A  c1 76 20 21
	ld XIY,RecordTable_F8C727                     ; F8C71E  45 27 c7 f8 00
	calr .LF8C7F9                                     ; F8C723  1e d3 00
	ret                                           ; F8C726  0e
RecordTable_F8C727:   ; 10 x [key,val_lo,val_hi] + 0xFF terminator, read by sub_F8C7F9's shared linear scan
	.byte 0x01, 0x02, 0x01, 0x02, 0x02, 0x02, 0x17, 0x02, 0x04, 0x16, 0x02, 0x08, 0x09, 0x04, 0x01, 0x0a, 0x04, 0x02, 0x12, 0x04, 0x04, 0x15, 0x04, 0x08, 0x08, 0x04, 0x10, 0x03, 0x04, 0x20, 0xff   ; F8C727
RecordTable_F8C727_Code_Skip:
	ld XIX,PanelLed_Shadow                             ; F8C746  44 d0 20 00 00
	and (XIX+0x01),0xf0                           ; F8C74B  8c 01 3c f0
	and (XIX+0x04),0xfc                           ; F8C74F  8c 04 3c fc
	and (XIX+0x05),0xfc                           ; F8C753  8c 05 3c fc
	ld a, (PanelModeGroup:16)                            ; F8C757  c1 76 20 21
	ld XIY,RecordTable_F8C764                     ; F8C75B  45 64 c7 f8 00
	calr .LF8C7F9                                     ; F8C760  1e 96 00
	ret                                           ; F8C763  0e
RecordTable_F8C764:   ; 8 x [key,val_lo,val_hi] + 0xFF terminator, read by sub_F8C7F9's shared linear scan
	.byte 0x01, 0x01, 0x01, 0x02, 0x01, 0x02, 0x17, 0x01, 0x04, 0x16, 0x01, 0x08, 0x09, 0x04, 0x01, 0x0a, 0x04, 0x02, 0x12, 0x05, 0x01, 0x15, 0x05, 0x02, 0xff   ; F8C764
; PanelLed_ShowBlinkEnable -- mirror the field-blink enable, (0x2075) bit 1, onto its LED
; Evidence: DispatchTable_F8C2B2 id 0x0200.  v1 clears (0x20D5) bit 1 and sets it if `bit 1,(0x2075)`; v2 does the
;   same with (0x20D6) bit 3.  Blink_SetEnable writes (0x2075) bit 1 (FINDINGS-prom_b-field-blink.md).
PanelLed_ShowBlinkEnable:   ; entry: DispatchTable_F8C2B2 id=0x0200
	.byte 0xc0, 0xc4, 0x3f, 0x02                  ; F8C77D  c0 c4 3f 02
	jr z, .LF8C798                                ; F8C781  66 15
	ld XIX,PanelLed_Shadow                             ; F8C783  44 d0 20 00 00
	and (XIX+0x05),0xfd                           ; F8C788  8c 05 3c fd
	bit	1, (UI_RequestBits:16)                       ; F8C78C  f1 75 20 c9
	jr z, .LF8C7AB                                ; F8C790  66 19
	or (XIX+0x05),0x02                            ; F8C792  8c 05 3e 02
	jr .LF8C7AB                                   ; F8C796  68 13
.LF8C798:
	ld XIX,PanelLed_Shadow                             ; F8C798  44 d0 20 00 00
	and (XIX+0x06),0xf7                           ; F8C79D  8c 06 3c f7
	bit	1, (UI_RequestBits:16)                       ; F8C7A1  f1 75 20 c9
	jr z, .LF8C7AB                                ; F8C7A5  66 04
	or (XIX+0x06),0x08                            ; F8C7A7  8c 06 3e 08
.LF8C7AB:
	ret                                           ; F8C7AB  0e
	cp	(Variant_Flag:8), 0x02                       ; F8C7AC  c0 c4 3f 02
	jr z, .LF8C7C7                                ; F8C7B0  66 15
	ld XIX,PanelLed_Shadow                             ; F8C7B2  44 d0 20 00 00
	and (XIX+0x07),0xfd                           ; F8C7B7  8c 07 3c fd
	bit	0, (0x216e:16)                       ; F8C7BB  f1 6e 21 c8
	jr z, .LF8C7DA                                ; F8C7BF  66 19
	or (XIX+0x07),0x02                            ; F8C7C1  8c 07 3e 02
	jr .LF8C7DA                                   ; F8C7C5  68 13
.LF8C7C7:
	ld XIX,PanelLed_Shadow                             ; F8C7C7  44 d0 20 00 00
	and (XIX+0x06),0xfb                           ; F8C7CC  8c 06 3c fb
	bit	0, (0x216e:16)                       ; F8C7D0  f1 6e 21 c8
	jr z, .LF8C7DA                                ; F8C7D4  66 04
	or (XIX+0x06),0x04                            ; F8C7D6  8c 06 3e 04
.LF8C7DA:
	ret                                           ; F8C7DA  0e
	cp	(Variant_Flag:8), 0x02                       ; F8C7DB  c0 c4 3f 02
	jr z, .LF8C7F8                                ; F8C7DF  66 17
	bit	2, (TransportA_State:8)                            ; F8C7E1  f0 94 ca
	jr nz, .LF8C7F8                               ; F8C7E4  6e 12
	ld XIX,PanelLed_Shadow                             ; F8C7E6  44 d0 20 00 00
	and (XIX+0x04),0xbf                           ; F8C7EB  8c 04 3c bf
	bit	2, (TransportB_State:8)                            ; F8C7EF  f0 96 ca
	jr z, .LF8C7F8                                ; F8C7F2  66 04
	or (XIX+0x04),0x40                            ; F8C7F4  8c 04 3e 40
.LF8C7F8:
	ret                                           ; F8C7F8  0e
.LF8C7F9:
	cp (XIY),0xff                                 ; F8C7F9  85 3f ff
	jr z, .LF8C815                                ; F8C7FC  66 17
	cp A,(XIY)                                    ; F8C7FE  85 f1
	jr z, .LF8C808                                ; F8C800  66 06
	add IY,0x0003                                 ; F8C802  dd c8 03 00
	jr .LF8C7F9                                   ; F8C806  68 f1
.LF8C808:
	ld WA,(XIY+0x01)                              ; F8C808  9d 01 20
	ld XIY,PanelLed_Shadow                             ; F8C80B  45 d0 20 00 00
	.byte 0xc3, 0x03, 0xf4, 0xe0, 0xe8            ; F8C810  c3 03 f4 e0 e8
.LF8C815:
	ret                                           ; F8C815  0e
	ld XIY,PanelLed_Shadow                             ; F8C816  45 d0 20 00 00
	ld	a, (xiy+w)                             ; F8C81B  c3 03 f4 e1 21
	ld XIY,PanelLed_Shadow                             ; F8C820  45 d0 20 00 00
	ex8 a, c                                      ; F8C825  cb b9
	scf                                           ; F8C827  11
	xorcf	a, (0x219b:16)                       ; F8C828  f1 9b 21 2a
	jr c, .LF8C837                                ; F8C82C  67 09
	or C,B                                        ; F8C82E  ca e3
	ld	(xiy+w), c                             ; F8C830  f3 03 f4 e1 43
	jr .LF8C841                                   ; F8C835  68 0a
.LF8C837:
	xor B,0xff                                    ; F8C837  ca cd ff
	and C,B                                       ; F8C83A  ca c3
	ld	(xiy+w), c                             ; F8C83C  f3 03 f4 e1 43
.LF8C841:
	ret                                           ; F8C841  0e
; PanelLed_SendByte -- send LED byte W (pattern A) to the panel, except while screen 0xDB is current
; Evidence: `calr .LF8C84A`: `cp (0x207A),0xdb / jr z,ret`, W = PanelLedWireMap_Variant1/2[W] (by (0xC4)), then
;   .LF8C86A stores W,A into the ring at 0x2BA0 (T_SC1_TxFlush while it is full).  Screen 0xDB is PanelSwLedCheck
;   (FINDINGS-prom_a-panel-control-map.md 3c).  T_PanelLed_SendByte callers: sub_F829A6 (LedNibblePatterns_F829F4).
PanelLed_SendByte:   ; entry: prom_b routine directory
	calr .LF8C84A                                        ; F8C842  1e 05 00
	ret                                                  ; F8C845  0e
; PanelLed_SendByteUnconditional -- PanelLed_SendByte without the screen-0xDB (switch/LED check) gate
; Evidence: `calr .LF8C851` enters past the `cp (0x207A),0xdb` test.  T_PanelLed_SendByteUnconditional's callers are TestMode_SendStagedLed and the test
;   mode's TestMode_PanelSwitchesToLeds, which drive the LEDs while that check screen is current.
PanelLed_SendByteUnconditional:   ; entry: prom_b routine directory
	calr .LF8C851                                        ; F8C846  1e 08 00
	ret                                                  ; F8C849  0e
.LF8C84A:
	cp	(UI_ScreenLatch:16), 0xdb                            ; F8C84A  c1 7a 20 3f db
	jr z, .LF8C869                                       ; F8C84F  66 18
.LF8C851:
	ld XIX,PanelLedWireMap_Variant1                      ; F8C851  44 ac c8 f8 00
	cp	(Variant_Flag:8), 0x01                               ; F8C856  c0 c4 3f 01
	jr z, .LF8C861                                       ; F8C85A  66 05
	ld XIX,PanelLedWireMap_Variant2                      ; F8C85C  44 b7 c8 f8 00
.LF8C861:
	ld	w, (xix+w)                                   ; F8C861  c3 03 f0 e1 20
	calr .LF8C86A                                        ; F8C866  1e 01 00
.LF8C869:
	ret                                                  ; F8C869  0e
.LF8C86A:
	ld XIZ,SC1_OutQueue                                    ; F8C86A  46 a0 2b 00 00
	cpw	(xiz+8), 0x0001                              ; F8C86F  9e 08 3f 01 00
	jr ule, .LF8C8A4                                     ; F8C874  63 2e
	ld IX,(XIZ+0x04)                                     ; F8C876  9e 04 24
	ld	(xiz+ix), w                                  ; F8C879  f3 07 f8 f0 40
	inc 1,IX                                             ; F8C87E  dc 61
	cp IX,(XIZ+0x02)                                     ; F8C880  9e 02 f4
	jr ule, .LF8C888                                     ; F8C883  63 03
	ld	ix, (xiz+0:8)                                ; F8C885  9e 00 24
.LF8C888:
	ld	(xiz+ix), a                                  ; F8C888  f3 07 f8 f0 41
	inc 1,IX                                             ; F8C88D  dc 61
	cp IX,(XIZ+0x02)                                     ; F8C88F  9e 02 f4
	jr ule, .LF8C897                                     ; F8C892  63 03
	ld	ix, (xiz+0:8)                                ; F8C894  9e 00 24
.LF8C897:
	ei 0x06                                              ; F8C897  06 06
	ld (XIZ+0x04),IX                                     ; F8C899  be 04 54
	subw	(xiz+8), 0x0002                      ; F8C89C  9e 08 3a 02 00
	ei 0x00                                              ; F8C8A1  06 00
	ret                                                  ; F8C8A3  0e
.LF8C8A4:
	pushw wa                                             ; F8C8A4  28
	call T_SC1_TxFlush                                   ; F8C8A5  1d 08 0f f4
	popw wa                                              ; F8C8A9  48
	jr .LF8C86A                                          ; F8C8AA  68 be
; ---------------------------------------------------------------------
; PanelLedWireMap_Variant1 / _Variant2 -- 11 bytes each: LED index W -> the
; panel wire code (0xC0 | segment) a LED packet is addressed to.
; Read by the code after PanelLed_SendByte / PanelLed_SendByteUnconditional (prom_b directory entries):
; 0xF8C851 `ld XIX,0x00F8C8AC` (0xF8C85C `ld XIX,0x00F8C8B7` when (0xC4) != 1),
; 0xF8C861 `ld W,(XIX+W)`, then .LF8C86A stores W and A into the ring at RAM
; 0x2BA0 -- the packet [wire][mask] (FINDINGS-prom_a-for-the-mame-driver.md 3).
; COUNT 11 is the extent between the two reader-named bases, and after the
; second one T_F4066C_Nop begins; the unused tail entries are 0x00.
; Was framed as code (`m_and_rm`, `xor D,0`, `and (0xc9c2),b`, `nop`s).
; ---------------------------------------------------------------------
PanelLedWireMap_Variant1:
	.byte 0xc0, 0xc1, 0xc2, 0xc4, 0xc5, 0xc9, 0xcc, 0xcd, 0x00, 0x00, 0x00  ; F8C8AC
PanelLedWireMap_Variant2:
	.byte 0xc1, 0xc2, 0xc9, 0xca, 0xcb, 0xcc, 0xc3, 0x00, 0x00, 0x00, 0x00  ; F8C8B7
T_F4066C_Nop:   ; entry: prom_b routine directory
	ret                                                  ; F8C8C2  0e
; PanelLed_FlashTransportBeat -- flash LED byte 4 bits 6/7 on each beat of transport A (variant 1 only)
; Evidence: called first in every main-loop pass (0xF8203B via T_PanelLed_FlashTransportBeat).  With (0x3552) = 0x8001/0x8002, bit 5 of
;   (0x212A)|(0x212C) clear, (0x94) bit 2 (transport A running) and (0x8B) & 0x60 = 0 (tick < 32 of 96): (0x225A) |=
;   2, A = SelfPtrTable_F8C930[(0x605000)][(0x8C) & 7] (beats per bar, beat -- INTTR4_SequencerTick's names), into
;   bits 6-7 of (0x20D4); otherwise the bits are cleared once.  ⚠ The table's "Read by: NOT ESTABLISHED" is wrong:
;   0xF8C91A.
PanelLed_FlashTransportBeat:   ; entry: prom_b routine directory
	cp	(Variant_Flag:8), 0x02                               ; F8C8C3  c0 c4 3f 02
	jr z, .LF8C92F                                       ; F8C8C7  66 66
	ld XIX,PanelLed_Shadow+4                                    ; F8C8C9  44 d4 20 00 00
	ld XIY,0x0000225a                                    ; F8C8CE  45 5a 22 00 00
	ld wa, (0x3552:16)                                 ; F8C8D3  d1 52 35 20
	cp WA,0x8002                                         ; F8C8D7  d8 cf 02 80
	jr z, .LF8C8E3                                       ; F8C8DB  66 06
	cp WA,0x8001                                         ; F8C8DD  d8 cf 01 80
	jr nz, .LF8C8F6                                      ; F8C8E1  6e 13
.LF8C8E3:
	ld wa, (0x212a:16)                                 ; F8C8E3  d1 2a 21 20
	or	wa, (0x212c:16)                              ; F8C8E7  d1 2c 21 e0
	and WA,0x0020                                        ; F8C8EB  d8 cc 20 00
	jr nz, .LF8C92F                                      ; F8C8EF  6e 3e
	bit	2, (TransportA_State:8)                                   ; F8C8F1  f0 94 ca
	jr nz, .LF8C902                                      ; F8C8F4  6e 0c
.LF8C8F6:
	bit 1,(XIY)                                          ; F8C8F6  b5 c9
	jr z, .LF8C92F                                       ; F8C8F8  66 35
	and (XIY),0xfd                                       ; F8C8FA  85 3c fd
	and (XIX),0x3f                                       ; F8C8FD  84 3c 3f
	jr .LF8C92F                                          ; F8C900  68 2d
.LF8C902:
	ld	c, (TransportA_Beat:8)                                      ; F8C902  c0 8c 23
	ld l, (TransportA_BeatsPerBar:24)                                 ; F8C905  c2 00 50 60 27
	ld	a, (TransportA_Tick:8)                                      ; F8C90A  c0 8b 21
	and A,0x60                                           ; F8C90D  c9 cc 60
	jr nz, .LF8C8F6                                      ; F8C910  6e e4
	or	(xiy), 0x02                                  ; F8C912  85 3e 02
	mul L,0x04                                           ; F8C915  cf 08 04
	extz XHL                                             ; F8C918  eb 12
	add XHL,SelfPtrTable_F8C930                          ; F8C91A  eb c8 30 c9 f8 00
	ld XHL,(XHL)                                         ; F8C920  a3 23
	and C,0x07                                           ; F8C922  cb cc 07
	ld	a, (xhl+c)                                   ; F8C925  c3 03 ec e4 21
	and (XIX),0x3f                                       ; F8C92A  84 3c 3f
	or (XIX),A                                           ; F8C92D  84 e9
.LF8C92F:
	ret                                                  ; F8C92F  0e
; ---------------------------------------------------------------------
; SelfPtrTable_F8C930 -- 9 LE32 self-pointers into an 18-long block of
; unclaimed bitmap-like constants, then a 4,196-byte uniform 0x0E pad
;
; Read by: NOT ESTABLISHED -- no call site or table walker anywhere in this
;          tree reaches 0xF8C930 or dereferences these pointers. Wave 1
;          (2026-09-02, c94f57ca) investigated this span and deliberately
;          left it whole as .incbin rather than respell it .byte with no
;          new understanding; this splits off the verified fill tail only.
; Evidence: notes/prom_a_c930_selfptr_check.py reads the ROM directly.
;          Words 0-8 are LE32 0x00F8C954, +8, +8, ... +8 = 0x00F8C994 -- each
;          one SELF-REFERENTIAL, landing exactly on the start of its own
;          8-byte (2-long) slot among words 9-26 that follow (no overlap, no
;          gap: pointer[i] == this table + 0x00F8C954 + 8*i). Words 9-26 (18
;          longs) use only the byte alphabet {0x00, 0x40, 0x80} -- a
;          one-byte-per-something mask shape consistent with a small bitmap,
;          though what draws or reads it is not established. Bytes
;          0xF8C99C-0xF8D9FF (4,196 bytes) are uniform 0x0E, checked byte by
;          byte by the same script, not sampled.
; Unknown: what reads this table; what the 16 non-zero constant longs mean;
;          why the table exists at all if nothing in this tree reaches it.
;          Left as .long typed data, not named: only the 4-byte-word FRAMING
;          is established, not the semantics.
; ---------------------------------------------------------------------
SelfPtrTable_F8C930:
	.long SelfPtrTable_F8C930+0x24                   ; F8C930  [ptr 0]
	.long SelfPtrTable_F8C930+0x2C                   ; F8C934  [ptr 1]
	.long SelfPtrTable_F8C930+0x34                   ; F8C938  [ptr 2]
	.long SelfPtrTable_F8C930+0x3C                   ; F8C93C  [ptr 3]
	.long SelfPtrTable_F8C930+0x44                   ; F8C940  [ptr 4]
	.long SelfPtrTable_F8C930+0x4C                   ; F8C944  [ptr 5]
	.long SelfPtrTable_F8C930+0x54                   ; F8C948  [ptr 6]
	.long SelfPtrTable_F8C930+0x5C                   ; F8C94C  [ptr 7]
	.long SelfPtrTable_F8C930+0x64                   ; F8C950  [ptr 8]
	.long 0x00000000                                 ; F8C954  [ 0]
	.long 0x00000000                                 ; F8C958  [ 1]
	.long 0x40404040                                 ; F8C95C  [ 2]
	.long 0x40404040                                 ; F8C960  [ 3]
	.long 0x80408040                                 ; F8C964  [ 4]
	.long 0x80408040                                 ; F8C968  [ 5]
	.long 0x40808040                                 ; F8C96C  [ 6]
	.long 0x80408080                                 ; F8C970  [ 7]
	.long 0x80808040                                 ; F8C974  [ 8]
	.long 0x80808040                                 ; F8C978  [ 9]
	.long 0x80808040                                 ; F8C97C  [10]
	.long 0x80804080                                 ; F8C980  [11]
	.long 0x80808040                                 ; F8C984  [12]
	.long 0x80408080                                 ; F8C988  [13]
	.long 0x80808040                                 ; F8C98C  [14]
	.long 0x40808080                                 ; F8C990  [15]
	.long 0x80808040                                 ; F8C994  [16]
	.long 0x80808080                                 ; F8C998  [17]
	.fill 4196, 1, 0x0E                                  ; F8C99C-F8D9FF: uniform RET pad, verified by notes/prom_a_c930_selfptr_check.py
