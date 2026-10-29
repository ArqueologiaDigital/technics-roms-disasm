
; ---------------------------------------------------------------------
; PanelTask_EntryVectors -- six `jp addr24` slots at the module's head
;
; Slots 0,1,2 -> PanelTask_Reset; slot 3 -> PanelTask_StepAndCheckRequest;
; slots 4,5 -> PanelTask_Return, a bare `ret`.
; Evidence: six consecutive 4-byte `jp` (opcode 0x1B) at 0xF86000-0xF86017,
;          all three targets inside this span.  The pad at 0xF85FF9-0xF85FFF
;          (7 bytes of 0x0E) is what puts the block on 0xF86000.
; Unknown:  who calls the six slots.  No `call`/`jp` in either image names
;          0xF86000-0xF86014; they are reached the way prom_b's directory
;          reaches everything else, and this module's published entry is the
;          thunk run T_PanelTask_Step (T_F40F34)-T_PanelEvent_NoOp_T40F94 (T_F40F94), not this block.
; ---------------------------------------------------------------------
PanelTask_EntryVectors:
	jp PanelTask_Reset                                   ; F86000  1b 18 60 f8
	jp PanelTask_Reset                                   ; F86004  1b 18 60 f8
	jp PanelTask_Reset                                   ; F86008  1b 18 60 f8
	jp PanelTask_StepAndCheckRequest                                   ; F8600C  1b 1c 60 f8
	jp PanelTask_Return                                   ; F86010  1b 1b 60 f8
	jp PanelTask_Return                                   ; F86014  1b 1b 60 f8
PanelTask_Reset:
	calr .LF86023                                 ; F86018  1e 08 00
PanelTask_Return:
	ret                                           ; F8601B  0e
PanelTask_StepAndCheckRequest:
	calr .LF86066                                 ; F8601C  1e 47 00
	calr PanelState_CheckRequestAllowed                                   ; F8601F  1e c7 0a   calr 0xf86ae9
	ret                                           ; F86022  0e

; ---------------------------------------------------------------------
; PanelState_Init -- set the screen state to its power-on values
;
; Called from: PanelTask_Reset 0xF86018 (`calr`).
; Outputs: (0x207A) = (0x207C) = (0x2083) = A, (0x2078) = (0x2076) = W,
;          (0x2079) = (0x2077) = 0xFF, (0x2070..0x2071) = 0x40AA.
;          A and W are both 1, or both 2 when (0x7F02) & 0xF0 == 0x10.
; Evidence: the 0x40AA store at 0xF86055 is a 16-bit store to 0x2070, so it
;          writes 0xAA to (0x2070) and 0x40 to (0x2071).  0x40 is bit 6, the
;          bit PanelScreen_ApplyRequest tests at 0xF862A6, and every
;          live entry of PanelHold_ScreenRequest has the same 0x40 high
;          byte -- so (0x2070) is a screen id and (0x2071) its request flags.
;          Setting the two `previous` cells to 0xFF is what makes the first
;          PanelState_LatchPrevious pass copy rather than compare.
; ---------------------------------------------------------------------
.LF86023:
PanelState_Init:   ; entry: calr from 0xF86018
	ld a, 0x01:opc                                   ; F86023  21 01   ld A,0x01
	ld w, 0x01:opc                                   ; F86025  20 01   ld W,0x01
	ld l, (0x7f02:16)                            ; F86027  c1 02 7f 27   ld L,(0x7f02)
	and L,0xf0                                    ; F8602B  cf cc f0
	cp L,0x10                                     ; F8602E  cf cf 10
	jr nz, .LF86037                               ; F86031  6e 04
	ld a, 0x02:opc                                   ; F86033  21 02   ld A,0x02
	ld w, 0x02:opc                                   ; F86035  20 02   ld W,0x02
.LF86037:
	ld (UI_ScreenLatch:16), a                            ; F86037  f1 7a 20 41   ld (0x207a),A
	ld (UI_ScreenId:16), a                            ; F8603B  f1 7c 20 41   ld (0x207c),A
	ld (0x2083:16), a                            ; F8603F  f1 83 20 41   ld (0x2083),A
	ld (PanelMode:16), w                            ; F86043  f1 78 20 40   ld (0x2078),W
	ld (PanelMode_Previous:16), 0xff                          ; F86047  f1 79 20 00 ff   ld (0x2079),0xff
	ld (PanelModeGroup:16), w                            ; F8604C  f1 76 20 40   ld (0x2076),W
	ld (PanelModeGroup_Previous:16), 0xff                          ; F86050  f1 77 20 00 ff   ld (0x2077),0xff
	ldw (UI_Request:16), 0x40aa                       ; F86055  f1 70 20 02 aa 40   ld (0x2070),0x40aa
	ret                                           ; F8605B  0e

; ---------------------------------------------------------------------
; sub_F8605C -- runs the three screen-transition steps and nothing else
;
; Evidence: NOTHING names this address.  Checked two ways: the census over
;          every decoded operand of every code segment in this span, and
;          far_calls() over both ROM images at every byte offset.
; Called from: NOTHING.  No absolute or relative reference to 0xF8605C
;          exists in either image (checked by the census over every decoded
;          operand of this span, and by far_calls over both ROM images).
;          It is reached only because it sits inside a code segment.
; Body:    `calr PanelScreen_RunLeave / calr PanelScreen_RunEnter /
;          calr PanelScreen_RunRedraw / ret` -- the same three calls
;          PanelTask_Step makes at 0xF8607E-0xF86084.
; Unknown:  why it exists.  Left as sub_XXXXXX because an unreferenced
;          routine has no caller to name it after.
; ---------------------------------------------------------------------
sub_F8605C:
	calr .LF8648D                                 ; F8605C  1e 2e 04
	calr .LF864FA                                 ; F8605F  1e 98 04
	calr .LF86582                                 ; F86062  1e 1d 05
	ret                                           ; F86065  0e

; ---------------------------------------------------------------------
; PanelTask_Step -- one pass of the panel/screen state machine
;
; Called from: thunk slot T_PanelTask_Step (T_F40F34) (`jp 0x00F86066`), whose one proven call
;          site is prom_a 0xF8210E; also `calr` from PanelTask_StepAndCheckRequest
;          0xF8601C.
; Body, in order: PanelState_CheckRequestAllowed, PanelState_SyncScreenFlags,
;          PanelState_LatchPrevious, PanelState_RunRequests,
;          PanelMode_ToGroup, PanelState_UpdateScreenHoldState,
;          PanelState_UpdateScreenLatch, PanelState_ClearOnChange,
;          PanelScreen_RunLeave, PanelScreen_RunEnter,
;          PanelScreen_RunRedraw, `and (0x2095),0xEF`,
;          PanelButton_RunPending, PanelState_TakePendingHoldTime.
; Evidence: fourteen `calr` in a row with no conditional between them, so
;          the order above IS the ROM's order.
; ---------------------------------------------------------------------
.LF86066:
PanelTask_Step:   ; entry: calr from 0xF8601C, prom_b directory slot T_PanelTask_Step (T_F40F34)
	calr PanelState_CheckRequestAllowed                                   ; F86066  1e 80 0a   calr 0xf86ae9
	calr .LF86553                                 ; F86069  1e e7 04
	calr .LF860D9                                 ; F8606C  1e 6a 00
	calr .LF86101                                 ; F8606F  1e 8f 00
	calr PanelMode_ToGroup                                   ; F86072  1e 39 0c   calr 0xf86cae
	calr .LF863D3                                 ; F86075  1e 5b 03
	calr .LF863F5                                 ; F86078  1e 7a 03
	calr .LF86413                                 ; F8607B  1e 95 03
	calr .LF8648D                                 ; F8607E  1e 0c 04
	calr .LF864FA                                 ; F86081  1e 76 04
	calr .LF86582                                 ; F86084  1e fb 04
	and	(UI_ScreenFlags:16), 0xef                     ; F86087  c1 95 20 3c ef   and (0x2095),0xef
	calr .LF8611B                                 ; F8608C  1e 8c 00
	calr .LF86094                                 ; F8608F  1e 02 00
	ret                                           ; F86092  0e

; ---------------------------------------------------------------------
; sub_F86093 -- a single `ret` between PanelTask_Step and
; PanelState_TakePendingHoldTime
;
; Called from: NOTHING; no reference to 0xF86093 exists in either image.
; Evidence: same two-way census as sub_F8605C.  It is a label only because
;          the layout's descent reached the byte; nothing published it.
; Unknown:  whether it is a routine at all or the tail of the one above.
; ---------------------------------------------------------------------
sub_F86093:
	ret                                           ; F86093  0e

; ---------------------------------------------------------------------
; PanelState_TakePendingHoldTime -- move (0x209A) into (0x2073) if set
;
; Called from: PanelTask_Step 0xF8608F (`calr`), and nothing else.
; Outputs: if (0x209A) != 0 then (0x2073) = (0x209A) and (0x209A) = 0.
; Evidence: (0x2073) is the cell PanelTimer_ScreenHold counts down and that
;          PanelScreen_ApplyRequest reloads with 0x70, so (0x209A) is a
;          one-shot request to preload that counter.
; ---------------------------------------------------------------------
.LF86094:
PanelState_TakePendingHoldTime:   ; entry: calr from 0xF8608F
	ld a, (UI_ScreenHoldPending:16)                            ; F86094  c1 9a 20 21   ld A,(0x209a)
	cp a, 0x00:i3                                   ; F86098  c9 d8   cp A,0
	jr z, .LF860A5                                ; F8609A  66 09
	ld (UI_ScreenHoldTimer:16), a                            ; F8609C  f1 73 20 41   ld (0x2073),A
	ld (UI_ScreenHoldPending:16), 0x00                          ; F860A0  f1 9a 20 00 00   ld (0x209a),0x00
.LF860A5:
	ret                                           ; F860A5  0e

; ---------------------------------------------------------------------
; UiEventList_Publish -- make the pending event list the current one
;
; Called from: thunk slot T_UiEventList_Publish (T_F40F50) (`jp 0x00F860A6`); 5 proven call sites
;          (prom_a 0xF820FC, 0xFB3151, 0xFB59CA, 0xFE00E2, 0xFE70CF).
; Outputs: RAM 0x2C00.. := RAM 0x2E00.., (0x60F004) bytes of it;
;          0xFF written one byte past; (0x60F000) := the byte count;
;          (0x2E00) := 0xFF and (0x60F004) := 0, i.e. the pending list is
;          emptied.
; Evidence: `ld XIY,0x2E00 / ld XIX,0x2C00 / ld BC,(0x60F004) / srl 1,BC /
;          ldirw` at 0xF860A6-0xF860BC -- on this core LDIRW copies (XIY) to
;          (XIX), so 0x2E00 is the SOURCE.  The count is halved because the
;          transfer is by words.  ★ This is what makes 0x2C00 and 0x2E00 a
;          double buffer rather than two unrelated queues: everything posted
;          with Queue2E00_AppendRegs becomes visible at 0x2C00 here, and
;          nowhere else.
; Answers:  notes/FINDINGS-prom_b-message-and-service-module.md's open
;          question `what RAM 0x2C00 holds` -- 4-byte UI event records,
;          published from 0x2E00 by this routine and walked by
;          UiEventList_Run.
; ---------------------------------------------------------------------
UiEventList_Publish:   ; entry: prom_b directory slot T_UiEventList_Publish (T_F40F50)
	ld XIY,0x00002e00                             ; F860A6  45 00 2e 00 00
	ld XIX,0x00002c00                             ; F860AB  44 00 2c 00 00
	ld bc, (0x60f004:24)                         ; F860B0  d2 04 f0 60 21   ld BC,(0x60f004)
	srl bc, 0x01                                  ; F860B5  d9 ef 01   srl 0x01,BC
	cp bc, 0x00:i3                                  ; F860B8  d9 d8   cp BC,0
	jr z, .LF860BE                                ; F860BA  66 02
	ldirw                                         ; F860BC  95 11
.LF860BE:
	ld (XIX),0xff                                 ; F860BE  b4 00 ff
	sub XIX,0x00002c00                            ; F860C1  ec ca 00 2c 00 00
	ld (0x60f000:24), ix                         ; F860C7  f2 00 f0 60 54   ld (0x60f000),IX
	ld (0x2e00:16), 0xff                          ; F860CC  f1 00 2e 00 ff   ld (0x2e00),0xff
	ldw (0x60f004:24), 0x00                      ; F860D1  f2 04 f0 60 02 00 00   ld (0x60f004),0x0000
	ret                                           ; F860D8  0e

; ---------------------------------------------------------------------
; PanelState_LatchPrevious -- copy the three current ids to their shadows
;
; Called from: PanelTask_Step 0xF8606C (`calr`), and nothing else.
; Outputs: unless (0x2077) == 0xFF: (0x2079) = (0x2078), (0x207B) = (0x207A),
;          (0x207D) = (0x207C).  Then (0x2077) = (0x2076) unconditionally.
; Evidence: the three pairs are exactly the three the change detectors
;          compare -- 0xF864BD (`(0x2078)` vs `L=(0x2079)`), 0xF864AE,
;          0xF86493 -- so odd address = current, even+1 = previous.
; ---------------------------------------------------------------------
.LF860D9:
PanelState_LatchPrevious:   ; entry: calr from 0xF8606C
	cp	(PanelModeGroup_Previous:16), 0xff                     ; F860D9  c1 77 20 3f ff   cp (0x2077),0xff
	jr z, .LF860F8                                ; F860DE  66 18
	ld a, (PanelMode:16)                            ; F860E0  c1 78 20 21   ld A,(0x2078)
	ld (PanelMode_Previous:16), a                            ; F860E4  f1 79 20 41   ld (0x2079),A
	ld a, (UI_ScreenLatch:16)                            ; F860E8  c1 7a 20 21   ld A,(0x207a)
	ld (UI_ScreenLatch_Previous:16), a                            ; F860EC  f1 7b 20 41   ld (0x207b),A
	ld a, (UI_ScreenId:16)                            ; F860F0  c1 7c 20 21   ld A,(0x207c)
	ld (UI_ScreenId_Previous:16), a                            ; F860F4  f1 7d 20 41   ld (0x207d),A
.LF860F8:
	ld a, (PanelModeGroup:16)                            ; F860F8  c1 76 20 21   ld A,(0x2076)
	ld (PanelModeGroup_Previous:16), a                            ; F860FC  f1 77 20 41   ld (0x2077),A
	ret                                           ; F86100  0e

; ---------------------------------------------------------------------
; PanelState_RunRequests -- run the four screen-change requests in (0x2071)
;
; Called from: PanelTask_Step 0xF8606F (`calr`), and nothing else.
; Body:    if (0x2071) != 0: PanelScreen_ApplyPendingId (bit 2),
;          PanelScreen_ApplyRequest (bits 6,5), PanelScreen_ApplyModeChange
;          (bit 1), PanelScreen_ApplyRequestForced (bit 7); then
;          `and (0x2071),0x09` -- keeping only bits 0 and 3, the two
;          PanelButton_RunPending consumes.
; Evidence: the mask 0x09 at 0xF86115 and the mask 0xF6 at 0xF8612C are
;          complementary over bits 0 and 3, so the byte is split between two
;          consumers with no overlap.
; ---------------------------------------------------------------------
.LF86101:
PanelState_RunRequests:   ; entry: calr from 0xF8606F
	ld a, (UI_Request_Hi:16)                            ; F86101  c1 71 20 21   ld A,(0x2071)
	cp a, 0x00:i3                                   ; F86105  c9 d8   cp A,0
	jr z, .LF8611A                                ; F86107  66 11
	calr .LF8625E                                 ; F86109  1e 52 01
	calr .LF86295                                 ; F8610C  1e 86 01
	calr .LF86318                                 ; F8610F  1e 06 02
	calr .LF8639C                                 ; F86112  1e 87 02
	and	(UI_Request_Hi:16), 0x09                     ; F86115  c1 71 20 3c 09   and (0x2071),0x09
.LF8611A:
	ret                                           ; F8611A  0e

; ---------------------------------------------------------------------
; PanelButton_RunPending -- run the button path if bit 0 or bit 3 is set
;
; Called from: PanelTask_Step 0xF8608C (`calr`), and nothing else.
; Outputs: calls PanelButton_Dispatch, then `and (0x2071),0xF6` (clears
;          bits 0 and 3).
; Evidence: `bit 0x03,A` at 0xF8611F and `bit 0x00,A` at 0xF86124 are the
;          only two bits tested, and 0xF6 is their complement -- so this
;          routine owns exactly the two bits PanelState_RunRequests spares.
; ---------------------------------------------------------------------
.LF8611B:
PanelButton_RunPending:   ; entry: calr from 0xF8608C
	ld a, (UI_Request_Hi:16)                            ; F8611B  c1 71 20 21   ld A,(0x2071)
	bit 0x03,A                                    ; F8611F  c9 33 03
	jr nz, .LF86129                               ; F86122  6e 05
	bit 0x00,A                                    ; F86124  c9 33 00
	jr z, .LF86131                                ; F86127  66 08
.LF86129:
	calr .LF86132                                 ; F86129  1e 06 00
	and	(UI_Request_Hi:16), 0xf6                     ; F8612C  c1 71 20 3c f6   and (0x2071),0xf6
.LF86131:
	ret                                           ; F86131  0e

; ---------------------------------------------------------------------
; PanelButton_Dispatch -- auto-repeat sweep, or the one pending button
;
; Called from: PanelButton_RunPending 0xF86129 (`calr`), and nothing else.
; Body:    bit 3 of (0x2071) AND bit 3 of (0x2075) -> PanelButton_SweepHeld,
;          (0x2074) = 3, `or (0x2075),0x04`; otherwise bit 0 of (0x2071) ->
;          PanelButton_DispatchCurrent.
; Evidence: (0x2074) is the counter PanelTimer_ButtonRepeat decrements before
;          setting bit 3 of (0x2071) again, so the bit-3 arm IS the repeat.
; ---------------------------------------------------------------------
.LF86132:
PanelButton_Dispatch:   ; entry: calr from 0xF86129
	ld a, (UI_Request_Hi:16)                            ; F86132  c1 71 20 21   ld A,(0x2071)
	bit 0x03,A                                    ; F86136  c9 33 03
	jr z, .LF86153                                ; F86139  66 18
	ld w, (UI_RequestBits:16)                            ; F8613B  c1 75 20 20   ld W,(0x2075)
	bit 0x03,W                                    ; F8613F  c8 33 03
	jr z, .LF86153                                ; F86142  66 0f
	calr .LF8615C                                 ; F86144  1e 15 00
	ld (PanelButton_RepeatTimer:16), 0x03                          ; F86147  f1 74 20 00 03   ld (0x2074),0x03
	or	(UI_RequestBits:16), 0x04                     ; F8614C  c1 75 20 3e 04   or (0x2075),0x04
	jr .LF8615B                                   ; F86151  68 08
.LF86153:
	bit 0x00,A                                    ; F86153  c9 33 00
	jr z, .LF8615B                                ; F86156  66 03
	calr .LF861A4                                 ; F86158  1e 49 00
.LF8615B:
	ret                                           ; F8615B  0e

; ---------------------------------------------------------------------
; PanelButton_SweepHeld -- route every button whose bit is set in (0x2088)
;
; Called from: PanelButton_Dispatch 0xF86144 (`calr`), and nothing else.
; Body:    for C = 0..31: mask = PanelButton_BitMask32[C]; if mask & (0x2088)
;          then (0x2082) = C | (0x80 if mask & (0x2084) else 0) and
;          PanelButton_DispatchCurrent is called.
; Evidence: the loop bound is `cp C,0x1f` at 0xF8619A and the table is 32
;          LE32 entries; PanelButton_BitMask32[i] == 1<<i for every i, so
;          `mask & (0x2088)` is literally `bit i of (0x2088)`.
;          ⚠ It reloads XWA from (0x2088) at the TOP of each iteration
;          (0xF8616A), so a handler that clears its own bit is seen at once.
; ---------------------------------------------------------------------
.LF8615C:
PanelButton_SweepHeld:   ; entry: calr from 0xF86144
	ld xwa, (PanelButton_HeldMask:16)                          ; F8615C  e1 88 20 20   ld XWA,(0x2088)
	cp XWA,0x00000000                             ; F86160  e8 cf 00 00 00 00
	jr z, .LF861A3                                ; F86166  66 3b
	xor BC,BC                                     ; F86168  d9 d1
.LF8616A:
	ld xwa, (PanelButton_HeldMask:16)                          ; F8616A  e1 88 20 20   ld XWA,(0x2088)
	ld xde, (PanelButton_HeldPairPos:16)                          ; F8616E  e1 84 20 22   ld XDE,(0x2084)
	ld XHL,PanelButton_BitMask32                  ; F86172  43 1a 67 f8 00
	pushw bc                                      ; F86177  29   push BC
	sll bc, 0x02                                  ; F86178  d9 ee 02   sll 0x02,BC
	add HL,BC                                     ; F8617B  d9 83
	popw bc                                       ; F8617D  49   pop BC
	ld XHL,(XHL)                                  ; F8617E  a3 23
	and XHL,XWA                                   ; F86180  e8 c3
	jr z, .LF8619A                                ; F86182  66 16
	xor B,B                                       ; F86184  ca d2
	and XHL,XDE                                   ; F86186  ea c3
	jr z, .LF8618D                                ; F86188  66 03
	or B,0x80                                     ; F8618A  ca ce 80
.LF8618D:
	or B,C                                        ; F8618D  cb e2
	ld (PanelButton_Current:16), b                            ; F8618F  f1 82 20 42   ld (0x2082),B
	xor B,B                                       ; F86193  ca d2
	pushw bc                                      ; F86195  29   push BC
	calr .LF861A4                                 ; F86196  1e 0b 00
	popw bc                                       ; F86199  49   pop BC
.LF8619A:
	cp C,0x1f                                     ; F8619A  cb cf 1f
	jr nc, .LF861A3                               ; F8619D  6f 04
	inc 1,C                                       ; F8619F  cb 61
	jr .LF8616A                                   ; F861A1  68 c7
.LF861A3:
	ret                                           ; F861A3  0e

; ---------------------------------------------------------------------
; PanelButton_DispatchCurrent -- route the button code in (0x2082)
;
; Called from: PanelButton_Dispatch 0xF86158, PanelButton_SweepHeld 0xF86196.
; Inputs:  (0x2082): bits 0-4 the button index, bit 7 a flag.
; Evidence: the split is PanelButton_Route's own, `and L,0x1f` at 0xF861AE
;          and `and W,0x80` at 0xF861B3; (0x2082) is written by
;          PanelButton_SweepHeld 0xF8618F and PanelButton_Accept 0xF86710.
; ---------------------------------------------------------------------
.LF861A4:
PanelButton_DispatchCurrent:   ; entry: calr from 0xF86158, 0xF86196
	ld w, (PanelButton_Current:16)                            ; F861A4  c1 82 20 20   ld W,(0x2082)
	calr .LF861AC                                 ; F861A8  1e 01 00
	ret                                           ; F861AB  0e

; ---------------------------------------------------------------------
; PanelButton_Route -- special-case three buttons, else call the screen's
;                      Button method
;
; Called from: PanelButton_DispatchCurrent 0xF861A8 (`calr`) and
;          PanelEvent_Code21_Dial 0xF8687E (`calr`).
; Inputs:  W = the button code (index in bits 0-4, flag in bit 7).
; Body:    L = W & 0x1F, W = W & 0x80.
;          * index 0x0E with bit 5 of (0x2075) clear -> PanelButton_PostClass70.
;          * index 0x0D with bit 0 of (0x2075) clear -> PanelDial_ApplyStep
;            with A = (W & 0x80) | 1, then PanelDial_PostClass7A, then
;            `or (0x2075),0x08`.
;          * index 0x0F released, with (0x20A2) == 0 -> `and (0x2075),0x7F`.
;          * otherwise: C = (0x207C); if C <= 0xDF, XBC = the screen vtable
;            for that id PLUS 8, (0x20B4) = XBC, and XBC is CALLED with
;            A = the flag and HL = the index pushed as two words.
; Evidence: the `+8` is the vtable's third method -- see the header on
;          PanelScreen_VtableTable.  The two `push` before the call and the
;          `inc 4,XSP` after it at 0xF8622E say the callee takes two 16-bit
;          stack arguments and does not pop them.
; ---------------------------------------------------------------------
.LF861AC:
PanelButton_Route:   ; entry: calr from 0xF861A8, 0xF8687E
	ld L,W                                        ; F861AC  c8 8f
	and L,0x1f                                    ; F861AE  cf cc 1f
	extz HL                                       ; F861B1  db 12
	and W,0x80                                    ; F861B3  c8 cc 80
	bit	5, (UI_RequestBits:16)                        ; F861B6  f1 75 20 cd   bit 5,(0x2075)
	jr nz, .LF861C6                               ; F861BA  6e 0a
	cp L,0x0e                                     ; F861BC  cf cf 0e
	jr nz, .LF861C6                               ; F861BF  6e 05
	calr .LF8623C                                 ; F861C1  1e 78 00
	jr .LF8623B                                   ; F861C4  68 75
.LF861C6:
	bit	0, (UI_RequestBits:16)                        ; F861C6  f1 75 20 c8   bit 0,(0x2075)
	jr nz, .LF861E6                               ; F861CA  6e 1a
	cp L,0x0d                                     ; F861CC  cf cf 0d
	jr nz, .LF861E6                               ; F861CF  6e 15
	ld A,W                                        ; F861D1  c8 89
	and A,0x80                                    ; F861D3  c9 cc 80
	or A,0x01                                     ; F861D6  c9 ce 01
	calr PanelDial_ApplyStep                                   ; F861D9  1e b2 06   calr 0xf8688e
	calr PanelDial_PostClass7A                                   ; F861DC  1e ee 06   calr 0xf868cd
	or	(UI_RequestBits:16), 0x08                     ; F861DF  c1 75 20 3e 08   or (0x2075),0x08
	jr .LF8623B                                   ; F861E4  68 55
.LF861E6:
	cp L,0x0f                                     ; F861E6  cf cf 0f
	jr nz, .LF86205                               ; F861E9  6e 1a
	ld A,W                                        ; F861EB  c8 89
	and A,0x80                                    ; F861ED  c9 cc 80
	cp a, 0x00:i3                                   ; F861F0  c9 d8   cp A,0
	jr nz, .LF86205                               ; F861F2  6e 11
	cp	(0x20a2:16), 0x00                     ; F861F4  c1 a2 20 3f 00   cp (0x20a2),0x00
	jr nz, .LF86200                               ; F861F9  6e 05
	and	(UI_RequestBits:16), 0x7f                     ; F861FB  c1 75 20 3c 7f   and (0x2075),0x7f
.LF86200:
	and	(UI_RequestBits:16), 0xef                     ; F86200  c1 75 20 3c ef   and (0x2075),0xef
.LF86205:
	xor XBC,XBC                                   ; F86205  e9 d1
	ld c, (UI_ScreenId:16)                            ; F86207  c1 7c 20 23   ld C,(0x207c)
	cp C,0xdf                                     ; F8620B  cb cf df
	jr ugt, .LF8623B                              ; F8620E  6b 2b
	ld XIX,XBC                                    ; F86210  e9 8c
	sla ix, 0x02                                  ; F86212  dc ec 02   sla 0x02,IX
	ld XBC,PanelScreen_VtableTable_ViewB          ; F86215  41 41 6f f8 00
	add XIX,XBC                                   ; F8621A  e9 84
	ld XBC,(XIX)                                  ; F8621C  a4 21
	add XBC,0x00000008                            ; F8621E  e9 c8 08 00 00 00
	ld (0x20b4:16), xbc                          ; F86224  f1 b4 20 61   ld (0x20b4),XBC
	ld A,W                                        ; F86228  c8 89
	pushw wa                                      ; F8622A  28   push WA
	pushw hl                                      ; F8622B  2b   push HL
	call (xbc)                                    ; F8622C  b1 e8   call T,XBC
	inc 4,XSP                                     ; F8622E  ef 64
	bit	4, (UI_Request_Hi:16)                        ; F86230  f1 71 20 cc   bit 4,(0x2071)
	jr z, .LF8623B                                ; F86234  66 05
	or	(0x2072:16), 0x10                     ; F86236  c1 72 20 3e 10   or (0x2072),0x10
.LF8623B:
	ret                                           ; F8623B  0e

; ---------------------------------------------------------------------
; PanelButton_PostClass70 -- post event {0x70, 0x01, code, 0x03} to 0x2030
;
; Called from: PanelButton_Route 0xF861C1 (`calr`), and nothing else.
; Outputs: DE = 0x0170 and WA = {A, 0x03} are handed to List2030_AppendRegs,
;          which stores E,D,A,W at +0..+3 -- so the record is
;          0x70, 0x01, A, 0x03, and 0x70 is the event class.
;          A is 3 when (0x208C) & 0x4000, else 1 when bit 7 of W is set,
;          else 2.
; ⚠ CORRECTED IN ROUND 9: this line used to gloss bit 7 of W as
;          "(button RELEASED)". IT IS NOT A RELEASE FLAG, and two independent
;          sites show it:
;            * prom_a PanelButton_CallTableEntry picks between TWO 32-bit enable masks on that
;              bit -- (0x2666) when clear, (0x266A) when set, at
;              0xF8BDD2-0xF8BDDE.
;            * prom_b's eight handlers at 0xF7ECFF-0xF7EDC6 use it to select
;              item i versus item i+8. A RELEASE would pick a different item
;              than its own press, which is not how a button works.
;          RELEASE is tested separately, as (0x20B9) & (0x20BA) == 0 at
;          0xF866F8. What bit 7 DOES mean is NOT established: the i / i+8 shape
;          resembles the LCD soft keys' 8 columns x 2 rows, but that is a
;          resemblance and nothing pins it.
;          Derived by notes/wave7_panel_button_codes.py (--selftest 31/31).
; Evidence: class 0x70 is one of the 121 ids that has its own handler list
;          in all three class tables (UiEventClass_ListTable_A/B/C).
; ---------------------------------------------------------------------
.LF8623C:
PanelButton_PostClass70:   ; entry: calr from 0xF861C1
	ld xde, (0x208c:16)                          ; F8623C  e1 8c 20 22   ld XDE,(0x208c)
	and XDE,0x00004000                            ; F86240  ea cc 00 40 00 00
	jr z, .LF8624C                                ; F86246  66 04
	ld a, 0x03:opc                                   ; F86248  21 03   ld A,0x03
	jr .LF86255                                   ; F8624A  68 09
.LF8624C:
	ld a, 0x01:opc                                   ; F8624C  21 01   ld A,0x01
	bit 0x07,W                                    ; F8624E  c8 33 07
	jr nz, .LF86255                               ; F86251  6e 02
	ld a, 0x02:opc                                   ; F86253  21 02   ld A,0x02
.LF86255:
	ld w, 0x03:opc                                   ; F86255  20 03   ld W,0x03
	ldw de, 0x0170                                ; F86257  32 70 01   ld DE,0x0170
	calr List2030_AppendRegs                                   ; F8625A  1e 6a 08   calr 0xf86ac7
	ret                                           ; F8625D  0e

; ---------------------------------------------------------------------
; PanelScreen_ApplyPendingId -- (0x207C) := (0x20A2) if set, else (0x2083)
;
; Called from: PanelState_RunRequests 0xF86109 (`calr`), and nothing else.
; Guard:   bit 2 of (0x2071).
; Outputs: (0x2072) = 0; A = (0x20A2) if non-zero (and (0x20A2) is then
;          cleared) else (0x2083); if (0x207C) already equals A then
;          `or (0x2072),0x10`; (0x207C) = A.
; Evidence: bit 4 of (0x2072) is what PanelScreen_RunRedraw consumes, so
;          `already on that screen` is turned into `redraw it`.
; ---------------------------------------------------------------------
.LF8625E:
PanelScreen_ApplyPendingId:   ; entry: calr from 0xF86109
	ld a, (UI_Request_Hi:16)                            ; F8625E  c1 71 20 21   ld A,(0x2071)
	bit 0x02,A                                    ; F86262  c9 33 02
	jr z, .LF86294                                ; F86265  66 2d
	xor A,A                                       ; F86267  c9 d1
	ld (0x2072:16), a                            ; F86269  f1 72 20 41   ld (0x2072),A
	cp	(0x20a2:16), 0x00                     ; F8626D  c1 a2 20 3f 00   cp (0x20a2),0x00
	jr z, .LF8627F                                ; F86272  66 0b
	ld a, (0x20a2:16)                            ; F86274  c1 a2 20 21   ld A,(0x20a2)
	ld (0x20a2:16), 0x00                          ; F86278  f1 a2 20 00 00   ld (0x20a2),0x00
	jr .LF86283                                   ; F8627D  68 04
.LF8627F:
	ld a, (0x2083:16)                            ; F8627F  c1 83 20 21   ld A,(0x2083)
.LF86283:
	ld w, (UI_ScreenId:16)                            ; F86283  c1 7c 20 20   ld W,(0x207c)
	cp W,A                                        ; F86287  c9 f0
	jr nz, .LF86290                               ; F86289  6e 05
	or	(0x2072:16), 0x10                     ; F8628B  c1 72 20 3e 10   or (0x2072),0x10
.LF86290:
	ld (UI_ScreenId:16), a                            ; F86290  f1 7c 20 41   ld (0x207c),A
.LF86294:
	ret                                           ; F86294  0e

; ---------------------------------------------------------------------
; PanelScreen_ApplyRequest -- (0x207C) := (0x2070), the requested screen
;
; Called from: PanelState_RunRequests 0xF8610C (`calr`), and nothing else.
; Guard:   bit 0 of (0x2095) or bit 4 of (0x2075) clear, then bit 6 or bit 5
;          of (0x2071).
; Outputs: (0x2083) is refreshed from (0x207C) when (0x2073) == 0;
;          (0x207C) = (0x2070); (0x2073) = 0x70; `and (0x2095),0xFD`.
; Evidence: bit 6 (0x40) is the bit PanelState_Init and every live entry of
;          PanelHold_ScreenRequest write together with the screen id.
; ---------------------------------------------------------------------
.LF86295:
PanelScreen_ApplyRequest:   ; entry: calr from 0xF8610C
	bit	0, (UI_ScreenFlags:16)                        ; F86295  f1 95 20 c8   bit 0,(0x2095)
	jr nz, .LF862A2                               ; F86299  6e 07
	bit	4, (UI_RequestBits:16)                        ; F8629B  f1 75 20 cc   bit 4,(0x2075)
	jrl nz, .LF86317                              ; F8629F  7e 75 00
.LF862A2:
	ld a, (UI_Request_Hi:16)                            ; F862A2  c1 71 20 21   ld A,(0x2071)
	bit 0x06,A                                    ; F862A6  c9 33 06
	jr nz, .LF862B0                               ; F862A9  6e 05
	bit 0x05,A                                    ; F862AB  c9 33 05
	jr z, .LF86317                                ; F862AE  66 67
.LF862B0:
	xor W,W                                       ; F862B0  c8 d0
	ld (0x2072:16), w                            ; F862B2  f1 72 20 40   ld (0x2072),W
	bit 0x05,A                                    ; F862B6  c9 33 05
	jr z, .LF862C5                                ; F862B9  66 0a
	ld a, (0x2083:16)                            ; F862BB  c1 83 20 21   ld A,(0x2083)
	ld (0x2083:16), a                            ; F862BF  f1 83 20 41   ld (0x2083),A
	jr .LF862D5                                   ; F862C3  68 10
.LF862C5:
	ld a, (UI_ScreenHoldTimer:16)                            ; F862C5  c1 73 20 21   ld A,(0x2073)
	cp a, 0x00:i3                                   ; F862C9  c9 d8   cp A,0
	jr nz, .LF862D5                               ; F862CB  6e 08
	ld a, (UI_ScreenId:16)                            ; F862CD  c1 7c 20 21   ld A,(0x207c)
	ld (0x2083:16), a                            ; F862D1  f1 83 20 41   ld (0x2083),A
.LF862D5:
	ld a, (UI_Request:16)                            ; F862D5  c1 70 20 21   ld A,(0x2070)
	ld w, (UI_ScreenId:16)                            ; F862D9  c1 7c 20 20   ld W,(0x207c)
	cp W,A                                        ; F862DD  c9 f0
	jr nz, .LF862E8                               ; F862DF  6e 07
	or	(0x2072:16), 0x10                     ; F862E1  c1 72 20 3e 10   or (0x2072),0x10
	jr .LF8630A                                   ; F862E6  68 22
.LF862E8:
	bit	7, (UI_RequestBits:16)                        ; F862E8  f1 75 20 cf   bit 7,(0x2075)
	jr z, .LF86305                                ; F862EC  66 17
	cp	(0x20a2:16), 0x00                     ; F862EE  c1 a2 20 3f 00   cp (0x20a2),0x00
	jr nz, .LF86305                               ; F862F3  6e 10
	bit	1, (UI_ScreenFlags:16)                        ; F862F5  f1 95 20 c9   bit 1,(0x2095)
	jr nz, .LF86305                               ; F862F9  6e 0a
	ld a, (UI_ScreenId:16)                            ; F862FB  c1 7c 20 21   ld A,(0x207c)
	ld a, 0x00:opc                                   ; F862FF  21 00   ld A,0x00
	ld (0x20a2:16), a                            ; F86301  f1 a2 20 41   ld (0x20a2),A
.LF86305:
	and	(UI_ScreenFlags:16), 0xfd                     ; F86305  c1 95 20 3c fd   and (0x2095),0xfd
.LF8630A:
	ld a, (UI_Request:16)                            ; F8630A  c1 70 20 21   ld A,(0x2070)
	ld (UI_ScreenId:16), a                            ; F8630E  f1 7c 20 41   ld (0x207c),A
	ld (UI_ScreenHoldTimer:16), 0x70                          ; F86312  f1 73 20 00 70   ld (0x2073),0x70
.LF86317:
	ret                                           ; F86317  0e

; ---------------------------------------------------------------------
; PanelScreen_ApplyModeChange -- recompute (0x2078) then map it to (0x207C)
;
; Called from: PanelState_RunRequests 0xF8610F (`calr`), and nothing else.
; Guard:   bit 1 of (0x2071).
; Body:    PanelMode_Normalise, then PanelMode_ToScreenId, then (0x2073) = 0;
;          if (0x207C) == (0x207D) then `or (0x2072),0x10` (redraw).
; Evidence: `bit 0x01,A` at 0xF8631C is the guard, and bit 1 is one of the
;          four PanelState_RunRequests clears with `and (0x2071),0x09`.
; ---------------------------------------------------------------------
.LF86318:
PanelScreen_ApplyModeChange:   ; entry: calr from 0xF8610F
	ld a, (UI_Request_Hi:16)                            ; F86318  c1 71 20 21   ld A,(0x2071)
	bit 0x01,A                                    ; F8631C  c9 33 01
	jr z, .LF86343                                ; F8631F  66 22
	xor A,A                                       ; F86321  c9 d1
	ld (0x2072:16), a                            ; F86323  f1 72 20 41   ld (0x2072),A
	calr .LF86344                                 ; F86327  1e 1a 00
	calr .LF86388                                 ; F8632A  1e 5b 00
	ld (UI_ScreenHoldTimer:16), 0x00                          ; F8632D  f1 73 20 00 00   ld (0x2073),0x00
	ld a, (UI_ScreenId:16)                            ; F86332  c1 7c 20 21   ld A,(0x207c)
	ld w, (UI_ScreenId_Previous:16)                            ; F86336  c1 7d 20 20   ld W,(0x207d)
	cp A,W                                        ; F8633A  c8 f1
	jr nz, .LF86343                               ; F8633C  6e 05
	or	(0x2072:16), 0x10                     ; F8633E  c1 72 20 3e 10   or (0x2072),0x10
.LF86343:
	ret                                           ; F86343  0e

; ---------------------------------------------------------------------
; PanelMode_Normalise -- derive (0x2078) from (0x2076) and (0x2070)
;
; Called from: PanelScreen_ApplyModeChange 0xF86327 (`calr`), and nothing else.
; Body:    E = (0x2070); if E == 1 then E = 1, or 2 when (0x7F02) & 0xF0 ==
;          0x10.  D = E.  If (A & 0x3F) != (E & 0x3F) the result is E;
;          otherwise, if bit 7 of D is set, the result is 1 (or 2 under the
;          same (0x7F02) test).  (0x2078) = the result.
; Evidence: (0x7F02) & 0xF0 == 0x10 is the same two-way test PanelState_Init
;          makes at 0xF8602E, and prom_a 0xF90C25 makes on the same cell.
; Unknown:  what the two settings of (0x7F02)'s high nibble ARE.
; ---------------------------------------------------------------------
.LF86344:
PanelMode_Normalise:   ; entry: calr from 0xF86327
	ld w, (0x7f02:16)                            ; F86344  c1 02 7f 20   ld W,(0x7f02)
	and W,0xf0                                    ; F86348  c8 cc f0
	ld a, (PanelModeGroup:16)                            ; F8634B  c1 76 20 21   ld A,(0x2076)
	ld e, (UI_Request:16)                            ; F8634F  c1 70 20 25   ld E,(0x2070)
	cp e, 0x01:i3                                   ; F86353  cd d9   cp E,1
	jr nz, .LF86360                               ; F86355  6e 09
	ld e, 0x01:opc                                   ; F86357  25 01   ld E,0x01
	cp W,0x10                                     ; F86359  c8 cf 10
	jr nz, .LF86360                               ; F8635C  6e 02
	ld e, 0x02:opc                                   ; F8635E  25 02   ld E,0x02
.LF86360:
	ld D,E                                        ; F86360  cd 8c
	and A,0x3f                                    ; F86362  c9 cc 3f
	and E,0x3f                                    ; F86365  cd cc 3f
	xor A,E                                       ; F86368  cd d1
	ld A,E                                        ; F8636A  cd 89
	jr nz, .LF86383                               ; F8636C  6e 15
	bit 0x07,D                                    ; F8636E  cc 33 07
	jr z, .LF86383                                ; F86371  66 10
	ld a, 0x01:opc                                   ; F86373  21 01   ld A,0x01
	ld w, (0x7f02:16)                            ; F86375  c1 02 7f 20   ld W,(0x7f02)
	and W,0xf0                                    ; F86379  c8 cc f0
	cp W,0x10                                     ; F8637C  c8 cf 10
	jr nz, .LF86383                               ; F8637F  6e 02
	ld a, 0x02:opc                                   ; F86381  21 02   ld A,0x02
.LF86383:
	ld (PanelMode:16), a                            ; F86383  f1 78 20 41   ld (0x2078),A
	ret                                           ; F86387  0e

; ---------------------------------------------------------------------
; PanelMode_ToScreenId -- (0x207C) := PanelMode_ToScreenIdMap[(0x2078)]
;
; Called from: PanelScreen_ApplyModeChange 0xF8632A (`calr`), and nothing else.
; Evidence: `ld XHL,0x00f86ea1` at 0xF86388 is the only instruction in
;          either image that names PanelMode_ToScreenIdMap.
; ⚠ Evidence AGAINST the round-1 dossier: this reader has NO bound at all --
;          `xor XWA,XWA / ld A,(0x2078) / add XHL,XWA / ld A,(XHL)`.  The
;          32-entry extent of the map rests only on the code at 0xF86EC1
;          starting there, which is a weaker pin than the map above it has.
; ---------------------------------------------------------------------
.LF86388:
PanelMode_ToScreenId:   ; entry: calr from 0xF8632A
	ld XHL,PanelMode_ToScreenIdMap                ; F86388  43 a1 6e f8 00
	xor XWA,XWA                                   ; F8638D  e8 d0
	ld a, (PanelMode:16)                            ; F8638F  c1 78 20 21   ld A,(0x2078)
	add XHL,XWA                                   ; F86393  e8 83
	ld A,(XHL)                                    ; F86395  83 21
	ld (UI_ScreenId:16), a                            ; F86397  f1 7c 20 41   ld (0x207c),A
	ret                                           ; F8639B  0e

; ---------------------------------------------------------------------
; PanelScreen_ApplyRequestForced -- (0x207C) := (0x2070) and clear (0x2073)
;
; Called from: PanelState_RunRequests 0xF86112 (`calr`), and nothing else.
; Guard:   bit 0 of (0x2095) or bit 4 of (0x2075) clear, then bit 7 of (0x2071).
; Differs from PanelScreen_ApplyRequest only in leaving (0x2083) alone
; and in zeroing (0x2073) instead of loading it with 0x70.
; Evidence: `bit 0x07,A` at 0xF863AC is the guard -- bit 7 of (0x2071), the
;          same bit PanelState_CheckRequestAllowed tests at 0xF86B1F on the
;          high half of the 16-bit load from (0x2070).
; ---------------------------------------------------------------------
.LF8639C:
PanelScreen_ApplyRequestForced:   ; entry: calr from 0xF86112
	bit	0, (UI_ScreenFlags:16)                        ; F8639C  f1 95 20 c8   bit 0,(0x2095)
	jr nz, .LF863A8                               ; F863A0  6e 06
	bit	4, (UI_RequestBits:16)                        ; F863A2  f1 75 20 cc   bit 4,(0x2075)
	jr nz, .LF863D2                               ; F863A6  6e 2a
.LF863A8:
	ld a, (UI_Request_Hi:16)                            ; F863A8  c1 71 20 21   ld A,(0x2071)
	bit 0x07,A                                    ; F863AC  c9 33 07
	jr z, .LF863D2                                ; F863AF  66 21
	xor A,A                                       ; F863B1  c9 d1
	ld (0x2072:16), a                            ; F863B3  f1 72 20 41   ld (0x2072),A
	ld a, (UI_Request:16)                            ; F863B7  c1 70 20 21   ld A,(0x2070)
	ld w, (UI_ScreenId:16)                            ; F863BB  c1 7c 20 20   ld W,(0x207c)
	cp W,A                                        ; F863BF  c9 f0
	jr nz, .LF863C8                               ; F863C1  6e 05
	or	(0x2072:16), 0x10                     ; F863C3  c1 72 20 3e 10   or (0x2072),0x10
.LF863C8:
	ld (UI_ScreenId:16), a                            ; F863C8  f1 7c 20 41   ld (0x207c),A
	xor A,A                                       ; F863CC  c9 d1
	ld (UI_ScreenHoldTimer:16), a                            ; F863CE  f1 73 20 41   ld (0x2073),A
.LF863D2:
	ret                                           ; F863D2  0e

; ---------------------------------------------------------------------
; PanelState_UpdateScreenHoldState -- fold `(0x2073) is running` into (0x2092)
;
; Called from: PanelTask_Step 0xF86075 (`calr`), and nothing else.
; Outputs: (0x2073) != 0 -> bit 0 = 1, bit 1 = 0;  (0x2073) == 0 -> bit 0 =
;          0, bit 1 = the OLD bit 0.  Bits 2-7 are preserved (`and A,0xfc`).
; Evidence: PanelState_UpdateScreenLatch at 0xF86405 tests exactly bit 0 of this
;          byte, so bit 0 means `the (0x2073) countdown is running` and
;          bit 1 means `it was running last pass`.
; ---------------------------------------------------------------------
.LF863D3:
PanelState_UpdateScreenHoldState:   ; entry: calr from 0xF86075
	ld a, (UI_ScreenHoldState:16)                            ; F863D3  c1 92 20 21   ld A,(0x2092)
	ld W,A                                        ; F863D7  c9 88
	and A,0xfc                                    ; F863D9  c9 cc fc
	ld l, (UI_ScreenHoldTimer:16)                            ; F863DC  c1 73 20 27   ld L,(0x2073)
	cp l, 0x00:i3                                   ; F863E0  cf d8   cp L,0
	jr z, .LF863E8                                ; F863E2  66 04
	ld w, 0x01:opc                                   ; F863E4  20 01   ld W,0x01
	jr .LF863EE                                   ; F863E6  68 06
.LF863E8:
	sla w, 0x01                                   ; F863E8  c8 ec 01   sla 0x01,W
	and W,0x02                                    ; F863EB  c8 cc 02
.LF863EE:
	or A,W                                        ; F863EE  c8 e1
	ld (UI_ScreenHoldState:16), a                            ; F863F0  f1 92 20 41   ld (0x2092),A
	ret                                           ; F863F4  0e

; ---------------------------------------------------------------------
; PanelState_UpdateScreenLatch -- (0x207A) := (0x207C) unless the mode is unchanged
;                          and bit 0 of (0x2092) is set
;
; Called from: PanelTask_Step 0xF86078 (`calr`), and nothing else.
; Evidence: `bit 0x00,A` at 0xF86405 on (0x2092), the bit
;          PanelState_UpdateScreenHoldState writes from (0x2073).
; ---------------------------------------------------------------------
.LF863F5:
PanelState_UpdateScreenLatch:   ; entry: calr from 0xF86078
	ld w, (PanelMode:16)                            ; F863F5  c1 78 20 20   ld W,(0x2078)
	ld a, (PanelMode_Previous:16)                            ; F863F9  c1 79 20 21   ld A,(0x2079)
	cp W,A                                        ; F863FD  c9 f0
	jr nz, .LF8640A                               ; F863FF  6e 09
	ld a, (UI_ScreenHoldState:16)                            ; F86401  c1 92 20 21   ld A,(0x2092)
	bit 0x00,A                                    ; F86405  c9 33 00
	jr nz, .LF86412                               ; F86408  6e 08
.LF8640A:
	ld a, (UI_ScreenId:16)                            ; F8640A  c1 7c 20 21   ld A,(0x207c)
	ld (UI_ScreenLatch:16), a                            ; F8640E  f1 7a 20 41   ld (0x207a),A
.LF86412:
	ret                                           ; F86412  0e

; ---------------------------------------------------------------------
; PanelState_ClearOnChange -- drop held-button state when an id changes
;
; Called from: PanelTask_Step 0xF8607B (`calr`), and nothing else.
; Outputs: (0x2078)!=(0x2079): (0x2088)=(0x208C)=0, `and (0x2075),0x04`,
;          `and (0x2095),0xEF`, `or (0x2134),0x0002`, (0x20A2)=0.
;          (0x207A)!=(0x207B): (0x2088)=(0x208C)=0, (0x207E)=A,
;          `and (0x2075),0x04`, (0x20A2)=0.
;          (0x207C)!=(0x207D): `and (0x2075),0x94`,
;          `and (0x2088),0xF7FFFFFF`, `and (0x2095),0xEF`, (0x20AB)=A.
;          Always: `and (0x2095),0xFE`.
; Evidence: 0xF86473 loads the 32-bit literal 0xF7FFFFFF and ANDs it into
;          (0x2088) -- clearing bit 27 only, i.e. button index 27 -- which is
;          a second, independent witness that (0x2088) is a 32-bit bitmap
;          over the same index space PanelButton_BitMask32 spans.
; ---------------------------------------------------------------------
.LF86413:
PanelState_ClearOnChange:   ; entry: calr from 0xF8607B
	ld a, (PanelMode:16)                            ; F86413  c1 78 20 21   ld A,(0x2078)
	ld w, (PanelMode_Previous:16)                            ; F86417  c1 79 20 20   ld W,(0x2079)
	cp A,W                                        ; F8641B  c8 f1
	jr z, .LF8643E                                ; F8641D  66 1f
	xor WA,WA                                     ; F8641F  d8 d0
	ld (PanelButton_HeldMask:16), wa                           ; F86421  f1 88 20 50   ld (0x2088),WA
	ld (0x208c:16), wa                           ; F86425  f1 8c 20 50   ld (0x208c),WA
	and	(UI_RequestBits:16), 0x04                     ; F86429  c1 75 20 3c 04   and (0x2075),0x04
	and	(UI_ScreenFlags:16), 0xef                     ; F8642E  c1 95 20 3c ef   and (0x2095),0xef
	orw	(0x2134:16), 0x0002                  ; F86433  d1 34 21 3e 02 00
	ld (0x20a2:16), 0x00                          ; F86439  f1 a2 20 00 00   ld (0x20a2),0x00
.LF8643E:
	ld a, (UI_ScreenLatch:16)                            ; F8643E  c1 7a 20 21   ld A,(0x207a)
	ld w, (UI_ScreenLatch_Previous:16)                            ; F86442  c1 7b 20 20   ld W,(0x207b)
	cp A,W                                        ; F86446  c8 f1
	jr z, .LF86462                                ; F86448  66 18
	xor WA,WA                                     ; F8644A  d8 d0
	ld (PanelButton_HeldMask:16), wa                           ; F8644C  f1 88 20 50   ld (0x2088),WA
	ld (0x208c:16), wa                           ; F86450  f1 8c 20 50   ld (0x208c),WA
	ld (UI_ScreenStage:16), a                            ; F86454  f1 7e 20 41   ld (0x207e),A
	and	(UI_RequestBits:16), 0x04                     ; F86458  c1 75 20 3c 04   and (0x2075),0x04
	ld (0x20a2:16), 0x00                          ; F8645D  f1 a2 20 00 00   ld (0x20a2),0x00
.LF86462:
	ld a, (UI_ScreenId:16)                            ; F86462  c1 7c 20 21   ld A,(0x207c)
	ld w, (UI_ScreenId_Previous:16)                            ; F86466  c1 7d 20 20   ld W,(0x207d)
	cp A,W                                        ; F8646A  c8 f1
	jr z, .LF86487                                ; F8646C  66 19
	and	(UI_RequestBits:16), 0x94                     ; F8646E  c1 75 20 3c 94   and (0x2075),0x94
	ld XWA,0xf7ffffff                             ; F86473  40 ff ff ff f7
	and	(PanelButton_HeldMask:16), xwa                     ; F86478  e1 88 20 c8
	and	(UI_ScreenFlags:16), 0xef                     ; F8647C  c1 95 20 3c ef   and (0x2095),0xef
	xor WA,WA                                     ; F86481  d8 d0
	ld (0x20ab:16), a                            ; F86483  f1 ab 20 41   ld (0x20ab),A
.LF86487:
	and	(UI_ScreenFlags:16), 0xfe                     ; F86487  c1 95 20 3c fe   and (0x2095),0xfe
	ret                                           ; F8648C  0e

; ---------------------------------------------------------------------
; PanelScreen_RunLeave -- call the Leave method of every id that changed
;
; Called from: PanelTask_Step 0xF8607E, sub_F8605C 0xF8605C (`calr`).
; Body:    (0x207C) != (0x207D) -> Leave on the PREVIOUS id (0x207D);
;          (0x207A) == (0x207C) and (0x207D) != (0x207B) -> Leave on (0x207B);
;          (0x2078) != (0x2079) -> Leave (view A) on (0x2079).
; Evidence: every one of the three passes the PREVIOUS cell of a pair, and
;          the method offset is 4 in all three -- `ld BC,0x0004` at 0xF864D3
;          and 0xF864F1.
; ---------------------------------------------------------------------
.LF8648D:
PanelScreen_RunLeave:   ; entry: calr from 0xF8605C, 0xF8607E
	xor HL,HL                                     ; F8648D  db d3
	ld l, (UI_ScreenId_Previous:16)                            ; F8648F  c1 7d 20 27   ld L,(0x207d)
	cp (UI_ScreenId:16), l                             ; F86493  c1 7c 20 ff   cp (0x207c),L
	jr z, .LF8649C                                ; F86497  66 03
	calr .LF864C7                                 ; F86499  1e 2b 00
.LF8649C:
	ld a, (UI_ScreenId:16)                            ; F8649C  c1 7c 20 21   ld A,(0x207c)
	ld w, (UI_ScreenLatch:16)                            ; F864A0  c1 7a 20 20   ld W,(0x207a)
	cp W,A                                        ; F864A4  c9 f0
	jr nz, .LF864B7                               ; F864A6  6e 0f
	xor HL,HL                                     ; F864A8  db d3
	ld l, (UI_ScreenLatch_Previous:16)                            ; F864AA  c1 7b 20 27   ld L,(0x207b)
	cp (UI_ScreenId_Previous:16), l                             ; F864AE  c1 7d 20 ff   cp (0x207d),L
	jr z, .LF864B7                                ; F864B2  66 03
	calr .LF864C7                                 ; F864B4  1e 10 00
.LF864B7:
	xor HL,HL                                     ; F864B7  db d3
	ld l, (PanelMode_Previous:16)                            ; F864B9  c1 79 20 27   ld L,(0x2079)
	cp (PanelMode:16), l                             ; F864BD  c1 78 20 ff   cp (0x2078),L
	jr z, .LF864C6                                ; F864C1  66 03
	calr .LF864E5                                 ; F864C3  1e 1f 00
.LF864C6:
	ret                                           ; F864C6  0e

; ---------------------------------------------------------------------
; PanelScreen_CallLeave_B -- vtable[L].Leave, table view B (base 0xF86F41)
;
; Called from: PanelScreen_RunLeave 0xF86499 and 0xF864B4 (`calr`).
; Inputs:  L = a screen id; the guard is `cp L,0xdf` at 0xF864C9.
; Outputs: nothing when L > 0xDF; else PanelScreen_ResolveMethod with
;          XIY = 0xF86F41 and BC = 4, then `call XWA`.
; Evidence: `ld XIY,0x00f86f41` at 0xF864CE and `ld BC,0x0004` at 0xF864D3
;          -- table view B, method offset 4.
; ---------------------------------------------------------------------
.LF864C7:
PanelScreen_CallLeave_B:   ; entry: calr from 0xF86499, 0xF864B4
	xor H,H                                       ; F864C7  ce d6
	cp L,0xdf                                     ; F864C9  cf cf df
	jr ugt, .LF864DB                              ; F864CC  6b 0d
	ld XIY,PanelScreen_VtableTable_ViewB          ; F864CE  45 41 6f f8 00
	ldw bc, 0x04                                  ; F864D3  31 04 00   ld BC,0x0004
	calr .LF86543                                 ; F864D6  1e 6a 00
	call (xwa)                                    ; F864D9  b0 e8   call T,XWA
.LF864DB:
	ld XWA,0x00000000                             ; F864DB  40 00 00 00 00
	ld (PanelButton_HeldMask:16), xwa                          ; F864E0  f1 88 20 60   ld (0x2088),XWA
	ret                                           ; F864E4  0e

; ---------------------------------------------------------------------
; PanelScreen_CallLeave_A -- vtable[L].Leave, table view A (base 0xF86EC1)
;
; Called from: PanelScreen_RunLeave 0xF864C3 (`calr`), and nothing else.
; Inputs:  L = a mode index; the guard is `cp L,0x2f` at 0xF864E7.
; Evidence: `ld XIY,0x00f86ec1` at 0xF864EC and `ld BC,0x0004` at 0xF864F1
;          -- table view A, method offset 4.
; ---------------------------------------------------------------------
.LF864E5:
PanelScreen_CallLeave_A:   ; entry: calr from 0xF864C3
	xor H,H                                       ; F864E5  ce d6
	cp L,0x2f                                     ; F864E7  cf cf 2f
	jr ugt, .LF864F9                              ; F864EA  6b 0d
	ld XIY,PanelScreen_VtableTable                ; F864EC  45 c1 6e f8 00
	ldw bc, 0x04                                  ; F864F1  31 04 00   ld BC,0x0004
	calr .LF86543                                 ; F864F4  1e 4c 00
	call (xwa)                                    ; F864F7  b0 e8   call T,XWA
.LF864F9:
	ret                                           ; F864F9  0e

; ---------------------------------------------------------------------
; PanelScreen_RunEnter -- call the Enter method of every id that changed
;
; Called from: PanelTask_Step 0xF86081, sub_F8605C 0xF8605F (`calr`).
; Body:    (0x2078) != (0x2079) -> Enter (view A) on the CURRENT (0x2078);
;          (0x207C) != (0x207D) -> Enter (view B) on the CURRENT (0x207C).
; Evidence: both pass the CURRENT cell and `ld BC,0x0000` (0xF86525,
;          0xF8653A) -- method offset 0, against offset 4 in RunLeave.  That
;          pairing is what fixes which method is Enter and which is Leave.
; ---------------------------------------------------------------------
.LF864FA:
PanelScreen_RunEnter:   ; entry: calr from 0xF8605F, 0xF86081
	xor HL,HL                                     ; F864FA  db d3
	ld l, (PanelMode:16)                            ; F864FC  c1 78 20 27   ld L,(0x2078)
	cp (PanelMode_Previous:16), l                             ; F86500  c1 79 20 ff   cp (0x2079),L
	jr z, .LF86509                                ; F86504  66 03
	calr .LF86519                                 ; F86506  1e 10 00
.LF86509:
	xor HL,HL                                     ; F86509  db d3
	ld l, (UI_ScreenId:16)                            ; F8650B  c1 7c 20 27   ld L,(0x207c)
	cp (UI_ScreenId_Previous:16), l                             ; F8650F  c1 7d 20 ff   cp (0x207d),L
	jr z, .LF86518                                ; F86513  66 03
	calr .LF8652E                                 ; F86515  1e 16 00
.LF86518:
	ret                                           ; F86518  0e

; ---------------------------------------------------------------------
; PanelScreen_CallEnter_A -- vtable[L].Enter, table view A (base 0xF86EC1)
;
; Called from: PanelScreen_RunEnter 0xF86506 (`calr`), and nothing else.
; Inputs:  L = a mode index; the guard is `cp L,0x2f` at 0xF8651B.
; Evidence: `ld XIY,0x00f86ec1` at 0xF86520 and `ld BC,0x0000` at 0xF86525
;          -- table view A, method offset 0.
; ---------------------------------------------------------------------
.LF86519:
PanelScreen_CallEnter_A:   ; entry: calr from 0xF86506
	xor H,H                                       ; F86519  ce d6
	cp L,0x2f                                     ; F8651B  cf cf 2f
	jr ugt, .LF8652D                              ; F8651E  6b 0d
	ld XIY,PanelScreen_VtableTable                ; F86520  45 c1 6e f8 00
	ldw bc, 0x00                                  ; F86525  31 00 00   ld BC,0x0000
	calr .LF86543                                 ; F86528  1e 18 00
	call (xwa)                                    ; F8652B  b0 e8   call T,XWA
.LF8652D:
	ret                                           ; F8652D  0e

; ---------------------------------------------------------------------
; PanelScreen_CallEnter_B -- vtable[L].Enter, table view B (base 0xF86F41)
;
; Called from: PanelScreen_RunEnter 0xF86515 and PanelScreen_RunRedraw
;          0xF86597 (`calr`).
; Inputs:  L = a screen id; the guard is `cp L,0xdf` at 0xF86530.
; Evidence: `ld XIY,0x00f86f41` at 0xF86535 and `ld BC,0x0000` at 0xF8653A
;          -- table view B, method offset 0.
; ---------------------------------------------------------------------
.LF8652E:
PanelScreen_CallEnter_B:   ; entry: calr from 0xF86515, 0xF86597
	xor H,H                                       ; F8652E  ce d6
	cp L,0xdf                                     ; F86530  cf cf df
	jr ugt, .LF86542                              ; F86533  6b 0d
	ld XIY,PanelScreen_VtableTable_ViewB          ; F86535  45 41 6f f8 00
	ldw bc, 0x00                                  ; F8653A  31 00 00   ld BC,0x0000
	calr .LF86543                                 ; F8653D  1e 03 00
	call (xwa)                                    ; F86540  b0 e8   call T,XWA
.LF86542:
	ret                                           ; F86542  0e

; ---------------------------------------------------------------------
; PanelScreen_ResolveMethod -- XWA := vtable_table[HL] + BC, remembered in
;                              (0x20B4)
;
; Called from: all four of PanelScreen_CallEnter_A/B and CallLeave_A/B.
; Inputs:  HL = the index, XIY = the table base, BC = the method offset.
; Outputs: XWA = the method address; (0x20B4) = the same value.
; Evidence: `sla 0x02,HL` at 0xF86545 is the 4-byte stride of an LE32
;          pointer table; `add WA,BC` at 0xF8654C adds only to the low 16
;          bits, which is safe because BC is 0 or 4 at every call site.
; ---------------------------------------------------------------------
.LF86543:
PanelScreen_ResolveMethod:   ; entry: calr from 0xF864D6, 0xF864F4, 0xF86528, 0xF8653D
	extz XHL                                      ; F86543  eb 12
	sla hl, 0x02                                  ; F86545  db ec 02   sla 0x02,HL
	add XHL,XIY                                   ; F86548  ed 83
	ld XWA,(XHL)                                  ; F8654A  a3 20
	add WA,BC                                     ; F8654C  d9 80
	ld (0x20b4:16), xwa                          ; F8654E  f1 b4 20 60   ld (0x20b4),XWA
	ret                                           ; F86552  0e

; ---------------------------------------------------------------------
; PanelState_SyncScreenFlags -- move bit 4 between (0x2095) and (0x2071), then
;                        publish (0x2071) into (0x2072) when it is quiet
;
; Called from: PanelTask_Step 0xF86069 (`calr`), and nothing else.
; Body:    bit 4 of (0x2095) set: clear it when bit 4 of (0x2071) is already
;          SET (the request is in flight; `jr z` at 0xF8655D skips the clear
;          while it is still clear), and set bit 4 of (0x2071) either way.  Then, only when
;          (0x2071) & 0xE2 == 0, (0x2072) = (0x2071) and (0x2071) &= 0xEF.
; ⚠ Note:  0xF86570 RELOADS A from (0x2071) after the `and A,0xe2` at
;          0xF8656D, so the `jr NZ` two instructions later tests the AND,
;          not the reload; the value STORED to (0x2072) is the unmasked
;          byte.  Written out because it reads like a bug and is not one.
; Evidence: `bit 4,(0x2095)` at 0xF86553 and `bit 4,(0x2071)` at 0xF86559
;          are the two tested bits; `and A,0xe2` at 0xF8656D is the quiet
;          test; `and A,0xef` at 0xF8657A clears the same bit 4 again.
; ---------------------------------------------------------------------
.LF86553:
PanelState_SyncScreenFlags:   ; entry: calr from 0xF86069
	bit	4, (UI_ScreenFlags:16)                        ; F86553  f1 95 20 cc   bit 4,(0x2095)
	jr z, .LF86569                                ; F86557  66 10
	bit	4, (UI_Request_Hi:16)                        ; F86559  f1 71 20 cc   bit 4,(0x2071)
	jr z, .LF86564                                ; F8655D  66 05
	and	(UI_ScreenFlags:16), 0xef                     ; F8655F  c1 95 20 3c ef   and (0x2095),0xef
.LF86564:
	or	(UI_Request_Hi:16), 0x10                     ; F86564  c1 71 20 3e 10   or (0x2071),0x10
.LF86569:
	ld a, (UI_Request_Hi:16)                            ; F86569  c1 71 20 21   ld A,(0x2071)
	and A,0xe2                                    ; F8656D  c9 cc e2
	ld a, (UI_Request_Hi:16)                            ; F86570  c1 71 20 21   ld A,(0x2071)
	jr nz, .LF86581                               ; F86574  6e 0b
	ld (0x2072:16), a                            ; F86576  f1 72 20 41   ld (0x2072),A
	and A,0xef                                    ; F8657A  c9 cc ef
	ld (UI_Request_Hi:16), a                            ; F8657D  f1 71 20 41   ld (0x2071),A
.LF86581:
	ret                                           ; F86581  0e

; ---------------------------------------------------------------------
; PanelScreen_RunRedraw -- re-Enter the current screen when bit 4 of (0x2072)
;
; Called from: PanelTask_Step 0xF86084, sub_F8605C 0xF86062 (`calr`).
; Body:    if bit 4 of (0x2072): (0x2072) = 0, L = (0x207C),
;          PanelScreen_CallEnter_B.
; Evidence: bit 4 of (0x2072) is set by exactly the four `or (0x2072),0x10`
;          at 0xF8628B, 0xF862E1, 0xF863C3 and 0xF8633E, each on the path
;          `the requested id EQUALS the current one` -- so `no transition,
;          redraw anyway`.
; ---------------------------------------------------------------------
.LF86582:
PanelScreen_RunRedraw:   ; entry: calr from 0xF86062, 0xF86084
	ld a, (0x2072:16)                            ; F86582  c1 72 20 21   ld A,(0x2072)
	bit 0x04,A                                    ; F86586  c9 33 04
	jr z, .LF8659A                                ; F86589  66 0f
	xor A,A                                       ; F8658B  c9 d1
	ld (0x2072:16), a                            ; F8658D  f1 72 20 41   ld (0x2072),A
	xor HL,HL                                     ; F86591  db d3
	ld l, (UI_ScreenId:16)                            ; F86593  c1 7c 20 27   ld L,(0x207c)
	calr .LF8652E                                 ; F86597  1e 94 ff
.LF8659A:
	ret                                           ; F8659A  0e

; ---------------------------------------------------------------------
; UiEvent_RouteByCode -- split a class-0xA9 event on its code byte (0x20B8)
;
; Called from: thunk slot T_UiEvent_RouteByCode (T_F40F58) (`jp 0x00F8659B`), which has NO proven
;          `call` site -- and from UiEventLists_C's list for class 0xA9
;          (0xF89362), whose first LE32 entry is 0x00F8659B.  ★ That list is
;          the answer to `who calls this`: an event {0xA9, code, b2, b3}
;          posted into RAM 0x2030 reaches here through UiEventList_RunPassC.
; Body:    A = (0x20B8);  A < 0x20 -> PanelButton_Accept;
;          A == 0x20 -> PanelEvent_Code20_SetScreen;
;          A == 0x21 -> PanelEvent_Code21_Dial.
; Evidence: the three-way split at 0xF8659F-0xF865B8 and the 0x1F index mask
;          PanelButton_Accept applies at 0xF8660D agree: codes 0x00-0x1F are
;          the 32 buttons PanelButton_BitMask32 spans.
; ---------------------------------------------------------------------
UiEvent_RouteByCode:   ; entry: prom_b directory slot T_UiEvent_RouteByCode (T_F40F58)
	ld a, (UiEvent_Byte1:16)                            ; F8659B  c1 b8 20 21   ld A,(0x20b8)
	cp A,0x20                                     ; F8659F  c9 cf 20
	jr nc, .LF865A9                               ; F865A2  6f 05
	calr .LF86609                                 ; F865A4  1e 62 00
	jr .LF865BB                                   ; F865A7  68 12
.LF865A9:
	cp A,0x20                                     ; F865A9  c9 cf 20
	jr nz, .LF865B3                               ; F865AC  6e 05
	calr PanelEvent_Code20_SetScreen                                   ; F865AE  1e 69 02   calr 0xf8681a
	jr .LF865BB                                   ; F865B1  68 08
.LF865B3:
	cp A,0x21                                     ; F865B3  c9 cf 21
	jr nz, .LF865BB                               ; F865B6  6e 03
	calr PanelEvent_Code21_Dial                                   ; F865B8  1e 78 02   calr 0xf86833
.LF865BB:
	ret                                           ; F865BB  0e

; ---------------------------------------------------------------------
; PanelEvent_Code03 -- toggle bit 4 of (0x2075) on event code 3
;
; Called from: thunk slot T_PanelEvent_Code03 (T_F40F90) (`jp 0x00F865BC`); no proven call site,
;          and no list in any of the three class tables names it.
; Inputs:  (0x20B8) must be 3; L = (0x20B9), H = (0x20BA), and bit 0 of
;          (L & H) must be set.
; Outputs: `xor (0x2075),0x10`, then either `or (0x2075),0x80` or
;          (0x2073) = 1, and `or (0x2134),0x2000`.
; Evidence: the guard is `cp A,3` at 0xF865C8 on (0x20B8), which
;          UiEventList_Run loads from the record's byte +1.
; Unknown:  which physical control raises code 3.  Nothing in any of the
;          366 lists of the three class tables points at this address, so
;          the only published way in is the thunk slot.
; ---------------------------------------------------------------------
PanelEvent_Code03:   ; entry: prom_b directory slot T_PanelEvent_Code03 (T_F40F90)
	ld l, (UiEvent_Byte2:16)                            ; F865BC  c1 b9 20 27   ld L,(0x20b9)
	ld h, (UiEvent_Byte3:16)                            ; F865C0  c1 ba 20 26   ld H,(0x20ba)
	ld a, (UiEvent_Byte1:16)                            ; F865C4  c1 b8 20 21   ld A,(0x20b8)
	cp a, 0x03:i3                                   ; F865C8  c9 db   cp A,3
	jr nz, .LF86608                               ; F865CA  6e 3c
	and L,H                                       ; F865CC  ce c7
	bit 0x00,L                                    ; F865CE  cf 33 00
	jr z, .LF86608                                ; F865D1  66 35
	xor	(UI_RequestBits:16), 0x10                     ; F865D3  c1 75 20 3d 10   xor (0x2075),0x10
	bit	4, (UI_RequestBits:16)                        ; F865D8  f1 75 20 cc   bit 4,(0x2075)
	jr z, .LF865EB                                ; F865DC  66 0d
	bit	0, (UI_ScreenHoldState:16)                        ; F865DE  f1 92 20 c8   bit 0,(0x2092)
	jr z, .LF865E9                                ; F865E2  66 05
	or	(UI_RequestBits:16), 0x80                     ; F865E4  c1 75 20 3e 80   or (0x2075),0x80
.LF865E9:
	jr .LF86602                                   ; F865E9  68 17
.LF865EB:
	bit	0, (UI_ScreenHoldState:16)                        ; F865EB  f1 92 20 c8   bit 0,(0x2092)
	jr z, .LF86602                                ; F865EF  66 11
	cp	(0x20a2:16), 0x00                     ; F865F1  c1 a2 20 3f 00   cp (0x20a2),0x00
	jr nz, .LF865FD                               ; F865F6  6e 05
	and	(UI_RequestBits:16), 0x7f                     ; F865F8  c1 75 20 3c 7f   and (0x2075),0x7f
.LF865FD:
	ld (UI_ScreenHoldTimer:16), 0x01                          ; F865FD  f1 73 20 00 01   ld (0x2073),0x01
.LF86602:
	orw	(0x2134:16), 0x2000                  ; F86602  d1 34 21 3e 00 20
.LF86608:
	ret                                           ; F86608  0e

; ---------------------------------------------------------------------
; PanelButton_Accept -- fold one button event into the (0x2088) bitmap
;
; Called from: UiEvent_RouteByCode 0xF865A4 (`calr`), and nothing else.
; Inputs:  (0x20B8) the button code, (0x20B9)/(0x20BA) the two state bytes.
; Body:    index 0x0D with bit 0 of (0x2075) set is REWRITTEN: the code
;          becomes (0x209C) or (0x209B) (chosen by bit 1 of (0x20BA)) and
;          (0x20BA) becomes 2, or 1 when bit 7 of that code is set.
;          Then mask = PanelButton_BitMask32[code & 0x1F].
;          RELEASE ((0x20B9) & (0x20BA) == 0): clear mask in (0x2088) and
;          (0x208C); if (0x2088) is then zero, (0x2074) = 0 and
;          `and (0x2075),0xF3`.
;          PRESS: if PanelButton_InterlockMask32[code] hits (0x2252) or
;          (0x2256), do nothing at all; else set mask in (0x2088), in
;          (0x208C) when (0x20B9) == 3, and in (0x2084) -- then clear it in
;          (0x2084) again unless bit 0 of (0x20B9) is set.  Finally
;          (0x2082) = code (| 0x80 when bit 0 of (0x20B9)) and
;          `or (0x2071),0x01`, which is what makes PanelButton_RunPending
;          route it on the next PanelTask_Step.
; Evidence: the two mask tables are read four instructions apart, at
;          0xF86659 (PanelButton_BitMask32) and 0xF86696
;          (PanelButton_InterlockMask32), both indexed by the SAME `BC =
;          code * 4` formed at 0xF86654-0xF86656.  That shared index is
;          what makes the two tables one per-button record split in two.
; ⚠ Correction: (0x2084) is a THIRD 32-bit bitmap, not the high half of a
;          64-bit word with (0x2088)/(0x208C).  0xF866C3 sets the mask there
;          and 0xF866D3 clears it there, both independently of (0x208C).
; ---------------------------------------------------------------------
.LF86609:
PanelButton_Accept:   ; entry: calr from 0xF865A4
	ld c, (UiEvent_Byte1:16)                            ; F86609  c1 b8 20 23   ld C,(0x20b8)
	and C,0x1f                                    ; F8660D  cb cc 1f
	cp C,0x0d                                     ; F86610  cb cf 0d
	jr nz, .LF86654                               ; F86613  6e 3f
	bit	0, (UI_RequestBits:16)                        ; F86615  f1 75 20 c8   bit 0,(0x2075)
	jr z, .LF86654                                ; F86619  66 39
	ld c, (PanelDial_UpButton:16)                            ; F8661B  c1 9c 20 23   ld C,(0x209c)
	bit	1, (UiEvent_Byte3:16)                        ; F8661F  f1 ba 20 c9   bit 1,(0x20ba)
	jr nz, .LF86629                               ; F86623  6e 04
	ld c, (PanelDial_DownButton:16)                            ; F86625  c1 9b 20 23   ld C,(0x209b)
.LF86629:
	ld (UiEvent_Byte1:16), c                            ; F86629  f1 b8 20 43   ld (0x20b8),C
	and	(UiEvent_Byte1:16), 0x1f                     ; F8662D  c1 b8 20 3c 1f   and (0x20b8),0x1f
	ld (UiEvent_Byte3:16), 0x02                          ; F86632  f1 ba 20 00 02   ld (0x20ba),0x02
	bit 0x07,C                                    ; F86637  cb 33 07
	jr z, .LF86641                                ; F8663A  66 05
	ld (UiEvent_Byte3:16), 0x01                          ; F8663C  f1 ba 20 00 01   ld (0x20ba),0x01
.LF86641:
	cp	(UiEvent_Byte2:16), 0x00                     ; F86641  c1 b9 20 3f 00   cp (0x20b9),0x00
	jr z, .LF86650                                ; F86646  66 08
	ld c, (UiEvent_Byte3:16)                            ; F86648  c1 ba 20 23   ld C,(0x20ba)
	ld (UiEvent_Byte2:16), c                            ; F8664C  f1 b9 20 43   ld (0x20b9),C
.LF86650:
	ld c, (UiEvent_Byte1:16)                            ; F86650  c1 b8 20 23   ld C,(0x20b8)
.LF86654:
	extz BC                                       ; F86654  d9 12
	sll bc, 0x02                                  ; F86656  d9 ee 02   sll 0x02,BC
	ld XWA,PanelButton_BitMask32                  ; F86659  40 1a 67 f8 00
	add WA,BC                                     ; F8665E  d9 80
	ld XWA,(XWA)                                  ; F86660  a0 20
	ld e, (UiEvent_Byte2:16)                            ; F86662  c1 b9 20 25   ld E,(0x20b9)
	ld d, (UiEvent_Byte3:16)                            ; F86666  c1 ba 20 24   ld D,(0x20ba)
	and E,D                                       ; F8666A  cc c5
	jr nz, .LF86695                               ; F8666C  6e 27
	xor XWA,0xffffffff                            ; F8666E  e8 cd ff ff ff ff
	and	(PanelButton_HeldMask:16), xwa                     ; F86674  e1 88 20 c8
	and	(0x208c:16), xwa                     ; F86678  e1 8c 20 c8
	ld xwa, (PanelButton_HeldMask:16)                          ; F8667C  e1 88 20 20   ld XWA,(0x2088)
	cp XWA,0x00000000                             ; F86680  e8 cf 00 00 00 00
	jr nz, .LF866F8                               ; F86686  6e 70
	xor A,A                                       ; F86688  c9 d1
	ld (PanelButton_RepeatTimer:16), a                            ; F8668A  f1 74 20 41   ld (0x2074),A
	and	(UI_RequestBits:16), 0xf3                     ; F8668E  c1 75 20 3c f3   and (0x2075),0xf3
	jr .LF866F8                                   ; F86693  68 63
.LF86695:
	push XWA                                      ; F86695  38
	ld XWA,PanelButton_InterlockMask32            ; F86696  40 9a 67 f8 00
	add WA,BC                                     ; F8669B  d9 80
	ld XDE,(XWA)                                  ; F8669D  a0 22
	and	xde, (PanelHeld_Pos0:16)                      ; F8669F  e1 52 22 c2   and XDE,(0x2252)
	jr nz, .LF866AF                               ; F866A3  6e 0a
	ld XDE,(XWA)                                  ; F866A5  a0 22
	and	xde, (PanelHeld_Pos1:16)                      ; F866A7  e1 56 22 c2   and XDE,(0x2256)
	jr nz, .LF866AF                               ; F866AB  6e 02
	jr .LF866B2                                   ; F866AD  68 03
.LF866AF:
	pop XWA                                       ; F866AF  58
	jr .LF86719                                   ; F866B0  68 67
.LF866B2:
	pop XWA                                       ; F866B2  58
	or	(PanelButton_HeldMask:16), xwa                     ; F866B3  e1 88 20 e8
	ld b, (UiEvent_Byte2:16)                            ; F866B7  c1 b9 20 22   ld B,(0x20b9)
	cp b, 0x03:i3                                   ; F866BB  ca db   cp B,3
	jr nz, .LF866C3                               ; F866BD  6e 04
	or	(0x208c:16), xwa                     ; F866BF  e1 8c 20 e8
.LF866C3:
	or	(PanelButton_HeldPairPos:16), xwa                     ; F866C3  e1 84 20 e8
	bit	0, (UiEvent_Byte2:16)                        ; F866C7  f1 b9 20 c8   bit 0,(0x20b9)
	jr nz, .LF866D7                               ; F866CB  6e 0a
	xor XWA,0xffffffff                            ; F866CD  e8 cd ff ff ff ff
	and	(PanelButton_HeldPairPos:16), xwa                     ; F866D3  e1 84 20 c8
.LF866D7:
	ld a, (UI_RequestBits:16)                            ; F866D7  c1 75 20 21   ld A,(0x2075)
	bit 0x02,A                                    ; F866DB  c9 33 02
	jr nz, .LF866EA                               ; F866DE  6e 0a
	ld (PanelButton_RepeatTimer:16), 0x10                          ; F866E0  f1 74 20 00 10   ld (0x2074),0x10
	and	(UI_RequestBits:16), 0xf3                     ; F866E5  c1 75 20 3c f3   and (0x2075),0xf3
.LF866EA:
	ld a, (UI_ScreenHoldTimer:16)                            ; F866EA  c1 73 20 21   ld A,(0x2073)
	cp a, 0x00:i3                                   ; F866EE  c9 d8   cp A,0
	jr z, .LF866F8                                ; F866F0  66 06
	ld a, 0x70:opc                                   ; F866F2  21 70   ld A,0x70
	ld (UI_ScreenHoldTimer:16), a                            ; F866F4  f1 73 20 41   ld (0x2073),A
.LF866F8:
	ld e, (UiEvent_Byte2:16)                            ; F866F8  c1 b9 20 25   ld E,(0x20b9)
	ld d, (UiEvent_Byte3:16)                            ; F866FC  c1 ba 20 24   ld D,(0x20ba)
	and E,D                                       ; F86700  cc c5
	jr z, .LF86719                                ; F86702  66 15
	ld a, (UiEvent_Byte1:16)                            ; F86704  c1 b8 20 21   ld A,(0x20b8)
	bit 0x00,E                                    ; F86708  cd 33 00
	jr z, .LF86710                                ; F8670B  66 03
	or A,0x80                                     ; F8670D  c9 ce 80
.LF86710:
	ld (PanelButton_Current:16), a                            ; F86710  f1 82 20 41   ld (0x2082),A
	or	(UI_Request_Hi:16), 0x01                     ; F86714  c1 71 20 3e 01   or (0x2071),0x01
.LF86719:
	ret                                           ; F86719  0e

; --- 0xF8671A-0xF86799  table (128 bytes) ---

; ---------------------------------------------------------------------
; PanelButton_BitMask32 -- 32 LE32 words, entry[i] == 1 << i
;
; Read by: `ld XHL,0x00F8671A` at 0xF86172 (PanelButton_SweepHeld) and
;          `ld XWA,0x00F8671A` at 0xF86659 (PanelButton_Accept).
; ENTRY COUNT 32, pinned twice: `cp C,0x1f` at 0xF8619A bounds the sweep's
;          index, and the 128-byte extent ends exactly where
;          PanelButton_InterlockMask32 begins at 0xF8679A -- an address the
;          code loads separately at 0xF86696.
; ★ LAST-ENTRY TEST: entry 31 is 0x80000000 and entry 0 is 0x00000001; the
;          identity entry[i] == 1<<i holds for all 32 (check B1).
; Evidence: because the table IS the identity, `mask & (0x2088)` is `bit i
;          of (0x2088)`, which is what makes (0x2084)/(0x2088)/(0x208C)
;          readable as three 32-bit bitmaps over 32 button indices.
; ---------------------------------------------------------------------
PanelButton_BitMask32:
	.long 0x00000001                            ; F8671A  [ 0]  1 << 0
	.long 0x00000002                            ; F8671E  [ 1]  1 << 1
	.long 0x00000004                            ; F86722  [ 2]  1 << 2
	.long 0x00000008                            ; F86726  [ 3]  1 << 3
	.long 0x00000010                            ; F8672A  [ 4]  1 << 4
	.long 0x00000020                            ; F8672E  [ 5]  1 << 5
	.long 0x00000040                            ; F86732  [ 6]  1 << 6
	.long 0x00000080                            ; F86736  [ 7]  1 << 7
	.long 0x00000100                            ; F8673A  [ 8]  1 << 8
	.long 0x00000200                            ; F8673E  [ 9]  1 << 9
	.long 0x00000400                            ; F86742  [10]  1 << 10
	.long 0x00000800                            ; F86746  [11]  1 << 11
	.long 0x00001000                            ; F8674A  [12]  1 << 12
	.long 0x00002000                            ; F8674E  [13]  1 << 13
	.long 0x00004000                            ; F86752  [14]  1 << 14
	.long 0x00008000                            ; F86756  [15]  1 << 15
	.long 0x00010000                            ; F8675A  [16]  1 << 16
	.long 0x00020000                            ; F8675E  [17]  1 << 17
	.long 0x00040000                            ; F86762  [18]  1 << 18
	.long 0x00080000                            ; F86766  [19]  1 << 19
	.long 0x00100000                            ; F8676A  [20]  1 << 20
	.long 0x00200000                            ; F8676E  [21]  1 << 21
	.long 0x00400000                            ; F86772  [22]  1 << 22
	.long 0x00800000                            ; F86776  [23]  1 << 23
	.long 0x01000000                            ; F8677A  [24]  1 << 24
	.long 0x02000000                            ; F8677E  [25]  1 << 25
	.long 0x04000000                            ; F86782  [26]  1 << 26
	.long 0x08000000                            ; F86786  [27]  1 << 27
	.long 0x10000000                            ; F8678A  [28]  1 << 28
	.long 0x20000000                            ; F8678E  [29]  1 << 29
	.long 0x40000000                            ; F86792  [30]  1 << 30
	.long 0x80000000                            ; F86796  [31]  1 << 31

; --- 0xF8679A-0xF86819  table (128 bytes) ---

; ---------------------------------------------------------------------
; PanelButton_InterlockMask32 -- 32 LE32 words; entry[i] == 1 << (i + 17)
;                                for i < 8, and 0 for i >= 8
;
; Read by: ONE site, `ld XWA,0x00F8679A` at 0xF86696 (PanelButton_Accept),
;          four instructions before the value is ANDed with (0x2252) and
;          then with (0x2256); a hit in either makes the press be DROPPED.
; ENTRY COUNT 32: the 128-byte extent ends at 0xF8681A, which is itself
;          `calr`-ed from 0xF865AE, so both ends are named by code.
; ★ LAST-ENTRY TEST: entries 8..31 are all zero -- so 24 of the 32 buttons
;          can never be interlocked -- and entry 7 is 0x01000000 = 1<<24 =
;          1<<(7+17).  Check B2.
; Evidence: `and XDE,(0x2252)` at 0xF8669F and `and XDE,(0x2256)` at
;          0xF866A7, each followed by a `jr NZ` to the path that pops and
;          returns WITHOUT touching (0x2088) -- so a hit vetoes the press.
; What (0x2252)/(0x2256) hold -- established 2026-09-25 (lane proma),
;          notes/proma-2026-09-25/gen_held_sets.py S1-S4: two 32-bit sets of
;          HELD panel event codes, bit c for code c.  Their only writers are
;          the action handlers PanelAction_PairPos0_HeldMaskAltCode / PanelAction_PairPos0_HeldMask ((0x2252)) and
;          PanelAction_PairPos1_HeldMaskAltCode / PanelAction_PairPos1_HeldMask ((0x2256)): mask = IndexToBitMask32(code
;          + 1), `or` on press, `and ~` on release, and the event value
;          becomes 0x0303 when the code is in both sets.  The pool routes
;          different switches of one code to the two sets; the codes are A9
;          0x00-0x10 (the soft keys, LCD rows, -1/+1, EXIT, PAGE of
;          Dispatch_FF3D39's legend).
; The 17: PanelAction_PairPos0_HeldMaskAltCode/PanelAction_PairPos1_HeldMaskAltCode rewrite a press whose bit is ALREADY set
;          to code + 0x11 and record it at bit + 17 (`add (XIX-1),0x11 /
;          sla 16 / sla 1`).  So bits 17..24 are codes 0..7 pressed again
;          while held -- exactly the bits this table tests for buttons
;          0..7, which is the offset the old line noted.
; ★ CORRECTED: this paragraph recorded both as open.
; ---------------------------------------------------------------------
PanelButton_InterlockMask32:
	.long 0x00020000                            ; F8679A  [ 0]  1 << 17
	.long 0x00040000                            ; F8679E  [ 1]  1 << 18
	.long 0x00080000                            ; F867A2  [ 2]  1 << 19
	.long 0x00100000                            ; F867A6  [ 3]  1 << 20
	.long 0x00200000                            ; F867AA  [ 4]  1 << 21
	.long 0x00400000                            ; F867AE  [ 5]  1 << 22
	.long 0x00800000                            ; F867B2  [ 6]  1 << 23
	.long 0x01000000                            ; F867B6  [ 7]  1 << 24
	.long 0x00000000                            ; F867BA  [ 8]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867BE  [ 9]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867C2  [10]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867C6  [11]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867CA  [12]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867CE  [13]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867D2  [14]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867D6  [15]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867DA  [16]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867DE  [17]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867E2  [18]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867E6  [19]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867EA  [20]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867EE  [21]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867F2  [22]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867F6  [23]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867FA  [24]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F867FE  [25]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F86802  [26]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F86806  [27]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F8680A  [28]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F8680E  [29]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F86812  [30]  zero -- this index can never be interlocked
	.long 0x00000000                            ; F86816  [31]  zero -- this index can never be interlocked

; ---------------------------------------------------------------------
; PanelEvent_Code20_SetScreen -- request the screen named by the event
;
; Called from: UiEvent_RouteByCode 0xF865AE (`calr`), and nothing else.
; Inputs:  E = (0x20B9), D = (0x20BA); the routine does nothing when
;          (E & D) == 0.
; Outputs: (0x2070) = E | 0x80 and (0x2071) = 0x02 -- i.e. the requested
;          screen id plus request bit 1, the bit PanelState_RunRequests
;          hands to PanelScreen_ApplyModeChange.
; Evidence: `ld (0x2070),E` at 0xF86829 and `ld (0x2071),0x02` at 0xF8682D
;          write the id and the flag byte as two separate stores to the
;          same pair PanelState_Init writes as one 16-bit 0x40AA.
; ---------------------------------------------------------------------
PanelEvent_Code20_SetScreen:   ; entry: calr from 0xF865AE
	ld e, (UiEvent_Byte2:16)                            ; F8681A  c1 b9 20 25   ld E,(0x20b9)
	ld d, (UiEvent_Byte3:16)                            ; F8681E  c1 ba 20 24   ld D,(0x20ba)
	and E,D                                       ; F86822  cc c5
	jr z, .LF86832                                ; F86824  66 0c
	or E,0x80                                     ; F86826  cd ce 80
	ld (UI_Request:16), e                            ; F86829  f1 70 20 45   ld (0x2070),E
	ld (UI_Request_Hi:16), 0x02                          ; F8682D  f1 71 20 00 02   ld (0x2071),0x02
.LF86832:
	ret                                           ; F86832  0e

; ---------------------------------------------------------------------
; PanelEvent_Code21_Dial -- apply one rotary-encoder delta
;
; Called from: UiEvent_RouteByCode 0xF865B8 (`calr`), and nothing else.
; Inputs:  E = (0x20B9) the signed delta, D = (0x20BA).
; Body:    E >= 0x40 gets bit 7 set; A = E + 0x10; A >= 0x80 -> 0; A >= 0x20
;          -> 0x1F; A = PanelDial_DeltaToStepIndex[A].
;          Then, with bit 0 of (0x2075) CLEAR: PanelDial_ApplyStep and
;          PanelDial_PostClass7A.  With it SET: W = (0x209C) or (0x209B)
;          (by bit 7 of A) and the value is routed as a BUTTON through
;          PanelButton_Route instead, and (0x2073) is reloaded with 0x70 if
;          it was already running.
; Evidence: the same (0x209B)/(0x209C) pair PanelButton_Accept substitutes
;          for button index 0x0D, so bit 0 of (0x2075) switches the dial
;          between `edit a value` and `act like a pair of buttons`.
; ---------------------------------------------------------------------
PanelEvent_Code21_Dial:   ; entry: calr from 0xF865B8
	ld e, (UiEvent_Byte2:16)                            ; F86833  c1 b9 20 25   ld E,(0x20b9)
	ld d, (UiEvent_Byte3:16)                            ; F86837  c1 ba 20 24   ld D,(0x20ba)
	cp E,0x40                                     ; F8683B  cd cf 40
	jr c, .LF86843                                ; F8683E  67 03
	or E,0x80                                     ; F86840  cd ce 80
.LF86843:
	ld A,E                                        ; F86843  cd 89
	add A,0x10                                    ; F86845  c9 c8 10
	cp A,0x80                                     ; F86848  c9 cf 80
	jr c, .LF8684F                                ; F8684B  67 02
	ld a, 0x00:opc                                   ; F8684D  21 00   ld A,0x00
.LF8684F:
	cp A,0x20                                     ; F8684F  c9 cf 20
	jr c, .LF86856                                ; F86852  67 02
	ld a, 0x1f:opc                                   ; F86854  21 1f   ld A,0x1f
.LF86856:
	ld XHL,PanelDial_DeltaToStepIndex             ; F86856  43 db 68 f8 00
	extz WA                                       ; F8685B  d8 12
	add HL,WA                                     ; F8685D  d8 83
	ld A,(XHL)                                    ; F8685F  83 21
	bit	0, (UI_RequestBits:16)                        ; F86861  f1 75 20 c8   bit 0,(0x2075)
	jr nz, .LF8686F                               ; F86865  6e 08
	calr .LF8688E                                 ; F86867  1e 24 00
	calr .LF868CD                                 ; F8686A  1e 60 00
	jr .LF8688D                                   ; F8686D  68 1e
.LF8686F:
	bit 0x07,A                                    ; F8686F  c9 33 07
	jr nz, .LF8687A                               ; F86872  6e 06
	ld w, (PanelDial_UpButton:16)                            ; F86874  c1 9c 20 20   ld W,(0x209c)
	jr .LF8687E                                   ; F86878  68 04
.LF8687A:
	ld w, (PanelDial_DownButton:16)                            ; F8687A  c1 9b 20 20   ld W,(0x209b)
.LF8687E:
	calr PanelButton_Route                                   ; F8687E  1e 2b f9   calr 0xf861ac
	cp	(UI_ScreenHoldTimer:16), 0x00                     ; F86881  c1 73 20 3f 00   cp (0x2073),0x00
	jr z, .LF8688D                                ; F86886  66 05
	ld (UI_ScreenHoldTimer:16), 0x70                          ; F86888  f1 73 20 00 70   ld (0x2073),0x70
.LF8688D:
	ret                                           ; F8688D  0e

; ---------------------------------------------------------------------
; PanelDial_ApplyStep -- add or subtract an accelerated step from (0x7EE2)
;
; Called from: PanelEvent_Code21_Dial 0xF86867, PanelButton_Route 0xF861D9.
; Inputs:  A -- bit 7 is the direction, bits 0-2 index PanelDial_StepSizes.
; Outputs: BC = the new value.  It is NOT stored here; PanelDial_PostClass7A
;          is what publishes it.
; Body:    WA = PanelDial_StepSizes[A & 7]; BC = (0x7EE2);
;          bit 7 of A set -> BC -= WA, floored at 0x0028;
;          bit 7 clear    -> BC += WA, capped at 0x012C.
; Evidence: the two literals at 0xF868B2 and 0xF868C3 are 0x0028 and 0x012C
;          -- 40 and 300 -- and the step ladder is 0, 1, 4, 10, 20, 50, 70,
;          100 in DECIMAL, which is what an acceleration curve looks like
;          when the quantity it steps is read in decimal by the user.
; Unknown:  what (0x7EE2) IS.  prom_b renders it through 0xF749A2 as a 9-bit
;          number ((0x7EE2) plus bit 0 of (0x7EE3)) at 0xF73AA8 and 0xF7573D,
;          and prom_b 0xF448A3 publishes it with the SAME event class 0x7A
;          this module uses -- but nothing decoded so far ties it to a
;          label on the panel, so the name stays mechanical.
; ---------------------------------------------------------------------
.LF8688E:
PanelDial_ApplyStep:   ; entry: calr from 0xF861D9, 0xF86867
	ld D,A                                        ; F8688E  c9 8c
	and A,0x07                                    ; F86890  c9 cc 07
	ld XHL,PanelDial_StepSizes                    ; F86893  43 fb 68 f8 00
	extz WA                                       ; F86898  d8 12
	add HL,WA                                     ; F8689A  d8 83
	ld A,(XHL)                                    ; F8689C  83 21
	xor W,W                                       ; F8689E  c8 d0
	ld XHL,0x00007ee2                             ; F868A0  43 e2 7e 00 00
	ld BC,(XHL)                                   ; F868A5  93 21
	bit 0x07,D                                    ; F868A7  cc 33 07
	jr z, .LF868BD                                ; F868AA  66 11
	cp BC,WA                                      ; F868AC  d8 f1
	jr c, .LF868B2                                ; F868AE  67 02
	sub BC,WA                                     ; F868B0  d8 a1
.LF868B2:
	cp BC,0x0028                                  ; F868B2  d9 cf 28 00
	jr ugt, .LF868BB                              ; F868B6  6b 03
	ldw bc, 0x28                                  ; F868B8  31 28 00   ld BC,0x0028
.LF868BB:
	jr .LF868CC                                   ; F868BB  68 0f
.LF868BD:
	add BC,WA                                     ; F868BD  d8 81
	jr nc, .LF868C3                               ; F868BF  6f 02
	sub BC,WA                                     ; F868C1  d8 a1
.LF868C3:
	cp BC,0x012c                                  ; F868C3  d9 cf 2c 01
	jr c, .LF868CC                                ; F868C7  67 03
	ldw bc, 0x012c                                ; F868C9  31 2c 01   ld BC,0x012c
.LF868CC:
	ret                                           ; F868CC  0e

; ---------------------------------------------------------------------
; PanelDial_PostClass7A -- post event {0x7A, 0x00, C, B & 1} to 0x2030
;
; Called from: PanelEvent_Code21_Dial 0xF8686A, PanelButton_Route 0xF861DC.
; Inputs:  BC = the 16-bit value PanelDial_ApplyStep computed.
; Outputs: A = C, W = B & 1, DE = 0x007A, then List2030_AppendRegs -- so the
;          record is 0x7A, 0x00, low byte, bit 8.
; Evidence: prom_b 0xF448A3 posts the SAME class 0x7A with E=0x7A, D=0x00
;          through T_Queue2E00_AppendRegs (T_F40F3C) and then writes (0x7EE2) itself, which is a
;          second, independent witness that class 0x7A carries this value.
;          The 9-bit split (low byte, then bit 8 alone) is the same split
;          prom_b 0xF6AD98-0xF6ADB6 makes when it packs the cell for the
;          link.
; ---------------------------------------------------------------------
.LF868CD:
PanelDial_PostClass7A:   ; entry: calr from 0xF861DC, 0xF8686A
	ld A,C                                        ; F868CD  cb 89
	ld W,B                                        ; F868CF  ca 88
	and W,0x01                                    ; F868D1  c8 cc 01
	ldw de, 0x7a                                  ; F868D4  32 7a 00   ld DE,0x007a
	calr List2030_AppendRegs                                   ; F868D7  1e ed 01   calr 0xf86ac7
	ret                                           ; F868DA  0e

; --- 0xF868DB-0xF868FA  table (32 bytes) ---

; ---------------------------------------------------------------------
; PanelDial_DeltaToStepIndex -- 32 bytes, encoder delta -> signed step index
;
; Read by: ONE site, `ld XHL,0x00F868DB` at 0xF86856.
; ENTRY COUNT 32, pinned by the reader itself: `cp A,0x20 / jr C / ld A,0x1f`
;          at 0xF8684F-0xF86854 clamps the index to 0..0x1F.  ⚠ The round-1
;          dossier said this base had no reader bound; it has one.
; Contents: 87 87 87 87 87 86 86 86 85 85 85 84 84 83 82 81 80 01 02 03 04
;          04 05 05 05 06 06 06 07 07 07 07.  Bit 7 is the direction and bits
;          0-2 index PanelDial_StepSizes, so the first 17 entries are
;          negative and the last 15 positive -- the index the reader forms
;          is delta + 0x10, which puts zero delta at entry 16 (0x80 =
;          negative, step 0).
; Evidence: the consumer is PanelDial_ApplyStep, which uses bit 7 of the
;          fetched byte as the direction (`bit 0x07,D` at 0xF868A7) and its
;          low three bits as the PanelDial_StepSizes index (`and A,0x07` at
;          0xF86890) -- so the encoding of the table IS the consumer's.
; ---------------------------------------------------------------------
PanelDial_DeltaToStepIndex:
	.byte 0x87, 0x87, 0x87, 0x87, 0x87, 0x86, 0x86, 0x86, 0x85, 0x85, 0x85, 0x84, 0x84, 0x83, 0x82, 0x81   ; F868DB
	.byte 0x80, 0x01, 0x02, 0x03, 0x04, 0x04, 0x05, 0x05, 0x05, 0x06, 0x06, 0x06, 0x07, 0x07, 0x07, 0x07   ; F868EB

; --- 0xF868FB-0xF86902  table (8 bytes) ---

; ---------------------------------------------------------------------
; PanelDial_StepSizes -- 8 bytes: 0, 1, 4, 10, 20, 50, 70, 100 (decimal)
;
; Read by: ONE site, `ld XHL,0x00F868FB` at 0xF86893, indexed by `and A,0x07`
;          at 0xF86890 -- which is what fixes the count at 8.  ⚠ The round-1
;          dossier said this base had no reader bound either.
; ★ LAST-ENTRY TEST: entry 7 is 0x64 = 100, and 0xF86903 (the byte after) is
;          PanelTimers_Step, a thunk-published entry point.
; Evidence: the values are added to or subtracted from (0x7EE2) at 0xF868BD
;          and 0xF868B0, between the 0x0028 and 0x012C limits -- a step of
;          100 on a range of 260 only makes sense as an acceleration ladder.
; ---------------------------------------------------------------------
PanelDial_StepSizes:
	.byte 0x00, 0x01, 0x04, 0x0a, 0x14, 0x32, 0x46, 0x64   ; F868FB

; ---------------------------------------------------------------------
; PanelTimers_Step -- run the screen timers, or the button repeat timer
;
; Called from: thunk slot T_PanelTimers_Step (T_F40F44) (`jp 0x00F86903`), whose one proven call
;          site is prom_a 0xF821ED.
; Body:    (0x2088) == 0 (no button held) -> PanelTimer_ScreenHold and
;          PanelTimer_Repeat20AB;  otherwise PanelTimer_ButtonRepeat.
; Evidence: the discriminator is a 32-bit compare of (0x2088) with zero at
;          0xF86907, the same bitmap PanelButton_Accept maintains.
; ---------------------------------------------------------------------
PanelTimers_Step:   ; entry: prom_b directory slot T_PanelTimers_Step (T_F40F44)
	ld xwa, (PanelButton_HeldMask:16)                          ; F86903  e1 88 20 20   ld XWA,(0x2088)
	cp XWA,0x00000000                             ; F86907  e8 cf 00 00 00 00
	jr nz, .LF86917                               ; F8690D  6e 08
	calr .LF86933                                 ; F8690F  1e 21 00
	calr .LF8691C                                 ; F86912  1e 07 00
	jr .LF8691A                                   ; F86915  68 03
.LF86917:
	calr .LF8696B                                 ; F86917  1e 51 00
.LF8691A:
	ret                                           ; F8691A  0e

; ---------------------------------------------------------------------
; sub_F8691B -- a single `ret` between PanelTimers_Step and
; PanelTimer_Repeat20AB
;
; Called from: NOTHING; no reference to 0xF8691B exists in either image.
; Evidence: same two-way census as sub_F8605C.
; ---------------------------------------------------------------------
sub_F8691B:
	ret                                           ; F8691B  0e

; ---------------------------------------------------------------------
; PanelTimer_Repeat20AB -- count (0x20AB) down; at zero bump (0x207E)
;
; Called from: PanelTimers_Step 0xF86912 (`calr`), and nothing else.
; Outputs: on expiry, `inc 1,(0x207E)` and `or (0x2071),0x10`.
; Evidence: (0x20AB) is loaded by PanelState_ClearOnChange at 0xF86483 with
;          the new screen id, so this counter starts on every screen change.
; ---------------------------------------------------------------------
.LF8691C:
PanelTimer_Repeat20AB:   ; entry: calr from 0xF86912
	cp	(0x20ab:16), 0x00                     ; F8691C  c1 ab 20 3f 00   cp (0x20ab),0x00
	jr z, .LF86932                                ; F86921  66 0f
	dec 0x01, (0x20ab:16)                         ; F86923  c1 ab 20 69   dec 1,(0x20ab)
	jr nz, .LF86932                               ; F86927  6e 09
	inc 0x01, (UI_ScreenStage:16)                         ; F86929  c1 7e 20 61   inc 1,(0x207e)
	or	(UI_Request_Hi:16), 0x10                     ; F8692D  c1 71 20 3e 10   or (0x2071),0x10
.LF86932:
	ret                                           ; F86932  0e

; ---------------------------------------------------------------------
; PanelTimer_ScreenHold -- count (0x2073) down and raise request bit 2
;
; Called from: PanelTimers_Step 0xF8690F (`calr`), and nothing else.
; Body:    (0x20A2) != 0: (0x2073) <= 1 -> `or (0x2071),0x04` and return;
;          else decrement (0x2073) unless bit 4 of (0x2075).
;          Then, if (0x2073) != 0 and bit 7 of (0x2075) is clear, decrement
;          it again and raise bit 2 of (0x2071) when it reaches zero.
; Evidence: bit 2 of (0x2071) is the bit PanelState_RunRequests hands to
;          PanelScreen_ApplyPendingId, and (0x20A2) is exactly the cell that
;          routine consumes -- so this is the `auto-return after N ticks`.
; ---------------------------------------------------------------------
.LF86933:
PanelTimer_ScreenHold:   ; entry: calr from 0xF8690F
	cp	(0x20a2:16), 0x00                     ; F86933  c1 a2 20 3f 00   cp (0x20a2),0x00
	jr z, .LF86952                                ; F86938  66 18
	cp	(UI_ScreenHoldTimer:16), 0x01                     ; F8693A  c1 73 20 3f 01   cp (0x2073),0x01
	jr ugt, .LF86948                              ; F8693F  6b 07
	or	(UI_Request_Hi:16), 0x04                     ; F86941  c1 71 20 3e 04   or (0x2071),0x04
	jr .LF8696A                                   ; F86946  68 22
.LF86948:
	bit	4, (UI_RequestBits:16)                        ; F86948  f1 75 20 cc   bit 4,(0x2075)
	jr nz, .LF86952                               ; F8694C  6e 04
	dec 0x01, (UI_ScreenHoldTimer:16)                         ; F8694E  c1 73 20 69   dec 1,(0x2073)
.LF86952:
	cp	(UI_ScreenHoldTimer:16), 0x00                     ; F86952  c1 73 20 3f 00   cp (0x2073),0x00
	jr z, .LF8696A                                ; F86957  66 11
	bit	7, (UI_RequestBits:16)                        ; F86959  f1 75 20 cf   bit 7,(0x2075)
	jr nz, .LF8696A                               ; F8695D  6e 0b
	dec 0x01, (UI_ScreenHoldTimer:16)                         ; F8695F  c1 73 20 69   dec 1,(0x2073)
	jr nz, .LF8696A                               ; F86963  6e 05
	or	(UI_Request_Hi:16), 0x04                     ; F86965  c1 71 20 3e 04   or (0x2071),0x04
.LF8696A:
	ret                                           ; F8696A  0e

; ---------------------------------------------------------------------
; PanelTimer_ButtonRepeat -- count (0x2074) down and raise repeat bit 3
;
; Called from: PanelTimers_Step 0xF86917 (`calr`), and nothing else.
; Evidence: (0x2074) is loaded with 3 by PanelButton_Dispatch at 0xF86147
;          and with 0x10 by PanelButton_Accept at 0xF866E0; bit 3 of
;          (0x2071) is what re-enters PanelButton_SweepHeld.  So 0x10 ticks
;          to the first repeat and 3 between repeats.
; ---------------------------------------------------------------------
.LF8696B:
PanelTimer_ButtonRepeat:   ; entry: calr from 0xF86917
	cp	(PanelButton_RepeatTimer:16), 0x00                     ; F8696B  c1 74 20 3f 00   cp (0x2074),0x00
	jr z, .LF8697D                                ; F86970  66 0b
	dec 0x01, (PanelButton_RepeatTimer:16)                         ; F86972  c1 74 20 69   dec 1,(0x2074)
	jr nz, .LF8697D                               ; F86976  6e 05
	or	(UI_Request_Hi:16), 0x08                     ; F86978  c1 71 20 3e 08   or (0x2071),0x08
.LF8697D:
	ret                                           ; F8697D  0e

; ---------------------------------------------------------------------
; UiEventList_RunPassA -- run pass A over the event list at 0x2C00
;
; Called from: thunk slot T_UiEventList_RunPassA (T_F40F5C) (`jp 0x00F8697E`).
; Outputs: (0x20C0) = UiEventClass_ListTable_A, (0x20C4) = UiEventPassA_TailList,
;          (0x20AD) = 0x2C00; then `calr UiEventList_Run`.
; Evidence: the three passes differ ONLY in those three immediates -- check P1
;          re-derives all nine from the ROM and compares them with this table.
; ---------------------------------------------------------------------
UiEventList_RunPassA:   ; entry: prom_b directory slot T_UiEventList_RunPassA (T_F40F5C)
	ld XIY,UiEventClass_ListTable_A               ; F8697E  45 81 76 f8 00
	ld (0x20c0:16), xiy                          ; F86983  f1 c0 20 65   ld (0x20c0),XIY
	ld XIY,UiEventPassA_TailList                  ; F86987  45 81 7e f8 00
	ld (0x20c4:16), xiy                          ; F8698C  f1 c4 20 65   ld (0x20c4),XIY
	ld XIY,0x00002c00                             ; F86990  45 00 2c 00 00
	ld (0x20ad:16), xiy                          ; F86995  f1 ad 20 65   ld (0x20ad),XIY
	calr .LF869DB                                 ; F86999  1e 3f 00
	ret                                           ; F8699C  0e

; ---------------------------------------------------------------------
; UiEventList_RunPassB -- run pass B over the event list at 0x2C00
;
; Called from: thunk slot T_UiEventList_RunPassB (T_F40F60) (`jp 0x00F8699D`).
; Outputs: (0x20C0) = UiEventClass_ListTable_B, (0x20C4) = UiEventPassB_TailList,
;          (0x20AD) = 0x2C00; then `calr UiEventList_Run`.
; Evidence: the three passes differ ONLY in those three immediates -- check P1
;          re-derives all nine from the ROM and compares them with this table.
; ---------------------------------------------------------------------
UiEventList_RunPassB:   ; entry: prom_b directory slot T_UiEventList_RunPassB (T_F40F60)
	ld XIY,UiEventClass_ListTable_B               ; F8699D  45 91 7e f8 00
	ld (0x20c0:16), xiy                          ; F869A2  f1 c0 20 65   ld (0x20c0),XIY
	ld XIY,UiEventPassB_TailList                  ; F869A6  45 91 8e f8 00
	ld (0x20c4:16), xiy                          ; F869AB  f1 c4 20 65   ld (0x20c4),XIY
	ld XIY,0x00002c00                             ; F869AF  45 00 2c 00 00
	ld (0x20ad:16), xiy                          ; F869B4  f1 ad 20 65   ld (0x20ad),XIY
	calr .LF869DB                                 ; F869B8  1e 20 00
	ret                                           ; F869BB  0e

; ---------------------------------------------------------------------
; UiEventList_RunPassC -- run pass C over the event list at 0x2030
;
; Called from: thunk slot T_UiEventList_RunPassC (T_F40F64) (`jp 0x00F869BC`).
; Outputs: (0x20C0) = UiEventClass_ListTable_C, (0x20C4) = UiEventPassC_TailList,
;          (0x20AD) = 0x2030; then `calr UiEventList_Run`.
; Evidence: the three passes differ ONLY in those three immediates -- check P1
;          re-derives all nine from the ROM and compares them with this table.
; ---------------------------------------------------------------------
UiEventList_RunPassC:   ; entry: prom_b directory slot T_UiEventList_RunPassC (T_F40F64)
	ld XIY,UiEventClass_ListTable_C               ; F869BC  45 c1 8e f8 00
	ld (0x20c0:16), xiy                          ; F869C1  f1 c0 20 65   ld (0x20c0),XIY
	ld XIY,UiEventPassC_TailList                  ; F869C5  45 71 96 f8 00
	ld (0x20c4:16), xiy                          ; F869CA  f1 c4 20 65   ld (0x20c4),XIY
	ld XIY,0x00002030                             ; F869CE  45 30 20 00 00
	ld (0x20ad:16), xiy                          ; F869D3  f1 ad 20 65   ld (0x20ad),XIY
	calr .LF869DB                                 ; F869D7  1e 01 00
	ret                                           ; F869DA  0e

; ---------------------------------------------------------------------
; UiEventList_Run -- walk one 4-byte event list and dispatch every record
;
; Called from: UiEventList_RunPassA/B/C (`calr` at 0xF86999, 0xF869B8,
;          0xF869D7), and nothing else.
; The record: 4 bytes.  +0 the CLASS (0xFF ends the list, > 0xBF is
;          skipped), +1..+3 the payload.  0xF869F7 stores +0 in (0x20BB),
;          0xF86A1B stores the WORD at +1 in (0x20B8) and 0xF86A1F stores
;          +3 in (0x20BA) -- so a handler reads its payload as
;          (0x20B8), (0x20B9), (0x20BA).
; The dispatch: class * 4 indexes the table in (0x20C0), giving the head of
;          an LE32 list of handler addresses.  Every entry is CALLED in turn
;          until the 0xFFFFFFFF terminator (0xF86A0E tests both halves).
;          Then every entry of the table in (0x20C4) is called the same way.
; Saved across each handler: ELEVEN pushes at 0xF86A23-0xF86A3C -- five
;          `pushw (mem)` of (0x20B2), (0x20C0), (0x20C2), (0x20C4), (0x20C6)
;          and six `push Xrr` of XWA, XBC, XDE, XHL, XIY, XIX.  ⚠ The
;          round-1 dossier read this as `eleven registers PLUS five RAM
;          cells`; it is eleven pushes IN TOTAL, of which five are RAM.
;          Saving (0x20C0)/(0x20C4) is what lets a handler start a NESTED
;          pass without losing this one.
; Evidence: the class bound is `cp L,0xbf` at 0xF869FB (192 classes) and
;          each class table is 0x300 bytes = 192 LE32 entries -- two
;          independent pins on the same count.
; ---------------------------------------------------------------------
.LF869DB:
UiEventList_Run:   ; entry: calr from 0xF86999, 0xF869B8, 0xF869D7
	ldw (0x20b2:16), 0x00                         ; F869DB  f1 b2 20 02 00 00   ld (0x20b2),0x0000
.LF869E1:
	ld xiy, (0x20ad:16)                          ; F869E1  e1 ad 20 25   ld XIY,(0x20ad)
	add	iy, (0x20b2:16)                       ; F869E5  d1 b2 20 85   add IY,(0x20b2)
	cp (XIY),0xff                                 ; F869E9  85 3f ff
	jrl z, .LF86A6A                               ; F869EC  76 7b 00
	ld xix, (0x20c0:16)                          ; F869EF  e1 c0 20 24   ld XIX,(0x20c0)
	xor HL,HL                                     ; F869F3  db d3
	ld L,(XIY)                                    ; F869F5  85 27
	ld (UiEvent_Class:16), l                            ; F869F7  f1 bb 20 47   ld (0x20bb),L
	cp L,0xbf                                     ; F869FB  cf cf bf
	jr UGT,.LF86A61                               ; F869FE  6b 61
	sla hl, 0x02                                  ; F86A00  db ec 02   sla 0x02,HL
	ld	xhl, (xix+hl)                         ; F86A03  e3 07 f0 ec 23   ld XHL,(XIX+HL)
	ld WA,(XIY+0x01)                              ; F86A08  9d 01 20
	ld C,(XIY+0x03)                               ; F86A0B  8d 03 23
.LF86A0E:
	cpw	(xhl), 0xffff                         ; F86A0E  93 3f ff ff   cp (XHL),0xffff
	jr nz, .LF86A1B                               ; F86A12  6e 07
	cpw	(xhl+2), 0xffff                       ; F86A14  9b 02 3f ff ff   cp (XHL+0x02),0xffff
	jr z, .LF86A61                                ; F86A19  66 46
.LF86A1B:
	ld (UiEvent_Byte1:16), wa                           ; F86A1B  f1 b8 20 50   ld (0x20b8),WA
	ld (UiEvent_Byte3:16), c                            ; F86A1F  f1 ba 20 43   ld (0x20ba),C
	pushw	(0x20b2:16)                           ; F86A23  d1 b2 20 04   pushw (0x20b2)
	pushw	(0x20c0:16)                           ; F86A27  d1 c0 20 04   pushw (0x20c0)
	pushw	(0x20c2:16)                           ; F86A2B  d1 c2 20 04   pushw (0x20c2)
	pushw	(0x20c4:16)                           ; F86A2F  d1 c4 20 04   pushw (0x20c4)
	pushw	(0x20c6:16)                           ; F86A33  d1 c6 20 04   pushw (0x20c6)
	push XWA                                      ; F86A37  38
	push XBC                                      ; F86A38  39
	push XDE                                      ; F86A39  3a
	push XHL                                      ; F86A3A  3b
	push XIY                                      ; F86A3B  3d
	push XIX                                      ; F86A3C  3c
	ld XDE,(XHL)                                  ; F86A3D  a3 22
	call (xde)                                    ; F86A3F  b2 e8   call T,XDE
	pop XIX                                       ; F86A41  5c
	pop XIY                                       ; F86A42  5d
	pop XHL                                       ; F86A43  5b
	pop XDE                                       ; F86A44  5a
	pop XBC                                       ; F86A45  59
	pop XWA                                       ; F86A46  58
	popw	(0x20c6:16)                           ; F86A47  f1 c6 20 06   popw (0x20c6)
	popw	(0x20c4:16)                           ; F86A4B  f1 c4 20 06   popw (0x20c4)
	popw	(0x20c2:16)                           ; F86A4F  f1 c2 20 06   popw (0x20c2)
	popw	(0x20c0:16)                           ; F86A53  f1 c0 20 06   popw (0x20c0)
	popw	(0x20b2:16)                           ; F86A57  f1 b2 20 06   popw (0x20b2)
	add HL,0x0004                                 ; F86A5B  db c8 04 00
	jr .LF86A0E                                   ; F86A5F  68 ad
.LF86A61:
	addw	(0x20b2:16), 0x0004                   ; F86A61  d1 b2 20 38 04 00   add (0x20b2),0x0004
	jrl .LF869E1                                  ; F86A67  78 77 ff
.LF86A6A:
	ld xix, (0x20c4:16)                          ; F86A6A  e1 c4 20 24   ld XIX,(0x20c4)
.LF86A6E:
	cpw	(xix), 0xffff                         ; F86A6E  94 3f ff ff   cp (XIX),0xffff
	jr z, .LF86A80                                ; F86A72  66 0c
	push XIX                                      ; F86A74  3c
	ld XIX,(XIX)                                  ; F86A75  a4 24
	call (xix)                                    ; F86A77  b4 e8   call T,XIX
	pop XIX                                       ; F86A79  5c
	add IX,0x0004                                 ; F86A7A  dc c8 04 00
	jr .LF86A6E                                   ; F86A7E  68 ee
.LF86A80:
	ret                                           ; F86A80  0e

; ---------------------------------------------------------------------
; Queue2C00_AppendRegs -- append {E, D, A, W} to the event list at 0x2C00
;
; Called from: thunk slot T_Queue2C00_AppendRegs (T_F40F38) (`jp 0x00F86A81`); 7 proven call sites
;          (prom_a 0xF818CB, 0xF8BEFE, 0xF90C3F, 0xF90C8F, 0xF99EB7,
;          0xFB901A and one more -- --sites lists them all).
; Inputs:  DE and WA; the record stored is E at +0, D at +1, A at +2, W at
;          +3, and 0xFF at +4 as the new terminator.
; Outputs: (0x60F000) += 4.
; ⚠ The capacity test is on the BYTE at 0x60F000 (`cp (0x60f000),0xfb`,
;          prefix 0xC2 = 8-bit), while every other user of that cell treats
;          it as 16-bit: UiEventList_Publish writes IX to it, prom_a
;          0xFAA4AB reads HL from it and bounds at 0x01FC, and prom_b's
;          Queue2C00_Append4 (0xF55231) bounds at 0x01FC too.  Stated, not
;          explained.
; Sibling:  prom_b's Queue2C00_Append4 at 0xF55231 is the C-compiled twin --
;          same base 0x2C00, same cursor (0x60F000), same 4-byte record,
;          same 0xFF one past, same `+= 4`.  It is NOT a byte copy: it takes
;          its four bytes as 16-bit stack slots and is 77 bytes against this
;          routine's 34, so the name is shared by STRUCTURE, not by a diff.
; Evidence: `ld XHL,0x00002c00` at 0xF86A89, `add HL,(0x60f000)` at
;          0xF86A8E, `ld (XHL),DE` / `ld (XHL+0x02),WA` /
;          `ld (XHL+0x04),0xff` at 0xF86A93-0xF86A98, `add (0x60f000),0x04`
;          at 0xF86A9C.
; ---------------------------------------------------------------------
Queue2C00_AppendRegs:   ; entry: prom_b directory slot T_Queue2C00_AppendRegs (T_F40F38)
	cp	(0x60f000:24), 0xfb                   ; F86A81  c2 00 f0 60 3f fb   cp (0x60f000),0xfb
	jr ugt, .LF86AA2                              ; F86A87  6b 19
	ld XHL,0x00002c00                             ; F86A89  43 00 2c 00 00
	add hl, (0x60f000:24)                     ; F86A8E  d2 00 f0 60 83   add HL,(0x60f000)
	ld (XHL),DE                                   ; F86A93  b3 52
	ld (XHL+0x02),WA                              ; F86A95  bb 02 50
	ld (XHL+0x04),0xff                            ; F86A98  bb 04 00 ff
	add	(0x60f000:24), 0x04                   ; F86A9C  c2 00 f0 60 38 04   add (0x60f000),0x04
.LF86AA2:
	ret                                           ; F86AA2  0e

; ---------------------------------------------------------------------
; Queue2E00_AppendRegs -- append {E, D, A, W} to the PENDING list at 0x2E00
;
; Called from: thunk slot T_Queue2E00_AppendRegs (T_F40F3C) (`jp 0x00F86AA3`); 59 proven call sites,
;          the most heavily referenced address in this span.  --sites lists
;          them; they are spread over prom_a 0xF8BF19..0xFEnnnn and are the
;          reason this span was picked.
; Inputs/outputs: as Queue2C00_AppendRegs, with base 0x2E00 and cursor
;          (0x60F004).  Here the bound IS 16-bit: `cp (0x60f004),0x00fb`
;          (prefix 0xD2), so at most 63 records.
; ★ What happens to the record: nothing, until UiEventList_Publish copies
;          0x2E00 over 0x2C00 and empties it.  So this is the WRITE half of
;          a double buffer and Queue2C00_AppendRegs the read half.
; Sibling:  prom_b's Queue2E00_Append4 (0xF5527E) and prom_a's own
;          sub_FE7100 are two more C-compiled twins of the same structure;
;          prom_b's bounds the OTHER cursor (0x60F000) at 0x00FC, which none
;          of the three hand-written ones do.
; Evidence: `ld XHL,0x00002e00` at 0xF86AAC and `add HL,(0x60f004)` at
;          0xF86AB1, against 0x2C00 / (0x60F000) twenty-two bytes earlier --
;          the two routines are the same code with the two constants
;          swapped and the compare widened.
; ---------------------------------------------------------------------
Queue2E00_AppendRegs:   ; entry: prom_b directory slot T_Queue2E00_AppendRegs (T_F40F3C)
	cpw	(0x60f004:24), 0x00fb                 ; F86AA3  d2 04 f0 60 3f fb 00   cp (0x60f004),0x00fb
	jr ugt, .LF86AC6                              ; F86AAA  6b 1a
	ld XHL,0x00002e00                             ; F86AAC  43 00 2e 00 00
	add hl, (0x60f004:24)                     ; F86AB1  d2 04 f0 60 83   add HL,(0x60f004)
	ld (XHL),DE                                   ; F86AB6  b3 52
	ld (XHL+0x02),WA                              ; F86AB8  bb 02 50
	ld (XHL+0x04),0xff                            ; F86ABB  bb 04 00 ff
	addw	(0x60f004:24), 0x0004                 ; F86ABF  d2 04 f0 60 38 04 00   add (0x60f004),0x0004
.LF86AC6:
	ret                                           ; F86AC6  0e

; ---------------------------------------------------------------------
; List2030_AppendRegs -- append {E, D, A, W} to the fixed list at 0x2030
;
; Called from: thunk slot T_List2030_AppendRegs (T_F40F40) (`jp 0x00F86AC7`); 14 proven call sites;
;          and in-span from PanelButton_PostClass70 0xF8625A and
;          PanelDial_PostClass7A 0xF868D7.
; Body:    scan from 0x2030 in steps of 4 for the 0xFF terminator, refuse if
;          it is past 0x206B, then store the record and a new 0xFF.
; Capacity: (0x206C - 0x2030) / 4 = 15 records.  Unlike the two queues this
;          list has no cursor -- the terminator IS the cursor.
; Read by:  UiEventList_RunPassC (this module), prom_a 0xF8A824 (which
;          handles classes <= 0x18 and stops on 0xFF or 0xFE), and prom_a
;          0xFADB41 in the 0xFAD800 module (which dispatches classes <= 0xBF
;          through its own 192-entry table at 0xFAE3A2).  Three independent
;          consumers, each with its own class range.
; Sibling:  prom_b's List2030_Append4 at 0xF552CC -- same base, same 0x206C
;          ceiling, same scan-for-0xFF; again a structural match, not a diff.
; Evidence: `ld XHL,0x00002030` at 0xF86AC7, `cp (XHL),0xff` at 0xF86ACC,
;          `add HL,0x0004` at 0xF86AD1, `cp XHL,0x0000206b` at 0xF86AD7.
; ---------------------------------------------------------------------
List2030_AppendRegs:   ; entry: calr from 0xF8625A, 0xF868D7, prom_b directory slot T_List2030_AppendRegs (T_F40F40)
	ld XHL,0x00002030                             ; F86AC7  43 30 20 00 00
.LF86ACC:
	cp (XHL),0xff                                 ; F86ACC  83 3f ff
	jr z, .LF86AD7                                ; F86ACF  66 06
	add HL,0x0004                                 ; F86AD1  db c8 04 00
	jr .LF86ACC                                   ; F86AD5  68 f5
.LF86AD7:
	cp XHL,0x0000206b                             ; F86AD7  eb cf 6b 20 00 00
	jr ugt, .LF86AE8                              ; F86ADD  6b 09
	ld (XHL),DE                                   ; F86ADF  b3 52
	ld (XHL+0x02),WA                              ; F86AE1  bb 02 50
	ld (XHL+0x04),0xff                            ; F86AE4  bb 04 00 ff
.LF86AE8:
	ret                                           ; F86AE8  0e

; ---------------------------------------------------------------------
; PanelState_CheckRequestAllowed -- veto the pending home jump on two screens
;
; Called from: thunk slots T_PanelState_CheckRequestAllowed AND T_PanelState_CheckRequestAllowed_2 (both `jp 0x00F86AE9`);
;          T_PanelState_CheckRequestAllowed_2 has 2 proven call sites (prom_a 0xFE01F1, 0xFE70AB) and
;          T_PanelState_CheckRequestAllowed none.  Also `calr` from PanelTask_StepAndCheckRequest 0xF8601F
;          and PanelTask_Step 0xF86066.
; Body:    bit 6 of (0x2071) and bit 4 of (0x2075) both set, with (0x207C)
;          either 0x01 or 0xDA -> `and (0x2071),0xBF`, i.e. drop the home
;          request.  Then, unless (bit 0 of (0x2092) is clear AND bit 4 of
;          (0x2075) is set -- which only does `and (0x2095),0xFE`), if bit 6
;          of (0x2071) is set the low byte of (0x2070) is compared against
;          the two entries of PanelState_AllowedScreenIds; a match gives
;          `or (0x2095),0x03` and (0x20A2) = 0.
; Evidence: `ld WA,(0x2070)` at 0xF86B1B is a 16-bit load and `bit 0x06,W`
;          (c8 33 06) at 0xF86B1F then tests bit 6 of the HIGH half -- which is byte
;          (0x2071), the same flag byte PanelState_Init writes at 0xF86055
;          and PanelScreen_ApplyRequestForced tests at 0xF863AC.  That is a
;          third independent witness for the (0x2070)/(0x2071) pairing.
; ---------------------------------------------------------------------
PanelState_CheckRequestAllowed:   ; entry: calr from 0xF8601F, 0xF86066, prom_b directory slot T_PanelState_CheckRequestAllowed, prom_b directory slot T_PanelState_CheckRequestAllowed_2
	bit	6, (UI_Request_Hi:16)                        ; F86AE9  f1 71 20 ce   bit 6,(0x2071)
	jr z, .LF86B08                                ; F86AED  66 19
	bit	4, (UI_RequestBits:16)                        ; F86AEF  f1 75 20 cc   bit 4,(0x2075)
	jr z, .LF86B08                                ; F86AF3  66 13
	cp	(UI_ScreenId:16), 0x01                     ; F86AF5  c1 7c 20 3f 01   cp (0x207c),0x01
	jr z, .LF86B03                                ; F86AFA  66 07
	cp	(UI_ScreenId:16), 0xda                     ; F86AFC  c1 7c 20 3f da   cp (0x207c),0xda
	jr nz, .LF86B08                               ; F86B01  6e 05
.LF86B03:
	and	(UI_Request_Hi:16), 0xbf                     ; F86B03  c1 71 20 3c bf   and (0x2071),0xbf
.LF86B08:
	bit	0, (UI_ScreenHoldState:16)                        ; F86B08  f1 92 20 c8   bit 0,(0x2092)
	jr nz, .LF86B1B                               ; F86B0C  6e 0d
	bit	4, (UI_RequestBits:16)                        ; F86B0E  f1 75 20 cc   bit 4,(0x2075)
	jr z, .LF86B1B                                ; F86B12  66 07
	and	(UI_ScreenFlags:16), 0xfe                     ; F86B14  c1 95 20 3c fe   and (0x2095),0xfe
	jr .LF86B42                                   ; F86B19  68 27
.LF86B1B:
	ld wa, (UI_Request:16)                          ; F86B1B  d1 70 20 20   ld WA,(0x2070)
	bit 0x06,W                                    ; F86B1F  c8 33 06
	jr z, .LF86B42                                ; F86B22  66 1e
	ld XIX,PanelState_AllowedScreenIds            ; F86B24  44 c9 6c f8 00
	ld XBC,0x00000002                             ; F86B29  41 02 00 00 00
.LF86B2E:
	cp a, (xix+)                               ; F86B2E  c5 f0 f1   cp A,(XIX+)
	jr z, .LF86B38                                ; F86B31  66 05
	djnz16 bc, .LF86B2E                           ; F86B33  d9 1c f8
	jr .LF86B42                                   ; F86B36  68 0a
.LF86B38:
	or	(UI_ScreenFlags:16), 0x03                     ; F86B38  c1 95 20 3e 03   or (0x2095),0x03
	ld (0x20a2:16), 0x00                          ; F86B3D  f1 a2 20 00 00   ld (0x20a2),0x00
.LF86B42:
	ret                                           ; F86B42  0e

; ---------------------------------------------------------------------
; EditValue_ApplyStep -- add or subtract (0x20CE) from (0x20CC), clamped
;
; Called from: thunk slot T_EditValue_ApplyStep (T_F40F68) (`jp 0x00F86B43`); no proven call site.
; Inputs:  W -- bit 7 is the direction.  (0x20C8) is the ceiling, (0x20CA)
;          the floor, (0x20CE) the step, (0x20CC) the value.
; Outputs: DE = the new value; it is NOT stored back.
; Evidence: the two `jr PE/OV` at 0xF86B50 and 0xF86B62 catch signed
;          overflow before the limit compare, so the four cells are SIGNED
;          16-bit.
; ---------------------------------------------------------------------
EditValue_ApplyStep:   ; entry: prom_b directory slot T_EditValue_ApplyStep (T_F40F68)
	ld de, (EditValue_Value:16)                          ; F86B43  d1 cc 20 22   ld DE,(0x20cc)
	bit 0x07,W                                    ; F86B47  c8 33 07
	jr nz, .LF86B5E                               ; F86B4A  6e 12
	add	de, (EditValue_Step:16)                       ; F86B4C  d1 ce 20 82   add DE,(0x20ce)
	jr ov, .LF86B58                               ; F86B50  64 06
	cp	de, (EditValue_Max:16)                       ; F86B52  d1 c8 20 f2   cp DE,(0x20c8)
	jr le, .LF86B6E                               ; F86B56  62 16
.LF86B58:
	ld de, (EditValue_Max:16)                          ; F86B58  d1 c8 20 22   ld DE,(0x20c8)
	jr .LF86B6E                                   ; F86B5C  68 10
.LF86B5E:
	sub	de, (EditValue_Step:16)                       ; F86B5E  d1 ce 20 a2   sub DE,(0x20ce)
	jr ov, .LF86B6A                               ; F86B62  64 06
	cp	de, (EditValue_Min:16)                       ; F86B64  d1 ca 20 f2   cp DE,(0x20ca)
	jr ge, .LF86B6E                               ; F86B68  69 04
.LF86B6A:
	ld de, (EditValue_Min:16)                          ; F86B6A  d1 ca 20 22   ld DE,(0x20ca)
.LF86B6E:
	ret                                           ; F86B6E  0e

; ---------------------------------------------------------------------
; EditStep_UseCurveA -- (0x20CE) := EditStep_CurveA[W & 0x7F]
;
; Called from: thunk slot T_EditStep_UseCurveA (T_F40F6C) (`jp 0x00F86B6F`); no proven call site.
; Evidence: `ld XIY,0x00f86ba0` at 0xF86B71, then `jr T,0xf86b8d` into the
;          shared tail -- so the only thing this entry decides is the base.
; ---------------------------------------------------------------------
EditStep_UseCurveA:   ; entry: prom_b directory slot T_EditStep_UseCurveA (T_F40F6C)
	push XIY                                      ; F86B6F  3d
	push XHL                                      ; F86B70  3b
	ld XIY,EditStep_Lookup_Data_F86BA0                             ; F86B71  45 a0 6b f8 00
	jr EditStep_Lookup                                       ; F86B76  68 15   jr T,0xf86b8d
	ld XIY,EditStep_Lookup_Data_F86BA8                             ; F86B78  45 a8 6b f8 00
	jr EditStep_Lookup                                       ; F86B7D  68 0e   jr T,0xf86b8d

; ---------------------------------------------------------------------
; EditStep_UseCurveC -- (0x20CE) := EditStep_CurveC[W & 0x7F]
;
; Called from: thunk slot T_EditStep_UseCurveC (T_F40F70) (`jp 0x00F86B7F`); no proven call site.
; ⚠ 0xF86B78 (`ld XIY,0x00F86BA8`) and 0xF86B88 (`ld XIY,0x00F86BB8`) are
;          UNREACHABLE: 0xF86B76 and 0xF86B86 are `jr T,0xF86B8D`, which
;          jumps straight over them.  Curves B and D are therefore named by
;          dead code and by nothing else.  Check C3.
; Evidence: `ld XIY,0x00f86bb0` at 0xF86B81, then `jr T,0xf86b8d`.
; ---------------------------------------------------------------------
EditStep_UseCurveC:   ; entry: prom_b directory slot T_EditStep_UseCurveC (T_F40F70)
	push XIY                                      ; F86B7F  3d
	push XHL                                      ; F86B80  3b
	ld XIY,EditStep_Lookup_Data_F86BB0                             ; F86B81  45 b0 6b f8 00
	jr EditStep_Lookup                                       ; F86B86  68 05   jr T,0xf86b8d

; --- 0xF86B88-0xF86B8C  an instruction NOTHING branches to (5 bytes) ---
	.byte 0x45, 0xb8, 0x6b, 0xf8, 0x00   ; F86B88

; ---------------------------------------------------------------------
; EditStep_Lookup -- the shared tail: (0x20CE) := (XIY + (W & 0x7F))
;
; Called from: fallen into from EditStep_UseCurveA and EditStep_UseCurveC.
; ⚠ The index mask is 0x7F, so an index of 8..127 reads PAST the 8-byte
;          curve it was given.  Nothing in this span bounds W, so what the
;          curves' real extent is rests on the 8-byte spacing of the four
;          bases alone.  Stated as a gap rather than papered over.
; Evidence: `and L,0x7f` at 0xF86B91, `ld L,(XIY+HL)` at 0xF86B94,
;          `ld (0x20ce),HL` at 0xF86B99 -- the cell EditValue_ApplyStep
;          adds at 0xF86B4C.
; ---------------------------------------------------------------------
EditStep_Lookup:
	xor HL,HL                                     ; F86B8D  db d3
	ld L,W                                        ; F86B8F  c8 8f
	and L,0x7f                                    ; F86B91  cf cc 7f
	ld	l, (xiy+hl)                           ; F86B94  c3 07 f4 ec 27   ld L,(XIY+HL)
	ld (EditValue_Step:16), hl                           ; F86B99  f1 ce 20 53   ld (0x20ce),HL
	pop XHL                                       ; F86B9D  5b
	pop XIY                                       ; F86B9E  5d
	ret                                           ; F86B9F  0e

; --- 0xF86BA0-0xF86BA7  table (8 bytes) ---
EditStep_Lookup_Data_F86BA0:
	.byte 0x00, 0x01, 0x05, 0x0a, 0x0f, 0x14, 0x19, 0x1e   ; F86BA0

; --- 0xF86BA8-0xF86BAF  table (8 bytes) ---
EditStep_Lookup_Data_F86BA8:
	.byte 0x00, 0x01, 0x03, 0x05, 0x0a, 0x0f, 0x14, 0x19   ; F86BA8

; --- 0xF86BB0-0xF86BB7  table (8 bytes) ---
EditStep_Lookup_Data_F86BB0:
	.byte 0x00, 0x01, 0x0a, 0x14, 0x1e, 0x28, 0x32, 0x3c   ; F86BB0

; --- 0xF86BB8-0xF86BBF  table (8 bytes) ---
	.byte 0x00, 0x01, 0x05, 0x0a, 0x14, 0x1e, 0x28, 0x32   ; F86BB8

; ---------------------------------------------------------------------
; PanelEvent_Code01_ArmHold -- arm the hold timer with request 2
;
; Called from: thunk slot T_PanelEvent_Code01_ArmHold (T_F40F7C) (`jp 0x00F86BC0`); no proven call site,
;          and no list in any class table names it.
; Body:    (0x20B8) must be 1 and bit 7 of ((0x20B9) & (0x20BA)) set;
;          then, unless bit 1 of (0x60F020) is set, (0x2096) = 2 and
;          (0x20A7) = 0x40.  With bit 7 clear, (0x20A7) = 0 -- the hold is
;          cancelled.
; Evidence: (0x20A7) is the counter PanelHold_Tick decrements and (0x2096)
;          the index it then looks up, so `arm` is exactly what this is.
; ---------------------------------------------------------------------
PanelEvent_Code01_ArmHold:   ; entry: prom_b directory slot T_PanelEvent_Code01_ArmHold (T_F40F7C)
	ld l, (UiEvent_Byte2:16)                            ; F86BC0  c1 b9 20 27   ld L,(0x20b9)
	ld h, (UiEvent_Byte3:16)                            ; F86BC4  c1 ba 20 26   ld H,(0x20ba)
	ld a, (UiEvent_Byte1:16)                            ; F86BC8  c1 b8 20 21   ld A,(0x20b8)
	cp a, 0x01:i3                                   ; F86BCC  c9 d9   cp A,1
	jr nz, .LF86BF3                               ; F86BCE  6e 23
	and L,H                                       ; F86BD0  ce c7
	bit 0x07,L                                    ; F86BD2  cf 33 07
	jr z, .LF86BEB                                ; F86BD5  66 14
	bit	1, (0x60f020:24)                      ; F86BD7  f2 20 f0 60 c9   bit 1,(0x60f020)
	jr nz, .LF86BF3                               ; F86BDC  6e 15
	ldw (PanelHold_Index:16), 0x02                         ; F86BDE  f1 96 20 02 02 00   ld (0x2096),0x0002
	ld (PanelHold_Timer:16), 0x40                          ; F86BE4  f1 a7 20 00 40   ld (0x20a7),0x40
	jr .LF86BF3                                   ; F86BE9  68 08
.LF86BEB:
	xor A,A                                       ; F86BEB  c9 d1
	ld (PanelHold_Timer:16), a                            ; F86BED  f1 a7 20 41   ld (0x20a7),A
	jr .LF86BF3                                   ; F86BF1  68 00
.LF86BF3:
	ret                                           ; F86BF3  0e

; ---------------------------------------------------------------------
; PanelEvent_ReadPayload_F86BF4 -- loads the event payload and returns
;
; Called from: thunk slot T_F40F78 (`jp 0x00F86BF4`); no proven call site.
; Body:    `ld L,(0x20b9) / ld H,(0x20ba) / ld A,(0x20b8) / ret`.  Thirteen
;          bytes, no effect.  PanelEvent_ReadPayload_F86C01 is byte-for-byte
;          the same routine at a different address.
; Evidence: the whole body decodes as three loads and a `ret`, 13 bytes,
;          with no store and no branch.
; Unknown:  whether these two are stubs left in place or handlers whose body
;          was removed.  The register loads are dead either way.
; ---------------------------------------------------------------------
PanelEvent_ReadPayload_F86BF4:   ; entry: prom_b directory slot T_F40F78
	ld l, (UiEvent_Byte2:16)                            ; F86BF4  c1 b9 20 27   ld L,(0x20b9)
	ld h, (UiEvent_Byte3:16)                            ; F86BF8  c1 ba 20 26   ld H,(0x20ba)
	ld a, (UiEvent_Byte1:16)                            ; F86BFC  c1 b8 20 21   ld A,(0x20b8)
	ret                                           ; F86C00  0e

; ---------------------------------------------------------------------
; PanelEvent_ReadPayload_F86C01 -- byte-identical twin of the routine above
;
; Called from: thunk slot T_F40F80 (`jp 0x00F86C01`); no proven call site.
; Evidence: ROM[0xF86BF4..0xF86C00] == ROM[0xF86C01..0xF86C0D], 13 bytes,
;          0 differing -- check E1.
; ---------------------------------------------------------------------
PanelEvent_ReadPayload_F86C01:   ; entry: prom_b directory slot T_F40F80
	ld l, (UiEvent_Byte2:16)                            ; F86C01  c1 b9 20 27   ld L,(0x20b9)
	ld h, (UiEvent_Byte3:16)                            ; F86C05  c1 ba 20 26   ld H,(0x20ba)
	ld a, (UiEvent_Byte1:16)                            ; F86C09  c1 b8 20 21   ld A,(0x20b8)
	ret                                           ; F86C0D  0e

; ---------------------------------------------------------------------
; PanelEvent_Code20_ArmHold -- arm the hold timer with request 7, or cancel
;
; Called from: thunk slot T_PanelEvent_Code20_ArmHold (T_F40F84) (`jp 0x00F86C0E`); no proven call site.
; Body:    (0x20B8) must be 0x20.  L = (0x20B9) & (0x20BA).
;          L == 0x15, (0x2078) != 0x15, bit 1 of (0x60F020) clear ->
;            (0x2096) = 7, (0x20A7) = 0x30.
;          L == 5 and (0x2078) == 5 -> nothing.
;          otherwise -> (0x2096) = 0 and (0x20A7) = 0.
; ⚠ (0x2096) = 7 selects PanelHold_ScreenRequest[7], which is 0xFFFF -- the
;          `no entry` value PanelHold_Tick skips.  So this arm cancels the
;          jump rather than causing one, unless something outside this span
;          rewrites the table entry.  prom_a 0xFF4795 also compares (0x2096)
;          with 7, so the index is used elsewhere; nothing decoded so far
;          explains the 0xFFFF.
; Evidence: `cp A,0x20` at 0xF86C1A is the guard; `ld (0x2096),0x0007` at
;          0xF86C34 and `ld (0x20a7),0x30` at 0xF86C3A are the arm; the
;          cancel path is `ld (0x2096),0x0000` at 0xF86C4E.
; ---------------------------------------------------------------------
PanelEvent_Code20_ArmHold:   ; entry: prom_b directory slot T_PanelEvent_Code20_ArmHold (T_F40F84)
	ld l, (UiEvent_Byte2:16)                            ; F86C0E  c1 b9 20 27   ld L,(0x20b9)
	ld h, (UiEvent_Byte3:16)                            ; F86C12  c1 ba 20 26   ld H,(0x20ba)
	ld a, (UiEvent_Byte1:16)                            ; F86C16  c1 b8 20 21   ld A,(0x20b8)
	cp A,0x20                                     ; F86C1A  c9 cf 20
	jr nz, .LF86C58                               ; F86C1D  6e 39
	and L,H                                       ; F86C1F  ce c7
	cp L,0x15                                     ; F86C21  cf cf 15
	jr nz, .LF86C41                               ; F86C24  6e 1b
	cp	(PanelMode:16), 0x15                     ; F86C26  c1 78 20 3f 15   cp (0x2078),0x15
	jr z, .LF86C58                                ; F86C2B  66 2b
	bit	1, (0x60f020:24)                      ; F86C2D  f2 20 f0 60 c9   bit 1,(0x60f020)
	jr nz, .LF86C58                               ; F86C32  6e 24
	ldw (PanelHold_Index:16), 0x07                         ; F86C34  f1 96 20 02 07 00   ld (0x2096),0x0007
	ld (PanelHold_Timer:16), 0x30                          ; F86C3A  f1 a7 20 00 30   ld (0x20a7),0x30
	jr .LF86C58                                   ; F86C3F  68 17
.LF86C41:
	cp l, 0x05:i3                                   ; F86C41  cf dd   cp L,5
	jr nz, .LF86C4C                               ; F86C43  6e 07
	cp	(PanelMode:16), 0x05                     ; F86C45  c1 78 20 3f 05   cp (0x2078),0x05
	jr z, .LF86C58                                ; F86C4A  66 0c
.LF86C4C:
	xor A,A                                       ; F86C4C  c9 d1
	ldw (PanelHold_Index:16), 0x00                         ; F86C4E  f1 96 20 02 00 00   ld (0x2096),0x0000
	ld (PanelHold_Timer:16), a                            ; F86C54  f1 a7 20 41   ld (0x20a7),A
.LF86C58:
	ret                                           ; F86C58  0e

; ---------------------------------------------------------------------
; PanelEvent_NoOp_T40F88 -- one `ret`, published as thunk slot T_PanelEvent_NoOp_T40F88 (T_F40F88)
;
; Called from: thunk slot T_PanelEvent_NoOp_T40F88 (T_F40F88) only; no proven call site.
; Evidence: 0xF86C59, 0xF86C5A and 0xF86C5B are three CONSECUTIVE single
;          `ret` bytes, and prom_b's directory publishes each of them as its
;          own slot (T_PanelEvent_NoOp_T40F88 (T_F40F88), T_PanelEvent_NoOp_T40F8C (T_F40F8C), T_PanelEvent_NoOp_T40F94 (T_F40F94)).  Three distinct
;          published entry points that all do nothing -- which is why they
;          are three labels and not one.
; ---------------------------------------------------------------------
PanelEvent_NoOp_T40F88:   ; entry: prom_b directory slot T_PanelEvent_NoOp_T40F88 (T_F40F88)
	ret                                           ; F86C59  0e

; ---------------------------------------------------------------------
; PanelEvent_NoOp_T40F8C -- one `ret`, published as thunk slot T_PanelEvent_NoOp_T40F8C (T_F40F8C)
;
; Evidence: prom_b 0xF40F8C holds `jp 0x00F86C5A` and ROM[0xF86C5A] is 0x0E.
; ---------------------------------------------------------------------
PanelEvent_NoOp_T40F8C:   ; entry: prom_b directory slot T_PanelEvent_NoOp_T40F8C (T_F40F8C)
	ret                                           ; F86C5A  0e

; ---------------------------------------------------------------------
; PanelEvent_NoOp_T40F94 -- one `ret`, published as thunk slot T_PanelEvent_NoOp_T40F94 (T_F40F94)
;
; Evidence: prom_b 0xF40F94 holds `jp 0x00F86C5B` and ROM[0xF86C5B] is 0x0E.
; ---------------------------------------------------------------------
PanelEvent_NoOp_T40F94:   ; entry: prom_b directory slot T_PanelEvent_NoOp_T40F94 (T_F40F94)
	ret                                           ; F86C5B  0e

; ---------------------------------------------------------------------
; PanelHold_Tick -- count (0x20A7) down and, at zero, request a screen
;
; Called from: thunk slot T_PanelHold_Tick (T_F40F74) (`jp 0x00F86C5C`); 2 proven call sites
;          (prom_a 0xF8209C, 0xF821F1).
; Body:    (0x20A7) == 0 -> nothing.  Decrement; while it is still non-zero,
;          nothing.  At zero: WA = PanelHold_ScreenRequest[(0x2096)]; a low
;          byte of 0xFF means `no entry`; otherwise (0x2070) = WA (which
;          writes both the screen id and the 0x40 request flag) and
;          `and (0x2075),0xEF`.
; Evidence: the index is `ld WA,(0x2096) / sla 0x01,WA` at 0xF86C6C -- a
;          16-bit index doubled, i.e. a table of WORDS.
; ---------------------------------------------------------------------
PanelHold_Tick:   ; entry: prom_b directory slot T_PanelHold_Tick (T_F40F74)
	ld a, (PanelHold_Timer:16)                            ; F86C5C  c1 a7 20 21   ld A,(0x20a7)
	cp a, 0x00:i3                                   ; F86C60  c9 d8   cp A,0
	jr z, .LF86C8B                                ; F86C62  66 27
	dec 1,A                                       ; F86C64  c9 69
	ld (PanelHold_Timer:16), a                            ; F86C66  f1 a7 20 41   ld (0x20a7),A
	jr nz, .LF86C8B                               ; F86C6A  6e 1f
	ld wa, (PanelHold_Index:16)                          ; F86C6C  d1 96 20 20   ld WA,(0x2096)
	sla wa, 0x01                                  ; F86C70  d8 ec 01   sla 0x01,WA
	ld XHL,PanelHold_ScreenRequest                ; F86C73  43 8c 6c f8 00
	ld	wa, (xhl+wa)                          ; F86C78  d3 07 ec e0 20   ld WA,(XHL+WA)
	cp A,0xff                                     ; F86C7D  c9 cf ff
	jr z, .LF86C8B                                ; F86C80  66 09
	ld (UI_Request:16), wa                           ; F86C82  f1 70 20 50   ld (0x2070),WA
	and	(UI_RequestBits:16), 0xef                     ; F86C86  c1 75 20 3c ef   and (0x2075),0xef
.LF86C8B:
	ret                                           ; F86C8B  0e

; --- 0xF86C8C-0xF86CAD  table (34 bytes) ---

; ---------------------------------------------------------------------
; PanelHold_ScreenRequest -- 17 LE16 words: {screen id, 0x40} or 0xFFFF
;
; Read by: ONE site, `ld XHL,0x00F86C8C / ld WA,(XHL+WA)` at 0xF86C73
;          (PanelHold_Tick), indexed by (0x2096) doubled.
; Contents: [0] 0x4001, [1] 0x4069, [2] 0x4043, [3] 0x406B, [4]..[14] 0xFFFF,
;          [15] 0x4001, [16] 0x4001.
; ★ The high byte of EVERY live entry is 0x40, and 0xF86C82 stores the whole
;          word to (0x2070) -- whose high half is (0x2071), whose bit 6 is
;          0x40.  So an entry is `screen id + the go-there request flag`, the
;          same pair PanelState_Init writes as the literal 0x40AA.  Check H2.
; ⚠ ENTRY COUNT 17 IS UNPINNED.  Nothing bounds (0x2096); the count rests
;          only on the table ending where PanelMode_ToGroup's code begins at
;          0xF86CAE.  The three writers inside this span use indices 0, 2 and
;          7, and prom_a 0xFF4795 compares (0x2096) with 7.
; Evidence: `ld XHL,0x00f86c8c` at 0xF86C73 is the only instruction in
;          either image that names this base, and `ld WA,(XHL+WA)` at
;          0xF86C78 is what makes the stride 2.
; ---------------------------------------------------------------------
PanelHold_ScreenRequest:
	.byte 0x01, 0x40                                    ; F86C8C  [ 0]  0x4001  screen 0x01, request flags 0x40
	.byte 0x69, 0x40                                    ; F86C8E  [ 1]  0x4069  screen 0x69, request flags 0x40
	.byte 0x43, 0x40                                    ; F86C90  [ 2]  0x4043  screen 0x43, request flags 0x40
	.byte 0x6b, 0x40                                    ; F86C92  [ 3]  0x406B  screen 0x6B, request flags 0x40
	.byte 0xff, 0xff                                    ; F86C94  [ 4]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86C96  [ 5]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86C98  [ 6]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86C9A  [ 7]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86C9C  [ 8]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86C9E  [ 9]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86CA0  [10]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86CA2  [11]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86CA4  [12]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86CA6  [13]  0xFFFF  no entry
	.byte 0xff, 0xff                                    ; F86CA8  [14]  0xFFFF  no entry
	.byte 0x01, 0x40                                    ; F86CAA  [15]  0x4001  screen 0x01, request flags 0x40
	.byte 0x01, 0x40                                    ; F86CAC  [16]  0x4001  screen 0x01, request flags 0x40

; ---------------------------------------------------------------------
; PanelMode_ToGroup -- (0x2076) := PanelMode_GroupMap[min((0x2078), 0x1F)]
;
; Called from: PanelTask_Step 0xF86072 (`calr`), and nothing else.
; Evidence: `cp L,0x1f / jr ULE / ld L,0x01` at 0xF86CB4 -- an index above
;          0x1F is replaced by 1, NOT clamped to 0x1F.  That bound is what
;          fixes PanelMode_GroupMap at 32 entries.
; ---------------------------------------------------------------------
PanelMode_ToGroup:   ; entry: calr from 0xF86072
	xor HL,HL                                     ; F86CAE  db d3
	ld l, (PanelMode:16)                            ; F86CB0  c1 78 20 27   ld L,(0x2078)
	cp L,0x1f                                     ; F86CB4  cf cf 1f
	jr ule, .LF86CBB                              ; F86CB7  63 02
	ld l, 0x01:opc                                   ; F86CB9  27 01   ld L,0x01
.LF86CBB:
	ld XIY,PanelMode_GroupMap                    ; F86CBB  45 81 6e f8 00
	add IY,HL                                     ; F86CC0  db 85
	ld A,(XIY)                                    ; F86CC2  85 21
	ld (PanelModeGroup:16), a                            ; F86CC4  f1 76 20 41   ld (0x2076),A
	ret                                           ; F86CC8  0e

; --- 0xF86CC9-0xF86CCA  table (2 bytes) ---

; ---------------------------------------------------------------------
; PanelState_AllowedScreenIds -- 2 bytes: 0xA1, 0xA0
;
; Read by: ONE site, `ld XIX,0x00F86CC9 / ld XBC,2 / cp A,(XIX+) / djnz BC`
;          at 0xF86B24-0xF86B33 (PanelState_CheckRequestAllowed).
; ENTRY COUNT 2, pinned twice: the literal `ld XBC,0x00000002` IS the loop
;          count, and 0xF86CCB begins the 438-byte 0x00 pad.
; Evidence: `ld XIX,0x00f86cc9` at 0xF86B24 is the only instruction in
;          either image that names this base; `cp A,(XIX+)` at 0xF86B2E
;          with `djnz BC` at 0xF86B33 is what makes it a 2-entry scan.
; ⚠ NOT ESTABLISHED: what these two ids MEAN. The table was called
;          PanelHome_ScreenIds and its Note asserted "0xAA -- the id
;          PanelState_Init installs as the home screen" as fact, then said 0xAA
;          is not in the table -- telling the reader it is the home-screen list
;          and that the home screen is not in it. Both halves were wrong: 0xAA is
;          only the power-on default, and the morpheme "home" occurs ZERO times
;          in all four ROM images (grep -aic home over each -> 0). What IS
;          established is the mechanism above: a 2-entry scan that gates whether
;          a screen request is allowed. The two ids are 0xA1 and 0xA0.
; ---------------------------------------------------------------------
PanelState_AllowedScreenIds:
	.byte 0xa1, 0xa0   ; F86CC9

; --- 0xF86CCB-0xF86E80  0x00 pad (438 bytes) ---
	.fill 438, 1, 0x00

; --- 0xF86E81-0xF86EA0  table (32 bytes) ---

; ---------------------------------------------------------------------
; PanelMode_GroupMap -- 32 bytes, (0x2078) -> (0x2076)
;
; Read by: ONE site, `ld XIY,0x00F86E81` at 0xF86CBB (PanelMode_ToGroup).
; ENTRY COUNT 32, pinned by `cp L,0x1f` at 0xF86CB4.
; Contents: 01 01 02 03 03 03 03 03 08 09 0A 0B 0C 0D 0E 0F 10 01 12 13 14
;          15 16 17 01 01 01 01 01 01 01 01 -- every value is <= 0x17, i.e.
;          inside the map's own index range, so it is idempotent-ish and the
;          unused tail (entries 24..31) all fall back to 1.
; Evidence: `ld XIY,0x00f86e81` at 0xF86CBB is the only instruction in
;          either image that names this base, and `cp L,0x1f` three
;          instructions earlier is what bounds the index.
; ---------------------------------------------------------------------
PanelMode_GroupMap:
	.byte 0x01, 0x01, 0x02, 0x03, 0x03, 0x03, 0x03, 0x03, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f   ; F86E81
	.byte 0x10, 0x01, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01   ; F86E91

; --- 0xF86EA1-0xF86EC0  table (32 bytes) ---

; ---------------------------------------------------------------------
; PanelMode_ToScreenIdMap -- 32 bytes, (0x2078) -> a screen id for (0x207C)
;
; Read by: ONE site, `ld XHL,0x00F86EA1` at 0xF86388 (PanelMode_ToScreenId).
; Contents: 01 01 02 04 05 06 0F 1A 12 B0 60 59 33 55 5E 02 60 01 70 5B 40
;          40 33 80 01 01 01 01 01 01 01 01.
; ⚠ ENTRY COUNT 32 IS WEAKLY PINNED.  Its reader has NO bound (0xF8638D-
;          0xF86395 is `xor XWA,XWA / ld A,(0x2078) / add XHL,XWA /
;          ld A,(XHL)`), so 32 rests only on PanelScreen_VtableTable starting
;          at 0xF86EC1.  The map ABOVE it is the one with a hard bound.
; ⚠ Correction: the round-1 dossier said this map is indexed by `the byte
;          the previous map produces`.  It is not -- 0xF86E81's reader WRITES
;          (0x2076) and READS (0x2078), and this reader reads (0x2078) too.
;          They share an input; they are not chained.  Check M2.
; Consistency: every entry is <= 0xDF, the bound PanelScreen_CallEnter_B
;          applies to (0x207C) -- check M3.
; Evidence: `ld XHL,0x00f86ea1` at 0xF86388 is the only instruction in
;          either image that names this base, and 0xF86397 stores the
;          fetched byte to (0x207C) -- which is what makes the values
;          screen ids rather than anything else.
; ---------------------------------------------------------------------
PanelMode_ToScreenIdMap:
	.byte 0x01, 0x01, 0x02, 0x04, 0x05, 0x06, 0x0f, 0x1a, 0x12, 0xb0, 0x60, 0x59, 0x33, 0x55, 0x5e, 0x02   ; F86EA1
	.byte 0x60, 0x01, 0x70, 0x5b, 0x40, 0x40, 0x33, 0x80, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01   ; F86EB1

; --- 0xF86EC1-0xF872C0  pointer table (1024 bytes) ---

; ---------------------------------------------------------------------
; PanelScreen_VtableTable -- 256 LE32 pointers, one screen object each
;
; Read by: `ld XIY,0x00F86EC1` at 0xF864EC and 0xF86520 (view A, index
;          (0x2078)/(0x2079), bound `cp L,0x2f`), and via the alias
;          PanelScreen_VtableTable_ViewB below.
; ENTRY COUNT 256: 1024 bytes, ending exactly at PanelScreen_NullVtable's
;          own code at 0xF872C1 -- which is also the value 81 of the entries
;          hold.  The largest index any reader admits is view B's 0xDF from
;          base entry 32, i.e. entry 255.  Two pins, and they agree.
; ★ EACH ENTRY POINTS AT A THREE-METHOD VTABLE: +0 Enter, +4 Leave, +8
;          Button.  171 of the 174 distinct live pointers land on three
;          consecutive `jp addr24` (opcode 0x1B) inside prom_b's thunk
;          directory; the other 3 land on 0x0E (`ret`) filler there.  The
;          81 stub entries point at PanelScreen_NullVtable, which is built so
;          that all three offsets reach one `ret`.  Checks V1-V4.
; The three offsets come from three different call sites, not from a guess:
;          +0 from PanelScreen_CallEnter_A/B (`ld BC,0x0000`), called with
;             the id that just BECAME current;
;          +4 from PanelScreen_CallLeave_A/B (`ld BC,0x0004`), called with
;             the id that just STOPPED being current;
;          +8 from PanelButton_Route 0xF8621E (`add XBC,0x00000008`), called
;             with the CURRENT id and a button index on the stack.
; Evidence: the +0/+4 pairing is not an assumption -- `ld BC,0x0000` is
;          reached only from the two CURRENT-id detectors (0xF86500,
;          0xF8650F) and `ld BC,0x0004` only from the two PREVIOUS-id ones
;          (0xF86493, 0xF864BD).  Check V6.
; ---------------------------------------------------------------------
; Three entries (13, 85, 86) point into the 0x0E `ret` filler of prom_b's routine directory
; (0xF406B8-0xF406FF holds no slot), so every method of those objects is a lone `ret`: three more
; do-nothing objects, built from filler instead of PanelScreen_NullVtable.  prom_b is linked
; separately, so they are named here, by the address they hold (python3 -c "print(open(
; 'original_ROMs/wsa1_prom_b.ic13','rb').read()[0x406B8:0x40700].hex())" prints only 0e).
	.set PanelScreen_FillerVtable_F406C4,	0x00f406c4
	.set PanelScreen_FillerVtable_F406CC,	0x00f406cc
	.set PanelScreen_FillerVtable_F406DC,	0x00f406dc
PanelScreen_VtableTable:
	.long PanelScreen_NullVtable                ; F86EC1  [0]   -> PanelScreen_NullVtable
	.long T_ModeEnter_Sound                      ; F86EC5  [1]   -> 0xF41500
	.long T_ModeEnter_Combination                              ; F86EC9  [2]   -> 0xF41508
	.long T_ModeEnter_Sequencer                              ; F86ECD  [3]   -> 0xF402A4
	.long PanelScreen_NullVtable                ; F86ED1  [4]   -> PanelScreen_NullVtable
	.long T_ModeEnter_RealtimeRecord_Fwd                              ; F86ED5  [5]   -> 0xF40D98
	.long T_ModeEnter_StepRecord                              ; F86ED9  [6]   -> 0xF43048
	.long T_ModeEnter_Edit                              ; F86EDD  [7]   -> 0xF43040
	.long T_ModeEnter_SeqPlay_Fwd                              ; F86EE1  [8]   -> 0xF40D90
	.long T_ModeEnter_CombiEditPart                              ; F86EE5  [9]   -> 0xF41840
	.long T_PanelMode_System_Enter                              ; F86EE9  [10]   -> 0xF41910
	.long PanelScreen_NullVtable                ; F86EED  [11]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86EF1  [12]   -> PanelScreen_NullVtable
	.long PanelScreen_FillerVtable_F406C4       ; F86EF5  [13]   -> 0xF406C4
	.long PanelScreen_NullVtable                ; F86EF9  [14]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86EFD  [15]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F01  [16]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F05  [17]   -> PanelScreen_NullVtable
	.long T_PanelMode_MidiEnter                              ; F86F09  [18]   -> 0xF41640
	.long PanelScreen_NullVtable                ; F86F0D  [19]   -> PanelScreen_NullVtable
	.long T_ModeEnter_SoundCopy                              ; F86F11  [20]   -> 0xF42254
	.long T_ModeEnter_SoundCopy_Call                              ; F86F15  [21]   -> 0xF4225C
	.long T_CombiEdit_Begin                              ; F86F19  [22]   -> 0xF41A00
	.long T_ModeEnter_SoundEdit                              ; F86F1D  [23]   -> 0xF41F54
	.long PanelScreen_NullVtable                ; F86F21  [24]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F25  [25]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F29  [26]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F2D  [27]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F31  [28]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F35  [29]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F39  [30]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F3D  [31]   -> PanelScreen_NullVtable

; ---------------------------------------------------------------------
; PanelScreen_VtableTable_ViewB -- entry 32 of the table above, used as a
;                                  second base
;
; Read by: `ld XIY,0x00F86F41` at 0xF864CE and 0xF86535, `ld XBC,0x00F86F41`
;          at 0xF86215.  0xF86F41 = 0xF86EC1 + 0x80 = entry 32 exactly.
; So screen ids 0..0xDF read here are table entries 32..255, and mode
; indices 0..0x2F read at PanelScreen_VtableTable are entries 0..47: the two
; views OVERLAP on entries 32..47, 11 of which are live (check V5).
; Evidence: 0xF86F41 - 0xF86EC1 = 0x80 = 32 * 4 exactly, and the two bounds
;          (0x2F from this base's parent, 0xDF from this one) reach entries
;          47 and 255 -- the last entry of the 256-entry table.
; ---------------------------------------------------------------------
PanelScreen_VtableTable_ViewB:
	.long PanelScreen_NullVtable                ; F86F41  [0]   -> PanelScreen_NullVtable
	.long T_InstallPainter_SoundMode_Entry                              ; F86F45  [1]   -> 0xF41520
	.long T_InstallPainter_C0mbinati0nM0de_Entry                              ; F86F49  [2]   -> 0xF41530
	.long PanelScreen_NullVtable                ; F86F4D  [3]   -> PanelScreen_NullVtable
	.long T_Paint_Sequencer                     ; F86F51  [4]   -> 0xF402AC
	.long PanelScreen_NullVtable                ; F86F55  [5]   -> PanelScreen_NullVtable
	.long T_ScreenEnter_RealtimeRecordScreen_Fwd                              ; F86F59  [6]   -> 0xF40DC0
	.long T_ScreenEnterBody_CombiEditMixer                              ; F86F5D  [7]   -> 0xF418B8
	.long T_ScreenEnter_CycleRecordScreen_Fwd                              ; F86F61  [8]   -> 0xF40DD0
	.long PanelScreen_NullVtable                ; F86F65  [9]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F69  [10]   -> PanelScreen_NullVtable
	.long T_ScreenEnter_AfterT0uchSetting       ; F86F6D  [11]   -> 0xF43180
	.long T_ScreenEnter_MetronomeBalanceScreen_Fwd                              ; F86F71  [12]   -> 0xF40E00
	.long T_ScreenEnter_S0ngSelectName          ; F86F75  [13]   -> 0xF431A0
	.long T_ScreenEnter_StepRecord                              ; F86F79  [14]   -> 0xF43160
	.long T_ScreenEnter_StepRecordPartSelect    ; F86F7D  [15]   -> 0xF43170
	.long T_ScreenEnter_TrackAssign             ; F86F81  [16]   -> 0xF43140
	.long T_ScreenEnter_TrackAssignPresets      ; F86F85  [17]   -> 0xF43190
	.long T_ScreenEnter_SeqPlayScreen_Fwd                              ; F86F89  [18]   -> 0xF40DA0
	.long T_ScreenEnter_SequencerMedley         ; F86F8D  [19]   -> 0xF43150
	.long T_ScreenEnter_CyclePlayScreen_Fwd                              ; F86F91  [20]   -> 0xF40DB0
	.long T_ScreenCode15_Handler                              ; F86F95  [21]   -> 0xF431D0
	.long PanelScreen_NullVtable                ; F86F99  [22]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86F9D  [23]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86FA1  [24]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F86FA5  [25]   -> PanelScreen_NullVtable
	.long T_ScreenEnter_Edit                    ; F86FA9  [26]   -> 0xF43050
	.long T_ScreenEnter_SongClear               ; F86FAD  [27]   -> 0xF43060
	.long T_ScreenEnter_TrackClear              ; F86FB1  [28]   -> 0xF43070
	.long T_ScreenEnter_Vel0cityChange          ; F86FB5  [29]   -> 0xF43080
	.long T_ScreenEnter_Quantize                ; F86FB9  [30]   -> 0xF43090
	.long T_ScreenEnter_TrackMerge              ; F86FBD  [31]   -> 0xF430A0
	.long T_ScreenEnter_MeasureErase            ; F86FC1  [32]   -> 0xF430B0
	.long T_ScreenEnter_MeasureC0py             ; F86FC5  [33]   -> 0xF430C0
	.long T_ScreenEnter_MeasureInsert           ; F86FC9  [34]   -> 0xF430D0
	.long T_ScreenEnter_MeasureDelete           ; F86FCD  [35]   -> 0xF430E0
	.long T_ShowScreen_NoteEditPartSelect       ; F86FD1  [36]   -> 0xF402BC
	.long T_EditScreen_EnterNoteEdit                              ; F86FD5  [37]   -> 0xF402CC
	.long T_F40DE0                              ; F86FD9  [38]   -> 0xF40DE0
	.long T_ShowScreen_DrumEditPartSelect       ; F86FDD  [39]   -> 0xF402DC
	.long T_EditScreen_EnterDrumEdit                              ; F86FE1  [40]   -> 0xF402EC
	.long T_ScreenEnter_CyclePlayEditScreen29_Fwd                              ; F86FE5  [41]   -> 0xF40DF0
	.long T_ScreenEnter_S0ngC0py                ; F86FE9  [42]   -> 0xF430F0
	.long T_ScreenEnter_Transp0se               ; F86FED  [43]   -> 0xF43100
	.long T_ScreenEnter_AdvanceDelay            ; F86FF1  [44]   -> 0xF43110
	.long T_ScreenEnter_N0teChange              ; F86FF5  [45]   -> 0xF43120
	.long T_ScreenEnter_PanelWrite              ; F86FF9  [46]   -> 0xF43130
	.long PanelScreen_NullVtable                ; F86FFD  [47]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87001  [48]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87005  [49]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87009  [50]   -> PanelScreen_NullVtable
	.long T_ScreenEnter_CombiEditMenuRedirect                              ; F8700D  [51]   -> 0xF41A08
	.long T_ScreenEnter_CombiEditMenu                              ; F87011  [52]   -> 0xF41A18
	.long T_F41A28                              ; F87015  [53]   -> 0xF41A28
	.long T_ScreenEnter_CombinationNaming                              ; F87019  [54]   -> 0xF41A38
	.long T_F41A48                              ; F8701D  [55]   -> 0xF41A48
	.long T_F41A58                              ; F87021  [56]   -> 0xF41A58
	.long T_ScreenEnter_CombiEditDspEffect                              ; F87025  [57]   -> 0xF41A68
	.long T_ScreenEnter_CombiEditMixer                              ; F87029  [58]   -> 0xF41A78
	.long T_F41A88                              ; F8702D  [59]   -> 0xF41A88
	.long T_Screen_CombinationNaming_Enter                              ; F87031  [60]   -> 0xF41A98
	.long PanelScreen_NullVtable                ; F87035  [61]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87039  [62]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F8703D  [63]   -> PanelScreen_NullVtable
	.long T_Paint_DiskMenu                              ; F87041  [64]   -> 0xF42264
	.long PanelScreen_NullVtable                ; F87045  [65]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87049  [66]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F8704D  [67]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87051  [68]   -> PanelScreen_NullVtable
	.long T_Paint_MidiFileDirectPlay            ; F87055  [69]   -> 0xF42274
	.long PanelScreen_NullVtable                ; F87059  [70]   -> PanelScreen_NullVtable
	.long T_Paint_DiskL0adFile                  ; F8705D  [71]   -> 0xF423A0
	.long PanelScreen_NullVtable                ; F87061  [72]   -> PanelScreen_NullVtable
	.long T_Paint_MidiFileL0ad                  ; F87065  [73]   -> 0xF42400
	.long PanelScreen_NullVtable                ; F87069  [74]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F8706D  [75]   -> PanelScreen_NullVtable
	.long T_PageDispatch_DiskSaveFile                              ; F87071  [76]   -> 0xF423B0
	.long PanelScreen_NullVtable                ; F87075  [77]   -> PanelScreen_NullVtable
	.long T_PageDispatch_MidiFileSave                              ; F87079  [78]   -> 0xF423C0
	.long PanelScreen_NullVtable                ; F8707D  [79]   -> PanelScreen_NullVtable
	.long T_Paint_FloppyDiskFormatSelectType    ; F87081  [80]   -> 0xF423D0
	.long T_Paint_FloppyDiskFormatAreYouSure    ; F87085  [81]   -> 0xF423F0
	.long PanelScreen_NullVtable                ; F87089  [82]   -> PanelScreen_NullVtable
	.long T_PageDispatch_L0adSingleC0mbination                              ; F8708D  [83]   -> 0xF4241C
	.long T_PageDispatch_L0adSingleS0und                              ; F87091  [84]   -> 0xF423E0
	.long PanelScreen_FillerVtable_F406CC       ; F87095  [85]   -> 0xF406CC
	.long PanelScreen_FillerVtable_F406DC       ; F87099  [86]   -> 0xF406DC
	.long PanelScreen_NullVtable                ; F8709D  [87]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F870A1  [88]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F870A5  [89]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F870A9  [90]   -> PanelScreen_NullVtable
	.long T_Screen_SoundGroupNaming_Enter                              ; F870AD  [91]   -> 0xF42680
	.long T_Screen_CombinationGroupNaming_Enter                              ; F870B1  [92]   -> 0xF42690
	.long T_Screen_SoundMute_Enter                              ; F870B5  [93]   -> 0xF434C0
	.long T_Screen_SoundCopy_Enter                              ; F870B9  [94]   -> 0xF426A0
	.long T_Screen_CombinationCopy_Enter                              ; F870BD  [95]   -> 0xF426B0
	.long T_Screen_System_Enter                              ; F870C1  [96]   -> 0xF41918
	.long T_Screen_DataLoadFilter_Enter                              ; F870C5  [97]   -> 0xF41998
	.long T_Screen_TuneScale_Enter                              ; F870C9  [98]   -> 0xF41928
	.long PanelScreen_NullVtable                ; F870CD  [99]   -> PanelScreen_NullVtable
	.long T_Screen_TouchSensitivityOrTest_Enter                              ; F870D1  [100]   -> 0xF41938
	.long T_Screen_ControllerAssign_Enter                              ; F870D5  [101]   -> 0xF41948
	.long T_Screen_DspEffect_Enter                              ; F870D9  [102]   -> 0xF419A8
	.long T_Screen_DrumsMapNaming_Enter                              ; F870DD  [103]   -> 0xF419B8
	.long PanelScreen_NullVtable                ; F870E1  [104]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F870E5  [105]   -> PanelScreen_NullVtable
	.long T_Screen_Initial_Enter                              ; F870E9  [106]   -> 0xF42670
	.long T_Screen_MainOutEqualizer_Enter                              ; F870ED  [107]   -> 0xF41958
	.long T_Screen_ReMapEdit_Enter                              ; F870F1  [108]   -> 0xF41968
	.long T_Screen_SoundCombinationManager_Enter                              ; F870F5  [109]   -> 0xF41978
	.long T_Screen_MemoryProtect_Enter                              ; F870F9  [110]   -> 0xF41988
	.long PanelScreen_NullVtable                ; F870FD  [111]   -> PanelScreen_NullVtable
	.long T_Paint_MidiMenu                              ; F87101  [112]   -> 0xF41650
	.long T_F41660                              ; F87105  [113]   -> 0xF41660
	.long T_F41680                              ; F87109  [114]   -> 0xF41680
	.long T_F41670                              ; F8710D  [115]   -> 0xF41670
	.long PanelScreen_NullVtable                ; F87111  [116]   -> PanelScreen_NullVtable
	.long T_Paint_MidiRealtimeMessages          ; F87115  [117]   -> 0xF41690
	.long T_F416B0                              ; F87119  [118]   -> 0xF416B0
	.long PanelScreen_NullVtable                ; F8711D  [119]   -> PanelScreen_NullVtable
	.long T_F41700                              ; F87121  [120]   -> 0xF41700
	.long T_Paint_SysexBulkDump_Entry                              ; F87125  [121]   -> 0xF41710
	.long T_Paint_GeneralMidiMode_Entry                              ; F87129  [122]   -> 0xF41720
	.long T_F416A0                              ; F8712D  [123]   -> 0xF416A0
	.long T_F416C0                              ; F87131  [124]   -> 0xF416C0
	.long T_Paint_MidiTotalMode                 ; F87135  [125]   -> 0xF4173C
	.long T_Paint_MidiInputOutputFilter         ; F87139  [126]   -> 0xF4174C
	.long T_Paint_MidiOutProgramChange          ; F8713D  [127]   -> 0xF4175C
	.long T_ScreenEnter_SoundEditMenu                              ; F87141  [128]   -> 0xF41F5C
	.long PanelScreen_NullVtable                ; F87145  [129]   -> PanelScreen_NullVtable
	.long T_ScreenEnter_SoundEditModelingToneTemplate                              ; F87149  [130]   -> 0xF4215C
	.long T_ScreenEnter_SoundEditToneLayerPanning                              ; F8714D  [131]   -> 0xF4216C
	.long T_ScreenEnter_SoundEditToneLayerKeyLayer                              ; F87151  [132]   -> 0xF4217C
	.long T_ScreenEnter_SoundEditToneLayerVelocityLayer                              ; F87155  [133]   -> 0xF4218C
	.long T_ScreenEnter_SoundEditModelingDriverWaveform                              ; F87159  [134]   -> 0xF4219C
	.long T_ScreenEnter_SoundEditPitchTune                              ; F8715D  [135]   -> 0xF41FFC
	.long T_ScreenEnter_SoundEditPitchEnvelope1                              ; F87161  [136]   -> 0xF4200C
	.long T_ScreenEnter_SoundEditPitchEnvelope2                              ; F87165  [137]   -> 0xF4201C
	.long T_ScreenEnter_SoundEditPitchLfo                              ; F87169  [138]   -> 0xF4202C
	.long T_ScreenEnter_SoundEditAmpLevel1                              ; F8716D  [139]   -> 0xF4203C
	.long T_ScreenEnter_SoundEditAmpLevel2                              ; F87171  [140]   -> 0xF4204C
	.long T_ScreenEnter_SoundEditAmpEnvelope1                              ; F87175  [141]   -> 0xF4205C
	.long T_ScreenEnter_SoundEditAmpEnvelope2                              ; F87179  [142]   -> 0xF4206C
	.long T_ScreenEnter_SoundEditAmpLfo                              ; F8717D  [143]   -> 0xF4207C
	.long T_ScreenEnter_SoundEditFilterLpf12                              ; F87181  [144]   -> 0xF420BC
	.long T_ScreenEnter_SoundEditFilterHpf12                              ; F87185  [145]   -> 0xF420CC
	.long T_ScreenEnter_SoundEditFilterLpf24                              ; F87189  [146]   -> 0xF420DC
	.long T_ScreenEnter_SoundEditFilterHpf24                              ; F8718D  [147]   -> 0xF420EC
	.long T_ScreenEnter_SoundEditFilterBpf                              ; F87191  [148]   -> 0xF420FC
	.long T_ScreenEnter_SoundEditFilterThrough                              ; F87195  [149]   -> 0xF4210C
	.long T_ScreenEnter_SoundEditFilterKeyFollow                              ; F87199  [150]   -> 0xF4211C
	.long T_ScreenEnter_SoundEditFilterEnvelope1                              ; F8719D  [151]   -> 0xF4212C
	.long T_ScreenEnter_SoundEditFilterEnvelope2                              ; F871A1  [152]   -> 0xF4213C
	.long T_ScreenEnter_SoundEditFilterLfo                              ; F871A5  [153]   -> 0xF4214C
	.long T_ScreenEnter_SoundEditDigitalEffect                              ; F871A9  [154]   -> 0xF433D0
	.long T_ScreenEnter_SoundEditControllerPage2                              ; F871AD  [155]   -> 0xF4209C
	.long T_ScreenEnter_SoundEditDigitalEffectFromMenu                              ; F871B1  [156]   -> 0xF420AC
	.long T_ScreenEnter_SoundEditCopy                              ; F871B5  [157]   -> 0xF42350
	.long T_ScreenEnter_SoundEditMemoryWrite                              ; F871B9  [158]   -> 0xF42360
	.long T_ScreenEnter_SoundEditNaming                              ; F871BD  [159]   -> 0xF42370
	.long T_InstallPainter_SoundGroupMenu_Entry                              ; F871C1  [160]   -> 0xF41540
	.long T_InstallPainter_GroupSoundDisplayHold_Entry                              ; F871C5  [161]   -> 0xF41550
	.long T_InstallPainter_CombinationGroupMenu_Entry                              ; F871C9  [162]   -> 0xF41560
	.long T_ScreenEnter_DrawbarScreen                              ; F871CD  [163]   -> 0xF42E44
	.long PanelScreen_NullVtable                ; F871D1  [164]   -> PanelScreen_NullVtable
	.long T_InstallPainter_CombinationGroupMenu_Entry_5                              ; F871D5  [165]   -> 0xF41570
	.long T_InstallPainter_GroupCombiDisplayHold_Entry                              ; F871D9  [166]   -> 0xF41580
	.long T_F41590                              ; F871DD  [167]   -> 0xF41590
	.long PanelScreen_NullVtable                ; F871E1  [168]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F871E5  [169]   -> PanelScreen_NullVtable
	.long T_ScreenEnter_PowerOnSplash                              ; F871E9  [170]   -> 0xF41510
	.long T_InstallPainter_MessageScreen                              ; F871ED  [171]   -> 0xF41604
	.long PanelScreen_NullVtable                ; F871F1  [172]   -> PanelScreen_NullVtable
	.long T_ScreenEnter_CreatorSelectController                              ; F871F5  [173]   -> 0xF434E0
	.long PanelScreen_NullVtable                ; F871F9  [174]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F871FD  [175]   -> PanelScreen_NullVtable
	.long T_ScreenEnter_CombiEditPartMenu                              ; F87201  [176]   -> 0xF41848
	.long T_ScreenEnter_CombiEditInternalSound                              ; F87205  [177]   -> 0xF41858
	.long T_ScreenEnter_CombiEditConfigure_B2                              ; F87209  [178]   -> 0xF41868
	.long T_ScreenEnter_WriteProtectError                              ; F8720D  [179]   -> 0xF41878
	.long T_ScreenEnter_CombiEditInternalSound_B4                              ; F87211  [180]   -> 0xF41888
	.long T_ScreenEnter_CombiEditInternalSound_B5                              ; F87215  [181]   -> 0xF41898
	.long T_ScreenEnter_Effect2OutputConflict                              ; F87219  [182]   -> 0xF418A8
	.long T_ScreenEnterBody_CombiEditMixer                              ; F8721D  [183]   -> 0xF418B8
	.long PanelScreen_NullVtable                ; F87221  [184]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87225  [185]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87229  [186]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F8722D  [187]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87231  [188]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87235  [189]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87239  [190]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F8723D  [191]   -> PanelScreen_NullVtable
	.long T_ToneEditPage_A0_ModelingTop                              ; F87241  [192]   -> 0xF41F6C
	.long T_F41F7C                              ; F87245  [193]   -> 0xF41F7C
	.long T_F41F8C                              ; F87249  [194]   -> 0xF41F8C
	.long T_ToneEditPage_A3_PositionParameter                              ; F8724D  [195]   -> 0xF41F9C
	.long T_ToneEditPage_A4_PositionMovement                              ; F87251  [196]   -> 0xF41FAC
	.long T_ToneEditPage_A5_FittingMutingTuning                              ; F87255  [197]   -> 0xF41FBC
	.long T_ToneEditPage_A6_TouchDepth                              ; F87259  [198]   -> 0xF41FCC
	.long T_ToneEditPage_A7_ResoModeKeyFollow                              ; F8725D  [199]   -> 0xF41FDC
	.long T_ToneEditPage_A8_SerialParallel                              ; F87261  [200]   -> 0xF41FEC
	.long PanelScreen_NullVtable                ; F87265  [201]   -> PanelScreen_NullVtable
	.long T_ScreenEnter_SoundEditDspEffect                              ; F87269  [202]   -> 0xF42320
	.long T_ScreenEnter_SoundEditDrumMenu                              ; F8726D  [203]   -> 0xF42330
	.long T_F42340                              ; F87271  [204]   -> 0xF42340
	.long T_ScreenEnter_SoundEditControllerPage1                              ; F87275  [205]   -> 0xF4208C
	.long T_F433E0                              ; F87279  [206]   -> 0xF433E0
	.long PanelScreen_NullVtable                ; F8727D  [207]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87281  [208]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87285  [209]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87289  [210]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F8728D  [211]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87291  [212]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87295  [213]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F87299  [214]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F8729D  [215]   -> PanelScreen_NullVtable
	.long T_Paint_GateArrayCheck                ; F872A1  [216]   -> 0xF400D0
	.long T_Paint_PanelCpuCheck                 ; F872A5  [217]   -> 0xF400E0
	.long T_Paint_SineWaveCheckMode             ; F872A9  [218]   -> 0xF400F0
	.long T_Paint_PanelSwLedCheck               ; F872AD  [219]   -> 0xF40100
	.long T_F40110                              ; F872B1  [220]   -> 0xF40110
	.long T_ScreenEnter_DebugMonitor                              ; F872B5  [221]   -> 0xF40130
	.long PanelScreen_NullVtable                ; F872B9  [222]   -> PanelScreen_NullVtable
	.long PanelScreen_NullVtable                ; F872BD  [223]   -> PanelScreen_NullVtable

; ---------------------------------------------------------------------
; PanelScreen_NullVtable -- the do-nothing screen object
;
; Called from: 81 of the 256 entries of PanelScreen_VtableTable point here
;          (check V2), and nothing calls the address directly.
; Body:    `jr T,+6 / jr T,+4 / jr T,+2 / jr T,+0 / ret` -- four 2-byte
;          branches at 0xF872C1, 0xF872C3, 0xF872C5, 0xF872C7, all landing
;          on the `ret` at 0xF872C9.
; ★ Evidence for the whole vtable reading: this object is laid out so that
;          BOTH +0, +4 AND +8 reach that `ret`.  Nothing else explains four
;          branches to the same target four bytes apart.  Check V3.
; Evidence: ROM[0xF872C1..0xF872C9] = 68 06 68 04 68 02 68 00 0E, and 81 of
;          the 256 entries of PanelScreen_VtableTable hold 0x00F872C1.
; ---------------------------------------------------------------------
PanelScreen_NullVtable:
	jr .LF872C9                                   ; F872C1  68 06
	jr .LF872C9                                   ; F872C3  68 04
	jr .LF872C9                                   ; F872C5  68 02
	jr .LF872C9                                   ; F872C7  68 00
.LF872C9:
	ret                                           ; F872C9  0e

; --- 0xF872CA-0xF87680  0x00 pad (951 bytes) ---
	.fill 951, 1, 0x00

; --- 0xF87681-0xF87980  pointer table (768 bytes) ---

; ---------------------------------------------------------------------
; UiEventClass_ListTable_A -- 192 LE32 heads, indexed by the event class
;
; Read by: ONE site, `ld XIY,0x00F87681 / ld (0x20C0),XIY` at UiEventList_RunPassA 0xF8697E;
;          UiEventList_Run indexes it with the record's byte +0.
; ENTRY COUNT 192, pinned twice: `cp L,0xbf` at 0xF869FB rejects a class
;          above 191, and the 0x300-byte extent is 192 * 4.  The table
;          ends one pad byte before its own list area.
; ★ 121 class ids have their own list and the other 71 share the area's
;          trailing empty list -- and the SAME 121 ids do so in all
;          THREE tables (check L2).  The distinct heads tile the list
;          area exactly, in ascending order, with no byte left over
;          (check L3).
; Evidence: `ld XIY,0x00F87681` at 0xF8697E, four bytes before `ld (0x20C0),XIY`;
;          UiEventList_Run reads (0x20C0) at 0xF869EF and indexes it
;          with `sla 0x02,HL` at 0xF86A00.
; ---------------------------------------------------------------------
UiEventClass_ListTable_A:
	.long UiListA_Class00                       ; F87681  [0]   -> UiListA_Class00
	.long UiListA_Class01                       ; F87685  [1]   -> UiListA_Class01
	.long UiListA_Class02                       ; F87689  [2]   -> UiListA_Class02
	.long UiListA_Class03                       ; F8768D  [3]   -> UiListA_Class03
	.long UiListA_Class04                       ; F87691  [4]   -> UiListA_Class04
	.long UiListA_Class05                       ; F87695  [5]   -> UiListA_Class05
	.long UiListA_Class06                       ; F87699  [6]   -> UiListA_Class06
	.long UiListA_Class07                       ; F8769D  [7]   -> UiListA_Class07
	.long UiListA_Class08                       ; F876A1  [8]   -> UiListA_Class08
	.long UiListA_Class09                       ; F876A5  [9]   -> UiListA_Class09
	.long UiListA_Class0A                       ; F876A9  [10]   -> UiListA_Class0A
	.long UiListA_Class0B                       ; F876AD  [11]   -> UiListA_Class0B
	.long UiListA_Class0C                       ; F876B1  [12]   -> UiListA_Class0C
	.long UiListA_Class0D                       ; F876B5  [13]   -> UiListA_Class0D
	.long UiListA_Class0E                       ; F876B9  [14]   -> UiListA_Class0E
	.long UiListA_Class0F                       ; F876BD  [15]   -> UiListA_Class0F
	.long UiListA_Class10                       ; F876C1  [16]   -> UiListA_Class10
	.long UiListA_Class11                       ; F876C5  [17]   -> UiListA_Class11
	.long UiListA_Class12                       ; F876C9  [18]   -> UiListA_Class12
	.long UiListA_Class13                       ; F876CD  [19]   -> UiListA_Class13
	.long UiListA_Class14                       ; F876D1  [20]   -> UiListA_Class14
	.long UiListA_Class15                       ; F876D5  [21]   -> UiListA_Class15
	.long UiListA_Class16                       ; F876D9  [22]   -> UiListA_Class16
	.long UiListA_Class17                       ; F876DD  [23]   -> UiListA_Class17
	.long UiListA_Class18                       ; F876E1  [24]   -> UiListA_Class18
	.long UiListA_Class19                       ; F876E5  [25]   -> UiListA_Class19
	.long UiListA_Class1A                       ; F876E9  [26]   -> UiListA_Class1A
	.long UiListA_Class1B                       ; F876ED  [27]   -> UiListA_Class1B
	.long UiListA_Class1C                       ; F876F1  [28]   -> UiListA_Class1C
	.long UiListA_Class1D                       ; F876F5  [29]   -> UiListA_Class1D
	.long UiListA_Class1E                       ; F876F9  [30]   -> UiListA_Class1E
	.long UiListA_Class1F                       ; F876FD  [31]   -> UiListA_Class1F
	.long UiListA_Class20                       ; F87701  [32]   -> UiListA_Class20
	.long UiListA_Class21                       ; F87705  [33]   -> UiListA_Class21
	.long UiListA_Class22                       ; F87709  [34]   -> UiListA_Class22
	.long UiListA_Class23                       ; F8770D  [35]   -> UiListA_Class23
	.long UiListA_Class24                       ; F87711  [36]   -> UiListA_Class24
	.long UiListA_Class25                       ; F87715  [37]   -> UiListA_Class25
	.long UiListA_Class26                       ; F87719  [38]   -> UiListA_Class26
	.long UiListA_Class27                       ; F8771D  [39]   -> UiListA_Class27
	.long UiListA_Class28                       ; F87721  [40]   -> UiListA_Class28
	.long UiListA_Class29                       ; F87725  [41]   -> UiListA_Class29
	.long UiListA_Class2A                       ; F87729  [42]   -> UiListA_Class2A
	.long UiListA_Class2B                       ; F8772D  [43]   -> UiListA_Class2B
	.long UiListA_Class2C                       ; F87731  [44]   -> UiListA_Class2C
	.long UiListA_Class2D                       ; F87735  [45]   -> UiListA_Class2D
	.long UiListA_Class2E                       ; F87739  [46]   -> UiListA_Class2E
	.long UiListA_Class2F                       ; F8773D  [47]   -> UiListA_Class2F
	.long UiListA_Class30                       ; F87741  [48]   -> UiListA_Class30
	.long UiListA_Class31                       ; F87745  [49]   -> UiListA_Class31
	.long UiListA_Class32                       ; F87749  [50]   -> UiListA_Class32
	.long UiListA_Class33                       ; F8774D  [51]   -> UiListA_Class33
	.long UiListA_Class34                       ; F87751  [52]   -> UiListA_Class34
	.long UiListA_Class35                       ; F87755  [53]   -> UiListA_Class35
	.long UiListA_Class36                       ; F87759  [54]   -> UiListA_Class36
	.long UiListA_Class37                       ; F8775D  [55]   -> UiListA_Class37
	.long UiListA_Class38                       ; F87761  [56]   -> UiListA_Class38
	.long UiListA_Class39                       ; F87765  [57]   -> UiListA_Class39
	.long UiListA_Class3A                       ; F87769  [58]   -> UiListA_Class3A
	.long UiListA_Class3B                       ; F8776D  [59]   -> UiListA_Class3B
	.long UiListA_Class3C                       ; F87771  [60]   -> UiListA_Class3C
	.long UiListA_Class3D                       ; F87775  [61]   -> UiListA_Class3D
	.long UiListA_Class3E                       ; F87779  [62]   -> UiListA_Class3E
	.long UiListA_Class3F                       ; F8777D  [63]   -> UiListA_Class3F
	.long UiListA_Class40                       ; F87781  [64]   -> UiListA_Class40
	.long UiListA_Class41                       ; F87785  [65]   -> UiListA_Class41
	.long UiListA_Class42                       ; F87789  [66]   -> UiListA_Class42
	.long UiListA_Shared                        ; F8778D  [67]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87791  [68]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87795  [69]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87799  [70]   -> UiListA_Shared
	.long UiListA_Shared                        ; F8779D  [71]   -> UiListA_Shared
	.long UiListA_Class48                       ; F877A1  [72]   -> UiListA_Class48
	.long UiListA_Shared                        ; F877A5  [73]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877A9  [74]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877AD  [75]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877B1  [76]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877B5  [77]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877B9  [78]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877BD  [79]   -> UiListA_Shared
	.long UiListA_Class50                       ; F877C1  [80]   -> UiListA_Class50
	.long UiListA_Class51                       ; F877C5  [81]   -> UiListA_Class51
	.long UiListA_Class52                       ; F877C9  [82]   -> UiListA_Class52
	.long UiListA_Class53                       ; F877CD  [83]   -> UiListA_Class53
	.long UiListA_Class54                       ; F877D1  [84]   -> UiListA_Class54
	.long UiListA_Shared                        ; F877D5  [85]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877D9  [86]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877DD  [87]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877E1  [88]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877E5  [89]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877E9  [90]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877ED  [91]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877F1  [92]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877F5  [93]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877F9  [94]   -> UiListA_Shared
	.long UiListA_Shared                        ; F877FD  [95]   -> UiListA_Shared
	.long UiListA_Class60                       ; F87801  [96]   -> UiListA_Class60
	.long UiListA_Class61                       ; F87805  [97]   -> UiListA_Class61
	.long UiListA_Class62                       ; F87809  [98]   -> UiListA_Class62
	.long UiListA_Class63                       ; F8780D  [99]   -> UiListA_Class63
	.long UiListA_Class64                       ; F87811  [100]   -> UiListA_Class64
	.long UiListA_Class65                       ; F87815  [101]   -> UiListA_Class65
	.long UiListA_Class66                       ; F87819  [102]   -> UiListA_Class66
	.long UiListA_Shared                        ; F8781D  [103]   -> UiListA_Shared
	.long UiListA_Class68                       ; F87821  [104]   -> UiListA_Class68
	.long UiListA_Class69                       ; F87825  [105]   -> UiListA_Class69
	.long UiListA_Class6A                       ; F87829  [106]   -> UiListA_Class6A
	.long UiListA_Class6B                       ; F8782D  [107]   -> UiListA_Class6B
	.long UiListA_Class6C                       ; F87831  [108]   -> UiListA_Class6C
	.long UiListA_Class6D                       ; F87835  [109]   -> UiListA_Class6D
	.long UiListA_Class6E                       ; F87839  [110]   -> UiListA_Class6E
	.long UiListA_Shared                        ; F8783D  [111]   -> UiListA_Shared
	.long UiListA_Class70                       ; F87841  [112]   -> UiListA_Class70
	.long UiListA_Class71                       ; F87845  [113]   -> UiListA_Class71
	.long UiListA_Class72                       ; F87849  [114]   -> UiListA_Class72
	.long UiListA_Shared                        ; F8784D  [115]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87851  [116]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87855  [117]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87859  [118]   -> UiListA_Shared
	.long UiListA_Shared                        ; F8785D  [119]   -> UiListA_Shared
	.long UiListA_Class78                       ; F87861  [120]   -> UiListA_Class78
	.long UiListA_Class79                       ; F87865  [121]   -> UiListA_Class79
	.long UiListA_Class7A                       ; F87869  [122]   -> UiListA_Class7A
	.long UiListA_Shared                        ; F8786D  [123]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87871  [124]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87875  [125]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87879  [126]   -> UiListA_Shared
	.long UiListA_Shared                        ; F8787D  [127]   -> UiListA_Shared
	.long UiListA_Class80                       ; F87881  [128]   -> UiListA_Class80
	.long UiListA_Class81                       ; F87885  [129]   -> UiListA_Class81
	.long UiListA_Shared                        ; F87889  [130]   -> UiListA_Shared
	.long UiListA_Shared                        ; F8788D  [131]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87891  [132]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87895  [133]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87899  [134]   -> UiListA_Shared
	.long UiListA_Shared                        ; F8789D  [135]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878A1  [136]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878A5  [137]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878A9  [138]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878AD  [139]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878B1  [140]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878B5  [141]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878B9  [142]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878BD  [143]   -> UiListA_Shared
	.long UiListA_Class90                       ; F878C1  [144]   -> UiListA_Class90
	.long UiListA_Class91                       ; F878C5  [145]   -> UiListA_Class91
	.long UiListA_Class92                       ; F878C9  [146]   -> UiListA_Class92
	.long UiListA_Class93                       ; F878CD  [147]   -> UiListA_Class93
	.long UiListA_Shared                        ; F878D1  [148]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878D5  [149]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878D9  [150]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878DD  [151]   -> UiListA_Shared
	.long UiListA_Class98                       ; F878E1  [152]   -> UiListA_Class98
	.long UiListA_Class99                       ; F878E5  [153]   -> UiListA_Class99
	.long UiListA_Class9A                       ; F878E9  [154]   -> UiListA_Class9A
	.long UiListA_Shared                        ; F878ED  [155]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878F1  [156]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878F5  [157]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878F9  [158]   -> UiListA_Shared
	.long UiListA_Shared                        ; F878FD  [159]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87901  [160]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87905  [161]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87909  [162]   -> UiListA_Shared
	.long UiListA_Shared                        ; F8790D  [163]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87911  [164]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87915  [165]   -> UiListA_Shared
	.long UiListA_Shared                        ; F87919  [166]   -> UiListA_Shared
	.long UiListA_Shared                        ; F8791D  [167]   -> UiListA_Shared
	.long UiListA_ClassA8                       ; F87921  [168]   -> UiListA_ClassA8
	.long UiListA_ClassA9                       ; F87925  [169]   -> UiListA_ClassA9
	.long UiListA_Shared                        ; F87929  [170]   -> UiListA_Shared
	.long UiListA_Shared                        ; F8792D  [171]   -> UiListA_Shared
	.long UiListA_ClassAC                       ; F87931  [172]   -> UiListA_ClassAC
	.long UiListA_ClassAD                       ; F87935  [173]   -> UiListA_ClassAD
	.long UiListA_ClassAE                       ; F87939  [174]   -> UiListA_ClassAE
	.long UiListA_Shared                        ; F8793D  [175]   -> UiListA_Shared
	.long UiListA_ClassB0                       ; F87941  [176]   -> UiListA_ClassB0
	.long UiListA_ClassB1                       ; F87945  [177]   -> UiListA_ClassB1
	.long UiListA_ClassB2                       ; F87949  [178]   -> UiListA_ClassB2
	.long UiListA_ClassB3                       ; F8794D  [179]   -> UiListA_ClassB3
	.long UiListA_ClassB4                       ; F87951  [180]   -> UiListA_ClassB4
	.long UiListA_ClassB5                       ; F87955  [181]   -> UiListA_ClassB5
	.long UiListA_ClassB6                       ; F87959  [182]   -> UiListA_ClassB6
	.long UiListA_ClassB7                       ; F8795D  [183]   -> UiListA_ClassB7
	.long UiListA_ClassB8                       ; F87961  [184]   -> UiListA_ClassB8
	.long UiListA_ClassB9                       ; F87965  [185]   -> UiListA_ClassB9
	.long UiListA_ClassBA                       ; F87969  [186]   -> UiListA_ClassBA
	.long UiListA_ClassBB                       ; F8796D  [187]   -> UiListA_ClassBB
	.long UiListA_ClassBC                       ; F87971  [188]   -> UiListA_ClassBC
	.long UiListA_ClassBD                       ; F87975  [189]   -> UiListA_ClassBD
	.long UiListA_Shared                        ; F87979  [190]   -> UiListA_Shared
	.long UiListA_Shared                        ; F8797D  [191]   -> UiListA_Shared

; --- 0xF87981-0xF87981  pad (1 bytes) ---
	.byte 0xff   ; F87981

; --- 0xF87982-0xF87B71  handler lists (496 bytes) ---
; ---------------------------------------------------------------------
; UiEventLists_A -- the 122 handler lists of pass A, tiling 0xF87982-0xF87B71
;
; Each list is LE32 routine addresses terminated by 0xFFFFFFFF.  120 of
; the 122 are EMPTY (the terminator and nothing else); 2 carry handlers.
; ⚠ The labels below are GENERATED: each is named after the LOWEST class
; id whose UiEventClass_ListTable_A entry points at it, and says nothing
; about what the list DOES.  UiListA_Shared is the empty list the 71
; classes without their own head share.
; Evidence: the heads are the table's own values -- nothing here is
;          framed by content.  They tile the area with no gap and no
;          overlap, every one ends in 0xFFFFFFFF, and the last one ends
;          exactly at the area's end (checks L3, L5).
; ---------------------------------------------------------------------
; Evidence: UiEventClass_ListTable_A[0x00], the LE32 at 0xF87681, holds 0xF87982.  GENERATED name.
UiListA_Class00:
	.long 0xFFFFFFFF                            ; F87982  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x01], the LE32 at 0xF87685, holds 0xF87986.  GENERATED name.
UiListA_Class01:
	.long 0xFFFFFFFF                            ; F87986  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x02], the LE32 at 0xF87689, holds 0xF8798A.  GENERATED name.
UiListA_Class02:
	.long 0xFFFFFFFF                            ; F8798A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x03], the LE32 at 0xF8768D, holds 0xF8798E.  GENERATED name.
UiListA_Class03:
	.long 0xFFFFFFFF                            ; F8798E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x04], the LE32 at 0xF87691, holds 0xF87992.  GENERATED name.
UiListA_Class04:
	.long 0xFFFFFFFF                            ; F87992  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x05], the LE32 at 0xF87695, holds 0xF87996.  GENERATED name.
UiListA_Class05:
	.long 0xFFFFFFFF                            ; F87996  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x06], the LE32 at 0xF87699, holds 0xF8799A.  GENERATED name.
UiListA_Class06:
	.long 0xFFFFFFFF                            ; F8799A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x07], the LE32 at 0xF8769D, holds 0xF8799E.  GENERATED name.
UiListA_Class07:
	.long 0xFFFFFFFF                            ; F8799E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x08], the LE32 at 0xF876A1, holds 0xF879A2.  GENERATED name.
UiListA_Class08:
	.long 0xFFFFFFFF                            ; F879A2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x09], the LE32 at 0xF876A5, holds 0xF879A6.  GENERATED name.
UiListA_Class09:
	.long 0xFFFFFFFF                            ; F879A6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x0A], the LE32 at 0xF876A9, holds 0xF879AA.  GENERATED name.
UiListA_Class0A:
	.long 0xFFFFFFFF                            ; F879AA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x0B], the LE32 at 0xF876AD, holds 0xF879AE.  GENERATED name.
UiListA_Class0B:
	.long 0xFFFFFFFF                            ; F879AE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x0C], the LE32 at 0xF876B1, holds 0xF879B2.  GENERATED name.
UiListA_Class0C:
	.long 0xFFFFFFFF                            ; F879B2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x0D], the LE32 at 0xF876B5, holds 0xF879B6.  GENERATED name.
UiListA_Class0D:
	.long 0xFFFFFFFF                            ; F879B6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x0E], the LE32 at 0xF876B9, holds 0xF879BA.  GENERATED name.
UiListA_Class0E:
	.long 0xFFFFFFFF                            ; F879BA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x0F], the LE32 at 0xF876BD, holds 0xF879BE.  GENERATED name.
UiListA_Class0F:
	.long 0xFFFFFFFF                            ; F879BE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x10], the LE32 at 0xF876C1, holds 0xF879C2.  GENERATED name.
UiListA_Class10:
	.long 0xFFFFFFFF                            ; F879C2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x11], the LE32 at 0xF876C5, holds 0xF879C6.  GENERATED name.
UiListA_Class11:
	.long 0xFFFFFFFF                            ; F879C6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x12], the LE32 at 0xF876C9, holds 0xF879CA.  GENERATED name.
UiListA_Class12:
	.long 0xFFFFFFFF                            ; F879CA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x13], the LE32 at 0xF876CD, holds 0xF879CE.  GENERATED name.
UiListA_Class13:
	.long 0xFFFFFFFF                            ; F879CE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x14], the LE32 at 0xF876D1, holds 0xF879D2.  GENERATED name.
UiListA_Class14:
	.long 0xFFFFFFFF                            ; F879D2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x15], the LE32 at 0xF876D5, holds 0xF879D6.  GENERATED name.
UiListA_Class15:
	.long 0xFFFFFFFF                            ; F879D6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x16], the LE32 at 0xF876D9, holds 0xF879DA.  GENERATED name.
UiListA_Class16:
	.long 0xFFFFFFFF                            ; F879DA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x17], the LE32 at 0xF876DD, holds 0xF879DE.  GENERATED name.
UiListA_Class17:
	.long 0xFFFFFFFF                            ; F879DE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x18], the LE32 at 0xF876E1, holds 0xF879E2.  GENERATED name.
UiListA_Class18:
	.long 0xFFFFFFFF                            ; F879E2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x19], the LE32 at 0xF876E5, holds 0xF879E6.  GENERATED name.
UiListA_Class19:
	.long 0xFFFFFFFF                            ; F879E6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x1A], the LE32 at 0xF876E9, holds 0xF879EA.  GENERATED name.
UiListA_Class1A:
	.long 0xFFFFFFFF                            ; F879EA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x1B], the LE32 at 0xF876ED, holds 0xF879EE.  GENERATED name.
UiListA_Class1B:
	.long 0xFFFFFFFF                            ; F879EE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x1C], the LE32 at 0xF876F1, holds 0xF879F2.  GENERATED name.
UiListA_Class1C:
	.long 0xFFFFFFFF                            ; F879F2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x1D], the LE32 at 0xF876F5, holds 0xF879F6.  GENERATED name.
UiListA_Class1D:
	.long 0xFFFFFFFF                            ; F879F6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x1E], the LE32 at 0xF876F9, holds 0xF879FA.  GENERATED name.
UiListA_Class1E:
	.long 0xFFFFFFFF                            ; F879FA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x1F], the LE32 at 0xF876FD, holds 0xF879FE.  GENERATED name.
UiListA_Class1F:
	.long 0xFFFFFFFF                            ; F879FE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x20], the LE32 at 0xF87701, holds 0xF87A02.  GENERATED name.
UiListA_Class20:
	.long 0xFFFFFFFF                            ; F87A02  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x21], the LE32 at 0xF87705, holds 0xF87A06.  GENERATED name.
UiListA_Class21:
	.long 0xFFFFFFFF                            ; F87A06  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x22], the LE32 at 0xF87709, holds 0xF87A0A.  GENERATED name.
UiListA_Class22:
	.long 0xFFFFFFFF                            ; F87A0A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x23], the LE32 at 0xF8770D, holds 0xF87A0E.  GENERATED name.
UiListA_Class23:
	.long 0xFFFFFFFF                            ; F87A0E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x24], the LE32 at 0xF87711, holds 0xF87A12.  GENERATED name.
UiListA_Class24:
	.long 0xFFFFFFFF                            ; F87A12  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x25], the LE32 at 0xF87715, holds 0xF87A16.  GENERATED name.
UiListA_Class25:
	.long 0xFFFFFFFF                            ; F87A16  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x26], the LE32 at 0xF87719, holds 0xF87A1A.  GENERATED name.
UiListA_Class26:
	.long 0xFFFFFFFF                            ; F87A1A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x27], the LE32 at 0xF8771D, holds 0xF87A1E.  GENERATED name.
UiListA_Class27:
	.long 0xFFFFFFFF                            ; F87A1E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x28], the LE32 at 0xF87721, holds 0xF87A22.  GENERATED name.
UiListA_Class28:
	.long 0xFFFFFFFF                            ; F87A22  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x29], the LE32 at 0xF87725, holds 0xF87A26.  GENERATED name.
UiListA_Class29:
	.long 0xFFFFFFFF                            ; F87A26  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x2A], the LE32 at 0xF87729, holds 0xF87A2A.  GENERATED name.
UiListA_Class2A:
	.long 0xFFFFFFFF                            ; F87A2A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x2B], the LE32 at 0xF8772D, holds 0xF87A2E.  GENERATED name.
UiListA_Class2B:
	.long 0xFFFFFFFF                            ; F87A2E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x2C], the LE32 at 0xF87731, holds 0xF87A32.  GENERATED name.
UiListA_Class2C:
	.long 0xFFFFFFFF                            ; F87A32  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x2D], the LE32 at 0xF87735, holds 0xF87A36.  GENERATED name.
UiListA_Class2D:
	.long 0xFFFFFFFF                            ; F87A36  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x2E], the LE32 at 0xF87739, holds 0xF87A3A.  GENERATED name.
UiListA_Class2E:
	.long 0xFFFFFFFF                            ; F87A3A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x2F], the LE32 at 0xF8773D, holds 0xF87A3E.  GENERATED name.
UiListA_Class2F:
	.long 0xFFFFFFFF                            ; F87A3E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x30], the LE32 at 0xF87741, holds 0xF87A42.  GENERATED name.
UiListA_Class30:
	.long 0xFFFFFFFF                            ; F87A42  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x31], the LE32 at 0xF87745, holds 0xF87A46.  GENERATED name.
UiListA_Class31:
	.long 0xFFFFFFFF                            ; F87A46  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x32], the LE32 at 0xF87749, holds 0xF87A4A.  GENERATED name.
UiListA_Class32:
	.long 0xFFFFFFFF                            ; F87A4A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x33], the LE32 at 0xF8774D, holds 0xF87A4E.  GENERATED name.
UiListA_Class33:
	.long 0xFFFFFFFF                            ; F87A4E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x34], the LE32 at 0xF87751, holds 0xF87A52.  GENERATED name.
UiListA_Class34:
	.long 0xFFFFFFFF                            ; F87A52  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x35], the LE32 at 0xF87755, holds 0xF87A56.  GENERATED name.
UiListA_Class35:
	.long 0xFFFFFFFF                            ; F87A56  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x36], the LE32 at 0xF87759, holds 0xF87A5A.  GENERATED name.
UiListA_Class36:
	.long 0xFFFFFFFF                            ; F87A5A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x37], the LE32 at 0xF8775D, holds 0xF87A5E.  GENERATED name.
UiListA_Class37:
	.long 0xFFFFFFFF                            ; F87A5E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x38], the LE32 at 0xF87761, holds 0xF87A62.  GENERATED name.
UiListA_Class38:
	.long 0xFFFFFFFF                            ; F87A62  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x39], the LE32 at 0xF87765, holds 0xF87A66.  GENERATED name.
UiListA_Class39:
	.long 0xFFFFFFFF                            ; F87A66  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x3A], the LE32 at 0xF87769, holds 0xF87A6A.  GENERATED name.
UiListA_Class3A:
	.long 0xFFFFFFFF                            ; F87A6A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x3B], the LE32 at 0xF8776D, holds 0xF87A6E.  GENERATED name.
UiListA_Class3B:
	.long 0xFFFFFFFF                            ; F87A6E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x3C], the LE32 at 0xF87771, holds 0xF87A72.  GENERATED name.
UiListA_Class3C:
	.long 0xFFFFFFFF                            ; F87A72  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x3D], the LE32 at 0xF87775, holds 0xF87A76.  GENERATED name.
UiListA_Class3D:
	.long 0xFFFFFFFF                            ; F87A76  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x3E], the LE32 at 0xF87779, holds 0xF87A7A.  GENERATED name.
UiListA_Class3E:
	.long 0xFFFFFFFF                            ; F87A7A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x3F], the LE32 at 0xF8777D, holds 0xF87A7E.  GENERATED name.
UiListA_Class3F:
	.long 0xFFFFFFFF                            ; F87A7E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x40], the LE32 at 0xF87781, holds 0xF87A82.  GENERATED name.
UiListA_Class40:
	.long 0xFFFFFFFF                            ; F87A82  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x41], the LE32 at 0xF87785, holds 0xF87A86.  GENERATED name.
UiListA_Class41:
	.long 0xFFFFFFFF                            ; F87A86  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x42], the LE32 at 0xF87789, holds 0xF87A8A.  GENERATED name.
UiListA_Class42:
	.long 0xFFFFFFFF                            ; F87A8A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x48], the LE32 at 0xF877A1, holds 0xF87A8E.  GENERATED name.
UiListA_Class48:
	.long 0xFFFFFFFF                            ; F87A8E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x50], the LE32 at 0xF877C1, holds 0xF87A92.  GENERATED name.
UiListA_Class50:
	.long 0xFFFFFFFF                            ; F87A92  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x51], the LE32 at 0xF877C5, holds 0xF87A96.  GENERATED name.
UiListA_Class51:
	.long 0xFFFFFFFF                            ; F87A96  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x52], the LE32 at 0xF877C9, holds 0xF87A9A.  GENERATED name.
UiListA_Class52:
	.long 0xFFFFFFFF                            ; F87A9A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x53], the LE32 at 0xF877CD, holds 0xF87A9E.  GENERATED name.
UiListA_Class53:
	.long 0xFFFFFFFF                            ; F87A9E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x54], the LE32 at 0xF877D1, holds 0xF87AA2.  GENERATED name.
UiListA_Class54:
	.long 0xFFFFFFFF                            ; F87AA2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x60], the LE32 at 0xF87801, holds 0xF87AA6.  GENERATED name.
UiListA_Class60:
	.long 0xFFFFFFFF                            ; F87AA6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x61], the LE32 at 0xF87805, holds 0xF87AAA.  GENERATED name.
UiListA_Class61:
	.long 0xFFFFFFFF                            ; F87AAA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x62], the LE32 at 0xF87809, holds 0xF87AAE.  GENERATED name.
UiListA_Class62:
	.long 0xFFFFFFFF                            ; F87AAE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x63], the LE32 at 0xF8780D, holds 0xF87AB2.  GENERATED name.
UiListA_Class63:
	.long 0xFFFFFFFF                            ; F87AB2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x64], the LE32 at 0xF87811, holds 0xF87AB6.  GENERATED name.
UiListA_Class64:
	.long 0xFFFFFFFF                            ; F87AB6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x65], the LE32 at 0xF87815, holds 0xF87ABA.  GENERATED name.
UiListA_Class65:
	.long 0xFFFFFFFF                            ; F87ABA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x66], the LE32 at 0xF87819, holds 0xF87ABE.  GENERATED name.
UiListA_Class66:
	.long 0xFFFFFFFF                            ; F87ABE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x68], the LE32 at 0xF87821, holds 0xF87AC2.  GENERATED name.
UiListA_Class68:
	.long 0xFFFFFFFF                            ; F87AC2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x69], the LE32 at 0xF87825, holds 0xF87AC6.  GENERATED name.
UiListA_Class69:
	.long 0xFFFFFFFF                            ; F87AC6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x6A], the LE32 at 0xF87829, holds 0xF87ACA.  GENERATED name.
UiListA_Class6A:
	.long 0xFFFFFFFF                            ; F87ACA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x6B], the LE32 at 0xF8782D, holds 0xF87ACE.  GENERATED name.
UiListA_Class6B:
	.long 0xFFFFFFFF                            ; F87ACE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x6C], the LE32 at 0xF87831, holds 0xF87AD2.  GENERATED name.
UiListA_Class6C:
	.long 0xFFFFFFFF                            ; F87AD2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x6D], the LE32 at 0xF87835, holds 0xF87AD6.  GENERATED name.
UiListA_Class6D:
	.long 0xFFFFFFFF                            ; F87AD6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x6E], the LE32 at 0xF87839, holds 0xF87ADA.  GENERATED name.
UiListA_Class6E:
	.long 0xFFFFFFFF                            ; F87ADA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x70], the LE32 at 0xF87841, holds 0xF87ADE.  GENERATED name.
UiListA_Class70:
	.long 0xFFFFFFFF                            ; F87ADE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x71], the LE32 at 0xF87845, holds 0xF87AE2.  GENERATED name.
UiListA_Class71:
	.long 0xFFFFFFFF                            ; F87AE2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x72], the LE32 at 0xF87849, holds 0xF87AE6.  GENERATED name.
UiListA_Class72:
	.long 0xFFFFFFFF                            ; F87AE6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x78], the LE32 at 0xF87861, holds 0xF87AEA.  GENERATED name.
UiListA_Class78:
	.long 0xFFFFFFFF                            ; F87AEA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x79], the LE32 at 0xF87865, holds 0xF87AEE.  GENERATED name.
UiListA_Class79:
	.long 0xFFFFFFFF                            ; F87AEE  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x7A], the LE32 at 0xF87869, holds 0xF87AF2.  GENERATED name.
UiListA_Class7A:
	.long 0xFFFFFFFF                            ; F87AF2  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x80], the LE32 at 0xF87881, holds 0xF87AF6.  GENERATED name.
UiListA_Class80:
	.long 0xFFFFFFFF                            ; F87AF6  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x81], the LE32 at 0xF87885, holds 0xF87AFA.  GENERATED name.
UiListA_Class81:
	.long 0xFFFFFFFF                            ; F87AFA  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x90], the LE32 at 0xF878C1, holds 0xF87AFE.  GENERATED name.
UiListA_Class90:
	.long 0xFFFFFFFF                            ; F87AFE  [0]   end of list

; ---------------------------------------------------------------------
; UiListA_Class91 -- 1 handler(s) for event class 0x91 in pass A
;
; Entries: 0xF408F0, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_A[0x91].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_A[0x91], the LE32 at 0xF878C5,
;          holds 0xF87B02.  The list ENDS at 0xF87B0A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListA_Class91:
	.long T_GmMode_HandleChange                              ; F87B02  [0]   -> 0xF408F0
	.long 0xFFFFFFFF                            ; F87B06  [1]   end of list
; Evidence: UiEventClass_ListTable_A[0x92], the LE32 at 0xF878C9, holds 0xF87B0A.  GENERATED name.
UiListA_Class92:
	.long 0xFFFFFFFF                            ; F87B0A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x93], the LE32 at 0xF878CD, holds 0xF87B0E.  GENERATED name.
UiListA_Class93:
	.long 0xFFFFFFFF                            ; F87B0E  [0]   end of list

; ---------------------------------------------------------------------
; UiListA_Class98 -- 1 handler(s) for event class 0x98 in pass A
;
; Entries: 0xF40244, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_A[0x98].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_A[0x98], the LE32 at 0xF878E1,
;          holds 0xF87B12.  The list ENDS at 0xF87B1A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListA_Class98:
	.long T_Combination_RecallOnSelect                              ; F87B12  [0]   -> 0xF40244
	.long 0xFFFFFFFF                            ; F87B16  [1]   end of list
; Evidence: UiEventClass_ListTable_A[0x99], the LE32 at 0xF878E5, holds 0xF87B1A.  GENERATED name.
UiListA_Class99:
	.long 0xFFFFFFFF                            ; F87B1A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0x9A], the LE32 at 0xF878E9, holds 0xF87B1E.  GENERATED name.
UiListA_Class9A:
	.long 0xFFFFFFFF                            ; F87B1E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xA8], the LE32 at 0xF87921, holds 0xF87B22.  GENERATED name.
UiListA_ClassA8:
	.long 0xFFFFFFFF                            ; F87B22  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xA9], the LE32 at 0xF87925, holds 0xF87B26.  GENERATED name.
UiListA_ClassA9:
	.long 0xFFFFFFFF                            ; F87B26  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xAC], the LE32 at 0xF87931, holds 0xF87B2A.  GENERATED name.
UiListA_ClassAC:
	.long 0xFFFFFFFF                            ; F87B2A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xAD], the LE32 at 0xF87935, holds 0xF87B2E.  GENERATED name.
UiListA_ClassAD:
	.long 0xFFFFFFFF                            ; F87B2E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xAE], the LE32 at 0xF87939, holds 0xF87B32.  GENERATED name.
UiListA_ClassAE:
	.long 0xFFFFFFFF                            ; F87B32  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB0], the LE32 at 0xF87941, holds 0xF87B36.  GENERATED name.
UiListA_ClassB0:
	.long 0xFFFFFFFF                            ; F87B36  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB1], the LE32 at 0xF87945, holds 0xF87B3A.  GENERATED name.
UiListA_ClassB1:
	.long 0xFFFFFFFF                            ; F87B3A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB2], the LE32 at 0xF87949, holds 0xF87B3E.  GENERATED name.
UiListA_ClassB2:
	.long 0xFFFFFFFF                            ; F87B3E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB3], the LE32 at 0xF8794D, holds 0xF87B42.  GENERATED name.
UiListA_ClassB3:
	.long 0xFFFFFFFF                            ; F87B42  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB4], the LE32 at 0xF87951, holds 0xF87B46.  GENERATED name.
UiListA_ClassB4:
	.long 0xFFFFFFFF                            ; F87B46  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB5], the LE32 at 0xF87955, holds 0xF87B4A.  GENERATED name.
UiListA_ClassB5:
	.long 0xFFFFFFFF                            ; F87B4A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB6], the LE32 at 0xF87959, holds 0xF87B4E.  GENERATED name.
UiListA_ClassB6:
	.long 0xFFFFFFFF                            ; F87B4E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB7], the LE32 at 0xF8795D, holds 0xF87B52.  GENERATED name.
UiListA_ClassB7:
	.long 0xFFFFFFFF                            ; F87B52  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB8], the LE32 at 0xF87961, holds 0xF87B56.  GENERATED name.
UiListA_ClassB8:
	.long 0xFFFFFFFF                            ; F87B56  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xB9], the LE32 at 0xF87965, holds 0xF87B5A.  GENERATED name.
UiListA_ClassB9:
	.long 0xFFFFFFFF                            ; F87B5A  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xBA], the LE32 at 0xF87969, holds 0xF87B5E.  GENERATED name.
UiListA_ClassBA:
	.long 0xFFFFFFFF                            ; F87B5E  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xBB], the LE32 at 0xF8796D, holds 0xF87B62.  GENERATED name.
UiListA_ClassBB:
	.long 0xFFFFFFFF                            ; F87B62  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xBC], the LE32 at 0xF87971, holds 0xF87B66.  GENERATED name.
UiListA_ClassBC:
	.long 0xFFFFFFFF                            ; F87B66  [0]   end of list
; Evidence: UiEventClass_ListTable_A[0xBD], the LE32 at 0xF87975, holds 0xF87B6A.  GENERATED name.
UiListA_ClassBD:
	.long 0xFFFFFFFF                            ; F87B6A  [0]   end of list

; ---------------------------------------------------------------------
; UiListA_Shared -- the empty list 71 class ids share
;
; Classes: every id NOT in the 121-member set the three tables agree
;          on.  Generated from the table, not typed:
;          0x43-0x47, 0x49-0x4F, 0x55-0x5F, 0x67, 0x6F, 0x73-0x77,
;          0x7B-0x7F, 0x82-0x8F, 0x94-0x97, 0x9B-0xA7, 0xAA-0xAB, 0xAF,
;          0xBE-0xBF
;          Check L2 asserts the set is the same in all three tables.
; Position: it is the LAST object in the area, and its 4 bytes are what
;          make the tiling reach 0xF87B72 exactly.
; Evidence: 71 of the 192 LE32 entries of UiEventClass_ListTable_A hold
;          0xF87B6E, and the word there is the 0xFFFFFFFF terminator.
; ---------------------------------------------------------------------
UiListA_Shared:
	.long 0xFFFFFFFF                            ; F87B6E  [0]   end of list

; --- 0xF87B72-0xF87E80  0x00 pad (783 bytes) ---
	.fill 783, 1, 0x00

; --- 0xF87E81-0xF87E84  0xFFFFFFFF-terminated list (4 bytes) ---

; ---------------------------------------------------------------------
; UiEventPassA_TailList -- LE32 routines run once, after the whole list
;
; Read by: ONE site, `ld XIY,0x00F87E81 / ld (0x20C4),XIY` at UiEventList_RunPassA 0xF8697E.
;          UiEventList_Run walks it at 0xF86A6A-0xF86A7E after the
;          record loop, calling every entry until a word 0xFFFF.
; Entries: none (0), then the 0xFFFF terminator.
; ENTRY COUNT: the terminator IS the count; the bytes after it are the
;          0x00 pad that runs to the next object.
; Evidence: `ld XIY,0x00F87E81` at 0xF86987, four bytes before `ld (0x20C4),XIY`;
;          UiEventList_Run reads (0x20C4) at 0xF86A6A and stops on
;          `cp (XIX),0xffff`.
; ---------------------------------------------------------------------
UiEventPassA_TailList:
	.long 0xFFFFFFFF                            ; F87E81  [0]   end of list

; --- 0xF87E85-0xF87E90  0x00 pad (12 bytes) ---
	.fill 12, 1, 0x00

; --- 0xF87E91-0xF88190  pointer table (768 bytes) ---

; ---------------------------------------------------------------------
; UiEventClass_ListTable_B -- 192 LE32 heads, indexed by the event class
;
; Read by: ONE site, `ld XIY,0x00F87E91 / ld (0x20C0),XIY` at UiEventList_RunPassB 0xF8699D;
;          UiEventList_Run indexes it with the record's byte +0.
; ENTRY COUNT 192, pinned twice: `cp L,0xbf` at 0xF869FB rejects a class
;          above 191, and the 0x300-byte extent is 192 * 4.  The table
;          ends one pad byte before its own list area.
; ★ 121 class ids have their own list and the other 71 share the area's
;          trailing empty list -- and the SAME 121 ids do so in all
;          THREE tables (check L2).  The distinct heads tile the list
;          area exactly, in ascending order, with no byte left over
;          (check L3).
; Evidence: `ld XIY,0x00F87E91` at 0xF8699D, four bytes before `ld (0x20C0),XIY`;
;          UiEventList_Run reads (0x20C0) at 0xF869EF and indexes it
;          with `sla 0x02,HL` at 0xF86A00.
; ---------------------------------------------------------------------
UiEventClass_ListTable_B:
	.long UiListB_Class00                       ; F87E91  [0]   -> UiListB_Class00
	.long UiListB_Class01                       ; F87E95  [1]   -> UiListB_Class01
	.long UiListB_Class02                       ; F87E99  [2]   -> UiListB_Class02
	.long UiListB_Class03                       ; F87E9D  [3]   -> UiListB_Class03
	.long UiListB_Class04                       ; F87EA1  [4]   -> UiListB_Class04
	.long UiListB_Class05                       ; F87EA5  [5]   -> UiListB_Class05
	.long UiListB_Class06                       ; F87EA9  [6]   -> UiListB_Class06
	.long UiListB_Class07                       ; F87EAD  [7]   -> UiListB_Class07
	.long UiListB_Class08                       ; F87EB1  [8]   -> UiListB_Class08
	.long UiListB_Class09                       ; F87EB5  [9]   -> UiListB_Class09
	.long UiListB_Class0A                       ; F87EB9  [10]   -> UiListB_Class0A
	.long UiListB_Class0B                       ; F87EBD  [11]   -> UiListB_Class0B
	.long UiListB_Class0C                       ; F87EC1  [12]   -> UiListB_Class0C
	.long UiListB_Class0D                       ; F87EC5  [13]   -> UiListB_Class0D
	.long UiListB_Class0E                       ; F87EC9  [14]   -> UiListB_Class0E
	.long UiListB_Class0F                       ; F87ECD  [15]   -> UiListB_Class0F
	.long UiListB_Class10                       ; F87ED1  [16]   -> UiListB_Class10
	.long UiListB_Class11                       ; F87ED5  [17]   -> UiListB_Class11
	.long UiListB_Class12                       ; F87ED9  [18]   -> UiListB_Class12
	.long UiListB_Class13                       ; F87EDD  [19]   -> UiListB_Class13
	.long UiListB_Class14                       ; F87EE1  [20]   -> UiListB_Class14
	.long UiListB_Class15                       ; F87EE5  [21]   -> UiListB_Class15
	.long UiListB_Class16                       ; F87EE9  [22]   -> UiListB_Class16
	.long UiListB_Class17                       ; F87EED  [23]   -> UiListB_Class17
	.long UiListB_Class18                       ; F87EF1  [24]   -> UiListB_Class18
	.long UiListB_Class19                       ; F87EF5  [25]   -> UiListB_Class19
	.long UiListB_Class1A                       ; F87EF9  [26]   -> UiListB_Class1A
	.long UiListB_Class1B                       ; F87EFD  [27]   -> UiListB_Class1B
	.long UiListB_Class1C                       ; F87F01  [28]   -> UiListB_Class1C
	.long UiListB_Class1D                       ; F87F05  [29]   -> UiListB_Class1D
	.long UiListB_Class1E                       ; F87F09  [30]   -> UiListB_Class1E
	.long UiListB_Class1F                       ; F87F0D  [31]   -> UiListB_Class1F
	.long UiListB_Class20                       ; F87F11  [32]   -> UiListB_Class20
	.long UiListB_Class21                       ; F87F15  [33]   -> UiListB_Class21
	.long UiListB_Class22                       ; F87F19  [34]   -> UiListB_Class22
	.long UiListB_Class23                       ; F87F1D  [35]   -> UiListB_Class23
	.long UiListB_Class24                       ; F87F21  [36]   -> UiListB_Class24
	.long UiListB_Class25                       ; F87F25  [37]   -> UiListB_Class25
	.long UiListB_Class26                       ; F87F29  [38]   -> UiListB_Class26
	.long UiListB_Class27                       ; F87F2D  [39]   -> UiListB_Class27
	.long UiListB_Class28                       ; F87F31  [40]   -> UiListB_Class28
	.long UiListB_Class29                       ; F87F35  [41]   -> UiListB_Class29
	.long UiListB_Class2A                       ; F87F39  [42]   -> UiListB_Class2A
	.long UiListB_Class2B                       ; F87F3D  [43]   -> UiListB_Class2B
	.long UiListB_Class2C                       ; F87F41  [44]   -> UiListB_Class2C
	.long UiListB_Class2D                       ; F87F45  [45]   -> UiListB_Class2D
	.long UiListB_Class2E                       ; F87F49  [46]   -> UiListB_Class2E
	.long UiListB_Class2F                       ; F87F4D  [47]   -> UiListB_Class2F
	.long UiListB_Class30                       ; F87F51  [48]   -> UiListB_Class30
	.long UiListB_Class31                       ; F87F55  [49]   -> UiListB_Class31
	.long UiListB_Class32                       ; F87F59  [50]   -> UiListB_Class32
	.long UiListB_Class33                       ; F87F5D  [51]   -> UiListB_Class33
	.long UiListB_Class34                       ; F87F61  [52]   -> UiListB_Class34
	.long UiListB_Class35                       ; F87F65  [53]   -> UiListB_Class35
	.long UiListB_Class36                       ; F87F69  [54]   -> UiListB_Class36
	.long UiListB_Class37                       ; F87F6D  [55]   -> UiListB_Class37
	.long UiListB_Class38                       ; F87F71  [56]   -> UiListB_Class38
	.long UiListB_Class39                       ; F87F75  [57]   -> UiListB_Class39
	.long UiListB_Class3A                       ; F87F79  [58]   -> UiListB_Class3A
	.long UiListB_Class3B                       ; F87F7D  [59]   -> UiListB_Class3B
	.long UiListB_Class3C                       ; F87F81  [60]   -> UiListB_Class3C
	.long UiListB_Class3D                       ; F87F85  [61]   -> UiListB_Class3D
	.long UiListB_Class3E                       ; F87F89  [62]   -> UiListB_Class3E
	.long UiListB_Class3F                       ; F87F8D  [63]   -> UiListB_Class3F
	.long UiListB_Class40                       ; F87F91  [64]   -> UiListB_Class40
	.long UiListB_Class41                       ; F87F95  [65]   -> UiListB_Class41
	.long UiListB_Class42                       ; F87F99  [66]   -> UiListB_Class42
	.long UiListB_Shared                        ; F87F9D  [67]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FA1  [68]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FA5  [69]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FA9  [70]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FAD  [71]   -> UiListB_Shared
	.long UiListB_Class48                       ; F87FB1  [72]   -> UiListB_Class48
	.long UiListB_Shared                        ; F87FB5  [73]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FB9  [74]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FBD  [75]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FC1  [76]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FC5  [77]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FC9  [78]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FCD  [79]   -> UiListB_Shared
	.long UiListB_Class50                       ; F87FD1  [80]   -> UiListB_Class50
	.long UiListB_Class51                       ; F87FD5  [81]   -> UiListB_Class51
	.long UiListB_Class52                       ; F87FD9  [82]   -> UiListB_Class52
	.long UiListB_Class53                       ; F87FDD  [83]   -> UiListB_Class53
	.long UiListB_Class54                       ; F87FE1  [84]   -> UiListB_Class54
	.long UiListB_Shared                        ; F87FE5  [85]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FE9  [86]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FED  [87]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FF1  [88]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FF5  [89]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FF9  [90]   -> UiListB_Shared
	.long UiListB_Shared                        ; F87FFD  [91]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88001  [92]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88005  [93]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88009  [94]   -> UiListB_Shared
	.long UiListB_Shared                        ; F8800D  [95]   -> UiListB_Shared
	.long UiListB_Class60                       ; F88011  [96]   -> UiListB_Class60
	.long UiListB_Class61                       ; F88015  [97]   -> UiListB_Class61
	.long UiListB_Class62                       ; F88019  [98]   -> UiListB_Class62
	.long UiListB_Class63                       ; F8801D  [99]   -> UiListB_Class63
	.long UiListB_Class64                       ; F88021  [100]   -> UiListB_Class64
	.long UiListB_Class65                       ; F88025  [101]   -> UiListB_Class65
	.long UiListB_Class66                       ; F88029  [102]   -> UiListB_Class66
	.long UiListB_Shared                        ; F8802D  [103]   -> UiListB_Shared
	.long UiListB_Class68                       ; F88031  [104]   -> UiListB_Class68
	.long UiListB_Class69                       ; F88035  [105]   -> UiListB_Class69
	.long UiListB_Class6A                       ; F88039  [106]   -> UiListB_Class6A
	.long UiListB_Class6B                       ; F8803D  [107]   -> UiListB_Class6B
	.long UiListB_Class6C                       ; F88041  [108]   -> UiListB_Class6C
	.long UiListB_Class6D                       ; F88045  [109]   -> UiListB_Class6D
	.long UiListB_Class6E                       ; F88049  [110]   -> UiListB_Class6E
	.long UiListB_Shared                        ; F8804D  [111]   -> UiListB_Shared
	.long UiListB_Class70                       ; F88051  [112]   -> UiListB_Class70
	.long UiListB_Class71                       ; F88055  [113]   -> UiListB_Class71
	.long UiListB_Class72                       ; F88059  [114]   -> UiListB_Class72
	.long UiListB_Shared                        ; F8805D  [115]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88061  [116]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88065  [117]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88069  [118]   -> UiListB_Shared
	.long UiListB_Shared                        ; F8806D  [119]   -> UiListB_Shared
	.long UiListB_Class78                       ; F88071  [120]   -> UiListB_Class78
	.long UiListB_Class79                       ; F88075  [121]   -> UiListB_Class79
	.long UiListB_Class7A                       ; F88079  [122]   -> UiListB_Class7A
	.long UiListB_Shared                        ; F8807D  [123]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88081  [124]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88085  [125]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88089  [126]   -> UiListB_Shared
	.long UiListB_Shared                        ; F8808D  [127]   -> UiListB_Shared
	.long UiListB_Class80                       ; F88091  [128]   -> UiListB_Class80
	.long UiListB_Class81                       ; F88095  [129]   -> UiListB_Class81
	.long UiListB_Shared                        ; F88099  [130]   -> UiListB_Shared
	.long UiListB_Shared                        ; F8809D  [131]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880A1  [132]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880A5  [133]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880A9  [134]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880AD  [135]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880B1  [136]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880B5  [137]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880B9  [138]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880BD  [139]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880C1  [140]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880C5  [141]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880C9  [142]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880CD  [143]   -> UiListB_Shared
	.long UiListB_Class90                       ; F880D1  [144]   -> UiListB_Class90
	.long UiListB_Class91                       ; F880D5  [145]   -> UiListB_Class91
	.long UiListB_Class92                       ; F880D9  [146]   -> UiListB_Class92
	.long UiListB_Class93                       ; F880DD  [147]   -> UiListB_Class93
	.long UiListB_Shared                        ; F880E1  [148]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880E5  [149]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880E9  [150]   -> UiListB_Shared
	.long UiListB_Shared                        ; F880ED  [151]   -> UiListB_Shared
	.long UiListB_Class98                       ; F880F1  [152]   -> UiListB_Class98
	.long UiListB_Class99                       ; F880F5  [153]   -> UiListB_Class99
	.long UiListB_Class9A                       ; F880F9  [154]   -> UiListB_Class9A
	.long UiListB_Shared                        ; F880FD  [155]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88101  [156]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88105  [157]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88109  [158]   -> UiListB_Shared
	.long UiListB_Shared                        ; F8810D  [159]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88111  [160]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88115  [161]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88119  [162]   -> UiListB_Shared
	.long UiListB_Shared                        ; F8811D  [163]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88121  [164]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88125  [165]   -> UiListB_Shared
	.long UiListB_Shared                        ; F88129  [166]   -> UiListB_Shared
	.long UiListB_Shared                        ; F8812D  [167]   -> UiListB_Shared
	.long UiListB_ClassA8                       ; F88131  [168]   -> UiListB_ClassA8
	.long UiListB_ClassA9                       ; F88135  [169]   -> UiListB_ClassA9
	.long UiListB_Shared                        ; F88139  [170]   -> UiListB_Shared
	.long UiListB_Shared                        ; F8813D  [171]   -> UiListB_Shared
	.long UiListB_ClassAC                       ; F88141  [172]   -> UiListB_ClassAC
	.long UiListB_ClassAD                       ; F88145  [173]   -> UiListB_ClassAD
	.long UiListB_ClassAE                       ; F88149  [174]   -> UiListB_ClassAE
	.long UiListB_Shared                        ; F8814D  [175]   -> UiListB_Shared
	.long UiListB_ClassB0                       ; F88151  [176]   -> UiListB_ClassB0
	.long UiListB_ClassB1                       ; F88155  [177]   -> UiListB_ClassB1
	.long UiListB_ClassB2                       ; F88159  [178]   -> UiListB_ClassB2
	.long UiListB_ClassB3                       ; F8815D  [179]   -> UiListB_ClassB3
	.long UiListB_ClassB4                       ; F88161  [180]   -> UiListB_ClassB4
	.long UiListB_ClassB5                       ; F88165  [181]   -> UiListB_ClassB5
	.long UiListB_ClassB6                       ; F88169  [182]   -> UiListB_ClassB6
	.long UiListB_ClassB7                       ; F8816D  [183]   -> UiListB_ClassB7
	.long UiListB_ClassB8                       ; F88171  [184]   -> UiListB_ClassB8
	.long UiListB_ClassB9                       ; F88175  [185]   -> UiListB_ClassB9
	.long UiListB_ClassBA                       ; F88179  [186]   -> UiListB_ClassBA
	.long UiListB_ClassBB                       ; F8817D  [187]   -> UiListB_ClassBB
	.long UiListB_ClassBC                       ; F88181  [188]   -> UiListB_ClassBC
	.long UiListB_ClassBD                       ; F88185  [189]   -> UiListB_ClassBD
	.long UiListB_Shared                        ; F88189  [190]   -> UiListB_Shared
	.long UiListB_Shared                        ; F8818D  [191]   -> UiListB_Shared

; --- 0xF88191-0xF88191  pad (1 bytes) ---
	.byte 0xff   ; F88191

; --- 0xF88192-0xF88D09  handler lists (2936 bytes) ---
; ---------------------------------------------------------------------
; UiEventLists_B -- the 122 handler lists of pass B, tiling 0xF88192-0xF88D09
;
; Each list is LE32 routine addresses terminated by 0xFFFFFFFF.  7 of
; the 122 are EMPTY (the terminator and nothing else); 115 carry handlers.
; ⚠ The labels below are GENERATED: each is named after the LOWEST class
; id whose UiEventClass_ListTable_B entry points at it, and says nothing
; about what the list DOES.  UiListB_Shared is the empty list the 71
; classes without their own head share.
; Evidence: the heads are the table's own values -- nothing here is
;          framed by content.  They tile the area with no gap and no
;          overlap, every one ends in 0xFFFFFFFF, and the last one ends
;          exactly at the area's end (checks L3, L5).
; ---------------------------------------------------------------------

; ---------------------------------------------------------------------
; UiListB_Class00 -- 10 handler(s) for event class 0x00 in pass B
;
; Entries: 0xF41070, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF42E54, 0xF40810, 0xF42F54, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x00].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x00], the LE32 at 0xF87E91,
;          holds 0xF88192.  The list ENDS at 0xF881BE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class00:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_Msg0716_HandlerTables_13                              ; F88192  [0]   -> 0xF41070
	.long T_UiEvent_SyncSoundSelection                              ; F88196  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8819A  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8819E  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F881A2  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F881A6  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F881AA  [6]   -> 0xF411C0
	.long T_Drawbar_MarkReloadOnSoundEvent                              ; F881AE  [7]   -> 0xF42E54
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F881B2  [8]   -> 0xF40810
	.long T_DspEffect_OnParamEvent                              ; F881B6  [9]   -> 0xF42F54
	.long 0xFFFFFFFF                            ; F881BA  [10]   end of list

; ---------------------------------------------------------------------
; UiListB_Class01 -- 8 handler(s) for event class 0x01 in pass B
;
; Entries: 0xF41074, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x01].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x01], the LE32 at 0xF87E95,
;          holds 0xF881BE.  The list ENDS at 0xF881E2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class01:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_8_Msg0716_HandlerTables_13                              ; F881BE  [0]   -> 0xF41074
	.long T_UiEvent_SyncSoundSelection                              ; F881C2  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F881C6  [2]   -> 0xF4067C
	.long T_F415B0                              ; F881CA  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F881CE  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F881D2  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F881D6  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F881DA  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F881DE  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class02 -- 8 handler(s) for event class 0x02 in pass B
;
; Entries: 0xF41078, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x02].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x02], the LE32 at 0xF87E99,
;          holds 0xF881E2.  The list ENDS at 0xF88206 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class02:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_16_Msg0716_HandlerTables_13                              ; F881E2  [0]   -> 0xF41078
	.long T_UiEvent_SyncSoundSelection                              ; F881E6  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F881EA  [2]   -> 0xF4067C
	.long T_F415B0                              ; F881EE  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F881F2  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F881F6  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F881FA  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F881FE  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88202  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class03 -- 8 handler(s) for event class 0x03 in pass B
;
; Entries: 0xF4107C, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x03].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x03], the LE32 at 0xF87E9D,
;          holds 0xF88206.  The list ENDS at 0xF8822A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class03:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_24_Msg0716_HandlerTables_13                              ; F88206  [0]   -> 0xF4107C
	.long T_UiEvent_SyncSoundSelection                              ; F8820A  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8820E  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88212  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F88216  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8821A  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F8821E  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88222  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88226  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class04 -- 8 handler(s) for event class 0x04 in pass B
;
; Entries: 0xF41080, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x04].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x04], the LE32 at 0xF87EA1,
;          holds 0xF8822A.  The list ENDS at 0xF8824E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class04:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_32_Msg0716_HandlerTables_13                              ; F8822A  [0]   -> 0xF41080
	.long T_UiEvent_SyncSoundSelection                              ; F8822E  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88232  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88236  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8823A  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8823E  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F88242  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88246  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F8824A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class05 -- 8 handler(s) for event class 0x05 in pass B
;
; Entries: 0xF41084, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x05].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x05], the LE32 at 0xF87EA5,
;          holds 0xF8824E.  The list ENDS at 0xF88272 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class05:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_40_Msg0716_HandlerTables_13                              ; F8824E  [0]   -> 0xF41084
	.long T_UiEvent_SyncSoundSelection                              ; F88252  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88256  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8825A  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8825E  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F88262  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F88266  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8826A  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F8826E  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class06 -- 8 handler(s) for event class 0x06 in pass B
;
; Entries: 0xF41088, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x06].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x06], the LE32 at 0xF87EA9,
;          holds 0xF88272.  The list ENDS at 0xF88296 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class06:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_48_Msg0716_HandlerTables_13                              ; F88272  [0]   -> 0xF41088
	.long T_UiEvent_SyncSoundSelection                              ; F88276  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8827A  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8827E  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F88282  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F88286  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F8828A  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8828E  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88292  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class07 -- 8 handler(s) for event class 0x07 in pass B
;
; Entries: 0xF4108C, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x07].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x07], the LE32 at 0xF87EAD,
;          holds 0xF88296.  The list ENDS at 0xF882BA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class07:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_56_Msg0716_HandlerTables_13                              ; F88296  [0]   -> 0xF4108C
	.long T_UiEvent_SyncSoundSelection                              ; F8829A  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8829E  [2]   -> 0xF4067C
	.long T_F415B0                              ; F882A2  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F882A6  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F882AA  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F882AE  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F882B2  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F882B6  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class08 -- 8 handler(s) for event class 0x08 in pass B
;
; Entries: 0xF41090, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x08].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x08], the LE32 at 0xF87EB1,
;          holds 0xF882BA.  The list ENDS at 0xF882DE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class08:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_64_Msg0716_HandlerTables_13                              ; F882BA  [0]   -> 0xF41090
	.long T_UiEvent_SyncSoundSelection                              ; F882BE  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F882C2  [2]   -> 0xF4067C
	.long T_F415B0                              ; F882C6  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F882CA  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F882CE  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F882D2  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F882D6  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F882DA  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class09 -- 8 handler(s) for event class 0x09 in pass B
;
; Entries: 0xF41094, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x09].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x09], the LE32 at 0xF87EB5,
;          holds 0xF882DE.  The list ENDS at 0xF88302 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class09:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_72_Msg0716_HandlerTables_13                              ; F882DE  [0]   -> 0xF41094
	.long T_UiEvent_SyncSoundSelection                              ; F882E2  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F882E6  [2]   -> 0xF4067C
	.long T_F415B0                              ; F882EA  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F882EE  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F882F2  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F882F6  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F882FA  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F882FE  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class0A -- 8 handler(s) for event class 0x0A in pass B
;
; Entries: 0xF41098, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x0A].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x0A], the LE32 at 0xF87EB9,
;          holds 0xF88302.  The list ENDS at 0xF88326 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class0A:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_80_Msg0716_HandlerTables_13                              ; F88302  [0]   -> 0xF41098
	.long T_UiEvent_SyncSoundSelection                              ; F88306  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8830A  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8830E  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F88312  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F88316  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F8831A  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8831E  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88322  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class0B -- 8 handler(s) for event class 0x0B in pass B
;
; Entries: 0xF4109C, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x0B].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x0B], the LE32 at 0xF87EBD,
;          holds 0xF88326.  The list ENDS at 0xF8834A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class0B:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_88_Msg0716_HandlerTables_13                              ; F88326  [0]   -> 0xF4109C
	.long T_UiEvent_SyncSoundSelection                              ; F8832A  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8832E  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88332  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F88336  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8833A  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F8833E  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88342  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88346  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class0C -- 8 handler(s) for event class 0x0C in pass B
;
; Entries: 0xF410A0, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x0C].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x0C], the LE32 at 0xF87EC1,
;          holds 0xF8834A.  The list ENDS at 0xF8836E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class0C:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_96_Msg0716_HandlerTables_13                              ; F8834A  [0]   -> 0xF410A0
	.long T_UiEvent_SyncSoundSelection                              ; F8834E  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88352  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88356  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8835A  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8835E  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F88362  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88366  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F8836A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class0D -- 8 handler(s) for event class 0x0D in pass B
;
; Entries: 0xF410A4, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x0D].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x0D], the LE32 at 0xF87EC5,
;          holds 0xF8836E.  The list ENDS at 0xF88392 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class0D:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_104_Msg0716_HandlerTables_13                              ; F8836E  [0]   -> 0xF410A4
	.long T_UiEvent_SyncSoundSelection                              ; F88372  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88376  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8837A  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8837E  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F88382  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F88386  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8838A  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F8838E  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class0E -- 8 handler(s) for event class 0x0E in pass B
;
; Entries: 0xF410A8, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x0E].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x0E], the LE32 at 0xF87EC9,
;          holds 0xF88392.  The list ENDS at 0xF883B6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class0E:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_112_Msg0716_HandlerTables_13                              ; F88392  [0]   -> 0xF410A8
	.long T_UiEvent_SyncSoundSelection                              ; F88396  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8839A  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8839E  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F883A2  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F883A6  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F883AA  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F883AE  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F883B2  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class0F -- 8 handler(s) for event class 0x0F in pass B
;
; Entries: 0xF410AC, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x0F].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x0F], the LE32 at 0xF87ECD,
;          holds 0xF883B6.  The list ENDS at 0xF883DA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class0F:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_120_Msg0716_HandlerTables_13                              ; F883B6  [0]   -> 0xF410AC
	.long T_UiEvent_SyncSoundSelection                              ; F883BA  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F883BE  [2]   -> 0xF4067C
	.long T_F415B0                              ; F883C2  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F883C6  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F883CA  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F883CE  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F883D2  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F883D6  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class10 -- 8 handler(s) for event class 0x10 in pass B
;
; Entries: 0xF410B0, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x10].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x10], the LE32 at 0xF87ED1,
;          holds 0xF883DA.  The list ENDS at 0xF883FE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class10:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_128_Msg0716_HandlerTables_13                              ; F883DA  [0]   -> 0xF410B0
	.long T_UiEvent_SyncSoundSelection                              ; F883DE  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F883E2  [2]   -> 0xF4067C
	.long T_F415B0                              ; F883E6  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F883EA  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F883EE  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F883F2  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F883F6  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F883FA  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class11 -- 8 handler(s) for event class 0x11 in pass B
;
; Entries: 0xF410B4, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x11].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x11], the LE32 at 0xF87ED5,
;          holds 0xF883FE.  The list ENDS at 0xF88422 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class11:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_136_Msg0716_HandlerTables_13                              ; F883FE  [0]   -> 0xF410B4
	.long T_UiEvent_SyncSoundSelection                              ; F88402  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88406  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8840A  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8840E  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F88412  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F88416  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8841A  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F8841E  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class12 -- 8 handler(s) for event class 0x12 in pass B
;
; Entries: 0xF410B8, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x12].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x12], the LE32 at 0xF87ED9,
;          holds 0xF88422.  The list ENDS at 0xF88446 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class12:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_144_Msg0716_HandlerTables_13                              ; F88422  [0]   -> 0xF410B8
	.long T_UiEvent_SyncSoundSelection                              ; F88426  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8842A  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8842E  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F88432  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F88436  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F8843A  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8843E  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88442  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class13 -- 8 handler(s) for event class 0x13 in pass B
;
; Entries: 0xF410BC, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x13].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x13], the LE32 at 0xF87EDD,
;          holds 0xF88446.  The list ENDS at 0xF8846A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class13:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_152_Msg0716_HandlerTables_13                              ; F88446  [0]   -> 0xF410BC
	.long T_UiEvent_SyncSoundSelection                              ; F8844A  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8844E  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88452  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F88456  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8845A  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F8845E  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88462  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88466  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class14 -- 8 handler(s) for event class 0x14 in pass B
;
; Entries: 0xF410C0, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x14].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x14], the LE32 at 0xF87EE1,
;          holds 0xF8846A.  The list ENDS at 0xF8848E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class14:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_160_Msg0716_HandlerTables_13                              ; F8846A  [0]   -> 0xF410C0
	.long T_UiEvent_SyncSoundSelection                              ; F8846E  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88472  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88476  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8847A  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8847E  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F88482  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88486  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F8848A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class15 -- 8 handler(s) for event class 0x15 in pass B
;
; Entries: 0xF410C4, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x15].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x15], the LE32 at 0xF87EE5,
;          holds 0xF8848E.  The list ENDS at 0xF884B2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class15:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_168_Msg0716_HandlerTables_13                              ; F8848E  [0]   -> 0xF410C4
	.long T_UiEvent_SyncSoundSelection                              ; F88492  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88496  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8849A  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8849E  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F884A2  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F884A6  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F884AA  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F884AE  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class16 -- 8 handler(s) for event class 0x16 in pass B
;
; Entries: 0xF410C8, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x16].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x16], the LE32 at 0xF87EE9,
;          holds 0xF884B2.  The list ENDS at 0xF884D6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class16:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_176_Msg0716_HandlerTables_13                              ; F884B2  [0]   -> 0xF410C8
	.long T_UiEvent_SyncSoundSelection                              ; F884B6  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F884BA  [2]   -> 0xF4067C
	.long T_F415B0                              ; F884BE  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F884C2  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F884C6  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F884CA  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F884CE  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F884D2  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class17 -- 8 handler(s) for event class 0x17 in pass B
;
; Entries: 0xF410CC, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x17].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x17], the LE32 at 0xF87EED,
;          holds 0xF884D6.  The list ENDS at 0xF884FA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class17:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_184_Msg0716_HandlerTables_13                              ; F884D6  [0]   -> 0xF410CC
	.long T_UiEvent_SyncSoundSelection                              ; F884DA  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F884DE  [2]   -> 0xF4067C
	.long T_F415B0                              ; F884E2  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F884E6  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F884EA  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F884EE  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F884F2  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F884F6  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class18 -- 8 handler(s) for event class 0x18 in pass B
;
; Entries: 0xF410D0, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x18].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x18], the LE32 at 0xF87EF1,
;          holds 0xF884FA.  The list ENDS at 0xF8851E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class18:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_192_Msg0716_HandlerTables_13                              ; F884FA  [0]   -> 0xF410D0
	.long T_UiEvent_SyncSoundSelection                              ; F884FE  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88502  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88506  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8850A  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8850E  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F88512  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88516  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F8851A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class19 -- 8 handler(s) for event class 0x19 in pass B
;
; Entries: 0xF410D4, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x19].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x19], the LE32 at 0xF87EF5,
;          holds 0xF8851E.  The list ENDS at 0xF88542 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class19:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_200_Msg0716_HandlerTables_13                              ; F8851E  [0]   -> 0xF410D4
	.long T_UiEvent_SyncSoundSelection                              ; F88522  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88526  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8852A  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8852E  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F88532  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F88536  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8853A  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F8853E  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class1A -- 8 handler(s) for event class 0x1A in pass B
;
; Entries: 0xF410D8, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x1A].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x1A], the LE32 at 0xF87EF9,
;          holds 0xF88542.  The list ENDS at 0xF88566 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class1A:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_208_Msg0716_HandlerTables_13                              ; F88542  [0]   -> 0xF410D8
	.long T_UiEvent_SyncSoundSelection                              ; F88546  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8854A  [2]   -> 0xF4067C
	.long T_F415B0                              ; F8854E  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F88552  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F88556  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F8855A  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8855E  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88562  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class1B -- 8 handler(s) for event class 0x1B in pass B
;
; Entries: 0xF410DC, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x1B].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x1B], the LE32 at 0xF87EFD,
;          holds 0xF88566.  The list ENDS at 0xF8858A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class1B:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_216_Msg0716_HandlerTables_13                              ; F88566  [0]   -> 0xF410DC
	.long T_UiEvent_SyncSoundSelection                              ; F8856A  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F8856E  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88572  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F88576  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8857A  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F8857E  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88582  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88586  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class1C -- 8 handler(s) for event class 0x1C in pass B
;
; Entries: 0xF410E0, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x1C].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x1C], the LE32 at 0xF87F01,
;          holds 0xF8858A.  The list ENDS at 0xF885AE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class1C:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_224_Msg0716_HandlerTables_13                              ; F8858A  [0]   -> 0xF410E0
	.long T_UiEvent_SyncSoundSelection                              ; F8858E  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F88592  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88596  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F8859A  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8859E  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F885A2  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F885A6  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F885AA  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class1D -- 8 handler(s) for event class 0x1D in pass B
;
; Entries: 0xF410E4, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x1D].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x1D], the LE32 at 0xF87F05,
;          holds 0xF885AE.  The list ENDS at 0xF885D2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class1D:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_232_Msg0716_HandlerTables_13                              ; F885AE  [0]   -> 0xF410E4
	.long T_UiEvent_SyncSoundSelection                              ; F885B2  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F885B6  [2]   -> 0xF4067C
	.long T_F415B0                              ; F885BA  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F885BE  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F885C2  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F885C6  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F885CA  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F885CE  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class1E -- 8 handler(s) for event class 0x1E in pass B
;
; Entries: 0xF410E8, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x1E].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x1E], the LE32 at 0xF87F09,
;          holds 0xF885D2.  The list ENDS at 0xF885F6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class1E:
	.long T_F410E8                              ; F885D2  [0]   -> 0xF410E8
	.long T_UiEvent_SyncSoundSelection                              ; F885D6  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F885DA  [2]   -> 0xF4067C
	.long T_F415B0                              ; F885DE  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F885E2  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F885E6  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F885EA  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F885EE  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F885F2  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class1F -- 8 handler(s) for event class 0x1F in pass B
;
; Entries: 0xF410EC, 0xF415A8, 0xF4067C, 0xF415B0, 0xF40754, 0xF418C8, 0xF411C0, 0xF40810, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x1F].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x1F], the LE32 at 0xF87F0D,
;          holds 0xF885F6.  The list ENDS at 0xF8861A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class1F:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_248_Msg0716_HandlerTables_13                              ; F885F6  [0]   -> 0xF410EC
	.long T_UiEvent_SyncSoundSelection                              ; F885FA  [1]   -> 0xF415A8
	.long T_PanelLed_OnPartEvent                              ; F885FE  [2]   -> 0xF4067C
	.long T_F415B0                              ; F88602  [3]   -> 0xF415B0
	.long T_MidiIn_ReqRouteRebuild_Msg0D        ; F88606  [4]   -> 0xF40754
	.long T_CombiEdit_OnPartParamEvent                              ; F8860A  [5]   -> 0xF418C8
	.long T_NoteRouting_OnPartMidiEvent                              ; F8860E  [6]   -> 0xF411C0
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88612  [7]   -> 0xF40810
	.long 0xFFFFFFFF                            ; F88616  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class20 -- 10 handler(s) for event class 0x20 in pass B
;
; Entries: 0xF42470, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF42E54, 0xF42F54, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x20].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x20], the LE32 at 0xF87F11,
;          holds 0xF8861A.  The list ENDS at 0xF88646 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class20:
	.long T_F42470                              ; F8861A  [0]   -> 0xF42470
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F8861E  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88622  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88626  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8862A  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8862E  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88632  [6]   -> 0xF40810
	.long T_Drawbar_MarkReloadOnSoundEvent                              ; F88636  [7]   -> 0xF42E54
	.long T_DspEffect_OnParamEvent                              ; F8863A  [8]   -> 0xF42F54
	.long T_CreatorSelectController_OnPartEvent                              ; F8863E  [9]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88642  [10]   end of list

; ---------------------------------------------------------------------
; UiListB_Class21 -- 8 handler(s) for event class 0x21 in pass B
;
; Entries: 0xF42474, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x21].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x21], the LE32 at 0xF87F15,
;          holds 0xF88646.  The list ENDS at 0xF8866A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class21:
	.long T_F42474                              ; F88646  [0]   -> 0xF42474
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F8864A  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F8864E  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88652  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88656  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8865A  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8865E  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88662  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88666  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class22 -- 8 handler(s) for event class 0x22 in pass B
;
; Entries: 0xF42478, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x22].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x22], the LE32 at 0xF87F19,
;          holds 0xF8866A.  The list ENDS at 0xF8868E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class22:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_16_Msg0716_HandlerTables_56_26                              ; F8866A  [0]   -> 0xF42478
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F8866E  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88672  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88676  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8867A  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8867E  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88682  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88686  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F8868A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class23 -- 8 handler(s) for event class 0x23 in pass B
;
; Entries: 0xF4247C, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x23].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x23], the LE32 at 0xF87F1D,
;          holds 0xF8868E.  The list ENDS at 0xF886B2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class23:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_24_Msg0716_HandlerTables_56_26                              ; F8868E  [0]   -> 0xF4247C
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88692  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88696  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F8869A  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8869E  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F886A2  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F886A6  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F886AA  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F886AE  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class24 -- 8 handler(s) for event class 0x24 in pass B
;
; Entries: 0xF42480, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x24].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x24], the LE32 at 0xF87F21,
;          holds 0xF886B2.  The list ENDS at 0xF886D6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class24:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_32_Msg0716_HandlerTables_56_26                              ; F886B2  [0]   -> 0xF42480
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F886B6  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F886BA  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F886BE  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F886C2  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F886C6  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F886CA  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F886CE  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F886D2  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class25 -- 8 handler(s) for event class 0x25 in pass B
;
; Entries: 0xF42484, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x25].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x25], the LE32 at 0xF87F25,
;          holds 0xF886D6.  The list ENDS at 0xF886FA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class25:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_40_Msg0716_HandlerTables_56_26                              ; F886D6  [0]   -> 0xF42484
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F886DA  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F886DE  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F886E2  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F886E6  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F886EA  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F886EE  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F886F2  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F886F6  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class26 -- 8 handler(s) for event class 0x26 in pass B
;
; Entries: 0xF42488, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x26].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x26], the LE32 at 0xF87F29,
;          holds 0xF886FA.  The list ENDS at 0xF8871E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class26:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_48_Msg0716_HandlerTables_56_26                              ; F886FA  [0]   -> 0xF42488
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F886FE  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88702  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88706  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8870A  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8870E  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88712  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88716  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F8871A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class27 -- 8 handler(s) for event class 0x27 in pass B
;
; Entries: 0xF4248C, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x27].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x27], the LE32 at 0xF87F2D,
;          holds 0xF8871E.  The list ENDS at 0xF88742 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class27:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_56_Msg0716_HandlerTables_56_26                              ; F8871E  [0]   -> 0xF4248C
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88722  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88726  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F8872A  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8872E  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88732  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88736  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F8873A  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F8873E  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class28 -- 8 handler(s) for event class 0x28 in pass B
;
; Entries: 0xF42490, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x28].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x28], the LE32 at 0xF87F31,
;          holds 0xF88742.  The list ENDS at 0xF88766 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class28:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_64_Msg0716_HandlerTables_56_26                              ; F88742  [0]   -> 0xF42490
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88746  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F8874A  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F8874E  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88752  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88756  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8875A  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F8875E  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88762  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class29 -- 8 handler(s) for event class 0x29 in pass B
;
; Entries: 0xF42494, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x29].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x29], the LE32 at 0xF87F35,
;          holds 0xF88766.  The list ENDS at 0xF8878A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class29:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_72_Msg0716_HandlerTables_56_26                              ; F88766  [0]   -> 0xF42494
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F8876A  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F8876E  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88772  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88776  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8877A  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8877E  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88782  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88786  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class2A -- 8 handler(s) for event class 0x2A in pass B
;
; Entries: 0xF42498, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x2A].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x2A], the LE32 at 0xF87F39,
;          holds 0xF8878A.  The list ENDS at 0xF887AE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class2A:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_80_Msg0716_HandlerTables_56_26                              ; F8878A  [0]   -> 0xF42498
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F8878E  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88792  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88796  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8879A  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8879E  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F887A2  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F887A6  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F887AA  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class2B -- 8 handler(s) for event class 0x2B in pass B
;
; Entries: 0xF4249C, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x2B].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x2B], the LE32 at 0xF87F3D,
;          holds 0xF887AE.  The list ENDS at 0xF887D2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class2B:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_88_Msg0716_HandlerTables_56_26                              ; F887AE  [0]   -> 0xF4249C
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F887B2  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F887B6  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F887BA  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F887BE  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F887C2  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F887C6  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F887CA  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F887CE  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class2C -- 8 handler(s) for event class 0x2C in pass B
;
; Entries: 0xF424A0, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x2C].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x2C], the LE32 at 0xF87F41,
;          holds 0xF887D2.  The list ENDS at 0xF887F6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class2C:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_96_Msg0716_HandlerTables_56_26                              ; F887D2  [0]   -> 0xF424A0
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F887D6  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F887DA  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F887DE  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F887E2  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F887E6  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F887EA  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F887EE  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F887F2  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class2D -- 8 handler(s) for event class 0x2D in pass B
;
; Entries: 0xF424A4, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x2D].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x2D], the LE32 at 0xF87F45,
;          holds 0xF887F6.  The list ENDS at 0xF8881A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class2D:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_104_Msg0716_HandlerTables_56_26                              ; F887F6  [0]   -> 0xF424A4
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F887FA  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F887FE  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88802  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88806  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8880A  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8880E  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88812  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88816  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class2E -- 8 handler(s) for event class 0x2E in pass B
;
; Entries: 0xF424A8, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x2E].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x2E], the LE32 at 0xF87F49,
;          holds 0xF8881A.  The list ENDS at 0xF8883E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class2E:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_112_Msg0716_HandlerTables_56_26                              ; F8881A  [0]   -> 0xF424A8
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F8881E  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88822  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88826  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8882A  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8882E  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88832  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88836  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F8883A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class2F -- 8 handler(s) for event class 0x2F in pass B
;
; Entries: 0xF424AC, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x2F].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x2F], the LE32 at 0xF87F4D,
;          holds 0xF8883E.  The list ENDS at 0xF88862 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class2F:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_120_Msg0716_HandlerTables_56_26                              ; F8883E  [0]   -> 0xF424AC
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88842  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88846  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F8884A  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8884E  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88852  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88856  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F8885A  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F8885E  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class30 -- 8 handler(s) for event class 0x30 in pass B
;
; Entries: 0xF424B0, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x30].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x30], the LE32 at 0xF87F51,
;          holds 0xF88862.  The list ENDS at 0xF88886 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class30:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_128_Msg0716_HandlerTables_56_26                              ; F88862  [0]   -> 0xF424B0
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88866  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F8886A  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F8886E  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88872  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88876  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8887A  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F8887E  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88882  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class31 -- 8 handler(s) for event class 0x31 in pass B
;
; Entries: 0xF424B4, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x31].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x31], the LE32 at 0xF87F55,
;          holds 0xF88886.  The list ENDS at 0xF888AA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class31:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_136_Msg0716_HandlerTables_56_26                              ; F88886  [0]   -> 0xF424B4
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F8888A  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F8888E  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88892  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88896  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8889A  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8889E  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F888A2  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F888A6  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class32 -- 8 handler(s) for event class 0x32 in pass B
;
; Entries: 0xF424B8, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x32].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x32], the LE32 at 0xF87F59,
;          holds 0xF888AA.  The list ENDS at 0xF888CE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class32:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_144_Msg0716_HandlerTables_56_26                              ; F888AA  [0]   -> 0xF424B8
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F888AE  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F888B2  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F888B6  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F888BA  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F888BE  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F888C2  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F888C6  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F888CA  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class33 -- 8 handler(s) for event class 0x33 in pass B
;
; Entries: 0xF424BC, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x33].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x33], the LE32 at 0xF87F5D,
;          holds 0xF888CE.  The list ENDS at 0xF888F2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class33:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_152_Msg0716_HandlerTables_56_26                              ; F888CE  [0]   -> 0xF424BC
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F888D2  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F888D6  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F888DA  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F888DE  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F888E2  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F888E6  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F888EA  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F888EE  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class34 -- 8 handler(s) for event class 0x34 in pass B
;
; Entries: 0xF424C0, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x34].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x34], the LE32 at 0xF87F61,
;          holds 0xF888F2.  The list ENDS at 0xF88916 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class34:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_160_Msg0716_HandlerTables_56_26                              ; F888F2  [0]   -> 0xF424C0
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F888F6  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F888FA  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F888FE  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88902  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88906  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8890A  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F8890E  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88912  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class35 -- 8 handler(s) for event class 0x35 in pass B
;
; Entries: 0xF424C4, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x35].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x35], the LE32 at 0xF87F65,
;          holds 0xF88916.  The list ENDS at 0xF8893A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class35:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_168_Msg0716_HandlerTables_56_26                              ; F88916  [0]   -> 0xF424C4
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F8891A  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F8891E  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88922  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88926  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8892A  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8892E  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88932  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88936  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class36 -- 8 handler(s) for event class 0x36 in pass B
;
; Entries: 0xF424C8, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x36].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x36], the LE32 at 0xF87F69,
;          holds 0xF8893A.  The list ENDS at 0xF8895E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class36:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_176_Msg0716_HandlerTables_56_26                              ; F8893A  [0]   -> 0xF424C8
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F8893E  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88942  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88946  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8894A  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F8894E  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88952  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88956  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F8895A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class37 -- 8 handler(s) for event class 0x37 in pass B
;
; Entries: 0xF424CC, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x37].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x37], the LE32 at 0xF87F6D,
;          holds 0xF8895E.  The list ENDS at 0xF88982 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class37:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_184_Msg0716_HandlerTables_56_26                              ; F8895E  [0]   -> 0xF424CC
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88962  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88966  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F8896A  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F8896E  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88972  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88976  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F8897A  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F8897E  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class38 -- 8 handler(s) for event class 0x38 in pass B
;
; Entries: 0xF424D0, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x38].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x38], the LE32 at 0xF87F71,
;          holds 0xF88982.  The list ENDS at 0xF889A6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class38:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_192_Msg0716_HandlerTables_56_26                              ; F88982  [0]   -> 0xF424D0
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88986  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F8898A  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F8898E  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88992  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88996  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F8899A  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F8899E  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F889A2  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class39 -- 8 handler(s) for event class 0x39 in pass B
;
; Entries: 0xF424D4, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x39].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x39], the LE32 at 0xF87F75,
;          holds 0xF889A6.  The list ENDS at 0xF889CA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class39:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_200_Msg0716_HandlerTables_56_26                              ; F889A6  [0]   -> 0xF424D4
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F889AA  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F889AE  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F889B2  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F889B6  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F889BA  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F889BE  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F889C2  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F889C6  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class3A -- 8 handler(s) for event class 0x3A in pass B
;
; Entries: 0xF424D8, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x3A].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x3A], the LE32 at 0xF87F79,
;          holds 0xF889CA.  The list ENDS at 0xF889EE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class3A:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_208_Msg0716_HandlerTables_56_26                              ; F889CA  [0]   -> 0xF424D8
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F889CE  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F889D2  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F889D6  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F889DA  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F889DE  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F889E2  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F889E6  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F889EA  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class3B -- 8 handler(s) for event class 0x3B in pass B
;
; Entries: 0xF424DC, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x3B].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x3B], the LE32 at 0xF87F7D,
;          holds 0xF889EE.  The list ENDS at 0xF88A12 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class3B:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_216_Msg0716_HandlerTables_56_26                              ; F889EE  [0]   -> 0xF424DC
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F889F2  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F889F6  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F889FA  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F889FE  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88A02  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88A06  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88A0A  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88A0E  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class3C -- 8 handler(s) for event class 0x3C in pass B
;
; Entries: 0xF424E0, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x3C].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x3C], the LE32 at 0xF87F81,
;          holds 0xF88A12.  The list ENDS at 0xF88A36 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class3C:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_224_Msg0716_HandlerTables_56_26                              ; F88A12  [0]   -> 0xF424E0
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88A16  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88A1A  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88A1E  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88A22  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88A26  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88A2A  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88A2E  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88A32  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class3D -- 8 handler(s) for event class 0x3D in pass B
;
; Entries: 0xF424E4, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x3D].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x3D], the LE32 at 0xF87F85,
;          holds 0xF88A36.  The list ENDS at 0xF88A5A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class3D:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_232_Msg0716_HandlerTables_56_26                              ; F88A36  [0]   -> 0xF424E4
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88A3A  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88A3E  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88A42  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88A46  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88A4A  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88A4E  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88A52  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88A56  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class3E -- 8 handler(s) for event class 0x3E in pass B
;
; Entries: 0xF424E8, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x3E].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x3E], the LE32 at 0xF87F89,
;          holds 0xF88A5A.  The list ENDS at 0xF88A7E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class3E:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_240_Msg0716_HandlerTables_56_26                              ; F88A5A  [0]   -> 0xF424E8
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88A5E  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88A62  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88A66  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88A6A  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88A6E  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88A72  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88A76  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88A7A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class3F -- 8 handler(s) for event class 0x3F in pass B
;
; Entries: 0xF424EC, 0xF415A0, 0xF40698, 0xF418C8, 0xF411C4, 0xF43350, 0xF40810, 0xF434F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x3F].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x3F], the LE32 at 0xF87F8D,
;          holds 0xF88A7E.  The list ENDS at 0xF88AA2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class3F:
	.long T_Msg0716_DispatchIndex_Msg0716_ObjectRecords_248_Msg0716_HandlerTables_56_26                              ; F88A7E  [0]   -> 0xF424EC
	.long T_UiEvent_MarkRedrawFromClass20Block                              ; F88A82  [1]   -> 0xF415A0
	.long T_PanelLed_OnClass20Event                              ; F88A86  [2]   -> 0xF40698
	.long T_CombiEdit_OnPartParamEvent                              ; F88A8A  [3]   -> 0xF418C8
	.long T_NoteRouting_OnPartPlayParamEvent                              ; F88A8E  [4]   -> 0xF411C4
	.long T_MidiIn_ReqListRebuild_Msg13_16                              ; F88A92  [5]   -> 0xF43350
	.long T_ParamMsg_RefreshMasksOnCtrlFieldChange                              ; F88A96  [6]   -> 0xF40810
	.long T_CreatorSelectController_OnPartEvent                              ; F88A9A  [7]   -> 0xF434F4
	.long 0xFFFFFFFF                            ; F88A9E  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_Class40 -- 2 handler(s) for event class 0x40 in pass B
;
; Entries: 0xF410F0, 0xF4067C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x40].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x40], the LE32 at 0xF87F91,
;          holds 0xF88AA2.  The list ENDS at 0xF88AAE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class40:
	.long T_F410F0                              ; F88AA2  [0]   -> 0xF410F0
	.long T_PanelLed_OnPartEvent                              ; F88AA6  [1]   -> 0xF4067C
	.long 0xFFFFFFFF                            ; F88AAA  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_Class41 -- 1 handler(s) for event class 0x41 in pass B
;
; Entries: 0xF410F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x41].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x41], the LE32 at 0xF87F95,
;          holds 0xF88AAE.  The list ENDS at 0xF88AB6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class41:
	.long T_F410F4                              ; F88AAE  [0]   -> 0xF410F4
	.long 0xFFFFFFFF                            ; F88AB2  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class42 -- 1 handler(s) for event class 0x42 in pass B
;
; Entries: 0xF410F8, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x42].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x42], the LE32 at 0xF87F99,
;          holds 0xF88AB6.  The list ENDS at 0xF88ABE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class42:
	.long T_F410F8                              ; F88AB6  [0]   -> 0xF410F8
	.long 0xFFFFFFFF                            ; F88ABA  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class48 -- 2 handler(s) for event class 0x48 in pass B
;
; Entries: 0xF410FC, 0xF40684, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x48].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x48], the LE32 at 0xF87FB1,
;          holds 0xF88ABE.  The list ENDS at 0xF88ACA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class48:
	.long T_F410FC                              ; F88ABE  [0]   -> 0xF410FC
	.long T_F40684                              ; F88AC2  [1]   -> 0xF40684
	.long 0xFFFFFFFF                            ; F88AC6  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_Class50 -- 1 handler(s) for event class 0x50 in pass B
;
; Entries: 0xF41100, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x50].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x50], the LE32 at 0xF87FD1,
;          holds 0xF88ACA.  The list ENDS at 0xF88AD2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class50:
	.long T_F41100                              ; F88ACA  [0]   -> 0xF41100
	.long 0xFFFFFFFF                            ; F88ACE  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class51 -- 1 handler(s) for event class 0x51 in pass B
;
; Entries: 0xF41104, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x51].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x51], the LE32 at 0xF87FD5,
;          holds 0xF88AD2.  The list ENDS at 0xF88ADA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class51:
	.long T_F41104                              ; F88AD2  [0]   -> 0xF41104
	.long 0xFFFFFFFF                            ; F88AD6  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class52 -- 1 handler(s) for event class 0x52 in pass B
;
; Entries: 0xF41108, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x52].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x52], the LE32 at 0xF87FD9,
;          holds 0xF88ADA.  The list ENDS at 0xF88AE2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class52:
	.long T_F41108                              ; F88ADA  [0]   -> 0xF41108
	.long 0xFFFFFFFF                            ; F88ADE  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class53 -- 1 handler(s) for event class 0x53 in pass B
;
; Entries: 0xF4110C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x53].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x53], the LE32 at 0xF87FDD,
;          holds 0xF88AE2.  The list ENDS at 0xF88AEA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class53:
	.long T_F4110C                              ; F88AE2  [0]   -> 0xF4110C
	.long 0xFFFFFFFF                            ; F88AE6  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class54 -- 1 handler(s) for event class 0x54 in pass B
;
; Entries: 0xF41174, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x54].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x54], the LE32 at 0xF87FE1,
;          holds 0xF88AEA.  The list ENDS at 0xF88AF2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class54:
	.long T_F41174                              ; F88AEA  [0]   -> 0xF41174
	.long 0xFFFFFFFF                            ; F88AEE  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class60 -- 2 handler(s) for event class 0x60 in pass B
;
; Entries: 0xF41110, 0xF42F54, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x60].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x60], the LE32 at 0xF88011,
;          holds 0xF88AF2.  The list ENDS at 0xF88AFE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class60:
	.long T_Msg0716_SetPendingBit0                              ; F88AF2  [0]   -> 0xF41110
	.long T_DspEffect_OnParamEvent                              ; F88AF6  [1]   -> 0xF42F54
	.long 0xFFFFFFFF                            ; F88AFA  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_Class61 -- 2 handler(s) for event class 0x61 in pass B
;
; Entries: 0xF41114, 0xF42F54, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x61].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x61], the LE32 at 0xF88015,
;          holds 0xF88AFE.  The list ENDS at 0xF88B0A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class61:
	.long T_Msg0716_SetPendingBit1                              ; F88AFE  [0]   -> 0xF41114
	.long T_DspEffect_OnParamEvent                              ; F88B02  [1]   -> 0xF42F54
	.long 0xFFFFFFFF                            ; F88B06  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_Class62 -- 2 handler(s) for event class 0x62 in pass B
;
; Entries: 0xF41118, 0xF42F54, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x62].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x62], the LE32 at 0xF88019,
;          holds 0xF88B0A.  The list ENDS at 0xF88B16 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class62:
	.long T_Msg0716_SetPendingBit2                              ; F88B0A  [0]   -> 0xF41118
	.long T_DspEffect_OnParamEvent                              ; F88B0E  [1]   -> 0xF42F54
	.long 0xFFFFFFFF                            ; F88B12  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_Class63 -- 2 handler(s) for event class 0x63 in pass B
;
; Entries: 0xF4111C, 0xF42F54, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x63].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x63], the LE32 at 0xF8801D,
;          holds 0xF88B16.  The list ENDS at 0xF88B22 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class63:
	.long T_Msg0716_SetPendingBit3                              ; F88B16  [0]   -> 0xF4111C
	.long T_DspEffect_OnParamEvent                              ; F88B1A  [1]   -> 0xF42F54
	.long 0xFFFFFFFF                            ; F88B1E  [2]   end of list
; Evidence: UiEventClass_ListTable_B[0x64], the LE32 at 0xF88021, holds 0xF88B22.  GENERATED name.
UiListB_Class64:
	.long 0xFFFFFFFF                            ; F88B22  [0]   end of list
; Evidence: UiEventClass_ListTable_B[0x65], the LE32 at 0xF88025, holds 0xF88B26.  GENERATED name.
UiListB_Class65:
	.long 0xFFFFFFFF                            ; F88B26  [0]   end of list
; Evidence: UiEventClass_ListTable_B[0x66], the LE32 at 0xF88029, holds 0xF88B2A.  GENERATED name.
UiListB_Class66:
	.long 0xFFFFFFFF                            ; F88B2A  [0]   end of list

; ---------------------------------------------------------------------
; UiListB_Class68 -- 1 handler(s) for event class 0x68 in pass B
;
; Entries: 0xF41120, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x68].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x68], the LE32 at 0xF88031,
;          holds 0xF88B2E.  The list ENDS at 0xF88B36 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class68:
	.long T_F41120                              ; F88B2E  [0]   -> 0xF41120
	.long 0xFFFFFFFF                            ; F88B32  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class69 -- 1 handler(s) for event class 0x69 in pass B
;
; Entries: 0xF41124, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x69].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x69], the LE32 at 0xF88035,
;          holds 0xF88B36.  The list ENDS at 0xF88B3E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class69:
	.long T_F41124                              ; F88B36  [0]   -> 0xF41124
	.long 0xFFFFFFFF                            ; F88B3A  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class6A -- 1 handler(s) for event class 0x6A in pass B
;
; Entries: 0xF41128, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x6A].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x6A], the LE32 at 0xF88039,
;          holds 0xF88B3E.  The list ENDS at 0xF88B46 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class6A:
	.long T_F41128                              ; F88B3E  [0]   -> 0xF41128
	.long 0xFFFFFFFF                            ; F88B42  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class6B -- 1 handler(s) for event class 0x6B in pass B
;
; Entries: 0xF4112C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x6B].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x6B], the LE32 at 0xF8803D,
;          holds 0xF88B46.  The list ENDS at 0xF88B4E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class6B:
	.long T_F4112C                              ; F88B46  [0]   -> 0xF4112C
	.long 0xFFFFFFFF                            ; F88B4A  [1]   end of list
; Evidence: UiEventClass_ListTable_B[0x6C], the LE32 at 0xF88041, holds 0xF88B4E.  GENERATED name.
UiListB_Class6C:
	.long 0xFFFFFFFF                            ; F88B4E  [0]   end of list
; Evidence: UiEventClass_ListTable_B[0x6D], the LE32 at 0xF88045, holds 0xF88B52.  GENERATED name.
UiListB_Class6D:
	.long 0xFFFFFFFF                            ; F88B52  [0]   end of list
; Evidence: UiEventClass_ListTable_B[0x6E], the LE32 at 0xF88049, holds 0xF88B56.  GENERATED name.
UiListB_Class6E:
	.long 0xFFFFFFFF                            ; F88B56  [0]   end of list

; ---------------------------------------------------------------------
; UiListB_Class70 -- 3 handler(s) for event class 0x70 in pass B
;
; Entries: 0xF41130, 0xF40690, 0xF411CC, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x70].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x70], the LE32 at 0xF88051,
;          holds 0xF88B5A.  The list ENDS at 0xF88B6A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class70:
	.long T_F41130                              ; F88B5A  [0]   -> 0xF41130
	.long T_F40690                              ; F88B5E  [1]   -> 0xF40690
	.long T_F411CC                              ; F88B62  [2]   -> 0xF411CC
	.long 0xFFFFFFFF                            ; F88B66  [3]   end of list

; ---------------------------------------------------------------------
; UiListB_Class71 -- 2 handler(s) for event class 0x71 in pass B
;
; Entries: 0xF41134, 0xF411E4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x71].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x71], the LE32 at 0xF88055,
;          holds 0xF88B6A.  The list ENDS at 0xF88B76 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class71:
	.long T_F41134                              ; F88B6A  [0]   -> 0xF41134
	.long T_F411E4                              ; F88B6E  [1]   -> 0xF411E4
	.long 0xFFFFFFFF                            ; F88B72  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_Class72 -- 1 handler(s) for event class 0x72 in pass B
;
; Entries: 0xF41138, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x72].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x72], the LE32 at 0xF88059,
;          holds 0xF88B76.  The list ENDS at 0xF88B7E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class72:
	.long T_F41138                              ; F88B76  [0]   -> 0xF41138
	.long 0xFFFFFFFF                            ; F88B7A  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class78 -- 1 handler(s) for event class 0x78 in pass B
;
; Entries: 0xF4113C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x78].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x78], the LE32 at 0xF88071,
;          holds 0xF88B7E.  The list ENDS at 0xF88B86 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class78:
	.long T_F4113C                              ; F88B7E  [0]   -> 0xF4113C
	.long 0xFFFFFFFF                            ; F88B82  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class79 -- 4 handler(s) for event class 0x79 in pass B
;
; Entries: 0xF41140, 0xF415B0, 0xF411E8, 0xF42F54, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x79].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x79], the LE32 at 0xF88075,
;          holds 0xF88B86.  The list ENDS at 0xF88B9A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class79:
	.long T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_164_6                              ; F88B86  [0]   -> 0xF41140
	.long T_F415B0                              ; F88B8A  [1]   -> 0xF415B0
	.long T_F411E8                              ; F88B8E  [2]   -> 0xF411E8
	.long T_DspEffect_OnParamEvent                              ; F88B92  [3]   -> 0xF42F54
	.long 0xFFFFFFFF                            ; F88B96  [4]   end of list

; ---------------------------------------------------------------------
; UiListB_Class7A -- 2 handler(s) for event class 0x7A in pass B
;
; Entries: 0xF41144, 0xF415B8, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x7A].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x7A], the LE32 at 0xF88079,
;          holds 0xF88B9A.  The list ENDS at 0xF88BA6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class7A:
	.long T_F41144                              ; F88B9A  [0]   -> 0xF41144
	.long T_UiEventClass7A_QueueDialValueRedraw                              ; F88B9E  [1]   -> 0xF415B8
	.long 0xFFFFFFFF                            ; F88BA2  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_Class80 -- 5 handler(s) for event class 0x80 in pass B
;
; Entries: 0xF41148, 0xF40688, 0xF411D4, 0xF4079C, 0xF43354, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x80].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x80], the LE32 at 0xF88091,
;          holds 0xF88BA6.  The list ENDS at 0xF88BBE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class80:
	.long T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_280_2                              ; F88BA6  [0]   -> 0xF41148
	.long T_F40688                              ; F88BAA  [1]   -> 0xF40688
	.long T_NoteRouting_OnMidiSystemEvent                              ; F88BAE  [2]   -> 0xF411D4
	.long T_ProgramChangeMode_OnEvent                              ; F88BB2  [3]   -> 0xF4079C
	.long T_MidiIn_ReqRebuild_Msg03_0A          ; F88BB6  [4]   -> 0xF43354
	.long 0xFFFFFFFF                            ; F88BBA  [5]   end of list

; ---------------------------------------------------------------------
; UiListB_Class81 -- 1 handler(s) for event class 0x81 in pass B
;
; Entries: 0xF4114C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x81].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x81], the LE32 at 0xF88095,
;          holds 0xF88BBE.  The list ENDS at 0xF88BC6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class81:
	.long T_F4114C                              ; F88BBE  [0]   -> 0xF4114C
	.long 0xFFFFFFFF                            ; F88BC2  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class90 -- 4 handler(s) for event class 0x90 in pass B
;
; Entries: 0xF41150, 0xF40680, 0xF411C8, 0xF415A8, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x90].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x90], the LE32 at 0xF880D1,
;          holds 0xF88BC6.  The list ENDS at 0xF88BDA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class90:
	.long T_F41150                              ; F88BC6  [0]   -> 0xF41150
	.long T_PanelLed_OnClass90Event                              ; F88BCA  [1]   -> 0xF40680
	.long T_F411C8                              ; F88BCE  [2]   -> 0xF411C8
	.long T_UiEvent_SyncSoundSelection                              ; F88BD2  [3]   -> 0xF415A8
	.long 0xFFFFFFFF                            ; F88BD6  [4]   end of list

; ---------------------------------------------------------------------
; UiListB_Class91 -- 5 handler(s) for event class 0x91 in pass B
;
; Entries: 0xF408F4, 0xF41154, 0xF411D8, 0xF42828, 0xF415A4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x91].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x91], the LE32 at 0xF880D5,
;          holds 0xF88BDA.  The list ENDS at 0xF88BF2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class91:
	.long T_GmMode_OnEventPassB                              ; F88BDA  [0]   -> 0xF408F4
	.long T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_292_14                              ; F88BDE  [1]   -> 0xF41154
	.long T_F411D8                              ; F88BE2  [2]   -> 0xF411D8
	.long T_SongGmFlag_OnEventPassB_Veneer                              ; F88BE6  [3]   -> 0xF42828
	.long T_GmMode_RepaintModeScreen                              ; F88BEA  [4]   -> 0xF415A4
	.long 0xFFFFFFFF                            ; F88BEE  [5]   end of list

; ---------------------------------------------------------------------
; UiListB_Class92 -- 1 handler(s) for event class 0x92 in pass B
;
; Entries: 0xF41158, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x92].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x92], the LE32 at 0xF880D9,
;          holds 0xF88BF2.  The list ENDS at 0xF88BFA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class92:
	.long T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_192_13                              ; F88BF2  [0]   -> 0xF41158
	.long 0xFFFFFFFF                            ; F88BF6  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class93 -- 2 handler(s) for event class 0x93 in pass B
;
; Entries: 0xF4115C, 0xF411DC, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x93].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x93], the LE32 at 0xF880DD,
;          holds 0xF88BFA.  The list ENDS at 0xF88C06 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class93:
	.long T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_248_7                              ; F88BFA  [0]   -> 0xF4115C
	.long T_F411DC                              ; F88BFE  [1]   -> 0xF411DC
	.long 0xFFFFFFFF                            ; F88C02  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_Class98 -- 4 handler(s) for event class 0x98 in pass B
;
; Entries: 0xF41160, 0xF40694, 0xF411D0, 0xF415A8, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x98].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x98], the LE32 at 0xF880F1,
;          holds 0xF88C06.  The list ENDS at 0xF88C1A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class98:
	.long T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_352_4                              ; F88C06  [0]   -> 0xF41160
	.long T_PanelLed_OnClass98Event                              ; F88C0A  [1]   -> 0xF40694
	.long T_NoteRouting_OnPlayModeRequest                              ; F88C0E  [2]   -> 0xF411D0
	.long T_UiEvent_SyncSoundSelection                              ; F88C12  [3]   -> 0xF415A8
	.long 0xFFFFFFFF                            ; F88C16  [4]   end of list

; ---------------------------------------------------------------------
; UiListB_Class99 -- 1 handler(s) for event class 0x99 in pass B
;
; Entries: 0xF41164, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x99].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x99], the LE32 at 0xF880F5,
;          holds 0xF88C1A.  The list ENDS at 0xF88C22 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class99:
	.long T_F41164                              ; F88C1A  [0]   -> 0xF41164
	.long 0xFFFFFFFF                            ; F88C1E  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_Class9A -- 1 handler(s) for event class 0x9A in pass B
;
; Entries: 0xF41168, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0x9A].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0x9A], the LE32 at 0xF880F9,
;          holds 0xF88C22.  The list ENDS at 0xF88C2A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_Class9A:
	.long T_UiListB_Class9A_Nop                              ; F88C22  [0]   -> 0xF41168
	.long 0xFFFFFFFF                            ; F88C26  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassA8 -- 8 handler(s) for event class 0xA8 in pass B
;
; Entries: 0xF4116C, 0xF415A8, 0xF4068C, 0xF411E0, 0xF409A0, 0xF40CBC, 0xF434F0, 0xF415B0, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xA8].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xA8], the LE32 at 0xF88131,
;          holds 0xF88C2A.  The list ENDS at 0xF88C4E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassA8:
	.long T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_372_19                              ; F88C2A  [0]   -> 0xF4116C
	.long T_UiEvent_SyncSoundSelection                              ; F88C2E  [1]   -> 0xF415A8
	.long T_PanelLed_OnClassA8Event                              ; F88C32  [2]   -> 0xF4068C
	.long T_NoteRouting_SetMidiOutPorts                              ; F88C36  [3]   -> 0xF411E0
	.long T_wsa1_prom_b_Join2                              ; F88C3A  [4]   -> 0xF409A0
	.long T_Seq_RequestRewindOnEvent                              ; F88C3E  [5]   -> 0xF40CBC
	.long T_CreatorSelectController_OpenOnEvent                              ; F88C42  [6]   -> 0xF434F0
	.long T_F415B0                              ; F88C46  [7]   -> 0xF415B0
	.long 0xFFFFFFFF                            ; F88C4A  [8]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassA9 -- 1 handler(s) for event class 0xA9 in pass B
;
; Entries: 0xF41170, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xA9].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xA9], the LE32 at 0xF88135,
;          holds 0xF88C4E.  The list ENDS at 0xF88C56 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassA9:
	.long T_F41170                              ; F88C4E  [0]   -> 0xF41170
	.long 0xFFFFFFFF                            ; F88C52  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassAC -- 1 handler(s) for event class 0xAC in pass B
;
; Entries: 0xF41178, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xAC].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xAC], the LE32 at 0xF88141,
;          holds 0xF88C56.  The list ENDS at 0xF88C5E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassAC:
	.long T_F41178                              ; F88C56  [0]   -> 0xF41178
	.long 0xFFFFFFFF                            ; F88C5A  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassAD -- 1 handler(s) for event class 0xAD in pass B
;
; Entries: 0xF4117C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xAD].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xAD], the LE32 at 0xF88145,
;          holds 0xF88C5E.  The list ENDS at 0xF88C66 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassAD:
	.long T_F4117C                              ; F88C5E  [0]   -> 0xF4117C
	.long 0xFFFFFFFF                            ; F88C62  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassAE -- 1 handler(s) for event class 0xAE in pass B
;
; Entries: 0xF41180, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xAE].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xAE], the LE32 at 0xF88149,
;          holds 0xF88C66.  The list ENDS at 0xF88C6E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassAE:
	.long T_Msg0716_EventPartPostCC78_AllSoundOff                              ; F88C66  [0]   -> 0xF41180
	.long 0xFFFFFFFF                            ; F88C6A  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB0 -- 1 handler(s) for event class 0xB0 in pass B
;
; Entries: 0xF424F0, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB0].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB0], the LE32 at 0xF88151,
;          holds 0xF88C6E.  The list ENDS at 0xF88C76 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB0:
	.long T_Msg0716_DispatchIndex_Twin_Msg0716_HandlerTables_452_17                              ; F88C6E  [0]   -> 0xF424F0
	.long 0xFFFFFFFF                            ; F88C72  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB1 -- 1 handler(s) for event class 0xB1 in pass B
;
; Entries: 0xF424F4, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB1].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB1], the LE32 at 0xF88155,
;          holds 0xF88C76.  The list ENDS at 0xF88C7E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB1:
	.long T_Msg0716_OnPitchBendEvent                              ; F88C76  [0]   -> 0xF424F4
	.long 0xFFFFFFFF                            ; F88C7A  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB2 -- 2 handler(s) for event class 0xB2 in pass B
;
; Entries: 0xF424F8, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB2].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB2], the LE32 at 0xF88159,
;          holds 0xF88C7E.  The list ENDS at 0xF88C8A because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB2:
	.long T_Msg0716_EventPartPostCC01_ModulationIfEnabled                              ; F88C7E  [0]   -> 0xF424F8
	.long T_PanelLed_OnCtrlParamEvent                              ; F88C82  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88C86  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB3 -- 2 handler(s) for event class 0xB3 in pass B
;
; Entries: 0xF424FC, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB3].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB3], the LE32 at 0xF8815D,
;          holds 0xF88C8A.  The list ENDS at 0xF88C96 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB3:
	.long T_Msg0716_EventPartPostCC0B_Expression                              ; F88C8A  [0]   -> 0xF424FC
	.long T_PanelLed_OnCtrlParamEvent                              ; F88C8E  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88C92  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB4 -- 2 handler(s) for event class 0xB4 in pass B
;
; Entries: 0xF42500, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB4].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB4], the LE32 at 0xF88161,
;          holds 0xF88C96.  The list ENDS at 0xF88CA2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB4:
	.long T_Msg0716_OnChannelPressureEvent                              ; F88C96  [0]   -> 0xF42500
	.long T_PanelLed_OnCtrlParamEvent                              ; F88C9A  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88C9E  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB5 -- 2 handler(s) for event class 0xB5 in pass B
;
; Entries: 0xF42504, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB5].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB5], the LE32 at 0xF88165,
;          holds 0xF88CA2.  The list ENDS at 0xF88CAE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB5:
	.long T_Msg0716_EventPartPostCC40_SustainFromValueIfEnabled                              ; F88CA2  [0]   -> 0xF42504
	.long T_PanelLed_OnCtrlParamEvent                              ; F88CA6  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88CAA  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB6 -- 1 handler(s) for event class 0xB6 in pass B
;
; Entries: 0xF42508, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB6].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB6], the LE32 at 0xF88169,
;          holds 0xF88CAE.  The list ENDS at 0xF88CB6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB6:
	.long T_F42508                              ; F88CAE  [0]   -> 0xF42508
	.long 0xFFFFFFFF                            ; F88CB2  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB7 -- 1 handler(s) for event class 0xB7 in pass B
;
; Entries: 0xF4250C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB7].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB7], the LE32 at 0xF8816D,
;          holds 0xF88CB6.  The list ENDS at 0xF88CBE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB7:
	.long T_F4250C                              ; F88CB6  [0]   -> 0xF4250C
	.long 0xFFFFFFFF                            ; F88CBA  [1]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB8 -- 2 handler(s) for event class 0xB8 in pass B
;
; Entries: 0xF42510, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB8].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB8], the LE32 at 0xF88171,
;          holds 0xF88CBE.  The list ENDS at 0xF88CCA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB8:
	.long T_Msg0716_EventPartPostCC10_GeneralPurpose1IfEnabled                              ; F88CBE  [0]   -> 0xF42510
	.long T_PanelLed_OnCtrlParamEvent                              ; F88CC2  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88CC6  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassB9 -- 2 handler(s) for event class 0xB9 in pass B
;
; Entries: 0xF42514, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xB9].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xB9], the LE32 at 0xF88175,
;          holds 0xF88CCA.  The list ENDS at 0xF88CD6 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassB9:
	.long T_Msg0716_EventPartPostCC11_GeneralPurpose2IfEnabled                              ; F88CCA  [0]   -> 0xF42514
	.long T_PanelLed_OnCtrlParamEvent                              ; F88CCE  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88CD2  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassBA -- 2 handler(s) for event class 0xBA in pass B
;
; Entries: 0xF42518, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xBA].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xBA], the LE32 at 0xF88179,
;          holds 0xF88CD6.  The list ENDS at 0xF88CE2 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassBA:
	.long T_Msg0716_EventPartPostCC12_GeneralPurpose3IfEnabled                              ; F88CD6  [0]   -> 0xF42518
	.long T_PanelLed_OnCtrlParamEvent                              ; F88CDA  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88CDE  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassBB -- 2 handler(s) for event class 0xBB in pass B
;
; Entries: 0xF4251C, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xBB].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xBB], the LE32 at 0xF8817D,
;          holds 0xF88CE2.  The list ENDS at 0xF88CEE because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassBB:
	.long T_Msg0716_EventPartPostCC13_GeneralPurpose4IfEnabled                              ; F88CE2  [0]   -> 0xF4251C
	.long T_PanelLed_OnCtrlParamEvent                              ; F88CE6  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88CEA  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassBC -- 2 handler(s) for event class 0xBC in pass B
;
; Entries: 0xF42520, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xBC].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xBC], the LE32 at 0xF88181,
;          holds 0xF88CEE.  The list ENDS at 0xF88CFA because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassBC:
	.long T_Msg0716_EventPartPostCC02_BreathIfEnabled                              ; F88CEE  [0]   -> 0xF42520
	.long T_PanelLed_OnCtrlParamEvent                              ; F88CF2  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88CF6  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_ClassBD -- 2 handler(s) for event class 0xBD in pass B
;
; Entries: 0xF42524, 0xF4069C, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_B[0xBD].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_B[0xBD], the LE32 at 0xF88185,
;          holds 0xF88CFA.  The list ENDS at 0xF88D06 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListB_ClassBD:
	.long T_Msg0716_EventPartPostCC04_FootIfEnabled                              ; F88CFA  [0]   -> 0xF42524
	.long T_PanelLed_OnCtrlParamEvent                              ; F88CFE  [1]   -> 0xF4069C
	.long 0xFFFFFFFF                            ; F88D02  [2]   end of list

; ---------------------------------------------------------------------
; UiListB_Shared -- the empty list 71 class ids share
;
; Classes: every id NOT in the 121-member set the three tables agree
;          on.  Generated from the table, not typed:
;          0x43-0x47, 0x49-0x4F, 0x55-0x5F, 0x67, 0x6F, 0x73-0x77,
;          0x7B-0x7F, 0x82-0x8F, 0x94-0x97, 0x9B-0xA7, 0xAA-0xAB, 0xAF,
;          0xBE-0xBF
;          Check L2 asserts the set is the same in all three tables.
; Position: it is the LAST object in the area, and its 4 bytes are what
;          make the tiling reach 0xF88D0A exactly.
; Evidence: 71 of the 192 LE32 entries of UiEventClass_ListTable_B hold
;          0xF88D06, and the word there is the 0xFFFFFFFF terminator.
; ---------------------------------------------------------------------
UiListB_Shared:
	.long 0xFFFFFFFF                            ; F88D06  [0]   end of list

; --- 0xF88D0A-0xF88E90  0x00 pad (391 bytes) ---
	.fill 391, 1, 0x00

; --- 0xF88E91-0xF88EAC  0xFFFFFFFF-terminated list (28 bytes) ---

; ---------------------------------------------------------------------
; UiEventPassB_TailList -- LE32 routines run once, after the whole list
;
; Read by: ONE site, `ld XIY,0x00F88E91 / ld (0x20C4),XIY` at UiEventList_RunPassB 0xF8699D.
;          UiEventList_Run walks it at 0xF86A6A-0xF86A7E after the
;          record loop, calling every entry until a word 0xFFFF.
; Entries: 0xF40FB4, 0xF411B4, 0xF40290, 0xF40758, 0xF42E60, 0xF418CC (6), then the 0xFFFF terminator.
; ENTRY COUNT: the terminator IS the count; the bytes after it are the
;          0x00 pad that runs to the next object.
; Evidence: `ld XIY,0x00F88E91` at 0xF869A6, four bytes before `ld (0x20C4),XIY`;
;          UiEventList_Run reads (0x20C4) at 0xF86A6A and stops on
;          `cp (XIX),0xffff`.
; ---------------------------------------------------------------------
UiEventPassB_TailList:
	.long T_Msg0716_FlushIfPending                              ; F88E91  [0]   -> 0xF40FB4
	.long T_NoteRouting_RebuildIfPending                              ; F88E95  [1]   -> 0xF411B4
	.long T_PanelScreen_RequestRedrawIfFieldQueued                              ; F88E99  [2]   -> 0xF40290
	.long T_MidiIn_ServiceDeferred              ; F88E9D  [3]   -> 0xF40758
	.long T_Drawbar_ReloadIfMarked                              ; F88EA1  [4]   -> 0xF42E60
	.long T_CombiEdit_RunPendingRepaint                              ; F88EA5  [5]   -> 0xF418CC
	.long 0xFFFFFFFF                            ; F88EA9  [6]   end of list

; --- 0xF88EAD-0xF88EC0  0x00 pad (20 bytes) ---
	.fill 20, 1, 0x00

; --- 0xF88EC1-0xF891C0  pointer table (768 bytes) ---

; ---------------------------------------------------------------------
; UiEventClass_ListTable_C -- 192 LE32 heads, indexed by the event class
;
; Read by: ONE site, `ld XIY,0x00F88EC1 / ld (0x20C0),XIY` at UiEventList_RunPassC 0xF869BC;
;          UiEventList_Run indexes it with the record's byte +0.
; ENTRY COUNT 192, pinned twice: `cp L,0xbf` at 0xF869FB rejects a class
;          above 191, and the 0x300-byte extent is 192 * 4.  The table
;          ends one pad byte before its own list area.
; ★ 121 class ids have their own list and the other 71 share the area's
;          trailing empty list -- and the SAME 121 ids do so in all
;          THREE tables (check L2).  The distinct heads tile the list
;          area exactly, in ascending order, with no byte left over
;          (check L3).
; Evidence: `ld XIY,0x00F88EC1` at 0xF869BC, four bytes before `ld (0x20C0),XIY`;
;          UiEventList_Run reads (0x20C0) at 0xF869EF and indexes it
;          with `sla 0x02,HL` at 0xF86A00.
; ---------------------------------------------------------------------
UiEventClass_ListTable_C:
	.long UiListC_Class00                       ; F88EC1  [0]   -> UiListC_Class00
	.long UiListC_Class01                       ; F88EC5  [1]   -> UiListC_Class01
	.long UiListC_Class02                       ; F88EC9  [2]   -> UiListC_Class02
	.long UiListC_Class03                       ; F88ECD  [3]   -> UiListC_Class03
	.long UiListC_Class04                       ; F88ED1  [4]   -> UiListC_Class04
	.long UiListC_Class05                       ; F88ED5  [5]   -> UiListC_Class05
	.long UiListC_Class06                       ; F88ED9  [6]   -> UiListC_Class06
	.long UiListC_Class07                       ; F88EDD  [7]   -> UiListC_Class07
	.long UiListC_Class08                       ; F88EE1  [8]   -> UiListC_Class08
	.long UiListC_Class09                       ; F88EE5  [9]   -> UiListC_Class09
	.long UiListC_Class0A                       ; F88EE9  [10]   -> UiListC_Class0A
	.long UiListC_Class0B                       ; F88EED  [11]   -> UiListC_Class0B
	.long UiListC_Class0C                       ; F88EF1  [12]   -> UiListC_Class0C
	.long UiListC_Class0D                       ; F88EF5  [13]   -> UiListC_Class0D
	.long UiListC_Class0E                       ; F88EF9  [14]   -> UiListC_Class0E
	.long UiListC_Class0F                       ; F88EFD  [15]   -> UiListC_Class0F
	.long UiListC_Class10                       ; F88F01  [16]   -> UiListC_Class10
	.long UiListC_Class11                       ; F88F05  [17]   -> UiListC_Class11
	.long UiListC_Class12                       ; F88F09  [18]   -> UiListC_Class12
	.long UiListC_Class13                       ; F88F0D  [19]   -> UiListC_Class13
	.long UiListC_Class14                       ; F88F11  [20]   -> UiListC_Class14
	.long UiListC_Class15                       ; F88F15  [21]   -> UiListC_Class15
	.long UiListC_Class16                       ; F88F19  [22]   -> UiListC_Class16
	.long UiListC_Class17                       ; F88F1D  [23]   -> UiListC_Class17
	.long UiListC_Class18                       ; F88F21  [24]   -> UiListC_Class18
	.long UiListC_Class19                       ; F88F25  [25]   -> UiListC_Class19
	.long UiListC_Class1A                       ; F88F29  [26]   -> UiListC_Class1A
	.long UiListC_Class1B                       ; F88F2D  [27]   -> UiListC_Class1B
	.long UiListC_Class1C                       ; F88F31  [28]   -> UiListC_Class1C
	.long UiListC_Class1D                       ; F88F35  [29]   -> UiListC_Class1D
	.long UiListC_Class1E                       ; F88F39  [30]   -> UiListC_Class1E
	.long UiListC_Class1F                       ; F88F3D  [31]   -> UiListC_Class1F
	.long UiListC_Class20                       ; F88F41  [32]   -> UiListC_Class20
	.long UiListC_Class21                       ; F88F45  [33]   -> UiListC_Class21
	.long UiListC_Class22                       ; F88F49  [34]   -> UiListC_Class22
	.long UiListC_Class23                       ; F88F4D  [35]   -> UiListC_Class23
	.long UiListC_Class24                       ; F88F51  [36]   -> UiListC_Class24
	.long UiListC_Class25                       ; F88F55  [37]   -> UiListC_Class25
	.long UiListC_Class26                       ; F88F59  [38]   -> UiListC_Class26
	.long UiListC_Class27                       ; F88F5D  [39]   -> UiListC_Class27
	.long UiListC_Class28                       ; F88F61  [40]   -> UiListC_Class28
	.long UiListC_Class29                       ; F88F65  [41]   -> UiListC_Class29
	.long UiListC_Class2A                       ; F88F69  [42]   -> UiListC_Class2A
	.long UiListC_Class2B                       ; F88F6D  [43]   -> UiListC_Class2B
	.long UiListC_Class2C                       ; F88F71  [44]   -> UiListC_Class2C
	.long UiListC_Class2D                       ; F88F75  [45]   -> UiListC_Class2D
	.long UiListC_Class2E                       ; F88F79  [46]   -> UiListC_Class2E
	.long UiListC_Class2F                       ; F88F7D  [47]   -> UiListC_Class2F
	.long UiListC_Class30                       ; F88F81  [48]   -> UiListC_Class30
	.long UiListC_Class31                       ; F88F85  [49]   -> UiListC_Class31
	.long UiListC_Class32                       ; F88F89  [50]   -> UiListC_Class32
	.long UiListC_Class33                       ; F88F8D  [51]   -> UiListC_Class33
	.long UiListC_Class34                       ; F88F91  [52]   -> UiListC_Class34
	.long UiListC_Class35                       ; F88F95  [53]   -> UiListC_Class35
	.long UiListC_Class36                       ; F88F99  [54]   -> UiListC_Class36
	.long UiListC_Class37                       ; F88F9D  [55]   -> UiListC_Class37
	.long UiListC_Class38                       ; F88FA1  [56]   -> UiListC_Class38
	.long UiListC_Class39                       ; F88FA5  [57]   -> UiListC_Class39
	.long UiListC_Class3A                       ; F88FA9  [58]   -> UiListC_Class3A
	.long UiListC_Class3B                       ; F88FAD  [59]   -> UiListC_Class3B
	.long UiListC_Class3C                       ; F88FB1  [60]   -> UiListC_Class3C
	.long UiListC_Class3D                       ; F88FB5  [61]   -> UiListC_Class3D
	.long UiListC_Class3E                       ; F88FB9  [62]   -> UiListC_Class3E
	.long UiListC_Class3F                       ; F88FBD  [63]   -> UiListC_Class3F
	.long UiListC_Class40                       ; F88FC1  [64]   -> UiListC_Class40
	.long UiListC_Class41                       ; F88FC5  [65]   -> UiListC_Class41
	.long UiListC_Class42                       ; F88FC9  [66]   -> UiListC_Class42
	.long UiListC_Shared                        ; F88FCD  [67]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FD1  [68]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FD5  [69]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FD9  [70]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FDD  [71]   -> UiListC_Shared
	.long UiListC_Class48                       ; F88FE1  [72]   -> UiListC_Class48
	.long UiListC_Shared                        ; F88FE5  [73]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FE9  [74]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FED  [75]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FF1  [76]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FF5  [77]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FF9  [78]   -> UiListC_Shared
	.long UiListC_Shared                        ; F88FFD  [79]   -> UiListC_Shared
	.long UiListC_Class50                       ; F89001  [80]   -> UiListC_Class50
	.long UiListC_Class51                       ; F89005  [81]   -> UiListC_Class51
	.long UiListC_Class52                       ; F89009  [82]   -> UiListC_Class52
	.long UiListC_Class53                       ; F8900D  [83]   -> UiListC_Class53
	.long UiListC_Class54                       ; F89011  [84]   -> UiListC_Class54
	.long UiListC_Shared                        ; F89015  [85]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89019  [86]   -> UiListC_Shared
	.long UiListC_Shared                        ; F8901D  [87]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89021  [88]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89025  [89]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89029  [90]   -> UiListC_Shared
	.long UiListC_Shared                        ; F8902D  [91]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89031  [92]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89035  [93]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89039  [94]   -> UiListC_Shared
	.long UiListC_Shared                        ; F8903D  [95]   -> UiListC_Shared
	.long UiListC_Class60                       ; F89041  [96]   -> UiListC_Class60
	.long UiListC_Class61                       ; F89045  [97]   -> UiListC_Class61
	.long UiListC_Class62                       ; F89049  [98]   -> UiListC_Class62
	.long UiListC_Class63                       ; F8904D  [99]   -> UiListC_Class63
	.long UiListC_Class64                       ; F89051  [100]   -> UiListC_Class64
	.long UiListC_Class65                       ; F89055  [101]   -> UiListC_Class65
	.long UiListC_Class66                       ; F89059  [102]   -> UiListC_Class66
	.long UiListC_Shared                        ; F8905D  [103]   -> UiListC_Shared
	.long UiListC_Class68                       ; F89061  [104]   -> UiListC_Class68
	.long UiListC_Class69                       ; F89065  [105]   -> UiListC_Class69
	.long UiListC_Class6A                       ; F89069  [106]   -> UiListC_Class6A
	.long UiListC_Class6B                       ; F8906D  [107]   -> UiListC_Class6B
	.long UiListC_Class6C                       ; F89071  [108]   -> UiListC_Class6C
	.long UiListC_Class6D                       ; F89075  [109]   -> UiListC_Class6D
	.long UiListC_Class6E                       ; F89079  [110]   -> UiListC_Class6E
	.long UiListC_Shared                        ; F8907D  [111]   -> UiListC_Shared
	.long UiListC_Class70                       ; F89081  [112]   -> UiListC_Class70
	.long UiListC_Class71                       ; F89085  [113]   -> UiListC_Class71
	.long UiListC_Class72                       ; F89089  [114]   -> UiListC_Class72
	.long UiListC_Shared                        ; F8908D  [115]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89091  [116]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89095  [117]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89099  [118]   -> UiListC_Shared
	.long UiListC_Shared                        ; F8909D  [119]   -> UiListC_Shared
	.long UiListC_Class78                       ; F890A1  [120]   -> UiListC_Class78
	.long UiListC_Class79                       ; F890A5  [121]   -> UiListC_Class79
	.long UiListC_Class7A                       ; F890A9  [122]   -> UiListC_Class7A
	.long UiListC_Shared                        ; F890AD  [123]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890B1  [124]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890B5  [125]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890B9  [126]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890BD  [127]   -> UiListC_Shared
	.long UiListC_Class80                       ; F890C1  [128]   -> UiListC_Class80
	.long UiListC_Class81                       ; F890C5  [129]   -> UiListC_Class81
	.long UiListC_Shared                        ; F890C9  [130]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890CD  [131]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890D1  [132]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890D5  [133]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890D9  [134]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890DD  [135]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890E1  [136]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890E5  [137]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890E9  [138]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890ED  [139]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890F1  [140]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890F5  [141]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890F9  [142]   -> UiListC_Shared
	.long UiListC_Shared                        ; F890FD  [143]   -> UiListC_Shared
	.long UiListC_Class90                       ; F89101  [144]   -> UiListC_Class90
	.long UiListC_Class91                       ; F89105  [145]   -> UiListC_Class91
	.long UiListC_Class92                       ; F89109  [146]   -> UiListC_Class92
	.long UiListC_Class93                       ; F8910D  [147]   -> UiListC_Class93
	.long UiListC_Shared                        ; F89111  [148]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89115  [149]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89119  [150]   -> UiListC_Shared
	.long UiListC_Shared                        ; F8911D  [151]   -> UiListC_Shared
	.long UiListC_Class98                       ; F89121  [152]   -> UiListC_Class98
	.long UiListC_Class99                       ; F89125  [153]   -> UiListC_Class99
	.long UiListC_Class9A                       ; F89129  [154]   -> UiListC_Class9A
	.long UiListC_Shared                        ; F8912D  [155]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89131  [156]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89135  [157]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89139  [158]   -> UiListC_Shared
	.long UiListC_Shared                        ; F8913D  [159]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89141  [160]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89145  [161]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89149  [162]   -> UiListC_Shared
	.long UiListC_Shared                        ; F8914D  [163]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89151  [164]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89155  [165]   -> UiListC_Shared
	.long UiListC_Shared                        ; F89159  [166]   -> UiListC_Shared
	.long UiListC_Shared                        ; F8915D  [167]   -> UiListC_Shared
	.long UiListC_ClassA8                       ; F89161  [168]   -> UiListC_ClassA8
	.long UiListC_ClassA9                       ; F89165  [169]   -> UiListC_ClassA9
	.long UiListC_Shared                        ; F89169  [170]   -> UiListC_Shared
	.long UiListC_Shared                        ; F8916D  [171]   -> UiListC_Shared
	.long UiListC_ClassAC                       ; F89171  [172]   -> UiListC_ClassAC
	.long UiListC_ClassAD                       ; F89175  [173]   -> UiListC_ClassAD
	.long UiListC_ClassAE                       ; F89179  [174]   -> UiListC_ClassAE
	.long UiListC_Shared                        ; F8917D  [175]   -> UiListC_Shared
	.long UiListC_ClassB0                       ; F89181  [176]   -> UiListC_ClassB0
	.long UiListC_ClassB1                       ; F89185  [177]   -> UiListC_ClassB1
	.long UiListC_ClassB2                       ; F89189  [178]   -> UiListC_ClassB2
	.long UiListC_ClassB3                       ; F8918D  [179]   -> UiListC_ClassB3
	.long UiListC_ClassB4                       ; F89191  [180]   -> UiListC_ClassB4
	.long UiListC_ClassB5                       ; F89195  [181]   -> UiListC_ClassB5
	.long UiListC_ClassB6                       ; F89199  [182]   -> UiListC_ClassB6
	.long UiListC_ClassB7                       ; F8919D  [183]   -> UiListC_ClassB7
	.long UiListC_ClassB8                       ; F891A1  [184]   -> UiListC_ClassB8
	.long UiListC_ClassB9                       ; F891A5  [185]   -> UiListC_ClassB9
	.long UiListC_ClassBA                       ; F891A9  [186]   -> UiListC_ClassBA
	.long UiListC_ClassBB                       ; F891AD  [187]   -> UiListC_ClassBB
	.long UiListC_ClassBC                       ; F891B1  [188]   -> UiListC_ClassBC
	.long UiListC_ClassBD                       ; F891B5  [189]   -> UiListC_ClassBD
	.long UiListC_Shared                        ; F891B9  [190]   -> UiListC_Shared
	.long UiListC_Shared                        ; F891BD  [191]   -> UiListC_Shared

; --- 0xF891C1-0xF891C1  pad (1 bytes) ---
	.byte 0xff   ; F891C1

; --- 0xF891C2-0xF893B5  handler lists (500 bytes) ---
; ---------------------------------------------------------------------
; UiEventLists_C -- the 122 handler lists of pass C, tiling 0xF891C2-0xF893B5
;
; Each list is LE32 routine addresses terminated by 0xFFFFFFFF.  120 of
; the 122 are EMPTY (the terminator and nothing else); 2 carry handlers.
; ⚠ The labels below are GENERATED: each is named after the LOWEST class
; id whose UiEventClass_ListTable_C entry points at it, and says nothing
; about what the list DOES.  UiListC_Shared is the empty list the 71
; classes without their own head share.
; Evidence: the heads are the table's own values -- nothing here is
;          framed by content.  They tile the area with no gap and no
;          overlap, every one ends in 0xFFFFFFFF, and the last one ends
;          exactly at the area's end (checks L3, L5).
; ---------------------------------------------------------------------
; Evidence: UiEventClass_ListTable_C[0x00], the LE32 at 0xF88EC1, holds 0xF891C2.  GENERATED name.
UiListC_Class00:
	.long 0xFFFFFFFF                            ; F891C2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x01], the LE32 at 0xF88EC5, holds 0xF891C6.  GENERATED name.
UiListC_Class01:
	.long 0xFFFFFFFF                            ; F891C6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x02], the LE32 at 0xF88EC9, holds 0xF891CA.  GENERATED name.
UiListC_Class02:
	.long 0xFFFFFFFF                            ; F891CA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x03], the LE32 at 0xF88ECD, holds 0xF891CE.  GENERATED name.
UiListC_Class03:
	.long 0xFFFFFFFF                            ; F891CE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x04], the LE32 at 0xF88ED1, holds 0xF891D2.  GENERATED name.
UiListC_Class04:
	.long 0xFFFFFFFF                            ; F891D2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x05], the LE32 at 0xF88ED5, holds 0xF891D6.  GENERATED name.
UiListC_Class05:
	.long 0xFFFFFFFF                            ; F891D6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x06], the LE32 at 0xF88ED9, holds 0xF891DA.  GENERATED name.
UiListC_Class06:
	.long 0xFFFFFFFF                            ; F891DA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x07], the LE32 at 0xF88EDD, holds 0xF891DE.  GENERATED name.
UiListC_Class07:
	.long 0xFFFFFFFF                            ; F891DE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x08], the LE32 at 0xF88EE1, holds 0xF891E2.  GENERATED name.
UiListC_Class08:
	.long 0xFFFFFFFF                            ; F891E2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x09], the LE32 at 0xF88EE5, holds 0xF891E6.  GENERATED name.
UiListC_Class09:
	.long 0xFFFFFFFF                            ; F891E6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x0A], the LE32 at 0xF88EE9, holds 0xF891EA.  GENERATED name.
UiListC_Class0A:
	.long 0xFFFFFFFF                            ; F891EA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x0B], the LE32 at 0xF88EED, holds 0xF891EE.  GENERATED name.
UiListC_Class0B:
	.long 0xFFFFFFFF                            ; F891EE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x0C], the LE32 at 0xF88EF1, holds 0xF891F2.  GENERATED name.
UiListC_Class0C:
	.long 0xFFFFFFFF                            ; F891F2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x0D], the LE32 at 0xF88EF5, holds 0xF891F6.  GENERATED name.
UiListC_Class0D:
	.long 0xFFFFFFFF                            ; F891F6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x0E], the LE32 at 0xF88EF9, holds 0xF891FA.  GENERATED name.
UiListC_Class0E:
	.long 0xFFFFFFFF                            ; F891FA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x0F], the LE32 at 0xF88EFD, holds 0xF891FE.  GENERATED name.
UiListC_Class0F:
	.long 0xFFFFFFFF                            ; F891FE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x10], the LE32 at 0xF88F01, holds 0xF89202.  GENERATED name.
UiListC_Class10:
	.long 0xFFFFFFFF                            ; F89202  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x11], the LE32 at 0xF88F05, holds 0xF89206.  GENERATED name.
UiListC_Class11:
	.long 0xFFFFFFFF                            ; F89206  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x12], the LE32 at 0xF88F09, holds 0xF8920A.  GENERATED name.
UiListC_Class12:
	.long 0xFFFFFFFF                            ; F8920A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x13], the LE32 at 0xF88F0D, holds 0xF8920E.  GENERATED name.
UiListC_Class13:
	.long 0xFFFFFFFF                            ; F8920E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x14], the LE32 at 0xF88F11, holds 0xF89212.  GENERATED name.
UiListC_Class14:
	.long 0xFFFFFFFF                            ; F89212  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x15], the LE32 at 0xF88F15, holds 0xF89216.  GENERATED name.
UiListC_Class15:
	.long 0xFFFFFFFF                            ; F89216  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x16], the LE32 at 0xF88F19, holds 0xF8921A.  GENERATED name.
UiListC_Class16:
	.long 0xFFFFFFFF                            ; F8921A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x17], the LE32 at 0xF88F1D, holds 0xF8921E.  GENERATED name.
UiListC_Class17:
	.long 0xFFFFFFFF                            ; F8921E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x18], the LE32 at 0xF88F21, holds 0xF89222.  GENERATED name.
UiListC_Class18:
	.long 0xFFFFFFFF                            ; F89222  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x19], the LE32 at 0xF88F25, holds 0xF89226.  GENERATED name.
UiListC_Class19:
	.long 0xFFFFFFFF                            ; F89226  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x1A], the LE32 at 0xF88F29, holds 0xF8922A.  GENERATED name.
UiListC_Class1A:
	.long 0xFFFFFFFF                            ; F8922A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x1B], the LE32 at 0xF88F2D, holds 0xF8922E.  GENERATED name.
UiListC_Class1B:
	.long 0xFFFFFFFF                            ; F8922E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x1C], the LE32 at 0xF88F31, holds 0xF89232.  GENERATED name.
UiListC_Class1C:
	.long 0xFFFFFFFF                            ; F89232  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x1D], the LE32 at 0xF88F35, holds 0xF89236.  GENERATED name.
UiListC_Class1D:
	.long 0xFFFFFFFF                            ; F89236  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x1E], the LE32 at 0xF88F39, holds 0xF8923A.  GENERATED name.
UiListC_Class1E:
	.long 0xFFFFFFFF                            ; F8923A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x1F], the LE32 at 0xF88F3D, holds 0xF8923E.  GENERATED name.
UiListC_Class1F:
	.long 0xFFFFFFFF                            ; F8923E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x20], the LE32 at 0xF88F41, holds 0xF89242.  GENERATED name.
UiListC_Class20:
	.long 0xFFFFFFFF                            ; F89242  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x21], the LE32 at 0xF88F45, holds 0xF89246.  GENERATED name.
UiListC_Class21:
	.long 0xFFFFFFFF                            ; F89246  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x22], the LE32 at 0xF88F49, holds 0xF8924A.  GENERATED name.
UiListC_Class22:
	.long 0xFFFFFFFF                            ; F8924A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x23], the LE32 at 0xF88F4D, holds 0xF8924E.  GENERATED name.
UiListC_Class23:
	.long 0xFFFFFFFF                            ; F8924E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x24], the LE32 at 0xF88F51, holds 0xF89252.  GENERATED name.
UiListC_Class24:
	.long 0xFFFFFFFF                            ; F89252  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x25], the LE32 at 0xF88F55, holds 0xF89256.  GENERATED name.
UiListC_Class25:
	.long 0xFFFFFFFF                            ; F89256  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x26], the LE32 at 0xF88F59, holds 0xF8925A.  GENERATED name.
UiListC_Class26:
	.long 0xFFFFFFFF                            ; F8925A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x27], the LE32 at 0xF88F5D, holds 0xF8925E.  GENERATED name.
UiListC_Class27:
	.long 0xFFFFFFFF                            ; F8925E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x28], the LE32 at 0xF88F61, holds 0xF89262.  GENERATED name.
UiListC_Class28:
	.long 0xFFFFFFFF                            ; F89262  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x29], the LE32 at 0xF88F65, holds 0xF89266.  GENERATED name.
UiListC_Class29:
	.long 0xFFFFFFFF                            ; F89266  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x2A], the LE32 at 0xF88F69, holds 0xF8926A.  GENERATED name.
UiListC_Class2A:
	.long 0xFFFFFFFF                            ; F8926A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x2B], the LE32 at 0xF88F6D, holds 0xF8926E.  GENERATED name.
UiListC_Class2B:
	.long 0xFFFFFFFF                            ; F8926E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x2C], the LE32 at 0xF88F71, holds 0xF89272.  GENERATED name.
UiListC_Class2C:
	.long 0xFFFFFFFF                            ; F89272  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x2D], the LE32 at 0xF88F75, holds 0xF89276.  GENERATED name.
UiListC_Class2D:
	.long 0xFFFFFFFF                            ; F89276  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x2E], the LE32 at 0xF88F79, holds 0xF8927A.  GENERATED name.
UiListC_Class2E:
	.long 0xFFFFFFFF                            ; F8927A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x2F], the LE32 at 0xF88F7D, holds 0xF8927E.  GENERATED name.
UiListC_Class2F:
	.long 0xFFFFFFFF                            ; F8927E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x30], the LE32 at 0xF88F81, holds 0xF89282.  GENERATED name.
UiListC_Class30:
	.long 0xFFFFFFFF                            ; F89282  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x31], the LE32 at 0xF88F85, holds 0xF89286.  GENERATED name.
UiListC_Class31:
	.long 0xFFFFFFFF                            ; F89286  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x32], the LE32 at 0xF88F89, holds 0xF8928A.  GENERATED name.
UiListC_Class32:
	.long 0xFFFFFFFF                            ; F8928A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x33], the LE32 at 0xF88F8D, holds 0xF8928E.  GENERATED name.
UiListC_Class33:
	.long 0xFFFFFFFF                            ; F8928E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x34], the LE32 at 0xF88F91, holds 0xF89292.  GENERATED name.
UiListC_Class34:
	.long 0xFFFFFFFF                            ; F89292  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x35], the LE32 at 0xF88F95, holds 0xF89296.  GENERATED name.
UiListC_Class35:
	.long 0xFFFFFFFF                            ; F89296  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x36], the LE32 at 0xF88F99, holds 0xF8929A.  GENERATED name.
UiListC_Class36:
	.long 0xFFFFFFFF                            ; F8929A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x37], the LE32 at 0xF88F9D, holds 0xF8929E.  GENERATED name.
UiListC_Class37:
	.long 0xFFFFFFFF                            ; F8929E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x38], the LE32 at 0xF88FA1, holds 0xF892A2.  GENERATED name.
UiListC_Class38:
	.long 0xFFFFFFFF                            ; F892A2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x39], the LE32 at 0xF88FA5, holds 0xF892A6.  GENERATED name.
UiListC_Class39:
	.long 0xFFFFFFFF                            ; F892A6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x3A], the LE32 at 0xF88FA9, holds 0xF892AA.  GENERATED name.
UiListC_Class3A:
	.long 0xFFFFFFFF                            ; F892AA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x3B], the LE32 at 0xF88FAD, holds 0xF892AE.  GENERATED name.
UiListC_Class3B:
	.long 0xFFFFFFFF                            ; F892AE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x3C], the LE32 at 0xF88FB1, holds 0xF892B2.  GENERATED name.
UiListC_Class3C:
	.long 0xFFFFFFFF                            ; F892B2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x3D], the LE32 at 0xF88FB5, holds 0xF892B6.  GENERATED name.
UiListC_Class3D:
	.long 0xFFFFFFFF                            ; F892B6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x3E], the LE32 at 0xF88FB9, holds 0xF892BA.  GENERATED name.
UiListC_Class3E:
	.long 0xFFFFFFFF                            ; F892BA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x3F], the LE32 at 0xF88FBD, holds 0xF892BE.  GENERATED name.
UiListC_Class3F:
	.long 0xFFFFFFFF                            ; F892BE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x40], the LE32 at 0xF88FC1, holds 0xF892C2.  GENERATED name.
UiListC_Class40:
	.long 0xFFFFFFFF                            ; F892C2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x41], the LE32 at 0xF88FC5, holds 0xF892C6.  GENERATED name.
UiListC_Class41:
	.long 0xFFFFFFFF                            ; F892C6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x42], the LE32 at 0xF88FC9, holds 0xF892CA.  GENERATED name.
UiListC_Class42:
	.long 0xFFFFFFFF                            ; F892CA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x48], the LE32 at 0xF88FE1, holds 0xF892CE.  GENERATED name.
UiListC_Class48:
	.long 0xFFFFFFFF                            ; F892CE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x50], the LE32 at 0xF89001, holds 0xF892D2.  GENERATED name.
UiListC_Class50:
	.long 0xFFFFFFFF                            ; F892D2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x51], the LE32 at 0xF89005, holds 0xF892D6.  GENERATED name.
UiListC_Class51:
	.long 0xFFFFFFFF                            ; F892D6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x52], the LE32 at 0xF89009, holds 0xF892DA.  GENERATED name.
UiListC_Class52:
	.long 0xFFFFFFFF                            ; F892DA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x53], the LE32 at 0xF8900D, holds 0xF892DE.  GENERATED name.
UiListC_Class53:
	.long 0xFFFFFFFF                            ; F892DE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x54], the LE32 at 0xF89011, holds 0xF892E2.  GENERATED name.
UiListC_Class54:
	.long 0xFFFFFFFF                            ; F892E2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x60], the LE32 at 0xF89041, holds 0xF892E6.  GENERATED name.
UiListC_Class60:
	.long 0xFFFFFFFF                            ; F892E6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x61], the LE32 at 0xF89045, holds 0xF892EA.  GENERATED name.
UiListC_Class61:
	.long 0xFFFFFFFF                            ; F892EA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x62], the LE32 at 0xF89049, holds 0xF892EE.  GENERATED name.
UiListC_Class62:
	.long 0xFFFFFFFF                            ; F892EE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x63], the LE32 at 0xF8904D, holds 0xF892F2.  GENERATED name.
UiListC_Class63:
	.long 0xFFFFFFFF                            ; F892F2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x64], the LE32 at 0xF89051, holds 0xF892F6.  GENERATED name.
UiListC_Class64:
	.long 0xFFFFFFFF                            ; F892F6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x65], the LE32 at 0xF89055, holds 0xF892FA.  GENERATED name.
UiListC_Class65:
	.long 0xFFFFFFFF                            ; F892FA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x66], the LE32 at 0xF89059, holds 0xF892FE.  GENERATED name.
UiListC_Class66:
	.long 0xFFFFFFFF                            ; F892FE  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x68], the LE32 at 0xF89061, holds 0xF89302.  GENERATED name.
UiListC_Class68:
	.long 0xFFFFFFFF                            ; F89302  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x69], the LE32 at 0xF89065, holds 0xF89306.  GENERATED name.
UiListC_Class69:
	.long 0xFFFFFFFF                            ; F89306  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x6A], the LE32 at 0xF89069, holds 0xF8930A.  GENERATED name.
UiListC_Class6A:
	.long 0xFFFFFFFF                            ; F8930A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x6B], the LE32 at 0xF8906D, holds 0xF8930E.  GENERATED name.
UiListC_Class6B:
	.long 0xFFFFFFFF                            ; F8930E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x6C], the LE32 at 0xF89071, holds 0xF89312.  GENERATED name.
UiListC_Class6C:
	.long 0xFFFFFFFF                            ; F89312  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x6D], the LE32 at 0xF89075, holds 0xF89316.  GENERATED name.
UiListC_Class6D:
	.long 0xFFFFFFFF                            ; F89316  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x6E], the LE32 at 0xF89079, holds 0xF8931A.  GENERATED name.
UiListC_Class6E:
	.long 0xFFFFFFFF                            ; F8931A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x70], the LE32 at 0xF89081, holds 0xF8931E.  GENERATED name.
UiListC_Class70:
	.long 0xFFFFFFFF                            ; F8931E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x71], the LE32 at 0xF89085, holds 0xF89322.  GENERATED name.
UiListC_Class71:
	.long 0xFFFFFFFF                            ; F89322  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x72], the LE32 at 0xF89089, holds 0xF89326.  GENERATED name.
UiListC_Class72:
	.long 0xFFFFFFFF                            ; F89326  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x78], the LE32 at 0xF890A1, holds 0xF8932A.  GENERATED name.
UiListC_Class78:
	.long 0xFFFFFFFF                            ; F8932A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x79], the LE32 at 0xF890A5, holds 0xF8932E.  GENERATED name.
UiListC_Class79:
	.long 0xFFFFFFFF                            ; F8932E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x7A], the LE32 at 0xF890A9, holds 0xF89332.  GENERATED name.
UiListC_Class7A:
	.long 0xFFFFFFFF                            ; F89332  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x80], the LE32 at 0xF890C1, holds 0xF89336.  GENERATED name.
UiListC_Class80:
	.long 0xFFFFFFFF                            ; F89336  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x81], the LE32 at 0xF890C5, holds 0xF8933A.  GENERATED name.
UiListC_Class81:
	.long 0xFFFFFFFF                            ; F8933A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x90], the LE32 at 0xF89101, holds 0xF8933E.  GENERATED name.
UiListC_Class90:
	.long 0xFFFFFFFF                            ; F8933E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x91], the LE32 at 0xF89105, holds 0xF89342.  GENERATED name.
UiListC_Class91:
	.long 0xFFFFFFFF                            ; F89342  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x92], the LE32 at 0xF89109, holds 0xF89346.  GENERATED name.
UiListC_Class92:
	.long 0xFFFFFFFF                            ; F89346  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x93], the LE32 at 0xF8910D, holds 0xF8934A.  GENERATED name.
UiListC_Class93:
	.long 0xFFFFFFFF                            ; F8934A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x98], the LE32 at 0xF89121, holds 0xF8934E.  GENERATED name.
UiListC_Class98:
	.long 0xFFFFFFFF                            ; F8934E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x99], the LE32 at 0xF89125, holds 0xF89352.  GENERATED name.
UiListC_Class99:
	.long 0xFFFFFFFF                            ; F89352  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0x9A], the LE32 at 0xF89129, holds 0xF89356.  GENERATED name.
UiListC_Class9A:
	.long 0xFFFFFFFF                            ; F89356  [0]   end of list

; ---------------------------------------------------------------------
; UiListC_ClassA8 -- 1 handler(s) for event class 0xA8 in pass C
;
; Entries: 0xF415AC, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_C[0xA8].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_C[0xA8], the LE32 at 0xF89161,
;          holds 0xF8935A.  The list ENDS at 0xF89362 because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListC_ClassA8:
	.long T_UiEventClassA8_ShowGroupScreen                              ; F8935A  [0]   -> 0xF415AC
	.long 0xFFFFFFFF                            ; F8935E  [1]   end of list

; ---------------------------------------------------------------------
; UiListC_ClassA9 -- 2 handler(s) for event class 0xA9 in pass C
;
; Entries: 0xF8659B, 0xF42F00, then the terminator.
; Read by: UiEventList_Run 0xF86A03, after UiEventClass_ListTable_C[0xA9].
; Payload the handlers see: (0x20B8)/(0x20B9) = the record's bytes
;          +1 and +2, (0x20BA) = byte +3, (0x20BB) = the class.
; Evidence: UiEventClass_ListTable_C[0xA9], the LE32 at 0xF89165,
;          holds 0xF89362.  The list ENDS at 0xF8936E because the next
;          head in the table is there.  The NAME is generated from
;          the index; what the handlers DO is not claimed here.
; ---------------------------------------------------------------------
UiListC_ClassA9:
	.long UiEvent_RouteByCode                   ; F89362  [0]   -> UiEvent_RouteByCode
	.long T_F42F00                              ; F89366  [1]   -> 0xF42F00
	.long 0xFFFFFFFF                            ; F8936A  [2]   end of list
; Evidence: UiEventClass_ListTable_C[0xAC], the LE32 at 0xF89171, holds 0xF8936E.  GENERATED name.
UiListC_ClassAC:
	.long 0xFFFFFFFF                            ; F8936E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xAD], the LE32 at 0xF89175, holds 0xF89372.  GENERATED name.
UiListC_ClassAD:
	.long 0xFFFFFFFF                            ; F89372  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xAE], the LE32 at 0xF89179, holds 0xF89376.  GENERATED name.
UiListC_ClassAE:
	.long 0xFFFFFFFF                            ; F89376  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB0], the LE32 at 0xF89181, holds 0xF8937A.  GENERATED name.
UiListC_ClassB0:
	.long 0xFFFFFFFF                            ; F8937A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB1], the LE32 at 0xF89185, holds 0xF8937E.  GENERATED name.
UiListC_ClassB1:
	.long 0xFFFFFFFF                            ; F8937E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB2], the LE32 at 0xF89189, holds 0xF89382.  GENERATED name.
UiListC_ClassB2:
	.long 0xFFFFFFFF                            ; F89382  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB3], the LE32 at 0xF8918D, holds 0xF89386.  GENERATED name.
UiListC_ClassB3:
	.long 0xFFFFFFFF                            ; F89386  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB4], the LE32 at 0xF89191, holds 0xF8938A.  GENERATED name.
UiListC_ClassB4:
	.long 0xFFFFFFFF                            ; F8938A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB5], the LE32 at 0xF89195, holds 0xF8938E.  GENERATED name.
UiListC_ClassB5:
	.long 0xFFFFFFFF                            ; F8938E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB6], the LE32 at 0xF89199, holds 0xF89392.  GENERATED name.
UiListC_ClassB6:
	.long 0xFFFFFFFF                            ; F89392  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB7], the LE32 at 0xF8919D, holds 0xF89396.  GENERATED name.
UiListC_ClassB7:
	.long 0xFFFFFFFF                            ; F89396  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB8], the LE32 at 0xF891A1, holds 0xF8939A.  GENERATED name.
UiListC_ClassB8:
	.long 0xFFFFFFFF                            ; F8939A  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xB9], the LE32 at 0xF891A5, holds 0xF8939E.  GENERATED name.
UiListC_ClassB9:
	.long 0xFFFFFFFF                            ; F8939E  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xBA], the LE32 at 0xF891A9, holds 0xF893A2.  GENERATED name.
UiListC_ClassBA:
	.long 0xFFFFFFFF                            ; F893A2  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xBB], the LE32 at 0xF891AD, holds 0xF893A6.  GENERATED name.
UiListC_ClassBB:
	.long 0xFFFFFFFF                            ; F893A6  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xBC], the LE32 at 0xF891B1, holds 0xF893AA.  GENERATED name.
UiListC_ClassBC:
	.long 0xFFFFFFFF                            ; F893AA  [0]   end of list
; Evidence: UiEventClass_ListTable_C[0xBD], the LE32 at 0xF891B5, holds 0xF893AE.  GENERATED name.
UiListC_ClassBD:
	.long 0xFFFFFFFF                            ; F893AE  [0]   end of list

; ---------------------------------------------------------------------
; UiListC_Shared -- the empty list 71 class ids share
;
; Classes: every id NOT in the 121-member set the three tables agree
;          on.  Generated from the table, not typed:
;          0x43-0x47, 0x49-0x4F, 0x55-0x5F, 0x67, 0x6F, 0x73-0x77,
;          0x7B-0x7F, 0x82-0x8F, 0x94-0x97, 0x9B-0xA7, 0xAA-0xAB, 0xAF,
;          0xBE-0xBF
;          Check L2 asserts the set is the same in all three tables.
; Position: it is the LAST object in the area, and its 4 bytes are what
;          make the tiling reach 0xF893B6 exactly.
; Evidence: 71 of the 192 LE32 entries of UiEventClass_ListTable_C hold
;          0xF893B2, and the word there is the 0xFFFFFFFF terminator.
; ---------------------------------------------------------------------
UiListC_Shared:
	.long 0xFFFFFFFF                            ; F893B2  [0]   end of list

; --- 0xF893B6-0xF89670  0x00 pad (699 bytes) ---
	.fill 699, 1, 0x00

; --- 0xF89671-0xF89674  0xFFFFFFFF-terminated list (4 bytes) ---

; ---------------------------------------------------------------------
; UiEventPassC_TailList -- LE32 routines run once, after the whole list
;
; Read by: ONE site, `ld XIY,0x00F89671 / ld (0x20C4),XIY` at UiEventList_RunPassC 0xF869BC.
;          UiEventList_Run walks it at 0xF86A6A-0xF86A7E after the
;          record loop, calling every entry until a word 0xFFFF.
; Entries: none (0), then the 0xFFFF terminator.
; ENTRY COUNT: the terminator IS the count; the bytes after it are the
;          0x00 pad that runs to the next object.
; Evidence: `ld XIY,0x00F89671` at 0xF869C5, four bytes before `ld (0x20C4),XIY`;
;          UiEventList_Run reads (0x20C4) at 0xF86A6A and stops on
;          `cp (XIX),0xffff`.
; ---------------------------------------------------------------------
UiEventPassC_TailList:
	.long 0xFFFFFFFF                            ; F89671  [0]   end of list

; --- 0xF89675-0xF89684  0x00 pad (16 bytes) ---
	.fill 16, 1, 0x00

; --- 0xF89685-0xF89685  pad (1 bytes) ---
	.byte 0xff   ; F89685

; --- 0xF89686-0xF8969A  0x00 pad (21 bytes) ---
	.fill 21, 1, 0x00

; --- 0xF8969B-0xF897FF  0x0E pad (357 bytes) ---
	.fill 357, 1, 0x0E
